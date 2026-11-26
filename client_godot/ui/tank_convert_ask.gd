extends "tank_convert.gd"










const AskAtlas = preload("tank_convert_ask_atlas.gd")

signal converted(tank: int)

const ASK_DIM: Color = Color(0, 0, 0, 0.4)
const T_ASK_SILENT: String = "Chưa đổi được: thiếu mảnh hoặc đã có tank này."
const WAIT: float = 2.0
const TOAST_LIFE: float = 2.6

var _ask: Dictionary = {}
var _waiting: bool = false
var _got: bool = false
var _wait_until: float = 0.0

func _setup() -> void :
	super ()
	_use(AskAtlas.FILE, AskAtlas.R)


func open(tank: int) -> void :
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
	_stale = true
	_sig = []
	_ask = {}
	mouse_filter = Control.MOUSE_FILTER_STOP
	pack.load_fair()
	pack.load_bag()
	pack.load_garage()
	pack.load_events()
	if not client.bag_loaded:
		client.request_bags()
	visible = true

func ask() -> Dictionary:
	return _ask

func waiting() -> bool:
	return _waiting


func covering() -> bool:
	return visible and ( not _waiting or not _sheet_id.is_empty())

func chat_busy() -> bool:
	return covering()


func _build_ask() -> void :
	_stale = false
	_ask = {}
	var row: Array = AskAtlas.CONVERT_OF.get(str(_tank), [])
	if row.size() >= 4:
		_ask = {"id": int(row[0]), "item": int(row[1]), "need": int(row[2]), "result": int(row[3]), 
			"tile": _item(int(row[1]), int(row[2])), "gift": _describe(int(row[3]), 1)}
	_recount()


func _ask_ready() -> bool:
	return not _ask.is_empty() and _have(int(_ask.item)) >= int(_ask.need)


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
			close(said if not said.is_empty() else T_ASK_SILENT)
		return
	if not _note.is_empty() and _time >= _note_at:
		say(_note)
		_note = ""
	if _stale and not pack.bag.is_empty() and not pack.garage.is_empty():
		_sig = [client.bag_rev]
		_build_ask()
	elif [client.bag_rev] != _sig:
		_sig = [client.bag_rev]
		_recount()

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
		"ask_do":
			_ask_do()


func _ask_do() -> void :
	if not _ask_ready() or _time - _sent_at < 1.0:
		return
	if not client.convert_item(int(_ask.id), 1):
		say(T_UNSENT)
		return
	_sent_at = _time
	_waiting = true
	_got = false
	_wait_until = _time + WAIT
	_tip = []
	_hover = ""
	_press = ""
	converted.emit(_tank)

func _unhandled_key_input(event: InputEvent) -> void :
	if _waiting:
		return
	super (event)

func _paint() -> void :
	_tip = []
	_placed = []
	_clip_ops = []
	var box: Vector2 = Vector2(float(AskAtlas.SIZE[0]), float(AskAtlas.SIZE[1]))

	var o: Vector2 = _stage() + Vector2(floorf((1000.0 - box.x) / 2.0), floorf((600.0 - box.y) / 2.0))
	var lst: Array = AskAtlas.NODES["lstConvert"]
	var hole: Rect2 = Rect2(o + _v(lst), Vector2(float(lst[2]), float(lst[3])))
	_list_rect = Rect2(hole.position * _f, hole.size * _f)
	_hole_px = _snap(_list_rect)
	if _clipper.position != _hole_px.position or _clipper.size != _hole_px.size:
		_clipper.position = _hole_px.position
		_clipper.size = _hole_px.size
	if not _waiting:
		var full: Rect2 = Rect2(Vector2.ZERO, size)
		for strip: Rect2 in _strips(full, _hole_px):
			draw_rect(strip, ASK_DIM)
		_crect(full, ASK_DIM)
		_hit("shade", full, false)
		_draw_ask_frame(o)
		_hit("panel", Rect2(o * _f, box * _f), false)
		if not _ask.is_empty():
			_draw_ask_row(hole.position)
		_fbutton("close", "tca_close", o + _v(AskAtlas.NODES["btnClose"]))
	if _sheet_id == "award":
		_draw_award()
	elif not _waiting:
		_draw_tip()
	_draw_flies()
	_clipper.visible = _sheet_id != "award"
	_clipper.queue_redraw()
	if _qty.visible:
		_qty.visible = false
		_qty.release_focus()


func _draw_ask_frame(o: Vector2) -> void :
	var cell: Array = _cells.get("tca_frame", [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var panel: Rect2 = Rect2(o * _f, Vector2(float(region[2]), float(region[3])) * _f)
	var origin: Vector2 = Vector2(float(region[0]), float(region[1]))
	for strip: Rect2 in _strips(panel, _hole_px):
		draw_texture_rect_region(cell[0], strip, Rect2(origin + (strip.position - panel.position) / _f, strip.size / _f))
	_clip_ops.append([0, cell[0], panel, Rect2(origin, Vector2(float(region[2]), float(region[3]))), Color.WHITE])


func _draw_ask_row(at: Vector2) -> void :
	_cblit("fa_cv_act", at)
	var have: int = _have(int(_ask.item))
	_draw_tile(at + _v(AtlasC.ACT_CELL["two"][0]), _ask.tile, "%d/%d" % [have, int(_ask.need)], Color.WHITE, false, "")
	_draw_reward(at + _v(AtlasC.ACT_CELL["reward"]), _ask.gift)
	var spot: Vector2 = at + _v(AtlasC.ACT_CELL["button"])
	if _ask_ready():
		_chit("ask_do", _cblit("fa_cv_btn", spot, 0.0, 0.0, _glow("ask_do")))
	else:
		_cblit("fa_cv_btn_off", spot)
