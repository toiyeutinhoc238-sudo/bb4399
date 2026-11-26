extends "tev_window.gd"





signal closed(note: String)

const VoiceClient = preload("voice_client.gd")
const Settings = preload("res://settings.gd")
const KD_PIECES: String = "res://assets/ui/kd/kd_pieces.png"
const KD_CHESS: String = "res://assets/ui/kd/kd_board_chess.png"
const KD_XQ: String = "res://assets/ui/kd/kd_board_xq.png"
const KD_UI: String = "res://assets/ui/kd/kd_ui.png"

const KD_SOL: String = "res://assets/ui/kd/kd_sol.png"
const SOL: Dictionary = {
	"avatar_ring": [796, 1046, 80, 80], 
	"board_frame": [2, 2, 516, 516, 48, 48, 48, 48], 
	"btn_blue": [196, 1046, 188, 88, 24, 21, 24, 21], 
	"btn_gray": [2, 1046, 190, 88, 25, 22, 25, 22], 
	"btn_orange": [696, 954, 190, 88, 25, 22, 25, 22], 
	"card": [2, 522, 172, 128, 26, 24, 26, 24], 
	"card_turn": [178, 522, 172, 128, 26, 24, 26, 24], 
	"clock": [388, 1046, 200, 80, 18, 16, 18, 16], 
	"clock_low": [592, 1046, 200, 80, 18, 16, 18, 16], 
	"end_box": [522, 2, 304, 244, 42, 42, 42, 42], 
	"field": [2, 1138, 162, 64, 21, 18, 21, 18], 
	"icon_chat_off": [168, 1138, 64, 64], 
	"icon_close": [236, 1138, 64, 64], 
	"icon_down": [304, 1138, 64, 64], 
	"icon_flag": [372, 1138, 64, 64], 
	"icon_hand": [440, 1138, 64, 64], 
	"icon_max": [508, 1138, 64, 64], 
	"icon_mic": [576, 1138, 64, 64], 
	"icon_mic_off": [644, 1138, 64, 64], 
	"icon_people": [712, 1138, 64, 64], 
	"icon_restore": [780, 1138, 64, 64], 
	"icon_smile": [848, 1138, 64, 64], 
	"icon_spk": [916, 1138, 64, 64], 
	"icon_spk_off": [2, 1206, 64, 64], 
	"icon_up": [70, 1206, 64, 64], 
	"panel": [566, 522, 106, 106, 21, 21, 21, 21], 
	"ribbon_draw": [2, 854, 544, 96, 92, 17, 92, 17], 
	"ribbon_lose": [2, 754, 544, 96, 92, 17, 92, 17], 
	"ribbon_win": [2, 654, 546, 96, 93, 17, 93, 17], 
	"row": [354, 522, 208, 112, 24, 23, 24, 23], 
	"win_frame": [830, 2, 140, 140, 38, 38, 38, 38], 
	"win_head": [2, 954, 690, 88, 45, 15, 45, 15]
}
const KD_TIP: String = "Kỳ Đài"
const UI_R: Dictionary = {"btn": [0, 0, 50, 50], "word": [52, 0, 58, 20]}
const XQ_ORDER: String = "KABNRCP"
const CH_ORDER: String = "KQRBNP"
const FILES: String = "abcdefghi"
const START: Dictionary = {"chess": "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", 
	"xq": "rnbakabnr/9/1c5c1/p1p1p1p1p/9/9/P1P1P1P1P/1C5C1/9/RNBAKABNR w - - 0 1"}
const KIND_NAME: Dictionary = {"chess": "Cờ Vua", "xq": "Cờ Tướng"}
const NORMAL: Vector2 = Vector2(940, 570)
const HEAD: float = 44.0
const SLIDE_MS: float = 180.0
const BURST_MS: float = 420.0
const CHAT_GAP_MS: float = 1500.0
const CHAT_MAX: int = 80
const QUICK: Array = ["Chào bạn", "Nước hay!", "Nhanh lên nào", "Cảm ơn ván cờ", "Thêm ván nữa?"]
const REASON: Dictionary = {"mate": "Chiếu hết", "repeat": "Lặp nước", "fifty": "Luật 50 nước", "material": "Không đủ quân chiếu hết", 
	"limit": "Quá số nước tối đa", "time": "Hết giờ", "leave": "Mất kết nối quá lâu", "away": "Rời ván", "idle": "Không thao tác", "resign": "Đầu hàng", "agree": "Hai bên đồng ý hoà"}
const WHY: Dictionary = {"off": "Quà đang tắt", "short": "Ván quá ngắn, không tính quà", "sameip": "Cùng mạng với đối thủ, không tính quà", 
	"samemachine": "Cùng máy với đối thủ, không tính quà", "cap": "Đã đủ lượt quà hôm nay", "ai": "Đánh với máy, không tính quà"}
const FRIEND_ST: Dictionary = {"free": "Rảnh", "chess": "Đang chơi cờ", "busy": "Đang bận", "off": "Chưa mở Kỳ Đài"}
const PIECE_VI: Dictionary = {"q": "Hậu", "r": "Xe", "b": "Tượng", "n": "Mã"}
const MIC_TEXT: Dictionary = {"off": "Mic: Tắt", "hold": "Mic: Giữ để nói", "open": "Mic: Mở liên tục"}
const MIC_SHORT: Dictionary = {"off": "Mic tắt", "hold": "Mic: giữ", "open": "Mic: mở"}
const WOOD: Color = Color("2a1a0e")
const WOOD_HI: Color = Color("5a3a1c")
const TALK: Color = Color("37e27a")
const LAST: Color = Color(1.0, 0.86, 0.25, 0.38)
const HINT: Color = Color(0.08, 0.32, 0.12, 0.55)
const SOFT: Color = Color("bfae94")
const PAD: float = 12.0
const RAIL: float = 15.0
const CARD_H: float = 48.0
const PTT_H: float = 44.0

static var prefs_path: String = "user://kd.cfg"
static var _kd_tex: Dictionary = {}


var kd_visible: bool = false
var token: String = ""
var kinds: Array = []
var minutes: Dictionary = {"chess": 10, "xq": 10}
var wins: int = 0
var cap: int = 0
var reward: int = 0
var test_mode: bool = false
var queue_kind: String = ""
var queue_ms: float = 0.0
var queue_at: float = 0.0

var ai_on: bool = false
var ai_full: bool = false
var ai_hint: float = 30.0
var ai_reward: int = 0
var ai_level: String = "normal"
var ai_kind: String = "chess"
var ai_hinted: bool = false
const AI_LV: Array = ["easy", "normal", "hard"]
const AI_LV_NAME: Dictionary = {"easy": "Dễ", "normal": "Thường", "hard": "Khó"}
const AI_LV_DESC: Dictionary = {"easy": "Máy đi nhanh, đôi khi đi nước chưa hay.", "normal": "Máy tính trước vài nước.", 
	"hard": "Máy nghĩ kỹ, tới 1 giây mỗi nước."}
var ins: Array = []
var out: Dictionary = {}
var friends: Array = []
var active_id: String = ""
var game: Dictionary = {}
var board: Array = []
var moves_from: Dictionary = {}
var clk: Dictionary = {"w": 0.0, "b": 0.0}
var clk_at: float = 0.0
var clk_run: String = ""


var screen: String = "home"
var tab: String = "chess"
var maxed: bool = false
var chat_open: bool = true
var mute_opp: bool = false
var quick_open: bool = false
var _itip: Array = []
var mic: String = "hold"
var speaker: bool = true
var sel: int = -1
var dragging: bool = false
var drag_from: int = -1
var drag_pos: Vector2 = Vector2.ZERO
var drag_moved: bool = false
var promo: Array = []
var confirm: String = ""
var pending: String = ""
var anim: Array = []
var bursts: Array = []
var anim_key: String = ""
var seen_n: int = 0
var chat_sent_at: float = -100000.0
var fr_off: int = 0
var _fr_rows: int = 1
var in_lobby: bool = false


var away_at: float = 0.0
var idle_ok: String = ""
var tip_later: String = ""
var now_skew: float = 0.0
var net_hook: Callable
var L: Dictionary = {}

var _reqs: Dictionary = {}
var _what: Dictionary = {}
var _busy: Dictionary = {}
var _writes: Array = []
var _next_poll: float = 0.0
var _friends_at: float = -100000.0
var _g_retry: float = 0.0
var _voice_gid: String = ""
var _voice_hold_at: float = -1.0
var _holding: bool = false
var vc: Variant = null
var chat_edit: LineEdit
var _prefs_read: bool = false



func _setup() -> void :
	win_size = NORMAL
	super ()
	chat_edit = _edit("Nhập tin nhắn…", CHAT_MAX)
	chat_edit.text_submitted.connect( func(_t: String) -> void : send_chat(chat_edit.text))
	for state: String in ["normal", "focus", "read_only"]:
		var box: StyleBoxFlat = chat_edit.get_theme_stylebox(state) as StyleBoxFlat
		box.bg_color = Color("140e0c", 0.96)
		if state != "focus":
			box.border_color = Color("8a5a2a", 0.75)
	chat_edit.add_theme_color_override("font_placeholder_color", Color(SOFT, 0.6))

func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew

static func _texture(path: String) -> Texture2D:
	if not _kd_tex.has(path):
		_kd_tex[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _kd_tex[path]

func art(name: String) -> Texture2D:
	var sheet: Texture2D = _texture(KD_UI)
	if sheet == null or not UI_R.has(name):
		return null
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = sheet
	var r: Array = UI_R[name]
	part.region = Rect2(r[0], r[1], r[2], r[3])
	return part

func button_icon() -> Texture2D:
	return art("btn")

func button_word() -> Texture2D:
	return art("word")

func load_art() -> void :
	_art_asked = true

func art_pending() -> int:
	return 0 if _art_asked else -1

func retry_art() -> void :
	pass

func _mg() -> float:
	return 14.0 if _mobile else 8.0

func frame_at() -> Vector2:
	if maxed:
		return Vector2(_mg(), _mg())
	return super ()

func _fit() -> void :
	win_size = Vector2(floorf(_fw - 2.0 * _mg()), floorf(_fh - 2.0 * _mg())) if maxed else NORMAL



func boot() -> void :
	in_lobby = true
	_read_prefs()
	_next_poll = 0.0
	poll()

func beat() -> void :
	in_lobby = true
	var now: float = now_ms()
	if now >= _next_poll:
		poll()
	if not tip_later.is_empty():
		_tip(tip_later)
		tip_later = ""
	if opened and screen == "home" and kd_visible and now - _friends_at > 10000.0:
		load_friends()
	_game_loop()
	_voice_sync()
	_sync_vis()

func poll() -> void :
	if _busy.get("l", false):
		return
	var playing: bool = str(game.get("status", "")) == "play"
	var gap: float = 60000.0 if not kd_visible else (3000.0 if playing else (2000.0 if opened or not queue_kind.is_empty() or not out.is_empty() else 4000.0))
	_next_poll = now_ms() + gap
	_send("l", "/chess.xml?t=%d" % now_ms(), "lobby")

func load_friends() -> void :
	if _busy.get("l", false):
		return
	_friends_at = now_ms()
	_send("l", "/chess.xml?f=1&t=%d" % now_ms(), "friends")

func button_visible() -> bool:
	return kd_visible

func button_dot() -> bool:
	return kd_visible and ( not ins.is_empty() or str(game.get("status", "")) == "play")

func button_tip() -> String:
	return KD_TIP

func minigame_active() -> bool:
	return opened and str(game.get("status", "")) == "play"

func open() -> void :
	if opened or not kd_visible:
		return
	_read_prefs()
	show_window()
	load_art()
	screen = "game" if not game.is_empty() else "home"
	if screen == "home":
		tab = tab if kinds.has(tab) or kinds.is_empty() else str(kinds[0])
		load_friends()
	_come_back()
	poll()


func request_close() -> void :
	if str(game.get("status", "")) == "play":
		confirm = "leave"
		promo = []
		dragging = false
		if chat_edit != null:
			chat_edit.release_focus()
	else:
		close()

func close(note: String = "") -> void :
	_hold_end()
	dragging = false
	promo = []
	confirm = ""
	if not opened:
		return
	if str(game.get("status", "")) == "over":
		_clear_game()
	elif str(game.get("status", "")) == "play":
		_go_away()
		if note.is_empty():
			note = "Kỳ Đài: quay lại trong %d giây để không bị xử thua." % away_s()
	_hide_edits()
	hide_window()
	_sync_vis()
	closed.emit(note)

func leave() -> void :
	in_lobby = false
	close()
	_go_away()
	_voice_sync()
	_sync_vis()


func _go_away() -> void :
	if str(game.get("status", "")) != "play" or away_at > 0.0:
		return
	away_at = now_ms()
	_act("away")

func _come_back() -> void :
	if str(game.get("status", "")) != "play":
		away_at = 0.0
		return
	var mine: Dictionary = game.get("p", {}).get(my_side(), {})
	if away_at > 0.0 or int(mine.get("aw", 0)) == 1:
		away_at = 0.0
		mine["aw"] = 0
		mine.erase("gone")
		_act("back")

func away_s() -> int:
	return maxi(1, int(game.get("away_s", 30)))


func away_left() -> float:
	if away_at <= 0.0 or str(game.get("status", "")) != "play":
		return INF
	return maxf(0.0, away_s() * 1000.0 - (now_ms() - away_at))


func idle_left() -> float:
	if str(game.get("status", "")) != "play" or not game.has("idle"):
		return INF
	return maxf(0.0, float(game["idle"]) - (now_ms() - float(game.get("at", now_ms()))))


func idle_warn() -> bool:
	var left: float = idle_left()
	return left < INF and float(game.get("limit", 0)) - left >= float(game.get("warn", 0))


func gone_left(side: String) -> float:
	var p: Dictionary = game.get("p", {}).get(side, {})
	if not p.has("gone") or str(game.get("status", "")) != "play":
		return INF
	return maxf(0.0, float(p["gone"]) - (now_ms() - float(game.get("at", now_ms()))))

func _tip(text: String) -> void :
	if opened:
		say(text)
	elif hub != null and hub.has_method("say"):
		hub.call("say", text)

func reset() -> void :
	in_lobby = false
	close()
	for ch: String in _reqs:
		(_reqs[ch] as HTTPRequest).cancel_request()
	_busy = {}
	_writes = []
	kd_visible = false
	token = ""
	ins = []
	out = {}
	friends = []
	queue_kind = ""
	active_id = ""
	_clear_game()
	_voice_sync()
	visible = false

func _clear_game() -> void :
	game = {}
	board = []
	moves_from = {}
	anim = []
	bursts = []
	pending = ""
	sel = -1
	promo = []
	confirm = ""
	seen_n = 0
	mute_opp = false
	away_at = 0.0
	idle_ok = ""
	if chat_edit != null:
		chat_edit.text = ""
	screen = "home"


func _sync_vis() -> void :
	if opened:
		visible = true
	else:
		visible = _popup_on() or _dock_on()

func _popup_on() -> bool:
	return kd_visible and not ins.is_empty() and str(game.get("status", "")) != "play"


func _dock_on() -> bool:
	return kd_visible and in_lobby and not opened and str(game.get("status", "")) == "play"





const DOCK_H: float = 30.0
const DOCK_W: float = 350.0
const DOCK_GAP: float = 8.0
const DOCK_VGAP: float = 4.0
const DOCK_TEXT: Array = ["Kỳ Đài: quay lại trong %s để không bị xử thua", "Kỳ Đài: chưa đi nước nào — còn %s trước khi bị xử thua"]
const DOCK_SHORT: Array = ["Kỳ Đài: quay lại trong %s", "Kỳ Đài: còn %s để đi nước"]
var _dock_r: Rect2 = Rect2()
var _dock_short: bool = false

func _dock_rect() -> Rect2:
	if not _dock_r.has_area():
		_dock_r = _dock_place()
	return _dock_r



func _dock_blocks() -> Array:
	var lob: Control = (hub.get("lobby") as Control) if hub != null else null
	if lob == null or not is_instance_valid(lob) or not lob.is_visible_in_tree():
		return []
	var to_me: Transform2D = get_global_transform().affine_inverse() * lob.get_global_transform()
	var scr: Rect2 = to_me * Rect2(Vector2.ZERO, lob.size)
	var out: Array = [["screen", scr]]
	var hits: Variant = lob.get("_hits")
	if hits is Array:
		for h: Variant in hits:
			if not (h is Array) or (h as Array).size() != 2 or not ((h as Array)[1] is Rect2):
				continue
			var r: Rect2 = to_me * ((h as Array)[1] as Rect2)
			if r.has_area() and r.size.x < scr.size.x * 0.5 and r.size.y < scr.size.y * 0.5:
				out.append([str((h as Array)[0]), r])
	var tags: Variant = lob.get("_isle_tags")
	if tags is Array and lob.has_method("_isle_rect"):
		for t: Variant in tags:
			if t is Rect2 and (t as Rect2).has_area():
				out.append(["tag", to_me * (lob.call("_isle_rect", (t as Rect2).position, (t as Rect2).size) as Rect2)])
	return out


func _dock_short_w() -> float:
	var font: Font = _face(BOLD)
	var widest: float = 0.0
	for s: String in DOCK_SHORT:
		widest = maxf(widest, font.get_string_size(s % "00:00", HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(12.0 * _f))).x / maxf(0.01, _f))
	return ceilf(34.0 + widest + 6.0 + 76.0)

func _dock_place() -> Rect2:
	_dock_short = false
	var old: Rect2 = Rect2(Vector2(282, 3) * _f, Vector2(DOCK_W, DOCK_H) * _f)
	var blocks: Array = _dock_blocks()
	if blocks.is_empty():
		return old
	var scr: Rect2 = blocks[0][1]
	var face: Rect2 = Rect2()
	for b: Array in blocks:
		if str(b[0]) == "avatar":
			face = b[1]
	if not face.has_area():
		return old
	var cx: float = scr.get_center().x
	var h: float = roundf(DOCK_H * _f)
	var m: float = DOCK_GAP * _f
	var v: float = DOCK_VGAP * _f
	var wides: Array = [roundf(DOCK_W * _f), roundf(_dock_short_w() * _f)]
	var y: float = roundf(face.get_center().y - h / 2.0)
	var last: Rect2 = Rect2(Vector2(roundf(cx - wides[1] / 2.0), y), Vector2(wides[1], h))
	for step: int in range(8):
		var lo: float = scr.position.x + m
		var hi: float = scr.end.x - m
		var below: float = y
		for i: int in range(1, blocks.size()):
			var r: Rect2 = blocks[i][1]
			if r.end.y <= y - v or r.position.y >= y + h + v:
				continue
			if r.get_center().x < cx:
				lo = maxf(lo, r.end.x + m)
			else:
				hi = minf(hi, r.position.x - m)
			if step > 0 or r.get_center().x < cx:
				below = maxf(below, r.end.y)
		for k: int in wides.size():
			var w: float = wides[k]
			if hi - lo >= w:
				_dock_short = k == 1
				return Rect2(Vector2(roundf((lo + hi - w) / 2.0), y), Vector2(w, h))
		last = Rect2(Vector2(roundf(cx - wides[1] / 2.0), y), Vector2(wides[1], h))
		y = roundf(maxf(below + v, y + h / 2.0))
		if y + h > scr.get_center().y:
			break
	_dock_short = true
	return last

func _has_point(point: Vector2) -> bool:
	if opened:
		return true
	if _dock_on() and _dock_rect().has_point(point):
		return true
	return _popup_on() and Rect2((_stage() + Vector2(290, 200)) * _f, Vector2(420, 190) * _f).has_point(point)



func _read_prefs() -> void :
	if _prefs_read:
		return
	_prefs_read = true
	maxed = _mobile
	if prefs_path.is_empty():
		return
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(prefs_path) != OK:
		return
	maxed = bool(cfg.get_value("kd", "max", maxed))
	var m: String = str(cfg.get_value("kd", "mic", "hold"))
	mic = m if MIC_TEXT.has(m) else "hold"
	speaker = bool(cfg.get_value("kd", "speaker", true))

func _save_prefs() -> void :
	if prefs_path.is_empty():
		return
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("kd", "max", maxed)

	cfg.set_value("kd", "chat_open", chat_open)
	cfg.set_value("kd", "mic", mic)
	cfg.set_value("kd", "speaker", speaker)
	cfg.save(prefs_path)



func _send(ch: String, url: String, what: String) -> void :
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
	var what: String = str(_what.get(ch, ""))
	if code == 200:
		_take(text, what)
	elif ch == "g":
		_g_retry = now_ms() + 2000.0
	elif ch == "w":
		say("Mất kết nối, thử lại sau.")
		if what == "move":
			pending = ""
			_g_retry = 0.0
	if ch == "w":
		_pump()
	_game_loop()
	_sync_vis()
	queue_redraw()

func _write(url: String, what: String) -> void :
	_writes.append([url, what])
	_pump()

func _pump() -> void :
	if _busy.get("w", false) or _writes.is_empty():
		return
	var job: Array = _writes.pop_front()
	_send("w", "%s&k=%s&t=%d" % [job[0], token.uri_encode(), now_ms()], str(job[1]))


func _game_loop() -> void :
	if game.is_empty() or str(game.get("status", "")) != "play" or _busy.get("g", false) or now_ms() < _g_retry:
		return
	_send("g", "/chess.xml?g=%s&v=%d&t=%d" % [str(game["id"]).uri_encode(), int(game.get("v", 0)), now_ms()], "game")


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

func _take(text: String, what: String) -> void :
	var root: Dictionary = tree_xml(text)
	if root.is_empty() or str(root["tag"]) != "chess":
		return
	var a: Dictionary = root["at"]
	if str(a.get("visible", "0")) != "1":
		kd_visible = false
		if opened:
			close("Kỳ Đài đang tạm đóng.")
		_clear_game()
		ins = []
		return
	kd_visible = true
	token = str(a.get("k", token))
	kinds = Array(str(a.get("games", "")).split(",", false))
	minutes = {"chess": int(a.get("min_chess", 10)), "xq": int(a.get("min_xq", 10))}
	wins = int(a.get("wins", 0))
	cap = int(a.get("cap", 0))
	reward = int(a.get("reward", 0))
	test_mode = str(a.get("test", "0")) == "1"
	ai_on = str(a.get("ai", "0")) == "1"
	ai_full = str(a.get("ai_full", "0")) == "1"
	ai_hint = float(a.get("ai_hint", 30))
	ai_reward = int(a.get("ai_reward", 0))
	queue_kind = str(a.get("queue", ""))
	queue_ms = float(a.get("qwait", 0))
	queue_at = now_ms()
	active_id = str(a.get("game", ""))
	var t: float = now_ms()
	ins = []
	out = {}
	var g_node: Dictionary = {}
	for kid: Dictionary in root["kids"]:
		var k: Dictionary = kid["at"]
		match str(kid["tag"]):
			"in":
				ins.append({"id": str(k.get("id", "")), "from": int(k.get("from", 0)), "name": str(k.get("name", "")), "level": str(k.get("level", "")), 
					"kind": str(k.get("kind", "chess")), "left": float(k.get("left", 0)), "at": t})
			"out":
				out = {"id": str(k.get("id", "")), "to": int(k.get("to", 0)), "name": str(k.get("name", "")), "kind": str(k.get("kind", "chess")), 
					"left": float(k.get("left", 0)), "at": t}
			"game":
				g_node = kid
			"friends":
				friends = []
				for f: Dictionary in kid["kids"]:
					var fa: Dictionary = f["at"]
					friends.append({"id": int(fa.get("id", 0)), "name": str(fa.get("name", "")), "level": str(fa.get("level", "")), "st": str(fa.get("st", "off"))})
				fr_off = clampi(fr_off, 0, maxi(0, friends.size() - _fr_rows))
	var failed: bool = str(a.get("ok", "")) == "0"
	if not g_node.is_empty():
		_take_game(g_node, what == "move" or failed)
	elif what == "game" and not game.is_empty() and str(game.get("status", "")) == "play":
		_clear_game()
		if opened:
			screen = "home"
	if what == "move":
		pending = ""
	var notice: String = str(a.get("notice", ""))
	if not notice.is_empty():
		if opened:
			say(notice)
		elif hub != null and hub.has_method("say"):
			hub.call("say", notice)
	_voice_sync()

func _take_game(node: Dictionary, force: bool) -> void :
	var a: Dictionary = node["at"]
	var g: Dictionary = {"id": str(a.get("id", "")), "kind": "xq" if str(a.get("kind", "")) == "xq" else "chess", "side": str(a.get("side", "")), 
		"v": int(a.get("v", 0)), "ply": int(a.get("ply", 0)), "fen": str(a.get("fen", "")), "turn": str(a.get("turn", "w")), 
		"chat": int(a.get("chat", 0)), "voice": int(a.get("voice", 0)), "last": str(a.get("last", "")), "check": int(a.get("check", 0)), 
		"draw": str(a.get("draw", "")), "canDraw": int(a.get("canDraw", 0)), "status": str(a.get("status", "play")), 
		"result": str(a.get("result", "")), "reason": str(a.get("reason", "")), "reward": int(a.get("reward", 0)), "why": str(a.get("why", "")), 
		"has_reward": a.has("reward"), "legal": Array(str(a.get("legal", "")).split(" ", false)), "rematch": int(a.get("rematch", 0)), 
		"grace": float(a.get("grace", 30)), "p": {}, "msgs": [], "at": now_ms(), "turn_at": str(a.get("turn_at", "")), 
		"limit": float(a.get("limit", 0)), "warn": float(a.get("warn", 0)), "away_s": int(a.get("away_s", 30)), 
		"ai": str(a.get("ai", ""))}
	if a.has("idle"):
		g["idle"] = float(a["idle"])
	for kid: Dictionary in node["kids"]:
		var k: Dictionary = kid["at"]
		if str(kid["tag"]) == "p":
			g["p"][str(k.get("side", "w"))] = {"id": int(k.get("id", 0)), "name": str(k.get("name", "")), "level": str(k.get("level", "")), 
				"online": int(k.get("online", 1)), "left": float(k.get("left", 0)), "away": float(k.get("away", 0)), "aw": int(k.get("aw", 0))}
			if k.has("gone"):
				g["p"][str(k.get("side", "w"))]["gone"] = float(k["gone"])
		elif str(kid["tag"]) == "c":
			g["msgs"].append({"n": int(k.get("n", 0)), "side": str(k.get("side", "")), "t": str(k.get("t", ""))})
	var same: bool = str(game.get("id", "")) == g["id"]
	if same and not force:
		if int(g["v"]) < int(game.get("v", 0)):
			return
		if not pending.is_empty() and int(g["ply"]) < int(game.get("ply", 0)):
			return
	var nb: Array = fen_board(str(g["fen"]), str(g["kind"]))
	var key: String = "%d:%s" % [int(g["ply"]), str(g["last"])]
	if same and int(g["ply"]) == int(game.get("ply", 0)) + 1 and not str(g["last"]).is_empty() and key != anim_key and board.size() == nb.size():
		_start_anim(board, str(g["last"]), str(g["kind"]), false)
	elif not same:
		anim = []
		bursts = []
		sel = -1
		promo = []
		confirm = ""
		seen_n = 0
		mute_opp = false
		pending = ""
		away_at = 0.0
		idle_ok = ""
		if chat_edit != null:
			chat_edit.text = ""
	anim_key = key
	var ended: bool = str(g["status"]) == "over" and ( not same or str(game.get("status", "")) != "over")
	game = g
	board = nb
	if int(g["ply"]) >= int(game.get("ply", 0)):
		pending = ""
	moves_from = {}
	for m: String in g["legal"]:
		var f: int = sq_of(m.substr(0, 2), str(g["kind"]))
		if not moves_from.has(f):
			moves_from[f] = []
		(moves_from[f] as Array).append(m)
	if sel >= 0 and not moves_from.has(sel):
		sel = -1
	clk = {"w": float(g["p"].get("w", {}).get("left", 0)), "b": float(g["p"].get("b", {}).get("left", 0))}
	clk_at = now_ms()
	clk_run = str(g["turn"]) if str(g["status"]) == "play" else ""
	var mine: Dictionary = g["p"].get(my_side(), {})
	if str(g["status"]) == "play" and not opened and int(mine.get("aw", 0)) == 1 and mine.has("gone"):
		away_at = now_ms() - maxf(0.0, away_s() * 1000.0 - float(mine["gone"]))
	elif str(g["status"]) == "play" and opened and int(mine.get("aw", 0)) == 1 and same:
		_come_back()
	if ended:
		sel = -1
		promo = []
		confirm = ""
		dragging = false
		_hold_end()
		away_at = 0.0
		_end_tip()
	if not same and str(g["status"]) == "play":
		screen = "game"
		if not opened and kd_visible:
			open()
	if opened and screen == "game" and chat_open:
		seen_n = _last_n()


func _end_tip() -> void :
	var result: String = str(game.get("result", ""))
	var reason: String = str(game.get("reason", ""))
	var lost: bool = result != "draw" and result != my_side()
	var text: String = ""
	if lost and reason == "away":
		text = "Kỳ Đài: bạn bị xử thua vì rời ván quá %d giây." % away_s()
	elif lost and reason == "idle":
		text = "Kỳ Đài: bạn bị xử thua vì không thao tác quá %s." % _span(float(game.get("limit", 120000)))
	elif not opened or not in_lobby:
		text = "Kỳ Đài: " + ("hoà" if result == "draw" else ("bạn thua" if lost else "bạn thắng"))
		var why: String = str(REASON.get(reason, ""))
		if not why.is_empty():
			text += " (%s)" % why.to_lower()
	if text.is_empty():
		return
	if in_lobby:
		_tip(text)
	else:
		tip_later = text

static func _span(ms: float) -> String:
	var s: int = roundi(ms / 1000.0)
	return ("%d phút" % (s / 60)) if s >= 60 and s % 60 == 0 else ("%d giây" % s)



static func sq_of(name: String, kind: String) -> int:
	if name.length() < 2:
		return -1
	var f: int = FILES.find(name[0])
	if kind == "xq":
		var r: int = name.substr(1, 1).to_int()
		return f + r * 9 if f >= 0 and f < 9 else -1
	var rank: int = name.substr(1, 1).to_int() - 1
	return f + rank * 8 if f >= 0 and f < 8 and rank >= 0 and rank < 8 else -1

static func fen_board(fen: String, kind: String) -> Array:
	var w: int = 9 if kind == "xq" else 8
	var h: int = 10 if kind == "xq" else 8
	var b: Array = []
	b.resize(w * h)
	b.fill("")
	var rows: PackedStringArray = fen.get_slice(" ", 0).split("/")
	for i in range(mini(rows.size(), h)):
		var rank: int = h - 1 - i
		var file: int = 0
		var row: String = rows[i]
		for j in range(row.length()):
			var c: String = row[j]
			if c >= "0" and c <= "9":
				file += c.to_int()
			elif file < w:
				b[rank * w + file] = c
				file += 1
	return b

static func apply_move(b: Array, m: String, kind: String) -> Array:
	var nb: Array = b.duplicate()
	var f: int = sq_of(m.substr(0, 2), kind)
	var t: int = sq_of(m.substr(2, 2), kind)
	if f < 0 or t < 0:
		return nb
	var p: String = str(nb[f])
	nb[f] = ""
	if kind == "chess":
		var white: bool = p == p.to_upper()
		if p.to_upper() == "P" and f % 8 != t % 8 and str(nb[t]).is_empty():
			nb[t - 8 if white else t + 8] = ""
		if p.to_upper() == "K" and absi(f % 8 - t % 8) == 2:
			var rf: int = f + 3 if t % 8 == 6 else f - 4
			var rt: int = f + 1 if t % 8 == 6 else f - 1
			nb[rt] = nb[rf]
			nb[rf] = ""
		if m.length() > 4:
			p = m[4].to_upper() if white else m[4].to_lower()
	nb[t] = p
	return nb


func _start_anim(before: Array, m: String, kind: String, dragged: bool) -> void :
	var f: int = sq_of(m.substr(0, 2), kind)
	var t: int = sq_of(m.substr(2, 2), kind)
	if f < 0 or t < 0 or f >= before.size() or t >= before.size():
		return
	var p: String = str(before[f])
	var now: float = now_ms()
	anim = []
	if not dragged:
		anim.append({"from": f, "to": t, "at": now})
	var victim: String = str(before[t])
	if kind == "chess" and p.to_upper() == "P" and f % 8 != t % 8 and victim.is_empty():
		victim = "p" if p == "P" else "P"
	if kind == "chess" and p.to_upper() == "K" and absi(f % 8 - t % 8) == 2:
		anim.append({"from": f + 3 if t % 8 == 6 else f - 4, "to": f + 1 if t % 8 == 6 else f - 1, "at": now})
	if not victim.is_empty():
		bursts.append({"sq": t, "at": now + (0.0 if dragged else SLIDE_MS * 0.7), "ch": victim})



func my_side() -> String:
	return str(game.get("side", ""))

func opp_side() -> String:
	return "b" if my_side() == "w" else "w"

func my_turn() -> bool:
	return str(game.get("status", "")) == "play" and pending.is_empty() and str(game.get("turn", "")) == my_side() and not my_side().is_empty()

func _activate(id: String) -> void :
	if id == "close":
		request_close()
	elif id == "leave:stay":
		confirm = ""
	elif id == "leave:go":
		confirm = ""
		close()
	elif id == "dock":
		open()
	elif id == "idle:ok":
		idle_ok = str(game.get("turn_at", ""))
	elif id == "max":
		maxed = not maxed
		_save_prefs()
	elif id.begins_with("tab:"):
		tab = id.substr(4)
	elif id == "quick":
		_write("/chess-queue.xml?kind=%s&on=1" % tab, "queue")
	elif id == "unq":
		_write("/chess-queue.xml?kind=%s&on=0" % (queue_kind if not queue_kind.is_empty() else tab), "queue")
	elif id.begins_with("invite:"):
		_write("/chess-invite.xml?to=%s&kind=%s" % [id.substr(7), tab], "invite")
	elif id == "uninvite":
		_write("/chess-invite.xml?to=0&kind=%s" % tab, "invite")
	elif id.begins_with("inv:ok:") or id.begins_with("inv:no:"):
		answer(id.substr(7), id.begins_with("inv:ok:"))
	elif id == "resume":
		screen = "game"
	elif id == "home":
		if str(game.get("status", "")) == "over":
			_clear_game()
		screen = "home"
		load_friends()
	elif id == "rematch":
		var opp: Dictionary = game.get("p", {}).get(opp_side(), {})
		var kind: String = str(game.get("kind", "chess"))
		_clear_game()
		tab = kind
		_write("/chess-invite.xml?to=%d&kind=%s" % [int(opp.get("id", 0)), kind], "invite")
		load_friends()
	elif id == "ai":
		ai_kind = queue_kind if not queue_kind.is_empty() else tab
		confirm = "ai"
	elif id.begins_with("ai:lv:"):
		if AI_LV.has(id.substr(6)):
			ai_level = id.substr(6)
	elif id == "ai:go":
		confirm = ""
		_write("/chess-ai.xml?kind=%s&lv=%s" % [ai_kind, ai_level], "ai")
	elif id == "ai:x":
		confirm = ""
	elif id == "aiagain":
		var ak: String = str(game.get("kind", "chess"))
		var al: String = str(game.get("ai", ""))
		if AI_LV.has(al):
			ai_level = al
		_clear_game()
		tab = ak
		ai_kind = ak
		_write("/chess-ai.xml?kind=%s&lv=%s" % [ak, ai_level], "ai")
	elif id == "resign":
		confirm = "resign"
	elif id == "resign:yes":
		confirm = ""
		_act("resign")
	elif id == "resign:no":
		confirm = ""
	elif id == "draw":
		_act("draw")
	elif id == "draw:yes":
		_act("accept")
	elif id == "draw:no":
		_act("decline")
	elif id == "promo:x":
		promo = []
	elif id.begins_with("promo:"):
		var m: String = id.substr(6)
		promo = []
		send_move(m, false)
	elif id == "chat:smile":
		quick_open = not quick_open
	elif id == "chat:send":
		send_chat(chat_edit.text)
	elif id.begins_with("chat:q:"):
		quick_open = false
		send_chat(str(QUICK[clampi(id.substr(7).to_int(), 0, QUICK.size() - 1)]))
	elif id == "chat:mute":
		mute_opp = not mute_opp
		say("Đã tắt chat của đối thủ" if mute_opp else "Đã bật lại chat của đối thủ")
	elif id == "v:spk":
		speaker = not speaker
		_save_prefs()
		if vc != null and str(vc.tea_scope) == "kd":
			vc.tea_set_deaf( not speaker)
		say("Loa: " + ("Bật" if speaker else "Tắt"))
	elif id == "v:mic":
		set_mic(str({"off": "hold", "hold": "open", "open": "off"}[mic]))
	elif id == "fr:up":
		fr_off = maxi(0, fr_off - 1)
	elif id == "fr:down":
		fr_off = mini(maxi(0, friends.size() - _fr_rows), fr_off + 1)

func answer(invite_id: String, yes: bool) -> void :
	for i in range(ins.size() - 1, -1, -1):
		if str(ins[i]["id"]) == invite_id:
			ins.remove_at(i)
	_write("/chess-answer.xml?id=%s&ok=%d" % [invite_id.uri_encode(), 1 if yes else 0], "answer")
	_sync_vis()

func _act(a: String) -> void :
	if game.is_empty():
		return
	_write("/chess-act.xml?g=%s&a=%s" % [str(game["id"]).uri_encode(), a], "act")

func send_move(m: String, dragged: bool) -> void :
	if not my_turn():
		return
	var kind: String = str(game["kind"])
	_start_anim(board, m, kind, dragged)
	board = apply_move(board, m, kind)
	var now: float = now_ms()
	var me: String = my_side()
	clk[me] = maxf(0.0, float(clk[me]) - (now - clk_at))
	clk_at = now
	clk_run = opp_side()
	game["ply"] = int(game["ply"]) + 1
	game["last"] = m
	game["turn"] = opp_side()
	game["legal"] = []
	game["check"] = 0
	if game.has("idle"):
		game["idle"] = float(game.get("limit", 0))
		game["at"] = now
		game["turn_at"] = "local:%d" % int(game["ply"])
	anim_key = "%d:%s" % [int(game["ply"]), m]
	moves_from = {}
	sel = -1
	pending = m
	Sound.click()
	_write("/chess-move.xml?g=%s&m=%s&v=%d" % [str(game["id"]).uri_encode(), m, int(game["v"])], "move")

func send_chat(text: String) -> void :
	text = text.strip_edges()
	if text.is_empty() or game.is_empty() or str(game.get("status", "")) != "play":
		return
	var now: float = now_ms()
	if now - chat_sent_at < CHAT_GAP_MS:
		say("Gửi chậm lại một chút nhé.")
		return
	chat_sent_at = now
	if text.length() > CHAT_MAX:
		text = text.left(CHAT_MAX)
	_write("/chess-chat.xml?g=%s&t=%s" % [str(game["id"]).uri_encode(), text.uri_encode()], "chat")
	if chat_edit != null:
		chat_edit.text = ""
		chat_edit.release_focus()

func set_mic(mode: String) -> void :
	mic = mode
	_save_prefs()
	var usable: bool = vc != null and str(vc.tea_scope) == "kd"
	if mode == "off":
		if usable and bool(vc.tea_mic):
			vc.tea_toggle_mic(true)
	elif mode == "hold":
		Settings.put("mic_mode", "ptt")
	else:
		Settings.put("mic_mode", "open")
		if usable and not bool(vc.tea_mic):
			vc.tea_toggle_mic(true)
	if vc == null and str(game.get("status", "")) == "play" and not VoiceClient.usable():
		say("Thiết bị này chưa dùng được voice.")
	else:
		say(str(MIC_TEXT[mode]) + (" (giữ phím V để nói)" if mode == "hold" and not _mobile else (" (giữ nút dưới bàn cờ)" if mode == "hold" else "")))

func _hold_start() -> void :
	if mic != "hold":
		return
	_holding = true
	_voice_hold_at = _time
	if vc == null or str(vc.tea_scope) != "kd":
		return
	if str(Settings.value("mic_mode")) != "ptt":
		Settings.put("mic_mode", "ptt")
	if not bool(vc.tea_mic):
		vc.tea_toggle_mic(true)
	vc.set_talk(true)

func _hold_end() -> void :
	if not _holding:
		return
	_holding = false
	_voice_hold_at = -1.0
	if vc != null:
		vc.set_talk(false)


func _voice_sync() -> void :
	var want: bool = in_lobby and str(game.get("status", "")) == "play" and int(game.get("voice", 0)) == 1 and not my_side().is_empty()
	if want and _voice_gid != str(game["id"]):
		_voice_gid = str(game["id"])
		if not VoiceClient.usable():
			return
		vc = VoiceClient.shared()
		if not (vc as Object).is_connected("tea_voice", _voice_text):
			(vc as Object).connect("tea_voice", _voice_text)
		vc.tea_join("kd")
		vc.tea_seated(true)
		vc.tea_set_deaf( not speaker)
	elif not want and not _voice_gid.is_empty():
		_voice_gid = ""
		_hold_end()
		if vc != null and str(vc.tea_scope) == "kd":
			vc.tea_leave("kd")

func _voice_text(text: String) -> void :
	if vc != null and str(vc.tea_scope) == "kd" and opened:
		say(text)


func _escape() -> void :
	if confirm == "leave" or confirm == "resign" or confirm == "ai":
		confirm = ""
	elif not promo.is_empty():
		promo = []
	elif chat_edit != null and chat_edit.has_focus():
		chat_edit.release_focus()
	else:
		request_close()
	queue_redraw()

func _input(event: InputEvent) -> void :
	if opened and event is InputEventKey and (event as InputEventKey).pressed and not (event as InputEventKey).echo\
	and ((event as InputEventKey).keycode == KEY_ESCAPE or (event as InputEventKey).physical_keycode == KEY_ESCAPE):
		get_viewport().set_input_as_handled()
		_escape()
		return
	if not opened or not event is InputEventKey or (event as InputEventKey).echo or mic != "hold" or vc == null or str(vc.tea_scope) != "kd":
		return
	var key: InputEventKey = event
	var code: int = key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
	if code != int(Settings.value("mic_ptt_key")) or not key.pressed or bool(vc.tea_mic):
		return
	var focus: Control = get_viewport().gui_get_focus_owner()
	if focus is LineEdit or focus is TextEdit or str(game.get("status", "")) != "play":
		return
	if str(Settings.value("mic_mode")) != "ptt":
		Settings.put("mic_mode", "ptt")
	vc.tea_toggle_mic(true)
	vc.set_talk(true)

func _top_hit(point: Vector2) -> String:
	for i in range(_hits.size() - 1, -1, -1):
		if (_hits[i][1] as Rect2).has_point(point):
			return str(_hits[i][0])
	return ""

func _gui_input(event: InputEvent) -> void :
	if opened and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var top: String = _top_hit(event.position)
		if event.pressed and top == "v:hold":
			_hold_start()
			accept_event()
			return
		if not event.pressed and _holding:
			_hold_end()
			accept_event()
			return
		if event.pressed and top == "board":
			if chat_edit != null:
				chat_edit.release_focus()
			board_press(event.position)
			accept_event()
			return
		if not event.pressed and dragging:
			board_release(event.position)
			accept_event()
			return
	elif opened and event is InputEventMouseMotion and dragging:
		drag_pos = event.position
		if (event.position as Vector2).distance_to(_held_at) > 8.0 * _u:
			drag_moved = true
		accept_event()
		return
	super (event)

func _wheel(step: int, _at: Vector2) -> void :
	if screen == "home":
		fr_off = clampi(fr_off + step, 0, maxi(0, friends.size() - _fr_rows))

func board_press(pos: Vector2) -> void :
	_held_at = pos
	var sq: int = square_at(pos)
	if sq < 0 or not my_turn():
		sel = -1
		return
	if sel >= 0 and _targets(sel).has(sq):
		try_move(sel, sq, false)
		return
	if moves_from.has(sq):
		sel = sq
		dragging = true
		drag_from = sq
		drag_pos = pos
		drag_moved = false
	else:
		sel = -1

func board_release(pos: Vector2) -> void :
	dragging = false
	if not drag_moved:
		return
	var sq: int = square_at(pos)
	if sq >= 0 and sq != drag_from and _targets(drag_from).has(sq):
		try_move(drag_from, sq, true)

func _targets(from: int) -> Array:
	var kind: String = str(game.get("kind", "chess"))
	var outv: Array = []
	for m: String in moves_from.get(from, []):
		outv.append(sq_of(m.substr(2, 2), kind))
	return outv

func try_move(from: int, to: int, dragged: bool) -> void :
	var kind: String = str(game.get("kind", "chess"))
	var cands: Array = []
	for m: String in moves_from.get(from, []):
		if sq_of(m.substr(2, 2), kind) == to:
			cands.append(m)
	if cands.is_empty():
		return
	if cands.size() > 1:
		promo = cands
		sel = from
		return
	send_move(str(cands[0]), dragged)





func _layout() -> void :
	var w: float = win_size.x
	var h: float = win_size.y
	L = {}
	if screen != "game" or game.is_empty():
		return
	var top: float = HEAD + PAD
	var avail: float = h - HEAD - PAD * 2.0
	var ptt: bool = _ptt_on()
	var room_h: float = avail - (PTT_H + 10.0 if ptt else 0.0)
	var aspect: float = 1.0 if str(game["kind"]) == "chess" else 0.9
	var side_min: float = clampf(w * 0.29, 270.0, maxf(270.0, w * 0.34))
	var side_max: float = maxf(side_min, w * 0.34)
	var room_w: float = w - side_min - PAD * 3.0
	var bh: float = floorf(minf(room_h - RAIL * 2.0, (room_w - RAIL * 2.0) / aspect))
	var bw: float = floorf(bh * aspect)
	var side_w: float = minf(side_max, side_min + maxf(0.0, room_w - bw - RAIL * 2.0))
	var left_w: float = w - side_w - PAD * 3.0
	var fx: float = floorf(PAD + (left_w - bw - RAIL * 2.0) / 2.0)
	var fy: float = floorf(top + (room_h - bh - RAIL * 2.0) / 2.0)
	L["frame"] = Rect2(fx, fy, bw + RAIL * 2.0, bh + RAIL * 2.0)
	L["board"] = Rect2(fx + RAIL, fy + RAIL, bw, bh)
	L["side"] = Rect2(w - side_w - PAD, top, side_w, avail)
	if ptt:
		var pw: float = minf(260.0, left_w - 20.0)
		L["ptt"] = Rect2(PAD + (left_w - pw) / 2.0, fy + bh + RAIL * 2.0 + 10.0, pw, PTT_H)

func _ptt_on() -> bool:
	return _mobile and mic == "hold" and str(game.get("status", "")) == "play" and (int(game.get("voice", 0)) == 1 or not _voice_gid.is_empty())


func sq_centre(i: int) -> Vector2:
	var b: Rect2 = L.get("board", Rect2())
	var me: String = my_side()
	if str(game.get("kind", "chess")) == "xq":
		var c: int = i % 9
		var r: int = i / 9
		var k: float = b.size.x / 720.0
		var x: float = 40.0 + 80.0 * (8 - c if me == "b" else c)
		var y: float = 40.0 + 80.0 * (r if me == "b" else 9 - r)
		return b.position + Vector2(x, y) * k
	var cell: float = b.size.x / 8.0
	var f: int = i % 8
	var rank: int = i / 8
	var col: int = 7 - f if me == "b" else f
	var row: int = rank if me == "b" else 7 - rank
	return b.position + Vector2(col + 0.5, row + 0.5) * cell

func cell_size() -> float:
	var b: Rect2 = L.get("board", Rect2())
	return b.size.x / 8.0 if str(game.get("kind", "chess")) == "chess" else b.size.x / 9.0


func square_at(pos: Vector2) -> int:
	if L.is_empty():
		return -1
	var local: Vector2 = pos / _f - frame_at()
	var n: int = 90 if str(game.get("kind", "chess")) == "xq" else 64
	var best: int = -1
	var best_d: float = cell_size() * 0.5
	for i in range(n):
		var d: float = sq_centre(i).distance_to(local)
		if d < best_d:
			best = i
			best_d = d
	return best



func _tick(delta: float) -> void :
	super (delta)
	var now: float = now_ms()
	var keep: Array = []
	for v: Dictionary in ins:
		if float(v["left"]) - (now - float(v["at"])) > 0.0:
			keep.append(v)
	if keep.size() != ins.size():
		ins = keep
		_sync_vis()
	if not out.is_empty() and float(out["left"]) - (now - float(out["at"])) <= 0.0:
		out = {}
	if queue_kind.is_empty():
		ai_hinted = false
	elif ai_on and not ai_full and not ai_hinted and ai_hint > 0.0 and queue_ms + now - queue_at >= ai_hint * 1000.0:
		ai_hinted = true
		_tip("Kỳ Đài: chưa có người ghép — thử Đánh với máy trong lúc chờ nhé.")

func _paint() -> void :
	if opened:
		_fit()
		_layout()
		_tips.clear()
		draw_rect(Rect2(Vector2.ZERO, size), DIM)
		_hit("shade", Rect2(Vector2.ZERO, size), false)
		var at: Vector2 = frame_at()
		_hit("panel", Rect2(at * _f, win_size * _f), false)
		_body(at)
		_draw_tips()
	else:
		_hide_edits()
	if _dock_on():
		_dock()
	if _popup_on():
		_popup()

func _R(x: float, y: float, w: float, h: float) -> Rect2:
	return Rect2((frame_at() + Vector2(x, y)) * _f, Vector2(w, h) * _f)

func _P(v: Vector2) -> Vector2:
	return (frame_at() + v) * _f


func _w(text: String, px: float, color: Color, align: String, x: float, cy: float, w: float, font: Font = SEMI) -> float:
	return _string(text, font, px * 2.0, color, align, _P(Vector2(x, cy)), w * _f) / _f



func _nine(name: String, r: Rect2, center: bool = true, tint: Color = Color.WHITE, k: float = 0.5) -> bool:
	var tex: Texture2D = _texture(KD_SOL)
	if tex == null or not SOL.has(name):
		return false
	var s: Array = SOL[name]
	var src: Rect2 = Rect2(float(s[0]), float(s[1]), float(s[2]), float(s[3]))
	if s.size() < 8:
		draw_texture_rect_region(tex, r, src, tint)
		return true
	var ml: float = float(s[4])
	var mt: float = float(s[5])
	var mr: float = float(s[6])
	var mb: float = float(s[7])
	var sc: float = k * _f
	var fx: float = minf(1.0, r.size.x / maxf(1.0, (ml + mr) * sc))
	var fy: float = minf(1.0, r.size.y / maxf(1.0, (mt + mb) * sc))
	var xs: Array = [r.position.x, r.position.x + ml * sc * fx, r.end.x - mr * sc * fx, r.end.x]
	var ys: Array = [r.position.y, r.position.y + mt * sc * fy, r.end.y - mb * sc * fy, r.end.y]
	var us: Array = [src.position.x, src.position.x + ml, src.end.x - mr, src.end.x]
	var vs: Array = [src.position.y, src.position.y + mt, src.end.y - mb, src.end.y]
	for j in range(3):
		for i in range(3):
			if i == 1 and j == 1 and not center:
				continue
			var x0: float = roundf(float(xs[i]))
			var x1: float = roundf(float(xs[i + 1]))
			var y0: float = roundf(float(ys[j]))
			var y1: float = roundf(float(ys[j + 1]))
			if x1 - x0 < 0.5 or y1 - y0 < 0.5:
				continue
			draw_texture_rect_region(tex, Rect2(x0, y0, x1 - x0, y1 - y0), 
				Rect2(float(us[i]), float(vs[j]), float(us[i + 1]) - float(us[i]), float(vs[j + 1]) - float(vs[j])), tint)
	return true


func _sol(name: String, r: Rect2, center: bool = true, tint: Color = Color.WHITE) -> void :
	var rect: Rect2 = _R(r.position.x, r.position.y, r.size.x, r.size.y)
	if not _nine(name, rect, center, tint):
		_plate(rect, Color("1d1514", 0.92) if center else Color(0, 0, 0, 0), Color(GOLD, 0.45) if name.begins_with("card_turn") else Color("8a5a2a", 0.7), 12.0, 2.0)


func _skin(id: String, skin: String, rect: Rect2, live: bool) -> void :
	var tint: Color = Color.WHITE
	if live and _press == id:
		tint = Color(0.8, 0.8, 0.8)
	elif live and _hover == id and _press.is_empty():
		tint = Color(1.18, 1.18, 1.18)
	if not _nine(skin, rect, true, tint):
		if skin == "btn_orange":
			_grad(rect, GOLD_TOP, GOLD_LOW, BTN_GOLD_EDGE, 16.0, 2.0)
		elif skin == "btn_blue":
			_grad(rect, BTN_TOP, BTN_LOW, Color(BTN_EDGE, 0.9), 16.0, 2.0)
		else:
			_plate(rect, Color("4a5468"), Color(CREAM, 0.25), 16.0, 2.0)
	if live:
		_hit(id, rect, false)

static func _skin_of(style: String, enabled: bool) -> String:
	return "btn_orange" if style == "orange" else ("btn_gray" if style == "gray" or not enabled else "btn_blue")



func _sbtn(id: String, text: String, rect: Rect2, enabled: bool = true, px: float = 15.0, style: String = "") -> void :
	var skin: String = _skin_of(style, enabled)
	_skin(id, skin, rect, enabled)
	var ink: Color = ON_GOLD if skin == "btn_orange" else (ON_BLUE if skin == "btn_blue" else Color(CREAM, 0.85 if enabled else 0.45))
	_string(text, BOLD, px * 2.0, ink, "c", rect.get_center(), rect.size.x - 8.0 * _f)

func _btn(id: String, text: String, r: Rect2, enabled: bool = true, px: float = 15.0, style: String = "") -> void :
	_sbtn(id, text, _R(r.position.x, r.position.y, r.size.x, r.size.y), enabled, px, style)

func _chip(id: String, text: String, r: Rect2, chosen: bool, px: float = 14.0, enabled: bool = true) -> void :
	_btn(id, text, r, enabled, px, "orange" if chosen and enabled else "")


func _icon_btn(id: String, r: Rect2, icon: String, tip: String, style: String = "", enabled: bool = true) -> void :
	var rect: Rect2 = _R(r.position.x, r.position.y, r.size.x, r.size.y)
	_skin(id, _skin_of(style, enabled), rect, enabled)
	if not enabled:
		_hit("tip:" + id, rect, false)
	var s: float = roundf(minf(rect.size.x, rect.size.y) * 0.62)
	var ir: Rect2 = Rect2((rect.get_center() - Vector2(s, s) / 2.0).round(), Vector2(s, s))
	if not _nine(icon, ir, true, Color(1, 1, 1, 1.0 if enabled or style == "orange" else 0.55)):
		_string(tip.substr(0, 1), BOLD, 26.0, ON_BLUE, "c", rect.get_center(), rect.size.x)
	if not tip.is_empty() and (_hover == id or _hover == "tip:" + id):
		_itip = [rect, tip]


func _draw_itip() -> void :
	if _itip.is_empty():
		return
	var a: Rect2 = _itip[0]
	var tip: String = str(_itip[1])
	var tw: float = _measure(tip, SEMI, 24.0) * _u + 20.0 * _f
	var th: float = 26.0 * _f
	var box: Rect2 = _R(0, 0, win_size.x, win_size.y)
	var x: float = clampf(a.get_center().x - tw / 2.0, box.position.x + 6.0 * _f, box.end.x - tw - 6.0 * _f)
	var y: float = a.position.y - th - 6.0 * _f
	if y < box.position.y + 4.0 * _f:
		y = a.end.y + 6.0 * _f
	var r: Rect2 = Rect2(x, y, tw, th)
	_plate(r, Color("120c0a", 0.95), Color(GOLD, 0.7), 8.0, 1.5)
	_string(tip, SEMI, 24.0, CREAM, "c", r.get_center(), tw)

func _body(_at: Vector2) -> void :
	var w: float = win_size.x
	var h: float = win_size.y
	_itip = []
	var frame: Rect2 = _R(0, 0, w, h)
	if not _nine("win_frame", frame):
		_grad(frame, Color("2a1d1a"), Color("161212"), Color(GOLD, 0.6), 22.0, 3.0)
	if not _nine("win_head", _R(0, 0, w, HEAD)):
		_grad(_R(3, 3, w - 6, HEAD - 4), Color("5a1414"), Color("2a0a0a"), Color(0, 0, 0, 0), 20.0, 0.0)
	var tw: float = _w("KỲ ĐÀI", 22, GOLD, "l", 22, HEAD / 2.0, 150, BOLD)
	_w("Bản thử nghiệm" if test_mode else "Đấu trí cùng bạn bè", 11, SOFT, "l", 22 + tw + 14, HEAD / 2.0 + 1, 130)
	_head_buttons()
	if screen == "game" and not game.is_empty():
		_game_screen()
	else:
		_hide_edits()
		_home()
	if confirm == "resign":
		_confirm_box()
	elif confirm == "leave":
		_leave_box()
	elif confirm == "ai":
		_ai_box()
	_draw_itip()

func _head_buttons() -> void :
	var w: float = win_size.x
	_icon_btn("close", Rect2(w - 48, 5, 34, 34), "icon_close", "Đóng")
	_icon_btn("max", Rect2(w - 88, 5, 34, 34), "icon_restore" if maxed else "icon_max", "Thu nhỏ" if maxed else "Phóng to")
	if screen == "home":
		var tx: float = 250.0
		for k: String in ["chess", "xq"]:
			_chip("tab:" + k, str(KIND_NAME[k]) + ("" if kinds.has(k) or kinds.is_empty() else " (đóng)"), Rect2(tx, 7, 130, 30), tab == k, 15.0)
			tx += 140.0
	elif not game.is_empty():
		_w(_game_title(), 15, CREAM, "l", 250, HEAD / 2.0, w - 250 - 100, BOLD)


func _game_title() -> String:
	var ply: int = int(game.get("ply", 0))
	var kind_name: String = str(KIND_NAME.get(str(game.get("kind", "chess")), "")).to_upper()
	if str(game.get("status", "")) == "over":
		return "%s · KẾT THÚC · NƯỚC %d" % [kind_name, maxi(1, ceili(ply / 2.0))]
	return "%s · NƯỚC %d" % [kind_name, ply / 2 + 1]







func _home_rects() -> Array:
	var w: float = win_size.x
	var h: float = win_size.y
	var avail: float = h - HEAD - 28.0
	if w < 1000.0:
		return [Rect2(16, HEAD + 12, 430, avail), Rect2(462, HEAD + 12, w - 478, avail), minf(avail - 170.0, 300.0)]
	var right_w: float = 420.0
	var room: float = minf(w - 32.0, 1160.0) - right_w - 16.0
	var bh: float = floorf(minf(minf(h * 0.52, avail - 150.0), room - 40.0))
	var left_w: float = clampf(bh + 110.0, 440.0, room)
	var cw: float = left_w + 16.0 + right_w
	var colh: float = minf(avail, bh + 160.0)
	var x0: float = floorf((w - cw) / 2.0)
	var y0: float = floorf(HEAD + 12.0 + (avail - colh) / 2.0)
	return [Rect2(x0, y0, left_w, colh), Rect2(x0 + left_w + 16.0, y0, right_w, colh), bh]

func _home() -> void :
	var rects: Array = _home_rects()
	var left: Rect2 = rects[0]
	_sol("panel", left)

	var kind: String = tab
	var tex: Texture2D = _texture(KD_CHESS if kind == "chess" else KD_XQ)
	var bh: float = float(rects[2])
	var bw: float = bh * (1.0 if kind == "chess" else 0.9)
	var br: Rect2 = Rect2(left.position.x + (left.size.x - bw) / 2.0, left.position.y + 26.0, bw, bh)
	L["home_left"] = left
	L["home_right"] = rects[1]
	L["home_board"] = br
	if tex != null:
		draw_texture_rect(tex, _R(br.position.x, br.position.y, br.size.x, br.size.y), false)
	_nine("board_frame", _R(br.position.x - RAIL, br.position.y - RAIL, br.size.x + RAIL * 2.0, br.size.y + RAIL * 2.0), false)
	var sb: Array = fen_board(str(START[kind]), kind)
	for i in range(sb.size()):
		if str(sb[i]).is_empty():
			continue
		var c: Vector2
		var d: float
		if kind == "xq":
			var k: float = bw / 720.0
			c = br.position + Vector2(40.0 + 80.0 * (i % 9), 40.0 + 80.0 * (9 - i / 9)) * k
			d = 76.0 * k
		else:
			var cell: float = bw / 8.0
			c = br.position + Vector2(i % 8 + 0.5, 7 - i / 8 + 0.5) * cell
			d = cell * 0.96
		_piece(str(sb[i]), kind, c, d)
	var cx: float = left.get_center().x
	var y: float = br.end.y + RAIL + 16.0
	var enabled: bool = kinds.has(kind) or kinds.is_empty()
	var mins: int = int(minutes.get(kind, 10))
	_w("%s · mỗi bên %d phút" % [KIND_NAME[kind], mins], 16, GOLD, "c", cx, y, left.size.x - 20, BOLD)
	y += 20.0
	var playing: bool = str(game.get("status", "")) == "play"
	if playing:
		_btn("resume", "Quay lại ván đang chơi", Rect2(cx - 140, y, 280, 46), true, 17.0)
	elif not queue_kind.is_empty():
		var waited: float = (queue_ms + now_ms() - queue_at) / 1000.0
		if ai_on and ai_hint > 0.0 and waited >= ai_hint:
			_btn("unq", "Đang tìm… %s · Huỷ" % _mmss(waited * 1000.0), Rect2(cx - 200, y, 244, 46), true, 15.0, "orange")
			_spinner(Vector2(cx - 180, y + 23), 8.0, ON_GOLD)
			_btn("ai", "Đánh với máy" if not ai_full else "Máy đang kín", Rect2(cx + 52, y, 148, 46), not ai_full, 15.0)
		else:
			_btn("unq", "Đang tìm %s… %s · Huỷ" % [KIND_NAME.get(queue_kind, ""), _mmss(waited * 1000.0)], Rect2(cx - 150, y, 300, 46), true, 15.0, "orange")
			_spinner(Vector2(cx - 128, y + 23), 8.0, ON_GOLD)
	elif ai_on:
		_btn("quick", "Ghép ngẫu nhiên", Rect2(cx - 196, y, 190, 46), enabled and out.is_empty(), 17.0)
		_btn("ai", "Đánh với máy" if not ai_full else "Máy đang kín", Rect2(cx + 6, y, 190, 46), enabled and out.is_empty() and not ai_full, 17.0)
	else:
		_btn("quick", "Ghép ngẫu nhiên", Rect2(cx - 130, y, 260, 46), enabled and out.is_empty(), 18.0)
	var info: String = "Thắng hôm nay: %d/%d · mỗi ván thắng +%d Xu Khóa" % [wins, cap, reward] if reward > 0 and cap > 0 else "Ván cờ giao hữu"
	_w(info, 12, SOFT, "c", cx, left.end.y - 17, left.size.x - 24)
	_friends_column(rects[1], playing, enabled)



func _friends_column(right: Rect2, playing: bool, enabled: bool) -> void :
	_sol("panel", right)
	_w("Mời bạn bè", 18, GOLD, "l", right.position.x + 20, right.position.y + 27, right.size.x - 160, BOLD)
	if not friends.is_empty():
		_w("%d trực tuyến" % friends.size(), 12, SOFT, "r", right.end.x - 20, right.position.y + 27, 130, BOLD)
	var ry: float = right.position.y + 52.0
	if not out.is_empty():
		var left_s: float = maxf(0.0, float(out["left"]) - (now_ms() - float(out["at"])))
		_sol("card_turn", Rect2(right.position.x + 12, ry, right.size.x - 24, 46))
		_w("Đang mời %s (%s)… %ds" % [out["name"], KIND_NAME.get(out["kind"], ""), ceili(left_s / 1000.0)], 14, GOLD, "l", right.position.x + 28, ry + 23, right.size.x - 140, BOLD)
		_btn("uninvite", "Huỷ", Rect2(right.end.x - 98, ry + 8, 74, 30), true, 14.0)
		ry += 54.0
	var list: Rect2 = Rect2(right.position.x + 12, ry, right.size.x - 24, right.end.y - ry - 12.0)
	if friends.is_empty():
		var cy: float = list.get_center().y - 10.0
		var c: Vector2 = Vector2(list.get_center().x, cy - 36.0)
		if not _nine("icon_people", _R(c.x - 30, c.y - 30, 60, 60)):
			draw_circle(_P(c), 26.0 * _f, Color(SOFT, 0.5))
		_w("Chưa có bạn bè nào đang online", 15, CREAM, "c", c.x, cy + 14.0, list.size.x - 20, BOLD)
		_w("Kết bạn ở mục Bạn Bè để mời chơi cùng", 12, SOFT, "c", c.x, cy + 38.0, list.size.x - 20)
		_fr_rows = 1
		fr_off = 0
		return
	var row_h: float = 56.0
	var rows: int = maxi(1, int(floorf((list.size.y + 6.0) / row_h)))
	_fr_rows = rows
	fr_off = clampi(fr_off, 0, maxi(0, friends.size() - rows))
	var scroll: bool = friends.size() > rows
	var row_w: float = list.size.x - (12.0 if scroll else 0.0)
	for i in range(fr_off, mini(friends.size(), fr_off + rows)):
		var f: Dictionary = friends[i]
		var rr: Rect2 = Rect2(list.position.x, ry, row_w, row_h - 6.0)
		_sol("row", rr)
		var st: String = str(f["st"])
		var ac: Vector2 = Vector2(rr.position.x + 30, rr.get_center().y)
		draw_circle(_P(ac), 16.0 * _f, Color("4a1010"))
		if not _nine("avatar_ring", _R(ac.x - 19, ac.y - 19, 38, 38)):
			draw_arc(_P(ac), 18.0 * _f, 0.0, TAU, 32, Color(GOLD, 0.8), maxf(1.0, 1.5 * _f), true)
		var fname: String = str(f["name"])
		_w(fname.substr(0, 1).to_upper(), 16, CREAM, "c", ac.x, ac.y, 34, BOLD)
		var dot: Vector2 = ac + Vector2(13, 13)
		draw_circle(_P(dot), 6.0 * _f, Color("1a0f0d"))
		draw_circle(_P(dot), 4.5 * _f, GREEN if st == "free" else (GOLD if st == "chess" else Color(SOFT, 0.7)))
		_w(fname, 15, CREAM, "l", rr.position.x + 58, rr.get_center().y - 9, rr.size.x - 160, BOLD)
		var lv: String = ("Cấp " + str(f["level"]) + " · ") if not str(f["level"]).is_empty() else ""
		_w(lv + str(FRIEND_ST.get(st, "")), 12, SOFT, "l", rr.position.x + 58, rr.get_center().y + 11, rr.size.x - 160)
		_btn("invite:%d" % int(f["id"]), "Mời", Rect2(rr.end.x - 92, rr.position.y + 9, 80, rr.size.y - 18), st == "free" and out.is_empty() and not playing and queue_kind.is_empty() and enabled, 14.0)
		ry += row_h
	if scroll:
		var track: Rect2 = Rect2(list.end.x - 6, list.position.y, 6, rows * row_h - 6.0)
		_plate(_R(track.position.x, track.position.y, track.size.x, track.size.y), Color(0, 0, 0, 0.4), Color(0, 0, 0, 0), 3.0, 0.0)
		var th: float = maxf(24.0, track.size.y * float(rows) / float(friends.size()))
		var ty: float = track.position.y + (track.size.y - th) * float(fr_off) / float(maxi(1, friends.size() - rows))
		_plate(_R(track.position.x, ty, track.size.x, th), Color(GOLD, 0.75), Color(0, 0, 0, 0), 3.0, 0.0)

func _spinner(c: Vector2, r: float, ink: Color = GOLD) -> void :
	var a: float = fmod(now_ms() / 1000.0 * 5.0, TAU)
	draw_arc(_P(c), r * _f, a, a + PI * 1.4, 16, ink, maxf(1.5, 5.0 * _u), true)

static func _mmss(ms: float) -> String:
	var s: int = maxi(0, ceili(ms / 1000.0))
	return "%d:%02d" % [s / 60, s % 60]



func _game_screen() -> void :
	var b: Rect2 = L["board"]
	var kind: String = str(game["kind"])
	var br: Rect2 = _R(b.position.x, b.position.y, b.size.x, b.size.y)
	var tex: Texture2D = _texture(KD_CHESS if kind == "chess" else KD_XQ)
	if tex != null:
		draw_texture_rect(tex, br, false)
	else:
		draw_rect(br, Color("c89a5a"))
	var fr: Rect2 = L.get("frame", b.grow(RAIL))
	if not _nine("board_frame", _R(fr.position.x, fr.position.y, fr.size.x, fr.size.y), false):
		_plate(_R(fr.position.x, fr.position.y, fr.size.x, fr.size.y), Color(0, 0, 0, 0), WOOD_HI, 8.0, 4.0)
	_hit("board", br, false)
	var cell: float = cell_size()
	var now: float = now_ms()

	var last: String = str(game.get("last", ""))
	if last.length() >= 4:
		for part: String in [last.substr(0, 2), last.substr(2, 2)]:
			var s: int = sq_of(part, kind)
			if s >= 0:
				if kind == "chess":
					var c: Vector2 = sq_centre(s)
					draw_rect(_R(c.x - cell / 2.0, c.y - cell / 2.0, cell, cell), LAST)
				else:
					_brackets(sq_centre(s), cell * 0.48, Color("ffd34a"))
	if kind == "chess":
		_coords(b, cell)

	if int(game.get("check", 0)) == 1 and str(game.get("status", "")) == "play":
		var king: String = "K" if str(game["turn"]) == "w" else "k"
		var ks: int = board.find(king)
		if ks >= 0:
			var kc: Vector2 = _P(sq_centre(ks))
			for i in range(6):
				draw_circle(kc, cell * _f * (0.62 - i * 0.07), Color(1, 0.1, 0.05, 0.1 + i * 0.05))

	if sel >= 0:
		var sc: Vector2 = _P(sq_centre(sel))
		var glow: float = 0.5 + 0.5 * sin(now / 180.0)
		for i in range(5):
			draw_circle(sc, cell * _f * (0.6 - i * 0.05), Color(1.0, 0.85, 0.3, 0.07 + 0.03 * glow))

	var moving: Dictionary = {}
	for a: Dictionary in anim:
		if now - float(a["at"]) < SLIDE_MS:
			moving[int(a["to"])] = a
	var drawn_late: Array = []
	for i in range(board.size()):
		var ch: String = str(board[i])
		if ch.is_empty():
			continue
		if moving.has(i) or (dragging and drag_moved and i == drag_from):
			drawn_late.append(i)
			continue
		_piece(ch, kind, sq_centre(i), _pd(kind, cell))

	if sel >= 0:
		for t: int in _targets(sel):
			var tc: Vector2 = _P(sq_centre(t))
			if str(board[t]).is_empty():
				draw_circle(tc, cell * _f * 0.14, HINT)
			else:
				draw_arc(tc, cell * _f * 0.47, 0, TAU, 32, Color(0.1, 0.45, 0.15, 0.75), maxf(2.0, cell * _f * 0.07), true)
	for i: int in drawn_late:
		var ch2: String = str(board[i])
		if moving.has(i):
			var a2: Dictionary = moving[i]
			var k: float = clampf((now - float(a2["at"])) / SLIDE_MS, 0.0, 1.0)
			k = 1.0 - pow(1.0 - k, 3.0)
			var pos: Vector2 = sq_centre(int(a2["from"])).lerp(sq_centre(int(a2["to"])), k)
			_piece(ch2, kind, pos, _pd(kind, cell) * (1.0 + 0.08 * sin(k * PI)))
		else:
			_piece(ch2, kind, drag_pos / _f - frame_at(), _pd(kind, cell) * 1.1)
	_bursts(cell)
	_side_column()
	if L.has("ptt"):
		_ptt_button(L["ptt"])
	if not promo.is_empty():
		_promo_box()
	if str(game.get("status", "")) == "over":
		_end_box()
	elif my_turn() and idle_warn() and idle_ok != str(game.get("turn_at", "")) and confirm.is_empty() and promo.is_empty():
		_idle_box()


func _ptt_button(r: Rect2) -> void :
	var rect: Rect2 = _R(r.position.x, r.position.y, r.size.x, r.size.y)
	var state: String = str(vc.tea_mic_state()) if vc != null and str(vc.tea_scope) == "kd" else "off"
	var on: bool = _holding or state == "talk"
	_skin("v:hold", "btn_orange" if on else "btn_blue", rect, true)
	var s: float = roundf(26.0 * _f)
	var label: String = "Đang nói…" if on else "Giữ để nói"
	var tw: float = _measure(label, BOLD, 32.0) * _u
	var x0: float = rect.get_center().x - (s + 8.0 * _f + tw) / 2.0
	_nine("icon_mic", Rect2(Vector2(x0, rect.get_center().y - s / 2.0).round(), Vector2(s, s)))
	_string(label, BOLD, 32.0, ON_GOLD if on else ON_BLUE, "l", Vector2(x0 + s + 8.0 * _f, rect.get_center().y), tw + 4.0)

func _pd(kind: String, cell: float) -> float:
	return cell * (0.95 if kind == "xq" else 0.96)

func _coords(b: Rect2, cell: float) -> void :
	var me: String = my_side()
	for i in range(8):
		var file: String = FILES[7 - i if me == "b" else i]
		var rank: String = str(i + 1 if me == "b" else 8 - i)
		var dark_f: bool = (i + 7) % 2 == 1
		var dark_r: bool = i % 2 == 1
		_w(file, 10, Color("f1dfbd") if dark_f else Color("6b4423"), "r", b.position.x + (i + 1) * cell - 3, b.end.y - 8, cell, BOLD)
		_w(rank, 10, Color("f1dfbd") if dark_r else Color("6b4423"), "l", b.position.x + 3, b.position.y + i * cell + 9, cell, BOLD)

func _brackets(c: Vector2, r: float, color: Color) -> void :
	var wd: float = maxf(1.5, 5.0 * _u)
	var l: float = r * 0.38
	for sx: float in [-1.0, 1.0]:
		for sy: float in [-1.0, 1.0]:
			var p: Vector2 = _P(c + Vector2(sx, sy) * r)
			draw_line(p, p + Vector2( - sx * l * _f, 0), color, wd, true)
			draw_line(p, p + Vector2(0, - sy * l * _f), color, wd, true)


func _piece(ch: String, kind: String, c: Vector2, d: float, alpha: float = 1.0) -> void :
	var tex: Texture2D = _texture(KD_PIECES)
	var white: bool = ch == ch.to_upper()
	var u: String = ch.to_upper()
	var col: int
	var row: int
	if kind == "xq":
		col = XQ_ORDER.find(u)
		row = 0 if white else 1
	else:
		col = CH_ORDER.find(u)
		row = 2 + (0 if white else 1)
	if col < 0:
		return
	var rect: Rect2 = Rect2(_P(c - Vector2(d, d) / 2.0), Vector2(d, d) * _f)
	if tex == null:
		draw_circle(rect.get_center(), rect.size.x * 0.45, Color("f3e6c8") if white else Color("2b2b2b"))
		_string(u, BOLD, d * 0.9, Color("b8141c") if white and kind == "xq" else (Color.BLACK if white else Color.WHITE), "c", rect.get_center(), rect.size.x)
		return
	draw_texture_rect_region(tex, rect, Rect2(col * 128, row * 128, 128, 128), Color(1, 1, 1, alpha))

func _bursts(cell: float) -> void :
	var now: float = now_ms()
	var keep: Array = []
	for bu: Dictionary in bursts:
		var age: float = now - float(bu["at"])
		if age > BURST_MS:
			continue
		keep.append(bu)
		if age < 0.0:
			continue
		var k: float = age / BURST_MS
		var c: Vector2 = _P(sq_centre(int(bu["sq"])))
		var r: float = cell * _f * (0.3 + 0.55 * k)
		draw_arc(c, r, 0, TAU, 36, Color(1.0, 0.82, 0.35, 0.9 * (1.0 - k)), maxf(1.5, cell * _f * 0.08 * (1.0 - k)), true)
		var dark: bool = str(bu["ch"]) != str(bu["ch"]).to_upper()
		for i in range(10):
			var ang: float = TAU * i / 10.0 + 0.3
			var p: Vector2 = c + Vector2(cos(ang), sin(ang)) * cell * _f * (0.2 + 0.6 * k)
			draw_circle(p, cell * _f * 0.05 * (1.0 - k), (Color("3a2a1a") if dark else Color("f6e3b8")).lerp(Color(1, 0.6, 0.2), 0.3))
	bursts = keep

func _clock_ms(side: String) -> float:
	var v: float = float(clk.get(side, 0.0))
	if clk_run == side:
		v -= now_ms() - clk_at
	return maxf(0.0, v)


func _side_column() -> void :
	var s: Rect2 = L["side"]
	var me: String = my_side()
	var opp: String = opp_side()
	var y: float = s.position.y
	_player_card(opp, Rect2(s.position.x, y, s.size.x, CARD_H))
	y += CARD_H + 8.0
	var bottom: float = s.end.y - CARD_H
	_player_card(me, Rect2(s.position.x, bottom, s.size.x, CARD_H))
	var playing: bool = str(game.get("status", "")) == "play"
	var draw_by: String = str(game.get("draw", ""))
	var warn: String = _opp_line(opp)
	if not warn.is_empty():
		var wr: Rect2 = Rect2(s.position.x, y, s.size.x, 30)
		var blink: float = 1.0 if fmod(now_ms(), 1000.0) < 650.0 else 0.6
		_plate(_R(wr.position.x, wr.position.y, wr.size.x, wr.size.y), Color("3a0b0b", 0.94), Color(RED, 0.75 * blink), 10.0, 1.5)
		_w(warn, 13, Color(1.0, 0.55, 0.5, blink), "c", wr.get_center().x, wr.get_center().y, wr.size.x - 16, BOLD)
		y += 38.0
	if playing and draw_by == opp:
		_sol("card_turn", Rect2(s.position.x, y, s.size.x, 44))
		_w("Đối thủ cầu hoà", 14, GOLD, "l", s.position.x + 14, y + 22, s.size.x - 190, BOLD)
		_btn("draw:yes", "Đồng ý", Rect2(s.end.x - 172, y + 7, 78, 30), true, 13.0)
		_btn("draw:no", "Từ chối", Rect2(s.end.x - 88, y + 7, 78, 30), true, 13.0, "gray")
		y += 52.0
	_action_icons(Rect2(s.position.x, y, s.size.x, 40))
	y += 48.0
	var chat_rect: Rect2 = Rect2(s.position.x, y, s.size.x, bottom - 8.0 - y)
	if int(game.get("chat", 0)) == 1:
		_chat(chat_rect)
	else:
		_hide_edits()
		if not str(game.get("ai", "")).is_empty() and chat_rect.size.y >= 60.0:
			_sol("panel", chat_rect)
			_w("Đánh với máy · Mức %s" % str(AI_LV_NAME.get(str(game.get("ai", "")), "")), 16, GOLD, "c", chat_rect.get_center().x, chat_rect.get_center().y - 12, chat_rect.size.x - 24, BOLD)
			_w("Ván luyện tập, không tính quà" if ai_reward <= 0 else "Thắng máy có quà tối đa 1 ván / ngày", 12, SOFT, "c", chat_rect.get_center().x, chat_rect.get_center().y + 14, chat_rect.size.x - 24)



func _action_icons(r: Rect2) -> void :
	var playing: bool = str(game.get("status", "")) == "play"
	var draw_by: String = str(game.get("draw", ""))
	var voice: bool = int(game.get("voice", 0)) == 1 or not _voice_gid.is_empty()
	var n: int = 4 if voice else 2
	var sz: float = 40.0
	var gap: float = 10.0
	var x: float = floorf(r.get_center().x - (n * sz + (n - 1) * gap) / 2.0)
	if playing and draw_by == my_side():
		_icon_btn("draw", Rect2(x, r.position.y, sz, sz), "icon_hand", "Đã cầu hoà — chờ đối thủ trả lời", "orange", false)
	else:
		var can: bool = playing and int(game.get("canDraw", 0)) == 1 and draw_by.is_empty()
		_icon_btn("draw", Rect2(x, r.position.y, sz, sz), "icon_hand", "Cầu hoà" if can or not playing else "Cầu hoà (chưa được lúc này)", "", can)
	x += sz + gap
	_icon_btn("resign", Rect2(x, r.position.y, sz, sz), "icon_flag", "Đầu hàng", "", playing)
	if not voice:
		return
	x += sz + gap
	_icon_btn("v:spk", Rect2(x, r.position.y, sz, sz), "icon_spk" if speaker else "icon_spk_off", "Loa: Bật — bấm để tắt" if speaker else "Loa: Tắt — bấm để bật")
	x += sz + gap
	var state: String = str(vc.tea_mic_state()) if vc != null and str(vc.tea_scope) == "kd" else "off"
	var tip: String = {"off": "Mic: Tắt — bấm để bật", "open": "Mic: Mở liên tục — bấm để tắt", 
		"hold": "Mic: Giữ để nói" + (" (giữ nút dưới bàn cờ)" if _mobile else " (giữ phím V)") + " — bấm để mở liên tục"}[mic]
	var mr: Rect2 = Rect2(x, r.position.y, sz, sz)
	_icon_btn("v:mic", mr, "icon_mic_off" if mic == "off" else "icon_mic", tip, "" if mic == "off" else "orange")
	if state == "talk":
		var pulse: float = 0.5 + 0.5 * sin(now_ms() / 120.0)
		_plate(_R(mr.position.x - 3, mr.position.y - 3, mr.size.x + 6, mr.size.y + 6), Color(0, 0, 0, 0), Color(TALK, 0.4 + 0.5 * pulse), 12.0, 2.5)



func _player_card(side: String, r: Rect2) -> void :
	var p: Dictionary = game.get("p", {}).get(side, {})
	var me: bool = side == my_side()
	var talking: bool = false
	if vc != null and str(vc.tea_scope) == "kd" and not _voice_gid.is_empty():
		var my_id: int = int(game.get("p", {}).get(my_side(), {}).get("id", 0))
		talking = bool(vc.tea_talking(int(p.get("id", 0)), my_id))
	var playing: bool = str(game.get("status", "")) == "play"
	var turn: bool = playing and str(game.get("turn", "")) == side
	_sol("card_turn" if turn else "card", r)
	if talking:
		var pulse: float = 0.5 + 0.5 * sin(now_ms() / 120.0)
		_plate(_R(r.position.x - 3, r.position.y - 3, r.size.x + 6, r.size.y + 6), Color(0, 0, 0, 0), Color(TALK, 0.35 + 0.45 * pulse), 14.0, 3.0)
	var kind: String = str(game.get("kind", "chess"))
	var cy: float = r.get_center().y
	_piece("K" if side == "w" else "k", kind, Vector2(r.position.x + 25, cy), 32.0)
	var x: float = r.position.x + 48.0
	var room: float = r.size.x - 48.0 - 104.0
	var sub: String = ("Cấp %s" % str(p.get("level", ""))) if not str(p.get("level", "")).is_empty() else ""
	var alarm: bool = me and playing and my_turn() and int(game.get("check", 0)) == 1
	if alarm:
		sub = "Đang bị chiếu!"
	var sub_w: float = _measure(sub, BOLD, 24.0) * _u / _f if not sub.is_empty() else 0.0
	var name: String = str(p.get("name", "?")) + (" (bạn)" if me else "")
	var nw: float = _w(name, 15, CREAM, "l", x, cy, maxf(60.0, room - (sub_w + 8.0 if alarm else 0.0)), BOLD)
	if not sub.is_empty() and nw + 8.0 + sub_w <= room + 2.0:
		_w(sub, 12, RED if alarm else SOFT, "l", x + nw + 8.0, cy + 1.0, sub_w + 4.0, BOLD)
	var ms: float = _clock_ms(side)
	var low: bool = turn and ms < 30000.0
	var cr: Rect2 = Rect2(r.end.x - 98, r.position.y + 7, 88, 34)
	_sol("clock_low" if low else "clock", cr)
	_w(_mmss(ms), 20, RED if low else (GOLD if turn else CREAM), "c", cr.get_center().x, cr.get_center().y, cr.size.x, BOLD)


func _opp_line(side: String) -> String:
	if str(game.get("status", "")) != "play":
		return ""
	var p: Dictionary = game.get("p", {}).get(side, {})
	var gone: float = gone_left(side)
	if gone < INF:
		return ("Đối thủ đã rời ván — còn %ds" if int(p.get("aw", 0)) == 1 else "Đối thủ mất kết nối — còn %ds") % ceili(gone / 1000.0)
	if str(game.get("turn", "")) == side and idle_warn():
		return "Đối thủ chưa đi — còn %ds" % ceili(idle_left() / 1000.0)
	return ""



func _last_n() -> int:
	var n: int = 0
	for m: Dictionary in game.get("msgs", []):
		n = maxi(n, int(m["n"]))
	return n

func _unread() -> int:
	var c: int = 0
	for m: Dictionary in game.get("msgs", []):
		if int(m["n"]) > seen_n and str(m["side"]) != my_side() and not mute_opp:
			c += 1
	return c



func _chat(r: Rect2) -> void :
	if r.size.y < 70.0:
		_hide_edits()
		return
	seen_n = _last_n()
	var playing: bool = str(game.get("status", "")) == "play"
	_sol("panel", r)
	_w("Trò chuyện", 15, GOLD, "l", r.position.x + 14, r.position.y + 21, 160, BOLD)
	_icon_btn("chat:mute", Rect2(r.end.x - 40, r.position.y + 6, 30, 30), "icon_chat_off", 
		"Bật lại chat của đối thủ" if mute_opp else "Tắt chat của đối thủ", "orange" if mute_opp else "")
	var input_h: float = 32.0
	var iy: float = r.end.y - input_h - 9.0
	var msg_end: float = r.end.y - 10.0
	if playing:
		msg_end = iy - 6.0
		if quick_open:
			var lines: Array = []
			var row: Array = []
			var row_w: float = 0.0
			for i in range(QUICK.size()):
				var tw: float = _measure(str(QUICK[i]), BOLD, 24.0) * _u / _f + 24.0
				if row_w + tw > r.size.x - 20.0 and not row.is_empty():
					lines.append(row)
					row = []
					row_w = 0.0
				row.append([i, tw])
				row_w += tw + 6.0
			if not row.is_empty():
				lines.append(row)
			var cy: float = iy - 6.0 - lines.size() * 34.0
			msg_end = cy - 4.0
			for ln: Array in lines:
				var cx: float = r.position.x + 10.0
				for it: Array in ln:
					_btn("chat:q:%d" % int(it[0]), str(QUICK[int(it[0])]), Rect2(cx, cy, float(it[1]), 28), true, 12.0)
					cx += float(it[1]) + 6.0
				cy += 34.0
		_icon_btn("chat:smile", Rect2(r.position.x + 9, iy, 32, input_h), "icon_smile", "Câu nói nhanh", "orange" if quick_open else "")
		var er: Rect2 = Rect2(r.position.x + 47, iy, r.size.x - 47 - 80, input_h)
		_place(chat_edit, _R(er.position.x, er.position.y, er.size.x, er.size.y))
		chat_edit.add_theme_font_size_override("font_size", maxi(8, roundi(26 * _u)))
		_btn("chat:send", "Gửi", Rect2(r.end.x - 74, iy, 64, input_h), true, 14.0)
	else:
		_hide_edits()

	var top: float = r.position.y + 40.0
	var y: float = msg_end
	var msgs: Array = game.get("msgs", [])
	var me: String = my_side()
	var px: float = 13.0
	var font_size: int = maxi(6, roundi(px * 2.0 * _u))
	for i in range(msgs.size() - 1, -1, -1):
		var m: Dictionary = msgs[i]
		var mine: bool = str(m["side"]) == me
		if not mine and mute_opp:
			continue
		var who: String = "Bạn" if mine else str(game.get("p", {}).get(str(m["side"]), {}).get("name", "Đối thủ"))
		var wrapped: Array = _wrap(who + ": " + str(m["t"]), font_size, (r.size.x - 28.0) * _f)
		var need: float = wrapped.size() * 18.0
		if y - need < top:
			break
		y -= need
		var ly: float = y
		for ln: String in wrapped:
			_w(ln, px, GOLD if mine else CREAM, "r" if mine else "l", r.end.x - 14 if mine else r.position.x + 14, ly + 9.0, r.size.x - 28, BOLD)
			ly += 18.0
		y -= 6.0
	if msgs.is_empty():
		_w("Gửi lời chào tới đối thủ nhé!", 12, Color(SOFT, 0.75), "c", r.get_center().x, (top + msg_end) / 2.0, r.size.x - 20)

func _wrap(text: String, font_size: int, width: float) -> Array:
	var outv: Array = []
	var line: String = ""
	for word: String in text.split(" "):
		var trial: String = word if line.is_empty() else line + " " + word
		if SEMI.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= width or line.is_empty():
			line = trial
		else:
			outv.append(line)
			line = word
	if not line.is_empty():
		outv.append(line)
	return outv

func _promo_box() -> void :
	var b: Rect2 = L["board"]
	var w: float = 4 * 76.0 + 36.0
	var r: Rect2 = Rect2(b.get_center().x - w / 2.0, b.get_center().y - 74, w, 148)
	_sol("end_box", r)
	_w("Phong cấp thành", 15, GOLD, "c", r.get_center().x, r.position.y + 26, w, BOLD)
	var x: float = r.position.x + 18.0
	var white: bool = my_side() == "w"
	for m: String in promo:
		var p: String = m.substr(4, 1)
		var rr: Rect2 = Rect2(x, r.position.y + 46, 72, 84)
		var rect: Rect2 = _R(rr.position.x, rr.position.y, rr.size.x, rr.size.y)
		var lit: bool = _hover == "promo:" + m
		if not _nine("card_turn" if lit else "card", rect):
			_plate(rect, Color(1, 1, 1, 0.08 if not lit else 0.2), Color(GOLD, 0.5), 12.0, 1.0)
		_piece(p.to_upper() if white else p, "chess", rr.get_center() - Vector2(0, 8), 54.0)
		_w(str(PIECE_VI.get(p, p)), 11, CREAM, "c", rr.get_center().x, rr.end.y - 12, 70, BOLD)
		_hit("promo:" + m, rect, false)
		x += 76.0


func _end_box() -> void :
	var b: Rect2 = L["board"]
	var w: float = minf(b.size.x - 30.0, 380.0)
	var r: Rect2 = Rect2(b.get_center().x - w / 2.0, b.get_center().y - 108, w, 216)
	_hit("endshade", _R(b.position.x, b.position.y, b.size.x, b.size.y), false)
	draw_rect(_R(b.position.x, b.position.y, b.size.x, b.size.y), Color(0, 0, 0, 0.35))
	_sol("end_box", r)
	var result: String = str(game.get("result", ""))
	var won: bool = result == my_side()
	var title: String = "HÒA" if result == "draw" else ("CHIẾN THẮNG" if won else "THẤT BẠI")
	var rib: Rect2 = Rect2(r.position.x - 12, r.position.y + 10, w + 24, 48)
	if not _nine("ribbon_draw" if result == "draw" else ("ribbon_win" if won else "ribbon_lose"), _R(rib.position.x, rib.position.y, rib.size.x, rib.size.y)):
		_grad(_R(rib.position.x, rib.position.y, rib.size.x, rib.size.y), GOLD_TOP, GOLD_LOW, BTN_GOLD_EDGE, 10.0, 2.0)
	_w(title, 22, ON_GOLD if won else ON_BLUE, "c", rib.get_center().x, rib.get_center().y - 1, rib.size.x - 100, BOLD)
	var reason: String = str(game.get("reason", ""))
	var why: String = str(REASON.get(reason, ""))
	if reason == "stalemate":
		why = "Hết nước đi — hoà" if str(game.get("kind", "")) == "chess" else "Hết nước đi"
	_w(why, 16, GOLD if won else CREAM, "c", r.get_center().x, r.position.y + 84, w - 24, BOLD)
	var gift: String = ""
	if bool(game.get("has_reward", false)) and won:
		gift = ("+%d Xu Khóa" % int(game.get("reward", 0))) if int(game.get("reward", 0)) > 0 else str(WHY.get(str(game.get("why", "")), ""))
	if not gift.is_empty():
		_w(gift, 14, GREEN if int(game.get("reward", 0)) > 0 else SOFT, "c", r.get_center().x, r.position.y + 112, w - 24, BOLD)
	var bw2: float = (w - 44.0) / 2.0
	if not str(game.get("ai", "")).is_empty():
		_btn("aiagain", "Ván mới với máy", Rect2(r.position.x + 16, r.end.y - 58, bw2, 40), ai_on and not ai_full, 15.0)
	else:
		_btn("rematch", "Thêm ván nữa", Rect2(r.position.x + 16, r.end.y - 58, bw2, 40), int(game.get("rematch", 0)) == 1, 15.0)
	_btn("home", "Về sảnh cờ", Rect2(r.position.x + 28 + bw2, r.end.y - 58, bw2, 40), true, 15.0)


func _ai_box() -> void :
	var w: float = 440.0
	var h: float = 236.0
	var r: Rect2 = Rect2((win_size.x - w) / 2.0, (win_size.y - h) / 2.0, w, h)
	_hit("cshade", _R(0, 0, win_size.x, win_size.y), false)
	draw_rect(_R(0, 0, win_size.x, win_size.y), Color(0, 0, 0, 0.4))
	_sol("end_box", r)
	var cx: float = r.get_center().x
	_w("Đánh với máy · %s" % str(KIND_NAME.get(ai_kind, "")), 19, CREAM, "c", cx, r.position.y + 34, w - 24, BOLD)
	_w("Ván luyện tập — không tính quà Xu Khóa." if ai_reward <= 0 else "Thắng máy được +%d Xu Khóa (tối đa 1 ván / ngày)." % ai_reward, 12, SOFT, "c", cx, r.position.y + 60, w - 24)
	var cw: float = 120.0
	var x: float = cx - (cw * 3.0 + 20.0) / 2.0
	for i in range(AI_LV.size()):
		var lv: String = str(AI_LV[i])
		_chip("ai:lv:" + lv, str(AI_LV_NAME[lv]), Rect2(x + i * (cw + 10.0), r.position.y + 82, cw, 40), ai_level == lv, 16.0)
	_w(str(AI_LV_DESC.get(ai_level, "")), 13, GOLD, "c", cx, r.position.y + 142, w - 24)
	_btn("ai:x", "Huỷ", Rect2(r.position.x + 22, r.end.y - 60, 180, 40), true, 15.0, "gray")
	_btn("ai:go", "Bắt đầu", Rect2(r.end.x - 202, r.end.y - 60, 180, 40), true, 15.0)


func _confirm_box() -> void :
	var w: float = 360.0
	var r: Rect2 = Rect2((win_size.x - w) / 2.0, (win_size.y - 160.0) / 2.0, w, 160)
	_hit("cshade", _R(0, 0, win_size.x, win_size.y), false)
	draw_rect(_R(0, 0, win_size.x, win_size.y), Color(0, 0, 0, 0.4))
	_sol("end_box", r)
	_w("Đầu hàng ván này?", 19, CREAM, "c", r.get_center().x, r.position.y + 40, w - 24, BOLD)
	_w("Đầu hàng là thua ngay ván đang chơi.", 12, SOFT, "c", r.get_center().x, r.position.y + 68, w - 24)
	_btn("resign:yes", "Đầu hàng", Rect2(r.position.x + 22, r.end.y - 60, 146, 40), true, 15.0, "gray")
	_btn("resign:no", "Chơi tiếp", Rect2(r.end.x - 168, r.end.y - 60, 146, 40), true, 15.0)


func _leave_box() -> void :
	var w: float = 460.0
	var r: Rect2 = Rect2((win_size.x - w) / 2.0, (win_size.y - 184.0) / 2.0, w, 184)
	_hit("cshade", _R(0, 0, win_size.x, win_size.y), false)
	draw_rect(_R(0, 0, win_size.x, win_size.y), Color(0, 0, 0, 0.4))
	_sol("end_box", r)
	_w("Ván cờ đang diễn ra.", 19, CREAM, "c", r.get_center().x, r.position.y + 36, w - 28, BOLD)
	_w("Rời cửa sổ quá %d giây sẽ bị xử thua." % away_s(), 16, Color("ff9b8a"), "c", r.get_center().x, r.position.y + 64, w - 28, BOLD)
	_w("Vào trận PvP / phụ bản cũng tính là rời cửa sổ.", 12, SOFT, "c", r.get_center().x, r.position.y + 88, w - 28)
	_btn("leave:go", "Vẫn đóng", Rect2(r.position.x + 26, r.end.y - 62, 180, 42), true, 16.0, "gray")
	_btn("leave:stay", "Ở lại", Rect2(r.end.x - 206, r.end.y - 62, 180, 42), true, 16.0)


func _idle_box() -> void :
	var b: Rect2 = L["board"]
	var w: float = minf(b.size.x - 24.0, 420.0)
	var r: Rect2 = Rect2(b.get_center().x - w / 2.0, b.get_center().y - 84, w, 168)
	_hit("idlebox", _R(r.position.x, r.position.y, r.size.x, r.size.y), false)
	_sol("end_box", r)
	var left: int = ceili(idle_left() / 1000.0)
	_w("Bạn chưa đi nước nào", 18, CREAM, "c", r.get_center().x, r.position.y + 32, w - 28, BOLD)
	var blink: float = 1.0 if left > 10 or fmod(now_ms(), 1000.0) < 600.0 else 0.35
	_w("còn %d giây" % left, 26, Color(RED, blink), "c", r.get_center().x, r.position.y + 66, w - 28, BOLD)
	_w("trước khi bị xử thua.", 13, SOFT, "c", r.get_center().x, r.position.y + 94, w - 28)
	_btn("idle:ok", "Tiếp tục", Rect2(r.get_center().x - 80, r.end.y - 54, 160, 38), true, 15.0)




func _dock() -> void :
	_dock_r = _dock_place()
	var r: Rect2 = _dock_r
	var at: Vector2 = r.position / _f
	var wide: float = r.size.x / _f
	var left: float = away_left()
	var idle: int = 0
	if my_turn() and idle_warn() and idle_left() < left:
		left = idle_left()
		idle = 1
	elif left == INF:
		left = gone_left(my_side())
	var on: bool = left == INF or left > 10000.0 or fmod(now_ms(), 1000.0) < 600.0
	_grad(r, Color("5a0f12", 0.96), Color("2a0608", 0.96), Color(RED, 0.95 if on else 0.4), 14.0, 2.0)
	_hit("dock", r)
	var word: Texture2D = art("btn")
	if word != null:
		draw_texture_rect(word, Rect2((at + Vector2(4, 2)) * _f, Vector2(26, 26) * _f), false)
	var shown: String = str((DOCK_SHORT if _dock_short else DOCK_TEXT)[idle]) % (_mmss(left) if left < INF else "—")
	_fwords(shown, BOLD, 12, Color(1.0, 0.86, 0.82) if on else Color(1.0, 0.86, 0.82, 0.55), "l", at + Vector2(34, 7), wide - 114.0)
	var go: Rect2 = Rect2((at + Vector2(wide - 74.0, 3)) * _f, Vector2(70, 24) * _f)
	_button("dock", "Vào lại", go, false, true, 22.0)



func _popup() -> void :
	var v: Dictionary = ins[0]
	var at: Vector2 = _stage() + Vector2(290, 200)
	var r: Rect2 = Rect2(at * _f, Vector2(420, 196) * _f)
	_hit("pop", r, false)
	if not _nine("end_box", r):
		_grad(r, Color("2a1d1a"), Color("161212"), Color(GOLD, 0.95), 22.0, 3.0)
	var word: Texture2D = art("btn")
	if word != null:
		draw_texture_rect(word, Rect2((at + Vector2(20, 20)) * _f, Vector2(50, 50) * _f), false)
	_fwords("Lời mời chơi cờ", BOLD, 18, GOLD, "l", at + Vector2(82, 22), 316)
	var lv: String = (" (Cấp %s)" % str(v["level"])) if not str(v["level"]).is_empty() else ""
	_fwords("%s%s mời bạn chơi %s" % [v["name"], lv, KIND_NAME.get(v["kind"], "")], SEMI, 14, CREAM, "l", at + Vector2(82, 54), 320)
	var left: float = maxf(0.0, float(v["left"]) - (now_ms() - float(v["at"])))
	var k: float = clampf(left / 30000.0, 0.0, 1.0)
	draw_rect(Rect2((at + Vector2(24, 96)) * _f, Vector2(372, 6) * _f), Color(1, 1, 1, 0.12))
	draw_rect(Rect2((at + Vector2(24, 96)) * _f, Vector2(372 * k, 6) * _f), GOLD)
	_fwords("Tự huỷ sau %ds" % ceili(left / 1000.0), SEMI, 11, SOFT, "r", at + Vector2(196, 104), 200)
	_sbtn("inv:ok:" + str(v["id"]), "Đồng ý", Rect2((at + Vector2(30, 134)) * _f, Vector2(170, 42) * _f), true, 16.0)
	_sbtn("inv:no:" + str(v["id"]), "Từ chối", Rect2((at + Vector2(220, 134)) * _f, Vector2(170, 42) * _f), true, 16.0, "gray")
