extends Control




const Client = preload("../game_client.gd")
const AssetPack = preload("../battle/asset_pack.gd")
const Sound = preload("res://audio.gd")
const BrowserZoom = preload("browser_zoom.gd")
const TouchKeys = preload("touch_keys.gd")

signal chat_asked
signal page_asked(id: String)

const RW: float = 2772.0
const RH: float = 1280.0
const GOLD: Color = Color("e9c77b")
const CREAM: Color = Color("f4ecd8")
const MUTED: Color = Color("a7c4e2")
const NAVY: Color = Color("051530")
const GREEN: Color = Color("6fe3a1")
const RED: Color = Color("ff6b6b")


const GLASS: Color = Color("0b2d58")
const GLASS_LOW: Color = Color("071d3d")
const GLASS_EDGE: Color = Color("3fb1f5")
const BTN: Color = Color("1d76cf")
const BTN_TOP: Color = Color("41acf5")
const BTN_LOW: Color = Color("0f4d9e")
const BTN_EDGE: Color = Color("a6e6ff")
const BTN_GOLD: Color = Color("ffb630")
const GOLD_TOP: Color = Color("ffc540")
const GOLD_LOW: Color = Color("e66a08")
const BTN_GOLD_EDGE: Color = Color("fff3c0")
const BTN_INK: Color = Color("2a1c05")
const ON_GOLD: Color = Color("fffdf2")
const ON_BLUE: Color = Color("f3fbff")
const GOLD_RIM: Color = Color("5a2200")
const BLUE_RIM: Color = Color("08295a")
const TAB: Color = Color("16508f")
const TAB_TOP: Color = Color("2668b0")
const TAB_LOW: Color = Color("0d3570")
const TAB_LIT: Color = Color("1d76cf")
const ART: String = "res://assets/ui/lobby/"
const BOLD: Font = preload("res://assets/fonts/BeVietnamPro-Bold.ttf")
const SEMI: Font = preload("res://assets/fonts/BeVietnamPro-SemiBold.ttf")
const MEDIUM: Font = preload("res://assets/fonts/BeVietnamPro-Medium.ttf")
const REGULAR: Font = preload("res://assets/fonts/BeVietnamPro-Regular.ttf")

const LONG_PRESS: float = 0.5
const SWIPE: float = 40.0
const FLING_MIN: float = 300.0
const FLING_STOP: float = 25.0
const FLING_DECAY: float = 4.0
const TAP_MIN: float = 48.0
const TAP_PAD: float = 18.0
const TAP_BIG: Vector2 = Vector2(200.0, 120.0)

var client: Client
var pack: AssetPack
var hall: String = "native"
var _art: Dictionary = {}
var _hits: Array = []
var _hover: String = ""
var _press: String = ""
var _time: float = 0.0
var _u: float = 0.5
var _cw: float = RW
var _ch: float = RH
var _mobile: bool = false
var _toast: String = ""
var _toast_at: float = -10.0
var _glass: StyleBoxFlat = StyleBoxFlat.new()
var _lit: StyleBoxFlat = StyleBoxFlat.new()
var _box: StyleBoxFlat = StyleBoxFlat.new()
var _edits: Array[LineEdit] = []
var _held: bool = false
var _held_at: Vector2 = Vector2.ZERO
var _lp_start: float = -1.0
var _lp_tip: bool = false
var _tip_pin: bool = false
var _swipe_from: Vector2 = Vector2(-1, -1)
var _swipe_acc: float = 0.0
var _swipe_done: bool = false
var _fling: Vector2 = Vector2.ZERO
var _fling_from: Vector2 = Vector2.ZERO
var _fling_v: Vector2 = Vector2.ZERO
var _fling_at: float = 0.0
var _fling_block: bool = false
var _knobs: Dictionary = {}
var _knob: Array = []
var chat_dock: Rect2 = Rect2()
var chat_embedded: bool = false
var chat_embed: Rect2 = Rect2()
var chat_modern: bool = false
var overlay: bool = false

var covered: bool = false:
	set(value):
		if covered == value:
			return
		covered = value
		_hover = ""
		_press = ""
		_held = false
		_touch_reset()
		set_process_input( not value)
		set_process_unhandled_input( not value)
		set_process_unhandled_key_input( not value)

func _ready() -> void :
	_mobile = OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios")
	if _mobile:
		TouchKeys.ensure(self)
	mouse_exited.connect( func() -> void : _hover = "")
	visibility_changed.connect( func() -> void :
		_hover = ""
		_press = ""
		_touch_reset()
		_shown())
	_glass.bg_color = Color(GLASS, 0.95)
	_glass.border_color = Color(GLASS_EDGE, 0.7)
	_glass.anti_aliasing = true
	_lit.anti_aliasing = true
	_box.anti_aliasing = true
	_setup()

func _process(delta: float) -> void :
	if not is_visible_in_tree():
		return
	_time += delta
	if _mobile:
		_touch_tick(delta)
	_tick(delta)
	queue_redraw()

func _setup() -> void :
	pass


func chat_busy() -> bool:
	return false

func _tick(_delta: float) -> void :
	pass

func _paint() -> void :
	pass

func _activate(_id: String) -> void :
	pass

func _wheel(_step: int, _at: Vector2) -> void :
	pass



func _drag(moved: Vector2, from: Vector2) -> void :
	if not _mobile:
		return
	if from != _swipe_from:
		_swipe_from = from
		_swipe_acc = 0.0
		_swipe_done = false
	var pitch: float = _swipe_pitch()
	if pitch <= 0.0 or _swipe_done:
		return
	_swipe_acc += moved.y + (moved.x if _swipe_once() else 0.0)
	while absf(_swipe_acc) >= pitch and not _swipe_done:
		var step: int = 1 if _swipe_acc < 0.0 else -1
		_swipe_acc += pitch * step
		_wheel(step, from)
		_swipe_done = _swipe_once()


func _swipe_pitch() -> float:
	return SWIPE


func _swipe_once() -> bool:
	return false


func _long_press(_id: String) -> bool:
	return false


func _tap_tip(_id: String) -> bool:
	return false


func _tip_ok() -> bool:
	return not _mobile or _lp_tip or _tip_pin


func _shown() -> void :
	pass



func _metrics() -> void :
	var window: Vector2 = preload("res://settings.gd").native_size(Vector2(get_window().size))
	var stretch: float = maxf(0.01, window.x / maxf(1.0, size.x))

	var k: float = BrowserZoom.frame_k(window, RW, RH, _mobile)
	_u = maxf(0.05, k / stretch)
	_cw = size.x / _u
	_ch = size.y / _u
	var radius: int = maxi(2, roundi(16 * _u))
	_glass.set_corner_radius_all(radius)
	_glass.set_border_width_all(maxi(1, roundi(2 * _u)))
	_lit.set_corner_radius_all(radius)

func _p(x: float, y: float, ax: float, ay: float) -> Vector2:
	return Vector2((x + (_cw - RW) * ax) * _u, (y + (_ch - RH) * ay) * _u)

func _r(x0: float, y0: float, x1: float, y1: float, ax: float, ay: float) -> Rect2:
	return Rect2(_p(x0, y0, ax, ay), Vector2(x1 - x0, y1 - y0) * _u)


func _a(x: float, y: float, width: float, height: float) -> Rect2:
	return Rect2(Vector2(x, y) * _u, Vector2(width, height) * _u)

func _tex(name: String) -> Texture2D:
	if not _art.has(name):
		_art[name] = load(ART + name + ".png")
	return _art[name]


func _image(name: String, x: float, y: float, ax: float, ay: float, alpha: float = 1.0) -> Rect2:
	var texture: Texture2D = _tex(name)
	var rect: Rect2 = Rect2(_p(x, y, ax, ay), texture.get_size() * _u)
	draw_texture_rect(texture, rect, false, Color(1, 1, 1, alpha))
	return rect


func _string(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, width: float) -> float:
	var font_size: int = maxi(6, roundi(px * _u))
	var origin: Vector2 = at
	var mode: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
	if align == "c":
		origin.x -= width / 2.0
		mode = HORIZONTAL_ALIGNMENT_CENTER
	elif align == "r":
		origin.x -= width
		mode = HORIZONTAL_ALIGNMENT_RIGHT
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	var rgb: Color = Color(color.r, color.g, color.b)
	if rgb == ON_GOLD or rgb == ON_BLUE:
		draw_string_outline(font, origin, text, mode, width, font_size, maxi(2, roundi((9.0 if rgb == ON_GOLD else 7.0) * _u)), Color(GOLD_RIM if rgb == ON_GOLD else BLUE_RIM, color.a))
	draw_string(font, origin, text, mode, width, font_size, color)
	return minf(width, font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)

func _text(text: String, font: Font, px: float, color: Color, align: String, x: float, cy: float, width: float, ax: float, ay: float) -> float:
	return _string(text, font, px, color, align, _p(x, cy, ax, ay), width * _u)


func _measure(text: String, font: Font, px: float) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _u))).x / _u




func _knob_hit(id: String, rect: Rect2, value: float, most: float, travel: float, apply: Callable, across: bool = false) -> void :
	_hit(id, rect, false)
	if most > 0.0 and travel > 0.0:
		_knobs[id] = [apply, value, travel / most, across]


func _hit(id: String, rect: Rect2, feedback: bool = true) -> void :
	_hits.append([id, rect])
	if not feedback:
		return
	if _press == id:
		_lit.bg_color = Color(0, 0, 0, 0.22)
		draw_style_box(_lit, rect)
	elif _hover == id and _press.is_empty():
		_lit.bg_color = Color(1, 1, 1, 0.09)
		draw_style_box(_lit, rect)

func _hit_at(point: Vector2) -> String:
	for i in range(_hits.size() - 1, -1, -1):
		if (_hits[i][1] as Rect2).has_point(point):
			return tap_pick(_hits, point, i) if _mobile else str(_hits[i][0])
	return tap_pick(_hits, point, -1) if _mobile else ""



static func tap_pick(hits: Array, point: Vector2, top: int) -> String:
	var found: String = str(hits[top][0]) if top >= 0 else ""
	if top >= 0:
		var under: Rect2 = hits[top][1]
		if found not in ["shade", "panel"] and not (under.size.x > TAP_BIG.x and under.size.y > TAP_BIG.y):
			return found
	var best: String = found
	var best_d: float = INF
	for i in range(top + 1, hits.size()):
		var rect: Rect2 = hits[i][1]
		if not rect.has_area() or (rect.size.x >= TAP_MIN and rect.size.y >= TAP_MIN):
			continue
		var gx: float = clampf((TAP_MIN - rect.size.x) / 2.0, 0.0, TAP_PAD)
		var gy: float = clampf((TAP_MIN - rect.size.y) / 2.0, 0.0, TAP_PAD)
		if not rect.grow_individual(gx, gy, gx, gy).has_point(point):
			continue
		var d: float = point.distance_to(point.clamp(rect.position, rect.end))
		if d <= best_d:
			best_d = d
			best = str(hits[i][0])
	return best

func _fade(y0: float, y1: float, stops: Array) -> void :
	for i in range(stops.size() - 1):
		var top: float = lerpf(y0, y1, float(stops[i][0]) / 255.0)
		var bottom: float = lerpf(y0, y1, float(stops[i + 1][0]) / 255.0)
		var a: Color = Color(NAVY, float(stops[i][1]) / 255.0)
		var b: Color = Color(NAVY, float(stops[i + 1][1]) / 255.0)
		draw_polygon(PackedVector2Array([Vector2(0, top), Vector2(size.x, top), Vector2(size.x, bottom), Vector2(0, bottom)]), PackedColorArray([a, a, b, b]))




func _plate(rect: Rect2, fill: Color, edge: Color, radius: float = 16.0, border: float = 2.0) -> void :
	_box.bg_color = fill
	_box.border_color = edge
	_box.set_corner_radius_all(maxi(1, roundi(radius * _u)))
	_box.set_border_width_all(maxi(1, roundi(border * _u)) if edge.a > 0.0 else 0)
	draw_style_box(_box, rect)


func _grad(rect: Rect2, top: Color, bottom: Color, edge: Color, radius: float = 16.0, border: float = 2.0) -> void :
	var r: float = minf(radius * _u, minf(rect.size.x, rect.size.y) / 2.0)
	var centers: Array[Vector2] = [Vector2(rect.end.x - r, rect.position.y + r), Vector2(rect.end.x - r, rect.end.y - r), Vector2(rect.position.x + r, rect.end.y - r), Vector2(rect.position.x + r, rect.position.y + r)]
	var points: PackedVector2Array = PackedVector2Array()
	var colors: PackedColorArray = PackedColorArray()
	for k in range(4):
		for i in range(6):
			var angle: float = - PI / 2.0 + PI / 2.0 * (k + i / 5.0)
			var point: Vector2 = centers[k] + Vector2(cos(angle), sin(angle)) * r
			if not points.is_empty() and (point.distance_to(points[-1]) < 0.05 or point.distance_to(points[0]) < 0.05):
				continue
			points.append(point)
			colors.append(top.lerp(bottom, clampf((point.y - rect.position.y) / maxf(1.0, rect.size.y), 0.0, 1.0)))
	if points.size() >= 3:
		draw_polygon(points, colors)
	if edge.a > 0.0 and border > 0.0:
		_box.draw_center = false
		_plate(rect, Color(0, 0, 0, 0), edge, radius, border)
		_box.draw_center = true

func _panel(rect: Rect2, selected: bool = false) -> void :
	_grad(rect, Color(GLASS, 0.9), Color(GLASS_LOW, 0.9), Color(GOLD, 0.85) if selected else Color(GLASS_EDGE, 0.6))


func _gloss(rect: Rect2, radius: float, alpha: float) -> void :
	if alpha > 0.0:
		_plate(Rect2(rect.position + Vector2(4, 4) * _u, Vector2(rect.size.x - 8.0 * _u, rect.size.y * 0.46)), Color(1, 1, 1, alpha), Color(0, 0, 0, 0), maxf(2.0, radius - 4.0), 0.0)


func _tab_plate(rect: Rect2, chosen: bool, lit: bool = false, radius: float = 16.0, alive: bool = true) -> Color:
	if chosen:
		_grad(rect, GOLD_TOP, GOLD_LOW, BTN_GOLD_EDGE, radius, 2.0)
		_gloss(rect, radius, 0.12)
		return ON_GOLD
	if not alive:
		_plate(rect, Color(TAB_LOW, 0.6), Color(BTN_EDGE, 0.2), radius, 2.0)
		return Color(MUTED, 0.75)
	_grad(rect, TAB_TOP.lightened(0.14) if lit else TAB_TOP, TAB_LOW.lightened(0.12) if lit else TAB_LOW, Color(BTN_EDGE, 0.95 if lit else 0.6), radius, 2.0)
	_gloss(rect, radius, 0.1)
	return ON_BLUE


func _button(id: String, text: String, rect: Rect2, primary: bool = false, enabled: bool = true, px: float = 36.0) -> void :
	if primary:
		if enabled:
			_grad(rect, GOLD_TOP, GOLD_LOW, BTN_GOLD_EDGE, 18.0, 3.0)
			_gloss(rect, 18.0, 0.14)
		else:
			_plate(rect, Color("6b6559"), Color(CREAM, 0.2), 18.0, 3.0)
		_string(text, BOLD, px + 6.0, ON_GOLD if enabled else Color("29241a"), "c", rect.get_center(), rect.size.x)
	elif enabled:
		_grad(rect, BTN_TOP, BTN_LOW, Color(BTN_EDGE, 0.9), 18.0, 2.0)
		_gloss(rect, 18.0, 0.14)
		_string(text, SEMI, px, ON_BLUE, "c", rect.get_center(), rect.size.x)
	else:
		_plate(rect, Color("1a3354"), Color(BTN_EDGE, 0.18), 18.0, 2.0)
		_string(text, SEMI, px, Color(CREAM, 0.45), "c", rect.get_center(), rect.size.x)
	if enabled:
		_hit(id, rect)

func _pill(id: String, text: String, rect: Rect2, color: Color) -> void :
	draw_style_box(_glass, rect)
	_string(text, SEMI, 34, color, "c", rect.get_center(), rect.size.x)
	_hit(id, rect)


func _back(id: String, rect: Rect2) -> void :
	_grad(rect, BTN_TOP, BTN_LOW, Color(BTN_EDGE, 0.9), rect.size.x / _u / 2.0)
	var c: Vector2 = rect.get_center()
	var s: float = rect.size.x * 0.17
	draw_polyline(PackedVector2Array([c + Vector2(s * 0.6, - s), c + Vector2( - s * 0.6, 0), c + Vector2(s * 0.6, s)]), Color(1, 1, 1), maxf(2.0, 5.0 * _u), true)
	_hit(id, rect)


func _lock(at: Vector2, px: float, color: Color) -> void :
	var s: float = px * _u
	draw_rect(Rect2(at + Vector2( - s * 0.36, - s * 0.08), Vector2(s * 0.72, s * 0.54)), color)
	draw_arc(at + Vector2(0, - s * 0.1), s * 0.22, PI, TAU, 12, color, maxf(1.5, s * 0.11), true)


func _plus(at: Vector2, px: float, color: Color) -> void :
	var s: float = px * _u / 2.0
	var w: float = maxf(2.0, px * _u * 0.16)
	draw_line(at - Vector2(s, 0), at + Vector2(s, 0), color, w, true)
	draw_line(at - Vector2(0, s), at + Vector2(0, s), color, w, true)


func _avatar(avatar_id: int, rect: Rect2) -> void :
	_plate(rect, Color(0.083, 0.187, 0.29, 1.0), Color(CREAM, 0.25), 12.0)
	var key: String = str(pack.lobby.get("avatars", {}).get(str(avatar_id), ""))
	var head: Texture2D = pack.picture("l/h/%s.webp" % key) if not key.is_empty() else null
	if head != null:
		draw_texture_rect(head, rect.grow(-2.0 * _u), false)
		return

	_silhouette(rect.get_center(), rect.size.x, Color(MUTED, 0.55))


func _silhouette(c: Vector2, r: float, color: Color) -> void :
	draw_circle(c - Vector2(0, r * 0.12), r * 0.17, color, true, -1.0, true)
	var body: PackedVector2Array = PackedVector2Array()
	for i in range(13):
		var angle: float = PI + PI * i / 12.0
		body.append(c + Vector2(cos(angle) * r * 0.3, r * 0.36 + sin(angle) * r * 0.26))
	draw_colored_polygon(body, color)



static func hall_picture(hall_id: String, halls: Dictionary) -> String:
	if hall_id.begins_with("isle:"):
		return "l/island/" + hall_id.trim_prefix("isle:")
	var scene: String = hall_id if halls.has(hall_id) else "native"
	return "l/hall/%s/bg.webp" % scene if halls.has(scene) else ""



static func hall_rect(hall_id: String, picture: Vector2, box: Vector2) -> Rect2:
	if not hall_id.begins_with("isle:") or picture.x <= 0.0 or picture.y <= 0.0:
		return Rect2(Vector2.ZERO, box)
	var cover: Vector2 = picture * maxf(box.x / picture.x, box.y / picture.y)
	return Rect2(((box - cover) / 2.0).round(), cover)


func _backdrop() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), NAVY)
	var path: String = hall_picture(hall, pack.lobby.get("halls", {}))
	var background: Texture2D = pack.picture(path) if not path.is_empty() else null
	if background != null:
		var cover: Vector2 = background.get_size() * maxf(size.x / background.get_width(), size.y / background.get_height())
		draw_texture_rect(background, Rect2((size - cover) / 2.0, cover), false, Color(1, 1, 1, 0.9))
	draw_rect(Rect2(Vector2.ZERO, size), Color("06214a99"))


func _sheet(width: float, height: float, title: String) -> Rect2:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.007, 0.036, 0.066, 0.66))
	_hits.append(["shade", Rect2(Vector2.ZERO, size)])
	var panel: Rect2 = _a(_cw / 2.0 - width / 2.0, _ch / 2.0 - height / 2.0, width, height)
	draw_style_box(_glass, panel)
	_hits.append(["panel", panel])
	_string(title, BOLD, 48, GOLD, "c", panel.position + Vector2(panel.size.x / 2.0, 78.0 * _u), panel.size.x)
	return panel





static var _numeric_vk_done: bool = false
static func _numeric_vk() -> void :
	if _numeric_vk_done or not OS.has_feature("web"):
		return
	_numeric_vk_done = true
	JavaScriptBridge.eval("try{if(!Object.getOwnPropertyDescriptor(HTMLElement.prototype,'inputmode'))Object.defineProperty(HTMLElement.prototype,'inputmode',{configurable:true,get(){return this.inputMode},set(v){this.inputMode=v||''}})}catch(e){}", true)

func _edit(placeholder: String, limit: int, digits: bool = false) -> LineEdit:
	var edit: LineEdit = LineEdit.new()
	edit.placeholder_text = placeholder
	edit.max_length = limit
	edit.visible = false
	edit.context_menu_enabled = false
	edit.caret_blink = true
	if digits:
		edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER


		edit.select_all_on_focus = true
		_numeric_vk()
		edit.text_changed.connect( func(value: String) -> void :
			var clean: String = ""
			for i in range(value.length()):
				if value[i] >= "0" and value[i] <= "9":
					clean += value[i]
			if clean != value:
				var caret: int = edit.caret_column
				edit.text = clean
				edit.caret_column = mini(caret, clean.length()))
	for state: String in ["normal", "focus", "read_only"]:
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = Color(0.015, 0.067, 0.119, 0.92)
		box.border_color = Color(GOLD, 0.85) if state == "focus" else Color(CREAM, 0.22)
		box.anti_aliasing = true
		edit.add_theme_stylebox_override(state, box)
	edit.add_theme_font_override("font", SEMI)
	edit.add_theme_color_override("font_color", CREAM)
	edit.add_theme_color_override("font_placeholder_color", Color(MUTED, 0.6))
	edit.add_theme_color_override("caret_color", GOLD)
	add_child(edit)
	_edits.append(edit)
	return edit


func _place(edit: LineEdit, rect: Rect2) -> void :
	edit.position = rect.position
	edit.size = rect.size
	edit.add_theme_font_size_override("font_size", maxi(8, roundi(34 * _u)))
	for state: String in ["normal", "focus", "read_only"]:
		var box: StyleBoxFlat = edit.get_theme_stylebox(state) as StyleBoxFlat
		box.set_corner_radius_all(maxi(2, roundi(14 * _u)))
		box.set_border_width_all(maxi(1, roundi(2 * _u)))
		box.content_margin_left = 28 * _u
		box.content_margin_right = 28 * _u
	edit.visible = true

func _hide_edits() -> void :
	for edit: LineEdit in _edits:
		if edit.visible:
			edit.visible = false
			edit.release_focus()



func _draw() -> void :
	if client == null or pack == null:
		return
	_hits.clear()
	_knobs.clear()
	_metrics()
	_paint()
	_draw_toast()
	mouse_default_cursor_shape = CURSOR_POINTING_HAND if not _hover.is_empty() and _hover not in ["shade", "panel"] else CURSOR_ARROW

func _draw_toast() -> void :
	var age: float = _time - _toast_at
	if _toast.is_empty() or age > 2.6:
		return
	var alpha: float = clampf(minf(age / 0.15, (2.6 - age) / 0.4), 0.0, 1.0)
	var font_size: int = maxi(6, roundi(32 * _u))
	var width: float = SEMI.get_string_size(_toast, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 96.0 * _u
	var rect: Rect2 = Rect2(Vector2((size.x - width) / 2.0, size.y * 0.3), Vector2(width, 88.0 * _u))
	_glass.bg_color.a = 0.94 * alpha
	_glass.border_color.a = 0.55 * alpha
	draw_style_box(_glass, rect)
	_glass.bg_color.a = 0.94
	_glass.border_color.a = 0.55
	_string(_toast, SEMI, 32, Color(CREAM, alpha), "c", rect.get_center(), rect.size.x)

func say(text: String) -> void :
	if covered:
		return
	_toast = text
	_toast_at = _time

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var knob: Array = _knobs.get(_hit_at(event.position), []) if event.pressed else []
		_knob = [] if knob.is_empty() else [knob[0], knob[1], knob[2], event.position.x if knob[3] else event.position.y, knob[3]]
	elif event is InputEventMouseMotion and not _knob.is_empty() and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		(_knob[0] as Callable).call(float(_knob[1]) + ((event.position.x if _knob[4] else event.position.y) - float(_knob[3])) / float(_knob[2]))
		queue_redraw()
		accept_event()
		return
	if event is InputEventMouseMotion:
		if _mobile and _lp_tip:
			_hover = _hit_at(event.position)
			accept_event()
			return

		_hover = "" if _mobile else _hit_at(event.position)
		if _held and event.button_mask & MOUSE_BUTTON_MASK_LEFT:

			if not _press.is_empty() and event.position.distance_to(_held_at) > 10.0:
				_press = ""
			if _mobile and event.position.distance_to(_held_at) > 10.0:
				_lp_start = -1.0
			if _press.is_empty():
				_drag(event.relative, _held_at)
				if _mobile:
					_fling_note(event.relative)
	elif event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		if event.pressed:
			_wheel(-1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 1, event.position)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_held = event.pressed
		if _mobile:
			_touch_button(event.pressed)
		if event.pressed:
			_held_at = event.position
			_press = _hit_at(event.position)
		else:
			var id: String = _hit_at(event.position)
			var pressed: String = _press
			_press = ""
			if not id.is_empty() and id == pressed:
				if id not in ["shade", "panel"] and not id.begins_with("slide:"):
					Sound.click()
				_activate(id)
				if _mobile and _tap_tip(id):
					_hover = id
					_tip_pin = true
		accept_event()



func _touch_reset() -> void :
	_lp_start = -1.0
	_lp_tip = false
	_fling = Vector2.ZERO
	_fling_v = Vector2.ZERO


func _touch_button(down: bool) -> void :
	if down:
		_touch_reset()
		if _tip_pin:
			_tip_pin = false
			_hover = ""
		_lp_start = _time
		_fling_block = false
		_fling_at = Time.get_ticks_usec() / 1000000.0
		_swipe_from = Vector2(-1, -1)
		return
	if _lp_tip:
		_hover = ""
	var fresh: bool = Time.get_ticks_usec() / 1000000.0 - _fling_at < 0.08
	var flick: Vector2 = _fling_v if fresh and not _fling_block and not _lp_tip and _press.is_empty() else Vector2.ZERO
	_touch_reset()
	if flick.length() >= FLING_MIN:
		_fling = flick
		_fling_from = _held_at


func _fling_note(moved: Vector2) -> void :
	var now: float = Time.get_ticks_usec() / 1000000.0
	var dt: float = now - _fling_at
	_fling_at = now
	if dt > 0.0005:
		var speed: Vector2 = moved / maxf(dt, 1.0 / 120.0)
		_fling_v = speed if dt > 0.1 else _fling_v.lerp(speed, 0.5)
	if _grabbing():
		_fling_block = true


func _grabbing() -> bool:
	for key: String in ["_grab", "_sliding", "_rule_grab", "_fl_sliding", "_pick_key"]:
		var value: Variant = get(key)
		if (value is bool and value) or (value is String and not (value as String).is_empty()):
			return true
	return str(get("_drag_mode")) == "thumb" or not _knob.is_empty()


func _long_ok(id: String) -> bool:
	if id.begins_with("slide:"):
		return false
	var rep: Variant = get("_rep_id")
	if rep is String and not id.is_empty() and rep == id:
		return false
	var hold: Variant = get("_voice_hold_at")
	return not (hold is float and hold >= 0.0)

func _touch_tick(delta: float) -> void :
	if _held and not _lp_tip and _lp_start >= 0.0 and _time - _lp_start >= LONG_PRESS:
		_lp_start = -1.0
		var id: String = _press if not _press.is_empty() else _hit_at(_held_at)
		if _long_ok(id):
			_press = ""
			_lp_tip = true
			_hover = "" if _long_press(id) else id
			Input.vibrate_handheld(25)
	if not _held and _fling != Vector2.ZERO:
		_drag(_fling * delta, _fling_from)
		_fling *= exp( - FLING_DECAY * delta)
		if _fling.length() < FLING_STOP:
			_fling = Vector2.ZERO
