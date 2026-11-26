extends RefCounted
























const Garage = preload("garage.gd")
const GarSkin = preload("gar_skin_atlas.gd")
const GarageModel = preload("garage_model.gd")
const TankPortrait = preload("tank_portrait.gd")
const BagAtlas = preload("bag_atlas.gd")
const GarageAtlas = preload("garage_atlas.gd")
const Atlas = preload("selecttank_atlas.gd")
const ARIAL: Font = preload("res://assets/fonts/flash_ui.tres")
const ARIAL_BOLD: Font = preload("res://assets/fonts/flash_ui_bold.tres")

const MID: String = "Chọn trang phục"
const READY: String = "Đang chuẩn bị vào"
const ROUND_SWAP: bool = true
const HEAD: String = "CHỌN TRANG PHỤC!"
const LOCKED_MSG: String = "Chưa sở hữu skin này"
const WORN_MSG: String = "Đang mặc trang phục này."
const FAIL_MSG: String = "Chưa đổi được trang phục lúc này."
const LATE_MSG: String = "Máy chủ chưa đổi trang phục, hãy thử lại."
const DEFAULT_NAME: String = "Mặc định"
const DEFAULT_DESC: String = "Ngoại hình gốc của xe."
const COUNT: String = "Đã có %d/%d"
const NONE_HINT: String = "Xe này chưa có trang phục nào"
const HAS_TEXT: String = "Đã có"
const WAIT_TEXT: String = "Đang mặc…"
const NOT_HAS: String = "Chưa sở hữu"
const ATTR_TITLE: String = "Thuộc tính sưu tập"



const FRAME: Rect2 = Rect2(233, 96, 539, 303)
const AREA: Rect2 = Rect2(228, 59, 549, 345)



const INFO_SIZE: Vector2 = Vector2(215, 538)
const INFO_TOUCH: Rect2 = Rect2(2.5, 0, 215, 533)
const MID_X: float = 502.5
const HEAD_Y: float = 59.0
const HEAD_H: float = 31.0
const SIDE_W: float = 140.0
const VIEW_FIT: Rect2 = Rect2(372.5, 104, 260, 172)
const VIEW_C: Vector2 = Vector2(502.5, 190)
const VIEW_ZOOM: float = 0.95
const VIEW_MAX: float = 1.6
const VIEW_CLIP: Rect2 = Rect2(350, 99, 305, 188)
const FULL_ALPHA: int = 12
const FULL_SCAN: int = 100
const ARC_R: float = 160.0
const ARC_SPAN: float = 32.0
const LOCK_R: Vector2 = Vector2(140, 86)
const SIDE_COL: float = 104.0
const LEFT_X: float = 239.0
const RIGHT_X: float = 662.0
const GRADE_Y: float = 160.0
const STATE_Y: float = 176.0
const LEFT_Y: float = 206.0
const NAME_Y: float = 290.0
const NAME_H: float = 21.0
const DOT_Y: float = 317.0
const DOT_GAP: float = 11.0
const STRIP_Y: float = 359.0
const BIG: float = 64.0
const SMALL: float = 52.0
const GAP: float = 12.0
const SLOTS: int = 2
const ARROW: Vector2 = Vector2(33, 29)
const ARROW_GAP: float = 14.0
const TILE_K: float = 0.005
const DIM_TILE: Color = Color(0, 0, 0, 0.55)
const DIM_SIDE: Color = Color(0, 0, 0, 0.38)
const DIM_VIEW: Color = Color(0, 0, 0, 0.5)
const SHADE: Color = Color(0, 0, 0, 0.8)
const HINT_COLOR: Color = Color("a6d6ff")
const HEAD_COLOR: Color = Color("fcc853")
const GOLD: Color = Color("ffd76a")
const GREEN: Color = Color("6fe3a1")
const RED: Color = Color("ff6b6b")
const DESC_COLOR: Color = Color("d6ecff")
const ATTR_COLOR: Color = Color("ffdd1f")
const SLANT: float = 0.2
const PICK_MS: int = 400
const WAIT_MS: int = 4000
const GAP_MS: int = 1000

var cursor: int = 0
var shown: Array = []
var label: String = ""
var status: String = ""
var dots: int = 0
var view_rect: Rect2 = Rect2()
var info_rect: Rect2 = Rect2()
var _key: String = ""
var _due_at: int = 0
var _wait_uuid: String = ""
var _wait_until: int = 0
var _sent_at: int = -100000
var _seen_uuid: String = ""
var _seen_scene: int = 0
var _seen_pick_ext: int = 0
var _ready_cells: bool = false
var _full: Dictionary = {}
var _view: WeakRef = null




func owned_inst(view) -> Dictionary:
	var best: Dictionary = {}
	if view == null or view.client == null:
		return best
	var tank: int = int(view.my_tank())
	if tank <= 0:
		return best
	for inst: Variant in (view.client.tanks as Dictionary).values():
		if not (inst is Dictionary):
			continue
		if int(inst.get("m_tpltId", 0)) != tank or int(inst.get("m_contType", -1)) != GarageModel.OWN or str(inst.get("m_tankUuid", "")).is_empty():
			continue
		if best.is_empty() or int(inst.get("m_level", 1)) > int(best.get("m_level", 1)):
			best = inst
	return best


func active(view) -> bool:
	if view == null or view.client == null or view.pack == null or (view.pair() as Dictionary).is_empty():
		return false
	if not bool(view.locked(int(view.client.account_oid))) or int(view.my_tank()) <= 0:
		return false
	if (view.pack.garage as Dictionary).is_empty():
		return false
	return not owned_inst(view).is_empty()


static func held(bags: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for inst: Variant in bags.get(6, []):
		if inst is Dictionary and int(inst.get("m_count", 0)) > 0 and not out.has(int(inst.get("m_templateId", 0))):
			out[int(inst.get("m_templateId", 0))] = inst
	return out


func entries(view, inst: Dictionary) -> Array:
	var tank: int = int(inst.get("m_tpltId", 0))
	var base: int = GarageModel.exterior(view.pack.garage, view.pack.index.get("tanks", {}), tank, int(inst.get("m_level", 1)), {})
	var worn: int = int(inst.get("m_externalId", 0))
	var list: Array = Garage.skin_list((GarSkin.SKINS.get(str(tank), []) as Array) + (GarSkin.SKINS.get("0", []) as Array), GarSkin.EXTQ, 
		held(view.client.bags), worn, base, 0)
	if not list.any( func(entry: Dictionary) -> bool: return int(entry.item) == 0):
		list.push_front({"item": 0, "ext": base, "has": true, "equip": worn == 0 or worn == base, "uuid": "", "bag": {}, "row": []})
	return list


static func quality(entry: Dictionary) -> int:
	if int(entry.item) == 0:
		return 0
	var row: Array = entry.row
	return int(GarSkin.EXTQ.get(str(int(entry.ext)), int(row[2]) if row.size() > 2 else 0))

static func tint(q: int) -> Color:
	return Garage.HALO_QUALITY.get(q, Color.WHITE if q <= 1 else Garage.HALO_QUALITY[5])

static func title(entry: Dictionary) -> String:
	return DEFAULT_NAME if int(entry.item) == 0 or (entry.row as Array).size() < 4 else str(entry.row[3])


func busy(now: int) -> bool:
	return ( not _wait_uuid.is_empty() and now < _wait_until) or now - _sent_at < GAP_MS


func seconds(view) -> int:
	if view.client != null and view.client.pair_all_locked():
		return int(view.round_seconds())
	return int(view.seconds_left())


func mid_text(view, normal: String) -> String:
	if view.client == null or not view.client.pair_all_locked():
		return normal
	if view.round_mode() and not ROUND_SWAP:
		return normal
	return MID if active(view) else READY




static func slot_x(slot: int) -> float:
	if slot == 0:
		return MID_X - BIG / 2.0
	if slot > 0:
		return MID_X + BIG / 2.0 + GAP + float(slot - 1) * (SMALL + GAP)
	return MID_X - BIG / 2.0 - GAP - SMALL - float( - slot - 1) * (SMALL + GAP)


static func arrow_at(next: bool) -> Vector2:
	var y: float = STRIP_Y - ARROW.y / 2.0
	if next:
		return Vector2(slot_x(SLOTS) + SMALL + ARROW_GAP, y)
	return Vector2(slot_x( - SLOTS) - ARROW_GAP - ARROW.x, y)



func _cells(view) -> void :
	if _ready_cells and view._cells.has("bag_q2"):
		return
	_ready_cells = true
	var bag: Dictionary = {}
	for name: String in ["bag_q2", "bag_q3", "bag_q4", "bag_q5"]:
		bag[name] = BagAtlas.R[name]
	view._use(BagAtlas.FILE, bag)
	view._use(GarageAtlas.FILE, {"garage_pg_prev": GarageAtlas.R["garage_pg_prev"], "garage_pg_next": GarageAtlas.R["garage_pg_next"]})
	view._use(GarSkin.FILE, {"gar_skin_qbg": GarSkin.R["gar_skin_qbg"], "gar_skin_equip": GarSkin.R["gar_skin_equip"]})


func paint(view, o: Vector2) -> bool:
	shown = []
	label = ""
	status = ""
	dots = 0
	view_rect = Rect2()
	if not active(view):
		_key = ""
		_due_at = 0
		return false
	_view = weakref(view)
	_cells(view)
	var client = view.client
	var pack = view.pack
	pack.load_garagex()
	if not client.tank_changed.is_connected(_on_tank_changed):
		client.tank_changed.connect(_on_tank_changed)
	var now: int = Time.get_ticks_msec()
	if not _wait_uuid.is_empty() and now >= _wait_until:
		_wait_uuid = ""
		view.say(LATE_MSG)
	var inst: Dictionary = owned_inst(view)
	var tank: int = int(inst.get("m_tpltId", 0))
	var list: Array = entries(view, inst)
	var key: String = "%d:%d" % [int(view.pair().get("scene", 0)), tank]
	if key != _key:
		_key = key
		_due_at = 0
		cursor = 0
		for i in range(list.size()):
			if bool(list[i].equip):
				cursor = i
	cursor = clampi(cursor, 0, list.size() - 1)
	_fire(view, list, inst, now)
	var f: float = view._f
	view._hit("skins", Rect2((o + AREA.position) * f, AREA.size * f), false)

	var owned: int = 0
	var total: int = 0
	for entry: Dictionary in list:
		if int(entry.item) != 0:
			total += 1
			if bool(entry["has"]):
				owned += 1
	var name: String = str(pack.lobby.get("tanks", {}).get(str(tank), ""))
	view._fwords(name, ARIAL_BOLD, 14.0, HINT_COLOR, "l", o + Vector2(FRAME.position.x + 6.0, HEAD_Y), SIDE_W, 1.0, HEAD_H)
	view._fwords(HEAD, ARIAL_BOLD, 22.0, HEAD_COLOR, "c", o + Vector2(MID_X - 115.0, HEAD_Y), 230.0, 1.5, HEAD_H)
	if total > 0:
		view._fwords(COUNT % [owned, total], ARIAL_BOLD, 13.0, HINT_COLOR, "r", o + Vector2(FRAME.end.x - 6.0 - SIDE_W, HEAD_Y), SIDE_W, 1.0, HEAD_H)
	var entry: Dictionary = list[cursor]
	var level: int = int(inst.get("m_level", 1))
	var unix: int = int(Time.get_unix_time_from_system())
	_preview(view, o, entry, inst, tank, level)
	_arcs(view, o + VIEW_C)
	_sides(view, o, entry, now, unix)

	var q: int = quality(entry)
	label = title(entry)
	_slanted(view, label, 17.0, Color.WHITE if int(entry.item) == 0 else tint(q), o + Vector2(MID_X, NAME_Y), 300.0, NAME_H)
	if total == 0:
		view._fwords(NONE_HINT, ARIAL, 12.0, HINT_COLOR, "c", o + Vector2(MID_X - 150.0, DOT_Y - 8.0), 300.0, 1.0, 16.0)
	else:
		dots = list.size()
		var x0: float = MID_X - DOT_GAP * float(dots - 1) / 2.0
		for i in range(dots):
			var at: Vector2 = (o + Vector2(x0 + DOT_GAP * float(i), DOT_Y)) * f
			if i == cursor:
				view.draw_circle(at, 3.5 * f, GOLD)
			else:
				view.draw_circle(at, 2.5 * f, Color(1, 1, 1, 0.35))

	for slot in range( - SLOTS, SLOTS + 1):
		var index: int = cursor + slot
		if index < 0 or index >= list.size():
			continue
		var side: float = BIG if slot == 0 else SMALL
		_tile(view, o + Vector2(slot_x(slot), STRIP_Y - side / 2.0), side, list[index], tank, level, slot)
	if list.size() > 1:
		var dim: Color = Color(1, 1, 1, 0.35)
		var prev: Vector2 = o + arrow_at(false)
		var next: Vector2 = o + arrow_at(true)
		view._fblit("garage_pg_prev", prev, 0.0, 0.0, view._glow("skin:prev") if cursor > 0 else dim)
		view._hit("skin:prev", Rect2(prev * f, ARROW * f), false)
		view._fblit("garage_pg_next", next, 0.0, 0.0, view._glow("skin:next") if cursor < list.size() - 1 else dim)
		view._hit("skin:next", Rect2(next * f, ARROW * f), false)
	return true


func _arcs(view, c: Vector2) -> void :
	var f: float = view._f
	var span: float = deg_to_rad(ARC_SPAN)
	for base: float in [0.0, PI]:
		view.draw_arc(c * f, ARC_R * f, base - span, base + span, 40, Color(GOLD, 0.16), 6.0 * f, true)
		view.draw_arc(c * f, ARC_R * f, base - span, base + span, 40, Color(GOLD, 0.9), 1.5 * f, true)
		for end: float in [base - span, base + span]:
			view.draw_circle((c + Vector2(cos(end), sin(end)) * ARC_R) * f, 2.0 * f, GOLD)




func _preview(view, o: Vector2, entry: Dictionary, inst: Dictionary, tank: int, level: int) -> void :
	var pack = view.pack
	var f: float = view._f
	var clip: Rect2 = Rect2((o + VIEW_CLIP.position) * f, VIEW_CLIP.size * f)
	var ext: int = int(entry.ext)
	var face: String = str(view.face_key(pack.garage, pack.index.get("tanks", {}), tank, level, ext))
	var centre: Vector2 = o + VIEW_C
	var zoom: float = VIEW_ZOOM
	var box: Rect2 = Rect2() if face.is_empty() else full_box(view, face)
	if box.has_area():
		var frame: Rect2 = Rect2(o + VIEW_FIT.position, VIEW_FIT.size)
		zoom = minf(VIEW_MAX, minf(frame.size.x / box.size.x, frame.size.y / box.size.y))
		centre = frame.get_center() - (box.get_center() - Vector2(TankPortrait.BOX, TankPortrait.BOX) * 0.5) * zoom
		view_rect = Rect2((centre + (box.position - Vector2(TankPortrait.BOX, TankPortrait.BOX) * 0.5) * zoom) * f, box.size * zoom * f)
	var folder: String = "l/t"
	if not face.is_empty() and (pack.garage.get("big", []) as Array).has(face) and pack.picture("l/tb/%s.webp" % face) != null:
		folder = "l/tb"
	var halo: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(inst.get("m_haloId", 0)), level)
	if face.is_empty() or not TankPortrait.draw(view, pack, face, halo, centre * f, zoom * f, view._time, folder, true, clip):
		view._stand_in(tank, ext, o + VIEW_C, VIEW_ZOOM * 1.4, 200.0)
	view._hit("skin:view", clip, false)
	if bool(entry["has"]):
		return
	var c: Vector2 = o + VIEW_C
	var ring: PackedVector2Array = PackedVector2Array()
	for i in range(48):
		var a: float = TAU * float(i) / 48.0
		ring.append((c + Vector2(cos(a) * LOCK_R.x, sin(a) * LOCK_R.y)) * f)
	view.draw_colored_polygon(ring, DIM_VIEW)
	var lock: Vector2 = Vector2(29, 38) * 1.5
	view._fblit("st_lock", c - lock / 2.0, lock.x, lock.y)



func full_box(view, face: String) -> Rect2:
	if _full.has(face):
		return _full[face]
	var picture: Texture2D = view.pack.picture("l/t/%s.webp" % face)
	if picture == null:
		return view.head_box(face)
	var spot: Rect2 = TankPortrait.still_rect(TankPortrait.movie(view.pack.garage, face), Vector2.ZERO, 1.0, TankPortrait.side(view.pack.garage, face))
	var box: Rect2 = alpha_box(picture.get_image(), spot, FULL_ALPHA)
	if not box.has_area():
		return view.head_box(face)
	_full[face] = box
	return box


static func alpha_box(image: Image, spot: Rect2, least: int) -> Rect2:
	if image == null or image.is_empty() or not spot.has_area():
		return Rect2()
	var small: Image = image.duplicate()
	if small.is_compressed():
		small.decompress()
	small.convert(Image.FORMAT_RGBA8)
	if small.get_width() > FULL_SCAN or small.get_height() > FULL_SCAN:
		small.resize(mini(small.get_width(), FULL_SCAN), mini(small.get_height(), FULL_SCAN), Image.INTERPOLATE_BILINEAR)
	var w: int = small.get_width()
	var h: int = small.get_height()
	var data: PackedByteArray = small.get_data()
	var low: Vector2i = Vector2i(w, h)
	var high: Vector2i = Vector2i(-1, -1)
	for y in range(h):
		for x in range(w):
			if data[(y * w + x) * 4 + 3] > least:
				low = Vector2i(mini(low.x, x), mini(low.y, y))
				high = Vector2i(maxi(high.x, x), maxi(high.y, y))
	if high.x < 0:
		return Rect2()
	var ratio: Vector2 = spot.size / Vector2(w, h)
	return Rect2(spot.position + Vector2(low) * ratio, Vector2(high - low + Vector2i(1, 1)) * ratio)



func _sides(view, o: Vector2, entry: Dictionary, now: int, unix: int) -> void :
	var q: int = quality(entry)
	if q >= 2:
		var badge: Vector2 = Vector2(47, 25) * 1.3
		view._fblit("gar_skin_qbg", o + Vector2(LEFT_X + (SIDE_COL - badge.x) / 2.0, GRADE_Y), badge.x, badge.y)
		view._fwords(GarageModel.grade(q), ARIAL_BOLD, 30.0, tint(q), "c", o + Vector2(LEFT_X, GRADE_Y + badge.y + 2.0), SIDE_COL, 1.5, 34.0)
	elif int(entry.item) == 0:
		view._fpara(DEFAULT_DESC, ARIAL_BOLD, 13.0, HINT_COLOR, o + Vector2(LEFT_X + 6.0, GRADE_Y + 6.0), SIDE_COL - 12.0, 3)
	var x: float = RIGHT_X
	if not bool(entry["has"]):
		view._fwords(NOT_HAS, ARIAL_BOLD, 15.0, RED, "c", o + Vector2(x, STATE_Y), SIDE_COL, 1.0, 24.0)
		status = "lock"
	elif bool(entry.equip):
		var badge: Vector2 = Vector2(65, 19) * 1.4
		view._fblit("gar_skin_equip", o + Vector2(x + (SIDE_COL - badge.x) / 2.0, STATE_Y), badge.x, badge.y)
		status = "equip"
	elif _due_at > 0 or busy(now):
		view._fwords(WAIT_TEXT, ARIAL_BOLD, 15.0, HINT_COLOR, "c", o + Vector2(x, STATE_Y), SIDE_COL, 1.0, 24.0)
		status = "wait"
	else:
		view._fwords(HAS_TEXT, ARIAL_BOLD, 15.0, GREEN, "c", o + Vector2(x, STATE_Y), SIDE_COL, 1.0, 24.0)
		status = "has"
	if bool(entry["has"]) and int((entry.bag as Dictionary).get("m_lifeTime", 0)) > 0:
		view._fwords(Garage.skin_left(entry.bag, unix), ARIAL_BOLD, 12.0, Color.WHITE, "c", o + Vector2(x - 6.0, LEFT_Y), SIDE_COL + 12.0, 1.0, 18.0)



func _tile(view, at: Vector2, side: float, entry: Dictionary, tank: int, level: int, slot: int) -> void :
	var f: float = view._f
	var pack = view.pack
	var item: int = int(entry.item)
	var id: String = "skin:%d" % item
	var has: bool = bool(entry["has"])
	var equip: bool = bool(entry.equip)
	var q: int = quality(entry)
	view._fblit("st_tile_on" if equip else "st_tile", at, side, side, view._glow(id))
	var ext: int = int(entry.ext)
	var face: String = str(view.face_key(pack.garage, pack.index.get("tanks", {}), tank, level, ext))
	var mid: Vector2 = at + Vector2(side, side) / 2.0
	var clip: Rect2 = Rect2(at * f, Vector2(side, side) * f)
	if face.is_empty() or not TankPortrait.draw(view, pack, face, 0, mid * f, TILE_K * side * f, view._time, "l/t", true, clip):
		view._stand_in(tank, ext, mid, TILE_K * side, side - 4.0)
	if q >= 2:
		view._fblit("bag_q%d" % clampi(q, 2, 5), at, side, side)
	if slot != 0:
		view.draw_rect(clip, DIM_SIDE)
	if not has:
		view.draw_rect(clip, DIM_TILE)
		var lock: Vector2 = Vector2(29, 38) * (side / 96.0) * 1.1
		view._fblit("st_lock", at + (Vector2(side, side) - lock) / 2.0, lock.x, lock.y)
	if equip:
		var badge: Vector2 = Vector2(65, 19) * (side * 0.9 / 65.0)
		view._fblit("gar_skin_equip", at + Vector2((side - badge.x) / 2.0, side - badge.y + 2.0), badge.x, badge.y)
	if slot == 0:
		view._round(Rect2((at - Vector2(3.5, 3.5)) * f, Vector2(side + 7.0, side + 7.0) * f), Color(0, 0, 0, 0), 10.0, Color(GOLD, 0.35), 4.0)
		view._round(Rect2((at - Vector2(1.5, 1.5)) * f, Vector2(side + 3.0, side + 3.0) * f), Color(0, 0, 0, 0), 6.0, GOLD, 2.5)
	view._hit(id, clip, false)
	shown.append({"item": item, "has": has, "equip": equip, "rect": clip, "quality": q, "name": title(entry), "slot": slot})



func _slanted(view, text: String, px: float, color: Color, at: Vector2, wide: float, high: float) -> void :
	var f: float = view._f
	var size: float = px
	while size > 8.0 and ARIAL_BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(size * f))).x > wide * f:
		size -= 1.0
	var font_size: int = maxi(6, roundi(size * f))
	var origin: Vector2 = Vector2(at.x - wide / 2.0, at.y + high / 2.0) * f
	origin.y += (ARIAL_BOLD.get_ascent(font_size) - ARIAL_BOLD.get_descent(font_size)) / 2.0
	view.draw_set_transform_matrix(Transform2D(Vector2(1, 0), Vector2( - SLANT, 1), Vector2(SLANT * origin.y, 0)))
	view.draw_string_outline(ARIAL_BOLD, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * f, font_size, maxi(1, roundi(f)), SHADE)
	view.draw_string(ARIAL_BOLD, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * f, font_size, color)
	view.draw_set_transform_matrix(Transform2D.IDENTITY)





func info_entry(view) -> Dictionary:
	if not active(view):
		return {}
	var hover: String = str(view._hover)
	if hover.is_empty() and bool(view._mobile):
		hover = str(view._press)
	var list: Array = entries(view, owned_inst(view))
	if list.is_empty() or not hover.begins_with("skin:") or hover in ["skin:prev", "skin:next"]:
		return {}
	if hover == "skin:view":
		return list[clampi(cursor, 0, list.size() - 1)]
	var want: int = int(hover.substr(5))
	for one: Dictionary in list:
		if int(one.item) == want:
			return one
	return {}


func info_box(view) -> Rect2:
	return INFO_TOUCH if bool(view._mobile) else Rect2(view._xy(Atlas.AT.info_bg), INFO_SIZE)



func info(view, o: Vector2) -> bool:
	info_rect = Rect2()
	if not active(view):
		return false
	var inst: Dictionary = owned_inst(view)
	var entry: Dictionary = info_entry(view)
	if entry.is_empty():
		return true
	var box: Rect2 = info_box(view)
	o += box.position - view._xy(Atlas.AT.info_bg)
	info_rect = Rect2((o + view._xy(Atlas.AT.info_bg)) * view._f, box.size * view._f)
	_info_bg(view, o + view._xy(Atlas.AT.info_bg), box.size.y)
	var q: int = quality(entry)
	var colour: Color = Color.WHITE if int(entry.item) == 0 else tint(q)
	view._label("lblTankName", title(entry), o, colour, 1.5)
	var x: float = 805.5
	if q >= 2:
		view._fblit("gar_skin_qbg", o + Vector2(x, 90))
		view._fwords(GarageModel.grade(q), ARIAL_BOLD, 16.0, colour, "l", o + Vector2(x + 52.0, 90), 100.0, 1.0, 25.0)
	if bool(entry.equip):
		view._fblit("gar_skin_equip", o + Vector2(x, 121))
	elif bool(entry["has"]):
		view._fwords(HAS_TEXT, ARIAL_BOLD, 13.0, GREEN, "l", o + Vector2(x, 119), 170.0, 1.0, 22.0)
	else:
		view._fwords(NOT_HAS, ARIAL_BOLD, 13.0, RED, "l", o + Vector2(x, 119), 170.0, 1.0, 22.0)
	var bag: Dictionary = entry.bag
	if int(bag.get("m_lifeTime", 0)) > 0:
		view._fwords(Garage.skin_left(bag, int(Time.get_unix_time_from_system())), ARIAL_BOLD, 12.0, Color.WHITE, "l", o + Vector2(x, 142), 170.0, 1.0, 18.0)
	var desc: String = DEFAULT_DESC
	if int(entry.item) != 0 and (entry.row as Array).size() > 7:
		desc = GarageModel._marked(str(entry.row[7]).replace("\n", ""), "", "").strip_edges()
	view._fpara(desc, ARIAL, 13.0, DESC_COLOR, o + Vector2(x - 5.0, 166), 182.0, 16)
	var tank: int = int(inst.get("m_tpltId", 0))
	var garagex: Dictionary = view.pack.garagex
	var attrs: String = Garage.skin_desc(garagex.get("skin", {}).get(str(tank), []), Garage.skin_flags(garagex.get("skins", {}), view.client.bags, tank))
	view._fwords(ATTR_TITLE, ARIAL_BOLD, 13.0, ATTR_COLOR, "l", o + Vector2(x - 5.0, 470), 182.0, 1.0, 18.0)
	view._fpara(Garage.SKIN_NONE if attrs.is_empty() else attrs, ARIAL_BOLD, 13.0, GREEN, o + Vector2(x - 5.0, 489), 182.0, 3)
	return true



func _info_bg(view, at: Vector2, high: float = 538.0) -> void :
	var cell: Array = view._cells.get("st_info_bg", [])
	if cell.is_empty() or cell[0] == null:
		return
	var page: Texture2D = cell[0]
	var r: Array = cell[1]
	var f: float = view._f
	var x: float = float(r[0])
	var y: float = float(r[1])
	view.draw_texture_rect_region(page, Rect2(at * f, Vector2(215, 140) * f), Rect2(x, y, 215, 140))
	view.draw_texture_rect_region(page, Rect2((at + Vector2(0, 140)) * f, Vector2(215, high - 160.0) * f), Rect2(x, y + 140.0, 215, 20))
	view.draw_texture_rect_region(page, Rect2((at + Vector2(0, high - 20.0)) * f, Vector2(215, 20) * f), Rect2(x, y + 518.0, 215, 20))





func activate(view, id: String) -> bool:
	if id != "skins" and not id.begins_with("skin:"):
		return false
	if id == "skins" or not active(view):
		return true
	var list: Array = entries(view, owned_inst(view))
	if id == "skin:prev" or id == "skin:next":
		_point(list, cursor + (1 if id == "skin:next" else -1))
		return true
	var index: int = clampi(cursor, 0, list.size() - 1)
	if id != "skin:view":
		var item: int = int(id.substr(5))
		index = -1
		for i in range(list.size()):
			if int(list[i].item) == item:
				index = i
		if index < 0:
			return true
	var again: bool = index == cursor
	_point(list, index)
	var entry: Dictionary = list[index]
	if not bool(entry["has"]):
		view.say(LOCKED_MSG)
	elif bool(entry.equip) and again:
		view.say(WORN_MSG)
	return true


func wheel(view, step: int, at: Vector2) -> bool:
	if not active(view):
		return false
	var id: String = str(view._hit_at(at))
	if id != "skins" and not id.begins_with("skin:"):
		return false
	_point(entries(view, owned_inst(view)), cursor + step)
	return true



func _point(list: Array, index: int) -> void :
	if list.is_empty():
		return
	cursor = clampi(index, 0, list.size() - 1)
	var entry: Dictionary = list[cursor]
	_due_at = Time.get_ticks_msec() + PICK_MS if bool(entry["has"]) and not bool(entry.equip) else 0


func _fire(view, list: Array, inst: Dictionary, now: int) -> void :
	if _due_at <= 0 or now < _due_at or busy(now):
		return
	_due_at = 0
	var entry: Dictionary = list[cursor]
	if not bool(entry["has"]) or bool(entry.equip):
		return
	var uuid: String = str(inst.get("m_tankUuid", ""))
	if view.client.wear_skin(uuid, str(entry.uuid)):
		_wait_uuid = uuid
		_wait_until = now + WAIT_MS
		_sent_at = now
	else:
		view.say(FAIL_MSG)



func seat_pick(view, oid: int, pick: Dictionary) -> Dictionary:
	if _seen_uuid.is_empty() or pick.is_empty() or view.client == null or oid != int(view.client.account_oid):
		return pick
	if int(view.pair().get("scene", 0)) != _seen_scene or int(pick.get("ext", 0)) != _seen_pick_ext:
		_seen_uuid = ""
		return pick
	var inst: Variant = (view.client.tanks as Dictionary).get(_seen_uuid, {})
	if not (inst is Dictionary) or int(inst.get("m_tpltId", 0)) != int(pick.get("tank", 0)):
		return pick
	var ext: int = int(inst.get("m_externalId", 0))
	if ext <= 0:
		ext = GarageModel.exterior(view.pack.garage, view.pack.index.get("tanks", {}), int(pick.get("tank", 0)), int(inst.get("m_level", 1)), {})
	if ext == int(pick.get("ext", 0)):
		return pick
	var out: Dictionary = pick.duplicate()
	out["ext"] = ext
	return out


func _on_tank_changed(uuid: String, op: int) -> void :
	if op != 10:
		return
	if uuid == _wait_uuid:
		_wait_uuid = ""
	var view = _view.get_ref() if _view != null else null
	if view == null or not active(view) or uuid != str(owned_inst(view).get("m_tankUuid", "")):
		return
	var pick: Dictionary = view.pair().get("picks", {}).get(int(view.client.account_oid), {})
	_seen_uuid = uuid
	_seen_scene = int(view.pair().get("scene", 0))
	_seen_pick_ext = int(pick.get("ext", 0))
