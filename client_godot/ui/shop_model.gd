extends RefCounted




const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")


const CATS: Array = [[1, "Đề cử"], [2, "Tank"], [7, "Skin"], [3, "Thời trang"], [9, "Trang trí"], [4, "Vật phẩm"], [5, "Nguyên liệu"], [6, "Trợ thủ"]]
const FILTERS: Array = [["all", "Toàn bộ"], ["sale", "SALE"], ["bound", "Xu Khóa"]]
const COIN_NAME: Array = ["Xu", "Xu Khóa", "Bạc"]
const COIN_KEY: Array = ["m_iCash", "m_iSilver", "m_iGolden"]
const DAYS: Array = [30, 90, 365]
const KINDS: Dictionary = {2: "Tank", 3: "Thời trang", 4: "Vật phẩm", 5: "Nguyên liệu", 6: "Skin", 8: "Trang trí"}
const BUY: int = 1
const RENEW_AVATAR: int = 7
const RENEW_DECOR: int = 14
const COUNT_CAP: int = 999


static func coin_index(ct: int) -> int:
	return 1 if ct == 3 else (2 if ct == 2 else 0)

static func balance(currency: Dictionary, ct: int) -> int:
	return int(currency.get(COIN_KEY[coin_index(ct)], 0))


static func parse(body: PackedByteArray) -> Array:
	var out: Array = []
	var parser: XMLParser = XMLParser.new()
	if body.is_empty() or parser.open_buffer(body) != OK:
		return out
	while parser.read() == OK:
		if parser.get_node_type() != XMLParser.NODE_ELEMENT or parser.get_node_name() != "row":
			continue
		var a: Dictionary = {}
		for i in range(parser.get_attribute_count()):
			a[parser.get_attribute_name(i)] = parser.get_attribute_value(i)
		var n: Callable = func(key: String) -> int: return int(str(a.get(key, "0")))
		var rec: Dictionary = {"gid": n.call("goods_id"), "gt": n.call("goods_type"), "tid": n.call("template_oid"), 
			"lv": n.call("limit_level"), "vip": n.call("vip_level"), "cnt": maxi(1, n.call("count_1")), 
			"cnts": [n.call("count_1"), n.call("count_2"), n.call("count_3")], 
			"ct": n.call("coin_type"), "ct2": n.call("coin_type2"), 
			"p": [n.call("price1"), n.call("price2"), n.call("price3")], 
			"p2": [n.call("price2_1"), n.call("price2_2"), n.call("price2_3")], 
			"a": [n.call("agio_price1"), n.call("agio_price2"), n.call("agio_price3")], 
			"a2": [n.call("agio_price2_1"), n.call("agio_price2_2"), n.call("agio_price2_3")], 
			"agio": n.call("is_agio") == 1, "hot": n.call("is_hot") == 1, "fresh": n.call("is_new") == 1}
		if int(rec.gid) <= 0:
			continue
		rec["gift"] = int(rec.ct) == 1 and n.call("can_use_gift") == 1
		rec["alt"] = int(rec.ct2) > 0 and int(rec.p2[0]) > 0 and int(rec.ct2) != int(rec.ct)
		rec["timed"] = int(rec.gt) == 3 or int(rec.gt) == 8
		rec["sale"] = rec.agio and (int(rec.a[0]) > 0 or int(rec.a[1]) > 0 or int(rec.a[2]) > 0)
		rec["limit"] = n.call("is_limit_count") == 1 or n.call("char_limit_count") > 0
		rec["ltime"] = n.call("is_limit_time") == 1
		rec["key"] = str(rec.gid)
		out.append(rec)
	return out



static func describe(rec: Dictionary, bag: Dictionary, garage: Dictionary, names: Dictionary, defaults: Dictionary) -> bool:
	var tid: String = str(int(rec.tid))
	var gt: int = int(rec.gt)
	rec["name"] = ""
	rec["desc"] = ""
	rec["quality"] = 0
	rec["icon"] = ""
	rec["face"] = ""
	rec["avatar"] = false
	rec["art"] = ""
	rec["tank"] = 0
	if gt == 2:
		if not names.has(tid):
			return false
		rec.name = BagModel.clean(str(names[tid]))
		var info: Dictionary = garage.get("tanks", {}).get(tid, {})
		var cls: String = str(GarageModel.CLASSES.get(int(info.get("cls", 0)), ""))
		var pos: String = BagModel.clean(str(info.get("pos", "")))
		rec.desc = BagModel.clean(str(info.get("desc", "")))
		if rec.desc.is_empty():
			rec.desc = ("Lớp xe: " + cls if not cls.is_empty() else "") + ("\n" if not cls.is_empty() and not pos.is_empty() else "") + pos
		rec.quality = 4
		rec.tank = int(rec.tid)
		var face: String = GarageModel.face(garage, int(defaults.get(tid, 0)))
		rec.face = "l/t/%s.webp" % face if not face.is_empty() else ""
		rec.art = rec.face
		return not str(rec.name).is_empty()
	var row: Array = bag.get("items", {}).get(tid, [])
	if row.size() >= 10:
		rec.name = BagModel.clean(str(row[0]))
		rec.desc = BagModel.clean(str(row[1]))
		rec.quality = int(row[3])
		var key: String = str(row[2])
		if int(row[5]) == 4:
			rec.avatar = true
			rec.art = "l/av/%s.webp" % key if not key.is_empty() else ""
		elif not key.is_empty():
			rec.icon = "l/it/%s.webp" % key
	else:
		var more: Array = bag.get("more", {}).get(tid, [])
		if more.size() < 4:
			return false
		rec.name = BagModel.clean(str(more[0]))
		rec.quality = int(more[2])
		if not str(more[1]).is_empty():
			rec.icon = "l/it/%s.webp" % str(more[1])
	if gt == 6:

		var skin: Array = garage.get("skin_items", {}).get(tid, [])
		if skin.size() >= 2:
			rec.tank = int(skin[0])
			var face: String = GarageModel.face(garage, int(skin[1]))
			rec.face = "l/t/%s.webp" % face if not face.is_empty() else ""
			var owner: String = BagModel.clean(str(names.get(str(int(skin[0])), "")))
			if not owner.is_empty() and rec.desc.is_empty():
				rec.desc = "Skin của xe " + owner + "."
	if str(rec.name).is_empty():
		return false
	if rec.art.is_empty():
		rec.art = rec.face if not str(rec.face).is_empty() else rec.icon
	return true



static func tiers(rec: Dictionary, coin: int) -> Array:
	var base: Array = rec.p if coin == 0 else rec.p2
	var cut: Array = rec.a if coin == 0 else rec.a2
	var out: Array = []
	if rec.timed:
		var use_cut: bool = rec.agio and (int(cut[0]) > 0 or int(cut[1]) > 0 or int(cut[2]) > 0)
		var table: Array = cut if use_cut else base
		for k in range(3):
			if int(table[k]) > 0:
				out.append({"k": k, "unit": int(table[k]), "old": int(base[k]) if use_cut and int(base[k]) != int(table[k]) else 0})
		if out.is_empty():
			out.append({"k": 0, "unit": int(base[0]), "old": 0})
		return out
	var unit: int = int(cut[0]) if rec.agio and int(cut[0]) > 0 else int(base[0])
	out.append({"k": 0, "unit": unit, "old": int(base[0]) if unit != int(base[0]) else 0})
	return out


static func pay_coin(rec: Dictionary, coin: int) -> int:
	return int(rec.ct2) if coin == 1 and rec.alt else int(rec.ct)

static func days_text(rec: Dictionary, tier: Dictionary) -> String:
	if rec.timed:
		return "%d ngày" % int(DAYS[int(tier.k)])
	return "Gói ×%d" % int(rec.cnt) if int(rec.cnt) > 1 else ""


static func spendable(rec: Dictionary, coin: int, currency: Dictionary) -> int:
	var ct: int = pay_coin(rec, coin)
	var have: int = balance(currency, ct)
	if ct == 1 and rec.gift:
		have += balance(currency, 3)
	return have


static func owned(rec: Dictionary, tanks: Dictionary, bags: Dictionary) -> int:
	match int(rec.gt):
		2:
			for inst: Dictionary in tanks.values():
				if int(inst.get("m_tpltId", 0)) == int(rec.tid) and int(inst.get("m_contType", -1)) == GarageModel.OWN:
					return 1
		6:
			for inst: Dictionary in bags.get(6, []):
				if int(inst.get("m_templateId", 0)) == int(rec.tid):
					return 1
		3, 8:
			for inst: Dictionary in bags.get(4 if int(rec.gt) == 3 else 7, []):
				if int(inst.get("m_templateId", 0)) == int(rec.tid):
					return 2
	return 0


static func multi(rec: Dictionary) -> bool:
	return int(rec.gt) in [4, 5]


static func passes(rec: Dictionary, filter: String) -> bool:
	match filter:
		"sale":
			return rec.sale
		"bound":
			return int(rec.ct) == 3 or (rec.alt and int(rec.ct2) == 3) or rec.gift
	return true


static func buy_type(rec: Dictionary, renew: bool) -> int:
	if not renew:
		return BUY
	return RENEW_DECOR if int(rec.gt) == 8 else RENEW_AVATAR
