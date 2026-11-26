extends RefCounted














const SIDE: float = 24.0
const LINE: float = 28.0
const PX: int = 14
const MIN_HIGH: float = 28.0


static func rows(emotes: Object, bubble: Dictionary, font: Font, width: float) -> Array:
	if emotes == null or font == null or not emotes.has_method("pieces"):
		return []
	var raw: String = str(bubble.get("raw", ""))
	if raw.is_empty() or not bool(emotes.has_emote(raw)):
		return []
	var parts: Array = emotes.pieces(raw)
	if not parts.any( func(piece: Array) -> bool: return str(piece[0]) == "emote"):
		return []
	var out: Array = []
	var row: Array = []
	var x: float = 0.0
	for piece: Array in parts:
		if str(piece[0]) == "emote":
			if x > 0.0 and x + SIDE > width:
				out.append(row)
				row = []
				x = 0.0
			row.append(["e", str(piece[1]), x])
			x += SIDE
			continue
		for found: RegExMatch in RegEx.create_from_string("\\S+|\\s").search_all(str(piece[1])):
			var word: String = found.get_string()
			var wide: float = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, PX).x
			if x > 0.0 and x + wide > width:
				if word.strip_edges().is_empty():
					continue
				out.append(row)
				row = []
				x = 0.0
			while wide > width and word.length() > 1:

				var cut: int = word.length() - 1
				while cut > 1 and font.get_string_size(word.left(cut), HORIZONTAL_ALIGNMENT_LEFT, -1, PX).x > width - x:
					cut -= 1
				row.append(["t", word.left(cut), x])
				out.append(row)
				row = []
				x = 0.0
				word = word.substr(cut)
				wide = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, PX).x
			row.append(["t", word, x])
			x += wide
	if not row.is_empty():
		out.append(row)
	return out


static func height(lines: Array) -> float:
	return maxf(MIN_HIGH, lines.size() * LINE)



static func draw(canvas: CanvasItem, emotes: Object, lines: Array, at: Vector2, font: Font, color: Color) -> Array:
	var asked: Array = []
	for i in range(lines.size()):
		var mid: float = at.y + i * LINE + LINE / 2.0
		for seg: Array in lines[i]:
			var x: float = at.x + float(seg[2])
			if str(seg[0]) == "e":
				asked.append(str(seg[1]))
				var tex: Texture2D = emotes.texture(str(seg[1])) if emotes != null else null
				if tex == null or tex.get_width() <= 0 or tex.get_height() <= 0:
					continue
				var scale: float = minf(SIDE / tex.get_width(), SIDE / tex.get_height())
				var shown: Vector2 = Vector2(tex.get_width(), tex.get_height()) * scale
				canvas.draw_texture_rect(tex, Rect2(Vector2(x, mid - SIDE / 2.0) + (Vector2(SIDE, SIDE) - shown) / 2.0, shown), false)
				continue
			var base: Vector2 = Vector2(x, mid + (font.get_ascent(PX) - font.get_descent(PX)) / 2.0)
			canvas.draw_string(font, base, str(seg[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, PX, color)
	return asked
