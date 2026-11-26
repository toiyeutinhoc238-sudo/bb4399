extends RefCounted
const AppSession = preload("res://net/app_session.gd")







const SafeJson = preload("res://net/safe_json.gd")
const ROOT: String = "/api/chat-private/"
const PAGE: int = 50
const AGAIN: float = 20.0

static var items: Array = []
static var list_rev: int = -1
static var list_at: float = -1000.0
static var history: Dictionary = {}
static var rev: int = 0
static var asks: Array = []
static var fetch: Callable
static var _queue: Array = []
static var _busy: Array = []
static var _failed: float = -1000.0
static var _http: HTTPRequest = null
static var _client: Object = null

static func reset() -> void :
	items = []
	list_rev = -1
	list_at = -1000.0
	history.clear()
	rev = 0
	asks = []
	fetch = Callable()
	_queue = []
	_busy = []
	_failed = -1000.0
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


static func want_list(client: Object, every: float) -> void :
	if _now() - list_at < every or _now() - _failed < AGAIN or _has("list", 0):
		return
	var origin: Variant = _origin(client)
	if origin == null:
		return
	list_at = _now()
	_ask(client, ["list", str(origin) + ROOT + "list", HTTPClient.METHOD_GET, 0])


static func want_history(client: Object, peer: int, again: bool = false) -> void :
	if peer <= 0 or (history.has(peer) and not again) or _has("history", peer):
		return
	var origin: Variant = _origin(client)
	if origin == null:
		return
	_ask(client, ["history", str(origin) + ROOT + "history?peer=%d" % peer, HTTPClient.METHOD_GET, peer])


static func want_older(client: Object, peer: int) -> void :
	var known: Dictionary = history.get(peer, {})
	if known.is_empty() or not bool(known.more) or (known.rows as Array).is_empty() or _has("older", peer):
		return
	var origin: Variant = _origin(client)
	if origin == null:
		return
	_ask(client, ["older", str(origin) + ROOT + "history?peer=%d&before=%d" % [peer, int(known.rows[0].id)], HTTPClient.METHOD_GET, peer])


static func mark_read(client: Object, peer: int, upto: int) -> void :
	if peer <= 0 or upto <= 0:
		return
	for item: Dictionary in items:
		if int(item.peer) == peer and int(item.unread) > 0:
			item.unread = 0
			rev += 1
	var origin: Variant = _origin(client)
	if origin == null:
		return
	_ask(client, ["read", str(origin) + ROOT + "read?peer=%d&upto=%d" % [peer, upto], HTTPClient.METHOD_POST, peer])

static func unread(peer: int) -> int:
	for item: Dictionary in items:
		if int(item.peer) == peer:
			return int(item.unread)
	return 0


static func last_id(peer: int) -> int:
	var known: Dictionary = history.get(peer, {})
	var best: int = 0
	if not known.is_empty() and not (known.rows as Array).is_empty():
		best = int(known.rows[-1].id)
	for item: Dictionary in items:
		if int(item.peer) == peer:
			best = maxi(best, int(item.last.id))
	return best

static func _has(kind: String, peer: int) -> bool:
	for job: Array in _queue + ([_busy] if not _busy.is_empty() else []):
		if str(job[0]) == kind and int(job[3]) == peer:
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
	var host: Node = _client as Node
	if host == null or not host.is_inside_tree():
		_busy = []
		_queue = []
		return
	if _http != null and is_instance_valid(_http):
		_http.cancel_request()
	if _http == null or not is_instance_valid(_http):
		_http = HTTPRequest.new()
		_http.timeout = 15.0
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
	_busy = []
	_queue = _queue.filter( func(job: Array) -> bool: return str(job[0]) == "read")
	_failed = _now()


static func done(result: int, code: int, body: PackedByteArray) -> void :
	if _busy.is_empty():
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or not parse(str(_busy[0]), int(_busy[3]), body.get_string_from_utf8()):
		_fail()
		return
	_busy = []
	_next()

static func parse(kind: String, peer: int, text: String) -> bool:
	var data: Variant = SafeJson.parse(text)
	if not data is Dictionary:
		return false
	var now_rev: int = int(_client.get("chat_rev")) if _client != null and _client.get("chat_rev") != null else 0
	match kind:
		"list":
			if not data.get("items") is Array:
				return false
			items = []
			for raw: Variant in data.items:
				if raw is Dictionary and int(raw.get("peer", 0)) > 0 and raw.get("last") is Dictionary:
					var last: Dictionary = raw.last
					items.append({"peer": int(raw.peer), "name": str(raw.get("name", "")), "avatar": int(raw.get("avatar", 0)), 
						"level": int(raw.get("level", 1)), "unread": int(raw.get("unread", 0)), 
						"last": {"id": int(last.get("id", 0)), "from": int(last.get("from", 0)), "text": str(last.get("text", "")), "at": int(last.get("at", 0))}})
			list_rev = now_rev
		"history", "older":
			if not data.get("items") is Array:
				return false
			var rows: Array = []
			for raw: Variant in data.items:
				if raw is Dictionary and int(raw.get("id", 0)) > 0:
					rows.append({"id": int(raw.id), "from": int(raw.get("from", 0)), "text": str(raw.get("text", "")), "at": int(raw.get("at", 0))})
			if kind == "older" and history.has(peer):
				var known: Dictionary = history[peer]
				known.rows = rows + known.rows
				known.more = rows.size() >= PAGE
			else:
				history[peer] = {"rows": rows, "rev": now_rev, "more": rows.size() >= PAGE}
		"read":
			pass
	rev += 1
	return true
