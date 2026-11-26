extends "room.gd"
























const PvR = preload("pve_room_atlas.gd")
const PveMaps = preload("pve_hall_atlas.gd")
const SelectTank = preload("select_tank.gd")
const Corps = preload("select_corps_atlas.gd")
const ResetAsk = preload("pve_reset_ask.gd")
const PvR2 = preload("pve_room2_atlas.gd")
const LadderArt = preload("ladder_room_atlas.gd")

signal stamina_asked
signal cash_back_asked(tid: int, kind: int)

const SOON: String = "%s đang được chuyển sang HTML5."
const TIP_TURN: float = 10.0
const HERO_ROOM: int = 3
const PVE_ROOM: int = 4
const PVE_CARDS: int = 3
const DOUBLE_ROOM: int = 8
const DOUBLE_CARDS: int = 2
const TEAM_TIP: String = "Thiếu lượt có thể dùng Xu mua thêm"
const TEAM_COUNT: int = 0
const TEAM_RIM: Color = Color("005391")
const DOUBLE_RIM: Color = Color("086da5")
const PVE_MAP: int = 2
const HARD: int = 2
const COMMON: int = 16
const TEAM_CITY: int = 3
const PVH_CELLS: Array = ["pvh_opt_bk", "pvh_w_normal", "pvh_w_normal_sel", "pvh_w_hard", "pvh_w_hard_sel", "pvh_w_hard_dis", 
	"pvh_last", "pvh_last_dis", "pvh_next", "pvh_next_dis", "pvh_close_w", "pvh_eval3", "pvh_eval4", "pvh_eval5", "pvh_eval6", "pvh_eval7"]
const CASH_BACK: int = 2600008
const GBT_CASH_BACK: int = 11

const BRANCH_CITY: int = 1
const TRUNK_CITY: int = 2
const ENABLE: int = 1
const TEAM_OPEN_PVE: int = 1
const T_LOCKED: String = "Chưa đạt điều kiện mở"
const T_SOLO: String = "Phụ Bản đơn , không thể vào khi tổ đội"
const T_MAX: String = "Số người lớn nhất là @num1@, không thể chọn"
const T_TEAM_LV: String = "Lv Team không đủ, không thể mở PB này"

const CORPS_ORIGIN: Vector2 = Vector2(-1, -3)

const CORPS_GRIDS: Array = [[18, 36, 50], [82, 42, 35], [127, 42, 35], [172, 42, 35], [217, 42, 35]]
const CORPS_BACKS: Array = [[], [80, 40, 39], [125, 40, 39], [170, 40, 39], [215, 40, 39]]
const CORPS_ACTIVE: int = 4
const SKILL_COMMON: int = 2
const SKILL_PASSIVE: int = 3
const CORPS_BOX_DX: float = -260.0
const CORPS_BOX_Y: float = 105.0
const TIP_BUTTONS: Dictionary = {"btnBuyVip": "Mua VIP", "btnUpHelper": "Nâng cấp trợ thủ", "btnPay": "Nạp", "btnBuyCashBack": "Mua Hoàn Tiền"}

var _tip_from: float = 0.0
var _inst: int = -1
var corps_slot: int = 0
var corps_list: Array = []
var _corps_x: float = 0.0
var _corps_first: int = 0
var reset_map: int = 0
var reset_cost: int = 0

func chat_busy() -> bool:
	return _inst >= 0 or reset_map > 0 or super ()

func _pve() -> bool:
	return client != null and client.has_method("pve_room") and client.pve_room()

func _kind() -> int:
	return int(client.room_state.room.get("m_bType", 0))

func _shown() -> void :
	super ()
	_inst = -1
	corps_slot = 0
	reset_map = 0
	_bag_asked = false
	if is_visible_in_tree():
		_tip_from = _time


func _pve_cells() -> void :
	if _cells.has("pvr_thew"):
		return
	_use(PvR.FILE, PvR.R)
	_use(Corps.FILE, Corps.R)
	_use(ResetAsk.Ask.FILE, ResetAsk.Ask.R)
	_use(PvR2.FILE, PvR2.R)

	_use(LadderArt.FILE, {"pr2_start_bk": LadderArt.R["lrm_start_bk"]})
	var picked: Dictionary = {}
	for cell: String in PVH_CELLS:
		if PveMaps.R.has(cell):
			picked[cell] = PveMaps.R[cell]
	_use(PveMaps.FILE, picked)




static func map_row(id: int) -> Array:
	return PvR.MAPS.get(str(id), [])


static func pair_map(id: int, hard: bool) -> int:
	var row: Array = map_row(id)
	if row.is_empty():
		return 0
	if (int(row[4]) == HARD) == hard:
		return id
	return int(row[7]) if hard else int(row[6])


static func city_of(id: int) -> int:
	if id <= 0:
		return 0
	for key: String in PveMaps.CITIES:
		var row: Array = PveMaps.CITIES[key]
		if int(row[1]) == id or int(row[2]) == id:
			return int(key)
	return 0


static func hard_left(cities: Dictionary, city: int) -> int:
	var info: Array = cities.get(city, [])
	var used: int = int(info[3]) if info.size() > 3 else 0
	return maxi(0, int(PvR.BATCH.hard_max) - used)


func _hard_open() -> bool:
	var city: int = city_of(_map_id())
	var row: Array = PveMaps.CITIES.get(str(city), [])
	if row.is_empty():
		return false
	if int(row[0]) == TEAM_CITY or _kind() == HERO_ROOM:
		return true
	var info: Array = client.pve_cities.get(city, [])
	return not info.is_empty() and int(info[0]) & COMMON != 0

func _thew() -> int:
	return int(client.character.get("thew", 0))


func _thew_ok() -> bool:
	if _kind() != PVE_ROOM:
		return true
	var row: Array = map_row(_map_id())
	if row.is_empty() or int(row[5]) != PVE_MAP or int(row[0]) <= _thew():
		return true
	stamina_asked.emit()
	return false


func _sites() -> Array:
	var camps: Array = _camps()
	return camps[0] + camps[1]

func _map_name(id: int) -> String:
	if not _pve():
		return super (id)
	var row: Array = PveMaps.MAPS.get(str(id), [])
	return str(row[0]) if not row.is_empty() else super (id)



func _draw_free(frame: Vector2) -> void :
	if not _pve():
		super (frame)
		return
	_pve_cells()
	var state = client.room_state
	var cards: int = card_count(_kind())
	var seats: int = clampi(int(state.room.get("m_nMax", 3)), 0, cards)
	var sites: Array = _sites()

	for slot in range(cards - 1, -1, -1):
		var at: Vector2 = frame + Vector2(card_x(_kind(), slot), CLAN_Y)
		if slot >= seats:
			_draw_closed(at, slot)
		else:
			_draw_clan_card(at, slot, int(sites[slot]) if slot < sites.size() else 0)
	var spots: Dictionary = PvR.ROOM
	var texts: Dictionary = spots.texts
	var kind: int = _kind()

	if kind not in [HERO_ROOM, DOUBLE_ROOM]:
		_fblit("pvr_thew", frame + _pos(spots.thew))
		_label(str(_thew()), texts.lblThew, frame)
		_fbutton("buy_thew", "pvr_buy", frame + _pos(spots.buy_thew))

	var map: int = _map_id()
	var row: Array = map_row(map)
	if kind not in [HERO_ROOM, DOUBLE_ROOM] and not row.is_empty() and int(row[4]) == HARD:
		_fblit("pvr_enter", frame + _pos(spots.enter))
		var left: int = hard_left(client.pve_cities, city_of(map))
		_label(str(PvR.WORDS.pass).replace("@num1@", str(left)).replace("@num2@", str(int(PvR.BATCH.hard_max))), texts.lblEnterCount, frame)
		_fbutton("buy_enter", "pvr_buy", frame + _pos(spots.buy_enter))
	if kind == HERO_ROOM:
		_draw_team(frame)
	if kind == DOUBLE_ROOM:
		_draw_double(frame, map)
	else:
		_draw_diff(frame, row)
	if kind in [PVE_ROOM, DOUBLE_ROOM]:
		_draw_tips(frame)
		_draw_corps(frame)
	_draw_start()



func _draw_team(frame: Vector2) -> void :
	var spots: Dictionary = PvR2.TEAM
	_fblit("pr2_times", frame + _pos(spots.times))
	var rank: Array = spots.rank
	_fblit("pr2_rank_bk", frame + _pos(rank), float(rank[2]), float(rank[3]))
	_fwords(str(TEAM_COUNT), ARIAL_BOLD, 12.0, Color.WHITE, "c", frame + _pos(rank), float(rank[2]), 0.0, float(rank[3]))
	_fwords(TEAM_TIP, ARIAL_BOLD, 12.0, Color.WHITE, "l", frame + _pos(spots.tip), 0.0, 1.0, 0.0, false, TEAM_RIM)


func _draw_double(frame: Vector2, map: int) -> void :
	var spots: Dictionary = PvR2.DOUBLE
	_fblit("pr2_open", frame + _pos(spots.open))
	var need: Array = double_need(map)
	if need.is_empty():
		return
	if pack != null and pack.bag.is_empty() and not _bag_asked:
		_bag_asked = true
		pack.load_bag()
	var title: String = item_name(int(need[0]))
	if title.is_empty():
		return
	for pair: Array in [[str(need[1]), spots.count], [title, spots.item]]:
		var label: Array = pair[1]
		_fwords(str(pair[0]), ARIAL_BOLD, float(label[4]), Color(str(label[5])), "c" if str(label[7]) == "c" else "l", 
			frame + _pos(label), float(label[2]), 1.0, 0.0, true, DOUBLE_RIM)


static func double_need(map: int) -> Array:
	return PvR2.CONSUME.get(str(map), [])


func item_name(item: int) -> String:
	var info: Array = pack.bag.get("items", {}).get(str(item), []) if pack != null else []
	return BagModel.clean(str(info[0])) if not info.is_empty() else ""



static func card_count(kind: int) -> int:
	return PVE_CARDS if kind == PVE_ROOM else (DOUBLE_CARDS if kind == DOUBLE_ROOM else CLAN_MAX)


static func card_x(kind: int, slot: int) -> float:
	return float(PvR2.DOUBLE.cards[slot]) if kind == DOUBLE_ROOM else float(CLAN_X[slot])


func _draw_closed(at: Vector2, slot: int) -> void :
	var hit: String = "closed:%d" % slot
	_fblit("gameroom_avatar_card", at)
	var cell: Vector2 = _cell_size("gameroom_avatar_card_close_t")
	_fblit("gameroom_avatar_card_close_t", at + ((CLAN_CARD - cell) / 2.0).round(), 0.0, 0.0, _glow(hit))
	_fblit("pvr_unrecall", at + Vector2(56.5, 279))
	_hit(hit, Rect2(at * _f, CLAN_CARD * _f), false)


func _draw_diff(frame: Vector2, row: Array) -> void :
	var spots: Dictionary = PvR.ROOM
	_fblit("pvr_diff_word", frame + _pos(spots.diff_word))
	_fblit("pvr_diff", frame + _pos(spots.diff))
	var hard_now: bool = not row.is_empty() and int(row[4]) == HARD
	var hard_ok: bool = _hard_open()
	for diff: int in [1, 2]:
		var key: String = "normal" if diff == 1 else "hard"
		var at: Vector2 = frame + _pos(spots[key])
		var id: String = "diff:%d" % diff
		var chosen: bool = hard_now == (diff == 2)
		if chosen:
			_fblit("pvh_opt_bk", at)
		var word: String = "pvh_w_%s%s" % [key, "_sel" if chosen else ""]
		if diff == 2 and not hard_ok:
			word = "pvh_w_hard_dis"
		var cell: Vector2 = _cell_size(word)
		_fblit(word, at + ((Vector2(85, 26) - cell) / 2.0).round(), 0.0, 0.0, _glow(id) if diff == 1 or hard_ok else Color.WHITE)
		_hit(id, Rect2(at * _f, Vector2(85, 26) * _f), false)


func _draw_tips(frame: Vector2) -> void :
	var spots: Dictionary = PvR.ROOM
	_fblit("pvr_tip", frame + _pos(spots.tip))
	var page: Array = PvR.TIP_PAGES[tip_page(_time - _tip_from)]
	_fblit(str(page[0]), frame + Vector2(float(page[1]), float(page[2])))
	_fblit("pvr_tip_btnbg", frame + _pos(spots.tip_btnbg))
	_fbutton("tip:%s" % str(page[4]), str(page[3]), frame + _pos(spots.tip_btn))


static func tip_page(elapsed: float) -> int:
	return posmod(int(floorf(maxf(0.0, elapsed) / TIP_TURN)), PvR.TIP_PAGES.size())




func _draw_corps(frame: Vector2) -> void :
	var spots: Dictionary = PvR.ROOM
	var at: Vector2 = frame + _pos(spots.corps)
	_hit("corps", _fblit("pvr_corps", at), false)
	if client.guild.is_empty():
		_fblit("pvr_nocorps", frame + _pos(spots.nocorps))
		return
	var origin: Vector2 = at + CORPS_ORIGIN
	var guild: Dictionary = {}
	if pack != null:
		if pack.gda_loading.is_empty():
			pack.load_gda_loading()
		guild = pack.gda_loading.get("guild", {})
	for i in range(CORPS_GRIDS.size()):
		if int(client.guild_skill_flag) & (1 << i) == 0:
			continue
		var slot: int = CORPS_ACTIVE + i
		var id: String = "corps:%d" % slot
		var grid: Array = CORPS_GRIDS[i]
		var rect: Rect2 = Rect2((origin + Vector2(float(grid[0]), float(grid[1]))) * _f, Vector2(float(grid[2]), float(grid[2])) * _f)
		if not (CORPS_BACKS[i] as Array).is_empty():

			_fblit("pvr_corps_back", origin + Vector2(float(CORPS_BACKS[i][0]), float(CORPS_BACKS[i][1])))
		var index: int = corps_index(client.guild_skill_slots, slot)
		var level: int = SelectTank.corps_level(client.guild_skill_self, client.guild_skill_corps, index) if index > 0 else 0
		var skill: int = SelectTank.corps_skill(guild, index, level) if index > 0 else 0
		if skill <= 0 and index > 0:

			skill = SelectTank.corps_pvp(index, level)
		var row: Array = pack.skill_hud(skill) if pack != null and skill > 0 else []
		var icon: Texture2D = pack.icon("s", str(row[0])) if not row.is_empty() else null
		if icon != null:
			draw_texture_rect(icon, rect, false, Color(1.25, 1.25, 1.25) if _hover == id else Color.WHITE)
		var back: Array = CORPS_BACKS[i]
		_hit(id, Rect2((origin + Vector2(float(back[0]), float(back[1]))) * _f, Vector2(float(back[2]), float(back[2])) * _f) if not back.is_empty() else rect, false)


static func corps_index(slots: Dictionary, slot: int) -> int:
	if slot == CORPS_ACTIVE:
		return SelectTank.corps_index(slots)
	var row: Array = slots.get(slot, [])
	return int(row[0]) if not row.is_empty() else 0


static func corps_unused(slots: Dictionary, learned: Dictionary, kind: int) -> Array:
	var used: Dictionary = {}
	for key: Variant in slots:
		var row: Array = slots[key]
		if not row.is_empty() and int(row[0]) != 0:
			used[int(row[0])] = true
	var kinds: Array = [1, SKILL_COMMON] if kind == SKILL_COMMON else [kind]
	var list: Array = []
	for key: Variant in learned:
		var level: int = int(learned[key])
		if level >= 1 and not used.has(int(key)) and SelectTank.corps_kind(int(key), level) in kinds:
			list.append([int(key), level])
	return list


func _corps_frame() -> Vector2:
	return _at("hall") + _pos(PvR.ROOM.corps) + CORPS_ORIGIN


func _corps_cell(i: int) -> Vector2:
	var row: int = i / SelectTank.CORPS_COLS - _corps_first
	return _corps_frame() + Vector2(_corps_x + float(Corps.LIST[0] + (i % SelectTank.CORPS_COLS) * Corps.CELL), 
		CORPS_BOX_Y + float(Corps.LIST[1] + Corps.PAD_TOP + row * Corps.CELL))



func _draw_corps_box() -> void :
	var box: Vector2 = _corps_frame() + Vector2(_corps_x, CORPS_BOX_Y)
	_hit("cs_box", _fblit("cs_box", box + _pos(Corps.BOX_AT)), false)
	if corps_list.is_empty():
		var tip: Array = Corps.TEXT.lblNoSkillTip
		_fwords(str(Corps.NO_SKILL), ARIAL_BOLD, float(tip[4]), Color(str(tip[5])), str(tip[7]), box + Vector2(float(tip[0]), float(tip[1])), 
			float(tip[2]), 2.0, 0.0, true, SelectTank.CORPS_NO_SKILL_GLOW)
		return
	_corps_first = clampi(_corps_first, 0, _corps_most())
	for i in range(corps_list.size()):
		var row: int = i / SelectTank.CORPS_COLS - _corps_first
		if row < 0 or row >= SelectTank.CORPS_ROWS:
			continue
		var rect: Rect2 = Rect2(_corps_cell(i) * _f, Vector2(50, 50) * _f)
		var hud: Array = pack.skill_hud(SelectTank.corps_pvp(int(corps_list[i][0]), int(corps_list[i][1]))) if pack != null else []
		var icon: Texture2D = pack.icon("s", str(hud[0])) if not hud.is_empty() else null
		var id: String = "cs_pick:%d" % i
		if icon != null:
			draw_texture_rect(icon, rect, false, Color(1.25, 1.25, 1.25) if _hover == id else Color.WHITE)
		_hit(id, rect, false)

func _corps_most() -> int:
	return maxi(0, ceili(float(corps_list.size()) / float(SelectTank.CORPS_COLS)) - SelectTank.CORPS_ROWS)


func _corps_open(slot: int) -> void :
	var i: int = slot - CORPS_ACTIVE
	if i < 0 or i >= CORPS_GRIDS.size() or int(client.guild_skill_flag) & (1 << i) == 0:
		return

	_corps_x = _held_at.x / _f - _corps_frame().x + CORPS_BOX_DX
	corps_list = corps_unused(client.guild_skill_slots, client.guild_skill_self, SKILL_COMMON if slot == CORPS_ACTIVE else SKILL_PASSIVE)
	_corps_first = 0
	corps_slot = slot


func _corps_choose(i: int) -> void :
	var slot: int = corps_slot
	corps_slot = 0
	if i < 0 or i >= corps_list.size():
		return
	var id: int = int(corps_list[i][0])
	var level: int = int(corps_list[i][1])
	client.guild_skill_set(id, level, SelectTank.corps_slot(slot, SelectTank.corps_kind(id, level)))

func _wheel(step: int, at: Vector2) -> void :
	if corps_slot > 0 and (_hit_at(at) == "cs_box" or _hit_at(at).begins_with("cs_pick:")):
		_corps_first = clampi(_corps_first + step, 0, _corps_most())
		return
	super (step, at)


func _draw_start() -> void :
	if not _pve():
		super ()
		return
	_pve_cells()
	var state = client.room_state
	var frame: Vector2 = _at("hall")
	var at: Vector2 = _at("start")
	var map: int = _map_id()
	var shown: Array = PveMaps.MAPS.get(str(map), [])
	var gui: Vector2 = frame + _pos(PvR.ROOM.gui)
	var texture: Texture2D = pack.picture(str(shown[10])) if not shown.is_empty() else null
	if texture != null:
		draw_texture_rect(texture, Rect2(gui * _f, Vector2(168, 100) * _f), false)
	else:
		_map_art("s", map, gui, 168.0, 100.0)
	_hit("map", Rect2(gui * _f, Vector2(168, 107) * _f), false)
	var two: bool = _kind() == DOUBLE_ROOM

	_fblit("pr2_start_bk" if two else "gameroom_startgame_background_t", at)
	var row: Array = map_row(map)
	if not two:
		_fblit("pvr_lbl_hard" if not row.is_empty() and int(row[4]) == HARD else "pvr_lbl_normal", frame + _pos(PvR.ROOM.label))
	_fblit("gameroom_cancelready_disable_button_t", at + Vector2(190, 16))
	if state.is_host():
		_fbutton("start", "gameroom_startgame_button_t", at + Vector2(190, 16))
	else:
		_fbutton("ready", "gameroom_cancelready_button_t" if state.is_ready() else "gameroom_ready_button_t", at + Vector2(190, 16))





func _draw_note() -> void :
	if _inst >= 0 and _pve():
		_draw_inst()
	elif corps_slot > 0 and _pve() and _kind() in [PVE_ROOM, DOUBLE_ROOM] and not client.guild.is_empty():
		_draw_corps_box()
	if reset_map > 0 and _pve():
		_pve_cells()
		ResetAsk.paint(self, reset_cost)
	super ()

func _draw_inst() -> void :
	_pve_cells()
	var stage: Vector2 = _stage()
	_hit("inst:bg", Rect2(stage * _f, Vector2(1000, 600) * _f), false)
	var chapter: Array = PveMaps.CHAPTERS[_inst]
	draw_rect(Rect2(stage * _f, Vector2(1000, 600) * _f), Color(0, 0, 0, 1))
	_inst_picture(str(chapter[1]), stage, Vector2(1000, 600), false)
	var bar: Array = PveMaps.WORLD.bar
	draw_rect(Rect2((stage + Vector2(float(bar[0]), float(bar[1]))) * _f, Vector2(float(bar[2]), float(bar[3])) * _f), Color(0, 0, 0, 0.4))
	var title: Array = PveMaps.WTEXT.label1
	_fwords(str(chapter[0]), ARIAL_BOLD, float(title[4]), Color(str(title[5])), "c", stage + Vector2(float(title[0]) - 300.0, float(title[1]) - 12.0), 
		600.0, 1.0, 24.0, false)
	for spot: Array in chapter[2]:
		_draw_inst_city(int(spot[0]), stage + Vector2(float(spot[1]), float(spot[2])))
	var team: Variant = chapter[3]
	if team is Array:
		_draw_inst_team(int(team[0]), stage + Vector2(float(team[1]), float(team[2])))
	var last: Array = PveMaps.WORLD.last
	var next: Array = PveMaps.WORLD.next
	if _inst > 0:
		_fbutton("inst:last", "pvh_last", stage + Vector2(float(last[0]), float(last[1])))
	else:
		_fblit("pvh_last_dis", stage + Vector2(float(last[0]), float(last[1])))
	if _inst < PveMaps.CHAPTERS.size() - 1:
		_fbutton("inst:next", "pvh_next", stage + Vector2(float(next[0]), float(next[1])))
	else:
		_fblit("pvh_next_dis", stage + Vector2(float(next[0]), float(next[1])))
	var close: Array = PveMaps.WORLD.close
	_fbutton("inst:close", "pvh_close_w", stage + Vector2(float(close[0]), float(close[1])))


func _inst_picture(path: String, at: Vector2, wide: Vector2, grey: bool, lit: float = 1.0) -> void :
	var texture: Texture2D = pack.picture(path.replace(".webp", "_g.webp") if grey else path) if pack != null and not path.is_empty() else null
	if texture != null:
		draw_texture_rect(texture, Rect2(at * _f, wide * _f), false, Color(lit, lit, lit, 1.0))



func inst_city_state(id: int) -> String:
	var city: Array = PveMaps.CITIES.get(str(id), [])
	if city.is_empty() or int(city[0]) == BRANCH_CITY:
		return "grey"
	if _kind() == HERO_ROOM:
		return "grey"
	var info: Array = client.pve_cities.get(id, [])
	if info.is_empty():
		return "open"
	var map: Array = PveMaps.MAPS.get(str(int(city[1])), [])
	if int(info[0]) & ENABLE == 0 or map.is_empty() or int(map[2]) == 1:
		return "grey_click"
	return "open"

func _draw_inst_city(id: int, at: Vector2) -> void :
	var city: Array = PveMaps.CITIES.get(str(id), [])
	if city.is_empty():
		return
	var state: String = inst_city_state(id)
	var wide: Vector2 = Vector2(float(city[8][0]), float(city[8][1]))
	var key: String = "inst:city:%d" % id
	var click: bool = state != "grey" and int(city[0]) == TRUNK_CITY
	_inst_picture(str(city[7]), at, wide, state != "open", _shine(key) if click else 1.0)
	if click:
		_hit(key, Rect2(at * _f, wide * _f), false)
	var info: Array = client.pve_cities.get(id, [])
	if int(city[0]) != TRUNK_CITY or info.is_empty():
		return
	var rank: int = maxi(_eval_rank(int(info[1])), _eval_rank(int(info[2])))
	if rank > 0:
		var cell: Vector2 = _cell_size("pvh_eval%d" % rank)
		_fblit("pvh_eval%d" % rank, at + Vector2(0, wide.y - 80.0 - cell.y))


func _draw_inst_team(id: int, at: Vector2) -> void :
	var city: Array = PveMaps.CITIES.get(str(id), [])
	if city.is_empty():
		return
	var wide: Vector2 = Vector2(float(city[8][0]), float(city[8][1]))
	var grey: bool = _kind() != HERO_ROOM or not _team_pve_open(_self_team())
	_inst_picture(str(city[7]), at, wide, grey, _shine("inst:team"))
	_hit("inst:team", Rect2(at * _f, wide * _f), false)

static func _eval_rank(value: int) -> int:
	if value == 0:
		return 0
	return value if value >= 3 and value <= 7 else 3

static func _team_pve_open(team: Dictionary) -> bool:
	return not team.is_empty() and int(team.get("nExtFlag", 0)) & TEAM_OPEN_PVE != 0


func _self_team() -> Dictionary:
	var uuid: String = client.guild_self_uuid()
	var team_id: int = int(client.guild_members[uuid].get("nTeamId", 0)) if not uuid.is_empty() and client.guild_members.has(uuid) else int(client.guild_self_team)
	if team_id == 0:
		return {}
	for team: Dictionary in client.guild_teams:
		if int(team.get("nTeamId", 0)) == team_id:
			return team
	return {}



func _open_inst() -> void :
	if not client.room_state.is_host() or _kind() == DOUBLE_ROOM:
		return
	var city: Array = PveMaps.CITIES.get(str(city_of(_map_id())), [])
	_inst = clampi(int(city[6]) - 1, 0, PveMaps.CHAPTERS.size() - 1) if not city.is_empty() else 0
	if _kind() == PVE_ROOM and client.pve_chapter >= 0:
		_inst = mini(client.pve_chapter, PveMaps.CHAPTERS.size() - 1)
	_viewing = {}



func _inst_click(id: String) -> void :
	if id == "inst:team":
		var spot: Variant = PveMaps.CHAPTERS[_inst][3]
		if not spot is Array:
			return
		var hero: Array = PveMaps.CITIES.get(str(int(spot[0])), [])
		var team: Dictionary = _self_team()
		if hero.is_empty():
			return
		if team.is_empty() or int(team.get("nLevel", 0)) < int(hero[5]):
			say(T_TEAM_LV)
			return
		_inst_confirm(int(spot[0]))
	elif id.begins_with("inst:city:"):
		_inst_confirm(int(id.substr(10)))



func _inst_confirm(id: int) -> void :
	var city: Array = PveMaps.CITIES.get(str(id), [])
	var info: Array = client.pve_cities.get(id, [])
	if city.is_empty() or info.is_empty() or int(city[0]) == BRANCH_CITY:
		return
	if int(info[0]) & ENABLE == 0:
		say(T_LOCKED)
		return
	var map: Array = PveMaps.MAPS.get(str(int(city[1])), [])
	if map.is_empty():
		return
	if int(map[2]) == 1:
		say(T_SOLO)
		return
	if client.room_state.members.size() > int(map[2]):
		say(T_MAX.replace("@num1@", str(int(map[2]))))
		return
	client.pve_chapter = _inst
	_inst = -1
	client.set_map(int(city[1]))

func _escape() -> bool:
	if reset_map > 0:
		reset_map = 0
		return true
	if _inst >= 0:
		_inst = -1
		return true
	if corps_slot > 0:
		corps_slot = 0
		return true
	return super ()

static func _pos(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))


func _label(text: String, label: Array, base: Vector2) -> void :
	var wide: float = float(label[2]) if float(label[2]) > 0.0 else 80.0
	var align: String = str(label[7])

	var left: float = float(label[0]) if float(label[2]) > 0.0 else float(label[0]) - (wide / 2.0 if align == "c" else (wide if align == "r" else 0.0))
	_fwords(text, ARIAL_BOLD if int(label[6]) == 1 else ARIAL, float(label[4]), Color(str(label[5])), align, base + Vector2(left, float(label[1])), wide, 1.0)





func _start() -> void :
	if not _pve():
		super ()
		return
	if not _thew_ok():
		return
	var state = client.room_state
	var host: int = int(state.room.get("m_nCreateId", 0))
	for id: int in state.members:
		if id != host and not bool(state.members[id].get("ready", false)):
			client.chat_note(TIP_12)
			return
	var least: int = int(state.room.get("m_nMin", 0))
	if state.members.size() < least:
		say(TIP_97.replace("@num1@", str(least)))
		return
	client.pve_room_op(24)


func _ready_click() -> void :
	if client.room_state.is_ready():
		client.pve_room_op(3)
	elif _thew_ok():
		client.pve_room_op(2)


func _diff_click(hard: bool) -> void :
	if hard and not _hard_open():
		return
	if not client.room_state.is_host():
		return
	var target: int = pair_map(_map_id(), hard)
	if target == 0 or target == _map_id():
		return
	client.set_map(target)


func _buy_enter() -> void :
	var city: int = city_of(_map_id())
	var info: Array = client.pve_cities.get(city, [])
	if info.is_empty():
		return
	if hard_left(client.pve_cities, city) > 0:
		say(str(PvR.WORDS.tip401))
	else:
		ask_reset(_map_id())


func ask_reset(map: int) -> void :
	var info: Array = client.pve_cities.get(city_of(map), [])
	if info.is_empty():
		return
	var row: Array = map_row(map)
	reset_cost = ResetAsk.price(info, int(row[5]) if row.size() > 5 else 0)
	reset_map = map
	corps_slot = 0


func _reset_click(id: String) -> void :
	match id:
		"rs:ok":
			var map: int = reset_map
			reset_map = 0
			ResetAsk.confirm(self, client, map, reset_cost)
		"rs:no":
			reset_map = 0

func _activate(id: String) -> void :
	if not _pve() or not _clan_sheet.is_empty() or _pwd_open:
		super (id)
		return
	if reset_map > 0:
		_reset_click(id)
		return
	if corps_slot > 0:
		if id.begins_with("cs_pick:"):
			_corps_choose(int(id.substr(8)))
			return
		if id == "cs_box":
			return
		corps_slot = 0
	if _inst >= 0:
		match id:
			"inst:close":
				_inst = -1
			"inst:last":
				_inst = maxi(0, _inst - 1)
			"inst:next":
				_inst = mini(PveMaps.CHAPTERS.size() - 1, _inst + 1)
			_:
				_inst_click(id)
		return
	if id.begins_with("tip:"):
		match id.substr(4):
			"btnBuyVip":
				page_asked.emit("events:vip")
			"btnUpHelper":
				page_asked.emit("helper")
			"btnBuyCashBack":
				cash_back_asked.emit(CASH_BACK, GBT_CASH_BACK)
			_:
				say(SOON % str(TIP_BUTTONS.get(id.substr(4), "Chức năng này")))
		return
	if id.begins_with("host:"):
		return
	if id.begins_with("corps:"):
		_corps_open(int(id.substr(6)))
		return
	match id:
		"start":
			_start()
		"ready":
			_ready_click()
		"leave", "back":
			client.pve_room_op(1)
		"diff:1":
			_diff_click(false)
		"diff:2":
			_diff_click(true)
		"buy_thew":
			stamina_asked.emit()
		"buy_enter":
			_buy_enter()
		"corps":
			pass
		"map":
			_open_inst()
		_:
			super (id)
