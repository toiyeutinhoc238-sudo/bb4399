extends "hall_screen.gd"













const Quick = preload("quickmatch_atlas.gd")
const Ask = preload("exitask_atlas.gd")
const Clan = preload("guild_match_atlas.gd")
const GuildRule = preload("guild_rule_atlas.gd")
const RuleSheet = preload("guild_match_rule.gd")
const OpenUi = preload("open_ui_note.gd")
const RANDOM_MAP_ID: int = 0
const NAME_CHARS: int = 10
const PASS_DIGITS: String = "123456789"
const ROOM_ID_CHARS: int = 6
const PAGE_ROOMS: int = 8

const ROW_ART: Array = [["gameroom_roomlisttitle_wait_bk", "cf6a00", "gameroom_list_status_waitting_t"], 
	["gameroom_roomlisttitle_bk", "007b9a", "gameroom_list_status_running_t"], 
	["gameroom_roomlisttitle_pairing_bk", "666666", "gameroom_list_status_pairing_t"], 
	["gameroom_roomlisttitle_pairing_bk", "666666", "gameroom_list_status_waitting_disable_t"]]
const MODES: Dictionary = {"tab:act": "Vui Vẻ", "tab:ladder": "Đấu Xếp Hạng", "tab:league": "Giải Team"}
const INFO: Color = Color("975317")
const FREE_ROOM: String = "    Tạo room 10 người, có thể tự do chọn đội xanh đỏ và bản đồ tỷ thí, không phần thưởng."
const RANDOM_ROOM: String = "    Tạo room 5 người, tham gia đối chiến ngẫu nhiên."

const GIAIDAU_ROOM: String = "    Tạo room 10 người như đấu tự do, có thêm ô quan sát. Người quan sát xem được chọn xe, màn tải và trận đấu. Không phần thưởng."
const GIAIDAU_KIND: int = 20
const GIAIDAU_RIM: Color = Color("1d4f8c")
const GIAIDAU_RIM_ON: Color = Color("a8401f")


const GIAIDAU_XBOLD: Font = preload("res://assets/fonts/BeVietnamPro-ExtraBold.ttf")
const GIAIDAU_TEXT_AT: float = 77.0
const GIAIDAU_TEXT_WIDE: float = 52.0
var _giaidau_fv: FontVariation = null
const PAIR_TEXT2: String = "Dự kiến: @time@"
const WAIT_SPAN: int = 300
const TIME_GOLD: Color = Color("fcff00")
const TIME_RIM: Color = Color(0.0, 0.4, 0.682, 0.8)
const DAILY_RIM: Color = Color(0.004, 0.376, 0.718, 0.8)

const DAILY_LABELS: Array = [[-145, 242, 20], [11, 242, 20], [111, 80, 14], [111, 202, 14]]
const PAIR_LOCKED: Array = ["create", "find", "back"]

const TIP_68: String = "Chỉ vào phòng của team mình"
const TIP_69: String = "Vào Team trước rồi tham gia giải đấu Team"
const TIP_70: String = "Vào Team trước rồi tham gia giải đấu"
const TIP_96: String = "LV @num1@ mới được vào Guild"
const TIP_353: String = "HĐ chưa mở"
const TIP_355: String = "Guild chưa mở, hãy làm xong NV PB Chính"
const ACT_TIME: String = "Thời gian:"
const ACT_OFF: String = "Chưa mở"
const CLAN_MODE: String = "Giải Team"
const GUILD_FLAG: int = 268435456
const WATCH_ASK: String = "Có vào @name@ xem không?"
const ROPT_LOOK_SCENE: int = 6
const ASK_DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const ASK_LINE: float = 18.0
const ASK_GUTTER: float = 2.0

const CLAN_HIDE: Array = ["gameroom_sort_title_arena_selected_t", "gameroom_sort_title_teamcompetition_t", "gameroom_quickplay_bk_4"]
const CLAN_HIDE_IDS: Array = ["quick", "create", "find"]

var _page: int = 0
var _sheet_id: String = ""
var _kind: int = 2
var _sheet_box: Rect2 = Rect2()
var _target: int = 0
var _watch: Dictionary = {}
var _locked: bool = false
var _name: LineEdit
var _code: LineEdit
var _id: LineEdit
var _key: LineEdit
var _pass: LineEdit
var _focus: LineEdit
var _hints: Array = []
var _hints_for: int = -1

func chat_busy() -> bool:
	return not _sheet_id.is_empty() or super ()

func _setup() -> void :
	super ()
	_add_parts(Atlas.PLACE)
	_name = _fedit(0)
	flash_limit(_name, NAME_CHARS)
	_code = _fedit(0, true)
	flash_limit(_code, 6, PASS_DIGITS)
	_id = _fedit(0, true)
	flash_limit(_id, ROOM_ID_CHARS)
	_key = _fedit(0, true)
	flash_limit(_key, 6, PASS_DIGITS)
	_pass = _fedit(6, true)
	for edit: LineEdit in [_name, _code, _id, _key, _pass]:
		edit.text_submitted.connect( func(_text: String) -> void : _submit())
	client.room_password_asked.connect( func(room_id: int, kind: int) -> void :
		if is_visible_in_tree() and kind not in [3, 4] and room_id > 0:
			_open("pass", room_id))
	var guide_view: Control = preload("guide_view.gd").new()
	guide_view.setup(self, "arena")
	add_child(guide_view)

func _shown() -> void :
	_close()
	_page = 0
	_reset_list()


func open_create() -> void :
	_open("create")

func _open(kind: String, target: int = 0) -> void :
	if client.is_pairing():
		say(client.INVITE_PAIRING)
		return
	_sheet_id = kind
	_target = target
	match kind:
		"create":
			flash_text(_name, _default_name())
			_code.text = ""
			_locked = false
			_kind = 2
			_focus = _name if _can_name() else null
		"find":
			_id.text = ""
			_key.text = ""
			_focus = _id
		"pass":
			_pass.text = ""
			_focus = _pass

func _close() -> void :
	_sheet_id = ""
	_watch = {}
	_focus = null
	_hide_edits()


func _can_name() -> bool:
	return _vip_level(int(client.character.get("vipPoints", 0))) >= 3


func _default_name() -> String:
	var who: String = str(client.character.get("name", client.account.get("name", ""))).strip_edges()
	return "Room của " + who if not who.is_empty() else "Room của tôi"




static func flash_limit(edit: LineEdit, limit: int, allowed: String = "") -> void :
	edit.set_meta("flash_prev", edit.text)
	edit.text_changed.connect( func(_value: String) -> void :
		var value: String = edit.text
		var clean: String = value
		if not allowed.is_empty():
			clean = ""
			for i in range(value.length()):
				if allowed.contains(value[i]):
					clean += value[i]
		var kept: String = max_chars(str(edit.get_meta("flash_prev", "")), clean, limit)
		if kept != value:
			var caret: int = edit.caret_column - (value.length() - kept.length())
			edit.text = kept
			edit.caret_column = clampi(caret, 0, kept.length())
		edit.set_meta("flash_prev", kept))


static func flash_text(edit: LineEdit, text: String) -> void :
	edit.text = text
	edit.set_meta("flash_prev", text)


static func max_chars(prev: String, value: String, limit: int) -> String:
	if limit <= 0 or value.length() <= limit:
		return value
	var head: int = 0
	while head < prev.length() and head < value.length() and prev[head] == value[head]:
		head += 1
	var tail: int = 0
	while tail < prev.length() - head and tail < value.length() - head\
	and prev[prev.length() - 1 - tail] == value[value.length() - 1 - tail]:
		tail += 1
	var added: String = value.substr(head, value.length() - head - tail)
	return value.left(head) + added.left(maxi(0, limit - head - tail)) + value.right(tail)


static func row_state(room: Dictionary) -> int:
	var phase: int = int(room.get("m_state", 1))
	if phase == 3:
		return 1
	if phase == 2:
		return 2
	return 3 if int(room.get("m_nNum", 0)) >= maxi(1, int(room.get("m_nMax", 10))) else 0


static func mode_text(room: Dictionary) -> String:
	if int(room.get("m_type", 0)) == 1:
		return "Giải đấu" if int(room.get("m_mode", 0)) == GIAIDAU_KIND else "Tự do"
	if int(room.get("m_type", 0)) == 5:
		return CLAN_MODE
	var mode: String = map_mode(int(room.get("m_mapId", 0)))
	return (mode if not mode.is_empty() else "Ngẫu nhiên") + " Sắp xếp"

static func page_count(total: int) -> int:
	return maxi(1, ceili(total / float(PAGE_ROOMS)))



static func sort_rooms(rooms: Array) -> Array:
	var groups: Array = [[], [], []]
	for room: Dictionary in rooms:
		var scene: bool = bool(room.get("scene", false))
		groups[1 if scene else 0 if int(room.get("m_state", 1)) == 1 else 2].append(room)
	return groups[0] + groups[1] + groups[2]

func _rooms() -> Array:
	var out: Array = []
	var clan: bool = _clan()
	for room: Dictionary in client.room_state.rooms.values():
		if clan and int(room.get("m_type", 0)) != client.TEAM_ROOM:
			continue
		out.append(room)
	return sort_rooms(out)

func _turn(step: int) -> void :
	_page = clampi(_page + step, 0, page_count(_rooms().size()) - 1)


func _clan() -> bool:
	return client != null and client.hall_type == client.TEAM_ROOM


func _row_kind(room: Dictionary) -> int:
	var kind: int = row_state(room)
	if kind == 0 and int(room.get("m_type", 0)) == client.TEAM_ROOM and client.guild_self_team != 0 and not client.team_row_mine(room):
		return 3
	return kind

func _tick(_delta: float) -> void :
	_turn(0)
	_tick_list()

func _wheel(step: int, at: Vector2) -> void :
	if not _sheet_id.is_empty() or not _viewing.is_empty() or _wheel_list(step, at):
		return
	if client.pairing.is_empty() and Rect2((_at("hall") + Vector2(21, 109)) * _f, Vector2(781, 290) * _f).has_point(at):
		_turn(step)



func _paint() -> void :
	_sheet_box = Rect2()
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(Hall.FILE, Hall.R)
		_use(Quick.FILE, Quick.R)
		_use(Clan.FILE, Clan.R)
		_use(GuildRule.FILE, GuildRule.R)
		_use(Ask.FILE, Ask.R)
	_scene()
	var frame: Vector2 = _at("hall")
	_frows(_hall_rows(), frame)
	if _clan():
		_draw_clan(frame)
	_draw_rooms(frame)
	if not client.pairing.is_empty():
		_draw_waiting(frame)
	var side: Vector2 = _at("list")
	_frows(_parts.get("list", []), side)
	_draw_players(side)
	_draw_chat()
	_draw_menu()
	match _sheet_id:
		"create":
			_draw_create()
		"find":
			_draw_find()
		"pass":
			_draw_pass()
		"rule":
			_hide_edits()
			_draw_rule()
		"watch":
			_hide_edits()
			_draw_watch()
		_:
			_hide_edits()
			if not _viewing.is_empty():
				_draw_viewing()
	if _focus != null and _focus.visible:
		_focus.grab_focus.call_deferred()
		_focus.select_all.call_deferred()
		_focus = null


func _draw_rooms(frame: Vector2) -> void :
	var rooms: Array = _rooms()
	for slot in range(clampi(rooms.size() - _page * PAGE_ROOMS, 0, PAGE_ROOMS)):
		var room: Dictionary = rooms[_page * PAGE_ROOMS + slot]
		var number: int = int(room.get("m_nRoomId", 0))
		var at: Vector2 = frame + Vector2(26, 114 + 36 * slot)
		var kind: int = _row_kind(room)
		var art: Array = ROW_ART[kind]
		var id: String = "room:%d" % number
		var rect: Rect2 = _fblit(str(art[0]), at, 0.0, 0.0, _glow(id))
		_hit(id, rect, false)
		var rim: Color = Color(str(art[1]), 0.8)
		_fwords(str(number), BOLD, 13.0, Color.WHITE, "c", at + Vector2(3, 3), 110.0, 1.5, 0.0, true, rim)
		if int(room.get("m_isValidate", 0)) != 0:
			_fblit("gameroom_roomtip_lock", at + Vector2(121, 4))
		_fwords(str(room.get("m_szName", "")), BOLD, 13.0, Color.WHITE, "c", at + Vector2(144, 3), 171.0, 1.5, 0.0, true, rim)
		_fwords(mode_text(room), BOLD, 13.0, Color.WHITE, "c", at + Vector2(323, 3), 60.0, 1.5, 0.0, true, rim)
		var map_id: int = int(room.get("m_mapId", 0))
		_fwords(map_title(map_id) if map_id > 0 else "Bản đồ ngẫu nhiên", BOLD, 13.0, Color.WHITE, "c", at + Vector2(391, 3), 120.0, 1.5, 0.0, true, rim)
		_fwords("%d/%d" % [int(room.get("m_nNum", 0)), int(room.get("m_nMax", 10))], BOLD, 13.0, Color.WHITE, "c", at + Vector2(523, 3), 60.0, 1.5, 0.0, true, rim)
		_fblit(str(art[2]), at + Vector2(roundf((771.0 - _cell_size(str(art[2])).x) / 2.0) + 259.0, 2))
		if kind == 0:
			_fbutton("join:%d" % number, "roomlist_btn_join_t", at + Vector2(719, 2))
		elif kind == 1 and int(room.get("m_isLookerMax", 0)) == 0:
			_fblit("roomlist_btn_watch_t", at + Vector2(719, 2))


func _hall_rows() -> Array:
	var rows: Array = _parts.get("hall", [])
	if not _clan():
		return rows
	var out: Array = []
	for row: Array in rows:
		var art: String = str(row[3])
		if art in CLAN_HIDE or str(row[4]) in CLAN_HIDE_IDS or (art == "gameroom_sort_selected" and int(row[1]) == 135):
			continue
		out.append(row)
	return out


func _draw_clan(frame: Vector2) -> void :
	_fblit("gameroom_sort_selected", frame + Vector2(361, 51))
	_fblit("gameroom_sort_title_teamcompetition_selected_t", frame + Vector2(366, 51))
	_fblit("gameroom_sort_title_arena_t", frame + Vector2(167, 60), 0.0, 0.0, _glow("tab:arena"))
	_hit("tab:arena", Rect2((frame + Vector2(135, 51)) * _f, Vector2(109, 39) * _f), false)
	_fblit("gameroom_quickplay_bk", frame + Vector2(501, 451))
	_fbutton("clan:enter", "gameroom_button_red_m", frame + Vector2(513, 464))
	_fblit("clan_button_ico_goleague_t", frame + Vector2(532, 465), 0.0, 0.0, _glow("clan:enter"))
	_fbutton("clan:rule", "gameroom_button_orange_ss", frame + Vector2(725, 464))
	_fblit("gameroom_ico_mark", frame + Vector2(738, 473), 0.0, 0.0, _glow("clan:rule"))
	_fwords(act_time(client.acts.get(client.team_act(), [])), ARIAL_BOLD, 14.0, Color.WHITE, "c", frame + Vector2(492, 524), 300.0)


static func act_time(info: Variant) -> String:
	if not (info is Array and (info as Array).size() >= 2) or int(info[1]) == 0:
		return ACT_TIME + ACT_OFF
	var start: int = int(info[0])
	return ACT_TIME + _hhmm(start) + " - " + _hhmm(start + int(info[1]))

static func _hhmm(unix: int) -> String:
	var local: int = posmod(unix + 7 * 3600, 86400)
	return "%02d:%02d" % [floori(local / 3600.0), floori((local % 3600) / 60.0)]


func _draw_rule() -> void :
	RuleSheet.draw(self)




func _draw_waiting(frame: Vector2) -> void :
	var w: Vector2 = frame + Vector2(18, 92)
	var bk: Vector2 = w + Vector2(0, -43)
	_fblit("gda_qm_bk", bk)
	_fblit("gameroom_pvpReadyRoom1000x600_shadow", bk)

	_hit("qm:block", Rect2(bk * _f, Vector2(794, 354) * _f), false)
	_hit("qm:block", Rect2((bk + Vector2(456, 354)) * _f, Vector2(338, 158) * _f), false)
	var daily: Vector2 = w + Vector2(7, 4)
	_fblit("gda_qm_daily_t", daily + Vector2(5, 8))
	var daily_text: Array = client.daily_progress()
	for i in range(DAILY_LABELS.size()):
		var label: Array = DAILY_LABELS[i]
		_fwords(str(daily_text[i]), BOLD, float(label[2]), Color.WHITE, "c", daily + Vector2(237.0 + float(label[0]) - 60.0, float(label[1])), 120.0, 1.5, 0.0, true, DAILY_RIM)
	_pick_hints()
	var tips: Array = [w + Vector2(491, 13), w + Vector2(491, 159)]
	for i in range(mini(tips.size(), _hints.size())):
		var tip: Vector2 = tips[i]
		_fblit("gda_qm_tip_bk", tip + Vector2(-5, -8) * 0.95, 295.0 * 0.95, 158.0 * 0.95)
		var art: Texture2D = pack.picture("l/gda/hint/%s.webp" % str(_hints[i])) if pack != null else null
		if art != null:
			draw_texture_rect(art, Rect2(tip * _f, Vector2(280, 140) * 0.95 * _f), false)
	var broad: Vector2 = w + Vector2(475, 311)
	_fmid("gda_qm_wait_t", broad + Vector2(0, 14), 298.0)
	var since: int = int(client.pairing.get("since", Time.get_ticks_msec()))
	var spent: int = maxi(0, floori((Time.get_ticks_msec() - since) / 1000.0))
	_fwords(_clock_text(spent), BOLD, 22.0, TIME_GOLD, "c", broad + Vector2(0, 40), 298.0, 2.0, 0.0, true, TIME_RIM)
	var button: Rect2 = _fblit("gda_qm_btn", broad + Vector2(59, 80), 0.0, 0.0, _glow("match:cancel"))
	_hit("match:cancel", button, false)
	var label_size: Vector2 = _cell_size("gda_qm_cancel_t")
	var btn_size: Vector2 = _cell_size("gda_qm_btn")
	_fblit("gda_qm_cancel_t", broad + Vector2(59, 80) + ((btn_size - label_size) / 2.0).round())
	var avg: int = int(client.pairing.get("avg", 0))
	if avg <= 0 or avg > WAIT_SPAN:
		avg = WAIT_SPAN
	_fwords(PAIR_TEXT2.replace("@time@", _clock_text(avg)), BOLD, 14.0, Color.WHITE, "c", broad + Vector2(0, 127), 298.0, 1.5, 0.0, true, TIME_RIM)


func _pick_hints() -> void :
	var since: int = int(client.pairing.get("since", 0))
	if since == _hints_for and not _hints.is_empty():
		return
	_hints_for = since
	var pool: Array = Quick.HINTS.duplicate()
	pool.shuffle()
	_hints = pool.slice(0, 2)

func _clock_text(seconds: int) -> String:
	return "%02d:%02d" % [floori(seconds / 60.0), seconds % 60]


func _draw_create() -> void :
	var named: bool = _can_name()
	var high: float = 464.0 if named else 484.0
	var lift: Vector2 = Vector2(0, -20.0 if named else 0.0)
	var at: Vector2 = _window(472.0, high)
	_fmid("title_createroom_t", at + Vector2(0, 19), 472.0)
	_fblit("gameroom_createroom_roomname_t", at + Vector2(52, 66))
	_fblit("public_input_bk_l", at + Vector2(113, 61))
	_fput(_name, Rect2(at + Vector2(128, 61), Vector2(300, 35)), 16.0, "l", named)
	if not named:
		_fwords("VIP3 trở lên được đặt tên room!", BOLD, 12.0, Color("ff9a0c"), "l", at + Vector2(127, 97), 320.0, 1.0)
	at += lift
	_fbutton("check", "public_checkbox_checked" if _locked else "public_checkbox_bk", at + Vector2(40, 125))
	_fblit("gameroom_createroom_password_t", at + Vector2(65, 128))
	_fblit("public_input_bk_m", at + Vector2(113, 122))
	_fput(_code, Rect2(at + Vector2(125, 124), Vector2(187, 30)), 20.0, "c", _locked)
	_fblit("gameroom_roomtype_bk", at + Vector2(23, 165))
	_fblit("gameroom_roomtype_bk", at + Vector2(23, 215))

	var random: bool = _kind == 2
	if random:
		_fblit("gameroom_roomtype_selected", at + Vector2(29, 171))
		_fblit("gameroom_roomtype_random_selected_t", at + Vector2(49, 177))
	else:
		_fblit("gameroom_roomtype_random_t", at + Vector2(49, 177), 0.0, 0.0, _glow("type:random"))
	_hit("type:random", Rect2((at + Vector2(29, 171)) * _f, Vector2(140, 40) * _f), false)
	var cup: bool = _kind == GIAIDAU_KIND
	if random or cup:
		_fblit("gameroom_roomtype_freedom_t", at + Vector2(34, 225), 0.0, 0.0, _glow("type:free"))
	else:
		_fblit("gameroom_roomtype_selected", at + Vector2(29, 221))
		_fblit("gameroom_roomtype_freedom_selected_t", at + Vector2(34, 225))
	_hit("type:free", Rect2((at + Vector2(29, 221)) * _f, Vector2(140, 40) * _f), false)

	_fblit("gameroom_roomtype_bk", at + Vector2(23, 265))
	if cup:
		_fblit("gameroom_roomtype_selected", at + Vector2(29, 271))
	_fpart("gameroom_roomtype_freedom_selected_t" if cup else "gameroom_roomtype_freedom_t", at + Vector2(34, 275), Rect2(0, 0, 32, 32), Color.WHITE if cup else _glow("type:giaidau"))
	_giaidau_art("GIẢI ĐẤU", 10.0, Color.WHITE if cup else _glow("type:giaidau"), at + Vector2(GIAIDAU_TEXT_AT, 275), GIAIDAU_TEXT_WIDE, 32.0, 3.0, GIAIDAU_RIM_ON if cup else GIAIDAU_RIM)
	_hit("type:giaidau", Rect2((at + Vector2(29, 271)) * _f, Vector2(140, 40) * _f), false)
	_fblit("roomtype_info_bk", at + Vector2(175, 164))
	_fpara(RANDOM_ROOM if random else (GIAIDAU_ROOM if cup else FREE_ROOM), BOLD, 16.0, INFO, at + Vector2(185, 176), 250.0)
	_confirm(at - lift, 472.0, high, "gameroom_word_createroom_t")


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
	_fwords("Nhập mật mã của room muốn vào", BOLD, 13.0, Color.WHITE, "c", at + Vector2(24, 77), 310.0, 1.5, 21.0, true, TITLE_RIM)
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
	return WATCH_ASK.replace("@name@", str(_watch.get("m_szName", "")))


func watch_lines() -> Array:
	var spec: Array = Ask.TEXTS["txtContent"]
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(float(spec[4]) * _f))
	var limit: float = (float(spec[2]) - ASK_GUTTER * 2.0) * _f
	var out: Array = []
	var line: String = ""
	for word: String in watch_text().split(" "):
		var next: String = word if line.is_empty() else line + " " + word
		if not line.is_empty() and font.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > limit:
			out.append(line)
			line = word
		else:
			line = next
	out.append(line)
	return out




func _ask_watch(room: Dictionary) -> void :
	if _sheet_id == "watch":
		return
	_close()
	_sheet_id = "watch"
	_watch = room.duplicate()



func _confirm_watch() -> void :
	var room: Dictionary = _watch
	_close()
	var id: int = int(room.get("m_nRoomId", 0))
	if id <= 0:
		return
	if bool(room.get("scene", false)):
		var why: String = client.look_scene(id)
		client._look_oid = 0
		if not why.is_empty():
			say(why)
	else:
		client._look_oid = 0
		client.room_op(ROPT_LOOK_SCENE, id)

func _escape() -> bool:
	if _sheet_id.is_empty():
		return super ()
	_close()
	return true

func _join(id: int, code: int = 0) -> void :
	var room: Dictionary = client.room_state.rooms.get(id, {})
	if room.is_empty():
		return
	if int(room.get("m_type", 0)) == client.TEAM_ROOM:
		_join_team(room)
		return

	match row_state(room):
		1:
			_ask_watch(room)
		2:
			say("Room đã bắt đầu sắp xếp, không thể vào")
		3:
			if _giaidau_full(id) and int(room.get("m_isValidate", 0)) != 0 and code <= 0:
				_open("pass", id)
			elif _giaidau_full(id):
				client.join_room(id, code, true)
			else:
				say("Số người trong room đã đầy, không thể vào")
		_:
			if int(room.get("m_isValidate", 0)) != 0 and code <= 0:
				_open("pass", id)
			else:
				client.join_room(id, code)


func _giaidau_full(id: int) -> bool:
	var room: Dictionary = client.room_state.rooms.get(id, {})
	return int(room.get("m_type", 0)) == 1 and int(room.get("m_mode", 0)) == GIAIDAU_KIND and row_state(room) == 3



func _giaidau_art(text: String, px: float, color: Color, at: Vector2, wide: float, high: float, edge: float, rim: Color) -> void :
	if _giaidau_fv == null:
		_giaidau_fv = FontVariation.new()
		_giaidau_fv.base_font = GIAIDAU_XBOLD
		_giaidau_fv.variation_embolden = 1.1
		_giaidau_fv.spacing_glyph = 1
	var font: Font = _giaidau_fv
	var size_px: int = maxi(6, roundi(px * _f))
	while size_px > 6 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > wide * _f:
		size_px -= 1
	var origin: Vector2 = Vector2(at.x, at.y + high / 2.0) * _f
	origin.y += (font.get_ascent(size_px) - font.get_descent(size_px)) / 2.0
	draw_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, size_px, maxi(2, roundi(edge * _f)), Color(rim, rim.a * color.a))
	draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, size_px, color)



func _join_team(room: Dictionary) -> void :
	if client.team_row_mine(room):
		var why: String = client.team_match_join(int(room.get("m_nRoomId", 0)))
		if not why.is_empty():
			say(why)
		return
	match int(room.get("m_state", 1)):
		3:
			_ask_watch(room)
		2:
			pass
		_:
			say(TIP_68)


func _to_clan() -> void :
	var need: int = client.TEAM_JOIN_LEVEL
	if int(client.character.get("level", 0)) < need:
		say(TIP_96.replace("@num1@", str(need)))
		return
	_page = 0
	client.hall_tab(client.TEAM_ROOM)



func _enter_clan() -> void :
	if not client.team_act_open():
		say(TIP_353)
		return
	if not client.guild.is_empty():
		var why: String = client.team_match_join(0)
		if not why.is_empty():
			say(why)
		return
	if (int(client.character.get("actionFlag", 0)) & GUILD_FLAG) == 0:
		say(TIP_355)
		return
	page_asked.emit("guild")
	client.noticed.emit(TIP_69)




func _league_click() -> void :
	if not client.guild.is_empty():
		var why: String = client.league_queue()
		if not why.is_empty():
			say(why)
		return
	if (int(client.character.get("actionFlag", 0)) & GUILD_FLAG) == 0:
		say(TIP_355)
		return
	page_asked.emit("guild")
	client.noticed.emit(TIP_70)



func _quick() -> void :
	var why: String = client.quick_match()
	if not why.is_empty():
		say(why)

func _submit() -> void :
	if client.is_pairing():
		_close()
		say(client.INVITE_PAIRING)
		return
	match _sheet_id:
		"create":
			var title: String = _name.text.strip_edges() if _can_name() else ""
			if title == _default_name():
				title = ""
			var code: int = _number(_code.text) if _locked else 0
			_close()
			if _kind == GIAIDAU_KIND:
				client.create_room(title, code, 1, RANDOM_MAP_ID, GIAIDAU_KIND)
			else:
				client.create_room(title, code, _kind, RANDOM_MAP_ID)
		"find":
			var id: int = _number(_id.text)
			if id <= 0:
				say("Nhập số room")
			elif not client.room_state.rooms.has(id):
				say("Không thấy room %d. Thử lại sau khi làm mới." % id)
				client.refresh_rooms()
			else:
				var code: int = _number(_key.text)
				_close()
				_join(id, code)
		"pass":
			var code: int = _number(_pass.text)
			if code <= 0:
				say("Nhập mật mã của room muốn vào")
			else:
				var id: int = _target
				_close()
				client.join_room(id, code, _giaidau_full(id))

func _activate(id: String) -> void :
	if id.begins_with("qm:"):
		return
	if id == "match:cancel":
		client.stop_match()
		return
	if _sheet_id == "watch":
		if id == "ask:ok":
			_confirm_watch()
		elif id == "ask:no":
			_close()
		return
	if client.is_pairing() and (id in PAIR_LOCKED or id == "quick" or id == "tab:arena" or id.begins_with("room:") or id.begins_with("join:") or MODES.has(id)):
		say(client.INVITE_PAIRING)
		return
	if id.begins_with("room:") or id.begins_with("join:"):
		_join(int(id.substr(5)))
		return
	if id == "tab:act":
		page_asked.emit("act")
		return
	if id == "tab:league":
		_to_clan()
		return
	if id == "tab:ladder":
		OpenUi.note(client, pack, OpenUi.UI_LADDER)
		page_asked.emit("ladder")
		return
	match id:
		"page:prev":
			_turn(-1)
		"page:next":
			_turn(1)
		"back":
			client.back_to_lobby()
		"create":
			_open("create")
		"find":
			_open("find")
		"quick":
			_quick()
		"tab:arena":
			_page = 0
			client.hall_tab(2)
		"clan:enter":
			_enter_clan()
		"clan:rule":
			_sheet_id = "rule"
		"rule_go":
			_close()
			_league_click()
		"check":
			_locked = not _locked
			if _locked:
				_focus = _code
			else:
				_code.text = ""
		"type:random":
			_kind = 2
		"type:free":
			_kind = 1
		"type:giaidau":
			_kind = GIAIDAU_KIND
		"ok":
			_submit()
		"cancel":
			_escape()
		_:
			_shared(id)


func _window(wide: float, high: float, close: String = "cancel", dim: float = 0.35) -> Vector2:
	var at: Vector2 = super (wide, high, close, dim)
	_sheet_box = Rect2(at * _f, Vector2(wide, high) * _f)
	return at


func _draw_toast() -> void :
	if _sheet_id.is_empty() or not _sheet_box.has_area():
		super ()
		return
	var age: float = _time - _toast_at
	if _toast.is_empty() or age > 2.6:
		return
	var alpha: float = clampf(minf(age / 0.15, (2.6 - age) / 0.4), 0.0, 1.0)
	_round(toast_rect(), Color("06203f", 0.92 * alpha), 22.0, Color("6fd0ff", 0.6 * alpha), 2.0)
	_fstring(_toast, SEMI, 32, Color(Color.WHITE, alpha), "c", toast_rect().get_center(), toast_rect().size.x)

func toast_rect() -> Rect2:
	var font_size: int = maxi(6, roundi(32 * _u))
	var width: float = ARIAL_BOLD.get_string_size(_toast, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 96.0 * _u
	var high: float = 88.0 * _u
	var gap: float = 8.0 * _u
	var y: float = _sheet_box.end.y + gap
	if y + high > size.y:
		y = _sheet_box.position.y - gap - high
		if y < 0.0:
			y = maxf(0.0, size.y - high - gap)
	return Rect2(Vector2((size.x - width) / 2.0, y), Vector2(width, high))
