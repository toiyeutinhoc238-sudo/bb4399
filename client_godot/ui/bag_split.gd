extends "flash_screen.gd"










const SplitAtlas = preload("bag_split_atlas.gd")
const Arena = preload("arena_atlas.gd")
const BagModel = preload("bag_model.gd")

signal closed(note: String)

const FRAME: Vector2 = Vector2(358, 258)
const NUM_LIMIT: int = 6
const CELLS: Array = ["public_bk", "public_bk_b2", "public_bk_bc", "public_bk_bc_r", "public_bk_c", "public_bk_l", "public_bk_lt", 
	"public_bk_oc", "public_bk_ol", "public_bk_or", "public_bk_pattern", "public_bk_r", "public_bk_rt", "public_bk_ti", 
	"public_button_close", "public_window_button_bk", "public_input_bk_m", "public_button_window_green", "title_title_confirm_green_t"]

const TIP_FULL: String = "Kho đầy, không thể tách"
const TIP_EMPTY: String = "Nhập số lượng muốn tách"
const TIP_ZERO: String = "Số lượng tách phải lớn hơn 0"
const TITLE: String = "TÁCH"
const PROMPT: String = "Nhập số lượng muốn tách"
const TITLE_INK: Color = Color("fff7c2")
const TITLE_RIM: Color = Color("0b3f73")
const OFFLINE: String = "Chưa thực hiện được lúc này."

var _cont: int = 2
var _slot: int = -1
var _max: int = 0
var _total: int = 0
var _num: LineEdit
var _focus_due: bool = false

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var cells: Dictionary = {}
	for key: String in CELLS:
		cells[key] = Arena.R[key]
	_use(Arena.FILE, cells)
	_use(SplitAtlas.FILE, SplitAtlas.R)
	_num = _fedit(NUM_LIMIT, true)
	_num.text_changed.connect(_on_text)


func open(cont: int, slot: int, count: int, total: int) -> void :
	_cont = cont
	_slot = slot
	_max = count - 1
	_total = total
	_toast = ""
	_hover = ""
	_press = ""
	_num.text = ""
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

func slot() -> int:
	return _slot

func most() -> int:
	return _max


func _on_text(text: String) -> void :
	var amount: int = int(text)
	var fixed: String = "1" if amount <= 0 else (str(_max) if amount > _max else str(amount))
	if fixed != text:
		_num.text = fixed
		_num.caret_column = fixed.length()



func _activate(id: String) -> void :
	match id:
		"cancel":
			close("")
		"confirm":
			_confirm()


func _confirm() -> void :
	if _num.text == "":
		say(TIP_EMPTY)
		return
	var amount: int = int(_num.text)
	if amount <= 0:
		say(TIP_ZERO)
		return
	var dest: int = BagModel.first_empty(client.bags, _cont, _total)
	if dest == -1:
		say(TIP_FULL)
		return
	close("" if client.swap_item(_cont, _slot, dest, amount) else OFFLINE)

func _input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()



func _paint() -> void :
	var at: Vector2 = _window(FRAME.x, FRAME.y)
	if SplitAtlas.TITLE_OK:
		_fmid("bsp_title", at + Vector2(0, 20), FRAME.x)
	else:
		_fwords(TITLE, BOLD, 20.0, TITLE_INK, "c", at + Vector2(0, 17), FRAME.x, 2.0, 28.0, true, TITLE_RIM)
	if SplitAtlas.PROMPT_OK:
		_fmid("bsp_prompt", at + Vector2(0, 86), FRAME.x)
	else:
		_fwords(PROMPT, BOLD, 16.0, Color.WHITE, "c", at + Vector2(0, 86), FRAME.x, 1.0, 24.0)
	var box: Vector2 = at + Vector2(roundf((FRAME.x - 210.0) / 2.0), 121)
	_fblit("public_input_bk_m", box)
	_fput(_num, Rect2(box + Vector2(15, 3), Vector2(190, 29)), 16)
	var ok: Vector2 = at + Vector2(119, FRAME.y - 17.0 - 35.0)
	_fbutton("confirm", "public_button_window_green", ok)
	_fblit("title_title_confirm_green_t", ok + Vector2(40, 7), 0.0, 0.0, _glow("confirm"))
	if _focus_due:
		_focus_due = false
		_num.grab_focus.call_deferred()
