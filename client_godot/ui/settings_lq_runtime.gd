extends CanvasLayer





const Settings = preload("res://settings.gd")
const QuickPing = preload("res://battle/quick_ping.gd")
const BATTLE_VIEW: String = "res://battle/battle_view.gd"

static var _shared: WeakRef = null

var _shade: ColorRect

static func shared() -> Node:
	return _shared.get_ref() if _shared != null else null


static func ensure(from: Node) -> Node:
	var node: Node = shared()
	if node == null:
		node = new()
		_shared = weakref(node)
		if from != null and from.is_inside_tree():
			from.get_tree().root.add_child.call_deferred(node)
	return node

func _init() -> void :
	name = "SettingsLqRuntime"
	layer = 128
	_shade = ColorRect.new()
	_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_shade.visible = false
	add_child(_shade)
	Settings.watch(_changed)
	apply()


func _ready() -> void :
	get_tree().node_added.connect(_node_added)
	for node: Node in get_tree().root.find_children("*", "Control", true, false):
		_node_added(node)

func _node_added(node: Node) -> void :
	if node is Control and node.get_script() != null and (node.get_script() as Script).resource_path == BATTLE_VIEW\
	and (load("res://ui/settings_lq.gd") as GDScript).call("wanted"):
		QuickPing.attach.call_deferred(node)

func _changed(key: String) -> void :
	if key.is_empty() or key in ["tc_bright", "master_vol"]:
		apply()


func apply() -> void :
	var bright: int = int(Settings.value("tc_bright"))
	if bright < 100:
		_shade.material = null
		_shade.color = Color(0, 0, 0, float(100 - bright) / 100.0 * 1.2)
		_shade.visible = true
	elif bright > 100:
		if _shade.material == null:
			var mat: CanvasItemMaterial = CanvasItemMaterial.new()
			mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
			_shade.material = mat
		_shade.color = Color(1, 1, 1, float(bright - 100) / 100.0 * 0.5)
		_shade.visible = true
	else:
		_shade.visible = false
	var vol: int = int(Settings.value("master_vol"))
	AudioServer.set_bus_mute(0, vol <= 0)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(0.0001, vol / 100.0)) if vol > 0 else -80.0)

func shade() -> ColorRect:
	return _shade
