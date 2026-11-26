extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")




















const HallScreen = preload("hall_screen.gd")
const Hall = preload("hall_atlas.gd")
const Atlas = preload("leaderboard_atlas.gd")
const Last = preload("lastrank_atlas.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const LeagueReward = preload("league_reward.gd")
const CorpsWatch = preload("corps_watch.gd")
const NameStyles = preload("name_styles.gd")
const Challenge = preload("rank_challenge_atlas.gd")

signal closed
signal player_info_asked(uuid: String)
signal whisper(name: String)



const TABS: Array = [["elo", 4], ["tank", 10], ["guild", 0], ["glamour", 7], ["romantic", 8], ["team", 0], ["military", 11], ["pet", 6]]


const TAB_SLOT: Array = [0, 1, 2, 3, 4, 6, 7, 5]
const TAB_SIZE: Vector2 = Vector2(92, 39)
const PET_TAB: String = "Bảng Pet"
const PET_TAB_INK: Color = Color("9fd0ff")

const PET_HEADS: Array = [["TRỢ THỦ", 697], ["LỰC CHIẾN", 788]]

const PETROW: Dictionary = {"lblRank": [5, 16, 60, 0, 14, "ffffff", 1, "c"], "lblName": [111, 16, 116, 0, 14, "ffffff", 1, "l"], 
	"lblNameVip": [111, 16, 92, 0, 14, "ffffff", 1, "l"], "lblHelperName": [230, 16, 80, 0, 14, "ffffff", 1, "c"], 
	"lblValue": [321, 16, 80, 0, 14, "ffffff", 1, "c"]}
const PAGE: int = 10
const STALE: float = 60.0
const SIZE: Vector2 = Vector2(882, 532)
const DIM: Color = Color(0, 0, 0, 0.4)
const STRIPE: Color = Color(0, 83.0 / 255.0, 145.0 / 255.0, 68.0 / 255.0)
const SELECT: Color = Color("ffff00")
const PAGE_RIM: Color = Color(0.6, 0.4, 0.2, 0.8)
const CELL_RIM: Color = Color(0.2, 0.4, 0.4, 0.8)
const WIN: Color = Color("88ff00")
const LOSE: Color = Color("ff0000")
const TIP_SEASON: String = "0h ngày 1 hàng tháng sẽ tổng kết huy chương mùa giải, TOP 250 sẽ được nhận huy hiệu."
const TIP_TEAM: String = "0h thứ 3 hàng tuần tổng kết điểm Đấu Team, thành viên Team TOP10 được nhận thưởng"
const NONE: String = "Không"
const NO_SECTION: String = "Không Huy Chương"

const STRIPES: Dictionary = {
	"elo": [[496, 138, 200, 332]], "glamour": [[496, 138, 200, 332]], "romantic": [[496, 138, 200, 332]], "military": [[496, 138, 200, 332]], 
	"tank": [[496, 138, 160, 332], [716, 138, 40, 331]], 
	"pet": [[496, 138, 160, 332], [738, 138, 100, 331]], 
	"guild": [[129, 145, 200, 310], [529, 145, 80, 310], [689, 145, 80, 310]], 
	"team": [[129, 145, 200, 320], [439, 145, 110, 320], [659, 145, 110, 320]], 
}
const LIST: Vector2 = Vector2(427, 138)
const WIDE: Vector2 = Vector2(51, 145)
const CORPS_FLOOR: float = 455.0
const ROW_H: float = 32.0
const GRID: Vector2 = Vector2(36, 114)
const CELL: Vector2 = Vector2(168, 117)
const AVATAR: Vector2 = Vector2(36, 120)

const LAST_PATH: String = "/cteamlastweekrank.php?noCache=%s"
const LAST_STALE: float = 60.0
const LAST_TOP: int = 10
const LAST_WIDE: float = 718.0

const CH_LIFT: Vector2 = Vector2(0, -33)
const CH_PATH: String = "/cchallengerankquery.php?p=%d&li=%d"
const TYPES_PATH: String = "/ctoppowertanklist.php?&noCache=%s"
const GRID_ROWS: int = 3
const GRID_WHEEL: int = 3
const TRACK: float = 322.0
const CH_STRIPE: Array = [496, 138, 200, 332]
const TIP_CHALLENGE: String = "20:00 mỗi tối sẽ tổng kết thưởng xếp hạng"

var tab: String = ""
var _tab: int = 0
var _page: int = 0
var _pick: int = 0
var _cache: Dictionary = {}
var _mine: Dictionary = {}
var _list_http: HTTPRequest
var _self_http: HTTPRequest
var _want: String = ""
var _self_want: String = ""
var _failed: String = ""
var _last_open: bool = false
var _last_rows: Variant = null
var _last_at: float = -1000000000.0
var _last_busy: bool = false
var _last_failed: bool = false
var _last_pick: int = -1
var _last_http: HTTPRequest
var _last_get: Callable
var _cut_box: StyleBoxFlat = StyleBoxFlat.new()
var _reward: Control = null
var _watch: Control = null
var _challenge: bool = false
var _ch_pick: Dictionary = {}
var _types: Variant = null
var _types_http: HTTPRequest
var _types_busy: bool = false
var _types_failed: bool = false
var _tank_id: int = 0
var _type_pick: int = 0
var _type_top: int = 0

func _setup() -> void :
	_list_http = _request(_on_list)
	_self_http = _request(_on_self)
	_last_http = _request(_on_last)
	_types_http = _request(_on_types)
	_last_get = func(url: String) -> int: return _last_http.request(url, AppSession.headers(url))
	_cut_box.bg_color = Color(0, 0, 0, 0)
	_cut_box.border_color = SELECT
	_cut_box.anti_aliasing = true

func _request(done: Callable) -> HTTPRequest:
	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 10
	http.accept_gzip = false
	add_child(http)
	http.request_completed.connect(done)
	return http


func chat_busy() -> bool:
	return _last_open or reward_open() or watch_open()

func reward_open() -> bool:
	return _reward != null and _reward.visible


func _open_reward() -> void :
	if _reward == null:
		_reward = LeagueReward.new()
		_reward.client = client
		_reward.pack = pack
		_reward.hall = hall
		add_child(_reward)
		_reward.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_reward.open()

func watch_open() -> bool:
	return _watch != null and _watch.visible


func _open_watch() -> Control:
	if _watch == null:
		_watch = CorpsWatch.new()
		_watch.visible = false
		_watch.client = client
		_watch.pack = pack
		_watch.hall = hall
		add_child(_watch)
		_watch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_watch.whisper.connect( func(who: String) -> void : whisper.emit(who))
	return _watch

func _shown() -> void :
	_last_open = false
	if _reward != null:
		_reward.close()
	if _watch != null:
		_watch.close()
	if not is_visible_in_tree():
		return
	_tab = 0
	for index: int in TABS.size():
		if TABS[index][0] == tab:
			_tab = index
	_challenge = tab == "challenge"
	_ch_pick = {}
	tab = ""
	_page = 0
	_pick = 0
	_mine.clear()
	_failed = ""
	_types = null
	_types_failed = false
	_tank_id = 0
	_type_pick = 0
	_type_top = 0
	pack.load_board()
	pack.load_garage()
	pack.load_rank()
	pack.load_bag()



func _key() -> String:
	if _challenge:
		return "ch:%d" % _page
	return "%d:%d:%d" % [_tab, _tank_id, _page] if _kind() == "tank" else "%d:%d" % [_tab, _page]


func _mine_key() -> String:
	return "tank:%d" % _tank_id if _kind() == "tank" else _kind()

func _rt() -> int:
	return int(TABS[_tab][1])

func _kind() -> String:
	return "challenge" if _challenge else str(TABS[_tab][0])

func _data() -> Dictionary:
	return _cache.get(_key(), {})

func _rows() -> Array:
	return _data().get("rows", [])

func _pages() -> int:
	return maxi(1, ceili(float(int(_data().get("amount", 0))) / PAGE))


func _list_path() -> String:
	match _kind():
		"guild":
			return "/cguildranklist.php?p=%d&li=%d" % [_page + 1, PAGE]
		"team":
			return "/cteamserverlist.php?p=%d&li=%d" % [_page + 1, PAGE]
		"challenge":
			return CH_PATH % [_page, PAGE]
	return "/crankquery.php?rt=%d&p=%d&limit=%d&tid=%d" % [_rt(), _page, PAGE, _tank_id if _kind() == "tank" else 0]

func _tick(_delta: float) -> void :
	if _challenge and _ch_pick.is_empty() and _page == 0 and not _rows().is_empty():
		_ch_pick = _rows()[0]
	var origin: String = client.config.origin
	if origin.is_empty():
		return
	var mine: String = _kind()
	if mine == "tank" and _types == null and not _types_busy and not _types_failed:
		_types_busy = true
		var types_url: String = origin + TYPES_PATH % str(randf())
		if _types_http.request(types_url, AppSession.headers(types_url)) != OK:
			_types_busy = false
			_types_failed = true
	if mine == "tank" and _tank_id <= 0:
		return
	var key: String = _key()
	var have: Dictionary = _cache.get(key, {})
	var fresh: bool = not have.is_empty() and _time - float(have.get("at", 0.0)) < STALE
	if not fresh and _want != key and _failed != key:
		_list_http.cancel_request()
		_want = key
		var list_url: String = origin + _list_path()
		if _list_http.request(list_url, AppSession.headers(list_url)) != OK:
			_want = ""
			_failed = key
	var slot: String = _mine_key()
	if not _mine.has(slot) and _self_want.is_empty():
		var url: String = ""
		if mine == "guild":
			var gid: int = int(client.guild.get("nGuildId", 0))
			if gid != 0:
				url = origin + "/cguildinfo.php?gid=%d" % gid
			else:
				_mine[slot] = -1
		elif mine == "team" or mine == "challenge" or mine == "pet":
			_mine[slot] = -1
		elif client.account_id > 0:
			url = origin + "/ccharrankquery.php?rt=%d&char=%d&ti=%d" % [_rt(), client.account_id, _tank_id if mine == "tank" else 0]
		if not url.is_empty():
			_self_want = slot
			if _self_http.request(url, AppSession.headers(url)) != OK:
				_self_want = ""
				_mine[slot] = -1

func _on_list(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	var key: String = _want
	_want = ""
	if key.is_empty():
		return
	var data: Variant = JSON.parse_string(body.get_string_from_utf8()) if result == HTTPRequest.RESULT_SUCCESS and code == 200 else null
	if not data is Dictionary:
		_failed = key
		return
	var rows: Variant = data.get("rank", data.get("datas", []))
	if key.begins_with("ch:"):
		rows = challenge_rows(rows)
	_cache[key] = {"amount": int(data.get("amount", 0)), "rows": rows if rows is Array else [], "at": _time}
	if key == _key():
		_pick = clampi(_pick, 0, maxi(0, _rows().size() - 1))

func _on_self(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	var kind: String = _self_want
	_self_want = ""
	if kind.is_empty():
		return
	var data: Variant = JSON.parse_string(body.get_string_from_utf8()) if result == HTTPRequest.RESULT_SUCCESS and code == 200 else null
	if not data is Dictionary:
		_mine[kind] = -1
		return
	_mine[kind] = int(data.get("nGuildRank", -1)) if kind == "guild" else int(data.get("total_rank", -1))


func _on_types(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_types_busy = false
	var data: Variant = JSON.parse_string(body.get_string_from_utf8()) if result == HTTPRequest.RESULT_SUCCESS and code == 200 else null
	if not data is Array:
		_types_failed = true
		return
	_set_types(known_types(tank_types(data), pack.lobby.get("tanks", {}) if pack != null and pack.lobby is Dictionary else {}))



static func known_types(rows: Array, names: Variant) -> Array:
	if not names is Dictionary or (names as Dictionary).is_empty():
		return rows
	return rows.filter( func(row: Dictionary) -> bool: return (names as Dictionary).has(str(int(row.get("char_maintank", 0)))))

func _set_types(rows: Array) -> void :
	_types = rows
	_type_pick = 0
	_type_top = 0
	if not rows.is_empty():
		_pick_type(0)



static func tank_types(source: Variant) -> Array:
	var out: Array = []
	if not source is Array:
		return out
	for item: Variant in source:
		if not item is Dictionary:
			continue
		var who: Variant = item.get("char_name", "")
		var uuid: Variant = item.get("char_uuid", "")
		out.append({
			"char_maintank": _whole(item.get("char_maintank", 0)), 
			"char_maintank_l": _whole(item.get("char_maintank_l", 1)), 
			"char_maintank_e": _whole(item.get("external_id", 0)), 
			"halo_id": _whole(item.get("halo_id", 0)), 
			"char_name": "" if who == null else str(who), 
			"char_uuid": "" if uuid == null else str(uuid), 
			"char_oid": _whole(item.get("char_oid", 0)), 
			"char_vippoint": _whole(item.get("char_vippoints", 0)), 
			"char_vip_time": _whole(item.get("char_viptime", 0)), 
			"char_super_vip_time": _whole(item.get("char_superviptime", 0)), 
		})
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a["char_maintank"]) > int(b["char_maintank"]))
	return out


func _pick_type(index: int) -> void :
	var rows: Array = _types if _types is Array else []
	if index < 0 or index >= rows.size():
		return
	_type_pick = index
	var tank_id: int = int(rows[index].get("char_maintank", 0))
	if tank_id == _tank_id:
		return
	_tank_id = tank_id
	_page = 0
	_pick = 0
	_failed = ""

func _type_rows() -> int:
	return ceili(float((_types as Array).size() if _types is Array else 0) / 2.0)

func _scroll_types(step: int) -> void :
	_type_top = clampi(_type_top + step, 0, maxi(0, _type_rows() - GRID_ROWS))



static func challenge_rows(source: Variant) -> Array:
	var out: Array = []
	if not source is Array:
		return out
	for item: Variant in source:
		if not item is Dictionary:
			continue
		var who: Variant = item.get("charName", "")
		var uuid: Variant = item.get("charUuid", "")
		out.append({
			"char_rank": _whole(item.get("rank", 0)), 
			"char_oid": _whole(item.get("charOid", 0)), 
			"char_uuid": "" if uuid == null else str(uuid), 
			"char_name": "" if who == null else str(who), 
			"char_level": _whole(item.get("charLevel", 0)), 
			"char_avatar": _whole(item.get("charAvatar", 0)), 
			"char_vippoint": _whole(item.get("charVippoint", 0)), 
			"char_vip_time": _whole(item.get("charViptime", 0)), 
			"char_super_vip_time": _whole(item.get("charSuperViptime", 0)), 
			"char_maintank": _whole(item.get("tankId", 0)), 
			"char_maintank_l": _whole(item.get("tankLevel", 1)), 
			"char_maintank_e": _whole(item.get("tankExtId", 0)), 
			"halo_id": _whole(item.get("halo_id", 0)), 
			"char_honor": _whole(item.get("char_honor", 0)), 
			"char_point": _whole(item.get("charAtk", 0)), 
		})
	return out



func _clock() -> float:
	return Time.get_ticks_msec() / 1000.0



func _open_last() -> void :
	_last_open = true
	_last_pick = -1
	var now: float = _clock()
	if now - _last_at > LAST_STALE or _last_rows == null:
		_last_at = now
		_fetch_last()

func _fetch_last() -> void :
	var origin: String = client.config.origin
	if origin.is_empty():
		return
	_last_http.cancel_request()
	_last_busy = true
	_last_failed = false
	if int(_last_get.call(origin + LAST_PATH % str(randf()))) != OK:
		_last_busy = false
		_last_failed = true


func _on_last(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_last_busy = false
	var text: String = body.get_string_from_utf8() if result == HTTPRequest.RESULT_SUCCESS and code == 200 else ""
	var data: Variant = JSON.parse_string(text) if not text.strip_edges().is_empty() else null
	if not (data is Array or data is Dictionary):
		_last_failed = true
		return
	_last_failed = false
	_last_rows = last_rows(data)

static func _whole(value: Variant) -> int:
	if value is int or value is float or value is bool:
		return int(value)
	return int(str(value).to_float()) if value is String and str(value).is_valid_float() else 0




static func last_rows(data: Variant) -> Array:
	var source: Variant = data.get("datas", []) if data is Dictionary else data
	var out: Array = []
	if not source is Array:
		return out
	for item: Variant in source:
		if not item is Dictionary:
			continue
		var rank: int = _whole(item.get("rank", item.get("team_place", 0)))
		var team: Variant = item.get("name", item.get("team_name", ""))
		out.append({
			"team_id": _whole(item.get("teamid", item.get("team_id", 0))), 
			"team_name": "" if team == null else str(team), 
			"rank": rank if rank > 0 else out.size() + 1, 
			"team_score": _whole(item.get("score", item.get("team_score", 0))), 
			"team_wins": _whole(item.get("win", item.get("team_wins", 0))), 
			"team_loses": _whole(item.get("lose", item.get("team_loses", 0))), 
			"team_glory": _whole(item.get("glory", item.get("team_glory", 0))), 
		})
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a["rank"]) < int(b["rank"]))
	return out.slice(0, LAST_TOP)

func _last_list() -> Array:
	return _last_rows if _last_rows is Array else []

func _last_hint() -> String:
	if _last_busy:
		return "Đang tải…"
	if _last_failed:
		return "Không tải được bảng xếp hạng"
	return "Đang tải…" if _last_rows == null else "Chưa có ai trong bảng này"


func _section(id: int) -> Array:
	return pack.board.get("sections", {}).get(str(id), [])


func _military(stars: int) -> Array:
	var best: Array = []
	for entry: Array in pack.rank.get("ranks", []):
		var nodes: Array = entry[2]
		if not nodes.is_empty() and int(nodes[0][0]) <= stars:
			best = [str(entry[0]), int(entry[1])]
	return best


func _vip_of(points: int, over: float, super_over: float) -> int:
	var now: float = Time.get_unix_time_from_system()
	if over > 100000000000.0:
		over /= 1000.0
	if super_over > 100000000000.0:
		super_over /= 1000.0
	if over - now <= 0.0:
		return 0
	return _vip_level(points) + (100 if super_over > now else 0)

func _row_vip(row: Dictionary) -> int:
	return _vip_of(int(row.get("char_vippoint", 0)), float(row.get("char_vip_time", 0)), float(row.get("char_super_vip_time", 0)))


func _standing(row: Dictionary, index: int) -> int:
	var place: int = 0
	match _kind():
		"guild":
			place = int(row.get("rank", 0))
		"team":
			place = int(row.get("team_place", row.get("rank", 0)))
		_:
			place = int(row.get("char_rank", 0))
	return place if place > 0 else _page * PAGE + index + 1


func _grid() -> Array:
	var count: int = (_types as Array).size() if _types is Array else 0
	var out: Array = []
	for index: int in range(_type_top * 2, mini(count, (_type_top + GRID_ROWS) * 2)):
		out.append(index)
	return out

func _waiting_text() -> String:
	if _kind() == "tank" and _tank_id <= 0:
		return "Không tải được bảng xếp hạng" if _types_failed else ("Đang tải…" if _types == null else "Chưa có ai trong bảng này")
	return "Không tải được bảng xếp hạng" if _failed == _key() else ("Đang tải…" if _data().is_empty() else "Chưa có ai trong bảng này")



func _paint() -> void :
	if _cells.is_empty():
		_use(Hall.FILE, Hall.R)
		_use(Atlas.FILE, Atlas.R)
		_use(Last.FILE, Last.R)
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	if _challenge:
		_paint_challenge()
		return
	var base: Vector2 = _centre(SIZE.x, SIZE.y)
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_fblit("lb_frame", base + Vector2(float(Atlas.FRAME[0]), float(Atlas.FRAME[1])))
	_draw_tabs(base)
	var kind: String = _kind()
	if kind == "guild" or kind == "team":
		_wide_box(base + Vector2(47, 141), 318.0 if kind == "guild" else 328.0)
	else:
		_small_box(base + Vector2(423, 134))
	for stripe: Array in STRIPES[kind]:
		draw_rect(Rect2((base + Vector2(float(stripe[0]), float(stripe[1]))) * _f, Vector2(float(stripe[2]), float(stripe[3])) * _f), STRIPE)
	for head: Array in Atlas.HEADS.get(kind, []):
		_fblit(str(head[0]), base + Vector2(float(head[1]), float(head[2])))
	if kind == "team":
		for head: Array in Atlas.TEAM_HEADS:
			_fwords(str(head[0]), BOLD, 12.0, Color.WHITE, "c", base + Vector2(float(head[1]) - 60.0, 132.5 - 12.0), 120.0, 1.0, 24.0)
	if kind == "pet":
		_fblit("lb_h_1a797c6c", base + Vector2(446, 119))
		_fblit("lb_h_fe814209", base + Vector2(544, 119))
		for head: Array in PET_HEADS:
			_fwords(str(head[0]), BOLD, 12.0, Color.WHITE, "c", base + Vector2(float(head[1]) - 50.0, 127.5 - 12.0), 100.0, 1.0, 24.0)
	var rows: Array = _rows()
	match kind:
		"pet":
			_draw_avatar(base, pet_stage_row(rows[_pick]) if _pick < rows.size() else {})
			for index: int in mini(rows.size(), PAGE):
				_pet_row(index, rows[index], base + LIST + Vector2(0, index * ROW_H))
			if rows.is_empty():
				_fwords(_waiting_text(), BOLD, 14.0, Color.WHITE, "c", base + LIST + Vector2(0, 150), 411.0, 1.0, 24.0)
		"guild", "team":
			for index: int in mini(rows.size(), PAGE):
				_wide_row(index, rows[index], base + WIDE + Vector2(0, index * ROW_H), base)
			if rows.is_empty():
				_fwords(_waiting_text(), BOLD, 14.0, Color.WHITE, "c", base + WIDE + Vector2(0, 140), 780.0, 1.0, 24.0)
		"tank":
			_draw_grid(base)
			for index: int in mini(rows.size(), PAGE):
				_tank_row(index, rows[index], base + LIST + Vector2(0, index * ROW_H))
			if rows.is_empty():
				_fwords(_waiting_text(), BOLD, 14.0, Color.WHITE, "c", base + LIST + Vector2(0, 150), 411.0, 1.0, 24.0)
		_:
			_draw_avatar(base, rows[_pick] if _pick < rows.size() else {})
			for index: int in mini(rows.size(), PAGE):
				_player_row(index, rows[index], base + LIST + Vector2(0, index * ROW_H))
			if rows.is_empty():
				_fwords(_waiting_text(), BOLD, 14.0, Color.WHITE, "c", base + LIST + Vector2(0, 150), 411.0, 1.0, 24.0)
	_draw_foot(base)
	_fbutton("close", "lb_close", base + Vector2(843, 33))
	if _last_open:
		_draw_last()



func _paint_challenge() -> void :
	if not _cells.has("lbc_frame"):
		_use(Challenge.FILE, Challenge.R)
	var base: Vector2 = _centre(float(Challenge.SIZE[0]), float(Challenge.SIZE[1]))
	_hit("panel", Rect2(base * _f, Vector2(float(Challenge.SIZE[0]), float(Challenge.SIZE[1])) * _f), false)
	_fblit("lbc_frame", base + Vector2(float(Challenge.FRAME[0]), float(Challenge.FRAME[1])))
	var spec: Array = Challenge.MAIN["btnMilitaryRank"]
	var at: Vector2 = base + Vector2(float(spec[0]), float(spec[1]))
	_fblit("lb_t_military", at, 0.0, 0.0, _glow("tab:6"))
	_hit("tab:6", Rect2(at * _f, Vector2(float(spec[2]), float(spec[3])) * _f), false)
	var lift: Vector2 = base + CH_LIFT
	_small_box(lift + Vector2(423, 134))
	draw_rect(Rect2((lift + Vector2(float(CH_STRIPE[0]), float(CH_STRIPE[1]))) * _f, Vector2(float(CH_STRIPE[2]), float(CH_STRIPE[3])) * _f), STRIPE)
	for head: Array in Challenge.HEADS:
		_fblit(str(head[0]), base + Vector2(float(head[1]), float(head[2])))
	_draw_avatar(lift, _ch_pick)
	var rows: Array = _rows()
	for index: int in mini(rows.size(), PAGE):
		_challenge_row(index, rows[index], lift + LIST + Vector2(0, index * ROW_H))
	if rows.is_empty():
		_fwords(_waiting_text(), BOLD, 14.0, Color.WHITE, "c", lift + LIST + Vector2(0, 150), 411.0, 1.0, 24.0)
	_draw_foot(lift)
	_fbutton("close", "lb_close", base + Vector2(float(Challenge.MAIN["btnClose"][0]), float(Challenge.MAIN["btnClose"][1])))


func _challenge_row(index: int, row: Dictionary, o: Vector2) -> void :
	var spec: Dictionary = Challenge.ROW
	_fblit("lb_cut", o + Vector2(0, 30))
	if not _ch_pick.is_empty() and int(row.get("char_oid", 0)) == int(_ch_pick.get("char_oid", -1)):
		_round(Rect2(o * _f, Vector2(409, 30) * _f), Color(0, 0, 0, 0), 10.0, SELECT, 6.0)
	_place_mark(_standing(row, index), spec["lblRank"], o, true)
	_level(int(row.get("char_level", 0)), o + Vector2(72, 6))
	var vip: int = _row_vip(row)
	var style: Array = HallScreen.name_style(vip % 100)
	_name_label(spec["lblName"], str(row.get("char_name", "")), o, true, style[0], style[1])
	_small_vip(vip, o + Vector2(238, 8.5))
	_label(spec["lblValue"], str(int(row.get("char_point", 0))), o, true)
	_hit("row:%d" % index, Rect2(o * _f, Vector2(411, ROW_H) * _f), false)



func _draw_last() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(float(Last.SIZE[0]), float(Last.SIZE[1]))
	_hit("panel", Rect2(base * _f, Vector2(float(Last.SIZE[0]), float(Last.SIZE[1])) * _f), false)
	_fblit("lw_frame", base + Vector2(float(Last.FRAME[0]), float(Last.FRAME[1])))
	for stripe: Array in Last.STRIPES:
		draw_rect(Rect2((base + Vector2(float(stripe[0]), float(stripe[1]))) * _f, Vector2(float(stripe[2]), float(stripe[3])) * _f), STRIPE)
	for head: Array in Last.HEADS:
		_fwords(str(head[0]), BOLD, 12.0, Color.WHITE, "c", base + Vector2(float(head[1]) - 60.0, float(Last.HEAD_Y) - 12.0), 120.0, 1.0, 24.0)
	var top: Vector2 = base + Vector2(float(Last.LIST[0]), float(Last.LIST[1]))
	var rows: Array = _last_list()
	for index: int in rows.size():
		_last_row(index, rows[index], top + Vector2(0, index * ROW_H))
	if rows.is_empty():
		_fwords(_last_hint(), BOLD, 14.0, Color.WHITE, "c", top + Vector2(0, 140), LAST_WIDE, 1.0, 24.0)
	_fbutton("last:close", "lb_close", base + Vector2(float(Last.CLOSE[0]), float(Last.CLOSE[1])))


func _last_row(index: int, row: Dictionary, o: Vector2) -> void :
	var spec: Dictionary = Atlas.TEAM
	_fpart("lb_cut_w", o + Vector2(0, 30), Rect2(0, 0, LAST_WIDE, 2))
	if index == _last_pick:
		_cut_select(Rect2(o * _f, Vector2(LAST_WIDE, 30) * _f))
	var place: int = int(row.get("rank", 0))
	if place >= 1 and place <= 50:
		_fblit("lb_cr%d" % place, o + Vector2(23, -1))
	else:
		_label(spec["lblRank"], str(place), o, false)
	_label(spec["lblClanName"], str(row.get("team_name", "")), o, false)
	_label(spec["lblScore"], str(int(row.get("team_score", 0))), o, false)
	_win_text(row, o, spec["lblWin"])
	var wins: int = int(row.get("team_wins", 0))
	var loses: int = int(row.get("team_loses", 0))
	_label(spec["lblWinRate"], "%d%%" % (wins * 100 / (wins + loses) if wins + loses > 0 else 0), o, false)
	_label(spec["lblGlory"], str(int(row.get("team_glory", 0))), o, false)
	_hit("last:row:%d" % index, Rect2(o * _f, Vector2(LAST_WIDE, ROW_H) * _f), false)


func _cut_select(rect: Rect2) -> void :
	var radius: int = maxi(1, roundi(minf(10.0 * _u, rect.size.y / 2.0)))
	var width: int = maxi(1, roundi(6.0 * _u))
	_cut_box.corner_radius_top_left = radius
	_cut_box.corner_radius_bottom_left = radius
	_cut_box.corner_radius_top_right = 0
	_cut_box.corner_radius_bottom_right = 0
	_cut_box.border_width_left = width
	_cut_box.border_width_top = width
	_cut_box.border_width_bottom = width
	_cut_box.border_width_right = 0
	draw_style_box(_cut_box, rect)






const PET_WORD_SIZE: Vector2 = Vector2(56, 21)
const PET_WORD_PNG: Array = [
	"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"]
static var _pet_words: Array = []
static func pet_word(on: bool) -> Texture2D:
	if _pet_words.is_empty():
		for raw: String in PET_WORD_PNG:
			var image: Image = Image.new()
			_pet_words.append(ImageTexture.create_from_image(image) if image.load_png_from_buffer(Marshalls.base64_to_raw(raw)) == OK else null)
	return _pet_words[1 if on else 0]



const XHTAB1_X0: float = 58.0
static func tab_at(index: int) -> Vector2:
	return Vector2(XHTAB1_X0 + float(TAB_SLOT[index]) * 96.0, 71.0)

func _draw_tabs(base: Vector2) -> void :
	for index: int in TABS.size():
		var code: String = str(TABS[index][0])
		var at: Vector2 = base + tab_at(index)
		var id: String = "tab:%d" % index
		var on: bool = index == _tab
		var tint: Color = _glow(id) if not on else Color.WHITE
		if code == "military":
			_fblit("lb_t_military_on" if on else "lb_t_military", at, TAB_SIZE.x, TAB_SIZE.y, tint)
		else:
			_fblit("lb_plate", at, TAB_SIZE.x, TAB_SIZE.y, tint)
			if on:
				_fblit("lb_sel", at, TAB_SIZE.x, TAB_SIZE.y)
			if code == "pet":
				var art: Texture2D = pet_word(on)
				if art != null:
					draw_texture_rect(art, Rect2((at + Vector2((TAB_SIZE.x - PET_WORD_SIZE.x) / 2.0 + 6.0, (TAB_SIZE.y - PET_WORD_SIZE.y) / 2.0)) * _f, PET_WORD_SIZE * _f), false, tint)
				else:
					_fwords(PET_TAB, BOLD, 11.0, Color.WHITE if on or _hover == id else PET_TAB_INK, "c", at + Vector2(8, 7.5), 84.0, 1.0, 24.0)
			else:
				var word: String = ("lb_t_%s_on" if on else "lb_t_%s") % code
				var cell: Vector2 = _cell_size(word)
				_fblit(word, at + Vector2((TAB_SIZE.x - cell.x) / 2.0 + 6.0, (TAB_SIZE.y - cell.y) / 2.0), 0.0, 0.0, tint)
		_hit(id, Rect2(at * _f, TAB_SIZE * _f), false)


func _small_box(at: Vector2) -> void :
	draw_rect(Rect2((at + Vector2(19, 19)) * _f, Vector2(382, 302) * _f), Color(str(Atlas.FILL)))
	_fpart("lb_e_t", at + Vector2(19, 0), Rect2(0, 0, 382, 19))
	_fblit("lb_e_b34", at + Vector2(19, 321))
	_fblit("lb_e_l", at + Vector2(0, 19))
	_fblit("lb_e_r67", at + Vector2(401, 19))
	_fblit("lb_c_tl", at)
	_fblit("lb_c_tr", at + Vector2(401, 0))
	_fblit("lb_c_bl", at + Vector2(0, 321))
	_fblit("lb_c_br", at + Vector2(401, 321))


func _wide_box(at: Vector2, high: float) -> void :
	var side: float = high - 38.0
	draw_rect(Rect2((at + Vector2(19, 19)) * _f, Vector2(750, side) * _f), Color(str(Atlas.FILL)))
	_fblit("lb_e_t", at + Vector2(19, 0))
	_fblit("lb_e_bf", at + Vector2(19, high - 19.0))
	_fpart("lb_e_l", at + Vector2(0, 19), Rect2(0, 0, 19, side))
	_fpart("lb_e_rf", at + Vector2(769, 19), Rect2(0, 0, 19, side))
	_fblit("lb_c_tl", at)
	_fblit("lb_c2_tr", at + Vector2(769, 0))
	_fblit("lb_c2_bl", at + Vector2(0, high - 19.0))
	_fblit("lb_c2_br", at + Vector2(769, high - 19.0))


func _label(spec: Array, text: String, o: Vector2, mid: bool, tint: Color = Color(0, 0, 0, 0), rim: Color = SHADE, edge: float = 1.0) -> void :
	if text.is_empty():
		return
	var wide: float = float(spec[2])
	var left: float = float(spec[0])
	var align: String = str(spec[7])
	if wide <= 0.0:
		wide = 600.0
		if align == "c":
			left -= 300.0
		elif align == "r":
			left -= 600.0
	var top: float = float(spec[1]) - (12.0 if mid else 0.0)
	var ink: Color = Color(str(spec[5])) if tint.a <= 0.0 else tint
	_fwords(text, BOLD if int(spec[6]) == 1 else REGULAR, float(spec[4]), ink, align, o + Vector2(left, top), wide, edge, 24.0 if mid else 0.0, float(spec[2]) > 0.0, rim)



func _name_label(spec: Array, text: String, o: Vector2, mid: bool, tint: Color, rim: Color) -> void :
	if text.is_empty():
		return
	var wide: float = float(spec[2])
	var left: float = float(spec[0])
	var align: String = str(spec[7])
	if wide <= 0.0:
		wide = 600.0
		if align == "c":
			left -= 300.0
		elif align == "r":
			left -= 600.0
	var top: float = float(spec[1]) - (12.0 if mid else 0.0)
	if not NameStyles.paint(self, text, BOLD if int(spec[6]) == 1 else REGULAR, float(spec[4]), align, o + Vector2(left, top), wide, 1.0, 
			24.0 if mid else 0.0, float(spec[2]) > 0.0):
		_label(spec, text, o, mid, tint, rim)


func _photo(path: String, rect: Rect2) -> bool:
	var picture: Texture2D = pack.picture(path) if not path.is_empty() else null
	if picture == null or picture.get_width() <= 4:
		return false
	draw_texture_rect(picture, Rect2(rect.position * _f, rect.size * _f), false)
	return true


func _art_scaled(path: String, left: float, mid: float, scale: float) -> void :
	var picture: Texture2D = pack.picture(path)
	if picture == null:
		return
	var box: Vector2 = Vector2(picture.get_width(), picture.get_height()) * scale
	draw_texture_rect(picture, Rect2(Vector2(left, mid - box.y / 2.0) * _f, box * _f), false)

func _honor_art(honor: int) -> String:
	if honor <= 0:
		return ""
	var entry: Array = pack.bag.get("honors", {}).get(str(honor), [])
	var art: String = str(entry[2]) if entry.size() > 2 else ""
	return "l/hn/%s.webp" % art if not art.is_empty() else ""


func _small_vip(vip: int, at: Vector2) -> void :
	var level: int = clampi(vip % 100, 0, 15)
	if level > 0:
		_fblit(("lb_sv%d" if vip >= 100 else "lb_v%d") % level, at)

func _level(level: int, at: Vector2, wide: float = 40.0, high: float = 20.0) -> void :
	_fblit("level_%d" % clampi(level, 0, 40), at, wide, high)
	_level_fx(level, at, wide)

func _place_mark(place: int, spec: Array, o: Vector2, mid: bool) -> void :
	if place >= 1 and place <= 5:
		_fblit("lb_no%d" % place, o + Vector2(13.5, 6))
	else:
		_label(spec, str(place), o, mid)


func _player_row(index: int, row: Dictionary, o: Vector2) -> void :
	var spec: Dictionary = Atlas.ROW
	_fblit("lb_cut", o + Vector2(0, 30))
	if index == _pick:
		_round(Rect2(o * _f, Vector2(409, 30) * _f), Color(0, 0, 0, 0), 10.0, SELECT, 6.0)
	_place_mark(_standing(row, index), spec["lblRank"], o, true)
	_level(int(row.get("char_level", 0)), o + Vector2(72, 6))
	var vip: int = _row_vip(row)
	var style: Array = HallScreen.name_style(vip % 100)
	_name_label(spec["lblName"], str(row.get("char_name", "")), o, true, style[0], style[1])
	_small_vip(vip, o + Vector2(238, 8.5))
	var value: int = int(row.get("char_point", 0))
	match _rt():
		4:
			var id: int = int(row.get("elo_section_id", 0))
			var section: Array = _section(id) if id > 0 else []
			if section.is_empty():
				_label(spec["lblValue"], NO_SECTION, o, true)
			else:
				var icon: Texture2D = pack.picture("l/bxh/s%d.webp" % int(section[1]))
				if icon != null:
					draw_texture_rect(icon, Rect2((o + Vector2(272, 2)) * _f, Vector2(icon.get_width(), icon.get_height()) * 0.14 * _f), false)
				_label(spec["lblSectionName"], str(section[0]), o, true)
				_label(spec["lblBattlePoint"], str(maxi(0, (value - int(section[2])) * 2)), o, true)
		11:
			var rank: Array = _military(value)
			if not rank.is_empty():
				_art_scaled("l/mr/b%d.webp" % int(rank[1]), o.x + 276.0, o.y + 16.0, 0.25)
				_label(spec["lblSectionName"], str(rank[0]), o, true)
				_fblit("lb_star", o + Vector2(355, 16.0 - 10.5))
				_label(spec["lblBattlePoint"], str(value), o, true)
		_:
			_label(spec["lblValue"], str(value), o, true)
	_hit("row:%d" % index, Rect2(o * _f, Vector2(411, ROW_H) * _f), false)


func pet_name(item: int) -> String:
	if item <= 0 or pack == null or pack.state != "ready":
		return ""
	pack.load_gda_loading()
	var info: Array = pack.gda_loading.get("helper", {}).get(str(item), [])
	return BagModel.clean(str(info[0])) if not info.is_empty() else ""


static func pet_stage_row(row: Dictionary) -> Dictionary:
	var out: Dictionary = row.duplicate()
	out["pet_id"] = int(row.get("char_booster_id", row.get("pet_id", 0)))
	out["pet_level"] = int(row.get("char_booster_l", row.get("pet_level", 0)))
	out["pet_rank"] = int(row.get("char_booster_r", row.get("pet_rank", 0)))
	out["pet_up"] = int(row.get("char_booster_ul", row.get("pet_up", 0)))
	out["pet_score"] = int(row.get("char_point", row.get("pet_score", 0)))
	return out


func _pet_row(index: int, row: Dictionary, o: Vector2) -> void :
	_fblit("lb_cut", o + Vector2(0, 30))
	if index == _pick:
		_round(Rect2(o * _f, Vector2(409, 30) * _f), Color(0, 0, 0, 0), 10.0, SELECT, 6.0)
	_place_mark(_standing(row, index), PETROW["lblRank"], o, true)
	_level(int(row.get("char_level", 0)), o + Vector2(72, 6))
	var vip: int = _row_vip(row)
	var style: Array = HallScreen.name_style(vip % 100)
	_name_label(PETROW["lblNameVip" if vip % 100 > 0 else "lblName"], str(row.get("char_name", "")), o, true, style[0], style[1])
	_small_vip(vip, o + Vector2(205, 8.5))
	_label(PETROW["lblHelperName"], pet_name(int(row.get("char_booster_id", 0))), o, true)
	_label(PETROW["lblValue"], str(int(row.get("char_point", 0))), o, true)
	_hit("row:%d" % index, Rect2(o * _f, Vector2(411, ROW_H) * _f), false)


func _tank_row(index: int, row: Dictionary, o: Vector2) -> void :
	var spec: Dictionary = Atlas.TANKROW
	_fblit("lb_cut", o + Vector2(0, 30))
	_place_mark(_standing(row, index), spec["lblRank"], o, true)
	_level(int(row.get("char_level", 0)), o + Vector2(72, 6))
	var vip: int = _row_vip(row)
	var style: Array = HallScreen.name_style(vip % 100)
	_name_label(spec["lblName"], str(row.get("char_name", "")), o, true, style[0], style[1])
	_small_vip(vip, o + Vector2(205, 8.5))
	_fblit("tklv_%d" % clampi(int(row.get("tank_lv", 1)), 1, 11), o + Vector2(250, 16.0 - 10.5))
	_label(spec["lblTankHpLevel"], str(int(row.get("tank_hplv", 0))), o, true)
	_label(spec["lblValue"], str(int(row.get("char_point", 0))), o, true)
	_hit("row:%d" % index, Rect2(o * _f, Vector2(411, ROW_H) * _f), false)
	_fbutton("watch:%d" % index, "lb_watch_s", o + Vector2(385, 5))


func _draw_grid(base: Vector2) -> void :
	var rows: Array = _types if _types is Array else []
	var cells: Array = _grid()
	_hit("grid", Rect2((base + GRID) * _f, Vector2(388, 360) * _f), false)
	for slot: int in cells.size():
		var index: int = int(cells[slot])
		var row: Dictionary = rows[index]
		var o: Vector2 = base + GRID + Vector2((slot % 2) * CELL.x, (slot / 2) * CELL.y)
		_fblit("lb_tk_bk", o)
		if index == _type_pick:
			_fblit("lb_tk_sel", o)
		_tank(row, o + Vector2(90, 60), 0.5)
		var spec: Dictionary = Atlas.TANKCELL
		var tank: String = GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(int(row.get("char_maintank", 0))), "")))
		_label(spec["lblTankName"], tank, o, false, Color(0, 0, 0, 0), SHADE, 0.0)
		var vip: int = _row_vip(row)
		var style: Array = HallScreen.name_style(vip % 100) if vip % 100 > 0 else [Color.WHITE, CELL_RIM]
		_name_label(spec["lblPlayerName"], str(row.get("char_name", "")), o, false, style[0], style[1])
		_hit("cell:%d" % index, Rect2(o * _f, CELL * _f), false)
	var bar: Vector2 = base + Vector2(405, 114)
	_fblit("lb_sb_up", bar)
	_fblit("lb_sb_bk", bar + Vector2(0, 19), _cell_size("lb_sb_up").x, TRACK)
	_fblit("lb_sb_down", bar + Vector2(0, 341))
	var total: int = _type_rows()
	if total > GRID_ROWS:
		var high: float = maxf(19.0, TRACK * GRID_ROWS / total)
		var top: float = (TRACK - high) * _type_top / (total - GRID_ROWS)
		var knob: Rect2 = _fblit("lb_sb_thumb", bar + Vector2(0, 19 + top), _cell_size("lb_sb_thumb").x, high, _glow("slide:types"))
		_knob_hit("slide:types", knob, _type_top, total - GRID_ROWS, (TRACK - high) * _f, 
			func(value: float) -> void : _scroll_types(roundi(value) - _type_top))
		_hit("tsb:up", Rect2(bar * _f, Vector2(19, 19) * _f))
		_hit("tsb:down", Rect2((bar + Vector2(0, 341)) * _f, Vector2(19, 19) * _f))


func _draw_avatar(base: Vector2, row: Dictionary) -> void :
	_photo("l/bxh/stage.webp", Rect2(base + AVATAR, Vector2(388, 350)))
	if not row.is_empty():
		_tank(row, base + Vector2(206, 342), 1.0)
		var key: String = str(pack.lobby.get("avatars", {}).get(str(int(row.get("char_avatar", 0))), ""))
		if not key.is_empty():
			_photo("l/av/%s.webp" % key, Rect2(base + Vector2(211, 179), Vector2(180, 240)))
		_level(int(row.get("char_level", 0)), base + Vector2(39, 125), 80.0, 40.0)
		var vip: int = _row_vip(row) % 100
		if vip > 0:
			_fblit("lb_vbig%d" % mini(12, vip), base + Vector2(355, 135))
		_photo(_honor_art(int(row.get("char_honor", 0))), Rect2(base + Vector2(58, 177), Vector2(40, 40)))
		_draw_pet(base, row)
	_fbutton("watch", "lb_watch", base + Vector2(333, 423))









const PET_ICON: Rect2 = Rect2(127, 145, 100, 100)
const PET_TEXT: Vector2 = Vector2(32, 396)
func _draw_pet(base: Vector2, row: Dictionary) -> void :
	var item: int = int(row.get("pet_id", 0))
	if item <= 0 or pack == null or pack.state != "ready":
		return
	pack.load_gda_loading()
	var info: Array = pack.gda_loading.get("helper", {}).get(str(item), [])
	if info.size() >= 2 and not str(info[1]).is_empty():
		var icon: Texture2D = pack.picture("l/it/%s.webp" % str(info[1]))
		if icon != null:
			draw_texture_rect(icon, Rect2((base + PET_ICON.position) * _f, PET_ICON.size * _f), false)
	var title: String = BagModel.clean(str(info[0])) if info.size() >= 3 else "Trợ thủ"
	var tone: Color = BagModel.tint(int(info[2]), Color.WHITE) if info.size() >= 3 else Color.WHITE
	_fwords(title, BOLD, 12.0, tone, "c", base + PET_TEXT, 140.0, 1.0, 16.0)
	_fwords("Cấp %d · %d sao · +%d" % [int(row.get("pet_level", 0)), int(row.get("pet_rank", 0)), int(row.get("pet_up", 0))], BOLD, 11.0, Color.WHITE, "c", base + PET_TEXT + Vector2(0, 16), 140.0, 1.0, 16.0)
	_fwords("Lực chiến: %d" % int(row.get("pet_score", 0)), BOLD, 11.0, Color("ffd24a"), "c", base + PET_TEXT + Vector2(0, 32), 140.0, 1.0, 16.0)

func _tank(row: Dictionary, centre: Vector2, zoom: float) -> void :
	var tank_id: int = int(row.get("char_maintank", 0))
	if tank_id <= 0 or pack.state != "ready" or pack.garage.is_empty():
		return
	var level: int = maxi(1, int(row.get("char_maintank_l", row.get("tank_lv", 1))))
	var ext: int = int(row.get("char_maintank_e", 0))
	if ext <= 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, level, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(row.get("halo_id", 0)), level)
	TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, centre * _f, zoom * _f, _time)


func _wide_row(index: int, row: Dictionary, o: Vector2, base: Vector2) -> void :
	var team: bool = _kind() == "team"
	var spec: Dictionary = Atlas.TEAM if team else Atlas.CORPS
	var high: float = ROW_H if team else minf(ROW_H, base.y + CORPS_FLOOR - o.y)
	if high >= ROW_H:
		_fblit("lb_cut_w", o + Vector2(0, 30))
	if index == _pick:
		_round(Rect2(o * _f, Vector2(760, minf(30.0, high)) * _f), Color(0, 0, 0, 0), 10.0, SELECT, 6.0)
	var place: int = _standing(row, index)
	if place >= 1 and place <= 50:
		_fblit("lb_cr%d" % place, o + Vector2(23, -1))
	else:
		_label(spec["lblRank"], str(place), o, false)
	if team:
		_photo(_honor_art(int(row.get("team_honor", 0))), Rect2(o + Vector2(80, 0), Vector2(32, 32)))
		_label(spec["lblClanName"], str(row.get("team_name", "")), o, false)
		_label(spec["lblScore"], str(int(row.get("team_score", 0))), o, false)
		_win_text(row, o, spec["lblWin"])
		var wins: int = int(row.get("team_wins", 0))
		var loses: int = int(row.get("team_loses", 0))
		_label(spec["lblWinRate"], "%d%%" % (wins * 100 / (wins + loses) if wins + loses > 0 else 0), o, false)
		_label(spec["lblGlory"], str(int(row.get("team_glory", 0))), o, false)
		_hit("row:%d" % index, Rect2(o * _f, Vector2(780, high) * _f), false)
		_fbutton("watch:%d" % index, "lb_watch_s", o + Vector2(718, 4))
		return
	_label(spec["lblClanName"], str(row.get("guild_name", "")), o, false)
	_level(int(row.get("guild_leader_level", 0)), o + Vector2(290, 6))
	if int(row.get("guild_leader_mil_level", 0)) == 0:
		_fblit("lb_acem", o + Vector2(328, 6))
	var vip: int = _vip_of(int(row.get("guild_leader_vippoint", 0)), float(row.get("guild_leader_vip", 0)), float(row.get("guild_leader_super_vip", 0)))
	var style: Array = HallScreen.name_style(vip % 100)
	_name_label(spec["lblLeaderName"], str(row.get("guild_leader", "")), o, false, style[0], style[1])
	_label(spec["lblNum"], str(int(row.get("guild_number", 0))), o, false)
	_label(spec["lblScore"], str(int(row.get("guild_level", 0))), o, false)
	_label(spec["lblGlory"], str(int(row.get("guild_teamlevel", 0))), o, false)
	_hit("row:%d" % index, Rect2(o * _f, Vector2(780, high) * _f), false)
	if high >= 4.0 + 22.0:
		_fbutton("watch:%d" % index, "lb_watch_s", o + Vector2(728, 4))


func _win_text(row: Dictionary, o: Vector2, spec: Array) -> void :
	var wins: int = int(row.get("team_wins", 0))
	var loses: int = int(row.get("team_loses", 0))
	var parts: Array = [["Thắng ", Color.WHITE], [str(wins) if wins > 0 else "--", WIN], [" /thua ", Color.WHITE], [str(loses) if loses > 0 else "--", LOSE]]
	var px: float = float(spec[4])
	var font_size: int = maxi(6, roundi(px * _f))
	var total: float = 0.0
	for part: Array in parts:
		total += ARIAL_BOLD.get_string_size(str(part[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var x: float = (o.x + float(spec[0]) + float(spec[2]) / 2.0) * _f - total / 2.0
	var y: float = (o.y + float(spec[1]) + 2.0 + px * 0.55) * _f
	for part: Array in parts:
		x += _fstring(str(part[0]), ARIAL_BOLD, px * 2.0, part[1], "l", Vector2(x, y), 2000.0, SHADE, 2.0)


func _draw_foot(base: Vector2) -> void :
	var kind: String = _kind()
	_fbutton("prev", "lb_prev", base + Vector2(706, 479))
	_fbutton("next", "lb_next", base + Vector2(808, 479))
	_fblit("lb_pager", base + Vector2(740, 476))
	_label(Atlas.MAIN["lblPage"], "%d/%d" % [_page + 1, _pages()], base, false, Color(0, 0, 0, 0), PAGE_RIM)
	if kind == "elo" or kind == "military" or kind == "tank":
		_fblit("lb_myrank_t" if kind == "tank" else "lb_myrank", base + Vector2(495, 481))
		var mine: int = int(_mine.get(_mine_key(), 0))
		var text: String = "…" if not _mine.has(_mine_key()) else (str(mine) if mine > 0 else NONE)
		_label(Atlas.MAIN["lblSelfRank"], text, base, false, Color(0, 0, 0, 0), SHADE, 0.0)
	if kind == "elo" or kind == "military" or kind == "team" or kind == "challenge":
		_fblit("lb_tip", base + Vector2(48, 479))
		var tip: String = TIP_TEAM if kind == "team" else (TIP_CHALLENGE if kind == "challenge" else TIP_SEASON)
		_label(Atlas.MAIN["lblRankTip"], tip, base, false, Color(0, 0, 0, 0), SHADE, 0.0)
	if kind == "team":
		_fbutton("award", "lb_award_pre", base + Vector2(487, 473))
		_fbutton("last", "lb_last_rank", base + Vector2(597, 473))



func _go(page: int) -> void :
	var clamped: int = clampi(page, 0, _pages() - 1)
	if clamped != _page:
		_page = clamped
		_pick = 0
		_failed = ""

func _activate(id: String) -> void :
	if reward_open() or watch_open():
		return
	if _last_open:

		if id == "last:close":
			_last_open = false
		elif id.begins_with("last:row:"):
			_last_pick = int(id.get_slice(":", 2))
		return
	if id.begins_with("tab:"):
		var index: int = int(id.substr(4))
		if _challenge:
			_challenge = false
			_ch_pick = {}
			_tab = -1
		if index != _tab:
			_tab = index
			_page = 0
			_pick = 0
			_failed = ""
		return
	if id.begins_with("cell:"):
		_pick_type(int(id.get_slice(":", 1)))
		return
	if id == "tsb:up" or id == "tsb:down":
		_scroll_types(-1 if id == "tsb:up" else 1)
		return
	if id.begins_with("row:"):
		_pick = int(id.get_slice(":", 1))
		if _challenge and _pick < _rows().size():
			_ch_pick = _rows()[_pick]
		return
	if id.begins_with("watch:"):
		_pick = int(id.get_slice(":", 1))
		if _kind() == "guild" or _kind() == "team":
			_watch_corps()
			return
		_watch_player()
		return
	match id:
		"close":
			closed.emit()
		"prev":
			_go(_page - 1)
		"next":
			_go(_page + 1)
		"watch":
			_watch_player()
		"award":
			_open_reward()
		"last":
			_open_last()


func _watch_corps() -> void :
	var rows: Array = _rows()
	if _pick < 0 or _pick >= rows.size() or not rows[_pick] is Dictionary:
		return
	var row: Dictionary = rows[_pick]
	if _kind() == "guild":
		_open_watch().open_guild(int(row.get("guild_id", 0)))
	else:
		_open_watch().open_team(row)



func _watch_player() -> bool:
	var rows: Array = _rows()
	var row: Variant = _ch_pick if _challenge else (rows[_pick] if _pick >= 0 and _pick < rows.size() else null)
	if not row is Dictionary or row.is_empty():
		return false
	var uuid: String = str(row.get("char_uuid", "")).strip_edges()
	if uuid.is_empty():
		return false
	player_info_asked.emit(uuid)
	return true

func _wheel(step: int, point: Vector2) -> void :
	if _last_open or reward_open() or watch_open():
		return
	var over: String = _hit_at(point)
	if not _challenge and _kind() == "tank" and (over in ["grid", "tsb:up", "tsb:down"] or over.begins_with("cell:")):
		_scroll_types(step * GRID_WHEEL)
		return
	var rows: int = _rows().size()
	if _challenge and rows > 0:

		var at: int = -1
		for index: int in rows:
			if not _ch_pick.is_empty() and int(_rows()[index].get("char_oid", 0)) == int(_ch_pick.get("char_oid", -1)):
				at = index
		_pick = clampi(at + step if at >= 0 else 0, 0, rows - 1)
		_ch_pick = _rows()[_pick]
		return
	if rows > 0:
		_pick = clampi(_pick + step, 0, rows - 1)

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if reward_open() or watch_open():
		return
	if _last_open:

		if event.keycode == KEY_ESCAPE:
			_last_open = false
			get_viewport().set_input_as_handled()
		return
	match event.keycode:
		KEY_ESCAPE:
			closed.emit()
		KEY_LEFT, KEY_PAGEUP:
			_go(_page - 1)
		KEY_RIGHT, KEY_PAGEDOWN:
			_go(_page + 1)
		KEY_UP:
			_wheel(-1, Vector2.ZERO)
		KEY_DOWN:
			_wheel(1, Vector2.ZERO)
		_:
			return
	get_viewport().set_input_as_handled()
