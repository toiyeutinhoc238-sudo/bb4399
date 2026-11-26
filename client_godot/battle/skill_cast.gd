extends RefCounted
const Mp = preload("res://battle/mp_use.gd")





const SELF_TYPES: Array[int] = [0, 2, 4, 5, 6, 7, 8, 9, 12, 13]
const SELECTED_OBJ: int = 3




const CURSOR_SELF: Array[int] = [371301, 612301, 971301, 333301]

const CHARGE_RECAST: Array[int] = [316101]



const TTE2_RECALL: Array[int] = [353201, 477201, 478201]

const TARGET_OR_POINT: Array[int] = [316201]
const GUIDE_TYPES: Array[int] = [0, 1, 10, 11]
const RANGE_LINE: int = 1
const RANGE_SECTOR: int = 2
const RANGE_DOT: int = 3
const RANGE_DESPOS_LINE: int = 5
const RANGE_VERTICAL: int = 6
const SSL_TEAMMATE: int = 1
const SSL_ENEMY: int = 2
const SSL_TANK: int = 4
const SSL_NOT_SELF: int = 8
const SSL_NO_SELF_BUFF: int = 64
const SSL_HAS_SELF_BUFF: int = 128
const SSL_NO_BUFF: int = 512
const SSL_HAS_BUFF: int = 1024
const BHT_COLLIDE: int = 1
const TANK_HALF: float = 36.0
const ARROW_WIDTH: float = 48.0
const ARROW_LENGTH: float = 165.0
const DEST_OFFSET: float = 60.0

const BAN_ALL: Array[int] = [1, 2, 4, 10, 13]
const BAN_BITS: Dictionary = {2: [1], 4: [2], 8: [10], 16: [4, 13]}
const TIP_CD: String = "Kỹ năng đang hồi"
const TIP_MP: String = "Không đủ năng lượng"
const TIP_BAN: String = "Hiện không thể dùng kỹ năng"
const TIP_DISTANCE: String = "Ngoài tầm thi triển"
const TIP_ENEMY: String = "Hãy chọn mục tiêu là kẻ địch"
const TIP_SELF: String = "Hãy chọn mục tiêu là phe mình"
const TIP_TARGET: String = "Mục tiêu không hợp lệ"
const TIP_GAP: float = 1.0
const TouchGfx = preload("touch_gfx.gd")
const BattleState = preload("battle_state.gd")

static var _last_tip: Dictionary = {}

static var missed: bool = false



static func _tip(battle, text: String) -> Dictionary:
	if TouchGfx.touch_device():
		return {}
	var now: float = float(Time.get_ticks_msec()) / 1000.0
	if now - float(_last_tip.get(text, -100.0)) >= TIP_GAP:
		_last_tip[text] = now
		battle.tip(text)
	return {}

const UNSTOPPABLE_E: Array[int] = [301201, 404201]



const BAN_GRACE: float = 1.0
const BAN_FOREVER: float = 2147483.0
static func _ban_stale(battle, buff: Dictionary) -> bool:
	var exist: float = float(buff.get("exist", 0.0))
	if exist <= 0 or exist >= BAN_FOREVER or not buff.has("t0") or not ("clock" in battle):
		return false
	return float(battle.clock) - float(buff.t0) > exist + BAN_GRACE

static func banned(battle, pack: Node, slot: int) -> bool:
	if pack == null or slot == 0 or not battle.tanks.has(battle.self_id):
		return false

	if slot == 1 and battle.skills.has(1) and int(battle.skills[1].nPropsId) in UNSTOPPABLE_E:
		return false
	for buff: Dictionary in battle.tanks[battle.self_id].get("buffs", {}).values():
		var bits: int = pack.ban_bits(int(buff.get("m_nBuffTpltId", 0)))
		if bits < 0 or _ban_stale(battle, buff):
			continue
		if bits == 0:
			return slot in BAN_ALL
		for bit: int in BAN_BITS:
			if bits & bit and slot in BAN_BITS[bit]:
				return true
	return false

static func _mp_lack(battle, pack: Node, slot: int) -> bool:
	if pack == null or not battle.skills.has(slot):
		return false


	if not Mp.uses(battle.tanks[battle.self_id]):
		return false
	var info: Array = pack.skill_hud(int(battle.skills[slot].nPropsId))
	return info.size() >= 4 and int(battle.tanks[battle.self_id].get("mp", 0)) < int(info[3])




static func ready(battle, pack: Node, slot: int, key: bool = false) -> bool:
	if not battle.alive() or not battle.tanks.has(battle.self_id):
		return false
	if key and ((slot == 2 and (banned(battle, pack, slot) or battle.ex_locked())) or (slot == 1 and banned(battle, pack, slot))):
		_tip(battle, TIP_BAN)
		return false
	if not battle.skills.has(slot):
		return false
	if slot != 0:
		if battle.cooldown(slot) > 0:
			return false
		if _mp_lack(battle, pack, slot):
			_tip(battle, TIP_MP)
			return false
		if banned(battle, pack, slot):
			_tip(battle, TIP_BAN)
			return false
	return true


static func rule_of(battle, pack: Node, slot: int) -> Variant:
	return pack.skill_cast(int(battle.skills[slot].nPropsId)) if pack != null and battle.skills.has(slot) else null




static func recall_armed(battle, slot: int) -> bool:
	if slot != 1 or not battle.skills.has(1) or not "npcs" in battle:
		return false
	var id: int = int(battle.skills[1].nPropsId)
	if id not in TTE2_RECALL:
		return false
	for npc: Dictionary in battle.npcs.values():
		if int(npc.get("template", 0)) == id and int(npc.get("owner", 0)) == int(battle.self_id) and not npc.get("dead", false):
			return true
	return false

static func instant(battle, pack: Node, slot: int, on_self: bool) -> bool:
	if recall_armed(battle, slot):
		return true
	var rule: Variant = rule_of(battle, pack, slot)
	if rule == null:
		return true
	return _field(rule, 0) in SELF_TYPES or (on_self and _can_use_on_self(rule))


static func guide_range(rule: Variant) -> float:
	if rule == null or _field(rule, 3) <= 0:
		return 0.0
	return float(_field(rule, 3)) + (TANK_HALF if _field(rule, 7) == RANGE_SECTOR else 0.0)


static func out_of_range_tip(rule: Variant, aim: Vector2, me_pos: Vector2) -> float:
	var reach: float = guide_range(rule)
	if reach <= 0 or _field(rule, 4) != 1 or aim.distance_squared_to(me_pos) <= reach * reach:
		return 0.0
	return reach







const STME4_EXACT_DOT: Array[int] = [377201, 677201]

static func stme4_skill(battle, slot: int) -> int:
	return int(battle.skills[slot].nPropsId) if battle != null and battle.skills.has(slot) else 0

static func guide_shape(rule: Variant, me: Vector2, aim: Vector2, skill: int = 0) -> PackedVector2Array:
	var shape: PackedVector2Array = PackedVector2Array()
	var reach: float = guide_range(rule)
	if reach <= 0 or not _field(rule, 0) in GUIDE_TYPES:
		return shape
	var gap: Vector2 = aim - me
	var dir: Vector2 = gap.normalized() if gap.length() > 0.5 else Vector2.UP
	var area: float = float(_field(rule, 2))
	var param: float = float(_field(rule, 8))
	match _field(rule, 7):
		RANGE_DOT:
			if param > 0 and area > 0:
				shape = _arrow(me, dir, param, area)
			elif skill in STME4_EXACT_DOT:
				shape = _arrow(me, dir, ARROW_WIDTH, minf(gap.length(), reach))
			else:
				shape = _arrow(me, dir, ARROW_WIDTH, clampf(gap.length(), ARROW_LENGTH, maxf(reach, ARROW_LENGTH)))
		RANGE_LINE, RANGE_DESPOS_LINE:
			if param == 0:
				shape = _arrow(me, dir, ARROW_WIDTH, reach)
			elif area > 0:
				var side: Vector2 = dir.orthogonal() * param / 2.0
				shape = PackedVector2Array([me - side, me + dir * area - side, me + dir * area + side, me + side])
		RANGE_SECTOR:
			if param > 0 and area > 0:
				var apex: Vector2 = me + dir * TANK_HALF
				shape.append(apex)
				for step: int in range(0, int(param) + 1, 3):
					shape.append(apex + dir.rotated(deg_to_rad(float(step) - param / 2.0)) * area)
		RANGE_VERTICAL:
			if param > 0:
				var half: Vector2 = dir.orthogonal() * param / 2.0
				var thick: Vector2 = dir * 14.0
				shape = PackedVector2Array([aim - half - thick, aim + half - thick, aim + half + thick, aim - half + thick])
	return shape




static func select_circle(rule: Variant) -> float:
	if rule == null or _field(rule, 7) != 0 or not _field(rule, 0) in [1, SELECTED_OBJ]:
		return 0.0
	return float(maxi(_field(rule, 2), 0))





const LAND_MIN: float = TANK_HALF * 1.2
static func landing_radius(rule: Variant) -> float:
	var r: float = select_circle(rule)
	if r > 0 and _field(rule, 0) == 1 and (r < float(_field(rule, 3)) or _field(rule, 3) <= 0):
		return r
	return LAND_MIN




static func draw_select_circle(canvas: Object, c: Vector2, r: float, tint: Color = Color(0, 0, 0, 0), soft: bool = true) -> void :
	if r <= 0:
		return
	var band: Color = tint if tint.a > 0 else Color("439ead")
	var rim: Color = tint if tint.a > 0 else Color("51b8c7")
	var lit: Color = tint if tint.a > 0 else Color("08e4f9")
	var core: Color = tint if tint.a > 0 else Color("0cd2e5")
	var k: float = r / 226.0
	var segs: int = clampi(int(r / 4.0), 24, 96)
	if soft:
		canvas.draw_arc(c, r * 0.905, 0, TAU, segs, Color(band, 0.18), r * 0.05)
		canvas.draw_arc(c, r * 0.935, 0, TAU, segs, Color(band, 0.45), r * 0.03)
	canvas.draw_arc(c, r * 0.97, 0, TAU, segs, rim, maxf(1.0, 1.5 * k), true)
	canvas.draw_arc(c, r, 0, TAU, segs, rim, maxf(1.5, 3.0 * k), true)
	for q: int in 4:
		var a0: float = q * PI / 2.0
		canvas.draw_arc(c, r * 0.885, a0 + 0.06, a0 + 0.75, maxi(6, segs / 8), Color(lit, 0.35), maxf(1.5, 6.0 * k), true)
		canvas.draw_arc(c, r * 0.885, a0 + 0.75, a0 + 1.5, maxi(6, segs / 8), Color(lit, 0.9), maxf(1.5, 6.0 * k), true)
		var u: Vector2 = Vector2.from_angle(a0)
		canvas.draw_line(c + u * r * 0.05, c + u * r * 0.89, Color(lit, 0.55), maxf(1.0, 2.0 * k), true)
		var v: Vector2 = Vector2.from_angle(a0 + PI / 4.0)
		canvas.draw_line(c + v * r * 0.42, c + v * r * 0.8, Color(lit, 0.6), maxf(1.0, 1.5 * k), true)
	var dot: float = maxf(3.0, 7.0 * k)
	canvas.draw_colored_polygon(PackedVector2Array([c + Vector2(0, - dot), c + Vector2(dot, 0), c + Vector2(0, dot), c + Vector2( - dot, 0)]), core)


static func _arrow(from: Vector2, dir: Vector2, width: float, length: float) -> PackedVector2Array:
	var side: Vector2 = dir.orthogonal() * width / 2.0
	var neck: Vector2 = from + dir * maxf(length - minf(width, length * 0.4), 0.0)
	return PackedVector2Array([from - side, neck - side, from + dir * length, neck + side, from + side])


static func resolve(battle, pack: Node, slot: int, aim: Vector2, on_self: bool = false) -> Dictionary:
	missed = false
	if not ready(battle, pack, slot):
		return {}
	if recall_armed(battle, slot):
		return {"dest": aim, "target": 0}
	var rule: Variant = rule_of(battle, pack, slot)
	if rule == null:
		return {"dest": aim, "target": 0}
	var stype: int = _field(rule, 0)
	var me: Dictionary = battle.tanks[battle.self_id]
	if slot != 0 and stype in SELF_TYPES:
		var aimed: bool = int(battle.skills[slot].nPropsId) in CURSOR_SELF and aim != Vector2.ZERO and aim.distance_squared_to(me.pos) > 1.0
		return {"dest": aim if aimed else Vector2.ZERO, "target": 0}
	if slot != 0 and on_self and _can_use_on_self(rule):
		return {"dest": me.pos, "target": int(battle.self_id)}
	if stype == SELECTED_OBJ:
		return _target_fire(battle, rule, aim, me)

	if _out_of_range(rule, aim, me):
		missed = true
		return _tip(battle, TIP_DISTANCE)
	if _field(rule, 5) & BHT_COLLIDE and _in_own_rect(aim, me):
		return {"dest": _offset_dest(aim, me), "target": 0}
	return {"dest": aim, "target": 0}

static func _field(rule: Array, index: int) -> int:
	return int(rule[index]) if index < rule.size() else 0

static func _can_use_on_self(rule: Array) -> bool:
	var stype: int = _field(rule, 0)
	var limit: int = _field(rule, 1)
	return stype == 0 or (stype == SELECTED_OBJ and limit & SSL_TEAMMATE and not limit & SSL_NOT_SELF)

static func _out_of_range(rule: Array, aim: Vector2, me: Dictionary) -> bool:
	var reach: float = float(_field(rule, 3))
	return _field(rule, 4) != 0 and aim.distance_squared_to(me.pos) > reach * reach

static func _in_own_rect(point: Vector2, me: Dictionary) -> bool:
	return absf(point.x - me.pos.x) <= TANK_HALF and absf(point.y - me.pos.y) <= TANK_HALF

static func _offset_dest(aim: Vector2, me: Dictionary) -> Vector2:
	var angle: float = atan2(aim.y - me.pos.y, aim.x - me.pos.x)
	return me.pos + Vector2(cos(angle), sin(angle)) * DEST_OFFSET


static func _same_camp(battle, tank: Dictionary) -> bool:
	var camp: int = battle.self_camp()
	if not battle.happy.is_empty() or camp == 0:
		return int(tank.id) == int(battle.self_id)
	return int(tank.camp) == camp


static func _selectable(battle, tank: Dictionary, limit: int) -> bool:
	if tank.dead:
		return false
	if limit & SSL_NOT_SELF and int(tank.id) == int(battle.self_id):
		return false
	var same: bool = _same_camp(battle, tank)
	if limit & SSL_TEAMMATE and same:
		return true
	return bool(limit & SSL_ENEMY) and not same and not tank.get("hidden", false)

static func _npc_camps_ok(battle, npc: Dictionary, limit: int) -> bool:
	var camp: int = battle.self_camp()
	if limit & SSL_TEAMMATE and int(npc.camp) == camp:
		return true
	return bool(limit & SSL_ENEMY) and (int(npc.camp) != camp or not battle.happy.is_empty())

static func _has_buff(obj: Dictionary, template: int, caster: int = 0) -> bool:
	for buff: Dictionary in obj.get("buffs", {}).values():
		if int(buff.get("m_nBuffTpltId", 0)) == template and (caster == 0 or int(buff.get("m_nCasterId", 0)) == caster):
			return true
	return false



static func _target_fire(battle, rule: Array, aim: Vector2, me: Dictionary) -> Dictionary:
	var limit: int = _field(rule, 1)
	var reach: float = float(_field(rule, 2) + 36)
	var best: float = reach * reach
	var target: Dictionary = {}
	for tank: Dictionary in battle.tanks.values():
		if not _selectable(battle, tank, limit):
			continue
		var gap: float = tank.pos.distance_squared_to(aim)
		if gap < best:
			best = gap
			target = tank
	if target.is_empty():
		var npc_hit: Dictionary = {}

		for npc: Dictionary in battle.npcs.values() if not limit & SSL_TANK else []:
			if int(npc.id) >> 26 != 5 or BattleState.pass_ainpc(int(npc.id), npc) or npc.dead or npc.get("hidden", false) or not _npc_camps_ok(battle, npc, limit):
				continue
			if absf(npc.pos.x - aim.x) < TANK_HALF and absf(npc.pos.y - aim.y) < TANK_HALF:
				npc_hit = npc
				break
		if npc_hit.is_empty():
			missed = true
			if _out_of_range(rule, aim, me):
				return _tip(battle, TIP_DISTANCE)
			return _tip(battle, TIP_ENEMY if limit & SSL_ENEMY else TIP_SELF)
		target = npc_hit
	if not _buff_ok(battle, rule, target):
		return _tip(battle, TIP_TARGET)
	var dest: Vector2 = target.pos
	if _in_own_rect(aim, me):
		dest = _offset_dest(aim, me)
	return {"dest": dest, "target": int(target.id)}


static func _buff_ok(battle, rule: Array, target: Dictionary) -> bool:
	var limit: int = _field(rule, 1)
	var param: int = _field(rule, 6)
	if limit & SSL_NO_SELF_BUFF and _has_buff(target, param, int(battle.self_id)):
		return false
	if limit & SSL_HAS_SELF_BUFF and not _has_buff(target, param, int(battle.self_id)):
		return false
	if limit & SSL_NO_BUFF and _has_buff(target, param):
		return false
	if limit & SSL_HAS_BUFF and not _has_buff(target, param):
		return false
	return true




static func resolve_on_tank(battle, pack: Node, slot: int, tank_id: int) -> Dictionary:
	missed = false
	if not ready(battle, pack, slot):
		return {}
	var rule: Variant = rule_of(battle, pack, slot)
	if rule == null or _field(rule, 0) != SELECTED_OBJ:
		return {}
	var tank: Dictionary = battle.tanks.get(tank_id, {})
	if tank.is_empty():
		return {}
	var me: Dictionary = battle.tanks[battle.self_id]
	if _out_of_range(rule, tank.pos, me):
		return _tip(battle, TIP_DISTANCE)
	var limit: int = _field(rule, 1)
	if not _selectable(battle, tank, limit):
		var same: bool = _same_camp(battle, tank)
		if limit & SSL_ENEMY and same:
			return _tip(battle, TIP_ENEMY)
		if not limit & SSL_ENEMY and not same:
			return _tip(battle, TIP_SELF)
		return {}
	if not _buff_ok(battle, rule, tank):
		return _tip(battle, TIP_TARGET)
	var dest: Vector2 = tank.pos
	if _in_own_rect(tank.pos, me):
		dest = _offset_dest(tank.pos, me)
	return {"dest": dest, "target": int(tank.id)}
