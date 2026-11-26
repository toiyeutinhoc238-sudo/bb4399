extends "flash_screen.gd"









const Arena = preload("arena_atlas.gd")
const Room = preload("room_atlas.gd")

signal closed(note: String)

const FRAME: Vector2 = Vector2(358, 230)
const MAX_NAME_BYTE: int = 12
const NEED_COIN: int = 10000
const CELLS: Array = ["public_bk", "public_bk_b2", "public_bk_bc", "public_bk_bc_r", "public_bk_c", "public_bk_l", "public_bk_lt", 
	"public_bk_oc", "public_bk_ol", "public_bk_or", "public_bk_pattern", "public_bk_r", "public_bk_rt", "public_bk_ti", 
	"public_button_close", "public_window_button_bk", "public_input_bk_m", "public_button_window_green", "title_title_confirm_green_t"]

const TITLE: String = "TẠO TEAM"
const PROMPT: String = "Nhập tên Team"

const TIP: String = "Quỹ Guild còn trên 10000 mới tạo Team mới được. Tạo thành công sẽ chuyển 1000 quỹ Guild làm quỹ khởi đầu cho Team. Người đầu tiên vào Team mặc định là Đội Trưởng."
const TIP_EMPTY: String = "Nhập tên Team"
const TOO_LONG: String = "Tên quá dài"
const NO_COIN: String = "Quỹ Guild không đủ"
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."

var _name: LineEdit
var _focus_due: bool = false

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var cells: Dictionary = {}
	for key: String in CELLS:
		cells[key] = Arena.R[key]
	_use(Arena.FILE, cells)
	_use(Room.FILE, {"public_tip_msg": Room.R["public_tip_msg"]})
	_name = _fedit(0)

func open() -> void :
	_toast = ""
	_hover = ""
	_press = ""
	_name.text = ""
	_focus_due = true
	visible = true

func close(note: String = "") -> void :
	if not visible:
		return
	visible = false
	_focus_due = false
	_hide_edits()
	closed.emit(note)

func chat_busy() -> bool:
	return visible



func _activate(id: String) -> void :
	match id:
		"cancel":
			close("")
		"confirm":
			_confirm()


func _confirm() -> void :
	var text: String = _name.text
	if text == "":
		say(TIP_EMPTY)
		return
	if text.to_utf8_buffer().size() > MAX_NAME_BYTE:
		say(TOO_LONG)
		return
	if int(client.guild.get("iCoin", 0)) < NEED_COIN:
		say(NO_COIN)
		return
	close("" if client.guild_create_team(text) else OFFLINE)

func _input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()




func _tip_high() -> float:
	var px: int = maxi(6, roundi(12.0 * _f))
	return roundf(ARIAL_BOLD.get_multiline_string_size(TIP, HORIZONTAL_ALIGNMENT_LEFT, 276.0 * _f, px).y / _f + 4.0)

func _paint() -> void :
	var high: float = FRAME.y + _tip_high()
	var at: Vector2 = _window(FRAME.x, high)
	_fwords(TITLE, ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2(88, 18), 182.0, 1.5, 28.0)
	_fwords(PROMPT, ARIAL_BOLD, 14.0, Color.WHITE, "c", at + Vector2(0, 61), FRAME.x, 1.0, 21.0)
	var box: Vector2 = at + Vector2(74, 91)
	_fblit("public_input_bk_m", box)
	_fput(_name, Rect2(box + Vector2(15, 3), Vector2(190, 29)), 16)
	_fblit("public_tip_msg", at + Vector2(33, 136))
	_fpara(TIP, ARIAL_BOLD, 12.0, Color.WHITE, at + Vector2(69, 136), 276.0)
	var ok: Vector2 = at + Vector2(119, high - 17.0 - 35.0)
	_fbutton("confirm", "public_button_window_green", ok)
	_fblit("title_title_confirm_green_t", ok + Vector2(40, 7), 0.0, 0.0, _glow("confirm"))
	if _focus_due:
		_focus_due = false
		_name.grab_focus.call_deferred()
