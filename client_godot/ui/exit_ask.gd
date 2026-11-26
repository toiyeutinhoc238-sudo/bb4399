extends "flash_screen.gd"









const Atlas = preload("exitask_atlas.gd")

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const LINE: float = 18.0
const GUTTER: float = 2.0
const TEXT_280: String = "Thoát ra khi chưa kết thúc thi đấu xem như bỏ chạy, bỏ chạy nhiều sẽ bị trừng phạt tạm cấm thi đấu, xác nhận thoát?"
const TEXT_256: String = "Xác nhận thoát phụ bản này?"
const TEXT_226: String = "Chiến đấu chưa kết thúc mà rời đi coi như bỏ chạy, đồng ý không?"
const PVP_ROOMS: Array = [2, 5]
const PVE_ROOMS: Array = [4, 3, 51, 8, 53, 52]

signal closed

var text: String = ""


static func words(room_type: int) -> String:
	if room_type in PVP_ROOMS:
		return TEXT_280
	if room_type in PVE_ROOMS:
		return TEXT_256
	return TEXT_226

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
	return client != null and client.state == "battle" and client.battle.active and not client.battle.ended


func ask() -> void :
	if visible or not _live():
		return
	text = words(int(client.battle.room_type))
	_hover = ""
	_press = ""
	visible = true
	queue_redraw()

func close() -> void :
	if not visible:
		return
	visible = false
	text = ""
	closed.emit()


func lines() -> Array:
	var spec: Array = Atlas.TEXTS["txtContent"]
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(float(spec[4]) * _f))
	var limit: float = (float(spec[2]) - GUTTER * 2.0) * _f
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

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _tick(_delta: float) -> void :
	if visible and not _live():
		close()

func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	var frame: Vector2 = at + _xy(Atlas.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("xa_frame") * _f), false)
	_fblit("xa_frame", frame)
	var body: Array = Atlas.TEXTS["txtContent"]
	var rows: Array = lines()
	for i in range(rows.size()):
		_fwords(str(rows[i]), ARIAL_BOLD, float(body[4]), Color(str(body[5])), "l", 
			at + Vector2(float(body[0]) + GUTTER, float(body[1]) + LINE * i), float(body[2]) - GUTTER * 2.0, 0.0, 0.0, false)
	_fbutton("ok", "xa_ok", at + _xy(Atlas.NODES["btnConfirm"]))
	_fbutton("no", "xa_no", at + _xy(Atlas.NODES["btnCancel"]))
	_fblit("xa_guy", at + _xy(Atlas.GUY))



func _activate(id: String) -> void :
	if id == "ok":
		var live: bool = _live()
		close()
		if live:
			client.leave_battle()
	elif id == "no":
		close()

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
