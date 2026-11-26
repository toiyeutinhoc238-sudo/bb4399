extends "flash_screen.gd"














const Film = preload("ladder_up_film.gd")
const Ladder = preload("ladder_hall.gd")
const PopQueue = preload("pop_queue.gd")

const POP_ID: String = "ladder_section_up"
const DIM: Color = Color(0, 0, 0, 0.4)
const FRAME: Vector2 = Vector2(400, 300)
const SHOW_IN: Array = ["lobby", "hall", "room"]
const MEDALS: Array = ["bronze", "silver", "golden", "platnum", "diamon", "epic"]
const EFFECT: float = 0.5
const BACK: float = 1.70158
const GLOW: Color = Color("005da4")
const TEXT_PX: float = 15.0
const NAME_WIDE: float = 150.0
const LOAD_WAIT: float = 4.0
const BLUR_COPIES: int = 5
const BLUR_ALPHA: float = 0.85

signal closed

var queue: PopQueue
var section: Array = []
var _start: int = 0
var _end: int = 0
var _clock: float = 0.0
var _waited: float = 0.0
var _rolling: bool = false
var _opened: float = 0.0
var _closing: float = -1.0
var _base: Control
var _add: Control
var _top: Control

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_base = _layer_canvas(false, 0)
	_add = _layer_canvas(true, 1)
	_top = _layer_canvas(false, 2)
	if queue == null:
		queue = PopQueue.new()
		queue.client = client
		add_child(queue)
	queue.register(POP_ID, _open)
	if client != null:
		client.ladder_section_up.connect(notice)
		client.changed.connect(_pump)

func _layer_canvas(add: bool, pass_id: int) -> Control:
	var canvas: Control = Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if add:
		var mat: CanvasItemMaterial = CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		canvas.material = mat
	add_child(canvas)
	canvas.draw.connect(_paint_pass.bind(canvas, pass_id))
	return canvas


func notice(old: int, now: int) -> void :
	if old != 0 and now > old:
		queue.append(POP_ID, [old, now])


func _open(value: Variant) -> bool:
	var pair: Array = value if value is Array and (value as Array).size() == 2 else [1, 1]
	var old: int = int(pair[0])
	var now: int = int(pair[1])
	if client != null:
		now = client.ladder_section()

		old = int(client.ladder_old) if int(client.ladder_old) < now else old
	old = old if old > 0 else 1
	section = [old, now]
	var label: Array = Film.LABEL01 if _kind(old) != 0 and _kind(old) != _kind(now) else Film.LABEL02
	_start = int(label[0])
	_end = int(label[1])
	_clock = 0.0
	_waited = 0.0
	_rolling = false
	_opened = 0.0
	_closing = -1.0
	_loaded()
	_pump()
	return true


static func _kind(at: int) -> int:
	return MEDALS.find(Ladder.section_kind(maxi(1, at))) + 1


func _pump() -> void :
	if client == null:
		return
	if client.state not in SHOW_IN and client.state != "battle":
		section = []
	var want: bool = not section.is_empty() and client.state in SHOW_IN
	if visible != want:
		visible = want


func close() -> void :
	if section.is_empty() or _closing >= 0.0:
		return
	_closing = 0.0

func _finish() -> void :
	section = []
	_closing = -1.0
	visible = false
	closed.emit()
	queue.closed()


func frame() -> int:
	return mini(_start + _ticks(), _end) if _rolling else -1

func _ticks() -> int:
	return floori(_clock * Film.FPS)


func fx_frame() -> int:
	var at: int = frame()
	var placed: int = -1
	for born: int in Film.FX_PLACED:
		if born <= at and born >= _start:
			placed = born
	return posmod(_start + _ticks() - placed, Film.FX_FRAMES) if placed >= 0 else -1


func _loaded() -> bool:
	if pack == null:
		return true
	var done: bool = true
	for key: String in [Film.BG, Film.FX, Film.MID, Film.SPARK, Film.MEDAL]:
		if pack.effect(key).is_empty() and not pack.effect_failed(key):
			done = false
	return done

func _tick(delta: float) -> void :
	if section.is_empty():
		return
	_opened += delta
	if _closing >= 0.0:
		_closing += delta
		if _closing >= EFFECT:
			_finish()
			return
	if not _rolling:
		_waited += delta
		_rolling = _loaded() or _waited >= LOAD_WAIT
	else:
		_clock += delta
	for canvas: Control in [_base, _add, _top]:
		canvas.queue_redraw()


func lens() -> Array:
	if _closing >= 0.0:
		var t: float = clampf(_closing / EFFECT, 0.0, 1.0)
		return [lerpf(1.0, 0.1, t * t * ((BACK + 1.0) * t - BACK)), 1.0 - t]
	var u: float = clampf(_opened / EFFECT, 0.0, 1.0) - 1.0
	return [lerpf(0.1, 1.0, u * u * ((BACK + 1.0) * u + BACK) + 1.0), u + 1.0]


func _origin() -> Transform2D:
	var middle: Vector2 = (_centre(FRAME.x, FRAME.y) + FRAME / 2.0) * _f
	var scale_now: float = float(lens()[0]) * _f
	return Transform2D(0.0, Vector2(scale_now, scale_now), 0.0, middle - FRAME / 2.0 * scale_now)



func _paint() -> void :
	if section.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: int = frame()
	if at < 0:
		return
	var row: Array = Film.BUTTON_AT[at]
	if not row.is_empty():
		var place: Transform2D = _origin() * flash_matrix(row)
		_hit("ok", place * Film.BUTTON_RECT, false)


func _paint_pass(canvas: Control, pass_id: int) -> void :
	var at: int = frame()
	if section.is_empty() or at < 0 or pack == null:
		return
	var origin: Transform2D = _origin()
	var fade: float = float(lens()[1])
	if pass_id == 0:
		_put(canvas, pack.effect(Film.BG), 0, origin, Film.BG_AT[at], fade)
		_put(canvas, pack.effect(Film.FX), fx_frame(), origin, Film.FX_AT[at], fade)
		_words(canvas, origin, Film.TEXT_AT[at], fade, _desc(), "l", 3.0)
		_put(canvas, pack.effect(Film.MID), at, origin, [1.0, 0.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0, 0, 0, 0, 0.0, 0.0, 0], fade)
	var add: int = 1 if pass_id == 1 else 0
	if pass_id != 2:
		var old: int = int(section[0])
		var now: int = int(section[1])
		for slot: Array in [[Film.OLD_ICON_AT, _kind(old)], [Film.NEW_ICON_AT, _kind(now)], [Film.NEW_ICON_FX_AT, _kind(now)]]:
			var row: Array = slot[0][at]
			if not row.is_empty() and int(row[16]) == add:
				_put(canvas, pack.effect(Film.MEDAL), int(slot[1]) - 1, origin, row, fade)
		for slot: Array in [[Film.NEW_NAME_AT, now], [Film.NEW_NAME_FX_AT, now], [Film.OLD_NAME_AT, old]]:
			var row: Array = slot[0][at]
			if not row.is_empty() and int(row[16]) == add:
				_words(canvas, origin, row, fade, Ladder.reward_name(int(slot[1])), "c", 2.0)
	for item: Array in Film.OVER_AT[at]:
		if item.is_empty():
			continue
		var spark: int = int(item[17])
		if (pass_id == 2) != (spark == 2) or (pass_id != 2 and int(item[16]) != add):
			continue
		_put(canvas, pack.effect(Film.SPARK), spark, origin, item, fade)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


func _desc() -> String:
	return "Đã tăng lên %s,\nCố lên!" % Ladder.reward_name(int(section[1])) if not section.is_empty() else ""


static func flash_matrix(row: Array) -> Transform2D:
	return Transform2D(Vector2(float(row[0]), float(row[1])), Vector2(float(row[2]), float(row[3])), Vector2(float(row[4]), float(row[5])))


static func tint(row: Array, fade: float = 1.0) -> Color:
	return Color(float(row[6]) + float(row[10]) / 255.0, float(row[7]) + float(row[11]) / 255.0, float(row[8]) + float(row[12]) / 255.0, 
		clampf(float(row[9]) + float(row[13]) / 255.0, 0.0, 1.0) * fade)

static func _blur(row: Array) -> Vector2:
	return Vector2(float(row[14]), float(row[15])) if row.size() >= 16 else Vector2.ZERO


func _put(canvas: Control, fx: Dictionary, index: int, origin: Transform2D, row: Array, fade: float) -> void :
	if row.is_empty():
		return
	var frames: Array = fx.get("data", {}).get("frames", [])
	var pages: Array = fx.get("pages", [])
	if index < 0 or index >= frames.size():
		return
	var cell: Dictionary = frames[index]
	var page: int = int(cell.get("page", 0))
	if page >= pages.size() or pages[page] == null:
		return
	var px: float = float(fx.get("data", {}).get("px", 1.0))
	var rect: Array = cell.get("rect", [0, 0, 0, 0])
	var pivot: Array = cell.get("pivot", [0, 0])
	var src: Rect2 = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	var dst: Rect2 = Rect2( - Vector2(float(pivot[0]), float(pivot[1])) * px, src.size * px)
	var color: Color = tint(row, fade)
	if color.a <= 0.002:
		return
	canvas.draw_set_transform_matrix(origin * flash_matrix(row))
	var blur: Vector2 = _blur(row)
	if blur.x < 1.0 and blur.y < 1.0:
		canvas.draw_texture_rect_region(pages[page], dst, src, color)
		return
	color.a = 1.0 - pow(1.0 - minf(color.a, BLUR_ALPHA), 1.0 / BLUR_COPIES)
	for i in range(BLUR_COPIES):
		var shift: Vector2 = blur * (float(i) / float(BLUR_COPIES - 1) - 0.5)
		canvas.draw_texture_rect_region(pages[page], Rect2(dst.position + shift, dst.size), src, color)



func _words(canvas: Control, origin: Transform2D, row: Array, fade: float, text: String, align: String, edge: float) -> void :
	if row.is_empty() or text.is_empty():
		return
	var color: Color = tint(row, fade)
	color = Color(minf(color.r, 1.0), minf(color.g, 1.0), minf(color.b, 1.0), color.a)
	if color.a <= 0.002:
		return
	var font: Font = ARIAL_BOLD
	var font_size: int = maxi(6, roundi(TEXT_PX * _f))
	var blur: Vector2 = _blur(row)
	var copies: int = BLUR_COPIES if blur.x >= 1.0 or blur.y >= 1.0 else 1
	if copies > 1:
		color.a = 1.0 - pow(1.0 - minf(color.a, BLUR_ALPHA), 1.0 / copies)
	var rim: Color = Color(GLOW, color.a)
	var left: float = - NAME_WIDE / 2.0 * _f if align == "c" else 0.0
	var wide: float = NAME_WIDE * _f if align == "c" else -1.0
	var mode: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER if align == "c" else HORIZONTAL_ALIGNMENT_LEFT
	var lines: PackedStringArray = text.split("\n")
	for i in range(copies):
		var shift: Vector2 = blur * (float(i) / float(maxi(1, copies - 1)) - 0.5) if copies > 1 else Vector2.ZERO
		canvas.draw_set_transform_matrix(origin * flash_matrix(row) * Transform2D(0.0, Vector2(1.0 / _f, 1.0 / _f), 0.0, shift))
		for n in range(lines.size()):
			var base: Vector2 = Vector2(left, 2.0 * _f + font.get_ascent(font_size) + n * font.get_height(font_size))
			canvas.draw_string_outline(font, base, lines[n], mode, wide, font_size, maxi(1, roundi(edge * _f)), rim)
			canvas.draw_string(font, base, lines[n], mode, wide, font_size, color)



func _activate(id: String) -> void :
	if id == "ok":
		close()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
