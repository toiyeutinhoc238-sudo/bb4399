extends RefCounted
const AppSession = preload("res://net/app_session.gd")








const PATH: String = "/api/name-styles.xml"
const AGAIN: float = 60.0
const RIM: Color = Color(0, 0, 0, 0.8)

static var by_id: Dictionary = {}
static var by_name: Dictionary = {}
static var rev: int = 0
static var asks: int = 0
static var drawn: int = 0
static var fetch: Callable
static var _state: int = 0
static var _failed: float = -1000.0
static var _http: HTTPRequest = null


static func reset() -> void :
	by_id.clear()
	by_name.clear()
	rev = 0
	asks = 0
	drawn = 0
	fetch = Callable()
	_state = 0
	_failed = -1000.0


static func colors_of(client: Object, id: int, name: String) -> PackedColorArray:
	_want(client)
	if id > 0:
		return by_id.get(str(id), PackedColorArray())
	return by_name.get(name, PackedColorArray())

static func loaded() -> bool:
	return _state == 2


static func _want(client: Object) -> void :
	if _state == 1 or _state == 2 or client == null:
		return
	if _state == 3 and Time.get_ticks_msec() / 1000.0 - _failed < AGAIN:
		return
	var config: Variant = client.get("config")
	if config == null:
		return
	var origin: String = str(config.get("origin"))
	if (origin.is_empty() or config.get("local_test_only") == true) and not fetch.is_valid():
		return
	var url: String = origin + PATH + "?t=%d" % int(Time.get_unix_time_from_system() * 1000.0)
	if fetch.is_valid():
		_state = 1
		asks += 1
		if int(fetch.call(url)) != OK:
			_fail()
		return
	var host: Node = client as Node
	if host == null or not host.is_inside_tree():
		return
	_state = 1
	asks += 1
	if _http == null or not is_instance_valid(_http):
		_http = HTTPRequest.new()
		_http.timeout = 15.0
		if OS.has_feature("web"):
			_http.accept_gzip = false
		_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
			done(result, code, body))
		_http.ready.connect( func() -> void :
			if _http.request(url, AppSession.headers(url)) != OK:
				_fail(), CONNECT_ONE_SHOT)
		host.add_child.call_deferred(_http)
	elif _http.request(url, AppSession.headers(url)) != OK:
		_fail()

static func _fail() -> void :
	_state = 3
	_failed = Time.get_ticks_msec() / 1000.0


static func done(result: int, code: int, body: PackedByteArray) -> void :
	if result == HTTPRequest.RESULT_SUCCESS and code == 200 and parse(body.get_string_from_utf8()):
		_state = 2
	else:
		_fail()



static func parse(text: String) -> bool:
	var parser: XMLParser = XMLParser.new()
	if text.strip_edges().is_empty() or parser.open_buffer(text.to_utf8_buffer()) != OK:
		return false
	var root: bool = false
	var closed: bool = false
	var ids: Dictionary = {}
	var names: Dictionary = {}
	while true:
		var step: int = parser.read()
		if step == ERR_FILE_EOF:
			break
		if step != OK:
			return false
		var kind: int = parser.get_node_type()
		if kind == XMLParser.NODE_ELEMENT_END and root and parser.get_node_name() == "nameStyles":
			closed = true
		if kind != XMLParser.NODE_ELEMENT:
			continue
		var tag: String = parser.get_node_name()
		if not root:
			if tag != "nameStyles":
				return false
			root = true
			closed = parser.is_empty()
			continue
		if tag != "style":
			continue
		var colors: PackedColorArray = PackedColorArray()
		for value: String in _attr(parser, "colors").split(","):
			if value.length() == 7 and value.begins_with("#") and value.substr(1).is_valid_hex_number():
				colors.append(Color(value))
		if colors.size() > 0 and colors.size() <= 4:
			ids[_attr(parser, "id")] = colors
			names[_attr(parser, "name")] = colors
	if not root or not closed:
		return false
	by_id.merge(ids, true)
	by_name.merge(names, true)
	rev += 1
	return true

static func _attr(parser: XMLParser, name: String) -> String:
	var value: String = parser.get_named_attribute_value_safe(name)
	return value.xml_unescape() if value.contains("&") else value



static func chat_colors(client: Object, line: Dictionary, block: String) -> PackedColorArray:
	var name: String = str(line.get("name", ""))
	if not line.has("who_oid") or name.is_empty() or not block.ends_with(name):
		return PackedColorArray()
	var colors: PackedColorArray = colors_of(client, int(line.get("who_oid", 0)), name)
	if colors.is_empty():
		return colors
	var plain: Color = line.get("name_color", Color.WHITE)
	var out: PackedColorArray = PackedColorArray()
	for i in range(block.length() - name.length()):
		out.append(plain)
	out.append_array(tints(colors, name.length()))
	return out


static func tints(colors: PackedColorArray, count: int) -> PackedColorArray:
	var out: PackedColorArray = PackedColorArray()
	if colors.is_empty():
		return out
	var last: int = colors.size() - 1
	for j in range(count):
		var position: float = 0.0 if count <= 1 else float(j * last) / float(count - 1)
		var index: int = mini(last, floori(position))
		var fraction: float = position - index
		var a: Color = colors[index]
		var b: Color = colors[mini(index + 1, last)]
		out.append(Color8(roundi(a.r8 * (1.0 - fraction) + b.r8 * fraction), roundi(a.g8 * (1.0 - fraction) + b.g8 * fraction), 
			roundi(a.b8 * (1.0 - fraction) + b.b8 * fraction)))
	return out




static func draw_tinted(canvas: CanvasItem, font: Font, font_size: int, origin: Vector2, text: String, colors: PackedColorArray, 
		outline: int = 0, rim: Color = RIM, align: String = "l", width: float = -1.0, per_char: bool = false) -> float:
	if text.is_empty() or colors.is_empty():
		return 0.0
	var line: TextLine = TextLine.new()
	line.add_string(text, font, font_size)
	var total: float = line.get_size().x
	var x0: float = origin.x
	if width > 0.0 and total <= width:
		if align == "c":
			x0 += floorf((width - total) / 2.0)
		elif align == "r":
			x0 += width - total
	var spans: Array = []
	var pen: float = 0.0
	for glyph: Dictionary in TextServerManager.get_primary_interface().shaped_text_get_glyphs(line.get_rid()):
		var start: int = int(glyph.get("start", 0))
		if spans.is_empty() or start != int(spans[-1][0]):
			spans.append([start, int(glyph.get("end", start + 1)), pen])
		pen += float(glyph.get("advance", 0.0)) * maxi(1, int(glyph.get("repeat", 1)))
	if spans.is_empty():
		for i in range(text.length()):
			spans.append([i, i + 1, font.get_string_size(text.substr(0, i), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x])
	drawn += 1
	if outline > 0:
		canvas.draw_string_outline(font, Vector2(x0, origin.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, outline, rim)
	var tint: PackedColorArray = colors if per_char else tints(colors, text.length())
	for span: Array in spans:
		var ink: Color = tint[clampi(int(span[0]), 0, tint.size() - 1)]
		canvas.draw_string(font, Vector2(x0 + float(span[2]), origin.y), text.substr(int(span[0]), int(span[1]) - int(span[0])), 
			HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, ink)
	return total



static func paint(screen: Control, text: String, font: Font, px: float, align: String, at: Vector2, wide: float, edge: float = 0.0, 
		high: float = 0.0, shrink: bool = true, id: int = 0) -> bool:
	if text.is_empty() or screen == null:
		return false
	var colors: PackedColorArray = colors_of(screen.get("client"), id, text)
	if colors.is_empty():
		return false
	place(screen, text, font, px, align, at, wide, edge, high, shrink, colors)
	return true


static func place(screen: Control, text: String, font: Font, px: float, align: String, at: Vector2, wide: float, edge: float, high: float, 
		shrink: bool, colors: PackedColorArray, per_char: bool = false, rim: Color = RIM) -> float:
	if text.is_empty() or colors.is_empty():
		return 0.0
	var f: float = float(screen.get("_f"))
	var u: float = float(screen.get("_u"))
	font = screen.call("_face", font)
	var shown: float = px
	if shrink:
		while shown > 8.0 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(shown * f))).x > wide * f:
			shown -= 1.0
	var middle: float = at.y + (high / 2.0 if high > 0.0 else 2.0 + px * 0.55)
	var x: float = at.x if align == "l" else (at.x + wide / 2.0 if align == "c" else at.x + wide)
	var font_size: int = maxi(6, roundi(shown * 2.0 * u))
	var origin: Vector2 = Vector2(x, middle) * f
	var width: float = wide * f
	if align == "c":
		origin.x -= width / 2.0
	elif align == "r":
		origin.x -= width
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	var used: float = draw_tinted(screen, font, font_size, origin, text, colors, maxi(1, roundi(edge * 2.0 * u)) if edge > 0.0 else 0, rim, 
		align, width, per_char)
	return minf(width, used) / f
