extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")
















const Ask = preload("exitask_atlas.gd")
const PopQueue = preload("pop_queue.gd")

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const TEXT: String = "HĐ @name@ đã bắt đầu, mau đi tham gia!"
const ACTS_PATH: String = "/xml/ActivityTemplate_table.xml"
const SKIP_TYPES: Array = [14, 16]
const BUSY_STATES: Array = ["battle", "room"]
const OPEN_IN: Array = ["lobby", "hall"]

const NAMES: Dictionary = {"热血激战": "Đấu Trường", "毁灭者": "Kẻ Hủy Diệt", "战队排位赛": "Xếp hạng Team", "全民火力赛": "Đấu Hỏa Lực", 
	"火球赛": "Đấu Cầu Lửa"}
const GUTTER: float = 2.0

var queue: Node = null
var templates: Dictionary = {}
var _list: Array = []
var _notified: Dictionary = {}
var _act_rev: int = -1
var _delay: int = 0
var _later: Array = []
var _shown_id: int = 0
var _http: HTTPRequest
var _asked: bool = false
var _clock: Timer

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_use(Ask.FILE, Ask.R)
	_clock = Timer.new()
	_clock.wait_time = 1.0
	_clock.autostart = true
	add_child(_clock)
	_clock.timeout.connect(tick)
	if client != null:
		client.changed.connect(_follow)


func read_templates(body: PackedByteArray) -> bool:
	var parser: XMLParser = XMLParser.new()
	if body.is_empty() or parser.open_buffer(body) != OK:
		return false
	var out: Dictionary = {}
	var row: Dictionary = {}
	var field: String = ""
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node: String = parser.get_node_name()
				if node == "entry":
					row = {}
					field = ""
				elif not parser.is_empty():
					field = node
			XMLParser.NODE_TEXT, XMLParser.NODE_CDATA:
				if not field.is_empty():
					row[field] = str(row.get(field, "")) + parser.get_node_data()
			XMLParser.NODE_ELEMENT_END:
				var node: String = parser.get_node_name()
				if node == "entry":
					var id: int = int(str(row.get("nId", "0")))
					if id > 0:
						out[id] = {"name": str(row.get("szName", "")).strip_edges(), "type": int(str(row.get("nType", "0"))), 
							"level": int(str(row.get("nLevel", "0"))), "hide": str(row.get("isHide", "0")).strip_edges() == "1"}
					row = {}
					field = ""
				elif node == field:
					field = ""
	if out.is_empty():
		return false
	templates = out
	_act_rev = -1
	_follow()
	return true

func _fetch() -> void :
	if _asked or _http != null or client == null or not (OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("pc_app") or ( not OS.has_feature("editor") and DisplayServer.get_name() != "headless")):
		return
	_asked = true
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		_asked = result == HTTPRequest.RESULT_SUCCESS and code == 200 and read_templates(body)
		_http.queue_free()
		_http = null)
	var url: String = client.config.origin + ACTS_PATH
	if _http.request(url, AppSession.headers(url)) != OK:
		_http.queue_free()
		_http = null
		_asked = false


static func act_name(raw: String) -> String:
	if NAMES.has(raw):
		return str(NAMES[raw])
	for i in range(raw.length()):
		var code: int = raw.unicode_at(i)
		if (code >= 13312 and code <= 40959) or (code >= 63744 and code <= 64255):
			return ""
	return raw

func message() -> String:
	var info: Dictionary = templates.get(_shown_id, {})
	return TEXT.replace("@name@", act_name(str(info.get("name", ""))))


func _started(id: int) -> bool:
	if client == null or not client.acts.has(id):
		return false
	var info: Variant = client.acts[id]
	return info is Array and (info as Array).size() >= 3 and int(info[2]) != 3 and client.act_now_state(id) == 2

func _busy() -> bool:
	if client == null:
		return true
	if client.state in BUSY_STATES or client.battle.active or not client.pair_scene.is_empty():
		return true
	if PopQueue.held():
		return true
	return client.state not in OPEN_IN or (queue != null and bool(queue.get("hold")))


func _flush_later() -> void :
	while not _later.is_empty() and not visible and not _busy():
		var id: int = int(_later.pop_front())
		if _started(id):
			offer(id)


func _follow() -> void :
	if client == null:
		return
	if client.state not in OPEN_IN and client.state not in BUSY_STATES:
		_list.clear()
		_notified.clear()
		_delay = 0
		_later.clear()
		if visible:
			_close()
		return
	_fetch()
	if client.act_rev != _act_rev and not templates.is_empty():
		_act_rev = client.act_rev
		for id: int in client.acts:
			if templates.has(id) and not _list.has(id) and not _notified.has(id):
				_list.append(id)
	if _delay != 0 and not _busy():
		var id: int = _delay
		_delay = 0
		offer(id)
	_flush_later()


func tick() -> void :
	if client == null:
		return
	if visible and not _started(_shown_id):
		_close()
	if visible and PopQueue.held():
		if not _later.has(_shown_id):
			_later.push_front(_shown_id)
		_close()
	for id: int in _notified.keys():
		if not _started(id):
			_notified.erase(id)
			if templates.has(id) and not _list.has(id):
				_list.append(id)
	var keep: Array = []
	for id: int in _list:
		if _started(id):
			_notified[id] = true
			offer(id)
		else:
			keep.append(id)
	_list = keep
	_flush_later()


func offer(id: int) -> void :
	var info: Dictionary = templates.get(id, {})
	if info.is_empty() or bool(info.hide) or int(info.type) in SKIP_TYPES or not _started(id):
		return
	if int(client.character.get("level", 0)) < int(info.level) or act_name(str(info.name)).is_empty():
		return
	if PopQueue.held():
		if not _later.has(id) and id != _shown_id:
			_later.append(id)
		return
	if _busy():
		_delay = id
		return
	_shown_id = id
	if not visible:
		visible = true
		_toast = ""
	queue_redraw()

func _close() -> void :
	visible = false
	_shown_id = 0

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(float(Ask.SIZE[0]), float(Ask.SIZE[1]))
	var frame: Vector2 = at + _xy(Ask.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("xa_frame") * _f), false)
	_fblit("xa_frame", frame)
	var body: Array = Ask.TEXTS["txtContent"]
	_fpara(message(), ARIAL_BOLD, float(body[4]), Color(str(body[5])), at + _xy(body) + Vector2(GUTTER, 0.0), float(body[2]) - GUTTER * 2.0)
	_fbutton("ok", "xa_ok", at + _xy(Ask.NODES["btnConfirm"]))
	_fbutton("no", "xa_no", at + _xy(Ask.NODES["btnCancel"]))
	_fblit("xa_guy", at + _xy(Ask.GUY))

func _activate(id: String) -> void :
	if id == "ok":
		var type: int = int(templates.get(_shown_id, {}).get("type", 0))
		_close()
		page_asked.emit("fair:center:%d" % type)
	elif id == "no":
		_close()

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
