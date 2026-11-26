extends RefCounted
























































const SkillCast = preload("skill_cast.gd")
const PveBossHp = preload("pve_boss_hp.gd")
const Settings = preload("res://settings.gd")
const SafeArea = preload("../ui/safe_area.gd")
const TouchLife = preload("touch_life.gd")
const TouchLayout = preload("touch_layout.gd")
const STAGE: Vector2 = Vector2(1266, 600)
const VIEW: Vector2 = Vector2(1582.5, 750)
const FIRE_AT: Vector2 = Vector2(104, 98)
const FIRE_R: float = 70.0










const BUTTONS: Array = [
	[Vector2(-249, 22), 52.5, Color("ff6688")], 
	[Vector2(-159, -133), 52.5, Color("66ccff")], 
	[Vector2(-4, -223), 52.5, Color("f5b342")], 
	[Vector2(-400, 24), 38.0, Color("99ee77")], 
	[Vector2(-520, 24), 38.0, Color("c8c8c8")], 
]
const AUTO_AT: Vector2 = Vector2(-131, 48)
const AUTO_R: float = 26.0
const AUTO_HIT: float = 1.6
const AUTO_BUZZ: Array = [20, 0.4]
const AUTO_COLOR: Color = Color("ffb347")
const FIRE_NEAR: float = 260.0
const FIRE_FAR: float = 440.0
const FIRE_TAP: float = 320.0
const FIRE_COLOR: Color = Color("ff5a4a")
const FIRE_FACE: Color = Color(0.753, 0.224, 0.169, 0.45)
const CELL_K: float = 0.92
const STICK_ZONE: Vector2 = Vector2(320, 290)
const STICK_IDLE: Vector2 = Vector2(140, 130)
const STICK_R: float = 95.0
const KNOB_R: float = 42.0
const STICK_DEAD: float = 0.3
const DRAG_DEAD: float = 10.0
const DRAG_MAX: float = 70.0
const PAD_KNOB: float = 26.0
const SELF_HOLD_MS: int = 450
const CANCEL_FAR: float = 150.0
const SELF_COLOR: Color = Color("66ee88")
const ASSIST_PVP: float = 35.0
const ASSIST_PVE: float = 45.0
const MARK_COLOR: Color = Color("ffd84a")
const MARK_R: float = 30.0
const MARK_MS: int = 600
const FIRE_SEEK: float = 640.0




const FIRE_HOLD_MS: int = 200
const FIRE_STEADY_MS: int = 250
const STEADY_PX: float = 4.0



const JUMP_NORMALS: Array[int] = [330141, 470141]
const JUMP_RANGE: float = 300.0
const STILL_AT: float = 2.0
const TAP_MS: int = 300
const JUMP_RETRY_MS: int = 1000
const STICK_KEEP: float = 1.2
const CANCEL_AT: Vector2 = Vector2(360, 170)
const CANCEL_R: float = 48.0
const SKILL_RANGE_MAX: float = 1400.0
const SKILL_RANGE_DEFAULT: float = 520.0
const DIR_TYPES: Array[int] = [1, 2, 5]



const FIXED_REACH: Array[int] = [303401]
const BUFF_K: float = 0.8
const BUFF_GAP: float = 8.0
const BUFF_ROW: float = 32.0
const BUFF_HIT: float = 4.0
const TIP_BLOCKERS: Array[String] = ["exit_ask", "pay_ask", "_settings", "score_board", "_loading", "pvp_result", "happy_result", "clan_result", "pve_result"]
const TIP_HOLD_MS: int = 350
const TIP_SHOW_MS: int = 1000
const COLUMN_K: float = 0.55
const MAP_AT: float = 2.0
const MAP_BOX: Vector2 = Vector2(128, 104)
const SIG_CELL: float = 26.0
const SIG_GAP: float = 3.0
const SYS_H: float = 44.0
const ICON_DIR: String = "res://assets/ui/mobile/"
const ICON_FILL: float = 0.8
const ZONE_BLUE: Color = Color("02f0ff")
const ZONE_RED: Color = Color("ff4a3a")
const ZONE_FILL: float = 0.08
const ZONE_RIM: float = 0.7
const ZONE_AREA: float = 0.28
const ZONE_DOT: float = 7.0
const TouchHeads = preload("touch_heads.gd")
const PICK_MAX: int = 9
const PICK_PUSH: float = 8.0
const PICK_PUSH_MAX: int = 12
const PICK_R: float = 25.0
const PICK_GAP: float = 112.0
const PICK_SP: float = 9.0
const PICK_HIT: float = 1.25
const PICK_HOT: float = 1.2
const PICK_EDGE: float = 4.0


var fingers: Dictionary = {}
var order: Array[int] = []
var face: Vector2 = Vector2.RIGHT
var aimed: bool = false
var aimed_in: int = -1
var pending_aim: Variant = null
var pending_tap: bool = false
var stick_vec: Vector2 = Vector2.ZERO
var mark_id: int = 0
var mark_until: int = 0
var tap_lean: Variant = null
var pending_pick: Array = []
var jump_aim: Variant = null
var jump_until: int = 0
var jump_shots: int = 0
var _icons: Dictionary = {}



var tip_pin: Dictionary = {}
var tip: Dictionary = {}
var cover: float = 1.0
var _cover_ms: int = 0


func icon(key: String) -> Texture2D:
	if not _icons.has(key):
		var path: String = ICON_DIR + key + "_128.png"
		_icons[key] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _icons[key]


static func _icon_at(view, tex: Texture2D, c: Vector2, span: float, tint: Color = Color.WHITE) -> void :
	var side: float = span / ICON_FILL
	view.draw_texture_rect(tex, Rect2(c - Vector2(side, side) * 0.5, Vector2(side, side)), false, tint)

static func unit(size: Vector2) -> float:
	return minf(size.x / STAGE.x, size.y / STAGE.y)

static func fire_center(size: Vector2) -> Vector2:
	return TouchLayout.at("fire", size, home(size, "fire"))



static func home(size: Vector2, key: String) -> Vector2:
	var u: float = unit(size)
	var e: Vector4 = SafeArea.inset(size)
	var fire: Vector2 = size - FIRE_AT * u - Vector2(e.z, e.w) + TouchLayout.pad_shift("skill") * u
	match key:
		"fire":
			return fire
		"auto":
			return fire + AUTO_AT * u * TouchLayout.scale()
		"stick":
			return Vector2(STICK_IDLE.x * u + e.x, size.y - STICK_IDLE.y * u - e.w) + TouchLayout.pad_shift("stick") * u
	var p: Vector2 = fire + (BUTTONS[int(key.substr(1))][0] as Vector2) * u * TouchLayout.scale()
	if key == "b2" and TouchLayout.mm_right():
		var top: float = SafeArea.corner_pad(size, "tr").y + (SYS_H + MAP_AT + MAP_BOX.y * TouchLayout.mm_base() + SIG_GAP + SIG_CELL + 6.0 + 22.0 + 9.0) * u
		p.y = maxf(p.y, top + maxf(float(BUTTONS[2][1]) * TouchLayout.scale() * u, drag_max(u)))
	return p


static func button(size: Vector2, ordinal: int) -> Array:
	var key: String = "b%d" % ordinal
	return [TouchLayout.at(key, size, home(size, key)), float(BUTTONS[ordinal][1]) * unit(size) * TouchLayout.k(key)]


static func auto_center(size: Vector2) -> Vector2:
	return TouchLayout.at("auto", size, home(size, "auto"))


static func fire_r(size: Vector2) -> float:
	return FIRE_R * unit(size) * TouchLayout.k("fire")

static func auto_r(size: Vector2) -> float:
	return AUTO_R * unit(size) * TouchLayout.k("auto")

static func stick_r(size: Vector2) -> float:
	return STICK_R * unit(size) * TouchLayout.k("stick")

static func knob_r(size: Vector2) -> float:
	return KNOB_R * unit(size) * TouchLayout.k("stick")


const SETTINGS_READS: Array[String] = ["tc_fire_move", "tc_cast", "tc_self_hold", "tc_cancel", "tc_sens", "tc_stick", "tc_aim", "tc_target", 
	"tc_mark", "tc_pve", "tc_face_keep", "tc_btn_fade", "tc_cast_0", "tc_cast_1", "tc_cast_2", "tc_cast_3", "tc_zone", "tc_pick"]


static var forced: Dictionary = {}


static func pref(key: String, fallback: Variant) -> Variant:
	if forced.has(key):
		return forced[key]
	var v: Variant = Settings.value(key)
	return fallback if v == null else v


static func drag_max(u: float) -> float:
	var s: float = clampf(float(pref("tc_sens", 50)), 1.0, 100.0)
	return DRAG_MAX * u * pow(2.0, (50.0 - s) / 50.0)


static func cast_mode(ord: int) -> String:
	var own: String = str(pref("tc_cast_%d" % ord, "auto"))
	if own in ["drag", "tap", "smart"]:
		return own
	return "tap" if str(pref("tc_cast", "drag")) == "tap" else "drag"


static func can_self(battle, pack: Node, slot: int) -> bool:
	var rule: Variant = SkillCast.rule_of(battle, pack, slot)
	return rule != null and SkillCast._field(rule, 0) not in SkillCast.SELF_TYPES and SkillCast._can_use_on_self(rule)

static func stick_idle(size: Vector2) -> Vector2:
	return TouchLayout.at("stick", size, home(size, "stick"))


static func stick_zone() -> Vector2:
	var s: Vector2 = TouchLayout.pad_shift("stick")
	return STICK_ZONE + Vector2(absf(s.x), absf(s.y))


static func in_stick_zone(size: Vector2, point: Vector2) -> bool:
	var u: float = unit(size)
	var p: Vector2 = point - (stick_idle(size) - home(size, "stick"))
	var e: Vector4 = SafeArea.inset(size)
	var z: Vector2 = stick_zone() * u
	return p.x < z.x + e.x and p.y > size.y - z.y - e.w



static func stick_clamp(size: Vector2, c: Vector2) -> Vector2:
	var u: float = unit(size)
	var off: Vector2 = stick_idle(size) - home(size, "stick")
	var e: Vector4 = SafeArea.inset(size)
	var z: Vector2 = stick_zone() * u
	return Vector2(minf(c.x, z.x + e.x + off.x), maxf(c.y, size.y - z.y - e.w + off.y))

static func cancel_center(size: Vector2) -> Vector2:
	var u: float = unit(size)
	var e: Vector4 = SafeArea.inset(size)
	return Vector2(size.x - CANCEL_AT.x * u - e.z, CANCEL_AT.y * u + e.y)


static func map_fit(raw: Vector2) -> Vector2:
	return raw * minf(1.0, minf(MAP_BOX.x / maxf(1.0, raw.x), MAP_BOX.y / maxf(1.0, raw.y)))


static func zoom_for(size: Vector2, extent: Vector2 = Vector2.ZERO) -> float:
	var z: float = clampf(minf(size.x / VIEW.x, size.y / VIEW.y), 0.3, 1.2)
	if extent.x > 0 and extent.y > 0:
		z = maxf(z, maxf(size.x / extent.x, size.y / extent.y))
	return z


static func skill_info(battle, pack: Node, slot: int) -> Array:
	var rule: Variant = SkillCast.rule_of(battle, pack, slot)
	if rule == null:
		return [SKILL_RANGE_DEFAULT, false]
	var reach: int = SkillCast._field(rule, 3)
	return [minf(float(reach), SKILL_RANGE_MAX) if reach > 0 else SKILL_RANGE_DEFAULT, 
		SkillCast._field(rule, 7) in DIR_TYPES or int(battle.skills[slot].nPropsId) in FIXED_REACH]


static func shown(view, battle) -> bool:
	return battle.started and not battle.ended and not battle.look and battle.tanks.has(battle.self_id)\
	and not (view._loading != null and view._loading.visible)




const COVER_LOW: float = 0.4
const COVER_EASE: float = 0.15
const COVER_BODY: float = 36.0


static func cluster(size: Vector2, battle) -> Array:
	var out: Array = [[fire_center(size), fire_r(size)], [auto_center(size), auto_r(size)]]
	for ordinal in range(5):
		if ordinal == 4 and not battle.skills.has(12):
			continue
		out.append(button(size, ordinal))
	return out


static func under(size: Vector2, battle, p: Vector2, pad: float) -> bool:
	for b: Array in cluster(size, battle):
		if p.distance_to(b[0]) <= float(b[1]) + pad:
			return true
	return false


func cover_target(view, battle) -> float:
	if TouchLayout.editing != null or not bool(pref("tc_btn_fade", true)) or not shown(view, battle):
		return 1.0
	var zoom: float = float(view._zoom)
	var half: Vector2 = view.size / 2.0
	var cam: Vector2 = view._camera
	for group: Dictionary in [battle.tanks, battle.npcs]:
		for obj: Dictionary in group.values():
			if obj.get("dead", false) or obj.get("hidden", false) or not (obj.get("pos") is Vector2):
				continue
			if group == battle.npcs and int(obj.get("max_hp", 0)) <= 0:
				continue
			if under(view.size, battle, ((obj.pos as Vector2) - cam) * zoom + half, COVER_BODY * zoom):
				return COVER_LOW
	for index: int in fingers:
		var st: Dictionary = fingers[index]
		if (st.kind == "skill" or (st.kind == "fire" and st.get("jump", false))) and under(view.size, battle, (view.controls.aim - cam) * zoom + half, 0.0):
			return COVER_LOW
	return 1.0


static func jump_normal(battle) -> bool:
	return battle.skills.has(0) and int(battle.skills[0].nPropsId) in JUMP_NORMALS


static func jump_reach(view, battle) -> float:
	var reach: float = SkillCast.guide_range(SkillCast.rule_of(battle, view.get("pack"), 0))
	return reach if reach > 0 else JUMP_RANGE

func reset() -> void :
	fingers.clear()
	order.clear()
	pending_aim = null
	pending_tap = false
	stick_vec = Vector2.ZERO
	mark_id = 0
	mark_until = 0
	tap_lean = null
	pending_pick = []
	jump_aim = null
	tip_pin = {}
	tip = {}

func held(kind: String) -> int:
	for index: int in fingers:
		if fingers[index].kind == kind:
			return index
	return -1


func press(view, battle, index: int, point: Vector2) -> bool:
	if not shown(view, battle):
		return false
	var pinned: Dictionary = tip_pin
	tip_pin = {}
	var size: Vector2 = view.size
	var fire: Vector2 = fire_center(size)
	if point.distance_to(fire) <= fire_r(size) * 1.12 and held("fire") < 0:
		var jump: bool = jump_normal(battle)
		fingers[index] = {"kind": "fire", "ord": -1, "slot": 0, "center": fire, "r": fire_r(size), "start": point, "d": point - fire, 
			"o": point - fire, "lock": false, "u": face, "f": 0.0, "tgt": 0, "range": jump_reach(view, battle) if jump else FIRE_SEEK, "dir": false, "jump": jump, "t0": Time.get_ticks_msec()}
		order.append(index)
		var lean: Dictionary = assist(view, battle, face) if battle.alive() else {}
		pending_tap = not jump and not lean.is_empty()
		tap_lean = lean.get("off")
		mark_id = int(lean.get("id", 0))
		mark_until = 0
		if not lean.is_empty():
			fingers[index]["lean"] = lean.off
			_face_to(lean.off)
		fingers[index].merge({"still": Time.get_ticks_msec(), "lp": point, "fired": pending_tap})
		view.controls.firing = held("skill") < 0 and battle.alive() and not jump and not lean.is_empty()
		return true
	if point.distance_to(auto_center(size)) <= auto_r(size) * AUTO_HIT:
		fingers[index] = {"kind": "dead", "ord": -2, "slot": 0, "center": auto_center(size), "r": auto_r(size), "start": point, "d": Vector2.ZERO, 
			"lock": false, "u": face, "f": 0.0, "tgt": 0, "range": 0.0, "dir": false}
		view.controls.auto_fire = not view.controls.auto_fire
		if TouchLife.vibrate_on():
			TouchLife._vibrate(int(AUTO_BUZZ[0]), float(AUTO_BUZZ[1]))
		return true
	var best: int = -1
	var best_d: float = INF
	for ordinal in range(5):
		if ordinal == 4 and not battle.skills.has(12):
			continue
		var b: Array = button(size, ordinal)
		var dist: float = point.distance_to(b[0])
		if dist <= float(b[1]) * 1.15 and dist < best_d:
			best = ordinal
			best_d = dist
	if best >= 0:
		var b: Array = button(size, best)
		var slot: int = view._hud.cell_slot(battle, best)
		var entry: Dictionary = {"kind": "dead", "ord": best, "slot": slot, "center": b[0], "r": b[1], "start": point, "d": point - b[0], 
			"o": point - b[0], "lock": false, "u": face, "f": 0.0, "tgt": 0, "range": SKILL_RANGE_DEFAULT, "dir": false, 
			"t0": Time.get_ticks_msec()}
		fingers[index] = entry

		if slot < 0 or view._hud.cell_blocked(battle, slot) or not SkillCast.ready(battle, view.pack, slot):
			return true
		if SkillCast.instant(battle, view.pack, slot, false):
			view.controls.queue_skill(slot)
			return true
		var info: Array = skill_info(battle, view.pack, slot)
		var mode: String = cast_mode(best)
		var tap: bool = mode != "drag"
		var selfy: bool = bool(pref("tc_self_hold", true)) and can_self(battle, view.pack, slot)
		var picky: bool = tap and not selfy and pick_rule(view, battle, {"kind": "skill", "slot": slot}) != null\
		and not pick_targets(battle, SkillCast.rule_of(battle, view.pack, slot), info[0]).is_empty()
		if tap and not selfy and not picky:

			var me: Dictionary = battle.tanks[battle.self_id]
			var tap_st: Dictionary = {"kind": "skill", "slot": slot, "d": Vector2.ZERO, "lock": false, "u": face, "f": 0.0, 
				"tgt": 0, "range": info[0], "dir": info[1], "tap": true, "smart": mode == "smart"}
			pending_aim = aim_for(view, battle, tap_st, me.pos)
			view.controls.queue_skill(slot, int(tap_st.tgt) == int(battle.self_id))
			return true
		entry.kind = "skill"
		entry.range = info[0]
		entry.dir = info[1]
		entry["t0"] = Time.get_ticks_msec()
		entry["selfy"] = selfy
		entry["smart"] = mode == "smart"
		entry["self"] = false
		order.append(index)
		if not tap:
			view.controls.selected = slot
		return true
	if in_stick_zone(size, point) and held("stick") < 0:
		var base: Vector2 = stick_idle(size) if str(pref("tc_stick", "follow")) == "fixed" else point
		fingers[index] = {"kind": "stick", "center": base, "start": point, "d": point - base}
		stick_vec = Vector2.ZERO
		view._joystick = index
		view._stick = stick_vec
		return true

	var hud: Variant = view.get("_hud")
	if hud != null and hud.has_method("touch_buff_tip"):
		var hit: Dictionary = hud.touch_buff_tip(point, battle)
		if not hit.is_empty():
			if not (str(pinned.get("kind", "")) == str(hit.kind) and int(pinned.get("id", 0)) == int(hit.get("id", 0))):
				tip_pin = hit
			fingers[index] = {"kind": "dead", "ord": -3, "slot": 0, "center": point, "r": 0.0, "start": point, "d": Vector2.ZERO, 
				"lock": false, "u": face, "f": 0.0, "tgt": 0, "range": 0.0, "dir": false}
			return true
	return false

func drag(view, index: int, point: Vector2) -> bool:
	if not fingers.has(index):
		return false
	var st: Dictionary = fingers[index]
	st.d = point - st.center
	if st.kind == "stick":
		var rim: float = stick_r(view.size)
		if str(pref("tc_stick", "follow")) != "fixed" and (st.d as Vector2).length() > rim:
			st.center = stick_clamp(view.size, point - (st.d as Vector2).normalized() * rim)
			st.d = point - st.center
		stick_vec = _stick_of(st.d, unit(view.size) * TouchLayout.k("stick"))
		view._stick = stick_vec
	elif st.kind == "fire" and point.distance_to(st.get("lp", point)) > STEADY_PX * unit(view.size):
		st.lp = point
		st.still = Time.get_ticks_msec()
		st.fired = false
	return true


static func _stick_of(d: Vector2, u: float) -> Vector2:
	var v: Vector2 = d / (STICK_R * u)
	return v.limit_length(1.0) if v.length() >= STICK_DEAD else Vector2.ZERO


func release(view, battle, index: int, point: Vector2) -> bool:
	if not fingers.has(index):
		return false
	var st: Dictionary = fingers[index]
	fingers.erase(index)
	order.erase(index)
	if st.kind == "stick":
		stick_vec = Vector2.ZERO
		view._joystick = -1
		view._stick = Vector2.ZERO
	elif st.kind == "fire":
		view.controls.firing = false
		st.d = point - st.center
		if not st.get("jump", false) and not st.get("fired", true) and battle.alive():
			pending_tap = true
			tap_lean = st.get("lean")
		if st.get("jump", false) and shown(view, battle) and battle.alive() and not cancelled(view.size, st):
			st["tap"] = quick(st)
			jump_aim = aim_for(view, battle, st, battle.tanks[battle.self_id].pos)
			jump_until = Time.get_ticks_msec() + JUMP_RETRY_MS
			var sent: Variant = view.controls.get("shots")
			jump_shots = int(sent) if sent != null else 0
		if st.get("lean") != null and mark_id != 0:
			mark_until = Time.get_ticks_msec() + MARK_MS
		else:
			mark_id = 0
	elif st.kind == "skill":
		st.d = point - st.center
		var slot: int = int(st.slot)
		if view.controls.selected == slot:
			view.controls.selected = 0
		if shown(view, battle):
			pick_update(view, battle, st)
			if int(st.get("pick", 0)) != 0:
				pending_pick = [slot, int(st.pick)]
				return true
		if cancelled(view.size, st):
			return true
		if shown(view, battle) and st.get("self", false):
			pending_aim = battle.tanks[battle.self_id].pos
			view.controls.queue_skill(slot, true)
			return true
		if shown(view, battle):
			var me: Dictionary = battle.tanks[battle.self_id]
			st["tap"] = quick(st)
			pending_aim = aim_for(view, battle, st, me.pos)
			view.controls.queue_skill(slot, int(st.tgt) == int(battle.self_id))
	return true


static func quick(st: Dictionary) -> bool:
	return not st.get("manual", false) and Time.get_ticks_msec() - int(st.get("t0", 0)) < TAP_MS



static func moved(st: Dictionary) -> Vector2:
	return (st.d as Vector2) - (st.get("o", Vector2.ZERO) as Vector2)


static func ramp(dist: float, u: float) -> float:
	var dead: float = DRAG_DEAD * u
	return clampf((dist - dead) / maxf(drag_max(u) - dead, 1.0), 0.0, 1.0)


static func cancelled(size: Vector2, st: Dictionary) -> bool:
	var u: float = unit(size)
	var d: Vector2 = st.d
	if moved(st).length() <= DRAG_DEAD * u:
		return false
	if str(pref("tc_cancel", "zone")) == "range":
		return d.length() > CANCEL_FAR * u
	return (st.center + d).distance_to(cancel_center(size)) <= CANCEL_R * u * 1.1


func frame(view, battle, controls, center: Vector2) -> void :
	var size: Vector2 = view.size
	var u: float = unit(size)
	var stick: int = held("stick")
	if stick >= 0:
		stick_vec = _stick_of(fingers[stick].d, u * TouchLayout.k("stick"))
	view._joystick = stick
	view._stick = stick_vec
	var me: Dictionary = battle.tanks.get(battle.self_id, {})
	var origin: Vector2 = me.pos if not me.is_empty() else center
	var aimer: int = order[order.size() - 1] if not order.is_empty() else -1
	var begun: Variant = battle.get("begun")
	if (int(begun) if begun != null else 0) != aimed_in:
		aimed_in = int(begun) if begun != null else 0
		aimed = false
	if aimer < 0 and stick_vec.length() >= STICK_DEAD and not (aimed and bool(pref("tc_face_keep", true))):
		face = stick_vec.normalized()
	var fire_held: bool = held("fire") >= 0
	var skill_held: bool = held("skill") >= 0
	var now: int = Time.get_ticks_msec()
	var dt: float = clampf(float(now - _cover_ms) / 1000.0, 0.0, 0.1) if _cover_ms > 0 else 0.0
	_cover_ms = now
	cover = move_toward(cover, cover_target(view, battle), dt * (1.0 - COVER_LOW) / COVER_EASE)
	var jumping: bool = jump_normal(battle)
	var jump_held: bool = false
	for index: int in fingers:
		var st: Dictionary = fingers[index]
		if st.kind == "fire":
			st.jump = jumping
			st.range = jump_reach(view, battle) if jumping else FIRE_SEEK
			jump_held = jumping
			if not st.lock and st.get("lean") != null and not me.is_empty():
				_follow(view, battle, st, me.pos)
		if st.kind != "skill":
			continue
		pick_update(view, battle, st)
		if moved(st).length() > DRAG_DEAD * u:
			st.self = false
			if controls.selected != int(st.slot):
				controls.selected = int(st.slot)
		elif st.get("selfy", false) and not st.self and now - int(st.get("t0", now)) >= SELF_HOLD_MS:
			st.self = true
			if controls.selected == int(st.slot):
				controls.selected = 0
	var sent: Variant = controls.get("shots")
	var jump_live: bool = jump_aim != null and now < jump_until and jumping and battle.alive() and not me.is_empty()\
	and (sent == null or int(sent) == jump_shots)
	if not jump_live:
		jump_aim = null
	if not pending_pick.is_empty():
		_cast_pick(view, battle, controls, origin)
	elif jump_live and not skill_held:
		controls.aim = jump_aim
	elif pending_aim != null:
		controls.aim = pending_aim
		pending_aim = null
	elif aimer >= 0 and not me.is_empty():
		controls.aim = aim_for(view, battle, fingers[aimer], origin)
	elif pending_tap and not me.is_empty():
		controls.aim = aim_for(view, battle, {"kind": "fire", "d": Vector2.ZERO, "lock": false, "u": face, "f": 0.0, "tgt": 0, 
			"range": FIRE_SEEK, "dir": false, "lean": tap_lean}, origin)
	else:
		controls.aim = origin + face * 350
	if pending_tap and not skill_held and battle.alive():
		controls.tapped = true
	if jump_live and not skill_held:
		controls.tapped = true
		if sent == null:
			jump_aim = null
	pending_tap = false
	tap_lean = null
	controls.firing = fire_held and not skill_held and battle.alive() and not jump_held and fire_ready(fingers[held("fire")], now)
	if controls.firing:
		fingers[held("fire")].fired = true
	if fire_held and not bool(pref("tc_fire_move", true)):
		view._stick = Vector2.ZERO
	tip = tip_now(view, battle, now)
	var hud: Variant = view.get("_hud")
	if hud != null and "touch_tip" in hud:
		hud.touch_tip = tip



func tip_now(view, battle, now: int) -> Dictionary:
	if not shown(view, battle):
		tip_pin = {}
		return {}
	var hud: Variant = view.get("_hud")
	if hud == null or not hud.has_method("shown_skill"):
		return {}
	for name: String in TIP_BLOCKERS:
		var node: Variant = view.get(name)
		if node != null and node is CanvasItem and node.visible:
			tip_pin = {}
			return {}
	var u: float = unit(view.size)
	var best: Dictionary = {}
	for index: int in fingers:
		var st: Dictionary = fingers[index]
		if int(st.get("ord", -1)) < 0 or not st.has("t0"):
			continue
		if st.get("tip_off", false) or moved(st).length() > DRAG_DEAD * u or now - int(st.t0) >= TIP_HOLD_MS + TIP_SHOW_MS:
			st["tip_off"] = true
			continue
		if now - int(st.t0) >= TIP_HOLD_MS and (best.is_empty() or int(st.t0) >= int(best.t0)):
			best = st
	if not best.is_empty():
		var shown_now: Array = hud.shown_skill(battle, int(best.ord))
		if int(shown_now[1]) != 0:
			var r: float = float(best.r)
			return {"kind": "skill", "id": int(shown_now[1]), "slot": int(shown_now[0]), "at": best.center, 
				"box": Rect2((best.center as Vector2) - Vector2(r, r), Vector2(r, r) * 2.0)}
	if str(tip_pin.get("kind", "")) == "buff":
		var live: bool = false
		for buff: Dictionary in (battle.tanks[battle.self_id].get("buffs", {}) as Dictionary).values():
			live = live or int(buff.get("m_nBuffTpltId", 0)) == int(tip_pin.id)
		if not live:
			tip_pin = {}
	return tip_pin




static func buff_origin(size: Vector2, n: int, row: int, has_b: bool) -> Vector2:
	var u: float = unit(size)
	var k: float = BUFF_K * u
	var q: Array = button(size, 3)
	var qc: Vector2 = q[0]
	var qr: float = float(q[1])
	var block: Rect2 = Rect2(qc.x + qr - 8 * 36 * k, qc.y - qr - (BUFF_GAP + BUFF_ROW) * u - 36 * k, 8 * 36 * k, BUFF_ROW * u + 36 * k)
	var clear: bool = block.position.x >= 0.0 and block.position.y >= SYS_H * u
	var others: Array = [[fire_center(size), fire_r(size)], [auto_center(size), auto_r(size)], button(size, 0), button(size, 1), button(size, 2)]
	if has_b:
		others.append(button(size, 4))
	for b: Array in others:
		var c: Vector2 = b[0]
		var near: Vector2 = Vector2(clampf(c.x, block.position.x, block.end.x), clampf(c.y, block.position.y, block.end.y))
		clear = clear and c.distance_to(near) >= float(b[1])
	if not clear:
		return Vector2(qc.x - qr - 8 * u - 36 * n * k, qc.y - 19 * k - row * BUFF_ROW * u)
	return Vector2(qc.x + qr - (36 * n + 2) * k, qc.y - qr - BUFF_GAP * u - 36 * k - row * BUFF_ROW * u)


static func fire_ready(st: Dictionary, now: int) -> bool:
	if st.get("lean") != null:
		return true
	if not st.get("lock", false):
		return now - int(st.get("t0", 0)) >= FIRE_HOLD_MS
	return now - int(st.get("still", 0)) >= FIRE_STEADY_MS


func aim_for(view, battle, st: Dictionary, me_pos: Vector2) -> Vector2:
	var u: float = unit(view.size)
	var d: Vector2 = moved(st)
	var dist: float = d.length()
	var fire: bool = st.kind == "fire" and not st.get("jump", false)
	if dist > DRAG_DEAD * u:
		st.u = d / dist
		st.f = minf(dist / drag_max(u), 1.0)
		if fire:
			st.lock = true
		else:
			st.manual = true
	var manual: bool = bool(st.get("manual", false))
	var tap: bool = bool(st.get("tap", false))
	var reach: float = float(st.range)
	var pick: int = int(st.get("pick", 0))
	if pick != 0 and battle.tanks.has(pick):
		var at: Vector2 = battle.tanks[pick].pos
		if at.distance_to(me_pos) > 0.5:
			face = (at - me_pos).normalized()
			aimed = true
		st.tgt = pick
		return at
	if st.get("jump", false) and not manual:
		st.tgt = 0
		if not tap:
			return me_pos + face * STILL_AT
		var lean: Variant = st.get("lean")
		var reach_jump: float = float(st.range) - 4.0
		return me_pos + ((lean as Vector2).limit_length(reach_jump) if lean != null else face * minf(FIRE_TAP, reach_jump))
	if fire and not st.lock:
		st.tgt = 0
		if st.get("lean") != null:
			return me_pos + (st.lean as Vector2)
		return me_pos + face * FIRE_TAP
	if dist > DRAG_DEAD * u or st.lock or manual:
		face = st.u
		aimed = true
		st.tgt = 0
		if fire:
			if st.has("lean"):
				st.erase("lean")
				mark_id = 0
			return me_pos + (st.u as Vector2) * (FIRE_NEAR + FIRE_FAR * float(st.f))

		var far: float = reach - 4.0 if st.dir else maxf(STILL_AT, ramp(dist, u) * (reach - 4.0))
		var at: Vector2 = me_pos + (st.u as Vector2) * far
		var snap: Dictionary = drag_target(view, battle, st, me_pos, at)
		st["snap"] = int(snap.get("id", 0))
		if snap.is_empty():
			return at
		st.tgt = int(snap.id)
		return snap.pos

	var foe: Dictionary = skill_foe(view, battle, st, me_pos)
	st.tgt = int(foe.get("id", 0))
	if not foe.is_empty():
		var to: Vector2 = (foe.pos as Vector2) - me_pos
		if to.length() > 0.5:
			face = to.normalized()
			aimed = true
		return me_pos + face * (reach - 4.0) if st.dir else foe.pos
	var mate: Dictionary = skill_mate(view, battle, st, me_pos)
	if not mate.is_empty():
		st.tgt = int(mate.id)
		return mate.pos
	if st.get("smart", false) and tap and reach > 4.0:
		var near: Dictionary = _best_foe(view, battle, me_pos, reach, null)
		if not near.is_empty():
			var at: Vector2 = (near.pos as Vector2) - me_pos
			if at.length() > 0.5:
				face = at.normalized()
				aimed = true
			return me_pos + face * (reach - 4.0) if st.dir else me_pos + at.limit_length(reach - 4.0)
	if st.dir or tap:
		return me_pos + face * (reach - 4.0 if st.dir else minf(reach - 4.0, 320.0))
	return me_pos + face * STILL_AT







const SNAP_DEG: float = 30.0
const SNAP_NEAR: float = 140.0


func drag_target(view, battle, st: Dictionary, me_pos: Vector2, aim: Vector2) -> Dictionary:
	var slot: int = int(st.get("slot", -1))
	if slot < 0 or str(st.get("kind", "")) != "skill" or not ("skills" in battle) or not battle.skills.has(slot):
		return {}
	var rule: Variant = SkillCast.rule_of(battle, view.pack, slot)
	if rule == null or SkillCast._field(rule, 0) != SkillCast.SELECTED_OBJ or int(battle.skills[slot].nPropsId) in SkillCast.TARGET_OR_POINT:
		return {}
	var limit: int = SkillCast._field(rule, 1)
	var hit: float = float(SkillCast._field(rule, 2) + 36)
	var pool: Array = []
	for tank: Dictionary in battle.tanks.values():
		if not SkillCast._selectable(battle, tank, limit):
			continue
		if (tank.pos as Vector2).distance_to(aim) < hit:
			return {}
		if int(tank.id) != int(battle.self_id):
			pool.append(tank)
	if not limit & SkillCast.SSL_TANK and "npcs" in battle:
		for npc: Dictionary in battle.npcs.values():
			if int(npc.id) >> 26 != 5 or SkillCast.BattleState.pass_ainpc(int(npc.id), npc) or npc.get("dead", false) or npc.get("hidden", false)\
			or not SkillCast._npc_camps_ok(battle, npc, limit):
				continue
			if absf(npc.pos.x - aim.x) < SkillCast.TANK_HALF and absf(npc.pos.y - aim.y) < SkillCast.TANK_HALF:
				return {}
			pool.append(npc)
	var dir: Vector2 = st.u
	var cone: float = cos(deg_to_rad(SNAP_DEG))
	var best: Dictionary = {}
	var best_gap: float = INF
	for obj: Dictionary in pool:
		var to: Vector2 = (obj.pos as Vector2) - me_pos
		var gap: float = (obj.pos as Vector2).distance_to(aim)
		if to.length() > float(st.range) or not on_screen(view, obj.pos) or not SkillCast._buff_ok(battle, rule, obj):
			continue
		if gap > SNAP_NEAR and (to.length() < 0.5 or to.normalized().dot(dir) < cone):
			continue
		if gap < best_gap:
			best_gap = gap
			best = {"id": int(obj.id), "pos": obj.pos}
	return best





func skill_foe(view, battle, st: Dictionary, me_pos: Vector2) -> Dictionary:
	var rule: Variant = SkillCast.rule_of(battle, view.pack, int(st.slot)) if st.has("slot") else null
	if rule == null or SkillCast._field(rule, 0) != SkillCast.SELECTED_OBJ or not SkillCast._field(rule, 1) & SkillCast.SSL_ENEMY:
		return {}
	return _best_foe(view, battle, me_pos, float(st.range), rule)



func _best_foe(view, battle, me_pos: Vector2, reach: float, rule: Variant) -> Dictionary:
	var limit: int = SkillCast._field(rule, 1) if rule != null else 0
	var how: String = str(pref("tc_target", "near"))
	var boss_first: bool = PveBossHp.is_pve(battle) and str(pref("tc_pve", "near")) == "boss"
	var best: Dictionary = {}
	var best_key: Array = []
	for foe: Dictionary in foes(battle):
		var dist: float = me_pos.distance_to(foe.pos)
		if dist > reach or not on_screen(view, foe.pos):
			continue
		var npc: bool = not battle.tanks.has(int(foe.id))
		if rule != null and npc and (int(foe.id) >> 26 != 5 or limit & SkillCast.SSL_TANK):
			continue
		if rule != null and not SkillCast._buff_ok(battle, rule, battle.npcs[int(foe.id)] if npc else battle.tanks[int(foe.id)]):
			continue
		var score: float = dist
		if how == "hp":
			score = float(foe.hp)
		elif how == "hp_pct":
			score = float(foe.hp) / maxf(1.0, float(foe.max_hp))
		var key: Array = [0 if (boss_first and foe.boss) else 1, score, dist]
		if best.is_empty() or _before(key, best_key):
			best = foe
			best_key = key
	return best





func skill_mate(view, battle, st: Dictionary, me_pos: Vector2) -> Dictionary:
	var rule: Variant = SkillCast.rule_of(battle, view.pack, int(st.slot)) if st.has("slot") else null
	if rule == null or SkillCast._field(rule, 0) != SkillCast.SELECTED_OBJ:
		return {}
	var limit: int = SkillCast._field(rule, 1)
	if limit & SkillCast.SSL_ENEMY or not limit & SkillCast.SSL_TEAMMATE:
		return {}
	var best: Dictionary = {}
	var best_key: Array = []
	for tank: Dictionary in battle.tanks.values():
		if not SkillCast._selectable(battle, tank, limit) or not SkillCast._same_camp(battle, tank):
			continue
		var dist: float = me_pos.distance_to(tank.pos)
		if dist > float(st.range) or not on_screen(view, tank.pos) or not SkillCast._buff_ok(battle, rule, tank):
			continue
		var key: Array = [float(tank.get("hp", 1)) / maxf(1.0, float(tank.get("max_hp", 1))), dist]
		if best.is_empty() or _before(key, best_key):
			best = {"id": int(tank.id), "pos": tank.pos}
			best_key = key
	return best


static func foes(battle) -> Array:
	var out: Array = []
	var camp: int = int(battle.self_camp())
	var happy: bool = battle.mode == "happy"
	for tank: Dictionary in battle.tanks.values():
		if int(tank.id) == battle.self_id or tank.dead or tank.get("hidden", false):
			continue
		if not happy and int(tank.camp) == camp:
			continue
		out.append({"id": int(tank.id), "pos": tank.pos, "hp": int(tank.get("hp", 1)), "max_hp": int(tank.get("max_hp", 1)), "boss": false})
	for npc: Dictionary in battle.npcs.values():
		var kind: int = int(npc.id) >> 26
		if kind not in [3, 5] or npc.get("dead", false) or int(npc.get("hp", 1)) <= 0:
			continue
		var c: int = int(npc.get("camp", 0))
		if c == 0 or c == camp:
			continue
		out.append({"id": int(npc.id), "pos": npc.pos, "hp": int(npc.get("hp", 1)), "max_hp": int(npc.get("max_hp", 1)), 
			"boss": not PveBossHp.boss_row(int(npc.get("template", 0))).is_empty()})
	return out

static func on_screen(view, pos: Vector2) -> bool:
	var half: Vector2 = view.size / (2.0 * maxf(0.01, view._zoom))
	return Rect2(view._camera - half, half * 2).has_point(pos)




func assist(view, battle, dir: Vector2) -> Dictionary:
	var mode: String = str(pref("tc_aim", "off"))
	if mode not in ["light", "strong"] or dir.length() < 0.5 or not battle.tanks.has(battle.self_id):
		return {}
	var me_pos: Vector2 = battle.tanks[battle.self_id].pos
	var pve: bool = PveBossHp.is_pve(battle)
	var cone: float = cos(deg_to_rad(ASSIST_PVE if pve else ASSIST_PVP)) if mode == "light" else -2.0
	var how: String = str(pref("tc_target", "near"))
	var boss_first: bool = pve and str(pref("tc_pve", "near")) == "boss"
	var unit_dir: Vector2 = dir.normalized()
	var best: Dictionary = {}
	var best_key: Array = []
	for foe: Dictionary in foes(battle):
		var to: Vector2 = (foe.pos as Vector2) - me_pos
		var dist: float = to.length()
		if dist < 0.5 or dist > FIRE_SEEK or unit_dir.dot(to / dist) < cone or not on_screen(view, foe.pos):
			continue
		if not los_clear(battle, me_pos, foe.pos):
			continue
		var score: float = dist
		if how == "hp":
			score = float(foe.hp)
		elif how == "hp_pct":
			score = float(foe.hp) / maxf(1.0, float(foe.max_hp))
		var key: Array = [0 if (boss_first and foe.boss) else 1, score, dist]
		if best.is_empty() or _before(key, best_key):
			best = {"id": int(foe.id), "off": to}
			best_key = key
	return best


func _face_to(off: Vector2) -> void :
	if off.length() > 0.5:
		face = off.normalized()
		aimed = true


func _follow(view, battle, st: Dictionary, me_pos: Vector2) -> void :
	if mark_id == 0 or str(pref("tc_aim", "off")) != "strong":
		return
	for foe: Dictionary in foes(battle):
		if int(foe.id) != mark_id:
			continue
		var to: Vector2 = (foe.pos as Vector2) - me_pos
		if to.length() > 0.5 and to.length() <= FIRE_SEEK and on_screen(view, foe.pos) and los_clear(battle, me_pos, foe.pos):
			st.lean = to
			_face_to(to)
		return


static func _before(a: Array, b: Array) -> bool:
	for i in range(a.size()):
		if float(a[i]) != float(b[i]):
			return float(a[i]) < float(b[i])
	return false



static func los_clear(battle, a: Vector2, b: Vector2) -> bool:
	var map: Variant = battle.get("map")
	if map == null or map.blocked.is_empty():
		return true
	var columns: int = int(map.extent.x / 24)
	var steps: int = maxi(1, ceili(a.distance_to(b) / 12.0))
	for i in range(1, steps):
		var p: Vector2 = a.lerp(b, float(i) / steps)
		if p.x >= 0 and p.y >= 0 and map.blocked.has(int(p.y / 24) * columns + int(p.x / 24)):
			return false
	return true


func mark_shown() -> bool:
	if mark_id == 0 or str(pref("tc_aim", "off")) not in ["light", "strong"] or not bool(pref("tc_mark", true)):
		return false
	var index: int = held("fire")
	if index >= 0 and fingers[index].get("lean") != null:
		return true
	return mark_until > 0 and Time.get_ticks_msec() < mark_until


func _draw_mark(view, battle, z: float) -> void :
	if not mark_shown():
		return
	for foe: Dictionary in foes(battle):
		if int(foe.id) == mark_id:
			view.draw_arc(foe.pos, MARK_R, 0, TAU, 32, MARK_COLOR, 3.0 / z, true)
			view.draw_arc(foe.pos, MARK_R + 4.0 / z, 0, TAU, 32, Color(0, 0, 0, 0.45), 1.5 / z, true)
			return


func pick_target(view, battle, me_pos: Vector2, reach: float, keep: int) -> Dictionary:
	var best: Dictionary = {}
	var score: float = INF
	for foe: Dictionary in foes(battle):
		if not on_screen(view, foe.pos):
			continue
		var to: Vector2 = foe.pos - me_pos
		var dist: float = to.length()
		if int(foe.id) == keep and dist <= reach * STICK_KEEP:
			return foe
		if dist > reach:
			continue
		var cosv: float = face.dot(to / dist) if dist > 0.5 else 1.0
		var s: float = dist * (1.6 - 0.6 * cosv)
		if s < score:
			score = s
			best = foe
	return best


func pick_in_dir(view, battle, me_pos: Vector2, dir: Vector2) -> Dictionary:
	var best: Dictionary = {}
	var score: float = INF
	for foe: Dictionary in foes(battle):
		var to: Vector2 = foe.pos - me_pos
		var dist: float = to.length()
		if dist < 0.5 or dist > FIRE_SEEK or not on_screen(view, foe.pos):
			continue
		var cosv: float = dir.dot(to / dist)
		if cosv < 0.85:
			continue
		var s: float = dist * (1.0 + 5.0 * (1.0 - cosv))
		if s < score:
			score = s
			best = foe
	return best



func draw(view, battle) -> void :
	if not shown(view, battle):
		return
	var size: Vector2 = view.size
	var u: float = unit(size)
	var fa: float = TouchLayout.alpha()
	var stick_a: float = fa
	fa *= cover
	var pressed: Dictionary = {}
	for index: int in fingers:
		var st: Dictionary = fingers[index]
		if st.kind in ["fire", "skill", "dead"]:
			pressed[int(st.get("ord", -1))] = true
	for ordinal in range(5):
		if ordinal == 4 and not battle.skills.has(12):
			continue
		var b: Array = button(size, ordinal)
		var r: float = float(b[1]) * (0.9 if pressed.has(ordinal) else 1.0)
		view.draw_arc(b[0], r, 0, TAU, 48, Color(BUTTONS[ordinal][2], 0.75 * fa), 3.0 * u, true)
	var ac: Vector2 = auto_center(size)
	var ar: float = auto_r(size) * (0.9 if pressed.has(-2) else 1.0)
	var ak: float = auto_r(size) / (AUTO_R * u)
	var on: bool = view.controls.auto_fire
	view.draw_circle(ac, ar, Color(AUTO_COLOR, 0.55 * fa) if on else Color(0.04, 0.06, 0.1, 0.6 * fa))
	view.draw_arc(ac, ar, 0, TAU, 40, Color(AUTO_COLOR, (0.95 if on else 0.6) * fa), 3.0 * u, true)
	var auto_icon: Texture2D = icon("autofire")
	if auto_icon != null:
		_icon_at(view, auto_icon, ac, ar * 1.45, Color(1, 1, 1, (1.0 if on else 0.8) * fa))
	else:
		view._label(ac + Vector2( - ar, -1 * u * ak), "TỰ", Color(1, 1, 1, fa), maxi(9, roundi(13 * u * ak)), HORIZONTAL_ALIGNMENT_CENTER, ar * 2)
		view._label(ac + Vector2( - ar, 12 * u * ak), "BẮN", Color(1, 1, 1, fa), maxi(8, roundi(11 * u * ak)), HORIZONTAL_ALIGNMENT_CENTER, ar * 2)
	var fire: Vector2 = fire_center(size)
	var fr: float = fire_r(size) * (0.9 if pressed.has(-1) else 1.0)
	view.draw_circle(fire, fr, TouchLayout.fade(FIRE_FACE, fa))
	view.draw_arc(fire, fr, 0, TAU, 64, Color(FIRE_COLOR, 0.9 * fa), 4.0 * u, true)
	var white: Color = Color(1, 1, 1, 0.9 * fa)
	var fire_icon: Texture2D = icon("fire")
	if fire_icon != null:
		_icon_at(view, fire_icon, fire, fr * 1.15, Color(1, 1, 1, fa))
	else:
		view.draw_arc(fire, fr * 0.42, 0, TAU, 40, white, 3.0 * u, true)
		for dir: Vector2 in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
			view.draw_line(fire + dir * fr * 0.2, fire + dir * fr * 0.66, white, 3.0 * u, true)
		view.draw_circle(fire, 4.0 * u, white)

	var stick: int = held("stick")
	var base: Vector2 = fingers[stick].center if stick >= 0 else stick_idle(size)
	var alpha: float = (1.0 if stick >= 0 else 0.55) * stick_a
	var sr: float = stick_r(size)
	view.draw_circle(base, sr, Color(0, 0, 0, 0.22 * alpha))
	var base_icon: Texture2D = icon("move_stick_base")
	if base_icon != null:
		_icon_at(view, base_icon, base, sr * 2.0, Color(1, 1, 1, 0.7 * alpha))
	else:
		view.draw_arc(base, sr, 0, TAU, 64, Color(1, 1, 1, 0.55 * alpha), 3.0 * u, true)
	var knob_icon: Texture2D = icon("move_stick_knob")
	if knob_icon != null:
		_icon_at(view, knob_icon, base + stick_vec * sr, knob_r(size) * 2.0, Color(1, 1, 1, 0.75 * alpha))
	else:
		view.draw_circle(base + stick_vec * sr, knob_r(size), Color(1, 1, 1, 0.5 * alpha))

	var dragging_skill: bool = false
	for index: int in fingers:
		var st: Dictionary = fingers[index]
		if st.kind != "fire" and st.kind != "skill":
			continue
		var d: Vector2 = moved(st)
		var zoned: bool = (st.kind == "skill" and _zoned(view, st)) or _jump_zoned(st)
		if d.length() <= DRAG_DEAD * u and not st.lock and not zoned:
			continue
		var pad: float = drag_max(u)
		if st.kind == "skill" or st.get("jump", false):
			dragging_skill = true
			if str(pref("tc_cancel", "zone")) == "range":
				var far: bool = cancelled(size, st)
				view.draw_arc(st.center, CANCEL_FAR * u, 0, TAU, 64, Color("ff6655", 0.95 if far else 0.45), (4.0 if far else 2.0) * u, true)
		if zoned:

			var zc: Color = ZONE_RED if _cancel_now(size, st) else ZONE_BLUE
			var knob: Vector2 = st.center + d.limit_length(pad)
			view.draw_circle(st.center, pad, Color(0, 0, 0, 0.2))
			view.draw_arc(st.center, pad, 0, TAU, 48, Color(zc, 0.8), 2.5 * u, true)
			view.draw_circle(knob, PAD_KNOB * u, Color(1, 1, 1, 0.55))
			view.draw_arc(knob, PAD_KNOB * u, 0, TAU, 32, Color(zc, 0.95), 2.5 * u, true)
			continue
		view.draw_circle(st.center, pad, Color(0, 0, 0, 0.12))
		view.draw_arc(st.center, pad, 0, TAU, 48, Color(1, 1, 1, 0.45), 2.0 * u, true)
		view.draw_circle(st.center + d.limit_length(pad), PAD_KNOB * u, Color(1, 1, 1, 0.35))
	for index: int in fingers:
		var st: Dictionary = fingers[index]
		if st.kind == "skill" and st.get("self", false):
			view.draw_arc(st.center, float(st.r) * 1.12, 0, TAU, 48, SELF_COLOR, 4.0 * u, true)
			var self_icon: Texture2D = icon("self_cast")
			if self_icon != null:
				_icon_at(view, self_icon, st.center + Vector2(1, -1) * float(st.r) * 0.85, float(st.r) * 0.8)
	if dragging_skill and str(pref("tc_cancel", "zone")) != "range":
		var cc: Vector2 = cancel_center(size)
		var hot: bool = false
		for index: int in fingers:
			var st: Dictionary = fingers[index]
			if (st.kind == "skill" or st.get("jump", false)) and (st.center + st.d).distance_to(cc) <= CANCEL_R * u * 1.1\
			and int(st.get("pick", 0)) == 0:
				hot = true
		view.draw_circle(cc, CANCEL_R * u, Color(ZONE_RED, 0.62) if hot else Color(0, 0, 0, 0.4))
		view.draw_arc(cc, CANCEL_R * u, 0, TAU, 48, ZONE_RED if hot else Color("ff6655"), (4.5 if hot else 3.0) * u, true)
		var cancel_icon: Texture2D = icon("cancel")
		if cancel_icon != null:
			_icon_at(view, cancel_icon, cc, CANCEL_R * u * 1.3)
		else:
			view._label(cc + Vector2( - CANCEL_R * u, 7 * u), "HỦY", Color.WHITE, maxi(10, roundi(20 * u)), HORIZONTAL_ALIGNMENT_CENTER, CANCEL_R * u * 2)
	_draw_picks(view, battle, u)



func draw_world(view, battle) -> void :
	if not shown(view, battle) or not battle.alive():
		return
	var me: Vector2 = battle.tanks[battle.self_id].pos
	var z: float = maxf(0.01, view._zoom)
	_draw_mark(view, battle, z)
	for finger: int in fingers:
		if fingers[finger].kind == "skill" and fingers[finger].get("self", false):
			view.draw_circle(me, 52.0, Color(SELF_COLOR, 0.16))
			view.draw_arc(me, 52.0, 0, TAU, 48, SELF_COLOR, 4.0 / z, true)
			return
	var held_zone: Dictionary = zone_finger(view)
	if not held_zone.is_empty():
		_draw_zone(view, zone(view, battle, held_zone), z)
		var pick: int = int(held_zone.get("pick", 0))
		if pick == 0 and battle.tanks.has(int(held_zone.get("snap", 0))):
			pick = int(held_zone.snap)
		if pick != 0 and battle.tanks.has(pick):
			view.draw_arc(battle.tanks[pick].pos, MARK_R + 14.0, 0, TAU, 40, MARK_COLOR, 3.5 / z, true)
			view.draw_arc(battle.tanks[pick].pos, MARK_R + 14.0 + 4.0 / z, 0, TAU, 40, Color(0, 0, 0, 0.45), 1.5 / z, true)
		return
	var index: int = held("fire")
	if index < 0 or held("skill") >= 0:
		return
	if _jump_zoned(fingers[index]):
		_draw_zone(view, zone(view, battle, fingers[index]), z)
		return
	var aim: Vector2 = view.controls.aim
	if int(fingers[index].get("tgt", 0)) != 0:
		view.draw_line(me, aim, Color(1, 1, 1, 0.45), 3.0 / z, true)
		view.draw_arc(aim, 34.0, 0, TAU, 40, Color(1, 1, 1, 0.8), 3.0 / z, true)
	else:
		view.draw_line(me, aim, Color(1, 1, 1, 0.55), 4.0 / z, true)
		view.draw_arc(aim, 14.0, 0, TAU, 24, Color(1, 1, 1, 0.8), 3.0 / z, true)


static func _sel(view) -> int:
	var v: Variant = view.controls.get("selected")
	return int(v) if v != null else 0



func _zoned(view, st: Dictionary) -> bool:
	var sel: int = _sel(view)
	return sel != 0 and not st.get("self", false) and int(st.get("slot", 0)) == sel and bool(pref("tc_zone", true))


static func _jump_zoned(st: Dictionary) -> bool:
	return st.get("kind", "") == "fire" and st.get("jump", false) and bool(pref("tc_zone", true))


func zone_finger(view) -> Dictionary:
	if _sel(view) == 0:
		return {}
	for i in range(order.size() - 1, -1, -1):
		var st: Dictionary = fingers.get(order[i], {})
		if st.get("kind", "") == "skill" and _zoned(view, st):
			return st
	for index: int in fingers:
		if fingers[index].get("kind", "") == "skill" and _zoned(view, fingers[index]):
			return fingers[index]
	return {}




func zone(view, battle, st: Dictionary) -> Dictionary:
	var me: Vector2 = battle.tanks[battle.self_id].pos
	var rule: Variant = SkillCast.rule_of(battle, view.pack, int(st.slot))
	var reach: float = SkillCast.guide_range(rule)
	if reach <= 0:
		reach = float(st.get("range", SKILL_RANGE_DEFAULT))
	var aim: Vector2 = view.controls.aim
	var shape: PackedVector2Array = SkillCast.guide_shape(rule, me, aim, SkillCast.stme4_skill(battle, int(st.slot)))
	if shape.size() < 3 or Geometry2D.triangulate_polygon(shape).is_empty():
		shape = PackedVector2Array()
	var out: Dictionary = {"me": me, "reach": reach, "hot": _cancel_now(view.size, st), "aim": aim, "shape": shape, 
		"strip": PackedVector2Array(), "dot": not bool(st.get("dir", false)), "area": 0.0}
	if shape.is_empty():
		var gap: Vector2 = aim - me
		var dir: Vector2 = gap.normalized() if gap.length() > 0.5 else face
		var param: float = float(SkillCast._field(rule, 8)) if rule != null else 0.0
		if not out.dot:
			out.strip = SkillCast._arrow(me, dir, param if param > 0 else SkillCast.ARROW_WIDTH, reach)
		else:


			out.area = SkillCast.landing_radius(rule)
	return out


static func _soft(view) -> bool:
	var gfx: Variant = view.get("_gfx")
	return gfx == null or int(gfx.level) > 0

func _draw_zone(view, zn: Dictionary, z: float) -> void :
	var c: Color = ZONE_RED if zn.hot else ZONE_BLUE
	var me: Vector2 = zn.me
	var reach: float = zn.reach
	var soft: bool = _soft(view)
	var segs: int = clampi(int(reach * z / 6.0), 48, 128)
	view.draw_circle(me, reach, Color(c, ZONE_FILL * (1.5 if zn.hot else 1.0)))
	if soft:
		view.draw_arc(me, reach, 0, TAU, segs, Color(c, 0.16), 10.0 / z, true)
	view.draw_arc(me, reach, 0, TAU, segs, Color(c, ZONE_RIM), 2.5 / z, true)
	var shape: PackedVector2Array = zn.shape if not (zn.shape as PackedVector2Array).is_empty() else zn.strip
	if shape.size() >= 3:
		view.draw_colored_polygon(shape, Color(c, ZONE_AREA))
		var ring: PackedVector2Array = shape.duplicate()
		ring.append(shape[0])
		if soft:
			view.draw_polyline(ring, Color(c, 0.18), 8.0 / z, true)
		view.draw_polyline(ring, Color(c, 0.9), 2.0 / z, true)
	elif zn.dot:
		view.draw_line(me, zn.aim, Color(c, 0.45), 2.0 / z, true)
	if zn.dot:
		var aim: Vector2 = zn.aim
		if float(zn.area) > 0:
			_draw_landing(view, aim, float(zn.area), c, z)
		view.draw_circle(aim, ZONE_DOT / z, Color(c, 0.95))
		view.draw_arc(aim, (ZONE_DOT + 3.0) / z, 0, TAU, 24, Color(1, 1, 1, 0.85), 1.5 / z, true)
		for q: int in 4:
			var v: Vector2 = Vector2.RIGHT.rotated(q * PI / 2.0)
			view.draw_line(aim + v * (ZONE_DOT + 6.0) / z, aim + v * (ZONE_DOT + 13.0) / z, Color(c, 0.9), 1.5 / z, true)



const LAND_FILL: float = 0.05
func _draw_landing(view, aim: Vector2, r: float, c: Color, z: float) -> void :
	view.draw_circle(aim, r, Color(c, LAND_FILL))
	view.draw_arc(aim, r, 0, TAU, clampi(int(r * z / 4.0), 24, 96), Color(c, 0.8), 1.5 / z, true)
	var tick: float = minf(9.0 / z, r * 0.3)
	for q: int in 4:
		var v: Vector2 = Vector2.RIGHT.rotated(q * PI / 2.0 + PI / 4.0)
		view.draw_line(aim + v * r, aim + v * (r - tick), Color(c, 0.9), 1.5 / z, true)



func pick_rule(view, battle, st: Dictionary) -> Variant:
	if st.get("kind", "") != "skill" or not bool(pref("tc_pick", true)) or battle.get("happy") == null:
		return null
	var rule: Variant = SkillCast.rule_of(battle, view.pack, int(st.get("slot", 0)))
	if rule == null or SkillCast._field(rule, 0) != SkillCast.SELECTED_OBJ:
		return null
	if not SkillCast._field(rule, 1) & (SkillCast.SSL_ENEMY | SkillCast.SSL_TEAMMATE):
		return null
	return rule




func pick_targets(battle, rule: Array, reach: float, anywhere: bool = false) -> Array:
	var me_pos: Vector2 = battle.tanks[battle.self_id].pos
	var limit: int = SkillCast._field(rule, 1)
	var how: String = str(pref("tc_target", "near"))
	var rows: Array = []
	for tank: Dictionary in battle.tanks.values():
		if int(tank.id) == int(battle.self_id) or not SkillCast._selectable(battle, tank, limit):
			continue
		var dist: float = me_pos.distance_to(tank.pos)
		if not anywhere and ((SkillCast._field(rule, 4) != 0 and dist > reach) or SkillCast._out_of_range(rule, tank.pos, battle.tanks[battle.self_id])) or not SkillCast._buff_ok(battle, rule, tank):
			continue
		var enemy: bool = not SkillCast._same_camp(battle, tank)
		var score: float = dist
		if enemy and how == "hp":
			score = float(tank.get("hp", 1))
		elif enemy and how == "hp_pct":
			score = float(tank.get("hp", 1)) / maxf(1.0, float(tank.get("max_hp", 1)))
		rows.append({"id": int(tank.id), "enemy": enemy, "key": [0 if enemy else 1, score, dist]})
	rows.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return _before(a.key, b.key))
	return rows





static func pick_spots(size: Vector2, center: Vector2, n: int, cap: int = -1) -> Array:
	var u: float = unit(size)
	var fire: Vector2 = fire_center(size)
	var rel: Vector2 = center - fire
	var base_a: float = rel.angle() if rel.length() > 1.0 else deg_to_rad(225.0)
	var r: float = PICK_R * u * PICK_HOT
	var e: Vector4 = SafeArea.inset(size)
	var box: Rect2 = Rect2(Vector2(e.x, e.y), size - Vector2(e.x + e.z, e.y + e.w)).grow( - (r + PICK_EDGE * u))
	var avoid: float = (CANCEL_R * 1.1 + PICK_R * PICK_HIT) * u if str(pref("tc_cancel", "zone")) != "range" else -1.0
	var cancel: Vector2 = cancel_center(size)
	var keep_off: Array = [[auto_center(size), auto_r(size)]]
	for o in range(BUTTONS.size()):
		keep_off.append(button(size, o))
	var want: int = maxi(n, cap)
	var best: Array = []
	for push in range(PICK_PUSH_MAX + 1):
		var radius: float = rel.length() + (PICK_GAP + push * PICK_PUSH) * u
		var step: float = (2.0 * PICK_R + PICK_SP) * u / maxf(1.0, radius)
		var out: Array = []
		for k in range(48):
			if out.size() >= want:
				break
			var j: int = ((k + 1) / 2) * (1 if k % 2 == 1 else -1)
			var p: Vector2 = fire + Vector2.from_angle(base_a + j * step) * radius
			if not box.has_point(p) or (avoid > 0 and p.distance_to(cancel) < avoid):
				continue
			var clear: bool = true
			for b: Array in keep_off:
				clear = clear and p.distance_to(b[0]) > float(b[1]) * 1.15 + PICK_R * u * 0.5
			if clear:
				out.append(p)
		if out.size() > best.size():
			best = out
		if best.size() >= want:
			break
	return best.slice(0, n)



func pick_update(view, battle, st: Dictionary) -> void :
	var rule: Variant = pick_rule(view, battle, st)
	if rule == null or not battle.alive() or not battle.tanks.has(battle.self_id):
		st.picks = []
		st.pick_ids = []
		st.pick_cap = 0
		st.pick = 0
		return
	var slot: int = int(st.slot)
	var sid: int = int(battle.skills[slot].get("nPropsId", 0))
	if int(st.get("pick_sid", sid)) != sid:
		st.pick_ids = []
		st.pick_cap = 0
	st.pick_sid = sid
	var live: Dictionary = {}
	var ids: Array = st.get("pick_ids", [])
	for row: Dictionary in pick_targets(battle, rule, float(skill_info(battle, view.pack, slot)[0])):
		live[int(row.id)] = row.enemy
		if ids.size() < PICK_MAX and int(row.id) not in ids:
			ids.append(int(row.id))
	st.pick_ids = ids
	var cap: int = maxi(int(st.get("pick_cap", 0)), mini(PICK_MAX, pick_targets(battle, rule, 0.0, true).size()))
	st.pick_cap = cap
	var spots: Array = pick_spots(view.size, st.center, ids.size(), cap)
	var picks: Array = []
	for i in range(mini(ids.size(), spots.size())):
		var id: int = ids[i]
		var tank: Dictionary = battle.tanks.get(id, {})
		var enemy: bool = bool(live[id]) if live.has(id) else ( not tank.is_empty() and not SkillCast._same_camp(battle, tank))
		picks.append({"id": id, "at": spots[i], "ok": live.has(id), "enemy": enemy})
	st.picks = picks
	var tip: Vector2 = st.center + (st.d as Vector2)
	var reach: float = PICK_R * PICK_HIT * unit(view.size)
	var best: float = INF
	st.pick = 0
	for p: Dictionary in picks:
		var gap: float = tip.distance_to(p.at)
		if p.ok and gap <= reach and gap < best:
			best = gap
			st.pick = int(p.id)



func in_pick_zone(size: Vector2) -> bool:
	var fire: Vector2 = fire_center(size)
	var pad: float = PICK_R * PICK_HIT * unit(size)
	for index: int in fingers:
		var st: Dictionary = fingers[index]
		var picks: Array = st.get("picks", [])
		if st.kind != "skill" or picks.is_empty():
			continue
		if int(st.get("pick", 0)) != 0:
			return true
		var far: float = 0.0
		for p: Dictionary in picks:
			far = maxf(far, (p.at as Vector2).distance_to(fire))
		if (st.center + (st.d as Vector2)).distance_to(fire) <= far + pad:
			return true
	return false


func _cancel_now(size: Vector2, st: Dictionary) -> bool:
	return int(st.get("pick", 0)) == 0 and cancelled(size, st)



func _cast_pick(view, battle, controls, origin: Vector2) -> void :
	var slot: int = int(pending_pick[0])
	var id: int = int(pending_pick[1])
	pending_pick = []
	if not battle.tanks.has(id):
		controls.aim = origin + face * 350
		return
	var at: Vector2 = battle.tanks[id].pos
	if at.distance_to(origin) > 0.5:
		face = (at - origin).normalized()
		aimed = true
	controls.aim = at
	if not battle.alive():
		return
	var cast: Dictionary = SkillCast.resolve_on_tank(battle, view.pack, slot, id)
	var client: Variant = view.get("client")
	if not cast.is_empty() and client != null:
		client.use_skill(slot, cast.dest, cast.target)



func _draw_picks(view, battle, u: float) -> void :
	var hud: Variant = view.get("_hud")
	var clock: float = float(battle.get("clock")) if battle.get("clock") != null else 0.0
	for index: int in fingers:
		var st: Dictionary = fingers[index]
		var picks: Array = st.get("picks", [])
		if st.kind != "skill" or picks.is_empty():
			continue
		var fire: Vector2 = fire_center(view.size)
		var base_a: float = (st.center - fire).angle()
		var bands: Dictionary = {}
		for p: Dictionary in picks:
			var a: float = wrapf(((p.at as Vector2) - fire).angle() - base_a, - PI, PI)
			var dist: float = ((p.at as Vector2) - fire).length()
			var span: Array = bands.get(roundi(dist / 8.0), [INF, - INF, dist])
			bands[roundi(dist / 8.0)] = [minf(span[0], a), maxf(span[1], a), dist]
		for band: Array in bands.values():
			var lo: float = band[0]
			var hi: float = band[1]
			var radius: float = band[2]
			var pad: float = (PICK_R + 6.0) * u / maxf(1.0, radius)
			if hi - lo < PI:
				view.draw_arc(fire, radius, base_a + lo - pad, base_a + hi + pad, 48, Color(0, 0, 0, 0.3), 2.0 * (PICK_R + 6.0) * u, true)
		var hot: int = int(st.get("pick", 0))
		for p: Dictionary in picks:
			var on: bool = int(p.id) == hot
			var r: float = PICK_R * u * (PICK_HOT if on else 1.0)
			var c: Vector2 = p.at
			var tank: Dictionary = battle.tanks.get(int(p.id), {})
			var side: Color = TouchHeads.FOE if p.enemy else TouchHeads.OWN
			view.draw_circle(c, r + 3.0 * u, Color(0.02, 0.03, 0.06, 0.8))
			view.draw_circle(c, r, Color(0.12, 0.16, 0.24, 0.92))
			var brief: Dictionary = {}
			if hud != null and hud.has_method("brief_of") and not tank.is_empty():
				brief = hud.brief_of(battle, int(tank.get("account", 0)))
			if not brief.is_empty():
				var other: Dictionary = brief.otherData if brief.get("otherData") is Dictionary else {}
				TouchHeads.face_on(view, hud, other, c, r, Color.WHITE if p.ok else TouchHeads.DEAD_TINT, clock)
			if not p.ok:
				view.draw_circle(c, r, TouchHeads.DEAD_VEIL)
			var fill: float = clampf(float(tank.get("hp", 0)) / maxf(1.0, float(tank.get("max_hp", 1))), 0.0, 1.0) if p.ok else 0.0
			view.draw_arc(c, r + 1.5 * u, 0, TAU, 40, Color(side, 0.3), 3.0 * u, true)
			if fill > 0.0:
				view.draw_arc(c, r + 1.5 * u, - PI / 2.0, - PI / 2.0 + TAU * fill, maxi(4, ceili(40 * fill)), side, 3.0 * u, true)
			if on:
				view.draw_arc(c, r + 5.5 * u, 0, TAU, 40, MARK_COLOR, 3.0 * u, true)
				var name: String = str(brief.charData.get("szName", "")) if brief.get("charData") is Dictionary else str(tank.get("name", ""))
				if not name.is_empty() and view.has_method("_label"):
					var fs: int = maxi(10, roundi(13 * u))
					view._label(c + Vector2(-90 * u, - r - 8.0 * u - fs), name, MARK_COLOR, fs, HORIZONTAL_ALIGNMENT_CENTER, 180 * u)
