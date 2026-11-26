extends RefCounted

























const Settings = preload("../settings.gd")
const TouchLq = preload("touch_lq.gd")


const SETTINGS_READS: Array[String] = ["tc_pan", "tc_pan_dir", "tc_view", "tc_return", "tc_frame", "tc_mapfollow", "cam_pan_speed", "tc_smooth"]
const DEFAULTS: Dictionary = {"tc_pan": "swipe", "tc_pan_dir": "lq", "tc_view": "mid", "tc_return": 1500, "tc_frame": true, "tc_mapfollow": true, "cam_pan_speed": 70, "tc_smooth": "mid"}
const PANS: Array[String] = ["swipe", "minimap"]

const PAN_DIRS: Array[String] = ["lq", "grab"]
const VIEWS: Dictionary = {"near": 1.0, "mid": 0.8, "far": 0.7}
const RETURNS: Array[int] = [100, 500, 1500, 3000, 0]

const SMOOTHS: Dictionary = {"off": 0.0, "low": 16.0, "mid": 9.0, "high": 5.0}
const SMOOTH_LAG: float = 0.25
const STAGE: Vector2 = Vector2(1266, 600)
const PINCH_MIN: float = 0.7
const PINCH_MAX: float = 1.0
const PAN_DEAD: float = 12.0
const TAP_GAP: float = 0.32
const TAP_NEAR: float = 60.0
const RETURN_RATE: float = 7.0
const RETURN_MIN: float = 300.0
const AIM_EDGE: float = 0.7
const AIM_RATE: float = 5.0

const EDGE_PAD: Vector4 = Vector4(0.35, 0.3, 0.6, 0.5)

const EDGE_OUT: bool = false


const MAP_VIEW: bool = false
const MAP_VIEW_REF: float = 1820.0
const MAP_VIEW_MIN: float = 0.78

const CAM_MODE: String = "lead"
const LEAD_K: float = 0.22
const LEAD_MIN: float = 0.3
const RAISE_K: float = 0.18
const EDGE_K_MAX: float = 1.0
const EDGE_STEPS: int = 10
const EDGE_RATE: float = 4.0
const TANK_R: float = 36.0
const FIRE_RING: float = 215.0


var opts: Dictionary = {}
var free: bool = false
var free_at: Vector2 = Vector2.ZERO
var idle: float = 0.0
var returning: bool = false
var drift: Vector2 = Vector2.ZERO
var pinch_k: float = -1.0
var fingers: Dictionary = {}
var pinch: Array = []
var clock: float = 0.0
var _tap: Array = []
var _stamp: Array = [-1, -1]
var _view_seen: String = ""
var _map_was: bool = false
var _eye: Vector2 = Vector2.ZERO
var _eye_ok: bool = false
var mode: String = CAM_MODE
var lead_dir: Vector2 = Vector2.ZERO
var _lead_begun: int = -1
var _tank: Vector2 = Vector2.ZERO
var _tank_ok: bool = false
var _dt: float = 0.0
var _ez: float = -1.0


func opt(key: String) -> Variant:
	var v: Variant = opts.get(key, Settings.value(key) if Settings.DEFAULTS.has(key) else null)
	var base: Variant = DEFAULTS[key]
	match key:
		"tc_pan":
			return str(v) if (v is String or v is StringName) and PANS.has(str(v)) else base
		"tc_pan_dir":
			return str(v) if (v is String or v is StringName) and PAN_DIRS.has(str(v)) else base
		"tc_view":
			return str(v) if (v is String or v is StringName) and VIEWS.has(str(v)) else base
		"tc_return":
			return int(v) if (v is int or v is float) and float(v) == float(int(v)) and RETURNS.has(int(v)) else base
		"tc_smooth":
			return str(v) if (v is String or v is StringName) and SMOOTHS.has(str(v)) else base
		"cam_pan_speed":
			return clampi(int(v), 25, 200) if (v is int or v is float) and is_finite(float(v)) else base
	return v if v is bool else base


func speed() -> float:
	return float(opt("cam_pan_speed")) / 70.0

func frame_shown() -> bool:
	return bool(opt("tc_frame"))


func drop_fingers() -> void :
	fingers.clear()
	pinch.clear()
	_tap.clear()

func reset() -> void :
	drop_fingers()
	home()
	pinch_k = -1.0
	_map_was = false
	_eye_ok = false
	_ez = -1.0


func home() -> void :
	free = false
	returning = false
	idle = 0.0
	drift = Vector2.ZERO

static func active(view, battle) -> bool:
	return view._touch and not battle.look


func view_k() -> float:
	var level: String = opt("tc_view")
	if level != _view_seen:
		_view_seen = level
		pinch_k = -1.0
	return pinch_k if pinch_k > 0.0 else float(VIEWS[level])


static func zoom_at(size: Vector2, extent: Vector2, k: float) -> float:
	var z: float = clampf(minf(size.x / STAGE.x, size.y / STAGE.y) * k, 0.3, 1.5 * k)
	if extent.x > 0 and extent.y > 0:
		z = maxf(z, maxf(size.x / extent.x, size.y / extent.y))
	return z

func zoom(size: Vector2, extent: Vector2) -> float:
	var z: float = zoom_at(size, extent, view_k() * map_view(extent))
	if mode != "edge":
		return z
	var want: float = edge_zoom(size, extent, z, _tank) if _tank_ok and not free else z
	_ez = want if _ez < 0.0 else lerpf(_ez, want, 1.0 - exp( - EDGE_RATE * _dt))
	return _ez


func edge_zoom(size: Vector2, extent: Vector2, z: float, tank: Vector2) -> float:
	var top: float = maxf(z, zoom_at(size, extent, EDGE_K_MAX))
	var t: float = z
	for i in EDGE_STEPS + 1:
		t = lerpf(z, top, float(i) / EDGE_STEPS)
		if not covered(size, screen_of(size, extent, t, tank, bias(size / (2.0 * t))), TANK_R * t):
			break
	return t


func bias(half: Vector2) -> Vector2:
	if mode == "":
		return Vector2.ZERO
	var up: Vector2 = Vector2(0.0, RAISE_K * half.y)
	if mode == "lead":
		return up + Vector2(lead_dir.x * half.x, lead_dir.y * half.y) * LEAD_K
	return up



static func lead_for(spawn: Vector2, extent: Vector2) -> Vector2:
	if extent.x <= 0 or extent.y <= 0:
		return Vector2.ZERO
	var d: Vector2 = (extent / 2 - spawn) / (extent / 2)
	if d.length() < LEAD_MIN:
		return Vector2.ZERO
	d = d.normalized()
	return Vector2(d.x, maxf(0.0, d.y))


static func screen_of(size: Vector2, extent: Vector2, z: float, tank: Vector2, off: Vector2) -> Vector2:
	var half: Vector2 = size / (2.0 * z)
	return size / 2 + (tank - clamp_center(tank + off, half, extent)) * z


static func covered(size: Vector2, p: Vector2, r: float) -> bool:
	if TouchLq.in_stick_zone(size, p - Vector2(r, - r)):
		return true
	var fire: Vector2 = TouchLq.fire_center(size)
	if p.distance_to(fire) < FIRE_RING * TouchLq.unit(size) + r:
		return true
	if p.distance_to(TouchLq.auto_center(size)) < TouchLq.AUTO_R * TouchLq.unit(size) + r:
		return true
	for i in TouchLq.BUTTONS.size():
		var b: Array = TouchLq.button(size, i)
		if p.distance_to(b[0]) < float(b[1]) + r:
			return true
	return false


static func map_view(extent: Vector2, on: bool = MAP_VIEW) -> float:
	if not on or extent.x <= 0 or extent.y <= 0:
		return 1.0
	return clampf(MAP_VIEW_REF / sqrt(extent.x * extent.y), MAP_VIEW_MIN, 1.0)


static func clamp_center(c: Vector2, half: Vector2, extent: Vector2, pad: Vector4 = Vector4.ZERO) -> Vector2:
	return Vector2(clampf(c.x, minf(half.x, extent.x / 2) - pad.x, maxf(extent.x - half.x, extent.x / 2) + pad.z), 
		clampf(c.y, minf(half.y, extent.y / 2) - pad.y, maxf(extent.y - half.y, extent.y / 2) + pad.w))


func edge_pad(half: Vector2) -> Vector4:
	if not EDGE_OUT:
		return Vector4.ZERO
	return Vector4(half.x * EDGE_PAD.x, half.y * EDGE_PAD.y, half.x * EDGE_PAD.z, half.y * EDGE_PAD.w)

static func _half(view) -> Vector2:
	return view.size / (2.0 * maxf(0.01, view._zoom))

static func _alive(battle) -> bool:
	return battle.started and not battle.ended and battle.tanks.has(battle.self_id) and battle.alive()


func center(view, battle, delta: float, follow: Vector2) -> Vector2:
	clock += delta
	_dt = delta
	var stamp: Array = [int(battle.begun), int(battle.self_spawns)]
	if stamp != _stamp:
		_stamp = stamp
		reset()
	var h9: Vector2 = view._hud.look_center(follow, battle)
	var extent: Vector2 = battle.map.extent
	var half: Vector2 = _half(view)
	_tank_ok = _alive(battle)
	_tank = follow
	if _tank_ok and int(battle.begun) != _lead_begun:
		_lead_begun = int(battle.begun)
		lead_dir = lead_for(follow, extent)
	follow += bias(half)
	if view._hud.map_dragging() and (opt("tc_pan") == "minimap" or opt("tc_mapfollow")):
		free = true
		returning = false
		idle = 0.0
		free_at = h9
		_map_was = true
	else:
		_map_was = false
	if free and not _panning() and not _map_was:
		idle += delta
		var wait: float = float(opt("tc_return")) / 1000.0
		if wait > 0.0 and idle >= wait:
			returning = true
	if returning:
		var target: Vector2 = clamp_center(follow, half, extent, edge_pad(half))
		var gap: float = free_at.distance_to(target)
		var step: float = maxf(gap * (1.0 - exp( - RETURN_RATE * speed() * delta)), RETURN_MIN * speed() * delta)
		free_at = target if step >= gap else free_at.move_toward(target, step)
		if free_at.distance_to(target) < 0.5:
			home()
	if free:
		free_at = clamp_center(free_at, half, extent, edge_pad(half))
		drift = Vector2.ZERO
		_eye = free_at
		_eye_ok = true
		return free_at
	var want: Vector2 = drift if pick_hold(view) else aim_drift(view, battle, follow, half)
	drift = drift.lerp(want, 1.0 - exp( - AIM_RATE * speed() * delta))
	if drift.length() < 0.5 and want == Vector2.ZERO:
		drift = Vector2.ZERO
	return smooth(follow + drift, half, delta)


func smooth(goal: Vector2, half: Vector2, delta: float) -> Vector2:
	var rate: float = float(SMOOTHS[opt("tc_smooth")])
	if rate <= 0.0 or not _eye_ok or _eye.distance_to(goal) > half.length():
		_eye = goal
	else:
		var lag: Vector2 = _eye.lerp(goal, 1.0 - exp( - rate * delta)) - goal
		_eye = goal + lag.limit_length(SMOOTH_LAG * minf(half.x, half.y))
	_eye_ok = true
	return _eye


static func pick_hold(view) -> bool:
	return view._lq != null and view._lq.has_method("in_pick_zone") and view._lq.held("skill") >= 0 and view._lq.in_pick_zone(view.size)


static func aim_drift(view, battle, follow: Vector2, half: Vector2) -> Vector2:
	if not _alive(battle) or view._lq == null or view._lq.held("skill") < 0 or int(view.controls.selected) == 0:
		return Vector2.ZERO
	var off: Vector2 = (view.controls.aim as Vector2) - follow
	var box: Vector2 = half * AIM_EDGE
	return Vector2(signf(off.x) * maxf(0.0, absf(off.x) - box.x), signf(off.y) * maxf(0.0, absf(off.y) - box.y))

func _panning() -> bool:
	if not pinch.is_empty():
		return true
	for index: int in fingers:
		if fingers[index].moved:
			return true
	return false


func press(view, battle, index: int, point: Vector2) -> void :
	if not active(view, battle):
		return
	fingers[index] = {"start": point, "last": point, "moved": false}
	if pinch.is_empty() and fingers.size() == 2 and _alive(battle):
		var ids: Array = fingers.keys()
		var d: float = (fingers[ids[0]].last as Vector2).distance_to(fingers[ids[1]].last)
		if d > 1.0:
			pinch = [ids[0], ids[1], d, view_k()]
			for i: int in ids:
				fingers[i].moved = true


func drag(view, battle, index: int, point: Vector2) -> bool:
	if not fingers.has(index):
		return false
	var st: Dictionary = fingers[index]
	var last: Vector2 = st.last
	st.last = point
	if not pinch.is_empty() and index in [pinch[0], pinch[1]]:
		if fingers.has(pinch[0]) and fingers.has(pinch[1]):
			var d: float = (fingers[pinch[0]].last as Vector2).distance_to(fingers[pinch[1]].last)
			pinch_k = clampf(float(pinch[3]) * d / float(pinch[2]), PINCH_MIN, PINCH_MAX)
		return true
	if opt("tc_pan") != "swipe" or not _alive(battle):
		return true
	var u: float = minf(view.size.x / STAGE.x, view.size.y / STAGE.y)
	if not st.moved:
		if point.distance_to(st.start) <= PAN_DEAD * u:
			return true
		st.moved = true
		last = point
	if not free:
		free_at = view._camera
		free = true
	returning = false
	idle = 0.0
	var dir: float = 1.0 if opt("tc_pan_dir") == "lq" else -1.0
	free_at = clamp_center(free_at + dir * (point - last) / maxf(0.01, view._zoom) * speed(), _half(view), battle.map.extent, edge_pad(_half(view)))
	return true


func release(view, index: int, point: Vector2) -> bool:
	if not fingers.has(index):
		return false
	var st: Dictionary = fingers[index]
	fingers.erase(index)
	if not pinch.is_empty() and index in [pinch[0], pinch[1]]:
		pinch.clear()
		for other: int in fingers:
			fingers[other].moved = true
		return true
	if st.moved:
		idle = 0.0
		return true
	var u: float = minf(view.size.x / STAGE.x, view.size.y / STAGE.y)
	if not _tap.is_empty() and clock - float(_tap[0]) <= TAP_GAP and point.distance_to(_tap[1]) <= TAP_NEAR * u:
		_tap.clear()
		home()
	else:
		_tap = [clock, point]
	return false
