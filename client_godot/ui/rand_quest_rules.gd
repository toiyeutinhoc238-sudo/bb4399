extends RefCounted







const Atlas = preload("rand_quest_atlas.gd")

const INIT: int = 34
const SELECT: Array = [35, 37, 38, 39, 40]
const GUILD: int = 39
const RESEARCH: int = 40
const GOING: int = 2
const COMPLETE: int = 3
const OVER: int = 4
const LIMIT: int = 240
const SLOTS: Array = [0, 1, 2, 4, 3]
const FPS: float = 24.0


static func template(id: int) -> Array:
	var row: Variant = Atlas.QUESTS.get(str(id))
	return row if row is Array else []

static func _ids(quests: Dictionary) -> Array:
	var out: Array = []
	for key: Variant in quests:
		out.append(int(key))
	out.sort()
	return out


static func init_id(quests: Dictionary) -> int:
	var found: int = 0
	for id: int in _ids(quests):
		var row: Array = template(id)
		if not row.is_empty() and int(row[0]) == INIT:
			found = id
	return found


static func slot_ids(quests: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for id: int in _ids(quests):
		var row: Array = template(id)
		if not row.is_empty() and SELECT.has(int(row[0])):
			out[int(row[1])] = id
	return out

static func open(quests: Dictionary) -> bool:
	return init_id(quests) > 0

static func state_of(quests: Dictionary, id: int) -> int:
	var info: Variant = quests.get(id)
	return int(info[0]) if info is Array and not (info as Array).is_empty() else 0


static func has_award(quests: Dictionary) -> bool:
	if state_of(quests, init_id(quests)) == COMPLETE:
		return true
	var slots: Dictionary = slot_ids(quests)
	for slot: Variant in slots:
		if state_of(quests, int(slots[slot])) == COMPLETE:
			return true
	return false


static func refresh_left(limits: Dictionary, most: int = Atlas.REFRESH_MAX) -> int:
	return maxi(0, most - int(limits.get(LIMIT, 0)))


static func cvs_id(quests: Dictionary, cvs: int) -> int:
	if cvs == 0:
		return init_id(quests)
	return int(slot_ids(quests).get(int(SLOTS[cvs]), 0))


static func item_state(quests: Dictionary, id: int, guild_id: int) -> String:
	var row: Array = template(id)
	if row.is_empty() or not quests.has(id):
		return ""
	if int(row[0]) == GUILD and guild_id == 0:
		return "NOCORP"
	match state_of(quests, id):
		COMPLETE:
			return "CANAWARD"
		OVER:
			return "GETAWARD"
	return "NOAWARD"



static func order(quests: Dictionary) -> Array:
	var ids: Array = []
	var cvs_of: Dictionary = {}
	for cvs: int in 5:
		var id: int = cvs_id(quests, cvs)
		ids.append(id)
		cvs_of[id] = cvs

	for i: int in range(1, ids.size()):
		var key: int = ids[i]
		var j: int = i - 1
		while j >= 0 and compare(quests, ids[j], key) > 0:
			ids[j + 1] = ids[j]
			j -= 1
		ids[j + 1] = key
	var out: Array = []
	for id: int in ids:
		var cvs: int = int(cvs_of[id])
		if not out.has(cvs):
			out.append(cvs)
	return out


static func compare(quests: Dictionary, a: int, b: int) -> int:
	if not quests.has(a):
		return 1
	if not quests.has(b):
		return -1
	var sa: int = state_of(quests, a)
	var sb: int = state_of(quests, b)
	if sa == sb or (sa <= GOING and sb <= GOING):
		var ta: Array = template(a)
		var tb: Array = template(b)
		if ta.is_empty() or int(ta[0]) == GUILD:
			return 1
		if tb.is_empty() or int(tb[0]) == GUILD:
			return -1
		return -1 if int(ta[0]) < int(tb[0]) else 1
	if sa == OVER:
		return 1
	if sb == OVER:
		return -1
	if sa == COMPLETE:
		return -1
	if sb == COMPLETE:
		return 1
	return -1


static func frame(seconds: float) -> int:
	return int(maxf(0.0, seconds) * FPS) % maxi(1, int(Atlas.FRAMES))
