extends Node




signal map_ready(map_id: int, ok: bool)
signal map_progress(map_id: int, fraction: float)
signal art_ready(external: String)
signal picture_ready(path: String)

const SafeJson = preload("res://net/safe_json.gd")
const ClientConfig = preload("res://client_config.gd")
const PARALLEL: int = 6



const PARALLEL_WEB: int = 18
const HTTP_TIMEOUT_WEB: float = 60.0
const AppSession = preload("res://net/app_session.gd")





const RETRY_WAIT: Array[float] = [1.0, 2.0, 4.0, 8.0]
const RETRY_KEEP: float = 15.0
var retries: int = 0

var startup: Dictionary = {}
var base: String = ""





const PACK_VER: String = "res://assets/pack_ver.json"
var vbase: String = ""
var vmap: Dictionary = {}
var _vplain: Dictionary = {}
var _vseen: Dictionary = {}
var _vprobe: Dictionary = {}
var local: bool = false
var state: String = "none"
var index: Dictionary = {}
var _maps: Dictionary = {}
var _waiting_index: Array[int] = []
var _art: Dictionary = {}
var _art_loading: Dictionary = {}
var _components: Dictionary = {}
var _component_waiters: Dictionary = {}
var _queue: Array = []
var _slow: Array = []
var fx: Dictionary = {}
var _known_skills: Dictionary = {}
var _effects: Dictionary = {}
var _effect_loading: Dictionary = {}
var _idle: Array[HTTPRequest] = []
var _pool: Array[HTTPRequest] = []
var _bg_on: bool = false
var _bg_gate: Dictionary = {}
var cut_stats: Dictionary = {"stale": 0, "skip": 0}
var bg_stats: Dictionary = {"hold": 0, "cut": 0}
const BG_SIDE: int = 3
const BG_GATE_MS: int = 15000
const STALL_MS: int = 30000
const STALL_GAP_MS: int = 3000
var net_stats: Dictionary = {"to": 0, "stall": 0}
var _stall_ms: int = STALL_MS
var _stall_last: int = 0
var _stall_timer: Timer
var hud: Dictionary = {}
var _icons: Dictionary = {}
var lobby: Dictionary = {}
var _pictures: Dictionary = {}
var garage: Dictionary = {}
var _garage_asked: bool = false
var bag: Dictionary = {}
var _bag_asked: bool = false
var bagx: Dictionary = {}
var _bagx_asked: bool = false
var helper: Dictionary = {}
var _helper_asked: bool = false
var crystal: Dictionary = {}
var _crystal_asked: bool = false
var crystalx: Dictionary = {}
var _crystalx_asked: bool = false
var rank: Dictionary = {}
var _rank_asked: bool = false
var board: Dictionary = {}
var _board_asked: bool = false
var quest: Dictionary = {}
var _quest_asked: bool = false
var mapart: Dictionary = {}
var _mapart_asked: bool = false
var questx: Dictionary = {}
var _questx_asked: bool = false
var events: Dictionary = {}
var _events_asked: bool = false
var eventsx: Dictionary = {}
var _eventsx_asked: bool = false
var garagex: Dictionary = {}
var _garagex_asked: bool = false
var fair: Dictionary = {}
var _fair_asked: bool = false
var gda_loading: Dictionary = {}

var _gda_loading_asked: bool = false
var gda_pveload: Dictionary = {}

var _gda_pveload_asked: bool = false
var gda_hall: Dictionary = {}

var _gda_hall_at: int = -1
var tips: Dictionary = {}
var _tips_asked: bool = false
var ainpc: Dictionary = {}
var _ainpc_asked: bool = false
var ainpc_settled: bool = false
var _fallback_asked: bool = false
static var _cjk_fonts: Array = []
var sounds: Dictionary = {}
var _sounds: Dictionary = {}
var _sound_done: Dictionary = {}
var _sound_slow: Dictionary = {}








const FRESH_MAX: int = 4096
var decode_budget_ms: float = 3.0


var load_budget_ms: float = 16.0
var decode_gate: Object = null
var decode_stats: Dictionary = {"now": 0, "late": 0, "steps": 0, "frames": 0, "peak": 0, "max_us": 0}
var _dq: Array = []
var _dq_slow: Array = []
var _fresh: Array = []









const IOS_CAP_MAP: int = 2000000
const IOS_CAP_FX: int = 600000
const IOS_DROP: Array = ["l/island/", "l/hall/"]
var ios_shrink: bool = OS.has_feature("web_ios") or OS.has_feature("ios")
var shrink_stats: Dictionary = {"n": 0, "px_before": 0, "px_after": 0}


func shrink_cap(path: String) -> int:
	if not ios_shrink:
		return 0
	if path.begins_with("m/"):
		return IOS_CAP_MAP
	if path.begins_with("e/"):
		return IOS_CAP_FX
	return 0



func ios_drop_lobby(prefixes: Array = IOS_DROP) -> int:
	if not ios_shrink:
		return 0
	var gone: int = 0
	for path: String in _pictures.keys():
		if _pictures[path] == null:
			continue
		for prefix: String in prefixes:
			if path.begins_with(prefix):
				_pictures.erase(path)
				gone += 1
				break
	if gone > 0:
		_fresh.clear()
	return gone






const IOS_FX_BUDGET: int = 12000000
const IOS_FX_HOT_MS: int = 3000
var _fx_used: Dictionary = {}
var _fx_px: Dictionary = {}
var _fx_total: int = 0
var trim_stats: Dictionary = {"fx": 0, "maps": 0}

func _forget_fx(key: String) -> void :
	if not ios_shrink:
		_gone(_effects.get(key))
	_fx_total -= int(_fx_px.get(key, 0))
	_fx_px.erase(key)
	_fx_used.erase(key)
	_fx_seq.erase(key)
	_effects.erase(key)


func ios_fit_fx(budget: int = IOS_FX_BUDGET) -> int:
	if not ios_shrink or _fx_total <= budget:
		return 0
	var now: int = Time.get_ticks_msec()
	var keys: Array = _fx_px.keys()
	keys.sort_custom( func(a: String, b: String) -> bool: return int(_fx_used.get(a, 0)) < int(_fx_used.get(b, 0)))
	var gone: int = 0
	for key: String in keys:
		if _fx_total <= budget or now - int(_fx_used.get(key, 0)) < IOS_FX_HOT_MS:
			break
		_forget_fx(key)
		gone += 1
	trim_stats.fx += gone
	return gone



func ios_trim_battle(map_id: int, jobs: Array) -> Array:
	if not ios_shrink:
		return [0, 0]
	var want: Dictionary = {}
	for job: Array in jobs:
		if str(job[0]) == "e":
			want[str(job[1])] = true
	var now: int = Time.get_ticks_msec()
	var fx_gone: int = 0
	for key: String in _fx_px.keys():
		if not want.has(key) and now - int(_fx_used.get(key, 0)) >= IOS_FX_HOT_MS:
			_forget_fx(key)
			fx_gone += 1
	var maps_gone: int = 0
	for id: int in _maps.keys():
		if id != map_id and str(_maps[id].status) != "loading":
			_maps.erase(id)
			maps_gone += 1
	trim_stats.fx += fx_gone
	trim_stats.maps += maps_gone
	return [fx_gone, maps_gone]






const PC_FX_BUDGET: int = 96000000
const PC_MAP_BUDGET: int = 24000000
var _trim_no: int = 0
var _fx_seq: Dictionary = {}
var leak_stats: Dictionary = {"trims": 0, "fx": 0, "maps": 0, "fx_px": 0, "map_px": 0}

func pc_trim_battle(map_id: int, jobs: Array) -> Array:
	if ios_shrink:
		return [0, 0]
	_trim_no += 1
	var want: Dictionary = {}
	for job: Array in jobs:
		if str(job[0]) == "e":
			want[str(job[1])] = true
			_fx_seq[str(job[1])] = _trim_no
	var fx_gone: int = 0
	if _fx_total > PC_FX_BUDGET:
		var keys: Array = _fx_px.keys().filter( func(k: String) -> bool: return not want.has(k))
		keys.sort_custom( func(a: String, b: String) -> bool: return int(_fx_seq.get(a, 0)) < int(_fx_seq.get(b, 0)))
		for key: String in keys:
			if _fx_total <= PC_FX_BUDGET:
				break
			_forget_fx(key)
			fx_gone += 1
	var map_px: int = 0
	for id: int in _maps:
		map_px += _map_px(id)
	var maps_gone: int = 0
	if map_px > PC_MAP_BUDGET:
		for id: int in _maps.keys():
			if id != map_id and str(_maps[id].get("status", "")) != "loading":
				map_px -= _map_px(id)
				_maps.erase(id)
				maps_gone += 1
	leak_stats.trims += 1
	leak_stats.fx += fx_gone
	leak_stats.maps += maps_gone
	leak_stats.fx_px = _fx_total
	leak_stats.map_px = map_px
	return [fx_gone, maps_gone]

func _map_px(id: int) -> int:
	var px: int = 0
	var seen: Dictionary = {}
	for texture: Variant in (_maps[id] as Dictionary).get("textures", {}).values():
		if texture is Texture2D and not seen.has(texture):
			seen[texture] = true
			px += int(texture.get_width()) * int(texture.get_height())
	return px

func _budgeted() -> bool:
	return _spread() and bool(decode_gate.call("decode_budgeted"))


func _spread() -> bool:
	return is_instance_valid(decode_gate) and is_inside_tree()

func _later(bytes: PackedByteArray, done: Callable, slow: bool, tag: String, cap: int = 0) -> void :
	(_dq_slow if slow else _dq).append([bytes, done, tag, cap])
	decode_stats.late += 1
	decode_stats.peak = maxi(int(decode_stats.peak), _dq.size() + _dq_slow.size())
	set_process(true)

func _upload(decoded: Image, cap: int = 0) -> ImageTexture:
	var full: Vector2i = decoded.get_size()
	if cap > 0 and full.x * full.y > cap:
		var k: float = sqrt(float(cap) / float(full.x * full.y))
		decoded.resize(maxi(1, floori(full.x * k)), maxi(1, floori(full.y * k)), Image.INTERPOLATE_BILINEAR)
		shrink_stats.n += 1
		shrink_stats.px_before += full.x * full.y
		shrink_stats.px_after += decoded.get_width() * decoded.get_height()
	var texture: ImageTexture = ImageTexture.create_from_image(decoded)
	if decoded.get_size() != full:
		texture.set_size_override(full)
	if is_instance_valid(decode_gate) and bool(decode_gate.call("touch_wanted")):
		if _fresh.size() >= FRESH_MAX:
			_fresh.pop_front()
		_fresh.append(texture)
	return texture

func _process(_delta: float) -> void :
	if _dq.is_empty() and _dq_slow.is_empty():
		set_process(false)
		return
	var limit: int = int((decode_budget_ms if _budgeted() else load_budget_ms) * 1000.0)
	var t0: int = Time.get_ticks_usec()
	var steps: int = 0
	while not (_dq.is_empty() and _dq_slow.is_empty()):
		if steps > 0 and limit >= 0 and Time.get_ticks_usec() - t0 >= limit:
			break
		steps += 1
		var q: Array = _dq if not _dq.is_empty() else _dq_slow
		var job: Array = q[0]
		var done: Callable = job[1]
		var s0: int = Time.get_ticks_usec()
		if job[0] is PackedByteArray:
			var bytes: PackedByteArray = job[0]
			var decoded: Image = Image.new()
			if bytes.is_empty() or decoded.load_webp_from_buffer(bytes) != OK:
				q.pop_front()
				if not bytes.is_empty():
					_relieve()
				done.call(null)
			else:
				job[0] = decoded
		else:
			q.pop_front()
			done.call(_upload(job[0], int(job[3]) if job.size() > 3 else 0))
		decode_stats.max_us = maxi(int(decode_stats.max_us), Time.get_ticks_usec() - s0)
	decode_stats.steps += steps
	decode_stats.frames += 1


func _hurry_decode(tag: String) -> void :
	if tag.is_empty() or _dq_slow.is_empty():
		return
	var keep: Array = []
	for job: Array in _dq_slow:
		if str(job[2]) == tag:
			_dq.append(job)
		else:
			keep.append(job)
	_dq_slow = keep












const PC_FX_SPARE: int = 64000000
const PC_ART_BUDGET: int = 16000000
const PC_UI_BUDGET: int = 40000000
const PC_HOT_MS: int = 20000
const PC_FIT_EVERY_MS: int = 1000
const PC_UI_DIRS: Array = ["l/tb/", "l/t/", "l/it/", "l/or/"]
var _pc_want: Dictionary = {}
var _pc_want_art: Dictionary = {}
var _pc_battle: bool = false
var _pc_fit_at: int = -1000000
var _art_used: Dictionary = {}
var _pic_used: Dictionary = {}
var _gone_tex: Dictionary = {}
var leak2_stats: Dictionary = {"fits": 0, "fx": 0, "art": 0, "comp": 0, "ui": 0, "maps": 0, "fresh": 0, "spare_px": 0, "comp_px": 0, "ui_px": 0}


func pc_want(jobs: Array, battle: bool) -> void :
	if ios_shrink:
		return
	_pc_want.clear()
	_pc_want_art.clear()
	for job: Variant in jobs:
		if job is Array and (job as Array).size() > 1:
			match str(job[0]):
				"e":
					_pc_want[str(job[1])] = true
				"a":
					_pc_want_art[str(job[1])] = true
	_pc_battle = battle
	pc_fit(true)



func pc_leave_battle() -> bool:
	if ios_shrink or not _pc_battle:
		return false
	_pc_battle = false
	_pc_want.clear()
	_pc_want_art.clear()
	if is_inside_tree():
		get_tree().create_timer(PC_HOT_MS / 1000.0 + 0.5).timeout.connect( func() -> void :
			if not _pc_battle:
				pc_fit(true))
	return true


func pc_fit(force: bool = false) -> void :
	if ios_shrink:
		return
	var now: int = Time.get_ticks_msec()
	if not force and now - _pc_fit_at < PC_FIT_EVERY_MS:
		return
	_pc_fit_at = now
	leak2_stats.fits += 1
	var spare: int = _fx_total
	for key: Variant in _pc_want:
		spare -= int(_fx_px.get(key, 0))
	if spare > PC_FX_SPARE:
		var keys: Array = _fx_px.keys().filter( func(k: Variant) -> bool: return not _pc_want.has(k) and now - int(_fx_used.get(k, 0)) >= PC_HOT_MS)
		keys.sort_custom( func(a: Variant, b: Variant) -> bool: return int(_fx_used.get(a, 0)) < int(_fx_used.get(b, 0)))
		for key: String in keys:
			if spare <= PC_FX_SPARE:
				break
			spare -= int(_fx_px.get(key, 0))
			_forget_fx(key)
			leak2_stats.fx += 1
	leak2_stats.spare_px = spare
	if force:
		_fit_art(now)
		_fit_ui(now)
	_unfresh()


func pc_trim_maps(keep: int) -> int:
	if ios_shrink:
		return 0
	var px: int = 0
	for id: int in _maps:
		px += _map_px(id)
	if px <= PC_MAP_BUDGET:
		return 0
	var gone: int = 0
	for id: int in _maps.keys():
		if id != keep and str(_maps[id].get("status", "")) != "loading":
			if not _fresh.is_empty():
				for texture: Variant in (_maps[id] as Dictionary).get("textures", {}).values():
					if texture is Texture2D:
						_gone_tex[texture] = true
			_maps.erase(id)
			gone += 1
	leak2_stats.maps += gone
	_unfresh()
	return gone


func mem_groups() -> String:
	var maps: int = 0
	for id: int in _maps:
		maps += _map_px(id)
	var comp: int = 0
	for cid: Variant in _components:
		comp += _sheet_px(_components[cid])
	var ui: int = 0
	for group: Dictionary in [_pictures, _icons, _hc_sheets]:
		for texture: Variant in group.values():
			if texture is Texture2D:
				ui += int(texture.get_width()) * int(texture.get_height())
	return "%d/%d/%d/%d" % [_fx_total >> 18, maps >> 18, comp >> 18, ui >> 18]

func _sheet_px(value: Variant) -> int:
	var px: int = 0
	if value is Dictionary and (value as Dictionary).get("pages") is Array:
		for page: Variant in value.pages:
			if page is Texture2D:
				px += int(page.get_width()) * int(page.get_height())
	return px

func _art_cids(external: String) -> Array:
	var out: Array = []
	var parts: Variant = (index.get("externals", {}) as Dictionary).get(external, {})
	if parts is Dictionary:
		for cid: Variant in (parts as Dictionary).values():
			out.append(int(cid))
	return out

func _fit_art(now: int) -> void :
	var px: int = 0
	for cid: Variant in _components:
		px += _sheet_px(_components[cid])
	leak2_stats.comp_px = px
	if px <= PC_ART_BUDGET:
		return
	var refs: Dictionary = {}
	var keep: Dictionary = {}
	var old: Array = []
	for external: Variant in _art:
		if not _art[external] is Dictionary or (_art[external] as Dictionary).is_empty():
			continue
		var hot: bool = _pc_want_art.has(external) or now - int(_art_used.get(external, 0)) < PC_HOT_MS
		for cid: int in _art_cids(str(external)):
			refs[cid] = int(refs.get(cid, 0)) + 1
			if hot:
				keep[cid] = true
		if not hot:
			old.append(external)
	for external: Variant in _art_loading:
		for cid: int in _art_cids(str(external)):
			keep[cid] = true
	old.sort_custom( func(a: Variant, b: Variant) -> bool: return int(_art_used.get(a, 0)) < int(_art_used.get(b, 0)))
	for external: Variant in old:
		if px <= PC_ART_BUDGET:
			break
		_art.erase(external)
		_art_used.erase(external)
		leak2_stats.art += 1
		for cid: int in _art_cids(str(external)):
			refs[cid] = int(refs.get(cid, 0)) - 1
			if int(refs[cid]) <= 0 and not keep.has(cid) and _components.get(cid) is Dictionary:
				px -= _sheet_px(_components[cid])
				_gone(_components[cid])
				_components.erase(cid)
				leak2_stats.comp += 1
	leak2_stats.comp_px = px

func _ui_dir(path: String) -> bool:
	for prefix: String in PC_UI_DIRS:
		if path.begins_with(prefix):
			return true
	return false

func _fit_ui(now: int) -> void :
	var px: int = 0
	var old: Array = []
	for path: Variant in _pictures:
		var texture: Variant = _pictures[path]
		if not texture is Texture2D or not _ui_dir(str(path)):
			continue
		var n: int = int(texture.get_width()) * int(texture.get_height())
		px += n
		if now - int(_pic_used.get(path, 0)) >= PC_HOT_MS:
			old.append([int(_pic_used.get(path, 0)), path, n])
	leak2_stats.ui_px = px
	if px <= PC_UI_BUDGET:
		return
	old.sort_custom( func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]))
	for row: Array in old:
		if px <= PC_UI_BUDGET:
			break
		if not _fresh.is_empty():
			_gone_tex[_pictures[row[1]]] = true
		_pictures.erase(row[1])
		_pic_used.erase(row[1])
		px -= int(row[2])
		leak2_stats.ui += 1
	leak2_stats.ui_px = px

func _gone(value: Variant) -> void :
	if _fresh.is_empty() or not value is Dictionary:
		return
	for page: Variant in (value as Dictionary).get("pages", []):
		if page is Texture2D:
			_gone_tex[page] = true

func _unfresh() -> void :
	if not _gone_tex.is_empty() and not _fresh.is_empty():
		var n: int = _fresh.size()
		_fresh = _fresh.filter( func(texture: Variant) -> bool: return not _gone_tex.has(texture))
		leak2_stats.fresh += n - _fresh.size()
	_gone_tex.clear()


func fresh_textures(n: int) -> Array:
	var out: Array = _fresh.slice(0, n)
	_fresh = _fresh.slice(n)
	return out


func drop_fresh() -> void :
	_fresh.clear()

func _init() -> void :
	attach_cjk_font()

func configure(root: String = "") -> void :
	if root.is_empty():
		root = str(JavaScriptBridge.eval("(window.__bbAssetRoot || new URL('a/', document.baseURI).href)", true)) if OS.has_feature("web") else OS.get_environment("BB_ASSET_DIR")
		if root.is_empty() and not OS.has_feature("web"):
			root = ClientConfig.resolved_asset_root()
	if root.is_empty() or root == "null":
		return
	base = root if root.ends_with("/") else root + "/"
	local = not base.begins_with("http")
	_load_pack_ver()
	_load_veil()
	_load_veil_ext()
	_k3_setup()
	_bg_on = OS.has_feature("web")
	var native_app: bool = OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("pc_app") or ( not OS.has_feature("web") and not OS.has_feature("editor"))
	_avc_on = native_app and not local and not vbase.is_empty()
	if _avc_on:
		_avc_open()
	if not local and _idle.is_empty():
		for i in range(PARALLEL_WEB if OS.has_feature("web") else PARALLEL):
			var http: HTTPRequest = HTTPRequest.new()


			http.timeout = 0.0

			http.accept_gzip = not OS.has_feature("web")


			http.download_chunk_size = 1 << 20
			http.request_completed.connect(_completed.bind(http))
			add_child(http)
			_idle.append(http)
			_pool.append(http)
	if not local and _stall_timer == null:
		_stall_ms = int(HTTP_TIMEOUT_WEB * 1000.0) if OS.has_feature("web") else STALL_MS
		_stall_timer = Timer.new()
		_stall_timer.wait_time = 1.0
		_stall_timer.autostart = true
		_stall_timer.timeout.connect(_stall_tick)
		add_child(_stall_timer)
	_dl_setup()
	state = "loading"
	_fetch("i/index.json", false, func(value: Variant) -> void :
		hud = value if value is Dictionary and value.get("skills") is Dictionary else {}
		_settle("hud", "i/index.json"), false, false, false, "", false, true)
	_fetch("l/index.json", false, func(value: Variant) -> void :
		lobby = value if value is Dictionary and value.get("halls") is Dictionary else {}
		startup["lobby"] = true
		picture_ready.emit("l/index.json"), false, false, false, "", false, true)
	_fetch("s/index.json", false, func(value: Variant) -> void :
		sounds = value if value is Dictionary and value.get("b") is Dictionary else {}
		_settle("sounds", "s/index.json"), false, false, false, "", false, true)
	_fetch("index.json", false, func(value: Variant) -> void :
		index = value if value is Dictionary and value.get("maps") is Dictionary and value.get("externals") is Dictionary else {}
		state = "ready" if not index.is_empty() else "failed"
		if state == "ready" and index.maps.has("40002"):
			for gb_map: String in ["40101", "40102", "40103"]:
				if not index.maps.has(gb_map):
					index.maps[gb_map] = index.maps["40002"]
		if state == "ready" and not str(index.get("fx", "")).is_empty():
			_fetch(str(index.fx), false, func(table: Variant) -> void :
				fx = table if table is Dictionary and table.get("exhibits") is Dictionary else {}
				_known_skills.clear()
				_settle("fx", str(index.fx)), false, false, false, "", false, true)
		else:
			startup["fx"] = true
		_settle("index", "index.json")
		var waiting: Array[int] = _waiting_index.duplicate()
		_waiting_index.clear()
		for id: int in waiting:
			_start_map(id))

func wants_map(id: int) -> bool:
	return state == "loading" or (state == "ready" and index.maps.has(str(id)))


func map_report(id: int) -> String:
	var entry: Dictionary = _maps.get(id, {})
	return "goi=%s w=%s idx=%s st=%s why=%s doc=%s %d/%d loc=%s avc=%s" % [state, wants_map(id), index.get("maps", {}).has(str(id)), 
		str(entry.get("status", "none")), str(entry.get("why", "-")), not (entry.get("doc", {}) as Dictionary).is_empty(), 
		int(entry.get("done", 0)), int(entry.get("total", 0)), local, _avc_on]

func map_status(id: int) -> String:
	return str(_maps.get(id, {}).get("status", "none"))

func map_doc(id: int) -> Dictionary:
	return _maps.get(id, {}).get("doc", {})

func map_textures(id: int) -> Dictionary:
	return _maps.get(id, {}).get("textures", {})

func map_fraction(id: int) -> float:
	var entry: Dictionary = _maps.get(id, {})
	return float(entry.get("done", 0)) / maxf(1.0, float(entry.get("total", 1)))

func request_map(id: int) -> void :
	_map_last = id
	if _maps.has(id):
		var entry: Dictionary = _maps[id]
		if entry.status == "failed" and state == "ready":


			entry.status = "loading"
			entry.total = 1
			entry.done = 0
			entry.erase("failed")
			_start_map(id)
			return
		if entry.status != "loading":
			if entry.status == "ready":
				refill_map(id)
			map_ready.emit.call_deferred(id, entry.status == "ready")
		return
	_maps[id] = {"status": "loading", "doc": {}, "textures": {}, "total": 1, "done": 0}
	if state == "loading":
		_waiting_index.append(id)
	else:
		_start_map(id)




func _start_map(id: int) -> void :
	if state != "ready" or not index.maps.has(str(id)):
		_map_failed(id, "goi %s idx %s" % [state, index.get("maps", {}).has(str(id))])
		return
	var folder: String = str(index.maps[str(id)])
	_fetch(folder + "/map.json", false, func(doc: Variant) -> void :
		var entry: Dictionary = _maps[id]
		if entry.status != "loading":
			return
		if not doc is Dictionary or not doc.get("visual") is Dictionary or not doc.get("header") is Dictionary:
			_map_failed(id, "map.json %s" % type_string(typeof(doc)))
			return
		entry.doc = doc
		var names: Array = doc.visual.get("images", {}).keys().filter(_drawn_image)
		entry.total = names.size() + 1
		entry.done = 1
		_map_step(id)
		for name: String in names:
			_fetch_drawn(id, entry, name), false, false, false, "", false, true)

func _fetch_drawn(id: int, entry: Dictionary, name: String) -> void :
	var file: String = str(index.maps[str(id)]) + "/" + str(entry.doc.visual.images[name].file)
	var background: bool = name == "background"
	var bad0: int = int(heal_stats.bad)
	if background:
		entry.bg_fly = true
		_bg_hold(file)
	_fetch(file, true, func(texture: Variant) -> void :
		if background:
			entry.erase("bg_fly")
			_bg_gate.erase(file)
		if not _map_size_ok(entry, name, texture):
			texture = null
		if texture != null:
			entry.textures[name] = texture
			entry.get("failed", {}).erase(name)
			if background:
				entry.erase("bg_why")
		else:
			if background:
				entry.bg_why = "giải mã" if int(heal_stats.bad) != bad0 else "tải"
			if background and entry.status == "loading" and int(heal_stats.bad) != bad0 and _bg_retry(id, entry):
				return
			entry.get_or_add("failed", {})[name] = true
			if background and not entry.textures.has(name):
				entry.textures[name] = _placeholder(entry.doc)
		if entry.status != "loading":
			return
		entry.done += 1
		_map_step(id), false, false, false, "", background, background)



func refill_map(id: int) -> int:
	var entry: Dictionary = _maps.get(id, {})
	entry.erase("heals")
	entry.erase("heal_at")
	if entry.get("status", "") != "ready" or entry.get("failed", {}).is_empty() or not index.get("maps", {}).has(str(id)):
		return 0
	var images: Dictionary = entry.doc.visual.get("images", {})
	var names: Array = entry.failed.keys().filter( func(name: String) -> bool: return images.has(name))
	var asked: Dictionary = entry.get_or_add("asked", {})
	for name: String in names:
		entry.failed.erase(name)
		if _drawn_image(name):
			asked[name] = true
			_fetch_drawn(id, entry, name)
		else:
			asked.erase(name)
			want_map_image(id, name)
	return names.size()



func force_map(id: int) -> bool:
	var entry: Dictionary = _maps.get(id, {})
	if entry.get("status", "") == "ready":
		return true
	if entry.get("status", "") != "loading" or entry.get("doc", {}).is_empty():
		return false
	_ready_map(id)
	return true



static func _placeholder(doc: Dictionary) -> Texture2D:
	var header: Dictionary = doc.get("header", {})
	var wanted: Variant = doc.get("visual", {}).get("images", {}).get("background", {}).get("size", [])
	var w: int = int(wanted[0]) if wanted is Array and wanted.size() >= 2 else int(header.get("mapWidth", 0))
	var h: int = int(wanted[1]) if wanted is Array and wanted.size() >= 2 else int(header.get("mapHeight", 0))
	var image: Image = Image.create_empty(2, 2, false, Image.FORMAT_RGB8)
	image.fill(PLACEHOLDER_COLOR)
	var texture: ImageTexture = ImageTexture.create_from_image(image)
	texture.set_size_override(Vector2i(maxi(64, w), maxi(64, h)))
	texture.set_meta("placeholder", true)
	return texture

const PLACEHOLDER_COLOR: Color = Color("2c3530")





const BG_LOAD_RETRY: Array = [1.0, 2.0, 4.0]
const HEAL_WAIT: Array = [2.0, 4.0, 8.0, 15.0, 30.0, 60.0]
const HEAL_MAX: int = 10
var heal_stats: Dictionary = {"bad": 0, "retry": 0, "heal": 0, "healed": 0, "relieve": 0, "avc_bad": 0, "avc_short": 0}
var _map_last: int = 0

func _bg_retry(id: int, entry: Dictionary) -> bool:
	var tries: int = int(entry.get("bg_tries", 0))
	if tries >= BG_LOAD_RETRY.size() or not is_inside_tree():
		return false
	entry.bg_tries = tries + 1
	entry.bg_fly = true
	heal_stats.retry += 1
	get_tree().create_timer(float(BG_LOAD_RETRY[tries])).timeout.connect( func() -> void :
		entry.erase("bg_fly")
		if is_same(_maps.get(id), entry) and index.get("maps", {}).has(str(id)):
			_fetch_drawn(id, entry, "background"))
	return true



func heal_map(id: int) -> bool:
	var entry: Dictionary = _maps.get(id, {})
	if entry.get("status", "") != "ready" or not index.get("maps", {}).has(str(id)):
		return false
	var images: Dictionary = entry.doc.get("visual", {}).get("images", {})
	var names: Array = entry.get("failed", {}).keys().filter( func(name: String) -> bool: return _drawn_image(name) and images.has(name))
	var bg_now: Variant = entry.get("textures", {}).get("background")
	if bg_now is Texture2D and (bg_now as Texture2D).has_meta("placeholder") and not entry.has("bg_fly") and images.has("background")\
	and not names.has("background"):
		entry.get_or_add("failed", {})["background"] = true
		entry.bg_why = "mồ côi"
		heal_stats.orphan = int(heal_stats.get("orphan", 0)) + 1
		names.append("background")
	if names.is_empty():
		if entry.has("heals") and not entry.has("bg_fly"):
			heal_stats.healed += 1
			entry.erase("heals")
			entry.erase("heal_at")
		return false
	var n: int = int(entry.get("heals", 0))
	if n >= HEAL_MAX and not names.has("background"):
		return false
	var now: int = Time.get_ticks_msec()
	if not entry.has("heal_at"):
		entry.heal_at = now + int(float(HEAL_WAIT[0]) * 1000.0)
	if now < int(entry.heal_at):
		return true
	entry.heals = n + 1
	entry.heal_at = now + int(float(HEAL_WAIT[mini(n + 1, HEAL_WAIT.size() - 1)]) * 1000.0)
	heal_stats.heal += 1
	_map_last = id
	var asked: Dictionary = entry.get_or_add("asked", {})
	for name: String in names:
		if name == "background" and entry.has("bg_fly"):
			continue
		entry.failed.erase(name)
		asked[name] = true
		_fetch_drawn(id, entry, name)
	return true





func bg_report(id: int, live: Dictionary, drawn: Dictionary) -> String:
	var entry: Dictionary = _maps.get(id, {})
	return "st=%s same=%s fail=%s fly=%s bg=%s to=%d/%d heals=%d why=%s tries=%d q=%d dq=%d/%d last=%d hs=%s" % [
		str(entry.get("status", "none")), str( not live.is_empty() and is_same(live, drawn)), str(entry.get("failed", {}).has("background")), 
		str(entry.has("bg_fly")), _bg_net(id, entry), int(net_stats.to), int(net_stats.stall), int(entry.get("heals", 0)), str(entry.get("bg_why", "-")), int(entry.get("bg_tries", 0)), _queue.size(), 
		_dq.size(), _dq_slow.size(), _map_last, JSON.stringify(heal_stats).trim_suffix("}") + ",\"mf1\":" + JSON.stringify(bg_stats) + "}"]

func _relieve() -> int:
	heal_stats.bad += 1
	var gone: int = 0
	for id: int in _maps.keys():
		if id != _map_last and str(_maps[id].get("status", "")) != "loading":
			_maps.erase(id)
			gone += 1
	_fresh.clear()
	heal_stats.relieve += gone
	return gone



func _map_size_ok(entry: Dictionary, name: String, texture: Variant) -> bool:
	if not (texture is Texture2D) or not name.begins_with("npc-"):
		return true
	var images: Variant = (entry.get("doc", {}) as Dictionary).get("visual", {}).get("images", {})
	var row: Variant = (images as Dictionary).get(name) if images is Dictionary else null
	var want: Variant = (row as Dictionary).get("size") if row is Dictionary else null
	if not (want is Array) or (want as Array).size() < 2:
		return true
	var tex: Texture2D = texture
	var file: String = str(index.get("maps", {}).get(str(_map_of(entry)), "?")) + "/" + str((row as Dictionary).get("file", ""))
	var src: String = str(_map_src.get(file, "?"))
	_map_src.erase(file)
	if tex.get_width() == int(want[0]) and tex.get_height() == int(want[1]):
		map_size_stats.ok += 1
		return true
	map_size_stats.bad += 1
	if int(map_size_stats.bad) <= 3:
		push_error("mapsz1 %s cỡ %dx%d ≠ %dx%d [%s] lần %d" % [file, tex.get_width(), tex.get_height(), int(want[0]), int(want[1]), src, 
			int(map_size_stats.bad)])
	if not local:
		_vprobe[file] = true
	if _avc_on:
		var cached: String = avc_file(vmap, _vplain, file)
		if not cached.is_empty() and FileAccess.file_exists(cached):
			var fa: FileAccess = FileAccess.open(cached, FileAccess.READ)
			var n: int = int(fa.get_length()) if fa != null else 0
			if fa != null:
				fa.close()
			_avc_drop(file, cached, n)
	return false


func _map_of(entry: Dictionary) -> int:
	for id: int in _maps:
		if is_same(_maps[id], entry):
			return id
	return -1

func _drawn_image(name: String) -> bool:

	return name in ["background", "sky", "air", "minimap"] or (name.begins_with("npc-") and name.substr(4).is_valid_int())



func want_map_image(id: int, name: String) -> bool:
	var entry: Dictionary = _maps.get(id, {})
	if entry.get("status", "") != "ready":
		return false
	if entry.textures.has(name):
		return true
	var images: Dictionary = entry.doc.visual.get("images", {})
	if not images.has(name) or not index.maps.has(str(id)):
		return false
	if not entry.has("asked"):
		entry["asked"] = {}
	if not entry.asked.has(name):
		entry.asked[name] = true
		_fetch(str(index.maps[str(id)]) + "/" + str(images[name].file), true, func(texture: Variant) -> void :
			if texture != null and _map_size_ok(entry, name, texture):
				entry.textures[name] = texture
			else:
				entry.get_or_add("failed", {})[name] = true)
	return true





func warm_map(id: int) -> Array:
	var entry: Dictionary = _maps.get(id, {})
	if entry.get("status", "") != "ready":
		return []
	var jobs: Array = []
	for name: String in entry.doc.visual.get("images", {}):
		if name.begins_with("npc-") and not _drawn_image(name) and want_map_image(id, name):
			jobs.append(["m", "%d|%s" % [id, name]])
		elif _drawn_image(name) and not entry.textures.has(name) and not entry.get("failed", {}).has(name):
			jobs.append(["m", "%d|%s" % [id, name]])
	if fx.is_empty():
		return jobs
	var add: Callable = _warm_adder(jobs, {})
	for template: Variant in entry.doc.visual.get("npc_templates", {}):
		for camp_a: bool in [false, true]:
			for key: String in [npc_destroy(int(template), camp_a), npc_left(int(template), camp_a), npc_open(int(template))]:
				add.call("e", key)
	for chunk: Dictionary in entry.doc.chunks:
		if int(chunk.tag) != 13:
			continue
		for portal: Dictionary in chunk.data.get("portals", []):
			add.call("e", portal_key(portal))
	for key: String in MAP_WARM.get(id, []):
		add.call("e", key)


	var art: Array = mapart.get(str(id), [])
	if ios_shrink or art.size() != 3:
		return jobs
	for sid: Variant in art[0]:
		_warm_exhibit(int(sid), add)
	for iid: Variant in art[1]:
		var row: Dictionary = item(int(iid))
		for field: String in ["o", "e", "n", "x"]:
			add.call("e", str(row.get(field, "")))
	for bid: Variant in art[2]:
		_warm_buff(int(bid), add)
	return jobs



static func portal_key(portal: Dictionary) -> String:
	var template: int = int(portal.get("nTpltId", 0))
	if template < 1 or template > 3:
		return ""
	return "portal/%s%s" % ["open" if int(portal.get("nFirstState", 0)) == 1 else "close", "" if template == 3 else "_png"]

func _map_step(id: int) -> void :
	var entry: Dictionary = _maps[id]
	map_progress.emit(id, map_fraction(id))
	if entry.done < entry.total:
		return
	_ready_map(id)



const MAP_WARM: Dictionary = {30: ["item/kuangjingbengta", "item/kuangjingbengta01", "dlg/jiaoguan04", "dlg/talkgroud"], 40: ["item/si_dihuopenquan01", "remove/sceneItem_si_dihuopenquan02", "item/si_dihuopenquan03", "buff/buff_dalongdianran", "buff/slow01", "dlg/jiaoguan04", "dlg/talkgroud"]}

func _ready_map(id: int) -> void :
	var entry: Dictionary = _maps[id]
	for key: String in MAP_WARM.get(id, []):
		effect(key, true)
	if not entry.textures.has("background"):
		entry.textures["background"] = _placeholder(entry.doc)
	entry.status = "ready"
	map_ready.emit(id, true)

func _map_failed(id: int, why: String = "") -> void :
	_maps[id].status = "failed"
	_maps[id].why = why
	map_ready.emit(id, false)



func art_external(external: String, tank: int) -> String:
	if state != "ready" or index.externals.has(external):
		return external
	var fallback: String = str(int(index.get("tanks", {}).get(str(tank), -1)))
	return fallback if index.externals.has(fallback) else external


func external_art(external: String) -> Dictionary:
	if not ios_shrink:
		_art_used[external] = Time.get_ticks_msec()
	if _art.has(external):
		return _art[external]
	if state != "ready" or _art_loading.has(external):
		return {}
	var parts: Dictionary = index.externals.get(external, {})

	if not parts.has("body"):
		print("Gói đồ hoạ: ngoại hình %s chưa có hình tank" % external)
		_art[external] = {}
		return {}
	var loading: Dictionary = {"parts": {}, "left": parts.size()}
	_art_loading[external] = loading
	for part: String in parts:
		_component(int(parts[part]), func(value: Variant) -> void :
			if value != null:
				loading.parts[part] = value
			loading.left -= 1
			if loading.left == 0:
				_art_loading.erase(external)
				_art[external] = loading.parts if loading.parts.size() == parts.size() else {}
				art_ready.emit(external))
	return {}


func art_settled(external: String) -> bool:
	return _art.has(external)


func _settle(key: String, path: String) -> void :
	startup[key] = true
	picture_ready.emit(path)




func want_fallback_font() -> void :
	if _fallback_asked or base.is_empty():
		return
	_fallback_asked = true
	_fetch("l/fallback.ttf", false, func(value: Variant) -> void :
		if value is FontFile:
			use_fallback_font(value)
	, false, true)


static func use_fallback_font(value: FontFile) -> void :
	attach_cjk_font()
	var bold: FontVariation = FontVariation.new()
	bold.base_font = value
	bold.variation_embolden = 0.6
	for weight: String in ["Regular", "Medium", "SemiBold", "Bold", "ExtraBold"]:
		var font: Font = load("res://assets/fonts/BeVietnamPro-%s.ttf" % weight)
		if font != null:
			font.fallbacks = [value if weight in ["Regular", "Medium"] else bold] + _cjk_tail(weight in ["Regular", "Medium"])

	for weight: String in ["Regular", "Bold"]:
		var arial: Font = load("res://assets/fonts/LCBBSans-%s.ttf" % weight)
		if arial != null:
			arial.fallbacks = [value if weight == "Regular" else bold] + _cjk_tail(weight == "Regular")




static func attach_cjk_font() -> void :
	if not _cjk_fonts.is_empty():
		return
	var cjk: Font = load("res://assets/fonts/LCBBCjk.tres")
	if cjk == null:
		return
	var bold: FontVariation = FontVariation.new()
	bold.base_font = cjk
	bold.variation_embolden = 0.6
	_cjk_fonts = [cjk, bold]
	for weight: String in ["Regular", "Medium", "SemiBold", "Bold", "ExtraBold"]:
		_join_cjk(load("res://assets/fonts/BeVietnamPro-%s.ttf" % weight), weight in ["Regular", "Medium"])
	for weight: String in ["Regular", "Bold"]:
		_join_cjk(load("res://assets/fonts/LCBBSans-%s.ttf" % weight), weight == "Regular")

static func _join_cjk(font: Font, light: bool) -> void :
	if font == null:
		return
	_cjk_fonts.append(font)
	var tail: Array = _cjk_tail(light)
	if not font.fallbacks.has(tail[0]):
		font.fallbacks = font.fallbacks + tail

static func _cjk_tail(light: bool) -> Array:
	if _cjk_fonts.size() < 2:
		return []
	return [_cjk_fonts[0] if light else _cjk_fonts[1]]


func ainpc_row(template: int) -> Array:
	if not _ainpc_asked:
		_ainpc_asked = true
		_fetch("l/ainpc.json", false, func(value: Variant) -> void :
			ainpc = value.t if value is Dictionary and value.get("t") is Dictionary else {}
			ainpc_settled = true)
	return ainpc.get(str(template), [])



func fire_exhibit(template: int, turret: int, tank: bool) -> int:
	if fx.is_empty():
		return 0
	if tank and template in [1, 17]:
		return int(fx.cannons.get(str(turret), 1))
	return int(skill(template).get("b", 1))


func known_skill(id: int) -> bool:
	var ids: Variant = fx.get("skill_ids")
	if not ids is Array:
		return true
	if _known_skills.is_empty():
		for sid: Variant in ids:
			_known_skills[int(sid)] = true
	return _known_skills.has(id)






const LEVEL_RING: int = 15001
const ENTRY_RING: int = 612111
const BUSH_BUFF: int = 16000

func warm_battle(looks: Array, kin: int = 1) -> Array:
	if state != "ready" or fx.is_empty():
		return []
	if kin >= 2 and ios_shrink:
		kin = 1
	ainpc_row(0)
	var table: Dictionary = fx.get("preload", {})
	var jobs: Array = []
	var add: Callable = _warm_adder(jobs, {})
	var buffs: Array = []
	var first: bool = true
	for look: Dictionary in looks:
		var tank: int = int(look.get("tank", 0))
		var external: String = str(int(look.get("external", 0)))
		var art: String = art_external(external, tank)
		add.call("a", art)
		var ids: Array = table.get("tanks", {}).get(str(tank), []).duplicate()
		var skin: Array = table.get("skins", {}).get(external, [])
		for i: int in mini(ids.size(), skin.size()):
			if int(skin[i]) != 0:
				ids[i] = skin[i]
		var kit: Array = ids.duplicate()
		for ext: String in [external, str(int(index.get("tanks", {}).get(str(tank), 0)))]:
			var res: Dictionary = table.get("externals", {}).get(ext, {})
			ids.append_array(res.get("s", []))
			buffs.append_array(res.get("b", []))


			for iid: Variant in res.get("i", []):
				var row: Dictionary = item(int(iid))
				for field: String in ["o", "e", "n", "x"]:
					add.call("e", str(row.get(field, "")))
		var exhibits: Array = [1, int(fx.get("cannons", {}).get(str(turret_of(art)), 1))]
		for sid: Variant in ids:
			var entry: Dictionary = skill(int(sid))
			for field: String in ["b", "s", "a", "c"]:
				if int(entry.get(field, 0)) != 0:
					exhibits.append(int(entry[field]))
			add.call("e", skill_name(int(sid)))
			buffs.append_array(table.get("skill_buffs", {}).get(str(int(sid)), []))
			var hud_row: Array = skill_hud(int(sid))
			if first and not hud_row.is_empty():
				add.call("i", "s/" + str(hud_row[0]))

		if int(look.get("level", 0)) >= 6:
			buffs.append(int(lobby.get("halos", {}).get(str(int(look.get("halo", 0))), LEVEL_RING)))
		for id: int in exhibits:
			_warm_exhibit(id, add)
		for key: Variant in body_death(external, tank):
			add.call("e", str(key))
		if kin >= 2 or (kin == 1 and first):
			_add_kin(kit, add, buffs)

		for bid: Variant in buffs:
			_warm_buff(int(bid), add)
		buffs.clear()
		first = false

	var common: Array = (table.get("common_buffs", []) as Array).duplicate()
	common.append_array([ENTRY_RING, BUSH_BUFF])
	for bid: Variant in common:
		var row: Array = buff(int(bid))
		if not row.is_empty():
			add.call("e", str(row[0]))
		var buff_row: Array = buff_hud(int(bid))
		if not buff_row.is_empty():
			add.call("i", "b/" + str(buff_row[0]))
	for key: String in [tank_born(), tank_hurt(), bullet_gone(), tank_face()]:
		add.call("e", key)

	for row: Variant in (fx.get("tank_faces", {}) as Dictionary).values():
		if row is Array and not (row as Array).is_empty():
			add.call("e", str(row[0]))
	return jobs


func _warm_adder(jobs: Array, seen: Dictionary) -> Callable:
	return func(kind: String, key: String) -> void :


		if key.is_empty() or seen.has(kind + key) or (kind == "i" and key.length() <= 2):
			return
		seen[kind + key] = true
		jobs.append([kind, key])
		match kind:
			"e":
				effect(key, true)
			"s":
				sound(key, true)
			"a":
				external_art(key)
			"i":
				icon(key.substr(0, 1), key.substr(2), true)

func _warm_exhibit(id: int, add: Callable) -> void :
	var ex: Dictionary = exhibit(id)
	for field: String in ["b", "x", "u", "lb", "lh"]:
		add.call("e", str(ex.get(field, "")))
	for tail: Variant in ex.get("t", []):
		add.call("e", str(tail))
	var row: Variant = sounds.get("b", {}).get(str(id))
	if row is Array and row.size() >= 2:
		if not str(row[0]).is_empty():
			add.call("s", "s/f/%s.mp3" % row[0])
		if not str(row[1]).is_empty():
			add.call("s", "s/x/%s.mp3" % row[1])

func _warm_buff(id: int, add: Callable) -> void :
	var row: Array = buff(id)
	if not row.is_empty():
		add.call("e", str(row[0]))
	for field: String in ["b", "lb", "lh"]:
		add.call("e", str(link_buff(id).get(field, "")))
	var buff_row: Array = buff_hud(id)
	if not buff_row.is_empty():
		add.call("i", "b/" + str(buff_row[0]))

	var buff_sound: String = str(sounds.get("bf", {}).get(str(id), ""))
	if not buff_sound.is_empty():
		add.call("s", "s/f/%s.mp3" % buff_sound)



func warm_first(jobs: Array) -> void :
	for job: Array in jobs:
		var key: String = str(job[1])
		match str(job[0]):
			"e":
				effect(key)
			"s":
				sound(key)
			"i":
				if key.length() > 2:
					icon(key.substr(0, 1), key.substr(2))



func refill_fx() -> void :
	for key: String in _effects.keys():
		if _effects[key] == null:
			_effects.erase(key)
	for cid: int in _components.keys():
		if _components[cid] == null:
			_components.erase(cid)
	for external: String in _art.keys():
		if (_art[external] as Dictionary).is_empty():
			_art.erase(external)







func _add_kin(kit: Array, add: Callable, buffs: Array) -> void :
	var kin: Dictionary = {}
	for sid: Variant in kit:
		if int(sid) >= 100000 and int(sid) <= 999999:
			kin[int(sid) / 1000] = true
	if kin.is_empty():
		return
	var items: Dictionary = fx.get("items", {})
	var drops: Dictionary = sounds.get("c", {})
	for key: String in items:
		if kin.has(int(key) / 1000):
			var row: Dictionary = items[key]
			for field: String in ["o", "e", "n", "x"]:
				add.call("e", str(row.get(field, "")))
			var pair: Variant = drops.get(key)
			if pair is Array and (pair as Array).size() >= 2:
				for file: Variant in pair:
					if not str(file).is_empty():
						add.call("s", "s/f/%s.mp3" % file)
	for key: String in fx.get("buffs", {}):
		if kin.has(int(key) / 1000):
			buffs.append(int(key))
	var runtime: Dictionary = fx.get("npc_rt", {})
	for key: String in runtime:
		if kin.has(int(key) / 1000):
			add.call("e", str(runtime[key].get("n", "")))
	for key: String in ainpc:
		if kin.has(int(key) / 1000):
			for i: int in mini(2, (ainpc[key] as Array).size()):
				if int(ainpc[key][i]) != 0:
					add.call("a", str(int(ainpc[key][i])))



func ios_keep(jobs: Array) -> void :
	if not ios_shrink:
		return
	var now: int = Time.get_ticks_msec()
	for job: Array in jobs:
		if str(job[0]) == "e" and _fx_used.has(job[1]):
			_fx_used[job[1]] = now


func warm_fraction(jobs: Array) -> float:
	if jobs.is_empty():
		return 1.0
	var done: int = 0
	for job: Array in jobs:
		match str(job[0]):
			"e":
				done += int(_effects.has(job[1]))
			"s":
				done += int(_sound_done.has(job[1]))
			"a":
				done += int(_art.has(job[1]))
			"m":
				var part: PackedStringArray = str(job[1]).split("|", true, 1)
				var entry: Dictionary = _maps.get(int(part[0]), {})
				done += int(entry.get("textures", {}).has(part[1]) or entry.get("failed", {}).has(part[1]))
			"i":
				done += int(str(job[1]).length() <= 2 or _icon_done.has("i/%s.webp" % job[1]))
	return float(done) / float(jobs.size())


func skill(id: int) -> Dictionary:
	return fx.get("skills", {}).get(str(id), {})

func exhibit(id: int) -> Dictionary:
	return fx.get("exhibits", {}).get(str(id), {})



const BUFF_LAYER: Dictionary = {10400193: 0}


func buff(id: int) -> Array:
	var row: Array = fx.get("buffs", {}).get(str(id), [])
	if BUFF_LAYER.has(id) and row.size() > 1 and int(row[1]) != int(BUFF_LAYER[id]):
		row = row.duplicate()
		row[1] = int(BUFF_LAYER[id])
	return row



var _normal_shots: Dictionary = {}
func normal_shot(id: int) -> bool:
	if _normal_shots.is_empty():
		for v: Variant in fx.get("normal_bullets", []):
			_normal_shots[int(v)] = true
	return _normal_shots.has(id)



var _still: Dictionary = {}
var _still_fx: Dictionary = {}
func still_buff(id: int) -> bool:
	if _still.is_empty():
		for v: Variant in hud.get("still", []):
			_still[int(v)] = true
			var row: Array = buff(int(v))
			if not row.is_empty():
				var keys: Array = _still_fx.get(int(v) / 1000, [])
				if not keys.has(str(row[0])):
					keys.append(str(row[0]))
				_still_fx[int(v) / 1000] = keys
	return _still.has(id)



func warm_still(id: int) -> void :
	still_buff(0)
	for key: String in _still_fx.get(id / 1000, []):
		effect(key, true)


func famulus(item: int) -> Array:
	return fx.get("famulus", {}).get("items", {}).get(str(item), [])


func famulus_star(rank: int) -> String:
	return str(fx.get("famulus", {}).get("stars", {}).get(str(rank), ""))


func famulus_wings(rank: int) -> Array:
	return fx.get("famulus", {}).get("wings", {}).get(str(mini(rank, 20)), [])

func link_buff(id: int) -> Dictionary:
	return fx.get("link_buffs", {}).get(str(id), {})


func buff_show(id: int) -> Array:
	return fx.get("show", {}).get(str(id), [])


func body_death(external: String, tank: int) -> Array:
	if state != "ready":
		return []
	var body: int = int(index.externals.get(art_external(external, tank), {}).get("body", 0))
	return fx.get("bodies", {}).get(str(body), [])

func item(id: int) -> Dictionary:
	return fx.get("items", {}).get(str(id), {})



func npc_destroy(template: int, camp_a: bool) -> String:
	var value: Variant = fx.get("npc_destroy", {}).get(str(template), "")
	if value is Array:
		return str(value[1 if camp_a else 0]) if value.size() == 2 else ""
	return str(value)


func spray_picture(id: int) -> String:
	var stem: String = str(fx.get("sprays", {}).get(str(id), ""))
	return "l/sp/%s.webp" % stem if not stem.is_empty() else ""


func npc_left(template: int, camp_a: bool) -> String:
	var value: Variant = fx.get("npc_left", {}).get(str(template), "")
	if value is Array:
		return str(value[1 if camp_a else 0]) if value.size() == 2 else ""
	return str(value)


func npc_open(template: int) -> String:
	return str(fx.get("npc_open", {}).get(str(template), ""))


func tank_hurt() -> String:
	return str(fx.get("tank_hurt", ""))


func tank_born() -> String:
	return str(fx.get("tank_born", ""))


func bullet_gone() -> String:
	return str(fx.get("bullet_gone", ""))


func tank_face() -> String:
	return str(fx.get("tank_face", ""))


func face_key(face: int) -> String:
	var row: Variant = (fx.get("tank_faces", {}) as Dictionary).get(str(face))
	return str(row[0]) if row is Array and (row as Array).size() >= 1 else ""

func face_priority(face: int) -> int:
	var row: Variant = (fx.get("tank_faces", {}) as Dictionary).get(str(face))
	return int(row[1]) if row is Array and (row as Array).size() >= 2 else 0


func pet_of(item: int) -> Array:
	var row: Variant = (fx.get("pets", {}) as Dictionary).get(str(item))
	return row if row is Array and (row as Array).size() >= 3 else []


func pet_star(rank: int) -> String:
	return str((fx.get("pet_stars", {}) as Dictionary).get(str(rank), ""))


func pet_star_front(rank: int) -> String:
	return str((fx.get("pet_star_fronts", {}) as Dictionary).get(str(rank), ""))


func skill_name(skill: int) -> String:
	return str(fx.get("skill_names", {}).get(str(skill), ""))


func tank_speed() -> String:
	return str(fx.get("tank_speed", ""))


func skill_shake(skill: int, ready: bool) -> int:
	var table: Variant = fx.get("shake", {})
	var row: Variant = table.get("skills", {}).get(str(skill)) if table is Dictionary else null
	return int(row[1 if ready else 0]) if row is Array and row.size() >= 2 else 0



func shake_of(kind: String, id: int) -> int:
	var table: Variant = fx.get("shake", {})
	var rows: Variant = table.get(kind, {}) if table is Dictionary else null
	return int(rows.get(str(id), 0)) if rows is Dictionary else 0


func has_external(external: String) -> bool:
	return state == "ready" and index.externals.has(external)

var _rules: Dictionary = {}
var _rules_from: Variant = null




func buff_rule(id: int) -> Array:
	var source: Variant = fx.get("buff_rules", {})
	if not is_same(source, _rules_from):
		_rules_from = source
		_rules.clear()
		if source is Dictionary:
			var kinds: Array = ["outlook", "lock", "turn", "speed"]
			for i in range(kinds.size()):
				var table: Variant = source.get(kinds[i], {})
				if table is Dictionary:
					for key: String in table:
						if not _rules.has(int(key)):
							_rules[int(key)] = [0, 0, 0, 0]
						_rules[int(key)][i] = int(table[key])
	return _rules.get(id, [])

var _appear: Dictionary = {}
var _appear_from: Variant = null


func ainpc_appear(template: int) -> String:
	var source: Variant = fx.get("ainpc_appear", {})
	if not is_same(source, _appear_from):
		_appear_from = source
		_appear.clear()
		if source is Dictionary:
			for key: String in source:
				for tpl: Variant in source[key]:
					_appear[int(tpl)] = key
	return str(_appear.get(template, ""))


func halo_ui(item: int) -> Array:
	return fx.get("halo_ui", {}).get(str(item), [])

func turret_of(external: String) -> int:
	return int(index.get("externals", {}).get(external, {}).get("turret", 0)) if state == "ready" else 0



func effect(key: String, slow: bool = false) -> Dictionary:
	if key.is_empty() or state != "ready":
		return {}
	if slow and _pc_battle:
		_pc_want[key] = true
	if _effects.has(key):
		_fx_used[key] = Time.get_ticks_msec()
		return _effects[key] if _effects[key] != null else {}
	if _effect_loading.has(key):
		if not slow and bool(_effect_loading[key]):
			_effect_loading[key] = false
			_hurry(key)
		return {}
	_effect_loading[key] = slow
	_sheet("e/%s.json" % key, func(data: Variant) -> void :
		if not data is Dictionary or not data.get("pages") is Array or data.pages.is_empty() or not data.get("frames") is Array or data.frames.is_empty():
			_effect_done(key, null)
			return
		var result: Dictionary = {"data": data, "pages": []}
		result.pages.resize(data.pages.size())
		var counter: Dictionary = {"left": data.pages.size(), "failed": false}
		for page in range(data.pages.size()):
			_fetch("e/" + str(data.pages[page].file), true, func(texture: Variant) -> void :
				counter.left -= 1
				if texture == null:
					counter.failed = true
				else:
					result.pages[page] = texture
				if counter.left == 0:
					_effect_done(key, null if counter.failed else result), false, false, bool(_effect_loading.get(key, false)), key)
	, slow, key)
	return {}


func effect_cached(key: String) -> Dictionary:
	var hit: Variant = _effects.get(key)
	if hit is Dictionary:
		_fx_used[key] = Time.get_ticks_msec()
	return hit if hit is Dictionary else {}


func _hurry(tag: String) -> void :
	_hurry_decode(tag)
	var keep: Array = []
	for job: Array in _slow:
		if str(job[5]) == tag:
			_queue.append(job)
		else:
			keep.append(job)
	_slow = keep
	_pump()



func icon(kind: String, key: String, slow: bool = false) -> Texture2D:
	if key.is_empty() or base.is_empty():
		return null
	var path: String = "i/%s/%s.webp" % [kind, key]
	if _icons.has(path):
		if not slow and _icon_slow.has(path):
			_icon_slow.erase(path)
			_hurry(path)
		return _icons[path]
	_icons[path] = null
	if slow:
		_icon_slow[path] = true
	_fetch(path, true, func(texture: Variant) -> void :
		_icons[path] = texture
		_icon_slow.erase(path)
		_icon_done[path] = true, false, false, slow, path)
	return null

var _icon_slow: Dictionary = {}
var _icon_done: Dictionary = {}

var _qh1_fail: Dictionary = {}



func picture_again(path: String, wait: float) -> void :
	if not _qh1_fail.has(path) or Time.get_ticks_msec() - int(_qh1_fail[path]) < int(wait * 1000.0):
		return
	_qh1_fail.erase(path)
	if _pictures.has(path) and _pictures[path] == null:
		_pictures.erase(path)


func picture(path: String) -> Texture2D:
	if path.is_empty() or base.is_empty():
		return null
	if path.begins_with(QG1_PREFIX):
		var qg1: Texture2D = _qg1_icon(path)
		if qg1 != null:
			return qg1
	var moving: Texture2D = _hc_moving(path)
	if moving != null:
		return moving
	if not ios_shrink:
		_pic_used[path] = Time.get_ticks_msec()
	if not _pictures.has(path):
		_pictures[path] = null
		_fetch(path, true, func(texture: Variant) -> void :
			_pictures[path] = texture
			if texture == null:
				_qh1_fail[path] = Time.get_ticks_msec()
			else:
				_qh1_fail.erase(path)
			picture_ready.emit(path))
	return _pictures[path]





const QG1_FILE: String = "res://assets/ui/hall/quaguild1.png"
const QG1_PREFIX: String = "l/it/gift_juntuan_0"
const QG1_ICONS: Dictionary = {"2006004": "gift_juntuan_04", "2006006": "gift_juntuan_06", "2006007": "gift_juntuan_07", 
	"2006008": "gift_juntuan_08", "2006009": "gift_juntuan_09"}
var _qg1_cut: Dictionary = {}

func _qg1_icon(path: String) -> Texture2D:
	var key: String = path.get_file().get_basename()
	if _qg1_cut.has(key):
		return _qg1_cut[key]
	var at: int = QG1_ICONS.values().find(key)
	if at < 0 or not ResourceLoader.exists(QG1_FILE):
		return null
	var strip: Texture2D = load(QG1_FILE)
	if strip == null:
		return null
	var cut: AtlasTexture = AtlasTexture.new()
	cut.atlas = strip
	cut.region = Rect2(at * 100, 0, 100, 100)
	_qg1_cut[key] = cut
	return cut


func _qg1_fill(table: Dictionary) -> void :
	var items: Variant = table.get("items")
	if not (items is Dictionary):
		return
	for id: String in QG1_ICONS:
		var row: Variant = (items as Dictionary).get(id)
		if row is Array and (row as Array).size() >= 3 and str(row[2]).is_empty():
			row[2] = QG1_ICONS[id]


func load_garage() -> void :
	if _garage_asked or base.is_empty():
		return
	_garage_asked = true
	_fetch("l/garage.json", false, func(value: Variant) -> void :
		garage = value if value is Dictionary and value.get("tanks") is Dictionary else {}
		if garage.is_empty():
			_garage_asked = false
		picture_ready.emit("l/garage.json"), false, false, false, "", true)


func load_bag() -> void :
	load_live()
	if _bag_asked or base.is_empty():
		return
	_bag_asked = true
	_fetch("l/bag.json", false, func(value: Variant) -> void :
		bag = value if value is Dictionary and value.get("items") is Dictionary else {}
		_qg1_fill(bag)
		if bag.is_empty():
			_bag_asked = false
		picture_ready.emit("l/bag.json"), false, false, false, "", true)


func load_bagx() -> void :
	load_live()
	if _bagx_asked or base.is_empty():
		return
	_bagx_asked = true
	_fetch("l/bagx.json", false, func(value: Variant) -> void :
		bagx = value if value is Dictionary and value.get("acem") is Dictionary else {}
		if bagx.is_empty():
			_bagx_asked = false
		picture_ready.emit("l/bagx.json"))


func load_helper() -> void :
	if _helper_asked or base.is_empty():
		return
	_helper_asked = true
	_fetch("l/helper.json", false, func(value: Variant) -> void :
		helper = value if value is Dictionary and value.get("tpl") is Dictionary else {}
		if helper.is_empty():
			_helper_asked = false
		picture_ready.emit("l/helper.json"))


func load_crystal() -> void :
	if _crystal_asked or base.is_empty():
		return
	_crystal_asked = true
	_fetch("l/crystal.json", false, func(value: Variant) -> void :
		crystal = value if value is Dictionary and value.get("items") is Dictionary else {}
		if crystal.is_empty():
			_crystal_asked = false
		picture_ready.emit("l/crystal.json"))



func load_crystalx() -> void :
	if _crystalx_asked or base.is_empty():
		return
	_crystalx_asked = true
	_fetch("l/crystalx.json", false, func(value: Variant) -> void :
		crystalx = value if value is Dictionary and value.get("convert") is Array else {}
		if crystalx.is_empty():
			_crystalx_asked = false
		picture_ready.emit("l/crystalx.json"))


func load_rank() -> void :
	if _rank_asked or base.is_empty():
		return
	_rank_asked = true
	_fetch("l/rank.json", false, func(value: Variant) -> void :
		rank = value if value is Dictionary and value.get("ranks") is Array else {}
		if rank.is_empty():
			_rank_asked = false
		picture_ready.emit("l/rank.json"))


func load_gda_loading() -> void :
	if _gda_loading_asked or base.is_empty():
		return
	_gda_loading_asked = true
	_fetch("l/gda/loading.json", false, func(value: Variant) -> void :
		gda_loading = value if value is Dictionary and value.get("guild") is Dictionary else {}
		if gda_loading.is_empty():
			_gda_loading_asked = false
		picture_ready.emit("l/gda/loading.json"))



func load_gda_hall() -> void :
	if base.is_empty() or not gda_hall.is_empty() or (_gda_hall_at >= 0 and Time.get_ticks_msec() - _gda_hall_at < LV_EVERY_MS):
		return
	_gda_hall_at = Time.get_ticks_msec()
	_fetch("l/hall.json", false, func(value: Variant) -> void :
		gda_hall = value if value is Dictionary and value.get("ornate") is Dictionary else {}
		if not gda_hall.is_empty():
			picture_ready.emit("l/hall.json"))


func load_gda_pveload() -> void :
	if _gda_pveload_asked or base.is_empty():
		return
	_gda_pveload_asked = true
	_fetch("l/gda/pveload.json", false, func(value: Variant) -> void :
		gda_pveload = value if value is Dictionary and value.get("maps") is Dictionary else {}
		if gda_pveload.is_empty():
			_gda_pveload_asked = false
		picture_ready.emit("l/gda/pveload.json"))



func load_tips() -> void :
	if _tips_asked or base.is_empty():
		return
	_tips_asked = true
	_fetch("i/tips.json", false, func(value: Variant) -> void :
		tips = value if value is Dictionary and value.get("skills") is Dictionary and value.get("desc") is Array else {}
		if tips.is_empty():
			_tips_asked = false
		picture_ready.emit("i/tips.json"), false, false, true)


func load_board() -> void :
	if _board_asked or base.is_empty():
		return
	_board_asked = true
	_fetch("l/bxh.json", false, func(value: Variant) -> void :
		board = value if value is Dictionary and value.get("sections") is Dictionary else {}
		if board.is_empty():
			_board_asked = false
		picture_ready.emit("l/bxh.json"))


func load_quest() -> void :
	if _quest_asked or base.is_empty():
		return
	_quest_asked = true
	_fetch("l/quest.json", false, func(value: Variant) -> void :
		quest = value if value is Dictionary and value.get("quests") is Dictionary else {}
		if quest.is_empty():
			_quest_asked = false
		picture_ready.emit("l/quest.json"))


func load_questx() -> void :
	if _questx_asked or base.is_empty():
		return
	_questx_asked = true
	_fetch("l/questx.json", false, func(value: Variant) -> void :
		questx = value if value is Dictionary and value.get("quests") is Dictionary else {}
		if questx.is_empty():
			_questx_asked = false
		picture_ready.emit("l/questx.json"))



func load_eventsx() -> void :
	if _eventsx_asked or base.is_empty():
		return
	_eventsx_asked = true
	_fetch("l/eventsx.json", false, func(value: Variant) -> void :
		eventsx = value if value is Dictionary and value.get("vip_level") is Array else {}
		if eventsx.is_empty():
			_eventsx_asked = false
		picture_ready.emit("l/eventsx.json"))



func load_garagex() -> void :
	if _garagex_asked or base.is_empty():
		return
	_garagex_asked = true
	_fetch("l/garagex.json", false, func(value: Variant) -> void :
		garagex = value if value is Dictionary and value.get("rent") is Array else {}
		if garagex.is_empty():
			_garagex_asked = false
		picture_ready.emit("l/garagex.json"))


func load_events() -> void :
	if _events_asked or base.is_empty():
		return
	_events_asked = true
	_fetch("l/events.json", false, func(value: Variant) -> void :
		events = value if value is Dictionary and value.get("week") is Array else {}
		if events.is_empty():
			_events_asked = false
		picture_ready.emit("l/events.json"))

func load_fair() -> void :
	if _fair_asked or base.is_empty():
		return
	_fair_asked = true
	_fetch("l/fair.json", false, func(value: Variant) -> void :
		fair = value if value is Dictionary and value.get("wheel") is Dictionary else {}
		if fair.is_empty():
			_fair_asked = false
		picture_ready.emit("l/fair.json"))



const SHIELD_PIERCE_ICON: String = "skill_guide_bd_nc"





const ICON_ALIAS: Dictionary = {472306: "skill_heiliuyatu", 


	675201: "skill_heibaoe", 675301: "skill_heibaok", 675401: "skill_heibaor", 
	368410: "skill_zuozhu02", 368320: "skill_zuozhu04", 
	608410: "skill_zuozhu_himitsu_r_v1", 608320: "skill_zuozhu_himitsu_space_v1"}


func skill_hud(id: int) -> Array:
	var row: Array = hud.get("skills", {}).get(str(id), [])
	if id >= 505001 and id <= 505009 and not row.is_empty() and str(row[0]) == "offline_empty_skill":
		row = row.duplicate()
		row[0] = SHIELD_PIERCE_ICON
	elif ICON_ALIAS.has(id) and not row.is_empty() and str(row[0]) == "offline_empty_skill":
		row = row.duplicate()
		row[0] = ICON_ALIAS[id]
	return row



func skill_cast(id: int) -> Variant:
	var rule: Variant = hud.get("cast", {}).get(str(id))
	return rule if rule is Array else null



func skill_flow(id: int) -> Array:
	var row: Variant = hud.get("flow", {}).get(str(id))
	var values: Array = row.duplicate() if row is Array else [0, 0, 0]
	values.resize(3)
	var entry: Dictionary = skill(id)
	var rule: Variant = skill_cast(id)
	values.append(int(entry.get("c", 0)))
	values.append(int(rule[0]) if rule is Array and not rule.is_empty() else 0)
	values.append(int(entry.get("s", 0)) != 0 or entry.is_empty())
	for i in 3:
		values[i] = int(values[i]) if values[i] != null else 0
	return values


func ban_bits(buff_id: int) -> int:
	var bits: Variant = hud.get("ban", {}).get(str(buff_id))
	return int(bits) if bits != null else -1


func buff_hud(id: int) -> Array:
	return hud.get("buffs", {}).get(str(id), [])

func effect_failed(key: String) -> bool:
	return key.is_empty() or state == "failed" or (_effects.has(key) and _effects[key] == null)

func _effect_done(key: String, value: Variant) -> void :
	_effects[key] = value
	_effect_loading.erase(key)
	if value is Dictionary:
		var px: int = 0
		for page: Variant in value.pages:
			if page is Texture2D:
				var n: int = int(page.get_width()) * int(page.get_height())
				px += mini(n, IOS_CAP_FX) if ios_shrink else n
		_fx_total += px - int(_fx_px.get(key, 0))
		_fx_px[key] = px
		_fx_seq[key] = _trim_no
		if ios_shrink:
			_fx_used[key] = Time.get_ticks_msec()
			if _budgeted():
				ios_fit_fx()
		else:
			_fx_used[key] = Time.get_ticks_msec()
			pc_fit()

func _component(cid: int, done: Callable) -> void :
	if _components.has(cid):
		done.call(_components[cid])
		return
	if _component_waiters.has(cid):
		_component_waiters[cid].append(done)
		return
	_component_waiters[cid] = [done]
	_sheet("c/%d.json" % cid, func(data: Variant) -> void :
		if not data is Dictionary or not data.get("pages") is Array or data.pages.is_empty() or not data.get("frames") is Array:
			_component_done(cid, null)
			return
		var result: Dictionary = {"data": data, "pages": []}
		result.pages.resize(data.pages.size())
		var counter: Dictionary = {"left": data.pages.size(), "failed": false}
		for page in range(data.pages.size()):
			_fetch("c/" + str(data.pages[page].file), true, func(texture: Variant) -> void :
				counter.left -= 1
				if texture == null:
					counter.failed = true
				else:
					result.pages[page] = texture
				if counter.left == 0:
					_component_done(cid, null if counter.failed else result)))

func _component_done(cid: int, value: Variant) -> void :
	_components[cid] = value
	for done: Callable in _component_waiters.get(cid, []):
		done.call(value)
	_component_waiters.erase(cid)


func sound(path: String, slow: bool = false) -> AudioStream:
	if _sounds.has(path):
		if not slow and _sound_slow.has(path):
			_sound_slow.erase(path)
			_hurry(path)
		return _sounds[path]
	if base.is_empty():
		return null
	_sounds[path] = null
	if slow:
		_sound_slow[path] = true
	_fetch(path, false, func(value: Variant) -> void :
		_sounds[path] = value as AudioStream
		_sound_slow.erase(path)
		_sound_done[path] = true, true, false, slow, path)
	return null





const VEIL_JSON: String = "res://assets/pk1img.json"
const VEIL_HEAD: int = 4096
const VEIL_TAIL: int = 20
var veil_stats: Dictionary = {"ok": 0, "back": 0}
var _veil_key: PackedByteArray = PackedByteArray()
var _veil_tag: PackedByteArray = PackedByteArray()
var _veil_off: Dictionary = {}
const BUNDLE: String = "e/bundle.json"
var _veil_ext: String = ".bin"
const K3_PARK_MS: int = 8000
const K3_RETRY: Array = [2.0, 8.0, 30.0, 60.0, 120.0]
const K3_PRE: Array = ["l/gate/", "l/ev/fw/word_thantai.", "l/ev/fw/btn_thantai."]
var _k3_key: PackedByteArray = PackedByteArray()
var _k3_tag: PackedByteArray = PackedByteArray()
var _k3_ext: String = ""
var _k3_off: Dictionary = {}
var _k3_park: Array = []
var _k3_until: int = 0
var _k3_http: HTTPRequest = null
var _k3_busy: bool = false
var _k3_tries: int = 0
var _k3_gen: int = 0
var k3_stats: Dictionary = {"ok": 0, "back": 0, "key": 0, "fail": 0, "park": 0, "drop": 0}
var bundle: Dictionary = {}
var _bundle_body: PackedByteArray = PackedByteArray()
var _bundle_state: int = 0
var _bundle_wait: Array = []

func load_bundle() -> void :
	if _bundle_state != 0 or base.is_empty():
		return
	_bundle_state = 1
	_fetch(BUNDLE, false, func(value: Variant) -> void :
		if value is PackedByteArray:
			_bundle_open(value)
		_bundle_state = 2
		var waiting: Array = _bundle_wait
		_bundle_wait = []
		for job: Array in waiting:
			_sheet(str(job[0]), job[1], bool(job[2]), str(job[3]))
		picture_ready.emit(BUNDLE), false, false, false, "", true)

func _bundle_open(bytes: PackedByteArray) -> void :
	var cut: int = bytes.find(10)
	if cut <= 0:
		return
	var head: Variant = SafeJson.parse(bytes.slice(0, cut).get_string_from_utf8())
	if head is Dictionary:
		bundle = head
		_bundle_body = bytes.slice(cut + 1)

func _bundle_read(path: String) -> Variant:
	var at: Variant = bundle.get(path)
	if not at is Array:
		return null
	return SafeJson.parse(_bundle_body.slice(int(at[0]), int(at[0]) + int(at[1])).get_string_from_utf8())


func _sheet(path: String, done: Callable, slow: bool = false, tag: String = "") -> void :
	if _bundle_state == 1:
		_bundle_wait.append([path, done, slow, tag])
	elif not bundle.is_empty() and _lv_full(path).is_empty():
		done.call_deferred(_bundle_read(path))
	else:
		_fetch(path, false, done, false, false, slow, tag)


func load_mapart() -> void :
	if _mapart_asked or base.is_empty():
		return
	_mapart_asked = true
	_fetch("l/mapart.json", false, func(value: Variant) -> void :
		mapart = value.maps if value is Dictionary and value.get("maps") is Dictionary else {}
		if mapart.is_empty():
			_mapart_asked = false
		picture_ready.emit("l/mapart.json"))


func _parse(path: String, bytes: PackedByteArray, image: bool, audio: bool = false, font: bool = false, cap: int = 0) -> Variant:
	if path == BUNDLE and not bytes.is_empty():
		return bytes
	return _decode(bytes, image, audio, font, cap)

func _decode(bytes: PackedByteArray, image: bool, audio: bool = false, font: bool = false, cap: int = 0) -> Variant:
	if bytes.is_empty():
		return null
	if font:
		var file: FontFile = FontFile.new()
		file.data = bytes
		return file
	if audio:
		var stream: AudioStreamMP3 = AudioStreamMP3.new()
		stream.data = bytes
		return stream if stream.get_length() > 0.0 else null
	if not image:
		return SafeJson.parse(bytes.get_string_from_utf8())
	var decoded: Image = Image.new()
	if decoded.load_webp_from_buffer(bytes) != OK:
		_relieve()
		return null
	decode_stats.now += 1
	return _upload(decoded, cap)



func _fetch(path: String, image: bool, done: Callable, audio: bool = false, font: bool = false, slow: bool = false, tag: String = "", first: bool = false, keep: bool = false) -> void :
	if local and _lv_local(path, image, done, audio, font, slow, tag):
		return
	if local:
		var found: bool = FileAccess.file_exists(base + path)
		if found and image and not audio and not font and _spread():
			_later(FileAccess.get_file_as_bytes(base + path), done, slow, tag)
			return
		done.call_deferred(_parse(path, FileAccess.get_file_as_bytes(base + path), image, audio, font) if found else null)
		return
	if _avc_on and _avc_hit(path, image, done, audio, font, slow, tag):
		return
	if first:
		_queue.push_front([path, image, done, audio, font, tag, keep])
	else:
		(_slow if slow else _queue).append([path, image, done, audio, font, tag, keep])
	_pump()


func _load_pack_ver(source: String = PACK_VER) -> void :
	vbase = ""
	vmap = {}
	if local or not base.ends_with("/a/") or not FileAccess.file_exists(source):
		return
	var doc: Variant = SafeJson.parse(FileAccess.get_file_as_string(source))
	if not (doc is Dictionary) or int((doc as Dictionary).get("v", 0)) != 1 or not ((doc as Dictionary).get("buckets") is Dictionary):
		return
	var buckets: Dictionary = (doc as Dictionary).buckets
	if buckets.is_empty():
		return
	vmap = buckets
	vbase = base.substr(0, base.length() - 2) + "av/"



static func bucket_of(path: String) -> String:
	var parts: PackedStringArray = path.split("/")
	if parts.size() >= 3:
		return parts[0] + "/" + parts[1]
	return parts[0] if parts.size() == 2 else ""


func url(path: String) -> String:
	if not vbase.is_empty():
		var group: String = bucket_of(path)
		var stamp: String = str(vmap.get(group, ""))
		if not stamp.is_empty() and not _vplain.has(group):
			return vbase + stamp + "/" + path
	return base + path


func _address(rel: String) -> Array:
	var lv: String = _lv_full(rel)
	if not lv.is_empty():
		return [lv, false, false]
	var probe: bool = _vprobe.erase(rel)
	var address: String = base + rel if probe else url(rel)
	return [address, probe, not probe and address != base + rel]



func _versioned(job: Array, http: HTTPRequest, result: int, code: int, slow: bool) -> bool:
	var ok: bool = result == HTTPRequest.RESULT_SUCCESS and code == 200
	var group: String = bucket_of(str(job[0]))
	if bool(http.get_meta("versioned", false)):
		if ok:
			_vseen[group] = true
		elif result == HTTPRequest.RESULT_SUCCESS and code >= 400 and code < 500 and code != 408 and code != 429 and not _vseen.has(group):
			_vprobe[str(job[0])] = true
			(_slow if slow else _queue).push_front(job)
			return true
	elif bool(http.get_meta("probe", false)) and ok:
		_vplain[group] = true
	return false


func _load_veil_ext(source: String = VEIL_JSON) -> void :
	_veil_ext = ".bin"
	if _veil_key.is_empty() or not FileAccess.file_exists(source):
		return
	var doc: Variant = JSON.parse_string(FileAccess.get_file_as_string(source))
	if not (doc is Dictionary):
		return
	var s: String = str((doc as Dictionary).get("s", ""))
	var re: RegEx = RegEx.create_from_string("^[a-z0-9]{1,8}$")
	if re != null and re.search(s) != null:
		_veil_ext = "." + s + ".bin"


func _veil_ext_route(where: Array, http: HTTPRequest) -> void :
	if _veil_ext != ".bin" and bool(http.get_meta("veiled", false)) and str(where[0]).ends_with(".bin"):
		where[0] = str(where[0]).trim_suffix(".bin") + _veil_ext



func _load_veil(source: String = VEIL_JSON, web: bool = OS.has_feature("web")) -> void :
	_veil_key = PackedByteArray()
	if local or not web or not FileAccess.file_exists(source) or not ClassDB.class_exists(&"AESContext"):
		return
	var doc: Variant = JSON.parse_string(FileAccess.get_file_as_string(source))
	if not (doc is Dictionary) or int((doc as Dictionary).get("v", 0)) != 1:
		return
	var key: PackedByteArray = str((doc as Dictionary).get("k", "")).hex_decode()
	var tag: PackedByteArray = str((doc as Dictionary).get("t", "")).hex_decode()
	if key.size() == 32 and tag.size() == 4:
		_veil_key = key
		_veil_tag = tag


func _veil_route(job: Array, where: Array, http: HTTPRequest) -> void :
	var path: String = str(job[0])
	var veil: bool = not _veil_key.is_empty() and bool(job[1]) and not bool(job[3]) and not bool(job[4]) and path.ends_with(".webp")\
	and not _veil_off.has(path) and not _veil_off.has(bucket_of(path)) and _lv_full(path).is_empty()
	http.set_meta("veiled", veil)
	if veil:
		where[0] = str(where[0]).trim_suffix(".webp") + ".bin"



func _veil_recv(job: Array, http: HTTPRequest, result: int, code: int, slow: bool, body: PackedByteArray) -> bool:
	var path: String = str(job[0])
	var ok: bool = result == HTTPRequest.RESULT_SUCCESS and code == 200
	if not bool(http.get_meta("veiled", false)):
		if ok and _veil_off.has(path):
			_veil_off[bucket_of(path)] = true
		return false
	if ok and body.size() >= VEIL_TAIL and body.slice(body.size() - 4) == _veil_tag:
		veil_stats.ok += 1
		return false
	if ok:
		_veil_key = PackedByteArray()
	elif result == HTTPRequest.RESULT_SUCCESS and code >= 400 and code < 500 and code != 408 and code != 429:
		_veil_off[path] = true
	else:
		return false
	veil_stats.back += 1
	(_slow if slow else _queue).push_front(job)
	return true


func _unveil(body: PackedByteArray) -> PackedByteArray:
	var n: int = body.size() - VEIL_TAIL
	var k: int = mini(VEIL_HEAD, n - n % 16)
	var head: PackedByteArray = PackedByteArray()
	if k > 0:
		var aes: AESContext = AESContext.new()
		aes.start(AESContext.MODE_CBC_DECRYPT, _veil_key, body.slice(n, n + 16))
		head = aes.update(body.slice(0, k))
		aes.finish()
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = body
	buffer.put_data(head)
	var out: PackedByteArray = buffer.data_array
	buffer.clear()
	out.resize(n)
	return out

func _pump() -> void :
	while ( not _queue.is_empty() or not _slow.is_empty()) and not _idle.is_empty():
		var http: HTTPRequest = _idle.pop_back()
		if http.has_meta("cut"):
			cut_stats.skip += 1
			continue
		if http.has_meta("job") or _idle.has(http):
			_idle.erase(http)
			if http.has_meta("job"):
				continue
		var pick: int = _bg_pick()
		if pick == -2:
			_idle.append(http)
			break
		var from_slow: bool = pick < 0 and _queue.is_empty()
		var job: Array = _queue.pop_at(pick) if pick >= 0 else (_queue.pop_front() if not _queue.is_empty() else _slow.pop_front())
		if _k3_hold(job, from_slow):
			_idle.append(http)
			continue
		http.set_meta("job", job)
		http.set_meta("slow", from_slow)
		var where: Array = _address(str(job[0]))
		http.set_meta("probe", where[1])
		http.set_meta("versioned", where[2])
		_veil_route(job, where, http)
		_veil_ext_route(where, http)
		_k3_route(job, where, http)
		var t0: int = Time.get_ticks_msec()
		http.set_meta("dl", [t0, 0, t0])

		where[0] = _dl_route(str(job[0]), str(where[0]), http)
		if http.request(str(where[0]), AppSession.headers(str(where[0]))) != OK:
			http.remove_meta("job")
			if not _idle.has(http):
				_idle.append(http)
			job[2].call(null)

func _completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest) -> void :
	if http.has_meta("cut"):
		cut_stats.stale += 1
		return
	var job: Array = http.get_meta("job", [])
	http.remove_meta("job")
	var from_slow: bool = bool(http.get_meta("slow", false))
	if not _idle.has(http):
		_idle.append(http)
	if not job.is_empty():
		var ok: bool = result == HTTPRequest.RESULT_SUCCESS and code == 200
		if _dl_back(job, http, result, code, from_slow):
			_pump()
			return
		if result == HTTPRequest.RESULT_TIMEOUT:
			net_stats.to += 1
		if ok and not _bg_gate.is_empty():
			_bg_gate.erase(str(job[0]))
		if _k3_recv(job, http, result, code, from_slow, body):
			_pump()
			return
		if _veil_recv(job, http, result, code, from_slow, body):
			_pump()
			return
		if ok and bool(http.get_meta("veiled", false)):
			body = _unveil(body)
		if _versioned(job, http, result, code, from_slow):
			_pump()
			return
		if not ok and _retry(job, result, code, from_slow):
			_pump()
			return
		if ok and str(job[0]).begins_with("m/"):
			if _map_src.size() > 512:
				_map_src.clear()
			_map_src[str(job[0])] = "net v%d g%d k2%d p%d %dB" % [int(bool(http.get_meta("versioned", false))), int(http.get_meta("vgen", 0)), 
				int(bool(http.get_meta("veiled", false))), int(bool(http.get_meta("probe", false))), body.size()]
		if ok and _avc_on and bool(http.get_meta("versioned", false)):
			_avc_put(str(job[0]), body)
		if ok and int(http.get_meta("vgen", 0)) == 3:
			body = _k3_unveil(body, http.get_meta("vkey", PackedByteArray()))
		if ok and bool(job[1]) and not bool(job[3]) and not bool(job[4]) and _spread():
			_later(body, job[2], from_slow, str(job[5]), shrink_cap(str(job[0])))
		else:
			job[2].call(_parse(str(job[0]), body, job[1], job[3], job[4], shrink_cap(str(job[0]))) if ok else null)
	_pump()






func _stall_tick() -> void :
	var now: int = Time.get_ticks_msec()
	var gap: bool = _stall_last > 0 and now - _stall_last > STALL_GAP_MS
	_stall_last = now
	_dl_tick(now)
	for http: HTTPRequest in _pool:
		if not http.has_meta("job"):
			continue
		var n: int = http.get_downloaded_bytes()
		var dl: Array = http.get_meta("dl", [now, n, now])
		if _dl_slow(http, now, n, gap):
			continue
		if gap or n != int(dl[1]):
			http.set_meta("dl", [now, n, int(dl[2])])
		elif now - int(dl[0]) >= _stall_ms:
			net_stats.stall += 1
			http.cancel_request()
			_completed(HTTPRequest.RESULT_TIMEOUT, 0, PackedStringArray(), PackedByteArray(), http)



func _bg_net(id: int, entry: Dictionary) -> String:
	var doc: Variant = entry.get("doc", {})
	var visual: Variant = (doc as Dictionary).get("visual", {}) if doc is Dictionary else {}
	var images: Variant = (visual as Dictionary).get("images", {}) if visual is Dictionary else {}
	var image: Variant = (images as Dictionary).get("background") if images is Dictionary else null
	if not (image is Dictionary) or not index.get("maps", {}).has(str(id)):
		return "-"
	var file: String = str(index.maps[str(id)]) + "/" + str((image as Dictionary).get("file", ""))
	var now: int = Time.get_ticks_msec()
	for http: HTTPRequest in _pool:
		if http.has_meta("job") and str((http.get_meta("job") as Array)[0]) == file:
			var job: Array = http.get_meta("job")
			var dl: Array = http.get_meta("dl", [now, 0, now])
			return "%dk/%ds/r%d" % [http.get_downloaded_bytes() / 1024, (now - int(dl[2])) / 1000, int(job[7]) if job.size() > 7 else 0]
	for i: int in range(_queue.size()):
		if str(_queue[i][0]) == file:
			return "q%d" % i
	for i: int in range(_slow.size()):
		if str(_slow[i][0]) == file:
			return "s%d" % i
	return "?"

func _bg_hold(path: String) -> void :
	if not _bg_on or local or _pool.is_empty():
		return
	if not _bg_gate.has(path):
		_bg_gate[path] = Time.get_ticks_msec()
	bg_stats.hold += 1
	if is_inside_tree():
		get_tree().create_timer(BG_GATE_MS / 1000.0 + 0.1).timeout.connect(_pump)
	var side: Array = []
	for http: HTTPRequest in _pool:
		if http.has_meta("job") and not str((http.get_meta("job") as Array)[0]).begins_with("m/"):
			side.append(http)
	if side.size() <= BG_SIDE:
		return
	side.sort_custom( func(a: HTTPRequest, b: HTTPRequest) -> bool: return a.get_downloaded_bytes() > b.get_downloaded_bytes())
	for k: int in range(side.size() - 1, BG_SIDE - 1, -1):
		var http: HTTPRequest = side[k]
		var job: Array = http.get_meta("job")
		var slow: bool = bool(http.get_meta("slow", false))
		http.cancel_request()
		http.remove_meta("job")
		(_slow if slow else _queue).push_front(job)
		_cut_rest(http)
		bg_stats.cut += 1




func _cut_rest(http: HTTPRequest) -> void :
	http.set_meta("cut", true)
	_idle.erase(http)
	_cut_back.call_deferred(http)


func _cut_back(http: HTTPRequest) -> void :
	if not is_instance_valid(http):
		return
	http.remove_meta("cut")
	if not http.has_meta("job") and not _idle.has(http):
		_idle.append(http)
	_pump()


func _bg_gating() -> bool:
	if _bg_gate.is_empty():
		return false
	var now: int = Time.get_ticks_msec()
	for path: String in _bg_gate.keys():
		if now - int(_bg_gate[path]) < BG_GATE_MS:
			return true
	return false



func _bg_pick() -> int:
	if not _bg_gating():
		return -1
	for i: int in range(_queue.size()):
		if str(_queue[i][0]).begins_with("m/"):
			return i
	if _queue.is_empty():
		return -2
	var side: int = 0
	for http: HTTPRequest in _pool:
		if http.has_meta("job") and not str((http.get_meta("job") as Array)[0]).begins_with("m/"):
			side += 1
	return -2 if side >= BG_SIDE else -1



func _retry(job: Array, result: int, code: int, slow: bool) -> bool:
	var transient: bool = result in [HTTPRequest.RESULT_CHUNKED_BODY_SIZE_MISMATCH, HTTPRequest.RESULT_CANT_CONNECT, HTTPRequest.RESULT_CANT_RESOLVE, 
		HTTPRequest.RESULT_CONNECTION_ERROR, HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR, HTTPRequest.RESULT_NO_RESPONSE, 
		HTTPRequest.RESULT_REQUEST_FAILED, HTTPRequest.RESULT_TIMEOUT]\
		or (result == HTTPRequest.RESULT_SUCCESS and (code == 0 or code == 408 or code == 429 or code >= 500))
	var keep: bool = job.size() > 6 and bool(job[6])
	var tries: int = int(job[7]) if job.size() > 7 else 0
	if not transient or not is_inside_tree() or (tries >= RETRY_WAIT.size() and not keep):
		return false
	var again: Array = job.slice(0, 7)
	again.append(tries + 1)
	retries += 1
	var wait: float = RETRY_WAIT[tries] if tries < RETRY_WAIT.size() else RETRY_KEEP
	get_tree().create_timer(wait).timeout.connect( func() -> void :
		(_slow if slow else _queue).push_front(again)
		_pump())
	return true







var _hc_anim: Dictionary = {}
var _hc_sheets: Dictionary = {}

func _hc_sheet(path: String) -> Texture2D:
	if not _hc_sheets.has(path):
		_hc_sheets[path] = null
		_fetch(path, true, func(texture: Variant) -> void :
			_hc_sheets[path] = texture
			picture_ready.emit(path), false, false, true)
	return _hc_sheets[path]


func _hc_moving(path: String, now_ms: int = -1) -> Texture2D:
	var table: Variant = lobby.get("anim")
	if not (table is Dictionary) or not (table as Dictionary).has(path):
		return null
	var row: Variant = (table as Dictionary)[path]
	if not (row is Array) or (row as Array).size() < 6 or not ((row as Array)[5] is Array) or ((row as Array)[5] as Array).is_empty():
		return null
	var line: Array = row
	var seq: Array = line[5]
	var wide: float = float(line[2])
	var high: float = float(line[3])
	var cols: int = maxi(1, int(line[4]))
	if wide <= 0.0 or high <= 0.0:
		return null
	var sheet: Texture2D = _hc_sheet(str(line[0]))
	if sheet == null:
		return null
	var atlas: AtlasTexture = _hc_anim.get(path)
	if atlas == null:
		atlas = AtlasTexture.new()
		atlas.filter_clip = true
		_hc_anim[path] = atlas
	if atlas.atlas != sheet:
		atlas.atlas = sheet
	var now: int = now_ms if now_ms >= 0 else Time.get_ticks_msec()
	var cell: int = maxi(0, int(seq[int(float(now) * float(line[1]) / 1000.0) % seq.size()]))
	var row_at: int = int(float(cell) / float(cols))
	var region: = Rect2(float(cell - row_at * cols) * wide, float(row_at) * high, wide, high)
	if atlas.region != region:
		atlas.region = region
	return atlas













const LV_JSON: String = "lv:live.json"
const LV_EVERY_MS: int = 60000
const _LV_NONE: String = "lv-none"
const _LV_TABLES: Dictionary = {"items": "bag", "more": "bag", "presents": "bag", "limits": "bag", "skins": "bag", 
	"avatars": "lobby", "anim": "lobby", "ornate": "bagx", "fx": "bagx"}
var live_enabled: bool = true
var live_build: String = ""
var lv_root: String = ""
var live: Dictionary = {}
var _lv_sums: Dictionary = {}
var _lv_orig: Dictionary = {}
var _lv_into: Dictionary = {}
var _lv_rev: Dictionary = {}
var _lv_at: int = - LV_EVERY_MS - 1
var _lv_busy: bool = false

func _enter_tree() -> void :
	if not picture_ready.is_connected(_lv_heard):
		picture_ready.connect(_lv_heard)

func _lv_heard(path: String) -> void :
	match path:
		"l/index.json":
			load_live()
			if _lv_merge("lobby"):
				picture_ready.emit(path)
		"l/bag.json":
			if _lv_merge("bag"):
				picture_ready.emit(path)
		"l/bagx.json":
			if _lv_merge("bagx"):
				picture_ready.emit(path)

func _lv_base() -> String:
	if not lv_root.is_empty():
		return lv_root if lv_root.ends_with("/") else lv_root + "/"
	if base.is_empty():
		return ""
	return base.trim_suffix("/").get_base_dir() + "/lv/"


func _lv_full(rel: String) -> String:
	if rel == LV_JSON:
		var root: String = _lv_base()
		return "" if root.is_empty() else root + "live.json"
	if _lv_sums.is_empty() or not _lv_sums.has(rel):
		return ""
	return _lv_base() + str(live.get("rev", "")) + "/" + rel


func _lv_local(path: String, image: bool, done: Callable, audio: bool, font: bool, slow: bool, tag: String) -> bool:
	var full: String = _lv_full(path)
	if full.is_empty():
		return false
	var found: bool = FileAccess.file_exists(full)
	if found and image and not audio and not font and _spread():
		_later(FileAccess.get_file_as_bytes(full), done, slow, tag)
		return true
	done.call_deferred(_decode(FileAccess.get_file_as_bytes(full), image, audio, font) if found else null)
	return true


func load_live(force: bool = false) -> void :
	if not live_enabled or base.is_empty() or _lv_busy or ( not force and Time.get_ticks_msec() - _lv_at < LV_EVERY_MS):
		return
	_lv_busy = true
	_lv_at = Time.get_ticks_msec()
	_fetch(LV_JSON, false, func(value: Variant) -> void :
		_lv_busy = false
		apply_live(value), false, false, true, LV_JSON)

func _lv_build() -> String:
	if live_build.is_empty():
		var script: Variant = load("res://ui/settings.gd")
		live_build = str((script as GDScript).get_script_constant_map().get("BUILD", "dev")) if script is GDScript else "dev"
	return live_build


func apply_live(doc: Variant) -> bool:
	if not live_enabled or not (doc is Dictionary):
		return false
	var next: Dictionary = doc
	var rev: String = str(next.get("rev", ""))
	if int(next.get("v", 0)) != 1 or not (next.get("files") is Array) or rev.length() != 12 or not rev.is_valid_hex_number():
		return false
	var tag: String = str(next.get("pack", ""))
	if _lv_build() != "dev" and not tag.is_empty() and tag != _lv_build():
		return false
	if rev == str(live.get("rev", "")):
		return false
	var sums: Dictionary = {}
	var given: Dictionary = next.get("sums") if next.get("sums") is Dictionary else {}
	for item: Variant in next.files:
		var rel: String = str(item)
		if rel.begins_with("l/") and not rel.contains("..") and not rel.contains("\\"):
			sums[rel] = str(given.get(rel, rev))
	var old_sums: Dictionary = _lv_sums
	var old_anim: Dictionary = live.get("anim") if live.get("anim") is Dictionary else {}
	var new_anim: Dictionary = next.get("anim") if next.get("anim") is Dictionary else {}
	live = next
	_lv_sums = sums
	var touched: Dictionary = {}
	for rel: String in old_sums:
		if str(sums.get(rel, "")) != str(old_sums[rel]):
			touched[rel] = true
	for rel: String in sums:
		if str(old_sums.get(rel, "")) != str(sums[rel]):
			touched[rel] = true
	for still: Variant in old_anim:
		if str(new_anim.get(still, null)) != str(old_anim[still]):
			_hc_anim.erase(str(still))
	for still: Variant in new_anim:
		if str(old_anim.get(still, null)) != str(new_anim[still]):
			_hc_anim.erase(str(still))
	for rel: String in touched:
		_lv_forget(rel)
	for table: String in ["lobby", "bag", "bagx"]:
		if _lv_merge(table):
			picture_ready.emit({"lobby": "l/index.json", "bag": "l/bag.json", "bagx": "l/bagx.json"}[table])
	return true


func _lv_forget(rel: String) -> void :
	_icons.erase(rel)
	_icon_done.erase(rel)
	_icon_slow.erase(rel)
	for cache: Dictionary in [_pictures, _hc_sheets]:
		if cache.get(rel) is Texture2D:
			_fetch(rel, true, func(texture: Variant) -> void :
				if texture is Texture2D:
					cache[rel] = texture
					picture_ready.emit(rel), false, false, true)
		else:
			cache.erase(rel)

func _lv_table(table: String) -> Dictionary:
	match table:
		"bag":
			return bag
		"bagx":
			return bagx
		"lobby":
			return lobby
	return {}


func _lv_merge(table: String) -> bool:
	var into: Dictionary = _lv_table(table)
	var rev: String = str(live.get("rev", ""))
	if into.is_empty() or (rev.is_empty() and not _lv_into.has(table)):
		return false
	var same: bool = _lv_into.has(table) and is_same(_lv_into[table], into)
	if same and str(_lv_rev.get(table, "")) == rev:
		return false
	var changed: bool = false
	if same:
		var saved_all: Dictionary = _lv_orig.get(table, {})
		for sub: String in saved_all:
			var saved: Variant = saved_all[sub]
			if sub == "skins" or not (saved is Dictionary):
				if str(saved) == _LV_NONE:
					into.erase(sub)
				else:
					into[sub] = saved
			elif into.get(sub) is Dictionary:
				var part: Dictionary = into[sub]
				for key: Variant in saved:
					if str(saved[key]) == _LV_NONE:
						part.erase(key)
					else:
						part[key] = saved[key]
			changed = true
	_lv_orig[table] = {}
	_lv_into[table] = into
	_lv_rev[table] = rev
	for sub: String in _LV_TABLES:
		if _LV_TABLES[sub] != table or not live.has(sub):
			continue
		var change: Variant = live[sub]
		if sub == "skins":
			if change is Array:
				_lv_orig[table][sub] = into[sub] if into.has(sub) else _LV_NONE
				into[sub] = (change as Array).duplicate()
				changed = true
			continue
		if not (change is Dictionary) or (change as Dictionary).is_empty():
			continue
		if not (into.get(sub) is Dictionary):
			_lv_orig[table][sub] = into[sub] if into.has(sub) else _LV_NONE
			into[sub] = {}
			changed = true
		var part: Dictionary = into[sub]
		var saved: Dictionary = {}
		for key: Variant in change:
			saved[key] = part[key] if part.has(key) else _LV_NONE
			if change[key] == null:
				part.erase(key)
			else:
				part[key] = change[key]
			changed = true
		if not (_lv_orig[table] as Dictionary).has(sub):
			_lv_orig[table][sub] = saved
	return changed





const AVC_ROOT: String = "http://127.0.0.1:8080/godot/a/"
const AVC_DIR: String = "user://avc/"
const AVC_CAP: int = 600 << 20
const AVC_FLUSH: int = 40
var _avc_on: bool = false
var _avc_index: Dictionary = {}
var _avc_total: int = 0
var _avc_dirty: int = 0
var avc_stats: Dictionary = {"hit": 0, "put": 0, "full": 0}
var map_size_stats: Dictionary = {"ok": 0, "bad": 0}
var _map_src: Dictionary = {}



static func avc_plan(old: Variant, stamps: Array, cap: int = AVC_CAP) -> Dictionary:
	var keep: Dictionary = {}
	var drop: Array = []
	var total: int = 0
	if not (old is Dictionary):
		return {"keep": {}, "drop": [], "wipe": true, "total": 0}
	var live: Dictionary = {}
	for stamp: Variant in stamps:
		live[str(stamp)] = true
	for stamp: Variant in (old as Dictionary):
		var key: String = str(stamp)
		var size: int = int((old as Dictionary)[stamp]) if (old as Dictionary)[stamp] is float or (old as Dictionary)[stamp] is int else -1
		if size < 0 or not key.is_valid_filename() or key.is_empty():
			return {"keep": {}, "drop": [], "wipe": true, "total": 0}
		if live.has(key):
			keep[key] = size
			total += size
		else:
			drop.append(key)
	if total > cap:
		return {"keep": {}, "drop": [], "wipe": true, "total": 0}
	return {"keep": keep, "drop": drop, "wipe": false, "total": total}


static func avc_file(stamps: Dictionary, plain: Dictionary, path: String) -> String:
	if path.is_empty() or path.begins_with("/") or ".." in path.split("/") or "\\" in path:
		return ""
	var group: String = bucket_of(path)
	var stamp: String = str(stamps.get(group, ""))
	if stamp.is_empty() or plain.has(group) or not stamp.is_valid_filename():
		return ""
	return AVC_DIR + stamp + "/" + path

func _avc_open() -> void :
	var raw: Variant = null
	if FileAccess.file_exists(AVC_DIR + "index.json"):
		raw = SafeJson.parse(FileAccess.get_file_as_string(AVC_DIR + "index.json"))
	elif not DirAccess.dir_exists_absolute(AVC_DIR):
		raw = {}
	var plan: Dictionary = avc_plan(raw, vmap.values())
	if bool(plan.wipe):
		_avc_rmtree(AVC_DIR)
	for stamp: String in plan.drop:
		_avc_rmtree(AVC_DIR + stamp + "/")

	var dir: DirAccess = DirAccess.open(AVC_DIR)
	if dir != null:
		for name: String in dir.get_directories():
			if not (plan.keep as Dictionary).has(name):
				_avc_rmtree(AVC_DIR + name + "/")
	_avc_index = plan.keep
	_avc_total = int(plan.total)
	DirAccess.make_dir_recursive_absolute(AVC_DIR)
	_avc_dirty = 1
	_avc_flush()

func _avc_rmtree(path: String) -> void :
	var dir: DirAccess = DirAccess.open(path)
	if dir == null:
		return
	for name: String in dir.get_files():
		DirAccess.remove_absolute(path.path_join(name))
	for name: String in dir.get_directories():
		_avc_rmtree(path.path_join(name) + "/")
	DirAccess.remove_absolute(path)

func _avc_hit(path: String, image: bool, done: Callable, audio: bool, font: bool, slow: bool, tag: String) -> bool:
	if not _lv_full(path).is_empty():
		return false
	var file: String = avc_file(vmap, _vplain, path)
	if file.is_empty() or not FileAccess.file_exists(file):
		return false
	var bytes: PackedByteArray = FileAccess.get_file_as_bytes(file)
	if bytes.is_empty():
		return false
	bytes = _k3_from_avc(path, bytes, image and not audio and not font)
	if bytes.is_empty():
		return false
	avc_stats.hit += 1
	if path.begins_with("m/"):
		_map_src[path] = "avc %dB" % bytes.size()
	_vseen[bucket_of(path)] = true
	var got: Callable = done
	if image and not audio and not font:
		got = func(value: Variant) -> void :
			if value == null:
				_avc_drop(path, file, bytes.size())
			done.call(value)
	if image and not audio and not font and _spread():
		_later(bytes, got, slow, tag)
	else:
		got.call_deferred(_parse(path, bytes, image, audio, font))
	return true

func _avc_drop(path: String, file: String, size: int) -> void :
	DirAccess.remove_absolute(file)
	var stamp: String = str(vmap.get(bucket_of(path), ""))
	if _avc_index.has(stamp):
		_avc_index[stamp] = maxi(0, int(_avc_index[stamp]) - size)
	_avc_total = maxi(0, _avc_total - size)
	_avc_dirty += 1
	heal_stats.avc_bad += 1

func _avc_put(path: String, body: PackedByteArray) -> void :
	var file: String = avc_file(vmap, _vplain, path)
	if file.is_empty() or body.is_empty():
		return
	if _avc_total + body.size() > AVC_CAP:
		avc_stats.full += 1
		return
	DirAccess.make_dir_recursive_absolute(file.get_base_dir())
	var part: String = file + ".part"
	var out: FileAccess = FileAccess.open(part, FileAccess.WRITE)
	if out == null:
		return
	var wrote: bool = out.store_buffer(body) and out.get_length() == body.size()
	out.close()
	if not wrote:
		heal_stats.avc_short += 1
		DirAccess.remove_absolute(part)
		return
	if DirAccess.rename_absolute(part, file) != OK:
		DirAccess.remove_absolute(part)
		return
	var stamp: String = str(vmap.get(bucket_of(path), ""))
	_avc_index[stamp] = int(_avc_index.get(stamp, 0)) + body.size()
	_avc_total += body.size()
	avc_stats.put += 1
	_avc_dirty += 1
	if _avc_dirty >= AVC_FLUSH:
		_avc_flush()

func _avc_flush() -> void :
	if _avc_dirty <= 0:
		return
	var out: FileAccess = FileAccess.open(AVC_DIR + "index.json.part", FileAccess.WRITE)
	if out == null:
		return
	out.store_string(JSON.stringify(_avc_index))
	out.close()
	if DirAccess.rename_absolute(AVC_DIR + "index.json.part", AVC_DIR + "index.json") == OK:
		_avc_dirty = 0


func quit_flush() -> void :
	if _avc_on:
		_avc_flush()

func _notification(what: int) -> void :
	if _avc_on and what in [NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_PREDELETE]:
		_avc_flush()



func _k3_setup() -> void :
	var native_app: bool = OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("pc_app") or ( not OS.has_feature("web") and not OS.has_feature("editor"))
	if _veil_key.is_empty() and not local and native_app:
		_load_veil(VEIL_JSON, true)
		_load_veil_ext()
	AppSession.on_login = _k3_kick

func k3_url() -> String:
	return base.trim_suffix("a/") + "ik3" if base.begins_with("http") and base.ends_with("/a/") else ""

static func k3_pre(path: String) -> bool:
	for head: String in K3_PRE:
		if path.begins_with(head):
			return true
	return false

static func k3_tag_of(key: PackedByteArray) -> PackedByteArray:
	var h: HashingContext = HashingContext.new()
	h.start(HashingContext.HASH_SHA256)
	h.update(key)
	h.update("pk1img/v1".to_utf8_buffer())
	return h.finish().slice(0, 4)


func k3_take(doc: Variant) -> bool:
	if not (doc is Dictionary) or int((doc as Dictionary).get("v", 0)) != 1:
		return false
	var s: String = str((doc as Dictionary).get("s", ""))
	var t: String = str((doc as Dictionary).get("t", ""))
	var m: String = str((doc as Dictionary).get("m", ""))
	if RegEx.create_from_string("^[a-z0-9]{1,8}$").search(s) == null or s == "bin" or "." + s + ".bin" == _veil_ext\
	or RegEx.create_from_string("^[0-9a-f]{8}$").search(t) == null or RegEx.create_from_string("^[0-9a-f]{64}$").search(m) == null:
		return false
	var pad: PackedByteArray = ("lcbb-img3/" + s + "/" + t).sha256_buffer()
	var mixed: PackedByteArray = m.hex_decode()
	var key: PackedByteArray = PackedByteArray()
	key.resize(32)
	for i: int in 32:
		key[i] = mixed[i] ^ pad[i]
	if k3_tag_of(key) != t.hex_decode():
		return false
	_k3_key = key
	_k3_tag = t.hex_decode()
	_k3_ext = "." + s + ".bin"
	return true


func _k3_kick() -> void :
	if local or k3_url().is_empty() or not ClassDB.class_exists(&"AESContext") or not is_inside_tree():
		return
	_k3_gen += 1
	_k3_tries = 0
	if _k3_key.is_empty():
		_k3_until = Time.get_ticks_msec() + K3_PARK_MS
		get_tree().create_timer(K3_PARK_MS / 1000.0 + 0.05).timeout.connect(_k3_timer.bind(_k3_gen))
	_k3_ask()

func _k3_timer(gen: int) -> void :
	if gen == _k3_gen:
		_k3_release()

func _k3_ask() -> void :
	if _k3_busy or not is_inside_tree():
		return
	if _k3_http == null:
		_k3_http = HTTPRequest.new()
		_k3_http.timeout = 10.0
		_k3_http.request_completed.connect(_k3_done)
		add_child(_k3_http)
	var where: String = k3_url()
	_k3_busy = _k3_http.request(where, AppSession.headers(where)) == OK
	if not _k3_busy:
		_k3_fail()

func _k3_done(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_k3_busy = false
	if result == HTTPRequest.RESULT_SUCCESS and code == 200 and k3_take(SafeJson.parse(body.get_string_from_utf8())):
		k3_stats.key += 1
		_k3_release()
		return
	_k3_fail()

func _k3_fail() -> void :
	k3_stats.fail += 1
	_k3_release()
	if not _k3_key.is_empty() or _k3_tries >= K3_RETRY.size() or not is_inside_tree():
		return
	get_tree().create_timer(float(K3_RETRY[_k3_tries])).timeout.connect(_k3_retry.bind(_k3_gen))
	_k3_tries += 1

func _k3_retry(gen: int) -> void :
	if gen == _k3_gen and _k3_key.is_empty():
		_k3_ask()


func _k3_release() -> void :
	_k3_until = 0
	if _k3_park.is_empty():
		return
	var parked: Array = _k3_park
	_k3_park = []
	for i: int in range(parked.size() - 1, -1, -1):
		(_slow if bool(parked[i][1]) else _queue).push_front(parked[i][0])
	_pump()

func _k3_wants(job: Array) -> bool:
	var path: String = str(job[0])
	return bool(job[1]) and not bool(job[3]) and not bool(job[4]) and path.ends_with(".webp") and not k3_pre(path) and _lv_full(path).is_empty()


func _k3_hold(job: Array, slow: bool) -> bool:
	if _k3_until <= 0 or not _k3_key.is_empty() or Time.get_ticks_msec() >= _k3_until or not _k3_wants(job):
		return false
	_k3_park.append([job, slow])
	k3_stats.park += 1
	return true


func _k3_route(job: Array, where: Array, http: HTTPRequest) -> void :
	http.set_meta("vgen", 0)
	var path: String = str(job[0])
	if _k3_key.is_empty() or not _k3_wants(job) or _k3_off.has(path) or _k3_off.has(bucket_of(path)):
		return
	var address: String = str(where[0])
	if bool(http.get_meta("veiled", false)):
		address = address.trim_suffix(_veil_ext if address.ends_with(_veil_ext) else ".bin") + ".webp"
	if not address.ends_with(".webp"):
		return
	http.set_meta("veiled", false)
	http.set_meta("vgen", 3)
	http.set_meta("vkey", _k3_key)
	http.set_meta("vtag", _k3_tag)
	where[0] = address.trim_suffix(".webp") + _k3_ext


func _k3_recv(job: Array, http: HTTPRequest, result: int, code: int, slow: bool, body: PackedByteArray) -> bool:
	var path: String = str(job[0])
	var ok: bool = result == HTTPRequest.RESULT_SUCCESS and code == 200
	if int(http.get_meta("vgen", 0)) != 3:
		if ok and _k3_off.has(path):
			_k3_off[bucket_of(path)] = true
		return false
	var tag: PackedByteArray = http.get_meta("vtag", PackedByteArray())
	if ok and body.size() >= VEIL_TAIL and body.slice(body.size() - 4) == tag:
		k3_stats.ok += 1
		return false
	if ok:
		if tag == _k3_tag:
			_k3_key = PackedByteArray()
			_k3_tag = PackedByteArray()
			k3_stats.drop += 1
	elif result == HTTPRequest.RESULT_SUCCESS and code >= 400 and code < 500 and code != 408 and code != 429:
		_k3_off[path] = true
	else:
		return false
	k3_stats.back += 1
	(_slow if slow else _queue).push_front(job)
	return true


func _k3_unveil(body: PackedByteArray, key: PackedByteArray) -> PackedByteArray:
	var n: int = body.size() - VEIL_TAIL
	if n < 0 or key.size() != 32:
		return PackedByteArray()
	var k: int = mini(VEIL_HEAD, n - n % 16)
	var head: PackedByteArray = PackedByteArray()
	if k > 0:
		var aes: AESContext = AESContext.new()
		aes.start(AESContext.MODE_CBC_DECRYPT, key, body.slice(n, n + 16))
		head = aes.update(body.slice(0, k))
		aes.finish()
	var buffer: StreamPeerBuffer = StreamPeerBuffer.new()
	buffer.data_array = body
	buffer.put_data(head)
	var out: PackedByteArray = buffer.data_array
	buffer.clear()
	out.resize(n)
	return out


func _k3_from_avc(path: String, bytes: PackedByteArray, image: bool) -> PackedByteArray:
	if not image or not path.ends_with(".webp") or bytes.size() < 4 or bytes.slice(0, 4) == "RIFF".to_ascii_buffer():
		return bytes
	if _k3_key.is_empty() or bytes.size() < VEIL_TAIL or bytes.slice(bytes.size() - 4) != _k3_tag:
		return PackedByteArray()
	return _k3_unveil(bytes, _k3_key)










const DL_JSON: String = "pcdl.json"
const DL_EVERY_MS: int = 60000
const DL_MAX_MIRRORS: int = 8
const DL_RETRY_MS: int = 15000
var dl_force: bool = false
var dl_stats: Dictionary = {"v": "pcdl1", "cfg": "", "to": "", "n": 0, "back": 0, "miss": 0, "bad": 0, "rest": 0, "why": ""}
var _dl_http: HTTPRequest = null
var _dl_busy: bool = false
var _dl_root: String = ""
var _dl_mirror: String = ""
var _dl_av: bool = false
var _dl_a: bool = false
var _dl_head_ms: int = 8000
var _dl_strikes: int = 3
var _dl_rest_ms: int = 120000
var _dl_row: int = 0
var _dl_until: int = 0
var _dl_at: int = - DL_EVERY_MS - 1
var _dl_skip: Dictionary = {}
static var _dl_rx: RegEx = null

func _dl_setup() -> void :
	if _dl_http != null or local or OS.has_feature("web") or not base.ends_with("/a/"):
		return
	var native_app: bool = OS.has_feature("pc_app") or OS.has_feature("android") or OS.has_feature("ios") or not OS.has_feature("editor")
	if not (dl_force or native_app):
		return
	_dl_root = base.substr(0, base.length() - 2)
	_dl_http = HTTPRequest.new()
	_dl_http.timeout = 15.0
	_dl_http.request_completed.connect(_dl_got)
	add_child(_dl_http)
	_dl_tick(Time.get_ticks_msec())


func _dl_tick(now: int) -> void :
	if _dl_http == null or _dl_busy or now - _dl_at < DL_EVERY_MS:
		return
	_dl_at = now
	var u: String = _dl_root + DL_JSON + "?t=%d" % int(Time.get_unix_time_from_system() / 60.0)
	_dl_busy = _dl_http.request(u, AppSession.headers(u)) == OK
	if not _dl_busy:
		_dl_set(null, "không xin được")

func _dl_got(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_dl_busy = false
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_dl_set(null, "đọc %d/%d" % [result, code])
		_dl_at = Time.get_ticks_msec() - DL_EVERY_MS + DL_RETRY_MS
		return
	_dl_set(SafeJson.parse(body.get_string_from_utf8()), "hỏng")

static func _dl_host_ok(m: String) -> bool:
	if _dl_rx == null:
		_dl_rx = RegEx.create_from_string("^(https://[a-z0-9.-]+(:[0-9]{1,5})?|http://(127\\.0\\.0\\.1|localhost|10\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}|192\\.168\\.[0-9]{1,3}\\.[0-9]{1,3}|172\\.(1[6-9]|2[0-9]|3[0-1])\\.[0-9]{1,3}\\.[0-9]{1,3})(:[0-9]{1,5})?)$")
	return _dl_rx.search(m) != null

static func _dl_num(v: Variant, fallback: int, lo: int, hi: int) -> int:
	return clampi(int(v), lo, hi) if (v is int or v is float) else fallback


func _dl_set(doc: Variant, why: String) -> void :
	var d: Dictionary = doc if doc is Dictionary else {}
	var list: Array = []
	if _dl_num(d.get("v"), 0, 0, 99) == 1 and d.get("on") is bool and bool(d.get("on")) and d.get("mirrors") is Array:
		for m: Variant in (d.get("mirrors") as Array):
			var h: String = str(m).trim_suffix("/") if m is String else ""
			if not h.is_empty() and _dl_host_ok(h) and not list.has(h) and list.size() < DL_MAX_MIRRORS:
				list.append(h)
	var was: String = _dl_mirror
	if list.is_empty():
		_dl_mirror = ""
		_dl_av = false
		_dl_a = false
		dl_stats.cfg = ("tắt" if doc is Dictionary else why)
	else:
		if not list.has(_dl_mirror):
			_dl_mirror = str(list[randi() % list.size()])
		_dl_av = not d.has("av") or (d.get("av") is bool and bool(d.get("av")))
		_dl_a = d.get("a") is bool and bool(d.get("a"))
		_dl_head_ms = _dl_num(d.get("head_ms"), 8000, 1000, 60000)
		_dl_strikes = _dl_num(d.get("strikes"), 3, 1, 100)
		_dl_rest_ms = _dl_num(d.get("rest_ms"), 120000, 1000, 3600000)
		dl_stats.cfg = "bật av=%s a=%s" % [_dl_av, _dl_a]
	dl_stats.to = _dl_mirror
	if was != _dl_mirror:
		_dl_row = 0
		_dl_until = 0
		_dl_skip.clear()
		print("[pcdl1] gương tải phụ: %s (%s)" % [_dl_mirror if not _dl_mirror.is_empty() else "TẮT", dl_stats.cfg])


func _dl_route(path: String, address: String, http: HTTPRequest) -> String:
	http.set_meta("mir", false)
	if _dl_mirror.is_empty() or _dl_root.is_empty() or not address.begins_with(_dl_root):
		return address
	var rest: String = address.substr(_dl_root.length())
	if not ((_dl_av and rest.begins_with("av/")) or (_dl_a and rest.begins_with("a/"))):
		return address
	if _dl_skip.erase(path):
		return address
	var now: int = Time.get_ticks_msec()
	if now < _dl_until:
		return address
	http.set_meta("mir", true)
	http.set_meta("mir_t", now)
	dl_stats.n += 1
	return _dl_mirror + "/godot/" + rest


func _dl_back(job: Array, http: HTTPRequest, result: int, code: int, slow: bool) -> bool:
	if not bool(http.get_meta("mir", false)):
		return false
	http.set_meta("mir", false)
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		_dl_row = 0
		return false
	var miss: bool = result == HTTPRequest.RESULT_SUCCESS and code == 404
	_dl_fail(str(job[0]), ("mã %d" % code) if result == HTTPRequest.RESULT_SUCCESS else ("kết quả %d" % result), miss)
	(_slow if slow else _queue).push_front(job)
	return true

func _dl_fail(path: String, why: String, miss: bool) -> void :
	_dl_skip[path] = true
	dl_stats.back += 1
	if miss:
		dl_stats.miss += 1
		return
	dl_stats.bad += 1
	dl_stats.why = why
	_dl_row += 1
	var now: int = Time.get_ticks_msec()
	if _dl_row < _dl_strikes or now < _dl_until:
		return
	_dl_row = 0
	_dl_until = now + _dl_rest_ms
	dl_stats.rest += 1
	print("[pcdl1] gương lỗi %d lần liền, nghỉ %d s: %s" % [_dl_strikes, _dl_rest_ms / 1000, why])


func _dl_slow(http: HTTPRequest, now: int, n: int, gap: bool) -> bool:
	if not bool(http.get_meta("mir", false)) or n > 0 or http.get_http_client_status() == HTTPClient.STATUS_BODY:
		return false
	if gap:
		http.set_meta("mir_t", now)
		return false
	if now - int(http.get_meta("mir_t", now)) < _dl_head_ms:
		return false
	var job: Array = http.get_meta("job")
	var slow: bool = bool(http.get_meta("slow", false))
	http.set_meta("mir", false)
	http.cancel_request()
	http.remove_meta("job")
	_dl_fail(str(job[0]), "quá %d s chưa có đầu đáp" % (_dl_head_ms / 1000), false)
	(_slow if slow else _queue).push_front(job)
	_cut_rest(http)
	return true
