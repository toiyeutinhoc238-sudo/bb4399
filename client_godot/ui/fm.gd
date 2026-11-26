extends "tev_window.gd"









signal closed(note: String)

const FmAtlas = preload("fm_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const MB_POLL_TICKS: int = 120
const MB_ARM_MS: float = 4000.0
const FM_TIP: String = "Nông Trại Teddy"
const FM_ICON: String = "btn_farm"
const FM_WORD: String = "word_farm"
const FM_W: float = 880.0
const FM_H: float = 580.0
const FM_FILES: Array = ["fm_bg", "fm_board", "pot_back", "pot_front", "pot_plus", "pot_locked", "plate_timer", "plate_ripe", "crop_carrot_1", 
	"crop_carrot_2", "crop_carrot_3", "crop_carrot_4", "crop_melon_1", "crop_melon_2", "crop_melon_3", "crop_melon_4", "crop_gold_1", "crop_gold_2", 
	"crop_gold_3", "crop_gold_4", "bug_a", "bug_b", "badge_water", "ring_bg", "thief_a", "thief_b", "thief_run", "guard_fox", "guard_scorpion", 
	"guard_phoenix", "guard_scarecrow", "teddy_a", "teddy_b", "wild_overlay", "tab1_on", "tab1_off", "tab2_on", "tab2_off", "tab3_on", "tab3_off", 
	"tab4_on", "tab4_off", "tab5_on", "tab5_off", "banner_thief", "plate_target", "stamp_het", "pop_panel", "card_shop", "card_seed", "card_guard", 
	"card_sel", "row_list", "ic_bac_16", "ic_bac_20", "ic_xukhoa_16", "ic_xukhoa_20", "ic_xu_16", "ic_xu_20", "ic_carrot_16", "ic_carrot_32", 
	"ic_melon_16", "ic_melon_32", "ic_gold_16", "ic_gold_32", "seed_carrot", "seed_melon", "seed_gold", "lg_thief", "lg_chase", "lg_shield", 
	"lg_water", "lg_bug", "lg_clock", "btn_close_st", "btn_all_st", "btn_ask_st", "btn_free_st", "btn_thue_st", "btn_duoi_st", "btn_search_st", 
	"btn_steal_st", "btn_revenge_st", "btn_visit_st", "btn_back_st", "btn_doi_st", "btn_gieo_st", "btn_mua_st", "btn_pill_st", "fx_water", 
	"fx_sparkle", "fx_leaf", "fx_puff", "fx_dust"]
const FM_SHEETS: Dictionary = {
	"btn_close_st": [40, 40, 1, 4], "btn_all_st": [214, 38, 1, 4], "btn_ask_st": [112, 36, 1, 4], "btn_free_st": [112, 36, 1, 4], 
	"btn_thue_st": [54, 34, 1, 4], "btn_duoi_st": [58, 28, 1, 4], "btn_search_st": [170, 46, 1, 4], "btn_steal_st": [84, 28, 1, 4], 
	"btn_revenge_st": [76, 26, 1, 4], "btn_visit_st": [92, 28, 1, 4], "btn_back_st": [92, 30, 1, 4], "btn_doi_st": [64, 26, 1, 4], 
	"btn_gieo_st": [84, 30, 1, 4], "btn_mua_st": [104, 28, 1, 4], "btn_pill_st": [120, 34, 1, 4], 
	"fx_water": [64, 64, 8, 8], "fx_sparkle": [48, 48, 8, 8], "fx_leaf": [96, 96, 8, 8], "fx_puff": [64, 64, 8, 8], "fx_dust": [96, 64, 8, 8], 
}
const FM_CREAM: Color = Color("fff7e3")
const FM_INK: Color = Color("3b2210")
const FM_DARK: Color = FM_INK
const FM_GOLD: Color = Color("ffd45a")
const FM_SHORT: Color = Color("d03a2a")
const FM_OWN_RING: Color = Color("5ad45b")
const FM_DOT: Color = Color("e53935")
const FM_DIM: Color = Color(0, 0, 0, 0.45)
const FM_CLOSE: Vector2 = Vector2(827, 15)
const FM_TABS: Array = [73, 82, 179, 82, 286, 82, 392, 82, 498, 82]
const FM_GARDEN: Array = [16, 123, 596, 443]
const FM_BOARD: Vector2 = Vector2(52, 129)
const FM_BOARD_IN: Array = [68, 155, 524, 390]
const FM_POTS: Array = [237, 216, 377, 219, 516, 216, 236, 326, 377, 327, 517, 325, 236, 431, 378, 429, 518, 429]
const FM_GATE: Array = [110, 502]
const FM_WALLET_TEXT: Array = [741, 107, 81, 22, 741, 135, 81, 22, 741, 164, 81, 22]
const FM_GUARD_PORT: Array = [630, 211, 54, 49]
const FM_GUARD_TEXT: Array = [695, 206, 132, 18, 716, 233, 57, 20]
const FM_SEED_HIT: Array = [633, 296, 56, 62, 699, 296, 56, 62, 765, 296, 56, 62]
const FM_SEED_TEXT: Array = [656, 333, 29, 20, 722, 333, 29, 20, 789, 333, 29, 20]
const FM_CROP_TEXT: Array = [674, 401, 23, 21, 737, 401, 28, 21, 807, 401, 22, 21]
const FM_POT_C: Array = [58, 40]
const FM_CROP_ROOT: Array = [56, 94]
const FM_PLATE: Array = [-43, 22]
const FM_PLATE_TEXT: Array = [6, 4, 74, 18]
const FM_BUGS: Array = [-31, -43, 0, -38, -34, -65, 2, -65]
const FM_WATER: Array = [30, -33]
const FM_THIEF: Array = [-108, -64]
const FM_RING: Array = [-65, -46]
const FM_DUOI: Array = [-104, 30]
const FM_GUARD_C: Array = [72, 118]
const FM_TEDDY: Vector2 = Vector2(720, 448)
const FM_BTNS: Array = [774, 224, 621, 434, 621, 478, 621, 516]
const FM_BANNER: Vector2 = Vector2(208, 126)
const FM_TARGET: Array = [120, 124]
const FM_TARGET_TEXT: Array = [14, 7, 272, 23, 14, 31, 272, 18]
const FM_TARGET_BTN: Array = [428, 129]
const FM_STEAL_BTN: Array = [-42, 48]
const FM_SHOP: Array = [68, 155, 132, 132]
const FM_SHOP_ICON: Array = [64, 35, 52]
const FM_SHOP_NAME: Array = [7, 66, 114, 15]
const FM_SHOP_LEFT: Array = [7, 82, 114, 12]
const FM_SHOP_PRICE: Array = [29, 99, 24, 18]
const FM_SHOP_CROP: Array = [18, 108]
const FM_SHOP_BTN: Array = [57, 95]
const FM_ROW: Array = [68, 169, 59]
const FM_ROW_ICON: Array = [25, 23]
const FM_ROW_TEXT: Array = [51, 6, 364, 34]
const FM_ROW_BTN: Array = [423, 9]
const FM_STEAL_INFO: Array = [106, 178, 440, 60]
const FM_SEARCH: Array = [237, 285]
const FM_POP: Vector2 = Vector2(200, 130)
const FM_POP_TITLE: Array = [98, 13, 284, 27]
const FM_POP_CLOSE: Array = [432, 8]
const FM_POP_CARDS: Array = [20, 54, 175, 54, 330, 54]
const FM_SCARD_ICON: Array = [65, 34, 48]
const FM_SCARD_TEXT: Array = [7, 66, 116, 18, 10, 88, 112, 24]
const FM_SCARD_BTN: Array = [23, 120, 13, 154]
const FM_GCARD_ICON: Array = [65, 54, 82]
const FM_GCARD_TEXT: Array = [6, 107, 118, 32, 8, 145, 114, 30]
const FM_POP_HOURS: Array = [25, 258, 180, 258, 335, 258]
const FM_GLOW_PAD: float = 14.0
const FM_ARM_PAD: float = 18.0
const FM_PULSE_PAD: float = 12.0
const CROPS: Array = ["carrot", "melon", "gold"]
const CURS: Array = ["s", "c", "g"]

const POP_DIM: String = "slide:popdim"

static var s_fm_shown: bool = false
static var s_fm_tab: int = 0
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 13
var fm_visible: bool = false
var loaded: bool = false
var broken: bool = false
var token: String = ""
var money: Dictionary = {"g": -1, "c": -1, "s": -1}
var show_money: Dictionary = {"g": -1, "c": -1, "s": -1}
var me: Dictionary = blank_me()
var seeds: Array = []
var guards: Array = []
var pots: Array = []
var thieves: Array = []
var mine: Array = []
var target: Variant = null
var mates: Array = []
var logs: Array = []
var shop: Array = []
var tab: int = 0
var page: int = 0
var visit: int = 0
var visit_data: Variant = null
var pop: String = ""
var pop_slot: int = -1
var pop_guard: String = ""
var arm_key: String = ""
var arm_at: float = 0.0
var re_arm: String = ""
var shop_id: String = ""
var cheer_at: int = 0
var asked: bool = false
var sig: String = ""
var open_poll: int = 0
var act_slots: Array = []
var load_o: int = 0
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _o: Vector2 = Vector2.ZERO
var _drawing: bool = false
var _bn: float = 0.0
var _b_ready: bool = false
var _b_failed: bool = false
var _b_busy: bool = false
var _b_view: String = ""
var _rows: Dictionary = {}
var _keys: Dictionary = {}
var _tip_ids: Dictionary = {}
var _money_text: Dictionary = {}
var _at: Dictionary = {}
var _glow_a: float = -1.0
var _pulse_a: float = -1.0
var _arm_id: String = ""
var _arm_a: float = -1.0
var _banner_a: float = 1.0
var _bob_t: int = -1
var _bug_step: int = -1
var _thief_key: String = "thief_a"
var _ring_now: float = 0.0
var _teddy_key: String = "teddy_a"
var _teddy_dy: float = 0.0

func _setup() -> void :
	art_dir = ""
	art_files = FM_FILES
	sheets = FM_SHEETS
	win_size = Vector2(FM_W, FM_H)
	super ()


static func blank_me() -> Dictionary:
	return {"guard": "", "gAt": 0.0, "askAt": 0.0, "gcur": "c", "potCur": "s", "gh": [], "sp": 1, "rs": 30, "cap": 3, "who": "", "poll": 60}

static func reset_statics() -> void :
	s_fm_shown = false
	s_fm_tab = 0


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew


func _t() -> float:
	return _bn if _drawing else now_ms()

func _mi(key: String) -> int:
	return int(me.get(key, 0))

func _mf(key: String) -> float:
	return float(me.get(key, 0.0))


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 13
	fm_visible = false
	loaded = false
	broken = false
	token = ""
	money = {"g": -1, "c": -1, "s": -1}
	show_money = {"g": -1, "c": -1, "s": -1}
	me = blank_me()
	seeds = []
	guards = []
	pots = []
	thieves = []
	mine = []
	target = null
	mates = []
	logs = []
	shop = []
	tab = 0
	page = 0
	visit = 0
	visit_data = null
	pop = ""
	pop_slot = -1
	pop_guard = ""
	arm_key = ""
	arm_at = 0.0
	re_arm = ""
	shop_id = ""
	cheer_at = 0
	asked = false
	sig = ""
	open_poll = 0
	act_slots = []
	load_o = 0
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(FmAtlas.FILE):
			_atlas = load(FmAtlas.FILE) as Texture2D
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
	if atlas == null or not FmAtlas.R.has(name):
		return null
	var row: Array = FmAtlas.R[name]
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
	return art(FM_ICON)

func button_word() -> Texture2D:
	return art(FM_WORD)




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	load_fm(state_url(), "poll")


func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = maxi(5, _mi("poll")) if fm_visible else MB_POLL_TICKS * 3
		if not loading:
			poll()


func button_visible() -> bool:
	return fm_visible

func button_dot() -> bool:
	return fm_visible and not broken and (_mi("alert") > 0 or _mi("free") == 1 or own_ripe().size() > 0)


func busy() -> bool:
	return loading and action != "poll"


func open() -> void :
	if opened or ( not fm_visible and loaded):
		return
	tab = 0 if _mi("alert") > 0 else (s_fm_tab if s_fm_tab >= 0 and s_fm_tab <= 4 else 0)
	visit = 0
	visit_data = null
	page = 0
	pop = ""
	pop_slot = -1
	pop_guard = ""
	arm_key = ""
	arm_at = 0.0
	re_arm = ""
	cheer_at = 0
	asked = false
	sig = ""
	open_poll = 0
	act_slots = []
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
	_rows = {}
	_keys = {}
	_tip_ids = {}
	_at = {}
	_arm_id = ""
	visit = 0
	visit_data = null
	pop = ""
	poll_in = maxi(5, _mi("poll")) if fm_visible else MB_POLL_TICKS
	closed.emit(note)


func leave() -> void :
	close()

func _activate(id: String) -> void :
	if rules_click(id):
		return
	if id == "close":
		close()
	elif id == POP_DIM or id == "popclose":
		on_pop_close()
	elif id.begins_with("tab:"):
		on_tab(id.substr(4).to_int())
	elif id.begins_with("page:"):
		on_page(id.substr(5).to_int())
	elif id.begins_with("pot:"):
		on_pot(id)
	elif id.begins_with("bug:"):
		on_bug(id)
	elif id.begins_with("water:"):
		on_water(id)
	elif id.begins_with("duoi:"):
		on_chase(id)
	elif id.begins_with("steal:"):
		on_steal(id)
	elif id.begins_with("visit:"):
		on_visit(id.substr(6).to_int())
	elif id.begins_with("rv:"):
		on_revenge(id.substr(3).to_int())
	elif id.begins_with("doi:"):
		on_doi(id)
	elif id.begins_with("seedpick:"):
		on_seed_pick()
	elif id.begins_with("gieo:"):
		on_gieo(id)
	elif id.begins_with("mua:"):
		on_mua(id)
	elif id.begins_with("gpick:"):
		on_guard_pick(id.substr(6))
	elif id.begins_with("pill:"):
		on_pill(id)
	elif id == "all":
		on_all()
	elif id == "ask":
		act("ask", "")
	elif id == "free":
		act("free", "")
	elif id == "thue":
		on_thue()
	elif id == "back":
		on_back()
	elif id == "search":
		on_search()




func state_url() -> String:
	return "/farm.xml?" + ("o=" + str(visit) + "&" if visit > 0 else "") + "z="


func load_fm(url: String, what: String, o: int = -1) -> void :
	load_o = o if o >= 0 else (visit if what == "poll" else 0)
	fetch(url + str(int(now_ms())), what)


func act(a: String, extra: String, slots: Array = [], o: int = 0) -> void :
	if busy() or token.is_empty():
		return
	act_slots = slots
	load_fm("/farm-act.xml?a=" + a + "&k=" + TevWheel.uri_component(token) + extra + "&z=", a, o)
	_rebuild()


func _failed(what: String) -> void :
	if what != "poll":
		tip("Không kết nối được máy chủ, hãy thử lại.")
	if opened:
		_rebuild()

static func money_of(at: Dictionary, key: String) -> int:
	var text: String = str(at.get(key, ""))
	return -1 if text.is_empty() else TevWheel.as_int(text)

static func _ai(at: Dictionary, key: String) -> int:
	return TevWheel.as_int(str(at.get(key, "")))

static func _an(at: Dictionary, key: String) -> float:
	return TevWheel.as_number(str(at.get(key, "")))

static func _as(at: Dictionary, key: String) -> String:
	return str(at.get(key, ""))


static func pot_of(node: Dictionary, now: float) -> Dictionary:
	var p: Dictionary = node["at"]
	return {"i": _ai(p, "i"), "s": _as(p, "s"), "at": now + _an(p, "t") * 1000.0, "g": maxi(1, _ai(p, "g")), "y": _ai(p, "y"), 
		"b": _ai(p, "b"), "rd": _ai(p, "rd"), "rr": _ai(p, "rr"), "cw": _ai(p, "cw"), "ok": _ai(p, "ok")}


static func counts(text: String) -> Dictionary:
	var out: Dictionary = {}
	for part: String in text.split(","):
		var bits: PackedStringArray = part.split(":")
		if bits.size() == 2 and TevWheel.as_int(bits[1]) > 0:
			out[bits[0]] = TevWheel.as_int(bits[1])
	return out


func parse_state(xml: Dictionary) -> Dictionary:
	var now: float = float(int(now_ms()))
	var r: Dictionary = xml["at"]
	var hours: Array = []
	for part: String in _as(r, "gh").split(","):
		if TevWheel.as_int(part) > 0:
			hours.append(TevWheel.as_int(part))
	var st: Dictionary = {"seeds": [], "guards": [], "pots": [], "thieves": [], "mine": [], "target": null, "visit": null, "mates": [], "log": [], 
		"shop": []}
	st["me"] = {
		"who": _as(r, "me"), "pots": _ai(r, "pots"), "maxPots": _ai(r, "maxPots"), "potPrice": _ai(r, "potPrice"), "potCur": _as(r, "potCur"), 
		"guard": _as(r, "guard"), "gAt": now + _an(r, "gl") * 1000.0, "free": _ai(r, "free"), "steals": _ai(r, "steals"), 
		"searches": _ai(r, "searches"), "helps": _ai(r, "helps"), "guild": _ai(r, "guild"), "askAt": now + _an(r, "ask") * 1000.0, 
		"alert": _ai(r, "alert"), "poll": _ai(r, "poll"), "gh": hours, "gmax": _ai(r, "gmax"), "gcur": _as(r, "gcur"), "cap": _ai(r, "cap"), 
		"rs": maxi(1, _ai(r, "rs")), "sp": maxi(1, _ai(r, "sp")), 
	}
	for node: Dictionary in kids(xml, "sd"):
		var p: Dictionary = node["at"]
		st["seeds"].append({"id": _as(p, "id"), "label": _as(p, "name"), "crop": _as(p, "crop"), "n": _ai(p, "n"), "have": _ai(p, "have"), 
			"price": _ai(p, "price"), "cur": _as(p, "cur"), "grow": _ai(p, "grow"), "y": _ai(p, "y"), "free": _ai(p, "free")})
	for node: Dictionary in kids(xml, "gd"):
		var p: Dictionary = node["at"]
		st["guards"].append({"id": _as(p, "id"), "label": _as(p, "name"), "bl": _ai(p, "bl"), "price": _ai(p, "price"), "burn": _ai(p, "burn")})
	for node: Dictionary in kids(xml, "pot"):
		st["pots"].append(pot_of(node, now))
	for node: Dictionary in kids(xml, "th"):
		var p: Dictionary = node["at"]
		st["thieves"].append({"id": _ai(p, "id"), "slot": _ai(p, "slot"), "who": _as(p, "name"), "at": now + _an(p, "t") * 1000.0, "n": _ai(p, "n")})
	for node: Dictionary in kids(xml, "my"):
		var p: Dictionary = node["at"]
		st["mine"].append({"id": _ai(p, "id"), "owner": _ai(p, "owner"), "who": _as(p, "name"), "slot": _ai(p, "slot"), "s": _as(p, "s"), 
			"n": _ai(p, "n"), "st": _ai(p, "st"), "at": now + _an(p, "t") * 1000.0})
	var found: Array = kids(xml, "tg")
	if not found.is_empty():
		var p: Dictionary = found[0]["at"]
		var list: Array = []
		for sub: Dictionary in kids(found[0], "tp"):
			list.append(pot_of(sub, now))
		st["target"] = {"id": _ai(p, "id"), "who": _as(p, "name"), "guard": _as(p, "guard"), "done": _ai(p, "done"), 
			"at": now + _an(p, "left") * 1000.0, "pots": list}
	found = kids(xml, "vs")
	if not found.is_empty():
		var p: Dictionary = found[0]["at"]
		var list: Array = []
		for sub: Dictionary in kids(found[0], "pot"):
			list.append(pot_of(sub, now))
		st["visit"] = {"id": _ai(p, "id"), "who": _as(p, "name"), "pots": list}
	for node: Dictionary in kids(xml, "gm"):
		var p: Dictionary = node["at"]
		st["mates"].append({"id": _ai(p, "id"), "who": _as(p, "name"), "ripe": _ai(p, "ripe"), "water": _ai(p, "water"), "bugs": _ai(p, "bugs")})
	for node: Dictionary in kids(xml, "lg"):
		var p: Dictionary = node["at"]
		st["log"].append({"k": _as(p, "k"), "tx": _as(p, "tx"), "rv": _ai(p, "rv"), "at": now - _an(p, "ago") * 1000.0})
	for node: Dictionary in kids(xml, "sh"):
		var p: Dictionary = node["at"]
		st["shop"].append({"id": _as(p, "id"), "label": _as(p, "name"), "items": items_of(_as(p, "it")), "sd": counts(_as(p, "sd")), 
			"crop": _as(p, "crop"), "cost": _ai(p, "cost"), "left": _ai(p, "left"), "lim": _ai(p, "lim"), "per": _as(p, "per"), 
			"resetAt": now + _an(p, "reset") * 1000.0})
	st["money"] = {"g": money_of(r, "g"), "c": money_of(r, "c"), "s": money_of(r, "s")}
	return st


func _reply(text: String, what: String) -> void :
	var lo: int = load_o
	var old_thieves: int = thieves.size()
	var xml: Variant = parse_deep(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": [], "text": text}
	var parsed: bool = xml != null
	var notice: String = ""
	var got_tip: String = ""
	var is_visible: bool = false
	var is_broken: bool = false
	var st: Variant = null
	var done: Variant = null
	var at: Dictionary = {}
	if parsed:
		at = xml["at"]
		notice = _as(at, "notice")
		is_visible = _as(at, "visible") == "1"
		is_broken = _as(at, "broken") == "1"
		if is_visible and not is_broken:
			st = parse_state(xml)
		var found: Array = kids(xml, "done")
		if not found.is_empty():
			var d: Dictionary = found[0]["at"]
			done = {"a": _as(d, "a"), "raid": _ai(d, "raid"), "blocked": _as(d, "blocked"), "chased": _ai(d, "chased"), "got": counts(_as(d, "got"))}
			got_tip = _as(d, "tip")
	asked = false
	if not parsed and what != "poll":
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if parsed:
		fm_visible = is_visible
		s_fm_shown = is_visible
		loaded = true
		broken = is_visible and is_broken
		if is_visible:
			token = _as(at, "token")
		if st != null:
			me = st["me"]
			seeds = st["seeds"]
			guards = st["guards"]
			pots = st["pots"]
			thieves = st["thieves"]
			mine = st["mine"]
			target = st["target"]
			mates = st["mates"]
			logs = st["log"]
			shop = st["shop"]
			money = st["money"]
			if lo > 0 and lo == visit:
				visit_data = st["visit"]
				if st["visit"] == null:
					visit = 0
					if notice.is_empty():
						notice = "Không sang được vườn này."
			if not opened:
				show_money = money.duplicate()
			elif thieves.size() > old_thieves and pop.is_empty():
				tab = 0
	if done != null:
		fm_after(done)
	if opened and not fm_visible and loaded:
		close()
	elif opened:
		_rebuild()
		if done != null:
			done_fx(str(done["a"]), done)
	act_slots = []
	if not got_tip.is_empty():
		tip(got_tip)
	if not notice.is_empty():
		tip(notice)


func fm_after(done: Dictionary) -> void :
	var a: String = str(done["a"])
	if a == "plant" or a == "guard":
		pop = ""
	if a == "search":
		tab = 2
		page = 0
		visit = 0
	if a == "seed" and not re_arm.is_empty():
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



static func cur_name(cur: String) -> String:
	return "Bạc" if cur == "s" else ("Xu khóa" if cur == "c" else "Xu")

static func cur_icon(cur: String, px: int) -> String:
	return ("ic_bac_" if cur == "s" else ("ic_xukhoa_" if cur == "c" else "ic_xu_")) + str(px)

func seed_of(id: String) -> Variant:
	for one: Dictionary in seeds:
		if str(one["id"]) == id:
			return one
	return null

func guard_of(id: String) -> Variant:
	for one: Dictionary in guards:
		if str(one["id"]) == id:
			return one
	return null

func crop_name(id: String) -> String:
	var one: Variant = seed_of(id)
	return str(one["crop"]) if one != null else ""

func guard_name(id: String) -> String:
	if id == "scarecrow":
		return "Bù Nhìn"
	var one: Variant = guard_of(id)
	return str(one["label"]) if one != null else ""


func stage(pot: Variant, time_only: bool = false) -> int:
	if pot == null or str(pot["s"]).is_empty():
		return 0
	var left: float = (float(pot["at"]) - _t()) / 1000.0
	if left <= 0.0:
		return 4
	if time_only:
		return 3
	var frac: float = 1.0 - left / maxf(1.0, float(pot["g"]))
	return 1 if frac < 0.34 else (2 if frac < 0.67 else 3)

func own_ripe() -> Array:
	var out: Array = []
	for pot: Dictionary in pots:
		if stage(pot) == 4:
			out.append(int(pot["i"]))
	return out

func empty_pots() -> Array:
	var out: Array = []
	for pot: Dictionary in pots:
		if str(pot["s"]).is_empty():
			out.append(int(pot["i"]))
	return out

func running_raid() -> Variant:
	for raid: Dictionary in mine:
		if int(raid["st"]) == 0 and float(raid["at"]) > _t():
			return raid
	return null


static func dur(sec: int) -> String:
	var h: int = int(sec / 3600.0)
	var m: int = int((sec % 3600) / 60.0)
	if h > 0:
		return str(h) + " giờ" + (" " + str(m) + " phút" if m > 0 else "")
	if m > 0:
		return str(m) + " phút"
	return str(maxi(1, sec)) + " giây"


func short_left(at: float) -> String:
	var sec: int = maxi(0, ceili((at - now_ms()) / 1000.0))
	var m: int = int((sec % 3600) / 60.0)
	if sec >= 86400:
		return str(int(sec / 86400.0)) + " ngày"
	if sec >= 3600:
		return str(int(sec / 3600.0)) + "h " + str(m) + "p"
	return "%02d:%02d" % [m, sec % 60]


func ago(at: float) -> String:
	var sec: int = maxi(0, int((_t() - at) / 1000.0))
	if sec < 60:
		return "vừa xong"
	if sec < 3600:
		return str(int(sec / 60.0)) + " phút trước"
	if sec < 86400:
		return str(int(sec / 3600.0)) + " giờ trước"
	return str(int(sec / 86400.0)) + " ngày trước"

func guard_on() -> bool:
	return not str(me.get("guard", "")).is_empty() and _mf("gAt") > _t()

func target_shown() -> bool:
	var raid: Variant = running_raid()
	if target == null:
		return false
	if raid != null and int(raid["owner"]) == int(target["id"]):
		return true
	return int(target["done"]) == 0 and float(target["at"]) > _t()

func mates_need_help() -> bool:
	if _mi("guild") <= 0 or _mi("helps") <= 0:
		return false
	for mate: Dictionary in mates:
		if int(mate["water"]) > 0 or int(mate["bugs"]) > 0:
			return true
	return false


func shop_at(id: String) -> Variant:
	var per: int = 12
	var at_page: int = mini(page, pages_of(shop.size(), per) - 1)
	for i in shop.size():
		if str(shop[i]["id"]) == id:
			if int(i / float(per)) != at_page:
				return null
			var k: int = i - at_page * per
			return Vector2(float(FM_SHOP[0]) + float(k % 4) * float(FM_SHOP[2]) + float(FM_SHOP_ICON[0]), 
				float(FM_SHOP[1]) + float(int(k / 4.0)) * float(FM_SHOP[3]) + float(FM_SHOP_ICON[1]))
	return null

func shop_have(entry: Dictionary) -> int:
	var one: Variant = seed_of(str(entry["crop"]))
	return int(one["have"]) if one != null else 0

func shop_ready() -> bool:
	for entry: Dictionary in shop:
		if int(entry["left"]) > 0 and shop_have(entry) >= int(entry["cost"]):
			return true
	return false


func sig_of() -> String:
	var now: float = _t()
	var parts: Array = [tab, visit, thieves.size(), 1 if _mf("askAt") > now else 0, 1 if guard_on() else 0, 1 if running_raid() != null else 0, 
		1 if target_shown() else 0]
	for pot: Dictionary in pots:
		parts.append(stage(pot))
	if visit_data != null:
		for pot: Dictionary in visit_data["pots"]:
			parts.append(stage(pot))
	if target != null:
		for pot: Dictionary in target["pots"]:
			parts.append(stage(pot, true))
	for thief: Dictionary in thieves:
		parts.append(1 if float(thief["at"]) > now else 0)
	return ",".join(parts.map( func(v: Variant) -> String: return str(v)))

static func pot_x(slot: int) -> float:
	return float(FM_POTS[slot * 2])

static func pot_y(slot: int) -> float:
	return float(FM_POTS[slot * 2 + 1])




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


func can_pay(cur: String, price: int) -> bool:
	var have: int = int(money.get(cur, -1))
	if have >= 0 and have < price:
		tip("Không đủ " + cur_name(cur) + ": cần " + num(price) + ", đang có " + num(have) + ".")
		return false
	return true


func on_tab(i: int) -> void :
	if i < 0 or i > 4 or (i == tab and not (i == 1 and visit > 0)):
		return
	tab = i
	s_fm_tab = 0 if i == 2 else i
	page = 0
	visit = 0
	visit_data = null
	arm_key = ""
	arm_at = 0.0
	_rebuild()

func on_page(step: int) -> void :
	page = maxi(0, page + step)
	_rebuild()


func on_pot(id: String) -> void :
	var key: Variant = _keys.get(id)
	if key == null or busy():
		return
	var i: int = int(key["i"])
	match str(key["kind"]):
		"plant":
			pop = "seed"
			pop_slot = i
			_rebuild()
		"harvest":
			act("harvest", "&i=" + str(i), [i])
		"grow":
			tip(crop_name(str(key["s"])) + " còn " + left_text(float(key["at"]), now_ms()) + " nữa mới chín.")
		"buy":
			var price: int = _mi("potPrice")
			var cur: String = str(me.get("potCur", ""))
			if not can_pay(cur, price):
				return
			if armed("pot", id, "Bấm lần nữa để mở chậu thứ " + str(i + 1) + " giá " + num(price) + " " + cur_name(cur) + "."):
				act("pot", "", [i])
		"lock":
			tip("Mở các chậu phía trước trước nhé.")

func on_bug(id: String) -> void :
	var key: Variant = _keys.get(id)
	if key == null:
		return
	var o: int = int(key["o"])
	act("bug", "&i=" + str(key["i"]) + "&b=" + str(key["b"]) + ("&o=" + str(o) if o > 0 else ""), [int(key["slot"])], o)

func on_water(id: String) -> void :
	var key: Variant = _keys.get(id)
	if key == null:
		return
	var o: int = int(key["o"])
	act("water", "&i=" + str(key["i"]) + ("&o=" + str(o) if o > 0 else ""), [int(key["slot"])], o)

func on_chase(id: String) -> void :
	var thief: Variant = _keys.get(id)
	if thief == null:
		return
	act("chase", "&r=" + str(thief["id"]), [int(thief["slot"])])

func on_all() -> void :
	var ripe: Array = own_ripe()
	if ripe.is_empty():
		tip("Chưa có cây nào chín.")
		return
	act("harvest", "&i=-1", ripe)

func on_thue() -> void :
	pop = "guard"
	pop_guard = str(me.get("guard", "")) if guard_on() else ""
	if pop_guard.is_empty() and not guards.is_empty():
		pop_guard = str(guards[mini(1, guards.size() - 1)]["id"])
	arm_key = ""
	_rebuild()

func on_seed_pick() -> void :
	pop = "seed"
	pop_slot = -1
	arm_key = ""
	_rebuild()

func on_pop_close() -> void :
	pop = ""
	arm_key = ""
	arm_at = 0.0
	_rebuild()

func on_gieo(id: String) -> void :
	var one: Variant = _keys.get(id)
	if one == null:
		return
	var slots: Array = [pop_slot] if pop_slot >= 0 else empty_pots().slice(0, int(one["n"]))
	act("plant", "&s=" + str(one["id"]) + "&i=" + str(pop_slot), slots)

func on_mua(id: String) -> void :
	var one: Variant = _keys.get(id)
	if one == null or busy():
		return
	var key: String = "seed:" + str(one["id"])
	var cur: String = str(one["cur"])
	if not can_pay(cur, int(one["price"])):
		return
	if armed(key, id, "Bấm MUA lần nữa để mua 1 hạt " + str(one["label"]) + " giá " + num(int(one["price"])) + " " + cur_name(cur) + "."):
		re_arm = key
		act("seed", "&s=" + str(one["id"]) + "&n=1")

func on_guard_pick(id: String) -> void :
	if id == pop_guard:
		return
	pop_guard = id
	arm_key = ""
	arm_at = 0.0
	_rebuild()

func on_pill(id: String) -> void :
	var sel: Variant = guard_of(pop_guard)
	var h: int = int(_keys.get(id, 0))
	if sel == null or h <= 0 or busy():
		return
	var cur: String = str(me.get("gcur", ""))
	var price: int = int(sel["price"]) * h
	if not can_pay(cur, price):
		return
	if armed("guard:" + str(sel["id"]) + ":" + str(h), id, "Bấm lần nữa để thuê " + str(sel["label"]) + " " + str(h) + " giờ giá " + num(price) + " "
			+ cur_name(cur) + "."):
		act("guard", "&g=" + str(sel["id"]) + "&h=" + str(h))

func on_visit(id: int) -> void :
	if id <= 0:
		return
	visit = id
	visit_data = null
	load_fm(state_url(), "visit", id)
	_rebuild()

func on_back() -> void :
	visit = 0
	visit_data = null
	_rebuild()

func can_raid() -> bool:
	if _mi("steals") <= 0:
		tip("Hôm nay bạn đã hết lượt trộm.")
		return false
	if _mi("searches") <= 0:
		tip("Hôm nay bạn đã hết lượt dò vườn.")
		return false
	return true

func on_search() -> void :
	if can_raid():
		act("search", "")

func on_revenge(id: int) -> void :
	if id > 0 and can_raid():
		act("search", "&r=" + str(id))

func on_steal(id: String) -> void :
	var key: Variant = _keys.get(id)
	if key == null:
		return
	if _mi("steals") <= 0:
		tip("Hôm nay bạn đã hết lượt trộm.")
		return
	act("steal", "&i=" + str(key["i"]), [int(key["slot"])])

func on_doi(id: String) -> void :
	var entry: Variant = _keys.get(id)
	if entry == null or busy():
		return
	var have: int = shop_have(entry)
	if int(entry["left"]) <= 0:
		tip("Đã hết lượt đổi " + ("tháng" if str(entry["per"]) == "m" else "tuần") + " này.")
		return
	if have < int(entry["cost"]):
		tip("Cần " + num(int(entry["cost"])) + " " + crop_name(str(entry["crop"])) + ", bạn đang có " + num(have) + ".")
		return
	if armed("shop:" + str(entry["id"]), id, "Bấm ĐỔI lần nữa để đổi " + str(entry["label"]) + " lấy " + num(int(entry["cost"])) + " "
			+ crop_name(str(entry["crop"])) + "."):
		shop_id = str(entry["id"])
		act("shop", "&e=" + TevWheel.uri_component(str(entry["id"])) + "&n=1")



func _slot_fx(slots: Array, name: String, tpf: int) -> void :
	for slot: Variant in slots:
		if int(slot) >= 0 and int(slot) < 9:
			fx_burst(name, Vector2(pot_x(int(slot)), pot_y(int(slot)) - 30.0), tpf)

func _crops_fly(got: Dictionary, cx: float, cy: float) -> void :
	var k: int = 0
	for i in 3:
		var crop: String = CROPS[i]
		var n: int = int(got.get(crop, 0))
		if n > 0:
			var to: Vector2 = Vector2(float(FM_CROP_TEXT[i * 4]) - 22.0, float(FM_CROP_TEXT[i * 4 + 1]) + float(FM_CROP_TEXT[i * 4 + 3]) / 2.0)
			for j in mini(5, n):
				fx_fly("ic_" + crop + "_32", Vector2(cx, cy), to, j)
			float_text("+" + num(n) + " " + crop_name(crop), FM_GOLD, FM_INK, Vector2(cx, cy - 40.0 - 24.0 * k))
			k += 1


func done_fx(a: String, done: Dictionary) -> void :
	var slots: Array = act_slots
	var cx: float = float(FM_GARDEN[0]) + float(FM_GARDEN[2]) / 2.0
	var cy: float = float(FM_GARDEN[1]) + float(FM_GARDEN[3]) / 2.0
	if slots.size() > 0 and int(slots[0]) >= 0 and int(slots[0]) < 9:
		cx = pot_x(int(slots[0]))
		cy = pot_y(int(slots[0])) - 30.0
	if a == "plant":
		_slot_fx(slots, "fx_leaf", 3)
		fx_sparkles("fx_sparkle", Vector2(cx, cy), 2)
	elif a == "harvest":
		_slot_fx(slots, "fx_leaf", 2)
		_crops_fly(done["got"], cx, cy)
		cheer_at = tick + 60
	elif a == "water":
		fx_burst("fx_water", Vector2(cx, cy - 10.0), 3)
	elif a == "bug":
		fx_burst("fx_puff", Vector2(cx, cy - 20.0), 3)
	elif a == "chase":
		fx_burst("fx_dust", Vector2(cx + float(FM_THIEF[0]) + 52.0, cy + float(FM_THIEF[1]) + 80.0), 3)
		float_text("Đuổi được rồi!", FM_GOLD, FM_INK, Vector2(cx - 50.0, cy - 40.0))
		cheer_at = tick + 60
	elif a == "steal":
		if not str(done["blocked"]).is_empty():
			fx_burst("fx_puff", Vector2(float(FM_GATE[0]), float(FM_GATE[1]) - 60.0), 3)
			float_text("Bị chặn!", FM_SHORT, FM_CREAM, Vector2(float(FM_GATE[0]) + 40.0, float(FM_GATE[1]) - 110.0))
		elif int(done["raid"]) > 0:
			fx_sparkles("fx_sparkle", Vector2(cx, cy), 3)
		else:
			_slot_fx(slots, "fx_leaf", 2)
			_crops_fly(done["got"], cx, cy)
	elif a == "shop":
		var spot: Variant = shop_at(shop_id)
		for entry: Dictionary in shop:
			if str(entry["id"]) == shop_id and spot != null:
				if (entry["items"] as Array).size() > 0:
					fx_pop_item(int(entry["items"][0]["id"]), spot)
				fx_sparkles("fx_sparkle", spot, 3)
		cheer_at = tick + 60
	elif a == "free" or a == "seed":
		for i in 3:
			if a == "free" or pop.is_empty():
				fx_fly("seed_" + str(CROPS[i]), Vector2(float(FM_BTNS[6]) + 56.0, float(FM_BTNS[7])), 
					Vector2(float(FM_SEED_HIT[i * 4]) + float(FM_SEED_HIT[i * 4 + 2]) / 2.0, float(FM_SEED_HIT[i * 4 + 1]) + float(FM_SEED_HIT[i * 4 + 3]) / 2.0), i)
		if a == "seed" and pop == "seed":
			fx_sparkles("fx_sparkle", FM_POP + Vector2(240, 120), 2)
	elif a == "pot":
		fx_sparkles("fx_sparkle", Vector2(cx, cy), 4)
		cheer_at = tick + 60
	elif a == "guard":
		fx_sparkles("fx_sparkle", Vector2(float(FM_GATE[0]), float(FM_GATE[1]) - 60.0), 4)
		fx_sparkles("fx_sparkle", Vector2(float(FM_GUARD_PORT[0]) + 27.0, float(FM_GUARD_PORT[1]) + 24.0), 2)
	elif a == "ask":
		float_text("Đã nhờ guild!", FM_GOLD, FM_INK, Vector2(float(FM_BTNS[4]) + 56.0, float(FM_BTNS[5]) - 10.0))
	_teddy_show()


func float_text(text: String, color: Color, glow: Color, at: Vector2) -> void :
	var fx: Dictionary = fx_add("text", "", at, {"vy": -0.9, "life": 44, "fade": 14})
	fx["text"] = text
	fx["color"] = color
	fx["glow"] = glow



func ready_shown() -> bool:
	return _b_ready


func view() -> String:
	if tab == 0:
		return "own"
	if tab == 1:
		return "visit" if visit > 0 else "mates"
	if tab == 2:
		return "target" if target_shown() else "lobby"
	return "log" if tab == 3 else "shop"


func _rebuild() -> void :
	if not opened:
		return
	_bn = now_ms()
	_rows = {}
	_keys = {}
	_tip_ids = {}
	_money_text = {}
	_at = {}
	_glow_a = -1.0
	_pulse_a = -1.0
	_arm_id = ""
	_arm_a = -1.0
	_banner_a = 1.0
	_bob_t = -1
	_bug_step = -1
	_thief_key = "thief_a"
	_ring_now = _bn
	_teddy_dy = 0.0
	_b_busy = busy()
	_b_ready = art_pending() == 0 and art("fm_bg") != null and loaded and fm_visible
	_b_failed = art_pending() == 0 and art("fm_bg") == null
	if not _b_ready:
		return
	_drawing = true
	_b_view = view()
	for cur: String in CURS:
		_money_text[cur] = _money_shown(cur)
	if _b_view == "own" and arm_on("pot"):
		_arm_id = "pot:" + str(_mi("pots"))
	if _b_view == "shop":
		for entry: Dictionary in shop:
			if arm_on("shop:" + str(entry["id"])):
				_arm_id = "doi:" + str(entry["id"])
	if pop == "seed":
		for one: Dictionary in seeds:
			if arm_on("seed:" + str(one["id"])):
				_arm_id = "mua:" + str(one["id"])
	elif pop == "guard":
		var sel: Variant = guard_of(pop_guard)
		var hours: Array = me.get("gh", [])
		for i in mini(3, hours.size()):
			if sel != null and arm_on("guard:" + str(sel["id"]) + ":" + str(hours[i])):
				_arm_id = "pill:" + str(hours[i])
	sig = sig_of()
	_drawing = false
	_teddy_key = "teddy_a"
	_teddy_show()


func _teddy_show() -> void :
	var key: String = "teddy_b" if cheer_at > tick else "teddy_a"
	if art(key) != null:
		_teddy_key = key

func _money_shown(cur: String) -> String:
	var n: int = int(show_money[cur])
	return num(n) if n >= 0 else "--"


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




func _anim() -> void :
	if not _b_ready:
		return
	var a: float = 0.55 + 0.45 * sin(float(tick) * 0.12)
	_glow_a = 0.25 + 0.5 * a
	_pulse_a = 0.3 + 0.5 * a
	_bob_t = tick
	if not _arm_id.is_empty():
		if arm_at != 0.0 and now_ms() - arm_at <= MB_ARM_MS:
			_arm_a = 0.5 + 0.5 * a
		else:
			_arm_id = ""
			_arm_a = -1.0
			arm_key = ""
			arm_at = 0.0
	_banner_a = 0.7 + 0.3 * a
	if tick % 10 == 0:
		_bug_step = int(tick / 10.0)
	if tick % 8 == 0:
		_thief_key = "thief_a" if int(tick / 8.0) % 2 == 0 else "thief_b"
	if tick % 5 == 0:
		_teddy_show()
		_ring_now = now_ms()
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
			_money_text[cur] = _money_shown(cur)
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
		elif pop.is_empty() and not busy() and sig_of() != sig:
			_rebuild()

		open_poll += 1
		var wait: int = mini(15, maxi(5, _mi("poll")))
		if open_poll >= wait and not loading:
			open_poll = 0
			poll()
	if tick % 30 == 0:
		_ambient()


func _ambient() -> void :
	var ripe: Array = own_ripe() if tab == 0 and pop.is_empty() else []
	if ripe.is_empty() or randf() < 0.3:
		return
	var slot: int = int(ripe[randi() % ripe.size()])
	if slot >= 0 and slot < 9:
		fx_sparkles("fx_sparkle", Vector2(pot_x(slot), pot_y(slot) - 50.0), 1)




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
		_dbtext(at + Vector2(float(fx["x"]) - 100.0, float(fx["y"]) - 12.0), 200.0, 24.0, 16.0, Color(fx["color"], alpha), Color(fx.get("glow", FM_INK), alpha), 
			"center", str(fx["text"]))


func _draw_tips() -> void :
	var keep: String = _hover
	if _tip_ids.has(_hover):
		_hover = "panel"
	super ()
	_hover = keep

func _draw() -> void :
	super ()
	if _hover == POP_DIM:
		mouse_default_cursor_shape = CURSOR_ARROW


func _ft(x: float, y: float, w: float, h: float, px: float, text: String, align: String = "center", color: Color = FM_DARK) -> void :
	_dbtext(_o + Vector2(x, y), w, h, px, color, NONE, align, text)


func _fit_line(x: float, y: float, w: float, h: float, px: int, text: String) -> void :
	var fs: int = px
	while text_width(text, float(fs)) > w - 4.0 and fs > 9:
		fs -= 1
	_ft(x, y, w, h, float(fs), text)


func _note(x: float, y: float, w: float, h: float, px: float, text: String, align: String = "center") -> int:
	return _para(_o + Vector2(x, y), w, h, px, FM_DARK, NONE, text, align)


func _center_note(text: String) -> void :
	_note(float(FM_BOARD_IN[0]) + 20.0, float(FM_BOARD_IN[1]), float(FM_BOARD_IN[2]) - 40.0, float(FM_BOARD_IN[3]) - 40.0, 14.0, text)


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
	if not glow.is_empty() and state == 1 and _glow_a >= 0.0:
		pic(glow, corner - Vector2(FM_GLOW_PAD, FM_GLOW_PAD), _glow_a)
	if not arm.is_empty() and _arm_id == id and _arm_a >= 0.0:
		pic(arm, corner - Vector2(FM_ARM_PAD, FM_ARM_PAD), _arm_a)
	var shown: Array = art_button(id, name, corner, state)
	shown.append(state)
	return shown


func _fm_face(shown: Array, name: String, text: String, icon_name: String, short: bool) -> void :
	var cell: Vector2 = art_size(name)
	if cell.x <= 0.0:
		return
	var face: Vector2 = (shown[0] as Rect2).position / _f + Vector2(0, 1 if int(shown[1]) == 2 else 0)
	var alpha: float = 0.75 if int(shown[2]) == 0 else 1.0
	_dbtext(face + Vector2(4, 0), cell.x - 26.0, cell.y, 12.0, Color(FM_SHORT if short else FM_DARK, alpha), NONE, "center", text)
	var coin: Texture2D = art(icon_name)
	if coin != null:
		pic(icon_name, face + Vector2(cell.x - 14.0, float(int(cell.y / 2.0))) - Vector2(floorf(coin.get_width() / 2.0), floorf(coin.get_height() / 2.0)), alpha)


func _fit(name: String, x: float, y: float, w: float, h: float) -> void :
	var texture: Texture2D = art(name)
	if texture == null:
		return
	var box: Array = FmAtlas.B.get(name, [0, 0, texture.get_width(), texture.get_height()])
	var bw: float = maxf(1.0, float(box[2]))
	var bh: float = maxf(1.0, float(box[3]))
	var k: float = minf(w / bw, h / bh)
	var corner: Vector2 = _o + Vector2(x + (w - bw * k) / 2.0 - float(box[0]) * k, y + (h - bh * k) / 2.0 - float(box[1]) * k)
	draw_texture_rect(texture, Rect2(corner * _f, Vector2(texture.get_size()) * k * _f), false)

func _pic_at(name: String, x: float, y: float, alpha: float = 1.0) -> void :
	pic(name, _o + Vector2(x, y), alpha)

func _pic_c(name: String, x: float, y: float, alpha: float = 1.0) -> void :
	pic_c(name, _o + Vector2(x, y), alpha)


func _para(at: Vector2, w: float, h: float, px: float, color: Color, glow: Color, text: String, align: String = "center", least: float = 8.0) -> int:
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
	return lines.size()

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



func _body(at: Vector2) -> void :
	_o = at
	_tip_ids = {}
	if not _b_ready:
		_wait_panel(at, _b_failed)
		return
	_drawing = true
	pic("fm_bg", at)
	if broken:
		_ft(float(FM_GARDEN[0]), float(FM_GARDEN[1]) + float(int(float(FM_GARDEN[3]) / 2.0)) - 15.0, float(FM_GARDEN[2]), 30.0, 15.0, 
			"Nông Trại đang bảo trì, hãy thử lại sau.")
		_close_btn()
		_drawing = false
		return
	if _b_view == "target" and int(target["id"]) < 0:
		pic("wild_overlay", at)
	_side()
	_tabs()
	match _b_view:
		"own":
			_own()
		"visit":
			_visit()
		"mates":
			_mates()
		"target":
			_target()
		"lobby":
			_lobby()
		"log":
			_log()
		_:
			_shop()
	if pop == "seed":
		_seed_pop()
	elif pop == "guard":
		_guard_pop()
	_close_btn()
	_drawing = false

func _close_btn() -> void :
	if art("btn_close_st") != null:
		art_button("close", "btn_close_st", _o + FM_CLOSE, 1)
	rules_button(_o + Vector2(803, 35))


func rules_title() -> String:
	return "LUẬT CHƠI · NÔNG TRẠI"

func rules_text() -> String:
	return ("Trồng cây, thu nông sản rồi sang tab Đổi Quà đổi lấy vật phẩm. Quà đổi giới hạn theo tuần, tính từ thứ Hai."
		+ "\n• Cà Rốt chín sau 2 giờ (30 củ mỗi chậu), Dưa Hấu 8 giờ (20 quả), Kim Tiền 24 giờ (10 Quả Vàng)."
		+ " Mỗi ngày bấm NHẬN HẠT được 3 hạt Cà Rốt và 1 hạt Dưa Hấu; hạt khác mua bằng Bạc / Xu khóa hoặc đổi ở Đổi Quà."
		+ "\n• Có sẵn 3 chậu, mua thêm bằng Xu tới 9 chậu. Cây không héo, nhưng chín mà chưa hái thì dễ bị trộm."
		+ "\n• Tưới cây: mỗi lượt rút 10% thời gian lớn (chủ vườn 1 lượt, bạn guild thêm 3 lượt). Mỗi con sâu còn trên cây lúc hái làm mất 15% sản lượng, bấm vào sâu để bắt."
		+ "\n• Giúp bạn guild tưới hoặc bắt sâu được 3 Cà Rốt mỗi lần, 10 lần có thưởng mỗi ngày. NHỜ GUILD gọi bạn tới giúp, 60 phút một lần."
		+ "\n• Đi trộm: 6 lượt trộm và 20 lần dò vườn mỗi ngày. Mỗi vụ lấy 10% sản lượng chậu, một chậu mất tối đa 30%."
		+ " Người mới được bảo hộ 48 giờ, người cùng guild không trộm được của nhau."
		+ "\n• Có kẻ trộm thì chủ vườn có 30 giây để bấm ĐUỔI. Thuê trợ thủ canh vườn bằng Xu khóa: Nữ Hoàng Bọ Cạp chặn 30%, Cửu Vĩ Hồ 50%, Phượng Hoàng 70%."
		+ "\n• Nhật Ký giữ 7 ngày; bấm TRẢ THÙ để sang thẳng vườn kẻ đã trộm của mình.")


func _chrome(at: Vector2) -> void :
	if not _b_ready or art("btn_close_st") == null:
		_native_close(at)


func _side() -> void :
	var tips: Array = ["Bạc đang có.", "Xu khóa đang có.", "Xu đang có."]
	for i in 3:
		var x: float = float(FM_WALLET_TEXT[i * 4])
		var y: float = float(FM_WALLET_TEXT[i * 4 + 1])
		var w: float = float(FM_WALLET_TEXT[i * 4 + 2])
		var h: float = float(FM_WALLET_TEXT[i * 4 + 3])
		_ft(x, y, w, h, 13.0, str(_money_text.get(CURS[i], "--")), "right")
		_tipr(x - 110.0, y - 2.0, w + 112.0, h + 4.0, str(tips[i]))
	var g_on: bool = guard_on()
	var gid: String = str(me.get("guard", ""))
	if g_on:
		_fit("guard_" + gid, float(FM_GUARD_PORT[0]) + 2.0, float(FM_GUARD_PORT[1]) + 2.0, float(FM_GUARD_PORT[2]) - 4.0, float(FM_GUARD_PORT[3]) - 4.0)
	_ft(float(FM_GUARD_TEXT[0]), float(FM_GUARD_TEXT[1]), float(FM_GUARD_TEXT[2]), float(FM_GUARD_TEXT[3]), 13.0, 
		guard_name(gid) if g_on else "Chưa có trợ thủ", "left")
	_ft(float(FM_GUARD_TEXT[4]), float(FM_GUARD_TEXT[5]), float(FM_GUARD_TEXT[6]), float(FM_GUARD_TEXT[7]), 12.0, 
		_row_text("guard", _mf("gAt"), "", "", "Hết hạn", 1) if g_on else "--", "left")
	var gd: Variant = guard_of(gid) if g_on else null
	_tipr(float(FM_GUARD_PORT[0]), float(FM_GUARD_TEXT[1]), 142.0, 54.0, str(gd["label"]) + " canh cổng vườn, chặn " + str(gd["bl"]) + "% kẻ trộm."
		+ ("\nKẻ bị chặn mất thêm " + str(gd["burn"]) + " lượt trộm." if int(gd["burn"]) > 0 else "") if gd != null
		else "Thuê trợ thủ canh cổng vườn để chặn kẻ trộm.")
	_btn("thue", "btn_thue_st", float(FM_BTNS[0]), float(FM_BTNS[1]), guards.size() > 0)
	for i in 3:
		var one: Variant = seed_of(CROPS[i])
		var n: int = int(one["n"]) if one != null else 0
		var have: int = int(one["have"]) if one != null else 0
		var sx: float = float(FM_SEED_TEXT[i * 4])
		var sy: float = float(FM_SEED_TEXT[i * 4 + 1])
		_ft(sx, sy, float(FM_SEED_TEXT[i * 4 + 2]), float(FM_SEED_TEXT[i * 4 + 3]), 10.0 if n >= 1000 else 13.0, num(n))
		var cx: float = float(FM_CROP_TEXT[i * 4])
		var cy: float = float(FM_CROP_TEXT[i * 4 + 1])
		var cw: float = float(FM_CROP_TEXT[i * 4 + 2])
		var ch: float = float(FM_CROP_TEXT[i * 4 + 3])
		_ft(cx, cy, cw + 8.0, ch, 10.0 if have >= 1000 else 13.0, num(have), "left")
		if one != null:
			_tipr(cx - 44.0, cy - 16.0, 44.0 + cw, ch + 22.0, str(one["crop"]) + " đã thu: " + num(have) + ".\nDùng để đổi quà ở mục ĐỔI QUÀ.")
			_click("seedpick:" + str(i), float(FM_SEED_HIT[i * 4]), float(FM_SEED_HIT[i * 4 + 1]), float(FM_SEED_HIT[i * 4 + 2]), 
				float(FM_SEED_HIT[i * 4 + 3]), str(one["label"]) + ": có " + num(n) + " hạt, chín sau " + dur(int(one["grow"]))
				+ ".\nBấm để chọn hạt gieo hoặc mua thêm.")
	if art(_teddy_key) != null:
		_pic_at(_teddy_key, FM_TEDDY.x, FM_TEDDY.y + _teddy_dy)
	_btn("all", "btn_all_st", float(FM_BTNS[2]), float(FM_BTNS[3]), own_ripe().size() > 0, "btn_all_glow")
	var ask_ok: bool = _mi("guild") > 0 and _mf("askAt") <= _t()
	if not ask_ok:
		_tipr(float(FM_BTNS[4]), float(FM_BTNS[5]), 112.0, 36.0, "Vào guild để nhờ bạn bè tưới cây, bắt sâu." if _mi("guild") <= 0
			else "Vừa nhờ guild rồi, nhờ lại sau " + left_text(_mf("askAt"), _t()) + ".")
	_btn("ask", "btn_ask_st", float(FM_BTNS[4]), float(FM_BTNS[5]), ask_ok)
	if _mi("free") != 1:
		_tipr(float(FM_BTNS[6]), float(FM_BTNS[7]), 112.0, 36.0, "Hôm nay đã nhận hạt miễn phí, mai quay lại nhé.")
	_btn("free", "btn_free_st", float(FM_BTNS[6]), float(FM_BTNS[7]), _mi("free") == 1, "btn_free_glow")


func _tabs() -> void :
	var dots: Array = [own_ripe().size() > 0 or thieves.size() > 0, mates_need_help(), target_shown() or running_raid() != null, false, shop_ready()]
	var w: float = maxf(60.0, _w("tab1_on"))
	var h: float = maxf(24.0, _h("tab1_on"))
	for i in 5:
		var x: float = float(FM_TABS[i * 2])
		var y: float = float(FM_TABS[i * 2 + 1])
		_pic_at("tab" + str(i + 1) + ("_on" if i == tab else "_off"), x, y)
		if dots[i] and i != tab:
			var centre: Vector2 = (_o + Vector2(x + w - 8.0, y + 6.0)) * _f
			draw_circle(centre, 6.0 * _f, FM_DOT)
			draw_arc(centre, 6.0 * _f, 0.0, TAU, 24, Color.WHITE, 2.0 * _f, true)
		_click("tab:" + str(i), x, y, w, h)


func _cell(slot: int, crop: String, st: int, mode: String) -> void :
	var x: float = pot_x(slot) - float(FM_POT_C[0])
	var y: float = pot_y(slot) - float(FM_POT_C[1])
	if mode == "locked":
		_pic_at("pot_locked", x, y)
		return
	_pic_at("pot_back", x, y)
	if not crop.is_empty() and st > 0:
		_pic_at("crop_" + crop + "_" + str(mini(4, st)), pot_x(slot) - float(FM_CROP_ROOT[0]), pot_y(slot) - float(FM_CROP_ROOT[1]))
	_pic_at("pot_front", x, y)
	if mode == "plus":
		_pic_at("pot_plus", x, y)


func _fm_plate(slot: int, kind: String, text: String, pulse: bool = false) -> void :
	var x: float = pot_x(slot) + float(FM_PLATE[0])
	var y: float = pot_y(slot) + float(FM_PLATE[1])
	if pulse and _pulse_a >= 0.0:
		_pic_at("plate_" + kind + "_pulse", x - FM_PULSE_PAD, y - FM_PULSE_PAD, _pulse_a)
	_pic_at("plate_" + kind, x, y)
	_ft(x + float(FM_PLATE_TEXT[0]), y + float(FM_PLATE_TEXT[1]), float(FM_PLATE_TEXT[2]), float(FM_PLATE_TEXT[3]), 12.0, text)


func _pot_hit(slot: int, key: Dictionary, text: String = "") -> void :
	var id: String = "pot:" + str(slot)
	_keys[id] = key
	_click(id, pot_x(slot) - 50.0, pot_y(slot) - 54.0, 100.0, 104.0, text)

func _gate_guard(id: String) -> void :
	if not id.is_empty():
		_pic_at("guard_" + id, float(FM_GATE[0]) - float(FM_GUARD_C[0]), float(FM_GATE[1]) - float(FM_GUARD_C[1]))


func _bugs(pot: Dictionary, slot: int, o: int) -> void :
	var st: int = stage(pot)
	if st < 1:
		return
	var base: int = 0 if st <= 2 else 4
	for k in 2:
		if (int(pot["b"]) & (1 << k)) == 0:
			continue
		var first: String = "bug_a" if k == 0 else "bug_b"
		if art(first) == null:
			continue
		var x: float = pot_x(slot) + float(FM_BUGS[base + k * 2])
		var y: float = pot_y(slot) + float(FM_BUGS[base + k * 2 + 1])
		var shown: String = first if _bug_step < 0 else ("bug_a" if (_bug_step + k) % 2 == 0 else "bug_b")
		_pic_at(shown if art(shown) != null else first, x, y)
		var size: Vector2 = art_size(first)
		var id: String = "bug:" + str(slot) + ":" + str(k)
		_keys[id] = {"i": int(pot["i"]), "b": k, "o": o, "slot": slot}
		_click(id, x - 6.0, y - 6.0, size.x + 12.0, size.y + 12.0)


func _water(pot: Dictionary, slot: int, o: int) -> void :
	if art("badge_water") == null:
		return
	var bob: float = 0.0 if _bob_t < 0 else float(roundi(2.0 * sin(float(_bob_t) * 0.15 + float(slot))))
	var x: float = pot_x(slot) + float(FM_WATER[0])
	var y: float = pot_y(slot) + float(FM_WATER[1]) + bob
	if _pulse_a >= 0.0:
		_pic_at("badge_water_pulse", x - FM_PULSE_PAD, y - FM_PULSE_PAD, _pulse_a)
	_pic_at("badge_water", x, y)
	var size: Vector2 = art_size("badge_water")
	var id: String = "water:" + str(slot)
	_keys[id] = {"i": int(pot["i"]), "o": o, "slot": slot}
	_click(id, x - 6.0, y - 4.0, size.x + 12.0, size.y + 8.0)


func _thief_at(slot: int, at: float, own: bool, thief: Variant) -> void :
	var cx: float = pot_x(slot)
	var cy: float = pot_y(slot)
	_pic_at(_thief_key, cx + float(FM_THIEF[0]), cy + float(FM_THIEF[1]))
	var rx: float = cx + float(FM_RING[0])
	var ry: float = cy + float(FM_RING[1])
	_pic_c("ring_bg", rx, ry)
	var left: float = maxf(0.0, at - _ring_now)
	var frac: float = minf(1.0, left / (_mf("rs") * 1000.0))
	if frac > 0.0:
		var r: float = 21.0
		var steps: int = maxi(1, int(frac * 40.0))
		var points: PackedVector2Array = PackedVector2Array([(_o + Vector2(rx, ry - r)) * _f])
		for i in steps + 1:
			var a: float = - PI / 2.0 + 2.0 * PI * frac * float(i) / float(steps)
			points.append((_o + Vector2(rx + cos(a) * r, ry + sin(a) * r)) * _f)
		draw_polyline(points, FM_OWN_RING if own else FM_SHORT, 4.0 * _f, true)
	_dbtext(_o + Vector2(rx - 24.0, ry - 11.0), 48.0, 22.0, 14.0, FM_CREAM, FM_INK, "center", str(ceili(left / 1000.0)))
	if thief != null:
		var id: String = "duoi:" + str(thief["id"])
		_keys[id] = thief
		_btn(id, "btn_duoi_st", cx + float(FM_DUOI[0]), cy + float(FM_DUOI[1]), true, "btn_duoi_glow")


func _own() -> void :
	var count: int = _mi("pots")
	var top: int = mini(9, _mi("maxPots"))
	var price: String = num(_mi("potPrice"))
	var cur: String = str(me.get("potCur", ""))
	var keys: Array = []
	keys.resize(9)
	_gate_guard(str(me.get("guard", "")) if guard_on() else "")
	for i in 9:
		var pot: Variant = pots[i] if i < pots.size() else null
		if i < count and pot != null:
			var st: int = stage(pot)
			_cell(i, str(pot["s"]), st, "plus" if st == 0 else "")
			keys[i] = {"kind": "plant", "i": i} if st == 0 else ({"kind": "harvest", "i": i} if st == 4
				else {"kind": "grow", "i": i, "s": pot["s"], "at": pot["at"]})
		elif i == count and count < top:
			if _arm_id == "pot:" + str(i) and _arm_a >= 0.0:
				_pic_at("pot_locked_arm", pot_x(i) - float(FM_POT_C[0]) - FM_ARM_PAD, pot_y(i) - float(FM_POT_C[1]) - FM_ARM_PAD, _arm_a)
			_cell(i, "", 0, "locked")
			keys[i] = {"kind": "buy", "i": i}
		elif i < top:
			_cell(i, "", 0, "locked")
			keys[i] = {"kind": "lock", "i": i}
	for i in 9:
		if keys[i] == null:
			continue
		var kind: String = str(keys[i]["kind"])
		var pot: Variant = pots[i] if i < pots.size() else null
		if kind == "plant":
			_fm_plate(i, "timer", "TRỒNG")
		elif kind == "harvest":
			_fm_plate(i, "ripe", "CHÍN ×" + str(int(pot["y"])), true)
		elif kind == "grow":
			_fm_plate(i, "timer", _row_text("plate:" + str(i), float(pot["at"]), "", "", "CHÍN"))
		elif kind == "buy":
			var x: float = pot_x(i) + float(FM_PLATE[0])
			var y: float = pot_y(i) + float(FM_PLATE[1])
			_pic_at("plate_timer", x, y)
			_pic_c(cur_icon(cur, 16), x + float(FM_PLATE_TEXT[0]) + 10.0, y + float(FM_PLATE_TEXT[1]) + float(FM_PLATE_TEXT[3]) / 2.0)
			_ft(x + float(FM_PLATE_TEXT[0]) + 20.0, y + float(FM_PLATE_TEXT[1]), float(FM_PLATE_TEXT[2]) - 20.0, float(FM_PLATE_TEXT[3]), 12.0, price)
	for i in 9:
		if keys[i] != null:
			var kind: String = str(keys[i]["kind"])
			_pot_hit(i, keys[i], "Mở chậu thứ " + str(i + 1) + ": " + price + " " + cur_name(cur) + "." if kind == "buy" else "")
	var i: int = 0
	while i < count and i < pots.size():
		var pot: Dictionary = pots[i]
		var st: int = stage(pot)
		_bugs(pot, i, 0)
		if int(pot["cw"]) == 1 and st >= 1 and st <= 3:
			_water(pot, i, 0)
		i += 1
	for thief: Dictionary in thieves:
		if int(thief["slot"]) >= 0 and int(thief["slot"]) < 9:
			_thief_at(int(thief["slot"]), float(thief["at"]), false, thief)
	if thieves.size() > 0:
		_pic_at("banner_thief", FM_BANNER.x, FM_BANNER.y, _banner_a)


func _sign(title: String, sub: String) -> void :
	var x: float = float(FM_TARGET[0])
	var y: float = float(FM_TARGET[1])
	_pic_at("plate_target", x, y)
	_fit_line(x + float(FM_TARGET_TEXT[0]) + 4.0, y + float(FM_TARGET_TEXT[1]), float(FM_TARGET_TEXT[2]) - 8.0, float(FM_TARGET_TEXT[3]), 14, title)
	_fit_line(x + float(FM_TARGET_TEXT[4]) + 4.0, y + float(FM_TARGET_TEXT[5]), float(FM_TARGET_TEXT[6]) - 8.0, float(FM_TARGET_TEXT[7]), 11, sub)


func _visit() -> void :
	var data: Variant = visit_data
	var list: Array = data["pots"] if data != null else []
	var helps: int = _mi("helps")
	if data == null:
		_visit_sign(data, helps)
		return
	for i in 9:
		var pot: Variant = list[i] if i < list.size() else null
		if pot != null:
			_cell(i, str(pot["s"]), stage(pot), "")
		else:
			_cell(i, "", 0, "locked")
	for i in mini(9, list.size()):
		var st: int = stage(list[i])
		if st == 4:
			_fm_plate(i, "ripe", "CHÍN")
		elif st > 0:
			_fm_plate(i, "timer", _row_text("plate:" + str(i), float(list[i]["at"]), "", "", "CHÍN"))
	for i in mini(9, list.size()):
		var pot: Dictionary = list[i]
		var st: int = stage(pot)
		if st > 0 and st < 4:
			_pot_hit(i, {"kind": "grow", "i": i, "s": pot["s"], "at": pot["at"]})
		_bugs(pot, i, int(data["id"]))
		if int(pot["cw"]) == 1 and st >= 1 and st <= 3:
			_water(pot, i, int(data["id"]))
	_visit_sign(data, helps)


func _visit_sign(data: Variant, helps: int) -> void :
	_sign("Vườn của " + str(data["who"]) if data != null else "Đang sang vườn...", ("Hôm nay còn " + str(helps) + " lượt giúp có thưởng" if helps > 0
		else "Hôm nay đã hết lượt giúp có thưởng") if data != null else "")
	_btn("back", "btn_back_st", float(FM_TARGET_BTN[0]), float(FM_TARGET_BTN[1]), true)


func _target() -> void :
	var tg: Dictionary = target
	var wild: bool = int(tg["id"]) < 0
	var list: Array = tg["pots"]
	var raid: Variant = running_raid()
	var mine_raid: bool = raid != null and int(raid["owner"]) == int(tg["id"])
	var is_open: bool = int(tg["done"]) == 0
	var slots: Array = []
	var steals: int = _mi("steals")
	var ripe: int = 0
	for i in mini(9, list.size()):
		slots.append(3 + i if wild else i)
		if stage(list[i], true) == 4 and int(list[i]["ok"]) == 1:
			ripe += 1
	var sub: String = ""
	if mine_raid:
		sub = _row_text("sign", float(raid["at"]), "Đang hái lén " + str(raid["n"]) + " " + crop_name(str(raid["s"])) + " · giữ yên ", "", 
			"Đang tính kết quả...", 1)
	else:
		sub = _row_text("sign", float(tg["at"]), ("Không có ai canh · " if wild else str(ripe) + " chậu hái được · ") + "còn " + str(steals)
			+ " lượt trộm · rời sau ", "", "Đã hết giờ ở vườn này", 1)
	_gate_guard(str(tg["guard"]))
	if not str(tg["guard"]).is_empty():
		_tipr(float(FM_GATE[0]) - 50.0, float(FM_GATE[1]) - 100.0, 100.0, 100.0, "Bù Nhìn đôi khi dọa kẻ trộm chạy mất." if wild
			else guard_name(str(tg["guard"])) + " đang canh cổng: có thể chặn bạn lại.")
	for i in 9:
		var at_slot: int = slots.find(i)
		if at_slot >= 0:
			_cell(i, str(list[at_slot]["s"]), stage(list[at_slot], true), "")
		elif not wild:
			_cell(i, "", 0, "locked")
	for i in slots.size():
		var pot: Dictionary = list[i]
		var slot: int = int(slots[i])
		var st: int = stage(pot, true)
		if st == 4:
			_fm_plate(slot, "ripe", "CHÍN" if int(pot["ok"]) == 1 or int(pot["rr"]) == 1 or wild else "HẾT PHẦN")
		elif st > 0:
			_fm_plate(slot, "timer", _row_text("plate:" + str(slot), float(pot["at"]), "", "", "CHÍN"))
	for i in slots.size():
		var pot: Dictionary = list[i]
		var slot: int = int(slots[i])
		if mine_raid and int(raid["slot"]) == int(pot["i"]):
			_thief_at(slot, float(raid["at"]), true, null)
		elif int(pot["rr"]) == 1:
			_pic_at("thief_b", pot_x(slot) + float(FM_THIEF[0]), pot_y(slot) + float(FM_THIEF[1]))
		if is_open and int(pot["ok"]) == 1 and stage(pot, true) == 4:
			var id: String = "steal:" + str(slot)
			_keys[id] = {"i": int(pot["i"]), "slot": slot}
			_btn(id, "btn_steal_st", pot_x(slot) + float(FM_STEAL_BTN[0]), pot_y(slot) + float(FM_STEAL_BTN[1]), steals > 0 and not mine_raid, "btn_steal_glow")

	_sign("Vườn Hoang" if wild else "Vườn của " + str(tg["who"]), sub)
	_btn("search", "btn_search_st", float(FM_TARGET_BTN[0]), float(FM_TARGET_BTN[1]), steals > 0 and _mi("searches") > 0 and not mine_raid)


func _lobby() -> void :
	var steals: int = _mi("steals")
	var searches: int = _mi("searches")
	var x: float = float(FM_STEAL_INFO[0])
	var y: float = float(FM_STEAL_INFO[1])
	var w: float = float(FM_STEAL_INFO[2])
	var rx: float = float(FM_ROW[0])
	var icons: Array = ["lg_clock", "lg_thief", "lg_chase", "lg_shield"]
	_pic_at("fm_board", FM_BOARD.x, FM_BOARD.y)
	_ft(x, y, w, 26.0, 14.0, "Hôm nay còn " + str(steals) + " lượt trộm · " + str(searches) + " lượt dò vườn")
	_note(x, y + 26.0, w, float(FM_STEAL_INFO[3]) - 22.0, 12.0, "Dò vườn tìm cây chín rồi bấm HÁI LÉN. Giữ yên " + str(_mi("rs"))
		+ " giây: chủ vườn đuổi kịp là mất phần hái. Mỗi chậu chỉ bị hái tối đa " + str(_mi("cap")) + " lần.")
	_btn("search", "btn_search_st", float(FM_SEARCH[0]), float(FM_SEARCH[1]), steals > 0 and searches > 0 and running_raid() == null, "btn_search_glow")
	if mine.is_empty():
		_ft(float(FM_BOARD_IN[0]), float(FM_SEARCH[1]) + 90.0, float(FM_BOARD_IN[2]), 24.0, 12.0, "Hôm nay bạn chưa đi trộm vườn nào.")
		return
	for k in mini(3, mine.size()):
		var raid: Dictionary = mine[k]
		var ry: float = float(FM_SEARCH[1]) + 60.0 + float(k) * float(FM_ROW[2])
		var crop: String = crop_name(str(raid["s"]))
		_pic_at("row_list", rx, ry)
		_pic_c(str(icons[clampi(int(raid["st"]), 0, 3)]), rx + float(FM_ROW_ICON[0]), ry + float(FM_ROW_ICON[1]))
		_ft(rx + float(FM_ROW_TEXT[0]), ry + float(FM_ROW_TEXT[1]), float(FM_ROW_TEXT[2]), 17.0, 12.0, "Vườn của " + str(raid["who"]), "left")
		var line: String = ""
		match int(raid["st"]):
			0:
				line = _row_text("raid:" + str(k), float(raid["at"]), "Đang hái lén " + str(raid["n"]) + " " + crop + " · còn ", "", "Đang tính kết quả...", 1)
			1:
				line = "Đã lấy được " + str(raid["n"]) + " " + crop + "."
			2:
				line = "Bị chủ vườn đuổi, mất phần hái."
			_:
				line = "Chủ vườn thu hoạch trước, không lấy được gì."
		_ft(rx + float(FM_ROW_TEXT[0]), ry + float(FM_ROW_TEXT[1]) + 16.0, float(FM_ROW_TEXT[2]), 17.0, 11.0, line, "left")


func _row(y: float, icon_name: String, line1: String, line2: String) -> float:
	var x: float = float(FM_ROW[0])
	_pic_at("row_list", x, y)
	_pic_c(icon_name, x + float(FM_ROW_ICON[0]), y + float(FM_ROW_ICON[1]))
	_ft(x + float(FM_ROW_TEXT[0]), y + float(FM_ROW_TEXT[1]), float(FM_ROW_TEXT[2]), 17.0, 12.0, line1, "left")
	_ft(x + float(FM_ROW_TEXT[0]), y + float(FM_ROW_TEXT[1]) + 16.0, float(FM_ROW_TEXT[2]), 17.0, 11.0, line2, "left")
	return x


func _pager(p: int, pages: int, note: String) -> void :
	var x: float = float(FM_BOARD_IN[0])
	var y: float = float(FM_BOARD_IN[1]) + float(FM_BOARD_IN[3]) - 28.0
	var w: float = float(FM_BOARD_IN[2])
	_ft(x + 6.0, y, w - 140.0, 24.0, 12.0, note, "left")
	if pages <= 1:
		return
	_ft(x + w - 124.0, y, 120.0, 24.0, 13.0, "«   " + str(p + 1) + "/" + str(pages) + "   »")
	if p > 0:
		_click("page:-1", x + w - 124.0, y, 40.0, 24.0)
	if p < pages - 1:
		_click("page:1", x + w - 44.0, y, 40.0, 24.0)

static func pages_of(count: int, per: int) -> int:
	return maxi(1, ceili(float(count) / float(per)))


func _mates() -> void :
	var per: int = 6
	var pages: int = pages_of(mates.size(), per)
	var helps: int = _mi("helps")
	_pic_at("fm_board", FM_BOARD.x, FM_BOARD.y)
	if _mi("guild") <= 0:
		_center_note("Bạn chưa vào guild.\nVào guild để tưới cây, bắt sâu giúp bạn bè và nhận Cà Rốt.")
		return
	if mates.is_empty():
		_center_note("Guild chưa có ai khác trồng cây.")
		return
	page = mini(page, pages - 1)
	var i: int = page * per
	while i < mates.size() and i < (page + 1) * per:
		var mate: Dictionary = mates[i]
		var needs: Array = []
		if int(mate["water"]) > 0:
			needs.append(str(mate["water"]) + " chậu cần tưới")
		if int(mate["bugs"]) > 0:
			needs.append(str(mate["bugs"]) + " con sâu")
		if int(mate["ripe"]) > 0:
			needs.append(str(mate["ripe"]) + " chậu đã chín")
		var y: float = float(FM_ROW[1]) + float(i - page * per) * float(FM_ROW[2])
		var x: float = _row(y, "lg_water" if int(mate["water"]) > 0 else ("lg_bug" if int(mate["bugs"]) > 0 else "lg_clock"), str(mate["who"]), 
			" · ".join(needs) if needs.size() > 0 else "Vườn đang ổn.")
		_btn("visit:" + str(mate["id"]), "btn_visit_st", x + float(FM_ROW_BTN[0]), y + float(FM_ROW_BTN[1]), true)
		i += 1
	_pager(page, pages, "Hôm nay còn " + str(helps) + " lượt giúp có thưởng." if helps > 0 else "Hôm nay đã hết lượt giúp có thưởng.")

static func log_icon(k: String) -> String:
	if k == "stole" or k == "got" or k == "wild":
		return "lg_thief"
	if k == "chased" or k == "run":
		return "lg_chase"
	if k == "blocked" or k == "guard" or k == "crow":
		return "lg_shield"
	if k == "water":
		return "lg_water"
	if k == "bug":
		return "lg_bug"
	return "lg_clock"


func _log() -> void :
	var per: int = 6
	var pages: int = pages_of(logs.size(), per)
	var x: float = float(FM_ROW[0])
	var tw: float = float(FM_ROW_TEXT[2]) - 72.0
	var can: bool = _mi("steals") > 0 and _mi("searches") > 0
	_pic_at("fm_board", FM_BOARD.x, FM_BOARD.y)
	if logs.is_empty():
		_center_note("Chưa có hoạt động nào.")
		return
	page = mini(page, pages - 1)
	var i: int = page * per
	while i < logs.size() and i < (page + 1) * per:
		var row: Dictionary = logs[i]
		var y: float = float(FM_ROW[1]) + float(i - page * per) * float(FM_ROW[2])
		_pic_at("row_list", x, y)
		_pic_c(log_icon(str(row["k"])), x + float(FM_ROW_ICON[0]), y + float(FM_ROW_ICON[1]))
		var tx: float = x + float(FM_ROW_TEXT[0])
		var ty: float = y + float(FM_ROW_TEXT[1])
		var px: float = 11.0 if _wrap(str(row["tx"]), tw, 12.0).size() > 2 else 12.0
		_note(tx, ty, tw, float(FM_ROW_TEXT[3]), px, str(row["tx"]), "left")
		_ft(tx + tw, ty, 70.0, float(FM_ROW_TEXT[3]), 11.0, ago(float(row["at"])), "right")
		if int(row["rv"]) > 0:
			_btn("rv:" + str(row["rv"]), "btn_revenge_st", x + float(FM_ROW_BTN[0]), y + float(FM_ROW_BTN[1]) + 1.0, can)
		i += 1
	_pager(page, pages, "Trả thù: sang vườn kẻ trộm để hái lại." if can else "Hôm nay đã hết lượt trộm hoặc dò vườn.")


func _shop() -> void :
	var per: int = 12
	var pages: int = pages_of(shop.size(), per)
	var icx: float = float(FM_SHOP_ICON[0])
	var icy: float = float(FM_SHOP_ICON[1])
	var ics: float = float(FM_SHOP_ICON[2])
	_pic_at("fm_board", FM_BOARD.x, FM_BOARD.y)
	if shop.is_empty():
		_center_note("Chưa có quà để đổi.")
		return
	page = mini(page, pages - 1)
	var i: int = page * per
	while i < shop.size() and i < (page + 1) * per:
		var entry: Dictionary = shop[i]
		var k: int = i - page * per
		var x: float = float(FM_SHOP[0]) + float(k % 4) * float(FM_SHOP[2])
		var y: float = float(FM_SHOP[1]) + float(int(k / 4.0)) * float(FM_SHOP[3])
		var items: Array = entry["items"]
		var have: int = shop_have(entry)
		var per2: String = "tháng" if str(entry["per"]) == "m" else "tuần"
		_pic_at("card_shop", x, y)
		var sn: int = 0
		if items.size() > 0:
			icon(int(items[0]["id"]), ics, _o + Vector2(x + icx, y + icy))
			sn = int(items[0]["n"])
		else:
			for sk: String in (entry["sd"] as Dictionary).keys():
				if sn == 0:
					_pic_c("seed_" + sk, x + icx, y + icy)
					sn = int(entry["sd"][sk])
		if sn > 1:
			_dbtext(_o + Vector2(x + icx - 6.0, y + icy + float(int(ics / 2.0)) - 16.0), float(int(ics / 2.0)) + 10.0, 16.0, 11.0, FM_CREAM, FM_INK, "right", 
				"×" + str(sn))
		_ft(x + float(FM_SHOP_NAME[0]), y + float(FM_SHOP_NAME[1]), float(FM_SHOP_NAME[2]), float(FM_SHOP_NAME[3]), 11.0, str(entry["label"]))
		_ft(x + float(FM_SHOP_LEFT[0]), y + float(FM_SHOP_LEFT[1]), float(FM_SHOP_LEFT[2]), float(FM_SHOP_LEFT[3]), 10.0, 
			"còn " + str(entry["left"]) + "/" + str(entry["lim"]) + " " + per2)
		_pic_c("ic_" + str(entry["crop"]) + "_16", x + float(FM_SHOP_CROP[0]), y + float(FM_SHOP_CROP[1]))
		_ft(x + float(FM_SHOP_PRICE[0]), y + float(FM_SHOP_PRICE[1]), float(FM_SHOP_BTN[0]) - float(FM_SHOP_PRICE[0]), float(FM_SHOP_PRICE[3]), 12.0, 
			num(int(entry["cost"])), "left", FM_SHORT if have < int(entry["cost"]) else FM_DARK)
		if items.size() > 0:
			tip_area(Rect2(_o + Vector2(x + icx - ics / 2.0, y + icy - ics / 2.0), Vector2(ics, ics)), int(items[0]["id"]), "")
		_tipr(x + float(FM_SHOP_LEFT[0]), y + float(FM_SHOP_LEFT[1]), float(FM_SHOP_LEFT[2]), float(FM_SHOP_LEFT[3]), "Mỗi " + per2 + " đổi tối đa "
			+ str(entry["lim"]) + " lần.\nLàm mới sau " + left_text(float(entry["resetAt"]), _t()) + ".")
		_tipr(x + 4.0, y + float(FM_SHOP_PRICE[1]), float(FM_SHOP_BTN[0]) - 4.0, float(FM_SHOP_PRICE[3]), "Giá: " + num(int(entry["cost"])) + " "
			+ crop_name(str(entry["crop"])) + ", bạn có " + num(have) + ".")
		var id: String = "doi:" + str(entry["id"])
		_keys[id] = entry
		_btn(id, "btn_doi_st", x + float(FM_SHOP_BTN[0]), y + float(FM_SHOP_BTN[1]), int(entry["left"]) > 0, "", "btn_doi_arm")
		if int(entry["left"]) <= 0:
			_pic_c("stamp_het", x + float(FM_SHOP[2]) / 2.0 - 2.0, y + float(FM_SHOP_NAME[1]) - 8.0)
		_at["shop:" + str(entry["id"])] = Vector2(x + icx, y + icy)
		i += 1
	if pages > 1:
		_pager(page, pages, "")


func _pop_panel(title: String) -> Vector2:
	_tips.clear()
	draw_rect(Rect2(_o * _f, Vector2(FM_W, FM_H) * _f), FM_DIM)
	_hit(POP_DIM, Rect2(_o * _f, Vector2(FM_W, FM_H) * _f), false)
	var size: Vector2 = Vector2(_w("pop_panel"), _h("pop_panel"))
	_hit("panel", Rect2((_o + FM_POP) * _f, size * _f), false)
	_pic_at("pop_panel", FM_POP.x, FM_POP.y)
	_ft(FM_POP.x + float(FM_POP_TITLE[0]), FM_POP.y + float(FM_POP_TITLE[1]), float(FM_POP_TITLE[2]), float(FM_POP_TITLE[3]), 15.0, title)
	return FM_POP

func _pop_close() -> void :
	if art("btn_close_st") != null:
		art_button("popclose", "btn_close_st", _o + FM_POP + Vector2(float(FM_POP_CLOSE[0]), float(FM_POP_CLOSE[1])), 1)


func _seed_pop() -> void :
	var empty: int = empty_pots().size()
	var slot: int = pop_slot
	var p: Vector2 = _pop_panel("GIEO VÀO CHẬU " + str(slot + 1) if slot >= 0 else "CHỌN HẠT GIỐNG")
	for i in 3:
		var one: Variant = seed_of(CROPS[i])
		if one == null:
			continue
		var x: float = p.x + float(FM_POP_CARDS[i * 2])
		var y: float = p.y + float(FM_POP_CARDS[i * 2 + 1])
		var cur: String = str(one["cur"])
		var half: float = float(int(float(FM_SCARD_TEXT[7]) / 2.0))
		_pic_at("card_seed", x, y)
		_pic_c("seed_" + str(one["id"]), x + float(FM_SCARD_ICON[0]), y + float(FM_SCARD_ICON[1]))
		_ft(x + float(FM_SCARD_TEXT[0]), y + float(FM_SCARD_TEXT[1]), float(FM_SCARD_TEXT[2]), float(FM_SCARD_TEXT[3]), 13.0, str(one["label"]))
		_fit_line(x + float(FM_SCARD_TEXT[4]), y + float(FM_SCARD_TEXT[5]), float(FM_SCARD_TEXT[6]), half, 11, "Chín sau " + dur(int(one["grow"])))
		_fit_line(x + float(FM_SCARD_TEXT[4]), y + float(FM_SCARD_TEXT[5]) + half, float(FM_SCARD_TEXT[6]), half, 11, 
			"Thu " + str(int(one["y"])) + " " + str(one["crop"]))
		_dbtext(_o + Vector2(x + float(FM_SCARD_ICON[0]) - 25.0, y + float(FM_SCARD_ICON[1]) + 12.0), 50.0, 14.0, 12.0, FM_CREAM, FM_DARK, "right", 
			"x" + num(int(one["n"])))
		var gid: String = "gieo:" + str(one["id"])
		_keys[gid] = one
		_btn(gid, "btn_gieo_st", x + float(FM_SCARD_BTN[0]), y + float(FM_SCARD_BTN[1]), int(one["n"]) > 0 and (slot >= 0 or empty > 0))
		var have: int = int(money.get(cur, -1))
		var mid: String = "mua:" + str(one["id"])
		_keys[mid] = one
		var shown: Array = _btn(mid, "btn_mua_st", x + float(FM_SCARD_BTN[2]), y + float(FM_SCARD_BTN[3]), int(one["price"]) > 0, "", "btn_mua_arm")
		_fm_face(shown, "btn_mua_st", "MUA · " + num(int(one["price"])), cur_icon(cur, 16), have >= 0 and have < int(one["price"]))
	_ft(p.x + 20.0, p.y + float(FM_POP_HOURS[1]), 440.0, 30.0, 12.0, "Chọn hạt rồi bấm GIEO." if slot >= 0 else ("Còn " + str(empty)
		+ " chậu trống: GIEO trồng hạt vào các chậu trống." if empty > 0 else "Không còn chậu trống: thu hoạch hoặc mở thêm chậu."))
	_pop_close()


func _guard_pop() -> void :
	var gid: String = str(me.get("guard", ""))
	var g_on: bool = guard_on()
	var sel: Variant = guard_of(pop_guard)
	var p: Vector2 = _pop_panel("GIA HẠN " + guard_name(gid).to_upper() if g_on else "THUÊ TRỢ THỦ CANH VƯỜN")
	var hours: Array = me.get("gh", [])
	var cur: String = str(me.get("gcur", ""))
	var sp: float = maxf(1.0, _mf("sp"))
	var left: float = (_mf("gAt") - _t()) / 1000.0 if g_on else 0.0
	var gs: float = float(FM_GCARD_ICON[2])
	for i in mini(3, guards.size()):
		var one: Dictionary = guards[i]
		var x: float = p.x + float(FM_POP_CARDS[i * 2])
		var y: float = p.y + float(FM_POP_CARDS[i * 2 + 1])
		_pic_at("card_guard", x, y)
		_fit("guard_" + str(one["id"]), x + float(FM_GCARD_ICON[0]) - gs / 2.0, y + float(FM_GCARD_ICON[1]) - gs / 2.0, gs, gs)
		_note(x + float(FM_GCARD_TEXT[0]), y + float(FM_GCARD_TEXT[1]), float(FM_GCARD_TEXT[2]), float(FM_GCARD_TEXT[3]), 13.0, str(one["label"]))
		_note(x + float(FM_GCARD_TEXT[4]), y + float(FM_GCARD_TEXT[5]), float(FM_GCARD_TEXT[6]), float(FM_GCARD_TEXT[7]), 11.0, "Chặn " + str(one["bl"])
			+ "% kẻ trộm\n" + num(int(one["price"])) + " " + cur_name(cur) + "/giờ")
		if str(one["id"]) == pop_guard:
			_pic_at("card_sel", x, y)
		var text: String = ("Đang thuê " + guard_name(gid) + ": hết hạn mới đổi được trợ thủ khác." if g_on and str(one["id"]) != gid
			else ("Kẻ trộm bị chặn mất thêm " + str(one["burn"]) + " lượt trộm." if int(one["burn"]) > 0 else ""))
		_click("gpick:" + str(one["id"]), x, y, _w("card_guard"), _h("card_guard"), text)
	var i: int = 0
	while sel != null and i < hours.size() and i < 3:
		var h: int = int(hours[i])
		var x: float = p.x + float(FM_POP_HOURS[i * 2])
		var y: float = p.y + float(FM_POP_HOURS[i * 2 + 1])
		var price: int = int(sel["price"]) * h
		var ok: bool = not (g_on and str(sel["id"]) != gid) and left + float(h) * 3600.0 / sp <= float(_mi("gmax")) * 3600.0 / sp + 1.0
		if not ok:
			_tipr(x, y, _w("btn_pill_st"), _h("btn_pill_st"), "Đang thuê " + guard_name(gid) + ": hết hạn mới đổi được." if g_on and str(sel["id"]) != gid
				else "Tối đa " + str(_mi("gmax")) + " giờ canh vườn.")
		var id: String = "pill:" + str(h)
		_keys[id] = h
		var have: int = int(money.get(cur, -1))
		var shown: Array = _btn(id, "btn_pill_st", x, y, ok, "", "btn_pill_arm")
		_fm_face(shown, "btn_pill_st", str(h) + " GIỜ · " + num(price), cur_icon(cur, 16), have >= 0 and have < price)
		i += 1
	_pop_close()
