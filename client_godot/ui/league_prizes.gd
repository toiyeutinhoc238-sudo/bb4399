extends "league_reward.gd"





var source: Array = []
var _key: String = ""
var _rows: Array = []

func prizes() -> Array:
	var items: Dictionary = pack.bag.get("items", {}) if pack != null else {}
	var key: String = "%d|%d" % [source.hash(), items.size()]
	if key != _key:
		_key = key
		_rows = build(source, items)
	return _rows

static func _n(value: Variant) -> int:
	if value is int or value is float:
		return int(value)
	if value is String and (value as String).is_valid_float():
		return int(float(value))
	return 0


static func build(rows: Array, items: Dictionary) -> Array:
	var out: Array = []
	for row: Variant in rows:
		if not row is Dictionary:
			continue
		var prize: Dictionary = row
		var cells: Array = []
		if _n(prize.get("tz_gift", 0)) > 0:
			cells.append(["gift", _n(prize.get("tz_gift", 0))])
		if _n(prize.get("tz_coin", 0)) > 0:
			cells.append(["money", _n(prize.get("tz_coin", 0))])
		for i: int in range(1, 6):
			var id: int = _n(prize.get("tz_item%d" % i, 0))
			if id <= 0:
				continue
			var found: Variant = items.get(str(id))
			var more: Array = found if found is Array else []
			var name: String = BagModel.clean(str(more[0])) if not more.is_empty() else ""
			cells.append([id, _n(prize.get("tz_itemcnt%d" % i, 0)), name if not name.is_empty() else "Vật phẩm %d" % id, 
				str(more[2]) if more.size() > 2 else "", _n(more[3]) if more.size() > 3 else 1])
		out.append([0, str(prize.get("tz_name", "")), cells])
	return out
