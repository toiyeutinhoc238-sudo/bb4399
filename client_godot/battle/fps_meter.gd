extends RefCounted








const REFRESH_STEPS: Array[float] = [30.0, 50.0, 60.0, 75.0, 90.0, 100.0, 120.0, 144.0, 165.0, 240.0, 360.0]
const CEILING: float = 120.0
const GOOD: float = 0.9
const FAIR: float = 0.6
const WINDOW: int = 120
const MIN_SAMPLES: int = 20
const MAX_GAP: float = 0.25
const FALLBACK_HZ: float = 60.0

static var _gaps: PackedFloat32Array = PackedFloat32Array()
static var _head: int = 0
static var _last_us: int = 0
static var _hz: float = 0.0
static var _hz_at: int = -1
static var _taken: int = 0


static func sample(now_us: int) -> void :
	if _last_us > 0 and now_us > _last_us:
		var gap: float = float(now_us - _last_us) / 1000000.0
		if gap <= MAX_GAP:
			if _gaps.size() < WINDOW:
				_gaps.append(gap)
			else:
				_gaps[_head] = gap
				_head = (_head + 1) % WINDOW
			_taken += 1
	_last_us = now_us


static func clear() -> void :
	_gaps = PackedFloat32Array()
	_head = 0
	_last_us = 0
	_hz = 0.0
	_hz_at = -1
	_taken = 0


static func snap(rate: float) -> float:
	var best: float = REFRESH_STEPS[0]
	for step: float in REFRESH_STEPS:
		if absf(log(rate / step)) < absf(log(rate / best)):
			best = step
	return best


static func estimated_hz() -> float:
	if _gaps.size() < MIN_SAMPLES:
		return FALLBACK_HZ
	if _hz <= 0.0 or _taken - _hz_at >= 30:
		var sorted: PackedFloat32Array = _gaps.duplicate()
		sorted.sort()
		var fast: float = sorted[int(sorted.size() * 0.1)]
		_hz = snap(1.0 / maxf(fast, 0.0005))
		_hz_at = _taken
	return _hz


static func refresh_rate() -> float:
	var hz: float = DisplayServer.screen_get_refresh_rate()
	return hz if hz > 0.0 else estimated_hz()


static func target(cap: int, hz: float) -> float:
	var ref: float = minf(hz if hz > 0.0 else FALLBACK_HZ, CEILING)
	if cap > 0:
		ref = minf(ref, float(cap))
	return ref


static func grade(fps: float, ref: float) -> int:
	if fps >= ref * GOOD:
		return 0
	if fps >= ref * FAIR:
		return 1
	return 2






const SOFTWARE_GPU: String = "(?i)swiftshader|llvmpipe|softpipe|lavapipe|software|basic render"
static var _gpu: String = ""
static var _gpu_read: bool = false

static func gpu_name() -> String:
	if not _gpu_read:
		_gpu_read = true
		if OS.has_feature("web"):
			_gpu = str(JavaScriptBridge.eval("window.__bbGpu||''", true))
		if _gpu.is_empty() or _gpu == "<null>":
			_gpu = RenderingServer.get_video_adapter_name()
	return _gpu


static func set_gpu_name(name: String) -> void :
	_gpu = name
	_gpu_read = true


static func gpu_short(raw: String) -> String:
	var name: String = raw.strip_edges()
	if name.begins_with("ANGLE (") and name.ends_with(")"):
		var parts: PackedStringArray = name.substr(7, name.length() - 8).split(", ")
		if parts.size() >= 2:
			name = parts[1]
	name = name.trim_prefix("ANGLE Metal Renderer: ")
	var noise: RegEx = RegEx.create_from_string("\\s*\\(0x[0-9A-Fa-f]+\\)|\\s+Direct3D.*$|\\s+vs_[0-9].*$")
	return noise.sub(name, "", true).strip_edges()


static func software(raw: String) -> bool:
	return RegEx.create_from_string(SOFTWARE_GPU).search(raw) != null
