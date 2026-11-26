extends "flash_screen.gd"








const Atlas = preload("exitask_atlas.gd")
const ExitAsk = preload("exit_ask.gd")

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const LINE: float = 18.0
const GUTTER: float = 2.0
const TITLE: String = "Thoát game?"

signal answered(ok: bool)

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func chat_busy() -> bool:
	return visible

func open() -> void :
	_hover = ""
	_press = ""
	_held = false
	visible = true
	queue_redraw()

func close() -> void :
	if not visible:
		return
	visible = false
	answered.emit(false)


func _live() -> bool:
	if client == null or str(client.state) != "battle":
		return false
	var battle = client.battle
	return battle != null and battle.active and not battle.ended and not battle.look


func rows() -> Array:
	var out: Array = [TITLE]
	if _live():
		out.append_array(_wrap(ExitAsk.words(int(client.battle.room_type))))
	return out


func _wrap(text: String) -> Array:
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
	var lines: Array = rows()
	for i in range(lines.size()):
		_fwords(str(lines[i]), ARIAL_BOLD, float(body[4]), Color(str(body[5])), "l", 
			at + Vector2(float(body[0]) + GUTTER, float(body[1]) + LINE * i), float(body[2]) - GUTTER * 2.0, 0.0, 0.0, false)
	_fbutton("ok", "xa_ok", at + _xy(Atlas.NODES["btnConfirm"]))
	_fbutton("no", "xa_no", at + _xy(Atlas.NODES["btnCancel"]))
	_fblit("xa_guy", at + _xy(Atlas.GUY))



func _activate(id: String) -> void :
	if id == "ok":
		visible = false
		answered.emit(true)
	elif id == "no":
		close()



func _input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree():
		return
	if event is InputEventKey:
		var key: InputEventKey = event as InputEventKey
		if key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
			close()
		if key.pressed:
			get_viewport().set_input_as_handled()
		return
	if event is InputEventMouse:
		_gui_input(make_input_local(event))
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch or event is InputEventScreenDrag or event is InputEventGesture:
		get_viewport().set_input_as_handled()
