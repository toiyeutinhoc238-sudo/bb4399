extends "flash_screen.gd"



























const GarageModel = preload("garage_model.gd")
const Proficiency = preload("proficiency.gd")


const PROF_BOX: Rect2 = Rect2(548, 97, 126, 46)
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const BagModel = preload("bag_model.gd")
const Atlas = preload("garage_atlas.gd")
const Arena = preload("arena_atlas.gd")
const TankRent = preload("tank_rent.gd")
const OpenSkin = preload("open_skin.gd")
const TankConvert = preload("tank_convert.gd")
const TankConvertAsk = preload("tank_convert_ask.gd")
const SkinConvert = preload("skin_convert_confirm.gd")
const AskAtlas = preload("tank_convert_ask_atlas.gd")
const Halo = preload("gar_halo_atlas.gd")
const GarSkin = preload("gar_skin_atlas.gd")
const ShopModel = preload("shop_model.gd")
const GarUp = preload("gar_up_atlas.gd")
const Mysterious = preload("mysterious_store.gd")
const FlashTip = preload("flash_tip.gd")
const ItemTipT = preload("item_tip.gd")
const CTip = preload("ctool_tip.gd")

signal closed
signal quick_buy_asked(tid: int, count: int)
signal rent_left
signal guide_asked(tid: int)


signal tank_buy_asked(tid: int, now: String, after: String)

const FRAME: Vector2 = Vector2(1000, 600)
const STARTER: int = 10000001
const BUY_TODO: String = "Mua tank đang được chuyển sang HTML5."
const DOUBLE: float = 0.4
const PAGE: int = 13
const GRADES: Dictionary = {2: Color("6ec1ff"), 3: Color("c99bff"), 4: Color("ffd166"), 5: Color("ff8257")}

const HALO_QUALITY: Dictionary = {2: Color("15ee19"), 3: Color("06fffc"), 4: Color("ff6eff"), 5: Color("f18819")}
const HALO_MASTER: int = 7003002
const HALO_DEFAULT: String = "Mặc định"
const HALO_OVER: String = "Quá hạn"
const HALO_LEFT: String = "T/g còn: @day@ ngày"
const HALO_COLS: int = 3
const WIZ_INK: Color = Color("ffc21a")
const FILTER_NODES: Dictionary = {"all": "btnAll", "dps": "btnAttack", "tank": "btnPanzer", "support": "btnAssist", "rent": "btnCanRent"}
const SKILL_KEYS: Array = ["R", "E", "Space"]
const SKILL_NODES: Array = ["skillGift", "skillNormal", "skillEx"]
const QUALITY: Array = [[2, "btnSkinQuaA", "qa"], [3, "btnSkinQuaS", "qs"], [4, "btnSkinQuaSS", "qss"], [5, "btnSkinQuaSSS", "qsss"]]
const STAT_Y: Array = [44, 70, 96, 122, 150, 208, 236, 180]
const GAIN: Color = Color("00ff00")
const MR_ATTRS: Array = [12, 1, 3, 6, 7]
const ATT_ATK: int = 1
const ATT_HPMAX: int = 12

const ATTR_NAMES: Array = ["TC", "PT", "Xuyên Thấu", "Tấn Công Vật Lý", "Tấn Công Năng Lượng", "Giáp Vật Lý", "Khiên Năng Lượng", 
	"Xuyên Giáp Vật Lý", "Xuyên Giáp Năng Lượng", "Tốc độ bắn", "Tốc độ di chuyển", "HP", "Thời gian hồi sinh", "CD Skill", "CD skill Guild", 
	"CD skill Tank", "Hiệu quả skill", "Tạo ST:", "Sát Thương nhận", "Nhận ST skill", "Nhận hiệu quả Khiên/Trị liệu", "Tầm bắn", "Tốc Độ Đạn", 
	"Thời gian duy trì", "Giới hạn Năng Lượng", "Mỗi 5s hồi HP", "Tỷ Lệ Bạo Công Thường", "Tỷ lệ hút máu công thường", "Tỷ lệ hút máu skill"]

const SKIN_BTN_TIP: String = "Skin cấp @text1@\nHiệu quả: @text2@\nNhấp nhận ngay"
const POS_INK: Color = Color("ecf9ff")
const POS_PX: float = 16.0
const POS_MIN: float = 14.0
const POS_TWO: float = 14.0
const TYPE_TIPS: Array = ["Tank Vật Lý: thường dùng đối kháng Tank năng lượng.", "Tank Năng Lượng: dùng đối kháng Tank Vật Lý"]
const SKIN_NONE: String = "HP +0% TC + 0%"
const RANK_GAP: float = 20.0
const SKIN_DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const SKIN_COLS: int = 3

const SKIN_TABS: Array = [[0, "gar_skin_q_all"], [2, "gar_skin_q_a"], [3, "gar_skin_q_s"], [4, "gar_skin_q_ss"], [5, "gar_skin_q_sss"]]


const SKIN_KINDS: Array = [[1, "lblQualityATitle", "lblQualityAAttr", "btnQualityA", ""], [2, "lblQualitySTitle", "lblQualitySAttr", "btnQualityS", ""], 
	[3, "lblQualitySSTitle", "lblQualitySSAttr", "btnQualitySS", ""], [4, "lblQualitySSSTitle", "lblQualitySSSAttr", "btnQualitySSS", ""], 
	[12, "lblCollect2Title", "lblCollect2Attr", "", "Khung Tím"], [13, "lblCollect3Title", "lblCollect3Attr", "", "Khung Cam"], 
	[14, "lblCollect4Title", "lblCollect4Attr", "", ""]]

const SKIN_TITLES: Dictionary = {1: "Có skin cấp A", 2: "Có skin cấp S", 3: "Có skin cấp SS", 4: "Có skin cấp SSS", 
	12: "Có 2 skin không cùng cấp kích hoạt:", 13: "Có 3 skin không cùng cấp, rồi có 1 skin SSS kích hoạt:", 14: "Có 4 skin không cùng cấp kích hoạt:"}
const SKIN_OFF: Color = Color("a6c0cf")
const SKIN_NO_TANK: String = "Nhận tank trước mới được dùng skin!"
const SKIN_LACK: String = "Chưa có"
const SKIN_OR: String = "Hoặc"
const SKIN_LEFT: String = "T/g còn: "

const SKIN_LEVEL: Array = ["Tank đạt lv", "Lv %d", " được đổi"]

const UP_ROWS: Array = [["label1", "lblHp", "lblUpgradeHp", 0], ["label2", "lblAtk", "lblUpgradeAtk", 1], 
	["label3", "lblADArmor", "lblUpgradeCentesis", 3], ["label4", "lblApArmor", "lblUpgradeArmor", 4]]
const UP_TWEEN: float = 1.0
const UP_GLOW: Color = Color(8.0 / 255.0, 109.0 / 255.0, 165.0 / 255.0, 0.8)
const UP_NAME_GLOW: Color = Color(0.2, 0.2, 0.0, 0.8)
const UP_TOKEN: int = 8000005
const UP_DEPTH: int = 12

var _filter: String = "all"
var _pick: int = 0
var _tab: int = 0
var _leaf: int = 0
var _first_page: int = 0
var _roster: Array = []
var _kinds: Dictionary = {}
var _stale: bool = true
var _fresh_at: float = -100.0
var _reveal: bool = false
var _asked: int = 0
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _sheet_id: String = ""
var _skin_q: int = 0
var _skin_first: int = 0
var _skin_bar: Array = []
var _skin_grab: Array = []
var _halo_first: int = 0
var _halo_uuid: String = ""
var _halo_bar: Array = []
var _halo_grab: Array = []
var _wait: Array = []


const DC1_HOLD: float = 10.0
const DC1_CALM: float = 0.6
var _dc1_calm: float = -1.0
var _up_frame: float = -1.0
var _up_tween: Array = []
var _up_seen: Array = []
var _last_id: String = ""
var _last_at: float = -10.0
var _hold: bool = false
var _rent: Control = null
var _rent_want: int = 0
var _rent_only: bool = false
var _from_guide: bool = false
var _opening: Control = null
var _converting: Control = null
var _asking: Control = null
var _skin_conv: Control = null

func _setup() -> void :
	client.changed.connect( func() -> void : _stale = true)
	client.tank_changed.connect(_on_tank_changed)
	pack.picture_ready.connect( func(path: String) -> void :
		if path == "l/garage.json":
			_stale = true)
	var guide_view: Control = preload("guide_view.gd").new()
	guide_view.setup(self, "garage")
	add_child(guide_view)


func guide_open(ui: String) -> bool:
	match ui:
		"tankWindow":
			return _sheet_id.is_empty() and not _renting()
		"tankUpWindow":
			return _sheet_id == "level"
	return false


func guide_select(id: int) -> void :
	_select(id)
	_filter = "all"
	_leaf = 0
	_reveal = true


func guide_close(ui: String) -> void :
	if ui == "tankUpWindow":
		if _sheet_id == "level":
			_close()
	else:
		closed.emit()

func _shown() -> void :
	_sheet_id = ""
	_wait = []
	_tip = []
	if not is_visible_in_tree():
		_rent_want = 0
		_rent_only = false
		if _from_guide:
			_from_guide = false
			rent_left.emit()
		if _rent != null and _rent.visible:
			_rent.close("")
		if _opening != null and _opening.visible:
			_opening.close("")
		if _converting != null and _converting.visible:
			_converting.close("")
		if _asking != null and _asking.visible:
			_asking.close("")
		if _skin_conv != null and _skin_conv.visible:
			_skin_conv.close("")
		return
	pack.load_garage()
	pack.load_bag()
	pack.load_garagex()
	pack.load_rank()
	if not client.bag_loaded:
		client.request_bags()
	if _hold:
		_hold = false
		_stale = true
		_take_rent_want()
		return
	_filter = "all"
	_tab = 0
	_leaf = 0
	_asked = 0
	_pick = int(client.current_tank().get("m_tpltId", 0))
	_stale = true
	_reveal = true
	_take_rent_want()




func want_rent(id: int) -> void :
	if id <= 0:
		return
	if is_visible_in_tree():
		_open_rent(id)
	else:
		_rent_want = id

func _take_rent_want() -> void :
	if _rent_want <= 0:
		return
	var id: int = _rent_want
	_rent_want = 0
	_rent_only = true
	_from_guide = true
	_open_rent(id)

func _tick(_delta: float) -> void :
	if not _wait.is_empty() and _time > float(_wait[1]):
		if str(_wait[0]) in ["up", "strengthen"] and _wait.size() == 3:
			say("Máy chủ đang chậm, đang chờ kết quả…")
			_wait = [_wait[0], _time + DC1_HOLD, _wait[2], true]
		else:
			say(str({"skin": "Máy chủ không nhận đổi ngoại hình.", "halo": "Máy chủ không nhận đổi vòng sáng."}.get(str(_wait[0]), "Máy chủ chưa trả lời, hãy thử lại.")))
			_wait = []
	if not _stale and _time - _fresh_at < 20.0:
		return
	_stale = false
	_fresh_at = _time
	_roster = GarageModel.roster(client.tanks, pack.garage, pack.lobby.get("tanks", {}), pack.index.get("tanks", {}), int(Time.get_unix_time_from_system()))
	_kinds = {}
	for rec: Dictionary in _roster:
		var own: Dictionary = GarageModel.owned_skins(pack.garage, client.bags, int(rec.id))
		if own.size() >= 2:
			_kinds[int(rec.id)] = _frame_of(GarageModel.looks(pack.garage, pack.index.get("tanks", {}), int(rec.id), int(rec.level), int(rec.ext)), own)
	if _rec().is_empty() and not _roster.is_empty():
		_pick = int(_roster[0].id)
		for rec: Dictionary in _roster:
			if rec.main:
				_pick = int(rec.id)
		_reveal = true
	if _asked > 0:
		for rec: Dictionary in _roster:
			if int(rec.id) == _asked and rec.main:
				say("Đã đặt %s làm chủ chiến." % str(rec.name))
				_asked = 0

func _rec() -> Dictionary:
	for rec: Dictionary in _roster:
		if int(rec.id) == _pick:
			return rec
	return {}

func _list() -> Array:
	if _filter == "rent":
		return _roster.filter( func(rec: Dictionary) -> bool: return _can_rent(int(rec.id)))
	return GarageModel.filtered(_roster, _filter)


func _can_rent(id: int) -> bool:
	var rows: Variant = client.tank_rents if client.tank_rent_got else pack.garagex.get("rent", [])
	if not rows is Array:
		return false
	for row: Variant in rows:
		if row is Dictionary and int(row.get("tank_id", 0)) == id:
			return true
	return false


func _renting() -> bool:
	return ((_rent != null and _rent.visible) or (_opening != null and _opening.visible) or (_converting != null and _converting.visible)
		or (_asking != null and _asking.covering()) or (_skin_conv != null and _skin_conv.covering()))


func _open_rent(id: int) -> void :
	if _rent == null:
		_rent = TankRent.new()
		_rent.client = client
		_rent.pack = pack
		_rent.hall = hall
		add_child(_rent)
		_rent.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_rent.quick_buy_asked.connect( func(tid: int, count: int) -> void : quick_buy_asked.emit(tid, count))
		_rent.tank_buy_asked.connect( func(tid: int, now: String, after: String) -> void :
			if tank_buy_asked.get_connections().is_empty():
				_rent.say(BUY_TODO)
			else:
				tank_buy_asked.emit(tid, now, after))
		_rent.convert_asked.connect( func(tid: int) -> void : _open_ask(tid))
		_rent.closed.connect( func(note: String) -> void :
			_stale = true
			if not note.is_empty():
				say(note)
			if _rent_only:
				_rent_only = false
				if note.is_empty():
					closed.emit()
				else:
					_select(_rent.current_tank()))
	_hover = ""
	_tip = []
	_rent.open(id)


func _open_get_skin(skin: int) -> void :
	if _opening == null:
		_opening = OpenSkin.new()
		_opening.client = client
		_opening.pack = pack
		_opening.hall = hall
		add_child(_opening)
		_opening.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_opening.closed.connect( func(note: String) -> void :
			_stale = true
			if not note.is_empty():
				say(note))
	_hover = ""
	_tip = []
	_opening.open(skin)


func _open_convert(tank: int) -> void :
	if _converting == null:
		_converting = TankConvert.new()
		_converting.client = client
		_converting.pack = pack
		_converting.hall = hall
		add_child(_converting)
		_converting.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_converting.quick_buy_asked.connect( func(tid: int) -> void : quick_buy_asked.emit(tid, 1))
		_converting.closed.connect( func(note: String) -> void :
			_stale = true
			if not note.is_empty():
				say(note))
	_hover = ""
	_tip = []
	_converting.open(tank)



func _open_ask(tank: int) -> void :
	if _asking == null:
		_asking = TankConvertAsk.new()
		_asking.client = client
		_asking.pack = pack
		_asking.hall = hall
		add_child(_asking)
		_asking.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_asking.converted.connect( func(_tid: int) -> void :
			if _rent != null and _rent.visible:
				_rent.close(""))
		_asking.closed.connect( func(note: String) -> void :
			_stale = true
			if not note.is_empty():
				say(note))
	move_child(_asking, get_child_count() - 1)
	_hover = ""
	_tip = []
	_asking.open(tank)



func _open_skin_conv(skin: int) -> void :
	if _skin_conv == null:
		_skin_conv = SkinConvert.new()
		_skin_conv.client = client
		_skin_conv.pack = pack
		_skin_conv.hall = hall
		add_child(_skin_conv)
		_skin_conv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_skin_conv.watch_all.connect( func(item: int) -> void : page_asked.emit("fair:convert:%d" % item))
		_skin_conv.closed.connect( func(note: String) -> void :
			_stale = true
			if not note.is_empty():
				say(note))
	move_child(_skin_conv, get_child_count() - 1)
	_hover = ""
	_tip = []
	_skin_conv.open_skin(skin, _skin_tank_of(skin))


func _convert_row(tank: int) -> Array:
	var row: Array = AskAtlas.CONVERT_OF.get(str(tank), [])
	return row if row.size() >= 4 else []


func _ext(rec: Dictionary) -> int:
	return int(rec.get("ext", 0))



func _kit(rec: Dictionary) -> Array:
	var base: Array = GarageModel.skills(pack.garage, int(rec.id), 0)
	var ext: int = _ext(rec)
	if ext <= 0 or not pack.garage.get("skins", {}).has(str(ext)):
		return base
	var own: Dictionary = {}
	for pair: Array in GarageModel.skills(pack.garage, int(rec.id), ext):
		own[str(pair[0])] = int(pair[1])
	var out: Array = []
	for pair: Array in base:
		var skill: int = int(own.get(str(pair[0]), 0))
		var hud: Array = pack.skill_hud(skill) if skill > 0 else []
		var key: String = str(hud[0]) if not hud.is_empty() else ""
		out.append([pair[0], skill] if not key.is_empty() and key != "offline_empty_skill" else pair)
	return out

func _select(id: int) -> void :
	if id == _pick:
		return
	_pick = id

func _step(by: int) -> void :
	var list: Array = _list()
	if list.is_empty():
		return
	var index: int = 0
	for i in range(list.size()):
		if int(list[i].id) == _pick:
			index = clampi(i + by, 0, list.size() - 1)
			break
	_select(int(list[index].id))
	_reveal = true

func _set_main() -> void :
	var rec: Dictionary = _rec()
	if rec.is_empty():
		return
	var block: String = GarageModel.main_block(rec, client.state)
	if not block.is_empty():
		say(block)
		return
	_asked = int(rec.id)
	client.change_battle_tank(str(rec.use.get("m_tankUuid", "")))

func _v(at: Array) -> Vector2:
	return Vector2(float(at[0]), float(at[1]))

func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Atlas.FILE, Atlas.R)
		_use(Halo.FILE, Halo.R)
		_use(GarSkin.FILE, GarSkin.R)
		_use(GarUp.FILE, GarUp.R)
		_use(AskAtlas.FILE, AskAtlas.R)
	_tip = []
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(FRAME.x, FRAME.y)
	_hit("panel", Rect2(base * _f, FRAME * _f), false)
	_fblit("garage_frame", base + _v(Atlas.PANELS["garage_frame"]))
	_fbutton("back", "public_button_close", base + _v(Atlas.NODES["btnClose"]))
	var rec: Dictionary = _rec()
	if rec.is_empty() or (_sheet_id == "level" and _own(rec).is_empty()):
		_sheet_id = ""
	for key: String in FILTER_NODES:
		_fbutton("filter:" + key, "garage_f_%s%s" % [key, "_on" if _filter == key else ""], base + _v(Atlas.NODES[FILTER_NODES[key]]))
	_draw_cells(base)
	_draw_pager(base)
	if rec.is_empty():
		_fwords("Đang tải kho xe…", BOLD, 16, Color.WHITE, "c", base + Vector2(372, 240), 256, 1.0)
	else:
		_draw_tank(base, rec)
		_draw_skin(base, rec)
	_draw_wizard(base + _v(Atlas.WIZ), rec)
	if _sheet_id == "halo":
		_draw_halo(rec)
	elif _sheet_id == "skin":
		_draw_skin_view(rec)
	elif _sheet_id == "level":
		_draw_up(rec)
	_draw_tip()

func _draw_cells(base: Vector2) -> void :
	var list: Array = _list()
	if _reveal and not list.is_empty():
		_reveal = false
		for i in range(list.size()):
			if int(list[i].id) == _pick:
				_leaf = i / PAGE
	_leaf = clampi(_leaf, 0, _pages(list.size()) - 1)
	if list.is_empty():
		var empty: String = "Đang tải kho xe…" if _roster.is_empty() else ("Không có tank cho thuê." if _filter == "rent" else "Không có tank nào.")
		_fwords(empty, BOLD, 14, Color.WHITE, "c", base + Vector2(10, 290), 308, 1.0)
		return
	for i in range(_leaf * PAGE, mini(list.size(), (_leaf + 1) * PAGE)):
		_draw_cell(list[i], base + _v(Atlas.CELLS[i - _leaf * PAGE]))





func _draw_cell(rec: Dictionary, at: Vector2) -> void :
	var id: String = "tank:%d" % int(rec.id)
	var avail: bool = rec.avail
	var rect: Rect2 = _fblit("garage_cell_bg" if avail else "garage_cell_off", at, 0.0, 0.0, _glow(id))
	var inst: Dictionary = rec.get("inst", {})
	var item: int = 0 if inst.is_empty() else TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(inst.get("m_haloId", 0)), int(rec.level))
	var mask: PackedVector2Array = TankPortrait.hexagon((at + Vector2(51, 58)) * _f, 50.0 * _f)
	var key: String = GarageModel.face(pack.garage, int(rec.ext))
	if not TankPortrait.draw(self, pack, key, item, (at + Vector2(54, 55)) * _f, 0.5 * _f, _time, "l/t", true, Rect2(), 1.0, null, mask):
		_framed(int(rec.id), int(rec.ext), at + Vector2(54, 55), at + Vector2(51, 58), 50.0, true, 0.5, Color.WHITE)
	var kind: String = str(_kinds.get(int(rec.id), ""))
	if not kind.is_empty():
		_fblit("garage_cell_" + kind, at + _v(Atlas.CELL["imgSkinFrame"]))
	if rec.hire and not rec.owned:
		_fblit("garage_mark_rent", at + _v(Atlas.CELL["imgRent"]))
	_fblit("garage_mark_owned" if rec.owned else "garage_mark_unbuy", at + _v(Atlas.CELL["imgMarkAchieved"]))
	var lv: Array = Atlas.CELL_LEVEL
	_fwords(str(int(rec.level)), BOLD, float(lv[4]), Color(str(lv[5])), "c", at + _v(lv), float(lv[2]), 1.0, float(lv[3]))
	if int(rec.id) == _pick:
		_fblit("garage_cell_sel", at)
	if rec.main:
		_fblit("garage_onbattle", at + _v(Atlas.ON_BATTLE))
	_hit(id, rect, false)



func _framed(tank: int, ext: int, mid: Vector2, c: Vector2, r: float, pointy: bool, zoom: float, tint: Color) -> void :
	var key: String = GarageModel.face(pack.garage, ext)
	if not key.is_empty():
		var picture: Texture2D = pack.picture("l/t/%s.webp" % key)
		if picture == null:
			return
		var box: Rect2 = TankPortrait.still_rect(TankPortrait.movie(pack.garage, key), (mid - Vector2(100, 100) * zoom) * _f, zoom * _f, TankPortrait.side(pack.garage, key))
		var points: PackedVector2Array = PackedVector2Array()
		var uvs: PackedVector2Array = PackedVector2Array()
		for i in range(6):
			var p: Vector2 = (c + (Vector2.UP if pointy else Vector2.RIGHT).rotated(TAU / 6.0 * i) * r) * _f
			points.append(p)
			uvs.append((p - box.position) / box.size)
		draw_colored_polygon(points, tint, uvs, picture)
		return
	if ext <= 0 or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tank))
	if TankPreview.ready(art):
		TankPreview.draw(self, art, (mid + Vector2(0, 16.0 * zoom)) * _f, minf(1.5 * zoom, 172.0 * zoom / TankPreview.extent(art)) * _f, 4, _time)

func _draw_pager(base: Vector2) -> void :
	var pages: int = _pages(_list().size())
	var p: Dictionary = Atlas.PAGER

	if _leaf > 0:
		_fbutton("page:-1", "garage_pg_prev", base + _v(p["prev"]))
	if _leaf < pages - 1:
		_fbutton("page:1", "garage_pg_next", base + _v(p["next"]))
	_first_page = _first(_leaf, pages, _first_page)
	var start: int = _first_page
	var num: Array = p["num"]
	for i in range(mini(4, pages)):
		var at: Vector2 = base + _v(p["first"]) + Vector2(float(p["step"]) * i, 0)
		var id: String = "page:=%d" % (start + i)
		var rect: Rect2 = _fblit("garage_pg_on" if start + i == _leaf else "garage_pg", at + _v(p["back"]), 0.0, 0.0, _glow(id))
		_fwords(str(start + i + 1), BOLD, float(num[4]), Color(str(num[5])), "c", at + _v(num), float(num[2]), 1.0, float(num[3]))
		_hit(id, rect, false)

func _draw_tank(base: Vector2, rec: Dictionary) -> void :
	var n: Dictionary = Atlas.NODES
	var info: Dictionary = pack.garage.get("tanks", {}).get(str(int(rec.id)), {})
	var title: Array = Atlas.TEXTS["lblTankName"]
	_fwords(str(rec.name), BOLD, float(title[4]), Color(str(title[5])), "c", base + _v(title), float(title[2]), 1.0)
	_fblit("garage_lv_%d" % clampi(int(rec.level), 0, 11), base + _v(n["imgTankLevel"]))
	var phys: bool = int(info.get("type", 1)) == 1
	var kind: Rect2 = _fblit("garage_type_phys" if phys else "garage_type_energy", base + _v(n["imgTankType"]))
	_hit("type", kind, false)
	if _hover == "type":
		_tip = [kind, TYPE_TIPS[0] if phys else TYPE_TIPS[1], "", Color.WHITE]
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(rec.inst.get("m_haloId", 0)), int(rec.level)) if rec.avail else 0
	_draw_pod(rec, _ext(rec), item, base + _v(n["viewAvatar"]) + Vector2(100, 100))
	_draw_prof(base, rec)
	for row: Array in _kit(rec):
		var k: int = SKILL_KEYS.find(str(row[0]))
		if k < 0:
			continue
		var box: Rect2 = Rect2((base + _v(n[SKILL_NODES[k]])) * _f, Vector2(50, 50) * _f)
		var hud: Array = pack.skill_hud(int(row[1]))
		var icon: Texture2D = pack.icon("s", str(hud[0])) if not hud.is_empty() else null
		if icon != null and icon.get_width() > 4:
			draw_texture_rect(icon, box, false)
		_fblit("garage_skill_ring", base + _v(Atlas.RINGS[k]))
		var id: String = "skill:%d" % k
		_hit(id, box, false)
		if _hover == id:
			_tip = [box, "", "", Color.WHITE, {"skill": int(row[1])}]
	var own: Dictionary = _own(rec)
	if not rec.owned:
		_fbutton("buy", "garage_btn_buy", base + _v(n["btnBuy"]))


		var conv: Array = _convert_row(int(rec.id))
		if not conv.is_empty() and up_have(client.bags, pack.bag.get("items", {}), int(conv[1])) >= int(conv[2]):
			_fbutton("convtank", "garage_btn_convert", base + _v(n["btnConvert"]))
		else:
			_fblit("tca_convert_off", base + _v(n["btnConvert"]))
		if not conv.is_empty():
			_draw_design_map(base, conv)
	if _can_rent(int(rec.id)):
		_fbutton("rent", "garage_btn_rent", base + _v(n["btnRent"]))
	if rec.main:
		_fblit("garage_onbattle_lbl", base + _v(n["lblOnBattle"]))
	elif GarageModel.main_block(rec, client.state).is_empty():
		_fbutton("onbattle", "garage_btn_onbattle", base + _v(n["btnOnBattle"]))
	if not own.is_empty():
		_fbutton("levelup", "garage_btn_levelup", base + _v(n["btnLevelUp"]))
		if _can_upgrade(rec, own):
			_fblit("garage_up_tip", base + _v(n["imgTankUpTip"]))
		var have: Array = Atlas.TEXTS["lblAchievedLevel"]
		_fwords("Lv Tank đã có: LV.%d" % int(own.get("m_level", 1)), BOLD, float(have[4]), Color(str(have[5])), "c", base + _v(have), float(have[2]), 1.0)
	_fbutton("halo", "garage_btn_halo", base + _v(n["btnTankHalo"]))
	_fbutton("convitem", "garage_btn_convitem", base + _v(n["btnConvertItem"]))
	var left: String = _exist(rec, int(Time.get_unix_time_from_system()))
	if not left.is_empty():
		var t: Array = Atlas.TEXTS["lblExistTime"]
		_fbox(left, float(t[4]), Color(str(t[5])), base + _v(t), float(t[2]), "c")



func _draw_prof(base: Vector2, rec: Dictionary) -> void :
	var own: Dictionary = _own(rec)
	var val: int = Proficiency.of_tank(own) if not own.is_empty() else -1
	var icon: Texture2D = Proficiency.icon(val, true)
	if icon == null:
		return
	var o: Vector2 = base + PROF_BOX.position
	var box: Rect2 = Rect2(o * _f, PROF_BOX.size * _f)
	draw_texture_rect(icon, Rect2((o + Vector2(0, 3)) * _f, Vector2(40, 40) * _f), false)
	var text_w: float = PROF_BOX.size.x - 46.0
	_fwords(Proficiency.tier_name(val), BOLD, 15.0, ON_BLUE, "l", o + Vector2(45, 1), text_w, 1.5, 0.0, true, BLUE_RIM)
	var bar: Rect2 = Rect2((o + Vector2(46, 22)) * _f, Vector2(text_w - 4.0, 5) * _f)
	_round(bar, Color(BLUE_RIM, 0.7), 2.5, Color(BTN_EDGE, 0.35), 1.0)
	var part: float = Proficiency.ratio(val)
	if part > 0.0:
		_round(Rect2(bar.position, Vector2(maxf(bar.size.y, bar.size.x * part), bar.size.y)), GOLD_TOP, 2.5)
	_fwords(Proficiency.progress(val), BOLD, 11.0, ON_BLUE, "l", o + Vector2(46, 29), text_w, 1.2, 0.0, true, BLUE_RIM)
	_hit("prof", box, false)
	if _hover == "prof":
		_tip = [box, "Thông thạo: %s (%s)" % [Proficiency.tier_name(val), Proficiency.progress(val)], "Thắng trận PvP với người thật +20, thua +10 (So Tài, Xếp Hạng, Đối Kháng).", Color.WHITE]



func _draw_design_map(base: Vector2, row: Array) -> void :
	var items: Dictionary = pack.bag.get("items", {})
	var item: int = int(row[1])
	var need: int = maxi(1, int(row[2]))
	var have: int = up_have(client.bags, items, item)
	var dm: Dictionary = AskAtlas.DESIGN_MAP
	var box: Array = dm["icon"]
	var rect: Rect2 = Rect2((base + _v(box)) * _f, Vector2(float(box[2]), float(box[3])) * _f)
	var entry: Array = up_entry(items, item)
	var key: String = str(entry[2]) if entry.size() > 2 else ""
	var folder: String = "av" if entry.size() > 5 and int(entry[5]) == 4 else "it"
	var picture: Texture2D = pack.picture("l/%s/%s.webp" % [folder, key]) if not key.is_empty() else null
	if picture != null:
		draw_texture_rect(picture, rect, false)
	_hit("dmap", rect, false)
	if _hover == "dmap":
		_tip = [rect, "", "", Color.WHITE, up_tip(pack.bag, item, entry)]
	var canvas: Array = dm["canvas"]
	var at: Vector2 = base + _v(dm["bar"])
	var k: int = clampi(roundi(float(have) * 100.0 / float(need)), 1, 100)
	_fpart("tca_dm_track", at, Rect2(0, 0, float(canvas[2]), 17))
	_fpart("tca_dm_fill", at, Rect2(0, 0, minf(float(AskAtlas.FILL_W[k - 1]), float(canvas[2])), 17))
	var label: Array = dm["label"]
	_fwords("%d/%d" % [have, int(row[2])], BOLD, 12.0, Color.WHITE, "c", base + _v(label), float(label[2]), 1.0, float(label[3]), false, UP_GLOW)



func _draw_pod(rec: Dictionary, ext: int, item: int, c: Vector2) -> void :
	var key: String = GarageModel.face(pack.garage, ext)
	var folder: String = "l/t"
	if not key.is_empty() and pack.garage.get("big", []).has(key) and pack.picture("l/tb/%s.webp" % key) != null:
		folder = "l/tb"
	if TankPortrait.draw(self, pack, key, item, c * _f, _f, _time, folder) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), int(rec.id)))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46)
		TankPortrait.ring(self, pack, item, pod * _f, _f, _time, 1)
		TankPreview.draw(self, art, (pod - Vector2(0, 52)) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * _f, 4, _time)
		TankPortrait.ring(self, pack, item, pod * _f, _f, _time, 2)



func _can_upgrade(rec: Dictionary, own: Dictionary) -> bool:
	if own.is_empty() or not client.bag_loaded:
		return false
	return up_ready(up_state(pack.garage, GarUp.UP_ITEMS, int(rec.id), own), GarUp.CONVERT, client.bags, pack.bag.get("items", {}), client.currency, 
		int(Time.get_unix_time_from_system()))




func _fbox(text: String, px: float, color: Color, at: Vector2, wide: float, align: String, high: float = 0.0) -> void :
	var font_size: int = maxi(6, roundi(px * _f))
	var mode: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER if align == "c" else HORIZONTAL_ALIGNMENT_LEFT
	var origin: Vector2 = Vector2(at.x, at.y + 2.0) * _f + Vector2(0, ARIAL_BOLD.get_ascent(font_size))
	var shown: String = fbox_cut(text, font_size, wide * _f, fbox_lines(high, ARIAL_BOLD.get_height(maxi(6, roundi(px)))))
	draw_multiline_string_outline(ARIAL_BOLD, origin, shown, mode, wide * _f, font_size, -1, maxi(1, roundi(_f)), SHADE)
	draw_multiline_string(ARIAL_BOLD, origin, shown, mode, wide * _f, font_size, -1, color)



static func fbox_cut(text: String, font_size: int, width: float, lines: int) -> String:
	if lines <= 0 or text.is_empty():
		return text
	var para: TextParagraph = TextParagraph.new()
	para.width = width
	para.break_flags = TextServer.BREAK_MANDATORY | TextServer.BREAK_WORD_BOUND
	para.add_string(text, ARIAL_BOLD, font_size)
	if para.get_line_count() <= lines:
		return text
	return text.substr(0, para.get_line_range(lines - 1).y).strip_edges(false, true)


static func fbox_lines(high: float, line: float) -> int:
	if high <= 0.0 or line <= 0.0:
		return -1
	return maxi(1, floori((high - 4.0) / line))




func _draw_skin(base: Vector2, rec: Dictionary) -> void :
	var n: Dictionary = Atlas.NODES
	var id: int = int(rec.id)
	var looks: Array = GarageModel.looks(pack.garage, pack.index.get("tanks", {}), id, int(rec.level), int(rec.ext))
	var own: Dictionary = GarageModel.owned_skins(pack.garage, client.bags, id)
	var kind: String = str(_kinds.get(id, ""))
	if not kind.is_empty():
		_fblit("garage_skin_" + kind, base + _v(n["imgSkinFrame"]))
	var c: Vector2 = base + Vector2(762, 481)
	var ext: int = _recommend(looks, own)
	if not TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), 0, c * _f, 0.5 * _f, _time, "l/t", true):
		_framed(id, ext, c, c, 60.0, false, 0.5, Color.WHITE)
	_hit("face", Rect2((c - Vector2(60, 52)) * _f, Vector2(120, 104) * _f), false)
	for q: Array in QUALITY:
		var grade: int = int(q[0])
		if not looks.any( func(look: Array) -> bool: return int(look[1]) == grade):
			continue
		var mine: bool = looks.any( func(look: Array) -> bool: return int(look[1]) == grade and own.has(int(look[0])))
		var gid: String = "grade:%d" % grade
		var rect: Rect2 = _fbutton(gid, "garage_%s%s" % [str(q[2]), "_on" if mine else ""], base + _v(n[str(q[1])]))
		if _hover == gid:
			_tip = [rect, skin_btn_tip(grade, pack.garagex.get("skin", {}).get(str(id), [])), "", Color.WHITE]
	_fbutton("skin", "garage_btn_skin", base + _v(n["btnTankSkin"]))
	if not kind.is_empty():
		var t: Array = Atlas.TEXTS["lblSkinFrameTip"]
		_fbox("Có 3 skin khác cấp, có skin SSS, kích hoạt khung cam" if kind == "orange" else "Có 2 skin kích hoạt khung tím", float(t[4]), Color(str(t[5])), base + _v(t), float(t[2]), "l")

func _draw_wizard(w: Vector2, rec: Dictionary) -> void :
	var p: Dictionary = Atlas.PANELS
	var nodes: Dictionary = Atlas.WNODES
	_fblit("garage_wiz_bg", w + _v(p["garage_wiz_bg"]))
	_fbutton("tab:0", "garage_w_sum_on" if _tab == 0 else "garage_w_sum", w + _v(nodes["btnSum"]))
	_fbutton("tab:1", "garage_w_attr_on" if _tab == 1 else "garage_w_attr", w + _v(nodes["btnAttr"]))
	if rec.is_empty():
		return
	var id: int = int(rec.id)
	if _tab == 0:
		var info: Dictionary = pack.garage.get("tanks", {}).get(str(id), {})
		_fblit("garage_wiz_sum", w + _v(p["garage_wiz_sum"]))
		_draw_pos(str(info.get("pos", "")), w + _v(Atlas.WTEXT["lblTankDec"]))
		for i in range(3):
			_fblit("garage_star_bg", w + _v(nodes["imgBg%d" % i]))
			if i < int(info.get("hard", 1)):
				_fblit("garage_star", w + _v(nodes["imgStar%d" % i]))
		_draw_radar(w + _v(Atlas.RADAR["c"]), float(Atlas.RADAR["r"]), GarageModel.radar(pack.garage, id))
		return
	_fblit("garage_wiz_attr", w + _v(p["garage_wiz_attr"]))
	var stats: Array = GarageModel.stats(pack.garage, id, int(rec.level), int(rec.inst.get("m_stthLevel", 0)))
	var plus: Array = _gains(id, stats)
	for i in range(mini(stats.size(), STAT_Y.size())):
		var at: Vector2 = w + Vector2(141, float(STAT_Y[i]))
		var wide: float = _fwords(str(int(stats[i][1])), BOLD, 16, Color.WHITE, "l", at, 130, 1.0)
		if i < plus.size():
			_fwords(" +%d" % int(plus[i]), BOLD, 16, GAIN, "l", at + Vector2(wide, 0), maxf(1.0, 130.0 - wide), 1.0, 0.0, false)
	_fwords("Thuộc tính skin", BOLD, 16, WIZ_INK, "l", w + Vector2(23, 274), 160, 1.0)
	_fwords(_skin_text(id), BOLD, 14, WIZ_INK, "l", w + Vector2(23, 295), 200, 1.0)
	var label: float = _fwords("Buff Quân Hàm", BOLD, 14, WIZ_INK, "l", w + Vector2(23, 316), 200, 1.0)
	_fbutton("rank", "garage_btn_rank", w + Vector2(23.0 + label + RANK_GAP, float(nodes["btnMilitaryRank"][1])))



func _gains(id: int, stats: Array) -> Array:
	if stats.size() < 2:
		return []
	var rows: Array = pack.garagex.get("skin", {}).get(str(id), [])
	var flags: Array = skin_flags(pack.garagex.get("skins", {}), client.bags, id)
	return gains(int(stats[0][1]), int(stats[1][1]), skin_val(rows, flags, ATT_HPMAX), skin_val(rows, flags, ATT_ATK), 
		mr_totals(pack.rank.get("ranks", []), int(client.character.get("nMilitaryStar", 0))))


func _skin_text(id: int) -> String:
	var rows: Array = pack.garagex.get("skin", {}).get(str(id), [])
	var text: String = skin_desc(rows, skin_flags(pack.garagex.get("skins", {}), client.bags, id))
	return SKIN_NONE if text.is_empty() else text

static func gains(hp: int, atk: int, hp_rate: float, atk_rate: float, rank: Array) -> Array:
	return [floori(float(hp) * hp_rate + float(rank[0])), floori(float(atk) * atk_rate + float(rank[1])), floori(float(rank[2])), 
		floori(float(rank[3])), floori(float(rank[4]))]



static func mr_totals(ranks: Array, star: int) -> Array:
	var sum: Array = [0.0, 0.0, 0.0, 0.0, 0.0]
	for rank: Variant in ranks:
		if not rank is Array or (rank as Array).size() < 3:
			continue
		for node: Variant in rank[2]:
			var at: int = int(node[0])
			if at < 1 or at > star or (node[1] as Array).is_empty():
				continue
			for attr: Variant in (node[1] as Array) + (node[2] as Array):
				var slot: int = MR_ATTRS.find(int(attr[0]))
				if slot >= 0:
					sum[slot] = float(sum[slot]) + float(attr[2])
	return sum



static func skin_flags(skins: Dictionary, bags: Dictionary, id: int) -> Array:
	var held: Dictionary = {}
	for item: Variant in bags.get(6, []):
		if item is Dictionary and int(item.get("m_count", 0)) > 0:
			held[int(item.get("m_templateId", 0))] = true
	var flags: Array = [0, 0, 0, 0]
	for row: Variant in (skins.get(str(id), []) as Array) + (skins.get("0", []) as Array):
		var grade: int = int(row[1]) - 2
		if held.has(int(row[0])) and grade >= 0 and grade < 4:
			flags[grade] = 1
	return flags


static func skin_active(flags: Array, kind: int) -> bool:
	var count: int = int(flags[0]) + int(flags[1]) + int(flags[2]) + int(flags[3])
	match kind:
		1, 2, 3, 4:
			return int(flags[kind - 1]) == 1
		11:
			return count >= 1
		12:
			return count >= 2
		13:
			return count >= 3 and int(flags[3]) == 1
		14:
			return count >= 4
	return false



static func skin_val(rows: Array, flags: Array, kind: int) -> float:
	var sum: float = 0.0
	for row: Variant in rows:
		if int(row[2]) != 0 and int(row[2]) == kind and skin_active(flags, int(row[0])):
			sum += float(row[3])
	return sum


static func skin_buff(row: Array) -> bool:
	return int(row[1]) == 2 or (int(row[1]) == 3 and int(row[2]) >= 1 and int(row[2]) <= 9)



static func skin_desc(rows: Array, flags: Array) -> String:
	var order: Array = []
	var sums: Dictionary = {}
	for row: Variant in rows:
		if not skin_active(flags, int(row[0])) or skin_buff(row):
			continue
		var kind: int = int(row[2])
		if sums.has(kind):
			sums[kind] = float(sums[kind]) + float(row[3])
		else:
			order.append(kind)
			sums[kind] = float(row[3])
	var parts: PackedStringArray = []
	for kind: int in order:
		var value: float = float(sums[kind])
		var shown: String = (str(int(value * 100.0)) + "%") if value < 1.0 else (str(int(value)) if value == floorf(value) else str(value))
		parts.append((ATTR_NAMES[kind - 1] if kind >= 1 and kind <= ATTR_NAMES.size() else "") + "+" + shown)
	return " ".join(parts)


func _draw_radar(c: Vector2, r: float, values: Array) -> void :
	if values.size() < 6:
		return
	var ink: Color = Color(str(Atlas.RADAR["color"]))
	var shape: PackedVector2Array = PackedVector2Array()
	for i in range(6):
		shape.append((c + Vector2.UP.rotated(TAU / 6.0 * i) * r * maxf(0.07, float(values[i]))) * _f)
	draw_colored_polygon(shape, Color(ink, 0.4))
	shape.append(shape[0])
	draw_polyline(shape, ink, maxf(1.0, _f), true)

func _draw_tip() -> void :
	if FlashTip.show(self, _tip, _ctip):
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


func _swipe_once() -> bool:
	return _sheet_id.is_empty()

func _wheel(step: int, at: Vector2) -> void :
	if _sheet_id == "halo":
		if _halo_view().has_point(at):
			_halo_scroll(_halo_first + step)
		return
	if _sheet_id == "skin":
		if _skin_view().has_point(at):
			_skin_scroll(_skin_first + step)
		return
	if _sheet_id.is_empty() and not _renting():
		_leaf = clampi(_leaf + step, 0, _pages(_list().size()) - 1)

func _input(event: InputEvent) -> void :
	if not _sheet_id.is_empty() and not _renting() and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or _renting() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	match event.keycode:
		KEY_ESCAPE:
			closed.emit()
		KEY_LEFT:
			_step(-1)
		KEY_RIGHT:
			_step(1)
		KEY_UP:
			_step(-3)
		KEY_DOWN:
			_step(3)
		_:
			return
	get_viewport().set_input_as_handled()


func _double(id: String) -> bool:
	var again: bool = id == _last_id and _time - _last_at < DOUBLE
	_last_id = "" if again else id
	_last_at = _time
	return again



func _draw_pos(text: String, at: Vector2) -> void :
	var wide: float = 160.0
	if _fit_px(text, POS_PX, wide) >= POS_MIN:
		_fwords(text, BOLD, POS_PX, POS_INK, "l", at, wide, 1.5, 24.0)
		return
	var lines: Array = split_two(text)
	var px: float = minf(_fit_px(str(lines[0]), POS_TWO, wide), _fit_px(str(lines[1]), POS_TWO, wide))
	_fwords(str(lines[0]), BOLD, px, POS_INK, "l", at + Vector2(0, -5), wide, 1.5, 17.0, false)
	_fwords(str(lines[1]), BOLD, px, POS_INK, "l", at + Vector2(0, 12), wide, 1.5, 17.0, false)


func _fit_px(text: String, px: float, wide: float) -> float:
	var font: Font = _face(BOLD)
	var shown: float = px
	while shown > 8.0 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(shown * _f))).x > wide * _f:
		shown -= 1.0
	return shown


static func split_two(text: String) -> Array:
	var best: int = -1
	for i in range(text.length()):
		if text[i] == " " and (best < 0 or absi(i * 2 - text.length()) < absi(best * 2 - text.length())):
			best = i
	return [text, ""] if best < 0 else [text.substr(0, best), text.substr(best + 1)]


func _tap_tip(id: String) -> bool:
	return _sheet_id.is_empty() and (id.begins_with("skill:") or id in ["type", "dmap"] or id == "prof")

func _activate(id: String) -> void :
	if _sheet_id == "skin":

		var colon: int = id.find(":")
		var arg: int = int(id.substr(colon + 1)) if colon > 0 else 0
		match id.substr(0, colon) if colon > 0 else id:
			"skinq":

				if arg != _skin_q:
					_skin_q = arg
					_skin_first = 0
			"skin_use":
				_use_skin(arg)
			"skin_buy":
				_buy_skin(arg)
			"skin_conv":
				if not _renting():
					_open_skin_conv(arg)
			"skin_get":
				if not _renting():
					_open_get_skin(arg)
			"skin_tank":

				var tank: int = _skin_tank_of(arg)
				if tank > 0 and not tank_buy_asked.get_connections().is_empty():
					tank_buy_asked.emit(tank, SKIN_LACK, "")
				else:
					say("Chưa có tank. " + BUY_TODO)
			"skin_close":
				_close()
		match id:
			"skin:left":
				_skin_scroll(_skin_first - 1)
			"skin:right":
				_skin_scroll(_skin_first + 1)
			"skin:pgl":
				_skin_scroll(_skin_first - SKIN_COLS)
			"skin:pgr":
				_skin_scroll(_skin_first + SKIN_COLS)
		return
	if _sheet_id == "halo":

		if id.begins_with("use:"):
			_use_halo(int(id.substr(4)))
		match id:
			"halo_close":
				_close()
			"halo:left":
				_halo_scroll(_halo_first - 1)
			"halo:right":
				_halo_scroll(_halo_first + 1)
			"halo:pgl":
				_halo_scroll(_halo_first - HALO_COLS)
			"halo:pgr":
				_halo_scroll(_halo_first + HALO_COLS)
		return
	if _sheet_id == "level":

		if id.begins_with("up_item:"):
			guide_asked.emit(int(id.substr(8)))
		match id:
			"up_close":
				_close()
			"up_btn":
				_up_click()
		return
	if id.begins_with("tank:"):
		var again: bool = _double(id)
		_select(int(id.substr(5)))
		if again:
			_set_main()
	elif id.begins_with("filter:"):

		if id.substr(7) != _filter:
			_filter = id.substr(7)
			_leaf = 0
	elif id.begins_with("page:="):
		_leaf = int(id.substr(6))
	elif id.begins_with("page:"):
		_leaf = clampi(_leaf + int(id.substr(5)), 0, _pages(_list().size()) - 1)
	elif id.begins_with("tab:"):
		_tab = int(id.substr(4))
	elif id.begins_with("grade:"):
		_open_skin(int(id.substr(6)))
	match id:
		"back":
			closed.emit()
		"onbattle":
			_set_main()
		"levelup":
			_open("level")
		"halo":
			_open("halo")
		"skin", "face":
			_open_skin(0)
		"buy":


			if _pick > 0 and not tank_buy_asked.get_connections().is_empty():
				tank_buy_asked.emit(_pick, "", "")
			else:
				say(BUY_TODO)
		"rent":
			if _can_rent(_pick):
				_open_rent(_pick)
		"convitem":
			if not _renting():
				_open_convert(_pick)
		"convtank":
			if not _renting():
				_open_ask(_pick)
		"rank":
			_hold = true
			page_asked.emit("rank")

func chat_busy() -> bool:
	return true

func _open(id: String) -> void :
	var rec: Dictionary = _rec()
	var inst: Dictionary = _own(rec)
	if rec.is_empty() or (id == "level" and inst.is_empty()):
		return
	_sheet_id = id
	_hover = ""
	_up_reset()
	if id == "halo":

		_halo_uuid = str((inst if not inst.is_empty() else rec.get("inst", {})).get("m_tankUuid", ""))
		_halo_first = 0
		_halo_grab = []
	if not client.bag_loaded:
		client.request_bags()


func _open_skin(quality: int) -> void :
	if _rec().is_empty():
		return
	_sheet_id = "skin"
	_hover = ""
	_skin_q = quality
	_skin_first = 0
	_skin_grab = []
	if not client.bag_loaded:
		client.request_bags()

func _close() -> void :
	_sheet_id = ""
	_halo_grab = []
	_skin_grab = []
	_up_reset()


func _up_reset() -> void :
	_up_frame = -1.0
	_up_tween = []
	_up_seen = []


func _own(rec: Dictionary) -> Dictionary:
	var best: Dictionary = {}
	for inst: Dictionary in client.tanks.values():
		if int(inst.get("m_tpltId", 0)) == int(rec.get("id", 0)) and int(inst.get("m_contType", -1)) == GarageModel.OWN\
		and (best.is_empty() or int(inst.get("m_level", 1)) > int(best.get("m_level", 1))):
			best = inst
	return best


func _use_halo(item: int) -> void :
	if _halo_uuid.is_empty() or not client.tanks.has(_halo_uuid) or not _wait.is_empty():
		return
	var worn: int = int(client.tanks[_halo_uuid].get("m_haloId", 0))
	if (worn == 0) if item == HALO_MASTER else (worn == item or _halo_bag(item).is_empty()):
		return
	var halo: int = 0 if item == HALO_MASTER else item
	var label: String = ""
	for row: Array in Halo.HALOS:
		if int(row[0]) == halo:
			label = str(row[2])
	if halo > 0 and label.is_empty():
		return
	if client.use_halo(_halo_uuid, halo):
		_wait = ["halo", _time + 4.0, label]
	else:
		say("Chưa đổi được vòng sáng lúc này.")
	_close()



func _up_click() -> void :
	var rec: Dictionary = _rec()
	var inst: Dictionary = _own(rec)
	if inst.is_empty() or not _wait.is_empty():
		return
	var st: Dictionary = up_state(pack.garage, GarUp.UP_ITEMS, int(rec.id), inst)
	if str(st.mode) == "top":
		say(GarUp.TIP_TOP)
		return
	if not client.bag_loaded:
		say("Đang tải túi đồ…")
		return
	if not up_enough(st.items, client.bags, pack.bag.get("items", {})):
		say(GarUp.TIP_SHORT)
		return
	if _time < _dc1_calm:
		return
	var uuid: String = str(inst.get("m_tankUuid", ""))
	if str(st.mode) == "strengthen":
		if client.strengthen_tank(uuid):
			_wait = ["strengthen", _time + 5.0, "bước %d" % (int(st.stth) + 1)]
		else:
			say("Chưa cường hoá được lúc này.")
	elif client.level_up_tank(uuid):
		_wait = ["up", _time + 5.0, "%s đã lên LV.%d" % [str(rec.name), int(st.level) + 1]]
	else:
		say("Chưa tăng cấp được lúc này.")


func _on_tank_changed(_uuid: String, op: int) -> void :
	_stale = true
	if _wait.is_empty() or not is_visible_in_tree():
		return
	var label: String = str(_wait[2])
	match [str(_wait[0]), op]:
		["skin", 10]:
			say("Đã mặc %s." % label)
		["halo", 20]:
			say("Đã gỡ vòng sáng." if label.is_empty() else "Đã dùng %s." % label)
		["halo", 21]:
			say("Không đổi được vòng sáng.")
		["strengthen", 4]:
			say("Cường hoá thành công %s." % label)
		["strengthen", 5]:
			say("Cường hoá không thành công (thiếu nguyên liệu hoặc tiền).")
		["up", 2]:
			say("%s." % label)
		["up", 3]:
			say("Tăng cấp không thành công.")
		_:
			return
	if str(_wait[0]) in ["up", "strengthen"]:
		_dc1_calm = _time + DC1_CALM
	_wait = []




func _draw_up(rec: Dictionary) -> void :
	draw_rect(Rect2(Vector2.ZERO, size), SKIN_DIM)
	_hit("panel", Rect2(Vector2.ZERO, size), false)
	var w: Vector2 = _centre(float(GarUp.SIZE[0]), float(GarUp.SIZE[1]))
	_fblit("gar_up_frame", w + _v(GarUp.FRAME_AT))
	_fbutton("up_close", "public_button_close", w + _v(GarUp.CLOSE))
	var inst: Dictionary = _own(rec)
	var id: int = int(rec.id)
	var st: Dictionary = up_state(pack.garage, GarUp.UP_ITEMS, id, inst)
	var mode: String = str(st.mode)
	var level: int = int(st.level)
	var stth: int = int(st.stth)
	var c: Dictionary = GarUp.CENTRES
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), id, level, inst)
	_draw_pod(rec, ext, TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(inst.get("m_haloId", 0)), level), w + _v(c["avatar"]))
	_fcentre("gar_up_lv%d" % clampi(level, 0, 11), w + _v(c["imgCurrentLevel"]))
	if mode != "top":
		_fcentre("gar_up_rank%d" % clampi(stth, 0, 10), w + _v(c["imgCurSLevel"]))
		_fcentre("gar_up_rank%d" % clampi(stth + 1, 0, 10) if mode == "strengthen" else "gar_up_lv%d" % clampi(level + 1, 0, 11), w + _v(c["imgNextSLevel"]))
	var now: Array = GarageModel.stats(pack.garage, id, level, stth)
	var next: Array = GarageModel.stats(pack.garage, id, int(st.next[0]), int(st.next[1]))
	var t: Dictionary = GarUp.TEXTS
	for i in range(UP_ROWS.size()):
		var row: Array = UP_ROWS[i]
		var name_spec: Array = t[str(row[0])]
		_fwords(str(GarUp.LABELS[i]), BOLD, float(name_spec[4]), Color.WHITE, "l", w + _v(name_spec), float(name_spec[2]))
		var k: int = int(row[3])
		if k >= now.size() or k >= next.size():
			continue
		var cur_spec: Array = t[str(row[1])]
		var next_spec: Array = t[str(row[2])]
		var a: int = int(now[k][1])
		var b: int = int(next[k][1])
		_fwords(str(a), BOLD, float(cur_spec[4]), Color.WHITE, "r", w + _v(cur_spec), float(cur_spec[2]))
		_fwords(str(b), BOLD, float(next_spec[4]), Color(GarUp.NEXT) if b > a else Color.WHITE, "l", w + _v(next_spec), float(next_spec[2]))
	var full: bool = bool(st.top) and mode != "strengthen"
	var n: Dictionary = GarUp.NODES
	if full:

		_up_reset()
		_fblit("gar_up_full", w + _v(n["imgFullStrengthan"]))
	else:
		var most: int = int(st.max)
		_fblit("gar_up_prog", w + _v(GarUp.PROG_AT))
		_draw_up_bar(w + _v(GarUp.PROGRESS["at"]), _up_progress(level, stth, most))
		var hb: Array = n["hbLevel"]
		for i in range(mini(most, 10)):
			_fblit("gar_up_rank%d" % (i + 1), w + Vector2(up_star_x(i, mini(most, 10), float(hb[0]), float(hb[2])), float(hb[1])))
		if mode != "top":
			_fblit("gar_up_lv%d" % clampi(level + 1, 0, 11), w + _v(n["imgNextLevelOverBar"]))

		var p: Array = t["lblUpgradeProgress"]
		_fwords("%d%%" % up_pct(stth, most), BOLD, float(p[4]), Color(str(p[5])), "l", w + _v(p), 80.0, 1.0, 0.0, false, UP_GLOW)
	var shown: Array = []
	if mode != "top":
		shown = (st.items as Array).filter( func(row: Array) -> bool: return int(row[1]) > 0)
		var items: Dictionary = pack.bag.get("items", {})
		var stamp: int = int(Time.get_unix_time_from_system())
		for i in range(shown.size()):
			_draw_up_cell(shown[i], w + Vector2(up_cell_x(i, shown.size()), float(GarUp.CELLS[0])), items, stamp)
		if shown.size() < 3 and not full:
			_fblit("gar_up_tip", w + _v(n["imgItemTip"]))
	var at: Vector2 = w + _v(n["btnUpgrade"])
	if full:
		_fblit("gar_up_btn_off", at)
	else:
		_fbutton("up_btn", "gar_up_btn", at)


func _fcentre(name: String, c: Vector2) -> Rect2:
	return _fblit(name, c - (_cell_size(name) / 2.0).floor())


func _draw_up_bar(at: Vector2, frame: int) -> void :
	var p: Dictionary = GarUp.PROGRESS
	if frame <= 1:
		return
	frame = mini(frame, int(p["frames"]))
	_fblit("gar_up_bar_cap", at)
	_fblit("gar_up_bar_head", at + Vector2(float(p["head_tx"][frame]) + float(p["head_dx"]), 0))
	var body: float = float(p["body_w"][frame])
	if body > 0.0:
		_fblit("gar_up_bar_body", at + Vector2(float(p["body_x"]), 0), body)



func _up_progress(level: int, stth: int, most: int) -> int:
	var frames: float = float(GarUp.PROGRESS["frames"])
	var key: Array = [level, stth, most]
	if _up_frame < 0.0:
		_up_frame = float(up_first(stth, most))
		_up_tween = []
	elif key != _up_seen:
		var target: float = up_ratio(stth, most)
		var start: float = _up_frame / frames
		if target < start:
			_up_frame = float(int(target * frames))
			_up_tween = []
		else:
			_up_tween = [start, target, _time]
	_up_seen = key
	if not _up_tween.is_empty():
		var k: float = clampf((_time - float(_up_tween[2])) / UP_TWEEN, 0.0, 1.0)
		_up_frame = float(int(up_ease(float(_up_tween[0]), float(_up_tween[1]), k) * frames))
		if k >= 1.0:
			_up_tween = []
	return int(_up_frame)



func _draw_up_cell(row: Array, cell: Vector2, items: Dictionary, stamp: int) -> void :
	var item: int = int(row[0])
	var need: int = int(row[1])
	var entry: Array = up_entry(items, item)
	var q: int = int(entry[3]) if entry.size() > 3 else 1
	var nodes: Dictionary = GarUp.CELL_NODES
	_fblit("gar_up_item_bg", cell + _v(nodes["image1"]))
	_fblit("gar_up_q_" + str(GarUp.QUALITY[up_quality(q)]), cell + _v(nodes["imgQuality"]))
	var box: Array = nodes["imgItem"]
	var rect: Rect2 = Rect2((cell + _v(box)) * _f, Vector2(float(box[2]), float(box[3])) * _f)
	var key: String = str(entry[2]) if entry.size() > 2 else ""
	var folder: String = "av" if entry.size() > 5 and int(entry[5]) == 4 else "it"
	var picture: Texture2D = pack.picture("l/%s/%s.webp" % [folder, key]) if not key.is_empty() else null
	if picture != null:
		draw_texture_rect(picture, rect, false)
	var title: String = BagModel.clean(str(entry[0])) if not entry.is_empty() else "Vật phẩm %d" % item
	var label: Array = GarUp.CELL_TEXTS["lblItemName"]
	_fbox_up(title, float(label[4]), Color(str(label[5])), UP_NAME_GLOW, cell + _v(label), float(label[2]))
	var have: int = up_have(client.bags, items, item)
	var num: Array = GarUp.CELL_TEXTS["lblNum"]
	_fwords("%d/%d" % [have, need], BOLD, float(num[4]), Color(GarUp.SHORT) if have < need else Color(str(num[5])), "c", cell + _v(num), float(num[2]))
	if have < need and can_convert(GarUp.CONVERT, item, need - have, client.bags, items, client.currency, stamp):
		_fblit("gar_up_convert", cell + _v(nodes["imgConvertTip"]))
	var id: String = "up_item:%d" % item
	_hit(id, rect, false)
	if _hover == id:
		_tip = [rect, "", "", Color.WHITE, up_tip(pack.bag, item, entry)]


func _fbox_up(text: String, px: float, color: Color, rim: Color, at: Vector2, wide: float) -> void :
	var font_size: int = maxi(6, roundi(px * _f))
	var high: float = ARIAL_BOLD.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, font_size).y / _f
	var origin: Vector2 = Vector2(at.x, at.y - 2.0 - high) * _f + Vector2(0, ARIAL_BOLD.get_ascent(font_size))
	draw_multiline_string_outline(ARIAL_BOLD, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, font_size, -1, maxi(1, roundi(_f)), rim)
	draw_multiline_string(ARIAL_BOLD, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, font_size, -1, color)




static func up_state(data: Dictionary, ups: Dictionary, id: int, inst: Dictionary) -> Dictionary:
	var level: int = maxi(1, int(inst.get("m_level", 1)))
	var stth: int = maxi(0, int(inst.get("m_stthLevel", 0)))
	var levels: Dictionary = data.get("levels", {}).get(str(id), {})
	var most: int = up_steps(data, id, level)
	var out: Dictionary = {"mode": "top", "level": level, "stth": stth, "max": most, "top": not levels.has(str(level + 1)), "items": [], "next": [level, stth]}
	if stth < most:
		out.mode = "strengthen"
		out.items = GarageModel.step(data, id, level, stth + 1).get("cost", [])
		out.next = [level, stth + 1]
	elif levels.has(str(level)) and not out.top:
		out.mode = "up"
		out.items = ups.get(str(id), {}).get(str(level), [])
		out.next = [level + 1, 0]
	return out


static func up_steps(data: Dictionary, id: int, level: int) -> int:
	var rows: Dictionary = data.get("strengthen", {}).get(str(id), {}).get(str(level), {})
	var n: int = 0
	while rows.has(str(n + 1)):
		n += 1
	return n



static func up_tip(bag: Dictionary, item: int, entry: Array) -> Dictionary:
	var extra: Dictionary = {}
	if not (bag.get("items", {}) as Dictionary).has(str(item)) and entry.size() > 5:
		extra = {"name": BagModel.clean(str(entry[0])), "desc": BagModel.clean(str(entry[1])), "quality": int(entry[3])}
		if not str(entry[2]).is_empty():
			extra["art"] = "l/%s/%s.webp" % ["av" if int(entry[5]) == 4 else "it", str(entry[2])]
			extra["icon"] = extra["art"]
	return FlashTip.simulate(item, bag, extra)

static func up_entry(items: Dictionary, item: int) -> Array:
	var row: Array = items.get(str(item), [])
	if not row.is_empty():
		return row
	var extra: Array = GarUp.ITEMS.get(str(item), [])
	return [] if extra.size() < 5 else [extra[0], extra[1], extra[2], extra[3], 0, extra[4]]


static func up_have(bags: Dictionary, items: Dictionary, item: int) -> int:
	var entry: Array = up_entry(items, item)
	var total: int = 0
	for inst: Variant in bags.get(int(entry[5]) if entry.size() > 5 else 3, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == item:
			total += maxi(1, int(inst.get("m_count", 1)))
	return total


static func up_enough(need: Array, bags: Dictionary, items: Dictionary) -> bool:
	for row: Array in need:
		if int(row[1]) > 0 and up_have(bags, items, int(row[0])) < int(row[1]):
			return false
	return true


static func up_ready(st: Dictionary, table: Dictionary, bags: Dictionary, items: Dictionary, purse: Dictionary, now: int) -> bool:
	if str(st.mode) == "top" or (str(st.mode) == "up" and (st.items as Array).is_empty()):
		return false
	for row: Array in st.items:
		var have: int = up_have(bags, items, int(row[0]))
		if int(row[0]) != 0 and have < int(row[1]) and not can_convert(table, int(row[0]), int(row[1]) - have, bags, items, purse, now):
			return false
	return true



static func can_convert(table: Dictionary, item: int, n: int, bags: Dictionary, items: Dictionary, purse: Dictionary, now: int, depth: int = 0) -> bool:
	if depth > UP_DEPTH:
		return false
	for recipe: Variant in table.get(str(item), []):
		if now < int(recipe[3]) or (int(recipe[4]) != 0 and now > int(recipe[4])):
			continue
		if not up_coin(int(recipe[0]), int(recipe[1]) * n, bags, items, purse):
			continue
		var ok: bool = true
		for part: Variant in recipe[2]:
			var need: int = int(part[1]) * n
			if int(part[0]) == 0 or need == 0:
				continue
			var have: int = up_have(bags, items, int(part[0]))
			if have < need and not can_convert(table, int(part[0]), need - have, bags, items, purse, now, depth + 1):
				ok = false
				break
		if ok:
			return true
	return false



static func up_coin(kind: int, cost: int, bags: Dictionary, items: Dictionary, purse: Dictionary) -> bool:
	match kind:
		0:
			return true
		1:
			return int(purse.get("m_iCash", 0)) >= cost
		2:
			return int(purse.get("m_iGolden", 0)) >= cost
		3:
			return int(purse.get("m_iSilver", 0)) >= cost
		7:
			return up_have(bags, items, UP_TOKEN) >= cost
	return false


static func up_quality(q: int) -> int:
	return 0 if q <= 1 else mini(q - 1, 4)


static func up_first(stth: int, most: int) -> int:
	return int(float(stth) * float(GarUp.PROGRESS["first"]) / float(most)) if most > 0 else 0

static func up_ratio(stth: int, most: int) -> float:
	return float(stth) / float(most) if most > 0 else 0.0


static func up_pct(stth: int, most: int) -> int:
	return int(float(stth) * 100.0 / float(most)) if most > 0 else 0


static func up_ease(a: float, b: float, k: float) -> float:
	return a + (b - a) * (1.0 - (1.0 - k) * (1.0 - k))


static func up_star_x(i: int, n: int, left: float, wide: float) -> float:
	var gap: float = maxf(0.0, (wide - float(GarUp.STAR) * n) / n) if n > 0 else 0.0
	return floorf(left + gap / 2.0 + i * (float(GarUp.STAR) + gap))


static func up_cell_x(i: int, n: int) -> float:
	return float(int((float(GarUp.SIZE[0]) - float(GarUp.CELLS[1]) * n) / 2.0) + int(GarUp.CELLS[1]) * i)



func _draw_halo(rec: Dictionary) -> void :
	_hit("panel", Rect2(Vector2.ZERO, size), false)
	var w: Vector2 = _centre(float(Halo.SIZE[0]), float(Halo.SIZE[1]))
	_fblit("gar_halo_frame", w + _v(Halo.FRAME_AT))
	_fbutton("halo_close", "public_button_close", w + _v(Halo.CLOSE))
	var uuid: String = _halo_uuid if client.tanks.has(_halo_uuid) else ""
	var inst: Dictionary = client.tanks.get(uuid, {}) if not uuid.is_empty() else {}
	if inst.is_empty():

		inst = {"m_tpltId": int(rec.id), "m_level": int(rec.level), "m_haloId": 0, "m_externalId": 0}
	var level: int = int(inst.get("m_level", rec.level))
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(rec.id), level, inst)
	var worn: int = int(inst.get("m_haloId", 0))
	var known: Dictionary = pack.fx.get("halo_ui", {})
	var now: int = int(Time.get_unix_time_from_system())
	var n: Dictionary = Halo.NODES
	var t: Dictionary = Halo.TEXTS
	var list: Vector2 = w + Vector2(float(Halo.LIST[0]), float(Halo.LIST[1]))
	_halo_first = clampi(_halo_first, 0, maxi(0, Halo.HALOS.size() - HALO_COLS))
	var mouse: Vector2 = get_local_mouse_position()
	for i in range(_halo_first, mini(Halo.HALOS.size(), _halo_first + HALO_COLS)):
		var row: Array = Halo.HALOS[i]
		var item: int = int(row[0])
		var master: bool = item == HALO_MASTER
		var cell: Vector2 = list + Vector2((i - _halo_first) * float(Halo.CELL[0]), 0)
		_fblit("gar_halo_booth", cell + _v(n["booth"]))

		var shown: int = TankPortrait.halo_item(known, 0, level) if master else (item if known.has(str(item)) else 0)
		var box: Array = n["avatar"]
		_draw_pod(rec, ext, shown, cell + Vector2(float(box[0]) + float(box[2]) / 2.0, float(box[1]) + float(box[3]) / 2.0))
		var title: Array = t["lblHaloName"]
		var name: String = HALO_DEFAULT if master else str(row[2])
		var tint: Color = Color(str(title[5])) if master else HALO_QUALITY.get(int(row[1]), Color(str(title[5])))
		_halo_label(name, title, tint, cell, "lblHaloName")
		if not master:
			var from: Array = t["lblFrom"]
			_halo_label(str(row[3]), from, Color(str(from[5])), cell, "lblFrom")
		var bag: Dictionary = _halo_bag(item)
		if not bag.is_empty():
			var left: Array = t["lblRemainTime"]
			_halo_label(_halo_left(bag, now), left, Color(str(left[5])), cell, "lblRemainTime")
		if not uuid.is_empty():
			var use: bool = worn != 0 if master else (worn != item and not bag.is_empty())
			var used: bool = worn == 0 if master else worn == item
			if use:
				_fbutton("use:%d" % item, "gar_halo_use", cell + _v(n["btnUse"]))
			if used:
				_fblit("gar_halo_used", cell + _v(n["imgUsingHalo"]))

		var face: Rect2 = Rect2((cell + Vector2(float(box[0]), float(box[1]))) * _f, Vector2(float(box[2]), float(box[3])) * _f)
		if not master and _hover == "panel" and face.has_point(mouse):
			_tip = [face, "", "", Color.WHITE, FlashTip.simulate(item, pack.bag, {"name": str(row[2]), "quality": int(row[1]), "desc": str(row[3]), 
				"type": 55, "tip_opts": {"no_time": true}})]
	_halo_bar = []
	if Halo.HALOS.size() > HALO_COLS:
		_draw_halo_bar(list + Vector2(0, float(Halo.LIST[3]) - float(Halo.BAR)), float(Halo.LIST[2]))


func _halo_label(text: String, spec: Array, color: Color, cell: Vector2, key: String) -> void :
	if text.is_empty():
		return
	var px: float = float(spec[4])
	var font: Font = ARIAL_BOLD if int(spec[6]) == 1 else ARIAL
	var wide: float = float(spec[2])
	_fwords(_trunc(text, font, px, wide), font, px, color, str(spec[7]), cell + _v(spec), wide, 1.0, 0.0, false, Color(str(Halo.GLOW.get(key, "000000")), 0.9))


func _trunc(text: String, font: Font, px: float, wide: float) -> String:
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	var room: float = (wide - 4.0) * _f
	if face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= room:
		return text
	var cut: String = text
	while cut.length() > 1 and face.get_string_size(cut + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
		cut = cut.substr(0, cut.length() - 1)
	return cut.strip_edges(false, true) + "..."


func _halo_bag(item: int) -> Dictionary:
	for inst: Dictionary in client.bags.get(9, []):
		if int(inst.get("m_templateId", 0)) == item:
			return inst
	return {}



static func _halo_left(inst: Dictionary, now: int) -> String:
	var life: int = int(inst.get("m_lifeTime", 0))
	var timed: bool = (int(inst.get("m_extFlag", 0)) & 4) != 0
	if timed and life <= now:
		return HALO_OVER
	var day: int = maxi(0, ceili((life - now) / 86400.0)) if timed else life
	return HALO_LEFT.replace("@day@", str(day))



func _draw_halo_bar(at: Vector2, wide: float) -> void :
	var bar: float = float(Halo.BAR)
	var track: float = wide - bar * 2.0
	var most: int = Halo.HALOS.size() - HALO_COLS
	_fblit("gar_hsb_bk", at + Vector2(bar, 0), track, bar)
	_fbutton("halo:left", "gar_hsb_left", at)
	_fbutton("halo:right", "gar_hsb_right", at + Vector2(bar + track, 0))
	var thumb: float = maxf(20.0, track * HALO_COLS / float(Halo.HALOS.size()))
	var x: float = at.x + bar + (track - thumb) * clampf(float(_halo_first) / float(most), 0.0, 1.0)
	_hit("halo:pgl", Rect2(Vector2(at.x + bar, at.y) * _f, Vector2(x - at.x - bar, bar) * _f), false)
	_hit("halo:pgr", Rect2(Vector2(x + thumb, at.y) * _f, Vector2(at.x + bar + track - x - thumb, bar) * _f), false)
	_hslice("gar_hsb_thumb", Vector2(x, at.y), thumb, 4.0, _glow("slide:halo"))
	_hit("slide:halo", Rect2(Vector2(x, at.y) * _f, Vector2(thumb, bar) * _f), false)
	_halo_bar = [track, thumb, most]


func _hslice(cell_name: String, at: Vector2, wide: float, cap: float, tint: Color) -> void :
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var src: Rect2 = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	var high: float = src.size.y
	var end: float = minf(cap, floorf(minf(wide, src.size.x) / 2.0))
	draw_texture_rect_region(cell[0], Rect2(at * _f, Vector2(end, high) * _f), Rect2(src.position, Vector2(end, high)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(end, 0)) * _f, Vector2(wide - 2.0 * end, high) * _f), 
		Rect2(src.position + Vector2(end, 0), Vector2(src.size.x - 2.0 * end, high)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(wide - end, 0)) * _f, Vector2(end, high) * _f), 
		Rect2(src.position + Vector2(src.size.x - end, 0), Vector2(end, high)), tint)


func _halo_view() -> Rect2:
	return Rect2(_centre(float(Halo.SIZE[0]), float(Halo.SIZE[1])) * _f, Vector2(float(Halo.SIZE[0]), float(Halo.SIZE[1])) * _f)

func _halo_scroll(first: int) -> void :
	_halo_first = clampi(first, 0, maxi(0, Halo.HALOS.size() - HALO_COLS))




func _draw_skin_view(rec: Dictionary) -> void :
	draw_rect(Rect2(Vector2.ZERO, size), SKIN_DIM)
	_hit("panel", Rect2(Vector2.ZERO, size), false)
	var w: Vector2 = _centre(float(GarSkin.SIZE[0]), float(GarSkin.SIZE[1]))
	_fblit("gar_skin_frame", w + _v(GarSkin.FRAME_AT))
	_fbutton("skin_close", "public_button_close", w + _v(GarSkin.CLOSE))
	var id: int = int(rec.id)

	var tabs: Array = skin_filters(GarSkin.SKINS.get(str(id), []))
	var x: float = float(GarSkin.FILTER[0])
	for tab: Array in SKIN_TABS:
		var q: int = int(tab[0])
		if not tabs.has(q):
			continue
		_fbutton("skinq:%d" % q, str(tab[1]) + ("_on" if q == _skin_q else ""), w + Vector2(x, float(GarSkin.FILTER[1])))
		x += float(GarSkin.FILTER[3]) + float(GarSkin.FILTER[2])
	var rows: Array = pack.garagex.get("skin", {}).get(str(id), [])
	var flags: Array = skin_flags(pack.garagex.get("skins", {}), client.bags, id)
	for kind_row: Array in SKIN_KINDS:
		var kind: int = int(kind_row[0])
		var on: bool = skin_active(flags, kind)
		var title: Array = GarSkin.LABELS[str(kind_row[1])]
		var attr: Array = GarSkin.LABELS[str(kind_row[2])]
		_fbox(str(SKIN_TITLES[kind]), float(title[4]), Color(str(title[5])) if on else SKIN_OFF, w + _v(title), float(title[2]), "l", float(title[3]))
		var text: String = skin_type_desc(rows, kind, GarSkin.BUFF)
		var tail: String = str(kind_row[4])
		if not tail.is_empty():
			text = tail if text.is_empty() else text + " " + tail
		_fbox(text, float(attr[4]), Color(str(attr[5])) if on else SKIN_OFF, w + _v(attr), float(attr[2]), "l", float(attr[3]))
		if not str(kind_row[3]).is_empty():
			_fblit("gar_skin_act_on" if on else "gar_skin_act_off", w + _v(GarSkin.MARKS[str(kind_row[3])]))
	var total: Array = GarSkin.LABELS["lbltTotalAttr"]
	_fwords(skin_desc(rows, flags), BOLD, float(total[4]), Color(str(total[5])), "c", w + _v(total), float(total[2]), 1.0)
	var inst: Dictionary = _skin_inst(rec)
	var entries: Array = _skin_entries(rec, inst)
	_skin_first = clampi(_skin_first, 0, maxi(0, entries.size() - SKIN_COLS))
	if entries.is_empty():
		_fblit("gar_skin_none", w + _v(GarSkin.NO_SKIN))
	var list: Vector2 = w + Vector2(float(GarSkin.LIST[0]), float(GarSkin.LIST[1]))
	var now: int = int(Time.get_unix_time_from_system())
	for i in range(_skin_first, mini(entries.size(), _skin_first + SKIN_COLS)):
		_draw_skin_cell(rec, inst, entries[i], list + Vector2((i - _skin_first) * float(GarSkin.CELL[0]), 0), now)
	_skin_bar = []
	if entries.size() > SKIN_COLS:
		_draw_skin_bar(list + Vector2(0, float(GarSkin.LIST[3]) - float(GarSkin.BAR)), float(GarSkin.LIST[2]), entries.size())


func _draw_skin_cell(rec: Dictionary, inst: Dictionary, entry: Dictionary, cell: Vector2, now: int) -> void :
	var base: Dictionary = GarSkin.CELL_BASE
	var texts: Dictionary = GarSkin.CELL_TEXTS
	var nodes: Dictionary = GarSkin.CELL_NODES
	var item: int = int(entry.item)
	var row: Array = entry.row
	_fblit("gar_skin_booth", cell + _v(base["booth"]))
	var box: Array = base["avatar"]
	_draw_pod(rec, int(entry.ext), 0, cell + Vector2(float(box[0]) + float(box[2]) / 2.0, float(box[1]) + float(box[3]) / 2.0))
	var name_spec: Array = texts["lblName"]
	var tint: Color = Color.WHITE
	if item == 0:
		_fwords(str(rec.name), BOLD, float(name_spec[4]), Color.WHITE, "c", cell + Vector2(0, float(name_spec[1])), float(GarSkin.CELL[0]), 1.0)
	else:
		var q: int = int(row[2])
		tint = HALO_QUALITY.get(q, Color.WHITE if q <= 1 else HALO_QUALITY[5])
		_fwords(str(row[3]), BOLD, float(name_spec[4]), tint, "c", cell + Vector2(0, float(name_spec[1])), float(GarSkin.CELL[0]), 1.0)
		_fblit("gar_skin_qbg", cell + _v(base["imgQuality"]))
		var grade: Array = texts["lblQuality"]
		_fwords(GarageModel.grade(q), BOLD, float(grade[4]), tint, "l", cell + _v(grade), float(grade[2]), 1.0)
	var level: int = int(inst.get("m_level", 1))
	var state: String = "HAS" if item == 0 else skin_state(row, bool(entry["has"]), level, GarSkin.SALE, GarSkin.CHIP)
	match state:
		"HAS":
			var n: Dictionary = nodes["HAS"]
			if entry.equip:
				_fblit("gar_skin_equip", cell + _v(n["imgEquire"]))
			else:
				_fbutton("skin_use:%d" % item, "gar_skin_use", cell + _v(n["btnUse"]))
			var bag: Dictionary = entry.bag
			if int(bag.get("m_lifeTime", 0)) > 0:
				var left: Array = texts["lblAvatarTime"]
				_fwords(skin_left(bag, now), BOLD, float(left[4]), Color(str(left[5])), "c", cell + _v(left), float(left[2]), 1.0)
		"NORMAL":
			var n: Dictionary = nodes["NORMAL"]
			if entry.equip:
				_fblit("gar_skin_equip", cell + _v(n["imgEquire"]))
			_fbutton("skin_conv:%d" % item, "gar_skin_convert", cell + _v(n["btnConvert"]))
		"LEVEL":
			_skin_level_tip(cell + Vector2(115, float(GarSkin.TIP_Y["NO_WAY"])), int(row[4]))
		"SELL", "SELL_PRICE_2":
			var n: Dictionary = nodes[state]
			var sale: Array = GarSkin.SALE[str(item)]
			var two: bool = state == "SELL_PRICE_2"
			_fblit("gar_skin_price_bg", cell + _v(n["image1"]))
			var com: Array = n["comPrice"]
			var at: Vector2 = cell + Vector2(float(com[0]) + (float(com[2]) - float(GarSkin.PRICE["two" if two else "one"])) / 2.0, float(com[1]))
			_skin_price(at, int(sale[0]), int(sale[1]))
			if two:
				_fwords(SKIN_OR, BOLD, 14, Color(str(GarSkin.PRICE["or_color"])), "l", at + Vector2(float(GarSkin.PRICE["or_x"]), float(GarSkin.PRICE["or_y"])), 40, 1.0)
				_skin_price(at + Vector2(float(GarSkin.PRICE["second_x"]), 0), int(sale[2]), int(sale[3]))
			_fbutton("skin_buy:%d" % item, "gar_skin_buy", cell + _v(n["btnBuy"]))
		"NEW_WAY_ACHIEVE":


			var a: Dictionary = GarSkin.ACHIEVE
			var com: Vector2 = cell + _v(a["at"])
			if _skin_owned(inst):
				_fblit("gar_skin_ach_icon", com + _v(a["icon"]))
				_fblit("gar_skin_ach_bar", com + _v(a["bar"]))
				var chip: Array = OpenSkin.OpenSkinAtlas.CHIP.get(str(item), [])
				if not chip.is_empty() and int(chip[0]) > 0:
					var have: int = int(client.skin_chips.get(item, 0))
					var bar: Array = a[""]["imgProgress"]
					var fill: float = floorf(float(bar[2]) * clampf(float(have) / float(chip[0]), 0.0, 1.0))
					if fill > 0.0:
						_fpart("gar_skin_ach_slot", com + _v(bar), Rect2(0, 0, fill, float(bar[3])))
					var num: Array = GarSkin.ACHIEVE_TEXTS["lblNum"]
					_fwords("%d/%d" % [have, int(chip[0])], BOLD, float(num[4]), Color(str(num[5])), "c", com + _v(num), float(num[2]), 1.0)
				_fbutton("skin_get:%d" % item, "gar_skin_ach_get", com + _v(a[""]["btnGetSkin"]))
			else:
				var tips: Array = GarSkin.ACHIEVE_TEXTS["lblTips"]
				var spot: Array = a["NoTank"]["lblTips"]
				_fwords(SKIN_LACK, BOLD, float(tips[4]), Color(str(tips[5])), "c", com + _v(spot), float(spot[2]), 1.0)
				_fbutton("skin_tank:%d" % item, "gar_skin_ach_buytank", com + _v(a["NoTank"]["btnBuyTank"]))

	if item != 0:
		var face: Rect2 = Rect2((cell + Vector2(float(box[0]), float(box[1]))) * _f, Vector2(float(box[2]), float(box[3])) * _f)
		if _hover == "panel" and face.has_point(get_local_mouse_position()):
			var look: String = GarageModel.face(pack.garage, int(row[1]))
			_tip = [face, "", "", Color.WHITE, FlashTip.simulate(item, pack.bag, {"type": ItemTipT.T_TANK_SKIN, "name": str(row[3]), 
				"quality": int(row[2]), "desc": str(row[7]), "face": "l/t/%s.webp" % look if not look.is_empty() else "", "tip_opts": {"no_time": true}})]


func _skin_level_tip(mid: Vector2, need: int) -> void :
	var parts: Array = [SKIN_LEVEL[0], SKIN_LEVEL[1] %need, SKIN_LEVEL[2]]
	var face: Font = _face(REGULAR)
	var font_size: int = maxi(6, roundi(13.0 * _f))
	var widths: Array = parts.map( func(part: String) -> float: return face.get_string_size(part, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f)
	var x: float = mid.x - (float(widths[0]) + float(widths[1]) + float(widths[2])) / 2.0
	for i in range(3):
		_fwords(str(parts[i]), REGULAR, 13, Color("ff0000") if i == 1 else Color.WHITE, "l", Vector2(x, mid.y), float(widths[i]) + 2.0, 1.0, 0.0, false)
		x += float(widths[i])


func _skin_price(at: Vector2, ct: int, price: int) -> void :
	var icon: Array = GarSkin.PRICE["icon"]
	_fblit("gar_skin_coin%d" % ct, at + _v(icon), float(icon[2]), float(icon[3]))
	var count: Array = GarSkin.PRICE["count"]
	var short: bool = ShopModel.balance(client.currency, ct) < price
	_fwords(Mysterious.comma(price), BOLD, 14, Color(str(GarSkin.PRICE["short" if short else "color"])), "l", at + Vector2(float(count[0]), float(count[1])), float(count[2]), 1.0)


func _draw_skin_bar(at: Vector2, wide: float, count: int) -> void :
	var bar: float = float(GarSkin.BAR)
	var track: float = wide - bar * 2.0
	var most: int = count - SKIN_COLS
	_fblit("gar_hsb_bk", at + Vector2(bar, 0), track, bar)
	_fbutton("skin:left", "gar_hsb_left", at)
	_fbutton("skin:right", "gar_hsb_right", at + Vector2(bar + track, 0))
	var thumb: float = maxf(20.0, track * SKIN_COLS / float(count))
	var x: float = at.x + bar + (track - thumb) * clampf(float(_skin_first) / float(most), 0.0, 1.0)
	_hit("skin:pgl", Rect2(Vector2(at.x + bar, at.y) * _f, Vector2(x - at.x - bar, bar) * _f), false)
	_hit("skin:pgr", Rect2(Vector2(x + thumb, at.y) * _f, Vector2(at.x + bar + track - x - thumb, bar) * _f), false)
	_hslice("gar_hsb_thumb", Vector2(x, at.y), thumb, 4.0, _glow("slide:skin"))
	_hit("slide:skin", Rect2(Vector2(x, at.y) * _f, Vector2(thumb, bar) * _f), false)
	_skin_bar = [track, thumb, most]


func _skin_view() -> Rect2:
	return Rect2(_centre(float(GarSkin.SIZE[0]), float(GarSkin.SIZE[1])) * _f, Vector2(float(GarSkin.SIZE[0]), float(GarSkin.SIZE[1])) * _f)

func _skin_scroll(first: int) -> void :
	var rec: Dictionary = _rec()
	var count: int = 0 if rec.is_empty() else _skin_entries(rec, _skin_inst(rec)).size()
	_skin_first = clampi(first, 0, maxi(0, count - SKIN_COLS))



func _skin_inst(rec: Dictionary) -> Dictionary:
	var own: Dictionary = _own(rec)
	if not own.is_empty():
		return own
	for inst: Dictionary in client.tanks.values():
		if int(inst.get("m_tpltId", 0)) == int(rec.get("id", 0)):
			return inst
	return {"m_tankUuid": "", "m_tpltId": int(rec.get("id", 0)), "m_level": 1, "m_externalId": 0, "m_contType": -1}


func _skin_owned(inst: Dictionary) -> bool:
	return not str(inst.get("m_tankUuid", "")).is_empty() and int(inst.get("m_contType", -1)) == GarageModel.OWN


func _skin_held() -> Dictionary:
	var held: Dictionary = {}
	for inst: Variant in client.bags.get(6, []):
		if inst is Dictionary and int(inst.get("m_count", 0)) > 0 and not held.has(int(inst.get("m_templateId", 0))):
			held[int(inst.get("m_templateId", 0))] = inst
	return held


func _skin_entries(rec: Dictionary, inst: Dictionary) -> Array:
	var id: int = int(rec.id)
	var base: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), id, int(inst.get("m_level", 1)), {})
	return skin_list((GarSkin.SKINS.get(str(id), []) as Array) + (GarSkin.SKINS.get("0", []) as Array), GarSkin.EXTQ, _skin_held(), 
		int(inst.get("m_externalId", 0)), base, _skin_q)



func _use_skin(item: int) -> void :
	var rec: Dictionary = _rec()
	if rec.is_empty() or not _wait.is_empty():
		return
	var inst: Dictionary = _skin_inst(rec)
	if not _skin_owned(inst):
		_ask_tank(int(rec.id), SKIN_NO_TANK)
		return
	var entry: Dictionary = {}
	for one: Dictionary in _skin_entries(rec, inst):
		if int(one.item) == item:
			entry = one
	if entry.is_empty() or not bool(entry["has"]) or entry.equip:
		return
	if client.wear_skin(str(inst.get("m_tankUuid", "")), str(entry.uuid)):
		_wait = ["skin", _time + 4.0, "ngoại hình mặc định" if item == 0 else str(entry.row[3])]
	else:
		say("Chưa đổi được ngoại hình lúc này.")


func _buy_skin(item: int) -> void :
	var rec: Dictionary = _rec()
	if rec.is_empty():
		return
	if not _skin_owned(_skin_inst(rec)):
		_ask_tank(int(rec.id), SKIN_NO_TANK)
		return
	if GarSkin.SALE.has(str(item)):
		quick_buy_asked.emit(item, 1)


func _ask_tank(tid: int, after: String) -> void :
	if tank_buy_asked.get_connections().is_empty():
		say(after)
	else:
		tank_buy_asked.emit(tid, "", after)


static func _skin_tank_of(item: int) -> int:
	for key: String in GarSkin.SKINS:
		for row: Array in GarSkin.SKINS[key]:
			if int(row[0]) == item:
				return int(key)
	return 0



static func skin_filters(skins: Array) -> Array:
	var out: Array = [0]
	for row: Array in skins:
		if int(row[5]) != 1 and not out.has(int(row[2])):
			out.append(int(row[2]))
	return out




static func skin_list(skins: Array, extq: Dictionary, held: Dictionary, worn: int, base_ext: int, quality: int) -> Array:
	var all: Array = []
	for row: Array in skins:
		var item: int = int(row[0])
		var has: bool = held.has(item)
		if not has and int(row[5]) == 1:
			continue
		var bag: Dictionary = held.get(item, {})
		all.append({"item": item, "ext": int(row[1]), "has": has, "equip": worn == int(row[1]), "uuid": str(bag.get("m_itemUuid", "")), "bag": bag, "row": row})
	if base_ext > 0:
		all.append({"item": 0, "ext": base_ext, "has": true, "equip": worn == 0 or worn == base_ext, "uuid": "", "bag": {}, "row": []})
	var keyed: Array = []
	for entry: Dictionary in all:
		var q: int = int(extq.get(str(entry.ext), 0))
		if quality == 0 or q == quality:
			keyed.append([-1 if q == 5 else q, keyed.size(), entry])
	keyed.sort_custom( func(a: Array, b: Array) -> bool: return int(a[0]) < int(b[0]) or (int(a[0]) == int(b[0]) and int(a[1]) < int(b[1])))
	return keyed.map( func(k: Array) -> Dictionary: return k[2])



static func skin_state(row: Array, has: bool, level: int, sale: Dictionary, chip: Dictionary) -> String:
	if has:
		return "HAS"
	var item: String = str(int(row[0]))
	if int(row[2]) == 5 and chip.has(item):
		return "NEW_WAY_ACHIEVE"
	if int(row[4]) > 0 and level < int(row[4]):
		return "LEVEL"
	if sale.has(item):
		return "SELL_PRICE_2" if int(sale[item][2]) != 0 else "SELL"
	return "NORMAL" if str(row[6]) == "conv" else "NO_WAY"




static func skin_btn_tip(grade: int, rows: Array) -> String:
	return SKIN_BTN_TIP.replace("@text1@", GarageModel.grade(grade)).replace("@text2@", skin_type_desc(rows, grade - 1, GarSkin.BUFF))

static func skin_type_desc(rows: Array, kind: int, buffs: Dictionary) -> String:
	var order: Array = []
	var sums: Dictionary = {}
	var extra: PackedStringArray = []
	for row: Variant in rows:
		if int(row[0]) != kind:
			continue
		if skin_buff(row):
			var text: String = str(buffs.get(str(int(row[3])), ""))
			if not text.is_empty():
				extra.append(text)
		elif sums.has(int(row[2])):
			sums[int(row[2])] = float(sums[int(row[2])]) + float(row[3])
		else:
			order.append(int(row[2]))
			sums[int(row[2])] = float(row[3])
	var parts: PackedStringArray = []
	for attr: int in order:
		var value: float = float(sums[attr])
		var shown: String = (str(int(value * 100.0)) + "%") if value < 1.0 else (str(int(value)) if value == floorf(value) else str(value))
		parts.append((ATTR_NAMES[attr - 1] if attr >= 1 and attr <= ATTR_NAMES.size() else "") + "+" + shown)
	parts.append_array(extra)
	return " ".join(parts)



static func skin_left(inst: Dictionary, now: int) -> String:
	var life: int = int(inst.get("m_lifeTime", 0))
	var timed: bool = (int(inst.get("m_extFlag", 0)) & 4) != 0
	if timed and life <= now:
		return HALO_OVER
	var left: int = maxi(0, life - now) if timed else life * 86400
	return SKIN_LEFT + ("1 ngày" if left == 86400 else _span(left))


func _gui_input(event: InputEvent) -> void :
	if _sheet_id == "halo":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_halo_grab = [event.position.x, _halo_first] if event.pressed and _hit_at(event.position) == "slide:halo" and not _halo_bar.is_empty() else []
		elif event is InputEventMouseMotion and not _halo_grab.is_empty():
			if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
				_halo_grab = []
			else:
				var step: float = maxf(0.001, (float(_halo_bar[0]) - float(_halo_bar[1])) / float(_halo_bar[2]))
				_halo_scroll(roundi(float(_halo_grab[1]) + (event.position.x - float(_halo_grab[0])) / _f / step))
				accept_event()
				return
	if _sheet_id == "skin":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_skin_grab = [event.position.x, _skin_first] if event.pressed and _hit_at(event.position) == "slide:skin" and not _skin_bar.is_empty() else []
		elif event is InputEventMouseMotion and not _skin_grab.is_empty():
			if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
				_skin_grab = []
			else:
				var step: float = maxf(0.001, (float(_skin_bar[0]) - float(_skin_bar[1])) / float(_skin_bar[2]))
				_skin_scroll(roundi(float(_skin_grab[1]) + (event.position.x - float(_skin_grab[0])) / _f / step))
				accept_event()
				return
	super (event)

static func _pages(count: int) -> int:
	return maxi(1, ceili(count / float(PAGE)))



static func _first(leaf: int, pages: int, start: int) -> int:
	if leaf >= start + 4:
		start = leaf - 3
	elif leaf < start:
		start = leaf
	return clampi(start, 0, maxi(0, pages - 4))


static func _span(s: int) -> String:
	if s > 86400:
		var h: int = ceili(s / 3600.0)
		return "%d ngày" % (h / 24) if h % 24 == 0 else "%d ngày %d giờ" % [h / 24, h % 24]
	var m: int = ceili(s / 60.0)
	if m < 60:
		return "%d phút" % m
	return "%d giờ" % (m / 60) if m % 60 == 0 else "%d giờ %d phút" % [m / 60, m % 60]


static func _exist(rec: Dictionary, now: int) -> String:
	var use: Dictionary = rec.get("use", {})
	if rec.get("owned", false) or use.is_empty():
		return ""
	var left: int = int(use.get("m_existTime", 0)) - now
	if left < 60:
		return ""
	return ("Thời gian thuê còn: %s" if int(use.get("m_contType", -1)) == GarageModel.HIRE else "Dùng thử còn \n%s") % _span(left)


static func _frame_of(looks: Array, own: Dictionary) -> String:
	var count: int = 0
	var grades: Dictionary = {}
	for look: Array in looks:
		if int(look[1]) >= 2 and own.has(int(look[0])):
			count += 1
			grades[int(look[1])] = true
	if grades.size() >= 3 and grades.has(5):
		return "orange"
	return "purple" if count >= 2 else ""


static func _recommend(looks: Array, own: Dictionary) -> int:
	var best: int = 0
	var grade: int = -1
	for look: Array in looks:
		var q: int = int(look[1])
		if q >= 2 and own.has(int(look[0])) and (q > grade or (q == grade and int(look[0]) > best)):
			best = int(look[0])
			grade = q
	if best > 0 or looks.is_empty():
		return best
	return int(looks[0][0])
