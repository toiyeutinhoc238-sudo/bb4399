extends "flash_screen.gd"







const FILE: String = "res://assets/ui/hall/scroll_bulletin.png"
const AT: Vector2 = Vector2(182, 8)
const LANE: Rect2 = Rect2(18, 0, 600, 32)
const HIGH: float = 48.0
const SPEED: float = 24.0
const PX: float = 16.0
const INK: Color = Color("ffff00")
const RIM: Color = Color(22.0 / 255.0, 0, 0, 0.8)
const EDGE: float = 2.0
const TAIL: String = "    "
const SHOW_IN: Array = ["lobby", "hall", "room", "battle"]


class Lane extends Control:
	var paint: Callable
	func _draw() -> void :
		paint.call(self)

var queue: Array = []
var text: String = ""
var offset: float = 0.0
var _lane: Lane

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_use(FILE, {"sb_bk": [0, 0, 636, 48]})
	_lane = Lane.new()
	_lane.clip_contents = true
	_lane.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lane.paint = _paint_lane
	add_child(_lane)
	if client != null:
		client.bulletin_rolled.connect(append)
		client.changed.connect(_follow)


func _follow() -> void :
	if client == null or client.state not in SHOW_IN:
		queue.clear()
		text = ""
		visible = false


func append(value: String) -> void :
	if value.strip_edges().is_empty() or client == null or client.state not in SHOW_IN:
		return
	queue.append(value + TAIL)
	if text.is_empty():
		visible = true
		_start()


func _start() -> void :
	if queue.is_empty():
		return
	text = str(queue.pop_front())
	offset = - LANE.size.x


func text_width() -> float:
	var font: Font = _face(ARIAL)
	var size_px: int = maxi(6, roundi(PX * _f))
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x / _f


func hidden_now() -> bool:
	return client != null and not client.pair_scene.is_empty()


func _tick(delta: float) -> void :
	if text.is_empty():
		visible = false
		return
	offset += SPEED * delta
	if offset > text_width():
		text = ""
		if queue.is_empty():
			visible = false
		else:
			_start()

func _paint() -> void :
	if text.is_empty() or hidden_now():
		_lane.visible = false
		return
	var o: Vector2 = _stage() + AT
	_fblit("sb_bk", o)
	_lane.visible = true
	_lane.position = (o + LANE.position) * _f
	_lane.size = LANE.size * _f
	_lane.queue_redraw()

func _paint_lane(item: Control) -> void :
	if text.is_empty():
		return
	var font: Font = _face(ARIAL)
	var size_px: int = maxi(6, roundi(PX * _f))
	var at: Vector2 = Vector2( - offset * _f, HIGH / 2.0 * _f + (font.get_ascent(size_px) - font.get_descent(size_px)) / 2.0)
	item.draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, maxi(1, roundi(EDGE * _f)), RIM)
	item.draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, INK)
