extends RefCounted



















const Settings = preload("../settings.gd")


const SETTINGS_READS: Array[String] = ["tc_fps", "tc_gfx", "tc_outline", "tc_eco"]

const FPS_CHOICES: Array[int] = [30, 60, 90, 0]
const FPS_DEFAULT: int = 60

const BATTLE: int = 2
const LOBBY: int = 1
const IDLE: int = 0
const LOBBY_FPS: int = 30
const IDLE_FPS: int = 15
const IDLE_MS: int = 20000
const ECO_FPS: int = 30
const LEVELS: Array[String] = ["low", "mid", "high"]
const MID_HIDE: Dictionary = {"gone": true, "born": true, "appear": true}
const LOW_HIDE: Dictionary = {"gone": true, "born": true, "appear": true, "death": true, "destroy": true, "remove": true}
const SKIP: float = 8.0
const WINDOW: float = 4.0
const MAX_GAP: float = 0.25
const WEAK_FPS: float = 45.0
const WEAK_WINDOWS: int = 2
const HINT: String = "Máy đang giật: Cài đặt › Hình ảnh › Mức mượt chọn 30 để chơi đều hơn"
const OUTLINE_PX: float = 2.0
const OUTLINE: Color = Color(0.02, 0.03, 0.05, 0.85)
const DIRS: Array[Vector2] = [Vector2(1, 0), Vector2(-1, 0), Vector2(0, 1), Vector2(0, -1)]

static var force_touch: int = -1
static var _weak: bool = false
static var _hinted: bool = false
static var _poke_ms: int = 0

var level: int = 2
var outline: bool = false
var outlining: bool = false
var last_fps: float = 0.0
var outlined: int = 0
var _begun: int = -1
var _age: float = 0.0
var _win_t: float = 0.0
var _win_n: int = 0
var _slow: int = 0

static func touch_device() -> bool:
	if force_touch >= 0:
		return force_touch == 1
	return touch_screen()






static var _touch_screen: int = -1
static func touch_screen() -> bool:
	if _touch_screen < 0:
		var yes: bool = DisplayServer.is_touchscreen_available() or OS.has_feature("android") or OS.has_feature("ios")
		if web_desktop_ua():
			yes = desktop_touch(touch_capable(), web_pointer())
		elif not yes and OS.has_feature("web") and not OS.has_feature("web_windows"):
			yes = JavaScriptBridge.eval("(navigator.maxTouchPoints||0)>1&&!!(window.matchMedia&&window.matchMedia('(pointer: coarse)').matches)", true) == true
		_touch_screen = 1 if yes else 0
	return _touch_screen == 1






const POINTER_JS: String = "(function(){var m=window.matchMedia;if(!m)return -1;if(m('(pointer: coarse)').matches)return 1;if(m('(pointer: fine)').matches)return 0;return -1})()"
static var force_pointer: int = -2
static var force_capable: int = -1
static var force_web_desktop: int = -1
static var _pointer: int = -2
static var _capable: int = -1


static func web_desktop_ua() -> bool:
	if force_web_desktop >= 0:
		return force_web_desktop == 1
	return OS.has_feature("web") and not OS.has_feature("web_android") and not OS.has_feature("web_ios")


static func web_pointer() -> int:
	if force_pointer > -2:
		return force_pointer
	if _pointer < -1:
		var v: Variant = JavaScriptBridge.eval(POINTER_JS, true) if OS.has_feature("web") else null
		_pointer = int(v) if (v is int or v is float) and int(v) >= -1 and int(v) <= 1 else -1
	return _pointer


static func touch_capable() -> bool:
	if force_capable >= 0:
		return force_capable == 1
	if _capable < 0:
		_capable = 1 if DisplayServer.is_touchscreen_available() else 0
	return _capable == 1


static func desktop_touch(ontouch: bool, pointer: int) -> bool:
	return pointer == 1 if pointer >= 0 else ontouch



static func fps_limit(where: int = BATTLE) -> int:
	var cap: int = int(Settings.value("fps_cap"))
	if not touch_device():
		return cap
	var v: Variant = Settings.value("tc_fps")
	var fps: int = cap if v == null else int(v) if (v is int or v is float) and FPS_CHOICES.has(int(v)) else int(Settings.default_of("tc_fps"))
	if eco():
		fps = ECO_FPS
	if where >= BATTLE:
		return fps
	var most: int = IDLE_FPS if where == IDLE else LOBBY_FPS
	return most if fps <= 0 or fps > most else fps


static func where_now(in_battle: bool, now_ms: int) -> int:
	if in_battle:
		return BATTLE
	return IDLE if now_ms - _poke_ms >= IDLE_MS else LOBBY


static func poke(now_ms: int = Time.get_ticks_msec()) -> void :
	_poke_ms = now_ms


static func eco() -> bool:
	return touch_device() and _on("tc_eco")

static func _on(key: String) -> bool:
	var v: Variant = Settings.value(key)
	return v is bool and v


static func flat_overlay() -> bool:
	return touch_device() and (level_of(Settings.value("tc_gfx")) < 2 or _on("tc_eco"))


static func weak() -> bool:
	return _weak

static func level_of(v: Variant) -> int:
	var i: int = LEVELS.find(str(v)) if v != null else -1
	return i if i >= 0 else 2

func tick(view, delta: float) -> void :
	if not touch_device():
		level = 2
		outline = false
		return
	level = level_of(Settings.value("tc_gfx"))
	var edge: Variant = Settings.value("tc_outline")
	outline = edge is bool and edge
	_measure(view, delta)

func _measure(view, delta: float) -> void :
	var battle = view.client.battle if view.client != null else null
	if battle == null or not battle.started or battle.ended:
		_age = 0.0
		_win_t = 0.0
		_win_n = 0
		return
	if int(battle.begun) != _begun:
		_begun = int(battle.begun)
		_age = 0.0
		_win_t = 0.0
		_win_n = 0
		_slow = 0
	if delta <= 0.0 or delta > MAX_GAP:
		return
	_age += delta
	if _age < SKIP:
		return
	_win_t += delta
	_win_n += 1
	if _win_t < WINDOW:
		return
	last_fps = float(_win_n) / _win_t
	_win_t = 0.0
	_win_n = 0
	var limit: int = fps_limit()
	if limit == 30 or Settings.value("tc_fps") == null:
		_slow = 0
		return
	_slow = _slow + 1 if last_fps < WEAK_FPS else 0
	if _slow < WEAK_WINDOWS:
		return
	_weak = true
	if not _hinted and not battle.look:
		_hinted = true
		battle.tip(HINT)

func hide_fx(fx: Dictionary) -> bool:
	if level >= 2:
		return false
	return (LOW_HIDE if level == 0 else MID_HIDE).has(str(fx.kind))

func keep_decor() -> bool:
	return level > 0

func keep_hurt() -> bool:
	return level >= 2

func skip_layer(layer: Dictionary) -> bool:
	return (outlining or level == 0) and str(layer.name) == "shadow"

func no_shake() -> bool:
	return level == 0



func draw_outline(view, art: Dictionary, body_swf: Dictionary, turret_swf: Dictionary, tank: Dictionary, moving: bool, cannon: float) -> void :
	var offset0: Vector2 = view._offset
	var tint0: Color = view._tint
	var fire0: Texture2D = view._fire_tex
	view._tint = Color(OUTLINE.r, OUTLINE.g, OUTLINE.b, OUTLINE.a * tint0.a)
	view._fire_tex = null
	outlining = true
	for dir: Vector2 in DIRS:
		view._offset = offset0 + dir * OUTLINE_PX
		if not body_swf.is_empty():
			view._draw_swf_body(art.body, body_swf, tank, moving)
		else:
			view._draw_png_body(art.body, tank, moving)
		if not art.has("turret"):
			pass
		elif turret_swf.has("idle"):
			view._draw_swf_cannon(art.turret, turret_swf, tank, cannon)
		elif not turret_swf.is_empty():
			view._ph_layer_cannon(art.turret, turret_swf, tank, cannon)
		else:
			view._draw_png_cannon(art.turret, tank, cannon)
	outlining = false
	view._offset = offset0
	view._tint = tint0
	view._fire_tex = fire0
	view.draw_set_transform(offset0, 0, Vector2(view._zoom, view._zoom))
	outlined += 1
