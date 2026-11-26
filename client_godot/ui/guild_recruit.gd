extends "flash_screen.gd"

















const Recruit = preload("guild_recruit_atlas.gd")
const Arena = preload("arena_atlas.gd")
const Guild = preload("guild_atlas.gd")
const GmReport = preload("gmreport_atlas.gd")
const QuickBuy = preload("quickbuy_atlas.gd")
const FriendPick = preload("friend_pick.gd")
const HallScreen = preload("hall_screen.gd")
const GuildManage = preload("guild_manage_atlas.gd")

signal closed(note: String)
signal watch_asked(uuid: String)

const OUTER: Vector2 = Vector2(1018, 618)
const ROW_H: float = 32.0
const SHOWN: int = 8
const BAR: float = 19.0
const TEAM_MAX: int = 10
const LEVEL_MAX: int = 40
const DEC_MAX: int = 15
const BIT_AUTOJOIN: int = 1
const BIT_BAN_APPLY: int = 2
const BIT_MEMBER_INVITE: int = 4
const OP_SETTING_BIT: int = 1
const OP_LEVEL_LIMIT: int = 2
const OP_LADDER_LIMIT: int = 3
const LADDER_IDS: Array = [0, 1, 4, 7, 10, 13, 17]
const LADDER_NAMES: Array = ["Không Huy Chương", "Đồng", "Bạc", "Vàng", "Bạch Kim", "Kim Cương", "Chỉ Huy"]
const CHECKS: Array = [["cbAutoIn", BIT_AUTOJOIN], ["cbBanApply", BIT_BAN_APPLY], ["cbMemberAuthority", BIT_MEMBER_INVITE]]
const CHECK_W: float = 27.0
const DROP_WIDE: float = 160.0
const DROP_ROW: float = 25.0
const DROP_SHOWN: int = 5

const COMBO_EDGE: Color = Color("1b79b4")
const COMBO_TOP: Color = Color("64bbdf")
const COMBO_BOTTOM: Color = Color("108ec6")
const DROP_FILL: Color = Color("0390d3")
const DROP_OVER: Color = Color("31b3e8")
const DROP_PICKED: Color = Color("07629b")
const INVITE: Vector2 = Vector2(358, 258)
const CELLS: Array = ["public_bk", "public_bk_b2", "public_bk_bc", "public_bk_bc_r", "public_bk_c", "public_bk_l", "public_bk_lt", 
	"public_bk_oc", "public_bk_ol", "public_bk_or", "public_bk_pattern", "public_bk_r", "public_bk_rt", "public_bk_ti", 
	"public_button_close", "public_window_button_bk", "public_input_bk_m", "public_button_window_green", "title_title_confirm_green_t"]

const TITLE: String = "QUẢN LÝ CHIÊU MỘ"
const HEAD_LADDER: String = "Huy Chương"
const HEAD_INVITER: String = "Người mời"
const INVITE_TITLE: String = "MỜI VÀO GUILD"

const INVITE_PROMPT: String = "Nhập tên người chơi muốn mời"
const HELP: String = "Đã chọn tự động duyệt hoặc chặn xin vào, sau khi mở quyền này người chơi được thành viên mời vào sẽ trực tiếp vào Guild"
const MEMBER_MAX: String = "Các Guild  đã đủ. hãy tăng cấp Guild, tạo team mới"
const ALL_TEAMS_FULL: String = "Team không trống, hãy tạo team mới"
const LEVEL_MEMBER_MAX: String = "Số người của Guild Lv tương ứng đã max"
const TEAM_FULL: String = "Team này không còn trống"
const NO_RIGHT: String = "Trưởng Guild chưa mở quyền này"
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."

var _state: String = "set"
var _seen_applies: Array = []
var _seen_guild: Dictionary = {}
var _first: int = 0
var _list_rect: Rect2 = Rect2()
var _thumb: Array = []
var _drag_from: Vector2 = Vector2(-1, -1)
var _drag_sum: float = 0.0
var _drag_first: int = 0
var _level: LineEdit
var _level_edit: bool = false
var _dec: TextEdit
var _dec_box: StyleBoxEmpty = StyleBoxEmpty.new()
var _dec_edit: bool = false
var _dec_prev: String = ""
var _drop: bool = false
var _drop_first: int = 0
var _drop_rect: Rect2 = Rect2()
var _help_rect: Rect2 = Rect2()
var _inviting: bool = false
var _name: LineEdit
var _focus_due: bool = false
var _pick = FriendPick.new()

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Recruit.FILE, Recruit.R)
	var cells: Dictionary = {}
	for key: String in CELLS:
		cells[key] = Arena.R[key]
	_use(Arena.FILE, cells)
	cells = {}
	for key: String in ["gu_sb_bk", "gu_sb_up", "gu_sb_down", "gu_sb_thumb"]:
		cells[key] = Guild.R[key]
	_use(Guild.FILE, cells)
	_use(GmReport.FILE, {"gmr_check_on": GmReport.R["gmr_check_on"], "gmr_check_off": GmReport.R["gmr_check_off"]})
	_use(QuickBuy.FILE, {"qb_findfriend": QuickBuy.R["qb_findfriend"]})
	FriendPick.cells(self)
	_level = _fedit(2, true)
	_level.text_changed.connect(_level_cap)
	_name = _name_fedit()
	_dec = TextEdit.new()
	_dec.visible = false
	_dec.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_dec.context_menu_enabled = false
	_dec.emoji_menu_enabled = false
	_dec.tab_input_mode = false
	_dec.caret_blink = true
	for state: String in ["normal", "focus", "read_only"]:
		_dec.add_theme_stylebox_override(state, _dec_box)
	_dec.add_theme_font_override("font", ARIAL)
	_dec.add_theme_color_override("font_color", Color.WHITE)
	_dec.add_theme_color_override("font_readonly_color", Color.WHITE)
	_dec.add_theme_color_override("caret_color", Color.WHITE)
	_dec.add_theme_color_override("selection_color", Color("0b5fae"))
	_dec.add_theme_color_override("background_color", Color(0, 0, 0, 0))
	_dec.add_theme_constant_override("line_spacing", 0)
	add_child(_dec)
	_dec.text_changed.connect(_dec_cap)

func open() -> void :
	_toast = ""
	_hover = ""
	_press = ""
	_state = "set"
	_seen_applies = client.guild_applies
	_first = 0
	_drop = false
	_inviting = false
	_pick.close()
	_init_setting()
	visible = true
	if not client.guild_apply_list_request():
		say(OFFLINE)

func close(note: String = "") -> void :
	if not visible:
		return
	visible = false
	_drop = false
	_inviting = false
	_pick.close()
	_level_edit = false
	_end_dec()
	_hide_edits()
	closed.emit(note)

func chat_busy() -> bool:
	return visible



func _me() -> String:
	return client.guild_self_uuid()


func _officer() -> bool:
	var me: String = _me()
	return not me.is_empty() and (me == str(client.guild.get("leaderUuid", "")) or me == str(client.guild.get("viceLeaderUuid", "")))

func _crew(team: int) -> int:
	var count: int = 0
	for member: Dictionary in client.guild_members.values():
		if int(member.get("nTeamId", 0)) == team:
			count += 1
	return count


func _guild_full() -> bool:
	var row: Array = GuildManage.LEVELS.get(str(int(client.guild.get("nLevel", 0))), [])
	return row.size() < 2 or client.guild_members.size() >= int(row[1]) * TEAM_MAX


func _least_team() -> int:
	var best: int = 0
	var low: int = 1 << 30
	for team: Dictionary in client.guild_teams:
		var id: int = int(team.get("nTeamId", 0))
		var count: int = _crew(id)
		if count < TEAM_MAX and count <= low:
			low = count
			best = id
	return best

func _self_team() -> Dictionary:
	var id: int = client.guild_self_team
	if id == 0:
		return {}
	for team: Dictionary in client.guild_teams:
		if int(team.get("nTeamId", 0)) == id:
			return team
	return {}

func _bits() -> int:
	return int(client.guild.get("iSettingBit", 0))

func _section(id: int) -> String:
	if id == 0:
		return str(LADDER_NAMES[0])
	var entry: Array = []
	if pack != null:
		entry = pack.board.get("sections", {}).get(str(id), [])
	return str(entry[0]) if entry.size() > 0 else HallScreen.section_name(id)



func _activate(id: String) -> void :
	if _inviting:
		_invite_click(id)
		return
	if id.begins_with("ladder:"):
		_pick_ladder(int(id.substr(7)))
		return
	if id in ["drop_up", "drop_down"]:
		_drop_scroll(-1 if id == "drop_up" else 1)
		return
	if id in ["drop", "slide:drop"]:
		return
	var was: bool = _drop
	_drop = false
	if id.begins_with("agree:"):
		_approve(id.substr(6))
		return
	if id.begins_with("refuse:"):
		if not client.guild_reject_apply(id.substr(7)):
			say(OFFLINE)
		return
	if id.begins_with("watch:"):
		watch_asked.emit(id.substr(6))
		return
	if id.begins_with("check:"):
		_check(int(id.substr(6)))
		return
	match id:
		"cancel":
			close("")
		"tab_mng":
			_state = "mng"
		"tab_set":
			_state = "set"
		"invite":
			if _can_invite():
				_open_invite()
		"reject_all":
			if not client.guild_reject_apply(""):
				say(OFFLINE)
		"level_edit":
			_level_edit = true
			_level.grab_focus.call_deferred()
		"level_ok":
			_level_edit = false
			_level.release_focus()
			if not client.guild_op(OP_LEVEL_LIMIT, int(_level.text)):
				say(OFFLINE)
		"dec_edit":
			_dec_edit = true
			_dec.grab_focus.call_deferred()
		"dec_ok":
			var text: String = _dec.text
			_end_dec()
			if not client.guild_set_recruit(text):
				say(OFFLINE)
		"combo":
			if not was:
				_drop = true
				_drop_first = clampi(_ladder_index(), 0, LADDER_IDS.size() - DROP_SHOWN)
		"list_up", "list_down":
			_scroll(-1 if id == "list_up" else 1)


func _approve(uuid: String) -> void :
	var me: String = _me()
	var team: Dictionary = _self_team()
	if team.is_empty():
		return
	var officer: bool = _officer()
	if me == str(team.get("leaderUuid", "")):
		var count: int = _crew(int(team.get("nTeamId", 0)))
		if count < TEAM_MAX:
			_send_approve(uuid, int(team.get("nTeamId", 0)))
		elif officer:
			_leader_approve(uuid)
			return
		if _guild_full():
			say(LEVEL_MEMBER_MAX)
			return
		if count >= TEAM_MAX:
			say(TEAM_FULL)
	elif officer:
		_leader_approve(uuid)


func _leader_approve(uuid: String) -> void :
	if _guild_full():
		say(MEMBER_MAX)
		return
	var team: int = _least_team()
	if team == 0:
		say(ALL_TEAMS_FULL)
		return
	_send_approve(uuid, team)

func _send_approve(uuid: String, team: int) -> void :
	if not client.guild_approve_apply(uuid, team):
		say(OFFLINE)


func _can_invite() -> bool:
	var me: String = _me()
	if _officer():
		if _guild_full():
			say(MEMBER_MAX)
			return false
		for team: Dictionary in client.guild_teams:
			if _crew(int(team.get("nTeamId", 0))) < TEAM_MAX:
				return true
		say(ALL_TEAMS_FULL)
		return false
	var team: Dictionary = _self_team()
	if not team.is_empty() and me == str(team.get("leaderUuid", "")):
		if _guild_full():
			say(LEVEL_MEMBER_MAX)
			return false
		if _crew(int(team.get("nTeamId", 0))) >= TEAM_MAX:
			say(TEAM_FULL)
			return false
		return true
	if _bits() & BIT_MEMBER_INVITE == 0:
		say(NO_RIGHT)
		return false
	return true


func _check(bit: int) -> void :
	var bits: int = _bits()
	var on: bool = bits & bit == 0
	bits = bits | bit if on else bits & ~ bit
	if on and bit == BIT_AUTOJOIN:
		bits &= ~ BIT_BAN_APPLY
	elif on and bit == BIT_BAN_APPLY:
		bits &= ~ BIT_AUTOJOIN
	if not client.guild_op(OP_SETTING_BIT, bits):
		say(OFFLINE)

func _ladder_index() -> int:
	return LADDER_IDS.find(int(client.guild.get("nLadderLimit", 0)))


func _pick_ladder(index: int) -> void :
	_drop = false
	if index < 0 or index >= LADDER_IDS.size() or index == _ladder_index():
		return
	if not client.guild_op(OP_LADDER_LIMIT, int(LADDER_IDS[index])):
		say(OFFLINE)

func _drop_scroll(step: int) -> void :
	_drop_first = clampi(_drop_first + step, 0, LADDER_IDS.size() - DROP_SHOWN)

func _scroll(step: int) -> void :
	_first = clampi(_first + step, 0, maxi(0, client.guild_applies.size() - SHOWN))


func _init_setting() -> void :
	_seen_guild = client.guild
	_level.text = str(int(client.guild.get("nLevelLimit", 1)))
	_level_edit = false
	_level.release_focus()
	_end_dec()
	_dec.text = str(client.guild.get("strRecruitNotice", ""))
	_dec_prev = _dec.text

func _end_dec() -> void :
	_dec_edit = false
	if _dec != null:
		_dec.release_focus()
		_dec.visible = false


func _level_cap(value: String) -> void :
	if value.is_valid_int() and int(value) > LEVEL_MAX:
		_level.text = str(LEVEL_MAX)
		_level.caret_column = _level.text.length()


func _dec_cap() -> void :
	var now: String = _dec.text
	if now.length() <= DEC_MAX or now.length() <= _dec_prev.length():
		_dec_prev = now
		return
	var kept: String = now.left(DEC_MAX) if _dec_prev.length() <= DEC_MAX else _dec_prev
	_dec_prev = kept
	_dec.text = kept
	_dec.set_caret_line(_dec.get_line_count() - 1)
	_dec.set_caret_column(_dec.get_line(_dec.get_line_count() - 1).length())

func _open_invite() -> void :
	_inviting = true
	_name.text = ""
	_focus_due = true
	_pick.close()
	_level.release_focus()
	_end_dec()

func _close_invite() -> void :
	_inviting = false
	_pick.close()
	_name.visible = false
	_name.release_focus()

func _invite_click(id: String) -> void :
	var picked: Array = _pick.activate(id)
	if bool(picked[0]):
		if not str(picked[1]).is_empty():
			_name.text = str(picked[1])
			_name.caret_column = _name.text.length()
		return
	match id:
		"inv_cancel":
			_close_invite()
		"inv_friend":
			if not _pick.open:
				var friends: Dictionary = {}
				for uuid: String in client.friends:
					if not client.guild_members.has(uuid):
						friends[uuid] = client.friends[uuid]
				_pick.toggle(friends)
		"inv_ok":
			var text: String = _name.text
			if text == "":
				say(INVITE_PROMPT)
				return
			var sent: bool = client.guild_invite(text, client.guild_self_team)
			_close_invite()
			if not sent:
				say(OFFLINE)

func _wheel(step: int, at: Vector2) -> void :
	if _inviting:
		_pick.wheel(step, at)
	elif _drop and Rect2(_drop_rect.position * _f, _drop_rect.size * _f).has_point(at):
		_drop_scroll(step)
	elif _state == "mng" and _list_rect.has_point(at):
		_scroll(step)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _inviting:
		_pick.drag(moved, from, _mobile, _f)
		return
	if _state != "mng":
		return
	if from != _drag_from:
		_drag_from = from
		_drag_sum = 0.0
		_drag_first = _first
	_drag_sum += moved.y
	var count: int = client.guild_applies.size()
	if not _thumb.is_empty() and (_thumb[0] as Rect2).has_point(from):
		var room: float = (_thumb[1] as Rect2).size.y - (_thumb[0] as Rect2).size.y
		var rate: float = (count - SHOWN) / room if room > 0.0 else 0.0
		_first = clampi(roundi(_drag_first + _drag_sum * rate), 0, maxi(0, count - SHOWN))
	elif _mobile and _list_rect.has_point(from):
		_first = clampi(roundi(_drag_first - _drag_sum / (ROW_H * _f)), 0, maxi(0, count - SHOWN))

func _input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _pick.open:
			_pick.close()
		elif _inviting:
			_close_invite()
		elif _drop:
			_drop = false
		else:
			close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()

func _tick(_delta: float) -> void :
	if not visible:
		return
	if client.guild.is_empty():
		close("")
		return
	if not is_same(client.guild_applies, _seen_applies):
		_seen_applies = client.guild_applies
		_scroll(0)
		_state = "mng" if not _officer() or client.guild_req_join > 0 else "set"
	elif _state == "set" and not _officer():
		_state = "mng"
	if not is_same(client.guild, _seen_guild):
		_init_setting()




func _cut(text: String, font: Font, px: float, room: float) -> String:
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	if face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
		return text
	for keep in range(text.length() - 1, 0, -1):
		var short: String = text.left(keep) + "..."
		if face.get_string_size(short, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
			return short
	return "..."

func _frame_at() -> Vector2:
	var frame: Array = Recruit.FRAME
	return _stage() + Vector2(-9, -9) + ((OUTER - Vector2(float(frame[0]), float(frame[1]))) / 2.0).floor()

func _spot(key: String) -> Vector2:
	var spec: Array = Recruit.AT[key] if Recruit.AT.has(key) else Recruit.FORM[key]
	return Vector2(float(spec[0]), float(spec[1]))

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _frame_at()
	var frame: Array = Recruit.FRAME
	_hit("panel", Rect2(at * _f, Vector2(float(frame[0]), float(frame[1])) * _f), false)
	_thumb = []
	_help_rect = Rect2()
	var setting: bool = _state == "set"
	_fblit("rc_set" if setting else "rc_mng", at)
	_fbutton("cancel", "public_button_close", at + _spot("btnClose"))
	_fwords(TITLE, ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2((float(frame[0]) - 182.0) / 2.0, 18), 182.0, 1.5, 28.0)
	if _officer():
		_fbutton("tab_mng", "rc_tab_mng_off" if setting else "rc_tab_mng_on", at + _spot("btnApplyManage"))
		_fbutton("tab_set", "rc_tab_set_on" if setting else "rc_tab_set_off", at + _spot("btnRecruit"))
	if setting:
		_draw_setting(at)
	else:
		_level.visible = false
		_level.release_focus()
		_end_dec()
		_drop = false
		_draw_manage(at)
	if _inviting:
		_draw_invite()
	elif _help_rect.has_area() and _help_rect.has_point(get_local_mouse_position()):
		_draw_help()


func _draw_manage(at: Vector2) -> void :
	var heads: Array = Recruit.HEADS
	_fwords(HEAD_LADDER, ARIAL_BOLD, 11.0, Color.WHITE, "c", at + Vector2(float(heads[0][0]) - 40.0, float(heads[0][1])), 81.0, 1.0, 14.0)
	_fwords(HEAD_INVITER, ARIAL_BOLD, 11.0, Color.WHITE, "c", at + Vector2(float(heads[1][0]) - 40.0, float(heads[1][1])), 81.0, 1.0, 14.0)
	var list: Array = Recruit.AT["lstApply"]
	var origin: Vector2 = at + Vector2(float(list[0]), float(list[1]))
	var applies: Array = client.guild_applies
	var count: int = applies.size()
	_first = clampi(_first, 0, maxi(0, count - SHOWN))
	var scroll: bool = count > SHOWN
	var wide: float = float(list[2]) - (BAR if scroll else 0.0)
	_list_rect = Rect2(origin * _f, Vector2(wide, float(list[3])) * _f)
	var officer: bool = _officer()
	for k in range(mini(SHOWN, count - _first)):
		_draw_row(applies[_first + k], origin + Vector2(0, ROW_H * k), officer)
	if scroll:
		_draw_bar(origin + Vector2(wide, 0), float(list[3]), count)
	_fbutton("reject_all", "rc_reject_all", at + _spot("btnRejectAll"))
	_fbutton("invite", "rc_invite", at + _spot("btnInvite"))


func _draw_row(brief: Dictionary, at: Vector2, officer: bool) -> void :
	var uuid: String = str(brief.get("m_charUuid", ""))
	var spots: Dictionary = Recruit.ROW
	var level: Array = spots["level"]
	_fblit("level_%d" % clampi(int(brief.get("m_level", 0)), 0, 40), at + Vector2(float(level[0]), float(level[1])), float(level[2]), float(level[3]))
	_level_fx(int(brief.get("m_level", 0)), at + Vector2(float(level[0]), float(level[1])), float(level[2]))
	var words: Dictionary = Recruit.ROW_TEXT
	var name: Array = words["lblName"]
	_fwords(_cut(str(brief.get("m_name", "")), ARIAL_BOLD, 12.0, float(name[2])), ARIAL_BOLD, 12.0, Color.WHITE, "c", 
		at + Vector2(float(name[0]), 0), float(name[2]), 0.0, ROW_H, false)
	var ladder: Array = words["lblLadder"]
	_fwords(_cut(_section(int(brief.get("m_eloSectionId", 0))), ARIAL_BOLD, 12.0, float(ladder[2])), ARIAL_BOLD, 12.0, Color.WHITE, "c", 
		at + Vector2(float(ladder[0]), float(ladder[1])), float(ladder[2]), 0.0, 18.0, false)
	var referee: Array = words["lblReferee"]
	var inviter: String = str(client.guild_inviters.get(int(brief.get("m_accountId", 0)), ""))
	_fwords(_cut(inviter, ARIAL_BOLD, 12.0, float(referee[2])), ARIAL_BOLD, 12.0, Color.WHITE, "c", 
		at + Vector2(float(referee[0]), float(referee[1])), float(referee[2]), 0.0, 18.0, false)
	var watch: Array = spots["btnWatch"]
	_fbutton("watch:" + uuid, "rc_watch", at + Vector2(float(watch[0]), float(watch[1])))
	var agree: Array = spots["btnApprove"]
	_fbutton("agree:" + uuid, "rc_agree", at + Vector2(float(agree[0]), float(agree[1])))
	var refuse: Array = spots["btnReject"]
	if officer:
		_fbutton("refuse:" + uuid, "rc_disagree", at + Vector2(float(refuse[0]), float(refuse[1])))
	else:
		_fblit("rc_disagree", at + Vector2(float(refuse[0]), float(refuse[1])), 0.0, 0.0, Color(0.55, 0.55, 0.55, 0.75))
	var cut: Array = spots["cut"]
	_fblit("rc_cut", at + Vector2(float(cut[0]), float(cut[1])))


func _draw_bar(at: Vector2, high: float, count: int) -> void :
	var track: float = high - 2.0 * BAR
	_fblit("gu_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("list_up", "gu_sb_up", at)
	_fbutton("list_down", "gu_sb_down", at + Vector2(0, high - BAR))
	var thumb: float = maxf(10.0, track * float(SHOWN) / float(count))
	var offset: float = (track - thumb) * float(_first) / float(maxi(1, count - SHOWN))
	var rect: Rect2 = _fblit("gu_sb_thumb", at + Vector2(0, BAR + offset), BAR, thumb)
	_thumb = [rect, Rect2((at + Vector2(0, BAR)) * _f, Vector2(BAR, track) * _f)]


func _draw_setting(at: Vector2) -> void :
	var edit_at: Vector2 = at + _spot("btnEditLevel")
	if _level_edit:
		_fbutton("level_ok", "rc_ok", at + _spot("btnConfirmLevel"))
	else:
		_fbutton("level_edit", "rc_edit", edit_at)
	var box: Array = Recruit.FORM["txtLevelLimit"]

	if _inviting:
		_level.visible = false
	else:
		_fput(_level, Rect2(at + Vector2(float(box[0]) + 10.0, float(box[1]) + 2.0), Vector2(float(box[2]) - 110.0, float(box[3]) - 2.0)), 14.0, "l", 
			_level_edit)
	var bits: int = _bits()
	for i in range(CHECKS.size()):
		var spot: Vector2 = _spot(str(CHECKS[i][0]))
		var on: bool = bits & int(CHECKS[i][1]) != 0

		var place: Vector2 = at + Vector2(29.0 + floorf((472.0 - CHECK_W) / 2.0) + 60.0, spot.y - 2.0)
		_fbutton("check:%d" % int(CHECKS[i][1]), "gmr_check_on" if on else "gmr_check_off", place)
	var help: Rect2 = _fblit("rc_help", at + _spot("imgHelp"))
	_help_rect = help
	if _dec_edit:
		_fbutton("dec_ok", "rc_ok", at + _spot("btnConfirmDec"))
	else:
		_fbutton("dec_edit", "rc_edit_dec", at + _spot("btnEditDec"))
	_draw_dec(at)
	_draw_combo(at)


func _draw_dec(at: Vector2) -> void :
	var box: Array = Recruit.FORM["txtDec"]
	var origin: Vector2 = at + Vector2(float(box[0]), float(box[1]))
	var shown: bool = _dec_edit and not _inviting
	if _dec.visible != shown:
		_dec.visible = shown
	if not shown:
		_fpara(_dec.text, ARIAL, 12.0, Color.WHITE, origin + Vector2(8, 6), float(box[2]) - 16.0, 5)
		return
	_dec.position = origin * _f
	_dec.size = Vector2(float(box[2]), float(box[3])) * _f
	var px: int = maxi(6, roundi(12.0 * _f))
	if _dec.get_theme_font_size("font_size") != px:
		_dec.add_theme_font_size_override("font_size", px)
	var left: float = 8.0 * _f
	var top: float = 6.0 * _f
	if not is_equal_approx(_dec_box.content_margin_left, left) or not is_equal_approx(_dec_box.content_margin_top, top):
		_dec_box.content_margin_left = left
		_dec_box.content_margin_top = top
		_dec_box.content_margin_right = left
		_dec_box.content_margin_bottom = top


func _draw_combo(at: Vector2) -> void :
	var spec: Array = Recruit.FORM["cbbLadder"]
	var box: Rect2 = Rect2(at + Vector2(float(spec[0]), float(spec[1])), Vector2(float(spec[2]), float(spec[3])))
	var rect: Rect2 = Rect2(box.position * _f, box.size * _f)
	if _hover == "combo" or _drop:
		_grad(rect, COMBO_BOTTOM, COMBO_BOTTOM, COMBO_EDGE, 3.0, 1.0)
	else:
		_grad(rect, COMBO_TOP, COMBO_BOTTOM, COMBO_EDGE, 3.0, 1.0)
	var split: float = box.end.x - 22.0
	draw_line(Vector2(split, box.position.y + 4.0) * _f, Vector2(split, box.end.y - 4.0) * _f, COMBO_EDGE, maxf(1.0, _f))
	var mid: float = box.position.y + box.size.y / 2.0
	var right: float = box.end.x
	draw_colored_polygon(PackedVector2Array([Vector2(right - 15.0, mid - 2.0) * _f, Vector2(right - 8.0, mid - 2.0) * _f, 
		Vector2(right - 11.5, mid + 3.0) * _f]), Color.WHITE)
	var index: int = _ladder_index()
	if index >= 0:
		_fwords(str(LADDER_NAMES[index]), ARIAL_BOLD, 14.0, Color.WHITE, "l", box.position + Vector2(5, 0), box.size.x - 29.0, 0.0, box.size.y, false)
	_hit("combo", rect, false)
	if not _drop:
		return
	var high: float = DROP_ROW * DROP_SHOWN
	var top: Vector2 = Vector2(box.position.x, box.end.y)
	_drop_rect = Rect2(top, Vector2(DROP_WIDE, high))
	draw_rect(Rect2((top + Vector2(2, 2)) * _f, _drop_rect.size * _f), Color(0, 0, 0, 0.25))
	var area: Rect2 = Rect2(top * _f, _drop_rect.size * _f)
	draw_rect(area, DROP_FILL)
	_hit("drop", area, false)
	var wide: float = DROP_WIDE - BAR
	for k in range(DROP_SHOWN):
		var j: int = _drop_first + k
		var line: Rect2 = Rect2((top + Vector2(0, DROP_ROW * k)) * _f, Vector2(wide, DROP_ROW) * _f)
		var id: String = "ladder:%d" % j
		if j == index:
			draw_rect(line, DROP_PICKED)
		elif _hover == id:
			draw_rect(line, DROP_OVER)
		_fwords(str(LADDER_NAMES[j]), ARIAL_BOLD, 14.0, Color.WHITE, "l", top + Vector2(5, DROP_ROW * k), wide - 7.0, 0.0, DROP_ROW, false)
		_hit(id, line, false)
	var bar: Vector2 = top + Vector2(wide, 0)
	var track: float = high - 2.0 * BAR
	_fblit("gu_sb_bk", bar + Vector2(0, BAR), BAR, track)
	_fbutton("drop_up", "gu_sb_up", bar)
	_fbutton("drop_down", "gu_sb_down", bar + Vector2(0, high - BAR))
	var thumb: float = maxf(10.0, track * float(DROP_SHOWN) / float(LADDER_IDS.size()))
	var offset: float = (track - thumb) * float(_drop_first) / float(LADDER_IDS.size() - DROP_SHOWN)
	var most: int = LADDER_IDS.size() - DROP_SHOWN
	var knob: Rect2 = _fblit("gu_sb_thumb", bar + Vector2(0, BAR + offset), BAR, thumb, _glow("slide:drop"))
	_knob_hit("slide:drop", knob, _drop_first, most, (track - thumb) * _f, func(value: float) -> void : _drop_first = clampi(roundi(value), 0, most))


func _draw_help() -> void :
	var mouse: Vector2 = get_local_mouse_position() / _f
	var wide: float = 300.0
	var px: int = maxi(6, roundi(12.0 * _f))
	var high: float = _face(ARIAL).get_multiline_string_size(HELP, HORIZONTAL_ALIGNMENT_LEFT, (wide - 16.0) * _f, px).y / _f + 10.0
	var at: Vector2 = mouse + Vector2(12, 16)
	at.x = clampf(at.x, 0.0, maxf(0.0, _fw - wide))
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 6.0, Color("6fd0ff", 0.55), 1.5)
	_fpara(HELP, ARIAL, 12.0, Color.WHITE, at + Vector2(8, 5), wide - 16.0)


func _draw_invite() -> void :
	var at: Vector2 = _window(INVITE.x, INVITE.y, "inv_cancel")
	_fwords(INVITE_TITLE, ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2(88, 18), 182.0, 1.5, 28.0)
	_fwords(INVITE_PROMPT, ARIAL_BOLD, 14.0, Color.WHITE, "c", at + Vector2(0, 86), INVITE.x, 1.0, 21.0)
	var box: Vector2 = at + Vector2(74, 121)
	_fblit("public_input_bk_m", box)
	_fput(_name, Rect2(box + Vector2(15, 3), Vector2(190, 29)), 16)
	_fbutton("inv_friend", "qb_findfriend", at + Vector2(288, 128))
	var ok: Vector2 = at + Vector2(119, INVITE.y - 17.0 - 35.0)
	_fbutton("inv_ok", "public_button_window_green", ok)
	_fblit("title_title_confirm_green_t", ok + Vector2(40, 7), 0.0, 0.0, _glow("inv_ok"))
	if _pick.open:
		_pick.draw(self, at + Vector2(288, 128))
	if _focus_due:
		_focus_due = false
		_name.grab_focus.call_deferred()
