extends Node








const MARGIN: float = 12.0
const SPEED: float = 14.0
const JS: String = "(function(w){try{var v=w.visualViewport;return v?Math.max(0,w.innerHeight-v.height-v.offsetTop)+','+w.innerHeight:'0,'+w.innerHeight}catch(e){return ''}})(window)"

static var made: bool = false

var lift: float = 0.0
var _focus: Control = null
var _base_h: int = 0


static func ensure(from: Node) -> void :
	if made or not from.is_inside_tree():
		return
	made = true
	var keys: Node = (load("res://ui/touch_keys.gd") as GDScript).new()
	keys.name = "TouchKeys"
	from.get_tree().root.add_child.call_deferred(keys)

func _ready() -> void :
	get_viewport().gui_focus_changed.connect(_focused)

func _focused(control: Control) -> void :
	_focus = control if (control is LineEdit or control is TextEdit) and not _battle(control) else null
	_base_h = DisplayServer.window_get_size().y

func _battle(control: Node) -> bool:
	var scene: Node = get_tree().current_scene
	if scene != null and bool(scene.get("_in_battle")):
		return true
	var node: Node = control
	while node != null:
		var script: Variant = node.get_script()
		if script is Script and (script as Script).resource_path.contains("/battle/"):
			return true
		node = node.get_parent()
	return false


func keyboard() -> float:
	var view: float = get_viewport().get_visible_rect().size.y
	if OS.has_feature("web"):
		var raw: Variant = JavaScriptBridge.eval(JS, true)
		var parts: PackedStringArray = str(raw).split(",")
		if parts.size() != 2 or float(parts[1]) <= 0.0:
			return 0.0
		return maxf(0.0, float(parts[0])) * view / float(parts[1])
	var window: int = DisplayServer.window_get_size().y
	if window <= 0:
		return 0.0
	var px: int = DisplayServer.virtual_keyboard_get_height() - maxi(0, _base_h - window)
	return maxf(0.0, float(px)) * view / float(window)


static func want(edit: Rect2, view: float, kb: float) -> float:
	if kb <= 0.0:
		return 0.0
	var need: float = edit.end.y + MARGIN - (view - kb)
	return clampf(need, 0.0, maxf(0.0, edit.position.y - MARGIN))

func _process(delta: float) -> void :
	var target: float = 0.0
	if _focus != null and is_instance_valid(_focus) and _focus.is_visible_in_tree() and _focus.has_focus():
		target = want(_focus.get_global_rect(), get_viewport().get_visible_rect().size.y, keyboard())
	if absf(target - lift) < 0.5:
		lift = target
	else:
		lift = lerpf(lift, target, 1.0 - exp( - SPEED * delta))
	var shift: Transform2D = Transform2D(0.0, Vector2(0.0, - roundf(lift)))
	if get_viewport().canvas_transform != shift:
		get_viewport().canvas_transform = shift
