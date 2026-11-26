extends "league_reward.gd"
const AppSession = preload("res://net/app_session.gd")
















const SafeJson = preload("res://net/safe_json.gd")
const Info = preload("league_info_atlas.gd")
const Award = preload("league_award_atlas.gd")

signal queued(word: String)
signal reward_asked

const INFO_TITLE: String = "GIẢI ĐẤU TEAM"
const INFO_RIM: Color = Color("0d4f96")
const HOVER_INK: Color = Color("ffff00")
const SELECT_SCALE: float = 1.4
const WIN_INK: Color = Color("88ff00")
const LOSE_INK: Color = Color("ff0000")
const PICK_FILL: Color = Color(1.0, 0.86, 0.2, 0.22)
const PICK_EDGE: Color = Color(1.0, 0.86, 0.2, 0.7)

const TIP13: String = "Team chưa báo danh"
const TIP20: String = "Bạn đã bị loại, hãy nỗ lực hơn"
const TIP21: String = "T/g mở đấu: @num1@"
const TIP22: String = "Kết thúc đấu"
const TIP_141: String = "Đang nghỉ"
const TIP_317: String = "Không phần thưởng"
const CORPS_TEXT34: String = "Nhập tên Team"
const CORPS_TEXT71: String = "Không tìm được team tương ứng"
const CONTROL_TEXT39: String = "Thắng @win@ /thua @lose@"
const SEARCH_HINT: String = "Nhập tên team cần tìm"
const EXP_NAME: String = "Kinh nghiệm"
const GLORY_NAME: String = "Vinh dự"

const KICK_OUT: int = 0
const MOVE_ON: int = 1
const ARMISTICE: int = 2
const GAME_OVER: int = 3
const ROWS: int = 10
const PAGE_ROWS: int = 10
const ROW_PULL: float = 16.0
const LISTED: Array = ["qualifying", "knockout"]

var host: Node = null
var fetch_hook: Callable = Callable()
var _http: Dictionary = {}
var _shown_round: Dictionary = {}
var _round_id: int = 0
var _zones: int = 0
var _zone: int = 0
var _page: int = 0
var _pages: Dictionary = {}
var _total: int = 0
var _last: int = 0
var _teams: Array = []
var _style: String = ""
var _has: bool = false
var _sel: int = -1
var _gifts: Dictionary = {"win": [], "lose": []}
var _search: LineEdit = null
var _first: bool = true
var _italic: FontVariation = FontVariation.new()

func _setup() -> void :
	super ()
	_use(Info.FILE, Info.R)
	_use(Award.FILE, Award.R)
	for kind: String in ["round", "teams", "win", "lose"]:
		_http[kind] = _request(kind)
	_italic.base_font = ARIAL_BOLD
	_italic.variation_transform = Transform2D(Vector2(1.0, 0.2), Vector2(0.0, 1.0), Vector2.ZERO)
	_search = _fedit(0)
	_search.gui_input.connect( func(event: InputEvent) -> void :

		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _first:
			_search.text = ""
			_first = false)

func _request(kind: String) -> HTTPRequest:
	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 10
	http.accept_gzip = false
	add_child(http)
	http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			arrive(kind, SafeJson.parse(body.get_string_from_utf8())))
	return http


func _base(kind: String) -> String:
	var origin: String = str(client.config.origin)
	if kind in ["win", "lose"]:
		return origin
	var path: String = str(client.league_url)
	return origin + (path.trim_suffix("/") if path.begins_with("/") else "")

func _fetch(kind: String, path: String) -> void :
	if fetch_hook.is_valid():
		fetch_hook.call(kind, path)
		return
	if client == null or str(client.config.origin).is_empty() or not _http.has(kind):
		return
	var http: HTTPRequest = _http[kind]
	http.cancel_request()
	var url: String = _base(kind) + path
	http.request(url, AppSession.headers(url))

static func _cache_buster() -> String:
	return str(randf())

static func _int(value: Variant) -> int:
	if value is int or value is float or value is bool:
		return int(value)
	if value is String and (value as String).is_valid_float():
		return int(float(value))
	return 0


static func held_text(unix: int) -> String:
	var day: Dictionary = Time.get_datetime_dict_from_unix_time(unix + 7 * 3600)
	var hour: int = int(day.hour)
	return "%04d/%02d/%02d %02d:%02d" % [int(day.year), int(day.month), int(day.day), 24 if hour == 0 else hour, int(day.minute)]




func show_round(round_id: int) -> void :
	if not visible:
		_shown_round = {}
		_round_id = 0
		_zones = 0
		_zone = 0
		_page = 0
		_style = ""
		_has = false
		_gifts = {"win": [], "lose": []}
		_first = true
		_search.text = SEARCH_HINT
		clear_data()
		_tip = []
		_grab = false
		_pull = 0.0
		_hover = ""
		_press = ""
		if pack != null:
			pack.load_bag()
		visible = true
	request_round(round_id)

func close() -> void :
	if visible:
		_search.visible = false
	super ()

func request_round(round_id: int) -> void :
	_fetch("round", "/cLeagueRoundInfo.php?sid=%d&rid=%d&noCache=%s" % [_sid(), round_id, _cache_buster()])


func _request_teams(zone: int, page: int, group: int) -> void :
	_fetch("teams", "/cLeagueRoundTeams.php?sid=%d&rid=%d&zid=%d&gid=%d&p=%d&noCache=%s" % [_sid(), _round_id, zone, group, page, _cache_buster()])


func _request_page(page: int) -> void :
	if _page == page:
		return
	_request_teams(_zone, page, 0)


func clear_data() -> void :
	_last = 0
	_top = 0
	_pages = {}
	_teams = []
	_sel = -1

func _sid() -> int:
	return int(host.session()) if host != null else 0

func _phases() -> Array:
	return host.phases() if host != null else []


func _phase(id: int) -> Array:
	for row: Array in _phases():
		if int(row[0]) == id:
			return row
	return []




func arrive(kind: String, data: Variant) -> void :
	if not visible or not data is Dictionary:
		return
	match kind:
		"round":
			_shown_round = parse_round(data)
			_on_round()
		"teams":
			_on_teams(data)
		"win", "lose":
			_gifts[kind] = reward_tiles(data, pack.bag.get("items", {}) if pack != null else {})


static func parse_round(data: Dictionary) -> Dictionary:
	return {"id": _int(data.get("nRoundId")), "pre": _int(data.get("nRoundPre")), "next": _int(data.get("nRoundNext")), 
		"name": str(data.get("szRoundName", "")), "held": _int(data.get("nHeldTime")), "win": _int(data.get("nWinnerAward")), 
		"lose": _int(data.get("nLoserAward")), "phase": _int(data.get("nPhaseId")), "phase_name": str(data.get("szPhaseName", "")), 
		"style": str(data.get("style", ""))}


func _on_round() -> void :
	_round_id = int(_shown_round.id)
	var phase: Array = _phase(int(_shown_round.phase))
	if not phase.is_empty():
		_zones = int(phase[3]) if phase.size() > 3 else 1
		_zone = 0 if _zones == 1 else 1
	clear_data()
	_request_teams(_zone, 0, 1)


static func parse_team(row: Dictionary) -> Dictionary:
	return {"id": _int(row.get("nTeamId")), "name": str(row.get("szTeamName", "")), "glory": _int(row.get("nTeamGlory")), 
		"score": _int(row.get("nTeamScore")), "win": _int(row.get("nTeamWintimes")), "lose": _int(row.get("nTeamLosetimes")), 
		"rate": _int(row.get("nTeamWinrate")), "qualify": _int(row.get("nQualifyTeam")), "rank": 0}


func _on_teams(data: Dictionary) -> void :
	_page = _int(data.get("p"))
	var list: Array = data.get("list") if data.get("list") is Array else []
	_has = not list.is_empty()
	_style = str(data.get("style", ""))
	if _has:
		_total = _int(data.get("total"))
		_last = maxi(_last, _page)
		var rows: Array = []
		for raw: Variant in list:
			if raw is Dictionary:
				rows.append(parse_team(raw))
		_pages[_page] = rows
		_teams = []
		var keys: Array = _pages.keys()
		keys.sort()
		for key: Variant in keys:
			_teams.append_array(_pages[key])
		for i: int in _teams.size():
			_teams[i].rank = i + 1
		_top = clampi(_top, 0, max_top())
		if _last < _total - 1 and _teams.size() <= PAGE_ROWS:
			_request_page(_last + 1)
	elif not _shown_round.is_empty():
		_gifts = {"win": [], "lose": []}
		_fetch("win", "/cLeagueAward.php?aid=%d&noCache=%s" % [int(_shown_round.win), _cache_buster()])
		_fetch("lose", "/cLeagueAward.php?aid=%d&noCache=%s" % [int(_shown_round.lose), _cache_buster()])



static func reward_tiles(data: Dictionary, items: Dictionary) -> Array:
	var out: Array = []
	var slot: int = 0
	for spec: Array in [["nCoin", "money", 1], ["nExp", "exp", 1], ["nGift", "gift", 2], ["nGlory", "glory", 1], ["nTank", "tank", 4]]:
		var count: int = _int(data.get(spec[0]))
		if count <= 0:
			continue
		var gift: Dictionary = {"kind": spec[1], "id": 0, "count": count, "name": "", "art": "", "quality": spec[2], "desc": ""}
		match str(spec[1]):
			"money":
				gift.name = str(Atlas.MONEY_NAME)
			"gift":
				gift.name = str(Atlas.GIFT_NAME)
			"exp":
				gift.name = EXP_NAME
			"glory":
				gift.name = GLORY_NAME
			"tank":
				gift.id = count
				gift.count = 0
		out.append([slot, gift])
		slot += 1
	var ids: Array = [_int(data.get("nAvatar"))]
	var counts: Array = [1]
	for i: int in range(1, 6):
		ids.append(_int(data.get("nItem%d" % i)))
		counts.append(_int(data.get("nItemcnt%d" % i)))
	for i: int in ids.size():
		var id: int = int(ids[i])
		if id > 0:
			var found: Variant = items.get(str(id))
			var more: Array = found if found is Array else []
			out.append([slot, {"kind": "item", "id": id, "count": int(counts[i]), 
				"name": BagModel.clean(str(more[0])) if not more.is_empty() else "", 
				"art": "l/it/%s.webp" % str(more[2]) if more.size() > 2 and not str(more[2]).is_empty() else "", 
				"quality": _int(more[3]) if more.size() > 3 else 1, "desc": GarageModel.plain(str(more[1])) if more.size() >= 10 else ""}])
		slot += 1
	return out.filter( func(cell: Array) -> bool: return int(cell[0]) < int(Info.REWARD.max))

func round_info() -> Dictionary:
	return _shown_round

func teams() -> Array:
	return _teams

func zone() -> int:
	return _zone

func zones() -> int:
	return _zones

func selected() -> int:
	return _sel

func has_teams() -> bool:
	return _has

func gifts(kind: String) -> Array:
	return _gifts.get(kind, [])

func search_box() -> LineEdit:
	return _search

func max_top() -> int:
	return maxi(0, _teams.size() - ROWS)


func _scroll(value: float) -> void :
	var before: int = _top
	_top = clampi(roundi(value), 0, max_top())
	if _top != before and _top >= max_top() and _last < _total - 1:
		_request_page(_last + 1)


func find_team(text: String) -> void :
	if text.is_empty() or _first:
		say(CORPS_TEXT34)
		return
	if not _style in LISTED:
		return
	var index: int = -1
	for i: int in _teams.size():
		if str(_teams[i].name) == text:
			index = i
			break
	if index == -1:
		say(CORPS_TEXT71)
		return
	_top = clampi(ceili(float(index) / float(_teams.size()) * max_top()), 0, max_top())
	_sel = index



func _paint() -> void :
	_tip = []
	_bar = []
	_clip = Rect2()
	_list_rect = Rect2()
	var glyph: int = maxi(1, roundi(_f))
	if _italic.spacing_glyph != glyph:
		_italic.spacing_glyph = glyph
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var box: Vector2 = _v(Info.SIZE)
	var o: Vector2 = _centre(box.x, box.y)
	_hit("panel", Rect2(o * _f, box * _f), false)
	_fblit("li_frame", o + _v(Info.FRAME))
	_draw_title(o)
	_draw_phases(o)
	_draw_round(o)
	if _style.is_empty():
		pass
	elif _has:
		_draw_teams(o)
	else:
		_draw_gifts(o)
	var find: bool = _style in LISTED
	if find:
		var spot: Array = Info.FIND
		_fput(_search, Rect2(o + Vector2(float(spot[0]) + 28.0, float(spot[1]) + 3.0), Vector2(float(spot[2]) - 34.0, float(spot[3]) - 6.0)), 12.0)
		_fbutton("find", "li_find", o + _v(Info.BUTTONS.btnFind))
	else:
		_search.visible = false
	_fbutton("enter", "li_enter", o + _v(Info.BUTTONS.btnEnterLeagueRoom))
	_fbutton("reward", "li_reward", o + _v(Info.BUTTONS.btnCurReward))
	_fbutton("close", "li_close", o + _v(Info.BUTTONS.btnClose))
	_draw_tip()

func _draw_title(o: Vector2) -> void :
	var spot: Array = Info.TITLE
	_fwords(INFO_TITLE, ARIAL_BOLD, 22.0, Color.WHITE, "c", o + Vector2(float(spot[0]) - 150.0, float(spot[1]) + 2.0), 300.0, 2.0, 30.0, true, INFO_RIM)




func _draw_phases(o: Vector2) -> void :
	var spec: Dictionary = Info.PHASE
	var at: Vector2 = o + _v(spec.at)
	var back: Array = spec.back
	var fill: Array = spec.fill
	draw_rect(Rect2((at + _v(back)) * _f, Vector2(float(back[2]), float(back[3])) * _f), Color(str(back[4])))
	draw_rect(Rect2((at + _v(fill)) * _f, Vector2(float(fill[2]), float(fill[3])) * _f), Color(str(fill[4])))
	var phases: Array = _phases()
	var count: int = phases.size()
	if count == 0:
		return
	var current: int = int(host.phase()) if host != null else 0
	var index: int = -1
	for i: int in count:
		if int(phases[i][0]) == current:
			index = i
	if index >= 0:
		var left: float = at.x + float(fill[0])
		var right: float = minf(left + float(index + 1) / float(count) * float(spec.wide), left + float(fill[2]))
		var body: float = maxf(left, right - float(spec.head) * 0.5)
		var top: float = at.y + float(fill[1])
		var low: float = top + float(fill[3])
		draw_colored_polygon(PackedVector2Array([Vector2(left, top) * _f, Vector2(body, top) * _f, Vector2(right, (top + low) / 2.0) * _f, 
			Vector2(body, low) * _f, Vector2(left, low) * _f]), Color(str(spec.arrow)))
	var title: Array = spec.title
	var label_w: float = float(title[0])
	var gap: float = floorf((float(spec.wide) - label_w * count) / count)
	var x: float = at.x + (float(spec.wide) - (label_w * count + gap * (count - 1))) / 2.0
	var viewing: int = int(_shown_round.get("phase", 0))
	for i: int in count:
		var id: int = int(phases[i][0])
		var chosen: bool = id == viewing and not _shown_round.is_empty()
		var scale: float = SELECT_SCALE if chosen else 1.0
		var hit_id: String = "phase:%d" % id
		var rect: Rect2 = Rect2(Vector2(x, at.y - 1.0) * _f, Vector2(label_w, float(title[1])) * scale * _f)
		var size_px: int = maxi(6, roundi(float(title[2]) * scale * _f))
		var text: String = str(phases[i][1])
		var wide: float = _italic.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
		var spot: Vector2 = Vector2(rect.get_center().x - wide / 2.0, rect.get_center().y + (_italic.get_ascent(size_px) - _italic.get_descent(size_px)) / 2.0)
		var ink: Color = HOVER_INK if chosen or (_hover == hit_id and _press.is_empty()) else Color.WHITE
		draw_string_outline(_italic, spot, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, maxi(1, roundi(2.0 * _f)), Color(INFO_RIM, 0.9))
		draw_string(_italic, spot, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, ink)
		if not chosen:
			_hit(hit_id, rect, false)
		x += label_w * scale + gap


func _draw_round(o: Vector2) -> void :
	var buttons: Dictionary = Info.BUTTONS
	if int(_shown_round.get("pre", 0)) > 0:
		_fbutton("pre", "li_pre", o + _v(buttons.btnPreRound))
	else:
		_fblit("li_pre_off", o + _v(buttons.btnPreRound))
	if int(_shown_round.get("next", 0)) > 0:
		_fbutton("next", "li_next", o + _v(buttons.btnNextRound))
	else:
		_fblit("li_next_off", o + _v(buttons.btnNextRound))
	if _zones > 1:
		for i: int in mini(_zones, 4):
			_fbutton("zone:%d" % i, "li_zone%d%s" % [i, "_on" if _zone == i + 1 else ""], o + _v(buttons["btnZone%d" % i]))
	if _shown_round.is_empty():
		return
	var name_spot: Array = Info.LABELS.lblRoundName
	_fwords("%s-%s" % [str(_shown_round.phase_name), str(_shown_round.name)], ARIAL_BOLD, float(name_spot[4]), Color(str(name_spot[5])), "l", 
		o + _v(name_spot), float(name_spot[2]), 1.0, float(name_spot[3]), true, INFO_RIM)
	var time_spot: Array = Info.LABELS.lblMatchTime
	_fwords(TIP21.replace("@num1@", held_text(int(_shown_round.held))), ARIAL_BOLD, float(time_spot[4]), Color(str(time_spot[5])), "l", 
		o + _v(time_spot), float(time_spot[2]), 0.0)


func _draw_teams(o: Vector2) -> void :
	_fblit("li_rank", o + _v(Info.RANK))
	for head: Array in Info.HEAD:
		_fwords(str(head[2]), ARIAL_BOLD, 13.0, Color.WHITE, "c", o + Vector2(float(head[0]) - 60.0, float(head[1])), 120.0, 1.0, 0.0, true, INFO_RIM)
	var spot: Array = Info.LIST
	var at: Vector2 = o + _v(spot)
	var wide: float = float(spot[2])
	var high: float = float(spot[3])
	var row_h: float = float(spot[4])
	_list_rect = Rect2(at * _f, Vector2(wide, high) * _f)
	_clip = Rect2(at * _f, Vector2(wide - BAR, high) * _f)
	for k: int in ceili(high / row_h):
		var index: int = _top + k
		if index >= _teams.size():
			break
		_draw_team(index, at + Vector2(0, k * row_h))
	_clip = Rect2()
	_draw_bar(at + Vector2(wide - BAR, 0), high - 2.0 * BAR)



func _draw_team(index: int, at: Vector2) -> void :
	var team: Dictionary = _teams[index]
	var row: Dictionary = Info.ROW
	var full: Rect2 = Rect2(at * _f, Vector2(836, 32) * _f)
	var stripe: Array = row.stripe
	_cut_rect(full, Color8(int(stripe[0]), int(stripe[1]), int(stripe[2]), int(stripe[3])))
	if index == _sel:
		_cut_rect(full, PICK_FILL)
		_cut_rect(Rect2(full.position, Vector2(full.size.x, 2.0 * _f)), PICK_EDGE)
		_cut_rect(Rect2(Vector2(full.position.x, full.end.y - 2.0 * _f), Vector2(full.size.x, 2.0 * _f)), PICK_EDGE)
	_cell(str(int(team.rank)) if int(team.rank) > 0 else "--", row.lblRank, at)
	_cell(str(team.name), row.lblClanName, at)
	_cell(str(int(team.glory)), row.lblGlory, at)
	_cell(str(int(team.score)), row.lblScore, at)
	_draw_record(team, row.lblWinCount, at)
	_cell("%d%%" % int(team.rate), row.lblWinRate, at)
	_cblit("li_cut", at + _v(row.cut))
	var shown: Rect2 = full.intersection(_clip)
	if shown.has_area():
		_hit("row:%d" % index, shown, false)

func _cut_rect(rect: Rect2, color: Color) -> void :
	var cut: Rect2 = rect.intersection(_clip) if _clip.has_area() else rect
	if cut.has_area():
		draw_rect(cut, color)

func _visible_line(at: Vector2, px: float) -> bool:
	if not _clip.has_area():
		return true
	var middle: float = (at.y + 2.0 + px * 0.55) * _f
	var half: float = px * 0.6 * _f
	return middle - half >= _clip.position.y - 1.0 and middle + half <= _clip.end.y + 1.0


func _cell(text: String, spec: Array, base: Vector2) -> void :
	var at: Vector2 = base + _v(spec)
	if not _visible_line(at, float(spec[4])):
		return
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), Color(str(spec[5])), str(spec[7]), at, float(spec[2]), 1.0)


func _draw_record(team: Dictionary, spec: Array, base: Vector2) -> void :
	var at: Vector2 = base + _v(spec)
	var px: float = float(spec[4])
	if not _visible_line(at, px):
		return
	var win: String = str(int(team.win)) if int(team.win) > 0 else "--"
	var lose: String = str(int(team.lose)) if int(team.lose) > 0 else "--"
	var head: String = CONTROL_TEXT39.get_slice("@win@", 0)
	var middle: String = CONTROL_TEXT39.get_slice("@win@", 1).get_slice("@lose@", 0)
	var tail: String = CONTROL_TEXT39.get_slice("@lose@", 1)
	var parts: Array = [[head, Color.WHITE], [win, WIN_INK if int(team.win) > 0 else Color.WHITE], [middle, Color.WHITE], 
		[lose, LOSE_INK if int(team.lose) > 0 else Color.WHITE], [tail, Color.WHITE]]
	var font_px: int = maxi(6, roundi(px * _f))
	var total: float = 0.0
	for part: Array in parts:
		total += ARIAL.get_string_size(str(part[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_px).x / _f
	var wide: float = float(spec[2])
	var fit: float = px * minf(1.0, (wide - 2.0) / maxf(1.0, total))
	var x: float = at.x + (wide - total * fit / px) / 2.0
	for part: Array in parts:
		if str(part[0]).is_empty():
			continue
		x += _fwords(str(part[0]), ARIAL, fit, part[1], "l", Vector2(x, at.y), wide, 1.0, 0.0, false)


func _draw_gifts(o: Vector2) -> void :
	var spec: Dictionary = Info.REWARD
	_fblit("li_win", o + _v(spec.win_t))
	_fblit("li_lose", o + _v(spec.lose_t))
	for kind: String in ["win", "lose"]:
		var base: Vector2 = o + _v(spec[kind])
		for cell: Array in _gifts[kind]:
			var slot: int = int(cell[0])
			_draw_tile(cell[1], base + Vector2(float(slot % int(spec.cols)), floorf(float(slot) / float(spec.cols))) * _v(spec.pitch))


func _draw_tile(gift: Dictionary, at: Vector2) -> void :
	super (gift, at)
	match str(gift.kind):
		"exp":
			_cblit("la_exp", at + Vector2(21, 17))
		"glory":
			_cblit("la_honor", at + Vector2(21, 17))


func _draw_bar(at: Vector2, track: float) -> void :
	_fblit("lr_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("bar:up", "lr_sb_up", at)
	_fbutton("bar:down", "lr_sb_down", at + Vector2(0, BAR + track))
	var most: float = float(max_top())
	if most <= 0.0:
		return
	var thumb: float = maxf(20.0, track * ROWS / (most + ROWS))
	var y: float = at.y + BAR + (track - thumb) * clampf(_top / most, 0.0, 1.0)
	_hit("bar:pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, y - at.y - BAR) * _f), false)
	_hit("bar:pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(BAR, at.y + BAR + track - y - thumb) * _f), false)
	_fslice("lr_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:bar"))
	_hit("slide:bar", Rect2(Vector2(at.x, y) * _f, Vector2(BAR, thumb) * _f), false)
	_bar = [track, thumb, most]



func _activate(id: String) -> void :
	if id.begins_with("phase:"):

		var phase: Array = _phase(int(id.substr(6)))
		if phase.is_empty() or host == null:
			return
		var rounds: Array = host.rounds()
		var first: int = int(phase[2])
		if first >= 0 and first < rounds.size() and int(rounds[first][0]) == int(phase[0]):
			request_round(int(rounds[first][2]))
		return
	if id.begins_with("zone:"):

		var picked: int = int(id.substr(5)) + 1
		if picked == _zone:
			return
		_zone = picked
		clear_data()
		_request_teams(_zone, 0, 1 if _style == "group" else 0)
		return
	if id.begins_with("row:"):
		_sel = int(id.substr(4))
		return
	match id:
		"close":
			close()
		"pre":
			if int(_shown_round.get("pre", 0)) != 0:
				request_round(int(_shown_round.pre))
		"next":
			if int(_shown_round.get("next", 0)) != 0:
				request_round(int(_shown_round.next))
		"find":
			find_team(_search.text)
		"enter":
			_enter()
		"reward":
			if host == null or int(host.awards()) == 0:
				say(TIP_317)
			else:
				reward_asked.emit()
		"bar:up":
			_scroll(_top - 1)
		"bar:down":
			_scroll(_top + 1)
		"bar:pgup":
			_scroll(_top - ROWS)
		"bar:pgdn":
			_scroll(_top + ROWS)


func _enter() -> void :
	if host == null or not bool(host.applied()):
		say(TIP13)
		return
	match int(host.process_state()):
		ARMISTICE:
			say(TIP_141)
		GAME_OVER:
			say(TIP22)
		KICK_OUT:
			say(TIP20)
		MOVE_ON:
			var word: String = client.league_queue()
			close()
			queued.emit(word)

func _drag(moved: Vector2, from: Vector2) -> void :
	if _grab or not _list_rect.has_point(from):
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, ROW_PULL * _f)
	while _pull >= pitch:
		_pull -= pitch
		_scroll(_top + 1)
	while _pull <= - pitch:
		_pull += pitch
		_scroll(_top - 1)

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_ESCAPE:
			close()
		KEY_UP:
			_scroll(_top - 1)
		KEY_DOWN:
			_scroll(_top + 1)
		KEY_PAGEUP:
			_scroll(_top - ROWS)
		KEY_PAGEDOWN:
			_scroll(_top + ROWS)
		KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER:
			pass
		_:
			return
	get_viewport().set_input_as_handled()
