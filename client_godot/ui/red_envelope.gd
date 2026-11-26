extends RefCounted
















const SafeJson = preload("res://net/safe_json.gd")
const AppSession = preload("res://net/app_session.gd")
const ROOT: String = "/api/red-envelope/"
const HEAD: String = "[Lì xì] "
const BAG_EVERY: float = 300.0
const OFF_AGAIN: float = 600.0
const AGAIN: float = 20.0
const HEARD_WAIT: Array = [1.0, 6.0]
const MONEY: Dictionary = {"cash": "Xu khóa", "silver": "Bạc", "cashgold": "Xu"}
const WISH: String = "Chúc mừng phát tài!"

static var gate: int = 0
static var bag: Dictionary = {}
static var rev: int = 0
static var asks: Array = []
static var fetch: Callable
static var _notes: Array = []
static var _bag_at: float = -1000.0
static var _want_at: float = -1.0
static var _failed: float = -1000.0
static var _who: int = -1
static var _queue: Array = []
static var _busy: Array = []
static var _http: HTTPRequest = null
static var _client: Object = null

static func reset() -> void :
	gate = 0
	bag = {}
	rev = 0
	asks = []
	fetch = Callable()
	_notes = []
	_bag_at = -1000.0
	_want_at = -1.0
	_failed = -1000.0
	_who = -1
	_queue = []
	_busy = []
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



static func shown() -> bool:
	return gate == 1

static func money_name(kind: String) -> String:
	return str(MONEY.get(kind, "Xu khóa"))

static func grants() -> Array:
	return bag.get("grants", []) if bag.get("grants") is Array else []

static func open_list() -> Array:
	return bag.get("open", []) if bag.get("open") is Array else []

static func own() -> Dictionary:
	return bag.get("own", {}) if bag.get("own") is Dictionary else {}

static func guild() -> Dictionary:
	return bag.get("guild", {}) if bag.get("guild") is Dictionary else {}

static func usable() -> bool:
	return gate == 1 and bag.get("ingame") == true and int(bag.get("level", 0)) >= int(bag.get("minLevel", 0))



static func can_open(e: Dictionary, me: int) -> bool:
	var mine_own: bool = int(e.get("fromId", 0)) == me and bag.get("selfClaim") != true
	if e.has("mine") or mine_own or int(e.get("taken", 0)) >= int(e.get("parts", 0)):
		return false
	return str(e.get("ch", "")) != "server" or int(bag.get("serverLeft", 0)) > 0


static func dot(me: int) -> bool:
	if not usable():
		return false
	if not grants().is_empty():
		return true
	return open_list().any( func(e: Variant) -> bool: return e is Dictionary and can_open(e, me))


static func from_wire(param_vec: String, text: String) -> Dictionary:
	if not param_vec.contains("\"rp\"") or not text.begins_with(HEAD):
		return {}
	var data: Variant = SafeJson.parse(param_vec)
	if not data is Dictionary or not (data.get("rp") is float or data.get("rp") is int):
		return {}
	var id: int = int(data.rp)
	if id <= 0:
		return {}
	return {"id": id, "money": "silver" if str(data.get("rm", "")) == "silver" else "cash"}


static func heard() -> void :
	if gate == -1:
		return
	var wait: float = randf_range(float(HEARD_WAIT[0]), float(HEARD_WAIT[1]))
	_want_at = _now() + wait if _want_at < 0.0 else minf(_want_at, _now() + wait)

static func want_bag() -> void :
	_want_at = _now()


static func take() -> Array:
	var out: Array = _notes
	_notes = []
	return out

static func busy(kind: String) -> bool:
	for job: Array in _queue + ([_busy] if not _busy.is_empty() else []):
		if str(job[0]) == kind:
			return true
	return false



static func tick(client: Object) -> void :
	if _origin(client) == null:
		return
	var who: int = int(client.get("account_id")) if client.get("account_id") != null else 0
	if who != _who:
		_who = who
		gate = 0
		bag = {}
		rev += 1
		_bag_at = -1000.0
		_want_at = _now()
	if who <= 0 or busy("bag") or _now() - _failed < AGAIN:
		return
	var due: bool = _want_at >= 0.0 and _now() >= _want_at
	var every: float = OFF_AGAIN if gate == -1 else BAG_EVERY
	if due or _now() - _bag_at >= every:
		_want_at = -1.0
		_bag_at = _now()
		_ask(client, ["bag", ROOT + "bag", HTTPClient.METHOD_GET, ""])



static func send_grant(client: Object, grant_id: int, ch: String, wish: String) -> void :
	_ask(client, ["send", ROOT + "send?src=grant:%d&ch=%s&wish=%s" % [grant_id, ch, _wish(wish).uri_encode()], HTTPClient.METHOD_POST, ""])

static func send_own(client: Object, money: String, pay: String, amount: int, parts: int, ch: String, wish: String) -> void :
	_ask(client, ["send", ROOT + "send?src=own&ch=%s&money=%s&pay=%s&total=%d&parts=%d&wish=%s" % [ch, money, pay, amount, parts, _wish(wish).uri_encode()], 
		HTTPClient.METHOD_POST, ""])

static func open_env(client: Object, id: int) -> void :
	if busy("open"):
		return
	_ask(client, ["open", ROOT + "open?id=%d" % id, HTTPClient.METHOD_POST, str(id)])

static func _wish(text: String) -> String:
	var clean: String = text.strip_edges().left(int(bag.get("wishMax", 30)))
	return clean if not clean.is_empty() else WISH


static func own_total(money: String, pay: String, amount: int) -> int:
	if pay == "cashgold":
		var cg: Dictionary = own().get("cashgold", {}) if own().get("cashgold") is Dictionary else {}
		return amount * int(cg.get("toCash", 1) if money == "cash" else cg.get("toSilver", 1000))
	return amount if pay == money else 0


static func own_refusal(money: String, pay: String, amount: int, parts: int) -> String:
	var o: Dictionary = own()
	if int(o.get("sendsLeft", 0)) <= 0:
		return "Hôm nay đã tự phát đủ số bao."
	var pr: Array = o.get("parts", [5, 50])
	if parts < int(pr[0]) or parts > int(pr[1]):
		return "Số phần từ %d đến %d." % [int(pr[0]), int(pr[1])]
	var span: Array = (o.get("cashgold", {}).get("range", [10, 200]) if pay == "cashgold" else o.get(money, [1, 2147483647]))
	if amount < int(span[0]) or amount > int(span[1]):
		return "%s: từ %s đến %s mỗi bao." % [money_name(pay), short(int(span[0])), short(int(span[1]))]
	if pay == "cashgold" and amount > int(o.get("xuLeft", 0)):
		return "Hôm nay chỉ còn phát được %d Xu." % int(o.get("xuLeft", 0))
	if own_total(money, pay, amount) < parts * 3:
		return "Tổng tiền quá ít so với số phần."
	return ""


static func short(n: int) -> String:
	if n >= 1000000 and n % 100000 == 0:
		return str(snappedf(n / 1000000.0, 0.1)).trim_suffix(".0") + "Tr"
	if n >= 10000 and n % 1000 == 0:
		return "%dK" % (n / 1000)
	return group(n)

static func group(n: int) -> String:
	var s: String = str(absi(n))
	var out: String = ""
	while s.length() > 3:
		out = "." + s.right(3) + out
		s = s.left(s.length() - 3)
	return ("-" if n < 0 else "") + s + out



static func _ask(client: Object, job: Array) -> void :
	var origin: Variant = _origin(client)
	if origin == null:
		if str(job[0]) != "bag":
			_notes.append({"kind": "say", "text": "Lì xì chỉ có khi chơi trực tuyến."})
		return
	_client = client
	job[1] = str(origin) + str(job[1])
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
	var host_node: Node = _client as Node
	if host_node == null or not host_node.is_inside_tree():
		_busy = []
		_queue = []
		return
	var headers: PackedStringArray = AppSession.headers(url)
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
			if _http.request(url, headers, method, "") != OK:
				_fail(), CONNECT_ONE_SHOT)
		host_node.add_child.call_deferred(_http)
	elif _http.request(url, headers, method, "") != OK:
		_fail()

static func _fail() -> void :
	if not _busy.is_empty() and str(_busy[0]) != "bag":
		_notes.append({"kind": "say", "text": "Lỗi mạng — thử lại."})
		if str(_busy[0]) == "open":
			_notes.append({"kind": "opened", "id": int(_busy[3]), "data": {}})
	_busy = []
	_queue = _queue.filter( func(job: Array) -> bool: return str(job[0]) != "bag")
	_failed = _now()
	_kick()


static var _kicked: bool = false
static func _kick() -> void :
	var host: Node = _client as Node if _client != null and is_instance_valid(_client) else null
	if fetch.is_valid() or host == null or not host.is_inside_tree():
		_next()
		return
	if _kicked:
		return
	_kicked = true
	host.get_tree().process_frame.connect( func() -> void :
		_kicked = false
		_next(), CONNECT_ONE_SHOT)


static func done(result: int, code: int, body: PackedByteArray) -> void :
	if _busy.is_empty():
		return
	var job: Array = _busy
	if result != HTTPRequest.RESULT_SUCCESS:
		_fail()
		return
	var data: Variant = SafeJson.parse(body.get_string_from_utf8())
	if not data is Dictionary:
		_fail()
		return
	_busy = []
	var kind: String = str(job[0])
	if data.get("ok") != true:
		if kind == "bag":
			if code == 401:
				_failed = _now()
		else:
			_notes.append({"kind": "say", "text": str(data.get("error", "Máy chủ lỗi — thử lại sau."))})
			if kind == "open":
				_notes.append({"kind": "opened", "id": int(job[3]), "data": {}})
	else:
		match kind:
			"bag":
				gate = 1 if data.get("on") == true else -1
				bag = data if gate == 1 else {}
				_bag_at = _now()
			"send":
				_notes.append({"kind": "sent", "id": int(data.get("id", 0))})
				want_bag()
			"open":
				_notes.append({"kind": "opened", "id": int(job[3]), "data": data})
				want_bag()
	rev += 1
	_next()
