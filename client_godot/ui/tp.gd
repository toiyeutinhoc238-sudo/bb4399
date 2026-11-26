extends "tev_window.gd"












signal closed(note: String)

const TpArt = preload("tp_art.gd")
const TpArt8 = preload("tp_art8.gd")
const Emotes = preload("chat_emotes.gd")
const Settings = preload("res://settings.gd")
const TP_TIP: String = "Cờ Tỷ Phú"
const NORMAL: Vector2 = Vector2(960, 580)


const TABLE: Vector2 = Vector2(1410, 840)
const HEAD: float = 40.0

const BOARD: Array = [
	["Bắt Đầu", "start", -1, 0], 
	["Cà Mau", "land", 0, 60], ["May Rủi", "luck", -1, 0], ["Đà Lạt", "land", 0, 70], ["Vũng Tàu", "land", 1, 90], 
	["Lạng Sơn", "land", 1, 100], ["Thái Bình", "land", 2, 120], ["Ninh Bình", "land", 2, 130], 
	["Côn Đảo", "jail", -1, 0], 
	["Đồ Sơn", "land", 3, 150], ["Pleiku", "land", 3, 150], ["Ninh Thuận", "land", 3, 160], ["Cơ Hội", "chance", -1, 0], 
	["Tây Ninh", "land", 4, 180], ["Hạ Long", "land", 4, 190], ["Hải Phòng", "land", 4, 200], 
	["Lễ Hội", "fest", -1, 0], 
	["Thanh Hóa", "land", 5, 220], ["Nha Trang", "land", 5, 230], ["Sa Pa", "land", 5, 240], ["Cơ Hội", "chance", -1, 0], 
	["Hội An", "land", 6, 260], ["Huế", "land", 6, 270], ["Đà Nẵng", "land", 6, 280], 
	["Bến Xe", "bus", -1, 0], 
	["Phú Quốc", "land", 7, 300], ["Bình Dương", "land", 7, 310], ["Cần Thơ", "land", 7, 320], ["Cơ Hội", "chance", -1, 0], 
	["Sài Gòn", "land", 8, 360], ["Thuế", "tax", -1, 0], ["Hà Nội", "land", 8, 400], 
]
const N: int = 32
const BUS: int = 24
const GROUP_COL: Array = ["2bb3a3", "efd75a", "3d8fe0", "f08cb4", "62c24a", "f28c28", "e04646", "c25ad6", "7a5ce0"]
const PLAYER_COL: Array = ["ff8a1f", "3fa9f5", "4cd964", "d16bff"]
const WHY: Dictionary = {"last": "Chỉ còn một người chưa phá sản", "rounds": "Hết số lượt của ván", "time": "Hết giờ ván"}
const PHASE_HINT: Dictionary = {"roll": "tung xúc xắc", "bus": "chọn ô đi xe", "buy": "mua đất", "build": "xây nhà", "fest": "mở Lễ Hội", "take": "mua lại đất"}

const BAR: float = 50.0
const ROSE_R: float = 0.21
const CS: float = 0.15
const TW: float = 0.1
var bc: Vector2 = Vector2(700, 290)
var ba: float = 230.0
var bb: float = 120.0
var bk: float = 1.0

var tp_visible: bool = false
var token: String = ""
var stakes: Array = [100000, 200000]
var sizes: Array = [4, 3, 2]
var bal: int = -1
var q_key: String = ""
var q_n: int = 0
var q_since: float = 0.0
var q_step: int = 30
var counts: Dictionary = {}
var turn_s: int = 20
var game_min: int = 15
var max_rounds: int = 30
var starting: bool = false
var active_gid: String = ""
var stake_pick: int = 0
var game: Dictionary = {}
var lines: Array = []
var seen_n: int = 0
var shown: Array = []
var paths: Array = []
var dice_at: float = -100000.0
var banner: String = ""
var banner_at: float = -100000.0
var banner_bad: bool = false
var floats: Array = []
var flash_tile: Dictionary = {}
var parity: String = ""
var confirm: String = ""
var pick_tile: int = -1
var pick_at: float = 0.0
var in_lobby: bool = false
var away_at: float = 0.0
var net_hook: Callable
var _reqs: Dictionary = {}
var _what: Dictionary = {}
var _busy: Dictionary = {}
var _writes: Array = []
var _next_poll: float = 0.0
var _g_retry: float = 0.0
var _icon_tex: Texture2D
var _word_tex: Texture2D



const ZONES: Array = [[2, 4], [5, 7], [8, 10], [11, 12]]
const ZONE_COL: Array = ["3fa9f5", "4cd964", "ffc540", "ff6a3d"]
const HOLD_MS: float = 250.0
const NEEDLE_MS: float = 1100.0
const WALK_MS: float = 150.0
const DICE_MS: float = 700.0
const PAWN_FOOT: float = 0.93
const PAWN_W: float = 58.0
const CH_W: float = 120.0
const CH_H: float = 200.0
const CH_FOOT: float = 0.96
const CH_HEAD: float = 1.22
const CB_W: float = 0.7
const HEX_FACE: float = 0.43
const HEX_TAG: float = 0.48

const ARC_R: float = 84.0
const ARC_DY: float = 26.0
const ARC_GAP: float = 0.32
const ARC_LBL: float = 0.1
const ARC_W0: float = 0.025
const ARC_W1: float = 0.27

const RD_FACE: float = 0.62
const PB_FACE: float = 0.6
const RD_W: float = 104.0
const PB_W: float = 62.0
const RD_SINK: float = 0.05
const HOUSE_K: float = 1.55
const FACE_V: float = 0.725
const LOT_R: float = 0.2
const LOT_B: float = 1.2
var _ysq: Array = []
var _ydefer: bool = false
var _sum_q: Array = []
var _pawn_at: Dictionary = {}


const DEMO_TANKS: Array = ["scifisix", "haiwang01", "douwa03_pf02", "zuqiuxiaozi02"]
const DEMO_PETS: Array = ["pet/ts_fenghuang03", "pet/ts_fangyu501", "pet/ts_fuzhu101", "pet/ts_gongji705"]
const TK_W: Dictionary = {"tank": 1.1, "pet": 1.3}
const TK_BASE: float = 1.0
const TK_SIT: Dictionary = {"tank": 0.3, "pet": 0.35}
var look: String = "tank"
var demo_looks: bool = false
var _pawn_head: Dictionary = {}
var _crop: Dictionary = {}
var _face_of: Dictionary = {}
var _pic_hooked: bool = false
var _select_tank: Script
const PAWN_R: float = 0.14
const PAWN_STEP: float = 0.1
const PAWN_SIDE: Array = [0.18, 0.12, 0.08]
const PAWN_KEY: float = 0.0
const OWN_W: float = 5.0
const OWN_INK_W: float = 2.8
const OWN_INK: Color = Color(0.09, 0.05, 0.02, 0.92)
const SEAT_RING: float = 0.07
const LOT_A: float = 0.27
const DIE_W: float = 60.0
var die_w: float = DIE_W

const DIE_FACE: Array = [[Vector2(0.494, 0.03), Vector2(0.928, 0.285), Vector2(0.094, 0.29)], 
	[Vector2(0.094, 0.29), Vector2(0.495, 0.49), Vector2(0.083, 0.665)], [Vector2(0.495, 0.49), Vector2(0.928, 0.285), Vector2(0.495, 0.965)]]

const DIE_SIDE: Dictionary = {1: [2, 3], 2: [4, 6], 3: [2, 6], 4: [5, 1], 5: [3, 1], 6: [5, 4]}
const DIE_T: Array = [360.0, 540.0, 660.0]
const JUMP_MS: float = 420.0
const EMO_PACK: String = "basic_v1"
const EMO_PICK: Array = ["grin", "joy", "rofl", "wink", "heart_eyes", "star_struck", "partying_face", "money_face", "sunglasses_face", 
	"thinking_face", "hug_face", "salute", "sweat", "scared", "loudly_crying", "rage", "mind_blown", "skull"]
const QUICK: Array = ["Chúc may mắn", "Nhanh lên nào", "Hay quá", "Ôi không"]
const SAY_MAX: int = 60
const TALK_GAP: float = 2000.0
var fake_now: float = -1.0
var _rep_id: String = "roll"
var hops: Array = []
var sink: Dictionary = {}
var rest_at: Dictionary = {}
var fx: Array = []
var hold_at: float = -1.0
var space_at: float = -1.0
var zone_hit: int = -1
var zone_at: float = -100000.0
var roll_wait: float = -100000.0
var dice_from: int = -1
var dice_z: int = -1
var cam_cell: int = -1
var cam_at: float = -100000.0
var _cam: Transform2D = Transform2D.IDENTITY
var cash_shown: Dictionary = {}
var cash_dir: Dictionary = {}
var shake_at: Dictionary = {}
var out_at: Dictionary = {}
var grow_at: Dictionary = {}
var flag_at: Dictionary = {}
var pot_at: float = -100000.0
var over_at: float = -100000.0
var order_at: float = -100000.0
var _last_neg: Dictionary = {}
var _go_wait: Dictionary = {}
var _go_amt: Dictionary = {}
var _old_tiles: Dictionary = {}
var _warned_min: bool = false
var talk: Array = []
var talk_seen: int = 0
var hide_talk: bool = false
var talk_pane: String = ""
var log_open: bool = false
var emo_at: float = -100000.0
var say_at: float = -100000.0
var _emotes: Node
var _say_edit: LineEdit
var _order0: int = 0
var _uv4: PackedVector2Array = PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
const FX_LIFE: Dictionary = {"pay": 1500.0, "cert": 1250.0, "card": 4000.0, "rain": 1700.0, "warn": 1600.0, "price": 1200.0, 
	"rent": 1300.0, "go": 1400.0, "ghost": 900.0, "rays": 1600.0}



func _setup() -> void :
	win_size = NORMAL
	super ()

func now_ms() -> float:
	return fake_now if fake_now >= 0.0 else float(Time.get_ticks_msec())


static func low_gfx() -> bool:
	return int(Settings.value("quality")) == 2 or str(Settings.value("tc_gfx")) == "low"


static func gfx_level() -> int:
	if low_gfx():
		return 0
	return 1 if str(Settings.value("tc_gfx")) == "mid" else 2


func chat_busy() -> bool:
	return opened and not game.is_empty()

func typing() -> bool:
	return _say_edit != null and _say_edit.visible and _say_edit.has_focus()

static func _png(b64: String, w: int, h: int) -> Texture2D:
	var img: Image = Image.new()
	if img.load_png_from_buffer(Marshalls.base64_to_raw(b64)) != OK:
		return null
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	tex.set_size_override(Vector2i(w, h))
	return tex

func button_icon() -> Texture2D:
	if _icon_tex == null:
		_icon_tex = _png(ICON_B64, 50, 50)
	return _icon_tex

func button_word() -> Texture2D:
	if _word_tex == null:
		_word_tex = _png(WORD_B64, 66, 20)
	return _word_tex

func load_art() -> void :
	_art_asked = true

func art_pending() -> int:
	return 0 if _art_asked else -1

func retry_art() -> void :
	pass



func boot() -> void :
	in_lobby = true
	_next_poll = 0.0
	poll()

func beat() -> void :
	in_lobby = true
	if now_ms() >= _next_poll:
		poll()
	_game_loop()
	_sync_vis()

func playing() -> bool:
	return not game.is_empty() and str(game.get("over", "0")) != "1"

func poll() -> void :
	if _busy.get("l", false):
		return
	var gap: float = 60000.0
	if tp_visible:
		if not q_key.is_empty() or starting or not active_gid.is_empty():
			gap = 3000.0
		elif opened:
			gap = 4000.0
		else:
			gap = 20000.0
	_next_poll = now_ms() + gap
	_send("l", "/ctp.xml?t=%d" % now_ms(), "lobby")

func button_visible() -> bool:
	return tp_visible

func button_dot() -> bool:
	return tp_visible and ( not q_key.is_empty() or playing())

func button_tip() -> String:
	return TP_TIP

func minigame_active() -> bool:
	return opened and playing()

func open() -> void :
	if opened or not tp_visible:
		return
	show_window()
	load_art()
	_emo_store()
	if stake_pick == 0 and not stakes.is_empty():
		stake_pick = int(stakes[0])
	_come_back()
	poll()


func request_close() -> void :
	close()

func close(note: String = "") -> void :
	confirm = ""
	if not opened:
		return
	if not game.is_empty() and str(game.get("over", "0")) == "1":
		_dismiss()
	elif playing() and not _me_out():
		_go_away()
		if note.is_empty():
			note = "Cờ Tỷ Phú: máy đang đi thay bạn, mở lại để chơi tiếp."
	hide_window()
	_sync_vis()
	closed.emit(note)

func leave() -> void :
	in_lobby = false
	if not q_key.is_empty():
		_act("unqueue")
		q_key = ""
	close()
	_go_away()
	_sync_vis()

func reset() -> void :
	in_lobby = false
	close()
	for ch: String in _reqs:
		(_reqs[ch] as HTTPRequest).cancel_request()
	_busy = {}
	_writes = []
	tp_visible = false
	token = ""
	q_key = ""
	active_gid = ""
	starting = false
	_clear_game()
	visible = false

func _clear_game() -> void :
	game = {}
	_evq8 = []
	_fest8 = {}
	_memo8 = {}
	_hold8 = 0.0
	_cend8 = 0.0
	_gate8 = -1.0
	lines = []
	seen_n = 0
	shown = []
	paths = []
	floats = []
	flash_tile = {}
	parity = ""
	confirm = ""
	banner = ""
	away_at = 0.0
	pick_tile = -1
	hops = []
	sink = {}
	rest_at = {}
	fx = []
	hold_at = -1.0
	space_at = -1.0
	zone_hit = -1
	zone_at = -100000.0
	roll_wait = -100000.0
	dice_at = -100000.0
	dice_from = -1
	dice_z = -1
	cam_cell = -1
	cam_at = -100000.0
	cash_shown = {}
	cash_dir = {}
	shake_at = {}
	out_at = {}
	grow_at = {}
	flag_at = {}
	pot_at = -100000.0
	over_at = -100000.0
	order_at = -100000.0
	_last_neg = {}
	_go_wait = {}
	_go_amt = {}
	_old_tiles = {}
	_warned_min = false
	talk = []
	talk_seen = 0
	talk_pane = ""
	log_open = false
	if _say_edit != null:
		_say_edit.text = ""
		_say_edit.visible = false
		_say_edit.release_focus()

func _sync_vis() -> void :
	visible = opened


func _dismiss() -> void :
	if not game.is_empty():
		_act("leave")
	active_gid = ""
	_clear_game()

func _go_away() -> void :
	if not playing() or away_at > 0.0 or _me_out():
		return
	away_at = now_ms()
	_act("away")

func _come_back() -> void :
	if not playing():
		away_at = 0.0
		return
	var me: Dictionary = _me()
	if away_at > 0.0 or str(me.get("away", "0")) == "1":
		away_at = 0.0
		me["away"] = "0"
		_act("back")

func _tip(text: String) -> void :
	if opened:
		say(text)
	elif hub != null and hub.has_method("say"):
		hub.call("say", text)



func _send(ch: String, url: String, what: String) -> void :
	url += ("&" if url.contains("?") else "?") + "cv=8"
	_what[ch] = what
	_busy[ch] = true
	if net_hook.is_valid():
		net_hook.call(url, ch)
		return
	if client == null or client.config == null or client.config.local_test_only or str(client.config.origin).is_empty():
		_busy[ch] = false
		return
	var http: HTTPRequest = _reqs.get(ch)
	if http == null:
		http = HTTPRequest.new()
		http.timeout = 25.0 if ch == "g" else 10.0
		http.accept_gzip = false
		add_child(http)
		http.request_completed.connect( func(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void :
			take(ch, code if result == HTTPRequest.RESULT_SUCCESS else 0, body.get_string_from_utf8()))
		_reqs[ch] = http
	var full: String = str(client.config.origin) + url
	if http.request(full, AppSession.headers(full)) != OK:
		_busy[ch] = false


func take(ch: String, code: int, text: String) -> void :
	if not _busy.get(ch, false):
		return
	_busy[ch] = false
	if code == 200:
		_take(text)
	elif ch == "g":
		_g_retry = now_ms() + 2000.0
	elif ch == "w":
		say("Mất kết nối, thử lại sau.")
	if ch == "w":
		_pump()
	_game_loop()
	_sync_vis()
	queue_redraw()

func _act(a: String, extra: String = "") -> void :
	_writes.append("/ctp-act.xml?a=%s%s" % [a, extra])
	_pump()

func _pump() -> void :
	if _busy.get("w", false) or _writes.is_empty():
		return
	var url: String = str(_writes.pop_front())
	_send("w", "%s&k=%s&t=%d" % [url, token.uri_encode(), now_ms()], "act")


func _game_loop() -> void :
	if not opened or not playing() or _busy.get("g", false) or now_ms() < _g_retry:
		return
	_send("g", "/ctp.xml?g=%s&v=%d&t=%d" % [str(game["id"]).uri_encode(), int(game.get("v", 0)), now_ms()], "game")


static func tree_xml(text: String) -> Dictionary:
	var tags: RegEx = RegEx.create_from_string("<\\?[\\s\\S]*?\\?>|<(/?)([A-Za-z_][\\w.:-]*)((?:\\s+[A-Za-z_][\\w.:-]*\\s*=\\s*(?:\"[^\"]*\"|'[^']*'))*)\\s*(/?)>")
	var attrs: RegEx = RegEx.create_from_string("([A-Za-z_][\\w.:-]*)\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)')")
	var root: Dictionary = {}
	var stack: Array = []
	for found: RegExMatch in tags.search_all(text):
		if found.get_string(2).is_empty():
			continue
		if found.get_string(1) == "/":
			if stack.is_empty():
				return {}
			stack.pop_back()
			continue
		var node: Dictionary = {"tag": found.get_string(2), "at": {}, "kids": []}
		for pair: RegExMatch in attrs.search_all(found.get_string(3)):
			node["at"][pair.get_string(1)] = unescape(pair.get_string(2) if pair.get_start(2) >= 0 else pair.get_string(3))
		if stack.is_empty():
			if not root.is_empty():
				return {}
			root = node
		else:
			((stack.back() as Dictionary)["kids"] as Array).append(node)
		if found.get_string(4) != "/":
			stack.append(node)
	return root if stack.is_empty() else {}


static func log_lines(text: String) -> Array:
	var out: Array = []
	for found: RegExMatch in RegEx.create_from_string("<l>([^<]*)</l>").search_all(text):
		out.append(unescape(found.get_string(1)))
	return out

func _take(text: String) -> void :
	var root: Dictionary = tree_xml(text)
	if root.is_empty() or str(root["tag"]) != "ctp":
		return
	var a: Dictionary = root["at"]
	if str(a.get("visible", "0")) != "1":
		tp_visible = false
		if opened:
			close("Cờ Tỷ Phú đang tạm đóng.")
		_clear_game()
		q_key = ""
		return
	tp_visible = true
	token = str(a.get("k", token))
	var st: Array = []
	for part: String in str(a.get("stakes", "")).split(",", false):
		st.append(part.to_int())
	if not st.is_empty():
		stakes = st
	if not stakes.has(stake_pick):
		stake_pick = int(stakes[0])
	var sz: Array = []
	for part: String in str(a.get("sizes", "")).split(",", false):
		sz.append(part.to_int())
	if not sz.is_empty():
		sizes = sz
	bal = str(a.get("bal", "")).to_int() if not str(a.get("bal", "")).is_empty() else -1
	var key: String = str(a.get("q", ""))
	if key != q_key:
		q_since = now_ms() - float(str(a.get("qat", "0")).to_int()) * 1000.0
	q_key = key
	q_n = str(a.get("qn", "0")).to_int()
	q_step = maxi(1, str(a.get("qstep", "30")).to_int())
	counts = {}
	var groups: PackedStringArray = str(a.get("counts", "")).split(",")
	for k in range(mini(groups.size(), stakes.size())):
		var per: PackedStringArray = groups[k].split("/")
		var keys: Array = sizes.duplicate()
		keys.append(0)
		for j in range(mini(per.size(), keys.size())):
			counts["%d:%d" % [int(stakes[k]), int(keys[j])]] = per[j].to_int()
	turn_s = maxi(1, str(a.get("turn", "20")).to_int())
	game_min = maxi(1, str(a.get("min", "15")).to_int())
	max_rounds = maxi(1, str(a.get("rounds", "30")).to_int())
	starting = str(a.get("starting", "0")) == "1"
	var gid: String = str(a.get("g", ""))
	var notice: String = str(a.get("notice", ""))
	if not notice.is_empty():
		_tip(notice)
	var node: Dictionary = {}
	for kid: Dictionary in root["kids"]:
		if str(kid["tag"]) == "game":
			node = kid
	if not node.is_empty():
		_take_game(node, log_lines(text))
	elif gid.is_empty() and playing() and str(_what.get("l", "")) != "":

		_clear_game()
	if gid != active_gid and not gid.is_empty() and game.is_empty() and not opened and in_lobby:
		_tip("Cờ Tỷ Phú: đã ghép đủ người, đang vào bàn!")
	active_gid = gid

func _take_game(node: Dictionary, lg: Array) -> void :
	var a: Dictionary = node["at"]
	var fresh: bool = game.is_empty() or str(game.get("id", "")) != str(a.get("id", ""))
	if not fresh and int(a.get("v", "0").to_int()) < int(game.get("v", 0)):
		return
	var g: Dictionary = {}
	for k: String in a:
		g[k] = a[k]
	g["v"] = str(a.get("v", "0")).to_int()
	g["me"] = str(a.get("me", "-1")).to_int()
	g["turn"] = str(a.get("turn", "0")).to_int()
	g["dl_at"] = now_ms()
	var ps: Array = []
	var tiles: Dictionary = {}
	var evs: Array = []
	var says: Array = []
	for kid: Dictionary in node["kids"]:
		var t: String = str(kid["tag"])
		if t == "p":
			ps.append(kid["at"])
		elif t == "t":
			tiles[str(kid["at"].get("c", "0")).to_int()] = kid["at"]
		elif t == "e":
			evs.append(kid["at"])
		elif t == "s":
			says.append(kid["at"])
	g["players"] = ps
	g["tiles"] = tiles
	var was_over: bool = not game.is_empty() and str(game.get("over", "0")) == "1"
	var was_out: bool = _me_out()
	if fresh:
		_clear_game()
		var top: int = 0
		for e: Dictionary in evs:
			top = maxi(top, str(e.get("n", "0")).to_int())
		seen_n = top if int(g["v"]) > 3 else 0
		for p: Dictionary in ps:
			shown.append(0.0 if seen_n == 0 else float(str(p.get("pos", "0")).to_int()))
			paths.append([])
			hops.append([])
		for s: Dictionary in says:
			talk_seen = maxi(talk_seen, str(s.get("n", "0")).to_int())
		if int(g["v"]) <= 3 and str(g.get("over", "0")) != "1":
			order_at = now_ms()
			_order0 = str(a.get("turn", "0")).to_int()
		if not opened and in_lobby and str(g.get("over", "0")) != "1":
			_tip("Cờ Tỷ Phú: ván đã bắt đầu, bấm nút Cờ Tỷ Phú để vào bàn.")
	_old_tiles = game.get("tiles", {}) if not fresh else {}
	game = g
	lines = lg
	while shown.size() < ps.size():
		shown.append(0.0)
		paths.append([])
	while hops.size() < ps.size():
		hops.append([])
	for i in range(ps.size()):
		if not cash_shown.has(i):
			cash_shown[i] = float(str(ps[i].get("cash", "0")).to_int())
	if fresh:
		_warned_min = game_left_ms() <= 60000.0
	_take_talk(says)
	for e: Dictionary in evs:
		var n: int = str(e.get("n", "0")).to_int()
		if n > seen_n:
			seen_n = n
			_evq8.append(e)
	_drain8()

	for i in range(ps.size() if _evq8.is_empty() else 0):
		var pos: int = str(ps[i].get("pos", "0")).to_int()
		if (paths[i] as Array).is_empty() and (hops[i] as Array).is_empty() and roundi(float(shown[i])) % N != pos:
			shown[i] = float(pos)
	if not _warned_min and str(g.get("over", "0")) != "1" and not fresh and game_left_ms() <= 60000.0 and game_left_ms() > 0.0:
		_warned_min = true
		fx.append({"k": "warn", "text": "Còn 1 phút — ai nhiều tài sản nhất sẽ thắng!", "at": now_ms()})
	if str(g.get("phase", "")) != "roll":
		parity = ""
	if _me_out() and not was_out and not fresh:
		_say_big("Phá sản — mất gói %s Bạc" % num(_stake()), true)
	if str(g.get("over", "0")) == "1" and not was_over:
		confirm = ""
		if not opened:
			_tip("Cờ Tỷ Phú: " + _result_text())
	if opened and str(g.get("over", "0")) != "1":
		var me: Dictionary = _me()
		if not me.is_empty() and str(me.get("away", "0")) == "1" and away_at <= 0.0 and not _me_out():
			_act("back")


func _event(e: Dictionary) -> void :
	var k: String = str(e.get("k", ""))
	var i: int = str(e.get("i", "-1")).to_int()
	var n: int = str(e.get("n", "0")).to_int()
	var now: float = now_ms()
	if k == "dice":
		dice_at = now
		dice_from = i
		dice_z = str(e.get("z", "-1")).to_int() if e.has("z") else -1
		roll_wait = -100000.0
	elif k == "move" and i >= 0 and i < paths.size():
		var from: int = str(e.get("from", "0")).to_int()
		var to: int = str(e.get("to", "0")).to_int()
		var path: Array = paths[i]
		if str(e.get("jump", "")) == "1" or str(e.get("back", "")) == "1":
			path.append(-1 - to)
		else:
			var c: int = from
			var guard: int = 0
			while c != to and guard < N:
				c = (c + 1) % N
				path.append(c)
				guard += 1
				if c == 0:
					_go_wait[i] = true
	elif k == "cash" and i >= 0:
		var d: int = str(e.get("d", "0")).to_int()
		cash_dir[i] = [signi(d), now]
		var paired: bool = false
		if d < 0:
			_last_neg = {"n": n, "i": i, "d": d}
		elif d > 0 and not _last_neg.is_empty() and int(_last_neg["n"]) == n - 1 and int(_last_neg["d"]) == - d and int(_last_neg["i"]) != i:

			fx.append({"k": "pay", "a": int(_last_neg["i"]), "b": i, "d": d, "at": now})

			fx.append({"k": "rent", "i": int(_last_neg["i"]), "d": - d, "at": now})
			fx.append({"k": "rent", "i": i, "d": d, "at": now + 180.0})
			shake_at[int(_last_neg["i"])] = now
			paired = true
		elif d > 0 and _go_wait.get(i, false):
			_go_wait.erase(i)
			_go_amt[i] = d
		if not paired:
			floats.append({"i": i, "d": d, "at": now})
	elif k == "buy" or k == "build" or k == "fest" or k == "sell":
		var c: int = str(e.get("c", "0")).to_int()
		flash_tile[c] = now
		if k == "buy":
			fx.append({"k": "price", "c": c, "d": - _price8(c), "at": now})
			fx.append({"k": "cert", "c": c, "i": i, "at": now + 150.0})
			flag_at[c] = now
			_cam_to(c)
			_check_set(c, i)
		elif k == "build":
			var h: int = str(game.get("tiles", {}).get(c, {}).get("h", "1")).to_int()
			fx.append({"k": "price", "c": c, "d": - str(game.get("hc", "0")).to_int(), "at": now})
			grow_at[c] = now
			if h >= 3:
				fx.append({"k": "rays", "c": c, "at": now})
			_cam_to(c)
		elif k == "fest":
			fx.append({"k": "rain", "text": "LỄ HỘI — %s thuê ×2!" % str(BOARD[c][0]), "at": now})
			_fest8[c] = now
			_cam_to(c)
		else:
			var old: Dictionary = _old_tiles.get(c, {})
			if not old.is_empty() and str(old.get("h", "0")).to_int() > 0:
				fx.append({"k": "ghost", "c": c, "h": str(old.get("h", "0")).to_int(), "o": str(old.get("o", "0")).to_int(), "at": now})
	elif k == "take":

		var c: int = str(e.get("c", "0")).to_int()
		flash_tile[c] = now
		fx.append({"k": "price", "c": c, "d": - str(e.get("d", "0")).to_int(), "at": now})
		fx.append({"k": "cert", "c": c, "i": i, "p": str(e.get("d", "0")).to_int(), "at": now + 150.0})
		flag_at[c] = now
		_cam_to(c)
		_check_set(c, i)
		_say_big("%s mua lại %s của %s" % [_pname(i), str(BOARD[c][0]), _pname(str(e.get("o", "-1")).to_int())], false)
	elif k == "card" or k == "luck":
		_card8(e, i, now)
	elif k == "bankrupt":
		out_at[i] = now
		shake_at[i] = now
		for c: int in _old_tiles:
			var old: Dictionary = _old_tiles[c]
			if str(old.get("o", "-1")).to_int() == i and str(old.get("h", "0")).to_int() > 0:
				fx.append({"k": "ghost", "c": c, "h": str(old.get("h", "0")).to_int(), "o": i, "at": now})
		if i == int(game.get("me", -1)):
			_say_big("Phá sản — mất gói %s Bạc" % num(str(e.get("lost", "0")).to_int()), true)
		else:
			_say_big("%s phá sản!" % _pname(i), true)
	elif k == "over":
		over_at = now
		pot_at = now


func _cam_to(c: int) -> void :
	cam_cell = c
	cam_at = now_ms()


func _check_set(c: int, i: int) -> void :
	var grp: int = int(BOARD[c][2])
	if grp < 0:
		return
	var mine: int = 0
	var all: int = 0
	var gap: int = -1
	for cell in range(N):
		if str(BOARD[cell][1]) != "land" or int(BOARD[cell][2]) != grp:
			continue
		all += 1
		if _owner(cell) == i:
			mine += 1
		elif _owner(cell) < 0:
			gap = cell
	if mine == all:
		fx.append({"k": "rain", "text": "%s đủ bộ màu — thuê tăng!" % _pname(i), "at": now_ms() + 900.0})
	elif mine == all - 1 and gap >= 0:
		fx.append({"k": "warn", "text": "%s chỉ thiếu %s là đủ bộ màu!" % [_pname(i), str(BOARD[gap][0])], "at": now_ms() + 900.0})

func _say_big(text: String, bad: bool) -> void :
	banner = text
	banner_at = now_ms()
	banner_bad = bad




func _take_talk(says: Array) -> void :
	var now: float = now_ms()
	for s: Dictionary in says:
		var n: int = str(s.get("n", "0")).to_int()
		if n <= talk_seen:
			continue
		talk_seen = n
		var k: String = str(s.get("k", ""))
		if k != "emo" and k != "say":
			continue
		talk.append({"n": n, "i": str(s.get("i", "-1")).to_int(), "k": k, "v": str(s.get("v", "")), "at": now})
	while talk.size() > 30:
		talk.pop_front()


func _emo_store() -> void :
	if _emotes == null:
		_emotes = Emotes.new()
		_emotes.client = client
		add_child(_emotes)
	_emotes.refresh()

func _emo_tex(item: String) -> Texture2D:
	return _emotes.texture("%s:%s" % [EMO_PACK, item]) if _emotes != null else null


func emo_items() -> Array:
	var out: Array = []
	for item: String in EMO_PICK:
		if _emotes == null or not _emotes.loaded or _emotes.known(EMO_PACK, item):
			out.append(item)
	return out

func can_talk() -> bool:
	return playing() and int(game.get("me", -1)) >= 0

func _send_emo(item: String) -> void :
	var now: float = now_ms()
	if now - emo_at < TALK_GAP:
		say("Chậm lại chút: 2 giây một lần.")
		return
	emo_at = now
	talk_pane = ""
	_act("emo", "&e=" + item.uri_encode())


func _send_say(text: String) -> void :
	var clean: String = " ".join(text.strip_edges().split(" ", false)).left(SAY_MAX)
	if clean.is_empty():
		return
	var now: float = now_ms()
	if now - say_at < TALK_GAP:
		say("Chậm lại chút: 2 giây một lần.")
		return
	say_at = now
	_act("say", "&s=" + clean.uri_encode())
	if _say_edit != null:
		_say_edit.text = ""
		_say_edit.release_focus()
	talk_pane = ""

func _chat_edit() -> LineEdit:
	if _say_edit == null:
		_say_edit = _edit("Nhắn trong ván…", SAY_MAX)
		_say_edit.text_submitted.connect( func(text: String) -> void :
			_send_say(text)
			queue_redraw())
	return _say_edit

func _open_chat() -> void :
	talk_pane = "chat"
	var edit: LineEdit = _chat_edit()
	edit.call_deferred("grab_focus")

func _close_talk() -> void :
	talk_pane = ""
	if _say_edit != null:
		_say_edit.release_focus()
		_say_edit.visible = false


func _bubble_of(i: int) -> Dictionary:
	var now: float = now_ms()
	if hide_talk and i != int(game.get("me", -1)):
		return {}
	for k in range(talk.size() - 1, -1, -1):
		var t: Dictionary = talk[k]
		if int(t["i"]) != i:
			continue
		var life: float = 2000.0 if str(t["k"]) == "emo" else 3000.0
		return t if now - float(t["at"]) < life else {}
	return {}



func _players() -> Array:
	return game.get("players", [])

func _me() -> Dictionary:
	var me: int = int(game.get("me", -1))
	var ps: Array = _players()
	return ps[me] if me >= 0 and me < ps.size() else {}

func _me_out() -> bool:
	return str(_me().get("out", "0")) == "1"

func _pname(i: int) -> String:
	var ps: Array = _players()
	if i == int(game.get("me", -1)):
		return "Bạn"
	return str(ps[i].get("name", "?")) if i >= 0 and i < ps.size() else "?"

func _stake() -> int:
	return str(game.get("stake", "0")).to_int()

func my_turn() -> bool:
	return playing() and int(game.get("turn", -1)) == int(game.get("me", -2)) and not _me_out()

func _phase() -> String:
	return str(game.get("phase", ""))

func turn_left_ms() -> float:
	return maxf(0.0, str(game.get("dl", "0")).to_float() * 1000.0 - (now_ms() - float(game.get("dl_at", now_ms()))))

func game_left_ms() -> float:
	return maxf(0.0, str(game.get("left", "0")).to_float() * 1000.0 - (now_ms() - float(game.get("dl_at", now_ms()))))

func _rank_of(i: int) -> int:
	var ps: Array = _players()
	var p: Dictionary = ps[i]
	if str(p.get("rank", "0")).to_int() > 0:
		return str(p.get("rank", "0")).to_int()
	var mine: int = str(p.get("asset", "0")).to_int()
	var r: int = 1
	for q: Dictionary in ps:
		if q != p and str(q.get("out", "0")) != "1" and (str(p.get("out", "0")) == "1" or str(q.get("asset", "0")).to_int() > mine):
			r += 1
	return r

func _result_text() -> String:
	var me: Dictionary = _me()
	var stake: int = _stake()
	if me.is_empty():
		return "Ván đã kết thúc."
	if str(me.get("win", "0")) == "1":
		var share: int = str(game.get("share", "0")).to_int()
		var wins: int = 0
		for p: Dictionary in _players():
			if str(p.get("win", "0")) == "1":
				wins += 1
		return ("Hoà — nhận %s Bạc qua thư" if wins > 1 else "Thắng! Nhận %s Bạc qua thư") % num(share)
	if str(me.get("out", "0")) == "1":
		return "Phá sản — mất gói %s Bạc" % num(stake)
	return "Thua — mất gói %s Bạc" % num(stake)

static func short_bac(v: int) -> String:
	if v >= 1000000 and v % 100000 == 0:
		return (str(v / 1000000) if v % 1000000 == 0 else String.num(v / 1000000.0, 1).replace(".", ",")) + "M"
	if v >= 1000 and v % 1000 == 0:
		return str(v / 1000) + "K"
	return num(v)



func _activate(id: String) -> void :
	if rules_click(id):
		return
	if id == "card8" or id == "roll":
		_close8()
		if id == "card8":
			return
	if id == "close":
		request_close()
		return
	if id.begins_with("stake:"):
		stake_pick = id.substr(6).to_int()
		return
	if id.begins_with("room:"):
		var seats: int = id.substr(5).to_int()
		if bal >= 0 and bal < stake_pick:
			say("Không đủ Bạc: cần %s Bạc." % num(stake_pick))
			return
		_act("queue", "&stake=%d&size=%d" % [stake_pick, seats])
		q_key = "%d:%d" % [stake_pick, seats]
		q_since = now_ms()
		return
	if id == "unqueue":
		_act("unqueue")
		q_key = ""
		return
	if id == "home":
		_dismiss()
		return
	if id == "leave_ask":
		if _me_out():
			_dismiss()
		else:
			confirm = "leave"
		return
	if id == "stay":
		confirm = ""
		return
	if id == "leave_yes":
		confirm = ""
		_act("leave")
		active_gid = ""
		_clear_game()
		say("Đã rời bàn — mất gói.")
		return
	if id == "emo_open":
		talk_pane = "" if talk_pane == "emo" else "emo"
		if talk_pane == "emo":
			_close_talk()
			talk_pane = "emo"
			_emo_store()
		return
	if id == "chat_open":
		if talk_pane == "chat":
			_close_talk()
		else:
			_open_chat()
		return
	if id == "talk_hide":
		hide_talk = not hide_talk
		say("Đã ẩn biểu cảm / tin của người khác." if hide_talk else "Đã hiện lại biểu cảm / tin của người khác.")
		return
	if id == "talk_log":
		log_open = not log_open
		return
	if id.begins_with("emo:"):
		_send_emo(id.substr(4))
		return
	if id.begins_with("quick:"):
		var q: int = id.substr(6).to_int()
		if q >= 0 and q < QUICK.size():
			_send_say(str(QUICK[q]))
		return
	if id == "say_send":
		if _say_edit != null:
			_send_say(_say_edit.text)
		return
	if not my_turn():
		if id.begins_with("t:"):
			_pick(id.substr(2).to_int())
		return
	var ph: String = _phase()
	if id == "odd" or id == "even":
		parity = "" if parity == id else id
	elif id == "roll":

		var start: float = space_at if space_at >= 0.0 else hold_at
		var held: float = now_ms() - start if start >= 0.0 else 0.0
		hold_at = -1.0
		space_at = -1.0
		var z: int = zone_of(held) if held >= HOLD_MS else -1
		var extra: String = "&p=" + parity if not parity.is_empty() else ""
		if z >= 0:
			extra += "&z=%d" % z
			zone_hit = z
			zone_at = now_ms()
		_act("roll", extra)
		parity = ""
		roll_wait = now_ms()
	elif id == "bail":
		_act("bail")
	elif id == "buy" or id == "build" or id == "skip" or id == "take":
		_act(id)
	elif id.begins_with("t:"):
		var c: int = id.substr(2).to_int()
		if ph == "bus" and c != BUS:
			_act("go", "&c=%d" % c)
		elif ph == "fest" and _owner(c) == int(game.get("me", -1)):
			_act("fest", "&c=%d" % c)
		else:
			_pick(c)


static func needle(held: float) -> float:
	var p: float = fmod(maxf(0.0, held), 2.0 * NEEDLE_MS) / NEEDLE_MS
	return p if p <= 1.0 else 2.0 - p

static func zone_of(held: float) -> int:
	return mini(3, int(needle(held) * 4.0))

func _pick(c: int) -> void :
	pick_tile = c
	pick_at = now_ms()

func _owner(c: int) -> int:
	var t: Dictionary = game.get("tiles", {}).get(c, {})
	return str(t.get("o", "-1")).to_int() if not t.is_empty() else -1

func _input(event: InputEvent) -> void :
	if not opened or not (event is InputEventKey):
		return
	var key: InputEventKey = event
	var code: int = key.keycode if key.keycode != KEY_NONE else key.physical_keycode
	if typing():

		if key.pressed and code == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_close_talk()
			queue_redraw()
		return
	if code == KEY_SPACE and not key.pressed and space_at >= 0.0:
		get_viewport().set_input_as_handled()
		if my_turn() and (_phase() == "roll" or _phase() == "bus") and confirm.is_empty():
			_activate("roll")
		space_at = -1.0
		return
	if not key.pressed or key.echo:
		return
	if code == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		if rules_on:
			rules_on = false
		elif talk_pane != "":
			_close_talk()
		elif confirm != "":
			confirm = ""
		else:
			request_close()
		queue_redraw()
	elif (code == KEY_ENTER or code == KEY_KP_ENTER) and can_talk() and confirm.is_empty() and not rules_on:
		get_viewport().set_input_as_handled()
		_open_chat()
		queue_redraw()
	elif my_turn() and code == KEY_SPACE and (_phase() == "roll" or _phase() == "bus") and confirm.is_empty():
		get_viewport().set_input_as_handled()
		space_at = now_ms()




func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		hold_at = now_ms() if _hit_at(event.position) == "roll" else -1.0
	super (event)

func _anim() -> void :
	_drain8()
	var now: float = now_ms()

	for i in range(paths.size()):
		while hops.size() <= i:
			hops.append([])
		for _step in range(6):
			var hop: Array = hops[i]
			var start: float = now
			if not hop.is_empty():
				var dur: float = JUMP_MS if bool(hop[3]) else WALK_MS
				if now - float(hop[2]) < dur:
					break
				_land(i, int(hop[1]), now)
				hops[i] = []
				start = maxf(float(hop[2]) + dur, now - 40.0)
			var path: Array = paths[i]
			if path.is_empty():
				break
			if i == dice_from and now - dice_at < DICE_MS:
				break
			var nxt: int = int(path.pop_front())
			var jump: bool = nxt < 0
			hops[i] = [posmod(roundi(float(shown[i])), N), -1 - nxt if jump else nxt, start, jump]

	var ps: Array = _players()
	for i in range(ps.size() if _evq8.is_empty() else 0):
		var target: float = float(str(ps[i].get("cash", "0")).to_int())
		var cur: float = float(cash_shown.get(i, target))
		cash_shown[i] = target if absf(target - cur) < 1.0 else cur + (target - cur) * 0.2
	var keep: Array = []
	for f: Dictionary in floats:
		if now - float(f["at"]) < 1600.0:
			keep.append(f)
	floats = keep
	var live: Array = []
	for e: Dictionary in fx:
		if now - float(e["at"]) < float(FX_LIFE.get(str(e["k"]), 1500.0)):
			live.append(e)
	fx = live
	for c: int in sink.keys():
		if now - float(sink[c]) > 400.0:
			sink.erase(c)


func _land(i: int, to: int, now: float) -> void :
	shown[i] = float(to)
	sink[to] = now
	rest_at[i] = now
	if to == 0 and _go_amt.has(i):
		fx.append({"k": "go", "c": 0, "d": int(_go_amt[i]), "i": i, "at": now})
		_go_amt.erase(i)



func _R(x: float, y: float, w: float, h: float) -> Rect2:
	return Rect2((frame_at() + Vector2(x, y)) * _f, Vector2(w, h) * _f)

func _P(v: Vector2) -> Vector2:
	return (frame_at() + v) * _f


func _w(text: String, px: float, color: Color, align: String, x: float, cy: float, w: float, font: Font = SEMI) -> float:
	return _string(text, font, px * 2.0, color, align, _P(Vector2(x, cy)), w * _f) / _f



func _lip(rect: Rect2, a: float, rad: float = 12.0) -> void :
	var inset: float = minf(rad * _u, rect.size.x * 0.3)
	draw_line(rect.position + Vector2(inset, 1.6 * _f), Vector2(rect.end.x - inset, rect.position.y + 1.6 * _f), Color(1, 1, 1, a), maxf(1.0, 1.4 * _f), true)

func _btn(id: String, text: String, r: Rect2, enabled: bool = true, px: float = 14.0, style: String = "") -> void :
	var rect: Rect2 = _R(r.position.x, r.position.y, r.size.x, r.size.y)
	var lit: bool = enabled and _hover == id and _press.is_empty()
	var down: bool = enabled and _press == id
	var ink: Color = ON_BLUE
	if not down:
		_round(Rect2(rect.position + Vector2(0, 3.0 * _f), rect.size), Color(0, 0, 0, 0.34), 12.0)
	if style == "talk" and enabled:
		_grad(rect, Color("3d82cc") if lit else Color("2f6db3"), Color("143b74"), Color("9fd2ff", 0.55), 12.0, 1.5)
		ink = CREAM
	elif style == "orange" and enabled:
		_grad(rect, GOLD_TOP.lightened(0.12) if lit else GOLD_TOP, GOLD_LOW, BTN_GOLD_EDGE, 12.0, 2.0)
		ink = ON_GOLD
	elif style == "gray" or not enabled:
		_grad(rect, Color("5d6878") if lit else Color("4e5868"), Color("343c4a"), Color(CREAM, 0.3), 12.0, 2.0)
		ink = Color(CREAM, 0.9 if enabled else 0.45)
	else:
		_grad(rect, BTN_TOP.lightened(0.12) if lit else BTN_TOP, BTN_LOW, Color(BTN_EDGE, 0.9), 12.0, 2.0)
	if down:
		draw_rect(rect.grow(-2.0 * _u), Color(0, 0, 0, 0.18))
	else:
		_lip(rect, 0.4 if enabled else 0.15)
	_string(text, BOLD, px * 2.0, ink, "c", rect.get_center(), rect.size.x - 6.0 * _f)
	if enabled:
		_hit(id, rect, false)

func _paint() -> void :
	if not opened:
		return
	win_size = _table_size() if not game.is_empty() else NORMAL
	if _press != "roll":
		hold_at = -1.0
	if _say_edit != null and _say_edit.visible and (talk_pane != "chat" or not can_talk() or confirm != "" or str(game.get("over", "0")) == "1"):
		_say_edit.visible = false
		_say_edit.release_focus()
	_tips.clear()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = frame_at()
	_hit("panel", Rect2(at * _f, win_size * _f), false)
	_body(at)
	if rules_on:
		_rules_panel(at)

func _body(at: Vector2) -> void :
	if not game.is_empty():
		_table_frame(at)
		_table()
		return
	var w: float = win_size.x
	var h: float = win_size.y
	var frame: Rect2 = _R(0, 0, w, h)
	_round(frame, Color("0b1730"), 16.0, Color(GOLD, 0.55), 2.0)

	for k in range(6):
		var t: float = float(k) / 6.0
		draw_circle(_P(Vector2(480, 318)), (420.0 - 60.0 * k) * _f, Color(0.06 + 0.02 * t, 0.16 + 0.05 * t, 0.3 + 0.06 * t, 0.22), true, -1.0, true)
	_round(_R(0, 0, w, HEAD), Color("08224a", 0.96), 16.0)
	draw_rect(_R(0, HEAD - 14.0, w, 14.0), Color("08224a", 0.96))
	draw_line(_P(Vector2(0, HEAD)), _P(Vector2(w, HEAD)), Color(GOLD, 0.5), maxf(1.0, _f))
	_w("CỜ TỶ PHÚ", 17.0, GOLD, "l", 20, HEAD / 2.0, 200, BOLD)
	_close_btn(Vector2(w - 26.0, HEAD / 2.0))
	rules_button(at + Vector2(w - 62.0, HEAD / 2.0), 13.0)
	_home()

func _close_btn(c: Vector2) -> void :
	var lit: bool = _hover == "close" and _press.is_empty()
	draw_circle(_P(c), 19.0 * _f, Color("7a1a12"), true, -1.0, true)
	draw_circle(_P(c), 16.5 * _f, Color("e0503c") if lit else Color("c43a2a"), true, -1.0, true)
	var d: float = 6.5
	draw_line(_P(c + Vector2( - d, - d)), _P(c + Vector2(d, d)), Color.WHITE, 3.0 * _f, true)
	draw_line(_P(c + Vector2(d, - d)), _P(c + Vector2( - d, d)), Color.WHITE, 3.0 * _f, true)
	_hit("close", _R(c.x - 22.0, c.y - 22.0, 44, 44), false)



func _home() -> void :
	var x0: float = 28.0
	var waiting: bool = not q_key.is_empty()
	_w("Bạc của bạn:", 13.0, MUTED, "l", 240, HEAD / 2.0, 120)
	_w(num(bal) if bal >= 0 else "—", 15.0, CREAM, "l", 330, HEAD / 2.0, 200, BOLD)
	_w("1. Chọn gói", 15.0, GOLD, "l", x0, 66, 300, BOLD)
	for k in range(stakes.size()):
		var st: int = int(stakes[k])
		var r: Rect2 = Rect2(x0 + k * 214.0, 82, 200, 58)
		var poor: bool = bal >= 0 and bal < st
		_btn("stake:%d" % st, "%s Bạc" % num(st), r, not waiting, 16.0, "orange" if st == stake_pick else "")
		_w("Không đủ Bạc" if poor else "Thắng nhận cả hũ", 11.0, RED if poor else Color(CREAM, 0.7), "c", r.get_center().x, r.end.y + 11.0, 200)
	_w("2. Chọn phòng (chỉ ghép người cùng gói)", 15.0, GOLD, "l", x0, 178, 420, BOLD)
	var rooms: Array = sizes.duplicate()
	rooms.append(0)
	for k in range(rooms.size()):
		var sz: int = int(rooms[k])
		var r: Rect2 = Rect2(x0 + (k % 2) * 214.0, 194.0 + floorf(k / 2.0) * 82.0, 200, 60)
		var key: String = "%d:%d" % [stake_pick, sz]
		var mine: bool = q_key == key
		var label: String = "Ghép nhanh" if sz == 0 else "Phòng %d người" % sz
		_btn("room:%d" % sz, label, r, not waiting and not starting, 16.0, "orange" if mine else "")
		var n: int = int(counts.get(key, 0))
		_w("Đang chờ: %d" % n if sz != 0 else "4 người, chờ lâu nhận 3 rồi 2", 11.0, Color(CREAM, 0.7), "c", r.get_center().x, r.end.y + 10.0, 210)
	var box: Rect2 = Rect2(x0, 372, 414, 118)
	_round(_R(box.position.x, box.position.y, box.size.x, box.size.y), Color("0e2a52", 0.9), 12.0, Color(GLASS_EDGE, 0.5), 1.5)
	var cx: float = box.get_center().x
	if starting or ( not active_gid.is_empty() and game.is_empty()):
		_spinner(Vector2(cx, box.position.y + 34.0))
		_w("Đã đủ người — đang trừ gói và xếp bàn…", 14.0, CREAM, "c", cx, box.position.y + 72.0, 400)
	elif waiting:
		var parts: PackedStringArray = q_key.split(":")
		var st: int = parts[0].to_int()
		var sz: int = parts[1].to_int() if parts.size() > 1 else 0
		var secs: int = int((now_ms() - q_since) / 1000.0)
		_spinner(Vector2(box.position.x + 34.0, box.position.y + 34.0))
		_w("Đang ghép %s · gói %s Bạc" % ["nhanh" if sz == 0 else "phòng %d người" % sz, num(st)], 14.0, CREAM, "l", box.position.x + 62.0, box.position.y + 24.0, 340, BOLD)
		var need: String = ""
		if sz == 0:
			var top: int = 4
			var want: int = clampi(top - secs / q_step, 2, top)
			need = "Đang tìm %d người · %d giây nữa nhận %d người" % [want, maxi(0, q_step * (top - want + 1) - secs), want - 1] if want > 2 else "Đang tìm 2 người trở lên"
		else:
			need = "Đã có %d/%d người" % [mini(q_n, sz), sz]
		_w("%s · đã chờ %d:%02d" % [need, secs / 60, secs % 60], 12.0, Color(CREAM, 0.75), "l", box.position.x + 62.0, box.position.y + 46.0, 345)
		_w("Chưa trừ Bạc — Hủy ghép không mất gì.", 12.0, GREEN, "l", box.position.x + 62.0, box.position.y + 66.0, 340)
		_btn("unqueue", "Hủy ghép", Rect2(cx - 70.0, box.end.y - 38.0, 140, 30), true, 13.0, "gray")
	else:
		_w("Chọn gói rồi chọn phòng để vào hàng chờ.", 14.0, CREAM, "c", cx, box.position.y + 30.0, 400)
		_w("Gói chỉ bị trừ khi ván bắt đầu.", 12.0, Color(CREAM, 0.75), "c", cx, box.position.y + 56.0, 400)
		_w("Mỗi lượt %d giây · ván tối đa %d phút / %d lượt." % [turn_s, game_min, max_rounds], 12.0, Color(CREAM, 0.75), "c", cx, box.position.y + 80.0, 400)
	_w("Thoát giữa ván hoặc phá sản: mất gói. Thắng: nhận cả hũ qua thư.", 12.0, Color(GOLD, 0.85), "c", cx, 520, 420)

	var keep: Dictionary = game
	bc = Vector2(700, 292)
	bb = 112.0
	ba = 212.0
	bk = 0.6
	_board(true)
	game = keep
	_w("Bàn 32 ô · 2–4 người", 13.0, Color(CREAM, 0.8), "c", 700, 448, 300)
	_w("Mua đất, xây nhà, thu tiền thuê. Hết giờ: ai nhiều tài sản nhất thắng.", 12.0, Color(CREAM, 0.65), "c", 700, 470, 420)

func _spinner(c: Vector2) -> void :
	var a: float = fmod(now_ms() / 1000.0 * TAU, TAU)
	draw_arc(_P(c), 14.0 * _f, a, a + PI * 1.4, 24, GOLD, 3.0 * _f, true)





func frame_at() -> Vector2:
	if game.is_empty():
		return super ()
	return Vector2(roundf((floorf(_fw + 0.01) - win_size.x) / 2.0), roundf((floorf(_fh + 0.01) - win_size.y) / 2.0))


func _table_size() -> Vector2:
	var m: float = 0.0 if _mobile else 8.0
	return Vector2(floorf(minf(TABLE.x, _fw - 2.0 * m)), floorf(minf(TABLE.y, _fh - 2.0 * m)))


func _fit_board(area: Rect2) -> void :
	var thick: float = 22.0
	bb = maxf(60.0, (area.size.y * 0.91 - thick) / 2.0)
	ba = minf(bb * 1.9, area.size.x / 2.0 - 8.0)
	bb = minf(bb, ba / 1.6)
	bc = area.get_center() - Vector2(0, thick / 2.0)
	bk = clampf(bb / 258.0, 0.8, 1.3)

func bp(u: float, v: float) -> Vector2:
	return bc + Vector2((u - v) * ba, (u + v - 1.0) * bb)


static func cell_uv(cell: int) -> Rect2:
	var s: int = cell / 8
	var j: int = cell % 8
	var lo: float = 1.0 - CS
	if j == 0:
		match s:
			0:
				return Rect2(lo, lo, CS, CS)
			1:
				return Rect2(0, lo, CS, CS)
			2:
				return Rect2(0, 0, CS, CS)
		return Rect2(lo, 0, CS, CS)
	match s:
		0:
			return Rect2(lo - j * TW, lo, TW, CS)
		1:
			return Rect2(0, lo - j * TW, CS, TW)
		2:
			return Rect2(CS + (j - 1) * TW, 0, TW, CS)
	return Rect2(lo, CS + (j - 1) * TW, CS, TW)


static func tile_uv(cell: int, a: float, r: float) -> Vector2:
	var q: Rect2 = cell_uv(cell)
	match cell / 8:
		0:
			return Vector2(q.position.x + a * TW, 1.0 - CS + r * CS)
		1:
			return Vector2(CS - r * CS, q.position.y + (1.0 - a) * TW)
		2:
			return Vector2(q.position.x + a * TW, CS - r * CS)
	return Vector2(1.0 - CS + r * CS, q.position.y + (1.0 - a) * TW)

func tile_at(cell: int, a: float, r: float) -> Vector2:
	var p: Vector2 = tile_uv(cell, a, r)
	return bp(p.x, p.y)

func tile_mid(cell: int) -> Vector2:
	var m: Vector2 = cell_uv(cell).get_center()
	return bp(m.x, m.y)


func tile_poly(cell: int) -> PackedVector2Array:
	var q: Rect2 = cell_uv(cell).grow(-0.0045)
	return PackedVector2Array([bp(q.position.x, q.position.y), bp(q.end.x, q.position.y), bp(q.end.x, q.end.y), bp(q.position.x, q.end.y)])

func _poly_px(poly: PackedVector2Array, shift: Vector2 = Vector2.ZERO) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in poly:
		out.append(_P(p + shift))
	return out

static func tile_fill(cell: int) -> Color:
	var t: Array = BOARD[cell]
	match str(t[1]):
		"land":
			return Color(str(GROUP_COL[int(t[2])])).lightened(0.18)
		"start":
			return Color("4cbf68")
		"jail":
			return Color("5cc8c0")
		"fest":
			return Color("ffc94a")
		"bus":
			return Color("7cc4f5")
		"tax":
			return Color("cfe6c4")
	return Color("eaf3ff")



func _block(top: PackedVector2Array, fill: Color, thick: float, cell: int = -1) -> void :
	var d: Vector2 = Vector2(0, thick)
	var left: PackedVector2Array = _poly_px(PackedVector2Array([top[3], top[2], top[2] + d, top[3] + d]))
	var right: PackedVector2Array = _poly_px(PackedVector2Array([top[2], top[1], top[1] + d, top[2] + d]))
	var side: Texture2D = TpArt.tex("side")
	if side != null:
		draw_colored_polygon(left, fill.darkened(0.22), _uv4, side)
		draw_colored_polygon(right, fill.darkened(0.42), _uv4, side)
	else:
		draw_colored_polygon(left, fill.darkened(0.36))
		draw_colored_polygon(right, fill.darkened(0.5))
	var face: Texture2D = null
	var uv: PackedVector2Array = _uv4
	if cell >= 0:
		var info: Array = BOARD[cell]
		var kind: String = str(info[1])
		if cell % 8 == 0:
			face = TpArt.tex("c" + kind)
		else:
			face = TpArt.tex("top%d" % int(info[2]) if kind == "land" else "topn")
			uv = _face_uv(cell)
	if face == null and cell >= 0:
		face = TpArt.tex("corner") if cell % 8 == 0 else TpArt.tex("top")
		if face != null:
			draw_colored_polygon(_poly_px(top), fill.lightened(0.05), _uv4, face)
			return
	if face != null:
		draw_colored_polygon(_poly_px(top), Color.WHITE, uv, face)
	else:
		draw_colored_polygon(_poly_px(top), fill)


func _face_uv(cell: int) -> PackedVector2Array:
	var q: Rect2 = cell_uv(cell).grow(-0.0045)
	var lo: float = 1.0 - CS
	var out: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in [q.position, Vector2(q.end.x, q.position.y), q.end, Vector2(q.position.x, q.end.y)]:
		var a: float = 0.0
		var r: float = 0.0
		var c0: Rect2 = cell_uv(cell)
		match cell / 8:
			0:
				a = (p.x - c0.position.x) / TW
				r = (p.y - lo) / CS
			1:
				a = 1.0 - (p.y - c0.position.y) / TW
				r = (CS - p.x) / CS
			2:
				a = (p.x - c0.position.x) / TW
				r = (CS - p.y) / CS
			_:
				a = 1.0 - (p.y - c0.position.y) / TW
				r = (p.x - lo) / CS
		out.append(Vector2(a, (r if cell / 8 == 0 or cell / 8 == 3 else 1.0 - r)))
	return out


func _ink(text: String, px: float, col: Color, rim: Color, at: Vector2, width: float, font: Font = BOLD) -> void :
	var fs: int = maxi(6, roundi(px * _f))
	var sz: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	if width > 0.0 and sz > width:
		fs = maxi(6, int(floorf(fs * width / sz)))
		sz = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var o: Vector2 = at + Vector2( - sz / 2.0, (font.get_ascent(fs) - font.get_descent(fs)) / 2.0)
	if rim.a > 0.0:
		draw_string_outline(font, o, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, maxi(2, roundi(fs * 0.3)), rim)
	draw_string(font, o, text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, col)


func _name_lines(nm: String, px: float, width: float) -> Array:
	var fs: int = maxi(6, roundi(px * _f))
	if BOLD.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= width or not nm.contains(" "):
		return [nm]
	var words: PackedStringArray = nm.split(" ")
	var best: Array = [nm]
	var score: float = INF
	for k in range(1, words.size()):
		var a: String = " ".join(words.slice(0, k))
		var b: String = " ".join(words.slice(k))
		var m: float = maxf(BOLD.get_string_size(a, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x, BOLD.get_string_size(b, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x)
		if m < score:
			score = m
			best = [a, b]
	return best


func _tile_axes(cell: int) -> Array:
	var ex: Vector2 = (tile_at(cell, 1.0, 0.5) - tile_at(cell, 0.0, 0.5)).normalized()
	var ey: Vector2 = (tile_at(cell, 0.5, 1.0) - tile_at(cell, 0.5, 0.0)).normalized()
	if cell / 8 == 1 or cell / 8 == 2:
		ey = - ey
	return [ex, ey]

func _plane(at: Vector2, axes: Array) -> void :
	draw_set_transform_matrix(_cam * Transform2D(axes[0] as Vector2, axes[1] as Vector2, _P(at)))

func _flat() -> void :
	draw_set_transform_matrix(_cam)



static func r_pawn(cell: int) -> float:
	if TpArt.tex("av0") != null:


		return PAWN_R if cell / 8 == 0 or cell / 8 == 3 else 1.0 - PAWN_R
	return 0.1 if cell / 8 == 0 or cell / 8 == 3 else 0.86

static func r_name(cell: int) -> float:
	if _lots():
		return 0.57 if cell / 8 == 0 or cell / 8 == 3 else 0.43
	return 0.45 if cell / 8 == 0 or cell / 8 == 3 else 0.6

static func r_sub(cell: int) -> float:
	if _lots():
		return LOT_R if cell / 8 == 0 or cell / 8 == 3 else 1.0 - LOT_R
	return 0.86 if cell / 8 == 0 or cell / 8 == 3 else 0.14


static func _lots() -> bool:
	return TpArt.tex("pl_e") != null


static func _own_r(cell: int, k: float) -> float:
	return 0.03 + 0.08 * k if cell / 8 == 0 or cell / 8 == 3 else 0.97 - 0.08 * k


func _pedestal(thick: float) -> void :
	var deck: PackedVector2Array = PackedVector2Array([bp(0, 0), bp(1, 0), bp(1, 1), bp(0, 1)])
	draw_colored_polygon(_poly_px(deck, Vector2(0, thick)), Color("2a1a10"))
	var tex: Texture2D = TpArt.tex("base")
	var h: float = clampf(bb * 0.05, 6.0, 16.0)
	var d0: Vector2 = Vector2(0, thick)
	var d1: Vector2 = Vector2(0, thick + h)
	var segs: int = 7
	for face in range(2):
		var p0: Vector2 = bp(0, 1) if face == 0 else bp(1, 1)
		var p1: Vector2 = bp(1, 1) if face == 0 else bp(1, 0)
		var tint: Color = Color(0.92, 0.9, 0.88) if face == 0 else Color(0.62, 0.58, 0.56)
		for k in range(segs):
			var a0: Vector2 = p0.lerp(p1, k / float(segs))
			var a1: Vector2 = p0.lerp(p1, (k + 1) / float(segs))
			var quad: PackedVector2Array = _poly_px(PackedVector2Array([a0 + d0, a1 + d0, a1 + d1, a0 + d1]))
			if tex != null:
				draw_colored_polygon(quad, tint, _uv4, tex)
			else:
				draw_colored_polygon(quad, Color("4a2e1a") * tint)
	var lip: PackedVector2Array = _poly_px(PackedVector2Array([bp(0, 1), bp(1, 1), bp(1, 0)]), d1)
	draw_polyline(lip, Color(0, 0, 0, 0.45), maxf(1.0, 1.5 * _f), true)


func _board(preview: bool) -> void :
	var thick: float = clampf(bb * 0.036, 4.0, 12.0)

	for k in range(7):
		var g: float = 0.006 + 0.011 * k
		var sh: PackedVector2Array = PackedVector2Array([bp( - g, - g), bp(1.0 + g, - g), bp(1.0 + g, 1.0 + g), bp( - g, 1.0 + g)])
		draw_colored_polygon(_poly_px(sh, Vector2(0.02 * ba, thick + clampf(bb * 0.05, 6.0, 16.0) + 0.035 * bb)), Color(0, 0, 0, 0.085))
	_pedestal(thick)
	var inner: PackedVector2Array = PackedVector2Array([bp(CS, CS), bp(1.0 - CS, CS), bp(1.0 - CS, 1.0 - CS), bp(CS, 1.0 - CS)])
	var plate: Texture2D = TpArt.tex("centre")
	if plate != null:
		draw_colored_polygon(_poly_px(inner, Vector2(0, thick)), Color(1, 1, 1, 0.97), _uv4, plate)
	else:
		draw_colored_polygon(_poly_px(inner, Vector2(0, thick)), Color("0c2348", 0.92))
	var loop: PackedVector2Array = _poly_px(inner, Vector2(0, thick))
	loop.append(loop[0])
	draw_polyline(loop, Color(0.1, 0.06, 0.03, 0.55), maxf(1.0, 2.0 * _f), true)
	if plate != null:

		for k in range(3):
			var q0: float = CS + 0.012 * (k + 1)
			var ring0: PackedVector2Array = _poly_px(PackedVector2Array([bp(q0, q0), bp(1.0 - q0, q0), bp(1.0 - q0, 1.0 - q0), bp(q0, 1.0 - q0), bp(q0, q0)]), Vector2(0, thick))
			draw_polyline(ring0, Color(0, 0, 0, 0.16), maxf(1.0, 6.0 * _f), true)

		var ros: Texture2D = TpArt.tex("rosette")
		if ros != null:
			var r0: float = 0.5 - ROSE_R
			var r1: float = 0.5 + ROSE_R
			draw_colored_polygon(_poly_px(PackedVector2Array([bp(r0, r0), bp(r1, r0), bp(r1, r1), bp(r0, r1)]), Vector2(0, thick)), Color(1, 1, 1, 0.72), _uv4, ros)
		if false:
			for sgn: float in [-1.0, 1.0]:
				var fp: Vector2 = bc + Vector2(sgn * 0.8 * (1.0 - 2.0 * CS) * ba, 0.035 * bb + thick)
				var fw: float = 0.12 * ba * _f
				var ft: Texture2D = TpArt.tex("fountain")
				if ft != null:
					var fh: float = fw * ft.get_height() / float(ft.get_width())
					var blob0: Texture2D = TpArt.tex("blob")
					if blob0 != null:
						draw_texture_rect(blob0, Rect2(_P(fp) - Vector2(fw * 0.55, fw * 0.12), Vector2(fw * 1.1, fw * 0.3)), false, Color(1, 1, 1, 0.6))
					draw_texture_rect(ft, Rect2(_P(fp) - Vector2(fw / 2.0, fh * 0.94), Vector2(fw, fh)), false)
	for k in range(1, 4 if plate == null else 1):
		var q: float = CS + 0.07 * k
		var ring: PackedVector2Array = _poly_px(PackedVector2Array([bp(q, q), bp(1.0 - q, q), bp(1.0 - q, 1.0 - q), bp(q, 1.0 - q), bp(q, q)]), Vector2(0, thick))
		draw_polyline(ring, Color(0.45, 0.72, 1.0, 0.07), maxf(1.0, _f), true)

	var order: Array = range(N)
	order.sort_custom( func(a: int, b: int) -> bool: return tile_mid(a).y < tile_mid(b).y)
	var tiles: Dictionary = game.get("tiles", {}) if not preview else {}
	var now: float = now_ms()
	var ph: String = _phase()
	var mine: int = int(game.get("me", -1))
	var choosing: bool = not preview and my_turn() and confirm.is_empty() and (ph == "bus" or ph == "fest")
	var names: Array = []
	for cell: int in order:
		var fill: Color = tile_fill(cell)
		var t: Dictionary = tiles.get(cell, {})
		var lift: float = 0.0
		var pickable: bool = false
		if not preview and my_turn() and confirm.is_empty():
			pickable = (ph == "bus" and cell != BUS) or (ph == "fest" and _owner(cell) == mine)
		if pickable:
			lift = 3.0 + 2.0 * sin(now / 160.0)
		if sink.has(cell):
			var st: float = (now - float(sink[cell])) / 220.0
			if st >= 0.0 and st < 1.0:
				lift -= 3.5 * bk * sin(PI * st)
		var up: Vector2 = Vector2(0, - lift)
		var poly: PackedVector2Array = tile_poly(cell)
		for k in range(poly.size()):
			poly[k] += up
		_block(poly, fill, maxf(1.0, thick + lift), cell)
		var info: Array = BOARD[cell]
		if cell % 8 != 0:

			if str(info[1]) == "land" and TpArt.tex("top0") == null:
				var gc: Color = Color(str(GROUP_COL[int(info[2])])).darkened(0.12)
				draw_colored_polygon(_poly_px(PackedVector2Array([tile_at(cell, 0.04, 0.03), tile_at(cell, 0.96, 0.03), tile_at(cell, 0.96, 0.17), tile_at(cell, 0.04, 0.17)]), up), gc)
			if not t.is_empty() and not _lots():
				var oc: Color = Color(str(PLAYER_COL[str(t.get("o", "0")).to_int() % 4]))
				draw_colored_polygon(_poly_px(PackedVector2Array([tile_at(cell, 0.04, _own_r(cell, 0.0)), tile_at(cell, 0.96, _own_r(cell, 0.0)), tile_at(cell, 0.96, _own_r(cell, 1.0)), tile_at(cell, 0.04, _own_r(cell, 1.0))]), up), oc)
		if flash_tile.has(cell) and now - float(flash_tile[cell]) < 900.0:
			draw_colored_polygon(_poly_px(poly), Color(1, 1, 1, 0.5 * (1.0 - (now - float(flash_tile[cell])) / 900.0)))
		var edge: Color = Color(1, 0.95, 0.85, 0.3)
		var width: float = 1.0
		if not t.is_empty():
			edge = Color(str(PLAYER_COL[str(t.get("o", "0")).to_int() % 4]))
			width = 2.5
		if pickable:
			edge = Color("ffb630")
			width = 3.0
		var rim: PackedVector2Array = _poly_px(poly)
		rim.append(rim[0])
		if not t.is_empty() and not pickable:

			var ow: float = maxf(3.0, OWN_W * _f)
			draw_polyline(rim, OWN_INK, ow + maxf(2.0, OWN_INK_W * _f), true)
			draw_polyline(rim, edge, ow, true)
		else:
			draw_polyline(rim, edge, maxf(1.0, width * _f), true)
		if cell % 8 == 0:
			_corner_face(cell, lift, preview)
		elif not preview:
			_tile_face(cell, lift, t)
			names.append([cell, lift, choosing and not pickable])
		if pickable:
			draw_colored_polygon(_poly_px(poly), Color(1.0, 0.78, 0.25, 0.12 + 0.1 * sin(now / 160.0)))
		elif choosing:
			draw_colored_polygon(_poly_px(poly), Color(0, 0, 0, 0.45))
		if not preview:
			var m: Vector2 = tile_mid(cell)
			var hw: Vector2 = Vector2(ba, bb) * (CS * 0.5 if cell % 8 == 0 else TW * 0.5)
			_hit("t:%d" % cell, _R(m.x - hw.x, m.y - hw.y, hw.x * 2.0, hw.y * 2.0), false)
	for nm: Array in names:
		_tile_name(int(nm[0]), float(nm[1]), bool(nm[2]))


func _tile_face(cell: int, lift: float, t: Dictionary) -> void :
	var info: Array = BOARD[cell]
	var kind: String = str(info[1])
	var axes: Array = _tile_axes(cell)
	var span: float = Vector2(ba, bb).length() * _f
	var wide: float = TW * span * 0.9
	var up: Vector2 = Vector2(0, - lift)
	var now: float = now_ms()
	if kind == "chance" or kind == "luck" or kind == "tax":

		_flat()
		if TpArt.tex(kind) != null:
			_ysprite(tile_at(cell, 0.5, r_sub(cell)).y + up.y + 8.0 * bk, kind, _P(tile_at(cell, 0.5, r_sub(cell)) + up + Vector2(0, -4.0 * bk)), wide * (0.62 if kind == "tax" else 0.7), Color.WHITE, true)
		else:
			_plane(tile_at(cell, 0.5, r_sub(cell)) + up, axes)
			_ink("10%" if kind == "tax" else "?", 14.0 * bk, Color("2a8ae0"), Color.WHITE, Vector2.ZERO, wide)
	if kind != "land":
		return
	if _lots():
		_lot_face(cell, up, t, now)
		return
	var sub: Vector2 = tile_at(cell, 0.5, r_sub(cell)) + up
	if t.is_empty():
		_plane(sub, axes)
		_ink(_k8(_price8(cell)) if _m8() else str(info[3]), 10.5 * bk, Color("4a2e12"), Color(1, 0.97, 0.88, 0.0), Vector2.ZERO, wide)
		_flat()
		return
	var h: int = str(t.get("h", "0")).to_int()
	var oc: Color = Color(str(PLAYER_COL[str(t.get("o", "0")).to_int() % 4]))
	if h == 0:
		_plane(sub, axes)
		_ink("thuê " + (_k8(str(t.get("r", "0")).to_int()) if _m8() else str(t.get("r", ""))), 9.5 * bk, Color("7a1e0e"), Color(1, 0.97, 0.88, 0.0), Vector2.ZERO, wide)
		_flat()
	else:

		var g: float = (now - float(grow_at.get(cell, -100000.0))) / 500.0
		var pop: float = 1.0
		if g >= 0.0 and g < 1.0:
			pop = 1.3 * g / 0.6 if g < 0.6 else 1.3 - 0.3 * (g - 0.6) / 0.4
		if TpArt.tex("house1") != null:
			_building(_bname(h), tile_at(cell, 0.5, r_sub(cell)) + up + Vector2(0, 5.0 * bk), _bwide(h) * bk * pop, oc)
		elif h >= 3:
			_building("hotel", tile_at(cell, 0.5, r_sub(cell)) + up + Vector2(0, 6.0 * bk), 30.0 * bk * pop, oc)
		else:
			for k in range(h):
				var hp: Vector2 = tile_at(cell, 0.5 + (k - (h - 1) / 2.0) * 0.3, r_sub(cell)) + up + Vector2(0, 5.0 * bk)
				_building("house", hp, 19.0 * bk * (pop if k == h - 1 else 1.0), oc)
		if g >= 0.0 and g < 1.2:
			_ring(tile_at(cell, 0.5, r_sub(cell)) + up, g / 1.2, Color(1.0, 0.85, 0.35))

	var ft: float = clampf((now - float(flag_at.get(cell, -100000.0))) / 300.0, 0.0, 1.0)
	_flag(tile_at(cell, 0.9, (r_name(cell) + r_sub(cell)) / 2.0) + up, oc, bk * _ease_back(ft))
	if str(t.get("f", "0")) == "1":
		var fc: Vector2 = tile_at(cell, 0.86, r_name(cell)) + up + Vector2(0, -8.0 * bk)
		draw_circle(_P(fc), 8.0 * bk * _f, Color("e2541b"), true, -1.0, true)
		draw_arc(_P(fc), 8.0 * bk * _f, 0, TAU, 20, Color.WHITE, maxf(1.0, _f), true)
		_ink("×2", 8.0 * bk, Color.WHITE, Color(0, 0, 0, 0), _P(fc), 30.0 * _f)


func _lot_face(cell: int, up: Vector2, t: Dictionary, now: float) -> void :
	var box: Array = _lot_box(cell, up)
	var o: int = -1 if t.is_empty() else str(t.get("o", "0")).to_int()
	var ph: String = _phase()
	var me: Dictionary = _me()
	var here: bool = my_turn() and (ph == "buy" or ph == "build" or ph == "take") and not me.is_empty() and str(me.get("pos", "-1")).to_int() == cell
	var h: int = 0 if o < 0 else str(t.get("h", "0")).to_int()
	var ft: float = clampf((now - float(flag_at.get(cell, -100000.0))) / 300.0, 0.0, 1.0)
	if o >= 0 and str(t.get("f", "0")) == "1":
		var near8: bool = cell / 8 == 0 or cell / 8 == 3
		var pw8: bool = _pawn_on8(cell)
		if not _ydefer:
			_fest_banner8(cell, up, now)
		elif near8:
			_ysq.append([tile_at(cell, 0.5, 0.0).y + up.y - 0.5, "8", [cell, up, 0 if pw8 else 1]])
		else:
			_fest_banner8(cell, up, now, 0 if pw8 else 1)
		if _ydefer and not pw8:
			_ysq.append([tile_at(cell, 0.5, 1.0 if near8 else 0.0).y + up.y + 0.5, "8x", [cell, up]])

	if here and h == 0:
		_plinth(box, "pl_g", 1.0)
	elif o >= 0 and h == 0:
		_oflag(_bfoot(cell, up), o, ft)
	if h > 0:
		var oc: Color = Color(str(PLAYER_COL[o % 4]))
		var g: float = (now - float(grow_at.get(cell, -100000.0))) / 500.0
		var pop: float = 1.0
		if g >= 0.0 and g < 1.0:
			pop = 1.3 * g / 0.6 if g < 0.6 else 1.3 - 0.3 * (g - 0.6) / 0.4
		_building(_bname(h), _bfoot(cell, up), _bwide(h) * LOT_B * bk * pop, oc, o)
		if g >= 0.0 and g < 1.2:
			_ring(box[0], g / 1.2, Color(1.0, 0.85, 0.35))
	_lot_band(cell, up, t)



func _lot_band(cell: int, up: Vector2, t: Dictionary) -> void :
	_fest_band8(cell, up, t)
	var wide: float = TW * Vector2(ba, bb).length() * _f * 0.9
	var at: Vector2 = tile_at(cell, 0.5, 0.87 if cell / 8 == 0 or cell / 8 == 3 else 0.13) + up
	_plane(at, _tile_axes(cell))

	var px: float = 13.0 * bk
	if t.is_empty():
		_ink(_k8(_price8(cell)) if _m8() else num(int(BOARD[cell][3])), px, Color("4a2e12"), Color(1, 0.97, 0.88, 0.0), Vector2.ZERO, wide)
	else:
		var txt: String = _k8(str(t.get("r", "0")).to_int()) if _m8() else str(t.get("r", ""))
		var fest: bool = str(t.get("f", "0")) == "1"
		var w1: float = _tw(txt, px, BOLD) * _f
		var w2: float = 0.0
		var k: float = minf(1.0, wide / maxf(1.0, w1 + w2))
		_ink(txt, px * k, Color("ffe066") if fest else Color("8a1c0c"), Color(1, 0.97, 0.88, 0.0), Vector2( - w2 * k / 2.0, 0), wide)
		if fest:
			pass
	_flat()


func _lot_box(cell: int, up: Vector2) -> Array:
	var rs: float = r_sub(cell)
	var hr: float = LOT_A * TW / CS
	var lo: Vector2 = Vector2(INF, INF)
	var hi: Vector2 = Vector2( - INF, - INF)
	for q: Vector2 in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var p: Vector2 = tile_at(cell, 0.5 + q.x * LOT_A, rs + q.y * hr)
		lo = Vector2(minf(lo.x, p.x), minf(lo.y, p.y))
		hi = Vector2(maxf(hi.x, p.x), maxf(hi.y, p.y))
	return [tile_at(cell, 0.5, rs) + up, hi.x - lo.x, hi.y - lo.y]


func _plinth(box: Array, nm: String, k: float) -> void :
	var tex: Texture2D = TpArt.tex(nm)
	if tex == null:
		return
	var wide: float = float(box[1]) * 1.04 * k * _f
	var sy: float = (float(box[2]) / maxf(1.0, float(box[1]))) / float(TpArt.META.get("pl_dr", 0.5))
	var hh: float = wide * tex.get_height() / float(tex.get_width()) * sy
	var mid: float = float(TpArt.META.get("pl_mid", 0.3))
	draw_texture_rect(tex, Rect2(_P(box[0]) - Vector2(wide / 2.0, hh * mid), Vector2(wide, hh)), false)


func _bfoot(cell: int, up: Vector2) -> Vector2:
	if not _lots():
		return tile_at(cell, 0.5, r_sub(cell)) + up + Vector2(0, 5.0 * bk)
	var box: Array = _lot_box(cell, up)
	return box[0] + Vector2(0, float(box[2]) * 0.22)


func _lot_tag(box: Array, txt: String, low: bool) -> void :
	var px: float = (7.0 if low else 8.5) * bk
	var at: Vector2 = box[0] + Vector2(0, float(box[2]) * (0.56 if low else 0.18))
	var tg: Texture2D = TpArt.tex("tagd")
	var tw: float = minf(_tw(txt, px, BOLD) + 10.0 * bk, float(box[1]) * 0.95) * _f
	if tg != null:
		var th: float = maxf(tw * tg.get_height() / float(tg.get_width()), px * 1.5 * _f)
		draw_texture_rect(tg, Rect2(_P(at) - Vector2(tw, th) * 0.5, Vector2(tw, th)), false, Color(1, 1, 1, 0.95))
	_ink(txt, px, Color("ffe9a8"), Color(0, 0, 0, 0.5), _P(at), tw * 0.86)



func _tile_name(cell: int, lift: float, dim: bool) -> void :
	var info: Array = BOARD[cell]
	var kind: String = str(info[1])
	var axes: Array = _tile_axes(cell)
	var wide: float = TW * Vector2(ba, bb).length() * _f * 0.9
	var px: float = 12.5 * bk
	var ink: Color = Color.WHITE
	var rim: Color = tile_fill(cell).darkened(0.62)
	if kind == "chance" or kind == "luck" or kind == "tax":
		ink = Color("2d5a20") if kind == "tax" else Color("17457e")
		rim = Color(1, 1, 1, 0.92)
	if dim:
		ink = ink.darkened(0.45)
		rim = rim.darkened(0.45)
	var lines: Array = _name_lines("THUẾ 10%" if kind == "tax" else str(info[0]), px, wide)
	_plane(tile_at(cell, 0.5, r_name(cell)) + Vector2(0, - lift), axes)
	var lh: float = px * _f * 1.08
	for k in range(lines.size()):
		_ink(str(lines[k]), px, ink, rim, Vector2(0, (k - (lines.size() - 1) / 2.0) * lh), wide)
	_flat()


func _corner_face(cell: int, lift: float, preview: bool) -> void :
	var m: Vector2 = tile_mid(cell) - Vector2(0, lift)
	var hx: float = CS * ba
	var hy: float = CS * bb
	var k: float = clampf(hy / 39.0, 0.45, 1.3)
	var big: float = 14.0 * k
	var kind: String = str(BOARD[cell][1])

	var art: Dictionary = {"start": [0.0, 1.0], "jail": [-0.1, 0.92], 
		"fest": [0.0, 1.0], "bus": [0.04, 0.94]}
	var put: Array = art.get(kind, [0.0, 1.0])
	_ysprite(m.y + 0.2 * hy, kind, _P(m + Vector2(float(put[0]) * hx, 0.2 * hy)), float(put[1]) * hx * _f)
	match kind:
		"start":
			_ink("BẮT ĐẦU", big, Color.WHITE, Color("1d5a2a"), _P(m + Vector2(0, 0.46 * hy)), 1.2 * hx * _f)
			_ink(_go8(), 10.0 * k, Color("fff3b0"), Color("1d5a2a"), _P(m + Vector2(0, 0.76 * hy)), 0.6 * hx * _f)
		"jail":
			_ink("CÔN ĐẢO", big, Color.WHITE, Color("125552"), _P(m + Vector2(0.1 * hx, 0.48 * hy)), 1.1 * hx * _f)
		"fest":
			_ink("LỄ HỘI", big, Color.WHITE, Color("8a4a05"), _P(m + Vector2(0, 0.44 * hy)), 1.0 * hx * _f)
			if not preview:
				_ink("thuê ×2", 9.5 * k, Color("6b3205"), Color(1, 1, 1, 0.6), _P(m + Vector2(0, 0.74 * hy)), 0.6 * hx * _f)
		"bus":
			_ink("BẾN XE", big, Color.WHITE, Color("164a7a"), _P(m + Vector2(-0.1 * hx, 0.48 * hy)), 1.1 * hx * _f)


func _sprite(name: String, at: Vector2, wide: float, tint: Color = Color.WHITE, mid: bool = false) -> bool:
	var tex: Texture2D = TpArt.tex(name)
	if tex == null:
		return false
	var hh: float = wide * tex.get_height() / float(tex.get_width())
	draw_texture_rect(tex, Rect2(at - Vector2(wide / 2.0, hh / 2.0 if mid else hh), Vector2(wide, hh)), false, tint)
	return true


func _building(name: String, foot: Vector2, wide: float, col: Color, o: int = -1, tint: Color = Color.WHITE) -> void :
	if wide <= 0.5:
		return
	if _ydefer:
		_bshadow(foot, wide)
		_ysq.append([foot.y, "b", [name, foot, wide, col, o, tint]])
		return
	_building_now(name, foot, wide, col, o, tint)


func _bshadow(foot: Vector2, wide: float) -> void :
	var blob: Texture2D = TpArt.tex("blob")
	var sw: float = wide * 1.25 * _f
	var sh: float = sw * 0.42
	var at: Vector2 = _P(foot + Vector2(2.0 * bk, -1.0 * bk))
	_flat()
	if blob != null:
		draw_texture_rect(blob, Rect2(at - Vector2(sw, sh) * 0.5, Vector2(sw, sh)), false, Color(0, 0, 0, 0.42))
	else:
		draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.42), 0.0, at))
		draw_circle(Vector2.ZERO, sw * 0.5, Color(0, 0, 0, 0.22), true, -1.0, true)
		_flat()


func _ysprite(y: float, name: String, at: Vector2, wide: float, tint: Color = Color.WHITE, mid: bool = false) -> void :
	if _ydefer:
		_ysq.append([y, "s", [name, at, wide, tint, mid]])
	else:
		_sprite(name, at, wide, tint, mid)


func _oflag(foot: Vector2, o: int, ft: float) -> void :
	if _ydefer:
		_bshadow(foot + Vector2(4.0 * bk, 0), 11.0 * bk)
		_ysq.append([foot.y, "f", [foot, o, ft]])
		return
	_oflag_now(foot, o, ft)

func _oflag_now(foot: Vector2, o: int, ft: float) -> void :
	var oc: Color = Color(str(PLAYER_COL[o % 4]))
	var pop: float = 0.85 + 0.15 * _ease_back(ft)
	var k: float = bk * _f * pop
	var base: Vector2 = _P(foot)
	var top: Vector2 = base - Vector2(0, 36.0 * k)
	var wv: float = sin(now_ms() / 320.0 + foot.x * 0.05) * 1.6 * k
	_flat()
	draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.5), 0.0, base))
	draw_circle(Vector2.ZERO, 3.6 * k, Color("5a3a1c"), true, -1.0, true)
	_flat()
	draw_line(base, top, Color("4a2c12"), maxf(1.5, 2.6 * k), true)
	draw_line(base + Vector2(0.8 * k, 0), top + Vector2(0.8 * k, 0), Color(1, 0.9, 0.7, 0.35), maxf(1.0, 0.9 * k), true)
	var p0: Vector2 = top + Vector2(1.3 * k, 1.5 * k)
	var pa: Vector2 = top + Vector2(21.0 * k, 3.0 * k + wv)
	var pn: Vector2 = top + Vector2(15.0 * k, 7.5 * k + wv * 0.7)
	var pb: Vector2 = top + Vector2(21.0 * k, 12.5 * k + wv)
	var p2: Vector2 = top + Vector2(1.3 * k, 14.0 * k)
	var poly: PackedVector2Array = PackedVector2Array([p0, pa, pn, pb, p2])
	draw_colored_polygon(poly, oc)
	draw_colored_polygon(PackedVector2Array([p0, pa, pn, p0.lerp(p2, 0.45)]), oc.lightened(0.18))
	poly.append(p0)
	draw_polyline(poly, OWN_INK, maxf(1.5, 1.8 * k), true)
	draw_circle(top, 2.4 * k, Color("ffd45a"), true, -1.0, true)
	draw_circle(top - Vector2(0.6, 0.6) * k, 0.9 * k, Color(1, 1, 0.9, 0.9), true, -1.0, true)


func _ydraw(q: Array) -> void :
	_flat()
	var a: Array = q[2]
	if str(q[1]) == "8" or str(q[1]) == "8x":
		_fest_banner8(int(a[0]), a[1], now_ms(), int(a[2]) if str(q[1]) == "8" else 2)
		return
	if str(q[1]) == "f":
		_oflag_now(a[0], int(a[1]), float(a[2]))
		return
	if str(q[1]) == "b":
		_building_now(str(a[0]), a[1], float(a[2]), a[3], int(a[4]), a[5])
	else:
		_sprite(str(a[0]), a[1], float(a[2]), a[3], bool(a[4]))

func _building_now(name: String, foot: Vector2, wide: float, col: Color, o: int = -1, tint: Color = Color.WHITE) -> void :
	if o >= 0 and _sprite("%s_%d" % [name, o % 4], _P(foot), wide * 24.0 / _bwide(_blv(name)) * HOUSE_K * _f, tint):
		return
	var roof: Texture2D = TpArt.tex(name + "_r")
	if roof != null and _sprite(name, _P(foot), wide * _f):
		_sprite(name + "_r", _P(foot), wide * _f, col.lightened(0.1))
		return
	if not _sprite(name, _P(foot), wide * _f, col.lightened(0.28)):
		_house(foot, wide / 19.0, col)


static func _bname(h: int) -> String:
	return "hotel" if h >= 3 else ("house2" if h == 2 else "house1")

static func _blv(name: String) -> int:
	return 3 if name == "hotel" else (2 if name == "house2" else 1)

static func _bwide(h: int) -> float:
	return 31.0 if h >= 3 else (27.0 if h == 2 else 24.0)


func _ring(at: Vector2, t: float, col: Color) -> void :
	draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.5), 0.0, _P(at)))
	draw_arc(Vector2.ZERO, (10.0 + 30.0 * t) * bk * _f, 0, TAU, 32, Color(col, 1.0 - t), 3.0 * _f, true)
	_flat()


func _flag(foot: Vector2, col: Color, s: float) -> void :
	if s <= 0.05:
		return
	var top: Vector2 = foot + Vector2(0, -15.0 * s)
	draw_line(_P(foot), _P(top), Color("3a2a1a"), maxf(1.0, 1.6 * s * _f), true)
	var tri: PackedVector2Array = _poly_px(PackedVector2Array([top, top + Vector2(10.0 * s, 3.5 * s), top + Vector2(0, 7.0 * s)]))
	draw_colored_polygon(tri, col)
	tri.append(tri[0])
	draw_polyline(tri, Color(0, 0, 0, 0.6), maxf(1.0, 0.8 * _f), true)


static func _ease_back(u: float) -> float:
	var v: float = clampf(u, 0.0, 1.0) - 1.0
	return 1.0 + 2.70158 * v * v * v + 1.70158 * v * v

func _house(p: Vector2, sc: float, col: Color) -> void :
	var s: float = 4.6 * sc
	var body: PackedVector2Array = PackedVector2Array([p + Vector2( - s, 0), p + Vector2(s, 0), p + Vector2(s, - s * 1.2), p + Vector2(0, - s * 2.3), p + Vector2( - s, - s * 1.2)])
	draw_colored_polygon(_poly_px(body), col)
	draw_colored_polygon(_poly_px(PackedVector2Array([p + Vector2( - s, - s * 1.2), p + Vector2(0, - s * 2.3), p + Vector2(s, - s * 1.2), p + Vector2(s * 0.6, - s * 1.2), p + Vector2(0, - s * 1.85), p + Vector2( - s * 0.6, - s * 1.2)])), col.darkened(0.35))
	body.append(body[0])
	draw_polyline(_poly_px(body), Color(0, 0, 0, 0.7), maxf(1.0, _f), true)


func _table() -> void :
	var w: float = win_size.x
	var h: float = win_size.y
	var over: bool = str(game.get("over", "0")) == "1"
	_fit_board(Rect2(0, BAR, w, h - BAR))
	_cam = _cam_now()
	draw_set_transform_matrix(_cam)
	_ysq.clear()
	_ydefer = true
	_board(false)
	_ydefer = false
	_pawns()
	_board_fx(false)
	var bcam: Transform2D = _cam
	_cam = Transform2D.IDENTITY
	draw_set_transform_matrix(_cam)
	_top_bar()
	_pot_box()

	_cam = bcam
	draw_set_transform_matrix(_cam)
	_board_fx(true)
	_cam = Transform2D.IDENTITY
	draw_set_transform_matrix(_cam)
	var ps: Array = _players()
	for i in range(ps.size()):
		_card(i, _seat(i))
	_draw_floats()
	_screen_fx()
	if not over and confirm != "leave":
		_talk_ui()
		_tile_info()
	if confirm == "leave":
		_leave_box()
	elif over:
		_over_box()


func _cam_now() -> Transform2D:
	if cam_cell < 0:
		return Transform2D.IDENTITY
	var t: float = (now_ms() - cam_at) / 1100.0
	if t < 0.0 or t >= 1.0:
		return Transform2D.IDENTITY
	var z: float = 1.0 + 0.14 * sin(PI * t)
	var c: Vector2 = _P(tile_mid(cam_cell))

	var lo: Vector2 = _P(Vector2.ZERO)
	var hi: Vector2 = _P(win_size)
	var b0: Vector2 = _P(bc - Vector2(ba + 4.0, bb + 60.0))
	var b1: Vector2 = _P(bc + Vector2(ba + 4.0, bb + 30.0))
	z = minf(z, minf((hi.x - lo.x) / maxf(1.0, b1.x - b0.x), (hi.y - lo.y) / maxf(1.0, b1.y - b0.y)))
	if z <= 1.001:
		return Transform2D.IDENTITY
	c.x = clampf(c.x, (z * b1.x - hi.x) / (z - 1.0), maxf((z * b1.x - hi.x) / (z - 1.0), (z * b0.x - lo.x) / (z - 1.0)))
	c.y = clampf(c.y, (z * b1.y - hi.y) / (z - 1.0), maxf((z * b1.y - hi.y) / (z - 1.0), (z * b0.y - lo.y) / (z - 1.0)))
	return Transform2D(0.0, Vector2(z, z), 0.0, c - c * z)


func _table_frame(at: Vector2) -> void :
	var w: float = win_size.x
	var h: float = win_size.y
	var rr: Rect2 = _R(0, 0, w, h)
	if at.x > 1.0 or at.y > 1.0:

		_round(_R(-3.0, 2.0, w + 6.0, h + 6.0), Color(0, 0, 0, 0.45), 14.0)
		_round(_R(-6.0, -6.0, w + 12.0, h + 12.0), Color("3a1e0c"), 12.0, Color(GOLD, 0.85), 2.0)
	draw_rect(rr, Color("0a1a36"))
	var bg: Texture2D = TpArt.tex("bg")
	if bg != null:
		var ts: Vector2 = bg.get_size()
		var fit: float = maxf(rr.size.x / ts.x, rr.size.y / ts.y)
		var src: Vector2 = rr.size / fit
		draw_texture_rect_region(bg, rr, Rect2((ts - src) / 2.0, src))
	var mid: Vector2 = Vector2(w / 2.0, BAR + (h - BAR) / 2.0)
	if TpArt.tex("fountain") != null:

		if TpArt.tex("av0") == null:
			draw_rect(rr, Color(0.05, 0.03, 0.02, 0.22))
		return
	for k in range(5):
		draw_circle(_P(mid), (w * 0.5 - w * 0.08 * k) * _f, Color(0.35, 0.55, 0.85, 0.035), true, -1.0, true)


func _top_bar() -> void :
	var at: Vector2 = frame_at()
	var w: float = win_size.x
	draw_rect(_R(0, 0, w, BAR), Color("08224a", 0.94))
	draw_line(_P(Vector2(0, BAR)), _P(Vector2(w, BAR)), Color(GLASS_EDGE, 0.35), maxf(1.0, _f))
	_w("CỜ TỶ PHÚ", 20.0, GOLD, "l", 18, BAR / 2.0, 160, BOLD)
	_w("Gói %s Bạc" % num(_stake()), 16.0, MUTED, "l", 172, BAR / 2.0, 190)
	_close_btn(Vector2(w - 30.0, BAR / 2.0))
	rules_button(at + Vector2(w - 76.0, BAR / 2.0), 17.0)
	if str(game.get("over", "0")) != "1":
		_btn("leave_ask", "Rời bàn", Rect2(w - 226.0, 5, 120, 40), true, 16.0, "gray")
	var cx: float = w / 2.0 + 10.0
	var room: float = w - 2.0 * 360.0
	var now: float = now_ms()
	if not banner.is_empty() and now - banner_at < 3200.0:
		var a: float = clampf((3200.0 - (now - banner_at)) / 400.0, 0.0, 1.0)
		_round(_R(cx - room / 2.0, 6, room, BAR - 12.0), Color("7a1616", 0.95 * a) if banner_bad else Color("6a4a08", 0.95 * a), 14.0, Color(GOLD, 0.8 * a), 1.5)
		_w(banner, 17.0, Color(1, 1, 1, a), "c", cx, BAR / 2.0, room - 20.0, BOLD)
	elif not _turn_text().is_empty():

		var tl: String = _turn_text()
		var pw: float = minf(room, _tw(tl, 16.0, BOLD) + 40.0)
		_round(_R(cx - pw / 2.0, 7, pw, BAR - 14.0), Color(0, 0, 0, 0.35), 14.0, Color(GOLD, 0.6) if my_turn() else Color(GLASS_EDGE, 0.3), 1.5)
		_w(tl, 16.0, GOLD if my_turn() else CREAM, "c", cx, BAR / 2.0, pw - 16.0, BOLD)
	elif not lines.is_empty():
		_w(str(lines[lines.size() - 1]), 16.0, CREAM, "c", cx, BAR / 2.0, room)


func _turn_text() -> String:
	if not playing() or str(game.get("over", "0")) == "1":
		return ""
	var turn: int = int(game.get("turn", -1))
	var ps: Array = _players()
	if turn < 0 or turn >= ps.size():
		return ""
	var mine: bool = my_turn() and confirm.is_empty()
	var ph: String = _phase()
	var secs: int = int(ceilf(turn_left_ms() / 1000.0))
	var who: String = "Lượt bạn" if my_turn() else "Lượt " + str(ps[turn].get("name", ""))
	var hint: String = "bấm ô muốn tới hoặc ĐỔ" if mine and ph == "bus" else ("giữ ĐỔ để chỉnh lực" if mine and ph == "roll" else str(PHASE_HINT.get(ph, "")))
	var hs: float = space_at if space_at >= 0.0 else hold_at
	if mine and ph == "roll" and hs >= 0.0 and now_ms() - hs >= HOLD_MS:
		var hz: int = zone_of(now_ms() - hs)
		hint = "thả tay: tổng %d–%d dễ ra hơn" % [int(ZONES[hz][0]), int(ZONES[hz][1])]
	return "%s · %s · %ds" % [who, hint, secs]



static func _hop_squash(t: float, strong: float = 1.0) -> Vector2:
	var c: float = 1.0 - absf(2.0 * t - 1.0)
	var sy: float = 1.0 + strong * (-0.18 + 0.32 * smoothstep(0.0, 0.35, c) - 0.14 * smoothstep(0.5, 1.0, c))
	return Vector2(1.0 / sqrt(sy), sy)


static func _rest_squash(u: float) -> Vector2:
	if u < 0.0 or u >= 1.0:
		return Vector2.ONE
	var sy: float = 1.0 - 0.2 * cos(u * PI * 3.0) * (1.0 - u) * (1.0 - u)
	return Vector2(1.0 / sqrt(sy), sy)


func _pawns() -> void :
	var ps: Array = _players()
	var now: float = now_ms()
	var lv: int = gfx_level()
	var at_cell: Dictionary = {}
	var items: Array = []
	for i in range(ps.size()):
		if str(ps[i].get("out", "0")) == "1":
			continue
		var hop: Array = hops[i] if i < hops.size() else []
		if not hop.is_empty():
			var jump: bool = bool(hop[3])
			var t: float = clampf((now - float(hop[2])) / (JUMP_MS if jump else WALK_MS), 0.0, 1.0)
			var a: Vector2 = _pawn_spot(int(hop[0]), 0, 1)
			var b: Vector2 = _pawn_spot(int(hop[1]), 0, 1)
			items.append([a.lerp(b, t), i, (60.0 if jump else 20.0) * bk * sin(PI * t), _hop_squash(t, 1.25 if jump else 1.0), -1])
			continue
		var cell: int = posmod(roundi(float(shown[i]) if i < shown.size() else 0.0), N)
		if not at_cell.has(cell):
			at_cell[cell] = []
		(at_cell[cell] as Array).append(i)
	for cell: int in at_cell:
		var who: Array = at_cell[cell]
		for k in range(who.size()):
			var i: int = int(who[k])
			items.append([_pawn_spot(cell, k, who.size()), i, 0.0, _rest_squash((now - float(rest_at.get(i, -100000.0))) / 320.0), cell])
	var ysort: Array = []
	for pit: Array in items:
		ysort.append([_pawn_key(pit[0], int(pit[4])), "p", pit])
	ysort.append_array(_ysq)
	_ysq = []
	ysort.sort_custom( func(a: Array, b: Array) -> bool: return float(a[0]) < float(b[0]))
	var turn: int = int(game.get("turn", -1))
	var s: float = bk
	var blob: Texture2D = TpArt.tex("blob")
	for q: Array in ysort:
		if str(q[1]) != "p":
			_ydraw(q)
			continue
		var it: Array = q[2]
		var ground: Vector2 = it[0]
		var i: int = it[1]
		var up: float = it[2]
		var sq: Vector2 = it[3]
		var p: Vector2 = ground - Vector2(0, up)
		_pawn_at[i] = p
		var col: Color = Color(str(PLAYER_COL[i % 4]))
		var cur: bool = i == turn and playing()
		var hk: float = clampf(up / (50.0 * bk), 0.0, 1.0)
		var tex: Texture2D = TpArt.tex("pawn%d" % (i % 4))

		var sh: Vector2 = ground + Vector2(3.0, 1.5) * s * (1.0 + 2.0 * hk)
		var sr: float = (18.0 * PAWN_W / 66.0 if TpArt.tex("av0") != null else 13.0) * s * (1.0 - 0.35 * hk) * sq.x
		if blob != null and lv >= 1:
			draw_texture_rect(blob, Rect2(_P(sh) - Vector2(sr, sr * 0.5) * _f * 1.5, Vector2(sr * 2.0, sr) * _f * 1.5), false, Color(0, 0, 0, 0.55 * (1.0 - 0.55 * hk)))
		else:
			draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.5), 0.0, _P(sh)))
			draw_circle(Vector2.ZERO, sr * _f, Color(0, 0, 0, 0.34 * (1.0 - 0.6 * hk)), true, -1.0, true)
			_flat()
		var lk: Array = _look(i)
		if TpArt.tex("av0") != null or not lk.is_empty():

			var br: float = (TK_BASE if not lk.is_empty() else CB_W) * 0.5 * PAWN_W * s
			var rr: float = (br + SEAT_RING * PAWN_W * s) * (1.0 - 0.3 * hk)
			var rc: Vector2 = _P(ground + Vector2(0, 2.0 * s - rr * 0.5))
			var rw: float = maxf(2.5, 4.2 * s * _f)
			draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.5), 0.0, rc))
			draw_arc(Vector2.ZERO, rr * _f, 0, TAU, 40, OWN_INK, rw + maxf(2.0, 2.6 * s * _f), true)
			draw_arc(Vector2.ZERO, rr * _f, 0, TAU, 40, col, rw, true)
			_flat()
		var ring: Texture2D = TpArt.tex("ring")
		if cur and up <= 0.0 and ring != null:
			var rw: float = (46.0 * PAWN_W / 66.0 + 2.0 * sin(now / 220.0)) * s * _f
			var rh: float = rw * ring.get_height() / float(ring.get_width())
			draw_texture_rect(ring, Rect2(_P(ground) - Vector2(rw, rh) * 0.5, Vector2(rw, rh)), false)
		elif cur and up <= 0.0:

			draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.5), 0.0, _P(ground)))
			draw_arc(Vector2.ZERO, (15.0 + 1.5 * sin(now / 220.0)) * s * _f, 0, TAU, 28, Color(1.0, 0.8, 0.3, 0.9), 2.2 * s * _f, true)
			_flat()
		var head: float = 30.0 * s
		var cha: Texture2D = TpArt.tex("ch%da" % (i % 4))
		if not lk.is_empty():

			var src: Rect2 = lk[1]
			var dw: Vector2 = src.size * (PAWN_W * float(TK_W.get(look, 1.1)) * s * _f / maxf(src.size.x, src.size.y))
			var cbt: Texture2D = TpArt.tex("cb%d" % (i % 4))
			var bw: float = PAWN_W * TK_BASE * s * _f
			var bh: float = bw * 0.43
			var gp: Vector2 = _P(ground)
			if cbt != null:
				bh = bw * cbt.get_height() / float(cbt.get_width())
				draw_texture_rect(cbt, Rect2(gp - Vector2(bw / 2.0, bh), Vector2(bw, bh)), false)
			else:
				draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.45), 0.0, gp - Vector2(0, bh * 0.5)))
				draw_circle(Vector2.ZERO, bw * 0.5, col, true, -1.0, true)
				_flat()

			draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.36), 0.0, gp - Vector2(0, bh * 0.66)))
			var aw: float = maxf(3.0, 4.6 * s * _f)
			draw_arc(Vector2.ZERO, bw * 0.47, 0, TAU, 36, OWN_INK, aw + maxf(2.0, 2.4 * s * _f), true)
			draw_arc(Vector2.ZERO, bw * 0.47, 0, TAU, 36, col.lightened(0.15), aw, true)
			_flat()
			var lift: float = bh * float(TK_SIT.get(look, 0.3))
			draw_set_transform_matrix(_cam * Transform2D(0.0, sq, 0.0, _P(p) - Vector2(0, lift)))
			draw_texture_rect_region(lk[0], Rect2(Vector2( - dw.x / 2.0, - dw.y), dw), src)
			_flat()
			head = (dw.y * sq.y + lift) / _f
		elif cha != null:

			var cw: float = PAWN_W * s * _f
			var chh: float = cw * CH_H / CH_W
			var air: bool = up > 4.0 * s
			var fr: Texture2D = cha
			if air:
				var cb: Texture2D = TpArt.tex("cb%d" % (i % 4))
				if cb != null:
					var bw: float = cw * CB_W
					var bh: float = bw * cb.get_height() / float(cb.get_width())
					var gp: Vector2 = _P(ground)
					draw_texture_rect(cb, Rect2(gp - Vector2(bw / 2.0, bh), Vector2(bw, bh)), false)
				var cj: Texture2D = TpArt.tex("ch%dj" % (i % 4))
				if cj != null:
					fr = cj
					p = ground - Vector2(0, up * 0.75)
			elif sq.y < 0.94:
				var cbk: Texture2D = TpArt.tex("ch%db" % (i % 4))
				if cbk != null:
					fr = cbk
			head = cw / _f * CH_HEAD * sq.y
			draw_set_transform_matrix(_cam * Transform2D(0.0, sq if not air else Vector2(1.0, sq.y), 0.0, _P(p)))
			draw_texture_rect(fr, Rect2(Vector2( - cw / 2.0, - chh * CH_FOOT), Vector2(cw, chh)), false)
			_flat()
		elif tex != null:
			var wide: float = 25.0 * s * _f
			var tall: float = wide * tex.get_height() / float(tex.get_width())
			head = tall / _f * sq.y * 0.94
			draw_set_transform_matrix(_cam * Transform2D(0.0, sq, 0.0, _P(p)))
			draw_texture_rect(tex, Rect2(Vector2( - wide / 2.0, - tall * PAWN_FOOT), Vector2(wide, tall)), false)
			_flat()
		else:
			draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.5), 0.0, _P(p)))
			draw_circle(Vector2.ZERO, 9.0 * s * _f, col.darkened(0.3), true, -1.0, true)
			draw_circle(Vector2(0, -2.0 * _f), 8.0 * s * _f, col, true, -1.0, true)
			_flat()
			var top: Vector2 = p + Vector2(0, -24.0 * s * sq.y)
			draw_line(_P(p), _P(top), col.darkened(0.4), 3.0 * s * _f, true)
			draw_circle(_P(top), 9.0 * s * _f, col.darkened(0.35), true, -1.0, true)
			draw_circle(_P(top + Vector2(-1.0, -1.0) * s), 8.0 * s * _f, col, true, -1.0, true)
			head = 34.0 * s
		_pawn_head[i] = head
		if cur and up <= 0.0:

			var ay: float = p.y - head - 7.0 * s - 5.0 * absf(sin(now / 200.0))
			var arw: Texture2D = TpArt.tex("arrow")
			if arw != null:
				var aw: float = 15.0 * s * _f
				var ah: float = aw * arw.get_height() / float(arw.get_width())
				draw_texture_rect(arw, Rect2(_P(Vector2(p.x, ay + 2.0 * s)) - Vector2(aw * 0.5, ah), Vector2(aw, ah)), false)
			else:
				var tri: PackedVector2Array = _poly_px(PackedVector2Array([Vector2(p.x - 7.0 * s, ay - 8.0 * s), Vector2(p.x + 7.0 * s, ay - 8.0 * s), Vector2(p.x, ay + 2.0 * s)]))
				draw_colored_polygon(tri, Color("ffd23f"))
				tri.append(tri[0])
				draw_polyline(tri, Color("8a4a05"), maxf(1.0, 1.2 * _f), true)

		if lv >= 2 and up <= 0.0:
			var du: float = (now - float(rest_at.get(i, -100000.0))) / 380.0
			if du >= 0.0 and du < 1.0:
				for k in range(5):
					var ang: float = PI + k * PI / 4.0
					var rr: float = (8.0 + 16.0 * du) * s
					draw_circle(_P(ground + Vector2(cos(ang) * rr, - sin(ang) * rr * 0.35)), (2.6 - 1.2 * du) * s * _f, Color(0.95, 0.9, 0.8, 0.45 * (1.0 - du)), true, -1.0, true)


func _board_fx(tags: bool = false) -> void :
	var now: float = now_ms()
	var low: bool = low_gfx()
	for e: Dictionary in fx:
		var t: float = now - float(e["at"])
		if t < 0.0:
			continue
		var kind: String = str(e["k"])
		if (kind == "price" or kind == "go" or kind == "rent") != tags:
			continue
		if kind == "rent":
			var u: float = t / float(FX_LIFE[kind])
			var who: int = int(e["i"])
			if u >= 1.0 or not _pawn_at.has(who):
				continue
			var p: Vector2 = _pawn_at[who] - Vector2(0, float(_pawn_head.get(who, PAWN_W * bk * CH_HEAD)) + 14.0 * bk + 42.0 * u)
			if int(e["d"]) < 0:

				var out: Vector2 = Vector2(_pawn_at[who].x - bc.x, 0.0)
				p += Vector2(signf(out.x) * 22.0 * bk, -14.0 * bk)
			_money_tag(int(e["d"]), p, t, u)
		elif kind == "price" or kind == "go":
			var u: float = t / float(FX_LIFE[kind])
			var c: int = int(e["c"])
			var p: Vector2 = tile_mid(c) + Vector2(0, -22.0 * bk - 42.0 * u)
			if TpArt.tex("ch0a") != null:

				p = _pawn_spot(c, 0, 1) - Vector2(0, (float(_pawn_head.values().max()) if not _pawn_head.is_empty() else PAWN_W * bk * CH_HEAD) + 14.0 * bk + 42.0 * u)
			var d: int = int(e["d"])
			var col: Color = RED if kind == "price" else GOLD
			var txt: String = ("+%s" if d > 0 else "%s") % num(d)
			var tg: Texture2D = TpArt.tex("tag_g" if d > 0 else "tag_r")
			if tg != null:

				var pop: float = _ease_back(clampf(t / 220.0, 0.0, 1.0))
				var al: float = clampf((1.0 - u) / 0.35, 0.0, 1.0)
				var px: float = (17.0 if kind == "go" else 16.0) * pop
				var tw: float = maxf(_tw(txt, px, BOLD) + 26.0, 54.0) * _f
				var th: float = tw * tg.get_height() / float(tg.get_width())
				th = maxf(th, 26.0 * pop * _f)
				draw_texture_rect(tg, Rect2(_P(p) - Vector2(tw, th) * 0.5, Vector2(tw, th)), false, Color(1, 1, 1, al))
				_ink(txt, px, Color(1, 1, 1, al), Color(0.1, 0.03, 0.02, 0.9 * al), _P(p) - Vector2(0, 1.0 * _f), tw * 0.86)
			else:
				_w(txt, 16.0 if kind == "go" else 15.0, Color(col, 1.0 - u * u), "c", p.x, p.y, 140, BOLD)
		elif kind == "ghost":
			var u: float = clampf(t / 900.0, 0.0, 1.0)
			var c: int = int(e["c"])
			var hh: int = int(e["h"])
			var foot: Vector2 = _bfoot(c, Vector2.ZERO)
			var oc: Color = Color(str(PLAYER_COL[int(e["o"]) % 4]))
			var tex: Texture2D = TpArt.tex(_bname(hh)) if TpArt.tex("house1") != null else TpArt.tex("hotel" if hh >= 3 else "house")
			if TpArt.tex("%s_%d" % [_bname(hh), int(e["o"]) % 4]) != null:
				tex = TpArt.tex("%s_%d" % [_bname(hh), int(e["o"]) % 4])
			if tex != null:
				var wide: float = (_bwide(hh) if TpArt.tex("house1") != null else (30.0 if hh >= 3 else 19.0)) * (LOT_B if _lots() else 1.0) * bk * _f * (1.0 + 0.3 * u)
				var tall: float = wide * tex.get_height() / float(tex.get_width()) * (1.0 - u)
				var fp: Vector2 = _P(foot)
				draw_texture_rect(tex, Rect2(fp - Vector2(wide / 2.0, tall), Vector2(wide, tall)), false, Color(Color.WHITE if TpArt.tex("house1") != null else oc.lightened(0.28), 1.0 - u))
			if not low:
				for k in range(8):
					var ang: float = k * TAU / 8.0
					var rr: float = (6.0 + 26.0 * u) * bk
					draw_circle(_P(foot + Vector2(cos(ang) * rr, sin(ang) * rr * 0.5 - 4.0 * bk)), (3.0 + 5.0 * u) * bk * _f, Color(0.85, 0.8, 0.7, 0.5 * (1.0 - u)), true, -1.0, true)
		elif kind == "rays" and not low:
			var u: float = clampf(t / 1600.0, 0.0, 1.0)
			var c: int = int(e["c"])
			var ctr: Vector2 = _P(tile_at(c, 0.5, r_sub(c)) - Vector2(0, 14.0 * bk))
			var ln: float = (26.0 + 22.0 * u) * bk * _f
			var al: float = 0.55 * sin(PI * u)
			for k in range(12):
				var ang: float = k * TAU / 12.0 + t / 900.0
				var tri: PackedVector2Array = PackedVector2Array([ctr, ctr + Vector2(cos(ang - 0.09), sin(ang - 0.09)) * ln, ctr + Vector2(cos(ang + 0.09), sin(ang + 0.09)) * ln])
				draw_colored_polygon(tri, Color(1.0, 0.86, 0.35, al))


func _money_tag(d: int, p: Vector2, t: float, u: float) -> void :
	var txt: String = ("+%s" if d > 0 else "%s") % num(d)
	var pop: float = _ease_back(clampf(t / 220.0, 0.0, 1.0))
	var al: float = clampf((1.0 - u) / 0.35, 0.0, 1.0)
	var tg: Texture2D = TpArt.tex("tag_r" if d < 0 else "tag_g")
	if tg != null:
		var px: float = 16.0 * pop
		var tw: float = maxf(_tw(txt, px, BOLD) + 26.0, 54.0) * _f
		var th: float = maxf(tw * tg.get_height() / float(tg.get_width()), 26.0 * pop * _f)
		draw_texture_rect(tg, Rect2(_P(p) - Vector2(tw, th) * 0.5, Vector2(tw, th)), false, Color(1, 1, 1, al))

		var ink: Color = Color(1, 1, 1, al) if d < 0 else Color(1.0, 0.96, 0.74, al)
		var rim: Color = Color(0.1, 0.03, 0.02, 0.9 * al) if d < 0 else Color(0.02, 0.16, 0.05, 0.92 * al)
		_ink(txt, px, ink, rim, _P(p) - Vector2(0, 1.0 * _f), tw * 0.86)
	else:
		var px2: float = 21.0 * pop
		_ink(txt, px2, Color(GOLD if d > 0 else RED, al), Color(0.16, 0.07, 0.02, 0.95 * al), _P(p), 140.0 * _f)


func _pawn_spot(cell: int, k: int, n: int) -> Vector2:
	var hx: float = CS * ba
	var hy: float = CS * bb
	var m: Vector2 = tile_mid(cell)
	var sp: float = 14.0 * bk
	if cell % 8 == 0:


		var slot: Array = [Vector2(-0.55, 0.02), Vector2(0.55, 0.02), Vector2(-0.3, -0.34), Vector2(0.3, -0.34)]
		var q: Vector2 = slot[k % 4]
		if n == 1:
			q = Vector2(-0.55 if cell == 0 or cell == 24 else 0.55, 0.02)
		return m + Vector2(q.x * hx, q.y * hy) + Vector2(0, - (k / 4) * sp * 0.4)
	var a: float = 0.5 if n == 1 else (0.3 + 0.4 * k if n == 2 else 0.2 + 0.6 * k / float(n - 1))
	if _lot_busy(cell):
		var e: float = float(PAWN_SIDE[mini(n, 3) - 1])
		a = e if n == 1 else e + (1.0 - 2.0 * e) * k / float(n - 1)

	var step: float = PAWN_STEP if n > 2 and k % 2 == 1 else 0.0
	var r: float = r_pawn(cell) + (step if cell / 8 == 0 or cell / 8 == 3 else - step)
	return tile_at(cell, a, r)


func _lot_busy(cell: int) -> bool:
	if not (game.get("tiles", {}).get(cell, {}) as Dictionary).is_empty():
		return true
	return ["chance", "luck", "tax"].has(str(BOARD[cell % N][1]))


func _pawn_key(ground: Vector2, cell: int) -> float:
	var y: float = ground.y + PAWN_KEY * bk
	if cell >= 0 and cell % 8 == 0:
		y = maxf(y, tile_mid(cell).y + 0.2 * CS * bb + 1.0)
	return y


func _pot_box() -> void :
	var over: bool = str(game.get("over", "0")) == "1"
	var c: Vector2 = bc
	var ck: float = _ck()
	die_w = DIE_W * ck
	var pot: int = str(game.get("pot", "0")).to_int()
	var round_n: int = str(game.get("round", "1")).to_int()
	var gl: int = int(ceilf(game_left_ms() / 1000.0))

	var box: Rect2 = Rect2(c.x - 122.0 * ck, c.y - 154.0 * ck, 244.0 * ck, 70.0 * ck)
	var pt: float = now_ms() - pot_at
	if pt >= 0.0 and pt < 600.0:
		box.position.x += 5.0 * sin(pt / 25.0) * (1.0 - pt / 600.0)
	var bxr: Rect2 = _R(box.position.x, box.position.y, box.size.x, box.size.y)
	for kq in range(4):
		var gq: float = (kq + 1) * 2.0 * _f
		_round(Rect2(bxr.position + Vector2( - gq * 0.5, 2.0 * _f + gq * 1.2), bxr.size + Vector2(gq, 0)), Color(0, 0, 0, 0.1), 16.0 + kq * 2.0)
	_grad(bxr, Color("1a4a86", 0.97), Color("0b2650", 0.97), Color("f0cf78", 0.95), 16.0, 1.5)
	_lip(bxr, 0.35, 16.0)
	var tl: String = ("Còn %d:%02d" % [gl / 60, gl % 60]) if not over else "Hết ván"
	var by: float = box.position.y
	_w("%s · Lượt %d/%s" % [tl, round_n, str(game.get("rounds", max_rounds))], 15.0 * ck, RED if gl <= 60 and not over else CREAM, "c", c.x, by + 17.0 * ck, box.size.x - 12.0, BOLD)
	draw_line(_P(Vector2(box.position.x + 16.0, by + 32.0 * ck)), _P(Vector2(box.end.x - 16.0, by + 32.0 * ck)), Color(GLASS_EDGE, 0.35), maxf(1.0, _f))
	_w("Hũ", 16.0 * ck, MUTED, "r", c.x - 58.0 * ck, by + 51.0 * ck, 60, BOLD)
	var pts: String = short_bac(pot)
	var ptw: float = minf(_tw(pts, 30.0 * ck, BOLD), 100.0 * ck)
	_ink(pts, 30.0 * ck, GOLD, Color("2a1404", 0.95), _P(Vector2(c.x - 52.0 * ck + ptw / 2.0, by + 51.0 * ck)), 100.0 * ck * _f)
	_w("cược " + short_bac(_stake()), 13.0 * ck, MUTED, "r", box.end.x - 10.0 * ck, by + 53.0 * ck, 70.0 * ck)
	if pt >= 0.0 and pt < 1000.0 and not low_gfx():
		for k in range(10):
			var u: float = pt / 1000.0
			var cp: Vector2 = Vector2(c.x + (k - 4.5) * 20.0 * ck * u, box.end.y - 4.0 - 80.0 * ck * u + 170.0 * ck * u * u)
			_coin(cp, 8.0 * ck, 1.0 - u * u)
	_dice(c, ck)
	if over:
		_sum_flush()
		return
	var turn: int = int(game.get("turn", -1))
	var ps: Array = _players()
	var mine: bool = my_turn() and confirm.is_empty()
	var ph: String = _phase()
	var me: Dictionary = _me()
	var line: String = ""
	if turn >= 0 and turn < ps.size():
		var secs: int = int(ceilf(turn_left_ms() / 1000.0))
		var who: String = "Lượt bạn" if my_turn() else "Lượt " + str(ps[turn].get("name", ""))
		var hint: String = "bấm ô muốn tới hoặc ĐỔ" if mine and ph == "bus" else ("giữ ĐỔ để chỉnh lực" if mine and ph == "roll" else str(PHASE_HINT.get(ph, "")))
		var hs: float = space_at if space_at >= 0.0 else hold_at
		if mine and ph == "roll" and hs >= 0.0 and now_ms() - hs >= HOLD_MS:
			var hz: int = zone_of(now_ms() - hs)
			hint = "thả tay: tổng %d–%d dễ ra hơn" % [int(ZONES[hz][0]), int(ZONES[hz][1])]
		line = "%s · %s · %ds" % [who, hint, secs]
	if mine and (ph == "buy" or ph == "build" or ph == "fest" or ph == "take") and not _moving(int(game.get("me", -1))) and _evq8.is_empty() and not _card_up8():
		_sum_flush()
		_choice_box(ph, line)
		return
	var pfee: int = str(game.get("pfee", "100")).to_int()
	var roll_ok: bool = mine and (ph == "roll" or ph == "bus")
	var row: float = c.y + 38.0 * ck
	var px: float = 178.0 * ck
	_parity_btn("odd", "Lẻ", Vector2(c.x - px, row), roll_ok)
	_parity_btn("even", "Chẵn", Vector2(c.x + px, row), roll_ok)
	if TpArt.tex("tagd") == null:
		_w("+Mua Lẻ (%s)" % num(pfee), 13.0 * ck, Color(CREAM, 0.9), "c", c.x - px, row - 46.0 * ck, 150.0 * ck, BOLD)
		_w("+Mua Chẵn (%s)" % num(pfee), 13.0 * ck, Color(CREAM, 0.9), "c", c.x + px, row - 46.0 * ck, 150.0 * ck, BOLD)
	_roll_btn(Vector2(c.x, row), roll_ok)
	_gauge(Vector2(c.x, row), roll_ok and (hold_at >= 0.0 or space_at >= 0.0))
	_sum_flush(Vector2(c.x, row))
	var ty: float = c.y + 107.0 * ck
	if not line.is_empty() and TpArt.tex("av0") == null:
		_round(_R(c.x - 170.0 * ck, ty - 14.0 * ck, 340.0 * ck, 28.0 * ck), Color(0, 0, 0, 0.36), 14.0)
		_w(line, 14.5 * ck, GOLD if my_turn() else CREAM, "c", c.x, ty, 330.0 * ck, BOLD)
	if mine and str(me.get("jail", "0")).to_int() > 0 and ph == "roll":
		var jf: int = str(game.get("jfee", "100")).to_int()
		var bh: float = _tap(32.0 * ck)
		_btn("bail", "Nộp %s ra Côn Đảo" % num(jf), Rect2(c.x - 105.0 * ck, ty + 18.0 * ck, 210.0 * ck, bh), str(me.get("cash", "0")).to_int() >= jf, 14.0 * ck)
	elif _me_out():
		_w("Phá sản — mất gói %s Bạc" % num(_stake()), 16.0 * ck, RED, "c", c.x, ty + 32.0 * ck, 330, BOLD)


func _ck() -> float:
	return clampf(bb / 295.0, 0.8, 1.2)


func _tap(hh: float) -> float:
	return maxf(hh, 40.0) if _mobile else hh


func _moving(i: int) -> bool:
	if i < 0:
		return false
	if i == dice_from and now_ms() - dice_at < DICE_MS:
		return true
	return (i < paths.size() and not (paths[i] as Array).is_empty()) or (i < hops.size() and not (hops[i] as Array).is_empty())


func _die(c: Vector2, v: int, rot: float, sc: float = 1.0, sq: Vector2 = Vector2.ONE, spin: int = -1) -> void :
	v = clampi(v, 1, 6)
	var blank: Texture2D = TpArt.tex("die0")
	var tex: Texture2D = blank if blank != null else TpArt.tex("die%d" % v)
	if spin >= 0 and TpArt.tex("roll%d" % posmod(spin, 6)) != null:
		blank = null
		tex = TpArt.tex("roll%d" % posmod(spin, 6))
	if tex != null:
		var wide: float = die_w * _f
		var tall: float = wide * tex.get_height() / float(tex.get_width())

		var m: Transform2D = _cam * Transform2D(0.0, sq * sc, 0.0, _P(c + Vector2(0, die_w * 0.45))) * Transform2D(rot, Vector2(0, - tall * 0.45))
		draw_set_transform_matrix(m)
		var r: Rect2 = Rect2(Vector2( - wide / 2.0, - tall / 2.0), Vector2(wide, tall))
		draw_texture_rect(tex, r, false)
		if blank != null:
			var vals: Array = [v, int(DIE_SIDE[v][0]), int(DIE_SIDE[v][1])]
			for f in range(3):
				var fc: Array = DIE_FACE[f]
				var o: Vector2 = r.position + (fc[0] as Vector2) * r.size
				var e1: Vector2 = ((fc[1] as Vector2) - (fc[0] as Vector2)) * r.size
				var e2: Vector2 = ((fc[2] as Vector2) - (fc[0] as Vector2)) * r.size
				_die_pips(int(vals[f]), o, e1, e2, f)
		draw_set_transform_matrix(_cam)
		return
	var s: float = 13.0
	draw_set_transform(_P(c), rot, Vector2(sc, sc) * sq)
	var rr: Rect2 = Rect2(Vector2( - s, - s) * _f, Vector2(s, s) * 2.0 * _f)
	_round(Rect2(rr.position + Vector2(0, 3) * _f, rr.size), Color("9aa0b0"), 5.0)
	_round(rr, Color("fbfbff"), 5.0, Color("5a6070"), 1.0)
	for p: Vector2 in _pip_at(v):
		draw_circle((p - Vector2(0.5, 0.5)) * 26.0 * _f, 2.4 * _f, Color("d4202c") if v == 1 or v == 4 else Color("1d2230"), true, -1.0, true)
	draw_set_transform_matrix(_cam)


static func _pip_at(n: int) -> Array:
	var lo: float = 0.27
	var hi: float = 0.73
	match n:
		1: return [Vector2(0.5, 0.5)]
		2: return [Vector2(lo, lo), Vector2(hi, hi)]
		3: return [Vector2(lo, lo), Vector2(0.5, 0.5), Vector2(hi, hi)]
		4: return [Vector2(lo, lo), Vector2(hi, lo), Vector2(lo, hi), Vector2(hi, hi)]
		5: return [Vector2(lo, lo), Vector2(hi, lo), Vector2(0.5, 0.5), Vector2(lo, hi), Vector2(hi, hi)]
	return [Vector2(lo, lo), Vector2(lo, 0.5), Vector2(lo, hi), Vector2(hi, lo), Vector2(hi, 0.5), Vector2(hi, hi)]


func _die_pips(n: int, o: Vector2, e1: Vector2, e2: Vector2, face: int) -> void :
	var col: Color = Color("c8261c") if n == 1 or n == 4 else Color("2a1a12")
	if face > 0:
		col = col.darkened(0.12)
	var rr: float = 0.15 if n == 1 else 0.105
	for p: Vector2 in _pip_at(n):
		for layer in range(2):
			var rad: float = rr * (1.22 if layer == 0 else 1.0)
			var pts: PackedVector2Array = PackedVector2Array()
			for k in range(16):
				var a: float = k * TAU / 16.0
				pts.append(o + (p.x + rad * cos(a)) * e1 + (p.y + rad * sin(a)) * e2)
			var cc: Color = Color(0.35, 0.22, 0.1, 0.28) if layer == 0 else col
			draw_colored_polygon(pts, cc)
			if layer == 1:
				pts.append(pts[0])
				draw_polyline(pts, Color(col, 0.8), 1.0, true)
		var hl: Vector2 = o + (p.x - rr * 0.3) * e1 + (p.y - rr * 0.35) * e2
		draw_circle(hl, maxf(0.6, rr * 0.3 * minf(e1.length(), e2.length())), Color(1, 1, 1, 0.22), true, -1.0, true)


func _die_shadow(ground: Vector2, up: float) -> void :
	var dk: float = die_w / 30.0
	var hk: float = clampf(up / (70.0 * dk), 0.0, 1.0)
	var at: Vector2 = ground + Vector2(4.0 * dk, die_w * 0.42) + Vector2(10.0, 4.0) * dk * hk
	var rr: float = die_w * 0.62 * (1.0 - 0.4 * hk)
	var blob: Texture2D = TpArt.tex("blob")
	if blob != null and gfx_level() >= 1:
		draw_texture_rect(blob, Rect2(_P(at) - Vector2(rr, rr * 0.5) * _f * 1.4, Vector2(rr * 2.0, rr) * _f * 1.4), false, Color(0, 0, 0, 0.6 * (1.0 - 0.6 * hk)))
	else:
		draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.5), 0.0, _P(at)))
		draw_circle(Vector2.ZERO, rr * _f, Color(0, 0, 0, 0.3 * (1.0 - 0.6 * hk)), true, -1.0, true)
		draw_set_transform_matrix(_cam)



static func _die_pose(t: float, start: Vector2, to: Vector2, dir: float, k: float = 1.0) -> Array:
	var back: Vector2 = (start - to).normalized()
	var l1: Vector2 = to + back * 38.0 * k
	var l2: Vector2 = to + back * 11.0 * k
	if t < DIE_T[0]:
		var u: float = t / DIE_T[0]
		var e: float = 1.0 - (1.0 - u) * (1.0 - u)
		return [start.lerp(l1, e), 96.0 * k * sin(PI * e) * (1.0 - 0.25 * e), (1.0 - e) * 2.0 * TAU * dir, 0.6 + 0.4 * e, Vector2(0.96, 1.06), true]
	if t < DIE_T[1]:
		var u: float = (t - DIE_T[0]) / (DIE_T[1] - DIE_T[0])
		return [l1.lerp(l2, u), 30.0 * k * sin(PI * u), 0.9 * (1.0 - u) * dir, 1.0, _hop_squash(u, 1.1), true]
	if t < DIE_T[2]:
		var u: float = (t - DIE_T[1]) / (DIE_T[2] - DIE_T[1])
		return [l2.lerp(to, u), 10.0 * k * sin(PI * u), 0.0, 1.0, _hop_squash(u, 0.7), false]
	return [to, 0.0, 0.0, 1.0, _rest_squash((t - DIE_T[2]) / 260.0), false]



func _dice(c: Vector2, ck: float) -> void :
	_sum_q = []
	if hold_at >= 0.0 or space_at >= 0.0:
		return
	var dice: PackedStringArray = str(game.get("dice", "0,0")).split(",")
	if dice.size() != 2:
		return
	var now: float = now_ms()
	var gap: float = die_w * 0.7
	var dk: float = die_w / 30.0
	var rest: Array = [Vector2(c.x - gap, c.y - 45.0 * ck), Vector2(c.x + gap, c.y - 45.0 * ck + 4.0 * ck)]
	if now - roll_wait < 3000.0:
		for k in range(2):
			var hopu: float = fposmod(now / 260.0 + k * 0.5, 1.0)
			_die_shadow(rest[k], 7.0 * dk * sin(PI * hopu))
			_die((rest[k] as Vector2) + Vector2(2.0 * dk * sin(now / 30.0 + k), -7.0 * dk * sin(PI * hopu)), 1 + (int(now / 70.0) + k * 3) % 6, 0.25 * sin(now / 40.0 + k), 1.0, _hop_squash(hopu, 0.6), int(now / 70.0) + k * 3)
		return
	if dice[0].to_int() <= 0:
		return
	var vals: Array = [clampi(dice[0].to_int(), 1, 6), clampi(dice[1].to_int(), 1, 6)]
	var t: float = now - dice_at
	var lv: int = gfx_level()
	var from: Vector2 = _card_centre(dice_from) if dice_from >= 0 and dice_from < _players().size() else c + Vector2(0, 140)
	for k in range(2):
		var to: Vector2 = rest[k]
		if t < 0.0 or t >= DIE_T[2] + 260.0:
			_die_shadow(to, 0.0)
			_die(to, int(vals[k]), 0.0)
			continue
		var start: Vector2 = from + Vector2((k - 0.5) * 24.0 * dk, 0)
		var dir: float = 1.0 if k == 0 else -1.0
		var tk: float = maxf(0.0, t - k * 30.0)
		var pose: Array = _die_pose(tk, start, to, dir, dk)
		var ground: Vector2 = pose[0]
		var up: float = pose[1]
		if lv >= 1 and tk < DIE_T[1]:

			var stx: Texture2D = TpArt.tex("fx_star")
			for j in range(1, 7):
				var pj: Array = _die_pose(tk - j * 26.0, start, to, dir, dk) if tk - j * 26.0 > 0.0 else []
				if pj.is_empty():
					break
				var tp_: Vector2 = _P((pj[0] as Vector2) - Vector2(0, float(pj[1])) + Vector2(sin(j * 2.3 + k) * 6.0, cos(j * 1.7) * 4.0) * dk)
				var fa: float = 1.0 - j / 7.0
				if stx != null:
					var sz: float = die_w * (0.5 - 0.05 * j) * _f
					draw_texture_rect(stx, Rect2(tp_ - Vector2(sz, sz) * 0.5, Vector2(sz, sz)), false, Color(1.0, 0.92, 0.55, 0.85 * fa))
				else:
					draw_circle(tp_, (7.0 - j) * dk * _f, Color(1.0, 0.8, 0.25, 0.32 * fa), true, -1.0, true)
		if lv >= 1:

			for hit: int in [0, 1]:
				var bu: float = (tk - DIE_T[hit]) / 380.0
				if bu >= 0.0 and bu < 1.0:
					_die_burst(_die_pose(DIE_T[hit], start, to, dir, dk)[0] as Vector2, bu, k * 2 + hit, 1.0 if hit == 0 else 0.6)
		_die_shadow(ground, up)
		if lv >= 2:

			for hit: int in [0, 1]:
				var hu: float = (tk - DIE_T[hit]) / 220.0
				if hu >= 0.0 and hu < 1.0:
					var hp: Vector2 = (_die_pose(DIE_T[hit], start, to, dir, dk)[0] as Vector2) + Vector2(0, die_w * 0.42)
					draw_set_transform_matrix(_cam * Transform2D(0.0, Vector2(1.0, 0.5), 0.0, _P(hp)))
					draw_arc(Vector2.ZERO, (die_w * 0.5 + 16.0 * dk * hu) * _f, 0, TAU, 24, Color(1.0, 0.95, 0.8, (0.4 if hit == 0 else 0.25) * (1.0 - hu)), 2.0 * _f, true)
					draw_set_transform_matrix(_cam)
		var spin: int = int(now / (60.0 if tk < DIE_T[0] else 90.0)) + k * 2
		var face: int = 1 + spin % 6 if bool(pose[5]) else int(vals[k])
		if lv >= 1 and tk < DIE_T[1]:
			_die_sparks(ground - Vector2(0, up), now, k)
		_die(ground - Vector2(0, up), face, float(pose[2]), float(pose[3]), pose[4], spin if bool(pose[5]) else -1)
	if t >= float(DIE_T[2]) and t < float(DIE_T[2]) + SUM_MS:
		_sum_q = [c, ck, vals, t - float(DIE_T[2])]


const SUM_MS: float = 850.0

func _sum_flush(dome: Vector2 = Vector2(-1, -1)) -> void :
	if _sum_q.is_empty():
		return
	var q: Array = _sum_q
	_sum_q = []
	_sum_big(q[0], q[1], q[2], q[3], dome)

func _sum_big(c: Vector2, ck: float, vals: Array, u: float, dome: Vector2 = Vector2(-1, -1)) -> void :
	var al: float = clampf(minf(u / 90.0, (SUM_MS - u) / 220.0), 0.0, 1.0)
	var pop: float = _ease_back(clampf(u / 220.0, 0.0, 1.0))
	var sum: int = int(vals[0]) + int(vals[1])
	var bp: Vector2 = Vector2(c.x, c.y + die_w * 1.45)
	var tp_: Vector2 = bp + Vector2(0, 40.0 * ck)
	var px: float = 66.0 * ck * maxf(0.2, pop)
	var rt: Texture2D = TpArt.tex("roll_n")
	if dome.x >= 0.0 and rt != null:

		var rk: float = _ck() * 1.5
		var rtall: float = RD_W * rk * rt.get_height() / float(rt.get_width())
		bp = dome + Vector2(0, 2.0 * ck)
		tp_ = dome + Vector2(0, rtall * RD_FACE + 13.0 * ck)
		px = 58.0 * ck * maxf(0.2, pop)
	draw_set_transform_matrix(_cam)
	_ink(str(sum), px, Color(1.0, 0.95, 0.72, al), Color(0.18, 0.06, 0.02, 0.95 * al), _P(bp), 180.0 * ck * _f)
	var tag: String = ""
	if int(vals[0]) == int(vals[1]):
		tag = "Đôi!"
	elif dice_z >= 0 and dice_z < ZONES.size() and sum >= int(ZONES[dice_z][0]) and sum <= int(ZONES[dice_z][1]):
		tag = "Đổ chính xác!"
	if not tag.is_empty():
		_ink(tag, 17.0 * ck, Color(1.0, 0.86, 0.3, al), Color(0.3, 0.05, 0.03, 0.95 * al), _P(tp_), 200.0 * ck * _f)


func _die_burst(g: Vector2, u: float, seed_: int, amp: float) -> void :
	var stx: Texture2D = TpArt.tex("fx_star")
	var dk: float = die_w / 30.0
	var al: float = pow(1.0 - u, 1.2)
	draw_set_transform_matrix(_cam)
	for j in range(5):
		var ang: float = PI * (1.08 + 0.84 * (j + 0.5) / 5.0) + 0.18 * sin(seed_ * 3.1 + j * 1.7)
		var r: float = (8.0 + 30.0 * u * amp) * dk
		var p: Vector2 = g + Vector2(cos(ang) * r, sin(ang) * r * 0.62 + 26.0 * u * u * dk * amp)
		if stx != null:
			var sz: float = die_w * 0.36 * (1.0 - 0.45 * u) * (0.7 + 0.3 * amp) * _f
			draw_texture_rect(stx, Rect2(_P(p) - Vector2(sz, sz) * 0.5, Vector2(sz, sz)), false, Color(1.0, 0.93, 0.6, al))
		else:
			draw_circle(_P(p), 2.5 * dk * _f, Color(1.0, 0.88, 0.4, al), true, -1.0, true)


func _die_sparks(at: Vector2, now: float, k: int) -> void :
	var st: Texture2D = TpArt.tex("fx_star")
	if st == null:
		return
	draw_set_transform_matrix(_cam)
	for j in range(3):
		var a: float = now / 140.0 + j * TAU / 3.0 + k * 1.1
		var p: Vector2 = at + Vector2(cos(a) * die_w * 0.72, sin(a) * die_w * 0.36)
		var sz: float = die_w * (0.42 + 0.14 * sin(now / 90.0 + j * 2.0)) * _f
		draw_texture_rect(st, Rect2(_P(p) - Vector2(sz, sz) * 0.5, Vector2(sz, sz)), false, Color(1, 1, 1, 0.9))


func _gauge(rc: Vector2, holding: bool) -> void :
	var now: float = now_ms()
	var blink: bool = zone_hit >= 0 and now - zone_at < 600.0
	if not holding and not blink:
		return
	var start: float = space_at if space_at >= 0.0 else hold_at
	var held: float = now - start if holding and start >= 0.0 else 0.0
	var gk: float = _ck() * 1.3
	if _gauge_art(rc, holding, held, blink, gk):
		return
	var rad: float = 64.0 * gk
	var mid: Vector2 = rc + Vector2(0, -4)
	var c: Vector2 = _P(mid)
	draw_arc(c, rad * _f, PI, TAU, 48, Color(0, 0, 0, 0.55), 30.0 * gk * _f, true)
	var cur: int = zone_of(held) if holding else -1
	for z in range(4):
		var a0: float = PI + PI * z / 4.0
		var a1: float = PI + PI * (z + 1) / 4.0
		var col: Color = Color(str(ZONE_COL[z]))
		var on: bool = (blink and z == zone_hit and int(now / 100.0) % 2 == 0) or z == cur
		draw_arc(c, rad * _f, a0 + 0.02, a1 - 0.02, 14, col.lightened(0.35) if on else Color(col, 0.8), (26.0 if on else 22.0) * gk * _f, true)
		var am: float = (a0 + a1) / 2.0
		var lp: Vector2 = mid + Vector2(cos(am), sin(am)) * rad
		_w("%d–%d" % [int(ZONES[z][0]), int(ZONES[z][1])], 10.0 * gk, ON_GOLD if on else Color(0.05, 0.1, 0.2, 0.9), "c", lp.x, lp.y, 44, BOLD)
	if holding:
		var ang: float = PI + needle(held) * PI
		var dir: Vector2 = Vector2(cos(ang), sin(ang))
		var side: Vector2 = Vector2( - dir.y, dir.x)
		var tip: Vector2 = c + dir * (rad - 15.0 * gk) * _f
		var base: Vector2 = c + dir * (rad + 20.0 * gk) * _f

		draw_colored_polygon(PackedVector2Array([tip - dir * 2.0 * gk * _f, base + side * 8.0 * gk * _f, base - side * 8.0 * gk * _f]), Color(0, 0, 0, 0.75))
		draw_colored_polygon(PackedVector2Array([tip, base + side * 5.5 * gk * _f - dir * 1.5 * _f, base - side * 5.5 * gk * _f - dir * 1.5 * _f]), Color.WHITE)



func _gauge_art(rc: Vector2, holding: bool, held: float, blink: bool, gk: float) -> bool:
	var dim: Texture2D = TpArt.tex("arc_dim")
	var lit: Texture2D = TpArt.tex("arc_lit")
	if dim == null or lit == null:
		return false
	var now: float = now_ms()
	var k: float = _ck() * 1.5
	var ro: float = ARC_R * k
	var gin: float = float(TpArt.META.get("a_in", 0.86))
	var c: Vector2 = _P(rc + Vector2(0, ARC_DY * k))
	var r: Rect2 = Rect2(c - Vector2(ro, ro) * _f, Vector2(ro * 2.0, ro) * _f)
	var a0: float = PI + ARC_GAP
	var a1: float = TAU - ARC_GAP
	var fill: float = needle(held) if holding else (zone_hit + 1) / 4.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var edge: PackedVector2Array = _wedge_pts(c, ro, a0, a1, a0, a1, 0.035)
	edge.append(edge[0])
	draw_polyline(edge, Color(0.07, 0.03, 0.02, 0.85), maxf(1.2, 1.5 * k * _f), true)
	_wedge(c, ro, gin, a0, a1, a0, a1, dim, r, Color.WHITE)
	var fl: float = 1.08 if holding or int(now / 110.0) % 2 == 0 else 1.35
	if fill > 0.0:
		_wedge(c, ro, gin, a0, a1, a0, lerpf(a0, a1, fill), lit, r, Color(fl, fl, fl))

	for z in range(1, 4):
		var ab: float = lerpf(a0, a1, z / 4.0)
		var d: Vector2 = Vector2(cos(ab), sin(ab))
		draw_line(c + d * ro * (1.0 - _wedge_w(z / 4.0)) * _f, c + d * ro * _f, Color(0.05, 0.02, 0.0, 0.35), maxf(1.0, 0.8 * k * _f), true)
	if fill > 0.0:
		var at: float = lerpf(a0, a1, fill)
		var tp: Vector2 = c + Vector2(cos(at), sin(at)) * ro * (1.0 - _wedge_w(fill) * 0.5) * _f
		var st: Texture2D = TpArt.tex("fx_star")
		if st != null:
			var sw: float = ro * (0.36 + 0.05 * sin(now / 70.0)) * _f
			draw_set_transform(tp, now / 400.0, Vector2.ONE)
			draw_texture_rect(st, Rect2( - Vector2(sw, sw) * 0.5, Vector2(sw, sw)), false, Color(1, 1, 1, 0.95))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		else:
			draw_circle(tp, ro * _wedge_w(fill) * 0.4 * _f, Color(1, 1, 0.85, 0.9), true, -1.0, true)

	var cur: int = zone_of(held) if holding else zone_hit
	for z in range(4):
		var am: float = lerpf(a0, a1, (z + 0.5) / 4.0)
		var lp: Vector2 = c + Vector2(cos(am), sin(am)) * ro * (1.0 + ARC_LBL) * _f
		var on: bool = z == cur
		_ink("%d-%d" % [int(ZONES[z][0]), int(ZONES[z][1])], (9.5 if on else 8.0) * k, Color("fff1a8") if on else Color(1, 1, 1, 0.88), Color(0.1, 0.04, 0.02, 0.85), lp, ro * 0.4 * _f)
	return true


func _wedge_w(u: float) -> float:
	return lerpf(ARC_W0, ARC_W1, clampf(u, 0.0, 1.0))


func _wedge_pts(c: Vector2, ro: float, A0: float, A1: float, a0: float, a1: float, pad: float = 0.0) -> PackedVector2Array:
	var n: int = maxi(3, int(ceil((a1 - a0) / 0.05)))
	var pts: PackedVector2Array = PackedVector2Array()
	for j in range(n + 1):
		var a: float = lerpf(a0, a1, j / float(n))
		pts.append(c + Vector2(cos(a), sin(a)) * ro * (1.0 + pad) * _f)
	for j in range(n, -1, -1):
		var a: float = lerpf(a0, a1, j / float(n))
		var w: float = _wedge_w((a - A0) / (A1 - A0))
		pts.append(c + Vector2(cos(a), sin(a)) * ro * (1.0 - w - pad) * _f)
	return pts


func _wedge(c: Vector2, ro: float, gin: float, A0: float, A1: float, a0: float, a1: float, tex: Texture2D, r: Rect2, mod: Color) -> void :
	if a1 - a0 < 0.004:
		return
	var n: int = maxi(3, int(ceil((a1 - a0) / 0.05)))
	var pts: PackedVector2Array = _wedge_pts(c, ro, A0, A1, a0, a1)
	var uvs: PackedVector2Array = PackedVector2Array()
	for j in range(n + 1):
		var a: float = lerpf(a0, a1, j / float(n))
		uvs.append(((c + Vector2(cos(a), sin(a)) * ro * 0.995 * _f - r.position) / r.size).clamp(Vector2.ZERO, Vector2.ONE))
	for j in range(n, -1, -1):
		var a: float = lerpf(a0, a1, j / float(n))
		uvs.append(((c + Vector2(cos(a), sin(a)) * ro * (gin + 0.005) * _f - r.position) / r.size).clamp(Vector2.ZERO, Vector2.ONE))
	draw_colored_polygon(pts, mod, uvs, tex)


func _coin(p: Vector2, r: float, a: float) -> void :
	draw_circle(_P(p), r * _f, Color("9a6a08", a), true, -1.0, true)
	draw_circle(_P(p) - Vector2(0, 0.15 * r * _f), r * 0.82 * _f, Color("ffd34d", a), true, -1.0, true)
	draw_circle(_P(p) - Vector2(0.3 * r, 0.45 * r) * _f, r * 0.25 * _f, Color(1, 1, 1, 0.5 * a), true, -1.0, true)


func _tw(text: String, px: float, font: Font = SEMI) -> float:
	return _measure(text, font, px * 2.0) * _u / _f


func _clip(text: String, px: float, width: float, font: Font = SEMI) -> String:
	if _tw(text, px, font) <= width:
		return text
	var t: String = text
	while t.length() > 1 and _tw(t + "…", px, font) > width:
		t = t.left(-1)
	return t + "…"


func _wrap(text: String, px: float, width: float, most: int, font: Font = SEMI) -> Array:
	var out: Array = []
	var cur: String = ""
	var cut: bool = false
	for word: String in text.split(" ", false):
		if out.size() >= most:
			cut = true
			break
		var t: String = word if cur.is_empty() else cur + " " + word
		if cur.is_empty() or _tw(t, px, font) <= width:
			cur = t
		else:
			out.append(cur)
			cur = word
	if not cur.is_empty():
		if out.size() < most:
			out.append(cur)
		else:
			cut = true
	for k in range(out.size()):
		out[k] = _clip(str(out[k]) + ("…" if cut and k == out.size() - 1 else ""), px, width, font)
	return out


func _parity_btn(id: String, text: String, c: Vector2, ok: bool) -> void :
	if _parity_art(id, text, c, ok):
		return
	var chosen: bool = parity == id
	var lit: bool = ok and _hover == id and _press.is_empty()
	var k: float = _ck() * 1.35
	draw_circle(_P(c + Vector2(0, 3.0 * k)), 23.0 * k * _f, Color(0, 0, 0, 0.4), true, -1.0, true)
	var rim: Color = Color("ffb630") if chosen else Color("8a93a6")
	draw_circle(_P(c), 23.0 * k * _f, rim.darkened(0.35), true, -1.0, true)
	var face: Color = Color("ffc540") if chosen else (Color("41acf5") if ok else Color("6a7282"))
	if lit:
		face = face.lightened(0.12)
	draw_circle(_P(c), 20.0 * k * _f, face, true, -1.0, true)
	draw_circle(_P(c - Vector2(0, 7.0 * k)), 12.0 * k * _f, Color(1, 1, 1, 0.18), true, -1.0, true)
	_w(text, 12.5 * k, ON_GOLD if chosen else (ON_BLUE if ok else Color(CREAM, 0.6)), "c", c.x, c.y, 60.0 * k, BOLD)
	if ok:
		var hr: float = maxf(24.0 * k, 24.0)
		_hit(id, _R(c.x - hr, c.y - hr, hr * 2.0, hr * 2.0), false)



func _parity_art(id: String, text: String, c: Vector2, ok: bool) -> bool:
	var chosen: bool = parity == id
	var down: bool = ok and _press == id
	var nm: String = "pb_s" if chosen else ((("pb_d" if TpArt.tex("pb_d") != null else "pb_x")) if not ok else ("pb_p" if down and TpArt.tex("pb_p") != null else "pb_n"))
	var tex: Texture2D = TpArt.tex(nm)
	if tex == null:
		return false
	var lit: bool = ok and _hover == id and _press.is_empty()
	var k: float = _ck() * 1.35
	var wide: float = PB_W * k
	var tall: float = wide * tex.get_height() / float(tex.get_width())
	var foot: Vector2 = c + Vector2(0, tall * PB_FACE)
	var dsk: float = 3.0 if nm == "pb_d" else 0.0
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_texture_rect(tex, Rect2(_P(foot) - Vector2(wide / 2.0, tall - dsk) * _f, Vector2(wide, tall - dsk) * _f), false, Color(1.1, 1.1, 1.1) if lit else Color.WHITE)
	var rim: Color = Color("0b4f6e") if ok or chosen else Color("06303d", 0.7)
	var ty: float = c.y + (2.0 * k if down or chosen else 0.0) + dsk
	_ink(text, 15.0 * k, Color.WHITE if ok or chosen else Color(1, 1, 1, 0.7), Color(rim, rim.a * 0.95), _P(Vector2(c.x, ty)), wide * 0.72 * _f)
	var tg: Texture2D = TpArt.tex("tagd")
	var fee: String = "%s Bạc" % _k8(str(game.get("pfee", "100")).to_int())
	var tc: Vector2 = c - Vector2(0, tall * (1.0 - PB_FACE) + 8.0 * k)
	if tg != null:
		var tw: float = wide * 0.62
		var th: float = tw * tg.get_height() / float(tg.get_width())
		draw_texture_rect(tg, Rect2(_P(tc) - Vector2(tw, th) * 0.5 * _f, Vector2(tw, th) * _f), false)
		_ink(fee, 10.0 * k, Color("ffe08a") if chosen else Color.WHITE, Color(0, 0, 0, 0.6), _P(tc), tw * 0.86 * _f)
	else:
		_w(fee, 11.0 * k, Color(CREAM, 0.9), "c", tc.x, tc.y, 90.0 * k, BOLD)
	if ok:
		var hr: float = maxf(wide * 0.45, 24.0)
		_hit(id, _R(c.x - hr, c.y - hr * 0.8, hr * 2.0, hr * 1.6), false)
	return true


func _roll_btn(c: Vector2, ok: bool) -> void :
	if _roll_btn_art(c, ok):
		return
	var lit: bool = ok and _hover == "roll" and _press.is_empty()
	var down: bool = ok and _press == "roll"
	var k: float = _ck() * 1.5
	var lift: float = 0.0 if down else 4.0 * k
	var sq: Vector2 = Vector2(1.0, 0.64)
	draw_set_transform(_P(c), 0.0, sq)
	draw_arc(Vector2.ZERO, 52.0 * k * _f, 0, TAU, 64, Color(0, 0, 0, 0.45), 8.0 * k * _f, true)
	if playing():
		var frac: float = clampf(turn_left_ms() / (turn_s * 1000.0), 0.0, 1.0)
		var col: Color = Color("4cd964") if frac > 0.5 else (Color("ffd23f") if frac > 0.25 else Color("ff4b3e"))
		if frac > 0.0:
			draw_arc(Vector2.ZERO, 52.0 * k * _f, - PI / 2.0, - PI / 2.0 + TAU * frac, 64, col, 5.0 * k * _f, true)
	draw_circle(Vector2(0, 6.0 * k * _f), 42.0 * k * _f, Color(0, 0, 0, 0.4), true, -1.0, true)
	draw_circle(Vector2.ZERO, 41.0 * k * _f, Color("8a2a06") if ok else Color("3a3f4a"), true, -1.0, true)
	draw_set_transform(_P(c - Vector2(0, lift)), 0.0, sq)
	var face: Color = Color("ff7a2a") if ok else Color("6a7282")
	if lit:
		face = face.lightened(0.1)
	draw_circle(Vector2.ZERO, 39.0 * k * _f, face.darkened(0.15), true, -1.0, true)
	draw_circle(Vector2(0, -4.0 * k * _f), 34.0 * k * _f, face, true, -1.0, true)
	draw_circle(Vector2(0, -16.0 * k * _f), 21.0 * k * _f, Color(1, 1, 1, 0.16), true, -1.0, true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_w("ĐỔ", 19.0 * k, ON_GOLD if ok else Color(CREAM, 0.6), "c", c.x, c.y - lift - 2.0 * k, 80.0 * k, BOLD)
	if ok:
		_hit("roll", _R(c.x - 42.0 * k, c.y - 28.0 * k, 84.0 * k, 56.0 * k), false)



func _roll_btn_art(c: Vector2, ok: bool) -> bool:
	var lit: bool = ok and _hover == "roll" and _press.is_empty()
	var down: bool = ok and _press == "roll"
	var tex: Texture2D = TpArt.tex((("roll_d" if TpArt.tex("roll_d") != null else "roll_x") if not ok else ("roll_p" if down else "roll_n")))
	if tex == null:
		return false
	var k: float = _ck() * 1.5
	var now: float = now_ms()
	var wide: float = RD_W * k
	var tall: float = wide * tex.get_height() / float(tex.get_width())
	var foot: Vector2 = c + Vector2(0, tall * RD_FACE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var halo: Texture2D = TpArt.tex("halo")

	if ok and halo != null and gfx_level() >= 1:
		var br: float = 0.5 + 0.5 * sin(now / 650.0)
		var hw: float = wide * (1.22 + 0.08 * br)
		var hh: float = hw * 0.4
		var bcn: Vector2 = foot - Vector2(0, tall * 0.2)
		draw_texture_rect(halo, Rect2(_P(bcn) - Vector2(hw, hh) * 0.5 * _f, Vector2(hw, hh) * _f), false, Color(1, 1, 1, 0.2 + 0.25 * br))

	var dsk: float = 3.5 if not ok else 0.0
	draw_texture_rect(tex, Rect2(_P(foot) - Vector2(wide / 2.0, tall - dsk) * _f, Vector2(wide, tall - dsk) * _f), false, Color(1.08, 1.08, 1.08) if lit else Color.WHITE)
	var ty: float = c.y + (RD_SINK * tall if down else 0.0) + dsk
	if _sum_q.is_empty():
		_ink("ĐỔ", 27.0 * k, Color.WHITE if ok else Color(1, 1, 1, 0.7), Color("8e1a12", 0.95) if ok else Color("3a0d0a", 0.7), _P(Vector2(c.x, ty)), wide * 0.55 * _f)
	if ok:
		_hit("roll", _R(c.x - wide * 0.46, c.y - tall * 0.4, wide * 0.92, tall * 0.8), false)
	return true


func _choice_box(ph: String, line: String) -> void :
	if _choice_art(ph, line):
		return
	var me: Dictionary = _me()
	var pos: int = str(me.get("pos", "0")).to_int()
	var info: Array = BOARD[pos]
	var ck: float = _ck()
	var cx: float = bc.x
	var bh: float = _tap(36.0 * ck)
	var r: Rect2 = Rect2(cx - 170.0 * ck, bc.y - 10.0 * ck, 340.0 * ck, 92.0 * ck + bh)
	_round(_R(r.position.x + 3.0, r.position.y + 5.0, r.size.x, r.size.y), Color(0, 0, 0, 0.35), 16.0)
	_grad(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color("16427a", 0.98), Color("0b2650", 0.98), Color(GOLD, 0.85), 16.0, 2.0)
	var cash: int = str(me.get("cash", "0")).to_int()
	var cy: float = r.position.y
	var tw: float = r.size.x - 20.0
	_w(line, 14.0 * ck, GOLD, "c", cx, cy + 17.0 * ck, tw, BOLD)
	draw_line(_P(Vector2(r.position.x + 16.0, cy + 31.0 * ck)), _P(Vector2(r.end.x - 16.0, cy + 31.0 * ck)), Color(GLASS_EDGE, 0.35), maxf(1.0, _f))
	var by: float = cy + 84.0 * ck
	var bw: float = 150.0 * ck
	if ph == "buy":
		_w("Mua %s?" % str(info[0]), 19.0 * ck, Color.WHITE, "c", cx, cy + 49.0 * ck, tw, BOLD)
		_w("Giá %s · tiền mặt %s" % [num(_price8(pos)), num(cash)], 14.5 * ck, CREAM, "c", cx, cy + 71.0 * ck, tw)
		_btn("buy", "Mua", Rect2(cx - bw - 6.0 * ck, by, bw, bh), cash >= _price8(pos), 17.0 * ck)
	elif ph == "build":
		var h: int = str(game.get("tiles", {}).get(pos, {}).get("h", "0")).to_int()
		var hc: int = str(game.get("hc", "0")).to_int()
		_w("Xây nhà cấp %d ở %s?" % [h + 1, str(info[0])], 19.0 * ck, Color.WHITE, "c", cx, cy + 49.0 * ck, tw, BOLD)
		_w("Giá %s · tiền mặt %s" % [num(hc), num(cash)], 14.5 * ck, CREAM, "c", cx, cy + 71.0 * ck, tw)
		_btn("build", "Xây", Rect2(cx - bw - 6.0 * ck, by, bw, bh), cash >= hc, 17.0 * ck)
	else:
		_w("Mở Lễ Hội", 19.0 * ck, Color.WHITE, "c", cx, cy + 49.0 * ck, tw, BOLD)
		_w("Bấm một ô đất của bạn (ô sáng cam)", 14.5 * ck, CREAM, "c", cx, cy + 71.0 * ck, tw)
	_btn("skip", "Bỏ qua", Rect2(cx + 6.0 * ck if ph != "fest" else cx - bw / 2.0, by, bw, bh), true, 17.0 * ck, "gray")



const PANEL_SLOT: Vector3 = Vector3(0.177, 0.584, 0.113)
const PANEL_RIB: Vector3 = Vector3(0.49, 0.13, 0.46)
const PANEL_TXT: Vector2 = Vector2(0.335, 0.955)

func _choice_art(ph: String, line: String) -> bool:
	if TpArt.tex("av0") != null or ph == "take":
		_choice_lv(ph)
		return true
	var pn: Texture2D = TpArt.tex("panel")
	if pn == null:
		return false
	var me: Dictionary = _me()
	var pos: int = str(me.get("pos", "0")).to_int()
	var info: Array = BOARD[pos]
	var ck: float = _ck()
	var now: float = now_ms()
	var pw: float = 420.0 * ck
	var ph_: float = pw * pn.get_height() / float(pn.get_width())
	var x0: float = bc.x - pw / 2.0
	var y0: float = bc.y - 24.0 * ck
	draw_texture_rect(pn, _R(x0, y0, pw, ph_), false)
	var cash: int = str(me.get("cash", "0")).to_int()
	var head: String = "Lễ Hội" if ph == "fest" else str(info[0])
	_ink(head, 17.0 * ck, Color.WHITE, Color("7a0c12", 0.95), _P(Vector2(x0 + pw * PANEL_RIB.x, y0 + ph_ * PANEL_RIB.y)), pw * PANEL_RIB.z * _f)

	var sc: Vector2 = Vector2(x0 + pw * PANEL_SLOT.x, y0 + ph_ * PANEL_SLOT.y)
	var sr: float = pw * PANEL_SLOT.z
	var bob: float = 2.0 * ck * sin(now / 300.0)
	if ph == "build":
		var h: int = str(game.get("tiles", {}).get(pos, {}).get("h", "0")).to_int()
		var nm: String = _bname(h + 1)
		var tx: Texture2D = TpArt.tex(nm)
		if tx != null:
			var wd: float = sr * (1.75 if h + 1 >= 3 else 1.55)
			_sprite(nm, _P(sc + Vector2(0, sr * 0.62 + bob)), wd * _f)
			if TpArt.tex(nm + "_r") != null:
				_sprite(nm + "_r", _P(sc + Vector2(0, sr * 0.62 + bob)), wd * _f, Color(str(PLAYER_COL[int(game.get("me", 0)) % 4])).lightened(0.1))
	else:
		_sprite("deed", _P(sc + Vector2(0, bob)), sr * 1.6 * _f, Color.WHITE, true)
	var tx0: float = x0 + pw * PANEL_TXT.x
	var tx1: float = x0 + pw * PANEL_TXT.y
	var tcx: float = (tx0 + tx1) / 2.0
	var tw: float = tx1 - tx0
	var ink: Color = Color("3a2412")
	_w(line, 12.0 * ck, Color("8a5a2a"), "c", tcx, y0 + ph_ * 0.33, tw, SEMI)
	var bw: float = 112.0 * ck
	var bh: float = maxf(bw * 0.4, _tap(36.0 * ck))
	var by: float = y0 + ph_ * 0.885 - bh
	if ph == "buy":
		_w("Mua %s?" % str(info[0]), 18.0 * ck, ink, "c", tcx, y0 + ph_ * 0.46, tw, BOLD)
		_w("Giá %s · tiền mặt %s" % [num(_price8(pos)), num(cash)], 13.5 * ck, Color("6a4524"), "c", tcx, y0 + ph_ * 0.58, tw)
		_art_btn("buy", "Mua", Rect2(tcx - bw - 6.0 * ck, by, bw, bh), cash >= _price8(pos), 17.0 * ck, "bt_g")
	elif ph == "build":
		var h: int = str(game.get("tiles", {}).get(pos, {}).get("h", "0")).to_int()
		var hc: int = str(game.get("hc", "0")).to_int()
		_w(("Lên khách sạn?" if h + 1 >= 3 else "Xây nhà cấp %d?" % (h + 1)), 18.0 * ck, ink, "c", tcx, y0 + ph_ * 0.46, tw, BOLD)
		_w("Giá %s · tiền mặt %s" % [num(hc), num(cash)], 13.5 * ck, Color("6a4524"), "c", tcx, y0 + ph_ * 0.58, tw)
		_art_btn("build", "Xây", Rect2(tcx - bw - 6.0 * ck, by, bw, bh), cash >= hc, 17.0 * ck, "bt_g")
	else:
		_w("Mở Lễ Hội", 18.0 * ck, ink, "c", tcx, y0 + ph_ * 0.46, tw, BOLD)
		_w("Bấm một ô đất của bạn (ô sáng cam)", 13.5 * ck, Color("6a4524"), "c", tcx, y0 + ph_ * 0.58, tw)
	_art_btn("skip", "Bỏ qua", Rect2(tcx + 6.0 * ck if ph != "fest" else tcx - bw / 2.0, by, bw, bh), true, 16.0 * ck, "bt_b")
	return true



const HOUSE_MUL: Array = [0.2, 0.8, 1.8, 3.2]
const LV_NAME: Array = ["Đất", "Nhà 1", "Nhà 2", "Khách sạn"]



func _choice_lv(ph: String) -> void :
	var me: Dictionary = _me()
	var mi: int = int(game.get("me", 0))
	var pos: int = str(me.get("pos", "0")).to_int()
	var info: Array = BOARD[pos]
	var ck: float = _ck()
	var now: float = now_ms()
	var cash: int = str(me.get("cash", "0")).to_int()
	var t: Dictionary = game.get("tiles", {}).get(pos, {})
	var h: int = str(t.get("h", "0")).to_int() if not t.is_empty() else -1
	var price: int = _price8(pos)
	var hc: int = str(game.get("hc", "0")).to_int()
	var fest: bool = ph == "fest"
	var pw: float = 470.0 * ck
	var chh: float = 156.0 * ck
	var phh: float = 118.0 * ck if fest else 48.0 * ck + chh + 10.0 * ck + _tap(44.0 * ck) + 12.0 * ck + (36.0 * ck if ph == "take" else 0.0)
	var x0: float = bc.x - pw / 2.0
	var y0: float = bc.y - (40.0 if fest else 6.0) * ck
	var col: Color = Color(str(PLAYER_COL[mi % 4]))
	_round(_R(x0 + 3.0, y0 + 6.0, pw, phh), Color(0, 0, 0, 0.4), 16.0)
	_grad(_R(x0, y0, pw, phh), Color("16427a", 0.97), Color("0b2650", 0.97), Color(GOLD, 0.8), 16.0, 2.0)
	var head: String = "Mở Lễ Hội" if fest else ("Mua đất · %s" % str(info[0]) if ph == "buy" else "Xây nhà · %s" % str(info[0]))
	if ph == "take":
		head = "Mua lại · %s" % str(info[0])
	_ink(head, 19.0 * ck, Color.WHITE, Color("06142c", 0.95), _P(Vector2(bc.x, y0 + 21.0 * ck)), (pw - 30.0 * ck) * _f)
	draw_line(_P(Vector2(x0 + 16.0, y0 + 38.0 * ck)), _P(Vector2(x0 + pw - 16.0, y0 + 38.0 * ck)), Color(GLASS_EDGE, 0.35), maxf(1.0, _f))
	var bh: float = _tap(44.0 * ck)
	var by: float = y0 + phh - bh - 12.0 * ck
	if fest:
		_w("Bấm một ô đất của bạn (ô sáng cam) để nhân đôi tiền thuê", 14.0 * ck, CREAM, "c", bc.x, y0 + 56.0 * ck, pw - 24.0 * ck)
		_sub_btn("skip", "Bỏ qua", Rect2(bc.x - 60.0 * ck, by + 4.0 * ck, 120.0 * ck, bh - 8.0 * ck), 15.0 * ck)
		return
	var want: int = 0 if ph == "buy" else (h if ph == "take" else h + 1)
	var gap: float = 8.0 * ck
	var cw: float = (pw - 28.0 * ck - 3.0 * gap) / 4.0
	var cy: float = y0 + 48.0 * ck
	for lv in range(4):
		var cx0: float = x0 + 14.0 * ck + lv * (cw + gap)
		var lit: bool = lv == want
		var done: bool = lv < want
		if lit:
			var gl: float = 0.5 + 0.5 * sin(now / 260.0)
			_round(_R(cx0 - 4.0, cy - 4.0, cw + 8.0, chh + 8.0), Color(1.0, 0.78, 0.25, 0.22 + 0.18 * gl), 13.0)


		_grad(_R(cx0, cy, cw, chh), Color("eef6ff" if lit else "d9e9fb", 0.98), Color("c6dcf5" if lit else "a9c8ec", 0.98), 
			Color(GOLD, 0.95) if lit else Color("e3f1ff", 0.55), 11.0, 2.5 if lit else 1.0)
		_lip(_R(cx0, cy, cw, chh), 0.6, 11.0)
		var locked: bool = not (lit or done)
		_w(str(LV_NAME[lv]), 13.5 * ck, Color("1d3c6b"), "c", cx0 + cw / 2.0, cy + 13.0 * ck, cw - 8.0, BOLD)
		var sy: float = cy + chh - 37.0 * ck
		var foot: Vector2 = Vector2(cx0 + cw / 2.0, sy - 4.0 * ck)
		if lv == 0:
			_sprite("pl_g" if lit else ("pl%d" % (mi % 4) if done else "pl_e"), _P(foot - Vector2(0, 22.0 * ck)), cw * 0.72 * _f, Color.WHITE, true)
		else:


			var bn: String = "%s_%d" % [_bname(lv), mi % 4]
			var btex: Texture2D = TpArt.tex(bn)
			var room: float = sy - 4.0 * ck - (cy + 22.0 * ck)
			if btex != null:
				var ub: Array = TpArt.META.get("ub_" + bn, [0, 0, btex.get_width(), btex.get_height()])
				var ur: Rect2 = Rect2(float(ub[0]), float(ub[1]), float(ub[2]), float(ub[3]))
				var hf: float = [0.0, 0.55, 0.75, 0.95][lv]
				var sc: float = minf(hf * room / ur.size.y, cw * 0.9 / ur.size.x)
				var dsz: Vector2 = ur.size * sc * _f
				var fp: Vector2 = _P(foot)
				draw_texture_rect_region(btex, Rect2(fp - Vector2(dsz.x / 2.0, dsz.y), dsz), ur)
			else:
				_building(_bname(lv), foot, cw * (0.56 if lv < 3 else 0.62), col)
		var cost: int = price if lv == 0 else hc
		var rent: int = _rent8(pos, lv, price)
		_round(_R(cx0 + 4.0 * ck, sy, cw - 8.0 * ck, 33.0 * ck), Color(0.04, 0.1, 0.24, 0.92), 8.0)
		if done or (lit and ph == "take"):
			_w("Kèm theo" if ph == "take" else "Đã có", 12.5 * ck, GREEN, "c", cx0 + cw / 2.0, sy + 10.0 * ck, cw - 12.0, BOLD)
		elif ph == "take":
			_w("Chưa có", 12.5 * ck, Color(0.62, 0.66, 0.74), "c", cx0 + cw / 2.0, sy + 10.0 * ck, cw - 12.0, BOLD)
		else:
			_w(("Giá %s" if lv == 0 else "Xây %s") % num(cost), 12.5 * ck, GOLD if lit else Color(GOLD, 0.85), "c", cx0 + cw / 2.0, sy + 10.0 * ck, cw - 12.0, BOLD)
		_w("Thuê %s" % num(rent), 12.0 * ck, CREAM, "c", cx0 + cw / 2.0, sy + 24.0 * ck, cw - 12.0)
		if locked:

			_round(_R(cx0, cy, cw, chh), Color(0.02, 0.06, 0.16, 0.25), 11.0)
			if TpArt.tex("lock") != null:
				_sprite("lock", _P(Vector2(cx0 + cw - 13.0 * ck, cy + 34.0 * ck)), 15.0 * ck * _f, Color.WHITE, true)
	if ph == "take":
		_w("Giá mua lại %s · trả cho %s" % [num(str(game.get("tp", "0")).to_int()), _pname(str(game.get("to", "-1")).to_int())], 14.0 * ck, CREAM, "c", bc.x, cy + chh + 12.0 * ck, pw - 24.0 * ck, BOLD)
	var need: int = price if ph == "buy" else (str(game.get("tp", "0")).to_int() if ph == "take" else hc)
	var ok: bool = cash >= need
	var gw: float = 220.0 * ck
	var sw: float = 108.0 * ck
	var gx: float = bc.x - (gw + sw + 12.0 * ck) / 2.0
	_gold_btn("take" if ph == "take" else ("buy" if ph == "buy" else "build"), ("Mua lại · %s" if ph == "take" else ("Mua · %s" if ph == "buy" else "Xây · %s")) % num(need), Rect2(gx, by, gw, bh), ok, 19.0 * ck)
	_sub_btn("skip", "Bỏ qua", Rect2(gx + gw + 12.0 * ck, by + 5.0 * ck, sw, bh - 10.0 * ck), 15.0 * ck)
	if not ok:
		_w("Thiếu Bạc · tiền mặt %s" % num(cash), 12.0 * ck, RED, "c", gx + gw / 2.0, by - 9.0 * ck, gw, BOLD)


func _gold_btn(id: String, text: String, r: Rect2, enabled: bool, px: float) -> void :
	var tex: Texture2D = TpArt.tex("bt_b" if enabled else "bt_x")
	var rect: Rect2 = _R(r.position.x, r.position.y, r.size.x, r.size.y)
	var lit: bool = enabled and _hover == id and _press.is_empty()
	var down: bool = enabled and _press == id
	var dr: Rect2 = rect.grow(-1.5 * _f) if down else rect
	if tex != null:
		draw_texture_rect(tex, dr, false, (Color(1.0, 1.32, 0.62) if enabled else Color.WHITE) * (1.08 if lit else 1.0))
	else:
		_grad(dr, Color("ffd65a"), Color("e09a12"), Color("fff0b0"), 12.0, 2.0)
	_ink(text, px, Color.WHITE if enabled else Color("e4e7ee"), Color("7a3e04", 0.95) if enabled else Color("3c4250", 0.9), dr.get_center() - Vector2(0, dr.size.y * 0.05), dr.size.x * 0.84)
	if enabled:
		_hit(id, rect, false)


func _sub_btn(id: String, text: String, r: Rect2, px: float) -> void :
	var rect: Rect2 = _R(r.position.x, r.position.y, r.size.x, r.size.y)
	var lit: bool = _hover == id and _press.is_empty()
	var dr: Rect2 = rect.grow(-1.0 * _f) if _press == id else rect
	_grad(dr, Color("2a5d9a" if lit else "214c80"), Color("10305c"), Color(GLASS_EDGE, 0.55), 11.0, 1.5)
	_w(text, px, CREAM, "c", r.position.x + r.size.x / 2.0, r.position.y + r.size.y / 2.0, r.size.x - 10.0, BOLD)
	_hit(id, rect, false)


func _art_btn(id: String, text: String, r: Rect2, enabled: bool, px: float, kind: String) -> void :
	var tex: Texture2D = TpArt.tex(kind if enabled else "bt_x")
	if tex == null:
		_btn(id, text, r, enabled, px, "gray" if kind == "bt_b" else "")
		return
	var rect: Rect2 = _R(r.position.x, r.position.y, r.size.x, r.size.y)
	var lit: bool = enabled and _hover == id and _press.is_empty()
	var down: bool = enabled and _press == id
	var dr: Rect2 = rect.grow(-1.5 * _f) if down else rect
	draw_texture_rect(tex, dr, false, Color(1.1, 1.1, 1.1) if lit else Color.WHITE)
	var rim: Color = Color("17641c") if kind == "bt_g" else Color("a8420c")
	if not enabled:
		rim = Color("3c4250")
	_ink(text, px, Color.WHITE if enabled else Color("e4e7ee"), Color(rim, 0.95), dr.get_center() - Vector2(0, dr.size.y * 0.05), dr.size.x * 0.8)
	if enabled:
		_hit(id, rect, false)



func _look(i: int) -> Array:
	var ps: Array = _players()
	if pack == null or look == "sol" or i < 0 or i >= ps.size():
		return []
	var pl: Dictionary = ps[i]
	if look == "pet":
		var key: String = ""
		var item: int = int(pl.get("pt", 0))
		if item > 0:
			var row: Array = pack.pet_of(item)
			key = str(row[0]) if not row.is_empty() else ""
		elif demo_looks:
			key = str(DEMO_PETS[i % 4])
		var fx: Dictionary = pack.effect(key) if not key.is_empty() else {}
		if fx.is_empty():
			return []
		var fr: Dictionary = fx.data.frames[0]
		var rc: Array = fr.rect
		var page: Texture2D = fx.pages[int(fr.get("page", 0))]
		var tag: String = "%s#0" % key
		if not _crop.has(tag):
			_crop[tag] = _alpha_box(page, Rect2(float(rc[0]), float(rc[1]), float(rc[2]), float(rc[3])))
		return [page, _crop[tag]]
	var face: String = ""
	var tk: int = int(pl.get("tk", 0))
	if tk > 0:
		var tag: String = "%d:%s:%s" % [tk, pl.get("tl", "1"), pl.get("tx", "0")]
		if _face_of.has(tag):
			face = _face_of[tag]
		elif pack.garage.is_empty():
			pack.load_garage()
			_hook_pics()
		else:
			if _select_tank == null:
				_select_tank = load("res://ui/select_tank.gd")
			face = str(_select_tank.face_key(pack.garage, pack.index.get("tanks", {}), tk, int(pl.get("tl", 1)), int(pl.get("tx", 0))))
			_face_of[tag] = face
	elif demo_looks:
		face = str(DEMO_TANKS[i % 4])
	if face.is_empty():
		return []
	var path: String = "l/t/%s.webp" % face
	var tex: Texture2D = pack.picture(path)
	if tex == null:
		_hook_pics()
		return []
	if not _crop.has(path):
		_crop[path] = _alpha_box(tex, Rect2(Vector2.ZERO, Vector2(tex.get_size())))
	return [tex, _crop[path]]


func _alpha_box(tex: Texture2D, box: Rect2) -> Rect2:
	var img: Image = tex.get_image()
	if img == null or img.is_empty():
		return box
	if img.is_compressed():
		img.decompress()
	var part: Image = img.get_region(Rect2i(box))
	var q: int = 4
	var w: int = maxi(1, part.get_width() / q)
	var h: int = maxi(1, part.get_height() / q)
	part.resize(w, h, Image.INTERPOLATE_BILINEAR)
	var lo: Vector2i = Vector2i(w, h)
	var hi: Vector2i = Vector2i(-1, -1)
	for y in range(h):
		for x in range(w):
			if part.get_pixel(x, y).a >= 0.45:
				lo = Vector2i(mini(lo.x, x), mini(lo.y, y))
				hi = Vector2i(maxi(hi.x, x), maxi(hi.y, y))
	if hi.x < lo.x + 1 or hi.y < lo.y + 1:
		return box
	var sx: float = box.size.x / float(w)
	var sy: float = box.size.y / float(h)
	return Rect2(box.position + Vector2(lo.x * sx, lo.y * sy), Vector2((hi.x - lo.x + 1) * sx, (hi.y - lo.y + 1) * sy)).intersection(box)


func _hook_pics() -> void :
	if _pic_hooked or pack == null or not pack.has_signal("picture_ready"):
		return
	_pic_hooked = true
	pack.picture_ready.connect( func(_path: String) -> void : queue_redraw())


func _head(i: int, c: Vector2, r: float, col: Color) -> bool:
	var tex: Texture2D = TpArt.tex("av%d" % (i % 4))
	var lk: Array = _look(i)
	if tex == null and lk.is_empty():
		return false
	var pc: Vector2 = _P(c)
	var rr: float = r * _f
	draw_circle(pc + Vector2(1.5, 2.5) * _f, rr + 2.0 * _f, Color(0, 0, 0, 0.4), true, -1.0, true)
	draw_circle(pc, rr, col.darkened(0.3), true, -1.0, true)
	draw_circle(pc - Vector2(rr, rr) * 0.08, rr * 0.9, col, true, -1.0, true)
	draw_circle(pc - Vector2(rr, rr) * 0.3, rr * 0.45, Color(1, 1, 1, 0.14), true, -1.0, true)
	if not lk.is_empty():
		var lt: Texture2D = lk[0]
		var src: Rect2 = lk[1]
		var ts: Vector2 = Vector2(lt.get_size())
		var side: float = minf(maxf(src.size.x, src.size.y) * 0.92, minf(ts.x, ts.y))
		var mid: Vector2 = src.get_center()
		mid = Vector2(clampf(mid.x, side / 2.0, ts.x - side / 2.0), clampf(mid.y, side / 2.0, ts.y - side / 2.0))
		var pts: PackedVector2Array = PackedVector2Array()
		var uvs: PackedVector2Array = PackedVector2Array()
		for k in range(40):
			var d: Vector2 = Vector2.from_angle(TAU * k / 40.0)
			pts.append(pc + d * rr * 0.94)
			uvs.append((mid + d * side * 0.5) / ts)
		var dim: Color = Color(0.55, 0.55, 0.55) if col == Color("666666") else Color.WHITE
		draw_colored_polygon(pts, dim, uvs, lt)
	else:
		draw_texture_rect(tex, Rect2(pc - Vector2(rr, rr), Vector2(rr, rr) * 2.0), false)
	draw_arc(pc, rr, 0, TAU, 40, col.lightened(0.5), maxf(1.5, 2.2 * _f), true)
	return true


func _seat(i: int) -> int:
	var me: int = int(game.get("me", -1))
	var n: int = maxi(1, _players().size())
	return (i - me + n) % n if me >= 0 else i

const CARD: Vector2 = Vector2(320, 84)

func _card_at(seat: int) -> Vector2:
	var w: float = win_size.x
	var h: float = win_size.y
	return [Vector2(w - CARD.x - 8.0, h - CARD.y - 8.0), Vector2(8, h - CARD.y - 8.0), Vector2(8, BAR + 8.0), Vector2(w - CARD.x - 8.0, BAR + 8.0)][seat % 4]


func _card(i: int, seat: int) -> void :
	var p: Dictionary = _players()[i]
	var now: float = now_ms()
	var at: Vector2 = _card_at(seat)
	var sk: float = now - float(shake_at.get(i, -100000.0))
	if sk >= 0.0 and sk < 450.0:
		at.x += 8.0 * sin(sk / 22.0) * (1.0 - sk / 450.0)
	var cw: float = CARD.x
	var ch: float = CARD.y
	var col: Color = Color(str(PLAYER_COL[i % 4]))
	var turn: bool = int(game.get("turn", -1)) == i and playing()
	var out: bool = str(p.get("out", "0")) == "1"
	if turn:
		var glow: float = 0.5 + 0.5 * sin(now_ms() / 180.0)
		_round(_R(at.x - 5.0, at.y - 5.0, cw + 10.0, ch + 10.0), Color(1.0, 0.7, 0.2, 0.25 + 0.3 * glow), 16.0)
	_grad(_R(at.x, at.y, cw, ch), Color("1d3a66", 0.94), Color("0b1d3a", 0.94), col if not out else Color("666666"), 14.0, 3.0 if turn else 2.0)
	_lip(_R(at.x, at.y, cw, ch).grow(-2.0 * _f), 0.3, 14.0)
	if not _head(i, Vector2(at.x + 42.0, at.y + 42.0), 35.0, col if not out else Color("666666")):
		_avatar(str(p.get("av", "0")).to_int(), _R(at.x + 7.0, at.y + 7.0, 70, 70))
		draw_rect(_R(at.x + 7.0, at.y + 71.0, 70, 6), col)
	var nm: String = str(p.get("name", ""))
	if i == int(game.get("me", -1)):
		nm += " (bạn)"
	var tx: float = at.x + 86.0
	var vx: float = at.x + 156.0
	_w(_clip(nm, 17.0, cw - 86.0 - 40.0, BOLD), 17.0, Color.WHITE, "l", tx, at.y + 18.0, cw - 86.0 - 40.0, BOLD)
	if not out and TpArt.tex("av0") != null:

		var rb: Rect2 = Rect2(at.x + cw - 46.0, at.y + 5.0, 40.0, 36.0)
		_round(_R(rb.position.x + 1.0, rb.position.y + 2.0, rb.size.x, rb.size.y), Color(0, 0, 0, 0.35), 9.0)
		_grad(_R(rb.position.x, rb.position.y, rb.size.x, rb.size.y), col.lightened(0.12), col.darkened(0.25), col.lightened(0.45), 9.0, 1.5)
		_ink(str(_rank_of(i)), 27.0, Color.WHITE, Color(col.darkened(0.65), 0.95), _P(rb.get_center()), 34.0 * _f)
	elif not out:
		_w(str(_rank_of(i)), 28.0, Color(GOLD, 0.9), "r", at.x + cw - 10.0, at.y + 20.0, 36, BOLD)
	var tag: String = ""
	var tag_col: Color = MUTED
	if out:
		tag = ""
	elif str(p.get("win", "0")) == "1":
		tag = "THẮNG"
		tag_col = GREEN
	elif str(p.get("away", "0")) == "1":
		tag = "Máy đi thay"
		tag_col = Color("ffd27a")
	elif str(p.get("jail", "0")).to_int() > 0:
		tag = "Côn Đảo"
		tag_col = Color("6fd1c9")
	elif str(p.get("bus", "0")) == "1":
		tag = "Bến Xe"
		tag_col = Color("8fd0ff")
	var tw: float = 0.0 if tag.is_empty() else _tw(tag, 12.0, BOLD) + 12.0
	var vw: float = at.x + cw - 8.0 - (tw + 6.0 if tw > 0.0 else 0.0) - vx
	_w("Tài sản", 15.0, MUTED, "l", tx, at.y + 46.0, 70)
	_w(num(str(p.get("asset", "0")).to_int()), 17.0, GOLD, "l", vx, at.y + 46.0, vw, BOLD)
	_w("Tiền mặt", 15.0, MUTED, "l", tx, at.y + 68.0, 70)
	var cash: int = roundi(float(cash_shown.get(i, float(str(p.get("cash", "0")).to_int()))))
	var cw2: float = _w(num(cash), 17.0, CREAM, "l", vx, at.y + 68.0, vw, BOLD)
	var cd: Array = cash_dir.get(i, [])
	if cd.size() == 2 and int(cd[0]) != 0 and now - float(cd[1]) < 1200.0:
		var upw: bool = int(cd[0]) > 0
		var al: float = clampf((1200.0 - (now - float(cd[1]))) / 300.0, 0.0, 1.0)
		var ax: float = vx + cw2 + 10.0
		var ay: float = at.y + 68.0
		var tri: PackedVector2Array = PackedVector2Array([Vector2(ax, ay - 7.0), Vector2(ax + 7.0, ay + 4.0), Vector2(ax - 7.0, ay + 4.0)]) if upw\
		else PackedVector2Array([Vector2(ax, ay + 7.0), Vector2(ax + 7.0, ay - 4.0), Vector2(ax - 7.0, ay - 4.0)])
		draw_colored_polygon(_poly_px(tri), Color(GREEN if upw else RED, al))
	if out:
		_round(_R(at.x, at.y, cw, ch), Color(0.22, 0.22, 0.24, 0.55), 14.0)
		_stamp(at + CARD / 2.0, now - float(out_at.get(i, -100000.0)))
	if not tag.is_empty():
		var tr: Rect2 = Rect2(at.x + cw - tw - 8.0, at.y + 44.0, tw, 26)
		_round(_R(tr.position.x, tr.position.y, tr.size.x, tr.size.y), Color(0, 0, 0, 0.35), 9.0, Color(tag_col, 0.7), 1.0)
		_w(tag, 12.0, tag_col, "c", tr.get_center().x, tr.get_center().y, tw - 4.0, BOLD)
	_bubble(i, seat, at)


func _stamp(c: Vector2, t: float) -> void :
	var u: float = clampf(t / 300.0, 0.0, 1.0) if t >= 0.0 else 1.0
	var sc: float = 2.2 - 1.2 * u
	var col: Color = Color(0.88, 0.12, 0.12, 0.95 * u)
	draw_set_transform(_P(c), -0.25, Vector2(sc, sc))
	var r: Rect2 = Rect2(Vector2(-64, -16) * _f, Vector2(128, 32) * _f)
	draw_rect(r, col, false, 3.0 * _f)
	draw_rect(r.grow(-4.0 * _f), Color(col, 0.6 * u), false, 1.0 * _f)
	_string("PHÁ SẢN", BOLD, 30.0, col, "c", Vector2.ZERO, 120.0 * _f)
	draw_set_transform_matrix(_cam)


func _bubble(i: int, seat: int, at: Vector2) -> void :
	var b: Dictionary = _bubble_of(i)
	if b.is_empty():
		return
	var emo: bool = str(b["k"]) == "emo"
	var age: float = now_ms() - float(b["at"])
	var life: float = 2000.0 if emo else 3000.0
	var al: float = clampf(minf(age / 120.0, (life - age) / 300.0), 0.0, 1.0)
	var rows: Array = [] if emo else _wrap(str(b["v"]), 14.0, 220.0, 3)
	var bw: float = 80.0
	var bh: float = 80.0
	if not emo:
		var most: float = 30.0
		for ln: String in rows:
			most = maxf(most, _tw(ln, 14.0))
		bw = most + 26.0
		bh = 21.0 * rows.size() + 16.0
	var left: bool = seat == 0 or seat == 3
	var x: float = at.x - bw - 12.0 if left else at.x + CARD.x + 12.0
	var y: float = clampf(at.y + CARD.y / 2.0 - bh / 2.0, BAR + 4.0, win_size.y - bh - 4.0)
	var pop: float = _ease_back(clampf(age / 200.0, 0.0, 1.0))
	var col: Color = Color(str(PLAYER_COL[i % 4]))
	var tip_x: float = at.x - 2.0 if left else at.x + CARD.x + 2.0
	var base_x: float = x + bw - 1.0 if left else x + 1.0
	var cy: float = at.y + CARD.y / 2.0
	draw_colored_polygon(_poly_px(PackedVector2Array([Vector2(base_x, cy - 7.0), Vector2(tip_x, cy), Vector2(base_x, cy + 7.0)])), Color(1, 1, 1, 0.96 * al))
	var r: Rect2 = Rect2(x, y, bw, bh)
	if pop < 0.999:
		var g: Vector2 = r.size * (pop - 1.0) / 2.0
		r = r.grow_individual(g.x, g.y, g.x, g.y)
	_round(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color(1, 1, 1, 0.96 * al), 12.0, Color(col, al), 2.0)
	if emo:
		var tex: Texture2D = _emo_tex(str(b["v"]))
		if tex != null:
			draw_texture_rect(tex, _R(r.position.x + 7.0, r.position.y + 7.0, r.size.x - 14.0, r.size.y - 14.0), false, Color(1, 1, 1, al))
		else:
			_w("…", 16.0, Color(0.2, 0.2, 0.3, al), "c", r.get_center().x, r.get_center().y, 50, BOLD)
		return
	for k in range(rows.size()):
		_w(str(rows[k]), 14.0, Color(0.1, 0.12, 0.2, al), "l", x + 13.0, y + 18.5 + 21.0 * k, bw - 22.0)

func _card_centre(i: int) -> Vector2:
	return _card_at(_seat(i)) + CARD / 2.0


func _draw_floats() -> void :
	var now: float = now_ms()
	for f: Dictionary in floats:
		var t: float = (now - float(f["at"])) / 1600.0
		var d: int = int(f["d"])
		var down: bool = _seat(int(f["i"])) >= 2
		var c: Vector2 = _card_centre(int(f["i"])) + Vector2(0, (1.0 if down else -1.0) * (CARD.y / 2.0 + 12.0 + 26.0 * t))
		_ink(("+%s" if d > 0 else "%s") % num(d), 22.0, Color(GREEN if d > 0 else Color("ff5a4a"), 1.0 - t * t), Color(0.08, 0.03, 0.02, 0.9 * (1.0 - t * t)), _P(c), 140.0 * _f)


func _screen_fx() -> void :
	var now: float = now_ms()
	var low: bool = low_gfx()
	for e: Dictionary in fx:
		var t: float = now - float(e["at"])
		if t < 0.0:
			continue
		match str(e["k"]):
			"pay":
				_fx_pay(e, t, low)
			"cert":
				_fx_cert(e, t)
			"card":
				_fx_card8(e, t)
			"rain":
				_fx_rain(e, t, low)
			"warn":
				_fx_warn(e, t)
	_fx_order(now)


func _fx_pay(e: Dictionary, t: float, low: bool) -> void :
	var ps: Array = _players()
	var ia: int = int(e["a"])
	var ib: int = int(e["b"])
	if ia >= ps.size() or ib >= ps.size():
		return
	var a: Vector2 = _card_centre(ia)
	var b: Vector2 = _card_centre(ib)
	var m: Vector2 = bc
	if not low:
		for j in range(6):
			var u: float = (t - 60.0 * j) / 700.0
			if u < 0.0 or u > 1.0:
				continue
			var p: Vector2 = a * (1.0 - u) * (1.0 - u) + m * 2.0 * u * (1.0 - u) + b * u * u
			_coin(p, 7.0, 1.0 - maxf(0.0, (u - 0.85) / 0.15))
	if t >= 650.0:
		var u: float = clampf((t - 650.0) / 850.0, 0.0, 1.0)
		var al: float = 1.0 - u * u
		var down: bool = _seat(ib) >= 2
		var q: Vector2 = b + Vector2(0, (1.0 if down else -1.0) * (CARD.y / 2.0 + 14.0 + 22.0 * u))
		_ink("+%s" % num(int(e["d"])), 19.0, Color(GREEN, al), Color(0.08, 0.03, 0.02, 0.9 * al), _P(Vector2(q.x + 12.0, q.y)), 140.0 * _f)
		for k in range(3):
			var cp: Vector2 = q + Vector2(-48.0, 6.0 - 4.0 * k)
			draw_set_transform(_P(cp), 0.0, Vector2(1.0, 0.45))
			draw_circle(Vector2.ZERO, 8.0 * _f, Color("9a6a08", al), true, -1.0, true)
			draw_circle(Vector2(0, -2.0 * _f), 8.0 * _f, Color("ffd34d", al), true, -1.0, true)
		draw_set_transform_matrix(_cam)


func _fx_cert(e: Dictionary, t: float) -> void :
	var c: int = int(e["c"])
	var mid: Vector2 = Vector2(win_size.x / 2.0, BAR + (win_size.y - BAR) / 2.0 - 10.0)
	var sc: float = 1.0
	var pos: Vector2 = mid
	if t < 150.0:
		sc = 0.3 + 0.7 * _ease_back(t / 150.0)
	elif t >= 800.0:
		var u: float = clampf((t - 800.0) / 450.0, 0.0, 1.0)
		sc = lerpf(1.0, 0.15, u)
		pos = mid.lerp(tile_mid(c), u * u)
	var al: float = clampf((1250.0 - t) / 150.0, 0.0, 1.0)
	var band: Color = tile_fill(c)
	draw_set_transform(_P(pos), 0.0, Vector2(sc, sc))
	var r: Rect2 = Rect2(Vector2(-100, -60) * _f, Vector2(200, 120) * _f)
	_round(Rect2(r.position + Vector2(3, 5) * _f, r.size), Color(0, 0, 0, 0.35 * al), 12.0)
	_round(r, Color(1.0, 0.97, 0.88, al), 12.0, Color(GOLD, al), 2.5)
	_round(Rect2(r.position + Vector2(6, 6) * _f, Vector2(188, 28) * _f), Color(band, al), 8.0)
	_string("GIẤY CHỦ QUYỀN", BOLD, 22.0, Color(1, 1, 1, al), "c", Vector2(0, -40) * _f, 180.0 * _f)
	_string(str(BOARD[c][0]), BOLD, 32.0, Color(0.23, 0.16, 0.06, al), "c", Vector2(0, -2) * _f, 184.0 * _f)
	_string("Giá %s · chủ %s" % [num(int(e.get("p", _price8(c)))), _pname(int(e["i"]))], SEMI, 21.0, Color(0.36, 0.29, 0.19, al), "c", Vector2(-8, 28) * _f, 160.0 * _f)
	draw_circle(Vector2(76, 38) * _f, 12.0 * _f, Color(0.8, 0.12, 0.1, 0.9 * al), true, -1.0, true)
	draw_arc(Vector2(76, 38) * _f, 8.0 * _f, 0, TAU, 20, Color(1, 0.85, 0.8, 0.8 * al), 1.5 * _f, true)
	draw_set_transform_matrix(_cam)


func _fx_card(e: Dictionary, t: float) -> void :
	var ps: Array = _players()
	var i: int = int(e["i"])
	var luck: bool = str(e["kind"]) == "luck"
	var mid: Vector2 = Vector2(win_size.x / 2.0, BAR + (win_size.y - BAR) / 2.0 - 10.0)
	var start: Vector2 = tile_mid(str(ps[i].get("pos", "0")).to_int() % N) if i >= 0 and i < ps.size() else mid
	var u: float = clampf(t / 350.0, 0.0, 1.0)
	var e2: float = 1.0 - (1.0 - u) * (1.0 - u)
	var pos: Vector2 = start.lerp(mid, e2)
	var sc: float = lerpf(0.25, 1.0, e2)
	var flip: float = 1.0
	var front: bool = t >= 650.0
	if t >= 350.0 and t < 650.0:
		var f: float = (t - 350.0) / 300.0
		flip = absf(cos(PI * f))
		front = f > 0.5
	var al: float = clampf((2200.0 - t) / 400.0, 0.0, 1.0)
	var col: Color = Color("8a3fd1") if luck else Color("2a7de1")
	draw_set_transform(_P(pos), 0.0, Vector2(sc * maxf(0.04, flip), sc))
	var r: Rect2 = Rect2(Vector2(-85, -110) * _f, Vector2(170, 220) * _f)
	_round(Rect2(r.position + Vector2(4, 6) * _f, r.size), Color(0, 0, 0, 0.35 * al), 14.0)
	if not front:
		_grad(r, Color(col.lightened(0.15), al), Color(col.darkened(0.35), al), Color(GOLD, al), 14.0, 3.0)
		_sprite("luck" if luck else "chance", Vector2(0, -6) * _f, 110.0 * _f, Color(1, 1, 1, al), true)
		for q: Vector2 in [Vector2(-62, -86), Vector2(62, 86)]:
			_string("?", BOLD, 34.0, Color(1, 1, 1, 0.8 * al), "c", q * _f, 30.0 * _f)
	else:
		draw_rect(r.grow(3.0 * _f), Color(1.0, 0.95, 0.6, 0.35 * al), false, 3.0 * _f)
		_round(r, Color(1.0, 0.98, 0.94, al), 14.0, Color(col, al), 3.0)
		_round(Rect2(r.position + Vector2(5, 5) * _f, Vector2(160, 34) * _f), Color(col, al), 10.0)
		_string("MAY RỦI" if luck else "CƠ HỘI", BOLD, 30.0, Color(1, 1, 1, al), "c", Vector2(0, -88) * _f, 150.0 * _f)
		_sprite("luck" if luck else "chance", Vector2(0, -28) * _f, 86.0 * _f, Color(1, 1, 1, al), true)
		var ink: Color = Color(0.15, 0.17, 0.27)
		if luck:
			ink = Color("1f7a2a") if int(e.get("d", 0)) > 0 else Color("b3261e")
		var rows: Array = _wrap(str(e["t"]), 12.0, 150.0, 3, BOLD)
		for k in range(rows.size()):
			_string(str(rows[k]), BOLD, 24.0, Color(ink, al), "c", Vector2(0, 34.0 + 19.0 * k) * _f, 154.0 * _f)
	draw_set_transform_matrix(_cam)


func _m8() -> bool:
	return str(game.get("pl", "")).split(",").size() == N

func _price8(c: int) -> int:
	var pl: PackedStringArray = str(game.get("pl", "")).split(",")
	if pl.size() == N and c >= 0 and c < N:
		return pl[c].to_int()
	return int(BOARD[c][3])

func _rent8(c: int, lv: int, price: int) -> int:
	var rt: PackedStringArray = str(game.get("rt", "")).split(",")
	if rt.size() == N and c >= 0 and c < N:
		var r4: PackedStringArray = rt[c].split("/")
		if r4.size() == 4 and lv >= 0 and lv < 4:
			return r4[lv].to_int()
	return roundi(price * float(HOUSE_MUL[lv]))


static func _k8(v: int) -> String:
	var a: int = absi(v)
	var s: String = "-" if v < 0 else ""
	if a >= 1000000:
		return s + String.num(a / 1000000.0, 1).trim_suffix(".0").replace(".", ",") + "M"
	if a >= 1000:
		return s + String.num(a / 1000.0, 1).trim_suffix(".0").replace(".", ",") + "k"
	return s + str(a)

func _go8() -> String:
	return "+" + _k8(str(game.get("pg", "0")).to_int()) if _m8() and game.has("pg") else "+300"



const CARD_LIFE8: float = 4000.0
const CARD_HOLD8: float = 1200.0
var _evq8: Array = []
var _hold8: float = 0.0
var _cend8: float = 0.0
var _gate8: float = -1.0
var _memo8: Dictionary = {}

func _walk8(i: int) -> bool:
	if i < 0:
		return false
	if i == dice_from and now_ms() - dice_at < DICE_MS:
		return true
	return (i < paths.size() and not (paths[i] as Array).is_empty()) or (i < hops.size() and not (hops[i] as Array).is_empty())

func _drain8() -> void :
	var now: float = now_ms()
	while not _evq8.is_empty():
		if now < _hold8:
			return
		var e: Dictionary = _evq8[0]
		var k: String = str(e.get("k", ""))
		var i: int = str(e.get("i", "-1")).to_int()
		if k == "card" or k == "luck":
			if _gate8 < 0.0:
				_gate8 = now
			if _walk8(i) and now - _gate8 < 6000.0:
				return
			_gate8 = -1.0
			_hold8 = now + CARD_HOLD8
			_cend8 = now + CARD_LIFE8 - 400.0
		elif k == "dice":
			if now < _cend8:
				return
			if not _memo8.is_empty() and i != int(_memo8["last"]):
				_memo8["n"] = int(_memo8["n"]) + 1
				_memo8["last"] = i
		_evq8.pop_front()
		_event(e)
		if _evq8.is_empty():
			_snap8()


func _snap8() -> void :
	var ps: Array = _players()
	for i in range(mini(ps.size(), shown.size())):
		var pos: int = str(ps[i].get("pos", "0")).to_int()
		if (paths[i] as Array).is_empty() and (hops[i] as Array).is_empty() and roundi(float(shown[i])) % N != pos:
			shown[i] = float(pos)

func _card8(e: Dictionary, i: int, now: float) -> void :
	var luck: bool = str(e.get("k", "")) == "luck"
	var d: int = str(e.get("d", "0")).to_int()
	var c: int = posmod(roundi(float(shown[i])), N) if i >= 0 and i < shown.size() else -1
	var t: String = str(e.get("t", ""))
	fx.append({"k": "card", "kind": "luck" if luck else "chance", "t": t, "d": d, "i": i, "c": c, "at": now})
	var body: String = ("%s%s" % ["+" if d > 0 else "-", num(absi(d))]) if luck else t
	_memo8 = {"t": "%s · %s: %s" % ["May Rủi" if luck else "Cơ Hội", _pname(i), body], "at": now + CARD_LIFE8 - 400.0, "n": 0, "last": i, "luck": luck, "d": d}


func _card_up8() -> bool:
	var now: float = now_ms()
	for e: Dictionary in fx:
		if str(e["k"]) == "card" and now - float(e["at"]) < CARD_LIFE8 - 400.0:
			return true
	return false

func _close8() -> void :
	var now: float = now_ms()
	for e: Dictionary in fx:
		if str(e["k"]) == "card" and now - float(e["at"]) < CARD_LIFE8 - 300.0:
			e["at"] = now - (CARD_LIFE8 - 300.0)
	if not _memo8.is_empty():
		_memo8["at"] = minf(float(_memo8["at"]), now)
	_hold8 = 0.0
	_cend8 = 0.0
	_gate8 = -1.0
	var guard: int = 0
	while not _evq8.is_empty() and guard < 64:
		guard += 1
		var e: Dictionary = _evq8.pop_front()
		var k: String = str(e.get("k", ""))
		if k == "dice" and not _memo8.is_empty() and str(e.get("i", "-1")).to_int() != int(_memo8["last"]):
			_memo8["n"] = int(_memo8["n"]) + 1
			_memo8["last"] = str(e.get("i", "-1")).to_int()
		_event(e)
		if k == "card" or k == "luck":
			for f: Dictionary in fx:
				if str(f["k"]) == "card" and float(f["at"]) >= now:
					f["at"] = now - (CARD_LIFE8 - 300.0)
			_memo8["at"] = now
	_snap8()


func _memo8_draw(x: float, cy: float) -> void :
	if _memo8.is_empty() or now_ms() < float(_memo8["at"]) or int(_memo8["n"]) >= 3 or _card_up8():
		return
	var wd: float = clampf(bc.x - x - 190.0, 240.0, 420.0)
	var rows: Array = _wrap(str(_memo8["t"]), 14.0, wd, 2, BOLD)
	var col: Color = Color("ffe9a8")
	if bool(_memo8["luck"]):
		col = Color("8ef09a") if int(_memo8["d"]) > 0 else Color("ff8a7a")
	for k in range(rows.size()):
		var tw: float = _tw(str(rows[k]), 14.0, BOLD)
		_ink(str(rows[k]), 14.0, col, Color(0.03, 0.06, 0.16, 0.95), _P(Vector2(x + tw / 2.0, cy + (k - (rows.size() - 1) / 2.0) * 17.0)), (wd + 6.0) * _f)




func _fx_card8(e: Dictionary, t: float) -> void :
	var ps: Array = _players()
	var i: int = int(e["i"])
	var luck: bool = str(e["kind"]) == "luck"
	var mid: Vector2 = Vector2(win_size.x / 2.0, BAR + (win_size.y - BAR) / 2.0 + 6.0)
	var c0: int = int(e.get("c", -1))
	var start: Vector2 = mid
	if c0 >= 0:
		start = tile_mid(c0)
	elif i >= 0 and i < ps.size():
		start = tile_mid(str(ps[i].get("pos", "0")).to_int() % N)
	var u: float = clampf(t / 350.0, 0.0, 1.0)
	var e2: float = 1.0 - (1.0 - u) * (1.0 - u)
	var pos: Vector2 = start.lerp(mid, e2)
	var sc: float = lerpf(0.25, 1.0, e2)
	var flip: float = 1.0
	var front: bool = t >= 650.0
	if t >= 350.0 and t < 650.0:
		var f: float = (t - 350.0) / 300.0
		flip = absf(cos(PI * f))
		front = f > 0.5
	var al: float = clampf((CARD_LIFE8 - t) / 400.0, 0.0, 1.0)
	var col: Color = Color("8a3fd1") if luck else Color("2a7de1")
	var hw: float = 110.0
	var hh: float = 143.0

	var dim8: float = 0.45 * clampf(t / 250.0, 0.0, 1.0) * al
	if dim8 > 0.0:
		var lo8: Vector2 = _P(Vector2(0.0, BAR))
		draw_rect(Rect2(lo8, _P(win_size) - lo8), Color(0.01, 0.02, 0.06, dim8))
	if t >= 350.0 and t < CARD_LIFE8 - 400.0 and not (my_turn() and (_phase() == "roll" or _phase() == "bus")):
		_hit("card8", _R(mid.x - hw, mid.y - hh - 24.0, hw * 2.0, hh * 2.0 + 24.0), false)
	draw_set_transform(_P(pos), 0.0, Vector2(sc * maxf(0.04, flip), sc))
	var r: Rect2 = Rect2(Vector2( - hw, - hh) * _f, Vector2(hw, hh) * 2.0 * _f)
	_round(Rect2(r.position + Vector2(5, 8) * _f, r.size), Color(0, 0, 0, 0.38 * al), 16.0)
	if not front:
		_grad(r, Color(col.lightened(0.15), al), Color(col.darkened(0.35), al), Color(GOLD, al), 16.0, 3.5)
		_sprite("luck" if luck else "chance", Vector2(0, -8) * _f, 140.0 * _f, Color(1, 1, 1, al), true)
		for q: Vector2 in [Vector2(-80, -112), Vector2(80, 112)]:
			_string("?", BOLD, 44.0, Color(1, 1, 1, 0.8 * al), "c", q * _f, 40.0 * _f)
	else:
		draw_rect(r.grow(4.0 * _f), Color(1.0, 0.95, 0.6, 0.35 * al), false, 4.0 * _f)
		_round(r, Color(1.0, 0.98, 0.94, al), 16.0, Color(col, al), 4.0)
		_round(Rect2(r.position + Vector2(6, 6) * _f, Vector2(hw * 2.0 - 12.0, 44.0) * _f), Color(col, al), 12.0)
		_string("MAY RỦI" if luck else "CƠ HỘI", BOLD, 38.0, Color(1, 1, 1, al), "c", Vector2(0, - hh + 28.0) * _f, 200.0 * _f)
		_sprite("luck" if luck else "chance", Vector2(0, -46) * _f, 74.0 * _f, Color(1, 1, 1, al), true)
		var ink: Color = Color(0.13, 0.15, 0.25)
		if luck:
			var d: int = int(e.get("d", 0))
			ink = Color("1f7a2a") if d > 0 else Color("b3261e")
			_string(("+%s" if d > 0 else "-%s") % num(absi(d)), BOLD, 66.0, Color(ink, al), "c", Vector2(0, 34) * _f, 206.0 * _f)
			_string("Bạc được cộng" if d > 0 else "Bạc bị trừ", BOLD, 28.0, Color(0.36, 0.29, 0.19, al), "c", Vector2(0, 78) * _f, 206.0 * _f)
		else:
			var rows: Array = _wrap(str(e["t"]), 16.0, 198.0, 4, BOLD)
			var lh: float = 21.0
			var y0: float = 42.0 - (rows.size() - 1) * lh / 2.0
			for k in range(rows.size()):
				_string(str(rows[k]), BOLD, 32.0, Color(ink, al), "c", Vector2(0, y0 + lh * k) * _f, 206.0 * _f)
		_string("Chạm để đóng", BOLD, 30.0, Color(0.27, 0.21, 0.14, al), "c", Vector2(0, hh - 15.0) * _f, 210.0 * _f)
	draw_set_transform_matrix(_cam)
	if t >= 350.0 and i >= 0 and i < ps.size():
		var lp8: Vector2 = _P(mid + Vector2(0, - hh - 15.0))
		_round(Rect2(lp8 - Vector2(104.0, 13.0) * _f, Vector2(208.0, 26.0) * _f), Color(0.05, 0.08, 0.2, 0.94 * al), 13.0, Color(GOLD, 0.8 * al), 1.5)
		_ink("%s rút được" % _pname(i), 15.0, Color(1, 1, 1, al), Color(0.05, 0.08, 0.2, 0.9 * al), lp8, 200.0 * _f)
















var _fest8: Dictionary = {}
var _fl8: Dictionary = {}
var _fc8: Dictionary = {}
var _btn8: Dictionary = {}
var _btn8_vp: Vector2 = Vector2.ZERO
var _btn8_rd: bool = false
var _fb8: Dictionary = {}
var _bd8: Dictionary = {}
const FEST_K8: float = 0.66

const PB8_HULL: PackedFloat32Array = [0.013, 0.545, 0.019, 0.504, 0.062, 0.341, 0.1, 0.276, 0.225, 0.122, 0.338, 0.057, 0.425, 0.033, 0.65, 0.049, 0.762, 0.114, 0.8, 0.146, 0.925, 0.325, 0.975, 0.496, 0.981, 0.537, 0.981, 0.683, 0.956, 0.748, 0.875, 0.846, 0.706, 0.935, 0.519, 0.967, 0.237, 0.919, 0.138, 0.862, 0.062, 0.789, 0.037, 0.748, 0.013, 0.675]
const RD8_HULL: PackedFloat32Array = [0.016, 0.517, 0.066, 0.341, 0.152, 0.205, 0.254, 0.102, 0.363, 0.044, 0.48, 0.02, 0.645, 0.044, 0.738, 0.093, 0.805, 0.151, 0.93, 0.341, 0.977, 0.507, 0.988, 0.59, 0.984, 0.688, 0.973, 0.727, 0.934, 0.795, 0.859, 0.868, 0.703, 0.946, 0.531, 0.976, 0.289, 0.946, 0.141, 0.873, 0.094, 0.834, 0.023, 0.732, 0.012, 0.693, 0.004, 0.615]


static func _btn8_poly(id: String, r: Rect2) -> PackedVector2Array:
	if id.ends_with("_tag"):
		return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	var g: Rect2 = r.grow_individual(r.size.x * 0.158, r.size.y * 0.087, r.size.x * 0.158, 0.0)
	var h: PackedFloat32Array = RD8_HULL if id == "roll" else PB8_HULL
	var out: PackedVector2Array = PackedVector2Array()
	for i in range(h.size() / 2):
		out.append(g.position + Vector2(h[2 * i], h[2 * i + 1]) * g.size)
	return out


func _sk8() -> float:
	return maxf(0.05, absf((get_viewport().get_final_transform() * get_global_transform_with_canvas() * _cam).get_scale().x))

static func _area8(ps: Array) -> float:
	var s: float = 0.0
	for p: PackedVector2Array in ps:
		var a: float = 0.0
		for i in range(p.size()):
			a += p[i].cross(p[(i + 1) % p.size()])
		s += absf(a) / 2.0
	return s

static func _bb8(p: PackedVector2Array) -> Rect2:
	var r: Rect2 = Rect2(p[0], Vector2.ZERO)
	for v: Vector2 in p:
		r = r.expand(v)
	return r

static func _q8(c: Vector2, ex: Vector2, ey: Vector2, w: float, h: float) -> PackedVector2Array:
	return PackedVector2Array([c - ex * w / 2.0 - ey * h / 2.0, c + ex * w / 2.0 - ey * h / 2.0, c + ex * w / 2.0 + ey * h / 2.0, c - ex * w / 2.0 + ey * h / 2.0])


func _txt8(cell: int, price: bool) -> Array:
	var ax: Array = _tile_axes(cell)
	var ex: Vector2 = ax[0]
	var ey: Vector2 = ax[1]
	var wide: float = TW * Vector2(ba, bb).length() * _f * 0.9
	var px: float = 12.5 * bk
	var fs: int = maxi(6, roundi(px * _f))
	var ol: float = float(maxi(2, roundi(fs * 0.3)))
	var kind: String = str(BOARD[cell][1])
	var lines: Array = _name_lines("THUẾ 10%" if kind == "tax" else str(BOARD[cell][0]), px, wide)
	var lh: float = px * _f * 1.08
	var at: Vector2 = _P(tile_at(cell, 0.5, r_name(cell)))
	var out: Array = []
	for k in range(lines.size()):
		var w: float = minf(wide, BOLD.get_string_size(str(lines[k]), HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x) + 2.0 * ol
		out.append(_q8(at + ey * (k - (lines.size() - 1) / 2.0) * lh, ex, ey, w, BOLD.get_ascent(fs) + BOLD.get_descent(fs) + 2.0 * ol))
	if price:
		var fs2: int = maxi(6, roundi(13.0 * bk * _f))
		var ol2: float = float(maxi(2, roundi(fs2 * 0.3)))
		out.append(_q8(_P(tile_at(cell, 0.5, 0.87 if cell / 8 == 0 or cell / 8 == 3 else 0.13)), ex, ey, wide, BOLD.get_ascent(fs2) + BOLD.get_descent(fs2) + 2.0 * ol2))
	return out


func _shapes8(gm: Array, badge: bool = true) -> Array:
	var m: Dictionary = TpArt8.META
	var T: Transform2D = Transform2D(gm[0] as Vector2, gm[1] as Vector2, gm[2] as Vector2)
	var fl: Array = m["fe_fl"]
	var out: Array = []
	for i in range(fl.size() / 3):
		var a: float = float(fl[3 * i])
		var b: float = float(fl[3 * i + 1])
		var y0: float = minf(_ropey8(a), _ropey8(b)) - 2.0
		out.append(PackedVector2Array([T * Vector2(a, y0), T * Vector2(b, y0), T * Vector2((a + b) / 2.0, float(fl[3 * i + 2]))]))
	var bp: PackedVector2Array = _badge8_poly(gm, 1.0 * _f) if badge else PackedVector2Array()
	if not bp.is_empty():
		out.append(bp)
	return out


static func _ropey8(x: float) -> float:
	var m: Dictionary = TpArt8.META
	var u: float = clampf((x - float(m["fe_l"])) / (float(m["fe_r"]) - float(m["fe_l"])), 0.0, 1.0)
	return float(m["fe_a"]) + (float(m["fe_by"]) - float(m["fe_a"])) * 4.0 * u * (1.0 - u)


func _rope8(gm: Array) -> PackedVector2Array:
	var m: Dictionary = TpArt8.META
	var T: Transform2D = Transform2D(gm[0] as Vector2, gm[1] as Vector2, gm[2] as Vector2)
	var rh: float = float(m.get("fe_rh", 13.0))
	var top: PackedVector2Array = PackedVector2Array()
	var bot: PackedVector2Array = PackedVector2Array()
	for j in range(7):
		var x: float = lerpf(float(m["fe_l"]), float(m["fe_r"]), j / 6.0)
		top.append(T * Vector2(x, _ropey8(x) - rh))
		bot.insert(0, T * Vector2(x, _ropey8(x) + rh))
	return top + bot


func _poles8(gm: Array, kn: int = -1) -> Array:
	var m: Dictionary = TpArt8.META
	var T: Transform2D = Transform2D(gm[0] as Vector2, gm[1] as Vector2, gm[2] as Vector2)
	var gy: float = float(m["fe_g"]) + float(gm[3])
	var w: float = maxf(15.0, 3.6 / (_sk8() * maxf(0.001, (gm[0] as Vector2).length())))
	var knob: bool = kn == 1 or (kn < 0 and (gm.size() < 7 or float(gm[6]) * _sk8() > 2.0))
	if not knob:
		w = 15.0
	var top: float = 12.0 - w if knob else 2.0
	var out: Array = []
	for x: float in [float(m["fe_l"]), float(m["fe_r"])]:
		out.append(PackedVector2Array([T * Vector2(x - w, top), T * Vector2(x + w, top), T * Vector2(x + w, gy), T * Vector2(x - w, gy)]))
	return out


func _fest_lift8(cell: int, gm: Array) -> float:
	var key: String = "%d|%.3f|%.1f|%.1f|%.2f" % [cell, _f, (gm[2] as Vector2).x, (gm[2] as Vector2).y, bk]
	if _fl8.has(key):
		return float(_fl8[key])
	var txt: Array = _txt8(cell, true)
	for c2: int in [cell - 1, cell + 1]:
		if posmod(c2, 8) != 0:
			txt += _txt8(posmod(c2, N), false)
	var sh: Array = _shapes8(gm)
	var gap: float = 2.0 * _f
	var hit: Callable = func(d: float) -> bool:
		var mv: Transform2D = Transform2D(0.0, Vector2(0.0, - d))
		for p: PackedVector2Array in sh:
			var q2: PackedVector2Array = mv * p
			for q: PackedVector2Array in txt:
				if not Geometry2D.intersect_polygons(q2, q).is_empty():
					return true
		return false
	var lo: float = 0.0
	var hi: float = 70.0 * _f
	if hit.call(0.0):
		for it in range(11):
			var md: float = (lo + hi) / 2.0
			if hit.call(md):
				lo = md
			else:
				hi = md
		lo = hi + gap
	if _fl8.size() > 64:
		_fl8.clear()
	_fl8[key] = lo
	return lo


func _fest_geo8(cell: int, up: Vector2, now: float) -> Array:
	var m: Dictionary = TpArt8.META
	var near: bool = cell / 8 == 0 or cell / 8 == 3
	var rr: float = 0.0 if near else 1.0
	var p0: Vector2 = _P(tile_at(cell, 0.04, rr) + up)
	var p1: Vector2 = _P(tile_at(cell, 0.96, rr) + up)
	if p1.x < p0.x:
		var sw: Vector2 = p0
		p0 = p1
		p1 = sw
	var span: float = float(m["fe_r"]) - float(m["fe_l"])
	var xc: Vector2 = (p1 - p0) / span
	var k: float = maxf(0.001, (p1 - p0).length() / span)
	var yk: Vector2 = Vector2(0.0, k)
	var hg: float = float(m["fe_g"])
	var ls: float = maxf(0.0, FEST_K8 * span - (hg - float(m["fe_a"])))
	if near:
		var q0: Vector2 = _P(tile_at(cell, 0.04, rr))
		var q1: Vector2 = _P(tile_at(cell, 0.96, rr))
		var b0: Vector2 = q0 if q0.x < q1.x else q1
		ls += _fest_lift8(cell, [xc, yk, b0 - xc * float(m["fe_l"]) - yk * (hg + ls), ls, 1.0, (p1 - p0).length()]) / k

	var vp: Vector2 = get_viewport_rect().size
	if vp != _btn8_vp:
		_btn8.clear()
		_btn8_vp = vp
		_btn8_rd = false
	var br8: Variant = get("_btn_rects")
	if br8 is Dictionary:
		for id: String in br8:
			_btn8[id] = (br8 as Dictionary)[id]
		if _btn8.is_empty() and not _btn8_rd:
			_btn8_rd = true
			call_deferred("queue_redraw")
	var gm0: Array = [xc, yk, p0 - xc * float(m["fe_l"]) - yk * (hg + ls), ls, 1.0, (p1 - p0).length()]
	var per: Array = []
	var ex8: float = _fest_raise8(cell, up, gm0, per)
	var hide: bool = false
	if ex8 > 0.0:
		var cl8: float = _fest_ceil8(cell, gm0)
		if ex8 - cl8 > 1.0 / _sk8():


			var mv8: Transform2D = Transform2D(0.0, Vector2(0.0, - cl8))
			var nfl: int = (m["fe_fl"] as Array).size() / 3
			var sh8: Array = _shapes8(gm0)
			var tot: float = 0.0
			var cov: float = 0.0
			for i in range(mini(nfl, sh8.size())):
				var f8: PackedVector2Array = mv8 * (sh8[i] as PackedVector2Array)
				tot += _area8([f8])
				var parts: Array = []
				for pe: Array in per:
					if not bool(pe[2]):
						var rr8: Rect2 = pe[0]
						parts += Geometry2D.intersect_polygons(f8, PackedVector2Array([rr8.position, Vector2(rr8.end.x, rr8.position.y), rr8.end, Vector2(rr8.position.x, rr8.end.y)]))
				cov += minf(_area8([f8]), _area8(parts))
			hide = cov > 0.5 * maxf(0.001, tot)
		ex8 = minf(ex8, cl8)
		ls += ex8 / k
	var g: float = clampf((now - float(_fest8.get(cell, -100000.0))) / 400.0, 0.0, 1.0)
	var yc: Vector2 = Vector2(0.0, k * _ease_back(g))
	return [xc, yc, p0 - xc * float(m["fe_l"]) - yc * (hg + ls), ls, g, (p1 - p0).length(), ex8, cell, hide]




func _obst8(cell: int, up: Vector2) -> Array:
	var out: Array = []
	var ps: Array = _players()
	var pbx: Variant = get("_pawn_box")
	for i in range(ps.size()):
		if str(ps[i].get("out", "0")) == "1" or (i < hops.size() and not (hops[i] as Array).is_empty()):
			continue
		if posmod(roundi(float(shown[i]) if i < shown.size() else 0.0), N) != cell:
			continue
		if pbx is Dictionary and (pbx as Dictionary).has(i):
			out.append([(pbx as Dictionary)[i] as Rect2, 3.0, false])
		elif _pawn_at.has(i):
			var hd: float = float(_pawn_head.get(i, PAWN_W * bk * CH_HEAD)) * _f
			out.append([Rect2(_P(_pawn_at[i] as Vector2) - Vector2(PAWN_W * bk * _f * 0.5, hd), Vector2(PAWN_W * bk * _f, hd)), 3.0, false])
	var t: Dictionary = game.get("tiles", {}).get(cell, {}) as Dictionary
	var o: int = -1 if t.is_empty() else str(t.get("o", "0")).to_int()
	var h: int = 0 if o < 0 else str(t.get("h", "0")).to_int()
	if h > 0:
		var ba8: Array = [_bname(h), _bfoot(cell, up), _bwide(h) * LOT_B * bk, Color.WHITE, o, Color.WHITE]
		if has_method("_brect"):
			out.append([call("_brect", ba8) as Rect2, 6.0, false])
		else:
			var bw: float = float(ba8[2]) * _f
			out.append([Rect2(_P(ba8[1] as Vector2) - Vector2(bw * 0.5, bw), Vector2(bw, bw)), 6.0, false])
	elif o >= 0:
		var k: float = bk * _f
		if has_method("_cell_count") and int(call("_cell_count", cell)) >= 3:
			var fp: Vector2 = _P(tile_at(cell, 0.9, (r_name(cell) + r_sub(cell)) / 2.0) + up)
			out.append([Rect2(fp.x - 1.0 * k, fp.y - 15.5 * k, 11.5 * k, 15.5 * k), 4.0, true])
		else:
			var fb: Vector2 = _P(_bfoot(cell, up))
			out.append([Rect2(fb.x - 3.6 * k, fb.y - 38.4 * k, 25.6 * k, 38.4 * k), 4.0, true])
	return out


func _fest_raise8(cell: int, up: Vector2, gm: Array, per: Array = []) -> float:
	var obs: Array = _obst8(cell, up)
	if obs.is_empty():
		return 0.0
	var sk: float = _sk8()
	var rp: PackedVector2Array = _rope8(gm)
	var bp: PackedVector2Array = _badge8_poly(gm, 1.0 * _f)
	var lite: Array = [rp] if bp.is_empty() else [bp, rp]
	var sh: Array = _shapes8(gm)
	sh.append(rp)
	var need: float = 0.0
	for ob: Array in obs:
		var r: Rect2 = ob[0]
		var top: float = r.position.y - float(ob[1]) / sk
		var slab: PackedVector2Array = PackedVector2Array([Vector2(r.position.x, -100000.0), Vector2(r.end.x, -100000.0), Vector2(r.end.x, 100000.0), Vector2(r.position.x, 100000.0)])
		var n1: float = 0.0
		for p: PackedVector2Array in (lite if bool(ob[2]) else sh):
			for q: PackedVector2Array in Geometry2D.intersect_polygons(p, slab):
				for v: Vector2 in q:
					n1 = maxf(n1, v.y - top)
		per.append([r, n1, bool(ob[2])])
		need = maxf(need, n1)
	return need



func _fest_ceil8(cell: int, gm: Array) -> float:
	var o: Vector2 = gm[2]
	var key: String = "%s|%.1f|%.1f|%.2f" % [_forb8_key(cell), o.x, o.y, float(gm[3])]
	if _fc8.has(key):
		return float(_fc8[key])
	var sk: float = _sk8()
	var forb: Array = _forb8(cell)
	var best: float = 130.0 / sk

	for p: PackedVector2Array in _shapes8(gm, false) + _poles8(gm, 0) + [_rope8(gm)]:
		for q: PackedVector2Array in forb:
			if not Geometry2D.intersect_polygons(p, q).is_empty():
				best = 0.0
	var st: float = 1.0 / sk
	var sh: Array = _shapes8(gm, false) + _poles8(gm, 1) + [_rope8(gm)]
	for p: PackedVector2Array in sh:
		if best <= 0.0:
			break
		var pb: Rect2 = _bb8(p)
		for q: PackedVector2Array in forb:
			var qb: Rect2 = _bb8(q)
			if qb.end.x <= pb.position.x or pb.end.x <= qb.position.x or qb.position.y >= pb.end.y:
				continue
			var d: float = maxf(st, pb.position.y - qb.end.y)
			var d1: float = minf(best, pb.end.y - qb.position.y)
			while d <= d1:
				if not Geometry2D.intersect_polygons(Transform2D(0.0, Vector2(0.0, - d)) * p, q).is_empty():
					best = minf(best, maxf(0.0, d - st - 2.0 / sk))
					break
				d += st
	if _fc8.size() > 64:
		_fc8.clear()
	_fc8[key] = best
	return best


func _forb8_key(cell: int) -> String:
	var hs: float = 0.0
	for r: Rect2 in _btn8.values():
		hs += r.position.x * 3.0 + r.position.y * 7.0 + r.size.x * 11.0 + r.size.y * 13.0
	return "%d|%.3f|%.2f|%s|%.0f|%d" % [cell, _f, bk, str(_cam), hs, _btn8.size()]

func _forb8(cell: int) -> Array:
	var key: String = _forb8_key(cell)
	if _fb8.has(key):
		return _fb8[key] as Array
	var inv: Transform2D = _cam.affine_inverse()
	var forb: Array = []
	for id: String in _btn8:
		forb.append(inv * _btn8_poly(id, _btn8[id] as Rect2))
	for c2 in range(N):
		if c2 % 8 != 0 and c2 != cell:
			forb += _txt8(c2, true)
	if _fb8.size() > 16:
		_fb8.clear()
	_fb8[key] = forb
	return forb


func _fest_banner8(cell: int, up: Vector2, now: float, part: int = 0) -> void :
	var m: Dictionary = TpArt8.META
	var gm: Array = _fest_geo8(cell, up, now)
	var yc: Vector2 = gm[1]
	if yc.y < 0.02 * (gm[0] as Vector2).length():
		return
	var al: float = clampf(float(gm[4]) * 3.0, 0.0, 1.0)
	var tex: Texture2D = TpArt8.tex("fe")
	var hide: bool = gm.size() > 8 and bool(gm[8])
	if tex != null and part != 2 and not hide:
		var sk: float = _sk8()
		var tall: bool = float(gm[6]) * sk > 2.0
		draw_set_transform_matrix(_cam * Transform2D(gm[0] as Vector2, yc, gm[2] as Vector2))
		var w: float = float(m["fe_w"])
		var s0: float = float(m["fe_s0"])
		var s1: float = float(m["fe_s1"])
		var ls: float = float(gm[3])
		var tint: Color = Color(1, 1, 1, al)
		if tall:
			var lw: float = 28.0 + 1.0 / maxf(0.001, sk * (gm[0] as Vector2).length())
			for px8: float in [float(m["fe_l"]), float(m["fe_r"])]:
				draw_line(Vector2(px8, float(m["fe_a"])), Vector2(px8, s1 + ls), Color(0.24, 0.08, 0.01, al), lw)
		draw_texture_rect_region(tex, Rect2(0, 0, w, s0), Rect2(0, 0, w, s0), tint)
		draw_texture_rect_region(tex, Rect2(0, s0, w, s1 - s0 + ls), Rect2(0, s0, w, s1 - s0), tint)
		draw_texture_rect_region(tex, Rect2(0, s1 + ls, w, float(m["fe_h"]) - s1), Rect2(0, s1, w, float(m["fe_h"]) - s1), tint)

		_flat()
		if tall:
			var T: Transform2D = Transform2D(gm[0] as Vector2, yc, gm[2] as Vector2)
			var rk: float = maxf(15.0 * (gm[0] as Vector2).length(), 2.6 / sk)
			for px8: float in [float(m["fe_l"]), float(m["fe_r"])]:
				var kc: Vector2 = T * Vector2(px8, 12.0)
				draw_circle(kc, rk + 0.9 / sk, Color(0.32, 0.12, 0.02, al), true, -1.0, true)
				draw_circle(kc, rk, Color(1.0, 0.83, 0.35, al), true, -1.0, true)
				draw_circle(kc - Vector2(rk, rk) * 0.3, rk * 0.36, Color(1.0, 1.0, 0.88, 0.9 * al), true, -1.0, true)
	_flat()
	if part != 1:
		_badge8(gm, up, now, al)


func _pawn_on8(cell: int) -> bool:
	var ps: Array = _players()
	for i in range(ps.size()):
		if str(ps[i].get("out", "0")) == "1" or (i < hops.size() and not (hops[i] as Array).is_empty()):
			continue
		if posmod(roundi(float(shown[i]) if i < shown.size() else 0.0), N) == cell:
			return true
	return false



func _badge8_rect(gm: Array) -> Array:


	var m: Dictionary = TpArt8.META
	var sk: float = _sk8()
	var fs: int = maxi(ceili(11.5 / sk), roundi(0.2 * float(gm[5])))
	var xc: Vector2 = gm[0]
	var yv: Vector2 = gm[1]
	var yy: float = maxf(0.001, yv.y)
	var slope: float = xc.y / xc.x if absf(xc.x) > 0.001 else 0.0
	var ax: float = maxf(0.001, absf(xc.x))
	var fl: Array = m["fe_fl"]
	var bx0: float = float(m["fe_bx"])
	var dirx: float = - signf(slope) if absf(slope) > 0.02 else 0.0
	var key: String = "%s|%s|%s|%.2f|%d|%.3f" % [str(xc), str(yv), str(gm[2]), float(gm[3]), fs, _f]
	var chk: bool = gm.size() > 7 and not _btn8.is_empty()
	if chk:
		key += "|" + _forb8_key(int(gm[7]))
		if _bd8.has(key):
			return _bd8[key] as Array
	var out: Array = []
	var st: float = 2.5 / (sk * ax)

	var fmin: int = ceili(11.5 / sk)
	var sizes: Array = [fs]
	if chk:
		var f2: int = fs - 1
		while f2 >= fmin and sizes.size() < 4:
			sizes.append(f2)
			f2 -= 1 if fs - fmin <= 4 else maxi(1, int(float(fs - fmin) / 3.0))
	var found: bool = false
	for fz: int in sizes:
		var tw2: float = _x2w8(fz)
		var as2: float = BOLD.get_ascent(fz)
		var ds2: float = BOLD.get_descent(fz)
		var hh2: float = (as2 + ds2) * 0.92 + 2.0
		var ww2: float = tw2 + 0.75 * fz
		var r2: Rect2 = Rect2( - ww2 / 2.0, - hh2, ww2, hh2)
		var tp2: Vector2 = Vector2( - tw2 / 2.0, - hh2 / 2.0 + (as2 - ds2) / 2.0)
		var hf2: float = (ww2 / 2.0 + 1.5 * _f) / ax
		var lim2: float = (float(m["fe_r"]) - float(m["fe_l"])) / 2.0 - hf2 - 24.0
		var n2: int = 0 if not chk or dirx == 0.0 else int(floorf(maxf(0.0, lim2) / st))
		for k in range(2 * n2 + 1):
			var bx: float = bx0 + (dirx * st * floorf((k + 1) / 2.0) * (1.0 if k % 2 == 1 else -1.0) if k > 0 else 0.0)
			var ybot: float = float(m["fe_by"])
			for i in range(fl.size() / 3):
				var a: float = float(fl[3 * i])
				var b: float = float(fl[3 * i + 1])
				if b > bx - hf2 and a < bx + hf2:
					ybot = minf(ybot, minf(_ropey8(a), _ropey8(b)) - 2.0)
			ybot -= (1.0 * _f + 1.2 / sk) / yy
			var M: Transform2D = Transform2D(Vector2(1.0, slope), Vector2(0.0, 1.0), (gm[2] as Vector2) + xc * bx + yv * ybot)
			if out.is_empty():
				out = [r2, fz, tp2, M]
			if not chk or _badge8_free(M, r2, int(gm[7])):
				out = [r2, fz, tp2, M]
				found = true
				break
		if found or not chk:
			break
	if chk and not found:
		out = []
	if chk:
		if _bd8.size() > 64:
			_bd8.clear()
		_bd8[key] = out
	return out

func _badge8_free(M: Transform2D, r: Rect2, cell: int) -> bool:
	var g: Rect2 = r.grow(1.0 * _f)
	var p: PackedVector2Array = M * PackedVector2Array([g.position, Vector2(g.end.x, g.position.y), g.end, Vector2(g.position.x, g.end.y)])
	for q: PackedVector2Array in _forb8(cell):
		if not Geometry2D.intersect_polygons(p, q).is_empty():
			return false
	return true


func _badge8_poly(gm: Array, g: float = 0.0) -> PackedVector2Array:
	var b: Array = _badge8_rect(gm)
	if b.is_empty():
		return PackedVector2Array()
	var r: Rect2 = (b[0] as Rect2).grow(g)
	return (b[3] as Transform2D) * PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])



func _fest_band8(cell: int, up: Vector2, t: Dictionary) -> void :
	if t.is_empty() or str(t.get("f", "0")) != "1":
		return
	var near: bool = cell / 8 == 0 or cell / 8 == 3
	var r0: float = 0.76 if near else 0.015
	var r1: float = 0.985 if near else 0.24
	var q: PackedVector2Array = _poly_px(PackedVector2Array([tile_at(cell, 0.06, r0), tile_at(cell, 0.94, r0), tile_at(cell, 0.94, r1), tile_at(cell, 0.06, r1)]), up)
	_flat()
	draw_colored_polygon(q, Color(0.8, 0.17, 0.12))
	q.append(q[0])
	draw_polyline(q, Color(1.0, 0.83, 0.3), maxf(1.0, 1.0 / _sk8()), true)

func _badge8(gm: Array, up: Vector2, now: float, al: float) -> void :
	var b: Array = _badge8_rect(gm)
	if b.is_empty() or (gm.size() > 8 and bool(gm[8])):
		_band_badge8(int(gm[7]), up, now, al)
		return
	var r: Rect2 = b[0]
	var fs: int = b[1]
	draw_set_transform_matrix(_cam * (b[3] as Transform2D))
	if not low_gfx():
		var pu: float = 0.5 + 0.5 * sin(now / 260.0)
		_round(r.grow(1.5), Color(1.0, 0.82, 0.2, (0.18 + 0.3 * pu) * al), r.size.y / 2.0 + 1.5)
	_round(r, Color(0.85, 0.2, 0.17, al), r.size.y / 2.0, Color(1.0, 0.83, 0.3, al), maxf(1.2, fs / 9.0))
	_x2_8(b[2], fs, al)
	_flat()


func _x2w8(fs: int) -> float:
	return 0.56 * fs + BOLD.get_string_size("2", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x



func _x2_8(o: Vector2, fs: int, al: float) -> void :
	var sk: float = _sk8()
	var hx: float = 0.19 * fs
	var c: Vector2 = o + Vector2(0.25 * fs, -0.36 * fs)
	var lw: float = maxf(1.7 / sk, 0.15 * fs)
	var rim: Color = Color(0.42, 0.04, 0.02, al)
	var ink: Color = Color(1.0, 0.94, 0.48, al)
	for j in range(2):
		var w: float = lw + (2.2 / sk if j == 0 else 0.0)
		var hx2: float = hx + (1.1 / sk if j == 0 else 0.0)
		var col: Color = rim if j == 0 else ink
		draw_line(c + Vector2( - hx2, - hx2), c + Vector2(hx2, hx2), col, w, true)
		draw_line(c + Vector2( - hx2, hx2), c + Vector2(hx2, - hx2), col, w, true)
	var o2: Vector2 = o + Vector2(0.56 * fs, 0.0)
	draw_string_outline(BOLD, o2, "2", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 2, rim)
	draw_string(BOLD, o2, "2", HORIZONTAL_ALIGNMENT_LEFT, -1, fs, ink)




func _band8_rect(cell: int, up: Vector2) -> Array:
	var t: Dictionary = game.get("tiles", {}).get(cell, {}) as Dictionary
	if t.is_empty() or str(t.get("f", "0")) != "1":
		return []
	var sk: float = _sk8()
	var near: bool = cell / 8 == 0 or cell / 8 == 3
	var ax: Array = _tile_axes(cell)
	var P: Transform2D = Transform2D(ax[0] as Vector2, ax[1] as Vector2, _P(tile_at(cell, 0.5, 0.87 if near else 0.13) + up))
	var txt: String = _k8(str(t.get("r", "0")).to_int()) if _m8() else str(t.get("r", ""))
	var key: String = "b|%d|%s|%s|%s|%.2f|%d" % [cell, str(up), txt, _forb8_key(cell), sk, int(_pawn_on8(cell))]
	if _bd8.has(key):
		return _bd8[key] as Array
	var ip: Transform2D = P.affine_inverse()
	var r0: float = 0.76 if near else 0.015
	var r1: float = 0.985 if near else 0.24
	var lo: Vector2 = Vector2(INF, INF)
	var hi: Vector2 = Vector2( - INF, - INF)
	for q: Vector2 in [Vector2(0.06, r0), Vector2(0.94, r0), Vector2(0.94, r1), Vector2(0.06, r1)]:
		var v: Vector2 = ip * _P(tile_at(cell, q.x, q.y) + up)
		lo = Vector2(minf(lo.x, v.x), minf(lo.y, v.y))
		hi = Vector2(maxf(hi.x, v.x), maxf(hi.y, v.y))

	var wide: float = TW * Vector2(ba, bb).length() * _f * 0.9
	var px: float = 13.0 * bk
	var kk: float = minf(1.0, wide / maxf(1.0, _tw(txt, px, BOLD) * _f))
	var fn: int = maxi(6, roundi(px * kk * _f))
	var sz: float = BOLD.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fn).x
	if sz > wide:
		fn = maxi(6, int(floorf(fn * wide / sz)))
		sz = BOLD.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, fn).x
	var base: float = (BOLD.get_ascent(fn) - BOLD.get_descent(fn)) / 2.0
	var nr8: Rect2 = Rect2( - sz / 2.0, base - 0.76 * fn, sz, 0.92 * fn).grow(1.5 / sk)
	var fs: int = maxi(ceili(10.5 / sk), roundi(0.78 * fn))
	var tw: float = _x2w8(fs)
	var asc: float = BOLD.get_ascent(fs)
	var dsc: float = BOLD.get_descent(fs)
	var hh: float = (asc + dsc) * 0.86 + 2.0
	var ww: float = tw + 0.6 * fs
	var r: Rect2 = Rect2( - ww / 2.0, - hh, ww, hh)
	var tq: Vector2 = Vector2( - tw / 2.0, - hh / 2.0 + (asc - dsc) / 2.0)
	var names: Array = _txt8(cell, false)
	var nmx: Vector2 = Vector2(INF, - INF)
	for q: PackedVector2Array in names:
		for v: Vector2 in ip * q:
			nmx = Vector2(minf(nmx.x, v.x), maxf(nmx.y, v.x))
	var forb: Array = _forb8(cell) if not _btn8.is_empty() else []
	for c2 in range(N):
		if _btn8.is_empty() and c2 % 8 != 0 and c2 != cell:
			forb += _txt8(c2, true)
	var obs: Array = []
	for ob: Array in _obst8(cell, up):
		var rb: Rect2 = (ob[0] as Rect2).grow(1.0 / sk)
		obs.append(PackedVector2Array([rb.position, Vector2(rb.end.x, rb.position.y), rb.end, Vector2(rb.position.x, rb.end.y)]))
	var st: float = 2.0 / sk
	var out: Array = []
	var first: Array = []
	var ya: Array = []
	for fr: float in [0.5, 0.36, 0.22, 0.08, 0.0]:
		ya.append(lo.y + fr * hh)
	var yu: Array = [hi.y + hh + 1.5 * _f, hi.y + hh + 1.5 * _f + st]
	for strict: bool in [true, false]:
		for pz: int in [0, 1]:
			for side: float in [1.0, -1.0]:
				var x0: float = hi.x - ww / 2.0 - 1.0 * _f if side > 0.0 else lo.x + ww / 2.0 + 1.0 * _f
				var steps: int = int(floorf(maxf(0.0, (hi.x - lo.x) / 2.0 - ww / 2.0) / st))
				var ed: float = maxf(hi.x, maxf(nr8.end.x, nmx.y)) if side > 0.0 else minf(lo.x, minf(nr8.position.x, nmx.x))
				var xs: Array = [x0, x0 + side * 0.25 * ww, x0 + side * 0.5 * ww, x0 + side * 0.75 * ww, ed + side * (ww / 2.0 + 2.0 * _f), ed + side * (ww / 2.0 + 2.0 * _f + st)]
				for j in range(1, steps + 1):
					xs.append(x0 - side * st * j)
				for cx: float in xs:
					for yb: float in (ya if pz == 0 else yu):
						var M: Transform2D = Transform2D(0.0, Vector2(cx, yb))
						var g: Rect2 = r.grow(1.0 * _f)
						var loc: Rect2 = Rect2(M.origin + g.position, g.size)
						if loc.intersects(nr8):
							continue
						var poly: PackedVector2Array = P * (M * PackedVector2Array([g.position, Vector2(g.end.x, g.position.y), g.end, Vector2(g.position.x, g.end.y)]))
						if first.is_empty() and strict:
							first = [P * M, r, fs, tq, "dai gia (cham)", nr8, P]
						var ok: bool = true
						for q: PackedVector2Array in names + forb + (obs if strict else []):
							if not Geometry2D.intersect_polygons(poly, q).is_empty():
								ok = false
								break
						if ok:
							out = [P * M, r, fs, tq, ("dai gia" if pz == 0 else "dai gia (duoi)") + ("" if strict else " (che vat)"), nr8, P]
							break
					if not out.is_empty():
						break
				if not out.is_empty():
					break
			if not out.is_empty():
				break
		if not out.is_empty():
			break
	if out.is_empty():
		out = first
	if out.is_empty():
		out = [P * Transform2D(0.0, Vector2(hi.x - ww / 2.0 - 1.0 * _f, lo.y)), r, fs, tq, "dai gia (ep)", nr8, P]
	if _bd8.size() > 64:
		_bd8.clear()
	_bd8[key] = out
	return out

func _band_badge8(cell: int, up: Vector2, now: float, al: float) -> void :
	var b: Array = _band8_rect(cell, up)
	if b.is_empty():
		return
	var r: Rect2 = b[1]
	var fs: int = b[2]
	draw_set_transform_matrix(_cam * (b[0] as Transform2D))
	if not low_gfx():
		var pu: float = 0.5 + 0.5 * sin(now / 260.0)
		_round(r.grow(1.2), Color(1.0, 0.82, 0.2, (0.16 + 0.26 * pu) * al), r.size.y / 2.0 + 1.2)
	_round(r, Color(0.8, 0.17, 0.12, al), r.size.y / 2.0, Color(1.0, 0.83, 0.3, al), maxf(1.0 / _sk8(), fs / 10.0))
	_x2_8(b[3], fs, al)
	_flat()

func _strip(text: String, t: float, life: float, good: bool) -> void :
	var w: float = win_size.x
	var al: float = clampf(minf(t / 150.0, (life - t) / 300.0), 0.0, 1.0)
	var open: float = clampf(t / 200.0, 0.0, 1.0)
	var sw: float = minf(560.0, w - 40.0) * open
	var y: float = BAR + 78.0
	var r: Rect2 = Rect2(w / 2.0 - sw / 2.0, y, sw, 40)
	if sw < 4.0:
		return
	if good:
		_grad(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color(GOLD_TOP, al), Color(GOLD_LOW, al), Color(1, 1, 1, 0.8 * al), 20.0, 2.0)
	else:
		_grad(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color(0.85, 0.3, 0.12, 0.96 * al), Color(0.55, 0.1, 0.08, 0.96 * al), Color(1.0, 0.8, 0.4, al), 20.0, 2.0)
	if open >= 1.0:
		_w(text, 14.0, Color(ON_GOLD, al) if good else Color(1, 1, 1, al), "c", w / 2.0 + (14.0 if not good else 0.0), y + 20.0, sw - 70.0, BOLD)
	if not good:
		var k: float = 1.0 + 0.12 * sin(t / 60.0)
		var c: Vector2 = Vector2(r.position.x + 24.0, y + 21.0)
		var tri: PackedVector2Array = _poly_px(PackedVector2Array([c + Vector2(0, -12) * k, c + Vector2(12, 9) * k, c + Vector2(-12, 9) * k]))
		draw_colored_polygon(tri, Color(1.0, 0.8, 0.15, al))
		_w("!", 13.0, Color(0.3, 0.1, 0.0, al), "c", c.x, c.y + 2.0, 20, BOLD)

func _fx_rain(e: Dictionary, t: float, low: bool) -> void :
	if not low:
		var w: float = win_size.x
		var h: float = win_size.y
		for k in range(26):
			var fk: float = fposmod(k * 0.618 + 0.13, 1.0)
			var tk: float = t - k * 25.0
			if tk < 0.0:
				continue
			var p: Vector2 = Vector2(fk * w, BAR - 16.0 + tk * (h - BAR) / 1300.0 * (0.8 + 0.4 * fposmod(k * 0.37, 1.0)))
			if p.y > h:
				continue
			var spin: float = maxf(0.15, absf(cos(tk / 120.0 + k)))
			draw_set_transform(_P(p), 0.0, Vector2(spin, 1.0))
			draw_circle(Vector2.ZERO, 8.0 * _f, Color("9a6a08"), true, -1.0, true)
			draw_circle(Vector2(0, -1.0 * _f), 6.8 * _f, Color("ffd34d"), true, -1.0, true)
		draw_set_transform_matrix(_cam)
	_strip(str(e.get("text", "")), t, 1700.0, true)

func _fx_warn(e: Dictionary, t: float) -> void :
	_strip(str(e.get("text", "")), t, 1600.0, false)


func _fx_order(now: float) -> void :
	var t: float = now - order_at
	if t < 0.0 or t >= 2600.0 or str(game.get("over", "0")) == "1":
		return
	var ps: Array = _players()
	var n: int = ps.size()
	if n == 0:
		return
	var w: float = win_size.x
	var h: float = win_size.y
	var al: float = clampf(minf(t / 200.0, (2600.0 - t) / 300.0), 0.0, 1.0)
	draw_rect(_R(0, BAR, w, h - BAR), Color(0, 0, 0, 0.45 * al))
	var cy: float = BAR + (h - BAR) / 2.0 + 10.0
	_w("THỨ TỰ ĐI", 18.0, Color(GOLD, al), "c", w / 2.0, cy - 98.0, 300, BOLD)
	var x0: float = w / 2.0 - (n * 110.0 + (n - 1) * 16.0) / 2.0
	for i in range(n):
		var f: float = clampf((t - 250.0 - i * 220.0) / 300.0, 0.0, 1.0)
		var flip: float = maxf(0.04, absf(cos(PI * f)))
		draw_set_transform(_P(Vector2(x0 + i * 126.0 + 55.0, cy)), 0.0, Vector2(flip, 1.0))
		var r: Rect2 = Rect2(Vector2(-55, -70) * _f, Vector2(110, 140) * _f)
		if f <= 0.5:
			_grad(r, Color(0.09, 0.26, 0.48, al), Color(0.04, 0.15, 0.31, al), Color(GOLD, al), 12.0, 2.0)
			_string("?", BOLD, 60.0, Color(GOLD, al), "c", Vector2.ZERO, 100.0 * _f)
		else:
			var col: Color = Color(str(PLAYER_COL[i % 4]))
			_grad(r, Color(0.14, 0.31, 0.56, al), Color(0.06, 0.16, 0.33, al), Color(col, al), 12.0, 3.0)
			_avatar(str(ps[i].get("av", "0")).to_int(), Rect2(Vector2(-28, -60) * _f, Vector2(56, 56) * _f))
			_string(_clip(_pname(i), 11.0, 100.0, BOLD), BOLD, 22.0, Color(1, 1, 1, al), "c", Vector2(0, 14) * _f, 104.0 * _f)
			draw_circle(Vector2(0, 44) * _f, 15.0 * _f, Color(GOLD, al), true, -1.0, true)
			_string(str((i - _order0 + n) % n + 1), BOLD, 30.0, Color(ON_GOLD, al), "c", Vector2(0, 44) * _f, 30.0 * _f)
	draw_set_transform_matrix(_cam)


func _talk_ui() -> void :
	if not can_talk():
		return
	var w: float = win_size.x
	var h: float = win_size.y
	var bh: float = _tap(36.0)
	var y: float = h - CARD.y - 8.0 - bh - 6.0
	var x0: float = w - 8.0 - 296.0
	var now: float = now_ms()
	_btn("emo_open", "Biểu cảm", Rect2(x0, y, 108, bh), true, 15.0, "orange" if talk_pane == "emo" else "talk")
	_btn("chat_open", "Chat", Rect2(x0 + 114.0, y, 80, bh), true, 15.0, "orange" if talk_pane == "chat" else "talk")
	_btn("talk_hide", "Hiện tin" if hide_talk else "Ẩn tin", Rect2(x0 + 200.0, y, 96, bh), true, 15.0, "orange" if hide_talk else "talk")
	_btn("talk_log", "Tin ván", Rect2(8, y, 108, bh), true, 15.0, "orange" if log_open else "talk")
	_memo8_draw(124.0, y + bh / 2.0)
	if log_open:
		_talk_log(Rect2(8, y - 176.0, 310, 170))
	if talk_pane == "emo":
		var r: Rect2 = Rect2(w - 8.0 - 326.0, y - 176.0, 326, 170)
		_round(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color("0e2a52", 0.97), 12.0, Color(GOLD, 0.8), 1.5)
		_hit("panel", _R(r.position.x, r.position.y, r.size.x, r.size.y), false)
		var cool: bool = now - emo_at < TALK_GAP
		var items: Array = emo_items()
		for k in range(mini(18, items.size())):
			var cr: Rect2 = Rect2(r.position.x + 5.0 + (k % 6) * 52.6, r.position.y + 5.0 + (k / 6) * 53.3, 52.6, 53.3)
			var id: String = "emo:" + str(items[k])
			if _hover == id and not cool:
				_round(_R(cr.position.x + 2.0, cr.position.y + 2.0, cr.size.x - 4.0, cr.size.y - 4.0), Color(1, 1, 1, 0.14), 10.0)
			var tex: Texture2D = _emo_tex(str(items[k]))
			if tex != null:
				draw_texture_rect(tex, _R(cr.position.x + 6.0, cr.position.y + 6.5, 40, 40), false, Color(1, 1, 1, 0.35 if cool else 1.0))
			else:
				draw_circle(_P(cr.get_center()), 3.0 * _f, Color(CREAM, 0.4), true, -1.0, true)
			if not cool:
				_hit(id, _R(cr.position.x, cr.position.y, cr.size.x, cr.size.y), false)
	elif talk_pane == "chat":
		var qh: float = _tap(34.0)
		var r: Rect2 = Rect2(w - 8.0 - 400.0, y - 30.0 - 3.0 * qh - 12.0, 400, 3.0 * qh + 30.0)
		_round(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color("0e2a52", 0.97), 14.0, Color(GOLD, 0.8), 1.5)
		_hit("panel", _R(r.position.x, r.position.y, r.size.x, r.size.y), false)
		var cool: bool = now - say_at < TALK_GAP
		for k in range(QUICK.size()):
			_btn("quick:%d" % k, str(QUICK[k]), Rect2(r.position.x + 10.0 + (k % 2) * 194.0, r.position.y + 10.0 + (k / 2) * (qh + 5.0), 186, qh), not cool, 14.0)
		var er: Rect2 = Rect2(r.position.x + 10.0, r.position.y + 20.0 + 2.0 * qh, 300, qh)
		var sr: Rect2 = Rect2(r.position.x + 316.0, r.position.y + 20.0 + 2.0 * qh, 74, qh)
		if _mobile:

			var bw: float = minf(560.0, w - 16.0)
			var bar: Rect2 = Rect2(w / 2.0 - bw / 2.0, BAR + 4.0, bw, qh + 10.0)
			_round(_R(bar.position.x, bar.position.y, bar.size.x, bar.size.y), Color("0e2a52", 0.97), 12.0, Color(GOLD, 0.8), 1.5)
			_hit("panel", _R(bar.position.x, bar.position.y, bar.size.x, bar.size.y), false)
			er = Rect2(bar.position.x + 5.0, bar.position.y + 5.0, bw - 96.0, qh)
			sr = Rect2(bar.end.x - 86.0, bar.position.y + 5.0, 81, qh)
			_w("Ô nhập ở trên cùng màn", 14.0, MUTED, "c", r.get_center().x, er.get_center().y, 380)
		_place(_chat_edit(), _R(er.position.x, er.position.y, er.size.x, er.size.y))
		_btn("say_send", "Gửi", sr, not cool, 15.0)


func _talk_log(r: Rect2) -> void :
	_round(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color("0a1f3e", 0.9), 10.0, Color(GLASS_EDGE, 0.6), 1.0)
	_hit("panel", _R(r.position.x, r.position.y, r.size.x, r.size.y), false)
	var me: int = int(game.get("me", -1))
	var rows: Array = []
	for k in range(talk.size() - 1, -1, -1):
		var t: Dictionary = talk[k]
		if hide_talk and int(t["i"]) != me:
			continue
		rows.push_front(t)
		if rows.size() >= 5:
			break
	if rows.is_empty():
		_w("Chưa có tin nào trong ván", 14.0, MUTED, "c", r.get_center().x, r.get_center().y, r.size.x - 16.0)
		return
	for k in range(rows.size()):
		var t: Dictionary = rows[k]
		var ry: float = r.position.y + 21.0 + 31.0 * k
		var i: int = int(t["i"])
		var nm: String = _clip(_pname(i) + ":", 14.0, 104.0, BOLD)
		var nw: float = _w(nm, 14.0, Color(str(PLAYER_COL[maxi(0, i) % 4])), "l", r.position.x + 10.0, ry, 106, BOLD)
		var x: float = r.position.x + 16.0 + nw
		if str(t["k"]) == "emo":
			var tex: Texture2D = _emo_tex(str(t["v"]))
			if tex != null:
				draw_texture_rect(tex, _R(x, ry - 12.0, 24, 24), false)
		else:
			_w(_clip(str(t["v"]), 14.0, r.end.x - x - 8.0), 14.0, CREAM, "l", x, ry, r.end.x - x - 6.0)


func _tile_info() -> void :
	var now: float = now_ms()
	var info: int = -1
	if _hover.begins_with("t:"):
		info = _hover.substr(2).to_int()
	elif pick_tile >= 0 and now - pick_at < 4000.0:
		info = pick_tile
	if info < 0 or info >= N or confirm != "":
		return
	var t: Array = BOARD[info]
	var tl: Dictionary = game.get("tiles", {}).get(info, {})
	var line: String = ""
	if str(t[1]) == "land":
		if tl.is_empty():
			line = "Giá %s · chưa có chủ" % num(_price8(info))
		else:
			var o: int = str(tl.get("o", "0")).to_int()
			line = "Chủ: %s · nhà cấp %s · thuê %s%s" % [_pname(o), str(tl.get("h", "0")), num(str(tl.get("r", "0")).to_int()), " (Lễ Hội ×2)" if str(tl.get("f", "0")) == "1" else ""]
	else:
		line = {"start": "Đi qua nhận thưởng", "luck": "Rút May Rủi: được hoặc mất tiền", "chance": "Rút thẻ Cơ Hội", 
			"jail": "Ra đảo: tung đôi, nộp phạt hoặc chờ 3 lượt", "fest": "Chọn ô đất của mình: thuê ×2", "bus": "Lượt sau chọn ô muốn tới", 
			"tax": "Nộp 10% tài sản"}.get(str(t[1]), "")
	var m: Vector2 = tile_mid(info)
	var r: Rect2 = Rect2(m.x - 190.0, m.y - CS * bb - 80.0, 380, 62)
	r.position.x = clampf(r.position.x, 8.0, win_size.x - r.size.x - 8.0)
	r.position.y = clampf(r.position.y, BAR + 6.0, win_size.y - r.size.y - 8.0)
	_round(_R(r.position.x + 2.0, r.position.y + 3.0, r.size.x, r.size.y), Color(0, 0, 0, 0.35), 10.0)
	_round(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color("0e2a52", 0.96), 10.0, Color(GLASS_EDGE, 0.7), 1.5)
	_w(str(t[0]), 17.0, GOLD, "c", r.get_center().x, r.position.y + 19.0, 360, BOLD)
	_w(line, 14.5, CREAM, "c", r.get_center().x, r.position.y + 44.0, 366)

func _leave_box() -> void :
	draw_rect(_R(0, BAR, win_size.x, win_size.y - BAR), Color(0, 0, 0, 0.45))
	_hit("stay", _R(0, BAR, win_size.x, win_size.y - BAR), false)
	var r: Rect2 = Rect2(win_size.x / 2.0 - 250.0, win_size.y / 2.0 - 105.0, 500, 210)
	_round(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color("0e2a52", 0.98), 16.0, Color(GOLD, 0.9), 2.0)
	_hit("panel", _R(r.position.x, r.position.y, r.size.x, r.size.y), false)
	_w("Rời bàn?", 23.0, GOLD, "c", r.get_center().x, r.position.y + 34.0, 470, BOLD)
	_w("Thoát giữa ván vẫn mất gói %s Bạc." % num(_stake()), 17.0, CREAM, "c", r.get_center().x, r.position.y + 76.0, 470)
	_w("Máy sẽ đi thay bạn đến hết ván.", 16.0, Color(CREAM, 0.75), "c", r.get_center().x, r.position.y + 105.0, 470)
	_btn("stay", "Ở lại", Rect2(r.get_center().x - 200.0, r.end.y - 66.0, 190, 46), true, 18.0)
	_btn("leave_yes", "Rời bàn", Rect2(r.get_center().x + 10.0, r.end.y - 66.0, 190, 46), true, 18.0, "gray")

func _over_box() -> void :
	var now: float = now_ms()
	var low: bool = low_gfx()
	var t: float = now - over_at
	var w: float = win_size.x
	draw_rect(_R(0, BAR, w, win_size.y - BAR), Color(0, 0, 0, 0.55))
	var ps: Array = _players()
	var me: Dictionary = _me()
	var text: String = _result_text()
	var good: bool = text.begins_with("Thắng") or text.begins_with("Hoà")
	var broke: bool = str(me.get("out", "0")) == "1"
	var h: float = 250.0 + 54.0 * ps.size()
	var r: Rect2 = Rect2(w / 2.0 - 270.0, BAR + (win_size.y - BAR - h) / 2.0, 540, h)
	var cx: float = r.get_center().x
	if good and not low and t < 6000.0:
		var ctr: Vector2 = _P(r.get_center())
		var ray_in: Color = Color(1.0, 0.82, 0.3, 0.3 * clampf(t / 500.0, 0.0, 1.0))
		var ray_out: Color = Color(1.0, 0.82, 0.3, 0.0)
		for k in range(14):
			var ang: float = k * TAU / 14.0 + now / 2500.0
			var ln: float = 420.0 * _f
			draw_polygon(PackedVector2Array([ctr, ctr + Vector2(cos(ang - 0.08), sin(ang - 0.08)) * ln, ctr + Vector2(cos(ang + 0.08), sin(ang + 0.08)) * ln]), PackedColorArray([ray_in, ray_out, ray_out]))
	if good:
		_grad(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color("ffd65a"), Color("b8770e"), Color("fff0b0"), 16.0, 3.0)
	else:
		_grad(_R(r.position.x, r.position.y, r.size.x, r.size.y), Color("1e2a3c"), Color("0a0f18"), Color("5a7090"), 16.0, 2.0)
	_hit("panel", _R(r.position.x, r.position.y, r.size.x, r.size.y), false)
	var title: String = ("HOÀ" if text.begins_with("Hoà") else "THẮNG!") if good else ("PHÁ SẢN" if broke else "THUA")
	var pop: float = _ease_back(clampf(t / 350.0, 0.0, 1.0)) if t >= 0.0 else 1.0
	_w(title, 34.0 * maxf(0.3, pop), ON_GOLD if good else (RED if broke else Color("9fb4d0")), "c", cx, r.position.y + 38.0, 500, BOLD)
	_w(WHY.get(str(game.get("why", "")), ""), 15.0, Color("5a3a05") if good else Color(CREAM, 0.6), "c", cx, r.position.y + 72.0, 500)
	var stake: int = _stake()
	if good:
		var share: int = str(game.get("share", "0")).to_int()
		var k: float = clampf((t - 300.0) / 1200.0, 0.0, 1.0) if t >= 0.0 else 1.0
		_w("+%s Bạc" % num(roundi(share * k)), 28.0, Color.WHITE, "c", cx, r.position.y + 106.0, 500, BOLD)
	elif not me.is_empty():
		_w("-%s Bạc" % num(stake), 28.0, Color("ff6b5e"), "c", cx, r.position.y + 106.0, 500, BOLD)
	var order: Array = range(ps.size())
	order.sort_custom( func(a: int, b: int) -> bool: return _rank_of(a) < _rank_of(b))
	var y: float = r.position.y + 134.0
	for i: int in order:
		var p: Dictionary = ps[i]
		var row: Rect2 = Rect2(r.position.x + 22.0, y, r.size.x - 44.0, 48)
		var mine: bool = i == int(game.get("me", -1))
		var fill: Color = (Color(0.35, 0.2, 0.02, 0.45) if mine else Color(0.35, 0.2, 0.02, 0.25)) if good else (Color("23508f") if mine else Color("16396b"))
		_round(_R(row.position.x, row.position.y, row.size.x, row.size.y), fill, 8.0)
		_w(str(_rank_of(i)), 21.0, GOLD if not good else Color.WHITE, "c", row.position.x + 22.0, row.get_center().y, 36, BOLD)
		_avatar(str(p.get("av", "0")).to_int(), _R(row.position.x + 44.0, row.position.y + 4.0, 40, 40))
		_w(str(p.get("name", "")), 16.5, Color.WHITE, "l", row.position.x + 94.0, row.get_center().y, 200, BOLD)
		var tag: String = "Phá sản" if str(p.get("out", "0")) == "1" else ("Thắng" if str(p.get("win", "0")) == "1" else "")
		_w(tag, 14.5, Color("ff8a7a") if tag == "Phá sản" else Color("b6ff9a"), "l", row.position.x + 300.0, row.get_center().y, 80, BOLD)
		_w(num(str(p.get("asset", "0")).to_int()), 17.0, Color.WHITE if good else GOLD, "r", row.end.x - 12.0, row.get_center().y, 110, BOLD)
		y += 54.0
	_w(text, 19.0, Color("2a4a05") if good else Color("ff8a7a"), "c", cx, r.end.y - 86.0, 510, BOLD)
	_btn("home", "Về sảnh Cờ Tỷ Phú", Rect2(cx - 130.0, r.end.y - 62.0, 260, 46), true, 18.0)
	if not good or low or t < 0.0:
		return

	for k in range(12):
		var u: float = (t - 300.0 - k * 50.0) / 700.0
		if u < 0.0 or u > 1.0:
			continue
		var side: float = -1.0 if k % 2 == 0 else 1.0
		var from: Vector2 = Vector2(cx + side * (r.size.x / 2.0 + 40.0 + k * 6.0), r.end.y - 20.0)
		var to: Vector2 = Vector2(cx + side * 180.0, r.position.y + 106.0)
		_coin(from.lerp(to, u) + Vector2(0, -60.0 * sin(PI * u)), 7.0, 1.0 - maxf(0.0, (u - 0.7) / 0.3))
	if t < 4500.0:
		var fade: float = clampf((4500.0 - t) / 800.0, 0.0, 1.0)
		var cols: Array = ["ff5a5a", "ffd23f", "4cd964", "3fa9f5", "d16bff"]
		for k in range(46):
			var fk: float = fposmod(k * 0.618 + 0.1, 1.0)
			var p: Vector2 = Vector2(fk * w + 20.0 * sin(t / 300.0 + k), BAR + fposmod(t * 0.12 * (0.6 + fposmod(k * 0.37, 1.0)) + k * 37.0, win_size.y - BAR))
			draw_set_transform(_P(p), t / 200.0 + k, Vector2.ONE)
			draw_rect(Rect2(Vector2(-4, -2) * _f, Vector2(8, 4) * _f), Color(Color(str(cols[k % 5])), fade))
		draw_set_transform_matrix(_cam)

func rules_title() -> String:
	return "LUẬT CỜ TỶ PHÚ"

func rules_text() -> String:
	return """• Chọn gói 100.000 hoặc 200.000 Bạc, rồi chọn phòng 4 / 3 / 2 người hoặc Ghép nhanh. Chỉ ghép người cùng gói.
""" + "• Ghép nhanh đợi đủ 4 người; chờ lâu thì nhận 3 rồi 2 người.\n"\
	+ "• Gói bị trừ khi ván bắt đầu (Hủy ghép không mất gì). Người thắng nhận cả hũ qua thư.\n"\
	+ "• Mỗi lượt %d giây, hết giờ máy tự tung / bỏ qua. Bấm ĐỔ để tung 2 xúc xắc; tung đôi được đi tiếp.\n" % turn_s\
	+ "• Mua Lẻ / Chẵn: trả thêm tiền để tổng xúc xắc ra lẻ hoặc chẵn.\n"\
	+ "• Thanh lực: giữ ĐỔ (hoặc phím Space), kim chạy qua 4 vùng tổng 2–4 / 5–7 / 8–10 / 11–12; thả tay ở vùng nào thì thêm 30% cơ hội ra tổng trong vùng đó. Bấm nhanh là đổ ngẫu nhiên. Đã mua Lẻ / Chẵn thì vẫn chắc chắn ra Lẻ / Chẵn.\n"\
	+ "• Biểu cảm / Chat trong ván: 2 giây một lần, chữ tối đa 60 ký tự; nút Ẩn tin để tắt tin của người khác.\n"\
	+ "• Dừng ở đất trống: được mua. Dừng ở đất của mình: xây nhà (tối đa 3 cấp). Dừng ở đất người khác: trả tiền thuê; đủ cả nhóm màu thì thuê ×2.\n"\
	+ "• Lễ Hội: chọn một ô đất của mình, tiền thuê ô đó ×2. Bến Xe: lượt sau chọn ô muốn tới. Côn Đảo: tung đôi, nộp phạt hoặc chờ 3 lượt.\n"\
	+ "• Hết tiền là phá sản: mất gói ngay. Rời bàn giữa ván cũng mất gói (máy đi thay tới hết ván). Rớt mạng: máy đi thay.\n"\
	+ "• Ván tối đa %d phút / %d lượt; hết giờ ai nhiều tài sản nhất thắng. Máy chủ khởi động lại giữa ván: hoàn gói (trừ người đã phá sản)." % [game_min, max_rounds]


const ICON_B64: String = "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"
const WORD_B64: String = "iVBORw0KGgoAAAANSUhEUgAAAIQAAAAoCAYAAAA/mlIyAAAdJ0lEQVR42u18eZRXxZX/51bVe++79kqzdcvuAoqyCgraIGJwidGMqImTIZq4ZjTGjGM0OohmMknUqGMSMxoTjSYqLVFj1IAotKKigKggi900Ow1Nb9/9fd97Vff3x/fb0CBL60x+c86Ee847fZrqqrp163Nv3XvrFsAROkJH6AgdoSPUI6IjIjikHPiIaP7OaCYgv0jbEQvRsz6H0iiafYi+cwDzv7R+BoCvTx5QfnTlYEYZ0LKhnR5esioFIPj/wcRsQKw5iGzqCnLhLwL0EQfpdyhZ9xQQVFsLOaUe5lCDdWnUoRdBAHWbls0XEuB/dxMWA6IeCKbWWF+PhNQt2Yxb7btMAKAsIBIPteYDfvr1zfm7cehNOSTQ96c1ALXUgnrXg+sA/beHvPhcsqaeIK0747W1taGJvdNOKBIr9u1E+y7HPDTh7DTmzOk+owBguvpP7i/PLI9Yt3V2upo1JAgQArq8LCxTLj/yxjb3mf3nOizr9AVdoKJgJlerCWVha6mXdXHcqOE48dQxkILQsLoBK95ahohjIRXgzoWb3DmH560H/DDvg6vimGbGYGukbYtKqBBUsU0HYA5cavXE+ne25nZ0t2Y9IGvGkPDjFPj90qnAgCCMgYnFhGDL2bZgY+6KovX7zJjqcJo4B9Bje0X6VZXjMjL8pdz6+qHvrEYJGwgDQBTkEExbtaIlfExsVd7X817bmJsHwMwGxOIi6AiiRhGmnjplDJRjQxCQS+fQuHodlKJqAPNaAD6Q9hetEgHgcf1DR/UK4bd+1pX5PDPo8x17zDAlcSEDaX8ohUx7mSyf8dWz/JvuudWywhVFkaTx1yfrggdvv18oqS4AMGcuYOizsjG1NdYJsZD8z0zS5cDng3JDAlAKRtlWQtmhNRnff6Vus/suABjIB0VgpqRTib3diRCLOLBgrgPwcC0g6w9zhNUCqh4Ipg4Kn23BfD3eqxxja48G+z6k46B5wyY0Nu3aMXbsWFqxYsUBx1CHAYM5c6BzrWPhLj+T7SWlwPCRR2Pw8GHo3bcXlGUhl8lix5ZmNKxaV7Vzy67jnbB16TnDIm+3dQaXz2n1GkaMgMIawApZSCWzwejTxptLbrheAklAG1x79uWmaW3TMWcMjs94Y2PqpfqDmzgCwNJSMWjvzONGHo3yPlWADnpuKRiAlNjZtAlNW1rjWugFZaVRc/2d15MV7ksr33gZzVubMeOSczHjGxfJN19eJOpfW65BAsSG9zf9ACCUUyGMN/Wk8SMQLy8DtD6g3dVaI9GeQPPm7Uh1pr4aj4VuP3to+JmWbNm3cqmd7ceOO8Zcc+d3Ay+bVyJko33HzuCB236uTOB5PQX7FMDUAwgpujGdyJtr7pgVnPPNWRLIwk+nzDUzriDAZA81hjrYMTEH0NMGhe+N2fh+ojOLk6eODy79zjfoxHEjSYQjtFeRGYBGcnc7v/nyIn7ygcc52dY+qVdZaPGpRKdPX5PfOAdAoPXmeNRRv733t3r0qaPlsBOHgywb51xynrj3B/dzPGx+dc7g0I2ptGuZoDBoPC6lkda6BRvdq2cXLAUiIcekW9P5i666VE256GsMdFDPgwEDoMz88pYfiI8e/nOyvFdYhWwlH/7Rr6QdieClJ1/AgKFHYfpFZ0NAIhaPFTB5CGMddqwg3ZnW37rlah552hkEpHBgF8fAZF3s2NqMBfPm87zH5pJlgkt7x1JlHbtZxkvjYsSEiQrsClAIHds2CkEkuDAYpQtc0MGc9z17NjB0is57U/oO7IPTz621dWYXZDSKB2+/D03rt8hwWXTnohUrTFHh+bCA6DorpxzlXB238f1k0vWvuvVKeel3L1cgAeSy8BOd+/joRISS0iid982vYdzpJ+OOb9/qb2vY2L8kHvr9nN04feZMyLq6/KIvDY08Q9q79Nc/eljfV/eQJNY488Lp9Mwjz6C9eXdNKGzXTJoyFk44BAjC1vUbsHlray8QFc/fPbZCujlX6qCTdTpFUsqijAgkaD93YW8/ow1kHOR7gSABm0nt7kjmGl586pUyE6Dqom9/mS+/+UqyouX4aNFiLHtrGWKlTmh2Z16sAWgEwPs71cwgIshcNsfGpMik0xBSgA3DmL1/SkRQSqJm2EBccduNGH/6ePzb1Xdo4bozQiHSeV/DeClhcnmISIBsuqDITNAAeAXgdzN0dDEg6gDddcS+NwxqdiN4qaW+FiRcOvfSc4NYVT8FaHyw8C3+69z5FCuLcCpnbp4N8OJCv+BwgKC6os8Qdfinic6cuerWb8tLb7xWmEw72BhIpWCVlhe1zTAgCTAwmQyM24q+QwbgR7/5sfWdC64L3HTq1GmDwufV1eX+PHMm5Pt12cuPHxaZ8NHSjwa98NhcM+MfLxQiHMbUc6fiD796lsMltrn5nttQMXAQAFvfd8NN8pM1r6VBYl9AMHQoHCKpyliWcdFCGAFjCPluFpYIiDoAyADE0miCiMO2LUgpSl7b4t4Dbe6prbYeHD60/w033jvbB8Lqz795VDz8779mWwKWYy2aQ77Z3yH8jI9ABCEEIAQEERCPQMIuepJEAANBDiaXgzEZjJw8Cf/y45vk7OvmGCkgiQhCCkAKCCkKYwFQQkS++5WTyqRWSssgWN+cMfR+YxIFB5cKACWgifJ/JeBM36CyTykmTZ/M6USbcRNp8V8/+bVxbCW1lHPqt2eW1u81l4c+Mrocl6pScYWfzZSefMb44NIbrlA62wEBQDgO2BjMf3Ier1iyjHOZrCirLNdTvnyGHDdtEiiXQ5BIoM+QoZh14z/hgVvvZ6ckOgvAi3V1MGcNDp9LhKzlKNx/xy/w6M8eBTMDzPBcTalESubzLoybhAjZ0L6RRPva36ybF+Ux23nukWfw+ouvAzqAkBKZrIthI4bhmn+7Huz7IKWQ6ujEfdfeCy/nCqUkjDEwQnHjqnUQbIacVmbeIAOjDB/X0ZHCT6/7gS0tC0sWLIHnutID4HmYOLkMbygLFI6FuD1vrn5vu9fQUgtC/YGcVgbsEFa89jY+XrYakYhNgdYIRyJ8+ozTqdeA/iDXhc60Y9J5Z2DU758X7yxcCRL7HjPGGGWIYEH/+wdLPrpLm4Lq2WHhnTMs8mk6F/zHm9u9hWcPCf3Zc/OO5xb2101nj0kLG7de/gOLwHBdD20tCSkl4KW86ZMrcFpZiU0eRP2CTe6cLl/xgICoL4ZVzMFXhJQ864ZZBCJAG8CykM/7uPs7s7n+pbfJdkCBQcYSiL70h1f5+ruuo4uumwWZSQN+Fmd+ZbqY+/AfaUdz66CRpaXl1b2831tszksn8qgeUo0RY46n3n16wXJsCEEwhtG3pi/61PQtOGawkEykIMW+iqn9II2QWLhuVYPML29gooIsMxmcmHfzlRDEzExEBN/zeflbyyjR7jaRxGYQyogx+vixx+LokcdFyQRThVTY+OlGtDS34s/PLmwgBsXj9rDqQdVcPWQgCROME0oh1d6BhrUbIIUsBYB0+sDxhDEGUjl4Z+Hb+M29L3BZBbIAojoA/enxeXig7iFU9usNzrmAdDB28jjUv7KyYFW6x+xCIJvJorKyrOSUL01GVe9e6OxIYuWSZdj86aY+JdHIaacPoKsD30w65rjB8cr+fcFBAFYKO7dsx6aGrZ0k6OOQY50+vnYMW7ZNivhUEGHTmgZs353MdneODwQIAsAzRvWtcnfuOnbkmOE0fMwJgt0siAAKhfHkzx7gRS++jap+sayn6Z+VE1+ogvRNIT9/4+/ufcybOPUU0W/IAOhMFuHyMnPciceKxoZdorpKz7V0cCaUHVx/99XyrJlnU7S8vOh8UbfpNTiTAkVjWPvu+1i9fDWiJQ7QnsedhfMby3e4WwFM3zfuF5jcy7wYj0XOhyQDQAIMKaUuLYmpvG8eXrg1uPfiCTWTWjduWzL9gunmwmuuFvA7NKwKvPLE4+b+W+61yvpUPEEE4bW133XZP/+j/tJllyl4HQZ2JT91z8+xYulaKu1fCWzNHSZRyyYWi4jSSrW9vsUfet7o3sMtz/vL1g3N1UtfW8LnfesyYbJZgA0qe1dCCID39gUEIZvO4ISxJ+CWB+7gPgMH7JnBTaXwy9vv06/OfUXFS+N3dexKeWdf8mX95auuAvxWwKqkFx5+WNzzw1+2hypi88NhdfrsX8w28b79JeAbwA7+9cIrZMPGtsyBvGXVLcykOQBznnv7HsdOGHci4MSgU51Q4RASzTsxf958Lq2wKZXVl76xNfdSwaPG984aEqqJKVx026ybEY1HYLQBCYFUZwLlFaGToD2QEzH/8dufqBGnnALkEwhSGShHFrJTrl8wtQBULIaXH5+HX9z5EFuSwUTvAsDFBfTovZnKwlHTDMh+0HqBJlVw4mQh6CcJQMAYg8ALnNlsxHvtnR4J8Px58+m8b3wVAiwFdWDMqeNErDyGbDZ9JTMQr4hj1MQxkv0ETKCFn92OhS8sgBOWfjbndx48xyeLIBfkBwaeG8TPGhS7LQj8YUpwJQPoO7CGAAMiCSaFdDKNgu9JBb6FBAKDiqpeuOOhO1FeM5DgJhD4GgQgFA7hez+9Ra1f3cBbN2zqY1mAm/dgTBZeOge7NMeeF4AASVpHmSXcXB5RzwV7npBWIA3zZ47ig0YZLIwSAuKoQX0AkyMOsoBU2LhmrU61dUiEws+/sSn70lVjYa1fAZ4CmAU5cweFRHvLll3GaN6j8sqSJh51ZmaSbsV37/wOjThlFPyOLVCWgopYaNnUgkw6x4OP6U8QBJMPAB84cdzRiMTDMpfOsiF68lC5+JkAPQJpTgUYMIDOFT8NGLdrr4I5gMGnyZUzBodWbl6/cUzjhx+Z4aeMEjqVQN9BVXTMicfig7dXDgQzjh45En0G9KIgm4CKx/DhW8t186btwg6F3nl9Q7JxNiDWrIDZJ7XDHmByhU875DhAZaVVWtXLmh1oASaFcy45B+NOHwXOtEEyg0wSq5Z/BKkAsAZ0DmQ8wHVR3jsGEKFp5Qcoq4ijon85kA8QZHJQJeU48/xaevjHhSOTEEDAheA8BFxQIXhgpoKciPMQyIPZw+GuRj6bh/AyIKkQ9ZYD21qBRB5IO0g0bGTNEoLMvJmAXL8CXA8E9QDQ7K0DcPWBYu+p1f7MY4+rpDNP3sFm7c8hGaCwwtO/b8AfnloLHQQ0emw1fnj7aEQiCoGncVRVDOefV2Oe+N0aGSpxhgNY1nLINLspaFe+BdjyKJALAFsCbS5gvOIyPQAISIpnvRyPefO5R8zwgWOFbnchK0I4ZTTw/puCAWDCKBB2/Q7c7gJlDt6Y+x60kSQk/REAFtdC9K7vkmoOEBbQ8hqwbS1kygN2CVx6Th5fnTYdUomAjSHLsqVdoYCmR6F9DVXmYMOSNry3eBlH4opMbiew5TeAZ2AYECGJXz24Cs89t57LysJ0990TcfzoSiDjA3EbQyp3QNk2+b4BEiuAHTmg3QWyISDxCSBEQS4cADvmAhwFPA1YEsi37m3vSWKKGXAzWcBPA54H5H2EbQ0hCGQwsQ74w9ixsLACNBMQW2tQGhf2NC0lQ4OYmZhIWwrV2ZRXPmZUJaTtwu/wYMUsNKzcicceWQllSShLuIsXNoWOHax41rUjiFN5cMLDyWNK+dmnFQLf9OkKgQ7k1e9zc8IGyKcLC4cA/M8m+VyoeVIFd737zg571mWD2LElIZ3HyaNKEY1axMwYf1IJkE7AEozklgSvWLZTClskOwJ6EQDq66Fn7p99CvKAlwZ8H9AERxCciCzKWIJNgGD3LigloeIWOrem8JOfvGdMYIQQBBgDeBlwXkPYEh1bXcx/tQGRsKTdLWkseOVTHD9qFDifBxwfjvSwJzDRXnGv8oAfFH4v5kjAAPwskAfga4BFQU50cDHuq2uCjGHmnTtdgImJCcgzBtbEZDiiWDJ/c3x/+5gVK+DPHAGrDtBR4Xy/JCTn2sbUhaWZG1b8bESa56IKD0pBorpfGNBErAlQEh9+2K6ZCcqRP8qDpkbjtvfhx51ARrMkAfIYVRUhxKIKQfA5bkO5Kz2yn2UsrnLmCNiLGpMbLEcsad6Ro1UfdhhyJHRGo/+AGAYNiOKo6ihqBsag0xpwFN5f1qZbW/OsbDn/vY2ZXTNnQh7Q5hoUbjsMFTwdJYCwBEKCERJMEckq5rABmaWLm/WNN73nb9ucFcqRjTnPLJMEwICLRh6ZTGCkkAgYL0GITToA4DMTd5ur+9ya9v4s5OiYQP5e3rp9PUldzyn+dIzT7sl8bu3ajgiyPiQbmKyHPtVhGje60ixc3BzrV+a8eOYQvrhujb/qS4NCF9sKNyVzOvjh909A9cAY6VwAGVV44vFGWvBGs7AkAYEGjAYCDc8rXBoaMk1ZGfskjGSgA2PBD0AagGYI5kIQ8blux7kQImtT2JT9wNSSKUCDSTytdTBt0VvNGD+pCsbXkCUWxp5UAc83gC3AKQ/IB1hU3yxIgAzjKQDUUncQ3TIGCDTY10BYYsW7u/DxJx0IhyQxA0Fg0NrhoaExSRs2JKGkkMqR6zsDfT4MfiTA48HGQBsJX0OwYQKQ0/yCH5iYBA+CNozAEAJdWOOeubkg38AU5cxgICzAI4kADgztkYs49J2p2g/jiDS07/QHOZvXrEsM396U5P4DY8SuBuc1rpw1TKz9NGm2b88cpxz57hlH2avZ8ITdbT4uOKeGa8/sR/C5YI4Mo7UtDxCwuyUHGAPSBvACHDMoJrQBpKZ7K2X25kTeRAYdFWXYgnTSg7QtdLbnkM1pKCU+n4XoWnjwWUDsjhbWmDD0UlSJ5AcftpUkd2S4pNQmpD2cMbk3tGYg7UHZAs1NSfPJmk4hLNrenM69DoDrD3YFbhgITAFcMYl3l7bg0ac2mrJSlTSamQESBCMtSodD1gbN/Jd1bbnHmjqQmNRLlDAX+dWmaGm4a1hJKJp+owvA6/pAxcixqAiFf6cgMJBC9A1b4h98zZAMUQALo3BHzYc8efe5Pq0DtJD0Wjbro+7FLYYkwIEBcj769HZw/92jxLnT+5uavuFov0pnwlH9w3zNrKF807XHkEl68BN5sDF47+1d+HRDkuMxi1eu6gByASQYnPIxZnQFnXFab3Qm/IpUwh/et18YF18wgOAG4MCAiPHx6g5kswELh5JdWbNDk9grGG0KwjVmn7VXVcHMnAn5blOmxbLk/NbWPC9b2aphEXTGx8CaCIYMjMKkfUABS5a2mFTah1TiTx/vQqa2FuqA0qSihejaMG1MNCxRUqqaJ0zod/zkCdVDT5tQPWTMqbGhVQP6HvdqU+6M+Rvdn2/sQAKAABVB1gWIrg8MArig1VxsL/4sAoa7rJPWIGMAN8BxQ2NQirCr1cXwo0tQVmGB80HRipkeWwjUF61EytOPlIbVd15e2EwTR5XzxCl9KejwIAKD3pUObv7eCOElPPa1MWFHShGzgFwAnTewbIEg4+PxuZtYEFEkLPHRmk5evbKNThhbiSDhQTkSP7xhOKZOrOJUJuCJoytERZ8QdNqHsgT8Tg9/ea1ZKEuQZnwEAL17WhzS3TSaz2pD0eQTCH8kwszFS1rEtNq+IGPAHu/d35SP+nd3SyEFPMbTALA3sjiIheia2xiYwCDQbCJOvHVO3Zpu3m0CxToRUZR5sAfMpgsMxexw99Ope3sX2IvUmfCAwEAYBmd8jB5ZjvvuOBHbduQw5dQqCOaCoomi78E9tBBdFU5vb/U/CTT+M+II+eNfrPdXvN0CVSIhBBBkfPgdLiwBitpCQjP8dhcmryFDAsyMex5aqxubUmTbYk3W44csQXT/Y41BsiUHFZXQuQAUaJw2qYrOmdFfVJRaCJIepATIIfzXE41605YMSUt8srAxt4KLl26HK6Biw4AXQHt6z7c/9QZ4di2kz6FFpETz6nVJsXtL2ghFQGDAgQZZhIZPO03TpjRJJVa9vsF9H4fhwQSmMKevYfJ6zy3rhs42q7izXWlZmlOoWwi6g5wZQDe+ta/3ATMbhsnvbTOBATPDtgSvXN0J5AIQGMbXMFkfo0eW4csX1iAeFsi252F0gT94uogH0bMoo64IiqZN7q15g9fJsH37zz4Jnnh8g04kPFYRASsqQRYBiiAcghVTEA5xY2PC3HL3x8FrS3bLSEQhG/ANCze73ydF27btyKqb7/7YX/dJJ8uwgAiJggOUDwAFqJhCIuHx/Q+uDf701x0UiyrKBeYWAP7FPaihNAxWghgxxVZUsoxKLosqLtpd7rY+PacewcKmjoRl0wuZTIAly1oNBGC6HDMw3lzaavJ5A7LwLABdW3vwogtmcCwsWEYlhyKSRUyyU4hgOeKIrmvS7t/+rg8rgX14L43IPX/LBmwpKowbKbTHQoK1gQmHJK3dkDLPvbCVRVRChgSEIwBieO15/Pw3jezmfJZlimVEMqKKpQAzHdjaHSgPwcUi2Xxmo3v+SYOdX1uKvvHkvK1Y8GYLxo0sw3GDY6aqwoYlCdm8wY4WFx+uS4oPP0mQ7xsRjcjORF5fWb/Fex0AOnL6/IqIenHr9txR/3L3apw8qgxjRpSavr0cKEFoS/lY15Shd5a3UUtbXsUiCklX37R4q/dyVxnf4QARskm1tOXpj79vUtAMEoRsTltaMyQJCQCL66GnHOVcaxGPzPso9/PmtEQ2wNKPOuSFZ/cHaQNSAm6bi7eWt0uphBdoM7eYezhgvOMHIMcW9OriXfTxp0loz0A4Uq5an0TYEdaO5sOfco5NaldrF+8GJAUSSV8xA6whQiGpmjZn6I9PNEn2DIQt0LLLhaWIXN/8KRqSX3107mY0bc2YU8aWoyQssbPDw6uLWmhNY4pKoxKRiARrAATV1uEhZJH6PCV0DICagWzzxvw/nTHQfjockVfv7vAmvbBwZy8pSEhBe+pW/MCAiYJISG5RtvjLziQ/uLzFayoW2/C7O/yVY3v5E/qUhG4zzBe8sbStZvHSNiElFf0xRmAYti2STli+k8yZn9Zv9xZ3VQH1xHVwbJFo3u12/OqpTYaIRMEukq4oUZIkZbtOlWmC/6FPTE2LxCwwA/16O5h1fg3BC2B8AxWRqF+8W+/YlRO2o95+tSnXsP8V8b75KPJDIXS8vLilkDMhAjNzJCwp5Mi2D3c1H9b3sfbwvnEP7yTIlMekCDS50ZBMrN+c6Vi2JlG4xmWGkMSlMSWyPu51A7PMscRtf32rJb5gSQuEIOiiUoRskXzihW3aGO7aLlMes4RjieQXqbqm2XuKMIDx/eOVFSV6YFiJuPFZdCFKCwoyAVo3cbqpsRH5/au1uwv02ErEh1ZEhoZtKvODwvxKAb42ubYMthQrjHGoTThggWkVYtV9S62jh4DzxXEdBV6+EpSmRK73Zvh1gD6lt5o3eWTp+T+56RgTeGzZUUlgQOc0ZFgglQxwzd1rgs6UrzymSxZucud2Fa8erLA1NgDxYYNLORzrmreMG5o6qSWTMAubkDxctfSBeM+lwY0bQZFYItOyG/aB2jdtSqBzENL19Qgm1oSre8flUCVY6gAsFSibN7l0Wm6YPFbu4d1R4IYm0O6WhPfaLmS+8Oumnr6FmLn3yu8z4OrJS6jZgPhbvJjqGvOUPuqFf51WyfzKxMA8P4H18yczvziBecGpnHv+ZP7BWb386TU2nz0k9AEA63/iDcjfmv4n5aV68kfdvGuaDdCBXhnVFR2mQ3jiXW2HHOO/8YKrp+X4BswaAposgDQjlQ7w8ced/ORfdmLD9pwKhaTb6QVXAvDX9EzYX/Q1W0/7H7K9KFcx88AyNZ+Ht7+bx75dR9i0AfaCPiVq+oC+YSgJZPMGLR0+Wto9CEFQijZ05vyrl+zQr3/eY+v/Aqm/l4V2vXNkwuJExqi3VycNAyQJJBXlLSW2gPDOug73+cZ2JP8ewXCEDuHH/L2unY5s9t4HuKjfU2h85P+FOEJH6AgdoSN0hI7QEfoc9P8AbfQEpxMWPSMAAAAASUVORK5CYII="
