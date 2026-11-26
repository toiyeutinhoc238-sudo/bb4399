extends "flash_screen.gd"













const Film = preload("level_up_film.gd")
const HallAtlas = preload("hall_atlas.gd")
const PopQueue = preload("pop_queue.gd")
const Text = preload("../i18n.gd")

const POP_ID: String = "level_up"
const FIRST_PAY_ID: String = "first_pay"
const AUTO_FIRST_CHARGE_LV: int = -1
const FIRST_CHARGE_ICON: int = 1 << 24
const DIM: Color = Color(0, 0, 0, 153 / 255.0)
const MOVIE_AT: Vector2 = Vector2(300, 50)
const SOUND: String = "u/levelup"
const SHOW_IN: Array = ["lobby", "hall", "room"]
const NO_TIP_ROOMS: Array = [2, 9]
const NO_TIP_MAPS: Array = [2, 4]
const LOAD_WAIT: float = 4.0
const SOUND_WAIT: float = 2.0
const BLUR_COPIES: int = 5
const BLUR_ALPHA: float = 0.85

signal closed

var queue: PopQueue
var first_pay_level: int = AUTO_FIRST_CHARGE_LV
var level: int = -1
var _clock: float = 0.0
var _waited: float = 0.0
var _rolling: bool = false
var _sound_due: bool = false
var _sound_waited: float = 0.0

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_use(HallAtlas.FILE, HallAtlas.R)
	if queue == null:
		queue = PopQueue.new()
		queue.client = client
		add_child(queue)
	queue.register(POP_ID, _open)
	if client != null:
		client.level_up.connect(notice)
		client.changed.connect(_pump)


func notice(value: int) -> void :
	if show_tip():
		queue.append(POP_ID, value)
	if value == first_pay_level and (int(client.character.get("actionFlag", 0)) & FIRST_CHARGE_ICON) != 0 and client.first_charge <= 0:
		queue.append(FIRST_PAY_ID)


func show_tip() -> bool:
	if client == null or client.state != "battle":
		return true
	if int(client.battle.room_type) in NO_TIP_ROOMS:
		return false
	var info: Dictionary = Text.map_info(int(client.battle.map_id))
	return info.is_empty() or int(info.get("type", 0)) not in NO_TIP_MAPS


func _open(value: Variant) -> bool:
	level = maxi(0, int(value))
	_clock = 0.0
	_waited = 0.0
	_rolling = false
	_sound_due = true
	_sound_waited = 0.0
	_loaded()
	_pump()
	return true


func _pump() -> void :
	if client == null:
		return
	if client.state not in SHOW_IN and client.state != "battle":
		level = -1
		_sound_due = false
	var want: bool = level >= 0 and client.state in SHOW_IN
	if visible != want:
		visible = want

func close() -> void :
	if level < 0:
		return
	level = -1
	_sound_due = false
	visible = false
	closed.emit()
	queue.closed()


func tick() -> int:
	return floori(_clock * Film.FPS) if _rolling else -1


func can_close() -> bool:
	var at: int = tick()
	return level >= 0 and at >= 0 and float(Film.BUTTON_ALPHA[mini(at, Film.COUNT - 1)]) >= 1.0


func _loaded() -> bool:
	if pack == null:
		return true
	var done: bool = true
	for key: String in [Film.OVER, Film.GLOW, Film.RAYS]:
		if pack.effect(key).is_empty() and not pack.effect_failed(key):
			done = false
	return done

func _tick(delta: float) -> void :
	if level < 0:
		return
	if _sound_due:
		_sound_waited += delta
		if pack != null and pack.sound("s/%s.mp3" % SOUND) != null:
			_sound_due = false
			Sound.play(SOUND)
		elif _sound_waited > SOUND_WAIT:
			_sound_due = false
	if not _rolling:
		_waited += delta
		_rolling = _loaded() or _waited >= LOAD_WAIT
		return
	_clock += delta



func _paint() -> void :
	if level < 0:
		return
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: int = tick()
	if at < 0:
		return
	var frame: int = mini(at, Film.COUNT - 1)
	var origin: Vector2 = (_stage() + MOVIE_AT) * _f
	_draw_glow(origin, frame)
	_draw_rays(origin, frame, at)
	_draw_avatar(origin, frame)
	_draw_level(origin, frame)
	_draw_film(pack.effect(Film.OVER) if pack != null else {}, frame, Transform2D(0.0, Vector2(_f, _f), 0.0, origin), Color.WHITE, Vector2.ZERO)
	draw_set_transform_matrix(Transform2D.IDENTITY)


static func flash_matrix(row: Array) -> Transform2D:
	return Transform2D(Vector2(float(row[0]), float(row[1])), Vector2(float(row[2]), float(row[3])), Vector2(float(row[4]), float(row[5])))


func _layer(origin: Vector2, row: Array) -> Transform2D:
	return Transform2D(0.0, Vector2(_f, _f), 0.0, origin) * flash_matrix(row)


static func tint(row: Array) -> Color:
	return Color(float(row[6]) + float(row[10]) / 255.0, float(row[7]) + float(row[11]) / 255.0, float(row[8]) + float(row[12]) / 255.0, 
		clampf(float(row[9]) + float(row[13]) / 255.0, 0.0, 1.0))

static func _blur(row: Array) -> Vector2:
	return Vector2(float(row[14]), float(row[15])) if row.size() >= 16 else Vector2.ZERO

func _draw_glow(origin: Vector2, frame: int) -> void :
	var row: Array = Film.GLOW_AT[frame]
	if not row.is_empty() and pack != null:
		_draw_film(pack.effect(Film.GLOW), 0, _layer(origin, row), tint(row), Vector2.ZERO)


func _draw_rays(origin: Vector2, frame: int, at: int) -> void :
	var row: Array = Film.RAYS_AT[frame]
	if row.is_empty() or pack == null:
		return
	var turn: Transform2D = flash_matrix(Film.SPIN[posmod(at - Film.RAYS_BORN, Film.SPIN.size())]) * flash_matrix(Film.SPIN[0]).affine_inverse()
	_draw_film(pack.effect(Film.RAYS), 0, _layer(origin, row) * turn, tint(row), Vector2.ZERO)


func _draw_avatar(origin: Vector2, frame: int) -> void :
	var row: Array = Film.AVATAR_AT[frame]
	if row.is_empty() or pack == null or client == null:
		return
	var key: String = str(pack.lobby.get("avatars", {}).get(str(int(client.character.get("avatarId", 0))), ""))
	var art: Texture2D = pack.picture("l/av/%s.webp" % key) if not key.is_empty() else null
	if art == null or art.get_width() <= 4:
		return
	var span: Vector2 = art.get_size()
	_draw_soft(art, Rect2( - span / 2.0, span), Rect2(Vector2.ZERO, span), _layer(origin, row), tint(row), _blur(row))


func _draw_level(origin: Vector2, frame: int) -> void :
	var row: Array = Film.LEVEL_AT[frame]
	var cell: Array = _cells.get("level_%d" % clampi(level, 0, 40), [])
	if row.is_empty() or cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var src: Rect2 = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	_draw_soft(cell[0], Rect2(Vector2.ZERO, src.size), src, _layer(origin, row), tint(row), _blur(row))


func _draw_film(fx: Dictionary, index: int, place: Transform2D, color: Color, blur: Vector2) -> void :
	var frames: Array = fx.get("data", {}).get("frames", [])
	var pages: Array = fx.get("pages", [])
	if index < 0 or index >= frames.size():
		return
	var cell: Dictionary = frames[index]
	var page: int = int(cell.get("page", 0))
	if page >= pages.size() or pages[page] == null:
		return
	var rect: Array = cell.get("rect", [0, 0, 0, 0])
	var pivot: Array = cell.get("pivot", [0, 0])
	var src: Rect2 = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	_draw_soft(pages[page], Rect2( - Vector2(float(pivot[0]), float(pivot[1])), src.size), src, place, color, blur)


func _draw_soft(texture: Texture2D, dst: Rect2, src: Rect2, place: Transform2D, color: Color, blur: Vector2) -> void :
	if color.a <= 0.002:
		return
	draw_set_transform_matrix(place)
	if blur.x < 1.0 and blur.y < 1.0:
		draw_texture_rect_region(texture, dst, src, color)
		return
	var copy: Color = color
	copy.a = 1.0 - pow(1.0 - minf(color.a, BLUR_ALPHA), 1.0 / BLUR_COPIES)
	for i in range(BLUR_COPIES):
		var shift: Vector2 = blur * (float(i) / float(BLUR_COPIES - 1) - 0.5)
		draw_texture_rect_region(texture, Rect2(dst.position + shift, dst.size), src, copy)



func _activate(id: String) -> void :
	if id == "shade" and can_close():
		close()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		if can_close():
			close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
