extends "tev_window.gd"








signal closed(note: String)

const PnAtlas = preload("pn_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const MB_POLL_TICKS: int = 120
const PN_TIP: String = "Đêm Bí Ngô"
const PN_ICON: String = "btn_bingo"
const PN_WORD: String = "word_bingo_t"
const PN_ART: Array = ["pn_bg", "tab_normal", "tab_selected", "tab_locked", "tabicon_rc", "tabicon_sp", "tabicon_shop", "tabicon_hunt", 
	"tabicon_shoot", "tabicon_boss", "tablabel_rc", "tablabel_sp", "tablabel_shop", "tablabel_hunt", "tablabel_shoot", "tablabel_boss", 
	"tab_lock", "chip_wallet", "chip_time", "token_24", "token_16", "shop_sign", "bubble", "teddy_a", "teddy_b", "counter", "feat_card", 
	"feat_vehicle", "ribbon_hot", "price_l", "price_s", "good_card", "good_card_off", "stamp_het", "dot_on", "dot_off", "ghost", "ms_head", 
	"ms_bar_empty", "ms_bar_full", "ms_card", "ms_card_off", "ms_glow", "ms_node", "ms_node_on", "stamp_danhan", "hunt_scene", 
	"hunt_basket_empty", "hunt_basket_full", "hunt_board", "lock_scene", "btn_close_st", "btn_doi_l_st", "btn_doi_s_st", "arrow_l_st", 
	"arrow_r_st", "btn_nhan_st", "btn_nhanhet_st", "btn_disan_st", "fx_bat", "fx_sparkle", "fx_bubble", "fx_steam", "fx_ember"]

const PN_SHEETS: Dictionary = {
	"btn_close_st": [40, 40, 1, 4], "btn_doi_l_st": [139, 38, 1, 4], "btn_doi_s_st": [92, 24, 1, 4], "arrow_l_st": [28, 30, 1, 4], 
	"arrow_r_st": [28, 30, 1, 4], "btn_nhan_st": [78, 34, 1, 4], "btn_nhanhet_st": [181, 55, 1, 4], "btn_disan_st": [266, 70, 1, 4], 
	"fx_bat": [64, 48, 4, 4], "fx_sparkle": [48, 48, 3, 6], "fx_bubble": [24, 24, 4, 4], "fx_steam": [48, 64, 3, 6], "fx_ember": [12, 12, 4, 4], 
}
const PN_TAB_KEYS: Array = ["rc", "sp", "shop", "hunt", "shoot", "boss"]
const PN_SAY: Array = ["Chào mừng tới Tiệm Phù Thủy Teddy!", "Bí Ngô đổi được quà xịn lắm đó~", "Săn Bí Ngô trong trận PvP, Phụ Bản nha!", 
	"Nạp hay tiêu Xu đạt mốc cũng có Bí Ngô!", "Xe Bí Ngô chỉ có một chiếc thôi nhé!", "Nồi thuốc sôi rồi, đổi gì nào?"]
const PN_NAME: String = "Đêm Bí Ngô"
const PN_CREAM: Color = Color("f6e8db")
const PN_INK: Color = Color("17162d")
const PN_INK_TEXT: Color = Color("2e173c")
const PN_GOLD: Color = Color("ffc94f")
const PN_SOFT: Color = Color("c9b6d9")
const PN_SHORT: Color = Color("ff6b57")
const PN_DOT: Color = Color("e82d2a")
const PN_CLOSE: Vector2 = Vector2(908, 78)
const PN_WALLET: Vector2 = Vector2(622, 72)
const PN_WALLET_TOKEN: Vector2 = Vector2(7, 6)
const PN_WALLET_TEXT: Array = [36, 6, 78, 25]
const PN_TIME: Vector2 = Vector2(747, 72)
const PN_TIME_TEXT: Array = [31, 7, 111, 23]
const PN_TABS: Array = [22, 123, 22, 188, 19, 251, 22, 324, 22, 389, 22, 460]
const PN_TAB_ICON: Vector2 = Vector2(3, 4)
const PN_TAB_LABEL: Vector2 = Vector2(70, 8)
const PN_TAB_LOCK: Vector2 = Vector2(93, 8)
const PN_TAB_DOT: Vector2 = Vector2(166, 5)
const PN_TAB_HIT: Rect2 = Rect2(0, 0, 174, 64)
const PN_SIGN: Vector2 = Vector2(213, 104)
const PN_BUBBLE: Vector2 = Vector2(233, 196)
const PN_BUBBLE_TEXT: Array = [16, 8, 136, 28]
const PN_TEDDY: Vector2 = Vector2(205, 237)
const PN_COUNTER: Vector2 = Vector2(203, 377)
const PN_POT: Array = [346, 400, 87]
const PN_EMBERS: Array = [221, 314, 202, 184]
const PN_FEAT: Vector2 = Vector2(441, 119)
const PN_FEAT_VEH: Array = [475, 126, 232, 124]
const PN_FEAT_HOT: Vector2 = Vector2(441, 118)
const PN_FEAT_NAME: Array = [716, 133, 182, 33]
const PN_FEAT_PRICE: Vector2 = Vector2(755, 169)
const PN_FEAT_STOCK: Array = [760, 198, 110, 13]
const PN_FEAT_BTN: Vector2 = Vector2(737, 212)
const PN_FEAT_STAMP: Vector2 = Vector2(549, 165)
const PN_PRICE_L_TOKEN: Vector2 = Vector2(3, 2)
const PN_PRICE_L_TEXT: Array = [30, 4, 70, 20]
const PN_PRICE_S_TOKEN: Vector2 = Vector2(3, 3)
const PN_PRICE_S_TEXT: Array = [23, 2, 58, 18]
const PN_GRID_X: Array = [443, 562, 681, 800]
const PN_GRID_Y: Array = [263, 400]
const PN_CARD_WELL: Array = [57, 30, 44]
const PN_CARD_NAME: Array = [10, 54, 94, 14]
const PN_CARD_PRICE: Vector2 = Vector2(14, 69)
const PN_CARD_STOCK: Array = [10, 91, 94, 12]
const PN_CARD_BTN: Vector2 = Vector2(11, 103)
const PN_CARD_STAMP: Vector2 = Vector2(17, 14)
const PN_ARROWS: Array = [598, 535, 724, 535]
const PN_DOTS: Array = [674, 542, 19, 7]
const PN_GHOST: Vector2 = Vector2(859, 110)
const PN_BATS: Array = [178, 49, 701, 43]
const PN_MS_HEAD: Vector2 = Vector2(220, 122)
const PN_MS_HEAD_TEXT: Array = [57, 25, 367, 24]
const PN_MS_HEAD_DX: float = 20.0
const PN_MS_SUB: Array = [57, 52, 367, 18]
const PN_MS_ALL: Vector2 = Vector2(722, 139)
const PN_MS_BAR: Vector2 = Vector2(215, 208)
const PN_MS_NODE: Array = [51, 150, 249, 348, 446, 545, 644]
const PN_MS_NODE_C: Vector2 = Vector2(24, -2)
const PN_MS_BAR_START: float = 0.0
const PN_MS_BAR_END: float = 689.0
const PN_MS_CARD_X: Array = [219, 318, 417, 516, 614, 713, 812]
const PN_MS_CARD_Y: float = 268.0
const PN_MS_GLOW: Vector2 = Vector2(-14, -14)
const PN_MS_AMOUNT: Array = [9, 16, 76, 20]
const PN_MS_TOKEN: Vector2 = Vector2(11, 43)
const PN_MS_PK: Array = [39, 43, 45, 23]
const PN_MS_WELL: Array = [47, 105, 48]
const PN_MS_BTN: Array = [8, 159, 78, 34]
const PN_MS_STAMP: Vector2 = Vector2(6, 159)
const PN_HU_SCENE: Vector2 = Vector2(202, 112)
const PN_HU_BASKET: Vector2 = Vector2(235, 218)
const PN_HU_FILL: Array = [0, 30, 138]
const PN_HU_BOARD: Vector2 = Vector2(235, 121)
const PN_HU_COUNT: Array = [374, 144, 384, 32]
const PN_HU_RULES: Array = [635, 253, 219, 45]
const PN_HU_BTN: Vector2 = Vector2(628, 406)
const PN_LK_SCENE: Vector2 = Vector2(202, 112)
const PN_LK_TITLE: Array = [365, 140, 394, 30]
const PN_LK_HINT: Array = [354, 486, 417, 32]
const PN_HINT_SHOOT: String = "Trò bắn bí ngô trúng quà đang được Teddy chuẩn bị. Sắp mở, hãy quay lại sau nhé!"
const PN_HINT_BOSS: String = "Bí Ngô khổng lồ đang thức giấc trong sương mù. Sắp mở: hợp sức cả server để hạ Boss!"

static var s_pn_shown: bool = false
static var s_pn_tab: int = 2
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 5
var pn_visible: bool = false
var loaded: bool = false
var pn_name: String = PN_NAME
var earning: bool = false
var end_at: float = 0.0
var shop_at: float = 0.0
var pumpkins: int = -1
var pumpkin_id: int = 0
var token: String = ""
var tracks: Array = []
var hunt: Dictionary = {}
var shop: Array = []
var tab: int = 2
var page: int = 0
var say_text: String = ""
var say_at: int = 0
var show_pk: int = -1
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _b_ready: bool = false
var _b_failed: bool = false
var _teddy_key: String = "teddy_a"
var _glow_a: float = 1.0
var _say_line: String = ""
var _time_line: String = ""
var _time_tip: String = ""
var _spots: Dictionary = {}
var _bat_f: Array = [0, 2]

func _setup() -> void :
	art_dir = ""
	art_files = PN_ART
	sheets = PN_SHEETS
	win_size = Vector2(960, 580)
	super ()

static func reset_statics() -> void :
	s_pn_shown = false
	s_pn_tab = 2


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew


func reset() -> void :
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 5
	pn_visible = false
	loaded = false
	pn_name = PN_NAME
	earning = false
	end_at = 0.0
	shop_at = 0.0
	pumpkins = -1
	pumpkin_id = 0
	token = ""
	tracks = []
	hunt = {}
	shop = []
	tab = 2
	page = 0
	say_text = ""
	say_at = 0
	show_pk = -1
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(PnAtlas.FILE):
			_atlas = load(PnAtlas.FILE) as Texture2D
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
	if atlas == null or not PnAtlas.R.has(name):
		return null
	var row: Array = PnAtlas.R[name]
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = atlas
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part


func button_icon() -> Texture2D:
	return art(PN_ICON)

func button_word() -> Texture2D:
	return art(PN_WORD)




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		poll()

func poll() -> void :
	fetch("/pumpkin-night.xml?r=" + str(int(now_ms())), "poll")


func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = MB_POLL_TICKS
		if not loading:
			poll()


func button_visible() -> bool:
	return pn_visible


func button_dot() -> bool:
	return pn_visible and claimable(-1) > 0


func claimable(t: int) -> int:
	var n: int = 0
	for i in tracks.size():
		if t < 0 or t == i:
			n += int(tracks[i]["claimable"])
	return n


func busy() -> bool:
	return loading and action != "poll"


func open() -> void :
	if opened or ( not pn_visible and loaded):
		return
	if claimable(0) > 0:
		tab = 0
	elif claimable(1) > 0:
		tab = 1
	else:
		tab = s_pn_tab if s_pn_tab >= 0 and s_pn_tab < 6 else 2
	page = 0
	say_at = 0
	show_pk = pumpkins
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
	elif id == "hunt":
		on_hunt()
	elif id.begins_with("tab:"):
		on_tab(id.substr(4).to_int())
	elif id.begins_with("page:"):
		on_page(id.substr(5).to_int())
	elif id.begins_with("buy:"):
		on_buy(id.substr(4))
	elif id.begins_with("claim:"):
		on_claim(id)




func _failed(what: String) -> void :
	if what != "poll":
		tip("Không kết nối được máy chủ, hãy thử lại.")
	if opened:
		_rebuild()


func _reply(text: String, what: String) -> void :
	var xml: Variant = parse_deep(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	var parsed: bool = xml != null
	var old_tracks: Array = tracks
	var old_pk: int = pumpkins
	var notice: String = ""
	var done_kind: String = ""
	var done_items: Array = []
	if parsed:
		var at: Dictionary = xml["at"]
		notice = str(at.get("notice", ""))
		pn_visible = str(at.get("visible", "")) == "1"
		s_pn_shown = pn_visible
		if pn_visible:
			var goods: Array = []
			for box: Dictionary in kids(xml, "shop"):
				for g: Dictionary in kids(box, "g"):
					var it: String = str(g["at"].get("it", ""))
					var cut: int = it.find(":")
					goods.append({"id": str(g["at"].get("id", "")), "item": maxi(0, TevWheel.as_int(it.substr(0, cut) if cut > 0 else it)), 
						"n": maxi(1, TevWheel.as_int(it.substr(cut + 1) if cut > 0 else "1")), "price": TevWheel.as_int(str(g["at"].get("price", ""))), 
						"limit": TevWheel.as_int(str(g["at"].get("limit", ""))), "bought": TevWheel.as_int(str(g["at"].get("bought", ""))), 
						"tag": str(g["at"].get("tag", ""))})
			var hunts: Array = kids(xml, "hunt")
			var dones: Array = kids(xml, "done")
			pn_name = str(at.get("name", "")) if not str(at.get("name", "")).is_empty() else PN_NAME
			earning = str(at.get("earning", "")) == "1"
			end_at = now_ms() + TevWheel.as_number(str(at.get("left", ""))) * 1000.0
			shop_at = now_ms() + TevWheel.as_number(str(at.get("shopLeft", ""))) * 1000.0
			pumpkins = TevWheel.as_int(str(at.get("pumpkins", "")))
			pumpkin_id = maxi(0, TevWheel.as_int(str(at.get("pumpkinId", ""))))
			token = str(at.get("token", ""))
			var rc: Array = kids(xml, "rc")
			var sp: Array = kids(xml, "sp")
			tracks = [track_of(rc[0] if not rc.is_empty() else null), track_of(sp[0] if not sp.is_empty() else null)]
			var h: Dictionary = hunts[0]["at"] if not hunts.is_empty() else {}
			hunt = {"got": TevWheel.as_int(str(h.get("got", ""))), "cap": TevWheel.as_int(str(h.get("cap", ""))), 
				"win": TevWheel.as_int(str(h.get("win", ""))), "lose": TevWheel.as_int(str(h.get("lose", ""))), 
				"matches": TevWheel.as_int(str(h.get("matches", ""))), 
				"min": TevWheel.as_int(str(h["min"])) if h.has("min") and not str(h["min"]).is_empty() else 60}
			shop = goods
			if not dones.is_empty():
				done_kind = str(dones[0]["at"].get("k", ""))
				done_items = items_of(str(dones[0]["at"].get("it", "")))
		else:
			tracks = []
			shop = []
		loaded = true
	if not parsed and what != "poll":
		notice = "Thao tác chưa thành công, hãy thử lại sau."
	if opened and not pn_visible:
		close()
	elif opened:
		if done_kind.is_empty():
			show_pk = pumpkins
		_rebuild()
		if not done_kind.is_empty():
			play_fx(done_kind, done_items, old_tracks, old_pk, what)
	if not notice.is_empty():
		tip(notice)



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


func track_of(node: Variant) -> Dictionary:
	var list: Array = []
	if node == null:
		return {"total": 0.0, "claimable": 0, "list": list}
	for m: Dictionary in kids(node, "m"):
		list.append({"need": TevWheel.as_number(str(m["at"].get("need", ""))), "pk": TevWheel.as_int(str(m["at"].get("pk", ""))), 
			"items": items_of(str(m["at"].get("it", ""))), "s": TevWheel.as_int(str(m["at"].get("s", "")))})
	return {"total": TevWheel.as_number(str(node["at"].get("total", ""))), "claimable": TevWheel.as_int(str(node["at"].get("claimable", ""))), "list": list}




func on_tab(i: int) -> void :
	if i < 0 or i >= 6 or i == tab:
		return
	tab = i
	s_pn_tab = tab
	page = 0
	_rebuild()


func on_page(step: int) -> void :
	page += step
	_rebuild()


func on_buy(id: String) -> void :
	if busy():
		return
	for g: Dictionary in shop:
		if str(g["id"]) == id:
			if pumpkins >= 0 and not afford(g):
				tip("Không đủ Bí Ngô: cần " + num(int(g["price"])) + ", đang có " + num(pumpkins) + ".")
				say_text = "Thiếu Bí Ngô rồi... đi săn thêm nhé!"
				say_at = tick + 100
				_say_line = say_line()
				return
			fetch("/pumpkin-night-buy.xml?g=" + TevWheel.uri_component(id) + "&n=1&k=" + TevWheel.uri_component(token) + "&r=" + str(int(now_ms())), "buy:" + id)
			_rebuild()
			return


func on_claim(key: String) -> void :
	var parts: PackedStringArray = key.split(":")
	if parts.size() != 3 or parts[0] != "claim" or busy():
		return
	fetch("/pumpkin-night-claim.xml?t=" + ("rc" if parts[1] == "0" else "sp") + "&m=" + parts[2] + "&k=" + TevWheel.uri_component(token)
		+ "&r=" + str(int(now_ms())), "claim:" + parts[1])
	_rebuild()


func on_hunt() -> void :
	close("hunt")
	tip("Vào trận PvP hoặc Phụ Bản để săn Bí Ngô nhé!")




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
	return pumpkins >= int(g["price"])

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
	if say_at > tick and not say_text.is_empty():
		return say_text
	var feat: Variant = featured()
	if feat != null and goods_left(feat) and afford(feat) and int(float(tick) / 150.0) % 2 == 0:
		return "Đủ Bí Ngô đổi Xe Bí Ngô rồi kìa!"
	return str(PN_SAY[int(float(tick) / 150.0) % PN_SAY.size()])


func time_line() -> String:
	return left_text(end_at, now_ms()) if earning else "Tiệm " + left_text(shop_at, now_ms())

func time_tip() -> String:
	if earning:
		return "Sự kiện kết thúc sau " + left_text(end_at, now_ms()) + ".\nTiệm Phù Thủy Teddy mở thêm tới " + left_text(shop_at, now_ms()) + " nữa để đổi nốt Bí Ngô."
	return "Sự kiện đã kết thúc, chỉ còn Tiệm Phù Thủy Teddy.\nTiệm đóng sau " + left_text(shop_at, now_ms()) + "."


func wallet_text() -> String:
	return "--" if pumpkins < 0 else num(show_pk)


static func bar_x(list: Array, total: float) -> float:
	var prev_need: float = 0.0
	var prev_x: float = PN_MS_BAR_START
	for i in mini(7, list.size()):
		var need: float = float(list[i]["need"])
		var nx: float = float(PN_MS_NODE[i])
		if total < need:
			return prev_x + (nx - prev_x) * maxf(0.0, total - prev_need) / maxf(1.0, need - prev_need)
		prev_need = need
		prev_x = nx
	return PN_MS_BAR_END




func _rebuild() -> void :
	if not opened:
		return
	fx_drop("pot")
	_b_ready = art_pending() == 0 and art("pn_bg") != null and loaded
	_b_failed = art_pending() == 0 and art("pn_bg") == null
	page = maxi(0, mini(pages() - 1, page))
	_teddy_key = "teddy_a"
	_glow_a = 1.0
	_bat_f = [0, 2]
	_say_line = say_line()
	_time_line = time_line()
	_time_tip = time_tip()
	_spots = {}
	if not _b_ready:
		return
	if tab == 2:
		var feat: Variant = featured()
		if feat != null:
			_spots["g:" + str(feat["id"])] = Vector2(float(PN_FEAT_VEH[0]) + float(PN_FEAT_VEH[2]) / 2.0, float(PN_FEAT_VEH[1]) + float(PN_FEAT_VEH[3]) / 2.0)
		var list: Array = grid()
		var n: int = 0
		var i: int = page * 8
		while i < list.size() and n < 8:
			_spots["g:" + str(list[i]["id"])] = Vector2(float(PN_GRID_X[n % 4]) + float(PN_CARD_WELL[0]), float(PN_GRID_Y[n / 4]) + float(PN_CARD_WELL[1]))
			n += 1
			i += 1
	elif tab == 0 or tab == 1:
		var list: Array = tracks[tab]["list"] if tracks.size() > tab else []
		for i in mini(7, list.size()):
			_spots["m:%d:%d" % [tab, int(float(list[i]["need"]))]] = Vector2(float(PN_MS_CARD_X[i]) + float(PN_MS_WELL[0]), PN_MS_CARD_Y + float(PN_MS_WELL[1]))

func ready_shown() -> bool:
	return _b_ready


func _anim() -> void :
	if not opened:
		return
	if _b_ready and tab == 2:
		_pot_fx()
		if tick % 11 == 0:
			_teddy_key = "teddy_a" if int(float(tick) / 11.0) % 2 == 0 or art("teddy_b") == null else "teddy_b"
	if _b_ready and tick % 3 == 0:
		for i in _bat_f.size():
			_bat_f[i] = (int(_bat_f[i]) + 1) % 4
	_glow_a = 0.55 + 0.45 * sin(float(tick) * 0.12)
	if show_pk != pumpkins and pumpkins >= 0:
		var k: int = pumpkins - show_pk
		show_pk += maxi(1, int(float(k) / 6.0)) if k > 0 else mini(-1, int(float(k) / 6.0))
	if tick % 25 == 0:
		_time_line = time_line()
		_time_tip = time_tip()
	if tick % 150 == 0 or say_at == tick:
		_say_line = say_line()




func sparkles(at: Vector2, count: int) -> void :
	if art("fx_sparkle") == null:
		return
	for i in count:
		fx_add("sheet", "fx_sparkle", at + Vector2((randf() - 0.5) * 50.0, (randf() - 0.5) * 40.0), {"tpf": 2, "vy": -0.6})


func float_text(text: String, color: Color, at: Vector2) -> void :
	var fx: Dictionary = fx_add("text", "", at, {"vy": -0.9, "life": 40, "fade": 14})
	fx["text"] = text
	fx["color"] = color


func fly_token(from: Vector2, order: int) -> void :
	if art("token_24") == null:
		return
	fx_add("pic", "token_24", from, {"tx": PN_WALLET.x + PN_WALLET_TOKEN.x + 12.0, "ty": PN_WALLET.y + PN_WALLET_TOKEN.y + 12.0, "ts": 0.8, 
		"life": 20 + order * 4})


func pop_item(id: int, at: Vector2) -> void :
	fx_add("icon", "", at, {"id": id, "side": 56.0, "tx": at.x, "ty": at.y - 70.0, "ts": 1.3, "life": 34, "fade": 12})


func play_fx(kind: String, items: Array, old_tracks: Array, old_pk: int, what: String) -> void :
	var t: int = 0 if kind == "rc" else (1 if kind == "sp" else -1)
	show_pk = maxi(0, old_pk)
	if t >= 0 and tracks.size() > t:
		var old_list: Array = old_tracks[t]["list"] if old_tracks.size() > t else []
		var n: int = 0
		for m: Dictionary in tracks[t]["list"]:
			if int(m["s"]) != 2:
				continue
			var was: Variant = null
			for row: Dictionary in old_list:
				if float(row["need"]) == float(m["need"]):
					was = row
			if was == null or int(was["s"]) == 2:
				continue
			var key: String = "m:%d:%d" % [t, int(float(m["need"]))]
			if _spots.has(key):
				var at: Vector2 = _spots[key]
				sparkles(at, 3)
				for i in mini(4, 1 + int(float(int(m["pk"])) / 60.0)):
					fly_token(at + Vector2((randf() - 0.5) * 30.0, -30.0 + (randf() - 0.5) * 20.0), n + i)
				n += 1
	elif what.begins_with("buy:"):
		var key: String = "g:" + what.substr(4)
		if _spots.has(key):
			var at: Vector2 = _spots[key]
			sparkles(at, 3)
			for row: Dictionary in items:
				pop_item(int(row["id"]), at)
		float_text("-" + num(maxi(0, old_pk - pumpkins)), PN_SHORT, PN_WALLET + Vector2(60, 52))
		say_text = "Cảm ơn nha! Ghé tiệm Teddy tiếp nhé~"
		say_at = tick + 110
		_say_line = say_line()
	if pumpkins > old_pk and old_pk >= 0:
		float_text("+" + num(pumpkins - old_pk), PN_GOLD, PN_WALLET + Vector2(60, 52))


func _pot_fx() -> void :
	if tick % 7 == 0 and art("fx_bubble") != null:
		var fx: Dictionary = fx_add("sheet", "fx_bubble", Vector2(float(PN_POT[0]) + (randf() - 0.5) * float(PN_POT[2]), float(PN_POT[1]) + (randf() - 0.5) * 6.0), 
			{"tpf": 3, "vy": -0.25, "layer": "pot"})
		fx["scale"] = 0.7 + randf() * 0.5
	if tick % 18 == 0 and art("fx_steam") != null:
		fx_add("sheet", "fx_steam", Vector2(float(PN_POT[0]) + (randf() - 0.5) * float(PN_POT[2]) * 0.6, float(PN_POT[1]) - 18.0), 
			{"tpf": 5, "vy": -0.7, "vx": (randf() - 0.5) * 0.4, "fade": 10, "layer": "pot"})
	if tick % 13 == 0 and art("fx_ember") != null:
		fx_add("sheet", "fx_ember", Vector2(float(PN_EMBERS[0]) + randf() * float(PN_EMBERS[2]), float(PN_EMBERS[1]) + float(PN_EMBERS[3])), 
			{"f": randi() % 4, "tpf": 4, "loop": 1, "vy": -0.9 - randf() * 0.6, "vx": (randf() - 0.5) * 0.6, "life": int(float(PN_EMBERS[3]) / 1.2), 
			"fade": 16, "layer": "pot"})

func _draw_fx(at: Vector2, layer: String) -> void :
	super (at, layer)
	for fx: Dictionary in _fx:
		if str(fx["layer"]) == layer and str(fx["kind"]) == "text":
			var alpha: float = float(fx["alpha"])
			_dbtext(at + Vector2(float(fx["x"]) - 90.0, float(fx["y"]) - 12.0), 180.0, 24.0, 16.0, Color(fx["color"], alpha), Color(PN_INK, alpha), 
				"center", str(fx["text"]))





func _card_name(corner: Vector2, text: String, color: Color) -> void :
	var x: float = float(PN_CARD_NAME[0]) - 5.0
	var w: float = float(PN_CARD_NAME[2]) + 10.0
	var size: float = 11.0
	while size > 9.0 and text_width(text, size) > w - 4.0:
		size -= 0.5
	if text_width(text, size) <= w - 4.0:
		_dbtext(corner + Vector2(x, float(PN_CARD_NAME[1])), w, float(PN_CARD_NAME[3]), size, color, PN_INK, "center", text)
		return
	var words: PackedStringArray = text.split(" ")
	var best: int = 1
	var best_w: float = INF
	for cut in range(1, words.size()):
		var wide: float = maxf(text_width(" ".join(words.slice(0, cut)), 9.0), text_width(" ".join(words.slice(cut)), 9.0))
		if wide < best_w:
			best_w = wide
			best = cut
	var top: float = float(PN_CARD_NAME[1]) - 4.5
	for k in 2:
		var line: String = " ".join(words.slice(0, best)) if k == 0 else " ".join(words.slice(best))
		_fit(corner + Vector2(x, top + float(k) * 9.0), w, 12.0, 9.0, color, PN_INK, "center", line)


func _fit(at: Vector2, w: float, h: float, px: float, color: Color, glow: Color, align: String, text: String, least: float = 7.0) -> float:
	var size: float = px
	while size > least and text_width(text, size) > w - 4.0:
		size -= 0.5
	return _dbtext(at, w, h, size, color, glow, align, text)


func _para(at: Vector2, w: float, h: float, px: float, color: Color, glow: Color, text: String) -> void :
	var lines: Array = []
	var line: String = ""
	for word: String in text.split(" "):
		var next: String = word if line.is_empty() else line + " " + word
		if not line.is_empty() and text_width(next, px) > w - 4.0:
			lines.append(line)
			line = word
		else:
			line = next
	if not line.is_empty():
		lines.append(line)
	var step: float = roundf(px * 1.15) - 1.0
	var high: float = step * float(lines.size()) + 1.0 + 6.0
	var top: float = at.y + float(int((h - high) / 2.0))
	for i in lines.size():
		_fwords(str(lines[i]), ARIAL_BOLD, px, color, "c", Vector2(at.x, top + float(i) * step), w, 2.0 if glow.a > 0.0 else 0.0, 0.0, false, glow)


func _dot(centre: Vector2) -> void :
	draw_circle(centre * _f, 5.5 * _f, PN_DOT)
	draw_arc(centre * _f, 5.5 * _f, 0.0, TAU, 24, Color.WHITE, 1.5 * _f, true)

func _body(at: Vector2) -> void :
	if not _b_ready:

		_round(Rect2((at + Vector2(0, 60)) * _f, Vector2(win_size.x, win_size.y - 60.0) * _f), Color(SHADOW, 0.96), 12.0, Color(1, 1, 1, 0.35), 1.0)
		_dbtext(at + Vector2(0, 280), win_size.x, 30.0, 14.0, Color.WHITE, NONE, "center", 
			"Không tải được giao diện, hãy thử lại." if _b_failed else "Đang tải...")
		return
	pic("pn_bg", at)
	if tab == 2:
		_shop(at)
	elif tab == 0 or tab == 1:
		_track(at, tab)
	elif tab == 3:
		_hunt(at)
	else:
		_locked(at, tab)
	_tabs(at)
	_chips(at)
	_crown(at)
	if art("btn_close_st") != null:
		art_button("close", "btn_close_st", at + PN_CLOSE, 1)


func _chrome(at: Vector2) -> void :
	if not _b_ready or art("btn_close_st") == null:
		var cell: Vector2 = _cell_size("public_button_close")
		_fbutton("close", "public_button_close", at + Vector2(win_size.x - 20.0 - cell.x, 78.0))


func _tabs(at: Vector2) -> void :
	for i in 6:
		var corner: Vector2 = at + Vector2(float(PN_TABS[i * 2]), float(PN_TABS[i * 2 + 1]))
		var locked: bool = i >= 4
		var id: String = "tab:%d" % i
		var plate: String = "tab_selected" if i == tab else ("tab_locked" if locked else "tab_normal")
		if i != tab and _hover == id and _press.is_empty() and _tip_ok():
			var size: Vector2 = art_size(plate)
			for k in 3:
				var grow: float = 2.0 + 2.5 * float(k)
				_round(Rect2((corner - Vector2(grow, grow)) * _f, (size + Vector2(grow, grow) * 2.0) * _f), Color(PN_GOLD, 0.16), 14.0 + grow)
		pic(plate, corner)
		pic("tabicon_" + str(PN_TAB_KEYS[i]), corner + PN_TAB_ICON, 0.7 if locked and i != tab else 1.0)
		pic("tablabel_" + str(PN_TAB_KEYS[i]), corner + PN_TAB_LABEL)
		if locked:
			pic("tab_lock", corner + PN_TAB_LOCK)
		if i < 2 and claimable(i) > 0:
			_dot(corner + PN_TAB_DOT)
		if i != tab:
			_hit(id, Rect2((corner + PN_TAB_HIT.position) * _f, PN_TAB_HIT.size * _f), false)


func _chips(at: Vector2) -> void :
	var corner: Vector2 = at + PN_WALLET
	pic("chip_wallet", corner)
	pic("token_24", corner + PN_WALLET_TOKEN)
	_dbtext(corner + Vector2(float(PN_WALLET_TEXT[0]), float(PN_WALLET_TEXT[1])), float(PN_WALLET_TEXT[2]), float(PN_WALLET_TEXT[3]), 15.0, PN_CREAM, PN_INK, 
		"center", wallet_text())
	tip_area(Rect2(corner, Vector2(float(PN_WALLET_TEXT[0]) + float(PN_WALLET_TEXT[2]), float(PN_WALLET_TEXT[1]) * 2.0 + float(PN_WALLET_TEXT[3]))), pumpkin_id, "")
	corner = at + PN_TIME
	pic("chip_time", corner)
	_dbtext(corner + Vector2(float(PN_TIME_TEXT[0]), float(PN_TIME_TEXT[1])), float(PN_TIME_TEXT[2]), float(PN_TIME_TEXT[3]), 13.0, PN_CREAM, PN_INK, 
		"center", _time_line)
	tip_area(Rect2(corner, Vector2(float(PN_TIME_TEXT[0]) + float(PN_TIME_TEXT[2]), float(PN_TIME_TEXT[1]) * 2.0 + float(PN_TIME_TEXT[3]))), 0, _time_tip)


func _crown(at: Vector2) -> void :
	var texture: Texture2D = art("fx_bat")
	if texture == null:
		return
	var cell: Vector2 = Vector2(64, 48)
	for i in 2:
		var p: float = float(i) * 2.1
		var centre: Vector2 = at + Vector2(float(PN_BATS[i * 2]) + 14.0 * sin(float(tick) * 0.035 + p), float(PN_BATS[i * 2 + 1]) + 6.0 * sin(float(tick) * 0.07 + p))
		draw_set_transform(centre * _f, 0.0, Vector2(-1.0 if i % 2 == 1 else 1.0, 1.0))
		draw_texture_rect_region(texture, Rect2( - Vector2(32, 24) * _f, cell * _f), sheet_region("fx_bat", int(_bat_f[i])))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _shop(at: Vector2) -> void :
	var feat: Variant = featured()
	var list: Array = grid()
	var count: int = pages()
	var is_busy: bool = busy()
	pic("shop_sign", at + PN_SIGN)
	pic(_teddy_key, at + PN_TEDDY)
	pic("counter", at + PN_COUNTER)
	_draw_fx(at, "pot")
	pic("bubble", at + PN_BUBBLE)
	_para(at + PN_BUBBLE + Vector2(float(PN_BUBBLE_TEXT[0]), float(PN_BUBBLE_TEXT[1])), float(PN_BUBBLE_TEXT[2]), float(PN_BUBBLE_TEXT[3]), 12.0, PN_INK_TEXT, NONE, 
		_say_line)
	var k: int = tick % 230
	if k < 182:
		var lift: float = 60.0 * (1.0 - float(k) / 30.0) if k < 30 else (0.0 if k < 150 else (60.0 * float(k - 150) / 30.0 if k < 180 else 60.0))
		var sway: float = 3.0 * sin(float(k - 30) * 0.08) if k >= 30 and k < 150 else 0.0
		pic("ghost", at + PN_GHOST + Vector2(sway, lift))
	if feat != null:
		_featured(at, feat, is_busy)
	var n: int = 0
	var i: int = page * 8
	while i < list.size() and n < 8:
		_goods(at, list[i], Vector2(float(PN_GRID_X[n % 4]), float(PN_GRID_Y[n / 4])), is_busy)
		n += 1
		i += 1
	if count > 1:
		art_button("page:-1", "arrow_l_st", at + Vector2(float(PN_ARROWS[0]), float(PN_ARROWS[1])), 1 if page > 0 else -1)
		art_button("page:1", "arrow_r_st", at + Vector2(float(PN_ARROWS[2]), float(PN_ARROWS[3])), 1 if page < count - 1 else -1)
		var dots: float = float(PN_DOTS[0]) - float(count - 1) * float(PN_DOTS[2]) / 2.0
		for d in count:
			pic("dot_on" if d == page else "dot_off", at + Vector2(dots + float(d) * float(PN_DOTS[2]) - float(PN_DOTS[3]), float(PN_DOTS[1])))


func _featured(at: Vector2, g: Dictionary, is_busy: bool) -> void :
	var left: bool = goods_left(g)
	var goods_name: String = item_name(int(g["item"]))
	pic("feat_card", at + PN_FEAT)
	var veh: Vector2 = at + Vector2(float(PN_FEAT_VEH[0]), float(PN_FEAT_VEH[1]) + 3.0 * sin(float(tick) * 0.07))
	pic("feat_vehicle", veh, 1.0 if left else 0.55)
	tip_area(Rect2(at + Vector2(float(PN_FEAT_VEH[0]), float(PN_FEAT_VEH[1])), Vector2(float(PN_FEAT_VEH[2]), float(PN_FEAT_VEH[3]))), int(g["item"]), "")
	pic("ribbon_hot", at + PN_FEAT_HOT)
	_para(at + Vector2(float(PN_FEAT_NAME[0]), float(PN_FEAT_NAME[1])), float(PN_FEAT_NAME[2]), float(PN_FEAT_NAME[3]), 15.0, PN_GOLD, PN_INK, 
		(goods_name if not goods_name.is_empty() else "Xe Bí Ngô") + (" x%d" % int(g["n"]) if int(g["n"]) > 1 else ""))
	var price: Vector2 = at + PN_FEAT_PRICE
	pic("price_l", price)
	pic("token_24", price + PN_PRICE_L_TOKEN)
	_dbtext(price + Vector2(float(PN_PRICE_L_TEXT[0]), float(PN_PRICE_L_TEXT[1])), float(PN_PRICE_L_TEXT[2]), float(PN_PRICE_L_TEXT[3]), 15.0, 
		PN_CREAM if afford(g) else PN_SHORT, PN_INK, "center", num(int(g["price"])))
	_dbtext(at + Vector2(float(PN_FEAT_STOCK[0]), float(PN_FEAT_STOCK[1])), float(PN_FEAT_STOCK[2]), float(PN_FEAT_STOCK[3]), 12.0, PN_SOFT, PN_INK, "center", stock(g))
	art_button("buy:" + str(g["id"]), "btn_doi_l_st", at + PN_FEAT_BTN, (0 if is_busy else 1) if left else -1)
	if not left:
		pic("stamp_het", at + PN_FEAT_STAMP)


func _goods(at: Vector2, g: Dictionary, cell: Vector2, is_busy: bool) -> void :
	var left: bool = goods_left(g)
	var corner: Vector2 = at + cell
	var centre: Vector2 = corner + Vector2(float(PN_CARD_WELL[0]), float(PN_CARD_WELL[1]))
	var side: float = float(PN_CARD_WELL[2])
	pic("good_card" if left else "good_card_off", corner)
	icon(int(g["item"]), side, centre, 1.0 if left else 0.5)
	if int(g["n"]) > 1:
		_dbtext(centre + Vector2( - side / 2.0, side / 2.0 - 16.0), side + 4.0, 16.0, 12.0, PN_CREAM, PN_INK, "right", "x%d" % int(g["n"]))
	tip_area(Rect2(centre - Vector2(side, side) / 2.0, Vector2(side, side)), int(g["item"]), "")
	_card_name(corner, item_name(int(g["item"])), PN_CREAM if left else PN_SOFT)
	var price: Vector2 = corner + PN_CARD_PRICE
	pic("price_s", price)
	pic("token_16", price + PN_PRICE_S_TOKEN)
	_dbtext(price + Vector2(float(PN_PRICE_S_TEXT[0]), float(PN_PRICE_S_TEXT[1])), float(PN_PRICE_S_TEXT[2]), float(PN_PRICE_S_TEXT[3]), 13.0, 
		PN_CREAM if afford(g) or not left else PN_SHORT, PN_INK, "center", num(int(g["price"])))
	_dbtext(corner + Vector2(float(PN_CARD_STOCK[0]), float(PN_CARD_STOCK[1])), float(PN_CARD_STOCK[2]), float(PN_CARD_STOCK[3]), 11.0, PN_SOFT, PN_INK, "center", stock(g))
	art_button("buy:" + str(g["id"]), "btn_doi_s_st", corner + PN_CARD_BTN, (0 if is_busy else 1) if left else -1)
	if not left:
		pic("stamp_het", corner + PN_CARD_STAMP)


func _track(at: Vector2, t: int) -> void :
	var track: Variant = tracks[t] if tracks.size() > t else null
	var list: Array = track["list"] if track != null else []
	var total: float = float(track["total"]) if track != null else 0.0
	var is_busy: bool = busy()
	var word: String = "nạp" if t == 0 else "tiêu"
	var head: Vector2 = at + PN_MS_HEAD
	pic("ms_head", head)

	_fit(head + Vector2(float(PN_MS_HEAD_TEXT[0]) + PN_MS_HEAD_DX, float(PN_MS_HEAD_TEXT[1])), float(PN_MS_HEAD_TEXT[2]) - PN_MS_HEAD_DX, float(PN_MS_HEAD_TEXT[3]), 
		16.0, PN_CREAM, PN_INK, "left", "Đã " + word + " trong sự kiện: " + num(int(total)) + " Xu")
	_dbtext(head + Vector2(float(PN_MS_SUB[0]), float(PN_MS_SUB[1])), float(PN_MS_SUB[2]), float(PN_MS_SUB[3]), 12.0, PN_SOFT, PN_INK, "left", 
		(("Nạp Xu đạt mốc để nhận Bí Ngô và quà." if t == 0 else "Tiêu Xu trong game đạt mốc để nhận Bí Ngô và quà.") if earning
			else "Sự kiện đã kết thúc: vẫn nhận được các mốc đã đạt."))
	art_button("claim:%d:all" % t, "btn_nhanhet_st", at + PN_MS_ALL, ((0 if is_busy else 1) if claimable(t) > 0 else -1))
	var bar: Vector2 = at + PN_MS_BAR
	pic("ms_bar_empty", bar)
	var full: Texture2D = art("ms_bar_full")
	if full != null:
		var cut: float = maxf(1.0, bar_x(list, total))
		draw_texture_rect_region(full, Rect2(bar * _f, Vector2(cut, float(full.get_height())) * _f), Rect2(0, 0, cut, float(full.get_height())))
	for i in mini(7, list.size()):
		var m: Dictionary = list[i]
		var s: int = int(m["s"])
		var card: Vector2 = at + Vector2(float(PN_MS_CARD_X[i]), PN_MS_CARD_Y)
		if s == 1:
			pic("ms_glow", card + PN_MS_GLOW, _glow_a)
		pic("ms_card_off" if s == 0 else "ms_card", card, 0.8 if s == 2 else 1.0)
		pic("ms_node_on" if total >= float(m["need"]) else "ms_node", bar + Vector2(float(PN_MS_NODE[i]) - PN_MS_NODE_C.x, PN_MS_NODE_C.y))
		_dbtext(card + Vector2(float(PN_MS_AMOUNT[0]), float(PN_MS_AMOUNT[1])), float(PN_MS_AMOUNT[2]), float(PN_MS_AMOUNT[3]), 13.0, PN_SOFT if s == 0 else PN_GOLD, 
			PN_INK, "center", num(int(float(m["need"]))) + " Xu")
		if int(m["pk"]) > 0:
			pic("token_24", card + PN_MS_TOKEN)
			_dbtext(card + Vector2(float(PN_MS_PK[0]), float(PN_MS_PK[1])), float(PN_MS_PK[2]), float(PN_MS_PK[3]), 13.0, PN_CREAM, PN_INK, "left", "x" + num(int(m["pk"])))
			tip_area(Rect2(card + PN_MS_TOKEN, Vector2(24, 24)), pumpkin_id, "")
		var items: Array = m["items"]
		var well: Vector2 = card + Vector2(float(PN_MS_WELL[0]), float(PN_MS_WELL[1]))
		var side: float = float(PN_MS_WELL[2])
		if not items.is_empty():
			icon(int(items[0]["id"]), side, well)
			if int(items[0]["n"]) > 1:
				_dbtext(well + Vector2( - side / 2.0, side / 2.0 - 15.0), side + 6.0, 16.0, 12.0, PN_CREAM, PN_INK, "right", "x%d" % int(items[0]["n"]))
			tip_area(Rect2(well - Vector2(side, side) / 2.0, Vector2(side, side)), int(items[0]["id"]), "")
		if s == 1:
			art_button("claim:%d:%d" % [t, int(float(m["need"]))], "btn_nhan_st", card + Vector2(float(PN_MS_BTN[0]), float(PN_MS_BTN[1])), 0 if is_busy else 1)
		elif s == 2:
			pic("stamp_danhan", card + PN_MS_STAMP)
		else:
			_dbtext(card + Vector2(float(PN_MS_BTN[0]) - 6.0, float(PN_MS_BTN[1])), float(PN_MS_BTN[2]) + 12.0, float(PN_MS_BTN[3]), 11.0, PN_SOFT, PN_INK, "center", 
				"Còn " + num(int(float(m["need"]) - total)))


func _hunt(at: Vector2) -> void :
	var got: int = int(hunt.get("got", 0))
	var cap_raw: int = int(hunt.get("cap", 0))
	var cap: int = maxi(1, cap_raw)
	pic("hunt_scene", at + PN_HU_SCENE)
	var basket: Vector2 = at + PN_HU_BASKET
	pic("hunt_basket_empty", basket)
	var full: Texture2D = art("hunt_basket_full")
	if full != null:
		var cut: float = float(PN_HU_FILL[1]) + float(PN_HU_FILL[2]) * (1.0 - minf(1.0, float(got) / float(cap)))
		var w: float = float(full.get_width())
		var h: float = maxf(1.0, float(full.get_height()) - cut)
		draw_texture_rect_region(full, Rect2((basket + Vector2(0, cut)) * _f, Vector2(w, h) * _f), Rect2(0, cut, w, h))
	pic("hunt_board", at + PN_HU_BOARD)
	var count: Vector2 = at + Vector2(float(PN_HU_COUNT[0]), float(PN_HU_COUNT[1]))
	_dbtext(count, float(PN_HU_COUNT[2]), float(PN_HU_COUNT[3]), 24.0, PN_GOLD, PN_INK, "center", "%d / %d" % [got, cap_raw])
	_dbtext(count + Vector2(0, float(PN_HU_COUNT[3]) - 4.0), float(PN_HU_COUNT[2]), 18.0, 12.0, PN_SOFT, PN_INK, "center", 
		"Bí Ngô săn được hôm nay" if earning else "Mùa săn đã kết thúc")


	var rows: Array = [["Thắng trận: +%d Bí Ngô" % int(hunt.get("win", 0)), "Thua trận: +%d Bí Ngô" % int(hunt.get("lose", 0))], 
		["Trận đấu tối thiểu %d giây" % int(hunt.get("min", 60)), "(PvP hoặc Phụ Bản)"], 
		["Tối đa %d Bí Ngô mỗi ngày" % cap_raw, "Hôm nay đã đánh %d trận" % int(hunt.get("matches", 0))]]
	for i in rows.size():
		var mid: float = float(PN_HU_RULES[1]) + 10.0 + float(i) * float(PN_HU_RULES[3])
		pic("token_16", at + Vector2(float(PN_HU_RULES[0]), mid - 8.0))
		for k in 2:
			_fit(at + Vector2(float(PN_HU_RULES[0]) + 30.0, mid - 14.0 + float(k) * 13.0), float(PN_HU_RULES[2]) - 14.0, 14.0, 11.0, 
				PN_CREAM if i == 0 else PN_SOFT, PN_INK, "left", str(rows[i][k]))
	art_button("hunt", "btn_disan_st", at + PN_HU_BTN, 1 if earning and got < cap_raw else -1)


func _locked(at: Vector2, t: int) -> void :
	pic("lock_scene", at + PN_LK_SCENE)
	_dbtext(at + Vector2(float(PN_LK_TITLE[0]), float(PN_LK_TITLE[1])), float(PN_LK_TITLE[2]), float(PN_LK_TITLE[3]), 22.0, PN_GOLD, PN_INK, "center", 
		"BẮN BÍ NGÔ" if t == 4 else "BOSS BÍ NGÔ")
	_para(at + Vector2(float(PN_LK_HINT[0]), float(PN_LK_HINT[1])), float(PN_LK_HINT[2]), float(PN_LK_HINT[3]), 13.0, PN_SOFT, PN_INK, 
		PN_HINT_SHOOT if t == 4 else PN_HINT_BOSS)
