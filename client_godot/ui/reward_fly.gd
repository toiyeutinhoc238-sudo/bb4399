extends RefCounted





const Atlas = preload("quest_atlas.gd")
const LobbyBar = preload("lobby_bar.gd")
const NO_LAND: Vector2 = Vector2(-1.0, -1.0)
const END_SCALE: float = 0.2
const POP_LIFT: float = 7.0
const PackageAtlas = preload("reward_popup_atlas.gd")
const BagModel = preload("bag_model.gd")
const BOUND_TIME: float = 0.7
const LENGTH_STEPS: int = 6
const PACKAGE_META: StringName = &"reward_fly_package"

static func reset(host: Variant) -> void :
	if host.has_meta(PACKAGE_META):
		host.remove_meta(PACKAGE_META)

static func begin(host: Variant, info: Dictionary) -> Array:
	var items: Array = info.get("base_items", info.get("items", []))
	var coins: Array = info.get("coins", [info.get("cash", 0), info.get("gift", 0), info.get("golden", 0)])
	var count: int = items.size()
	var added: Array = []
	for index: int in count:
		var pair: Variant = items[index]
		if not (pair is Array) or (pair as Array).is_empty():
			continue
		var art: String = _item_art(host, int(pair[0]))
		if art.is_empty() and not (host.has_method("_reward_cell") and not str(host._reward_cell(int(pair[0]))).is_empty()):
			art = BagModel.alt_of(int(pair[0]), host.pack.bag)
		if not art.is_empty():
			added.append({"art": art, "i": index})
		elif host.has_method("_reward_cell") and not str(host._reward_cell(int(pair[0]))).is_empty():
			added.append({"cell": str(host._reward_cell(int(pair[0]))), "i": index})

	if coins.size() > 2 and int(coins[2]) > 0:
		added.append({"cell": "qu_fly_gold", "i": count})
	if coins.size() > 1 and int(coins[1]) > 0:
		added.append({"cell": "qu_fly_gift", "i": count})
	var now: float = float(host._time)
	for fly: Dictionary in added:
		var order: float = float(fly["i"])
		fly["n"] = count
		fly["born"] = now
		fly["end"] = now + 1.7 + 0.2 * order + maxf(0.2, 1.0 - 0.1 * order)
	return added

static func paint(host: Variant, flies: Array) -> Array:
	var active: Array = []
	var now: float = float(host._time)


	if ( not flies.is_empty() or host.has_meta(PACKAGE_META)) and host._cell_size("rw_fly_package") == Vector2.ZERO:
		var regions: Dictionary = {}
		for key: String in ["qu_fly_gold", "qu_fly_gift"]:
			if Atlas.R.has(key):
				regions[key] = Atlas.R[key]
		host._use(Atlas.FILE, regions)
		host._use(PackageAtlas.FILE, {"rw_fly_package": PackageAtlas.R["rw_fly_package"]})
	var bar: Dictionary = target(host)
	for fly: Dictionary in flies:
		_package_events(host, fly, now)
		if now >= float(fly["end"]):
			continue
		active.append(fly)
		var picture: Texture2D = null
		var full: Vector2 = Vector2.ZERO
		if fly.has("cell"):
			full = host._cell_size(str(fly["cell"]))
		else:
			picture = host.pack.picture(str(fly.get("art", "")))
			if picture != null and picture.get_width() > 0 and picture.get_height() > 0:
				full = picture.get_size()
		var shown: Dictionary = pose(fly, now, float(host._fw), float(host._fh), land(host, bar, full))
		if not bool(shown["visible"]) or full.x <= 0.0 or full.y <= 0.0:
			continue
		var at: Vector2 = shown["at"]
		var scale: float = float(shown["scale"])
		if fly.has("cell"):
			host._fblit(str(fly["cell"]), at, full.x * scale, full.y * scale)
		else:
			var factor: float = float(host._f)
			host.draw_texture_rect(picture, Rect2(at * factor, full * scale * factor), false)
	_paint_package(host, now, bar)
	return active


static func target(host: Variant) -> Dictionary:
	if not (host is CanvasItem):
		return {}
	for bar: Dictionary in LobbyBar.live(host as CanvasItem):
		if (bar.get("bag", Rect2()) as Rect2).has_area():
			return bar
	return {}


static func land(host: Variant, bar: Dictionary, full: Vector2) -> Vector2:
	if bar.is_empty():
		return NO_LAND
	var factor: float = maxf(0.0001, float(host._f))
	return (bar["bag"] as Rect2).get_center() / factor - full * END_SCALE / 2.0




static func _package_events(host: Variant, fly: Dictionary, now: float) -> void :
	var order: float = float(fly["i"])
	var departure: float = float(fly["born"]) + 1.7 + 0.2 * order
	var arrival: float = float(fly["end"])
	var state: Dictionary = host.get_meta(PACKAGE_META, {})
	if now >= departure and not bool(fly.get("_departed", false)):
		fly["_departed"] = true
		if state.is_empty() or departure >= float(state.get("hide", INF)):
			state = {"born": departure, "arrived": -1.0, "hide": INF, "glow_born": -1.0, "glow_until": -1.0}
	if now >= arrival and not bool(fly.get("_arrived", false)):
		fly["_arrived"] = true
		state["arrived"] = maxf(float(state.get("arrived", -1.0)), arrival)
		state["hide"] = float(state["arrived"]) + 1.5

		state["glow_born"] = arrival
		state["glow_until"] = arrival + 1.0
	if not state.is_empty():
		host.set_meta(PACKAGE_META, state)

static func _paint_package(host: Variant, now: float, bar: Dictionary = {}) -> void :
	var state: Dictionary = host.get_meta(PACKAGE_META, {})
	if state.is_empty() or now >= float(state.get("hide", INF)):
		return
	if not bar.is_empty():
		_paint_bag_pop(host, now, state, bar)
		return
	var at: Vector2 = Vector2(floorf(float(host._fw)) - 230.0, floorf(float(host._fh)) - 42.0)
	var scale: float = lerpf(0.4, 1.0, clampf((now - float(state["born"])) / 0.5, 0.0, 1.0))
	var arrived: float = float(state.get("arrived", -1.0))
	if arrived >= 0.0:
		var age: float = now - arrived
		var progress: float = clampf(age / 0.5, 0.0, 1.0)
		var shifted: float = progress - 1.0
		var ratio: float = shifted * shifted * (2.70158 * shifted + 1.70158) + 1.0
		var path: Dictionary = through(at, at + Vector2(0.0, 20.0), at)
		at = along(path, ratio)
	host._fblit("rw_fly_package", at, 72.0 * scale, 61.0 * scale)



static func _paint_bag_pop(host: Variant, now: float, state: Dictionary, bar: Dictionary) -> void :
	var arrived: float = float(state.get("arrived", -1.0))
	if arrived < 0.0:
		return
	var glow_born: float = float(state.get("glow_born", -1.0))
	var glow_until: float = float(state.get("glow_until", -1.0))
	if now >= maxf(arrived + 0.5, glow_until):
		return
	var factor: float = float(host._f)
	var lift: float = 0.0
	var age: float = now - arrived
	if age < 0.5:
		var shifted: float = clampf(age / 0.5, 0.0, 1.0) - 1.0
		var ratio: float = shifted * shifted * (2.70158 * shifted + 1.70158) + 1.0
		lift = along(through(Vector2.ZERO, Vector2(0.0, POP_LIFT), Vector2.ZERO), ratio).y * factor
	var glow: float = clampf((glow_until - now) / maxf(0.0001, glow_until - glow_born), 0.0, 1.0) if now < glow_until else 0.0
	var grow: float = 1.0 + 0.08 * clampf(lift / maxf(0.0001, POP_LIFT * factor), 0.0, 1.5)
	LobbyBar.pop_lease()
	LobbyBar.bag_pop(host as CanvasItem, bar, lift, grow, glow)




static func pose(fly: Dictionary, now: float, wide: float, high: float, land: Vector2 = NO_LAND) -> Dictionary:
	var order: float = float(fly["i"])
	var age: float = now - float(fly["born"])
	var leave: float = 1.7 + 0.2 * order
	var duration: float = maxf(0.2, 1.0 - 0.1 * order)
	var end: float = leave + duration
	var start: Vector2 = Vector2(wide / 2.0, high / 2.0)
	var dest: Vector2 = Vector2(floorf(wide) - 240.0, floorf(high) - 44.0)
	var spot: Vector2 = Vector2(start.x + 50.0 * (float(fly["n"]) - 1.0) - 100.0 * order, start.y - 50.0)
	var viewport: Vector2 = Vector2(wide, high)
	var goal: Vector2 = dest + Vector2(10.0, 2.0) if land == NO_LAND else land
	if fly.get("_viewport", Vector2.ZERO) != viewport:
		fly["_viewport"] = viewport
		var peak: Vector2 = Vector2((spot.x + start.x) * 0.5, start.y - 300.0)
		fly["_bound_path"] = through(start, peak, spot)
		fly.erase("_goal")
	if fly.get("_goal", NO_LAND) != goal or not fly.has("_bag_path"):
		fly["_goal"] = goal

		fly["_bag_path"] = through(spot, Vector2(goal.x - 10.0, 0.0), goal)
	var at: Vector2 = start
	var scale: float = 0.0
	if age >= leave:
		var progress: float = clampf((age - leave) / duration, 0.0, 1.0)
		var ratio: float = progress * progress
		at = along(fly["_bag_path"], ratio)
		scale = lerpf(1.0, END_SCALE, ratio)
	elif age > 0.1 * order:
		scale = bounce(clampf((age - 0.1 * order) / BOUND_TIME, 0.0, 1.0))
		at = along(fly["_bound_path"], scale)
	return {"at": at, "scale": scale, "visible": scale > 0.0 and age < end, 
		"arrived": age >= end, "leave": leave, "end": end}

static func _item_art(host: Variant, tid: int) -> String:

	var bag: Dictionary = host.pack.bag
	var found: Variant = bag.get("items", {}).get(str(tid))
	if found is Array:
		var row: Array = found
		if row.size() > 2 and not str(row[2]).is_empty():
			return ("l/av/" if row.size() > 5 and int(row[5]) == 4 else "l/it/") + str(row[2]) + ".webp"
	var other: Variant = bag.get("more", {}).get(str(tid))
	if other is Array and (other as Array).size() > 1 and not str(other[1]).is_empty():
		return "l/it/%s.webp" % str(other[1])

	if host.has_method("_item"):
		var item: Variant = host._item(tid, 1)
		if item is Dictionary:
			return str(item.get("art", ""))
	return ""




static func through(a: Vector2, middle: Vector2, end: Vector2) -> Dictionary:
	var first: Vector2 = middle - a
	var second: Vector2 = end - middle
	var r1: float = first.length()
	var r2: float = second.length()
	var unit1: Vector2 = first / r1 if r1 > 0.0 else Vector2.ZERO
	var unit2: Vector2 = second / r2 if r2 > 0.0 else Vector2.ZERO
	var r3: float = (unit1 + unit2).length()
	var distance: float = (r1 + r2) * 0.25 / (r3 if r3 > 0.0 else 0.5)
	var before: Vector2 = middle - unit1 * distance
	var after: Vector2 = middle + unit2 * distance
	var weight: float = (r1 * 3.0 / (r1 + r2) + 0.5) / 4.0 if r1 + r2 > 0.0 else 0.0
	var offset: Vector2 = middle - (before + (after - before) * weight)
	before += offset
	after += offset
	var curves: Array = [PackedVector2Array([a, a + (before - a) * 0.6, before, middle]), 
		PackedVector2Array([middle, after, after + (end - after) * 0.4, end])]


	if a.distance_to(end) <= 0.05:
		curves = [PackedVector2Array([a, a, middle, middle]), PackedVector2Array([middle, middle, end, end])]
	var lengths: PackedFloat64Array = PackedFloat64Array([0.0])
	var total: float = 0.0
	for curve: PackedVector2Array in curves:
		var previous: Vector2 = curve[0]
		for step: int in range(1, LENGTH_STEPS + 1):
			var point: Vector2 = _cubic(curve, float(step) / float(LENGTH_STEPS))
			total += previous.distance_to(point)
			lengths.append(total)
			previous = point
	return {"curves": curves, "lengths": lengths, "length": total}

static func along(path: Dictionary, ratio: float) -> Vector2:
	var curves: Array = path["curves"]
	var lengths: PackedFloat64Array = path["lengths"]
	var total: float = float(path["length"])
	if total <= 0.0:
		return (curves[0] as PackedVector2Array)[0]
	var distance: float = ratio * total
	var slice: int = 0
	while slice < lengths.size() - 2 and distance > lengths[slice + 1]:
		slice += 1
	var span: float = lengths[slice + 1] - lengths[slice]
	var fraction: float = (distance - lengths[slice]) / span if span > 0.0 else 0.0
	var segment: int = slice / LENGTH_STEPS
	var local: float = (float(slice % LENGTH_STEPS) + fraction) / float(LENGTH_STEPS)
	return _cubic(curves[segment], local)

static func _cubic(points: PackedVector2Array, ratio: float) -> Vector2:
	var rest: float = 1.0 - ratio
	return points[0] * rest * rest * rest + points[1] * 3.0 * rest * rest * ratio\
	+ points[2] * 3.0 * rest * ratio * ratio + points[3] * ratio * ratio * ratio


static func bounce(ratio: float) -> float:
	if ratio < 1.0 / 2.75:
		return 7.5625 * ratio * ratio
	if ratio < 2.0 / 2.75:
		ratio -= 1.5 / 2.75
		return 7.5625 * ratio * ratio + 0.75
	if ratio < 2.5 / 2.75:
		ratio -= 2.25 / 2.75
		return 7.5625 * ratio * ratio + 0.9375
	ratio -= 2.625 / 2.75
	return 7.5625 * ratio * ratio + 0.984375
