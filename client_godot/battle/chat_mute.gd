extends RefCounted











const Settings = preload("res://settings.gd")
const VOICE: String = "res://ui/voice_client.gd"
const VoiceUI = preload("res://ui/voice_ui.gd")
const BOLD: Font = preload("res://assets/fonts/BeVietnamPro-Bold.ttf")
const KEY: String = "chat_scene_off"
const SCENE: int = 32
const ROOM_HAPPY: int = 100
const ENTER_LOOK: int = 2
const CAMP_B: int = 2
const BTN_TOP: Color = Color("41acf5")
const BTN_LOW: Color = Color("0f4d9e")
const BTN_EDGE: Color = Color("a6e6ff")
const GOLD_TOP: Color = Color("ffc540")
const GOLD_LOW: Color = Color("e66a08")
const GOLD_EDGE: Color = Color("fff3c0")
const ON_BLUE: Color = Color("f3fbff")
const BTN_INK: Color = Color("2a1c05")
const NOTE: Color = Color("ffd700")
const LABEL_ON: String = "Chat tổng: Bật"
const LABEL_OFF: String = "Chat tổng: Tắt"
const NOTE_OFF: String = "Đã tắt chat tổng: ẩn kênh Chiến trường, vẫn xem chat Bên ta. Bật lại ở bảng tình hình trận."
const NOTE_ON: String = "Đã bật lại chat tổng."

const PC_X: float = 424.25
const PC_X_LV: float = 474.0
const PC_HEAD_Y: Array[float] = [44.0, 230.0]
const PC_CHIP: Vector2 = Vector2(30.0, 18.0)
const PC_HIT: Vector2 = Vector2(32.0, 24.0)
const PC_TOPS: Array[float] = [70.0, 254.0]
const PC_ROW: float = 20.0
const PC_ROOM_TOP: float = 384.0
const PC_RIGHT: float = 12.0
const PC_PILL_H: float = 24.0
const NAME_FADE: float = 0.4

const T_PILL: Vector2 = Vector2(158.0, 26.0)
const T_FOOT: float = 34.0
const T_PAD: float = 12.0
const T_RIGHT_PX: float = 12.0
const T_BOTTOM_PX: float = 8.0
const T_MUTE_R: float = 17.0

static var probe: Vector2 = Vector2.INF

static func scene_off() -> bool:
	return Settings.on(KEY)


static func hides(battle, line: Dictionary) -> bool:
	if bool(line.get("sys", false)):
		return false
	var from: int = int(line.get("from", 0))
	if from == 0 or from == int(battle.self_id):
		return false
	if battle.chat_muted.has(from):
		return true
	return int(line.get("ch", 0)) == SCENE and scene_off()


static func drop_bubble(battle, sender: int, channel: int) -> bool:
	return sender != int(battle.self_id) and channel == SCENE and scene_off()


static func set_scene(board, battle, off: bool) -> void :
	Settings.put(KEY, off)
	if battle == null:
		return
	if off:
		for store: Dictionary in [battle.bubbles, battle.load_chat]:
			for id: Variant in store.keys():
				if int(id) != int(battle.self_id) and int(store[id].get("ch", 0)) == SCENE:
					store.erase(id)
	battle._chat_line({"head": "", "name": "", "name_color": Color.WHITE, "text": NOTE_OFF if off else NOTE_ON, "color": NOTE}, true)
	refresh(board)


static func toggle_person(board, battle, account: int, mates: bool) -> void :
	var on: bool = not battle.chat_muted.has(account)
	if on:
		battle.chat_muted[account] = true
		battle.bubbles.erase(account)
		battle.load_chat.erase(account)
	else:
		battle.chat_muted.erase(account)
	var voice_script: GDScript = load(VOICE) if mates else null
	if voice_script != null and voice_script.call("usable"):
		var voice: Object = voice_script.call("shared")
		if voice.is_muted(account) != on:
			voice.toggle_mute(account)
	refresh(board)


static func refresh(board) -> void :
	var host: Node = board.get_parent() if board != null else null
	var ui: Variant = host.get("chat_ui") if host != null else null
	if ui is Object and "_key" in ui:
		ui._key = []


static func paint_pc(board, battle, o: Vector2) -> void :
	var f: float = board._f
	var spots: Array = []
	var happy: bool = int(battle.room_type) == ROOM_HAPPY
	var camp: int = board.view_camp(battle)
	var ours: int = 1 if camp == CAMP_B else 0
	var look: bool = int(battle.enter_type) == ENTER_LOOK
	var x: float = PC_X_LV if board.level_map(battle, board.pack) else PC_X
	var mouse: Vector2 = probe if probe != Vector2.INF else board.get_local_mouse_position()
	var sides: Array = [0] if happy else [0, 1]
	for side: int in sides:
		board._label("Chat", 14.0, board.HEAD, o, x - board.WIDE / 2.0, PC_HEAD_Y[side], 1.5, board.LABEL_GLOW, 44.0)
		var lines: Array = board._lines[side]
		for r in range(mini(lines.size(), 12 if happy else 6)):
			var account: int = int(lines[r][6])
			if account == int(battle.self_id):
				continue
			var c: Vector2 = ((o + Vector2(x, PC_TOPS[side] + PC_ROW * r + PC_ROW / 2.0)) * f).round()
			var hit: Vector2 = hit_size(f)
			spots.append([account, c, Rect2(c - hit / 2.0, hit), not happy and side == ours and camp != 0 and not look])
	var hot: Array = _pick(spots, mouse)
	for spot: Array in spots:
		_chip(board, spot[1], f, battle.chat_muted.has(int(spot[0])), spot == hot)

	var font: Font = board._face(board.ARIAL_BOLD)
	var fs: int = maxi(6, roundi(14.0 * f))
	var middle: float = (o.y + PC_ROOM_TOP + 2.0 + 14.0 * 0.55) * f
	var base: float = middle + (font.get_ascent(fs) - font.get_descent(fs)) / 2.0
	var text: String = LABEL_OFF if scene_off() else LABEL_ON
	var high: float = PC_PILL_H * f
	var rad: float = high / 2.0
	var r: float = rad - 2.5 * f
	var wide: float = rad + r + 4.0 * f + font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + rad * 0.9
	var right: float = (o.x + board.WIDE - PC_RIGHT) * f
	var pill: Rect2 = Rect2(Vector2(right - wide, middle - rad).round(), Vector2(wide, high).round())
	_pill(board, pill, f, font, fs, base, pill.has_point(mouse))
	board.touch_rects["pc_mute"] = spots
	board.touch_rects["pc_scene"] = pill


static func glyph_px(f: float) -> float:
	return 22.0 * maxf(f, 1.0)

static func chip_size(f: float) -> Vector2:
	return Vector2(maxf(PC_CHIP.x * f, glyph_px(f) + 6.0), PC_CHIP.y * f)

static func hit_size(f: float) -> Vector2:
	return Vector2(maxf(PC_HIT.x * f, 28.0), maxf(PC_HIT.y * f, 24.0))


static func _pick(spots: Array, at: Vector2) -> Array:
	var best: Array = []
	for spot: Array in spots:
		if (spot[2] as Rect2).has_point(at) and (best.is_empty() or (spot[1] as Vector2).distance_to(at) < (best[1] as Vector2).distance_to(at)):
			best = spot
	return best


static func _chip(board, c: Vector2, f: float, off: bool, hot: bool) -> void :
	var box: Rect2 = Rect2(c - chip_size(f) / 2.0, chip_size(f))
	var rad: float = box.size.y / 2.0
	if hot:
		VoiceUI.grad(board, box, rad, BTN_TOP, BTN_LOW, BTN_EDGE, maxf(1.0, 1.2 * f))
	else:
		VoiceUI.grad(board, box, rad, Color(0.1, 0.13, 0.2, 0.92), Color(0.05, 0.07, 0.12, 0.92), Color(BTN_EDGE, 0.25 if off else 0.6), maxf(1.0, f))
	var g: float = glyph_px(f) / 21.0
	var ink: Color = Color(1, 1, 1, 0.45 if off and not hot else 0.95)
	var o: Vector2 = c + Vector2(0, -1.0) * g
	VoiceUI.grad(board, Rect2(o + Vector2(-10.5, -6.0) * g, Vector2(21.0, 12.0) * g), 4.0 * g, ink, ink)
	board.draw_colored_polygon(PackedVector2Array([o + Vector2(-6.0, 5.5) * g, o + Vector2(-1.5, 5.5) * g, o + Vector2(-7.5, 8.5) * g]), ink)
	var dark: Color = BTN_LOW if hot else Color(0.07, 0.09, 0.15, 1.0)
	var s: Vector2 = o + Vector2(-1.0, 0.0) * g
	board.draw_rect(Rect2(s + Vector2(-5.0, -1.6) * g, Vector2(2.4, 3.2) * g), dark)
	board.draw_colored_polygon(PackedVector2Array([s + Vector2(-2.6, -1.6) * g, s + Vector2(1.0, -4.0) * g, s + Vector2(1.0, 4.0) * g, s + Vector2(-2.6, 1.6) * g]), dark)
	board.draw_arc(s + Vector2(1.6, 0) * g, 2.6 * g, -0.9, 0.9, 10, dark, 1.2 * g, true)
	board.draw_arc(s + Vector2(1.6, 0) * g, 4.9 * g, -0.85, 0.85, 12, dark, 1.2 * g, true)
	if off:
		var a: Vector2 = box.position + Vector2(rad * 0.75, box.size.y - 2.5 * f)
		var b: Vector2 = box.end - Vector2(rad * 0.75, box.size.y - 2.5 * f)
		board.draw_line(a, b, Color(0, 0, 0, 0.75), 4.0 * f, true)
		board.draw_line(a, b, Color("ff4d4d"), 2.2 * f, true)


static func grid_ink(board, lines: Array, r: int, column: int, ink: Color) -> Color:
	if column != 0 or board.client == null:
		return ink
	var battle = board.client.get("battle")
	if battle == null or battle.chat_muted.is_empty():
		return ink
	for side: int in [0, 1]:
		if is_same(lines, board._rows[side]) and r < board._lines[side].size():
			return Color(ink, ink.a * NAME_FADE) if battle.chat_muted.has(int(board._lines[side][r][6])) else ink
	return ink


static func touch_pill(panel: Rect2, k: float) -> Rect2:
	var bottom: float = maxf(T_BOTTOM_PX, 6.0 * k)
	var high: float = maxf(12.0, minf(T_PILL.y * k, (T_FOOT - 3.0) * k - bottom))
	var size: Vector2 = Vector2(T_PILL.x / T_PILL.y * high, high).round()
	var right: float = maxf(T_RIGHT_PX, T_PAD * k)
	return Rect2(Vector2(panel.end.x - right - size.x, panel.end.y - bottom - size.y).round(), size)


static func foot_y(panel: Rect2, k: float) -> float:
	return touch_pill(panel, k).get_center().y


static func paint_touch(board, battle) -> void :
	var panel: Rect2 = board.touch_rects.get("panel", Rect2())
	if panel.size.x <= 0.0:
		return
	var pill: Rect2 = touch_pill(panel, board._k)
	_pill(board, pill, board._k)
	board.touch_rects["scene"] = pill


static func quiet_horn(client: Object) -> bool:
	return client != null and str(client.get("state")) == "battle" and scene_off()



static func _pill(board, rect: Rect2, unit: float, font: Font = BOLD, size: int = 0, base: float = NAN, hot: bool = false) -> void :
	var off: bool = scene_off()
	var rad: float = rect.size.y / 2.0
	var top: Color = GOLD_TOP if off else BTN_TOP
	var low: Color = GOLD_LOW if off else BTN_LOW
	if hot:
		top = top.lightened(0.18)
		low = low.lightened(0.18)
	VoiceUI.grad(board, rect, rad, top, low, Color.WHITE if hot else (GOLD_EDGE if off else BTN_EDGE), maxf(1.0, (1.8 if hot else 1.2) * unit))
	var r: float = rad - 2.5 * unit
	var c: Vector2 = rect.position + Vector2(rad, rad)
	var k0: float = board._k
	board._k = r / T_MUTE_R
	board._mute_icon(c, r, off)
	board._k = k0
	var ink: Color = BTN_INK if off else ON_BLUE
	var x0: float = c.x + r + 4.0 * unit
	var wide: float = rect.end.x - rad * 0.6 - x0
	var fs: int = size if size > 0 else maxi(6, roundi(rect.size.y * 0.46))
	var text: String = LABEL_OFF if off else LABEL_ON
	while size <= 0 and fs > 6 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > wide:
		fs -= 1
	var at: Vector2 = Vector2(x0, base if not is_nan(base) else rect.get_center().y + (font.get_ascent(fs) - font.get_descent(fs)) / 2.0)
	if not off:
		board.draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_CENTER, wide, fs, maxi(1, roundi(2.0 * unit)), Color(0.03, 0.16, 0.35, 0.6))
	board.draw_string(font, at, text, HORIZONTAL_ALIGNMENT_CENTER, wide, fs, ink)


static func click_pc(board, at: Vector2) -> bool:
	if board == null or not board.visible or board.touch_mode() or board.client == null:
		return false
	var battle = board.client.get("battle")
	if battle == null:
		return false
	var pill: Rect2 = board.touch_rects.get("pc_scene", Rect2())
	if pill.size.x > 0.0 and pill.grow(2.0).has_point(at):
		set_scene(board, battle, not scene_off())
		return true
	var spot: Array = _pick(board.touch_rects.get("pc_mute", []), at)
	if spot.is_empty():
		return false
	toggle_person(board, battle, int(spot[0]), bool(spot[3]))
	return true


static func tap_touch(board, battle, at: Vector2) -> bool:
	var pill: Rect2 = board.touch_rects.get("scene", Rect2())
	if pill.size.x <= 0.0 or not pill.grow(6.0 * board._k).has_point(at):
		return false
	set_scene(board, battle, not scene_off())
	return true
