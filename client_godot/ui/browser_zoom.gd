extends Node





















const MIN_Z: float = 0.5
const Settings = preload("res://settings.gd")
const MAX_Z: float = 3.0
const POLL: float = 0.25
const SNAP: float = 0.03

const LEVELS: Array = [0.25, 0.33, 0.5, 0.67, 0.75, 0.8, 0.9, 1.0, 1.1, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0, 4.0, 5.0]
const JS: String = "(function(w){try{var d=w.__bbDpr?w.__bbDpr():w.devicePixelRatio;var u=(w.navigator&&w.navigator.userAgent)||'';var c=/Chrome\\/|Chromium\\/|Edg\\//.test(u)&&!/Firefox\\//.test(u)?1:0;return [d||1,w.outerWidth||0,w.innerWidth||0,c].join(',')}catch(e){return ''}})(window)"


static var z: float = 1.0

static var user: float = 1.0

static var base: float = 0.0

var _wait: float = 0.0


static func factor() -> float:
	return clampf(z * user, MIN_Z, MAX_Z)








static func frame_k(window: Vector2, rw: float, rh: float, mobile: bool, zoom: float = -1.0) -> float:
	var k: float = minf(window.x / rw, window.y / rh)
	if not mobile:
		var f: float = factor() if zoom < 0.0 else clampf(zoom, MIN_Z, MAX_Z)
		if base > 0.0:
			k = minf(k, 0.5 * base * f)
		else:
			k *= minf(1.0, f)
	return k


static func floor_for(known_base: float) -> float:
	return known_base * MIN_Z if known_base > 0.0 else 1.0


static func snap(ratio: float) -> float:
	if ratio <= 0.0:
		return 0.0
	var best: float = 0.0
	var gap: float = SNAP
	for level: float in LEVELS:
		var off: float = absf(ratio / level - 1.0)
		if off <= gap:
			gap = off
			best = level
	return best


static func read(dpr: float, outer: float, inner: float, chromium: bool, known_base: float) -> Array:
	if dpr <= 0.0:
		return [1.0, known_base]
	if chromium and outer > 0.0 and inner > 0.0:
		var level: float = snap(outer / inner)
		if level > 0.0:
			return [level, dpr / level]
	var b: float = known_base if known_base > 0.0 else dpr
	return [dpr / b, b]


static func update_from(text: String, tree: SceneTree) -> bool:
	var parts: PackedStringArray = text.split(",")
	if parts.size() < 4:
		return false
	var got: Array = read(float(parts[0]), float(parts[1]), float(parts[2]), parts[3] == "1", base)
	base = float(got[1])
	var next: float = float(got[0])
	if absf(next - z) < 0.004:
		return false
	z = next
	if tree != null and tree.root != null:
		tree.root.propagate_call("queue_redraw")
	return true

func _ready() -> void :
	_poll()

func _process(delta: float) -> void :
	_wait -= delta
	if _wait <= 0.0:
		_poll()

func _poll() -> void :
	_wait = POLL
	if not OS.has_feature("web"):
		return
	update_from(str(JavaScriptBridge.eval(JS, true)), get_tree())
	Settings.css_floor = floor_for(base)
