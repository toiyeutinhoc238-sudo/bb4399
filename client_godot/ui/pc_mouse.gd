extends Node






const Settings = preload("../settings.gd")

const KEY: String = "pc_mouse_lock"
const CLOSE_HOLD_MS: int = 1500

static var force_app: int = -1

var client = null
var apply_mode: Callable = Callable()
var clock: Callable = Callable()
var focused: bool = true
var held: bool = false
var _hold_until: int = 0

static func app() -> bool:
	if force_app >= 0:
		return force_app == 1
	return OS.has_feature("pc_app") or ( not OS.has_feature("web") and not OS.has_feature("android") and not OS.has_feature("ios") and not OS.has_feature("editor"))

func _ready() -> void :
	var window: Window = get_window()
	if window != null:
		window.focus_exited.connect(_focus.bind(false))
		window.focus_entered.connect(_focus.bind(true))
		focused = window.has_focus() or DisplayServer.get_name() == "headless"

func _ms() -> int:
	return int(clock.call()) if clock.is_valid() else Time.get_ticks_msec()


func want() -> bool:
	if not app() or not focused or not Settings.on(KEY) or client == null or _ms() < _hold_until:
		return false
	if str(client.state) != "battle" or client.battle == null or not client.battle.started or client.battle.ended:
		return false
	return not client.reconnecting()

func _process(_delta: float) -> void :
	sync()

func sync() -> void :
	if not app():
		return
	var on: bool = want()
	if on and not held:
		held = true
		_apply(Input.MOUSE_MODE_CONFINED)
	elif not on and held:
		release()

func release() -> void :
	if not held:
		return
	held = false
	_apply(Input.MOUSE_MODE_VISIBLE)

func _apply(mode: int) -> void :
	if apply_mode.is_valid():
		apply_mode.call(mode)
	else:
		Input.mouse_mode = mode

func _focus(value: bool) -> void :
	focused = value
	if not value:
		release()
	else:
		sync()

func _notification(what: int) -> void :
	match what:
		NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			_focus(false)
		NOTIFICATION_APPLICATION_FOCUS_IN, NOTIFICATION_WM_WINDOW_FOCUS_IN, NOTIFICATION_APPLICATION_RESUMED:
			_focus(true)
		NOTIFICATION_WM_CLOSE_REQUEST:
			_hold_until = _ms() + CLOSE_HOLD_MS
			release()
		NOTIFICATION_EXIT_TREE, NOTIFICATION_PREDELETE:
			release()
