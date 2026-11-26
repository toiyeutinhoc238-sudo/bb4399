extends RefCounted
























const Settings = preload("res://settings.gd")
const St2Skin = preload("res://ui/st2_skin.gd")
const STAGE: Vector2 = Vector2(1266, 600)
const KEYS: Array[String] = ["fire", "auto", "b0", "b1", "b2", "b3", "b4", "stick", "zoom", "ping", "chat"]
const K_MIN: float = 0.8
const K_MAX: float = 1.3
const K_LOW: float = 0.6
const EDGE: float = 24.0
const SLOTS: int = 3
const PAD_DEFAULT: int = 40
const PAD_SKILL: Vector2 = Vector2(-1.2, 0.0)
const PAD_STICK: Vector2 = Vector2(1.2, -0.6)
const BAR_H: float = 156.0


const SETTINGS_READS: Array[String] = ["tc_btn_scale", "tc_btn_alpha", "tc_layout", "tc_layout_0", "tc_layout_1", "tc_layout_2", 
	"tc_mm_side", "tc_mm_scale", "tc_target_info", "tc_tips", "tc_chat", "tc_pad_skill", "tc_pad_stick"]




const TARGET_SHOW: float = 3.0

static var forced: Dictionary = {}

static var editing: Variant = null
static var _src: String = ""
static var _parsed: Dictionary = {}
static var _scale: float = -1.0

const V1_RE_SHIFT: Vector2 = Vector2(74.5, -65)

const CLUSTER: Array[String] = ["fire", "auto", "b0", "b1", "b2", "b3", "b4"]


const V2_HOME: Dictionary = {"auto": [Vector2(-92, 66), 26.0], "b0": [Vector2(-137, -82), 42.0], "b1": [Vector2(-62.5, -147), 42.0], 
	"b2": [Vector2(36, -156), 48.0], "b3": [Vector2(-159.4, 14), 38.0], "b4": [Vector2(-236, -120), 38.0]}
const V3_HOME: Dictionary = {"auto": [Vector2(-131, 48), 26.0], "b0": [Vector2(-249, 22), 52.5], "b1": [Vector2(-159, -133), 52.5], 
	"b2": [Vector2(-4, -223), 52.5], "b3": [Vector2(-400, 24), 38.0], "b4": [Vector2(-520, 24), 38.0]}

static func pref(key: String, fallback: Variant) -> Variant:
	if forced.has(key):
		return forced[key]
	var v: Variant = Settings.value(key)
	return fallback if v == null else v

static func unit(size: Vector2) -> float:
	return minf(size.x / STAGE.x, size.y / STAGE.y)

static func slot() -> int:
	return clampi(int(pref("tc_layout", 0)), 0, SLOTS - 1)


static func parse(text: String) -> Dictionary:
	var out: Dictionary = {}
	if text.is_empty():
		return out
	var data: Variant = JSON.parse_string(text)
	if not (data is Dictionary) or not (int(data.get("v", 0)) in [1, 2, 3]) or not (data.get("e") is Dictionary):
		return out
	var e: Dictionary = data.e
	for key: String in KEYS:
		var row: Variant = e.get(key)
		if not (row is Array) or row.size() != 3:
			continue
		var ok: bool = true
		for n: Variant in row:
			if not (n is float or n is int) or not is_finite(float(n)):
				ok = false
		if not ok:
			continue
		var off: Vector2 = Vector2(clampf(float(row[0]), - STAGE.x, STAGE.x), clampf(float(row[1]), - STAGE.y, STAGE.y))
		out[key] = [off, clampf(float(row[2]), K_MIN if int(data.v) < 3 else K_LOW, K_MAX)]
	if int(data.v) == 1 and (out.has("b0") or out.has("b1")):
		var shift: Vector2 = V1_RE_SHIFT * scale()
		var row_r: Array = out.get("b0", [Vector2.ZERO, 1.0])
		var row_e: Array = out.get("b1", [Vector2.ZERO, 1.0])
		out["b0"] = [(row_r[0] as Vector2) + shift, row_r[1]]
		out["b1"] = [(row_e[0] as Vector2) - shift, row_e[1]]
	if int(data.v) < 3:
		var custom: bool = false
		for key: String in CLUSTER:
			custom = custom or out.has(key)
		if custom:
			for key: String in V2_HOME:
				var row: Array = out.get(key, [Vector2.ZERO, 1.0])
				var keep: Vector2 = ((V2_HOME[key][0] as Vector2) - (V3_HOME[key][0] as Vector2)) * scale()
				out[key] = [(row[0] as Vector2) + keep, clampf(float(row[1]) * float(V2_HOME[key][1]) / float(V3_HOME[key][1]), K_LOW, K_MAX)]
	return out


static func encode(entries: Dictionary) -> String:
	var e: Dictionary = {}
	for key: String in KEYS:
		if not entries.has(key):
			continue
		var off: Vector2 = entries[key][0]
		var k: float = snappedf(clampf(float(entries[key][1]), K_LOW, K_MAX), 0.05)
		off = Vector2(snappedf(off.x, 0.1), snappedf(off.y, 0.1))
		if off == Vector2.ZERO and is_equal_approx(k, 1.0):
			continue
		e[key] = [off.x, off.y, k]
	return "" if e.is_empty() else JSON.stringify({"v": 3, "e": e})


static func layout() -> Dictionary:
	if editing != null:
		return editing.e
	var src: String = str(pref("tc_layout_%d" % slot(), ""))
	var sc: float = scale()
	if src != _src or sc != _scale:
		_src = src
		_scale = sc
		_parsed = parse(src)
	return _parsed


static func at(key: String, size: Vector2, home: Vector2) -> Vector2:
	var row: Variant = layout().get(key)
	if row == null or (row[0] as Vector2) == Vector2.ZERO:
		return home
	var u: float = unit(size)
	var p: Vector2 = home + (row[0] as Vector2) * u
	var m: float = minf(EDGE * u, minf(size.x, size.y) / 2.0)
	return Vector2(clampf(p.x, m, size.x - m), clampf(p.y, m, size.y - m))


static func mm_right() -> bool:
	return str(pref("tc_mm_side", "left")) == "right"


static func mm_scale() -> float:
	return mm_base() * map_zoom


static func mm_base() -> float:
	return clampf(float(pref("tc_mm_scale", 100)) / 100.0, K_MIN, K_MAX)



static var map_zoom: float = 1.0

static func target_info() -> bool:
	return bool(pref("tc_target_info", false))

static func tips_on() -> bool:
	return bool(pref("tc_tips", true))

static func chat_on() -> bool:
	return bool(pref("tc_chat", true))


static func scale() -> float:
	return clampf(float(pref("tc_btn_scale", 100)) / 100.0, K_MIN, K_MAX)


static func k(key: String) -> float:
	var row: Variant = layout().get(key)
	var own: float = float(row[1]) if row != null else 1.0
	return own if key == "stick" else scale() * own


static func pad(which: String) -> float:
	var key: String = "tc_pad_" + which
	if editing != null and (editing as Dictionary).has(key):
		return clampf(float(editing[key]), 0.0, 100.0)
	return clampf(float(pref(key, PAD_DEFAULT)), 0.0, 100.0)


static func pad_shift(which: String) -> Vector2:
	return (PAD_STICK if which == "stick" else PAD_SKILL) * pad(which)


static func alpha() -> float:
	if editing != null:
		return float(editing.a)
	return clampf(float(pref("tc_btn_alpha", 100)) / 100.0, 0.3, 1.0)


static func fade(c: Color, a: float) -> Color:
	return Color(c, c.a * a)



static func set_editing(value: Variant) -> void :
	editing = value

static func open_layout_editor(host: Node) -> void :
	if host == null or not host.is_inside_tree():
		return
	var root: Window = host.get_tree().root
	for old: Node in root.get_children():
		if old.name == "TouchLayoutEditor":
			return
	var layer: CanvasLayer = CanvasLayer.new()
	layer.name = "TouchLayoutEditor"
	layer.layer = 120
	var ed: Editor = Editor.new()
	ed.name = "Editor"
	layer.add_child(ed)
	root.add_child(layer)


class Editor extends Control:
	const KIT_BG: Color = Color("061a33")
	const COLUMN: Array[String] = ["zoom", "ping", "chat"]
	const PICK: Color = Color("ffb630")
	const NAMES: Dictionary = {"fire": "BẮN", "auto": "TỰ BẮN", "b0": "R", "b1": "E", "b2": "SPACE", "b3": "Q", "b4": "B", "stick": "DI CHUYỂN", 
		"zoom": "BẢN ĐỒ", "ping": "PING", "chat": "CHAT"}
	const LABEL_OF: Dictionary = {"fire": "Nút Bắn", "auto": "Nút Tự bắn", "b0": "Chiêu R", "b1": "Chiêu E", "b2": "Chiêu SPACE", 
		"b3": "Chiêu Q", "b4": "Chiêu B", "stick": "Cần di chuyển", "zoom": "Nút thu phóng bản đồ", "ping": "Nút Ping nhanh", "chat": "Nút Chat lẹ"}
	var lq: Script = null
	var qp: Script = null
	var L = null
	var drafts: Array = []
	var view_slot: int = 0
	var a: float = 1.0
	var pick: String = "fire"
	var grab: String = ""
	var grab_from: Vector2 = Vector2.ZERO
	var grab_off: Vector2 = Vector2.ZERO
	var moved: bool = false
	var touch_id: int = -1
	var hits: Array = []
	var saved: bool = false
	var pads: Dictionary = {"skill": PAD_DEFAULT, "stick": PAD_DEFAULT}
	var slider: String = ""
	var tracks: Dictionary = {}

	func _ready() -> void :
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		resized.connect(queue_redraw)
		mouse_filter = Control.MOUSE_FILTER_STOP
		lq = load("res://battle/touch_lq.gd")
		qp = load("res://battle/quick_ping.gd")
		L = load("res://battle/touch_layout.gd")
		drafts.clear()
		for i in range(SLOTS):
			drafts.append(L.parse(str(L.pref("tc_layout_%d" % i, ""))))
		view_slot = L.slot()
		a = clampf(float(L.pref("tc_btn_alpha", 100)) / 100.0, 0.3, 1.0)
		for which: String in pads:
			pads[which] = clampi(int(L.pref("tc_pad_" + which, PAD_DEFAULT)), 0, 100)
		_sync()

	func _exit_tree() -> void :
		if L != null:
			L.set_editing(null)

	func _sync() -> void :
		L.set_editing({"e": drafts[view_slot], "a": a, "tc_pad_skill": pads.skill, "tc_pad_stick": pads.stick})
		queue_redraw()

	func _u() -> float:
		return L.unit(size)


	func shape(key: String) -> Array:
		match key:
			"fire":
				return [lq.fire_center(size), lq.fire_r(size)]
			"auto":
				return [lq.auto_center(size), lq.auto_r(size)]
			"stick":
				return [lq.stick_idle(size), lq.stick_r(size)]
			"zoom", "ping", "chat":
				var box: Rect2 = qp.button_rect(size, key)
				return [box.get_center(), box.size.x / 2.0]
		return lq.button(size, int(key.substr(1)))

	func home(key: String) -> Vector2:
		return qp.home(size, key) if key in ["zoom", "ping", "chat"] else lq.home(size, key)

	func element_at(p: Vector2) -> String:
		var best: String = ""
		var best_d: float = INF
		for key: String in KEYS:
			var s: Array = shape(key)
			var d: float = p.distance_to(s[0])
			if d <= maxf(float(s[1]) * 1.15, 30.0 * _u()) and d < best_d:
				best = key
				best_d = d
		return best


	func _input(event: InputEvent) -> void :
		if not is_visible_in_tree():
			return
		if event.is_action_pressed("ui_cancel"):
			close(false)
			get_viewport().set_input_as_handled()
			return
		if event is InputEventScreenTouch:
			if event.pressed and touch_id < 0:
				touch_id = event.index
				touch_down(event.position)
			elif not event.pressed and event.index == touch_id:
				touch_id = -1
				touch_up(event.position)
			get_viewport().set_input_as_handled()
		elif event is InputEventScreenDrag:
			if event.index == touch_id:
				touch_move(event.position)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouse and event.device != InputEvent.DEVICE_ID_EMULATION:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed:
					touch_down(event.position)
				else:
					touch_up(event.position)
			elif event is InputEventMouseMotion and (grab != "" or slider != ""):
				touch_move(event.position)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouse:
			get_viewport().set_input_as_handled()

	func _notification(what: int) -> void :
		if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_inside_tree():
			close(false)

	func touch_down(p: Vector2) -> void :
		for h: Array in hits:
			if (h[0] as Rect2).has_point(p):
				if str(h[1]).begins_with("pad:"):
					slider = str(h[1]).substr(4)
					slide_to(p)
					return
				press_bar(str(h[1]))
				return
		var key: String = element_at(p)
		if key != "":
			pick = key
			grab = key
			grab_from = p
			grab_off = (drafts[view_slot].get(key, [Vector2.ZERO, 1.0])[0] as Vector2)
			moved = false
		queue_redraw()

	func touch_move(p: Vector2) -> void :
		if slider != "":
			slide_to(p)
			return
		if grab == "":
			return
		var u: float = _u()
		if u <= 0.0:
			return
		var row: Array = drafts[view_slot].get(grab, [Vector2.ZERO, 1.0]).duplicate()
		var want: Vector2 = home(grab) + grab_off * u + (p - grab_from)
		var m: float = minf(EDGE * u, minf(size.x, size.y) / 2.0)
		want = Vector2(clampf(want.x, m, size.x - m), clampf(want.y, m, size.y - m))
		row[0] = (want - home(grab)) / u
		drafts[view_slot][grab] = row
		moved = true
		_sync()

	func touch_up(_p: Vector2) -> void :
		grab = ""
		slider = ""
		queue_redraw()


	func slide_to(p: Vector2) -> void :
		var r: Rect2 = tracks.get(slider, Rect2())
		if r.size.x <= 0.0:
			return
		pads[slider] = roundi(clampf((p.x - r.position.x) / r.size.x, 0.0, 1.0) * 20.0) * 5
		_sync()

	func press_bar(id: String) -> void :
		if id.begins_with("slot:"):
			view_slot = clampi(int(id.substr(5)), 0, SLOTS - 1)
		elif id == "reset":
			drafts[view_slot] = {}
			pads = {"skill": PAD_DEFAULT, "stick": PAD_DEFAULT}
		elif id == "k-" or id == "k+":
			var row: Array = drafts[view_slot].get(pick, [Vector2.ZERO, 1.0]).duplicate()
			row[1] = clampf(snappedf(float(row[1]) + (0.05 if id == "k+" else -0.05), 0.05), minf(K_MIN, float(row[1])), K_MAX)
			drafts[view_slot][pick] = row
		elif id == "a-" or id == "a+":
			a = clampf(snappedf(a + (0.05 if id == "a+" else -0.05), 0.05), 0.3, 1.0)
		elif id == "save":
			save()
			close(true)
			return
		elif id == "exit":
			close(false)
			return
		_sync()


	func save() -> void :
		for i in range(SLOTS):
			Settings.put("tc_layout_%d" % i, L.encode(drafts[i]), false)
		Settings.put("tc_layout", view_slot, false)
		Settings.put("tc_btn_alpha", roundi(a * 100.0 / 5.0) * 5, false)
		Settings.put("tc_pad_skill", int(pads.skill), false)
		Settings.put("tc_pad_stick", int(pads.stick), false)
		Settings.save()
		saved = true

	func close(_kept: bool) -> void :
		if L != null:
			L.set_editing(null)
		var layer: Node = get_parent()
		if layer != null and layer.name == "TouchLayoutEditor":
			layer.queue_free()
		else:
			queue_free()


	func _draw() -> void :
		var u: float = _u()
		if u <= 0.0:
			return
		draw_rect(Rect2(Vector2.ZERO, size), Color(KIT_BG, 0.86))
		var grid: Color = Color(1, 1, 1, 0.05)
		var step: float = 50.0 * u
		var x: float = step
		while x < size.x:
			draw_line(Vector2(x, 0), Vector2(x, size.y), grid, 1.0)
			x += step
		var y: float = step
		while y < size.y:
			draw_line(Vector2(0, y), Vector2(size.x, y), grid, 1.0)
			y += step
		var f: float = u
		for key: String in KEYS:
			if not key in COLUMN:
				_element(key, u)
		_bar(u, f)
		for key: String in COLUMN:
			_element(key, u)

	func _element(key: String, u: float) -> void :
		var s: Array = shape(key)
		var c: Vector2 = s[0]
		var r: float = s[1]
		var col: Color = Color.WHITE
		if key == "fire":
			col = lq.FIRE_COLOR
		elif key == "auto":
			col = lq.AUTO_COLOR
		elif key.begins_with("b"):
			col = lq.BUTTONS[int(key.substr(1))][2]
		if key == "stick":
			draw_circle(c, r, Color(0, 0, 0, 0.22 * a))
			draw_arc(c, r, 0, TAU, 64, Color(1, 1, 1, 0.55 * a), 3.0 * u, true)
			draw_circle(c, lq.knob_r(size), Color(1, 1, 1, 0.5 * a))
		else:
			draw_circle(c, r, Color(0.04, 0.06, 0.1, 0.75 * a))
			if key == "fire":
				draw_circle(c, r, L.fade(lq.FIRE_FACE, a))
			draw_arc(c, r, 0, TAU, 48, Color(col, 0.85 * a), 3.0 * u, true)
		var px: float = clampf(r * 0.42, 10.0 * u, 22.0 * u) if key != "stick" else 18.0 * u
		St2Skin.words(self, St2Skin.XBOLD, NAMES[key], px, Rect2(c - Vector2(r, px), Vector2(r * 2, px * 2)), Color(1, 1, 1, maxf(0.5, a)), 
			"c", Color(0, 0, 0, 0.8), 3.0 * u)
		if key == pick:
			var ring: float = r + 6.0 * u
			var n: int = 24
			for i in range(n):
				if i % 2 == 0:
					draw_arc(c, ring, TAU * i / n, TAU * (i + 1) / n, 6, PICK, 3.0 * u, true)


	func _pad_slider(which: String, label: String, box: Rect2, u: float, _f: float) -> void :
		var lw: float = 220.0 * u
		St2Skin.words(self, St2Skin.SEMI, label, 17.0 * u, Rect2(box.position, Vector2(lw, box.size.y)), Color("a7c4e2"), "l")
		var vw: float = 64.0 * u
		var track: Rect2 = Rect2(box.position.x + lw + 14.0 * u, box.get_center().y - 4.0 * u, maxf(40.0 * u, box.size.x - lw - vw - 40.0 * u), 8.0 * u)
		tracks[which] = track
		var t: float = float(pads[which]) / 100.0
		draw_rect(track, Color(1, 1, 1, 0.18))
		draw_rect(Rect2(track.position, Vector2(track.size.x * t, track.size.y)), Color("3fb1f5"))
		var knob: Vector2 = Vector2(track.position.x + track.size.x * t, track.get_center().y)
		draw_circle(knob, 13.0 * u, PICK if slider == which else Color.WHITE)
		draw_arc(knob, 13.0 * u, 0, TAU, 24, Color(0, 0, 0, 0.5), 2.0 * u, true)
		St2Skin.words(self, St2Skin.XBOLD, "%d %%" % int(pads[which]), 18.0 * u, Rect2(track.end.x + 26.0 * u, box.position.y, vw, box.size.y), 
			Color.WHITE, "l")
		hits.append([Rect2(track.position.x - 16.0 * u, box.position.y - 4.0 * u, track.size.x + 32.0 * u, box.size.y + 8.0 * u), "pad:" + which])

	func _btn(r: Rect2, f: float, kind: String, text: String, id: String, px: float = 15.0) -> void :
		St2Skin.button(self, r, f, kind, text, px)
		hits.append([r, id])

	func _bar(u: float, f: float) -> void :
		hits.clear()
		var top: Rect2 = Rect2(0, 0, size.x, BAR_H * u)
		draw_rect(top, Color(0.02, 0.07, 0.16, 0.92))
		draw_line(Vector2(0, top.end.y), Vector2(size.x, top.end.y), Color("3fb1f5", 0.6), maxf(1.0, 1.5 * u))
		St2Skin.words(self, St2Skin.XBOLD, "TỰ THIẾT LẬP NÚT", 22.0 * u, Rect2(16 * u, 10 * u, 280 * u, 40 * u), Color("ffc540"), "l", 
			Color("5a2200"), 3.0 * u)
		var bw: float = 112.0 * u
		var bh: float = 40.0 * u
		var x: float = size.x / 2.0 - (bw * 3 + 8 * u * 2) / 2.0
		for i in range(SLOTS):
			_btn(Rect2(x + i * (bw + 8 * u), 10 * u, bw, bh), f, "orange" if i == view_slot else "deep", "Bố cục %d" % (i + 1), "slot:%d" % i)
		var right: float = size.x - 16 * u
		_btn(Rect2(right - bw, 10 * u, bw, bh), f, "red", "THOÁT", "exit")
		_btn(Rect2(right - bw * 2 - 8 * u, 10 * u, bw, bh), f, "green", "LƯU", "save")
		_btn(Rect2(right - bw * 3 - 16 * u, 10 * u, bw, bh), f, "blue", "KHÔI PHỤC", "reset")

		var y: float = 60 * u
		var sh: float = 40 * u
		var row: Array = drafts[view_slot].get(pick, [Vector2.ZERO, 1.0])
		St2Skin.words(self, St2Skin.SEMI, "Đang chọn: %s" % LABEL_OF[pick], 17.0 * u, Rect2(16 * u, y, 300 * u, sh), Color("f4ecd8"))
		var cx: float = size.x / 2.0 - 250 * u
		St2Skin.words(self, St2Skin.SEMI, "Cỡ", 17.0 * u, Rect2(cx, y, 60 * u, sh), Color("a7c4e2"), "r")
		_btn(Rect2(cx + 70 * u, y + 2 * u, 40 * u, sh - 4 * u), f, "blue", "−", "k-", 20.0)
		St2Skin.words(self, St2Skin.XBOLD, "%d %%" % roundi(float(row[1]) * 100.0), 18.0 * u, Rect2(cx + 114 * u, y, 76 * u, sh), Color.WHITE, "c")
		_btn(Rect2(cx + 194 * u, y + 2 * u, 40 * u, sh - 4 * u), f, "blue", "+", "k+", 20.0)
		var ax: float = cx + 270 * u
		St2Skin.words(self, St2Skin.SEMI, "Độ rõ", 17.0 * u, Rect2(ax, y, 70 * u, sh), Color("a7c4e2"), "r")
		_btn(Rect2(ax + 80 * u, y + 2 * u, 40 * u, sh - 4 * u), f, "blue", "−", "a-", 20.0)
		St2Skin.words(self, St2Skin.XBOLD, "%d %%" % roundi(a * 100.0), 18.0 * u, Rect2(ax + 124 * u, y, 76 * u, sh), Color.WHITE, "c")
		_btn(Rect2(ax + 204 * u, y + 2 * u, 40 * u, sh - 4 * u), f, "blue", "+", "a+", 20.0)

		var end: float = size.x - 16 * u
		for key: String in COLUMN:
			var s: Array = shape(key)
			if (s[0] as Vector2).y - float(s[1]) < BAR_H * u and (s[0] as Vector2).x > size.x / 2.0:
				end = minf(end, (s[0] as Vector2).x - float(s[1]) - 12 * u)
		_pad_slider("stick", "Nút di chuyển cách góc", Rect2(16 * u, 108 * u, size.x / 2.0 - 32 * u, sh), u, f)
		_pad_slider("skill", "Cụm chiêu cách góc", Rect2(size.x / 2.0 + 16 * u, 108 * u, end - size.x / 2.0 - 16 * u, sh), u, f)
		St2Skin.words(self, St2Skin.SEMI, "Kéo nút để dời chỗ · chạm để chọn rồi chỉnh cỡ", 15.0 * u, 
			Rect2(size.x / 2.0 - 260 * u, size.y - 52 * u, 520 * u, 30 * u), Color(1, 1, 1, 0.7), "c")
