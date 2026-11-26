extends RefCounted







const ItemTip = preload("item_tip.gd")
const TipAtlas = preload("item_tip_atlas.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const CTip = preload("ctool_tip.gd")
const ARIAL: Font = preload("res://assets/fonts/flash_ui.tres")
const ARIAL_BOLD: Font = preload("res://assets/fonts/flash_ui_bold.tres")
const WIDE: float = 252.0
const BEGIN_Y: float = 10.0
const LINE: float = 16.0
const TEXT_WIDE: float = 240.0
const PX: float = 12.0
const DEC: Color = Color("cccccc")
const NAME: Color = Color.WHITE
const CD: Color = Color("21ac16")
const MP: Color = Color("529fe4")
const CORPS: Color = Color("ff0000")
const GUILD_FLAG: int = 1 << 28
const MO_HEADER: String = "Project-Id-Version:"
const GUARD: int = 50

const WORDS: Dictionary = {"TIP_399": "X Tấn Công", "ITEM_TEXT2": "[Giới thiệu]", "CONTROL_TEXT190": "Thời gian CD @num1@ s", 
	"CONTROL_TEXT775": "MP tiêu hao: @num1@", "CORPS_TEXT91": "Vào Guild kích hoạt skill Guild"}
const COLORS: Array = [["#PH_", "_IC#", "ffae0d"], ["#EN_", "_ER#", "df84f3"]]

static var _words_re: RegEx = null
static var _hex_re: RegEx = null
static var _mark_re: RegEx = null
static var _br_re: RegEx = null
static var _tag_re: RegEx = null

static func _re(slot: String) -> RegEx:
	match slot:
		"words":
			if _words_re == null:
				_words_re = RegEx.create_from_string("\\S+|\\s")
			return _words_re
		"hex":
			if _hex_re == null:
				_hex_re = RegEx.create_from_string("^[0-9a-f]{6}$")
			return _hex_re
		"mark":
			if _mark_re == null:
				_mark_re = RegEx.create_from_string("\\x01([^\\x02]*)\\x02([^\\x03]*)\\x03")
			return _mark_re
		"br":
			if _br_re == null:
				_br_re = RegEx.create_from_string("(?i)<br\\s*/?>")
			return _br_re
	if _tag_re == null:
		_tag_re = RegEx.create_from_string("<[^>]*>")
	return _tag_re



static func rich(text: String, tip399: String = "") -> Array:
	if tip399.is_empty():
		tip399 = WORDS.TIP_399
	if text.is_empty() or text.contains(MO_HEADER):
		return []
	if text.contains("<"):
		text = _re("br").sub(text, "\n", true)
		text = _re("tag").sub(text, "", true)
	text = text.replace("#ENTER#", "\n").replace("\r\n", "\n").replace("\r", "\n")
	var a: String = char(1)
	var b: String = char(2)
	var c: String = char(3)
	for spec: Array in COLORS:
		for _turn in range(GUARD):
			var start: int = text.find(str(spec[0]))
			var end: int = text.find(str(spec[1]))
			if start == -1 or end == -1:
				break
			var lo: int = mini(start, end + 4)
			var hi: int = maxi(start, end + 4)
			var parts: PackedStringArray = text.substr(lo, hi - lo).split("_")
			var value: String = parts[1] if parts.size() > 1 else ""
			text = text.substr(0, start) + a + str(spec[2]) + b + "(" + value + tip399 + ")" + c + text.substr(end + 4)
	for _turn in range(GUARD):
		var start: int = text.find("#COLOR_")
		var end: int = text.find("_END#")
		if start == -1 or end == -1 or start >= end:
			break
		var parts: PackedStringArray = text.substr(start, end + 5 - start).split("_")
		var color: String = parts[1].to_lower() if parts.size() > 1 else "cccccc"
		var value: String = parts[2] if parts.size() > 2 else ""
		if _re("hex").search(color) == null:
			color = "cccccc"
		text = text.substr(0, start) + a + color + b + value + c + text.substr(end + 5)
	var out: Array = []
	var from: int = 0
	for found: RegExMatch in _re("mark").search_all(text):
		_piece(out, text.substr(from, found.get_start() - from), DEC)
		_piece(out, found.get_string(2), Color.html(found.get_string(1)))
		from = found.get_end()
	_piece(out, text.substr(from), DEC)
	while not out.is_empty() and str(out[-1][0]).strip_edges().is_empty():
		out.pop_back()
	return out

static func _piece(out: Array, value: String, color: Color) -> void :
	if value.is_empty():
		return
	if not out.is_empty() and (out[-1][1] as Color).is_equal_approx(color):
		out[-1][0] = str(out[-1][0]) + value
	else:
		out.append([value, color])


static func pieces(segs: Variant) -> Array:
	var out: Array = []
	if not segs is Array:
		return out
	for seg: Variant in segs:
		if seg is Array and seg.size() >= 2:
			_piece(out, str(seg[0]), Color.html(str(seg[1])) if Color.html_is_valid(str(seg[1])) else DEC)
	return out


static func rows(segs: Array, width: float, px: float, f: float) -> Array:
	var out: Array = []
	var para: Array = []
	for seg: Array in segs:
		var parts: PackedStringArray = str(seg[0]).split("\n")
		for k in range(parts.size()):
			if k > 0:
				out.append_array(wrap_rows(para, width, px, f) if not para.is_empty() else [[]])
				para = []
			if not parts[k].is_empty():
				para.append([parts[k], seg[1]])
	if not para.is_empty():
		out.append_array(wrap_rows(para, width, px, f))
	return out


static func wrap_rows(segs: Array, width: float, px: float, f: float) -> Array:
	var font_size: int = maxi(6, roundi(px * f))
	var out: Array = [[]]
	var x: float = 0.0
	for seg: Array in segs:
		for found: RegExMatch in _re("words").search_all(str(seg[0])):
			var word: String = found.get_string()
			var w: float = _span(word, font_size, f)
			if x + w > width and x > 0.0:
				out.append([])
				x = 0.0
				if word.strip_edges().is_empty():
					continue
			while w > width and word.length() > 1:
				var cut: int = word.length() - 1
				while cut > 1 and _span(word.left(cut), font_size, f) > width:
					cut -= 1
				out[-1].append([word.left(cut), seg[1]])
				out.append([])
				word = word.substr(cut)
				w = _span(word, font_size, f)
			out[-1].append([word, seg[1]])
			x += w
	return out

static func _span(text: String, font_size: int, f: float) -> float:
	return ARIAL.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / f


static func tip_number(value: float) -> String:
	var tenth: float = snappedf(value, 0.1)
	return str(int(roundf(tenth))) if is_equal_approx(tenth, roundf(tenth)) else String.num(tenth, 1)


static func simulate(id: int, bag: Dictionary, extra: Dictionary = {}) -> Dictionary:
	var rec: Dictionary = {"id": id, "name": "", "desc": "", "quality": 0, "type": 0, "reuse": 0, "life": 0, "flag": 0, "bind": false, 
		"art": "", "icon": "", "face": ""}
	var row: Array = bag.get("items", {}).get(str(id), [])
	if row.size() >= 10:
		rec.name = BagModel.clean(str(row[0]))
		rec.desc = BagModel.clean(str(row[1]))
		rec.quality = int(row[3])
		rec.type = int(row[4])
		rec.reuse = int(row[9])
		var key: String = str(row[2])
		if not key.is_empty():
			rec.art = ("l/av/" if int(row[5]) == 4 else "l/it/") + key + ".webp"
			rec.icon = rec.art
	else:
		var more: Array = bag.get("more", {}).get(str(id), [])
		if more.size() >= 4:
			rec.name = BagModel.clean(str(more[0]))
			rec.quality = int(more[2])
			if not str(more[1]).is_empty():
				rec.icon = "l/it/%s.webp" % str(more[1])
				rec.art = rec.icon
	if str(rec.name).is_empty():
		rec.name = "Vật phẩm %d" % id
	rec.merge(extra, true)
	return rec


static func context(screen: Object, no_time: bool = false) -> Dictionary:
	var pack: Object = screen.get("pack")
	var client: Object = screen.get("client")
	var owned: Array = []
	var me: int = 0
	if client != null:
		for tank: Variant in (client.tanks as Dictionary).values():
			if tank is Dictionary and int(tank.get("m_contType", -1)) == GarageModel.OWN:
				owned.append(int(tank.get("m_tpltId", 0)))
		me = int(client.character.get("avatarId", 0)) if client.character is Dictionary else 0
	var lobby: Dictionary = pack.lobby if pack != null else {}
	var bagx: Dictionary = pack.bagx if pack != null else {}
	var tip399: String = str((pack.tips if pack != null else {}).get("text", {}).get("TIP_399", WORDS.TIP_399))
	var f: float = float(screen.get("_f"))
	return {"now": int(Time.get_unix_time_from_system()), "tanks": lobby.get("tanks", {}), "owned": owned, 
		"fx": bagx.get("fx", {}), "ornate": bagx.get("ornate", {}), "bigs": TipAtlas.BIG_OF, "coins": TipAtlas.COIN_OF, 
		"me": str(lobby.get("avatars", {}).get(str(me), "")), "line": LINE, "no_time": no_time, 
		"rich": func(text: String) -> Array: return rows(rich(text, tip399), TEXT_WIDE, PX, f)}


static func item(screen: Object, rec: Dictionary, opts: Dictionary = {}) -> Rect2:
	var pack: Object = screen.get("pack")
	if pack == null:
		return Rect2()
	if not (screen.get("_cells") as Dictionary).has("itp_bind"):
		screen.call("_use", TipAtlas.FILE, TipAtlas.R)
	var kind: int = int(rec.get("type", 0))
	if kind in [ItemTip.T_AVATAR, ItemTip.T_DECORATE, ItemTip.T_GIVE_ITEM] and (pack.bagx as Dictionary).is_empty():
		pack.load_bagx()
	if kind == ItemTip.T_TANK_SKIN and str(rec.get("face", "")).is_empty():
		rec = rec.duplicate()
		var skin: Array = (pack.garage as Dictionary).get("skin_items", {}).get(str(int(rec.get("id", 0))), [])
		var face: String = GarageModel.face(pack.garage, int(skin[1])) if skin.size() >= 2 else ""
		rec["face"] = "l/t/%s.webp" % face if not face.is_empty() else ""
	var ctx: Dictionary = context(screen, bool(opts.get("no_time", false)))
	var f: float = float(screen.get("_f"))
	var tall: Callable = func(text: String, wide: float, px: float) -> float:
		var font_size: int = maxi(6, roundi(px * f))
		return ARIAL.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, (wide - 4.0) * f, font_size).y / f
	return paint(screen, ItemTip.layout(rec, pack.bag, ctx, tall))


static func skill(screen: Object, id: int) -> Rect2:
	var pack: Object = screen.get("pack")
	if pack == null or id <= 0:
		return Rect2()
	if not (pack.tips as Dictionary).get("skills") is Dictionary:
		pack.load_tips()
		return Rect2()
	var client: Object = screen.get("client")
	var flag: int = 0
	var guild: int = 0
	if client != null:
		flag = int(client.character.get("actionFlag", 0)) if client.character is Dictionary else 0
		guild = int(client.guild.get("nGuildId", 0)) if client.guild is Dictionary else 0
	var tip: Dictionary = skill_layout(id, pack.tips, pack.skill_hud(id), flag, guild, float(screen.get("_f")))
	return Rect2() if tip.is_empty() else paint(screen, tip)



static func skill_layout(id: int, tips: Dictionary, info: Array, flag: int, guild: int, f: float) -> Dictionary:
	var row: Variant = tips.get("skills", {}).get(str(id))
	if not row is Array or row.size() < 4:
		return {}
	var text: Dictionary = tips.get("text", {})
	var ops: Array = []
	var y: float = BEGIN_Y
	var corps: bool = false
	for value: Variant in tips.get("corps", []):
		if int(value) == id:
			corps = true
			break
	if (flag & GUILD_FLAG) != 0 and corps and guild == 0:
		ops.append(["label", str(text.get("CORPS_TEXT91", WORDS.CORPS_TEXT91)), Vector2(0, y), 16.0, CORPS, false, WIDE])
		y += LINE + LINE
	ops.append(["label", str(row[0]), Vector2(5, y), 14.0, NAME, true, 0.0])
	y += 20.0
	var cool: int = int(info[1]) if info.size() > 1 else 0
	if cool > 0:
		ops.append(["label", str(text.get("CONTROL_TEXT190", WORDS.CONTROL_TEXT190)).replace("@num1@", tip_number(cool / 1000.0)), 
			Vector2(5, y), PX, CD, false, 0.0])
		y += LINE
	var mp: int = int(info[3]) if info.size() > 3 else 0
	if mp != 0:
		ops.append(["label", str(text.get("CONTROL_TEXT775", WORDS.CONTROL_TEXT775)).replace("@num1@", str(mp)), Vector2(5, y), PX, MP, false, 0.0])
		y += LINE
	y += 10.0
	ops.append(["label", str(text.get("ITEM_TEXT2", WORDS.ITEM_TEXT2)), Vector2(5, y), PX, DEC, false, 0.0])
	y += LINE
	var desc: Array = tips.get("desc", [])
	var index: int = int(row[1])
	var lines: Array = rows(pieces(desc[index]), TEXT_WIDE, PX, f) if index >= 0 and index < desc.size() else []
	if not lines.is_empty():
		ops.append(["rich", lines, Vector2(7, y), PX, LINE])
	y += lines.size() * LINE + 6.0
	return {"wide": WIDE, "high": y + LINE, "ops": ops}


static func paint(screen: Object, tip: Dictionary) -> Rect2:
	var canvas: CanvasItem = screen as CanvasItem
	var f: float = float(screen.get("_f"))
	var size: Vector2 = Vector2(float(tip.wide), float(tip.high))
	var at: Vector2 = ItemTip.place(canvas.get_local_mouse_position() / f, size, Vector2(float(screen.get("_fw")), float(screen.get("_fh"))))
	screen.call("_round", Rect2(at * f, size * f), Color(0, 0, 0, 0.8), 12.0)
	var regular: Font = ARIAL
	var bold: Font = ARIAL_BOLD
	var pack: Object = screen.get("pack")
	for op: Array in tip.ops:
		match str(op[0]):
			"label":

				var wide: float = float(op[6])
				if wide > 0.0:
					screen.call("_fwords", str(op[1]), bold if op[5] else regular, float(op[3]), op[4], "c", at + op[2] + Vector2(wide / 2.0 - 200.0, 0), 400.0, 0.0, 0.0, false)
				else:
					screen.call("_fwords", str(op[1]), bold if op[5] else regular, float(op[3]), op[4], "l", at + op[2], 400.0, 0.0, 0.0, false)
			"para":
				screen.call("_fpara", str(op[1]), regular, float(op[4]), op[5], at + op[2] + Vector2(2, 0), float(op[3]) - 4.0)
			"cell":
				var box: Rect2 = op[2]
				screen.call("_fblit", str(op[1]), at + box.position, box.size.x, box.size.y)
			"pic", "face":
				var box: Rect2 = op[2]
				var picture: Texture2D = pack.picture(str(op[1])) if pack != null else null
				if picture != null and picture.get_width() > 4:
					var k: float = minf(box.size.x / picture.get_width(), box.size.y / picture.get_height())
					var shown: Vector2 = Vector2(picture.get_size()) * k
					var lead: Vector2 = (box.size - shown) / 2.0 if str(op[0]) == "face" else Vector2.ZERO
					canvas.draw_texture_rect(picture, Rect2((at + box.position + lead) * f, shown * f), false)
			"rich":
				draw_rows(canvas, op[1], at + op[2], float(op[3]), float(op[4]), f)
	CTip.note(canvas, Rect2(at, size), f)
	return Rect2(at, size)


static func draw_rows(canvas: CanvasItem, lines: Array, at: Vector2, px: float, line: float, f: float) -> void :
	var font_size: int = maxi(6, roundi(px * f))
	var ascent: float = ARIAL.get_ascent(font_size)
	for i in range(lines.size()):
		var x: float = at.x * f
		var base: float = (at.y + 2.0 + i * line) * f + ascent
		for seg: Array in lines[i]:
			canvas.draw_string(ARIAL, Vector2(x, base), str(seg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, seg[1])
			x += ARIAL.get_string_size(str(seg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x




static func show(screen: Object, tip: Array, ctip: RefCounted) -> bool:
	var canvas: CanvasItem = screen as CanvasItem
	var f: float = float(screen.get("_f"))
	var stage: Vector2 = Vector2(float(screen.get("_fw")), float(screen.get("_fh")))
	var mouse: Vector2 = canvas.get_local_mouse_position() / f
	if tip.is_empty():
		ctip.call("draw", canvas, "", "", mouse, stage, f)
		return true
	var body: Variant = tip[4] if tip.size() > 4 else null
	if body is Dictionary:
		ctip.call("draw", canvas, "", "", mouse, stage, f)
		if (body as Dictionary).has("skill"):
			skill(screen, int(body.skill))
		else:
			item(screen, body, body.get("tip_opts", {}))
		return true
	if str(tip[2]).is_empty():
		ctip.call("draw", canvas, str(tip[0]) + str(tip[1]), str(tip[1]), mouse, stage, f)
		return true
	ctip.call("draw", canvas, "", "", mouse, stage, f)
	return false
