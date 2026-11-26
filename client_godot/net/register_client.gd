extends Node








signal captcha_done(result: Dictionary)
signal register_done(result: Dictionary)
signal code_done(result: Dictionary)


signal status_done(result: Dictionary)




signal quiz_done(result: Dictionary)
signal check_done(result: Dictionary)


signal rooms_done(result: Dictionary)
signal here_done(result: Dictionary)








const QUIZ_BODY_MAX: int = 786432
const PIC_BYTES: int = 49152
const PIC_SIDE: int = 256
const PUZ_BYTES: int = 262144
const PUZ_W: int = 640
const PUZ_H: int = 480
const PUZ_CELLS: Vector2i = Vector2i(2, 6)
const GROUPS_MAX: int = 6

const DeviceId = preload("res://net/device_id.gd")
const NET_ERROR: String = "Không kết nối được máy chủ, kiểm tra mạng rồi thử lại."
const BAD_REPLY: String = "Máy chủ trả lời không hợp lệ, thử lại sau."

var _captcha: HTTPRequest
var _register: HTTPRequest
var _code: HTTPRequest
var _status: HTTPRequest
var _quiz: HTTPRequest
var _check: HTTPRequest
var _rooms: HTTPRequest
var _here: HTTPRequest

var hook: Callable

func _request(done: Callable, limit: int = 65536) -> HTTPRequest:
	var request: HTTPRequest = HTTPRequest.new()
	request.accept_gzip = not OS.has_feature("web")
	request.timeout = 12.0
	request.body_size_limit = limit
	request.max_redirects = 0
	add_child(request)
	request.request_completed.connect(done.bind(request))
	return request

func busy() -> bool:
	return is_instance_valid(_register) or is_instance_valid(_code) or is_instance_valid(_check)

func fetch_captcha(origin: String) -> void :
	_drop(_captcha)
	if hook.is_valid():
		_captcha = null
		hook.call("captcha", {})
		return
	_captcha = _request(_on_captcha)
	if _captcha.request(origin + "/api/register/captcha", PackedStringArray(["Cache-Control: no-cache"])) != OK:
		_drop(_captcha)
		_captcha = null
		captcha_done.emit({"ok": false, "error": NET_ERROR, "code": "NETWORK"})


func fetch_status(origin: String) -> void :
	_drop(_status)
	if hook.is_valid():
		_status = null
		hook.call("status", {})
		return
	_status = _request(_on_status)
	if _status.request(origin + "/api/register/status", PackedStringArray(["Cache-Control: no-cache"])) != OK:
		_drop(_status)
		_status = null
		status_done.emit({"ok": false})


func send_code(origin: String, email: String, captcha_id: String, code: String) -> void :
	_drop(_code)
	var payload: Dictionary = {"email": email, "captchaId": captcha_id, "captcha": code}
	var dev: Dictionary = DeviceId.wire()
	if not dev.is_empty():
		payload["dev"] = dev
	if hook.is_valid():
		_code = null
		hook.call("code", payload)
		return
	_code = _request(_on_code)
	if _code.request(origin + "/api/register/email-code", PackedStringArray(["Content-Type: application/json"]), 
		HTTPClient.METHOD_POST, JSON.stringify(payload)) != OK:
		_drop(_code)
		_code = null
		code_done.emit({"ok": false, "error": NET_ERROR, "code": "NETWORK"})


func fetch_rooms(origin: String) -> void :
	_drop(_rooms)
	if hook.is_valid():
		_rooms = null
		hook.call("rooms", {})
		return
	_rooms = _request(_on_rooms)
	if _rooms.request(origin + "/api/register/quiz-rooms") != OK:
		_drop(_rooms)
		_rooms = null
		rooms_done.emit({"ok": false, "error": NET_ERROR, "code": "NETWORK"})


func poll_here(origin: String, here: String) -> void :
	_drop(_here)
	if hook.is_valid():
		_here = null
		hook.call("here", {"here": here})
		return
	_here = _request(_on_here)
	var url: String = origin + "/api/register/quiz-rooms" + ("?here=" + here.uri_encode() if not here.is_empty() else "")
	if _here.request(url) != OK:
		_drop(_here)
		_here = null
		here_done.emit({"ok": false, "error": NET_ERROR, "code": "NETWORK"})


func fetch_quiz(origin: String, room: String = "", lv: int = 0) -> void :
	_drop(_quiz)
	var payload: Dictionary = {}
	if not room.is_empty():
		payload["room"] = room
		payload["lv"] = lv
	var dev: Dictionary = DeviceId.wire()
	if not dev.is_empty():
		payload["dev"] = dev
	if hook.is_valid():
		_quiz = null
		hook.call("quiz", payload)
		return
	_quiz = _request(_on_quiz, QUIZ_BODY_MAX)
	if _quiz.request(origin + "/api/register/quiz", PackedStringArray(["Content-Type: application/json"]), 
		HTTPClient.METHOD_POST, JSON.stringify(payload)) != OK:
		_drop(_quiz)
		_quiz = null
		quiz_done.emit({"ok": false, "error": NET_ERROR, "code": "NETWORK"})


func check_quiz(origin: String, quiz_id: String, answers: Array, caps: Array = []) -> void :
	_drop(_check)
	var payload: Dictionary = {"id": quiz_id, "answers": answers.duplicate(true)}
	if not caps.is_empty():
		payload["caps"] = caps.duplicate()
		payload["capRetry"] = 1
	if hook.is_valid():
		_check = null
		hook.call("check", payload)
		return
	_check = _request(_on_check)
	if _check.request(origin + "/api/register/quiz-check", PackedStringArray(["Content-Type: application/json"]), 
		HTTPClient.METHOD_POST, JSON.stringify(payload)) != OK:
		_drop(_check)
		_check = null
		check_done.emit({"ok": false, "error": NET_ERROR, "code": "NETWORK"})



func send(origin: String, username: String, password: String, captcha_id: String, code: String, mail: Dictionary = {}, quiz_token: String = "", reg_code: String = "") -> void :
	_drop(_register)
	var payload: Dictionary = {"username": username, "password": password, "captchaId": captcha_id, "captcha": code}
	if not mail.is_empty():
		payload = {"username": username, "password": password, "email": str(mail.get("email", "")), "emailCode": str(mail.get("emailCode", ""))}
	if not quiz_token.is_empty():
		payload["quizToken"] = quiz_token
	if not reg_code.is_empty():
		payload["regCode"] = reg_code
	var dev: Dictionary = DeviceId.wire()
	if not dev.is_empty():
		payload["dev"] = dev
	if hook.is_valid():
		_register = null
		hook.call("register", payload)
		payload.clear()
		return
	_register = _request(_on_register)
	var result: Error = _register.request(origin + "/api/register", PackedStringArray(["Content-Type: application/json"]), 
		HTTPClient.METHOD_POST, JSON.stringify(payload))
	payload.clear()
	if result != OK:
		_drop(_register)
		_register = null
		register_done.emit({"ok": false, "error": NET_ERROR, "code": "NETWORK"})


func answer(kind: String, status: int, body: Dictionary) -> void :
	var bytes: PackedByteArray = JSON.stringify(body).to_utf8_buffer()
	if kind == "captcha":
		captcha_done.emit(parse_captcha(HTTPRequest.RESULT_SUCCESS, status, bytes))
	elif kind == "code":
		code_done.emit(parse_code(HTTPRequest.RESULT_SUCCESS, status, bytes))
	elif kind == "status":
		status_done.emit(parse_status(HTTPRequest.RESULT_SUCCESS, status, bytes))
	elif kind == "quiz":
		quiz_done.emit(parse_quiz(HTTPRequest.RESULT_SUCCESS, status, bytes))
	elif kind == "rooms":
		rooms_done.emit(parse_rooms(HTTPRequest.RESULT_SUCCESS, status, bytes))
	elif kind == "here":
		here_done.emit(parse_rooms(HTTPRequest.RESULT_SUCCESS, status, bytes))
	elif kind == "check":
		check_done.emit(parse_check(HTTPRequest.RESULT_SUCCESS, status, bytes))
	else:
		register_done.emit(parse_register(HTTPRequest.RESULT_SUCCESS, status, bytes))

func cancel() -> void :
	_drop(_captcha)
	_drop(_register)
	_drop(_code)
	_drop(_status)
	_drop(_quiz)
	_drop(_check)
	_drop(_rooms)
	_drop(_here)
	_here = null
	_captcha = null
	_register = null
	_code = null
	_status = null
	_quiz = null
	_check = null
	_rooms = null

func _drop(request: HTTPRequest) -> void :
	if is_instance_valid(request):
		request.cancel_request()
		request.queue_free()

func _on_captcha(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _captcha:
		return
	_drop(_captcha)
	_captcha = null
	captcha_done.emit(parse_captcha(result, status, body))

func _on_register(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _register:
		return
	_drop(_register)
	_register = null
	register_done.emit(parse_register(result, status, body))

func _on_code(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _code:
		return
	_drop(_code)
	_code = null
	code_done.emit(parse_code(result, status, body))

func _on_status(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _status:
		return
	_drop(_status)
	_status = null
	status_done.emit(parse_status(result, status, body))

func _on_quiz(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _quiz:
		return
	_drop(_quiz)
	_quiz = null
	quiz_done.emit(parse_quiz(result, status, body))

func _on_check(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _check:
		return
	_drop(_check)
	_check = null
	check_done.emit(parse_check(result, status, body))

func _on_rooms(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _rooms:
		return
	_drop(_rooms)
	_rooms = null
	rooms_done.emit(parse_rooms(result, status, body))

func _on_here(result: int, status: int, _headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _here:
		return
	_drop(_here)
	_here = null
	here_done.emit(parse_rooms(result, status, body))

static func _json(result: int, body: PackedByteArray) -> Variant:
	if result != HTTPRequest.RESULT_SUCCESS:
		return null
	var json: JSON = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK or typeof(json.data) != TYPE_DICTIONARY:
		return {}
	return json.data

static func _refused(parsed: Dictionary) -> Dictionary:
	return {"ok": false, "error": str(parsed["error"]), "code": str(parsed.get("code", "")), "renew": parsed.get("renew") == true, 
		"later": typeof(parsed.get("openAt")) == TYPE_FLOAT}


static func _cap_retry(parsed: Dictionary) -> Dictionary:
	var out: Dictionary = _refused(parsed)
	var bad: Variant = parsed.get("bad")
	var imgs: Variant = parsed.get("imgs")
	if typeof(bad) != TYPE_ARRAY or typeof(imgs) != TYPE_ARRAY or (bad as Array).is_empty() or (bad as Array).size() != (imgs as Array).size() or (bad as Array).size() > 10:
		out["code"] = "QUIZ_CAP"
		out["renew"] = true
		return out
	var idx: Array = []
	var pics: Array = []
	for i in range((bad as Array).size()):
		var n: Variant = bad[i]
		var img: Image = Image.new()
		var raw_png: PackedByteArray = Marshalls.base64_to_raw(str(imgs[i])) if typeof(imgs[i]) == TYPE_STRING else PackedByteArray()
		if typeof(n) != TYPE_FLOAT or int(n) < 0 or int(n) > 9 or idx.has(int(n)) or raw_png.is_empty() or raw_png.size() > 65536\
		or img.load_png_from_buffer(raw_png) != OK or img.get_width() > 400 or img.get_height() > 200:
			out["code"] = "QUIZ_CAP"
			out["renew"] = true
			return out
		idx.append(int(n))
		pics.append(img)
	out["bad"] = idx
	out["imgs"] = pics
	out["left"] = clampi(int(parsed.get("left", 0)) if typeof(parsed.get("left")) == TYPE_FLOAT else 0, 0, 10)
	return out

static func parse_captcha(result: int, status: int, body: PackedByteArray) -> Dictionary:
	var parsed: Variant = _json(result, body)
	if parsed == null:
		return {"ok": false, "error": NET_ERROR, "code": "NETWORK"}
	if parsed.get("ok") == false and typeof(parsed.get("error")) == TYPE_STRING:
		return _refused(parsed)
	if status != 200 or parsed.get("ok") != true or typeof(parsed.get("id")) != TYPE_STRING or typeof(parsed.get("png")) != TYPE_STRING:
		return {"ok": false, "error": BAD_REPLY, "code": "RESPONSE"}
	var image: Image = Image.new()
	var bytes: PackedByteArray = Marshalls.base64_to_raw(str(parsed["png"]))
	if bytes.is_empty() or bytes.size() > 65536 or image.load_png_from_buffer(bytes) != OK or image.get_width() > 400 or image.get_height() > 200:
		return {"ok": false, "error": BAD_REPLY, "code": "RESPONSE"}
	return {"ok": true, "id": str(parsed["id"]), "image": image, "email": parsed.get("email") == true, "quiz": parsed.get("quiz") == true, 
		"regcode": parsed.get("regcode") == true}

static func parse_code(result: int, status: int, body: PackedByteArray) -> Dictionary:
	var parsed: Variant = _json(result, body)
	if parsed == null:
		return {"ok": false, "error": NET_ERROR, "code": "NETWORK"}
	if parsed.get("ok") == false and typeof(parsed.get("error")) == TYPE_STRING:
		return _refused(parsed)
	if status != 200 or parsed.get("ok") != true or typeof(parsed.get("to")) != TYPE_STRING:
		return {"ok": false, "error": BAD_REPLY, "code": "RESPONSE", "renew": true}
	return {"ok": true, "to": str(parsed["to"]).left(120), "ttl": int(parsed.get("ttl", 600)), "resend": clampi(int(parsed.get("resend", 60)), 0, 600)}

static func parse_register(result: int, status: int, body: PackedByteArray) -> Dictionary:
	var parsed: Variant = _json(result, body)
	if parsed == null:
		return {"ok": false, "error": NET_ERROR, "code": "NETWORK"}
	if parsed.get("ok") == false and typeof(parsed.get("error")) == TYPE_STRING:
		return _refused(parsed)
	if status != 200 or parsed.get("ok") != true or typeof(parsed.get("username")) != TYPE_STRING or str(parsed["username"]).is_empty():
		return {"ok": false, "error": BAD_REPLY, "code": "RESPONSE", "renew": true}
	return {"ok": true, "username": str(parsed["username"])}

const STATUS_STATES: Array = ["open", "wait", "full", "closed"]
const WAIT_MAX_MS: float = 30.0 * 86400000.0

static func parse_status(result: int, status: int, body: PackedByteArray) -> Dictionary:
	var parsed: Variant = _json(result, body)
	if parsed == null or status != 200 or parsed.get("ok") != true or not STATUS_STATES.has(str(parsed.get("state", ""))):
		return {"ok": false}
	var out: Dictionary = {"ok": true, "state": str(parsed["state"]), "wait_ms": 0, "left": -1, "cap": 0, "quiz": parsed.get("quiz") == true, 
		"regcode": parsed.get("regcode") == true}
	if typeof(parsed.get("left")) == TYPE_FLOAT and typeof(parsed.get("cap")) == TYPE_FLOAT:
		out["cap"] = maxi(0, int(parsed["cap"]))
		out["left"] = clampi(int(parsed["left"]), 0, out["cap"])
	if out["state"] == "wait":
		var at: float = float(parsed.get("openAt", 0)) if typeof(parsed.get("openAt")) == TYPE_FLOAT else 0.0
		var now: float = float(parsed.get("now", 0)) if typeof(parsed.get("now")) == TYPE_FLOAT else 0.0
		if at <= 0.0 or now <= 0.0:
			return {"ok": false}
		out["wait_ms"] = int(clampf(at - now, 1000.0, WAIT_MAX_MS))
	return out


static func _png(b64: Variant, max_bytes: int, max_w: int, max_h: int) -> Image:
	if typeof(b64) != TYPE_STRING or str(b64).is_empty() or str(b64).length() > max_bytes * 4 / 3 + 8:
		return null
	var raw_png: PackedByteArray = Marshalls.base64_to_raw(str(b64))
	var img: Image = Image.new()
	if raw_png.is_empty() or raw_png.size() > max_bytes or img.load_png_from_buffer(raw_png) != OK or img.get_width() > max_w or img.get_height() > max_h:
		return null
	return img


static func _puzzle(z: Variant) -> Dictionary:
	if typeof(z) != TYPE_DICTIONARY or typeof(z.get("cols")) != TYPE_FLOAT or typeof(z.get("rows")) != TYPE_FLOAT:
		return {}
	var cols: int = int(z["cols"])
	var rows: int = int(z["rows"])
	if float(cols) != float(z["cols"]) or float(rows) != float(z["rows"]) or cols < PUZ_CELLS.x or cols > PUZ_CELLS.y or rows < PUZ_CELLS.x or rows > PUZ_CELLS.y:
		return {}
	var img: Image = _png(z.get("img"), PUZ_BYTES, PUZ_W, PUZ_H)
	if img == null or img.get_width() < cols * 8 or img.get_height() < rows * 8:
		return {}
	return {"img": img, "cols": cols, "rows": rows}


static func parse_quiz(result: int, status: int, body: PackedByteArray) -> Dictionary:
	var parsed: Variant = _json(result, body)
	if parsed == null:
		return {"ok": false, "error": NET_ERROR, "code": "NETWORK"}
	if parsed.get("ok") == false and typeof(parsed.get("error")) == TYPE_STRING:
		return _refused(parsed)
	var bad: Dictionary = {"ok": false, "error": BAD_REPLY, "code": "RESPONSE"}
	if status != 200 or parsed.get("ok") != true or typeof(parsed.get("id")) != TYPE_STRING or typeof(parsed.get("items")) != TYPE_ARRAY:
		return bad
	var raw: Array = parsed["items"]
	if raw.is_empty() or raw.size() > 10:
		return bad
	var items: Array = []
	for row: Variant in raw:
		if typeof(row) != TYPE_DICTIONARY:
			return bad
		var puz: Dictionary = {}
		if row.has("z"):
			puz = _puzzle(row["z"])
			if puz.is_empty() or row.has("p"):
				return bad
			if typeof(row.get("q", "")) != TYPE_STRING:
				return bad
			row["q"] = str(row.get("q", ""))
			row["a"] = []
		if typeof(row.get("q")) != TYPE_STRING or typeof(row.get("a")) != TYPE_ARRAY:
			return bad
		var answers: Array = []
		for text: Variant in row["a"]:
			if typeof(text) != TYPE_STRING or str(text).strip_edges().is_empty():
				return bad
			answers.append(str(text).strip_edges().left(60))
		if puz.is_empty() and (answers.size() < 2 or answers.size() > 6 or str(row["q"]).strip_edges().is_empty()):
			return bad
		var pic: Image = null
		if row.has("p"):
			pic = _png(row["p"], PIC_BYTES, PIC_SIDE, PIC_SIDE)
			if pic == null:
				return bad
		var img: Image = null
		if row.has("c"):
			img = Image.new()
			var raw_png: PackedByteArray = Marshalls.base64_to_raw(str(row["c"])) if typeof(row["c"]) == TYPE_STRING else PackedByteArray()
			if raw_png.is_empty() or raw_png.size() > 65536 or img.load_png_from_buffer(raw_png) != OK or img.get_width() > 400 or img.get_height() > 200:
				return bad
		items.append({"s": str(row.get("s", "")).left(30), "q": str(row["q"]).strip_edges().left(240), "a": answers, "img": img})
		if pic != null:
			items[-1]["pic"] = pic
		if not puz.is_empty():
			items[-1]["z"] = puz
	var need: int = clampi(int(parsed.get("pass", items.size())), 1, items.size()) if typeof(parsed.get("pass")) == TYPE_FLOAT else items.size()
	return {"ok": true, "id": str(parsed["id"]), "pass": need, "items": items, 
		"room": str(parsed.get("room", "")).left(16), "lv": clampi(int(parsed.get("lv", 0)), 0, 2) if typeof(parsed.get("lv")) == TYPE_FLOAT else 0}


static func parse_rooms(result: int, status: int, body: PackedByteArray) -> Dictionary:
	var parsed: Variant = _json(result, body)
	if parsed == null:
		return {"ok": false, "error": NET_ERROR, "code": "NETWORK"}
	if parsed.get("ok") == false and typeof(parsed.get("error")) == TYPE_STRING:
		return _refused(parsed)
	if status != 200 or parsed.get("ok") != true or typeof(parsed.get("rooms")) != TYPE_ARRAY:
		return {"ok": false, "error": BAD_REPLY, "code": "RESPONSE"}
	var levels: Array = ["Dễ", "Vừa", "Khó"]
	if typeof(parsed.get("levels")) == TYPE_ARRAY and parsed["levels"].size() == 3:
		for i: int in 3:
			if typeof(parsed["levels"][i]) == TYPE_STRING and not str(parsed["levels"][i]).strip_edges().is_empty():
				levels[i] = str(parsed["levels"][i]).strip_edges().left(8)
	var groups: Array = []
	var known: Dictionary = {}
	if typeof(parsed.get("groups")) == TYPE_ARRAY:
		for grow: Variant in parsed["groups"]:
			if groups.size() >= GROUPS_MAX:
				break
			if typeof(grow) != TYPE_DICTIONARY or typeof(grow.get("g")) != TYPE_STRING or typeof(grow.get("tab")) != TYPE_STRING:
				continue
			var gid: String = str(grow["g"])
			var title: String = str(grow["tab"]).strip_edges().left(16)
			if gid.is_empty() or gid.length() > 16 or known.has(gid) or title.is_empty():
				continue
			known[gid] = 0
			groups.append({"g": gid, "tab": title, "count": int(grow["count"]) if typeof(grow.get("count")) == TYPE_FLOAT else 0, 
				"pass": int(grow["pass"]) if typeof(grow.get("pass")) == TYPE_FLOAT else 0})
	var rooms: Array = []
	var seen: Dictionary = {}
	for row: Variant in parsed["rooms"]:
		if rooms.size() >= 200:
			break
		if typeof(row) != TYPE_DICTIONARY or typeof(row.get("id")) != TYPE_STRING or typeof(row.get("n")) != TYPE_STRING or typeof(row.get("l")) != TYPE_ARRAY:
			continue
		var id: String = str(row["id"])
		var name: String = str(row["n"]).strip_edges().left(28)
		if id.is_empty() or id.length() > 16 or seen.has(id) or name.is_empty() or row["l"].size() != 3:
			continue
		var counts: Array = []
		for c: Variant in row["l"]:
			counts.append(maxi(0, int(c)) if typeof(c) == TYPE_FLOAT else 0)
		if counts[0] + counts[1] + counts[2] <= 0:
			continue
		var grp: String = "game" if row.get("g") == "game" else "hoc"
		if not groups.is_empty():
			grp = str(row.get("g", ""))
			if not known.has(grp):
				continue
			known[grp] += 1
		seen[id] = true
		rooms.append({"id": id, "g": grp, "n": name, "l": counts})
	if rooms.is_empty():
		return {"ok": false, "error": BAD_REPLY, "code": "RESPONSE"}
	var count: int = clampi(int(parsed.get("count", 3)), 1, 10) if typeof(parsed.get("count")) == TYPE_FLOAT else 3
	var need: int = clampi(int(parsed.get("pass", 2)), 1, count) if typeof(parsed.get("pass")) == TYPE_FLOAT else mini(2, count)
	groups = groups.filter( func(g: Dictionary) -> bool: return int(known[g["g"]]) > 0)
	for g: Dictionary in groups:
		g["count"] = clampi(int(g["count"]), 1, 10) if int(g["count"]) > 0 else count
		g["pass"] = clampi(int(g["pass"]), 1, int(g["count"])) if int(g["pass"]) > 0 else mini(need, int(g["count"]))
	var on: Dictionary = {}
	if typeof(parsed.get("on")) == TYPE_DICTIONARY:
		for id: Variant in parsed["on"]:
			var row: Variant = parsed["on"][id]
			if typeof(id) != TYPE_STRING or not seen.has(id) or typeof(row) != TYPE_ARRAY or row.size() != 3:
				continue
			var n: Array = []
			for c: Variant in row:
				n.append(clampi(int(c), 0, 99999) if typeof(c) == TYPE_FLOAT else 0)
			on[id] = n
	var full: Dictionary = {}
	if typeof(parsed.get("full")) == TYPE_DICTIONARY:
		for id: Variant in parsed["full"]:
			var row: Variant = parsed["full"][id]
			if typeof(id) != TYPE_STRING or not seen.has(id) or typeof(row) != TYPE_ARRAY or row.size() != 3:
				continue
			var f: Array = []
			for c: Variant in row:
				f.append(1 if typeof(c) == TYPE_FLOAT and int(c) == 1 else 0)
			full[id] = f
	return {"ok": true, "count": count, "pass": need, "levels": levels, "rooms": rooms, "on": on, "full": full, "groups": groups}


static func parse_check(result: int, status: int, body: PackedByteArray) -> Dictionary:
	var parsed: Variant = _json(result, body)
	if parsed == null:
		return {"ok": false, "error": NET_ERROR, "code": "NETWORK"}
	if parsed.get("ok") == false and typeof(parsed.get("error")) == TYPE_STRING and str(parsed.get("code", "")) == "QUIZ_CAP_RETRY":
		return _cap_retry(parsed)
	if parsed.get("ok") == false and typeof(parsed.get("error")) == TYPE_STRING:
		return _refused(parsed)
	if status != 200 or parsed.get("ok") != true or typeof(parsed.get("pass")) != TYPE_BOOL:
		return {"ok": false, "error": BAD_REPLY, "code": "RESPONSE", "renew": true}
	var out: Dictionary = {"ok": true, "pass": parsed["pass"] == true, "score": maxi(0, int(parsed.get("score", 0))), 
		"need": maxi(1, int(parsed.get("need", 1))), "total": maxi(1, int(parsed.get("total", 1))), "token": "", 
		"wait": clampi(int(parsed.get("wait", 0)) if typeof(parsed.get("wait")) == TYPE_FLOAT else 0, 0, 86400000), 
		"cap_bad": clampi(int(parsed.get("capBad", 0)) if typeof(parsed.get("capBad")) == TYPE_FLOAT else 0, 0, 10)}
	if out["pass"]:
		if typeof(parsed.get("token")) != TYPE_STRING or str(parsed["token"]).is_empty() or str(parsed["token"]).length() > 100:
			return {"ok": false, "error": BAD_REPLY, "code": "RESPONSE", "renew": true}
		out["token"] = str(parsed["token"])
	return out
