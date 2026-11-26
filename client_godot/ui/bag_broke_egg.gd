extends "flash_screen.gd"









const Atlas = preload("broke_egg_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")

signal closed(note: String)
signal quick_buy_asked(tid: int)

const DIM: Color = Color(0, 0, 0, 0.4)
const NAME_GLOW: Color = Color(0.2, 0.2, 0.0, 0.8)
const SHORT: Color = Color("ff0000")
const OFFLINE: String = "Chưa thực hiện được lúc này."

var _cont: int = 2
var _slot: int = -1
var _item: int = 0
var _hammer: int = 0
var _state: String = ""
var _tip: Array = []
var _ctip: CTip = CTip.new()

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)


func open(cont: int, slot: int, item_id: int, hammer_id: int) -> void :
	_cont = cont
	_slot = slot
	_item = item_id
	_hammer = hammer_id
	_state = client.state
	_toast = ""
	_hover = ""
	_press = ""
	_tip = []
	visible = true

func close(note: String = "") -> void :
	if not visible:
		return
	visible = false
	_tip = []
	closed.emit(note)

func chat_busy() -> bool:
	return visible

func hammer_id() -> int:
	return _hammer


func hammers() -> int:
	var total: int = 0
	for inst: Dictionary in client.bags.get(2, []):
		if int(inst.get("m_templateId", 0)) == _hammer:
			total += int(inst.get("m_count", 0))
	return total


func egg() -> Dictionary:
	var inst: Dictionary = client.bag_item(_cont, _slot)
	return inst if int(inst.get("m_templateId", 0)) == _item and int(inst.get("m_count", 0)) > 0 else {}

func _tick(_delta: float) -> void :
	if not visible:
		return
	if client.state != _state:
		close("")
	elif egg().is_empty():
		close("")



func _activate(id: String) -> void :
	match id:
		"close":
			close("")
		"buy":
			quick_buy_asked.emit(_hammer)
		"ok":
			_confirm()


func _confirm() -> void :
	var have: int = hammers()
	if have < 1:
		return
	var inst: Dictionary = egg()
	if inst.is_empty():
		return
	if not client.use_item(_cont, _slot, mini(have, int(inst.get("m_count", 1)))):
		_toast = OFFLINE

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()



func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))

func _paint() -> void :
	_tip = []
	var frame: Vector2 = _v(Atlas.FRAME)
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(frame.x, frame.y)
	_hit("panel", Rect2(at * _f, frame * _f), false)
	_fblit("be_frame", at + _v(Atlas.BODY))
	var have: int = hammers()
	_draw_cell(at + _v(Atlas.AT["cell"]), have)
	if have > 0:
		_fbutton("ok", "be_ok", at + _v(Atlas.AT["ok"]))
	else:
		_fblit("be_ok_off", at + _v(Atlas.AT["ok"]))
		_fbutton("buy", "be_buy", at + _v(Atlas.AT["buy"]))
	_fbutton("close", "be_close", at + _v(Atlas.AT["close"]))
	_draw_tip()
	_draw_toast()



func _draw_cell(cell: Vector2, have: int) -> void :
	var row: Array = pack.bag.get("items", {}).get(str(_hammer), [])
	var quality: int = int(row[3]) if row.size() > 3 else 1
	var nodes: Dictionary = Atlas.CELL_NODES
	_fblit("be_q_" + str(Atlas.QUALITY[clampi(quality - 1, 0, Atlas.QUALITY.size() - 1)]), cell + _v(nodes["imgQuality"]))
	var box: Array = nodes["imgItem"]
	var rect: Rect2 = Rect2((cell + _v(box)) * _f, Vector2(float(box[2]), float(box[3])) * _f)
	var key: String = str(row[2]) if row.size() > 2 else ""
	var picture: Texture2D = pack.picture("l/it/%s.webp" % key) if not key.is_empty() else null
	if picture != null:
		draw_texture_rect(picture, rect, false)
	var title: String = BagModel._named(row, "Vật phẩm %d" % _hammer)
	var label: Array = Atlas.CELL_TEXTS["lblItemName"]
	_name_box(title, float(label[3]), Color(str(label[4])), cell + _v(label), float(label[2]))
	var num: Array = Atlas.CELL_TEXTS["lblNum"]
	_fwords("%d/1" % have, BOLD, float(num[3]), SHORT if have < 1 else Color(str(num[4])), "c", cell + _v(num), float(num[2]))
	_hit("hammer", rect, false)
	if _tip_ok() and _hover == "hammer" and rect.has_point(get_local_mouse_position()):
		var rec: Dictionary = _gift_rec({"id": _hammer, "name": title, "quality": quality})
		_tip = [rect, "", "", Color.WHITE, rec] if not rec.is_empty() else [rect, GarageModel.cap(title), BagModel.clean(str(row[1])) if row.size() > 1 else "", BagModel.tint(quality, Color.WHITE)]


func _name_box(text: String, px: float, color: Color, at: Vector2, wide: float) -> void :
	var font_size: int = maxi(6, roundi(px * _f))
	var high: float = ARIAL_BOLD.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, font_size).y / _f
	var origin: Vector2 = Vector2(at.x, at.y - 2.0 - high) * _f + Vector2(0, ARIAL_BOLD.get_ascent(font_size))
	draw_multiline_string_outline(ARIAL_BOLD, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, font_size, -1, maxi(1, roundi(_f)), NAME_GLOW)
	draw_multiline_string(ARIAL_BOLD, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, font_size, -1, color)



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
	_fwords(str(_tip[1]), BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 10)
