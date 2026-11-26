extends Control







const DIR: String = "user://pck/"
const STATE: String = "user://pck/state.json"
const EMBED: String = "res://assets/apk_build.txt"
const MAIN: String = "res://main.tscn"
const TRIES: int = 2

func _ready() -> void :
	var bg: ColorRect = ColorRect.new()
	bg.color = Color.BLACK
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	_boot.call_deferred()

func _boot() -> void :
	var embedded: String = embedded_tag()
	var state: Dictionary = read_state()
	var used: String = ""
	for tag: String in order(state, embedded):
		var build: Dictionary = state.builds[tag]
		if not bool(build.get("ok", false)):
			build["tries"] = int(build.get("tries", 0)) + 1
		state["boot"] = tag
		write_state(state)
		var path: String = DIR + tag + ".pck"
		if not verify(path, int(build.get("size", 0)), str(build.get("sha", ""))):
			build["bad"] = true
			build["why"] = "verify"
			DirAccess.remove_absolute(path)
			write_state(state)
			continue
		if not ProjectSettings.load_resource_pack(path, true):
			build["bad"] = true
			build["why"] = "load"
			write_state(state)
			continue
		used = tag
		break
	if used.is_empty():
		state["boot"] = embedded
		write_state(state)
	print("mh1 boot: ", used if not used.is_empty() else embedded + " (APK)")
	get_tree().change_scene_to_file(MAIN)

static func embedded_tag() -> String:
	if not FileAccess.file_exists(EMBED):
		return "dev"
	var text: String = FileAccess.get_file_as_string(EMBED).strip_edges()
	return text if tag_ok(text) else "dev"

static func tag_ok(tag: String) -> bool:
	return RegEx.create_from_string("^[A-Za-z0-9._-]{1,32}$").search(tag) != null



static func order(state: Dictionary, embedded: String) -> Array[String]:
	var out: Array[String] = []
	var builds: Dictionary = state.get("builds", {})
	if str(state.get("want", "")) == embedded:
		return out
	for key: String in ["want", "last_ok"]:
		var tag: String = str(state.get(key, ""))
		if tag.is_empty() or tag == embedded or not tag_ok(tag) or tag in out or not (builds.get(tag) is Dictionary):
			continue
		var build: Dictionary = builds[tag]
		if bool(build.get("bad", false)):
			continue
		if not bool(build.get("ok", false)) and int(build.get("tries", 0)) >= TRIES:
			build["bad"] = true
			build["why"] = "tries"
			continue
		out.append(tag)
	return out

static func read_state() -> Dictionary:
	var doc: Variant = null
	if FileAccess.file_exists(STATE):
		doc = JSON.parse_string(FileAccess.get_file_as_string(STATE))
	return clean_state(doc)


static func clean_state(doc: Variant) -> Dictionary:
	if not (doc is Dictionary) or int((doc as Dictionary).get("v", 0)) != 1 or not ((doc as Dictionary).get("builds") is Dictionary):
		return {"v": 1, "builds": {}, "want": "", "last_ok": "", "boot": ""}
	var state: Dictionary = doc
	for key: String in ["want", "last_ok", "boot"]:
		state[key] = str(state.get(key, ""))
	return state

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
	return ctx.finish().hex_encode() == sha.to_lower()
