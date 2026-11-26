extends RefCounted









const Settings = preload("res://settings.gd")



const LIST: Array = [
	{"id": "island", "name": "Sảnh Alpha Test", "preview": ["l/island/alpha/d_sea.webp", "l/island/alpha/d_bk.webp"], "ready": true, 
		"check": "_isle_ready", "build": "_draw_island", "bar": "", 
		"day_night": true, "fx": true, "note": "Lễ khai trương: bóng bay, pháo giấy; đêm có đèn rọi, pháo hoa", "event": "", 
		"low_note": "Độ nét Thấp: ít bóng bay, pháo giấy thưa, pháo hoa thưa."}, 
	{"id": "noel", "name": "Sảnh Noel", "preview": ["l/island/noel/d_sea.webp", "l/island/noel/d_bk.webp"], "ready": true, 
		"check": "_isle_ready", "build": "_draw_island", "bar": "", 
		"day_night": true, "fx": true, "note": "Mùa Noel 24/10 – 05/01: tuyết, đèn, ngày / đêm; ngoài mùa là đảo thường", "event": "noel", 
		"low_note": "Độ nét Thấp: 1 lớp tuyết, không xe tuần lộc, đèn chỉ quầng."}, 
]








const CUOI_MODE: String = "off"
static var cuoi_ok: bool = false
const CUOI: Dictionary = {"id": "cuoi", "kind": "cuoi", "name": "Sảnh Cưới", "preview": ["l/island/cuoi/d_sea.webp", "l/island/cuoi/d_bk.webp"], 
	"ready": true, "check": "_isle_ready", "build": "_draw_island", "bar": "", 
	"day_night": true, "fx": true, "note": "Lễ đường cưới Rurin ♥ Coca: cánh hoa rơi; đêm có dây đèn, nến, tháp ly", "event": "", 
	"low_note": "Độ nét Thấp: cánh hoa thưa, chỉ một quầng tháp ly."}


static func cuoi_mode() -> String:
	return "default" if cuoi_ok else CUOI_MODE

static func entries() -> Array:
	var out: Array = LIST.filter( func(entry: Dictionary) -> bool: return bool(entry.get("ready", false)))
	var mode: String = cuoi_mode()
	if mode == "option":
		out.insert(mini(1, out.size()), CUOI)
	elif mode == "default" and not out.is_empty() and str(out[0]["id"]) == "island":
		var alpha: Dictionary = out[0].duplicate()
		alpha["id"] = "alpha"
		alpha["kind"] = "island"
		var wed: Dictionary = CUOI.duplicate()
		wed["id"] = "island"
		out[0] = wed
		out.insert(1, alpha)
	return out


static func kind(entry: Dictionary) -> String:
	return str(entry.get("kind", entry.get("id", "")))

static func find(id: String) -> Dictionary:
	for entry: Dictionary in entries():
		if str(entry["id"]) == id:
			return entry
	return {}


static func supports(entry: Dictionary, flag: String) -> bool:
	return bool(entry.get(flag, false))


static func current() -> Dictionary:
	var found: Dictionary = find(str(Settings.value("lobby_theme")))
	if not found.is_empty():
		return found
	var all: Array = entries()
	return all[0] if not all.is_empty() else {}
