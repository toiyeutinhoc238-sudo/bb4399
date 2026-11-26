extends Node





























const Settings = preload("res://settings.gd")
const TouchGfx = preload("touch_gfx.gd")
const BrowserZoom = preload("res://ui/browser_zoom.gd")
const PcMouse = preload("res://ui/pc_mouse.gd")

const LOWEST: int = 2
const WINDOW: float = 3.0
const SKIP: float = 3.0
const MAX_GAP: float = 0.25
const SOFT_GPU: String = "(?i)swiftshader|llvmpipe|softpipe|lavapipe|software|basic render"

const RENDER: Array = [[1.0, 1.0], [0.85, 0.75], [0.7, 0.5]]

const RENDER_OUT: Array = [[1.0, 1.0], [0.25, 0.75], [0.2, 0.5]]
const ZOOM_OUT: float = 0.995
const OUT_FLOOR: int = 1
const TOUCH_DPR: float = 2.0
const WARM_ROW: Array = [0.85, 0.85]
const WARM_AT: float = 300.0
const COOL_AT: float = 120.0
const HEAT_MAX: float = 360.0
const ECO_FLOOR: int = 1
const NATIVE_MIN: float = 1.15


const RK_JS: String = "(function(w,lo,mul,hi){try{if(!w.__bbDpr){var o=Object.getOwnPropertyDescriptor(w,'devicePixelRatio')||Object.getOwnPropertyDescriptor(Object.getPrototypeOf(w),'devicePixelRatio');if(!o||!o.get){return 1}var g=o.get;w.__bbDpr=function(){return g.call(w)};w.__bbRK=1;Object.defineProperty(w,'devicePixelRatio',{configurable:true,enumerable:true,get:function(){return w.__bbDpr()*w.__bbRK}})}var r=w.__bbDpr()||1;w.__bbRK=Math.min(1,Math.min(hi,mul>=1?r:Math.max(lo,r*mul))/r);return w.__bbRK}catch(e){return 1}})(window,%s,%s,%s)"


class Brain:
	const SLOW_FPS: float = 0.8
	const SLOW_P95: float = 2.0
	const FAST_FPS: float = 0.95
	const FAST_P95: float = 1.25
	const DOWN_AFTER: int = 2
	const PROBE_FIRST: int = 10
	const PROBE_MAX: int = 100
	const HELP_FPS: float = 1.1
	const HELP_P95: float = 0.85

	var level: int = 0
	var min_level: int = 0
	var lifted: bool = false
	var lowest: int = LOWEST
	var slow_run: int = 0
	var fast_run: int = 0
	var settle: int = 0
	var probe_every: int = PROBE_FIRST
	var trial: String = ""
	var trial_left: int = 0
	var before_fps: float = 0.0
	var before_p95: float = 0.0

	func start(at: int, low: int) -> void :
		lowest = clampi(low, 0, LOWEST)
		level = clampi(at, 0, lowest)
		slow_run = 0
		fast_run = 0
		settle = 0
		probe_every = PROBE_FIRST
		trial = ""
		trial_left = 0
		lifted = false


	func feed(fps: float, p95: float, goal: float) -> int:
		var budget: float = 1.0 / maxf(goal, 1.0)
		var slow: bool = fps < SLOW_FPS * goal or p95 > SLOW_P95 * budget
		var fast: bool = fps >= FAST_FPS * goal and p95 <= FAST_P95 * budget
		if level < min_level:
			level = min_level
			lifted = true
			trial = ""
			slow_run = 0
			fast_run = 0
		if settle > 0:
			settle -= 1
			return level
		if trial == "down":
			trial = ""
			if fps < before_fps * HELP_FPS and p95 > before_p95 * HELP_P95:
				lowest = level - 1
				return _go(level - 1)
		elif trial == "up":
			if slow:
				trial = ""
				probe_every = mini(probe_every * 2, PROBE_MAX)
				return _go(level + 1)
			trial_left -= 1
			if trial_left <= 0:
				trial = ""
			return level
		if slow:
			fast_run = 0
			slow_run += 1
			if slow_run >= DOWN_AFTER and level < lowest:
				before_fps = fps
				before_p95 = p95
				trial = "down"
				return _go(level + 1)
		elif fast:
			slow_run = 0
			fast_run += 1
			if fast_run >= probe_every and level > min_level:
				trial = "up"
				trial_left = 2
				return _go(level - 1)
		else:
			slow_run = 0
			fast_run = 0
		return level


	func hold(at: int) -> void :
		min_level = clampi(at, 0, LOWEST)
		if lifted and level > min_level:
			level = min_level
			lifted = false
			trial = ""
			slow_run = 0
			fast_run = 0
		elif min_level == 0:
			lifted = false

	func _go(to: int) -> int:
		level = to
		lifted = false
		slow_run = 0
		fast_run = 0
		settle = 1
		return level

static var force: bool = false
static var _learned: int = -1
static var _lowest: int = -1
static var _soft: int = -1
static var _js: bool = false
static var _row: Array = [1.0, 1.0]
static var _heat: float = 0.0
static var _hot: bool = false
static var _at_z: float = 1.0
static var _native_on: bool = false
static var _native_was: int = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS

var brain: Brain = Brain.new()
var _in: bool = false
var _gaps: PackedFloat32Array = PackedFloat32Array()
var _span: float = 0.0
var _since: float = 0.0
var _last_us: int = 0
var _web_at: int = 0

static func enabled() -> bool:
	return force or DisplayServer.get_name() != "headless"


static func goal(cap: int, hz: float) -> float:
	var target: float = 60.0
	if hz > 0.0:
		target = minf(target, hz)
	if cap > 0:
		target = minf(target, float(cap))
	return maxf(target, 20.0)

static func software(raw: String) -> bool:
	return RegEx.create_from_string(SOFT_GPU).search(raw) != null

static func gpu_soft() -> bool:
	if _soft < 0:
		var name: String = ""
		if OS.has_feature("web"):
			name = str(JavaScriptBridge.eval("window.__bbGpu||''", true))
		if name.is_empty() or name == "<null>":
			name = RenderingServer.get_video_adapter_name()
		_soft = 1 if software(name) else 0
	return _soft == 1



func wanted() -> int:
	return maxi(pick(int(Settings.value("quality")), brain.level, zoomed_out()), ECO_FLOOR if TouchGfx.eco() else 0)


static func heat(at: float, delta: float, playing: bool) -> float:
	return clampf(at + (minf(delta, MAX_GAP) if playing else - delta), 0.0, HEAT_MAX)


static func hot_after(was: bool, at: float) -> bool:
	return at >= WARM_AT or (was and at > COOL_AT)


static func zoomed_out() -> bool:
	return BrowserZoom.z < ZOOM_OUT




static func pick(quality: int, _auto_level: int, _out: bool) -> int:
	return LOWEST if quality == 2 else 0



static func row(to: int, out: bool, hot: bool = false) -> Array:
	var rows: Array = RENDER_OUT if out else RENDER
	var r: Array = rows[clampi(to, 0, rows.size() - 1)]
	if not TouchGfx.touch_device():
		return r
	var at: Array = WARM_ROW if hot and to == 0 else r
	return at + [TOUCH_DPR * float(at[1])]


static func rk(dpr: float, r: Array) -> float:
	var real: float = dpr if dpr > 0.0 else 1.0
	var hi: float = float(r[2]) if r.size() > 2 else 99.0
	return minf(1.0, minf(hi, real if float(r[1]) >= 1.0 else maxf(float(r[0]), real * float(r[1]))) / real)

func _ready() -> void :
	get_window().size_changed.connect(_resized)

func _exit_tree() -> void :
	_leave()


func _phase() -> int:
	var panel: Node = get_parent()
	var view: Variant = panel.get("view") if panel != null else null
	if view == null or not (view as Control).visible:
		return 0
	var client: Variant = view.get("client")
	if client == null or str(client.state) != "battle" or not client.battle.active:
		return 0
	return 2 if client.battle.started and not client.battle.ended else 1

func _process(delta: float) -> void :
	if not enabled():
		return
	var phase: int = _phase()
	if _web_at < 2:
		_web_gpu1(phase)
	if TouchGfx.touch_device():
		_heat = heat(_heat, delta, phase == 2)
		_hot = hot_after(_hot, _heat)
	if phase == 0:
		_leave()
		return
	if not _in:
		_in = true
		var soft: bool = gpu_soft()
		brain.start(_learned if _learned >= 0 else (LOWEST if soft else 0), _lowest if _lowest >= 0 else LOWEST)
		_reset_window()
		_since = 0.0
	brain.hold(ECO_FLOOR if TouchGfx.eco() else 0)
	if _learned >= 0:
		_learned = brain.level
	if phase == 2:
		_measure()
	else:
		_last_us = 0
	apply(wanted(), zoomed_out(), _hot)
	_native(wanted())

func _measure() -> void :
	var now: int = Time.get_ticks_usec()
	if _last_us > 0 and now > _last_us:
		var gap: float = float(now - _last_us) / 1000000.0
		if gap <= MAX_GAP:
			_since += gap
			if _since > SKIP:
				_gaps.append(gap)
				_span += gap
	_last_us = now
	if _span < WINDOW:
		return
	var sorted: PackedFloat32Array = _gaps.duplicate()
	sorted.sort()
	var p95: float = sorted[mini(sorted.size() - 1, int(sorted.size() * 0.95))]
	var fps: float = float(_gaps.size()) / _span
	_reset_window()
	if int(Settings.value("quality")) == 0:
		brain.feed(fps, p95, goal(TouchGfx.fps_limit(), DisplayServer.screen_get_refresh_rate()))
		_learned = brain.level
		_lowest = brain.lowest

func _reset_window() -> void :
	_gaps = PackedFloat32Array()
	_span = 0.0

func _leave() -> void :
	if _in:
		_in = false
		_last_us = 0
	apply(0)
	_native(0)



static func native_low(to: int, win: Vector2, base: Vector2, app: bool) -> bool:
	if not app or to <= 0 or base.x <= 0.0 or base.y <= 0.0:
		return false
	return minf(win.x / base.x, win.y / base.y) >= NATIVE_MIN


func _native(to: int) -> void :
	if (to <= 0 and not _native_on) or OS.has_feature("web"):
		return
	var win: Window = get_window()
	if win == null:
		return
	var low: bool = native_low(to, Vector2(win.size), Vector2(win.content_scale_size), PcMouse.app())
	if low == _native_on:
		return
	if low:
		_native_was = win.content_scale_mode
		win.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
	else:
		win.content_scale_mode = _native_was as Window.ContentScaleMode
	_native_on = low



static func apply(to: int, out: bool = false, hot: bool = false) -> void :
	var r: Array = row(to, out, hot)
	if Settings.drop == to and r == _row and ((to == 0 and r.size() < 3) or absf(BrowserZoom.z - _at_z) < 0.004):
		return
	Settings.drop = to
	_row = r
	_at_z = BrowserZoom.z
	if not OS.has_feature("web"):
		return
	if Settings.render_k >= 1.0:
		Settings.render_scale = DisplayServer.screen_get_scale()
	JavaScriptBridge.eval(RK_JS % [str(r[0]), str(r[1]), str(r[2] if r.size() > 2 else 99.0)], true)
	_js = true


func _resized() -> void :
	if not _js:
		return
	var k: float = float(JavaScriptBridge.eval("window.__bbRK||1", true))
	Settings.render_k = k if k > 0.0 and k < 1.0 else 1.0
	Settings.render_scale = DisplayServer.screen_get_scale() if Settings.render_k < 1.0 else 0.0




static func gpu1_at(phase: int, state: String) -> int:
	if phase > 0:
		return 2
	return 1 if state in ["lobby", "hall", "room"] else 0



func _web_gpu1(phase: int) -> void :
	if not OS.has_feature("web"):
		_web_at = 2
		return
	var state: String = ""
	if phase == 0:
		var panel: Node = get_parent()
		var view: Variant = panel.get("view") if panel != null else null
		var client: Variant = view.get("client") if view != null else null
		state = str(client.state) if client != null else ""
	var at: int = gpu1_at(phase, state)
	if at > _web_at:
		_web_at = at
		JavaScriptBridge.eval("window.__bbGpu1&&window.__bbGpu1(%d)" % at, true)
