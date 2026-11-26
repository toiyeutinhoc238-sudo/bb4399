extends "league_reward.gd"













const Award = preload("league_award_atlas.gd")

const NAME_GLOW: Color = Color("0390d3", 0.8)
const RING: Color = Color("ffff00")
const ROWS_SHOWN: int = 1
const TILE_MAX: int = 7
const ICONS: Dictionary = {"exp": "la_exp", "gift": "la_gift", "coin": "la_gold", "team": "la_team", "glory": "la_honor"}
const LABEL_PITCH: float = 16.0

var rows: Array = []
var _sel: int = 0
var _row_rects: Array = []

func _setup() -> void :
	super ()
	_use(Award.FILE, Award.R)


func show_rows(list: Array) -> void :
	rows = list.duplicate(true)
	_sel = 0
	if rows.is_empty():
		close()
		return
	open()



func remove(award_id: int) -> bool:
	for i: int in rows.size():
		if int(rows[i].aid) == award_id:
			rows.remove_at(i)
			_sel = 0
			_top = 0
			if rows.is_empty():
				close()
			return true
	return false



static func _n(value: Variant) -> int:
	if value is int or value is float:
		return int(value)
	if value is String and (value as String).is_valid_float():
		return int(float(value))
	return 0



static func parse_rows(data: Variant) -> Array:
	var out: Array = []
	if not data is Array:
		return out
	for raw: Variant in data:
		if not raw is Dictionary or _n(raw.get("nDrawed")) == 1:
			continue
		var items: Array = []
		for i: int in range(1, 6):
			items.append([_n(raw.get("nItem%d" % i)), _n(raw.get("nItemcnt%d" % i))])
		var title: Variant = raw.get("szRoundName", "")
		out.append({"aid": _n(raw.get("nAid")), "round": _n(raw.get("nRoundId")), "name": str(title) if title != null else "", 
			"exp": _n(raw.get("nExp")), "gift": _n(raw.get("nGift")), "coin": _n(raw.get("nCoin")), "team": _n(raw.get("nTeamCoin")), 
			"glory": _n(raw.get("nGlory")), "tank": _n(raw.get("nTank")), "items": items})
	return out




static func award_tiles(row: Dictionary, items: Dictionary) -> Array:
	var out: Array = []
	for kind: String in ["exp", "gift", "coin", "team", "glory", "tank"]:
		var count: int = _n(row.get(kind))
		if count <= 0:
			continue
		out.append({"kind": kind, "cell": str(ICONS.get(kind, "")), "id": 0, "count": count, "label": "" if kind == "tank" else str(count), 
			"name": "", "art": "", "quality": 0, "desc": ""})
	for pair: Variant in row.get("items", []):
		if not pair is Array or (pair as Array).size() < 2:
			continue
		var id: int = _n(pair[0])
		var count: int = _n(pair[1])
		if id == 0 or count == 0:
			continue
		var found: Variant = items.get(str(id))
		var more: Array = found if found is Array else []
		var title: String = BagModel.clean(str(more[0])) if not more.is_empty() else ""
		out.append({"kind": "item", "cell": "", "id": id, "count": count, 
			"label": "" if more.is_empty() else (title + ("  x%d" % count if count > 1 else "")), "name": title, 
			"art": "l/it/%s.webp" % str(more[2]) if more.size() > 2 and not str(more[2]).is_empty() else "", 
			"quality": _n(more[3]) if more.size() > 3 else 0, "desc": GarageModel.plain(str(more[1])) if more.size() >= 10 else ""})
	return out.slice(0, TILE_MAX)

func prizes() -> Array:
	return rows


func tiles(index: int) -> Array:
	if index < 0 or index >= rows.size():
		return []
	return award_tiles(rows[index], pack.bag.get("items", {}) if pack != null else {})

func selected() -> int:
	return _sel


func pick(index: int) -> void :
	if index >= 0 and index < rows.size():
		_sel = index

func max_top() -> int:
	return maxi(0, rows.size() - ROWS_SHOWN)



func _paint() -> void :
	_tip = []
	_bar = []
	_row_rects = []
	_clip = Rect2()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var box: Vector2 = _v(Award.SIZE)
	var o: Vector2 = _centre(box.x, box.y)
	_hit("panel", Rect2(o * _f, box * _f), false)
	_fblit("la_frame", o + _v(Award.FRAME))
	_draw_rows(o)
	_fbutton("close", "la_close", o + _v(Award.CLOSE))
	_draw_tip()


func _draw_rows(o: Vector2) -> void :
	var spot: Array = Award.LIST
	var at: Vector2 = o + _v(spot)
	var wide: float = float(spot[2])
	var high: float = float(spot[3])
	var pitch: float = float(Award.ROW_H)
	var barred: bool = max_top() > 0
	_list_rect = Rect2(at * _f, Vector2(wide, high) * _f)
	_clip = Rect2(at * _f, Vector2(wide - (BAR if barred else 0.0), high) * _f)
	var items: Dictionary = pack.bag.get("items", {}) if pack != null else {}
	for k: int in ceili(high / pitch):
		var index: int = _top + k
		if index >= rows.size():
			break
		_draw_award_row(index, at + Vector2(0, k * pitch), items)
	_clip = Rect2()
	if barred:
		_draw_award_bar(at + Vector2(wide - BAR, 0), high - 2.0 * BAR)


func _draw_award_row(index: int, at: Vector2, items: Dictionary) -> void :
	var row: Dictionary = rows[index]
	var area: Rect2 = Rect2(at * _f, Vector2(float(Award.ROW[0]), float(Award.ROW_H)) * _f).intersection(_clip)
	if area.has_area():
		_row_rects.append([index, area])
	if index == _sel:
		_ring(Rect2((at + _v(Award.SELECT)) * _f, Vector2(float(Award.SELECT[2]), float(Award.SELECT[3])) * _f))
	var name_spot: Array = Award.NAME
	var row_w: float = float(Award.ROW[0])
	_ctext(str(row.name), float(name_spot[4]), "c", at + Vector2(float(name_spot[0]) - row_w / 2.0, float(name_spot[1])), row_w, 2.0, NAME_GLOW)
	var cells: Array = award_tiles(row, items)
	var bottom: float = at.y + float(Award.ROW[1])
	for i: int in cells.size():
		_draw_award_tile(cells[i], at + _v(Award.TILES[i]), bottom)
	_cblit("la_btnbk", at + _v(Award.BTN_BK))
	var id: String = "get:%d" % index
	var button: Rect2 = _ctint("la_get", at + _v(Award.BTN), _glow(id))
	var hit: Rect2 = button.intersection(_clip) if _clip.has_area() else button
	if hit.has_area():
		_hit(id, hit, false)
	_ctint("la_cut", at + _v(Award.CUT), Color.WHITE)



func _draw_award_tile(gift: Dictionary, at: Vector2, bottom: float) -> void :
	var spot: Dictionary = Award.TILE
	var bg: Rect2 = _cblit("la_tile", at + _v(spot["bg"]))
	var quality: int = int(gift.quality)
	if quality >= 2 and quality <= 5:
		_cblit("la_q%d" % quality, at + _v(spot["quality"]))
	var box: Array = spot["item"]
	if not str(gift.cell).is_empty():
		_cblit(str(gift.cell), at + _v(box))
	elif not str(gift.art).is_empty() and pack != null:
		var picture: Texture2D = pack.picture(str(gift.art))
		if picture != null and picture.get_width() > 4:
			var room: Vector2 = Vector2(float(box[2]), float(box[3]))
			var k: float = minf(room.x / picture.get_width(), room.y / picture.get_height())
			_cut_tex(picture, Rect2((at + _v(box)) * _f, Vector2(picture.get_size()) * k * _f), Rect2(Vector2.ZERO, picture.get_size()))
	var label: Array = spot["lblNum"]
	if not str(gift.label).is_empty():
		var lines: Array = award_label(str(gift.label), float(label[4]), float(label[2]), at.y + float(label[1]), bottom)
		for k: int in lines.size():
			_ctext(str(lines[k]), float(label[4]), "c", at + Vector2(float(label[0]), float(label[1]) + k * LABEL_PITCH), float(label[2]), 0.0, 
				Color(0, 0, 0, 0))
	if str(gift.kind) == "item" and not str(gift.name).is_empty():
		_peek(bg, gift)



func award_label(text: String, px: float, wide: float, top: float, bottom: float) -> Array:
	var out: Array = []
	var lines: Array = _wrap(text, px, wide)
	for k: int in lines.size():
		if k > 0 and top + k * LABEL_PITCH + 2.0 + px * 1.15 > bottom:
			break
		out.append(str(lines[k]).strip_edges())
	return out


func _ring(rect: Rect2) -> void :
	if not _clip.has_area() or _clip.encloses(rect):
		_round(rect, Color(0, 0, 0, 0), 6.0 * 2.0, RING, 3.0 * 2.0)
		return
	var w: float = 3.0 * _f
	for edge: Rect2 in [Rect2(rect.position, Vector2(rect.size.x, w)), Rect2(Vector2(rect.position.x, rect.end.y - w), Vector2(rect.size.x, w)), 
			Rect2(rect.position, Vector2(w, rect.size.y)), Rect2(Vector2(rect.end.x - w, rect.position.y), Vector2(w, rect.size.y))]:
		var cut: Rect2 = edge.intersection(_clip)
		if cut.has_area():
			draw_rect(cut, RING)


func _ctint(cell_name: String, at: Vector2, tint: Color) -> Rect2:
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty():
		return Rect2(at * _f, Vector2.ZERO)
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	if cell[0] == null:
		return rect
	var src: Rect2 = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	var cut: Rect2 = rect.intersection(_clip) if _clip.has_area() else rect
	if cut.has_area():
		var k: Vector2 = src.size / rect.size
		draw_texture_rect_region(cell[0], cut, Rect2(src.position + (cut.position - rect.position) * k, cut.size * k), tint)
	return rect


func _ctext(text: String, px: float, align: String, at: Vector2, wide: float, edge: float, rim: Color) -> void :
	if _clip.has_area():
		var middle: float = (at.y + 2.0 + px * 0.55) * _f
		var half: float = px * 0.6 * _f
		if middle - half < _clip.position.y - 1.0 or middle + half > _clip.end.y + 1.0:
			return
	_fwords(text, ARIAL_BOLD, px, Color.WHITE, align, at, wide, edge, 0.0, true, rim)


func _draw_award_bar(at: Vector2, track: float) -> void :
	_fblit("lr_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("bar:up", "lr_sb_up", at)
	_fbutton("bar:down", "lr_sb_down", at + Vector2(0, BAR + track))
	var most: float = float(max_top())
	if most <= 0.0:
		return
	var thumb: float = maxf(20.0, track * ROWS_SHOWN / (most + ROWS_SHOWN))
	var y: float = at.y + BAR + (track - thumb) * clampf(_top / most, 0.0, 1.0)
	_hit("bar:pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, y - at.y - BAR) * _f), false)
	_hit("bar:pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(BAR, at.y + BAR + track - y - thumb) * _f), false)
	_fslice("lr_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:bar"))
	_hit("slide:bar", Rect2(Vector2(at.x, y) * _f, Vector2(BAR, thumb) * _f), false)
	_bar = [track, thumb, most]



func _activate(id: String) -> void :
	if id.begins_with("get:"):

		var index: int = int(id.substr(4))
		if index >= 0 and index < rows.size():
			pick(index)
			if client != null and client.has_method("league_award"):
				client.call("league_award", int(rows[index].aid))
		return
	match id:
		"bar:pgup":
			_scroll(_top - ROWS_SHOWN)
		"bar:pgdn":
			_scroll(_top + ROWS_SHOWN)
		_:
			super (id)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for spot: Array in _row_rects:
			if (spot[1] as Rect2).has_point(event.position) and _hit_at(event.position) not in ["slide:bar", "close"]\
			and not _hit_at(event.position).begins_with("bar:"):
				pick(int(spot[0]))
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :
	if is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_PAGEUP, KEY_PAGEDOWN]:
		_scroll(_top + (ROWS_SHOWN if event.keycode == KEY_PAGEDOWN else - ROWS_SHOWN))
		get_viewport().set_input_as_handled()
		return
	super (event)
