extends RefCounted





const FONT: Font = preload("res://assets/fonts/flash_ui_bold.tres")
const FILL: Color = Color("e9f9ff")
const EDGE: Color = Color.WHITE
const INK: Color = Color("086da5")
const WRAP: float = 186.0
const PAD: Vector2 = Vector2(4, 4)
const SHOW_MS: int = 100
const HIDE_MS: int = 10000



static var showing: Dictionary = {}

var _key: String = ""
var _since: int = 0
var _at: Vector2 = Vector2(-1, -1)


static func box(text: String, mouse: Vector2, stage: Vector2, f: float) -> Rect2:
	var px: int = maxi(6, roundi(12.0 * f))
	var span: Vector2 = FONT.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, WRAP * f, px) / f
	var size: Vector2 = Vector2(floorf(minf(span.x, WRAP)) + 8.0, floorf((span.y + 6.0) * 1.1))
	var at: Vector2 = mouse + Vector2(11, 22)
	if at.x + size.x > stage.x:
		at.x = stage.x - size.x
	if at.y + size.y > stage.y:
		at.y = stage.y - size.y
	return Rect2(at, size)


static func note(canvas: CanvasItem, rect: Rect2, f: float) -> void :
	var id: int = canvas.get_instance_id()
	if rect.size == Vector2.ZERO:
		showing.erase(id)
	elif canvas.is_inside_tree():
		showing[id] = canvas.get_global_transform_with_canvas() * Rect2(rect.position * f, rect.size * f)


static func covers(area: Rect2) -> bool:
	for id: int in showing.keys():
		var canvas: CanvasItem = instance_from_id(id) as CanvasItem
		if canvas == null or not canvas.is_inside_tree() or not canvas.is_visible_in_tree():
			showing.erase(id)
			continue
		if (showing[id] as Rect2).intersects(area):
			return true
	return false


static func paint(canvas: CanvasItem, text: String, rect: Rect2, f: float) -> void :
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = FILL
	style.border_color = EDGE
	style.set_border_width_all(maxi(1, roundi(f)))
	style.set_corner_radius_all(maxi(1, roundi(4.0 * f)))
	canvas.draw_style_box(style, Rect2(rect.position * f, rect.size * f))
	var px: int = maxi(6, roundi(12.0 * f))
	canvas.draw_multiline_string(FONT, (rect.position + PAD) * f + Vector2(0, FONT.get_ascent(px)), text, 
		HORIZONTAL_ALIGNMENT_LEFT, WRAP * f, px, -1, INK)



func track(canvas: CanvasItem, key: String, text: String, mouse: Vector2, stage: Vector2, f: float) -> Rect2:
	var now: int = Time.get_ticks_msec()
	if key != _key:
		_key = key
		_since = now
		_at = Vector2(-1, -1)
		if not key.is_empty() and canvas.is_inside_tree():
			canvas.get_tree().create_timer(SHOW_MS / 1000.0).timeout.connect(canvas.queue_redraw)
			canvas.get_tree().create_timer((SHOW_MS + HIDE_MS) / 1000.0).timeout.connect(canvas.queue_redraw)
	if key.is_empty() or text.is_empty():
		note(canvas, Rect2(), f)
		return Rect2()
	var age: int = now - _since
	if age < SHOW_MS or age >= SHOW_MS + HIDE_MS:
		note(canvas, Rect2(), f)
		return Rect2()
	if _at.x < 0.0:
		_at = mouse
	var rect: Rect2 = box(text, _at, stage, f)
	note(canvas, rect, f)
	return rect


func draw(canvas: CanvasItem, key: String, text: String, mouse: Vector2, stage: Vector2, f: float) -> Rect2:
	var rect: Rect2 = track(canvas, key, text, mouse, stage, f)
	if rect.size != Vector2.ZERO:
		paint(canvas, text, rect, f)
	return rect
