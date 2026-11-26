extends "hall_screen.gd"
const AppSession = preload("res://net/app_session.gd")








































const Guild = preload("guild_atlas.gd")
const GuildManage = preload("guild_manage_atlas.gd")
const GuildRule = preload("guild_rule_atlas.gd")
const GuildTeam = preload("guild_team_atlas.gd")
const BagRename = preload("bag_rename.gd")
const CreateTeam = preload("guild_create_team.gd")
const Appoint = preload("guild_appoint.gd")
const Recruit = preload("guild_recruit.gd")
const Join = preload("guild_join_atlas.gd")
const GuildCreate = preload("guild_create.gd")
const GuildSearch = preload("guild_search.gd")
const CorpsWatch = preload("corps_watch.gd")
const OpenUi = preload("open_ui_note.gd")
const BagModel = preload("bag_model.gd")
const CTip = preload("ctool_tip.gd")



const HELP_TIPS = [["help:merit", 384, 53, "Cách nhận: \n 1. Tham gia chiến đấu mỗi trận nhận 100đ cống hiến Guild, giới hạn mỗi ngày 1200đ 1 người;\n 22. Login mỗi ngày có thể tăng 100đ cống hiến Guild;\n 3. Thành viên team trong Guild tham gia chiến đấu, nhận thêm điểm cống hiến Guild, thành viên team càng nhiều điểm càng cao, chức vụ càng cao nhận càng nhiều điểm;\n4.  Mỗi ngày dùng xu để cống hiến có thể tăng cống hiến Guild\nChú ý: thành viên Guild cứ mỗi lần được 10đ cống hiến, thì đồng thời tăng 3đ quỹ Guild và 7đ quỹ Team\n"], 
	["help:leader", 773, 107, "Trưởng Guild offline hơn 14 ngày, hệ thống sẽ tự động buộc tội, sẽ cho Guild Phó có online trong 7 ngày gần đây làm Guild Trưởng, Guild Phó đã off hơn 7 ngày hoặc không có Guild Phó, thì thành viên có online trong 7 ngày gần đây và có cống hiến cao nhất sẽ làm Guild Trưởng."], 
	["help:active", 773, 141, "Thành viên Guild login hàng ngày, tham gia thi đấu sẽ tăng Độ Hoạt Động, Độ Hoạt Động Guild là trung bình Độ Hoạt Động của thành viên trong 7 ngày"]]

signal closed

signal quick_buy_asked(tid: int)


signal player_info_asked(uuid: String)


signal donate_asked(tid: int)

signal boss_asked
const GB_PILL: Rect2 = Rect2(558, 438, 210, 28)
const GB_HALL: String = "Về sảnh chính để mở Boss Guild."

const ROW: float = 32.0
const ROW_W: float = 461.0
const SHOWN: int = 9
const BAR: float = 19.0
const TRACK: float = 250.0
const FOLD_W: float = 22.0
const MENU_TIME: float = 3.0
const MENU_MIN_W: float = 178.0
const LINK: Color = Color("086da5")
const LINK_ROLL: Color = Color("00adef")
const TEAM_BG: Color = Color("0081c3")
const TEAM_RIM: Color = Color("6c400b")
const ACT_RIM: Color = Color("086da5", 0.8)
const MENU_BG: Color = Color("e9f9ff", 0.98)
const MENU_NAME: Color = Color("f16422")

const BARE: Array = ["arena_bg", "gameroom_pvpReadyRoom1000x600_shadow", "public_button_close"]
const NC_PAGE: int = 10
const NC_ROW: float = 32.0
const NC_RED: Color = Color("f64a4a")
const NC_NUM: String = "@num1@/@num2@"
const NC_YES: String = "Có"
const NC_NO: String = "Không"
const NC_APPLIED: String = "Đã gửi yêu cầu cho [@clanName@]"

const NC_LADDER: Dictionary = {0: "Không Huy Chương", 1: "Đồng", 4: "Bạc", 7: "Vàng", 10: "Bạch Kim", 13: "Kim Cương", 17: "Chỉ Huy"}
const SOON: String = "%s đang được chuyển sang HTML5."
const GUILD_DONATE: int = 8000001
const TEAM_DONATE: int = 8000002
const TIP_70: String = "Vào Team trước rồi tham gia giải đấu"
const TIP_355: String = "Guild chưa mở, hãy làm xong NV PB Chính"
const GUILD_FLAG: int = 268435456
const LEAVE_TIP: String = "Giao chức chủ Guild hoặc khi Guild còn 1 người mới được rời đi"
const ASK_LEAVE: String = "Rời Guild không? Sau khi đi, các phúc lợi liên quan trong Guild sẽ mất."
const ASK_LEAVE_LEAD: String = "Chuyển chức hoặc Guild còn 1 người mới được đi"

const PADS: Dictionary = {"lblClanName": [10, 10], "lblClanLeaderName": [50, 10], "txtActiveValue": [10, 100], "txtCoin": [10, 10], 
	"txtTeamMoney": [10, 100], "txtLevel": [10, 100]}

const NAMES: Dictionary = {}
const JOIN_NUM: Vector2 = Vector2(495, 362)

const OPTIONS: Dictionary = {"friend": "Thêm bạn bè", "chat": "Chat riêng", "copy": "Copy tên gọi", "team": "Di chuyển team", 
	"kick": "Kick khỏi Guild", "invite": "Mời vào đội", "vice": "Bổ nhiệm Guild Phó", "captain": "Bổ nhiệm Team Trưởng", 
	"leader": "Nhường chức Guild Trưởng"}

const POST_CAPTAIN: int = 5
const POST_VICE: int = 9
const POST_LEADER: int = 10
const POST_TITLES: Dictionary = {0: "Thành viên", 5: "Team trưởng", 9: "Phó Guild", 10: "Guild trưởng"}
const TEAM_MAX: int = 10
const TRANS_COOL: int = 86400
const FRIEND_ORIGIN: int = 2

const KICK_FEES: Array = [[2, 0.3, 0.7], [3, 0.2, 0.4], [5, 0.1, 0.2], [7, 0.05, 0.1]]
const DLG_ROW: float = 32.0
const DLG_SHOWN: Dictionary = {"cj": 6, "ex": 5}
const PICK: Color = Color("ffff00")
const SEXES: Dictionary = {1: "Nam", 2: "Nữ"}
const EX_NAME: String = "Nick người chơi"
const EX_SEX: String = "Nam"
const ASK_KICK: String = "Có kick out @name@ khỏi Guild không?"
const ASK_KICK_LEAD: String = "Khi đó sẽ bị trừ @num1@ quỹ Guild và @num2@ quỹ team, thành viên có cống hiến cao nhất sẽ là team trưởng."
const ASK_KICK_FEE: String = "Khi đó sẽ bị trừ @num1@ quỹ Guild và @num2@ quỹ team."
const ASK_POST: String = "Quyết định nhậm chức @name@ là @title1@?"
const ASK_LEADER: String = "Giao chức cho @name@? Bạn sẽ trở thành thành viên thường"
const NO_CORPS_COIN: String = "Quỹ Guild không đủ"
const TEAMS_MAX: String = "Lượng Team đạt giới hạn, tăng cấp Guild để thêm 4 Team mới."
const NO_TEAM_COIN: String = "Quỹ Team không đủ"
const NOT_ONLINE: String = "Đối phương không online"
const TEAM_FULL: String = "Đủ người"
const INVITE_SENT: String = "Thông tin mời đã gửi, chờ đối phương trả lời"
const IN_COOL: String = "Đối phương đang CD chuyển đội. Còn: @num1@"
const NO_KICK: String = "Không có quyền kick"

const TW_ROW: float = 30.0
const TW_SHOWN: int = 4
const TW_ROW_W: float = 313.0
const ASK_PVE_ON: String = "Mở PB Team này? Sau khi mở, phí bảo trì mỗi lần sẽ tăng @num1@"
const ASK_PVE_OFF: String = "Tắt PB Team? Sau lần bảo trì hôm nay sẽ tắt."
const NO_PVE_COIN: String = "Không đủ quỹ Team, không thể mở PB Team"
const TW_BUTTONS: Dictionary = {"btnRename": ["tw_rename", "gt_rename"], "btnKickOut": ["tw_kick", "gt_kick"], 
	"btnPersonalContribute": ["tw_give", "gt_contribute"], "btnInstanceEnterance": ["tw_enter", "gt_enter"], 
	"btnInstanceSwitch": ["tw_switch", "gt_switch_off"]}

const TW_FIELDS: Array = ["txtClanName", "txtClanLeader", "lblLevel", "lblHonor", "lblTeamFund", "lblTeamCoutribute", "lblMaintenance"]

var _open: Dictionary = {}
var _first: int = 0
var _asked: float = -10.0
var _opened_once: bool = false
var _ui_wait: Array = []
var _team_noted: bool = false
var _me: String = ""
var _menu_uuid: String = ""
var _ctip: CTip = CTip.new()
var _tip_box: Rect2 = Rect2()
var _menu_name: String = ""
var _menu_items: Array = []
var _menu_at: Vector2 = Vector2.ZERO
var _menu_size: Vector2 = Vector2.ZERO
var _menu_hide_at: float = -1.0
var _menu_rect: Rect2 = Rect2()
var _tree_rect: Rect2 = Rect2()
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_first: int = 0
var _click_at: Vector2 = Vector2.ZERO
var _dialog: String = ""

var _ask_do: String = ""
var _ask_text: String = ""
var _ask_uuid: String = ""
var _ask_team: int = 0
var _ask_post: int = 0
var _ask_fees: Array = [0, 0]
var _dlg_uuid: String = ""
var _dlg_team: int = 0
var _dlg_dest: int = 0
var _dlg_rows: Array = []
var _dlg_pick: int = 0
var _dlg_first: int = 0
var _dlg_rect: Rect2 = Rect2()
var _dlg_grab: bool = false
var _dlg_grab_at: Vector2 = Vector2.ZERO
var _dlg_grab_first: int = 0

var fetch: Callable
var _tw_http: HTTPRequest
var _tw_team: int = 0
var _tw_asked: int = 0
var _tw_sig: int = 0
var _tw_state: String = "visit"
var _tw_rename: bool = false
var _tw_flag: int = 0
var _tw_values: Dictionary = {}
var _tw_rows: Array = []
var _tw_pick: int = 0
var _tw_first: int = 0
var _tw_rect: Rect2 = Rect2()
var _tw_grab: bool = false
var _tw_grab_at: Vector2 = Vector2.ZERO
var _tw_grab_first: int = 0
var _tw_seen: Array = []
var _tw_me0: int = 0
var _rename: Control = null
var _create: Control = null
var _appoint: Control = null
var _recruit: Control = null
var _found: Control = null
var _find: Control = null
var _watch: Control = null
var search_fetch: Callable
var _nc_http: HTTPRequest
var _nc_waiting: bool = false
var _nc_page: int = 1
var _nc_prev: bool = false
var _nc_next: bool = false
var _nc_only: bool = false
var _nc_rows: Array = []
var _nc_pick: int = -1
var _nc_was: bool = false
var _ask_back: Dictionary = {}
var _notice: TextEdit = null
var _notice_box: StyleBoxEmpty = StyleBoxEmpty.new()
var _noting: bool = false
var _notice_was: String = ""
var _notice_prev: String = ""

func _setup() -> void :
	super ()
	_add_parts(Guild.PLACE)
	_tw_http = HTTPRequest.new()
	_tw_http.timeout = 10
	_tw_http.accept_gzip = false
	add_child(_tw_http)
	_tw_http.request_completed.connect(_tw_on_query)
	_nc_http = HTTPRequest.new()
	_nc_http.timeout = 10
	_nc_http.accept_gzip = false
	add_child(_nc_http)
	_nc_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		nc_on_reply(result, code, body))
	_notice = TextEdit.new()
	_notice.visible = false
	_notice.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_notice.context_menu_enabled = false
	_notice.emoji_menu_enabled = false
	_notice.tab_input_mode = false
	_notice.caret_blink = true
	for state: String in ["normal", "focus", "read_only"]:
		_notice.add_theme_stylebox_override(state, _notice_box)
	_notice.add_theme_font_override("font", ARIAL)
	_notice.add_theme_color_override("font_color", Color.WHITE)
	_notice.add_theme_color_override("font_readonly_color", Color.WHITE)
	_notice.add_theme_color_override("caret_color", Color.WHITE)
	_notice.add_theme_color_override("selection_color", Color("0b5fae"))
	_notice.add_theme_color_override("background_color", Color(0, 0, 0, 0))
	_notice.add_theme_constant_override("line_spacing", 0)
	add_child(_notice)
	_notice.text_changed.connect(_notice_cap)
	_notice.gui_input.connect(_notice_key)

func _frames() -> Dictionary:
	return Guild.FRAME

func _shown() -> void :
	_reset_list()
	_hide_menu()
	_end_notice()
	_ask_back = {}
	_close_dialog()
	_tw_close()
	if _rename != null and _rename.visible:
		_rename.close("")
	if _create != null and _create.visible:
		_create.close("")
	if _appoint != null and _appoint.visible:
		_appoint.close("")
	if _recruit != null and _recruit.visible:
		_recruit.close("")
	for child: Control in [_found, _find, _watch]:
		if child != null and child.visible:
			child.close()
	_nc_waiting = false
	if _nc_http != null:
		_nc_http.cancel_request()
	_nc_rows = []
	_nc_pick = -1
	_nc_prev = false
	_nc_next = false
	_grab = false
	_ui_wait = []
	_team_noted = false
	if not is_visible_in_tree() or client == null:
		return
	_first = 0
	_open = {}
	_opened_once = false
	_ui_wait = [OpenUi.UI_GUILD]
	if client.request_guild():
		_asked = _time
	_nc_was = _nc_on()
	_nc_request(1)

func _tick(_delta: float) -> void :
	if client == null:
		return


	if client.guild.is_empty():
		_team_noted = false
	elif not _team_noted:
		_team_noted = true
		_ui_wait.push_front(OpenUi.UI_TEAM)
	while not _ui_wait.is_empty() and OpenUi.note(client, pack, int(_ui_wait[0])) != OpenUi.WAIT:
		_ui_wait.pop_front()
	_me = client.guild_self_uuid()

	if _nc_on() and not _nc_was:
		_nc_request(1)
	_nc_was = _nc_on()

	if not _opened_once and not client.guild.is_empty():
		var teams: Array = _teams()
		if not teams.is_empty():
			_opened_once = true
			_open = {int(teams[0].get("nTeamId", 0)): true}
	if not _menu_uuid.is_empty():
		if not client.guild_members.has(_menu_uuid) or not client.guild_briefs.has(_menu_uuid):
			_hide_menu()
		else:

			var inside: bool = _hover == "panel" or _hover.begins_with("menu:") or _menu_rect.has_point(get_local_mouse_position())
			if inside:
				_menu_hide_at = -1.0
			elif _menu_hide_at < 0.0:
				_menu_hide_at = _time + MENU_TIME
			if _menu_hide_at >= 0.0 and _time >= _menu_hide_at:
				_hide_menu()

	if client.guild.is_empty():
		_ask_back = {}
		if not _dialog.is_empty():
			_close_dialog()
		if _tw_team != 0:
			_tw_close()
	elif _tw_team != 0:
		_tw_tick()
	_notice_tick()
	_tree_scroll(0)
	_tick_list()




func _my_team() -> int:
	if client.guild_self_team != 0:
		return client.guild_self_team
	if _me.is_empty():
		return 0
	return int(client.guild_members.get(_me, {}).get("nTeamId", 0))

func _team(id: int) -> Dictionary:
	for team: Dictionary in client.guild_teams:
		if int(team.get("nTeamId", 0)) == id:
			return team
	return {}


func _teams() -> Array:
	var mine: int = _my_team()
	var teams: Array = []
	for team: Dictionary in client.guild_teams:
		if int(team.get("nTeamId", 0)) == mine:
			teams.push_front(team)
		else:
			teams.append(team)
	return teams

func _count(id: int) -> int:
	var count: int = 0
	for member: Dictionary in client.guild_members.values():
		if int(member.get("nTeamId", 0)) == id:
			count += 1
	return count


func _members(id: int) -> Array:
	var found: Array = []
	for uuid: String in client.guild_members:
		if int(client.guild_members[uuid].get("nTeamId", 0)) == id:
			found.append(uuid)
	found.sort_custom(_before)
	return found



func _before(a: String, b: String) -> bool:
	var brief_a: Dictionary = client.guild_briefs.get(a, {})
	var brief_b: Dictionary = client.guild_briefs.get(b, {})
	if brief_a.is_empty() != brief_b.is_empty():
		return brief_b.is_empty()
	if not brief_a.is_empty():
		var member_a: Dictionary = client.guild_members.get(a, {})
		var member_b: Dictionary = client.guild_members.get(b, {})
		var lead: String = str(client.guild.get("leaderUuid", ""))
		var vice: String = str(client.guild.get("viceLeaderUuid", ""))
		var captain: String = str(_team(int(member_a.get("nTeamId", 0))).get("leaderUuid", ""))
		var on_a: int = int(brief_a.get("m_online", 0))
		var on_b: int = int(brief_b.get("m_online", 0))
		var pairs: Array = [[int(member_a.get("iAllMerit", 0)), int(member_b.get("iAllMerit", 0))], 
			[int(member_a.get("iMerit", 0)), int(member_b.get("iMerit", 0))], 
			[int(on_a == 1 and on_b == 0), int(on_a == 0 and on_b == 1)], 
			[int(a == lead), int(b == lead)], [int(a == vice), int(b == vice)], 
			[int( not captain.is_empty() and a == captain), int( not captain.is_empty() and b == captain)], 
			[int(brief_a.get("m_eloSectionId", 0)), int(brief_b.get("m_eloSectionId", 0))], 
			[int(member_a.get("weekLiveness", 0)), int(member_b.get("weekLiveness", 0))], 
			[int(brief_a.get("m_level", 0)), int(brief_b.get("m_level", 0))]]
		for pair: Array in pairs:
			if int(pair[0]) != int(pair[1]):
				return int(pair[0]) > int(pair[1])
	return a < b


func _rows() -> Array:
	var rows: Array = []
	for team: Dictionary in _teams():
		var id: int = int(team.get("nTeamId", 0))
		rows.append([id, ""])
		if bool(_open.get(id, false)):
			for uuid: String in _members(id):
				rows.append([id, uuid])
	return rows

func _most() -> int:
	return maxi(0, _rows().size() - SHOWN)

func _tree_scroll(step: int) -> void :
	_first = clampi(_first + step, 0, _most())

func _thumb(count: int) -> float:
	return maxf(20.0, TRACK * float(SHOWN) / float(maxi(1, count)))


func _post(uuid: String) -> String:
	var member: Dictionary = client.guild_members.get(uuid, {})
	var team: Dictionary = _team(int(member.get("nTeamId", 0)))
	if member.is_empty() or team.is_empty():
		return ""
	var text: String = "Team trưởng" if str(team.get("leaderUuid", "")) == uuid else "Thành viên"
	if uuid == str(client.guild.get("leaderUuid", "")):
		text += "(Guild trưởng)"
	elif uuid == str(client.guild.get("viceLeaderUuid", "")):
		text += "(Phó Guild)"
	return text


func _login(brief: Dictionary) -> String:
	if int(brief.get("m_online", 0)) == 1:
		return "Online"
	var days: int = maxi(0, floori((Time.get_unix_time_from_system() - float(brief.get("m_lastLoginTime", 0))) / 86400.0))
	return "Hôm nay" if days == 0 else "%d ngày trước" % days


func _act_time() -> String:
	var minutes: int = posmod(int(Time.get_time_zone_from_system().get("bias", 0)), 1440)
	var clock: String = "%02d:%02d" % [floori(minutes / 60.0), minutes % 60]
	return "Thời gian:%s - %s" % [clock, clock]


func _state() -> String:
	if _me.is_empty():
		return "member"
	if _me == str(client.guild.get("leaderUuid", "")):
		return "manageClan"
	if _me == str(client.guild.get("viceLeaderUuid", "")):
		return "viceLeader"
	for team: Dictionary in client.guild_teams:
		if str(team.get("leaderUuid", "")) == _me:
			return "teamLeader"
	return "member"


func _info_values() -> Dictionary:
	var info: Dictionary = client.guild
	var leader: Dictionary = client.guild_briefs.get(str(info.get("leaderUuid", "")), {})
	return {"lblClanName": str(info.get("strName", "")), "lblClanLeaderName": str(leader.get("m_name", "")), 
		"txtActiveValue": str(int(info.get("nActiveNum", 0))), "txtCoin": str(int(info.get("iCoin", 0))), 
		"txtTeamMoney": str(int(_team(_my_team()).get("iCoin", 0))), "txtLevel": str(int(info.get("nLevel", 0)))}


func _clip(text: String, font: Font, px: float, room: float, tail: String = "") -> String:
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	if face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
		return text
	for keep in range(text.length() - 1, 0, -1):
		var short: String = text.left(keep) + tail
		if face.get_string_size(short, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
			return short
	return text if text.length() <= 1 else text.left(1) + tail


func _cut(text: String, font: Font, px: float, wide: float) -> String:
	return _clip(text, font, px, wide - 5.0, "...")





func _show_menu(uuid: String) -> void :
	_me = client.guild_self_uuid()
	var member: Dictionary = client.guild_members.get(uuid, {})
	var brief: Dictionary = client.guild_briefs.get(uuid, {})
	if member.is_empty() or brief.is_empty():
		return
	var leader: String = str(client.guild.get("leaderUuid", ""))
	var vice: String = str(client.guild.get("viceLeaderUuid", ""))
	var chief: bool = not _me.is_empty() and _me in [leader, vice]
	var captain: bool = false
	if not _me.is_empty():
		for team: Dictionary in client.guild_teams:
			if str(team.get("leaderUuid", "")) == _me:
				captain = true
	var same: bool = int(member.get("nTeamId", 0)) == _my_team()
	var items: Array
	if uuid == _me:
		items = ["copy", "team"]
	elif captain and same:
		items = ["friend", "chat", "copy", "team", "kick"] if chief else ["friend", "chat", "copy", "kick"]
	elif captain:
		items = ["friend", "chat", "copy", "team", "kick", "invite"] if chief else ["friend", "chat", "copy", "invite"]
	elif chief:
		items = ["friend", "chat", "copy", "team", "kick"]
	else:
		items = ["friend", "chat", "copy"]
	if not _me.is_empty() and _me == leader:
		if vice != uuid and leader != uuid:
			items.append("vice")
		var team: Dictionary = _team(int(member.get("nTeamId", 0)))
		if not team.is_empty() and str(team.get("leaderUuid", "")) != uuid:
			items.append("captain")
		if leader != uuid:
			items.append("leader")
	_menu_uuid = uuid
	_menu_name = str(brief.get("m_name", ""))
	_menu_items = items
	var face: Font = _face(ARIAL_BOLD)
	var widest: float = face.get_string_size(_menu_name, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(16.0 * _f))).x / _f
	for key: String in items:
		widest = maxf(widest, face.get_string_size(str(OPTIONS[key]), HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(14.0 * _f))).x / _f + 5.0)
	_menu_size = Vector2(maxf(MENU_MIN_W, widest + 9.0), 69.0 + 26.0 * items.size())
	var spot: Vector2 = _click_at
	var x: float = spot.x - _menu_size.x
	if x < 0.0:
		x = spot.x
	var y: float = spot.y
	if spot.y > 600.0 - _menu_size.y:
		y = spot.y - _menu_size.y
	if spot.y - _menu_size.y < 0.0:
		y = 0.0
	_menu_at = Vector2(x, y)
	_menu_rect = Rect2(_menu_at * _f, _menu_size * _f)
	_menu_hide_at = _time + MENU_TIME

func _hide_menu() -> void :
	_menu_uuid = ""
	_menu_name = ""
	_menu_items = []
	_menu_hide_at = -1.0
	_menu_rect = Rect2()




func _fround(rect: Rect2, fill: Color, radius: float, edge: Color = Color(0, 0, 0, 0), width: float = 0.0) -> void :
	_round(Rect2(rect.position * _f, rect.size * _f), fill, radius * 2.0, edge, width * 2.0)


func _fslice(cell_name: String, at: Vector2, high: float, cap: float = 4.0, tint: Color = Color.WHITE) -> void :
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var src: Rect2 = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	var wide: float = src.size.x
	var end: float = minf(cap, floorf(minf(high, src.size.y) / 2.0))
	draw_texture_rect_region(cell[0], Rect2(at * _f, Vector2(wide, end) * _f), Rect2(src.position, Vector2(wide, end)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, end)) * _f, Vector2(wide, high - 2.0 * end) * _f), 
		Rect2(src.position + Vector2(0, end), Vector2(wide, src.size.y - 2.0 * end)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, high - end)) * _f, Vector2(wide, end) * _f), 
		Rect2(src.position + Vector2(0, src.size.y - end), Vector2(wide, end)), tint)

func _paint() -> void :
	_tip_box = Rect2()
	_me = client.guild_self_uuid()
	_tree_rect = Rect2()
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(Hall.FILE, Hall.R)
		_use(Guild.FILE, Guild.R)
		_use(GuildRule.FILE, GuildRule.R)
		_use(GuildTeam.FILE, GuildTeam.R)
		_use(GuildManage.FILE, GuildManage.R)
		_use(Join.FILE, Join.R)
	_scene()
	var frame: Vector2 = _at("hall")
	var hall_rows: Array = _parts.get("hall", [])
	if client.guild.is_empty():
		_frows(hall_rows.filter( func(row: Array) -> bool: return str(row[3]) in BARE), frame)
		_nc_draw(frame)
	else:
		_frows(hall_rows, frame)
		_draw_tree(frame)
		_place_notice(frame)
		_draw_info(frame)
		for help: Array in HELP_TIPS:
			_hit(str(help[0]), Rect2((frame + Vector2(float(help[1]), float(help[2]))) * _f, Vector2(16, 16) * _f), false)
		var buttons: Array = Guild.BUTTONS.get(_state(), [])
		for button: Array in buttons:
			if _noting and str(button[0]) == "btnSetNotice":
				continue
			if str(button[0]) == "btnCorpsGift" and not _can_gift():

				_fblit("gm_gift_off", frame + Vector2(float(button[2]), float(button[3])))
				continue
			_fbutton(str(button[0]), str(button[1]), frame + Vector2(float(button[2]), float(button[3])))
			if str(button[0]) == "btnRecruitManage" and client.guild_req_join > 0:
				_fblit("public_tip", frame + JOIN_NUM + Vector2(3, 3))
				_fwords(str(client.guild_req_join), ARIAL_BOLD, 11, Color.WHITE, "c", frame + JOIN_NUM, 25.0, 0.0, 25.0)
		if _noting:
			_fbutton("btnSureNotice", "gm_sure_notice", frame + Vector2(float(GuildManage.SURE[0]), float(GuildManage.SURE[1])))
		_fwords(_act_time(), ARIAL_BOLD, 14, Color.WHITE, "c", frame + Vector2(float(Guild.ACT_TIME[0]) - 150.0, float(Guild.ACT_TIME[1])), 300, 
			1.5, 0.0, false, ACT_RIM)
		_gb_pill(frame)
	var side: Vector2 = _at("list")
	var list_rows: Array = _parts.get("list", [])
	_frows(list_rows, side)
	_draw_players(side)
	_draw_chat()
	_draw_menu()
	if not _menu_uuid.is_empty():
		_draw_popup()
	elif not _viewing.is_empty():
		_draw_viewing()
	_draw_dialog()
	_draw_help_tip()


func _draw_help_tip() -> void :
	var body: String = help_text(_hover) if _press.is_empty() and not client.guild.is_empty() else ""
	var shown: Rect2 = _ctip.draw(self, _hover if not body.is_empty() else "", body, get_local_mouse_position() / _f, Vector2(_fw, _fh), _f)
	if shown.has_area():
		_tip_mark(Rect2(shown.position * _f, shown.size * _f))



func _tip_mark(rect: Rect2) -> void :
	_tip_box = rect.grow(2.0 * _f) if not _tip_box.has_area() else _tip_box.merge(rect.grow(2.0 * _f))

func chat_cover() -> Array:
	var out: Array = super ()
	if _tip_box.has_area():
		out.append(_tip_box)
	return out


static func help_text(id: String) -> String:
	for help: Array in HELP_TIPS:
		if str(help[0]) == id:
			return str(help[3])
	return ""


func _draw_tree(frame: Vector2) -> void :
	var at: Vector2 = frame + Vector2(float(Guild.TREE[0]), float(Guild.TREE[1]))
	_tree_rect = Rect2(at * _f, Vector2(float(Guild.TREE[2]), float(Guild.TREE[3])) * _f)
	var rows: Array = _rows()
	var most: int = maxi(0, rows.size() - SHOWN)
	_first = clampi(_first, 0, most)
	for slot in range(mini(SHOWN, rows.size() - _first)):
		var row: Array = rows[_first + slot]
		var spot: Vector2 = at + Vector2(0, ROW * slot)
		if str(row[1]).is_empty():
			_draw_team(_team(int(row[0])), spot)
		else:
			_draw_member(str(row[1]), spot)
	var bar: Vector2 = at + Vector2(ROW_W, 0)
	_fblit("gu_sb_bk", bar + Vector2(0, BAR), BAR, TRACK)
	_fbutton("sb_up", "gu_sb_up", bar)
	_fbutton("sb_down", "gu_sb_down", bar + Vector2(0, BAR + TRACK))
	if most > 0:
		var thumb: float = _thumb(rows.size())
		var top: float = BAR + roundf((TRACK - thumb) * float(_first) / float(most))
		if top > BAR:
			_hit("sb_pgup", Rect2((bar + Vector2(0, BAR)) * _f, Vector2(BAR, top - BAR) * _f), false)
		if top + thumb < BAR + TRACK:
			_hit("sb_pgdn", Rect2((bar + Vector2(0, top + thumb)) * _f, Vector2(BAR, BAR + TRACK - top - thumb) * _f), false)
		_fslice("gu_sb_thumb", bar + Vector2(0, top), thumb, 4.0, _glow("slide:tree"))
		_hit("slide:tree", Rect2((bar + Vector2(0, top)) * _f, Vector2(BAR, thumb) * _f), false)


func _draw_team(team: Dictionary, at: Vector2) -> void :
	if team.is_empty():
		return
	var id: int = int(team.get("nTeamId", 0))
	var count: int = _count(id)
	draw_rect(Rect2(at * _f, Vector2(ROW_W, ROW) * _f), TEAM_BG)
	if count > 0:
		_fblit("gu_open" if bool(_open.get(id, false)) else "gu_closed", at + Vector2(0, 7))
		_hit("fold:%d" % id, Rect2(at * _f, Vector2(FOLD_W, ROW) * _f), false)
	_fwords("Lv %d" % int(team.get("nLevel", 0)), ARIAL_BOLD, 14, Color.WHITE, "l", at + Vector2(24, 5), 56, 0.0, 0.0, false)
	var title: String = _cut("%s(%dngười)" % [str(team.get("strName", "")), count], ARIAL_BOLD, 13, 240)
	_fwords(title, ARIAL_BOLD, 13, Color.WHITE, "l", at + Vector2(84, 5), 236, 1.0, 0.0, false, TEAM_RIM)
	_fbutton("teamop:%d" % id, "gu_team_op", at + Vector2(403, 3))
	_fblit("gu_row_line", at + Vector2(0, 30))


func _draw_member(uuid: String, at: Vector2) -> void :
	var member: Dictionary = client.guild_members.get(uuid, {})
	var brief: Dictionary = client.guild_briefs.get(uuid, {})
	if not member.is_empty() and not brief.is_empty():
		_fblit("level_%d" % clampi(int(brief.get("m_level", 0)), 0, 40), at + Vector2(11, 6), 40.0, 20.0)
		_level_fx(int(brief.get("m_level", 0)), at + Vector2(11, 6), 40.0)
		var vip: int = clampi(int(brief.get("m_vipLevel", 0)) % 100, 0, 12)
		var style: Array = name_style(vip)
		var ink: PackedColorArray = NameStyles.colors_of(client, 0, str(brief.get("m_name", "")))
		if not ink.is_empty():
			NameStyles.place(self, _cut(str(brief.get("m_name", "")), ARIAL_BOLD, 13, 140), ARIAL_BOLD, 13, "l", at + Vector2(63, 7), 136, 1.0, 0.0, false, 
				NameStyles.tints(ink, str(brief.get("m_name", "")).length()), true)
			style = [Color(0, 0, 0, 0), Color(0, 0, 0, 0)]
		_fwords(_cut(str(brief.get("m_name", "")), ARIAL_BOLD, 13, 140), ARIAL_BOLD, 13, style[0], "l", at + Vector2(63, 7), 136, 1.0, 0.0, false, 
			style[1])
		if vip > 0:
			_fblit("vip_%d" % vip, at + Vector2(160, 7))
		var cols: Array = [[_post(uuid), 201.0, 60.0], ["%d/%d" % [int(member.get("iMerit", 0)), int(member.get("iAllMerit", 0))], 261.0, 100.0], 
			[_login(brief), 361.0, 74.0]]
		for col: Array in cols:
			_fwords(_cut(str(col[0]), ARIAL_BOLD, 13, float(col[2])), ARIAL_BOLD, 13, Color.WHITE, "c", at + Vector2(float(col[1]), 5), float(col[2]), 
				0.0, 0.0, false)
		var lead: String = str(client.guild.get("leaderUuid", ""))
		var vice: String = str(client.guild.get("viceLeaderUuid", ""))
		if ( not _me.is_empty() and _me in [lead, vice]) or _me != uuid:
			_fbutton("op:" + uuid, "gu_member_op", at + Vector2(435, 5))
	_fblit("gu_row_line", at + Vector2(0, 30))


func _draw_info(frame: Vector2) -> void :
	var values: Dictionary = _info_values()
	for key: String in values:
		var box: Array = Guild.INFO[key]
		var pad: Array = PADS.get(key, [10, 10])
		var room: float = float(box[2]) - float(pad[0]) - float(pad[1]) - 4.0
		_fwords(_clip(str(values[key]), ARIAL_BOLD, 13, room), ARIAL_BOLD, 13, Color.WHITE, "l", 
			frame + Vector2(float(box[0]) + float(pad[0]) + 2.0, float(box[1]) + 5.0), room, 0.0, 0.0, false)
	var leader: Dictionary = client.guild_briefs.get(str(client.guild.get("leaderUuid", "")), {})
	if not leader.is_empty():
		_fblit("level_%d" % clampi(int(leader.get("m_level", 0)), 0, 40), frame + Vector2(float(Guild.BADGE[0]), float(Guild.BADGE[1])), 
			float(Guild.BADGE[2]), float(Guild.BADGE[3]))
		_level_fx(int(leader.get("m_level", 0)), frame + Vector2(float(Guild.BADGE[0]), float(Guild.BADGE[1])), float(Guild.BADGE[2]))
	if _notice.visible:
		return
	var notice: Array = Guild.INFO["txtNotice"]
	_fpara(_notice.text if _noting else str(client.guild.get("strNotice", "")), ARIAL, 12, Color.WHITE, 
		frame + Vector2(float(notice[0]) + 8.0, float(notice[1]) + 4.0), float(notice[2]) - 16.0, 4)


func _draw_popup() -> void :
	var at: Vector2 = _menu_at
	_hit("panel", _menu_rect, false)
	_fround(Rect2(at, _menu_size), MENU_BG, 10.0, Color.WHITE, 2.0)
	_fwords(_menu_name, ARIAL_BOLD, 16, MENU_NAME, "l", at + Vector2(4, 2), _menu_size.x - 8.0, 0.0, 0.0, false)
	_fblit("gu_menu_line", at + Vector2(2, 30))
	var face: Font = _face(ARIAL_BOLD)
	var font_size: int = maxi(6, roundi(14.0 * _f))
	for i in range(_menu_items.size()):
		var key: String = str(_menu_items[i])
		var label: String = str(OPTIONS.get(key, key))
		var id: String = "menu:" + key
		var wide: float = face.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f + 5.0
		var cell: Rect2 = Rect2(at + Vector2(2, 38.0 + 26.0 * i), Vector2(wide, 20))
		var ink: Color = LINK
		if _hover == id:
			_fround(cell, LINK_ROLL, 2.0)
			ink = Color.WHITE
		_fwords(label, ARIAL_BOLD, 14, ink, "c", cell.position, cell.size.x, 0.0, 20.0, false)
		_hit(id, Rect2(cell.position * _f, cell.size * _f), false)
	_fbutton("menu:watch", "gu_watch", at + Vector2(110, 38.0 + 26.0 * _menu_items.size()))




func _gb_pill(frame: Vector2) -> void :
	if client.get("guild_boss") == null or not bool(client.guild_boss.get("live", false)) or int(client.guild_boss.get("role", 255)) == 255:
		return
	var rect: Rect2 = Rect2((frame + GB_PILL.position) * _f, GB_PILL.size * _f)
	var lit: bool = _hover == "gb_boss"
	_round(rect, Color("c0392b") if not lit else Color("e74c3c"), 14.0 * _f, Color("ffe45c"), maxf(1.0, 2.0 * _f))
	_fwords("BOSS GUILD", ARIAL_BOLD, 15, Color.WHITE, "c", frame + GB_PILL.position, GB_PILL.size.x, 1.5, GB_PILL.size.y, false, Color("5a0e00"))
	if not client.guild_boss_awards.is_empty():
		_fblit("public_tip", frame + GB_PILL.position + Vector2(GB_PILL.size.x - 14.0, -6.0))
	_hit("gb_boss", rect, false)

func _activate(id: String) -> void :
	if id == "gb_boss":
		if client.state != "lobby":
			say(GB_HALL)
		else:
			boss_asked.emit()
		return
	if id.begins_with("fold:"):
		var team: int = int(id.substr(5))
		_open[team] = not bool(_open.get(team, false))
		_tree_scroll(0)
	elif id.begins_with("op:"):
		_show_menu(id.substr(3))
	elif id.begins_with("teamop:"):
		_open_team(int(id.substr(7)))
	elif id.begins_with("tw_") or id.begins_with("tw:"):
		_tw_activate(id)
	elif id.begins_with("nc:"):
		_nc_activate(id)
	elif id.begins_with("menu:"):


		var key: String = id.substr(5)
		var nick: String = _menu_name
		var uuid: String = _menu_uuid
		_hide_menu()
		match key:
			"chat":
				whisper.emit(nick)
			"copy":
				if DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
					DisplayServer.clipboard_set(nick)
			"friend":
				client.add_friend(nick, FRIEND_ORIGIN)
			"invite":
				_invite_member(uuid)
			"team":
				_change_team(uuid)
			"kick":
				_open_kick(uuid)
			"vice":
				_open_post(uuid, POST_VICE)
			"captain":
				_open_post(uuid, POST_CAPTAIN)
			"leader":
				_open_post(uuid, POST_LEADER)
			"watch":
				if not uuid.is_empty():
					player_info_asked.emit(uuid)
			_:
				say(SOON % str(OPTIONS.get(key, key)))
	elif id in ["ask_ok", "ask_no", "dlg_ok", "dlg_close", "rule_go", "lv_give", "lv_up", "gift_get", "gift_item", "gift_got"] or id.begins_with("dlg:")\
	or id.begins_with("cj:"):
		_dialog_activate(id)
	elif id == "btnSetNotice":
		_begin_notice()
	elif id == "btnSureNotice":
		_sure_notice()
	elif id == "btnSkill":
		_open_skill()
	elif id.begins_with("sk_") or id.begins_with("sk:"):
		_skill_activate(id)
	elif id == "btnCorpsCountribute":
		donate_asked.emit(GUILD_DONATE)
	elif id == "btnDonate":
		donate_asked.emit(TEAM_DONATE)
	elif id == "btnJoinLeague":
		pass
	elif NAMES.has(id):
		say(SOON % str(NAMES[id]))
	else:
		match id:
			"back":
				closed.emit()
			"btnRank":
				page_asked.emit("board:guild")
			"btnWatchMatchRule":
				_close_dialog()
				_dialog = "rule"
			"btnMyClan":
				_open_team(_my_team())
			"btnCorpsRename":
				_open_rename(BagRename.CORPS_RENAME)
			"btnCreateTeam":
				_create_team_click()
			"btnAppoint":
				_appoint_click()
			"btnRecruitManage":
				_recruit_click()
			"btnMemberInvite":
				pass
			"btnCorpsLevelUp":
				_open_level_up()
			"btnCorpsGift":
				_open_gift()
			"btnLeaveClan":
				if not _me.is_empty() and _me == str(client.guild.get("leaderUuid", "")) and client.guild_members.size() > 1:
					say(LEAVE_TIP)
				else:

					_open_ask("leave", ASK_LEAVE_LEAD if not _me.is_empty() and _me == str(client.guild.get("leaderUuid", "")) else ASK_LEAVE, "", 0, 0, [0, 0])
			"sb_up", "sb_down":
				_tree_scroll(-1 if id == "sb_up" else 1)
			"sb_pgup", "sb_pgdn":
				_tree_scroll( - SHOWN if id == "sb_pgup" else SHOWN)
			"panel", "slide:tree", "slide:dlg", "slide:tw", "slide:sk", "shade":
				pass
			_:
				_shared(id)

func _wheel(step: int, at: Vector2) -> void :
	if _popped() or _dialog == "ask":
		return
	if _tw_team != 0:
		if _tw_rect.has_point(at):
			_tw_scroll(step * 3)
		return
	if _dialog == "skill":
		if _sk_rect.has_point(at):
			_sk_scroll(step * 3)
		return
	if not _dialog.is_empty():
		if _dlg_rect.has_point(at):
			_dlg_scroll(step * 3)
		return
	if not _viewing.is_empty() or ( not _menu_uuid.is_empty() and _menu_rect.has_point(at)):
		return
	if _tree_rect.has_point(at):
		_tree_scroll(step * 3)
	else:
		_wheel_list(step, at)



func _escape() -> bool:
	if _rename != null and _rename.visible:
		_rename.close("")
		return true
	if _create != null and _create.visible:
		_create.close("")
		return true
	if _appoint != null and _appoint.visible:
		_appoint.close("")
		return true
	if _recruit != null and _recruit.visible:
		_recruit.close("")
		return true
	for child: Control in [_found, _find, _watch]:
		if child != null and child.visible:
			child.close()
			return true
	if _dialog == "ask":
		_close_dialog()
		return true
	if _tw_team != 0:
		_tw_close()
		return true
	if _dialog == "skill" and _sk_pick_slot != 0:
		_sk_close_pick()
		return true
	if not _dialog.is_empty():
		_close_dialog()
		return true
	if not _menu_uuid.is_empty():
		_hide_menu()
		return true
	return super ()


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = event.position
		_click_at = pos / _f
		if event.pressed:
			if not _menu_uuid.is_empty() and not _menu_rect.has_point(pos):
				_hide_menu()
			if _viewing.is_empty() and _hit_at(pos) == "slide:tree":
				_grab = true
				_grab_at = pos
				_grab_first = _first
			elif _hit_at(pos) == "slide:dlg":
				_dlg_grab = true
				_dlg_grab_at = pos
				_dlg_grab_first = _dlg_first
			elif _hit_at(pos) == "slide:tw":
				_tw_grab = true
				_tw_grab_at = pos
				_tw_grab_first = _tw_first
			elif _hit_at(pos) == "slide:sk":
				_sk_grab = true
				_sk_grab_at = pos
				_sk_grab_first = _sk_first
		else:
			_grab = false
			_dlg_grab = false
			_tw_grab = false
			_sk_grab = false
	elif event is InputEventMouseMotion and _grab:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
			_grab = false
		else:
			var count: int = _rows().size()
			var most: int = maxi(0, count - SHOWN)
			if most > 0:
				var step: float = maxf(0.001, (TRACK - _thumb(count)) / float(most))
				_first = clampi(_grab_first + roundi((event.position.y - _grab_at.y) / _f / step), 0, most)
	elif event is InputEventMouseMotion and _dlg_grab:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
			_dlg_grab = false
		else:
			_dlg_drag(event.position.y - _dlg_grab_at.y)
	elif event is InputEventMouseMotion and _tw_grab:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
			_tw_grab = false
		else:
			_tw_drag(event.position.y - _tw_grab_at.y)
	elif event is InputEventMouseMotion and _sk_grab:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
			_sk_grab = false
		else:
			_sk_drag(event.position.y - _sk_grab_at.y)
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode == KEY_ESCAPE:
		closed.emit()
		get_viewport().set_input_as_handled()




func _can_invite(who: Dictionary) -> bool:
	return int(who.get("nAcctId", 0)) != client.account_oid and client.can_invite(str(who.get("szName", "")))


func _bare_window(wide: float, high: float, close: String) -> Vector2:
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(wide, high)
	_hit("panel", Rect2(at * _f, Vector2(wide, high) * _f), false)
	draw_rect(Rect2((at + Vector2(12, 43)) * _f, Vector2(wide - 24.0, high - 56.0) * _f), WINDOW)
	var full: Vector2 = _cell_size("public_bk_pattern")
	var part: Vector2 = Vector2(minf(full.x, wide - 24.0), minf(full.y, high - 56.0))
	_fpart("public_bk_pattern", at + Vector2(12, 43) + (Vector2(wide - 24.0, high - 56.0) - part) / 2.0, Rect2(((full - part) / 2.0).floor(), part))
	_fblit("public_bk_lt", at)
	_fblit("public_bk_rt", at + Vector2(wide - 34.0, 0))
	_fblit("public_bk_bc", at + Vector2(0, high - 90.0))
	_fblit("public_bk_bc_r", at + Vector2(wide - 30.0, high - 90.0))
	_fblit("public_bk", at + Vector2(34, 0), wide - 68.0)
	_fblit("public_bk_b2", at + Vector2(30, high - 68.0), wide - 60.0)
	_fblit("public_bk_l", at + Vector2(0, 84), 0.0, high - 174.0)
	_fblit("public_bk_r", at + Vector2(wide - 30.0, 84), 0.0, high - 174.0)
	_fmid("public_bk_ti", at + Vector2(0, 18), wide)
	_fblit("public_bk_oc", at + Vector2(43, 9), wide - 86.0)
	_fblit("public_bk_ol", at + Vector2(35, 9))
	_fblit("public_bk_or", at + Vector2(wide - 43.0, 9))
	_fblit("public_bk_c", at + Vector2(wide - 52.0, 13))
	_fmid("public_window_button_bk", at + Vector2(0, high - 56.0), wide)
	_fbutton(close, "public_button_close", at + Vector2(wide - 39.0, 15))
	return at

func _close_dialog() -> void :
	var back: Dictionary = _ask_back
	_ask_back = {}
	_dialog = ""
	_ask_do = ""
	_ask_text = ""
	_ask_uuid = ""
	_ask_team = 0
	_ask_post = 0
	_ask_fees = [0, 0]
	_dlg_uuid = ""
	_dlg_team = 0
	_dlg_dest = 0
	_dlg_rows = []
	_dlg_pick = 0
	_dlg_first = 0
	_dlg_rect = Rect2()
	_dlg_grab = false
	_sk_reset()
	if not back.is_empty():
		_unstash(back)


func _open_ask(kind: String, text: String, uuid: String, team: int, post: int, fees: Array) -> void :
	_close_dialog()
	_dialog = "ask"
	_ask_do = kind
	_ask_text = text
	_ask_uuid = uuid
	_ask_team = team
	_ask_post = post
	_ask_fees = fees


func _open_list(kind: String) -> void :
	_dialog = kind
	_dlg_pick = 0
	_dlg_first = 0
	_dlg_grab = false


func _in_cool(uuid: String) -> bool:
	var member: Dictionary = client.guild_members.get(uuid, {})
	if member.is_empty():
		return true
	return int(Time.get_unix_time_from_system()) - int(member.get("nTransTime", 0)) <= TRANS_COOL


func _cool_left(member: Dictionary) -> int:
	if member.is_empty():
		return 0
	return int(member.get("nTransTime", 0)) + TRANS_COOL - int(Time.get_unix_time_from_system())


func _say_cool(left: int) -> void :
	say(IN_COOL.replace("@num1@", _day_hours(maxi(0, left))))


func _day_hours(seconds: int) -> String:
	var hours: int = ceili(seconds / 3600.0)
	if hours < 24:
		return "%d giờ" % hours
	var days: int = floori(hours / 24.0)
	hours %= 24
	if hours > 0:
		return "%d ngày %d giờ" % [days, hours]
	return "%d ngày" % days



func _invite_member(uuid: String) -> void :
	var brief: Dictionary = client.guild_briefs.get(uuid, {})
	if brief.is_empty() or int(brief.get("m_online", 0)) == 0:
		say(NOT_ONLINE)
		return
	var member: Dictionary = client.guild_members.get(uuid, {})
	if member.is_empty():
		return
	if _in_cool(uuid):
		_say_cool(_cool_left(member))
		return
	var mine: int = _my_team()
	if _team(mine).is_empty():
		return
	if _count(mine) >= TEAM_MAX:
		say(TEAM_FULL)
		return
	if client.guild_invite_member(int(member.get("nTeamId", 0)), uuid):
		say(INVITE_SENT)


func _change_team(uuid: String) -> void :
	var member: Dictionary = client.guild_members.get(uuid, {})
	if _in_cool(uuid):
		_say_cool(_cool_left(member))
		return
	_close_dialog()
	_dlg_uuid = uuid
	_dlg_team = int(member.get("nTeamId", 0))
	for team: Dictionary in client.guild_teams:
		var id: int = int(team.get("nTeamId", 0))
		if id != _dlg_team:
			_dlg_rows.append(id)
	_open_list("cj")


func _open_exchange(dest: int) -> void :
	var rows: Array = []
	for member: Dictionary in client.guild_members.values():
		if int(member.get("nTeamId", 0)) == dest:
			rows.append(member.duplicate())
	_dlg_dest = dest
	_dlg_rows = rows
	_open_list("ex")


func _open_kick(uuid: String) -> void :
	var member: Dictionary = client.guild_members.get(uuid, {})
	var brief: Dictionary = client.guild_briefs.get(uuid, {})
	if member.is_empty() or brief.is_empty():
		return
	var days: int = 0
	if int(brief.get("m_online", 0)) != 1:
		days = maxi(0, floori((int(Time.get_unix_time_from_system()) - int(brief.get("m_lastLoginTime", 0))) / 86400.0))
	var rates: Array = [0.0, 0.0]
	for row: Array in KICK_FEES:
		if days < int(row[0]):
			rates = [float(row[1]), float(row[2])]
			break
	var merit: int = int(member.get("iAllMerit", 0))
	var fees: Array = [int(float(rates[0]) * merit), int(float(rates[1]) * merit)]
	var lead: bool = false
	for team: Dictionary in client.guild_teams:
		if str(team.get("leaderUuid", "")) == uuid:
			lead = true
	var text: String = (ASK_KICK + (ASK_KICK_LEAD if lead else ASK_KICK_FEE)).replace("@num1@", str(fees[0])).replace("@num2@", str(fees[1]))
	_open_ask("kick", text.replace("@name@", str(brief.get("m_name", ""))), uuid, int(member.get("nTeamId", 0)), 0, fees)


func _open_post(uuid: String, post: int) -> void :
	var member: Dictionary = client.guild_members.get(uuid, {})
	if member.is_empty():
		return
	var brief: Dictionary = client.guild_briefs.get(uuid, {})
	var text: String = ""
	if not brief.is_empty():
		var nick: String = str(brief.get("m_name", ""))
		if post == POST_LEADER:
			text = ASK_LEADER.replace("@name@", nick)
		else:
			text = ASK_POST.replace("@name@", nick).replace("@title1@", str(POST_TITLES.get(post, "")))
	_open_ask("post", text, uuid, int(member.get("nTeamId", 0)), post, [0, 0])


func _can_kick(uuid: String) -> bool:
	var me: String = client.guild_self_uuid()
	if me.is_empty():
		return false
	var leader: String = str(client.guild.get("leaderUuid", ""))
	var vice: String = str(client.guild.get("viceLeaderUuid", ""))
	if me == leader:
		return true
	if me == vice and uuid != leader:
		return true
	var mine: int = _my_team()
	var theirs: int = int(client.guild_members.get(uuid, {}).get("nTeamId", -1))
	return str(_team(mine).get("leaderUuid", "")) == me and theirs == mine and not (uuid in [leader, vice])




func _confirm_ask() -> void :
	var kind: String = _ask_do
	var uuid: String = _ask_uuid
	var team: int = _ask_team
	var post: int = _ask_post
	var fees: Array = _ask_fees
	_close_dialog()
	if kind == "post":
		client.guild_change_post(uuid, post, team)
	elif kind == "leave":
		client.guild_leave()
	elif kind == "kick":
		var info: Dictionary = _team(team)
		if not _can_kick(uuid):
			say(NO_KICK)
		elif info.is_empty() or int(info.get("iCoin", 0)) < int(fees[1]):
			say(NO_TEAM_COIN)
		elif int(client.guild.get("iCoin", 0)) < int(fees[0]):
			say(NO_CORPS_COIN)
		else:
			client.guild_kickout(uuid, team)
	elif kind == "pve_on":
		var mine: Dictionary = _team(_my_team())
		if mine.is_empty():
			return
		if int(mine.get("iCoin", 0)) < int(fees[0]) + int(fees[1]):
			say(NO_PVE_COIN)
		else:
			client.guild_team_pve(true)
	elif kind == "pve_off":
		client.guild_team_pve(false)


func _confirm_choose() -> void :
	if _dlg_pick < 0 or _dlg_pick >= _dlg_rows.size():
		return
	var dest: int = int(_dlg_rows[_dlg_pick])
	if _count(dest) < TEAM_MAX:
		client.guild_move_member(_dlg_team, _dlg_uuid, dest, "")
		_close_dialog()
	else:
		_open_exchange(dest)


func _confirm_exchange() -> void :
	if _dlg_pick < 0 or _dlg_pick >= _dlg_rows.size():
		return
	var row: Dictionary = _dlg_rows[_dlg_pick]
	var target: String = str(row.get("charUuid", ""))
	if _in_cool(target):
		_say_cool(_cool_left(row))
		return
	client.guild_move_member(_dlg_team, _dlg_uuid, int(row.get("nTeamId", 0)), target)
	_close_dialog()


func _dialog_activate(id: String) -> void :
	if id.begins_with("dlg:row:"):
		_dlg_pick = int(id.substr(8))
	elif id.begins_with("cj:watch:"):
		var index: int = int(id.substr(9))
		_dlg_pick = index
		if index >= 0 and index < _dlg_rows.size():
			_open_team(int(_dlg_rows[index]))
	else:
		match id:
			"ask_ok":
				_confirm_ask()
			"rule_go":
				_confirm_rule()
			"lv_up":
				_level_up()
			"gift_get":
				_get_gift()
			"gift_item", "gift_got":
				pass
			"lv_give":
				donate_asked.emit(GUILD_DONATE)
			"ask_no", "dlg_close":
				_close_dialog()
			"dlg_ok":
				if _dialog == "cj":
					_confirm_choose()
				elif _dialog == "ex":
					_confirm_exchange()
			"dlg:up", "dlg:down":
				_dlg_scroll(-1 if id == "dlg:up" else 1)
			"dlg:pgup", "dlg:pgdn":
				var page: int = int(DLG_SHOWN.get(_dialog, 1))
				_dlg_scroll( - page if id == "dlg:pgup" else page)

func _dlg_most() -> int:
	return maxi(0, _dlg_rows.size() - int(DLG_SHOWN.get(_dialog, 1)))

func _dlg_scroll(step: int) -> void :
	_dlg_first = clampi(_dlg_first + step, 0, _dlg_most())


func _dlg_thumb(track: float) -> float:
	return maxf(20.0, track * float(DLG_SHOWN.get(_dialog, 1)) / float(maxi(1, _dlg_rows.size())))


func _dlg_drag(moved: float) -> void :
	var spec: Dictionary = Guild.DIALOGS.get(_dialog, {})
	var most: int = _dlg_most()
	if most <= 0 or spec.is_empty():
		return
	var track: float = float(spec["list"][3]) - 2.0 * BAR
	var step: float = maxf(0.001, (track - _dlg_thumb(track)) / float(most))
	_dlg_first = clampi(_dlg_grab_first + roundi(moved / _f / step), 0, most)


func _draw_dialog() -> void :
	_dlg_rect = Rect2()
	if _dialog == "ask" and not _ask_back.is_empty():
		var live: Dictionary = _stash()
		_unstash(_ask_back)
		_draw_list_dialog()
		_ask_back = _stash()
		_unstash(live)
		_dlg_rect = Rect2()
	elif _dialog in ["cj", "ex"]:
		_draw_list_dialog()
	elif _dialog == "rule":
		_draw_rule()
	elif _dialog == "lvup":
		_draw_level_up()
	elif _dialog == "gift":
		_draw_gift()
	elif _dialog == "skill":
		_draw_skill()
	if _tw_team != 0:
		_draw_team_window()
	if _dialog == "ask":
		_draw_ask()




func _draw_rule() -> void :
	var box: Array = GuildRule.BOX
	var at: Vector2 = _bare_window(float(box[0]), float(box[1]), "dlg_close")
	var spot: Dictionary = GuildRule.AT
	_fblit("gr_body", at + Vector2(float(spot["body"][0]), float(spot["body"][1])))
	var words: Dictionary = GuildRule.WORDS
	var title: Array = words["title"]
	_fwords(str(title[0]), ARIAL_BOLD, 16, Color.WHITE, "c", at + Vector2(float(title[1]) - 91.0, float(title[2]) - 1.0), 182, 1.5, 28.0)
	for key: String in ["mode", "time", "rule"]:
		var word: Array = words[key]
		_fwords(str(word[0]), ARIAL_BOLD, 13, Color.WHITE, "l", at + Vector2(float(word[1]), float(word[2]) - 3.0), 38, 1.0, 19.0)
	var texts: Dictionary = GuildRule.TEXTS
	for key: String in ["mode", "time"]:
		var cell: Array = spot[key]
		_fwords(str(texts[key]), ARIAL_BOLD, 13, Color.WHITE, "l", at + Vector2(float(cell[0]) + 10.0, float(cell[1]) + 5.0), 
			float(cell[2]) - 20.0, 0.0, float(cell[3]) - 10.0)
	var rule: Array = spot["rule"]
	var face: Font = _face(ARIAL)
	var lines: int = maxi(1, floori((float(rule[3]) - 8.0) * _f / face.get_height(maxi(6, roundi(12.0 * _f)))))
	_fpara(str(texts["rule"]), ARIAL, 12, Color.WHITE, at + Vector2(float(rule[0]) + 6.0, float(rule[1]) + 4.0), float(rule[2]) - 12.0, lines)
	_fbutton("rule_go", "gr_go", at + Vector2(float(spot["go"][0]), float(spot["go"][1])))




func _confirm_rule() -> void :
	_close_dialog()
	if client.state == "room":
		return
	if not client.guild.is_empty():
		var why: String = client.league_queue()
		if not why.is_empty():
			say(why)
	elif (int(client.character.get("actionFlag", 0)) & GUILD_FLAG) == 0:
		say(TIP_355)
	else:
		say(TIP_70)




func _draw_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.4))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(450.0, 220.0) + (Vector2(-9, -9) if _ask_do == "leave" else Vector2.ZERO)
	_hit("panel", Rect2(at * _f, Vector2(450, 220) * _f), false)
	var panel: Array = Guild.ASK["panel"]
	_fblit("gu_ask", at + Vector2(float(panel[0]), float(panel[1])))
	_fblit("gu_ask_guy", at + Vector2(-80, -76))
	var words: Array = Guild.ASK["txtContent"]
	_fpara(_ask_text, ARIAL_BOLD, float(words[4]), Color.WHITE, at + Vector2(float(words[0]), float(words[1])), float(words[2]), 5)
	var ok: Array = Guild.ASK["btnConfirm"]
	var no: Array = Guild.ASK["btnCancel"]
	_fbutton("ask_ok", "gu_ask_ok", at + Vector2(float(ok[0]), float(ok[1])))
	_fbutton("ask_no", "gu_ask_no", at + Vector2(float(no[0]), float(no[1])))



func _draw_list_dialog() -> void :
	var spec: Dictionary = Guild.DIALOGS[_dialog]
	var box: Array = spec["size"]
	var at: Vector2 = _bare_window(float(box[0]), float(box[1]), "dlg_close")
	if spec.has("bed"):
		_fblit("public_window_button_bk", at + Vector2(float(spec["bed"][0]), float(spec["bed"][1])))
	_fblit("gu_" + _dialog, at + Vector2(float(spec["panel"][0]), float(spec["panel"][1])))
	var list: Array = spec["list"]
	var origin: Vector2 = at + Vector2(float(list[0]), float(list[1]))
	var wide: float = float(list[2]) - BAR
	var high: float = float(list[3])
	_dlg_rect = Rect2(origin * _f, Vector2(float(list[2]), high) * _f)
	var count: int = _dlg_rows.size()
	var shown: int = int(DLG_SHOWN[_dialog])
	_dlg_first = clampi(_dlg_first, 0, maxi(0, count - shown))
	for slot in range(ceili(high / DLG_ROW)):
		var index: int = _dlg_first + slot
		if index >= count:
			break
		var top: float = DLG_ROW * slot
		var room: float = minf(DLG_ROW, high - top)
		var spot: Vector2 = origin + Vector2(0, top)
		_hit("dlg:row:%d" % index, Rect2(spot * _f, Vector2(wide, room) * _f), false)
		if _dialog == "cj":
			_draw_team_row(int(_dlg_rows[index]), spot, room, index == _dlg_pick, index)
		else:
			_draw_member_row(_dlg_rows[index], spot, room, index == _dlg_pick)
	_dlg_bar(origin + Vector2(wide, 0), high, count, shown)
	_fbutton("dlg_ok", "gu_dlg_ok", at + Vector2(float(spec["ok"][0]), float(spec["ok"][1])))



func _draw_team_row(id: int, at: Vector2, room: float, picked: bool, index: int) -> void :
	if picked and room >= 29.0:
		_fround(Rect2(at + Vector2(1, 1), Vector2(400, 28)), Color(0, 0, 0, 0), 5.0, PICK, 3.0)
	if room >= 20.0:
		var team: Dictionary = _team(id)
		var count: int = _count(id)
		var leader: Dictionary = client.guild_briefs.get(str(team.get("leaderUuid", "")), {})
		var cols: Array = [["Lv %d" % int(team.get("nLevel", 0)), 0.0, 4.0, 44.0, 14.0], [str(team.get("strName", "")), 44.0, 5.0, 120.0, 12.0], 
			[str(leader.get("m_name", "")), 164.0, 5.0, 110.0, 12.0], ["%d/%d" % [count, maxi(count, TEAM_MAX)], 274.0, 5.0, 50.0, 12.0]]
		for col: Array in cols:
			_fwords(_cut(str(col[0]), ARIAL_BOLD, float(col[4]), float(col[3])), ARIAL_BOLD, float(col[4]), Color.WHITE, "c", 
				at + Vector2(float(col[1]), float(col[2])), float(col[3]), 0.0, 0.0, false)
	if room >= 26.0:
		_fbutton("cj:watch:%d" % index, "gu_cj_watch", at + Vector2(340, 4))
	if room >= 32.0:
		_fblit("gu_cj_line", at + Vector2(0, 30))


func _draw_member_row(row: Dictionary, at: Vector2, room: float, picked: bool) -> void :
	if picked and room >= 30.0:
		_fround(Rect2(at, Vector2(329, 30)), Color(0, 0, 0, 0), 5.0, PICK, 3.0)
	if room >= 26.0:
		var brief: Dictionary = client.guild_briefs.get(str(row.get("charUuid", "")), {})
		var nick: String = EX_NAME
		var sex: String = EX_SEX
		if not brief.is_empty():
			_fblit("level_%d" % clampi(int(brief.get("m_level", 0)), 0, 40), at + Vector2(21, 6), 40.0, 20.0)
			_level_fx(int(brief.get("m_level", 0)), at + Vector2(21, 6), 40.0)
			nick = str(brief.get("m_name", ""))
			sex = str(SEXES.get(int(brief.get("m_sex", 0)), ""))
		_fwords(_cut(nick, ARIAL_BOLD, 12, 90), ARIAL_BOLD, 12, Color.WHITE, "l", at + Vector2(120, 8), 90, 0.0, 0.0, false)
		_fwords(_cut(sex, ARIAL_BOLD, 12, 30), ARIAL_BOLD, 12, Color.WHITE, "l", at + Vector2(277, 8), 30, 0.0, 0.0, false)
	if room >= 32.0:
		_fpart("gu_ex_line", at + Vector2(0, 30), Rect2(0, 0, 337, 2))


func _dlg_bar(bar: Vector2, high: float, count: int, shown: int) -> void :
	_vbar("dlg", bar, high, count, shown, _dlg_first)


func _vbar(key: String, bar: Vector2, high: float, count: int, shown: int, first: int) -> void :
	var track: float = high - 2.0 * BAR
	_fblit("gu_sb_bk", bar + Vector2(0, BAR), BAR, track)
	_fbutton(key + ":up", "gu_sb_up", bar)
	_fbutton(key + ":down", "gu_sb_down", bar + Vector2(0, high - BAR))
	var most: int = maxi(0, count - shown)
	if most <= 0:
		return
	var thumb: float = maxf(20.0, track * float(shown) / float(maxi(1, count)))
	var top: float = BAR + roundf((track - thumb) * float(first) / float(most))
	if top > BAR:
		_hit(key + ":pgup", Rect2((bar + Vector2(0, BAR)) * _f, Vector2(BAR, top - BAR) * _f), false)
	if top + thumb < BAR + track:
		_hit(key + ":pgdn", Rect2((bar + Vector2(0, top + thumb)) * _f, Vector2(BAR, BAR + track - top - thumb) * _f), false)
	_fslice("gu_sb_thumb", bar + Vector2(0, top), thumb, 4.0, _glow("slide:" + key))
	_hit("slide:" + key, Rect2((bar + Vector2(0, top)) * _f, Vector2(BAR, thumb) * _f), false)




func _stash() -> Dictionary:
	return {"dialog": _dialog, "uuid": _dlg_uuid, "team": _dlg_team, "dest": _dlg_dest, "rows": _dlg_rows.duplicate(), "pick": _dlg_pick, 
		"first": _dlg_first}

func _unstash(saved: Dictionary) -> void :
	_dialog = str(saved.get("dialog", ""))
	_dlg_uuid = str(saved.get("uuid", ""))
	_dlg_team = int(saved.get("team", 0))
	_dlg_dest = int(saved.get("dest", 0))
	_dlg_rows = (saved.get("rows", []) as Array).duplicate()
	_dlg_pick = int(saved.get("pick", 0))
	_dlg_first = int(saved.get("first", 0))


func _open_team(id: int) -> void :
	if client == null or _tw_team != 0 or id == 0 or _team(id).is_empty():
		return
	_hide_menu()
	_tw_close()
	_tw_team = id
	if pack != null:
		pack.load_board()
	_tw_seen = _tw_members()
	_tw_refresh()



func _tw_refresh() -> void :
	var team: Dictionary = _team(_tw_team)
	if team.is_empty():
		return
	_tw_sig = team.hash()
	_tw_flag = int(team.get("nExtFlag", 0))
	var me: String = client.guild_self_uuid()
	var mine: Dictionary = client.guild_members.get(me, {}) if not me.is_empty() else {}
	if not mine.is_empty():
		var chief: bool = me in [str(client.guild.get("leaderUuid", "")), str(client.guild.get("viceLeaderUuid", ""))]
		if me == str(team.get("leaderUuid", "")):
			_tw_state = "captain"
		elif int(mine.get("nTeamId", 0)) == _tw_team:
			_tw_state = "teammateAndLeader" if chief else "teammate"
		else:
			_tw_state = "leader" if chief else "visit"
		_tw_rename = (GuildTeam.BUTTONS.get(_tw_state, {}) as Dictionary).has("btnRename") or chief
	var title: String = str(team.get("strName", ""))
	var values: Dictionary = {"lblClanName": title, "txtClanName": title, "lblLevel": str(int(team.get("nLevel", 0))), 
		"lblHonor": str(int(team.get("iGlory", 0))), "lblTeamFund": str(int(team.get("iCoin", 0))), 
		"lblTeamCoutribute": str(int(team.get("iMerit", 0))), "txtClanLeader": str(_tw_values.get("txtClanLeader", "")), 
		"lblMaintenance": str(_tw_values.get("lblMaintenance", "")), "tip": str(_tw_values.get("tip", ""))}
	var leader: Dictionary = client.guild_briefs.get(str(team.get("leaderUuid", "")), {})
	if not leader.is_empty():
		values["txtClanLeader"] = str(leader.get("m_name", ""))
	var keep: Array = GuildTeam.KEEP.get(str(int(team.get("nLevel", 0))), [])
	if not keep.is_empty():
		var fee: int = int(keep[1]) + (int(keep[2]) if (_tw_flag & 1) != 0 else 0)
		values["lblMaintenance"] = str(GuildTeam.WORDS["maint"]).replace("@num1@", str(fee))
		values["tip"] = str(GuildTeam.WORDS["level_tip"]).replace("@num1@", str(int(keep[0]))) if int(keep[0]) > 0 else str(GuildTeam.WORDS["full_lv"])
	_tw_values = values
	_tw_request()


func _tw_request() -> void :
	_tw_asked = _tw_team
	var url: String = str(client.config.origin) + "/cTeamMember.php?tid=%d&noCache=%d" % [_tw_team, randi() % 1000000]
	if fetch.is_valid():
		fetch.call(url)
		return
	if _tw_http == null:
		return
	_tw_http.cancel_request()
	_tw_http.request(url, AppSession.headers(url))


func _tw_on_query(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	if _tw_team == 0 or _tw_asked != _tw_team or result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty():
		return
	var json: JSON = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return
	var parsed: Variant = json.data
	var items: Array = []
	if parsed is Array:
		items = parsed
	elif parsed is Dictionary:
		items = (parsed as Dictionary).values()
	else:
		return
	var rows: Array = []
	for item: Variant in items:
		if not (item is Dictionary):
			continue
		var data: Dictionary = item
		rows.append({"charUuid": _tw_text(data.get("char_uuid")), "charName": _tw_text(data.get("char_name")), 
			"charLevel": int(_tw_num(data.get("char_level"))), "charOid": int(_tw_num(data.get("char_oid"))), 
			"post": int(_tw_num(data.get("team_post"))), "clanName": _tw_text(data.get("team_name")), "elo": int(_tw_num(data.get("char_elo"))), 
			"merit": int(_tw_num(data.get("team_merit"))), "vipEndTime": _tw_num(data.get("char_viptime")), 
			"superVipEndTime": _tw_num(data.get("char_superviptime")), "vipPoints": int(_tw_num(data.get("char_vippoints"))), 
			"sectionId": int(_tw_num(data.get("elo_section_id")))})
	if rows.is_empty():
		return
	_tw_rows = rows
	_tw_pick = 0
	_tw_first = 0
	_tw_me0 = (client.guild_members.get(client.guild_self_uuid(), {}) as Dictionary).hash()

static func _tw_num(value: Variant) -> float:
	if value is float or value is int:
		return float(value)
	if value is String and (value as String).is_valid_float():
		return float(value)
	return 0.0

static func _tw_text(value: Variant) -> String:
	if value == null:
		return ""
	if value is float and is_equal_approx(value, roundf(value)):
		return str(int(value))
	return str(value)


func _tw_members() -> Array:
	var found: Array = []
	for uuid: String in client.guild_members:
		if int(client.guild_members[uuid].get("nTeamId", 0)) == _tw_team:
			found.append(uuid)
	return found


func _tw_tick() -> void :
	var team: Dictionary = _team(_tw_team)
	if not team.is_empty() and team.hash() != _tw_sig:
		_tw_refresh()
	var gone: Array = _tw_seen.filter( func(uuid: String) -> bool: return not client.guild_members.has(uuid))
	if not gone.is_empty():
		_tw_rows = _tw_rows.filter( func(row: Dictionary) -> bool: return not (str(row.get("charUuid", "")) in gone))
		_tw_pick = 0
		_tw_first = 0
	_tw_seen = _tw_members()

func _tw_close() -> void :
	_tw_team = 0
	_tw_asked = 0
	_tw_sig = 0
	_tw_state = "visit"
	_tw_rename = false
	_tw_flag = 0
	_tw_values = {}
	_tw_rows = []
	_tw_pick = 0
	_tw_first = 0
	_tw_rect = Rect2()
	_tw_grab = false
	_tw_seen = []
	_tw_me0 = 0
	if _tw_http != null:
		_tw_http.cancel_request()

func _tw_scroll(step: int) -> void :
	_tw_first = clampi(_tw_first + step, 0, maxi(0, _tw_rows.size() - TW_SHOWN))


func _tw_drag(moved: float) -> void :
	var most: int = maxi(0, _tw_rows.size() - TW_SHOWN)
	if most <= 0:
		return
	var track: float = float(GuildTeam.LIST[3]) - 2.0 * BAR
	var thumb: float = maxf(20.0, track * float(TW_SHOWN) / float(maxi(1, _tw_rows.size())))
	var step: float = maxf(0.001, (track - thumb) / float(most))
	_tw_first = clampi(_tw_grab_first + roundi(moved / _f / step), 0, most)


func _tw_vip(row: Dictionary) -> int:
	var now: float = Time.get_unix_time_from_system()
	var over: float = float(row.get("vipEndTime", 0.0))
	var super_over: float = float(row.get("superVipEndTime", 0.0))
	if over > 100000000000.0:
		over /= 1000.0
	if super_over > 100000000000.0:
		super_over /= 1000.0
	if over - now <= 0.0:
		return 0
	return _vip_level(int(row.get("vipPoints", 0))) + (100 if super_over > now else 0)


func _tw_activate(id: String) -> void :
	if id.begins_with("tw:row:"):
		var index: int = int(id.substr(7))
		if index >= 0 and index < _tw_rows.size():
			_tw_pick = index
		return
	match id:
		"tw_close", "tw_ok":
			_tw_close()
		"tw_rename":
			_tw_rename_click()
		"tw_kick":
			_tw_kick()
		"tw_give":
			donate_asked.emit(TEAM_DONATE)
		"tw_enter":
			_tw_enter()
		"tw_switch":
			_tw_switch()
		"tw:up", "tw:down":
			_tw_scroll(-1 if id == "tw:up" else 1)
		"tw:pgup", "tw:pgdn":
			_tw_scroll( - TW_SHOWN if id == "tw:pgup" else TW_SHOWN)



func _tw_enter() -> void :
	if (_tw_flag & 1) == 0 or not GuildTeam.BUTTONS.get(_tw_state, {}).has("btnInstanceEnterance"):
		return
	var word: String = client.team_pve_enter()
	if not word.is_empty():
		say(word)




func _tw_switch() -> void :
	var info: Dictionary = _team(_tw_team)
	if info.is_empty() or not GuildTeam.BUTTONS.get(_tw_state, {}).has("btnInstanceSwitch"):
		return
	var closing: bool = _tw_flag != 0 and (_tw_flag & 2) == 0
	var keep: Array = GuildTeam.KEEP.get(str(int(info.get("nLevel", 0))), [])
	if not closing and keep.is_empty():
		return
	var back: Dictionary = _stash() if _dialog in ["cj", "ex"] else {}
	if closing:
		_open_ask("pve_off", ASK_PVE_OFF, "", _tw_team, 0, [0, 0])
	else:
		_open_ask("pve_on", ASK_PVE_ON.replace("@num1@", str(int(keep[2]))), "", _tw_team, 0, [int(keep[1]), int(keep[2])])
	_ask_back = back


func _tw_rename_click() -> void :
	var mine: Dictionary = client.guild_members.get(client.guild_self_uuid(), {})
	if mine.is_empty():
		return
	if int(mine.get("nTeamId", 0)) == _tw_team:
		_open_rename(BagRename.SELF_TEAM_RENAME)
	else:
		_open_rename(BagRename.TEAM_RENAME, _tw_team)


func _tw_kick() -> void :
	if _tw_pick < 0 or _tw_pick >= _tw_rows.size():
		return
	var uuid: String = str((_tw_rows[_tw_pick] as Dictionary).get("charUuid", ""))
	if uuid.is_empty() or uuid == client.guild_self_uuid():
		return
	var back: Dictionary = _stash() if _dialog in ["cj", "ex"] else {}
	_open_kick(uuid)
	if _dialog == "ask":
		_ask_back = back


func _open_rename(kind: int, team: int = 0) -> void :
	if _rename == null:
		_rename = BagRename.new()
		_rename.client = client
		_rename.pack = pack
		_rename.hall = hall
		add_child(_rename)
		_rename.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_rename.quick_buy_asked.connect( func(tid: int) -> void : quick_buy_asked.emit(tid))
		_rename.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
	_rename.hall = hall
	_hide_menu()
	_hover = ""
	_press = ""
	_rename.open(kind, team)

func chat_busy() -> bool:
	return super () or _popped()


func _popped() -> bool:
	return (_rename != null and _rename.visible) or (_create != null and _create.visible) or (_appoint != null and _appoint.visible)\
	or (_recruit != null and _recruit.visible) or (_found != null and _found.visible) or (_find != null and _find.visible)\
	or (_watch != null and _watch.visible)


func _appoint_click() -> void :
	if _appoint == null:
		_appoint = Appoint.new()
		_appoint.client = client
		_appoint.pack = pack
		_appoint.hall = hall
		add_child(_appoint)
		_appoint.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_appoint.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
	if _appoint.visible:
		return
	_appoint.hall = hall
	_hide_menu()
	_hover = ""
	_press = ""
	_appoint.open()


func _recruit_click() -> void :
	if _recruit == null:
		_recruit = Recruit.new()
		_recruit.client = client
		_recruit.pack = pack
		_recruit.hall = hall
		add_child(_recruit)
		_recruit.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_recruit.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
		_recruit.watch_asked.connect( func(uuid: String) -> void : player_info_asked.emit(uuid))
	if _recruit.visible:
		return
	_recruit.hall = hall
	_hide_menu()
	_hover = ""
	_press = ""
	_recruit.open()


func _create_team_click() -> void :
	var row: Array = _level_row(int(client.guild.get("nLevel", 0)))
	if row.is_empty():
		return
	if client.guild_teams.size() >= int(row[1]):
		say(TEAMS_MAX)
		return
	if _create == null:
		_create = CreateTeam.new()
		_create.client = client
		_create.pack = pack
		_create.hall = hall
		add_child(_create)
		_create.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_create.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
	_create.hall = hall
	_hide_menu()
	_hover = ""
	_press = ""
	_create.open()



func _draw_team_window() -> void :
	var box: Array = GuildTeam.BOX
	var at: Vector2 = _bare_window(float(box[0]), float(box[1]), "tw_close")
	var body: Array = GuildTeam.BODY.get(_tw_state, GuildTeam.BODY["visit"])
	_fblit(str(body[2]), at + Vector2(float(body[0]), float(body[1])))
	var texts: Dictionary = GuildTeam.TEXTS
	var head: Array = texts["lblClanName"]
	_fwords(_cut(str(_tw_values.get("lblClanName", "")), ARIAL_BOLD, 17, float(head[2])), ARIAL_BOLD, 17, Color.WHITE, "c", 
		at + Vector2(float(head[0]), float(head[1])), float(head[2]), 2.0, 0.0, false, Color("737372", 0.8))
	for key: String in TW_FIELDS:
		var cell: Array = texts[key]
		var room: float = float(cell[2]) - 24.0
		_fwords(_clip(str(_tw_values.get(key, "")), ARIAL_BOLD, 13, room), ARIAL_BOLD, 13, Color.WHITE, str(cell[7]), 
			at + Vector2(float(cell[0]) + 12.0, float(cell[1]) + 5.0), room, 0.0, 0.0, false)
	var buttons: Dictionary = GuildTeam.BUTTONS.get(_tw_state, {})
	for key: String in TW_BUTTONS:
		var spot: Array = buttons.get(key, [])
		if key == "btnRename":
			if not _tw_rename:
				continue
			if spot.is_empty():
				spot = GuildTeam.BUTTONS["captain"]["btnRename"]
		elif spot.is_empty():
			continue
		var place: Vector2 = at + Vector2(float(spot[0]), float(spot[1]))
		if key == "btnInstanceEnterance":
			if (_tw_flag & 1) != 0:
				_fbutton("tw_enter", "gt_enter", place)
			else:
				_fblit("gt_enter_off", place)
		elif key == "btnInstanceSwitch":
			_fbutton("tw_switch", "gt_switch_on" if _tw_flag != 0 and (_tw_flag & 2) == 0 else "gt_switch_off", place)
		else:
			_fbutton(str(TW_BUTTONS[key][0]), str(TW_BUTTONS[key][1]), place)
	var tip: Array = GuildTeam.AT["tip"]
	var tip_rect: Rect2 = Rect2((at + Vector2(float(tip[0]), float(tip[1]))) * _f, Vector2(float(tip[2]), float(tip[3])) * _f)
	_hit("tw_tip", tip_rect, false)
	var ok: Array = GuildTeam.AT["ok"]
	_fbutton("tw_ok", "gt_ok", at + Vector2(float(ok[0]), float(ok[1])))
	_draw_team_list(at)
	if _hover == "tw_tip" and _press.is_empty() and _tip_ok():
		_draw_team_tip(tip_rect, str(_tw_values.get("tip", "")))


func _draw_team_list(at: Vector2) -> void :
	var list: Array = GuildTeam.LIST
	var origin: Vector2 = at + Vector2(float(list[0]), float(list[1]))
	var high: float = float(list[3])
	_tw_rect = Rect2(origin * _f, Vector2(float(list[2]), high) * _f)
	var count: int = _tw_rows.size()
	_tw_first = clampi(_tw_first, 0, maxi(0, count - TW_SHOWN))
	var me: String = client.guild_self_uuid()
	var mine: Dictionary = client.guild_members.get(me, {}) if not me.is_empty() else {}
	for slot in range(mini(TW_SHOWN, count - _tw_first)):
		var index: int = _tw_first + slot
		var spot: Vector2 = origin + Vector2(0, TW_ROW * slot)
		_hit("tw:row:%d" % index, Rect2(spot * _f, Vector2(TW_ROW_W, TW_ROW) * _f), false)
		_draw_team_member(_tw_rows[index], spot, index == _tw_pick, me, mine)
	_vbar("tw", origin + Vector2(TW_ROW_W, 0), high, count, TW_SHOWN, _tw_first)



func _draw_team_member(row: Dictionary, at: Vector2, picked: bool, me: String, mine: Dictionary) -> void :
	if picked:
		_fround(Rect2(at + Vector2(0, -1), Vector2(314, 30)), Color(0, 0, 0, 0), 5.0, PICK, 3.0)
	_fblit("level_%d" % clampi(int(row.get("charLevel", 0)), 0, 40), at + Vector2(5, 5), 40.0, 20.0)
	_level_fx(int(row.get("charLevel", 0)), at + Vector2(5, 5), 40.0)
	var cols: Dictionary = GuildTeam.COLS
	var nick: String = str(row.get("charName", ""))
	var spec: Array = cols["lblPlayerName"]
	var shown: String = _cut(nick, ARIAL_BOLD, 12, float(spec[2]))
	var style: Array = name_style(clampi(_tw_vip(row) % 100, 0, 12))
	var ink: PackedColorArray = NameStyles.colors_of(client, 0, nick)
	if not ink.is_empty():
		NameStyles.place(self, shown, ARIAL_BOLD, 12, "l", at + Vector2(float(spec[0]), 0), float(spec[2]), 1.0, TW_ROW, false, 
			NameStyles.tints(ink, nick.length()), true)
		style = [Color(0, 0, 0, 0), Color(0, 0, 0, 0)]
	_fwords(shown, ARIAL_BOLD, 12, style[0], "l", at + Vector2(float(spec[0]), 0), float(spec[2]), 1.0, TW_ROW, false, style[1])
	var section: int = int(row.get("sectionId", 0))
	var virtue: String = str(GuildTeam.WORDS["no_section"])
	if section > 0:
		var entry: Array = []
		if pack != null:
			entry = pack.board.get("sections", {}).get(str(section), [])
		virtue = str(entry[0]) if entry.size() > 0 else section_name(section)
		var icon: Texture2D = pack.picture("l/bxh/s%d.webp" % (int(entry[1]) if entry.size() > 1 else medal(section))) if pack != null else null
		if icon != null and icon.get_width() > 4:
			draw_texture_rect(icon, Rect2((at + Vector2(126, 2)) * _f, Vector2(icon.get_width(), icon.get_height()) * 0.125 * _f), false)
	var uuid: String = str(row.get("charUuid", ""))
	var words: Array = [["lblVirtue", virtue], ["lblMerit", str(_tw_merit(row, me, mine))], ["lblPost", _post(uuid)]]
	for word: Array in words:
		var cell: Array = cols[str(word[0])]
		_fwords(_cut(str(word[1]), ARIAL_BOLD, 12, float(cell[2])), ARIAL_BOLD, 12, Color.WHITE, str(cell[7]), at + Vector2(float(cell[0]), 0), 
			float(cell[2]), 0.0, TW_ROW, false)


func _tw_merit(row: Dictionary, me: String, mine: Dictionary) -> int:
	var oid: int = int(row.get("charOid", 0))
	var own: bool = ( not me.is_empty() and str(row.get("charUuid", "")) == me) or (oid != 0 and oid == client.account_id)
	if own and not mine.is_empty() and mine.hash() != _tw_me0:
		return int(mine.get("iMerit", 0))
	return int(row.get("merit", 0))


func _draw_team_tip(anchor: Rect2, body: String) -> void :
	if body.is_empty():
		return
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var high: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f + 16.0
	var spot: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if spot.x + wide > _fw:
		spot.x = anchor.position.x / _f - 6.0 - wide
	spot.y = clampf(spot.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(spot * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_tip_mark(Rect2(spot * _f, Vector2(wide, high) * _f))
	_fpara(body, REGULAR, 12.0, Color.WHITE, spot + Vector2(10, 6), wide - 20.0, 8)




func _can_notice() -> bool:
	if client.guild.is_empty():
		return false
	for button: Array in Guild.BUTTONS.get(_state(), []):
		if str(button[0]) == "btnSetNotice":
			return true
	return false


func _begin_notice() -> void :
	if not _can_notice():
		return
	_noting = true
	_notice_was = str(client.guild.get("strNotice", ""))
	_notice_fill(_notice_was)
	_notice.visible = true
	_notice.grab_focus()



func _sure_notice() -> void :
	if not _noting:
		return
	var old: String = str(client.guild.get("strNotice", ""))
	var text: String = _notice.text.replace("\r", "").replace("\n", "").strip_edges()
	_end_notice()
	if old != text:
		client.guild_set_notice(text)

func _end_notice() -> void :
	_noting = false
	if _notice != null:
		_notice.release_focus()
		_notice.visible = false


func _notice_fill(text: String) -> void :
	_notice.text = text
	_notice_prev = text
	_notice.set_caret_line(_notice.get_line_count() - 1)
	_notice.set_caret_column(_notice.get_line(_notice.get_line_count() - 1).length())


func _notice_tick() -> void :
	var now: String = str(client.guild.get("strNotice", ""))
	if now != _notice_was:
		_notice_was = now
		if _noting:
			_notice_fill(now)
	if _noting and not _can_notice():
		_end_notice()


func _notice_covered() -> bool:
	return not _dialog.is_empty() or _tw_team != 0 or not _menu_uuid.is_empty() or not _viewing.is_empty() or _popped()


func _place_notice(frame: Vector2) -> void :
	var shown: bool = _noting and not _notice_covered()
	if _notice.visible != shown:
		_notice.visible = shown
	if not shown:
		return
	var rect: Array = GuildManage.NOTICE["rect"]
	var pad: Array = GuildManage.NOTICE["pad"]
	_notice.position = (frame + Vector2(float(rect[0]), float(rect[1]))) * _f
	_notice.size = Vector2(float(rect[2]), float(rect[3])) * _f
	var px: int = maxi(6, roundi(float(GuildManage.NOTICE["px"]) * _f))
	if _notice.get_theme_font_size("font_size") != px:
		_notice.add_theme_font_size_override("font_size", px)
	var margins: Array = [(float(pad[0]) + 2.0) * _f, (float(pad[2]) + 2.0) * _f, (float(pad[1]) + 2.0) * _f, (float(pad[3]) + 2.0) * _f]
	if not is_equal_approx(_notice_box.content_margin_left, margins[0]) or not is_equal_approx(_notice_box.content_margin_top, margins[1]):
		_notice_box.content_margin_left = margins[0]
		_notice_box.content_margin_top = margins[1]
		_notice_box.content_margin_right = margins[2]
		_notice_box.content_margin_bottom = margins[3]


func _notice_cap() -> void :
	var most: int = int(GuildManage.NOTICE["max"])
	var now: String = _notice.text
	if now.length() <= most or now.length() <= _notice_prev.length():
		_notice_prev = now
		return
	var head: int = 0
	var limit: int = mini(now.length(), _notice_prev.length())
	while head < limit and now[head] == _notice_prev[head]:
		head += 1
	var tail: int = 0
	while tail < limit - head and now[now.length() - 1 - tail] == _notice_prev[_notice_prev.length() - 1 - tail]:
		tail += 1
	var added: String = now.substr(head, now.length() - head - tail)
	var room: int = maxi(0, most - (now.length() - added.length()))
	var kept: String = now.left(head) + added.left(room) + now.right(tail)
	var caret: int = head + mini(room, added.length())
	_notice_prev = kept
	_notice.text = kept
	var before: String = kept.left(mini(caret, kept.length()))
	var line: int = before.count("\n")
	_notice.set_caret_line(line)
	_notice.set_caret_column(before.length() - (before.rfind("\n") + 1))


func _notice_key(event: InputEvent) -> void :
	if event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		_notice.accept_event()
		_sure_notice()




func _level_row(level: int) -> Array:
	return GuildManage.LEVELS.get(str(level), [])



func _open_level_up() -> void :
	var row: Array = _level_row(int(client.guild.get("nLevel", 0)))
	if row.is_empty() or int(row[0]) == 0:
		say(str(GuildManage.FULL))
		return
	if _dialog == "lvup":
		return
	_close_dialog()
	_dialog = "lvup"



func _level_up() -> void :
	var row: Array = _level_row(int(client.guild.get("nLevel", 0)))
	if row.is_empty():
		return
	if int(client.guild.get("iCoin", 0)) < int(row[0]):
		say(NO_CORPS_COIN)
		return
	client.guild_upgrade()
	_close_dialog()



func _level_texts() -> Dictionary:
	var level: int = int(client.guild.get("nLevel", 0))
	var row: Array = _level_row(level)
	if row.is_empty():
		return {}
	var money: int = int(client.guild.get("iCoin", 0))
	return {"level": str(level), "cost": str(int(row[0])), "money": str(money), "low": money < int(row[0])}




func _draw_level_up() -> void :
	var spec: Dictionary = GuildManage.LV
	var box: Array = spec["box"]
	var at: Vector2 = _bare_window(float(box[0]), float(box[1]), "dlg_close")
	var body: Array = spec["body"]
	_fblit("gm_lv_body", at + Vector2(float(body[0]), float(body[1])))
	var words: Dictionary = GuildManage.LV_WORDS
	var title: Array = words["title"]
	_fwords(str(title[0]), ARIAL_BOLD, 16, Color.WHITE, "c", at + Vector2(float(title[1]) - 91.0, float(title[2])), 182, 1.5, 28.0)
	for key: String in ["txtCurrentLevel", "txtCostMoney", "txtCurrentMoney"]:
		var word: Array = words[key]
		_fwords(str(word[0]), ARIAL_BOLD, 13, Color.WHITE, "r", at + Vector2(float(word[1]) - 140.0, float(word[2]) - 10.0), 140, 1.0, 20.0)
	var values: Dictionary = _level_texts()
	var pad: Array = spec["pad"]
	for key: String in values:
		if key == "low":
			continue
		var cell: Array = spec[key]
		var tint: Color = Color(str(spec["low"])) if key == "money" and bool(values["low"]) else Color.WHITE
		_fwords(str(values[key]), ARIAL_BOLD, float(spec["px"]), tint, "l", at + Vector2(float(cell[0]) + float(pad[0]), float(cell[1]) + float(pad[1])), 
			float(cell[2]) - 2.0 * float(pad[0]), 0.0, float(cell[3]) - 2.0 * float(pad[1]), false)
	var give: Array = spec["give"]
	var up: Array = spec["up"]
	_fbutton("lv_give", "gm_lv_give", at + Vector2(float(give[0]), float(give[1])))
	_fbutton("lv_up", "gm_lv_up", at + Vector2(float(up[0]), float(up[1])))





func _can_gift() -> bool:
	var bias: int = int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	var last: Dictionary = Time.get_date_dict_from_unix_time(int(client.guild_gift_time) + bias)
	var today: Dictionary = Time.get_date_dict_from_unix_time(int(Time.get_unix_time_from_system()) + bias)
	return int(last.year) != int(today.year) or int(last.month) != int(today.month) or int(last.day) != int(today.day)


func _open_gift() -> void :
	if not _can_gift() or _dialog == "gift":
		return
	_close_dialog()
	_dialog = "gift"
	if pack != null:
		pack.load_bag()



func _get_gift() -> void :
	if not _can_gift():
		return
	var row: Array = _level_row(int(client.guild.get("nLevel", 0)))
	if row.is_empty():
		return
	var member: Dictionary = client.guild_members.get(_me, {}) if not _me.is_empty() else {}
	if member.is_empty():
		return
	if int(row[3]) > int(member.get("iMerit", 0)):
		say(str(GuildManage.GIFT_TEXT["few"]))
		return
	client.guild_gift()



func _gift_item() -> Array:
	var row: Array = _level_row(int(client.guild.get("nLevel", 0)))
	if row.is_empty() or pack == null:
		return []
	var id: String = str(int(row[2]))
	var item: Array = pack.bag.get("items", {}).get(id, [])
	if item.size() >= 4:
		return [str(item[0]), str(item[1]), str(item[2]), int(item[3])]
	var more: Array = pack.bag.get("more", {}).get(id, [])
	return [str(more[0]), "", str(more[1]), int(more[2])] if more.size() >= 3 else []


func _gift_cost() -> String:
	var row: Array = _level_row(int(client.guild.get("nLevel", 0)))
	return str(GuildManage.GIFT_TEXT["cost"]).replace("@num1@", str(int(row[3]))) if not row.is_empty() else ""




func _draw_gift() -> void :
	var spec: Dictionary = GuildManage.GIFT
	var box: Array = spec["box"]
	var at: Vector2 = _bare_window(float(box[0]), float(box[1]), "dlg_close")
	var body: Array = spec["body"]
	_fblit("gm_gift_body", at + Vector2(float(body[0]), float(body[1])))
	var item: Array = _gift_item()
	var cell: Array = spec["item"]
	var rect: Rect2 = Rect2((at + Vector2(float(cell[0]), float(cell[1]))) * _f, Vector2(float(cell[2]), float(cell[3])) * _f)
	var icon: Texture2D = pack.picture("l/it/%s.webp" % str(item[2])) if not item.is_empty() and not str(item[2]).is_empty() else null
	if icon != null:
		draw_texture_rect(icon, rect, false)
	_hit("gift_item", rect, false)
	var can: bool = _can_gift()
	if not can:

		var got: Array = spec["got"]
		_hit("gift_got", _fblit("gm_gift_got", at + Vector2(float(got[0]), float(got[1]))), false)
	var cost: Array = spec["cost"]
	_fwords(_gift_cost(), ARIAL_BOLD, float(spec["px"]), Color(str(spec["color"])), "c", at + Vector2(float(cost[0]), float(cost[1])), float(cost[2]), 
		0.0, 0.0, false)
	var take: Array = spec["get"]
	if can:
		_fbutton("gift_get", "gm_gift_get", at + Vector2(float(take[0]), float(take[1])))
	else:
		_fblit("gm_gift_get_off", at + Vector2(float(take[0]), float(take[1])))
	if _hover == "gift_item" and not item.is_empty():
		_draw_gift_tip(rect, item)



func _draw_gift_tip(anchor: Rect2, item: Array) -> void :
	var wide: float = 220.0
	var body: String = str(item[1])
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 10).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_tip_mark(Rect2(at * _f, Vector2(wide, high) * _f))
	_fwords(str(item[0]), ARIAL_BOLD, 13.0, BagModel.tint(int(item[3]), Color.WHITE), "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, ARIAL, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 10)



const SK_ROW: float = 94.0
const SK_SHOWN: int = 3
const SK_TIP_W: float = 257.0
const SK_RIM: Color = Color("0390d3", 0.8)
const SK_PICK_EDGE: Color = Color("3d5a68")
const SK_PICK_FILL: Color = Color("001715")
const SK_YELLOW: Color = Color("ffff00")

var _sk_tab: String = "study"
var _sk_captain: bool = false
var _sk_first: int = 0
var _sk_rect: Rect2 = Rect2()
var _sk_grab: bool = false
var _sk_grab_at: Vector2 = Vector2.ZERO
var _sk_grab_first: int = 0
var _sk_pick_slot: int = 0
var _sk_pick_type: int = 0
var _sk_pick_y: float = 0.0
var _sk_pick_list: Array = []
var _sk_greys: Dictionary = {}
var _sk_top: StyleBoxFlat = null


func _open_skill() -> void :
	if _dialog == "skill":
		return
	_close_dialog()
	_dialog = "skill"
	var lead: String = str(client.guild.get("leaderUuid", ""))
	var vice: String = str(client.guild.get("viceLeaderUuid", ""))
	_sk_captain = not _me.is_empty() and (_me == lead or _me == vice)
	_sk_tab = "study"
	_sk_first = 0

func _sk_reset() -> void :
	_sk_tab = "study"
	_sk_captain = false
	_sk_first = 0
	_sk_rect = Rect2()
	_sk_grab = false
	_sk_close_pick()

func _sk_close_pick() -> void :
	_sk_pick_slot = 0
	_sk_pick_type = 0
	_sk_pick_list = []


func _sk_row(idx: String, lvl: int) -> Array:
	var table: Array = GuildManage.SKILL_TABLE.get(idx, [])
	return table[2].get(str(lvl), []) if table.size() >= 3 else []

func _sk_max(idx: String) -> int:
	var table: Array = GuildManage.SKILL_TABLE.get(idx, [])
	return int(table[0]) if not table.is_empty() else 0


func _sk_info(id: int) -> Array:
	return GuildManage.SKILL_INFO.get(str(id), [])

func _sk_text(key: int, one: Variant = "", two: Variant = "") -> String:
	return str(GuildManage.SKILL_TEXT.get("CORPS_TEXT%d" % key, "")).replace("@num1@", str(one)).replace("@num2@", str(two))

func _sk_lv_self(idx: String) -> int:
	return int(client.guild_skill_self.get(int(idx), 0))

func _sk_lv_corps(idx: String) -> int:
	return int(client.guild_skill_corps.get(int(idx), 0))

func _sk_merit() -> int:
	var member: Dictionary = client.guild_members.get(_me, {}) if not _me.is_empty() else {}
	return int(member.get("iMerit", 0))


func _sk_icon(pvp: int, grey: bool) -> Texture2D:
	if pack == null:
		return null
	var hud: Array = pack.skill_hud(pvp)
	if hud.is_empty():
		return null
	var texture: Texture2D = pack.icon("s", str(hud[0]))
	return _sk_grey(texture) if texture != null and grey else texture

func _sk_grey(texture: Texture2D) -> Texture2D:
	var key: int = texture.get_instance_id()
	if _sk_greys.has(key):
		return _sk_greys[key]
	var image: Image = texture.get_image()
	if image == null:
		return texture
	image = image.duplicate()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var data: PackedByteArray = image.get_data()
	for i in range(0, data.size(), 4):
		var v: int = clampi(roundi(0.3086 * data[i] + 0.6094 * data[i + 1] + 0.082 * data[i + 2]), 0, 255)
		data[i] = v
		data[i + 1] = v
		data[i + 2] = v
	var grey: ImageTexture = ImageTexture.create_from_image(Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data))
	_sk_greys[key] = grey
	return grey


func _sk_slot_state(i: int) -> String:
	if i >= 2 and (client.guild_skill_flag & (1 << (i - 1))) == 0:
		return "lock"
	return "open" if (client.guild_skill_flag & (1 << i)) != 0 else "close"

func _skill_activate(id: String) -> void :
	if id == "sk_close":
		_close_dialog()
	elif id == "sk_frame" or id.begins_with("sk_item:"):
		_sk_close_pick()
	elif id.begins_with("sk_tab:"):

		var tab: String = id.substr(7)
		if _sk_captain and tab != _sk_tab:
			_sk_tab = tab
			_sk_first = 0
	elif id.begins_with("sk_res:"):
		_sk_do_research(id.substr(7))
	elif id.begins_with("sk_learn:"):
		_sk_do_learn(id.substr(9))
	elif id.begins_with("sk_grid:"):
		_sk_grid_click(int(id.substr(8)))
	elif id.begins_with("sk_open:"):
		client.guild_skill_unlock(int(id.substr(8)))
	elif id.begins_with("sk_pick:"):
		_sk_choose(int(id.substr(8)))
	else:
		_sk_close_pick()
		match id:
			"sk:up", "sk:down":
				_sk_scroll(-1 if id == "sk:up" else 1)
			"sk:pgup", "sk:pgdn":
				_sk_scroll( - SK_SHOWN if id == "sk:pgup" else SK_SHOWN)



func _sk_do_research(idx: String) -> void :
	var next: Array = _sk_row(idx, _sk_lv_corps(idx) + 1)
	if next.is_empty():
		say(_sk_text(53))
	elif int(client.guild.get("nLevel", 0)) < int(next[2]):
		say(_sk_text(51, int(next[2])))
	elif int(client.guild.get("iCoin", 0)) < int(next[3]):
		say(_sk_text(16))
	else:
		client.guild_skill_research(int(idx))



func _sk_do_learn(idx: String) -> void :
	var study: int = _sk_lv_self(idx)
	var research: int = _sk_lv_corps(idx)
	if research == 0:
		say(_sk_text(54))
		return
	if study >= research:
		say(_sk_text(55) if not _sk_row(idx, research + 1).is_empty() else _sk_text(56))
		return
	var next: Array = _sk_row(idx, mini(study, research) + 1)
	if next.is_empty():
		return
	if int(client.character.get("level", 0)) < int(next[5]):
		say(_sk_text(92))
	elif _sk_merit() < int(next[4]):
		say(_sk_text(59))
	else:
		client.guild_skill_learn(int(idx))


func _sk_grid_click(i: int) -> void :
	var spec: Dictionary = GuildManage.SKILL
	if i == 0:
		_sk_open_pick(2, 4, float(spec["main"][1]))
	elif i >= 1 and i <= 4 and _sk_slot_state(i) == "open":
		_sk_open_pick(3, 4 + i, float(spec["deputy"][i - 1][1]))


func _sk_open_pick(type: int, slot: int, grid_y: float) -> void :
	_sk_close_pick()
	var used: Dictionary = {}
	for key: Variant in client.guild_skill_slots:
		var row: Array = client.guild_skill_slots[key]
		if not row.is_empty() and int(row[0]) != 0:
			used[int(row[0])] = true
	var list: Array = []
	for key: Variant in client.guild_skill_self:
		var lvl: int = int(client.guild_skill_self[key])
		if lvl < 1 or used.has(int(key)):
			continue
		var row: Array = _sk_row(str(int(key)), lvl)
		var info: Array = _sk_info(int(row[0])) if not row.is_empty() else []
		if info.is_empty():
			continue
		var kind: int = int(info[2])
		if kind == type or (type == 2 and kind == 1):
			list.append([int(key), lvl])
	if list.is_empty():
		say(str(GuildManage.SKILL_EMPTY))
		return
	_sk_pick_slot = slot
	_sk_pick_type = type
	_sk_pick_y = grid_y
	_sk_pick_list = list


func _sk_choose(i: int) -> void :
	if i < 0 or i >= _sk_pick_list.size():
		return
	var id: int = int(_sk_pick_list[i][0])
	var lvl: int = int(_sk_pick_list[i][1])
	var slot: int = _sk_pick_slot
	if slot < 4:
		slot += 4
	var row: Array = _sk_row(str(id), lvl)
	var info: Array = _sk_info(int(row[0])) if not row.is_empty() else []
	var kind: int = int(info[2]) if not info.is_empty() else 0
	if kind == 2:
		slot = 4
	elif kind == 3 and slot == 4:
		slot = 5
	_sk_close_pick()
	client.guild_skill_set(id, lvl, slot)

func _sk_rows() -> int:
	return ceili(GuildManage.SKILL_ORDER.size() / 2.0)

func _sk_most() -> int:
	return maxi(0, _sk_rows() - SK_SHOWN)

func _sk_scroll(step: int) -> void :
	_sk_first = clampi(_sk_first + step, 0, _sk_most())

func _sk_drag(moved: float) -> void :
	var most: int = _sk_most()
	if most <= 0:
		return
	var track: float = float(GuildManage.SKILL["list"][3]) - 2.0 * BAR
	var thumb: float = maxf(20.0, track * float(SK_SHOWN) / float(maxi(1, _sk_rows())))
	var step: float = maxf(0.001, (track - thumb) / float(most))
	_sk_first = clampi(_sk_grab_first + roundi(moved / _f / step), 0, most)




func _draw_skill() -> void :
	var spec: Dictionary = GuildManage.SKILL
	var wide: float = float(spec["box"][0])
	var high: float = float(spec["box"][1])
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(wide, high)
	_hit("sk_frame", Rect2(at * _f, Vector2(wide, high) * _f), false)
	draw_rect(Rect2((at + Vector2(12, 43)) * _f, Vector2(wide - 24.0, high - 55.0) * _f), WINDOW)
	var full: Vector2 = _cell_size("public_bk_pattern")
	var part: Vector2 = Vector2(minf(full.x, wide - 24.0), minf(full.y, high - 55.0))
	_fpart("public_bk_pattern", at + Vector2(12, 43) + (Vector2(wide - 24.0, high - 55.0) - part) / 2.0, Rect2(((full - part) / 2.0).floor(), part))
	_fblit("public_bk_lt", at)
	_fblit("public_bk_rt", at + Vector2(wide - 34.0, 0))
	_fblit("public_bk", at + Vector2(34, 0), wide - 68.0)
	_fblit("public_bk_l", at + Vector2(0, 84), 0.0, high - 147.0)
	_fblit("public_bk_r", at + Vector2(wide - 30.0, 84), 0.0, high - 147.0)
	_fblit("gm_sk_lb", at + Vector2(0, high - 63.0))
	_fblit("gm_sk_rb", at + Vector2(wide - 30.0, high - 63.0))
	_fblit("gm_sk_b", at + Vector2(30, high - 24.0), wide - 60.0)
	_fmid("public_bk_ti", at + Vector2(0, 18), wide)
	_fblit("public_bk_oc", at + Vector2(43, 9), wide - 86.0)
	_fblit("public_bk_ol", at + Vector2(35, 9))
	_fblit("public_bk_or", at + Vector2(wide - 43.0, 9))
	_fblit("public_bk_c", at + Vector2(wide - 52.0, 13))
	var body: Array = spec["body"]
	_fblit("gm_sk_body", at + Vector2(float(body[0]), float(body[1])))
	var close: Array = spec["close"]
	_fbutton("sk_close", "public_button_close", at + Vector2(float(close[0]), float(close[1])))
	if _sk_captain:
		for tab: String in ["study", "research"]:
			var spot: Array = spec[tab]
			_fbutton("sk_tab:" + tab, "gm_sk_tab_%s_%s" % [tab, "on" if _sk_tab == tab else "off"], at + Vector2(float(spot[0]), float(spot[1])))

	var list: Array = spec["list"]
	var list_at: Vector2 = at + Vector2(float(list[0]), float(list[1]))
	_sk_rect = Rect2(list_at * _f, Vector2(float(list[2]), float(list[3])) * _f)
	var order: Array = GuildManage.SKILL_ORDER
	var cell: Array = spec["cell"]
	_sk_first = clampi(_sk_first, 0, _sk_most())
	for r in range(_sk_first, mini(_sk_rows(), _sk_first + SK_SHOWN + 1)):
		var room: float = float(list[3]) - float(r - _sk_first) * float(cell[1])
		for c in range(int(spec["cols"])):
			var k: int = r * int(spec["cols"]) + c
			if k < order.size():
				_sk_draw_item(str(order[k]), list_at + Vector2(float(c) * float(cell[0]), float(r - _sk_first) * float(cell[1])), minf(room, float(spec["item"][1])))
	_vbar("sk", list_at + Vector2(float(list[2]) - BAR, 0), float(list[3]), _sk_rows(), SK_SHOWN, _sk_first)

	for key: String in ["merit", "coin"]:
		var box: Array = spec[key]
		var value: int = _sk_merit() if key == "merit" else int(client.guild.get("iCoin", 0))
		_fwords(str(value), ARIAL_BOLD, float(spec["px"]), Color.WHITE, "c", at + Vector2(float(box[0]), float(box[1])), float(box[2]), 0.0, float(box[3]), false)
	var tip: String = ""
	for i in range(5):
		var grid: Array = spec["main"] if i == 0 else spec["deputy"][i - 1]
		var name_tip: String = _sk_draw_grid(i, at + Vector2(float(grid[0]), float(grid[1])))
		if not name_tip.is_empty() and _hover == "sk_grid:%d" % i:
			tip = name_tip
	if _sk_pick_slot != 0:
		_sk_draw_pick(at)

	if _hover.begins_with("sk_pick:") and _sk_pick_slot != 0:
		var index: int = int(_hover.substr(8))
		if index >= 0 and index < _sk_pick_list.size():
			_sk_tip(str(int(_sk_pick_list[index][0])), int(_sk_pick_list[index][1]))
	elif _hover.begins_with("sk_item:") or _hover.begins_with("sk_res:") or _hover.begins_with("sk_learn:"):
		var idx: String = _hover.get_slice(":", 1)
		var lvl: int = _sk_lv_corps(idx) if _sk_tab == "research" else _sk_lv_self(idx)
		_sk_tip(idx, maxi(1, lvl))
	elif not tip.is_empty():
		_sk_line_tip(tip)


func _sk_draw_item(idx: String, at: Vector2, room: float) -> void :
	var spec: Dictionary = GuildManage.SKILL
	var item: Vector2 = Vector2(float(spec["item"][0]), float(spec["item"][1]))
	var fill: Color = Color(str(spec["item_bg"]))
	var study: int = _sk_lv_self(idx)
	var research: int = _sk_lv_corps(idx)
	var row: Array = _sk_row(idx, maxi(1, study))
	var info: Array = _sk_info(int(row[0])) if not row.is_empty() else []
	var research_tab: bool = _sk_tab == "research" and _sk_captain
	var grey: bool = research == 0
	var icon_at: Vector2 = at + Vector2(float(spec["item_icon"][0]), float(spec["item_icon"][1]))
	if room < item.y:
		if _sk_top == null:
			_sk_top = StyleBoxFlat.new()
		_sk_top.bg_color = fill
		_sk_top.corner_radius_top_left = roundi(minf(10.0, room) * _f)
		_sk_top.corner_radius_top_right = roundi(minf(10.0, room) * _f)
		draw_style_box(_sk_top, Rect2(at * _f, Vector2(item.x, room) * _f))
		var shown: float = room - (icon_at.y - at.y)
		var texture: Texture2D = _sk_icon(int(row[0]), grey or ( not research_tab and mini(study, research) == 0)) if not info.is_empty() else null
		if texture != null and shown > 0.0:
			draw_texture_rect_region(texture, Rect2(icon_at * _f, Vector2(50, shown) * _f), Rect2(0, 0, texture.get_width(), texture.get_height() * shown / 50.0))
		_hit("sk_item:" + idx, Rect2(at * _f, Vector2(item.x, room) * _f), false)
		return
	_fround(Rect2(at, item), fill, 10.0)
	_hit("sk_item:" + idx, Rect2(at * _f, item * _f), false)
	if info.is_empty():
		return
	var top: int = _sk_max(idx)
	var share: float = float(top if top >= 1 else 9)
	var process: String = ""
	var ratio: float = 0.0
	var cover: float = 0.0
	var cost: String = ""
	var red: bool = false
	var guild_lv: int = int(client.guild.get("nLevel", 0))
	if research_tab:
		process = _sk_text(12, research, top)
		ratio = float(research) / share
		var next: Array = _sk_row(idx, research + 1)
		if next.is_empty():
			cost = _sk_text(53)
		elif guild_lv < int(next[2]):
			grey = true
			cost = _sk_text(51, int(next[2]))
		else:
			cost = _sk_text(52, int(next[3]))
			red = int(client.guild.get("iCoin", 0)) < int(next[3])
	else:
		var cur: int = mini(study, research)
		process = _sk_text(12, cur, top)
		ratio = float(cur) / share
		cover = clampf(1.0 - float(research) / share, 0.0, 1.0)
		var next: Array = _sk_row(idx, cur + 1)
		if not next.is_empty():
			var merit: int = 0 if study > cur else int(next[4])
			var need: int = 0 if study > cur else int(next[5])
			cost = _sk_text(50, merit)
			if int(client.character.get("level", 0)) < need:
				cost = _sk_text(48, need)
				red = true
			elif _sk_merit() < merit:
				red = true
		if cur == 0:
			grey = true
			if research == 0:
				cost = _sk_text(54)
			elif not next.is_empty() and guild_lv < int(next[2]):
				cost = _sk_text(51, int(next[2]))
	var texture: Texture2D = _sk_icon(int(row[0]), grey)
	if texture != null:
		draw_texture_rect(texture, Rect2(icon_at * _f, Vector2(50, 50) * _f), false)
	var track: Array = spec["track"]
	_fblit("gm_sk_track", at + Vector2(float(track[0]), float(track[1])))
	var bar: Array = spec["fill"]
	var lit: float = roundf(float(bar[2]) * clampf(ratio, 0.0, 1.0))
	if lit > 0.0:
		_fpart("gm_sk_fill", at + Vector2(float(bar[0]), float(bar[1])), Rect2(0, 0, lit, float(bar[3])))
	if cover > 0.0:
		var over: Array = spec["over"]
		var shade_w: float = float(over[2]) * cover
		_fround(Rect2(at + Vector2(float(over[0]) - shade_w, float(over[1])), Vector2(shade_w, float(over[3]))), Color(0, 0, 0, float(spec["over_alpha"])), 3.0)
	var spot: Array = spec["process"]
	_fwords(process, ARIAL_BOLD, 11.0, Color.WHITE, "l", at + Vector2(float(spot[0]), float(spot[1])), float(spot[2]), 1.5, 0.0, false, SK_RIM)
	spot = spec["name"]
	_fwords(str(info[0]), ARIAL_BOLD, 14.0, Color.WHITE, "l", at + Vector2(float(spot[0]), float(spot[1])), float(spot[2]), 1.5, 0.0, true, SK_RIM)
	spot = spec["cost"]
	_fwords(cost, ARIAL_BOLD, 14.0, Color("ff0000") if red else Color.WHITE, "r", at + Vector2(float(spot[0]), float(spot[1])), float(spot[2]), 1.5, 0.0, true, SK_RIM)
	var button: Array = spec["button"]
	if research_tab:
		_fbutton("sk_res:" + idx, "gm_sk_research", at + Vector2(float(button[0]), float(button[1])))
	else:
		_fbutton("sk_learn:" + idx, "gm_sk_study", at + Vector2(float(button[0]), float(button[1])))


func _sk_draw_grid(i: int, at: Vector2) -> String:
	var spec: Dictionary = GuildManage.SKILL
	var state: String = _sk_slot_state(i)
	var named: String = ""
	if state == "lock":
		_fblit("gm_sk_lock", at)
	elif state == "open":
		_fblit("gm_sk_slot", at)
		var held: Array = client.guild_skill_slots.get(4 + i, [])
		if not held.is_empty() and int(held[0]) != 0:
			var row: Array = _sk_row(str(int(held[0])), maxi(1, int(held[1])))
			var info: Array = _sk_info(int(row[0])) if not row.is_empty() else []
			if not info.is_empty():
				var icon: Array = spec["icon"]
				var texture: Texture2D = _sk_icon(int(row[0]), false)
				if texture != null:
					draw_texture_rect(texture, Rect2((at + Vector2(float(icon[0]), float(icon[1]))) * _f, Vector2(float(icon[2]), float(icon[3])) * _f), false)
				named = str(info[0])
		var arrow: Array = spec["arrow"]
		_fblit("gm_sk_arrow", at + Vector2(float(arrow[0]), float(arrow[1])))
	else:
		_fblit("gm_sk_open", at)
	_hit("sk_grid:%d" % i, Rect2(at * _f, Vector2(float(spec["main"][2]), float(spec["main"][3])) * _f), false)
	if state == "close":
		var id: String = "sk_open:%d" % (4 + i)
		var button: Rect2 = Rect2(0, 13, 66, 29)
		if _hover == id or _press == id:
			_fpart("gm_sk_open", at + button.position, button, _glow(id))
		_hit(id, Rect2((at + button.position) * _f, button.size * _f), false)
	return named


func _sk_draw_pick(at: Vector2) -> void :
	var count: int = _sk_pick_list.size()
	if count == 0:
		return
	var cols: int = mini(5, count)
	var rows: int = ceili(float(count) / float(cols))
	var wide: float = maxf(74.0, 18.0 + 56.0 * float(cols))
	var high: float = maxf(74.0, 18.0 + 56.0 * float(rows))
	var y: float = _sk_pick_y + 52.0
	if y + 90.0 > 420.0:
		y = 330.0
	if y < 70.0:
		y = 70.0
	var x: float = 628.0 - (wide - 34.0)
	if x < 20.0:
		x = 20.0
	if x + wide > 700.0:
		x = 700.0 - wide
	var spot: Vector2 = at + Vector2(x, y)
	_hit("sk_frame", Rect2(spot * _f, Vector2(wide, high + 12.0) * _f), false)
	_sk_bubble(spot, Rect2(0, 12, wide, high), wide - 34.0, 0.0, 10.0, SK_PICK_EDGE)
	_sk_bubble(spot, Rect2(2, 14, wide - 4.0, high - 4.0), wide - 34.0, 3.0, 8.0, SK_PICK_FILL)
	for i in range(count):
		var cell: Vector2 = spot + Vector2(12.0 + float(i % cols) * 56.0, 24.0 + floorf(float(i) / float(cols)) * 56.0)
		var row: Array = _sk_row(str(int(_sk_pick_list[i][0])), int(_sk_pick_list[i][1]))
		var texture: Texture2D = _sk_icon(int(row[0]), false) if not row.is_empty() else null
		var rect: Rect2 = Rect2(cell * _f, Vector2(50, 50) * _f)
		if texture != null:
			draw_texture_rect(texture, rect, false, _glow("sk_pick:%d" % i))
		_hit("sk_pick:%d" % i, rect, false)


func _sk_bubble(origin: Vector2, box: Rect2, apex_x: float, apex_y: float, half: float, fill: Color) -> void :
	var l: float = box.position.x
	var t: float = box.position.y
	var r: float = box.end.x
	var b: float = box.end.y
	var k: float = 10.0
	var points: PackedVector2Array = PackedVector2Array([Vector2(apex_x - half, t), Vector2(apex_x, apex_y), Vector2(apex_x + half, t), Vector2(r - k, t)])
	_sk_curve(points, Vector2(r - k, t), Vector2(r, t), Vector2(r, t + k))
	points.append(Vector2(r, b - k))
	_sk_curve(points, Vector2(r, b - k), Vector2(r, b), Vector2(r - k, b))
	points.append(Vector2(l + k, b))
	_sk_curve(points, Vector2(l + k, b), Vector2(l, b), Vector2(l, b - k))
	points.append(Vector2(l, t + k))
	_sk_curve(points, Vector2(l, t + k), Vector2(l, t), Vector2(l + k, t))
	for i in range(points.size()):
		points[i] = (origin + points[i]) * _f
	draw_colored_polygon(points, fill)

func _sk_curve(points: PackedVector2Array, from: Vector2, bend: Vector2, to: Vector2) -> void :
	for step in range(1, 7):
		var s: float = float(step) / 6.0
		points.append(from.lerp(bend, s).lerp(bend.lerp(to, s), s))



func _sk_tip(idx: String, lvl: int) -> void :
	var row: Array = _sk_row(idx, lvl)
	if row.is_empty():
		return
	var cur: Array = _sk_info(int(row[0]))
	var cur_pve: Array = _sk_info(int(row[1]))
	if cur.is_empty() or cur_pve.is_empty():
		return
	var next_row: Array = _sk_row(idx, lvl + 1)
	var nxt: Array = _sk_info(int(next_row[0])) if not next_row.is_empty() else []
	var nxt_pve: Array = _sk_info(int(next_row[1])) if not next_row.is_empty() else []
	var study: int = _sk_lv_self(idx)
	var learned: int = study if study > _sk_lv_corps(idx) else 0
	var ops: Array = []
	var y: float = 10.0
	ops.append(["w", str(cur[0]), ARIAL_BOLD, 14.0, Color.WHITE, y, 20.0])
	y += 20.0
	ops.append(["w", _sk_text(62, lvl), ARIAL, 12.0, Color.WHITE, y, 18.0])
	y += 18.0
	if learned > 0:
		ops.append(["n", _sk_text(60, "@"), str(learned), y])
		y += 18.0
	y += 10.0
	ops.append(["w", _sk_text(63), ARIAL, 12.0, Color.WHITE, y, 16.0])
	y += 16.0
	if int(cur[3]) > 0:
		ops.append(["w", str(GuildManage.SKILL_TEXT["CONTROL_TEXT190"]).replace("@num1@", str(int(int(cur[3]) / 1000.0))), ARIAL, 12.0, Color("21ac16"), y, 16.0])
		y += 16.0
	var blocks: Array = []
	var active: bool = int(cur[2]) == 1 or int(cur[2]) == 2
	if active:
		blocks.append([str(cur[1]), Color.WHITE])
	else:
		blocks.append([_sk_text(65).replace("@title1@", str(cur[1])), Color.WHITE])
		blocks.append([_sk_text(66).replace("@title1@", str(cur_pve[1])), Color.WHITE])
	y = _sk_tip_blocks(ops, blocks, y)
	if not nxt.is_empty() and not nxt_pve.is_empty():
		y += 10.0
		ops.append(["w", _sk_text(64), ARIAL, 12.0, SK_YELLOW, y, 16.0])
		y += 16.0
		if int(client.guild.get("nLevel", 0)) < int(next_row[2]):
			ops.append(["w", _sk_text(51, int(next_row[2])), ARIAL, 12.0, Color("ff0000"), y, 18.0])
			y += 18.0
		if int(nxt[3]) > 0:
			ops.append(["w", str(GuildManage.SKILL_TEXT["CONTROL_TEXT190"]).replace("@num1@", str(int(int(nxt[3]) / 1000.0))), ARIAL, 12.0, Color("35ff26"), y, 16.0])
			y += 16.0
		blocks = []
		if active:
			blocks.append([str(nxt[1]), SK_YELLOW])
		else:
			blocks.append([_sk_text(65).replace("@title1@", str(nxt[1])), SK_YELLOW])
			blocks.append([_sk_text(66).replace("@title1@", str(nxt_pve[1])), SK_YELLOW])
		y = _sk_tip_blocks(ops, blocks, y)
	var high: float = y + 16.0
	var mouse: Vector2 = get_local_mouse_position() / _f
	var spot: Vector2 = Vector2(mouse.x - SK_TIP_W, mouse.y)
	if spot.x < 0.0:
		spot.x = mouse.x
	if spot.y + high > _fh:
		spot.y = mouse.y - high
	_fround(Rect2(spot, Vector2(SK_TIP_W, high)), Color(0, 0, 0, 0.8), 6.0)
	_tip_mark(Rect2(spot * _f, Vector2(SK_TIP_W, high) * _f))
	for op: Array in ops:
		match str(op[0]):
			"w":
				_fwords(str(op[1]), op[2], float(op[3]), op[4], "l", spot + Vector2(5, float(op[5])), SK_TIP_W - 10.0, 0.0, float(op[6]), false)
			"n":
				var parts: PackedStringArray = str(op[1]).split("@", true, 1)
				var left: float = _fwords(parts[0], ARIAL, 12.0, Color.WHITE, "l", spot + Vector2(5, float(op[3])), SK_TIP_W - 10.0, 0.0, 18.0, false)
				var mid: float = _fwords(str(op[2]), ARIAL, 12.0, SK_YELLOW, "l", spot + Vector2(5.0 + left, float(op[3])), SK_TIP_W - 10.0 - left, 0.0, 18.0, false)
				if parts.size() > 1 and not parts[1].is_empty():
					_fwords(parts[1], ARIAL, 12.0, Color.WHITE, "l", spot + Vector2(5.0 + left + mid, float(op[3])), SK_TIP_W - 10.0 - left - mid, 0.0, 18.0, false)
			"p":
				_fpara(str(op[1]), ARIAL, 12.0, op[2], spot + Vector2(5, float(op[3])), 244.0)


func _sk_tip_blocks(ops: Array, blocks: Array, y: float) -> float:
	var px: int = maxi(6, roundi(12.0 * _f))
	for block: Array in blocks:
		var text: String = str(block[0])
		ops.append(["p", text, block[1], y])
		y += ARIAL.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, 244.0 * _f, px).y / _f + 6.0
	return y


func _sk_line_tip(text: String) -> void :
	var px: int = maxi(6, roundi(12.0 * _f))
	var wide: float = ARIAL.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f + 16.0
	var spot: Vector2 = get_local_mouse_position() / _f + Vector2(10, 22)
	spot.x = clampf(spot.x, 0.0, maxf(0.0, _fw - wide))
	spot.y = clampf(spot.y, 0.0, maxf(0.0, _fh - 24.0))
	_round(Rect2(spot * _f, Vector2(wide, 24) * _f), Color(0, 0, 0, 0.86), 6.0, Color("6fd0ff", 0.55), 1.5)
	_tip_mark(Rect2(spot * _f, Vector2(wide, 24) * _f))
	_fwords(text, ARIAL, 12.0, Color.WHITE, "l", spot + Vector2(8, 0), wide - 16.0, 0.0, 24.0, false)




func _nc_on() -> bool:
	return client != null and client.guild.is_empty()



func _nc_request(page: int) -> void :
	if _nc_waiting or client == null:
		return
	var origin: String = str(client.config.origin)
	if origin.is_empty() and not fetch.is_valid():
		return
	_nc_page = page
	var url: String = origin + "/cGuildJoinList.php?p=%d&li=%d" % [page, NC_PAGE]
	if _nc_only:
		url += "&charuuid=" + str(client.char_uuid).uri_encode()
	url += "&noCache=" + str(randf())
	_nc_waiting = true
	if fetch.is_valid():
		fetch.call(url)
		return
	_nc_http.cancel_request()
	if _nc_http.request(url, AppSession.headers(url)) != OK:
		_nc_waiting = false



func nc_on_reply(result: int, code: int, body: PackedByteArray) -> void :
	if not _nc_waiting:
		return
	_nc_waiting = false
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var text: String = body.get_string_from_utf8()
	if text.strip_edges().is_empty():
		return
	var json: JSON = JSON.new()
	if json.parse(text) != OK or not (json.data is Dictionary):
		return
	var data: Dictionary = json.data
	var total: int = maxi(1, ceili(float(int(_tw_num(data.get("amount")))) / float(NC_PAGE)))
	_nc_prev = _nc_page > 1
	_nc_next = _nc_page < total
	var rows: Array = []
	var items: Variant = data.get("datas", [])
	if items is Dictionary:
		items = (items as Dictionary).values()
	if items is Array:
		for item: Variant in items:
			if item is Dictionary:
				rows.append(_nc_row(item))
	rows.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a["active"]) > int(b["active"]))
	_nc_rows = rows
	_nc_pick = -1


func _nc_row(data: Dictionary) -> Dictionary:
	var row: Dictionary = {"gid": int(_tw_num(data.get("guild_id"))), "name": _tw_text(data.get("guild_name")), 
		"num": int(_tw_num(data.get("guild_number"))), "max": int(_tw_num(data.get("guild_maxnum"))), 
		"active": int(_tw_num(data.get("guild_active"))), "level": int(_tw_num(data.get("guild_level_limit"))), 
		"ladder": int(_tw_num(data.get("guild_ladder_limit"))), "notice": _tw_text(data.get("guild_notice")), 
		"auto": bool(_tw_num(data.get("auto_join")))}
	row["level_ok"] = int(client.character.get("level", 0)) >= int(row["level"])
	row["ladder_ok"] = client.ladder_section() >= int(row["ladder"])
	row["ok"] = bool(row["level_ok"]) and bool(row["ladder_ok"])
	return row


func _nc_ladder(section: int) -> String:
	return str(NC_LADDER.get(section, ""))


func _nc_draw(frame: Vector2) -> void :
	var at: Dictionary = Join.AT
	_fblit("gj_panel", frame + Vector2(float(Join.PANEL[0]), float(Join.PANEL[1])))
	_fblit("gj_title", frame + Vector2(float(at["image1"][0]), float(at["image1"][1])))
	var list: Vector2 = frame + Vector2(float(at["lstClan"][0]), float(at["lstClan"][1]))
	for index: int in mini(NC_PAGE, _nc_rows.size()):
		_nc_draw_row(index, list + Vector2(0, NC_ROW * index))
	_fbutton("nc:only", "gj_check_on" if _nc_only else "gj_check_off", frame + Vector2(float(at["cbShowCanJoin"][0]), float(at["cbShowCanJoin"][1])))
	if _nc_prev:
		_fbutton("nc:prev", "gj_prev", frame + Vector2(float(at["btnPreviousPage"][0]), float(at["btnPreviousPage"][1])))
	if _nc_next:
		_fbutton("nc:next", "gj_next", frame + Vector2(float(at["btnNextPage"][0]), float(at["btnNextPage"][1])))
	_fbutton("nc:quick", "gj_quick", frame + Vector2(float(at["btnJoinCorps"][0]), float(at["btnJoinCorps"][1])))
	_fbutton("nc:create", "gj_new", frame + Vector2(float(at["btnCreateCorps"][0]), float(at["btnCreateCorps"][1])))
	_fbutton("nc:search", "gj_search", frame + Vector2(float(at["btnSearchCorps"][0]), float(at["btnSearchCorps"][1])))



func _nc_draw_row(index: int, spot: Vector2) -> void :
	var row: Dictionary = _nc_rows[index]
	var pick: bool = index == _nc_pick
	_hit("nc:row:%d" % index, Rect2(spot * _f, Vector2(780, NC_ROW) * _f), false)
	var texts: Dictionary = {"lblClanName": [str(row["name"]), pick], "lblActValue": [str(row["active"]), pick], 
		"lblNum": [NC_NUM.replace("@num1@", str(row["num"])).replace("@num2@", str(row["max"])), pick], 
		"lblNotice": [str(row["notice"]), false], "lblAutoJoin": [NC_YES if bool(row["auto"]) else NC_NO, false]}
	for key: String in texts:
		var spec: Array = Join.ROW_TEXT[key]
		var words: String = str(texts[key][0])
		var tone: Color = PICK if bool(texts[key][1]) else Color.WHITE
		_fwords(_cut(words, ARIAL_BOLD, 13.0, float(spec[2])), ARIAL_BOLD, 13.0, tone, str(spec[7]), spot + Vector2(float(spec[0]), float(spec[1])), 
			float(spec[2]), 0.0, 0.0, false)
	for key: String in ["lblLevelLimit", "lblLadder"]:
		var spec: Array = Join.ROW_TEXT[key]
		var ok: bool = bool(row["level_ok" if key == "lblLevelLimit" else "ladder_ok"])
		var words: String = str(row["level"]) if key == "lblLevelLimit" else _nc_ladder(int(row["ladder"]))
		var px: float = 13.0 if ok else 14.0
		_fwords(_cut(words, ARIAL_BOLD, px, float(spec[2])), ARIAL_BOLD, px, Color.WHITE if ok else NC_RED, "c", 
			spot + Vector2(float(spec[0]), float(spec[1])), float(spec[2]), 0.0, 0.0, false)
	_fbutton("nc:watch:%d" % index, "gj_watch", spot + Vector2(float(Join.ROW["btnWatch"][0]), float(Join.ROW["btnWatch"][1])))
	var ask: Vector2 = spot + Vector2(float(Join.ROW["btnRequest"][0]), float(Join.ROW["btnRequest"][1]))
	if bool(row["ok"]):
		_fbutton("nc:req:%d" % index, "gj_request", ask)
	else:
		_fblit("gj_request_off", ask)
	_fblit("gj_cut", spot + Vector2(float(Join.ROW["cut"][0]), float(Join.ROW["cut"][1])))
	if pick:
		_fround(Rect2(spot + Vector2(11, 0), Vector2(758, 30)), Color(0, 0, 0, 0), 5.0, PICK, 3.0)

func _nc_activate(id: String) -> void :
	if id.begins_with("nc:row:"):
		_nc_pick = int(id.substr(7))
	elif id.begins_with("nc:watch:"):

		_nc_pick = int(id.substr(9))
		_nc_watch(_nc_pick)
	elif id.begins_with("nc:req:"):
		_nc_pick = int(id.substr(7))
		var row: Dictionary = _nc_rows[_nc_pick] if _nc_pick < _nc_rows.size() else {}

		if not row.is_empty() and client.guild_join_apply(int(row["gid"]), "", false):
			say(NC_APPLIED.replace("@clanName@", str(row["name"])))
	else:
		match id:
			"nc:only":
				_nc_only = not _nc_only
				_nc_request(1)
			"nc:prev":
				_nc_request(_nc_page - 1)
			"nc:next":
				_nc_request(_nc_page + 1)
			"nc:quick":
				client.guild_join_apply(0, "", true)
			"nc:create":
				_nc_open_create()
			"nc:search":
				_nc_open_search()


func _nc_watch(index: int) -> void :
	if index < 0 or index >= _nc_rows.size():
		return
	var watch: Control = _nc_watch_view()
	if watch.visible:
		return
	_hide_menu()
	_hover = ""
	_press = ""
	watch.open_apply(_nc_ids(), index, _nc_rows)

func _nc_ids() -> Array:
	var ids: Array = []
	for row: Dictionary in _nc_rows:
		ids.append(int(row["gid"]))
	return ids

func _nc_watch_view() -> Control:
	if _watch == null:
		_watch = CorpsWatch.new()
		_watch.visible = false
		_watch.client = client
		_watch.pack = pack
		_watch.hall = hall
		add_child(_watch)
		_watch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_watch.whisper.connect( func(who: String) -> void : whisper.emit(who))
		_watch.notice.connect( func(text: String) -> void : say(text))
	return _watch


func _nc_open_create() -> void :
	if _found == null:
		_found = GuildCreate.new()
		_found.client = client
		_found.pack = pack
		_found.hall = hall
		add_child(_found)
		_found.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_found.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
		_found.quick_buy_asked.connect( func(tid: int) -> void : quick_buy_asked.emit(tid))
	if _found.visible:
		return
	_found.hall = hall
	_hover = ""
	_press = ""
	_found.open()


func _nc_open_search() -> void :
	if _find == null:
		_find = GuildSearch.new()
		_find.client = client
		_find.pack = pack
		_find.hall = hall
		_find.fetch = search_fetch
		add_child(_find)
		_find.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_find.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
		_find.found.connect( func(data: Dictionary) -> void :
			_hover = ""
			_press = ""
			_nc_watch_view().show_search(data, _nc_rows))
	if _find.visible:
		return
	_find.hall = hall
	_hover = ""
	_press = ""
	_find.open()
