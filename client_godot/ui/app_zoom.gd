extends Node












const Settings = preload("../settings.gd")
const BrowserZoom = preload("browser_zoom.gd")
const PcMouse = preload("pc_mouse.gd")

const KEY: String = "pc_zoom"
const LEVELS: Array[int] = [50, 67, 75, 80, 90, 100, 110, 125, 150]
const TOAST_HOLD: float = 1.2

var client = null
var _layer: CanvasLayer = null
var _toast: PanelContainer = null
var _label: Label = null
var _tw: Tween = null
var _applied: int = 0
var toasts: Array = []


static func active() -> bool:
	return PcMouse.app() and not DisplayServer.is_touchscreen_available()

static func level() -> int:
	return int(Settings.value(KEY))


static func step(cur: int, dir: int) -> int:
	var i: int = LEVELS.find(cur)
	if i < 0:
		i = LEVELS.find(100)
	return LEVELS[clampi(i + dir, 0, LEVELS.size() - 1)]

static func text(lvl: int) -> String:
	return "Thu phóng %d %%" % lvl


static func set_level(lvl: int) -> void :
	var z: float = float(lvl) / 100.0
	BrowserZoom.z = z
	BrowserZoom.base = os_scale(DisplayServer.screen_get_dpi() if OS.get_name() == "Windows" else 0)
	Settings.dpr_mul = z
	Settings.css_floor = BrowserZoom.floor_for(1.0) if z < 1.0 else 1.0




static func os_scale(dpi: int) -> float:
	return clampf(float(dpi) / 96.0, 1.0, 3.0) if dpi > 0 else 1.0


static func clear() -> void :
	BrowserZoom.z = 1.0
	BrowserZoom.base = 0.0
	Settings.dpr_mul = 1.0
	Settings.css_floor = 1.0

func _ready() -> void :
	if not active():
		return
	get_window().content_scale_factor = 1.0
	_layer = CanvasLayer.new()
	_layer.layer = 120
	add_child(_layer)
	_toast = PanelContainer.new()
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(0.03, 0.07, 0.12, 0.86)
	box.border_color = Color("29c6d6")
	box.set_border_width_all(1)
	box.set_corner_radius_all(6)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 5
	box.content_margin_bottom = 6
	_toast.add_theme_stylebox_override("panel", box)
	_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.modulate.a = 0.0
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 15)
	_label.add_theme_color_override("font_color", Color("e7eef2"))
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_toast.add_child(_label)
	_layer.add_child(_toast)
	Settings.watch(_changed)
	_apply(false)

func _exit_tree() -> void :
	if _applied != 0:
		clear()
		_applied = 0

func _changed(key: String) -> void :
	if key == KEY or key == "":
		_apply(true)

func _apply(show: bool) -> void :
	var lvl: int = level()
	if lvl == _applied:
		return
	_applied = lvl
	set_level(lvl)
	var tree: SceneTree = get_tree()
	if tree != null and tree.root != null:
		tree.root.propagate_call("queue_redraw")
	if show:
		_show(text(lvl))

func _show(msg: String) -> void :
	toasts.append(msg)
	if _toast == null:
		return
	_label.text = msg
	_toast.reset_size()
	var view: Vector2 = get_viewport().get_visible_rect().size
	_toast.position = Vector2(roundf((view.x - _toast.size.x) / 2.0), 46.0)
	if _tw != null and _tw.is_valid():
		_tw.kill()
	_tw = create_tween()
	_tw.tween_property(_toast, "modulate:a", 1.0, 0.12)
	_tw.tween_interval(TOAST_HOLD)
	_tw.tween_property(_toast, "modulate:a", 0.0, 0.35)


func nudge(dir: int) -> void :
	var lvl: int = 100 if dir == 0 else step(level(), dir)
	if lvl == level():
		_show(text(lvl))
		return
	Settings.put(KEY, lvl)

func _in_battle() -> bool:
	return client != null and str(client.state) == "battle"

func _input(event: InputEvent) -> void :
	if not active():
		return
	var dir: int = 2
	var key: InputEventKey = event as InputEventKey
	if key != null:
		if not key.pressed or not key.ctrl_pressed or key.alt_pressed:
			return
		var codes: Array = [key.keycode, key.physical_keycode]
		if codes.has(KEY_MINUS) or codes.has(KEY_KP_SUBTRACT):
			dir = -1
		elif codes.has(KEY_EQUAL) or codes.has(KEY_PLUS) or codes.has(KEY_KP_ADD):
			dir = 1
		elif codes.has(KEY_0) or codes.has(KEY_KP_0):
			dir = 0
	var wheel: InputEventMouseButton = event as InputEventMouseButton
	if wheel != null:
		if not wheel.pressed or not wheel.ctrl_pressed or _in_battle():
			return
		if wheel.button_index == MOUSE_BUTTON_WHEEL_UP:
			dir = 1
		elif wheel.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			dir = -1
	if dir == 2:
		return
	nudge(dir)
	var viewport: Viewport = get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()
