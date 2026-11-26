extends "master_task_draw.gd"






const Atlas = preload("master_task_atlas.gd")
const Arena = preload("arena_atlas.gd")

signal closed

const DIM: Color = Color(0, 0, 0, 0.4)
const NO_BENEFIT: String = "Không có xu thu ích"
const RANGE: String = "Khi xuất sư, nếu Điểm Tình đạt @num1@ - @num2@ được nhận"
const ABOVE: String = "Điểm Tình cao hơn @num1@ có thể nhận"
const GAP: float = 6.0
const LINE: float = 15.0
const LOW: int = 4500
const HIGH: int = 7000

var _state: String = ""
var _amity: int = 0
var _scroll: float = 0.0
var _list_rect: Rect2 = Rect2()
var _bar: Array = []
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_value: float = 0.0
var benefit: int = 0

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use_task()
	_use(Arena.FILE, {"public_button_close": Arena.R["public_button_close"]})


func open(amity: int, have_master: bool) -> void :
	_state = "" if have_master else "master"
	_amity = maxi(0, amity)
	_scroll = 0.0
	_grab = false
	_toast = ""
	_hover = ""
	_press = ""
	_item_tip = []
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

func state() -> String:
	return _state

func amity() -> int:
	return _amity


static func reward_type(value: int) -> int:
	if value < LOW:
		return 1
	if value < HIGH:
		return 2
	return 3


static func reward_text(kind: int) -> String:
	match kind:
		1:
			return RANGE.replace("@num1@", "0").replace("@num2@", str(LOW))
		2:
			return RANGE.replace("@num1@", str(LOW)).replace("@num2@", str(HIGH))
	return ABOVE.replace("@num1@", str(HIGH))


func present_id(kind: int) -> int:
	return (2006103 if _state == "" else 2006100) + kind - 1


func rows() -> Array:
	var out: Array = []
	for kind: int in [1, 2, 3]:
		out.append({"title": reward_text(kind), "tick": _amity > 0 and reward_type(_amity) == kind, "award": true, 
			"tiles": present_tiles(present_id(kind))})
	return out

func _quest() -> Array:
	return Atlas.QUEST["master" if _state == "master" else ""]

func _content() -> float:
	var n: int = rows().size()
	return float(Atlas.TASK[1]) * n + GAP * maxi(0, n - 1)

func max_scroll() -> float:
	return maxf(0.0, _content() - float(_quest()[3]))

func scroll() -> float:
	return _scroll

func _set_scroll(value: float) -> void :
	_scroll = clampf(roundf(value), 0.0, max_scroll())



func _paint() -> void :
	_item_tip = []
	_bar = []
	_clip = Rect2()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var win: Vector2 = _v(Atlas.WIN)
	var o: Vector2 = _centre(win.x, win.y)
	_hit("panel", Rect2(o * _f, win * _f), false)
	var at: Dictionary = Atlas.WIN_AT
	_fblit("mt_win", o + _v(at["win"]))
	if _state == "master":
		_fblit("mt_box_master", o + _v(at["box_master"]))
		_fblit("mt_get_bk", o + _v(at["get_bk"]))
		_fbutton("take", "mt_take", o + _v(at["take"]))
		_benefit(o)
	else:
		_fblit("mt_box", o + _v(at["box"]))
	_draw_list(o)
	_fbutton("close", "public_button_close", o + _v(at["close"]))
	_draw_item_tip()
	_draw_toast()


func _benefit(o: Vector2) -> void :
	var spec: Array = Atlas.BENEFIT
	var at: Vector2 = o + _v(spec)
	var text: String = str(benefit)
	_fwords(text, ARIAL_BOLD, float(spec[4]), Color("017ac3"), "l", at + Vector2(2.83, 2.83), 200.0, 0.0, 0.0, false, Color(0, 0, 0, 0))
	_fwords(text, ARIAL_BOLD, float(spec[4]), Color(str(spec[5])), "l", at, 200.0, 0.0, 0.0, false, Color(0, 0, 0, 0))


func _draw_list(o: Vector2) -> void :
	var spot: Array = _quest()
	var at: Vector2 = o + _v(spot)
	var wide: float = float(spot[2])
	var high: float = float(spot[3])
	var most: float = max_scroll()
	_scroll = clampf(_scroll, 0.0, most)
	_list_rect = Rect2(at * _f, Vector2(wide, high) * _f)
	_clip = Rect2(at * _f, Vector2(wide - (BAR if most > 0.0 else 0.0), high) * _f)
	var all: Array = rows()
	var y: float = - _scroll
	for row: Dictionary in all:
		if y + float(Atlas.TASK[1]) > 0.0 and y < high:
			_draw_task(at + Vector2(0, y), row, true)
		y += float(Atlas.TASK[1]) + GAP
	_clip = Rect2()
	if most > 0.0:
		_bar = _draw_bar("bar", at + Vector2(wide - BAR, 0), high - 2.0 * BAR, _scroll, most, high)



func _activate(id: String) -> void :
	match id:
		"close":
			close()
		"take":

			say(NO_BENEFIT)
		"bar:up":
			_set_scroll(_scroll - LINE)
		"bar:down":
			_set_scroll(_scroll + LINE)
		"bar:pgup":
			_set_scroll(_scroll - float(_quest()[3]))
		"bar:pgdn":
			_set_scroll(_scroll + float(_quest()[3]))

func _wheel(step: int, at: Vector2) -> void :
	if _list_rect.has_point(at):
		_set_scroll(_scroll + LINE * step)

func _drag(moved: Vector2, from: Vector2) -> void :
	if not _grab and _list_rect.has_point(from):
		_set_scroll(_scroll - moved.y / _f)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _hit_at(event.position) == "slide:bar" and not _bar.is_empty():
				_grab = true
				_grab_at = event.position
				_grab_value = _scroll
		else:
			_grab = false
	elif event is InputEventMouseMotion and _grab:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_grab = false
		else:
			var step: float = maxf(0.001, (float(_bar[0]) - float(_bar[1])) / float(_bar[2]))
			_set_scroll(_grab_value + (event.position.y - _grab_at.y) / _f / step)
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
			_set_scroll(_scroll - LINE)
		KEY_DOWN:
			_set_scroll(_scroll + LINE)
		KEY_PAGEUP:
			_set_scroll(_scroll - float(_quest()[3]))
		KEY_PAGEDOWN:
			_set_scroll(_scroll + float(_quest()[3]))
	get_viewport().set_input_as_handled()
