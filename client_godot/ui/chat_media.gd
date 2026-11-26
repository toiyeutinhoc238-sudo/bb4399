extends RefCounted
const AppSession = preload("res://net/app_session.gd")



















const SafeJson = preload("res://net/safe_json.gd")
const MicEngine = preload("mic_engine.gd")
const PcVoice = preload("res://net/pc_voice.gd")
const PcFetch = preload("res://net/pc_fetch.gd")
const ROOT: String = "/api/chat-media/"
const LEVEL: int = 10
const VOICE_SEC: int = 15
const SIDE: int = 640
const KEEP: int = 20
const AGAIN: float = 20.0
const POLL: float = 0.1
const THUMB: int = 112
const THUMB_KEEP: int = 80
const ALBUM_GAP: float = 4.0
const MARK: String = ""
const SECONDS: String = "″"
const JS: String = "(function () {\n\tif (window.__bbm) return;\n\tvar out = [], rec = null, au = null, auId = '';\n\tfunction push(o) { out.push(o); }\n\tfunction up(kind, q, blob) {\n\t\tpush({kind: kind, stage: 'up'});\n\t\tfetch('/api/chat-media/upload?kind=' + kind + q, {method: 'POST', body: blob, credentials: 'same-origin',\n\t\t\theaders: {'Content-Type': blob.type || 'application/octet-stream'}})\n\t\t\t.then(function (r) { return r.json().catch(function () { return {ok: false, error: 'HTTP ' + r.status}; }); })\n\t\t\t.then(function (j) { push({kind: kind, ok: !!(j && j.ok && j.media), media: j && j.media || null, state: j && j.state || '',\n\t\t\t\t\treused: !!(j && j.reused), error: j && j.error || ''}); })\n\t\t\t.catch(function () { push({kind: kind, ok: false, error: 'net'}); });\n\t}\n\tfunction jpeg(c, q) { return new Promise(function (ok) { c.toBlob(ok, 'image/jpeg', q); }); }\n\tfunction blobOf(b64, type) {\n\t\tvar s = atob(b64), a = new Uint8Array(s.length);\n\t\tfor (var i = 0; i < s.length; i++) a[i] = s.charCodeAt(i);\n\t\treturn new Blob([a], {type: type || 'application/octet-stream'});\n\t}\n\tfunction take(file) {\n\t\tpush({kind: 'img', stage: 'pack'});\n\t\tshrink(file).then(function (blob) {\n\t\t\tif (!blob) return push({kind: 'img', ok: false, error: 'big'});\n\t\t\tup('img', '', blob);\n\t\t}).catch(function () { push({kind: 'img', ok: false, error: 'bad'}); });\n\t}\n\tasync function shrink(file) {\n\t\tvar bmp = await createImageBitmap(file), side = 1280, qs = [0.86, 0.74, 0.62, 0.5];\n\t\ttry {\n\t\t\tfor (var k = 0; k < 5; k++) {\n\t\t\t\tvar s = Math.min(1, side / Math.max(bmp.width, bmp.height));\n\t\t\t\tvar w = Math.max(1, Math.round(bmp.width * s)), h = Math.max(1, Math.round(bmp.height * s));\n\t\t\t\tvar c = document.createElement('canvas');\n\t\t\t\tc.width = w; c.height = h;\n\t\t\t\tvar g = c.getContext('2d');\n\t\t\t\tg.fillStyle = '#fff'; g.fillRect(0, 0, w, h); g.drawImage(bmp, 0, 0, w, h);\n\t\t\t\tfor (var i = 0; i < qs.length; i++) {\n\t\t\t\t\tvar blob = await jpeg(c, qs[i]);\n\t\t\t\t\tif (blob && blob.size <= 1000000) return blob;\n\t\t\t\t}\n\t\t\t\tside = Math.round(side * 0.75);\n\t\t\t}\n\t\t\treturn null;\n\t\t} finally { if (bmp.close) bmp.close(); }\n\t}\n\twindow.__bbm = {\n\t\tpick: function () {\n\t\t\tvar input = document.createElement('input');\n\t\t\tinput.type = 'file'; input.accept = 'image/*'; input.style.display = 'none';\n\t\t\tdocument.body.appendChild(input);\n\t\t\tfunction gone() { if (input.parentNode) input.parentNode.removeChild(input); }\n\t\t\tinput.addEventListener('cancel', function () { gone(); push({kind: 'img', ok: false, error: 'cancel'}); });\n\t\t\tinput.addEventListener('change', function () {\n\t\t\t\tvar file = input.files && input.files[0];\n\t\t\t\tgone();\n\t\t\t\tif (!file) return push({kind: 'img', ok: false, error: 'cancel'});\n\t\t\t\ttake(file);\n\t\t\t});\n\t\t\tinput.click();\n\t\t},\n\t\tput: function (b64, type) { // pmd1: ảnh app PC chọn bằng hộp chọn Windows (byte base64 từ Godot)\n\t\t\ttry { take(blobOf(b64, type)); } catch (e) { push({kind: 'img', ok: false, error: 'bad'}); }\n\t\t},\n\t\trec: function () {\n\t\t\tif (rec) return;\n\t\t\tif (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia || typeof MediaRecorder === 'undefined')\n\t\t\t\treturn push({kind: 'voice', ok: false, error: 'nomic'});\n\t\t\t// mic1: có bộ xử lý mic (ui/mic_engine.gd, window.__bbmic) thì ghi luồng ĐÃ xử lý (khuếch đại, chống ồn, thiết bị đã chọn).\n\t\t\tvar mic = window.__bbmic;\n\t\t\tif (mic && mic.muted()) return push({kind: 'voice', ok: false, error: 'muted'});\n\t\t\tvar me = rec = {t0: 0, send: false, r: null, quit: false};\n\t\t\t(mic ? mic.acquire('rec') : navigator.mediaDevices.getUserMedia({audio: {echoCancellation: true, noiseSuppression: true}})).then(function (stream) {\n\t\t\t\tfunction close() { if (mic) mic.release('rec'); else stream.getTracks().forEach(function (t) { t.stop(); }); }\n\t\t\t\tif (me.quit) { close(); if (rec === me) rec = null; return push({kind: 'voice', ok: false, error: 'cancel'}); }\n\t\t\t\tvar types = ['audio/webm;codecs=opus', 'audio/ogg;codecs=opus', 'audio/mp4', 'audio/webm'], mime = '';\n\t\t\t\tfor (var i = 0; i < types.length; i++) if (MediaRecorder.isTypeSupported && MediaRecorder.isTypeSupported(types[i])) { mime = types[i]; break; }\n\t\t\t\tvar opt = {audioBitsPerSecond: 32000};\n\t\t\t\tif (mime) opt.mimeType = mime;\n\t\t\t\tvar r = new MediaRecorder(stream, opt), parts = [];\n\t\t\t\tme.r = r;\n\t\t\t\tr.ondataavailable = function (e) { if (e.data && e.data.size) parts.push(e.data); };\n\t\t\t\tr.onstop = function () {\n\t\t\t\t\tclose(); clearTimeout(me.cap);\n\t\t\t\t\tvar ms = Date.now() - me.t0;\n\t\t\t\t\tif (rec === me) rec = null;\n\t\t\t\t\tif (!me.send) return push({kind: 'voice', ok: false, error: 'cancel'});\n\t\t\t\t\tif (ms < 1000) return push({kind: 'voice', ok: false, error: 'short'});\n\t\t\t\t\tvar sec = Math.max(1, Math.min(15, Math.round(ms / 1000)));\n\t\t\t\t\tup('voice', '&sec=' + sec, new Blob(parts, {type: (r.mimeType || mime || 'audio/webm').split(';')[0]}));\n\t\t\t\t};\n\t\t\t\tme.t0 = Date.now();\n\t\t\t\tr.start();\n\t\t\t\tpush({kind: 'voice', stage: 'rec'});\n\t\t\t\tme.cap = setTimeout(function () { window.__bbm.stop(true); }, 15000);\n\t\t\t}).catch(function (e) {\n\t\t\t\tif (rec === me) rec = null;\n\t\t\t\tpush({kind: 'voice', ok: false, error: e && e.name === 'NotAllowedError' ? 'deny' : 'nomic'});\n\t\t\t});\n\t\t},\n\t\tstop: function (send) {\n\t\t\tvar me = rec;\n\t\t\tif (!me) return;\n\t\t\tme.send = !!send;\n\t\t\tif (me.r) { if (me.r.state !== 'inactive') me.r.stop(); } else me.quit = true;\n\t\t},\n\t\tplay: function (id) {\n\t\t\tif (au) { au.pause(); var was = auId; au = null; auId = ''; if (was === id) return; }\n\t\t\tvar a = au = new Audio('/api/chat-media/file/' + id);\n\t\t\tauId = id;\n\t\t\ta.onended = function () { if (au === a) { au = null; auId = ''; } };\n\t\t\ta.onerror = function () { if (au === a) { au = null; auId = ''; push({kind: 'play', ok: false, error: 'gone'}); } };\n\t\t\ta.play().catch(function () { if (au === a) { au = null; auId = ''; push({kind: 'play', ok: false, error: 'play'}); } });\n\t\t},\n\t\tpoll: function () {\n\t\t\tvar o = out;\n\t\t\tout = [];\n\t\t\treturn JSON.stringify({out: o, rec: rec && rec.r ? Date.now() - rec.t0 : -1, wait: rec && !rec.r ? 1 : 0, play: auId,\n\t\t\t\tpt: au ? au.currentTime : 0});\n\t\t}\n\t};\n})();"

























































































































static var recording: float = -1.0
static var asking_mic: bool = false
static var playing: String = ""
static var play_at: float = 0.0
static var stage: String = ""
static var reported: Dictionary = {}
static var rev: int = 0
static var asks: Array = []
static var calls: Array = []
static var fetch: Callable
static var bridge: Callable
static var _pictures: Dictionary = {}
static var _results: Array = []
static var _installed: bool = false
static var _poll_at: float = -1.0
static var _queue: Array = []
static var _busy: Array = []
static var _failed: float = -1000.0
static var _http: HTTPRequest = null
static var _client: Object = null
static var album: Array = []
static var album_ban: String = ""
static var album_max: int = 60
static var album_loaded: bool = false
static var album_rev: int = 0
static var _album_at: float = -1000.0
static var _thumbs: Dictionary = {}

static func reset() -> void :
	recording = -1.0
	asking_mic = false
	playing = ""
	play_at = 0.0
	stage = ""
	reported = {}
	rev = 0
	asks = []
	calls = []
	fetch = Callable()
	bridge = Callable()
	_pictures = {}
	_results = []
	_installed = false
	_poll_at = -1.0
	_queue = []
	_busy = []
	_failed = -1000.0
	_client = null
	album = []
	album_ban = ""
	album_max = 60
	album_loaded = false
	album_rev = 0
	_album_at = -1000.0
	_thumbs = {}

static func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


static func usable() -> bool:
	return bridge.is_valid() or OS.has_feature("web") or PcFetch.usable()


static func _pc() -> bool:
	return not bridge.is_valid() and not OS.has_feature("web") and PcFetch.usable()

static func _js(code: String) -> Variant:
	if bridge.is_valid():
		calls.append(code)
		return bridge.call(code)
	if OS.has_feature("web"):
		return JavaScriptBridge.eval(code, true)
	if PcFetch.usable():
		return PcFetch.js(code)
	return null


static func why_not(what: String) -> String:
	if OS.has_feature("android") or OS.has_feature("ios"):
		return what + " chưa có trên app."
	if PcVoice.is_pc():
		match PcVoice.blocked():
			"nosession":
				return what + " cần đăng nhập vào game."
			"fail:runtime":
				return what + " cần WebView2 Runtime — cài Microsoft Edge WebView2 Runtime rồi mở lại app."
			"fail:av", "fail:spawn":
				return what + " chưa dùng được: phần mềm diệt virus hoặc Windows đang chặn bbvoice.exe — cho phép tệp này rồi mở lại app."
			"":
				return what + " chưa sẵn sàng — thử lại."
		return what + " tạm hỏng (bộ thoại của app: %s) — mở lại app." % PcVoice.blocked().trim_prefix("fail:")
	if OS.has_feature("pc_app") or ( not OS.has_feature("web") and not OS.has_feature("editor")):
		return what + " chưa có trên bản app này — cài bản app mới."
	return what + " chỉ có ở bản web."

static func _install() -> void :
	if not _installed:
		_installed = true
		_js(JS)

static func busy() -> bool:
	return recording >= 0.0 or asking_mic or not stage.is_empty()


static func pick_image() -> void :
	_install()
	if _pc():
		if not PcFetch.pick(false, func(paths: PackedStringArray) -> void : _picked(paths)):
			_results.append({"kind": "img", "ok": false, "error": "nopick"})
		return
	_js("window.__bbm.pick()")


static func _picked(paths: PackedStringArray) -> void :
	if paths.is_empty():
		_results.append({"kind": "img", "ok": false, "error": "cancel"})
		return
	var got: Dictionary = PcFetch.prepare(paths[0])
	if got.has("error"):
		_results.append({"kind": "img", "ok": false, "error": str(got.error)})
		return
	_install()
	_js("window.__bbm.put(%s,%s)" % [JSON.stringify(got.b64), JSON.stringify(got.type)])

static func record_start() -> void :
	MicEngine.shared().prepare()
	_install()
	asking_mic = true
	_js("window.__bbm.rec()")


static func record_stop(send: bool) -> void :
	if recording < 0.0 and not asking_mic:
		return
	_js("window.__bbm.stop(%s)" % ("true" if send else "false"))


static func play(id: String) -> void :
	if not _id_ok(id):
		return
	_install()
	_js("window.__bbm.play('%s')" % id)
	playing = "" if playing == id else id
	play_at = 0.0


static func poll() -> void :
	PcFetch.poll()
	if not _installed or _now() - _poll_at < POLL:
		return
	_poll_at = _now()
	var data: Variant = SafeJson.parse(str(_js("window.__bbm?window.__bbm.poll():''")))
	if not data is Dictionary:
		return
	recording = float(data.get("rec", -1)) / 1000.0 if float(data.get("rec", -1)) >= 0.0 else -1.0
	asking_mic = int(data.get("wait", 0)) == 1
	playing = str(data.get("play", ""))
	play_at = float(data.get("pt", 0.0))
	for raw: Variant in data.get("out", []):
		if not raw is Dictionary:
			continue
		if raw.has("stage"):
			stage = "" if str(raw.stage) == "rec" else str(raw.stage)
			if str(raw.stage) == "rec":
				asking_mic = false
				recording = maxf(recording, 0.0)
		else:
			if str(raw.get("kind", "")) != "play":
				stage = ""
			if str(raw.get("kind", "")) == "voice":
				asking_mic = false
				recording = -1.0
		_results.append(raw)


static func take() -> Array:
	var out: Array = _results
	_results = []
	return out


static func error_text(result: Dictionary) -> String:
	match str(result.get("error", "")):
		"cancel":
			return ""
		"deny":
			if PcVoice.is_pc():
				return "Windows đang chặn micro — bật Cài đặt Windows › Quyền riêng tư › Micro (cho ứng dụng máy tính) rồi thử lại."
			return "Trình duyệt chưa cho dùng mic — bật quyền mic cho trang này rồi thử lại."
		"nomic":
			return "Máy / trình duyệt này không ghi âm được."
		"muted":
			return "Mic đang tắt — bật mic trong Cài đặt rồi thử lại."
		"short":
			return "Ghi âm ngắn quá (dưới 1 giây)."
		"big":
			return "Ảnh quá lớn, chọn ảnh khác."
		"bad":
			return "Không đọc được ảnh này."
		"net":
			return "Lỗi mạng — thử lại."
		"gone":
			return "Ghi âm đã hết hạn."
		"play":
			return "Không phát được ghi âm."
		"nopick":
			return "Không mở được hộp chọn ảnh."
		"":
			return "Gửi không được — thử lại."
	return str(result.error)

static func _id_ok(id: String) -> bool:
	return RegEx.create_from_string("^[0-9a-f]{16}$").search(id) != null


static func label(media: Dictionary) -> String:
	return "[Ảnh]" if str(media.get("kind", "")) == "img" else "[Ghi âm %d%s]" % [int(media.get("sec", 0)), SECONDS]


static func wire(media: Dictionary) -> Dictionary:
	return {"media": str(media.get("id", "")), "mk": str(media.get("kind", "")), "ms": int(media.get("sec", 0)), 
		"mw": int(media.get("w", 0)), "mh": int(media.get("h", 0))}


static func from_wire(param_vec: String, text: String) -> Dictionary:
	if not param_vec.contains("\"media\""):
		return {}
	var data: Variant = SafeJson.parse(param_vec)
	if not data is Dictionary:
		return {}
	return _media(str(data.get("media", "")), text, int(data.get("mw", 0)), int(data.get("mh", 0)))

static func _media(id: String, text: String, w: int, h: int) -> Dictionary:
	if not _id_ok(id):
		return {}
	if text == "[Ảnh]":
		return {"id": id, "kind": "img", "sec": 0, "w": clampi(w, 0, 4096), "h": clampi(h, 0, 4096)}
	var found: RegExMatch = RegEx.create_from_string("^\\[Ghi âm (\\d{1,2})" + SECONDS + "\\]$").search(text)
	if found != null and int(found.get_string(1)) >= 1 and int(found.get_string(1)) <= VOICE_SEC:
		return {"id": id, "kind": "voice", "sec": int(found.get_string(1)), "w": 0, "h": 0}
	return {}


static func split_stored(text: String) -> Array:
	var cut: int = text.find(MARK)
	if cut < 0:
		return [text, {}]
	var head: String = text.substr(0, cut)
	var data: Variant = SafeJson.parse(text.substr(cut + 1))
	if not data is Dictionary:
		return [head, {}]
	return [head, _media(str(data.get("id", "")), head, int(data.get("w", 0)), int(data.get("h", 0)))]


static func picture(client: Object, id: String) -> Texture2D:
	var known: Dictionary = _pictures.get(id, {})
	if not known.is_empty():
		known.used = _now()
		return known.tex
	if not _id_ok(id) or _now() - _failed < AGAIN or _has("file", id):
		return null
	var origin: Variant = _origin(client)
	if origin == null:
		return null
	_ask(client, ["file", str(origin) + ROOT + "file/" + id, HTTPClient.METHOD_GET, id])
	return null

static func gone(id: String) -> bool:
	return bool(_pictures.get(id, {}).get("gone", false))


static func report(client: Object, id: String) -> bool:
	if not _id_ok(id) or reported.has(id):
		return false
	var origin: Variant = _origin(client)
	if origin == null:
		return false
	reported[id] = true
	_ask(client, ["report", str(origin) + ROOT + "report?id=" + id, HTTPClient.METHOD_POST, id])
	return true

static func _origin(client: Object) -> Variant:
	var config: Variant = client.get("config") if client != null else null
	if config == null:
		return null
	if (str(config.get("origin")).is_empty() or config.get("local_test_only") == true) and not fetch.is_valid():
		return null
	return str(config.get("origin"))

static func _has(kind: String, id: String) -> bool:
	for job: Array in _queue + ([_busy] if not _busy.is_empty() else []):
		if str(job[0]) == kind and str(job[3]) == id:
			return true
	return false

static func _ask(client: Object, job: Array) -> void :
	_client = client
	_queue.append(job)
	_next()

static func _next() -> void :
	if not _busy.is_empty() or _queue.is_empty():
		return
	_busy = _queue.pop_front()
	var url: String = str(_busy[1])
	var method: int = int(_busy[2])
	asks.append([method, url])
	if fetch.is_valid():
		if int(fetch.call(url, method)) != OK:
			_fail()
		return
	if PcFetch.reachable():
		var job: Array = _busy
		var at: int = url.find(ROOT)
		if at < 0 or not PcFetch.send(method, url.substr(at), "", "", func(result: int, code: int, body: PackedByteArray) -> void :
				if _busy == job:
					done(result, code, body)):
			_fail()
		return
	var host: Node = _client as Node
	if host == null or not host.is_inside_tree():
		_busy = []
		_queue = []
		return
	if _http != null and is_instance_valid(_http):
		_http.cancel_request()
	if _http == null or not is_instance_valid(_http):
		_http = HTTPRequest.new()
		_http.timeout = 20.0
		if OS.has_feature("web"):
			_http.accept_gzip = false
		_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
			done(result, code, body))
		_http.ready.connect( func() -> void :
			if _http.request(url, AppSession.headers(url), method) != OK:
				_fail(), CONNECT_ONE_SHOT)
		host.add_child.call_deferred(_http)
	elif _http.request(url, AppSession.headers(url), method) != OK:
		_fail()

static func _fail() -> void :
	for job: Array in _queue + ([_busy] if not _busy.is_empty() else []):
		if str(job[0]) in ["add", "del"]:
			_results.append({"kind": "album_" + str(job[0]), "ok": false, "error": "net", "id": str(job[3])})
	_busy = []
	_queue = _queue.filter( func(job: Array) -> bool: return str(job[0]) == "report")
	_failed = _now()


static func done(result: int, code: int, body: PackedByteArray) -> void :
	if _busy.is_empty():
		return
	var kind: String = str(_busy[0])
	var id: String = str(_busy[3])
	if result == HTTPRequest.RESULT_SUCCESS and kind in ["album", "add", "del"]:
		_album_done(kind, id, code, body)
	elif result == HTTPRequest.RESULT_SUCCESS and kind in ["file", "thumb"] and code in [404, 410]:
		if kind == "file":
			_keep(id, null, true)
		else:
			_keep_thumb(id, null, true)
	elif result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_fail()
		return
	elif kind == "file":
		_keep(id, decode(body), false)
	elif kind == "thumb":
		_keep_thumb(id, shrink(decode(body), THUMB), false)
	_busy = []
	_next()


static func decode(body: PackedByteArray) -> Texture2D:
	var image: Image = Image.new()
	var error: int = ERR_FILE_UNRECOGNIZED
	if body.size() > 3 and body[0] == 255 and body[1] == 216:
		error = image.load_jpg_from_buffer(body)
	elif body.size() > 8 and body[0] == 137 and body[1] == 80:
		error = image.load_png_from_buffer(body)
	elif body.size() > 12 and body.slice(0, 4).get_string_from_ascii() == "RIFF" and body.slice(8, 12).get_string_from_ascii() == "WEBP":
		error = image.load_webp_from_buffer(body)
	if error != OK or image.is_empty():
		return null
	var longest: int = maxi(image.get_width(), image.get_height())
	if longest > SIDE:
		var s: float = float(SIDE) / longest
		image.resize(maxi(1, roundi(image.get_width() * s)), maxi(1, roundi(image.get_height() * s)), Image.INTERPOLATE_BILINEAR)
	return ImageTexture.create_from_image(image)

static func _keep(id: String, tex: Texture2D, is_gone: bool) -> void :
	_pictures[id] = {"tex": tex, "gone": is_gone or tex == null, "used": _now()}
	while _pictures.size() > KEEP:
		var oldest: String = ""
		for key: String in _pictures:
			if oldest.is_empty() or float(_pictures[key].used) < float(_pictures[oldest].used):
				oldest = key
		_pictures.erase(oldest)
	rev += 1




static func album_load(client: Object, every: float = 60.0, force: bool = false) -> void :
	var since: float = _now() - _album_at
	if since < ALBUM_GAP or ( not force and since < every) or _has("album", "") or _now() - _failed < AGAIN:
		return
	var origin: Variant = _origin(client)
	if origin == null:
		return
	_album_at = _now()
	_ask(client, ["album", str(origin) + ROOT + "album", HTTPClient.METHOD_GET, ""])


static func album_add(client: Object, id: String) -> bool:
	if not _id_ok(id) or _has("add", id):
		return false
	var origin: Variant = _origin(client)
	if origin == null:
		return false
	_ask(client, ["add", str(origin) + ROOT + "album/add?id=" + id, HTTPClient.METHOD_POST, id])
	return true


static func album_del(client: Object, id: String) -> bool:
	if not _id_ok(id) or _has("del", id):
		return false
	var origin: Variant = _origin(client)
	if origin == null:
		return false
	album = album.filter( func(item: Dictionary) -> bool: return str(item.get("id", "")) != id)
	album_rev += 1
	_ask(client, ["del", str(origin) + ROOT + "album/del?id=" + id, HTTPClient.METHOD_POST, id])
	return true


static func album_has(id: String) -> bool:
	for item: Dictionary in album:
		if str(item.get("id", "")) == id:
			return true
	return false


static func album_count(state: String = "") -> int:
	var count: int = 0
	for item: Dictionary in album:
		if (state.is_empty() and str(item.get("state", "")) != "no") or str(item.get("state", "")) == state:
			count += 1
	return count

static func _album_done(kind: String, id: String, code: int, body: PackedByteArray) -> void :
	var data: Variant = SafeJson.parse(body.get_string_from_utf8()) if body.size() > 0 else null
	var row: Dictionary = data if data is Dictionary else {}
	var error: String = str(row.get("error", "")) if row.get("error") is String else ""
	if error.is_empty() and code == 429:
		error = "Thao tác quá nhanh, thử lại sau."
	if kind == "album":
		if code == 200 and bool(row.get("ok", false)) and row.get("items") is Array:
			var items: Array = []
			for raw: Variant in row.items:
				if raw is Dictionary and _id_ok(str(raw.get("id", ""))) and str(raw.get("state", "")) in ["ok", "wait", "no"]:
					items.append({"id": str(raw.id), "w": clampi(int(raw.get("w", 0)), 0, 4096), "h": clampi(int(raw.get("h", 0)), 0, 4096), 
						"state": str(raw.state), "mine": bool(raw.get("mine", false))})
			album = items
			album_max = clampi(int(row.get("max", 60)), 1, 999)
			album_ban = str(row.ban) if row.get("ban") is String else ""
			album_loaded = true
			album_rev += 1
		return
	var ok: bool = code == 200 and bool(row.get("ok", false))
	if kind == "add" and not ok and error.is_empty():
		error = "Không sưu tầm được ảnh này."
	_results.append({"kind": "album_" + kind, "ok": ok, "error": error, "id": id})
	_album_at = minf(_album_at, _now() - ALBUM_GAP)
	album_load(_client, 0.0, true)


static func thumb(client: Object, id: String) -> Texture2D:
	var known: Dictionary = _thumbs.get(id, {})
	if not known.is_empty():
		known.used = _now()
		return known.tex
	var big: Dictionary = _pictures.get(id, {})
	if not big.is_empty() and big.tex != null:
		_keep_thumb(id, shrink(big.tex, THUMB), false)
		return _thumbs[id].tex
	if not _id_ok(id) or _now() - _failed < AGAIN or _has("thumb", id) or _has("file", id):
		return null
	var origin: Variant = _origin(client)
	if origin == null:
		return null
	_ask(client, ["thumb", str(origin) + ROOT + "file/" + id, HTTPClient.METHOD_GET, id])
	return null

static func thumb_gone(id: String) -> bool:
	return bool(_thumbs.get(id, {}).get("gone", false)) or gone(id)


static func shrink(tex: Texture2D, side: int) -> Texture2D:
	if tex == null:
		return null
	var image: Image = tex.get_image()
	if image == null or image.is_empty():
		return null
	var longest: int = maxi(image.get_width(), image.get_height())
	if longest > side:
		var s: float = float(side) / longest
		image.resize(maxi(1, roundi(image.get_width() * s)), maxi(1, roundi(image.get_height() * s)), Image.INTERPOLATE_BILINEAR)
	return ImageTexture.create_from_image(image)

static func _keep_thumb(id: String, tex: Texture2D, is_gone: bool) -> void :
	_thumbs[id] = {"tex": tex, "gone": is_gone or tex == null, "used": _now()}
	while _thumbs.size() > THUMB_KEEP:
		var oldest: String = ""
		for key: String in _thumbs:
			if oldest.is_empty() or float(_thumbs[key].used) < float(_thumbs[oldest].used):
				oldest = key
		_thumbs.erase(oldest)
	album_rev += 1
