extends RefCounted
const AppSession = preload("res://net/app_session.gd")




const SafeJson = preload("res://net/safe_json.gd")
const PATH: String = "/api/chat-faces"
const BATCH: int = 40
const AGAIN: float = 30.0
const STALE: float = 300.0

static var faces: Dictionary = {}
static var rev: int = 0
static var asks: int = 0
static var fetch: Callable
static var _asked: Dictionary = {}
static var _busy: bool = false
static var _failed: float = -1000.0
static var _http: HTTPRequest = null

static func reset() -> void :
	faces.clear()
	_asked.clear()
	rev = 0
	asks = 0
	fetch = Callable()
	_busy = false
	_failed = -1000.0


static func of(id: int) -> Array:
	return faces.get(id, [])


static func put(id: int, avatar: int, level: int) -> void :
	if id <= 0:
		return
	var face: Array = [avatar, level]
	if faces.get(id, []) != face:
		faces[id] = face
		rev += 1
	_asked[id] = _now()


static func want(client: Object, ids: Array) -> void :
	if _busy or client == null or _now() - _failed < AGAIN:
		return
	var config: Variant = client.get("config")
	if config == null:
		return
	var origin: String = str(config.get("origin"))
	if (origin.is_empty() or config.get("local_test_only") == true) and not fetch.is_valid():
		return
	var batch: PackedStringArray = PackedStringArray()
	for raw: Variant in ids:
		var id: int = int(raw)
		if id <= 0 or batch.has(str(id)) or _now() - float(_asked.get(id, - STALE - 1.0)) <= STALE:
			continue
		batch.append(str(id))
		if batch.size() >= BATCH:
			break
	if batch.is_empty():
		return
	for id: String in batch:
		_asked[int(id)] = _now()
	var url: String = origin + PATH + "?ids=" + ",".join(batch)
	asks += 1
	_busy = true
	if fetch.is_valid():
		if int(fetch.call(url)) != OK:
			_fail()
		return
	var host: Node = client as Node
	if host == null or not host.is_inside_tree():
		_busy = false
		return
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

static func _now() -> float:
	return Time.get_ticks_msec() / 1000.0

static func _fail() -> void :
	_busy = false
	_failed = _now()


static func done(result: int, code: int, body: PackedByteArray) -> void :
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or not parse(body.get_string_from_utf8()):
		_fail()
		return
	_busy = false

static func parse(text: String) -> bool:
	var data: Variant = SafeJson.parse(text)
	if not data is Dictionary:
		return false
	for key: Variant in data:
		var face: Variant = data[key]
		var id: int = int(str(key)) if str(key).is_valid_int() else 0
		if id > 0 and face is Array and (face as Array).size() >= 2:
			faces[id] = [int(face[0]), int(face[1])]
	rev += 1
	return true
