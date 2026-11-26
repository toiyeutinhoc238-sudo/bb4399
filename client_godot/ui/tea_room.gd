extends RefCounted
const AppSession = preload("res://net/app_session.gd")


















const SafeJson = preload("res://net/safe_json.gd")
const PcFetch = preload("res://net/pc_fetch.gd")
const ROOT: String = "/api/voice/tea?op="





const PROBE_MAX: int = 3
const OFF_AGAIN: float = 300.0
const PROBE_WAIT: Array = [30.0, 120.0]
const AGAIN: float = 20.0
const LIST_EVERY: float = 15.0
const STATE_EVERY: float = 20.0
const SHARE_HEAD: String = "[Phòng Trà] "
const LEVEL_CREATE: int = 10
const LEVEL_SEAT: int = 5
const SEATS: Array = [4, 6, 8]
const SEATS_DEFAULT: int = 6
const NAME_MAX: int = 20
const PEOPLE_MAX: int = 20
const TAGS: Array = [["tangau", "Tán Gẫu", Color("6fd0ff")], ["timdoi", "Tìm Đội", Color("ffb15a")], ["hatho", "Hát Hò", Color("f78fec")], 
	["guild", "Guild", Color("4cd964")], ["ketban", "Kết Bạn", Color("ffd25a")], ["hoidap", "Hỏi Đáp", Color("9fc4ff")]]
const CODES: Dictionary = {
	"off": "Phòng Trà đang tạm đóng.", "auth": "Phiên đăng nhập hết hạn — tải lại trang.", "offline": "Chưa vào sảnh — thử lại sau.", 
	"ingame": "Đang ở room / trận — ra sảnh rồi vào Phòng Trà.", "banned": "Bạn đang bị cấm voice.", 
	"name": "Tên phòng chưa hợp lệ.", "bad": "Thao tác không hợp lệ.", "busy": "Hết phòng trống — thử lại sau.", 
	"none": "Chưa có phòng phù hợp — tự tạo một phòng nhé!", "gone": "Phòng đã đóng.", "kicked": "Bạn vừa bị mời ra phòng này — 10 phút sau mới vào lại.", 
	"full": "Phòng đã đủ 20 người.", "pass": "Sai mật khẩu.", "locked": "Mic của bạn tạm bị khoá do nhiều tố cáo.", 
	"approve": "Phòng này chủ phòng mời mới lên mic — bấm Xin lên mic.", "taken": "Ghế đã có người.", "seatlock": "Ghế đang khoá.", 
	"nothost": "Bạn không còn là chủ phòng.", "rate": "Thao tác quá nhanh — thử lại sau.", "err": "Máy chủ lỗi — thử lại sau."}
const OUT: Dictionary = {"kick": "Bạn đã bị chủ phòng mời ra (10 phút sau mới vào lại được).", "closed": "Phòng Trà đã đóng.", 
	"game": "Bạn vào room / trận nên đã rời Phòng Trà.", "gone": "Mất kết nối lâu nên đã rời Phòng Trà.", "banned": "Bạn đang bị cấm voice — đã rời Phòng Trà."}

static var rooms: Array = []
static var total: int = 0
static var people: int = 0
static var page: int = 1
static var pages: int = 1
static var counts: Dictionary = {"all": 0, "friend": 0, "guild": 0}
static var filter: Dictionary = {"f": "all", "tag": "", "nolock": false, "q": ""}
static var listed: bool = false
static var room: Dictionary = {}
static var seats: Array = []
static var listen: Dictionary = {"n": 0, "top": []}
static var you: Dictionary = {}
static var lines: Array = []
static var requests: Array = []
static var room_rev: int = 0
static var mark: int = 0
static var invite: int = 0
static var rev: int = 0
static var asks: Array = []
static var fetch: Callable
static var voice: Object = null
static var _notes: Array = []
static var _list_at: float = -1000.0
static var _state_at: float = -1000.0
static var _want_state: bool = false
static var _my_seat: int = -2
static var _queue: Array = []
static var _busy: Array = []
static var _failed: float = -1000.0
static var _http: HTTPRequest = null
static var _client: Object = null
static var gate: int = 0
static var _probe_n: int = 0
static var _probe_at: float = 0.0
static var _probe_who: int = -1
static var _off_at: float = -1000.0
static var _away: bool = false

static func reset() -> void :
	rooms = []
	total = 0
	people = 0
	page = 1
	pages = 1
	counts = {"all": 0, "friend": 0, "guild": 0}
	filter = {"f": "all", "tag": "", "nolock": false, "q": ""}
	listed = false
	_clear_room()
	rev = 0
	asks = []
	fetch = Callable()
	voice = null
	_notes = []
	_list_at = -1000.0
	_queue = []
	_busy = []
	_failed = -1000.0
	_client = null
	gate = 0
	_probe_n = 0
	_probe_at = 0.0
	_probe_who = -1
	_off_at = -1000.0
	_away = false

static func _clear_room() -> void :
	room = {}
	seats = []
	listen = {"n": 0, "top": []}
	you = {}
	lines = []
	requests = []
	room_rev = 0
	mark = 0
	invite = 0
	_state_at = -1000.0
	_want_state = false
	_my_seat = -2

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




static func shown() -> bool:
	return gate == 1 or in_room()


static func probe(client: Object) -> void :
	var who: int = int(client.get("account_id")) if client.get("account_id") != null else 0
	if who != _probe_who:
		_probe_who = who
		_probe_n = 0
		_probe_at = 0.0
		if not in_room():
			gate = 0
	if gate == -1:
		if str(client.get("state")) not in ["lobby", "hall"]:
			_away = true
		elif _away and not in_room() and _now() - _off_at >= OFF_AGAIN:
			gate = 0
			_probe_n = 0
			_probe_at = 0.0
			_away = false
	if gate != 0 or _probe_n >= PROBE_MAX or _now() < _probe_at or _now() - _failed < AGAIN or _has("list"):
		return
	if str(client.get("state")) not in ["lobby", "hall"]:
		return
	_probe_at = _now() + float(PROBE_WAIT[mini(_probe_n, PROBE_WAIT.size() - 1)])
	_probe_n += 1
	want_list(client, true)

static func in_room() -> bool:
	return not room.is_empty()

static func room_id() -> int:
	return int(room.get("id", 0))

static func is_host() -> bool:
	return str(you.get("role", "")) == "host"


static func my_seat() -> int:
	return int(you.get("seat", -1)) if in_room() else -1

static func can_publish() -> bool:
	return bool(you.get("canPublish", false))

static func tag_name(slug: String) -> String:
	for row: Array in TAGS:
		if row[0] == slug:
			return str(row[1])
	return ""

static func tag_color(slug: String) -> Color:
	for row: Array in TAGS:
		if row[0] == slug:
			return row[2]
	return Color("8fa9c6")

static func host_face() -> Dictionary:
	var host: Variant = room.get("host", {})
	return host if host is Dictionary else {}


static func seat_at(i: int) -> Dictionary:
	for s: Variant in seats:
		if s is Dictionary and int(s.get("i", 0)) == i:
			return s
	return {}


static func seat_of(c: int) -> int:
	if c <= 0:
		return -1
	if int(host_face().get("c", 0)) == c:
		return 0
	for s: Variant in seats:
		if s is Dictionary and int(s.get("c", 0)) == c:
			return int(s.get("i", 0))
	return -1


static func chat_lines(client: Object) -> Array:
	var out: Array = []
	var me: int = int(client.get("account_oid")) if client != null and client.get("account_oid") != null else 0
	for raw: Variant in lines:
		if not raw is Dictionary:
			continue
		if int(raw.get("sys", 0)) == 1:
			out.append({"sys": true, "c": 0, "name": "", "text": str(raw.get("text", "")), "own": false})
		else:
			out.append({"sys": false, "c": int(raw.get("c", 0)), "name": str(raw.get("name", "")), "text": str(raw.get("text", "")), 
				"own": int(raw.get("c", 0)) == me and me > 0})
	if client != null and client.get("tea_log") is Array:
		var got: Array = client.tea_log
		var fresh: int = mini(got.size(), maxi(0, int(client.tea_rev) - mark))
		for k in range(got.size() - fresh, got.size()):
			var row: Dictionary = got[k]
			out.append({"sys": false, "c": int(row.get("oid", 0)), "name": str(row.get("name", "")), "text": str(row.get("raw", row.get("text", ""))), 
				"own": bool(row.get("own", false))})
	return out


static func _mark(client: Object) -> void :
	mark = int(client.tea_rev) if client != null and client.get("tea_rev") != null else 0




static func want_list(client: Object, again: bool = false) -> void :
	if not again and _now() - _list_at < LIST_EVERY:
		return
	if _has("list"):
		return
	_list_at = _now()
	var body: Dictionary = {"f": str(filter.f), "page": page}
	if not str(filter.tag).is_empty():
		body.tag = str(filter.tag)
	if bool(filter.nolock):
		body.nolock = 1
	if not str(filter.q).is_empty():
		body.q = str(filter.q)
	_read(client, "list", JSON.stringify(body))

static func set_filter(client: Object, key: String, value: Variant) -> void :
	if filter.get(key) == value:
		return
	filter[key] = value
	page = 1
	rev += 1
	want_list(client, true)

static func go_page(client: Object, to: int) -> void :
	to = clampi(to, 1, maxi(1, pages))
	if to == page:
		return
	page = to
	rev += 1
	want_list(client, true)


static func want_state(client: Object, again: bool = false) -> void :
	if not in_room():
		return
	if not again and not _want_state and _now() - _state_at < STATE_EVERY:
		return
	if _has("state"):
		return
	_want_state = false
	_state_at = _now()
	_read(client, "state", JSON.stringify({"rev": room_rev}))


static func tick(client: Object, looking: bool) -> void :
	PcFetch.poll()
	if not online(client):
		return
	probe(client)
	if in_room():
		want_state(client)
	elif looking and gate == 1:
		want_list(client)



static func create(client: Object, name: String, tag: String, seat_count: int, pin: String, approve: bool) -> void :
	var body: Dictionary = {"name": name.strip_edges().left(NAME_MAX), "tag": tag if not tag_name(tag).is_empty() else "tangau", 
		"seats": seat_count if SEATS.has(seat_count) else SEATS_DEFAULT, "pass": pin, "approve": approve}
	_post(client, "create", "", JSON.stringify(body))

static func join(client: Object, id: int, pin: String = "") -> void :
	var body: Dictionary = {"id": maxi(0, id)}
	if not pin.is_empty():
		body["pass"] = pin
	_post(client, "join", str(id) + (":p" if not pin.is_empty() else ""), JSON.stringify(body))


static func use_voice(v: Object) -> void :
	voice = v


static func leave(client: Object, give: int = 0) -> void :
	if not in_room():
		return
	_post(client, "leave", "", JSON.stringify({"give": give} if give > 0 else {}))
	drop(client, "")


static func seat(client: Object, act: String, i: int = 0) -> void :
	var body: Dictionary = {"do": act}
	if i > 0:
		body.i = i
	if act == "accept":
		invite = 0
		rev += 1
	_post(client, "seat", act, JSON.stringify(body))


static func host(client: Object, act: String, c: int = 0, i: int = 0, extra: Dictionary = {}) -> void :
	var body: Dictionary = {"do": act}
	if c > 0:
		body.c = c
	if i > 0:
		body.i = i
	body.merge(extra, true)
	_post(client, "host", act, JSON.stringify(body))


static func decline() -> void :
	invite = 0
	rev += 1


static func drop(client: Object, text: String) -> void :
	var was: bool = in_room()
	_clear_room()
	_queue = _queue.filter( func(job: Array) -> bool: return str(job[0]) not in ["state", "seat", "host"])
	if voice != null and is_instance_valid(voice):
		voice.tea_leave()
	if client != null and client.has_method("clear_tea_log"):
		client.clear_tea_log()
	if was:
		_notes.append({"kind": "left"})
	if not text.is_empty():
		_say(text)
	_list_at = -1000.0
	rev += 1


static func on_notice(client: Object, op: int, scope: String, code: String) -> void :
	if scope != "tea":
		return
	match op:
		4:
			if in_room() and int(code) != room_rev:
				_want_state = true
				want_state(client, true)
		5:
			if in_room() and int(code) > 0:
				invite = int(code)
				_notes.append({"kind": "invite", "seat": invite})
				rev += 1
		6:
			if in_room():
				drop(client, str(OUT.get(code, "Đã rời Phòng Trà.")))



static func invite_text(info: Dictionary = {}) -> String:
	var r: Dictionary = info if not info.is_empty() else room
	return SHARE_HEAD + "%s #%d" % [str(r.get("name", "")), int(r.get("id", 0))]


static func invite_param(info: Dictionary = {}) -> Dictionary:
	var r: Dictionary = info if not info.is_empty() else room
	return {"tea": int(r.get("id", 0))}


static func from_wire(param_vec: String, text: String) -> int:
	if not param_vec.contains("\"tea\"") or not text.begins_with(SHARE_HEAD):
		return 0
	var data: Variant = SafeJson.parse(param_vec)
	if not data is Dictionary:
		return 0
	var id: int = int(data.get("tea", 0)) if (data.get("tea") is float or data.get("tea") is int) else 0
	return id if id > 0 and id <= 9999 else 0


static func take() -> Array:
	var out: Array = _notes
	_notes = []
	return out

static func _say(text: String) -> void :
	_notes.append({"kind": "say", "text": text})



static func _has(kind: String) -> bool:
	for job: Array in _queue + ([_busy] if not _busy.is_empty() else []):
		if str(job[0]) == kind:
			return true
	return false

static func busy(kind: String) -> bool:
	return _has(kind)

static func _read(client: Object, kind: String, body: String) -> void :
	var origin: Variant = _origin(client)
	if origin == null or _now() - _failed < AGAIN:
		return
	_ask(client, [kind, str(origin) + ROOT + kind, HTTPClient.METHOD_POST, "", body])

static func _post(client: Object, kind: String, arg: String, body: String) -> void :
	var origin: Variant = _origin(client)
	if origin == null:
		_say("Phòng Trà chỉ có ở bản web.")
		return
	_ask(client, [kind, str(origin) + ROOT + kind, HTTPClient.METHOD_POST, arg, body])

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
		if at < 0 or not PcFetch.send(method, url.substr(at), body, "application/json", 
				func(result: int, code: int, data: PackedByteArray) -> void :
					if _busy == job:
						done(result, code, data)):
			_fail()
		return
	var host_node: Node = _client as Node
	if host_node == null or not host_node.is_inside_tree():
		_busy = []
		_queue = []
		return
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
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
		host_node.add_child.call_deferred(_http)
	elif _http.request(url, headers, method, body) != OK:
		_fail()


static func _fail() -> void :
	if not _busy.is_empty() and str(_busy[0]) not in ["list", "state", "leave"]:
		_say("Lỗi mạng — thử lại.")
	_busy = []
	_queue = _queue.filter( func(job: Array) -> bool: return str(job[0]) not in ["list", "state"])
	_failed = _now()


static func done(result: int, code: int, body: PackedByteArray) -> void :
	if _busy.is_empty():
		return
	var job: Array = _busy
	if result != HTTPRequest.RESULT_SUCCESS:
		_fail()
		return
	var data: Variant = SafeJson.parse(body.get_string_from_utf8())
	if not data is Dictionary or (code != 200 and not data.has("code")):
		_fail()
		return
	_busy = []
	if data.get("ok") == true:
		gate = 1
		if not parse(str(job[0]), str(job[3]), data):
			_failed = _now()
			if str(job[0]) in ["create", "join"]:
				_say(str(CODES.err))
	else:
		_refused(str(job[0]), str(job[3]), str(data.get("code", "err")))
	rev += 1
	_next()

static func _refused(kind: String, arg: String, code: String) -> void :
	var was: int = gate
	if code == "off":
		gate = -1
		_off_at = _now()
		_away = false
		rooms = []
	match kind:
		"list":
			listed = true
			if code in ["off", "auth"]:
				rooms = []
				if was == 1:
					_say(str(CODES[code]))
			_list_at = _now() + (40.0 if code in ["off", "auth"] else 0.0)
			return
		"state":
			if code == "off":
				drop(_client, str(CODES.off))
			elif code == "gone":
				drop(_client, "Bạn không còn ở Phòng Trà.")
			return
		"leave":
			return
	var text: String = str(CODES.get(code, CODES.err))
	if code == "level":
		text = "Cần cấp %d để tạo phòng." % LEVEL_CREATE if kind == "create" else ("Người này chưa đủ cấp %d để lên mic." % LEVEL_SEAT if kind == "host" else ("Cần cấp %d để lên mic." % LEVEL_SEAT if kind == "seat" else "Chưa đủ cấp vào Phòng Trà."))
	elif code == "rate" and kind == "join" and arg.ends_with(":p"):
		text = "Nhập sai quá nhiều lần — 10 phút sau thử lại."
	elif code == "rate" and kind == "create":
		text = "Tạo phòng quá nhiều — chờ một lát rồi thử lại."
	elif code == "locked" and kind == "host":
		text = "Mic người này đang bị khoá."
	if kind == "join" and code == "pass":
		_notes.append({"kind": "pass", "id": int(arg.get_slice(":", 0))})
	if kind == "seat" and code == "approve":
		invite = 0
	if code == "gone" and kind in ["seat", "host"]:
		drop(_client, "Phòng Trà đã đóng.")
		return
	if code in ["bad", "taken", "seatlock", "nothost", "approve"] and in_room():
		_want_state = true
	_say(text)


static func parse(kind: String, arg: String, data: Dictionary) -> bool:
	match kind:
		"list":
			if not data.get("rooms") is Array:
				return false
			rooms = []
			for raw: Variant in data.rooms:
				var one: Dictionary = _summary(raw)
				if not one.is_empty():
					rooms.append(one)
			total = int(data.get("total", rooms.size()))
			people = int(data.get("people", 0))
			pages = maxi(1, int(data.get("pages", 1)))
			page = clampi(int(data.get("page", page)), 1, pages)
			if data.get("counts") is Dictionary:
				for key: String in ["all", "friend", "guild"]:
					counts[key] = int(data.counts.get(key, counts.get(key, 0)))
			listed = true
		"create":
			if not data.get("state") is Dictionary or not _keep_state(data.state):
				return false
			_notes.append({"kind": "joined", "id": room_id(), "created": true})
		"join":
			var was: int = room_id()
			if not _keep_state(data):
				return false
			if was != room_id():
				_notes.append({"kind": "joined", "id": room_id()})
		"state":
			if int(data.get("same", 0)) == 1:
				return true
			return _keep_state(data)
		"seat":
			if arg == "ask":
				_say("Đã xin lên mic — chờ chủ phòng đồng ý.")
			_want_state = true
			want_state(_client, true)
		"host":
			if arg == "invite":
				_say("Đã mời lên mic.")
			elif arg == "edit":
				_say("Đã lưu cài đặt phòng.")
			_want_state = true
			want_state(_client, true)
		"leave":
			pass
	return true

static func _summary(raw: Variant) -> Dictionary:
	if not raw is Dictionary or int(raw.get("id", 0)) <= 0:
		return {}
	var mic: Array = []
	for m: Variant in raw.get("mic", []):
		if m is Dictionary:
			mic.append({"a": int(m.get("a", 0)), "sex": int(m.get("sex", 1))})
		else:
			mic.append(str(m))
	var host_raw: Dictionary = raw.get("host", {}) if raw.get("host") is Dictionary else {}
	return {"id": int(raw.id), "name": str(raw.get("name", "")), "tag": str(raw.get("tag", "")), "lock": bool(raw.get("lock", false)), 
		"approve": bool(raw.get("approve", false)), "n": int(raw.get("n", 0)), "max": int(raw.get("max", PEOPLE_MAX)), 
		"seats": int(raw.get("seats", mic.size())), "full": bool(raw.get("full", false)), "mic": mic, 
		"host": {"name": str(host_raw.get("name", "")), "a": int(host_raw.get("a", 0)), "sex": int(host_raw.get("sex", 1))}, 
		"friends": int(raw.get("friends", 0))}


static func _keep_state(data: Dictionary) -> bool:
	if not data.get("room") is Dictionary or int(data.room.get("id", 0)) <= 0:
		return false
	var fresh: bool = room_id() != int(data.room.id)
	room = data.room
	seats = data.get("seat", []) if data.get("seat") is Array else []
	listen = data.get("listen", {}) if data.get("listen") is Dictionary else {"n": 0, "top": []}
	if not listen.get("top") is Array:
		listen.top = []
	you = data.get("you", {}) if data.get("you") is Dictionary else {}
	lines = data.get("lines", []) if data.get("lines") is Array else []
	requests = data.get("asks", []) if data.get("asks") is Array else []
	room_rev = int(data.get("rev", 0))
	_state_at = _now()
	_mark(_client)
	if fresh:
		_list_at = -1000.0
		filter.q = ""
	var seat_now: int = int(you.get("seat", -1))
	if you.has("invite") and int(you.invite) > 0 and seat_now < 0:
		if invite != int(you.invite):
			invite = int(you.invite)
			_notes.append({"kind": "invite", "seat": invite})
	elif seat_now >= 0:
		invite = 0
	if voice != null and is_instance_valid(voice):
		if fresh and voice.tea_joined():
			voice.tea_leave()
		if fresh or not voice.tea_joined():
			voice.tea_join()
		if seat_now != _my_seat:
			voice.tea_seated(false)
		voice.tea_seated(bool(you.get("canPublish", false)))
	if not fresh and _my_seat > 0 and seat_now == -1:
		_say("Bạn đã xuống mic.")
	_my_seat = seat_now
	rev += 1
	return true
