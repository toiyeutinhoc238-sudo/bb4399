extends "flash_screen.gd"







const Atlas = preload("quickmatch_atlas.gd")
const VoiceClient = preload("voice_client.gd")
const VOICE_AT: Vector2 = Vector2(216.0, 369.0)
const SHOW_IN: Array = ["lobby", "hall", "room"]
const DIM: Color = Color(0, 0, 0, 0.5)
const BOX: Vector2 = Vector2(467, 345)
const COUNT: String = "@num1@/@num2@ đã sắp xếp"
const CLOCK_HEAD: String = "Đếm ngược "
const CLOCK_TAIL: String = " giây"
const CLOCK_NUMBER: Color = Color("ffea00")
const CELL: float = 80.0

var _opened_at: int = -1
var _self_slot: int = 0
var _faces: Array = []
var voice_drawn: Dictionary = {}

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	if client != null:
		client.changed.connect(_follow)

func _follow() -> void :
	var want: bool = client != null and client.quick_pair and not client.pair_confirm.is_empty() and client.state in SHOW_IN
	if want and int(client.pair_confirm.get("at", 0)) != _opened_at:
		_deal()
	if want == visible:
		return
	visible = want
	if not want:
		_voice_release()
	if want:
		_hover = ""
		_press = ""
		if is_inside_tree():
			get_viewport().gui_release_focus()


func _deal() -> void :
	var confirm: Dictionary = client.pair_confirm
	_opened_at = int(confirm.get("at", 0))
	var total: int = maxi(1, int(confirm.get("total", 1)))
	_self_slot = randi() % total
	_faces = []
	var keys: Array = pack.lobby.get("avatars", {}).values() if pack != null else []
	var mine: String = str(pack.lobby.get("avatars", {}).get(str(int(client.character.get("avatarId", 0))), "")) if pack != null else ""
	for i in range(total):
		if i == _self_slot:
			_faces.append(mine)
		else:
			_faces.append(str(keys[randi() % keys.size()]) if not keys.is_empty() else "")
	Sound.play("u/begin")

func seconds_left() -> int:
	var confirm: Dictionary = client.pair_confirm if client != null else {}
	if confirm.is_empty():
		return 0
	return maxi(0, int(confirm.get("seconds", 0)) - floori((Time.get_ticks_msec() - int(confirm.get("at", 0))) / 1000.0))


func _confirmed_slot(slot: int) -> bool:
	var confirm: Dictionary = client.pair_confirm
	var count: int = int(confirm.get("confirmed", 0))
	var mine: bool = bool(confirm.get("mine", false))
	if slot == _self_slot:
		return mine

	var others: int = maxi(0, count - (1 if mine else 0))
	var order: int = slot if slot < _self_slot else slot - 1
	return order < others

func _tick(_delta: float) -> void :
	if client != null and not client.pair_confirm.is_empty():
		client.pair_flush()

func _paint() -> void :
	if client == null or client.pair_confirm.is_empty():
		return
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(BOX.x, BOX.y)
	_hit("panel", _fblit("gda_pc_bg_t", o), false)
	var confirm: Dictionary = client.pair_confirm
	var total: int = maxi(1, int(confirm.get("total", 1)))
	var count: int = clampi(int(confirm.get("confirmed", 0)), 0, total)
	_fwords(COUNT.replace("@num1@", str(count)).replace("@num2@", str(total)), ARIAL_BOLD, 16.0, Color.WHITE, "c", o + Vector2(20, 60), 200.0, 1.0)
	_clock(o + Vector2(247, 60), seconds_left())
	var cols: int = ceili(total / 2.0)
	var grid: Vector2 = o + Vector2(roundf((BOX.x - CELL * cols) / 2.0), roundf((BOX.y - CELL * 2.0) / 2.0) + 7.0)
	for slot in range(total):
		_head(grid + Vector2(CELL * (slot % cols), CELL * floorf(slot / float(cols))), slot)
	if bool(confirm.get("mine", false)):
		_fmid("gda_pc_ok_off_t", o + Vector2(0, roundf((BOX.y - 41.0) / 2.0) + 126.0), BOX.x)
	else:
		_hit("match:confirm", _fmid("gda_pc_ok_t", o + Vector2(0, roundf((BOX.y - 41.0) / 2.0) + 126.0), BOX.x, _glow("match:confirm")), false)
	var voice: Object = _voice()
	voice_drawn = voice.dock_draw(self, "room", o + VOICE_AT) if voice != null else {}


func _voice() -> Object:
	if client == null or not VoiceClient.usable():
		return null
	var voice: Object = VoiceClient.shared()
	voice.attach(client)
	return voice

func _voice_release() -> void :
	var voice: Object = _voice()
	if voice != null:
		voice.dock_release()


func _clock(at: Vector2, left: int) -> void :
	var px: int = maxi(6, roundi(16.0 * _f))
	var font: Font = ARIAL_BOLD
	var head_w: float = font.get_string_size(CLOCK_HEAD, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
	var number: String = str(left)
	var num_w: float = font.get_string_size(number, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
	var tail_w: float = font.get_string_size(CLOCK_TAIL, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
	var x: float = at.x + (200.0 - head_w - num_w - tail_w) / 2.0
	_fwords(CLOCK_HEAD, ARIAL_BOLD, 16.0, Color.WHITE, "l", Vector2(x, at.y), head_w + 4.0, 1.0, 0.0, false)
	_fwords(number, ARIAL_BOLD, 16.0, CLOCK_NUMBER, "l", Vector2(x + head_w, at.y), num_w + 4.0, 1.0, 0.0, false)
	_fwords(CLOCK_TAIL, ARIAL_BOLD, 16.0, Color.WHITE, "l", Vector2(x + head_w + num_w, at.y), tail_w + 4.0, 1.0, 0.0, false)


func _head(at: Vector2, slot: int) -> void :
	_fblit("gda_pc_head_bg", at + Vector2(9, 9))
	var key: String = str(_faces[slot]) if slot < _faces.size() else ""
	var face: Texture2D = pack.picture("l/h/%s.webp" % key) if pack != null and not key.is_empty() else null
	if face != null:
		draw_texture_rect(face, Rect2((at + Vector2(10, 10)) * _f, Vector2(60, 60) * _f), false)
	if _confirmed_slot(slot):
		_fblit("gda_pc_head_ok", at + Vector2(3, 3))
	else:
		_fblit("gda_pc_head_mask", at + Vector2(10, 10))

func _activate(id: String) -> void :
	if id.begins_with("voice:"):
		var voice: Object = _voice()
		if voice != null:
			voice.dock_click(id)
		return
	if id == "match:confirm":
		client.confirm_pair()


func _gui_input(event: InputEvent) -> void :
	var voice: Object = _voice() if visible else null
	if voice != null:
		voice.dock_touch(self, "room", event)
	super (event)


func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
