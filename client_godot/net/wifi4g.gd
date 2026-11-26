extends RefCounted








const Settings = preload("res://settings.gd")


const SETTINGS_READS: Array[String] = ["net_wifi_4g"]
const KEY: String = "net_wifi_4g"
const JAVA_CLASS: String = "vn.loanchien.net1.Net1"
const POLL_MS: int = 250
const STATUS: String = "Mất Wi-Fi, đang chuyển sang 4G…"

var bridge: Variant = null
var wanted: Variant = null
var on: bool = false
var bound: bool = false
var last: Dictionary = {}
var _seen: int = -1
var _def: String = ""
var _next: int = 0


func setup() -> void :
	if bridge != null or not OS.has_feature("android") or not Engine.has_singleton("JavaClassWrapper"):
		return
	var wrapped: Variant = Engine.get_singleton("JavaClassWrapper").call("wrap", JAVA_CLASS)
	if has_java(wrapped, "state"):
		bridge = wrapped



static func has_java(o: Variant, method: String) -> bool:
	if not (o is Object) or not is_instance_valid(o):
		return false
	var obj: Object = o
	if obj.has_method(method):
		return true
	if obj.has_method("has_java_method"):
		return bool(obj.call("has_java_method", method))
	return obj.get_class() == "JavaClass"

func enabled() -> bool:
	if wanted != null:
		return bool(wanted)
	return Settings.value(KEY) == true



func tick(now: int, busy: bool) -> bool:
	if bridge == null or now < _next:
		return false
	_next = now + POLL_MS
	var want: bool = enabled()
	if want != on:
		_switch(want)
	if not on:
		return false
	last = parse(str(bridge.call("state")))
	var lost: int = int(last.get("lost", "0"))
	var was: String = _def
	_def = str(last.get("def", ""))
	if bound and last.get("bound", "0") != "1":
		bound = false
	if _seen < 0:
		_seen = lost
		return false
	if lost != _seen:
		_seen = lost

		if not bound and (was == "wifi" or _def == "wifi") and last.get("cell", "0") == "1" and bool(bridge.call("bindCell")):
			bound = true
			return true
		return false
	if bound and not busy and last.get("wifi", "0") == "1" and last.get("wv", "0") == "1":
		bridge.call("unbind")
		bound = false
	return false

func _switch(want: bool) -> void :
	_seen = -1
	bound = false
	if not want:
		bridge.call("stop")
		on = false
		return
	var ctx: Variant = null
	if Engine.has_singleton("AndroidRuntime"):
		ctx = Engine.get_singleton("AndroidRuntime").call("getApplicationContext")
	on = bool(bridge.call("startCtx", ctx)) if ctx != null else bool(bridge.call("start"))


static func parse(text: String) -> Dictionary:
	var out: Dictionary = {}
	for part: String in text.split(";", false):
		var cut: int = part.find("=")
		if cut > 0:
			out[part.substr(0, cut)] = part.substr(cut + 1)
	return out
