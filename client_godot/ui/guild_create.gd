extends "flash_screen.gd"










const Arena = preload("arena_atlas.gd")
const Join = preload("guild_join_atlas.gd")
const BagModel = preload("bag_model.gd")

signal closed(note: String)
signal quick_buy_asked(tid: int)

const FRAME: Vector2 = Vector2(398, 326)
const MAX_NAME_BYTE: int = 12
const CARD: int = 2600007

const TITLE: String = "TẠO GUILD"
const PROMPT_GUILD: String = "Nhập tên Guild"
const PROMPT_TEAM: String = "Nhập tên Team"

const TIP: String = "Tạo Guild cần 1 Thẻ Tạo Guild"
const TIP_COLOR: Color = Color8(0, 87, 151)
const NO_GUILD_NAME: String = "Nhập tên Guild"
const NO_TEAM_NAME: String = "Nhập tên Team"
const TEAM_TOO_LONG: String = "Tên quá dài"
const GUILD_TOO_LONG: String = "Tên quá dài"
const NO_CARD: String = "Đạo cụ tạo Guild không đủ"
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."

var _guild_name: LineEdit
var _team_name: LineEdit
var _buy: bool = false
var _focus_due: bool = false

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Arena.FILE, {"public_button_close": Arena.R["public_button_close"]})
	_use(Join.FILE, {"gj_create": Join.R["gj_create"], "gj_buy": Join.R["gj_buy"], "gj_ok": Join.R["gj_ok"]})
	_guild_name = _fedit(0)
	_team_name = _fedit(0)

func open() -> void :
	_toast = ""
	_hover = ""
	_press = ""
	_guild_name.text = ""
	_team_name.text = ""
	_buy = _cards() == 0
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

func buy_shown() -> bool:
	return _buy

func _cards() -> int:
	return BagModel.item_count(client.bags, CARD) if client != null else 0



func _activate(id: String) -> void :
	match id:
		"cancel":
			close("")
		"buy":
			if _buy:
				quick_buy_asked.emit(CARD)
		"confirm":
			_confirm()


func _confirm() -> void :
	var guild_name: String = _guild_name.text
	var team_name: String = _team_name.text
	if guild_name == "":
		say(NO_GUILD_NAME)
		return
	if team_name == "":
		say(NO_TEAM_NAME)
		return
	if _cards() < 1:
		quick_buy_asked.emit(CARD)
		say(NO_CARD)
		return
	if team_name.to_utf8_buffer().size() > MAX_NAME_BYTE:
		say(TEAM_TOO_LONG)
		return
	if guild_name.to_utf8_buffer().size() > MAX_NAME_BYTE:
		say(GUILD_TOO_LONG)
		return
	close("" if client.guild_create(guild_name, team_name) else OFFLINE)

func _input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()



func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(FRAME.x, FRAME.y)
	_hit("panel", Rect2(at * _f, FRAME * _f), false)
	_fblit("gj_create", at)
	_fwords(TITLE, ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2(108, 18), 182.0, 1.5, 28.0)
	_fwords(PROMPT_GUILD, ARIAL_BOLD, 14.0, Color.WHITE, "c", at + Vector2(0, 71), FRAME.x, 1.0, 21.0)
	_fwords(PROMPT_TEAM, ARIAL_BOLD, 14.0, Color.WHITE, "c", at + Vector2(0, 148), FRAME.x, 1.0, 21.0)
	_fput(_guild_name, Rect2(at + Vector2(94, 93) + Vector2(15, 3), Vector2(190, 29)), 16)
	_fput(_team_name, Rect2(at + Vector2(94, 170) + Vector2(15, 3), Vector2(190, 29)), 16)
	_fpara(TIP, ARIAL_BOLD, 14.0, TIP_COLOR, at + Vector2(60, 216), 250.0)
	if _buy:
		_fbutton("buy", "gj_buy", at + Vector2(314, 211))
	_fbutton("confirm", "gj_ok", at + Vector2(139, 274))
	_fbutton("cancel", "public_button_close", at + Vector2(359, 15))
	if _focus_due:
		_focus_due = false
		_guild_name.grab_focus.call_deferred()
