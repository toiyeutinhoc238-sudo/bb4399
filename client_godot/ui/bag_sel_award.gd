extends "flash_screen.gd"










const Atlas = preload("sel_award_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")

signal closed(note: String)

const DIM: Color = Color(0, 0, 0, 0.4)
const TITLE_INK: Color = Color("eefcff")
const TITLE_RIM: Color = Color("3491af")
const GET_INK: Color = Color("fffef2")
const GET_RIM: Color = Color("9a3a10")
const CNT_RIM: Color = Color("005391")
const OFFLINE: String = "Chưa thực hiện được lúc này."
const EMPTY_TIP: String = "Không còn vật phẩm này trong túi."

var _item: int = 0
var _pick: int = 0
var _count: int = 1
var _state: String = ""
var _choices: Array = []
var _tip: Array = []
var _ctip: CTip = CTip.new()

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)


func open(item_id: int) -> void :
	_item = item_id
	var catalog_choices: Dictionary = pack.bag.get("choices", Atlas.CHOICES)
	_choices = catalog_choices.get(str(item_id), Atlas.CHOICES.get(str(item_id), []))
	_pick = 0
	_count = 1
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

func box_id() -> int:
	return _item

func picked() -> int:
	return _pick

func count() -> int:
	return _count


func have() -> int:
	var total: int = 0
	for item: Dictionary in client.bags.get(2, []):
		if int(item.get("m_templateId", 0)) == _item:
			total += int(item.get("m_count", 0))
	return total


func slot() -> int:
	var best: int = -1
	for item: Dictionary in client.bags.get(2, []):
		var at: int = int(item.get("m_slotNo", -1))
		if int(item.get("m_templateId", 0)) == _item and at >= 0 and (best < 0 or at < best):
			best = at
	return best

func _tick(_delta: float) -> void :
	if visible and client.state != _state:
		close("")



func _activate(id: String) -> void :
	match id:
		"close":
			close("")
		"add":
			if _count < have():
				_count += 1
		"reduce":
			if _count > 1:
				_count -= 1
		"max":
			_count = have()
		"min":
			_count = 1
		"get":
			_claim()
		_:
			if id.begins_with("item"):
				_pick = clampi(int(id.substr(4)), 0, 3)


func _claim() -> void :
	var at: int = slot()
	if at < 0:
		close(EMPTY_TIP)
		return
	close("" if client.sel_award_use(at, _count, _pick + 1) else OFFLINE)

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()



func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))


func _info(choice: Array) -> Array:
	var id: int = int(choice[0])
	var row: Array = pack.bag.get("items", {}).get(str(id), [])
	var fallback: String = str(choice[1]) if choice.size() > 1 and not str(choice[1]).is_empty() else "Vật phẩm %d" % id
	var title: String = BagModel._named(row, fallback)
	var desc: String = BagModel.clean(str(row[1])) if row.size() > 1 else ""
	var quality: int = int(row[3]) if row.size() > 3 else (int(choice[2]) if choice.size() > 2 else 0)
	var key: String = str(row[2]) if row.size() > 2 else ""
	var folder: String = "l/av/" if row.size() > 5 and int(row[5]) == 4 else "l/it/"
	return [title, desc, quality, folder + key + ".webp" if not key.is_empty() else ""]

func _paint() -> void :
	_tip = []
	var frame: Vector2 = _v(Atlas.FRAME)
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(frame.x, frame.y)
	_hit("panel", Rect2(at * _f, frame * _f), false)
	_fblit("sa_frame", at + _v(Atlas.BODY))
	_fwords(str(Atlas.TITLE[0]), BOLD, 18.0, TITLE_INK, "c", at + Vector2(0, 2), frame.x, 2.0, 29.0, true, TITLE_RIM)
	var layout: Dictionary = Atlas.AT
	var cells: Array = layout["items"]
	for i: int in cells.size():
		if i < _choices.size():
			_draw_item(i, at + _v(cells[i]), _choices[i])
	_fblit("sa_count_bg", at + _v(layout["count_bg"]))
	_fwords(str(_count), BOLD, 20.0, Color.WHITE, "c", at + Vector2(150, 161), 100.0, 0.0, 28.0)
	_fbutton("min", "sa_min", at + _v(layout["min"]))
	_fbutton("reduce", "sa_reduce", at + _v(layout["reduce"]))
	_fbutton("add", "sa_add", at + _v(layout["add"]))
	_fbutton("max", "sa_max", at + _v(layout["max"]))
	var button: Vector2 = at + _v(layout["get"])
	_fbutton("get", "sa_get", button)
	_fwords(str(Atlas.TITLE[1]), BOLD, 16.0, GET_INK, "c", button, _cell_size("sa_get").x, 2.0, _cell_size("sa_get").y, true, GET_RIM)
	_fbutton("close", "sa_close", at + _v(layout["close"]))
	_draw_tip()


func _draw_item(index: int, at: Vector2, choice: Array) -> void :
	var id: String = "item%d" % index
	var rect: Rect2 = _fbutton(id, "sa_grid", at)
	var info: Array = _info(choice)
	var picture: Texture2D = pack.picture(str(info[3])) if not str(info[3]).is_empty() else null
	if picture != null:
		var box: Vector2 = _cell_size("sa_grid")
		var extent: Vector2 = picture.get_size()
		var zoom: float = minf(box.x / maxf(extent.x, 1.0), box.y / maxf(extent.y, 1.0))
		extent *= zoom
		draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false, _glow(id))
	_fwords("1", BOLD, 14.0, Color.WHITE, "r", at + Vector2(-78.5, 56), 150.0, 2.0, 0.0, false, CNT_RIM)
	if _pick == index:
		_fblit("sa_select", at + Vector2(39, 39))
	if _tip_ok() and _hover == id and rect.has_point(get_local_mouse_position()):
		var rec: Dictionary = _gift_rec({"id": int(choice[0]), "name": str(info[0]), "desc": str(info[1]), "quality": int(info[2]), "art": str(info[3])})
		_tip = [rect, "", "", Color.WHITE, rec] if not rec.is_empty() else [rect, GarageModel.cap(str(info[0])), str(info[1]), BagModel.tint(int(info[2]), Color.WHITE)]



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
