extends RefCounted




const DIR: String = "res://assets/ui/proficiency/"

const TIERS: Array = [
	[300, "jianxi", "Tập Sự"], 
	[1000, "jingying", "Lão Luyện"], 
	[2500, "gaoshou", "Tinh Anh"], 
	[5000, "dashi", "Chuyên Gia"], 
	[10000, "zongshi", "Tông Sư"], 
	[20000, "wangzhe", "Huyền Thoại"], 
	[999999, "chuanshuo", "Chí Tôn"], 
]
const TITLE: String = "THÔNG THẠO"
const NAME_INK: Color = Color("bdcde6")
const NUM_INK: Color = Color("5eff33")

static var _tex: Dictionary = {}

static func tier(val: int) -> int:
	if val < 0:
		return -1
	for i in range(TIERS.size()):
		if val < int(TIERS[i][0]):
			return i
	return TIERS.size() - 1

static func tier_name(val: int) -> String:
	var i: int = tier(val)
	return str(TIERS[i][2]) if i >= 0 else ""


static func progress(val: int) -> String:
	var i: int = tier(val)
	if i < 0:
		return ""
	var top: int = int(TIERS[i][0])
	return "%d/%d" % [mini(val, top), top]


static func ratio(val: int) -> float:
	var i: int = tier(val)
	if i < 0:
		return 0.0
	var top: int = int(TIERS[i][0])
	return clampf(float(mini(val, top)) / float(maxi(1, top)), 0.0, 1.0)


static func tip(val: int) -> String:
	return "%s: %s" % [tier_name(val), progress(val)] if tier(val) >= 0 else ""

static func _load(file: String) -> Texture2D:
	var hit: Variant = _tex.get(file, false)
	if hit is bool:
		hit = load(DIR + file) if ResourceLoader.exists(DIR + file) else null
		_tex[file] = hit
	return hit


static func icon(val: int, big: bool) -> Texture2D:
	var i: int = tier(val)
	if i < 0:
		return null
	return _load("%s_%s.png" % [str(TIERS[i][1]), "l" if big else "m"])


static func of_tank(tank: Dictionary) -> int:
	return int(tank.get("m_proficiencyVal", -1)) if tank.has("m_proficiencyVal") else -1
