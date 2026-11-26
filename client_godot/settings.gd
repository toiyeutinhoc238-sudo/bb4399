extends RefCounted



const DEFAULTS: Dictionary = {
	"music": true, 
	"music_vol": 0.5, 
	"sfx": true, 
	"sfx_vol": 0.8, 
	"voice": true, 
	"zoom": 1.0, 
	"pc_zoom": 100, 
	"pc_mouse_lock": true, 
	"cam_pan_speed": 70, 

	"numbers": true, 
	"fps": true, 
	"fps_cap": 0, 
	"skill_fx": true, 
	"skill_name": true, 
	"cursor": true, 
	"cursor_size": 100, 

	"quality": 1, 
	"lobby_bar": "bright", 
	"lobby_theme": "island", 
	"lobby_daynight": "auto", 
	"lobby_fx": true, 

	"mic_device": "", 
	"mic_gain": 100, 
	"mic_mute": false, 
	"mic_ns": 1, 
	"mic_ec": true, 
	"mic_agc": true, 
	"mic_gate": 0.35, 
	"mic_gate_auto": true, 
	"mic_mode": "ptt", 
	"mic_ptt_key": 86, 
	"voice_play_vol": 100, 


	"tc_cast": "drag", 


	"tc_cast_0": "auto", 
	"tc_cast_1": "auto", 
	"tc_cast_2": "auto", 
	"tc_cast_3": "auto", 
	"tc_self_hold": true, 
	"tc_cancel": "zone", 
	"tc_sens": 50, 
	"tc_stick": "follow", 
	"tc_aim": "off", 
	"tc_target": "near", 
	"tc_mark": true, 
	"tc_zone": true, 
	"tc_pick": true, 
	"tc_fire_move": true, 
	"tc_face_keep": true, 
	"tc_pve": "near", 
	"tc_btn_scale": 100, 
	"tc_btn_alpha": 100, 
	"tc_pad_skill": 40, 
	"tc_pad_stick": 40, 
	"tc_btn_fade": true, 
	"tc_layout": 0, 
	"tc_layout_0": "", 
	"tc_layout_1": "", 
	"tc_layout_2": "", 
	"tc_mm_side": "left", 
	"tc_mm_scale": 100, 
	"tc_target_info": false, 
	"tc_tips": true, 
	"tc_chat": true, 
	"tc_pan": "swipe", 
	"tc_pan_dir": "lq", 
	"tc_view": "mid", 
	"tc_return": 1500, 
	"tc_smooth": "mid", 
	"tc_frame": true, 
	"tc_mapfollow": true, 
	"tc_edge": true, 
	"net_wifi_4g": false, 
	"tc_bright": 100, 
	"master_vol": 100, 
	"tc_vibrate": true, 

	"tc_fps": 60, 
	"tc_gfx": "high", 
	"tc_outline": false, 
	"tc_eco": false, 

	"tc_ping_mute": false, 
	"tc_qc": "", 
	"chat_scene_off": false, 
}

const CAST_CELL: Array = ["auto", "drag", "tap", "smart"]

const CHOICES: Dictionary = {
	"tc_cast": ["drag", "tap"], "tc_cast_0": CAST_CELL, "tc_cast_1": CAST_CELL, "tc_cast_2": CAST_CELL, "tc_cast_3": CAST_CELL, "tc_cancel": ["zone", "range"], "tc_stick": ["follow", "fixed"], "tc_aim": ["off", "light", "strong"], 
	"tc_target": ["near", "hp", "hp_pct"], "tc_pve": ["near", "boss"], "tc_mm_side": ["left", "right"], "tc_layout": [0, 1, 2], 
	"tc_pan": ["swipe", "minimap"], "tc_pan_dir": ["lq", "grab"], "tc_view": ["near", "mid", "far"], "tc_return": [1500, 100, 500, 3000, 0], "tc_smooth": ["mid", "off", "low", "high"], 
	"tc_fps": [60, 30, 90, 0], "tc_gfx": ["high", "mid", "low"], 
	"pc_zoom": [50, 67, 75, 80, 90, 100, 110, 125, 150], 
}

const RANGES: Dictionary = {
	"tc_sens": [1, 100, 1], "tc_btn_scale": [80, 130, 5], "tc_btn_alpha": [30, 100, 5], "tc_pad_skill": [0, 100, 5], "tc_pad_stick": [0, 100, 5], "tc_mm_scale": [80, 130, 5], 
	"tc_bright": [70, 130, 5], "master_vol": [0, 100, 1], 
	"cursor_size": [75, 200, 25], 
}

const LAYOUT_MAX: int = 4096

const QC_MAX: int = 1024


const LOBBY_BARS: Array[String] = ["bright", "glass"]

const LOBBY_DAYNIGHT: Array[String] = ["auto", "day", "night"]


const MIC_MODES: Array[String] = ["off", "ptt", "open"]
const MIC_NS: Array[int] = [0, 1, 2]


const PAN_MIN: int = 25
const PAN_MAX: int = 200


const FPS_CAPS: Array[int] = [0, 30, 60, 90, 120, 144, 240]

const QUALITIES: Array[int] = [1, 2]


const IOS_OVERRIDES: Dictionary = {"tc_fps": 30}
const IOS_MARK: String = "ios30"

static var path: String = "user://settings.cfg"
static var force_ios: int = -1
static var _values: Dictionary = {}
static var _loaded: bool = false
static var _watchers: Array[Callable] = []
static var _dirty: bool = false

static var drop: int = 0

static var render_k: float = 1.0
static var render_scale: float = 0.0



static var css_floor: float = 1.0


static var dpr_mul: float = 1.0

static func _load() -> void :
	if _loaded:
		return
	_loaded = true
	_values = defaults()
	if path.is_empty():
		return
	var file: ConfigFile = ConfigFile.new()
	if file.load(path) != OK:
		return
	var fresh: bool = ios() and not file.has_section_key("s", IOS_MARK)
	for key: String in DEFAULTS:
		if file.has_section_key("s", key) and not (fresh and IOS_OVERRIDES.has(key)):
			_values[key] = clean(key, file.get_value("s", key))

	if not file.has_section_key("s", "fps_cap"):
		_values["fps"] = DEFAULTS["fps"]


static func clean(key: String, value: Variant) -> Variant:
	var base: Variant = default_of(key)
	if key.begins_with("tc_layout_"):
		return str(value) if value is String and str(value).length() <= LAYOUT_MAX else base
	if key == "tc_qc":
		return str(value) if value is String and str(value).length() <= QC_MAX else base
	if CHOICES.has(key):
		var list: Array = CHOICES[key]
		if base is String:
			return str(value) if (value is String or value is StringName) and list.has(str(value)) else base
		var ok: bool = (value is int or value is float) and is_finite(float(value)) and float(value) == float(int(value)) and list.has(int(value))
		return int(value) if ok else base
	if RANGES.has(key):
		if not (value is int or value is float) or not is_finite(float(value)):
			return base
		var r: Array = RANGES[key]
		return clampi(int(r[0]) + roundi((float(value) - float(r[0])) / float(r[2])) * int(r[2]), int(r[0]), int(r[1]))
	if base is bool:
		return value if value is bool else base
	if base is String:

		if not (value is String or value is StringName):
			return base
		var text: String = str(value)
		if key == "lobby_bar":
			return text if LOBBY_BARS.has(text) else base
		if key == "lobby_daynight":
			return text if LOBBY_DAYNIGHT.has(text) else base

		if key == "mic_device":
			return text if value is String and text.length() <= 256 else base
		if key == "mic_mode":
			return text if MIC_MODES.has(text) else base
		return text if RegEx.create_from_string("^[a-z0-9_]{1,32}$").search(text) != null else base
	if not (value is float or value is int):
		return base
	if key == "zoom":
		return clampf(roundf(float(value) * 4.0) / 4.0, 1.0, 2.0)
	if key == "cam_pan_speed":

		return clampi(roundi(float(value) / 5.0) * 5, PAN_MIN, PAN_MAX) if is_finite(float(value)) else int(base)
	if key == "fps_cap":

		return int(value) if float(value) == float(int(value)) and FPS_CAPS.has(int(value)) else 0
	if key == "quality":

		return int(value) if float(value) == float(int(value)) and QUALITIES.has(int(value)) else 1
	if key.begins_with("mic_") and not is_finite(float(value)):
		return base
	if key == "mic_gain":
		return clampi(roundi(float(value)), 0, 200)
	if key == "voice_play_vol":
		return clampi(roundi(float(value)), 0, 200) if is_finite(float(value)) else int(base)
	if key == "mic_ns":
		return int(value) if float(value) == float(int(value)) and MIC_NS.has(int(value)) else int(base)
	if key == "mic_ptt_key":
		return int(value) if float(value) == float(int(value)) and int(value) > 0 and int(value) < (1 << 23) else int(base)
	return clampf(float(value), 0.0, 1.0)


static func pan_scale() -> float:
	return float(int(value("cam_pan_speed"))) / 100.0


static func cursor_step(cur: int, dir: int) -> int:
	var r: Array = RANGES["cursor_size"]
	var n: int = (int(r[1]) - int(r[0])) / int(r[2]) + 1
	var i: int = (int(clean("cursor_size", cur)) - int(r[0])) / int(r[2])
	return int(r[0]) + posmod(i + dir, n) * int(r[2])


static func next_cap(cap: int) -> int:
	return FPS_CAPS[(FPS_CAPS.find(cap) + 1) % FPS_CAPS.size()]


static func next_quality(quality: int) -> int:
	return QUALITIES[(QUALITIES.find(quality) + 1) % QUALITIES.size()]




static func css_size(window: Vector2) -> Vector2:
	var scale: float = render_scale if render_scale > 0.0 else DisplayServer.screen_get_scale()
	return window / maxf(render_k * css_floor, scale * dpr_mul)


static func native_size(window: Vector2) -> Vector2:
	return window / render_k

static func value(key: String) -> Variant:
	_load()
	return _values.get(key, DEFAULTS.get(key))

static func on(key: String) -> bool:
	return bool(value(key))

static func level(key: String) -> float:
	return float(value(key))


static func put(key: String, new_value: Variant, store: bool = true) -> void :
	_load()
	if not DEFAULTS.has(key):
		return
	var cleaned: Variant = clean(key, new_value)
	if _values.get(key) != cleaned:
		_values[key] = cleaned
		_dirty = true
		_tell(key)
	if store:
		save()

static func reset() -> void :
	_load()
	if is_default():
		return
	_values = defaults()
	_dirty = true
	save()
	_tell("")

static func is_default() -> bool:
	_load()
	var base: Dictionary = defaults()
	for key: String in DEFAULTS:
		if _values.get(key) != base[key]:
			return false
	return true


static func ios() -> bool:
	return force_ios == 1 if force_ios >= 0 else (OS.has_feature("web_ios") or OS.has_feature("ios"))


static func defaults() -> Dictionary:
	var base: Dictionary = DEFAULTS.duplicate()
	if ios():
		base.merge(IOS_OVERRIDES, true)
	return base

static func default_of(key: String) -> Variant:
	return IOS_OVERRIDES[key] if ios() and IOS_OVERRIDES.has(key) else DEFAULTS.get(key)

static func save() -> void :
	if not _dirty or path.is_empty():
		_dirty = false
		return
	_dirty = false
	var file: ConfigFile = ConfigFile.new()
	for key: String in DEFAULTS:
		file.set_value("s", key, _values[key])
	if ios():
		file.set_value("s", IOS_MARK, true)
	file.save(path)


static func reload() -> void :
	_loaded = false
	_dirty = false
	_load()
	_tell("")


static func watch(listener: Callable) -> void :
	_watchers.append(listener)

static func _tell(key: String) -> void :
	for i in range(_watchers.size() - 1, -1, -1):
		if _watchers[i].is_valid():
			_watchers[i].call(key)
		else:
			_watchers.remove_at(i)
