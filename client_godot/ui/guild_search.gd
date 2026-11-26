extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")








const Arena = preload("arena_atlas.gd")
const Join = preload("guild_join_atlas.gd")

signal closed(note: String)
signal found(data: Dictionary)

const FRAME: Vector2 = Vector2(358, 258)
const PATH: String = "/cGuildInfo.php?gn=%s&noCache=%s"
const NOT_FOUND: String = "Guild không tồn tại"

var fetch: Callable
var _name: LineEdit
var _http: HTTPRequest
var _waiting: bool = false
var _focus_due: bool = false

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Arena.FILE, {"public_button_close": Arena.R["public_button_close"]})
	_use(Join.FILE, {"gj_find": Join.R["gj_find"], "gj_ok": Join.R["gj_ok"]})
	_name = _fedit(0)
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		on_reply(result, code, body))

func open() -> void :
	_toast = ""
	_hover = ""
	_press = ""
	_name.text = ""
	_waiting = false
	_focus_due = true
	visible = true

func close(note: String = "") -> void :
	if not visible:
		return
	visible = false
	_focus_due = false
	_waiting = false
	if _http != null:
		_http.cancel_request()
	_hide_edits()
	closed.emit(note)

func chat_busy() -> bool:
	return visible



func _activate(id: String) -> void :
	match id:
		"cancel":
			close("")
		"confirm":
			_request()


func _request() -> void :
	if _waiting or client == null:
		return
	var origin: String = str(client.config.origin)
	if origin.is_empty() and not fetch.is_valid():
		return
	var url: String = origin + PATH % [_name.text.uri_encode(), str(randf())]
	_waiting = true
	var done: int
	if fetch.is_valid():
		done = int(fetch.call(url))
	else:
		_http.cancel_request()
		done = _http.request(url, AppSession.headers(url))
	if done != OK:
		_waiting = false


func on_reply(result: int, code: int, body: PackedByteArray) -> void :
	if not _waiting:
		return
	_waiting = false
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var text: String = body.get_string_from_utf8()
	if text.strip_edges().is_empty():
		say(NOT_FOUND)
		return
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return
	if not (json.data is Dictionary) or int((json.data as Dictionary).get("nGuildId", 0)) <= 0:
		say(NOT_FOUND)
		return
	var data: Dictionary = json.data
	close("")
	found.emit(data)

func _input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()



func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(FRAME.x, FRAME.y)
	_hit("panel", Rect2(at * _f, FRAME * _f), false)
	_fblit("gj_find", at)
	_fput(_name, Rect2(at + Vector2(74, 112) + Vector2(15, 3), Vector2(190, 29)), 16)
	_fbutton("confirm", "gj_ok", at + Vector2(119, 206))
	_fbutton("cancel", "public_button_close", at + Vector2(319, 15))
	if _focus_due:
		_focus_due = false
		_name.grab_focus.call_deferred()
