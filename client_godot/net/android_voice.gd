extends RefCounted












const JAVA_CLASS: String = "vn.loanchien.voice1.VoiceWeb"
const PERM: String = "android.permission.RECORD_AUDIO"
const POLLS: Array[String] = ["window.__bbv?window.__bbv.poll():''", "window.__bbmic?window.__bbmic.poll():''", 
	"window.__bbx?window.__bbx.poll():''"]
const CFG_PREFIXES: Array[String] = ["window.__bbv.cfg(", "window.__bbmic.cfg("]
const BOOT_MAX: int = 4




const BT_JS: String = "(function(){var W=window;if(W.__bbBt1)return;W.__bbBt1=1;var md=navigator.mediaDevices,live=[];"\
+ "if(md&&md.getUserMedia){var g=md.getUserMedia.bind(md);md.getUserMedia=function(c){return g(c).then(function(s){"\
+ "s.getAudioTracks().forEach(function(t){live.push(t);});return s;});};}"\
+ "function mic(){for(var i=0;i<live.length;i++){if(live[i].readyState==='live')return true;live.splice(i--,1);}return false;}"\
+ "function wrap(){var T=W.__bbTick;if(!T||T.__bt1)return!!T;var f=function(){var s=T();if(!s)return s;try{var r=JSON.parse(s);"\
+ "if(r.call&&!mic()){r.call=0;return JSON.stringify(r);}}catch(e){}return s;};f.__bt1=1;W.__bbTick=f;return true;}"\
+ "if(!wrap()){var n=0,iv=setInterval(function(){if(wrap()||++n>40)clearInterval(iv);},250);}})();"
const DENIED_TEXT: String = "Chưa cho phép dùng micro — bật quyền Micro cho app trong Cài đặt Android."

static var java: Variant = null
static var android: Variant = null
static var perm_state: String = ""
static var perm_asks: int = 0
static var origin: String = ""
static var _session: String = ""
static var _started: bool = false
static var _wrapped: bool = false
static var _boot: Array[String] = []
static var _cfg: Dictionary = {}
static var _wait_ok: Array[Callable] = []
static var _wait_no: Array[Callable] = []
static var _asking: bool = false
static var _listening: bool = false
static var _inst: RefCounted = null

static func is_android() -> bool:
	return bool(android) if android != null else OS.has_feature("android")


static func reset() -> void :
	java = null
	android = null
	perm_state = ""
	perm_asks = 0
	origin = ""
	_session = ""
	_started = false
	_wrapped = false
	_boot = []
	_cfg = {}
	_wait_ok = []
	_wait_no = []
	_asking = false
	_inst = null


static func has_session() -> bool:
	return not _session.is_empty()


static func session_shape(value: String) -> bool:
	if value.length() < 16 or value.length() > 256:
		return false
	for c: String in value:
		if not (c >= "A" and c <= "Z" or c >= "a" and c <= "z" or c >= "0" and c <= "9" or c in ["-", "_", ".", "~"]):
			return false
	return true


static func session_from_headers(headers: PackedStringArray) -> String:
	for line: String in headers:
		var colon: int = line.find(":")
		if colon <= 0 or line.substr(0, colon).strip_edges().to_lower() != "set-cookie":
			continue
		var parts: PackedStringArray = line.substr(colon + 1).split(";", false, 1)
		var pair: String = parts[0].strip_edges() if not parts.is_empty() else ""
		var eq: int = pair.find("=")
		if eq <= 0 or pair.substr(0, eq).strip_edges() != "bb_session":
			continue
		var value: String = pair.substr(eq + 1).strip_edges()
		return value if session_shape(value) else ""
	return ""


static func set_session(from_origin: String, value: String) -> void :
	if not is_android() or not session_shape(value):
		return
	origin = from_origin
	_session = value
	if _started and _java() != null:
		_java().call("session", value)


static func shutdown() -> void :
	_session = ""
	if _started and _java() != null:
		_java().call("stop")
	_started = false


static func bridge() -> Callable:
	if not is_android() or _java() == null:
		return Callable()
	return Callable(_instance(), "_call")

static func _instance() -> RefCounted:
	if _inst == null:
		_inst = load("res://net/android_voice.gd").new()
	return _inst

static func _java() -> Variant:
	if java == null and not _wrapped:
		_wrapped = true
		if OS.has_feature("android") and Engine.has_singleton("JavaClassWrapper"):
			var wrapped: Variant = Engine.get_singleton("JavaClassWrapper").call("wrap", JAVA_CLASS)
			if _has_java(wrapped, "ask"):
				java = wrapped
	return java


static func _has_java(o: Variant, method: String) -> bool:
	if not (o is Object) or not is_instance_valid(o):
		return false
	var obj: Object = o
	if obj.has_method(method):
		return true
	if obj.has_method("has_java_method"):
		return bool(obj.call("has_java_method", method))
	return obj.get_class() == "JavaClass"


static func _ensure() -> bool:
	var j: Variant = _java()
	if j == null or _session.is_empty():
		return false
	if _started and str(j.call("state")).begins_with("fail"):
		_started = false
	if _started:
		return true
	var activity: Variant = null
	if Engine.has_singleton("AndroidRuntime"):
		activity = Engine.get_singleton("AndroidRuntime").call("getActivity")
	if not bool(j.call("start", activity, origin, _session)):
		return false
	_started = true
	j.call("eval", BT_JS)
	for code: String in _boot:
		j.call("eval", code)
	for prefix: String in CFG_PREFIXES:
		if _cfg.has(prefix):
			j.call("eval", str(_cfg[prefix]))
	return true

func _call(code: String) -> Variant:
	var poll: bool = code in POLLS
	_remember(code)
	if not _ensure():
		return "" if poll else null
	if poll:
		return str(_java().call("ask", code))
	_java().call("eval", code)
	return null

static func _remember(code: String) -> void :
	if code.begins_with("(function"):
		if not code in _boot and _boot.size() < BOOT_MAX:
			_boot.append(code)
		return
	for prefix: String in CFG_PREFIXES:
		if code.begins_with(prefix):
			_cfg[prefix] = code



static func _granted_now() -> String:
	if not perm_state.is_empty():
		return perm_state
	return "granted" if PERM in OS.get_granted_permissions() else "ask"


static func mic_allowed() -> bool:
	return not is_android() or _granted_now() == "granted"



static func mic_ready(after: Callable, denied: Callable = Callable()) -> bool:
	if not is_android():
		return true
	if _granted_now() == "granted":
		return true
	if after.is_valid() and not after in _wait_ok:
		_wait_ok.append(after)
	if denied.is_valid() and not denied in _wait_no:
		_wait_no.append(denied)
	if _asking:
		return false
	_asking = true
	perm_asks += 1
	if not perm_state.is_empty():
		return false
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null and not _listening:
		_listening = true
		tree.on_request_permissions_result.connect(Callable(_instance(), "_on_perm"))
	if OS.request_permission(PERM):
		perm_result(true)
	return false

func _on_perm(permission: String, granted: bool) -> void :
	if permission == PERM:
		perm_result(granted)


static func perm_result(granted: bool) -> void :
	var ok: Array[Callable] = _wait_ok
	var no: Array[Callable] = _wait_no
	_wait_ok = []
	_wait_no = []
	_asking = false
	if not perm_state.is_empty():
		perm_state = "granted" if granted else "denied"
	for cb: Callable in (ok if granted else no):
		if cb.is_valid():
			cb.call()
