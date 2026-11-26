extends "tev_window.gd"








signal closed(note: String)

const DrAtlas = preload("dr_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const POLL_TICKS: int = 120
const OPEN_POLL: int = 125
const DR_TIP: String = "Vịt Siêu Tốc"
const DR_ICON: String = "btn_duavit"
const DR_WORD: String = "word_duavit"
const DR_W: float = 860.0
const DR_H: float = 590.0
const NAMES: Array = ["Vịt Bông", "Vịt Ớt", "Vịt Cốm", "Vịt Sóng", "Vịt Mận"]
const DR_INK: Color = Color("6b3a10")
const DR_CREAM: Color = Color("fff5c8")
const DR_GOLD: Color = Color("ffe45c")
const DR_CHIP_INK: Color = Color("ffd21f")
const DR_CHIP_RIM: Color = Color("2e1500")
const RACE_LEN: float = 30.0

const START_NOSE: float = 70.0

const DR_RULES: String = "Mỗi ván 5 phút: cổ vũ 3 phút 40 giây, khoá 15 giây, 5 vịt đua 30 giây, rồi trao thưởng.\n• Chọn vịt + mức Bạc rồi bấm CỔ VŨ (tối đa 3 vịt mỗi ván).\n• Vịt về nhất trả Bạc = tiền cổ vũ × hệ số trên thẻ.\n• Sao = phong độ: nhiều sao dễ về nhất, hệ số thấp.\nHạn mức 3.000.000 Bạc mỗi ngày, từ cấp 10."

const DR_PARTS: Array = ["title", "card", "face_0", "face_1", "face_2", "face_3", "face_4", "star_on", "heart", "watch", "coin", "chip_0", "chip_1", 
	"chip_2", "chip_3", "chip_4", "ring", "btn", "btn_hi", "btn_off", "pill", "close", "row", "medal_0", "medal_1", "medal_2", "wake_0", "wake_1", 
	"splash", "whirl_0", "whirl_1", "fish_up", "fish_dn", "pad", "pad_lit", "streak", "conf_0", "conf_1", "conf_2", "conf_3", "conf_4", "conf_5", 
	"heart_fx", "sparkle", "firework", "trophy", "duck_0_0", "duck_0_1", "duck_0_2", "duck_1_0", "duck_1_1", "duck_1_2", "duck_2_0", "duck_2_1", 
	"duck_2_2", "duck_3_0", "duck_3_1", "duck_3_2", "duck_4_0", "duck_4_1", "duck_4_2"]

static var s_dr_shown: bool = false
static var _atlas: Texture2D = null
static var _bg: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 3
var open_poll: int = OPEN_POLL
var dr_visible: bool = false
var loaded: bool = false
var round_id: int = 0
var phase: String = ""
var round_sec: float = 300.0
var bet_end: float = 220.0
var race_at: float = 235.0
var race_end: float = 265.0
var base_ms: float = 0.0
var silver: int = 0
var spent: int = 0
var cap: int = 0
var max_lanes: int = 3
var min_lv: int = 0
var token: String = ""
var round_hash: String = ""
var next_text: String = ""
var ducks: Array = []
var tiers: Array = []
var hist: Array = []
var top_rows: Array = []
var race_seed: String = ""
var race_winner: int = -1
var race_order: Array = []
var race_p: Array = []
var race_e: Array = []
var res: Dictionary = {}
var sel_lane: int = -1
var sel_tier: int = 2
var now_skew: float = 0.0
var seen_win: int = -1
var cheer_cd: int = 0

var _parts: Dictionary = {}
var _b_ready: bool = false
var _b_failed: bool = false
var _shown_phase: String = ""
var _bob: float = 0.0

func _setup() -> void :
	art_dir = ""
	art_files = []
	win_size = Vector2(DR_W, DR_H)
	super ()

static func reset_statics() -> void :
	s_dr_shown = false

func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew

func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 3
	dr_visible = false
	loaded = false
	phase = ""
	ducks = []
	tiers = []
	hist = []
	top_rows = []
	_clear_race()
	res = {}
	token = ""
	silver = 0
	spent = 0
	sel_lane = -1
	sel_tier = 2
	seen_win = -1
	reset_statics()

func _clear_race() -> void :
	race_seed = ""
	race_winner = -1
	race_order = []
	race_p = []
	race_e = []



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(DrAtlas.FILE):
			_atlas = load(DrAtlas.FILE) as Texture2D
		if ResourceLoader.exists(DrAtlas.BG):
			_bg = load(DrAtlas.BG) as Texture2D
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
	if atlas == null or not DrAtlas.R.has(name):
		return null
	var row: Array = DrAtlas.R[name]
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = atlas
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part


func part_size(name: String) -> Vector2:
	if not DrAtlas.R.has(name):
		return Vector2.ZERO
	var row: Array = DrAtlas.R[name]
	return Vector2(float(row[2]), float(row[3])) / DrAtlas.K


func part(name: String, at: Vector2, k: float = 1.0, alpha: float = 1.0, flip: bool = false) -> Rect2:
	var texture: Texture2D = art(name)
	var shown: Vector2 = part_size(name) * k
	var rect: Rect2 = Rect2(at * _f, shown * _f)
	if texture == null:
		return rect
	if flip:
		draw_set_transform(Vector2((at.x + shown.x) * _f, at.y * _f), 0.0, Vector2(-1, 1))
		draw_texture_rect(texture, Rect2(Vector2.ZERO, shown * _f), false, Color(1, 1, 1, alpha))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	else:
		draw_texture_rect(texture, rect, false, Color(1, 1, 1, alpha))
	return rect


func part_c(name: String, centre: Vector2, wide: float = 0.0, alpha: float = 1.0, flip: bool = false) -> Rect2:
	var shown: Vector2 = part_size(name)
	var k: float = wide / shown.x if wide > 0.0 and shown.x > 0.0 else 1.0
	return part(name, centre - shown * k / 2.0, k, alpha, flip)


func part_bar(name: String, at: Vector2, wide: float, high: float, alpha: float = 1.0) -> void :
	var atlas: Texture2D = _load_atlas()
	if atlas == null or not DrAtlas.R.has(name):
		return
	var row: Array = DrAtlas.R[name]
	var src: Rect2 = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	var k: float = high / src.size.y
	var cap_src: float = minf(src.size.y * 0.6, src.size.x / 2.0 - 1.0)
	var cap_w: float = minf(cap_src * k, wide / 2.0)
	var tint: Color = Color(1, 1, 1, alpha)
	draw_texture_rect_region(atlas, Rect2(at * _f, Vector2(cap_w, high) * _f), Rect2(src.position, Vector2(cap_src, src.size.y)), tint)
	draw_texture_rect_region(atlas, Rect2((at + Vector2(cap_w, 0)) * _f, Vector2(wide - cap_w * 2.0, high) * _f), 
		Rect2(src.position + Vector2(cap_src, 0), Vector2(src.size.x - cap_src * 2.0, src.size.y)), tint)
	draw_texture_rect_region(atlas, Rect2((at + Vector2(wide - cap_w, 0)) * _f, Vector2(cap_w, high) * _f), 
		Rect2(src.position + Vector2(src.size.x - cap_src, 0), Vector2(cap_src, src.size.y)), tint)

func button_icon() -> Texture2D:
	return art(DR_ICON)

func button_word() -> Texture2D:
	return art(DR_WORD)

func button_tip() -> String:
	return DR_TIP



func boot() -> void :
	poll_in = POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/duck-race.xml?t=" + str(int(now_ms())), "poll")

func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = POLL_TICKS
		if not loading:
			poll()

func button_visible() -> bool:
	return dr_visible


func button_dot() -> bool:
	return dr_visible and int(res.get("won", 0)) > 0 and seen_win != round_id

func busy() -> bool:
	return not action.is_empty() and action != "poll"

func open() -> void :
	if opened or not dr_visible:
		return
	show_window()
	load_art()
	_shown_phase = ""
	open_poll = OPEN_POLL
	_rebuild()
	if action.is_empty() or action == "poll":
		poll()

func close(note: String = "") -> void :
	if not opened:
		return
	hide_window()
	poll_in = POLL_TICKS
	closed.emit(note)

func leave() -> void :
	close()

func _activate(id: String) -> void :
	if rules_click(id):
		return
	if id == "close":
		close()
	elif id == "bet":
		on_bet()
	elif id == "cheer":
		on_cheer()
	elif id.begins_with("lane:"):
		sel_lane = clampi(TevWheel.as_int(id.substr(5)), 0, 4)
	elif id.begins_with("tier:"):
		sel_tier = clampi(TevWheel.as_int(id.substr(5)), 0, maxi(0, tiers.size() - 1))



func _failed(what: String) -> void :
	if what == "bet":
		tip("Không kết nối được máy chủ, hãy thử lại.")

func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_deep(text)
	if xml == null:
		if what == "bet":
			tip("Thao tác chưa thành công, hãy thử lại sau.")
		return
	var at: Dictionary = xml["at"]
	dr_visible = str(at.get("visible", "")) == "1"
	s_dr_shown = dr_visible
	loaded = true
	if dr_visible:
		var rid: int = TevWheel.as_int(str(at.get("round", "")))
		if rid != round_id:
			_clear_race()
			res = {}
		round_id = rid
		phase = str(at.get("phase", ""))
		round_sec = maxf(1.0, TevWheel.as_number(str(at.get("roundSec", "300"))))
		bet_end = TevWheel.as_number(str(at.get("betEnd", "220")))
		race_at = TevWheel.as_number(str(at.get("raceAt", "235")))
		race_end = TevWheel.as_number(str(at.get("raceEnd", "265")))
		base_ms = now_ms() - TevWheel.as_number(str(at.get("at", "0")))
		silver = TevWheel.as_int(str(at.get("silver", "")))
		spent = TevWheel.as_int(str(at.get("spent", "")))
		cap = TevWheel.as_int(str(at.get("cap", "")))
		max_lanes = maxi(1, TevWheel.as_int(str(at.get("maxLanes", "3"))))
		min_lv = TevWheel.as_int(str(at.get("minLv", "")))
		token = str(at.get("token", ""))
		round_hash = str(at.get("hash", ""))
		next_text = str(at.get("next", ""))
		var list: Array = []
		for node: Dictionary in kids(xml, "d"):
			var a: Dictionary = node["at"]
			list.append({"star": clampi(TevWheel.as_int(str(a.get("star", ""))), 0, 5), "mult": TevWheel.as_number(str(a.get("mult", ""))), 
				"n": TevWheel.as_int(str(a.get("n", ""))), "my": TevWheel.as_int(str(a.get("my", "")))})
		ducks = list.slice(0, 5)
		tiers = []
		for node: Dictionary in kids(xml, "tier"):
			tiers.append(TevWheel.as_int(str(node["at"].get("v", ""))))
		sel_tier = clampi(sel_tier, 0, maxi(0, tiers.size() - 1))
		hist = []
		for node: Dictionary in kids(xml, "h"):
			var a: Dictionary = node["at"]
			hist.append({"r": TevWheel.as_int(str(a.get("r", ""))), "w": TevWheel.as_int(str(a.get("w", ""))) - 1, 
				"star": TevWheel.as_int(str(a.get("star", ""))), "mult": TevWheel.as_number(str(a.get("mult", "")))})
		top_rows = []
		for node: Dictionary in kids(xml, "top"):
			var a: Dictionary = node["at"]
			top_rows.append({"nick": str(a.get("nick", "")), "lane": TevWheel.as_int(str(a.get("lane", ""))) - 1, 
				"mult": TevWheel.as_number(str(a.get("mult", ""))), "win": TevWheel.as_int(str(a.get("win", "")))})
		for node: Dictionary in kids(xml, "race"):
			_read_race(node)
		for node: Dictionary in kids(xml, "res"):
			var a: Dictionary = node["at"]
			res = {"winner": TevWheel.as_int(str(a.get("winner", ""))) - 1, "mult": TevWheel.as_number(str(a.get("mult", ""))), 
				"bet": TevWheel.as_int(str(a.get("bet", ""))), "won": TevWheel.as_int(str(a.get("won", "")))}
	elif opened:
		close()
	if opened:
		_rebuild()
	var notice: String = str(at.get("notice", ""))
	if not notice.is_empty():
		tip(notice)

func _read_race(node: Dictionary) -> void :
	var a: Dictionary = node["at"]
	race_seed = str(a.get("seed", ""))
	race_winner = TevWheel.as_int(str(a.get("winner", ""))) - 1
	race_order = []
	for part_text: String in str(a.get("order", "")).split(",", false):
		race_order.append(TevWheel.as_int(part_text) - 1)
	var rows: Array = [[], [], [], [], []]
	var events: Array = []
	for kid: Dictionary in node["kids"]:
		var k: Dictionary = kid["at"]
		if str(kid["tag"]) == "p":
			var lane: int = TevWheel.as_int(str(k.get("lane", ""))) - 1
			if lane >= 0 and lane < 5:
				var row: Array = []
				for v: String in str(k.get("v", "")).split(",", false):
					row.append(TevWheel.as_number(v))
				rows[lane] = row
		elif str(kid["tag"]) == "e":
			events.append({"t": TevWheel.as_number(str(k.get("t", ""))), "lane": TevWheel.as_int(str(k.get("lane", ""))) - 1, "k": str(k.get("k", ""))})
	for row: Array in rows:
		if row.size() < 2:
			race_p = []
			race_e = []
			return
	race_p = rows
	race_e = events


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




func round_t() -> float:
	return (now_ms() - base_ms) / 1000.0


func local_phase() -> String:
	if phase == "closed" or phase.is_empty():
		return phase
	var t: float = round_t()
	if t < bet_end:
		return "bet"
	if t < race_at:
		return "lock"
	if t < race_end:
		return "race"
	return "pay"


func race_t() -> float:
	return clampf(round_t() - race_at, 0.0, race_end - race_at)


func lane_v(lane: int, rt: float) -> float:
	if race_p.size() != 5:
		return 0.0
	var row: Array = race_p[lane]
	var last: int = row.size() - 1
	var s: float = clampf(rt * 2.0, 0.0, float(last))
	var i: int = mini(int(s), last - 1)
	var f: float = s - float(i)
	var p0: float = float(row[maxi(0, i - 1)])
	var p1: float = float(row[i])
	var p2: float = float(row[i + 1])
	var p3: float = float(row[mini(last, i + 2)])
	var v: float = 0.5 * (2.0 * p1 + (p2 - p0) * f + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * f * f + (3.0 * p1 - p0 - 3.0 * p2 + p3) * f * f * f)
	return clampf(v, minf(p1, p2), maxf(p1, p2))


static func nose_x(v: float) -> float:
	var x0: float = DrAtlas.START_X + START_NOSE
	return x0 + v / 1000.0 * (DrAtlas.FINISH_X - x0)


func finish_t(lane: int) -> float:
	if race_p.size() != 5:
		return -1.0
	var row: Array = race_p[lane]
	for i in range(1, row.size()):
		if float(row[i]) >= 1000.0:
			var a: float = float(row[i - 1])
			return (float(i - 1) + (1000.0 - a) / maxf(1.0, float(row[i]) - a)) / 2.0
	return -1.0



func my_lanes() -> int:
	var n: int = 0
	for d: Dictionary in ducks:
		n += 1 if int(d["my"]) > 0 else 0
	return n


func bet_button() -> Array:
	var p: String = local_phase()
	if p == "closed":
		return ["Ngoài giờ", -1, "bet"]
	if p == "lock":
		return ["Đã khoá", -1, "bet"]
	if p == "race":
		return ["Cổ vũ!", 1 if cheer_cd <= 0 else 0, "cheer"]
	if p == "pay":
		return ["Chờ ván mới", -1, "bet"]
	if busy():
		return ["Đang gửi...", 0, "bet"]
	if sel_lane < 0 or sel_lane >= ducks.size():
		return ["Chọn vịt", -1, "bet"]
	var amount: int = int(tiers[sel_tier]) if sel_tier < tiers.size() else 0
	if int(ducks[sel_lane]["my"]) > 0:
		return ["Đã cổ vũ", -1, "bet"]
	if my_lanes() >= max_lanes:
		return ["Đủ %d vịt" % max_lanes, -1, "bet"]
	if silver < amount:
		return ["Thiếu Bạc", -1, "bet"]
	if cap > 0 and spent + amount > cap:
		return ["Hết hạn mức", -1, "bet"]
	return ["CỔ VŨ " + tier_label(amount), 1, "bet"]

func on_bet() -> void :
	var state: Array = bet_button()
	if int(state[1]) != 1 or str(state[2]) != "bet":
		return
	fetch("/duck-race-bet.xml?lane=%d&tier=%d&k=%s&t=%d" % [sel_lane + 1, sel_tier, TevWheel.uri_component(token), int(now_ms())], "bet")


func on_cheer() -> void :
	if cheer_cd > 0 or local_phase() != "race":
		return
	cheer_cd = 12
	var lanes: Array = []
	for i in ducks.size():
		if int(ducks[i]["my"]) > 0:
			lanes.append(i)
	if lanes.is_empty():
		lanes.append(maxi(0, sel_lane))
	var rt: float = race_t()
	for lane: int in lanes:
		var spot: Vector2 = Vector2(nose_x(lane_v(lane, rt)) - 30.0, float(DrAtlas.LANE_Y[lane]) - 20.0)
		for i in 4:
			fx_add("part", "heart_fx", spot + Vector2(randf() * 30.0 - 15.0, 0), {"vx": randf() * 1.6 - 0.8, "vy": -1.2 - randf() * 1.2, "life": 28, 
				"fade": 12})

static func tier_label(v: int) -> String:
	if v >= 1000000 and v % 1000000 == 0:
		return str(v / 1000000) + "M"
	if v >= 1000 and v % 1000 == 0:
		return str(v / 1000) + "K"
	return num(v)


static func mult_text(m: float) -> String:
	var shown: String = ("%.1f" % m).trim_suffix(".0")
	return "x" + shown.replace(".", ",")

static func clock_text(secs: float) -> String:
	var s: int = maxi(0, int(ceil(secs)))
	return "%02d:%02d" % [s / 60, s % 60]

func timer_text() -> String:
	var t: float = round_t()
	match local_phase():
		"bet":
			return "Cổ vũ còn " + clock_text(bet_end - t)
		"lock":
			return "Xuất phát sau " + clock_text(race_at - t)
		"race":
			return "Đang đua!"
		"pay":
			return "Ván mới sau " + clock_text(round_sec - t)
		"closed":
			return "Ngoài giờ"
	return ""



func _rebuild() -> void :
	if not opened:
		return
	_load_atlas()
	_b_ready = art_pending() == 0 and _atlas != null and _bg != null and loaded and ducks.size() == 5
	_b_failed = art_pending() == 0 and (_atlas == null or _bg == null)

func ready_shown() -> bool:
	return _b_ready

func _anim() -> void :
	if not opened:
		return
	_bob += 0.16
	if cheer_cd > 0:
		cheer_cd -= 1
	if not _b_ready:
		return
	var p: String = local_phase()
	if p != _shown_phase:
		var was: String = _shown_phase
		_shown_phase = p
		if not was.is_empty():
			_phase_changed(was, p)
	if p == "bet":
		open_poll -= 1
		if open_poll <= 0:
			open_poll = OPEN_POLL
			if not loading:
				poll()
	elif (p == "lock" or p == "race") and race_p.is_empty() and tick % 25 == 0 and not loading:
		poll()
	elif p == "pay" and round_t() >= round_sec and tick % 25 == 0 and not loading:
		poll()
	if p == "race":
		_race_fx()


func _phase_changed(was: String, now_phase: String) -> void :
	if now_phase == "lock" or now_phase == "pay" or (was == "pay" and now_phase == "bet"):
		if not loading:
			poll()
	if now_phase == "pay" and was == "race":
		celebrate()

func celebrate() -> void :

	var spots: Array = [Vector2(125, 115), Vector2(150, 255), Vector2(720, 110)]
	for i in 3:
		var spot: Vector2 = spots[i]
		var fx: Dictionary = fx_add("part", "firework", spot, {"tx": spot.x, "ty": spot.y, "ts": 1.25, "life": 26 + i * 6, "fade": 12, "alpha": 0.95})
		fx["s0"] = 0.3
	confetti(Vector2(430, 80), 26, 5.0)
	if race_winner >= 0:
		var y: float = float(DrAtlas.LANE_Y[race_winner])
		for i in 6:
			fx_add("part", "sparkle", Vector2(nose_x(lane_v(race_winner, RACE_LEN)) - 30.0 + randf() * 50.0, y - 20.0 + randf() * 30.0), 
				{"vy": -0.5, "life": 20 + i * 2, "fade": 8})

func confetti(at: Vector2, count: int, spread: float) -> void :
	for i in count:
		fx_add("part", "conf_" + str(i % 6), at + Vector2(randf() * 300.0 - 150.0, 0), {"vx": randf() * spread * 2.0 - spread, "vy": -2.0 - randf() * 4.0, 
			"g": 0.25, "vr": randf() * 30.0 - 15.0, "life": 40, "fade": 12})


func _race_fx() -> void :
	var rt: float = race_t()
	for lane in 5:
		var ft: float = finish_t(lane)
		if ft > 0.0 and rt >= ft and rt - ft < TICK:
			fx_add("part", "splash", Vector2(DrAtlas.FINISH_X, float(DrAtlas.LANE_Y[lane]) + 6.0), {"life": 14, "fade": 8, "tx": DrAtlas.FINISH_X, 
				"ty": float(DrAtlas.LANE_Y[lane]) + 2.0, "ts": 1.3})

func _draw_fx(at: Vector2, layer: String) -> void :
	super (at, layer)
	for fx: Dictionary in _fx:
		if str(fx["layer"]) != layer or str(fx["kind"]) != "part":
			continue
		var name: String = str(fx["name"])
		var texture: Texture2D = art(name)
		if texture == null:
			continue
		var grow: float = float(fx["scale"])
		if fx.has("s0"):
			var k: float = minf(1.0, float(fx["age"]) / maxf(1.0, float(fx["life"])))
			grow = lerpf(float(fx["s0"]), float(fx["ts"]), 1.0 - (1.0 - k) * (1.0 - k))
		var shown: Vector2 = part_size(name)
		draw_set_transform((at + Vector2(float(fx["x"]), float(fx["y"]))) * _f, deg_to_rad(float(fx["rot"])), Vector2(grow, grow))
		draw_texture_rect(texture, Rect2( - shown / 2.0 * _f, shown * _f), false, Color(1, 1, 1, float(fx["alpha"])))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)



func _body(at: Vector2) -> void :
	if not _b_ready:
		_wait_panel(at, _b_failed)
		return
	draw_texture_rect(_bg, Rect2(at * _f, Vector2(DR_W, DR_H) * _f), false)
	var p: String = local_phase()
	_river(at, p)
	_header(at)
	_cards(at, p)
	_chips(at, p)
	_side(at)
	_overlay(at, p)


func _river(at: Vector2, p: String) -> void :
	var racing: bool = (p == "race" or p == "pay") and race_p.size() == 5
	var rt: float = race_t() if p == "race" else (RACE_LEN if p == "pay" else 0.0)
	if racing:
		for e: Dictionary in race_e:
			_event(at, e, rt)
	for lane in 5:
		var y: float = float(DrAtlas.LANE_Y[lane])
		var v: float = lane_v(lane, rt) if racing else 0.0
		var x: float = nose_x(v)
		var moving: bool = racing and p == "race" and v < 1000.0 + 60.0 and rt > 0.0
		var bob: float = sin(_bob + float(lane) * 1.3) * (1.2 if moving else 2.0)
		var frame: String = "duck_%d_%d" % [lane, (1 + int(tick / 4.0 + lane) % 2) if moving else 0]
		var shown: Vector2 = part_size(frame)
		if moving:
			var speed: float = lane_v(lane, minf(rt + 0.25, RACE_LEN)) - v
			var wake: String = "wake_" + str(int(tick / 3.0) % 2)
			var wsize: Vector2 = part_size(wake)
			part(wake, at + Vector2(x - shown.x * 0.55 - wsize.x * 0.85, y + 2.0 - wsize.y / 2.0), 0.85, clampf(speed / 12.0, 0.25, 0.9), true)
			if _turbo_on(lane, rt):
				part_c("streak", at + Vector2(x - shown.x - 40.0, y), 120.0, 0.85)
		part(frame, at + Vector2(x - shown.x, y + 22.0 - shown.y + bob), 1.0)
		if lane < ducks.size() and int(ducks[lane]["my"]) > 0:
			part_c("heart", at + Vector2(x - shown.x * 0.45, y - shown.y + 18.0 + bob), 16.0)
		if racing and v >= 1000.0:
			var place: int = race_order.find(lane) + 1
			if place > 0:
				var c: Vector2 = at + Vector2(x - shown.x - 10.0, y - 6.0)
				draw_circle(c * _f, 9.0 * _f, Color("b8860b") if place == 1 else Color("2a5d8f"))
				draw_arc(c * _f, 9.0 * _f, 0.0, TAU, 20, Color.WHITE, 1.5 * _f)
				_dbtext(c - Vector2(9, 9), 18.0, 18.0, 11.0, Color.WHITE, NONE, "center", str(place))

func _turbo_on(lane: int, rt: float) -> bool:
	for e: Dictionary in race_e:
		if int(e["lane"]) == lane and str(e["k"]) == "turbo" and rt >= float(e["t"]) and rt < float(e["t"]) + 1.5:
			return true
	return false


func _event(at: Vector2, e: Dictionary, rt: float) -> void :
	var t: float = float(e["t"])
	var lane: int = clampi(int(e["lane"]), 0, 4)
	var y: float = float(DrAtlas.LANE_Y[lane])
	var x: float = nose_x(lane_v(lane, t))
	var dt: float = rt - t
	match str(e["k"]):
		"turbo":
			if dt >= -2.0 and dt < 0.0:
				part_c("pad", at + Vector2(x - 20.0, y + 10.0), 62.0, clampf((dt + 2.0) * 2.0, 0.0, 1.0))
			elif dt >= 0.0 and dt < 0.8:
				part_c("pad_lit", at + Vector2(x - 20.0, y + 8.0), 62.0, 1.0 - dt / 0.8 * 0.6)
		"whirl":
			if dt >= -0.6 and dt < 1.6:
				var a: float = clampf(minf(dt + 0.6, 1.6 - dt) * 2.5, 0.0, 1.0)
				var name: String = "whirl_" + str(int(tick / 3.0) % 2)
				part_c(name, at + Vector2(x - 24.0, y + 12.0), 72.0, a)
		"splash":
			if dt >= -0.3 and dt < 0.4:
				part_c("fish_up", at + Vector2(x + 26.0, y - 12.0 - (dt + 0.3) * 30.0), 42.0)
			elif dt >= 0.4 and dt < 1.0:
				part_c("fish_dn", at + Vector2(x + 40.0, y - 10.0 + (dt - 0.4) * 30.0), 42.0, 1.0 - (dt - 0.4) / 0.6 * 0.5)
			if dt >= 0.0 and dt < 0.7:
				part_c("splash", at + Vector2(x + 8.0, y + 4.0), 60.0, 1.0 - dt / 0.7)
		"wave":
			if dt >= 0.0 and dt < 0.8:
				part_c("splash", at + Vector2(x - 10.0, y + 8.0), 50.0 + dt * 20.0, 1.0 - dt / 0.8)

func _header(at: Vector2) -> void :
	part("title", at + Vector2(4, -6))
	_dbtext(at + Vector2(80, 8), 150.0, 34.0, 20.0, Color.WHITE, Color("8a1d00"), "center", DR_TIP)
	tip_area(Rect2(at + Vector2(4, 0), Vector2(292, 60)), 0, DR_RULES)
	part_bar("pill", at + Vector2(318, 12), 200.0, 34.0)
	part_c("watch", at + Vector2(322, 26), 34.0)
	_dbtext(at + Vector2(342, 12), 172.0, 34.0, 15.0, DR_INK, NONE, "center", timer_text())
	part_bar("pill", at + Vector2(548, 12), 200.0, 34.0)
	part_c("coin", at + Vector2(556, 29), 26.0)
	_dbtext(at + Vector2(572, 12), 170.0, 34.0, 15.0, DR_INK, NONE, "center", num(silver) + " Bạc")
	tip_area(Rect2(at + Vector2(540, 12), Vector2(208, 34)), 0, "Bạc hiện có.\nHôm nay đã cổ vũ %s / %s Bạc." % [num(spent), num(cap)])

func _cards(at: Vector2, p: String) -> void :
	for i in mini(5, ducks.size()):
		var d: Dictionary = ducks[i]
		var c: Vector2 = at + Vector2(31.0 + float(i) * 108.0, 373.0)
		var chosen: bool = i == sel_lane
		var hover: bool = _hover == "lane:" + str(i) and not _mobile
		if chosen:
			_round(Rect2((c - Vector2(3, 3)) * _f, Vector2(102, 133) * _f), Color(DR_GOLD, 0.55), 10.0, Color("ff9a1f"), 2.0)
		part("card", c, 1.0, 1.0 if not hover or chosen else 0.92)
		var face_c: Vector2 = c + Vector2(48, 42)
		if chosen:
			part_c("ring", face_c, 84.0)
		part_c("face_" + str(i), face_c, 66.0 if chosen else 64.0)
		var stars: int = int(d["star"])
		for k in stars:
			part_c("star_on", c + Vector2(48.0 + (float(k) - float(stars - 1) / 2.0) * 14.0, 84.0), 13.0)
		_dbtext(c + Vector2(8, 93), 80.0, 22.0, 15.0, Color("b0400a"), NONE, "center", mult_text(float(d["mult"])))
		part_c("heart", c + Vector2(80, 10), 14.0)
		_dbtext(c + Vector2(30, 3), 40.0, 16.0, 11.0, DR_INK, NONE, "right", str(int(d["n"])))
		if int(d["my"]) > 0:
			_round(Rect2((c + Vector2(4, 4)) * _f, Vector2(40, 16) * _f), Color("2f9e44"), 8.0, Color.WHITE, 1.0)
			_dbtext(c + Vector2(4, 4), 40.0, 16.0, 10.0, Color.WHITE, NONE, "center", tier_label(int(d["my"])))
		var rect: Rect2 = Rect2(c, Vector2(96, 127))
		if p != "closed":
			_hit("lane:" + str(i), Rect2(rect.position * _f, rect.size * _f), false)
		var line: String = "%s — %d sao, về nhất được %s.\n%d người đang cổ vũ." % [NAMES[i], stars, mult_text(float(d["mult"])), int(d["n"])]
		if int(d["my"]) > 0:
			line += "\nBạn đã cổ vũ %s Bạc." % num(int(d["my"]))
		tip_area(rect, 0, line)

func _chips(at: Vector2, p: String) -> void :
	for i in mini(5, tiers.size()):
		var c: Vector2 = at + Vector2(52.0 + float(i) * 60.0, 538.5)
		var chosen: bool = i == sel_tier
		if chosen:
			c.y -= 3.0

			draw_set_transform(c * _f, 0.0, Vector2(1.0, 0.62))
			draw_circle(Vector2.ZERO, 34.0 * _f, Color(DR_GOLD, 0.28))
			draw_circle(Vector2.ZERO, 28.0 * _f, Color(DR_GOLD, 0.5))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		part_c("chip_" + str(i), c, 52.0)

		_fwords(tier_label(int(tiers[i])), ARIAL_BOLD, 15.0, DR_CHIP_INK, "c", c - Vector2(30, 10), 60.0, 3.5, 0.0, false, DR_CHIP_RIM)
		if p == "bet":
			_hit("tier:" + str(i), Rect2((c - Vector2(26, 26)) * _f, Vector2(52, 52) * _f), false)
	var state: Array = bet_button()
	var id: String = str(state[2])
	var live: int = int(state[1])
	var lit: bool = live == 1 and _hover == id and not _mobile
	var down: bool = live == 1 and _press == id and _hover == id
	var spot: Vector2 = at + Vector2(382, 510.5 + (1.0 if down else 0.0))
	var face: String = "btn_off" if live < 0 else ("btn_hi" if lit else "btn")
	var rect: Rect2 = part(face, spot, 1.0, 0.75 if live == 0 else 1.0)
	_dbtext(spot + Vector2(56, 0), 114.0, 56.0, 17.0 if str(state[0]).length() <= 8 else 14.0, Color.WHITE, Color("8a3a00") if live >= 0 else Color("555555"), "center", str(state[0]))
	if live == 1:
		_hit(id, rect, false)


func _side(at: Vector2) -> void :
	for i in mini(10, hist.size()):
		var h: Dictionary = hist[i]
		var c: Vector2 = at + Vector2(603.0 + float(i) * 24.8, 388.0)
		part_c("face_" + str(clampi(int(h["w"]), 0, 4)), c, 22.0)
		tip_area(Rect2(c - Vector2(11, 11), Vector2(22, 22)), 0, "Ván #%d: %s về nhất (%d sao, %s)." % [int(h["r"]), NAMES[clampi(int(h["w"]), 0, 4)], 
			int(h["star"]), mult_text(float(h["mult"]))])
	_dbtext(at + Vector2(590, 402), 248.0, 20.0, 13.0, Color("b0400a"), NONE, "center", "Thắng lớn hôm nay")
	for j in mini(5, top_rows.size()):
		var row: Dictionary = top_rows[j]
		var y: float = 422.0 + float(j) * 25.0
		part_bar("row", at + Vector2(590, y), 248.0, 23.0)
		if j < 3:
			part_c("medal_" + str(j), at + Vector2(602, y + 11.5), 14.0)
		else:
			_dbtext(at + Vector2(592, y), 20.0, 23.0, 11.0, DR_INK, NONE, "center", str(j + 1))
		part_c("face_" + str(clampi(int(row["lane"]), 0, 4)), at + Vector2(624, y + 11.5), 18.0)
		_dbtext(at + Vector2(636, y), 112.0, 23.0, 12.0, DR_INK, NONE, "left", str(row["nick"]))
		_dbtext(at + Vector2(746, y), 88.0, 23.0, 12.0, Color("2f7d1e"), NONE, "right", "+" + num(int(row["win"])))
		tip_area(Rect2(at + Vector2(590, y), Vector2(248, 23)), 0, "%s cổ vũ %s, thắng %s Bạc (%s)." % [str(row["nick"]), 
			NAMES[clampi(int(row["lane"]), 0, 4)], num(int(row["win"])), mult_text(float(row["mult"]))])
	if top_rows.is_empty():
		_dbtext(at + Vector2(590, 440), 248.0, 40.0, 12.0, Color(DR_INK, 0.7), NONE, "center", "Chưa có ai thắng lớn hôm nay.")
	_dbtext(at + Vector2(590, 547), 248.0, 18.0, 11.0, DR_INK, NONE, "center", "Hôm nay: %s / %s Bạc" % [num(spent), num(cap)])


func _overlay(at: Vector2, p: String) -> void :
	if p == "lock":
		var left: float = race_at - round_t()
		_round(Rect2((at + Vector2(300, 150)) * _f, Vector2(260, 84) * _f), Color("0b3a66", 0.8), 14.0, DR_GOLD, 2.0)
		_dbtext(at + Vector2(300, 154), 260.0, 30.0, 18.0, DR_GOLD, Color("3a1a00"), "center", "Chuẩn bị xuất phát!")
		_dbtext(at + Vector2(300, 184), 260.0, 44.0, 30.0 if left <= 5.0 else 20.0, Color.WHITE, Color("06325a"), "center", 
			str(maxi(1, int(ceil(left)))) if left <= 5.0 else clock_text(left))
	elif p == "pay" and race_winner >= 0:
		var w: int = race_winner
		_round(Rect2((at + Vector2(210, 128)) * _f, Vector2(440, 170) * _f), Color("0b3a66", 0.82), 16.0, DR_GOLD, 2.0)
		part("trophy", at + Vector2(222, 152), 1.0)
		part_c("face_" + str(w), at + Vector2(372, 176), 52.0)
		_dbtext(at + Vector2(402, 156), 240.0, 40.0, 22.0, DR_GOLD, Color("3a1a00"), "left", NAMES[w] + " về nhất!")
		var mult: float = float(ducks[w]["mult"]) if w < ducks.size() else 0.0
		_dbtext(at + Vector2(346, 204), 290.0, 26.0, 15.0, Color.WHITE, NONE, "left", "Hệ số " + mult_text(mult))
		var line: String = "Bạn chưa cổ vũ ván này."
		var ink: Color = Color(1, 1, 1, 0.8)
		if not res.is_empty():
			if int(res["won"]) > 0:
				line = "Bạn nhận %s Bạc!" % num(int(res["won"]))
				ink = Color("8dff7a")
				seen_win = round_id
			else:
				line = "Chưa trúng ván này, thử lại ván sau nhé."
		_dbtext(at + Vector2(346, 234), 290.0, 26.0, 15.0, ink, Color("06325a"), "left", line)
		_dbtext(at + Vector2(346, 262), 290.0, 22.0, 12.0, Color(1, 1, 1, 0.75), NONE, "left", timer_text())
	elif p == "closed":
		_round(Rect2((at + Vector2(16, 64)) * _f, Vector2(828, 293) * _f), Color(0, 0, 0, 0.45), 8.0)
		_dbtext(at + Vector2(16, 170), 828.0, 36.0, 22.0, Color.WHITE, Color("06325a"), "center", "Ngoài giờ đua")
		if not next_text.is_empty():
			_dbtext(at + Vector2(16, 206), 828.0, 26.0, 14.0, DR_CREAM, Color("06325a"), "center", next_text)


func _chrome(at: Vector2) -> void :
	var down: bool = _press == "close" and _hover == "close"
	var rect: Rect2 = part("close", at + Vector2(806, 7 + (1 if down else 0)), 1.0, 0.9 if _hover == "close" and not _mobile else 1.0)
	_hit("close", rect, false)
	rules_button(at + Vector2(781, 28))


func rules_title() -> String:
	return "LUẬT CHƠI · VỊT SIÊU TỐC"

func rules_text() -> String:
	var text: String = "Mỗi ván 5 phút: cổ vũ 3 phút 40 giây, khoá 15 giây, 5 vịt đua 30 giây, rồi trao thưởng. Mở 08:00 – 24:00 mỗi ngày."
	text += "\n• Chọn vịt và mức Bạc rồi bấm CỔ VŨ, mỗi ván cổ vũ tối đa %d vịt." % maxi(1, max_lanes)
	text += "\n• Vịt về nhất trả Bạc = tiền cổ vũ × hệ số trên thẻ vịt. Vịt khác về nhất thì mất tiền cổ vũ."
	text += "\n• Sao = phong độ: nhiều sao dễ về nhất nhưng hệ số thấp, ít sao khó thắng nhưng hệ số cao."

	if cap > 0:
		text += "\n• Mỗi ngày cổ vũ tối đa %s Bạc." % num(cap)
	if min_lv > 0:
		text += "\n• Cần cấp %d trở lên." % min_lv
	return text
