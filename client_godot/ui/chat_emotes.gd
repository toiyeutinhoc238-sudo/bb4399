extends Node
const AppSession = preload("res://net/app_session.gd")










const Gif = preload("chat_emote_gif.gd")
const BASIC: String = "basic_v1"
const ID: String = "^[a-z0-9_]{1,40}$"
const CODE: String = "^[1-9][0-9]{2,4}$"
const ART: String = "^f[a-f0-9]{32}$"
const ART_PACK: String = "frameasset"
const PACKS_MAX: int = 10
const ITEMS_MAX: int = 200
const LOADS: int = 3
const KEEP: int = 48
const BUDGET_USEC: int = 3000
const AGAIN: float = 60.0

var client
var rev: int = 0
var loaded: bool = false
var revision: String = ""
var asset_rev: String = "0"
var packs: Array = []

var pack_of: Dictionary = {}
var labels: Dictionary = {}
var formats: Dictionary = {}
var codes: Dictionary = {}
var code_of: Dictionary = {}
var owned: Array = []

var catalog_get: Callable
var image_get: Callable

var _http: HTTPRequest
var _busy: bool = false
var _asked: float = -1000.0
var _images: Dictionary = {}
var _queue: Array = []
var _loading: Dictionary = {}
var _pool: Array = []
var _work: Array = []
var _id: RegEx = RegEx.create_from_string(ID)
var _code: RegEx = RegEx.create_from_string(CODE)
var _art: RegEx = RegEx.create_from_string(ART)
var _marker: RegEx = RegEx.create_from_string("\\[emote:([^:\\]\\s]+):([^\\]\\s]+)\\]")
var _frame_marker: RegEx = RegEx.create_from_string("\\[chatframe:[^\\]]*\\]")
var _tag: RegEx = RegEx.create_from_string("<[^>]*>")
var _glued: RegEx = RegEx.create_from_string("[0-9A-Za-z:/.]")

func _ready() -> void :
	_http = _request()
	_http.request_completed.connect(_on_catalog)
	set_process(false)

func _request() -> HTTPRequest:
	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 15.0
	http.download_chunk_size = 1 << 18
	if OS.has_feature("web"):
		http.accept_gzip = false
	add_child(http)
	return http





func refresh(force: bool = false) -> void :
	if _busy or client == null:
		return
	var origin: String = str(client.config.origin)
	if origin.is_empty() or (_offline() and not catalog_get.is_valid()):
		return
	var now: float = Time.get_ticks_msec() / 1000.0
	if not force and loaded and now - _asked < AGAIN:
		return
	_asked = now
	_busy = true
	var url: String = origin + "/chat-emotes.xml?t=%d" % Time.get_ticks_msec()
	var asked: int = catalog_get.call(url) if catalog_get.is_valid() else _http.request(url, AppSession.headers(url))
	if asked != OK:
		_busy = false


func _offline() -> bool:
	return client == null or client.config.get("local_test_only") == true

func _on_catalog(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_busy = false
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		parse(body.get_string_from_utf8())

func _attr(parser: XMLParser, name: String) -> String:
	var value: String = parser.get_named_attribute_value_safe(name)
	return value.xml_unescape() if value.contains("&") else value



func parse(text: String) -> bool:
	var parser: XMLParser = XMLParser.new()
	if text.is_empty() or parser.open_buffer(text.to_utf8_buffer()) != OK:
		return false
	var got: String = ""
	var list: Array = []
	var by_id: Dictionary = {}
	var names: Dictionary = {}
	var kinds: Dictionary = {}
	var code_map: Dictionary = {}
	var code_back: Dictionary = {}
	var mine: Array = []
	var current: Dictionary = {}
	var seen_root: bool = false
	while parser.read() == OK:
		var type: int = parser.get_node_type()
		if type == XMLParser.NODE_ELEMENT_END:
			if parser.get_node_name() == "pack":
				current = {}
			continue
		if type != XMLParser.NODE_ELEMENT:
			continue
		match parser.get_node_name():
			"emotes":
				seen_root = true
				got = _attr(parser, "revision")
			"pack":
				current = {}
				var id: String = _attr(parser, "id")
				if _id.search(id) == null or by_id.has(id) or mine.size() >= PACKS_MAX:
					continue
				var colors: PackedStringArray = _attr(parser, "frame").split(":")
				var frame: Array = []
				if colors.size() == 3 and colors[0].length() == 6 and colors[1].length() == 6 and colors[2].length() == 6\
				and colors[0].is_valid_hex_number() and colors[1].is_valid_hex_number() and colors[2].is_valid_hex_number():
					frame = [Color(colors[0]), Color(colors[1]), Color(colors[2])]
				var art: Array = []
				var slice: String = _attr(parser, "frameSlice")
				if _art.search(_attr(parser, "frameImage")) != null:
					art = [_attr(parser, "frameImage"), slice.to_float() if slice.is_valid_float() else 0.0]
				current = {"id": id, "label": _attr(parser, "label"), "owned": id == BASIC or _attr(parser, "owned") == "1", 
					"kind": _attr(parser, "kind"), "card": _attr(parser, "cardItemId").to_int(), "frame": frame, "art": art, "items": []}
				list.append(current)
				by_id[id] = current
				if current["owned"]:
					mine.append(id)
				if parser.is_empty():
					current = {}
			"item":
				if current.is_empty():
					continue
				var item: String = _attr(parser, "id")
				var items: Array = current["items"]
				if _id.search(item) == null or items.has(item) or items.size() >= ITEMS_MAX:
					continue
				items.append(item)
				var key: String = "%s/%s" % [current["id"], item]
				kinds[key] = "gif" if _attr(parser, "format") == "swf" else "png"
				names[key] = _attr(parser, "label")
				var number: String = _attr(parser, "code")
				if _code.search(number) != null and not code_map.has(number):
					code_map[number] = "%s:%s" % [current["id"], item]
					code_back[key] = number
	if not seen_root or mine.is_empty():
		return false
	if loaded and got == revision:
		return true
	revision = got
	asset_rev = got.split(":")[0]
	packs = list
	pack_of = by_id
	labels = names
	formats = kinds
	codes = code_map
	code_of = code_back
	owned = mine
	loaded = true
	rev += 1

	for key: String in _images.keys():
		if (_images[key] as Dictionary)["state"] in ["ok", "gif", "bad", "wait"]:
			_images.erase(key)
	_work.clear()
	_queue.clear()
	return true


func known(pack: String, item: String) -> bool:
	pack = BASIC if pack == "robot" else pack
	return pack_of.has(pack) and ((pack_of[pack] as Dictionary)["items"] as Array).has(item)

func owns(pack: String) -> bool:
	return owned.has(BASIC if pack == "robot" else pack)


func usable(pack: String, item: String) -> bool:
	pack = BASIC if pack == "robot" else pack
	return owns(pack) and known(pack, item) and str((pack_of[pack] as Dictionary)["kind"]) != "frame"


func picker_packs() -> Array:
	var out: Array = []
	for id: String in owned:
		var pack: Dictionary = pack_of[id]
		if str(pack["kind"]) != "frame":
			out.append(pack)
	return out


func frame_packs() -> Array:
	var out: Array = []
	for id: String in owned:
		if str((pack_of[id] as Dictionary)["kind"]) == "frame":
			out.append(pack_of[id])
	return out


func frame_art(id: String) -> Array:
	return (pack_of.get(id, {}) as Dictionary).get("art", [])




static func nine(size: Vector2, slice: float, w: float, h: float) -> Array:
	if not (slice >= 1.0 and slice <= 64.0) or size.x > 256.0 or size.y > 256.0 or slice * 2.0 >= size.x or slice * 2.0 >= size.y:
		return []
	var dx: float = minf(minf(slice, 12.0), w / 2.0)
	var dy: float = minf(minf(slice, 12.0), h / 2.0)
	var sx: Array = [0.0, slice, size.x - slice, size.x]
	var sy: Array = [0.0, slice, size.y - slice, size.y]
	var tx: Array = [0.0, dx, w - dx, w]
	var ty: Array = [0.0, dy, h - dy, h]
	var out: Array = []
	for row in range(3):
		for col in range(3):
			var dst: Rect2 = Rect2(tx[col], ty[row], tx[col + 1] - tx[col], ty[row + 1] - ty[row])
			var src: Rect2 = Rect2(sx[col], sy[row], sx[col + 1] - sx[col], sy[row + 1] - sy[row])
			if dst.size.x > 0.0 and dst.size.y > 0.0 and src.size.x > 0.0 and src.size.y > 0.0:
				out.append([dst, src])
	return out

func label(pack: String, item: String) -> String:
	var name: String = str(labels.get("%s/%s" % [pack, item], ""))
	return name if not name.is_empty() else item

func code(pack: String, item: String) -> String:
	return str(code_of.get("%s/%s" % [pack, item], ""))





func find_codes(text: String) -> Array:
	var found: Array = []
	if not loaded:
		return found
	var chained: int = -1
	var start: int = text.find("/")
	while start >= 0:
		var end: int = start + 1
		while end < text.length() and text.unicode_at(end) >= 48 and text.unicode_at(end) <= 57:
			end += 1
		var emote: String = str(codes.get(text.substr(start + 1, end - start - 1), ""))
		var free: bool = start == 0 or start == chained or _glued.search(text.substr(start - 1, 1)) == null
		if end > start + 1 and not emote.is_empty() and free and owned.has(emote.get_slice(":", 0)):
			found.append([start, end, emote])
			chained = end
		start = text.find("/", start + 1)
	return found


func expand_codes(text: String) -> String:
	var out: String = ""
	var cursor: int = 0
	for hit: Array in find_codes(text):
		out += text.substr(cursor, int(hit[0]) - cursor) + "[emote:%s]" % str(hit[2])
		cursor = int(hit[1])
	return out + text.substr(cursor)


func expand(text: String, tokens: Dictionary) -> String:
	var out: String = ""
	var cursor: int = 0
	var start: int = text.find("[")
	while start >= 0:
		var end: int = text.find("]", start)
		if end < 0:
			break
		var key: String = text.substr(start, end - start + 1)
		out += text.substr(cursor, start - cursor) + str(tokens.get(key, key))
		cursor = end + 1
		start = text.find("[", cursor)
	return expand_codes(out + text.substr(cursor))


func refusal(text: String) -> String:
	var hits: Array = _marker.search_all(text)
	if hits.is_empty():
		return ""
	if not loaded:
		refresh()
		return "Danh sách biểu cảm chưa tải xong, thử lại sau."
	for hit: RegExMatch in hits:
		var pack: String = BASIC if hit.get_string(1) == "robot" else hit.get_string(1)
		var item: String = hit.get_string(2)
		if not known(pack, item) or str((pack_of[pack] as Dictionary)["kind"]) == "frame":
			return "Emote không còn tồn tại."
		if not owns(pack):
			var box: Dictionary = pack_of[pack]
			if int(box["card"]) > 0:
				return "Cần dùng thẻ mở bộ emote %s." % str(box["label"])
			return "Bộ %s chưa mở cho tài khoản này." % str(box["label"])
	return ""






func pieces(raw: String) -> Array:
	var text: String = _frame_marker.sub(raw, "", true)
	var out: Array = []
	var cursor: int = 0
	var start: int = text.find("[emote:")
	while start >= 0:
		var end: int = text.find("]", start)
		if end < 0:
			break
		var parts: PackedStringArray = text.substr(start + 7, end - start - 7).split(":")
		var inside: bool = start > 0 and text.rfind("<", start - 1) > text.rfind(">", start - 1)
		_add_text(out, text.substr(cursor, start - cursor))
		if not inside and parts.size() == 2 and loaded and known(parts[0], parts[1]):
			out.append(["emote", "%s:%s" % [BASIC if parts[0] == "robot" else parts[0], parts[1]]])
		elif inside:
			_add_text(out, text.substr(start, end - start + 1))
		else:
			_add_text(out, "(^^)")
		cursor = end + 1
		start = text.find("[emote:", cursor)
	_add_text(out, text.substr(cursor))

	var merged: Array = []
	for piece: Array in out:
		if piece[0] == "text" and not merged.is_empty() and merged[-1][0] == "text":
			merged[-1][1] = str(merged[-1][1]) + str(piece[1])
		else:
			merged.append(piece.duplicate())
	for piece: Array in merged:
		if piece[0] == "text":
			piece[1] = _tag.sub(str(piece[1]), "", true).replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", "\"").replace("&amp;", "&")
	if not merged.is_empty() and merged[0][0] == "text":
		merged[0][1] = str(merged[0][1]).lstrip(" \t\n\r")
	if not merged.is_empty() and merged[-1][0] == "text":
		merged[-1][1] = str(merged[-1][1]).rstrip(" \t\n\r")
	return merged.filter( func(piece: Array) -> bool: return piece[0] != "text" or not str(piece[1]).is_empty())

func _add_text(out: Array, text: String) -> void :
	if not text.is_empty():
		out.append(["text", text])


func has_emote(raw: String) -> bool:
	return loaded and raw.contains("[emote:")



func image_url(key: String) -> String:
	if client == null or str(client.config.origin).is_empty():
		return ""
	var pack: String = key.get_slice(":", 0)
	var item: String = key.get_slice(":", 1)
	if pack == ART_PACK:

		return "%s/rez/zh_CN/icon/emote/%s/%s.png" % [str(client.config.origin), ART_PACK, item] if _art.search(item) != null else ""
	if not known(pack, item):
		return ""
	var ext: String = str(formats.get("%s/%s" % [pack, item], "png"))
	return "%s/rez/zh_CN/icon/emote/%s/%s.%s?rev=%s" % [str(client.config.origin), pack, item, ext, asset_rev.uri_encode()]


func texture(key: String) -> Texture2D:
	var now: float = Time.get_ticks_msec() / 1000.0
	var entry: Variant = _images.get(key)
	if entry == null:
		if not loaded:
			return null
		_evict(now)
		_images[key] = {"state": "wait", "tex": null, "gif": null, "used": now}
		_queue.append(key)
		_pump()
		return null
	entry["used"] = now
	match str(entry["state"]):
		"ok":
			return entry["tex"]
		"gif":
			return (entry["gif"] as Gif).frame_at(Time.get_ticks_msec())
	return null


func state(key: String) -> String:
	return str((_images[key] as Dictionary)["state"]) if _images.has(key) else ""

func _evict(now: float) -> void :
	if _images.size() < KEEP:
		return
	var oldest: String = ""
	var at: float = now - 2.0
	for key: String in _images:
		var entry: Dictionary = _images[key]
		if str(entry["state"]) != "load" and float(entry["used"]) < at:
			at = float(entry["used"])
			oldest = key
	if not oldest.is_empty():
		_images.erase(oldest)
		_work.erase(oldest)
		_queue.erase(oldest)

func _pump() -> void :
	while not _queue.is_empty() and _loading.size() < LOADS:
		var key: String = _queue.pop_front()
		var entry: Variant = _images.get(key)
		if entry == null or str(entry["state"]) != "wait":
			continue
		var url: String = image_url(key)
		if url.is_empty():
			entry["state"] = "bad"
			continue
		if not image_get.is_valid() and _offline():
			entry["state"] = "bad"
			continue
		entry["state"] = "load"
		if image_get.is_valid():
			_loading[key] = true
			if image_get.call(key, url) != OK:
				_loading.erase(key)
				entry["state"] = "bad"
			continue
		var http: HTTPRequest = _take()
		_loading[key] = http
		var done: Callable = _on_image.bind(key, http)
		http.request_completed.connect(done, CONNECT_ONE_SHOT)
		http.cancel_request()
		http.set_meta("ra1c_busy", true)
		if http.request(url, PackedStringArray(["X-BB-Client: h5"]) + AppSession.headers(url)) != OK:
			http.request_completed.disconnect(done)
			_loading.erase(key)
			_give(http)
			entry["state"] = "bad"


func _take() -> HTTPRequest:
	while not _pool.is_empty():
		var http: Variant = _pool.pop_back()
		if http is HTTPRequest and is_instance_valid(http) and not (http as HTTPRequest).has_meta("ra1c_busy") and not _pool.has(http):
			return http
	return _request()

func _give(http: HTTPRequest) -> void :
	http.remove_meta("ra1c_busy")
	if not _pool.has(http):
		_pool.append(http)

func _on_image(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray, key: String, http: HTTPRequest) -> void :
	_give(http)
	image_done(key, body if result == HTTPRequest.RESULT_SUCCESS and code == 200 else PackedByteArray())


func image_done(key: String, body: PackedByteArray) -> void :
	_loading.erase(key)
	var entry: Variant = _images.get(key)
	if entry != null and str(entry["state"]) == "load":
		entry["state"] = "bad"
		if body.size() >= 6 and body.slice(0, 3).get_string_from_ascii() == "GIF":
			var gif: Gif = Gif.new()
			if gif.open(body):
				entry["gif"] = gif
				entry["state"] = "gif"
				_work.append(key)
				set_process(true)
		elif body.size() >= 8:
			var image: Image = Image.new()
			if image.load_png_from_buffer(body) == OK and image.get_width() > 0:
				entry["tex"] = ImageTexture.create_from_image(image)
				entry["state"] = "ok"
	_pump()


func _process(_delta: float) -> void :
	decode(BUDGET_USEC)


func decode(budget: int) -> void :
	var until: int = Time.get_ticks_usec() + budget
	while not _work.is_empty() and Time.get_ticks_usec() < until:
		var pick: int = 0
		for i in range(_work.size()):
			var entry: Variant = _images.get(_work[i])
			if entry != null and (entry["gif"] as Gif).frames.is_empty():
				pick = i
				break
		var key: String = _work[pick]
		var entry: Variant = _images.get(key)
		if entry == null or entry["gif"] == null:
			_work.remove_at(pick)
			continue
		var gif: Gif = entry["gif"]
		if not gif.step():
			_work.remove_at(pick)
			if gif.failed:
				entry["state"] = "bad"
	if _work.is_empty():
		set_process(false)
