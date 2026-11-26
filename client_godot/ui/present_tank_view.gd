extends "flash_screen.gd"







const Arena = preload("arena_atlas.gd")
const ShopTry = preload("shop_try.gd")
const Atlas = preload("present_tank_atlas.gd")
const GarageModel = preload("garage_model.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")

const PREV: String = "roll:prev"
const NEXT: String = "roll:next"

var tanks: Array = []
var index: int = 0
var _tip: Array = []
var _ctip: CTip = CTip.new()

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Arena.FILE, Arena.R)
	ShopTry.use(self)
	_use(Atlas.FILE, Atlas.R)

func open(list: Array) -> void :
	tanks = []
	for id: Variant in list:
		tanks.append(int(id))
	index = 0
	_tip = []
	if pack != null:
		pack.load_garage()
	visible = not tanks.is_empty()
	queue_redraw()

func close() -> void :
	visible = false
	_tip = []


func current() -> Array:
	if tanks.is_empty() or pack == null:
		return []
	var tank: int = int(tanks[clampi(index, 0, tanks.size() - 1)])
	if not pack.garage.get("tanks", {}).has(str(tank)):
		return []
	return [tank, GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank, 1, {})]


func roll(step: int) -> void :
	if tanks.is_empty():
		return
	index = posmod(index + step, tanks.size())


func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false)

func _paint() -> void :
	if tanks.is_empty():
		return
	var name: String = ""
	var tank: int = int(tanks[clampi(index, 0, tanks.size() - 1)])
	name = str(pack.lobby.get("tanks", {}).get(str(tank), ""))

	var at: Vector2 = _centre(float(Atlas.VIEW[0]), float(Atlas.VIEW[1]))
	_tip = ShopTry.draw(self, {"name": name}, current(), false, _draw_tip0)
	for row: Array in [[PREV, "pt_prev", "left", Atlas.TEXT.prev], [NEXT, "pt_next", "right", Atlas.TEXT.next]]:
		var spot: Array = Atlas.ROLL[row[2]]
		var rect: Rect2 = _fbutton(str(row[0]), str(row[1]), at + Vector2(float(spot[0]), float(spot[1])))
		if _tip.is_empty() and _tip_ok() and _hover == str(row[0]) and _press.is_empty():
			_tip = [rect, str(row[3]), "", Color.WHITE]
	_draw_tip()


func _draw_tip0(at: Vector2) -> void :
	var spec: Array = Atlas.TIP0
	var px: float = float(spec[2])
	var wide: float = 300.0
	_fwords(str(Atlas.TEXT.tip0), ARIAL_BOLD, px, Color(str(spec[3])), "r", at + Vector2(float(spec[0]) - wide, float(spec[1])), wide, 
		1.5, 0.0, true, Color(Color(str(spec[4])), 0.8))


func _draw_tip() -> void :
	if FlashTip.show(self, _tip, _ctip):
		return
	var anchor: Rect2 = _tip[0]
	var body: String = str(_tip[2])
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	if body.is_empty():
		wide = minf(230.0, ARIAL_BOLD.get_string_size(str(_tip[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(13.0 * _f))).x / _f + 24.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), ARIAL_BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, ARIAL, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 8)

func _activate(id: String) -> void :
	match id:
		"cancel", ShopTry.OK:
			close()
		PREV:
			roll(-1)
		NEXT:
			roll(1)

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
