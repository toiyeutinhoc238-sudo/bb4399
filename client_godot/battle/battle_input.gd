extends RefCounted





const SkillCast = preload("skill_cast.gd")
const FIRE_RETRY: float = 0.06
const RANGE_TIP_TIME: float = 1.0
var direction: int = 8
var firing: bool = false

var auto_fire: bool = false
var aim: Vector2 = Vector2.ZERO
var queued_slots: Array[int] = []

var self_slots: Array[int] = []


var pick_slots: Array[int] = []

var tapped: bool = false

var selected: int = 0

var touch: bool = false

var skill_wait: float = 0.0

var range_tip: float = 0.0
var range_tip_left: float = 0.0
var fire_wait: float = 0.0

var cooling: bool = false


const SAT_THU_ARMED: Array[int] = [322302, 443302, 444302, 458302]
var thrust_queued: bool = false


const SNEAK_KEEP_KAKASHI: Array[int] = [330131, 470131]
const SNEAK_KEEP_NIGHTWING: Array[int] = [390201]


const SNEAK_KEEP_SAT_THU_ROLL: Array[int] = [322303, 443303, 444303, 458303]
var _st1_sneak: Array[int] = []

var hover_tank: int = 0

var avatar_tap: int = 0

var shots: int = 0


const CC1_AIM_HOLD: bool = true
var aim_hold: bool = false





const NTC1_ONE_PER_CLICK: bool = true
var click_sent: int = 0



const NHEN4_CD_GUARD: bool = true
const NHEN4_CD_EPS: float = 0.2

static func direction_for(vector: Vector2) -> int:
	if vector.length() < 0.2:
		return 8
	return posmod(roundi(vector.angle() / (PI / 4.0)) + 3, 8)

func clear() -> void :
	direction = 8
	firing = false
	queued_slots.clear()
	self_slots.clear()
	pick_slots.clear()
	tapped = false
	selected = 0
	skill_wait = 0
	range_tip_left = 0
	fire_wait = 0
	cooling = false
	thrust_queued = false
	hover_tank = 0
	avatar_tap = 0
	aim_hold = false
	click_sent = 0

func queue_skill(slot: int, on_self: bool = false, pick: bool = false) -> void :
	if slot not in queued_slots and queued_slots.size() < 4:
		queued_slots.append(slot)
		if on_self:
			self_slots.append(slot)
		if pick:
			pick_slots.append(slot)


static func _normal_fire(battle, pack: Node, template: int) -> bool:
	if not battle.skills.has(0):
		return template in [1, 17]
	var common: int = int(battle.skills[0].nPropsId)
	if template == common or (template in [1, 17] and common in [1, 17]):
		return true
	if pack == null or template in [1, 17] or common in [1, 17]:
		return false
	var exhibit: int = pack.fire_exhibit(template, 0, false)
	return exhibit > 1 and exhibit == pack.fire_exhibit(common, 0, false)

func tick(delta: float, client: Node, pack: Node = null) -> void :
	var battle = client.battle
	fire_wait = maxf(0, fire_wait - delta)
	skill_wait = maxf(0, skill_wait - delta)
	range_tip_left = maxf(0, range_tip_left - delta)
	if fire_wait <= 0:
		cooling = false
	if not battle.alive():
		queued_slots.clear()
		self_slots.clear()
		pick_slots.clear()
		tapped = false
		selected = 0
		aim_hold = false
		click_sent = 0
		battle.swapped_slots.clear()
		_nhen4_clear(battle)
		range_tip_left = 0
		battle.fire_echoes.clear()
		fire_wait = 0
		cooling = false
		thrust_queued = false
		avatar_tap = 0
		return
	for template: int in battle.fire_echoes:
		if not cooling and _normal_fire(battle, pack, template):
			cooling = true
			fire_wait = float(battle.fire_ms) / 1000.0
	battle.fire_echoes.clear()
	client.move_battle(direction)


	if selected != 0 and ( not battle.skills.has(selected) or _nhen4_cooling(battle, selected) or not battle.swapped_slots.is_empty()
			or SkillCast.recall_armed(battle, selected)):
		selected = 0
	battle.swapped_slots.clear()
	_nhen4_clear(battle)
	while not queued_slots.is_empty():
		var slot: int = queued_slots.pop_front()
		_press(client, battle, pack, slot, slot in self_slots, slot in pick_slots)
	self_slots.clear()
	pick_slots.clear()
	if avatar_tap != 0:
		_avatar_down(client, battle, pack, avatar_tap)
		avatar_tap = 0
	if CC1_AIM_HOLD and not touch and (tapped or not firing):
		aim_hold = false
	if tapped or not firing:
		click_sent = 0

	if _st1_sneak.is_empty():
		for id: int in battle.BUFF_SNEAK:
			if not id in SNEAK_KEEP_SAT_THU_ROLL:
				_st1_sneak.append(id)
	var sneak: bool = battle.tanks.has(battle.self_id) and battle.has_buff(battle.tanks[battle.self_id], _st1_sneak)
	var armed: bool = battle.tanks.has(battle.self_id) and battle.has_buff(battle.tanks[battle.self_id], SAT_THU_ARMED)
	var press: bool = tapped or (firing and ( not sneak or armed))
	if not armed:
		thrust_queued = false
	elif tapped and selected == 0:
		thrust_queued = true
	tapped = false
	if firing and battle.tanks.has(battle.self_id) and (battle.has_buff(battle.tanks[battle.self_id], SNEAK_KEEP_KAKASHI)\
	or battle.has_buff(battle.tanks[battle.self_id], SNEAK_KEEP_NIGHTWING)):
		press = true
	if CC1_AIM_HOLD and not touch:
		if selected != 0 and press:
			aim_hold = true
		elif aim_hold:
			press = false
	if selected != 0:

		if press and skill_wait <= 0 and not (NTC1_ONE_PER_CLICK and not touch and click_sent == selected):
			skill_wait = FIRE_RETRY
			var cast: Dictionary = SkillCast.resolve(battle, pack, selected, aim)
			if not cast.is_empty():
				if client.use_skill(selected, cast.dest, cast.target) and not touch:
					click_sent = selected
			elif SkillCast.missed and fire_wait <= 0 and (touch or not CC1_AIM_HOLD):
				_shoot(client, battle, pack)
		return
	if armed and (press or auto_fire or thrust_queued) and (fire_wait <= 0 or cooling):
		cooling = false
		if _shoot(client, battle, pack):
			thrust_queued = false
	elif (press or auto_fire) and fire_wait <= 0:
		_shoot(client, battle, pack)


func _nhen4_cooling(battle, slot: int) -> bool:
	if not NHEN4_CD_GUARD:
		return battle.cooldown(slot) > 0
	return battle.cooldown(slot) > NHEN4_CD_EPS or ("cooled_slots" in battle and slot in battle.cooled_slots)

func _nhen4_clear(battle) -> void :
	if "cooled_slots" in battle:
		battle.cooled_slots.clear()


func _avatar_down(client: Node, battle, pack: Node, tank_id: int) -> void :
	if selected == 0 and fire_wait > 0:
		return
	var cast: Dictionary = SkillCast.resolve_on_tank(battle, pack, selected, tank_id)
	if cast.is_empty() or not client.use_skill(selected, cast.dest, cast.target) or selected != 0:
		return
	fire_wait = FIRE_RETRY

func _shoot(client: Node, battle, pack: Node) -> bool:
	var shot: Dictionary = SkillCast.resolve(battle, pack, 0, aim)
	if not shot.is_empty() and client.use_skill(0, shot.dest, shot.target):
		shots += 1
		fire_wait = FIRE_RETRY
		return true
	return false

func _smart(client: Node, slot: int) -> bool:
	return touch or client.smart_slot(slot)


func _press(client: Node, battle, pack: Node, slot: int, on_self: bool, pick: bool = false) -> void :
	if not SkillCast.ready(battle, pack, slot, not pick):
		return
	if SkillCast.instant(battle, pack, slot, on_self):
		var now: Dictionary = SkillCast.resolve(battle, pack, slot, aim, on_self)
		if not now.is_empty():
			client.use_skill(slot, now.dest, now.target)
		return
	if selected == slot:
		selected = 0
		return
	selected = slot
	skill_wait = 0
	click_sent = 0
	if (pick and not touch) or not _smart(client, slot):
		return
	var at: Vector2 = aim
	if hover_tank != 0:

		var rule: Variant = SkillCast.rule_of(battle, pack, slot)
		if rule == null or SkillCast._field(rule, 0) != SkillCast.SELECTED_OBJ or not battle.tanks.has(hover_tank):
			return
		at = battle.tanks[hover_tank].pos
	var cast: Dictionary = SkillCast.resolve(battle, pack, slot, at)
	if not cast.is_empty():
		client.use_skill(slot, cast.dest, cast.target)
	var reach: float = SkillCast.out_of_range_tip(SkillCast.rule_of(battle, pack, slot), at, battle.tanks[battle.self_id].pos)
	if reach > 0:
		range_tip = reach
		range_tip_left = RANGE_TIP_TIME
	selected = 0
