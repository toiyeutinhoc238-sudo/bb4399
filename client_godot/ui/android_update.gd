extends Node
















signal ready_tag(tag: String)



signal finished(kind: String, was: String)

const SafeJson = preload("res://net/safe_json.gd")
const ClientConfig = preload("res://client_config.gd")
const PAGE: String = "http://127.0.0.1:8080/godot/app/lc/"
const DIR: String = "user://pck/"
const STATE: String = "user://pck/state.json"
const MAX_PCK: int = 200 << 20
const OK_STATES: Array = ["login", "servers", "lobby"]
const PcLive = preload("res://ui/pc_launcher_live.gd")


const ENC_MARK: String = "res://assets/pk1_enc.json"
const LIVE_DIR: String = "user://pck/live/"
const LIVE_EVERY: float = 60.0
const LIVE_STALE: int = 300
const KEEP: int = 3
const REDO: int = 1

var build: String = "dev"
var page: String = PAGE
var stage: String = "idle"
var fetched: String = ""
var last_error: String = ""
var _http: HTTPRequest
var _sum: Dictionary = {}
var _marked: bool = false
var _own: String = ""
var _pruned: bool = false
var _live: Timer

func _ready() -> void :
	page = page_from(ClientConfig.resolved_update_page())
	_http = HTTPRequest.new()
	_http.use_threads = true
	_http.accept_gzip = false
	_http.timeout = 30
	_http.request_completed.connect(_done)
	add_child(_http)
	PcLive.apply(get_parent())
	_own = own_key(get_parent(), read_state(), build)


static func key_tag(key: String) -> String:
	var m: RegExMatch = RegEx.create_from_string("^(.+)-[0-9a-f]{8}$").search(key)
	return m.get_string(1) if m != null else key

static func make_key(tag: String, sha: String) -> String:
	return tag + "-" + sha.left(8)


static func own_key(parent: Node, st: Dictionary, running_build: String) -> String:
	if parent != null and parent.get("_running") is String:
		return str(parent.get("_running"))
	var boot: String = str(st.get("boot", ""))
	return boot if key_tag(boot) == running_build and (st.get("builds", {}) as Dictionary).has(boot) else ""


static func find_key(st: Dictionary, tag: String, check: Callable = Callable()) -> String:
	var builds: Dictionary = st.get("builds", {})
	var keys: Array = builds.keys()
	keys.sort_custom( func(a: Variant, b: Variant) -> bool: return int((builds[a] as Dictionary).get("at", 0)) > int((builds[b] as Dictionary).get("at", 0)) if builds[a] is Dictionary and builds[b] is Dictionary else false)
	for key: Variant in keys:
		var have: Variant = builds[key]
		if key_tag(str(key)) != tag or not (have is Dictionary) or bool((have as Dictionary).get("bad", false)):
			continue
		if not check.is_valid() or bool(check.call(str(key), have)):
			return str(key)
	return ""


static func prune_keys(st: Dictionary, keep: Array) -> Array[String]:
	var builds: Dictionary = st.get("builds", {})
	var keys: Array = builds.keys()
	keys.sort_custom( func(a: Variant, b: Variant) -> bool: return int((builds[a] as Dictionary).get("at", 0) if builds[a] is Dictionary else 0) > int((builds[b] as Dictionary).get("at", 0) if builds[b] is Dictionary else 0))
	var out: Array[String] = []
	var n: int = 0
	for key: Variant in keys:
		n += 1
		if str(key) in keep or n <= KEEP:
			continue
		out.append(str(key))
	return out



static func redo_key(st: Dictionary, sum: Dictionary) -> String:
	var builds: Dictionary = st.get("builds", {})
	var tag: String = str(sum.get("tag", ""))
	var sha: String = str(sum.get("sha", "")).to_lower()
	if tag.is_empty() or sha.length() != 64:
		return ""
	for key: String in [make_key(tag, sha), tag]:
		var row: Variant = builds.get(key)
		if row is Dictionary and str((row as Dictionary).get("sha", "")).to_lower() == sha:
			return key
	return ""




static func redo_plan(st: Dictionary, sum: Dictionary, check: Callable = Callable()) -> String:
	var key: String = redo_key(st, sum)
	if key.is_empty():
		return "fetch"
	var row: Dictionary = (st.builds as Dictionary)[key]
	if not bool(row.get("bad", false)):
		return "fetch"
	if int(row.get("redo", 0)) >= REDO:
		return "bad"
	return "redo" if check.is_valid() and bool(check.call(key, row)) else "fetch"


static func rearm(row: Dictionary) -> void :
	row["redo"] = int(row.get("redo", 0)) + 1
	if row.has("why"):
		row["why0"] = row["why"]
		row.erase("why")
	row["bad"] = false
	row["ok"] = false
	row["tries"] = 0


static func page_from(raw: String) -> String:
	var text: String = raw.strip_edges()
	if text.is_empty():
		return ""
	if not text.ends_with("/"):
		text += "/"
	if text == PAGE:
		return text
	if not text.contains("..") and RegEx.create_from_string("^(https://[a-z0-9.-]+(:[0-9]{1,5})?|http://(127\\.0\\.0\\.1|localhost|10\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}|192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}|172\\.(1[6-9]|2[0-9]|3[0-1])\\.[0-9]{1,3}\\.[0-9]{1,3})(:[0-9]{1,5})?)/([A-Za-z0-9_-]+/)*$").search(text) != null:
		return text
	return PAGE


static func pck_name() -> String:
	return "index.e.pck" if FileAccess.file_exists(ENC_MARK) else "index.pck"

static func tag_ok(tag: String) -> bool:
	return RegEx.create_from_string("^[A-Za-z0-9._-]{1,32}$").search(tag) != null


static func parse_sum(text: String) -> Dictionary:
	var parts: PackedStringArray = text.strip_edges().split(" ", false)
	if parts.size() != 3 or not tag_ok(parts[0]) or not parts[1].is_valid_int():
		return {}
	var size: int = parts[1].to_int()
	var sha: String = parts[2].to_lower()
	if size <= 0 or size > MAX_PCK or RegEx.create_from_string("^[0-9a-f]{64}$").search(sha) == null:
		return {}
	return {"tag": parts[0], "size": size, "sha": sha}


static func prune_list(state: Dictionary, want: String, running: String) -> Array[String]:
	var out: Array[String] = []
	for tag: Variant in (state.get("builds", {}) as Dictionary):
		if str(tag) != want and str(tag) != running:
			out.append(str(tag))
	return out

static func read_state() -> Dictionary:
	var doc: Variant = null
	if FileAccess.file_exists(STATE):
		doc = SafeJson.parse(FileAccess.get_file_as_string(STATE))
	if not (doc is Dictionary) or int((doc as Dictionary).get("v", 0)) != 1 or not ((doc as Dictionary).get("builds") is Dictionary):
		return {"v": 1, "builds": {}, "want": "", "last_ok": "", "boot": ""}
	return doc

static func write_state(state: Dictionary) -> void :
	DirAccess.make_dir_recursive_absolute(DIR)
	var out: FileAccess = FileAccess.open(STATE + ".part", FileAccess.WRITE)
	if out == null:
		return
	out.store_string(JSON.stringify(state))
	out.close()
	DirAccess.rename_absolute(STATE + ".part", STATE)

static func verify(path: String, size: int, sha: String) -> bool:
	if size <= 0 or sha.length() != 64 or not FileAccess.file_exists(path):
		return false
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() != size:
		return false
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	while file.get_position() < size:
		var chunk: PackedByteArray = file.get_buffer(mini(1 << 20, size - file.get_position()))
		if chunk.is_empty():
			return false
		ctx.update(chunk)
	return ctx.finish().hex_encode() == sha


func on_state(state: String) -> void :
	if state in OK_STATES and not _marked:
		_marked = true
		mark_ok()
		_beat()
		prune()
	if state in OK_STATES:
		check()

func mark_ok() -> void :
	var st: Dictionary = read_state()
	var builds: Dictionary = st.builds
	var boot: String = _own if not _own.is_empty() else str(st.get("boot", ""))
	if key_tag(boot) == build and builds.get(boot) is Dictionary:
		(builds[boot] as Dictionary)["ok"] = true
		(builds[boot] as Dictionary)["tries"] = 0
		st["last_ok"] = boot
		write_state(st)

func check() -> void :
	if stage != "idle":
		return
	if page.is_empty() or not tag_ok(build) or build == "dev":
		finished.emit("current", "version")
		return
	stage = "version"
	if _http.request(page + "version.txt?t=%d" % Time.get_unix_time_from_system()) != OK:
		stage = "idle"
		_fail("version request", "version")


func progress() -> float:
	if stage != "pck" or _http == null or int(_sum.get("size", 0)) <= 0:
		return -1.0
	return clampf(float(_http.get_downloaded_bytes()) / float(_sum.size), 0.0, 1.0)


func target() -> String:
	return str(_sum.get("tag", _sum.get("want", "")))

func _fail(why: String, was: String) -> void :
	last_error = why
	finished.emit("error", was)

func _done(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	var ok: bool = result == HTTPRequest.RESULT_SUCCESS and code == 200
	var was: String = stage
	stage = "idle"
	if not ok:
		last_error = "%s %d/%d" % [was, result, code]
		if was == "pck":
			DirAccess.remove_absolute(_http.download_file)
			_http.body_size_limit = -1
			_http.timeout = 30
		_http.download_file = ""
		finished.emit("error", was)
		return
	match was:
		"version":
			var got: String = body.get_string_from_utf8().strip_edges()
			if not tag_ok(got):
				_fail("version text", was)
				return
			var st: Dictionary = read_state()
			if got == build:
				if str(st.get("want", "")) != got:
					st["want"] = got
					write_state(st)
				finished.emit("current", was)
				return
			if got == fetched:
				finished.emit("same", was)
				return
			var good: String = find_key(st, got, func(key: String, row: Dictionary) -> bool:
				return verify(DIR + key + ".pck", int(row.get("size", 0)), str(row.get("sha", ""))))
			if not good.is_empty():
				st["want"] = good
				write_state(st)
				_ready_tag(got)
				return
			stage = "sum"
			_sum = {"want": got}
			if _http.request(page + pck_name() + ".sha256?t=%d" % Time.get_unix_time_from_system()) != OK:
				stage = "idle"
				_fail("sum request", "sum")
		"sum":
			var sum: Dictionary = parse_sum(body.get_string_from_utf8())
			if sum.is_empty() or str(sum.tag) != str(_sum.get("want", "")):
				_fail("sum", was)
				return
			_sum = sum
			var st: Dictionary = read_state()
			var plan: String = redo_plan(st, sum, func(key: String, row: Dictionary) -> bool:
				return verify(DIR + key + ".pck", int(row.get("size", 0)), str(row.get("sha", ""))))
			if plan == "bad":
				finished.emit("bad", was)
				return
			if plan == "redo":
				var again: String = redo_key(st, sum)
				rearm((st.builds as Dictionary)[again])
				st["want"] = again
				if not (st.builds as Dictionary).has(str(st.get("last_ok", ""))):
					st["last_ok"] = ""
				write_state(st)
				_ready_tag(str(sum.tag))
				return
			DirAccess.make_dir_recursive_absolute(DIR)
			_http.download_file = DIR + make_key(str(sum.tag), str(sum.sha)) + ".%d.part" % OS.get_process_id()
			_http.body_size_limit = int(sum.size) + 1
			_http.timeout = 900
			stage = "pck"
			if _http.request(page + pck_name() + "?v=" + str(sum.tag).uri_encode()) != OK:
				stage = "idle"
				_http.download_file = ""
				_http.body_size_limit = -1
				_http.timeout = 30
				_fail("pck request", "pck")
		"pck":
			var part: String = _http.download_file
			_http.download_file = ""
			_http.body_size_limit = -1
			_http.timeout = 30
			var tag: String = str(_sum.tag)
			if not verify(part, int(_sum.size), str(_sum.sha)):
				DirAccess.remove_absolute(part)
				_fail("verify", was)
				return
			var key: String = make_key(tag, str(_sum.sha))
			var dest: String = DIR + key + ".pck"
			if verify(dest, int(_sum.size), str(_sum.sha)):
				DirAccess.remove_absolute(part)
			else:
				DirAccess.remove_absolute(dest)
				if DirAccess.rename_absolute(part, dest) != OK:
					DirAccess.remove_absolute(part)
					_fail("rename", was)
					return
			var st: Dictionary = read_state()
			var row: Variant = (st.builds as Dictionary).get(key)
			if row is Dictionary and str((row as Dictionary).get("sha", "")) == str(_sum.sha):
				if bool((row as Dictionary).get("bad", false)):
					rearm(row)
				(row as Dictionary)["bad"] = false
				(row as Dictionary)["tries"] = 0
				(row as Dictionary)["at"] = int(Time.get_unix_time_from_system())
			else:
				(st.builds as Dictionary)[key] = {"size": int(_sum.size), "sha": str(_sum.sha), "ok": false, "bad": false, "tries": 0, 
					"tag": tag, "at": int(Time.get_unix_time_from_system())}
			st["want"] = key
			if not (st.builds as Dictionary).has(str(st.get("last_ok", ""))):
				st["last_ok"] = ""
			write_state(st)
			_ready_tag(tag)


func prune() -> void :
	if _pruned:
		return
	_pruned = true
	var st: Dictionary = read_state()
	var builds: Dictionary = st.builds
	var keep: Array = [str(st.get("want", "")), str(st.get("last_ok", "")), str(st.get("boot", "")), _own]
	for key: Variant in builds:
		if key_tag(str(key)) == build:
			keep.append(str(key))
	keep.append_array(live_keys())
	var gone: Array[String] = prune_keys(st, keep)
	for old: String in gone:
		builds.erase(old)
		DirAccess.remove_absolute(DIR + old + ".pck")
	if not gone.is_empty():
		write_state(st)
	var now: int = int(Time.get_unix_time_from_system())
	for name: String in DirAccess.get_files_at(DIR):
		var path: String = DIR + name
		var orphan: bool = name.ends_with(".pck") and not builds.has(name.get_basename()) and not name.get_basename() in keep
		if (orphan or name.ends_with(".part")) and now - FileAccess.get_modified_time(path) > 3600:
			DirAccess.remove_absolute(path)


static func live_keys() -> Array:
	var out: Array = []
	var now: int = int(Time.get_unix_time_from_system())
	for name: String in DirAccess.get_files_at(LIVE_DIR):
		var path: String = LIVE_DIR + name
		if now - FileAccess.get_modified_time(path) > LIVE_STALE:
			DirAccess.remove_absolute(path)
			continue
		var text: String = FileAccess.get_file_as_string(path).strip_edges()
		if not text.is_empty():
			out.append(text)
	return out

func _beat() -> void :
	if _live == null:
		_live = Timer.new()
		_live.wait_time = LIVE_EVERY
		_live.timeout.connect(_beat)
		add_child(_live)
		_live.start()
	DirAccess.make_dir_recursive_absolute(LIVE_DIR)
	var out: FileAccess = FileAccess.open(LIVE_DIR + "%d.txt" % OS.get_process_id(), FileAccess.WRITE)
	if out != null:
		out.store_string(_own if not _own.is_empty() else "-")
		out.close()

func _exit_tree() -> void :
	if _live != null:
		DirAccess.remove_absolute(LIVE_DIR + "%d.txt" % OS.get_process_id())

func _ready_tag(tag: String) -> void :
	fetched = tag
	ready_tag.emit(tag)
