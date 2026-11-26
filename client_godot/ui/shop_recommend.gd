extends RefCounted













const RecommendData = preload("shop_recommend_data.gd")

const FRAME: Vector2 = Vector2(169, 89)
const WIDE: float = 214.0
const CELL_X: float = 23.0
const CELL_X_PLAIN: float = 123.0
const RADIO_Y: Array = [1.0, 31.0, 61.0]
const LABEL_Y: Array = [5.0, 35.0, 65.0]
const AGIO_Y: Array = [0.0, 36.0, 66.0]
const LABEL_X: float = 34.0
const LABEL_WIDE: float = 140.0
const AGIO: Color = Color("ff8c00")
const TEXT302: String = "@num1@ Xu/ @num2@ "
const TEXT303: String = "Sale @num1@ %"
const TEXT15: String = "@coinType@/@num1@ ngày"
const DAYS: Array = [7, 30, 365]
const SKIN_GT: int = 6


static func reuse_d(tid: int) -> int:
	return int(RecommendData.REUSE_D.get(tid, 0))


static func skin(rec: Dictionary) -> bool:
	return int(rec.get("reuse_d", reuse_d(int(rec.get("tid", 0))))) > 0


static func counts(rec: Dictionary) -> Array:
	var raw: Variant = rec.get("cnts", rec.get("cnt", 0))
	if raw is Array and (raw as Array).size() >= 3:
		return [int(raw[0]), int(raw[1]), int(raw[2])]
	return [int(raw), 0, 0]


static func active(rec: Dictionary) -> bool:
	return int(counts(rec)[0]) > 0 or skin(rec)


static func label_price(rec: Dictionary, k: int) -> int:
	return int((rec.a if rec.get("agio", false) else rec.p)[k])



static func unit(rec: Dictionary, coin: int, k: int) -> int:
	var base: Array = rec.p if coin == 0 else rec.p2
	var cut: Array = rec.a if coin == 0 else rec.a2
	return int(cut[k]) if rec.get("agio", false) and int(cut[k]) > 0 else int(base[k])


static func rows(rec: Dictionary, coin_name: String) -> Array:
	var out: Array = []
	if skin(rec):
		var tail: String = TEXT15.replace("@coinType@", coin_name)
		for k in range(3):
			if int(rec.p[k]) > 0:
				out.append({"k": k, "text": str(label_price(rec, k)) + tail.replace("@num1@", str(int(DAYS[k]))), "agio": ""})
		return out
	var cnt: Array = counts(rec)
	var shown: Array = [true, int(cnt[1]) > 0 and label_price(rec, 1) > 0, int(cnt[2]) > 0 and label_price(rec, 2) > 0]
	if not shown[1] and not shown[2]:
		return out
	for k in range(3):
		var price: int = label_price(rec, k)
		if not shown[k]:
			continue
		var text: String = TEXT302.replace("@num1@", str(price)).replace("@num2@", str(int(cnt[k])))
		var cut: String = agio_text(price, label_price(rec, 0), int(cnt[k]), int(cnt[0])) if k > 0 else ""
		out.append({"k": k, "text": text, "agio": cut})
	return out


static func agio_text(price: int, first: int, count: int, first_count: int) -> String:
	if first <= 0 or count <= 0 or first_count <= 0:
		return ""
	var whole: bool = (price * 10) % first == 0
	var rate: float = float(price) * 10.0 / (float(first) * float(count) / float(first_count))
	if is_equal_approx(rate, 10.0):
		return ""
	return TEXT303.replace("@num1@", str(int(rate)) if whole else "%.1f" % rate)



static func initial(rec: Dictionary, buy_count: int, shown: Array) -> int:
	if shown.is_empty():
		return 0
	if not skin(rec):
		var cnt: Array = counts(rec)
		for k: int in [2, 1]:
			for row: Dictionary in shown:
				if int(row.k) == k and buy_count >= int(cnt[k]):
					return k
	return int(shown[0].k)



static func resets(rec: Dictionary, _buy_count: int) -> bool:
	return not skin(rec)


static func has_row(shown: Array, k: int) -> bool:
	for row: Dictionary in shown:
		if int(row.k) == k:
			return true
	return false
