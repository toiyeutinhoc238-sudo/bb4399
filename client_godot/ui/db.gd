extends "tev_window.gd"









signal closed(note: String)

const DbAtlas = preload("db_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const MB_POLL_TICKS: int = 120
const MB_ARM_MS: float = 4000.0
const MB_GOLD: Color = Color("ffe45c")
const DB_TIP: String = "Cờ Tỉ Phú"
const DB_ICON: String = "btn_cotiphu"
const DB_WORD: String = "word_cotiphu_t"
const DB_W: float = 860.0
const DB_H: float = 590.0
const DB_ART: Array = ["db_bg", "stage_rays", "stage_disc", "bulb_on", "tile_start", "tile_item", "tile_chest", "tile_x2", "tile_fwd2", "tile_fwd3", 
	"tile_back2", "tile_back3", "tile_lit", "tile_lit_start", "die_f1", "die_f2", "die_f3", "die_f4", "die_f5", "die_f6", "die_tumble", "die_shadow", 
	"x2_badge", "teddy_idle", "teddy_jump", "teddy_land", "teddy_shadow", "btn_roll1", "btn_roll10", "btn_claim", "btn_help", "ticket_small", 
	"ms_reached", "ms_next", "ms_claimed", "fx_land_ring", "fx_sparkle", "fx_coin", "fx_confetti", "fx_chest_open", "fx_trail_dot", "fx_lap_banner", 
	"fx_rays_small"]
const DB_SHEETS: Dictionary = {
	"die_tumble": [128, 128, 4, 12], "fx_land_ring": [128, 80, 4, 8], "fx_sparkle": [48, 48, 3, 6], "fx_coin": [40, 40, 4, 8], 
	"fx_confetti": [24, 24, 4, 8], "fx_chest_open": [96, 104, 3, 6], "fx_trail_dot": [20, 20, 4, 4], "fx_lap_banner": [240, 88, 3, 6], 
	"ms_next": [80, 80, 3, 6], 
}
const DB_TILE_XY: Array = [180, 137, 244, 137, 307, 137, 371, 138, 436, 146, 497, 173, 525, 225, 531, 288, 531, 349, 532, 417, 507, 472, 459, 516, 
	398, 529, 336, 526, 272, 528, 208, 527, 149, 527, 87, 496, 53, 442, 49, 378, 51, 319, 49, 258, 66, 198, 113, 154]
const DB_BULB_XY: Array = [189, 93.5, 229, 93.5, 270, 93.5, 311, 93.5, 350, 94, 390, 93.5, 434, 94, 472.5, 103.5, 498.5, 120.5, 529, 145.5, 552, 178, 
	565, 211, 571, 247, 571, 283, 571, 321, 571, 358, 571, 395.5, 567, 435, 555, 473, 534, 504, 506, 533, 468, 555, 429, 566, 389, 568, 351, 568, 
	312, 568, 270, 568, 227, 568, 187, 568, 150, 565, 109, 555, 73, 535, 44, 504, 26, 474, 14, 434, 9, 396, 8, 357, 8, 321, 8, 281, 10, 245.5, 21, 
	202, 54, 149, 87, 121.5, 119, 106.5, 151, 96]
const DB_MS_XY: Array = [614, 175, 674.5, 175, 736, 175, 796.5, 174.5, 797.5, 263.5, 735.5, 263.5, 674.5, 263.5, 613.5, 263.5]
const DB_MS_FLAG: Array = [598, 132, 658, 132, 720, 132, 780, 132, 782, 221, 720, 221, 658, 221, 598, 221]
const DB_CHEST_XY: Array = [618, 463, 676.5, 463, 735.5, 463, 794.5, 463, 618, 518, 676.5, 518, 735.5, 518, 794.5, 518]
const DB_LAST_XY: Array = [247, 464, 291.5, 464, 335.5, 464, 380, 464]
const DB_RULES: String = "Tung xúc xắc để đi quanh bàn cờ, dừng ở ô nào nhận quà ô đó.\n• Ô x2: quà lần sau được nhân đôi.\n• Ô Rương: mở Rương Bí Ẩn.\n• Ô mũi tên: tiến hoặc lùi thêm ô.\n• Mỗi lần qua ô Khởi Hành tính 1 vòng, đủ vòng nhận quà mốc.\nMỗi ngày 1 lượt tung miễn phí. Vé Tung Xúc Xắc được dùng trước xu.\nQuà vào thẳng túi (túi đầy thì gửi vào Hộp thư)."
const DB_GOT_TIP: String = "Phần thưởng Cờ Tỉ Phú đã vào túi."
const DB_CREAM: Color = Color("fff5c8")
const DB_PRICE: Color = Color("742109")
const DB_GLOW: float = 12.0
const MONEY: String = "l/c/money.webp"

static var s_db_shown: bool = false
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 3
var db_visible: bool = false
var loaded: bool = false
var season: String = ""
var days: int = 0
var end_at: float = 0.0
var pos: int = 0
var laps: int = 0
var dbl: bool = false
var rolls: int = 0
var free_left: int = 0
var tickets: int = 0
var ticket_id: int = 0
var price1: int = 0
var price10: int = 0
var claimable: int = 0
var token: String = ""
var tiles: Array = []
var lap_data: Array = []
var chest: Array = []
var arm_at: float = 0.0
var got_tip: String = DB_GOT_TIP
var rolling: bool = false
var steps: Variant = null
var step_at: int = 0
var phase: int = 0
var wait: int = 0
var hops: int = 0
var hop_dir: int = 1
var fast: bool = false
var show_pos: int = 0
var show_laps: int = 0
var show_dbl: bool = false
var face: int = 1
var last: Array = []
var ray_angle: float = 0.0
var bulb_phase: int = 0
var tumble: int = -1
var hop_t: int = 0
var hop_len: int = 0
var hop_arc: float = 0.0
var hop_from: Vector2 = Vector2.ZERO
var hop_to: Vector2 = Vector2.ZERO
var hop_fwd: bool = false
var hop_target: int = 0
var land_t: int = 0
var facing: int = 1
var badge_t: int = 0
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _b_ready: bool = false
var _b_failed: bool = false
var _pose: String = "teddy_idle"
var _foot: Vector2 = Vector2.ZERO
var _lift: float = 0.0
var _lit_name: String = ""
var _lit_at: Vector2 = Vector2.ZERO
var _lit_a: float = 1.0
var _halo_f: int = 0
var _badge_s: float = 1.0
var _last_shown: Array = []
var _count_line: String = ""
var _pill_laps: int = 0
var _glow_claim: float = -1.0
var _glow_roll10: float = -1.0

func _setup() -> void :
	art_dir = ""
	art_files = DB_ART
	sheets = DB_SHEETS
	win_size = Vector2(DB_W, DB_H)
	super ()

static func reset_statics() -> void :
	s_db_shown = false


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 3
	db_visible = false
	loaded = false
	season = ""
	days = 0
	end_at = 0.0
	pos = 0
	laps = 0
	dbl = false
	rolls = 0
	free_left = 0
	tickets = 0
	ticket_id = 0
	price1 = 0
	price10 = 0
	claimable = 0
	token = ""
	tiles = []
	lap_data = []
	chest = []
	arm_at = 0.0
	got_tip = DB_GOT_TIP
	rolling = false
	steps = null
	show_pos = 0
	show_laps = 0
	show_dbl = false
	face = 1
	last = []
	ray_angle = 0.0
	bulb_phase = 0
	tumble = -1
	hop_len = 0
	land_t = 0
	facing = 1
	badge_t = 0
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(DbAtlas.FILE):
			_atlas = load(DbAtlas.FILE) as Texture2D
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
	var atlas: Texture2D = _load_atlas()
	if atlas == null or not DbAtlas.R.has(name):
		return null
	var row: Array = DbAtlas.R[name]
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = atlas
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part


func button_icon() -> Texture2D:
	return art(DB_ICON)

func button_word() -> Texture2D:
	return art(DB_WORD)




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/dice-board.xml?t=" + str(int(now_ms())), "poll")


func beat() -> void :
	if opened:
		if arm_at != 0.0 and now_ms() - arm_at > MB_ARM_MS:
			arm_at = 0.0
			_rebuild()
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = MB_POLL_TICKS
		if not loading:
			poll()


func button_visible() -> bool:
	return db_visible


func button_dot() -> bool:
	return db_visible and (free_left > 0 or claimable > 0)


func busy() -> bool:
	return ( not action.is_empty() and action != "poll") or steps != null


func open() -> void :
	if opened or not db_visible:
		return
	arm_at = 0.0
	last = []
	steps = null
	rolling = false
	tumble = -1
	hop_len = 0
	land_t = 0
	badge_t = 0
	show_pos = pos
	show_laps = laps
	show_dbl = dbl
	show_window()
	load_art()
	if pack != null:
		pack.load_events()
		pack.load_quest()
		pack.load_bag()
	_rebuild()
	if action.is_empty() or action == "poll":
		poll()


func close(note: String = "") -> void :
	if not opened:
		return
	if steps != null:
		tip(got_tip)
	steps = null
	rolling = false
	arm_at = 0.0
	hide_window()
	poll_in = MB_POLL_TICKS
	closed.emit(note)


func leave() -> void :
	close()

func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "roll1":
		on_roll1()
	elif id == "roll10":
		on_roll10()
	elif id == "claim":
		on_claim()
	elif id.begins_with("lap:"):
		on_cell(id)




func _failed(what: String) -> void :
	rolling = false
	if what == "roll" or what == "claim":
		tip("Không kết nối được máy chủ, hãy thử lại.")
		if opened:
			_rebuild()


func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_deep(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	var parsed: bool = xml != null
	var notice: String = ""
	var old_dbl: bool = dbl
	var from: int = pos
	var got: Array = []
	if parsed:
		var at: Dictionary = xml["at"]
		notice = str(at.get("notice", ""))
		db_visible = str(at.get("visible", "")) == "1"
		s_db_shown = db_visible
		if db_visible:
			var t_list: Array = []
			var l_list: Array = []
			var c_list: Array = []
			for node: Dictionary in kids(xml, "t"):
				t_list.append(entry(node, str(node["at"].get("k", "")), TevWheel.as_int(str(node["at"].get("s", "")))))
			for node: Dictionary in kids(xml, "lap"):
				l_list.append(entry(node, str(node["at"].get("n", "")), TevWheel.as_int(str(node["at"].get("s", "")))))
			for node: Dictionary in kids(xml, "ch"):
				c_list.append(entry(node, str(node["at"].get("p", "")), 0))
			var roll: Array = kids(xml, "roll")
			for box: Dictionary in roll:
				for node: Dictionary in kids(box, "st"):
					var it: Dictionary = entry(node, "", 0)
					var a: Dictionary = node["at"]
					got.append({"d": TevWheel.as_int(str(a.get("d", ""))), "land": TevWheel.as_int(str(a.get("land", ""))), 
						"to": TevWheel.as_int(str(a.get("to", ""))), "k": str(a.get("k", "")), "jk": str(a.get("jk", "")), "id": it["id"], "c": it["c"], 
						"x2": str(a.get("x2", "")) == "1", "lap": TevWheel.as_int(str(a.get("lap", "")))})
			if not roll.is_empty():
				from = TevWheel.as_int(str(roll[0]["at"].get("from", "")))
				if not str(roll[0]["at"].get("tip", "")).is_empty():
					got_tip = str(roll[0]["at"]["tip"])
			season = str(at.get("season", ""))
			days = TevWheel.as_int(str(at.get("days", "")))
			end_at = now_ms() + TevWheel.as_number(str(at["left"])) * 1000.0 if not str(at.get("left", "")).is_empty() else 0.0
			pos = TevWheel.as_int(str(at.get("pos", "")))
			laps = TevWheel.as_int(str(at.get("laps", "")))
			dbl = str(at.get("dbl", "")) == "1"
			rolls = TevWheel.as_int(str(at.get("rolls", "")))
			free_left = TevWheel.as_int(str(at.get("free", "")))
			tickets = TevWheel.as_int(str(at.get("tickets", "")))
			ticket_id = maxi(0, TevWheel.as_int(str(at.get("ticketId", ""))))
			price1 = TevWheel.as_int(str(at.get("price1", "")))
			price10 = TevWheel.as_int(str(at.get("price10", "")))
			claimable = TevWheel.as_int(str(at.get("claimable", "")))
			token = str(at.get("token", ""))
			tiles = t_list
			lap_data = l_list
			chest = c_list
		else:
			claimable = 0
			free_left = 0
		loaded = true
	if not parsed and (what == "roll" or what == "claim"):
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if not opened or not db_visible:
		rolling = false
		if opened:
			close()
		if notice.is_empty() and not got.is_empty():
			notice = got_tip
	elif what == "roll" and not got.is_empty():
		start_anim(got, from, old_dbl)
	else:
		rolling = false
		if steps == null:
			show_pos = pos
			show_laps = laps
			show_dbl = dbl
		_rebuild()
	if not notice.is_empty():
		tip(notice)


static func entry(node: Dictionary, key: String, state: int) -> Dictionary:
	var parts: PackedStringArray = str(node["at"].get("it", "")).split(":")
	return {"k": key, "id": maxi(0, TevWheel.as_int(parts[0])), "c": TevWheel.as_int(parts[1]) if parts.size() > 1 else 0, "s": state}



static func parse_deep(text: String) -> Variant:
	var tags: RegEx = RegEx.create_from_string("<!--[\\s\\S]*?-->|<\\?[\\s\\S]*?\\?>|<!\\[CDATA\\[[\\s\\S]*?\\]\\]>|<!DOCTYPE[^>]*>|<(/?)([A-Za-z_][\\w.:-]*)((?:\\s+[A-Za-z_][\\w.:-]*\\s*=\\s*(?:\"[^\"]*\"|'[^']*'))*)\\s*(/?)>")
	var attrs: RegEx = RegEx.create_from_string("([A-Za-z_][\\w.:-]*)\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)')")
	var root: Dictionary = {}
	var stack: Array = []
	var ended: bool = false
	var cursor: int = 0
	for found: RegExMatch in tags.search_all(text):
		var gap: String = text.substr(cursor, found.get_start() - cursor)
		cursor = found.get_end()
		if gap.contains("<") or (ended and not gap.strip_edges().is_empty()):
			return null
		if found.get_string(2).is_empty():
			continue
		var name: String = found.get_string(2)
		if found.get_string(1) == "/":
			if stack.is_empty() or str(stack.back()["tag"]) != name:
				return null
			stack.pop_back()
			if stack.is_empty():
				ended = true
			continue
		if ended:
			return null
		var node: Dictionary = {"tag": name, "at": {}, "kids": []}
		for pair: RegExMatch in attrs.search_all(found.get_string(3)):
			var value: String = pair.get_string(2) if pair.get_start(2) >= 0 else pair.get_string(3)
			node["at"][pair.get_string(1)] = unescape(value)
		if root.is_empty():
			root = node
		else:
			(stack.back()["kids"] as Array).append(node)
		if found.get_string(4) == "/":
			if stack.is_empty():
				ended = true
		else:
			stack.append(node)
	var tail: String = text.substr(cursor)
	if root.is_empty() or not stack.is_empty() or tail.contains("<") or not tail.strip_edges().is_empty():
		return null
	return root




func on_roll1() -> void :
	if busy() or (free_left <= 0 and tickets <= 0 and price1 <= 0):
		return
	arm_at = 0.0
	last = []
	rolling = true
	fetch("/dice-board-roll.xml?n=1&k=" + TevWheel.uri_component(token) + "&t=" + str(int(now_ms())), "roll")
	_rebuild()


func on_roll10() -> void :
	if busy() or (tickets < 10 and price10 <= 0):
		return
	var cost: int = cost10()
	if cost > 0 and (arm_at == 0.0 or now_ms() - arm_at > MB_ARM_MS):
		arm_at = now_ms()
		tip("Bấm Tung 10 Lần lần nữa để trả " + str(cost) + " xu" + (" (dùng thêm " + str(tickets) + " vé)." if tickets > 0 else "."))
		_rebuild()
		return
	arm_at = 0.0
	last = []
	rolling = true
	fetch("/dice-board-roll.xml?n=10&k=" + TevWheel.uri_component(token) + "&t=" + str(int(now_ms())), "roll")
	_rebuild()


func on_claim() -> void :
	if busy() or claimable <= 0:
		return
	fetch("/dice-board-claim.xml?k=" + TevWheel.uri_component(token) + "&t=" + str(int(now_ms())), "claim")
	_rebuild()


func on_cell(key: String) -> void :
	var parts: PackedStringArray = key.split(":")
	if parts.size() < 3:
		return
	if parts[2].to_int() == 1:
		on_claim()
	elif parts[2].to_int() == 0:
		tip("Cần đi đủ " + str(parts[1].to_int()) + " vòng để nhận phần thưởng này.")




func cost10() -> int:
	if tickets >= 10:
		return 0
	if tickets > 0:
		return int(ceil(float(10 - tickets) * float(price10) / 10.0))
	return price10


func countdown() -> String:
	if end_at <= 0.0:
		return "Còn " + str(days) + " ngày" if days > 0 else "Đã kết thúc"
	var secs: float = floorf((end_at - now_ms()) / 1000.0)
	if secs >= 86400.0:
		return "Còn " + str(int(ceil(secs / 86400.0))) + " ngày"
	if secs > 0.0:
		var s: int = int(secs)
		return "Còn %02d:%02d:%02d" % [s / 3600, (s % 3600) / 60, s % 60]
	return "Đã kết thúc"


func tile_pos(i: int) -> Vector2:
	var n: int = tiles.size()
	if n <= 0:
		return Vector2(float(DB_TILE_XY[0]), float(DB_TILE_XY[1]))
	i = (i % n + n) % n
	if n == 24:
		return Vector2(float(DB_TILE_XY[i * 2]), float(DB_TILE_XY[i * 2 + 1]))
	var t: float = float(i) * 24.0 / float(n)
	var a: int = int(t)
	var b: int = (a + 1) % 24
	var f: float = t - float(a)
	var pa: Vector2 = Vector2(float(DB_TILE_XY[a * 2]), float(DB_TILE_XY[a * 2 + 1]))
	var pb: Vector2 = Vector2(float(DB_TILE_XY[b * 2]), float(DB_TILE_XY[b * 2 + 1]))
	return pa + (pb - pa) * f


static func tile_art(tile: Dictionary) -> String:
	match str(tile["k"]):
		"start":
			return "tile_start"
		"chest":
			return "tile_chest"
		"double":
			return "tile_x2"
		"forward":
			return "tile_fwd3" if int(tile["s"]) >= 3 else "tile_fwd2"
		"back":
			return "tile_back3" if int(tile["s"]) >= 3 else "tile_back2"
	return "tile_item"


static func tile_tip(tile: Dictionary) -> String:
	match str(tile["k"]):
		"start":
			return "Ô Khởi Hành: mỗi lần đi qua tính 1 vòng."
		"chest":
			return "Rương Bí Ẩn: nhận ngẫu nhiên 1 phần thưởng trong bảng Rương Bí Ẩn."
		"double":
			return "Ô x2: phần thưởng lần sau được nhân đôi."
		"forward":
			return "Tiến thêm " + str(int(tile["s"])) + " ô."
		"back":
			return "Lùi " + str(int(tile["s"])) + " ô."
	return ""




func _rebuild() -> void :
	if not opened:
		return
	fx_drop("back")
	_b_ready = art_pending() == 0 and art("db_bg") != null and loaded and tiles.size() >= 8
	_b_failed = art_pending() == 0 and art("db_bg") == null
	_glow_claim = -1.0
	_glow_roll10 = -1.0
	if not _b_ready:
		return
	if steps == null:
		tumble = maxi(0, tumble) if rolling else -1
	_badge_s = 1.0
	_halo_f = 0
	_lit_a = 1.0
	_pose = "teddy_jump" if hop_len > 0 else ("teddy_land" if land_t > 0 else "teddy_idle")
	_last_shown = _copy_last()
	_count_line = countdown()
	_pill_laps = show_laps
	move_pawn(show_pos, false)

func ready_shown() -> bool:
	return _b_ready

func _copy_last() -> Array:
	var out: Array = []
	for row: Dictionary in last:
		out.append(row.duplicate())
	return out


func refresh_last() -> void :
	if _b_ready:
		_last_shown = _copy_last()


func move_pawn(i: int, forward: bool) -> void :
	var n: int = tiles.size()
	if n <= 0:
		return
	i = (i % n + n) % n
	show_pos = i
	if forward and i == 0:
		show_laps += 1
		banner()
	var p: Vector2 = tile_pos(i)
	place_teddy(Vector2(p.x, p.y - 21.0), 0.0)
	_lit_name = "tile_lit_start" if str(tiles[i]["k"]) == "start" else "tile_lit"
	var lit: Vector2 = art_size(_lit_name)
	_lit_at = p - lit / 2.0


func place_teddy(foot: Vector2, lift: float) -> void :
	_foot = foot
	_lift = lift


func start_hop(target: int, forward: bool) -> void :
	var src: Vector2 = tile_pos(show_pos)
	var dst: Vector2 = tile_pos(target)
	hop_from = Vector2(src.x, src.y - 21.0)
	hop_to = Vector2(dst.x, dst.y - 21.0)
	hop_target = target
	hop_fwd = forward
	hop_t = 0
	hop_len = 3 if fast else 6
	hop_arc = 12.0 if fast else 22.0
	land_t = 0
	if dst.x < src.x - 1.0:
		facing = -1
	elif dst.x > src.x + 1.0:
		facing = 1
	_pose = "teddy_jump"


func hop() -> void :
	hop_t += 1
	var f: float = minf(1.0, float(hop_t) / float(hop_len))
	var p: Vector2 = hop_from + (hop_to - hop_from) * f
	place_teddy(p, sin(f * PI) * hop_arc)
	if hop_t % 2 == 0 and art("fx_trail_dot") != null:
		fx_add("sheet", "fx_trail_dot", p + Vector2(0, -4), {"tpf": 2, "layer": "back"})
	if f >= 1.0:
		hop_len = 0
		move_pawn(hop_target, hop_fwd)
		_pose = "teddy_land"
		land_t = 2 if fast else 4
		if ( not fast or hops == 0) and art("fx_land_ring") != null:
			fx_add("sheet", "fx_land_ring", p, {"tpf": 1, "layer": "back"})
		wait = 0 if fast else 1


func show_face(d: int) -> void :
	face = maxi(1, mini(6, d))
	tumble = -1
	if art("fx_sparkle") != null:
		fx_add("sheet", "fx_sparkle", Vector2(290, 250), {"tpf": 1})


func die_lift() -> float:
	if tumble >= 0 and art("die_tumble") != null:
		return absf(sin(float(tumble) * PI / 6.0)) * 14.0
	return 0.0


func start_anim(list: Array, from: int, old_dbl: bool) -> void :
	var n: int = 0
	for step: Dictionary in list:
		n += int(step["lap"])
	steps = list
	step_at = 0
	fast = list.size() > 1
	show_pos = from
	show_laps = maxi(0, laps - n)
	show_dbl = old_dbl
	last = []
	phase = 0
	wait = 3 if fast else 10
	rolling = true
	tumble = maxi(0, tumble)
	hop_len = 0
	_rebuild()


func _anim() -> void :
	if not opened:
		return
	_ambient()
	var n: int = tiles.size()
	if not _b_ready or n <= 0:
		return
	if tumble >= 0:
		tumble += 1
	if land_t > 0:
		land_t -= 1
		if land_t == 0 and hop_len == 0:
			_pose = "teddy_idle"
	if hop_len > 0:
		hop()
		return
	if steps == null:
		return
	if wait > 0:
		wait -= 1
		return
	var step: Dictionary = steps[step_at]
	var kind: String = str(step["k"])
	if phase == 0:
		show_face(int(step["d"]))
		hops = int(step["d"])
		hop_dir = 1
		phase = 1
		wait = 2 if fast else 6
	elif phase == 1 or phase == 3:
		if hops > 0:
			hops -= 1
			start_hop(show_pos + hop_dir, hop_dir > 0)
		elif phase == 1 and (kind == "forward" or kind == "back"):
			hop_dir = 1 if kind == "forward" else -1
			hops = (int(step["to"]) - int(step["land"]) + n) % n if kind == "forward" else (int(step["land"]) - int(step["to"]) + n) % n
			float_at(show_pos, ("Tiến " if kind == "forward" else "Lùi ") + str(hops) + " ô!", Color("90ff90") if kind == "forward" else Color("ff9090"))
			phase = 3
			wait = 4 if fast else 12
		else:
			pay(step, str(step["jk"]) if phase == 3 else kind)
			phase = 4
			wait = 3 if fast else 14
	else:
		step_at += 1
		if step_at >= (steps as Array).size():
			finish_anim()
		else:
			phase = 0
			wait = 3 if fast else 10
			tumble = 0


func _ambient() -> void :
	var is_busy: bool = busy()
	if _b_ready:
		ray_angle = fmod(ray_angle + (1.2 if is_busy else 0.4), 360.0)
	if tick % (3 if is_busy else 8) == 0:
		bulb_phase = (bulb_phase + 1) % 6
	if not _b_ready:
		return
	if show_dbl:
		if badge_t > 0:
			badge_t -= 1
			_badge_s = 1.0 + float(badge_t) * 0.06
		else:
			_badge_s = 1.0 + 0.04 * sin(float(tick) * 0.15)
	if tick % 2 == 0:
		_halo_f = int(float(tick) / 2.0) % 6
	_lit_a = 0.75 + 0.25 * sin(float(tick) * 0.2)
	if tick % 2 == 0 and not is_busy:
		if claimable > 0:
			_glow_claim = 0.55 + 0.35 * sin(float(tick) * 0.18)
		if arm_at != 0.0:
			_glow_roll10 = 0.55 + 0.35 * sin(float(tick) * 0.3)
	if tick % 25 == 0:
		_count_line = countdown()


func finish_anim() -> void :
	steps = null
	rolling = false
	hop_len = 0
	tumble = -1
	show_pos = pos
	show_laps = laps
	show_dbl = dbl
	_rebuild()
	if not last.is_empty():
		tip(got_tip)




func _fx_tick() -> void :
	var landed: bool = false
	for fx: Dictionary in _fx:
		if str(fx.get("done", "")) == "last" and int(fx["life"]) - (int(fx["age"]) + 1) <= 0:
			landed = true
	super ()
	if landed:
		refresh_last()


func pay(step: Dictionary, kind: String) -> void :
	var p: Vector2 = tile_pos(show_pos)
	if int(step["id"]) > 0:
		var slot: int = -1
		for i in last.size():
			if slot < 0 and int(last[i]["id"]) == int(step["id"]):
				last[i]["c"] = int(last[i]["c"]) + int(step["c"])
				slot = i
		if slot < 0:
			last.append({"id": int(step["id"]), "c": int(step["c"])})
			slot = last.size() - 1
		if kind == "chest":
			if art("fx_rays_small") != null:
				fx_add("pic", "fx_rays_small", p, {"still": 1, "vr": 3, "life": 40, "fade": 12, "layer": "back"})
			if art("fx_chest_open") != null:
				var box: Dictionary = fx_add("sheet", "fx_chest_open", p, {"tpf": 2, "hold": 5, "holdT": 10, "fade": 6, "layer": "back"})
				box["kind"] = "psheet"
				box["px"] = 48.0
				box["py"] = 65.0
			confetti(p + Vector2(0, -20), 12, 8.0)
		else:
			if art("fx_sparkle") != null:
				fx_add("sheet", "fx_sparkle", p, {"tpf": 1})
			if art("fx_coin") != null:
				for i in 3 + int(randf() * 3.0):
					fx_add("sheet", "fx_coin", p + Vector2(0, -10), {"f": int(randf() * 8.0), "tpf": 2, "loop": 1, "vx": randf() * 5.0 - 2.5, 
						"vy": -4.0 - randf() * 2.0, "g": 0.35, "life": 22, "fade": 6})
		var fly: Dictionary = fx_add("icon", "", p, {"id": int(step["id"]), "side": 42.0, 
			"tx": float(DB_LAST_XY[slot * 2]) if slot < 4 else 411.0, "ty": float(DB_LAST_XY[slot * 2 + 1]) if slot < 4 else 464.0, "ts": 0.67, "life": 18})
		fly["done"] = "last"
		float_at(show_pos, ("Rương Bí Ẩn!" if kind == "chest" else "Nhận quà!") + (" x2" if bool(step["x2"]) else ""), 
			Color("e0b0ff") if kind == "chest" else Color.WHITE)
		show_dbl = false
	elif kind == "double":
		show_dbl = true
		badge_t = 8
		if art("fx_sparkle") != null:
			fx_add("sheet", "fx_sparkle", Vector2(391, 238), {"tpf": 1})
		float_at(show_pos, "Lần sau x2!", MB_GOLD)


func banner() -> void :
	if art("fx_lap_banner") != null:
		fx_add("sheet", "fx_lap_banner", Vector2(286, 225), {"tpf": 2, "hold": 3, "holdT": 6 if fast else 12, "fade": 6})
	confetti(Vector2(286, 215), 10, 3.0)


func confetti(at: Vector2, count: int, spread: float) -> void :
	if art("fx_confetti") == null:
		return
	for i in count:
		fx_add("sheet", "fx_confetti", at + Vector2(randf() * 40.0 - 20.0, 0), {"f": int(randf() * 8.0), "still": 1, "vx": randf() * spread * 2.0 - spread, 
			"vy": -3.0 - randf() * 4.0, "g": 0.3, "vr": randf() * 30.0 - 15.0, "life": 30, "fade": 10})


func float_text(text: String, color: Color, at: Vector2) -> void :
	var fx: Dictionary = fx_add("text", "", Vector2(clampf(at.x, 95.0, 520.0), maxf(60.0, at.y)), {"vy": -0.8, "life": 36, "fade": 14})
	fx["text"] = text
	fx["color"] = color


func float_at(i: int, text: String, color: Color) -> void :
	var p: Vector2 = tile_pos(i)
	float_text(text, color, Vector2(p.x, p.y - 60.0))

func _draw_fx(at: Vector2, layer: String) -> void :
	super (at, layer)
	for fx: Dictionary in _fx:
		if str(fx["layer"]) != layer:
			continue
		var alpha: float = float(fx["alpha"])
		match str(fx["kind"]):
			"psheet":
				var name: String = str(fx["name"])
				var texture: Texture2D = art(name)
				if texture != null:
					var cell: Vector2 = Vector2(float(sheets[name][0]), float(sheets[name][1]))
					var scale: float = float(fx["scale"])
					draw_set_transform((at + Vector2(float(fx["x"]), float(fx["y"]))) * _f, deg_to_rad(float(fx["rot"])), Vector2(scale, scale))
					draw_texture_rect_region(texture, Rect2( - Vector2(float(fx["px"]), float(fx["py"])) * _f, cell * _f), sheet_region(name, int(fx["f"])), 
						Color(1, 1, 1, alpha))
					draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"text":
				_dbtext(at + Vector2(float(fx["x"]) - 90.0, float(fx["y"]) - 12.0), 180.0, 24.0, 15.0, Color(fx["color"], alpha), Color("2a1206", alpha), 
					"center", str(fx["text"]))




func _draw_tips() -> void :
	var keep: String = _hover
	if _hover.begins_with("lap:"):
		_hover = "panel"
	super ()
	_hover = keep


func _pic_scaled(name: String, anchor: Vector2, corner: Vector2, s: float, alpha: float = 1.0) -> Rect2:
	var texture: Texture2D = art(name)
	if texture == null:
		return Rect2(anchor * _f, Vector2.ZERO)
	var rect: Rect2 = Rect2((anchor + corner * s) * _f, Vector2(texture.get_size()) * s * _f)
	draw_texture_rect(texture, rect, false, Color(1, 1, 1, alpha))
	return rect


func _dbbutton(at: Vector2, id: String, name: String, spot: Vector2, state: int, price: int, glow: float) -> void :
	var lit: bool = state == 1 and _hover == id and not _mobile
	var down: bool = state == 1 and _press == id and _hover == id
	var alpha: float = 1.0 if state == 1 else (0.7 if state == 0 else 0.85)
	if glow >= 0.0 and art(name + "_glow") != null:
		pic(name + "_glow", at + spot - Vector2(DB_GLOW, DB_GLOW), glow)
	var suffix: String = "_hi" if lit else ("_grey" if state < 0 else "")
	var face_at: Vector2 = at + spot + Vector2(0, 1 if down else 0)
	var rect: Rect2 = pic(name + suffix if art(name + suffix) != null else name, face_at, alpha)
	if state == 1:
		_hit(id, Rect2(at * _f + spot * _f, rect.size), false)
	if price <= 0:
		return
	var ink: Color = _filtered(DB_PRICE, lit, state < 0)
	ink.a = alpha
	if price == 1 and free_left > 0:
		_dbtext(face_at + Vector2(36, 29), 71.0, 16.0, 12.0, ink, NONE, "center", "Miễn phí")
		return
	if (price == 1 and tickets > 0) or (price == 10 and tickets >= 10):
		pic("ticket_small" + suffix if art("ticket_small" + suffix) != null else "ticket_small", face_at + Vector2(34, 22), alpha)
		_dbtext(face_at + Vector2(66, 29), 43.0, 17.0, 12.0, ink, NONE, "left", str(price))
		return
	var coin: Texture2D = pack.picture(MONEY) if pack != null else null
	if coin != null:

		var k: float = minf(28.0 / maxf(1.0, float(coin.get_width())), 28.0 / maxf(1.0, float(coin.get_height())))
		var shown: Vector2 = Vector2(coin.get_size()) * k
		var tint: Color = Color(1.11, 1.11, 1.08, alpha) if lit else (Color(0.82, 0.8, 0.78, alpha) if state < 0 else Color(1, 1, 1, alpha))
		draw_texture_rect(coin, Rect2((face_at + Vector2(48, 36) - shown / 2.0) * _f, shown * _f), false, tint)
	_dbtext(face_at + Vector2(66, 29), 43.0, 17.0, 12.0, ink, NONE, "left", str(price1 if price == 1 else cost10()))


static func _filtered(color: Color, lit: bool, grey: bool) -> Color:
	if lit:
		return Color(minf(1.0, color.r + 28.0 / 255.0), minf(1.0, color.g + 28.0 / 255.0), minf(1.0, color.b + 20.0 / 255.0), color.a)
	if grey:
		var l: float = color.r * 0.3 + color.g * 0.59 + color.b * 0.11
		return Color(l, l, l, color.a)
	return color


func _count(at: Vector2, w: float, n: int) -> void :
	_dbtext(at, w, 14.0, 10.0, Color.WHITE, Color("221139"), "right", "x" + str(n))

func _body(at: Vector2) -> void :
	if not _b_ready:

		_round(Rect2((at + Vector2(0, 30)) * _f, Vector2(DB_W, DB_H - 30.0) * _f), Color(SHADOW, 0.96), 12.0, Color(1, 1, 1, 0.35), 1.0)
		_dbtext(at + Vector2(0, 290), DB_W, 30.0, 14.0, Color.WHITE, NONE, "center", 
			"Không tải được giao diện, hãy thử lại." if _b_failed else "Đang tải...")
		return
	var is_busy: bool = busy()
	pic("db_bg", at)
	var rays: Texture2D = art("stage_rays")
	if rays != null:
		draw_set_transform((at + Vector2(286, 274)) * _f, deg_to_rad(ray_angle), Vector2.ONE)
		draw_texture_rect(rays, Rect2(Vector2(-150, -150) * _f, Vector2(rays.get_size()) * _f), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	pic("db_pill", at + Vector2(221, 160))
	for i in range(0, DB_BULB_XY.size(), 2):
		var k: int = i / 2
		if ((k + bulb_phase) % 3 == 0) if is_busy else ((k + bulb_phase) % 2 == 0):
			pic("bulb_on", at + Vector2(float(DB_BULB_XY[i]) - 12.0, float(DB_BULB_XY[i + 1]) - 12.0))
	for i in tiles.size():
		var p: Vector2 = tile_pos(i)
		var name: String = tile_art(tiles[i])
		var half: float = 39.0 if name == "tile_start" else 33.0
		pic(name, at + p - Vector2(half, half))
	for i in tiles.size():
		var tile: Dictionary = tiles[i]
		if int(tile["id"]) > 0:
			var p: Vector2 = tile_pos(i)
			icon(int(tile["id"]), 42.0, at + p)
			if int(tile["c"]) > 1:
				_count(at + p + Vector2(-30, 9), 58.0, int(tile["c"]))
	pic("stage_disc", at + Vector2(168, 190))
	var lift: float = die_lift()
	var s: float = 1.0 - lift / 50.0
	_pic_scaled("die_shadow", at + Vector2(290, 332), Vector2(-48, -16), s)
	if tumble >= 0 and art("die_tumble") != null:
		sheet("die_tumble", tumble % 12, at + Vector2(226, 214.0 - lift))
	else:
		pic("die_f" + str(face), at + Vector2(242, 226))
	if show_dbl:
		var badge: Rect2 = _pic_scaled("x2_badge", at + Vector2(391, 238), Vector2(-30, -31), _badge_s)
		tip_area(Rect2(badge.position / _f, badge.size / _f), 0, "Phần thưởng lần tới được nhân đôi.")
	_draw_fx(at, "back")
	pic("teddy_shadow", at + _foot + Vector2(-28, -9), maxf(0.3, 1.0 - _lift / 40.0))
	if not _lit_name.is_empty():
		pic(_lit_name, at + _lit_at, _lit_a)
	var teddy: Texture2D = art(_pose)
	if teddy != null:
		draw_set_transform((at + _foot - Vector2(0, _lift)) * _f, 0.0, Vector2(float(facing), 1.0))
		draw_texture_rect(teddy, Rect2(Vector2(-40, -90) * _f, Vector2(teddy.get_size()) * _f), false)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_laps(at)
	for i in mini(8, chest.size()):
		var row: Dictionary = chest[i]
		var c: Vector2 = Vector2(float(DB_CHEST_XY[i * 2]), float(DB_CHEST_XY[i * 2 + 1]))
		icon(int(row["id"]), 34.0, at + c)
		if int(row["c"]) > 1:
			_count(at + c + Vector2(-21, 3), 42.0, int(row["c"]))
		_dbtext(at + c + Vector2(-23, 19), 46.0, 15.0, 10.0, DB_CREAM, Color("221139"), "center", str(row["k"]))
		tip_area(Rect2(at + c + Vector2(-21, -19), Vector2(42, 38)), int(row["id"]), "")
	for i in mini(4, _last_shown.size()):
		var row: Dictionary = _last_shown[i]
		var c: Vector2 = Vector2(float(DB_LAST_XY[i * 2]), float(DB_LAST_XY[i * 2 + 1]))
		icon(int(row["id"]), 28.0, at + c)
		if int(row["c"]) > 1:
			_dbtext(at + c + Vector2(-22, 3), 40.0, 14.0, 10.0, Color.WHITE, Color("221139"), "right", "x" + str(int(row["c"])))
		tip_area(Rect2(at + c + Vector2(-16, -14.5), Vector2(32, 29)), int(row["id"]), "")
	if _last_shown.size() > 4:
		_dbtext(at + Vector2(398, 456), 26.0, 16.0, 11.0, DB_CREAM, Color("231438"), "center", "+" + str(_last_shown.size() - 4))
	_dbbutton(at, "roll1", "btn_roll1", Vector2(150, 385), ((0 if is_busy else 1) if free_left > 0 or tickets > 0 or price1 > 0 else -1), 1, -1.0)
	_dbbutton(at, "roll10", "btn_roll10", Vector2(294, 385), ((0 if is_busy else 1) if tickets >= 10 or price10 > 0 else -1), 10, _glow_roll10)
	_dbbutton(at, "claim", "btn_claim", Vector2(639, 298), ((0 if is_busy else 1) if claimable > 0 else -1), 0, _glow_claim)
	if arm_at != 0.0:
		_round(Rect2((at + Vector2(298, 336)) * _f, Vector2(132, 20) * _f), Color("231438", 0.92), 5.0, MB_GOLD, 1.0)
		_dbtext(at + Vector2(298, 336), 132.0, 20.0, 11.0, MB_GOLD, NONE, "center", "Bấm lần nữa: " + str(cost10()) + " xu")
	_dbtext(at + Vector2(582, 47), 193.0, 28.0, 13.0, DB_CREAM, Color("24123e"), "left", _count_line)
	_dbtext(at + Vector2(242, 170), 88.0, 20.0, 12.0, DB_CREAM, Color("4b210e"), "center", "Vòng " + str(show_laps))
	_dbtext(at + Vector2(184, 366), 204.0, 18.0, 11.0, DB_CREAM, Color("231438"), "center", "Miễn phí hôm nay: " + str(free_left))
	pic("ticket_small", at + Vector2(390, 358))
	_dbtext(at + Vector2(420, 365), 65.0, 18.0, 11.0, DB_CREAM, Color("231438"), "left", "Vé: " + str(tickets))

	for i in tiles.size():
		var tile: Dictionary = tiles[i]
		tip_area(Rect2(at + tile_pos(i) - Vector2(29, 29), Vector2(58, 58)), int(tile["id"]), tile_tip(tile) if int(tile["id"]) <= 0 else "")
	tip_area(Rect2(at + Vector2(388, 358), Vector2(98, 28)), ticket_id, "Vé Tung Xúc Xắc: " + str(tickets))
	tip_area(Rect2(at + Vector2(221, 160), Vector2(130, 37)), 0, "Đã đi " + str(_pill_laps) + " vòng, đã tung " + str(rolls) + " lần mùa này.")
	tip_area(Rect2(at + Vector2(582, 47), Vector2(193, 28)), 0, season if not season.is_empty() else "Mùa hiện tại")


func _laps(at: Vector2) -> void :
	var next_at: int = -1
	for i in mini(8, lap_data.size()):
		var row: Dictionary = lap_data[i]
		var c: Vector2 = Vector2(float(DB_MS_XY[i * 2]), float(DB_MS_XY[i * 2 + 1]))
		var state: int = int(row["s"])
		if state == 0 and next_at < 0:
			next_at = i
			if art("ms_next") != null:
				sheet("ms_next", _halo_f, at + c - Vector2(40, 40))
		elif state == 1:
			pic("ms_reached", at + c - Vector2(40, 40))
		icon(int(row["id"]), 42.0, at + c, 0.55 if state == 2 else 1.0)
		_dbtext(at + Vector2(float(DB_MS_FLAG[i * 2]), float(DB_MS_FLAG[i * 2 + 1])), 32.0, 19.0, 13.0, DB_CREAM, Color("771b17"), "center", str(row["k"]))
		if int(row["c"]) > 1:
			_dbtext(at + c + Vector2(-25, 7), 48.0, 14.0, 10.0, Color.WHITE, Color("221139"), "right", "x" + str(int(row["c"])))
		if state == 2:
			pic("ms_claimed", at + c + Vector2(3, 1))
		var cell: Rect2 = Rect2(at + c - Vector2(25, 25), Vector2(50, 50))
		_hit("lap:%d:%d" % [TevWheel.as_int(str(row["k"])), state], Rect2(cell.position * _f, cell.size * _f), false)
		tip_area(cell, int(row["id"]), "")


func _chrome(at: Vector2) -> void :
	if art("btn_help") != null:
		pic("btn_help", at + Vector2(791, 48))
	tip_area(Rect2(at + Vector2(791, 48), Vector2(38, 38)), 0, DB_RULES)
	var cell: Vector2 = _cell_size("public_button_close")
	_fbutton("close", "public_button_close", at + Vector2(839, 42) - Vector2(float(int(cell.x / 2.0)), float(int(cell.y / 2.0))))
