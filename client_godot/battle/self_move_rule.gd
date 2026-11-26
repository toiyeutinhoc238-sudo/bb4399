extends RefCounted









const EDGE: float = 72.0
const RETRY: float = 0.15
const GHOST: int = 20001
const GHOST_EDGE: float = 61.0



const NO_COLLIDE: Array[int] = [392302, 402, 403, 406, 104401, 511111, 309207, 309210, 309215, 402207, 402210, 402215, 321202, 321205, 
	321303, 621202, 621205, 621303, 322304, 443304, 444304, 458304, 469210, 332210, 339204, 339206, 341201, 341202, 341203, 442201, 442202, 
	442203, 344206, 450206, 471206, 348204, 460204, 461204, 648204, 354126, 481126, 482126, 356303, 485303, 486303, 357208, 487208, 488208, 
	371123, 371124, 612123, 612124, 971123, 971124, 372102, 372103, 614102, 614103, 374413, 674413, 375101, 375102, 675101, 675102, 380214, 380215, 380302, 
	680214, 680215, 680302, 382304, 407321, 439204, 439206, 472204, 472206, 390104, 391214, 330135, 330310, 470135, 470310, 972102, 972103, 
	974413, 991214]


var retry_at: float = -1.0

var blocked_dir: int = -1

var hit: bool = false

func reset() -> void :
	retry_at = -1.0
	blocked_dir = -1
	hit = false



func waiting(direction: int, clock: float) -> bool:
	return direction == blocked_dir and clock < retry_at


func settle(direction: int, moved: bool, clock: float) -> void :
	if hit and clock >= retry_at:
		retry_at = clock + RETRY
	blocked_dir = direction if hit and not moved else -1
	hit = false



static func no_collide(tank: Dictionary) -> bool:
	for buff: Dictionary in tank.get("buffs", {}).values():
		var id: int = int(buff.get("m_nBuffTpltId", 0))
		if id in NO_COLLIDE and not id in ONE_WAY:
			return true
	return false



const ONE_WAY: Array[int] = [402, 403, 406]


static func phases(tank: Dictionary) -> bool:
	return no_collide(tank)


static func item_ghost(tank: Dictionary) -> bool:
	for buff: Dictionary in tank.get("buffs", {}).values():
		if int(buff.get("m_nBuffTpltId", 0)) in ONE_WAY:
			return true
	return false




const HAPPY_NPC_BLOCK: Dictionary = {81: [2421, 2422, 2424], 80: [2404, 2405, 2406, 2407, 2408, 2409]}
static func blocked_by_happy_npc(center: Vector2, from: Vector2, me: Dictionary, npcs: Dictionary, map_id: int) -> bool:
	var list: Array = HAPPY_NPC_BLOCK.get(map_id, [])
	if list.is_empty() or me.is_empty() or phases(me) or item_ghost(me):
		return false
	for npc: Dictionary in npcs.values():
		if not int(npc.get("template", 0)) in list or npc.get("dead", false) or int(npc.get("hp", 1)) == 0:
			continue
		var at: Vector2 = npc.get("pos", Vector2.INF)
		var d: Vector2 = at - center
		if absf(d.x) >= GHOST_EDGE or absf(d.y) >= GHOST_EDGE:
			continue
		var s: Vector2 = at - from
		if absf(s.x) < GHOST_EDGE and absf(s.y) < GHOST_EDGE and d.length_squared() >= s.length_squared():
			continue
		return true
	return false




static func blocked_by_ghost(center: Vector2, from: Vector2, me: Dictionary, npcs: Dictionary, ffa: bool = false) -> bool:
	if me.is_empty() or no_collide(me) or item_ghost(me):
		return false
	var my_id: int = int(me.get("id", 0))
	var my_camp: int = int(me.get("camp", 0))
	for npc: Dictionary in npcs.values():
		var owner: int = int(npc.get("owner", 0))
		if int(npc.get("template", 0)) != GHOST or owner == 0 or owner == my_id or npc.get("dead", false) or int(npc.get("hp", 1)) <= 0 or ( not ffa and int(npc.get("camp", 0)) == my_camp):
			continue
		var at: Vector2 = npc.get("pos", Vector2.INF)
		var d: Vector2 = at - center
		if absf(d.x) >= GHOST_EDGE or absf(d.y) >= GHOST_EDGE:
			continue
		var s: Vector2 = at - from
		if absf(s.x) < GHOST_EDGE and absf(s.y) < GHOST_EDGE and d.length_squared() >= s.length_squared():
			continue
		return true
	return false





static func blocked_by_tank(center: Vector2, from: Vector2, me: Dictionary, tanks: Dictionary, gone: Callable, ffa: bool = false) -> bool:
	if me.is_empty() or no_collide(me) or item_ghost(me):
		return false
	var my_id: int = int(me.get("id", 0))
	var my_camp: int = int(me.get("camp", 0))
	for other: Dictionary in tanks.values():
		if int(other.get("id", 0)) == my_id or ( not ffa and int(other.get("camp", 0)) == my_camp) or int(other.get("hp", 1)) <= 0 or no_collide(other):
			continue
		if other.get("dead", false) or (gone.is_valid() and gone.call(other)):
			continue
		var at: Vector2 = other.get("pos", Vector2.INF)
		var d: Vector2 = at - center
		if absf(d.x) >= EDGE or absf(d.y) >= EDGE:
			continue
		var s: Vector2 = at - from

		if absf(s.x) < EDGE and absf(s.y) < EDGE and d.length_squared() >= s.length_squared():
			continue
		return true
	return false
