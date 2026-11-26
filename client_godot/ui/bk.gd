extends "tev_window.gd"











signal closed(note: String)

const BkAtlas = preload("bk_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const MB_POLL_TICKS: int = 120
const BK_TIP: String = "Hũ Mật"
const BK_ICON: String = "btn_humat"
const BK_WORD: String = "word_humat_t"
const BK_W: float = 960.0
const BK_H: float = 580.0
const BK_ART: Array = ["bank_bg", "jar7_empty", "jar7_full", "jar30_empty", "jar30_full", "jar90_empty", "jar90_full", "glow_ripe", "slot_empty", 
	"tag", "tag_ripe", "teddy_idle", "teddy_pour", "chip_gift", "detail_bg", "fx_sparkle", "fx_puff", "fx_shards", "bee", "fx_drop", "btn_care_st", 
	"tab_on_st", "tab_off_st", "term_on_st", "term_off_st", "btn_minus_st", "btn_plus_st", "chip_st", "btn_deposit_st", "btn_claim_st", 
	"btn_break_st", "confirm_bg", "confirm_teddy_raised", "confirm_teddy_strike", "btn_confirm_st", "btn_cancel_st", "btn_close_st"]
const BK_SHEETS: Dictionary = {
	"fx_sparkle": [48, 48, 3, 6], "fx_puff": [96, 64, 3, 6], "fx_shards": [32, 32, 4, 8], "bee": [40, 36, 2, 2], 
	"btn_care_st": [140, 42, 1, 4], "tab_on_st": [96, 36, 1, 4], "tab_off_st": [96, 36, 1, 4], "term_on_st": [96, 84, 1, 4], 
	"term_off_st": [96, 84, 1, 4], "btn_minus_st": [32, 34, 1, 4], "btn_plus_st": [32, 34, 1, 4], "chip_st": [64, 24, 1, 4], 
	"btn_deposit_st": [190, 46, 1, 4], "btn_claim_st": [130, 50, 1, 4], "btn_break_st": [130, 50, 1, 4], "btn_confirm_st": [150, 50, 1, 4], 
	"btn_cancel_st": [140, 50, 1, 4], "btn_close_st": [40, 40, 1, 4], 
}
const TERM_ART: Array = ["7", "30", "90"]
const JAR_W: float = 120.0
const JAR_H: float = 130.0
const JAR_FOOT: float = 128.0
const FILL: Array = [73, 127, 47, 127, 49, 127]
const STAMP_Y: Array = [96, 88, 85]
const BODY_Y: Array = [100, 89, 88]
const MOUTH: Array = [86, 106, 116]
const COL_X: Array = [176, 325, 470]
const ROW_Y: Array = [222, 375, 517]
const SLOT_W: float = 148.0
const SLOT_H: float = 150.0
const TAG: Vector2 = Vector2(-56, -2)
const TAG_L1: Array = [9, 10, 94, 15]
const TAG_L2: Array = [9, 24, 94, 11]
const HEX: Vector2 = Vector2(-42, -86)
const LIPS: Array = [91, 224, 461, 18, 91, 377, 461, 18, 91, 519, 461, 18]
const GLOW_CLIP: Array = [91, 104, 461, 121, 91, 242, 461, 136, 91, 395, 461, 125]
const GLOW_PAD: float = 18.0
const HINT_PAD: float = 14.0
const RULES: Array = [180, 10, 350, 90]
const TEDDY: Vector2 = Vector2(557, 78)
const CARE_BTN: Vector2 = Vector2(713, 121)
const CARE_LINE: Array = [716, 170, 140, 16]
const GIFT: Array = [752, 190, 88, 26]
const DIPPER: Vector2 = Vector2(570, 181)
const TAB_X: Array = [568, 665, 762]
const TAB_Y: float = 262.0
const TERM_Y: float = 300.0
const MINUS: Vector2 = Vector2(573, 389)
const FIELD: Array = [621, 393, 181, 24]
const PLUS: Vector2 = Vector2(821, 389)
const CHIP_X: Array = [582, 648, 714, 780]
const CHIP_Y: float = 426.0
const CHIP_LABEL: Array = ["Ít nhất", "1/4", "1/2", "Tối đa"]
const EST: Array = [580, 457, 264, 17, 475, 15]
const DEPOSIT: Vector2 = Vector2(619, 492)
const BAL: Array = [619, 540, 200, 17]
const DET: Vector2 = Vector2(300, 160)
const DET_JAR: Vector2 = Vector2(91, 175)
const DET_ROWS: Array = [200, 66, 28, 110]
const DET_CLAIM: Vector2 = Vector2(38, 182)
const DET_BREAK: Vector2 = Vector2(186, 182)
const DET_GLOW: Array = [10, 55, 18, 45, 145, 133]
const ASK: Array = [260, 150, 440, 280]
const ASK_TEDDY: Vector2 = Vector2(38, 46)
const ASK_JAR: Array = [158, 194, 0.75]
const ASK_ROWS: Array = [207, 76, 38.5, 178, 20]
const ASK_YES: Vector2 = Vector2(75, 205)
const ASK_NO: Vector2 = Vector2(230, 205)
const ASK_HIT: Vector2 = Vector2(164, 180)
const CLOSE: Vector2 = Vector2(861, 72)
const ASK_POP: Array = [0.8, 0.9, 0.98, 1.04, 1.03, 1.01, 1]
const ASK_HIT_MS: float = 260.0
const INK: Color = Color("3c2416")
const BK_CREAM: Color = Color("fff0ca")
const OUTLINE: Color = Color("5a2e10")
const BAD: Color = Color("c93226")
const RIPE_INK: Color = Color("35862b")
const WAIT_INK: Color = Color("79383f")
const HONEY: Color = Color("ffd05a")
const VEIL_DET: Color = Color("221000")
const VEIL_ASK: Color = Color("120c10")
const ICON_GOLD: String = "l/c/money.webp"
const ICON_CASH: String = "l/c/coupon.webp"
const ICON_SILVER: String = "l/c/diamond.webp"

static var s_bk_shown: bool = false
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 5
var bk_visible: bool = false
var loaded: bool = false
var bk_name: String = "Hũ Mật"
var accepting: bool = false
var frozen: bool = false
var online: bool = false
var level: int = 0
var min_level: int = 0
var max_slots: int = 9
var care_bonus: float = 0.0
var cared: bool = false
var can_care: bool = false
var gift: String = ""
var token: String = ""
var curs: Array = []
var terms: Array = []
var jars: Array = []
var cur_id: String = ""
var term_d: int = 0
var amount: float = 0.0
var sel: int = -1
var ask: bool = false
var hit_at: float = 0.0
var ask_pop: int = 0
var pour_t: int = 0
var pop_slot: int = -1
var pop_t: int = 0
var later: Array = []
var due: bool = false
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _amount: LineEdit = null
var _b_ready: bool = false
var _b_failed: bool = false
var _b_busy: bool = false
var _b_tick: int = 0
var _b_cur: Variant = null
var _b_term: Variant = null
var _b_block: String = ""
var _b_dep: int = -1
var _b_ask: bool = false
var _views: Array = []
var _by_slot: Dictionary = {}
var _times: Array = []
var _det: Dictionary = {}
var _ask_view: Dictionary = {}
var _est: Array = ["", INK, "", WAIT_INK]
var _hint: bool = false

func _setup() -> void :
	art_dir = ""
	art_files = BK_ART
	sheets = BK_SHEETS
	win_size = Vector2(BK_W, BK_H)
	super ()

	_amount = _fedit(11, false)
	for key: String in ["font_color", "font_uneditable_color", "caret_color"]:
		_amount.add_theme_color_override(key, BK_CREAM)
	_amount.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	_amount.text_changed.connect(_on_amount_typed)
	_amount.focus_exited.connect(_on_amount_out)

static func reset_statics() -> void :
	s_bk_shown = false


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew

func amount_edit() -> LineEdit:
	return _amount


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 5
	bk_visible = false
	loaded = false
	bk_name = "Hũ Mật"
	accepting = false
	frozen = false
	online = false
	level = 0
	min_level = 0
	max_slots = 9
	care_bonus = 0.0
	cared = false
	can_care = false
	gift = ""
	token = ""
	curs = []
	terms = []
	jars = []
	cur_id = ""
	term_d = 0
	amount = 0.0
	sel = -1
	ask = false
	hit_at = 0.0
	ask_pop = 0
	pour_t = 0
	pop_slot = -1
	pop_t = 0
	later = []
	due = false
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(BkAtlas.FILE):
			_atlas = load(BkAtlas.FILE) as Texture2D
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
	if atlas == null or not BkAtlas.R.has(name):
		return null
	var row: Array = BkAtlas.R[name]
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = atlas
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part


func button_icon() -> Texture2D:
	return art(BK_ICON)

func button_word() -> Texture2D:
	return art(BK_WORD)




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/savings-bank.xml?t=" + str(int(now_ms())), "poll")


func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = MB_POLL_TICKS
		if not loading:
			poll()


func button_visible() -> bool:
	return bk_visible


func button_dot() -> bool:
	var ripe: bool = false
	for jar: Dictionary in jars:
		if is_ripe(jar):
			ripe = true
	return bk_visible and (ripe or (can_care and not cared and online and not frozen))


func busy() -> bool:
	return not action.is_empty() and action != "poll"

func ready_shown() -> bool:
	return _b_ready


func open() -> void :
	if opened or not bk_visible:
		return
	ask = false
	hit_at = 0.0
	sel = -1
	pour_t = 0
	pop_slot = -1
	later = []
	due = false
	show_window()
	load_art()
	_rebuild()
	if action.is_empty() or action == "poll":
		poll()


func close(note: String = "") -> void :
	if not opened:
		return
	hide_window()
	_hide_edits()
	ask = false
	hit_at = 0.0
	sel = -1
	_views = []
	_by_slot = {}
	_times = []
	_det = {}
	_ask_view = {}
	_b_ask = false
	later = []
	poll_in = MB_POLL_TICKS
	closed.emit(note)


func leave() -> void :
	close()

func _activate(id: String) -> void :
	if rules_click(id):
		return
	if id == "close":
		close()
	elif id == "care":
		on_care()
	elif id == "deposit":
		on_deposit()
	elif id == "claim":
		if sel >= 0:
			claim(str(sel))
	elif id == "break":
		on_break()
	elif id == "ask:yes":
		on_ask_yes()
	elif id == "ask:cancel" or id == "ask:veil":
		on_ask_no()
	elif id.contains(":"):
		on_pick(id)




func _failed(what: String) -> void :
	if what != "poll":
		tip("Không kết nối được máy chủ, hãy thử lại.")
	if opened:
		_rebuild()

func _num_of(at: Dictionary, key: String) -> float:
	return TevWheel.as_number(str(at.get(key, "")))


func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_xml(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	var old: Array = jars
	var notice: String = ""
	var fx: String = ""
	var parsed: bool = false
	if xml != null:
		var at: Dictionary = xml["at"]
		notice = str(at.get("notice", ""))
		fx = str(at.get("fx", ""))
		bk_visible = str(at.get("visible", "")) == "1"
		s_bk_shown = bk_visible
		if bk_visible:
			var got_curs: Array = []
			var got_terms: Array = []
			var got_jars: Array = []
			for node: Dictionary in kids(xml, "cur"):
				var c: Dictionary = node["at"]
				got_curs.append({"id": str(c.get("id", "")), "n": str(c.get("n", "")), "p": str(c.get("p", "")), "pn": str(c.get("pn", "")), 
					"min": _num_of(c, "min"), "max": _num_of(c, "max"), "total": _num_of(c, "total"), "used": _num_of(c, "used"), 
					"bal": _num_of(c, "bal")})
			for node: Dictionary in kids(xml, "term"):
				var t: Dictionary = node["at"]
				got_terms.append({"d": TevWheel.as_int(str(t.get("d", ""))), "r": _num_of(t, "r"), "n": str(t.get("n", ""))})
			for node: Dictionary in kids(xml, "jar"):
				var j: Dictionary = node["at"]
				got_jars.append({
					"id": TevWheel.as_int(str(j.get("id", ""))), "slot": TevWheel.as_int(str(j.get("slot", ""))), "c": str(j.get("c", "")), 
					"a": _num_of(j, "a"), "d": TevWheel.as_int(str(j.get("d", ""))), "r": _num_of(j, "r"), "p": str(j.get("p", "")), 
					"cd": TevWheel.as_int(str(j.get("cd", ""))), "ct": str(j.get("ct", "")) == "1", "ready": str(j.get("ready", "")) == "1", 
					"i": _num_of(j, "i"), "im": _num_of(j, "im"), "at": now_ms() + _num_of(j, "left") * 1000.0, 
				})
			bk_name = str(at.get("name", "")) if not str(at.get("name", "")).is_empty() else "Hũ Mật"
			accepting = str(at.get("open", "")) == "1"
			frozen = str(at.get("frozen", "")) == "1"
			online = str(at.get("online", "")) == "1"
			level = TevWheel.as_int(str(at.get("level", "")))
			min_level = TevWheel.as_int(str(at.get("minLevel", "")))
			max_slots = maxi(1, mini(9, TevWheel.as_int(str(at.get("max", "")))))
			care_bonus = _num_of(at, "careBonus")
			cared = str(at.get("cared", "")) == "1"
			can_care = str(at.get("canCare", "")) == "1"
			gift = str(at.get("gift", ""))
			token = str(at.get("token", ""))
			curs = got_curs
			terms = got_terms
			jars = got_jars
		else:
			jars = []
			can_care = false
		loaded = true
		parsed = true
	due = false
	if not parsed and what != "poll":
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if sel >= 0:
		var found: bool = false
		for jar: Dictionary in jars:
			if int(jar["id"]) == sel and not is_ripe(jar):
				found = true
		if not found:
			sel = -1
	if opened and not bk_visible:
		close()
	elif opened:
		_rebuild()
		if parsed and not fx.is_empty():
			play_fx(fx, old)
	if not notice.is_empty():
		tip(notice)




static func fmt(value: float) -> String:
	if is_nan(value):
		return "NaN"
	var digits: String = String.num(floorf(absf(value)), 0)
	var out: String = ""
	while digits.length() > 3:
		out = "." + digits.substr(digits.length() - 3) + out
		digits = digits.substr(0, digits.length() - 3)
	return ("-" if value < 0.0 else "") + digits + out


static func as_text(value: float) -> String:
	if is_nan(value):
		return "NaN"
	if value == floorf(value) and absf(value) < 1e+15:
		return str(int(value))
	return String.num(value)

static func pad(value: int) -> String:
	return ("0" if value < 10 else "") + str(value)

static func cur_icon(id: String) -> String:
	if id == "cashgold":
		return ICON_GOLD
	return ICON_CASH if id == "cash" else ICON_SILVER

func cur_name(id: String) -> String:
	for cur: Dictionary in curs:
		if str(cur["id"]) == id:
			return str(cur["n"])
	if id == "cashgold":
		return "Xu"
	return "Xu khóa" if id == "cash" else "Bạc"


func is_ripe(jar: Dictionary) -> bool:
	return bool(jar["ready"]) or float(jar["at"]) <= now_ms()


func term_art(d: int) -> int:
	for i in terms.size():
		if int(terms[i]["d"]) == d:
			return mini(2, i)
	return 0 if d <= 7 else (1 if d <= 30 else 2)


func left(jar: Dictionary) -> String:
	var secs: float = ceilf((float(jar["at"]) - now_ms()) / 1000.0)
	if bool(jar["ready"]) or secs <= 0.0:
		return "Đã chín"
	if is_nan(secs):
		secs = 0.0
	var dd: int = int(secs / 86400.0)
	if dd > 0:
		return str(dd) + " ngày " + pad(int(fmod(secs, 86400.0) / 3600.0)) + ":" + pad(int(fmod(secs, 3600.0) / 60.0))
	return pad(int(secs / 3600.0)) + ":" + pad(int(fmod(secs, 3600.0) / 60.0)) + ":" + pad(int(fmod(secs, 60.0)))


func fill_of(jar: Dictionary) -> float:
	var span: float = maxf(1.0, float(int(jar["d"])) * 86400000.0)
	if is_ripe(jar):
		return 1.0
	return maxf(0.12, minf(0.97, 1.0 - (float(jar["at"]) - now_ms()) / span))

static func slot_pos(i: int) -> Vector2:
	return Vector2(float(COL_X[i % 3]), float(ROW_Y[int(i / 3.0) % 3]))

static func jar_by_id(list: Array, id: int) -> Variant:
	for jar: Dictionary in list:
		if int(jar["id"]) == id:
			return jar
	return null


func bank_cur() -> Variant:
	for cur: Dictionary in curs:
		if str(cur["id"]) == cur_id:
			return cur
	if curs.size() > 0:
		cur_id = str(curs[0]["id"])
		return curs[0]
	return null


func bank_term() -> Variant:
	for term: Dictionary in terms:
		if int(term["d"]) == term_d:
			return term
	if terms.size() > 0:
		var term: Dictionary = terms[mini(1, terms.size() - 1)]
		term_d = int(term["d"])
		return term
	return null


static func bank_limit(cur: Dictionary) -> float:
	var lim: float = float(cur["max"])
	if float(cur["total"]) > 0.0:
		lim = minf(lim, float(cur["total"]) - float(cur["used"]))
	if float(cur["bal"]) >= 0.0:
		lim = minf(lim, float(cur["bal"]))
	return maxf(0.0, lim)


func bank_amount() -> float:
	var cur: Variant = bank_cur()
	if cur == null:
		return 0.0
	if amount <= 0.0:
		amount = float(cur["min"])
	return amount


func interest(a: float, term: Dictionary) -> Array:
	var base: float = floorf(a * roundf(float(term["r"]) * 100.0) / 10000.0)
	return [base, base + floorf(base * roundf(care_bonus * 100.0) / 10000.0)]


func bank_block() -> String:
	var cur: Variant = bank_cur()
	if not online:
		return "Hãy vào game rồi mở lại Hũ Mật."
	if frozen:
		return "Hũ Mật đang bảo trì, hãy thử lại sau."
	if not accepting:
		return "Hũ Mật đã ngừng nhận gửi mới."
	if level < min_level:
		return "Cần đạt cấp " + str(min_level) + " để gửi mật."
	if jars.size() >= max_slots:
		return "Kệ đã đầy, hãy thu hoạch hoặc đập bớt hũ."
	if cur == null or bank_term() == null:
		return "Hũ Mật đang bảo trì, hãy thử lại sau."
	if bank_limit(cur) < float(cur["min"]):
		if float(cur["bal"]) >= 0.0 and float(cur["bal"]) < float(cur["min"]):
			return "Không đủ " + str(cur["n"]) + " (mỗi hũ ít nhất " + fmt(float(cur["min"])) + ")."
		return "Đã gửi tối đa " + fmt(float(cur["total"])) + " " + str(cur["n"]) + "."
	return ""

func _gift_n() -> float:
	var parts: PackedStringArray = gift.split(":")
	return TevWheel.as_number(parts[1]) if parts.size() > 1 else NAN

func _has_gift() -> bool:
	return gift.split(":").size() > 1 and _gift_n() > 0.0


func rules() -> String:
	var text: String = "Gửi Xu, Xu khóa hoặc Bạc vào hũ mật theo kỳ hạn; hũ chín trả đủ tiền gốc kèm lãi vào túi."
	text += "\n• Lãi của Xu trả bằng Xu khóa."
	text += "\n• Mỗi ngày bấm RÓT MẬT: hũ được chăm đủ mọi ngày của kỳ hạn nhận thêm " + as_text(care_bonus) + "% lãi"
	if _has_gift():
		text += ", ong mật tặng " + fmt(_gift_n()) + " " + cur_name(gift.split(":")[0])
	text += ".\n• Đập hũ trước hạn: nhận lại tiền gốc, mất lãi."
	text += "\n• Kệ có " + str(max_slots) + " ô, cần cấp " + str(min_level) + " để gửi."
	return text


func jar_tip(jar: Dictionary) -> String:
	var text: String = "Hũ " + str(int(jar["d"])) + " ngày · lãi " + as_text(float(jar["r"])) + "%\nGốc: " + fmt(float(jar["a"])) + " " + cur_name(str(jar["c"]))
	if is_ripe(jar):
		return text + "\nLãi: +" + fmt(float(jar["i"])) + " " + cur_name(str(jar["p"])) + "\nĐã chín, bấm để thu hoạch!"
	return (text + "\nLãi hiện tại: +" + fmt(float(jar["i"])) + " " + cur_name(str(jar["p"])) + "\nĐã chăm " + str(int(jar["cd"])) + "/"
		+ str(int(jar["d"])) + " ngày\nBấm để xem chi tiết.")




func _on_amount_typed(value: String) -> void :
	var clean: String = ""
	for i in range(value.length()):
		if (value[i] >= "0" and value[i] <= "9") or value[i] == ".":
			clean += value[i]
	if clean != value:
		var caret: int = _amount.caret_column
		_amount.text = clean
		_amount.caret_column = mini(caret, clean.length())
	on_input(clean)


func on_input(text: String) -> void :
	var digits: String = text.replace(".", "")
	amount = 0.0 if digits.is_empty() else TevWheel.as_number(digits)
	if is_nan(amount):
		amount = 0.0
	_refresh_est()


func _on_amount_out() -> void :
	if amount > 0.0:
		_amount.text = fmt(amount)


func _refresh_est() -> void :
	var cur: Variant = bank_cur()
	var term: Variant = bank_term()
	if cur == null or term == null:
		return
	var a: float = amount
	var lim: float = bank_limit(cur)
	if a < float(cur["min"]) or a > float(cur["max"]):
		_est = ["Mỗi hũ từ " + fmt(float(cur["min"])) + " đến " + fmt(float(cur["max"])) + " " + str(cur["n"]), BAD, 
			"Còn gửi thêm được " + fmt(maxf(0.0, float(cur["total"]) - float(cur["used"]))) + " " + str(cur["n"]), WAIT_INK]
		return
	if a > lim:
		_est = [("Không đủ " + str(cur["n"]) + " (có " + fmt(float(cur["bal"])) + ")" if float(cur["bal"]) >= 0.0 and a > float(cur["bal"])
			else "Lúc này gửi tối đa " + fmt(lim) + " " + str(cur["n"])), BAD, "", WAIT_INK]
		return
	var got: Array = interest(a, term)
	var bias: int = int(Time.get_time_zone_from_system().get("bias", 0))
	var when : Dictionary = Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_system()) + int(term["d"]) * 86400 + bias * 60)
	_est = ["Lãi +" + fmt(float(got[0])) + " → +" + fmt(float(got[1])) + " " + str(cur["pn"]), INK, 
		"Chín ngày " + pad(int( when ["day"])) + "/" + pad(int( when ["month"])) + " · chăm đủ " + str(int(term["d"])) + " ngày để lãi cao nhất", WAIT_INK]




func on_pick(key: String) -> void :
	var parts: PackedStringArray = key.split(":")
	if parts.size() < 2:
		return
	var n: int = TevWheel.as_int(parts[1])
	if parts[0] == "detail":
		sel = -1
		ask = false
		_rebuild()
		return
	if parts[0] == "jar":
		var jar: Variant = jar_by_id(jars, n)
		if jar == null or busy():
			return
		if is_ripe(jar):
			claim(str(n))
			return
		sel = n
		_rebuild()
		return
	if parts[0] == "slot":
		if _amount != null and _amount.visible:
			_amount.grab_focus()
			_amount.select_all()
		if _b_ready:
			later.append({"t": tick, "k": "hint"})
		return
	if busy():
		return
	if parts[0] == "cur" and n < curs.size():
		if str(curs[n]["id"]) != cur_id:
			cur_id = str(curs[n]["id"])
			amount = 0.0
	elif parts[0] == "term" and n < terms.size():
		term_d = int(terms[n]["d"])
	else:
		var cur: Variant = bank_cur()
		if cur == null:
			return
		var lim: float = bank_limit(cur)
		if parts[0] == "step":
			var step: float = float(cur["min"]) * 10.0
			amount = floorf((bank_amount() + n * step) / step) * step
		elif n == 0:
			amount = float(cur["min"])
		elif n == 3:
			amount = lim
		else:
			amount = floorf((float(cur["bal"]) if float(cur["bal"]) >= 0.0 else float(cur["max"])) / (4.0 if n == 1 else 2.0))
		amount = maxf(float(cur["min"]), minf(maxf(float(cur["min"]), float(cur["max"])), amount))
	_rebuild()


func on_deposit() -> void :
	var cur: Variant = bank_cur()
	var term: Variant = bank_term()
	var a: float = amount
	if busy() or cur == null or term == null or not bank_block().is_empty():
		return
	if a < float(cur["min"]) or a > float(cur["max"]) or a > bank_limit(cur):
		tip(str(_est[0]) if _b_ready else "Số lượng không hợp lệ.")
		return
	fetch("/savings-bank-deposit.xml?c=" + TevWheel.uri_component(str(cur["id"])) + "&a=" + as_text(a) + "&d=" + str(int(term["d"])) + "&k="
		+ TevWheel.uri_component(token) + "&t=" + str(int(now_ms())), "deposit")
	_rebuild()


func on_care() -> void :
	if busy():
		return
	fetch("/savings-bank-care.xml?k=" + TevWheel.uri_component(token) + "&t=" + str(int(now_ms())), "care")
	_rebuild()


func claim(id: String) -> void :
	if busy():
		return
	fetch("/savings-bank-claim.xml?j=" + TevWheel.uri_component(id) + "&k=" + TevWheel.uri_component(token) + "&t=" + str(int(now_ms())), "claim")
	_rebuild()


func on_break() -> void :
	var jar: Variant = jar_by_id(jars, sel)
	if busy() or jar == null or is_ripe(jar):
		return
	ask = true
	hit_at = 0.0
	ask_pop = 0
	_rebuild()


func on_ask_yes() -> void :
	if not ask or hit_at != 0.0 or busy():
		return
	hit_at = now_ms()
	ask_pop = ASK_POP.size()
	_rebuild()
	sparkles(float(ASK[0]) + ASK_HIT.x, float(ASK[1]) + ASK_HIT.y, 2)


func on_ask_no() -> void :
	if hit_at != 0.0:
		return
	ask = false
	_rebuild()




func play_fx(fx: String, old: Array) -> void :
	if not opened:
		return
	var parts: PackedStringArray = fx.split(":")
	var ids: PackedStringArray = parts[1].split(".") if parts.size() > 1 else PackedStringArray()
	if parts[0] == "seal":
		pop_slot = TevWheel.as_int(parts[1])
		pop_t = 1
		_pop_step()
		return
	if parts[0] == "care":
		pour_t = 56
		var n: int = 0
		for view: Dictionary in _views:
			var jar: Variant = jar_by_id(jars, int(view["id"]))
			var was: Variant = jar_by_id(old, int(view["id"]))
			if jar != null and bool(jar["ct"]) and (was == null or not bool(was["ct"])):
				var mouth: float = float(MOUTH[term_art(int(jar["d"]))])
				later.append({"t": tick + 8 + n * 4, "k": "drop", "x": float(view["x"]), "y": float(view["y"]) - mouth})
				later.append({"t": tick + 30 + n * 4, "k": "float", "s": "+1 ngày chăm", "c": HONEY, "x": float(view["x"]), 
					"y": float(view["y"]) - mouth - 14.0})
				n += 1
		if not gift.is_empty():
			later.append({"t": tick + 34 + n * 4, "k": "float", "s": "Quà ong mật +" + fmt(_gift_n()), "c": Color.WHITE, 
				"x": float(GIFT[0]) + 46.0, "y": float(GIFT[1]) - 6.0})
		return
	var k: int = 0
	for id: String in ids:
		var was: Variant = jar_by_id(old, TevWheel.as_int(id))
		if was != null:
			var pos: Vector2 = slot_pos(int(was["slot"]))
			if parts[0] == "claim":
				claim_fx(was, pos, k)
			elif parts[0] == "break":
				break_fx(was, pos)
			k += 1


func claim_fx(jar: Dictionary, pos: Vector2, k: int) -> void :
	var fly: Dictionary = fx_add("jar", "", pos, {"vy": -1.6, "life": 34, "fade": 18})
	fly["t"] = term_art(int(jar["d"]))
	fly["cur"] = str(jar["c"])
	sparkles(pos.x, pos.y - 56.0, 5)
	var path: String = cur_icon(str(jar["c"]))
	var coin: Texture2D = pack.picture(path) if pack != null else null
	if coin != null and coin.get_width() > 1:
		for i in 6:
			var c: Dictionary = fx_add("coin", "", Vector2(pos.x + randf() * 40.0 - 20.0, pos.y - 50.0 - randf() * 30.0), {
				"tx": float(BAL[0]) + float(BAL[2]) / 2.0, "ty": float(BAL[1]), "ts": 0.6, "life": 22 + i * 3 + k * 4, "fade": 5})
			c["path"] = path
	float_text("+" + fmt(float(jar["a"])) + " " + cur_name(str(jar["c"])), Color.WHITE, pos.x, pos.y - 130.0)
	if float(jar["i"]) > 0.0:
		later.append({"t": tick + 10, "k": "float", "s": "+" + fmt(float(jar["i"])) + " " + cur_name(str(jar["p"])), "c": HONEY, 
			"x": pos.x, "y": pos.y - 130.0})


func break_fx(jar: Dictionary, pos: Vector2) -> void :
	if art("fx_shards") != null:
		for i in 10:
			fx_add("sheet", "fx_shards", Vector2(pos.x + randf() * 50.0 - 25.0, pos.y - 50.0 - randf() * 40.0), {
				"f": i % 8, "still": 1, "vx": randf() * 7.0 - 3.5, "vy": -3.0 - randf() * 4.0, "g": 0.45, "vr": randf() * 30.0 - 15.0, 
				"life": 34, "fade": 10})
	puff(pos.x, pos.y - 40.0)
	float_text("+" + fmt(float(jar["a"])) + " " + cur_name(str(jar["c"])), Color.WHITE, pos.x, pos.y - 120.0)

func puff(x: float, y: float) -> void :
	if art("fx_puff") != null:
		fx_add("sheet", "fx_puff", Vector2(x, y), {"tpf": 2})


func sparkles(x: float, y: float, count: int) -> void :
	if art("fx_sparkle") == null:
		return
	for i in count:
		fx_add("sheet", "fx_sparkle", Vector2(x + randf() * 90.0 - 45.0, y + randf() * 80.0 - 40.0), {"tpf": 2})


func float_text(text: String, color: Color, x: float, y: float) -> void :
	var fx: Dictionary = fx_add("text", "", Vector2(maxf(110.0, minf(BK_W - 110.0, x)), maxf(70.0, y)), {"vy": -0.8, "life": 40, "fade": 14})
	fx["text"] = text
	fx["color"] = color


func drop(x: float, y: float) -> void :
	if art("fx_drop") == null or not opened:
		return
	fx_add("pic", "fx_drop", DIPPER, {"vx": (x - DIPPER.x) / 20.0, "vy": (y - DIPPER.y) / 20.0 - 0.35 * 21.0 / 2.0, "g": 0.35, "life": 20})
	later.append({"t": tick + 20, "k": "sparkle", "x": x, "y": y + 30.0})


func _pop_step() -> void :
	var view: Variant = _by_slot.get(pop_slot)
	if view == null:
		pop_slot = -1
		return
	var k: float = minf(1.0, float(pop_t) / 14.0)
	var foot: Vector2 = _pop_foot(view)
	if pop_t == 10:
		puff(foot.x, foot.y - 16.0)
	if k >= 1.0:
		sparkles(foot.x, foot.y - 64.0, 3)
		pop_slot = -1

func _pop_scale() -> float:
	var k: float = minf(1.0, float(pop_t) / 14.0)
	return maxf(0.05, (1.0 - pow(1.0 - k, 3.0)) + 0.16 * sin(k * PI))

func _pop_foot(view: Dictionary) -> Vector2:
	var k: float = minf(1.0, float(pop_t) / 14.0)
	return Vector2(float(view["x"]), slot_pos(int(view["slot"])).y - 46.0 * (1.0 - k) * (1.0 - k))


func _ask_tick() -> void :
	if _b_ask and ask_pop < ASK_POP.size():
		ask_pop += 1
	if hit_at != 0.0 and now_ms() - hit_at >= ASK_HIT_MS:
		hit_at = 0.0
		ask = false
		var jar: Variant = jar_by_id(jars, sel)
		if jar != null and not is_ripe(jar) and not busy():
			fetch("/savings-bank-break.xml?j=" + str(int(jar["id"])) + "&k=" + TevWheel.uri_component(token) + "&t=" + str(int(now_ms())), "break")
		_rebuild()




func _rebuild() -> void :
	if not opened:
		return
	_views = []
	_by_slot = {}
	_times = []
	_det = {}
	_ask_view = {}
	_b_ask = false
	_hint = false
	_b_tick = tick
	_b_busy = busy()
	_b_cur = null
	_b_term = null
	_b_block = ""
	_b_dep = -1
	_est = ["", INK, "", WAIT_INK]
	_b_ready = art_pending() == 0 and art("bank_bg") != null and loaded
	_b_failed = art_pending() == 0 and art("bank_bg") == null
	if _amount != null:
		_amount.release_focus()
	if not _b_ready:
		return
	for jar: Dictionary in jars:
		var slot: int = int(jar["slot"])
		if slot >= 0 and slot < 9:
			var pos: Vector2 = slot_pos(slot)
			var time: Dictionary = {"jar": jar, "pre": "", "text": left(jar)}
			var view: Dictionary = {"id": int(jar["id"]), "slot": slot, "jar": jar, "ripe": is_ripe(jar), "t": term_art(int(jar["d"])), 
				"fill": fill_of(jar), "x": pos.x, "y": pos.y, "time": time}
			_by_slot[slot] = view
	for i in 9:
		if _by_slot.has(i):
			_views.append(_by_slot[i])
			_times.append(_by_slot[i]["time"])
	_b_cur = bank_cur()
	_b_term = bank_term()
	_b_block = bank_block()
	if _amount != null:
		_amount.text = fmt(bank_amount())
	_refresh_est()
	_b_dep = -1 if not _b_block.is_empty() else (0 if _b_busy else 1)
	if sel >= 0:
		var jar: Variant = jar_by_id(jars, sel)
		if jar == null:
			sel = -1
		else:
			var ripe: bool = is_ripe(jar)
			_det = {"jar": jar, "ripe": ripe, "t": term_art(int(jar["d"])), "fill": fill_of(jar), 
				"time": {"jar": jar, "pre": "Còn ", "text": ("" if ripe else "Còn ") + left(jar)}}
			_times.append(_det["time"])
	if ask and sel >= 0:
		var jar: Variant = jar_by_id(jars, sel)
		if jar == null or is_ripe(jar):
			ask = false
			hit_at = 0.0
		else:
			_b_ask = true
			_ask_view = {"jar": jar, "t": term_art(int(jar["d"])), "fill": fill_of(jar), 
				"time": {"jar": jar, "pre": "Hũ chín sau: ", "text": "Hũ chín sau: " + left(jar)}}
			_times.append(_ask_view["time"])




func _anim() -> void :
	_ask_tick()
	if not opened:
		return
	if pop_slot >= 0:
		pop_t += 1
		_pop_step()
	if pour_t > 0:
		pour_t -= 1
	var ripe: Array = []
	for view: Dictionary in _views:
		if bool(view["ripe"]):
			ripe.append(view)
	if ripe.size() > 0 and tick % 9 == 0:
		var view: Dictionary = ripe[randi() % ripe.size()]
		sparkles(float(view["x"]), float(view["y"]) - 64.0, 1)
	var keep: Array = []
	var now: Array = later
	later = []
	for entry: Dictionary in now:
		if int(entry["t"]) > tick:
			keep.append(entry)
		elif str(entry["k"]) == "float":
			float_text(str(entry["s"]), entry["c"], float(entry["x"]), float(entry["y"]))
		elif str(entry["k"]) == "drop":
			drop(float(entry["x"]), float(entry["y"]))
		elif str(entry["k"]) == "sparkle":
			sparkles(float(entry["x"]), float(entry["y"]), 2)
		elif str(entry["k"]) == "hint" and _b_ready:
			_hint = true
			keep.append({"t": tick + 20, "k": "unhint"})
		elif str(entry["k"]) == "unhint":
			if _b_dep == 1:
				_hint = false
	later = keep + later
	if tick % 25 == 0:
		var ripened: bool = false
		for entry: Dictionary in _times:
			var jar: Dictionary = entry["jar"]
			entry["text"] = (str(entry["pre"]) if not str(entry["pre"]).is_empty() and not is_ripe(jar) else "") + left(jar)
			if not bool(jar["ready"]) and is_ripe(jar):
				ripened = true

		if ripened and not due and not loading:
			due = true
			poll()




func _dbtext(at: Vector2, w: float, h: float, px: float, color: Color, glow: Color, align: String, text: String) -> float:
	var size: float = px
	while size > 7.0 and text_width(text, size) > w - 4.0:
		size -= 0.5
	return super (at, w, h, size, color, glow, align, text)


func _say(at: Vector2, w: float, h: float, px: float, least: float, color: Color, align: String, text: String) -> void :
	var y: float = at.y + float(int((h - px * 1.2 - 4.0) / 2.0))
	var size: float = px
	while size > least and text_width(text, size) > w - 6.0:
		size -= 1.0
	while size > 6.0 and text_width(text, size) > w - 4.0:
		size -= 0.5
	var x: float = at.x + (2.0 if align == "left" else (-2.0 if align == "right" else 0.0))
	_fwords(text, ARIAL_BOLD, size, color, align.substr(0, 1), Vector2(x, y), w, 0.0, 0.0, false, NONE)


func _draw_tips() -> void :
	var was: String = _hover
	if _hover.begins_with("jar:") or _hover.begins_with("slot:") or _hover == "stop":
		_hover = "panel"
	super ()
	_hover = was


func _cur_pic(id: String, side: float, centre: Vector2, alpha: float = 1.0) -> void :
	var texture: Texture2D = pack.picture(cur_icon(id)) if pack != null else null
	if texture == null:
		return
	var k: float = minf(side / maxf(1.0, float(texture.get_width())), side / maxf(1.0, float(texture.get_height())))
	var shown: Vector2 = Vector2(texture.get_size()) * k
	draw_texture_rect(texture, Rect2((centre - shown / 2.0) * _f, shown * _f), false, Color(1, 1, 1, alpha))


func _jar(t: int, foot: Vector2, fill: float, scale: float, cur: String, alpha: float = 1.0) -> void :
	var name: String = "jar" + str(TERM_ART[t])
	var inner: Vector2 = foot + Vector2( - JAR_W / 2.0, - JAR_FOOT) * scale
	var empty: Texture2D = art(name + "_empty")
	if empty != null:
		draw_texture_rect(empty, Rect2(inner * _f, Vector2(empty.get_size()) * scale * _f), false, Color(1, 1, 1, alpha))
	var full: Texture2D = art(name + "_full")
	if full != null and fill > 0.0:
		var top: float = float(FILL[t * 2])
		var bot: float = float(FILL[t * 2 + 1])
		var cut: float = 0.0 if fill >= 1.0 else float(int(bot - (bot - top) * fill))
		draw_texture_rect_region(full, Rect2((inner + Vector2(0, cut) * scale) * _f, Vector2(JAR_W, JAR_H - cut) * scale * _f), 
			Rect2(0, cut, JAR_W, JAR_H - cut), Color(1, 1, 1, alpha))
	if not cur.is_empty():
		_cur_pic(cur, 26.0 * scale, inner + Vector2(JAR_W / 2.0, float(STAMP_Y[t])) * scale, alpha)


func _ripe_glow(gx: float, gy: float, clip: Rect2, alpha: float) -> void :
	var texture: Texture2D = art("glow_ripe")
	if texture == null:
		return
	var rect: Rect2 = Rect2(Vector2(gx, gy), Vector2(texture.get_size())).intersection(clip)
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	draw_texture_rect_region(texture, Rect2(rect.position * _f, rect.size * _f), Rect2(rect.position - Vector2(gx, gy), rect.size), Color(1, 1, 1, alpha))

static func _clip(list: Array, i: int, at: Vector2) -> Rect2:
	return Rect2(at + Vector2(float(list[i]), float(list[i + 1])), Vector2(float(list[i + 2]), float(list[i + 3])))

func _draw_fx(at: Vector2, layer: String) -> void :
	super (at, layer)
	for fx: Dictionary in _fx:
		if str(fx["layer"]) != layer:
			continue
		var alpha: float = float(fx["alpha"])
		var spot: Vector2 = at + Vector2(float(fx["x"]), float(fx["y"]))
		match str(fx["kind"]):
			"text":
				_dbtext(spot - Vector2(100, 12), 200.0, 24.0, 15.0, Color(fx["color"], alpha), Color(OUTLINE, alpha), "center", str(fx["text"]))
			"jar":
				pic("jar" + str(TERM_ART[int(fx["t"])]) + "_full_glow", spot - Vector2(JAR_W / 2.0 + GLOW_PAD, JAR_FOOT + GLOW_PAD), alpha)
				_jar(int(fx["t"]), spot, 1.0, 1.0, str(fx["cur"]), alpha)
			"coin":
				var texture: Texture2D = pack.picture(str(fx["path"])) if pack != null else null
				if texture != null:
					var scale: float = float(fx["scale"])
					draw_set_transform(spot * _f, 0.0, Vector2(scale, scale))
					draw_texture_rect(texture, Rect2(Vector2(-12, -12) * _f, Vector2(24, 24) * _f), false, Color(1, 1, 1, alpha))
					draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _wait_panel(at: Vector2, failed: bool) -> void :
	_round(Rect2((at + Vector2(0, 30)) * _f, Vector2(BK_W, BK_H - 30.0) * _f), Color(SHADOW, 0.96), 12.0, Color(1, 1, 1, 0.35), 1.0)
	_dbtext(at + Vector2(0, 280), BK_W, 30.0, 14.0, Color.WHITE, NONE, "center", "Không tải được giao diện, hãy thử lại." if failed else "Đang tải...")


func _native_close(at: Vector2) -> void :
	var cell: Vector2 = _cell_size("public_button_close")
	_fbutton("close", "public_button_close", at + Vector2(BK_W - 68.0 - cell.x, 78.0))

func _chrome(at: Vector2) -> void :
	if not _b_ready or art("btn_close_st") == null:
		_native_close(at)

func _body(at: Vector2) -> void :
	if not _b_ready:
		_amount_off()
		_wait_panel(at, _b_failed)
		return
	var cover: bool = not _det.is_empty() or rules_on
	var moved: bool = tick != _b_tick
	pic("bank_bg", at)
	if not cover:
		tip_area(_clip(RULES, 0, at), 0, rules())
	_shelf(at, cover, moved)
	_care(at, cover, moved)
	_deposit(at, cover)
	_bees(at)
	if not _det.is_empty():
		_detail(at)
	if _b_ask:
		_ask(at, moved)
	if art("btn_close_st") != null:
		art_button("close", "btn_close_st", at + CLOSE, 1)
	rules_button(at + Vector2(836, 92))


func rules_title() -> String:
	return "LUẬT CHƠI · HŨ MẬT"

func rules_text() -> String:
	var text: String = rules()
	var rows: Array = []
	for term: Dictionary in terms:
		rows.append(str(int(term["d"])) + " ngày lãi " + as_text(float(term["r"])) + "%")
	if not rows.is_empty():
		text += "\n• Kỳ hạn: " + ", ".join(rows) + ". Lãi chốt ngay lúc gửi."
	var caps: Array = []
	for cur: Dictionary in curs:
		if float(cur.get("total", 0)) > 0.0:
			caps.append(str(cur["n"]) + " " + fmt(float(cur["total"])))
	if not caps.is_empty():
		text += "\n• Tổng đang gửi tối đa mỗi loại: " + ", ".join(caps) + "."
	return text + "\n• Bấm vào hũ để xem lãi hiện tại; hũ chín bấm để thu hoạch."


func _shelf(at: Vector2, cover: bool, moved: bool) -> void :
	var hex_a: float = 0.7 + 0.3 * sin(float(tick) * 0.1) if moved else 1.0
	for i in 9:
		var pos: Vector2 = slot_pos(i)
		var view: Variant = _by_slot.get(i)
		if view == null:
			if i < max_slots:
				pic("slot_empty", at + pos + HEX, hex_a)
			continue
		var t: int = int(view["t"])
		if bool(view["ripe"]):
			var glow_a: float = 0.6 + 0.4 * sin(float(tick) * 0.12 + float(i)) if moved else 1.0
			_ripe_glow(at.x + pos.x - 80.0, at.y + pos.y - JAR_FOOT + float(BODY_Y[t]) - 80.0, _clip(GLOW_CLIP, int(i / 3.0) * 4, at), glow_a)
		var foot: Vector2 = pos
		var scale: float = 1.0
		if pop_slot == i:
			foot = _pop_foot(view)
			scale = _pop_scale()
		_jar(t, at + foot, float(view["fill"]), scale, str(view["jar"]["c"]))
	var bg: Texture2D = art("bank_bg")
	for i in 3:
		var lip: Rect2 = _clip(LIPS, i * 4, Vector2.ZERO)
		draw_texture_rect_region(bg, Rect2((at + lip.position) * _f, lip.size * _f), lip)
	for i in 9:
		var pos: Vector2 = slot_pos(i)
		var view: Variant = _by_slot.get(i)
		if view == null:
			if i < max_slots:
				var area: Rect2 = Rect2(at + pos - Vector2(SLOT_W / 2.0, 112.0), Vector2(SLOT_W, 112.0))
				_hit("slot:" + str(i), Rect2(area.position * _f, area.size * _f), false)
				if not cover:
					tip_area(area, 0, "Ô trống: chọn tiền, kỳ hạn và số lượng bên phải rồi bấm GỬI MẬT.")
			continue
		var jar: Dictionary = view["jar"]
		var ripe: bool = bool(view["ripe"])
		var corner: Vector2 = at + pos + TAG
		pic("tag_ripe" if ripe else "tag", corner)
		_say(corner + Vector2(float(TAG_L1[0]), float(TAG_L1[1])), float(TAG_L1[2]), float(TAG_L1[3]), 12.0, 9.0, INK, "center", fmt(float(jar["a"])))
		_say(corner + Vector2(float(TAG_L2[0]), float(TAG_L2[1])), float(TAG_L2[2]), float(TAG_L2[3]), 10.0, 10.0, RIPE_INK if ripe else WAIT_INK, "center", 
			str(view["time"]["text"]))
		var area: Rect2 = Rect2(at + pos - Vector2(SLOT_W / 2.0, 112.0), Vector2(SLOT_W, SLOT_H))
		_hit("jar:" + str(int(jar["id"])), Rect2(area.position * _f, area.size * _f), false)
		if not cover:
			tip_area(area, 0, jar_tip(jar))


func _care(at: Vector2, cover: bool, moved: bool) -> void :
	var dy: float = (0.0 if pour_t > 0 else 1.5 * sin(float(tick) * 0.08)) if moved else 0.0
	pic("teddy_pour" if pour_t > 0 else "teddy_idle", at + TEDDY + Vector2(0, dy))
	var state: int = (0 if _b_busy else 1) if can_care and not cared and online and not frozen else -1
	art_button("care", "btn_care_st", at + CARE_BTN, state)
	var line: String = "Hôm nay đã rót mật" if cared else ("Chăm đều: thêm " + as_text(care_bonus) + "% lãi" if can_care else "Chưa có hũ đang ủ mật")
	var box: Rect2 = _clip(CARE_LINE, 0, at)
	_say(box.position, box.size.x, box.size.y, 11.0, 9.0, INK, "center", line)
	if not cover:
		tip_area(box, 0, "Hôm nay đã rót mật, mai quay lại nhé!" if cared else "Mỗi ngày bấm RÓT MẬT một lần cho mọi hũ đang ủ: mỗi ngày chăm cộng dần, "
			+ "chăm đủ cả kỳ hạn thì lãi tăng thêm " + as_text(care_bonus) + "%. Không rót vẫn nhận đủ gốc và lãi thường.")
	if _has_gift():
		var chip: Rect2 = _clip(GIFT, 0, at)
		var parts: PackedStringArray = gift.split(":")
		pic("chip_gift", chip.position)
		_cur_pic(parts[0], 16.0, chip.position + Vector2(14, 13))
		_say(chip.position + Vector2(31, 4), 50.0, 18.0, 12.0, 9.0, INK, "center", "+" + fmt(_gift_n()))
		if not cover:
			tip_area(chip, 0, "Quà ong mật mỗi lần rót mật: " + fmt(_gift_n()) + " " + cur_name(parts[0]) + ".")


func _deposit(at: Vector2, cover: bool) -> void :
	var state: int = 0 if _b_busy else 1
	var alpha: float = 0.75 if _b_busy else 1.0
	for i in mini(curs.size(), 3):
		var cur: Dictionary = curs[i]
		var shown: Array = art_button("cur:" + str(i), "tab_on_st" if str(cur["id"]) == cur_id else "tab_off_st", at + Vector2(float(TAB_X[i]), TAB_Y), state)
		var face: Vector2 = at + Vector2(float(TAB_X[i]), TAB_Y + (1.0 if int(shown[1]) == 2 else 0.0))
		_cur_pic(str(cur["id"]), 22.0, face + Vector2(20, 18), alpha)
		_say(face + Vector2(35, 8), 55.0, 20.0, 13.0, 10.0, Color(INK, alpha), "center", str(cur["n"]))
	for i in mini(terms.size(), 3):
		var term: Dictionary = terms[i]
		var shown: Array = art_button("term:" + str(i), "term_on_st" if int(term["d"]) == term_d else "term_off_st", at + Vector2(float(TAB_X[i]), TERM_Y), 
			state)
		var face: Vector2 = at + Vector2(float(TAB_X[i]), TERM_Y + (1.0 if int(shown[1]) == 2 else 0.0))
		_jar(mini(2, i), face + Vector2(26.0 + JAR_W / 2.0 * 0.36, 4.0 + JAR_FOOT * 0.36), 1.0, 0.36, "", alpha)
		_say(face + Vector2(9, 49), 78.0, 13.0, 11.0, 11.0, Color(INK, alpha), "center", str(int(term["d"])) + " ngày")
		_say(face + Vector2(9, 62), 78.0, 12.0, 11.0, 11.0, Color(RIPE_INK, alpha), "center", "+" + as_text(float(term["r"])) + "%")
	art_button("step:-1", "btn_minus_st", at + MINUS, state)
	art_button("step:1", "btn_plus_st", at + PLUS, state)
	var field: Rect2 = Rect2(at + Vector2(float(FIELD[0]), float(FIELD[1]) + (float(FIELD[3]) - 26.0) / 2.0), Vector2(float(FIELD[2]), 26.0))
	if cover:
		_amount_off()
		_say(field.position, field.size.x, field.size.y, 18.0, 18.0, BK_CREAM, "center", _amount.text if _amount != null else "")
	elif _amount != null:
		_fput(_amount, field, 18.0, "c")
	for i in 4:
		var shown: Array = art_button("chip:" + str(i), "chip_st", at + Vector2(float(CHIP_X[i]), CHIP_Y), state)
		var face: Vector2 = at + Vector2(float(CHIP_X[i]), CHIP_Y + (1.0 if int(shown[1]) == 2 else 0.0))
		_say(face + Vector2(5, 4), 54.0, 17.0, 11.0, 11.0, Color(INK, alpha), "center", str(CHIP_LABEL[i]))
	_say(at + Vector2(float(EST[0]), float(EST[1])), float(EST[2]), float(EST[3]), 13.0, 10.0, _est[1], "center", str(_est[0]))
	_say(at + Vector2(float(EST[0]), float(EST[4])), float(EST[2]), float(EST[5]), 11.0, 9.0, _est[3], "center", str(_est[2]))
	if _hint:
		pic("btn_deposit_hint", at + DEPOSIT - Vector2(HINT_PAD, HINT_PAD))
	art_button("deposit", "btn_deposit_st", at + DEPOSIT, _b_dep)
	var bal: Rect2 = _clip(BAL, 0, at)
	if not _b_block.is_empty():
		_say(bal.position, bal.size.x, bal.size.y, 11.0, 8.0, BAD, "center", _b_block)
		if not cover:
			tip_area(bal, 0, _b_block)
	elif _b_cur != null:
		var cur: Dictionary = _b_cur
		var sending: String = "Đang gửi " + fmt(float(cur["used"])) + "/" + fmt(float(cur["total"])) + " " + str(cur["n"])
		var have: String = "Số dư: " + fmt(float(cur["bal"])) + " " + str(cur["n"])
		_say(bal.position, bal.size.x, bal.size.y, 11.0, 8.0, INK, "center", have if float(cur["bal"]) >= 0.0 else sending)
		if not cover:
			tip_area(bal, 0, (have + "\n" if float(cur["bal"]) >= 0.0 else "") + sending + " (tối đa mỗi loại tiền)")

func _amount_off() -> void :
	if _amount != null and _amount.visible:
		_amount.visible = false
		_amount.release_focus()


func _bees(at: Vector2) -> void :
	var texture: Texture2D = art("bee")
	if texture == null:
		return
	for n in 3:
		var a: float = float(tick) * (0.012 + n * 0.004) + n * 2.1
		var x: float = (712.0 if n == 2 else 317.0) + (130.0 if n == 2 else 200.0) * sin(a)
		var y: float = (150.0 if n == 0 else (310.0 if n == 1 else 112.0)) + (18.0 if n == 2 else 46.0) * sin(2.0 * a) + 3.0 * sin(float(tick) * 0.35 + n)
		draw_set_transform((at + Vector2(x, y)) * _f, 0.0, Vector2(1.0 if cos(a) >= 0.0 else -1.0, 1.0))
		draw_texture_rect_region(texture, Rect2(Vector2(-20, -18) * _f, Vector2(40, 36) * _f), sheet_region("bee", int(tick / 2.0 + n) % 2))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _detail(at: Vector2) -> void :
	var jar: Dictionary = _det["jar"]
	var ripe: bool = bool(_det["ripe"])
	var veil: Rect2 = Rect2((at + Vector2(10, 64)) * _f, Vector2(BK_W - 20.0, BK_H - 74.0) * _f)
	_round(veil, Color(VEIL_DET, 0.45), 12.0)
	_hit("detail:close", veil, false)
	var card: Vector2 = at + DET
	pic("detail_bg", card)
	_hit("stop", Rect2(card * _f, Vector2(360, 260) * _f), false)
	if ripe:
		_ripe_glow(card.x + float(DET_GLOW[0]), card.y + float(DET_GLOW[1]), _clip(DET_GLOW, 2, card), 1.0)
	_jar(int(_det["t"]), card + DET_JAR, float(_det["fill"]), 1.0, str(jar["c"]))
	var rows: Array = [str(int(jar["d"])) + " ngày · lãi " + as_text(float(jar["r"])) + "%", "Gốc: " + fmt(float(jar["a"])) + " " + cur_name(str(jar["c"])), 
		"Lãi: +" + fmt(float(jar["i"])) + " " + cur_name(str(jar["p"]))]
	var rx: float = float(DET_ROWS[0])
	var ry: float = float(DET_ROWS[1])
	var rp: float = float(DET_ROWS[2])
	var rw: float = float(DET_ROWS[3])
	for i in rows.size():
		_say(card + Vector2(rx, ry + i * rp), rw, 21.0, 12.0, 9.0, INK, "left", str(rows[i]))
	_say(card + Vector2(rx, ry + 3.0 * rp), rw, 21.0, 12.0, 10.0, RIPE_INK if ripe else WAIT_INK, "left", str(_det["time"]["text"]))
	if not _b_ask:
		tip_area(Rect2(card + Vector2(rx - 28.0, ry - 3.0), Vector2(rw + 33.0, 4.0 * rp)), 0, "Hũ " + str(int(jar["d"])) + " ngày · lãi "
			+ as_text(float(jar["r"])) + "%\nGốc: " + fmt(float(jar["a"])) + " " + cur_name(str(jar["c"])) + "\nLãi hiện tại: +" + fmt(float(jar["i"]))
			+ " / tối đa +" + fmt(float(jar["im"])) + " " + cur_name(str(jar["p"])) + "\nĐã chăm " + str(int(jar["cd"])) + "/" + str(int(jar["d"])) + " ngày")
	var live: int = 0 if _b_busy else 1
	art_button("claim", "btn_claim_st", card + DET_CLAIM, live if ripe else -1)
	art_button("break", "btn_break_st", card + DET_BREAK, -1 if ripe else live)


func _ask(at: Vector2, moved: bool) -> void :
	var jar: Dictionary = _ask_view["jar"]
	var veil: Rect2 = Rect2((at + Vector2(10, 64)) * _f, Vector2(BK_W - 20.0, BK_H - 74.0) * _f)
	_round(veil, Color(VEIL_ASK, 0.5), 12.0)
	_hit("ask:veil", veil, false)
	var box: Rect2 = _clip(ASK, 0, at)
	var centre: Vector2 = box.get_center()
	var s: float = float(ASK_POP[mini(ask_pop, ASK_POP.size() - 1)])
	draw_set_transform(centre * _f * (1.0 - s), 0.0, Vector2(s, s))
	var card: Vector2 = box.position
	pic("confirm_bg", card)
	_hit("stop", Rect2(card * _f, box.size * _f), false)
	var shake: float = (2.0 if tick % 2 == 0 else -2.0) if hit_at != 0.0 and moved else 0.0
	_jar(int(_ask_view["t"]), card + Vector2(float(ASK_JAR[0]) + shake, float(ASK_JAR[1])), float(_ask_view["fill"]), float(ASK_JAR[2]), str(jar["c"]))
	var bob: float = 1.2 * sin(float(tick) * 0.15) if hit_at == 0.0 and moved else 0.0
	pic("confirm_teddy_strike" if hit_at != 0.0 else "confirm_teddy_raised", card + ASK_TEDDY + Vector2(0, bob))
	var rx: float = float(ASK_ROWS[0])
	var ry: float = float(ASK_ROWS[1])
	var rp: float = float(ASK_ROWS[2])
	var rw: float = float(ASK_ROWS[3])
	var rh: float = float(ASK_ROWS[4])
	_say(card + Vector2(rx, ry), rw, rh, 12.0, 9.0, INK, "left", "Nhận lại: " + fmt(float(jar["a"])) + " " + cur_name(str(jar["c"])))
	_say(card + Vector2(rx, ry + rp), rw, rh, 12.0, 9.0, BAD, "left", "Mất lãi: tới +" + fmt(float(jar["im"])) + " " + cur_name(str(jar["p"])))
	_say(card + Vector2(rx, ry + 2.0 * rp), rw, rh, 12.0, 9.0, WAIT_INK, "left", str(_ask_view["time"]["text"]))
	var live: int = 0 if hit_at != 0.0 or _b_busy else 1
	art_button("ask:yes", "btn_confirm_st", card + ASK_YES, live)
	art_button("ask:cancel", "btn_cancel_st", card + ASK_NO, live)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
