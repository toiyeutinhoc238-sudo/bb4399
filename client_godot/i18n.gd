extends RefCounted


static var _maps: Dictionary = {}

const EXTRA_MAPS: Dictionary = {
	"40101": {"name": "Hẻm Núi Cát Đỏ", "mode": "Boss Guild", "goal": "Diệt BOSS", "modeType": 0, "rounds": 0, "type": 16, "boss": "Giáp Thép Sa Mạc"}, 
	"40102": {"name": "Pháo Đài Băng Giá", "mode": "Boss Guild", "goal": "Diệt BOSS", "modeType": 0, "rounds": 0, "type": 16, "boss": "Bạo Chúa Băng Nguyên"}, 
	"40103": {"name": "Lõi Núi Lửa", "mode": "Boss Guild", "goal": "Diệt BOSS", "modeType": 0, "rounds": 0, "type": 16, "boss": "Hắc Long Cơ Giới"}}

static func map_name(id: int) -> String:
	return str(map_info(id).get("name", "Bản đồ %d" % id))


static func map_info(id: int) -> Dictionary:
	if _maps.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/i18n/maps.json"))
		_maps = parsed if parsed is Dictionary else {"": {}}
		for key: String in EXTRA_MAPS:
			if not _maps.has(key):
				_maps[key] = EXTRA_MAPS[key]
	return _maps.get(str(id), {})

static func clock(seconds: int) -> String:
	seconds = maxi(0, seconds)
	return "%02d:%02d" % [seconds / 60, seconds % 60]
