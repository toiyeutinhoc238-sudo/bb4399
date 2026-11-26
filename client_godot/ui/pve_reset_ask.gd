extends RefCounted






const Ask = preload("exitask_atlas.gd")
const BOLD_FONT: Font = preload("res://assets/fonts/flash_ui_bold.tres")
const TIP_402: String = "Dùng @money@ xu khóa/xu reset lượt PB（Ưu tiên xu khóa）"
const TIP_79: String = "Xu không đủ, hãy nạp tiền"
const MONEY: String = "@money@"
const MONEY_INK: Color = Color("ff0000")
const ACT_PVE: int = 11
const ACT_COSTS: Array = [1, 4, 4, 9, 9]
const NUM: int = 50
const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const LINE: float = 18.0
const GUTTER: float = 2.0


static func cost(reset_time: int, map_type: int) -> int:
	var times: int = maxi(0, reset_time)
	if map_type == ACT_PVE:
		if times < 5:
			return int(ACT_COSTS[times])
		if times >= 25:
			return 49
		return int((times - 5) / 5) * 10 + 19
	var bit: int = 1 << (int(times / 3) % 32)
	if bit == 2147483648:
		bit = - bit
	return (NUM * bit) & 4294967295


static func price(info: Array, map_type: int) -> int:
	return cost(int(info[4]) if info.size() > 4 else 0, map_type)


static func words(amount: int) -> Array:
	var out: Array = []
	for word: String in TIP_402.split(" "):
		var at: int = word.find(MONEY)
		if at < 0:
			out.append([word, false])
			continue
		var parts: Array = []
		if at > 0:
			parts.append([word.substr(0, at), false])
		parts.append([str(amount), true])
		if at + MONEY.length() < word.length():
			parts.append([word.substr(at + MONEY.length()), false])
		out.append(parts[0] if parts.size() == 1 else parts)
	return out

static func _width(text: String, size_px: int, scale_f: float) -> float:
	return BOLD_FONT.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x / scale_f


static func lines(amount: int, scale_f: float) -> Array:
	var spec: Array = Ask.TEXTS["txtContent"]
	var size_px: int = maxi(6, roundi(float(spec[4]) * scale_f))
	var limit: float = float(spec[2]) - GUTTER * 2.0
	var space: float = _width(" ", size_px, scale_f)
	var out: Array = []
	var line: Array = []
	var x: float = 0.0
	for word in words(amount):
		var parts: Array = word if word[0] is Array else [word]
		var wide: float = 0.0
		for part: Array in parts:
			wide += _width(str(part[0]), size_px, scale_f)
		var start: float = 0.0 if line.is_empty() else x + space
		if not line.is_empty() and start + wide > limit:
			out.append(line)
			line = []
			start = 0.0
		var cursor: float = start
		for part: Array in parts:
			line.append([str(part[0]), bool(part[1]), cursor])
			cursor += _width(str(part[0]), size_px, scale_f)
		x = cursor
	if not line.is_empty():
		out.append(line)
	return out


static func paint(screen: Control, amount: int) -> void :
	screen.draw_rect(Rect2(Vector2.ZERO, screen.size), DIM)
	screen._hit("rs:shade", Rect2(Vector2.ZERO, screen.size), false)
	var f: float = float(screen._f)
	var at: Vector2 = screen._centre(float(Ask.SIZE[0]), float(Ask.SIZE[1]))
	var frame: Vector2 = at + Vector2(float(Ask.PANELS["frame"][0]), float(Ask.PANELS["frame"][1]))
	screen._hit("rs:panel", Rect2(frame * f, screen._cell_size("xa_frame") * f), false)
	screen._fblit("xa_frame", frame)
	var body: Array = Ask.TEXTS["txtContent"]
	var rows: Array = lines(amount, f)
	for i in range(rows.size()):
		for part: Array in rows[i]:
			var spot: Vector2 = at + Vector2(float(body[0]) + GUTTER + float(part[2]), float(body[1]) + LINE * i)
			screen._fwords(str(part[0]), BOLD_FONT, float(body[4]), MONEY_INK if bool(part[1]) else Color(str(body[5])), "l", spot, 
				float(body[2]), 0.0, 0.0, false)
	var ok: Array = Ask.NODES["btnConfirm"]
	var no: Array = Ask.NODES["btnCancel"]
	screen._fbutton("rs:ok", "xa_ok", at + Vector2(float(ok[0]), float(ok[1])))
	screen._fbutton("rs:no", "xa_no", at + Vector2(float(no[0]), float(no[1])))
	screen._fblit("xa_guy", at + Vector2(float(Ask.GUY[0]), float(Ask.GUY[1])))


static func confirm(screen: Control, client, map: int, amount: int) -> bool:
	var money: Dictionary = client.currency
	if int(money.get("m_iCash", 0)) + int(money.get("m_iSilver", 0)) < amount:
		screen.say(TIP_79)
		return false
	return client.pve_reset_enter(map)
