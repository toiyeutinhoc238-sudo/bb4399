extends "flash_screen.gd"











































































const Atlas = preload("selecttank_atlas.gd")
const Hall = preload("hall_atlas.gd")
const GarageModel = preload("garage_model.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const Seats = preload("room_atlas.gd")
const NameStyles = preload("name_styles.gd")
const HallScreen = preload("hall_screen.gd")
const SelectSkin = preload("select_skin.gd")
const Corps = preload("select_corps_atlas.gd")
const Camp = preload("selectcamp_atlas.gd")
const BarAtlas = preload("approach_tank_atlas.gd")
const GuildManage = preload("guild_manage_atlas.gd")
const VoiceUI = preload("voice_ui.gd")
const VoiceClient = preload("voice_client.gd")
const Settings = preload("res://settings.gd")

signal pick_asked(id: int)
signal lock_asked()
signal talent_asked(tank_uuid: String)
signal rent_asked(tank: int)
signal crystal_asked(tank_uuid: String)

const DIM: Color = Color(0, 0, 0, 0.6)
const SHOW_IN: Array = ["lobby", "hall", "room"]
const MUSIC: String = "startfightfx"
const SOON: String = "Mục này đang được chuyển sang HTML5."
const PITCH: float = 100.0
const ROWS: int = 3
const BAR: float = 19.0
const ROOM_HAPPY: int = 100
const CHAT_BAR_W: float = 16.0


const CHAT_BAR: Vector3 = Vector3(534.5, 8.5, 34.0)
const CHAT_BAR_OPEN: Vector3 = Vector3(533.5, 7.5, 84.0)
const GRID: Vector2 = Vector2(178, 98)
const HEAD_INSET: float = 4.0
const HEAD_ALPHA: int = 40
const HEAD_SCAN: int = 64
const HEAD_TRIM: float = 0.03
const TITLE_GOLD: Color = Color("fcc853")
const CRYSTAL_EDIT: Vector2 = Vector2(602, 444)
const LACK_LEVEL: int = 8
const LACK_COUNT: int = 3
const FILTERS: Array = ["btnAll", "btnAttack", "btnPanzer", "btnAssist"]
const FILTER_CELLS: Array = ["st_f_all", "st_f_attack", "st_f_panzer", "st_f_assist"]
const WEEKLY_BATTLE: int = 2
const WEEKLY_BG: Color = Color("b32025")
const WEEKLY_FREE: String = "MIỄN PHÍ TUẦN"
const WEEKLY_VIP: String = "VIP TUẦN"
const WEEKLY_FREE_TIP: String = "Miễn phí tuần · Chỉ So tài"
const WEEKLY_VIP_TIP: String = "VIP tuần · VIP tối thiểu %d"
const CRYSTAL_OPEN: int = 524288
const CRYSTAL_DEFAULT: Array = ["DPS", "Sinh Tồn"]
const CRYSTAL_CUSTOM: String = "Tùy chỉnh %d"
const CORPS_SLOT: int = 4
const CORPS_DEFAULT: int = 1100
const CORPS_TIP_WIDE: float = 240.0
const CORPS_COLS: int = 5
const CORPS_ROWS: int = 2
const CORPS_NO_SKILL_GLOW: Color = Color(0, 0, 0, 0.6)
const CHAT_FILE: String = "res://assets/ui/hall/selecttank_chat.png"
const CHAT_OPEN_AT: Vector2 = Vector2(223, 463)
const CHAT_OPEN_SIZE: Vector2 = Vector2(557, 129)
const CHAT_SIZE: Vector2 = Vector2(557, 79)
const CHAT_AREA: Rect2 = Rect2(231.5, 525, 540, 25)
const CHAT_AREA_OPEN: Rect2 = Rect2(231.5, 475, 540, 75)
const CHAT_INPUT: Rect2 = Rect2(234.5, 562.5, 460, 22)
const CHAT_SEND_OPEN: Vector2 = Vector2(700, 559)
const CHAT_LINE: float = 24.0
const CHAT_PX: float = 14.0
const CHAT_GLOW: Color = Color(22 / 255.0, 0, 0, 0.8)
const CHAT_LIMIT: int = 60
const CHAT_HINT: String = "Nhập nội dung chat"
const CHAT_FAST: String = "Nói quá nhanh"
const CHAT_HOVER: Array = ["chatbox", "chat", "send"]

const CENTRED: Array = ["lblTankName", "lblSkillGiftName", "lblSkillNormalName", "lblSkillExName"]
const SPRITE_ROOM: float = 172.0

const ROUND_SELF: String = "Bên ta chọn @num1@ tank（@num2@/@num1@）"
const ROUND_ENEMY: String = "Bên địch chọn @num1@ tank（@num2@/@num1@）"
const ROUND_WAIT: String = "Hãy đợi phía địch chọn tank"
const ROUND_READY: String = "Đang chuẩn bị vào"
const ROUND_PLAYER: String = "Người chơi"
const ROUND_ENTER: int = 10
const LADDER: int = 9
const FREE_ROOM: int = 1
const ROOM_PVP: int = 2
const GUILD_MATCH: int = 12
const HALO_EDGE: Color = Color("1b79b4")
const HALO_TOP: Color = Color("64bbdf")
const HALO_BOTTOM: Color = Color("108ec6")
const HALO_FILL: Color = Color("0390d3")
const HALO_OVER: Color = Color("31b3e8")
const HALO_PICKED: Color = Color("07629b")
const TALENT_ROW: float = 22.0
const TALENT_SHOWN: int = 5



const VOICE_MIC: Vector2 = Vector2(163.5, 552.5)
const VOICE_SPK: Vector2 = Vector2(198.5, 552.5)
const VOICE_R: float = 12.5
const VOICE_HIT: float = 17.0
const VOICE_HOLD: float = 0.3
const VOICE_TAG: Dictionary = {"all": "T", "room": "R", "off": ""}

var can_pick: bool = false
var _filter: int = 0
var _scroll: int = 0
var _tip_text: String = ""
var _tip_spot: Vector2 = Vector2.ZERO
var crystal_label: String = ""
var crystal_drop: bool = false
var _crystal_first: int = 0
var crystal_pick: int = 0
var _crystal_tank: int = -1
var corps_shown: int = 0
var corps_tip: String = ""
var corps_open: bool = false
var corps_list: Array = []
var _corps_first: int = 0
var chat_open: bool = false
var chat_shown: Array = []
var _chat_from: int = 0
var _chat_scroll: int = 0
var _chat_most: int = 0
var _typing: LineEdit
var _bars: Dictionary = {}
var head_shown: Array = []
var _boxes: Dictionary = {}
var skin_strip: SelectSkin = SelectSkin.new()
var talent_label: String = ""
var talent_uuid: String = ""
var talent_drop: bool = false
var _talent_first: int = 0
var _talent_tank: int = -1
var _talent_seen: int = -1


var _chat_pin: bool = false
var _voice: Object = null
var _voice_key: Array = [-1, ""]
var _voice_hold_at: float = -1.0
var voice_drawn: Dictionary = {}

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_typing = _fedit(CHAT_LIMIT)
	_typing.placeholder_text = CHAT_HINT
	_typing.add_theme_font_override("font", ARIAL)
	_typing.add_theme_color_override("font_placeholder_color", Color.WHITE)
	_typing.keep_editing_on_text_submit = true
	_typing.text_submitted.connect( func(_text: String) -> void : _send_chat())
	if client != null:
		client.changed.connect(_follow)
	var guide_view: Control = preload("guide_view.gd").new()
	guide_view.setup(self, "select_tank")
	add_child(guide_view)


func _follow() -> void :
	var want: bool = client != null and not client.pair_scene.is_empty() and client.state in SHOW_IN
	if want == visible:
		return
	visible = want
	_chat_pin = false
	talent_drop = false
	crystal_drop = false
	crystal_pick = 0
	_talent_tank = -1
	if want:
		_filter = 0
		_scroll = 0
		_hover = ""
		_press = ""
		_chat_from = client.chat_rev
		_chat_scroll = 0
		_typing.text = ""
		if is_inside_tree():
			get_viewport().gui_release_focus()
		if pack != null:
			pack.load_garage()
		if int(pair().get("type", 0)) == LADDER:
			say(str(Atlas.TIP_3))

func _shown() -> void :
	if not is_visible_in_tree():
		_hide_edits()



func pair() -> Dictionary:
	return client.pair_scene if client != null else {}


func camp() -> int:
	for brief: Dictionary in pair().get("chars", []):
		if int(brief.charData.nAcctId) == client.account_oid:
			return int(brief.get("bCamp", 1))
	return 1



func watching() -> bool:
	var chars: Array = pair().get("chars", [])
	if client == null or chars.is_empty():
		return false
	for brief: Dictionary in chars:
		if int(brief.charData.nAcctId) == client.account_oid:
			return false
	return true


func sides() -> Array:
	var mine: Array = []
	var enemy: Array = []
	var own: int = camp()
	for brief: Dictionary in pair().get("chars", []):
		(mine if int(brief.get("bCamp", 1)) == own else enemy).append(brief)
	return [mine, enemy]


func seconds_left() -> int:
	var scene: Dictionary = pair()
	if scene.is_empty():
		return 0
	return maxi(0, int(scene.get("time", 0)) - floori((Time.get_ticks_msec() - int(scene.get("at", 0))) / 1000.0))


func round_mode() -> bool:
	return client != null and client.pair_round()



func ranked_cells() -> bool:
	return round_mode() or (client != null and int(pair().get("type", 0)) == FREE_ROOM)


func round_seconds() -> int:
	var scene: Dictionary = pair()
	if scene.is_empty():
		return 0
	var from: int = int(scene.get("at", 0))
	var total: int = int(scene.get("time", 0))
	var turn: Dictionary = scene.get("turn", {})
	if int(scene.get("all_at", 0)) > 0:
		from = int(scene.all_at)
		total = ROUND_ENTER
	elif not turn.is_empty():
		from = int(turn.get("at", 0))
		total = int(turn.get("time", 0))
	return maxi(0, total - floori((Time.get_ticks_msec() - from) / 1000.0))


func round_texts() -> Array:
	var left: int = round_seconds()
	var clock: String = str(left) if left > 0 else ""
	if client.pair_all_locked():
		return [clock, clock, ROUND_READY]
	var mine: bool = client.self_turn()
	var turn: Dictionary = pair().get("turn", {})
	var mid: String = str(Atlas.MID_TIPS)
	if not turn.is_empty():
		mid = (ROUND_SELF if mine else ROUND_ENEMY).replace("@num1@", str(int(turn.get("max", 0)))).replace("@num2@", str(int(turn.get("done", 0))))
	return [clock if mine else "", "" if mine else clock, mid]


func enemy_seat(oid: int) -> int:
	var enemy: Array = sides()[1]
	for i in range(enemy.size()):
		if int(enemy[i].charData.nAcctId) == oid:
			return i
	return 0

func _pick(oid: int) -> Dictionary:
	return skin_strip.seat_pick(self, oid, pair().get("picks", {}).get(oid, {}))

func locked(oid: int) -> bool:
	return bool(pair().get("locked", {}).get(oid, false))


func my_tank() -> int:
	return int(_pick(client.account_oid).get("tank", 0)) if client != null else 0



func weekly(tank: int) -> Dictionary:
	if client == null or int(pair().get("type", 0)) != WEEKLY_BATTLE:
		return {}
	var row: Dictionary = client.weekly_row(tank, int(Time.get_unix_time_from_system()))
	return row if bool(row.get("eligible", false)) else {}




func tank_list() -> Array:
	if pack == null or pack.garage.is_empty():
		return []
	var out: Array = []
	for rec: Dictionary in GarageModel.roster(client.tanks, pack.garage, pack.lobby.get("tanks", {}), pack.index.get("tanks", {}), int(Time.get_unix_time_from_system())):
		if _filter != 0 and int(rec.cls) != _filter:
			continue
		if rec.avail:
			out.append(rec)
			continue
		var row: Dictionary = weekly(int(rec.id))
		if row.is_empty():
			continue
		var sim: Dictionary = rec.duplicate()
		sim.level = clampi(int(row.get("level", 1)), 1, 11)
		sim.ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(rec.id), int(sim.level), {})
		sim["weekly"] = row
		out.append(sim)
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		if int(a.level) != int(b.level):
			return int(a.level) > int(b.level)
		if bool(a.owned) != bool(b.owned):
			return bool(a.owned)
		return int(a.id) > int(b.id))
	return out





func info_tank() -> int:
	if _hover.begins_with("tank:"):
		return int(_hover.substr(5))
	if _mobile and _press.begins_with("tank:"):
		return int(_press.substr(5))
	return 0



static func crystal_scheme(tanks: Dictionary, tank: int) -> int:
	var scheme: int = int(best_inst(tanks, tank).get("m_crystalSchemeId", 0))
	return scheme if scheme > 0 else 1


static func best_inst(tanks: Dictionary, tank: int) -> Dictionary:
	var best: Dictionary = {}
	for inst: Dictionary in tanks.values():
		if tank <= 0 or int(inst.get("m_tpltId", 0)) != tank:
			continue
		var level: int = int(inst.get("m_level", 1))
		if best.is_empty() or int(best.get("m_level", 1)) < level\
		or (int(best.get("m_level", 1)) == level and int(inst.get("m_contType", 0)) < int(best.get("m_contType", 0))):
			best = inst
	return best


static func scheme_name(names: Dictionary, scheme: int) -> String:
	var custom: String = str(names.get(scheme, "")).strip_edges()
	if not custom.is_empty():
		return custom
	if scheme >= 1 and scheme <= CRYSTAL_DEFAULT.size():
		return str(CRYSTAL_DEFAULT[scheme - 1])
	return CRYSTAL_CUSTOM % scheme



static func crystal_text(names: Dictionary, scheme: int) -> String:
	var ids: Array = names.keys().map( func(key: Variant) -> int: return int(key))
	ids.sort()
	if scheme < 1 or scheme > ids.size():
		return Atlas.NO_CRYSTAL
	return scheme_name(names, int(ids[scheme - 1]))


static func music_for(game: Object) -> String:
	if game == null or game.pair_scene.is_empty() or not (game.state in SHOW_IN):
		return ""
	return MUSIC


static func corps_index(slots: Dictionary) -> int:
	var row: Array = slots.get(CORPS_SLOT, [])
	return int(row[0]) if not row.is_empty() and int(row[0]) > 0 else CORPS_DEFAULT


static func corps_level(learned: Dictionary, researched: Dictionary, index: int) -> int:
	var study: int = int(learned.get(index, 0))
	var research: int = int(researched.get(index, 0))
	var level: int = research if study > research else study
	return level if level > 0 else 1


static func corps_skill(guild: Dictionary, index: int, level: int) -> int:
	var pair: Array = guild.get(str(index << 4 | level), [])
	return int(pair[0]) if not pair.is_empty() else 0


static func corps_unused(slots: Dictionary, learned: Dictionary) -> Array:
	var used: Dictionary = {}
	for key: Variant in slots:
		var row: Array = slots[key]
		if not row.is_empty() and int(row[0]) != 0:
			used[int(row[0])] = true
	var list: Array = []
	for key: Variant in learned:
		var level: int = int(learned[key])
		if level < 1 or used.has(int(key)):
			continue
		if corps_kind(int(key), level) in [1, 2]:
			list.append([int(key), level])
	return list


static func corps_kind(index: int, level: int) -> int:
	var info: Array = GuildManage.SKILL_INFO.get(str(corps_pvp(index, level)), [])
	return int(info[2]) if info.size() >= 3 else 0

static func corps_pvp(index: int, level: int) -> int:
	var table: Array = GuildManage.SKILL_TABLE.get(str(index), [])
	var row: Array = table[2].get(str(level), []) if table.size() >= 3 else []
	return int(row[0]) if not row.is_empty() else 0


static func corps_slot(slot: int, kind: int) -> int:
	if slot < 4:
		slot += 4
	if kind == 2:
		return 4
	if kind == 3 and slot == 4:
		return 5
	return slot




static func face_key(garage: Dictionary, defaults: Dictionary, tank: int, level: int, ext: int) -> String:
	if tank <= 0 or garage.is_empty():
		return ""
	var picked: int = ext if ext > 0 else GarageModel.exterior(garage, defaults, tank, maxi(1, level), {})
	var face: String = GarageModel.face(garage, picked)
	if not face.is_empty():
		return face
	face = GarageModel.face(garage, int(defaults.get(str(tank), 0)))
	if not face.is_empty():
		return face
	var rows: Dictionary = garage.get("levels", {}).get(str(tank), {})
	var order: Array = range(mini(level, 11), 0, -1) + range(mini(level, 11) + 1, 12)
	for step: int in order:
		var row: Array = rows.get(str(step), [])
		if row.size() > 10:
			face = GarageModel.face(garage, int(row[10]))
			if not face.is_empty():
				return face
	return ""


func crystal_shown() -> bool:
	return extra_shown() and (int(client.character.get("actionFlag", 0)) & CRYSTAL_OPEN) != 0


func extra_shown() -> bool:
	if client == null or int(pair().get("type", 0)) == GUILD_MATCH:
		return false
	return (int(client.character.get("actionFlag", 0)) & CRYSTAL_OPEN) != 0 or client.talent_open()


func talent_shown() -> bool:
	return extra_shown() and client.talent_open() and client.talent_ready


func talent_inst() -> Dictionary:
	return best_inst(client.tanks, my_tank()) if client != null else {}


func talent_index() -> int:
	for i in range(client.talent_pages.size()):
		if str(client.talent_pages[i].uuid) == talent_uuid:
			return i
	return -1


func _talent_reselect() -> void :
	talent_uuid = str(client.talent_page_of_tank(str(talent_inst().get("m_tankUuid", ""))).get("uuid", ""))



func _tick(_delta: float) -> void :
	if client == null or pair().is_empty() or not extra_shown() or not client.talent_open():
		return
	var tank: int = my_tank()
	if tank != _talent_tank:
		_talent_tank = tank
		_talent_seen = client.talent_rev
		_talent_reselect()
		if client.talent_pages.is_empty():
			client.talent_request_all()
	elif _talent_seen != client.talent_rev:
		_talent_seen = client.talent_rev
		if talent_index() < 0:
			_talent_reselect()
		if client.talent_pages.is_empty():
			talent_drop = false





func lack() -> Array:
	if pack == null or pack.garage.is_empty() or int(client.character.get("level", 0)) < LACK_LEVEL:
		return []
	var mine: Array = sides()[0]
	if mine.size() < LACK_COUNT:
		return []
	var have: Dictionary = {}
	for brief: Dictionary in mine:
		var tank: int = int(_pick(int(brief.charData.nAcctId)).get("tank", 0))
		if tank > 0:
			have[int(pack.garage.get("tanks", {}).get(str(tank), {}).get("cls", 0))] = true
	var out: Array = []
	for cls in range(1, 4):
		if not have.has(cls):
			out.append(Atlas.CLASSES[cls - 1])
	return out



func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))



static func label_place(key: String) -> Vector2:
	var spec: Array = Atlas.TEXT[key]
	if key in CENTRED:
		var high: float = float(spec[4]) + 6.0
		return Vector2(float(spec[1]) - high / 2.0, high)
	return Vector2(float(spec[1]), float(spec[3]))


func _label(key: String, text: String, o: Vector2, color: Color = Color(0, 0, 0, 0), edge: float = 1.0) -> void :
	var spec: Array = Atlas.TEXT[key]
	var wide: float = float(spec[2])
	var x: float = float(spec[0])
	if wide <= 0.0:
		wide = 300.0
		x -= 150.0
	var place: Vector2 = label_place(key)
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), color if color.a > 0.0 else Color(str(spec[5])), 
		str(spec[7]), o + Vector2(x, place.x), wide, edge, place.y)

func _paint() -> void :
	if client == null or pair().is_empty():
		return
	if _cells.is_empty():
		_use(Hall.FILE, Hall.R)
		_use(Atlas.FILE, Atlas.R)
		_use(CHAT_FILE, {"st_chat_bg_open": [0, 0, int(CHAT_OPEN_SIZE.x), int(CHAT_OPEN_SIZE.y)]})
		_use(Corps.FILE, Corps.R)
		_use(Camp.FILE, Camp.R)
		_use(BarAtlas.FILE, {"apt_sb_bk": BarAtlas.R["apt_sb_bk"], "apt_sb_up": BarAtlas.R["apt_sb_up"], 
			"apt_sb_down": BarAtlas.R["apt_sb_down"], "apt_sb_thumb": BarAtlas.R["apt_sb_thumb"]})

	_typing.mouse_filter = Control.MOUSE_FILTER_IGNORE if talent_drop or crystal_drop or corps_open else Control.MOUSE_FILTER_STOP
	_tip_text = ""
	_bars.clear()
	head_shown = []
	draw_rect(Rect2(Vector2.ZERO, size), DIM)

	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	_fblit("st_bg", o + _xy(Atlas.AT.bg))
	_hit("panel", Rect2(o * _f, Vector2(1000, 600) * _f), false)
	var gd_watch: bool = watching()
	_label("_SelectTankFrameNew_Label1", "Đội Xanh" if gd_watch else str(Atlas.TITLE_SELF), o)
	_label("_SelectTankFrameNew_Label2", "Đội Đỏ" if gd_watch else str(Atlas.TITLE_ENEMY), o)
	if round_mode():

		var texts: Array = round_texts()
		if not client.pair_all_locked():
			if client.self_turn():
				_fblit("st_arrow_team", o + _xy(Atlas.AT.imgTeammateArrow))
			else:
				_fblit("st_arrow_enemy", o + _xy(Atlas.AT.imgEnemyArrow))
		_label("lblSelfCountdown", str(texts[0]), o)
		_label("lblEnemyCountdown", str(texts[1]), o)
		_label("lblMidTips", skin_strip.mid_text(self, str(texts[2])), o)
	else:
		_fblit("st_arrow_team", o + _xy(Atlas.AT.imgTeammateArrow))
		_fblit("st_arrow_enemy", o + _xy(Atlas.AT.imgEnemyArrow))
		var left: int = skin_strip.seconds(self)
		var clock: String = str(left) if left > 0 else str(Atlas.TIP_10)
		_label("lblSelfCountdown", clock, o)
		_label("lblEnemyCountdown", clock, o)
		_label("lblMidTips", skin_strip.mid_text(self, str(Atlas.MID_TIPS)), o)
	var both: Array = sides()
	for i in range(5):
		_seat(o + _xy(Atlas.AT["frmSelf%d" % (i + 1)]), both[0][i] if i < both[0].size() else {}, true)
		_seat(o + _xy(Atlas.AT["frmEnemy%d" % (i + 1)]), both[1][i] if i < both[1].size() else {}, false)
	if not skin_strip.paint(self, o):
		if gd_watch:
			var gd_box: Array = Atlas.LIST
			_fwords("Đang quan sát", ARIAL_BOLD, 24.0, Color("ffff00"), "c", o + Vector2(float(gd_box[0]), float(gd_box[1])), float(gd_box[2]), 1.0, float(gd_box[3]))
		else:
			_filters(o)
			_tiles(o)
	_camp(o)
	var missing: Array = [] if gd_watch else lack()
	if not missing.is_empty():
		_label("lblLackTankClassification1", str(Atlas.TIP_666), o)
		_label("lblLackTankClassification2", "、".join(missing), o)
	_bottom(o)
	if not skin_strip.info(self, o):
		_info(o)
	_draw_voice(o)
	_corps_pick(o)
	_talent_list(o)
	_crystal_list(o)
	_weekly_tip()
	_corps_tip(o)




func camp_side() -> String:
	if not round_mode() or client.pair_all_locked():
		return ""
	return "blue" if client.self_turn() else "red"

static func camp_frame(msec: int) -> int:
	return int(floori(msec * Camp.FPS / 1000.0)) % Camp.FRAMES["blue"].size()

func _camp(o: Vector2) -> void :
	var side: String = camp_side()
	if side.is_empty():
		return
	var at: Vector2 = o + _xy(Camp.AT[side])
	for layer: Array in Camp.FRAMES[side][camp_frame(Time.get_ticks_msec())]:
		var tint: Color = Color(float(layer[5]) + float(layer[9]) / 255.0, float(layer[6]) + float(layer[10]) / 255.0, 
			float(layer[7]) + float(layer[11]) / 255.0, clampf(float(layer[8]) + float(layer[12]) / 255.0, 0.0, 1.0))
		if tint.a <= 0.002:
			continue
		var cell: Vector2 = _cell_size(str(layer[0]))
		_fblit(str(layer[0]), at + Vector2(float(layer[1]), float(layer[2])), cell.x * float(layer[3]), cell.y * float(layer[4]), tint)





func _seat_watch(at: Vector2, brief: Dictionary) -> void :
	_fblit("st_grid_empty", at)
	if brief.is_empty():
		return
	var oid: int = int(brief.charData.nAcctId)
	var pick: Dictionary = _pick(oid)
	if int(pick.get("frame", 0)) != 0:
		_fblit("st_grid_frame", at + _xy(Atlas.GRID_AT.imgSkinFrameRed))
	_head(at, int(pick.get("tank", 0)), int(pick.get("ext", 0)), int(pick.get("level", 1)), false)
	var who: String = str(brief.charData.get("szName", ""))
	var style: Array = HallScreen.name_style(HallScreen.vip_of(brief.charData))
	if NameStyles.paint(self, who, ARIAL_BOLD, 13.0, "c", at + Vector2(0, 74), GRID.x, 1.0):
		style = [Color(0, 0, 0, 0), Color(0, 0, 0, 0)]
	_fwords(who, ARIAL_BOLD, 13.0, style[0], "c", at + Vector2(0, 74), GRID.x, 1.0, 0.0, true, style[1])
	if locked(oid):
		_fblit("st_grid_cover", at + _xy(Atlas.GRID_AT.cover))



func _seat(at: Vector2, brief: Dictionary, mine: bool) -> void :
	if not mine and watching():
		_seat_watch(at, brief)
		return
	if brief.is_empty():
		if mine and int(pair().get("type", 0)) == ROOM_HAPPY:
			return
		_fblit(("st_grid_blue" if watching() else "st_grid_empty") if mine else "st_grid_unknow", at)
		if not mine:
			_fwords("???", ARIAL_BOLD, 13.0, Color.WHITE, "c", at + Vector2(0, 74), GRID.x, 1.0)
		return
	var oid: int = int(brief.charData.nAcctId)
	if not mine and ranked_cells():


		_fblit("st_grid_empty", at)
		var live: Dictionary = _pick(oid)
		if int(live.get("frame", 0)) != 0:
			_fblit("st_grid_frame", at + _xy(Atlas.GRID_AT.imgSkinFrameRed))
		var seen: Dictionary = pair().get("shown", {}).get(oid, {})
		_head(at, int(seen.get("tank", 0)), int(seen.get("ext", 0)), int(seen.get("level", 1)), false)
		var colour: Array = HallScreen.name_style(HallScreen.vip_of(brief.charData))
		_fwords(ROUND_PLAYER + str(enemy_seat(oid) + 1), ARIAL_BOLD, 13.0, colour[0], "c", at + Vector2(0, 74), GRID.x, 1.0, 0.0, true, colour[1])
		if locked(oid):
			_fblit("st_grid_cover", at + _xy(Atlas.GRID_AT.cover))
		return
	if not mine:
		_fblit("st_grid_unknow", at)
		_fwords("???", ARIAL_BOLD, 13.0, Color.WHITE, "c", at + Vector2(0, 74), GRID.x, 1.0)
		if locked(oid):
			_fblit("st_grid_cover", at + _xy(Atlas.GRID_AT.cover))
		return
	_fblit("st_grid_self" if oid == client.account_oid else "st_grid_blue", at)
	var pick: Dictionary = _pick(oid)
	if int(pick.get("frame", 0)) != 0:
		_fblit("st_grid_frame", at + _xy(Atlas.GRID_AT.imgSkinFrame))
	_head(at, int(pick.get("tank", 0)), int(pick.get("ext", 0)), int(pick.get("level", 1)))



	if not name_shown(oid):
		var plain: Array = HallScreen.name_style(0)
		_fwords("???", ARIAL_BOLD, 13.0, plain[0], "c", at + Vector2(0, 74), GRID.x, 1.0, 0.0, true, plain[1])
		if locked(oid):
			_fblit("st_grid_cover", at + _xy(Atlas.GRID_AT.cover))
		return
	var who: String = str(brief.charData.get("szName", ""))
	var style: Array = HallScreen.name_style(HallScreen.vip_of(brief.charData))
	if NameStyles.paint(self, who, ARIAL_BOLD, 13.0, "c", at + Vector2(0, 74), GRID.x, 1.0):
		style = [Color(0, 0, 0, 0), Color(0, 0, 0, 0)]
	_fwords(who, ARIAL_BOLD, 13.0, style[0], "c", at + Vector2(0, 74), GRID.x, 1.0, 0.0, true, style[1])
	if locked(oid):
		_fblit("st_grid_cover", at + _xy(Atlas.GRID_AT.cover))



func _stand_in(tank: int, ext: int, mid: Vector2, zoom: float, wide: float) -> void :
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tank)) if pack.state == "ready" else {}
	if TankPreview.ready(art):
		var scale: float = minf(1.5 * zoom, SPRITE_ROOM * zoom / maxf(1.0, TankPreview.extent(art)))
		TankPreview.draw(self, art, (mid + Vector2(0, 16.0 * zoom)) * _f, scale * _f, 4, _time)
		return
	var title: String = str(pack.lobby.get("tanks", {}).get(str(tank), ""))
	if not title.is_empty():
		_fwords(title, ARIAL_BOLD, 13.0, Color.WHITE, "c", mid - Vector2(wide / 2.0, 11.0), wide, 1.0, 22.0)




func name_shown(oid: int) -> bool:
	if client == null:
		return true
	var kind: int = int(pair().get("type", 0))
	var mates: Dictionary = pair().get("mates", {})

	return watching() or kind == ROOM_PVP or kind == FREE_ROOM or oid == client.account_oid or client.room_state.members.has(oid) or mates.has(oid)



func _head(at: Vector2, tank: int, ext: int, level: int, flip: bool = true) -> void :
	if tank <= 0 or pack == null or pack.garage.is_empty():
		return
	var face: String = face_key(pack.garage, pack.index.get("tanks", {}), tank, level, ext)
	if face.is_empty():
		_stand_in(tank, ext, at + Vector2(GRID.x / 2.0, 36.0), 0.4, GRID.x - 8.0)
		return
	var frame: Rect2 = Rect2(at + Vector2(HEAD_INSET, HEAD_INSET), GRID - Vector2(HEAD_INSET, HEAD_INSET) * 2.0)
	var box: Rect2 = head_box(face)
	if not box.has_area():
		return
	var fit: Array = fit_head(box, frame)
	var centre: Vector2 = fit[0]
	var zoom: float = fit[1]
	var drawn: Rect2 = Rect2(centre + (box.position - Vector2(TankPortrait.BOX, TankPortrait.BOX) * 0.5) * zoom, box.size * zoom)
	if flip:
		drawn.position.x = 2.0 * at.x + GRID.x - drawn.end.x
	head_shown.append({"tank": tank, "face": face, "box": box, "rect": drawn, "frame": frame, "flip": flip})
	var clip: Rect2 = Rect2(frame.position * _f, frame.size * _f)
	if flip:
		draw_set_transform(Vector2((2.0 * at.x + GRID.x) * _f, 0), 0.0, Vector2(-1, 1))
		clip.position.x = (2.0 * at.x + GRID.x) * _f - clip.end.x
	TankPortrait.draw(self, pack, face, 0, centre * _f, zoom * _f, _time, "l/t", true, clip)
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)



func head_box(face: String) -> Rect2:
	if _boxes.has(face):
		return _boxes[face]
	var film: Array = TankPortrait.movie(pack.garage, face)
	var picture: Texture2D = pack.picture("l/t/%s.webp" % face)
	if picture != null:
		var box: Rect2 = used_box(picture.get_image(), TankPortrait.still_rect(film, Vector2.ZERO, 1.0, TankPortrait.side(pack.garage, face)))
		if box.has_area():
			_boxes[face] = box
			return box
	if film.is_empty():
		return Rect2()
	var part: Dictionary = pack.effect_cached(str(film[0]))
	if part.is_empty() or part.data.frames.is_empty():
		pack.effect(str(film[0]))
		return Rect2()
	var first: Dictionary = part.data.frames[0]

	var shrink: float = TankPortrait.fit(film)
	var mid: Vector2 = Vector2(TankPortrait.BOX, TankPortrait.BOX) * 0.5
	return Rect2(mid + (TankPortrait.movie_origin(film) - Vector2(float(first.pivot[0]), float(first.pivot[1])) - mid) * shrink, 
		Vector2(float(first.rect[2]), float(first.rect[3])) * shrink)




static func used_box(image: Image, spot: Rect2) -> Rect2:
	if image == null or image.is_empty() or not spot.has_area():
		return Rect2()
	var small: Image = image.duplicate()
	if small.is_compressed():
		small.decompress()
	small.convert(Image.FORMAT_RGBA8)
	if small.get_width() > HEAD_SCAN or small.get_height() > HEAD_SCAN:
		small.resize(mini(small.get_width(), HEAD_SCAN), mini(small.get_height(), HEAD_SCAN), Image.INTERPOLATE_BILINEAR)
	var w: int = small.get_width()
	var h: int = small.get_height()
	var data: PackedByteArray = small.get_data()
	var cols: PackedFloat32Array = PackedFloat32Array()
	var rows: PackedFloat32Array = PackedFloat32Array()
	cols.resize(w)
	rows.resize(h)
	var total: float = 0.0
	for y in range(h):
		var at: int = y * w * 4 + 3
		for x in range(w):
			var alpha: int = data[at + x * 4]
			if alpha > HEAD_ALPHA:
				cols[x] += alpha
				rows[y] += alpha
				total += alpha
	if total <= 0.0:
		return Rect2()
	var across: Vector2i = _span(cols, total * HEAD_TRIM)
	var down: Vector2i = _span(rows, total * HEAD_TRIM)
	var ratio: Vector2 = spot.size / Vector2(w, h)
	return Rect2(spot.position + Vector2(across.x, down.x) * ratio, Vector2(across.y - across.x + 1, down.y - down.x + 1) * ratio)


static func _span(sums: PackedFloat32Array, cut: float) -> Vector2i:
	var low: int = 0
	var run: float = 0.0
	for i in range(sums.size()):
		run += sums[i]
		if run > cut:
			low = i
			break
	var high: int = sums.size() - 1
	run = 0.0
	for i in range(sums.size() - 1, -1, -1):
		run += sums[i]
		if run > cut:
			high = i
			break
	return Vector2i(low, maxi(low, high))


static func fit_head(box: Rect2, frame: Rect2) -> Array:
	if not box.has_area() or not frame.has_area():
		return [frame.get_center(), 0.0]
	var zoom: float = minf(frame.size.x / box.size.x, frame.size.y / box.size.y)
	return [frame.get_center() - (box.get_center() - Vector2(TankPortrait.BOX, TankPortrait.BOX) * 0.5) * zoom, zoom]

func _filters(o: Vector2) -> void :
	for i in range(4):
		var name: String = str(FILTER_CELLS[i]) + ("_on" if _filter == i else "")
		_fbutton("filter:%d" % i, name, o + _xy(Atlas.AT[FILTERS[i]]))


func _tiles(o: Vector2) -> void :
	var box: Array = Atlas.LIST
	var list: Array = grid_list()
	_scroll = clampi(_scroll, 0, maxi(0, ceili(list.size() / float(Atlas.COLS)) - ROWS))
	_hit("list", Rect2((o + Vector2(float(box[0]), float(box[1]))) * _f, Vector2(float(box[2]), float(box[3])) * _f), false)
	if not _cells.has(SKIN_ORANGE):
		_use(SKIN_ORANGE_FILE, {SKIN_ORANGE: [0, 0, 96, 96]})
	tiles_shown.clear()
	var mine: int = my_tank()
	var kind: int = int(pair().get("type", 0))
	var mates: Array = tile_mates()
	var best: Dictionary = tile_insts(client.tanks)
	var known: Dictionary = pack.fx.get("halo_ui", {})
	for index in range(_scroll * Atlas.COLS, mini(list.size(), (_scroll + ROWS) * Atlas.COLS)):
		var rec: Dictionary = list[index]
		var slot: int = index - _scroll * Atlas.COLS
		var at: Vector2 = o + Vector2(float(box[0]), float(box[1])) + Vector2(slot % Atlas.COLS, floori(slot / float(Atlas.COLS))) * PITCH + Vector2(2, 2)
		var id: String = "tank:%d" % int(rec.id)
		var inst: Dictionary = {} if rec.has("weekly") or rec.has("cont") else best.get(int(rec.id), {})
		var cont: int = int(rec.get("cont", inst.get("m_contType", -1)))
		var state: String = tile_state(kind, int(rec.id), cont, mine, mates)
		var dim: bool = state == "unSelectable"
		var bg: String = "st_tile_on" if state == "select" else "st_tile"
		_fblit(_tile_grey_cell(bg) if dim or state == "notHave" else bg, at, 0.0, 0.0, _glow(id))
		var frame: String = str(SKIN_FRAMES.get(int(inst.get("m_skinFrameType", 0)), ""))
		if not frame.is_empty():
			_fblit(_tile_grey_cell(frame) if dim else frame, at)
		var face: String = face_key(pack.garage, pack.index.get("tanks", {}), int(rec.id), int(rec.level), int(rec.ext))
		var film: Array = TankPortrait.movie(pack.garage, face) if not face.is_empty() else []
		var still: Texture2D = _tile_grey_face(face) if dim else null
		var picture: Texture2D = still if dim else (pack.picture("l/t/%s.webp" % face) if film.is_empty() and not face.is_empty() else null)
		var grow: float = tile_grow(film, picture, (pack.garage.get("t300", []) as Array).has(face))
		var item: int = 0 if dim else TankPortrait.halo_item(known, int(inst.get("m_haloId", 0)), int(rec.level))
		var drawn: bool = not face.is_empty()
		if not dim or still != null:
			drawn = TankPortrait.draw(self, pack, face, item, (at + Vector2(48, 48)) * _f, TILE_ZOOM * _f, _time, "l/t", true, Rect2(at * _f, Vector2(96, 96) * _f), grow, still)
		if not drawn:
			_stand_in(int(rec.id), int(rec.ext), at + Vector2(48, 48), TILE_ZOOM, 92.0)
		if state != "notHave" and not dim:
			_fmid("tklv_%d" % clampi(int(rec.level), 1, 11), at + Vector2(0, float(Atlas.TILE_AT.imgTankLv[1])), 96.0)
		if rec.has("weekly"):
			_weekly_badge(at, rec.weekly, id)
		_hit(id, Rect2(at * _f, Vector2(96, 96) * _f), false)
		if state == "notHave":

			_fbutton("rent:%d" % int(rec.id), "st_rent", at + _xy(Atlas.TILE_AT.btnRent))
		tiles_shown.append({"tank": int(rec.id), "state": state, "frame": frame, "halo": item, "grow": grow, "cont": cont, "grey": dim and still != null})

	var lines: int = ceili(list.size() / float(Atlas.COLS))
	_vbar("tank", o + Vector2(float(box[0] + box[2]) - BAR, float(box[1])), float(box[3]), _scroll, ROWS, lines, 
		func(value: float) -> void : _scroll = clampi(roundi(value), 0, maxi(0, lines - ROWS)))







const TILE_ZOOM: float = 0.48


const TILE_SPAN: float = 273.0
const SKIN_ORANGE: String = "st_tile_frame_2"
const SKIN_ORANGE_FILE: String = "res://assets/ui/hall/selecttank_skin_orange.png"
const SKIN_FRAMES: Dictionary = {1: "st_tile_frame", 2: SKIN_ORANGE}
const NOT_HAVE: int = 7
const HIRE_OPEN: int = 256
const NOT_HAVE_TYPES: Array = [1, 2, 11, 16, 17, 18, 19, 100, 101]
const LADDER_STATE: Array = [5, 6, 9, 11, 15]
const TILE_GREY: Vector3 = Vector3(0.3086, 0.6094, 0.082)
const TILE_GREY_KEEP: int = 24

var tiles_shown: Array = []
var _tile_greys: Dictionary = {}




func grid_list() -> Array:
	var out: Array = tank_list()
	if pack == null or pack.garage.is_empty() or int(pair().get("type", 0)) not in NOT_HAVE_TYPES:
		return out
	if (int(client.character.get("setting_flag", 0)) & HIRE_OPEN) == 0:
		return out
	var rents: Dictionary = tile_rent_ids()
	if rents.is_empty():
		return out
	var shown: Dictionary = {}
	for rec: Dictionary in out:
		shown[int(rec.id)] = true
	var added: bool = false
	for rec: Dictionary in GarageModel.roster(client.tanks, pack.garage, pack.lobby.get("tanks", {}), pack.index.get("tanks", {}), int(Time.get_unix_time_from_system())):
		if shown.has(int(rec.id)) or not rents.has(int(rec.id)) or (_filter != 0 and int(rec.cls) != _filter):
			continue
		var sim: Dictionary = rec.duplicate()
		sim.level = 1
		sim.inst = {}
		sim.ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(rec.id), 1, {})
		sim["cont"] = NOT_HAVE
		out.append(sim)
		added = true
	if added:
		out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return tile_before(a, b))
	return out



func tile_rent_ids() -> Dictionary:
	var rows: Variant = client.tank_rents if client.tank_rent_got else pack.garagex.get("rent", [])
	var out: Dictionary = {}
	if rows is Array:
		for row: Variant in rows:
			if row is Dictionary and int(row.get("tank_id", 0)) > 0:
				out[int(row.tank_id)] = true
	return out


func tile_mates() -> Array:
	var out: Array = []
	for brief: Dictionary in sides()[0]:
		var oid: int = int(brief.charData.nAcctId)
		var tank: int = int(_pick(oid).get("tank", 0))
		if oid != client.account_oid and tank > 0:
			out.append(tank)
	return out



static func tile_state(kind: int, tank: int, cont: int, mine: int, mates: Array) -> String:
	if tank == mine:
		return "select"
	if kind in LADDER_STATE and mates.has(tank):
		return "unSelectable"
	if cont == NOT_HAVE:
		return "notHave"
	return ""


static func tile_insts(tanks: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for inst: Variant in tanks.values():
		if not inst is Dictionary:
			continue
		var id: int = int(inst.get("m_tpltId", 0))
		var had: Dictionary = out.get(id, {})
		var level: int = int(inst.get("m_level", 1))
		var top: int = int(had.get("m_level", 1))
		if had.is_empty() or level > top or (level == top and int(inst.get("m_contType", 0)) < int(had.get("m_contType", 0))):
			out[id] = inst
	return out


static func tile_before(a: Dictionary, b: Dictionary) -> bool:
	if int(a.level) != int(b.level):
		return int(a.level) > int(b.level)
	if bool(a.owned) != bool(b.owned):
		return bool(a.owned)
	return int(a.id) > int(b.id)



static func tile_grow(film: Array, picture: Texture2D, legacy: bool = false) -> float:
	if not film.is_empty() or picture == null or not legacy:
		return 1.0
	return TILE_SPAN / TankPortrait.BOX


func _tile_grey_cell(name: String) -> String:
	var key: String = name + "~grey"
	if _cells.has(key):
		return key
	var cell: Array = _cells.get(name, [])
	if cell.is_empty() or cell[0] == null:
		return name
	var region: Array = cell[1]
	var image: Image = (cell[0] as Texture2D).get_image()
	if image == null or image.is_empty():
		_cells[key] = cell
		return key
	image = image.duplicate()
	if image.is_compressed():
		image.decompress()
	image.clear_mipmaps()
	var part: Image = image.get_region(Rect2i(int(region[0]), int(region[1]), int(region[2]), int(region[3])))
	_cells[key] = [ImageTexture.create_from_image(tile_grey_image(part)), [0, 0, int(region[2]), int(region[3])]]
	return key


func _tile_grey_face(face: String) -> Texture2D:
	if face.is_empty() or pack == null:
		return null
	if _tile_greys.has(face):
		return _tile_greys[face]
	var picture: Texture2D = pack.picture("l/t/%s.webp" % face)
	if picture == null:
		return null
	var image: Image = picture.get_image()
	if image == null or image.is_empty():
		return null
	if _tile_greys.size() >= TILE_GREY_KEEP:
		_tile_greys.clear()
	var out: ImageTexture = ImageTexture.create_from_image(tile_grey_image(image))
	_tile_greys[face] = out
	return out


static func tile_grey_image(source: Image) -> Image:
	var image: Image = source.duplicate()
	if image.is_compressed():
		image.decompress()
	image.clear_mipmaps()
	image.convert(Image.FORMAT_RGBA8)
	var data: PackedByteArray = image.get_data()
	for i: int in range(0, data.size(), 4):
		var lum: int = clampi(roundi(data[i] * TILE_GREY.x + data[i + 1] * TILE_GREY.y + data[i + 2] * TILE_GREY.z), 0, 255)
		data[i] = lum
		data[i + 1] = lum
		data[i + 2] = lum
	return Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data)



func _weekly_badge(at: Vector2, row: Dictionary, id: String) -> void :
	var vip: int = int(row.get("vipMin", 0))
	draw_rect(Rect2((at + Vector2(2, 0)) * _f, Vector2(92, 21) * _f), WEEKLY_BG)
	_fwords(WEEKLY_VIP if vip > 0 else WEEKLY_FREE, ARIAL_BOLD, 10.0, Color.WHITE, "c", at + Vector2(2, 0), 92.0)
	if _hover == id:
		_tip_text = WEEKLY_VIP_TIP % vip if vip > 0 else WEEKLY_FREE_TIP
		_tip_spot = at + Vector2(2, 23)

func _weekly_tip() -> void :
	if _tip_text.is_empty():
		return
	var wide: float = _face(ARIAL).get_string_size(_tip_text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(12.0 * _f))).x / _f + 16.0
	_round(Rect2(_tip_spot * _f, Vector2(wide, 22) * _f), Color(0, 0, 0, 0.86), 4.0, Color("6fd0ff", 0.55), 1.0)
	_fwords(_tip_text, ARIAL, 12.0, Color.WHITE, "l", _tip_spot + Vector2(8, 0), wide - 16.0, 0.0, 22.0, false)


func _corps(o: Vector2) -> void :
	corps_shown = 0
	if pack == null:
		return
	if pack.gda_loading.is_empty():
		pack.load_gda_loading()
		return
	var index: int = corps_index(client.guild_skill_slots)
	var skill: int = corps_skill(pack.gda_loading.get("guild", {}), index, corps_level(client.guild_skill_self, client.guild_skill_corps, index))
	if skill <= 0:
		return
	corps_shown = skill
	var row: Array = pack.skill_hud(skill)
	var icon: Texture2D = pack.icon("s", str(row[0])) if not row.is_empty() else null
	if icon != null:
		var spot: Rect2 = Rect2((o + _xy(Atlas.AT.gridCorpsSkill)) * _f, Vector2(50, 50) * _f)
		draw_texture_rect(icon, spot, false, Color(1.25, 1.25, 1.25) if _hover == "corps" else Color.WHITE)


func _corps_tip(o: Vector2) -> void :
	corps_tip = ""
	if pack == null:
		return
	var skill: int = corps_shown if _hover == "corps" else 0
	var anchor: Vector2 = o + _xy(Atlas.AT.gridCorpsSkill)
	if corps_open and _hover.begins_with("cs_pick:"):
		var i: int = int(_hover.substr(8))
		if i >= 0 and i < corps_list.size():
			skill = corps_pvp(int(corps_list[i][0]), int(corps_list[i][1]))
			anchor = _corps_cell(o, i)
	if skill <= 0:
		return
	var info: Array = pack.gda_loading.get("skill", {}).get(str(skill), [])
	if info.is_empty():
		return
	corps_tip = str(info[0])
	var desc: String = str(info[1]) if info.size() >= 2 else ""
	var px: int = maxi(6, roundi(12.0 * _f))
	var lines: float = 0.0
	if not desc.is_empty():
		lines = _face(ARIAL).get_multiline_string_size(desc, HORIZONTAL_ALIGNMENT_LEFT, (CORPS_TIP_WIDE - 16.0) * _f, px).y / _f
	var high: float = 30.0 + lines + (6.0 if lines > 0.0 else 0.0)
	var at: Vector2 = anchor + Vector2(0, -4.0 - high)
	_round(Rect2(at * _f, Vector2(CORPS_TIP_WIDE, high) * _f), Color(0, 0, 0, 0.86), 4.0, Color("6fd0ff", 0.55), 1.0)
	_fwords(str(info[0]), ARIAL_BOLD, 13.0, Color("ffd36a"), "l", at + Vector2(8, 4), CORPS_TIP_WIDE - 16.0, 0.0, 22.0)
	if not desc.is_empty():
		_fpara(desc, ARIAL, 12.0, Color.WHITE, at + Vector2(8, 28), CORPS_TIP_WIDE - 16.0)


func _corps_cell(o: Vector2, i: int) -> Vector2:
	var row: int = i / CORPS_COLS - _corps_first
	return o + _xy(Corps.FRAME) + Vector2(float(Corps.LIST[0] + (i % CORPS_COLS) * Corps.CELL), float(Corps.LIST[1] + Corps.PAD_TOP + row * Corps.CELL))



func _corps_pick(o: Vector2) -> void :
	if not corps_open:
		return
	var frame: Vector2 = o + _xy(Corps.FRAME)
	_fblit("cs_box", frame + _xy(Corps.BOX_AT))
	_hit("cs_box", Rect2((frame + _xy(Corps.BOX_AT)) * _f, _cell_size("cs_box") * _f), false)
	if corps_list.is_empty():
		var tip: Array = Corps.TEXT.lblNoSkillTip
		_fwords(str(Corps.NO_SKILL), ARIAL_BOLD, float(tip[4]), Color(str(tip[5])), str(tip[7]), frame + Vector2(float(tip[0]), float(tip[1])), 
			float(tip[2]), 2.0, 0.0, true, CORPS_NO_SKILL_GLOW)
		return
	_corps_first = clampi(_corps_first, 0, _corps_most())
	for i in range(corps_list.size()):
		var row: int = i / CORPS_COLS - _corps_first
		if row < 0 or row >= CORPS_ROWS:
			continue
		var rect: Rect2 = Rect2(_corps_cell(o, i) * _f, Vector2(50, 50) * _f)
		var hud: Array = pack.skill_hud(corps_pvp(int(corps_list[i][0]), int(corps_list[i][1]))) if pack != null else []
		var icon: Texture2D = pack.icon("s", str(hud[0])) if not hud.is_empty() else null
		var id: String = "cs_pick:%d" % i
		if icon != null:
			draw_texture_rect(icon, rect, false, Color(1.25, 1.25, 1.25) if _hover == id else Color.WHITE)
		_hit(id, rect, false)
	var lines: int = ceili(float(corps_list.size()) / float(CORPS_COLS))
	_vbar("cs", frame + Vector2(float(Corps.LIST[0] + Corps.LIST[2]) - BAR, float(Corps.LIST[1])), float(Corps.LIST[3]), _corps_first, CORPS_ROWS, lines, 
		func(value: float) -> void : _corps_first = clampi(roundi(value), 0, _corps_most()))

func _corps_most() -> int:
	return maxi(0, ceili(float(corps_list.size()) / float(CORPS_COLS)) - CORPS_ROWS)


func corps_show() -> void :
	corps_list = corps_unused(client.guild_skill_slots, client.guild_skill_self)
	_corps_first = 0
	corps_open = true


func _corps_choose(i: int) -> void :
	corps_open = false
	if i < 0 or i >= corps_list.size():
		return
	var id: int = int(corps_list[i][0])
	var level: int = int(corps_list[i][1])
	client.guild_skill_set(id, level, corps_slot(CORPS_SLOT, corps_kind(id, level)))





const MAP_MEDIUM: Array = [80, 81]



static func map_icon_path(map: int) -> String:
	if MAP_MEDIUM.has(map):
		return "l/map/m%d.webp" % map
	if MAP_MINI.has(map):
		return "l/map/mini%d.webp" % map
	return "l/map/s%d.webp" % map if Seats.SMALLS.has(map) else ""





const MAP_BAKED: Array = [30, 40, 333, 334]
const MAP_MINI: Array = [1201, 1202]







const MAP_STRIPS: Array = [1, 4, 7, 9, 10, 12, 14, 17, 18, 19, 20, 21, 30, 34, 35, 36, 37, 40, 50, 70, 130, 169, 170, 333, 334, 1201, 1202]

static func map_strip_path(map: int) -> String:
	return "l/map/m%d.webp" % map if MAP_STRIPS.has(map) else ""


static func map_icon_region(map: int, size: Vector2, cell: Vector2) -> Rect2:
	if MAP_MINI.has(map):
		var high: float = size.x * cell.y / cell.x
		return Rect2(0.0, floorf((size.y - high) / 2.0), size.x, high)
	var scale: float = size.x / 168.0
	var corner: Vector2 = ((Vector2(168, 100) - cell) / 2.0).floor()
	if MAP_BAKED.has(map):
		corner.y = 0.0
	return Rect2(corner * scale, cell * scale)


func _bottom(o: Vector2) -> void :
	_fblit("st_attr", o + _xy(Atlas.AT.attr))
	var map: int = int(pair().get("map", 0))
	var spot: Array = Atlas.AT.imgMap
	var strip: Texture2D = pack.picture(map_strip_path(map)) if pack != null and MAP_STRIPS.has(map) else null
	var path: String = map_icon_path(map)
	var picture: Texture2D = pack.picture(path) if pack != null and not path.is_empty() and strip == null else null
	if strip != null:
		draw_texture_rect(strip, Rect2((o + _xy(spot)) * _f, Vector2(float(spot[2]), float(spot[3])) * _f), false)
	elif picture != null and MAP_MEDIUM.has(map):
		draw_texture_rect(picture, Rect2((o + _xy(spot)) * _f, Vector2(float(spot[2]), float(spot[3])) * _f), false)
	elif picture != null:
		var cut: Vector2 = Vector2(float(spot[2]), float(spot[3]))
		draw_texture_rect_region(picture, Rect2((o + _xy(spot)) * _f, cut * _f), map_icon_region(map, picture.get_size(), cut))
	elif map > 0:
		draw_rect(Rect2((o + _xy(spot)) * _f, Vector2(float(spot[2]), float(spot[3])) * _f), Color("0b2c4f"))
	_fblit("st_map_cover", o + _xy(Atlas.AT.map_cover))
	if watching():
		corps_shown = 0
		corps_open = false
	else:
		_corps(o)
		if client.guild.is_empty():
			_fblit("st_lock", o + _xy(Atlas.AT.imgCorpsSkillLocked))
		_hit("corps", Rect2((o + _xy(Atlas.AT.gridCorpsSkill)) * _f, Vector2(50, 50) * _f), false)
		_fbutton("switch", "st_switch", o + _xy(Atlas.AT.btnSwitchSkill))

	crystal_label = ""
	talent_label = ""
	if extra_shown():
		_fblit("st_x_bg", o + _xy(Atlas.AT.x_bg))
	if crystal_shown():
		_fblit("st_x_crystal", o + _xy(Atlas.AT.imgCrystalTitle))
		crystal_label = crystal_text(client.crystal_names, crystal_index() + 1)
		_halo_combo(o, "cbCrystal", crystal_label, "crystal", crystal_drop)
		_fbutton("edit_crystal", "st_edit_talent", o + CRYSTAL_EDIT)
	else:
		crystal_drop = false
	if talent_shown():
		_fblit("st_x_talent", o + _xy(Atlas.AT.imgTalentTitle))
		var index: int = talent_index()
		talent_label = client.talent_page_name(client.talent_pages[index]) if index >= 0 else str(Atlas.NO_TALENT)
		_halo_combo(o, "cbTalent", talent_label, "talent", talent_drop)
		_fbutton("edit_talent", "st_edit_talent", o + _xy(Atlas.AT.btnEditTalent))
	else:
		talent_drop = false
	if camp() != 0 and not watching():
		_fbutton("confirm", "st_confirm_done" if locked(client.account_oid) else "st_confirm", o + _xy(Atlas.AT.btnConfirm))
	_chat(o)



func _halo_combo(o: Vector2, key: String, text: String, id: String, open: bool) -> void :
	var spec: Array = Atlas.AT[key]
	var box: Rect2 = Rect2(o + _xy(spec), Vector2(float(spec[2]), float(spec[3])))
	var rect: Rect2 = Rect2(box.position * _f, box.size * _f)
	if _hover == id or open:
		_grad(rect, HALO_BOTTOM, HALO_BOTTOM, HALO_EDGE, 3.0, 1.0)
	else:
		_grad(rect, HALO_TOP, HALO_BOTTOM, HALO_EDGE, 3.0, 1.0)
	var split: float = box.end.x - 22.0
	draw_line(Vector2(split, box.position.y + 4.0) * _f, Vector2(split, box.end.y - 4.0) * _f, HALO_EDGE, maxf(1.0, _f))
	var mid: float = box.position.y + box.size.y / 2.0
	var right: float = box.end.x
	draw_colored_polygon(PackedVector2Array([Vector2(right - 15.0, mid - 2.0) * _f, Vector2(right - 8.0, mid - 2.0) * _f, 
		Vector2(right - 11.5, mid + 3.0) * _f]), Color.WHITE)
	_fwords(text, ARIAL_BOLD, 12.0, Color.WHITE, "l", box.position + Vector2(5, 0), box.size.x - 29.0, 0.0, box.size.y, false)
	_hit(id, rect, false)



func _talent_list(o: Vector2) -> void :
	if not talent_drop or not talent_shown():
		talent_drop = false
		return
	var pages: Array = client.talent_pages
	var shown: int = mini(pages.size(), TALENT_SHOWN)
	if shown <= 0:
		talent_drop = false
		return
	_talent_first = clampi(_talent_first, 0, pages.size() - shown)
	var spec: Array = Atlas.AT.cbTalent
	var box: Rect2 = Rect2(o + _xy(spec), Vector2(float(spec[2]), float(spec[3])))
	var high: float = TALENT_ROW * shown
	var top: Vector2 = Vector2(box.position.x, box.end.y)
	if top.y + high > _fh:
		top.y = box.position.y - high
	var area: Rect2 = Rect2(top * _f, Vector2(box.size.x, high) * _f)
	draw_rect(Rect2((top + Vector2(2, 2)) * _f, area.size), Color(0, 0, 0, 0.25))
	draw_rect(area, HALO_FILL)
	_hit("tl_drop", area, false)
	var index: int = talent_index()
	for k in range(shown):
		var j: int = _talent_first + k
		var line: Rect2 = Rect2((top + Vector2(0, TALENT_ROW * k)) * _f, Vector2(box.size.x, TALENT_ROW) * _f)
		var id: String = "tl_pick:%d" % j
		if j == index:
			draw_rect(line, HALO_PICKED)
		elif _hover == id:
			draw_rect(line, HALO_OVER)
		_fwords(client.talent_page_name(pages[j]), ARIAL_BOLD, 12.0, Color.WHITE, "l", top + Vector2(5, TALENT_ROW * k), box.size.x - 7.0 - (BAR if pages.size() > shown else 0.0), 0.0, TALENT_ROW, false)
		_hit(id, line, false)
	var most_tl: int = pages.size() - shown
	_vbar("tl", top + Vector2(box.size.x - BAR, 0), high, _talent_first, shown, pages.size(), 
		func(value: float) -> void : _talent_first = clampi(roundi(value), 0, most_tl))


func _talent_choose(i: int) -> void :
	talent_drop = false
	if i < 0 or i >= client.talent_pages.size():
		return
	var uuid: String = str(client.talent_pages[i].uuid)
	if uuid == talent_uuid:
		return
	talent_uuid = uuid
	client.talent_op(client.TALENT_OP_SET_CUR, uuid, str(talent_inst().get("m_tankUuid", "")))


func crystal_count() -> int:
	return client.crystal_names.size() if client != null else 0


func crystal_index() -> int:
	var tank: int = my_tank()
	if crystal_pick > 0 and _crystal_tank != tank:
		crystal_pick = 0
	return (crystal_pick if crystal_pick > 0 else crystal_scheme(client.tanks, tank)) - 1


func _crystal_list(o: Vector2) -> void :
	if not crystal_drop or not crystal_shown():
		crystal_drop = false
		return
	var count: int = crystal_count()
	var shown: int = mini(count, TALENT_SHOWN)
	if shown <= 0:
		crystal_drop = false
		return
	_crystal_first = clampi(_crystal_first, 0, count - shown)
	var spec: Array = Atlas.AT.cbCrystal
	var box: Rect2 = Rect2(o + _xy(spec), Vector2(float(spec[2]), float(spec[3])))
	var high: float = TALENT_ROW * shown
	var top: Vector2 = Vector2(box.position.x, box.end.y)
	if top.y + high > _fh:
		top.y = box.position.y - high
	var area: Rect2 = Rect2(top * _f, Vector2(box.size.x, high) * _f)
	draw_rect(Rect2((top + Vector2(2, 2)) * _f, area.size), Color(0, 0, 0, 0.25))
	draw_rect(area, HALO_FILL)
	_hit("cr_drop", area, false)
	var index: int = crystal_index()
	for k in range(shown):
		var j: int = _crystal_first + k
		var line: Rect2 = Rect2((top + Vector2(0, TALENT_ROW * k)) * _f, Vector2(box.size.x, TALENT_ROW) * _f)
		var id: String = "cr_pick:%d" % j
		if j == index:
			draw_rect(line, HALO_PICKED)
		elif _hover == id:
			draw_rect(line, HALO_OVER)
		_fwords(crystal_text(client.crystal_names, j + 1), ARIAL_BOLD, 12.0, Color.WHITE, "l", top + Vector2(5, TALENT_ROW * k), box.size.x - 7.0 - (BAR if count > shown else 0.0), 0.0, TALENT_ROW, false)
		_hit(id, line, false)
	var most_cr: int = count - shown
	_vbar("cr", top + Vector2(box.size.x - BAR, 0), high, _crystal_first, shown, count, 
		func(value: float) -> void : _crystal_first = clampi(roundi(value), 0, most_cr))



func _crystal_choose(i: int) -> void :
	crystal_drop = false
	var scheme: int = i + 1
	if scheme > crystal_count() or scheme <= 0 or i == crystal_index():
		return
	crystal_pick = scheme
	_crystal_tank = my_tank()
	client._send("ItemMessage.RequestSetCurCrystalSchemeIdMessage", {"m_schemeId": scheme, "m_tankUuid": str(talent_inst().get("m_tankUuid", ""))})



func chat_expand() -> bool:
	if _tip_ok() and _hover in CHAT_HOVER:
		return true
	return _mobile and _chat_pin



func _chat(o: Vector2) -> void :
	chat_open = chat_expand()
	var at: Vector2 = o + (CHAT_OPEN_AT if chat_open else _xy(Atlas.AT.chat_bg))
	var box: Vector2 = CHAT_OPEN_SIZE if chat_open else CHAT_SIZE
	_fblit("st_chat_bg_open" if chat_open else "st_chat_bg", at)
	_hit("chatbox", Rect2(at * _f, box * _f), false)
	var area: Rect2 = CHAT_AREA_OPEN if chat_open else CHAT_AREA
	var fit: int = maxi(1, floori(area.size.y / CHAT_LINE))
	var rows: Array = chat_rows(client.chat_log, _chat_from, area.size.x)
	_chat_most = maxi(0, rows.size() - fit)
	_chat_scroll = clampi(_chat_scroll, 0, _chat_most)
	var last: int = rows.size() - _chat_scroll
	var shown: Array = rows.slice(maxi(0, last - fit), last)
	var font_size: int = maxi(6, roundi(CHAT_PX * _f))
	var rim: int = maxi(1, roundi(2.0 * _f))
	chat_shown = []
	for i in range(shown.size()):
		var x: float = (o.x + area.position.x) * _f
		var middle: float = (o.y + area.position.y + CHAT_LINE * (i + fit - shown.size()) + CHAT_LINE / 2.0) * _f
		var y: float = middle + (ARIAL.get_ascent(font_size) - ARIAL.get_descent(font_size)) / 2.0
		var plain: String = ""
		for seg: Array in shown[i]:
			draw_string_outline(ARIAL, Vector2(x, y), str(seg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, rim, CHAT_GLOW)
			draw_string(ARIAL, Vector2(x, y), str(seg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, seg[1])
			x += ARIAL.get_string_size(str(seg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
			plain += str(seg[0])
		chat_shown.append(plain)
	_chat_bar(at, CHAT_BAR_OPEN if chat_open else CHAT_BAR, fit)
	_hit("chat", Rect2((o + CHAT_INPUT.position) * _f, CHAT_INPUT.size * _f), false)
	_fbutton("send", "st_send", o + (CHAT_SEND_OPEN if chat_open else _xy(Atlas.AT.btnSendChat)))
	_fput(_typing, Rect2(o + CHAT_INPUT.position, CHAT_INPUT.size), 12)




func _chat_bar(frame: Vector2, bar: Vector3, fit: int) -> void :
	var at: Vector2 = frame + Vector2(bar.x, bar.y)
	var high: float = bar.z
	var arrow: float = minf(BAR, floorf(high / 2.0))
	var track: float = high - 2.0 * arrow
	var first: int = _chat_most - _chat_scroll
	var apply: Callable = func(value: float) -> void : _chat_scroll = clampi(_chat_most - roundi(value), 0, _chat_most)
	if track > 0.0:
		_fblit("apt_sb_bk", at + Vector2(0, arrow), CHAT_BAR_W, track)
	_fblit("apt_sb_up", at, CHAT_BAR_W, arrow)
	_fblit("apt_sb_down", at + Vector2(0, arrow + track), CHAT_BAR_W, arrow)
	_hit("sb:chat:up", Rect2(at * _f, Vector2(CHAT_BAR_W, arrow) * _f))
	_hit("sb:chat:down", Rect2((at + Vector2(0, arrow + track)) * _f, Vector2(CHAT_BAR_W, arrow) * _f))
	_bars["chat"] = [apply, first, fit]
	if _chat_most <= 0 or track < 20.0:
		return
	var thumb: float = maxf(20.0, track * fit / float(_chat_most + fit))
	var y: float = at.y + arrow + (track - thumb) * clampf(float(first) / _chat_most, 0.0, 1.0)
	_fblit("apt_sb_thumb", Vector2(at.x, y), CHAT_BAR_W, thumb, _glow("slide:chat"))
	_knob_hit("slide:chat", Rect2(Vector2(at.x, y) * _f, Vector2(CHAT_BAR_W, thumb) * _f), first, _chat_most, (track - thumb) * _f, apply)



static func chat_rows(log: Array, from: int, wide: float) -> Array:
	var font_size: int = int(CHAT_PX)
	var rows: Array = []
	for line: Dictionary in log:
		if int(line.get("channel", 0)) != 64 or int(line.get("seq", 0)) <= from:
			continue
		var pieces: Array = []
		if not str(line.get("head", "")).is_empty():
			pieces.append([str(line.head), line.get("color", Color.WHITE)])
		if not str(line.get("name", "")).is_empty():
			pieces.append([str(line.name), line.get("name_color", Color.WHITE)])
		pieces.append([str(line.get("text", "")), line.get("color", Color.WHITE)])
		var row: Array = []
		var x: float = 0.0
		for piece: Array in pieces:
			var text: String = piece[0]
			while not text.is_empty():
				var cut: int = text.length()
				while cut > 0 and x + ARIAL.get_string_size(text.left(cut), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > wide:
					cut -= 1
				if cut == 0:
					if x <= 0.0:
						cut = 1
					else:
						rows.append(row)
						row = []
						x = 0.0
						continue
				var part: String = text.left(cut)
				row.append([part, piece[1]])
				x += ARIAL.get_string_size(part, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				text = text.substr(cut)
				if not text.is_empty():
					rows.append(row)
					row = []
					x = 0.0
		rows.append(row)
	return rows


func _send_chat() -> void :
	if client == null or _typing.text.strip_edges().is_empty():
		return
	if client.send_pair_chat(_typing.text):
		_typing.text = ""
		_chat_scroll = 0
	else:
		say(CHAT_FAST)


func _info(o: Vector2) -> void :
	var tank: int = info_tank()
	if tank <= 0:
		return
	_fblit("st_info_bg", o + _xy(Atlas.AT.info_bg))
	if pack == null or pack.garage.is_empty():
		return
	var row: Dictionary = pack.garage.get("tanks", {}).get(str(tank), {})
	_label("lblTankName", str(pack.lobby.get("tanks", {}).get(str(tank), tank)), o, TITLE_GOLD, 1.5)
	var intro: Array = Atlas.TEXT.txtTankIntro
	var kind: String = str(Atlas.PHYS[0 if int(row.get("type", 1)) == 1 else 1])
	var pos: String = str(row.get("pos", ""))
	_fpara(kind + ("\n" + pos if not pos.is_empty() else ""), ARIAL_BOLD, float(intro[4]), Color(str(intro[5])), 
		o + Vector2(float(intro[0]), float(intro[1])), float(intro[2]), 3)
	var ext: int = int(_pick(client.account_oid).get("ext", 0)) if tank == my_tank() else 0
	if ext <= 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank, 1, {})
	var keys: Dictionary = {}
	for pair: Array in GarageModel.skills(pack.garage, tank, ext):
		keys[str(pair[0])] = int(pair[1])
	var grids: Array = Atlas.AT.skill_grids
	var rows: Array = [["R", "skillGift", "lblSkillGiftName", "txtSkillGiftIntro"], ["E", "skillNormal", "lblSkillNormalName", "txtSkillNormalIntro"], 
		["Space", "skillEx", "lblSkillExName", "txtSkillExIntro"]]
	for i in range(rows.size()):
		var part: Array = rows[i]
		_fblit("st_skill_grid", o + _xy(grids[i]))
		var skill: int = int(keys.get(part[0], 0))
		if skill <= 0:
			continue
		var hud: Array = pack.skill_hud(skill)
		var icon: Texture2D = pack.icon("s", str(hud[0])) if not hud.is_empty() else null
		var slot: Array = Atlas.AT[part[1]]
		if icon != null:
			draw_texture_rect(icon, Rect2((o + _xy(slot)) * _f, Vector2(float(slot[2]), float(slot[3])) * _f), false)
		var text: Array = GarageModel.skill(pack.garage, skill)
		if text.is_empty():
			continue
		_label(str(part[2]), GarageModel.cap(str(text[0])), o)
		var body: Array = Atlas.TEXT[part[3]]
		_fpara(GarageModel.plain(str(text[1])), ARIAL_BOLD, float(body[4]), Color(str(body[5])), o + Vector2(float(body[0]), float(body[1])), float(body[2]), 6)






func _voice_get() -> Object:
	if _voice == null and client != null and VoiceClient.usable():
		_voice = VoiceClient.shared()
	if _voice != null:
		_voice.attach(client)
	return _voice

func voice_shown() -> bool:
	var voice: Object = _voice_get()
	return voice != null and voice.pick_shown()

func _draw_voice(o: Vector2) -> void :
	voice_drawn = {}
	if not voice_shown():
		if _voice_hold_at >= 0.0:
			_voice_release()
		return
	if _voice_hold_at >= 0.0 and not _held:
		_voice_release()
	var mic: Vector2 = (o + VOICE_MIC) * _f
	var spk: Vector2 = (o + VOICE_SPK) * _f
	var rad: float = VOICE_R * _f
	var half: Vector2 = Vector2(VOICE_HIT, VOICE_HIT) * _f
	var state: String = _voice.mic_state()
	var tag: String = ""
	if state != "off" and Settings.value("mic_mode") == "ptt" and not _mobile:
		var code: int = int(Settings.value("mic_ptt_key"))
		if code != int(_voice_key[0]):
			_voice_key = [code, str(load("res://ui/settings.gd").ptt_name(code))]
		tag = str(_voice_key[1])
	VoiceUI.button(self, mic, rad, "mic_off" if state == "off" else "mic", state, tag, BOLD, _f, _hover == "voice:mic", _press == "voice:mic")
	_hit("voice:mic", Rect2(mic - half, half * 2.0), false)
	var mode: String = _voice.speaker
	var icon: String = "spk_off" if mode == "off" else ("spk" if mode == "all" else "spk_room")
	VoiceUI.button(self, spk, rad, icon, "off" if mode == "off" else "on", str(VOICE_TAG.get(mode, "")), BOLD, _f, 
		_hover == "voice:spk", _press == "voice:spk")
	_hit("voice:spk", Rect2(spk - half, half * 2.0), false)
	voice_drawn = {"mic": Rect2(mic - half, half * 2.0), "spk": Rect2(spk - half, half * 2.0)}

func _voice_click(what: String) -> void :
	if _voice_get() == null:
		return
	if what == "mic":
		_voice.toggle_mic()
	elif what == "spk":
		var at: int = VoiceClient.SPEAKERS.find(_voice.speaker)
		var next: String = str(VoiceClient.SPEAKERS[(at + 1) % VoiceClient.SPEAKERS.size()])
		_voice.set_speaker(next)
		say(str(VoiceClient.SPEAKER_TEXT.get(next, "")))

func _voice_release() -> void :
	if _voice_hold_at >= 0.0 and _voice != null:
		_voice.hold_talk(false)
	_voice_hold_at = -1.0

func _activate(id: String) -> void :
	if id.begins_with("voice:"):
		_voice_click(id.substr(6))
		return
	if id.begins_with("sb:") or id.begins_with("slide:"):
		_bar_step(id)
		return
	if corps_open:
		if id.begins_with("cs_pick:"):
			_corps_choose(int(id.substr(8)))
			return
		if id == "cs_box":
			return
		corps_open = false
	if talent_drop:

		if id.begins_with("tl_pick:"):
			_talent_choose(int(id.substr(8)))
			return
		if id == "tl_drop":
			return
		talent_drop = false
		if id == "talent":
			return
	if crystal_drop:

		if id.begins_with("cr_pick:"):
			_crystal_choose(int(id.substr(8)))
			return
		if id == "cr_drop":
			return
		crystal_drop = false
		if id == "crystal":
			return
	if _mobile and id == "chatbox":
		_chat_pin = not _chat_pin
		return
	if id in ["shade", "panel", "list", "chatbox", ""]:
		return
	if watching() and id not in ["chat", "send"] and not id.begins_with("filter:"):
		return
	if skin_strip.activate(self, id):
		return
	if id == "chat":
		_typing.grab_focus()
		return
	if id == "send":
		_send_chat()
		return
	if id.begins_with("filter:"):
		_filter = int(id.substr(7))
		_scroll = 0
		return
	if id.begins_with("rent:"):
		rent_asked.emit(int(id.substr(5)))
		return
	if id.begins_with("tank:"):
		var tank: int = int(id.substr(5))
		var trial: bool = tank_list().any( func(rec: Dictionary) -> bool: return int(rec.id) == tank and rec.has("weekly"))
		if can_pick and trial:
			client.pick_weekly_tank(tank)
		elif can_pick:
			pick_asked.emit(tank)
		else:
			say(SOON)
		return
	if id == "crystal":
		if crystal_shown() and crystal_count() > 0:
			crystal_drop = true
			_crystal_first = clampi(crystal_index() - TALENT_SHOWN + 1, 0, maxi(0, crystal_count() - TALENT_SHOWN))
		return
	if id == "talent":
		if talent_shown() and not client.talent_pages.is_empty():
			talent_drop = true
			_talent_first = clampi(talent_index() - TALENT_SHOWN + 1, 0, maxi(0, client.talent_pages.size() - TALENT_SHOWN))
		return
	if id == "edit_talent":
		if talent_shown() and not client.talent_pages.is_empty():
			talent_asked.emit(str(talent_inst().get("m_tankUuid", "")))
		return
	if id == "edit_crystal":
		if crystal_shown():
			crystal_asked.emit(str(talent_inst().get("m_tankUuid", "")))
		return
	if id in ["corps", "switch"]:
		corps_show()
		return
	if id == "confirm":
		if my_tank() <= 0:
			say(str(Atlas.TIP_3))
		elif round_mode() and not client.self_turn():
			say(ROUND_WAIT)
		elif can_pick:
			lock_asked.emit()
		else:
			say(SOON)
		return
	say(SOON)



func _vbar(name: String, at: Vector2, high: float, first: int, shown: int, total: int, apply: Callable) -> void :
	var most: int = total - shown
	if most <= 0:
		return
	var track: float = high - 2.0 * BAR
	_fblit("apt_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("sb:%s:up" % name, "apt_sb_up", at)
	_fbutton("sb:%s:down" % name, "apt_sb_down", at + Vector2(0, BAR + track))
	var thumb: float = maxf(20.0, track * shown / float(total))
	var y: float = at.y + BAR + (track - thumb) * clampf(float(first) / most, 0.0, 1.0)
	_hit("sb:%s:pgup" % name, Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, y - at.y - BAR) * _f), false)
	_hit("sb:%s:pgdn" % name, Rect2(Vector2(at.x, y + thumb) * _f, Vector2(BAR, at.y + BAR + track - y - thumb) * _f), false)
	_fslice("apt_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:" + name))
	_knob_hit("slide:" + name, Rect2(Vector2(at.x, y) * _f, Vector2(BAR, thumb) * _f), first, most, (track - thumb) * _f, apply)
	_bars[name] = [apply, first, shown]


func _bar_step(id: String) -> void :
	var part: PackedStringArray = id.split(":")
	var bar: Array = _bars.get(part[1], []) if part.size() >= 3 else []
	if bar.is_empty():
		return
	var step: int = {"up": -1, "down": 1, "pgup": - int(bar[2]), "pgdn": int(bar[2])}.get(part[2], 0)
	(bar[0] as Callable).call(float(int(bar[1]) + step))


func _fslice(cell_name: String, at: Vector2, high: float, cap: float, tint: Color) -> void :
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var src: Rect2 = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	var wide: float = src.size.x
	var end: float = minf(cap, floorf(minf(high, src.size.y) / 2.0))
	draw_texture_rect_region(cell[0], Rect2(at * _f, Vector2(wide, end) * _f), Rect2(src.position, Vector2(wide, end)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, end)) * _f, Vector2(wide, high - 2.0 * end) * _f), 
		Rect2(src.position + Vector2(0, end), Vector2(wide, src.size.y - 2.0 * end)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, high - end)) * _f, Vector2(wide, end) * _f), 
		Rect2(src.position + Vector2(0, src.size.y - end), Vector2(wide, end)), tint)

func _wheel(step: int, at: Vector2) -> void :
	if skin_strip.wheel(self, step, at):
		return
	var over: String = _hit_at(at)
	for bar: String in ["tl", "cr", "cs", "tank"]:
		if over.begins_with("sb:%s:" % bar) or over == "slide:" + bar:
			_bar_step("sb:%s:%s" % [bar, "up" if step < 0 else "down"])
			return
	if talent_drop and (_hit_at(at) == "tl_drop" or _hit_at(at).begins_with("tl_pick:")):
		_talent_first = clampi(_talent_first + step, 0, maxi(0, client.talent_pages.size() - TALENT_SHOWN))
		return
	if crystal_drop and (_hit_at(at) == "cr_drop" or _hit_at(at).begins_with("cr_pick:")):
		_crystal_first = clampi(_crystal_first + step, 0, maxi(0, crystal_count() - TALENT_SHOWN))
		return
	if corps_open and (_hit_at(at) == "cs_box" or _hit_at(at).begins_with("cs_pick:")):
		_corps_first = clampi(_corps_first + step, 0, _corps_most())
		return
	if _hit_at(at) in CHAT_HOVER:
		_chat_scroll = clampi(_chat_scroll - step, 0, _chat_most)
	elif _hit_at(at) == "list" or _hit_at(at).begins_with("tank:"):
		_scroll = maxi(0, _scroll + step)



func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if talent_drop:
			talent_drop = false
		elif crystal_drop:
			crystal_drop = false
		elif corps_open:
			corps_open = false
		queue_redraw()
		get_viewport().set_input_as_handled()


func _gui_input(event: InputEvent) -> void :
	if _mobile and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed\
	and _hit_at(event.position) not in CHAT_HOVER:
		_chat_pin = false
		if _typing != null and _typing.has_focus():
			_typing.release_focus()

	if _voice != null and _mobile and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _hit_at(event.position) == "voice:mic" and voice_shown() and _voice.mic_state() != "off" and Settings.value("mic_mode") == "ptt":
				_voice_hold_at = _time
				_voice.hold_talk(true)
		elif _voice_hold_at >= 0.0:
			var long: bool = _time - _voice_hold_at > VOICE_HOLD
			_voice_release()
			if long:
				_press = ""
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		_typing.grab_focus()
		get_viewport().set_input_as_handled()
