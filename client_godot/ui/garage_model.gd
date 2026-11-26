extends RefCounted








const OWN: int = 0
const HIRE: int = 1
const FREE_QQ: int = 2
const TRY_4399: int = 4
const JOIN_BATTLE: int = 2
const LEVEL_RING: int = 15001
const CLASSES: Dictionary = {1: "DPS", 2: "Tank", 3: "Hỗ trợ"}
const FILTERS: Array = ["all", "dps", "tank", "support", "rent"]
const FILTER_NAMES: Array = ["Tất cả", "DPS", "Tank", "Hỗ trợ", "Thuê"]
const AXES: Array = ["DPS", "Bạo phát", "Cơ động", "Hỗ trợ", "Thủ", "Bền"]
const RADAR_FULL: float = 1000.0
const STAT_NAMES: Array = ["Máu", "Tấn công", "Xuyên giáp", "Giáp vật lý", "Giáp năng lượng", "Tốc bắn (phát/phút)", "Tầm bắn", "Tốc độ"]



const MAIN_HIDDEN: Array[int] = [10000122, 10000123, 10000124]

static func main_channel() -> bool:
	return str(ProjectSettings.get_setting("bangbang/android_page", "")).ends_with("/app/lc/")


static func roster(tanks: Dictionary, data: Dictionary, names: Dictionary, defaults: Dictionary, now: int) -> Array:
	var by_id: Dictionary = {}
	for inst: Dictionary in tanks.values():
		by_id.get_or_add(int(inst.get("m_tpltId", 0)), []).append(inst)
	var out: Array = []
	for key: String in data.get("tanks", {}):
		var id: int = int(key)
		if id in MAIN_HIDDEN and main_channel():
			continue
		var info: Dictionary = data.tanks[key]
		var rec: Dictionary = {"id": id, "name": str(names.get(key, key)), "cls": int(info.get("cls", 0)), 
			"sort": int(info.get("sort", 0)), "owned": false, "hire": false, "try": false, "main": false, 
			"inst": {}, "use": {}, "level": 1, "left": 0}
		for inst: Dictionary in by_id.get(id, []):
			var cont: int = int(inst.get("m_contType", -1))
			var alive: bool = int(inst.get("m_existTime", 0)) - now > 0
			rec.owned = rec.owned or cont == OWN
			rec.hire = rec.hire or (cont == HIRE and alive)
			rec.try = rec.try or ((cont == TRY_4399 or cont == FREE_QQ) and alive)
			rec.main = rec.main or (int(inst.get("m_extFlag", 0)) & JOIN_BATTLE) != 0
			if rec.inst.is_empty() or int(inst.get("m_level", 1)) > int(rec.inst.get("m_level", 1)):
				rec.inst = inst
			if _usable(inst, now) and (rec.use.is_empty() or _rank(inst) < _rank(rec.use)):
				rec.use = inst
		rec["avail"] = rec.owned or rec.hire or rec.try
		if not rec.inst.is_empty():
			rec.level = max(1, int(rec.inst.get("m_level", 1)))
		if rec.hire and not rec.owned:
			rec.left = int(rec.use.get("m_existTime", 0)) - now if not rec.use.is_empty() else 0
		rec["ext"] = exterior(data, defaults, id, rec.level, rec.inst)
		out.append(rec)
	out.sort_custom(_before)
	return out

static func _usable(inst: Dictionary, now: int) -> bool:
	var cont: int = int(inst.get("m_contType", -1))
	return cont == OWN or (cont in [HIRE, TRY_4399, FREE_QQ] and int(inst.get("m_existTime", 0)) - now > 0)

static func _rank(inst: Dictionary) -> int:

	return [OWN, HIRE, TRY_4399, FREE_QQ].find(int(inst.get("m_contType", -1)))

static func _before(a: Dictionary, b: Dictionary) -> bool:
	if a.avail != b.avail:
		return a.avail
	if a.sort != b.sort:
		return a.sort > b.sort
	return a.id < b.id

static func filtered(list: Array, kind: String) -> Array:
	match kind:
		"dps":
			return list.filter( func(rec: Dictionary) -> bool: return rec.cls == 1)
		"tank":
			return list.filter( func(rec: Dictionary) -> bool: return rec.cls == 2)
		"support":
			return list.filter( func(rec: Dictionary) -> bool: return rec.cls == 3)
		"rent":
			return list.filter( func(rec: Dictionary) -> bool: return rec.hire and not rec.owned)
	return list


static func exterior(data: Dictionary, defaults: Dictionary, id: int, level: int, inst: Dictionary) -> int:
	var ext: int = int(inst.get("m_externalId", 0))
	if ext > 0:
		return ext
	var row: Array = data.get("levels", {}).get(str(id), {}).get(str(level), [])
	if row.size() > 10 and int(row[10]) > 0:
		return int(row[10])
	return int(defaults.get(str(id), 0))




static func halo(halos: Dictionary, halo_item: int, level: int) -> int:
	var worn: int = int(halos.get(str(halo_item), 0))
	if worn > 0:
		return worn
	return LEVEL_RING if level >= 6 else 0




static func looks(data: Dictionary, defaults: Dictionary, id: int, level: int, worn: int) -> Array:
	var base: int = exterior(data, defaults, id, level, {})
	var out: Array = []
	var at: Dictionary = {}
	if base > 0:
		at[base] = 0
		out.append([base, 0, "Mặc định"])
	for look: Variant in data.get("looks", {}).get(str(id), []):
		if not (look is Array and look.size() >= 3) or int(look[0]) <= 0 or int(look[0]) == base:
			continue
		var row: Array = [int(look[0]), int(look[1]), str(look[2])]
		if at.has(row[0]):
			if int(row[1]) > int(out[at[row[0]]][1]):
				out[at[row[0]]] = row
			continue
		at[row[0]] = out.size()
		out.append(row)
	if worn > 0 and not at.has(worn):
		out.insert(mini(1, out.size()), [worn, 0, "Đang dùng"])
	return out



static func owned_skins(data: Dictionary, bags: Dictionary, id: int) -> Dictionary:
	var out: Dictionary = {}
	var known: Dictionary = data.get("skin_items", {})
	for item: Dictionary in bags.get(6, []):
		var entry: Array = known.get(str(int(item.get("m_templateId", 0))), [])
		if entry.size() >= 2 and int(entry[0]) == id and int(entry[1]) > 0:
			out[int(entry[1])] = str(item.get("m_itemUuid", ""))
	return out



static func owned_halos(data: Dictionary, bags: Dictionary, now: int) -> Array:
	var out: Array = []
	var seen: Dictionary = {}
	var names: Dictionary = data.get("halo_items", {})
	for item: Dictionary in bags.get(9, []):
		var id: int = int(item.get("m_templateId", 0))
		var life: int = int(item.get("m_lifeTime", 0))
		if id <= 0 or seen.has(id) or (life > 0 and (int(item.get("m_extFlag", 0)) & 4) != 0 and life <= now):
			continue
		seen[id] = true
		var entry: Array = names.get(str(id), [])
		out.append([id, str(entry[0]) if not entry.is_empty() else "Vòng sáng"])
	return out


static func have(bags: Dictionary, item: int) -> int:
	var total: int = 0
	for cont: int in [2, 3]:
		for inst: Dictionary in bags.get(cont, []):
			if int(inst.get("m_templateId", 0)) == item:
				total += maxi(1, int(inst.get("m_count", 1)))
	return total


static func cost(data: Dictionary, index: int) -> Array:
	var rows: Array = data.get("costs", [])
	var out: Array = []
	if index < 0 or index >= rows.size():
		return out
	var row: Array = rows[index]
	for i in range(0, mini(4, row.size()) - 1, 2):
		if int(row[i]) > 0 and int(row[i + 1]) > 0:
			out.append([int(row[i]), int(row[i + 1])])
	return out



static func step(data: Dictionary, id: int, level: int, n: int) -> Dictionary:
	var rows: Dictionary = data.get("strengthen", {}).get(str(id), {}).get(str(level), {})
	var row: Array = rows.get(str(n), [])
	if row.size() < 2:
		return {}
	var before: Array = rows.get(str(n - 1), [0, 0])
	return {"gain": [int(row[0]) - int(before[0]), int(row[1]) - int(before[1])], "cost": cost(data, int(row[2])) if row.size() > 2 else []}


static func can_up(data: Dictionary, id: int, level: int) -> bool:
	return level < 6 and data.get("ups", {}).get(str(id), {}).has(str(level)) and data.get("levels", {}).get(str(id), {}).has(str(level + 1))


static func up_cost(data: Dictionary, id: int, level: int) -> Array:
	var ups: Dictionary = data.get("ups", {}).get(str(id), {})
	return cost(data, int(ups[str(level)])) if ups.has(str(level)) else []




static func progress(data: Dictionary, id: int, inst: Dictionary) -> Dictionary:
	var level: int = maxi(1, int(inst.get("m_level", 1)))
	var done: int = maxi(0, int(inst.get("m_stthLevel", 0)))
	var steps: int = data.get("strengthen", {}).get(str(id), {}).get(str(level), {}).size()
	var out: Dictionary = {"mode": "max", "level": level, "done": mini(done, steps), "steps": steps, "cost": [], "gain": [0, 0]}
	var next: Dictionary = step(data, id, level, done + 1)
	if not next.is_empty():
		out.mode = "strengthen"
		out.gain = next.gain
		out.cost = next.cost
	elif can_up(data, id, level):
		out.mode = "up"
		out.cost = up_cost(data, id, level)
	return out


static func affordable(bags: Dictionary, need: Array) -> bool:
	for row: Array in need:
		if have(bags, int(row[0])) < int(row[1]):
			return false
	return true


static func grade(quality: int) -> String:
	return str({2: "A", 3: "S", 4: "SS", 5: "SSS"}.get(quality, ""))


static func cooldown(ms: int) -> String:
	if ms <= 0:
		return ""
	return ("%d giây" % (ms / 1000)) if ms % 1000 == 0 else ("%.1f giây" % (ms / 1000.0)).replace(".", ",")


static func dots(value: int) -> String:
	var digits: String = str(absi(value))
	var out: String = ""
	while digits.length() > 3:
		out = "." + digits.substr(digits.length() - 3) + out
		digits = digits.substr(0, digits.length() - 3)
	return ("-" if value < 0 else "") + digits + out


static func face(data: Dictionary, ext: int) -> String:
	return str(data.get("faces", {}).get(str(ext), ""))


static func skills(data: Dictionary, id: int, ext: int) -> Array:
	var base: Array = data.get("tanks", {}).get(str(id), {}).get("skills", [0, 0, 0, 0]).duplicate()
	var skin: Array = data.get("skins", {}).get(str(ext), [])
	for i in range(mini(4, skin.size())):
		if int(skin[i]) > 0:
			base[i] = int(skin[i])
	while base.size() < 4:
		base.append(0)
	var out: Array = []
	var ultimate: int = int(base[3]) if int(base[3]) > 0 else int(base[2])
	for pair: Array in [["R", ultimate], ["E", int(base[0])], ["Space", int(base[1])], ["Nội tại", int(base[2]) if int(base[3]) > 0 else 0]]:
		if int(pair[1]) > 0:
			out.append(pair)
	return out


static func skill(data: Dictionary, skill_id: int) -> Array:
	return data.get("skills", {}).get(str(skill_id), [])


static func stats(data: Dictionary, id: int, level: int, strengthen: int) -> Array:
	var levels: Dictionary = data.get("levels", {}).get(str(id), {})
	var row: Array = levels.get(str(level), levels.get("1", []))
	if row.size() < 11:
		return []
	var bonus: Array = data.get("strengthen", {}).get(str(id), {}).get(str(level), {}).get(str(strengthen), [0, 0])
	var energy: bool = int(data.get("tanks", {}).get(str(id), {}).get("type", 1)) != 1
	var reach: Array = levels.get("1", row)
	var values: Array = [int(row[0]) + int(bonus[0]), (int(row[2]) if energy else int(row[1])) + int(bonus[1]), 
		int(row[4]) if energy else int(row[3]), int(row[5]), int(row[6]), 
		roundi(60000.0 / float(row[7])) if int(row[7]) > 0 else 0, int(reach[9]), int(row[8])]
	var out: Array = []
	for i in range(STAT_NAMES.size()):
		out.append([STAT_NAMES[i], values[i]])
	return out


static func radar(data: Dictionary, id: int) -> Array:
	var attrs: Array = data.get("tanks", {}).get(str(id), {}).get("attrs", [])
	var full: float = RADAR_FULL
	for value: Variant in attrs:
		full = maxf(full, float(value))
	var out: Array = []
	for i in range(6):
		out.append(clampf(float(attrs[i]) / full, 0.0, 1.0) if i < attrs.size() else 0.0)
	return out


static func left_text(seconds: int) -> String:
	if seconds <= 0:
		return ""
	var minutes: int = maxi(1, seconds / 60)
	if minutes >= 1440:
		return "%dn %dg" % [minutes / 1440, (minutes % 1440) / 60]
	if minutes >= 60:
		return "%dg %dp" % [minutes / 60, minutes % 60]
	return "%dp" % minutes


static func main_block(rec: Dictionary, state: String) -> String:
	if rec.get("main", false):
		return "Đang chủ chiến"
	if not rec.get("avail", false) or rec.get("use", {}).is_empty():
		return "Chưa sở hữu"
	if not state in ["lobby", "hall", "room"]:
		return "Chưa dùng được lúc này"
	return ""




static func bbcode(text: String) -> String:
	return _marked(text.replace("[", "[lb]"), "[color=#%s]", "[/color]")


static func plain(text: String) -> String:
	return _marked(text, "", "").replace("\n", " ").strip_edges()


static func cap(text: String) -> String:
	return text.substr(0, 1).to_upper() + text.substr(1)

static func _marked(text: String, open: String, close: String) -> String:
	var out: String = text.replace("#ENTER#", "\n")
	for pair: Array in [["#PH_\\s*(.*?)\\s*_IC#", "ffae0d"], ["#EN_\\s*(.*?)\\s*_ER#", "df84f3"]]:
		out = RegEx.create_from_string(str(pair[0])).sub(out, (open % str(pair[1]) if not open.is_empty() else "") + "$1" + close, true)
	var colour: RegEx = RegEx.create_from_string("(?s)#COLOR_\\s*([0-9A-Fa-f]{6})[^_#]*_\\s?((?:(?!#COLOR_).)*?)_END#")
	for turn in range(4):
		var next: String = colour.sub(out, (open.replace("%s", "$1") if not open.is_empty() else "") + "$2" + close, true)
		if next == out:
			break
		out = next
	return RegEx.create_from_string("#COLOR_\\s*[0-9A-Fa-f]{6}[^_#]*_|_END#|_TKN_\\d+__").sub(out, "", true)
