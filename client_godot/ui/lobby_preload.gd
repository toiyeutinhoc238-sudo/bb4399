extends Node
const AppSession = preload("res://net/app_session.gd")


















const Client = preload("../game_client.gd")
const AssetPack = preload("../battle/asset_pack.gd")
const BattleWarm = preload("../battle_warm.gd")
const TankPortrait = preload("tank_portrait.gd")
const GarageModel = preload("garage_model.gd")

signal changed

const STATUS: String = "Đang tải..."
const STARTUP: Array[String] = ["hud", "lobby", "sounds", "index", "fx"]
const DATA: Array[String] = ["l/garage.json", "l/events.json", "l/eventsx.json", "l/fair.json", "l/quest.json", "l/mapart.json", "e/bundle.json"]
const HALL: Array[String] = ["bg", "plat", "pvp", "pve", "league", "territory", "rank", "guild", "shop"]
const DATA_SHARE: float = 40.0
const CAP_MS: int = 30000
const OWN_SHARE: float = 0.3
const OWN_SOFT_MS: int = 8000
const HALO_SOFT_MS: int = 6000
const TANK_GRACE: float = 5.0
const THEME_WAIT: Array[float] = [1.0, 2.0, 4.0]
const LATER: Array[String] = ["load_bag", "load_bagx", "load_garagex", "load_rank"]
const LATER_GAP: float = 0.5
const TICK: float = 0.1
const STEP_MAX: float = 0.5
const PK2_SHARE: float = 0.4

var client: Client
var pack: AssetPack
var lobby: Control
var pk2: Node

var phase: String = "idle"
var percent: float = 0.0
var files: int = 0
var settled: int = 0
var _seen: String = ""
var _begun: int = 0
var _waited: float = 0.0
var _tick: float = 0.0
var _theme_ok: bool = false
var _theme_try: int = 0
var _theme_http: HTTPRequest
var _done_paths: Dictionary = {}
var _fresh: Dictionary = {}
var _later: Array = []
var _later_wait: float = 0.0
var _hooked: bool = false
var _own: Array = []
var _own_asked: bool = false

func _ready() -> void :
	_hook()

func _hook() -> void :
	if _hooked or pack == null:
		return
	_hooked = true
	pack.picture_ready.connect( func(path: String) -> void :
		_done_paths[path] = true
		_fresh[path] = true)


func sync() -> bool:
	_hook()
	if client == null or pack == null:
		return false
	var state: String = client.state
	if state != _seen:
		var before: String = _seen
		_seen = state
		if state in ["login", "auth", "servers", "connecting", "characters"]:
			if phase == "wait":
				_stop()
			phase = "idle"
			_later.clear()
		elif state == "lobby" and phase == "idle" and before in ["connecting", "characters"] and not pack.base.is_empty():
			_begin()
		elif state != "lobby" and phase == "wait":
			_release("rời sảnh")
	if not holding() and not _pk2_ok() and state in ["lobby", "hall", "room"]:
		percent = 99.0 * _pk2_part()
		return true
	return holding()


func _pk2_ok() -> bool:
	return pk2 == null or bool(pk2.call("is_done"))

func _pk2_part() -> float:
	return 1.0 if pk2 == null else float(pk2.call("fraction"))

func _pk2_share() -> float:
	return PK2_SHARE if pk2 != null and bool(pk2.get("active")) else 0.0

func holding() -> bool:
	return phase == "wait"

func _begin() -> void :
	phase = "wait"
	percent = 0.0
	settled = 0
	files = 0
	_begun = Time.get_ticks_msec()
	_waited = 0.0
	_tick = TICK
	_fresh.clear()
	_own = []
	_own_asked = false
	_theme_try = 0
	_theme_ok = lobby == null or bool(lobby.get("_theme_asked")) or not (OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("pc_app") or ( not OS.has_feature("editor") and DisplayServer.get_name() != "headless"))
	if not _theme_ok:
		lobby.set("_theme_asked", true)
		_ask_theme()
	pack.load_garage()
	pack.load_events()
	pack.load_eventsx()
	pack.load_fair()
	pack.load_quest()
	pack.load_mapart()
	pack.load_bundle()

func _process(delta: float) -> void :
	if phase == "wait":
		_waited += minf(delta, STEP_MAX)
		_tick += delta
		if _tick >= TICK:
			_tick = 0.0
			_measure()
	elif phase != "wait" and not _pk2_ok() and client != null and client.state in ["lobby", "hall", "room"]:
		percent = 99.0 * _pk2_part()
	elif phase == "done" and not _later.is_empty() and client != null and client.state != "battle":
		_later_wait -= delta
		if _later_wait <= 0.0:
			_later_wait = LATER_GAP
			pack.call(str(_later.pop_front()))

func _measure() -> void :
	var data: Array = []
	for key: String in STARTUP:
		data.append(pack.startup.has(key))
	data.append(_theme_ok)
	for path: String in DATA:
		data.append(_data_done(path))
	var art: Array = _pictures()
	_ask_own()
	var own: float = pack.warm_fraction(_own) if _own_asked else 0.0
	var have: int = data.count(true) + art.count(true)
	var all: int = data.size() + art.size()
	var ratio: float = DATA_SHARE * data.count(true) / data.size() + (100.0 - DATA_SHARE) * art.count(true) / art.size()
	var own_ok: bool = not _own_asked or own >= 1.0 or int(_waited * 1000.0) >= OWN_SOFT_MS
	var shown: float = 100.0 if have == all and own_ok else (ratio * (1.0 - OWN_SHARE) + 100.0 * OWN_SHARE * own) * 0.99
	var pk_ok: bool = _pk2_ok()
	var share: float = _pk2_share()
	if share > 0.0 and not (shown >= 100.0 and pk_ok):
		shown = minf(99.0, shown * (1.0 - share) + 100.0 * share * _pk2_part())
	percent = shown
	settled = have
	files = all
	var elapsed: int = int(_waited * 1000.0)
	if not pk_ok:
		pass
	elif have == all and own_ok:
		_release("đủ")
	elif elapsed >= HALO_SOFT_MS and own_ok and data.count(false) == 0 and art.slice(0, art.size() - 2).count(false) == 0:
		_release("còn vòng sáng")
	elif elapsed >= CAP_MS and pack.startup.has("lobby") and pack.startup.has("index"):
		_release("quá %d s" % int(CAP_MS / 1000.0))


func _ask_own() -> void :
	if _own_asked or pack.state != "ready" or not pack.startup.has("fx"):
		return
	var tank: Dictionary = client.current_tank()
	if tank.is_empty():
		return
	_own_asked = true
	var look: Dictionary = {"tank": int(tank.get("m_tpltId", 0)), "external": int(tank.get("m_externalId", 0)), "level": int(tank.get("m_level", 0)), "halo": int(tank.get("m_haloId", 0))}
	_own = pack.warm_battle([look]) + BattleWarm.jobs(pack, client.battle)
	pack.warm_first(_own)


func _data_done(path: String) -> bool:
	var field: String = path.get_file().get_basename()
	var value: Variant = pack.get(field)
	return (value is Dictionary and not value.is_empty()) or _fresh.has(path)


func _pictures() -> Array:
	var out: Array = []
	var known: bool = pack.startup.has("lobby")
	var halls: Dictionary = pack.lobby.get("halls", {})
	var theme: String = str(lobby.get("_theme")) if lobby != null else ""
	var hall: String = theme if halls.has(theme) else "native"
	var ready_hall: bool = known and _theme_ok
	for name: String in HALL:
		if not ready_hall:
			out.append(false)
		elif not halls.has(hall):
			out.append(true)
		else:
			out.append(_picture_done("l/hall/%s/%s.webp" % [hall, name]))

	var avatar: String = str(pack.lobby.get("avatars", {}).get(str(int(client.character.get("avatarId", 0))), ""))
	out.append(known and (avatar.is_empty() or _picture_done("l/h/%s.webp" % avatar)))
	out.append_array(_tank())
	return out


func _tank() -> Array:
	var tank: Dictionary = client.current_tank()
	if tank.is_empty():
		var gone: bool = _waited >= TANK_GRACE
		return [gone, gone, gone]
	if pack.state == "failed":
		return [true, true, true]
	if pack.state != "ready" or not pack.startup.has("fx") or not _data_done("l/garage.json"):
		return [false, false, false]
	var level: int = maxi(1, int(tank.get("m_level", 1)))
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(tank.get("m_tpltId", 0)), level, tank)
	var face: String = GarageModel.face(pack.garage, ext)
	if face.is_empty():
		var external: String = pack.art_external(str(int(tank.get("m_externalId", 0))), int(tank.get("m_tpltId", 0)))
		pack.external_art(external)
		return [pack.art_settled(external), true, true]
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(tank.get("m_haloId", 0)), level)
	var keys: Array = pack.halo_ui(item) if item > 0 else []
	var halo: Array = [true, true]
	if keys.size() >= 2:
		halo = [_effect_done(str(keys[0])), _effect_done(str(keys[1]))]
	var film: Array = TankPortrait.movie(pack.garage, face)
	var body: bool
	if not film.is_empty() and not pack.effect_failed(str(film[0])):
		body = _effect_done(str(film[0]))
	else:
		body = _picture_done("l/t/%s.webp" % face)
	return [body, halo[0], halo[1]]

func _picture_done(path: String) -> bool:
	return pack.picture(path) != null or _done_paths.has(path)

func _effect_done(key: String) -> bool:
	return not pack.effect(key).is_empty() or pack.effect_failed(key)


func _ask_theme() -> void :
	_theme_http = HTTPRequest.new()
	_theme_http.timeout = 10
	_theme_http.accept_gzip = false
	add_child(_theme_http)
	var http: HTTPRequest = _theme_http
	http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		http.queue_free()
		if _theme_http == http:
			_theme_http = null
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			var found: RegExMatch = RegEx.create_from_string("<hall[^>]*\\stheme=\"([a-z0-9_]*)\"").search(body.get_string_from_utf8())
			if lobby != null:
				lobby.set("_theme", found.get_string(1) if found != null else "")
			_theme_ok = true
		elif result == HTTPRequest.RESULT_SUCCESS and code > 0 and code < 500 and code != 408 and code != 429:
			_theme_ok = true
		else:
			_theme_again())
	var url: String = client.config.origin + "/hall-theme.xml"
	if http.request(url, AppSession.headers(url)) != OK:
		http.queue_free()
		_theme_http = null
		_theme_again()

func _theme_again() -> void :
	if phase != "wait" or _theme_try >= THEME_WAIT.size() or not is_inside_tree():
		_theme_ok = true
		return
	var wait: float = THEME_WAIT[_theme_try]
	_theme_try += 1
	get_tree().create_timer(wait).timeout.connect( func() -> void :
		if phase == "wait" and not _theme_ok:
			_ask_theme())

func _stop() -> void :
	if _theme_http != null:
		_theme_http.cancel_request()
		_theme_http.queue_free()
		_theme_http = null

func _release(why: String) -> void :
	if phase != "wait":
		return
	phase = "done"
	_stop()
	_theme_ok = true
	print("[BG2] vào sảnh (%s): %d/%d tệp, %d ms, thử lại %d" % [why, settled, files, Time.get_ticks_msec() - _begun, int(pack.retries)])
	_later = []
	_later.append_array(LATER)
	_later_wait = LATER_GAP
	emit_signal.call_deferred("changed")
