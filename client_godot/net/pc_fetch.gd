extends RefCounted















const PcVoice = preload("res://net/pc_voice.gd")
const AndroidVoice = preload("res://net/android_voice.gd")
const TEA: String = "/api/voice/tea?op="
const POLL_EXPR: String = "window.__bbx?window.__bbx.poll():''"
const WAIT_MS: int = 30000
const POLL_MS: int = 100
const FILE_MAX: int = 41943040
const RAW_MAX: int = 2621440
const SIDE: int = 1280
const METHODS: PackedStringArray = ["GET", "HEAD", "POST", "PUT", "DELETE", "OPTIONS", "TRACE", "CONNECT", "PATCH"]
const FILTERS: PackedStringArray = ["*.jpg, *.jpeg, *.png, *.webp, *.gif, *.bmp ; Ảnh"]
const JS: String = "(function () {\n\tif (window.__bbx) return;\n\tvar out = [], big = [], BIG = 65536, OK = /^\\/api\\/((chat-media|forum)\\/[^\\s]*|voice\\/tea\\?op=[a-z]+)$/;\n\tfunction b64(blob) {\n\t\treturn new Promise(function (ok, no) {\n\t\t\tvar f = new FileReader();\n\t\t\tf.onload = function () { var s = String(f.result), i = s.indexOf(','); ok(i < 0 ? '' : s.slice(i + 1)); };\n\t\t\tf.onerror = no;\n\t\t\tf.readAsDataURL(blob);\n\t\t});\n\t}\n\twindow.__bbx = {\n\t\tgo: function (n, method, path, body, type) {\n\t\t\tif (!OK.test(path) || path.indexOf('..') >= 0 || path.indexOf('//') >= 0) return out.push({n: n, c: 0, b: ''});\n\t\t\tvar o = {method: method, credentials: 'same-origin', cache: 'no-store'};\n\t\t\tif (body) { o.body = body; o.headers = {'Content-Type': type || 'application/json'}; }\n\t\t\tfetch(path, o).then(function (r) {\n\t\t\t\treturn r.blob().then(b64).then(function (s) { (s.length > BIG ? big : out).push({n: n, c: r.status, b: s}); });\n\t\t\t}).catch(function () { out.push({n: n, c: 0, b: ''}); });\n\t\t},\n\t\tpoll: function () {\n\t\t\tif (!out.length && !big.length) return '';\n\t\t\tvar o = out;\n\t\t\tout = [];\n\t\t\tif (big.length) o.push(big.shift());\n\t\t\treturn JSON.stringify(o);\n\t\t}\n\t};\n})();"





























static var picker: Callable
static var picks: int = 0
static var sent: Array = []
static var _installed: bool = false
static var _n: int = 0
static var _pending: Dictionary = {}
static var _poll_at: int = -100000
static var _chosen: Array = []

static func reset() -> void :
	picker = Callable()
	picks = 0
	sent = []
	_installed = false
	_n = 0
	_pending = {}
	_poll_at = -100000
	_chosen = []


static func usable() -> bool:
	return PcVoice.is_pc() and PcVoice.blocked() == ""


static func android() -> bool:
	return not PcVoice.is_pc() and AndroidVoice.is_android() and AndroidVoice.has_session() and AndroidVoice.bridge().is_valid()


static func reachable() -> bool:
	return usable() or android()


static func allowed(path: String) -> bool:
	if path.begins_with("/api/chat-media/") or path.begins_with("/api/forum/"):
		return true
	if not path.begins_with(TEA) or path.length() == TEA.length():
		return false
	for c: String in path.substr(TEA.length()):
		if c < "a" or c > "z":
			return false
	return true

static func js(code: String) -> Variant:
	var b: Callable = AndroidVoice.bridge() if android() else PcVoice.bridge()
	return b.call(code) if b.is_valid() else null

static func busy() -> bool:
	return not _pending.is_empty()


static func send(method: int, path: String, body: String, ctype: String, on_done: Callable) -> bool:
	if not reachable() or method < 0 or method >= METHODS.size() or not allowed(path):
		return false
	if not _installed:
		_installed = true
		js(JS)
	_n += 1
	_pending[_n] = {"done": on_done, "at": Time.get_ticks_msec()}
	sent.append([method, path])
	js("window.__bbx.go(%d,%s,%s,%s,%s)" % [_n, JSON.stringify(METHODS[method]), JSON.stringify(path), JSON.stringify(body), 
		JSON.stringify(ctype)])
	return true


static func poll() -> void :
	if not _chosen.is_empty():
		var chosen: Array = _chosen
		_chosen = []
		for item: Array in chosen:
			(item[1] as Callable).call(item[0])
	if _pending.is_empty():
		return
	var now: int = Time.get_ticks_msec()
	if not reachable():
		for n: int in _pending.keys():
			_deliver(n, 0, "")
		return
	if now - _poll_at < POLL_MS:
		return
	_poll_at = now
	var raw_text: String = str(js(POLL_EXPR))
	var data: Variant = JSON.parse_string(raw_text) if raw_text.begins_with("[") else null
	if data is Array:
		for raw: Variant in data:
			if raw is Dictionary:
				_deliver(int(raw.get("n", 0)), int(raw.get("c", 0)), str(raw.get("b", "")))
	for n: int in _pending.keys():
		if _pending.has(n) and now - int(_pending[n].at) > WAIT_MS:
			_deliver(n, 0, "")

static func _deliver(n: int, code: int, b64: String) -> void :
	if not _pending.has(n):
		return
	var done: Callable = _pending[n].done
	_pending.erase(n)
	var body: PackedByteArray = Marshalls.base64_to_raw(b64) if not b64.is_empty() else PackedByteArray()
	if done.is_valid():
		done.call(HTTPRequest.RESULT_SUCCESS if code > 0 else HTTPRequest.RESULT_CANT_CONNECT, code, body)


static func pick(multi: bool, done: Callable) -> bool:
	picks += 1
	if picker.is_valid():
		_chosen.append([PackedStringArray(picker.call(multi)), done])
		return true
	if not DisplayServer.has_feature(DisplayServer.FEATURE_NATIVE_DIALOG_FILE):
		return false
	var mode: int = DisplayServer.FILE_DIALOG_MODE_OPEN_FILES if multi else DisplayServer.FILE_DIALOG_MODE_OPEN_FILE
	var err: int = DisplayServer.file_dialog_show("Chọn ảnh", OS.get_system_dir(OS.SYSTEM_DIR_PICTURES), "", false, mode, FILTERS, 
		func(status: bool, paths: PackedStringArray, _filter: int) -> void :
			var got: PackedStringArray = paths if status else PackedStringArray()
			( func() -> void : _chosen.append([got, done])).call_deferred())
	return err == OK


static func mime(bytes: PackedByteArray) -> String:
	if bytes.size() > 3 and bytes[0] == 255 and bytes[1] == 216 and bytes[2] == 255:
		return "image/jpeg"
	if bytes.size() > 8 and bytes.slice(0, 8) == PackedByteArray([137, 80, 78, 71, 13, 10, 26, 10]):
		return "image/png"
	if bytes.size() > 12 and bytes.slice(0, 4).get_string_from_ascii() == "RIFF" and bytes.slice(8, 12).get_string_from_ascii() == "WEBP":
		return "image/webp"
	if bytes.size() > 6 and bytes.slice(0, 4).get_string_from_ascii() == "GIF8":
		return "image/gif"
	if bytes.size() > 26 and bytes[0] == 66 and bytes[1] == 77:
		return "image/bmp"
	return ""


static func prepare(path: String) -> Dictionary:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return {"error": "bad"}
	var size: int = f.get_length()
	if size <= 0:
		return {"error": "bad"}
	if size > FILE_MAX:
		return {"error": "big"}
	var bytes: PackedByteArray = f.get_buffer(size)
	f.close()
	var type: String = mime(bytes)
	if type.is_empty():
		return {"error": "bad"}
	if bytes.size() > RAW_MAX:
		bytes = _shrink(bytes, type)
		if bytes.is_empty():
			return {"error": "big"}
		type = "image/jpeg"
	return {"b64": Marshalls.raw_to_base64(bytes), "type": type}


static func _shrink(bytes: PackedByteArray, type: String) -> PackedByteArray:
	var image: Image = Image.new()
	var error: int = ERR_FILE_UNRECOGNIZED
	match type:
		"image/jpeg":
			error = image.load_jpg_from_buffer(bytes)
		"image/png":
			error = image.load_png_from_buffer(bytes)
		"image/webp":
			error = image.load_webp_from_buffer(bytes)
		"image/bmp":
			error = image.load_bmp_from_buffer(bytes)
	if error != OK or image.is_empty():
		return PackedByteArray()
	var longest: int = maxi(image.get_width(), image.get_height())
	if longest > SIDE:
		var s: float = float(SIDE) / longest
		image.resize(maxi(1, roundi(image.get_width() * s)), maxi(1, roundi(image.get_height() * s)), Image.INTERPOLATE_BILINEAR)
	if image.detect_alpha() != Image.ALPHA_NONE:
		image.convert(Image.FORMAT_RGBA8)
		var flat: Image = Image.create(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8)
		flat.fill(Color.WHITE)
		flat.blend_rect(image, Rect2i(Vector2i.ZERO, image.get_size()), Vector2i.ZERO)
		image = flat
	image.convert(Image.FORMAT_RGB8)
	for q: float in [0.9, 0.8, 0.7, 0.55]:
		var out: PackedByteArray = image.save_jpg_to_buffer(q)
		if not out.is_empty() and out.size() <= RAW_MAX:
			return out
	return PackedByteArray()
