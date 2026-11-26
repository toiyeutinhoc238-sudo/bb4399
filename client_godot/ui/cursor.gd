extends Node








































const Settings = preload("res://settings.gd")
const TouchGfx = preload("res://battle/touch_gfx.gd")
const BrowserZoom = preload("res://ui/browser_zoom.gd")
const MAX_PX: float = 128.0
const DIR: String = "res://assets/ui/cursor/"

const KINDS: Dictionary = {
	"normal": ["normal.png", Vector2(4, 0), Vector2(32, 32)], 
	"atk": ["atk.png", Vector2(16, 16), Vector2(32, 32)], 
	"bak": ["bak.png", Vector2(16, 16), Vector2(32, 32)], 
	"mst": ["mst.png", Vector2(16, 16), Vector2(32, 32)], 
	"battle": ["battle.png", Vector2(16, 16), Vector2(32, 32)], 
	"sell": ["sell.png", Vector2(24, 24), Vector2(47, 47)], 
}

const SIGNALS: Array[String] = ["", "atk", "bak", "mst"]
const SHAPES: Array[Input.CursorShape] = [Input.CURSOR_ARROW, Input.CURSOR_POINTING_HAND, Input.CURSOR_IBEAM]

var client: Node
var battle: Control
var bag: Control
var kind: String = "-"
var cursor_scale: float = 1.0
var _textures: Dictionary = {}
var _scaled: Dictionary = {}
var mouse_live: bool = false
const TOUCH_QUIET_MS: int = 700
const MOUSE_RUN: int = 3
const JS_HOOK: String = "(function(){if(window.__tdet1)return;var s=window.__tdet1={run:0,touch:-1e9,any:!window.PointerEvent};function f(e){if(e.pointerType==='mouse'){s.run++;}else{s.run=0;s.touch=performance.now();}}window.addEventListener('pointermove',f,{capture:true,passive:true});window.addEventListener('pointerdown',f,{capture:true,passive:true});})();"
const JS_MOUSE: String = "(function(){var s=window.__tdet1;return !!s&&(s.any||(s.run>=%d&&performance.now()-s.touch>=%d));})()"
var _touch_ms: int = -1000000
var _mouse_run: int = 0
static var force_strict: int = -1
static var _strict: int = -1
var soft: TextureRect
var _soft_layer: CanvasLayer

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.has_feature("web") and TouchGfx.touch_device():
		JavaScriptBridge.eval(JS_HOOK, true)
	refresh()

func _process(_delta: float) -> void :
	refresh()
	if mouse_live:
		place_soft()


func _input(event: InputEvent) -> void :
	if not TouchGfx.touch_device():
		if event is InputEventMouse and event.device != InputEvent.DEVICE_ID_EMULATION and TouchGfx.touch_capable():
			_battle_mouse()
		return
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		_touch_ms = Time.get_ticks_msec()
		_mouse_run = 0
	if event is InputEventMouse and event.device != InputEvent.DEVICE_ID_EMULATION:
		var loose: bool = not strict()
		if not mouse_live and (loose or real_mouse(event)):
			set_mouse_live(true)
			_battle_mouse()
		elif mouse_live and loose:
			_battle_mouse()
	elif event is InputEventScreenTouch and event.pressed and mouse_live:
		set_mouse_live(false)
		if battle != null and battle.get("_touch") == false and battle.has_method("reset_input"):
			battle.call("reset_input")


func _battle_mouse() -> void :
	if battle != null and battle.get("_touch") == true:
		battle.set("_touch", false)
		if battle.has_method("reset_input"):
			battle.call("reset_input")


static func strict() -> bool:
	if force_strict >= 0:
		return force_strict == 1
	if _strict < 0:
		var yes: bool = OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("web_android") or OS.has_feature("web_ios")
		if not yes and TouchGfx.web_desktop_ua():
			yes = TouchGfx.web_pointer() == 1
		_strict = 1 if yes else 0
	return _strict == 1


func real_mouse(event: InputEvent) -> bool:
	if Time.get_ticks_msec() - _touch_ms < TOUCH_QUIET_MS:
		_mouse_run = 0
		return false
	if not (event is InputEventMouseMotion):
		return false
	_mouse_run += 1
	if _mouse_run < MOUSE_RUN:
		return false
	if OS.has_feature("web"):
		return JavaScriptBridge.eval(JS_MOUSE % [MOUSE_RUN, TOUCH_QUIET_MS], true) == true
	return true

func _notification(what: int) -> void :
	if what == NOTIFICATION_WM_MOUSE_EXIT and soft != null:
		soft.visible = false

func set_mouse_live(on: bool) -> void :
	mouse_live = on
	if on:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
		place_soft()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		if soft != null:
			soft.visible = false


func place_soft() -> void :
	var view: Viewport = get_viewport()
	if view == null:
		return
	if soft == null:
		_soft_layer = CanvasLayer.new()
		_soft_layer.name = "SoftCursor"
		_soft_layer.layer = 128
		add_child(_soft_layer)
		soft = TextureRect.new()
		soft.mouse_filter = Control.MOUSE_FILTER_IGNORE
		soft.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		soft.stretch_mode = TextureRect.STRETCH_SCALE
		soft.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		_soft_layer.add_child(soft)
	var pick: String = kind if KINDS.has(kind) else "normal"
	var texture: Texture2D = texture_of(pick)
	if texture == null:
		soft.visible = false
		return
	soft.texture = texture
	var k: float = soft_scale(view) * maxf(cursor_scale, 0.05)
	soft.size = Vector2(KINDS[pick][2]) * k
	soft.position = view.get_mouse_position() - Vector2(KINDS[pick][1]) * k
	soft.visible = true


func soft_scale(view: Viewport) -> float:
	var css: Vector2 = Settings.css_size(Vector2(DisplayServer.window_get_size()))
	if css.x <= 0.0:
		return 1.0
	return view.get_visible_rect().size.x / css.x


func refresh() -> void :
	var next: String = want()
	if next != kind or want_scale() != cursor_scale:
		apply(next)


static func zoom_scale() -> float:
	var s: float = BrowserZoom.factor()
	if not OS.has_feature("web") and BrowserZoom.base > 0.0:
		s *= BrowserZoom.base
	return snappedf(s, 0.05)


static func user_scale() -> float:
	return float(int(Settings.value("cursor_size"))) / 100.0


static func want_scale() -> float:
	var z: float = zoom_scale()
	var u: float = user_scale()
	return z if u == 1.0 else snappedf(z * u, 0.05)


func want() -> String:
	if battle != null and battle.visible and client != null and str(client.get("state")) == "battle":
		var hud: Variant = battle.get("_hud")
		var armed: int = int(hud.get("armed")) if hud is Object and hud.get("armed") != null else 0
		if armed > 0 and armed < SIGNALS.size():
			return SIGNALS[armed]
	if bag != null and bag.is_visible_in_tree() and bag.get("_selling") == true:
		return "sell"
	return "normal" if Settings.on("cursor") else ""

func apply(next: String) -> void :
	kind = next
	cursor_scale = want_scale()
	var texture: Texture2D = texture_of(next)
	var hot: Vector2 = KINDS[next][1] if KINDS.has(next) and texture != null else Vector2.ZERO
	if texture != null and not is_equal_approx(cursor_scale, 1.0):
		var k: float = minf(cursor_scale, MAX_PX / maxf(texture.get_width(), texture.get_height()))
		texture = scaled(next, k)
		hot = (hot * k).floor()
	for shape: Input.CursorShape in SHAPES:
		Input.set_custom_mouse_cursor(texture, shape, hot)


func texture_of(name: String) -> Texture2D:
	if not KINDS.has(name):
		return null
	if _textures.has(name):
		return _textures[name]
	var path: String = DIR + str(KINDS[name][0])
	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	elif FileAccess.file_exists(path):
		var image: Image = Image.new()
		if image.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK:
			texture = ImageTexture.create_from_image(image)
	_textures[name] = texture
	return texture


func scaled(name: String, k: float) -> Texture2D:
	var key: String = "%s@%.2f" % [name, k]
	if _scaled.has(key):
		return _scaled[key]
	var base: Texture2D = texture_of(name)
	if base == null:
		return null
	var image: Image = base.get_image()
	if image == null:
		return base
	image = image.duplicate() as Image
	if image.is_compressed():
		image.decompress()
	image.resize(maxi(1, roundi(image.get_width() * k)), maxi(1, roundi(image.get_height() * k)), Image.INTERPOLATE_LANCZOS)
	var out: Texture2D = ImageTexture.create_from_image(image)
	_scaled[key] = out
	return out
