extends RefCounted












const LeftGlow = preload("left_glow.gd")
const GarageModel = preload("garage_model.gd")
const HelperModel = preload("helper_model.gd")
const MORE: String = "!"
const TEMP: int = 8
const SOON: int = 72 * 3600
const DAY: int = 86400
const TIME_START: int = 4
const AVATAR_CARD: int = 32
const T_TYPE: int = 4
const NUM_SIDE: float = 25.0
const TANK_DOT: Vector2 = Vector2(422, 0)
const PACKAGE_DOT: Vector2 = Vector2(593, 0)
const HELPER_NUM: Vector2 = Vector2(500, 2)
const QUEST_NUM: Vector2 = Vector2(664, 2)


static func quest_count(quests: Dictionary, templates: Dictionary) -> int:
	if templates.is_empty():
		return 0
	var count: int = 0
	for key: Variant in quests:
		var info: Variant = quests[key]
		if not (info is Array) or (info as Array).is_empty() or int(info[0]) != LeftGlow.QUEST_DONE:
			continue
		var row: Variant = templates.get(str(int(key)))
		if row is Array and (row as Array).size() > LeftGlow.T_SHOW and int(row[LeftGlow.T_SHOW]) == 1\
		and LeftGlow.QUEST_TYPES.has(int(row[LeftGlow.T_TYPE])):
			count += 1
	return count

static func quest_label(count: int) -> String:
	return MORE if count > 9 else str(count)


static func battle_tank(tanks: Dictionary) -> Dictionary:
	for inst: Variant in tanks.values():
		if inst is Dictionary and int((inst as Dictionary).get("m_extFlag", 0)) & GarageModel.JOIN_BATTLE:
			return inst
	return {}


static func tank_up(tanks: Dictionary, garage: Dictionary, bags: Dictionary) -> bool:
	var inst: Dictionary = battle_tank(tanks)
	if inst.is_empty() or garage.is_empty() or int(inst.get("m_contType", 0)) == GarageModel.HIRE:
		return false
	var plan: Dictionary = GarageModel.progress(garage, int(inst.get("m_tpltId", 0)), inst)
	if plan.mode == "max" or (plan.mode == "up" and (plan.cost as Array).is_empty()):
		return false
	return GarageModel.affordable(bags, plan.cost)


static func temp_items(bags: Dictionary) -> bool:
	return not bags.get(TEMP, []).is_empty()



static func soon(inst: Dictionary, now: int) -> bool:
	var life: int = int(inst.get("m_lifeTime", 0))
	if life <= 0:
		return false
	if int(inst.get("m_extFlag", 0)) & TIME_START:
		var left: int = life - now
		return left >= 0 and left <= SOON
	return life * DAY <= SOON



static func expiring(bags: Dictionary, items: Dictionary, now: int) -> int:
	var waiting: bool = false
	for cont: int in [3, 2]:
		for inst: Variant in bags.get(cont, []):
			if not (inst is Dictionary) or not soon(inst, now):
				continue
			if items.is_empty():
				waiting = true
				continue
			var row: Variant = items.get(str(int((inst as Dictionary).get("m_templateId", 0))))
			if row is Array and (row as Array).size() > T_TYPE and int(row[T_TYPE]) != AVATAR_CARD:
				return 1
	return -1 if waiting else 0



static func helper_up(bags: Dictionary, data: Dictionary, battle: String) -> bool:
	if battle.is_empty() or data.is_empty():
		return false
	var rec: Dictionary = {}
	for inst: Variant in bags.get(5, []):
		if inst is Dictionary and str((inst as Dictionary).get("m_itemUuid", "")) == battle:
			rec = HelperModel.record(inst, data, {}, battle)
			break
	if rec.is_empty():
		return false
	if int(rec.lv) < int(rec.lv_max):
		var total: int = 0
		for chip: Dictionary in HelperModel.chips(bags, data):
			total += int(chip.gain) * int(chip.have)
		if total >= HelperModel.exp_need(data, int(rec.lv)) - int(rec.exp):
			return true
	if int(rec.up) < int(rec.up_max) and _has_next(bags, data, 1, int(rec.up) + 1):
		return true
	return int(rec.rank) < int(rec.rank_max) and _has_next(bags, data, 2, int(rec.rank) + 1)


static func _has_next(bags: Dictionary, data: Dictionary, kind: int, level: int) -> bool:
	var row: Array = HelperModel.consume(data, kind, level)
	return not row.is_empty() and HelperModel.have(bags, int(row[0])) > 0
