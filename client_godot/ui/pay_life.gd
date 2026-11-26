extends "flash_screen.gd"









const Atlas = preload("paylife_atlas.gd")

const DIM: float = 76.0 / 255.0
const TEXT_300: String = "Tốn %d %s để hồi sinh ngay?"
const COIN_NAMES: Dictionary = {1: "Xu", 2: "Bạc"}
const LINE: float = 20.0
const GUTTER: float = 2.0

signal closed

var coin_type: int = 0
var coin_num: int = 0
var text: String = ""

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	if client != null:
		client.changed.connect(_follow)

func _follow() -> void :
	if visible and not _live():
		close()


func _live() -> bool:
	return client != null and client.state == "battle" and client.battle.active and not client.battle.ended and client.battle.respawn > 0


func ask(kind: int, num: int) -> void :
	if not _live():
		return
	coin_type = kind
	coin_num = num
	text = TEXT_300 % [num, str(COIN_NAMES.get(kind, ""))]
	_hover = ""
	_press = ""
	visible = true
	queue_redraw()

func close() -> void :
	if not visible:
		return
	visible = false
	closed.emit()


func no_tip() -> bool:
	return client != null and not client.ask_buy_life()


func lines() -> Array:
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(16.0 * _f))
	var limit: float = (float(Atlas.NODES["cost"][2]) - GUTTER * 2.0) * _f
	var out: Array = []
	var line: String = ""
	for word: String in text.split(" "):
		var next: String = word if line.is_empty() else line + " " + word
		if not line.is_empty() and font.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > limit:
			out.append(line)
			line = word
		else:
			line = next
	out.append(line)
	return out

func _xy(node: String) -> Vector2:
	return Vector2(float(Atlas.NODES[node][0]), float(Atlas.NODES[node][1]))

func _tick(_delta: float) -> void :
	if visible and not _live():
		close()

func _paint() -> void :
	if _cells.is_empty():
		var cells: Dictionary = {}
		for key: String in Atlas.R:
			cells[key.trim_prefix("plf_") if key.begins_with("plf_public_") else key] = Atlas.R[key]
		_use(Atlas.FILE, cells)
	var at: Vector2 = _window(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]), "cancel", DIM)
	_fblit("plf_title", at + _xy("title"))

	var rows: Array = lines()
	var high: float = LINE * rows.size() + GUTTER * 2.0
	var top: float = floorf((float(Atlas.SIZE[1]) - high) / 2.0) - 22.0
	var cost: Array = Atlas.NODES["cost"]
	for i in range(rows.size()):
		_fwords(str(rows[i]), ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2(float(cost[0]) + GUTTER, top + GUTTER + LINE * i), 
			float(cost[2]) - GUTTER * 2.0, 0.0, LINE, false)
	var check: Rect2 = _fblit("plf_cb_on" if no_tip() else "plf_cb_off", at + _xy("check"))
	_hit("check", check, false)
	var tip: Rect2 = _fblit("plf_tip", at + _xy("tip"))
	_hit("tip", tip, false)
	_fbutton("ok", "plf_ok", at + _xy("ok"))



func _activate(id: String) -> void :
	match id:
		"ok":
			var kind: int = coin_type
			close()
			if client != null:
				client.request_buy_life(kind)
		"cancel":
			close()
		"check":
			client.set_ask_buy_life(no_tip())
			queue_redraw()
		"tip":
			client.set_ask_buy_life( not no_tip())
			queue_redraw()

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
