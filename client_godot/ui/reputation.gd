extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")














const Award = preload("league_award_atlas.gd")
const Arena = preload("arena_atlas.gd")
const BagModel = preload("bag_model.gd")

signal closed

const W: float = 440.0
const H: float = 460.0
const CELL_W: float = 76.0
const DIM: float = 0.4
const SHADOW: Color = Color("06325a")
const YELLOW: Color = Color("ffe45c")
const LEVEL_COLORS: Array = [Color("ff5a5a"), Color("ffe45c"), Color("5cf2ff")]
const LEVEL_NAMES: Array = ["Thấp", "Trung bình", "Tốt"]
const TITLE: String = "res://assets/ui/hall/rep_title.png"
const RULES: Array = ["Điểm Uy Tín dưới 60: không thể tham gia Đấu So Tài, Đấu Xếp Hạng, Đấu Đối Kháng.", 
	"Điểm Uy Tín dưới 90: không thể tham gia Đấu Xếp Hạng.", "Điểm Uy Tín đạt 100: nhận phần thưởng hằng tuần."]
const REWARDS: Array = [2002064, 1, 2004003, 1, 2000162, 1, 2003175, 1]
const LABELS: Dictionary = {"claimable": "Nhận thưởng", "claiming": "Đang nhận...", "claimed": "Đã nhận", "locked": "Chưa đạt"}
const SOON: String = "Sắp mở"
const SOON_TIP: String = "Phần thưởng Uy Tín sắp mở."
const RETRY: String = "Không nhận được thưởng, hãy thử lại."
const OFFLINE: String = "Không kết nối được máy chủ, hãy thử lại."
const RULE_LINE: float = 17.0

var score: int = 100
var top: int = 100
var status: String = "soon"
var tip: String = ""
var thresholds: Array = [60, 90]
var rules: Array = RULES.duplicate()
var rewards: Array = REWARDS.duplicate()
var xml_get: Callable
var asked: Array = []
var _http: HTTPRequest
var _busy: bool = false
var _title: Texture2D
var _state: String = ""

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_use(Arena.FILE, Arena.R)
	_use(Award.FILE, Award.R)
	_title = load(TITLE) if ResourceLoader.exists(TITLE) else null
	_http = HTTPRequest.new()
	_http.timeout = 15.0
	if OS.has_feature("web"):
		_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			receive(body.get_string_from_utf8())
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
	visible = true
	if pack != null:
		pack.load_bag()
	_load("/reputation.xml?t=")

func close() -> void :
	if not visible:
		return
	visible = false
	_busy = false
	if _http != null:
		_http.cancel_request()
	closed.emit()


func _load(path: String) -> void :
	if client == null:
		return
	if _http != null and _busy:
		_http.cancel_request()
	var url: String = str(client.config.origin) + path + str(Time.get_ticks_msec())
	asked.append(url)
	if xml_get.is_valid():
		_busy = xml_get.call(url) == OK
		return
	if client.config.get("local_test_only") == true or _http == null:
		return
	_busy = _http.request(url, AppSession.headers(url)) == OK
	if not _busy:
		fail()


func fail() -> void :
	_busy = false
	if status == "claiming":
		status = "claimable"
		say(OFFLINE)
	queue_redraw()


func receive(text: String) -> void :
	_busy = false
	var notice: String = ""
	var data: Dictionary = parse(text)
	if not data.is_empty():
		top = int(data.max)
		score = int(data.score)
		status = str(data.status)
		tip = str(data.tip)
		notice = str(data.notice)
		thresholds = data.thresholds
		rules = data.rules
		rewards = data.rewards
	if status == "claiming":
		status = "claimable"
		notice = RETRY
	if not notice.is_empty():
		say(notice)
	queue_redraw()



static func parse(text: String) -> Dictionary:
	var parser: XMLParser = XMLParser.new()
	if text.strip_edges().is_empty() or parser.open_buffer(text.to_utf8_buffer()) != OK:
		return {}
	var root: Dictionary = {}
	var out: Dictionary = {"thresholds": [], "rules": [], "rewards": []}
	var raw_thresholds: Array = []
	var depth: int = 0
	var in_rule: bool = false
	var rule: String = ""
	while parser.read() == OK:
		var kind: int = parser.get_node_type()
		if kind == XMLParser.NODE_ELEMENT:
			var name: String = parser.get_node_name()
			var empty: bool = parser.is_empty()
			if depth == 0:
				if name != "reputation":
					return {}
				for key: String in ["score", "max", "status", "tip", "notice"]:
					root[key] = _attr(parser, key)
			elif depth == 1:
				match name:
					"threshold":
						raw_thresholds.append(_int(_attr(parser, "value")))
					"reward":
						var item: int = _int(_attr(parser, "item"))
						if item > 0 and (out.rewards as Array).size() < 10:
							(out.rewards as Array).append_array([item, maxi(1, _int(_attr(parser, "count")))])
					"rule":
						in_rule = not empty
						rule = ""
			if not empty:
				depth += 1
		elif kind == XMLParser.NODE_TEXT or kind == XMLParser.NODE_CDATA:
			if in_rule and depth == 2:
				rule += parser.get_node_data()
		elif kind == XMLParser.NODE_ELEMENT_END:
			depth -= 1
			if in_rule and depth == 1:
				in_rule = false
				if not rule.is_empty() and (out.rules as Array).size() < 6:
					(out.rules as Array).append(rule.xml_unescape() if rule.contains("&") else rule)
	if root.is_empty():
		return {}
	var top_value: int = _int(str(root.max))
	if top_value <= 0:
		top_value = 100
	for value: int in raw_thresholds:
		if value > 0 and value < top_value and (out.thresholds as Array).size() < 4:
			(out.thresholds as Array).append(value)
	out["max"] = top_value
	out["score"] = clampi(_int(str(root.score)), 0, top_value)
	out["status"] = str(root.status)
	out["tip"] = str(root.tip)
	out["notice"] = str(root.notice)
	return out

static func _attr(parser: XMLParser, name: String) -> String:
	var value: String = parser.get_named_attribute_value_safe(name)
	return value.xml_unescape() if value.contains("&") else value


static func _int(text: String) -> int:
	var t: String = text.strip_edges()
	return int(t) if t.is_valid_int() else (int(t.to_float()) if t.is_valid_float() else 0)


func level() -> int:
	if thresholds.is_empty():
		return 2
	var count: int = 0
	for value: Variant in thresholds:
		if score >= int(value):
			count += 1
	return int(count * 2 / thresholds.size())

func level_color() -> Color:
	return LEVEL_COLORS[clampi(level(), 0, 2)]

func button_label() -> String:
	return str(LABELS.get(status, SOON))

func can_claim() -> bool:
	return status == "claimable"

func button_tip() -> String:
	if not tip.is_empty():
		return tip
	return SOON_TIP if status == "soon" else ""


func cells() -> Array:
	var count: int = mini(5, rewards.size() / 2)
	var gap: float = 6.0 if count >= 5 else 14.0
	var left: float = floorf((W - count * CELL_W - (count - 1) * gap) / 2.0)
	var out: Array = []
	for i in range(count):
		out.append([int(rewards[i * 2]), int(rewards[i * 2 + 1]), Vector2(left + i * (CELL_W + gap), 290)])
	return out



func _paint() -> void :
	var at: Vector2 = _window(W, H, "close", DIM)
	if _title != null:
		draw_texture_rect(_title, Rect2((at + Vector2(roundf((W - _title.get_width()) / 2.0), 20)) * _f, Vector2(_title.get_size()) * _f), false)
	var color: Color = level_color()
	_draw_ring(at + Vector2(40, 56), 52.0, float(score) / float(top) if top > 0 else 0.0, color)
	_label([[str(score), Color.WHITE]], 30.0, at + Vector2(40, 78), "c", 104.0)
	_label([["Uy Tín", Color("cfeaff")]], 12.0, at + Vector2(40, 116), "c", 104.0)
	_label([["Điểm Uy Tín hiện tại: ", Color.WHITE], [str(score), YELLOW], ["/%d" % top, Color.WHITE]], 14.0, at + Vector2(166, 60))
	_draw_bar(at + Vector2(170, 94), 230.0, 14.0)
	for value: Variant in [0] + thresholds + [top]:
		_label([[str(int(value)), Color.WHITE]], 11.0, at + Vector2(170.0 + floorf(230.0 * int(value) / top) - 15.0, 111), "c", 30.0)
	_label([["Mức uy tín: ", Color.WHITE], [str(LEVEL_NAMES[clampi(level(), 0, 2)]), color]], 13.0, at + Vector2(166, 134))
	var panel: Rect2 = Rect2((at + Vector2(24, 166)) * _f, Vector2(W - 48.0, 100) * _f)
	_round(panel, Color(SHADOW, 0.4), 14.0, Color(1, 1, 1, 0.35), 2.0)
	_label([["Quy tắc", YELLOW]], 12.0, at + Vector2(34, 170))
	_draw_rules(at + Vector2(34, 189), W - 68.0)
	_label([["Phần thưởng hằng tuần (Uy Tín đạt ", Color.WHITE], [str(top), YELLOW], [")", Color.WHITE]], 12.0, at + Vector2(0, 272), "c", W)
	var items: Dictionary = pack.bag.get("items", {}) if pack != null else {}
	for cell: Array in cells():
		_draw_cell(at + (cell[2] as Vector2), int(cell[0]), int(cell[1]), items)
	_draw_claim(at + Vector2(floorf((W - 120.0) / 2.0), H - 17.0 - 35.0))



func _label(parts: Array, px: float, at: Vector2, align: String = "l", wide: float = 0.0) -> void :
	var total: float = 0.0
	for part: Array in parts:
		total += _measure_flash(str(part[0]), ARIAL_BOLD, px)
	var x: float = at.x if align == "l" else at.x + (wide - total) / 2.0
	for part: Array in parts:
		var text: String = str(part[0])
		var span: float = _measure_flash(text, ARIAL_BOLD, px)
		_fwords(text, ARIAL_BOLD, px, part[1], "l", Vector2(x, at.y), span + 2.0, 1.5, 0.0, false, Color(SHADOW, 0.9))
		x += span

func _measure_flash(text: String, font: Font, px: float) -> float:
	return _face(font).get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f


func _draw_rules(at: Vector2, wide: float) -> void :
	var y: float = at.y
	var digits: RegEx = RegEx.create_from_string("\\d+|\\D+")
	for rule: Variant in rules:
		var runs: Array = []
		for found: RegExMatch in digits.search_all("• " + str(rule)):
			var piece: String = found.get_string()
			if piece.is_valid_int():
				runs.append([piece, true])
			else:
				for word: String in piece.split(" "):
					runs.append([word, false])
					runs.append([" ", false])
				runs.pop_back()
		var x: float = at.x
		for run: Array in runs:
			var font: Font = ARIAL_BOLD if run[1] else ARIAL
			var span: float = _measure_flash(str(run[0]), font, 12.0)
			if str(run[0]) != " " and x + span > at.x + wide and x > at.x:
				x = at.x
				y += RULE_LINE
			if str(run[0]) == " " and x == at.x:
				continue
			if str(run[0]) != " ":
				_fwords(str(run[0]), font, 12.0, YELLOW if run[1] else Color.WHITE, "l", Vector2(x, y), span + 2.0, 1.2, 0.0, false, Color(SHADOW, 0.9))
			x += span
		y += RULE_LINE


func _draw_ring(at: Vector2, r: float, ratio: float, color: Color) -> void :
	var centre: Vector2 = (at + Vector2(r, r)) * _f
	ratio = clampf(ratio, 0.0, 1.0)
	for i in range(7, 0, -1):
		draw_circle(centre, (r + i) * _f, Color(color, 0.75 * 0.22 * (1.0 - i / 8.0)))
	var steps: int = 26
	for i in range(steps):
		var k: float = float(i) / float(steps - 1)
		draw_circle(centre, r * (1.0 - float(i) / steps) * _f, Color("0b3f78").lerp(Color("2f9ae0"), k))
	draw_arc(centre, (r - 1.5) * _f, 0.0, TAU, 96, Color(1, 1, 1, 0.95), 3.0 * _f, true)
	var track: float = r - 10.0
	draw_arc(centre, track * _f, 0.0, TAU, 96, Color(SHADOW, 0.55), 7.0 * _f, true)
	if ratio <= 0.0:
		return
	var segments: int = maxi(2, int(72.0 * ratio))
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(segments + 1):
		var angle: float = - PI / 2.0 + TAU * ratio * i / segments
		points.append(centre + Vector2(cos(angle), sin(angle)) * track * _f)
	draw_polyline(points, color, 7.0 * _f, true)
	for end: Vector2 in [points[0], points[points.size() - 1]]:
		draw_circle(end, 3.5 * _f, color)



func _draw_bar(at: Vector2, wide: float, high: float) -> void :
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(SHADOW, 0.7), high, Color(1, 1, 1, 0.9), 2.0)
	var ratio: float = clampf(float(score) / float(top), 0.0, 1.0) if top > 0 else 0.0
	if ratio > 0.0:
		var fill: Rect2 = Rect2((at + Vector2(2, 2)) * _f, Vector2(maxf(high - 4.0, (wide - 4.0) * ratio), high - 4.0) * _f)
		_grad_round(fill, (high - 4.0) / 2.0 * _f, Color("ffe45c"), Color("ff9f1f"), at.x * _f, (at.x + wide) * _f)
	for value: Variant in thresholds:
		var x: float = floorf(wide * int(value) / top)
		draw_rect(Rect2((at + Vector2(x - 1.0, -3.0)) * _f, Vector2(2, high + 6.0) * _f), Color(1, 1, 1, 0.95))


func _grad_round(rect: Rect2, radius: float, a: Color, b: Color, x0: float, x1: float) -> void :
	radius = minf(radius, minf(rect.size.x, rect.size.y) / 2.0)
	var points: PackedVector2Array = PackedVector2Array()
	var corners: Array = [[rect.end - Vector2(radius, radius), 0.0], [Vector2(rect.position.x + radius, rect.end.y - radius), PI / 2.0], 
		[rect.position + Vector2(radius, radius), PI], [Vector2(rect.end.x - radius, rect.position.y + radius), PI * 1.5]]
	for corner: Array in corners:
		for i in range(7):
			var angle: float = float(corner[1]) + PI / 2.0 * i / 6.0
			points.append((corner[0] as Vector2) + Vector2(cos(angle), sin(angle)) * radius)
	var colors: PackedColorArray = PackedColorArray()
	for point: Vector2 in points:
		colors.append(a.lerp(b, clampf((point.x - x0) / maxf(1.0, x1 - x0), 0.0, 1.0)))
	draw_polygon(points, colors)



func _draw_cell(at: Vector2, item: int, count: int, items: Dictionary) -> void :
	var spot: Dictionary = Award.TILE
	_fblit("la_tile", at + Vector2(float(spot["bg"][0]), float(spot["bg"][1])))
	var found: Variant = items.get(str(item))
	var more: Array = found if found is Array else []
	var quality: int = int(more[3]) if more.size() > 3 else 0
	if quality >= 2 and quality <= 5:
		_fblit("la_q%d" % quality, at + Vector2(float(spot["quality"][0]), float(spot["quality"][1])))
	var box: Array = spot["item"]
	if more.size() > 2 and not str(more[2]).is_empty() and pack != null:
		var picture: Texture2D = pack.picture("l/it/%s.webp" % str(more[2]))
		if picture != null and picture.get_width() > 4:
			var k: float = minf(float(box[2]) / picture.get_width(), float(box[3]) / picture.get_height())
			draw_texture_rect(picture, Rect2((at + Vector2(float(box[0]), float(box[1]))) * _f, Vector2(picture.get_size()) * k * _f), false)
	var label: Array = spot["lblNum"]
	_fwords(str(count), ARIAL_BOLD, 12.0, Color.WHITE, "c", at + Vector2(float(label[0]), float(label[1])), float(label[2]))


func _draw_claim(at: Vector2) -> void :
	var on: bool = can_claim()
	var tint: Color = _glow("claim") if on else Color.WHITE
	var rect: Rect2 = _fblit("public_button_window_green" if on else "public_button_window_gray", at, 0.0, 0.0, tint)
	_fwords(button_label(), ARIAL_BOLD, 14.0, Color.WHITE if on else Color("eeeeee"), "c", at, 120.0, 0.0, 35.0)
	_hit("claim" if on else "claim:off", rect, false)




func claim() -> void :
	if status != "claimable":
		return
	status = "claiming"
	tip = ""
	queue_redraw()
	_load("/reputation-claim.xml?t=")

func _activate(id: String) -> void :
	match id:
		"close":
			close()
		"claim":
			claim()

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
