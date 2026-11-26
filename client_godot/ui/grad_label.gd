extends RefCounted









const HELPER_TOP: Color = Color("ffff44")
const HELPER_BOTTOM: Color = Color("ff2200")
const BROWN_GLOW_2: Color = Color("6c400b")
const START: float = 128.0 / 255.0


static func measured_high(px: float) -> float:
	return 4.0 + ceilf(px * 1.215)


static func ink(t: float, top: Color = HELPER_TOP, bottom: Color = HELPER_BOTTOM) -> Color:
	return top if t <= START else top.lerp(bottom, clampf((t - START) / (1.0 - START), 0.0, 1.0))




static func flex(item: CanvasItem, text: String, font: Font, px: float, at: Vector2, high: float, scale: float, top: Color = HELPER_TOP, 
		bottom: Color = HELPER_BOTTOM, rim: Color = BROWN_GLOW_2, edge: float = 1.0) -> float:
	if text.is_empty() or font == null or scale <= 0.0:
		return 0.0
	var font_size: int = maxi(6, roundi(px * scale))
	var origin: Vector2 = Vector2(at.x, at.y + 2.0 + px * 0.55) * scale
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	var rim_size: int = maxi(1, roundi(edge * scale)) if edge > 0.0 and rim.a > 0.0 else 0
	return draw(item, text, font, font_size, origin, at.y * scale, high * scale, top, bottom, rim, rim_size) / scale



static func draw(item: CanvasItem, text: String, font: Font, font_size: int, origin: Vector2, y_top: float, high: float, top: Color, 
		bottom: Color, rim: Color, rim_size: int) -> float:
	if text.is_empty() or font == null or font_size <= 0:
		return 0.0
	if rim_size > 0:
		item.draw_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, rim_size, rim)
	var viewport: Viewport = item.get_viewport()
	var over: float = maxf(1.0, viewport.get_oversampling()) if viewport != null else 1.0
	var deep: float = maxf(1.0, high)
	var ts: TextServer = TextServerManager.get_primary_interface()
	var line: TextLine = TextLine.new()
	line.add_string(text, font, roundi(font_size * over))
	var canvas: RID = item.get_canvas_item()
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
				var shade: Color = ink(((spot.y + row + 0.5) / over - y_top) / deep, top, bottom)
				RenderingServer.canvas_item_add_texture_rect_region(canvas, Rect2(Vector2(spot.x, spot.y + row) / over, Vector2(box.x, 1.0) / over), 
					sheet, Rect2(uv.position + Vector2(0, row), Vector2(uv.size.x, 1.0)), shade)
		pen += float(glyph.get("advance", 0.0)) * int(glyph.get("repeat", 1))
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
