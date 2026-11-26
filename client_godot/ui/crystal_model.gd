extends RefCounted







const CONT: int = 10
const SLOTS: int = 30
const PAGES: int = 5
const KINDS: Array = [2, 3, 4]
const KIND_NAME: Dictionary = {1: "Siêu", 2: "Tấn công", 3: "Phòng thủ", 4: "Hỗ trợ"}
const KIND_TINT: Dictionary = {1: Color("c79bff"), 2: Color("ff7a66"), 3: Color("ffd457"), 4: Color("6cc8ff")}

const MAKE_FREE: int = 2
const MAKE_CASH: Array = [3, 4]
const MAKE_GIFT: Array = [5, 6]
const FORGE_CAP: int = 64

static func row(data: Dictionary, item: int) -> Array:
	var value: Variant = data.get("items", {}).get(str(item), [])
	return value if value is Array and value.size() >= 8 else []

static func kind(data: Dictionary, item: int) -> int:
	var r: Array = row(data, item)
	return int(r[0]) if not r.is_empty() else 0

static func level(data: Dictionary, item: int) -> int:
	var r: Array = row(data, item)
	return int(r[1]) if not r.is_empty() else 0

static func need_level(data: Dictionary, item: int) -> int:
	var r: Array = row(data, item)
	return int(r[2]) if not r.is_empty() else 0

static func next(data: Dictionary, item: int) -> int:
	var r: Array = row(data, item)
	return int(r[3]) if not r.is_empty() else 0

static func merge_need(data: Dictionary, item: int) -> int:
	var r: Array = row(data, item)
	return maxi(1, int(r[4])) if not r.is_empty() else 1

static func pieces(data: Dictionary, item: int) -> int:
	var r: Array = row(data, item)
	return int(r[5]) if not r.is_empty() else 0

static func attrs(data: Dictionary, item: int) -> Array:
	var r: Array = row(data, item)
	return r[6] if not r.is_empty() and r[6] is Array else []

static func title(data: Dictionary, item: int) -> String:
	var r: Array = row(data, item)
	return str(r[7]) if not r.is_empty() else "Tinh thể %d" % item


static func short(data: Dictionary, item: int) -> String:
	var list: Array = attrs(data, item)
	if list.is_empty():
		return title(data, item)
	return str(data.get("attrs", {}).get(str(int(list[0][0])), "Thuộc tính %d" % int(list[0][0])))


static func owned(bags: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for inst: Dictionary in bags.get(CONT, []):
		var item: int = int(inst.get("m_templateId", 0))
		if item > 0:
			out[item] = int(out.get(item, 0)) + maxi(1, int(inst.get("m_count", 1)))
	return out


static func used(slots: Array) -> Dictionary:
	var out: Dictionary = {}
	for item: int in slots:
		if item > 0:
			out[item] = int(out.get(item, 0)) + 1
	return out


static func held(pages: Array) -> Dictionary:
	var out: Dictionary = {}
	for slots: Array in pages:
		var mine: Dictionary = used(slots)
		for item: int in mine:
			out[item] = maxi(int(out.get(item, 0)), int(mine[item]))
	return out


static func number(value: float) -> String:
	var text: String = "%.2f" % (roundf(absf(value) * 100.0) / 100.0)
	if text.contains("."):
		text = text.rstrip("0").rstrip(".")
	return text


static func amount(attr: Array) -> String:
	var value: float = float(attr[2]) * (100.0 if int(attr[1]) == 2 else 1.0)
	return ("−" if value < 0.0 else "+") + number(value) + ("%" if int(attr[1]) == 2 else "")

static func attr_name(data: Dictionary, attr: Array) -> String:
	return str(data.get("attrs", {}).get(str(int(attr[0])), "Thuộc tính %d" % int(attr[0])))


static func effect(data: Dictionary, item: int) -> String:
	var parts: Array = []
	for attr: Array in attrs(data, item):
		parts.append(amount(attr) + " " + attr_name(data, attr))
	return " · ".join(parts)


static func totals(data: Dictionary, slots: Array) -> Array:
	var sum: Dictionary = {}
	for item: int in slots:
		for attr: Array in attrs(data, item):
			var key: int = int(attr[0]) * 10 + int(attr[1])
			sum[key] = float(sum.get(key, 0.0)) + float(attr[2])
	var keys: Array = sum.keys()
	keys.sort()
	var out: Array = []
	for key: int in keys:
		out.append([key / 10, key % 10, roundf(float(sum[key]) * 10000.0) / 10000.0])
	return out

static func level_sum(data: Dictionary, slots: Array) -> int:
	var total: int = 0
	for item: int in slots:
		total += level(data, item)
	return total

static func filled(slots: Array) -> int:
	var total: int = 0
	for item: int in slots:
		if item > 0:
			total += 1
	return total


static func slot_kind(data: Dictionary, index: int) -> int:
	var list: Array = data.get("slots", [])
	return int(list[index][1]) if index >= 0 and index < list.size() else 0

static func slot_level(data: Dictionary, index: int) -> int:
	var list: Array = data.get("slots", [])
	return int(list[index][0]) if index >= 0 and index < list.size() else 99


static func slots_of(data: Dictionary, k: int) -> Array:
	var out: Array = []
	for i in range(SLOTS):
		if slot_kind(data, i) == k:
			out.append(i)
	return out


static func refuse(data: Dictionary, slots: Array, index: int, item: int, have: Dictionary, player_level: int) -> String:
	if index < 0 or index >= SLOTS:
		return "Chưa chọn ô."
	var k: int = kind(data, item)
	if k == 0 or attrs(data, item).is_empty():
		return "Viên này không khảm được."
	if slot_level(data, index) > player_level:
		return "Ô này mở ở cấp %d." % slot_level(data, index)
	if slot_kind(data, index) != k:
		return "Ô này chỉ nhận tinh thể %s." % str(KIND_NAME.get(slot_kind(data, index), "")).to_lower()
	if need_level(data, item) > player_level:
		return "Cần cấp %d để dùng viên này." % need_level(data, item)
	var taken: int = int(used(slots).get(item, 0)) - (1 if int(slots[index]) == item else 0)
	if int(have.get(item, 0)) - taken < 1:
		return "Đã khảm hết số viên đang có."
	return ""


static func free_slot(data: Dictionary, slots: Array, k: int, player_level: int) -> int:
	for i in range(SLOTS):
		if int(slots[i]) == 0 and slot_kind(data, i) == k and slot_level(data, i) <= player_level:
			return i
	return -1


static func roster(data: Dictionary, have: Dictionary, socket: bool) -> Array:
	var out: Array = []
	for item: int in have:
		if int(have[item]) < 1 or row(data, item).is_empty():
			continue
		if socket and (attrs(data, item).is_empty() or not kind(data, item) in KINDS):
			continue
		out.append(item)
	out.sort_custom( func(a: int, b: int) -> bool:
		var ka: int = kind(data, a) if kind(data, a) != 1 else 9
		var kb: int = kind(data, b) if kind(data, b) != 1 else 9
		if ka != kb:
			return ka < kb
		if level(data, a) != level(data, b):
			return level(data, a) > level(data, b)
		return a < b)
	return out


static func liked(data: Dictionary, tank: int) -> Dictionary:
	var out: Dictionary = {}
	var by_level: Variant = data.get("rmd", {}).get(str(tank), {})
	if not by_level is Dictionary:
		return out
	for ids: Variant in by_level.values():
		if not ids is Array:
			continue
		for item: Variant in ids:
			var list: Array = attrs(data, int(item))
			if not list.is_empty():
				out.get_or_add(kind(data, int(item)), {})[int(list[0][0])] = true
	return out

static func is_liked(data: Dictionary, likes: Dictionary, item: int) -> bool:
	var list: Array = attrs(data, item)
	return not list.is_empty() and likes.get(kind(data, item), {}).has(int(list[0][0]))


static func quick(data: Dictionary, slots: Array, have: Dictionary, player_level: int, tank: int) -> Array:
	var out: Array = slots.duplicate()
	var left: Dictionary = {}
	var taken: Dictionary = used(out)
	for item: int in have:
		left[item] = int(have[item]) - int(taken.get(item, 0))
	var likes: Dictionary = liked(data, tank)
	var pool: Array = roster(data, have, true)
	pool.sort_custom( func(a: int, b: int) -> bool:
		var la: bool = is_liked(data, likes, a)
		var lb: bool = is_liked(data, likes, b)
		if la != lb:
			return la
		if level(data, a) != level(data, b):
			return level(data, a) > level(data, b)
		return a < b)
	for i in range(SLOTS):
		if int(out[i]) != 0 or slot_level(data, i) > player_level:
			continue
		for item: int in pool:
			if int(left.get(item, 0)) > 0 and kind(data, item) == slot_kind(data, i) and need_level(data, item) <= player_level:
				out[i] = item
				left[item] = int(left[item]) - 1
				break
	return out

static func empty_page() -> Array:
	var out: Array = []
	out.resize(SLOTS)
	out.fill(0)
	return out


static func make_cost(data: Dictionary, make: int) -> Array:
	var table: Dictionary = data.get("make", {})
	if make in MAKE_GIFT:
		return [3, int(table.get("gift", [120, 488])[MAKE_GIFT.find(make)]), 1 if make == MAKE_GIFT[0] else 5]
	if make in MAKE_CASH:
		return [1, int(table.get("cash", [120, 488])[MAKE_CASH.find(make)]), 1 if make == MAKE_CASH[0] else 5]
	return [0, 0, 1]


static func span(seconds: int) -> String:
	var s: int = maxi(0, seconds)
	if s >= 86400:
		return "%d ngày %d giờ" % [s / 86400, (s % 86400) / 3600]
	if s >= 3600:
		return "%d giờ %d phút" % [s / 3600, (s % 3600) / 60]
	return "%d phút" % maxi(1, int(ceil(s / 60.0)))
