extends RefCounted














const SafeJson = preload("res://net/safe_json.gd")
const AndroidVoice = preload("res://net/android_voice.gd")
const POLLS: Array[String] = ["window.__bbv?window.__bbv.poll():''", "window.__bbmic?window.__bbmic.poll():''", 
	"window.__bbm?window.__bbm.poll():''", "window.__bbf?window.__bbf.poll():''", "window.__bbx?window.__bbx.poll():''"]
const CFG_PREFIXES: Array[String] = ["window.__bbv.cfg(", "window.__bbmic.cfg("]
const TICK: String = "window.__bbTick?window.__bbTick():''"
const LOGS: String = "window.__bbLogs?window.__bbLogs():''"
const BOOT_MAX: int = 6
const QUEUE_MAX: int = 32
const TICK_MS: int = 1500
const IDLE_MAX: int = 4
const LOG_MS: int = 2000
const DIAG_MAX: int = 80
const LOG_LEN: int = 220
const READ_MAX: int = 262144
const LINE_MAX: int = 4194304
const RETRY_MAX: int = 3
const RETRY_MS: int = 8000
const NO_RETRY: Array[String] = ["fail:arg", "fail:runtime", "fail:loader"]
const HELPER_RES: String = "res://assets/pc/voice/bbvoice.exe"
const LOADER_RES: String = "res://assets/pc/voice/WebView2Loader.dll"
const DIR: String = "user://pcvoice/"
const ASK_STALE_MS: int = 5000
const KILL_AFTER: float = 4.0

static var pc: Variant = null
static var helper_cmd: String = ""
static var helper_args: PackedStringArray = PackedStringArray()
static var origin: String = ""
static var diag: Array[String] = []
static var spawns: int = 0
static var _pc_cache: int = -1
static var _session: String = ""
static var _io: FileAccess = null
static var _err: FileAccess = null
static var _pid: int = 0
static var _state: String = "off"
static var _buf: PackedByteArray = PackedByteArray()
static var _boot: Array[String] = []
static var _cfg: Dictionary = {}
static var _results: Dictionary = {}
static var _inflight: Dictionary = {}
static var _asking: Dictionary = {}
static var _ask_at: Dictionary = {}
static var _next: int = 1
static var _fails: int = 0
static var _fail_at: int = -100000
static var _dead: bool = false
static var _want_tick: bool = false
static var _tick_at: int = -100000
static var _idle: int = 0
static var _log_at: int = -100000
static var _rx: Dictionary = {}
static var _inst: RefCounted = null
static var _drained: bool = false


static func is_pc() -> bool:
	if pc != null:
		return bool(pc)
	if _pc_cache < 0:
		_pc_cache = 1 if OS.has_feature("pc_app") and OS.has_feature("windows") and FileAccess.file_exists(HELPER_RES)\
		and FileAccess.file_exists(LOADER_RES) else 0
	return _pc_cache == 1


static func reset() -> void :
	_close(true)
	pc = null
	helper_cmd = ""
	helper_args = PackedStringArray()
	origin = ""
	diag = []
	spawns = 0
	_pc_cache = -1
	_session = ""
	_state = "off"
	_boot = []
	_cfg = {}
	_fails = 0
	_fail_at = -100000
	_dead = false
	_inst = null

static func has_session() -> bool:
	return not _session.is_empty()

static func state() -> String:
	return _state

static func running() -> bool:
	return _pid != 0 and OS.is_process_running(_pid)




static func blocked() -> String:
	if _session.is_empty():
		return "nosession"
	if _dead or (_fails >= RETRY_MAX and _pid == 0):
		return _state if _state.begins_with("fail") else "fail:exit"
	return ""


static func set_session(from_origin: String, value: String) -> void :
	if not is_pc() or not AndroidVoice.session_shape(value):
		return
	origin = from_origin
	_session = value
	_dead = false
	_fails = 0
	if running():
		_send("C " + esc(value))


static func shutdown() -> void :
	_session = ""
	_close(false)


static func bridge() -> Callable:
	if not is_pc():
		return Callable()
	if _inst == null:
		_inst = load("res://net/pc_voice.gd").new()
	return Callable(_inst, "_call")

func _call(code: String) -> Variant:
	var poll: bool = code in POLLS
	_remember(code)
	_pump()
	if not _ensure():
		return "" if poll else null
	if not poll:
		_send("E " + esc(code))
		return null
	var out: String = _take(code)
	_ask(code)
	if code == POLLS[0]:
		_tick()
		_logs()
	return out



static func _ensure() -> bool:
	if _session.is_empty() or _dead:
		return false
	if _pid != 0 and not OS.is_process_running(_pid):
		_pump()
		_exited()
	if _pid != 0:
		return not _state.begins_with("fail")
	if _fails >= RETRY_MAX or (_fails > 0 and Time.get_ticks_msec() - _fail_at < RETRY_MS):
		return false
	return _spawn()




static func _spawn() -> bool:
	var alt: bool = helper_cmd.is_empty() and _fails % 2 == 1
	var cmd: String = helper_cmd if not helper_cmd.is_empty() else _unpack(alt)
	if cmd.is_empty() and alt:
		cmd = _unpack(false)
	if cmd.is_empty():
		_state = "fail:copy"
		_dead = true
		return false
	if helper_cmd.is_empty() and not FileAccess.file_exists(cmd):
		_state = "fail:av"
		_fails += 1
		_fail_at = Time.get_ticks_msec()
		return false
	var args: PackedStringArray = helper_args.duplicate()
	args.append_array(PackedStringArray(["--origin", origin, "--parent", str(OS.get_process_id())]))
	_drained = false
	var p: Dictionary = OS.execute_with_pipe(cmd, args, true)
	spawns += 1
	if p.is_empty() or not (p.get("stdio") is FileAccess):
		_state = "fail:av" if helper_cmd.is_empty() and not FileAccess.file_exists(cmd) else "fail:spawn"
		_fails += 1
		_fail_at = Time.get_ticks_msec()
		return false
	_io = p.stdio
	_err = p.get("stderr") as FileAccess
	_pid = int(p.get("pid", 0))
	_state = "load"
	_buf = PackedByteArray()
	_send("C " + esc(_session))
	for code: String in _boot:
		_send("E " + esc(code))
	for prefix: String in CFG_PREFIXES:
		if _cfg.has(prefix):
			_send("E " + esc(str(_cfg[prefix])))
	return true


static func _exited() -> void :
	var why: String = _state
	_drop_io()
	_fails += 1
	_fail_at = Time.get_ticks_msec()
	if why in NO_RETRY:
		_dead = true
	_state = why if why.begins_with("fail") else "fail:exit"

static func _close(now: bool) -> void :
	var pid: int = _pid
	if pid != 0 and OS.is_process_running(pid):
		_send("X")
		var tree: SceneTree = Engine.get_main_loop() as SceneTree
		if now or tree == null:
			OS.kill(pid)
		else:
			tree.create_timer(KILL_AFTER).timeout.connect( func() -> void :
				if OS.is_process_running(pid):
					OS.kill(pid))
	_drop_io()
	_state = "off"

static func _drop_io() -> void :
	if _io != null:
		_io.close()
	if _err != null:
		_err.close()
	_io = null
	_err = null
	_pid = 0
	_buf = PackedByteArray()
	_results = {}
	_inflight = {}
	_asking = {}
	_ask_at = {}
	_want_tick = false
	_idle = 0


static func _unpack(alt: bool = false) -> String:
	var exe: PackedByteArray = FileAccess.get_file_as_bytes(HELPER_RES)
	var dll: PackedByteArray = FileAccess.get_file_as_bytes(LOADER_RES)
	if exe.is_empty() or dll.is_empty():
		return ""
	var h: HashingContext = HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	h.update(exe)
	h.update(dll)
	var root: String = DIR
	if alt:
		root = OS.get_executable_path().get_base_dir().path_join("voice") + "/"
	var dir: String = root + h.finish().hex_encode().substr(0, 16) + "/"
	if DirAccess.make_dir_recursive_absolute(dir) != OK and not DirAccess.dir_exists_absolute(dir):
		return ""
	if not _put(dir + "WebView2Loader.dll", dll) or not _put(dir + "bbvoice.exe", exe):
		return ""
	return ProjectSettings.globalize_path(dir + "bbvoice.exe")

static func _put(path: String, data: PackedByteArray) -> bool:
	if FileAccess.file_exists(path) and FileAccess.get_file_as_bytes(path) == data:
		return true
	var tmp: String = path + ".tmp"
	var f: FileAccess = FileAccess.open(tmp, FileAccess.WRITE)
	if f == null:
		return false
	f.store_buffer(data)
	f.close()
	DirAccess.remove_absolute(path)
	return DirAccess.rename_absolute(tmp, path) == OK



static func _send(line: String) -> void :
	if _io == null:
		return
	_io.store_buffer((line + "\n").to_utf8_buffer())
	_io.flush()


static func _pump() -> void :


	var dead: bool = _pid != 0 and not OS.is_process_running(_pid)
	if dead and _drained:
		return
	_drained = dead
	if _err != null and not dead:
		var e: int = _err.get_length()
		if e > 0:
			_err.get_buffer(mini(e, READ_MAX))
	if _io == null:
		return
	var got: int = 0
	var n: int = _io.get_length()
	while n > 0 and got < READ_MAX:
		var chunk: PackedByteArray = _io.get_buffer(mini(n, READ_MAX - got))
		if chunk.is_empty():
			break
		got += chunk.size()
		_buf.append_array(chunk)
		n = 0 if dead else _io.get_length()
	var start: int = 0
	var at: int = _buf.find(10)
	while at >= 0:
		_line(_buf.slice(start, at).get_string_from_utf8())
		start = at + 1
		at = _buf.find(10, start)
	if start > 0:
		_buf = _buf.slice(start)
	if _buf.size() > LINE_MAX:
		_buf = PackedByteArray()

static func _line(s: String) -> void :
	if s.begins_with("S "):
		var st: String = s.substr(2)
		if _re("^[a-z]+(:[a-z0-9]+)?$").search(st) != null and st.length() <= 32:
			_state = st
		return
	if not s.begins_with("R "):
		return
	var sp: int = s.find(" ", 2)
	if sp < 0:
		return
	var id: int = s.substr(2, sp - 2).to_int()
	if not _inflight.has(id):
		return
	var expr: String = _inflight[id]
	_inflight.erase(id)
	_ask_at.erase(id)
	_asking.erase(expr)
	var text: String = decode(unesc(s.substr(sp + 1)))
	if text.is_empty():
		return
	if expr == TICK:
		_on_tick(text)
		return
	if expr == LOGS:
		_on_logs(text)
		return
	if expr == POLLS[0]:
		_want_tick = voice_on(text)
	var q: Array = _results.get(expr, [])
	if q.size() >= QUEUE_MAX:
		q.pop_front()
	q.append(text)
	_results[expr] = q

static func _take(expr: String) -> String:
	var q: Array = _results.get(expr, [])
	return str(q.pop_front()) if not q.is_empty() else ""

static func _ask(expr: String) -> void :
	if _state != "ready":
		return
	if _asking.has(expr):
		var old: int = int(_asking[expr])
		if Time.get_ticks_msec() - int(_ask_at.get(old, 0)) < ASK_STALE_MS:
			return
		_inflight.erase(old)
		_ask_at.erase(old)
	var id: int = _next
	_next += 1
	_asking[expr] = id
	_inflight[id] = expr
	_ask_at[id] = Time.get_ticks_msec()
	_send("A %d %s" % [id, esc(expr)])

static func _remember(code: String) -> void :
	if code.begins_with("(function"):
		if not code in _boot and _boot.size() < BOOT_MAX:
			_boot.append(code)
		return
	for prefix: String in CFG_PREFIXES:
		if code.begins_with(prefix):
			_cfg[prefix] = code




static func voice_on(poll_result: String) -> bool:
	var m: RegExMatch = _re("\"st\":\\{([^{}]*)\\}").search(poll_result)
	return m != null and _re(":\"(?:on|join)\"").search(m.get_string(1)) != null

static func _tick() -> void :
	if not _want_tick or Time.get_ticks_msec() - _tick_at < TICK_MS:
		return
	_tick_at = Time.get_ticks_msec()
	_ask(TICK)

static func _on_tick(text: String) -> void :
	var o: Variant = SafeJson.parse(text)
	var on: int = int((o as Dictionary).get("on", 0)) if o is Dictionary else 0
	_idle = 0 if on == 1 else _idle + 1
	if _idle >= IDLE_MAX:
		_want_tick = false
		_idle = 0

static func _logs() -> void :
	if Time.get_ticks_msec() - _log_at < LOG_MS:
		return
	_log_at = Time.get_ticks_msec()
	_ask(LOGS)

static func _on_logs(text: String) -> void :
	for raw: String in text.split("\n", false):
		var line: String = clean(raw)
		if line.is_empty():
			continue
		diag.append(line)
		if diag.size() > DIAG_MAX:
			diag.pop_front()
		print("voice-pc: ", line)



static func esc(s: String) -> String:
	return s.replace("\\", "\\\\").replace("\n", "\\n").replace("\r", "\\r")


static func unesc(s: String) -> String:
	if not s.contains("\\"):
		return s
	var parts: PackedStringArray = s.split("\\\\")
	for i: int in parts.size():
		if parts[i].contains("\\"):
			parts[i] = _re("\\\\(.)").sub(parts[i].replace("\\n", "\n").replace("\\r", "\r"), "$1", true)
	return "\\".join(parts)


static func decode(raw: String) -> String:
	if raw.is_empty() or raw == "null":
		return ""
	var v: Variant = SafeJson.parse(raw)
	return v if v is String else ""


static func clean(s: String) -> String:
	var t: String = _re("[\\x00-\\x1f\\x7f]+").sub(s, " ", true)
	t = _re("([A-Za-z][A-Za-z0-9+.-]*://[^\\s'\"?#]*)[?#][^\\s'\"]*").sub(t, "$1?…", true)
	t = _re("eyJ[A-Za-z0-9_-]*(?:\\.[A-Za-z0-9_-]*)+").sub(t, "<jwt>", true)
	t = _re("[A-Za-z0-9_-]{24,}").sub(t, "<…>", true)
	t = _re("\\b(?:\\d{1,3}\\.){3}\\d{1,3}\\b").sub(t, "<ip>", true)
	t = _re("(?<![\\w:])(?:(?:[0-9A-Fa-f]{1,4}:){3,7}[0-9A-Fa-f]{1,4}|(?:[0-9A-Fa-f]{1,4}:){0,6}[0-9A-Fa-f]{0,4}::[0-9A-Fa-f]{0,4}(?::[0-9A-Fa-f]{1,4}){0,6})(?![\\w:])").sub(t, "<ip>", true)
	t = _re("\\bc\\d{3,}\\b").sub(t, "c#", true)
	t = t.strip_edges()
	return t.substr(0, LOG_LEN) + "…" if t.length() > LOG_LEN else t

static func _re(p: String) -> RegEx:
	if not _rx.has(p):
		_rx[p] = RegEx.create_from_string(p)
	return _rx[p]
