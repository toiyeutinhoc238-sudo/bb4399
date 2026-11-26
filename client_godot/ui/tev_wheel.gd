extends "tev_window.gd"







const MB_POLL_TICKS: int = 120
const FW_FILES: Array = ["fw_bg", "box_j", "box_r", "box_c", "box_won", "box_hl", "fx_rays", "btn_quay_done", "chip_wallet", 
	"chip_time", "plate_won", "step_done", "step_cur", "step_next", "bubble", "teddy_a", "teddy_b", "coin_16", "coin_20", 
	"btn_close_st", "btn_quay_st", "btn_help_st", "fx_sparkle", "fx_burst", "fx_jackpot"]
const FW_MORE: Array = ["glow_box_j", "glow_quay"]
const FW_SHEETS: Dictionary = {
	"btn_close_st": [40, 40, 1, 4], "btn_quay_st": [200, 82, 1, 4], "btn_help_st": [36, 36, 1, 4], 
	"fx_sparkle": [48, 48, 8, 8], "fx_burst": [128, 128, 8, 8], "fx_jackpot": [160, 160, 8, 8], 
}
const FW_SLOW: Array = [2, 2, 3, 3, 4, 5, 6, 8, 10, 13]
const FW_SAY: Array = ["Quay là trúng, ô nào cũng có quà!", "Ô Đặc Biệt đang chờ bạn đó~", 
	"Ô đã trúng sẽ khóa, lượt sau dễ trúng quà to hơn!", "Thần Tài gõ cửa, quay một lượt nha!"]
const FW_NAME: String = "Vòng Quay Thần Tài"
const FW_CREAM: Color = Color("fff1c9")
const FW_INK: Color = Color("4a0b0b")
const FW_DIM: Color = Color("c9b494")
const FW_SHORT: Color = Color("ff8a7a")
const FW_PLATE_INK: Color = Color("5a1a10")
const FW_CLOSE: Vector2 = Vector2(832, 82)
const FW_BOXES: Array = [280, 176, 364, 180, 436, 230, 453, 314, 437, 395, 377, 465, 280, 491, 182, 466, 122, 395, 105, 314, 124, 229, 196, 180]
const FW_BOX_C: Vector2 = Vector2(48, 64)
const FW_BOX_ICON: Vector2 = Vector2(48, 65)
const FW_HL_C: Vector2 = Vector2(53, 55)
const FW_WELL: Vector2 = Vector2(279, 276)
const FW_RAYS: Vector2 = Vector2(279, 276)
const FW_QUAY: Vector2 = Vector2(180, 363)
const FW_QUAY_PILL: Array = [65, 45, 71, 21]
const FW_WALLET: Vector2 = Vector2(493, 120)
const FW_WALLET_COIN: Vector2 = Vector2(19, 19)
const FW_TIME: Vector2 = Vector2(629, 120)
const FW_WON: Vector2 = Vector2(549, 165)
const FW_STEPS: Array = [525, 232, 594, 232, 663, 232, 732, 232, 525, 276, 594, 276, 663, 276, 732, 276, 525, 320, 594, 320, 663, 320, 732, 320]
const FW_LEGEND: Array = [576, 378, 40, 20, 666, 378, 40, 20, 756, 378, 40, 20]
const FW_BUBBLE: Vector2 = Vector2(525, 420)
const FW_TEDDY: Vector2 = Vector2(637, 400)
const FW_HELP: Vector2 = Vector2(521, 504)
const GLOW_PAD: Vector2 = Vector2(16, 16)

static var s_fw_shown: bool = false
static var s_fw_seen: bool = false

var poll_in: int = 9
var fw_visible: bool = false
var loaded: bool = false
var fw_name: String = FW_NAME
var season: String = ""
var end_at: float = 0.0
var round_no: int = 1
var rounds: int = 1
var finished: bool = false
var step: int = 0
var next: int = 0
var xu: int = -1
var show_xu: int = -1
var token: String = ""
var slots: Array = []
var prices: Array = []
var run: int = 0
var hl: int = -1
var hl_wait: int = 0
var hl_hold: int = 0
var left: int = 0
var cheer_at: int = 0
var say_text: String = ""
var say_at: int = 0
var asked: bool = false
var pend_st: Variant = null
var prize: Variant = null
var now_skew: float = 0.0


var _b_ready: bool = false
var _b_failed: bool = false
var _b_live: bool = false
var _b_short: bool = false
var _quay_pressed: bool = false
var _rays_rot: float = 0.0
var _glow_a: float = 0.55
var _say_line: String = ""
var _teddy_key: String = "teddy_a"
var _time_line: String = ""
var _time_tip: String = ""
var _rules: String = ""
var _art_wait: bool = false

func _setup() -> void :
	art_dir = "l/ev/fw/"
	art_files = FW_FILES
	art_more = FW_MORE
	sheets = FW_SHEETS
	win_size = Vector2(880, 580)
	super ()

static func reset_statics() -> void :
	s_fw_shown = false
	s_fw_seen = false


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 9
	fw_visible = false
	loaded = false
	fw_name = FW_NAME
	season = ""
	end_at = 0.0
	round_no = 1
	rounds = 1
	finished = false
	step = 0
	next = 0
	xu = -1
	show_xu = -1
	token = ""
	slots = []
	prices = []
	run = 0
	hl = -1
	hl_hold = 0
	left = 0
	cheer_at = 0
	say_text = ""
	say_at = 0
	asked = false
	pend_st = null
	prize = null
	reset_statics()




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/fortune-wheel.xml?r=" + str(int(now_ms())), "poll")


func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = MB_POLL_TICKS if fw_visible else MB_POLL_TICKS * 3
		if not loading:
			poll()


func button_visible() -> bool:
	return fw_visible


func button_dot() -> bool:
	return fw_visible and not finished and not s_fw_seen and (xu < 0 or xu >= next)

func busy() -> bool:
	return loading and action != "poll"


func open() -> void :
	if opened or ( not fw_visible and loaded):
		return
	retry_art()
	s_fw_seen = true
	run = 0
	hl = -1
	hl_hold = 0
	pend_st = null
	prize = null
	cheer_at = 0
	say_text = ""
	asked = false
	show_xu = xu
	show_window()
	load_art()
	if pack != null:
		pack.load_events()
		pack.load_quest()
		pack.load_bag()
	_rebuild()
	if action.is_empty() or action == "poll":
		poll()


func close() -> void :
	if not opened:
		return
	hide_window()
	if pend_st != null:
		_apply(pend_st)
		_prize_tip(prize)
	pend_st = null
	prize = null
	run = 0
	hl = -1
	_quay_pressed = false
	poll_in = MB_POLL_TICKS


func leave() -> void :
	close()

func _activate(id: String) -> void :
	match id:
		"quay":
			on_quay()
		"close":
			close()



func _failed(what: String) -> void :
	if what != "poll":
		tip("Không kết nối được máy chủ, hãy thử lại.")
	if what == "spin" and run == 1:
		run = 0
		hl = -1
	if opened and run == 0:
		_rebuild()

func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_xml(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	var parsed: bool = xml != null
	var notice: String = ""
	var st: Dictionary = {}
	var won: Variant = null
	if parsed:
		notice = str(xml["at"].get("notice", ""))
		st = parse_state(xml)
		var spins: Array = kids(xml, "spin")
		if not spins.is_empty():
			var at: Dictionary = spins[0]["at"]
			var items: Array = items_of(str(at.get("it", "")))
			won = {"slot": as_int(str(at.get("slot", ""))), "r": str(at.get("r", "")), 
				"id": int(items[0]["id"]) if not items.is_empty() else 0, "n": int(items[0]["n"]) if not items.is_empty() else 1, 
				"price": as_int(str(at.get("price", ""))), "tip": str(at.get("tip", ""))}
	asked = false
	if not parsed and what != "poll":
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if parsed and won != null and run == 1 and opened and bool(st["visible"]) and int(won["slot"]) >= 0 and int(won["slot"]) < 12:

		pend_st = st
		prize = won
		run = 2
		left = 12 + (int(won["slot"]) - maxi(0, hl) + 12) % 12
		if int(st["xu"]) >= 0:
			xu = int(st["xu"])
		say_text = "Vòng quay đang chạy..."
		_say_line = say_line()
		_pay_fx()
	else:
		if parsed:
			_apply(st)
		if won != null:
			_prize_tip(won)
		run = 0
		hl = -1
		hl_hold = 0
	if opened and not fw_visible:
		close()
	elif opened and run == 0:
		_rebuild()
	if not notice.is_empty():
		tip(notice)


func parse_state(node: Dictionary) -> Dictionary:
	var at: Dictionary = node["at"]
	var st: Dictionary = {"visible": str(at.get("visible", "")) == "1"}
	if not st["visible"]:
		return st
	var got: Array = []
	got.resize(12)
	var cost: Array = []
	cost.resize(12)
	for kid: Dictionary in kids(node, "s"):
		var i: int = as_int(str(kid["at"].get("i", "")))
		var items: Array = items_of(str(kid["at"].get("it", "")))
		if i >= 0 and i < 12 and not items.is_empty():
			var odds: float = as_number(str(kid["at"].get("p", "")).replace("%", ""))
			got[i] = {"r": str(kid["at"].get("r", "")), "id": int(items[0]["id"]), "n": int(items[0]["n"]), 
				"w": str(kid["at"].get("w", "")) == "1", "p": odds}
	for kid: Dictionary in kids(node, "p"):
		var i: int = as_int(str(kid["at"].get("n", ""))) - 1
		if i >= 0 and i < 12:
			cost[i] = as_int(str(kid["at"].get("v", "")))
	for i in 12:
		if got[i] == null or cost[i] == null:
			st["visible"] = false
			return st
	st["name"] = str(at.get("name", "")) if not str(at.get("name", "")).is_empty() else FW_NAME
	st["season"] = str(at.get("season", ""))
	st["endAt"] = now_ms() + as_number(str(at.get("left", ""))) * 1000.0
	st["round"] = as_int(str(at.get("round", "")))
	st["rounds"] = maxi(1, as_int(str(at.get("rounds", ""))))
	st["finished"] = str(at.get("finished", "")) == "1"
	st["step"] = as_int(str(at.get("step", "")))
	st["next"] = as_int(str(at.get("next", "")))
	st["xu"] = -1 if str(at.get("xu", "")).is_empty() else as_int(str(at.get("xu", "")))
	st["token"] = str(at.get("token", ""))
	st["slots"] = got
	st["prices"] = cost
	return st


func _apply(st: Dictionary) -> void :
	fw_visible = bool(st["visible"])
	s_fw_shown = fw_visible
	loaded = true
	if not fw_visible:
		slots = []
		prices = []
		return
	fw_name = str(st["name"])
	season = str(st["season"])
	end_at = float(st["endAt"])
	round_no = int(st["round"])
	rounds = int(st["rounds"])
	finished = bool(st["finished"])
	step = int(st["step"])
	next = int(st["next"])
	token = str(st["token"])
	slots = st["slots"]
	prices = st["prices"]
	xu = int(st["xu"])
	if not opened or show_xu < 0 or xu < 0:
		show_xu = xu


func _prize_tip(won: Variant) -> void :
	if won == null:
		return
	var name: String = item_name(int(won["id"]))
	var line: String = str(won["tip"]) if not str(won["tip"]).is_empty() else "Phần thưởng Vòng Quay Thần Tài đã vào túi."
	tip(("Trúng %s x%d. " % [name, int(won["n"])] if not name.is_empty() else "") + line)


func on_quay() -> void :
	if busy() or run != 0 or finished or not loaded or token.is_empty():
		return
	if xu >= 0 and xu < next:
		tip("Không đủ Xu: lượt này cần " + num(next) + " Xu, đang có " + num(xu) + ".")
		return
	run = 1
	hl = maxi(0, hl)
	hl_hold = 0
	hl_wait = 2
	_quay_pressed = true
	fetch("/fortune-wheel-spin.xml?k=" + uri_component(token) + "&r=" + str(int(now_ms())), "spin")


static func uri_component(text: String) -> String:
	return text.uri_encode().replace("%21", "!").replace("%27", "'").replace("%28", "(").replace("%29", ")").replace("%2A", "*")


static func as_number(text: String) -> float:
	var s: String = text.strip_edges()
	if s.is_empty():
		return 0.0
	if s.is_valid_float():
		return s.to_float()
	if s.to_lower().begins_with("0x") and s.substr(2).is_valid_hex_number():
		return float(s.substr(2).hex_to_int())
	return NAN


static func as_int(text: String) -> int:
	var value: float = as_number(text)
	if is_nan(value) or is_inf(value):
		return 0
	return int(value)



func box_centre(i: int) -> Vector2:
	return Vector2(float(FW_BOXES[i * 2]), float(FW_BOXES[i * 2 + 1]))


func _spin_tick() -> void :
	if run == 0:
		if hl_hold > 0:
			hl_hold -= 1
			if hl_hold == 0:
				hl = -1
		return
	hl_wait -= 1
	if hl_wait > 0:
		return
	_trail(hl)
	hl = (hl + 1) % 12
	if run == 1:
		hl_wait = 2
		return
	left -= 1
	if left <= 0:
		_land()
		return
	hl_wait = 2 if left > 10 else int(FW_SLOW[10 - left])


func _trail(i: int) -> void :
	if not opened or i < 0 or i >= 12 or art("box_hl") == null:
		return
	var fx: Dictionary = fx_add("pic", "box_hl", box_centre(i), {"life": 8, "fade": 8, "alpha": 0.6, "layer": "hl"})
	fx["dx"] = - FW_HL_C.x
	fx["dy"] = - FW_HL_C.y
	_fx.pop_back()
	_fx.push_front(fx)


func _land() -> void :
	var won: Variant = prize
	var st: Variant = pend_st
	run = 0
	pend_st = null
	prize = null
	hl_hold = 50
	cheer_at = tick + 60
	if st != null:
		_apply(st)
	if won == null:
		_rebuild()
		return
	var name: String = item_name(int(won["id"]))
	say_text = "Trúng %s x%d!" % [name, int(won["n"])] if not name.is_empty() else "Trúng thưởng rồi!"
	say_at = tick + 120
	_rebuild()
	var at: Vector2 = box_centre(int(won["slot"]))
	fx_burst("fx_burst", at, 2)
	if str(won["r"]) == "j":
		fx_burst("fx_jackpot", at, 2)
		fx_burst("fx_jackpot", FW_WELL, 3)
		fx_sparkles("fx_sparkle", FW_WELL, 6)
	fx_pop_item(int(won["id"]), at)
	fx_sparkles("fx_sparkle", at, 5)
	_prize_tip(won)


func _pay_fx() -> void :
	var from: Vector2 = FW_WALLET + FW_WALLET_COIN
	var to: Vector2 = FW_QUAY + Vector2(float(FW_QUAY_PILL[0]) + float(FW_QUAY_PILL[2]) / 2.0, float(FW_QUAY_PILL[1]) + float(FW_QUAY_PILL[3]) / 2.0)
	for i in 5:
		fx_fly("coin_20", from, to, i)


func _anim() -> void :
	_spin_tick()
	if not opened:
		return
	_rays_rot += 2.0 if run != 0 else 0.4
	_glow_a = 0.55 + 0.45 * sin(float(tick) * 0.12)
	if tick % 5 == 0:
		_teddy_show()
	if show_xu != xu and xu >= 0 and show_xu >= 0:
		var k: int = xu - show_xu
		show_xu += maxi(1, int(float(k) / 6.0)) if k > 0 else mini(-1, int(float(k) / 6.0))
	if tick % 25 == 0:
		_time_line = time_line()
		_time_tip = time_tip()
		if end_at <= now_ms() and not asked and not loading and run == 0:
			asked = true
			poll()
	if tick % 150 == 0 or say_at == tick:
		_say_line = say_line()
	if tick % 30 == 0 and run == 0:
		fx_sparkles("fx_sparkle", FW_WELL - Vector2(0, 10), 1)

func _tick(delta: float) -> void :
	super (delta)
	if opened and _art_wait and art_pending() == 0:
		_rebuild()




func say_line() -> String:
	if not say_text.is_empty() and (run != 0 or say_at > tick):
		return say_text
	if finished:
		return "Bạn đã ôm trọn 12 ô quà!"
	if xu >= 0 and xu < next:
		return "Lượt tới cần " + num(next) + " Xu nha!"
	return str(FW_SAY[int(float(tick) / 150.0) % FW_SAY.size()])

func time_line() -> String:
	return "Còn " + left_text(end_at, now_ms()) if end_at > now_ms() else "Đã kết thúc"

func time_tip() -> String:
	return "Mùa " + season + " kết thúc sau " + left_text(end_at, now_ms()) + ".\nHết mùa thì Vòng Quay đóng lại."


func rules() -> String:
	var counts: Dictionary = {"j": 0, "r": 0, "c": 0}
	for slot: Dictionary in slots:
		if counts.has(str(slot["r"])):
			counts[str(slot["r"])] = int(counts[str(slot["r"])]) + 1
	var total: int = 0
	for price: int in prices:
		total += price
	var first: int = int(prices[0]) if not prices.is_empty() else 0
	var last: int = int(prices[11]) if prices.size() > 11 else 0
	return fw_name + " · mùa " + season + "\n" + "• 12 ô quà: " + str(counts["j"]) + " Đặc Biệt, " + str(counts["r"]) + " Trung, " + str(counts["c"]) + """ Thường.
""" + "• Mỗi lượt chắc chắn trúng 1 ô chưa trúng; ô đã trúng bị khóa.\n"\
	+ "• Giá tăng dần " + num(first) + " → " + num(last) + " Xu, cả 12 lượt " + num(total) + " Xu.\n"\
	+ ("• Trúng hết 12 ô thì sang vòng mới (tối đa " + str(rounds) + " vòng).\n" if rounds > 1 else "• Trúng hết 12 ô là hoàn thành Vòng Quay mùa này.\n")\
	+ "• Quà vào túi ngay, túi đầy thì gửi vào Hộp thư.\n" + "• Mùa kết thúc sau " + left_text(end_at, now_ms()) + "."

func won_count() -> int:
	var n: int = 0
	for slot: Dictionary in slots:
		if bool(slot["w"]):
			n += 1
	return n

func jackpot() -> Variant:
	for slot: Dictionary in slots:
		if str(slot["r"]) == "j":
			return slot
	return null


func _teddy_show() -> void :
	var key: String = "teddy_b" if cheer_at > tick or run != 0 else "teddy_a"
	if art(key) != null:
		_teddy_key = key


func _rebuild() -> void :
	if not opened:
		return
	fx_drop("hl")
	var pending: int = art_pending()
	_art_wait = pending != 0
	_b_ready = pending == 0 and art("fw_bg") != null and loaded and slots.size() == 12
	_b_failed = pending == 0 and art("fw_bg") == null
	_b_live = not busy() and run == 0
	_b_short = xu >= 0 and xu < next
	_quay_pressed = false
	_rays_rot = 0.0
	_teddy_key = "teddy_a"
	_teddy_show()
	_say_line = say_line()
	_time_line = time_line()
	_time_tip = time_tip()
	_rules = rules() if _b_ready else ""


func ready_shown() -> bool:
	return _b_ready



func _body(at: Vector2) -> void :
	if not _b_ready:
		_wait_panel(at, _b_failed)
		return
	pic("fw_bg", at)
	_showcase(at)
	_boxes(at)
	_ladder(at)
	_chips(at)
	_quay(at)
	_teddy(at)
	if art("btn_help_st") != null:
		art_button("help", "btn_help_st", at + FW_HELP, 2)
		tip_area(Rect2(at + FW_HELP, art_size("btn_help_st")), 0, _rules)
	if art("btn_close_st") != null:
		art_button("close", "btn_close_st", at + FW_CLOSE, 1)

func _chrome(at: Vector2) -> void :
	if not _b_ready or art("btn_close_st") == null:
		_native_close(at)


func _showcase(at: Vector2) -> void :
	var jp: Variant = jackpot()
	var won: bool = jp != null and bool(jp["w"])
	var rays: Texture2D = art("fx_rays")
	if rays != null:
		var half: Vector2 = Vector2(float(int(rays.get_width() / 2)), float(int(rays.get_height() / 2)))
		draw_set_transform((at + FW_RAYS) * _f, deg_to_rad(_rays_rot), Vector2.ONE)
		draw_texture_rect(rays, Rect2( - half * _f, Vector2(rays.get_size()) * _f), false, Color(1, 1, 1, 0.35 if won else 1.0))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if jp == null:
		return
	var alpha: float = 0.45 if won else 1.0
	var centre: Vector2 = at + FW_WELL + Vector2(0, 2.0 * sin(float(tick) * 0.08))
	icon(int(jp["id"]), 68.0, centre, alpha)
	if int(jp["n"]) > 1:
		_dbtext(centre + Vector2(-34, 16), 68.0, 20.0, 13.0, Color(FW_CREAM, alpha), Color(FW_INK, alpha), "right", "x%d" % int(jp["n"]))
	tip_area(Rect2(at + FW_WELL - Vector2(34, 34), Vector2(68, 68)), int(jp["id"]), "")


func _boxes(at: Vector2) -> void :
	_draw_fx(at, "hl")
	if hl >= 0 and hl < 12:
		pic("box_hl", at + box_centre(hl) - FW_HL_C)
	var glowing: int = -1
	for i in mini(12, slots.size()):
		if not bool(slots[i]["w"]) and str(slots[i]["r"]) == "j":
			glowing = i
	for i in mini(12, slots.size()):
		var slot: Dictionary = slots[i]
		var centre: Vector2 = at + box_centre(i)
		var corner: Vector2 = centre - FW_BOX_C
		if i == glowing:
			pic("glow_box_j", corner - GLOW_PAD, _glow_a)
		pic("box_" + str(slot["r"]), corner)
		icon(int(slot["id"]), 32.0, corner + FW_BOX_ICON, 0.5 if bool(slot["w"]) else 1.0)
		if int(slot["n"]) > 1:
			_dbtext(corner + Vector2(29, 95), 38.0, 13.0, 11.0, FW_PLATE_INK, NONE, "center", "x%d" % int(slot["n"]))
		if bool(slot["w"]):
			pic("box_won", corner)
		tip_area(Rect2(centre - Vector2(20, 20), Vector2(40, 40)), int(slot["id"]), "")


func _ladder(at: Vector2) -> void :
	for i in 12:
		var corner: Vector2 = at + Vector2(float(FW_STEPS[i * 2]), float(FW_STEPS[i * 2 + 1]))
		var state: String = "done" if i < step or finished else ("cur" if i == step else "next")
		var color: Color = FW_DIM if state == "done" else FW_PLATE_INK
		var glow: Color = FW_INK if state == "done" else NONE
		pic("step_" + state, corner)
		_dbtext(corner + Vector2(13, 3), 34.0, 17.0, 10.0, color, glow, "center", str(i + 1))
		pic_c("coin_16", corner + Vector2(13, 31))
		_dbtext(corner + Vector2(24, 23), 37.0, 16.0, 12.0, color, glow, "center", num(int(prices[i]) if i < prices.size() else 0))
	var sums: Dictionary = {"j": 0.0, "r": 0.0, "c": 0.0}
	for slot: Dictionary in slots:
		if sums.has(str(slot["r"])):
			sums[str(slot["r"])] = float(sums[str(slot["r"])]) + float(slot["p"])
	var ranks: Array = ["j", "r", "c"]
	for i in 3:
		_dbtext(at + Vector2(float(FW_LEGEND[i * 4]), float(FW_LEGEND[i * 4 + 1])), float(FW_LEGEND[i * 4 + 2]), float(FW_LEGEND[i * 4 + 3]), 
			11.0, FW_PLATE_INK, NONE, "center", percent(float(sums[ranks[i]])))
	tip_area(Rect2(at + Vector2(float(FW_LEGEND[0]) - 70.0, float(FW_LEGEND[1]) - 4.0), 
		Vector2(float(FW_LEGEND[8]) + float(FW_LEGEND[10]) - float(FW_LEGEND[0]) + 74.0, float(FW_LEGEND[3]) + 8.0)), 0, 
		"Tỉ lệ trúng của lượt tới, theo loại quà.\nÔ đã trúng bị khóa nên tỉ lệ các ô còn lại tăng dần.")


func _chips(at: Vector2) -> void :
	var corner: Vector2 = at + FW_WALLET
	pic("chip_wallet", corner)
	pic_c("coin_20", corner + FW_WALLET_COIN)
	_dbtext(corner + Vector2(33, 7), 93.0, 23.0, 13.0, FW_CREAM, FW_INK, "center", num(show_xu) if show_xu >= 0 else "--")
	tip_area(Rect2(corner, art_size("chip_wallet")), 0, "Xu đang có. Mỗi lượt quay trừ Xu theo bảng Giá mỗi lượt.")
	corner = at + FW_TIME
	pic("chip_time", corner)
	_dbtext(corner + Vector2(34, 7), 134.0, 23.0, 13.0, FW_CREAM, FW_INK, "center", _time_line)
	tip_area(Rect2(corner, art_size("chip_time")), 0, _time_tip)
	corner = at + FW_WON
	pic("plate_won", corner)
	_dbtext(corner + Vector2(45, 7), 126.0, 20.0, 13.0, FW_PLATE_INK, NONE, "center", 
		"Đã trúng " + str(won_count()) + "/12" + (" · Vòng " + str(mini(round_no, rounds)) + "/" + str(rounds) if rounds > 1 else ""))


func _quay(at: Vector2) -> void :
	var corner: Vector2 = at + FW_QUAY
	if finished:
		pic("btn_quay_done", corner)
		return
	var live: bool = _b_live and not _quay_pressed
	if live and run == 0:
		pic("glow_quay", corner - GLOW_PAD, 0.25 + 0.4 * _glow_a)
	var drawn: Array = art_button("quay", "btn_quay_st", corner, 1) if live else art_button("quay", "btn_quay_st", corner, 0, 2 if _quay_pressed else -1)
	if art("btn_quay_st") == null:
		return
	var alpha: float = 1.0 if _b_live and not _quay_pressed else 0.75
	var face: Vector2 = corner + Vector2(0, 1.0 if int(drawn[1]) == 2 else 0.0)
	var text: String = num(next)
	var px: float = float(FW_QUAY_PILL[0])
	var wide: float = 20.0 + text_width(text, 14.0)
	px += maxf(0.0, (float(FW_QUAY_PILL[2]) - wide) / 2.0)
	pic_c("coin_16", face + Vector2(px + 8.0, float(FW_QUAY_PILL[1]) + float(FW_QUAY_PILL[3]) / 2.0), alpha)
	_dbtext(face + Vector2(px + 18.0, float(FW_QUAY_PILL[1])), text_width(text, 14.0) + 8.0, float(FW_QUAY_PILL[3]), 14.0, 
		Color(FW_SHORT if _b_short else FW_CREAM, alpha), Color(FW_INK, alpha), "left", text)


func _teddy(at: Vector2) -> void :
	if art("bubble") != null:
		pic("bubble", at + FW_BUBBLE)
		_para_c(at + FW_BUBBLE + Vector2(11, 9), 107.0, 35.0, 12.0, FW_PLATE_INK, _say_line)
	pic(_teddy_key, at + FW_TEDDY + Vector2(0, roundf(1.5 * sin(float(tick) * 0.07))))
