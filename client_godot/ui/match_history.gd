extends "flash_screen.gd"










const Atlas = preload("leaderboard_atlas.gd")
const Result = preload("pvpresult_atlas.gd")
const TankPortrait = preload("tank_portrait.gd")
const GarageModel = preload("garage_model.gd")
const HallScreen = preload("hall_screen.gd")
const PveMaps = preload("pve_hall_atlas.gd")
const PveRoom = preload("pve_room_atlas.gd")
const AppSession = preload("res://net/app_session.gd")

signal closed

const SIZE: Vector2 = Vector2(882, 532)
const DIM: float = 0.4
const STRIPE: Color = Color(0, 83.0 / 255.0, 145.0 / 255.0, 68.0 / 255.0)
const SELECT: Color = Color("ffff00")
const WIN: Color = Color("88ff00")
const LOSE: Color = Color("ff0000")
const INK: Color = Color("005797")
const PAGE_RIM: Color = Color(0.6, 0.4, 0.2, 0.8)
const SILVER: Color = Color("fff600")

const STAT_KEYS: Array = ["dmg", "taken", "heal"]
const STAT_COLORS: Array = [Color("ff9c9c"), Color("9fe8ff"), Color("88ff00")]
const STAT_NAMES: Array = ["ST gây ra", "ST gánh chịu", "Máu hồi"]
const STAT_X: float = 444.0
const STAT_W: float = 92.0
const EXP: Color = Color("9fe8ff")
const WIDE: Vector2 = Vector2(51, 145)
const ROW_H: float = 32.0
const MODES: Array = ["", "normal", "ranked", "happy", "team", "pve"]
const TABS: Array = ["Tất cả", "Đấu Thường", "Xếp Hạng", "Vui Vẻ", "Đấu Team", "Phụ Bản"]
const MODE_NAMES: Dictionary = {"normal": "Đấu Thường", "ranked": "Xếp Hạng", "happy": "Vui Vẻ", "team": "Đấu Team", "pve": "Phụ Bản"}



const HEADS: Array = [["THỜI GIAN", 2, 72], ["CHẾ ĐỘ", 74, 74], ["BẢN ĐỒ", 148, 90], ["TANK", 238, 86], ["KẾT QUẢ", 324, 54], 
	["HẠ/CHẾT/HT", 378, 66], ["GÂY/CHỊU/HỒI", 444, 92], ["ĐIỂM", 536, 48], ["THƯỞNG", 584, 70], ["DANH HIỆU", 654, 64]]
const STRIPES: Array = [[148, 90], [324, 54], [444, 92], [584, 70]]


const TAB_TEXT: Vector2 = Vector2(34, 70)
const TAB_PX: float = 11.0


const BOARD_HEADS: Array = [["NGƯỜI CHƠI", 50, 112], ["DANH HIỆU", 166, 92], ["HẠ/CHẾT/HT", 295, 116], ["ĐIỂM", 410, 80]]
const BOARD_HEAD_FILL: Color = Color(0.02, 0.2, 0.4, 0.92)
const HONOR_X: float = 210.0

const HONORS: Array = [[1, "pr_t_kill", "pr_honor_killer", "Kẻ Tàn Sát"], [2, "pr_t_assist", "pr_honor_assist", "Trợ Thủ"], 
	[4, "pr_t_kda", "pr_honor_kda", "Vua Toàn Năng"], [8, "pr_t_destroy", "", "Kẻ Phá Hủy"]]
const NOTE: String = "Lưu 50 trận gần nhất (30 ngày). Bấm kính lúp để xem lại bảng điểm trận."
const LOADING: String = "Đang tải..."
const EMPTY: String = "Chưa có trận nào được lưu."
const OFFLINE: String = "Không kết nối được máy chủ, hãy thử lại."
const LOGIN: String = "Phiên đăng nhập đã hết, hãy đăng nhập lại để xem lịch sử đấu."
const GONE: String = "Trận này không còn trong lịch sử."

var mode: String = "list"
var tab: int = 0
var page: int = 1
var data: Dictionary = {}
var game: Dictionary = {}
var status: String = ""
var fetch: Callable
var asked: Array = []
var _http: HTTPRequest
var _busy: bool = false
var _want: String = ""
var _state: String = ""
var _details: Dictionary = {}

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	overlay = true
	_use(Atlas.FILE, Atlas.R)
	_use(Result.FILE, Result.R)
	_http = HTTPRequest.new()
	_http.timeout = 15.0
	if OS.has_feature("web"):
		_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		if result == HTTPRequest.RESULT_SUCCESS:
			receive(code, body.get_string_from_utf8())
		else:
			fail())
	if client != null:
		client.changed.connect(_follow)


func _follow() -> void :
	if visible and (client == null or str(client.state) != _state):
		close()

func open() -> void :
	if visible:
		return
	_hover = ""
	_press = ""
	_state = str(client.state) if client != null else ""
	mode = "list"
	tab = 0
	page = 1
	data = {}
	game = {}
	_details = {}
	visible = true
	_ask_list()

func close() -> void :
	if not visible:
		return
	visible = false
	_busy = false
	status = ""
	if _http != null:
		_http.cancel_request()
	closed.emit()

func _ask_list() -> void :
	_ask("list", "/api/match-history?mode=%s&page=%d" % [str(MODES[tab]), page])

func _ask_detail(key: String) -> void :
	if _details.has(key):
		game = _details[key]
		mode = "detail"
		status = ""
		return
	_ask("detail", "/api/match-history/" + key.uri_encode())


func _ask(kind: String, path: String) -> void :
	if client == null:
		return
	if _http != null and _busy:
		_http.cancel_request()
	_want = kind
	status = "loading"
	var url: String = str(client.config.origin) + path
	asked.append(url)
	if fetch.is_valid():
		_busy = fetch.call(url) == OK
		return
	if client.config.get("local_test_only") == true or _http == null:
		_busy = false
		status = ""
		return

	_busy = _http.request(url, AppSession.headers(url)) == OK
	if not _busy:
		fail()

func fail() -> void :
	_busy = false
	status = "error"
	queue_redraw()


func receive(code: int, text: String) -> void :
	_busy = false
	var json: JSON = JSON.new()
	var reply: Variant = json.data if json.parse(text) == OK else null
	var good: bool = code == 200 and reply is Dictionary and bool(reply.get("ok", false))
	if code == 401:
		status = "login"
	elif code == 404 and _want == "detail":
		status = ""
		mode = "list"
		say(GONE)
	elif not good:
		status = "error"
	elif _want == "detail":
		var found: Variant = reply.get("match")
		if found is Dictionary:
			game = found
			_details[str(found.get("key", ""))] = found
			mode = "detail"
			status = ""
		else:
			status = "error"
	else:
		data = reply
		page = maxi(1, int(reply.get("page", page)))
		status = ""
	queue_redraw()

func items() -> Array:
	var found: Variant = data.get("items", [])
	return found if found is Array else []

func pages() -> int:
	return maxi(1, int(data.get("pages", 1)))



static func mode_name(item: Dictionary) -> String:
	return str(MODE_NAMES.get(str(item.get("mode", "")), "Đấu Thường"))

static func map_name(item: Dictionary) -> String:
	var id: int = int(item.get("mapId", 0))
	if str(item.get("mode", "")) == "pve":
		var pve: Variant = PveMaps.MAPS.get(str(id))
		if pve is Array and not (pve as Array).is_empty():
			return str(pve[0])
	return HallScreen.map_title(id) if id > 0 else ""

func tank_name(id: int) -> String:
	if pack == null or id <= 0:
		return ""
	return GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(id), "")))


static func when (at: int, year: bool = false) -> String:
	var local: int = at + int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(local)
	if year:
		return "%02d/%02d/%d %02d:%02d" % [int(d.day), int(d.month), int(d.year), int(d.hour), int(d.minute)]
	return "%02d/%02d %02d:%02d" % [int(d.day), int(d.month), int(d.hour), int(d.minute)]

static func clock(seconds: int) -> String:
	seconds = maxi(0, seconds)
	return "%02d:%02d" % [seconds / 60, seconds % 60]


static func num(value: int) -> String:
	var digits: String = str(absi(value))
	var out: String = ""
	while digits.length() > 3:
		out = "." + digits.right(3) + out
		digits = digits.left(digits.length() - 3)
	return ("-" if value < 0 else "") + digits + out


static func short(value: int) -> String:
	var v: int = absi(value)
	var minus: String = "-" if value < 0 else ""
	if v < 10000:
		return minus + num(v)
	if v < 100000:
		return minus + ("%d,%dk" % [v / 1000, v / 100 % 10]).replace(",0k", "k")
	if v < 1000000:
		return minus + "%dk" % (v / 1000)
	if v < 10000000:
		return minus + ("%d,%dM" % [v / 1000000, v / 100000 % 10]).replace(",0M", "M")
	return minus + "%dM" % (v / 1000000)


static func stats(item: Dictionary) -> Array:
	var out: Array = []
	for key: String in STAT_KEYS:
		var v: Variant = item.get(key)
		out.append(maxi(0, int(v)) if v is float or v is int else null)
	return out


static func outcome(item: Dictionary) -> Array:
	var won: bool = bool(item.get("won", false))
	if str(item.get("mode", "")) == "happy" and int(item.get("grade", item.get("rank", 0))) > 0:
		return ["HẠNG %d" % int(item.get("grade", item.get("rank", 0))), WIN if won else Color.WHITE]
	return ["THẮNG", WIN] if won else ["THUA", LOSE]


static func score_text(item: Dictionary) -> String:
	var grade: int = int(item.get("grade", 0))
	if str(item.get("mode", "")) == "pve" and grade > 0 and grade < PveRoom.SCORE_NAMES.size():
		return str(PveRoom.SCORE_NAMES[grade])
	return num(int(item.get("score", 0)))

static func honor_cells(bits: int) -> Array:
	var out: Array = []
	for honor: Array in HONORS:
		if bits & int(honor[0]):
			out.append(honor)
	return out



func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, DIM))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(SIZE.x, SIZE.y)
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_frame(base, "CHI TIẾT TRẬN" if mode == "detail" else "LỊCH SỬ ĐẤU")
	if mode == "detail":
		_detail(base)
	else:
		_list(base)
	_fbutton("close", "lb_close", base + Vector2(843, 33))


func _frame(base: Vector2, title: String) -> void :
	var f: Vector2 = base + Vector2(float(Atlas.FRAME[0]), float(Atlas.FRAME[1]))
	_fpart("lb_frame", f, Rect2(0, 0, 350, 529))
	_fpart("lb_frame", f + Vector2(350, 21), Rect2(350, 21, 145, 508))
	_fpart("lb_frame", f + Vector2(495, 0), Rect2(495, 0, 366, 529))
	_fwords(title, ARIAL_BOLD, 17.0, Color("d8ff8a"), "c", f + Vector2(330, 0), 200.0, 2.0, 22.0, true, Color("1663a8"))

func _tabs(base: Vector2) -> void :
	for i: int in TABS.size():
		var at: Vector2 = base + Vector2(37.0 + 114.0 * i, 71)
		_fblit("lb_plate", at, 0.0, 0.0, _glow("tab:%d" % i) if i != tab else Color.WHITE)
		if i == tab:
			_fblit("lb_sel", at)
		_fwords(str(TABS[i]), ARIAL_BOLD, TAB_PX, Color.WHITE, "c", at + Vector2(TAB_TEXT.x, 7), TAB_TEXT.y, 1.0, 24.0, true, Color("6b3a00") if i == tab else Color("06447a"))
		_hit("tab:%d" % i, Rect2(at * _f, _cell_size("lb_plate") * _f), false)

func _hbox(at: Vector2, high: float) -> void :
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

func _cell(text: String, x: float, o: Vector2, wide: float, color: Color = Color.WHITE, px: float = 12.0, align: String = "c") -> void :
	_fwords(text, ARIAL_BOLD, px, color, align, o + Vector2(x, 4), wide, 1.0, 24.0)



func _cell2(text: String, x: float, o: Vector2, wide: float, align: String = "c") -> void :
	var font: Font = _face(ARIAL_BOLD)
	var size: int = maxi(6, roundi(12.0 * _f))
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= wide * _f or text.find(" ") < 0:
		_cell(text, x, o, wide, Color.WHITE, 12.0, align)
		return
	var best: int = -1
	var worst: float = INF
	for i: int in text.length():
		if text[i] == " ":
			var w: float = maxf(font.get_string_size(text.left(i), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x, 
				font.get_string_size(text.substr(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x)
			if w < worst:
				worst = w
				best = i
	_fwords(text.left(best), ARIAL_BOLD, 10.5, Color.WHITE, align, o + Vector2(x, 2), wide, 1.0, 14.0)
	_fwords(text.substr(best + 1), ARIAL_BOLD, 10.5, Color.WHITE, align, o + Vector2(x, 15), wide, 1.0, 14.0)

func _list(base: Vector2) -> void :
	_tabs(base)
	_hbox(base + Vector2(47, 141), 328.0)
	for s: Array in STRIPES:
		draw_rect(Rect2((base + WIDE + Vector2(float(s[0]), 0)) * _f, Vector2(float(s[1]), 320) * _f), STRIPE)
	for head: Array in HEADS:
		_fwords(str(head[0]), ARIAL_BOLD, 11.5, Color.WHITE, "c", base + Vector2(WIDE.x + float(head[1]) + 1.0, 120.5), float(head[2]) - 2.0, 1.0, 24.0)
	var rows: Array = items()
	for i: int in mini(rows.size(), 10):
		var row: Dictionary = rows[i] if rows[i] is Dictionary else {}
		var o: Vector2 = base + WIDE + Vector2(0, i * ROW_H)
		_fblit("lb_cut_w", o + Vector2(0, 30))
		var lit: bool = _hover in ["row:%d" % i, "watch:%d" % i]
		if lit:
			_round(Rect2(o * _f, Vector2(760, 30) * _f), Color(1, 1, 0.4, 0.1), 10.0, SELECT, 6.0)
		_hit("row:%d" % i, Rect2(o * _f, Vector2(724, 30) * _f), false)
		_cell( when (int(row.get("at", 0))), 2, o, 72)
		var kind: String = mode_name(row)
		_cell(kind, 74, o, 74, Color("ffe36b") if str(row.get("mode", "")) == "ranked" else Color.WHITE)
		_cell2(map_name(row), 150, o, 86)
		_portrait(int(row.get("tankId", 0)), o + Vector2(252, 15), 0.15)
		_cell2(tank_name(int(row.get("tankId", 0))), 267, o, 56, "l")
		var result: Array = outcome(row)
		_cell(str(result[0]), 324, o, 54, result[1], 13.0)
		_cell("%d/%d/%d" % [int(row.get("kills", 0)), int(row.get("deaths", 0)), int(row.get("assists", 0))], 378, o, 66, Color("fff600"))
		_stat_cell(o + Vector2(STAT_X, 0), stats(row))
		_cell(score_text(row), 536, o, 48)
		_reward(o + Vector2(584, 0), 70.0, int(row.get("silver", 0)), int(row.get("exp", 0)))
		var icons: Array = honor_cells(int(row.get("honors", 0)))
		var step: float = minf(23.0, 58.0 / maxf(1.0, icons.size()))
		var x: float = 686.0 - (step * (icons.size() - 1) + 22.0) / 2.0
		for icon: Array in icons:
			_fblit(str(icon[1]), o + Vector2(x, 4))
			x += step
		_fbutton("watch:%d" % i, "lb_watch_s", o + Vector2(730, 4))
	if rows.is_empty() or status != "":
		_box_note(base + Vector2(51, 145), Vector2(760, 320), rows.is_empty())
	_fblit("lb_tip", base + Vector2(48, 479))
	_fwords(NOTE, ARIAL_BOLD, 12.0, INK, "l", base + Vector2(83, 476), 404.0, 0.0, 24.0, true, Color(0, 0, 0, 0))
	var total: int = int(data.get("total", 0))
	var wins: int = int(data.get("wins", 0))
	var tally: String = "%d trận · Thắng %d · Thua %d · %d%%" % [total, wins, total - wins, roundi(100.0 * wins / total)] if total > 0 else ""
	_fwords(tally, ARIAL_BOLD, 13.0, INK, "c", base + Vector2(490, 476), 212.0, 0.0, 24.0, true, Color(0, 0, 0, 0))
	_pager_button("prev", "lb_prev", base + Vector2(706, 479), page > 1)
	_pager_button("next", "lb_next", base + Vector2(808, 479), page < pages())
	_fblit("lb_pager", base + Vector2(740, 476))
	_fwords("%d/%d" % [page, pages()], ARIAL_BOLD, 16.0, Color.WHITE, "c", base + Vector2(744, 480), 57.0, 1.0, 24.0, true, PAGE_RIM)


func _stat_cell(o: Vector2, values: Array) -> void :
	if values.all( func(v: Variant) -> bool: return v == null):
		_cell("—", 0, o, STAT_W)
		return
	var part: float = (STAT_W - 8.0) / 3.0
	for k: int in 3:
		var x: float = k * (part + 4.0)
		_fwords("—" if values[k] == null else short(int(values[k])), ARIAL_BOLD, 11.0, STAT_COLORS[k], "c", o + Vector2(x, 4), part, 1.0, 24.0)
		if k < 2:
			_fwords("/", ARIAL_BOLD, 11.0, Color.WHITE, "c", o + Vector2(x + part - 1.0, 4), 6.0, 1.0, 24.0, false)


func _reward(o: Vector2, wide: float, silver: int, xp: int) -> void :
	if silver <= 0 and xp <= 0:
		_fwords("—", ARIAL_BOLD, 12.0, Color.WHITE, "c", o + Vector2(0, 4), wide, 1.0, 24.0)
		return
	_fwords("%s Bạc" % num(silver), ARIAL_BOLD, 10.5, SILVER, "c", o + Vector2(0, 2), wide, 1.0, 14.0)
	_fwords("%s EXP" % num(xp), ARIAL_BOLD, 10.5, EXP, "c", o + Vector2(0, 15), wide, 1.0, 14.0)

func _pager_button(id: String, cell: String, at: Vector2, on: bool) -> void :
	if on:
		_fbutton(id, cell, at)
	else:
		_fblit(cell, at, 0.0, 0.0, Color(0.55, 0.55, 0.55, 0.8))


func _box_note(at: Vector2, box: Vector2, empty: bool) -> void :
	var text: String = ""
	match status:
		"loading":
			text = LOADING
		"error":
			text = OFFLINE
		"login":
			text = LOGIN
		_:
			text = EMPTY if empty else ""
	if text.is_empty():
		return
	if not empty:
		_round(Rect2((at + Vector2(box.x / 2.0 - 190.0, box.y / 2.0 - 22.0)) * _f, Vector2(380, 44) * _f), Color(0, 0.2, 0.45, 0.85), 12.0, Color(1, 1, 1, 0.6), 2.0)
	_fwords(text, ARIAL_BOLD, 15.0, Color.WHITE, "c", at + Vector2(box.x / 2.0 - 185.0, box.y / 2.0 - 12.0), 370.0, 1.5, 24.0)



func sides() -> Array:
	var players: Array = []
	for p: Variant in game.get("players", []):
		if p is Dictionary:
			players.append(p)
	if str(game.get("mode", "")) == "happy":
		players.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
			var ra: int = int(a.get("rank", 0)) if int(a.get("rank", 0)) > 0 else 999
			var rb: int = int(b.get("rank", 0)) if int(b.get("rank", 0)) > 0 else 999
			return ra < rb if ra != rb else int(a.get("score", 0)) > int(b.get("score", 0)))
		if players.size() > 10:
			var me: Array = players.filter( func(p: Dictionary) -> bool: return bool(p.get("me", false)))
			players = players.slice(0, 10)
			if not me.is_empty() and not players.has(me[0]):
				players[9] = me[0]
		return [players.slice(0, 5), players.slice(5, 10)]
	var camp: int = int(game.get("camp", 0))
	var mine: Array = players.filter( func(p: Dictionary) -> bool: return int(p.get("camp", 0)) == camp)
	var rest: Array = players.filter( func(p: Dictionary) -> bool: return int(p.get("camp", 0)) != camp)
	return [mine, rest]

func _detail(base: Vector2) -> void :
	var board: Vector2 = base + Vector2(44, 76)
	_fpart("pr_board", board + Vector2(0, 20), Rect2(0, 20, 494, 363))
	_round(Rect2((board + Vector2(2, 0)) * _f, Vector2(490, 19) * _f), BOARD_HEAD_FILL, 6.0)
	for head: Array in BOARD_HEADS:
		_fwords(str(head[0]), ARIAL_BOLD, 11.5, Color.WHITE, "l" if head == BOARD_HEADS[0] else "c", board + Vector2(float(head[1]), -2.5), float(head[2]), 1.0, 24.0)
	var halves: Array = sides()
	for side: int in 2:
		var list: Array = halves[side]
		var at: Vector2 = board + Vector2(2, 20 + 179 * side)
		var step: float = minf(36.0, 176.0 / maxf(5.0, list.size()))
		for i: int in list.size():
			_row(at + Vector2(0, step * i), list[i], side == 1 and str(game.get("mode", "")) != "happy", str(game.get("mode", "")) == "happy")
	_panel_info(base + Vector2(560, 80))
	var back: Rect2 = _fbutton("back", "lb_prev", base + Vector2(48, 474))
	_fwords("Về danh sách", ARIAL_BOLD, 13.0, INK, "l", base + Vector2(86, 476), 200.0, 0.0, 24.0, true, Color(0, 0, 0, 0))
	_hit("back", Rect2(back.position, Vector2(150, back.size.y)), false)
	if status != "":
		_box_note(base + Vector2(44, 76), Vector2(494, 383), false)

func _panel_info(o: Vector2) -> void :
	_round(Rect2(o * _f, Vector2(280, 376) * _f), Color(0, 0.25, 0.5, 0.35), 10.0, Color(1, 1, 1, 0.55), 2.0)
	var result: Array = outcome(game)
	_fwords(str(result[0]), ARIAL_BOLD, 26.0, result[1], "c", o + Vector2(0, 8), 280.0, 2.0, 34.0, true, Color("1a4a00") if result[1] == WIN else Color("4a0000"))
	var lines: Array = [["Chế độ", mode_name(game)], ["Bản đồ", map_name(game)], ["Thời điểm", when (int(game.get("at", 0)), true)], 
		["Thời lượng", clock(int(game.get("duration", 0)))], ["Tank", tank_name(int(game.get("tankId", 0)))], 
		["Hạ/Chết/HT", "%d/%d/%d" % [int(game.get("kills", 0)), int(game.get("deaths", 0)), int(game.get("assists", 0))]]]
	if str(game.get("mode", "")) == "pve":
		lines.append(["Đánh giá", score_text(game)])
	lines.append(["Điểm trận", num(int(game.get("score", 0)))])
	lines.append(["Bạc nhận", num(int(game.get("silver", 0)))])
	lines.append(["EXP nhận", num(int(game.get("exp", 0)))])
	var gap: float = 20.0
	for i: int in lines.size():
		var y: float = 46.0 + gap * i
		_fwords(str(lines[i][0]), ARIAL_BOLD, 13.0, Color("cfe9ff"), "l", o + Vector2(18, y), 100.0, 1.0, 22.0)
		var color: Color = Color.WHITE
		if lines[i][0] == "Bạc nhận":
			color = SILVER
		elif lines[i][0] == "EXP nhận":
			color = EXP
		_fwords(str(lines[i][1]), ARIAL_BOLD, 13.0, color, "l", o + Vector2(118, y), 150.0, 1.0, 22.0)
	var top: float = _stat_grid(o + Vector2(0, 46.0 + gap * lines.size() + 2.0), stats(game)) - o.y + 4.0
	_fwords("Danh hiệu trận", ARIAL_BOLD, 13.0, Color("cfe9ff"), "l", o + Vector2(18, top), 200.0, 1.0, 22.0)
	var icons: Array = honor_cells(int(game.get("honors", 0)))
	if icons.is_empty():
		_fwords("Không có", ARIAL_BOLD, 13.0, Color.WHITE, "l", o + Vector2(118, top), 150.0, 1.0, 22.0)
		return
	var x: float = 140.0 - 70.0 * icons.size() / 2.0
	for icon: Array in icons:
		if str(icon[2]).is_empty():
			_fblit(str(icon[1]), o + Vector2(x + 13, top + 26), 40.0, 40.0)
			_fwords(str(icon[3]), ARIAL_BOLD, 10.0, Color.WHITE, "c", o + Vector2(x - 2, top + 66), 70.0, 1.0, 14.0)
		else:
			_fblit(str(icon[2]), o + Vector2(x, top + 22), 0.0, minf(70.0, 376.0 - top - 26.0))
		x += 70.0


func _stat_grid(at: Vector2, values: Array) -> float:
	_round(Rect2((at + Vector2(12, 0)) * _f, Vector2(256, 36) * _f), Color(0, 0.12, 0.3, 0.45), 6.0)
	for k: int in 3:
		var x: float = 14.0 + k * 84.0
		_fwords(str(STAT_NAMES[k]), ARIAL_BOLD, 10.5, Color("cfe9ff"), "c", at + Vector2(x, 1), 80.0, 1.0, 14.0)
		_fwords("—" if values[k] == null else num(int(values[k])), ARIAL_BOLD, 13.0, STAT_COLORS[k], "c", at + Vector2(x, 15), 80.0, 1.0, 20.0)
	return at.y + 36.0



func _row(at: Vector2, p: Dictionary, foe: bool, ranked: bool) -> void :
	_portrait(int(p.get("tankId", 0)), at + Vector2(23, 18), 0.17)
	var tone: Color = Color("ff9c9c") if foe else Color("fff600")
	if bool(p.get("me", false)):
		_round(Rect2((at + Vector2(1, 1)) * _f, Vector2(488, 32) * _f), Color(1, 1, 0.4, 0.12), 6.0, SELECT, 2.0)
	var who: String = str(p.get("name", ""))
	if ranked and int(p.get("rank", 0)) > 0:
		who = "%d. %s" % [int(p.get("rank", 0)), who]
	_fwords(who, ARIAL_BOLD, 13.0, tone, "l", at + Vector2(48, 6), 112.0, 1.0, 22.0)
	var icons: Array = honor_cells(int(p.get("honors", 0)))
	var x: float = HONOR_X - 11.0 * icons.size()
	for icon: Array in icons:
		_fblit(str(icon[1]), at + Vector2(x, 7))
		x += 22.0
	_fwords("%d/%d/%d" % [int(p.get("kills", 0)), int(p.get("deaths", 0)), int(p.get("assists", 0))], ARIAL_BOLD, 13.0, tone, "c", at + Vector2(293, 6), 116.0, 1.0, 22.0)
	_fwords(num(int(p.get("score", 0))), ARIAL_BOLD, 13.0, tone, "c", at + Vector2(408, 6), 80.0, 1.0, 22.0)
	_fblit("pr_cut", at + Vector2(0, 34))

func _portrait(tank_id: int, centre: Vector2, zoom: float) -> void :
	if pack == null or pack.state != "ready" or pack.garage.is_empty() or tank_id <= 0:
		return
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, 5, {})
	TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), 0, centre * _f, zoom * _f, _time)



func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "back":
		mode = "list"
		status = ""
	elif id.begins_with("tab:"):
		var next: int = int(id.substr(4))
		if next != tab:
			tab = next
			page = 1
			data = {}
			_ask_list()
	elif id == "prev" and page > 1:
		page -= 1
		_ask_list()
	elif id == "next" and page < pages():
		page += 1
		_ask_list()
	elif id.begins_with("watch:") or id.begins_with("row:"):
		var i: int = int(id.get_slice(":", 1))
		var rows: Array = items()
		if i >= 0 and i < rows.size() and rows[i] is Dictionary:
			_ask_detail(str(rows[i].get("key", "")))

func _wheel(step: int, _at: Vector2) -> void :
	if mode != "list" or status == "loading":
		return
	if step > 0 and page < pages():
		_activate("next")
	elif step < 0 and page > 1:
		_activate("prev")

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		if mode == "detail":
			_activate("back")
		else:
			close()
		get_viewport().set_input_as_handled()
