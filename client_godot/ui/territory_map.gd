extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")















const Tm = preload("territory_map_atlas.gd")
const Arena = preload("arena_atlas.gd")
const Rules = preload("ladder_rule_atlas.gd")
const CorpsRank = preload("corps_rank.gd")

signal closed

const MAP_PATH: String = "/territory/map.txt"
const PERIOD: float = 5.0
const MAP_W: float = 3094.0
const MAP_H: float = 1856.0
const CORPS_ACT: int = 30
const CORPS_ACT_IDS: Array = [3001, 3002]
const WAR_QUEST: int = 1200

const LEVEL_NAMES: Dictionary = {1: "Cứ Điểm Tiếp Viện", 2: "Thánh Sơn", 3: "Thánh Địa", 4: "Thánh Cảnh", 5: "Thánh Vực", 6: "Vĩnh Hằng"}
const TIP_353: String = "HĐ chưa mở"
const TIP_663: String = "Mời tham gia Guild"
const NONE: String = "Không có"
const PICK_CITY: String = "Lãnh Thổ Chiến: bấm vào một thành trên bản đồ để vào chiến trường."
const SOON: String = "%s đang được chuyển sang HTML5."
const LATER: Dictionary = {"castle": "Vào chiến trường Lãnh Thổ Chiến"}
const TEXT: Color = Color("ede3c8")
const TEXT_RIM: Color = Color(0, 0, 0, 0.95)
const TIP_RIM: Color = Color(0.027, 0.392, 0.737, 0.8)
const ENTITIES: Dictionary = {"amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": " "}

const RULE_PATH: String = "/xml/SystemTip_table.xml"
const RULE_TIP: int = 165
const RULE_SIZE: Vector2 = Vector2(534, 510)
const RULE_DESC: Rect2 = Rect2(15, 45, 504, 400)
const RULE_PAD: Array = [12.0, 8.0, 15.0]
const RULE_PX: float = 14.0
const RULE_TITLE: String = "Quy Tắc"
const RULE_BG: Color = Color("1376ba")
const RULE_INK: Color = Color("fdfdfd")
const RULE_RIM: Color = Color(0.086, 0.204, 0.514, 0.8)
const RULE_GLOW: Color = Color("737372cc")
const RULE_WHEEL: int = 3
const REPEAT_DELAY: float = 0.5
const REPEAT_STEP: float = 0.035

var fetch_hook: Callable = Callable()
var states: Array = []
var ups: Array = []
var texts: Array = []
var head: String = ""
var legend: String = ""
var loaded: bool = false
var _city: Array = []
var _owner: Array = []
var _lines: Array = []
var _head_lines: Array = []
var _legend_lines: Array = []
var _http: HTTPRequest
var _busy: bool = false
var _booted: bool = false
var _gone: bool = false
var _wait: float = PERIOD
var _view: Vector2 = Vector2.ZERO
var _laid: Vector2 = Vector2.ZERO
var _cx: Array = []
var _cy: Array = []
var _hw: Array = []
var _hh: Array = []
var _mouse: Vector2 = Vector2.ZERO
var rule_text: String = ""
var _rule_open: bool = false
var _rule_top: int = 0
var _rule_most: int = 0
var _rule_runs: Array = []
var _rule_rev: int = 0
var _rule_http: HTTPRequest
var _rule_busy: bool = false
var _rule_rect: Rect2 = Rect2()
var _rule_bar: Array = []
var _wrap_key: String = ""
var _wrapped: Array = []
var _words: RegEx = RegEx.create_from_string("\\S+\\s*|\\s+")
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_top: float = 0.0
var _pull: float = 0.0
var _rep_id: String = ""
var _rep_next: float = 0.0
var _rep_skip: bool = false
var _rank: Control = null

func _setup() -> void :
	_use(Tm.FILE, Tm.R)
	clip_contents = true
	_reset_data()
	_layout(Vector2(1000, 600))
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		map_arrived(code if result == HTTPRequest.RESULT_SUCCESS else 0, body.get_string_from_utf8()))
	_rule_http = HTTPRequest.new()
	_rule_http.timeout = 10
	_rule_http.accept_gzip = false
	add_child(_rule_http)
	_rule_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		rule_arrived(code if result == HTTPRequest.RESULT_SUCCESS else 0, body))
	if client != null:
		client.noticed.connect( func(text: String) -> void :
			if is_visible_in_tree():
				say(text))


func _shown() -> void :
	if is_visible_in_tree():
		_reset_data()
		_booted = false
		_gone = false
		_laid = Vector2.ZERO
		_wait = PERIOD
		load_map()
	else:
		if _http != null:
			_http.cancel_request()
		_busy = false
		_close_rule()
		if _rank != null:
			_rank.close()

func _reset_data() -> void :
	states = []
	texts = []
	_city = []
	_owner = []
	_lines = []
	for slot: int in 16:
		states.append("")
		texts.append("")
		_city.append("")
		_owner.append("")
		_lines.append([])
	ups = Tm.UP.duplicate()
	head = ""
	legend = ""
	_head_lines = []
	_legend_lines = []
	loaded = false

func _tick(delta: float) -> void :
	_wait -= delta
	if _wait <= 0.0:
		_wait = PERIOD
		if not _gone:
			load_map()
	if _rule_open and not _rep_id.is_empty():

		if _held and _press == _rep_id and _hit_at(get_local_mouse_position()) == _rep_id:
			if _time >= _rep_next:
				_rule_step(_rep_id)
				_rep_next = maxf(_rep_next + REPEAT_STEP, _time - REPEAT_STEP)
		else:
			_rep_id = ""




func load_map() -> void :
	if _busy or client == null:
		return
	var url: String = "%s?oid=%d%s&t=%d" % [MAP_PATH, int(client.account_oid), "" if _booted else "&boot=v12", Time.get_ticks_msec()]
	if fetch_hook.is_valid():
		_booted = true
		_busy = true
		fetch_hook.call(url)
		return
	if str(client.config.origin).is_empty() or _http == null:
		return
	_booted = true
	_busy = true
	_http.cancel_request()
	var full: String = str(client.config.origin) + url
	if _http.request(full, AppSession.headers(full)) != OK:
		_busy = false


func map_arrived(code: int, text: String) -> void :
	_busy = false
	_gone = code == 404
	if code == 200:
		read_map(text)


func read_map(text: String) -> bool:
	var rows: PackedStringArray = text.replace("\r", "").split("\n")
	if rows.size() < 18 or rows[0] != "TMAP1":
		return false
	head = rows[1]
	legend = rows[2]
	_head_lines = html_lines(head, TEXT)
	_legend_lines = html_lines(legend, TEXT)
	for i: int in range(3, rows.size()):
		var cols: PackedStringArray = rows[i].split("\t")
		if cols.size() < 6:
			continue
		var slot: int = cols[0].to_int()
		if slot < 1 or slot > 15:
			continue
		states[slot] = cols[1]
		ups[slot] = cols[2].to_int()
		texts[slot] = cols[3] + "<br>" + cols[4] + "<br>" + cols[5]
		_city[slot] = cols[3]
		_owner[slot] = cols[4]
		_lines[slot] = html_lines(texts[slot], TEXT)
	loaded = true
	return true


static func html_lines(html: String, base: Color) -> Array:
	var lines: Array = [[]]
	var colors: Array = [base]
	var bold: int = 0
	var at: int = 0
	var count: int = html.length()
	while at < count:
		var open: int = html.find("<", at)
		var stop: int = count if open < 0 else open
		if stop > at:
			var piece: String = _entities(html.substr(at, stop - at))
			if not piece.is_empty():
				(lines[-1] as Array).append([piece, colors[-1], bold > 0])
		if open < 0:
			break
		var close: int = html.find(">", open)
		if close < 0:
			break
		var tag: String = html.substr(open + 1, close - open - 1).strip_edges()
		match tag.get_slice(" ", 0).to_lower():
			"b":
				bold += 1
			"/b":
				bold = maxi(0, bold - 1)
			"font":
				colors.append(_tag_color(tag, colors[-1]))
			"/font":
				if colors.size() > 1:
					colors.pop_back()
			"br", "br/":
				lines.append([])
		at = close + 1
	return lines

static func _tag_color(tag: String, fallback: Color) -> Color:
	var at: int = tag.to_lower().find("color=")
	if at < 0:
		return fallback
	var rest: String = tag.substr(at + 6).strip_edges()
	var value: String = rest.get_slice(" ", 0)
	var quote: String = rest.left(1)
	if quote == "'" or quote == "\"":
		var end: int = rest.find(quote, 1)
		value = rest.substr(1, end - 1) if end > 0 else rest.substr(1)
	value = value.strip_edges().trim_prefix("#")
	return Color.html(value) if Color.html_is_valid(value) else fallback

static func _entities(text: String) -> String:
	if text.find("&") < 0:
		return text
	var out: String = ""
	var at: int = 0
	while true:
		var amp: int = text.find("&", at)
		if amp < 0:
			out += text.substr(at)
			break
		out += text.substr(at, amp - at)
		var semi: int = text.find(";", amp)
		var name: String = text.substr(amp + 1, semi - amp - 1) if semi > amp and semi - amp <= 9 else ""
		var glyph: String = str(ENTITIES.get(name, ""))
		if name == "nbsp":
			glyph = char(160)
		elif glyph.is_empty() and name.begins_with("#") and name.length() > 1:
			var code: int = name.substr(2).hex_to_int() if name.substr(1, 1).to_lower() == "x" else name.substr(1).to_int()
			if code > 0:
				glyph = char(code)
		if glyph.is_empty():
			out += "&"
			at = amp + 1
		else:
			out += glyph
			at = semi + 1
	return out


static func strip_html(html: String) -> String:
	var words: PackedStringArray = []
	for line: Array in html_lines(html, Color.WHITE):
		var text: String = ""
		for run: Array in line:
			text += str(run[0])
		words.append(text)
	return " ".join(words).strip_edges()



func tip_info(slot: int) -> Array:
	var kind: String = str(LEVEL_NAMES.get(int(Tm.LEVEL[slot]), "")) if slot >= 1 and slot <= 15 else ""
	var city: String = strip_html(str(_city[slot])) if slot >= 1 and slot <= 15 else ""
	if not kind.is_empty() and city.ends_with(" " + kind):
		city = city.trim_suffix(" " + kind)
	var owner: String = strip_html(str(_owner[slot])) if slot >= 1 and slot <= 15 else ""
	return [kind, NONE if city.is_empty() else city, NONE if owner.is_empty() else owner]


func corps_war_on(now: int = -1) -> bool:
	var ids: Array = []
	for id: Variant in client.act_types:
		if int(client.act_types[id]) == CORPS_ACT:
			ids.append(int(id))
	if ids.is_empty():
		ids = CORPS_ACT_IDS
	for id: int in ids:
		if client.act_now_state(id, now) == 2:
			return true
	return false


func reward_ready() -> bool:
	var quest: Variant = client.quests.get(WAR_QUEST) if client != null else null
	return quest is Array and not (quest as Array).is_empty() and int(quest[0]) == 3



func get_reward() -> bool:
	if not reward_ready() or not client.has_method("quest_complete"):
		return false
	return bool(client.call("quest_complete", WAR_QUEST, 0))



func join_word(now: int = -1) -> String:
	if not corps_war_on(now):
		return TIP_353
	if client.guild.is_empty():
		return TIP_663
	return PICK_CITY


func join_castle(slot: int) -> void :
	if client == null or not client.has_method("territory_join"):
		say(SOON % LATER["castle"])
		return
	var word: String = str(client.call("territory_join", slot))
	if not word.is_empty():
		say(word)




func load_rule() -> void :
	if not rule_text.is_empty() or _rule_busy or client == null:
		return
	if fetch_hook.is_valid():
		_rule_busy = true
		fetch_hook.call(RULE_PATH)
		return
	if client.config.local_test_only or str(client.config.origin).is_empty() or _rule_http == null:
		return
	_rule_busy = true
	var url: String = str(client.config.origin) + RULE_PATH
	if _rule_http.request(url, AppSession.headers(url)) != OK:
		_rule_busy = false


func rule_arrived(code: int, body: PackedByteArray) -> void :
	_rule_busy = false
	if code != 200:
		return
	var text: String = system_tip(body, RULE_TIP)
	if not text.is_empty():
		set_rule(text)

func set_rule(text: String) -> void :
	rule_text = text
	_rule_runs = html_lines(rule_html(text), RULE_INK)
	_rule_rev += 1


static func system_tip(body: PackedByteArray, id: int) -> String:
	var parser: XMLParser = XMLParser.new()
	if body.is_empty() or parser.open_buffer(body) != OK:
		return ""
	var row: Dictionary = {}
	var inside: bool = false
	var field: String = ""
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node: String = parser.get_node_name()
				if node == "entry":
					row = {}
					inside = not parser.is_empty()
				elif inside and not parser.is_empty():
					field = node
			XMLParser.NODE_TEXT, XMLParser.NODE_CDATA:
				if inside and not field.is_empty():
					row[field] = str(row.get(field, "")) + parser.get_node_data()
			XMLParser.NODE_ELEMENT_END:
				var node: String = parser.get_node_name()
				if node == "entry":
					inside = false
					if str(row.get("iId", "")).strip_edges().to_int() == id and str(row.get("iId", "")).strip_edges() != "":
						return _xml_text(str(row.get("szContent", "")))
				elif node == field:
					field = ""
	return ""

static func _xml_text(text: String) -> String:
	if not "&" in text:
		return text
	return text.replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", "\"").replace("&apos;", "'").replace("&amp;", "&")



static func rule_html(text: String) -> String:
	var rest: String = text.replace("\r", "").replace("#ENTER#", "\n")
	var out: String = ""
	while true:
		var a: int = rest.find("#COLOR_")
		var b: int = rest.find("_END#")
		if a < 0 or b < 0 or a >= b:
			break
		var parts: PackedStringArray = rest.substr(a, b + 5 - a).split("_")
		var ok: bool = parts.size() > 2
		out += rest.substr(0, a) + "<font color=\"#%s\">%s</font>" % [parts[1] if ok else "", parts[2] if ok else ""]
		rest = rest.substr(b + 5)
	return (out + rest).replace("\n", "<br>")


func rule_pitch() -> float:
	return _face(ARIAL_BOLD).get_height(maxi(6, roundi(RULE_PX * _f))) / maxf(_f, 0.001)


func rule_shown() -> int:
	return maxi(1, floori((RULE_DESC.size.y - float(RULE_PAD[1]) - 4.0) / rule_pitch()))


func rule_room(bar: bool) -> float:
	return RULE_DESC.size.x - float(RULE_PAD[0]) - float(RULE_PAD[2]) - 4.0 - (float(Rules.BAR) if bar else 0.0)

func rule_open() -> bool:
	return _rule_open

func rule_top() -> int:
	return _rule_top

func rule_most() -> int:
	return _rule_most


func rule_lines(wide: float) -> Array:
	var font_size: int = maxi(6, roundi(RULE_PX * _f))
	var key: String = "%d|%d|%d" % [roundi(wide * 10.0), font_size, _rule_rev]
	if key == _wrap_key:
		return _wrapped
	var font: Font = _face(ARIAL_BOLD)
	var limit: float = wide * _f
	var out: Array = []
	for line: Array in _rule_runs:
		var row: Array = []
		var used: float = 0.0
		for run: Array in line:
			for found: RegExMatch in _words.search_all(str(run[0])):
				var piece: String = found.get_string()
				var bare: float = font.get_string_size(piece.rstrip(" "), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				if not row.is_empty() and used + bare > limit:
					out.append(row)
					row = []
					used = 0.0
				while row.is_empty() and bare > limit and piece.length() > 1:
					var cut: int = piece.length() - 1
					while cut > 1 and font.get_string_size(piece.left(cut), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > limit:
						cut -= 1
					out.append([[piece.left(cut), run[1]]])
					piece = piece.substr(cut)
					bare = font.get_string_size(piece.rstrip(" "), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				if not row.is_empty() and row[-1][1] == run[1]:
					row[-1][0] = str(row[-1][0]) + piece
				else:
					row.append([piece, run[1]])
				used += font.get_string_size(piece, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		out.append(row)
	_wrap_key = key
	_wrapped = out
	return out

func _rule_roll(value: int) -> void :
	_rule_top = clampi(value, 0, _rule_most)

func _rule_step(id: String) -> void :
	_rule_roll(_rule_top + (1 if id == "rule:down" else -1))

func _close_rule() -> void :
	_rule_open = false
	_rule_top = 0
	_rule_bar = []
	_grab = false
	_rep_id = ""
	_rep_skip = false



static func half_h(slot: int) -> float:
	if slot == 1:
		return 95.0
	if slot <= 3:
		return 75.0
	return 57.5 if slot <= 7 else 45.0

static func half_w(slot: int) -> float:
	if slot == 1:
		return 110.0
	if slot <= 3:
		return 90.0
	return 70.0 if slot <= 7 else 54.0


func _layout(stage: Vector2) -> void :
	_laid = stage
	var vw: float = stage.x
	var vh: float = stage.y
	var bw: float = maxf(1500.0, minf(2900.0, vw - 80.0))
	var bh: float = maxf(700.0, minf(1700.0, vh - 175.0))
	var mid_x: float = maxf(bw * 0.5 + 40.0, minf(MAP_W - 40.0 - bw * 0.5, 2150.0))
	var mid_y: float = maxf(bh * 0.5 + 30.0, minf(MAP_H - 30.0 - bh * 0.5, 560.0))
	var left: float = mid_x - bw * 0.5
	var top: float = mid_y - bh * 0.5
	_view = Vector2(floorf(maxf(1.0, minf(MAP_W - vw, left - (vw - bw) * 0.5)) + 0.5), 
		floorf(maxf(1.0, minf(MAP_H - vh, top - 70.0)) + 0.5))
	_cx = []
	_cy = []
	_hw = []
	_hh = []
	for slot: int in 16:
		_cx.append(floorf(left + bw * float(Tm.POS_U[slot]) + 0.5))
		_cy.append(floorf(top + bh * float(Tm.POS_V[slot]) + 0.5))
		_hw.append(half_w(slot))
		_hh.append(half_h(slot))

func layout_info() -> Dictionary:
	return {"view": _view, "cx": _cx.duplicate(), "cy": _cy.duplicate()}

func _drag(moved: Vector2, from: Vector2) -> void :
	if _rule_open:

		if _grab or not _rule_rect.has_point(from) or _hit_at(from) != "panel":
			return
		_pull -= moved.y
		var pitch: float = maxf(8.0, rule_pitch() * _f)
		while _pull >= pitch:
			_pull -= pitch
			_rule_roll(_rule_top + 1)
		while _pull <= - pitch:
			_pull += pitch
			_rule_roll(_rule_top - 1)
		return

	var under: String = _hit_at(from)
	if not under.is_empty() and not under.begins_with("castle:"):
		return
	_view -= moved / _f
	_clamp_view()

func _clamp_view() -> void :
	_view = Vector2(clampf(_view.x, 0.0, maxf(0.0, MAP_W - _laid.x)), clampf(_view.y, 0.0, maxf(0.0, MAP_H - _laid.y)))



func _map_at(point: Vector2) -> Vector2:
	return (point - _view) * _f

func _paint() -> void :
	var stage: Vector2 = Vector2(floorf(_fw + 0.01), floorf(_fh + 0.01))
	if not _laid.is_equal_approx(stage):
		_layout(stage)
	draw_rect(Rect2(Vector2.ZERO, size), Color("0b0805"))
	var map: Texture2D = pack.picture(str(Tm.MAP["path"])) if pack != null else null
	if map != null and map.get_width() > 4:
		draw_texture_rect(map, Rect2(_map_at(Vector2.ZERO), Vector2(MAP_W, MAP_H) * _f), false)
	_paint_roads()
	var wave: float = 0.6 + 0.4 * sin(Time.get_ticks_msec() / 260.0)
	for slot: int in range(1, 16):
		match str(states[slot]):
			"A":
				_paint_glow(slot, Color("ffd54a"), wave)
			"O":
				_paint_glow(slot, Color("6cff6c"), 0.85)
	for slot: int in range(1, 16):
		var id: String = "castle:%d" % slot
		var lit: float = _shine(id)
		var tint: Color = Color(0.4 * lit, 0.4 * lit, 0.46 * lit) if str(states[slot]) == "L" else Color(lit, lit, lit)
		var rect: Rect2 = _fblit("tm_castle_%d" % int(Tm.LEVEL[slot]), Vector2(_cx[slot] - _hw[slot], _cy[slot] - _hh[slot]) - _view, 
			_hw[slot] * 2.0, _hh[slot] * 2.0, tint)
		_hit(id, rect, false)
	for slot: int in range(1, 16):
		_paint_label(slot)
	_paint_frame(stage)
	_paint_tip(stage)
	if _rule_open:
		_draw_rule()


static func road_point(a: Vector2, b: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	var mid: float = (a.x + b.x) * 0.5
	return Vector2(u * u * u * a.x + 3.0 * u * u * t * mid + 3.0 * u * t * t * mid + t * t * t * b.x, 
		u * u * u * a.y + 3.0 * u * u * t * a.y + 3.0 * u * t * t * b.y + t * t * t * b.y)



func _paint_roads() -> void :
	for slot: int in range(1, 16):
		var up: int = int(ups[slot])
		if up < 1 or up > 15:
			continue
		var own: bool = str(states[slot]) == "O"
		var a: Vector2 = Vector2(_cx[slot], _cy[slot])
		var b: Vector2 = Vector2(_cx[up], _cy[up])
		var points: PackedVector2Array = [_map_at(a)]
		for i: int in range(1, 37):
			points.append(_map_at(road_point(a, b, i / 36.0)))
		draw_polyline(points, Color(Color("10240a") if own else Color("2a1a08"), 0.82), (15.0 if own else 13.0) * _f, true)
		var color: Color = Color("8cff5a") if own else Color(Color("f1d9a0"), 0.95)
		var width: float = (7.0 if own else 5.0) * _f
		if own:
			draw_polyline(points, color, width, true)
			continue
		for i: int in range(0, 36, 3):
			draw_polyline(points.slice(i, i + 3), color, width, true)

func _ellipse(at: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var points: PackedVector2Array = []
	for i: int in 48:
		var angle: float = TAU * i / 48.0
		points.append(at + Vector2(cos(angle) * rx, sin(angle) * ry))
	return points


func _paint_glow(slot: int, color: Color, alpha: float) -> void :
	var at: Vector2 = _map_at(Vector2(_cx[slot], _cy[slot] + _hh[slot] * 0.55))
	var rx: float = _hw[slot] * 1.05 * _f
	var ry: float = _hh[slot] * 0.42 * _f
	if not (rx >= 0.5 and ry >= 0.5 and is_finite(rx) and is_finite(ry) and at.is_finite()):
		return
	for k: int in range(4, 0, -1):
		var grow: float = k * 4.0 * _f
		draw_colored_polygon(_ellipse(at, rx * 1.25 + grow, ry * 1.25 + grow), Color(color, 0.05 * alpha))
	draw_colored_polygon(_ellipse(at, rx * 1.25, ry * 1.25), Color(color, 0.16 * alpha))
	draw_colored_polygon(_ellipse(at, rx, ry), Color(color, 0.26 * alpha))
	var ring: PackedVector2Array = _ellipse(at, rx * 0.86, ry * 0.86)
	ring.append(ring[0])
	draw_polyline(ring, Color(color, 0.95 * alpha), 3.0 * _f, true)

func _step(px: float) -> float:
	return roundf(px * 1.15)

func _line_width(line: Array, font_size: int) -> float:
	var wide: float = 0.0
	for run: Array in line:
		wide += (ARIAL_BOLD if run[2] else ARIAL).get_string_size(str(run[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	return wide


func _extent(lines: Array, px: float) -> Vector2:
	var font_size: int = maxi(6, roundi(px * _f))
	var wide: float = 0.0
	for line: Array in lines:
		wide = maxf(wide, _line_width(line, font_size))
	return Vector2(wide / _f, lines.size() * _step(px))


func _runs(lines: Array, px: float, centre_x: float, top: float, alpha: float = 1.0) -> void :
	var font_size: int = maxi(6, roundi(px * _f))
	var outline: int = maxi(1, roundi(2.5 * _f))
	var ascent: float = ARIAL.get_ascent(font_size)
	for layer: int in 2:
		for i: int in lines.size():
			var line: Array = lines[i]
			var x: float = centre_x * _f - _line_width(line, font_size) / 2.0
			var y: float = (top + 2.0 + i * _step(px)) * _f + ascent
			for run: Array in line:
				var font: Font = ARIAL_BOLD if run[2] else ARIAL
				var text: String = str(run[0])
				if layer == 0:
					draw_string_outline(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline, 
						Color(TEXT_RIM, TEXT_RIM.a * alpha))
				else:
					var color: Color = run[1]
					draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(color, color.a * alpha))
				x += font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x


func _paint_label(slot: int) -> void :
	var lines: Array = _lines[slot]
	if lines.is_empty() or str(texts[slot]).is_empty():
		return
	var mode: String = str(states[slot])
	var alpha: float = 0.8 if mode == "L" else 1.0
	var back: Vector2 = Vector2(_cx[slot], _cy[slot] + _hh[slot] - 4.0) - _view
	var extent: Vector2 = _extent(lines, 12.0)
	var wide: float = minf(236.0, maxf(110.0, extent.x + 20.0))
	var edge: Color = Color("6cff6c") if mode == "O" else (Color("e8c25a") if mode == "A" else Color("6e6250"))
	_round(Rect2((back + Vector2( - wide * 0.5, -1.0)) * _f, Vector2(wide, extent.y + 8.0) * _f), Color(Color("120c06"), 0.72 * alpha), 12.0, 
		Color(edge, 0.9 * alpha), 2.0)
	_runs(lines, 12.0, back.x, back.y, alpha)


func _paint_frame(stage: Vector2) -> void :
	_fblit("tm_border", Vector2.ZERO, stage.x, stage.y)
	_fblit("tm_title_bg", Vector2(roundf((stage.x - 1000.0) / 2.0), 0))
	_fblit("tm_title", Vector2(roundf((stage.x - 134.0) / 2.0), 0))
	_fbutton("close", "tm_close", Vector2(stage.x - 46.0, 0))
	for row: Array in Tm.BUTTONS:
		var id: String = str(row[0])
		var wide: float = float(row[4])
		var high: float = float(row[5])
		var at: Vector2 = Vector2(roundf((stage.x - wide) / 2.0 + float(row[2])), stage.y - float(row[3]) - high)
		if id == "reward" and not reward_ready():
			_fblit("tm_reward_off", at, wide, high)
			continue
		var drawn: Vector2 = at + (Vector2.ONE if _press == id and _hover == id else Vector2.ZERO)
		_fblit(str(row[1]), drawn, wide, high, _glow(id))
		_hit(id, Rect2(at * _f, Vector2(wide, high) * _f), false)
	var centre: float = roundf(stage.x * 0.5 - 450.0) + 450.0
	if not _head_lines.is_empty():
		_runs(_head_lines, 14.0, centre, 40.0)
	if not _legend_lines.is_empty():
		_runs(_legend_lines, 12.0, centre, 62.0)


func _cut(text: String, px: float, wide: float) -> String:
	var font_size: int = maxi(6, roundi(px * _f))
	var limit: float = (wide - 4.0) * _f
	if ARIAL_BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= limit:
		return text
	while text.length() > 0 and ARIAL_BOLD.get_string_size(text + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > limit:
		text = text.left(-1)
	return text + "..."


func _paint_tip(stage: Vector2) -> void :
	if not _hover.begins_with("castle:") or not _press.is_empty():
		return
	var slot: int = _hover.get_slice(":", 1).to_int()
	if slot < 1 or slot > 15:
		return
	var box: Vector2 = Vector2(float(Tm.TIP["size"][0]), float(Tm.TIP["size"][1]))
	var mouse: Vector2 = (_mouse / _f).floor()
	var at: Vector2 = Vector2(mouse.x if mouse.x - box.x < 0.0 else mouse.x - box.x, mouse.y if mouse.y - box.y < 0.0 else mouse.y - box.y)
	at = at.clamp(Vector2.ZERO, (stage - box).max(Vector2.ZERO))
	_fblit("tm_tip_bg", at)
	_fblit("tm_tip_%d" % int(Tm.LEVEL[slot]), at + Vector2(float(Tm.TIP["castle"][0]), float(Tm.TIP["castle"][1])))
	var info: Array = tip_info(slot)
	for i: int in 3:
		var row: Array = Tm.TIP["labels"][i]
		_fwords(_cut(str(info[i]), 14.0, float(row[2])), ARIAL_BOLD, 14.0, Color.WHITE, "l", at + Vector2(float(row[0]), float(row[1])), 
			float(row[2]), 2.0, 0.0, false, TIP_RIM)



func _draw_rule() -> void :
	if not _cells.has("public_bk_lt"):
		_use(Arena.FILE, Arena.R)
		_use(Rules.FILE, Rules.R)
	var at: Vector2 = _window(RULE_SIZE.x, RULE_SIZE.y, "rule:close")
	_fwords(RULE_TITLE, ARIAL_BOLD, 17.0, Color.WHITE, "c", at + Vector2(roundf((RULE_SIZE.x - 170.0) / 2.0), 22), 170.0, 1.0, 0.0, true, RULE_GLOW)
	var box: Vector2 = at + RULE_DESC.position
	_rule_rect = Rect2(box * _f, RULE_DESC.size * _f)
	_round(_rule_rect, RULE_BG, 20.0)
	var shown: int = rule_shown()
	var lines: Array = rule_lines(rule_room(false))
	var bar: bool = lines.size() > shown
	if bar:
		lines = rule_lines(rule_room(true))
	_rule_most = maxi(0, lines.size() - shown)
	_rule_top = clampi(_rule_top, 0, _rule_most)
	_draw_rule_text(lines, box + Vector2(float(RULE_PAD[0]) + 2.0, float(RULE_PAD[1]) + 2.0), shown)
	_rule_bar = []
	if bar:
		var size_bar: float = float(Rules.BAR)
		_draw_rule_bar(box + Vector2(RULE_DESC.size.x - size_bar, 0), RULE_DESC.size.y - 2.0 * size_bar)
	var button: Vector2 = _cell_size("public_button_window_green")
	var ok: Vector2 = at + Vector2(roundf((RULE_SIZE.x - button.x) / 2.0), RULE_SIZE.y - 17.0 - button.y)
	_fbutton("rule:ok", "public_button_window_green", ok)
	_fblit("title_title_confirm_green_t", ok + ((button - _cell_size("title_title_confirm_green_t")) / 2.0).round(), 0.0, 0.0, _glow("rule:ok"))


func _draw_rule_text(lines: Array, origin: Vector2, shown: int) -> void :
	var font: Font = _face(ARIAL_BOLD)
	var font_size: int = maxi(6, roundi(RULE_PX * _f))
	var rim: int = maxi(1, roundi(_f))
	var pitch: float = rule_pitch()
	for i: int in range(_rule_top, mini(lines.size(), _rule_top + shown)):
		var y: float = (origin.y + pitch * (i - _rule_top)) * _f + font.get_ascent(font_size)
		for layer: int in 2:
			var x: float = origin.x * _f
			for run: Array in lines[i]:
				var text: String = str(run[0])
				if layer == 0:
					draw_string_outline(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, rim, RULE_RIM)
				else:
					draw_string(font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, run[1])
				x += font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x


func _draw_rule_bar(at: Vector2, track: float) -> void :
	var bar: float = float(Rules.BAR)
	_fblit("lu_sb_bk", at + Vector2(0, bar), bar, track)
	_fbutton("rule:up", "lu_sb_up", at)
	_fbutton("rule:down", "lu_sb_down", at + Vector2(0, bar + track))
	var most: float = float(_rule_most)
	var shown: float = float(rule_shown())
	var thumb: float = maxf(20.0, track * shown / (most + shown))
	var y: float = at.y + bar + (track - thumb) * clampf(float(_rule_top) / maxf(most, 1.0), 0.0, 1.0)
	_hit("rule:pgup", Rect2(Vector2(at.x, at.y + bar) * _f, Vector2(bar, y - at.y - bar) * _f), false)
	_hit("rule:pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(bar, at.y + bar + track - y - thumb) * _f), false)
	_fslice("lu_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:rule"))
	_hit("slide:rule", Rect2(Vector2(at.x, y) * _f, Vector2(bar, thumb) * _f), false)
	_rule_bar = [track, thumb, most]


func _fslice(cell_name: String, at: Vector2, high: float, cap: float, tint: Color) -> void :
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



func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouse:
		_mouse = (event as InputEventMouse).position
	if _rule_open and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_pull = 0.0
		var id: String = _hit_at(event.position)

		if id in ["rule:up", "rule:down"]:
			_rule_step(id)
			_rep_id = id
			_rep_next = _time + REPEAT_DELAY
			_rep_skip = true
		elif id == "slide:rule" and not _rule_bar.is_empty():
			_grab = true
			_grab_at = event.position
			_grab_top = float(_rule_top)
	elif event is InputEventMouseMotion and _grab:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT) or _rule_bar.is_empty():
			_grab = false
		else:
			var step: float = maxf(0.001, (float(_rule_bar[0]) - float(_rule_bar[1])) / maxf(float(_rule_bar[2]), 1.0))
			_rule_roll(roundi(_grab_top + (event.position.y - _grab_at.y) / _f / step))
			accept_event()
			return
	super (event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_rep_id = ""
		_rep_skip = false
		_grab = false


func _wheel(step: int, at: Vector2) -> void :
	if _rule_open and _rule_rect.has_point(at):
		_rule_roll(_rule_top + step * RULE_WHEEL)


func _rule_activate(id: String) -> void :
	match id:
		"rule:ok", "rule:close":
			_close_rule()
		"rule:up", "rule:down":
			if _rep_skip:
				_rep_skip = false
			else:
				_rule_step(id)
		"rule:pgup":
			_rule_roll(_rule_top - rule_shown())
		"rule:pgdn":
			_rule_roll(_rule_top + rule_shown())

func _activate(id: String) -> void :
	if _rule_open:
		_rule_activate(id)
		return
	if id.begins_with("castle:"):
		join_castle(id.get_slice(":", 1).to_int())
		return
	match id:
		"close":
			closed.emit()
		"join":
			say(join_word())
		"rule":

			_rule_open = true
			_rule_top = 0
			_pull = 0.0
			load_rule()
		"rank":
			_open_rank()
		"reward":
			get_reward()


func _open_rank() -> void :
	if _rank == null:
		_rank = CorpsRank.new()
		_rank.client = client
		_rank.pack = pack
		_rank.hall = hall
		_rank.fetch = fetch_hook
		add_child(_rank)
		_rank.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rank.open()

func rank_open() -> bool:
	return _rank != null and _rank.visible


func chat_busy() -> bool:
	return rank_open()

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode != KEY_ESCAPE:
		return
	if _rule_open:
		_close_rule()
	else:
		closed.emit()
	get_viewport().set_input_as_handled()
