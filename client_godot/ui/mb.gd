extends "tev_window.gd"












signal closed(note: String)

const MbAtlas = preload("mb_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const LobbyBar = preload("lobby_bar.gd")
const MB_TIP: String = "Battle Pass"
const MB_ICON: String = "btn_battlepass"
const MB_WORD: String = "word_battlepass_t"
const MB_POLL_TICKS: int = 120
const MB_ARM_MS: float = 4000.0
const MB_COL_STEP: float = 80.0
const MB_VIEW: Rect2 = Rect2(266, 66, 480, 228)
const MB_FREE_Y: float = 47.0
const MB_PAID_Y: float = 145.0
const MB_DRAG_PX: float = 6.0
const MB_GOLD: Color = Color("ffe45c")
const MB_INK: Color = Color("3a1d08")
const MB_LIGHT: Color = Color("e8f1ff")
const MB_MUTED: Color = Color("a9bedf")
const MB_GREEN: Color = Color("90ff90")
const MB_FULL: Color = Color("ff8f8f")
const MB_INK_RIM: Color = Color("fff1b0")
const MB_TRACK: Color = Color("0b1630")
const MB_TRACK_EDGE: Color = Color("6f8fb8")
const MB_DOT: Color = Color("ffd200")
const MB_TABS: Array = ["Phần thưởng", "Nhiệm vụ", "Đặc quyền", "Đổi Huy Hiệu"]
const MB_PACK_ART: Array = ["pack_basic", "pack_plus20", "pack_plus40"]

static var s_mb_shown: bool = false
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = MB_POLL_TICKS
var mb_visible: bool = false
var loaded: bool = false
var season: String = ""
var days: int = 0
var level: int = 0
var into: int = 0
var per: int = 1
var max_level: int = 0
var points: int = 0
var premium: bool = false
var price: int = 0
var claimable: int = 0
var token: String = ""
var per100: int = 0
var badges: int = 0
var badge_into: int = 0
var badge_per: int = 1
var tank_end: float = 0.0
var server_now: float = 0.0
var now_at: float = 0.0
var levels: Array = []
var missions: Array = []
var packs: Array = []
var tanks: Array = []
var shop: Array = []
var tab: int = 0
var panel: String = ""
var scroll: float = 0.0
var scroll_to: float = -1.0
var drag_mode: int = 0
var dragged: bool = false
var dirty: bool = false
var aim: bool = false
var arm_at: float = 0.0
var arm_key: String = ""
var buy_n: int = 1
var choose: int = 0
var pick: int = -1
var fly_from: Vector2 = Vector2(-1, -1)
var flyers: Array = []
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _o: Vector2 = Vector2.ZERO
var _cut: Rect2 = Rect2()
var _claim_spots: Array = []
var _down_x: float = 0.0
var _down_scroll: float = 0.0
var _last_x: float = 0.0
var _last_t: float = 0.0
var _vel: float = 0.0
var _halo: GradientTexture2D = null
var _tag_rx: RegEx = RegEx.create_from_string("<(/?)(font|b|br)\\b([^>]*)>")
var _color_rx: RegEx = RegEx.create_from_string("color\\s*=\\s*['\"]#?([0-9a-fA-F]{6})['\"]")
var _size_rx: RegEx = RegEx.create_from_string("size\\s*=\\s*['\"]([0-9]+)['\"]")

func _setup() -> void :
	art_dir = ""
	win_size = Vector2(760, 500)
	super ()

static func reset_statics() -> void :
	s_mb_shown = false


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = MB_POLL_TICKS
	mb_visible = false
	loaded = false
	season = ""
	days = 0
	level = 0
	into = 0
	per = 1
	max_level = 0
	points = 0
	premium = false
	price = 0
	claimable = 0
	token = ""
	per100 = 0
	badges = 0
	badge_into = 0
	badge_per = 1
	tank_end = 0.0
	server_now = 0.0
	now_at = 0.0
	levels = []
	missions = []
	packs = []
	tanks = []
	shop = []
	tab = 0
	panel = ""
	scroll = 0.0
	scroll_to = -1.0
	drag_mode = 0
	dragged = false
	dirty = false
	aim = false
	arm_at = 0.0
	arm_key = ""
	buy_n = 1
	choose = 0
	pick = -1
	fly_from = Vector2(-1, -1)
	flyers = []
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(MbAtlas.FILE):
			_atlas = load(MbAtlas.FILE) as Texture2D
	return _atlas

func load_art() -> void :
	_art_asked = true

func art_pending() -> int:
	return 0 if _art_asked else -1

func retry_art() -> void :
	pass

func art(name: String) -> Texture2D:
	if _parts.has(name):
		return _parts[name]
	var sheet_tex: Texture2D = _load_atlas()
	if sheet_tex == null or not MbAtlas.R.has(name):
		return null
	var row: Array = MbAtlas.R[name]
	var cut: AtlasTexture = AtlasTexture.new()
	cut.atlas = sheet_tex
	cut.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = cut
	return cut

func button_icon() -> Texture2D:
	return art(MB_ICON)

func button_word() -> Texture2D:
	return art(MB_WORD)




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/mission-book.xml?t=" + str(int(now_ms())), "poll")


func beat() -> void :
	if opened:
		if arm_at != 0.0 and now_ms() - arm_at > MB_ARM_MS:
			arm_at = 0.0
			arm_key = ""
			_rebuild()
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = MB_POLL_TICKS
		if not loading:
			poll()

func button_visible() -> bool:
	return mb_visible


func button_dot() -> bool:
	return mb_visible and claimable > 0

func idle() -> bool:
	return action.is_empty() or action == "poll"

func maxed() -> bool:
	return max_level > 0 and level >= max_level


func open() -> void :
	if opened or not mb_visible:
		return
	tab = 0
	arm_at = 0.0
	arm_key = ""
	panel = ""
	scroll = 0.0
	scroll_to = -1.0
	drag_mode = 0
	dirty = false
	aim = true
	show_window()
	load_art()
	if pack != null:
		pack.load_events()
		pack.load_quest()
		pack.load_bag()
	_rebuild()
	if idle():
		poll()


func close(note: String = "") -> void :
	if not opened:
		return
	arm_at = 0.0
	arm_key = ""
	panel = ""
	drag_mode = 0
	flyers.clear()
	hide_window()
	poll_in = MB_POLL_TICKS
	closed.emit(note)

func leave() -> void :
	close()



func _load(prefix: String, what: String) -> void :
	fetch(prefix + str(int(now_ms())), what)


func _failed(what: String) -> void :
	if what != "" and what != "poll":
		tip("Không kết nối được máy chủ, hãy thử lại.")
		if opened:
			_rebuild()


func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_xml(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	var parsed: bool = xml != null
	var notice: String = ""
	var got: String = ""
	var before: int = level
	if parsed:
		var at: Dictionary = xml["at"]
		notice = str(at.get("notice", ""))
		got = str(at.get("got", ""))
		mb_visible = str(at.get("visible", "")) == "1"
		s_mb_shown = mb_visible
		if mb_visible:
			var rows: Array = []
			for node: Dictionary in kids(xml, "lv"):
				rows.append(level_of(node["at"]))
			var tasks: Array = []
			for node: Dictionary in kids(xml, "ms"):
				var m: Dictionary = node["at"]
				tasks.append({"period": str(m.get("period", "")), "name": str(m.get("name", "")), "value": _int(m, "value"), 
					"target": maxi(1, _int(m, "target")), "points": _int(m, "points"), "done": str(m.get("done", "")) == "1"})
			var offers: Array = []
			for node: Dictionary in kids(xml, "pk"):
				var k: Dictionary = node["at"]
				offers.append({"id": str(k.get("id", "")), "name": str(k.get("name", "")), "price": _int(k, "price"), "lv": _int(k, "lv"), 
					"ok": str(k.get("ok", "")) == "1"})
			var cars: Array = []
			for node: Dictionary in kids(xml, "pt"):
				var c: Dictionary = node["at"]
				cars.append({"id": _int(c, "id"), "name": str(c.get("name", "")), "lv": _int(c, "lv")})
			var goods: Array = []
			for node: Dictionary in kids(xml, "bx"):
				var b: Dictionary = node["at"]
				var pair: PackedStringArray = str(b.get("i", "")).split(":")
				goods.append({"id": str(b.get("id", "")), "i": maxi(0, TevWheel.as_int(pair[0])), 
					"c": TevWheel.as_int(pair[1]) if pair.size() > 1 else 1, "cost": _int(b, "cost"), "limit": _int(b, "limit"), "used": _int(b, "used")})
			season = str(at.get("season", ""))
			days = _int(at, "days")
			level = _int(at, "level")
			into = _int(at, "into")
			per = maxi(1, _int(at, "per"))
			max_level = _int(at, "max") if _int(at, "max") > 0 else rows.size()
			points = _int(at, "points")
			premium = str(at.get("premium", "")) == "1"
			price = _int(at, "price")
			claimable = _int(at, "claimable")
			token = str(at.get("token", ""))
			per100 = _int(at, "per100")
			badges = _int(at, "badges")
			badge_into = _int(at, "badgeInto")
			badge_per = maxi(1, _int(at, "badgePer"))
			tank_end = _num(at, "tankEnd")
			server_now = _num(at, "now")
			now_at = now_ms()
			levels = rows
			missions = tasks
			packs = offers
			tanks = cars
			shop = goods
		else:
			claimable = 0
		loaded = true
	if not parsed and what != "" and what != "poll":
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if what == "buy" or what == "level" or what == "badge":
		arm_at = 0.0
		arm_key = ""
	if parsed and what == "buy" and premium:
		tab = 0
		aim = true
	if parsed and what == "level" and level > before:
		panel = ""
		aim = true
	if parsed and what == "claim" and panel == "choose":
		var entry: Variant = entry_of(choose)
		if entry == null or int(entry["p"]) == 2:
			panel = ""
	if parsed and not got.is_empty() and (what == "claim" or what == "badge"):
		fly(got)
	else:
		fly_from = Vector2(-1, -1)
	if opened:
		if mb_visible:
			_rebuild()
		else:
			close()
	if not notice.is_empty():
		tip(notice)


static func _num(at: Dictionary, key: String) -> float:
	var value: float = TevWheel.as_number(str(at.get(key, "")))
	return 0.0 if is_nan(value) else value

static func _int(at: Dictionary, key: String) -> int:
	return TevWheel.as_int(str(at.get(key, "")))


static func level_of(at: Dictionary) -> Dictionary:
	var free: PackedStringArray = str(at.get("fi", "")).split(":")
	var paid: PackedStringArray = str(at.get("pi", "")).split(":")
	var gifts: Array = []
	if not str(at.get("pc", "")).is_empty():
		for one: String in str(at["pc"]).split(","):
			var pair: PackedStringArray = one.split(":")
			if TevWheel.as_int(pair[0]) > 0:
				gifts.append({"i": TevWheel.as_int(pair[0]), "c": TevWheel.as_int(pair[1]) if pair.size() > 1 else 1})
	return {"n": _int(at, "n"), "fi": maxi(0, TevWheel.as_int(free[0])), "fc": TevWheel.as_int(free[1]) if free.size() > 1 else 0, 
		"pi": maxi(0, TevWheel.as_int(paid[0])), "pc": TevWheel.as_int(paid[1]) if paid.size() > 1 else 0, 
		"f": _int(at, "f"), "p": _int(at, "p"), "ch": gifts}

func entry_of(n: int) -> Variant:
	return levels[n - 1] if n >= 1 and n <= levels.size() else null



func max_scroll() -> float:
	return maxf(0.0, float(levels.size()) * MB_COL_STEP - MB_VIEW.size.x)

func snap(x: float) -> float:
	return clampf(roundf(x / MB_COL_STEP) * MB_COL_STEP, 0.0, max_scroll())

func rubber(x: float) -> float:
	var top: float = max_scroll()
	if x < 0.0:
		return x / 3.0
	if x > top:
		return top + (x - top) / 3.0
	return x

func scroll_for(n: int) -> float:
	return snap(float(n - 3) * MB_COL_STEP)

func ready_at(n: int) -> bool:
	var entry: Variant = entry_of(n)
	return entry != null and (int(entry["f"]) == 1 or int(entry["p"]) == 1)


func focus_level() -> int:
	for i in levels.size():
		if ready_at(i + 1):
			return i + 1
	return clampi(level + 1, 1, maxi(1, levels.size()))


func magnet(from: float, to: float) -> int:
	var a: int = int(roundf(from / MB_COL_STEP)) + 3
	var b: int = int(roundf(to / MB_COL_STEP)) + 3
	if a == b:
		return 0
	var step: int = 1 if b > a else -1
	var n: int = a + step
	while (step > 0 and n <= b) or (step < 0 and n >= b):
		if ready_at(n):
			return n
		n += step
	return 0

func glide(x: float) -> void :
	scroll_to = x


func _rebuild() -> void :
	if drag_mode != 0:
		dirty = true
		return
	dirty = false
	if not opened or not loaded:
		return
	if tab == 0:
		scroll = clampf(scroll, 0.0, max_scroll())
		if scroll_to >= 0.0:
			scroll_to = snap(scroll_to)
		if aim:
			aim = false
			var target: float = scroll_for(focus_level())
			if absf(target - scroll) >= 1.0:
				scroll_to = target
	if panel == "level":
		buy_n = clampi(buy_n, 1, maxi(1, max_level - level))
	elif panel == "choose":
		var entry: Variant = entry_of(choose)
		if entry == null or (entry["ch"] as Array).is_empty():
			panel = ""


func _anim() -> void :
	if tab == 0 and loaded and scroll_to >= 0.0 and drag_mode < 2:
		var gap: float = scroll_to - scroll
		if absf(gap) < 0.75:
			scroll = scroll_to
			scroll_to = -1.0
		else:
			scroll += gap * 0.24
	var now: float = now_ms()
	for i in range(flyers.size() - 1, -1, -1):
		if now - float(flyers[i]["at"]) >= 1620.0:
			flyers.remove_at(i)



func _view_rect() -> Rect2:
	return Rect2(_o + MB_VIEW.position, MB_VIEW.size)

func _track_rect() -> Rect2:
	return Rect2(_o + Vector2(MB_VIEW.position.x, MB_VIEW.end.y + 6.0), Vector2(MB_VIEW.size.x, 20.0))

func _strip_live() -> bool:
	return opened and loaded and tab == 0 and panel.is_empty()

func _gui_input(event: InputEvent) -> void :
	var released: bool = false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var at: Vector2 = event.position / _f
		if event.pressed and _strip_live():
			if _track_rect().has_point(at):
				drag_mode = 3
				dragged = true
				scroll_to = -1.0
				_vel = 0.0
				track_to(at.x)
			elif _view_rect().has_point(at):
				drag_mode = 1
				dragged = false
				_down_x = at.x
				_down_scroll = scroll
				_last_x = at.x
				_last_t = now_ms()
				_vel = 0.0
				scroll_to = -1.0
		elif not event.pressed:
			released = true
	elif event is InputEventMouseMotion and drag_mode != 0:
		strip_move(event.position.x / _f)
	super (event)
	if released:
		end_drag()


func track_to(x: float) -> void :
	var full: float = maxf(1.0, float(levels.size()) * MB_COL_STEP)
	scroll = clampf((x - _o.x - MB_VIEW.position.x) / MB_VIEW.size.x * full - MB_VIEW.size.x / 2.0, 0.0, max_scroll())


func strip_move(x: float) -> void :
	if drag_mode == 3:
		track_to(x)
		return
	if drag_mode == 1:
		if absf(x - _down_x) < MB_DRAG_PX:
			return
		drag_mode = 2
		dragged = true
		_press = ""
	if drag_mode != 2:
		return
	var now: float = now_ms()
	var dt: float = maxf(1.0, now - _last_t)
	_vel = _vel * 0.4 - (x - _last_x) / dt * 0.6
	_last_x = x
	_last_t = now
	scroll = rubber(_down_scroll - (x - _down_x))


func end_drag() -> void :
	var mode: int = drag_mode
	if mode == 0:
		return
	drag_mode = 0
	if now_ms() - _last_t > 90.0:
		_vel = 0.0
	if dirty:
		_rebuild()
	if not (opened and loaded and tab == 0) or mode < 2:
		return
	var dest: float = snap(scroll + (_vel * 280.0 if mode == 2 else 0.0))
	if mode == 2:
		var stop: int = magnet(scroll, dest)
		if stop > 0:
			dest = scroll_for(stop)
	glide(dest)


func _wheel(step: int, at: Vector2) -> void :
	if not (opened and loaded and tab == 0) or not _view_rect().has_point(at / _f) or drag_mode != 0 or not panel.is_empty():
		return
	var base: float = scroll_to if scroll_to >= 0.0 else scroll
	glide(snap(base + (2.0 if step > 0 else -2.0) * MB_COL_STEP))




func armed(key: String) -> bool:
	return arm_at != 0.0 and arm_key == key and now_ms() - arm_at <= MB_ARM_MS

func confirm(key: String) -> bool:
	if armed(key):
		arm_at = 0.0
		arm_key = ""
		return true
	arm_at = now_ms()
	arm_key = key
	_rebuild()
	return false

func _activate(id: String) -> void :
	if id == "shut":
		close()
		return
	if id.begins_with("cell:"):
		on_cell(id)
		return
	var parts: PackedStringArray = id.split(":")
	var kind: String = parts[0]
	var arg: String = parts[1] if parts.size() > 1 else ""
	if kind == "tab":
		if arg.to_int() != tab:
			tab = arg.to_int()
			arm_at = 0.0
			arm_key = ""
			_rebuild()
	elif kind == "openpass":
		tab = 2
		panel = ""
		_rebuild()
	elif kind == "levels":
		panel = "level"
		buy_n = 1
		arm_at = 0.0
		arm_key = ""
		_rebuild()
	elif kind == "lv":
		buy_n = maxi(1, mini(maxi(1, max_level - level), buy_n + arg.to_int()))
		arm_at = 0.0
		arm_key = ""
		_rebuild()
	elif kind == "close":
		panel = ""
		arm_at = 0.0
		arm_key = ""
		_rebuild()
	elif kind == "goto":
		if drag_mode == 0:
			glide(scroll_for(arg.to_int()))
	elif kind == "claimall":
		if not idle() or claimable <= 0:
			return
		fly_from = _hit_centre(id)
		_load("/mission-book-claim.xml?all=1&t=", "claim")
		_rebuild()
	elif kind == "pick":
		pick = arg.to_int()
		_rebuild()
	elif kind == "pickok":
		if not idle() or pick < 0:
			return
		fly_from = _hit_centre(id)
		_load("/mission-book-claim.xml?level=%d&track=premium&pick=%d&t=" % [choose, pick], "claim")
		_rebuild()
	elif kind == "pack":
		if not idle() or premium or not confirm(id):
			return
		_load("/mission-book-buy.xml?k=" + TevWheel.uri_component(token) + "&pack=" + TevWheel.uri_component(arg) + "&t=", "buy")
		_rebuild()
	elif kind == "lvbuy":
		if not idle() or level >= max_level or not confirm(id):
			return
		_load("/mission-book-level.xml?k=" + TevWheel.uri_component(token) + "&n=%d&from=%d&t=" % [buy_n, level], "level")
		_rebuild()
	elif kind == "shop":
		if not idle() or not premium or not confirm(id):
			return
		fly_from = _hit_centre(id)
		_load("/mission-book-badge.xml?k=" + TevWheel.uri_component(token) + "&id=" + TevWheel.uri_component(arg) + "&q=1&t=", "badge")
		_rebuild()


func on_cell(key: String) -> void :
	var parts: PackedStringArray = key.split(":")
	if parts.size() < 4 or dragged:
		return
	var n: int = parts[1].to_int()
	var entry: Variant = entry_of(n)
	if parts[2] == "premium" and entry != null and not (entry["ch"] as Array).is_empty():
		panel = "choose"
		choose = n
		pick = -1
		_rebuild()
		return
	if parts[3].to_int() == 1:
		if not idle():
			return
		fly_from = _hit_centre(key)
		_load("/mission-book-claim.xml?level=%d&track=%s&t=" % [n, parts[2]], "claim")
		_rebuild()
	elif parts[3].to_int() == 0:
		tip("Mở Battle Pass để nhận phần thưởng này." if parts[2] == "premium" and not premium else "Cần đạt cấp %d để nhận phần thưởng này." % n)


func _hit_centre(id: String) -> Vector2:
	for i in range(_hits.size() - 1, -1, -1):
		if str(_hits[i][0]) == id:
			return (_hits[i][1] as Rect2).get_center() / _f
	return Vector2(-1, -1)



func _bag_point() -> Vector2:
	for row: Dictionary in LobbyBar.live(self):
		var bag: Rect2 = row.get("bag", Rect2())
		if bag.has_area():
			return bag.get_center() / _f
	return Vector2(_fw / 2.0, _fh / 2.0)


func fly(got: String) -> void :
	var bag: Vector2 = _bag_point()
	var view: Rect2 = _view_rect()
	var has_view: bool = opened and loaded and tab == 0
	var left: float = view.position.x + 36.0 if has_view else 36.0
	var right: float = view.end.x - 36.0 if has_view else _fw - 36.0
	var used: Dictionary = {}
	var slots: Dictionary = {}
	var now: float = now_ms()
	var n: int = 0
	for one: String in got.split(","):
		var pair: PackedStringArray = one.split(":")
		var id: int = maxi(0, TevWheel.as_int(pair[0]))
		var count: int = TevWheel.as_int(pair[1]) if pair.size() > 1 else 1
		if id == 0 or n >= 10:
			continue
		var from: Vector2 = Vector2(-1, -1)
		for k in _claim_spots.size():
			var spot: Array = _claim_spots[k]
			if not used.has(k) and int(spot[0]) == id and ( not has_view or view.has_point(spot[1])):
				used[k] = true
				from = spot[1]
				break
		if from.x < 0.0 and has_view:
			from = fly_from if fly_from.x >= 0.0 and view.has_point(fly_from) else view.get_center()
		if from.x < 0.0:
			from = fly_from
		if from.x < 0.0:
			from = (_o + win_size / 2.0) if opened else Vector2(_fw / 2.0, _fh / 2.0)
		var key: String = "%d,%d" % [int(from.x), int(from.y)]
		var slot: int = int(slots.get(key, 0))
		slots[key] = slot + 1
		var side: float = 0.0 if slot == 0 else (1.0 if slot % 2 == 1 else -1.0) * ceilf(float(slot) / 2.0) * 62.0
		var peak: Vector2 = Vector2(maxf(left, minf(right, from.x + side)), maxf(36.0, from.y - 64.0))
		var ctl: Vector2 = Vector2(peak.x + (bag.x - peak.x) * 0.3, maxf(10.0, minf(peak.y, bag.y) - 110.0))
		flyers.append({"id": id, "c": count, "p0": from, "p1": peak, "ctl": ctl, "p2": bag, "at": now + float(n) * 90.0, "ping": n == 0})
		n += 1
	fly_from = Vector2(-1, -1)

func _draw_flyers() -> void :
	var now: float = now_ms()
	for f: Dictionary in flyers:
		var t: float = now - float(f["at"])
		if t < 0.0:
			continue
		var p0: Vector2 = f["p0"]
		var p1: Vector2 = f["p1"]
		var p2: Vector2 = f["p2"]
		if t >= 1300.0:
			var k: float = (t - 1300.0) / 320.0
			if k < 1.0:
				var rs: float = 0.4 + k * 1.1
				var ra: float = 1.0 - k
				draw_arc(p2 * _f, 26.0 * rs * _f, 0.0, TAU, 48, Color(MB_GOLD, 0.35 * ra), 8.0 * rs * _f, true)
				draw_arc(p2 * _f, 22.0 * rs * _f, 0.0, TAU, 48, Color(MB_GOLD, ra), 3.0 * rs * _f, true)
			continue
		var pos: Vector2 = p0
		var grow: float = 1.0
		var alpha: float = 1.0
		if t < 450.0:
			var k: float = t / 450.0
			var e: float = 1.0 - pow(1.0 - k, 3.0)
			pos = p0.lerp(p1, e) - Vector2(0.0, sin(k * PI) * 26.0)
			grow = 1.2 * k / 0.6 if k < 0.6 else 1.2 - 0.2 * (k - 0.6) / 0.4
		elif t < 700.0:
			pos = p1 - Vector2(0.0, sin((t - 450.0) / 250.0 * PI) * 4.0)
		else:
			var e: float = pow((t - 700.0) / 600.0, 2.0)
			var ctl: Vector2 = f["ctl"]
			pos = p1 * (1.0 - e) * (1.0 - e) + ctl * 2.0 * e * (1.0 - e) + p2 * e * e
			grow = 1.0 - 0.7 * e
			alpha = 1.0 - (e - 0.85) / 0.15 * 0.5 if e > 0.85 else 1.0
		_flyer(int(f["id"]), int(f["c"]), pos, grow, alpha)


func _flyer(id: int, count: int, centre: Vector2, grow: float, alpha: float) -> void :
	if grow <= 0.01:
		return
	if _halo == null:
		var ramp: Gradient = Gradient.new()
		ramp.set_color(0, Color(MB_GOLD, 0.75))
		ramp.set_color(1, Color(MB_GOLD, 0.0))
		_halo = GradientTexture2D.new()
		_halo.gradient = ramp
		_halo.fill = GradientTexture2D.FILL_RADIAL
		_halo.fill_from = Vector2(0.5, 0.5)
		_halo.fill_to = Vector2(1.0, 0.5)
		_halo.width = 128
		_halo.height = 128
	var half: float = 52.0 * grow
	draw_texture_rect(_halo, Rect2((centre - Vector2(half, half)) * _f, Vector2(half, half) * 2.0 * _f), false, Color(1, 1, 1, alpha))
	_item_icon(id, Rect2(centre - Vector2(26, 24.5) * grow, Vector2(52, 49) * grow), alpha)
	if count > 1:
		var fs: int = maxi(6, roundi(15.0 * grow * _f))
		var word: String = "x" + str(count)
		var wide: float = ARIAL_BOLD.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var base: Vector2 = (centre + Vector2(30.0, 8.0) * grow) * _f - Vector2(wide, 0.0) + Vector2(0.0, ARIAL_BOLD.get_ascent(fs))
		draw_string_outline(ARIAL_BOLD, base, word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, maxi(1, roundi(3.0 * grow * _f)), Color(MB_INK, alpha))
		draw_string(ARIAL_BOLD, base, word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color(1, 1, 1, alpha))




func _blit(name: String, x: float, y: float, w: float, h: float, alpha: float = 1.0, tint: Color = Color.WHITE) -> Rect2:
	var rect: Rect2 = Rect2((_o + Vector2(x, y)) * _f, Vector2(w, h) * _f)
	var sheet_tex: Texture2D = _load_atlas()
	if sheet_tex == null or not MbAtlas.R.has(name):
		return rect
	var row: Array = MbAtlas.R[name]
	_tex_cut(sheet_tex, rect, Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3])), Color(tint, tint.a * alpha))
	return rect

func _tex_cut(texture: Texture2D, rect: Rect2, src: Rect2, color: Color) -> void :
	if not _cut.has_area():
		draw_texture_rect_region(texture, rect, src, color)
		return
	var inter: Rect2 = rect.intersection(_cut)
	if not inter.has_area():
		return
	var k: Vector2 = src.size / rect.size
	draw_texture_rect_region(texture, inter, Rect2(src.position + (inter.position - rect.position) * k, inter.size * k), color)

func _fill(x: float, y: float, w: float, h: float, color: Color) -> void :
	var rect: Rect2 = Rect2((_o + Vector2(x, y)) * _f, Vector2(w, h) * _f)
	if _cut.has_area():
		rect = rect.intersection(_cut)
	if rect.has_area():
		draw_rect(rect, color)


func _item_icon(id: int, box: Rect2, alpha: float = 1.0) -> void :
	if pack == null or id <= 0:
		return
	var path: String = str(item(id)["art"])
	var texture: Texture2D = pack.picture(path) if not path.is_empty() else null
	if texture == null:
		return
	var k: float = minf(box.size.x / maxf(1.0, float(texture.get_width())), box.size.y / maxf(1.0, float(texture.get_height())))
	var shown: Vector2 = Vector2(texture.get_size()) * k
	_tex_cut(texture, Rect2((box.get_center() - shown / 2.0) * _f, shown * _f), Rect2(Vector2.ZERO, Vector2(texture.get_size())), Color(1, 1, 1, alpha))


func _runs(html: String, px: float, color: Color, bold: bool) -> Array:
	var lines: Array = [[]]
	var stack: Array = [[color, px, bold]]
	var cursor: int = 0
	for found: RegExMatch in _tag_rx.search_all(html):
		var chunk: String = html.substr(cursor, found.get_start() - cursor)
		cursor = found.get_end()
		if not chunk.is_empty():
			var top: Array = stack.back()
			(lines.back() as Array).append({"t": unescape(chunk), "c": top[0], "px": top[1], "b": top[2]})
		var tag: String = found.get_string(2)
		if tag == "br":
			lines.append([])
		elif found.get_string(1) == "/":
			if stack.size() > 1:
				stack.pop_back()
		else:
			var top2: Array = (stack.back() as Array).duplicate()
			if tag == "b":
				top2[2] = true
			else:
				var c: RegExMatch = _color_rx.search(found.get_string(3))
				var s: RegExMatch = _size_rx.search(found.get_string(3))
				if c != null:
					top2[0] = Color("#" + c.get_string(1))
				if s != null:
					top2[1] = float(s.get_string(1).to_int())
			stack.append(top2)
	var rest: String = html.substr(cursor)
	if not rest.is_empty():
		var last: Array = stack.back()
		(lines.back() as Array).append({"t": unescape(rest), "c": last[0], "px": last[1], "b": last[2]})
	return lines

func _run_font(run: Dictionary) -> Font:
	return ARIAL_BOLD if bool(run["b"]) else ARIAL

func _run_size(run: Dictionary) -> int:
	return maxi(6, roundi(float(run["px"]) * _f))

func _line_wide(line: Array) -> float:
	var wide: float = 0.0
	for run: Dictionary in line:
		wide += _run_font(run).get_string_size(str(run["t"]), HORIZONTAL_ALIGNMENT_LEFT, -1, _run_size(run)).x
	return wide

func _line_ascent(line: Array, px: float) -> float:
	var top: float = ARIAL_BOLD.get_ascent(maxi(6, roundi(px * _f)))
	for run: Dictionary in line:
		top = maxf(top, _run_font(run).get_ascent(_run_size(run)))
	return top

func _line_high(line: Array, px: float) -> float:
	var high: float = ARIAL_BOLD.get_height(maxi(6, roundi(px * _f)))
	for run: Dictionary in line:
		high = maxf(high, _run_font(run).get_height(_run_size(run)))
	return high


func _line_draw(line: Array, left: float, base: float, rim: Color, rim_px: float, alpha: float) -> void :
	for pass_i in 2:
		var x: float = left
		for run: Dictionary in line:
			var font: Font = _run_font(run)
			var fs: int = _run_size(run)
			var word: String = str(run["t"])
			var color: Color = run["c"]
			if pass_i == 0:
				_glyphs(font, fs, word, Vector2(x, base), Color(rim, rim.a * alpha), maxi(1, roundi(rim_px * _f)))
			else:
				_glyphs(font, fs, word, Vector2(x, base), Color(color, color.a * alpha), 0)
			x += font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x


func _glyphs(font: Font, fs: int, word: String, origin: Vector2, color: Color, outline: int) -> void :
	if not _cut.has_area():
		if outline > 0:
			draw_string_outline(font, origin, word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, outline, color)
		else:
			draw_string(font, origin, word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, color)
		return
	var ts: TextServer = TextServerManager.get_primary_interface()
	var viewport: Viewport = get_viewport()
	var over: float = maxf(1.0, viewport.get_oversampling()) if viewport != null else 1.0
	var shaped: TextLine = TextLine.new()
	shaped.add_string(word, font, roundi(fs * over))
	var canvas: RID = get_canvas_item()
	var pen: float = origin.x * over
	for glyph: Dictionary in ts.shaped_text_get_glyphs(shaped.get_rid()):
		var face: RID = glyph.get("font_rid", RID())
		var index: int = int(glyph.get("index", 0))
		var cache: Vector2i = Vector2i(int(glyph.get("font_size", 0)), roundi(outline * over))
		if face.is_valid() and ts.font_get_glyph_texture_idx(face, cache, index) >= 0:
			var sheet_rid: RID = ts.font_get_glyph_texture_rid(face, cache, index)
			var uv: Rect2 = ts.font_get_glyph_uv_rect(face, cache, index)
			var box: Vector2 = ts.font_get_glyph_size(face, cache, index)
			var spot: Vector2 = (Vector2(pen, origin.y * over) + glyph.get("offset", Vector2.ZERO) + ts.font_get_glyph_offset(face, cache, index)).floor()
			var dst: Rect2 = Rect2(spot / over, box / over)
			var inter: Rect2 = dst.intersection(_cut)
			if inter.has_area() and dst.has_area():
				var k: Vector2 = uv.size / dst.size
				RenderingServer.canvas_item_add_texture_rect_region(canvas, inter, sheet_rid, 
					Rect2(uv.position + (inter.position - dst.position) * k, inter.size * k), color)
		pen += float(glyph.get("advance", 0.0)) * int(glyph.get("repeat", 1))


func _lab(html: String, x: float, y: float, w: float, px: float, align: String = "c", color: Color = Color.WHITE, ink: bool = false, alpha: float = 1.0) -> void :
	var line: Array = _runs(html, px, MB_INK if ink else color, true)[0]
	var wide: float = _line_wide(line)
	var left: float = (_o.x + x + 2.0) * _f
	if align == "c":
		left = (_o.x + x + w / 2.0) * _f - wide / 2.0
	elif align == "r":
		left = (_o.x + x + w - 2.0) * _f - wide
	var base: float = (_o.y + y + 2.0) * _f + _line_ascent(line, px)
	_line_draw(line, left, base, Color(MB_INK_RIM, 0.7) if ink else Color(SHADOW, 0.9), 1.5 if ink else 2.0, alpha)


func _txt(html: String, x: float, y: float, w: float, px: float, align: String = "c", color: Color = Color.WHITE, bold: bool = false) -> void :
	var room: float = maxf(1.0, (w - 4.0) * _f)
	var lines: Array = []
	for line: Array in _runs(html, px, color, bold):
		lines.append_array(_wrap(line, room))
	var top: float = (_o.y + y + 2.0) * _f
	for line: Array in lines:
		var wide: float = _line_wide(line)
		var left: float = (_o.x + x + 2.0) * _f
		if align == "c":
			left = (_o.x + x + w / 2.0) * _f - wide / 2.0
		elif align == "r":
			left = (_o.x + x + w - 2.0) * _f - wide
		_line_draw(line, left, top + _line_ascent(line, px), Color(SHADOW, 0.9), 2.0, 1.0)
		top += _line_high(line, px) + 2.0 * _f


func _wrap(line: Array, room: float) -> Array:
	var out: Array = []
	var cur: Array = []
	var wide: float = 0.0
	for run: Dictionary in line:
		var font: Font = _run_font(run)
		var fs: int = _run_size(run)
		var words: PackedStringArray = str(run["t"]).split(" ")
		for wi in words.size():
			var word: String = words[wi] + (" " if wi < words.size() - 1 else "")
			if word.is_empty():
				continue
			var ww: float = font.get_string_size(word.strip_edges(false, true), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
			if wide > 0.0 and wide + ww > room:
				out.append(_trim(cur))
				cur = []
				wide = 0.0
			cur.append({"t": word, "c": run["c"], "px": run["px"], "b": run["b"]})
			wide += font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	out.append(_trim(cur))
	return out

func _trim(line: Array) -> Array:
	if not line.is_empty():
		var last: Dictionary = (line.back() as Dictionary).duplicate()
		last["t"] = str(last["t"]).strip_edges(false, true)
		line[line.size() - 1] = last
	return line

static func esc(text: String) -> String:
	return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")

static func gold(text: String) -> String:
	return "<font color='#ffe45c'>" + text + "</font>"


func _key(id: String, plate: String, w: float, h: float, label: String, enabled: bool, x: float, y: float, note: String = "") -> void :
	var px: float = 14.0 if h >= 40.0 else (13.0 if h >= 34.0 else 12.0)
	var lit: bool = enabled and _hover == id and _press.is_empty()
	var gray: String = "bp2_" + plate + "@gray"
	var rect: Rect2 = _blit(gray if not enabled and MbAtlas.R.has(gray) else "bp2_" + plate, x, y, w, h, 1.0, 
		Color(1.2, 1.2, 1.2) if lit else (Color(0.85, 0.85, 0.85) if enabled and _press == id else Color.WHITE))
	if not label.is_empty():
		var ink: bool = plate.begins_with("btn_gold") or plate == "tab_on"
		_lab(label, x, y + float(int((h - px * 1.25 - 4.0) / 2.0)), w, px, "c", MB_LIGHT if plate == "tab_off" else MB_GOLD, ink, 1.0 if enabled else 0.8)
	if enabled:
		_hit(id, rect, false)
	if not note.is_empty():
		tip_area(Rect2(_o + Vector2(x, y), Vector2(w, h)), 0, note)


func _cell(plate: String, x: float, y: float, id: int, count: int, alpha: float = 1.0) -> Rect2:
	var rect: Rect2 = _blit("bp2_" + plate, x, y, 74, 74)
	_item_icon(id, Rect2(_o + Vector2(x + 11.0, y + 13.0), Vector2(52, 49)), alpha)
	if count > 1:
		_lab("x" + str(count), x + 22.0, y + 8.0, 46.0, 11.0, "r")
	var area: Rect2 = Rect2(_o + Vector2(x, y), Vector2(74, 74))
	if _cut.has_area():
		area = area.intersection(Rect2(_cut.position / _f, _cut.size / _f))
	if area.has_area():
		tip_area(area, id, "")
	return rect



func _body(at: Vector2) -> void :
	_o = at
	_claim_spots.clear()
	var is_maxed: bool = maxed()
	var part: float = 1.0 if is_maxed else clampf(float(into) / float(per), 0.0, 1.0)
	_blit("bp2_bp_frame", 0, 0, 760, 500)
	_blit("bp2_crest_hero", 42, 20, 132, 120)
	_blit("bp2_title_l", 22, 140, 172, 36)
	_lab(esc(season if not season.is_empty() else "Mùa mới") + "  <font color='#a9bedf' size='11'>· còn " + gold(str(days)) + " ngày</font>", 
		14, 178, 188, 12)
	_blit("bp2_medal", 66, 198, 84, 84)
	_lab(str(level), 66, 219, 84, 24)
	_lab("CẤP", 66, 250, 84, 9, "c", MB_GOLD)
	_blit("bp2_bar_back", 28, 292, 160, 16)
	if part > 0.0:
		var wide: float = maxf(6.0, roundf(156.0 * part))
		var row: Array = MbAtlas.R.get("bp2_bar_fill", [0, 0, 1, 1])
		var sheet_tex: Texture2D = _load_atlas()
		if sheet_tex != null:
			_tex_cut(sheet_tex, Rect2((_o + Vector2(30, 294)) * _f, Vector2(wide, 12) * _f), 
				Rect2(float(row[0]), float(row[1]), minf(float(row[2]), wide * float(row[2]) / 156.0), float(row[3])), Color.WHITE)
	_lab("TỐI ĐA" if is_maxed else "%d / %d" % [into, per], 28, 291, 160, 10)
	_lab("Tổng điểm: " + gold(str(points)), 14, 312, 188, 11)
	var line: String = ("Huy Hiệu: " + gold(str(badges)) if premium else "Đã đạt cấp tối đa") if is_maxed\
	else "Lên cấp %d: còn %s điểm" % [level + 1, gold(str(maxi(0, per - into)))]
	_lab(line, 14, 329, 188, 11, "c", MB_MUTED)
	if premium:
		_blit("bp2_pass_on", 24, 356, 168, 40)
		_lab("PASS ĐÃ MỞ", 56, 366, 124, 13, "c", MB_GOLD)
	else:
		_key("openpass", "btn_gold_l", 168, 40, "MỞ BATTLE PASS", true, 24, 356, "Xem 3 gói Battle Pass và đặc quyền.")
	if not is_maxed:
		_key("levels", "btn_dark_m", 168, 34, "Mua cấp", loaded and per100 > 0, 24, 404, "Mua thêm cấp bằng xu: mỗi 100 điểm %d xu." % per100)
	elif premium:
		_key("tab:3", "btn_dark_m", 168, 34, "Đổi Huy Hiệu", true, 24, 404)
	else:
		_key("maxed", "btn_dark_m", 168, 34, "Đã tối đa", false, 24, 404)
	_txt("Mỗi " + gold(str(per)) + " điểm lên 1 cấp<br>Nhiệm vụ · PvP · Phụ Bản", 14, 448, 188, 10, "c", MB_MUTED)
	for i in MB_TABS.size():
		_key("tab:%d" % i, "tab_on" if tab == i else "tab_off", 120, 36, str(MB_TABS[i]), true, 214.0 + float(i) * 122.0, 18)
	if not loaded:
		_lab("Đang tải...", 210, 260, 536, 14)
	elif tab == 0:
		_rewards()
	elif tab == 1:
		_missions()
	elif tab == 2:
		_perks()
	else:
		_shop()
	if tab <= 1:
		var label: String = "Đang nhận..." if action == "claim" else ("Nhận tất cả (%d)" % claimable if claimable > 0 else "Nhận tất cả")
		_key("claimall", "btn_gold_l", 168, 40, label, action.is_empty() and claimable > 0, 562, 392 if tab == 0 else 420)
	if loaded and panel == "level":
		_level_panel()
	elif loaded and panel == "choose":
		_chooser()

func _chrome(at: Vector2) -> void :
	_o = at
	var rect: Rect2 = _blit("bp2_btn_close", 706, 18, 36, 36, 1.0, Color(1.2, 1.2, 1.2) if _hover == "shut" and _press.is_empty() else Color.WHITE)
	_hit("shut", rect, false)
	tip_area(Rect2(at + Vector2(706, 18), Vector2(36, 36)), 0, "Đóng")
	_draw_flyers()


func _rewards() -> void :
	var vx: float = MB_VIEW.position.x
	var vy: float = MB_VIEW.position.y
	_blit("bp2_lane_free", vx, vy + MB_FREE_Y - 9.0, MB_VIEW.size.x, 92)
	_blit("bp2_lane_pass", vx, vy + MB_PAID_Y - 9.0, MB_VIEW.size.x, 92)
	_blit("bp2_tag_free", 214, vy + MB_FREE_Y - 9.0, 50, 92)
	_blit("bp2_tag_pass", 214, vy + MB_PAID_Y - 9.0, 50, 92)
	_lab("MIỄN", 214, vy + MB_FREE_Y + 19.0, 50, 11)
	_lab("PHÍ", 214, vy + MB_FREE_Y + 35.0, 50, 11)
	_lab("PASS", 214, vy + MB_PAID_Y + (27.0 if premium else 19.0), 50, 12, "c", MB_INK, true)
	if not premium:
		_blit("lock_pass", 232, vy + MB_PAID_Y + 42.0, 15, 18)
	var total: int = levels.size()
	var first: int = maxi(0, int(floorf(scroll / MB_COL_STEP)) - 1)
	var last: int = mini(total - 1, int(floorf((scroll + MB_VIEW.size.x) / MB_COL_STEP)) + 1)
	_cut = Rect2((_o + MB_VIEW.position) * _f, MB_VIEW.size * _f)
	for i in range(first, last + 1):
		_column(i, vx + roundf(float(i) * MB_COL_STEP - scroll), vy)
	_cut = Rect2()
	_track()
	_lab("Kéo dải quà hoặc lăn chuột để xem đủ %d cấp · dải tự dừng ở quà nhận được" % total, vx, vy + MB_VIEW.size.y + 25.0, MB_VIEW.size.x, 10, "c", MB_MUTED)
	_showcase()


func _column(i: int, x: float, y: float) -> void :
	var entry: Dictionary = levels[i]
	var n: int = int(entry["n"])
	var fill: float = 0.0
	if n <= level:
		fill = MB_COL_STEP
	elif n == level + 1:
		fill = MB_COL_STEP * clampf(float(into) / float(per), 0.0, 1.0)
	_fill(x, y + 9.0, MB_COL_STEP, 4, Color(MB_TRACK, 0.95))
	if fill > 0.0:
		_fill(x, y + 9.0, fill, 4, MB_GOLD)
	if n == level:
		for g in 3:
			var grow: float = 2.0 + float(g) * 2.5
			_fill(x + 12.0 - grow, y - grow, 56.0 + grow * 2.0, 22.0 + grow * 2.0, Color(MB_GOLD, 0.16))
	_blit("bp2_node_on" if n <= level else "bp2_node_off", x + 12.0, y, 56, 22)
	_lab("Cấp %d" % n, x + 12.0, y + 3.0, 56, 10, "c", MB_LIGHT, n <= level)
	_strip_cell(x + 3.0, y + MB_FREE_Y, n, "free", int(entry["fi"]), int(entry["fc"]), int(entry["f"]), [])
	_strip_cell(x + 3.0, y + MB_PAID_Y, n, "premium", int(entry["pi"]), int(entry["pc"]), int(entry["p"]), entry["ch"])


func _strip_cell(x: float, y: float, n: int, track: String, id: int, count: int, state: int, gifts: Array) -> void :
	var choosing: bool = not gifts.is_empty()
	if id == 0:
		_blit("bp2_cell_empty", x, y, 74, 74)
		return
	if state == 1:
		_blit("bp2_cell_glow", x - 8.0, y - 8.0, 90, 90)
	var alpha: float = 0.55 if state == 2 else (0.7 if state == 0 else 1.0)
	var rect: Rect2 = _cell("cell_pass" if track == "premium" else "cell_free", x, y, id, 1 if choosing else count, alpha)
	var key: String = "cell:%d:%s:%d" % [n, track, state]
	var shown: Rect2 = rect.intersection(_cut)
	if shown.has_area():
		_hit(key, shown, false)
	if state == 1:
		_claim_spots.append([id, _o + Vector2(x - 1.0 + 38.0, y + 3.0 + 34.0)])
		_lab("CHỌN QUÀ" if choosing else "NHẬN", x, y + 57.0, 74, 11, "c", MB_GREEN)
	elif state == 2:
		_blit("bp2_stamp_done", x + 44.0, y + 44.0, 30, 30)
	elif track == "premium" and not premium:
		_blit("lock_pass", x + 6.0, y + 6.0, 15, 18)
	if choosing and state != 1:
		_lab("CHỌN 1", x, y + 58.0, 74, 10, "c", MB_GOLD)

func _track() -> void :
	var total: float = maxf(1.0, float(levels.size()))
	var full: float = maxf(1.0, float(levels.size()) * MB_COL_STEP)
	var top: Vector2 = _o + Vector2(MB_VIEW.position.x, MB_VIEW.end.y + 10.0)
	var wide: float = MB_VIEW.size.x
	_round(Rect2((top + Vector2(0, 2)) * _f, Vector2(wide, 8) * _f), Color(MB_TRACK, 0.95), 8.0, Color(MB_TRACK_EDGE, 0.7), 2.0)
	if level > 0:
		_round(Rect2((top + Vector2(1, 3)) * _f, Vector2(maxf(6.0, minf(wide - 2.0, (wide - 2.0) * float(level) / total)), 6) * _f), Color(MB_GOLD, 0.5), 6.0)
	for i in levels.size():
		if ready_at(i + 1):
			draw_circle((top + Vector2((float(i) + 0.5) / total * wide, 6.0)) * _f, 3.0 * _f, MB_DOT, true, -1.0, true)
	var left: float = clampf(scroll / full * wide, 0.0, wide)
	var thumb: float = minf(wide - left, wide * wide / full)
	if thumb > 0.0:
		_round(Rect2((top + Vector2(left, 0)) * _f, Vector2(thumb, 12) * _f), Color(MB_LIGHT, 0.2), 12.0, Color(MB_LIGHT, 0.95), 2.0)
	_hit("track", Rect2((top + Vector2(0, -4)) * _f, Vector2(wide, 20) * _f), false)


func _showcase() -> void :
	_blit("bp2_showcase", 212, 346, 532, 132)
	if levels.is_empty():
		return
	var n: int = maxi(1, mini(levels.size(), level + 1))
	while n < levels.size():
		var probe: Dictionary = levels[n - 1]
		if n % 10 == 0 or not (probe["ch"] as Array).is_empty():
			break
		n += 1
	var entry: Dictionary = levels[n - 1]
	var gifts: Array = entry["ch"]
	var id: int = 0
	var count: int = 0
	if not gifts.is_empty():
		id = int(gifts[0]["i"])
		count = int(gifts[0]["c"])
	elif int(entry["pi"]) > 0:
		id = int(entry["pi"])
		count = int(entry["pc"])
	else:
		id = int(entry["fi"])
		count = int(entry["fc"])
	var is_maxed: bool = maxed()
	_lab("QUÀ PASS CẤP TỐI ĐA" if is_maxed else "QUÀ LỚN TIẾP THEO · CẤP %d" % n, 228, 357, 320, 11, "l", MB_GOLD)
	if id == 0:
		return
	var rect: Rect2 = _cell("cell_pass", 228, 380, id, count)
	_hit("goto:%d" % n, rect, false)
	_lab(esc(item_name(id)) + (" x%d" % count if count > 1 else ""), 314, 388, 240, 14, "l", MB_GOLD)
	var sub: String = ""
	if not gifts.is_empty():
		sub = "Chọn 1 trong %d món quà" % gifts.size()
	elif is_maxed:
		sub = "Bạn đã đi hết Battle Pass mùa này" if premium else "Mở Battle Pass để nhận quà PASS"
	else:
		sub = "Còn " + gold(str(maxi(0, n * per - points))) + " điểm nữa"
	_lab(sub, 314, 412, 240, 11, "l", MB_LIGHT)
	if not premium and not is_maxed:
		_lab("Cần mở Battle Pass", 314, 432, 240, 11, "l", MB_MUTED)


func _missions() -> void :
	var daily: Array = []
	var weekly: Array = []
	for m: Dictionary in missions:
		if str(m["period"]) == "w":
			weekly.append(m)
		else:
			daily.append(m)
	var heads: Array = ["Hằng ngày  <font color='#a9bedf' size='10'>(làm mới lúc 0h)</font>", "Hằng tuần  <font color='#a9bedf' size='10'>(làm mới thứ Hai)</font>"]
	var lists: Array = [daily, weekly]
	for side in 2:
		var x: float = 214.0 if side == 0 else 482.0
		var rows: Array = lists[side]
		_blit("bp2_panel_list", x, 66, 262, 300)
		_lab(heads[side], x + 12.0, 77, 238, 12, "l", MB_GOLD)
		if rows.is_empty():
			_lab("Chưa có nhiệm vụ", x, 200, 262, 12, "c", MB_MUTED)
			continue
		for r in mini(6, rows.size()):
			var m: Dictionary = rows[r]
			var top: float = 108.0 + float(r) * 42.0
			var done: bool = bool(m["done"])
			_lab(esc(str(m["name"])), x + 12.0, top + 5.0, 166, 12, "l", MB_GREEN if done else Color.WHITE)
			_lab(("<font color='#90ff90'>Xong</font>" if done else "%d/%d" % [int(m["value"]), int(m["target"])]) + "  " + gold("+" + str(m["points"])), 
				x + 170.0, top + 6.0, 82, 11, "r")
			_round(Rect2((_o + Vector2(x + 14.0, top + 28.0)) * _f, Vector2(234, 5) * _f), Color(MB_TRACK, 0.95), 5.0)
			var wide: float = minf(234.0, float(int(234.0 * float(m["value"]) / float(maxi(1, int(m["target"]))))))
			if wide > 0.0:
				_round(Rect2((_o + Vector2(x + 14.0, top + 28.0)) * _f, Vector2(wide, 5) * _f), MB_GREEN if done else MB_GOLD, 5.0)
	_txt("Mỗi " + gold("<b>" + str(per) + "</b>") + " điểm lên 1 cấp. Đánh trận PvP và Phụ Bản cũng được cộng điểm.", 216, 422, 330, 11, "l", MB_MUTED)


func tank_left() -> String:
	if tank_end <= 0.0 or server_now <= 0.0:
		return ""
	var left: float = tank_end - server_now - (now_ms() - now_at) / 1000.0
	if left <= 0.0:
		return ""
	var secs: int = int(left)
	if secs >= 86400:
		return "%d ngày %d giờ" % [secs / 86400, (secs % 86400) / 3600]
	return "%d giờ %d phút" % [secs / 3600, (secs % 3600) / 60]


func _perks() -> void :
	var names: Array = []
	var tank_lv: int = 0
	for t: Dictionary in tanks:
		names.append(esc(str(t["name"])))
		tank_lv = maxi(tank_lv, int(t["lv"]))
	var status: String = ""
	if not premium:
		status = "<font color='#a9bedf'>Chỉ dành cho chủ Pass</font>"
	elif level >= tank_lv:
		status = "<font color='#90ff90'>Đang dùng ở mục Xe Tuần</font>"
	else:
		status = "<font color='#a9bedf'>Đạt cấp %d để nhận</font>" % tank_lv
	var last_pi: int = int((levels.back() as Dictionary)["pi"]) if not levels.is_empty() else 0
	var titles: Array = ["Quà PASS cả %d cấp" % max_level, "Xe tuần chủ Pass", "Huy Hiệu sau cấp %d" % max_level]
	var notes: Array = ["Cấp %d: " % max_level + gold(esc(item_name(last_pi))), 
		gold(" · ".join(PackedStringArray(names))) + "<br>" + status if not names.is_empty() else "Xe tuần đang được cập nhật", 
		"Mỗi " + gold(str(badge_per)) + " điểm thêm được 1 Huy Hiệu để đổi quà"]
	var icons: Array = [["bp2_perk_all", 277.0], ["bp2_perk_tank", 459.0], ["badge_hh_big", 641.0]]
	for i in 3:
		var left: float = 214.0 + float(i) * 182.0
		_blit("bp2_perk_tile", left, 66, 172, 128)
		_blit(str(icons[i][0]), float(icons[i][1]), 83, 48, 48)
		_lab(titles[i], left, 137, 172, 12, "c", MB_GOLD)
		_txt(notes[i], left + 6.0, 153, 160, 10, "c", MB_LIGHT)
	var tl: String = tank_left()
	if not tl.is_empty():
		tip_area(Rect2(_o + Vector2(396, 66), Vector2(172, 128)), 0, "Xe tuần đổi sau %s." % tl)
	for i in 3:
		var left: float = 214.0 + float(i) * 182.0
		_blit("bp2_pack_card", left, 202, 172, 276)
		if i >= packs.size():
			continue
		var k: Dictionary = packs[i]
		_blit(str(MB_PACK_ART[i]), left + 50.0, 214, 72, 72)
		_lab(esc(str(k["name"])), left + 6.0, 303, 160, 13, "c", MB_GOLD)
		var lv: int = int(k["lv"])
		_txt(("Mở hàng quà PASS cả mùa<br>+ nhận ngay " + gold("<b>%d</b>" % lv) + " cấp" if lv > 0 else "Mở hàng quà PASS cả mùa")
			+ "<br><font color='#a9bedf' size='10'>Quà các cấp đã đạt nhận được ngay</font>", left + 12.0, 336, 148, 11, "c", MB_LIGHT)
		var key: String = "pack:" + str(k["id"])
		var label: String = "Đã mở" if premium else ("Đang mở..." if action == "buy" else ("Xác nhận?" if armed(key) else "%d xu" % int(k["price"])))
		var note: String = ""
		if armed(key):
			note = "Bấm lần nữa để trả %d xu." % int(k["price"])
		elif not premium and not bool(k["ok"]):
			note = "Gói này vượt quá cấp %d, hãy chọn gói khác." % max_level
		_key(key, "btn_gold_m", 140, 34, label, not premium and bool(k["ok"]) and action.is_empty(), left + 16.0, 432, note)


func _shop() -> void :
	_blit("badge_hh_big", 216, 68, 36, 36)
	_lab("Huy Hiệu: " + gold(str(badges)), 258, 76, 176, 16, "l")
	var note: String = ""
	if not premium:
		note = "Chỉ chủ Battle Pass mới tích và đổi được Huy Hiệu."
	elif level < max_level:
		note = "Đạt cấp %d, mỗi %d điểm thêm được 1 Huy Hiệu." % [max_level, badge_per]
	if not note.is_empty():
		_lab(note, 440, 79, 300, 11, "l", MB_MUTED)
	else:
		var part: float = clampf(float(badge_into) / float(badge_per), 0.0, 1.0)
		_blit("bp2_bar_back", 440, 76, 160, 16)
		if part > 0.0:
			var wide: float = maxf(6.0, roundf(156.0 * part))
			var row: Array = MbAtlas.R.get("bp2_bar_fill", [0, 0, 1, 1])
			var sheet_tex: Texture2D = _load_atlas()
			if sheet_tex != null:
				_tex_cut(sheet_tex, Rect2((_o + Vector2(442, 78)) * _f, Vector2(wide, 12) * _f), 
					Rect2(float(row[0]), float(row[1]), minf(float(row[2]), wide * float(row[2]) / 156.0), float(row[3])), Color.WHITE)
		_lab("%d / %d" % [badge_into, badge_per], 440, 75, 160, 10)
		_lab("tới Huy Hiệu sau", 606, 78, 136, 11, "l", MB_MUTED)
	for i in mini(12, shop.size()):
		var b: Dictionary = shop[i]
		var left: float = 216.0 + float(i % 6) * 88.0
		var top: float = 112.0 + float(i / 6) * 184.0
		var full: bool = int(b["limit"]) > 0 and int(b["used"]) >= int(b["limit"])
		_blit("bp2_shop_card", left, top, 84, 176)
		_cell("cell_pass", left + 5.0, top + 8.0, int(b["i"]), int(b["c"]))
		_blit("badge_hh", left + 12.0, top + 93.0, 16, 16)
		_lab(str(b["cost"]), left + 30.0, top + 92.0, 48, 12, "l", MB_GOLD)
		_lab("Đã đổi %d/%d" % [int(b["used"]), int(b["limit"])], left, top + 113.0, 84, 10, "c", MB_FULL if full else MB_MUTED)
		var key: String = "shop:" + str(b["id"])
		var label: String = "Hết lượt" if full else ("Xác nhận?" if armed(key) else "Đổi")
		var cost: int = int(b["cost"])
		var tip_text: String = "Bấm lần nữa để đổi %d Huy Hiệu." % cost if armed(key) else "Đổi bằng %d Huy Hiệu (tối đa %d lần mỗi mùa)." % [cost, int(b["limit"])]
		_key(key, "btn_gold_s", 72, 26, label, not full and premium and badges >= cost and action.is_empty(), left + 6.0, top + 142.0, tip_text)


func _dim() -> void :
	_round(Rect2((_o + Vector2(8, 8)) * _f, Vector2(744, 484) * _f), Color(0, 0, 0, 0.6), 36.0)
	_hit("dim", Rect2((_o + Vector2(8, 8)) * _f, Vector2(744, 484) * _f), false)
	_tips.clear()

func level_cost(c: int) -> int:
	return ceili(float(maxi(0, (level + c) * per - points)) / 100.0) * per100


func _level_panel() -> void :
	var room: int = maxi(1, max_level - level)
	var count: int = clampi(buy_n, 1, room)
	buy_n = count
	var cost: int = level_cost(count)
	_dim()
	_blit("bp2_panel_modal", 150, 115, 460, 270)
	_key("close", "btn_close", 36, 36, "", true, 576, 121)
	_lab("MUA CẤP BATTLE PASS", 150, 129, 460, 15, "c", MB_GOLD)
	_lab("Cấp %d   →   " % level + gold("Cấp %d" % (level + count)), 150, 172, 460, 18)
	_key("lv:-5", "btn_sq", 44, 32, "−5", count > 1, 230, 205)
	_key("lv:-1", "btn_sq", 44, 32, "−", count > 1, 280, 205)
	_lab("%d cấp" % count, 330, 209, 100, 16)
	_key("lv:1", "btn_sq", 44, 32, "+", count < room, 436, 205)
	_key("lv:5", "btn_sq", 44, 32, "+5", count < room, 486, 205)
	var need: int = maxi(0, (level + count) * per - points)
	_lab("Cần thêm " + gold(str(need)) + " điểm  ·  mỗi 100 điểm " + gold(str(per100)) + " xu", 150, 258, 460, 12, "c", MB_LIGHT)
	var on: bool = armed("lvbuy")
	var label: String = "Đang mua..." if action == "level" else ("Xác nhận %d xu?" % cost if on else "Mua %d cấp · %d xu" % [count, cost])
	_key("lvbuy", "btn_gold_xl", 240, 40, label, action.is_empty() and per100 > 0 and level < max_level, 260, 300, 
		"Bấm lần nữa để trả %d xu." % cost if on else "")


func _chooser() -> void :
	var entry: Variant = entry_of(choose)
	var gifts: Array = entry["ch"] if entry != null else []
	if gifts.is_empty():
		return
	var can: bool = int(entry["p"]) == 1
	_dim()
	_blit("bp2_panel_modal", 150, 115, 460, 270)
	_key("close", "btn_close", 36, 36, "", true, 576, 121)
	_lab("QUÀ PASS CẤP %d · CHỌN 1 TRONG %d" % [choose, gifts.size()], 150, 129, 460, 15, "c", MB_GOLD)
	var first: int = 150 + int((460 - gifts.size() * 100) / 2) + 13
	for i in gifts.size():
		var cx: float = float(first + i * 100)
		if i == pick:
			_blit("bp2_cell_glow", cx - 8.0, 162, 90, 90)
		var rect: Rect2 = _cell("cell_pass", cx, 170, int(gifts[i]["i"]), int(gifts[i]["c"]))
		if can:
			_hit("pick:%d" % i, rect, false)
		_txt(esc(item_name(int(gifts[i]["i"]))), cx - 11.0, 246, 96, 10, "c", MB_GOLD if i == pick else Color.WHITE, true)
	var status: String = ""
	if int(entry["p"]) == 2:
		status = "Bạn đã nhận quà cấp này."
	elif can:
		status = "Đã chọn: " + gold(esc(item_name(int(gifts[pick]["i"])))) if pick >= 0 and pick < gifts.size() else "Bấm vào 1 món để chọn."
	else:
		status = "Mở Battle Pass và đạt cấp %d để chọn quà." % choose if not premium else "Đạt cấp %d để chọn quà." % choose
	_lab(status, 150, 278, 460, 12, "c", MB_LIGHT)
	_key("pickok", "btn_gold_xl", 240, 40, "Đang nhận..." if action == "claim" else "Nhận quà đã chọn", can and pick >= 0 and action.is_empty(), 260, 300)
