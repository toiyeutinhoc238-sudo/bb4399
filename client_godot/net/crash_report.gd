extends Node













const BUILD: String = preload("res://ui/settings.gd").BUILD
const AppSession = preload("res://net/app_session.gd")
const PATH: String = "/api/client-error"
const FLAG: String = "user://fn1_running.txt"
const PRE_LOGIN: Array = ["login", "auth", "servers", "connecting"]
const FIRST_DELAY: float = 5.0
const SEND_EVERY: float = 30.0
const MAX_ITEMS: int = 6
const MAX_POSTS: int = 12
const MAX_SIGS: int = 40
const MAX_BODY: int = 3800
const MEM_EVERY: float = 30.0
const MEM_STEP: int = 100
const WEB_JS: String = "(function(){var w=window;if(!w.__bbFn1){var P='bbFn1Run.',F='bbFn1Fatal',now=Date.now(),tab='',ls=null,o={crash:[],st:''};"\
+ "try{ls=w.localStorage;}catch(e){}try{tab=sessionStorage.getItem('bbFn1Tab')||'';}catch(e){}"\
+ "if(!tab){tab=Math.random().toString(36).slice(2,10);try{sessionStorage.setItem('bbFn1Tab',tab);}catch(e){}}"\
+ "var fatal='';if(ls){try{fatal=ls.getItem(F)||'';ls.removeItem(F);for(var i=ls.length-1;i>=0;i--){var k=ls.key(i);"\
+ "if(!k||k.indexOf(P)!==0)continue;var v=(ls.getItem(k)||'').split('|');var t=+v[2]||0;"\
+ "if(k===P+tab||now-t>20000){o.crash.push({b:v[0]||'',st:v[1]||'',f:'',m:v[3]||''});ls.removeItem(k);}}}catch(e){}}"\
+ "if(fatal){if(o.crash.length)o.crash[0].f=fatal;else o.crash.push({b:'',st:'',f:fatal});}"\
+ "var key=P+tab,off=function(){try{ls&&ls.removeItem(key);}catch(e){}},"\
+ "mem=function(){var j=0;try{var m=performance.memory;if(m)j=Math.round(m.usedJSHeapSize/1048576);}catch(e){}return (o.mem||'0/0')+'/'+j;},"\
+ "put=function(){if(!o.st||document.visibilityState==='hidden')return;try{ls&&ls.setItem(key,o.st+'|'+Date.now()+'|'+mem());}catch(e){}};"\
+ "o.set=function(s){o.st=s;put();};setInterval(put,5000);"\
+ "document.addEventListener('visibilitychange',function(){if(document.visibilityState==='hidden')off();else put();});"\
+ "w.addEventListener('pagehide',off);"\
+ "var bad=function(m){m=String(m||'');if(/RuntimeError|unreachable|out of memory|Aborted|memory access/i.test(m)){try{ls&&ls.setItem(F,m.slice(0,160));}catch(e){}}};"\
+ "w.addEventListener('error',function(e){bad(e&&(e.message||(e.error&&e.error.message)));});"\
+ "w.addEventListener('unhandledrejection',function(e){var r=e&&e.reason;bad(r&&(r.message||r));});w.__bbFn1=o;}"\
+ "var c=w.__bbFn1.crash;w.__bbFn1.crash=[];return JSON.stringify(c);})()"

class Catch extends Logger:
	var lock: Mutex = Mutex.new()
	var sigs: Dictionary = {}
	var order: Array = []
	var dropped: int = 0
	var state: String = ""
	const LIMIT: int = 40

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, 
			error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void :
		if error_type != ERROR_TYPE_SCRIPT and error_type != ERROR_TYPE_ERROR:
			return
		var msg: String = code if rationale.is_empty() else (rationale + " | " + code)
		add("script" if error_type == ERROR_TYPE_SCRIPT else "error", msg, "%s:%d %s" % [file.get_file(), line, function]
			+ Catch.caller(_script_backtraces, file.get_file(), line))



	static func caller(traces: Array[ScriptBacktrace], file: String, line: int) -> String:
		for bt: ScriptBacktrace in traces:
			if bt == null or bt.is_empty():
				continue
			for i: int in mini(bt.get_frame_count(), 2):
				var f: String = bt.get_frame_file(i).get_file()
				var l: int = bt.get_frame_line(i)
				if f == file and l == line:
					continue
				return " ← %s:%d %s" % [f, l, bt.get_frame_function(i)]
		return ""

	func _log_message(_message: String, _error: bool) -> void :
		pass

	func add(kind: String, msg: String, src: String, st: String = "") -> void :
		msg = msg.strip_edges().substr(0, 180)
		src = src.substr(0, 160)
		var sig: String = kind + "|" + msg.substr(0, 120) + "|" + src
		lock.lock()
		if sigs.has(sig):
			sigs[sig]["n"] += 1
		elif sigs.size() < LIMIT:
			sigs[sig] = {"k": kind, "m": msg, "s": src, "st": st if not st.is_empty() else state, "n": 1, 
				"up": int(Time.get_ticks_msec() / 1000)}
			order.append(sig)
		else:
			dropped += 1
		lock.unlock()

	func set_state(value: String) -> void :
		lock.lock()
		state = value
		lock.unlock()


	func take(limit: int) -> Array:
		var out: Array = []
		lock.lock()
		for sig: String in order:
			var it: Dictionary = sigs[sig]
			if int(it["n"]) <= 0:
				continue
			out.append({"k": it["k"], "m": it["m"], "s": it["s"], "st": it["st"], "n": it["n"], "up": it["up"]})
			it["n"] = 0
			if out.size() >= limit:
				break
		lock.unlock()
		return out

	func waiting() -> bool:
		lock.lock()
		var any: bool = false
		for sig: String in order:
			if int(sigs[sig]["n"]) > 0:
				any = true
				break
		lock.unlock()
		return any

var client: Node
var force: bool = false
var fetch: Callable = Callable()
var flag_path: String = FLAG
var web: bool = OS.has_feature("web")
var sid: String = ""
var posts: int = 0
var stopped: bool = false
var _catch: Catch = Catch.new()
var _http: HTTPRequest
var _busy: bool = false
var _wait: float = 0.0
var _tick: float = 0.0
var _mem_t: float = 0.0
var mem_extra: Callable = Callable()
var _state: String = ""
var _since_login: float = -1.0
var _paused: bool = false
var _on: bool = false


func live() -> bool:
	if force:
		return true
	if BUILD == "dev" or DisplayServer.get_name() == "headless":
		return false
	var loop: MainLoop = Engine.get_main_loop()
	return loop != null and loop.get_script() == null

static func platform() -> String:
	if OS.has_feature("web"):
		var ua: String = str(JavaScriptBridge.eval("navigator.userAgent||''", true))
		var touch: int = int(JavaScriptBridge.eval("navigator.maxTouchPoints||0", true))
		if ua.contains("iPhone") or ua.contains("iPad") or ua.contains("iPod") or (ua.contains("Macintosh") and touch > 1):
			return "ios_web"
		return "android_web" if ua.contains("Android") else "web_pc"
	if OS.has_feature("android"):
		return "android_app"
	if OS.has_feature("ios"):
		return "ios_app"
	if OS.has_feature("pc_app") or OS.has_feature("windows") or OS.has_feature("macos") or OS.has_feature("linuxbsd"):
		return "app_pc"
	return "unknown"

func _ready() -> void :
	_on = live()
	if not _on:
		set_process(false)
		return
	sid = "%08x%08x" % [randi(), randi()]
	OS.add_logger(_catch)
	_check_previous()
	_state = _client_state()
	_catch.set_state(_state)
	_mark()
	_http = HTTPRequest.new()
	_http.timeout = 15.0
	add_child(_http)
	_http.request_completed.connect(_done)

func _exit_tree() -> void :
	if not _on:
		return
	OS.remove_logger(_catch)
	_unmark()

func _notification(what: int) -> void :
	if not _on:
		return
	if what == NOTIFICATION_APPLICATION_PAUSED:
		_paused = true
		_unmark()
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		_paused = false
		_mark()
	elif what == NOTIFICATION_PREDELETE:
		_unmark()



func quit_flush() -> void :
	if not _on:
		return
	_paused = true
	_unmark()

func _client_state() -> String:
	var s: String = str(client.get("state")) if client != null else ""
	return s if RegEx.create_from_string("^[a-z_0-9]{1,32}$").search(s) != null else ""


func _check_previous() -> void :
	if web:
		var raw: Variant = JavaScriptBridge.eval(WEB_JS, true)
		var json: JSON = JSON.new()
		var list: Variant = json.data if raw != null and json.parse(str(raw)) == OK else null
		if list is Array:
			for it: Variant in list:
				if it is Dictionary:
					_crash(str(it.get("b", "")), str(it.get("st", "")), str(it.get("f", "")), str(it.get("m", "")))
		return
	if FileAccess.file_exists(flag_path):
		var parts: PackedStringArray = FileAccess.get_file_as_string(flag_path).strip_edges().split("|")
		_crash(parts[0] if parts.size() > 0 else "", parts[1] if parts.size() > 1 else "", "", parts[3] if parts.size() > 3 else "", 
			parts[4] if parts.size() > 4 else "")

func _crash(build: String, st: String, fatal: String, mem: String = "", groups: String = "") -> void :
	var b: String = build if RegEx.create_from_string("^(G6b[0-9]{1,5}|dev)$").search(build) != null else "?"
	var s: String = st if RegEx.create_from_string("^[a-z_0-9]{1,32}$").search(st) != null else ""
	_catch.add("crash", "Phiên trước tắt bất thường" + ("" if fatal.is_empty() else ": " + fatal.substr(0, 140)), "bản trước " + b + mem_text(mem) + group_text(groups), s)



static func mem_text(mem: String) -> String:
	var parts: PackedStringArray = mem.split("/")
	var names: Array = ["RAM", "đồ hoạ", "JS"]
	var out: String = ""
	for i: int in mini(parts.size(), names.size()):
		if not parts[i].is_valid_int() or parts[i].to_int() <= 0:
			continue
		out += " · %s ≥%dMB" % [names[i], (mini(parts[i].to_int(), 99999) / MEM_STEP) * MEM_STEP]
	return out


static func group_text(groups: String) -> String:
	var parts: PackedStringArray = groups.split("/")
	if parts.size() != 4:
		return ""
	var out: PackedStringArray = []
	var names: Array = ["fx", "map", "xe", "ui"]
	for i: int in range(4):
		if not parts[i].is_valid_int():
			return ""
		out.append("%s ≥%d" % [names[i], (clampi(parts[i].to_int(), 0, 99999) / MEM_STEP) * MEM_STEP])
	return " · ảnh gói " + " ".join(out) + "MB"


static func mem_now() -> String:
	return "%d/%d" % [int(OS.get_static_memory_usage() >> 20), int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)) >> 20]

func _mark() -> void :
	if _paused:
		return
	var mem: String = mem_now()
	var line: String = "%s|%s|%d|%s" % [BUILD, _state, int(Time.get_unix_time_from_system()), mem]
	if web:
		JavaScriptBridge.eval("window.__bbFn1&&(window.__bbFn1.mem='%s',window.__bbFn1.set('%s|%s'))" % [mem, BUILD.replace("'", ""), _state], true)
		return
	if mem_extra.is_valid():
		line += "|" + str(mem_extra.call())
	var f: FileAccess = FileAccess.open(flag_path, FileAccess.WRITE)
	if f != null:
		f.store_string(line)
		f.close()

func _unmark() -> void :
	if web:
		return
	if FileAccess.file_exists(flag_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(flag_path) if flag_path.begins_with("user://") else flag_path)

func _process(delta: float) -> void :
	_tick += delta
	if _tick < 1.0:
		return
	var step: float = _tick
	_tick = 0.0
	var s: String = _client_state()
	_mem_t += step
	if s != _state or _mem_t >= MEM_EVERY:
		_mem_t = 0.0
		_state = s
		_catch.set_state(s)
		_mark()
	if s in PRE_LOGIN or s.is_empty():
		return
	if _since_login < 0.0:
		_since_login = 0.0
	_since_login += step
	_wait = maxf(0.0, _wait - step)
	if _since_login >= FIRST_DELAY and _wait <= 0.0:
		send_now()


func send_now() -> bool:
	if stopped or _busy or posts >= MAX_POSTS or not _catch.waiting():
		return false
	if client != null and client.get("config") != null and client.config.get("local_test_only") == true and not fetch.is_valid():
		return false
	var items: Array = _catch.take(MAX_ITEMS)
	var body: String = _body(items)
	while body.to_utf8_buffer().size() > MAX_BODY and items.size() > 1:
		items.pop_back()
		body = _body(items)
	if items.is_empty():
		return false
	var origin: String = str(client.config.get("origin")) if client != null and client.get("config") != null else ""
	var url: String = origin.trim_suffix("/") + PATH
	posts += 1
	_wait = SEND_EVERY
	if fetch.is_valid():
		return fetch.call(url, body) == OK
	if origin.is_empty() or _http == null:
		return false
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	headers.append_array(AppSession.headers(url))
	_busy = _http.request(url, headers, HTTPClient.METHOD_POST, body) == OK
	return _busy

func _body(items: Array) -> String:
	return JSON.stringify({"v": BUILD, "pf": platform(), "sid": sid, "items": items})

func _done(_result: int, code: int, _headers: PackedStringArray, _body_bytes: PackedByteArray) -> void :
	_busy = false
	if code == 404 or code == 405:
		stopped = true
	elif code == 429:
		_wait = 600.0
