extends "tev_window.gd"










signal closed(note: String)

const TaAtlas = preload("ta_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const MB_POLL_TICKS: int = 120
const TA_TIP: String = "Tri Ân Thầy Cô"
const TA_ICON: String = "btn_trian"
const TA_WORD: String = "word_trian_t"
const TA_NAME: String = "Tri Ân Thầy Cô"
const TA_ART: Array = ["ta_bg", "tab_normal", "tab_selected", "tabicon_bd", "tabicon_dh", "tabicon_dv", "tabicon_shop", "tabicon_rc", "tabicon_sp", 
	"tablabel_bd", "tablabel_dh", "tablabel_dv", "tablabel_shop", "tablabel_rc", "tablabel_sp", "chip_wallet", "chip_time", "token_24", "token_16", 
	"bubble", "teddy_a", "teddy_b", "desk", "qty_plate", "school_head", "ruler_empty", "ruler_full", "gift_off", "gift_on", "ms_head", "vine_off", 
	"vine_on", "ms_card", "ms_card_off", "ms_glow", "ms_lock", "ms_check", "stamp_danhan", "bd_card", "bd_rules", "tn_head", "stamp_10", "stamp_9", 
	"stamp_8", "stamp_7", "stamp_slot", "dv_board", "dv_pip_off", "dv_pip_on", "dv_pip_right", "dv_pip_wrong", "ans_right", "ans_wrong", "shop_sign", 
	"feat_card", "feat_art", "ribbon_hot", "price_l", "price_s", "good_card", "good_card_off", "stamp_het", "dot_on", "dot_off", "rc_head", "sp_head", 
	"vine7_off", "vine7_on", "dv_teddy_a", "dv_teddy_b", "rc_scene", "btn_close_st", "btn_minus_st", "btn_plus_st", "btn_danghoa_st", "btn_nhan_st", 
	"btn_nhanhet_st", "btn_ans_st", "btn_doi_l_st", "btn_doi_s_st", "arrow_l_st", "arrow_r_st", "fx_sparkle", "fx_petal", "fx_chalk", "fx_dove", "fx_plane"]

const TA_SHEETS: Dictionary = {
	"btn_close_st": [40, 40, 1, 4], "btn_minus_st": [44, 46, 1, 4], "btn_plus_st": [44, 46, 1, 4], "btn_danghoa_st": [228, 71, 1, 4], 
	"btn_nhan_st": [70, 36, 1, 4], "btn_nhanhet_st": [160, 52, 1, 4], "btn_ans_st": [214, 62, 1, 4], "btn_doi_l_st": [180, 44, 1, 4], 
	"btn_doi_s_st": [82, 36, 1, 4], "arrow_l_st": [30, 30, 1, 4], "arrow_r_st": [30, 30, 1, 4], "fx_sparkle": [48, 48, 8, 8], 
	"fx_petal": [28, 28, 4, 4], "fx_chalk": [64, 64, 6, 6], "fx_dove": [64, 96, 6, 6], "fx_plane": [64, 32, 4, 4], 
}
const TA_TAB_KEYS: Array = ["bd", "dh", "dv", "shop", "rc", "sp"]
const TA_SAY: Array = ["Chúc mừng ngày Nhà giáo Việt Nam 20/11!", "Mỗi bông hoa là một lời cảm ơn đó~", "Thắng trận được điểm 10, có thêm hoa!", 
	"Cả trường dâng đủ hoa là ai cũng có quà!", "Ngày 20/11 mỗi bông tính gấp đôi nhé!", "Làm Đố Vui mỗi ngày để có thêm hoa nha!"]
const TA_CREAM: Color = Color("fff3d2")
const TA_INK: Color = Color("0e2a22")
const TA_INK_TEXT: Color = Color("233b59")
const TA_GOLD: Color = Color("f5d06b")
const TA_SOFT: Color = Color("b9d2c2")
const TA_SHORT: Color = Color("ff6b57")
const TA_CHALK: Color = Color("f4f0e6")
const TA_NEED: Color = Color("a3252b")
const TA_DIM: Color = Color("7d7468")
const TA_QTY: Color = Color("7a1c27")
const TA_DOT: Color = Color("e82d2a")
const TA_CLOSE: Vector2 = Vector2(905, 72)
const TA_TABS: Array = [39, 107, 39, 177, 39, 248, 39, 314, 39, 383, 39, 450]
const TA_TAB_ICON: Vector2 = Vector2(7, 8)
const TA_TAB_LABEL: Vector2 = Vector2(60, 8)
const TA_TAB_DOT: Vector2 = Vector2(141, 14)
const TA_TAB_HIT: Rect2 = Rect2(3, 3, 151, 64)
const TA_TAB_GLOW: Vector2 = Vector2(-10, -10)
const TA_WALLET: Vector2 = Vector2(603, 81)
const TA_WALLET_TOKEN: Vector2 = Vector2(7, 3)
const TA_WALLET_TEXT: Array = [35, 3, 87, 24]
const TA_TIME: Vector2 = Vector2(735, 81)
const TA_TIME_TEXT: Array = [32, 4, 114, 22]
const TA_DOVE: Vector2 = Vector2(918, 482)
const TA_PLANE: Array = [704, 42, 863, 36]
const TA_PETALS: Array = [229, 116, 658, 4]
const TA_TEDDY: Vector2 = Vector2(242, 164)
const TA_BUBBLE: Vector2 = Vector2(222, 117)
const TA_BUBBLE_TEXT: Array = [11, 8, 138, 35]
const TA_DESK: Vector2 = Vector2(209, 223)
const TA_VASE: Vector2 = Vector2(288, 316)
const TA_QTY_PLATE: Vector2 = Vector2(268, 425)
const TA_QTY_TEXT: Array = [26, 4, 76, 32]
const TA_QTY_MINUS: Vector2 = Vector2(245, 422)
const TA_QTY_PLUS: Vector2 = Vector2(372, 422)
const TA_OFFER_BTN: Vector2 = Vector2(219, 467)
const TA_SC_HEAD: Vector2 = Vector2(475, 114)
const TA_RULER: Vector2 = Vector2(462, 168)
const TA_RULER_FILL: Array = [12, 414]
const TA_RULER_GIFT_Y: float = 10.0
const TA_SC_TEXT: Array = [588, 223, 193, 21]
const TA_SC_SUB: Array = [527, 246, 316, 17]
const TA_DH_HEAD: Vector2 = Vector2(475, 263)
const TA_DH_HEAD_TEXT: Array = [270, 7, 116, 23]
const TA_DH_VINE: Vector2 = Vector2(473, 303)
const TA_DH_NODES: Array = [34, 120, 209, 296, 384]
const TA_DH_BAR: Array = [8, 414]
const TA_DH_CARDS: Array = [465, 551, 640, 727, 815]
const TA_DH_CARD_Y: float = 332.0
const TA_BD_CARD: Vector2 = Vector2(215, 119)
const TA_BD_SLOTS: Array = [276, 294, 320, 294, 364, 294, 408, 294, 276, 374, 320, 374, 364, 374, 408, 374]
const TA_BD_TODAY: Array = [239, 417, 199, 26]
const TA_BD_SUB: Array = [239, 443, 193, 24]
const TA_BD_RULES: Vector2 = Vector2(469, 117)
const TA_BD_RULE: Array = [478, 147, 22, 23]
const TA_BD_RULE_TEXT: Array = [508, 147, 385, 23]
const TA_BD_FOOT: Array = [488, 235, 402, 29]
const TA_TN_HEAD: Vector2 = Vector2(473, 271)
const TA_TN_HEAD_TEXT: Array = [263, 8, 136, 24]
const TA_TN_VINE: Vector2 = Vector2(473, 305)
const TA_TN_CARD_Y: float = 339.0
const TA_DV_TEDDY: Vector2 = Vector2(214, 204)
const TA_DV_BOARD: Vector2 = Vector2(448, 117)
const TA_DV_PIPS: Array = [534, 233, 73]
const TA_DV_Q: Array = [474, 251, 405, 65]
const TA_DV_ANS: Array = [466, 315, 681, 315, 466, 381, 681, 381]
const TA_DV_ANS_TEXT: Array = [12, 7, 190, 47]
const TA_DV_MARK: Vector2 = Vector2(182, -8)
const TA_DV_INFO: Array = [467, 456, 420, 20]
const TA_DV_SUB: Array = [467, 477, 420, 20]
const TA_SIGN: Vector2 = Vector2(214, 117)
const TA_FEAT: Vector2 = Vector2(220, 196)
const TA_FEAT_ART: Array = [234, 214, 202, 164]
const TA_FEAT_HOT: Vector2 = Vector2(220, 196)
const TA_FEAT_NAME: Array = [240, 382, 194, 36]
const TA_FEAT_PRICE: Vector2 = Vector2(252, 421)
const TA_PRICE_L_TOKEN: Vector2 = Vector2(11, 9)
const TA_PRICE_L_TEXT: Array = [46, 6, 116, 28]
const TA_FEAT_STOCK: Array = [247, 463, 177, 22]
const TA_FEAT_BTN: Vector2 = Vector2(246, 493)
const TA_FEAT_STAMP: Vector2 = Vector2(290, 268)
const TA_GRID_X: Array = [462, 573, 684, 795]
const TA_GRID_Y: Array = [126, 328]
const TA_CARD_WELL: Array = [56, 56, 54]
const TA_CARD_NAME: Array = [10, 85, 88, 31]
const TA_CARD_PRICE: Vector2 = Vector2(7, 116)
const TA_PRICE_S_TOKEN: Vector2 = Vector2(8, 6)
const TA_PRICE_S_TEXT: Array = [28, 2, 64, 24]
const TA_CARD_STOCK: Array = [10, 143, 88, 17]
const TA_CARD_BTN: Vector2 = Vector2(14, 159)
const TA_CARD_STAMP: Vector2 = Vector2(8, 77)
const TA_ARROWS: Array = [564, 528, 720, 528]
const TA_DOTS: Array = [648, 536, 28, 6]
const TA_RC_SCENE: Vector2 = Vector2(394, 449)
const TA_RC_HEAD: Vector2 = Vector2(214, 119)
const TA_RC_HEAD_TEXT: Array = [111, 45, 394, 26]
const TA_RC_SUB: Array = [239, 202, 642, 23]
const TA_RC_ALL: Vector2 = Vector2(734, 136)
const TA_RC_VINE: Vector2 = Vector2(224, 226)
const TA_RC_NODES: Array = [51, 148, 245, 342, 439, 536, 633]
const TA_RC_BAR: Array = [2, 682]
const TA_RC_CARDS: Array = [233, 330, 427, 524, 621, 718, 815]
const TA_RC_CARD_Y: float = 265.0
const TA_MS_NEED: Array = [6, 20, 72, 21]
const TA_MS_WELL: Array = [42, 78, 54]
const TA_MS_TOKEN: Vector2 = Vector2(13, 107)
const TA_MS_FLN: Array = [38, 107, 39, 24]
const TA_MS_BTN: Array = [7, 132, 70, 36]
const TA_MS_STAMP: Vector2 = Vector2(7, 133)
const TA_MS_GLOW: Vector2 = Vector2(-12, -12)
const TA_MS_LOCK: Vector2 = Vector2(67, 112)
const TA_MS_CHECK: Vector2 = Vector2(11, 144)
const TA_FLOAT_AT: Vector2 = Vector2(663, 133)

static var s_ta_shown: bool = false
static var s_ta_tab: int = 1
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 7
var ta_visible: bool = false
var loaded: bool = false
var ta_name: String = TA_NAME
var earning: bool = false
var end_at: float = 0.0
var shop_at: float = 0.0
var flowers: int = -1
var flower_id: int = 0
var token: String = ""
var today: String = ""
var tracks: Dictionary = {}
var day: Dictionary = {"got": 0, "cap": 0, "matches": 0, "grades": []}
var pay: Dictionary = {}
var offer: Dictionary = {}
var school: Dictionary = {}
var quiz: Dictionary = {}
var shop: Array = []
var tab: int = 1
var page: int = 0
var qty: int = 10
var q_at: int = 0
var pick_q: int = -1
var pick: int = -1
var advance_at: int = 0
var say_text: String = ""
var say_at: int = 0
var thank_at: int = 0
var show_fl: int = 0
var show_sc: int = 0
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _b_ready: bool = false
var _b_failed: bool = false
var _teddy_key: String = ""
var _teddy_b: bool = false
var _glow_a: float = 1.0
var _say_line: String = ""
var _time_line: String = ""
var _time_tip: String = ""
var _spots: Dictionary = {}
var _dove_f: int = 0
var _plane_f: int = 0

func _setup() -> void :
	art_dir = ""
	art_files = TA_ART
	sheets = TA_SHEETS
	win_size = Vector2(960, 580)
	_defaults()
	super ()

static func reset_statics() -> void :
	s_ta_shown = false
	s_ta_tab = 1


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew


func _defaults() -> void :
	day = {"got": 0, "cap": 0, "matches": 0, "grades": []}
	pay = {"g10": 0, "g9": 0, "g8": 0, "g7": 0, "min": 60, "kills": 3, "bot": 9, "pw": 9, "pl": 7}
	offer = {"step": 10, "max": 500, "offered": 0, "mult": 1, "double": ""}
	school = track_of(null)
	school["min"] = 10
	school["ok"] = false
	quiz = {}


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 7
	ta_visible = false
	loaded = false
	ta_name = TA_NAME
	earning = false
	end_at = 0.0
	shop_at = 0.0
	flowers = -1
	flower_id = 0
	token = ""
	today = ""
	tracks = {}
	_defaults()
	shop = []
	tab = 1
	page = 0
	qty = 10
	q_at = 0
	pick_q = -1
	pick = -1
	advance_at = 0
	say_text = ""
	say_at = 0
	thank_at = 0
	show_fl = 0
	show_sc = 0
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(TaAtlas.FILE):
			_atlas = load(TaAtlas.FILE) as Texture2D
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
	if atlas == null or not TaAtlas.R.has(name):
		return null
	var row: Array = TaAtlas.R[name]
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = atlas
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part


func button_icon() -> Texture2D:
	return art(TA_ICON)

func button_word() -> Texture2D:
	return art(TA_WORD)




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/tri-an.xml?r=" + str(int(now_ms())), "poll")


func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = MB_POLL_TICKS
		if not loading:
			poll()


func button_visible() -> bool:
	return ta_visible


func button_dot() -> bool:
	return ta_visible and (claimable("") > 0 or quiz_left() > 0)


func claimable(key: String) -> int:
	var n: int = 0
	for k: String in (["rc", "sp", "tn", "dh"] if key.is_empty() else [key]):
		if tracks.has(k):
			n += int(tracks[k]["claimable"])
	return n


func quiz_left() -> int:
	var qs: Array = quiz.get("qs", [])
	if not earning:
		return 0
	var n: int = 0
	for q: Dictionary in qs:
		if str(q["s"]) == "-":
			n += 1
	return n


func busy() -> bool:
	return loading and action != "poll"

func ready_shown() -> bool:
	return _b_ready


func open() -> void :
	if opened or not ta_visible:
		return
	if claimable("dh") > 0:
		tab = 1
	elif claimable("tn") > 0:
		tab = 0
	elif claimable("rc") > 0:
		tab = 4
	elif claimable("sp") > 0:
		tab = 5
	else:
		tab = s_ta_tab if s_ta_tab >= 0 and s_ta_tab < 6 else 1
	page = 0
	say_at = 0
	thank_at = 0
	advance_at = 0
	pick_q = -1
	pick = -1
	q_at = next_question(-1)
	show_fl = flowers
	show_sc = int(float(school["total"]))
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
	poll_in = MB_POLL_TICKS
	closed.emit(note)


func leave() -> void :
	close()

func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "offer":
		on_offer()
	elif id.begins_with("tab:"):
		on_tab(id.substr(4).to_int())
	elif id.begins_with("page:"):
		on_page(id.substr(5).to_int())
	elif id.begins_with("qty:"):
		on_qty(id.substr(4).to_int())
	elif id.begins_with("q:"):
		on_question(id.substr(2).to_int())
	elif id.begins_with("a:"):
		on_answer(id)
	elif id.begins_with("buy:"):
		on_buy(id.substr(4))
	elif id.begins_with("claim:"):
		on_claim(id)




func _failed(what: String) -> void :
	if what != "poll":
		tip("Không kết nối được máy chủ, hãy thử lại.")
	if what.begins_with("quiz:"):
		pick_q = -1
		pick = -1
	if opened:
		_rebuild()

static func _int_at(at: Dictionary, key: String) -> int:
	return TevWheel.as_int(str(at.get(key, "")))


func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_deep(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": [], "text": text}
	var parsed: bool = xml != null
	var old_tracks: Dictionary = tracks
	var old_fl: int = show_fl
	var old_sc: int = show_sc
	var notice: String = ""
	var done_kind: String = ""
	var done_items: Array = []
	var answer: Variant = null
	if parsed:
		var at: Dictionary = xml["at"]
		notice = str(at.get("notice", ""))
		ta_visible = str(at.get("visible", "")) == "1"
		s_ta_shown = ta_visible
		if ta_visible:
			var goods: Array = []
			for box: Dictionary in kids(xml, "shop"):
				for g: Dictionary in kids(box, "g"):
					var it: String = str(g["at"].get("it", ""))
					var cut: int = it.find(":")
					goods.append({"id": str(g["at"].get("id", "")), "item": maxi(0, TevWheel.as_int(it.substr(0, cut) if cut > 0 else it)), 
						"n": maxi(1, TevWheel.as_int(it.substr(cut + 1) if cut > 0 else "1")), "price": _int_at(g["at"], "price"), 
						"limit": _int_at(g["at"], "limit"), "bought": _int_at(g["at"], "bought"), "tag": str(g["at"].get("tag", ""))})
			var days: Array = kids(xml, "day")
			var pays: Array = kids(xml, "pay")
			var offers: Array = kids(xml, "offer")
			var schools: Array = kids(xml, "school")
			var quizzes: Array = kids(xml, "quiz")
			var dones: Array = kids(xml, "done")
			var answers: Array = kids(xml, "ans")
			ta_name = str(at.get("name", "")) if not str(at.get("name", "")).is_empty() else TA_NAME
			earning = str(at.get("earning", "")) == "1"
			end_at = now_ms() + TevWheel.as_number(str(at.get("left", ""))) * 1000.0
			shop_at = now_ms() + TevWheel.as_number(str(at.get("shopLeft", ""))) * 1000.0
			flowers = _int_at(at, "flowers")
			flower_id = maxi(0, _int_at(at, "flowerId"))
			token = str(at.get("token", ""))
			today = str(at.get("today", ""))
			var found: Dictionary = {}
			for key: String in ["rc", "sp", "tn", "dh"]:
				var rows: Array = kids(xml, key)
				found[key] = track_of(rows[0] if not rows.is_empty() else null)
			tracks = found
			var d: Dictionary = days[0]["at"] if not days.is_empty() else {}
			var grades: Array = []
			if not days.is_empty():
				for part: String in str(d.get("grades", "")).split(","):
					if TevWheel.as_int(part) > 0:
						grades.append(TevWheel.as_int(part))
			day = {"got": _int_at(d, "got"), "cap": _int_at(d, "cap"), "matches": _int_at(d, "matches"), "grades": grades}
			var p: Variant = pays[0]["at"] if not pays.is_empty() else null
			pay = {"g10": _int_at(p, "g10") if p != null else 0, "g9": _int_at(p, "g9") if p != null else 0, 
				"g8": _int_at(p, "g8") if p != null else 0, "g7": _int_at(p, "g7") if p != null else 0, 
				"min": _int_at(p, "min") if p != null else 60, "kills": _int_at(p, "kills") if p != null else 3, 
				"bot": _int_at(p, "bot") if p != null else 9, "pw": _int_at(p, "pw") if p != null else 9, "pl": _int_at(p, "pl") if p != null else 7}
			var o: Variant = offers[0]["at"] if not offers.is_empty() else null
			offer = {"step": maxi(1, _int_at(o, "step")) if o != null else 10, "max": _int_at(o, "max") if o != null else 500, 
				"offered": _int_at(o, "offered") if o != null else 0, "mult": maxi(1, _int_at(o, "mult")) if o != null else 1, 
				"double": str(o.get("double", "")) if o != null else ""}
			school = track_of(schools[0] if not schools.is_empty() else null)
			school["min"] = _int_at(schools[0]["at"], "min") if not schools.is_empty() else 10
			school["ok"] = not schools.is_empty() and str(schools[0]["at"].get("ok", "")) == "1"
			var qs: Array = []
			if not quizzes.is_empty():
				for node: Dictionary in kids(quizzes[0], "q"):
					var opts: Array = []
					for opt: Dictionary in kids(node, "a"):
						opts.append(_text_of(opt))
					var ts: Array = kids(node, "t")
					qs.append({"i": _int_at(node["at"], "i"), "s": str(node["at"].get("s", "")), "c": _int_at(node["at"], "c"), 
						"t": "\n".join(ts.map( func(t: Dictionary) -> String: return _text_of(t))), "a": opts})
			var qa: Dictionary = quizzes[0]["at"] if not quizzes.is_empty() else {}
			quiz = {"pay": _int_at(qa, "pay"), "bonus": _int_at(qa, "bonus"), "right": _int_at(qa, "right"), "qs": qs}
			shop = goods
			if not dones.is_empty():
				done_kind = str(dones[0]["at"].get("k", ""))
				done_items = items_of(str(dones[0]["at"].get("it", "")))
			if not answers.is_empty():
				var a: Dictionary = answers[0]["at"]
				answer = {"i": _int_at(a, "i"), "ok": str(a.get("ok", "")) == "1", "c": _int_at(a, "c"), "gain": _int_at(a, "gain"), 
					"perfect": str(a.get("perfect", "")) == "1"}
		else:
			tracks = {}
			shop = []
			quiz = {}
		loaded = true
	if not parsed and what != "poll":
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if what.begins_with("quiz:") and answer == null:
		pick_q = -1
		pick = -1
	if opened and not ta_visible:
		close()
	elif opened:
		if done_kind.is_empty() and answer == null:
			show_fl = flowers
			show_sc = int(float(school["total"]))
		if answer != null:
			advance_at = tick + 55
		_rebuild()
		if not done_kind.is_empty() or answer != null:
			play_fx(done_kind, done_items, old_tracks, old_fl, old_sc, what, answer)
	if not notice.is_empty():
		tip(notice)


static func _text_of(node: Dictionary) -> String:
	return str(node.get("text", "")).strip_edges()



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


static func track_of(node: Variant) -> Dictionary:
	var list: Array = []
	if node == null:
		return {"total": 0.0, "claimable": 0, "list": list}
	for m: Dictionary in kids(node, "m"):
		list.append({"need": TevWheel.as_number(str(m["at"].get("need", ""))), "fl": _int_at(m["at"], "fl"), 
			"items": items_of(str(m["at"].get("it", ""))), "s": _int_at(m["at"], "s")})
	return {"total": TevWheel.as_number(str(node["at"].get("total", ""))), "claimable": _int_at(node["at"], "claimable"), "list": list}




func on_tab(i: int) -> void :
	if i < 0 or i >= 6 or i == tab:
		return
	tab = i
	s_ta_tab = tab
	page = 0
	_rebuild()


func on_page(step: int) -> void :
	page += step
	_rebuild()


func on_claim(key: String) -> void :
	var parts: PackedStringArray = key.split(":")
	if parts.size() != 3 or parts[0] != "claim" or busy():
		return
	fetch("/tri-an-claim.xml?t=" + parts[1] + "&m=" + parts[2] + "&k=" + TevWheel.uri_component(token) + "&r=" + str(int(now_ms())), "claim:" + parts[1])
	_rebuild()


func on_buy(id: String) -> void :
	if busy():
		return
	for g: Dictionary in shop:
		if str(g["id"]) == id:
			if flowers >= 0 and not afford(g):
				tip("Không đủ Hoa Điểm 10: cần " + num(int(g["price"])) + ", đang có " + num(flowers) + ".")
				return
			fetch("/tri-an-buy.xml?g=" + TevWheel.uri_component(id) + "&n=1&k=" + TevWheel.uri_component(token) + "&r=" + str(int(now_ms())), "buy:" + id)
			_rebuild()
			return


func qty_top() -> int:
	var step: int = maxi(1, int(offer["step"]))
	var top: int = maxi(step, int(offer["max"]))
	if flowers >= step:
		top = mini(top, int(float(flowers) / float(step)) * step)
	return top

func qty_fix() -> void :
	var step: int = maxi(1, int(offer["step"]))
	qty = maxi(step, mini(qty_top(), int(float(qty) / float(step)) * step))


func on_qty(dir: int) -> void :
	qty += dir * maxi(1, int(offer["step"]))
	qty_fix()
	_rebuild()


func on_offer() -> void :
	if busy() or not earning:
		return
	qty_fix()
	if flowers >= 0 and flowers < qty:
		tip("Không đủ Hoa Điểm 10: cần " + num(qty) + ", đang có " + num(flowers) + ".")
		say_text = "Em đánh trận hoặc làm Đố Vui để có thêm hoa nhé!"
		say_at = tick + 100
		_say_line = say_line()
		return
	fetch("/tri-an-offer.xml?n=" + str(qty) + "&k=" + TevWheel.uri_component(token) + "&r=" + str(int(now_ms())), "offer")
	_rebuild()


func on_question(i: int) -> void :
	q_at = i
	advance_at = 0
	_rebuild()


func on_answer(key: String) -> void :
	var parts: PackedStringArray = key.split(":")
	if parts.size() != 3 or parts[0] != "a" or busy():
		return
	pick_q = parts[1].to_int()
	pick = parts[2].to_int()
	advance_at = 0
	fetch("/tri-an-quiz.xml?q=" + parts[1] + "&a=" + parts[2] + "&k=" + TevWheel.uri_component(token) + "&r=" + str(int(now_ms())), 
		"quiz:" + parts[1] + ":" + parts[2])
	_rebuild()


func next_question(p: int) -> int:
	var qs: Array = quiz.get("qs", [])
	var n: int = qs.size()
	if n == 0:
		return 0
	for i in range(1, n + 1):
		var j: int = (p + i + n) % n
		if str(qs[j]["s"]) == "-":
			return j
	return maxi(0, mini(n - 1, p))




func featured() -> Variant:
	for g: Dictionary in shop:
		if str(g["tag"]) == "hot":
			return g
	return null

static func goods_left(g: Dictionary) -> bool:
	return int(g["limit"]) <= 0 or int(g["bought"]) < int(g["limit"])

static func stock(g: Dictionary) -> String:
	return "Còn %d/%d" % [maxi(0, int(g["limit"]) - int(g["bought"])), int(g["limit"])] if int(g["limit"]) > 0 else "Không giới hạn"

func afford(g: Dictionary) -> bool:
	return flowers >= int(g["price"])

func grid() -> Array:
	var feat: Variant = featured()
	var out: Array = []
	for g: Dictionary in shop:
		if feat == null or str(g["id"]) != str(feat["id"]):
			out.append(g)
	return out

func pages() -> int:
	return maxi(1, ceili(float(grid().size()) / 8.0))




func say_line() -> String:
	var turn: int = int(float(tick) / 150.0)
	if say_at > tick and not say_text.is_empty():
		return say_text
	if earning and flowers >= 0 and flowers < maxi(1, int(offer["step"])) and turn % 2 == 0:
		return "Thắng trận được điểm 10 là có hoa đó em!"
	if int(offer["mult"]) > 1 and turn % 2 == 1:
		return "Hôm nay 20/11, mỗi bông tính gấp đôi!"
	return str(TA_SAY[turn % TA_SAY.size()])


func time_line() -> String:
	return left_text(end_at, now_ms()) if earning else "Tiệm " + left_text(shop_at, now_ms())

func time_tip() -> String:
	if earning:
		return "Sự kiện kết thúc sau " + left_text(end_at, now_ms()) + ".\nTiệm Văn Phòng Phẩm mở thêm tới " + left_text(shop_at, now_ms()) + " nữa để đổi nốt Hoa Điểm 10."
	return "Sự kiện đã kết thúc, chỉ còn Tiệm Văn Phòng Phẩm.\nTiệm đóng sau " + left_text(shop_at, now_ms()) + "."


func wallet_text() -> String:
	return "--" if flowers < 0 else num(show_fl)


static func need_text(key: String, need: float) -> String:
	if key == "tn":
		return str(int(need)) + " điểm 10"
	return num(int(need)) + (" hoa" if key == "dh" else " Xu")


func reward_text(m: Dictionary) -> String:
	var parts: Array = []
	if int(m["fl"]) > 0:
		parts.append("Hoa Điểm 10 x" + str(int(m["fl"])))
	for row: Dictionary in m["items"]:
		var goods_name: String = item_name(int(row["id"]))
		parts.append((goods_name if not goods_name.is_empty() else "Quà") + " x" + str(int(row["n"])))
	return ", ".join(parts)


static func bar_x(list: Array, total: float, nodes: Array, bar: Array) -> float:
	var prev_need: float = 0.0
	var prev_x: float = float(bar[0])
	for i in mini(list.size(), nodes.size()):
		var need: float = float(list[i]["need"])
		var nx: float = float(nodes[i])
		if total < need:
			return prev_x + (nx - prev_x) * maxf(0.0, total - prev_need) / maxf(1.0, need - prev_need)
		prev_need = need
		prev_x = nx
	return float(bar[1])


func ruler_x(v: float) -> float:
	var list: Array = school["list"]
	var last: float = float(list[list.size() - 1]["need"]) if not list.is_empty() else 1.0
	return float(TA_RULER_FILL[0]) + float(TA_RULER_FILL[1] - TA_RULER_FILL[0]) * clampf(v / maxf(1.0, last), 0.0, 1.0)

func school_top() -> int:
	var list: Array = school["list"]
	return int(float(list[list.size() - 1]["need"])) if not list.is_empty() else 0




func _rebuild() -> void :
	if not opened:
		return
	fx_drop("amb")
	_b_ready = art_pending() == 0 and art("ta_bg") != null and loaded
	_b_failed = art_pending() == 0 and art("ta_bg") == null
	page = maxi(0, mini(pages() - 1, page))
	_glow_a = 1.0
	_dove_f = 0
	_plane_f = 0
	_teddy_key = "teddy" if tab == 1 else ("dv_teddy" if tab == 2 else "")
	_teddy_b = thank_at > tick
	_say_line = say_line()
	_time_line = time_line()
	_time_tip = time_tip()
	_spots = {}
	if not _b_ready:
		return
	var qs: Array = quiz.get("qs", [])
	if tab == 2 and not qs.is_empty():
		q_at = clampi(q_at, 0, qs.size() - 1)
	if tab == 1:
		qty_fix()
		_spots["qty"] = TA_QTY_PLATE + Vector2(float(TA_QTY_TEXT[0]) + float(TA_QTY_TEXT[2]) / 2.0, float(TA_QTY_TEXT[1]) + float(TA_QTY_TEXT[3]) / 2.0)
		_spots["sc"] = Vector2(float(TA_SC_TEXT[0]) + float(TA_SC_TEXT[2]) / 2.0, float(TA_SC_TEXT[1]))
		_track_spots("dh", TA_DH_CARDS, TA_DH_CARD_Y)
	elif tab == 0:
		_track_spots("tn", TA_DH_CARDS, TA_TN_CARD_Y)
	elif tab == 4 or tab == 5:
		_track_spots("rc" if tab == 4 else "sp", TA_RC_CARDS, TA_RC_CARD_Y)
	elif tab == 2 and not qs.is_empty():
		var opts: Array = qs[q_at]["a"]
		for j in mini(opts.size(), 4):
			_spots["a:%d" % j] = Vector2(float(TA_DV_ANS[j * 2]) + 107.0, float(TA_DV_ANS[j * 2 + 1]) + 30.5)
	elif tab == 3:
		var feat: Variant = featured()
		if feat != null:
			_spots["g:" + str(feat["id"])] = Vector2(float(TA_FEAT_ART[0]) + float(TA_FEAT_ART[2]) / 2.0, float(TA_FEAT_ART[1]) + float(TA_FEAT_ART[3]) / 2.0)
		var list: Array = grid()
		var n: int = 0
		var i: int = page * 8
		while i < list.size() and n < 8:
			_spots["g:" + str(list[i]["id"])] = Vector2(float(TA_GRID_X[n % 4]) + float(TA_CARD_WELL[0]), float(TA_GRID_Y[n / 4]) + float(TA_CARD_WELL[1]))
			n += 1
			i += 1

func _track_spots(key: String, cards: Array, card_y: float) -> void :
	var list: Array = tracks[key]["list"] if tracks.has(key) else []
	for i in mini(list.size(), cards.size()):
		_spots["m:%s:%d" % [key, int(float(list[i]["need"]))]] = Vector2(float(cards[i]) + float(TA_MS_WELL[0]), card_y + float(TA_MS_WELL[1]))


func _anim() -> void :
	if not opened:
		return
	if _b_ready:
		_ambient_tick()
	if not _teddy_key.is_empty() and _b_ready and tick % 10 == 0:
		_teddy_b = thank_at > tick or (_teddy_key == "teddy" and tick % 200 < 20)
	_glow_a = 0.55 + 0.45 * sin(float(tick) * 0.12)
	if show_fl != flowers and flowers >= 0:
		var k: int = flowers - show_fl
		show_fl += maxi(1, int(float(k) / 6.0)) if k > 0 else mini(-1, int(float(k) / 6.0))
	var total: int = int(float(school["total"]))
	if show_sc != total:
		var k: int = total - show_sc
		show_sc += maxi(1, int(float(k) / 8.0)) if k > 0 else mini(-1, int(float(k) / 8.0))
	if tick % 25 == 0:
		_time_line = time_line()
		_time_tip = time_tip()
	if tick % 150 == 0 or say_at == tick:
		_say_line = say_line()
	if advance_at > 0 and tick >= advance_at and not busy():
		advance_at = 0
		q_at = next_question(q_at)
		pick_q = -1
		pick = -1
		if tab == 2:
			_rebuild()


func _ambient_tick() -> void :
	if tick % 4 == 0:
		_dove_f = (_dove_f + 1) % 6 if tick % 140 < 48 else 0
	var k: int = tick % 320
	if k < 220 and tick % 5 == 0:
		_plane_f = (_plane_f + 1) % 4
	var every: int = maxi(6, int(160.0 / float(maxi(1, int(TA_PETALS[3])))))
	if int(TA_PETALS[3]) > 0 and tick % every == 0 and art("fx_petal") != null:
		fx_add("sheet", "fx_petal", Vector2(float(TA_PETALS[0]) + randf() * float(TA_PETALS[2]), float(TA_PETALS[1])), 
			{"f": int(randf() * 4.0), "tpf": 7, "loop": 1, "vy": 0.5 + randf() * 0.4, "vx": (randf() - 0.5) * 0.5, "vr": (randf() - 0.5) * 2.0, 
			"life": 200, "fade": 40, "layer": "amb"})




func sparkles(at: Vector2, count: int) -> void :
	if art("fx_sparkle") == null:
		return
	for i in count:
		fx_add("sheet", "fx_sparkle", at + Vector2((randf() - 0.5) * 50.0, (randf() - 0.5) * 40.0), {"tpf": 2, "vy": -0.6})


func float_text(text: String, color: Color, at: Vector2) -> void :
	var fx: Dictionary = fx_add("text", "", at, {"vy": -0.9, "life": 40, "fade": 14})
	fx["text"] = text
	fx["color"] = color


func fly_token(from: Vector2, to: Vector2, order: int) -> void :
	if art("token_24") == null:
		return
	fx_add("pic", "token_24", from, {"tx": to.x, "ty": to.y, "ts": 0.8, "life": 20 + order * 4})

func wallet_at() -> Vector2:
	return TA_WALLET + TA_WALLET_TOKEN + Vector2(12, 12)


func pop_item(id: int, at: Vector2) -> void :
	fx_add("icon", "", at, {"id": id, "side": 56.0, "tx": at.x, "ty": at.y - 70.0, "ts": 1.3, "life": 34, "fade": 12})


func petal_burst(at: Vector2, count: int) -> void :
	if art("fx_petal") == null:
		return
	for i in count:
		fx_add("sheet", "fx_petal", Vector2(at.x + (randf() - 0.5) * 16.0, at.y), {"f": i, "tpf": 4, "loop": 1, "vx": (randf() - 0.5) * 4.0, 
			"vy": -2.0 - randf() * 2.5, "g": 0.14, "vr": (randf() - 0.5) * 12.0, "life": 46, "fade": 16})


func chalk_puff(at: Vector2) -> void :
	if art("fx_chalk") == null:
		return
	fx_add("sheet", "fx_chalk", at, {"tpf": 3, "vy": -0.3})


func play_fx(kind: String, items: Array, old_tracks: Dictionary, old_fl: int, old_sc: int, what: String, answer: Variant) -> void :
	show_fl = maxi(0, old_fl)
	show_sc = old_sc
	if what.begins_with("claim:"):
		var key: String = what.substr(6)
		var old_list: Array = old_tracks[key]["list"] if old_tracks.has(key) else []
		var new_list: Array = tracks[key]["list"] if tracks.has(key) else []
		var n: int = 0
		for m: Dictionary in new_list:
			if int(m["s"]) != 2:
				continue
			var was: Variant = null
			for row: Dictionary in old_list:
				if float(row["need"]) == float(m["need"]):
					was = row
			if was == null or int(was["s"]) == 2:
				continue
			var spot: String = "m:%s:%d" % [key, int(float(m["need"]))]
			if _spots.has(spot):
				var at: Vector2 = _spots[spot]
				sparkles(at, 3)
				if not (m["items"] as Array).is_empty():
					pop_item(int(m["items"][0]["id"]), at)
				var i: int = 0
				while int(m["fl"]) > 0 and i < mini(4, 1 + int(float(int(m["fl"])) / 10.0)):
					fly_token(at + Vector2((randf() - 0.5) * 30.0, -30.0 + (randf() - 0.5) * 20.0), wallet_at(), n + i)
					i += 1
				n += 1
	elif what.begins_with("buy:"):
		var spot: String = "g:" + what.substr(4)
		if _spots.has(spot):
			var at: Vector2 = _spots[spot]
			sparkles(at, 3)
			for row: Dictionary in items:
				pop_item(int(row["id"]), at)
	elif what == "offer":
		var given: int = maxi(0, old_fl - flowers)
		if _spots.has("qty"):
			var at: Vector2 = _spots["qty"]
			for i in mini(6, 1 + int(float(given) / 20.0)):
				fly_token(Vector2(at.x + (randf() - 0.5) * 30.0, at.y), TA_VASE, i)
		petal_burst(TA_VASE, 8)
		sparkles(TA_VASE - Vector2(0, 20), 2)
		thank_at = tick + 110
		say_text = "Cảm ơn em nhiều lắm! Thầy vui quá~"
		say_at = tick + 110
		_say_line = say_line()
		_teddy_b = true
		var total: int = int(float(school["total"]))
		if _spots.has("sc") and total > old_sc:
			var to: Vector2 = _spots["sc"]
			float_text("+" + num(total - old_sc), TA_GOLD, to - Vector2(0, 6))
	if answer != null:
		if bool(answer["ok"]):
			thank_at = tick + 90
			_teddy_b = true
			var spot: String = "a:%d" % int(answer["c"])
			if _spots.has(spot):
				var at: Vector2 = _spots[spot]
				sparkles(at, 4)
				float_text("+%d hoa" % int(answer["gain"]), TA_GOLD, at - Vector2(0, 30))
				for i in mini(4, int(answer["gain"])):
					fly_token(Vector2(at.x + (randf() - 0.5) * 40.0, at.y), wallet_at(), i)
			if bool(answer["perfect"]):
				for i in 5:
					sparkles(Vector2(float(TA_DV_PIPS[0]) + float(i) * float(TA_DV_PIPS[2]), float(TA_DV_PIPS[1])), 1)
		else:
			var spot: String = "a:%d" % pick
			if _spots.has(spot):
				chalk_puff(_spots[spot])
	if flowers > old_fl and old_fl >= 0:
		float_text("+" + num(flowers - old_fl), TA_GOLD, TA_FLOAT_AT)
	elif flowers < old_fl and flowers >= 0:
		float_text("-" + num(old_fl - flowers), TA_SHORT, TA_FLOAT_AT)

func _draw_fx(at: Vector2, layer: String) -> void :
	super (at, layer)
	for fx: Dictionary in _fx:
		if str(fx["layer"]) == layer and str(fx["kind"]) == "text":
			var alpha: float = float(fx["alpha"])
			_dbtext(at + Vector2(float(fx["x"]) - 90.0, float(fx["y"]) - 12.0), 180.0, 24.0, 16.0, Color(fx["color"], alpha), Color(TA_INK, alpha), 
				"center", str(fx["text"]))




func _dbtext(at: Vector2, w: float, h: float, px: float, color: Color, glow: Color, align: String, text: String) -> float:
	var size: float = px
	while size > 7.0 and text_width(text, size) > w - 4.0:
		size -= 0.5
	return super (at, w, h, size, color, glow, align, text)



func _para(at: Vector2, w: float, h: float, px: float, color: Color, glow: Color, text: String, align: String = "center", least: float = 8.0) -> void :
	var size: float = px
	var lines: Array = _wrap(text, w, size)
	while size > least and (_block_h(lines.size(), size) - 6.0 > h or _widest(lines, size) > w - 4.0):
		size -= 0.5
		lines = _wrap(text, w, size)
	var step: float = roundf(size * 1.15) - 1.0
	var high: float = _block_h(lines.size(), size)
	var top: float = at.y + float(int((h - high) / 2.0))
	var x: float = at.x + (2.0 if align == "left" else 0.0)
	for i in lines.size():
		_fwords(str(lines[i]), ARIAL_BOLD, size, color, align.substr(0, 1), Vector2(x, top + float(i) * step), w, 2.0 if glow.a > 0.0 else 0.0, 0.0, false, glow)

static func _block_h(count: int, px: float) -> float:
	return (roundf(px * 1.15) - 1.0) * float(count) + 1.0 + 6.0

func _widest(lines: Array, px: float) -> float:
	var wide: float = 0.0
	for line: String in lines:
		wide = maxf(wide, text_width(line, px))
	return wide

func _wrap(text: String, w: float, px: float) -> Array:
	var lines: Array = []
	for chunk: String in text.split("\n"):
		var line: String = ""
		for word: String in chunk.split(" "):
			var next: String = word if line.is_empty() else line + " " + word
			if not line.is_empty() and text_width(next, px) > w - 4.0:
				lines.append(line)
				line = word
			else:
				line = next
		lines.append(line)
	return lines


func _card_name(corner: Vector2, text: String, color: Color) -> void :
	var x: float = float(TA_CARD_NAME[0]) - 4.0
	var w: float = float(TA_CARD_NAME[2]) + 8.0
	var size: float = 11.0
	while size > 9.0 and text_width(text, size) > w - 4.0:
		size -= 0.5
	if text_width(text, size) <= w - 4.0 or not text.contains(" "):
		_dbtext(corner + Vector2(x, float(TA_CARD_NAME[1])), w, float(TA_CARD_NAME[3]), size, color, NONE, "center", text)
		return
	var words: PackedStringArray = text.split(" ")
	var best: int = 1
	var best_w: float = INF
	for cut in range(1, words.size()):
		var wide: float = maxf(text_width(" ".join(words.slice(0, cut)), 10.0), text_width(" ".join(words.slice(cut)), 10.0))
		if wide < best_w:
			best_w = wide
			best = cut
	var top: float = float(TA_CARD_NAME[1]) + 2.5
	for k in 2:
		var line: String = " ".join(words.slice(0, best)) if k == 0 else " ".join(words.slice(best))
		_dbtext(corner + Vector2(x, top + float(k) * 12.0), w, 14.0, 10.0, color, NONE, "center", line)


func _tbox(base: Vector2, box: Array, px: float, color: Color, glow: Color, align: String, text: String) -> void :
	_dbtext(base + Vector2(float(box[0]), float(box[1])), float(box[2]), float(box[3]), px, color, glow, align, text)

func _tpara(base: Vector2, box: Array, px: float, color: Color, glow: Color, text: String, align: String = "center") -> void :
	_para(base + Vector2(float(box[0]), float(box[1])), float(box[2]), float(box[3]), px, color, glow, text, align)


func _dot(centre: Vector2) -> void :
	draw_circle(centre * _f, 5.5 * _f, TA_DOT)
	draw_arc(centre * _f, 5.5 * _f, 0.0, TAU, 24, Color.WHITE, 1.5 * _f, true)


func _cut(name: String, at: Vector2, cut: float) -> void :
	var full: Texture2D = art(name)
	if full == null:
		return
	var w: float = minf(float(full.get_width()), maxf(1.0, cut))
	draw_texture_rect_region(full, Rect2(at * _f, Vector2(w, float(full.get_height())) * _f), Rect2(0, 0, w, float(full.get_height())))


func _sheet_c(name: String, frame: int, centre: Vector2, deg: float = 0.0, alpha: float = 1.0) -> void :
	var texture: Texture2D = art(name)
	if texture == null or not sheets.has(name):
		return
	var cell: Vector2 = Vector2(float(sheets[name][0]), float(sheets[name][1]))
	draw_set_transform(centre * _f, deg_to_rad(deg), Vector2.ONE)
	draw_texture_rect_region(texture, Rect2( - Vector2(float(int(cell.x / 2.0)), float(int(cell.y / 2.0))) * _f, cell * _f), sheet_region(name, frame), Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)



func _body(at: Vector2) -> void :
	if not _b_ready:

		_round(Rect2((at + Vector2(0, 60)) * _f, Vector2(win_size.x, win_size.y - 60.0) * _f), Color(SHADOW, 0.96), 12.0, Color(1, 1, 1, 0.35), 1.0)
		_dbtext(at + Vector2(0, 280), win_size.x, 30.0, 14.0, Color.WHITE, NONE, "center", 
			"Không tải được giao diện, hãy thử lại." if _b_failed else "Đang tải...")
		return
	pic("ta_bg", at)
	_draw_fx(at, "amb")
	match tab:
		0:
			_grades(at)
		1:
			_offer(at)
		2:
			_quiz(at)
		3:
			_shop(at)
		_:
			_spend(at, "rc" if tab == 4 else "sp")
	_tabs(at)
	_chips(at)
	_ambient(at)
	if art("btn_close_st") != null:
		art_button("close", "btn_close_st", at + TA_CLOSE, 1)


func _chrome(at: Vector2) -> void :
	if not _b_ready or art("btn_close_st") == null:
		var cell: Vector2 = _cell_size("public_button_close")
		_fbutton("close", "public_button_close", at + Vector2(win_size.x - 20.0 - cell.x, 78.0))


func _tabs(at: Vector2) -> void :
	for i in 6:
		var corner: Vector2 = at + Vector2(float(TA_TABS[i * 2]), float(TA_TABS[i * 2 + 1]))
		var key: String = str(TA_TAB_KEYS[i])
		var id: String = "tab:%d" % i
		if i != tab and _hover == id and _press.is_empty() and not _mobile:
			pic("tab_hover_glow", corner + TA_TAB_GLOW)
		pic("tab_selected" if i == tab else "tab_normal", corner)
		pic("tabicon_" + key, corner + TA_TAB_ICON)
		pic("tablabel_" + key, corner + TA_TAB_LABEL)
		var dot: int = 0
		if key == "bd":
			dot = claimable("tn")
		elif key == "dv":
			dot = quiz_left()
		elif key != "shop":
			dot = claimable(key)
		if dot > 0:
			_dot(corner + TA_TAB_DOT)
		if i != tab:
			_hit(id, Rect2((corner + TA_TAB_HIT.position) * _f, TA_TAB_HIT.size * _f), false)


func _chips(at: Vector2) -> void :
	var corner: Vector2 = at + TA_WALLET
	pic("chip_wallet", corner)
	pic("token_24", corner + TA_WALLET_TOKEN)
	_tbox(corner, TA_WALLET_TEXT, 15.0, TA_CREAM, TA_INK, "center", wallet_text())
	tip_area(Rect2(corner, Vector2(float(TA_WALLET_TEXT[0]) + float(TA_WALLET_TEXT[2]), float(TA_WALLET_TEXT[1]) * 2.0 + float(TA_WALLET_TEXT[3]))), flower_id, "")
	corner = at + TA_TIME
	pic("chip_time", corner)
	_tbox(corner, TA_TIME_TEXT, 13.0, TA_CREAM, TA_INK, "center", _time_line)
	tip_area(Rect2(corner, Vector2(float(TA_TIME_TEXT[0]) + float(TA_TIME_TEXT[2]), float(TA_TIME_TEXT[1]) * 2.0 + float(TA_TIME_TEXT[3]))), 0, _time_tip)


func _ambient(at: Vector2) -> void :
	_sheet_c("fx_dove", _dove_f, at + Vector2(TA_DOVE.x, TA_DOVE.y + 1.5 * sin(float(tick) * 0.06)))
	var k: int = tick % 320
	if k < 220:
		var t: float = float(k) / 220.0
		var x: float = float(TA_PLANE[0]) + float(TA_PLANE[2] - TA_PLANE[0]) * t
		var y: float = float(TA_PLANE[1]) + float(TA_PLANE[3] - TA_PLANE[1]) * t + 5.0 * sin(float(k) * 0.07)
		_sheet_c("fx_plane", _plane_f, at + Vector2(x, y), 6.0 * cos(float(k) * 0.07), minf(1.0, float(mini(k, 220 - k)) / 20.0))


func _teddy(at: Vector2) -> void :
	var name: String = _teddy_key + ("_b" if _teddy_b and art(_teddy_key + "_b") != null else "_a")
	pic(name, at)


func _track(at: Vector2, key: String, vine: String, origin: Vector2, nodes: Array, bar: Array, cards: Array, card_y: float) -> void :
	var track: Variant = tracks.get(key)
	var list: Array = track["list"] if track != null else []
	var total: float = float(track["total"]) if track != null else 0.0
	var is_busy: bool = busy()
	pic(vine + "_off", at + origin)
	_cut(vine + "_on", at + origin, maxf(1.0, bar_x(list, total, nodes, bar)))
	for i in mini(list.size(), cards.size()):
		_card(at, key, list[i], total, float(cards[i]), card_y, is_busy)


func _card(at: Vector2, key: String, m: Dictionary, total: float, x: float, y: float, is_busy: bool) -> void :
	var st: int = int(m["s"])
	var card: Vector2 = at + Vector2(x, y)
	var well: Vector2 = card + Vector2(float(TA_MS_WELL[0]), float(TA_MS_WELL[1]))
	var side: float = float(TA_MS_WELL[2])
	var need: float = float(m["need"])
	if st == 1:
		pic("ms_glow", card + TA_MS_GLOW, _glow_a)
	pic("ms_card_off" if st == 0 else "ms_card", card, 0.85 if st == 2 else 1.0)
	var line: String = need_text(key, need)
	_tbox(card, TA_MS_NEED, 11.0 if line.length() > 8 else 13.0, TA_DIM if st == 0 else TA_NEED, NONE, "center", line)
	var items: Array = m["items"]
	var fl: int = int(m["fl"])
	var shown_id: int = int(items[0]["id"]) if not items.is_empty() else (flower_id if fl > 0 else 0)
	var shown_n: int = int(items[0]["n"]) if not items.is_empty() else fl
	if shown_id > 0:
		icon(shown_id, side, well, 0.6 if st == 0 else 1.0)
		if shown_n > 1:
			_dbtext(well + Vector2( - side / 2.0, side / 2.0 - 15.0), 60.0, 16.0, 12.0, TA_DIM if st == 0 else TA_INK_TEXT, TA_CREAM, "right", "x" + num(shown_n))
		tip_area(Rect2(well - Vector2(side, side) / 2.0, Vector2(side, side)), shown_id, "")
	if not items.is_empty() and fl > 0:
		pic("token_24", card + TA_MS_TOKEN)
		_tbox(card, TA_MS_FLN, 13.0, TA_DIM if st == 0 else TA_INK_TEXT, NONE, "left", "x" + num(fl))
		tip_area(Rect2(card + TA_MS_TOKEN, Vector2(24, 24)), flower_id, "")
	if st == 1:
		art_button("claim:%s:%d" % [key, int(need)], "btn_nhan_st", card + Vector2(float(TA_MS_BTN[0]), float(TA_MS_BTN[1])), 0 if is_busy else 1)
	elif st == 2:
		pic("stamp_danhan", card + TA_MS_STAMP)
		pic("ms_check", card + TA_MS_CHECK)
	else:
		pic("ms_lock", card + TA_MS_LOCK)
		if need > total:
			_dbtext(card + Vector2(1, float(TA_MS_BTN[1])), 82.0, float(TA_MS_BTN[3]), 11.0, TA_DIM, NONE, "center", "Còn " + num(int(need - total)))


func _grades(at: Vector2) -> void :
	pic("bd_card", at + TA_BD_CARD)
	var grades: Array = day.get("grades", [])
	var from: int = maxi(0, grades.size() - 8)
	for k in 8:
		var centre: Vector2 = at + Vector2(float(TA_BD_SLOTS[k * 2]), float(TA_BD_SLOTS[k * 2 + 1]))
		var g: int = int(grades[from + k]) if from + k < grades.size() else 0
		pic_c("stamp_%d" % g if g > 0 else "stamp_slot", centre)
	_tbox(at, TA_BD_TODAY, 15.0, TA_NEED, NONE, "center", 
		("Hôm nay: +%d / %d hoa" % [int(day.get("got", 0)), int(day.get("cap", 0))]) if earning else "Mùa chấm điểm đã kết thúc")
	_tbox(at, TA_BD_SUB, 12.0, TA_INK_TEXT, NONE, "center", "Đã chấm %d trận hôm nay" % int(day.get("matches", 0)))
	pic("bd_rules", at + TA_BD_RULES)
	var rows: Array = ["Thắng + MVP hoặc ≥%d hạ gục: +%d hoa" % [int(pay["kills"]), int(pay["g10"])], "Thắng trận: +%d hoa" % int(pay["g9"]), 
		"Thua nhưng MVP hoặc ≥%d hạ gục: +%d hoa" % [int(pay["kills"]), int(pay["g8"])], "Thua trận: +%d hoa" % int(pay["g7"])]
	var row_h: float = float(TA_BD_RULE[3])
	for i in 4:
		var stamp: Texture2D = art("stamp_%d" % (10 - i))
		var y: float = float(TA_BD_RULE[1]) + float(i) * row_h
		if stamp != null:
			var k: float = minf(1.0, minf(float(TA_BD_RULE[2]) / float(stamp.get_width()), row_h / float(stamp.get_height())))
			var size: Vector2 = Vector2(stamp.get_size()) * k
			var corner: Vector2 = at + Vector2(float(TA_BD_RULE[0]) + (float(TA_BD_RULE[2]) - size.x) / 2.0, y + (row_h - size.y) / 2.0)
			draw_texture_rect(stamp, Rect2(corner * _f, size * _f), false)
		_dbtext(at + Vector2(float(TA_BD_RULE_TEXT[0]), y), float(TA_BD_RULE_TEXT[2]), float(TA_BD_RULE_TEXT[3]), 13.0, TA_CREAM, TA_INK, "left", str(rows[i]))
	_tpara(at, TA_BD_FOOT, 11.0, TA_INK_TEXT, NONE, "Trận từ %d giây, tối đa %d hoa mỗi ngày. Trận có bot tối đa điểm %d; Phụ Bản thắng điểm %d, thua điểm %d."
		%[int(pay["min"]), int(day.get("cap", 0)), int(pay["bot"]), int(pay["pw"]), int(pay["pl"])], "left")
	var head: Vector2 = at + TA_TN_HEAD
	pic("tn_head", head)
	var tn: Variant = tracks.get("tn")
	_tbox(head, TA_TN_HEAD_TEXT, 14.0, TA_CREAM, TA_INK, "center", "Đã có %d điểm 10" % int(float(tn["total"]) if tn != null else 0.0))
	_track(at, "tn", "vine", TA_TN_VINE, TA_DH_NODES, TA_DH_BAR, TA_DH_CARDS, TA_TN_CARD_Y)


func _offer(at: Vector2) -> void :
	var step: int = maxi(1, int(offer["step"]))
	var top: int = qty_top()
	var is_busy: bool = busy()
	_teddy(at + TA_TEDDY)
	pic("desk", at + TA_DESK)
	pic("bubble", at + TA_BUBBLE)
	_tpara(at + TA_BUBBLE, TA_BUBBLE_TEXT, 12.0, TA_INK_TEXT, NONE, _say_line)
	pic("qty_plate", at + TA_QTY_PLATE)
	_tbox(at + TA_QTY_PLATE, TA_QTY_TEXT, 20.0, TA_SHORT if flowers >= 0 and flowers < qty else TA_QTY, NONE, "center", num(qty))
	art_button("qty:-1", "btn_minus_st", at + TA_QTY_MINUS, 1 if qty > step else -1)
	art_button("qty:1", "btn_plus_st", at + TA_QTY_PLUS, 1 if qty + step <= top else -1)
	art_button("offer", "btn_danghoa_st", at + TA_OFFER_BTN, (0 if is_busy else 1) if earning else -1)
	pic("school_head", at + TA_SC_HEAD)
	pic("ruler_empty", at + TA_RULER)
	_cut("ruler_full", at + TA_RULER, maxf(1.0, ruler_x(float(show_sc))))
	var total: float = float(int(float(school["total"])))
	for m: Dictionary in school["list"]:
		var need: float = float(m["need"])
		var gift: Vector2 = Vector2(float(TA_RULER.x) + ruler_x(need), TA_RULER.y + TA_RULER_GIFT_Y)
		pic_c("gift_on" if total >= need else "gift_off", at + gift)
		var state: String = ""
		if int(m["s"]) == 2:
			state = "Đã nhận (gửi vào túi)."
		elif total >= need:
			state = "Đã đạt, quà đang được gửi." if bool(school["ok"]) else "Đã đạt: dâng từ %s hoa để nhận quà mốc này." % num(int(school["min"]))
		else:
			state = "Cả trường còn thiếu %s hoa." % num(int(need - total))
		tip_area(Rect2(at + gift - Vector2(18, 18), Vector2(36, 36)), 0, "Mốc Cả trường " + num(int(need)) + " hoa: " + reward_text(m) + "\n" + state)
	_tbox(at, TA_SC_TEXT, 15.0, TA_CREAM, TA_INK, "center", num(show_sc) + " / " + num(school_top()))
	var sub: String = "Quà mốc Cả trường gửi thẳng vào túi."
	var tone: Color = TA_SOFT
	var dbl: String = str(offer["double"])
	if int(offer["mult"]) > 1:
		sub = "Hôm nay 20/11: mỗi bông dâng tính %d vào thanh Cả trường!" % int(offer["mult"])
		tone = TA_GOLD
	elif not bool(school["ok"]):
		sub = "Dâng từ %s hoa để nhận quà các mốc Cả trường." % num(int(school["min"]))
	elif not dbl.is_empty() and today < dbl:
		sub = "Ngày 20/11: mỗi bông dâng tính 2."
	_tbox(at, TA_SC_SUB, 12.0, tone, TA_INK, "center", sub)
	var head: Vector2 = at + TA_DH_HEAD
	pic("ms_head", head)
	_tbox(head, TA_DH_HEAD_TEXT, 14.0, TA_CREAM, TA_INK, "center", "Đã dâng " + num(int(offer["offered"])))
	_track(at, "dh", "vine", TA_DH_VINE, TA_DH_NODES, TA_DH_BAR, TA_DH_CARDS, TA_DH_CARD_Y)


func _quiz(at: Vector2) -> void :
	_teddy(at + TA_DV_TEDDY)
	pic("dv_board", at + TA_DV_BOARD)
	var qs: Array = quiz.get("qs", [])
	if qs.is_empty():
		_tpara(at, TA_DV_Q, 18.0, TA_CHALK, TA_INK, "Câu đố hôm nay đang được Thầy Teddy chuẩn bị, quay lại sau nhé!" if earning
			else "Đố Vui đã kết thúc. Cảm ơn các em đã tham gia!")
		return
	var n: int = qs.size()
	var cur: int = clampi(q_at, 0, n - 1)
	var is_busy: bool = busy()
	for i in mini(n, 5):
		var centre: Vector2 = at + Vector2(float(TA_DV_PIPS[0]) + float(i) * float(TA_DV_PIPS[2]), float(TA_DV_PIPS[1]))
		var s: String = str(qs[i]["s"])
		if i == cur:
			pic("dv_pip_on_glow", centre - Vector2(32, 32))
		pic_c("dv_pip_right" if s == "1" else ("dv_pip_wrong" if s == "0" else ("dv_pip_on" if i == cur else "dv_pip_off")), centre)
		_dbtext(centre + Vector2(-12, -10), 24.0, 20.0, 12.0, TA_CREAM, TA_INK, "center", str(i + 1))
		if i != cur:
			_hit("q:%d" % i, Rect2((centre - Vector2(36.5, 36.5)) * _f, Vector2(73, 73) * _f), false)
	var q: Dictionary = qs[cur]
	_tpara(at, TA_DV_Q, 16.0, TA_CHALK, TA_INK, "Câu %d/%d: %s" % [cur + 1, n, str(q["t"])])
	var opts: Array = q["a"]
	var answered: bool = str(q["s"]) != "-"
	var qi: int = int(q["i"])
	var c: int = int(q["c"])
	for j in mini(opts.size(), 4):
		var corner: Vector2 = at + Vector2(float(TA_DV_ANS[j * 2]), float(TA_DV_ANS[j * 2 + 1]))
		var alpha: float = 1.0
		var frame: int = 0
		if answered:
			alpha = 1.0 if j == c else 0.6
			sheet("btn_ans_st", 0, corner, alpha)
		else:
			var state: int = 0 if is_busy else 1
			var picked: bool = is_busy and pick_q == qi and pick == j
			frame = int(art_button("a:%d:%d" % [qi, j], "btn_ans_st", corner, state, 2 if picked else -1)[1])
			if is_busy:
				alpha = 0.75
		var face: Vector2 = corner + Vector2(0, 1.0 if frame == 2 else 0.0)
		_tpara(face, TA_DV_ANS_TEXT, 13.0, Color(TA_INK_TEXT, alpha), NONE, "ABCD".substr(j, 1) + ". " + str(opts[j]))
		if answered:
			if j == c:
				pic("ans_right", corner + TA_DV_MARK)
			elif pick_q == qi and pick == j:
				pic("ans_wrong", corner + TA_DV_MARK, alpha)
	_tbox(at, TA_DV_INFO, 13.0, TA_CREAM, TA_INK, "center", "Hôm nay đúng %d/%d câu · mỗi câu đúng +%d hoa" % [int(quiz.get("right", 0)), n, int(quiz.get("pay", 0))])
	_tbox(at, TA_DV_SUB, 11.0, TA_SOFT, TA_INK, "center", "Đúng cả 5 câu: thêm +%d hoa và 1 điểm 10. Câu hỏi mới mỗi ngày." % int(quiz.get("bonus", 0)))


func _shop(at: Vector2) -> void :
	var feat: Variant = featured()
	var list: Array = grid()
	var count: int = pages()
	var is_busy: bool = busy()
	pic("shop_sign", at + TA_SIGN)
	if feat != null:
		_featured(at, feat, is_busy)
	var n: int = 0
	var i: int = page * 8
	while i < list.size() and n < 8:
		_goods(at, list[i], Vector2(float(TA_GRID_X[n % 4]), float(TA_GRID_Y[n / 4])), is_busy)
		n += 1
		i += 1
	if count > 1:
		art_button("page:-1", "arrow_l_st", at + Vector2(float(TA_ARROWS[0]), float(TA_ARROWS[1])), 1 if page > 0 else -1)
		art_button("page:1", "arrow_r_st", at + Vector2(float(TA_ARROWS[2]), float(TA_ARROWS[3])), 1 if page < count - 1 else -1)
		var dots: float = float(TA_DOTS[0]) - float(count - 1) * float(TA_DOTS[2]) / 2.0
		for d in count:
			pic("dot_on" if d == page else "dot_off", at + Vector2(dots + float(d) * float(TA_DOTS[2]) - float(TA_DOTS[3]), float(TA_DOTS[1])))


func _featured(at: Vector2, g: Dictionary, is_busy: bool) -> void :
	var left: bool = goods_left(g)
	var goods_name: String = item_name(int(g["item"]))
	var box: Rect2 = Rect2(at + Vector2(float(TA_FEAT_ART[0]), float(TA_FEAT_ART[1])), Vector2(float(TA_FEAT_ART[2]), float(TA_FEAT_ART[3])))
	pic("feat_card", at + TA_FEAT)
	if art("feat_art") != null:
		pic("feat_art", box.position, 1.0 if left else 0.55)
	else:
		icon(int(g["item"]), 96.0, box.get_center(), 1.0 if left else 0.55)
	tip_area(box, int(g["item"]), "")
	pic("ribbon_hot", at + TA_FEAT_HOT)
	_tpara(at, TA_FEAT_NAME, 15.0, TA_NEED, NONE, (goods_name if not goods_name.is_empty() else "Quà đặc biệt") + (" x%d" % int(g["n"]) if int(g["n"]) > 1 else ""))
	var price: Vector2 = at + TA_FEAT_PRICE
	pic("price_l", price)
	pic("token_24", price + TA_PRICE_L_TOKEN)
	_tbox(price, TA_PRICE_L_TEXT, 15.0, TA_INK_TEXT if afford(g) else TA_NEED, NONE, "center", num(int(g["price"])))
	_tbox(at, TA_FEAT_STOCK, 12.0, TA_INK_TEXT, NONE, "center", stock(g))
	art_button("buy:" + str(g["id"]), "btn_doi_l_st", at + TA_FEAT_BTN, (0 if is_busy else 1) if left else -1)
	if not left:
		pic("stamp_het", at + TA_FEAT_STAMP)


func _goods(at: Vector2, g: Dictionary, cell: Vector2, is_busy: bool) -> void :
	var left: bool = goods_left(g)
	var corner: Vector2 = at + cell
	var centre: Vector2 = corner + Vector2(float(TA_CARD_WELL[0]), float(TA_CARD_WELL[1]))
	var side: float = float(TA_CARD_WELL[2])
	pic("good_card" if left else "good_card_off", corner)
	icon(int(g["item"]), side, centre, 1.0 if left else 0.5)
	if int(g["n"]) > 1:
		_dbtext(centre + Vector2( - side / 2.0, side / 2.0 - 16.0), side + 4.0, 16.0, 12.0, TA_INK_TEXT, TA_CREAM, "right", "x%d" % int(g["n"]))
	tip_area(Rect2(centre - Vector2(side, side) / 2.0, Vector2(side, side)), int(g["item"]), "")
	_card_name(corner, item_name(int(g["item"])), TA_INK_TEXT if left else TA_DIM)
	var price: Vector2 = corner + TA_CARD_PRICE
	pic("price_s", price)
	pic("token_16", price + TA_PRICE_S_TOKEN)
	_tbox(price, TA_PRICE_S_TEXT, 13.0, TA_INK_TEXT if afford(g) or not left else TA_NEED, NONE, "center", num(int(g["price"])))
	_tbox(corner, TA_CARD_STOCK, 11.0, TA_DIM, NONE, "center", stock(g))
	art_button("buy:" + str(g["id"]), "btn_doi_s_st", corner + TA_CARD_BTN, (0 if is_busy else 1) if left else -1)
	if not left:
		pic("stamp_het", corner + TA_CARD_STAMP)


func _spend(at: Vector2, key: String) -> void :
	var track: Variant = tracks.get(key)
	var total: float = float(track["total"]) if track != null else 0.0
	var is_busy: bool = busy()
	pic("rc_scene", at + TA_RC_SCENE)
	var head: Vector2 = at + TA_RC_HEAD
	pic(key + "_head", head)
	_tbox(head, TA_RC_HEAD_TEXT, 16.0, TA_CREAM, TA_INK, "left", "Đã " + ("nạp" if key == "rc" else "tiêu") + " trong sự kiện: " + num(int(total)) + " Xu")
	_tbox(at, TA_RC_SUB, 12.0, TA_SOFT, TA_INK, "left", 
		(("Nạp Xu đạt mốc để nhận Hoa Điểm 10 và quà tri ân." if key == "rc" else "Tiêu Xu trong game đạt mốc để nhận Hoa Điểm 10 và quà tri ân.") if earning
			else "Sự kiện đã kết thúc: vẫn nhận được các mốc đã đạt."))
	art_button("claim:%s:all" % key, "btn_nhanhet_st", at + TA_RC_ALL, ((0 if is_busy else 1) if claimable(key) > 0 else -1))
	_track(at, key, "vine7", TA_RC_VINE, TA_RC_NODES, TA_RC_BAR, TA_RC_CARDS, TA_RC_CARD_Y)
