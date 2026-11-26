extends "flash_screen.gd"




const TaskAtlas = preload("master_task_atlas.gd")
const EventsAtlas = preload("events_atlas.gd")
const LRAtlas = preload("league_reward_atlas.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const FlashTip = preload("flash_tip.gd")

const TASK_RIM: Color = Color("0057a7", 0.8)
const TILE_RIM: Color = Color("005797", 0.8)
const BAR: float = 19.0
const EXP_NAME: String = "EXP"
const GIFT_NAME: String = "Xu Khóa"
const MONEY_NAME: String = "Bạc"
const AMITY_PLUS: String = "Điểm Tình +@num1@"
const THEW: String = "Thể Lực +@num1@"
const CHECK: String = "@num1@/@num2@"

var _clip: Rect2 = Rect2()
var _item_tip: Array = []
var _wraps: Dictionary = {}


func _use_task() -> void :
	_use(TaskAtlas.FILE, TaskAtlas.R)
	var ev: Dictionary = {}
	for key: String in EventsAtlas.R:
		if key.begins_with("ev_aw_") or key.begins_with("ev_q"):
			ev[key] = EventsAtlas.R[key]
	_use(EventsAtlas.FILE, ev)
	var lr: Dictionary = {}
	for key: String in LRAtlas.R:
		if key.begins_with("lr_sb_"):
			lr[key] = LRAtlas.R[key]
	_use(LRAtlas.FILE, lr)

func _v(at: Array) -> Vector2:
	return Vector2(float(at[0]), float(at[1]))




func _item_cell(cell: Array) -> Dictionary:
	var id: int = int(cell[0])
	var items: Dictionary = pack.bag.get("items", {}) if pack != null else {}
	var found: Variant = items.get(str(id))
	var more: Array = found if found is Array else []
	var title: String = BagModel.clean(str(more[0])) if not more.is_empty() and not str(more[0]).is_empty() else str(cell[2])
	return {"kind": "item", "id": id, "count": int(cell[1]), "name": title, 
		"art": "l/it/%s.webp" % str(cell[3]) if not str(cell[3]).is_empty() else "", "quality": int(cell[4]), 
		"desc": GarageModel.plain(str(more[1])) if more.size() >= 2 else ""}


func award_tiles(award: int) -> Array:
	var row: Variant = TaskAtlas.AWARDS.get(str(award))
	if not (row is Array):
		return []
	var out: Array = []
	if int(row[0]) > 0:
		out.append({"kind": "exp", "id": 0, "count": int(row[0]), "name": EXP_NAME, "art": "", "quality": 1, "desc": ""})
	if int(row[1]) > 0:
		out.append({"kind": "gift", "id": 0, "count": int(row[1]), "name": GIFT_NAME, "art": "", "quality": 2, "desc": ""})
	if int(row[2]) > 0:
		out.append({"kind": "money", "id": 0, "count": int(row[2]), "name": MONEY_NAME, "art": "", "quality": 1, "desc": ""})
	for cell: Array in row[4]:
		out.append(_item_cell(cell))
	return out.slice(0, 4)


func award_thew(award: int) -> int:
	var row: Variant = TaskAtlas.AWARDS.get(str(award))
	return int(row[3]) if row is Array else 0


func present_tiles(present: int) -> Array:
	var out: Array = []
	for cell: Array in TaskAtlas.PRESENTS.get(str(present), []):
		out.append(_item_cell(cell))
	return out.slice(0, 5)



func _cut_tex(texture: Texture2D, dest: Rect2, src: Rect2, tint: Color = Color.WHITE) -> void :
	if texture == null or dest.size.x <= 0.0 or dest.size.y <= 0.0:
		return
	if not _clip.has_area():
		draw_texture_rect_region(texture, dest, src, tint)
		return
	var cut: Rect2 = dest.intersection(_clip)
	if not cut.has_area():
		return
	var k: Vector2 = src.size / dest.size
	draw_texture_rect_region(texture, cut, Rect2(src.position + (cut.position - dest.position) * k, cut.size * k), tint)


func _cblit(cell_name: String, at: Vector2) -> Rect2:
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty():
		return Rect2(at * _f, Vector2.ZERO)
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	_cut_tex(cell[0], rect, Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])))
	return rect


func _cbutton(id: String, cell_name: String, at: Vector2) -> void :
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty():
		return
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	var shown: Rect2 = rect.intersection(_clip) if _clip.has_area() else rect
	if not shown.has_area():
		return
	_cut_tex(cell[0], rect, Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])), _glow(id))
	_hit(id, shown, false)


func _cwords(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, wide: float, high: float, shrink: bool, rim: Color) -> void :
	if text.is_empty():
		return
	if _clip.has_area():
		var middle: float = (at.y + (high / 2.0 if high > 0.0 else 2.0 + px * 0.55)) * _f
		var half: float = px * 0.6 * _f
		if middle - half < _clip.position.y - 1.0 or middle + half > _clip.end.y + 1.0:
			return
	_fwords(text, font, px, color, align, at, wide, 1.0, high, shrink, rim)


func _task_label(spec: Array, text: String, o: Vector2, truncate: bool = false) -> void :
	var wide: float = float(spec[2])
	var left: float = float(spec[0])
	var align: String = str(spec[7])
	var font: Font = ARIAL_BOLD if int(spec[6]) == 1 else ARIAL
	var shrink: bool = false
	if wide <= 0.0 and align == "l":

		wide = float(TaskAtlas.TASK[0]) - left
		shrink = true
	elif wide <= 0.0:
		wide = 600.0
		if align == "c":
			left -= 300.0
	elif truncate:
		text = _truncate(text, font, float(spec[4]), wide)
	_cwords(text, font, float(spec[4]), Color(str(spec[5])), align, o + Vector2(left, float(spec[1])), wide, 0.0, shrink, TASK_RIM)


func _truncate(text: String, font: Font, px: float, wide: float) -> String:
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	var room: float = (wide - 5.0) * _f
	if face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= room:
		return text
	var keep: String = text
	while keep.length() > 1 and face.get_string_size(keep + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
		keep = keep.left(keep.length() - 1)
	return keep + "..."

func _fit_rect(texture: Texture2D, rect: Rect2) -> Rect2:
	var full: Vector2 = texture.get_size()
	if full.x <= 0.0 or full.y <= 0.0:
		return rect
	var ratio: float = minf(rect.size.x / full.x, rect.size.y / full.y)
	var shown: Vector2 = full * ratio
	return Rect2(rect.position + (rect.size - shown) / 2.0, shown)


func _wrap(text: String, px: float, wide: float) -> Array:
	var key: String = "%d|%d|%d|%s" % [roundi(px * 100.0), roundi(wide), roundi(_f * 1000.0), text]
	if _wraps.has(key):
		return _wraps[key]
	if _wraps.size() > 200:
		_wraps.clear()
	var font_size: int = maxi(6, roundi(px * _f))
	var out: Array = []
	var line: String = ""
	for word: String in text.split(" "):
		var trial: String = word if line.is_empty() else line + " " + word
		if line.is_empty() or ARIAL_BOLD.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= wide * _f:
			line = trial
		else:
			out.append(line)
			line = word
	out.append(line)
	_wraps[key] = out
	return out





func _draw_task(at: Vector2, row: Dictionary, display: bool) -> void :
	var texts: Dictionary = TaskAtlas.TASK_TEXT
	_cblit("mt_row", at)
	if bool(row.get("tick", false)):
		_cblit("mt_tick", at)
	var title: Array = texts["lblTitle"]
	if display:

		title = title.duplicate()
		title[2] = float(TaskAtlas.TASK[0]) - float(title[0]) - 10.0
	_task_label(title, str(row.get("title", "")), at, true)
	if not display:
		_task_label(texts["lblCheckPoint"], str(row.get("check", "")), at)
		_task_label(texts["lblAmity"], str(row.get("amity", "")), at)
	if not bool(row.get("award", false)):
		return
	var spots: Dictionary = TaskAtlas.TASK_AT
	_cblit("mt_bracket", at + _v(spots["bracket_only" if display else "bracket"]))
	var tiles: Array = row.get("tiles", [])
	var cells: Array = spots["cells_only" if display else "cells"]
	for i: int in (mini(tiles.size(), 5) if display else 4):
		_draw_tile(tiles[i] if i < tiles.size() else {}, at + _v(cells[i]))
	if display:
		return
	if int(row.get("thew", 0)) > 0:
		_task_label(texts["lblThew"], THEW.replace("@num1@", str(int(row.thew))), at)
	var get_id: String = str(row.get("get", ""))
	if not get_id.is_empty():
		_cbutton(get_id, "mt_get", at + _v(spots["get"]))



func _draw_tile(gift: Dictionary, at: Vector2) -> void :
	var spot: Dictionary = TaskAtlas.AWARD
	_cblit("ev_aw_bg", at + _v(spot["bg"]))
	if gift.is_empty():
		return
	_cblit("ev_q%d" % clampi(int(gift.quality), 1, 5), at + _v(spot["quality"]))
	match str(gift.kind):
		"item":
			var art: String = str(gift.art)
			var picture: Texture2D = pack.picture(art) if pack != null and not art.is_empty() else null
			if picture != null:
				var dest: Rect2 = _fit_rect(picture, Rect2((at + _v(spot["item"])) * _f, Vector2(76, 76) * _f))
				_cut_tex(picture, dest, Rect2(Vector2.ZERO, picture.get_size()))
		"exp":
			_cblit("ev_aw_exp", at + _v(spot["coin"]))
		"money":
			_cblit("ev_aw_money", at + _v(spot["coin"]))
		"gift":
			_cblit("ev_aw_gift", at + _v(spot["gift"]))
	var lines: Array = _wrap(str(gift.name), 12.0, 66.0)
	for i: int in lines.size():
		_cwords(str(lines[i]), ARIAL_BOLD, 12.0, Color.WHITE, "c", at + Vector2(12.5, 78.0 - 14.0 * lines.size() + 14.0 * i), 66.0, 14.0, false, TILE_RIM)
	if int(gift.count) != 0:
		_cwords(str(int(gift.count)), ARIAL_BOLD, 13.0, Color.WHITE, "c", at + Vector2(0.5, 82), 90.0, 0.0, true, TILE_RIM)
	_peek(Rect2((at + Vector2(3.5, 0)) * _f, Vector2(84, 84) * _f), gift)


func _peek(rect: Rect2, gift: Dictionary) -> void :
	if not _tip_ok() or _hover != "panel":
		return
	var mouse: Vector2 = get_local_mouse_position()
	if not rect.has_point(mouse) or (_clip.has_area() and not _clip.has_point(mouse)):
		return
	var rec: Dictionary = _gift_rec(gift)
	if not rec.is_empty():
		_item_tip = [rect, "", "", Color.WHITE, rec]
		return
	_item_tip = [rect, GarageModel.cap(str(gift.name)), str(gift.get("desc", "")), BagModel.tint(int(gift.quality), Color.WHITE)]


func _gift_rec(gift: Dictionary) -> Dictionary:
	var id: int = int(gift.get("id", 0))
	if str(gift.get("kind", "item")) != "item" or id <= 0 or pack == null:
		return {}
	pack.load_bag()
	var extra: Dictionary = {}
	if not (pack.bag.get("items", {}) as Dictionary).has(str(id)):
		extra = {"name": str(gift.get("name", "")), "quality": int(gift.get("quality", 0)), "desc": str(gift.get("desc", ""))}
		if not str(gift.get("art", "")).is_empty() and not str(gift.art).begins_with("l/t/"):
			extra["art"] = str(gift.art)
			extra["icon"] = str(gift.art)
	return FlashTip.simulate(id, pack.bag, extra)

func _draw_item_tip() -> void :
	if _item_tip.is_empty():
		return
	if _item_tip.size() > 4 and _item_tip[4] is Dictionary:
		FlashTip.item(self, _item_tip[4])
		return
	var anchor: Rect2 = _item_tip[0]
	var body: String = str(_item_tip[2])
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 10).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_item_tip[1]), ARIAL_BOLD, 13.0, _item_tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, ARIAL, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 10)





func _draw_bar(key: String, at: Vector2, track: float, value: float, most: float, page: float) -> Array:
	_fblit("lr_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton(key + ":up", "lr_sb_up", at)
	_fbutton(key + ":down", "lr_sb_down", at + Vector2(0, BAR + track))
	if most <= 0.0:
		return []
	var thumb: float = maxf(20.0, track * page / (most + page))
	var y: float = at.y + BAR + (track - thumb) * clampf(value / most, 0.0, 1.0)
	_hit(key + ":pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, y - at.y - BAR) * _f), false)
	_hit(key + ":pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(BAR, at.y + BAR + track - y - thumb) * _f), false)
	_fslice("lr_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:" + key))
	_hit("slide:" + key, Rect2(Vector2(at.x, y) * _f, Vector2(BAR, thumb) * _f), false)
	return [track, thumb, most]


func _fslice(cell_name: String, at: Vector2, high: float, cap: float, tint: Color) -> void :
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var src: Rect2 = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	var wide: float = src.size.x
	var end: float = minf(cap, floorf(minf(high, src.size.y) / 2.0))
	draw_texture_rect_region(cell[0], Rect2(at * _f, Vector2(wide, end) * _f), Rect2(src.position, Vector2(wide, end)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, end)) * _f, Vector2(wide, high - 2.0 * end) * _f), 
		Rect2(src.position + Vector2(0, end), Vector2(wide, src.size.y - 2.0 * end)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, high - end)) * _f, Vector2(wide, end) * _f), 
		Rect2(src.position + Vector2(0, src.size.y - end), Vector2(wide, end)), tint)
