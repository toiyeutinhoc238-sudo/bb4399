extends Node

















const JS: String = "(function(w){if(w.__bbPaste)return 1;var st={arm:false,cb:null,mac:/Mac|iPhone|iPad|iPod/.test((w.navigator&&w.navigator.platform)||'')};"\
+ "function own(e){var t=e.target,n=t&&t.tagName?String(t.tagName).toUpperCase():'';return n!=='INPUT'&&n!=='TEXTAREA';}"\
+ "w.addEventListener('keydown',function(e){if(!st.arm||!st.cb||e.altKey||!own(e))return;"\
+ "var v=(e.code==='KeyV'||String(e.key||'').toLowerCase()==='v')&&(st.mac?(e.metaKey&&!e.ctrlKey):(e.ctrlKey&&!e.metaKey));"\
+ "var ins=e.code==='Insert'&&e.shiftKey&&!e.ctrlKey&&!e.metaKey;if(v||ins)e.stopImmediatePropagation();},true);"\
+ "w.addEventListener('paste',function(e){if(!st.arm||!st.cb||!own(e))return;var d=e.clipboardData||w.clipboardData;"\
+ "var s=d?(d.getData('text/plain')||d.getData('text')||''):'';e.preventDefault();try{st.cb(s);}catch(x){}},true);"\
+ "w.__bbPaste=st;return 1;})(window)"

var live: bool = false
var armed: bool = false
var _st: JavaScriptObject = null
var _cb: JavaScriptObject = null

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.has_feature("web") and not live:
		JavaScriptBridge.eval(JS, true)
		_st = JavaScriptBridge.get_interface("__bbPaste")
		if _st != null:
			_cb = JavaScriptBridge.create_callback( func(args: Array) -> void : paste_now(str(args[0]) if args.size() > 0 else ""))
			_st.set("cb", _cb)
			live = true
	if not live:
		return
	get_tree().node_added.connect(_on_node_added)
	for type: String in ["LineEdit", "TextEdit"]:
		for node: Node in get_tree().root.find_children("*", type, true, false):
			_hook_menu(node)

func _process(_delta: float) -> void :
	if not live:
		return
	var want: bool = wants(get_viewport().gui_get_focus_owner())
	if want != armed:
		armed = want
		if _st != null:
			_st.set("arm", want)

func _input(event: InputEvent) -> void :
	if live and armed and event is InputEventKey and event.is_pressed() and event.is_action("ui_paste", true):
		get_viewport().set_input_as_handled()


func paste_now(text: String) -> bool:
	return paste_into(get_viewport().gui_get_focus_owner(), text)

static func wants(node: Node) -> bool:
	if node is LineEdit:
		return (node as LineEdit).editable and (node as LineEdit).is_visible_in_tree()
	if node is TextEdit:
		return (node as TextEdit).editable and (node as TextEdit).is_visible_in_tree()
	return false


static func paste_into(node: Node, text: String) -> bool:
	if node is LineEdit:
		var edit: LineEdit = node
		var clean: String = text.strip_escapes()
		if not edit.editable or clean.is_empty():
			return false
		var before: String = edit.text
		if edit.has_selection():
			var from: int = edit.get_selection_from_column()
			var to: int = edit.get_selection_to_column()
			edit.deselect()
			edit.delete_text(from, to)
			edit.caret_column = from
		edit.insert_text_at_caret(clean)
		if edit.text != before:
			edit.text_changed.emit(edit.text)
		return true
	if node is TextEdit:
		var box: TextEdit = node
		var body: String = text.replace("\r", "")
		if not box.editable or body.is_empty():
			return false
		box.insert_text_at_caret(body)
		return true
	return false

func _on_node_added(node: Node) -> void :
	if node is LineEdit or node is TextEdit:
		_hook_menu.call_deferred(node)

func _hook_menu(node: Node) -> void :
	if not is_instance_valid(node) or node.has_meta("gc1_menu") or not bool(node.get("context_menu_enabled")):
		return
	node.set_meta("gc1_menu", true)
	var menu: PopupMenu = node.call("get_menu")
	if menu != null:
		menu.about_to_popup.connect( func() -> void :
			var _primed: String = DisplayServer.clipboard_get())
