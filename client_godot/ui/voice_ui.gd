extends RefCounted





const BLUE_T: Color = Color("63ccff")
const BLUE_B: Color = Color("1268c9")
const BLUE_L: Color = Color("b5ecff")
const INK: Color = Color("0b3470")
const ORG_T: Color = Color("ffd257")
const ORG_B: Color = Color("ee6a0c")
const ORG_INK: Color = Color("5a1d00")
const TALK: Color = Color("4dff7a")
const RED: Color = Color("ff4a3d")
const OFF_T: Color = Color("8a97a6")
const OFF_B: Color = Color("4a5563")
const OFF_L: Color = Color("d8dee6")
const WAVE_FILL: Color = Color("1fae4b")
const MUTE_FILL: Color = Color("5b6573")
const PANEL_T: Color = Color("1a5fa8")
const PANEL_B: Color = Color("0b2f63")


const SVG: Dictionary = {
	"mic": "<rect x=\"8.6\" y=\"1.8\" width=\"6.8\" height=\"12.4\" rx=\"3.4\" fill=\"{c}\"/><path d=\"M5.2 10.8a6.8 6.8 0 0 0 13.6 0\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/><path d=\"M12 17.8v3.4M8.4 21.6h7.2\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/>", 
	"mic_off": "<rect x=\"8.6\" y=\"1.8\" width=\"6.8\" height=\"12.4\" rx=\"3.4\" fill=\"{c}\"/><path d=\"M5.2 10.8a6.8 6.8 0 0 0 13.6 0\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/><path d=\"M12 17.8v3.4M8.4 21.6h7.2\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/><path d=\"M3.4 3.4l17.2 17.2\" stroke=\"{d}\" stroke-width=\"2.8\" stroke-linecap=\"round\"/>", 
	"spk": "<path d=\"M2.6 8.6h4.2l5.4-4.8v16.4l-5.4-4.8H2.6z\" fill=\"{c}\" stroke=\"{c}\" stroke-width=\"1\" stroke-linejoin=\"round\"/><path d=\"M15.4 8.4a5 5 0 0 1 0 7.2M18.4 5.4a9.2 9.2 0 0 1 0 13.2\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/>", 
	"spk_room": "<path d=\"M2.6 8.6h4.2l5.4-4.8v16.4l-5.4-4.8H2.6z\" fill=\"{c}\" stroke=\"{c}\" stroke-width=\"1\" stroke-linejoin=\"round\"/><path d=\"M15.4 8.4a5 5 0 0 1 0 7.2\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\"/>", 
	"spk_off": "<path d=\"M2.6 8.6h4.2l5.4-4.8v16.4l-5.4-4.8H2.6z\" fill=\"{c}\" stroke=\"{c}\" stroke-width=\"1\" stroke-linejoin=\"round\"/><path d=\"M15.2 9l6 6M21.2 9l-6 6\" stroke=\"{d}\" stroke-width=\"2.6\" stroke-linecap=\"round\"/>", 
	"wave": "<rect x=\"2\" y=\"9\" width=\"3\" height=\"6\" rx=\"1.5\" fill=\"{c}\"/><rect x=\"7\" y=\"5\" width=\"3\" height=\"14\" rx=\"1.5\" fill=\"{c}\"/><rect x=\"12\" y=\"2.5\" width=\"3\" height=\"19\" rx=\"1.5\" fill=\"{c}\"/><rect x=\"17\" y=\"6.5\" width=\"3\" height=\"11\" rx=\"1.5\" fill=\"{c}\"/>", 
	"flag": "<path d=\"M5.2 2.6v18.8\" stroke=\"{c}\" stroke-width=\"2.2\" stroke-linecap=\"round\"/><path d=\"M6.2 3.6h12.4l-2.8 4.4 2.8 4.4H6.2z\" fill=\"{c}\"/>", 
}

static var _icons: Dictionary = {}


static func icon(name: String, px: int, c: Color, d: Color = RED) -> Texture2D:
	px = clampi(px, 6, 256)
	var key: String = "%s|%d|%s|%s" % [name, px, c.to_html(), d.to_html()]
	if _icons.has(key):
		return _icons[key]
	if _icons.size() > 96:
		_icons.clear()
	var body: String = str(SVG.get(name, "")).replace("{c}", "#" + c.to_html(false)).replace("{d}", "#" + d.to_html(false))
	var svg: String = "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\">" + body + "</svg>"
	var img: Image = Image.new()
	var texture: Texture2D = null
	if img.load_svg_from_string(svg, float(px) / 24.0) == OK and not img.is_empty():
		texture = ImageTexture.create_from_image(img)
	_icons[key] = texture
	return texture

static func draw_icon(ci: CanvasItem, name: String, center: Vector2, side: float, c: Color, d: Color = RED) -> void :
	var texture: Texture2D = icon(name, ceili(side * 2.0), c, d)
	if texture != null:
		ci.draw_texture_rect(texture, Rect2(center - Vector2(side, side) * 0.5, Vector2(side, side)), false)

static func rounded(r: Rect2, rad: float) -> PackedVector2Array:
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	if rad <= 0.0:
		return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	var pts: PackedVector2Array = PackedVector2Array()
	var corners: Array = [[r.position + Vector2(r.size.x - rad, rad), -90.0], [r.end - Vector2(rad, rad), 0.0], 
		[Vector2(r.position.x + rad, r.end.y - rad), 90.0], [r.position + Vector2(rad, rad), 180.0]]
	for corner: Array in corners:
		for s in 9:
			var a: float = deg_to_rad(float(corner[1]) + s * 90.0 / 8.0)
			var q: Vector2 = corner[0] + Vector2(cos(a), sin(a)) * rad
			if pts.is_empty() or pts[pts.size() - 1].distance_squared_to(q) > 0.0001:
				pts.append(q)
	if pts.size() > 3 and pts[pts.size() - 1].distance_squared_to(pts[0]) <= 0.0001:
		pts.remove_at(pts.size() - 1)
	return pts


static func grad(ci: CanvasItem, r: Rect2, rad: float, top: Color, bot: Color, border: Color = Color(0, 0, 0, 0), bw: float = 1.0) -> void :
	if r.size.x <= 0.5 or r.size.y <= 0.5:
		return
	var pts: PackedVector2Array = rounded(r, rad)
	var cols: PackedColorArray = PackedColorArray()
	for p: Vector2 in pts:
		cols.append(top.lerp(bot, clampf((p.y - r.position.y) / r.size.y, 0.0, 1.0)))
	ci.draw_polygon(pts, cols)
	if border.a > 0.0:
		var loop: PackedVector2Array = pts.duplicate()
		loop.append(pts[0])
		ci.draw_polyline(loop, border, maxf(1.0, bw), true)


static func glow(ci: CanvasItem, r: Rect2, rad: float, c: Color, f: float) -> void :
	for i in 4:
		var g: Rect2 = r.grow((4.0 - i) * f)
		var loop: PackedVector2Array = rounded(g, rad + (4.0 - i) * f)
		loop.append(loop[0])
		ci.draw_polyline(loop, Color(c, 0.18 + i * 0.2), maxf(1.0, 2.0 * f), true)


static func button(ci: CanvasItem, at: Vector2, rad: float, name: String, state: String, tag: String, font: Font, f: float, hover: bool = false, pressed: bool = false) -> void :
	var r: Rect2 = Rect2(at - Vector2(rad, rad), Vector2(rad, rad) * 2.0)
	ci.draw_circle(at + Vector2(0, 2.0 * f), rad, Color(0, 0, 0, 0.35))
	if state == "off":
		grad(ci, r, rad, OFF_T, OFF_B, OFF_L, 1.6 * f)
	else:
		grad(ci, r, rad, BLUE_T, BLUE_B, BLUE_L, 1.6 * f)
	grad(ci, Rect2(r.position + Vector2(2, 1.5) * f, Vector2(r.size.x - 4.0 * f, r.size.y * 0.45)), rad - 2.0 * f, Color(1, 1, 1, 0.55), Color(1, 1, 1, 0.08))
	draw_icon(ci, name, at + Vector2(0, 0.5 * f), rad * 1.15, Color.WHITE, RED)
	if pressed:
		ci.draw_circle(at, rad, Color(0, 0, 0, 0.22))
	elif hover:
		ci.draw_circle(at, rad, Color(1, 1, 1, 0.12))
	if state == "talk":
		ci.draw_arc(at, rad + 3.0 * f, 0, TAU, 40, TALK, 2.6 * f, true)
		ci.draw_arc(at, rad + 6.0 * f, 0, TAU, 40, Color(TALK, 0.35), 2.0 * f, true)
	if not tag.is_empty():
		var size: int = maxi(6, roundi(9.0 * f))
		var text_w: float = font.get_string_size(tag, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var tw: float = maxf(13.0 * f, text_w + 6.0 * f)
		var tr: Rect2 = Rect2(at + Vector2(rad * 0.45, rad * 0.35), Vector2(tw, 13.0 * f))
		grad(ci, tr, 4.0 * f, ORG_T, ORG_B, Color.WHITE, 1.2 * f)
		var base: float = tr.position.y + (tr.size.y + font.get_ascent(size) - font.get_descent(size)) * 0.5
		ci.draw_string(font, Vector2(tr.position.x + (tw - text_w) * 0.5, base), tag, HORIZONTAL_ALIGNMENT_LEFT, -1, size, ORG_INK)


static func chip(ci: CanvasItem, at: Vector2, rad: float, name: String, fill: Color, f: float, ink: Color = Color.WHITE) -> void :
	ci.draw_circle(at + Vector2(0, 1.5 * f), rad, Color(0, 0, 0, 0.35))
	ci.draw_circle(at, rad, fill)
	ci.draw_arc(at, rad, 0, TAU, 32, Color.WHITE, 1.4 * f, true)
	draw_icon(ci, name, at, rad * 1.25, ink, RED)



static func speaker_menu(ci: CanvasItem, at: Vector2, rows: Array, chosen: String, tip_x: float, bold: Font, semi: Font, f: float, hover: String = "", 
		up: bool = false) -> Dictionary:
	var w: float = 236.0 * f
	var h: float = (30.0 + rows.size() * 40.0 + 6.0) * f
	var box: Rect2 = Rect2(at, Vector2(w, h))
	grad(ci, Rect2(box.position + Vector2(0, 3.0 * f), box.size), 10.0 * f, Color(0, 0, 0, 0.35), Color(0, 0, 0, 0.35))
	grad(ci, box, 10.0 * f, PANEL_T, PANEL_B, BLUE_L, 2.0 * f)
	var title: int = maxi(6, roundi(12.0 * f))
	ci.draw_string_outline(bold, at + Vector2(14, 20) * f, "LOA", HORIZONTAL_ALIGNMENT_LEFT, -1, title, maxi(1, roundi(3.0 * f)), INK)
	ci.draw_string(bold, at + Vector2(14, 20) * f, "LOA", HORIZONTAL_ALIGNMENT_LEFT, -1, title, Color.WHITE)
	if up:
		ci.draw_colored_polygon(PackedVector2Array([Vector2(tip_x - 9.0 * f, at.y + 1.0), Vector2(tip_x, at.y - 10.0 * f), 
			Vector2(tip_x + 9.0 * f, at.y + 1.0)]), PANEL_T)
	else:
		ci.draw_colored_polygon(PackedVector2Array([Vector2(tip_x - 9.0 * f, at.y + h - 1.0), Vector2(tip_x + 9.0 * f, at.y + h - 1.0), 
			Vector2(tip_x, at.y + h + 10.0 * f)]), PANEL_B)
	var out: Dictionary = {}
	for i in rows.size():
		var row: Array = rows[i]
		var rr: Rect2 = Rect2(at + Vector2(8.0, 30.0 + i * 40.0) * f, Vector2(w - 16.0 * f, 36.0 * f))
		var on: bool = str(row[0]) == chosen
		if on:
			grad(ci, rr, 8.0 * f, ORG_T, ORG_B, Color("fff0b8"), 1.4 * f)
		else:
			var lit: float = 0.08 if hover == str(row[0]) else 0.0
			grad(ci, rr, 8.0 * f, Color(1, 1, 1, 0.1 + lit), Color(1, 1, 1, 0.04 + lit), Color(1, 1, 1, 0.18), 1.0 * f)
		var ink: Color = ORG_INK if on else Color.WHITE
		draw_icon(ci, str(row[1]), rr.position + Vector2(20, 18) * f, 20.0 * f, ink, RED)
		ci.draw_string(bold, rr.position + Vector2(38, 16) * f, str(row[2]), HORIZONTAL_ALIGNMENT_LEFT, rr.size.x - 70.0 * f, maxi(6, roundi(13.0 * f)), ink)
		ci.draw_string(semi, rr.position + Vector2(38, 30) * f, str(row[3]), HORIZONTAL_ALIGNMENT_LEFT, rr.size.x - 70.0 * f, maxi(6, roundi(10.0 * f)), Color(ink, 0.85))
		if on:
			ci.draw_circle(rr.position + Vector2(rr.size.x - 14.0 * f, 18.0 * f), 6.0 * f, Color.WHITE)
			ci.draw_circle(rr.position + Vector2(rr.size.x - 14.0 * f, 18.0 * f), 3.2 * f, ORG_B)
		out[str(row[0])] = rr
	return out


static func small_menu(ci: CanvasItem, at: Vector2, rows: Array, bold: Font, f: float, hover: String = "") -> Dictionary:
	var w: float = 128.0 * f
	var h: float = (8.0 + rows.size() * 28.0) * f
	var box: Rect2 = Rect2(at, Vector2(w, h))
	grad(ci, Rect2(box.position + Vector2(0, 3.0 * f), box.size), 8.0 * f, Color(0, 0, 0, 0.35), Color(0, 0, 0, 0.35))
	grad(ci, box, 8.0 * f, PANEL_T, PANEL_B, BLUE_L, 1.6 * f)
	var out: Dictionary = {}
	for i in rows.size():
		var row: Array = rows[i]
		var rr: Rect2 = Rect2(at + Vector2(4.0, 4.0 + i * 28.0) * f, Vector2(w - 8.0 * f, 26.0 * f))
		var lit: bool = hover == str(row[0])
		grad(ci, rr, 6.0 * f, Color(1, 1, 1, 0.16 if lit else 0.08), Color(1, 1, 1, 0.08 if lit else 0.02), Color(1, 1, 1, 0.14), 1.0 * f)
		draw_icon(ci, str(row[1]), rr.position + Vector2(14, 13) * f, 16.0 * f, Color.WHITE, RED)
		var size: int = maxi(6, roundi(12.0 * f))
		var base: float = rr.position.y + (rr.size.y + bold.get_ascent(size) - bold.get_descent(size)) * 0.5
		ci.draw_string(bold, Vector2(rr.position.x + 28.0 * f, base), str(row[2]), HORIZONTAL_ALIGNMENT_LEFT, rr.size.x - 32.0 * f, size, Color.WHITE)
		out[str(row[0])] = rr
	return out
