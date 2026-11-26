extends "flash_screen.gd"








const Pick = preload("private_chat_select_atlas.gd")

signal picked(name: String)

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const TIP_SELF: String = "Không thể chat với bản thân"
const TITLE: String = "CHAT RIÊNG"
const PROMPT: String = "Nhập tên người muốn chat riêng"
const TITLE_INK: Color = Color("fff7c2")
const TITLE_RIM: Color = Color("0b3f73")

var _name: LineEdit
var _focus_due: bool = false

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Pick.FILE, Pick.R)
	_name = _name_fedit()
	_name.text_submitted.connect( func(_text: String) -> void : _confirm())


func open() -> void :
	if visible:
		return
	_toast = ""
	_hover = ""
	_press = ""
	_name.text = ""
	_focus_due = true
	visible = true
	queue_redraw()

func close() -> void :
	visible = false
	_hide_edits()

func _confirm() -> void :
	var who: String = _name.text
	if who == "":
		close()
		return
	if client != null and who == str(client.character.get("name", "")):
		say(TIP_SELF)
		return
	close()
	picked.emit(who)

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = Vector2(floorf((_fw - float(Pick.SIZE[0])) / 2.0), floorf((_fh - float(Pick.SIZE[1])) / 2.0))
	var frame: Vector2 = at + _xy(Pick.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("ps_frame") * _f), false)
	_fblit("ps_frame", frame)
	_fwords(TITLE, ARIAL_BOLD, 20.0, TITLE_INK, "c", at + Vector2(0, 17), float(Pick.SIZE[0]), 2.0, 28.0, true, TITLE_RIM)
	_fwords(PROMPT, ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2(0, 86), float(Pick.SIZE[0]), 1.0, 24.0)
	var box: Array = Pick.NODES["txtCharName"]
	_fput(_name, Rect2(at + _xy(box) + Vector2(15, 3), Vector2(float(box[2]) - 20.0, float(box[3]) - 6.0)), 16)
	_fbutton("confirm", "ps_confirm", at + _xy(Pick.NODES["btnConfirm"]))
	_fbutton("close", "ps_close", at + _xy(Pick.NODES["btnClose"]))
	if _focus_due:
		_focus_due = false
		_name.grab_focus.call_deferred()

func _activate(id: String) -> void :
	match id:
		"confirm":
			_confirm()
		"close":
			close()

func _input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()
