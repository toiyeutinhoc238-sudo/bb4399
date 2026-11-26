extends Control














const Settings = preload("res://settings.gd")
const SettingsLq = preload("res://ui/settings_lq.gd")
const MinimapMarks = preload("res://battle/minimap_marks.gd")
const TouchLq = preload("res://battle/touch_lq.gd")
const TouchLayout = preload("res://battle/touch_layout.gd")
const SafeArea = preload("res://ui/safe_area.gd")


const SETTINGS_READS: Array = ["tc_ping_mute", "tc_qc"]
const TYPES: Array = [1, 2, 3, 4]
const NAMES: Dictionary = {1: "Tấn công", 2: "Rút lui", 3: "Tập trung", 4: "Cẩn thận"}
const COLORS: Dictionary = {1: Color("ff6a5a"), 2: Color("ffd24a"), 3: Color("5ad2ff"), 4: Color("ffa040")}
const DEFAULT_QC: Array = ["Tấn công!", "Rút lui!", "Tập trung!", "Cẩn thận!", "Cần hỗ trợ!", "Đợi mình!", "Làm tốt lắm!", "Cảm ơn!"]
const QC_SLOTS: int = 8
const QC_LEN: int = 30
const LIMIT: int = 3
const WINDOW: float = 5.0
const IDLE_CLOSE: float = 6.0
const TIP_FAST: String = "Ping quá nhanh, chờ chút."
const GLASS: Color = Color(0.04, 0.07, 0.11, 0.62)
const GLASS_EDGE: Color = Color(1, 1, 1, 0.22)
const PRESS: Color = Color("2f8fe0")
const PICK: Color = Color("f08a24")

static var _hits: Array[float] = []
static var clock_override: float = -1.0

var view: Control
var fan: bool = false
var qc_open: bool = false
var target: Vector2 = Vector2(-1, -1)
var _target_screen: Vector2 = Vector2(-1, -1)
var _touched: float = 0.0
var _shown: bool = false
var map_big: bool = false
var _font: Font

static func now() -> float:
	return clock_override if clock_override >= 0.0 else Time.get_ticks_msec() / 1000.0


static func take(at: float = -1.0) -> bool:
	var t: float = now() if at < 0.0 else at
	var kept: Array[float] = []
	for one: float in _hits:
		if t - one < WINDOW:
			kept.append(one)
	_hits = kept
	if _hits.size() >= LIMIT:
		return false
	_hits.append(t)
	return true

static func reset() -> void :
	_hits.clear()
	clock_override = -1.0
	TouchLayout.map_zoom = 1.0


static func lines() -> Array[String]:
	var out: Array[String] = []
	var parsed: Variant = JSON.parse_string(str(Settings.value("tc_qc"))) if not str(Settings.value("tc_qc")).is_empty() else null
	for i in range(QC_SLOTS):
		var one: String = ""
		if parsed is Array and i < (parsed as Array).size() and (parsed as Array)[i] is String:
			one = tidy(str((parsed as Array)[i]))
		out.append(one if not one.is_empty() else str(DEFAULT_QC[i]))
	return out

static func tidy(text: String) -> String:
	return text.replace("<", "").replace(">", "").replace("\n", " ").strip_edges().left(QC_LEN)


static func store(texts: Array) -> void :
	var out: Array = []
	var same: bool = true
	for i in range(QC_SLOTS):
		var one: String = tidy(str(texts[i])) if i < texts.size() else ""
		if one.is_empty():
			one = str(DEFAULT_QC[i])
		same = same and one == str(DEFAULT_QC[i])
		out.append(one)
	Settings.put("tc_qc", "" if same else JSON.stringify(out))


static func attach(battle_view: Control) -> Control:
	if battle_view == null:
		return null
	var old: Node = battle_view.get_node_or_null("QuickPing")
	if old != null:
		return old as Control
	var node: Control = (load("res://battle/quick_ping.gd") as GDScript).new()
	node.view = battle_view
	battle_view.add_child(node)
	battle_view.move_child(node, 0)
	return node

func _init() -> void :
	name = "QuickPing"
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_font = ThemeDB.fallback_font

func _ready() -> void :
	if view == null and get_parent() is Control:
		view = get_parent() as Control

func _client() -> Node:
	return view.get("client") if view != null else null

func _battle() -> Object:
	var client: Node = _client()
	return client.get("battle") if client != null else null


func live() -> bool:
	var client: Node = _client()
	if client == null or not view.is_visible_in_tree() or str(client.get("state")) != "battle":
		return false
	var b: Object = client.get("battle")
	return b != null and bool(b.get("active")) and bool(b.get("started")) and not bool(b.get("ended")) and not bool(b.get("look"))

func _process(_delta: float) -> void :
	var b: Object = _battle()
	if b != null and "qp_on" in b:
		b.set("qp_on", true)
		b.set("qp_mute", Settings.on("tc_ping_mute"))
	var shown: bool = live()
	if not shown or ((fan or qc_open) and now() - _touched > IDLE_CLOSE):
		close()
	if not shown or not _map_shown() or TouchLayout.editing != null:
		map_big = false
	_apply_zoom()
	if shown or _shown:
		queue_redraw()
	_shown = shown


func _apply_zoom() -> void :
	var z: float = zoom_for(size) if map_big else 1.0
	if not is_equal_approx(TouchLayout.map_zoom, z):
		TouchLayout.map_zoom = z
		if view != null:
			view.queue_redraw()

func _exit_tree() -> void :
	map_big = false
	TouchLayout.map_zoom = 1.0

func close() -> void :
	fan = false
	qc_open = false
	target = Vector2(-1, -1)
	_target_screen = Vector2(-1, -1)


func _unit() -> float:
	var hud: Object = view.get("_hud") if view != null else null
	var k: float = float(hud.get("scale")) if hud != null and hud.get("scale") != null else 1.0
	return clampf(46.0 * k, size.y * 0.06, size.y * 0.11)

func _map_rect() -> Rect2:
	var hud: Object = view.get("_hud") if view != null else null
	if hud == null:
		return Rect2()
	var rects: Variant = hud.get("rects")
	return rects.get("map", Rect2()) if rects is Dictionary and _map_shown() else Rect2()

func _map_shown() -> bool:
	var b: Object = _battle()
	return b != null and not int(b.get("map_id")) in MinimapMarks.HIDE_MAPS










const SIDE: float = 28.0
const SIDE_MIN: float = 22.0
const GAP: float = 6.0
const EDGE_R: float = 6.0
const SIG_BELOW: float = TouchLq.SIG_GAP + TouchLq.SIG_CELL
const SYS_KEYS: Array = ["exit", "board", "set"]


static func _safe_tr(size: Vector2) -> Vector2:
	return SafeArea.corner_pad(size, "tr")


static func _space_cap(size: Vector2) -> float:
	var u: float = TouchLq.unit(size)
	var sc: float = TouchLayout.scale()
	var space: Vector2 = TouchLq.home(size, "b2")
	return space.y - maxf(float(TouchLq.BUTTONS[2][1]) * sc * u, TouchLq.drag_max(u)) - 8.0 * u


static func _limit(size: Vector2) -> float:
	return minf(_space_cap(size), size.y * 0.5)


static func _column(size: Vector2) -> Array:
	var u: float = TouchLq.unit(size)
	var sc: float = TouchLayout.scale()
	var safe: Vector2 = _safe_tr(size)
	var s: float = SIDE * u * sc
	var right: bool = TouchLayout.mm_right()
	var top: float = safe.y + ((TouchLq.SYS_H + TouchLq.MAP_AT + TouchLq.MAP_BOX.y * TouchLayout.mm_scale() + SIG_BELOW + 6.0) * u if right\
	else (TouchLq.SYS_H + 6.0) * u)
	var x: float = size.x - safe.x - EDGE_R * u - s / 2.0
	var cap: float = _limit(size)
	var step: float = s + GAP * u
	if top + 3.0 * s + 2.0 * GAP * u > cap:
		s = clampf(cap - top, SIDE_MIN * u, s)
		step = s + GAP * u
		x = size.x - safe.x - EDGE_R * u - s / 2.0
		var y: float = top + s / 2.0
		if y + s / 2.0 > cap:
			var avoid: Array = [[TouchLq.cancel_center(size), TouchLq.CANCEL_R * u]]
			for i in range(TouchLq.BUTTONS.size()):
				avoid.append(TouchLq.button(size, i))
			var left_end: float = size.x * 0.5 + s / 2.0
			while x - 2.0 * step > left_end:
				var row: Rect2 = Rect2(x - 2.0 * step - s / 2.0, y - s / 2.0, 2.0 * step + s, s)
				var clear: bool = true
				for c: Array in avoid:
					clear = clear and not _hits_circle(row, c[0], float(c[1]))
				if clear:
					break
				x -= u
		return [s, Vector2(x - 2.0 * step, y), Vector2(x - step, y), Vector2(x, y)]
	return [s, Vector2(x, top + s / 2.0), Vector2(x, top + s / 2.0 + step), Vector2(x, top + s / 2.0 + 2.0 * step)]



const ZOOM: float = 1.6
static func zoom_for(size: Vector2) -> float:
	var u: float = TouchLq.unit(size)
	var base: float = TouchLayout.mm_base()
	var right: bool = TouchLayout.mm_right()
	var sz: Vector2 = TouchLq.stick_zone() * u
	var stick: Rect2 = Rect2(0, size.y - sz.y, sz.x, sz.y)
	var circles: Array = [[TouchLq.fire_center(size), TouchLq.fire_r(size)], [TouchLq.auto_center(size), TouchLq.auto_r(size)], 
		[TouchLayout.at("stick", size, TouchLq.home(size, "stick")), TouchLq.stick_r(size)]]
	for i in range(TouchLq.BUTTONS.size()):
		circles.append(TouchLq.button(size, i))
	var b2: Array = TouchLq.button(size, 2)
	circles.append([b2[0], maxf(float(b2[1]), TouchLq.drag_max(u))])
	var cap: float = _limit(size)
	var z: float = ZOOM
	while z > 1.0 + 0.001:
		var w: float = TouchLq.MAP_BOX.x * base * z * u
		var h: float = (TouchLq.MAP_BOX.y * base * z + SIG_BELOW) * u
		var box: Rect2 = Rect2(map_at(size, w), Vector2(w, h))
		var ok: bool = not box.intersects(stick) and ( not right or box.end.y + (6.0 + SIDE_MIN) * u <= cap)
		for c: Array in circles:
			if ok and _hits_circle(box, c[0], float(c[1])):
				ok = false
		if ok:
			return z
		z -= 0.05
	return 1.0



static func map_at(size: Vector2, w: float) -> Vector2:
	var u: float = TouchLq.unit(size)
	if TouchLayout.mm_right():
		return Vector2(size.x - TouchLq.MAP_AT * u - w - SafeArea.inset(size).z, (TouchLq.SYS_H + TouchLq.MAP_AT) * u + _safe_tr(size).y)
	return Vector2.ONE * TouchLq.MAP_AT * u + SafeArea.corner_pad(size, "tl")

static func _hits_circle(box: Rect2, c: Vector2, r: float) -> bool:
	var near: Vector2 = Vector2(clampf(c.x, box.position.x, box.end.x), clampf(c.y, box.position.y, box.end.y))
	return near.distance_to(c) < r


static func home(size: Vector2, key: String) -> Vector2:
	var col: Array = _column(size)
	return col[1] if key == "zoom" else (col[2] if key == "ping" else col[3])


static func side(size: Vector2, key: String) -> float:
	var sc: float = TouchLayout.scale()
	return float(_column(size)[0]) * (TouchLayout.k(key) / sc if sc > 0.0 else 1.0)


static func button_rect(size: Vector2, key: String) -> Rect2:
	var s: float = side(size, key)
	var c: Vector2 = TouchLayout.at(key, size, home(size, key))
	return Rect2(c - Vector2(s, s) / 2.0, Vector2(s, s))



func _rect(key: String) -> Rect2:
	var box: Rect2 = button_rect(size, key)
	var hud: Object = view.get("_hud") if view != null else null
	if hud == null or TouchLayout.layout().has(key):
		return box
	if not TouchLayout.mm_right():
		box.position.y += _sys_drop(hud)
	if hud.get("touch_round") != null or TouchLayout.mm_right():
		return box
	var cols: Variant = hud.get("touch_col_x")
	var col_x: float = float(cols[1]) if cols is Array and cols.size() > 1 else 0.0
	if col_x <= size.x * 0.5:
		return box
	var u: float = TouchLq.unit(size)
	var shift: float = col_x - 4.0 * u - box.end.x
	if shift < 0.0:
		box.position.x += shift
	return box



func _sys_drop(hud: Object) -> float:
	var rects: Variant = hud.get("rects")
	if not rects is Dictionary:
		return 0.0
	var u: float = TouchLq.unit(size)
	var bottom: float = 0.0
	for k: String in SYS_KEYS:
		if (rects as Dictionary).has(k):
			bottom = maxf(bottom, (rects[k] as Rect2).end.y)
	return maxf(0.0, bottom - (_safe_tr(size).y + TouchLq.SYS_H * u))

func zoom_rect() -> Rect2:
	return _rect("zoom")

func ping_rect() -> Rect2:
	return _rect("ping")

func chat_rect() -> Rect2:
	return _rect("chat")


func _map_zone() -> Rect2:
	var map: Rect2 = _map_rect()
	if map.size.x <= 0:
		return Rect2()
	var hud: Object = view.get("_hud")
	var k: float = float(hud.get("scale")) if hud != null and hud.get("scale") != null else 1.0
	return Rect2(map.position, map.size + Vector2(0, SIG_BELOW * k)).grow(6.0)


func _keep_clear(rects: Array[Rect2]) -> Array[Rect2]:
	var zone: Rect2 = _map_zone()
	var shift: float = 0.0
	if zone.size.x > 0:
		for one: Rect2 in rects:
			if one.intersects(zone):
				var right: float = - INF
				for r: Rect2 in rects:
					right = maxf(right, r.end.x)
				shift = zone.position.x - right
				break
	var left: float = INF
	for r: Rect2 in rects:
		left = minf(left, r.position.x + shift)
	if left < 4.0:
		shift += 4.0 - left
	var out: Array[Rect2] = []
	for r: Rect2 in rects:
		out.append(Rect2(r.position + Vector2(shift, 0), r.size))
	return out


func _row_h() -> float:
	return maxf(30.0, 32.0 * TouchLq.unit(size))


func type_rects() -> Array[Rect2]:
	var p: Rect2 = ping_rect()
	var c: Rect2 = chat_rect()
	var h: float = _row_h()
	var x: float = minf(p.position.x, c.position.x) - 8 - h * 3.2
	var top: float = minf(p.position.y, c.position.y)
	var out: Array[Rect2] = []
	for i in range(TYPES.size()):
		out.append(Rect2(Vector2(x, top + i * (h + 5)), Vector2(h * 3.2, h)))
	return _keep_clear(out)


func qc_rects() -> Array[Rect2]:
	var p: Rect2 = ping_rect()
	var c: Rect2 = chat_rect()
	var h: float = _row_h()
	var edge: float = minf(p.position.x, c.position.x) - 8
	var w: float = clampf((edge - 24) / 4.0, 120.0, 190.0)
	var top: float = minf(minf(p.position.y, c.position.y), size.y - 4 * (h + 5) - 8)
	var out: Array[Rect2] = []
	for i in range(QC_SLOTS):
		out.append(Rect2(Vector2(edge - (2 - (i >> 2)) * (w + 6) + 6, top + (i % 4) * (h + 5)), Vector2(w, h)))
	return _keep_clear(out)

func _has_point(point: Vector2) -> bool:
	if not _shown:
		return false
	if fan or qc_open:
		return true
	return ping_rect().has_point(point) or chat_rect().has_point(point) or (_map_shown() and zoom_rect().has_point(point))


func _input(event: InputEvent) -> void :
	if not map_big:
		return
	var touch: bool = event is InputEventScreenTouch and event.pressed
	var click: bool = event is InputEventMouseButton and event.pressed and event.device != InputEvent.DEVICE_ID_EMULATION
	if not (touch or click):
		return
	var at: Vector2 = get_global_transform_with_canvas().affine_inverse() * (event.position as Vector2)
	if not _map_rect().has_point(at) and not zoom_rect().has_point(at):
		toggle_zoom(false)

func toggle_zoom(big: bool) -> void :
	map_big = big and _map_shown() and live()
	_apply_zoom()
	queue_redraw()

func _gui_input(event: InputEvent) -> void :
	var at: Vector2 = Vector2(-1, -1)
	if event is InputEventScreenTouch and event.pressed:
		at = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT\
	and event.device != InputEvent.DEVICE_ID_EMULATION:
		at = event.position
	if at.x >= 0:
		tap(at)
	accept_event()

func tap(at: Vector2) -> void :
	if not live():
		return
	_touched = now()
	if _map_shown() and zoom_rect().has_point(at):
		close()
		toggle_zoom( not map_big)
		return
	if qc_open:
		var rects: Array[Rect2] = qc_rects()
		for i in range(rects.size()):
			if rects[i].has_point(at):
				quick_chat(i)
				break
		close()
		return
	if fan:
		var rects: Array[Rect2] = type_rects()
		for i in range(rects.size()):
			if rects[i].has_point(at):
				ping(int(TYPES[i]))
				close()
				return
		if ping_rect().has_point(at):
			close()
			return
		if chat_rect().has_point(at):
			close()
			qc_open = true
			return
		var map: Rect2 = _map_rect()
		var hud: Object = view.get("_hud")
		if map.has_point(at) and hud != null:
			target = hud.call("minimap_to_world", at)
		else:
			target = view.call("screen_to_world", at)
		_target_screen = at
		return
	if ping_rect().has_point(at):
		fan = true
		target = Vector2(-1, -1)
		_target_screen = Vector2(-1, -1)
	elif chat_rect().has_point(at):
		qc_open = true

func _own_pos() -> Vector2:
	var b: Object = _battle()
	var tanks: Dictionary = b.get("tanks")
	var me: Dictionary = tanks.get(int(b.get("self_id")), {})
	if me.has("pos"):
		return me.pos
	return view.call("screen_to_world", size / 2)

func ping(kind: int) -> bool:
	var client: Node = _client()
	if client == null or not live() or kind not in TYPES:
		return false
	if not take():
		_battle().call("chat_rejected", TIP_FAST)
		return false
	var at: Vector2 = target if target.x >= 0 else _own_pos()
	client.call("send_signal", kind, at)
	return true

func quick_chat(index: int) -> bool:
	var client: Node = _client()
	if client == null or not live() or index < 0 or index >= QC_SLOTS:
		return false
	if not take():
		_battle().call("chat_rejected", TIP_FAST)
		return false
	var b: Object = _battle()
	var oid: int = int(client.get("account_oid"))
	var tanks: Dictionary = b.get("tanks")
	var names: Dictionary = b.get("names")
	var who: String = str(tanks.get(oid, {}).get("name", names.get(oid, "")))
	var server_ms: float = float(b.get("server_ms"))
	var stamp: int = int(server_ms) if server_ms > 0 else int(Time.get_unix_time_from_system() * 1000)
	client.set("_chat_sent", Time.get_ticks_msec() / 1000.0)
	client.call("_send_chat_packet", int(b.get("CHAT_CAMP")), who, lines()[index], "", 0, stamp, {"qc": index})
	return true


func _pill(rect: Rect2, text: String, fill: Color, edge: Color, font_size: int) -> void :
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = edge
	box.set_border_width_all(1)
	box.set_corner_radius_all(int(rect.size.y * 0.3))
	draw_style_box(box, rect)
	var width: float = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var base: float = rect.position.y + (rect.size.y + _font.get_ascent(font_size) - _font.get_descent(font_size)) / 2.0
	draw_string_outline(_font, Vector2(rect.position.x + maxf(4.0, (rect.size.x - width) / 2.0), base), text, 
		HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 8, font_size, 3, Color(0, 0, 0, 0.6))
	draw_string(_font, Vector2(rect.position.x + maxf(4.0, (rect.size.x - width) / 2.0), base), text, 
		HORIZONTAL_ALIGNMENT_LEFT, rect.size.x - 8, font_size, Color.WHITE)


func _icon_flag(rect: Rect2, color: Color) -> void :
	var c: Vector2 = rect.get_center()
	var r: float = rect.size.y * 0.24
	draw_line(c + Vector2( - r * 0.6, - r * 1.1), c + Vector2( - r * 0.6, r * 1.2), color, 2.0, true)
	draw_colored_polygon(PackedVector2Array([c + Vector2( - r * 0.6, - r * 1.1), c + Vector2(r * 1.0, - r * 0.6), c + Vector2( - r * 0.6, - r * 0.05)]), color)

func _icon_chat(rect: Rect2, color: Color) -> void :
	var c: Vector2 = rect.get_center() - Vector2(0, rect.size.y * 0.04)
	var r: float = rect.size.y * 0.24
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = color
	box.set_corner_radius_all(int(r * 0.5))
	draw_style_box(box, Rect2(c - Vector2(r * 1.15, r * 0.75), Vector2(r * 2.3, r * 1.45)))
	draw_colored_polygon(PackedVector2Array([c + Vector2( - r * 0.5, r * 0.65), c + Vector2( - r * 0.75, r * 1.25), c + Vector2(0, r * 0.65)]), color)
	for i in range(3):
		draw_circle(c + Vector2((i - 1) * r * 0.62, 0), r * 0.16, Color(0.05, 0.08, 0.12, 0.9))


func _btn(rect: Rect2, active: bool, flag: bool) -> void :
	var c: Vector2 = rect.get_center()
	var r: float = rect.size.x / 2.0
	draw_circle(c, r, Color(PICK, 0.88) if active else Color(0.03, 0.05, 0.09, 0.7))
	draw_arc(c, r - 0.75, 0, TAU, 40, Color(1, 1, 1, 0.75) if active else Color(1, 1, 1, 0.38), 1.5, true)
	var icon: Rect2 = Rect2(c - Vector2(r, r) * 0.95, Vector2(r, r) * 1.9)
	var art: Texture2D = null if flag else SettingsLq.mi_tex("chat_quick", r * 1.45 * get_global_transform_with_canvas().get_scale().x)
	if art != null:
		var span: float = r * 1.45
		draw_texture_rect(art, Rect2(c - Vector2(span, span) / 2.0, Vector2(span, span)), false)
	elif flag:
		_icon_flag(Rect2(icon.position + Vector2(icon.size.x * 0.06, 0), icon.size), Color.WHITE)
	else:
		_icon_chat(icon, Color.WHITE)


const ZOOM_TINT: Color = Color("3fe0d2")
func _btn_zoom(rect: Rect2) -> void :
	var c: Vector2 = rect.get_center()
	var r: float = rect.size.x / 2.0
	draw_circle(c, r, Color(0.03, 0.05, 0.09, 0.7))
	draw_arc(c, r - 0.75, 0, TAU, 40, Color(ZOOM_TINT, 0.8) if map_big else Color(1, 1, 1, 0.38), 1.5, true)
	var w: float = maxf(1.6, r * 0.13)
	var lens: Vector2 = c - Vector2(r, r) * 0.1
	var lr: float = r * 0.38
	draw_arc(lens, lr, 0, TAU, 32, ZOOM_TINT, w, true)
	var dir: Vector2 = Vector2(1, 1).normalized()
	draw_line(lens + dir * (lr + w * 0.4), lens + dir * (lr + r * 0.42), ZOOM_TINT, w * 1.5, true)
	var arm: float = lr * 0.52
	draw_line(lens - Vector2(arm, 0), lens + Vector2(arm, 0), ZOOM_TINT, w, true)
	if not map_big:
		draw_line(lens - Vector2(0, arm), lens + Vector2(0, arm), ZOOM_TINT, w, true)


func _field_marks() -> void :
	var b: Object = _battle()
	var zoom: float = float(view.get("_zoom"))
	var offset: Vector2 = view.get("_offset")
	if zoom <= 0.0:
		return
	var font_size: int = maxi(11, int(_unit() * 0.3))
	for mark: Dictionary in b.get("signals"):
		var kind: int = int(mark.get("type", 0))
		if not COLORS.has(kind):
			continue
		var life: float = float(MinimapMarks.SIGNAL_DELAY.get(kind, 2.0))
		var age: float = float(mark.get("age", 0.0))
		if age >= life:
			continue
		var at: Vector2 = offset + (mark.pos as Vector2) * zoom
		if not Rect2(Vector2.ZERO, size).grow(40).has_point(at):
			continue
		var color: Color = COLORS[kind]
		var k: float = fmod(age, 1.0)
		var r: float = _unit() * 0.5
		draw_arc(at, r * (0.6 + k * 0.8), 0, TAU, 40, Color(color, 0.9 * (1.0 - k)), 3.0, true)
		draw_arc(at, r * 0.45, 0, TAU, 32, Color(color, 0.95), 2.0, true)
		draw_circle(at, r * 0.16, color)
		var label: String = str(NAMES[kind])
		var who: String = str(mark.get("name", ""))
		if not who.is_empty():
			label = who + ": " + label
		var width: float = _font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var pos: Vector2 = at + Vector2( - width / 2.0, - r * 0.75)
		draw_string_outline(_font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, 4, Color(0, 0, 0, 0.75))
		draw_string(_font, pos, label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color.lightened(0.25))

func _draw() -> void :
	if not _shown or view == null:
		return
	_field_marks()
	var font_size: int = maxi(12, int(_unit() * 0.32))
	if _map_shown():
		_btn_zoom(zoom_rect())
	_btn(ping_rect(), fan, true)
	_btn(chat_rect(), qc_open, false)
	if fan:
		var rects: Array[Rect2] = type_rects()
		for i in range(rects.size()):
			var kind: int = int(TYPES[i])
			_pill(rects[i], str(NAMES[kind]), Color(COLORS[kind].darkened(0.45), 0.86), Color(COLORS[kind], 0.9), font_size)
		var hint: String = "Chạm bản đồ nhỏ / sân để chọn chỗ" if _target_screen.x < 0 else "Đã chọn chỗ — chạm kiểu để gửi"
		var last: Rect2 = rects[rects.size() - 1]
		draw_string_outline(_font, Vector2(last.position.x, last.end.y + font_size + 4), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size - 1, 3, 
			Color(0, 0, 0, 0.7))
		draw_string(_font, Vector2(last.position.x, last.end.y + font_size + 4), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size - 1, Color(1, 1, 1, 0.85))
		if _target_screen.x >= 0:
			draw_arc(_target_screen, 10, 0, TAU, 24, PICK, 2.0, true)
			draw_line(_target_screen - Vector2(14, 0), _target_screen + Vector2(14, 0), PICK, 1.5)
			draw_line(_target_screen - Vector2(0, 14), _target_screen + Vector2(0, 14), PICK, 1.5)
	if qc_open:
		var texts: Array[String] = lines()
		var rects: Array[Rect2] = qc_rects()
		for i in range(rects.size()):
			_pill(rects[i], texts[i], Color(PRESS.darkened(0.55), 0.86), Color(PRESS, 0.9), font_size)



static func open_quick_chat_editor(host: Control) -> Control:
	if host == null:
		return null
	var old: Node = host.get_node_or_null("QuickChatEditor")
	if old != null:
		old.queue_free()
		host.remove_child(old)
	var shade: Control = ColorRect.new()
	shade.name = "QuickChatEditor"
	(shade as ColorRect).color = Color(0, 0, 0, 0.55)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	host.add_child(shade)
	shade.size = host.size
	var room: Vector2 = host.size
	var box_size: Vector2 = Vector2(minf(room.x - 24, 600), minf(room.y - 16, 330))
	var panel: Panel = Panel.new()
	panel.name = "Box"
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.09, 0.14, 0.96)
	style.border_color = Color(1, 1, 1, 0.2)
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	panel.add_theme_stylebox_override("panel", style)
	panel.position = (room - box_size) / 2
	panel.size = box_size
	shade.add_child(panel)
	var font_size: int = 14 if box_size.y >= 300 else 12
	var title: Label = Label.new()
	title.text = "Chat lẹ — 8 câu gửi đồng đội bằng một chạm"
	title.position = Vector2(14, 8)
	title.add_theme_font_size_override("font_size", font_size + 1)
	panel.add_child(title)
	var texts: Array[String] = lines()
	var edits: Array[LineEdit] = []
	var top: float = 36.0
	var row: float = minf(40.0, (box_size.y - top - 50) / 4.0)
	var col: float = (box_size.x - 36) / 2.0
	for i in range(QC_SLOTS):
		var edit: LineEdit = LineEdit.new()
		edit.name = "Line%d" % i
		edit.max_length = QC_LEN
		edit.text = texts[i]
		edit.placeholder_text = str(DEFAULT_QC[i])
		edit.position = Vector2(14 + (i >> 2) * (col + 8), top + (i % 4) * row)
		edit.size = Vector2(col, row - 6)
		edit.add_theme_font_size_override("font_size", font_size)
		panel.add_child(edit)
		edits.append(edit)
	var buttons: Array = [["Default", "Mặc định"], ["Cancel", "Huỷ"], ["Save", "Lưu"]]
	var bw: float = 104.0
	for i in range(buttons.size()):
		var button: Button = Button.new()
		button.name = str(buttons[i][0])
		button.text = str(buttons[i][1])
		button.size = Vector2(bw, 34)
		button.position = Vector2(box_size.x - (buttons.size() - i) * (bw + 8) - 6, box_size.y - 44)
		button.add_theme_font_size_override("font_size", font_size)
		var fill: StyleBoxFlat = StyleBoxFlat.new()
		fill.bg_color = PICK if button.name == "Save" else PRESS
		fill.set_corner_radius_all(8)
		button.add_theme_stylebox_override("normal", fill)
		panel.add_child(button)
	(panel.get_node("Default") as Button).pressed.connect( func() -> void :
		for i in range(QC_SLOTS):
			edits[i].text = str(DEFAULT_QC[i]))
	(panel.get_node("Cancel") as Button).pressed.connect(shade.queue_free)
	(panel.get_node("Save") as Button).pressed.connect( func() -> void :
		var out: Array = []
		for edit: LineEdit in edits:
			out.append(edit.text)
		store(out)
		shade.queue_free())
	return shade
