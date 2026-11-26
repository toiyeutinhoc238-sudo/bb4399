extends RefCounted



const Atlas = preload("reward_popup_atlas.gd")
const RewardFly = preload("reward_fly.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const TankPortrait = preload("tank_portrait.gd")
const FONT: Font = preload("res://assets/fonts/flash_ui_bold.tres")
const SHADOW: Color = Color("005797", 0.8)
const AUTO_CLOSE: float = 3.0
const EFFECT_TIME: float = 0.5
const LABELS: Dictionary = {"exp": "EXP", "money": "Bạc", "gift": "Xu Khóa", "cash": "Xu", "honor": "Vinh dự", "fizz": "Độ Hoạt Động"}

var active: bool = false
var opened_at: float = -1.0
var closing_at: float = -1.0
var info: Dictionary = {}
var raw_info: Dictionary = {}
var rewards: Array = []
var rows: Array = []
var _bound_host: WeakRef = null

static func has_rewards(value: Dictionary) -> bool:
	var normalized: Dictionary = _normalize(value)
	for field: String in ["exp", "golden", "gift", "cash", "glory", "fizz"]:
		if int(normalized[field]) != 0:
			return true
	return not normalized.items.is_empty() or not normalized.tanks.is_empty()

static func frame_rows(count: int) -> int:
	return clampi(ceili(float(count) / 5.0), 1, 4)

func begin(host: Variant, value: Dictionary) -> void :
	raw_info = value.duplicate(true)
	var incoming: Dictionary = _normalize(value)
	if active:
		for field: String in ["exp", "golden", "gift", "cash", "glory", "fizz"]:
			info[field] = int(info[field]) + int(incoming[field])
		for pair: Array in incoming.items:
			var found: bool = false
			for kept: Array in info.items:
				if int(kept[0]) == int(pair[0]):
					kept[1] = int(kept[1]) + int(pair[1])
					found = true
					break
			if not found:
				info.items.append(pair.duplicate())
		info.tanks.append_array(incoming.tanks)
	else:
		info = incoming
		active = true
		opened_at = float(host._time)
		closing_at = -1.0
	info["coins"] = [int(info.cash), int(info.gift), int(info.golden), int(info.glory)]
	info["base_items"] = info.items
	rewards = _ordered(info)
	rows = rewards
	for reward: Dictionary in rows:
		var kind: String = str(reward.kind)
		var item: Dictionary = _item(host, int(reward.id)) if kind == "item" else {}
		reward["name"] = str(item.get("name", LABELS.get(kind, host.pack.lobby.get("tanks", {}).get(str(int(reward.get("id", 0))), ""))))
		reward["art"] = str(item.get("art", ""))
		reward["quality"] = int(item.get("quality", 4 if kind == "tank" else (2 if kind in ["gift", "cash"] else 1)))

func reset() -> void :
	active = false
	opened_at = -1.0
	closing_at = -1.0
	info = {}
	raw_info = {}
	rewards = []
	rows = []

func request_close(host: Variant) -> bool:
	if not active:
		return false
	if closing_at < 0.0:
		closing_at = float(host._time)
	return true


func tick(host: Variant) -> bool:
	if not active:
		return false
	var now: float = float(host._time)
	if closing_at < 0.0 and now - opened_at >= AUTO_CLOSE:
		closing_at = opened_at + AUTO_CLOSE
	if closing_at < 0.0 or now - closing_at < EFFECT_TIME:
		return false
	active = false
	host._flies.append_array(RewardFly.begin(host, info))
	return true

func paint(host: Variant) -> void :
	if not active:
		return
	if _bound_host == null or _bound_host.get_ref() != host:
		host._use(Atlas.FILE, Atlas.R)
		_bound_host = weakref(host)


	var row_count: int = frame_rows(rewards.size() - (1 if int(info.glory) != 0 else 0))
	var frame: Dictionary = Atlas.FRAMES[str(row_count)]
	var full: Vector2 = _v(frame.size)

	var at: Vector2 = Vector2(floorf((float(host._fw) - full.x) / 2.0), floorf((float(host._fh) - 300.0 - 110.0 * float(row_count - 1)) / 2.0))
	var pose: Dictionary = effect_at(float(host._time))
	var scale_k: float = float(pose.scale)
	var alpha: float = float(pose.alpha)
	var f: float = float(host._f)
	var pivot: Vector2 = (at + full * 0.5) * f
	host.draw_rect(Rect2(Vector2.ZERO, host.size), Color(0, 0, 0, 0.4))
	host._hit("shade", Rect2(Vector2.ZERO, host.size), false)
	host.draw_set_transform(pivot * (1.0 - scale_k), 0.0, Vector2(scale_k, scale_k))
	host._fblit(str(frame.cell), at + _v(frame.panel), 0.0, 0.0, Color(1, 1, 1, alpha))

	host._hit("ok", _scaled_rect(Rect2(at * f, full * f), pivot, scale_k), false)
	var slots: Array = frame.slots
	for i: int in mini(rewards.size(), slots.size()):
		_paint_reward(host, rewards[i], at + _v(slots[i]), alpha)
	var close_rect: Rect2 = _r(frame.nodes.btnClose)
	host._fblit("rw_close", at + close_rect.position, close_rect.size.x, close_rect.size.y, _tint(host, alpha))
	host._hit("ok", _scaled_rect(Rect2((at + close_rect.position) * f, close_rect.size * f), pivot, scale_k), false)
	_paint_confirm(host, at + _r(frame.nodes.btnConfirm).position, alpha)
	var confirm_rect: Rect2 = _r(frame.nodes.btnConfirm)
	host._hit("ok", _scaled_rect(Rect2((at + confirm_rect.position) * f, confirm_rect.size * f), pivot, scale_k), false)
	host.draw_set_transform_matrix(Transform2D.IDENTITY)

func effect_at(now: float) -> Dictionary:
	if closing_at >= 0.0:
		var p: float = clampf((now - closing_at) / EFFECT_TIME, 0.0, 1.0)
		return {"scale": lerpf(1.0, 0.1, _back_in(p)), "alpha": 0.5 + 0.5 * cos(PI * p)}
	var p: float = clampf((now - opened_at) / EFFECT_TIME, 0.0, 1.0)

	return {"scale": lerpf(0.1, 1.0, _back_out(p)), "alpha": 0.5 - 0.5 * cos(PI * p)}

func _paint_confirm(host: Variant, at: Vector2, alpha: float) -> void :
	host._fblit("rw_ok_skin", at, 0.0, 0.0, _tint(host, alpha))
	var left: int = maxi(0, 3 - int(maxf(0.0, float(host._time) - opened_at)))
	var label: String = "(%dGiây)" % left
	var font: Font = host._face(FONT)
	var px: int = maxi(6, roundi(12.0 * float(host._f)))
	var width: float = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / float(host._f)

	var start: Vector2 = at + Vector2((120.0 - 39.0 - 2.0 - width) / 2.0, 0)
	host._fblit("rw_ok_word", start + Vector2(0, 7), 0.0, 0.0, Color(1, 1, 1, alpha))
	host._fwords(label, FONT, 12.0, Color("e85f37", alpha), "c", start + Vector2(41, 0), width, 0.0, 35.0, false)

func _paint_reward(host: Variant, reward: Dictionary, at: Vector2, alpha: float) -> void :
	var kind: String = str(reward.kind)
	var name: String = str(LABELS.get(kind, ""))
	var quality: String = "white"
	var art: String = ""
	if kind == "item":
		var item: Dictionary = _item(host, int(reward.id))
		name = str(item.name)
		art = str(item.art)
		quality = str(["white", "white", "green", "blue", "purple", "orange"][clampi(int(item.quality), 0, 5)])
	elif kind == "tank":
		name = str(host.pack.lobby.get("tanks", {}).get(str(int(reward.id)), str(int(reward.id))))
		quality = "purple"
	else:
		quality = str(Atlas.ITEM.icons.get(kind, {}).get("quality", "white"))
	if kind == "item" and art.is_empty() and not (host.has_method("_reward_cell") and not str(host._reward_cell(int(reward.id))).is_empty()):
		art = BagModel.alt_of(int(reward.id), host.pack.bag)
	var bg: Rect2 = _r(Atlas.ITEM.bg)
	host._fblit("rw_item_bg", at + bg.position, bg.size.x, bg.size.y, Color(1, 1, 1, alpha))
	var q: Dictionary = Atlas.ITEM.qualities[quality]
	var qr: Rect2 = _r(q.rect)
	host._fblit(str(q.cell), at + qr.position, qr.size.x, qr.size.y, Color(1, 1, 1, alpha))
	if kind == "item":
		var spot: Rect2 = Rect2(at + _r(Atlas.ITEM.icon).position, _r(Atlas.ITEM.icon).size)
		var cell: String = str(host._reward_cell(int(reward.id))) if art.is_empty() and host.has_method("_reward_cell") else ""
		if cell.is_empty():
			_picture(host, art, spot, alpha)
		else:
			host._fblit(cell, spot.position, spot.size.x, spot.size.y, Color(1, 1, 1, alpha))
	elif kind == "tank":
		_paint_tank(host, int(reward.id), at, alpha)
	else:
		var icon: Dictionary = Atlas.ITEM.icons.get(kind, {})
		if not icon.is_empty():
			var icon_rect: Rect2 = _r(icon.rect)
			host._fblit(str(icon.cell), at + icon_rect.position, icon_rect.size.x, icon_rect.size.y, Color(1, 1, 1, alpha))
	_name(host, name, at, alpha)
	var count: Dictionary = Atlas.ITEM.count
	host._fwords(str(int(reward.count)), FONT, float(count.fontSize), Color(1, 1, 1, alpha), "c", at + Vector2(float(count.x), float(count.y)), float(count.width), 1.0, 0.0, false, Color(SHADOW, SHADOW.a * alpha))

func _name(host: Variant, text: String, at: Vector2, alpha: float) -> void :
	var spec: Dictionary = Atlas.ITEM.name
	var f: float = float(host._f)
	var font: Font = host._face(FONT)
	var px: int = maxi(6, roundi(float(spec.fontSize) * f))
	var wide: float = float(spec.width) * f
	var high: float = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, wide, px).y
	var origin: Vector2 = (at + Vector2((91.0 - float(spec.width)) / 2.0, 110.0 - float(spec.bottom))) * f
	origin.y += font.get_ascent(px) - high - 2.0 * f
	host.draw_multiline_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide, px, -1, maxi(1, roundi(f)), Color(SHADOW, SHADOW.a * alpha))
	host.draw_multiline_string(font, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide, px, -1, Color(1, 1, 1, alpha))

func _paint_tank(host: Variant, id: int, at: Vector2, alpha: float) -> void :
	var garage: Dictionary = host.pack.garage
	var defaults: Dictionary = host.pack.index.get("tanks", {})
	var ext: int = GarageModel.exterior(garage, defaults, id, 1, {})
	var face: String = GarageModel.face(garage, ext)
	if face.is_empty():
		return
	var f: float = float(host._f)
	var origin: Vector2 = at + Vector2(8.5, 4)
	var film: Array = TankPortrait.movie(garage, face)
	var rect: Rect2 = TankPortrait.still_rect(film, origin, 0.37, TankPortrait.side(garage, face))
	var picture: Texture2D = host.pack.picture("l/t/%s.webp" % face)
	if picture != null:
		host.draw_texture_rect(picture, Rect2(rect.position * f, rect.size * f), false, Color(1, 1, 1, alpha))

static func _item(host: Variant, id: int) -> Dictionary:
	var row: Array = host.pack.bag.get("items", {}).get(str(id), [])
	if row.size() >= 6:
		return {"name": BagModel.clean(str(row[0])), "quality": int(row[3]), "art": ("l/av/" if int(row[5]) == 4 else "l/it/") + str(row[2]) + ".webp" if not str(row[2]).is_empty() else ""}
	var found: Variant = {}
	if host.has_method("_item") and host.get_method_argument_count("_item") == 2:
		found = host._item(id, 1)
		if found is Dictionary and ( not str(found.get("art", "")).is_empty() or str(found.get("name", "")) != "Vật phẩm %d" % id):
			return found


	var other: Array = host.pack.bag.get("more", {}).get(str(id), [])
	if other.size() >= 3:
		return {"name": BagModel.clean(str(other[0])), "quality": int(other[2]), "art": "l/it/%s.webp" % str(other[1]) if not str(other[1]).is_empty() else ""}
	if found is Dictionary and not (found as Dictionary).is_empty():
		return found
	return {"name": "Vật phẩm %d" % id, "quality": 1, "art": ""}

static func _picture(host: Variant, path: String, rect: Rect2, alpha: float) -> void :
	if path.is_empty():
		return
	var picture: Texture2D = host.pack.picture(path)
	if picture == null or picture.get_width() <= 0 or picture.get_height() <= 0:
		return
	var shown: Vector2 = picture.get_size() * minf(rect.size.x / float(picture.get_width()), rect.size.y / float(picture.get_height()))
	var f: float = float(host._f)
	host.draw_texture_rect(picture, Rect2((rect.position + (rect.size - shown) / 2.0) * f, shown * f), false, Color(1, 1, 1, alpha))

static func _normalize(value: Dictionary) -> Dictionary:
	var raw: Dictionary = value.get("m_info", value)
	var coins: Array = value.get("coins", [])
	var out: Dictionary = {}
	for spec: Array in [["cash", 0], ["gift", 1], ["golden", 2], ["glory", 3], ["exp", -1], ["fizz", -1]]:
		var field: String = str(spec[0])
		var index: int = int(spec[1])
		out[field] = int(value.get(field, raw.get("m_" + field, coins[index] if index >= 0 and index < coins.size() else 0)))
	out["items"] = []
	var source: Array = (value.get("base_items", value.get("items", [])) as Array).duplicate(true)
	if value.has("m_info") and not value.has("base_items") and not value.has("items"):
		for group: Dictionary in raw.get("m_settleItemVec", []):
			if int(group.get("m_nType", 0)) in [0, 7]:
				for item: Dictionary in group.get("m_itemVec", []):
					source.append([int(item.get("m_itemId", 0)), int(item.get("m_count", 0))])
	var counts: Dictionary = {}
	for pair: Variant in source:
		if pair is Array and (pair as Array).size() >= 2 and int(pair[0]) > 0 and int(pair[1]) != 0:
			var id: int = int(pair[0])
			counts[id] = int(counts.get(id, 0)) + int(pair[1])
	for id: int in counts:
		out.items.append([id, int(counts[id])])
	out["tanks"] = []
	for id: Variant in value.get("tanks", raw.get("m_tankVec", [])):
		if int(id) != 0:
			out.tanks.append(int(id))
	return out

static func _ordered(value: Dictionary) -> Array:
	var out: Array = []
	for pair: Array in [["exp", "exp"], ["golden", "money"], ["gift", "gift"], ["cash", "cash"], ["glory", "honor"], ["fizz", "fizz"]]:
		if int(value[pair[0]]) != 0:
			out.append({"kind": str(pair[1]), "count": int(value[pair[0]])})
	for pair: Array in value.items:
		out.append({"kind": "item", "id": int(pair[0]), "count": int(pair[1])})
	for id: int in value.tanks:
		out.append({"kind": "tank", "id": id, "count": 1})
	return out

static func _v(value: Array) -> Vector2:
	return Vector2(float(value[0]), float(value[1]))

static func _r(value: Array) -> Rect2:
	return Rect2(float(value[0]), float(value[1]), float(value[2]), float(value[3]))

static func _scaled_rect(rect: Rect2, pivot: Vector2, scale_k: float) -> Rect2:
	return Rect2(pivot + (rect.position - pivot) * scale_k, rect.size * scale_k)

static func _tint(host: Variant, alpha: float) -> Color:
	var tint: Color = host._glow("ok")
	tint.a = alpha
	return tint

static func _back_in(p: float) -> float:
	return p * p * ((1.70158 + 1.0) * p - 1.70158)

static func _back_out(p: float) -> float:
	var q: float = p - 1.0
	return q * q * ((1.70158 + 1.0) * q + 1.70158) + 1.0
