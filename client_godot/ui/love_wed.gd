extends "flash_screen.gd"










const Love = preload("love.gd")
const SCRIPT_PATH: String = "res://ui/love_wed.gd"
const NODE_NAME: String = "LoveWed"
const ASK = preload("love_ask.gd")
const DIM: Color = Color(0, 0, 0, 115.0 / 255.0)
const PANEL: Vector2 = Vector2(600, 420)
const CARD: Color = Color("0a2448")
const CARD_EDGE: Color = Color(0.25, 0.69, 0.96, 0.35)
const ONLINE: Color = Color("4fe08a")
const SLOT_COLS: int = 6
const SLOT_SIZE: Vector2 = Vector2(52, 26)
const SLOT_GAP: float = 4.0
const GUEST_ROW: float = 24.0
const GUEST_SHOWN: int = 11
const HALL_OPEN_EVERY: float = 5.0
const HALL_WAIT_EVERY: float = 15.0
const SLOTS_EVERY: float = 30.0
const NOTE_KINDS: Array = ["book", "guests", "join", "bless", "hall", "slots", "hall_name"]
const GUEST_SHOWN_NAMED: int = 9

var mode: String = ""
var wid: int = 0
var day: int = 0
var pick_at: int = 0
var picked: Dictionary = {}
var gfirst: int = 0
var note: String = ""
var note_ok: bool = true
var _state: String = ""
var _rev: int = -1
var _hall_at: float = -1000.0
var _hall_got: float = 0.0
var _hall_seen: Dictionary = {}
var _slots_at: float = -1000.0
var _joined: int = 0
var _seeded: int = -1
var _guest_rect: Rect2 = Rect2()
var _hall_edit: LineEdit = null
var _hall_seed: String = ""
var _hall_put: bool = false

static func open_for(host: Control, kind: String, wedding_id: int = 0) -> Control:
	if host == null or host.client == null or host.pack == null or host.get_parent() == null or not Love.wed_on():
		return null
	var parent: Node = host.get_parent()
	var view: Control = parent.get_node_or_null(NODE_NAME) as Control
	if view == null:
		view = load(SCRIPT_PATH).new()
		view.name = NODE_NAME
		view.client = host.client
		view.pack = host.pack
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		parent.add_child(view)
	view.client = host.client
	view.pack = host.pack
	parent.move_child(view, parent.get_child_count() - 1)
	return view if view.open(kind, wedding_id) else null

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_hall_edit = _fedit(0)
	_hall_edit.placeholder_text = "Để trống = tên hai bạn"
	_hall_edit.add_theme_color_override("font_placeholder_color", Color(MUTED, 0.7))
	_hall_edit.text_changed.connect( func(value: String) -> void :
		var over: int = value.length() - Love.wrule("hallNameMax", 24)
		if over > 0:
			var caret: int = maxi(_hall_edit.caret_column - over, 0)
			_hall_edit.text = value.left(caret) + value.substr(caret + over)
			_hall_edit.caret_column = caret
		queue_redraw())
	_hall_edit.text_submitted.connect( func(_value: String) -> void : _activate("hname"))

func open(kind: String, wedding_id: int = 0) -> bool:
	if client == null or not kind in ["book", "hall"]:
		return false
	mode = kind
	wid = wedding_id
	day = 0
	pick_at = 0
	gfirst = 0
	note = ""
	_seeded = -1
	_joined = 0
	_hall_at = -1000.0
	_slots_at = -1000.0
	_state = client.state
	Love.take(NOTE_KINDS)
	if mode == "book" and Love.wedding().is_empty():
		picked = {}
	visible = true
	var view: Viewport = get_viewport()
	if view != null:
		view.gui_release_focus()
	_tick(0.0)
	queue_redraw()
	return true

func close() -> void :
	visible = false
	mode = ""
	note = ""
	_hall_hide()


func hall_named() -> bool:
	return Love.wrule("hallNameMax", 0) > 0 and Love.wcouple().has("hallName")

func guest_shown() -> int:
	return GUEST_SHOWN_NAMED if mode == "book" and hall_named() else GUEST_SHOWN

func _hall_hide() -> void :
	if _hall_edit != null and _hall_edit.visible:
		_hall_edit.visible = false
		_hall_edit.release_focus()
		_hall_seed = ""


func _paint_hall_name(at: Vector2) -> void :
	var own: String = str(Love.wcouple().get("hallOwn", ""))
	if own != _hall_seed and not _hall_edit.has_focus():
		_hall_seed = own
		_hall_edit.text = own
	_fwords("Tên sảnh lễ (tối đa %d ký tự)" % Love.wrule("hallNameMax", 24), ARIAL_BOLD, 11, MUTED, "l", at, 208, 0.0, 16.0)
	var field: Rect2 = Rect2(at + Vector2(0, 20), Vector2(150, 26))
	_fround(field, CARD, 6.0, Color(GLASS_EDGE, 0.8) if _hall_edit.has_focus() else CARD_EDGE, 1.0)
	_fput(_hall_edit, Rect2(field.position + Vector2(6, 0), field.size - Vector2(12, 0)), 12.0)
	_hit("hfield", Rect2(field.position * _f, field.size * _f), false)
	_hall_put = true
	var text: String = _hall_edit.text.strip_edges()
	_fbtn("hname", "Lưu", Rect2(at + Vector2(156, 20), Vector2(52, 26)), "blue", text != own and not Love.busy("hall_name"), 12.0)


func hall_id() -> int:
	return wid if wid > 0 else int(Love.wedding().get("id", 0))

func _hall() -> Dictionary:
	var hall: Dictionary = Love.hall_data
	return hall if hall.get("ok") == true and int(hall.get("id", 0)) == hall_id() and hall_id() > 0 else {}

func _tick(_delta: float) -> void :
	if client == null or client.state != _state or not Love.wed_on():
		close()
		return
	var t: float = Time.get_ticks_msec() / 1000.0
	if mode == "hall":
		var hall: Dictionary = _hall()
		var every: float = HALL_OPEN_EVERY if str(hall.get("phase", "")) == "open" else HALL_WAIT_EVERY
		if t - _hall_at >= every and hall_id() > 0:
			_hall_at = t
			Love.want_hall(client, hall_id())
		if hall != _hall_seen:
			_hall_seen = hall
			_hall_got = t
		if str(hall.get("role", "")) == "guest" and str(hall.get("phase", "")) == "open" and hall.get("joined") != true and _joined != hall_id():
			_joined = hall_id()
			Love.join(client, hall_id())
	elif mode == "book" and Love.wedding().is_empty():
		if t - _slots_at >= SLOTS_EVERY or int(Love.slots_data.get("day", -1)) != day:
			if not Love.busy("slots"):
				_slots_at = t
				Love.want_slots(client, day)
	if mode == "book" and not Love.wedding().is_empty() and _seeded != int(Love.wedding().get("id", 0)):
		_seeded = int(Love.wedding().get("id", 0))
		picked = {}
		for g: Variant in Love.wedding().get("guests", []):
			if g is Dictionary:
				picked[int(g.get("id", 0))] = true
	for item: Dictionary in Love.take(NOTE_KINDS):
		if str(item.get("kind", "")) == "join" and item.get("ok") != true:
			continue
		note = str(item.get("text", ""))
		note_ok = item.get("ok") == true
		if str(item.get("kind", "")) == "book" and note_ok:
			note = ""
			mode = "hall"
			wid = 0
			_hall_at = -1000.0
	if _rev != Love.rev:
		_rev = Love.rev
		queue_redraw()
	elif mode == "hall":
		queue_redraw()



func _fround(rect: Rect2, fill: Color, radius: float, edge: Color = Color(0, 0, 0, 0), width: float = 0.0) -> void :
	_round(Rect2(rect.position * _f, rect.size * _f), fill, radius * 2.0, edge, width * 2.0)

func _fgrad(rect: Rect2, top: Color, bottom: Color, edge: Color, radius: float, border: float = 1.0) -> void :
	_grad(Rect2(rect.position * _f, rect.size * _f), top, bottom, edge, radius * 2.0, border * 2.0)

func _fbtn(id: String, text: String, rect: Rect2, style: String = "blue", on: bool = true, px: float = 13.0) -> void :
	var tones: Dictionary = {"blue": [BTN_TOP, BTN_LOW, BTN_EDGE], "gold": [GOLD_TOP, GOLD_LOW, BTN_GOLD_EDGE], 
		"green": [Color("46d483"), Color("15804a"), Color("bff7d6")], "gray": [Color("53657d"), Color("2c3a4e"), Color(1, 1, 1, 0.28)]}
	var tone: Array = tones.get(style, tones["blue"])
	var ink: Color = Color.WHITE
	if not on:
		_fround(rect, Color("1a2c45", 0.9), 6.0, Color(1, 1, 1, 0.12), 1.0)
		ink = Color(MUTED, 0.5)
	else:
		var lit: float = _shine(id)
		var top: Color = tone[0]
		var low: Color = tone[1]
		if lit > 1.0:
			top = top.lightened(0.14)
			low = low.lightened(0.14)
		elif lit < 1.0:
			top = top.darkened(0.18)
			low = low.darkened(0.18)
		_fgrad(rect, top, low, Color(tone[2], 0.9), 6.0, 1.0)
		_fround(Rect2(rect.position + Vector2(2, 2), Vector2(rect.size.x - 4.0, rect.size.y * 0.45)), Color(1, 1, 1, 0.1), 4.0)
	_fwords(text, ARIAL_BOLD, px, ink, "c", rect.position + Vector2(3, 0), rect.size.x - 6.0, 1.0 if on else 0.0, rect.size.y, true, Color(0, 0, 0, 0.35))
	if on:
		_hit(id, Rect2(rect.position * _f, rect.size * _f), false)


func _fcheck(at: Vector2, on: bool, usable: bool) -> void :
	var box: Rect2 = Rect2(at, Vector2(14, 14))
	_fround(box, GOLD if on else Color(0, 0, 0, 0.35), 3.0, Color(1, 1, 1, 0.5 if usable else 0.18), 1.0)
	if on:
		var pts: PackedVector2Array = PackedVector2Array([(at + Vector2(3, 7)) * _f, (at + Vector2(6, 10.5)) * _f, (at + Vector2(11, 3.5)) * _f])
		draw_polyline(pts, BTN_INK, maxf(1.5, 2.0 * _f))

func _fline(at: Vector2, wide: float) -> void :
	draw_line(at * _f, (at + Vector2(wide, 0)) * _f, Color(GLASS_EDGE, 0.22), maxf(1.0, _f * 0.6))



func _paint() -> void :
	if mode.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var high: float = panel_high()
	var at: Vector2 = _centre(PANEL.x, high)
	_hit("panel", Rect2(at * _f, Vector2(PANEL.x, high) * _f), false)
	_fgrad(Rect2(at, Vector2(PANEL.x, high)), Color(GLASS, 0.97), Color(GLASS_LOW, 0.97), Color(GLASS_EDGE, 0.85), 12.0, 1.0)
	_fround(Rect2(at + Vector2(2, 2), Vector2(PANEL.x - 4.0, 34)), Color(1, 1, 1, 0.05), 10.0)
	_close_x(Rect2(at + Vector2(PANEL.x - 36.0, 8), Vector2(24, 24)))
	_guest_rect = Rect2()
	_hall_put = false
	if mode == "book":
		_paint_book(at)
		if not note.is_empty():
			_fwords(note, ARIAL_BOLD, 12, ONLINE if note_ok else Color("ff8a8a"), "l", at + Vector2(16, PANEL.y - 64.0), 348, 0.0, 16.0)
	else:
		_paint_hall(at, high)
	if not _hall_put:
		_hall_hide()


func _close_x(box: Rect2) -> void :
	var lit: float = _shine("close")
	_fround(box, Color(1, 1, 1, 0.08 * lit), 12.0, Color(1, 1, 1, 0.25 * lit), 1.0)
	var c: Vector2 = box.get_center() * _f
	var s: float = 5.0 * _f
	draw_line(c + Vector2( - s, - s), c + Vector2(s, s), Color(1, 1, 1, 0.9), maxf(1.5, 1.6 * _f), true)
	draw_line(c + Vector2( - s, s), c + Vector2(s, - s), Color(1, 1, 1, 0.9), maxf(1.5, 1.6 * _f), true)
	_hit("close", Rect2(box.position * _f, box.size * _f).grow(3.0 * _f), false)


func panel_high() -> float:
	if mode == "hall":
		return float(_hall_plan(_hall()).get("high", PANEL.y))
	return PANEL.y

func _title(at: Vector2, text: String) -> void :
	_fwords(text, ARIAL_BOLD, 16, GOLD, "l", at + Vector2(16, 8), PANEL.x - 110.0, 1.0, 26.0, true, Color(0, 0, 0, 0.5))


func day_label(d: int) -> String:
	if d == 0:
		return "Nay"
	if d == 1:
		return "Mai"
	var vn: Dictionary = Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_system()) + 7 * 3600 + d * 86400)
	return "%02d/%02d" % [int(vn.day), int(vn.month)]


func day_tab(d: int, days: int) -> Rect2:
	var wide: float = float(SLOT_COLS) * SLOT_SIZE.x + float(SLOT_COLS - 1) * SLOT_GAP
	var tab_w: float = floorf((wide - SLOT_GAP * float(days - 1)) / float(maxi(1, days)))
	var spare: float = wide - tab_w * float(days) - SLOT_GAP * float(days - 1)
	return Rect2(Vector2(2.0 + floorf(spare / 2.0) + float(d) * (tab_w + SLOT_GAP), 0), Vector2(tab_w, 24))


func slot_rows(count: int) -> int:
	var per_day: int = maxi(1, (Love.wrule("closeHour", 23) - Love.wrule("openHour", 8)) * 60 / maxi(1, Love.wrule("slotMinutes", 30)))
	return maxi(1, ceili(float(maxi(per_day, count)) / float(SLOT_COLS)))

func _paint_book(at: Vector2) -> void :
	var w: Dictionary = Love.wedding()
	var left: Vector2 = at + Vector2(16, 46)
	if w.is_empty():
		_title(at, "Đặt Lễ đường")
		var days: int = Love.wrule("bookDaysAhead", 7) + 1
		for d in range(days):
			var tab: Rect2 = day_tab(d, days)
			_fbtn("day:%d" % d, day_label(d), Rect2(left + tab.position, tab.size), "gold" if d == day else "blue", true, 11.0)
		var slots: Array = []
		if int(Love.slots_data.get("day", -1)) == day:
			slots = (Love.slots_data.get("slots", []) as Array).filter( func(s: Variant) -> bool: return s is Dictionary)
		_fwords("Khung %d phút · %02d:00–%02d:00 giờ Việt Nam" % [Love.wrule("slotMinutes", 30), Love.wrule("openHour", 8), Love.wrule("closeHour", 23)], 
			ARIAL_BOLD, 11, MUTED, "l", left + Vector2(0, 30), 348, 0.0, 16.0)
		var rows: int = slot_rows(slots.size())
		var grid_h: float = float(rows) * (SLOT_SIZE.y + SLOT_GAP) - SLOT_GAP
		if slots.is_empty():
			_fwords("Đang tải khung giờ…" if Love.busy("slots") or int(Love.slots_data.get("day", -1)) != day else "Hết khung giờ trống ngày này.", 
				ARIAL_BOLD, 13, Color(MUTED, 0.85), "c", left + Vector2(0, 52), 348, 0.0, grid_h)
		for i in range(slots.size()):
			var s: Dictionary = slots[i]
			var cell: Vector2 = left + Vector2(float(i % SLOT_COLS) * (SLOT_SIZE.x + SLOT_GAP) + 2.0, 52.0 + float(i / SLOT_COLS) * (SLOT_SIZE.y + SLOT_GAP))
			var slot_at: int = int(s.get("at", 0))
			var mine: bool = s.get("mine") == true
			var free: bool = s.get("free") == true
			_fbtn("slot:%d" % slot_at, str(s.get("time", "")), Rect2(cell, SLOT_SIZE), "gold" if mine or slot_at == pick_at else "blue", free and not mine, 12.0)
		_book_legend(left + Vector2(2, 52.0 + grid_h + 8.0))
		_book_summary(Rect2(left + Vector2(2, 52.0 + grid_h + 32.0), Vector2(346, 72)))
		var chosen: String = "Chọn một khung giờ trống." if pick_at <= 0 else "Lễ cưới lúc %s · %d khách mời" % [Love.vn_time(pick_at), picked.size()]
		_fwords(chosen, ARIAL_BOLD, 13, Color.WHITE if pick_at > 0 else MUTED, "l", at + Vector2(16, PANEL.y - 40.0), 400, 1.0, 26.0)
		_fbtn("book", "Đặt lễ", Rect2(at + Vector2(PANEL.x - 128.0, PANEL.y - 42.0), Vector2(112, 30)), "blue", 
			pick_at > 0 and not Love.busy("book"), 14.0)
	else:
		_title(at, "Lễ đường · Khách mời")
		_fround(Rect2(left, Vector2(348, 150)), CARD, 8.0, CARD_EDGE, 1.0)
		_fwords("Lễ cưới của bạn", ARIAL_BOLD, 13, MUTED, "l", left + Vector2(14, 12), 320, 0.0, 16.0)
		_fwords(str(w.get("time", Love.vn_time(int(w.get("at", 0))))), ARIAL_BOLD, 22, GOLD, "l", left + Vector2(14, 34), 320, 1.0, 30.0, true, Color(0, 0, 0, 0.5))
		_fwords("Chỉ khách mời vào được sảnh lễ. Sửa danh sách trước giờ lễ.", ARIAL_BOLD, 11, MUTED, "l", left + Vector2(14, 72), 320, 0.0, 16.0)
		_fwords("Huỷ trước giờ lễ: khung giờ được trả lại.", ARIAL_BOLD, 11, MUTED, "l", left + Vector2(14, 90), 320, 0.0, 16.0)
		_fbtn("hall", "Vào sảnh lễ", Rect2(left + Vector2(14, 112), Vector2(110, 28)), "blue", true, 12.0)
		_fbtn("unbook", "Huỷ lễ", Rect2(left + Vector2(132, 112), Vector2(80, 28)), "gray", not Love.busy("unbook"), 12.0)
		_book_summary(Rect2(left + Vector2(0, 160), Vector2(348, 72)))
		_fwords("%d khách mời" % picked.size(), ARIAL_BOLD, 13, Color.WHITE, "l", at + Vector2(16, PANEL.y - 40.0), 400, 1.0, 26.0)
		_fbtn("guests", "Lưu khách mời", Rect2(at + Vector2(PANEL.x - 148.0, PANEL.y - 42.0), Vector2(132, 30)), "blue", 
			str(w.get("phase", "wait")) == "wait" and not Love.busy("guests"), 14.0)
	_paint_guests(at + Vector2(376, 46))
	if hall_named():
		_paint_hall_name(at + Vector2(376, 46 + 28 + GUEST_ROW * float(GUEST_SHOWN_NAMED) + 8.0 + 8.0))


func _book_legend(at: Vector2) -> void :
	_fround(Rect2(at + Vector2(0, 3), Vector2(16, 12)), Color("1a2c45", 0.9), 3.0, Color(1, 1, 1, 0.12), 1.0)
	var used: float = _fwords("xám = đã kín / đã qua", ARIAL_BOLD, 11, MUTED, "l", at + Vector2(22, 0), 150, 0.0, 18.0)
	var x: float = 22.0 + used + 18.0
	_fgrad(Rect2(at + Vector2(x, 3), Vector2(16, 12)), GOLD_TOP, GOLD_LOW, Color(BTN_GOLD_EDGE, 0.9), 3.0, 1.0)
	_fwords("cam = đang chọn", ARIAL_BOLD, 11, MUTED, "l", at + Vector2(x + 22.0, 0), 120, 0.0, 18.0)


func _book_summary(box: Rect2) -> void :
	_fround(box, CARD, 8.0, CARD_EDGE, 1.0)
	var tier: int = int(Love.wcouple().get("ringTier", 0))
	var art: Texture2D = Love.ring_tex(pack, tier)
	var x: float = 12.0
	if art != null:
		draw_texture_rect(art, Rect2((box.position + Vector2(10, 14)) * _f, Vector2(44, 44) * _f), false)
		x = 64.0
	var ring_name: String = Love.ring_name(tier)
	_fwords("Nhẫn cưới: %s" % (ring_name if not ring_name.is_empty() else "chưa có"), ARIAL_BOLD, 13, GOLD, "l", box.position + Vector2(x, 6), box.size.x - x - 10.0, 1.0, 20.0, true, Color(0, 0, 0, 0.45))
	_fwords("Mỗi khách chúc phúc: +%d thân mật · tối đa %d" % [Love.wrule("blessPoints", 10), Love.wrule("blessCap", 200)], 
		ARIAL_BOLD, 11, Color.WHITE, "l", box.position + Vector2(x, 27), box.size.x - x - 10.0, 0.0, 18.0)
	_fwords("Khách mời %d/%d · chỉ khách mời vào được sảnh lễ" % [picked.size(), Love.wrule("maxGuests", 20)], 
		ARIAL_BOLD, 11, MUTED, "l", box.position + Vector2(x, 46), box.size.x - x - 10.0, 0.0, 18.0)


func friends_list() -> Array:
	var out: Array = []
	if client == null:
		return out
	for brief: Variant in client.friends.values():
		if brief is Dictionary and int(brief.get("m_accountId", 0)) > 0:
			out.append(brief)
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		var ao: int = int(a.get("m_online", 0))
		var bo: int = int(b.get("m_online", 0))
		if ao != bo:
			return ao > bo
		return str(a.get("m_name", "")) < str(b.get("m_name", "")))
	return out

func _paint_guests(at: Vector2) -> void :
	var cap: int = Love.wrule("maxGuests", 20)
	_fwords("Khách mời %d/%d" % [picked.size(), cap], ARIAL_BOLD, 13, GOLD, "l", at, 208, 1.0, 24.0)
	var rows_shown: int = guest_shown()
	var box: Rect2 = Rect2(at + Vector2(0, 28), Vector2(208, GUEST_ROW * float(rows_shown) + 8.0))
	_fround(box, CARD, 8.0, CARD_EDGE, 1.0)
	_guest_rect = Rect2(box.position * _f, box.size * _f)
	var rows: Array = friends_list()
	gfirst = clampi(gfirst, 0, maxi(0, rows.size() - rows_shown))
	if rows.is_empty():
		_fwords("Chưa có bạn bè để mời.", ARIAL_BOLD, 12, MUTED, "c", box.position, box.size.x, 0.0, box.size.y)
	var editable: bool = Love.wedding().is_empty() or str(Love.wedding().get("phase", "wait")) == "wait"
	for i in range(gfirst, mini(rows.size(), gfirst + rows_shown)):
		var brief: Dictionary = rows[i]
		var acct: int = int(brief.get("m_accountId", 0))
		var row: Vector2 = box.position + Vector2(8, 4 + float(i - gfirst) * GUEST_ROW)
		var on: bool = picked.has(acct)
		var usable: bool = editable and (on or picked.size() < cap)
		_fcheck(row + Vector2(0, 5), on, usable)
		var online: bool = int(brief.get("m_online", 0)) != 0
		_fround(Rect2(row + Vector2(22, 9), Vector2(6, 6)), ONLINE if online else Color(MUTED, 0.4), 3.0)
		_fwords(str(brief.get("m_name", "")), ARIAL_BOLD, 12, Color.WHITE if usable or on else Color(MUTED, 0.6), "l", row + Vector2(34, 0), 150, 0.0, GUEST_ROW)
		if usable:
			_hit("guest:%d" % acct, Rect2(row * _f, Vector2(192, GUEST_ROW) * _f), false)
	if rows.size() > rows_shown:
		var track: Rect2 = Rect2(box.position + Vector2(box.size.x - 7.0, 4), Vector2(4, box.size.y - 8.0))
		_fround(track, Color(0, 0, 0, 0.35), 2.0)
		var most: int = rows.size() - rows_shown
		var thumb: float = maxf(20.0, track.size.y * float(rows_shown) / float(rows.size()))
		_fround(Rect2(Vector2(track.position.x, track.position.y + (track.size.y - thumb) * float(gfirst) / float(most)), Vector2(4, thumb)), Color(GLASS_EDGE, 0.75), 2.0)






func _hall_plan(hall: Dictionary) -> Dictionary:
	if hall.is_empty():
		return {"high": 220.0}
	var phase: String = str(hall.get("phase", "wait"))
	var role: String = str(hall.get("role", "guest"))
	var guests: int = (hall.get("guests", []) as Array).size()
	var said: int = (hall.get("blessings", []) as Array).size()
	var list_h: float = float(clampi(guests, 1, 8)) * 20.0 + 8.0 + (18.0 if guests > 8 else 0.0)
	var chips: Array = []
	if role == "guest" and phase == "open" and hall.get("blessed") != true:
		chips = bless_chips(Love.bless_lines(), PANEL.x - 32.0)
	var chips_h: float = 0.0
	for r: Rect2 in chips:
		chips_h = maxf(chips_h, r.end.y)
	var talk_h: float = 40.0 if said == 0 and phase == "wait" else float(clampi(said, 2, 6 if chips.is_empty() else 4)) * 20.0 + 8.0
	var col_h: float = maxf(maxf(list_h, talk_h), 48.0 if said == 0 and phase == "wait" else 88.0)
	talk_h = col_h
	var foot: bool = not note.is_empty() or (role == "couple" and phase == "wait") or (role == "guest" and (hall.get("blessed") == true or phase == "wait"))
	var body_end: float = 150.0 + col_h + (8.0 + chips_h if not chips.is_empty() else 0.0)
	return {"col_h": col_h, "talk_h": talk_h, "chips": chips, "foot": foot, 
		"foot_y": body_end + 12.0, "high": body_end + (12.0 + 30.0 + 12.0 if foot else 16.0)}


func bless_chips(lines: Array, wide: float) -> Array:
	var out: Array = []
	var font: Font = _face(ARIAL_BOLD)
	var f: float = maxf(_f, 0.01)
	var x: float = 0.0
	var y: float = 0.0
	for line: Variant in lines:
		var w: float = minf(wide, ceilf(font.get_string_size(str(line), HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(12.0 * f))).x / f) + 22.0)
		if x > 0.0 and x + w > wide:
			x = 0.0
			y += 26.0 + 6.0
		out.append(Rect2(Vector2(x, y), Vector2(w, 26)))
		x += w + 6.0

	var k: int = 0
	while k < out.size():
		var row_y: float = (out[k] as Rect2).position.y
		var last: int = k
		while last + 1 < out.size() and is_equal_approx((out[last + 1] as Rect2).position.y, row_y):
			last += 1
		var shift: float = floorf((wide - (out[last] as Rect2).end.x) / 2.0)
		for j in range(k, last + 1):
			out[j] = Rect2((out[j] as Rect2).position + Vector2(shift, 0), (out[j] as Rect2).size)
		k = last + 1
	return out


func _hall_banner(heads: Rect2) -> float:
	var full: Texture2D = Love.hall_tex()
	if full != null:
		draw_texture_rect(full, Rect2(heads.position * _f, heads.size * _f), false)
		return floorf(heads.size.x * 0.2)
	_fgrad(heads, Color("1b5aa3", 0.9), Color("103d78", 0.9), Color(GLASS_EDGE, 0.9), 8.0, 1.0)
	var tex: Texture2D = pack.picture(Love.HALL_ART) if pack != null else null
	if tex == null:
		return 0.0
	var cut: Rect2 = Love.HALL_ART_CUT
	var h: float = heads.size.y - 4.0
	var dest: Rect2 = Rect2(heads.position + Vector2(2, 2), Vector2(floorf(cut.size.x * h / cut.size.y), h))
	_art_end(tex, cut, dest)
	var mid: float = (heads.position.x + heads.size.x / 2.0) * _f
	draw_set_transform(Vector2(2.0 * mid, 0), 0.0, Vector2(-1, 1))
	_art_end(tex, cut, dest)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return dest.size.x * 0.6


func _art_end(tex: Texture2D, cut: Rect2, dest: Rect2) -> void :
	var solid: float = 0.6
	var steps: int = 8
	draw_texture_rect_region(tex, Rect2(dest.position * _f, Vector2(dest.size.x * solid, dest.size.y) * _f), Rect2(cut.position, Vector2(cut.size.x * solid, cut.size.y)))
	for i in range(steps):
		var a: float = solid + (1.0 - solid) * float(i) / float(steps)
		var b: float = solid + (1.0 - solid) * float(i + 1) / float(steps)
		draw_texture_rect_region(tex, Rect2((dest.position + Vector2(dest.size.x * a, 0)) * _f, Vector2(dest.size.x * (b - a), dest.size.y) * _f), 
			Rect2(cut.position + Vector2(cut.size.x * a, 0), Vector2(cut.size.x * (b - a), cut.size.y)), Color(1, 1, 1, 1.0 - (float(i) + 0.5) / float(steps)))

func _paint_hall(at: Vector2, high: float) -> void :
	var hall: Dictionary = _hall()
	var named: String = str(hall.get("hallName", "")).strip_edges()
	_title(at, "Lễ đường · " + named if not named.is_empty() else "Lễ đường")
	if hall.is_empty():
		_fwords("Đang mở sảnh lễ…", ARIAL_BOLD, 14, MUTED, "c", at + Vector2(16, 46), PANEL.x - 32.0, 0.0, high - 70.0)
		return
	var plan: Dictionary = _hall_plan(hall)
	var phase: String = str(hall.get("phase", "wait"))
	var left: int = int(hall.get("left", 0)) - int(Time.get_ticks_msec() / 1000.0 - _hall_got)
	var heads: Rect2 = Rect2(at + Vector2(16, 44), Vector2(PANEL.x - 32.0, 74))
	var art_w: float = _hall_banner(heads)
	var mid: float = heads.position.x + heads.size.x / 2.0
	var inner: float = maxf(8.0, art_w)
	_fwords(str(hall.get("aName", "")), ARIAL_BOLD, 17, Color.WHITE, "r", Vector2(heads.position.x + inner, heads.position.y + 8.0), mid - heads.position.x - inner - 18.0, 1.0, 26.0, true, Color(0, 0, 0, 0.6))
	Love.draw(self, Rect2(Vector2(mid - 11.0, heads.position.y + 10.0) * _f, Vector2(22, 22) * _f), 1.0, 1.0, 1)
	_fwords(str(hall.get("bName", "")), ARIAL_BOLD, 17, Color.WHITE, "l", Vector2(mid + 18.0, heads.position.y + 8.0), heads.size.x / 2.0 - inner - 18.0, 1.0, 26.0, true, Color(0, 0, 0, 0.6))
	var line: String = "Lễ cưới lúc %s" % str(hall.get("time", ""))
	match phase:
		"wait":
			line = "Lễ bắt đầu sau %s · %s" % [Love.clock(left), str(hall.get("time", ""))]
		"open":
			line = "Đang cử hành · còn %s" % Love.clock(left)
		"done":
			line = "Lễ cưới đã kết thúc"
	var ring_name: String = Love.ring_name(int(hall.get("ringTier", 0)))
	if not ring_name.is_empty():
		line = "%s · %s" % [ring_name, line]
	_fwords(line, ARIAL_BOLD, 13, GOLD, "c", heads.position + Vector2(inner, 40), heads.size.x - 2.0 * inner, 1.0, 24.0, true, Color(0, 0, 0, 0.6))
	var col_h: float = float(plan.get("col_h", 88.0))

	var guests: Array = (hall.get("guests", []) as Array).filter( func(g: Variant) -> bool: return g is Dictionary)
	var joined: int = guests.filter( func(g: Dictionary) -> bool: return g.get("joined") == true).size()
	var col: Vector2 = at + Vector2(16, 128)
	_fwords("Khách mời %d/%d đã vào" % [joined, guests.size()], ARIAL_BOLD, 12, GOLD, "l", col, 200, 0.0, 18.0)
	var gbox: Rect2 = Rect2(col + Vector2(0, 22), Vector2(200, col_h))
	_fround(gbox, CARD, 8.0, CARD_EDGE, 1.0)
	if guests.is_empty():
		_fwords("Chưa mời ai.", ARIAL_BOLD, 12, MUTED, "c", gbox.position, gbox.size.x, 0.0, gbox.size.y)
	var fits: int = clampi(int((col_h - 8.0) / 20.0), 1, guests.size()) if guests.size() > 0 else 0
	var shown: int = fits if guests.size() <= fits else fits - 1
	for i in range(shown):
		var g: Dictionary = guests[i]
		var row: Vector2 = gbox.position + Vector2(10, 4 + float(i) * 20.0)
		_fround(Rect2(row + Vector2(0, 7), Vector2(6, 6)), ONLINE if g.get("joined") == true else Color(MUTED, 0.4), 3.0)
		_fwords(str(g.get("name", "")), ARIAL_BOLD, 12, Color.WHITE, "l", row + Vector2(12, 0), 112, 0.0, 20.0)
		var mark: String = "đã chúc" if g.get("blessed") == true else ("đã vào" if g.get("joined") == true else "")
		_fwords(mark, ARIAL_BOLD, 11, GOLD if g.get("blessed") == true else MUTED, "r", row + Vector2(124, 0), 56, 0.0, 20.0)
	if guests.size() > shown:
		_fwords("+%d khách" % (guests.size() - shown), ARIAL_BOLD, 11, MUTED, "l", gbox.position + Vector2(22, 4 + float(shown) * 20.0), 160, 0.0, 20.0)

	var right: Vector2 = at + Vector2(228, 128)
	var role: String = str(hall.get("role", "guest"))
	var head: String = "Lời chúc"
	if role == "couple":
		head = "Lời chúc · thân mật +%d/%d" % [int(hall.get("blessTotal", 0)), int(hall.get("blessCap", Love.wrule("blessCap", 200)))]
	_fwords(head, ARIAL_BOLD, 12, GOLD, "l", right, 356, 0.0, 18.0)
	var bbox: Rect2 = Rect2(right + Vector2(0, 22), Vector2(356, float(plan.get("talk_h", 88.0))))
	_fround(bbox, CARD, 8.0, CARD_EDGE, 1.0)
	var said: Array = (hall.get("blessings", []) as Array).filter( func(b: Variant) -> bool: return b is Dictionary)
	var talk_fits: int = maxi(1, int((bbox.size.y - 8.0) / 20.0))
	if said.is_empty():
		_fwords("Chưa có lời chúc." if phase != "wait" else "Lời chúc mở khi tới giờ lễ.", ARIAL_BOLD, 12, MUTED, "c", bbox.position, bbox.size.x, 0.0, bbox.size.y)
	var from: int = maxi(0, said.size() - talk_fits)
	for i in range(from, said.size()):
		var b: Dictionary = said[i]
		var row: Vector2 = bbox.position + Vector2(10, 4 + float(i - from) * 20.0)
		var used: float = _fwords(str(b.get("name", "")) + ":", ARIAL_BOLD, 12, GOLD, "l", row, 110, 0.0, 20.0)
		_fwords(str(b.get("text", "")), ARIAL_BOLD, 12, Color.WHITE, "l", row + Vector2(used + 6.0, 0), 336.0 - used - 6.0, 0.0, 20.0)

	var chips: Array = plan.get("chips", [])
	var lines: Array = Love.bless_lines()
	for k in range(mini(chips.size(), lines.size())):
		var chip: Rect2 = chips[k]
		_fbtn("bless:%d" % k, str(lines[k]), Rect2(at + Vector2(16, 150.0 + col_h + 8.0) + chip.position, chip.size), "blue", not Love.busy("bless"), 12.0)

	if plan.get("foot") != true:
		return
	var foot: Vector2 = at + Vector2(16, float(plan.get("foot_y", high - 42.0)))
	var status: String = ""
	var tone: Color = MUTED
	if not note.is_empty():
		status = note
		tone = ONLINE if note_ok else Color("ff8a8a")
	elif role == "guest" and hall.get("blessed") == true:
		status = "Bạn đã chúc phúc đôi uyên ương."
		tone = ONLINE
	elif role == "guest" and phase == "wait":
		status = "Tới giờ lễ hãy quay lại để chúc phúc."
	if not status.is_empty():
		_fwords(status, ARIAL_BOLD, 12, tone, "l", foot, 320 if role == "couple" and phase == "wait" else PANEL.x - 32.0, 0.0, 30.0)
	if role == "couple" and phase == "wait":
		_fbtn("edit", "Sửa khách mời", Rect2(Vector2(at.x + PANEL.x - 240.0, foot.y), Vector2(132, 30)), "blue", true, 13.0)
		_fbtn("unbook", "Huỷ lễ", Rect2(Vector2(at.x + PANEL.x - 100.0, foot.y), Vector2(84, 30)), "gray", not Love.busy("unbook"), 13.0)



func _activate(id: String) -> void :
	var parts: PackedStringArray = id.split(":")
	var num: int = int(parts[1]) if parts.size() > 1 else 0
	match parts[0]:
		"close":
			close()
		"day":
			if num != day:
				day = num
				pick_at = 0
				_slots_at = -1000.0
				Love.want_slots(client, day)
		"slot":
			pick_at = 0 if pick_at == num else num
		"guest":
			if picked.has(num):
				picked.erase(num)
			elif picked.size() < Love.wrule("maxGuests", 20):
				picked[num] = true
		"book":
			if pick_at > 0:
				note = ""
				Love.book(client, pick_at, picked.keys())
		"guests":
			var w: Dictionary = Love.wedding()
			if not w.is_empty():
				note = ""
				Love.set_guests(client, int(w.get("id", 0)), picked.keys())
		"unbook":
			var mine: int = int(Love.wedding().get("id", 0))
			if mine > 0:
				ASK.open_for(self, "unbook", "", mine)
		"edit":
			mode = "book"
			_seeded = -1
		"hall":
			mode = "hall"
			wid = 0
			_hall_at = -1000.0
		"bless":
			Love.bless(client, hall_id(), num)
		"hfield":
			_hall_edit.grab_focus()
		"hname":
			if hall_named() and not Love.busy("hall_name") and _hall_edit.text.strip_edges() != str(Love.wcouple().get("hallOwn", "")):
				note = ""
				Love.set_hall_name(client, _hall_edit.text)
			_hall_edit.release_focus()
	queue_redraw()

func _wheel(step: int, at: Vector2) -> void :
	if mode == "book" and _guest_rect.has_point(at):
		gfirst = clampi(gfirst + step, 0, maxi(0, friends_list().size() - guest_shown()))
		queue_redraw()

func _input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree() or not (event is InputEventKey):
		return
	var key: InputEventKey = event
	if key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
		close()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
