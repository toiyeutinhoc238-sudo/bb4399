extends Node












const QuitAsk = preload("quit_ask.gd")

const OFF_STATES: Array = ["", "login", "auth"]
const SOLO_ASK: bool = true
const LAYER: int = 126

const GUARD_JS: String = "(function(){var w=window;if(w.__bbExit)return;var s={on:false,free:0};"\
+ "w.__bbExit={on:function(v){s.on=!!v;},leave:function(){s.free=Date.now()+10000;},"\
+ "state:function(){return (s.on?1:0)+','+(Date.now()<s.free?1:0);}};"\
+ "w.addEventListener('beforeunload',function(e){if(!s.on||Date.now()<s.free)return;e.preventDefault();e.returnValue=true;});"\
+ "document.addEventListener('click',function(e){try{var a=e.target&&e.target.closest&&e.target.closest('a[href]');"\
+ "if(a&&!/^https?:$/.test(a.protocol))s.free=Math.max(s.free,Date.now()+1500);}catch(x){}},true);})()"

static var _users: int = 0

var client = null
var pack = null
var battle_view = null
var host = null
var quit_fn: Callable = Callable()
var dialog: Control = null
var _layer: CanvasLayer = null
var _web: bool = OS.has_feature("web")
var _native: bool = false
var _on: int = -1





const QT1_GROUP: String = "qt1_quit"
static var qt1_busy: bool = false
static var qt1_force: String = ""
static var qt1_hide_fn: Callable = Callable()

func _enter_tree() -> void :
	if _web or _native:
		return
	_native = true
	_users += 1
	get_tree().set_auto_accept_quit(false)
	get_tree().set_quit_on_go_back(false)

func _ready() -> void :
	if not _web:
		return
	JavaScriptBridge.eval(GUARD_JS, true)
	if client != null:
		client.changed.connect(_follow)
	_follow()

func _exit_tree() -> void :
	if _native:
		_native = false
		_users = maxi(0, _users - 1)
		if _users == 0:
			get_tree().set_auto_accept_quit(true)
			get_tree().set_quit_on_go_back(true)
	if _web and _on == 1:
		JavaScriptBridge.eval("window.__bbExit&&window.__bbExit.on(false)", true)
	_on = -1
	if _layer != null and is_instance_valid(_layer):
		_layer.queue_free()
	_layer = null
	dialog = null


func _follow() -> void :
	var on: int = 0 if client == null or str(client.state) in OFF_STATES else 1
	if on == _on:
		return
	_on = on
	JavaScriptBridge.eval("window.__bbExit&&window.__bbExit.on(%s)" % ("true" if on == 1 else "false"), true)

func _notification(what: int) -> void :
	if not _native:
		return
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:

		back_pressed.call_deferred(_editor_open())
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		close_requested.call_deferred()

func _editor_open() -> bool:
	for node: Node in get_tree().root.get_children():
		if node.name == "TouchLayoutEditor":
			return true
	return false



func back_pressed(editor: bool = false) -> void :
	if not is_inside_tree():
		return
	if dialog != null and dialog.visible:
		dialog.close()
		return
	if editor:
		return
	if client != null and str(client.state) == "battle" and battle_view != null:
		_battle_back()
		return
	var page: Variant = host.get("_page") if host != null else ""
	var before: Array = _state()
	if _esc() or _state() != before:
		return
	if page != null and not str(page).is_empty():
		return
	open_dialog()

func _battle_back() -> void :
	var ask = battle_view.get("exit_ask")
	if ask != null and ask.visible:
		ask.close()
		return
	var before: Array = _state()
	if _esc() or _state() != before:
		return
	var board = battle_view.get("score_board")
	if board != null and board.visible:
		board.hide_board()
		return
	var battle = client.battle
	if not battle.active or battle.ended or ask == null:
		return
	if battle.look or not SOLO_ASK:
		battle_view.ask_exit()
		return
	battle_view.controls.clear()
	ask.ask()


func _state() -> Array:
	var shown: PackedInt64Array = PackedInt64Array()
	_shown(get_tree().root, shown)
	var out: Array = [shown, str(client.state) if client != null else ""]
	if host != null:
		out.append(host.get("_page"))
		out.append(host.get("_return"))
	if battle_view != null:
		var hud = battle_view.get("_hud")
		out.append(hud.get("armed") if hud != null else null)
	return out

func _shown(node: Node, out: PackedInt64Array) -> void :
	if node.is_queued_for_deletion():
		return
	if node is CanvasItem and not (node as CanvasItem).visible:
		return
	if node is CanvasLayer and not (node as CanvasLayer).visible:
		return
	if node is Window and node != get_tree().root and not (node as Window).visible:
		return
	out.append(node.get_instance_id())
	for child: Node in node.get_children():
		_shown(child, out)


func _esc() -> bool:
	var viewport: Viewport = get_viewport()
	var handled: bool = false
	for down: bool in [true, false]:
		var key: InputEventKey = InputEventKey.new()
		key.keycode = KEY_ESCAPE
		key.physical_keycode = KEY_ESCAPE
		key.pressed = down
		viewport.push_input(key)
		if down:
			handled = viewport.is_input_handled()
	return handled


func open_dialog() -> void :
	if not is_inside_tree():
		return
	if dialog == null or not is_instance_valid(dialog):
		_layer = CanvasLayer.new()
		_layer.name = "QuitAsk"
		_layer.layer = LAYER
		_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		dialog = QuitAsk.new()
		dialog.name = "Ask"
		dialog.client = client
		dialog.pack = pack
		dialog.answered.connect(_answered)
		_layer.add_child(dialog)
		get_tree().root.add_child(_layer)
	elif _layer.get_parent() == get_tree().root:
		get_tree().root.move_child(_layer, -1)
	if battle_view != null and client != null and str(client.state) == "battle":
		battle_view.controls.clear()
	dialog.open()

func _answered(ok: bool) -> void :
	if ok:
		_quit()

func _quit() -> void :
	quit_app(get_tree(), quit_fn)


static func quit_app(tree: SceneTree, fn: Callable = Callable()) -> void :
	if tree == null:
		return
	var kind: String = qt1_kind()
	if kind == "web":
		if fn.is_valid():
			fn.call()
		else:
			tree.quit()
		return
	if qt1_busy:
		return
	qt1_busy = true
	var muted: bool = AudioServer.is_bus_mute(0)
	_qt1_hide(kind)
	tree.call_group(QT1_GROUP, "quit_flush")
	await tree.process_frame
	if not fn.is_valid():
		tree.quit()
		return
	fn.call()
	qt1_busy = false
	if not qt1_hide_fn.is_valid():
		AudioServer.set_bus_mute(0, muted)

static func qt1_kind() -> String:
	if not qt1_force.is_empty():
		return qt1_force
	if OS.has_feature("web"):
		return "web"
	return "mobile" if OS.has_feature("android") or OS.has_feature("ios") else "pc"


static func _qt1_hide(kind: String) -> void :
	if qt1_hide_fn.is_valid():
		qt1_hide_fn.call(kind)
		return
	AudioServer.set_bus_mute(0, true)
	if kind != "pc" or DisplayServer.get_name() == "headless":
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)


func close_requested() -> void :
	if not is_inside_tree():
		return
	if client == null or str(client.state) in OFF_STATES:
		_quit()
		return
	open_dialog()
