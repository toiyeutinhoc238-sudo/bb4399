extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")















const Atlas = preload("arena_atlas.gd")
const CTip = preload("ctool_tip.gd")
const Hall = preload("hall_atlas.gd")
const Guild = preload("guild_atlas.gd")
const GuildTeam = preload("guild_team_atlas.gd")
const Watch = preload("corps_watch_atlas.gd")
const Join = preload("guild_join_atlas.gd")
const HallScreen = preload("hall_screen.gd")
const NameStyles = preload("name_styles.gd")

signal closed
signal whisper(name: String)
signal notice(text: String)

const BAR: float = 19.0
const ROW: float = 30.0
const ROW_W: float = 313.0
const SHOWN: Dictionary = {"corps": 6, "team": 4}
const MENU_TIME: float = 3.0
const LINK: Color = Color("086da5")
const LINK_ROLL: Color = Color("00adef")
const MENU_BG: Color = Color("e9f9ff", 0.98)
const MENU_NAME: Color = Color("f16422")
const PICK: Color = Color("ffff00")
const TITLE_RIM: Color = Color("737372", 0.8)
const FRIEND_SELF: String = "Không thể kết bạn với chính mình"
const BUSY: String = "Đang xử lý…"
const APPLIED: String = "Đã gửi yêu cầu cho [@clanName@]"
const GUILD_PATH: String = "/cGuildInfo.php?gid=%d&noCache=%s"
const TEAM_PATH: String = "/cTeamInfo.php?tid=%d&noCache=%s"
const MEMBER_PATH: String = "/cTeamMember.php?tid=%d&noCache=%s"
const CORPS_FIELDS: Array = ["txtClanName", "txtClanLeader", "txtNowNumber", "txtCorpsLevel"]
const TEAM_FIELDS: Array = ["txtClanName", "txtClanLeader", "lblLevel", "lblHonor", "lblTeamFund", "lblTeamCoutribute"]
const MENU_KEYS: Dictionary = {"friend": "btnAddFriend", "chat": "btnPrivateChat", "copy": "btnCopyName"}

var fetch: Callable
var _ctip: CTip = CTip.new()
var _mode: String = ""
var _values: Dictionary = {}
var _rows: Array = []
var _tid: int = 0
var _want: Dictionary = {}
var _http: Dictionary = {}
var _first: int = 0
var _pick: int = -1
var _list_rect: Rect2 = Rect2()
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_first: int = 0
var _pull: float = 0.0
var _click_at: Vector2 = Vector2.ZERO
var _menu_name: String = ""
var _menu_at: Vector2 = Vector2.ZERO
var _menu_rect: Rect2 = Rect2()
var _menu_hide_at: float = -1.0
var _befriend: String = ""
var _apply: Dictionary = {}

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)
	_use(Hall.FILE, Hall.R)
	_use(Guild.FILE, Guild.R)
	_use(Watch.FILE, Watch.R)
	_use(Join.FILE, Join.R)
	for kind: String in ["guild", "team", "member"]:
		var http: HTTPRequest = HTTPRequest.new()
		http.timeout = 10
		http.accept_gzip = false
		add_child(http)
		http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
			on_reply(kind, result, code, body))
		_http[kind] = http
	if client != null:
		client.friend_result.connect( func(_ok: bool, text: String) -> void :
			if not _befriend.is_empty():
				_befriend = ""
				if is_visible_in_tree():
					say(text))




func open_guild(gid: int) -> void :
	if gid <= 0 or client == null:
		return
	_apply = {}
	_ask("guild", gid, GUILD_PATH)


func open_apply(ids: Array, index: int, entries: Array) -> void :
	if client == null or index < 0 or index >= ids.size():
		return
	_apply = {"ids": ids.duplicate(), "cur": index, "entries": entries.duplicate(), "only": false, "gid": 0, "name": ""}
	_ask("guild", int(ids[index]), GUILD_PATH)


func show_search(data: Dictionary, entries: Array) -> void :
	_want.erase("guild")
	_apply = {"ids": [], "cur": 0, "entries": entries.duplicate(), "only": true}
	_take_apply(data)
	show_corps(data)

func apply_state() -> Dictionary:
	return _apply


func open_team_id(tid: int) -> void :
	if tid <= 0 or client == null:
		return
	_apply = {}
	_ask("team", tid, TEAM_PATH)


func open_team(row: Dictionary) -> void :
	_reset()
	_apply = {}
	_mode = "team"
	_tid = int(_num(row.get("team_id")))
	var title: String = _as_text(row.get("team_name"))
	_values = {"lblClanName": title, "txtClanName": title, "txtClanLeader": _as_text(row.get("team_leader")), 
		"lblLevel": str(int(_num(row.get("team_level")))), "lblHonor": str(int(_num(row.get("team_glory")))), 
		"lblTeamFund": str(int(_num(row.get("team_coin")))), "lblTeamCoutribute": str(int(_num(row.get("team_merit")))), "tip": ""}

	var keep: Array = GuildTeam.KEEP.get(str(int(_num(row.get("team_level")))), [])
	if not keep.is_empty():
		_values["tip"] = str(GuildTeam.WORDS["level_tip"]).replace("@num1@", str(int(keep[0]))) if int(keep[0]) > 0 else str(GuildTeam.WORDS["full_lv"])
	visible = true
	if _tid > 0:
		_ask("member", _tid, MEMBER_PATH)


func show_corps(data: Dictionary) -> void :
	_reset()
	_mode = "corps"
	var title: String = _as_text(data.get("szGuildName"))
	_values = {"lblClanName": title, "txtClanName": title, "txtClanLeader": _as_text(data.get("szGuildLeader")), 
		"txtNowNumber": str(int(_num(data.get("nGuildNumMember")))), "txtCorpsLevel": str(int(_num(data.get("nGuildLv"))))}
	var teams: Variant = data.get("allTeams")
	for item: Variant in (teams if teams is Array else []):
		if item is Dictionary:
			var team: Dictionary = item
			_rows.append({"name": _as_text(team.get("szTeamName")), "leader": _as_text(team.get("szTeamLeader")), 
				"place": int(_num(team.get("nTeamPlace"))), "count": int(_num(team.get("nTeamNumMember"))), 
				"vipPoints": int(_num(team.get("nTeamLeaderVippoint"))), "vipEndTime": _num(team.get("nTeamLeaderViptime")), 
				"superVipEndTime": _num(team.get("nTeamLeaderSuperViptime"))})
	visible = true

func close() -> void :
	for kind: String in _http:
		(_http[kind] as HTTPRequest).cancel_request()
	_want = {}
	if not visible:
		return
	visible = false
	_reset()
	_mode = ""
	_apply = {}
	closed.emit()

func is_open() -> bool:
	return visible and not _mode.is_empty()

func mode() -> String:
	return _mode

func values() -> Dictionary:
	return _values

func rows() -> Array:
	return _rows

func menu_name() -> String:
	return _menu_name


func chat_busy() -> bool:
	return visible

func _reset() -> void :
	_values = {}
	_rows = []
	_tid = 0
	_first = 0
	_pick = -1
	_grab = false
	_pull = 0.0
	_hover = ""
	_press = ""
	_hide_menu()
	if _http.has("member"):
		(_http["member"] as HTTPRequest).cancel_request()
	_want.erase("member")




func _ask(kind: String, id: int, path: String) -> void :
	var origin: String = str(client.config.origin)
	if origin.is_empty() and not fetch.is_valid():
		return
	var url: String = origin + path % [id, str(randf())]
	_want[kind] = id
	var done: int
	if fetch.is_valid():
		done = int(fetch.call(url))
	else:
		var http: HTTPRequest = _http[kind]
		http.cancel_request()
		done = http.request(url, AppSession.headers(url))
	if done != OK:
		_want.erase(kind)


func on_reply(kind: String, result: int, code: int, body: PackedByteArray) -> void :
	if not _want.has(kind):
		return
	var asked: int = int(_want[kind])
	_want.erase(kind)
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty():
		return
	var text: String = body.get_string_from_utf8()
	if text.strip_edges().is_empty():
		return
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return
	var data: Variant = json.data
	match kind:
		"guild":
			if data is Dictionary:


				if not _apply.is_empty():
					_take_apply(data)
				show_corps(data)
		"team":
			if data is Dictionary:
				open_team(data)
		"member":
			if is_open() and _mode == "team" and asked == _tid:
				_take_members(data)


func _take_apply(data: Dictionary) -> void :
	_apply["gid"] = int(_num(data.get("nGuildId")))
	_apply["name"] = _as_text(data.get("szGuildName"))


func _can_join() -> bool:
	var entries: Array = _apply.get("entries", [])
	var cur: int = int(_apply.get("cur", 0))
	if cur < 0 or cur >= entries.size() or not (entries[cur] is Dictionary):
		return true
	return bool((entries[cur] as Dictionary).get("ok", true))


func _step(by: int) -> void :
	var ids: Array = _apply.get("ids", [])
	var cur: int = int(_apply.get("cur", 0)) + by
	if cur < 0 or cur >= ids.size():
		return
	_apply["cur"] = cur
	_ask("guild", int(ids[cur]), GUILD_PATH)


func _join() -> void :
	var name: String = str(_apply.get("name", ""))
	if client.guild_join_apply(int(_apply.get("gid", 0)), "", false):
		notice.emit(APPLIED.replace("@clanName@", name))
	close()


func _take_members(data: Variant) -> void :
	var items: Array = []
	if data is Array:
		items = data
	elif data is Dictionary:
		items = (data as Dictionary).values()
	var found: Array = []
	for item: Variant in items:
		if not (item is Dictionary):
			continue
		var row: Dictionary = item
		found.append({"charUuid": _as_text(row.get("char_uuid")), "charName": _as_text(row.get("char_name")), 
			"charLevel": int(_num(row.get("char_level"))), "merit": int(_num(row.get("team_merit"))), 
			"vipEndTime": _num(row.get("char_viptime")), "superVipEndTime": _num(row.get("char_superviptime")), 
			"vipPoints": int(_num(row.get("char_vippoints"))), "sectionId": int(_num(row.get("elo_section_id")))})
	_rows = found
	_pick = -1
	_first = 0
	_hide_menu()

static func _num(value: Variant) -> float:
	if value is float or value is int:
		return float(value)
	if value is String and (value as String).is_valid_float():
		return float(value)
	return 0.0

static func _as_text(value: Variant) -> String:
	if value == null:
		return ""
	if value is float and is_equal_approx(value, roundf(value)):
		return str(int(value))
	return str(value)


func _vip(row: Dictionary) -> int:
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


func _post(uuid: String) -> String:
	var member: Dictionary = client.guild_members.get(uuid, {})
	if member.is_empty():
		return ""
	var team: Dictionary = {}
	for one: Dictionary in client.guild_teams:
		if int(one.get("nTeamId", 0)) == int(member.get("nTeamId", 0)):
			team = one
	if team.is_empty():
		return ""
	var text: String = "Team trưởng" if str(team.get("leaderUuid", "")) == uuid else "Thành viên"
	if uuid == str(client.guild.get("leaderUuid", "")):
		text += "(Guild trưởng)"
	elif uuid == str(client.guild.get("viceLeaderUuid", "")):
		text += "(Phó Guild)"
	return text




func _show_menu(nick: String) -> void :
	_menu_name = nick
	_menu_at = _click_at
	_menu_rect = Rect2(_menu_at * _f, Vector2(float(Watch.MENU[0]), float(Watch.MENU[1])) * _f)
	_menu_hide_at = _time + MENU_TIME

func _hide_menu() -> void :
	_menu_name = ""
	_menu_hide_at = -1.0
	_menu_rect = Rect2()

func _tick(_delta: float) -> void :
	if _menu_name.is_empty():
		return

	if _hover.begins_with("menu:") or _menu_rect.has_point(get_local_mouse_position()):
		_menu_hide_at = -1.0
	elif _menu_hide_at < 0.0:
		_menu_hide_at = _time + MENU_TIME
	if _menu_hide_at >= 0.0 and _time >= _menu_hide_at:
		_hide_menu()


func _add_friend(nick: String) -> void :
	if nick.is_empty():
		return
	if nick == str(client.character.get("name", "")):
		say(FRIEND_SELF)
		return
	if client.add_friend(nick, 0):
		_befriend = nick
	else:
		say(BUSY)



func _paint() -> void :
	if _mode.is_empty():
		return
	var box: Array = Watch.BOX
	var at: Vector2 = _bare_window(float(box[0]), float(box[1]), "close")
	if not _apply.is_empty():
		_fmid("public_window_button_bk", at + Vector2(0, float(box[1]) - 56.0), float(box[0]))
	var body: Array = Watch.BODY[_mode]
	_fblit(str(body[2]), at + Vector2(float(body[0]), float(body[1])))
	var texts: Dictionary = Watch.TEXTS_CORPS if _mode == "corps" else Watch.TEXTS_TEAM
	var head: Array = texts["lblClanName"]
	_fwords(_cut(str(_values.get("lblClanName", "")), ARIAL_BOLD, 17, float(head[2])), ARIAL_BOLD, 17, Color.WHITE, "c", 
		at + Vector2(float(head[0]), float(head[1])), float(head[2]), 2.0, 0.0, false, TITLE_RIM)
	for key: String in (CORPS_FIELDS if _mode == "corps" else TEAM_FIELDS):
		var cell: Array = texts[key]
		var room: float = float(cell[2]) - 24.0
		_fwords(_clip(str(_values.get(key, "")), ARIAL_BOLD, 13, room), ARIAL_BOLD, 13, Color.WHITE, str(cell[7]), 
			at + Vector2(float(cell[0]) + 12.0, float(cell[1]) + 5.0), room, 0.0, 0.0, false)
	var tip_rect: Rect2 = Rect2()
	if _mode == "team":
		var tip: Array = Watch.AT["tip"]
		tip_rect = Rect2((at + Vector2(float(tip[0]), float(tip[1]))) * _f, Vector2(float(tip[2]), float(tip[3])) * _f)
		_hit("tip", tip_rect, false)
	_draw_list(at)
	if not _apply.is_empty():
		_draw_apply(at)
	if not _menu_name.is_empty():
		_draw_menu()
	elif _hover == "tip" and _press.is_empty() and _tip_ok():
		_draw_tip(tip_rect, str(_values.get("tip", "")))
	else:
		_draw_tip(Rect2(), "")


func _bare_window(wide: float, high: float, close_id: String) -> Vector2:
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
	var spot: Array = Watch.AT["close"]
	_fbutton(close_id, "public_button_close", at + Vector2(float(spot[0]), float(spot[1])))
	return at



func _draw_apply(at: Vector2) -> void :
	var spots: Dictionary = Join.APPLY
	if not bool(_apply.get("only", false)):
		for key: String in ["base_l", "base_r"]:
			_fblit("gj_apply_base", at + Vector2(float(spots[key][0]), float(spots[key][1])))
		_fbutton("apply:pre", "gj_up", at + Vector2(float(spots["btnPre"][0]), float(spots["btnPre"][1])))
		_fbutton("apply:next", "gj_down", at + Vector2(float(spots["btnNext"][0]), float(spots["btnNext"][1])))
	var join: Vector2 = at + Vector2(float(spots["btnJoinClan"][0]), float(spots["btnJoinClan"][1]))
	if _can_join():
		_fbutton("apply:join", "gj_apply", join)
	else:
		_fblit("gj_apply_off", join)


func _draw_list(at: Vector2) -> void :
	var list: Array = Watch.LIST[_mode]
	var origin: Vector2 = at + Vector2(float(list[0]), float(list[1]))
	var high: float = float(list[3])
	var shown: int = int(SHOWN[_mode])
	_list_rect = Rect2(origin * _f, Vector2(float(list[2]), high) * _f)
	var count: int = _rows.size()
	_first = clampi(_first, 0, maxi(0, count - shown))
	for slot in range(mini(shown, count - _first)):
		var index: int = _first + slot
		var spot: Vector2 = origin + Vector2(0, ROW * slot)
		if _mode == "team":
			_hit("row:%d" % index, Rect2(spot * _f, Vector2(ROW_W, ROW) * _f), false)
			_draw_member(_rows[index], spot, index == _pick)
		else:
			_draw_team(_rows[index], spot)
	_vbar(origin + Vector2(ROW_W, 0), high, count, shown)


func _draw_team(row: Dictionary, at: Vector2) -> void :
	var cols: Dictionary = Watch.LEGION
	var spec: Array = cols["lblTeamName"]
	_fwords(_cut(str(row.get("name", "")), ARIAL_BOLD, 13, float(spec[2])), ARIAL_BOLD, 13, Color.WHITE, "l", 
		at + Vector2(float(spec[0]), 0), float(spec[2]), 0.0, ROW, false)
	spec = cols["lblPlayerName"]
	_draw_name(str(row.get("leader", "")), _vip(row), 13, at + Vector2(float(spec[0]), 0), float(spec[2]))
	spec = cols["lblRank"]
	_fwords(_cut(str(int(row.get("place", 0))), ARIAL_BOLD, 12, float(spec[2])), ARIAL_BOLD, 12, Color.WHITE, "c", 
		at + Vector2(float(spec[0]), 1), float(spec[2]), 0.0, ROW, false)
	spec = cols["lblMumberCount"]
	_fwords(_cut(str(int(row.get("count", 0))), ARIAL_BOLD, 13, float(spec[2])), ARIAL_BOLD, 13, Color.WHITE, "l", 
		at + Vector2(float(spec[0]), 0), float(spec[2]), 0.0, ROW, false)



func _draw_member(row: Dictionary, at: Vector2, picked: bool) -> void :
	if picked:
		_fround(Rect2(at + Vector2(0, -1), Vector2(314, 30)), Color(0, 0, 0, 0), 5.0, PICK, 3.0)
	_fblit("level_%d" % clampi(int(row.get("charLevel", 0)), 0, 40), at + Vector2(5, 5), 40.0, 20.0)
	_level_fx(int(row.get("charLevel", 0)), at + Vector2(5, 5), 40.0)
	var cols: Dictionary = GuildTeam.COLS
	var spec: Array = cols["lblPlayerName"]
	_draw_name(str(row.get("charName", "")), _vip(row), 12, at + Vector2(float(spec[0]), 0), float(spec[2]))
	var section: int = int(row.get("sectionId", 0))
	var virtue: String = str(GuildTeam.WORDS["no_section"])
	if section > 0:
		var entry: Array = []
		if pack != null:
			entry = pack.board.get("sections", {}).get(str(section), [])
		virtue = str(entry[0]) if entry.size() > 0 else HallScreen.section_name(section)
		var icon: Texture2D = pack.picture("l/bxh/s%d.webp" % (int(entry[1]) if entry.size() > 1 else HallScreen.medal(section))) if pack != null else null
		if icon != null and icon.get_width() > 4:
			draw_texture_rect(icon, Rect2((at + Vector2(126, 2)) * _f, Vector2(icon.get_width(), icon.get_height()) * 0.125 * _f), false)
	var words: Array = [["lblVirtue", virtue], ["lblMerit", str(int(row.get("merit", 0)))], ["lblPost", _post(str(row.get("charUuid", "")))]]
	for word: Array in words:
		var cell: Array = cols[str(word[0])]
		_fwords(_cut(str(word[1]), ARIAL_BOLD, 12, float(cell[2])), ARIAL_BOLD, 12, Color.WHITE, str(cell[7]), at + Vector2(float(cell[0]), 0), 
			float(cell[2]), 0.0, ROW, false)


func _draw_name(nick: String, vip: int, px: float, at: Vector2, wide: float) -> void :
	var shown: String = _cut(nick, ARIAL_BOLD, px, wide)
	var style: Array = HallScreen.name_style(clampi(vip % 100, 0, 12))
	var ink: PackedColorArray = NameStyles.colors_of(client, 0, nick)
	if not ink.is_empty():
		NameStyles.place(self, shown, ARIAL_BOLD, px, "l", at, wide, 1.0, ROW, false, NameStyles.tints(ink, nick.length()), true)
		style = [Color(0, 0, 0, 0), Color(0, 0, 0, 0)]
	_fwords(shown, ARIAL_BOLD, px, style[0], "l", at, wide, 1.0, ROW, false, style[1])


func _vbar(bar: Vector2, high: float, count: int, shown: int) -> void :
	var track: float = high - 2.0 * BAR
	_fblit("gu_sb_bk", bar + Vector2(0, BAR), BAR, track)
	_fbutton("sb:up", "gu_sb_up", bar)
	_fbutton("sb:down", "gu_sb_down", bar + Vector2(0, high - BAR))
	var most: int = maxi(0, count - shown)
	if most <= 0:
		return
	var thumb: float = maxf(20.0, track * float(shown) / float(maxi(1, count)))
	var top: float = BAR + roundf((track - thumb) * float(_first) / float(most))
	if top > BAR:
		_hit("sb:pgup", Rect2((bar + Vector2(0, BAR)) * _f, Vector2(BAR, top - BAR) * _f), false)
	if top + thumb < BAR + track:
		_hit("sb:pgdn", Rect2((bar + Vector2(0, top + thumb)) * _f, Vector2(BAR, BAR + track - top - thumb) * _f), false)
	_fslice("gu_sb_thumb", bar + Vector2(0, top), thumb, 4.0, _glow("slide:cw"))
	_hit("slide:cw", Rect2((bar + Vector2(0, top)) * _f, Vector2(BAR, thumb) * _f), false)


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


func _draw_menu() -> void :
	var at: Vector2 = _menu_at
	var box: Vector2 = Vector2(float(Watch.MENU[0]), float(Watch.MENU[1]))
	_hit("panel", _menu_rect, false)
	_fround(Rect2(at, box), MENU_BG, 10.0, Color.WHITE, 2.0)
	var head: Array = Watch.MENU_TEXTS["lblCharName"]
	_fwords(_menu_name, ARIAL_BOLD, float(head[4]), MENU_NAME, "l", at + Vector2(float(head[0]) + 2.0, float(head[1]) + 2.0), 
		box.x - float(head[0]) - 4.0, 0.0, 0.0, false)
	_fblit("cw_line", at + Vector2(float(Watch.LINE[0]), float(Watch.LINE[1])))
	var face: Font = _face(ARIAL_BOLD)
	for key: String in MENU_KEYS:
		var spec: Array = Watch.MENU_TEXTS[MENU_KEYS[key]]
		var label: String = str(Watch.WORDS[key])
		var id: String = "menu:" + key
		var px: float = float(spec[4])
		var wide: float = face.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f + 5.0
		var cell: Rect2 = Rect2(at + Vector2(float(spec[0]), float(spec[1])), Vector2(wide, 20))
		var ink: Color = LINK
		if _hover == id:
			_fround(cell, LINK_ROLL, 2.0)
			ink = Color.WHITE
		_fwords(label, ARIAL_BOLD, px, ink, "c", cell.position, cell.size.x, 0.0, 20.0, false)
		_hit(id, Rect2(cell.position * _f, cell.size * _f), false)


func _draw_tip(anchor: Rect2, body: String) -> void :
	_ctip.draw(self, (str(anchor) + body) if not body.is_empty() else "", body, get_local_mouse_position() / _f, Vector2(_fw, _fh), _f)


func _fround(rect: Rect2, fill: Color, radius: float, edge: Color = Color(0, 0, 0, 0), width: float = 0.0) -> void :
	_round(Rect2(rect.position * _f, rect.size * _f), fill, radius * 2.0, edge, width * 2.0)


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



func _scroll(first: int) -> void :
	_first = clampi(first, 0, maxi(0, _rows.size() - int(SHOWN.get(_mode, 1))))

func _activate(id: String) -> void :
	if id.begins_with("row:"):
		var index: int = int(id.substr(4))
		if _mode == "team" and index >= 0 and index < _rows.size():
			_pick = index
			_show_menu(str(_rows[index].get("charName", "")))
		return
	if id.begins_with("menu:"):

		var nick: String = _menu_name
		_hide_menu()
		match id.substr(5):
			"friend":
				_add_friend(nick)
			"chat":
				if not nick.is_empty():
					whisper.emit(nick)
			"copy":
				if DisplayServer.has_feature(DisplayServer.FEATURE_CLIPBOARD):
					DisplayServer.clipboard_set(nick)
		return
	var shown: int = int(SHOWN.get(_mode, 1))
	match id:
		"close":
			close()
		"apply:pre":
			_step(-1)
		"apply:next":
			_step(1)
		"apply:join":
			_join()
		"sb:up":
			_scroll(_first - 1)
		"sb:down":
			_scroll(_first + 1)
		"sb:pgup":
			_scroll(_first - shown)
		"sb:pgdn":
			_scroll(_first + shown)

func _wheel(step: int, at: Vector2) -> void :
	if _list_rect.has_point(at) and not _menu_rect.has_point(at):
		_scroll(_first + step * 3)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _grab or not _list_rect.has_point(from):
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, ROW * _f)
	while _pull >= pitch:
		_pull -= pitch
		_scroll(_first + 1)
	while _pull <= - pitch:
		_pull += pitch
		_scroll(_first - 1)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = event.position
		_click_at = pos / _f
		if event.pressed:
			_pull = 0.0
			if not _menu_name.is_empty() and not _menu_rect.has_point(pos):
				_hide_menu()
			if _hit_at(pos) == "slide:cw":
				_grab = true
				_grab_at = pos
				_grab_first = _first
		else:
			_grab = false
	elif event is InputEventMouseMotion and _grab:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
			_grab = false
		else:
			var shown: int = int(SHOWN.get(_mode, 1))
			var most: int = maxi(0, _rows.size() - shown)
			if most > 0:
				var track: float = float(Watch.LIST[_mode][3]) - 2.0 * BAR
				var thumb: float = maxf(20.0, track * float(shown) / float(maxi(1, _rows.size())))
				var step: float = maxf(0.001, (track - thumb) / float(most))
				_scroll(_grab_first + roundi((event.position.y - _grab_at.y) / _f / step))
			accept_event()
			return
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :


	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	var shown: int = int(SHOWN.get(_mode, 1))
	match event.keycode:
		KEY_ESCAPE:
			if not _menu_name.is_empty():
				_hide_menu()
			else:
				close()
		KEY_UP:
			_scroll(_first - 1)
		KEY_DOWN:
			_scroll(_first + 1)
		KEY_PAGEUP:
			_scroll(_first - shown)
		KEY_PAGEDOWN:
			_scroll(_first + shown)
		KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER:
			pass
		_:
			return
	get_viewport().set_input_as_handled()
