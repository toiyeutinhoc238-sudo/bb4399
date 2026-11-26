extends "flash_screen.gd"











const RenameAtlas = preload("bag_rename_atlas.gd")
const Arena = preload("arena_atlas.gd")
const BagModel = preload("bag_model.gd")

signal closed(note: String)
signal quick_buy_asked(tid: int)


const CORPS_RENAME: int = 1
const TEAM_RENAME: int = 2
const PLAYER_RENAME: int = 3
const SELF_TEAM_RENAME: int = 4

const CARD: Dictionary = {CORPS_RENAME: 2600006, TEAM_RENAME: 2600003, PLAYER_RENAME: 2600002, SELF_TEAM_RENAME: 2600003}
const FRAME: Vector2 = Vector2(358, 258)


const NAME_LIMIT: int = 20
const CELLS: Array = ["public_bk", "public_bk_b2", "public_bk_bc", "public_bk_bc_r", "public_bk_c", "public_bk_l", "public_bk_lt", 
	"public_bk_oc", "public_bk_ol", "public_bk_or", "public_bk_pattern", "public_bk_r", "public_bk_rt", "public_bk_ti", 
	"public_button_close", "public_window_button_bk", "public_input_bk_m", "public_button_window_green", "title_title_confirm_green_t"]

const TIP_EMPTY: String = "Không để trống tên"
const NO_GUILD: String = "Chưa vào Guild"
const NOT_LEADER: String = "Guild trưởng mới được sửa tên"
const NOT_OFFICER: String = "Thành viên không thể đổi tên"
const HINT_TEAM: String = "Nhập tên Team"
const HINT_GUILD: String = "Nhập tên Guild"
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."

var _kind: int = PLAYER_RENAME
var _team: int = 0
var _name: LineEdit
var _focus_due: bool = false

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var cells: Dictionary = {}
	for key: String in CELLS:
		cells[key] = Arena.R[key]
	_use(Arena.FILE, cells)
	_use(RenameAtlas.FILE, RenameAtlas.R)
	_name = _fedit(NAME_LIMIT)


func open(kind: int, team_id: int = 0) -> void :
	_kind = kind if CARD.has(kind) else PLAYER_RENAME
	_team = team_id
	_toast = ""
	_hover = ""
	_press = ""
	_name.max_length = Client.CHAR_NAME_LIMIT if _kind == PLAYER_RENAME else NAME_LIMIT
	_name.text = HINT_GUILD if _kind == CORPS_RENAME else (HINT_TEAM if _kind in [TEAM_RENAME, SELF_TEAM_RENAME] else "")
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

func kind() -> int:
	return _kind

func card() -> int:
	return int(CARD[_kind])


func buy_shown() -> bool:
	return client != null and BagModel.item_count(client.bags, card()) == 0



func _activate(id: String) -> void :
	match id:
		"cancel":
			close("")
		"buy":
			if buy_shown():
				quick_buy_asked.emit(card())
		"confirm":
			_confirm()


func _confirm() -> void :
	var text: String = _name.text
	if text == "":
		say(TIP_EMPTY)
		return
	var note: String = ""
	if _kind in [TEAM_RENAME, SELF_TEAM_RENAME]:
		note = _team_rename(text)
	elif _kind == CORPS_RENAME:
		note = _corps_rename(text)
	elif not client.rename_char(text):
		note = OFFLINE
	close(note)


func _captain(me: String) -> bool:
	for team: Dictionary in client.guild_teams:
		if str(team.get("leaderUuid", "")) == me:
			return true
	return false


func _team_rename(text: String) -> String:
	if str(client.guild.get("strName", "")) == "":
		return NO_GUILD
	var me: String = client.guild_self_uuid()
	if me.is_empty() or not (me == str(client.guild.get("leaderUuid", "")) or me == str(client.guild.get("viceLeaderUuid", "")) or _captain(me)):
		return NOT_OFFICER
	if BagModel.item_count(client.bags, int(CARD[TEAM_RENAME])) < 1:
		quick_buy_asked.emit(int(CARD[TEAM_RENAME]))
		return ""
	var team: int = _team
	if _kind == SELF_TEAM_RENAME:
		team = int(client.guild_members.get(me, {}).get("nTeamId", client.guild_self_team))
	return "" if client.rename_team(team, text) else OFFLINE


func _corps_rename(text: String) -> String:
	if str(client.guild.get("strName", "")) == "":
		return NO_GUILD
	var me: String = client.guild_self_uuid()
	if me.is_empty() or me != str(client.guild.get("leaderUuid", "")):
		return NOT_LEADER
	if BagModel.item_count(client.bags, int(CARD[CORPS_RENAME])) < 1:
		quick_buy_asked.emit(int(CARD[CORPS_RENAME]))
		return ""
	return "" if client.rename_guild(text) else OFFLINE

func _input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()



func _paint() -> void :
	var at: Vector2 = _window(FRAME.x, FRAME.y)
	_fmid("brn_title", at + Vector2(0, 20), FRAME.x)
	_fmid("brn_prompt", at + Vector2(0, 72), FRAME.x)
	var box: Vector2 = at + Vector2(roundf((FRAME.x - 210.0) / 2.0), 103)
	_fblit("public_input_bk_m", box)
	_fput(_name, Rect2(box + Vector2(15, 3), Vector2(190, 29)), 16)
	if buy_shown():
		_fbutton("buy", "brn_buy", at + Vector2(roundf((FRAME.x - 60.0) / 2.0), 147))
	var ok: Vector2 = at + Vector2(roundf((FRAME.x - 120.0) / 2.0), FRAME.y - 17.0 - 35.0)
	_fbutton("confirm", "public_button_window_green", ok)
	_fblit("title_title_confirm_green_t", ok + Vector2(40, 7), 0.0, 0.0, _glow("confirm"))
	if _focus_due:
		_focus_due = false
		_name.grab_focus.call_deferred()
		_name.select_all.call_deferred()
