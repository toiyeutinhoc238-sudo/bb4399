extends RefCounted



const BagModel = preload("bag_model.gd")
const Text = preload("../i18n.gd")




const FAMULUS_ROOMS: Array = [3, 4, 7, 12, 14, 51]
const MODE_5_PVE: int = 8

const TYPES: Dictionary = {1: "Bảo tiêu", 2: "Thủ hộ", 3: "Thiên sứ áo trắng", 4: "Kẻ kích động", 5: "Phá hoại thủ", 6: "Đột kích thủ"}

const STATS: Array = [[4, "Máu"], [1, "Tấn công"], [2, "Xuyên giáp"], [3, "Phòng thủ"]]
const STAT_INDEX: Dictionary = {1: 5, 2: 6, 3: 7, 4: 8}
const RATE: float = 10000000.0
const EXP_CHIP: int = 37
const CRYSTAL: int = 38
const NANO: int = 39
const MEMORY: int = 40
const CORE: int = 41
const MEMORY_ITEM: int = 4000001
const NANO_SLOTS: int = 3
const NANO_TWO: int = 2000000
const NANO_THREE: int = 6000000


static func famulus_game(room_type: int, maps: Array) -> bool:
	for map: Variant in maps:
		if int(map) > 0 and int(Text.map_info(int(map)).get("modeType", 0)) == MODE_5_PVE:
			return false
	return room_type in FAMULUS_ROOMS


static func record(inst: Dictionary, data: Dictionary, bag: Dictionary, battle: String) -> Dictionary:
	var item: int = int(inst.get("m_templateId", 0))
	var t: Array = data.get("tpl", {}).get(str(item), [])
	if t.size() < 15:
		return {}
	var more: Array = bag.get("more", {}).get(str(item), [])
	var uuid: String = str(inst.get("m_itemUuid", ""))
	var apt: int = int(t[1])
	var rec: Dictionary = {"slot": int(inst.get("m_slotNo", -1)), "uuid": uuid, "item": item, "tpl": t, 
		"name": BagModel.clean(str(more[0])) if more.size() >= 4 else "Trợ thủ %d" % item, 
		"icon": "l/it/%s.webp" % str(more[1]) if more.size() >= 4 and not str(more[1]).is_empty() else "", 
		"type": int(t[0]), "apt": apt, "lv_max": int(t[2]), "rank_max": int(t[3]), "up_max": int(t[4]), 
		"lv": int(inst.get("m_level", 0)), "exp": int(inst.get("m_exp", 0)), "up": int(inst.get("m_upLevel", 0)), 
		"upc": int(inst.get("m_upCost", 0)), "rank": int(inst.get("m_rank", 0)), "rankc": int(inst.get("m_rankCost", 0)), 
		"battle": not uuid.is_empty() and uuid == battle, "created": int(inst.get("m_createTime", 0))}
	var q: int = int(more[2]) if more.size() >= 4 else 0
	rec["quality"] = q if q > 0 else quality(apt)
	rec["score"] = score(rec, data)
	return rec


static func quality(apt: int) -> int:
	if apt >= 50:
		return 5
	if apt >= 30:
		return 4
	if apt >= 20:
		return 3
	return 2 if apt >= 10 else 1


static func roster(bags: Dictionary, data: Dictionary, bag: Dictionary, battle: String) -> Array:
	var out: Array = []
	for inst: Dictionary in bags.get(5, []):
		var rec: Dictionary = record(inst, data, bag, battle)
		if not rec.is_empty():
			out.append(rec)
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		if a.battle != b.battle:
			return a.battle
		if int(a.score) != int(b.score):
			return int(a.score) > int(b.score)
		return int(a.slot) < int(b.slot))
	return out


static func consume(data: Dictionary, kind: int, level: int) -> Array:
	var row: Array = data.get("cost", {}).get(str(kind), {}).get(str(level), [])
	return row if row.size() >= 6 else []


static func luck(data: Dictionary, kind: int, level: int, cost: int) -> int:
	var row: Array = consume(data, kind, level + 1)
	if row.is_empty() or int(row[3]) <= 0:
		return 0
	return int(floor(float(cost) / float(row[3]) * 100.0))


static func score(rec: Dictionary, data: Dictionary, lv: int = -1, up: float = -1.0, rank: float = -1.0) -> int:
	if int(rec.apt) <= 0:
		return 0
	var level: int = int(rec.lv) if lv < 0 else lv
	var upf: float = (float(rec.up) + luck(data, 1, int(rec.up), int(rec.upc)) / 100.0) if up < 0.0 else up
	var rf: float = (float(rec.rank) + luck(data, 2, int(rec.rank), int(rec.rankc)) / 100.0) if rank < 0.0 else rank
	return int(floor(1000.0 * (1.0 + level * 0.05) * (1.0 + int(rec.apt) * 4.0 / 50.0) * 
		(1.025 + rf * rf / 120.0 + rf / 12.0 + 0.0125 * upf)))


static func attr(rec: Dictionary, data: Dictionary, kind: int, lv: int = -1, up: float = -1.0, rank: float = -1.0) -> int:
	var t: Array = rec.tpl
	var level: int = int(rec.lv) if lv < 0 else lv
	var base: float = float(t[STAT_INDEX[kind]]) * (1.0 + level * 0.05)
	var rf: float = (float(rec.rank) + luck(data, 2, int(rec.rank), int(rec.rankc)) / 100.0) if rank < 0.0 else rank
	var upf: float = (float(rec.up) + luck(data, 1, int(rec.up), int(rec.upc)) / 100.0) if up < 0.0 else up
	var extra: float = 0.0
	if kind == int(t[9]):
		extra = base * (upf * int(t[11]) / RATE + int(t[10]) / RATE)
	elif kind == int(t[12]):
		extra = base * (upf * int(t[14]) / RATE + int(t[13]) / RATE)
	return int(base + extra + base * (rf * rf / 120.0 + rf / 12.0))


static func rows(rec: Dictionary, data: Dictionary, mode: String, next_lv: int = -1) -> Array:
	var out: Array = []
	var nl: int = -1
	var nu: float = -1.0
	var nr: float = -1.0
	match mode:
		"lv":
			nl = next_lv if next_lv > int(rec.lv) else -2
		"up":
			nu = float(int(rec.up) + 1) if int(rec.up) < int(rec.up_max) else -2.0
		"star":
			nr = float(int(rec.rank) + 1) if int(rec.rank) < int(rec.rank_max) else -2.0
	var moved: bool = nl >= 0 or nu >= 0.0 or nr >= 0.0
	var lv: int = nl if nl >= 0 else -1
	var up: float = nu if nu >= 0.0 else -1.0
	var rank: float = nr if nr >= 0.0 else -1.0
	out.append(["Chiến Lực", int(rec.score), score(rec, data, lv, up, rank) if moved else -1])
	for stat: Array in STATS:
		var now: int = attr(rec, data, int(stat[0]))
		out.append([stat[1], now, attr(rec, data, int(stat[0]), lv, up, rank) if moved else -1])
	return out


static func exp_need(data: Dictionary, level: int) -> int:
	var table: Array = data.get("exp", [])
	if level >= 0 and level < table.size():
		return int(table[level])
	return int(table[0]) if not table.is_empty() else 100


static func exp_to_max(rec: Dictionary, data: Dictionary) -> int:
	var level: int = int(rec.lv)
	if level >= int(rec.lv_max):
		return 0
	var need: int = - int(rec.exp)
	while level < int(rec.lv_max):
		need += maxi(0, exp_need(data, level))
		level += 1
	return maxi(0, need)


static func chips(bags: Dictionary, data: Dictionary) -> Array:
	return _mats(bags, data, EXP_CHIP)


static func _mats(bags: Dictionary, data: Dictionary, kind: int) -> Array:
	var by_id: Dictionary = {}
	var meta: Dictionary = data.get("mats", {})
	for inst: Dictionary in bags.get(3, []):
		var id: int = int(inst.get("m_templateId", 0))
		var row: Array = meta.get(str(id), [])
		if row.size() < 3 or int(row[0]) != kind:
			continue
		if not by_id.has(id):
			by_id[id] = {"item": id, "gain": int(row[1]), "tier": int(row[2]), "have": 0, "slot": int(inst.get("m_slotNo", -1))}
		by_id[id].have += maxi(1, int(inst.get("m_count", 1)))
	var out: Array = by_id.values()
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.gain) < int(b.gain) if int(a.gain) != int(b.gain) else int(a.item) < int(b.item))
	return out

static func mats(bags: Dictionary, data: Dictionary, kind: int) -> Array:
	return _mats(bags, data, kind)


static func have(bags: Dictionary, item: int) -> int:
	var total: int = 0
	for inst: Dictionary in bags.get(3, []):
		if int(inst.get("m_templateId", 0)) == item:
			total += maxi(1, int(inst.get("m_count", 1)))
	return total



static func plan(list: Array, need: int) -> Array:
	var sorted: Array = list.filter( func(c: Dictionary) -> bool: return int(c.gain) > 0 and int(c.have) > 0)
	sorted.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.gain) > int(b.gain) if int(a.gain) != int(b.gain) else int(a.item) < int(b.item))
	var left: int = maxi(0, need)
	var used: Dictionary = {}
	for c: Dictionary in sorted:
		if left <= 0:
			break
		var n: int = mini(int(c.have), left / int(c.gain))
		if n > 0:
			used[c.item] = n
			left -= n * int(c.gain)
	if left > 0:
		var pick: Dictionary = {}
		for c: Dictionary in sorted:
			if int(used.get(c.item, 0)) >= int(c.have):
				continue
			if pick.is_empty() or int(c.gain) < int(pick.gain):
				pick = c
		if not pick.is_empty():
			used[pick.item] = int(used.get(pick.item, 0)) + 1
	var out: Array = []
	for c: Dictionary in sorted:
		if int(used.get(c.item, 0)) > 0:
			out.append({"item": c.item, "count": used[c.item], "gain": c.gain})
	return out


static func after_exp(rec: Dictionary, data: Dictionary, gain: int) -> Array:
	var level: int = int(rec.lv)
	var exp: int = int(rec.exp) + maxi(0, gain)
	var guard: int = 0
	while guard < 200 and level < int(rec.lv_max):
		guard += 1
		var need: int = exp_need(data, level)
		if exp < need:
			break
		exp -= need
		level += 1
	if level >= int(rec.lv_max):
		return [int(rec.lv_max), 0]
	return [level, exp]



static func nano_bonus(rank: int, picked: Array) -> int:
	var need: int = rank / 2
	var bonus: int = 0
	var matched: int = 0
	for m: Dictionary in picked:
		if int(m.tier) >= need:
			bonus += int(m.gain)
			matched += 1
		else:
			bonus += int(floor(int(m.gain) / pow(2.0, need - int(m.tier))))
	if matched == 2:
		bonus += NANO_TWO
	elif matched == 3:
		bonus += NANO_THREE
	return bonus


static func convert_need(apt_a: int, apt_b: int) -> int:
	var m: int = maxi(apt_a, apt_b)
	if m <= 10:
		return 1
	if m <= 20:
		return 10
	if m <= 50:
		return m / 5 - 1
	return 10


static func convert_block(a: Dictionary, b: Dictionary) -> String:
	if a.uuid == b.uuid:
		return "Chọn hai trợ thủ khác nhau."
	if int(a.lv) > int(b.lv_max) or int(a.up) > int(b.up_max) or int(a.rank) > int(b.rank_max):
		return "%s vượt giới hạn cấp / cường hoá / sao của %s." % [a.name, b.name]
	if int(b.lv) > int(a.lv_max) or int(b.up) > int(a.up_max) or int(b.rank) > int(a.rank_max):
		return "%s vượt giới hạn cấp / cường hoá / sao của %s." % [b.name, a.name]
	if int(a.lv) == int(b.lv) and int(a.exp) == int(b.exp) and int(a.up) == int(b.up) and int(a.rank) == int(b.rank):
		return "Hai trợ thủ đang cùng cấp, cường hoá và sao."
	return ""






const TACHPET_SKIP_UPGRADED: bool = true
static func bulk_split(list: Array, bag: Dictionary) -> Array:
	var out: Array = []
	for rec: Dictionary in list:
		if bulk_kind(rec, bag) == 0:
			out.append(rec)
	return out


static func bulk_kind(rec: Dictionary, bag: Dictionary) -> int:
	var more: Array = bag.get("more", {}).get(str(int(rec.item)), [])
	var q: int = int(more[2]) if more.size() >= 4 else 0
	if rec.battle or q > 1:
		return 2
	if TACHPET_SKIP_UPGRADED and (int(rec.get("up", 0)) > 0 or int(rec.get("rank", 0)) > 0):
		return 1
	return 0
