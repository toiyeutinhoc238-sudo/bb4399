extends "flash_screen.gd"






const Atlas = preload("msgbox_atlas.gd")

signal closed

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const CANVAS: Color = Color("0067b6")
const SHOW_IN: Array = ["lobby", "hall", "room", "battle"]
const MIN_TEXT: float = 60.0
const LINE: float = 18.0
const GUTTER: float = 2.0

var text: String = ""

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	if client != null:
		client.message_box.connect(show_text)
		client.changed.connect(_follow)


func _follow() -> void :
	if visible and (client == null or client.state not in SHOW_IN):
		close()


func show_text(value: String) -> void :
	value = value.strip_edges()
	if value.is_empty() or client == null or client.state not in SHOW_IN:
		return
	text = value
	_hover = ""
	_press = ""
	visible = true
	queue_redraw()

func close() -> void :
	if not visible:
		return
	visible = false
	text = ""
	closed.emit()


func lines() -> Array:
	var spec: Array = Atlas.TEXT["txtContent"]
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(float(spec[4]) * _f))
	var limit: float = (float(spec[2]) - GUTTER * 2.0) * _f
	var out: Array = []
	for part: String in text.split("\n"):
		var line: String = ""
		for word: String in part.split(" "):
			var next: String = word if line.is_empty() else line + " " + word
			if not line.is_empty() and font.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > limit:
				out.append(line)
				line = word
			else:
				line = next
		out.append(line)
	return out


func grow() -> float:
	var high: float = maxf(MIN_TEXT, LINE * lines().size() - 2.0 + 6.0)
	return high - MIN_TEXT

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	var inner: Vector2 = at + Vector2(floorf(float(Atlas.LEFT)), 0)
	var extra: float = grow()
	var bg: Vector2 = Vector2(float(Atlas.BG[0]), float(Atlas.BG[1]) + extra)
	_hit("panel", Rect2((inner - Vector2(0, extra)) * _f, bg * _f), false)
	_draw_bg(inner - Vector2(0, extra), bg)
	var title: Array = Atlas.TEXT["lblTitle"]
	var body: Array = Atlas.TEXT["txtContent"]
	var top: float = float(body[1]) - extra
	_fwords(str(Atlas.TITLE), ARIAL_BOLD, float(title[4]), Color(str(title[5])), "l", inner + Vector2(float(title[0]), float(title[1]) - extra), float(title[2]))
	var rows: Array = lines()
	for i in range(rows.size()):
		_fwords(str(rows[i]), ARIAL_BOLD, float(body[4]), Color(str(body[5])), "l", 
			inner + Vector2(float(body[0]) + GUTTER, top + LINE * i), float(body[2]) - GUTTER * 2.0, 0.0, 0.0, false)
	_fbutton("ok", "mb_ok", inner + _xy(Atlas.AT["ok"]))
	_fblit("mb_guy", at + _xy(Atlas.AT["guy"]))


func _draw_bg(o: Vector2, box: Vector2) -> void :
	var w: float = box.x
	var h: float = box.y
	var inside: Vector2 = Vector2(w - 36.0, h - 34.0)
	draw_rect(Rect2((o + Vector2(16, 16)) * _f, inside * _f), CANVAS)
	var fill: Vector2 = _xy(Atlas.FILL)
	var part: Vector2 = Vector2(minf(fill.x, inside.x), minf(fill.y, inside.y))
	_fpart("mb_fill", o + Vector2(16, 16) + ((inside - part) / 2.0).floor(), Rect2(((fill - part) / 2.0).floor(), part))
	_fblit("mb_c_tl", o)
	_fblit("mb_c_tr", o + Vector2(w - 99.0, 0))
	_fblit("mb_c_bl", o + Vector2(0, h - 51.0))
	_fblit("mb_c_br", o + Vector2(w - 99.0, h - 51.0))
	_fblit("mb_h_t", o + Vector2(99, 4))
	_fblit("mb_h_b", o + Vector2(99, h - 25.0))
	var side: float = minf(h - 102.0, float(Atlas.EDGE_V))
	if side > 0.0:
		_fpart("mb_v_l", o + Vector2(4, 51), Rect2(0, 0, 22, side))
		_fpart("mb_v_r", o + Vector2(w - 26.0, 51), Rect2(0, 0, 22, side))
	_fblit("mb_dot", o + Vector2(24, 23))
	_fblit("mb_dot", o + Vector2(24, h - 36.0))
	_fblit("mb_dot", o + Vector2(w - 36.0, h - 36.0))
	_fblit("mb_dot", o + Vector2(w - 36.0, 23))



func _activate(id: String) -> void :
	if id == "ok":
		close()

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
