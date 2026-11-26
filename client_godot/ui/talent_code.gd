extends RefCounted





const Atlas = preload("talent_atlas.gd")

const GRID_CODE_LEN: int = 2
const CODE_MAX: int = 30
const WATCH_CODE_MAX: int = 256
const NAME_MAX: int = 16
const ATK: int = 1
const DEF: int = 2
const COMM: int = 3
const DIGITS: String = "0123456789abcdefghijklmnopqrstuvwxyz"




static func row(id: int) -> Array:
	return Atlas.TALENTS.get(str(id), [])

static func series_of(id: int) -> int:
	var r: Array = row(id)
	return int(r[0]) if not r.is_empty() else 0

static func group_of(id: int) -> int:
	var r: Array = row(id)
	return int(r[1]) if not r.is_empty() else 0

static func max_lv(id: int) -> int:
	var r: Array = row(id)
	return int(r[3]) if not r.is_empty() else 0


static func group_max(series: int, group: int) -> int:
	return int(Atlas.GROUPS.get("%d_%d" % [series, group], 0))


static func need_lv(series: int, group: int) -> int:
	var total: int = 0
	for key: String in Atlas.GROUPS:
		var parts: PackedStringArray = key.split("_")
		if int(parts[0]) == series and int(parts[1]) < group:
			total += int(Atlas.GROUPS[key])
	return total


static func math(id: int, name: String) -> int:
	return int(Atlas.MATH.get(str(id), {}).get(name, 0))


static func loc_template(series: int, group: int, slot: int, level: int = 0) -> int:
	for key: String in Atlas.TALENTS:
		var r: Array = Atlas.TALENTS[key]
		if int(r[0]) == series and int(r[1]) == group and int(r[2]) == slot and int(r[3]) >= level:
			return int(key)
	return 0



static func clone(tree: Array) -> Array:
	var out: Array = []
	for cell: Variant in tree:
		if cell is Array and (cell as Array).size() >= 2:
			out.append([int(cell[0]), int(cell[1])])
	return out


static func active(tree: Array) -> int:
	var total: int = 0
	for cell: Array in tree:
		total += int(cell[1])
	return total

static func level_of(tree: Array, id: int) -> int:
	for cell: Array in tree:
		if int(cell[0]) == id:
			return int(cell[1])
	return 0


static func series_total(tree: Array, series: int) -> int:
	var total: int = 0
	for cell: Array in tree:
		if series_of(int(cell[0])) == series:
			total += int(cell[1])
	return total


static func group_total(tree: Array, series: int, group: int) -> int:
	var total: int = 0
	for cell: Array in tree:
		var id: int = int(cell[0])
		if series_of(id) == series and group_of(id) == group:
			total += int(cell[1])
	return total


static func series_max_group(tree: Array, series: int) -> int:
	var top: int = 1
	for cell: Array in tree:
		var id: int = int(cell[0])
		if series_of(id) == series and group_of(id) > top:
			top = group_of(id)
	return top


static func crux_series(tree: Array) -> int:
	var counts: Dictionary = {ATK: 0, DEF: 0, COMM: 0}
	for cell: Array in tree:
		var s: int = series_of(int(cell[0]))
		if counts.has(s):
			counts[s] += 1
	var top: int = maxi(int(counts[ATK]), maxi(int(counts[DEF]), int(counts[COMM])))
	for s: int in [ATK, DEF, COMM]:
		if int(counts[s]) == top:
			return s
	return 0


static func is_equal(a: Array, b: Array) -> bool:
	if a.size() != b.size():
		return false
	var x: Array = clone(a)
	var y: Array = clone(b)
	x.sort_custom( func(p: Array, q: Array) -> bool: return int(p[0]) < int(q[0]))
	y.sort_custom( func(p: Array, q: Array) -> bool: return int(p[0]) < int(q[0]))
	for i in range(x.size()):
		if int(x[i][0]) != int(y[i][0]) or int(x[i][1]) != int(y[i][1]):
			return false
	return true


static func fit(tree: Array, max_point: int) -> Array:
	var out: Array = clone(tree)
	var points: int = active(out)
	if points <= max_point:
		return out
	var crux: int = crux_series(out)
	out.sort_custom( func(p: Array, q: Array) -> bool:
		var a: int = int(p[0])
		var b: int = int(q[0])
		var sa: int = series_of(a)
		var sb: int = series_of(b)
		if sa == sb:
			return a < b
		if sa == crux:
			return true
		if sb == crux:
			return false
		return a > b)
	var index: int = out.size()
	while index > 0:
		var over: int = points - max_point
		if over <= 0:
			break
		var cell: Array = out[index - 1]
		if over >= int(cell[1]):
			points -= int(cell[1])
			out.pop_back()
		else:
			cell[1] = int(cell[1]) - over
			points -= over
		index -= 1
	return out


static func is_available(tree: Array, id: int, level: int, max_point: int) -> bool:
	var r: Array = row(id)
	if r.is_empty() or level > int(r[3]):
		return false
	var s: int = int(r[0])
	var g: int = int(r[1])
	if series_total(tree, s) < need_lv(s, g):
		return false
	if active(tree) >= max_point and group_total(tree, s, g) < group_max(s, g) and level == 0:
		return false
	return true


static func is_tree_available(tree: Array, max_point: int) -> bool:
	if tree.is_empty():
		return true
	if active(tree) > max_point:
		return false
	for cell: Array in tree:
		var r: Array = row(int(cell[0]))
		if r.is_empty() or int(cell[1]) > int(r[3]):
			return false
		var s: int = int(r[0])
		var g: int = int(r[1])
		if group_total(tree, s, g) > group_max(s, g):
			return false
		if series_total(tree, s) < need_lv(s, g):
			return false
	return true


static func transform(tree: Array, id: int, delta: int, max_point: int) -> Variant:
	if delta == 0:
		return null
	var r: Array = row(id)
	if r.is_empty():
		return null
	var s: int = int(r[0])
	var g: int = int(r[1])
	var cap: int = group_max(s, g)
	var cells: Array = clone(tree)
	if g < series_max_group(cells, s):
		if delta < 0:
			return null
	elif active(cells) >= max_point and group_total(cells, s, g) < cap and delta > 0:
		return null
	var by_id: Dictionary = {}
	for cell: Array in cells:
		by_id[int(cell[0])] = cell
	var mine: Variant = by_id.get(id)
	if mine == null:
		if delta < 0 or delta > int(r[3]):
			return null
		mine = [id, delta]
		by_id[id] = mine
		cells.append(mine)
	else:
		mine[1] = int(mine[1]) + delta
		if int(mine[1]) < 0 or int(mine[1]) > int(r[3]):
			return null
	var total: int = group_total(cells, s, g)
	if total > cap:
		var extra: int = total - cap
		for cell: Array in cells:
			var other: int = int(cell[0])
			if int(cell[1]) == 0 or other == id or series_of(other) != s or group_of(other) != g:
				continue
			if extra <= int(cell[1]):
				cell[1] = int(cell[1]) - extra
				extra = 0
				break
			extra -= int(cell[1])
			cell[1] = 0
	var out: Array = []
	for key: int in by_id:
		if int(by_id[key][1]) > 0:
			out.append([key, int(by_id[key][1])])
	return out




static func base36(value: int) -> String:
	return String.num_int64(maxi(0, value), 36)


static func parse36(text: String) -> int:
	var value: int = 0
	for i in range(text.length()):
		var digit: int = DIGITS.find(text[i])
		if digit < 0:
			return -1
		value = value * 36 + digit
	return value


static func encode_grid(id: int, level: int) -> String:
	var r: Array = row(id)
	if r.is_empty():
		return ""
	return base36((int(r[0]) << 8) | (int(r[1]) << 5) | (int(r[2]) << 3) | level)


static func encode(tree: Array) -> String:
	var out: String = ""
	for cell: Array in clone(tree):
		var part: String = encode_grid(int(cell[0]), int(cell[1]))
		if part.is_empty():
			return ""
		out += part
	return out


static func decode_grid(text: String) -> Array:
	var value: int = parse36(text)
	if value < 0:
		return []
	var level: int = value & 7
	var slot: int = (value & 31) >> 3
	var group: int = (value & 255) >> 5
	var series: int = (value & 1023) >> 8
	var id: int = loc_template(series, group, slot, level)
	if id == 0:
		return []
	return [id, level]


static func decode(code: String) -> Array:
	var out: Array = []
	var at: int = 0
	while at < code.length():
		var cell: Array = decode_grid(code.substr(at, GRID_CODE_LEN))
		if cell.is_empty():
			return []
		out.append(cell)
		at += GRID_CODE_LEN
	return out

static func _clean_code(code: String) -> bool:
	for i in range(code.length()):
		if DIGITS.find(code[i]) < 0:
			return false
	return true


static func is_code_available(code: String) -> bool:
	if code.length() > CODE_MAX or code.length() % GRID_CODE_LEN != 0 or not _clean_code(code):
		return false
	var tree: Array = decode(code)
	return not tree.is_empty() and is_tree_available(tree, active(tree))


static func valid_watch_code(code: Variant) -> Array:
	if not code is String:
		return []
	var text: String = code
	if text.is_empty() or text.length() > WATCH_CODE_MAX or not is_code_available(text):
		return []
	var tree: Array = decode(text)
	var seen: Dictionary = {}
	for cell: Array in tree:
		var id: int = int(cell[0])
		if row(id).is_empty() or int(cell[1]) < 0 or int(cell[1]) > max_lv(id) or seen.has(id):
			return []
		seen[id] = true
	return tree


static func clean_name(name: Variant) -> String:
	if not name is String:
		return ""
	var raw: String = name
	var out: String = ""
	for i in range(raw.length()):
		var ch: String = raw[i]
		var code: int = raw.unicode_at(i)
		if code < 32 or code == 127 or (code >= 128 and code < 160) or code in [8203, 8206, 8207, 8234, 8235, 8236, 8237, 8238, 8294, 8295, 8296, 8297, 65279]:
			continue
		if ch in ["[", "]", "<", ">", "{", "}"]:
			continue
		out += ch
	while out.contains("  "):
		out = out.replace("  ", " ")
	return out.strip_edges().left(NAME_MAX)




static func num_text(value: float) -> String:
	if is_equal_approx(value, roundf(value)):
		return str(int(roundf(value)))
	var text: String = String.num(value, 6)
	return text


static func desc(id: int, level: int) -> String:
	var r: Array = row(id)
	if r.is_empty():
		return ""
	level = level if level > 0 else 1
	var text: String = str(r[9])
	var logic: Array = Atlas.LOGIC.get("%d_%d" % [id, level], [])
	var v1: float = absf(float(logic[0])) if logic.size() > 0 else 0.0
	var v2: float = absf(float(logic[1])) if logic.size() > 1 else 0.0
	text = _replace_first(text, "@int1@", num_text(v1))
	text = _replace_first(text, "@int2@", num_text(v2))
	text = _replace_first(text, "@float1@", "%.1f%%" % (v1 * 100.0))
	text = _replace_first(text, "@float2@", "%.1f%%" % (v2 * 100.0))
	return text

static func _replace_first(text: String, key: String, value: String) -> String:
	var at: int = text.find(key)
	if at < 0:
		return text
	return text.substr(0, at) + value + text.substr(at + key.length())


static func radar(tree: Array, attrs: Array) -> Array:
	if attrs.size() < 6:
		return []
	var sums: Array = [1000.0, 1000.0, 1000.0, 1000.0, 1000.0, 1000.0]
	for cell: Array in tree:
		if int(cell[1]) == 0:
			continue
		var logic: Array = Atlas.LOGIC.get("%d_%d" % [int(cell[0]), int(cell[1])], [])
		if logic.size() < 8:
			continue
		for n in range(6):
			sums[n] += float(logic[2 + n])
	var base: float = float(maxi(1, math(64, "VAL1")))
	var out: Array = []
	for n in range(6):
		out.append(float(attrs[n]) * (float(sums[n]) / 1000.0) / base)
	return out


static func next_page_name(pages: Array) -> String:
	var n: int = 1
	while true:
		var name: String = str(Atlas.WORDS["CONTROL_TEXT601"]).replace("@num1@", str(n))
		var used: bool = false
		for page: Variant in pages:
			if page is Dictionary and str(page.get("name", "")) == name:
				used = true
				break
		if not used:
			return name
		n += 1
	return ""
