extends Control
const AppSession = preload("res://net/app_session.gd")









const Client = preload("../game_client.gd")
const AssetPack = preload("../battle/asset_pack.gd")
const SafeArea = preload("safe_area.gd")
const TankPreview = preload("tank_preview.gd")
const TankPortrait = preload("tank_portrait.gd")
const GarageModel = preload("garage_model.gd")
const BrowserZoom = preload("browser_zoom.gd")
const Love = preload("love.gd")
const Atlas = preload("hall_atlas.gd")

const NAPTIEN1_HIDE: bool = true
const Sound = preload("res://audio.gd")
const KitScreen = preload("kit_screen.gd")
const NewbieLogin = preload("newbie_login.gd")
const NewbieAtlas = preload("newbie_atlas.gd")
const ReturnGift = preload("return_gift.gd")
const ReturnAtlas = preload("return_atlas.gd")
const LuckAtlas = preload("vnluck_atlas.gd")
const BagModel = preload("bag_model.gd")
const ExpAtlas = preload("expedition_atlas.gd")
const AccCards = preload("acc_cards.gd")
const AccAtlas = preload("acc_atlas.gd")
const LeftGlow = preload("left_glow.gd")
const LeftGlowAtlas = preload("left_glow_atlas.gd")
const ActPrize = preload("act_prize.gd")
const CharTips = preload("char_tips.gd")
const MenuTips = preload("menu_tips.gd")
const MenuTipsAtlas = preload("menu_tips_atlas.gd")
const ChallengeAtlas = preload("challenge_atlas.gd")
const MysticalShop = preload("mystical_shop.gd")
const MysteriousStore = preload("mysterious_store.gd")
const MysteriousAtlas = preload("mysterious_store_atlas.gd")
const PresentTank = preload("present_tank.gd")
const NameStyles = preload("name_styles.gd")
const RandAtlas = preload("rand_quest_atlas.gd")
const RandRules = preload("rand_quest_rules.gd")
const SocialMenu = preload("social_menu.gd")
const CTip = preload("ctool_tip.gd")
const LobbyBar = preload("lobby_bar.gd")
const LobbyThemes = preload("lobby_themes.gd")


const FLEX_TIPS: Dictionary = {"social": "Cộng đồng", "col:quest": "Nhiệm vụ", "settings": "Cài đặt", 
	"money:cash": "Nạp tiền", "money:gift": "Nhận Xu Khóa", "money:gold": "Nhận Bạc", "nav:talent": "Kỹ Thuật"}

signal play
signal find_room
signal create_room
signal chat_asked
signal bonfire_asked
signal page_asked(id: String)
signal stamina_asked
signal quick_buy_asked(tid: int)
signal player_info_asked(uuid: String)
signal training_asked
signal newbie_asked
signal challenge_asked
signal mystical_asked
signal mysterious_asked
signal master_asked
signal reputation_asked
signal history_asked
signal rand_quest_asked
signal talent_asked(tank_uuid: String)
signal luck_asked
signal expedition_asked

const RW: float = 2772.0
const RH: float = 1280.0
const NAVY: Color = Color("051530")
const INK: Color = Color("0b2f63")
const SHADE: Color = Color(0, 0, 0, 0.8)

const BOLD: Font = preload("res://assets/fonts/flash_ui_bold.tres")
const SEMI: Font = BOLD
const MEDIUM: Font = BOLD
const REGULAR: Font = preload("res://assets/fonts/flash_ui.tres")
const TANK: float = 1.7

const STAND: Vector2 = Vector2(282, 299)

const CARDS: Array = [["pvp", "mode:pvp", 452, 100, 223, 134], ["pve", "mode:pve", 668, 100, 223, 134], 
	["league", "mode:league", 488, 237, 223, 134], ["territory", "mode:territory", 704, 237, 223, 134], 
	["rank", "nav:leaderboard", 527, 397, 109, 41], ["guild", "nav:guild", 637, 397, 109, 41], ["shop", "nav:shop", 747, 397, 109, 41]]

const CHAT_TABS: Array = [["all", "Tổng"], ["room", "Room"], ["camp", "Team"], ["guild", "Guild"], ["whisper", "Chat riêng"]]
const CHAT_LINES: int = 5
const WHEEL_FRAMES: int = 30
const WHEEL_FPS: float = 24.0

const BonfireView = preload("bonfire.gd")
const BonfireAtlas = preload("bonfire_atlas.gd")
const ACT_STEP: float = 66.0
const ACT_TIP: Vector2 = Vector2(30, 0)
const ACT_TIPS: Array = ["event:growth", "event:daily", "event:topup", "event:monthly", "event:first"]
const FIRST: int = 1400
const ACCUM_FROM: int = 1500
const ACCUM_TO: int = 1507
const QUEST_DONE: int = 3
const BALL: int = 2600004

const BALL_TIP: Vector2 = Vector2(25 + 3, 168 - 2 + 3)
const DAY: int = 86400
const VN: int = 25200

const PAGES: Dictionary = {"settings": "settings", "nav:friends": "friends", "nav:tank": "tank", "plate": "tank", "nav:bag": "bag", 
	"nav:shop": "shop", "nav:support": "helper", "nav:crystal": "crystal", "nav:rank": "rank", "nav:guild": "guild", 
	"nav:leaderboard": "board", "col:quest": "quest", "col:live": "quest:live", "event:daily": "events:sign", 
	"event:monthly": "events:card", "event:topup": "events:accum", "event:growth": "events:growth", "col:vip": "events:vip", 
	"event:wheel": "fair:wheel", "col:money": "fair:convert", "col:award": "fair:prize", "col:center": "fair:center", 
	"event:first": "events:first", 
	"mode:pve": "pve", 
	"mode:league": "league", 
	"mode:territory": "territory", 
	"event:boss": "boss"}

const NAMES: Dictionary = {"mode:pve": "Phụ Bản", "mode:league": "League", "mode:territory": "Lãnh Thổ Chiến", 
	"avatar": "Hồ sơ nhân vật", "stamina": "Mua thể lực", "buy:exp": "Mua EXP", "money": "Đổi tiền", "topup": "Nạp", 
	"money:cash": "Nạp", "money:gift": "Thẻ tháng", "money:gold": "Mua Bạc", 
	"event:mysterious": "Chợ Thần Bí", "event:store": "Cửa Hàng Thần Bí", "event:boss": "Kẻ Huỷ Diệt", "event:first": "Quà Lần Đầu", "col:book": "Huấn Luyện"}

var client: Client
var pack: AssetPack
var _hud: Texture2D
var _hud_asked: bool = false
var _rows: Dictionary = {}
var _hits: Array = []
var _hover: String = ""
var _press: String = ""
var _time: float = 0.0
var _u: float = 0.5
var _f: float = 1.0
var _fw: float = RW / 2.0
var _fh: float = RH / 2.0
var _mobile: bool = false
var _lp_start: float = -1.0
var _lp_at: Vector2 = Vector2.ZERO
var _lp_down: bool = false
var _lp_tip: bool = false
var _toast: String = ""
var _toast_at: float = -10.0
var chat_dock: Rect2 = Rect2()
var _chat_tab: String = "all"
var chat_modern: bool = false


var covered: bool = false:
	set(value):
		if covered == value:
			return
		covered = value
		_hover = ""
		_press = ""
		_mouse = Vector2(-1, -1)
		if not value:
			_data_asked = false
var _theme: String = ""
var _theme_asked: bool = false
var _theme_http: HTTPRequest
var _box: StyleBoxFlat = StyleBoxFlat.new()
var _act_x: Dictionary = {}
var _data_asked: bool = false
var _balls_rev: int = -1
var _balls_id: int = 0
var _balls_count: int = 0
var _dots: Array = []
var _newbie_on: bool = false
var _newbie_tex: Texture2D
var _return_on: bool = false
var _return_tex: Texture2D
var _luck_on: bool = false
var _luck_tex: Texture2D
const LUCK_TYPE: int = 137
const LUCK_ITEM: int = 2003170
var _exped_on: bool = false
var _exped_tex: Texture2D
const EXPED_LEVEL: int = 18
const EXPED_HOURS: Array = [24, 24, 72]
var _return_sent: float = -10.0
var _acc_tex: Texture2D
var _acc_rects: Array = []
var _acc_tip: String = ""
var _acc_text: String = ""
var _mouse: Vector2 = Vector2(-1, -1)
var _left_tex: Texture2D
var _left_swap: Dictionary = {}
var _award_http: HTTPRequest
var _award_ok: bool = false
var _award_ms: int = -1
var _award_stale: bool = false
var _char_tips: Array = []
var _char_tip: String = ""
var _ctip: CTip = CTip.new()
var _flex_tips: Dictionary = {}
var _menu_tex: Texture2D
var _menu_tips: Dictionary = {}

var _social = SocialMenu.new()
var _bonfire_texture: Texture2D
var _daily_open: bool = false
var daily_rect: Rect2 = Rect2()
var _kc_tex: Texture2D
const MYSTERIOUS_ACTS_PATH: String = "/xml/ActivityTemplate_table.xml"
const MYSTICAL_ACT_X: float = 132.0
var _mysterious_http: HTTPRequest
var _mysterious_templates_asked: bool = false
var _act_levels: Dictionary = {}
var _mysterious_tex: Texture2D
var _present: RefCounted = PresentTank.new()
var _social_base: Vector2 = Vector2(-1, -1)

var bar_style: String:
	get:
		return LobbyBar.current()

func _ready() -> void :
	_mobile = OS.has_feature("web_android") or OS.has_feature("web_ios") or OS.has_feature("android") or OS.has_feature("ios")
	mouse_exited.connect( func() -> void : _hover = "")
	mouse_exited.connect( func() -> void : _mouse = Vector2(-1, -1))
	visibility_changed.connect( func() -> void : _mouse = Vector2(-1, -1))
	visibility_changed.connect( func() -> void :
		_hover = ""
		_press = ""
		_lp_tip = false
		_lp_down = false
		_lp_start = -1.0
		_data_asked = false
		_daily_open = false
		_social = SocialMenu.new())
	_box.anti_aliasing = true
	for source_row: Array in Atlas.PLACE:
		var row: Array = source_row.duplicate()
		if NAPTIEN1_HIDE and str(row[3]) == "main_button_payment_t":
			continue
		if str(row[0]) == "acts":
			if str(row[4]) == "event:store":
				row[4] = "event:mysterious"
			if str(row[4]) in ["event:growth", "event:daily", "event:mysterious"]:
				row[1] = float(row[1]) - ACT_STEP
		if not _rows.has(row[0]):
			_rows[row[0]] = []
		_rows[row[0]].append(row)
		if str(row[0]) == "acts" and int(row[8]) == 1:
			_act_x[str(row[4])] = float(row[1])
	_act_x["event:store"] = MYSTICAL_ACT_X
	if client != null:
		client.noticed.connect( func(text: String) -> void :
			if is_visible_in_tree():
				say(text))
		client.prize_result.connect( func(_award: int, ok: bool) -> void : _award_stale = _award_stale or ok)
	var guide_view: Control = preload("guide_view.gd").new()
	guide_view.setup(self, "lobby")
	add_child(guide_view)
	_present.setup(self)


func chat_busy() -> bool:
	if _present.busy():
		return true
	return false

func _process(delta: float) -> void :
	_isle_keep()
	if not is_visible_in_tree():
		return
	_time += delta
	if _mobile and _lp_down and not _lp_tip and _lp_start >= 0.0 and _time - _lp_start >= KitScreen.LONG_PRESS:
		_lp_start = -1.0
		_lp_tip = true
		_press = ""
		_hover = _hit_at(_lp_at)
		_mouse = _lp_at
		Input.vibrate_handheld(25)
	if not _theme_asked and client != null and client.state == "lobby":
		_ask_theme()
	queue_redraw()


func _ask_theme() -> void :
	_theme_asked = true
	if not (OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("pc_app") or ( not OS.has_feature("editor") and DisplayServer.get_name() != "headless")):
		return
	_theme_http = HTTPRequest.new()
	_theme_http.timeout = 10
	_theme_http.accept_gzip = false
	add_child(_theme_http)
	_theme_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			var found: RegExMatch = RegEx.create_from_string("<hall[^>]*\\stheme=\"([a-z0-9_]*)\"").search(body.get_string_from_utf8())
			_theme = found.get_string(1) if found != null else ""
		_theme_http.queue_free())
	var url: String = client.config.origin + "/hall-theme.xml"
	if _theme_http.request(url, AppSession.headers(url)) != OK:
		_theme_http.queue_free()

func _hall_name() -> String:
	var halls: Dictionary = pack.lobby.get("halls", {})
	return _theme if halls.has(_theme) else "native"



func backdrop_hall() -> String:
	if ISLAND_HALL:
		return "isle:" + _noel.file("sea", _isle_mode)
	return _hall_name()



func _metrics() -> void :
	var window: Vector2 = preload("res://settings.gd").native_size(Vector2(get_window().size))
	var stretch: float = maxf(0.01, window.x / maxf(1.0, size.x))

	var k: float = BrowserZoom.frame_k(window, RW, RH, _mobile)
	_u = maxf(0.05, k / stretch)
	_f = 2.0 * _u
	_fw = size.x / _f
	_fh = size.y / _f


func _origin(frame: String) -> Vector2:
	var row: Array = Atlas.FRAME[frame]
	var wide: float = floorf(_fw + 0.01)
	var high: float = floorf(_fh + 0.01)
	var corner: Vector2 = Vector2.ZERO
	match str(row[0]):
		"tr":
			corner = Vector2(wide, 0)
		"bl":
			corner = Vector2(0, high)
		"br":
			corner = Vector2(wide, high)
		"c":
			corner = Vector2(roundf((wide - 1000.0) / 2.0), roundf((high - 600.0) / 2.0))
	return corner + Vector2(float(row[1]), float(row[2])) + _safe_pad(str(row[0]))



func _safe_pad(anchor: String) -> Vector2:
	if not _mobile or anchor not in ["tl", "tr", "bl", "br"] or _f <= 0.0:
		return Vector2.ZERO
	var p: Vector2 = (SafeArea.corner_pad(size, anchor) / _f).ceil()
	return Vector2(p.x if anchor.ends_with("l") else - p.x, p.y if anchor.begins_with("t") else - p.y)



const TL1_FILE: String = "res://assets/ui/hall/tichluy1.png"
const TL1_HUD: Dictionary = {"main_word_accumulate_t": [0, 81, 64, 19], "main_word_firstPay_t": [66, 81, 64, 19]}
var _tl1: Texture2D = null

func _tl1_tex() -> Texture2D:
	if _tl1 == null and ResourceLoader.exists(TL1_FILE):
		_tl1 = load(TL1_FILE)
	return _tl1


func _blit(name: String, at: Vector2, wide: float = 0.0, high: float = 0.0, tint: Color = Color.WHITE) -> Rect2:
	var region: Array = Atlas.R[name]
	if _hud != null and TL1_HUD.has(name) and _tl1_tex() != null:
		var cell: Array = TL1_HUD[name]
		var box: Rect2 = Rect2(at * _f, Vector2(wide if wide > 0.0 else float(cell[2]), high if high > 0.0 else float(cell[3])) * _f)
		draw_texture_rect_region(_tl1, box, Rect2(cell[0], cell[1], cell[2], cell[3]), tint)
		return box
	var rect: Rect2 = Rect2(at * _f, Vector2(wide if wide > 0.0 else float(region[2]), high if high > 0.0 else float(region[3])) * _f)
	if _hud != null:
		draw_texture_rect_region(_hud, rect, Rect2(region[0], region[1], region[2], region[3]), tint)
	return rect


func _level_fx(level: int, at: Vector2, wide: float) -> void :
	TankPortrait.level_fx(self, pack, level, at, wide, _f, _time)



func _place(frame: String, solid: bool = false, hidden: Array = []) -> void :
	var base: Vector2 = _origin(frame)
	for row: Array in _rows.get(frame, []):
		var id: String = str(row[4])
		if not hidden.is_empty() and hidden.has(id):
			continue
		var at: Vector2 = base + Vector2(float(row[1]) + _act_shift(id, hidden), float(row[2]) + (_rand_drop(id) if frame == "left" else 0.0))
		if frame == "left" and _left_swap.has(str(row[3])):
			_draw_left_glow(str(row[3]), at, id)
			continue
		var rect: Rect2
		if str(row[3]).is_empty():
			rect = Rect2(at * _f, Vector2(float(row[5]), float(row[6])) * _f)
		else:
			var lit: float = 1.0 if id.is_empty() else _lit(id)
			rect = _blit(str(row[3]), at, float(row[5]), float(row[6]), Color(lit, lit, lit, 1.0 if solid else float(row[7]) / 100.0))
		if int(row[8]) == 1 and not id.is_empty():
			_hit(id, rect)
			if (frame == "menu" or frame == "coin") and FLEX_TIPS.has(id):
				_flex_tips[id] = rect



func _string(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, width: float, outline: Color = INK, thick: float = 0.0) -> float:
	var font_size: int = maxi(6, roundi(px * _u))
	var origin: Vector2 = at
	var mode: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
	if align == "c":
		origin.x -= width / 2.0
		mode = HORIZONTAL_ALIGNMENT_CENTER
	elif align == "r":
		origin.x -= width
		mode = HORIZONTAL_ALIGNMENT_RIGHT
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	if thick > 0.0:
		draw_string_outline(font, origin, text, mode, width, font_size, maxi(1, roundi(thick * _u)), Color(outline, outline.a * color.a))
	draw_string(font, origin, text, mode, width, font_size, color)
	return minf(width, font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)




func _words(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, wide: float, edge: float = 0.0, high: float = 0.0, shrink: bool = true) -> float:
	var shown: float = px
	if shrink:
		while shown > 8.0 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(shown * _f))).x > wide * _f:
			shown -= 1.0
	var middle: float = at.y + (high / 2.0 if high > 0.0 else 2.0 + px * 0.55)
	var x: float = at.x if align == "l" else (at.x + wide / 2.0 if align == "c" else at.x + wide)
	return _string(text, font, shown * 2.0, color, align, Vector2(x, middle) * _f, wide * _f, SHADE, edge * 2.0) / _f


func _face(font: Font) -> Font:
	return font


func _hit(id: String, rect: Rect2, _feedback: bool = true) -> void :
	_hits.append([id, rect])

func _hit_at(point: Vector2) -> String:
	for i in range(_hits.size() - 1, -1, -1):
		if (_hits[i][1] as Rect2).has_point(point) and (_hits[i].size() < 3 or _isle_hit(int(_hits[i][2]), point)):
			return str(_hits[i][0])
	return ""


func _lit(id: String) -> float:
	if _press == id:
		return 0.78
	if _hover == id and _press.is_empty():
		return 1.16
	return 1.0

func _round(rect: Rect2, fill: Color, radius: float, edge: Color = Color(0, 0, 0, 0), width: float = 0.0) -> void :
	_box.bg_color = fill
	_box.set_corner_radius_all(maxi(1, roundi(minf(radius * _u, rect.size.y / 2.0))))
	_box.border_color = edge
	_box.set_border_width_all(maxi(1, roundi(width * _u)) if width > 0.0 else 0)
	draw_style_box(_box, rect)


func _sprite(texture: Texture2D, rect: Rect2, id: String) -> void :
	if texture == null:
		return
	var lit: float = _lit(id)
	draw_texture_rect(texture, rect, false, Color(lit, lit, lit, 1.0))



func _draw() -> void :
	if client == null or pack == null:
		return
	_hits.clear()
	_dots.clear()
	_flex_tips.clear()
	_metrics()
	if not _hud_asked:
		_hud_asked = true
		if ResourceLoader.exists(Atlas.FILE):
			_hud = load(Atlas.FILE)
	if _draw_theme():
		pass
	else:
		_draw_scene()
		_draw_cards()
		_place("tank")
		_draw_plate()
	_place("char")
	_draw_player()
	_draw_acc()
	_place("coin")
	_draw_money()
	_ask_data()
	_newbie_on = NewbieLogin.shown(client)
	_return_on = ReturnGift.act_shown(client)
	_luck_on = luck_open()
	_exped_on = expedition_shown()
	var hidden: Array = _acts_hidden()
	_place("acts", false, hidden)
	_draw_mystical_act(hidden)
	_draw_act_tips(hidden)
	_draw_newbie(hidden)
	_draw_return_act(hidden)
	_draw_luck_act(hidden)
	_draw_exped_act(hidden)
	_rand_on = not _rand_hidden and RandRules.open(client.quests)
	_draw_wheel()
	_left_swap = _left_rewards()
	_place("left")
	_draw_rand_left()
	_draw_balls()
	_place("right")
	_draw_award_tip()
	_draw_return_right()
	_draw_bar()

	var solid: bool = _hover == "chat" or _hover.begins_with("tab:")
	if chat_modern:
		chat_dock = Rect2((_origin("input") + Vector2(6, -3)) * _f, Vector2(447, 43) * _f)
	else:
		_place("chat", solid)
		_draw_chat(solid)
	_present.draw(self)
	_menu_tips = _menu_state()
	_draw_menu_bar()
	_draw_social()
	_draw_overtime()
	_draw_toast()
	_draw_acc_tip()
	_draw_char_tip()
	_draw_flex_tip()
	_present.tip(self)
	_draw_daily(hidden)
	mouse_default_cursor_shape = CURSOR_POINTING_HAND if not _hover.is_empty() else CURSOR_ARROW


func _draw_theme() -> bool:
	var theme: Dictionary = LobbyThemes.current()
	if theme.is_empty() or not has_method(str(theme["check"])) or not has_method(str(theme["build"])):
		return false
	if not bool(call(str(theme["check"]))):
		if ISLAND_HALL and LobbyThemes.kind(theme) in ["island", "noel", "cuoi"]:
			_isle_shown = "cover"
			_draw_isle_cover()
			return true
		_isle_shown = ""
		return false
	_isle_shown = str(theme["id"])
	call(str(theme["build"]))
	return true



func _draw_scene() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), NAVY)
	var hall: Dictionary = pack.lobby.get("halls", {}).get(_hall_name(), {})
	if hall.is_empty():
		return
	var folder: String = "l/hall/%s/" % _hall_name()
	var background: Texture2D = pack.picture(folder + "bg.webp")
	if background != null:
		draw_texture_rect(background, Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = (_origin("mid") + STAND) * _f
	var platform: Texture2D = pack.picture(folder + "plat.webp")
	if platform != null:
		draw_texture_rect(platform, Rect2(at - Vector2(float(hall.pad[0]), float(hall.pad[1])) * _f, platform.get_size() * _f), false)
	var tank: Dictionary = client.current_tank()
	if tank.is_empty() or pack.state != "ready":
		return

	pack.load_garage()
	if pack.garage.is_empty() and _time < 4.0:
		return
	var level: int = maxi(1, int(tank.get("m_level", 1)))
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(tank.get("m_tpltId", 0)), level, tank)
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(tank.get("m_haloId", 0)), level)
	if TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, at - Vector2(0, 46) * _f, _f, _time):
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(int(tank.get("m_externalId", 0))), int(tank.get("m_tpltId", 0))))
	if TankPreview.ready(art):
		TankPreview.draw(self, art, at, _f * TANK, 4, _time)


func _draw_cards() -> void :
	var folder: String = "l/hall/%s/" % _hall_name()
	var base: Vector2 = _origin("mid")
	for card: Array in CARDS:
		var id: String = str(card[1])
		var rect: Rect2 = Rect2((base + Vector2(float(card[2]), float(card[3]))) * _f, Vector2(float(card[4]), float(card[5])) * _f)
		_sprite(pack.picture(folder + str(card[0]) + ".webp"), rect, id)

		_hit(id, rect.grow_individual(-4 * _f, -7 * _f, -4 * _f, -2 * _f) if int(card[5]) > 100 else rect)


func _draw_plate() -> void :
	var tank: Dictionary = client.current_tank()
	if tank.is_empty():
		return
	var base: Vector2 = _origin("tank")
	_blit("tklv_%d" % clampi(int(tank.get("m_level", 1)), 1, 11), base + Vector2(30, 55))
	var name: String = str(pack.lobby.get("tanks", {}).get(str(int(tank.get("m_tpltId", 0))), "Tank"))
	_words(name, MEDIUM, 16.0, Color.WHITE, "c", base + Vector2(68, 52), 133.0, 1.0)


func _draw_player() -> void :
	var base: Vector2 = _origin("char")
	var basic: Dictionary = client.character
	var avatar: String = str(pack.lobby.get("avatars", {}).get(str(int(basic.get("avatarId", 0))), ""))
	if avatar.is_empty():
		avatar = "girl001" if int(basic.get("sexes", 1)) == 2 else "boy001"
	var frame: Rect2 = Rect2((base + Vector2(2, 2)) * _f, Vector2(60, 60) * _f)
	var av_pic: Texture2D = pack.picture("l/av/%s.webp" % avatar)
	if av_pic != null and av_pic.get_width() > 10:
		var crop_w: float = minf(float(av_pic.get_width()) * 0.78, 140.0)
		var crop_x: float = (float(av_pic.get_width()) - crop_w) / 2.0
		var src_rect: Rect2 = Rect2(crop_x, 0.0, crop_w, crop_w)
		var lit: float = _lit("avatar")
		draw_texture_rect_region(av_pic, frame, src_rect, Color(lit, lit, lit, 1.0))
	else:
		var head: Texture2D = pack.picture("l/h/%s.webp" % avatar)
		_sprite(head, frame, "avatar")
	_hit("avatar", frame)
	var points: int = int(basic.get("vipPoints", 0))
	var vip: int = mini(12, _vip_level(points))
	if vip > 0:
		_blit("vip_%d" % vip, base + Vector2(6, 9))
	var level: int = int(basic.get("level", 1))
	_blit("level_%d" % clampi(level, 0, 40), base + Vector2(64, 6), 40.0, 20.0)
	_level_fx(level, base + Vector2(64, 6), 40.0)
	var love_me: bool = Love.has(client, Love.me(client))
	var love_room: float = 136.0 - (18.0 if love_me else 0.0)
	var own_ink: bool = NameStyles.paint(self, str(basic.get("name", client.account.get("name", ""))), REGULAR, 13.0, "l", base + Vector2(108, 7), love_room, 1.0)
	var love_used: float = _words(str(basic.get("name", client.account.get("name", ""))), REGULAR, 13.0, Color(1, 1, 1, 0) if own_ink else Color.WHITE, "l", base + Vector2(108, 7), love_room, 1.0)
	if love_me:
		Love.fdraw(self, base + Vector2(108.0 + love_used + Love.NAME_GAP, 9.0), Love.SIDE)

	var levels: Dictionary = pack.lobby.get("levels", {})
	var need: float = float(levels.get(str(level), [0, 0])[0])
	var gained: int = int(basic.get("exp", 0))
	var top: bool = need <= 0.0 or not levels.has(str(level + 1))
	var grown: int = 100 if top else clampi(floori(gained * 100.0 / need), 0, 100)
	_meter("bar_orange", base + Vector2(110, 33), grown)
	var exp_text: String = "%d%%" % grown if top or level > 24 else "%d/%d(%d%%)" % [gained, int(need), grown]
	_bar_words(exp_text, base + Vector2(104, 29), BAR_GLOW_EXP)
	var thew: int = int(basic.get("thew", 0))
	var cap: int = 200 + _vip_thew(points)
	var rate: int = floori(thew * 100.0 / cap)
	_meter("bar_green", base + Vector2(110, 49), clampi(rate, 0, 100))
	_bar_words("%d/%d(%d%%)" % [thew, cap, rate], base + Vector2(104, 45), BAR_GLOW_THEW)
	_char_tips = CharTips.tips(basic, _now(), cap)



func _meter(name: String, at: Vector2, percent: int) -> void :
	if percent <= 0 or _hud == null:
		return
	var region: Array = Atlas.R[name]
	var full: float = float(region[2])
	var body: float = minf(full, percent + 3.0) - 3.0
	draw_texture_rect_region(_hud, Rect2(at * _f, Vector2(3, region[3]) * _f), Rect2(region[0], region[1], 3, region[3]))
	draw_texture_rect_region(_hud, Rect2((at + Vector2(3, 0)) * _f, Vector2(body, region[3]) * _f), Rect2(region[0] + full - body, region[1], body, region[3]))


func _vip_level(points: int) -> int:
	var level: int = 0
	for row: Array in pack.lobby.get("vip", []):
		if points >= int(row[0]):
			level += 1
	return level

func _vip_thew(points: int) -> int:
	var extra: int = 0
	for row: Array in pack.lobby.get("vip", []):
		if points >= int(row[0]):
			extra = int(row[1])
	return extra



func _draw_money() -> void :
	var base: Vector2 = _origin("coin")
	_digits(int(client.currency.get("m_iCash", 0)), 0, base + Vector2(207, 8))
	_digits(int(client.currency.get("m_iSilver", 0)), 1, base + Vector2(346, 8))
	_digits(int(client.currency.get("m_iGolden", 0)), 3, base + Vector2(484, 8))

func _digits(value: int, line: int, right: Vector2) -> void :
	if _hud == null:
		return
	var text: String = str(maxi(0, value))
	var region: Array = Atlas.R["number"]
	var left: float = right.x - 10.0 * text.length()
	for i in range(text.length()):
		var digit: int = text.unicode_at(i) - 48
		draw_texture_rect_region(_hud, Rect2(Vector2(left + 10.0 * i, right.y) * _f, Vector2(10, 14) * _f), Rect2(region[0] + 10 * digit, region[1] + 14 * line, 10, 14))


func _draw_wheel() -> void :
	var lit: float = _lit("event:wheel")
	_blit("gambling_%d" % (int(_time * WHEEL_FPS) % WHEEL_FRAMES), _origin("left") + Vector2(0, 168 + _rand_drop("event:wheel")), 0.0, 0.0, Color(lit, lit, lit, 1.0))




func _ask_data() -> void :
	if _data_asked:
		return
	_data_asked = true
	pack.load_events()
	pack.load_eventsx()
	pack.load_fair()
	pack.load_quest()
	_ask_award()
	_ask_mysterious_templates()


func _acts_hidden() -> Array:
	var out: Array = []
	if _accum_done():
		out.append("event:topup")
	if _first_done():
		out.append("event:first")
	if not MysteriousStore.is_open(client):
		out.append("event:mysterious")
	if not MysticalShop.is_open(client, int(Time.get_unix_time_from_system())):
		out.append("event:store")
	if client.world_boss_wait_at() > 0:
		out.append("event:boss")
	return out


func _act_shift(id: String, hidden: Array) -> float:
	var luck: float = ACT_STEP if _luck_on and _act_x.has(id) and float(_act_x[id]) <= float(LuckAtlas.ACT["at"]) else 0.0
	return _act_shift_base(id, hidden) - luck - _exped_shift(id)

func _act_shift_base(id: String, hidden: Array) -> float:
	if _return_on and _act_x.has(id) and float(_act_x[id]) <= float(ReturnAtlas.ACT["at"]):
		return _newbie_gap(float(_act_x[id]), hidden) - ACT_STEP * (2.0 if _newbie_on else 1.0)
	if _newbie_on and _act_x.has(id) and float(_act_x[id]) <= float(NewbieAtlas.ACT["at"]):
		return _newbie_gap(float(_act_x[id]), hidden) - ACT_STEP
	if hidden.is_empty() or not _act_x.has(id):
		return 0.0
	var shift: float = 0.0
	for gone: String in hidden:
		if float(_act_x.get(gone, -1.0)) > float(_act_x[id]):
			shift += ACT_STEP
	return shift

func _draw_act_tips(hidden: Array) -> void :
	var base: Vector2 = _origin("acts")
	for id: String in ACT_TIPS:
		if _act_x.has(id) and not hidden.has(id) and _act_due(id):
			_dots.append(id)
			_blit("public_tip", base + Vector2(float(_act_x[id]) + _act_shift(id, hidden), 0.0) + ACT_TIP)


func _newbie_gap(x: float, hidden: Array) -> float:
	var shift: float = 0.0
	for gone: String in hidden:
		if float(_act_x.get(gone, -1.0)) > x:
			shift += ACT_STEP
	return shift



func _draw_newbie(hidden: Array) -> void :
	if not _newbie_on:
		return
	if _newbie_tex == null and ResourceLoader.exists(NewbieAtlas.FILE):
		_newbie_tex = load(NewbieAtlas.FILE)
	var x: float = float(NewbieAtlas.ACT["at"])
	var at: Vector2 = _origin("acts") + Vector2(x + _newbie_gap(x, hidden), 0.0)
	var lit: float = _lit("event:newbie")
	var icon: Rect2 = _newbie_blit("nb_act", at, Color(lit, lit, lit, 1.0))
	var word: Array = NewbieAtlas.ACT["word"]
	_newbie_blit("nb_act_word", at + Vector2(float(word[0]), float(word[1])), Color(lit, lit, lit, 1.0))
	if NewbieLogin.due(client):
		_dots.append("event:newbie")
		_blit("public_tip", at + ACT_TIP)
	_hit("event:newbie", icon)

func _newbie_blit(name: String, at: Vector2, tint: Color) -> Rect2:
	var region: Array = NewbieAtlas.R[name]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	if _newbie_tex != null:
		draw_texture_rect_region(_newbie_tex, rect, Rect2(region[0], region[1], region[2], region[3]), tint)
	return rect




func _draw_return_act(hidden: Array) -> void :
	if not _return_on:
		return
	var x: float = float(ReturnAtlas.ACT["at"])
	var at: Vector2 = _origin("acts") + Vector2(x + _newbie_gap(x, hidden) - (ACT_STEP if _newbie_on else 0.0) - (ACT_STEP if _exped_on else 0.0), 0.0)
	var lit: float = _lit("event:return")
	var icon: Rect2 = _return_blit("rt_act", at, Color(lit, lit, lit, 1.0))
	var word: Array = ReturnAtlas.ACT["word"]
	_return_blit("rt_act_word", at + Vector2(float(word[0]), float(word[1])), Color(lit, lit, lit, 1.0))
	var tip: Array = ReturnAtlas.ACT["tip"]
	_dots.append("event:return")
	_blit("public_tip", at + Vector2(float(tip[0]), float(tip[1])))
	_hit("event:return", icon)



func luck_open(now: int = -1) -> bool:
	if client == null:
		return false
	var level: int = int(client.character.get("level", 0))
	for id: Variant in client.act_types:
		if int(client.act_types[id]) == LUCK_TYPE and level >= int(_act_levels.get(int(id), 0)) and client.act_now_state(int(id), now) == 2:
			return true
	return false




func _draw_luck_act(hidden: Array) -> void :
	if not _luck_on:
		return
	if _luck_tex == null and ResourceLoader.exists(LuckAtlas.FILE):
		_luck_tex = load(LuckAtlas.FILE)
	var x: float = float(LuckAtlas.ACT["at"])
	var at: Vector2 = _origin("acts") + Vector2(x + _newbie_gap(x, hidden) - (ACT_STEP if _newbie_on else 0.0) - (ACT_STEP if _return_on else 0.0)
		- (ACT_STEP if _exped_on else 0.0), 0.0)
	var lit: float = _lit("event:luck")
	var icon: Rect2 = _luck_blit("vl_act", at, Color(lit, lit, lit, 1.0))
	var word: Array = LuckAtlas.ACT["word"]
	_luck_blit("vl_act_word", at + Vector2(float(word[0]), float(word[1])), Color(lit, lit, lit, 1.0))
	if client.bag_loaded and BagModel.item_count(client.bags, LUCK_ITEM) > 0:
		var tip: Array = LuckAtlas.ACT["tip"]
		_dots.append("event:luck")
		_blit("public_tip", at + Vector2(float(tip[0]), float(tip[1])))
	_hit("event:luck", icon)



func expedition_shown() -> bool:
	return client != null and bool(client.expedition.get("live", false)) and int(client.character.get("level", 0)) >= EXPED_LEVEL


func expedition_due(now: int = -1) -> bool:
	if client == null:
		return false
	var at: int = client.expedition_now() if now < 0 else now
	var times: Array = client.expedition.get("times", [])
	for i in range(mini(3, times.size())):
		if int(times[i]) > 0 and at - int(times[i]) >= int(EXPED_HOURS[i]) * 3600:
			return true
	return false


func _exped_shift(id: String) -> float:
	return ACT_STEP if _exped_on and _act_x.has(id) and float(_act_x[id]) <= float(ExpAtlas.ACT["at"]) else 0.0



func _draw_exped_act(hidden: Array) -> void :
	if not _exped_on:
		return
	if _exped_tex == null and ResourceLoader.exists(ExpAtlas.FILE):
		_exped_tex = load(ExpAtlas.FILE)
	var x: float = float(ExpAtlas.ACT["at"])
	var at: Vector2 = _origin("acts") + Vector2(x + _newbie_gap(x, hidden) - (ACT_STEP if _newbie_on else 0.0), 0.0)
	var lit: float = _lit("event:expedition")
	var icon: Rect2 = _exped_blit("ex_act", at, Color(lit, lit, lit, 1.0))
	var word: Array = ExpAtlas.ACT["word"]
	_exped_blit("ex_act_word", at + Vector2(float(word[0]), float(word[1])), Color(lit, lit, lit, 1.0))
	if expedition_due():
		var tip: Array = ExpAtlas.ACT["tip"]
		_dots.append("event:expedition")
		_blit("public_tip", at + Vector2(float(tip[0]), float(tip[1])))
	_hit("event:expedition", icon)

func _exped_blit(name: String, at: Vector2, tint: Color) -> Rect2:
	var region: Array = ExpAtlas.R[name]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	if _exped_tex != null:
		draw_texture_rect_region(_exped_tex, rect, Rect2(region[0], region[1], region[2], region[3]), tint)
	return rect

func _luck_blit(name: String, at: Vector2, tint: Color) -> Rect2:
	var region: Array = LuckAtlas.R[name]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	if _luck_tex != null:
		draw_texture_rect_region(_luck_tex, rect, Rect2(region[0], region[1], region[2], region[3]), tint)
	return rect



func _draw_return_right() -> void :
	if not ReturnGift.right_shown(client):
		return
	var at: Vector2 = _origin("right") + Vector2(0.0, float(ReturnAtlas.RIGHT["y"]))
	var lit: float = _lit("col:return")
	var icon: Rect2 = _return_blit("rt_right", at, Color(lit, lit, lit, 1.0))
	var word: Array = ReturnAtlas.RIGHT["word"]
	_return_blit("rt_right_word", at + Vector2(float(word[0]), float(word[1])), Color(lit, lit, lit, 1.0))
	if ReturnGift.due(client):
		var tip: Array = ReturnAtlas.RIGHT["tip"]
		_dots.append("col:return")
		_blit("public_tip", at + Vector2(float(tip[0]), float(tip[1])))
	_hit("col:return", icon)

func _return_blit(name: String, at: Vector2, tint: Color) -> Rect2:
	if _return_tex == null and ResourceLoader.exists(ReturnAtlas.FILE):
		_return_tex = load(ReturnAtlas.FILE)
	var region: Array = ReturnAtlas.R[name]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	if _return_tex != null:
		draw_texture_rect_region(_return_tex, rect, Rect2(region[0], region[1], region[2], region[3]), tint)
	return rect


func _return_reap() -> void :
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _return_sent < ReturnGift.RESEND or not ReturnGift.right_shown(client):
		return
	if client.stage_reap(ReturnGift.STAGE, true):
		_return_sent = now




func _draw_acc() -> void :
	_acc_rects.clear()
	if _acc_tex == null and ResourceLoader.exists(AccAtlas.FILE):
		_acc_tex = load(AccAtlas.FILE)
	var at: Vector2 = _origin("char") + Vector2(float(AccAtlas.AT[0]), float(AccAtlas.AT[1]))
	var side: float = float(AccAtlas.SIDE)
	for card: Array in AccCards.cards(client.character, _now()):
		var region: Array = AccAtlas.R[str(card[0])]
		var rect: Rect2 = Rect2(at * _f, Vector2(side, side) * _f)
		if _acc_tex != null:
			draw_texture_rect_region(_acc_tex, rect, Rect2(region[0], region[1], region[2], region[3]))
		_acc_rects.append([card, rect])
		at.x += side + float(AccAtlas.GAP)


func _draw_acc_tip() -> void :
	_acc_tip = ""
	if not _tip_ok() or not _hover.is_empty() or not _press.is_empty():
		return
	for row: Array in _acc_rects:
		if (row[1] as Rect2).has_point(_mouse):
			var card: Array = row[0]
			_acc_tip = str(card[0])
			_acc_text = _flex_card(card)
			return



func _hall_tip(anchor: Rect2, title: String, body: String) -> void :
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = REGULAR.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_words(title, BOLD, 13.0, Color.WHITE, "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		draw_multiline_string(REGULAR, Vector2(at.x + 10.0, at.y + 28.0) * _f + Vector2(0, REGULAR.get_ascent(body_px)), body, 
			HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8, Color.WHITE)



func _draw_char_tip() -> void :
	_char_tip = ""
	if not _tip_ok() or not _hover.is_empty() or not _press.is_empty() or not _acc_tip.is_empty():
		return
	var base: Vector2 = _origin("char")
	for row: Array in _char_tips:
		var area: Rect2 = row[0]
		var rect: Rect2 = Rect2((base + area.position) * _f, area.size * _f)
		if rect.has_point(_mouse):
			_char_tip = str(row[1])
			return



static func _flex_card(card: Array) -> String:
	return str(card[1]) if str(card[2]).is_empty() else str(card[1]) + "\n" + str(card[2])



func _draw_flex_tip() -> void :
	var key: String = ""
	var text: String = ""
	var at: Vector2 = _mouse / _f
	if _tip_ok() and _press.is_empty():
		if _flex_tips.has(_hover) and (_flex_tips[_hover] as Rect2).has_point(_mouse):
			key = _hover
			text = str(FLEX_TIPS[_hover])
			if _hover == "nav:talent" and not LobbyBar.talent_block(client).is_empty():
				text = LobbyBar.talent_block(client)
		elif _hover == "social:history" and _social.open:
			key = _hover
			text = str(SocialMenu.TIPS[_hover])
			at = _history_tip(text)
		elif not _acc_tip.is_empty():
			key = "acc:" + _acc_tip
			text = _acc_text
		elif not _char_tip.is_empty():
			var card: Array = AccCards.card("", _char_tip)
			key = "char:" + str(card[1])
			text = _flex_card(card)
	_ctip.draw(self, key, text, at, Vector2(_fw, _fh), _f)



func _history_tip(text: String) -> Vector2:
	var button: Rect2 = Rect2(_social_at() + SocialMenu.AT + Vector2(0, SocialMenu.HISTORY_Y), Vector2(SocialMenu.SIDE, SocialMenu.SIDE))
	var size: Vector2 = CTip.box(text, Vector2.ZERO, Vector2(_fw, _fh), _f).size
	return Vector2(button.position.x - 4.0 - size.x, button.get_center().y - size.y / 2.0) - Vector2(11, 22)



func _left_rewards() -> Dictionary:
	var out: Dictionary = {}
	var on: Array = []
	if LeftGlow.quest_due(client.quests, pack.quest.get("quests", {})):
		on.append("col_quest")
	if LeftGlow.fizz_state(client.stages, client.stages_cleared) == LeftGlow.HAS:
		on.append("main_livepoint")
	for cell: String in on:
		out[cell] = float(_left_swap.get(cell, _time))
	return out



func _draw_left_glow(cell: String, at: Vector2, id: String) -> void :
	if _left_tex == null and ResourceLoader.exists(LeftGlowAtlas.FILE):
		_left_tex = load(LeftGlowAtlas.FILE)
	if _left_tex == null:
		return
	var step: int = LeftGlow.frame(_time - float(_left_swap.get(cell, _time)), int(LeftGlowAtlas.FRAMES))
	var art: String = str(LeftGlowAtlas.CELLS[cell])
	var rect: Rect2 = Rect2((at + Vector2(0.0, float(LeftGlowAtlas.BOB[step]))) * _f, Vector2(LeftGlowAtlas.SIDE, LeftGlowAtlas.SIDE) * _f)
	var lit: float = _lit(id)
	var region: Array = LeftGlowAtlas.R[art]
	draw_texture_rect_region(_left_tex, rect, Rect2(region[0], region[1], region[2], region[3]), Color(lit, lit, lit, 1.0))
	var glow: float = float(LeftGlowAtlas.GLOW[step])
	if glow > 0.0:
		var white: Array = LeftGlowAtlas.R[art + "_white"]
		draw_texture_rect_region(_left_tex, rect, Rect2(white[0], white[1], white[2], white[3]), Color(1, 1, 1, glow))



func _ask_award() -> void :
	if _award_http != null or not ActPrize.want(_award_ms, Time.get_ticks_msec(), _award_stale):
		return
	if not (OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("pc_app") or ( not OS.has_feature("editor") and DisplayServer.get_name() != "headless")) or client.account_id <= 0:
		return
	_award_ms = Time.get_ticks_msec()
	_award_stale = false
	_award_http = HTTPRequest.new()
	_award_http.timeout = 10
	_award_http.accept_gzip = false
	add_child(_award_http)
	_award_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			var due: int = ActPrize.due(body)
			if due != ActPrize.BAD:
				_award_ok = due == ActPrize.HAS
		_award_http.queue_free()
		_award_http = null)
	var url: String = client.config.origin + "/getuseraward.php?account_id=%d" % client.account_id
	if _award_http.request(url, AppSession.headers(url)) != OK:
		_award_http.queue_free()
		_award_http = null


func _draw_award_tip() -> void :
	if not _award_ok:
		return
	for row: Array in _rows.get("right", []):
		if str(row[3]) == "main_actaward":
			_dots.append("col:award")
			_blit("public_tip", _origin("right") + Vector2(float(row[1]), float(row[2])) + ACT_TIP)
			return

func _act_due(id: String) -> bool:
	match id:
		"event:growth":
			return _growth_due()
		"event:daily":
			return _sign_due() or _challenge_due() or _bonfire_due()
		"event:topup":
			return _accum_open()
		"event:monthly":
			return _card_days() > 0
		"event:first":
			return true
	return false


func _growth_due() -> bool:
	var quests: Array = (pack.eventsx.get("growth_back", []) as Array).duplicate()
	var growth: Dictionary = pack.events.get("growth", {})
	if int(client.limits.get(int(growth.get("limit", 1018)), 0)) > 0:
		quests.append_array(growth.get("quests", []))
	for quest: Variant in quests:
		var info: Variant = client.quests.get(int(quest))
		if info is Array and not (info as Array).is_empty() and int(info[0]) == QUEST_DONE:
			return true
	return false


func _sign_due() -> bool:
	if client.sign_in.is_empty():
		return false
	var day: int = int(client.sign_in.get("day", 0))
	var vip: bool = maxi(int(client.character.get("vipTime", 0)), int(client.character.get("superVipTime", 0))) > _now()
	var flag: int = int(client.sign_in.get("vip_flag" if vip else "flag", 0))
	return ((flag >> day) & 1) == 0


func _challenge_due() -> bool:
	return client.challenge_loaded and int(client.challenge.get("count", 0)) > 0



func _draw_daily(hidden: Array) -> void :
	daily_rect = Rect2()
	if not _daily_open or not _act_x.has("event:daily") or hidden.has("event:daily"):
		return
	if _kc_tex == null and ResourceLoader.exists(ChallengeAtlas.FILE):
		_kc_tex = load(ChallengeAtlas.FILE)
	var spot: Vector2 = _origin("acts") + Vector2(float(_act_x["event:daily"]) + _act_shift("event:daily", hidden), 0.0)
	var daily: Dictionary = ChallengeAtlas.DAILY
	var bg: Rect2 = _kc_blit("kc_dd_bg", spot + Vector2(float(daily.bg[0]), float(daily.bg[1])), Color.WHITE)
	_hit("daily:bg", bg)
	daily_rect = bg
	var first: Vector2 = spot + Vector2(float(daily.first[0]), float(daily.first[1]))
	var word: Vector2 = Vector2(float(daily.word[0]), float(daily.word[1]))
	var bonfire_on: bool = BonfireView.activity_open(_now(), client.acts)
	var count: int = 3 if bonfire_on else 2
	for i: int in count:
		var kind: int = i if bonfire_on else i + 1
		var id: String = ["daily:bonfire", "daily:pk", "daily:sign"][kind]
		var cell: String = ["bf_lobby", "kc_dd_pk", "kc_dd_sign"][kind]
		var at: Vector2 = first + Vector2(float(daily.step) * float(i), 0.0)
		var lit: float = _lit(id)
		var icon: Rect2
		if kind == 0:
			icon = _bonfire_blit(cell, at, Color(lit, lit, lit, 1))
			_bonfire_blit("bf_word", at + Vector2(-6.5, 33), Color(lit, lit, lit, 1))
		else:
			icon = _kc_blit(cell, at, Color(lit, lit, lit, 1.0))
			_kc_blit(cell + "_t", at + word, Color(lit, lit, lit, 1.0))
		_hit(id, icon)
		daily_rect = daily_rect.merge(icon)
		if kind == 1 and _challenge_due():
			var num: Vector2 = at + Vector2(float(daily.num[0]), float(daily.num[1]))
			_blit("public_tip", num + Vector2(3, 3))
			_words(str(int(client.challenge.get("count", 0))), BOLD, 11.0, Color.WHITE, "c", num, 25.0, 0.0, 25.0)
		elif (kind == 2 and _sign_due()) or (kind == 0 and _bonfire_due()):
			_blit("public_tip", at + Vector2(float(daily.tip[0]), float(daily.tip[1])))

func _bonfire_due() -> bool:
	if not BonfireView.activity_open(_now(), client.acts):
		return false
	for inst: Dictionary in client.bags.get(2, []):
		if int(inst.get("m_templateId", 0)) == 3205525 and int(inst.get("m_count", 0)) > 0:
			return true
	return false

func _bonfire_blit(name: String, at: Vector2, tint: Color) -> Rect2:
	if _bonfire_texture == null and ResourceLoader.exists(BonfireAtlas.FILE):
		_bonfire_texture = load(BonfireAtlas.FILE)
	var region: Array = BonfireAtlas.R[name]
	var rect: Rect2 = Rect2(at * _f, Vector2(region[2], region[3]) * _f)
	if _bonfire_texture != null:
		draw_texture_rect_region(_bonfire_texture, rect, Rect2(region[0], region[1], region[2], region[3]), tint)
	return rect

func _kc_blit(name: String, at: Vector2, tint: Color) -> Rect2:
	var region: Array = ChallengeAtlas.R[name]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	if _kc_tex != null:
		draw_texture_rect_region(_kc_tex, rect, Rect2(region[0], region[1], region[2], region[3]), tint)
	return rect


func _accum_current() -> int:
	for stage: int in range(ACCUM_FROM, ACCUM_TO + 1):
		if client.stages.has(stage):
			return stage
	return 0

func _accum_done() -> bool:
	for stage: int in range(ACCUM_FROM, ACCUM_TO + 1):
		if client.stages_cleared.has(stage):
			return true
	return false

func _accum_open() -> bool:
	var current: int = _accum_current()
	return current != 0 and int(client.stages[current].get("reward", 0)) == 1

func _first_done() -> bool:
	return client.stages_cleared.has(FIRST) and not client.stages.has(FIRST)


func _card_days() -> int:
	var times: int = int(client.character.get("cashback_times", 0))
	var picked: int = int(client.character.get("cashback_picked", 0))
	if times <= picked:
		return 0
	var today: int = ((_now() + VN) / DAY) * DAY - VN
	return maxi(0, (mini(today, times) - picked) / DAY)

func _now() -> int:
	return int(Time.get_unix_time_from_system())


func _balls() -> int:
	var ball: int = int(pack.fair.get("ball", BALL))
	if _balls_rev != client.bag_rev or _balls_id != ball:
		_balls_rev = client.bag_rev
		_balls_id = ball
		_balls_count = 0
		for cont: Variant in client.bags.keys():
			for inst: Variant in client.bags[cont]:
				if inst is Dictionary and int(inst.get("m_templateId", 0)) == ball:
					_balls_count += maxi(1, int(inst.get("m_count", 1)))
	return _balls_count


func _draw_balls() -> void :
	var count: int = _balls()
	if count <= 0:
		return
	var at: Vector2 = _origin("left") + BALL_TIP + Vector2(0, _rand_drop("event:wheel"))
	_dots.append("ball")
	_blit("public_tip", at)
	_words("!" if count > 9 else str(count), BOLD, 11.0, Color.WHITE, "c", at, 19.0, 0.0, 19.0)


func _draw_bar() -> void :
	LobbyBar.strip(self, bar_style, _f, floorf(_fw + 0.01), floorf(_fh + 0.01), Vector2.ZERO, - _safe_pad("br").y)



func _draw_chat(solid: bool) -> void :
	var base: Vector2 = _origin("chat")
	var fade: float = 1.0 if solid else 0.6
	for i in range(CHAT_TABS.size()):
		var key: String = str(CHAT_TABS[i][0])
		var id: String = "tab:" + key
		var at: Vector2 = base + Vector2(31 + 71 * i, 2)
		var lit: float = _lit(id)
		var rect: Rect2 = _blit("chat_chat_channel_select" if _chat_tab == key else "chat_chat_channel_item", at, 0.0, 0.0, Color(lit, lit, lit, fade))

		_words(str(CHAT_TABS[i][1]), BOLD, 12.0, Color(1, 1, 1, 0.45 if key == "camp" else 0.92), "c", at, 69.0, 1.0, 25.0)
		_hit(id, rect)
	var lines: Array = []
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		var where: String = str(line.get("tab", "all"))
		if _chat_tab == "all" or where.is_empty() or where == _chat_tab:
			lines.push_front(line)
			if lines.size() >= CHAT_LINES:
				break
	for i in range(lines.size()):
		var line: Dictionary = lines[i]
		var at: Vector2 = base + Vector2(33, 34 + 24 * i)
		var head: String = str(line.get("head", "")) + str(line.get("name", ""))
		var used: float = _words(head, SEMI, 14.0, line.get("name_color", Color.WHITE), "l", at, 390.0, 1.0, 24.0, false) if not head.is_empty() else 0.0
		if 390.0 - used > 20.0:
			_words(str(line.get("text", "")), REGULAR, 14.0, line.get("color", Color.WHITE), "l", at + Vector2(used + 3.0, 0), 387.0 - used, 1.0, 24.0, false)

	var track: Rect2 = Rect2((base + Vector2(428, 34)) * _f, Vector2(16, 120) * _f)
	draw_rect(track, Color("17558f", 0.9))
	for end: int in range(2):
		var cell: Rect2 = Rect2(track.position + Vector2(0, 104.0 * _f * end), Vector2(16, 16) * _f)
		draw_rect(cell, Color("1f9be8"))
		draw_rect(cell, Color("6cc8ff"), false, maxf(1.0, _f))
		var centre: Vector2 = cell.get_center()
		var way: float = 1.0 if end == 1 else -1.0
		draw_colored_polygon(PackedVector2Array([centre + Vector2(-3.5, -2.0 * way) * _f, centre + Vector2(3.5, -2.0 * way) * _f, centre + Vector2(0, 2.5 * way) * _f]), Color.WHITE)
	var row: Vector2 = _origin("input")
	_draw_input_row(row)
	chat_dock = Rect2((row + Vector2(6, -3)) * _f, Vector2(447, 43) * _f)



func _draw_input_row(row: Vector2) -> void :
	var state: int = 2 if _press == "chat" else (1 if _hover == "chat" and _press.is_empty() else 0)
	LobbyBar.input_row(self, bar_style, _f, Rect2(row + Vector2(6, 1), Vector2(447, 34)), "Thế Giới", 
		"Chạm để trò chuyện" if _mobile else "Nhấn Enter để trò chuyện", state, true)
	_hit("chat", Rect2((row + Vector2(6, -3)) * _f, Vector2(447, 43) * _f))



func _draw_social() -> void :
	_social.refresh(client)
	var base: Vector2 = _social_at()
	for part: Array in _social.parts(_press):
		var rect: Rect2 = part[2]
		_sprite(part[1], Rect2((base + rect.position) * _f, rect.size * _f), str(part[0]))
	for hit: Array in _social.hits():
		var rect: Rect2 = hit[1]
		_hit(str(hit[0]), Rect2((base + rect.position) * _f, rect.size * _f))
	if not _social.open:
		return
	var dot: Array = Atlas.R["public_tip"]
	for tip: Array in _social.tips(client):
		var box: Rect2 = tip[0]
		var at: Vector2 = base + box.position
		_blit("public_tip", at + (box.size - Vector2(float(dot[2]), float(dot[3]))) / 2.0)
		if not str(tip[1]).is_empty():
			_words(str(tip[1]), BOLD, 11.0, Color.WHITE, "c", at, box.size.x, 0.0, box.size.y)



func _social_at() -> Vector2:
	return _social_base if _social_base.x >= 0.0 else _origin("menu")






const MENU_GAP: float = 10.0
func _draw_menu_bar() -> void :
	var area: Rect2 = menu_area()
	_social.refresh(client)
	_social_base = Vector2(-1, -1)
	var off: Array = [] if LobbyBar.talent_block(client).is_empty() else ["nav:talent"]
	for hit: Array in LobbyBar.menu(self, bar_style, _f, area, _hover, _press, _menu_badges(), [], Vector2.ZERO, off, LobbyBar.hidden_ids(client)):
		var id: String = str(hit[0])
		var rect: Rect2 = hit[1]
		_hit(id, rect)
		if FLEX_TIPS.has(id):
			_flex_tips[id] = rect
		if id == "social":
			_social_base = Vector2(rect.get_center().x / _f - (SocialMenu.AT.x + SocialMenu.SIDE / 2.0), _origin("menu").y)


func menu_area() -> Rect2:
	var wide: float = floorf(_fw + 0.01)
	var high: float = floorf(_fh + 0.01)
	var pad: Vector2 = _safe_pad("br")
	var x0: float = maxf(471.0, _origin("input").x + 453.0 + MENU_GAP)
	return Rect2(x0, high - LobbyBar.STRIP + pad.y, maxf(1.0, wide + pad.x - 8.0 - x0), LobbyBar.STRIP)


func _menu_badges() -> Dictionary:
	var out: Dictionary = {}
	if _menu_tips.has("tank"):
		out["nav:tank"] = ""
	if _menu_tips.has("package"):
		out["nav:bag"] = ""
	if _menu_tips.has("helper"):
		out["nav:support"] = str(_menu_tips["helper"])
	if _menu_tips.has("quest"):
		out["col:quest"] = str(_menu_tips["quest"])
	if not _social.open and not _social.tips(client).is_empty():
		out["social"] = ""
	return out




func _menu_state() -> Dictionary:
	var tips: Dictionary = {}
	if client.bag_loaded:
		if MenuTips.tank_up(client.tanks, pack.garage, client.bags):
			tips["tank"] = true
		if MenuTips.temp_items(client.bags):
			tips["package"] = true
		if not client.battle_helper.is_empty():
			pack.load_helper()
			if MenuTips.helper_up(client.bags, pack.helper, client.battle_helper):
				tips["helper"] = ""
		if not client.bag_opened:
			var over: int = MenuTips.expiring(client.bags, pack.bag.get("items", {}), _now())
			if over < 0:
				pack.load_bag()
			elif over > 0:
				tips["overtime"] = true
	var done: int = MenuTips.quest_count(client.quests, pack.quest.get("quests", {}))
	if done > 0:
		tips["quest"] = MenuTips.quest_label(done)
	return tips



func _draw_overtime() -> void :
	if not _menu_tips.has("overtime"):
		return
	if _menu_tex == null and ResourceLoader.exists(MenuTipsAtlas.FILE):
		_menu_tex = load(MenuTipsAtlas.FILE)
	if _menu_tex == null:
		return
	var base: Vector2 = _origin("menu")
	for hit: Array in _hits:
		if str(hit[0]) == "nav:bag":
			base.x = (hit[1] as Rect2).get_center().x / _f - 554.0
	var box: Vector2 = base + Vector2(float(MenuTipsAtlas.AT[0]), float(MenuTipsAtlas.AT[1]))
	for row: Array in MenuTipsAtlas.ORDER:
		var region: Array = MenuTipsAtlas.R[str(row[0])]
		var spot: Vector2 = box + Vector2(float(row[1][0]), float(row[1][1]))
		draw_texture_rect_region(_menu_tex, Rect2(spot * _f, Vector2(float(region[2]), float(region[3])) * _f), 
			Rect2(region[0], region[1], region[2], region[3]))

func _draw_toast() -> void :
	var age: float = _time - _toast_at
	if _toast.is_empty() or age > 2.6:
		return
	var alpha: float = clampf(minf(age / 0.15, (2.6 - age) / 0.4), 0.0, 1.0)
	var font_size: int = maxi(6, roundi(32 * _u))
	var width: float = SEMI.get_string_size(_toast, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 96.0 * _u
	var rect: Rect2 = Rect2(Vector2((size.x - width) / 2.0, size.y * 0.3), Vector2(width, 88.0 * _u))
	_round(rect, Color("06203f", 0.92 * alpha), 22.0, Color("6fd0ff", 0.6 * alpha), 2.0)
	_string(_toast, SEMI, 32, Color(Color.WHITE, alpha), "c", rect.get_center(), rect.size.x)



func say(text: String) -> void :
	if covered:
		return
	_toast = text
	_toast_at = _time

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		if _mobile and _lp_tip:
			_hover = _hit_at(event.position)
			_mouse = event.position
			accept_event()
			return
		if _mobile and event.position.distance_to(_lp_at) > 10.0:
			_lp_start = -1.0

		_hover = "" if _mobile else _hit_at(event.position)
		_mouse = Vector2(-1, -1) if _mobile else event.position
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if _mobile:
			_lp_down = event.pressed
			_lp_start = _time if event.pressed else -1.0
			_lp_at = event.position
			if not event.pressed and _lp_tip:
				_lp_tip = false
				_hover = ""
				_mouse = Vector2(-1, -1)
		if event.pressed:
			_press = _hit_at(event.position)
			if _daily_open and _press != "event:daily" and not _press.begins_with("daily:"):
				_daily_open = false
		else:
			var id: String = _hit_at(event.position)
			var pressed: String = _press
			_press = ""
			if id == "daily:bg":
				pass
			elif not id.is_empty() and id == pressed:
				Sound.click()
				_activate(id)
		accept_event()

func _activate(id: String) -> void :

	match id:
		"event:daily":
			_daily_open = not _daily_open
			return
		"daily:bonfire":
			_daily_open = false
			bonfire_asked.emit()
			return
		"daily:pk":
			_daily_open = false
			challenge_asked.emit()
			return
		"daily:sign":
			_daily_open = false
			page_asked.emit("events:sign")
			return
	_daily_open = false
	if _social.activate(id):
		return
	if id.begins_with("tab:"):
		_chat_tab = id.substr(4)
		return
	if ISLE_PAGES.has(id):
		page_asked.emit(str(ISLE_PAGES[id]))
		return
	if PAGES.has(id):
		page_asked.emit(str(PAGES[id]))
		return
	match id:
		"nav:talent":
			var why: String = LobbyBar.talent_block(client)
			if why.is_empty():
				talent_asked.emit(LobbyBar.talent_tank(client))
			else:
				say(why)
		"chat":
			chat_asked.emit()
		"mode:pvp":
			play.emit()
		"back":
			say("Bạn đang ở sảnh chính.")
		"stamina":
			stamina_asked.emit()
		"col:book":
			training_asked.emit()
		"event:mysterious":
			if MysteriousStore.is_open(client):
				mysterious_asked.emit()
		"event:store":
			mystical_asked.emit()
		"social:master":
			master_asked.emit()
		"social:mail":
			page_asked.emit("mail")
		"social:rep":
			reputation_asked.emit()
		"social:history":
			history_asked.emit()
		"event:newbie":
			newbie_asked.emit()
		"event:expedition":
			if expedition_shown():
				expedition_asked.emit()
		"event:luck":
			if luck_open():
				luck_asked.emit()
		"event:return", "col:return":
			_return_reap()
		"present:tank":
			_present.activate(self)
		"buy:exp":
			quick_buy_asked.emit(2300003)
		"money:gift":
			page_asked.emit("events:card")
		"money:gold":
			quick_buy_asked.emit(2320004)
		"col:rand":
			rand_quest_asked.emit()
		"avatar":
			if client != null:
				player_info_asked.emit(client.char_uuid if not client.char_uuid.is_empty() else str(client.account_id))
		_:
			say("%s đang được chuyển sang HTML5." % str(NAMES.get(id, "Mục này")))






func _ask_mysterious_templates() -> void :
	if _mysterious_templates_asked or _mysterious_http != null or client == null or not (OS.has_feature("web") or OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("pc_app") or ( not OS.has_feature("editor") and DisplayServer.get_name() != "headless")):
		return
	_mysterious_templates_asked = true
	_mysterious_http = HTTPRequest.new()
	_mysterious_http.timeout = 10
	_mysterious_http.accept_gzip = false
	add_child(_mysterious_http)
	_mysterious_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		_mysterious_templates_asked = result == HTTPRequest.RESULT_SUCCESS and code == 200 and read_mysterious_templates(body)
		_mysterious_http.queue_free()
		_mysterious_http = null)
	var url: String = client.config.origin + MYSTERIOUS_ACTS_PATH
	if _mysterious_http.request(url, AppSession.headers(url)) != OK:
		_mysterious_http.queue_free()
		_mysterious_http = null
		_mysterious_templates_asked = false



func read_mysterious_templates(body: PackedByteArray) -> bool:
	if client == null:
		return false
	var parser: XMLParser = XMLParser.new()
	if parser.open_buffer(body) != OK:
		return false
	var types: Dictionary = {}
	var wanted: Array = []
	var row: Dictionary = {}
	var field: String = ""
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node: String = parser.get_node_name()
				if node == "entry":
					row = {}
					field = ""
				elif not parser.is_empty():
					field = node
			XMLParser.NODE_TEXT, XMLParser.NODE_CDATA:
				if not field.is_empty():
					row[field] = str(row.get(field, "")) + parser.get_node_data()
			XMLParser.NODE_ELEMENT_END:
				var node: String = parser.get_node_name()
				if node == "entry":
					var id: int = int(str(row.get("nId", "0")))
					var type: int = int(str(row.get("nType", "0")))
					if id > 0:
						types[id] = type
						_act_levels[id] = int(str(row.get("nLevel", "0")))
						if type == 107:
							wanted.append({"id": id, "level": int(str(row.get("nLevel", "0"))), 
								"start": _mysterious_start(str(row.get("szStartTime", ""))), "duration": int(str(row.get("nDuration", "0")))})
					row = {}
					field = ""
				elif node == field:
					field = ""
	if types.is_empty():
		return false
	for id: int in types:
		client.act_types[id] = int(types[id])
	client.mysterious_acts = wanted
	queue_redraw()
	return true


static func _mysterious_start(text: String) -> int:
	var pieces: PackedStringArray = text.strip_edges().split(",", false)
	if pieces.size() != 3 or pieces[0].strip_edges() != "once":
		return 0
	var stamp: String = pieces[1].strip_edges() + "T" + pieces[2].strip_edges()
	if RegEx.create_from_string("^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}$").search(stamp) == null:
		return 0
	return int(Time.get_unix_time_from_datetime_string(stamp)) - VN



func _draw_mystical_act(hidden: Array) -> void :
	if hidden.has("event:store"):
		return
	if _mysterious_tex == null and ResourceLoader.exists(MysteriousAtlas.FILE):
		_mysterious_tex = load(MysteriousAtlas.FILE)
	var at: Vector2 = _origin("acts") + Vector2(MYSTICAL_ACT_X + _act_shift("event:store", hidden), 0.0)
	var lit: float = _lit("event:store")
	var tint: Color = Color(lit, lit, lit, 1.0)
	_mysterious_blit("cm_mystical_icon", at, tint)
	var word: Array = MysteriousAtlas.MYSTICAL_ACT.word
	_mysterious_blit("cm_mystical_word", at + Vector2(float(word[0]), float(word[1])), tint)
	_blit("public_tip", at + ACT_TIP)
	_dots.append("event:store")
	_hit("event:store", Rect2(at * _f, Vector2(50, 50) * _f))

func _mysterious_blit(name: String, at: Vector2, tint: Color) -> void :
	var region: Array = MysteriousAtlas.R[name]
	if _mysterious_tex != null:
		draw_texture_rect_region(_mysterious_tex, Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f), 
			Rect2(region[0], region[1], region[2], region[3]), tint)




var _rand_on: bool = false
var _rand_hidden: bool = true
var _rand_tex: Texture2D
var _rand_since: float = -1.0


func _rand_drop(id: String) -> float:
	return 56.0 if _rand_on and id in ["col:live", "event:wheel"] else 0.0


func _draw_rand_left() -> void :
	if not _rand_on:
		_rand_since = -1.0
		return
	var at: Vector2 = _origin("left") + Vector2(0, 112)
	var lit: float = _lit("col:rand")
	var cell: String = "rq_icon"
	var bob: float = 0.0
	var glow: float = 0.0
	if RandRules.has_award(client.quests):
		if _rand_since < 0.0:
			_rand_since = _time
		var step: int = RandRules.frame(_time - _rand_since)
		cell = "rq_icon_has"
		bob = float(RandAtlas.BOB[step])
		glow = float(RandAtlas.GLOW[step])
	else:
		_rand_since = -1.0
	var rect: Rect2 = Rect2((at + Vector2(0, bob)) * _f, Vector2(RandAtlas.SIDE, RandAtlas.SIDE) * _f)
	if _rand_tex == null and ResourceLoader.exists(RandAtlas.FILE):
		_rand_tex = load(RandAtlas.FILE)
	var tex: Texture2D = _rand_tex
	if tex != null:
		var region: Array = RandAtlas.R[cell]
		draw_texture_rect_region(tex, rect, Rect2(region[0], region[1], region[2], region[3]), Color(lit, lit, lit, 1.0))
		if glow > 0.0:
			var white: Array = RandAtlas.R["rq_icon_has_white"]
			draw_texture_rect_region(tex, rect, Rect2(white[0], white[1], white[2], white[3]), Color(1, 1, 1, glow))
	_words("NV Ngày", BOLD, 11.0, Color.WHITE, "c", at + Vector2(-5, 34), 60.0, 1.5, 0.0)
	_hit("col:rand", Rect2(at * _f, Vector2(RandAtlas.SIDE, RandAtlas.SIDE) * _f))






const BAR_GLOW_EXP: Color = Color("6c0d2c")
const BAR_GLOW_THEW: Color = Color("004117")
const BAR_RIM: Array = [[Vector2(-1, 0), 0.5], [Vector2(1, 0), 0.5], [Vector2(0, -1), 0.5], [Vector2(0, 1), 0.5], 
	[Vector2(-1, -1), 0.25], [Vector2(1, -1), 0.25], [Vector2(-1, 1), 0.25], [Vector2(1, 1), 0.25]]
const BAR_WEIGHT: int = 600
var _bar_face: FontVariation = null


func _bar_font() -> FontVariation:
	if _bar_face == null:
		_bar_face = REGULAR.duplicate() as FontVariation
		var axes: Dictionary = _bar_face.variation_opentype.duplicate()
		axes[2003265652] = BAR_WEIGHT
		_bar_face.variation_opentype = axes
	return _bar_face


func _bar_size(text: String, wide: float = 120.0) -> int:
	var font: Font = _bar_font()
	var shown: float = 10.0
	while shown > 8.0 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(shown * _f))).x > wide * _f:
		shown -= 1.0
	return maxi(6, roundi(shown * _f))


func _bar_words(text: String, at: Vector2, glow: Color) -> void :
	var font: Font = _bar_font()
	var font_size: int = _bar_size(text)
	var origin: Vector2 = Vector2(at.x, at.y + 2.0 + 10.0 * 0.55) * _f
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	var wide: float = 120.0 * _f
	for rim: Array in BAR_RIM:
		var step: Vector2 = rim[0]
		draw_string(font, origin + step * _f, text, HORIZONTAL_ALIGNMENT_CENTER, wide, font_size, Color(glow, float(rim[1])))
	draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide, font_size, Color.WHITE)







const ISLAND_HALL: bool = true
const IsleAtlas = preload("island_atlas.gd")
const IslandNoel = preload("island_noel.gd")
const IslandAlpha = preload("island_alpha.gd")
const IslandCuoi = preload("island_cuoi.gd")
const ISLE_PAGES: Dictionary = {"isle:center": "fair:center", "isle:shop": "shop"}
const ISLE_GOLD: Color = Color("ffe04a")
const ISLE_EDGE: Color = Color("3a1c00")
const ISLE_FONT: float = 13.0
const ISLE_ASC: float = 12.0
const ISLE_LINE: float = 14.0
const ISLE_BOB: Array = [2.5, 1.7]
var _isle_s: float = 1.0
var _isle_o: Vector2 = Vector2.ZERO
var _isle_y: Array = []
var _isle_tags: Array = []
var _noel: RefCounted = _isle_theme()
var _isle_mode: String = "d"
var _isle_season: bool = false


static func _isle_theme() -> RefCounted:
	var kind: String = LobbyThemes.kind(LobbyThemes.current())
	if kind == "noel":
		return IslandNoel.new()
	if kind == "cuoi":
		return IslandCuoi.new()
	return IslandAlpha.new()


func _isle_pick() -> void :
	var kind: String = LobbyThemes.kind(LobbyThemes.current())
	if (kind == "noel") == (_noel is IslandNoel) and (kind == "cuoi") == (_noel is IslandCuoi):
		return
	_noel = _isle_theme()
	_isle_warm = false
	_isle_due.clear()
	_isle_fail.clear()


func _isle_ready() -> bool:
	if not ISLAND_HALL or pack == null:
		return false
	if Love.want_theme(client):
		return false
	_isle_pick()
	if not pack.picture_ready.is_connected(_isle_landed):
		pack.picture_ready.connect(_isle_landed)
	_noel.refresh()
	var full: bool = true
	for file: String in _noel.files():
		if pack.picture(IsleAtlas.DIR + file) == null:
			full = false
	if full:
		_isle_mode = _noel.want()
		return true

	var want: String = _noel.want()
	for m: String in [want, "n" if want == "d" else "d"]:
		if _isle_has(_noel.need(m)):
			_isle_mode = m
			return true
	return false


func _isle_has(list: Array) -> bool:
	for file: String in list:
		if pack._pictures.get(IsleAtlas.DIR + file) == null:
			return false
	return true


func _isle_need() -> Array:
	return _noel.need(_noel.want())


func _isle_pic(name: String, m: String = "") -> Texture2D:
	return pack.picture(IsleAtlas.DIR + _noel.file(name, _isle_mode if m.is_empty() else m))






const ISLE_RETRY: Array = [1.0, 2.0, 4.0, 8.0, 15.0]
const ISLE_COVER: Array = [Color("0e3b5c"), Color("135a80"), Color("0a2a40")]
var _isle_warm: bool = false
var _isle_fail: Dictionary = {}
var _isle_due: Dictionary = {}
var _isle_asked: Dictionary = {}
const ISLE_STUCK_MS: int = 180000
var _isle_wait: float = 1.0
const ISLE_DROP_MS: int = 3000
var _isle_held: int = -1
var _isle_shown: String = ""

func _isle_keep() -> void :
	if not ISLAND_HALL or pack == null or pack.base.is_empty():
		return
	var now: int = Time.get_ticks_msec()
	if pack.ios_shrink and client != null and client.state == "battle":
		if _isle_held < 0 or now - _isle_held >= ISLE_DROP_MS:
			pack.ios_drop_lobby(AssetPack.IOS_DROP if _isle_held < 0 else ["l/island/"])
			_isle_held = now
		return
	if _isle_held >= 0:
		_isle_held = -1
		_isle_warm = false
		_isle_due.clear()
		_isle_fail.clear()
	_isle_pick()
	_noel.refresh()
	if _isle_warm and _isle_season != _noel.season:
		_isle_warm = false
	var files: Array = _noel.files()
	if not _isle_warm:
		_isle_warm = true
		_isle_season = _noel.season
		_isle_ready()
		for file: String in files:
			_isle_asked[file] = now
	for file: String in files:
		if not _isle_due.has(file) and now - int(_isle_asked.get(file, now)) > ISLE_STUCK_MS and pack._pictures.get(IsleAtlas.DIR + file) == null:
			_isle_due[file] = now
	if _isle_due.is_empty():
		return
	for file: String in _isle_due.keys():
		if now < int(_isle_due[file]):
			continue
		_isle_due.erase(file)
		_isle_asked[file] = now
		var path: String = IsleAtlas.DIR + file
		if pack._pictures.has(path) and pack._pictures[path] == null:
			pack._pictures.erase(path)
		pack.picture(path)


func _isle_landed(path: String) -> void :
	if not path.begins_with(IsleAtlas.DIR) or not _noel.files().has(path.substr(IsleAtlas.DIR.length())):
		return
	var file: String = path.substr(IsleAtlas.DIR.length())
	if pack._pictures.get(path) != null:
		_isle_fail.erase(file)
		_isle_due.erase(file)
		return
	var tries: int = int(_isle_fail.get(file, 0)) + 1
	_isle_fail[file] = tries
	_isle_due[file] = Time.get_ticks_msec() + int(1000.0 * _isle_wait * float(ISLE_RETRY[mini(tries, ISLE_RETRY.size()) - 1]))


func _isle_count() -> int:
	var done: int = 0
	if pack != null:
		for file: String in _isle_need():
			if pack._pictures.get(IsleAtlas.DIR + file) != null:
				done += 1
	return done



func _draw_isle_cover() -> void :
	var wide: float = size.x
	var mid: float = size.y * 0.5
	draw_polygon(PackedVector2Array([Vector2.ZERO, Vector2(wide, 0), Vector2(wide, mid), Vector2(0, mid)]), 
		PackedColorArray([ISLE_COVER[0], ISLE_COVER[0], ISLE_COVER[1], ISLE_COVER[1]]))
	draw_polygon(PackedVector2Array([Vector2(0, mid), Vector2(wide, mid), Vector2(wide, size.y), Vector2(0, size.y)]), 
		PackedColorArray([ISLE_COVER[1], ISLE_COVER[1], ISLE_COVER[2], ISLE_COVER[2]]))
	var frac: float = float(_isle_count()) / float(_isle_need().size())
	var bar: Vector2 = Vector2(260, 8) * _f
	var at: Vector2 = Vector2(roundf((wide - bar.x) / 2.0), roundf(size.y * 0.52))
	draw_rect(Rect2(at - Vector2(1, 1) * _f, bar + Vector2(2, 2) * _f), ISLE_EDGE)
	draw_rect(Rect2(at, bar), Color(1, 1, 1, 0.15))
	if frac > 0.0:
		draw_rect(Rect2(at, Vector2(bar.x * frac, bar.y)), ISLE_GOLD)
	var font_size: int = maxi(8, roundi(16.0 * _f))
	var text: String = "Đang tải sảnh đảo… %d%%" % roundi(frac * 100.0)
	if not _isle_fail.is_empty():
		text += "  (mạng chậm, đang thử lại)"
	var line: float = BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var base: Vector2 = Vector2(roundf((wide - line) / 2.0), at.y - roundf(10.0 * _f))
	draw_string_outline(BOLD, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(3.0 * _f)), ISLE_EDGE)
	draw_string(BOLD, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)
	_draw_isle_tank()


func _tip_ok() -> bool:
	return not _mobile or _lp_tip


func _isle_hot(id: String) -> bool:
	return (_press == id) if _mobile else (_hover == id)


func _isle_rect(at: Vector2, dim: Vector2) -> Rect2:
	return Rect2((_isle_o + at * _isle_s) * _f, dim * _isle_s * _f)

func _draw_island() -> void :
	_noel.show(_isle_mode, _time)
	draw_rect(Rect2(Vector2.ZERO, size), NAVY)
	var wide: float = floorf(_fw + 0.01)
	var high: float = floorf(_fh + 0.01)

	var k: float = maxf(wide / IsleAtlas.SEA.x, high / IsleAtlas.SEA.y)
	var sea: Vector2 = IsleAtlas.SEA * k
	var sea_rect: Rect2 = Rect2(Vector2(roundf((wide - sea.x) / 2.0), roundf((high - sea.y) / 2.0)) * _f, sea * _f)
	draw_texture_rect(_isle_pic("sea"), sea_rect, false)
	_isle_s = maxf(0.75, minf(1.75, minf(wide / 1365.0, high / 640.0)))
	_isle_o = Vector2(roundf(wide * 0.503 - 500.0 * _isle_s), roundf(high * 0.49 - 300.0 * _isle_s))
	draw_texture_rect(_isle_pic("bk"), _isle_rect(Vector2.ZERO, IsleAtlas.WORLD), false)
	_isle_y.clear()
	_isle_tags.clear()
	var pad: Vector2 = Vector2(IsleAtlas.PAD, IsleAtlas.PAD)
	for part: Array in IsleAtlas.PARTS:
		var name: String = str(part[0])
		var id: String = str(part[1])
		var y: float = float(part[3]) + (float(ISLE_BOB[0]) * sin(_time * float(ISLE_BOB[1])) if name == "league" else 0.0)
		var at: Vector2 = Vector2(float(part[2]), y)
		var dim: Vector2 = Vector2(float(part[4]), float(part[5]))
		var hot: bool = _isle_hot(id)
		if bool(part[9]):
			if hot:
				draw_texture_rect(_isle_pic(name), _isle_rect(at, dim), false)
		elif hot:
			draw_texture_rect(_isle_pic(name + "_hot"), _isle_rect(at - pad, dim + 2.0 * pad), false)
		else:
			draw_texture_rect(_isle_pic(name), _isle_rect(at, dim), false)
		var tag: Rect2 = _isle_tag(part, hot)
		_isle_y.append(y)
		_isle_tags.append(tag)
		var box: Rect2 = Rect2(at, dim).merge(tag) if tag.has_area() else Rect2(at, dim)
		_hits.append([id, _isle_rect(box.position, box.size), _isle_tags.size() - 1])
	_draw_isle_fade(sea_rect)
	_noel.draw_ground(self, _time)

	var font_size: int = maxi(6, roundi(ISLE_FONT * _isle_s * _f))
	var edge: int = maxi(1, roundi(3.0 * _f))
	for i in range(IsleAtlas.PARTS.size()):
		var tag: Rect2 = _isle_tags[i]
		if not tag.has_area():
			continue
		var part: Array = IsleAtlas.PARTS[i]
		var color: Color = Color.WHITE if _isle_hot(str(part[1])) else ISLE_GOLD
		var lines: PackedStringArray = str(part[6]).split("\n")
		for j in range(lines.size()):
			var line: String = lines[j]
			var wide_line: float = BOLD.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			var base: Vector2 = (_isle_o + Vector2(float(part[7]), float(part[8]) + ISLE_ASC + ISLE_LINE * j) * _isle_s) * _f - Vector2(wide_line / 2.0, 0)
			draw_string_outline(BOLD, base, line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, edge, ISLE_EDGE)
			draw_string(BOLD, base, line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	_noel.draw_sky(self, _time)
	_draw_isle_tank()


func _draw_isle_fade(sea_rect: Rect2) -> void :
	var a: float = _noel.fade(_time)
	var old: String = _noel.fade_mode()
	if a <= 0.0 or old.is_empty() or not _isle_has(_noel.need(old)):
		return
	var tint: Color = Color(1, 1, 1, a)
	draw_texture_rect(_isle_pic("sea", old), sea_rect, false, tint)
	draw_texture_rect(_isle_pic("bk", old), _isle_rect(Vector2.ZERO, IsleAtlas.WORLD), false, tint)
	for i in range(IsleAtlas.PARTS.size()):
		var part: Array = IsleAtlas.PARTS[i]
		if bool(part[9]) or i >= _isle_y.size():
			continue
		draw_texture_rect(_isle_pic(str(part[0]), old), _isle_rect(Vector2(float(part[2]), float(_isle_y[i])), Vector2(float(part[4]), float(part[5]))), false, tint)





const ISLE_TANK_CELL: Vector2 = Vector2(251, 0)
const ISLE_TANK_AT: Vector2 = Vector2(284, 32)
const ISLE_TANK_ZOOM: float = 0.3
const ISLE_TANK_LV: Vector2 = Vector2(291, 45)
const ISLE_TANK_LV_ZOOM: float = 0.75

func _draw_isle_tank() -> void :
	if _hud == null or not Atlas.R.has("char_bg"):
		return
	var base: Vector2 = _origin("char")
	var bg: Array = Atlas.R["char_bg"]
	var left: Vector2 = (base + ISLE_TANK_CELL) * _f
	var high: float = float(bg[3])
	draw_texture_rect_region(_hud, Rect2(left, Vector2(64, high) * _f), Rect2(float(bg[0]), float(bg[1]), 64, high))
	draw_texture_rect_region(_hud, Rect2(left + Vector2(64, 0) * _f, Vector2(3, high) * _f), Rect2(float(bg[0]) + float(bg[2]) - 3.0, float(bg[1]), 3, high))
	var cell: Rect2 = Rect2(left, Vector2(67, high) * _f)
	_hit("plate", cell)
	var tank: Dictionary = client.current_tank()
	if tank.is_empty() or pack.state != "ready":
		return
	var level: int = maxi(1, int(tank.get("m_level", 1)))
	pack.load_garage()
	if not pack.garage.is_empty() or _time >= 4.0:
		var inner: Rect2 = Rect2(left + Vector2(3, 3) * _f, Vector2(60, 60) * _f)
		var centre: Vector2 = (base + ISLE_TANK_AT) * _f
		var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(tank.get("m_tpltId", 0)), level, tank)
		var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(tank.get("m_haloId", 0)), level)
		if not TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, centre, ISLE_TANK_ZOOM * _f, _time, "l/t", true, inner):
			var art: Dictionary = pack.external_art(pack.art_external(str(int(tank.get("m_externalId", 0))), int(tank.get("m_tpltId", 0))))
			if TankPreview.ready(art):
				TankPreview.draw(self, art, centre + Vector2(0, 7) * _f, ISLE_TANK_ZOOM * _f, 4, _time)
	var lv: String = "tklv_%d" % clampi(level, 1, 11)
	if Atlas.R.has(lv):
		var region: Array = Atlas.R[lv]
		var dim: Vector2 = Vector2(float(region[2]), float(region[3])) * ISLE_TANK_LV_ZOOM
		_blit(lv, base + Vector2(ISLE_TANK_LV.x - dim.x / 2.0, ISLE_TANK_LV.y), dim.x, dim.y)



func _isle_tag(part: Array, _hot: bool) -> Rect2:
	var lines: PackedStringArray = str(part[6]).split("\n")
	var font_size: int = maxi(6, roundi(ISLE_FONT * _isle_s * _f))
	var widest: float = 0.0
	for line: String in lines:
		widest = maxf(widest, BOLD.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / maxf(0.01, _isle_s * _f))
	var wide: float = ceilf(widest) + 4.0
	return Rect2(roundf(float(part[7]) - wide / 2.0), float(part[8]) - 2.0, wide, 15.0 + ISLE_LINE * (lines.size() - 1) + 4.0)


func _isle_hit(index: int, point: Vector2) -> bool:
	if index < 0 or index >= IsleAtlas.PARTS.size() or index >= _isle_y.size() or _isle_s <= 0.0 or _f <= 0.0:
		return false
	var part: Array = IsleAtlas.PARTS[index]
	var local: Vector2 = (point / _f - _isle_o) / _isle_s
	var tag: Rect2 = _isle_tags[index]
	if tag.has_area() and tag.has_point(local):
		return true
	var x: int = floori(local.x - float(part[2]))
	var y: int = floori(local.y - float(_isle_y[index]))
	if x < 0 or y < 0 or x >= int(part[4]) or y >= int(part[5]):
		return false
	var runs: Array = IsleAtlas.MASK[str(part[0])][y]
	for j in range(0, runs.size() - 1, 2):
		if x >= int(runs[j]) and x < int(runs[j + 1]):
			return true
	return false
