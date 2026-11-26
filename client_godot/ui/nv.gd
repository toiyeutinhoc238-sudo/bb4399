extends "tev_window.gd"





signal closed(note: String)

const NvAtlas = preload("nv_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const MB_POLL_TICKS: int = 120
const MB_ARM_MS: float = 4000.0
const NV_TIP: String = "Giáng Sinh Teddy"
const NV_ICON: String = "btn_noel"
const NV_WORD: String = "word_noel"
const NV_W: float = 960.0
const NV_H: float = 580.0
const NV_FILES: Array = ["nv_bg", "tab_normal", "tab_selected", "tabicon_lich", "tabicon_cay", "tabicon_tat", "tabicon_xuong", "tabicon_rc", 
	"tabicon_sp", "tablabel_lich", "tablabel_cay", "tablabel_tat", "tablabel_xuong", "tablabel_rc", "tablabel_sp", "chip_wallet", "chip_time", 
	"token_24", "token_16", "chau_24", "cabinet", "door_locked_r", "door_locked_g", "door_missed", "door_today", "door_open", "door_big", 
	"door_big_open", "door_check", "door_lock", "today_halo", "num_plate", "teddy_a", "teddy_b", "bubble", "streak_pole", "node_base", 
	"node_ready", "node_check", "node_lock", "plate_need", "tree_base", "tree_lit1", "tree_lit2", "tree_lit3", "tree_lit4", "tree_lit5", 
	"tree_lit6", "tree_lit7", "tree_lit8", "tree_lit9", "tree_lit10", "ladder_node", "ladder_lit", "ladder_check", "plate_prog", "box_me", 
	"badge_ok", "badge_no", "panel_rank", "medal_1", "medal_2", "medal_3", "mantel", "stocking_empty", "stocking_some", "stocking_full", 
	"row_mate", "arrow_l", "arrow_r", "plate_sent", "warm_track", "gift_pack", "card_feat", "card_good", "stamp_het", "dot_on", "dot_off", 
	"plate_ms", "garland", "garland_lit", "card_ms", "stamp_nhan", "lock_ms", "btn_close_st", "btn_nhan_st", "btn_minus_st", "btn_plus_st", 
	"btn_treo_st", "btn_gui_st", "btn_mo_st", "btn_doi_st", "btn_doi_s_st", "btn_nhanhet_st", "fx_snow", "fx_twinkle", "fx_door", "fx_bird", 
	"fx_pop", "fx_stock"]

const NV_SHEETS: Dictionary = {
	"btn_close_st": [40, 40, 1, 4], "btn_nhan_st": [84, 43, 1, 4], "btn_minus_st": [32, 38, 1, 4], "btn_plus_st": [32, 38, 1, 4], 
	"btn_treo_st": [150, 48, 1, 4], "btn_gui_st": [82, 32, 1, 4], "btn_mo_st": [150, 46, 1, 4], "btn_doi_st": [144, 52, 1, 4], 
	"btn_doi_s_st": [94, 32, 1, 4], "btn_nhanhet_st": [128, 68, 1, 4], 
	"fx_snow": [24, 24, 4, 4], "fx_twinkle": [48, 48, 8, 8], "fx_door": [128, 128, 8, 8], "fx_bird": [64, 64, 4, 4], "fx_pop": [96, 96, 8, 8], 
	"fx_stock": [160, 160, 8, 8], 
}
const NV_CREAM: Color = Color("fff7e6")
const NV_INK: Color = Color("3a0e0e")
const NV_DARK: Color = Color("4a1a12")
const NV_GOLD: Color = Color("ffd55a")
const NV_SHORT: Color = Color("ff6a5a")
const NV_RED: Color = Color("b01818")
const PN_DOT: Color = Color("e82d2a")
const NV_CLOSE: Vector2 = Vector2(907, 15)
const NV_PAGE: Array = [188, 110, 748, 446]
const NV_TABS: Array = [18, 94, 18, 174, 18, 248, 18, 322, 18, 396, 18, 470]
const NV_TAB_ICON: Array = [5, 4]
const NV_TAB_LABEL: Array = [55, 4]
const NV_TAB_DOT: Array = [142, 12]
const NV_TAB_HIT: Array = [0, 0, 156, 68]
const NV_WALLET: Array = [582, 72]
const NV_WALLET_TOKEN: Array = [5, 5]
const NV_WALLET_TEXT: Array = [35, 6, 115, 22]
const NV_TIME: Array = [748, 72]
const NV_TIME_TEXT: Array = [46, 6, 122, 23]
const NV_CABINET: Array = [194, 110]
const NV_DOORS: Array = [202, 102, 102, 86]
const NV_DOOR_NUM: Array = [37, 31, 34, 23]
const NV_DOOR_NUM_OPEN: Array = [9, 33, 25, 23]
const NV_DOOR_ITEM: Array = [64, 66, 40]
const NV_DOOR_PRICE: Array = [54, 69, 24, 18]
const NV_DOOR_TOKEN: Array = [29, 66, 24]
const NV_DOOR_HINT: Array = [31, 69, 47, 18]
const NV_TEDDY: Array = [736, 146]
const NV_BUBBLE: Array = [734, 114]
const NV_BUBBLE_TEXT: Array = [13, 8, 132, 29]
const NV_POLE: Array = [745, 337]
const NV_NODES: Array = [790, 373, 790, 450, 790, 518]
const NV_NODE_C: Array = [48, 48, 48]
const NV_NODE_PLATE: Array = [20, -20]
const NV_NODE_PLATE_TEXT: Array = [14, 5, 66, 18]
const NV_NODE_BTN: Array = [29, 0]
const NV_OPENED: Array = [745, 552, 154, 17]
const NV_TREE: Array = [190, 110]
const NV_LADDER_NODES: Array = [498, 422, 498, 354, 498, 286, 498, 218, 498, 150, 586, 422, 586, 354, 586, 286, 586, 218, 586, 150]
const NV_LADDER_C: Array = [36, 33, 40]
const NV_LADDER_TEXT: Array = [-24, 25, 48, 18]
const NV_TREE_PROG: Array = [194, 472]
const NV_TREE_PROG_TEXT: Array = [44, 23, 336, 21, 44, 46, 336, 21]
const NV_ME: Array = [620, 424]
const NV_ME_TEXT: Array = [14, 14, 151, 18, 14, 37, 151, 18]
const NV_ME_BADGE: Array = [174, 20, 181, 25, 103, 18]
const NV_QTY: Array = [678, 511, 52, 22]
const NV_QTY_BTNS: Array = [634, 504, 739, 504]
const NV_HANG_BTN: Array = [774, 488]
const NV_HANG_COST: Array = [797, 537, 112, 16, 778, 537]
const NV_RANK: Array = [630, 112]
const NV_RANK_ROWS: Array = [13, 38, 21]
const NV_RANK_MEDAL: Array = [15, 10, 18]
const NV_RANK_NAME: Array = [35, 1, 168, 18]
const NV_RANK_N: Array = [208, 1, 58, 18]
const NV_RANK_FOOT: Array = [15, 253, 267, 18, 15, 276, 267, 18]
const NV_MANTEL: Array = [194, 110]
const NV_STOCKING: Array = [302, 110]
const NV_STOCK_COUNT: Array = [349, 296, 80, 18]
const NV_FROM: Array = [227, 349, 220, 104]
const NV_OPEN_TIME: Array = [244, 488, 152, 20]
const NV_OPEN_BTN: Array = [419, 482]
const NV_MATE_ROWS: Array = [594, 147, 40, 4]
const NV_MATE_NAME: Array = [54, 6, 177, 14]
const NV_MATE_RC: Array = [54, 20, 177, 14]
const NV_MATE_BTN: Array = [240, 4]
const NV_MATE_PAGER: Array = [662, 313, 813, 313, 697, 321, 108, 18]
const NV_SENT: Array = [587, 353]
const NV_SENT_TEXT: Array = [38, 7, 262, 20]
const NV_WARM: Array = [587, 388]
const NV_WARM_NODES: Array = [640, 454, 755, 454, 870, 454]
const NV_WARM_TEXT: Array = [731, 403, 45, 18]
const NV_WARM_PLATE: Array = [-47, 29]
const NV_WARM_BTN: Array = [-42, 57]
const NV_FEAT: Array = [200, 126]
const NV_FEAT_ICON: Array = [100, 120, 100]
const NV_FEAT_NAME: Array = [34, 198, 132, 26]
const NV_FEAT_PRICE: Array = [66, 242, 92, 24, 37, 242]
const NV_FEAT_LIMIT: Array = [37, 284, 128, 22]
const NV_FEAT_BTN: Array = [27, 325]
const NV_FEAT_STAMP: Array = [49, 93]
const NV_GOODS: Array = [403, 126, 130, 195]
const NV_GOOD_ICON: Array = [62, 43, 48]
const NV_GOOD_NAME: Array = [15, 77, 94, 18]
const NV_GOOD_PRICE: Array = [41, 102, 63, 18, 20, 102]
const NV_GOOD_LIMIT: Array = [17, 128, 90, 17]
const NV_GOOD_BTN: Array = [15, 151]
const NV_GOOD_STAMP: Array = [12, 42]
const NV_PAGER: Array = [530, 515, 669, 515, 613, 533, 18]
const NV_MS_HEAD: Array = [203, 113]
const NV_MS_HEAD_TEXT: Array = [28, 75, 476, 24, 28, 109, 476, 20]
const NV_MS_GARLAND: Array = [198, 249]
const NV_MS_LIT: Array = [73, 175, 278, 378, 481, 582, 684]
const NV_MS_CARDS: Array = [206, 300, 308, 300, 411, 300, 511, 300, 614, 300, 715, 300, 817, 300]
const NV_MS_NEED: Array = [13, 39, 72, 18]
const NV_MS_ICON: Array = [49, 97, 48]
const NV_MS_COUNT: Array = [12, 138, 74, 18]
const NV_MS_BTN: Array = [7, 185]
const NV_MS_STAMP: Array = [7, 185]
const NV_MS_LOCK: Array = [34, 188]
const NV_MS_ALL: Array = [790, 156]
const NV_SNOWBIRD: Array = [919, 550]
const NV_SNOW: Array = [190, 113, 742, 438]
const NV_GLOW_PAD: float = 14.0
const NV_ARM_PAD: float = 18.0
const NV_PULSE_PAD: float = 12.0
const TAB_KEYS: Array = ["lich", "cay", "tat", "xuong", "rc", "sp"]
const TAB_TIPS: Array = ["Lịch Mùa Vọng: mỗi ngày mở một ô quà.", "Cây Thông Máy Chủ: cả máy chủ cùng treo Quả Châu.", 
	"Tất Quà Guild: gửi quà vào Tất của bạn guild.", "Xưởng Quà Ông Già Noel: đổi Kẹo lấy quà.", 
	"Nạp Giáng Sinh: quà theo tổng Xu nạp trong mùa.", "Tiêu Giáng Sinh: quà theo tổng Xu tiêu trong mùa."]

static var s_nv_shown: bool = false
static var s_nv_tab: int = 0
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 17
var nv_visible: bool = false
var loaded: bool = false
var token: String = ""
var me: Dictionary = blank_me()
var tracks: Dictionary = {}
var bt: Variant = null
var cal: Variant = null
var tree: Variant = null
var st: Variant = null
var shop: Array = []
var qty: int = 1
var candy_show: int = -1
var tab: int = 0
var page: int = 0
var arm_key: String = ""
var arm_at: float = 0.0
var re_arm: String = ""
var cheer_at: int = 0
var asked: bool = false
var open_poll: int = 0
var act_key: String = ""
var bubble_i: int = 0
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _o: Vector2 = Vector2.ZERO
var _drawing: bool = false
var _bn: float = 0.0
var _b_ready: bool = false
var _b_failed: bool = false
var _b_busy: bool = false
var _rows: Dictionary = {}
var _tip_ids: Dictionary = {}
var _at: Dictionary = {}
var _glow_a: float = -1.0
var _pulse_a: float = -1.0
var _halo_a: float = 1.0
var _arm_id: String = ""
var _arm_a: float = -1.0
var _teddy_key: String = "teddy_a"
var _teddy_dy: float = 0.0
var _bird_f: int = 0
var _bird_frame: int = 0

func _setup() -> void :
	art_dir = ""
	art_files = NV_FILES
	sheets = NV_SHEETS
	win_size = Vector2(NV_W, NV_H)
	super ()

static func blank_me() -> Dictionary:
	return {"label": "", "season": "", "earning": false, "test": false, "day": 0, "dayAt": 0.0, "endAt": 0.0, "shopAt": 0.0, "candy": -1, "candyId": 0}

static func reset_statics() -> void :
	s_nv_shown = false
	s_nv_tab = 0

func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew

func _t() -> float:
	return _bn if _drawing else now_ms()


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 17
	nv_visible = false
	loaded = false
	token = ""
	me = blank_me()
	tracks = {}
	bt = null
	cal = null
	tree = null
	st = null
	shop = []
	qty = 1
	candy_show = -1
	tab = 0
	page = 0
	arm_key = ""
	arm_at = 0.0
	re_arm = ""
	cheer_at = 0
	asked = false
	open_poll = 0
	act_key = ""
	bubble_i = 0
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(NvAtlas.FILE):
			_atlas = load(NvAtlas.FILE) as Texture2D
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
	if atlas == null or not NvAtlas.R.has(name):
		return null
	var row: Array = NvAtlas.R[name]
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
	return art(NV_ICON)

func button_word() -> Texture2D:
	return art(NV_WORD)




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/noel.xml?z=" + str(int(now_ms())), "poll")


func beat() -> void :
	if opened:
		return
	poll_in -= 1
	var day_at: float = float(me.get("dayAt", 0.0))
	if nv_visible and day_at > 0.0 and day_at <= now_ms() and not asked:
		poll_in = 0
	if poll_in <= 0:
		poll_in = 60 if nv_visible else 360
		if not loading:
			asked = true
			poll()

func button_visible() -> bool:
	return nv_visible

func button_dot() -> bool:
	return nv_visible and dots().has(true)

func busy() -> bool:
	return loading and action != "poll"


func open() -> void :
	if opened or ( not nv_visible and loaded):
		return
	tab = 0 if today_door() != null else (s_nv_tab if s_nv_tab >= 0 and s_nv_tab <= 5 else 0)
	page = 0
	arm_key = ""
	arm_at = 0.0
	re_arm = ""
	cheer_at = 0
	asked = false
	open_poll = 0
	act_key = ""
	bubble_i = 0
	candy_show = int(me.get("candy", -1))
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
	_rows = {}
	_tip_ids = {}
	_at = {}
	_arm_id = ""
	poll_in = 60 if nv_visible else 120
	closed.emit(note)

func leave() -> void :
	close()

func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id.begins_with("tab:"):
		on_tab(id.substr(4).to_int())
	elif id.begins_with("page:"):
		on_page(id.substr(5).to_int())
	elif id.begins_with("door:"):
		on_door(id.substr(5).to_int())
	elif id.begins_with("claim:"):
		var bits: PackedStringArray = id.split(":")
		if bits.size() == 3:
			on_claim(bits[1], bits[2].to_int())
	elif id == "all":
		on_all()
	elif id.begins_with("qty:"):
		on_qty(id.substr(4).to_int())
	elif id == "hang":
		on_hang()
	elif id.begins_with("mate:"):
		on_send(id.substr(5).to_int())
	elif id == "openst":
		on_open_st()
	elif id.begins_with("shop:"):
		on_buy(id.substr(5))




func act(a: String, extra: String, at_key: String = "") -> void :
	if busy() or token.is_empty():
		return
	act_key = at_key
	fetch("/noel-act.xml?a=" + a + "&k=" + TevWheel.uri_component(token) + extra + "&z=" + str(int(now_ms())), a)
	_rebuild()


func _failed(what: String) -> void :
	asked = false
	if what != "poll":
		tip("Không kết nối được máy chủ, hãy thử lại.")
	if opened:
		_rebuild()

static func _ai(at: Dictionary, key: String) -> int:
	return TevWheel.as_int(str(at.get(key, "")))

static func _an(at: Dictionary, key: String) -> float:
	return TevWheel.as_number(str(at.get(key, "")))

static func _as(at: Dictionary, key: String) -> String:
	return str(at.get(key, ""))

static func _first(node: Dictionary, tag: String) -> Variant:
	var found: Array = kids(node, tag)
	return found[0] if not found.is_empty() else null


func reward(node: Dictionary) -> Array:
	var out: Array = []
	var c: int = _ai(node["at"], "c")
	var candy_id: int = int(me.get("candyId", 0))
	if c > 0 and candy_id > 0:
		out.append({"id": candy_id, "n": c})
	out.append_array(items_of(_as(node["at"], "it")))
	return out


func parse_state(xml: Dictionary) -> Dictionary:
	var now: float = float(int(now_ms()))
	var r: Dictionary = xml["at"]
	var out: Dictionary = {"tracks": {}, "shop": []}
	out["me"] = {
		"label": _as(r, "name"), "season": _as(r, "season"), "earning": _ai(r, "earning") == 1, "test": _ai(r, "test") == 1, "day": _ai(r, "day"), 
		"dayAt": now + _an(r, "dayLeft") * 1000.0, "endAt": now + _an(r, "left") * 1000.0, "shopAt": now + _an(r, "shopLeft") * 1000.0, 
		"candy": -1 if _as(r, "candy").is_empty() else _ai(r, "candy"), "candyId": maxi(0, _ai(r, "candyId")), 
	}
	if int(me.get("candyId", 0)) == 0:
		me["candyId"] = out["me"]["candyId"]
	for key: String in ["ad", "wm", "rc", "sp"]:
		var node: Variant = _first(xml, key)
		var list: Array = []
		if node != null:
			for sub: Dictionary in kids(node, "m"):
				list.append({"need": _ai(sub["at"], "need"), "items": reward(sub), "s": _ai(sub["at"], "s")})
		out["tracks"][key] = {"total": _ai(node["at"], "total") if node != null else 0, 
			"claimable": _ai(node["at"], "claimable") if node != null else 0, "list": list}
	var b: Variant = _first(xml, "bt")
	var ba: Dictionary = b["at"] if b != null else {}
	out["bt"] = {"win": _ai(ba, "win"), "lose": _ai(ba, "lose"), "cap": _ai(ba, "cap"), "got": _ai(ba, "got"), "min": _ai(ba, "min")}
	var c: Variant = _first(xml, "cal")
	out["cal"] = {"door": 0, "make": 0, "opened": 0, "doors": []}
	if c != null:
		out["cal"]["door"] = _ai(c["at"], "door")
		out["cal"]["make"] = _ai(c["at"], "make")
		out["cal"]["opened"] = _ai(c["at"], "opened")
		for sub: Dictionary in kids(c, "d"):
			out["cal"]["doors"].append({"i": _ai(sub["at"], "i"), "items": reward(sub), "s": _ai(sub["at"], "s")})
	var t: Variant = _first(xml, "tree")
	out["tree"] = {"total": 0, "price": 1, "max": 0, "today": 0, "hung": 0, "min": 0, "ok": false, "rank": 0, "ranked": false, "rankAt": 0.0, 
		"tiers": [], "top": []}
	if t != null:
		var ta: Dictionary = t["at"]
		var tr: Dictionary = out["tree"]
		tr["total"] = _ai(ta, "total")
		tr["price"] = maxi(1, _ai(ta, "price"))
		tr["max"] = _ai(ta, "max")
		tr["today"] = _ai(ta, "today")
		tr["hung"] = _ai(ta, "hung")
		tr["min"] = _ai(ta, "min")
		tr["ok"] = _ai(ta, "ok") == 1
		tr["rank"] = _ai(ta, "rank")
		tr["ranked"] = _ai(ta, "ranked") == 1
		tr["rankAt"] = now + _an(ta, "rankLeft") * 1000.0
		for sub: Dictionary in kids(t, "t"):
			tr["tiers"].append({"i": _ai(sub["at"], "i"), "need": _ai(sub["at"], "need"), "items": reward(sub), "s": _ai(sub["at"], "s")})
		for sub: Dictionary in kids(t, "r"):
			tr["top"].append({"i": _ai(sub["at"], "i"), "id": _ai(sub["at"], "id"), "label": _as(sub["at"], "name"), "n": _ai(sub["at"], "n")})
	var s: Variant = _first(xml, "st")
	out["st"] = {"price": 1, "send": 0, "sent": 0, "max": 0, "warmth": 0, "total": 0, "unopened": 0, "open": false, "openAt": 0.0, "guild": false, 
		"mates": [], "from": []}
	if s != null:
		var sa: Dictionary = s["at"]
		var so: Dictionary = out["st"]
		so["price"] = maxi(1, _ai(sa, "price"))
		so["send"] = _ai(sa, "send")
		so["sent"] = _ai(sa, "sent")
		so["max"] = _ai(sa, "max")
		so["warmth"] = _ai(sa, "warmth")
		so["total"] = _ai(sa, "total")
		so["unopened"] = _ai(sa, "unopened")
		so["open"] = _ai(sa, "open") == 1
		so["openAt"] = now + _an(sa, "openLeft") * 1000.0
		so["guild"] = _ai(sa, "guild") == 1
		for sub: Dictionary in kids(s, "f"):
			so["mates"].append({"id": _ai(sub["at"], "id"), "label": _as(sub["at"], "name"), "rc": _ai(sub["at"], "rc"), "mine": _ai(sub["at"], "mine")})
		for sub: Dictionary in kids(s, "from"):
			so["from"].append({"id": _ai(sub["at"], "id"), "label": _as(sub["at"], "name"), "n": _ai(sub["at"], "n")})
	var g: Variant = _first(xml, "shop")
	if g != null:
		for sub: Dictionary in kids(g, "g"):
			var items: Array = items_of(_as(sub["at"], "it"))
			if not items.is_empty():
				out["shop"].append({"id": _as(sub["at"], "id"), "item": int(items[0]["id"]), "n": int(items[0]["n"]), 
					"price": maxi(1, _ai(sub["at"], "price")), "limit": _ai(sub["at"], "limit"), "per": _as(sub["at"], "per"), 
					"bought": _ai(sub["at"], "bought"), "tag": _as(sub["at"], "tag")})
	return out


func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_deep(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": [], "text": text}
	var parsed: bool = xml != null
	var notice: String = ""
	var got_tip: String = ""
	var is_visible: bool = false
	var state: Variant = null
	var done: Variant = null
	var at: Dictionary = {}
	if parsed:
		at = xml["at"]
		notice = _as(at, "notice")
		is_visible = _as(at, "visible") == "1"
		if is_visible:
			state = parse_state(xml)
		var node: Variant = _first(xml, "done")
		if node != null:
			var d: Dictionary = node["at"]
			done = {"a": _as(d, "a"), "items": items_of(_as(d, "it")), "door": _ai(d, "door"), "n": _ai(d, "n"), "to": _ai(d, "to")}
			got_tip = _as(d, "tip")
	asked = false
	if not parsed and what != "poll":
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if parsed:
		nv_visible = is_visible
		s_nv_shown = is_visible
		loaded = true
		if is_visible:
			token = _as(at, "token")
		if state != null:
			me = state["me"]
			tracks = state["tracks"]
			bt = state["bt"]
			cal = state["cal"]
			tree = state["tree"]
			st = state["st"]
			shop = state["shop"]
			if not opened or candy_show < 0:
				candy_show = int(me["candy"])
	if done != null:
		nv_after(done)
	if opened and not nv_visible and loaded:
		close()
	elif opened:
		_rebuild()
		if done != null:
			done_fx(str(done["a"]), done)
	act_key = ""
	if not got_tip.is_empty():
		tip(got_tip)
	if not notice.is_empty() and notice != got_tip:
		tip(notice)


func nv_after(done: Dictionary) -> void :
	var a: String = str(done["a"])
	if a == "hang":
		qty = 1
	if a == "buy" and not re_arm.is_empty():
		arm_key = re_arm
		arm_at = now_ms()
	re_arm = ""


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
		if not stack.is_empty() and not gap.is_empty():
			stack.back()["text"] = str(stack.back()["text"]) + unescape(gap)
		if found.get_string(2).is_empty():
			var whole: String = found.get_string(0)
			if whole.begins_with("<![CDATA[") and not stack.is_empty():
				stack.back()["text"] = str(stack.back()["text"]) + whole.substr(9, whole.length() - 12)
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
		var node: Dictionary = {"tag": name, "at": {}, "kids": [], "text": ""}
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



func have() -> int:
	return int(me.get("candy", -1))

func earning() -> bool:
	return bool(me.get("earning", false))

func track(t: String) -> Dictionary:
	return tracks.get(t, {"total": 0, "claimable": 0, "list": []})


func today_door() -> Variant:
	if cal == null:
		return null
	for d: Dictionary in cal["doors"]:
		if int(d["s"]) == 1:
			return d
	return null

func missed() -> int:
	var n: int = 0
	if cal != null:
		for d: Dictionary in cal["doors"]:
			if int(d["s"]) == 2:
				n += 1
	return n

func door_of(i: int) -> Variant:
	if cal == null:
		return null
	for d: Dictionary in cal["doors"]:
		if int(d["i"]) == i:
			return d
	return null

func mate_of(id: int) -> Variant:
	if st == null:
		return null
	for mate: Dictionary in st["mates"]:
		if int(mate["id"]) == id:
			return mate
	return null

func good_of(id: String) -> Variant:
	for g: Dictionary in shop:
		if str(g["id"]) == id:
			return g
	return null


func items_text(items: Array) -> String:
	var parts: Array = []
	for it: Dictionary in items:
		var label: String = item_name(int(it["id"])) if pack != null else ""
		parts.append((label if not label.is_empty() else "Vật phẩm") + " ×" + num(int(it["n"])))
	return ", ".join(parts)


func show_item(items: Array) -> Variant:
	var candy_id: int = int(me.get("candyId", 0))
	for it: Dictionary in items:
		if int(it["id"]) != candy_id:
			return it
	return items[0] if not items.is_empty() else null

static func good_left(g: Dictionary) -> int:
	return maxi(0, int(g["limit"]) - int(g["bought"])) if int(g["limit"]) > 0 else 99

func qty_max() -> int:
	return maxi(1, int(tree["max"]) - int(tree["today"])) if tree != null else 1


func dots() -> Array:
	var out: Array = [false, false, false, false, false, false]
	if cal == null or tree == null or st == null:
		return out
	var candy: int = have()
	var on: bool = earning()
	out[0] = today_door() != null or int(track("ad")["claimable"]) > 0
	out[1] = on and int(tree["today"]) == 0 and int(tree["max"]) > 0 and candy >= int(tree["price"])
	out[2] = (bool(st["open"]) and int(st["unopened"]) > 0) or int(track("wm")["claimable"]) > 0
	if not out[2] and on and int(st["sent"]) == 0 and candy >= int(st["price"]):
		for mate: Dictionary in st["mates"]:
			if int(mate["rc"]) < int(st["max"]):
				out[2] = true
	for g: Dictionary in shop:
		if str(g["tag"]) == "hot" and good_left(g) > 0 and candy >= int(g["price"]):
			out[3] = true
	out[4] = int(track("rc")["claimable"]) > 0
	out[5] = int(track("sp")["claimable"]) > 0
	return out


func short_left(at: float) -> String:
	var sec: int = maxi(0, ceili((at - now_ms()) / 1000.0))
	var m: int = int((sec % 3600) / 60.0)
	if sec >= 86400:
		return str(int(sec / 86400.0)) + " ngày"
	if sec >= 3600:
		return str(int(sec / 3600.0)) + "h " + str(m) + "p"
	return "%02d:%02d" % [m, sec % 60]




func armed(key: String, btn: String, msg: String) -> bool:
	if arm_key == key and now_ms() - arm_at <= MB_ARM_MS:
		arm_key = ""
		arm_at = 0.0
		_arm_id = ""
		return true
	arm_key = key
	arm_at = now_ms()
	_arm_id = btn
	tip(msg)
	return false

func arm_on(key: String) -> bool:
	return arm_key == key and now_ms() - arm_at <= MB_ARM_MS


func can_pay(n: int) -> bool:
	var h: int = have()
	if h < 0:
		tip("Hãy vào game rồi mở lại Giáng Sinh.")
		return false
	if h < n:
		tip("Không đủ Kẹo Giáng Sinh: cần " + num(n) + ", đang có " + num(h) + ".")
		return false
	return true

func on_tab(i: int) -> void :
	if i < 0 or i > 5 or i == tab:
		return
	tab = i
	s_nv_tab = i
	page = 0
	arm_key = ""
	arm_at = 0.0
	_rebuild()

func on_page(step: int) -> void :
	page = maxi(0, page + step)
	arm_key = ""
	_rebuild()

func on_door(i: int) -> void :
	var d: Variant = door_of(i)
	if d == null or busy():
		return
	var s: int = int(d["s"])
	if s == 1:
		act("door", "&d=" + str(i), "door:" + str(i))
	elif s == 2:
		if not earning():
			tip("Lịch Mùa Vọng đã khép lại.")
			return
		var make: int = int(cal["make"])
		if not can_pay(make):
			return
		if armed("door:" + str(i), "door:" + str(i), "Bấm lần nữa để bù ô " + str(i) + " với " + num(make) + " Kẹo Giáng Sinh."):
			act("door", "&d=" + str(i), "door:" + str(i))
		else:
			_rebuild()
	elif s == 0:
		tip("Ô " + str(i) + " chưa tới ngày mở." if earning() else "Lịch Mùa Vọng đã khép lại.")

func on_claim(t: String, need: int) -> void :
	act("claim", "&t=" + t + "&m=" + str(need), "ms:" + t + ":" + str(need))

func on_all() -> void :
	var t: String = "rc" if tab == 4 else "sp"
	if int(track(t)["claimable"]) <= 0:
		tip("Chưa có mốc nào để nhận.")
		return
	act("claim", "&t=" + t + "&m=all", "all")

func on_qty(step: int) -> void :
	qty = clampi(qty + step, 1, qty_max())
	arm_key = ""
	arm_at = 0.0
	_arm_id = ""
	_rebuild()

func on_hang() -> void :
	if busy() or tree == null:
		return
	if not earning():
		tip("Cây Thông đã thôi nhận Quả Châu.")
		return
	if int(tree["today"]) >= int(tree["max"]):
		tip("Hôm nay bạn đã treo đủ " + str(int(tree["max"])) + " Quả Châu.")
		return
	var cost: int = qty * int(tree["price"])
	if not can_pay(cost):
		return
	if armed("hang:" + str(qty), "hang", "Bấm TREO lần nữa: " + str(qty) + " Quả Châu, giá " + num(cost) + " Kẹo Giáng Sinh."):
		act("hang", "&n=" + str(qty), "hang")
	else:
		_rebuild()

func on_send(id: int) -> void :
	var mate: Variant = mate_of(id)
	if mate == null or busy():
		return
	if not earning():
		tip("Đã hết thời gian gửi quà.")
		return
	if int(st["sent"]) >= int(st["send"]):
		tip("Hôm nay bạn đã gửi đủ " + str(int(st["send"])) + " gói quà.")
		return
	if int(mate["rc"]) >= int(st["max"]):
		tip(str(mate["label"]) + " đã nhận đủ " + str(int(st["max"])) + " gói hôm nay.")
		return
	var price: int = int(st["price"])
	if not can_pay(price):
		return
	if armed("send:" + str(id), "mate:" + str(id), "Bấm GỬI lần nữa: 1 gói quà vào Tất của " + str(mate["label"]) + ", giá " + num(price) + " Kẹo Giáng Sinh."):
		act("send", "&o=" + str(id), "mate:" + str(id))
	else:
		_rebuild()

func on_open_st() -> void :
	if st == null:
		return
	if not bool(st["open"]):
		tip("Tất Giáng Sinh mở được sau " + left_text(float(st["openAt"]), now_ms()) + ".")
		return
	if int(st["unopened"]) <= 0:
		tip("Tất của bạn chưa có gói quà nào mới.")
		return
	act("openst", "", "stock")

func on_buy(id: String) -> void :
	var g: Variant = good_of(id)
	if g == null or busy():
		return
	if good_left(g) <= 0:
		tip("Bạn đã đổi hết lượt món này.")
		return
	var price: int = int(g["price"])
	if not can_pay(price):
		return
	var key: String = "shop:" + id
	var label: String = item_name(int(g["item"])) if pack != null else ""
	if armed(key, key, "Bấm ĐỔI lần nữa: " + (label if not label.is_empty() else "món này") + " ×" + num(int(g["n"])) + " giá " + num(price) + " Kẹo Giáng Sinh."):
		re_arm = key
		act("buy", "&g=" + TevWheel.uri_component(id) + "&n=1", key)
	else:
		_rebuild()




func done_fx(a: String, done: Dictionary) -> void :
	var c: Vector2 = _at.get(act_key, Vector2(562, 333))
	var candy: int = 0
	var candy_id: int = int(me.get("candyId", 0))
	for it: Dictionary in done["items"]:
		if int(it["id"]) == candy_id:
			candy += int(it["n"])
	var it: Variant = show_item(done["items"])
	if a == "door":
		fx_burst("fx_door", c, 3)
		fx_sparkles("fx_twinkle", c - Vector2(0, 10), 6 if int(done["door"]) >= 24 else 2)
		if int(done["door"]) >= 24:
			for k in 14:
				snow(c.x + (randf() - 0.5) * 220.0, c.y - 120.0 + randf() * 40.0)
		if it != null:
			fx_pop_item(int(it["id"]), c)
		cheer_at = tick + 60
	elif a == "claim":
		fx_burst("fx_pop", c, 3)
		fx_sparkles("fx_twinkle", c, 3)
		if it != null:
			fx_pop_item(int(it["id"]), c)
		cheer_at = tick + 60
	elif a == "hang":
		var t: Vector2 = Vector2(float(NV_TREE[0]) + _w("tree_base") / 2.0, float(NV_TREE[1]) + _h("tree_base") * 0.45)
		for j in mini(6, maxi(1, int(done["n"]))):
			fx_fly("chau_24", c, t + Vector2((randf() - 0.5) * 90.0, (randf() - 0.5) * 80.0), j)
		fx_burst("fx_pop", t, 4)
		float_text("+" + num(int(done["n"])) + " Quả Châu", NV_GOLD, NV_INK, t - Vector2(0, 60))
		if it != null:
			fx_pop_item(int(it["id"]), t)
			fx_sparkles("fx_twinkle", t, 4)
	elif a == "send":
		fx_fly("gift_pack", c, c + Vector2(40, -70), 0)
		fx_burst("fx_pop", c - Vector2(0, 20), 3)
		float_text("Độ Ấm +1", NV_GOLD, NV_INK, c - Vector2(0, 50))
	elif a == "openst":
		fx_burst("fx_stock", c, 3)
		fx_sparkles("fx_twinkle", c, 4)
		if it != null:
			fx_pop_item(int(it["id"]), c - Vector2(0, 20))
		cheer_at = tick + 60
	elif a == "buy":
		if it != null:
			fx_pop_item(int(it["id"]), c)
		fx_sparkles("fx_twinkle", c, 3)
		cheer_at = tick + 60
	if candy > 0 and a != "buy":
		float_text("+" + num(candy) + " Kẹo", NV_GOLD, NV_INK, c - Vector2(0, 64))
	_teddy_show()


func snow(x: float, y: float) -> void :
	if art("fx_snow") == null:
		return
	var vy: float = 0.45 + randf() * 0.5
	var fx: Dictionary = fx_add("sheet", "fx_snow", Vector2(x, y), {"f": int(randf() * 4.0), "tpf": 4, "loop": 1, "vx": (randf() - 0.5) * 0.4, 
		"vy": vy, "life": int(float(NV_SNOW[3]) / vy), "fade": 24, "alpha": 0.6 + randf() * 0.4})
	fx["scale"] = 0.6 + randf() * 0.4

func float_text(text: String, color: Color, glow: Color, at: Vector2) -> void :
	var fx: Dictionary = fx_add("text", "", at, {"vy": -0.9, "life": 44, "fade": 14})
	fx["text"] = text
	fx["color"] = color
	fx["glow"] = glow



func ready_shown() -> bool:
	return _b_ready


func _rebuild() -> void :
	if not opened:
		return
	_bn = now_ms()
	_rows = {}
	_tip_ids = {}
	_at = {}
	_glow_a = -1.0
	_pulse_a = -1.0
	_halo_a = 1.0
	_arm_id = ""
	_arm_a = -1.0
	_teddy_dy = 0.0
	_b_busy = busy()
	_b_ready = art_pending() == 0 and art("nv_bg") != null and loaded and nv_visible and cal != null
	_b_failed = art_pending() == 0 and art("nv_bg") == null
	if not _b_ready:
		return
	_drawing = true
	_layout()
	_drawing = false
	_teddy_key = "teddy_a"
	_teddy_show()


func _layout() -> void :
	match tab:
		0:
			for d: Dictionary in cal["doors"]:
				var k: int = int(d["i"]) - 1
				if k < 0 or k > 24:
					continue
				var x: float = float(NV_DOORS[0]) + float(k % 5) * float(NV_DOORS[2])
				var y: float = float(NV_DOORS[1]) + float(int(k / 5.0)) * float(NV_DOORS[3])
				_at["door:" + str(int(d["i"]))] = Vector2(x + float(NV_DOOR_ITEM[0]), y + float(NV_DOOR_ITEM[1]))
				if arm_on("door:" + str(int(d["i"]))):
					_arm_id = "door:" + str(int(d["i"]))
			var list: Array = track("ad")["list"]
			for k in mini(3, list.size()):
				_at["ms:ad:" + str(int(list[k]["need"]))] = Vector2(float(NV_NODES[k * 2]), float(NV_NODES[k * 2 + 1]))
		1:
			var tiers: Array = sorted_tiers()
			for k in mini(10, tiers.size()):
				if int(tiers[k]["s"]) >= 1:
					_at["tier:" + str(k)] = Vector2(float(NV_LADDER_NODES[k * 2]), float(NV_LADDER_NODES[k * 2 + 1]))
			qty = maxi(1, mini(qty_max(), qty))
			_at["hang"] = Vector2(float(NV_HANG_BTN[0]) + float(int(_w("btn_treo_st") / 2.0)), float(NV_HANG_BTN[1]))
			if arm_on("hang:" + str(qty)):
				_arm_id = "hang"
		2:
			_at["stock"] = Vector2(float(NV_STOCKING[0]) + float(int(_w("stocking_empty") / 2.0)), float(NV_STOCKING[1]) + float(int(_h("stocking_empty") / 2.0)))
			var list: Array = st["mates"]
			var per: int = int(NV_MATE_ROWS[3])
			var pages: int = maxi(1, ceili(float(list.size()) / float(per)))
			page = mini(page, pages - 1)
			if bool(st["guild"]):
				for i in range(page * per, mini(list.size(), (page + 1) * per)):
					var y: float = float(NV_MATE_ROWS[1]) + float(i - page * per) * float(NV_MATE_ROWS[2])
					var id: String = str(int(list[i]["id"]))
					_at["mate:" + id] = Vector2(float(NV_MATE_ROWS[0]) + float(NV_MATE_BTN[0]) + float(int(_w("btn_gui_st") / 2.0)), y + float(NV_MATE_BTN[1]))
					if arm_on("send:" + id):
						_arm_id = "mate:" + id
			var wl: Array = track("wm")["list"]
			for k in mini(3, wl.size()):
				_at["ms:wm:" + str(int(wl[k]["need"]))] = Vector2(float(NV_WARM_NODES[k * 2]), float(NV_WARM_NODES[k * 2 + 1]))
		3:
			if shop.is_empty():
				return
			var split: Array = shop_split()
			var feat: Dictionary = split[0]
			_at["shop:" + str(feat["id"])] = Vector2(float(NV_FEAT[0]) + float(NV_FEAT_ICON[0]), float(NV_FEAT[1]) + float(NV_FEAT_ICON[1]))
			if arm_on("shop:" + str(feat["id"])):
				_arm_id = "shop:" + str(feat["id"])
			var goods: Array = split[1]
			var pages: int = maxi(1, ceili(float(goods.size()) / 8.0))
			page = mini(page, pages - 1)
			for i in range(page * 8, mini(goods.size(), (page + 1) * 8)):
				var k: int = i - page * 8
				var corner: Vector2 = good_corner(k)
				var id: String = str(goods[i]["id"])
				_at["shop:" + id] = corner + Vector2(float(NV_GOOD_ICON[0]), float(NV_GOOD_ICON[1]))
				if arm_on("shop:" + id):
					_arm_id = "shop:" + id
		_:
			var t: String = "rc" if tab == 4 else "sp"
			var list: Array = track(t)["list"]
			var start: int = ms_start(list)
			for k in mini(7, list.size() - start):
				var m: Dictionary = list[start + k]
				_at["ms:" + t + ":" + str(int(m["need"]))] = Vector2(float(NV_MS_CARDS[k * 2]) + float(NV_MS_ICON[0]), float(NV_MS_CARDS[k * 2 + 1]) + float(NV_MS_ICON[1]))
			_at["all"] = Vector2(float(NV_MS_ALL[0]) + float(int(_w("btn_nhanhet_st") / 2.0)), float(NV_MS_ALL[1]))

func sorted_tiers() -> Array:
	var tiers: Array = (tree["tiers"] as Array).duplicate() if tree != null else []
	tiers.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a["i"]) < int(b["i"]))
	return tiers


func shop_split() -> Array:
	var feat: Dictionary = shop[0]
	for g: Dictionary in shop:
		if str(g["tag"]) == "hot":
			feat = g
			break
	var rest: Array = []
	for g: Dictionary in shop:
		if g != feat:
			rest.append(g)
	return [feat, rest]

static func good_corner(k: int) -> Vector2:
	return Vector2(float(NV_GOODS[0]) + float(k % 4) * float(NV_GOODS[2]), float(NV_GOODS[1]) + float(int(k / 4.0)) * float(NV_GOODS[3]))


static func ms_start(list: Array) -> int:
	var start: int = list.size()
	for k in list.size():
		if int(list[k]["s"]) != 2:
			start = k
			break
	return maxi(0, mini(start, list.size() - 7))

func _teddy_show() -> void :
	var key: String = "teddy_b" if cheer_at > tick else "teddy_a"
	if art(key) != null:
		_teddy_key = key

func _row_text(name: String, at: float, pre: String, post: String, over: String, fmt: int = 0) -> String:
	if not _rows.has(name):
		var row: Dictionary = {"at": at, "pre": pre, "post": post, "over": over, "fmt": fmt, "live": at > now_ms(), "text": ""}
		_rows[name] = row
		_row_show(row)
	return str(_rows[name]["text"])

func _row_show(row: Dictionary) -> void :
	var at: float = float(row["at"])
	if at > now_ms():
		row["text"] = str(row["pre"]) + (short_left(at) if int(row["fmt"]) == 1 else left_text(at, now_ms())) + str(row["post"])
	else:
		row["text"] = str(row["over"])


func bubble_lines() -> Array:
	if not earning():
		return ["Lịch Mùa Vọng đã khép.\nXưởng Quà vẫn mở đổi Kẹo."]
	var lines: Array = []
	if today_door() != null:
		lines.append("Ô hôm nay sẵn sàng rồi!\nBấm ô sáng để mở quà nhé.")
	if int(track("ad")["claimable"]) > 0:
		lines.append("Đủ mốc chuỗi rồi,\nbấm NHẬN ở cột kẹo!")
	var lost: int = missed()
	if lost > 0:
		lines.append("Lỡ " + str(lost) + " ô? Bù được bằng\n" + num(int(cal["make"])) + " Kẹo mỗi ô.")
	lines.append("Đánh trận để kiếm Kẹo:\nthắng +" + str(int(bt["win"]) if bt != null else 3) + ", thua +" + str(int(bt["lose"]) if bt != null else 1) + ".")
	lines.append("Cùng cả máy chủ treo\nQuả Châu lên Cây Thông!")
	lines.append("Gửi quà vào Tất của\nbạn guild nhé!")
	return lines




func _anim() -> void :
	if not _b_ready:
		return
	var a: float = 0.55 + 0.45 * sin(float(tick) * 0.12)
	_glow_a = 0.25 + 0.5 * a
	_pulse_a = 0.3 + 0.5 * a
	_halo_a = 0.35 + 0.65 * a
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
	var target: int = have()
	if candy_show != target and candy_show >= 0 and target >= 0:
		var k: int = target - candy_show
		candy_show += maxi(1, int(k / 6.0)) if k > 0 else mini(-1, int(k / 6.0))
	elif candy_show != target:
		candy_show = target
	if _bird_f <= 0 and tick % 120 == 0 and randf() < 0.6:
		_bird_f = 8
	if _bird_f > 0 and tick % 3 == 0:
		_bird_f -= 1
		_bird_frame = (8 - _bird_f) % 4 if _bird_f > 0 else 0
	if tick % 10 == 0:
		snow(float(NV_SNOW[0]) + randf() * float(NV_SNOW[2]), float(NV_SNOW[1]))
	if tick % 100 == 0:
		bubble_i += 1
	if tick % 25 == 0:
		var over: bool = false
		for row: Dictionary in _rows.values():
			_row_show(row)
			if row["live"] and float(row["at"]) <= now_ms():
				row["live"] = false
				over = true
		var day_at: float = float(me.get("dayAt", 0.0))
		if day_at > 0.0 and day_at <= now_ms():
			over = true
		open_poll += 1
		if over and not asked and not loading:
			asked = true
			open_poll = 0
			poll()
		elif open_poll >= 30 and not loading:
			open_poll = 0
			poll()
	if tick % 30 == 0:
		_ambient()


func _ambient() -> void :
	if randf() < 0.3:
		return
	var spot: Variant = null
	if tab == 0:
		var d: Variant = today_door()
		if d != null:
			spot = _at.get("door:" + str(int(d["i"])))
	elif tab == 1:
		var lit: Array = []
		for key: String in _at.keys():
			if key.begins_with("tier:"):
				lit.append(_at[key])
		if not lit.is_empty():
			spot = lit[randi() % lit.size()]
	elif tab == 2 and st != null and int(st["unopened"]) > 0:
		spot = _at.get("stock")
	if spot != null:
		fx_sparkles("fx_twinkle", (spot as Vector2) - Vector2(0, 10), 1)




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
		_dbtext(at + Vector2(float(fx["x"]) - 100.0, float(fx["y"]) - 12.0), 200.0, 24.0, 16.0, Color(fx["color"], alpha), Color(fx.get("glow", NV_INK), alpha), 
			"center", str(fx["text"]))

func _draw_tips() -> void :
	var keep: String = _hover
	if _tip_ids.has(_hover):
		_hover = "panel"
	super ()
	_hover = keep


func _nv_text(x: float, y: float, w: float, h: float, px: float, text: String, align: String = "center") -> void :
	_dbtext(_o + Vector2(x, y), w, h, px, NV_CREAM, NV_INK, align, text)


func _rect(arr: Array, idx: int, ox: float, oy: float, px: float, color: Color, text: String, align: String = "center") -> void :
	_dbtext(_o + Vector2(ox + float(arr[idx]), oy + float(arr[idx + 1])), float(arr[idx + 2]), float(arr[idx + 3]), px, color, NV_INK, align, text)


func _dk(arr: Array, idx: int, ox: float, oy: float, px: float, color: Color, text: String, align: String = "center") -> void :
	_dbtext(_o + Vector2(ox + float(arr[idx]), oy + float(arr[idx + 1])), float(arr[idx + 2]), float(arr[idx + 3]), px, color, NONE, align, text)


func _dk_fit(arr: Array, idx: int, ox: float, oy: float, px: int, color: Color, text: String, align: String = "center") -> void :
	var fs: int = px
	while text_width(text, float(fs)) > float(arr[idx + 2]) - 4.0 and fs > 9:
		fs -= 1
	_dk(arr, idx, ox, oy, float(fs), color, text, align)


func _ink(arr: Array, idx: int, ox: float, oy: float, px: float, text: String) -> void :
	_dk(arr, idx, ox, oy, px, NV_DARK, text)

func plain_width(text: String, px: float) -> float:
	return ARIAL.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f


func _plain(x: float, y: float, w: float, h: float, px: float, color: Color, align: String, text: String, wrap: bool) -> void :
	var size: float = px
	var lines: Array = [text]
	if wrap:
		lines = _plain_wrap(text, w, size)
		while size > 7.0 and (_block_h(lines.size(), size) - 6.0 > h or _plain_widest(lines, size) > w - 4.0):
			size -= 0.5
			lines = _plain_wrap(text, w, size)
	else:
		while size > 7.0 and plain_width(text, size) > w - 4.0:
			size -= 0.5
	var high: float = _block_h(lines.size(), size) if wrap else size + 8.0
	var top: float = y + float(int((h - high) / 2.0))
	var step: float = roundf(size * 1.15) - 1.0
	var lx: float = x + (2.0 if align == "left" else (-2.0 if align == "right" else 0.0))
	for i in lines.size():
		_fwords(str(lines[i]), ARIAL, size, color, align.substr(0, 1), _o + Vector2(lx, top + float(i) * step), w, 0.0, 0.0, false)

func _plain_widest(lines: Array, px: float) -> float:
	var wide: float = 0.0
	for line: String in lines:
		wide = maxf(wide, plain_width(line, px))
	return wide

func _plain_wrap(text: String, w: float, px: float) -> Array:
	var lines: Array = []
	for chunk: String in text.split("\n"):
		var line: String = ""
		for word: String in chunk.split(" "):
			var next: String = word if line.is_empty() else line + " " + word
			if not line.is_empty() and plain_width(next, px) > w - 4.0:
				lines.append(line)
				line = word
			else:
				line = next
		lines.append(line)
	return lines

static func _block_h(count: int, px: float) -> float:
	return (roundf(px * 1.15) - 1.0) * float(count) + 1.0 + 6.0


func _count(n: int, cx: float, cy: float, s: float) -> void :
	if n > 1:
		_dbtext(_o + Vector2(cx - 6.0, cy + float(int(s / 2.0)) - 16.0), float(int(s / 2.0)) + 12.0, 16.0, 11.0, NV_CREAM, NV_INK, "right", "×" + num(n))


func _prize(items: Array, cx: float, cy: float, s: float, with_tip: bool) -> void :
	var it: Variant = show_item(items)
	if it == null:
		return
	icon(int(it["id"]), s, _o + Vector2(cx, cy))
	_count(int(it["n"]), cx, cy, s)
	if with_tip:
		tip_area(Rect2(_o + Vector2(cx - s / 2.0, cy - s / 2.0), Vector2(s, s)), int(it["id"]), "")

func _note(text: String) -> void :
	_nv_text(float(NV_PAGE[0]), float(NV_PAGE[1]) + float(int(float(NV_PAGE[3]) / 2.0)) - 15.0, float(NV_PAGE[2]), 30.0, 14.0, text)

func _tipr(x: float, y: float, w: float, h: float, text: String) -> void :
	tip_area(Rect2(_o + Vector2(x, y), Vector2(w, h)), 0, text)

func _click(id: String, x: float, y: float, w: float, h: float, text: String = "") -> void :
	_hit(id, Rect2((_o + Vector2(x, y)) * _f, Vector2(w, h) * _f), false)
	if not text.is_empty():
		_tipr(x, y, w, h, text)
		_tip_ids[id] = true


func _btn(id: String, name: String, x: float, y: float, live: bool, glow: String = "", arm: String = "") -> Array:
	var state: int = (0 if _b_busy else 1) if live else -1
	var corner: Vector2 = _o + Vector2(x, y)
	var arming: bool = _arm_id == id and _arm_a >= 0.0
	if not glow.is_empty() and state == 1 and _glow_a >= 0.0 and not arming:
		pic(glow, corner - Vector2(NV_GLOW_PAD, NV_GLOW_PAD), _glow_a)
	if not arm.is_empty() and arming:
		pic(arm, corner - Vector2(NV_ARM_PAD, NV_ARM_PAD), _arm_a)
	var shown: Array = art_button(id, name, corner, state)
	shown.append(state)
	return shown

func _pic_at(name: String, x: float, y: float, alpha: float = 1.0) -> void :
	pic(name, _o + Vector2(x, y), alpha)

func _pic_c(name: String, x: float, y: float, alpha: float = 1.0) -> void :
	pic_c(name, _o + Vector2(x, y), alpha)


func _dot(centre: Vector2) -> void :
	draw_circle(centre * _f, 5.5 * _f, PN_DOT)
	draw_arc(centre * _f, 5.5 * _f, 0.0, TAU, 24, Color.WHITE, 1.5 * _f, true)



func _body(at: Vector2) -> void :
	_o = at
	_tip_ids = {}
	if not _b_ready:
		_wait_panel(at, _b_failed)
		return
	_drawing = true
	pic("nv_bg", at)
	_tabs()
	_chips()
	match tab:
		0:
			_lich()
		1:
			_cay()
		2:
			_tat()
		3:
			_xuong()
		4:
			_ms("rc")
		_:
			_ms("sp")
	if art("fx_bird") != null:
		sheet("fx_bird", _bird_frame, _o + Vector2(float(NV_SNOWBIRD[0]) - 32.0, float(NV_SNOWBIRD[1]) - 64.0))
	_close_btn()
	_drawing = false

func _close_btn() -> void :
	if art("btn_close_st") != null:
		art_button("close", "btn_close_st", _o + NV_CLOSE, 1)

func _chrome(at: Vector2) -> void :
	if not _b_ready or art("btn_close_st") == null:
		_native_close(at)

func _tabs() -> void :
	var on: Array = dots()
	for i in 6:
		var x: float = float(NV_TABS[i * 2])
		var y: float = float(NV_TABS[i * 2 + 1])
		var key: String = TAB_KEYS[i]
		_pic_at("tab_selected" if i == tab else "tab_normal", x, y)
		_pic_at("tabicon_" + key, x + float(NV_TAB_ICON[0]), y + float(NV_TAB_ICON[1]))
		_pic_at("tablabel_" + key, x + float(NV_TAB_LABEL[0]), y + float(NV_TAB_LABEL[1]))
		if on[i] and i != tab:
			_dot(_o + Vector2(x + float(NV_TAB_DOT[0]), y + float(NV_TAB_DOT[1])))
		if i != tab:
			_click("tab:" + str(i), x + float(NV_TAB_HIT[0]), y + float(NV_TAB_HIT[1]), float(NV_TAB_HIT[2]), float(NV_TAB_HIT[3]), TAB_TIPS[i])
		else:
			_tipr(x + float(NV_TAB_HIT[0]), y + float(NV_TAB_HIT[1]), float(NV_TAB_HIT[2]), float(NV_TAB_HIT[3]), TAB_TIPS[i])

func _chips() -> void :
	var x: float = float(NV_WALLET[0])
	var y: float = float(NV_WALLET[1])
	_pic_at("chip_wallet", x, y)
	_pic_at("token_24", x + float(NV_WALLET_TOKEN[0]), y + float(NV_WALLET_TOKEN[1]))
	_rect(NV_WALLET_TEXT, 0, x, y, 14.0, NV_CREAM, num(candy_show) if candy_show >= 0 else "--")
	var h: int = have()
	var text: String = "Kẹo Giáng Sinh trong túi: " + (num(h) if h >= 0 else "--") + "."
	if bt != null:
		text += "\nĐánh trận PvP / PvE dài từ " + str(int(bt["min"])) + " giây: thắng +" + str(int(bt["win"])) + ", thua +" + str(int(bt["lose"])) + " Kẹo.\nHôm nay từ trận: " + str(int(bt["got"])) + "/" + str(int(bt["cap"])) + " Kẹo."
	text += "\nKẹo còn đến từ Lịch Mùa Vọng, quà Cây Thông và mốc Nạp / Tiêu."
	_tipr(x, y, maxf(60.0, _w("chip_wallet")), maxf(24.0, _h("chip_wallet")), text)
	x = float(NV_TIME[0])
	y = float(NV_TIME[1])
	_pic_at("chip_time", x, y)
	var end_at: float = float(me.get("endAt", 0.0))
	var shop_at: float = float(me.get("shopAt", 0.0))
	if earning():
		_rect(NV_TIME_TEXT, 0, x, y, 13.0, NV_CREAM, _row_text("time", end_at, "", "", "Đã kết thúc", 1))
		text = "Sự kiện kết thúc sau " + left_text(end_at, _t()) + ".\nXưởng Quà mở thêm tới " + left_text(shop_at, _t()) + " nữa để đổi nốt Kẹo."
	else:
		_rect(NV_TIME_TEXT, 0, x, y, 13.0, NV_CREAM, _row_text("time", shop_at, "Xưởng ", "", "Đã đóng", 1))
		text = "Sự kiện đã kết thúc, chỉ còn Xưởng Quà.\nXưởng đóng sau " + left_text(shop_at, _t()) + ", Kẹo còn lại hết hạn."
	_tipr(x, y, maxf(60.0, _w("chip_time")), maxf(24.0, _h("chip_time")), text)


static func door_art(d: Dictionary, k: int) -> String:
	var s: int = int(d["s"])
	var big: bool = int(d["i"]) >= 24
	if s == 3:
		return "door_big_open" if big else "door_open"
	if big:
		return "door_big"
	if s == 1:
		return "door_today"
	if s == 2:
		return "door_missed"
	return "door_locked_r" if (k % 5 + int(k / 5.0)) % 2 == 0 else "door_locked_g"


func _lich() -> void :
	var make: int = int(cal["make"])
	var on: bool = earning()
	var ics: float = float(NV_DOOR_ITEM[2])
	_pic_at("cabinet", float(NV_CABINET[0]), float(NV_CABINET[1]))
	for d: Dictionary in cal["doors"]:
		var i: int = int(d["i"])
		var k: int = i - 1
		if k < 0 or k > 24:
			continue
		var s: int = int(d["s"])
		var x: float = float(NV_DOORS[0]) + float(k % 5) * float(NV_DOORS[2])
		var y: float = float(NV_DOORS[1]) + float(int(k / 5.0)) * float(NV_DOORS[3])
		var name: String = door_art(d, k)
		var big: bool = i >= 24
		var id: String = "door:" + str(i)
		var shown: String = items_text(d["items"])
		var text: String = ""
		if s == 1 and _pulse_a >= 0.0 and _arm_id != id:
			_pic_at("door_big_pulse" if big else "door_today_pulse", x - NV_PULSE_PAD, y - NV_PULSE_PAD, _pulse_a)
		if _arm_id == id and _arm_a >= 0.0:
			_pic_at("door_big_arm" if big else "door_missed_arm", x - NV_ARM_PAD, y - NV_ARM_PAD, _arm_a)
		_pic_at(name, x, y)
		if s == 3:
			_prize(d["items"], x + float(NV_DOOR_ITEM[0]), y + float(NV_DOOR_ITEM[1]), ics, false)
			_rect(NV_DOOR_NUM_OPEN, 0, x, y, 15.0, NV_CREAM, str(i))
			_pic_at("door_check", x, y)
			text = "Ô " + str(i) + " đã mở: " + shown + "."
		else:
			_pic_at("num_plate", x, y)
			_rect(NV_DOOR_NUM, 0, x, y, 15.0, NV_CREAM, str(i))
			if s == 1:
				_pic_at("today_halo", x, y, _halo_a)
				_ink(NV_DOOR_HINT, 0, x, y, 12.0, "MỞ")
				text = "Ô hôm nay: bấm để mở miễn phí.\nQuà: " + shown + "."
			elif s == 2:
				_pic_at("token_16" if int(NV_DOOR_TOKEN[2]) <= 16 else "token_24", x + float(NV_DOOR_TOKEN[0]), y + float(NV_DOOR_TOKEN[1]))
				var h: int = have()
				_rect(NV_DOOR_PRICE, 0, x, y, 12.0, NV_SHORT if h >= 0 and h < make else NV_CREAM, num(make))
				text = "Ô " + str(i) + " bị lỡ: bù với " + num(make) + " Kẹo Giáng Sinh (bấm 2 lần).\nQuà: " + shown + "."
			else:
				_pic_at("door_lock", x, y)
				text = ("Ô " + str(i) + " chưa tới ngày mở." if on else "Lịch Mùa Vọng đã khép lại.") + "\nQuà: " + shown + "."
		var cw: float = maxf(40.0, _w(name))
		var ch: float = maxf(40.0, _h(name))
		if s != 3:
			_click(id, x, y, cw, ch, text)
		else:
			_tipr(x, y, cw, ch, text)
			var it: Variant = show_item(d["items"])
			if it != null:
				tip_area(Rect2(_o + Vector2(x + float(NV_DOOR_ITEM[0]) - ics / 2.0, y + float(NV_DOOR_ITEM[1]) - ics / 2.0), Vector2(ics, ics)), int(it["id"]), "")
	_pic_at(_teddy_key, float(NV_TEDDY[0]), float(NV_TEDDY[1]) + _teddy_dy)
	_pic_at("bubble", float(NV_BUBBLE[0]), float(NV_BUBBLE[1]))
	var lines: Array = bubble_lines()
	_plain(float(NV_BUBBLE[0]) + float(NV_BUBBLE_TEXT[0]), float(NV_BUBBLE[1]) + float(NV_BUBBLE_TEXT[1]), float(NV_BUBBLE_TEXT[2]), float(NV_BUBBLE_TEXT[3]), 
		12.0, NV_DARK, "center", str(lines[bubble_i % lines.size()]), true)
	_pic_at("streak_pole", float(NV_POLE[0]), float(NV_POLE[1]))
	var list: Array = track("ad")["list"]
	for k in mini(3, list.size()):
		var need: int = int(list[k]["need"])
		_node("ad", list[k], float(NV_NODES[k * 2]), float(NV_NODES[k * 2 + 1]), NV_NODE_PLATE, NV_NODE_BTN, str(need) + " ô", "Mở đủ " + str(need) + " ô Lịch")
	_rect(NV_OPENED, 0, 0, 0, 12.0, NV_CREAM, "Đã mở " + str(int(cal["opened"])) + "/25 ô")


func _node(t: String, m: Dictionary, cx: float, cy: float, plate: Array, btn: Array, label: String, what: String) -> void :
	var s: int = int(m["s"])
	var ox: float = cx - float(NV_NODE_C[0])
	var oy: float = cy - float(NV_NODE_C[1])
	var ics: float = float(NV_NODE_C[2])
	if s == 1:
		_pic_at("node_ready", ox, oy, _halo_a)
	_pic_at("node_base", ox, oy)
	_prize(m["items"], cx, cy, ics, false)
	if s == 2:
		_pic_at("node_check", ox, oy)
	elif s == 0:
		_pic_at("node_lock", ox, oy)
	var px: float = cx + float(plate[0])
	var py: float = cy + float(plate[1])
	_pic_at("plate_need", px, py)
	_ink(NV_NODE_PLATE_TEXT, 0, px, py, 12.0, label)
	_tipr(cx - ics / 2.0, cy - ics / 2.0, ics, ics, what + ": " + items_text(m["items"]) + "." + ("\nĐã nhận." if s == 2 else ("\nBấm NHẬN để lấy quà." if s == 1 else "\nChưa đạt.")))
	if s == 1:
		_btn("claim:" + t + ":" + str(int(m["need"])), "btn_nhan_st", cx + float(btn[0]), cy + float(btn[1]), true, "btn_nhan_glow")


func _cay() -> void :
	var t: Dictionary = tree
	var tiers: Array = sorted_tiers()
	var lit: int = 0
	var next: Variant = null
	_pic_at("tree_base", float(NV_TREE[0]), float(NV_TREE[1]))
	for tier: Dictionary in tiers:
		if int(tier["s"]) >= 1:
			_pic_at("tree_lit" + str(int(tier["i"])), float(NV_TREE[0]), float(NV_TREE[1]))
			lit += 1
		elif next == null:
			next = tier
	_tipr(float(NV_TREE[0]), float(NV_TREE[1]), maxf(40.0, _w("tree_base")), maxf(40.0, _h("tree_base")), 
		"Cây Thông chung của cả máy chủ: " + str(lit) + "/10 tầng đã sáng.\nMỗi tầng sáng, ai đã treo từ " + str(int(t["min"])) + " Quả Châu nhận quà tầng qua thư.")
	var ics: float = float(NV_LADDER_C[2])
	for k in mini(10, tiers.size()):
		var tier: Dictionary = tiers[k]
		var s: int = int(tier["s"])
		var cx: float = float(NV_LADDER_NODES[k * 2])
		var cy: float = float(NV_LADDER_NODES[k * 2 + 1])
		_pic_at("ladder_lit" if s >= 1 else "ladder_node", cx - float(NV_LADDER_C[0]), cy - float(NV_LADDER_C[1]))
		_prize(tier["items"], cx, cy, ics, false)
		if s == 2:
			_pic_at("ladder_check", cx - float(NV_LADDER_C[0]), cy - float(NV_LADDER_C[1]))
		_rect(NV_LADDER_TEXT, 0, cx, cy, 12.0, NV_GOLD if s >= 1 else NV_CREAM, num(int(tier["need"])))
		_tipr(cx - ics / 2.0, cy - ics / 2.0, ics, ics, "Tầng " + str(int(tier["i"])) + ": sáng khi cả máy chủ treo đủ " + num(int(tier["need"])) + " Quả Châu.\nQuà: "
			+ items_text(tier["items"]) + "." + ("\nBạn đã nhận quà tầng này." if s == 2 else ("\nĐã sáng: treo đủ " + str(int(t["min"])) + " Quả Châu để nhận." if s == 1 else "")))
	var x: float = float(NV_TREE_PROG[0])
	var y: float = float(NV_TREE_PROG[1])
	_pic_at("plate_prog", x, y)
	_dk(NV_TREE_PROG_TEXT, 0, x, y, 13.0, NV_DARK, "Cả máy chủ: " + num(int(t["total"])) + " Quả Châu")
	_dk(NV_TREE_PROG_TEXT, 4, x, y, 13.0, NV_RED, "Tầng " + str(int(next["i"])) + " sáng khi đủ " + num(int(next["need"])) if next != null else "Cây đã sáng trọn 10 tầng!")
	x = float(NV_ME[0])
	y = float(NV_ME[1])
	_pic_at("box_me", x, y)
	_dk(NV_ME_TEXT, 0, x, y, 12.0, NV_DARK, "Đã treo " + num(int(t["hung"])), "left")
	_dk(NV_ME_TEXT, 4, x, y, 12.0, NV_DARK, "Hôm nay " + str(int(t["today"])) + "/" + str(int(t["max"])), "left")
	var ok: bool = bool(t["ok"])
	_pic_at("badge_ok" if ok else "badge_no", x + float(NV_ME_BADGE[0]), y + float(NV_ME_BADGE[1]))
	_rect(NV_ME_BADGE, 2, x, y, 11.0, NV_CREAM, "ĐỦ ĐIỀU KIỆN" if ok else "CẦN ≥ " + str(int(t["min"])))
	_tipr(x + float(NV_ME_BADGE[0]), y + float(NV_ME_BADGE[1]), maxf(40.0, _w("badge_ok")), maxf(16.0, _h("badge_ok")), 
		"Bạn đã treo từ " + str(int(t["min"])) + " Quả Châu: mỗi tầng sáng đều có quà qua thư." if ok
		else "Treo từ " + str(int(t["min"])) + " Quả Châu trong mùa để nhận quà các tầng (tầng đã sáng được bù khi bạn đủ).")
	var cost: int = qty * int(t["price"])
	var can_hang: bool = earning() and int(t["today"]) < int(t["max"])
	var h: int = have()
	_dk(NV_QTY, 0, 0, 0, 16.0, NV_DARK, str(qty))
	_btn("qty:-1", "btn_minus_st", float(NV_QTY_BTNS[0]), float(NV_QTY_BTNS[1]), can_hang and qty > 1)
	_btn("qty:1", "btn_plus_st", float(NV_QTY_BTNS[2]), float(NV_QTY_BTNS[3]), can_hang and qty < qty_max())
	if not can_hang:
		_tipr(float(NV_HANG_BTN[0]), float(NV_HANG_BTN[1]), maxf(40.0, _w("btn_treo_st")), maxf(24.0, _h("btn_treo_st")), 
			"Hôm nay bạn đã treo đủ " + str(int(t["max"])) + " Quả Châu, mai quay lại nhé." if earning() else "Cây Thông đã thôi nhận Quả Châu.")
	_btn("hang", "btn_treo_st", float(NV_HANG_BTN[0]), float(NV_HANG_BTN[1]), can_hang, "btn_treo_glow" if h >= cost else "", "btn_treo_arm")
	_rect(NV_HANG_COST, 0, 0, 0, 13.0, NV_SHORT if h >= 0 and h < cost else NV_CREAM, num(cost), "right")
	_pic_at("token_16", float(NV_HANG_COST[4]), float(NV_HANG_COST[5]))
	_tipr(float(NV_HANG_COST[0]), float(NV_HANG_COST[1]), float(NV_HANG_COST[2]) + 20.0, float(NV_HANG_COST[3]), 
		"1 Quả Châu = " + str(int(t["price"])) + " Kẹo Giáng Sinh, tối đa " + str(int(t["max"])) + " quả mỗi ngày.")
	_rank()


func _rank() -> void :
	var t: Dictionary = tree
	var x: float = float(NV_RANK[0])
	var y: float = float(NV_RANK[1])
	_pic_at("panel_rank", x, y)
	var top: Array = t["top"]
	var rx: float = x + float(NV_RANK_ROWS[0])
	var ry: float = y + float(NV_RANK_ROWS[1])
	var step: float = float(NV_RANK_ROWS[2])
	if top.is_empty():
		_nv_text(rx, ry, float(NV_RANK_N[0]) - 5.0, step, 12.0, "Chưa ai treo Quả Châu.", "left")
	for row: Dictionary in top:
		var k: int = int(row["i"]) - 1
		if k < 0 or k > 9:
			continue
		var cy: float = ry + float(k) * step
		var mine: bool = int(t["rank"]) == int(row["i"])
		if k < 3 and art("medal_" + str(k + 1)) != null:
			_pic_c("medal_" + str(k + 1), rx + float(NV_RANK_MEDAL[0]), cy + float(NV_RANK_MEDAL[1]))
		else:
			_dbtext(_o + Vector2(rx - 1.0, cy), 32.0, 20.0, 12.0, NV_DARK, NONE, "center", str(k + 1))
		_dk_fit(NV_RANK_NAME, 0, rx, cy, 12, NV_RED if mine else NV_DARK, str(row["label"]), "left")
		_dk(NV_RANK_N, 0, rx, cy, 12.0, NV_RED if mine else NV_DARK, num(int(row["n"])), "right")
	_dk(NV_RANK_FOOT, 0, x, y, 11.0, NV_DARK, "Hạng của bạn: " + (str(int(t["rank"])) if int(t["rank"]) > 0 else "chưa có"), "left")
	_dk(NV_RANK_FOOT, 4, x, y, 11.0, NV_DARK, "BXH đã chốt" if bool(t["ranked"]) else _row_text("rank", float(t["rankAt"]), "Chốt BXH sau ", "", "Đang chốt BXH...", 1), "right")


func _tat() -> void :
	var s: Dictionary = st
	var unopened: int = int(s["unopened"])
	var stocking: String = "stocking_empty" if unopened <= 0 else ("stocking_some" if unopened < 5 else "stocking_full")
	_pic_at("mantel", float(NV_MANTEL[0]), float(NV_MANTEL[1]))
	_pic_at(stocking, float(NV_STOCKING[0]), float(NV_STOCKING[1]))
	_tipr(float(NV_STOCKING[0]), float(NV_STOCKING[1]), maxf(40.0, _w(stocking)), maxf(40.0, _h(stocking)), 
		"Tất Giáng Sinh của bạn: " + str(unopened) + " gói chưa mở, đã nhận " + str(int(s["total"])) + " gói.\nBạn guild gửi tối đa " + str(int(s["max"])) + " gói mỗi ngày cho một người.")
	_dk(NV_STOCK_COUNT, 0, 0, 0, 14.0, NV_DARK, "×" + str(unopened))
	var from: Array = s["from"]
	var lines: Array = []
	for one: Dictionary in from:
		if lines.size() < 4 or from.size() <= 5:
			lines.append(str(one["label"]) + " (" + str(int(one["n"])) + ")")
	if from.size() > 5:
		lines.append("... và " + str(from.size() - 4) + " người khác")
	if lines.is_empty():
		lines.append("Chưa có ai gửi quà.")
	var lh: float = float(NV_FROM[3]) / 5.0
	for j in mini(5, lines.size()):
		_plain(float(NV_FROM[0]), float(NV_FROM[1]) + float(j) * lh, float(NV_FROM[2]), lh, 12.0, NV_DARK, "left", str(lines[j]), false)
	var is_open: bool = bool(s["open"])
	_dk(NV_OPEN_TIME, 0, 0, 0, 12.0, NV_DARK, "Tất đã mở được!" if is_open else _row_text("open", float(s["openAt"]), "Mở sau ", "", "Tất đã mở được!", 0))
	var live: bool = is_open and unopened > 0
	if not live:
		_tipr(float(NV_OPEN_BTN[0]), float(NV_OPEN_BTN[1]), maxf(40.0, _w("btn_mo_st")), maxf(24.0, _h("btn_mo_st")), 
			"Tất chưa có gói quà nào mới." if is_open else "Tất mở được sau " + left_text(float(s["openAt"]), _t()) + ".")
	_btn("openst", "btn_mo_st", float(NV_OPEN_BTN[0]), float(NV_OPEN_BTN[1]), live, "btn_mo_glow")
	var list: Array = s["mates"]
	var per: int = int(NV_MATE_ROWS[3])
	var pages: int = maxi(1, ceili(float(list.size()) / float(per)))
	var can_send: bool = earning() and int(s["sent"]) < int(s["send"])
	var guild: bool = bool(s["guild"])
	if not guild:
		_nv_text(float(NV_MATE_ROWS[0]), float(NV_MATE_ROWS[1]), float(NV_MATE_NAME[0]) + 240.0, float(NV_MATE_ROWS[2]), 13.0, "Vào guild để gửi quà cho bạn bè.", "left")
	elif list.is_empty():
		_nv_text(float(NV_MATE_ROWS[0]), float(NV_MATE_ROWS[1]), float(NV_MATE_NAME[0]) + 240.0, float(NV_MATE_ROWS[2]), 13.0, "Guild chưa có thành viên khác.", "left")
	var p: int = mini(page, pages - 1)
	if guild:
		for i in range(p * per, mini(list.size(), (p + 1) * per)):
			var mate: Dictionary = list[i]
			var x: float = float(NV_MATE_ROWS[0])
			var y: float = float(NV_MATE_ROWS[1]) + float(i - p * per) * float(NV_MATE_ROWS[2])
			_pic_at("row_mate", x, y)
			_dk_fit(NV_MATE_NAME, 0, x, y, 12, NV_DARK, str(mate["label"]), "left")
			_plain(x + float(NV_MATE_RC[0]), y + float(NV_MATE_RC[1]), float(NV_MATE_RC[2]), float(NV_MATE_RC[3]), 11.0, NV_DARK, "left", 
				"đã nhận " + str(int(mate["rc"])) + "/" + str(int(s["max"])), false)
			_tipr(x, y, float(NV_MATE_BTN[0]), float(NV_MATE_ROWS[2]) - 2.0, str(mate["label"]) + ": hôm nay đã nhận " + str(int(mate["rc"])) + "/" + str(int(s["max"])) + " gói"
				+ (", " + str(int(mate["mine"])) + " gói là của bạn." if int(mate["mine"]) > 0 else "."))
			_btn("mate:" + str(int(mate["id"])), "btn_gui_st", x + float(NV_MATE_BTN[0]), y + float(NV_MATE_BTN[1]), can_send and int(mate["rc"]) < int(s["max"]), "", "btn_gui_arm")
		if pages > 1:
			_arrow(-1, float(NV_MATE_PAGER[0]), float(NV_MATE_PAGER[1]), p > 0)
			_arrow(1, float(NV_MATE_PAGER[2]), float(NV_MATE_PAGER[3]), p < pages - 1)
			_dk(NV_MATE_PAGER, 4, 0, 0, 12.0, NV_DARK, str(p + 1) + "/" + str(pages))
	var x2: float = float(NV_SENT[0])
	var y2: float = float(NV_SENT[1])
	_pic_at("plate_sent", x2, y2)
	_dk(NV_SENT_TEXT, 0, x2, y2, 12.0, NV_DARK, "Hôm nay " + str(int(s["sent"])) + "/" + str(int(s["send"])))
	_tipr(x2, y2, maxf(60.0, _w("plate_sent")), maxf(20.0, _h("plate_sent")), 
		"Mỗi ngày gửi tối đa " + str(int(s["send"])) + " gói, mỗi gói " + str(int(s["price"])) + " Kẹo Giáng Sinh.\nGói quà là hộp bí mật, mỗi gói +1 Độ Ấm.")
	_pic_at("warm_track", float(NV_WARM[0]), float(NV_WARM[1]))
	_dk(NV_WARM_TEXT, 0, 0, 0, 13.0, NV_DARK, num(int(s["warmth"])))
	var wl: Array = track("wm")["list"]
	for k in mini(3, wl.size()):
		var need: int = int(wl[k]["need"])
		_node("wm", wl[k], float(NV_WARM_NODES[k * 2]), float(NV_WARM_NODES[k * 2 + 1]), NV_WARM_PLATE, NV_WARM_BTN, str(need), "Độ Ấm " + str(need))


func _arrow(dir: int, x: float, y: float, live: bool) -> void :
	var name: String = "arrow_l" if dir < 0 else "arrow_r"
	_pic_at(name, x, y, 1.0 if live else 0.35)
	if live:
		_click("page:" + str(dir), x, y, maxf(24.0, _w(name)), maxf(24.0, _h(name)))


func _xuong() -> void :
	if shop.is_empty():
		_note("Xưởng Quà chưa có hàng.")
		return
	var split: Array = shop_split()
	_good(split[0], float(NV_FEAT[0]), float(NV_FEAT[1]), true)
	var goods: Array = split[1]
	var pages: int = maxi(1, ceili(float(goods.size()) / 8.0))
	var p: int = mini(page, pages - 1)
	for i in range(p * 8, mini(goods.size(), (p + 1) * 8)):
		var corner: Vector2 = good_corner(i - p * 8)
		_good(goods[i], corner.x, corner.y, false)
	if pages > 1:
		_arrow(-1, float(NV_PAGER[0]), float(NV_PAGER[1]), p > 0)
		_arrow(1, float(NV_PAGER[2]), float(NV_PAGER[3]), p < pages - 1)
		for k in pages:
			_pic_c("dot_on" if k == p else "dot_off", float(NV_PAGER[4]) + (float(k) - float(pages - 1) / 2.0) * float(NV_PAGER[6]), float(NV_PAGER[5]))


func _good(g: Dictionary, x: float, y: float, feat: bool) -> void :
	var ic: Array = NV_FEAT_ICON if feat else NV_GOOD_ICON
	var name_r: Array = NV_FEAT_NAME if feat else NV_GOOD_NAME
	var price: Array = NV_FEAT_PRICE if feat else NV_GOOD_PRICE
	var limit: Array = NV_FEAT_LIMIT if feat else NV_GOOD_LIMIT
	var bpos: Array = NV_FEAT_BTN if feat else NV_GOOD_BTN
	var stamp: Array = NV_FEAT_STAMP if feat else NV_GOOD_STAMP
	var ics: float = float(ic[2])
	var left: int = good_left(g)
	var label: String = item_name(int(g["item"]))
	var id: String = "shop:" + str(g["id"])
	var h: int = have()
	var short: bool = h >= 0 and h < int(g["price"])
	_pic_at("card_feat" if feat else "card_good", x, y)
	icon(int(g["item"]), ics, _o + Vector2(x + float(ic[0]), y + float(ic[1])))
	_count(int(g["n"]), x + float(ic[0]), y + float(ic[1]), ics)
	_dk_fit(name_r, 0, x, y, 14 if feat else 12, NV_DARK, label if not label.is_empty() else "Vật phẩm")
	_dk(price, 0, x, y, 13.0, NV_RED if short else NV_DARK, num(int(g["price"])), "center" if feat else "left")
	_pic_at("token_24" if feat else "token_16", x + float(price[4]), y + float(price[5]))
	var lim: int = int(g["limit"])
	_dk(limit, 0, x, y, 11.0, NV_DARK, ("Tuần " if str(g["per"]) == "w" else "Mùa ") + str(int(g["bought"])) + "/" + str(lim) if lim > 0 else "Không giới hạn")
	tip_area(Rect2(_o + Vector2(x + float(ic[0]) - ics / 2.0, y + float(ic[1]) - ics / 2.0), Vector2(ics, ics)), int(g["item"]), "")
	_tipr(x + float(price[0]), y + float(price[1]), float(price[2]), float(price[3]), 
		"Giá: " + num(int(g["price"])) + " Kẹo Giáng Sinh, bạn có " + (num(h) if h >= 0 else "--") + ".")
	if lim > 0:
		_tipr(x + float(limit[0]), y + float(limit[1]), float(limit[2]), float(limit[3]), 
			"Mỗi tuần đổi tối đa " + str(lim) + " lần." if str(g["per"]) == "w" else "Cả mùa đổi tối đa " + str(lim) + " lần.")
	_btn(id, "btn_doi_st" if feat else "btn_doi_s_st", x + float(bpos[0]), y + float(bpos[1]), left > 0, 
		"btn_doi_glow" if feat and not short and left > 0 else "", "btn_doi_arm" if feat else "btn_doi_s_arm")
	if left <= 0:
		_pic_at("stamp_het", x + float(stamp[0]), y + float(stamp[1]))


func _ms(t: String) -> void :
	var tr: Dictionary = track(t)
	var list: Array = tr["list"]
	var x: float = float(NV_MS_HEAD[0])
	var y: float = float(NV_MS_HEAD[1])
	_pic_at("plate_ms", x, y)
	_dbtext(_o + Vector2(361, 127), 218.0, 28.0, 15.0, NV_CREAM, NV_INK, "center", "NẠP GIÁNG SINH" if t == "rc" else "TIÊU GIÁNG SINH")
	_dk(NV_MS_HEAD_TEXT, 0, x, y, 13.0, NV_DARK, "Đã " + ("nạp" if t == "rc" else "tiêu") + " trong mùa: " + num(int(tr["total"])) + " Xu")
	_dk(NV_MS_HEAD_TEXT, 4, x, y, 11.0, NV_DARK, _row_text("ms", float(me.get("endAt", 0.0)), "Tính đến hết mùa: còn ", "", "Mùa Giáng Sinh đã kết thúc", 0)
		if earning() else "Mùa Giáng Sinh đã kết thúc, quà đạt mốc vẫn nhận được.")
	_tipr(x, y, maxf(60.0, _w("plate_ms")), maxf(24.0, _h("plate_ms")), 
		"Tổng Xu nạp trong mùa Giáng Sinh. Mỗi mốc nhận một lần." if t == "rc"
		else "Tổng Xu tiêu trong mùa Giáng Sinh (không tính tiền gửi Hũ Mật). Mỗi mốc nhận một lần.")
	var start: int = ms_start(list)
	var count: int = mini(7, list.size() - start)
	var reached: int = 0
	for k in count:
		if int(list[start + k]["s"]) >= 1:
			reached = k + 1
	var gx: float = float(NV_MS_GARLAND[0])
	var gy: float = float(NV_MS_GARLAND[1])
	_pic_at("garland", gx, gy)
	if reached > 0:
		var lit_w: float = float(NV_MS_LIT[reached - 1])
		var pulse: Texture2D = art("garland_lit_pulse")
		if pulse != null and _pulse_a >= 0.0:
			var pw: float = minf(float(pulse.get_width()), lit_w + 24.0)
			draw_texture_rect_region(pulse, Rect2((_o + Vector2(gx - NV_PULSE_PAD, gy - NV_PULSE_PAD)) * _f, Vector2(pw, float(pulse.get_height())) * _f), 
				Rect2(0, 0, pw, float(pulse.get_height())), Color(1, 1, 1, _pulse_a))
		var lit: Texture2D = art("garland_lit")
		if lit != null:
			var lw: float = minf(float(lit.get_width()), maxf(1.0, lit_w))
			draw_texture_rect_region(lit, Rect2((_o + Vector2(gx, gy)) * _f, Vector2(lw, float(lit.get_height())) * _f), Rect2(0, 0, lw, float(lit.get_height())))
	for k in count:
		var m: Dictionary = list[start + k]
		var s: int = int(m["s"])
		var cx: float = float(NV_MS_CARDS[k * 2])
		var cy: float = float(NV_MS_CARDS[k * 2 + 1])
		_pic_at("card_ms", cx, cy)
		_dk(NV_MS_NEED, 0, cx, cy, 12.0, NV_RED if s >= 1 else NV_DARK, num(int(m["need"])) + " Xu")
		_prize(m["items"], cx + float(NV_MS_ICON[0]), cy + float(NV_MS_ICON[1]), float(NV_MS_ICON[2]), true)
		_dk(NV_MS_COUNT, 0, cx, cy, 11.0, NV_DARK, str((m["items"] as Array).size()) + " món" if (m["items"] as Array).size() > 1 else "")
		_tipr(cx + float(NV_MS_NEED[0]), cy + float(NV_MS_NEED[1]), float(NV_MS_NEED[2]), float(NV_MS_NEED[3]), "Mốc " + num(int(m["need"])) + " Xu: " + items_text(m["items"]) + ".")
		if s == 1:
			_btn("claim:" + t + ":" + str(int(m["need"])), "btn_nhan_st", cx + float(NV_MS_BTN[0]), cy + float(NV_MS_BTN[1]), true, "btn_nhan_glow")
		elif s == 2:
			_pic_at("stamp_nhan", cx + float(NV_MS_STAMP[0]), cy + float(NV_MS_STAMP[1]))
		else:
			_pic_at("lock_ms", cx + float(NV_MS_LOCK[0]), cy + float(NV_MS_LOCK[1]))
	if list.is_empty():
		_note("Chưa có mốc nào.")
	_btn("all", "btn_nhanhet_st", float(NV_MS_ALL[0]), float(NV_MS_ALL[1]), int(tr["claimable"]) > 0, "btn_nhanhet_glow")
	_btn("all", "btn_nhanhet_st", float(NV_MS_ALL[0]), float(NV_MS_ALL[1]), int(tr["claimable"]) > 0, "btn_nhanhet_glow")
