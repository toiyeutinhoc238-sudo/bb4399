extends "hall_screen.gd"



























const Pve = preload("pve_hall_atlas.gd")
const PvR = preload("pve_room_atlas.gd")
const BagModel = preload("bag_model.gd")
const HelperModel = preload("helper_model.gd")

signal closed
signal stamina_asked

const SOON: String = "%s đang được chuyển sang HTML5."

const Ask = preload("exitask_atlas.gd")
const ASK_DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const ASK_LINE: float = 18.0
const ASK_GUTTER: float = 2.0
const ResetAsk = preload("pve_reset_ask.gd")
const WATCH_ASK: String = "Có vào @name@ xem không?"
const ROPT_LOOK_SCENE: int = 6
const T_ROOM_ID: String = "Nhập số room"
const T_PASSWORD: String = "Nhập mật mã của room muốn vào"
const GuildTeam = preload("guild_team_atlas.gd")
const T_TEAM_ASK: String = "Mở PB Team này? Sau khi mở, phí bảo trì mỗi lần sẽ tăng @num1@"
const T_TEAM_COIN: String = "Không đủ quỹ Team, không thể mở PB Team"

const ENABLE: int = 1
const LEVEL: int = 2
const QUEST: int = 4
const PRE_CITY: int = 8
const COMMON: int = 16
const HERO: int = 32
const COMMON_TODAY: int = 64
const HERO_TODAY: int = 128

const BRANCH: int = 1
const TRUNK: int = 2
const TEAM: int = 3
const ROOM_TYPE: int = 4
const HERO_ROOM: int = 3
const TEAM_OPEN_PVE: int = 1
const PAGE: int = 8
const FADE: float = 0.5
const TIP_TIME: float = 0.4
const TIP_W: float = 440.0
const TIP_EDGE: Color = Color("f66828")
const POLL_EMPTY: float = 5.0
const POLL_FEW: float = 10.0
const WANT_WAIT: float = 3.0
const PASS_COLOR: Color = Color("73bc50")
const FAIL_COLOR: Color = Color("f4280d")
const HINT_FILL: Color = Color("ffffcc")
const HINT_TEXT: Color = Color("0b333c")

const T_LOCKED: String = "Chưa đạt điều kiện mở"
const T_NO_HARD: String = "Phụ bản không có hình thức khó"
const T_LEVEL: String = "Lên lv @num1@ mới mở được map này"
const T_PAIRING: String = "Room đã bắt đầu sắp xếp, không thể vào"
const T_FULL: String = "Số người trong room đã đầy, không thể vào"
const T_GUILD: String = "Mời vào Guild"
const T_THEW: String = "Cần @num1@ Thể Lực"
const T_THEW_NEED: String = "Phụ bản này cần @num1@ Điểm Thể Lực"
const T_REC: String = "Chiến lực @num1@ người trở lên: @num2@"
const T_MIN: String = "Chiến lực tối thiểu: @num1@"
const T_SOLO: String = "(Đơn)"
const T_NORMAL: String = "Chế độ thường"
const T_HARD: String = "Chế độ khó"
const T_HARD_LOCK: String = "Điều kiện mở: vượt ải độ khó thường"
const T_REC_NORMAL: String = "Thường:"
const T_REC_HARD: String = "Khó:"
const T_NO_RECORD: String = "Chưa có lịch sử"
const T_CHAR_LEVEL: String = "Lv nhân vật yêu cầu: @num1@"
const T_PRE: String = "Qua ải PB: @name@"
const T_TEAM_LEVEL: String = "Lv Team: @num1@"
const T_TEAM_LOW: String = "Lv Team không đủ, không thể mở PB này"
const T_TEAM_SHUT: String = "PB Team chưa mở, cần trưởng Team mở "
const T_HELP_N: String = "Thường: Đề cử @num1@ người trở lên chiến lực @num2@ (Tối thiểu @num3@)"
const T_HELP_H: String = "Khó: Đề cử @num1@ người trở lên chiến lực @num2@ (Tối thiểu @num3@)"
const T_PET: String = "Pet :"
const T_MIN_HELPER: String = "Min C.Lực trợ thủ:"
const T_MY_HELPER: String = "C.Lực trợ thủ:"
const HELPER_LINE: float = 20.0
const T_REWARD: String = "Qua ải nhận thưởng:"
const T_EVAL: String = "Đánh giá:"
const T_REQUIRE: String = "Điều kiện mở:"
const T_RECORD: String = "Ghi chép vượt ải: "
const T_CAPTAIN: String = "Đội trưởng team mở"



const GuideAtlas = preload("guide_atlas.gd")
const GuideView = preload("guide_view.gd")
const T_QUEST_MAP: String = "Map Nhiệm Vụ"
const HELP_BOX: float = 300.0
const HELP_SHIFT: float = 80.0
const HELP_LINE: float = 40.0

const SWEEP_AT: Vector2 = Vector2(288, 134)
const SWEEP_SIZE: Vector2 = Vector2(441, 350)
const AWARD_AT: Vector2 = Vector2(175, 40)
const AWARD_SIZE: Vector2 = Vector2(650, 520)
const SHOW_TIME: float = 0.5
const ITEM_GAP: float = 0.05
const LINE_STEP: float = 15.0
const NAME_LINE: float = 14.0
const HARD_DIFF: int = 2
const PVE_MAP_TYPE: int = 2
const CASH_COST: int = 1

var _mode: String = "world"
var _chapter: int = -1
var _bg_chapter: int = -1
var _bg_from: int = -1
var _fade_at: float = -10.0
var _city: int = 0
var _kind: int = ROOM_TYPE
var _diff: int = 1
var _site: int = 0
var _list_sig: int = 0
var _list_at: float = 0.0
var _sweep_hidden: bool = false
var _tip_city: int = 0
var _tip_at: float = 0.0
var _tip_box: Rect2 = Rect2()
var _want_map: int = 0
var _want_at: float = 0.0
var _seen_rev: int = -1
var _sweep_map: int = 0
var _sweep_once_at: float = -10.0
var _sweep_more_at: float = -10.0
var _award_open: bool = false
var _award_runs: Array = []
var _award_cells: Array = []
var _award_at: float = 0.0
var _award_scroll: float = 0.0
var _award_shown: int = 0
var _award_seen: int = 0
var _award_vip: int = 0
var _award_box: Control
var _back_chapter: int = -1
var _help_map: int = 0
var _help_at: float = 0.0
var _sheet_id: String = ""
var reset_map: int = 0
var reset_cost: int = 0
var _target: int = 0
var _watch: Dictionary = {}
var _id: LineEdit
var _key: LineEdit
var _pass: LineEdit
var _focus: LineEdit

func _setup() -> void :
	super ()
	_add_parts(Pve.PLACE)
	_award_box = Control.new()
	_award_box.clip_contents = true
	_award_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_award_box.visible = false
	_award_box.draw.connect( func() -> void : _draw_awards(_award_box))
	add_child(_award_box)
	_id = _fedit(9, true)
	_key = _fedit(6, true)
	_pass = _fedit(6, true)
	for edit: LineEdit in [_id, _key, _pass]:
		edit.text_submitted.connect( func(_text: String) -> void : _submit())
	client.room_password_asked.connect( func(room_id: int, kind: int) -> void :
		if is_visible_in_tree() and kind in [3, 4] and room_id > 0:
			_open_sheet("pass", room_id))

func _frames() -> Dictionary:
	return Pve.WFRAME if _mode == "world" else Pve.FRAME

func _shown() -> void :
	_reset_list()
	_close_sheet()
	if client == null:
		return
	_sweep_map = 0
	_close_awards()
	_award_seen = int(client.pve_sweep_rev)
	if is_visible_in_tree():
		_mode = "world"
		if _want_map == 0:
			_chapter = _back_chapter
		_back_chapter = -1
		_tip_city = 0
		_seen_rev = -1
		client.pve_info()
	else:
		_want_map = 0
		_help_map = 0
		if _mode == "station":
			_leave_station()



func come_back(map_id: int) -> void :
	var city: Array = Pve.CITIES.get(str(city_of_map(map_id)), [])
	_back_chapter = clampi(int(city[6]) - 1, 0, Pve.CHAPTERS.size() - 1) if not city.is_empty() else -1


func _tick_list() -> void :
	if _mode == "station":
		super ()
	else:
		_scroll(0)

func _tick(_delta: float) -> void :
	if client == null:
		return
	_tick_list()
	_tick_awards()
	if client.pve_rev != _seen_rev:
		_seen_rev = client.pve_rev
		if _want_map != 0:
			_try_want()
	if _want_map != 0 and _time - _want_at > WANT_WAIT:
		_want_map = 0
	if _mode == "station":
		var shown: Array = rooms()
		var sig: int = client.room_state.rooms.hash()
		if sig != _list_sig:
			_list_sig = sig
			_list_at = _time
		var wait: float = POLL_EMPTY if shown.is_empty() else (POLL_FEW if shown.size() < PAGE else -1.0)
		if wait > 0.0 and _time - _list_at >= wait:
			_list_at = _time
			_in_hall(-1)
	else:
		var over: int = int(_hover.substr(5)) if _hover.begins_with("city:") else 0
		if over != _tip_city:
			_tip_city = over
			_tip_at = _time
			if over != 0:
				ask_records(over)





static func now_chapter(cities: Dictionary) -> int:
	var seen: bool = false
	for index in range(Pve.CHAPTERS.size()):
		for spot: Array in Pve.CHAPTERS[index][2]:
			var city: Array = Pve.CITIES.get(str(spot[0]), [])
			var info: Array = cities.get(int(spot[0]), [])
			if city.is_empty() or info.is_empty() or int(city[0]) != TRUNK:
				continue
			seen = true
			if int(info[0]) & COMMON == 0:
				return index
	return Pve.CHAPTERS.size() - 1 if seen else -1


func chapter() -> int:
	if _chapter >= 0:
		return clampi(_chapter, 0, Pve.CHAPTERS.size() - 1)
	return clampi(now_chapter(client.pve_cities), 0, Pve.CHAPTERS.size() - 1)


static func city_of_map(map_id: int) -> int:
	if map_id <= 0:
		return 0
	for key: String in Pve.CITIES:
		var row: Array = Pve.CITIES[key]
		if int(row[1]) == map_id or int(row[2]) == map_id:
			return int(key)
	return 0


static func eval_rank(value: int) -> int:
	if value == 0:
		return 0
	return value if value >= 3 and value <= 7 else 3


static func helper_need(map: Array) -> int:
	return int(map[4]) if int(map[4]) != 0 else Pve.DEFAULT_BOOSTER



static func helper_spans(city: Array, mine: int) -> Array:
	var maps: Array = []
	for id: int in [int(city[1]), int(city[2])]:
		if id != 0 and Pve.MAPS.has(str(id)):
			maps.append(Pve.MAPS[str(id)])
	if maps.is_empty():
		return []
	var big: Callable = func(value: int) -> Array: return [str(value), "ff6600", 16.0]
	var lines: Array = []
	if maps.size() == 1:
		lines.append([[T_PET, "ff6600", 12.0], big.call(helper_need(maps[0]))])
		lines.append([[T_MIN_HELPER, "ff6600", 12.0], big.call(int(maps[0][5]))])
	else:
		for i in range(2):
			var line: Array = []
			var rest: String = T_HELP_N if i == 0 else T_HELP_H
			var nums: Dictionary = {"@num1@": int(maps[i][6]), "@num2@": helper_need(maps[i]), "@num3@": int(maps[i][5])}
			for key: String in ["@num1@", "@num2@", "@num3@"]:
				var cut: int = rest.find(key)
				if cut < 0:
					continue
				if cut > 0:
					line.append([rest.left(cut), "ff6600", 12.0])
				line.append(big.call(int(nums[key])))
				rest = rest.substr(cut + key.length())
			if not rest.is_empty():
				line.append([rest, "ff6600", 12.0])
			lines.append(line)
	lines.append([[T_MY_HELPER, "15e337", 12.0], [str(mine), "15e337", 16.0]])
	return lines


static func helper_text(city: Array, mine: int = 0) -> String:
	var out: Array = []
	for line: Array in helper_spans(city, mine):
		out.append("".join(line.map( func(part: Array) -> String: return str(part[0]))))
	return "\n".join(out)



func _my_helper() -> int:
	if client.battle_helper.is_empty():
		return 0
	if pack.helper.is_empty():
		pack.load_helper()
		return 0
	for inst: Variant in client.bags.get(5, []):
		if inst is Dictionary and str((inst as Dictionary).get("m_itemUuid", "")) == client.battle_helper:
			return int(HelperModel.record(inst, pack.helper, pack.bag, client.battle_helper).get("score", 0))
	return 0



func ask_records(id: int) -> void :
	var city: Array = Pve.CITIES.get(str(id), [])
	if city.is_empty() or not client.pve_cities.has(id):
		return
	client.pve_record(int(city[1]))
	client.pve_record(int(city[2]))


static func record_text(label: String, record: Dictionary) -> String:
	if record.is_empty() or int(record.get("pass", 0)) == 0:
		return label + T_NO_RECORD
	var used: int = int(record.get("use", 0))
	return label + "%02d'%02ds" % [used / 60, used % 60] + " " + ", ".join(PackedStringArray(record.get("names", [])))


func rooms() -> Array:
	var ids: Array = client.room_state.rooms.keys()
	ids.sort()
	var out: Array = []
	for id: Variant in ids:
		var room: Dictionary = client.room_state.rooms[id]
		if int(room.get("m_type", 0)) == _kind:
			out.append(room)
	return out


func _in_hall(site: int) -> bool:
	if _kind == ROOM_TYPE:
		return client.pve_hall(site)
	return client.pve_hall_kind(_kind, site)


func _self_team() -> Dictionary:
	var uuid: String = client.guild_self_uuid()
	var team_id: int = int(client.guild_members[uuid].get("nTeamId", 0)) if not uuid.is_empty() else int(client.guild_self_team)
	if team_id == 0:
		return {}
	for team: Dictionary in client.guild_teams:
		if int(team.get("nTeamId", 0)) == team_id:
			return team
	return {}


func _self_leader() -> bool:
	var uuid: String = client.guild_self_uuid()
	if uuid.is_empty():
		return false
	for team: Dictionary in client.guild_teams:
		if str(team.get("leaderUuid", "")) == uuid:
			return true
	return false


static func team_open(team: Dictionary) -> bool:
	return not team.is_empty() and int(team.get("nExtFlag", 0)) & TEAM_OPEN_PVE != 0



static func hero_gate(in_guild: bool, team: Dictionary, need: int, leader: bool) -> String:
	if not in_guild:
		return T_GUILD
	if team.is_empty() or int(team.get("nLevel", 0)) < need:
		return T_TEAM_LOW
	if not team_open(team):
		return "open" if leader else T_TEAM_SHUT
	return ""

func _level() -> int:
	return int(client.character.get("level", 0))

func _city_row() -> Array:
	return Pve.CITIES.get(str(_city), [])


func _map_id() -> int:
	var city: Array = _city_row()
	if city.is_empty():
		return 0
	return int(city[2]) if _diff == 2 and int(city[2]) != 0 else int(city[1])


func _hard_open() -> bool:
	var city: Array = _city_row()
	var info: Array = client.pve_cities.get(_city, [])
	if city.is_empty():
		return false
	return int(city[0]) == TEAM or ( not info.is_empty() and int(info[0]) & COMMON != 0)




func _open_city(id: int) -> void :
	var city: Array = Pve.CITIES.get(str(id), [])
	var info: Array = client.pve_cities.get(id, [])
	if city.is_empty():
		return
	var kind: int = ROOM_TYPE
	if int(city[0]) == TEAM:

		var gate: String = hero_gate( not client.guild.is_empty(), _self_team(), int(city[5]), _self_leader())
		if gate == "open":
			_ask_team()
			return
		if gate != "":
			say(gate)
			return
		kind = HERO_ROOM
	if info.is_empty():
		return
	if int(info[0]) & ENABLE == 0:
		say(T_LOCKED)
		return
	var map: Array = Pve.MAPS.get(str(city[1]), [])
	if kind == ROOM_TYPE and not map.is_empty() and int(map[2]) == 1:


		var row: Array = PvR.MAPS.get(str(city[1]), [])
		if not row.is_empty() and int(row[5]) == PVE_MAP_TYPE and int(row[0]) > int(client.character.get("thew", 0)):
			stamina_asked.emit()
			return
		if not client.select_tutor_map(int(city[1])):
			say("Chưa vào được lúc này.")
		return
	_kind = kind
	if not _in_hall(-1):
		_kind = ROOM_TYPE
		say("Chưa vào được lúc này.")
		return
	_mode = "station"
	_city = id
	if _chapter >= 0:
		client.pve_chapter = _chapter
	_diff = 1
	_site = 0
	_tip_city = 0
	_list_sig = client.room_state.rooms.hash()
	_list_at = _time
	_reset_list()
	_sweep_hidden = false
	_refresh_sweep()


func _refresh_sweep() -> void :
	var map: Array = Pve.MAPS.get(str(_map_id()), [])
	if not map.is_empty() and int(map[2]) >= 5:
		_sweep_hidden = true


func _leave_station() -> void :
	_mode = "world"
	_city = 0
	_kind = ROOM_TYPE
	_sweep_map = 0
	_close_sheet()
	_reset_list()
	client.pve_out_hall()




func open_map(map_id: int) -> bool:
	if map_id < 0:
		return point_map( - map_id)
	if city_of_map(map_id) == 0:
		return false
	_want_map = map_id
	_want_at = _time
	if is_visible_in_tree():
		_try_want()
	return true




func point_map(map_id: int) -> bool:
	var city: Array = Pve.CITIES.get(str(city_of_map(map_id)), [])
	if city.is_empty():
		return false
	var index: int = clampi(int(city[6]) - 1, 0, Pve.CHAPTERS.size() - 1)
	_want_map = 0
	_help_map = map_id
	_help_at = _time
	if is_visible_in_tree():
		_chapter = index
	else:
		_back_chapter = index
	return true



static func help_spot(index: int, map_id: int) -> Array:
	if map_id <= 0 or index < 0 or index >= Pve.CHAPTERS.size():
		return []
	for spot: Array in Pve.CHAPTERS[index][2]:
		var city: Array = Pve.CITIES.get(str(int(spot[0])), [])
		if not city.is_empty() and int(city[0]) == TRUNK and map_id in [int(city[1]), int(city[2])]:
			return [float(spot[1]) - HELP_BOX / 2.0 + HELP_SHIFT, float(spot[2]) - HELP_BOX]
	return []

func _try_want() -> void :
	if _want_map == 0 or client == null:
		return
	var id: int = city_of_map(_want_map)
	var city: Array = Pve.CITIES.get(str(id), [])
	if city.is_empty():
		_want_map = 0
		return
	_chapter = clampi(int(city[6]) - 1, 0, Pve.CHAPTERS.size() - 1)
	if not client.pve_cities.has(id):
		return
	var hard: bool = int(city[2]) != 0 and int(city[2]) == _want_map
	_want_map = 0
	if _mode == "station" and _city != id:
		_leave_station()
	if _mode != "station":
		_open_city(id)
	if _mode == "station" and _city == id and hard and _hard_open():
		_diff = 2



func _paint() -> void :
	_tip_box = Rect2()
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(Hall.FILE, Hall.R)
		_use(Pve.FILE, Pve.R)
		_use(PvR.FILE, PvR.R)
		_use(Ask.FILE, Ask.R)
	_scene()
	if _mode == "world":
		_draw_world()
	else:
		_draw_station()
	_draw_chat()
	_draw_menu()
	if _mode == "world" and _tip_city != 0:
		_draw_tip(_tip_city)
	elif _mode == "station":
		if _sweep_map != 0:
			_draw_sweep()
		_draw_hints()
	if _mode == "world" and _help_map != 0:
		_draw_help()
	match _sheet_id:
		"find":
			_draw_find()
		"pass":
			_draw_pass()
		"watch", "team":
			_hide_edits()
			_draw_watch()
		"reset":
			_hide_edits()
			ResetAsk.paint(self, reset_cost)
		_:
			_hide_edits()
			if not _viewing.is_empty():
				_draw_viewing()
	if _focus != null and _focus.visible:
		_focus.grab_focus.call_deferred()
		_focus.select_all.call_deferred()
		_focus = null
	if _award_open:
		_draw_award_frame()


func _draw_find() -> void :
	var at: Vector2 = _window(358.0, 258.0)
	_fmid("title_findroom_t", at + Vector2(0, 20), 358.0)
	_fmid("label_goroomid_t", at + Vector2(0, 55), 358.0)
	_fmid("public_input_bk_m", at + Vector2(0, 82), 358.0)
	_fput(_id, Rect2(at + Vector2(89, 82), Vector2(180, 35)), 16.0)
	_fmid("word_inputroompassword_t", at + Vector2(0, 124), 358.0)
	_fmid("public_input_bk_m", at + Vector2(0, 148), 358.0)
	_fput(_key, Rect2(at + Vector2(89, 148), Vector2(180, 35)), 16.0)
	_confirm(at, 358.0, 258.0, "title_title_confirm_green_t")


func _draw_pass() -> void :
	var at: Vector2 = _window(358.0, 258.0)
	_fwords("NHẬP MẬT MÃ", BOLD, 15.0, Color.WHITE, "c", at + Vector2(88, 18), 182.0, 1.5, 28.0, true, TITLE_RIM)
	_fwords(T_PASSWORD, BOLD, 13.0, Color.WHITE, "c", at + Vector2(24, 77), 310.0, 1.5, 21.0, true, TITLE_RIM)
	_fmid("public_input_bk_m", at + Vector2(0, 111), 358.0)
	_fput(_pass, Rect2(at + Vector2(89, 111), Vector2(180, 35)), 16.0)
	_confirm(at, 358.0, 258.0, "title_title_confirm_green_t")


func _draw_watch() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), ASK_DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(float(Ask.SIZE[0]), float(Ask.SIZE[1]))
	var frame: Vector2 = at + Vector2(float(Ask.PANELS["frame"][0]), float(Ask.PANELS["frame"][1]))
	_hit("panel", Rect2(frame * _f, _cell_size("xa_frame") * _f), false)
	_fblit("xa_frame", frame)
	var body: Array = Ask.TEXTS["txtContent"]
	var rows: Array = watch_lines()
	for i in range(rows.size()):
		_fwords(str(rows[i]), ARIAL_BOLD, float(body[4]), Color(str(body[5])), "l", 
			at + Vector2(float(body[0]) + ASK_GUTTER, float(body[1]) + ASK_LINE * i), float(body[2]) - ASK_GUTTER * 2.0, 0.0, 0.0, false)
	var ok: Array = Ask.NODES["btnConfirm"]
	var no: Array = Ask.NODES["btnCancel"]
	_fbutton("ask:ok", "xa_ok", at + Vector2(float(ok[0]), float(ok[1])))
	_fbutton("ask:no", "xa_no", at + Vector2(float(no[0]), float(no[1])))
	_fblit("xa_guy", at + Vector2(float(Ask.GUY[0]), float(Ask.GUY[1])))


func watch_text() -> String:
	var name: String = str(_watch.get("m_szName", "")).strip_edges()
	return WATCH_ASK.replace("@name@", name if not name.is_empty() else "room %d" % int(_watch.get("m_nRoomId", 0)))


func team_text() -> String:
	return T_TEAM_ASK.replace("@num1@", str(int(_team_fee()[2])))

func _team_fee() -> Array:
	return GuildTeam.KEEP.get(str(int(_watch.get("nLevel", 0))), [0, 0, 0])


func watch_lines() -> Array:
	var spec: Array = Ask.TEXTS["txtContent"]
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(float(spec[4]) * _f))
	var limit: float = (float(spec[2]) - ASK_GUTTER * 2.0) * _f
	var out: Array = []
	var line: String = ""
	for word: String in (team_text() if _sheet_id == "team" else watch_text()).split(" "):
		var next: String = word if line.is_empty() else line + " " + word
		if not line.is_empty() and font.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > limit:
			out.append(line)
			line = word
		else:
			line = next
	out.append(line)
	return out

func _draw_world() -> void :
	var stage: Vector2 = _at("hall")
	var index: int = chapter()
	if index != _bg_chapter:
		_bg_from = _bg_chapter
		_bg_chapter = index
		_fade_at = _time
	var mix: float = clampf((_time - _fade_at) / FADE, 0.0, 1.0)
	if mix < 1.0 and _bg_from >= 0:
		_picture(str(Pve.CHAPTERS[_bg_from][1]), stage, Vector2(1000, 600), 1.0)
	_picture(str(Pve.CHAPTERS[index][1]), stage, Vector2(1000, 600), mix if _bg_from >= 0 else 1.0)
	_frows(Pve.WPLACE, stage)
	var bar: Array = Pve.WORLD.bar
	draw_rect(Rect2((stage + Vector2(float(bar[0]), float(bar[1]))) * _f, Vector2(float(bar[2]), float(bar[3])) * _f), Color(0, 0, 0, 0.4))
	var title: Array = Pve.WTEXT.label1
	_fwords(str(Pve.CHAPTERS[index][0]), ARIAL_BOLD, float(title[4]), Color(str(title[5])), "c", stage + Vector2(float(title[0]) - 300.0, float(title[1]) - 12.0), 
		600.0, 1.0, 24.0, false)
	for spot: Array in Pve.CHAPTERS[index][2]:
		_draw_city(int(spot[0]), stage + Vector2(float(spot[1]), float(spot[2])), false)
	var team: Variant = Pve.CHAPTERS[index][3]
	if team is Array:
		_draw_city(int(team[0]), stage + Vector2(float(team[1]), float(team[2])), true)
	var last: Array = Pve.WORLD.last
	var next: Array = Pve.WORLD.next
	if index > 0:
		_fbutton("chapter:last", "pvh_last", stage + Vector2(float(last[0]), float(last[1])))
	else:
		_fblit("pvh_last_dis", stage + Vector2(float(last[0]), float(last[1])))
	if index < Pve.CHAPTERS.size() - 1:
		_fbutton("chapter:next", "pvh_next", stage + Vector2(float(next[0]), float(next[1])))
	else:
		_fblit("pvh_next_dis", stage + Vector2(float(next[0]), float(next[1])))
	var close: Array = Pve.WORLD.close
	_fbutton("close", "pvh_close_w", stage + Vector2(float(close[0]), float(close[1])))


func _picture(path: String, at: Vector2, wide: Vector2, alpha: float = 1.0) -> bool:
	var texture: Texture2D = pack.picture(path) if not path.is_empty() else null
	if texture == null:
		return false
	draw_texture_rect(texture, Rect2(at * _f, wide * _f), false, Color(1, 1, 1, alpha))
	return true



func _draw_help() -> void :
	var spot: Array = help_spot(chapter(), _help_map)
	if spot.is_empty():
		return
	var at: Vector2 = _at("hall") + Vector2(float(spot[0]), float(spot[1]))
	var arrow: Array = GuideAtlas.HELP["down"]
	_help_film(str(GuideView.FILM["down"]), int((_time - _help_at) * float(GuideAtlas.FX_FPS)), at + Vector2(float(arrow[0]), float(arrow[1])))
	var place: Array = GuideView.TIP_TEXT["down"]
	_fwords(T_QUEST_MAP, ARIAL_BOLD, float(GuideAtlas.HELP["size"]), GuideView.TIP_COLOR, "c", 
		at + Vector2(0, float(place[2]) - HELP_LINE / 2.0), HELP_BOX, 4.0, HELP_LINE, false, GuideView.TIP_RIM)


func _help_film(key: String, frame: int, at: Vector2) -> void :
	if pack == null:
		return
	var fx: Dictionary = pack.effect_cached(key)
	if fx.is_empty():
		pack.effect(key)
		return
	var frames: Array = fx.get("data", {}).get("frames", [])
	var pages: Array = fx.get("pages", [])
	if frames.is_empty():
		return
	var cell: Dictionary = frames[posmod(frame, frames.size())]
	var page: int = int(cell.get("page", 0))
	if page >= pages.size() or pages[page] == null:
		return
	var rect: Array = cell.get("rect", [0, 0, 0, 0])
	var pivot: Array = cell.get("pivot", [0, 0])
	var src: Rect2 = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	draw_texture_rect_region(pages[page], Rect2((at - Vector2(float(pivot[0]), float(pivot[1]))) * _f, src.size * _f), src)



func _draw_city(id: int, at: Vector2, team: bool) -> void :
	var city: Array = Pve.CITIES.get(str(id), [])
	if city.is_empty():
		return
	var info: Array = client.pve_cities.get(id, [])

	var grey: bool = not team_open(_self_team()) if team else ( not info.is_empty() and int(info[0]) & ENABLE == 0)
	var icon: String = str(city[7])
	if grey:
		icon = icon.replace(".webp", "_g.webp")
	var wide: Vector2 = Vector2(float(city[8][0]), float(city[8][1]))
	var id_key: String = "city:%d" % id
	var lit: float = _shine(id_key)
	_picture(icon, at, wide, 1.0)
	if lit > 1.0:
		var texture: Texture2D = pack.picture(icon)
		if texture != null:
			draw_texture_rect(texture, Rect2(at * _f, wide * _f), false, Color(1, 1, 1, 0.16))
	_hit(id_key, Rect2(at * _f, wide * _f), false)
	if info.is_empty():
		return
	var rank: int = maxi(eval_rank(int(info[1])), eval_rank(int(info[2])))
	if rank > 0:
		var cell: Vector2 = _cell_size("pvh_eval%d" % rank)
		_fblit("pvh_eval%d" % rank, at + Vector2(0, wide.y - 80.0 - cell.y))

func _draw_station() -> void :
	var frame: Vector2 = _at("hall")
	_frows(_parts.get("hall", []), frame)
	var city: Array = _city_row()
	if city.is_empty():
		return
	var base: Array = Pve.MAPS.get(str(city[1]), [])
	var map: Array = Pve.MAPS.get(str(_map_id()), [])
	var spots: Dictionary = Pve.STATION
	if not base.is_empty():
		_picture(str(base[10]), frame + Vector2(float(spots.gui[0]), float(spots.gui[1])), Vector2(168, 100))
	_hit("help", Rect2((frame + Vector2(float(spots.help[0]), float(spots.help[1]))) * _f, Vector2(16, 16) * _f), false)
	var texts: Dictionary = spots.texts
	if not map.is_empty():
		var label: Array = texts.txtHelperScore
		_fwords(str(helper_need(map)), ARIAL_BOLD, float(label[4]), Color(str(label[5])), "c", frame + Vector2(float(label[0]) - 60.0, float(label[1]) - 13.0), 
			120.0, 1.0, 26.0, false)
		_draw_rewards(frame, map)
	var info: Array = client.pve_cities.get(_city, [])
	var rank: int = eval_rank(int(info[_diff])) if info.size() > 2 else 0
	if rank > 0:
		var cell: Vector2 = _cell_size("pvh_eval_l%d" % rank)
		_fblit("pvh_eval_l%d" % rank, frame + Vector2(float(spots.eval[0]) - cell.x / 2.0, float(spots.eval[1])))
	else:
		var label: Array = texts.txtNoPass
		_fwords(str(spots.no_pass), ARIAL_BOLD, float(label[4]), Color(str(label[5])), "c", frame + Vector2(float(label[0]), float(label[1]) - 9.0), 
			float(label[2]), 1.0, 18.0)

	var hard_ok: bool = _hard_open()
	for diff: int in [1, 2]:
		var key: String = "normal" if diff == 1 else "hard"
		var at: Vector2 = frame + Vector2(float(spots[key][0]), float(spots[key][1]))
		var id: String = "diff:%d" % diff
		if _diff == diff:
			_fblit("pvh_opt_bk", at)
		var word: String = "pvh_w_%s%s" % [key, "_sel" if _diff == diff else ""]
		if diff == 2 and not hard_ok:
			word = "pvh_w_hard_dis"
		var size_word: Vector2 = _cell_size(word)
		_fblit(word, at + ((Vector2(85, 26) - size_word) / 2.0).round(), 0.0, 0.0, _glow(id) if diff == 1 or hard_ok else Color.WHITE)
		_hit(id, Rect2(at * _f, Vector2(85, 26) * _f), false)
	if not _sweep_hidden:
		_fbutton("sweep", "pvh_sweep", frame + Vector2(float(spots.sweep[0]), float(spots.sweep[1])))
	_fbutton("quick", "pvh_quick", frame + Vector2(float(spots.quick[0]), float(spots.quick[1])))
	_fbutton("create", "pvh_create", frame + Vector2(float(spots.create[0]), float(spots.create[1])))
	_fbutton("find", "pvh_find", frame + Vector2(float(spots.find[0]), float(spots.find[1])))
	_fbutton("page:prev", "pvh_pg_prev", frame + Vector2(float(spots.prev[0]), float(spots.prev[1])))
	_fbutton("page:next", "pvh_pg_next", frame + Vector2(float(spots.next[0]), float(spots.next[1])))
	_draw_rooms(frame)
	var side: Vector2 = _at("list")
	_frows(_parts.get("list", []), side)
	_draw_players(side)


func _draw_rewards(frame: Vector2, map: Array) -> void :
	var items: Array = map[7]
	for i in range(mini(items.size(), Pve.REWARD.size())):
		var spot: Array = Pve.REWARD[i]
		var item: Array = Pve.ITEMS.get(str(items[i]), [])
		if item.is_empty():
			continue
		var quality: int = int(item[2])
		if quality >= 2 and quality <= 5:
			_fblit("pvh_q%d" % quality, frame + Vector2(float(spot[0]), float(spot[1])))
		_picture(str(item[1]), frame + Vector2(float(spot[2]), float(spot[3])), Vector2(52, 49))
		_fwords(_cut(str(item[0]), ARIAL_BOLD, 12.0, float(spot[6])), ARIAL_BOLD, 12.0, Color.WHITE, "c", frame + Vector2(float(spot[4]), float(spot[5])), float(spot[6]), 1.0, 0.0, 
			false, Color("0057a7"))


func _cut(text: String, font: Font, px: float, wide: float) -> String:
	font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	var room: float = (wide - 4.0) * _f
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= room:
		return text
	var shown: String = text
	while shown.length() > 1 and font.get_string_size(shown + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
		shown = shown.left(-1)
	return shown.strip_edges() + "..."


func _draw_rooms(frame: Vector2) -> void :
	var list: Array = Pve.LIST
	var shown: Array = rooms()
	for slot in range(mini(shown.size(), int(list[5]))):
		var room: Dictionary = shown[slot]
		var id: int = int(room.get("m_nRoomId", 0))
		var key: String = "room:%d" % id
		var at: Vector2 = frame + Vector2(float(list[0]), float(list[1]) + float(list[4]) * slot)
		var state: int = int(room.get("m_state", 1))
		var full: bool = int(room.get("m_nNum", 0)) >= int(room.get("m_nMax", 0)) and int(room.get("m_nMax", 0)) > 0
		var back: String = "pvh_row_sel" if _hover == key else ("pvh_row_wait" if state == 1 else "pvh_row_pair")
		_hit(key, _fblit(back, at), false)
		var status: String = "pvh_st_run" if state == 3 else ("pvh_st_pair" if state == 2 else ("pvh_st_wait_dis" if full else "pvh_st_wait"))
		var cell: Vector2 = _cell_size(status)
		_fblit(status, at + Vector2(float(Pve.ROW.status[0]) - cell.x / 2.0, float(Pve.ROW.status[1])))
		if int(room.get("m_isValidate", 0)) == 1:
			_fblit("pvh_lock", at + Vector2(float(Pve.ROW.lock[0]), float(Pve.ROW.lock[1])))
		var rim: Color = Color(str(Pve.ROW.glow.run if state == 3 else (Pve.ROW.glow.grey if state == 2 or full else Pve.ROW.glow.wait)))
		var map_id: int = int(room.get("m_mapId", 0))
		var map: Array = Pve.MAPS.get(str(map_id), [])
		var title: String = str(map[0]) if not map.is_empty() else map_title(map_id)
		var tint: Color = Color(str(Pve.ROW.diff.get(str(int(map[9])) if not map.is_empty() else "1", "ffffff")))
		_row_text(str(id), "lblRoomId", at, Color.WHITE, rim)
		_row_text(str(room.get("m_szName", "")), "lblRoomName", at, Color.WHITE, rim)
		_row_text(title, "lblMapName", at, tint, rim)
		_row_text("%d/%d" % [int(room.get("m_nNum", 0)), int(room.get("m_nMax", 0))], "lblPlayerNum", at, Color.WHITE, rim)

func _row_text(text: String, key: String, at: Vector2, color: Color, rim: Color) -> void :
	var label: Array = Pve.ROW[key]
	_fwords(text, ARIAL_BOLD, float(label[4]), color, str(label[7]), at + Vector2(float(label[0]), 0), float(label[2]), 1.0, float(Pve.LIST[3]), true, rim)


func _draw_hints() -> void :
	var text: String = hint_text(_hover)
	if text.is_empty():
		return
	var lines: PackedStringArray = text.split("\n")
	var wide: float = 0.0
	for line: String in lines:
		wide = maxf(wide, ARIAL.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, roundi(12.0 * _f)).x / _f)
	wide = minf(wide + 12.0, 420.0)
	var high: float = 16.0 * lines.size() + 6.0
	var mouse: Vector2 = get_local_mouse_position() / _f + Vector2(12, 18)
	mouse.x = minf(mouse.x, _fw - wide - 2.0)
	mouse.y = minf(mouse.y, _fh - high - 2.0)
	draw_rect(Rect2(mouse * _f, Vector2(wide, high) * _f), HINT_FILL)
	draw_rect(Rect2(mouse * _f, Vector2(wide, high) * _f), Color("919999"), false, maxf(1.0, _f))
	for i in range(lines.size()):
		_fwords(lines[i], ARIAL, 12.0, HINT_TEXT, "l", mouse + Vector2(6, 3 + 16 * i), wide - 12.0, 0.0, 16.0, false)


func hint_text(id: String) -> String:
	var city: Array = _city_row()
	if city.is_empty():
		return ""
	var normal: Array = Pve.MAPS.get(str(city[1]), [])
	var hard: Array = Pve.MAPS.get(str(city[2]), []) if int(city[2]) != 0 else []
	match id:
		"help":
			return str(normal[1]) if not normal.is_empty() else ""
		"diff:1":
			if normal.is_empty():
				return T_NORMAL
			var parts: Array = [T_NORMAL]
			parts.append(T_REC.replace("@num1@", str(int(normal[6]))).replace("@num2@", str(helper_need(normal))) + "\n" + T_MIN.replace("@num1@", str(int(normal[5]))))
			if int(city[0]) != TEAM:
				parts.append(T_THEW_NEED.replace("@num1@", str(int(normal[3]))))
			return "\n".join(parts)
		"diff:2":
			if not _hard_open() or hard.is_empty():
				return T_HARD + "\n" + T_HARD_LOCK if not _hard_open() else T_HARD
			var rows: Array = [T_HARD, T_REC.replace("@num1@", str(int(hard[6]))).replace("@num2@", str(helper_need(hard))) + "\n"
				+ T_MIN.replace("@num1@", str(int(hard[5])))]
			if int(city[0]) != TEAM:
				rows.append(T_THEW_NEED.replace("@num1@", str(int(hard[3]))))
			return "\n".join(rows)
	return ""


func tip_layout(id: int) -> Dictionary:
	var city: Array = Pve.CITIES.get(str(id), [])
	var map: Array = Pve.MAPS.get(str(city[1]), []) if not city.is_empty() else []
	if map.is_empty() or not client.pve_cities.has(id):
		return {}
	var hero: bool = int(city[2]) != 0 and Pve.MAPS.has(str(city[2]))
	var branch: bool = int(city[0]) == BRANCH
	var parts: Array = []
	var y: float = 10.0
	parts.append(["name", y])
	y += 22.0 + 2.0
	parts.append(["desc", y])
	var font_size: int = maxi(6, roundi(12.0 * _f))
	y += ARIAL.get_multiline_string_size(str(map[1]), HORIZONTAL_ALIGNMENT_LEFT, 408.0 * _f, font_size).y / _f + 4.0 + 2.0
	if not branch:
		parts.append(["helper", y])
		y += maxf(23.0, HELPER_LINE * helper_spans(city, 0).size() + 4.0) + 2.0
		parts.append(["record", y])
		y += (101.0 if hero else 83.0) + 2.0
	parts.append(["reward", y])
	y += (190.0 if hero else 105.0) + 2.0
	parts.append(["bottom", y])
	y += 59.0 + 10.0
	return {"parts": parts, "high": y, "hero": hero}


func tip_place(id: int, high: float) -> Array:
	var chapter_row: Array = Pve.CHAPTERS[chapter()]
	var spots: Array = chapter_row[2].duplicate()
	if chapter_row[3] is Array:
		spots.append(chapter_row[3])
	for spot: Array in spots:
		if int(spot[0]) != id:
			continue
		var city: Array = Pve.CITIES.get(str(id), [])
		var cx: float = float(spot[1]) + float(city[8][0]) / 2.0
		var sy: float = float(spot[2])
		var x: float = clampf(floorf(cx - TIP_W / 2.0), 0.0, 1000.0 - TIP_W)
		var y: float = sy - high + 30.0
		if y >= 0.0:
			return [x, y - 20.0, false, floorf(cx - x - 21.0)]
		y = minf(sy + 100.0, 600.0 - high - 20.0)
		return [x, y + 20.0, true, floorf(cx - x - 21.0)]
	return []

func _draw_tip(id: int) -> void :
	var layout: Dictionary = tip_layout(id)
	if layout.is_empty():
		return
	var high: float = float(layout.high)
	var place: Array = tip_place(id, high)
	if place.is_empty():
		return
	var step: float = clampf((_time - _tip_at) / TIP_TIME, 0.0, 1.0)
	var eased: float = sin(step * PI / 2.0)
	var flip: bool = bool(place[2])
	var origin: Vector2 = _at("hall") + Vector2(float(place[0]), float(place[1]) + (-20.0 if flip else 20.0) * (1.0 - eased))
	var alpha: float = eased
	var city: Array = Pve.CITIES[str(id)]
	var info: Array = client.pve_cities.get(id, [0, 0, 0])
	var flags: int = int(info[0])
	var map: Array = Pve.MAPS[str(city[1])]
	var hard: Array = Pve.MAPS.get(str(city[2]), []) if bool(layout.hero) else []
	var trunk: bool = int(city[0]) == TRUNK

	var box: Rect2 = Rect2(origin * _f, Vector2(TIP_W, high) * _f)
	_tip_box = box.grow(3.0 * _f)
	_round(box.grow(3.0 * _f), Color(0, 0, 0, 0.25 * alpha), 36.0)
	_round(box, Color(1, 1, 1, alpha), 30.0, Color(TIP_EDGE, alpha), 6.0)
	var arrow: Vector2 = _cell_size("pvh_tip_arrow")
	var arrow_at: Vector2 = origin + Vector2(float(place[3]), -23.0 if flip else high - 3.0)
	var cell: Array = _cells.get("pvh_tip_arrow", [])
	if not cell.is_empty() and cell[0] != null:
		var region: Array = cell[1]
		var dest: Rect2 = Rect2(arrow_at * _f, arrow * _f)
		_tip_box = _tip_box.merge(dest)
		if flip:

			draw_set_transform(Vector2(0, dest.position.y * 2.0 + dest.size.y), 0.0, Vector2(1, -1))
		draw_texture_rect_region(cell[0], dest, Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])), Color(1, 1, 1, alpha))
		if flip:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var ink: Callable = func(color: String) -> Color: return Color(Color(color), alpha)
	for part: Array in layout.parts:
		var y: float = float(part[1])
		var at: Vector2 = origin + Vector2(0, y)
		match str(part[0]):
			"name":
				var title: String = str(map[0]) + (T_SOLO if int(city[0]) == BRANCH else "")
				_fwords(title, ARIAL_BOLD, 16.0, ink.call("484848"), "l", at + Vector2(12, 0), 410.0, 0.0, 22.0)
			"desc":
				_fpara(str(map[1]), ARIAL, 12.0, ink.call("919191"), at + Vector2(12, 0), 408.0)
			"helper":
				_fblit("pvh_tip_up", at + Vector2(12, 6), 0.0, 0.0, Color(1, 1, 1, alpha))
				var lines: Array = helper_spans(city, _my_helper())
				for i in range(lines.size()):

					var x: float = 28.0


					var total: float = 0.0
					for span: Array in lines[i]:
						total += ARIAL_BOLD.get_string_size(str(span[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(float(span[2]) * _f))).x / _f
					var fit: float = minf(1.0, (TIP_W - 40.0) / maxf(1.0, total))
					for span: Array in lines[i]:
						var px: float = float(span[2]) * fit
						var font_size: int = maxi(6, roundi(px * _f))
						var wide: float = ARIAL_BOLD.get_string_size(str(span[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f
						_fwords(str(span[0]), ARIAL_BOLD, px, ink.call(str(span[1])), "l", at + Vector2(x, HELPER_LINE * i + (16.0 - px) * 0.9), wide + 2.0, 0.0, 0.0, false)
						x += wide
			"record":
				_fwords(T_RECORD, ARIAL_BOLD, 13.0, ink.call("484848"), "l", at + Vector2(12, 0), 300.0, 0.0, 20.0)
				_fblit("pvh_tip_medal", at + Vector2(12, 22), 0.0, 0.0, Color(1, 1, 1, alpha))
				_fwords(record_text(T_REC_NORMAL, client.pve_record(int(city[1]), false)), ARIAL_BOLD, 12.0, ink.call("008fe9"), "l", at + Vector2(28, 20), 390.0, 0.0, 18.0)
				if bool(layout.hero):
					_fblit("pvh_tip_star", at + Vector2(12, 41), 0.0, 0.0, Color(1, 1, 1, alpha))
					_fwords(record_text(T_REC_HARD, client.pve_record(int(city[2]), false)), ARIAL_BOLD, 12.0, ink.call("008fe9"), "l", at + Vector2(28, 39), 390.0, 0.0, 18.0)
			"reward":
				_fwords(T_REWARD, ARIAL_BOLD, 13.0, ink.call("484848"), "l", at + Vector2(12, 0), 300.0, 0.0, 20.0)
				_draw_tip_items(at, 18.0, map, "pvh_tip_wnormal", flags & COMMON_TODAY != 0, trunk, alpha)
				if not hard.is_empty():
					_draw_tip_items(at, 105.0, hard, "pvh_tip_whard", flags & HERO_TODAY != 0, trunk, alpha)
			"bottom":
				_draw_tip_bottom(at, city, info, alpha)


func _draw_tip_items(at: Vector2, top: float, map: Array, word: String, passed: bool, trunk: bool, alpha: float) -> void :
	var white: Color = Color(1, 1, 1, alpha)
	_fblit(word, at + Vector2(91, top + 19.0), 0.0, 0.0, white)
	_fblit("pvh_tip_pass" if passed else "pvh_tip_nopass", at + Vector2(32, top + 15.0), 0.0, 0.0, white)
	if trunk:
		_fwords(T_THEW.replace("@num1@", str(int(map[3]))), ARIAL, 12.0, Color(Color("919191"), alpha), "l", at + Vector2(91, top + 39.0), 80.0, 0.0, 18.0)
	var items: Array = map[7]
	for i in range(mini(items.size(), 4)):
		var item: Array = Pve.ITEMS.get(str(items[i]), [])
		if item.is_empty():
			continue
		var box: Vector2 = at + Vector2(171.0 + 63.0 * i, top - 1.0)
		var icon: Texture2D = pack.picture(str(item[1]))
		if icon != null:
			draw_texture_rect(icon, Rect2((box + Vector2(7, 7)) * _f, Vector2(50, 50) * _f), false, white)
		_fwords(_cut(str(item[0]), ARIAL, 12.0, 64.0), ARIAL, 12.0, Color(Color("919191"), alpha), "c", box + Vector2(0, 46), 64.0, 0.0, 18.0, false)


func _draw_tip_bottom(at: Vector2, city: Array, info: Array, alpha: float) -> void :
	var flags: int = int(info[0])
	var rank: int = eval_rank(int(info[2]) if int(info[2]) != 0 else int(info[1]))
	if rank > 0:
		_fwords(T_EVAL, ARIAL_BOLD, 13.0, Color(Color("484848"), alpha), "l", at + Vector2(242, 0), 120.0, 0.0, 20.0)
		var cell: Vector2 = _cell_size("pvh_eval%d" % rank)
		_fblit("pvh_eval%d" % rank, at + Vector2(296, 28.0 - cell.y / 2.0), 0.0, 0.0, Color(1, 1, 1, alpha))
	var rows: Array = []
	if int(city[5]) != 0:
		rows.append([(T_CHAR_LEVEL if int(city[0]) == TRUNK else T_TEAM_LEVEL).replace("@num1@", str(int(city[5]))), flags & LEVEL != 0])
	if int(city[3]) != 0:
		var pre: Array = Pve.CITIES.get(str(city[3]), [])
		var pre_map: Array = Pve.MAPS.get(str(pre[1]), []) if not pre.is_empty() else []
		rows.append([T_PRE.replace("@name@", str(pre_map[0]) if not pre_map.is_empty() else ""), flags & PRE_CITY != 0])
	if int(city[4]) != 0:
		rows.append(["Nhiệm vụ #%d" % int(city[4]), flags & QUEST != 0])
	if int(city[0]) == TEAM:
		rows.append([T_CAPTAIN, team_open(_self_team())])
	if rows.is_empty():
		return
	_fwords(T_REQUIRE, ARIAL_BOLD, 13.0, Color(Color("484848"), alpha), "l", at + Vector2(12, 0), 200.0, 0.0, 20.0)
	for i in range(rows.size()):
		var ok: bool = bool(rows[i][1])
		var spot: Vector2 = at + Vector2(32, 19.0 + 18.0 * i)
		_fblit("pvh_req_ok" if ok else "pvh_req_fail", spot, 0.0, 0.0, Color(1, 1, 1, alpha))
		_fwords(str(rows[i][0]), ARIAL_BOLD, 12.0, Color(PASS_COLOR if ok else FAIL_COLOR, alpha), "l", spot + Vector2(20, -2), 360.0, 0.0, 17.0)



func _activate(id: String) -> void :
	if _sheet_id == "reset":
		_reset_click(id)
		return
	if id in ["panel", "sw:panel", "rw:panel"]:
		return
	if id.begins_with("rw:") or id.begins_with("sw:"):
		_modal_click(id)
		return
	if _sheet_id == "watch" or _sheet_id == "team":
		if id == "ask:ok" and _sheet_id == "team":
			_confirm_team()
		elif id == "ask:ok":
			_confirm_watch()
		elif id == "ask:no":
			_close_sheet()
		return
	if not _sheet_id.is_empty():
		if id == "ok":
			_submit()
		elif id == "cancel":
			_close_sheet()
		return
	if id.begins_with("city:"):
		_open_city(int(id.substr(5)))
		return
	if id.begins_with("room:"):
		_room_click(int(id.substr(5)))
		return
	match id:
		"chapter:last":
			_chapter = maxi(0, chapter() - 1)
			_tip_city = 0
			_help_map = 0
		"chapter:next":
			_chapter = mini(Pve.CHAPTERS.size() - 1, chapter() + 1)
			_tip_city = 0
			_help_map = 0
		"close":
			closed.emit()
		"back":
			if _mode == "station":
				_leave_station()
			else:
				closed.emit()
		"diff:1":
			_diff = 1
			_refresh_sweep()
		"diff:2":
			if not _hard_open():
				return
			if int(_city_row()[2]) == 0:
				say(T_NO_HARD)
				return
			_diff = 2
			_refresh_sweep()
		"sweep":

			if _level_ok() and _sweep_map == 0:
				_sweep_map = _map_id()
		"create":

			if _level_ok() and not client.pve_create(_map_id(), _kind):
				say("Chưa vào được lúc này.")
		"quick":

			if _level_ok():
				if client.is_pairing():
					say(str(PvR.WORDS.tip132))
				elif not client.pve_join(0, _map_id(), _kind):
					say("Chưa vào được lúc này.")
		"find":
			_open_sheet("find")
		"page:prev":
			if _site >= PAGE:
				_site -= PAGE
				_in_hall(_site)
		"page:next":
			if rooms().size() >= PAGE:
				_site += PAGE
				_in_hall(_site)
		"help":
			pass
		_:
			_shared(id)


func _level_ok() -> bool:
	var map: Array = Pve.MAPS.get(str(_map_id()), [])
	if map.is_empty():
		return false
	var need: int = int(map[8])
	if _level() < need:
		say(T_LEVEL.replace("@num1@", str(need)))
		return false
	return true




func _room_click(id: int) -> void :
	var room: Dictionary = client.room_state.rooms.get(id, {})
	if room.is_empty():
		return
	var state: int = int(room.get("m_state", 1))
	if state == 3:
		_ask_watch(room)
	elif state == 2:
		say(T_PAIRING)
	elif int(room.get("m_nNum", 0)) >= int(room.get("m_nMax", 0)) and int(room.get("m_nMax", 0)) > 0:
		say(T_FULL)
	elif int(room.get("m_isValidate", 0)) == 1:
		_open_sheet("pass", id)
	elif client.is_pairing():
		say(str(PvR.WORDS.tip132))
	elif not client.pve_join(id, 0, _kind):
		say("Chưa vào được lúc này.")


func _open_sheet(kind: String, target: int = 0) -> void :
	_viewing = {}
	_sheet_id = kind
	_target = target
	_watch = {}
	match kind:
		"find":
			_id.text = ""
			_key.text = ""
			_focus = _id
		"pass":
			_pass.text = ""
			_focus = _pass


func ask_reset(map: int) -> void :
	var info: Array = client.pve_cities.get(city_of_map(map), [])
	if info.is_empty():
		return
	var row: Array = PvR.MAPS.get(str(map), [])
	reset_cost = ResetAsk.price(info, int(row[5]) if row.size() > 5 else 0)
	_open_sheet("reset")
	reset_map = map


func _reset_click(id: String) -> void :
	match id:
		"rs:ok":
			var map: int = reset_map
			_close_sheet()
			ResetAsk.confirm(self, client, map, reset_cost)
		"rs:no":
			_close_sheet()

func _close_sheet() -> void :
	_sheet_id = ""
	reset_map = 0
	_target = 0
	_watch = {}
	_focus = null
	_hide_edits()


func _ask_watch(room: Dictionary) -> void :
	if _sheet_id == "watch":
		return
	_close_sheet()
	_viewing = {}
	_sheet_id = "watch"
	_watch = room.duplicate()



func _confirm_watch() -> void :
	var id: int = int(_watch.get("m_nRoomId", 0))
	_close_sheet()
	if id > 0:
		client._look_oid = 0
		client.room_op(ROPT_LOOK_SCENE, id)


func _ask_team() -> void :
	var team: Dictionary = _self_team()
	if team.is_empty() or not GuildTeam.KEEP.has(str(int(team.get("nLevel", 0)))):
		return
	_close_sheet()
	_viewing = {}
	_sheet_id = "team"
	_watch = team.duplicate()


func _confirm_team() -> void :
	var fee: Array = _team_fee()
	_close_sheet()
	var team: Dictionary = _self_team()
	if team.is_empty():
		return
	if int(team.get("iCoin", 0)) < int(fee[1]) + int(fee[2]):
		say(T_TEAM_COIN)
	elif not client.guild_team_pve(true):
		say("Chưa vào được lúc này.")



func _submit() -> void :
	var id: int = 0
	var code: int = 0
	match _sheet_id:
		"find":
			if _id.text.strip_edges().is_empty():
				say(T_ROOM_ID)
				return
			id = _number(_id.text)
			code = _number(_key.text)
		"pass":
			if _pass.text.strip_edges().is_empty():
				say(T_PASSWORD)
				return
			id = _target
			code = _number(_pass.text)
		_:
			return
	_close_sheet()
	if client.is_pairing():
		say(str(PvR.WORDS.tip132))
	elif not client.pve_join(id, 0, _kind, code):
		say("Chưa vào được lúc này.")

func _wheel(step: int, at: Vector2) -> void :
	if _award_open and _award_list_rect().has_point(at / _f):
		_award_scroll = clampf(_award_scroll + LINE_STEP * step, 0.0, _award_max_scroll())
		return
	if _mode != "station" or not _viewing.is_empty() or not _sheet_id.is_empty():
		return
	_wheel_list(step, at)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _award_open and _award_list_rect().has_point(from / _f):
		_award_scroll = clampf(_award_scroll - moved.y / _f, 0.0, _award_max_scroll())
		return
	super (moved, from)


func _escape() -> bool:
	if _award_open:
		_close_awards()
		return true
	if not _sheet_id.is_empty():
		_close_sheet()
		return true
	if _sweep_map != 0:
		_sweep_map = 0
		return true
	return super ()



func chat_cover() -> Array:
	var out: Array = super ()
	if _tip_box.has_area():
		out.append(_tip_box)
	return out

func chat_busy() -> bool:
	return super () or _award_open or _sweep_map != 0 or not _sheet_id.is_empty()

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode == KEY_ESCAPE:
		if _mode == "station":
			_leave_station()
		else:
			closed.emit()
		get_viewport().set_input_as_handled()



func _now() -> int:
	return int(Time.get_unix_time_from_system())


static func sweep_hard_left(info: Array) -> int:
	return maxi(0, int(PvR.BATCH.hard_max) - (int(info[3]) if info.size() >= 4 else 0))




static func sweep_block(row: Array, evals: Array, batch: int, more: bool, vip_ok: bool, hard_left: int, have: int, thew: int) -> String:
	var hard: bool = int(row[4]) == HARD_DIFF
	var mine: int = (int(evals[1]) if hard else int(evals[0])) if evals.size() >= 2 else 0
	if mine < int(row[3]):
		return "eval"
	if more and not vip_ok:
		return "vip"
	if hard and hard_left < 1:
		return "hard"
	if batch < 1 or int(row[1]) * batch > have:
		return "cost"
	if int(row[0]) * batch > thew:
		return "thew"
	return ""


static func sweep_batch(row: Array, hard_left: int) -> int:
	return hard_left if int(row[4]) == HARD_DIFF else int(PvR.BATCH.count)

func _sweep_vip_ok() -> bool:
	return _vip_level(int(client.character.get("vipPoints", 0))) >= int(PvR.BATCH.vip) and int(client.character.get("vipTime", 0)) > _now()

func _sweep_have(row: Array) -> int:
	if int(row[2]) == CASH_COST:
		return int(client.currency.get("m_iCash", 0))
	return BagModel.item_count(client.bags, int(PvR.BATCH.ticket), 2)

func _sweep(more: bool) -> void :
	var row: Array = PvR.MAPS.get(str(_sweep_map), [])
	if row.is_empty() or _time - (_sweep_more_at if more else _sweep_once_at) < float(PvR.BATCH.lock):
		return
	var info: Array = client.pve_cities.get(city_of_map(_sweep_map), [])
	var evals: Array = [int(info[1]), int(info[2])] if info.size() >= 3 else [0, 0]
	var hard_left: int = sweep_hard_left(info)
	var batch: int = sweep_batch(row, hard_left) if more else 1
	var thew: int = int(client.character.get("thew", 0))
	match sweep_block(row, evals, batch, more, _sweep_vip_ok(), hard_left, _sweep_have(row), thew):
		"eval":
			var tip: String = str(PvR.WORDS.tip438 if int(row[4]) == HARD_DIFF else PvR.WORDS.tip437)
			say(tip.replace("@name@", str(PvR.SCORE_NAMES[clampi(int(row[3]), 0, PvR.SCORE_NAMES.size() - 1)])))
		"vip":
			say(str(PvR.WORDS.tip442))
		"hard":
			ask_reset(_sweep_map)
			say(str(PvR.WORDS.tip439))
		"cost":
			say(str(PvR.WORDS.tip451).replace("@name@", str(PvR.WORDS.cash if int(row[2]) == CASH_COST else PvR.WORDS.ticket)))
		"thew":
			stamina_asked.emit()
			say(str(PvR.WORDS.tip441))
		_:
			if batch > 0 and client.pve_sweep(_sweep_map, batch):
				if more:
					_sweep_more_at = _time
				else:
					_sweep_once_at = _time

func _modal_click(id: String) -> void :
	match id:
		"rw:ok", "rw:close":
			_close_awards()
		"sw:close":
			_sweep_map = 0
		"sw:once":
			if _sweep_map != 0:
				_sweep(false)
		"sw:more":
			if _sweep_map != 0:
				_sweep(true)


func _draw_sweep() -> void :
	var row: Array = PvR.MAPS.get(str(_sweep_map), [])
	if row.is_empty():
		_sweep_map = 0
		return
	var spot: Dictionary = PvR.SWEEP
	var texts: Dictionary = spot.texts
	var origin: Vector2 = _at("hall") + SWEEP_AT
	_hit("panel", Rect2(origin * _f, SWEEP_SIZE * _f), false)
	_fblit("pvr_sw", origin + _v(spot.static ))
	_fbutton("sw:close", "public_button_close", origin + _v(spot.close))
	var map: Array = Pve.MAPS.get(str(_sweep_map), [])
	if map.size() > 10:
		_picture(str(map[10]), origin + _v(spot.gui), Vector2(168, 100))

	var hard: bool = int(row[4]) == HARD_DIFF
	var word: String = str(PvR.WORDS.hard if hard else PvR.WORDS.normal)
	var label: Array = texts.txtMapName
	var name_x: float = float(label[0]) + 2.0
	var name_w: float = _fwords(str(map[0]) if not map.is_empty() else "", ARIAL_BOLD, 16.0, Color.WHITE, "l", origin + Vector2(name_x, float(label[1])), 132.0, 1.0)
	var diff: Array = texts.txtDifficult
	var diff_x: float = maxf(float(diff[0]) + 2.0, name_x + name_w + 6.0)
	_fwords(word, ARIAL_BOLD, 16.0, Color(str(spot.hard_ink if hard else spot.normal_ink)), "l", origin + Vector2(diff_x, float(diff[1])), 60.0, 1.0)
	_sweep_text(origin, texts.txtNeedThew, str(int(row[0])))
	_sweep_text(origin, texts.txtMyThew, str(int(client.character.get("thew", 0))))
	_sweep_text(origin, texts.txtSweepCost, str(int(row[1])))
	_sweep_cost_icon(origin + _v(spot.cost), row)
	var info: Array = client.pve_cities.get(city_of_map(_sweep_map), [])
	var batch: int = sweep_batch(row, sweep_hard_left(info))
	if _sweep_vip_ok():
		_fblit("pvr_sw_coin", origin + _v(spot.coin))
		_sweep_text(origin, texts.txtSweepCostMore, str(int(row[1]) * batch))
		_sweep_cost_icon(origin + _v(spot.cost_more), row)
	else:
		_fblit("pvr_sw_needvip", origin + _v(spot.needvip))
	if int(row[2]) == CASH_COST:
		_fblit("pvr_my_cash", origin + _v(spot.my_cash))
	else:
		_fblit("pvr_my_sweep", origin + _v(spot.my_sweep))
	_sweep_text(origin, texts.txtMySweep, str(_sweep_have(row)))
	var lock: float = float(PvR.BATCH.lock)
	if _time - _sweep_once_at < lock:
		_fblit("pvr_sw_once", origin + _v(spot.once), 0.0, 0.0, Color(0.55, 0.55, 0.55, 1.0))
	else:
		_fbutton("sw:once", "pvr_sw_once", origin + _v(spot.once))
	var more: String = "pvr_sw_more%d" % (batch if batch in [1, 2, 3, 10] else 3)
	if _time - _sweep_more_at < lock:
		_fblit(more + "_dis", origin + _v(spot.more))
	else:
		_fbutton("sw:more", more, origin + _v(spot.more))

func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))


func _sweep_text(origin: Vector2, label: Array, text: String) -> void :
	_fwords(text, ARIAL_BOLD, float(label[4]), Color(str(label[5])), "l", origin + Vector2(float(label[0]) + 2.0, float(label[1])), 90.0, 1.0, 0.0, false)


func _sweep_cost_icon(at: Vector2, row: Array) -> void :
	var icon: String = str(PvR.COST_ICONS.get(str(int(row[2])), ""))
	if not icon.is_empty():
		_fblit(icon, at)
	else:
		_fwords(str(PvR.WORDS.cash), ARIAL_BOLD, 12.0, Color("feec53"), "l", at + Vector2(0, -2), 34.0, 1.0, 0.0, false)





static func merged_items(vecs: Array) -> Array:
	var order: Array = []
	var seen: Dictionary = {}
	for kind in range(6):
		for vec: Array in vecs:
			if int(vec[0]) != kind:
				continue
			for pair: Array in vec[1]:
				var id: int = int(pair[0])
				if not seen.has(id):
					seen[id] = order.size()
					order.append([id, 0])
				order[seen[id]][1] = int(order[seen[id]][1]) + int(pair[1])
			break
	return order


static func award_cells_of(run: Dictionary) -> Array:
	var cells: Array = []
	if int(run.get("glory", 0)) > 0:
		cells.append(["honor", 0, int(run.glory)])
	for pair: Array in merged_items(run.get("vecs", [])):
		cells.append(["item", int(pair[0]), int(pair[1])])
	return cells


static func award_starts(counts: Array) -> Array:
	var starts: Array = [0.0]
	for count in counts:
		starts.append(float(starts[-1]) + SHOW_TIME + int(count) * ITEM_GAP + SHOW_TIME)
	return starts


static func render_high(count: int) -> float:
	var lines: int = int(ceil(count / 6.0))
	return float(PvR.RENDER.base) + (110.0 * (lines - 1) if count > 6 else 0.0)

static func bounce_out(t: float) -> float:
	if t < 1.0 / 2.75:
		return 7.5625 * t * t
	if t < 2.0 / 2.75:
		t -= 1.5 / 2.75
		return 7.5625 * t * t + 0.75
	if t < 2.5 / 2.75:
		t -= 2.25 / 2.75
		return 7.5625 * t * t + 0.9375
	t -= 2.625 / 2.75
	return 7.5625 * t * t + 0.984375


static func bounce(t: float) -> float:
	t = clampf(t, 0.0, 1.0)
	if t < 0.5:
		return (1.0 - bounce_out(1.0 - t * 2.0)) * 0.5
	return bounce_out(t * 2.0 - 1.0) * 0.5 + 0.5

func _award_counts() -> Array:
	var counts: Array = []
	for cells: Array in _award_cells:
		counts.append(cells.size())
	return counts


func _award_layout(t: float) -> Array:
	var counts: Array = _award_counts()
	var starts: Array = award_starts(counts)
	var gap: float = float(PvR.REWARD.gap)
	var rows: Array = []
	var y: float = 0.0
	for i in range(counts.size()):
		if t < float(starts[i]):
			break
		var high: float = render_high(int(counts[i]))
		rows.append(["run", i, y, high, float(starts[i])])
		y += high + gap
	if t >= float(starts[-1]) and _award_vip > 0:
		rows.append(["vip", 0, y, float(PvR.RENDER.end_high), float(starts[-1])])
		y += float(PvR.RENDER.end_high) + gap
	return [rows, maxf(0.0, y - gap)]

func _award_list_rect() -> Rect2:
	var list: Array = PvR.REWARD.list
	return Rect2(_stage() + AWARD_AT + Vector2(float(list[0]), float(list[1])), Vector2(float(list[2]), float(list[3])))

func _award_max_scroll() -> float:
	return maxf(0.0, float(_award_layout(_time - _award_at)[1]) - float(PvR.REWARD.list[3]))

func _open_awards(runs: Array) -> void :
	_award_open = true
	_award_runs = runs.duplicate(true)
	_award_cells = []
	for run in _award_runs:
		_award_cells.append(award_cells_of(run))
	_award_at = _time
	_award_scroll = 0.0
	_award_shown = 0
	var points: int = int(client.character.get("vipPoints", 0))
	_award_vip = _vip_level(points) if int(client.character.get("vipTime", 0)) > _now() else 0
	pack.load_bag()

func _close_awards() -> void :
	_award_open = false
	_award_runs = []
	_award_cells = []
	if _award_box != null:
		_award_box.visible = false


func _tick_awards() -> void :
	if client == null or _award_box == null:
		return
	if int(client.pve_sweep_rev) != _award_seen:
		_award_seen = int(client.pve_sweep_rev)
		if not _award_open and not client.pve_sweep_awards.is_empty():
			_open_awards(client.pve_sweep_awards)
	if not _award_open:
		_award_box.visible = false
		return
	var shown: int = (_award_layout(_time - _award_at)[0] as Array).size()
	if shown > _award_shown:
		_award_shown = shown
		_award_scroll = _award_max_scroll()
	var list: Array = PvR.REWARD.list
	_award_box.visible = true
	_award_box.position = (_stage() + AWARD_AT + Vector2(float(list[0]), float(list[1]))) * _f
	_award_box.size = Vector2(569.0, float(list[3])) * _f
	_award_box.queue_redraw()


func _draw_award_frame() -> void :
	var at: Vector2 = _stage() + AWARD_AT
	var spot: Dictionary = PvR.REWARD
	_hit("panel", Rect2(at * _f, AWARD_SIZE * _f), false)
	_fblit("pvr_rw", at + _v(spot.static ))
	_fbutton("rw:close", "public_button_close", at + _v(spot.close))
	var starts: Array = award_starts(_award_counts())
	if _time - _award_at >= float(starts[-1]):
		_fblit("pvr_rw_okbk", at + _v(spot.okbk))
		_fbutton("rw:ok", "pvr_rw_ok", at + _v(spot.ok))

func _tblit(target: CanvasItem, name: String, at: Vector2, wide: float = 0.0, high: float = 0.0, tint: Color = Color.WHITE, part: Rect2 = Rect2()) -> void :
	var cell: Array = _cells.get(name, [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Rect2 = Rect2(float(cell[1][0]), float(cell[1][1]), float(cell[1][2]), float(cell[1][3]))
	if part.size != Vector2.ZERO:
		region = Rect2(region.position + part.position, part.size)
	var shown: Vector2 = Vector2(wide if wide > 0.0 else region.size.x, high if high > 0.0 else region.size.y)
	target.draw_texture_rect_region(cell[0], Rect2(at * _f, shown * _f), region, tint)


func _ttext(target: CanvasItem, text: String, px: float, color: Color, align: String, x: float, middle: float, rim: Color = SHADE, edge: float = 1.0) -> void :
	var font: Font = ARIAL_BOLD
	var font_size: int = maxi(6, roundi(px * _f))
	var wide: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var origin: Vector2 = Vector2(x * _f, middle * _f)
	if align == "c":
		origin.x -= wide / 2.0
	elif align == "r":
		origin.x -= wide
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	if edge > 0.0:
		target.draw_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(edge * _f)), Color(rim, rim.a * color.a))
	target.draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)


func _tlabel(target: CanvasItem, label: Array, text: String, at: Vector2, alpha: float = 1.0) -> void :
	var px: float = float(label[4])
	_ttext(target, text, px, Color(Color(str(label[5])), alpha), str(label[7]), at.x + float(label[0]), at.y + float(label[1]) + 2.0 + px * 0.55)


func _draw_awards(target: Control) -> void :
	if not _award_open:
		return
	var t: float = _time - _award_at
	for row: Array in _award_layout(t)[0]:
		var top: float = float(row[2]) - _award_scroll
		if top > float(PvR.REWARD.list[3]) or top + float(row[3]) < 0.0:
			continue
		if str(row[0]) == "vip":
			_draw_award_vip(target, top)
		else:
			_draw_award_run(target, int(row[1]), top, float(row[3]), t - float(row[4]))

func _draw_award_run(target: Control, index: int, top: float, high: float, age: float) -> void :
	var alpha: float = clampf(age / SHOW_TIME, 0.0, 1.0)
	alpha *= alpha
	var white: Color = Color(1, 1, 1, alpha)
	if high <= float(PvR.RENDER.base):
		_tblit(target, "pvr_rr_bk", Vector2(0, top), 0.0, 0.0, white)
	else:
		_tblit(target, "pvr_rr_bk", Vector2(0, top), 569.0, 20.0, white, Rect2(0, 0, 569, 20))
		_tblit(target, "pvr_rr_bk", Vector2(0, top + 20.0), 569.0, high - 40.0, white, Rect2(0, 20, 569, 154))
		_tblit(target, "pvr_rr_bk", Vector2(0, top + high - 20.0), 569.0, 20.0, white, Rect2(0, 174, 569, 20))
	var spot: Dictionary = PvR.RENDER
	_tblit(target, "pvr_rr_head", Vector2(0, top) + _v(spot.head), 0.0, 0.0, white)
	var run: Dictionary = _award_runs[index]
	var texts: Dictionary = spot.texts
	var base: Vector2 = Vector2(0, top)
	_tlabel(target, texts.lblIndex, str(PvR.WORDS.index).replace("@num1@", str(index + 1)), base, alpha)
	if int(run.get("exp", 0)) > 0:
		_tlabel(target, texts.lblExp, "+%d" % int(run.exp), base, alpha)
	var coin: String = ""
	var amount: int = 0
	if int(run.get("golden", 0)) > 0:
		coin = "pvr_coin_gold"
		amount = int(run.golden)
	if int(run.get("gift", 0)) > 0:
		coin = "pvr_coin_gift"
		amount = int(run.gift)
	if not coin.is_empty():
		_tblit(target, coin, base + _v(spot.coin), 0.0, 0.0, white)
		_tlabel(target, texts.lblCoin, "+%d" % amount, base, alpha)
	var item: Array = spot.item
	var cells: Array = _award_cells[index]
	for k in range(cells.size()):
		var moved: float = age - SHOW_TIME - k * ITEM_GAP
		if moved < 0.0:
			continue
		var home: Vector2 = Vector2(float(item[0]) + (k % 6) * float(item[2]), float(item[1]) + (k / 6) * float(item[3]))
		var x: float = 569.0 + (home.x - 569.0) * bounce(moved / SHOW_TIME)
		_draw_award_cell(target, Vector2(x, top + home.y), cells[k])


func _draw_award_cell(target: Control, at: Vector2, cell: Array) -> void :
	var spot: Dictionary = PvR.AWARD
	_tblit(target, "pvr_aw_bg", at + _v(spot.bg))
	if str(cell[0]) == "honor":
		_tblit(target, "pvr_q1", at + _v(spot.quality))
		_tblit(target, "pvr_aw_honor", at + _v(spot.honor))
	else:
		var look: Array = _award_item(int(cell[1]))
		var quality: int = int(look[2])
		if quality >= 1 and quality <= 5:
			_tblit(target, "pvr_q%d" % quality, at + _v(spot.quality))
		var icon: Texture2D = pack.picture(str(look[1])) if not str(look[1]).is_empty() else null
		if icon != null:
			target.draw_texture_rect(icon, Rect2((at + _v(spot.icon)) * _f, Vector2(76, 76) * _f), false)
		var label: Array = spot.texts.lblRewardName
		var lines: Array = _wrap_name(str(look[0]), float(label[4]), float(label[2]))
		for j in range(lines.size()):
			var middle: float = at.y + float(label[1]) - (lines.size() - j) * NAME_LINE + NAME_LINE / 2.0
			_ttext(target, str(lines[j]), float(label[4]), Color.WHITE, "c", at.x + float(label[0]) + float(label[2]) / 2.0, middle, Color(str(spot.rim)), 1.0)
	if int(cell[2]) > 0:
		var number: Array = spot.texts.lblNum
		_ttext(target, str(int(cell[2])), float(number[4]), Color.WHITE, "c", at.x + float(number[0]) + float(number[2]) / 2.0, 
			at.y + float(number[1]) + 2.0 + float(number[4]) * 0.55, Color(str(spot.rim)), 1.0)


func _wrap_name(text: String, px: float, wide: float) -> Array:
	var font_size: int = maxi(6, roundi(px * _f))
	var limit: float = wide * _f
	var lines: Array = []
	var line: String = ""
	for word: String in text.split(" ", false):
		var next: String = word if line.is_empty() else line + " " + word
		if line.is_empty() or ARIAL_BOLD.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= limit:
			line = next
		else:
			lines.append(line)
			line = word
	if not line.is_empty():
		lines.append(line)
	if lines.size() > 2:
		var tail: String = " ".join(lines.slice(1))
		while tail.length() > 1 and ARIAL_BOLD.get_string_size(tail + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > limit:
			tail = tail.left(tail.length() - 1)
		lines = [lines[0], tail + "..."]
	return lines


func _award_item(id: int) -> Array:
	var row: Array = Pve.ITEMS.get(str(id), [])
	if row.size() >= 3:
		return [str(row[0]), str(row[1]), int(row[2])]
	var key: String = str(id)
	var more: Array = pack.bag.get("items", {}).get(key, [])
	if more.size() >= 6:
		var art: String = ("l/av/" if int(more[5]) == 4 else "l/it/") + str(more[2]) + ".webp" if not str(more[2]).is_empty() else ""
		return [BagModel.clean(str(more[0])), art, int(more[3])]
	var other: Array = pack.bag.get("more", {}).get(key, [])
	if other.size() >= 3:
		return [BagModel.clean(str(other[0])), "l/it/%s.webp" % other[1] if not str(other[1]).is_empty() else "", int(other[2])]
	return ["Vật phẩm %d" % id, "", 1]


func _draw_award_vip(target: Control, top: float) -> void :
	var spot: Dictionary = PvR.RENDER
	_tblit(target, "pvr_rr_vip", Vector2(0, top) + _v(spot.vip))
	var icon: String = str(PvR.VIP_ICONS.get(str(_award_vip), "pvr_vip12" if _award_vip == 12 else ""))
	if not icon.is_empty():
		_tblit(target, icon, Vector2(0, top) + _v(spot.vip_icon))
	var add: Array = PvR.VIP.get(str(_award_vip), [0, 0, 0])
	var texts: Dictionary = spot.vip_texts
	for pair: Array in [[texts.lblExpAdd, int(add[1])], [texts.lblMerAdd, int(add[2])], [texts.lblCoinAdd, int(add[0])]]:
		var label: Array = pair[0]
		_ttext(target, "+%d%%" % int(pair[1]), float(label[4]), Color(str(label[5])), "l", float(label[0]), top + float(label[1]))
