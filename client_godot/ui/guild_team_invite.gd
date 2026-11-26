extends "flash_screen.gd"






const Ask = preload("exitask_atlas.gd")
const PopQueue = preload("pop_queue.gd")


const HELD_NOTE: String = " (đang chơi sự kiện — đóng màn để trả lời)"

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const HIDE_IN: Array = ["login", "auth", "servers", "connecting", "characters", "battle"]
const TEXT: String = "Team @teamName@ team trưởng @name@ mời bạn vào Team!"
const GUTTER: float = 2.0

var _closed_rev: int = -1
var _was_battle: bool = false
var _noted_rev: int = -1

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_use(Ask.FILE, Ask.R)
	if client != null:
		client.changed.connect(_follow)


func _follow() -> void :
	if client == null:
		return
	var fighting: bool = client.state == "battle" or client.battle.active
	if _was_battle and not fighting:
		_closed_rev = -1
	_was_battle = fighting
	var show: bool = not client.guild_team_invite.is_empty() and not fighting and client.state not in HIDE_IN\
	and _closed_rev != client.guild_team_invite_rev
	if show and PopQueue.held():
		if _noted_rev != client.guild_team_invite_rev and not visible:
			_noted_rev = client.guild_team_invite_rev
			client.chat_note(message() + HELD_NOTE)
		show = false
	if show != visible:
		visible = show
		_toast = ""
	if show:
		queue_redraw()

func message() -> String:
	if client == null or client.guild_team_invite.is_empty():
		return ""
	var invite: Dictionary = client.guild_team_invite
	return TEXT.replace("@name@", str(invite.get("starter", ""))).replace("@teamName@", str(invite.get("team_name", "")))

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(float(Ask.SIZE[0]), float(Ask.SIZE[1]))
	var frame: Vector2 = at + _xy(Ask.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("xa_frame") * _f), false)
	_fblit("xa_frame", frame)
	var body: Array = Ask.TEXTS["txtContent"]
	_fpara(message(), ARIAL_BOLD, float(body[4]), Color(str(body[5])), at + _xy(body) + Vector2(GUTTER, 0.0), float(body[2]) - GUTTER * 2.0)
	_fbutton("ok", "xa_ok", at + _xy(Ask.NODES["btnConfirm"]))
	_fbutton("no", "xa_no", at + _xy(Ask.NODES["btnCancel"]))
	_fblit("xa_guy", at + _xy(Ask.GUY))



func _activate(id: String) -> void :
	if client == null or client.guild_team_invite.is_empty():
		return
	if id == "ok":
		client.guild_team_invite_answer(true)
	elif id == "no":
		client.guild_team_invite_answer(false)

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_closed_rev = client.guild_team_invite_rev
		visible = false
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
