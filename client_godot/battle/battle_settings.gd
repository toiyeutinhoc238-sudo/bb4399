extends Control









const Settings = preload("res://settings.gd")
const DIR: String = "res://assets/hud/sysset/"
const FRAME: Vector2 = Vector2(726, 510)
const SUB: Vector2 = Vector2(164, 64)
const TABS: Array[String] = ["CHIẾN ĐẤU", "HÌNH ẢNH", "ÂM THANH", "KHÁC"]

const KEY_ROWS: Array = [
	[82, "Skill 1", Vector2(30, 137), Vector2(258, 136)], 
	[69, "Skill 2", Vector2(30, 160), Vector2(258, 160)], 
	[32, "Tuyệt Chiêu", Vector2(30, 185), Vector2(258, 184)], 
	[81, "Skill Guild", Vector2(30, 209), Vector2(258, 209)], 
	[1000, "Xạ Kích", Vector2(30, 232), Vector2(120, 235)], 
	[1001, "Tự động bắn", Vector2(30, 257), Vector2(120, 259)], 
	[71, "Thông tin trận", Vector2(30, 280), Vector2(120, 283)], 
	[70, "Phun Sơn Xe", Vector2(30, 306), Vector2(120, 307)], 
	[72, "Thuộc tính xe", Vector2(30, 331), Vector2(120, 332)], 
	[90, "Công", Vector2(210, 232), Vector2(300, 234)], 
	[88, "Rút Lui", Vector2(210, 257), Vector2(300, 259)], 
	[67, "Tập hợp", Vector2(210, 280), Vector2(300, 282)], 
	[66, "Về thành", Vector2(210, 306), Vector2(300, 307)], 
]

const SMART_ROWS: Array = [[[10], 131.0], [[1], 155.0], [[2], 180.0], [[4, 13], 204.0]]
const ALL_SMART: Array[int] = [1, 2, 3, 4, 10, 13]
const BLUE: Color = Color("1f78d0")
const ORANGE: Color = Color("f39020")
const LABEL: Color = Color("eff6fd")
const YELLOW: Color = Color("f8d06b")
const RULE_TIP: String = "Thi triển nhanh: bấm phím là ra chiêu ngay tại con trỏ chuột.\nTắt: bấm phím để chọn chiêu, bấm chuột trái để thả."

var view: Control
var client: Node
var tab: int = 0
var slots: Array[int] = []
var keys: Dictionary = {}
var _wait: int = -1
var _revert_armed: float = -1.0
var _hover: Vector2 = Vector2(-1, -1)
var _drag: String = ""
var _origin: Vector2 = Vector2.ZERO
var _s: float = 1.0
var _hit: Array = []
var _tex: Dictionary = {}
var _font: Font
var _bold: Font
var _clock: float = 0.0

func _init(owner_view: Control, font: Font, bold: Font) -> void :
	view = owner_view
	_font = font
	_bold = bold
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	set_anchors_preset(Control.PRESET_FULL_RECT)


const MOD_KEYS: Dictionary = {KEY_SHIFT: 16, KEY_CTRL: 17}



static func flash_key(keycode: int) -> int:
	if keycode >= KEY_KP_0 and keycode <= KEY_KP_9:
		return 96 + keycode - KEY_KP_0
	if MOD_KEYS.has(keycode):
		return int(MOD_KEYS[keycode])
	return keycode if keycode < 128 else 0


static func can_set(code: int) -> bool:
	if code >= 65 and code <= 90:
		return not code in [65, 68, 83, 87]
	return code in [16, 17, 32] or (code >= 48 and code <= 57) or (code >= 96 and code <= 105)


static func key_name(code: int) -> String:
	match code:
		0: return "--"
		16: return "Shift"
		17: return "Ctrl"
		32: return "Space"
		1000: return "Chuột trái"
		1001: return "Chuột phải"
		36: return "Home"
	if code >= 96 and code <= 105:
		return "Num %d" % (code - 96)
	if code >= 32 and code < 128:
		return char(code)
	return "--"

func open() -> void :
	client = view.client
	slots = client.smart_slots.duplicate()
	keys = client.key_map.duplicate() if not client.key_map.is_empty() else client._parse_key_map([])
	tab = 0
	_wait = -1
	_revert_armed = -1.0
	_drag = ""
	visible = true
	queue_redraw()


func close() -> void :
	if not visible:
		return
	_wait = -1
	if _unset():
		if _revert_armed < _clock:
			_revert_armed = _clock + 4.0
			return
		keys = client.key_map.duplicate() if not client.key_map.is_empty() else client._parse_key_map([])
	var sorted_slots: Array[int] = slots.duplicate()
	sorted_slots.sort()
	var old_slots: Array[int] = client.smart_slots.duplicate()
	old_slots.sort()
	var old_keys: Dictionary = client.key_map if not client.key_map.is_empty() else client._parse_key_map([])
	if sorted_slots != old_slots or not keys.recursive_equal(old_keys, 1):
		client.save_char_option(sorted_slots, keys)
	if not _drag.is_empty():
		Settings.save()
		_drag = ""
	visible = false

func _unset() -> bool:
	for row: Array in KEY_ROWS:
		if int(keys.get(int(row[0]), row[0])) == 0:
			return true
	return false

func smart_on(row: int) -> bool:
	for slot: int in SMART_ROWS[row][0]:
		if slot in slots:
			return true
	return false

func set_smart(row: int, on: bool) -> void :
	for slot: int in SMART_ROWS[row][0]:
		slots.erase(slot)
		if on:
			slots.append(slot)


func reset() -> void :
	var extra: Dictionary = {}
	for action: int in keys:
		if not action in client.KEY_DEFAULT and not int(keys[action]) in client.KEY_DEFAULT:
			extra[action] = keys[action]
	keys = client._parse_key_map([])
	keys.merge(extra)
	slots = ALL_SMART.duplicate()
	_wait = -1
	_revert_armed = -1.0


func bind(action: int, code: int) -> void :
	for other: int in keys:
		if other != action and int(keys[other]) == code:
			keys[other] = 0
	keys[action] = code
	_revert_armed = -1.0

func key(event: InputEventKey) -> void :
	if _wait >= 0:
		var code: int = flash_key(event.physical_keycode)
		if event.physical_keycode != KEY_ESCAPE and can_set(code):
			bind(_wait, code)
		_wait = -1
		return
	if event.physical_keycode == KEY_ESCAPE:
		close()

func tex(name: String) -> Texture2D:
	if not _tex.has(name):
		var path: String = DIR + name + ".png"
		var texture: Texture2D = null
		if ResourceLoader.exists(path):
			texture = load(path)
		else:
			var image: Image = Image.load_from_file(ProjectSettings.globalize_path(path))
			if image != null and not image.is_empty():
				texture = ImageTexture.create_from_image(image)
		_tex[name] = texture
	return _tex[name]

func _process(delta: float) -> void :
	_clock += delta
	if not visible:
		return
	if client == null or client.battle.ended or not client.battle.active:
		_wait = -1
		visible = false
		return
	queue_redraw()

func _frame_point(screen: Vector2) -> Vector2:
	return (screen - _origin) / _s

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		_hover = _frame_point(event.position)
		if not _drag.is_empty():
			_slide(_drag, _hover, false)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var point: Vector2 = _frame_point(event.position)
		if event.pressed:
			_click(point)
		elif not _drag.is_empty():
			_slide(_drag, point, true)
			_drag = ""
	accept_event()

func _click(point: Vector2) -> void :
	var picked: String = ""
	for item: Array in _hit:
		if (item[0] as Rect2).has_point(point):
			picked = str(item[1])
	if _wait >= 0 and not picked.begins_with("key:"):
		_wait = -1
	if picked.is_empty():
		return
	var part: PackedStringArray = picked.split(":")
	match part[0]:
		"tab":
			tab = int(part[1])
			_wait = -1
		"close", "confirm":
			close()
		"vote":
			client.request_surrender()
			close()
		"key":
			_wait = -1 if _wait == int(part[1]) else int(part[1])
		"smart":
			set_smart(int(part[1]), not smart_on(int(part[1])))
		"common":
			slots.clear()
		"intelligent":
			slots = ALL_SMART.duplicate()
		"reset":
			reset()
		"set":
			Settings.put(part[1], not Settings.on(part[1]))
		"slider":
			_drag = part[1]
			_slide(_drag, point, false)
		"touch":
			view._touch = not view._touch
			view.controls.clear()
		"auto":
			view.controls.auto_fire = not view.controls.auto_fire
		"zoom":
			view.camera_zoom = clampf(roundf((view.camera_zoom + float(part[1]) / 10.0) * 10.0) / 10.0, 1.0, 2.0)

const SLIDER_X: float = 200.0
const SLIDER_W: float = 230.0

func _slide(key_name: String, point: Vector2, store: bool) -> void :
	var value: float = clampf((point.x - SUB.x - SLIDER_X) / SLIDER_W, 0.0, 1.0)
	Settings.put(key_name, snappedf(value, 0.01), store)



func _draw() -> void :
	_hit.clear()
	var hud_scale: float = view._hud.layout_scale()
	_s = minf(hud_scale, minf(size.x / (FRAME.x + 24), size.y / (FRAME.y + 24)))
	_origin = ((size - FRAME * _s) / 2).floor()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	draw_set_transform(_origin, 0, Vector2(_s, _s))
	_pic("bg", Vector2.ZERO)
	_pic("inner", Vector2(163, 63))
	_text(Vector2(290, 22), "CÀI ĐẶT", Color.WHITE, 18, HORIZONTAL_ALIGNMENT_CENTER, 146)
	_close_button(Rect2(684, 12, 30, 30))
	for i in range(TABS.size()):
		_button(Rect2(30, 119 + 55 * i, 122, 44), TABS[i], "tab:%d" % i, i == tab, 15)
	match tab:
		0: _draw_battle()
		1: _draw_picture()
		2: _draw_audio()
		3: _draw_other()
	_draw_bottom()
	draw_set_transform(Vector2.ZERO)

func _draw_bottom() -> void :
	var battle = client.battle
	if battle.started and battle.supported():

		var now: float = battle.now_seconds()
		var wait: int = ceili(battle.vote_next - now)
		var busy: bool = wait > 0 or ( not battle.vote.is_empty() and battle.vote.end > now)
		_button(Rect2(300, 455, 140, 36), ("Đầu Hàng (%ds)" % wait) if wait > 0 else "Đầu Hàng", "" if busy else "vote", false, 15, busy)
	_button(Rect2(585, 455, 110, 36), "Xác nhận", "confirm", true, 16)
	if _revert_armed > _clock:
		_text(Vector2(40, 462), "Còn phím chưa đặt — bấm đóng lần nữa để bỏ đổi phím", Color("ff5a4a"), 13, HORIZONTAL_ALIGNMENT_LEFT, 250)

func _draw_battle() -> void :
	_pic("word_battle_setting_t", SUB + Vector2(20, 9))
	_button(Rect2(SUB + Vector2(531 - 20 - 96, 7), Vector2(96, 28)), "Mặc định", "reset", false, 13)
	_pic("battle_set_inner1", SUB + Vector2(40, 49))
	_pic("battle_btn_bg", SUB + Vector2(146, 60))
	_text(SUB + Vector2(50, 66), "Kiểu thi triển", LABEL, 13, HORIZONTAL_ALIGNMENT_LEFT, 92)
	var all_on: bool = true
	var all_off: bool = true
	for row in range(SMART_ROWS.size()):
		all_on = all_on and smart_on(row)
		all_off = all_off and not smart_on(row)
	_button(Rect2(SUB + Vector2(148, 61), Vector2(148, 30)), "Thi triển thường", "common", all_off, 13)
	_button(Rect2(SUB + Vector2(298, 61), Vector2(150, 30)), "Thi triển nhanh", "intelligent", all_on, 13)
	_pic("key_board_set_t", SUB + Vector2(265, 112))
	_pic("word_open_intelligent_t", SUB + Vector2(335, 111))
	var rule: Rect2 = Rect2(SUB + Vector2(428, 108), Vector2(22, 22))
	_pic("ruleHint", rule.position)
	_pic("battle_set_inner2", SUB + Vector2(23, 134))
	for row: Array in KEY_ROWS:
		var action: int = int(row[0])
		_text(SUB + row[2], str(row[1]), LABEL, 13, HORIZONTAL_ALIGNMENT_LEFT, 88)
		var box: Rect2 = Rect2(SUB + row[3], Vector2(75, 21))
		var mouse_row: bool = action >= 1000
		var waiting: bool = _wait == action
		var code: int = int(keys.get(action, action))
		draw_rect(box, Color("ffb54a") if waiting else Color(0.02, 0.16, 0.35, 0.9))
		draw_rect(box, Color("8fd3ff") if not mouse_row else Color(0.55, 0.7, 0.85), false, 1.0)
		var shown: String = ("…" if fmod(_clock, 0.8) < 0.5 else "") if waiting else key_name(code)
		_text(box.position + Vector2(0, 1), shown, Color("ff6a5a") if code == 0 and not waiting else Color.WHITE, 12, HORIZONTAL_ALIGNMENT_CENTER, box.size.x)
		if not mouse_row:
			_hit.append([box, "key:%d" % action])
	for row in range(SMART_ROWS.size()):
		_check(Vector2(SUB.x + 364, SUB.y + float(SMART_ROWS[row][1]) + 1), smart_on(row), "smart:%d" % row)
	if _unset():
		_text(SUB + Vector2(400, 268), "Có phím\nchưa đặt", Color("ff5a4a"), 13, HORIZONTAL_ALIGNMENT_LEFT, 120)
	elif _wait >= 0:
		_text(SUB + Vector2(400, 268), "Bấm phím mới\n(Esc: huỷ)", YELLOW, 13, HORIZONTAL_ALIGNMENT_LEFT, 120)
	if rule.has_point(_hover):
		var tip: Rect2 = Rect2(SUB + Vector2(150, 132), Vector2(330, 52))
		draw_rect(tip, Color(0.02, 0.08, 0.2, 0.94))
		draw_rect(tip, Color("8fd3ff"), false, 1.0)
		_text(tip.position + Vector2(8, 6), RULE_TIP, Color.WHITE, 12, HORIZONTAL_ALIGNMENT_LEFT, tip.size.x - 16, false)

func _draw_picture() -> void :
	_heading("HÌNH ẢNH")
	var rows: Array = [["numbers", "Số sát thương"], ["fps", "Hiện FPS"], ["skill_fx", "Hiệu ứng chiêu"], ["skill_name", "Tên chiêu"]]
	for i in range(rows.size()):
		_check_row(SUB + Vector2(60, 60 + 44 * i), str(rows[i][1]), Settings.on(str(rows[i][0])), "set:" + str(rows[i][0]))
	var y: float = SUB.y + 60 + 44 * rows.size() + 8
	_text(Vector2(SUB.x + 60, y + 4), "Thu phóng", LABEL, 15, HORIZONTAL_ALIGNMENT_LEFT, 120)
	_button(Rect2(SUB.x + 200, y, 36, 30), "−", "zoom:-1", false, 18)
	_text(Vector2(SUB.x + 240, y + 4), "%d%%" % roundi(view.camera_zoom * 100), Color.WHITE, 15, HORIZONTAL_ALIGNMENT_CENTER, 70)
	_button(Rect2(SUB.x + 314, y, 36, 30), "+", "zoom:1", false, 18)
	_text(Vector2(SUB.x + 60, y + 40), "Lăn chuột trong trận cũng đổi được (100–200 %).", Color(LABEL, 0.75), 12, HORIZONTAL_ALIGNMENT_LEFT, 400, false)

func _draw_audio() -> void :
	_heading("ÂM THANH")
	_check_row(SUB + Vector2(60, 60), "Mở nhạc", Settings.on("music"), "set:music")
	_slider(SUB.y + 96, "music_vol", Settings.on("music"))
	_check_row(SUB + Vector2(60, 150), "Mở âm thanh hiệu ứng", Settings.on("sfx"), "set:sfx")
	_slider(SUB.y + 186, "sfx_vol", Settings.on("sfx"))
	_check_row(SUB + Vector2(60, 240), "Giọng báo hạ gục", Settings.on("voice"), "set:voice")

func _draw_other() -> void :
	_heading("KHÁC")
	_check_row(SUB + Vector2(60, 60), "Điều khiển cảm ứng", view._touch, "touch")
	_text(SUB + Vector2(92, 88), "Cần điều khiển + nút chiêu trên màn hình (điện thoại, máy tính bảng).", Color(LABEL, 0.75), 12, HORIZONTAL_ALIGNMENT_LEFT, 400, false)
	_check_row(SUB + Vector2(60, 124), "Tự động bắn", view.controls.auto_fire, "auto")
	_text(SUB + Vector2(92, 152), "Như bấm chuột phải trong trận: xe tự bắn liên tục.", Color(LABEL, 0.75), 12, HORIZONTAL_ALIGNMENT_LEFT, 400, false)

func _heading(title: String) -> void :
	_text(SUB + Vector2(20, 12), title, Color.WHITE, 17, HORIZONTAL_ALIGNMENT_LEFT, 300)

func _slider(y: float, key_name: String, enabled: bool) -> void :
	var track: Rect2 = Rect2(SUB.x + SLIDER_X, y + 8, SLIDER_W, 8)
	var value: float = Settings.level(key_name)
	_text(Vector2(SUB.x + 92, y), "Âm lượng", Color(LABEL, 1.0 if enabled else 0.5), 13, HORIZONTAL_ALIGNMENT_LEFT, 100)
	draw_rect(track, Color(0.02, 0.12, 0.28, 0.95))
	draw_rect(Rect2(track.position, Vector2(track.size.x * value, track.size.y)), ORANGE if enabled else Color(0.5, 0.5, 0.5))
	draw_circle(track.position + Vector2(track.size.x * value, track.size.y / 2), 9.0, Color.WHITE)
	draw_circle(track.position + Vector2(track.size.x * value, track.size.y / 2), 9.0, BLUE, false, 2.0, true)
	_text(Vector2(track.end.x + 16, y), "%d%%" % roundi(value * 100), Color.WHITE, 13, HORIZONTAL_ALIGNMENT_LEFT, 60)
	_hit.append([track.grow_individual(10, 10, 10, 10), "slider:" + key_name])

func _check_row(pos: Vector2, text: String, on: bool, id: String) -> void :
	_check(pos, on, id)
	_text(pos + Vector2(32, 0), text, LABEL, 15, HORIZONTAL_ALIGNMENT_LEFT, 360)
	_hit.append([Rect2(pos + Vector2(28, -2), Vector2(260, 26)), id])


func _check(pos: Vector2, on: bool, id: String) -> void :
	var box: Rect2 = Rect2(pos, Vector2(20, 20))
	draw_rect(box, ORANGE if on else Color(0.95, 0.97, 1.0))
	draw_rect(box, Color("0c3d78"), false, 1.5)
	if on:
		draw_polyline(PackedVector2Array([pos + Vector2(4, 10), pos + Vector2(8.5, 15), pos + Vector2(16, 5)]), Color.WHITE, 3.0, true)
	_hit.append([box.grow(3), id])


func _button(rect: Rect2, text: String, id: String, chosen: bool, size_px: int, disabled: bool = false) -> void :
	var fill: Color = ORANGE if chosen else BLUE
	if disabled:
		fill = Color(0.35, 0.42, 0.5)
	elif rect.has_point(_hover):
		fill = fill.lightened(0.14)
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = fill
	box.set_corner_radius_all(7)
	box.set_border_width_all(2)
	box.border_color = Color("fff3c0") if chosen else Color("a6e6ff")
	draw_style_box(box, rect)
	_text(Vector2(rect.position.x, rect.position.y + (rect.size.y - size_px) / 2 - 3), text, Color("fffdf2"), size_px, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x)
	if not id.is_empty():
		_hit.append([rect, id])

func _close_button(rect: Rect2) -> void :
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color("e2483a").lightened(0.12 if rect.has_point(_hover) else 0.0)
	box.set_corner_radius_all(15)
	box.set_border_width_all(2)
	box.border_color = Color.WHITE
	draw_style_box(box, rect)
	var c: Vector2 = rect.get_center()
	draw_line(c + Vector2(-6, -6), c + Vector2(6, 6), Color.WHITE, 3.0, true)
	draw_line(c + Vector2(6, -6), c + Vector2(-6, 6), Color.WHITE, 3.0, true)
	_hit.append([rect.grow(4), "close"])

func _pic(name: String, pos: Vector2) -> void :
	var texture: Texture2D = tex(name)
	if texture != null:
		draw_texture(texture, pos)


func _text(pos: Vector2, text: String, color: Color, size_px: int, align: HorizontalAlignment, width: float, heavy: bool = true) -> void :
	var font: Font = _bold if heavy else _font
	var lines: PackedStringArray = text.split("\n")
	var px: int = size_px
	for line: String in lines:
		var w: float = font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		if width > 0 and w > width:
			px = maxi(9, floori(px * width / w))
	for i in range(lines.size()):
		var base: Vector2 = pos + Vector2(0, px + 1 + i * (px + 4))
		draw_string_outline(font, base, lines[i], align, width, px, 3, Color(0, 0, 0, color.a * 0.85))
		draw_string(font, base, lines[i], align, width, px, color)
