extends "tank_convert.gd"











const ConfAtlas = preload("skin_convert_confirm_atlas.gd")

signal watch_all(skin: int)

const ASK_DIM: Color = Color(0, 0, 0, 0.4)
const RED_PKT: int = 7
const WAIT: float = 2.0
const TOAST_LIFE: float = 2.6

var _skin: int = 0
var _plan: Dictionary = {}
var _slots: Array = []
var _all_enough: bool = true
var _planned: bool = false
var _waiting: bool = false
var _got: bool = false
var _wait_until: float = 0.0

func _setup() -> void :
	super ()
	_use(ConfAtlas.FILE, ConfAtlas.R)


func open_skin(skin: int, tank: int) -> void :
	_skin = skin
	_tank = tank
	_state = str(client.state)
	_reward.reset()
	_close_sheet()
	_tip = []
	_flies = []
	RewardFly.reset(self)
	_note = ""
	_toast = ""
	_hover = ""
	_press = ""
	_waiting = false
	_got = false
	_planned = false
	_plan = {}
	_slots = []
	_all_enough = true
	_stale = true
	_sig = []
	mouse_filter = Control.MOUSE_FILTER_STOP
	pack.load_fair()
	pack.load_bag()
	pack.load_garage()
	pack.load_events()
	if not client.bag_loaded:
		client.request_bags()
	visible = true
	_fetch()

func skin() -> int:
	return _skin

func plan() -> Dictionary:
	return _plan

func slots() -> Array:
	return _slots

func all_enough() -> bool:
	return _all_enough

func waiting() -> bool:
	return _waiting


func covering() -> bool:
	return visible and ( not _waiting or not _sheet_id.is_empty())

func chat_busy() -> bool:
	return covering()


func _known(id: int) -> bool:
	var key: String = str(id)
	return (pack.bag.get("items", {}).has(key) or pack.bag.get("more", {}).has(key) or pack.fair.get("items", {}).has(key)
		or pack.events.get("items", {}).has(key) or pack.garage.get("skin_items", {}).has(key))


func _slot_of(id: int, need: int) -> Dictionary:
	if need <= 0:
		return {"show": false}
	var have: int = _have(id)
	var short: bool = have < need
	if short:
		_all_enough = false
	var known: bool = _known(id)
	return {"show": true, "gift": _item(id, need) if known else {}, "text": "%d/%d" % [have, need], 
		"color": SHORT_RED if short and known else Color.WHITE}


func _plan_cost() -> void :
	_planned = true
	_plan = {}
	_slots = []
	_all_enough = true
	_recount()
	for rec: Dictionary in _by_result.get(str(_skin), []):
		if int(rec.type) != RED_PKT:
			_plan = rec
			break
	if _plan.is_empty():
		return
	var items: Array = _plan.items
	if int(_plan.price) > 0:
		var ct: int = int(_plan.ct)
		var ok: bool = (ct == 1 and _cash("m_iCash") >= int(_plan.price)) or (ct == 2 and _cash("m_iGolden") >= int(_plan.price))
		if not ok:
			_all_enough = false
		_slots.append({"show": true, "cell": str(ConfAtlas.COIN_OF.get(str(ct), "")), "text": str(int(_plan.price)), 
			"color": Color.WHITE if ok else SHORT_RED})
		_slots.append(_slot_of(int(items[0][0]), int(items[0][1])))
	else:
		_slots.append(_slot_of(int(items[0][0]), int(items[0][1])))
		_slots.append(_slot_of(int(items[1][0]), int(items[1][1])))


func _said() -> String:
	return _toast if not _toast.is_empty() and _time - _toast_at <= TOAST_LIFE else ""

func _tick(_delta: float) -> void :
	_tick_award()
	if not visible:
		return
	if str(client.state) != _state:
		close("")
		return
	if _waiting:
		var busy: bool = not _sheet_id.is_empty()
		mouse_filter = Control.MOUSE_FILTER_STOP if busy else Control.MOUSE_FILTER_IGNORE
		if busy or not _flies.is_empty():
			return
		if _got:
			close(_said())
		elif _time >= _wait_until:
			var said: String = _said()
			close(said if not said.is_empty() else T_SILENT)
		return
	if _raw.is_empty() and _loading.is_empty() and _time - _fetch_at >= RETRY:
		_fetch()
	if not _note.is_empty() and _time >= _note_at:
		say(_note)
		_note = ""
	if _stale and not _raw.is_empty() and not pack.bag.is_empty() and not pack.garage.is_empty() and client.bag_loaded:
		_build()
		if not _planned or not _plan.is_empty():
			_plan_cost()

func _show_award(info: Dictionary) -> void :
	if _waiting and not BagModel.award_lines(info, pack.bag).is_empty():
		_got = true
	super (info)

func _activate(id: String) -> void :
	if not _sheet_id.is_empty():
		_sheet_activate(id)
		return
	if _waiting:
		return
	match id:
		"close":
			close("")
		"ok":
			_confirm_do()
		"link":

			var skin_id: int = _skin
			close("")
			watch_all.emit(skin_id)


func _confirm_do() -> void :
	if _plan.is_empty() or _time - _sent_at < 1.0:
		return
	if not _all_enough:
		say(str(ConfAtlas.WORDS["CONTROL_TEXT305"]))
		return
	var words: Dictionary = Atlas.WORDS
	if _tank != 0 and not _has_tank(_tank):
		var name_of: String = str(pack.lobby.get("tanks", {}).get(str(_tank), ""))
		if name_of.is_empty():
			return
		say(str(words["CONTROL_TEXT461"]).replace("@name@", name_of).replace("@item@", GarageModel.cap(str(_describe(_skin, 1).name))))
		return
	if _has_skin(_skin):
		say(str(words["TIP_285"]))
		return
	if not client.convert_item(int(_plan.id), 1):
		say(T_UNSENT)
		return
	_sent_at = _time
	_waiting = true
	_got = false
	_wait_until = _time + WAIT
	_tip = []
	_hover = ""
	_press = ""

func _unhandled_key_input(event: InputEvent) -> void :
	if _waiting:
		return
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_ESCAPE:
			close("")
		KEY_ENTER, KEY_KP_ENTER:
			pass
		_:
			return
	get_viewport().set_input_as_handled()

func _paint() -> void :
	_tip = []
	_placed = []
	_clip_ops = []
	_hole_px = Rect2()
	_list_rect = Rect2()
	var box: Vector2 = Vector2(float(ConfAtlas.SIZE[0]), float(ConfAtlas.SIZE[1]))
	var o: Vector2 = _stage() + Vector2(floorf((1000.0 - box.x) / 2.0), floorf((600.0 - box.y) / 2.0))
	if not _waiting:
		var full: Rect2 = Rect2(Vector2.ZERO, size)
		draw_rect(full, ASK_DIM)
		_hit("shade", full, false)
		_fblit("scc_frame", o)
		_hit("panel", Rect2(o * _f, box * _f), false)
		var spots: Array = [ConfAtlas.NODES["frmPrice"], ConfAtlas.NODES["item1"]]
		for k: int in mini(_slots.size(), spots.size()):
			_draw_slot(o + _v(spots[k]), _slots[k])
		_draw_link(o)
		_fbutton("close", "scc_close", o + _v(ConfAtlas.NODES["btnCancel"]))
		_fbutton("ok", "scc_ok", o + _v(ConfAtlas.NODES["btnConfirm"]))
	if _sheet_id == "award":
		_draw_award()
	_draw_flies()
	_clipper.visible = _sheet_id != "award"
	_clipper.queue_redraw()
	if _qty.visible:
		_qty.visible = false
		_qty.release_focus()


func _draw_slot(at: Vector2, slot: Dictionary) -> void :
	if not bool(slot.get("show", false)):
		return
	var spec: Dictionary = ConfAtlas.TILE
	_fblit("fa_cv_tile", at + _v(spec["bg"]))
	var img: Array = spec["img"]
	var spot: Vector2 = at + _v(img)
	if slot.has("cell"):
		if not str(slot.cell).is_empty():
			_fblit(str(slot.cell), spot)
	elif not (slot.gift as Dictionary).is_empty():
		_corner_fit(_gift_art(slot.gift), spot, Vector2(float(img[2]), float(img[3])))
	var num: Array = spec["num"]
	_fwords(str(slot.text), BOLD, 12.0, slot.color, "c", at + _v(num), float(num[2]), 1.0, 0.0, true, 
		Color(str(spec["rim"]), float(spec["rim_alpha"])))


func _corner_fit(picture: Texture2D, at: Vector2, box: Vector2) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(box.x / picture.get_width(), box.y / picture.get_height())
	draw_texture_rect(picture, Rect2(at * _f, Vector2(picture.get_size()) * k * _f), false)


func _draw_link(o: Vector2) -> void :
	var spec: Dictionary = ConfAtlas.LINK
	var color: Color = Color(str(spec["color"]))
	var rim: Color = Color(str(spec["rim"]))
	var px: float = float(spec["px"])
	var top: float = float(spec["y"])
	var wide: float = _fwords(str(ConfAtlas.WORDS["LINK"]), BOLD, px, color, "c", o + Vector2(0, top), float(ConfAtlas.SIZE[0]), 1.0, 0.0, false, rim)
	var mid: float = float(spec["x"])
	var line_y: float = top + 2.0 + px + 1.0
	var a: Vector2 = o + Vector2(mid - wide / 2.0, line_y)
	var b: Vector2 = o + Vector2(mid + wide / 2.0, line_y)
	draw_line(a * _f, b * _f, rim, 3.0 * _f)
	draw_line(a * _f, b * _f, color, maxf(1.0, _f))
	_hit("link", Rect2((o + Vector2(mid - (wide + 5.0) / 2.0, top)) * _f, Vector2(wide + 5.0, px + 6.0) * _f), false)
