extends RefCounted















const Settings = preload("../settings.gd")


const SETTINGS_READS: Array[String] = ["tc_vibrate"]

const CD_SLOTS: Array[int] = [3, 10, 1, 2, 4, 13]
const CD_MIN: float = 1.5

const BUZZ: Dictionary = {"kill": [80, 1.0], "dead": [140, 0.9], "hit": [30, 0.55], "ready": [18, 0.35]}
const ORDER: Array[String] = ["kill", "dead", "hit", "ready"]
const HIT_GAP: float = 0.4
const ANY_GAP: float = 0.1
const RESUME_GAP_MS: int = 3000
const PING_LATE_MS: int = 1500
const IDLE_STALL: float = 12.0
const NORMAL_PING: int = 400
const SHOW_MAX: int = 9999

var buzz: Callable
var clock: Callable
var fired: Array = []
var resumed: int = 0
var _last_ms: int = 0
var _begun: int = -1
var _armed: bool = false
var _hp: int = -1
var _dead: bool = false
var _kill_top: Variant = null
var _cd_peak: Dictionary = {}
var _at: float = 0.0
var _hit_at: float = -100.0
var _any_at: float = -100.0
static var _web_ok: int = -1

static func active(view) -> bool:
	return bool(view._touch) or OS.has_feature("android") or OS.has_feature("ios")


static func vibrate_on() -> bool:
	var v: Variant = Settings.value("tc_vibrate")
	return true if v == null else bool(v)

func _ms() -> int:
	return int(clock.call()) if clock.is_valid() else Time.get_ticks_msec()


func tick(view, delta: float) -> void :
	if not active(view):
		return
	var client = view.client
	var battle = client.battle
	_at += delta
	var now: int = _ms()
	if _last_ms > 0 and now - _last_ms >= RESUME_GAP_MS:
		resumed += 1
		_armed = false
		if not client.bg_hidden and client.config != null:
			client._ping = maxf(float(client._ping), float(client.config.ping_seconds))
	_last_ms = now
	if int(battle.begun) != _begun:
		_begun = int(battle.begun)
		_armed = false
	if client.bg_hidden or battle.look or not battle.started or battle.ended or not battle.tanks.has(battle.self_id):
		_armed = false
		return
	var me: Dictionary = battle.tanks[battle.self_id]
	if not _armed:
		_arm(battle, me)
		return
	var kinds: Array[String] = []
	var hp: int = int(me.get("hp", 0))
	if hp < _hp and not bool(me.get("dead", false)):
		kinds.append("hit")
	_hp = hp
	var dead: bool = bool(me.get("dead", false))
	if dead and not _dead:
		kinds.append("dead")
	_dead = dead
	var top: Variant = battle.kills[0] if not battle.kills.is_empty() else null
	if top != null and not is_same(top, _kill_top) and int(top.get("killer_id", 0)) == int(battle.self_id)\
	and int(top.get("dead_id", 0)) != int(battle.self_id):
		kinds.append("kill")
	_kill_top = top
	for slot: int in CD_SLOTS:
		if not battle.skills.has(slot):
			_cd_peak.erase(slot)
			continue
		var cd: float = float(battle.cooldown(slot))
		if is_inf(cd) or is_nan(cd):
			continue
		if cd > 0.0:
			_cd_peak[slot] = maxf(float(_cd_peak.get(slot, 0.0)), cd)
		elif float(_cd_peak.get(slot, 0.0)) >= CD_MIN:
			_cd_peak.erase(slot)
			if not dead:
				kinds.append("ready")
		else:
			_cd_peak.erase(slot)
	if not kinds.is_empty():
		_fire(kinds)

func _arm(battle, me: Dictionary) -> void :
	_armed = true
	_hp = int(me.get("hp", 0))
	_dead = bool(me.get("dead", false))
	_kill_top = battle.kills[0] if not battle.kills.is_empty() else null
	_cd_peak.clear()
	for slot: int in CD_SLOTS:
		if battle.skills.has(slot):
			var cd: float = float(battle.cooldown(slot))
			if cd > 0.0 and not is_inf(cd):
				_cd_peak[slot] = cd

func _fire(kinds: Array[String]) -> void :
	if not vibrate_on() or _at - _any_at < ANY_GAP:
		return
	for kind: String in ORDER:
		if not kind in kinds:
			continue
		if kind == "hit" and _at - _hit_at < HIT_GAP:
			continue
		if kind == "hit" or kind == "dead":
			_hit_at = _at
		_any_at = _at
		fired.append(kind)
		var spec: Array = BUZZ[kind]
		if buzz.is_valid():
			buzz.call(kind, int(spec[0]), float(spec[1]))
		else:
			_vibrate(int(spec[0]), float(spec[1]))
		return

static func _vibrate(ms: int, amp: float) -> void :
	if OS.has_feature("web"):
		if _web_ok < 0:
			_web_ok = 1 if bool(JavaScriptBridge.eval("typeof navigator.vibrate === 'function'", true)) else 0
		if _web_ok == 0:
			return
	Input.vibrate_handheld(ms, amp)


static func pending_ms(client) -> int:
	var sent: int = int(client._ping_sent)
	return maxi(0, Time.get_ticks_msec() - sent) if sent > 0 else 0

static func link_bad(client) -> bool:
	if client.reconnecting():
		return true
	return pending_ms(client) > PING_LATE_MS or float(client._idle) > IDLE_STALL or int(client.latency_ms) > NORMAL_PING


static func ping_shown(client, shown: Dictionary, bad_color: Color) -> Dictionary:
	if not link_bad(client):
		return shown
	var ms: int = mini(SHOW_MAX, maxi(maxi(0, int(client.latency_ms)), pending_ms(client)))
	return {"text": "%dms" % ms, "color": bad_color, "dot": true}


static func dot_alpha() -> float:
	return 1.0 if (Time.get_ticks_msec() / 250) % 2 == 0 else 0.35
