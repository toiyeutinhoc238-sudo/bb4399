extends "flash_screen.gd"

















const Atlas = preload("mystical_atlas.gd")
const Arena = preload("arena_atlas.gd")
const GarageModel = preload("garage_model.gd")
const BagModel = preload("bag_model.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const AccCards = preload("acc_cards.gd")

signal closed
signal buy_asked(tank: int, msbt: int, item: int, ori: int, disc: int)

const SHOW_IN: Array = ["lobby", "hall", "room"]
const MSBT_TANK: int = 1
const MSBT_GIFT: int = 2
const MSBT_SKIN2S: int = 3
const MSBT_SKIN3S: int = 4
const DAY: int = 86400
const TITLE: String = "Cửa Hàng Thần Bí"
const HEADS: Array = ["Gói Ưu Đãi", "Tank", "Trang Phục 3S", "Trang Phục 2S"]
const ORI: String = "Gốc: @num1@"
const AGIO: String = "Mua @num1@ xu"
const LIMIT: String = "Đếm ngược cho HĐ: @time@"
const TIP_651: String = "Chưa có"
const SOON: String = "Chưa mở bán"
const MXML_TEXT: String = "Label"
const CARD_FILL: Color = Color("06203f", 0.72)
const CARD_EDGE: Color = Color("6fd0ff", 0.55)
const HEAD_INK: Color = Color("ffdd1f")
const CARD_Y: float = 58.0
const CARD_H: float = 474.0
const CARD_W: float = 222.0

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Arena.FILE, Arena.R)
	_use(Atlas.FILE, Atlas.R)
	if client != null:
		client.changed.connect(_follow)


func _follow() -> void :
	if visible and (client == null or client.state not in SHOW_IN):
		close()


static func is_open(game: Object, now: int) -> bool:
	return game != null and int(game.mystic_tank) > 0 and int(game.mystic_end) - now > 0


static func limit_text(left: int) -> String:
	if left < 0:
		return ""
	return AccCards.hours_minutes(left) if left < DAY else AccCards.day_hours(left)

func _now() -> int:
	return int(Time.get_unix_time_from_system())

func open() -> void :
	if visible or client == null or client.state not in SHOW_IN or not is_open(client, _now()):
		return
	_hover = ""
	_press = ""
	visible = true
	if pack != null:
		pack.load_bag()
		pack.load_garage()

func close() -> void :
	if not visible:
		return
	visible = false
	closed.emit()


func row() -> Dictionary:
	return Atlas.ROWS.get(str(int(client.mystic_tank)), {}) if client != null else {}


func item_name(item: int) -> String:
	var info: Array = pack.bag.get("items", {}).get(str(item), []) if pack != null else []
	if info.size() >= 10 and not str(info[0]).is_empty():
		return BagModel.clean(str(info[0]))
	return str(Atlas.NAMES.get(str(item), ""))


func has_tank(tank: int) -> bool:
	for inst: Variant in client.tanks.values():
		if inst is Dictionary and int(inst.get("m_tpltId", 0)) == tank and int(inst.get("m_contType", -1)) == GarageModel.OWN:
			return true
	return false


func has_skin(item: int) -> bool:
	if item <= 0:
		return false
	for inst: Variant in client.bags.get(6, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == item and int(inst.get("m_count", 0)) > 0:
			return true
	return false


func buttons(data: Dictionary) -> Array:
	var on: Array = [true, true, true, true]
	if data.is_empty():
		return on
	if has_tank(int(client.mystic_tank)):
		on[1] = false
	if has_skin(int(data.s3[0])):
		on[2] = false
	if has_skin(int(data.s2[0])):
		on[3] = false
	if not on[1] and not on[2]:
		on[0] = false
	return on


func gift_name(data: Dictionary) -> String:
	var parts: PackedStringArray = PackedStringArray()
	for item: Variant in data.gift[3]:
		parts.append(item_name(int(item)))
	return "+".join(parts)


static func goods(data: Dictionary, k: int) -> Array:
	match k:
		1:
			return [MSBT_GIFT, int(data.gift[0]), int(data.gift[1]), int(data.gift[2]), 0]
		2:
			return [MSBT_TANK, int(data.card[0]), int(data.card[1]), int(data.card[2]), 0]
		3:
			return [MSBT_SKIN3S, int(data.s3[0]), int(data.s3[3]), int(data.s3[4]), int(data.s3[2])]
	return [MSBT_SKIN2S, int(data.s2[0]), int(data.s2[3]), int(data.s2[4]), int(data.s2[2])]



func _v(spec: Array) -> Vector2:
	return Vector2(float(spec[0]), float(spec[1]))

func _paint() -> void :
	if not visible:
		return
	var at: Vector2 = _window(float(Atlas.FRAME[0]), float(Atlas.FRAME[1]))
	_fwords(TITLE, ARIAL_BOLD, 20.0, Color.WHITE, "c", at + Vector2(0, 17), float(Atlas.FRAME[0]), 1.5, 26.0)
	var data: Dictionary = row()
	var on: Array = buttons(data)
	for k in range(1, 5):
		_draw_card(at, data, k, bool(on[k - 1]))
	var spec: Array = Atlas.TEXTS["lblLimitTime"]
	var text: String = LIMIT.replace("@time@", limit_text(int(client.mystic_end) - _now()))
	_fwords(text, ARIAL_BOLD, float(spec[4]), Color(str(spec[5])), "l", at + _v(spec), float(spec[2]), 1.5)


func _draw_card(at: Vector2, data: Dictionary, k: int, enabled: bool) -> void :
	var btn: Array = Atlas.AT["btn_buy%d" % k]
	var mid: float = float(btn[0]) + float(btn[2]) / 2.0
	var box: Rect2 = Rect2((at + Vector2(roundf(mid - CARD_W / 2.0), CARD_Y)) * _f, Vector2(CARD_W, CARD_H) * _f)
	_round(box, CARD_FILL, 14.0, CARD_EDGE, 2.0)
	_fwords(str(HEADS[k - 1]), ARIAL_BOLD, 18.0, HEAD_INK, "c", at + Vector2(mid - CARD_W / 2.0, CARD_Y + 8.0), CARD_W, 1.5, 24.0)
	if data.is_empty():
		return
	var sale: Array = goods(data, k)
	var blank: bool = k >= 3 and int(sale[1]) <= 0
	var name: String = ""
	match k:
		1:
			name = gift_name(data)
			if int(data.gift[4]) > 0:
				_draw_tank(int(data.gift[4]), at, "avTank1")
			if int(data.gift[5]) > 0:
				_draw_skin(int(data.gift[5]), int(data.gift[4]), at, "avSkin1")
		2:
			name = item_name(int(data.card[0]))
			_draw_tank(int(client.mystic_tank), at, "avTank2")
		3, 4:
			var skin: Array = data.s3 if k == 3 else data.s2
			if blank:
				name = MXML_TEXT
			else:
				name = item_name(int(skin[0]))
				_draw_skin(int(skin[1]), int(skin[2]), at, "avSkin2" if k == 3 else "avSkin3")
	_label("lblName%d" % k, name, at)
	_label("lblOri%d" % k, MXML_TEXT if blank else ORI.replace("@num1@", str(int(sale[2]))), at)
	var line: Array = Atlas.LINES[k - 1]
	_fblit("ms_line", at + _v(line))
	if enabled:
		_fbutton("buy:%d" % k, "ms_buy", at + _v(btn))
		_label("lblAgio%d" % k, MXML_TEXT if blank else AGIO.replace("@num1@", str(int(sale[3]))), at)
	else:
		_fblit("ms_has", at + _v(btn))


func _label(key: String, text: String, at: Vector2) -> void :
	var spec: Array = Atlas.TEXTS[key]
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), Color(str(spec[5])), str(spec[7]), at + _v(spec), float(spec[2]), 1.0)


func _spot(at: Vector2, key: String) -> Array:
	var zoom: float = float(Atlas.ZOOM.get(key, 1.0))
	return [at + _v(Atlas.AT[key]) + Vector2(100, 100) * zoom, zoom]


func _draw_tank(tid: int, at: Vector2, key: String) -> void :
	var spot: Array = _spot(at, key)
	var c: Vector2 = spot[0]
	var zoom: float = spot[1]
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tid, 1, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), 0, 1)
	if TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, c * _f, zoom * _f, _time) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tid))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46) * zoom
		TankPreview.draw(self, art, (pod - Vector2(0, 52) * zoom) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * zoom * _f, 4, _time)


func _draw_skin(ext: int, tank: int, at: Vector2, key: String) -> void :
	var spot: Array = _spot(at, key)
	var c: Vector2 = spot[0]
	var zoom: float = spot[1]
	var face: String = GarageModel.face(pack.garage, ext)
	var folder: String = "l/t"
	if not face.is_empty() and pack.garage.get("big", []).has(face) and pack.picture("l/tb/%s.webp" % face) != null:
		folder = "l/tb"
	if TankPortrait.draw(self, pack, face, 0, c * _f, zoom * _f, _time, folder) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tank))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46) * zoom
		TankPreview.draw(self, art, (pod - Vector2(0, 52) * zoom) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * zoom * _f, 4, _time)



func _activate(id: String) -> void :
	if id == "cancel":
		close()
		return
	if not id.begins_with("buy:"):
		return
	var data: Dictionary = row()
	var k: int = int(id.substr(4))
	if data.is_empty() or k < 1 or k > 4 or not bool(buttons(data)[k - 1]):
		return
	var sale: Array = goods(data, k)
	if k >= 3 and int(sale[1]) <= 0:
		return
	if int(sale[4]) > 0 and not has_tank(int(sale[4])):
		say(TIP_651)
		return
	if int(sale[1]) <= 0:
		say(SOON)
		return
	buy_asked.emit(int(client.mystic_tank), int(sale[0]), int(sale[1]), int(sale[2]), int(sale[3]))

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
