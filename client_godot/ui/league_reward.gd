extends "flash_screen.gd"








const Atlas = preload("league_reward_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")

signal closed

const DIM: Color = Color(0, 0, 0, 0.4)
const TITLE: String = "THƯỞNG GIẢI TEAM"
const TITLE_INK: Color = Color("1f86e0")
const TITLE_SHADOW: Color = Color(0, 0.16, 0.4, 0.35)
const NAME_RIM: Color = Color("086de5", 0.8)
const TILE_RIM: Color = Color("005797", 0.8)
const BAR: float = 19.0
const SHOWN: int = 2
const PULL: float = 85.0

var _top: int = 0
var _clip: Rect2 = Rect2()
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _bar: Array = []
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_top: float = 0.0
var _pull: float = 0.0
var _list_rect: Rect2 = Rect2()
var _wraps: Dictionary = {}

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)


func open() -> void :
	_top = 0
	_tip = []
	_grab = false
	_pull = 0.0
	_hover = ""
	_press = ""
	if pack != null:
		pack.load_bag()
	visible = true

func close() -> void :
	if not visible:
		return
	visible = false
	_grab = false
	closed.emit()


func chat_busy() -> bool:
	return visible




func prizes() -> Array:
	return Atlas.PRIZES

func top() -> int:
	return _top

func max_top() -> int:
	return maxi(0, prizes().size() - SHOWN)



func tiles(index: int) -> Array:
	var out: Array = []
	if index < 0 or index >= prizes().size():
		return out
	var items: Dictionary = pack.bag.get("items", {}) if pack != null else {}
	for cell: Array in prizes()[index][2]:
		var kind: String = str(cell[0])
		if kind == "gift":
			out.append({"kind": "gift", "id": 0, "count": int(cell[1]), "name": str(Atlas.GIFT_NAME), "art": "", "quality": 2, "desc": ""})
		elif kind == "money":
			out.append({"kind": "money", "id": 0, "count": int(cell[1]), "name": str(Atlas.MONEY_NAME), "art": "", "quality": 1, "desc": ""})
		elif cell.size() >= 5:
			var id: int = int(cell[0])
			var found: Variant = items.get(str(id))
			var more: Array = found if found is Array else []
			var title: String = BagModel.clean(str(more[0])) if not more.is_empty() and not str(more[0]).is_empty() else str(cell[2])
			out.append({"kind": "item", "id": id, "count": int(cell[1]), "name": title, 
				"art": "l/it/%s.webp" % str(cell[3]) if not str(cell[3]).is_empty() else "", "quality": int(cell[4]), 
				"desc": GarageModel.plain(str(more[1])) if more.size() >= 10 else ""})
	return out.slice(0, Atlas.TILES.size())

func _scroll(value: float) -> void :
	_top = clampi(roundi(value), 0, max_top())



func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))

func _cut_tex(texture: Texture2D, dest: Rect2, src: Rect2) -> void :
	if texture == null or dest.size.x <= 0.0 or dest.size.y <= 0.0:
		return
	if not _clip.has_area():
		draw_texture_rect_region(texture, dest, src)
		return
	var cut: Rect2 = dest.intersection(_clip)
	if not cut.has_area():
		return
	var k: Vector2 = src.size / dest.size
	draw_texture_rect_region(texture, cut, Rect2(src.position + (cut.position - dest.position) * k, cut.size * k))


func _cblit(cell_name: String, at: Vector2) -> Rect2:
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty():
		return Rect2(at * _f, Vector2.ZERO)
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	_cut_tex(cell[0], rect, Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])))
	return rect


func _cwords(text: String, px: float, align: String, at: Vector2, wide: float, high: float, shrink: bool, rim: Color) -> void :
	if _clip.has_area():
		var middle: float = (at.y + (high / 2.0 if high > 0.0 else 2.0 + px * 0.55)) * _f
		var half: float = px * 0.6 * _f
		if middle - half < _clip.position.y - 1.0 or middle + half > _clip.end.y + 1.0:
			return
	_fwords(text, ARIAL_BOLD, px, Color.WHITE, align, at, wide, 1.0, high, shrink, rim)

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

func _paint() -> void :
	_tip = []
	_bar = []
	_clip = Rect2()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var box: Vector2 = _v(Atlas.SIZE)
	var o: Vector2 = _centre(box.x, box.y)
	_hit("panel", Rect2(o * _f, box * _f), false)
	_fblit("lr_frame", o + _v(Atlas.FRAME))
	_draw_title(o)
	_draw_list(o)
	_fbutton("close", "lr_close", o + _v(Atlas.CLOSE))
	_draw_tip()


func _draw_title(o: Vector2) -> void :
	var spot: Array = Atlas.TITLE
	var at: Vector2 = o + _v(spot)
	_fwords(TITLE, ARIAL_BOLD, 24.0, TITLE_SHADOW, "c", at + Vector2(0, 2), float(spot[2]), 3.0, float(spot[3]), true, TITLE_SHADOW)
	_fwords(TITLE, ARIAL_BOLD, 24.0, TITLE_INK, "c", at, float(spot[2]), 3.0, float(spot[3]), true, Color.WHITE)


func _draw_list(o: Vector2) -> void :
	var spot: Array = Atlas.LIST
	var at: Vector2 = o + _v(spot)
	var wide: float = float(spot[2])
	var high: float = float(spot[3])
	var row_h: float = float(Atlas.ROW[1])
	_list_rect = Rect2(at * _f, Vector2(wide, high) * _f)
	_clip = Rect2(at * _f, Vector2(wide - BAR, high) * _f)
	var rows: Array = prizes()
	for k: int in ceili(high / row_h):
		var index: int = _top + k
		if index >= rows.size():
			break
		_draw_row(index, at + Vector2(0, k * row_h))
	_clip = Rect2()
	_draw_bar(at + Vector2(wide - BAR, 0), high - 2.0 * BAR)


func _draw_row(index: int, at: Vector2) -> void :
	_cblit("lr_row", at + _v(Atlas.ROW_BG))
	var name_spot: Array = Atlas.ROW_NAME
	_cwords(str(prizes()[index][1]), float(name_spot[4]), "l", at + _v(name_spot), float(Atlas.ROW[0]) - 10.0, 0.0, true, NAME_RIM)
	var cells: Array = tiles(index)
	for i: int in cells.size():
		_draw_tile(cells[i], at + _v(Atlas.TILES[i]))


func _draw_tile(gift: Dictionary, at: Vector2) -> void :
	var spot: Dictionary = Atlas.AWARD
	_cblit("lr_aw_bg", at + _v(spot["bg"]))
	_cblit("lr_q%d" % clampi(int(gift.quality), 1, 5), at + _v(spot["quality"]))
	match str(gift.kind):
		"item":
			var art: String = str(gift.art)
			var picture: Texture2D = pack.picture(art) if pack != null and not art.is_empty() else null
			if picture != null:
				var dest: Rect2 = _fit_rect(picture, Rect2((at + _v(spot["item"])) * _f, Vector2(76, 76) * _f))
				_cut_tex(picture, dest, Rect2(Vector2.ZERO, picture.get_size()))
		"money":
			_cblit("lr_aw_money", at + _v(spot["coin"]))
		"gift":
			_cblit("lr_aw_gift", at + _v(spot["gift"]))
	var lines: Array = _wrap(str(gift.name), 12.0, 66.0)
	for i: int in lines.size():
		_cwords(str(lines[i]), 12.0, "c", at + Vector2(12.5, 78.0 - 14.0 * lines.size() + 14.0 * i), 66.0, 14.0, false, TILE_RIM)
	if int(gift.count) != 0:
		_cwords(str(int(gift.count)), 13.0, "c", at + Vector2(0.5, 82), 90.0, 0.0, true, TILE_RIM)
	_peek(Rect2((at + Vector2(3.5, 0)) * _f, Vector2(84, 84) * _f), gift)


func _peek(rect: Rect2, gift: Dictionary) -> void :
	if not _tip_ok() or _grab or _hover != "panel":
		return
	var mouse: Vector2 = get_local_mouse_position()
	if not rect.has_point(mouse) or (_clip.has_area() and not _clip.has_point(mouse)):
		return
	var rec: Dictionary = _gift_rec(gift)
	if not rec.is_empty():
		_tip = [rect, "", "", Color.WHITE, rec]
		return
	_tip = [rect, GarageModel.cap(str(gift.name)), str(gift.get("desc", "")), BagModel.tint(int(gift.quality), Color.WHITE)]


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

func _draw_tip() -> void :

	if FlashTip.show(self, _tip if _tip.size() != 4 else [], _ctip) and _tip.size() != 4:
		return
	if _tip.is_empty():
		return
	var anchor: Rect2 = _tip[0]
	var body: String = str(_tip[2])
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 10).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), ARIAL_BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, ARIAL, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 10)


func _draw_bar(at: Vector2, track: float) -> void :
	_fblit("lr_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("bar:up", "lr_sb_up", at)
	_fbutton("bar:down", "lr_sb_down", at + Vector2(0, BAR + track))
	var most: float = float(max_top())
	if most <= 0.0:
		return
	var thumb: float = maxf(20.0, track * SHOWN / (most + SHOWN))
	var y: float = at.y + BAR + (track - thumb) * clampf(_top / most, 0.0, 1.0)
	_hit("bar:pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, y - at.y - BAR) * _f), false)
	_hit("bar:pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(BAR, at.y + BAR + track - y - thumb) * _f), false)
	_fslice("lr_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:bar"))
	_hit("slide:bar", Rect2(Vector2(at.x, y) * _f, Vector2(BAR, thumb) * _f), false)
	_bar = [track, thumb, most]


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



func _activate(id: String) -> void :
	match id:
		"close":
			close()
		"bar:up":
			_scroll(_top - 1)
		"bar:down":
			_scroll(_top + 1)
		"bar:pgup":
			_scroll(_top - SHOWN)
		"bar:pgdn":
			_scroll(_top + SHOWN)

func _wheel(step: int, at: Vector2) -> void :
	if _list_rect.has_point(at):
		_scroll(_top + step)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _grab or not _list_rect.has_point(from):
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, PULL * _f)
	while _pull >= pitch:
		_pull -= pitch
		_scroll(_top + 1)
	while _pull <= - pitch:
		_pull += pitch
		_scroll(_top - 1)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pull = 0.0
			if _hit_at(event.position) == "slide:bar" and not _bar.is_empty():
				_grab = true
				_grab_at = event.position
				_grab_top = float(_top)
		else:
			_grab = false
	elif event is InputEventMouseMotion and _grab:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_grab = false
		else:
			var step: float = maxf(0.001, (float(_bar[0]) - float(_bar[1])) / float(_bar[2]))
			_scroll(_grab_top + (event.position.y - _grab_at.y) / _f / step)
			accept_event()
			return
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :


	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_ESCAPE:
			close()
		KEY_UP:
			_scroll(_top - 1)
		KEY_DOWN:
			_scroll(_top + 1)
		KEY_PAGEUP:
			_scroll(_top - SHOWN)
		KEY_PAGEDOWN:
			_scroll(_top + SHOWN)
		KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER:
			pass
		_:
			return
	get_viewport().set_input_as_handled()
