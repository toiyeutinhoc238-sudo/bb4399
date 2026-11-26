extends RefCounted
const AppSession = preload("res://net/app_session.gd")















const SafeJson = preload("res://net/safe_json.gd")
const ChatMedia = preload("chat_media.gd")
const ChatFaces = preload("chat_faces.gd")
const PcFetch = preload("res://net/pc_fetch.gd")

const ROOT: String = "/api/forum/"
const LEVEL: int = 10
const TEXT_MAX: int = 500
const COMMENT_MAX: int = 200
const IMAGES_MAX: int = 4
const PAGE: int = 20
const HOT_PAGES: int = 20
const AGAIN: float = 20.0
const STALE: float = 60.0
const KEEP: int = 40
const POLL: float = 0.1
const SHARE_HEAD: String = "[Diễn đàn] "
const SHARE_CUT: int = 40
const JS: String = "(function () {\n\tif (window.__bbf) return;\n\tvar out = [], busy = 0, last = 0, chain = Promise.resolve();\n\tfunction push(o) { out.push(o); }\n\tfunction wait(ms) { return new Promise(function (ok) { setTimeout(ok, ms); }); }\n\tfunction jpeg(c, q) { return new Promise(function (ok) { c.toBlob(ok, 'image/jpeg', q); }); }\n\tasync function shrink(file) {\n\t\tvar bmp = await createImageBitmap(file), side = 1280, qs = [0.86, 0.74, 0.62, 0.5];\n\t\ttry {\n\t\t\tfor (var k = 0; k < 5; k++) {\n\t\t\t\tvar s = Math.min(1, side / Math.max(bmp.width, bmp.height));\n\t\t\t\tvar w = Math.max(1, Math.round(bmp.width * s)), h = Math.max(1, Math.round(bmp.height * s));\n\t\t\t\tvar c = document.createElement('canvas');\n\t\t\t\tc.width = w; c.height = h;\n\t\t\t\tvar g = c.getContext('2d');\n\t\t\t\tg.fillStyle = '#fff'; g.fillRect(0, 0, w, h); g.drawImage(bmp, 0, 0, w, h);\n\t\t\t\tfor (var i = 0; i < qs.length; i++) {\n\t\t\t\t\tvar blob = await jpeg(c, qs[i]);\n\t\t\t\t\tif (blob && blob.size <= 1000000) return blob;\n\t\t\t\t}\n\t\t\t\tside = Math.round(side * 0.75);\n\t\t\t}\n\t\t\treturn null;\n\t\t} finally { if (bmp.close) bmp.close(); }\n\t}\n\tasync function one(file) {\n\t\ttry {\n\t\t\tvar blob = await shrink(file);\n\t\t\tif (!blob) return push({ok: false, error: 'big'});\n\t\t\tvar gap = 2100 - (Date.now() - last);\n\t\t\tif (gap > 0) await wait(gap);\n\t\t\tlast = Date.now();\n\t\t\tvar r = await fetch('/api/forum/upload', {method: 'POST', body: blob, credentials: 'same-origin', headers: {'Content-Type': 'image/jpeg'}});\n\t\t\tvar j = await r.json().catch(function () { return {ok: false, error: 'HTTP ' + r.status}; });\n\t\t\tpush({ok: !!(j && j.ok && j.image), image: j && j.image || null, error: j && j.error || ''});\n\t\t} catch (e) { push({ok: false, error: e && e.name === 'TypeError' ? 'net' : 'bad'}); }\n\t}\n\tfunction blobOf(b64, type) {\n\t\tvar s = atob(b64), a = new Uint8Array(s.length);\n\t\tfor (var i = 0; i < s.length; i++) a[i] = s.charCodeAt(i);\n\t\treturn new Blob([a], {type: type || 'application/octet-stream'});\n\t}\n\twindow.__bbf = {\n\t\tpick: function (n) {\n\t\t\tvar input = document.createElement('input');\n\t\t\tinput.type = 'file'; input.accept = 'image/*'; input.multiple = n > 1; input.style.display = 'none';\n\t\t\tdocument.body.appendChild(input);\n\t\t\tfunction gone() { if (input.parentNode) input.parentNode.removeChild(input); }\n\t\t\tinput.addEventListener('cancel', function () { gone(); push({ok: false, error: 'cancel'}); });\n\t\t\tinput.addEventListener('change', function () {\n\t\t\t\tvar files = Array.prototype.slice.call(input.files || [], 0, Math.max(1, n));\n\t\t\t\tgone();\n\t\t\t\tif (!files.length) return push({ok: false, error: 'cancel'});\n\t\t\t\tbusy += files.length;\n\t\t\t\t(async function () { for (var i = 0; i < files.length; i++) { await one(files[i]); busy--; } })();\n\t\t\t});\n\t\t\tinput.click();\n\t\t},\n\t\tput: function (b64, type) { // pmd1: ảnh app PC chọn bằng hộp chọn Windows (byte base64 từ Godot), tải lần lượt\n\t\t\tbusy++;\n\t\t\tchain = chain.then(function () { return one(blobOf(b64, type)); })\n\t\t\t\t.catch(function () { push({ok: false, error: 'bad'}); })\n\t\t\t\t.then(function () { busy--; });\n\t\t},\n\t\tpoll: function () {\n\t\t\tvar o = out;\n\t\t\tout = [];\n\t\t\treturn JSON.stringify({out: o, busy: busy});\n\t\t}\n\t};\n})();"







































































static var feeds: Dictionary = {}
static var posts: Dictionary = {}
static var threads: Dictionary = {}
static var profiles: Dictionary = {}
static var tags: Array = []
static var notices: Array = []
static var unread: int = 0
static var gone: Dictionary = {}
static var draft: Array = []
static var uploading: int = 0
static var reported: Dictionary = {}
static var rev: int = 0
static var asks: Array = []
static var calls: Array = []
static var fetch: Callable
static var bridge: Callable
static var _notes: Array = []
static var _tags_at: float = -1000.0
static var _bell_at: float = -1000.0
static var _pictures: Dictionary = {}
static var _installed: bool = false
static var _poll_at: float = -1.0
static var _queue: Array = []
static var _busy: Array = []
static var _failed: float = -1000.0
static var _cool: Dictionary = {}
static var _http: HTTPRequest = null
static var _client: Object = null

static func reset() -> void :
	feeds = {}
	posts = {}
	threads = {}
	profiles = {}
	tags = []
	notices = []
	unread = 0
	gone = {}
	draft = []
	uploading = 0
	reported = {}
	rev = 0
	asks = []
	calls = []
	fetch = Callable()
	bridge = Callable()
	_notes = []
	_tags_at = -1000.0
	_bell_at = -1000.0
	_pictures = {}
	_installed = false
	_poll_at = -1.0
	_queue = []
	_busy = []
	_failed = -1000.0
	_cool = {}
	_client = null

static func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


static func _origin(client: Object) -> Variant:
	var config: Variant = client.get("config") if client != null else null
	if config == null:
		return null
	if (str(config.get("origin")).is_empty() or config.get("local_test_only") == true) and not fetch.is_valid():
		return null
	return str(config.get("origin"))


static func online(client: Object) -> bool:
	return _origin(client) != null


static func usable() -> bool:
	return bridge.is_valid() or OS.has_feature("web") or PcFetch.usable()

static func _pc() -> bool:
	return not bridge.is_valid() and not OS.has_feature("web") and PcFetch.usable()



static func feed_key(tab: String, arg: String = "") -> String:
	return tab + "|" + arg

static func feed(key: String) -> Dictionary:
	return feeds.get(key, {})


static func want_feed(client: Object, tab: String, arg: String = "", again: bool = false) -> void :
	var key: String = feed_key(tab, arg)
	var known: Dictionary = feeds.get(key, {})
	if ( not known.is_empty() and not again and _now() - float(known.at) < STALE) or _has("feed", key) or _now() - _failed < AGAIN:
		return
	_read(client, "feed", _feed_url(tab, arg, ""), key)


static func want_more(client: Object, key: String) -> void :
	var known: Dictionary = feeds.get(key, {})
	if known.is_empty() or not bool(known.more) or (known.ids as Array).is_empty() or _has("more", key) or _has("feed", key):
		return
	var parts: PackedStringArray = key.split("|", true, 1)
	var tab: String = parts[0]
	if tab == "hot" and int(known.page) >= HOT_PAGES:
		return
	var tail: String = "&page=%d" % (int(known.page) + 1) if tab == "hot" else "&before=%d" % int(known.ids[-1])
	_read(client, "more", _feed_url(tab, parts[1] if parts.size() > 1 else "", tail), key)

static func _feed_url(tab: String, arg: String, tail: String) -> String:
	var url: String = "feed?tab=" + tab
	if tab == "tag":
		url += "&tag=" + arg.uri_encode()
	elif tab == "user" and not arg.is_empty():
		url += "&user=" + arg
	return url + tail


static func want_post(client: Object, id: int, again: bool = false) -> void :
	if id <= 0 or (threads.has(id) and not again) or _has("post", str(id)):
		return
	_read(client, "post", "post?id=%d" % id, str(id))

static func want_tags(client: Object, every: float) -> void :
	if _now() - _tags_at < every or _has("tags", ""):
		return
	_tags_at = _now()
	_read(client, "tags", "tags", "")

static func want_bell(client: Object, every: float) -> void :
	if _now() - _bell_at < every or _has("bell", ""):
		return
	_bell_at = _now()
	_read(client, "bell", "bell", "")


static func want_notices(client: Object) -> void :
	if _has("notices", ""):
		return
	_read(client, "notices", "notices", "")
	_post(client, "seen", "seen", "")
	if unread > 0:
		unread = 0
		rev += 1


static func list(key: String) -> Array:
	var out: Array = []
	for id: Variant in feeds.get(key, {}).get("ids", []):
		if posts.has(int(id)) and not gone.has(int(id)):
			out.append(posts[int(id)])
	return out

static func loading(key: String) -> bool:
	return _has("feed", key) or _has("more", key)

static func post_loading(id: int) -> bool:
	return _has("post", str(id))



static func like(client: Object, id: int, on: bool) -> void :
	_post(client, "like", "like?id=%d&on=%d" % [id, 1 if on else 0], str(id))

static func comment(client: Object, id: int, text: String) -> void :
	_post(client, "comment", "comment?id=%d" % id, str(id), JSON.stringify({"text": text}))

static func uncomment(client: Object, post: int, comment_id: int) -> void :
	_post(client, "uncomment", "uncomment?id=%d" % comment_id, "%d:%d" % [post, comment_id])

static func follow(client: Object, user: int, on: bool) -> void :
	_post(client, "follow", "follow?id=%d&on=%d" % [user, 1 if on else 0], "%d:%d" % [user, 1 if on else 0])

static func remove(client: Object, id: int) -> void :
	_post(client, "delete", "delete?id=%d" % id, str(id))

static func report(client: Object, id: int) -> bool:
	if reported.has(id):
		return false
	reported[id] = true
	_post(client, "report", "report?id=%d" % id, str(id))
	return true


static func create(client: Object, text: String) -> void :
	if _has("create", ""):
		return
	var ids: Array = draft.map( func(image: Dictionary) -> String: return str(image.id))
	_post(client, "create", "create", "", JSON.stringify({"text": text, "images": ids}))

static func creating() -> bool:
	return _has("create", "")



static func _js(code: String) -> Variant:
	if bridge.is_valid():
		calls.append(code)
		return bridge.call(code)
	if OS.has_feature("web"):
		return JavaScriptBridge.eval(code, true)
	if PcFetch.usable():
		return PcFetch.js(code)
	return null


static func pick_images() -> void :
	var room: int = IMAGES_MAX - draft.size() - uploading
	if room <= 0:
		return
	if not _installed:
		_installed = true
		_js(JS)
	if _pc():
		if not PcFetch.pick(room > 1, func(paths: PackedStringArray) -> void : _picked(paths)):
			_note(ChatMedia.error_text({"error": "nopick"}))
		return
	_js("window.__bbf.pick(%d)" % room)


static func _picked(paths: PackedStringArray) -> void :
	var room: int = IMAGES_MAX - draft.size() - uploading
	for path: String in paths.slice(0, maxi(0, room)):
		var got: Dictionary = PcFetch.prepare(path)
		if got.has("error"):
			_note(ChatMedia.error_text(got))
			continue
		_js("window.__bbf.put(%s,%s)" % [JSON.stringify(got.b64), JSON.stringify(got.type)])
		uploading += 1
		rev += 1
	_poll_at = _now()


static func poll() -> void :
	PcFetch.poll()
	if not _installed or _now() - _poll_at < POLL:
		return
	_poll_at = _now()
	var data: Variant = SafeJson.parse(str(_js("window.__bbf?window.__bbf.poll():''")))
	if not data is Dictionary:
		return
	var was: int = uploading
	uploading = maxi(0, int(data.get("busy", 0)))
	for raw: Variant in data.get("out", []):
		if not raw is Dictionary:
			continue
		if bool(raw.get("ok", false)) and raw.get("image") is Dictionary and _image_ok(raw.image):
			if draft.size() < IMAGES_MAX:
				draft.append({"id": str(raw.image.id), "w": int(raw.image.get("w", 0)), "h": int(raw.image.get("h", 0))})
		else:
			var text: String = ChatMedia.error_text(raw)
			if not text.is_empty():
				_note(text)
		rev += 1
	if was != uploading:
		rev += 1

static func unpick(index: int) -> void :
	if index >= 0 and index < draft.size():
		draft.remove_at(index)
		rev += 1

static func _image_ok(image: Dictionary) -> bool:
	return RegEx.create_from_string("^[0-9a-f]{16}$").search(str(image.get("id", ""))) != null


static func picture(client: Object, id: String) -> Texture2D:
	var known: Dictionary = _pictures.get(id, {})
	if not known.is_empty():
		known.used = _now()
		return known.tex
	if not _image_ok({"id": id}) or _now() - _failed < AGAIN or _has("image", id):
		return null
	_read(client, "image", "image/" + id, id)
	return null

static func picture_gone(id: String) -> bool:
	return bool(_pictures.get(id, {}).get("gone", false))




static func share_text(post: Dictionary) -> String:
	var text: String = str(post.get("text", "")).strip_edges().split("\n")[0].strip_edges()
	if text.is_empty():
		text = "Ảnh của %s" % str(post.get("name", "")) if not (post.get("images", []) as Array).is_empty() else "Bài của %s" % str(post.get("name", ""))
	if text.length() > SHARE_CUT:
		text = text.substr(0, SHARE_CUT - 1).strip_edges() + "…"
	return SHARE_HEAD + text


static func from_wire(param_vec: String, text: String) -> int:
	if not param_vec.contains("\"post\"") or not text.begins_with(SHARE_HEAD):
		return 0
	var data: Variant = SafeJson.parse(param_vec)
	if not data is Dictionary:
		return 0
	var id: int = int(data.get("post", 0)) if (data.get("post") is float or data.get("post") is int) else 0
	return id if id > 0 else 0


static func tags_of(text: String) -> Array:
	var out: Array = []
	for found: RegExMatch in RegEx.create_from_string("#([\\p{L}\\p{N}_]{2,24})").search_all(text):
		var tag: String = found.get_string(1).to_lower()
		if not out.has(tag):
			out.append(tag)
		if out.size() >= 5:
			break
	return out


static func take() -> Array:
	var out: Array = _notes
	_notes = []
	return out

static func _note(text: String) -> void :
	_notes.append({"kind": "say", "text": text})



static func _has(kind: String, arg: String) -> bool:
	for job: Array in _queue + ([_busy] if not _busy.is_empty() else []):
		if str(job[0]) == kind and str(job[3]) == arg:
			return true
	return false

static func _read(client: Object, kind: String, path: String, arg: String) -> void :
	var origin: Variant = _origin(client)
	if origin == null or _now() - _failed < AGAIN or _now() - float(_cool.get(kind + "|" + arg, -1000.0)) < AGAIN:
		return
	_ask(client, [kind, str(origin) + ROOT + path, HTTPClient.METHOD_GET, arg, ""])

static func _post(client: Object, kind: String, path: String, arg: String, body: String = "") -> void :
	var origin: Variant = _origin(client)
	if origin == null:
		_note("Diễn đàn chỉ có ở bản web.")
		return
	_ask(client, [kind, str(origin) + ROOT + path, HTTPClient.METHOD_POST, arg, body])

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
	var body: String = str(_busy[4])
	asks.append([method, url, body])
	if fetch.is_valid():
		if int(fetch.call(url, method, body)) != OK:
			_fail()
		return
	if PcFetch.reachable():
		var job: Array = _busy
		var at: int = url.find(ROOT)
		if at < 0 or not PcFetch.send(method, url.substr(at), body, "application/json" if not body.is_empty() else "", 
				func(result: int, code: int, data: PackedByteArray) -> void :
					if _busy == job:
						done(result, code, data)):
			_fail()
		return
	var host: Node = _client as Node
	if host == null or not host.is_inside_tree():
		_busy = []
		_queue = []
		return
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"]) if not body.is_empty() else PackedStringArray()
	headers.append_array(AppSession.headers(url))
	if _http != null and is_instance_valid(_http):
		_http.cancel_request()
	if _http == null or not is_instance_valid(_http):
		_http = HTTPRequest.new()
		_http.timeout = 20.0
		if OS.has_feature("web"):
			_http.accept_gzip = false
		_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, data: PackedByteArray) -> void :
			done(result, code, data))
		_http.ready.connect( func() -> void :
			if _http.request(url, headers, method, body) != OK:
				_fail(), CONNECT_ONE_SHOT)
		host.add_child.call_deferred(_http)
	elif _http.request(url, headers, method, body) != OK:
		_fail()


static func _fail() -> void :
	if not _busy.is_empty() and int(_busy[2]) == HTTPClient.METHOD_POST and str(_busy[0]) not in ["seen", "report"]:
		_note("Lỗi mạng — thử lại.")
	_busy = []
	_queue = _queue.filter( func(job: Array) -> bool: return int(job[2]) == HTTPClient.METHOD_POST)
	_failed = _now()


static func done(result: int, code: int, body: PackedByteArray) -> void :
	if _busy.is_empty():
		return
	var job: Array = _busy
	var kind: String = str(job[0])
	var arg: String = str(job[3])
	if result != HTTPRequest.RESULT_SUCCESS:
		_fail()
		return
	if kind == "image":
		if code == 200 or code in [404, 410]:
			_keep(arg, ChatMedia.decode(body) if code == 200 else null)
		else:
			_fail()
			return
	else:

		var text: String = body.get_string_from_utf8().strip_edges()
		var data: Variant = SafeJson.parse(text) if text.begins_with("{") or text.begins_with("[") else null
		if code != 200:
			if not data is Dictionary or not data.has("error"):
				_fail()
				return
			_refused(kind, arg, code, str(data.error))
		elif not data is Dictionary or not parse(kind, arg, data):
			_fail()
			return
	_busy = []
	_next()

static func _refused(kind: String, arg: String, code: int, text: String) -> void :
	_cool[kind + "|" + arg] = _now()
	if code == 410 and kind in ["post", "like", "comment", "delete", "report"]:
		var id: int = int(arg)
		gone[id] = true
		threads.erase(id)
		_notes.append({"kind": "removed", "id": id})
	if kind == "report":
		reported.erase(int(arg))
	if kind not in ["bell", "tags", "seen", "notices"]:
		_note(text)
	rev += 1


static func _keep_post(raw: Variant) -> int:
	if not raw is Dictionary or int(raw.get("id", 0)) <= 0:
		return 0
	var id: int = int(raw.id)
	var images: Array = []
	for image: Variant in raw.get("images", []):
		if image is Dictionary and _image_ok(image):
			images.append({"id": str(image.id), "w": int(image.get("w", 0)), "h": int(image.get("h", 0))})
	var post: Dictionary = {"id": id, "by": int(raw.get("by", 0)), "name": str(raw.get("name", "")), "avatar": int(raw.get("avatar", 0)), 
		"level": int(raw.get("level", 1)), "text": str(raw.get("text", "")), "images": images, "likes": int(raw.get("likes", 0)), 
		"comments": int(raw.get("comments", 0)), "liked": bool(raw.get("liked", false)), "followed": bool(raw.get("followed", false)), 
		"at": int(raw.get("at", 0))}
	if posts.has(id):
		(posts[id] as Dictionary).merge(post, true)
	else:
		posts[id] = post
	gone.erase(id)
	_face(raw)
	return id

static func _face(raw: Dictionary) -> void :
	if int(raw.get("by", 0)) > 0:
		ChatFaces.put(int(raw.by), int(raw.get("avatar", 0)), int(raw.get("level", 1)))

static func parse(kind: String, arg: String, data: Dictionary) -> bool:
	match kind:
		"feed", "more":
			if not data.get("items") is Array:
				return false
			var ids: Array = []
			for raw: Variant in data.items:
				var id: int = _keep_post(raw)
				if id > 0:
					ids.append(id)
			var known: Dictionary = feeds.get(arg, {})
			if kind == "more" and not known.is_empty():
				for id: int in ids:
					if not (known.ids as Array).has(id):
						known.ids.append(id)
				known.more = bool(data.get("more", false)) and not ids.is_empty()
				known.page = int(known.page) + 1
			else:
				feeds[arg] = {"ids": ids, "more": bool(data.get("more", false)), "page": 0, "at": _now()}
			if data.get("profile") is Dictionary:
				var raw: Dictionary = data.profile
				var user: int = int(raw.get("id", 0))
				if user > 0:
					profiles[user] = {"id": user, "name": str(raw.get("name", "")), "avatar": int(raw.get("avatar", 0)), "level": int(raw.get("level", 1)), 
						"posts": int(raw.get("posts", 0)), "followers": int(raw.get("followers", 0)), "following": int(raw.get("following", 0)), 
						"followed": bool(raw.get("followed", false))}
					ChatFaces.put(user, int(raw.get("avatar", 0)), int(raw.get("level", 1)))
		"post", "create":
			var id: int = _keep_post(data.get("post"))
			if id <= 0:
				return false
			var rows: Array = []
			for raw: Variant in data.get("comments", []):
				if raw is Dictionary and int(raw.get("id", 0)) > 0:
					rows.append({"id": int(raw.id), "by": int(raw.get("by", 0)), "name": str(raw.get("name", "")), "avatar": int(raw.get("avatar", 0)), 
						"level": int(raw.get("level", 1)), "text": str(raw.get("text", "")), "at": int(raw.get("at", 0))})
					_face(raw)
			threads[id] = rows
			if kind == "create":
				draft = []
				for key: String in feeds.keys():
					if key.begins_with("new|") or key.begins_with("user|"):
						feeds.erase(key)
				_notes.append({"kind": "created", "id": id})
				_note("Đã đăng bài.")
		"tags":
			if not data.get("items") is Array:
				return false
			tags = []
			for raw: Variant in data.items:
				if raw is Dictionary and not str(raw.get("tag", "")).is_empty():
					tags.append({"tag": str(raw.tag), "n": int(raw.get("n", 0))})
		"bell":
			unread = int(data.get("unread", 0))
		"notices":
			if not data.get("items") is Array:
				return false
			notices = []
			for raw: Variant in data.items:
				if raw is Dictionary and int(raw.get("id", 0)) > 0:
					notices.append({"id": int(raw.id), "kind": str(raw.get("kind", "")), "by": int(raw.get("by", 0)), "name": str(raw.get("name", "")), 
						"post": int(raw.get("post", 0)), "excerpt": str(raw.get("excerpt", "")) if raw.get("excerpt") != null else "", 
						"at": int(raw.get("at", 0))})
					_face(raw)
		"like":
			var post: Dictionary = posts.get(int(arg), {})
			if not post.is_empty():
				post.likes = int(data.get("likes", post.likes))
				post.liked = bool(data.get("liked", post.liked))
		"comment":
			var post: Dictionary = posts.get(int(arg), {})
			if not post.is_empty():
				post.comments = int(post.comments) + 1
			threads.erase(int(arg))
			_read(_client, "post", "post?id=%d" % int(arg), arg)
		"uncomment":
			var parts: PackedStringArray = arg.split(":")
			var id: int = int(parts[0])
			var gone_id: int = int(parts[1])
			if threads.has(id):
				threads[id] = (threads[id] as Array).filter( func(row: Dictionary) -> bool: return int(row.id) != gone_id)
			if posts.has(id):
				posts[id].comments = maxi(0, int(posts[id].comments) - 1)
		"follow":
			var parts: PackedStringArray = arg.split(":")
			var user: int = int(parts[0])
			var on: bool = bool(data.get("followed", parts[1] == "1"))
			for post: Dictionary in posts.values():
				if int(post.by) == user:
					post.followed = on
			if profiles.has(user):
				var known: Dictionary = profiles[user]
				if bool(known.followed) != on:
					known.followers = maxi(0, int(known.followers) + (1 if on else -1))
				known.followed = on
			feeds.erase(feed_key("follow"))
			_note("Đã theo dõi." if on else "Đã bỏ theo dõi.")
		"delete":
			var id: int = int(arg)
			gone[id] = true
			threads.erase(id)
			_notes.append({"kind": "removed", "id": id})
			_note("Đã xoá bài.")
		"report":
			_note("Đã báo cáo bài — GM sẽ xem xét.")
		"seen":
			pass
	rev += 1
	return true

static func _keep(id: String, tex: Texture2D) -> void :
	_pictures[id] = {"tex": tex, "gone": tex == null, "used": _now()}
	while _pictures.size() > KEEP:
		var oldest: String = ""
		for key: String in _pictures:
			if oldest.is_empty() or float(_pictures[key].used) < float(_pictures[oldest].used):
				oldest = key
		_pictures.erase(oldest)
	rev += 1
