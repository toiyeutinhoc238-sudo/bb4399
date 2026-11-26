extends RefCounted












const CATS: Array = ["vp", "mat", "fashion", "decor", "honor", "spray"]
const CAT_NAMES: Array = ["VP", "Nguyên liệu", "Thời trang", "Trang trí", "Thành tích", "Phun"]
const CONT: Dictionary = {"vp": 2, "mat": 3, "fashion": 4, "decor": 7}
const KIND: Dictionary = {"vp": "Vật phẩm", "mat": "Nguyên liệu", "fashion": "Thời trang", "decor": "Trang trí", "honor": "Thành tích", "spray": "Hình phun"}
const TIME_START: int = 4
const SYS_BIND: int = 1
const MATERIAL_SLOTS: int = 135
const DECOR_SLOTS: int = 80
const SPRAY_CAN: int = 2600001
const USE_CAP: int = 9999

const USE_ONE: Array = [2400001, 5600001, 2009023]
const HONOR_SLOTS: int = 4
const QUALITY: Dictionary = {2: Color("15ee19"), 3: Color("06fffc"), 4: Color("ff6eff"), 5: Color("f18819")}
const QUALITY_NAMES: Dictionary = {1: "Thường", 2: "Tốt", 3: "Hiếm", 4: "Cực hiếm", 5: "Truyền thuyết"}

const SPEAKERS: Array = [2100001, 2100002, 2100007]

const SPEAKER_CHANNEL: Dictionary = {2100001: 128, 2100002: 256, 2100007: 2048}

const WHEEL_ITEMS: Array = [2600004]

const LUCK_ITEMS: Array = [2003170, 2020022]
const PHOENIX_STONE: int = 2600038
const FLAUNT: int = 33
const MAP_KEY: int = 43

const TIP_SELF: String = "Không thể tự tặng bản thân"
const TIP_ROOM: String = "Trong room ko thể thực hiện thao tác này"
const TIP_ACT_OVER: String = "Đã quá hạn HĐ, không thể dùng"
const TIP_PAIRING: String = "Đang phối hợp, không thể thao tác"
const TIP_MAP_KEY: String = "Dùng @item@ mở để mở lối đi đến Map Boss @map@ (Chiến Lực đề cử: @num1@)"
const MAP_KEY_BASE: int = 7000
const RENAMES: Array = [2600002, 2600003, 2600006]

const RENAME_KIND: Dictionary = {2600002: 3, 2600003: 4, 2600006: 1}
const WINDOW_ITEMS: Array = [2600038, 2002156, 4050003, 8400027, 4050004, 2003170, 2020022]


const WINDOW_TYPES: Array = [48, 49, 65, 66, 67, 75]
const SEL_AWARD: int = 73
const LIMIT_AWARD: int = 71
const DROP: int = 27
const TIP_BAG_FULL: String = "Ô đạo cụ đã đầy"
const TIP_MAT_FULL: String = "Ô vật liệu đã đầy"
const SOON: int = 72 * 3600
const AVATAR_CARD: int = 32
const PER_PAGE: int = 45
const CARD_PAGE: int = 3
const PVP_COIN: int = 8000005
const GCOUNT_WIN: int = 1
const GCOUNT_LOST: int = 2
const GCOUNT_ESCAPE: int = 3


static func entries(cat: String, bags: Dictionary, sprays: Array, honors: Array, data: Dictionary, char: Dictionary, worn: Array, now: int) -> Array:
	var out: Array = []
	if cat == "honor":
		for info: Dictionary in honors:
			var id: int = int(info.get("nHonorId", 0))
			var row: Array = data.get("honors", {}).get(str(id), [])
			var medal: Dictionary = _plain("honor", id, row, "Thành tích %d" % id, "l/hn/", worn.has(id))
			medal["gained"] = int(info.get("nGainTime", 0))
			out.append(medal)
		return out
	if cat == "spray":
		var list: Array = sprays.duplicate()
		list.sort()
		for id: int in list:
			var row: Array = data.get("sprays", {}).get(str(id), [])
			out.append(_plain("spray", id, row, "Hình phun %d" % id, "l/sp/", int(char.get("sprayId", 0)) == id))
		return out
	var cont: int = int(CONT.get(cat, 0))
	var seen: Dictionary = {}
	for inst: Dictionary in bags.get(cont, []):
		var rec: Dictionary = entry(cat, inst, data, char, now)
		if seen.has(rec.key):
			rec.key = "%s#%d" % [str(rec.key), int(rec.slot)]
		seen[rec.key] = true
		out.append(rec)
	return out

static func _plain(cat: String, id: int, row: Array, fallback: String, folder: String, active: bool) -> Dictionary:
	var key: String = str(row[2]) if row.size() > 2 else ""
	var picture: String = folder + key + ".webp" if not key.is_empty() else ""
	return {"key": "%s:%d" % [cat, id], "cat": cat, "cont": 0, "slot": -1, "id": id, "count": 1, 
		"name": _named(row, fallback), "desc": clean(str(row[1])) if row.size() > 1 else "", 
		"icon": picture, "art": picture, "quality": 0, "type": 0, "reuse": 0, "badge": "", "tline": "", "timed": false, 
		"expired": false, "active": active, "price": 0, "coin": "", "stack": 1}


static func _named(row: Array, fallback: String) -> String:
	var name: String = clean(str(row[0])) if row.size() > 0 else ""
	return name if not name.is_empty() else fallback



static func clean(text: String) -> String:
	var out: String = ""
	var dropped: int = 0
	var letters: int = 0
	for i: int in text.length():
		var code: int = text.unicode_at(i)
		if code < 11904:
			out += text[i]
			if code > 64:
				letters += 1
		elif code >= 65281 and code <= 65374:
			out += String.chr(code - 65248)
		elif code == 12288:
			out += " "
		elif code in [12304, 12300, 12298]:
			out += "["
		elif code in [12305, 12301, 12299]:
			out += "]"
		elif code == 12289:
			out += ", "
		elif code == 12290:
			out += ". "
		elif code <= 40959 or (code >= 63744 and code <= 64255) or (code >= 65072 and code <= 65103):
			dropped += 1
		else:
			out += text[i]
	return "" if dropped > letters else out.strip_edges()


static func entry(cat: String, inst: Dictionary, data: Dictionary, char: Dictionary, now: int) -> Dictionary:
	var id: int = int(inst.get("m_templateId", 0))
	var row: Array = data.get("items", {}).get(str(id), [])
	var known: bool = row.size() >= 10
	var key: String = str(row[2]) if known else ""
	var cont: int = int(CONT.get(cat, 0))
	var count: int = maxi(1, int(inst.get("m_count", 1)))
	var unit: int = int(row[7]) if known else 0



	var uuid: String = str(inst.get("m_itemUuid", ""))
	var rec: Dictionary = {"key": "%d:%s" % [cont, uuid if not uuid.is_empty() else "t%d" % id], "cat": cat, "cont": cont, 
		"slot": int(inst.get("m_slotNo", -1)), "id": id, "count": count, 
		"name": _named(row, "Vật phẩm %d" % id), "desc": clean(str(row[1])) if known else "", 
		"icon": "", "art": "", "quality": int(row[3]) if known else 0, "type": int(row[4]) if known else 0, 
		"reuse": int(row[9]) if known else 0, "stack": int(row[6]) if known else 1, 
		"price": unit * count if unit > 1 else 0, "coin": coin_name(int(row[8]) if known else 0), 
		"life": int(inst.get("m_lifeTime", 0)), "flag": int(inst.get("m_extFlag", 0)), "bind": (int(inst.get("m_extFlag", 0)) & SYS_BIND) != 0}
	if not key.is_empty():

		rec.art = ("l/av/" if cont == 4 else "l/it/") + key + ".webp"
		rec.icon = "" if cont == 4 else rec.art
	elif known and cont != 4:
		rec.icon = alt_icon(id, int(rec.type), data)
		rec.art = rec.icon
	rec["active"] = (cont == 4 and int(char.get("avatarId", 0)) == id) or (cont == 7 and int(char.get("decorateId", 0)) == id)
	_time(rec, inst, now)
	return rec




static func alt_icon(id: int, type: int, data: Dictionary) -> String:
	var alt: Variant = data.get("alt", null)
	if not (alt is Dictionary):
		return ""
	var by_id: Variant = (alt as Dictionary).get("items", {})
	if by_id is Dictionary and (by_id as Dictionary).has(str(id)):
		return str(by_id[str(id)])
	var by_type: Variant = (alt as Dictionary).get("types", {})
	if by_type is Dictionary and (by_type as Dictionary).has(str(type)):
		return str(by_type[str(type)])
	return str((alt as Dictionary).get("default", ""))


static func alt_of(id: int, data: Dictionary) -> String:
	var row: Array = data.get("items", {}).get(str(id), [])
	if row.size() <= 5 or int(row[5]) == 4 or not str(row[2]).is_empty():
		return ""
	return alt_icon(id, int(row[4]), data)

static func _time(rec: Dictionary, inst: Dictionary, now: int) -> void :
	var life: int = int(inst.get("m_lifeTime", 0))
	rec["timed"] = life > 0
	rec["expired"] = false
	rec["badge"] = ""
	rec["tline"] = ""
	rec["started"] = false
	rec["left"] = -1
	rec["soon"] = false
	if life <= 0:
		if int(rec.cont) in [4, 7]:
			rec.tline = "Không giới hạn"
		return
	if int(inst.get("m_extFlag", 0)) & TIME_START:
		var left: int = life - now
		rec.started = true
		rec.left = maxi(0, left)
		rec.expired = left <= 0
		rec.badge = "Hết hạn" if rec.expired else span(left)
		rec.tline = "Đã hết hạn" if rec.expired else "Còn " + span(left)
	else:
		rec.left = life * 86400
		rec.badge = "%d ngày" % life
		rec.tline = "Hạn %d ngày, tính từ lúc dùng" % life
	rec.soon = int(rec.get("type", 0)) != AVATAR_CARD and int(rec.left) <= SOON


static func span(seconds: int) -> String:
	var minutes: int = maxi(1, seconds / 60)
	if minutes >= 1440:
		return "%dn %dg" % [minutes / 1440, (minutes % 1440) / 60]
	if minutes >= 60:
		return "%dg %dp" % [minutes / 60, minutes % 60]
	return "%dp" % minutes

static func coin_name(kind: int) -> String:
	return str({1: "Xu", 3: "Xu Khóa"}.get(kind, "Bạc"))


static func tint(quality: int, plain: Color) -> Color:
	return QUALITY.get(mini(quality, 5), plain)

static func quality_name(quality: int) -> String:
	return str(QUALITY_NAMES.get(clampi(quality, 1, 5), "")) if quality > 0 else ""


static func capacity(cat: String, count: int, data: Dictionary, char: Dictionary) -> Array:
	match cat:
		"vp":
			var expand: Array = data.get("expand", [])
			return [count, (int(expand[1]) if expand.size() > 1 else 45) + int(char.get("grocery_add", 0))]
		"mat":
			return [count, MATERIAL_SLOTS]
		"decor":
			return [count, DECOR_SLOTS]
	return [count, 0]



static func first_empty(bags: Dictionary, cont: int, total: int) -> int:
	var used: Dictionary = {}
	for inst: Dictionary in bags.get(cont, []):
		used[int(inst.get("m_slotNo", -1))] = true
	for slot in range(maxi(0, total)):
		if not used.has(slot):
			return slot
	return -1



static func drop_full(bags: Dictionary, data: Dictionary, char: Dictionary) -> String:
	if first_empty(bags, 2, int(capacity("vp", 0, data, char)[1])) == -1:
		return TIP_BAG_FULL
	if first_empty(bags, 3, MATERIAL_SLOTS) == -1:
		return TIP_MAT_FULL
	return ""


static func expand_cost(data: Dictionary) -> int:
	var expand: Array = data.get("expand", [])
	return int(expand[0]) if expand.size() > 0 else 0


static func spray_cans(bags: Dictionary) -> int:
	var total: int = 0
	for inst: Dictionary in bags.get(2, []):
		if int(inst.get("m_templateId", 0)) == SPRAY_CAN:
			total += maxi(1, int(inst.get("m_count", 1)))
	return total


static func item_count(bags: Dictionary, id: int, cont: int = 2) -> int:
	var total: int = 0
	for inst: Dictionary in bags.get(cont, []):
		if int(inst.get("m_templateId", 0)) == id:
			total += maxi(1, int(inst.get("m_count", 1)))
	return total





static func asks_count(rec: Dictionary, _data: Dictionary) -> bool:
	return str(rec.get("cat", "")) == "vp" and int(rec.get("count", 1)) > 1 and not USE_ONE.has(int(rec.get("id", 0)))

static func use_max(rec: Dictionary) -> int:
	return clampi(int(rec.get("count", 1)), 1, USE_CAP)









static func map_key_ask(rec: Dictionary) -> String:
	var target: int = int(rec.get("reuse", 0))
	var map: String = "Bí Cảnh Vũ Trụ No.%d" % (target - MAP_KEY_BASE) if target > MAP_KEY_BASE else "Bản đồ %d" % target
	var desc: String = str(rec.get("desc", ""))
	var lead: String = "đề cử: "
	var at: int = desc.find(lead)
	var power: String = ""
	if at >= 0:
		for ch: String in desc.substr(at + lead.length()):
			if ch == ".":
				continue
			if not ch.is_valid_int():
				break
			power += ch
	return TIP_MAP_KEY.replace("@item@", str(rec.get("name", ""))).replace("@map@", map).replace("@num1@", power if not power.is_empty() else "0")

static func primary(rec: Dictionary, data: Dictionary, state: String, cans: int, worn: int) -> Array:
	if rec.is_empty():
		return ["", "Dùng", false, ""]
	var ready: bool = state in ["lobby", "hall", "room"]
	var wait: String = "" if ready else "Chưa dùng được lúc này."
	match str(rec.cat):
		"vp":
			var id: int = int(rec.id)
			if rec.expired:
				return ["", "Dùng", false, "Vật phẩm đã hết hạn."]
			if id == SPRAY_CAN:
				return ["to_spray", "Chọn hình", true, ""]
			if SPEAKER_CHANNEL.has(id):
				return ["horn", "Dùng", ready, wait]
			if RENAMES.has(id):
				return ["rename", "Dùng", ready, wait]
			if id == PHOENIX_STONE:
				return ["tip", "Dùng", true, TIP_ACT_OVER]
			if WHEEL_ITEMS.has(id):
				return ["wheel", "Dùng", ready, wait]
			if LUCK_ITEMS.has(id):
				return ["luck", "Dùng", ready, wait]
			if int(rec.type) == FLAUNT:
				return ["tip", "Dùng", true, TIP_SELF]
			if int(rec.type) == MAP_KEY:
				if state == "room":
					return ["tip", "Dùng", true, TIP_ROOM]
				return ["map_key", "Dùng", ready, wait]
			if int(rec.type) == SEL_AWARD and not WINDOW_ITEMS.has(id):
				return ["sel_award", "Dùng", ready, wait]
			if int(rec.type) == LIMIT_AWARD and int(rec.reuse) > 0 and not WINDOW_ITEMS.has(id):
				return ["egg", "Dùng", ready, wait]
			if WINDOW_ITEMS.has(id) or WINDOW_TYPES.has(int(rec.type)):
				return ["", "Dùng", false, "Vật phẩm này mở một màn đang được chuyển sang HTML5."]
			return ["ask" if asks_count(rec, data) or (id == 2009023 and int(rec.get("count", 1)) > 1) else "use", "Dùng", ready, wait]
		"mat":
			return ["", "Dùng", false, "Nguyên liệu dùng khi chế tạo và nâng cấp."]
		"fashion":
			if rec.active:
				return ["", "Đang mặc", false, "Bạn đang mặc bộ này."]
			if rec.expired:
				return ["", "Mặc", false, "Thời trang đã hết hạn."]
			return ["wear", "Mặc", ready, wait]
		"decor":
			if rec.active:
				return ["strip", "Bỏ", ready, wait]
			if rec.expired:
				return ["", "Dùng", false, "Trang trí đã hết hạn."]
			return ["wear", "Dùng", ready, wait]
		"honor":
			if rec.active:
				return ["honor_off", "Gỡ", ready, wait]
			if worn >= HONOR_SLOTS:
				return ["", "Đeo", false, "Đã đeo đủ %d thành tích, gỡ bớt một cái trước." % HONOR_SLOTS]
			return ["honor_on", "Đeo", ready, wait]
		"spray":
			if rec.active:
				return ["", "Đang dùng", false, "Bạn đang dùng hình này."]
			if cans <= 0:
				return ["", "Dùng hình này", false, "Cần bình phun để đổi hình."]
			return ["spray", "Dùng hình này", ready, wait]
	return ["", "Dùng", false, ""]


static func sale(rec: Dictionary, state: String) -> Array:
	if rec.is_empty() or not (str(rec.cat) in ["vp", "mat"]):
		return [false, false, ""]
	if int(rec.price) <= 0:
		return [true, false, "Vật phẩm này không thể bán."]
	if not state in ["lobby", "hall", "room"]:
		return [true, false, "Chưa bán được lúc này."]
	return [true, true, ""]


static func honor_toggle(worn: Array, id: int) -> Array:
	var out: Array = worn.filter( func(value: Variant) -> bool: return int(value) != id and int(value) > 0)
	if out.size() == worn.size() and out.size() < HONOR_SLOTS:
		out.append(id)
	return out


static func award_lines(info: Dictionary, data: Dictionary) -> Array:
	var out: Array = []
	var coins: Array = info.get("coins", [])
	var names: Array = ["Xu", "Xu Khóa", "Bạc"]
	for i: int in mini(coins.size(), names.size()):
		if int(coins[i]) > 0:
			out.append([names[i], int(coins[i]), "coin:%d" % i])
	if int(info.get("exp", 0)) > 0:
		out.append(["Kinh nghiệm", int(info.exp), ""])
	for pair: Array in info.get("items", []):
		var row: Array = data.get("items", {}).get(str(int(pair[0])), [])
		var other: Array = data.get("more", {}).get(str(int(pair[0])), []) if row.is_empty() else []
		var name: String = _named(row if other.is_empty() else other, "Vật phẩm %d" % int(pair[0]))
		var key: String = str(row[2]) if row.size() > 2 else (str(other[1]) if other.size() > 1 else "")
		var folder: String = "l/av/" if row.size() > 5 and int(row[5]) == 4 else "l/it/"
		out.append([name, int(pair[1]), folder + key + ".webp" if not key.is_empty() else alt_of(int(pair[0]), data)])
	return out


static func fmt_left(seconds: int) -> String:
	if seconds >= 86400:
		var hours: int = ceili(seconds / 3600.0)
		var days: int = hours / 24
		hours %= 24
		return "%d ngày %d giờ" % [days, hours] if hours > 0 else "%d ngày" % days
	var minutes: int = ceili(seconds / 60.0)
	if minutes < 60:
		return "%d phút" % minutes
	return "%d giờ %d phút" % [minutes / 60, minutes % 60] if minutes % 60 > 0 else "%d giờ" % (minutes / 60)



static func card_time(rec: Dictionary) -> Array:
	if bool(rec.get("expired", false)):
		return ["Quá hạn", ""]
	if not bool(rec.get("timed", false)):
		return ["Không hạn chế", ""]
	if bool(rec.get("started", false)):
		return ["T/g còn: " + fmt_left(int(rec.left)), ""]
	var days: String = "T/g còn: %d ngày" % (int(rec.get("left", 0)) / 86400)
	return [days, " (Chưa kích hoạt)" if str(rec.get("cat", "")) == "fashion" else ""]


static func avatar_fx(fx: Dictionary, id: int) -> String:
	var pair: Array = fx.get(str(id), [0, 0])
	var out: String = ""
	if int(pair[1]) > 0:
		out += "EXP +%d%% " % int(pair[1])
	if int(pair[0]) > 0:
		out += "Bạc +%d%%" % int(pair[0])
	return out.strip_edges()


static func decor_fx(fx: Dictionary, id: int) -> String:
	var pair: Array = fx.get(str(id), [0, 0])
	var out: String = ""
	if int(pair[0]) > 0:
		out += "Bạc +%d%% " % int(pair[0])
	if int(pair[1]) > 0:
		out += "Vật Liệu PB+%d%%" % int(pair[1])
	return out.strip_edges()


static func card_order(list: Array) -> Array:
	var out: Array = list.duplicate()
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		var ra: int = 2 if bool(a.get("expired", false)) else (1 if bool(a.get("timed", false)) else 0)
		var rb: int = 2 if bool(b.get("expired", false)) else (1 if bool(b.get("timed", false)) else 0)
		return ra < rb if ra != rb else int(a.get("slot", 0)) < int(b.get("slot", 0)))
	return out



static func honor_pick(worn: Array, id: int) -> Array:
	var out: Array = []
	for value: Variant in worn:
		out.append(int(value))
	if out.is_empty():
		return [id]
	var at: int = out.find(id)
	if at > 0:
		out[at] = out[0]
	out[0] = id
	return out


static func acem_stats(acem: Dictionary, done: Dictionary) -> Array:
	var points: int = 0
	var count: int = 0
	for key: String in acem:
		if _acem_done(done, int(key)):
			points += int(acem[key][3])
			count += 1
	return [points, count, acem.size()]


static func acem_list(acem: Dictionary, done: Dictionary, filter: int) -> Array:
	var out: Array = []
	for key: String in acem:
		var finished: bool = _acem_done(done, int(key))
		if filter == 0 or (filter == 1 and finished) or (filter == 2 and not finished):
			out.append(int(key))
	return out

static func _acem_done(done: Dictionary, id: int) -> bool:
	var pair: Variant = done.get(id, null)
	return pair is Array and (pair as Array).size() > 0 and int(pair[0]) == 2


static func acem_count(done: Dictionary, id: int) -> int:
	var pair: Variant = done.get(id, null)
	return int(pair[1]) if pair is Array and (pair as Array).size() > 1 else 0


static func pvp_coins(bags: Dictionary) -> int:
	var total: int = 0
	for cont: Variant in bags:
		for inst: Dictionary in bags[cont]:
			if int(inst.get("m_templateId", 0)) == PVP_COIN:
				total += maxi(1, int(inst.get("m_count", 1)))
	return total

static func pages(total: int, per: int) -> int:
	return maxi(1, ceili(total / float(maxi(1, per))))


static func game_stats(tech: Array) -> Array:
	var wins: int = int(tech[GCOUNT_WIN]) if tech.size() > GCOUNT_WIN else 0
	var lost: int = int(tech[GCOUNT_LOST]) if tech.size() > GCOUNT_LOST else 0
	var escape: int = int(tech[GCOUNT_ESCAPE]) if tech.size() > GCOUNT_ESCAPE else 0
	var total: int = wins + lost + escape
	return [wins, int(escape / float(total) * 100.0) if total > 0 else 0]
