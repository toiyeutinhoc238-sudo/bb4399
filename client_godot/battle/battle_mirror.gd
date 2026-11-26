extends RefCounted















const BattleState = preload("battle_state.gd")


const MAPS: Dictionary = {35: Vector2(2412, 2412), 40: Vector2(2184, 1680)}
const CAMP_B: int = 2
const FIX_1562: bool = true
const FIX_1603: bool = true

const OUT: Dictionary = {"MovementMessage.RequestMoveForward": 501, "TankMessage.RequestUseSkill": 503, 
	"SkillMessage.RequestAutoBullet": 510, "SkillMessage.RequestCacheSkillDestPos": 514}

var fix_1562: bool = FIX_1562
var fix_1603: bool = FIX_1603
var size: Vector2 = Vector2.ZERO
var _on: bool = false
var _begun: int = -1
var _look_camp: int = -1


static func opposite(direction: int) -> int:
	return (direction + 4) % 8 if direction >= 0 and direction <= 7 else 8


static func camp(battle: BattleState) -> int:
	if battle.look:
		return int(battle.look_camp_id)
	for brief: Variant in battle.roster:
		if brief is Dictionary and int((brief as Dictionary).get("charData", {}).get("nAcctId", 0)) == int(battle.self_id):
			return int((brief as Dictionary).get("bCamp", 0))
	return 0


func sync(battle: BattleState) -> bool:
	if int(battle.begun) != _begun or int(battle.look_camp_id) != _look_camp:
		_begun = int(battle.begun)
		_look_camp = int(battle.look_camp_id)
		_on = MAPS.has(int(battle.map_id)) and camp(battle) == CAMP_B
	if not _on or not battle.active:
		return false
	size = battle.map.extent if battle.map_loaded and int(battle.map.id) == int(battle.map_id) else MAPS[int(battle.map_id)]
	return true

func _x(value: Variant) -> int:
	return int(size.x) - int(value)

func _y(value: Variant) -> int:
	return int(size.y) - int(value)

func _flip(row: Variant, key_x: String, key_y: String) -> void :
	if not (row is Dictionary):
		return
	var d: Dictionary = row
	if d.has(key_x):
		d[key_x] = _x(d[key_x])
	if d.has(key_y):
		d[key_y] = _y(d[key_y])

func _flip_all(rows: Variant, key_x: String, key_y: String) -> void :
	if rows is Array:
		for row: Variant in rows:
			_flip(row, key_x, key_y)


func receive(battle: BattleState, type: int, v: Dictionary) -> void :
	if not sync(battle):
		return
	match type:
		1550, 1552:
			_flip(v.get("m_selfData"), "m_x", "m_y")
		1551:
			_flip_all(v.get("m_otherList"), "m_x", "m_y")
		1554, 1563, 1569, 1606:
			_flip(v, "m_x", "m_y")
		1555, 1602:
			_flip_all(v.get("m_objVec"), "m_x", "m_y")
		1556:
			_flip(v.get("m_objVec"), "m_x", "m_y")
		1562:

			_flip(v, "m_startX", "m_startY")
			if v.has("m_destX"):
				v["m_destX"] = _x(v.m_destX) if fix_1562 else _y(v.m_destX)
			if v.has("m_destY"):
				v["m_destY"] = _y(v.m_destY)
		1564:

			for move: Variant in v.get("m_moveVec", []):
				_flip(move, "m_x", "m_y")
				if move is Dictionary and (move as Dictionary).has("m_direction"):
					move["m_direction"] = opposite(int(move.m_direction))
			for fire: Variant in v.get("m_fireVec", []):
				_flip(fire, "m_startX", "m_startY")
				_flip(fire, "m_destX", "m_destY")
			for skill: Variant in v.get("m_skillVec", []):
				_flip(skill, "m_StartX", "m_StartY")
				_flip(skill, "m_x", "m_y")
		1566:
			_flip(v.get("m_killInfo"), "m_dead_x", "m_dead_y")
		1578:
			_flip(v, "m_iStartX", "m_iStartY")
			_flip(v, "m_iDestX", "m_iDestY")
		1585:
			_flip(v, "m_posX", "m_posY")
		1603:
			if fix_1603:
				_flip(v, "m_destX", "m_destY")


func send(battle: BattleState, short_name: String, fields: Dictionary) -> Dictionary:
	if not OUT.has(short_name) or not sync(battle):
		return fields
	var out: Dictionary = fields.duplicate()
	match int(OUT[short_name]):
		501:
			if out.has("m_start_x"):
				out["m_start_x"] = clampi(_x(out.m_start_x), 0, 65535)
			if out.has("m_start_y"):
				out["m_start_y"] = clampi(_y(out.m_start_y), 0, 65535)
			if out.has("m_direction"):
				out["m_direction"] = opposite(int(out.m_direction))
		510:
			for key: String in ["m_startX", "m_destX"]:
				if out.has(key):
					out[key] = clampi(_x(out[key]), -32768, 32767)
			for key: String in ["m_startY", "m_destY"]:
				if out.has(key):
					out[key] = clampi(_y(out[key]), -32768, 32767)
		_:
			if out.has("m_destX"):
				out["m_destX"] = clampi(_x(out.m_destX), -32768, 32767)
			if out.has("m_destY"):
				out["m_destY"] = clampi(_y(out.m_destY), -32768, 32767)
	return out


func point(battle: BattleState, pos: Vector2) -> Vector2:
	if not sync(battle):
		return pos
	return Vector2(_x(int(pos.x)), _y(int(pos.y)))
