extends RefCounted







const AndroidVoice = preload("res://net/android_voice.gd")

static var native: Variant = null
static var _origin: String = ""
static var _session: String = ""
static var on_login: Callable = Callable()

static func is_native() -> bool:
	if native != null:
		return bool(native)
	return not OS.has_feature("web")

static func set_session(from_origin: String, value: String) -> void :
	if not is_native() or from_origin.is_empty() or not AndroidVoice.session_shape(value):
		return
	_origin = from_origin
	_session = value

static func has_session() -> bool:
	return not _session.is_empty()


static func logged_in() -> void :
	if on_login.is_valid():
		on_login.call()


static func forget() -> void :
	_origin = ""
	_session = ""


static func headers(url: String) -> PackedStringArray:
	if not is_native() or _session.is_empty() or not url.begins_with(_origin + "/"):
		return PackedStringArray()
	return PackedStringArray(["Cookie: bb_session=" + _session])
