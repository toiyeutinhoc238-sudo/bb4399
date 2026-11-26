extends RefCounted














const HelperModel = preload("helper_model.gd")
const BagModel = preload("bag_model.gd")
const Atlas = preload("helper_tip_atlas.gd")
const ARIAL: Font = preload("res://assets/fonts/flash_ui.tres")
const ARIAL_BOLD: Font = preload("res://assets/fonts/flash_ui_bold.tres")

const WIDE: float = 280.0
const HINT_WIDE: float = 252.0
const BEGIN_Y: float = 10.0
const X: float = 5.0
const ICON_X: float = 17.0
const ICON: float = 100.0
const BASE_X: float = 135.0
const LABEL: float = 16.0
const HTML: float = 18.0
const PARA: float = 10.0
const STAR: float = 15.0
const LINE_SPACE: float = 12.0
const SCORE_X: float = 210.0
const SCORE: Vector2 = Vector2(80, 40)
const EQUIP_OFF: float = 20.0
const TEXT_WIDE: float = 244.0
const GUTTER: float = 2.0
const BIND_SIDE: float = 30.0
const TITLE_PX: float = 14.0
const PX: float = 12.0
const EFFECT: Color = Color("00ff00")
const DEC: Color = Color("cccccc")
const QUALITY: Dictionary = {2: Color("15ee19"), 3: Color("06fffc"), 4: Color("ff6eff")}
const ORANGE: Color = Color("f18819")
const TIME_START: int = 4
const SYS_BIND: int = 1
const MEASURE: float = 2.0

const BASE_ATTRS: Array = [[4, "HP"], [1, "TC"], [2, "XG"], [3, "PT"]]
const GROW_ATTRS: Array = [[5, "Di động", 15], [6, "Công Tốc", 16]]

const WORDS: Dictionary = {"TIP_232": "Tư chất:", "TIP_235": "LV:", "CONTROL_TEXT299": "Cường hóa:", "TIP_243": "[Đang Trang Bị]", 
	"ITEM_TEXT7": "[Thuộc tính cơ bản]", "ITEM_TEXT8": "[Thuộc tính tư chất]", "ITEM_TEXT2": "[Giới thiệu]", "TIP_280": "    Cường Hóa", 
	"TIP_6": "Hiệu lực vĩnh viễn", "TIP_7": "Ngày", "TIP_8": "Thời gian có hiệu lực", "TIP_9": "Quá hạn"}

const RESULTS: Dictionary = {"frmLevelResultHelper": [true, false, false, true, true], 
	"frmStrengthenResultHelper": [false, true, false, false, true], "frmGradeResultHelper": [false, false, true, true, false]}

static var _back: StyleBoxFlat = null
static var _sheet: Texture2D = null

static func tint(quality: int) -> Color:
	if quality <= 1:
		return Color.WHITE
	return QUALITY.get(quality, ORANGE)


static func width(text: String, px: float, bold: bool) -> float:
	var font: Font = ARIAL_BOLD if bold else ARIAL
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, roundi(px * MEASURE)).x / MEASURE


static func line_high() -> float:
	return ARIAL.get_height(roundi(PX * MEASURE)) / MEASURE




static func context(client, rec: Dictionary, more: Dictionary, result: String = "", show_time: bool = true) -> Dictionary:
	var uuid: String = str(rec.get("uuid", ""))
	var inst: Dictionary = {}
	if not uuid.is_empty() and client != null:
		for one: Dictionary in client.bags.get(5, []):
			if str(one.get("m_itemUuid", "")) == uuid:
				inst = one
				break
	var row: Array = more.get(str(int(rec.get("item", 0))), [])
	var flag: int = int(inst.get("m_extFlag", 0))
	return {"struct": RESULTS.get(result, []), "equipped": client != null and str(client.battle_helper) == uuid, 
		"bind": flag & SYS_BIND != 0, "life": int(inst.get("m_lifeTime", 0)), "flag": flag, 
		"now": int(Time.get_unix_time_from_system()), "show_time": show_time, 
		"quality": int(row[2]) if row.size() >= 4 else 0}


static func self_helper(client, data: Dictionary, more: Dictionary) -> Array:
	if client == null or str(client.battle_helper).is_empty():
		return []
	for inst: Dictionary in client.bags.get(5, []):
		if str(inst.get("m_itemUuid", "")) == str(client.battle_helper):
			var rec: Dictionary = HelperModel.record(inst, data, {"more": more}, str(client.battle_helper))
			return [] if rec.is_empty() else [rec, context(client, rec, more)]
	return []




static func layout(rec: Dictionary, data: Dictionary, ctx: Dictionary) -> Dictionary:
	if rec.is_empty():
		return {}
	var t: Array = rec.get("tpl", [])
	var ops: Array = []
	var y: float = BEGIN_Y
	var struct: Array = ctx.get("struct", [])
	var next: Array = struct if struct.size() == 5 else [false, false, false, false, false]
	var lv: int = int(rec.lv) + (1 if next[0] and int(rec.lv) < int(rec.lv_max) else 0)
	var up_next: bool = next[1] and int(rec.up) < int(rec.up_max)
	var rank_next: bool = next[2] and int(rec.rank) < int(rec.rank_max)
	var up: int = int(rec.up) + (1 if up_next else 0)
	var rank: int = int(rec.rank) + (1 if rank_next else 0)
	if bool(ctx.get("bind", false)):
		ops.append(["cell", "htp_bind", Rect2(WIDE - BIND_SIDE - 1.0, 4.0, BIND_SIDE, BIND_SIDE)])
	if not str(rec.get("icon", "")).is_empty():
		ops.append(["pic", str(rec.icon), Rect2(ICON_X, y, ICON, ICON)])
	y += 10.0
	ops.append(["label", str(rec.get("name", "")), Vector2(BASE_X, y), TITLE_PX, tint(int(ctx.get("quality", 0))), true])
	y += LABEL + 10.0
	ops.append(["label", WORDS.TIP_232 + str(int(rec.apt)), Vector2(BASE_X, y), PX, Color.WHITE, false])
	y += LABEL
	ops.append(["label", WORDS.TIP_235 + "%d/%d" % [lv, int(rec.lv_max)], Vector2(BASE_X, y), PX, Color.WHITE, false])
	y += LABEL
	ops.append(["label", WORDS.CONTROL_TEXT299 + "%d/%d" % [up, int(rec.up_max)], Vector2(BASE_X, y), PX, EFFECT, false])
	y += LABEL
	if bool(ctx.get("equipped", false)):

		ops.append(["label", WORDS.TIP_243, Vector2(WIDE - width(WORDS.TIP_243, PX, false) - EQUIP_OFF, y), PX, EFFECT, true])
	y += 10.0
	var limit: int = int(rec.rank_max)
	for i in range(limit):
		var spot: Vector2 = Vector2(ICON_X + (i % 10) * STAR, y + floori(i / 10.0) * STAR)
		ops.append(["cell", "htp_star_on" if i < rank else "htp_star_off", Rect2(spot, Vector2(STAR, STAR))])
	y += STAR * ceili(limit / 10.0)
	y += LINE_SPACE
	ops.append(["cell", "htp_line", Rect2(X, y, WIDE, 1.0)])
	y += 1.0 + LINE_SPACE

	var upc: int = int(rec.upc) if struct.size() != 5 or next[3] else 0
	var rankc: int = int(rec.rankc) if struct.size() != 5 or next[4] else 0
	var power: int = HelperModel.score(rec, data, lv, float(up) + HelperModel.luck(data, 1, up, upc) / 100.0, 
		float(rank) + HelperModel.luck(data, 2, rank, rankc) / 100.0)
	var number: String = str(power)
	ops.append(["label", number, Vector2(SCORE_X, y), TITLE_PX, Color.WHITE, true])
	var text_h: float = ARIAL_BOLD.get_height(roundi(TITLE_PX * MEASURE)) / MEASURE
	ops.append(["cell", "htp_score", Rect2(Vector2(SCORE_X - (SCORE.x - width(number, TITLE_PX, true)) / 2.0, y + text_h), SCORE)])
	y += PARA
	ops.append(["label", WORDS.ITEM_TEXT7, Vector2(X, y), PX, DEC, false])
	y += LABEL

	var lv_at: int = lv
	var up_at: float = float(up) if up_next else -1.0
	var rank_at: float = float(rank) if rank_next else -1.0
	for attr: Array in BASE_ATTRS:
		var value: int = HelperModel.attr(rec, data, int(attr[0]), lv_at, up_at, rank_at)
		y = _attr_line(ops, y, str(attr[1]), str(value), int(attr[0]), t)
	y += PARA
	ops.append(["label", WORDS.ITEM_TEXT8, Vector2(X, y), PX, DEC, false])
	y += LABEL
	for attr: Array in GROW_ATTRS:
		var raw: int = int(t[int(attr[2])]) if t.size() > int(attr[2]) else 0
		y = _attr_line(ops, y, str(attr[1]), "%d%%" % int(raw / 100.0), int(attr[0]), t)

	y += PARA
	ops.append(["label", WORDS.ITEM_TEXT2, Vector2(X, y), PX, DEC, false])
	y += LABEL
	var lines: Array = wrap_lines(runs(description(rec, data)), TEXT_WIDE - 2.0 * GUTTER)
	var line_h: float = line_high()
	for i in range(lines.size()):
		for part: Array in lines[i]:
			ops.append(["label", str(part[0]), Vector2(X + GUTTER + float(part[2]), y + i * line_h), PX, part[1], false])
	y += (lines.size() * line_h if not description(rec, data).is_empty() else 0.0) + 6.0

	if bool(ctx.get("show_time", true)):
		y += LABEL
		var life: int = int(ctx.get("life", 0))
		var line: String
		if life == 0:
			line = WORDS.TIP_6
		elif int(ctx.get("flag", 0)) & TIME_START:
			var left: int = life - int(ctx.get("now", 0))
			line = WORDS.TIP_9 if left < 0 else WORDS.TIP_8 + str(ceili(left / 86400.0)) + WORDS.TIP_7
		else:
			line = WORDS.TIP_8 + str(life) + WORDS.TIP_7
		ops.append(["label", line, Vector2(X, y), PX, Color.WHITE, false])
		y += LABEL
	return {"wide": WIDE, "high": y + LABEL, "ops": ops}


static func _attr_line(ops: Array, y: float, label: String, value: String, kind: int, t: Array) -> float:
	var text: String = label + "：+" + value
	ops.append(["label", text, Vector2(X, y), PX, Color.WHITE, false])
	if t.size() >= 15 and (kind == int(t[9]) or kind == int(t[12])):
		ops.append(["label", WORDS.TIP_280, Vector2(X + width(text, PX, false), y), PX, EFFECT, false])
	return y + HTML


static func description(rec: Dictionary, data: Dictionary) -> String:
	var index: int = int(data.get("desc", {}).get(str(int(rec.get("item", 0))), -1))
	var text: Array = data.get("text", [])
	if index < 0 or index >= text.size():
		return ""
	var raw: String = str(text[index])
	if raw.strip_edges().is_empty():
		return ""
	var cleaned: String = BagModel.clean(raw.replace("#ENTER#", ""))
	return cleaned.replace("", "#ENTER#")


static func runs(text: String) -> Array:
	var out: Array = []
	var rest: String = text.replace("#ENTER#", "\n")
	while not rest.is_empty():
		var open: int = rest.find("#COLOR_")
		var close: int = rest.find("_END#")
		if open < 0 or close < 0 or open >= close:
			out.append([rest, DEC])
			break
		if open > 0:
			out.append([rest.substr(0, open), DEC])
		var parts: PackedStringArray = rest.substr(open, close - open).split("_")
		if parts.size() >= 3 and parts[1].is_valid_html_color():
			out.append([parts[2], Color(parts[1])])
		rest = rest.substr(close + 5)
	return out


static func wrap_lines(pieces: Array, wide: float) -> Array:
	var lines: Array = [[]]
	var x: float = 0.0
	for piece: Array in pieces:
		var chunks: PackedStringArray = str(piece[0]).split("\n")
		for c in range(chunks.size()):
			if c > 0:
				lines.append([])
				x = 0.0
			for word: String in _words(chunks[c]):
				var bare: float = width(word.strip_edges(false, true), PX, false)
				if x > 0.0 and x + bare > wide:
					lines.append([])
					x = 0.0
					word = word.strip_edges(true, false)
					if word.is_empty():
						continue
				var line: Array = lines[lines.size() - 1]
				if not line.is_empty() and line[line.size() - 1][1] == piece[1]:
					line[line.size() - 1][0] += word
				else:
					line.append([word, piece[1], x])
				x += width(word, PX, false)
	if lines.size() == 1 and lines[0].is_empty():
		return []
	return lines


static func _words(text: String) -> Array:
	var out: Array = []
	var cur: String = ""
	var spaced: bool = false
	for i in range(text.length()):
		var ch: String = text[i]
		if ch == " ":
			spaced = true
		elif spaced and not cur.is_empty():
			out.append(cur)
			cur = ""
			spaced = false
		else:
			spaced = false
		cur += ch
	if not cur.is_empty():
		out.append(cur)
	return out






static func place(mouse: Vector2, main: Vector2, other: Vector2, stage: Vector2) -> Array:
	var y: float = mouse.y
	if mouse.y > stage.y - main.y:
		y = maxf(0.0, mouse.y - main.y)
	if other == Vector2.ZERO:
		var x: float = mouse.x - main.x
		return [Vector2(x if x >= 0.0 else mouse.x, y), Vector2.ZERO]
	if mouse.x - (HINT_WIDE + other.x) >= 0.0:
		return [Vector2(mouse.x - HINT_WIDE, y), Vector2(mouse.x - HINT_WIDE - other.x, y)]
	return [Vector2(mouse.x, y), Vector2(mouse.x + main.x, y)]


static func paint(canvas: CanvasItem, tip: Dictionary, at: Vector2, k: float, picture: Callable) -> void :
	if tip.is_empty():
		return
	if _back == null:
		_back = StyleBoxFlat.new()
		_back.bg_color = Color(0, 0, 0, 0.8)
		_back.anti_aliasing = true
	_back.set_corner_radius_all(maxi(1, roundi(6.0 * k)))
	canvas.draw_style_box(_back, Rect2(at * k, Vector2(float(tip.wide), float(tip.high)) * k))
	if _sheet == null and ResourceLoader.exists(Atlas.FILE):
		_sheet = load(Atlas.FILE)
	for op: Array in tip.ops:
		match str(op[0]):
			"label":
				var bold: bool = bool(op[5])
				var font: Font = ARIAL_BOLD if bold else ARIAL
				var px: float = float(op[3])
				var size: int = maxi(6, roundi(px * k))
				var spot: Vector2 = at + (op[2] as Vector2)
				var origin: Vector2 = Vector2(spot.x * k, (spot.y + 2.0 + px * 0.55) * k + (font.get_ascent(size) - font.get_descent(size)) / 2.0)
				canvas.draw_string(font, origin, str(op[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, size, op[4])
			"cell":
				var region: Array = Atlas.R.get(str(op[1]), [])
				if _sheet != null and region.size() == 4:
					var box: Rect2 = op[2]
					canvas.draw_texture_rect_region(_sheet, Rect2((at + box.position) * k, box.size * k), 
						Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])))
			"pic":
				var image: Texture2D = picture.call(str(op[1])) if picture.is_valid() else null
				if image != null and image.get_width() > 4:
					var box: Rect2 = op[2]
					var fit: float = minf(box.size.x / image.get_width(), box.size.y / image.get_height())
					canvas.draw_texture_rect(image, Rect2((at + box.position) * k, Vector2(image.get_size()) * fit * k), false)




static func show(canvas: CanvasItem, k: float, stage: Vector2, mouse: Vector2, client, data: Dictionary, more: Dictionary, 
		rec: Dictionary, ctx: Dictionary, compare: bool, picture: Callable) -> Dictionary:
	var main: Dictionary = layout(rec, data, ctx)
	if main.is_empty():
		return {}
	var other: Dictionary = {}
	if compare:
		var mine: Array = self_helper(client, data, more)
		if not mine.is_empty():
			other = layout(mine[0], data, mine[1])
	var main_size: Vector2 = Vector2(float(main.wide), float(main.high))
	var other_size: Vector2 = Vector2(float(other.wide), float(other.high)) if not other.is_empty() else Vector2.ZERO
	var spots: Array = place(mouse, main_size, other_size, stage)
	paint(canvas, main, spots[0], k, picture)
	if not other.is_empty():
		paint(canvas, other, spots[1], k, picture)
	return {"main": Rect2(spots[0], main_size), "other": Rect2(spots[1], other_size) if not other.is_empty() else Rect2()}
