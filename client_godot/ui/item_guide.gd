extends "flash_screen.gd"


















const Atlas = preload("item_guide_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const ShopModel = preload("shop_model.gd")
const Cv2 = preload("item_guide_cv2_atlas.gd")
const AtlasC = preload("fairc_atlas.gd")
const FairAtlas = preload("fair_atlas.gd")
const Arena = preload("arena_atlas.gd")

signal closed
signal quick_buy_asked(tid: int)
signal expedition_asked
signal guild_boss_asked
signal arena_asked

const SHOW_IN: Array = ["lobby", "hall", "room"]
const CELL: Vector2 = Vector2(134, 106)
const GAP: float = 8.0
const BAR: float = 14.0
const UP_DEPTH: int = 12
const ACT_TYPE: int = 4
const TOKEN: int = 8000005
const COINS: Array = ["Xu", "Xu Khóa", "Bạc"]
const SHORT_RED: Color = Color("d70018")
const NAME_GOLD: Color = Color("fff499")
const PILL_RIM: Color = Color("174a00")
const DESC_LINES: int = 3
const SOON: String = "%s đang được chuyển sang HTML5."
const PVE_HALL: String = "Về sảnh chính để vào Phụ Bản."
const NAMES: Dictionary = {"pve": "Phụ Bản", "solo": "Phụ Bản", "pve_entrance": "Phụ Bản", "Rent": "Thuê xe", "guild_boss": "Boss Guild", 
	"expedition": "Viễn chinh", "team_pve": "Phụ Bản đội", "ladder": "Leo thang", "active": "Hoạt động"}
const UNSENT: String = "Chưa gửi được, hãy thử lại."


const EXPED_LEVEL: int = 18
const EXPED_TIP8: String = "Nhân vật đạt Lv@num1@ mở"
const EXPED_HALL: String = "Về sảnh chính để mở Viễn chinh."
const EXPED_OFF: String = "Viễn chinh chưa mở."
const GB_HALL: String = "Về sảnh chính để mở Boss Guild."


const RENT_TANK: Dictionary = {2003203: 10000059, 2003204: 10000062, 2003206: 10000039, 2003207: 10000040, 2003208: 10000041, 2003209: 10000042, 2003210: 10000044, 2003211: 10000045, 2003212: 10000046, 2003213: 10000047, 2003214: 10000048, 2003215: 10000049, 2003216: 10000050, 2003217: 10000001, 2003218: 10000032, 2003219: 10000019, 2003220: 10000029, 2003221: 10000003, 2003222: 10000031, 2003223: 10000008, 2003224: 10000030, 2003225: 10000034, 2003226: 10000033, 2003227: 10000035, 2003228: 10000036, 2003229: 10000037, 2003230: 10000043, 2003231: 10000051, 2003232: 10000052, 2003233: 10000053, 2003234: 10000054, 2003235: 10000055, 2003236: 10000056, 2003237: 10000057, 2003238: 10000058}
const CONFIRM_BOX: Vector2 = Vector2(358, 300)
const MOST: int = 9999

var _tid: int = 0
var _stack: Array[int] = []
var _entry: Dictionary = {}
var _routes: Array = []
var _recipes: Array = []
var _index: int = 0
var _scroll: float = 0.0
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _counts: Dictionary = {}
var _total: Dictionary = {}
var _counted_at: float = -10.0
var _waiting: int = 0
var _desc_top: int = 0
var _desc_text: TextParagraph = TextParagraph.new()
var _desc_key: String = ""
var _slots: Array = []
var _dlg: String = ""
var _pick: Array = []
var _pick_id: int = 0
var _pick_max: int = 0
var _amount: int = 0
var _most_n: int = 0
var _plan_cost: Array = []
var _plan_info: Array = []
var _qty: LineEdit

func _setup() -> void :
	_use(Atlas.FILE, Atlas.R)
	_use(AtlasC.FILE, AtlasC.R)
	_use(FairAtlas.FILE, {"fa_dec": FairAtlas.R["fa_dec"], "fa_add": FairAtlas.R["fa_add"]})
	var shared: Dictionary = {}
	for key: String in Arena.R:
		if key.begins_with("public_"):
			shared[key] = Arena.R[key]
	_use(Arena.FILE, shared)
	_qty = _fedit(4, true)
	_qty.text_changed.connect( func(_text: String) -> void : _on_qty_input())
	_qty.text_submitted.connect( func(_text: String) -> void : _confirm())
	visible = false
	if client != null:
		client.changed.connect(_follow)
	if pack != null:
		pack.picture_ready.connect(_on_pack)

func _on_pack(path: String) -> void :
	if path == "l/bag.json" and _waiting != 0:
		var tid: int = _waiting
		_waiting = 0
		open(tid)

func _follow() -> void :
	if visible and (client == null or client.state not in SHOW_IN):
		close()


func open(tid: int) -> void :
	if client == null or pack == null or client.state not in SHOW_IN:
		return
	if pack.bag.is_empty() and not pack.base.is_empty():
		_waiting = tid
		pack.load_bag()
		return
	if not _known(tid):
		return
	if visible:
		if tid != _tid:
			_stack.append(_tid)
	else:
		_stack.clear()
	_show(tid)
	visible = true

func close() -> void :
	var was: bool = visible
	visible = false
	_stack.clear()
	_tip = []
	_waiting = 0
	_close_sheet()
	if was:
		closed.emit()


func _show(tid: int) -> void :
	_tid = tid
	_entry = _item(tid, 1)
	_routes = Atlas.GUIDE.get(str(tid), [])
	_scroll = 0.0
	_desc_top = 0
	_tip = []
	_index = 0
	_recount()
	_recipes = _sorted_recipes(tid)


func _has_point(point: Vector2) -> bool:
	if visible and not _dlg.is_empty():
		return true
	return visible and Rect2(_origin() * _f, _size() * _f).has_point(point)

func _origin() -> Vector2:
	return _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))

func _size() -> Vector2:
	return Vector2(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))

func _node(name: String) -> Rect2:
	var row: Array = Atlas.NODES[name]
	return Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))

func _now() -> int:
	return int(Time.get_unix_time_from_system())



func _known(tid: int) -> bool:
	var key: String = str(tid)
	return pack.bag.get("items", {}).has(key) or pack.bag.get("more", {}).has(key) or Atlas.ITEMS.has(key)


func _item(id: int, count: int) -> Dictionary:
	var key: String = str(id)
	var out: Dictionary = {"kind": "item", "id": id, "count": count, "name": "Vật phẩm %d" % id, "art": "", "quality": 1, "desc": ""}
	var row: Array = pack.bag.get("items", {}).get(key, [])
	var other: Array = pack.bag.get("more", {}).get(key, [])
	var spare: Array = Atlas.ITEMS.get(key, [])
	if row.size() >= 6:
		out.name = BagModel.clean(str(row[0]))
		out.desc = _lines(BagModel.clean(str(row[1])))
		out.quality = int(row[3])
		out.art = ("l/av/" if int(row[5]) == 4 else "l/it/") + str(row[2]) + ".webp" if not str(row[2]).is_empty() else ""
	elif other.size() >= 3:
		out.name = BagModel.clean(str(other[0]))
		out.art = "l/it/%s.webp" % other[1] if not str(other[1]).is_empty() else ""
		out.quality = int(other[2])
	elif spare.size() >= 4:
		out.name = str(spare[0])
		out.desc = _lines(str(spare[1]))
		out.art = "l/it/%s.webp" % spare[2] if not str(spare[2]).is_empty() else ""
		out.quality = int(spare[3])
	var skin: Array = pack.garage.get("skin_items", {}).get(key, [])
	if skin.size() >= 2:
		var face: String = GarageModel.face(pack.garage, int(skin[1]))
		if not face.is_empty():
			out.art = "l/t/%s.webp" % face
	return out


static func _lines(text: String) -> String:
	var rows: PackedStringArray = []
	for part: String in text.split("#ENTER#"):
		rows.append(GarageModel.plain(part))
	return "\n".join(rows).strip_edges()

func _coin_art(index: int) -> String:
	var coins: Array = pack.lobby.get("coins", [])
	return "l/c/%s.webp" % str(coins[index]) if index >= 0 and index < coins.size() and not str(coins[index]).is_empty() else ""

func _coin(index: int, count: int) -> Dictionary:
	return {"kind": "coin", "id": 0, "count": count, "name": str(COINS[index]) if index >= 0 and index < COINS.size() else "Xu", 
		"art": _coin_art(index), "quality": 2 if index == 1 else 1, "desc": ""}


func _recount() -> void :
	_counted_at = _time
	_counts = {}
	_total = {}
	if client == null:
		return
	for cont: Variant in client.bags.keys():
		var shelf: Dictionary = {}
		for inst: Variant in client.bags[cont]:
			if inst is Dictionary:
				var id: int = int(inst.get("m_templateId", 0))
				var n: int = maxi(1, int(inst.get("m_count", 1)))
				shelf[id] = int(shelf.get(id, 0)) + n
				_total[id] = int(_total.get(id, 0)) + n
		_counts[int(cont)] = shelf


func _have(id: int) -> int:
	var row: Array = pack.bag.get("items", {}).get(str(id), [])
	if row.size() >= 6:
		return int(_counts.get(int(row[5]), {}).get(id, 0))
	return int(_total.get(id, 0))

func _purse(key: String) -> int:
	return int(client.currency.get(key, 0)) if client != null else 0

func _in_time(recipe: Array, now: int) -> bool:
	return not ((int(recipe[5]) != 0 and now < int(recipe[5])) or (int(recipe[6]) != 0 and now > int(recipe[6])))


func _sorted_recipes(tid: int) -> Array:
	var now: int = _now()
	var rows: Array = []
	var list: Array = Atlas.CONVERT.get(str(tid), [])
	for i: int in list.size():
		var recipe: Variant = list[i]
		if recipe is Array and _in_time(recipe, now):
			rows.append([_convert_count(recipe), rows.size(), recipe, i])
	rows.sort_custom( func(a: Array, b: Array) -> bool:
		return int(a[0]) > int(b[0]) if int(a[0]) != int(b[0]) else int(a[1]) < int(b[1]))
	var out: Array = []
	_slots = []
	for row: Array in rows:
		out.append(row[2])
		_slots.append(row[3])
	return out


func _convert_count(recipe: Array) -> int:
	var most: int = 4294967295
	var parts: Array = recipe[3]
	for k: int in mini(2, parts.size()):
		if int(parts[k][1]) > 0:
			most = mini(most, _have(int(parts[k][0])) / int(parts[k][1]))
	if int(recipe[2]) > 0:
		most = mini(most, _purse("m_iGolden") / int(recipe[2]))
	return most


func _all_convert() -> bool:
	for recipe: Array in _recipes:
		if int(recipe[0]) in [2, 5] and int(recipe[1]) == 2:
			return true
	return false


func _afford(ct: int, price: int) -> bool:
	match ct:
		2:
			return _purse("m_iGolden") >= price
		3:
			return _purse("m_iCash") + _purse("m_iSilver") >= price
	return _purse("m_iCash") >= price


func _coin_ok(kind: int, cost: int) -> bool:
	match kind:
		0:
			return true
		1:
			return _purse("m_iCash") >= cost
		2:
			return _purse("m_iGolden") >= cost
		3:
			return _purse("m_iSilver") >= cost
		7:
			return _have(TOKEN) >= cost
	return false


func _can_convert(item: int, n: int, depth: int = 0) -> bool:
	if depth > UP_DEPTH:
		return false
	var now: int = _now()
	for recipe: Variant in Atlas.CONVERT.get(str(item), []):
		if not (recipe is Array) or not _in_time(recipe, now):
			continue
		if not _coin_ok(int(recipe[1]), int(recipe[2]) * n):
			continue
		var ok: bool = true
		for part: Variant in recipe[3]:
			var need: int = int(part[1]) * n
			if int(part[0]) == 0 or need == 0:
				continue
			var have: int = _have(int(part[0]))
			if have < need and not _can_convert(int(part[0]), need - have, depth + 1):
				ok = false
				break
		if ok:
			return true
	return false


func _has_tank(tank: int) -> bool:
	for inst: Variant in client.tanks.values():
		if inst is Dictionary and int(inst.get("m_tpltId", 0)) == tank and int(inst.get("m_contType", -1)) == GarageModel.OWN:
			return true
	return false


func _has_skin(id: int) -> bool:
	for inst: Variant in client.bags.get(6, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == id and int(inst.get("m_count", 0)) > 0 and int(inst.get("m_lifeTime", 0)) == 0:
			return true
	return false

func _owned_skin(tid: int) -> bool:
	return Atlas.SKIN.has(tid) and client != null and ShopModel.owned({"gt": 6, "tid": tid}, client.tanks, client.bags) > 0


static func face_of(state: String) -> String:
	return "pve" if state in ["pve", "solo", "pve_entrance"] else state

func _tick(_delta: float) -> void :
	if _time - _counted_at > 0.25:
		_recount()

func _shown() -> void :
	if not is_visible_in_tree():
		_tip = []



func _paint() -> void :
	_tip = []
	if _entry.is_empty():
		return
	var o: Vector2 = _origin()
	_hit("panel", Rect2(o * _f, _size() * _f), false)
	_fblit("ig_frame", o + Vector2(float(Atlas.FRAME_AT[0]), float(Atlas.FRAME_AT[1])))
	_fbutton("close", "ig_close", o + _node("btnClose").position)
	var icon: Rect2 = _node("imgItem")
	_fit(_picture_of(_entry), o + icon.position, icon.size, 1.0)
	var name_spec: Array = Atlas.TEXTS["lblItemName"]
	_fwords(GarageModel.cap(str(_entry.name)), ARIAL_BOLD, float(name_spec[4]), NAME_GOLD, "l", o + Vector2(float(name_spec[0]), float(name_spec[1])), 205.0)
	var desc_spec: Array = Atlas.TEXTS["txtItemDec"]
	_draw_desc(str(_entry.desc), o + Vector2(float(desc_spec[0]), float(desc_spec[1])), float(desc_spec[2]), float(desc_spec[4]))
	if Atlas.BUY.has(str(_tid)):
		_fbutton("buy", "ig_buy", o + _node("btnQuickBuy").position)
	_draw_routes(o)
	if not _recipes.is_empty():
		_draw_convert(o)
	if not _stack.is_empty():
		_fbutton("back", "ig_back", o + _node("btnBack").position)
	match _dlg:
		"one", "all":
			_draw_confirm(true)
		"swap":
			_draw_confirm(false)
			_draw_swap()
		_:
			_draw_tip()
	if _qty.visible and _dlg not in ["one", "all"]:
		_qty.visible = false
		_qty.release_focus()


func _draw_desc(text: String, at: Vector2, wide: float, px: float) -> void :
	var font_size: int = maxi(6, roundi(px * _f))
	var key: String = "%s|%d|%d" % [text, font_size, roundi(wide * _f)]
	if key != _desc_key:
		_desc_key = key
		_desc_text.clear()
		_desc_text.width = (wide - 8.0) * _f
		_desc_text.add_string(text, ARIAL, font_size)
	var count: int = _desc_text.get_line_count()
	_desc_top = clampi(_desc_top, 0, maxi(0, count - DESC_LINES))
	var y: float = (at.y + 2.0) * _f
	for line: int in range(_desc_top, mini(count, _desc_top + DESC_LINES)):
		_desc_text.draw_line(get_canvas_item(), Vector2(at.x * _f, y), line, Color.WHITE)
		y += _desc_text.get_line_size(line).y
	if count > DESC_LINES:
		var track: Rect2 = Rect2(Vector2(at.x + wide - 5.0, at.y + 2.0), Vector2(4.0, 42.0))
		_round(Rect2(track.position * _f, track.size * _f), Color("0a3d73", 0.85), 2.0)
		var high: float = maxf(8.0, track.size.y * float(DESC_LINES) / float(count))
		var top: float = track.position.y + (track.size.y - high) * float(_desc_top) / float(maxi(1, count - DESC_LINES))
		_round(Rect2(Vector2(track.position.x, top) * _f, Vector2(4.0, high) * _f), Color("8fd6ff"), 2.0)

func _desc_rect(o: Vector2) -> Rect2:
	var spec: Array = Atlas.TEXTS["txtItemDec"]
	return Rect2(o + Vector2(float(spec[0]), float(spec[1])), Vector2(float(spec[2]), float(spec[3])))


func _draw_routes(o: Vector2) -> void :
	var box: Rect2 = _node("hboxMap")
	var clip: Rect2 = Rect2(o + box.position, Vector2(box.size.x, CELL.y))
	var content: float = _content()
	_scroll = clampf(_scroll, 0.0, maxf(0.0, content - box.size.x))
	for i: int in _routes.size():
		var at: Vector2 = clip.position + Vector2(float(i) * (CELL.x + GAP) - _scroll, 0)
		if at.x + CELL.x <= clip.position.x or at.x >= clip.end.x:
			continue
		_draw_route(i, at, clip)
	if content > box.size.x:
		_draw_bar(o, content)

func _content() -> float:
	return maxf(0.0, float(_routes.size()) * (CELL.x + GAP) - GAP)

func _bar_rect(o: Vector2) -> Rect2:
	var box: Rect2 = _node("hboxMap")
	return Rect2(o + box.position + Vector2(0, CELL.y + 2.0), Vector2(box.size.x, BAR))


func _draw_bar(o: Vector2, content: float) -> void :
	var bar: Rect2 = _bar_rect(o)
	_round(Rect2(bar.position * _f, bar.size * _f), Color("0a3d73", 0.85), BAR / 2.0, Color("6fd0ff", 0.35), 1.0)
	var thumb_w: float = maxf(30.0, bar.size.x * bar.size.x / content)
	var span: float = maxf(1.0, content - bar.size.x)
	var tx: float = bar.position.x + (bar.size.x - thumb_w) * _scroll / span
	var thumb: Rect2 = Rect2(Vector2(tx, bar.position.y + 2.0), Vector2(thumb_w, BAR - 4.0))
	_round(Rect2(thumb.position * _f, thumb.size * _f), Color("8fd6ff"), (BAR - 4.0) / 2.0)
	if tx > bar.position.x:
		_hit("bar:-1", Rect2(bar.position * _f, Vector2(tx - bar.position.x, bar.size.y) * _f), false)
	if thumb.end.x < bar.end.x:
		_hit("bar:1", Rect2(Vector2(thumb.end.x, bar.position.y) * _f, Vector2(bar.end.x - thumb.end.x, bar.size.y) * _f), false)


func _clipped(texture: Texture2D, src: Rect2, dest: Rect2, clip: Rect2, tint: Color = Color.WHITE) -> Rect2:
	var shown: Rect2 = dest.intersection(clip)
	if shown.size.x <= 0.0 or shown.size.y <= 0.0 or dest.size.x <= 0.0 or dest.size.y <= 0.0:
		return Rect2()
	if texture != null:
		var k: Vector2 = src.size / dest.size
		draw_texture_rect_region(texture, Rect2(shown.position * _f, shown.size * _f), Rect2(src.position + (shown.position - dest.position) * k, shown.size * k), tint)
	return Rect2(shown.position * _f, shown.size * _f)


func _clip_cell(name: String, at: Vector2, clip: Rect2, extent: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> Rect2:
	var cell: Array = _cells.get(name, [])
	if cell.is_empty():
		return Rect2()
	var region: Array = cell[1]
	var src: Rect2 = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	return _clipped(cell[0], src, Rect2(at, extent if extent != Vector2.ZERO else src.size), clip, tint)




const ROUTE_NONE: String = "ig_map_none"
static func route_picture(route: Array) -> String:
	var state: String = str(route[0])
	var arg: String = str(int(route[1]))
	if state in ["pve", "solo"]:
		return "l/ig/m%s.webp" % arg if Atlas.MAP_CELLS.has(arg) else ROUTE_NONE
	return "ig_e_" + state if Atlas.ENTRANCE.has(state) else ROUTE_NONE


func _draw_route(i: int, at: Vector2, clip: Rect2) -> void :
	var route: Array = _routes[i]
	var state: String = str(route[0])
	var arg: String = str(int(route[1]))
	_clip_cell("ig_r_bg", at, clip)
	var scale: float = float(Atlas.IMG_MAP[2])
	var mid: float = float(Atlas.IMG_MAP[0])
	var top: float = float(Atlas.IMG_MAP[1])
	var source: String = route_picture(route)
	var none: Array = _cells.get(ROUTE_NONE, [null, [0, 0, 168, 100]])
	var none_extent: Vector2 = Vector2(float(none[1][2]), float(none[1][3])) * scale
	if source.begins_with("l/"):
		var picture: Texture2D = pack.picture(source)
		var extent: Vector2 = Vector2(float(Atlas.MAP_CELLS[arg][0]), float(Atlas.MAP_CELLS[arg][1])) * scale
		if picture != null:
			_clipped(picture, Rect2(Vector2.ZERO, picture.get_size()), Rect2(at + Vector2(mid - extent.x / 2.0, top), extent), clip)
		else:
			_clip_cell(ROUTE_NONE, at + Vector2(mid - none_extent.x / 2.0, top), clip, none_extent)
	elif source == ROUTE_NONE:
		_clip_cell(ROUTE_NONE, at + Vector2(mid - none_extent.x / 2.0, top), clip, none_extent)
	else:
		var extent: Vector2 = Vector2(float(Atlas.ENTRANCE[state][0]), float(Atlas.ENTRANCE[state][1])) * scale
		_clip_cell(source, at + Vector2(mid - extent.x / 2.0, top), clip, extent)
	var face: String = face_of(state)
	var spot: Array = Atlas.RENDER.get(face, [27, 75, 81, 24])
	var place: Rect2 = Rect2(at + Vector2(float(spot[0]), float(spot[1])), Vector2(float(spot[2]), float(spot[3])))
	var id: String = "route:%d" % i
	var cell: String = "ig_b_" + face
	var label: String = ""
	if not _cells.has(cell) or Atlas.LABEL.has(state):
		cell = "ig_b_blank" if place.size.y >= 24.0 else "ig_b_blank_s"
		label = str(Atlas.LABEL.get(state, "ĐI ĐẾN"))
	var shown: Rect2 = _clip_cell(cell, place.position, clip, Vector2.ZERO, _glow(id))
	if shown.size.x > 0.0:
		_hit(id, shown, false)
	if not label.is_empty() and clip.encloses(place):
		_fwords(label, ARIAL_BOLD, 10.0, Color.WHITE, "c", place.position, place.size.x, 1.5, place.size.y, true, PILL_RIM)


func _draw_convert(o: Vector2) -> void :
	_index = clampi(_index, 0, _recipes.size() - 1)
	_fblit("ig_conv_title", o + _node("imgConvert").position)
	_fblit("ig_cv_bk", o + _node("cvsConvert").position)
	var recipe: Array = _recipes[_index]
	var ct: int = int(recipe[1])
	var price: int = int(recipe[2])
	var enough: bool = true
	var k: int = 0
	if price > 0:
		var ok: bool = _afford(ct, price)
		_draw_tile(o, k, _coin(ShopModel.coin_index(ct), price), str(price), Color.WHITE if ok else SHORT_RED, false, "")
		if not ok:
			enough = false
		k += 1
	for part: Variant in recipe[3]:
		var id: int = int(part[0])
		var need: int = int(part[1])
		if id != 0 and k < 4:
			var have: int = _have(id)
			_draw_tile(o, k, _item(id, need), "%d/%d" % [have, need], Color.WHITE, have < need and _can_convert(id, 1), "mat:%d" % id)
			if have < need:
				enough = false
		k += 1
	_draw_reward(o + _node("frmConvertItem").position, _item(_tid, int(recipe[4])))
	if not (int(recipe[0]) == ACT_TYPE and not _in_time(recipe, _now())):
		if enough and not _owned_skin(_tid):
			_fbutton("convert", "ig_cv_btn", o + _node("btnConvert").position)
		else:
			_fblit("ig_cv_btn_off", o + _node("btnConvert").position)
	if _index > 0:
		_fbutton("last", "ig_last", o + _node("btnLast").position)
	if _index < _recipes.size() - 1:
		_fbutton("next", "ig_next", o + _node("btnNext").position)
	if _all_convert():
		_fbutton("all", "ig_all", o + _node("btnAllConvert").position)


func _draw_tile(o: Vector2, k: int, gift: Dictionary, number: String, color: Color, mark: bool, id: String) -> void :
	var at: Vector2 = o + _node("item%d" % k).position
	var rect: Rect2 = _fblit("ig_cv_tile", at + Vector2(4, 0))
	var quality: int = int(gift.get("quality", 1))
	if quality >= 2 and quality <= 5:
		_fblit("ig_iq%d" % quality, at + Vector2(10, 6))
	_fit(_picture_of(gift), at + Vector2(12, 10), Vector2(52, 49), 1.0)
	var spec: Array = Atlas.TILE_TEXT
	_fwords(number, ARIAL_BOLD, float(spec[4]), color, "c", at + Vector2(float(spec[0]) - 30.0, float(spec[1]) - 394.0), float(spec[2]))
	if mark:
		_fblit("ig_cv_tip", o + _node("imgConvertTip%d" % k).position)
	if not id.is_empty():
		_hit(id, rect, false)
	_peek_item(rect, gift, id)


func _draw_reward(at: Vector2, gift: Dictionary) -> void :
	var rect: Rect2 = _fblit("ig_cv_reward", at)
	_fit(_picture_of(gift), at + Vector2(4, 4), Vector2(76, 76), 1.0)
	if int(gift.count) > 1:
		_fwords(str(int(gift.count)), ARIAL_BOLD, 12.0, Color.WHITE, "r", at + Vector2(7, 59), 70.0)
	_fwords(GarageModel.cap(str(gift.name)), ARIAL_BOLD, 12.0, BagModel.tint(int(gift.quality), Color.WHITE), "c", at + Vector2(-18, 79), 120.0)
	_peek_item(rect, gift, "")

func _picture_of(gift: Dictionary) -> Texture2D:
	var path: String = str(gift.get("art", ""))
	return pack.picture(path) if not path.is_empty() else null


func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false)

func _peek_item(rect: Rect2, gift: Dictionary, id: String) -> void :
	if not _tip_ok() or gift.is_empty() or not rect.has_point(get_local_mouse_position()):
		return
	if _hover == "panel" or ( not id.is_empty() and _hover == id):
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



func _draw_confirm(live: bool) -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	var at: Vector2 = _centre(CONFIRM_BOX.x, CONFIRM_BOX.y)
	var layout: Dictionary = AtlasC.CONFIRM
	if live:
		_hit("shade", Rect2(Vector2.ZERO, size), false)
		_hit("panel", Rect2(at * _f, CONFIRM_BOX * _f), false)
	_fblit("fa_cc_frame", at + _pair(layout["frame"]))
	var buttons: Array = [["cc_close", "fa_cc_close", "btnCancel"], ["cc_dec", "fa_dec", "btnDec"], ["cc_add", "fa_add", "btnAdd"], 
		["cc_ok", "fa_ok", "btnConfirm"]]
	for row: Array in buttons:
		if live:
			_fbutton(str(row[0]), str(row[1]), at + _pair(layout[row[2]]))
		else:
			_fblit(str(row[1]), at + _pair(layout[row[2]]))
	var field: Array = layout["txtBuyNum"]
	var rect: Rect2 = Rect2(at + Vector2(float(field[0]), float(field[1])), Vector2(float(field[2]), float(field[3])))
	if live:
		_fput(_qty, rect, 20.0, "c")
	else:
		_fwords(str(_amount), ARIAL_BOLD, 20.0, Color("fff352"), "c", rect.position, rect.size.x, 0.0, rect.size.y)
	var ct: int = 2
	var total: int = int(_plan_cost[_amount]) if _amount >= 0 and _amount < _plan_cost.size() else 0
	if _dlg != "all":
		if _pick.is_empty() or int(_pick[2]) <= 0:
			return
		ct = int(_pick[1])
		total = int(_pick[2]) * _amount
	var spot: Array = layout["rows"]
	var line: Vector2 = at + Vector2(float(spot[0]), float(spot[1]))
	_fblit("fa_cc_row", line)
	_fit(pack.picture(_coin_art(ShopModel.coin_index(ct))), line + _pair(layout["icon"]), Vector2(22, 22), 1.0)
	_fwords(str(total), ARIAL_BOLD, 14.0, Color.WHITE, "l", line + Vector2(float(layout["name"][0]), float(layout["value"][1])), 160.0, 0.0, 22.0)


func _draw_swap() -> void :
	var at: Vector2 = _window(358, 200, "swap_no")
	_fwords("Xác nhận", ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2(0, 18), 358.0, 1.0, 28.0)
	_fpara(_swap_text(), ARIAL_BOLD, 14.0, Color.WHITE, at + Vector2(30, 66), 298.0, 4)
	_fbutton("swap_yes", "fa_ok", at + Vector2(119, 200 - 50))

static func _pair(row: Array) -> Vector2:
	return Vector2(float(row[0]), float(row[1]))





func _convert_click() -> void :
	if _index < 0 or _index >= _recipes.size() or _index >= _slots.size():
		return
	var ids: Array = Cv2.IDS.get(str(_tid), [])
	var slot: int = int(_slots[_index])
	if slot >= ids.size():
		return
	var owner: Array = Cv2.TANK_OF.get(str(_tid), [])
	if not owner.is_empty():
		var tank: int = int(owner[0])
		if int(owner[1]) == int(Cv2.TYPES["card"]):
			if tank != 0 and _has_tank(tank):
				say(str(Cv2.WORDS["TIP_769"]))
				return
		else:
			if tank != 0 and not _has_tank(tank):
				var tank_name: String = GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(tank), "")))
				say(str(Cv2.WORDS["CONTROL_TEXT461"]).replace("@name@", tank_name).replace("@item@", GarageModel.cap(str(_entry.name))))
				return
			if _has_skin(_tid):
				say(str(Cv2.WORDS["TIP_285"]))
				return
	_pick = _recipes[_index]
	_pick_id = int(ids[slot][0])
	_pick_max = int(ids[slot][1])
	_most_n = _most()
	_amount = _most_n
	_open_sheet("one")



func _most() -> int:
	var most: int = 4294967295
	var price: int = int(_pick[2])
	if price > 0:
		match int(_pick[1]):
			1:
				most = _purse("m_iCash") / price
			3:
				most = (_purse("m_iCash") + _purse("m_iSilver")) / price
			_:
				most = _purse("m_iGolden") / price
	for part: Variant in _pick[3]:
		if int(part[1]) > 0:
			most = mini(most, _have(int(part[0])) / int(part[1]))
	var owner: Array = Cv2.TANK_OF.get(str(_tid), [])
	if not owner.is_empty() and int(owner[1]) == int(Cv2.TYPES["skin"]):
		most = mini(most, 1)
	elif _pick_max != 0:
		most = mini(most, _pick_max)
	return clampi(most, 0, MOST)


func _coin_vec() -> Array:
	var price: int = int(_pick[2]) if not _pick.is_empty() else 0
	if price <= 0:
		return []
	var total: int = price * _amount
	if int(_pick[1]) == 3:
		var gift: int = _purse("m_iSilver")
		if gift >= total:
			return [[3, total]]
		var out: Array = [[3, gift]] if gift > 0 else []
		out.append([1, total - gift])
		return out
	return [[int(_pick[1]), total]]

func _swap_text() -> String:
	for coin: Array in _coin_vec():
		if int(coin[0]) == 1:
			return str(Cv2.WORDS["TIP_520"]).replace("@num1@", str(int(coin[1]))).replace("@num2@", str(int(coin[1])))
	return ""


func _all_click() -> void :
	var vip: int = maxi(int(client.character.get("vipTime", 0)), int(client.character.get("superVipTime", 0)))
	if vip <= _now():
		page_asked.emit("events:vip")
		say(str(Cv2.WORDS["TIP_443"]))
		return
	_plan(_tid)
	_amount = _most_n
	_open_sheet("all")



func _plan(tid: int) -> void :
	_plan_cost = [0]
	_plan_info = [[]]
	_most_n = 0
	var gold: int = _purse("m_iGolden")
	var n: int = 1
	while true:
		var acc: Array = [0, []]
		if not _try_add(tid, n, acc, 0) or n >= MOST or int(acc[0]) > gold:
			break
		_plan_cost.append(int(acc[0]))
		_plan_info.append(acc[1])
		_most_n = n
		n += 1



func _try_add(item: int, n: int, acc: Array, depth: int) -> bool:
	if depth > UP_DEPTH:
		return false
	var at: int = _material_recipe(item)
	if at < 0:
		return false
	var recipe: Array = Atlas.CONVERT[str(item)][at]
	acc[0] = int(acc[0]) + int(recipe[2]) * n
	for part: Variant in recipe[3]:
		var id: int = int(part[0])
		var need: int = int(part[1]) * n
		if id == 0 or need == 0:
			continue
		var have: int = _have(id)
		if have < need and not _try_add(id, need - have, acc, depth + 1):
			return false
	(acc[1] as Array).append([int(Cv2.IDS[str(item)][at][0]), n])
	return true


func _material_recipe(item: int) -> int:
	var now: int = _now()
	var list: Array = Atlas.CONVERT.get(str(item), [])
	var ids: Array = Cv2.IDS.get(str(item), [])
	for i: int in mini(list.size(), ids.size()):
		var recipe: Variant = list[i]
		if recipe is Array and int(recipe[0]) in [2, 5] and int(recipe[1]) == 2 and _in_time(recipe, now):
			return i
	return -1

func _open_sheet(kind: String) -> void :
	_dlg = kind
	_qty.text = str(_amount)
	_tip = []
	_press = ""

func _close_sheet() -> void :
	_dlg = ""
	_pick = []
	_plan_cost = []
	_plan_info = []
	if _qty != null:
		_hide_edits()


func _on_qty_input() -> void :
	if _dlg not in ["one", "all"]:
		return
	var typed: String = _qty.text.strip_edges()
	var value: int = mini(int(typed) if typed.is_valid_int() else 0, _most_n)
	value = maxi(value, 1 if _dlg == "one" else 0)
	_amount = value
	if typed != str(value):
		_qty.text = str(value)
		_qty.caret_column = _qty.text.length()


func _step_qty(step: int) -> void :
	if _dlg == "one":
		if (step < 0 and _amount <= 1) or (step > 0 and _amount >= _most_n):
			return
		_amount += step
	else:
		_amount = clampi(_amount + step, 0, _most_n)
	_qty.text = str(_amount)


func _confirm() -> void :
	match _dlg:
		"one":
			if _amount < 1:
				_close_sheet()
				return
			if int(_pick[1]) == 3 and not _swap_text().is_empty():
				_dlg = "swap"
				_hide_edits()
				return
			_send_one()
		"swap":
			_send_one()
		"all":
			_send_all()



func _send_one() -> void :
	var infos: Array = [[_pick_id, _amount]]
	var coins: Array = _coin_vec()
	_close_sheet()
	if not client.convert_items(infos, coins):
		say(UNSENT)
		return
	if not _stack.is_empty():
		_show(_stack.pop_back())


func _send_all() -> void :
	var n: int = _amount
	var infos: Array = _plan_info[n] if n >= 1 and n < _plan_info.size() else []
	var cost: int = int(_plan_cost[n]) if not infos.is_empty() else 0
	_close_sheet()
	if infos.is_empty():
		say(str(Cv2.WORDS["TIP_444"]))
		return
	if not client.convert_items(infos, [[2, cost]]):
		say(UNSENT)

func _sheet_activate(id: String) -> void :
	match _dlg:
		"one", "all":
			match id:
				"cc_close":
					_close_sheet()
				"cc_dec":
					_step_qty(-1)
				"cc_add":
					_step_qty(1)
				"cc_ok":
					_confirm()
		"swap":
			match id:
				"swap_yes":
					_confirm()
				"swap_no":
					_dlg = "one"



func _activate(id: String) -> void :
	if not visible:
		return
	if not _dlg.is_empty():
		_sheet_activate(id)
		return
	var cut: int = id.find(":")
	var head: String = id.left(cut) if cut >= 0 else id
	var tail: String = id.substr(cut + 1) if cut >= 0 else ""
	match head:
		"close":
			close()
		"buy":
			if Atlas.BUY.has(str(_tid)):
				quick_buy_asked.emit(int(Atlas.BUY[str(_tid)]))
		"back":
			if not _stack.is_empty():
				_show(_stack.pop_back())
		"last":
			_index = maxi(0, _index - 1)
		"next":
			_index = mini(_recipes.size() - 1, _index + 1)
		"convert":
			_convert_click()
		"all":
			_all_click()
		"mat":
			open(int(tail))
		"bar":
			_scroll += float(int(tail)) * _node("hboxMap").size.x
		"route":
			_go(int(tail))


func _go(i: int) -> void :
	if i < 0 or i >= _routes.size():
		return
	var state: String = str(_routes[i][0])
	match state:
		"shop_gambling", "mk":
			page_asked.emit("shop")
		"teammatch", "guild":
			page_asked.emit("guild")
		"boss":
			page_asked.emit("fair:center:5")
		"Summer":
			page_asked.emit("fair:prize")
		"normal_gambling", "vip_gambling":
			page_asked.emit("fair:wheel")
		"pvp":
			if _blocked():
				return
			close()
			arena_asked.emit()
		"HAPPY", "FIRE":
			if _blocked():
				return
			close()
			page_asked.emit("act")
		"pve", "solo", "pve_entrance":
			if _blocked():
				return
			if client.state != "lobby":
				say(PVE_HALL)
				return
			var map: int = int(_routes[i][1])
			close()
			page_asked.emit("pve:%d" % map if map > 0 else "pve")
		"ladder":


			if client.state == "room":
				say(BagModel.TIP_ROOM)
				return
			if client.is_pairing():
				say(client.INVITE_PAIRING)
				return
			close()
			client.back_to_lobby()
		"expedition":

			if int(client.character.get("level", 0)) < EXPED_LEVEL:
				say(EXPED_TIP8.replace("@num1@", str(EXPED_LEVEL)))
			elif client.get("expedition") == null or not bool(client.expedition.get("live", false)):
				say(EXPED_OFF)
			elif client.state != "lobby":
				say(EXPED_HALL)
			else:
				expedition_asked.emit()
		"guild_boss":

			if client.get("guild_boss") == null or not bool(client.guild_boss.get("live", false)):
				say(SOON % str(NAMES.get(state, "Mục này")))
			elif client.state != "lobby":
				say(GB_HALL)
			else:
				guild_boss_asked.emit()
		"Rent":

			var tank: int = int(RENT_TANK.get(_tid, 0))
			if tank > 0:
				page_asked.emit("tank:rent:%d" % tank)
		_:
			say(SOON % str(NAMES.get(state, "Mục này")))


func _blocked() -> bool:
	if client.state == "room":
		say(BagModel.TIP_ROOM)
		return true
	if client.is_pairing():
		say(client.INVITE_PAIRING)
		return true
	return false

func _wheel(step: int, at: Vector2) -> void :
	var o: Vector2 = _origin()
	var box: Rect2 = _node("hboxMap")
	if Rect2((o + box.position) * _f, box.size * _f).has_point(at):
		_scroll += float(step) * (CELL.x + GAP)
	elif Rect2(_desc_rect(o).position * _f, _desc_rect(o).size * _f).has_point(at):
		_desc_top += step


func _drag(moved: Vector2, from: Vector2) -> void :
	var o: Vector2 = _origin()
	var box: Rect2 = _node("hboxMap")
	var bar: Rect2 = _bar_rect(o)
	if Rect2(bar.position * _f, bar.size * _f).has_point(from):
		_scroll += moved.x / _f * _content() / box.size.x
	elif Rect2((o + box.position) * _f, Vector2(box.size.x, CELL.y) * _f).has_point(from):
		_scroll -= moved.x / _f


func _input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree() or _dlg.is_empty() or not (event is InputEventKey and event.pressed) or event.echo:
		return
	match event.keycode:
		KEY_ESCAPE:
			if _dlg == "swap":
				_dlg = "one"
			else:
				_close_sheet()
		KEY_ENTER, KEY_KP_ENTER:
			_confirm()
		_:
			return
	get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.echo:
		return
	if event.keycode != KEY_ESCAPE or get_viewport().gui_get_focus_owner() is LineEdit:
		return
	close()
	get_viewport().set_input_as_handled()
