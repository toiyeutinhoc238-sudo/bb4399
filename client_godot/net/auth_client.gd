extends Node
signal completed(result: Dictionary)

const AndroidVoice = preload("res://net/android_voice.gd")
const PcVoice = preload("res://net/pc_voice.gd")
const AppSession = preload("res://net/app_session.gd")
const DeviceId = preload("res://net/device_id.gd")

static var client_instance: String = Crypto.new().generate_random_bytes(16).hex_encode()
var _request: HTTPRequest
var _origin: String = ""

func _ready() -> void :
	DeviceId.warm()

func login(origin: String, username: String, password: String, access_key: String) -> void :
	cancel()
	_origin = origin
	_request = HTTPRequest.new()
	_request.accept_gzip = not OS.has_feature("web")
	_request.timeout = 12.0
	_request.body_size_limit = 65536
	_request.max_redirects = 0
	add_child(_request)
	_request.request_completed.connect(_on_response.bind(_request))
	var payload: Dictionary = {"username": username, "password": password}
	if not access_key.is_empty():
		payload["key"] = access_key
	var dev: Dictionary = DeviceId.wire()
	if not dev.is_empty():
		payload["dev"] = dev
	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json", "X-Client-Instance: " + client_instance])
	var result: Error = _request.request(origin + "/api/auth", headers, HTTPClient.METHOD_POST, JSON.stringify(payload))

	payload.clear()
	if result != OK:
		cancel()
		completed.emit({"ok": false, "error": "Không bắt đầu đăng nhập được.", "code": "NETWORK"})


func resume(origin: String, ticket: String, access_key: String) -> void :
	cancel()
	_origin = origin
	_request = HTTPRequest.new()
	_request.accept_gzip = not OS.has_feature("web")
	_request.timeout = 12.0
	_request.body_size_limit = 65536
	_request.max_redirects = 0
	add_child(_request)
	_request.request_completed.connect(_on_response.bind(_request))
	var payload: Dictionary = {"resume": ticket}
	if not access_key.is_empty():
		payload["key"] = access_key
	var dev: Dictionary = DeviceId.wire()
	if not dev.is_empty():
		payload["dev"] = dev
	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json", "X-Client-Instance: " + client_instance])
	var result: Error = _request.request(origin + "/api/auth", headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	payload.clear()
	if result != OK:
		cancel()
		completed.emit({"ok": false, "error": "Không kết nối lại được.", "code": "NETWORK"})


static func resume_shape(ticket: String) -> bool:
	if ticket.length() < 40 or ticket.length() > 64:
		return false
	for c: String in ticket:
		if not (c >= "A" and c <= "Z" or c >= "a" and c <= "z" or c >= "0" and c <= "9" or c == "-" or c == "_"):
			return false
	return true

func _on_response(result: int, status: int, headers: PackedStringArray, body: PackedByteArray, source: HTTPRequest) -> void :
	if source != _request:
		return
	cancel()
	var done: Dictionary = parse_response(result, status, body)
	if done.get("ok") == true and AndroidVoice.is_android():


		AndroidVoice.set_session(_origin, AndroidVoice.session_from_headers(headers))
	elif done.get("ok") == true and PcVoice.is_pc():

		PcVoice.set_session(_origin, AndroidVoice.session_from_headers(headers))
	if done.get("ok") == true:
		AppSession.set_session(_origin, AndroidVoice.session_from_headers(headers))
		AppSession.logged_in()
	completed.emit(done)


static func forget_voice() -> void :
	AndroidVoice.shutdown()
	PcVoice.shutdown()
	AppSession.forget()

func parse_response(result: int, status: int, body: PackedByteArray) -> Dictionary:
	if result != HTTPRequest.RESULT_SUCCESS:
		return {"ok": false, "error": "Không kết nối được máy chủ đăng nhập.", "code": "NETWORK"}
	var json: JSON = JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		return {"ok": false, "error": "Máy chủ trả lời đăng nhập không hợp lệ.", "code": "RESPONSE"}
	var parsed: Variant = json.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Máy chủ trả lời đăng nhập không hợp lệ.", "code": "RESPONSE"}
	if parsed.get("ok") == false and typeof(parsed.get("error")) == TYPE_STRING:
		return {"ok": false, "error": parsed["error"], "code": str(parsed.get("code", ""))}
	if status != 200 or parsed.get("ok") != true or typeof(parsed.get("account")) != TYPE_DICTIONARY:
		return {"ok": false, "error": "Máy chủ trả lời đăng nhập không hợp lệ.", "code": "RESPONSE"}
	var account: Dictionary = parsed["account"]
	if typeof(parsed.get("authToken")) != TYPE_STRING or str(parsed["authToken"]).is_empty() or typeof(account.get("username")) != TYPE_STRING or str(account["username"]).is_empty():
		return {"ok": false, "error": "Máy chủ trả lời đăng nhập thiếu dữ liệu.", "code": "RESPONSE"}

	var display_name: String = account.get("name", "") if typeof(account.get("name")) == TYPE_STRING else ""
	if display_name.is_empty():
		display_name = account["username"]
	var done: Dictionary = {"ok": true, "authToken": parsed["authToken"], "account": {
		"username": account["username"], "name": display_name}}
	var ticket: Variant = parsed.get("resumeToken")
	if typeof(ticket) == TYPE_STRING and resume_shape(ticket):
		done["resumeToken"] = ticket
	return done

func cancel() -> void :
	if is_instance_valid(_request):
		_request.cancel_request()
		_request.queue_free()
	_request = null
