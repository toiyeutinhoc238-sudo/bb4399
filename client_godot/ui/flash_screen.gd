extends "kit_screen.gd"




const SHADE: Color = Color(0, 0, 0, 0.8)
const WINDOW: Color = Color("5db8e9")



const ARIAL: Font = preload("res://assets/fonts/flash_ui.tres")
const ARIAL_BOLD: Font = preload("res://assets/fonts/flash_ui_bold.tres")

const _LevelLayer = preload("tank_portrait.gd")
var _f: float = 1.0
var _fw: float = RW / 2.0
var _fh: float = RH / 2.0
var _cells: Dictionary = {}



static var art_defer: bool = OS.has_feature("web")
static var _art_turn: int = -1
static var _art_hold: int = 0
const PRE_AUTH: Array = ["login", "auth"]
var _lazy: Dictionary = {}

func _metrics() -> void :
	super ()
	if not _lazy.is_empty():
		_art_now()
	_f = 2.0 * _u
	_fw = size.x / _f
	_fh = size.y / _f



const VIP12_FILE: String = "res://assets/ui/hall/vip12.png"
const VIP12_CELLS: Dictionary = {"lb_vbig11": ["lb_vbig12", [0, 0, 57, 41]], "shop_vip11": ["shop_vip12", [0, 0, 57, 41]], "ew_vip11": ["ew_vip12", [0, 0, 57, 41]], "vg_vip11": ["vg_vip12", [0, 0, 57, 41]], "pvr_vip11": ["pvr_vip12", [59, 0, 40, 29]]}


func _use(file: String, regions: Dictionary) -> void :
	var texture: Texture2D = null if _art_later(file, regions) else (load(file) if ResourceLoader.exists(file) else null)
	for name: String in regions:
		_cells[name] = [texture, regions[name]]
		if VIP12_CELLS.has(name):
			var twelve: Array = VIP12_CELLS[name]
			_cells[twelve[0]] = [load(VIP12_FILE) if ResourceLoader.exists(VIP12_FILE) else null, twelve[1]]


func _art_later(file: String, regions: Dictionary) -> bool:
	if not art_defer or not is_inside_tree() or is_visible_in_tree() or client == null or str(client.state) not in PRE_AUTH\
	or not ResourceLoader.exists(file):
		return false
	var wait: Array = _lazy.get(file, [])
	for name: String in regions:
		wait.append([name, regions[name]])
	_lazy[file] = wait
	if not get_tree().process_frame.is_connected(_art_step):
		get_tree().process_frame.connect(_art_step)
	return true


func _art_step() -> void :
	if _lazy.is_empty():
		get_tree().process_frame.disconnect(_art_step)
		return
	if _art_hold > 0 or _art_turn == Engine.get_process_frames() or client == null or str(client.state) in PRE_AUTH:
		return
	_art_turn = Engine.get_process_frames()
	_art_load(str(_lazy.keys()[0]))

func _art_now() -> void :
	for file: String in _lazy.keys():
		_art_load(file)


func _art_load(file: String) -> void :
	var texture: Texture2D = load(file)
	for pair: Array in _lazy.get(file, []):
		var cell: Array = _cells.get(pair[0], [])
		if not cell.is_empty() and cell[0] == null and is_same(cell[1], pair[1]):
			cell[0] = texture
	_lazy.erase(file)


func _stage() -> Vector2:
	return Vector2(roundf((floorf(_fw + 0.01) - 1000.0) / 2.0), roundf((floorf(_fh + 0.01) - 600.0) / 2.0))


func _centre(wide: float, high: float) -> Vector2:
	return Vector2(roundf((floorf(_fw + 0.01) - wide) / 2.0), roundf((floorf(_fh + 0.01) - high) / 2.0))

func _cell_size(name: String) -> Vector2:
	var cell: Array = _cells.get(name, [])
	return Vector2(float(cell[1][2]), float(cell[1][3])) if not cell.is_empty() else Vector2.ZERO


func _fblit(name: String, at: Vector2, wide: float = 0.0, high: float = 0.0, tint: Color = Color.WHITE) -> Rect2:
	var cell: Array = _cells.get(name, [])
	if cell.is_empty():
		return Rect2(at * _f, Vector2(wide, high) * _f)
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(wide if wide > 0.0 else float(region[2]), high if high > 0.0 else float(region[3])) * _f)
	if cell[0] != null:
		draw_texture_rect_region(cell[0], rect, Rect2(region[0], region[1], region[2], region[3]), tint)
	return rect




func _level_fx(level: int, at: Vector2, wide: float = 80.0) -> void :
	_LevelLayer.level_fx(self, pack, level, at, wide, _f, _time)

func _fpart(name: String, at: Vector2, from: Rect2, tint: Color = Color.WHITE) -> void :
	var cell: Array = _cells.get(name, [])
	if cell.is_empty() or cell[0] == null:
		return
	draw_texture_rect_region(cell[0], Rect2(at * _f, from.size * _f), Rect2(Vector2(float(cell[1][0]), float(cell[1][1])) + from.position, from.size), tint)


func _fmid(name: String, at: Vector2, wide: float, tint: Color = Color.WHITE) -> Rect2:
	return _fblit(name, at + Vector2(roundf((wide - _cell_size(name).x) / 2.0), 0), 0.0, 0.0, tint)


func _shine(id: String) -> float:
	if _press == id:
		return 0.78
	if _hover == id and _press.is_empty():
		return 1.16
	return 1.0

func _glow(id: String) -> Color:
	var lit: float = _shine(id)
	return Color(lit, lit, lit, 1.0)


func _fbutton(id: String, name: String, at: Vector2) -> Rect2:
	var rect: Rect2 = _fblit(name, at, 0.0, 0.0, _glow(id))
	_hit(id, rect, false)
	return rect





func _hscroll(id: String, names: Array, at: Vector2, wide: float, value: int, shown: int, count: int, apply: Callable) -> Rect2:
	var arrow: Vector2 = _cell_size(str(names[0]))
	var track: float = wide - arrow.y * 2.0
	_tslice(str(names[2]), at + Vector2(arrow.y, 0), track)
	_tbutton(id + ":left", str(names[0]), at)
	_tbutton(id + ":right", str(names[1]), at + Vector2(wide - arrow.y, 0))
	var most: int = count - shown
	if most > 0 and track > 0.0:
		var thumb: float = minf(track, maxf(20.0, track * shown / float(count)))
		var x: float = at.x + arrow.y + (track - thumb) * clampi(value, 0, most) / float(most)
		_hit(id + ":pgl", Rect2(Vector2(at.x + arrow.y, at.y) * _f, Vector2(x - at.x - arrow.y, arrow.x) * _f), false)
		_hit(id + ":pgr", Rect2(Vector2(x + thumb, at.y) * _f, Vector2(at.x + arrow.y + track - x - thumb, arrow.x) * _f), false)
		_tslice(str(names[3]), Vector2(x, at.y), thumb, _glow("slide:" + id))
		_knob_hit("slide:" + id, Rect2(Vector2(x, at.y) * _f, Vector2(thumb, arrow.x) * _f), value, most, (track - thumb) * _f, apply, true)
	return Rect2(at * _f, Vector2(wide, arrow.x) * _f)



func _tpart(name: String, at: Vector2, from: Rect2, size: Vector2, tint: Color = Color.WHITE) -> void :
	var cell: Array = _cells.get(name, [])
	if cell.is_empty() or cell[0] == null or size.x <= 0.0 or size.y <= 0.0:
		return
	draw_texture_rect_region(cell[0], Rect2(at * _f, Vector2(size.y, size.x) * _f), 
		Rect2(Vector2(float(cell[1][0]), float(cell[1][1])) + from.position, from.size), tint, true)


func _tslice(name: String, at: Vector2, wide: float, tint: Color = Color.WHITE) -> void :
	var cell: Vector2 = _cell_size(name)
	if wide <= 0.0 or cell.y <= 0.0:
		return
	var cap: float = minf(6.0, floorf(wide / 2.0))
	_tpart(name, at, Rect2(0, 0, cell.x, cap), Vector2(cap, cell.x), tint)
	_tpart(name, at + Vector2(wide - cap, 0), Rect2(0, cell.y - cap, cell.x, cap), Vector2(cap, cell.x), tint)
	_tpart(name, at + Vector2(cap, 0), Rect2(0, cap, cell.x, cell.y - 2.0 * cap), Vector2(wide - 2.0 * cap, cell.x), tint)


func _tbutton(id: String, name: String, at: Vector2) -> Rect2:
	var cell: Vector2 = _cell_size(name)
	_tpart(name, at, Rect2(Vector2.ZERO, cell), Vector2(cell.y, cell.x), _glow(id))
	var rect: Rect2 = Rect2(at * _f, Vector2(cell.y, cell.x) * _f)
	_hit(id, rect, false)
	return rect


func _frows(rows: Array, base: Vector2, solid: bool = false) -> void :
	for row: Array in rows:
		var id: String = str(row[4])
		var at: Vector2 = base + Vector2(float(row[1]), float(row[2]))
		var rect: Rect2
		if str(row[3]).is_empty():
			rect = Rect2(at * _f, Vector2(float(row[5]), float(row[6])) * _f)
		else:
			var lit: float = 1.0 if id.is_empty() else _shine(id)
			rect = _fblit(str(row[3]), at, float(row[5]), float(row[6]), Color(lit, lit, lit, 1.0 if solid else float(row[7]) / 100.0))
		if int(row[8]) == 1 and not id.is_empty():
			_hit(id, rect, false)


func _face(font: Font) -> Font:
	return ARIAL if font == REGULAR or font == ARIAL else ARIAL_BOLD


func _fstring(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, width: float, outline: Color = SHADE, thick: float = 0.0) -> float:
	font = _face(font)
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
	if thick > 0.0:
		draw_string_outline(font, origin, text, mode, width, font_size, maxi(1, roundi(thick * _u)), Color(outline, outline.a * color.a))
	draw_string(font, origin, text, mode, width, font_size, color)
	return minf(width, font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)




func _fwords(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, wide: float, edge: float = 0.0, high: float = 0.0, shrink: bool = true, rim: Color = SHADE) -> float:
	font = _face(font)
	var shown: float = px
	if shrink:
		while shown > 8.0 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(shown * _f))).x > wide * _f:
			shown -= 1.0
	var middle: float = at.y + (high / 2.0 if high > 0.0 else 2.0 + px * 0.55)
	var x: float = at.x if align == "l" else (at.x + wide / 2.0 if align == "c" else at.x + wide)
	return _fstring(text, font, shown * 2.0, color, align, Vector2(x, middle) * _f, wide * _f, rim, edge * 2.0) / _f





func _fgrad_words(text: String, font: Font, px: float, top: Color, bottom: Color, at: Vector2, wide: float) -> float:
	font = _face(font)
	var font_size: int = maxi(6, roundi(px * 2.0 * _u))
	var viewport: Viewport = get_viewport()
	var over: float = maxf(1.0, viewport.get_oversampling()) if viewport != null else 1.0
	var origin: Vector2 = Vector2(at.x, at.y + 2.0 + px * 0.55) * _f
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	var y_top: float = at.y * _f
	var high: float = (4.0 + px * 1.1) * _f
	var ts: TextServer = TextServerManager.get_primary_interface()
	var line: TextLine = TextLine.new()
	line.add_string(text, font, roundi(font_size * over))
	var canvas: RID = get_canvas_item()
	var pen: float = origin.x * over
	for glyph: Dictionary in ts.shaped_text_get_glyphs(line.get_rid()):
		var face: RID = glyph.get("font_rid", RID())
		var index: int = int(glyph.get("index", 0))
		var cache: Vector2i = Vector2i(int(glyph.get("font_size", 0)), 0)
		if face.is_valid() and ts.font_get_glyph_texture_idx(face, cache, index) >= 0:
			var sheet: RID = ts.font_get_glyph_texture_rid(face, cache, index)
			var uv: Rect2 = ts.font_get_glyph_uv_rect(face, cache, index)
			var box: Vector2 = ts.font_get_glyph_size(face, cache, index)
			var spot: Vector2 = (Vector2(pen, origin.y * over) + glyph.get("offset", Vector2.ZERO) + ts.font_get_glyph_offset(face, cache, index)).floor()
			for row: int in maxi(1, ceili(box.y)):
				var ink: Color = grad_ink(((spot.y + row + 0.5) / over - y_top) / high, top, bottom)
				RenderingServer.canvas_item_add_texture_rect_region(canvas, Rect2(Vector2(spot.x, spot.y + row) / over, Vector2(box.x, 1.0) / over), 
					sheet, Rect2(uv.position + Vector2(0, row), Vector2(uv.size.x, 1.0)), ink)
		pen += float(glyph.get("advance", 0.0)) * int(glyph.get("repeat", 1))
	return minf(wide, font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f)


static func grad_ink(t: float, top: Color, bottom: Color) -> Color:
	var start: float = 128.0 / 255.0
	return top if t <= start else top.lerp(bottom, clampf((t - start) / (1.0 - start), 0.0, 1.0))


func _fpara(text: String, font: Font, px: float, color: Color, at: Vector2, wide: float, lines: int = -1) -> void :
	font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	draw_multiline_string(font, Vector2(at.x, at.y + 2.0) * _f + Vector2(0, font.get_ascent(font_size)), text, HORIZONTAL_ALIGNMENT_LEFT, wide * _f, font_size, lines, color)

func _round(rect: Rect2, fill: Color, radius: float, edge: Color = Color(0, 0, 0, 0), width: float = 0.0) -> void :
	_box.bg_color = fill
	_box.set_corner_radius_all(maxi(1, roundi(minf(radius * _u, rect.size.y / 2.0))))
	_box.border_color = edge
	_box.set_border_width_all(maxi(1, roundi(width * _u)) if width > 0.0 else 0)
	draw_style_box(_box, rect)


func _scene() -> void :
	if overlay:
		return
	draw_rect(Rect2(Vector2.ZERO, size), NAVY)
	var path: String = hall_picture(hall, pack.lobby.get("halls", {}))
	var background: Texture2D = pack.picture(path) if not path.is_empty() else null
	if background != null:
		draw_texture_rect(background, hall_rect(hall, background.get_size(), size), false)


func _vip_level(points: int) -> int:
	var level: int = 0
	for row: Array in pack.lobby.get("vip", []):
		if points >= int(row[0]):
			level += 1
	return level



func _window(wide: float, high: float, close: String = "cancel", dim: float = 0.35) -> Vector2:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, dim))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(wide, high)
	_hit("panel", Rect2(at * _f, Vector2(wide, high) * _f), false)
	draw_rect(Rect2((at + Vector2(12, 43)) * _f, Vector2(wide - 24.0, high - 56.0) * _f), WINDOW)
	var full: Vector2 = _cell_size("public_bk_pattern")
	var part: Vector2 = Vector2(minf(full.x, wide - 24.0), minf(full.y, high - 56.0))
	_fpart("public_bk_pattern", at + Vector2(12, 43) + (Vector2(wide - 24.0, high - 56.0) - part) / 2.0, Rect2(((full - part) / 2.0).floor(), part))
	_fblit("public_bk_lt", at)
	_fblit("public_bk_rt", at + Vector2(wide - 34.0, 0))
	_fblit("public_bk_bc", at + Vector2(0, high - 90.0))
	_fblit("public_bk_bc_r", at + Vector2(wide - 30.0, high - 90.0))
	_fblit("public_bk", at + Vector2(34, 0), wide - 68.0)
	_fblit("public_bk_b2", at + Vector2(30, high - 68.0), wide - 60.0)
	_fblit("public_bk_l", at + Vector2(0, 84), 0.0, high - 174.0)
	_fblit("public_bk_r", at + Vector2(wide - 30.0, 84), 0.0, high - 174.0)
	_fmid("public_bk_ti", at + Vector2(0, 18), wide)
	_fblit("public_bk_oc", at + Vector2(43, 9), wide - 86.0)
	_fblit("public_bk_ol", at + Vector2(35, 9))
	_fblit("public_bk_or", at + Vector2(wide - 43.0, 9))
	_fblit("public_bk_c", at + Vector2(wide - 52.0, 13))
	_fmid("public_window_button_bk", at + Vector2(0, high - 56.0), wide)
	_fbutton(close, "public_button_close", at + Vector2(wide - 39.0, 15))
	return at



func _fedit(limit: int, digits: bool = false) -> LineEdit:
	var edit: LineEdit = _edit("", limit, digits)
	for state: String in ["normal", "focus", "read_only"]:
		edit.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	edit.add_theme_font_override("font", ARIAL_BOLD)
	edit.add_theme_color_override("font_color", Color.WHITE)
	edit.add_theme_color_override("font_uneditable_color", Color.WHITE)
	edit.add_theme_color_override("caret_color", Color.WHITE)
	edit.add_theme_color_override("selection_color", Color("0b5fae"))
	edit.add_theme_constant_override("minimum_character_width", 0)
	return edit



func _name_fedit() -> LineEdit:
	var edit: LineEdit = _fedit(0)
	edit.text_changed.connect( func(value: String) -> void :
		var over: int = value.length() - Client.CHAR_NAME_LIMIT
		if over > 0:
			var caret: int = maxi(edit.caret_column - over, 0)
			edit.text = value.left(caret) + value.substr(caret + over)
			edit.caret_column = caret)
	return edit


func _fput(edit: LineEdit, rect: Rect2, px: float, align: String = "l", editable: bool = true) -> void :
	edit.position = rect.position * _f
	edit.size = rect.size * _f
	edit.add_theme_font_size_override("font_size", maxi(8, roundi(px * _f)))
	edit.alignment = HORIZONTAL_ALIGNMENT_CENTER if align == "c" else HORIZONTAL_ALIGNMENT_LEFT
	edit.editable = editable
	edit.visible = true


func _draw_toast() -> void :
	var age: float = _time - _toast_at
	if _toast.is_empty() or age > 2.6:
		return
	var alpha: float = clampf(minf(age / 0.15, (2.6 - age) / 0.4), 0.0, 1.0)
	var font_size: int = maxi(6, roundi(32 * _u))
	var width: float = ARIAL_BOLD.get_string_size(_toast, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 96.0 * _u
	var rect: Rect2 = Rect2(Vector2((size.x - width) / 2.0, size.y * 0.3), Vector2(width, 88.0 * _u))
	_round(rect, Color("06203f", 0.92 * alpha), 22.0, Color("6fd0ff", 0.6 * alpha), 2.0)
	_fstring(_toast, SEMI, 32, Color(Color.WHITE, alpha), "c", rect.get_center(), rect.size.x)
