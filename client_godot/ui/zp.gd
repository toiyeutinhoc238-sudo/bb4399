extends "tev_window.gd"









signal closed(note: String)

const ZpAtlas = preload("zp_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const MB_POLL_TICKS: int = 120
const MB_ARM_MS: float = 4000.0
const ZP_TIP: String = "Gói 0Đ"
const ZP_ICON: String = "btn_goi0d"
const ZP_WORD: String = "word_goi0d"
const ZP_W: float = 880.0
const ZP_H: float = 560.0
const ZP_FILES: Array = ["zp_bg", "chip_time", "chip_money", "cur_s", "cur_c", "cur_g", "cur_s_20", "cur_c_20", "cur_g_20", "tab_sel", "tab_open", 
	"tab_lock", "tab_off", "tab_crown", "dot_red", "daylabel_1", "daylabel_2", "daylabel_3", "daylabel_4", "daylabel_5", "daylabel_6", "daylabel_7", 
	"tab_het", "card", "card_gold", "cardname_s", "cardname_c", "cardname_g", "well", "card_dim", "solo_deco", "act_wait", "act_done", "act_off", 
	"act_lock", "teddy_a", "teddy_b", "btn_close_st", "btn_mua_st", "btn_nhan_st", "btn_nhanhet_st", "fx_sparkle", "fx_confetti", "fx_refund"]
const ZP_SHEETS: Dictionary = {
	"btn_close_st": [40, 40, 1, 4], "btn_mua_st": [188, 54, 1, 4], "btn_nhan_st": [188, 54, 1, 4], "btn_nhanhet_st": [180, 56, 1, 4], 
	"fx_sparkle": [48, 48, 8, 8], "fx_confetti": [128, 128, 8, 8], "fx_refund": [128, 128, 8, 8], 
}
const ZP_SAY: Array = ["Mua gói 0Đ: quà về túi, tiền về lại ví!", "Gói ngày 7 là QUÀ LỚN đó nha!", "Tới hạn nhớ quay lại NHẬN tiền hoàn nha!", 
	"Mỗi ngày một gói mới, đừng bỏ lỡ!"]
const ZP_CREAM: Color = Color("fff6e0")
const ZP_INK: Color = Color("0b1a44")
const ZP_GOLD: Color = Color("ffd86b")
const ZP_SHORT: Color = Color("ff7a8a")
const ZP_INFO_INK: Color = ZP_CREAM
const ZP_INFO_GLOW: Color = ZP_INK
const ZP_CLOSE: Vector2 = Vector2(820, 62)
const ZP_TIME: Vector2 = Vector2(86, 101)
const ZP_TIME_TEXT: Array = [36, 7, 148, 20]
const ZP_MONEY: Array = [359, 109, 503, 109, 647, 109]
const ZP_MONEY_ICON: Array = [18, 16, 20]
const ZP_MONEY_TEXT: Array = [35, 7, 101, 18]
const ZP_TABS: Array = [77, 138, 180, 138, 281, 138, 380, 138, 483, 138, 587, 138, 692, 138]
const ZP_TAB_LABEL: Vector2 = Vector2(52, 20)
const ZP_TAB_HET: Vector2 = Vector2(52, 38)
const ZP_TAB_CROWN: Vector2 = Vector2(52, 2)
const ZP_TAB_DOT: Vector2 = Vector2(90, 8)
const ZP_TAB_HIT: Array = [3, 4, 98, 42]
const ZP_BOARD: Array = [84, 198, 712, 278]
const ZP_CARD: Array = [201, 208, 274, 14]
const ZP_CARD_ICON: Vector2 = Vector2(36, 34)
const ZP_CARD_NAME: Vector2 = Vector2(128, 34)
const ZP_WELLS_1: Array = [104, 108]
const ZP_WELLS_2: Array = [68, 108, 140, 108]
const ZP_WELLS_3: Array = [68, 78, 140, 78, 104, 138]
const ZP_WELLS_4: Array = [68, 78, 140, 78, 68, 138, 140, 138]
const ZP_WELL_ICON: Array = [-1, -4, 40]
const ZP_WELL_COUNT: Array = [2, 15, 25, 12]
const ZP_VALUE: Array = [13, 171, 182, 16]
const ZP_PRICE: Array = [12, 191, 184, 16]
const ZP_ACT: Array = [10, 212, 188, 54]
const ZP_MUA_ICON: Vector2 = Vector2(76, 38)
const ZP_MUA_PRICE: Array = [90, 28, 52, 20]
const ZP_ACT_LINE: Array = [46, 30, 132, 16]
const ZP_ALL: Vector2 = Vector2(574, 486)
const ZP_TEDDY: Vector2 = Vector2(24, 405)
const ZP_INFO: Array = [242, 497, 318, 17, 242, 517, 318, 17]
const ZP_SOLO: Vector2 = Vector2(84, 198)
const ZP_GLOW_PAD: float = 14.0
const ZP_ARM_PAD: float = 18.0
const CURS: Array = ["s", "c", "g"]

static var s_zp_shown: bool = false
static var s_zp_seen: String = ""
static var s_zp_day: int = 0
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 11
var zp_visible: bool = false
var loaded: bool = false
var zp_name: String = "Gói 0Đ"
var season: String = ""
var end_at: float = 0.0
var due: int = 0
var test: bool = false
var token: String = ""
var money: Dictionary = {"g": -1, "c": -1, "s": -1}
var show_money: Dictionary = {"g": -1, "c": -1, "s": -1}
var cards: Array = []
var day: int = 0
var arm_key: String = ""
var arm_at: float = 0.0
var claim_key: String = ""
var cheer_at: int = 0
var say_text: String = ""
var say_at: int = 0
var asked: bool = false
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _b_ready: bool = false
var _b_failed: bool = false
var _b_busy: bool = false
var _b_cards: Array = []
var _at: Dictionary = {}
var _rows: Dictionary = {}
var _keys: Dictionary = {}
var _money_text: Dictionary = {}
var _glow_ids: Array = []
var _glow_a: float = -1.0
var _arm_id: String = ""
var _arm_a: float = -1.0
var _teddy_key: String = "teddy_a"
var _teddy_dy: float = 0.0
var _info2: String = ""

func _setup() -> void :
	art_dir = ""
	art_files = ZP_FILES
	sheets = ZP_SHEETS
	win_size = Vector2(ZP_W, ZP_H)
	super ()

static func reset_statics() -> void :
	s_zp_shown = false
	s_zp_seen = ""
	s_zp_day = 0


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 11
	zp_visible = false
	loaded = false
	zp_name = "Gói 0Đ"
	season = ""
	end_at = 0.0
	due = 0
	test = false
	token = ""
	money = {"g": -1, "c": -1, "s": -1}
	show_money = {"g": -1, "c": -1, "s": -1}
	cards = []
	day = 0
	arm_key = ""
	arm_at = 0.0
	claim_key = ""
	cheer_at = 0
	say_text = ""
	say_at = 0
	asked = false
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(ZpAtlas.FILE):
			_atlas = load(ZpAtlas.FILE) as Texture2D
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
	if atlas == null or not ZpAtlas.R.has(name):
		return null
	var row: Array = ZpAtlas.R[name]
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = atlas
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part


func _w(name: String) -> float:
	return art_size(name).x

func _h(name: String) -> float:
	return art_size(name).y


func button_icon() -> Texture2D:
	return art(ZP_ICON)

func button_word() -> Texture2D:
	return art(ZP_WORD)




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/zero-pack.xml?r=" + str(int(now_ms())), "poll")


func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = MB_POLL_TICKS if zp_visible else MB_POLL_TICKS * 3
		if not loading:
			poll()

static func card_key(card: Dictionary) -> String:
	return "|" + str(card["sn"]) + ":" + str(card["id"]) + "|"


func button_visible() -> bool:
	return zp_visible


func button_dot() -> bool:
	var dot: bool = zp_visible and due > 0
	for card: Dictionary in cards:
		if str(card["st"]) == "sale" and s_zp_seen.find(card_key(card)) < 0:
			dot = zp_visible
	return dot

func mark_seen() -> void :
	for card: Dictionary in cards:
		if str(card["st"]) == "sale" and s_zp_seen.find(card_key(card)) < 0:
			s_zp_seen += card_key(card)


func busy() -> bool:
	return loading and action != "poll"


func open() -> void :
	if opened or ( not zp_visible and loaded):
		return
	mark_seen()
	day = 0
	arm_key = ""
	arm_at = 0.0
	claim_key = ""
	cheer_at = 0
	say_text = ""
	asked = false
	show_money = money.duplicate()
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
	hide_window()
	_at = {}
	_rows = {}
	_keys = {}
	_arm_id = ""
	poll_in = MB_POLL_TICKS
	closed.emit(note)


func leave() -> void :
	close()

func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "all":
		on_nhan_het()
	elif id.begins_with("tab:"):
		on_tab(id.substr(4).to_int())
	elif id.begins_with("mua:"):
		on_mua(id)
	elif id.begins_with("nhan:"):
		on_nhan(id)




func _failed(what: String) -> void :
	claim_key = ""
	if what != "poll":
		tip("Không kết nối được máy chủ, hãy thử lại.")
	if opened:
		_rebuild()

static func money_of(at: Dictionary, key: String) -> int:
	var text: String = str(at.get(key, ""))
	return -1 if text.is_empty() else TevWheel.as_int(text)


func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_xml(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	var parsed: bool = xml != null
	var notice: String = ""
	var got_tip: String = ""
	var list: Array = []
	var done: Variant = null
	var is_visible: bool = false
	var at: Dictionary = {}
	if parsed:
		at = xml["at"]
		notice = str(at.get("notice", ""))
		is_visible = str(at.get("visible", "")) == "1"
		var now: float = now_ms()
		if is_visible:
			for node: Dictionary in kids(xml, "p"):
				var p: Dictionary = node["at"]
				var t: float = TevWheel.as_number(str(p.get("t", "")))
				list.append({
					"id": str(p.get("id", "")), "sn": str(p.get("sn", "")), "day": TevWheel.as_int(str(p.get("day", ""))), 
					"cur": str(p.get("cur", "")), "price": TevWheel.as_int(str(p.get("price", ""))), "st": str(p.get("st", "")), 
					"at": now + t * 1000.0, "rd": TevWheel.as_int(str(p.get("rd", ""))), "v": TevWheel.as_int(str(p.get("v", ""))), 
					"items": items_of(str(p.get("it", ""))), 
				})
		var found: Array = kids(xml, "done")
		if not found.is_empty():
			var d: Dictionary = found[0]["at"]
			done = {"id": str(d.get("id", "")), "g": money_of(d, "g"), "c": money_of(d, "c"), "s": money_of(d, "s")}
			got_tip = str(d.get("tip", ""))
	asked = false
	if not parsed and what != "poll":
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if parsed:
		zp_visible = is_visible
		s_zp_shown = is_visible
		loaded = true
		cards = list
		if is_visible:
			zp_name = str(at.get("name", "")) if not str(at.get("name", "")).is_empty() else "Gói 0Đ"
			season = str(at.get("season", ""))
			end_at = now_ms() + TevWheel.as_number(str(at.get("left", ""))) * 1000.0
			due = TevWheel.as_int(str(at.get("due", "")))
			test = str(at.get("test", "")) == "1"
			token = str(at.get("token", ""))
			money = {"g": money_of(at, "g"), "c": money_of(at, "c"), "s": money_of(at, "s")}
			if not opened:
				show_money = money.duplicate()
		if opened:
			mark_seen()
	if opened and not zp_visible and loaded:
		close()
	elif opened:
		_rebuild()
		if done != null:
			done_fx(what, done)
	claim_key = ""
	if not got_tip.is_empty():
		tip(got_tip)
	if not notice.is_empty():
		tip(notice)



static func cur_name(cur: String) -> String:
	return "Bạc" if cur == "s" else ("Xu khóa" if cur == "c" else "Xu")

static func pack_name(card: Dictionary) -> String:
	return "Gói " + cur_name(str(card["cur"])) + " ngày " + str(card["day"])

func _have(card: Dictionary) -> int:
	return int(money.get(str(card["cur"]), -1))


func on_mua(id: String) -> void :
	var card: Variant = _keys.get(id)
	if card == null or busy() or token.is_empty():
		return
	var key: String = card_key(card)
	var have: int = _have(card)
	if have >= 0 and have < int(card["price"]):
		tip("Không đủ " + cur_name(str(card["cur"])) + ": cần " + num(int(card["price"])) + ", đang có " + num(have) + ".")
		return
	if arm_key != key or now_ms() - arm_at > MB_ARM_MS:
		arm_key = key
		arm_at = now_ms()
		_arm_id = id
		tip("Bấm MUA lần nữa để mua " + pack_name(card) + " giá " + num(int(card["price"])) + " " + cur_name(str(card["cur"])) + ".")
		return
	arm_key = ""
	arm_at = 0.0
	_arm_id = ""
	fetch("/zero-pack-buy.xml?p=" + TevWheel.uri_component(str(card["id"])) + "&k=" + TevWheel.uri_component(token) + "&r=" + str(int(now_ms())), "buy")
	_rebuild()


func on_nhan(id: String) -> void :
	var card: Variant = _keys.get(id)
	if card == null or busy() or token.is_empty():
		return
	claim_key = card_key(card)
	fetch("/zero-pack-claim.xml?k=" + TevWheel.uri_component(token) + "&p=" + TevWheel.uri_component(str(card["id"])) + "&s="
		+ TevWheel.uri_component(str(card["sn"])) + "&r=" + str(int(now_ms())), "claim")
	_rebuild()


func on_nhan_het() -> void :
	if busy() or token.is_empty() or due <= 0:
		return
	claim_key = ""
	fetch("/zero-pack-claim.xml?k=" + TevWheel.uri_component(token) + "&r=" + str(int(now_ms())), "claim")
	_rebuild()


func on_tab(d: int) -> void :
	if d < 1 or d > 7 or d == day:
		return
	day = d
	s_zp_day = d
	arm_key = ""
	arm_at = 0.0
	_rebuild()


func done_fx(what: String, done: Dictionary) -> void :
	var spot: Variant = null
	var cx: float = 0.0
	var cy: float = 0.0
	if what == "buy" and not str(done["id"]).is_empty():
		for card: Dictionary in cards:
			if str(card["id"]) == str(done["id"]) and int(card["v"]) > 0:
				spot = _at.get(card_key(card))
		if spot != null:
			cx = float(spot["x"])
			cy = float(spot["y"])
			fx_burst("fx_confetti", Vector2(cx, cy - 30.0), 3)
			for well: Array in spot["wells"]:
				fx_pop_item(int(well[2]), Vector2(float(well[0]), float(well[1])))
				fx_sparkles("fx_sparkle", Vector2(float(well[0]), float(well[1])), 2)
		say_text = "Quà đã vào túi!"
	else:
		spot = _at.get(claim_key) if not claim_key.is_empty() else null
		if spot != null:
			cx = float(spot["x"])
			cy = float(spot["y"])
		else:
			cx = ZP_ALL.x + _w("btn_nhanhet_st") / 2.0
			cy = ZP_ALL.y + _h("btn_nhanhet_st") / 2.0
		say_text = "Tiền đã về ví!"
	var k: int = 0
	for i in 3:
		var cur: String = CURS[i]
		var n: int = int(done[cur])
		if n > 0:
			fx_burst("fx_refund", Vector2(cx, cy - 20.0 * k), 3)
			float_text("+" + num(n) + " " + cur_name(cur), ZP_GOLD, Vector2(cx, cy - 40.0 - 24.0 * k))
			coins_to(cur, Vector2(cx, cy), i)
			k += 1
	cheer_at = tick + 60
	say_at = tick + 120
	_teddy_show()


func coins_to(cur: String, from: Vector2, slot: int) -> void :
	var to: Vector2 = Vector2(float(ZP_MONEY[slot * 2]) + float(ZP_MONEY_ICON[0]), float(ZP_MONEY[slot * 2 + 1]) + float(ZP_MONEY_ICON[1]))
	for i in 5:
		fx_fly("cur_" + cur + "_20", from, to, i)


func float_text(text: String, color: Color, at: Vector2) -> void :
	var fx: Dictionary = fx_add("text", "", at, {"vy": -0.9, "life": 44, "fade": 14})
	fx["text"] = text
	fx["color"] = color




func default_day() -> int:
	var due_day: int = 0
	var sale_day: int = 0
	for card: Dictionary in cards:
		if str(card["st"]) == "due" and (due_day == 0 or int(card["day"]) < due_day):
			due_day = int(card["day"])
		if str(card["st"]) == "sale" and (sale_day == 0 or int(card["day"]) < sale_day):
			sale_day = int(card["day"])
	if due_day > 0:
		return due_day
	if sale_day > 0:
		return sale_day
	return s_zp_day if s_zp_day >= 1 and s_zp_day <= 7 else 1


func day_cards(d: int) -> Array:
	var list: Array = []
	for card: Dictionary in cards:
		if int(card["day"]) == d and int(card["v"]) > 0 and list.size() < 3:
			list.append(card)
	for card: Dictionary in cards:
		if int(card["day"]) == d and int(card["v"]) <= 0 and list.size() < 3:
			list.append(card)
	return list

func ready_shown() -> bool:
	return _b_ready


static func card_x(i: int, n: int) -> float:
	var w: float = float(ZP_CARD[1])
	var gap: float = float(ZP_CARD[3])
	return float(ZP_BOARD[0]) + float(int((float(ZP_BOARD[2]) - (n * w + (n - 1) * gap)) / 2.0)) + i * (w + gap)

static func wells_of(count: int) -> Array:
	return ZP_WELLS_4 if count >= 4 else (ZP_WELLS_3 if count == 3 else (ZP_WELLS_2 if count == 2 else ZP_WELLS_1))


func _row(name: String, at: float, pre: String, post: String, over: String) -> void :
	var row: Dictionary = {"at": at, "pre": pre, "post": post, "over": over, "live": at > now_ms(), "text": ""}
	_rows[name] = row
	_row_show(row)

func _row_show(row: Dictionary) -> void :
	row["text"] = str(row["pre"]) + _left(float(row["at"])) + str(row["post"]) if float(row["at"]) > now_ms() else str(row["over"])

func _left(at: float) -> String:
	return left_text(0.0 if is_nan(at) else at, now_ms())

func _money_shown(cur: String) -> String:
	var n: int = int(show_money[cur])
	return num(n) if n >= 0 else "--"


func _rebuild() -> void :
	if not opened:
		return
	_at = {}
	_rows = {}
	_keys = {}
	_money_text = {}
	_glow_ids = []
	_glow_a = -1.0
	_arm_id = ""
	_arm_a = -1.0
	_teddy_dy = 0.0
	_info2 = ""
	_b_cards = []
	_b_busy = busy()
	_b_ready = art_pending() == 0 and art("zp_bg") != null and loaded and zp_visible
	_b_failed = art_pending() == 0 and art("zp_bg") == null
	if not _b_ready:
		return
	if day < 1 or day > 7:
		day = default_day()
	_b_cards = day_cards(day)
	_row("time", end_at, "Còn bán ", "", "Đã hết đợt bán")
	for cur: String in CURS:
		_money_text[cur] = _money_shown(cur)
	var n: int = _b_cards.size()
	for i in n:
		var card: Dictionary = _b_cards[i]
		var key: String = card_key(card)
		var x: float = card_x(i, n)
		var y: float = float(ZP_CARD[0])
		var items: Array = card["items"]
		var spots: Array = wells_of(items.size())
		var wells: Array = []
		for j in mini(items.size(), 4):
			wells.append([x + float(spots[j * 2]), y + float(spots[j * 2 + 1]), int(items[j]["id"])])
		_at[key] = {"x": x + float(ZP_CARD[1]) / 2.0, "y": y + float(ZP_CARD[2]) / 2.0, "wells": wells}
		var st: String = str(card["st"])
		if st == "sale":
			_keys["mua:" + key] = card
			if arm_key == key and now_ms() - arm_at <= MB_ARM_MS:
				_arm_id = "mua:" + key
		elif st == "due":
			_keys["nhan:" + key] = card
			if not _b_busy:
				_glow_ids.append("nhan:" + key)
		elif st == "wait" or st == "lock":
			_row("act:" + key, float(card["at"]), "", "", "Đang tới hạn..." if st == "wait" else "Đang mở bán...")
			_rows["act:" + key]["tip"] = ("Tới hạn sẽ hoàn " + num(int(card["price"])) + " " + cur_name(str(card["cur"])) + ", bấm NHẬN để lấy."
				if st == "wait" else "Gói ngày " + str(card["day"]) + " mở bán sau " + _left(float(card["at"])) + ".")
	if due > 0:
		_info2 = "Có " + str(due) + " gói tới hạn hoàn: bấm NHẬN HẾT."
		if not _b_busy:
			_glow_ids.append("all")
	else:
		var sale_at: float = 0.0
		for card: Dictionary in _b_cards:
			if str(card["st"]) == "sale" and sale_at == 0.0:
				sale_at = float(card["at"])
		if sale_at > 0.0:
			_row("info", sale_at, "Gói ngày " + str(day) + " ngưng bán sau ", ".", "Gói ngày " + str(day) + " đã ngưng bán.")
		else:
			_info2 = "Đợt thử: thời gian được rút ngắn." if test else "Mỗi ngày mở gói mới, quà càng về sau càng lớn."
	_teddy_key = "teddy_a"
	_teddy_show()


func _teddy_show() -> void :
	var key: String = "teddy_b" if cheer_at > tick else "teddy_a"
	if art(key) != null:
		_teddy_key = key


func say_line() -> String:
	if not say_text.is_empty() and say_at > tick:
		return say_text
	if due > 0:
		return "Tới hạn hoàn tiền rồi, bấm NHẬN nha!"
	return str(ZP_SAY[int(float(tick) / 150.0) % ZP_SAY.size()])




func _anim() -> void :
	if not _b_ready:
		return
	var a: float = 0.55 + 0.45 * sin(float(tick) * 0.12)
	if not _glow_ids.is_empty():
		_glow_a = 0.25 + 0.5 * a
	if not _arm_id.is_empty():
		if arm_at != 0.0 and now_ms() - arm_at <= MB_ARM_MS:
			_arm_a = 0.5 + 0.5 * a
		else:
			_arm_id = ""
			_arm_a = -1.0
			arm_key = ""
			arm_at = 0.0
	if tick % 5 == 0:
		_teddy_show()
	_teddy_dy = float(roundi(1.5 * sin(float(tick) * 0.07)))
	for cur: String in CURS:
		var s: int = int(show_money[cur])
		var m: int = int(money[cur])
		if s != m and s >= 0 and m >= 0:
			var k: int = m - s
			show_money[cur] = s + (maxi(1, int(k / 6.0)) if k > 0 else mini(-1, int(k / 6.0)))
			_money_text[cur] = _money_shown(cur)
		elif s != m:
			show_money[cur] = m
	if tick % 25 == 0:
		var over: bool = false
		for row: Dictionary in _rows.values():
			_row_show(row)
			if row["live"] and float(row["at"]) <= now_ms():
				row["live"] = false
				over = true

		if over and not asked and not loading:
			asked = true
			poll()
	if tick % 30 == 0:
		_ambient()


func _ambient() -> void :
	var spots: Array = _at.values()
	if spots.size() > 0 and randf() < 0.6:
		var spot: Dictionary = spots[randi() % spots.size()]
		fx_sparkles("fx_sparkle", Vector2(float(spot["x"]), float(spot["y"]) - 60.0), 1)
	else:
		fx_sparkles("fx_sparkle", Vector2(float(ZP_TABS[12]) + ZP_TAB_CROWN.x, float(ZP_TABS[13]) + ZP_TAB_CROWN.y), 1)




func _dbtext(at: Vector2, w: float, h: float, px: float, color: Color, glow: Color, align: String, text: String) -> float:
	var size: float = px
	while size > 7.0 and text_width(text, size) > w - 4.0:
		size -= 0.5
	return super (at, w, h, size, color, glow, align, text)

func _draw_fx(at: Vector2, layer: String) -> void :
	super (at, layer)
	for fx: Dictionary in _fx:
		if str(fx["layer"]) != layer or str(fx["kind"]) != "text":
			continue
		var alpha: float = float(fx["alpha"])
		_dbtext(at + Vector2(float(fx["x"]) - 100.0, float(fx["y"]) - 12.0), 200.0, 24.0, 16.0, Color(fx["color"], alpha), Color(ZP_INK, alpha), 
			"center", str(fx["text"]))

func _body(at: Vector2) -> void :
	if not _b_ready:
		_wait_panel(at, _b_failed)
		return
	pic("zp_bg", at)
	_chips(at)
	_tabs(at)
	if _b_cards.size() == 1:
		pic("solo_deco", at + ZP_SOLO)
	_cards(at)
	_info(at)
	var state: int = -1 if due <= 0 else (0 if _b_busy else 1)
	if state == 1 and _glow_ids.has("all") and _glow_a >= 0.0:
		pic("btn_nhanhet_glow", at + ZP_ALL - Vector2(ZP_GLOW_PAD, ZP_GLOW_PAD), _glow_a)
	art_button("all", "btn_nhanhet_st", at + ZP_ALL, state)
	if art(_teddy_key) != null:
		pic(_teddy_key, at + ZP_TEDDY + Vector2(0, _teddy_dy))
	if art("btn_close_st") != null:
		art_button("close", "btn_close_st", at + ZP_CLOSE, 1)


func _chrome(at: Vector2) -> void :
	if not _b_ready or art("btn_close_st") == null:
		_native_close(at)


func _chips(at: Vector2) -> void :
	var corner: Vector2 = at + ZP_TIME
	pic("chip_time", corner)
	_dbtext(corner + Vector2(float(ZP_TIME_TEXT[0]), float(ZP_TIME_TEXT[1])), float(ZP_TIME_TEXT[2]), float(ZP_TIME_TEXT[3]), 13.0, ZP_CREAM, ZP_INK, 
		"center", str(_rows["time"]["text"]) if _rows.has("time") else "")
	tip_area(Rect2(corner, Vector2(_w("chip_time"), _h("chip_time"))), 0, (season + ": " if not season.is_empty() else "")
		+ "hết hạn bán gói thì không mua thêm được.\nGói đã mua vẫn được hoàn đúng hạn.")
	var tips: Array = ["Bạc đang có.", "Xu khóa đang có.", "Xu đang có."]
	for i in 3:
		var cur: String = CURS[i]
		corner = at + Vector2(float(ZP_MONEY[i * 2]), float(ZP_MONEY[i * 2 + 1]))
		pic("chip_money", corner)
		pic_c("cur_" + cur + ("_20" if int(ZP_MONEY_ICON[2]) <= 24 else ""), corner + Vector2(float(ZP_MONEY_ICON[0]), float(ZP_MONEY_ICON[1])))
		_dbtext(corner + Vector2(float(ZP_MONEY_TEXT[0]), float(ZP_MONEY_TEXT[1])), float(ZP_MONEY_TEXT[2]), float(ZP_MONEY_TEXT[3]), 13.0, ZP_CREAM, ZP_INK, 
			"center", str(_money_text.get(cur, "--")))
		tip_area(Rect2(corner, Vector2(_w("chip_money"), _h("chip_money"))), 0, str(tips[i]))


func _tabs(at: Vector2) -> void :
	for d in range(1, 8):
		var corner: Vector2 = at + Vector2(float(ZP_TABS[(d - 1) * 2]), float(ZP_TABS[(d - 1) * 2 + 1]))
		var list: Array = day_cards(d)
		var sale: bool = false
		var lock: bool = list.size() > 0
		var gone: bool = list.size() > 0
		var dot: bool = false
		for card: Dictionary in list:
			var st: String = str(card["st"])
			if st == "sale":
				sale = true
			if st != "lock":
				lock = false
			if st != "exp" and st != "off":
				gone = false
			if st == "sale" or st == "due":
				dot = true
		pic("tab_sel" if d == day else ("tab_lock" if lock else ("tab_off" if gone else "tab_open")), corner)
		if art("daylabel_" + str(d)) != null:
			pic_c("daylabel_" + str(d), corner + ZP_TAB_LABEL)
		else:
			_dbtext(corner + ZP_TAB_LABEL - Vector2(50, 10), 100.0, 20.0, 13.0, ZP_CREAM, ZP_INK, "center", "NGÀY " + str(d))
		if gone and d != day:
			pic_c("tab_het", corner + ZP_TAB_HET)
		if d == 7:
			pic_c("tab_crown", corner + ZP_TAB_CROWN)
		if dot and d != day:
			pic_c("dot_red", corner + ZP_TAB_DOT)
		_hit("tab:" + str(d), Rect2((corner + Vector2(float(ZP_TAB_HIT[0]), float(ZP_TAB_HIT[1]))) * _f, 
			Vector2(float(ZP_TAB_HIT[2]), float(ZP_TAB_HIT[3])) * _f), false)


static func refund_line(card: Dictionary) -> String:
	var cash: String = num(int(card["price"])) + " " + cur_name(str(card["cur"]))
	var st: String = str(card["st"])
	if st == "done":
		return "Đã hoàn " + cash
	if st == "due":
		return "Tới hạn hoàn " + cash
	if st == "wait":
		return "Chờ hoàn " + cash
	return "Hoàn ngay " + cash if int(card["rd"]) <= 0 else "Hoàn " + cash + " sau " + str(card["rd"]) + " ngày"


func _cards(at: Vector2) -> void :
	var n: int = _b_cards.size()
	if n == 0:
		_dbtext(at + Vector2(float(ZP_BOARD[0]), float(ZP_BOARD[1]) + float(int(float(ZP_BOARD[3]) / 2.0)) - 15.0), float(ZP_BOARD[2]), 30.0, 14.0, 
			ZP_CREAM, ZP_INK, "center", "Ngày " + str(day) + " không có gói nào.")
		return
	var well_w: float = maxf(48.0, _w("well"))
	var well_h: float = maxf(48.0, _h("well"))
	for i in n:
		var card: Dictionary = _b_cards[i]
		var cur: String = str(card["cur"])
		var st: String = str(card["st"])
		var corner: Vector2 = at + Vector2(card_x(i, n), float(ZP_CARD[0]))
		pic("card_gold" if int(card["day"]) == 7 else "card", corner)
		pic_c("cur_" + cur, corner + ZP_CARD_ICON)
		if art("cardname_" + cur) != null:
			pic_c("cardname_" + cur, corner + ZP_CARD_NAME)
		else:
			_dbtext(corner + ZP_CARD_NAME - Vector2(70, 11), 140.0, 22.0, 14.0, ZP_CREAM, ZP_INK, "center", 
				"GÓI BẠC" if cur == "s" else ("GÓI XU KHÓA" if cur == "c" else "GÓI XU"))
		var items: Array = card["items"]
		var spots: Array = wells_of(items.size())
		for j in mini(items.size(), 4):
			var well: Vector2 = corner + Vector2(float(spots[j * 2]), float(spots[j * 2 + 1]))
			pic_c("well", well)
			icon(int(items[j]["id"]), float(ZP_WELL_ICON[2]), well + Vector2(float(ZP_WELL_ICON[0]), float(ZP_WELL_ICON[1])))
			_dbtext(well + Vector2(float(ZP_WELL_COUNT[0]), float(ZP_WELL_COUNT[1])), float(ZP_WELL_COUNT[2]), float(ZP_WELL_COUNT[3]), 11.0, ZP_CREAM, ZP_INK, 
				"center", "x" + num(int(items[j]["n"])))
		_dbtext(corner + Vector2(float(ZP_VALUE[0]), float(ZP_VALUE[1])), float(ZP_VALUE[2]), float(ZP_VALUE[3]), 11.0, ZP_GOLD, ZP_INK, "center", 
			"Trị giá " + num(int(card["v"])) + " Xu" if int(card["v"]) > 0 else "Gói của đợt trước")
		_dbtext(corner + Vector2(float(ZP_PRICE[0]), float(ZP_PRICE[1])), float(ZP_PRICE[2]), float(ZP_PRICE[3]), 11.0, ZP_CREAM, ZP_INK, "center", 
			refund_line(card))
		if st == "lock" or st == "exp" or st == "off":
			pic("card_dim", corner)
		var spot: Dictionary = _at.get(card_key(card), {})
		for well: Array in spot.get("wells", []):
			tip_area(Rect2(at + Vector2(float(well[0]) - well_w / 2.0, float(well[1]) - well_h / 2.0), Vector2(well_w, well_h)), int(well[2]), "")
		_action(at, card, corner + Vector2(float(ZP_ACT[0]) + float(ZP_ACT[2]) / 2.0, float(ZP_ACT[1]) + float(ZP_ACT[3]) / 2.0))


func _action(at: Vector2, card: Dictionary, centre: Vector2) -> void :
	var st: String = str(card["st"])
	var key: String = card_key(card)
	if st == "sale" or st == "due":
		var name: String = "btn_mua_st" if st == "sale" else "btn_nhan_st"
		var id: String = ("mua:" if st == "sale" else "nhan:") + key
		var corner: Vector2 = centre - Vector2(float(int(_w(name) / 2.0)), float(int(_h(name) / 2.0)))
		var state: int = 0 if _b_busy else 1
		if st == "due" and state == 1 and _glow_a >= 0.0:
			pic("btn_nhan_glow", corner - Vector2(ZP_GLOW_PAD, ZP_GLOW_PAD), _glow_a)
		if st == "sale" and _arm_id == id and _arm_a >= 0.0:
			pic("btn_mua_arm", corner - Vector2(ZP_ARM_PAD, ZP_ARM_PAD), _arm_a)
		var shown: Array = art_button(id, name, corner, state)
		if st == "sale":

			var face: Vector2 = corner + Vector2(0, 1 if int(shown[1]) == 2 else 0)
			var alpha: float = 0.75 if state == 0 else 1.0
			var coin: Texture2D = art("cur_" + str(card["cur"]) + "_20")
			if coin != null:
				pic("cur_" + str(card["cur"]) + "_20", face + ZP_MUA_ICON - Vector2(float(int(coin.get_width() / 2)), float(int(coin.get_height() / 2))), alpha)
			var have: int = _have(card)
			var ink: Color = ZP_SHORT if have >= 0 and have < int(card["price"]) else ZP_CREAM
			_dbtext(face + Vector2(float(ZP_MUA_PRICE[0]), float(ZP_MUA_PRICE[1])), float(ZP_MUA_PRICE[2]), float(ZP_MUA_PRICE[3]), 14.0, Color(ink, alpha), 
				Color(ZP_INK, alpha), "center", num(int(card["price"])))
		return
	var stamp: String = "act_wait" if st == "wait" else ("act_lock" if st == "lock" else ("act_done" if st == "done" else "act_off"))
	var corner: Vector2 = centre - Vector2(float(int(_w(stamp) / 2.0)), float(int(_h(stamp) / 2.0)))
	pic(stamp, corner)
	if (st == "wait" or st == "lock") and _rows.has("act:" + key):
		var row: Dictionary = _rows["act:" + key]
		_dbtext(corner + Vector2(float(ZP_ACT_LINE[0]), float(ZP_ACT_LINE[1])), float(ZP_ACT_LINE[2]), float(ZP_ACT_LINE[3]), 12.0, ZP_CREAM, ZP_INK, 
			"center", str(row["text"]))
		tip_area(Rect2(corner, Vector2(_w(stamp), _h(stamp))), 0, str(row.get("tip", "")))


func _info(at: Vector2) -> void :
	_dbtext(at + Vector2(float(ZP_INFO[0]), float(ZP_INFO[1])), float(ZP_INFO[2]), float(ZP_INFO[3]), 12.0, ZP_INFO_INK, ZP_INFO_GLOW, "center", 
		"Mua gói nhận quà ngay, sau đó hoàn lại đủ tiền đã trả.")
	var line: String = str(_rows["info"]["text"]) if _rows.has("info") else _info2
	_dbtext(at + Vector2(float(ZP_INFO[4]), float(ZP_INFO[5])), float(ZP_INFO[6]), float(ZP_INFO[7]), 12.0, ZP_INFO_INK, ZP_INFO_GLOW, "center", line)
