extends "flash_screen.gd"








const PopQueue = preload("pop_queue.gd")
const BagModel = preload("bag_model.gd")
const POP_ID: String = "honor_view"

signal closed

const FILE: String = "res://assets/ui/hall/honor_view.png"
const REGIONS: Dictionary = {"honor_bg": [2, 2, 510, 438], "honor_ok": [2, 442, 142, 29]}
const SIZE: Vector2 = Vector2(520, 450)
const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const BG_AT: Vector2 = Vector2(5, 0)
const ICON_AT: Vector2 = Vector2(210, 131)
const ICON_BOX: Vector2 = Vector2(100, 100)
const TEXT_AT: Vector2 = Vector2(123.5, 247)
const TEXT_WIDE: float = 273.0
const TEXT_COLOR: Color = Color("ffec69")
const OK_AT: Vector2 = Vector2(189, 294)
const CONGRATS: String = "Chúc mừng nhận được %s."
const FALLBACK: String = "Huân Chương"
const SHOW_IN: Array = ["lobby", "hall", "room"]

var queue: PopQueue
var honor_id: int = 0
var rest: Array = []

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	if queue == null:
		queue = PopQueue.new()
		queue.client = client
		add_child(queue)
	queue.register(POP_ID, _open)
	if client != null:
		client.honor_added.connect(notice)
		client.changed.connect(_pump)


func notice(ids: Array) -> void :
	if not ids.is_empty():
		queue.append(POP_ID, ids.duplicate())


func _open(ids: Variant) -> bool:
	rest = (ids as Array).duplicate() if ids is Array else []
	if rest.is_empty():
		return false
	if pack != null:
		pack.load_bag()
	honor_id = int(rest.pop_front())
	_pump()
	return true

func _pump() -> void :
	if client == null:
		return
	if client.state not in SHOW_IN and client.state != "battle":
		honor_id = 0
		rest.clear()
	var want: bool = honor_id > 0 and client.state in SHOW_IN
	if visible != want:
		visible = want


func advance() -> void :
	if honor_id <= 0:
		return
	if not rest.is_empty():
		honor_id = int(rest.pop_front())
		return
	close()

func close() -> void :
	if honor_id <= 0:
		return
	honor_id = 0
	rest.clear()
	visible = false
	closed.emit()
	queue.closed()

func _row() -> Array:
	if pack == null:
		return []
	var row: Variant = pack.bag.get("honors", {}).get(str(honor_id), [])
	return row if row is Array else []


func text() -> String:
	var row: Array = _row()
	var name_text: String = BagModel.clean(str(row[0])) if not row.is_empty() else ""
	return CONGRATS % (name_text if not name_text.is_empty() else FALLBACK)

func _paint() -> void :
	if _cells.is_empty():
		_use(FILE, REGIONS)
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(SIZE.x, SIZE.y)
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_fblit("honor_bg", base + BG_AT)
	var row: Array = _row()
	if row.size() > 2 and not str(row[2]).is_empty():
		_icon(pack.picture("l/hn/%s.webp" % str(row[2])), base + ICON_AT)
	_fwords(text(), ARIAL_BOLD, 14.0, TEXT_COLOR, "c", base + TEXT_AT, TEXT_WIDE, 0.0, 20.0)
	_fbutton("ok", "honor_ok", (base + OK_AT).floor())

func _icon(picture: Texture2D, at: Vector2) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(ICON_BOX.x / picture.get_width(), ICON_BOX.y / picture.get_height())
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (ICON_BOX - extent) / 2.0) * _f, extent * _f), false)

func _activate(id: String) -> void :
	if id == "ok":
		advance()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		advance()
		get_viewport().set_input_as_handled()
