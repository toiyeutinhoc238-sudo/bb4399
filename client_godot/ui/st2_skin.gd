extends RefCounted




const Atlas = preload("st2_atlas.gd")
const LobbyBar = preload("lobby_bar.gd")
const XBOLD: Font = preload("res://assets/fonts/BeVietnamPro-ExtraBold.ttf")
const BOLD: Font = preload("res://assets/fonts/BeVietnamPro-Bold.ttf")
const SEMI: Font = preload("res://assets/fonts/BeVietnamPro-SemiBold.ttf")

const INK: Color = Color.WHITE
const RIM: Color = Color("0a3474")
const SOFT: Color = Color("a8d0f5")
const WARN: Color = Color("ffd84a")
const BAD: Color = Color("ff6b5a")
const LIVE: Color = Color("7ff179")
const ACCOUNT: Color = Color("0962c6")

const BLUE: Array = [Color("3acafc"), Color("019ff0"), Color("b9efff"), Color("064a8f")]
const DEEP: Array = [Color("1f8de8"), Color("0b62c6"), Color("8fd8ff"), Color("06367a")]
const ORANGE: Array = [Color("fcb000"), Color("fd7401"), Color("ffe28a"), Color("8a3300")]
const RED: Array = [Color("fe724e"), Color("c40d00"), Color("ffc0a8"), Color("7a0f00")]
const GREEN: Array = [Color("92ea28"), Color("169b00"), Color("dcffb0"), Color("1b5a00")]
const GRAY: Array = [Color("6d87a8"), Color("53698a"), Color("9fb2c8"), Color("2b3d55")]
const KINDS: Dictionary = {"blue": BLUE, "deep": DEEP, "orange": ORANGE, "red": RED, "green": GREEN, "gray": GRAY}

static var _tex: Texture2D = null
static var _tried: bool = false


static func tex() -> Texture2D:
	if not _tried:
		_tried = true
		if ResourceLoader.exists(Atlas.FILE):
			_tex = load(Atlas.FILE)
	return _tex

static func has(name: String) -> bool:
	return Atlas.R.has("st2_" + name)


static func icon(ci: CanvasItem, name: String, centre: Vector2, high: float, tint: Color = Color.WHITE) -> Rect2:
	var reg: Array = Atlas.R.get("st2_" + name, [])
	if reg.is_empty():
		return Rect2(centre, Vector2.ZERO)
	var wide: float = high * float(reg[2]) / maxf(1.0, float(reg[3]))
	var r: Rect2 = Rect2(centre - Vector2(wide, high) / 2.0, Vector2(wide, high))
	var t: Texture2D = tex()
	if t != null:
		ci.draw_texture_rect_region(t, r, Rect2(float(reg[0]), float(reg[1]), float(reg[2]), float(reg[3])), tint)
	return r


static func icon_in(ci: CanvasItem, name: String, r: Rect2, tint: Color = Color.WHITE) -> Rect2:
	var reg: Array = Atlas.R.get("st2_" + name, [])
	if reg.is_empty():
		return r
	var k: float = minf(r.size.x / maxf(1.0, float(reg[2])), r.size.y / maxf(1.0, float(reg[3])))
	return icon(ci, name, r.get_center(), float(reg[3]) * k, tint)


static func piece(ci: CanvasItem, name: String, r: Rect2, tint: Color = Color.WHITE) -> void :
	var reg: Array = Atlas.R.get("st2_" + name, [])
	var t: Texture2D = tex()
	if reg.is_empty() or t == null:
		return
	ci.draw_texture_rect_region(t, r, Rect2(float(reg[0]), float(reg[1]), float(reg[2]), float(reg[3])), tint)


static func fit(font: Font, value: String, px: float, wide: float) -> int:
	var size: int = maxi(5, roundi(px))
	while size > 5 and font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > wide:
		size -= 1
	return size



static func words(ci: CanvasItem, font: Font, value: String, px: float, r: Rect2, color: Color, align: String = "l", 
		outline: Color = Color(0, 0, 0, 0), thick: float = 0.0, shadow: Color = Color(0, 0, 0, 0)) -> float:
	if value.is_empty():
		return 0.0
	var size: int = fit(font, value, px, r.size.x)
	var w: float = font.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var x: float = r.position.x
	if align == "c":
		x += (r.size.x - w) / 2.0
	elif align == "r":
		x += r.size.x - w
	var at: Vector2 = Vector2(x, r.get_center().y + size * 0.36)
	var line: int = roundi(thick)
	if shadow.a > 0.0:
		var drop: Vector2 = Vector2(0, maxf(1.0, size * 0.09))
		if line > 0:
			ci.draw_string_outline(font, at + drop, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, line, shadow)
		ci.draw_string(font, at + drop, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, shadow)
	if line > 0 and outline.a > 0.0:
		ci.draw_string_outline(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, line, outline)
	ci.draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
	return w

static func grad(ci: CanvasItem, r: Rect2, radius: float, top: Color, bottom: Color, edge: Color = Color(0, 0, 0, 0), width: float = 1.0) -> void :
	LobbyBar.grad(ci, r, radius, top, bottom, edge, width)

static func _lit(c: Color, lit: float, a: float = 1.0) -> Color:
	return Color(minf(1.0, c.r * lit), minf(1.0, c.g * lit), minf(1.0, c.b * lit), c.a * a)




static func frame(ci: CanvasItem, r: Rect2, inner: Rect2, f: float) -> void :
	grad(ci, r.grow(1.0 * f), 18.0 * f, Color(0, 0, 0, 0.18), Color(0, 0, 0, 0.3))
	grad(ci, r, 16.0 * f, Color("fbfdff"), Color("dbe6f2"), Color("9db3cc"), maxf(1.0, 1.5 * f))
	var y: float = r.position.y + 1.5 * f
	var x0: float = r.position.x + 18.0 * f
	var x1: float = r.end.x - 18.0 * f
	var steps: int = 40
	for i in steps:
		var t: float = float(i) / steps
		var c: Color = Color.from_hsv(0.36 - 0.36 * t, 0.85, 1.0, 0.95)
		ci.draw_rect(Rect2(Vector2(lerpf(x0, x1, t), y), Vector2((x1 - x0) / steps + 0.5, 2.5 * f)), c)
	grad(ci, inner.grow(2.0 * f), 13.0 * f, Color("cfe1f3"), Color("b9cfe6"))
	grad(ci, inner, 12.0 * f, Color("1188ea"), Color("0566c9"), Color("63c9ff"), maxf(1.0, 2.0 * f))
	LobbyBar.gloss(ci, Rect2(inner.position, Vector2(inner.size.x, 40.0 * f)), 12.0 * f, f, 0.12, 0.0)


static func title(ci: CanvasItem, r: Rect2, f: float, value: String) -> void :
	var pts: PackedVector2Array = PackedVector2Array([r.position + Vector2(-8.0 * f, 0), Vector2(r.end.x + 8.0 * f, r.position.y), 
		r.end, Vector2(r.position.x, r.end.y)])
	ci.draw_colored_polygon(pts, Color("eef2f6"))
	var body: Rect2 = r.grow_individual(-2.0 * f, -1.0 * f, -2.0 * f, -2.0 * f)
	grad(ci, body, 9.0 * f, Color("98a8ba"), Color("4d5d70"), Color("dfe7ef"), maxf(1.0, 1.5 * f))
	LobbyBar.gloss(ci, body, 9.0 * f, f, 0.28, 0.02)
	var cy: float = body.get_center().y
	for side: float in [-1.0, 1.0]:
		gear(ci, Vector2(body.get_center().x + side * 67.0 * f, cy), 10.0 * f, Color("c9d6e4"), Color("2e3d50"))
	words(ci, XBOLD, value, 21.0 * f, Rect2(body.position + Vector2(40.0 * f, 0), body.size - Vector2(80.0 * f, 0)), Color.WHITE, "c", 
		Color("27364a"), 3.0 * f, Color(0, 0, 0, 0.35))


static func gear(ci: CanvasItem, c: Vector2, rad: float, fill: Color, edge: Color) -> void :
	var pts: PackedVector2Array = PackedVector2Array()
	for i in 48:
		var a: float = TAU * float(i) / 48.0
		var rr: float = rad if (i % 6) < 3 else rad * 0.76
		pts.append(c + Vector2(cos(a), sin(a)) * rr)
	ci.draw_colored_polygon(pts, edge)
	var inner: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in pts:
		inner.append(c + (p - c) * 0.84)
	ci.draw_colored_polygon(inner, fill)
	ci.draw_circle(c, rad * 0.34, edge)


static func tab(ci: CanvasItem, r: Rect2, f: float, on: bool, lit: float) -> void :
	if on:
		var body: Rect2 = Rect2(r.position, Vector2(r.size.x - 10.0 * f, r.size.y))
		var tip: PackedVector2Array = PackedVector2Array([Vector2(body.end.x - 6.0 * f, body.position.y), Vector2(r.end.x, body.get_center().y), 
			Vector2(body.end.x - 6.0 * f, body.end.y)])
		ci.draw_colored_polygon(tip, Color("f7d870"))
		var inner: PackedVector2Array = PackedVector2Array([tip[0] + Vector2(0, 3.0 * f), tip[1] + Vector2(-3.5 * f, 0), tip[2] + Vector2(0, -3.0 * f)])
		ci.draw_colored_polygon(inner, Color("fd8a1e"))
		grad(ci, body, 8.0 * f, Color("ffb703"), Color("fb7d1c"), Color("f7d870"), maxf(1.0, 2.0 * f))
		LobbyBar.gloss(ci, body, 8.0 * f, f, 0.3, 0.04)
	else:
		grad(ci, r, 8.0 * f, _lit(Color("1b92e6"), lit), _lit(Color("0569c4"), lit), Color("63c6ff", 0.9), maxf(1.0, 1.5 * f))
		LobbyBar.gloss(ci, r, 8.0 * f, f, 0.16, 0.0)


static func content(ci: CanvasItem, r: Rect2, f: float) -> void :
	grad(ci, r, 10.0 * f, Color("1a7dd8"), Color("0b5db9"), Color("3fa2ee"), maxf(1.0, 1.5 * f))


static func card(ci: CanvasItem, r: Rect2, f: float) -> void :
	grad(ci, r, 10.0 * f, Color("0a8cf2"), Color("0670d2"), Color("72d2ff"), maxf(1.0, 2.0 * f))
	LobbyBar.gloss(ci, r, 10.0 * f, f, 0.16, 0.0)


static func card_title(ci: CanvasItem, f: float, name: String, centre: Vector2, high: float, text_at: Vector2, value: String, wide: float = 260.0) -> void :
	if not name.is_empty():
		icon(ci, name, centre, high)
	words(ci, XBOLD, value, 19.0 * f, Rect2(text_at - Vector2(0, 12.0 * f), Vector2(wide * f, 24.0 * f)), Color.WHITE, "l", RIM, 3.0 * f, 
		Color(0, 0.1, 0.3, 0.45))


static func block(ci: CanvasItem, r: Rect2, f: float) -> void :
	grad(ci, r, 7.0 * f, Color("0f5fb4"), Color("125aac"), Color("0a4b97", 0.9), maxf(1.0, f))


static func sep(ci: CanvasItem, x0: float, x1: float, y: float, f: float) -> void :
	ci.draw_line(Vector2(x0, y), Vector2(x1, y), Color(1, 1, 1, 0.1), maxf(1.0, f))


static func keycell(ci: CanvasItem, r: Rect2, f: float, hot: bool, active: bool, dim: bool = false) -> void :
	var edge: Color = Color("ffb21e") if active else (Color("9fe2ff") if hot else Color("2b7fd2"))
	grad(ci, r, 5.0 * f, Color("0a4e99", 0.5 if dim else 1.0), Color("033a7a", 0.5 if dim else 1.0), edge, maxf(1.0, (2.0 if active else 1.5) * f))


static func button(ci: CanvasItem, r: Rect2, f: float, kind: String, value: String, px: float, lit: float = 1.0, alpha: float = 1.0, 
		radius: float = 7.0, font: Font = XBOLD) -> void :
	var c: Array = KINDS.get(kind, BLUE)
	grad(ci, r, radius * f, _lit(c[0], lit, alpha), _lit(c[1], lit, alpha), Color(c[2], 0.95 * alpha), maxf(1.0, 1.5 * f))
	LobbyBar.gloss(ci, r, radius * f, f, 0.26 * alpha, 0.02)
	if not value.is_empty():
		words(ci, font, value, px * f, r.grow_individual(-6.0 * f, 0, -6.0 * f, 0), Color(1, 1, 1, alpha), "c", Color(c[3], alpha), 2.5 * f)


static func switch(ci: CanvasItem, r: Rect2, f: float, on: bool, alpha: float = 1.0, lit: float = 1.0) -> void :
	if tex() == null:
		grad(ci, r, r.size.y / 2.0, Color("7ce23a") if on else Color("6c7a8c"), Color("1a9a12") if on else Color("475466"), Color.WHITE, maxf(1.0, f))
		var d: float = r.size.y - 4.0 * f
		ci.draw_circle(Vector2(r.end.x - d / 2.0 - 2.0 * f if on else r.position.x + d / 2.0 + 2.0 * f, r.get_center().y), d / 2.0, Color.WHITE)
		return
	piece(ci, "switch_on" if on else "switch_off", r, Color(lit, lit, lit, alpha))


static func track(ci: CanvasItem, r: Rect2, f: float, share: float, knob: float, alpha: float = 1.0, lit: float = 1.0) -> Vector2:
	grad(ci, r, r.size.y / 2.0, Color("021f55", alpha), Color("06357a", alpha), Color("0a2a5c", alpha), maxf(1.0, f))
	var x: float = r.position.x + r.size.x * clampf(share, 0.0, 1.0)
	if x - r.position.x > 2.0 * f:
		grad(ci, Rect2(r.position, Vector2(x - r.position.x, r.size.y)), r.size.y / 2.0, Color("8ff6ff", alpha), Color("00b9ee", alpha))
	var at: Vector2 = Vector2(x, r.get_center().y)
	if tex() != null:
		icon(ci, "knob", at, knob, Color(lit, lit, lit, alpha))
	else:
		ci.draw_circle(at, knob / 2.0, Color("e8f6ff", alpha))
		ci.draw_circle(at, knob / 3.2, Color("1593e6", alpha))
	return at


static func numbox(ci: CanvasItem, r: Rect2, f: float, value: String, px: float = 15.0) -> void :
	grad(ci, r, 6.0 * f, Color("0a3c84"), Color("072b66"), Color("3d92e2"), maxf(1.0, 1.5 * f))
	words(ci, XBOLD, value, px * f, r.grow_individual(-3.0 * f, 0, -3.0 * f, 0), Color.WHITE, "c", RIM, 2.0 * f)


static func hint(ci: CanvasItem, r: Rect2, f: float, value: String, color: Color = Color.WHITE) -> void :
	grad(ci, r, minf(r.size.y / 2.0, 10.0 * f), Color("0a5aaa"), Color("064992"), Color("2f88da", 0.9), maxf(1.0, f))
	var d: float = minf(r.size.y + 4.0 * f, 30.0 * f)
	icon(ci, "info", Vector2(r.position.x + 20.0 * f, r.get_center().y), d)
	words(ci, SEMI, value, 13.0 * f, Rect2(r.position + Vector2(40.0 * f, 0), Vector2(r.size.x - 48.0 * f, r.size.y)), color, "l", RIM, 2.0 * f)


static func check(ci: CanvasItem, r: Rect2, f: float, on: bool, alpha: float = 1.0, lit: float = 1.0) -> void :
	if tex() == null:
		grad(ci, r, 4.0 * f, Color("eaf4ff"), Color("b8d4ef"), Color("2b7fd2"), maxf(1.0, f))
		if on:
			ci.draw_polyline(PackedVector2Array([r.position + r.size * Vector2(0.22, 0.52), r.position + r.size * Vector2(0.42, 0.74), 
				r.position + r.size * Vector2(0.8, 0.28)]), Color("1a8ae6"), maxf(1.0, 3.0 * f))
		return
	piece(ci, "check_on" if on else "check_off", r, Color(lit, lit, lit, alpha))


static func arrow(ci: CanvasItem, centre: Vector2, d: float, left: bool, live: bool, lit: float = 1.0) -> void :
	var a: float = 1.0 if live else 0.35
	if tex() != null:
		icon(ci, "arrow_left" if left else "arrow_right", centre, d, Color(lit, lit, lit, a))
		return
	ci.draw_circle(centre, d / 2.0, Color(0.85, 0.88, 0.92, a))
	var s: float = -1.0 if left else 1.0
	ci.draw_colored_polygon(PackedVector2Array([centre + Vector2(s * d * 0.18, 0), centre + Vector2( - s * d * 0.1, - d * 0.2), 
		centre + Vector2( - s * d * 0.1, d * 0.2)]), Color(0.45, 0.5, 0.58, a))


static func swatch(ci: CanvasItem, centre: Vector2, d: float, f: float, color: Color, chosen: bool, hot: bool, checker: bool = false) -> void :
	if chosen:
		ci.draw_circle(centre, d / 2.0 + 3.0 * f, Color("ffb21e"))
		ci.draw_circle(centre, d / 2.0 + 1.2 * f, Color("fff0b8"))
	elif hot:
		ci.draw_circle(centre, d / 2.0 + 2.0 * f, Color("9fe2ff"))
	ci.draw_circle(centre, d / 2.0, Color("0a1a33"))
	if checker:
		ci.draw_circle(centre, d / 2.0 - 1.0 * f, Color("27384d"))
		var s: float = d / 5.0
		for gy in 5:
			for gx in 5:
				if (gx + gy) % 2 == 0:
					continue
				var p: Vector2 = centre + Vector2( - d / 2.0 + gx * s, - d / 2.0 + gy * s)
				var cell: Rect2 = Rect2(p, Vector2(s, s))
				var mid: Vector2 = cell.get_center()
				if mid.distance_to(centre) < d / 2.0 - s * 0.5:
					ci.draw_rect(cell, Color("4a5d75"))
	else:
		ci.draw_circle(centre, d / 2.0 - 1.0 * f, color)
		ci.draw_circle(centre + Vector2( - d * 0.14, - d * 0.16), d * 0.18, Color(1, 1, 1, 0.22))


static func badge(ci: CanvasItem, r: Rect2, f: float, value: String, top: Color, bottom: Color, ink: Color = Color.WHITE, rim: Color = Color("7a1500")) -> void :
	grad(ci, r, r.size.y / 2.0, top, bottom, Color("ffe08a"), maxf(1.0, f))
	words(ci, XBOLD, value, r.size.y * 0.72, r.grow_individual(-4.0 * f, 0, -4.0 * f, 0), ink, "c", rim, 2.0 * f)


static func big_arrow(ci: CanvasItem, tip: Vector2, f: float, left: bool, color: Color) -> void :
	var s: float = -1.0 if left else 1.0
	var w: float = 14.0 * f
	ci.draw_colored_polygon(PackedVector2Array([tip, tip + Vector2( - s * w, -10.0 * f), tip + Vector2( - s * w, -4.0 * f), 
		tip + Vector2( - s * 28.0 * f, -4.0 * f), tip + Vector2( - s * 28.0 * f, 4.0 * f), tip + Vector2( - s * w, 4.0 * f), tip + Vector2( - s * w, 10.0 * f)]), color)


static func dialog(ci: CanvasItem, r: Rect2, f: float) -> void :
	grad(ci, r.grow(3.0 * f), 16.0 * f, Color(0, 0, 0, 0.3), Color(0, 0, 0, 0.4))
	grad(ci, r, 14.0 * f, Color("ffffff"), Color("dbe8f5"))
	var body: Rect2 = r.grow(-4.0 * f)
	grad(ci, body, 11.0 * f, Color("0a86fb"), Color("033a86"), Color("6fd0ff"), maxf(1.0, 1.5 * f))
	LobbyBar.gloss(ci, Rect2(body.position, Vector2(body.size.x, minf(body.size.y, 60.0 * f))), 11.0 * f, f, 0.16, 0.0)


static func field(ci: CanvasItem, r: Rect2, f: float, focus: bool) -> void :
	grad(ci, r, 6.0 * f, Color("012a66"), Color("013276"), Color("ffb21e") if focus else Color("4aa3ef"), maxf(1.0, 1.5 * f))


static func toast(ci: CanvasItem, r: Rect2, f: float, value: String) -> void :
	grad(ci, r, r.size.y / 2.0, Color("fdfa56"), Color("ffd923"), Color("fff8c0"), maxf(1.0, 1.5 * f))
	icon(ci, "warn", Vector2(r.position.x + 18.0 * f, r.get_center().y), r.size.y * 0.62)
	words(ci, XBOLD, value, 14.0 * f, Rect2(r.position + Vector2(34.0 * f, 0), Vector2(r.size.x - 44.0 * f, r.size.y)), Color("6a3200"), "l")
