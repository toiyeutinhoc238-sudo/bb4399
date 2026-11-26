extends "flash_screen.gd"










const Atlas = preload("gm_option_atlas.gd")
const FriendsAtlas = preload("friends_atlas.gd")
const SCRIPT_PATH: String = "res://ui/gm_option.gd"
const NODE_NAME: String = "GmOption"
const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const ASK_SIZE: Vector2 = Vector2(450, 220)
const ASK_CELLS: Array = ["fr_ask", "fr_ask_guy", "fr_ask_ok", "fr_ask_no"]

var target: String = ""
var _ask: String = ""
var _days: int = 0
var _state: String = ""


static func open_for(host: Control, who: String) -> Control:
	if host == null or host.client == null or host.pack == null or host.get_parent() == null:
		return null
	var parent: Node = host.get_parent()
	var view: Control = parent.get_node_or_null(NODE_NAME) as Control
	if view == null:
		view = load(SCRIPT_PATH).new()
		view.name = NODE_NAME
		view.client = host.client
		view.pack = host.pack
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		parent.add_child(view)
	elif view.visible:
		return null
	view.client = host.client
	view.pack = host.pack
	parent.move_child(view, parent.get_child_count() - 1)
	return view if view.open(who) else null

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)
	var ask: Dictionary = {}
	for cell: String in ASK_CELLS:
		ask[cell] = FriendsAtlas.R[cell]
	_use(FriendsAtlas.FILE, ask)

func open(who: String) -> bool:
	if visible or client == null or who.is_empty() or who == str(client.character.get("name", "")):
		return false
	if int(client.character.get("gm_level", 0)) <= 0:
		return false
	target = who
	_ask = ""
	_days = 0
	_state = client.state
	visible = true
	var view: Viewport = get_viewport()
	if view != null:
		view.gui_release_focus()
	queue_redraw()
	return true

func close() -> void :
	if not visible:
		return
	visible = false
	_ask = ""
	_days = 0
	target = ""


func asking() -> String:
	return _ask

func _tick(_delta: float) -> void :
	if client == null or client.state != _state:
		close()

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var frame: Vector2 = Vector2(float(Atlas.FRAME[0]), float(Atlas.FRAME[1]))
	var at: Vector2 = _centre(frame.x, frame.y)
	_hit("panel", Rect2(at * _f, frame * _f), false)
	_fblit("gmo_frame", at + _xy(Atlas.BODY))
	for i in range(3):
		_fbutton("acc%d" % (i + 1), str(Atlas.FACE[i]), at + _xy(Atlas.AT["btnBanAccount%d" % (i + 1)]))
		_fbutton("chat%d" % (i + 1), str(Atlas.FACE[i]), at + _xy(Atlas.AT["btnBanChat%d" % (i + 1)]))
	_fbutton("close", "gmo_close", at + _xy(Atlas.AT["btnClose"]))
	if not _ask.is_empty():
		_paint_ask()


func _paint_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(ASK_SIZE.x, ASK_SIZE.y)
	_hit("panel", Rect2(at * _f, ASK_SIZE * _f), false)
	_fblit("fr_ask", at + Vector2(46, 1))
	_fblit("fr_ask_guy", at + Vector2(-80, -76))
	_fpara(ask_text(), ARIAL_BOLD, 14, Color.WHITE, at + Vector2(102, 38), 270, 5)
	_fbutton("ask_ok", "fr_ask_ok", at + Vector2(120, 133))
	_fbutton("ask_no", "fr_ask_no", at + Vector2(240, 133))



func ask_text() -> String:
	if _ask.is_empty():
		return ""
	var text: String = str(Atlas.WORDS["ask_chat" if _ask == "chat" else "ask_account"])
	return _first(_first(text, "@name@", target), "@time@", str(_days))


func command() -> String:
	if _ask.is_empty():
		return ""
	return "%s -n %s -t %d" % ["banchat" if _ask == "chat" else "banaccount", target, _days]

static func _first(text: String, key: String, value: String) -> String:
	var at: int = text.find(key)
	return text if at < 0 else text.substr(0, at) + value + text.substr(at + key.length())

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _activate(id: String) -> void :
	if id in ["shade", "panel"]:
		return
	if not _ask.is_empty():
		match id:
			"ask_ok":
				client.send_gm_command(command())
				_ask = ""
				_days = 0
			"ask_no":
				_ask = ""
				_days = 0
		return
	if id == "close":
		close()
	elif id.length() >= 4 and (id.begins_with("acc") or id.begins_with("chat")):
		var n: int = int(id.right(1))
		if n < 1 or n > Atlas.DAYS.size():
			return
		_ask = "account" if id.begins_with("acc") else "chat"
		_days = int(Atlas.DAYS[n - 1])

func _input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree() or not (event is InputEventKey):
		return
	var key: InputEventKey = event
	if key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
		if not _ask.is_empty():
			_ask = ""
			_days = 0
		else:
			close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
