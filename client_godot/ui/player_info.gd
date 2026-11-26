extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")






































const Atlas = preload("player_info_atlas.gd")
const LB = preload("leaderboard_atlas.gd")
const Hall = preload("hall_atlas.gd")
const HallScreen = preload("hall_screen.gd")
const TankPortrait = preload("tank_portrait.gd")
const GarageModel = preload("garage_model.gd")
const Proficiency = preload("proficiency.gd")
const PROF_AT: Rect2 = Rect2(480, 449.5, 30, 30)
const HelperModel = preload("helper_model.gd")
const BagModel = preload("bag_model.gd")
const HelperTip = preload("helper_tip.gd")
const SkinAtlas = preload("player_info_skin_atlas.gd")
const GarSkin = preload("gar_skin_atlas.gd")
const SelfAtlas = preload("bag_self_atlas.gd")
const HelperAtlas = preload("helper_atlas.gd")



const HELPER_BOX: String = "sg"
const HELPER_CELLS: Array = ["hp_bx_s", "hp_gl_s", "hp_star", "hp_bar_s"]
const Love = preload("love.gd")
const NameStyles = preload("name_styles.gd")
const CorpsWatch = preload("corps_watch.gd")

signal closed
signal tank_buy_asked(tid: int)
signal whisper(name: String)

const SIZE: Vector2 = Vector2(828, 568)
const SHOW_IN: Array = ["lobby", "hall", "room"]
const PATH: String = "/observechar.php?charoid=%s&noCache=%s"

const TECH: Dictionary = {"all": "total", "pvp": "pvp", "ladder": "ladderpvp", "clan": "league"}

const STATS: Array = [["lblWinMatch", "winmatchs"], ["lblEscape", "escapeprecent"], ["lblKillerKing", "killerkingmatchs"], 
	["txtAssist", "assistkingmatchs"], ["txtKda", "kda_count"], ["lblDestory", "destroyer_count"]]
const LIST: Vector2 = Vector2(241, 282)
const ROW: Vector2 = Vector2(220, 76)
const ROWS: int = 3
const LIST_H: float = 228.0
const HONOR: Vector2 = Vector2(250, 183)
const HONOR_AREA: Rect2 = Rect2(244, 183, 550, 70)
const HONOR_PITCH: float = 60.0
const HONOR_SHOWN: int = 9
const HONOR_BAR: Vector2 = Vector2(250, 234)
const HONOR_BAR_W: float = 540.0
const ORNATE_CENTRE: Vector2 = Vector2(-289, -85)
const BIG_TANK: Vector2 = Vector2(583, 375)
const VALUE_INK: Color = Color.WHITE
const NUM_INK: Color = Color("ffea00")
const NAME_INK: Color = Color("00ffff")
const NAME_RIM: Color = Color(0, 83 / 255.0, 145 / 255.0, 0.8)
const NAME_W: float = 78.0
const TIP_INK: Color = Color("016597")
const EMPTY_RIM: Color = Color(0, 87 / 255.0, 151 / 255.0, 0.8)
const GradLabel = preload("grad_label.gd")
const NONE: String = "Không"
const NO_SECTION: String = "Không Huy Chương"
const LEVEL: String = "LV."
const TANK_NUM: String = "Hiện có %d Tank"
const ROW_SCORE: String = "Chiến tích: %s"
const ROW_WIN: String = "Thắng: %s"
const WORN: String = "(Đang đeo)"
const NO_HONOR: String = "Hiện không có huân chương! Hãy cố gắng thêm nhé!"
const REFRESH: String = "Nhắc: 5 phút/lần làm mới thông tin cá nhân"
const SCORE_HELP: String = "Điểm bình quân giữa tỉ lệ thắng, trận thắng, lượt nhận đánh giá (Kẻ Tàn Sát/Vua Toàn Năng//Vua Phá Hoại/Vua Trợ Công) và lượt bỏ chạy."
const SOON: String = "%s đang được chuyển sang HTML5."
const NOT_FOUND: String = "Không tìm thấy thông tin người chơi."
const FAILED: String = "Không tải được hồ sơ người chơi, thử lại sau."

var _model: Dictionary = {}
var _want: String = ""
var _tab: String = "all"
var _pick: int = 0
var _row: int = 0
var _honor_row: int = 0
var _helper: Dictionary = {}
var _htip: Dictionary = {}
var _tip: Array = []
var _thumb: Rect2 = Rect2()
var _hbar: Rect2 = Rect2()
var _drag_from: Vector2 = Vector2(-1, -1)
var _drag_mode: String = ""
var _drag_sum: float = 0.0
var _http: HTTPRequest
var _observe_get: Callable
var _watch: Control = null

func chat_busy() -> bool:
	return watch_open()

func watch_open() -> bool:
	return _watch != null and _watch.visible

func _open_watch() -> Control:
	if _watch == null:
		_watch = CorpsWatch.new()
		_watch.visible = false
		_watch.client = client
		_watch.pack = pack
		_watch.hall = hall
		add_child(_watch)
		_watch.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_watch.whisper.connect( func(who: String) -> void : whisper.emit(who))
	return _watch

func _setup() -> void :
	visible = false
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_reply)
	_observe_get = func(url: String) -> int: return _http.request(url, AppSession.headers(url))
	if client != null:
		client.changed.connect(_follow)


func _follow() -> void :
	if visible and (client == null or client.state not in SHOW_IN):
		close()
	elif visible:
		queue_redraw()

func _shown() -> void :
	if pack == null:
		return
	if not pack.picture_ready.is_connected(_on_picture_ready):
		pack.picture_ready.connect(_on_picture_ready)
	pack.load_board()
	pack.load_bag()
	pack.load_bagx()
	pack.load_garage()
	pack.load_helper()

func _on_picture_ready(_path: String) -> void :
	if visible:
		queue_redraw()




static func tail(uuid: String) -> String:
	var at: int = uuid.length()
	while at > 0 and uuid.unicode_at(at - 1) >= 48 and uuid.unicode_at(at - 1) <= 57:
		at -= 1
	return uuid.substr(at)


static func valid_uuid(uuid: String) -> bool:
	var digits: String = tail(uuid.strip_edges())
	return not digits.is_empty() and digits.lstrip("0") != ""


func open(uuid: String) -> void :
	uuid = uuid.strip_edges()
	if client == null or client.state not in SHOW_IN or not valid_uuid(uuid):
		return
	if uuid == _want or (visible and not _model.is_empty() and str(_model.get("asked", "")) == uuid):
		return
	var origin: String = client.config.origin
	if origin.is_empty():
		return
	_http.cancel_request()
	_want = uuid
	if int(_observe_get.call(origin + PATH % [uuid.uri_encode(), str(randf())])) != OK:
		_want = ""
		_fail(FAILED)

func _on_reply(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	var asked: String = _want
	_want = ""
	if asked.is_empty():
		return
	var text: String = body.get_string_from_utf8() if result == HTTPRequest.RESULT_SUCCESS and code == 200 else ""
	var json: JSON = JSON.new()
	var data: Variant = json.data if not text.strip_edges().is_empty() and json.parse(text) == OK else null
	if not show_data(data, asked):
		_fail(NOT_FOUND if code == 404 or data is Dictionary else FAILED)


func show_data(data: Variant, asked: String = "") -> bool:
	if client == null or client.state not in SHOW_IN:
		return false
	var model: Dictionary = parse(data)
	if model.is_empty():
		return false
	model["asked"] = asked if not asked.is_empty() else str(model.uuid)
	model["self"] = _is_me(model)
	_model = model
	_tab = "all"
	_pick = 0
	_row = 0
	_honor_row = 0
	_helper = {}
	_tip = []
	_hover = ""
	_press = ""
	_toast = ""
	if pack != null and not pack.picture_ready.is_connected(_on_picture_ready):
		pack.picture_ready.connect(_on_picture_ready)
	_shown()
	visible = true
	queue_redraw()
	return true

func _fail(text: String) -> void :
	if _model.is_empty():
		visible = true
	say(text)

func close() -> void :
	_want = ""
	if _http != null:
		_http.cancel_request()
	if _watch != null:
		_watch.close()
	if not visible:
		return
	var was: bool = not _model.is_empty()
	_model = {}
	_helper = {}
	_tip = []
	visible = false
	if was:
		closed.emit()

func _tick(_delta: float) -> void :

	if _model.is_empty() and _want.is_empty() and _time - _toast_at > 2.7:
		visible = false


func _has_point(point: Vector2) -> bool:
	return visible and not _model.is_empty() and Rect2(_centre(SIZE.x, SIZE.y) * _f, SIZE * _f).has_point(point)

func _is_me(model: Dictionary) -> bool:
	if client == null:
		return false

	var mine: int = tail(str(client.char_uuid)).to_int()
	if mine > 0:
		return tail(str(model.uuid)).to_int() == mine
	return client.account_id > 0 and int(model.get("account", 0)) == client.account_id



static func _whole(value: Variant) -> int:
	if value is int or value is float or value is bool:
		return int(value)
	return int(str(value).to_float()) if value is String and str(value).is_valid_float() else 0


static func _num(value: Variant) -> String:
	if value is String:
		return str(value) if not str(value).is_empty() else "0"
	if value is bool:
		return str(int(value))
	if value is int:
		return str(value)
	if value is float:
		var number: float = value
		if is_equal_approx(number, roundf(number)) and absf(number) < 1e+15:
			return str(int(roundf(number)))
		return str(snappedf(number, 0.01))
	return "0"

static func _str(value: Variant) -> String:
	return "" if value == null else str(value).strip_edges()

static func _ids(list: Variant) -> Array:
	var out: Array = []
	if not list is Array:
		return out
	for item: Variant in list:
		var id: int = _whole(item.get("nHonorId", item.get("honor_id", item.get("id", 0)))) if item is Dictionary else _whole(item)
		if id > 0:
			out.append(id)
	return out


static func parse(data: Variant) -> Dictionary:
	if not data is Dictionary:
		return {}
	if data.has("state") and _whole(data.get("state")) == 0:
		return {}
	if _whole(data.get("code", 0)) != 0:
		return {}
	var tech: Variant = data.get("char_tech")
	var tanks: Variant = data.get("char_tank")
	var uuid: String = _str(data.get("char_uuid"))
	if not tech is Dictionary or not tanks is Array or (tanks as Array).is_empty() or uuid.is_empty():
		return {}
	var stats: Dictionary = {}
	for tab: String in TECH:
		var block: Variant = tech.get(TECH[tab], {})
		var row: Array = []
		for stat: Array in STATS:
			row.append(_num(block.get(str(stat[1])) if block is Dictionary else null))
		stats[tab] = row
	var list: Array = []
	for item: Variant in tanks:
		if not item is Dictionary:
			continue
		list.append({"id": _whole(item.get("tank_tplt_id", item.get("tank_id", 0))), "level": maxi(1, _whole(item.get("level", 1))), 
			"win": _num(item.get("winmatchs")), "kill": _num(item.get("totalkill")), "assist": _num(item.get("totalassist")), 
			"score": _num(item.get("fightScore")), "ext": _whole(item.get("external_id", 0)), "halo": _whole(item.get("halo_id", 0)), 
			"frame": _whole(item.get("skin_frame_type", 0)), 
			"prof": _whole(item.get("proficiency_val")) if item.get("proficiency_val") != null else -1})
	if list.is_empty():
		return {}


	var keys: Array = []
	for index: int in range(list.size()):
		keys.append([int(list[index].level), str(list[index].score).to_float(), index])
	keys.sort_custom( func(a: Array, b: Array) -> bool:
		if a[0] != b[0]:
			return a[0] > b[0]
		if a[1] != b[1]:
			return a[1] > b[1]
		return a[2] < b[2])
	var ordered: Array = []
	for key: Array in keys:
		ordered.append(list[int(key[2])])
	list = ordered
	var booster: Variant = data.get("booster")
	var helper: Dictionary = {}
	if booster is Dictionary and _whole(booster.get("booster_tid", 0)) > 0:
		helper = {"m_templateId": _whole(booster.get("booster_tid")), "m_rank": _whole(booster.get("booster_r", 0)), 
			"m_rankCost": _whole(booster.get("booster_rcost", 0)), "m_level": _whole(booster.get("booster_l", 0)), 
			"m_upLevel": _whole(booster.get("booster_ul", 0)), "m_upCost": _whole(booster.get("booster_ulcost", 0))}
	var guild: String = _str(data.get("guild_name"))
	var team: String = _str(data.get("team_name"))
	var oid: String = _num(data.get("account_oid")) if data.get("account_oid") != null else tail(uuid)
	var worn: Array = _ids(data.get("equipped_honor_ids"))
	return {"uuid": uuid, "oid": oid, "display": _whole(data.get("displayId", 0)), "account": _whole(data.get("account_id", 0)), "name": _str(data.get("char_name")), 
		"level": _whole(data.get("char_level", 0)), "avatar": _whole(data.get("char_avatar", 0)), "decorate": _whole(data.get("char_decorate", 0)), 
		"vip_point": _whole(data.get("char_vippoint", 0)), "vip_time": float(_whole(data.get("char_vip_time", 0))), 
		"super_time": float(_whole(data.get("char_super_vip_time", 0))), 
		"charm": _num(data.get("char_charm")) if _whole(data.get("char_charm", 0)) > 0 else "0", 
		"romantic": _num(data.get("char_romantic")) if _whole(data.get("char_romantic", 0)) > 0 else "0", 
		"couple": data.get("couple") if data.get("couple") is Dictionary else {}, 
		"section": _whole(data.get("elo_section_id", 0)), 
		"guild_id": _whole(data.get("guild_id", 0)), "guild": guild if not guild.is_empty() else NONE, "guild_level": _whole(data.get("guild_level", 0)), 
		"team_id": _whole(data.get("team_id", 0)), "team": team if not team.is_empty() else NONE, "team_level": _whole(data.get("team_level", 0)), 
		"honors": _ids(data.get("char_honors")), "worn": int(worn[0]) if not worn.is_empty() else 0, 
		"stats": stats, "tanks": list, "helper": helper}


func model() -> Dictionary:
	return _model


func stats() -> Array:
	return _model.get("stats", {}).get(_tab, [])

func tab() -> String:
	return _tab


func is_self() -> bool:
	return bool(_model.get("self", false))

func picked() -> Dictionary:
	var list: Array = _model.get("tanks", [])
	return list[_pick] if _pick >= 0 and _pick < list.size() else {}


func owns(tank_id: int) -> bool:
	if client == null:
		return false
	for inst: Variant in client.tanks.values():
		if inst is Dictionary and int(inst.get("m_tpltId", 0)) == tank_id and int(inst.get("m_contType", -1)) == GarageModel.OWN:
			return true
	return false


func buy_shown() -> bool:
	var tank: Dictionary = picked()
	return not tank.is_empty() and not owns(int(tank.id))


func worn_mark() -> int:
	if not bool(_model.get("self", false)):
		return 0
	var mine: int = int(client.character.get("honor_id", 0)) if client != null else 0
	return mine if mine > 0 else int(_model.get("worn", 0))

func _section(id: int) -> Array:
	return pack.board.get("sections", {}).get(str(id), [])


func _vip_of(points: int, over: float, super_over: float) -> int:
	var now: float = Time.get_unix_time_from_system()
	if over > 100000000000.0:
		over /= 1000.0
	if super_over > 100000000000.0:
		super_over /= 1000.0
	if over - now <= 0.0:
		return 0
	return _vip_level(points) + (100 if super_over > now else 0)

func _tank_name(id: int) -> String:
	return GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(id), "")))



static func skin_name(ext: int, tank_id: int = 0) -> String:
	if ext <= 0:
		return ""
	var groups: Array = [str(tank_id)] if GarSkin.SKINS.has(str(tank_id)) else []
	for key: Variant in GarSkin.SKINS:
		if str(key) != "0" and str(key) != str(tank_id):
			groups.append(str(key))
	for key: String in groups:
		for row: Variant in GarSkin.SKINS[key]:
			if row is Array and row.size() > 3 and int(row[1]) == ext and not str(row[3]).strip_edges().is_empty():
				return str(row[3]).strip_edges()
	return ""


func row_name(tank: Dictionary) -> String:
	var skin: String = skin_name(int(tank.get("ext", 0)), int(tank.get("id", 0)))
	return skin if not skin.is_empty() else _tank_name(int(tank.get("id", 0)))


static func frame_cell(kind: int) -> String:
	return "pis_frame_%d" % kind if kind in SkinAtlas.KINDS else ""


func honors() -> Array:
	if bool(_model.get("self", false)) and client != null:
		var mine: Array = _ids(client.honors)
		if not mine.is_empty():
			return mine
	return _model.get("honors", [])



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(LB.FILE, LB.R)
		_use(Hall.FILE, Hall.R)
		_use(SkinAtlas.FILE, SkinAtlas.R)
		var cells: Dictionary = {}
		for name: String in HELPER_CELLS:
			cells[name] = HelperAtlas.R[name]
		_use(HelperAtlas.FILE, cells)
	_tip = []
	_htip = {}
	if _model.is_empty():
		return
	var base: Vector2 = _centre(SIZE.x, SIZE.y)
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_fblit("pi_frame", base + Vector2(float(Atlas.FRAME[0]), float(Atlas.FRAME[1])))
	_fbutton("close", "pi_close", base + _at("btnClose"))
	_draw_card(base)
	_draw_tabs(base)
	_draw_stats(base)
	_draw_honors(base)
	_draw_tanks(base)
	_draw_tank(base)
	_draw_helper(base)
	_fwords(REFRESH, BOLD, 12.0, TIP_INK, "l", base + Vector2(21, 499), 216.0, 0.0, 27.0)
	_draw_tip()
	_draw_htip()

func _at(id: String) -> Vector2:
	var spot: Array = Atlas.SPOT[id]
	return Vector2(float(spot[0]), float(spot[1]))


func _value(text: String, id: String, base: Vector2) -> void :
	var spot: Array = Atlas.SPOT[id]
	_fwords(text, BOLD, 13.0, VALUE_INK, "r", base + Vector2(float(spot[0]) + 3.0, float(spot[1])), float(spot[2]) - 9.0, 1.0, float(spot[3]))


func _photo(path: String, rect: Rect2) -> bool:
	var picture: Texture2D = pack.picture(path) if not path.is_empty() else null
	if picture == null or picture.get_width() <= 4:
		return false
	draw_texture_rect(picture, Rect2(rect.position * _f, rect.size * _f), false)
	return true


func _hfit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0, tint: Color = Color.WHITE) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false, tint)


func _draw_card(base: Vector2) -> void :

	var shown_id: String = str(_model.get("display", 0)) if int(_model.get("display", 0)) > 0 else ""
	_fwords(shown_id, BOLD, 16.0, Color.WHITE, "l", base + _at("lblCharOid"), 170.0, 1.0)
	_value(str(_model.charm), "lblGlamourValue", base)
	_value(str(_model.romantic), "lblRomanticValue", base)
	var ornate: String = ornate_stem()
	var box: Rect2 = ornate_box(base, ornate)
	if box.has_area():
		_photo(ornate_picture(ornate), box)
	var vip: int = _vip_of(int(_model.vip_point), float(_model.vip_time), float(_model.super_time))
	var style: Array = HallScreen.name_style(vip % 100)
	if not NameStyles.paint(self, str(_model.name), BOLD, 14.0, "c", base + _at("lblPlayerName"), 152.0, 1.0, 24.0):
		_fwords(str(_model.name), BOLD, 14.0, style[0], "c", base + _at("lblPlayerName"), 152.0, 1.0, 24.0, true, style[1])
	_fblit("level_%d" % clampi(int(_model.level), 0, 40), base + _at("cvsCharLevel"), 80.0, 40.0)
	_level_fx(int(_model.level), base + _at("cvsCharLevel"), 80.0)
	var av_id: int = int(_model.avatar)
	var key: String = str(pack.lobby.get("avatars", {}).get(str(av_id), ""))
	if key.is_empty():
		var sex: int = int(_model.get("sexes", _model.get("char_sex", 1)))
		av_id = 2802001 if sex == 2 else 2801001
		key = str(pack.lobby.get("avatars", {}).get(str(av_id), "girl001" if sex == 2 else "boy001"))
	if not key.is_empty():
		_photo("l/av/%s.webp" % key, Rect2(base + _at("imgCharAvatar"), Vector2(180, 240)))
	if vip % 100 > 0:
		_fblit("lb_vbig%d" % mini(12, vip % 100), base + _at("imgVip"))
	var love_pair: Variant = _model.get("couple")

	if love_pair is Dictionary and not (love_pair as Dictionary).is_empty() and (is_self() or (Love.me(client) > 0 and int((love_pair as Dictionary).get("partnerId", 0)) == Love.me(client))):
		draw_rect(Rect2((base + Vector2(32, 312)) * _f, Vector2(180, 22) * _f), Color(0.02, 0.07, 0.16, 0.72))
		var love_wed: bool = int(love_pair.get("state", 1)) == 2
		Love.fdraw(self, base + Vector2(38, 316), 14.0, 1 if love_wed else 0)
		_fwords("%s · %s" % ["Vợ Chồng" if love_wed else Love.days_text(int(love_pair.get("days", 1))), str(love_pair.get("partnerName", ""))], BOLD, 12.0, Color.WHITE, "l", 
			base + Vector2(58, 312), 150.0, 1.0, 22.0)
	_draw_group(base, str(_model.guild), int(_model.guild_level), int(_model.guild_id), "txtCorpsName", "txtCorpsLevel", "btnWatchCorps", "guild")
	_draw_group(base, str(_model.team), int(_model.team_level), int(_model.team_id), "txtTeamName", "lblTeamLevel", "btnWatchTeam", "team")


func ornate_stem() -> String:
	return str(pack.bagx.get("ornate", {}).get(str(int(_model.get("decorate", 0))), "")) if pack != null and not _model.is_empty() else ""



static func ornate_box(base: Vector2, stem: String) -> Rect2:
	if stem.is_empty() or SelfAtlas.ORB_BLANK.has(stem):
		return Rect2()
	var size: Array = SelfAtlas.ORB.get(stem, [180, 240])
	var extent: Vector2 = Vector2(float(size[0]), float(size[1]))
	return Rect2(base + ((SIZE - extent) / 2.0 + ORNATE_CENTRE).round(), extent)


static func ornate_picture(stem: String) -> String:
	return ("l/orb/%s.webp" if SelfAtlas.ORB.has(stem) else "l/or/%s.webp") % stem

func _draw_group(base: Vector2, title: String, level: int, id: int, name_spot: String, level_spot: String, button: String, hit: String) -> void :
	var spot: Array = Atlas.SPOT[level_spot]
	var level_text: String = LEVEL + str(maxi(0, level))
	var used: float = _fwords(level_text, BOLD, 13.0, VALUE_INK, "r", base + Vector2(float(spot[0]), float(spot[1])), float(spot[2]) - 4.0, 1.0, float(spot[3]))
	var box: Array = Atlas.SPOT[name_spot]
	_fwords(title, BOLD, 13.0, VALUE_INK, "l", base + Vector2(float(box[0]) + 3.0, float(box[1])), maxf(20.0, float(box[2]) - used - 12.0), 1.0, float(box[3]))
	if id > 0:
		_fbutton(hit, "pi_view", base + _at(button))

func _draw_tabs(base: Vector2) -> void :
	for tab: Array in Atlas.TABS:
		var id: String = str(tab[0])
		var at: Vector2 = base + Vector2(float(tab[1]), float(tab[2]))
		var box: Vector2 = Vector2(float(tab[3]), float(tab[4]))
		var chosen: bool = id == _tab
		if chosen:
			_fblit("pi_tab_on", at)
		var word: String = "pi_t_%s%s" % [id, "_on" if chosen and int(tab[5]) == 1 else ""]
		_fblit(word, at + ((box - _cell_size(word)) / 2.0).round(), 0.0, 0.0, _glow("tab:" + id))
		_hit("tab:" + id, Rect2(at * _f, box * _f), false)


func _draw_stats(base: Vector2) -> void :
	var id: int = int(_model.section)
	var section: Array = _section(id) if id > 0 else []
	if not section.is_empty():
		var icon: Texture2D = pack.picture("l/bxh/s%d.webp" % int(section[1]))
		if icon != null and icon.get_width() > 4:
			draw_texture_rect(icon, Rect2((base + _at("imgSectionIcon")) * _f, Vector2(icon.get_width(), icon.get_height()) * 0.14 * _f), false)
		_value(str(section[0]), "lblSection", base)
	elif id <= 0 or not pack.board.is_empty():
		_fblit("pi_section", base + _at("imgSectionIcon"))
		_value(NO_SECTION, "lblSection", base)
	var row: Array = stats()
	for i: int in mini(row.size(), STATS.size()):
		_value(str(row[i]), str(STATS[i][0]), base)


func _draw_honors(base: Vector2) -> void :
	var shown: Array = honors()
	_hbar = Rect2()
	if shown.is_empty():
		_fwords(NO_HONOR, BOLD, 14.0, Color.WHITE, "c", base + Vector2(279, 208), 480.0, 1.0, 20.0, true, EMPTY_RIM)
		return
	_honor_row = clampi(_honor_row, 0, maxi(0, shown.size() - HONOR_SHOWN))
	var y: float = HONOR.y + (10.0 if shown.size() <= HONOR_SHOWN else 0.0)
	var mark: int = worn_mark()
	for i: int in HONOR_SHOWN:
		var index: int = _honor_row + i
		if index >= shown.size():
			break
		var id: int = int(shown[index])
		var at: Vector2 = base + Vector2(HONOR.x + i * HONOR_PITCH, y)
		_fblit("pi_honor_box", at)
		var info: Array = _honor_row_of(id)
		if info.size() > 2 and not str(info[2]).is_empty():
			_hfit(pack.picture("l/hn/%s.webp" % str(info[2])), at + Vector2(5, 5), Vector2(40, 40))
		if mark > 0 and mark == id:
			_fblit("pi_honor_on", at + Vector2(26, 26))
		var rect: Rect2 = Rect2(at * _f, Vector2(50, 50) * _f)
		var hit: String = "honor:%d" % index
		_hit(hit, rect, false)
		var title: String = BagModel.clean(str(info[0])) if info.size() > 0 else ""
		var body: String = GarageModel.plain(BagModel.clean(str(info[1]))) if info.size() > 1 else ""
		if mark > 0 and mark == id:
			body = (body + " " + WORN).strip_edges()
		_tip_on(hit, rect, title if not title.is_empty() else "Huy chương %d" % id, body, Color.WHITE)
	if shown.size() > HONOR_SHOWN:
		_draw_honor_bar(base, shown.size())



func _draw_honor_bar(base: Vector2, count: int) -> void :
	var most: int = count - HONOR_SHOWN
	_hbar = _hscroll("hsb", ["pi_sb_up", "pi_sb_down", "pi_sb_bk", "pi_sb_thumb"], base + HONOR_BAR, HONOR_BAR_W, _honor_row, HONOR_SHOWN, count, 
		func(value: float) -> void : _honor_row = clampi(roundi(value), 0, most))

func _honor_row_of(id: int) -> Array:
	return pack.bag.get("honors", {}).get(str(id), [])



func _draw_tanks(base: Vector2) -> void :
	var list: Array = _model.get("tanks", [])
	_fwords(TANK_NUM % list.size(), BOLD, 14.0, NUM_INK, "l", base + Vector2(316, 260), 160.0, 1.0)
	_row = clampi(_row, 0, maxi(0, list.size() - ROWS))
	for i: int in ROWS:
		var index: int = _row + i
		if index >= list.size():
			break
		var tank: Dictionary = list[index]
		var o: Vector2 = base + LIST + Vector2(0, i * ROW.y)
		if index == _pick:
			_fblit("pi_row_on", o)
		_fwords(row_name(tank), BOLD, 14.0, NAME_INK, "l", o + Vector2(132, 6), NAME_W, 1.0, 20.0, true, NAME_RIM)
		_fblit("tklv_%d" % clampi(int(tank.level), 1, 11), o + Vector2(82, 7))
		_fwords(ROW_SCORE % str(tank.score), BOLD, 12.0, Color.WHITE, "l", o + Vector2(80, 31), 136.0, 1.0, 18.0)
		_fwords(ROW_WIN % str(tank.win), BOLD, 12.0, Color.WHITE, "l", o + Vector2(80, 50), 136.0, 1.0, 18.0)
		var frame: String = frame_cell(int(tank.get("frame", 0)))
		if not frame.is_empty():
			_fblit(frame, o + Vector2(float(SkinAtlas.AT[0]), float(SkinAtlas.AT[1])))
		_tank(tank, o + Vector2(38, 38), 0.3)
		_hit("row:%d" % index, Rect2(o * _f, ROW * _f), false)
	_draw_scroll(base, list.size())

func _draw_scroll(base: Vector2, count: int) -> void :
	var spot: Vector2 = base + LIST + Vector2(ROW.x + 1.0, 0)
	var track: float = LIST_H - 38.0
	_vslice("pi_sb_bk", spot + Vector2(0, 19), track)
	_fbutton("sb:up", "pi_sb_up", spot)
	_fbutton("sb:down", "pi_sb_down", spot + Vector2(0, LIST_H - 19.0))
	_thumb = Rect2()
	if count <= ROWS:
		return
	_hit("sb:track", Rect2((spot + Vector2(0, 19)) * _f, Vector2(19, track) * _f), false)
	var thumb: float = maxf(20.0, track * ROWS / float(count))
	var y: float = (track - thumb) * _row / float(count - ROWS)
	_vslice("pi_sb_thumb", spot + Vector2(0, 19.0 + y), thumb)
	_thumb = Rect2((spot + Vector2(0, 19.0 + y)) * _f, Vector2(19, thumb) * _f)


func _vslice(cell_id: String, at: Vector2, high: float) -> void :
	var cell: Array = _cells.get(cell_id, [])
	if cell.is_empty() or cell[0] == null or high <= 0.0:
		return
	var region: Array = cell[1]
	var w: float = float(region[2])
	var full: float = float(region[3])
	var cap: float = minf(6.0, floorf(high / 2.0))
	_fpart(cell_id, at, Rect2(0, 0, w, cap))
	_fpart(cell_id, at + Vector2(0, high - cap), Rect2(0, full - cap, w, cap))
	if high - 2.0 * cap > 0.0:
		draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, cap)) * _f, Vector2(w, high - 2.0 * cap) * _f), Rect2(float(region[0]), float(region[1]) + cap, w, full - 2.0 * cap))


func _tank(tank: Dictionary, centre: Vector2, zoom: float) -> void :
	var tank_id: int = int(tank.id)
	if tank_id <= 0 or pack.state != "ready" or pack.garage.is_empty():
		return
	var level: int = maxi(1, int(tank.level))
	var ext: int = int(tank.ext)
	if ext <= 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, level, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(tank.halo), level)
	TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, centre * _f, zoom * _f, _time)


func _draw_tank(base: Vector2) -> void :
	var tank: Dictionary = picked()
	if tank.is_empty():
		return
	_tank(tank, base + BIG_TANK, 1.0)
	_fblit("tklv_%d" % clampi(int(tank.level), 1, 11), base + Vector2(513, 454))
	var prof_icon: Texture2D = Proficiency.icon(int(tank.get("prof", -1)), false)
	if prof_icon != null:
		var prof_rect: Rect2 = Rect2((base + PROF_AT.position) * _f, PROF_AT.size * _f)
		draw_texture_rect(prof_icon, prof_rect, false)
		_hit("prof", prof_rect, false)
		_tip_on("prof", prof_rect, "Thông thạo", Proficiency.tip(int(tank.get("prof", -1))), Color.WHITE)
	_fwords(_tank_name(int(tank.id)), BOLD, 13.0, Color.WHITE, "l", base + Vector2(557, 450), 160.0, 1.0, 28.0)
	_value(str(tank.score), "lblTankBattlePoint", base)
	_value(str(tank.win), "lblTankWin", base)
	_value(str(tank.kill), "lblTankKill", base)
	_value(str(tank.assist), "lblTankAssist", base)
	var help: Array = Atlas.SPOT["imgTankScoreHelp"]
	var rect: Rect2 = Rect2((base + Vector2(float(help[0]), float(help[1]))) * _f, Vector2(float(help[2]), float(help[3])) * _f)
	_hit("help", rect, false)
	_tip_on("help", rect, "Chiến tích", SCORE_HELP, Color.WHITE)
	if buy_shown():
		_fbutton("buy", "pi_buy", base + _at("btnBuyTank"))


func _draw_helper(base: Vector2) -> void :
	var inst: Dictionary = _model.get("helper", {})
	if inst.is_empty() or pack.helper.is_empty():
		return
	if _helper.is_empty():
		_helper = HelperModel.record(inst, pack.helper, pack.bag, "")
	if _helper.is_empty():
		return
	var rec: Dictionary = _helper
	var spot: Vector2 = base + _at("frmHelperBox")
	var b: Dictionary = HelperAtlas.BOX[HELPER_BOX]
	var side: float = float(b.size)
	var glass: Array = b.glass
	var item: Array = b.item
	var star: Array = b.star
	_fblit(str(b.bg), spot)
	_fblit(str(glass[0]), spot + Vector2(float(glass[1]), float(glass[2])), float(glass[3]), float(glass[4]))
	if not str(rec.icon).is_empty():
		_hfit(pack.picture(str(rec.icon)), spot + Vector2(float(item[0]), float(item[1])), Vector2(float(item[2]), float(item[3])))
	_fblit("hp_star", spot + Vector2(float(star[0]), float(star[1])), float(star[2]), float(star[3]))


	var rank_max: int = int(rec.rank_max)
	GradLabel.flex(self, "%d/%d" % [mini(int(rec.rank), rank_max), rank_max], _face(BOLD), 12.0, spot + _spec_at(b.lbl_star), 22.0, _f)
	GradLabel.flex(self, str(int(rec.apt)), _face(BOLD), 12.0, spot + _spec_at(b.pot), 22.0, _f)
	if int(rec.up) != 0:
		_bar(spot, b.bar, b.rule, int(rec.up), int(rec.up_max))
	var rect: Rect2 = Rect2(spot * _f, Vector2(side, side) * _f)
	_hit("helper", rect, false)


	if (rec.get("tpl", []) as Array).size() >= 17:
		if _hover == "helper" and _press.is_empty():
			_htip = rec
	else:
		_tip_on("helper", rect, GarageModel.cap(str(rec.name)), _helper_lines(rec), BagModel.tint(int(rec.quality), Color.WHITE))


func _draw_htip() -> void :
	if _htip.is_empty():
		return
	var more: Dictionary = pack.bag.get("more", {})
	HelperTip.show(self, _f, Vector2(_fw, _fh), get_local_mouse_position() / _f, client, pack.helper, more, _htip, 
		HelperTip.context(client, _htip, more), false, pack.picture)



func _bar(box: Vector2, bar: Array, rule: Array, up: int, up_max: int) -> void :
	var cell_id: String = str(bar[0])
	var spot: Vector2 = box + Vector2(float(bar[1]), float(bar[2]))
	_fblit(cell_id, spot, 0.0, 0.0, Color(1, 1, 1, 0.5))
	if up_max <= 0:
		return
	var size_of: Vector2 = _cell_size(cell_id)
	var steps: int = clampi(ceili(float(mini(up, up_max)) / (float(up_max) / 10.0)), 0, 10)
	var y_off: float = maxf(0.0, float(rule[2]) - steps * float(rule[0]) + float(rule[1]))
	if y_off < size_of.y:
		_fpart(cell_id, spot + Vector2(0, y_off), Rect2(0, 0, size_of.x, size_of.y - y_off))

func _spec_at(spec: Array) -> Vector2:
	return Vector2(float(spec[0]), float(spec[1]))

func _helper_lines(rec: Dictionary) -> String:
	return "\n".join(PackedStringArray([
		"Loại: %s" % str(HelperModel.TYPES.get(int(rec.type), "—")), 
		"Tư chất: %d" % int(rec.apt), 
		"LV: %d/%d" % [int(rec.lv), int(rec.lv_max)], 
		"Cường hóa: %d/%d" % [int(rec.up), int(rec.up_max)], 
		"Sao: %d/%d" % [int(rec.rank), int(rec.rank_max)], 
		"Chiến Lực: %d" % int(rec.score)]))


func _tip_on(id: String, rect: Rect2, title: String, body: String, tint: Color) -> void :
	if _hover == id and _press.is_empty():
		_tip = [rect, title, body, tint]

func _draw_tip() -> void :
	if _tip.is_empty():
		return
	var anchor: Rect2 = _tip[0]
	var body: String = str(_tip[2])
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 8)



func _activate(id: String) -> void :
	if _model.is_empty() or watch_open():
		return
	if id == "close":
		close()
	elif id.begins_with("tab:"):
		var tab: String = id.substr(4)
		if TECH.has(tab):
			_tab = tab
	elif id.begins_with("row:"):
		var index: int = int(id.substr(4))
		if index >= 0 and index < _model.get("tanks", []).size():
			_pick = index
	elif id == "sb:up":
		_scroll_tanks(-1)
	elif id == "sb:down":
		_scroll_tanks(1)
	elif id == "sb:track":
		var mouse: float = get_local_mouse_position().y
		if _thumb.size.y > 0.0:
			_scroll_tanks( - ROWS if mouse < _thumb.position.y else ROWS)
	elif id.begins_with("honor:"):
		_click_honor(int(id.substr(6)))
	elif id == "hsb:left":
		_scroll_honors(-1)
	elif id == "hsb:right":
		_scroll_honors(1)
	elif id == "hsb:pgl":
		_scroll_honors( - HONOR_SHOWN)
	elif id == "hsb:pgr":
		_scroll_honors(HONOR_SHOWN)
	elif id == "buy":
		if buy_shown():
			if tank_buy_asked.get_connections().is_empty():
				say(SOON % "Mua tank")
			else:
				tank_buy_asked.emit(int(picked().id))
	elif id == "guild" and int(_model.get("guild_id", 0)) > 0:
		_open_watch().open_guild(int(_model.get("guild_id", 0)))
	elif id == "team" and int(_model.get("team_id", 0)) > 0:
		_open_watch().open_team_id(int(_model.get("team_id", 0)))


func _click_honor(index: int) -> void :
	var list: Array = honors()
	if not is_self() or index < 0 or index >= list.size() or client == null:
		return
	var id: int = int(list[index])
	var first: int = int(client.character.get("honor_id", 0))
	if id != 0 and id != first:
		client.wear_honors(swap_first(first, client.honors_worn, id))


static func swap_first(first: int, worn: Array, id: int) -> Array:
	var ids: Array = worn.duplicate()
	if first == 0 or ids.is_empty():
		ids.push_front(id)
	else:
		ids[0] = id
	return ids.slice(0, 4)

func _scroll_tanks(step: int) -> void :
	_row = clampi(_row + step, 0, maxi(0, _model.get("tanks", []).size() - ROWS))

func _scroll_honors(step: int) -> void :
	_honor_row = clampi(_honor_row + step, 0, maxi(0, honors().size() - HONOR_SHOWN))

func _area(rect: Rect2) -> Rect2:
	return Rect2((_centre(SIZE.x, SIZE.y) + rect.position) * _f, rect.size * _f)

func _wheel(step: int, at: Vector2) -> void :
	if _model.is_empty() or watch_open():
		return
	if _area(HONOR_AREA).has_point(at):
		_scroll_honors(step)
	elif _area(Rect2(LIST, Vector2(ROW.x + 20.0, LIST_H))).has_point(at):
		_scroll_tanks(step)



func _drag(moved: Vector2, from: Vector2) -> void :
	if _model.is_empty() or watch_open():
		return
	if from != _drag_from:
		_drag_from = from
		_drag_sum = 0.0
		_drag_mode = ""
		if _thumb.size.y > 0.0 and _thumb.grow(2.0).has_point(from):
			_drag_mode = "thumb"
		elif _hbar.has_point(from):
			_drag_mode = "bar"
		elif _area(Rect2(LIST, Vector2(ROW.x, LIST_H))).has_point(from):
			_drag_mode = "tanks"
		elif _area(HONOR_AREA).has_point(from):
			_drag_mode = "honors"
	match _drag_mode:
		"thumb":
			var count: int = _model.get("tanks", []).size()
			var track: float = (LIST_H - 38.0) * _f - _thumb.size.y
			if count > ROWS and track > 0.0:
				_drag_sum += moved.y
				var per: float = track / float(count - ROWS)
				while absf(_drag_sum) >= per:
					_scroll_tanks(1 if _drag_sum > 0.0 else -1)
					_drag_sum -= per * signf(_drag_sum)
		"tanks":
			_drag_sum += moved.y
			var row_px: float = ROW.y * _f
			while absf(_drag_sum) >= row_px:
				_scroll_tanks(-1 if _drag_sum > 0.0 else 1)
				_drag_sum -= row_px * signf(_drag_sum)
		"honors":
			_drag_sum += moved.x
			var cell_px: float = HONOR_PITCH * _f
			while absf(_drag_sum) >= cell_px:
				_scroll_honors(-1 if _drag_sum > 0.0 else 1)
				_drag_sum -= cell_px * signf(_drag_sum)

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or _model.is_empty() or not (event is InputEventKey and event.pressed):
		return
	if watch_open():
		return
	if event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
