extends Control






















const TankPortrait = preload("tank_portrait.gd")
const GarageModel = preload("garage_model.gd")
const UpAtlas = preload("helper_up_atlas.gd")
const Sound = preload("res://audio.gd")
const FONT: Font = preload("res://assets/fonts/flash_ui_bold.tres")

const WIDE: float = 1000.0
const HIGH: float = 600.0
const SHIFT: float = 2.0
const END: float = 10.0 + SHIFT
const HELPER: float = 70.0
const TANK_K: Array = [0, 1, 1.01, 1.02, 1.03, 1.04, 1.06, 1.08, 1.1, 1.13, 1.16, 1.2]
const FPS: float = 24.0
const KEYS: Array = ["kcm/appear", "kcm/crash", "kcm/bown", "kcm/fire", "kcm/cry", "kcm/snooty"]
const SOUND: String = "u/challenge_battle"
const LOSE_SOUND: String = "u/lose"
const AVATAR: Vector2 = Vector2(180, 240)
const TANK: float = 200.0
const FIRES: Array = [80, 216, 352, 488, 624, 760, 896]
const SCORES: Array = [Vector2(88, 104), Vector2(762, 104)]
const SCORE_BOX: Vector2 = Vector2(180, 55)
const DIGIT: float = 30.0
const SKIP: String = "Nhấp trái để bỏ qua"
const SKIP_INK: Color = Color("30ff00")
const SKIP_RIM: Color = Color("005797", 0.8)


const PATH: PackedVector2Array = [Vector2(0, 600), Vector2(6, 567.8), Vector2(11.9, 536.2), Vector2(17.7, 505.5), Vector2(23.5, 475.4), 
	Vector2(29.2, 446.1), Vector2(35.6, 414.2), Vector2(42.2, 382.7), Vector2(48.9, 352.2), Vector2(55.7, 322.9), Vector2(63, 292.9), 
	Vector2(71.4, 261.2), Vector2(80.1, 231), Vector2(89.2, 202.5), Vector2(99.9, 172.8), Vector2(112.1, 142.9), Vector2(125.3, 115.5), 
	Vector2(140.6, 88.9), Vector2(159.2, 62.6), Vector2(179.7, 40.4), Vector2(204, 21.1), Vector2(231.6, 6.4), Vector2(262.2, -2.8), 
	Vector2(293.1, -3.2), Vector2(323, 5.4), Vector2(349.7, 20.4), Vector2(374.8, 39.8), Vector2(397.4, 60.9), Vector2(419, 83.6), 
	Vector2(439.6, 106.9), Vector2(460, 131.1), Vector2(479.6, 154.9), Vector2(500, 180)]

var pack: Node = null
var f: float = 1.0
var time: float = 0.0
var win: bool = false
var mine: Dictionary = {}
var theirs: Dictionary = {}
var _tanks: Array = []
var _top: Control = null
var _digits: Texture2D = null
var _greys: Dictionary = {}
var _lost: bool = false

func _ready() -> void :
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_digits = load(UpAtlas.FILE) if ResourceLoader.exists(UpAtlas.FILE) else null
	for enemy: bool in [false, true]:
		var layer: Control = _layer()
		layer.draw.connect(_draw_tank.bind(layer, enemy))
		_tanks.append(layer)
	_top = _layer()
	_top.draw.connect(_draw_top)

func _layer() -> Control:
	var layer: Control = Control.new()
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(layer)
	return layer


static func warm(pack_node: Node, avatars: Array) -> void :
	if pack_node == null:
		return
	for key: String in KEYS:
		pack_node.effect(key, true)
	pack_node.sound("s/%s.mp3" % SOUND, true)
	for avatar: Variant in avatars:
		portrait(pack_node, int(avatar))


static func portrait(pack_node: Node, avatar: int) -> Texture2D:
	if pack_node == null:
		return null
	var key: String = str(pack_node.lobby.get("avatars", {}).get(str(avatar), ""))
	if key.is_empty():
		return null
	var big: Texture2D = pack_node.picture("l/ch/%s.webp" % key)
	return big if big != null else pack_node.picture("l/h/%s.webp" % key)

func done() -> bool:
	return time >= END


func place(at: Vector2, scale_f: float) -> void :
	f = scale_f
	position = at
	size = Vector2(WIDE, HIGH) * f
	if not win and time >= 9.0 + SHIFT and not _lost:
		_lost = true
		Sound.play(LOSE_SOUND)
	for i: int in 2:
		var state: Array = _tank_state(i == 1)
		_tanks[i].visible = bool(state[0])
		_tanks[i].modulate.a = float(state[2])
		_tanks[i].queue_redraw()
	_top.queue_redraw()
	queue_redraw()



static func bounce(p: float) -> float:
	if p < 1.0 / 2.75:
		return 7.5625 * p * p
	if p < 2.0 / 2.75:
		p -= 1.5 / 2.75
		return 7.5625 * p * p + 0.75
	if p < 2.5 / 2.75:
		p -= 2.25 / 2.75
		return 7.5625 * p * p + 0.9375
	p -= 2.625 / 2.75
	return 7.5625 * p * p + 0.984375

static func quad(p: float) -> float:
	return - p * (p - 2.0)

static func quint(p: float) -> float:
	p -= 1.0
	return p * p * p * p * p + 1.0

static func span(t: float, from: float, length: float) -> float:
	return clampf((t - from) / length, 0.0, 1.0)

static func path_at(ratio: float) -> Vector2:
	var spot: float = clampf(ratio, 0.0, 1.0) * float(PATH.size() - 1)
	var i: int = mini(int(spot), PATH.size() - 2)
	return PATH[i].lerp(PATH[i + 1], spot - float(i))


func _avatar_state(enemy: bool) -> Array:
	if time < 1.0:
		return []
	var at: Vector2 = Vector2(500, 180)
	var k: float = 1.0
	if time < 1.5:
		var r: float = bounce(span(time, 1.0, 0.5))
		at = path_at(r)
		k = 0.5 + 0.5 * r
	elif time >= 2.0:
		at.x = lerpf(500.0, 218.0, span(time, 2.0, 0.5))
	if enemy:
		at.x = WIDE - at.x
	return [at, k]


func _tank_state(enemy: bool) -> Array:
	var t: float = time - SHIFT
	if t < 2.5:
		return [false, 0.0, 0.0]
	var home: float = 770.0 if enemy else 230.0
	var alpha: float = quad(span(t, 2.5, 1.0))
	var x: float = home
	if t >= 3.5:
		x = lerpf(home, 500.0, bounce(span(t, 3.5, 0.5)))
	if t >= 7.0:
		if win:
			if enemy:
				return [false, 0.0, 0.0]
			x = lerpf(500.0, home, quad(span(t, 7.0, 0.5)))
		elif t >= 7.5:
			var q: float = quint(span(t, 7.5, 0.5))
			x = lerpf(500.0, home, q)
			if not enemy:
				alpha = 1.0 - q
	return [true, x, alpha]

func _fire_alpha() -> float:
	if time < 1.5:
		return 0.0
	if time < 7.0 + SHIFT:
		return quad(span(time, 1.5, 2.0))
	return 1.0 - quad(span(time, 7.0 + SHIFT, 2.0))


func _films() -> Array:
	var out: Array = []
	var t: float = time - SHIFT
	if t >= 4.0 and t < 7.0:
		out.append(["kcm/bown", Vector2(500, 400), int((t - 4.0) * FPS) % 58])
	for row: Array in [["kcm/appear", Vector2(130, 460), 2.5, 18], ["kcm/crash", Vector2(225, 360), 4.0, 5], 
			["kcm/cry" if win else "kcm/snooty", Vector2(782, 180) if win else Vector2(200, 250), 7.0 if win else 9.0, 40 if win else 38], 
			["kcm/appear", Vector2(870, 460), 2.5, 18]]:
		var frame: int = int((t - float(row[2])) * FPS)
		if t >= float(row[2]) and frame < int(row[3]):
			out.append([row[0], row[1], frame])
	return out


func _wipe() -> float:
	var p: float = span(time, 9.0 + SHIFT, 1.0)
	return 0.5 * (sin(PI * (p - 0.5)) + 1.0)



func _draw() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.9 * span(time, 0.0, 1.0)))
	_draw_avatar(false, -1.0, not win and time >= 9.0 + SHIFT)
	_draw_avatar(true, -1.0, false)



func _draw_avatar(enemy: bool, from: float, grey: bool, canvas: CanvasItem = self) -> void :
	var state: Array = _avatar_state(enemy)
	if state.is_empty():
		return
	var picture: Texture2D = portrait(pack, int((theirs if enemy else mine).get("avatar", 0)))
	if picture == null or picture.get_width() <= 4:
		return
	if grey:
		picture = _grey(picture)
	var k: float = minf(AVATAR.x / picture.get_width(), AVATAR.y / picture.get_height())
	var extent: Vector2 = Vector2(picture.get_size()) * k
	var at: Vector2 = state[0]
	var scale_k: float = float(state[1])
	canvas.draw_set_transform(at * f, 0.0, Vector2(scale_k if enemy else - scale_k, scale_k) * f)
	if from < 0.0:
		canvas.draw_texture_rect(picture, Rect2(Vector2.ZERO, extent), false)
	elif from < extent.y:
		canvas.draw_texture_rect_region(picture, Rect2(Vector2(0, from), Vector2(extent.x, extent.y - from)), 
			Rect2(Vector2(0, from / k), Vector2(picture.get_width(), (extent.y - from) / k)))
	canvas.draw_set_transform(Vector2.ZERO)

func _grey(texture: Texture2D) -> Texture2D:
	var key: int = texture.get_instance_id()
	if _greys.has(key):
		return _greys[key]
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		_greys[key] = texture
		return texture
	image = image.duplicate()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var data: PackedByteArray = image.get_data()
	for i: int in range(0, data.size(), 4):
		var v: int = clampi(roundi(0.3086 * data[i] + 0.6094 * data[i + 1] + 0.082 * data[i + 2]), 0, 255)
		data[i] = v
		data[i + 1] = v
		data[i + 2] = v
	var out: ImageTexture = ImageTexture.create_from_image(Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data))
	_greys[key] = out
	return out


func _draw_tank(layer: Control, enemy: bool) -> void :
	var card: Dictionary = theirs if enemy else mine
	var tank_id: int = int(card.get("tank_id", 0))
	if tank_id <= 0 or pack == null or pack.state != "ready" or pack.garage.is_empty():
		return
	var level: int = maxi(1, int(card.get("tank_level", 1)))
	var ext: int = int(card.get("external", 0))
	if ext <= 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, level, {})
	var x: float = float(_tank_state(enemy)[1])
	var centre: Vector2 = Vector2(x + (TANK / 2.0 if enemy else - TANK / 2.0), 360.0 + TANK / 2.0) * f
	if not enemy:
		layer.draw_set_transform_matrix(Transform2D(Vector2(-1, 0), Vector2(0, 1), Vector2(2.0 * centre.x, 0)))
	TankPortrait.draw(layer, pack, GarageModel.face(pack.garage, ext), 0, centre, f, time)
	layer.draw_set_transform_matrix(Transform2D.IDENTITY)

func _draw_top() -> void :
	for film: Array in _films():
		_film(str(film[0]), Vector2(film[1]), int(film[2]), 1.0)
	var fire: float = _fire_alpha()
	if fire > 0.0:
		for x: int in FIRES:
			_film("kcm/fire", Vector2(float(x), HIGH), int(time * FPS) % 15, fire)
	_draw_helper(false)
	_draw_helper(true)
	_draw_skip()
	if not win and time >= 9.0 + SHIFT:
		_draw_avatar(false, AVATAR.y * _wipe(), false, _top)
	if time >= 2.5:
		for i: int in 2:
			_draw_score(SCORES[i], _score_now(theirs if i == 1 else mine))


func _score_now(card: Dictionary) -> int:
	var total: float = float(int(card.get("atk", 0)))
	var k: float = float(TANK_K[clampi(int(card.get("tank_level", 1)), 1, 11)])
	var helper: float = floorf(total / k)
	if time < 2.5 + SHIFT:
		return int(helper * span(time, 2.5, 1.0))
	return int(lerpf(helper, total, span(time, 2.5 + SHIFT, 1.0)))


func _helper_picture(item: int) -> Texture2D:
	if pack == null or item <= 0:
		return null
	var more: Array = pack.bag.get("more", {}).get(str(item), [])
	if more.size() >= 4 and not str(more[1]).is_empty():
		return pack.picture("l/it/%s.webp" % str(more[1]))
	var row: Array = pack.bag.get("items", {}).get(str(item), [])
	if row.size() >= 10:
		return pack.picture(("l/av/" if int(row[5]) == 4 else "l/it/") + str(row[2]) + ".webp")
	return null


func _helper_state(enemy: bool) -> Array:
	if time < 3.0:
		return []
	var side: float = 1.0 if enemy else -1.0
	var home: Vector2 = Vector2(500.0 + side * 170.0, 270.0)
	var top: Vector2 = Vector2(500.0 + side * 60.0, 70.0)
	var alpha: float = quad(span(time, 3.0, 0.3))
	var k: float = 0.5 + 0.5 * bounce(span(time, 3.0, 0.3))
	var at: Vector2 = home
	if time >= 3.5:
		at = home.lerp(top, quad(span(time, 3.5, 0.5)))
	if time >= 4.0:

		var p: float = fmod(time - 4.0, 1.0)
		var gap: float = 30.0 + 110.0 * sin(PI * p)
		var bob: float = 22.0 * sin(TAU * (time - 4.0) / 1.7 + (PI if enemy else 0.0))
		at = Vector2(500.0 + side * gap, 75.0 + bob)
	var lost: bool = win == enemy
	if time >= 9.0:
		if lost:
			alpha *= 1.0 - span(time, 9.0, 0.5)
			if alpha <= 0.0:
				return []
		else:
			var back: Vector2 = home.lerp(at, 1.0 - quad(span(time, 9.0, 0.5)))
			at = back
			if time >= 10.0:
				var loser: Vector2 = Vector2(500.0 - side * 170.0, 280.0)
				at = home.lerp(loser, quad(span(time, 10.0, 0.6)))
				at.y += 6.0 * sin(TAU * (time - 10.6) / 1.2)
	return [at, alpha, k]

func _draw_helper(enemy: bool) -> void :
	var state: Array = _helper_state(enemy)
	if state.is_empty():
		return
	var picture: Texture2D = _helper_picture(int((theirs if enemy else mine).get("item", 0)))
	if picture == null or picture.get_width() <= 4:
		return
	var box: float = HELPER * float(state[2])
	var k: float = minf(box / picture.get_width(), box / picture.get_height())
	var extent: Vector2 = Vector2(picture.get_size()) * k
	var centre: Vector2 = state[0]

	_top.draw_set_transform(centre * f, 0.0, Vector2(1.0 if enemy else -1.0, 1.0) * f)
	_top.draw_texture_rect(picture, Rect2( - extent / 2.0, extent), false, Color(1, 1, 1, float(state[1])))
	_top.draw_set_transform(Vector2.ZERO)

	if not enemy and time >= 4.0 and time < 9.0 and fmod(time - 4.0, 1.0) < 5.0 / FPS:
		_film("kcm/crash", Vector2(500.0, 75.0), int(fmod(time - 4.0, 1.0) * FPS), 0.8)


func _film(key: String, at: Vector2, index: int, alpha: float) -> void :
	if pack == null:
		return
	var fx: Dictionary = pack.effect_cached(key)
	if fx.is_empty():
		pack.effect(key)
		return
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
	_top.draw_texture_rect_region(pages[page], Rect2((at - Vector2(float(pivot[0]), float(pivot[1]))) * f, src.size * f), src, 
		Color(1, 1, 1, alpha))


func _draw_skip() -> void :
	var font_size: int = maxi(6, roundi(14.0 * f))
	var wide: float = FONT.get_string_size(SKIP, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var high: float = 14.0 * 1.15 + 4.0
	var spot: Vector2 = Vector2(WIDE * f - 3.0 * f - wide, (HIGH - high / 2.0) * f + (FONT.get_ascent(font_size) - FONT.get_descent(font_size)) / 2.0)
	_top.draw_string_outline(FONT, spot, SKIP, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(1.5 * f)), SKIP_RIM)
	_top.draw_string(FONT, spot, SKIP, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, SKIP_INK)


func _draw_score(at: Vector2, value: int) -> void :
	if _digits == null:
		return
	var text: String = str(maxi(0, value))

	var step: float = DIGIT
	var zoom: float = 1.0
	if float(text.length()) * DIGIT > SCORE_BOX.x:
		step = SCORE_BOX.x / float(text.length())
		zoom = step / DIGIT
	for i: int in text.length():
		var cell: Array = UpAtlas.R.get("gda_up_n" + text[i], [])
		if cell.size() < 4:
			continue
		var lift: float = float(cell[3]) * (1.0 - zoom) / 2.0
		_top.draw_texture_rect_region(_digits, Rect2((at + Vector2(step * i, lift)) * f, Vector2(float(cell[2]), float(cell[3])) * zoom * f), 
			Rect2(float(cell[0]), float(cell[1]), float(cell[2]), float(cell[3])))
