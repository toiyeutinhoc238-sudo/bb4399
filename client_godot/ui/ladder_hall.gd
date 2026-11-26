extends "hall_screen.gd"
const AppSession = preload("res://net/app_session.gd")






















const Quick = preload("quickmatch_atlas.gd")
const ActHall = preload("act_hall_atlas.gd")
const Ladder = preload("ladder_hall_atlas.gd")
const Reward = preload("ladder_reward_atlas.gd")
const Rule = preload("rule_atlas.gd")
const Rules = preload("ladder_rule_atlas.gd")
const ArenaUi = preload("arena.gd")

signal closed

const LADDER_ROOM: int = 9
const LADDER_ACT: int = 14
const TOP_SECTION: int = 17

const SECTION_NAMES: Array = ["Đồng I", "Đồng II", "Đồng III", "Bạc I", "Bạc II", "Bạc III", "Vàng I", "Vàng II", "Vàng III", 
	"Bạch Kim I", "Bạch Kim II", "Bạch Kim III", "Kim Cương I", "Kim Cương II", "Kim Cương III", "Kim Cương IV", "Chỉ Huy"]
const NO_SECTION: String = "Không Huy Chương"
const LEGEND: String = "Truyền Kỳ"
const ELO_SESSION: int = 13
const ZONE: int = 7 * 3600
const REWARD_SHADE: Color = Color(0, 0, 0, 0.4)
const POINT_HEAD: String = "Điểm Chiến Đấu: "
const POINT_UP: String = "  (Thắng 1 trận nữa sẽ lên bậc kế tiếp)"
const POINT_GOLD: Color = Color("fcff1a")
const NAME_TINT: Color = Color("cfecfb")
const NAME_RIM: Color = Color(0, 0, 0, 1)
const STATE_RIM: Color = Color(0.843, 0.275, 0.071, 0.8)
const TIME_GOLD: Color = Color("fcff00")
const TIME_RIM: Color = Color(0.0, 0.4, 0.682, 0.8)
const DAILY_RIM: Color = Color(0.004, 0.376, 0.718, 0.8)

const DAILY_LABELS: Array = [[-145, 242, 20], [11, 242, 20], [111, 80, 14], [111, 202, 14]]
const PAIR_TEXT2: String = "Dự kiến: @time@"
const WAIT_SPAN: int = 300
const SHOW_AT: int = 1800
const OPEN_TEXT: String = "Thời gian mở :"
const FRONT_TEXT: String = "Bắt đầu sau :"
const ACTING_TEXT: String = "Kết thúc sau :"
const TIP_96: String = "LV @num1@ mới được vào Guild"
const INFO: Color = Color("975317")

const ROOM_5: String = "    Tổ đội đủ 5 người vào Đấu Xếp Hạng, ghép với tổ đội 5 người khác. Bậc Xếp Hạng trong đội chênh nhau tối đa 9 bậc, cùng đội không thể chọn tank giống nhau."
const ROOM_3: String = "    Tổ đội tối đa 3 người vào Đấu Xếp Hạng, ưu tiên gặp tổ đội 3 người khác, chỗ còn lại ghép người chơi đơn. Bậc Xếp Hạng trong đội chênh nhau tối đa 6 bậc, cùng đội không thể chọn tank giống nhau."
const PARTY_5: String = "PHÒNG 5"
const PARTY_3: String = "PHÒNG 3"
const PARTY_RIM_ON: Color = Color("d8431a")
const PARTY_RIM_OFF: Color = Color("1f5fa8")
const NAME_TIP: String = "VIP3 trở lên được đặt tên room!"
const RULE_BG: Color = Color("1376ba")
const RULE_INK: Color = Color("bce0fe")
const RULE_RIM: Color = Color("005486")
const RULE_LINE: float = 5.0
const RULE_WHEEL: float = 15.0
const REPEAT_DELAY: float = 0.5
const REPEAT_STEP: float = 0.035

const PAIR_LOCKED: Array = ["quick", "create", "find", "back", "tab:act", "tab:pvp", "tab:league"]
const ACTS_PATH: String = "/xml/ActivityTemplate_table.xml"

var templates: Dictionary = {}
var _http: HTTPRequest
var _asking: bool = false
var _hints: Array = []
var _hints_for: int = -1
var _reward_open: bool = false
var now: Callable = Callable()
var _rule: int = 0
var _rule_top: float = 0.0
var _rule_bar: Array = []
var _rule_clip: Control
var _rule_grab: bool = false
var _rule_grab_at: Vector2 = Vector2.ZERO
var _rule_grab_top: float = 0.0
var _rep_id: String = ""
var _rep_next: float = 0.0
var _rep_skip: bool = false
var _sheet_id: String = ""
var _locked: bool = false
var _party: int = 3
var _name: LineEdit
var _code: LineEdit
var _id: LineEdit
var _key: LineEdit
var _focus: LineEdit

func _setup() -> void :
	super ()
	_add_parts(Ladder.PLACE)

	var hall: Array = _parts.get("hall", [])
	_parts["info"] = hall.filter( func(row: Array) -> bool: return str(row[3]).begins_with("ld_"))
	_parts["hall"] = hall.filter( func(row: Array) -> bool: return not str(row[3]).begins_with("ld_"))
	_rule_clip = Control.new()
	_rule_clip.clip_contents = true
	_rule_clip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rule_clip.visible = false
	_rule_clip.draw.connect(_draw_rule_text)
	add_child(_rule_clip)
	_name = _fedit(0)
	ArenaUi.flash_limit(_name, ArenaUi.NAME_CHARS)
	_code = _fedit(0, true)
	ArenaUi.flash_limit(_code, 6, ArenaUi.PASS_DIGITS)
	_id = _fedit(0, true)
	ArenaUi.flash_limit(_id, ArenaUi.ROOM_ID_CHARS)
	_key = _fedit(0, true)
	ArenaUi.flash_limit(_key, 6, ArenaUi.PASS_DIGITS)
	for edit: LineEdit in [_name, _code, _id, _key]:
		edit.text_submitted.connect( func(_text: String) -> void : _submit())
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		_asking = false
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			read_templates(body))

func _frames() -> Dictionary:
	return Ladder.FRAME

func _shown() -> void :
	_reset_list()
	_reward_open = false
	_close_rule()
	_close()
	if client != null and is_visible_in_tree() and templates.is_empty() and not _asking and _http != null and is_inside_tree():
		var url: String = client.config.origin + ACTS_PATH
		_asking = _http.request(url, AppSession.headers(url)) == OK

func _tick(_delta: float) -> void :
	_tick_rule()
	if client == null:
		return


	if client.state == "hall" and int(client.get("hall_type")) != LADDER_ROOM and client.has_method("ladder_tab"):
		client.call("ladder_tab")
	_tick_list()




func read_templates(body: PackedByteArray) -> bool:
	var parser: XMLParser = XMLParser.new()
	if parser.open_buffer(body) != OK:
		return false
	var rows: Dictionary = {}
	var row: Dictionary = {}
	var field: String = ""
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node: String = parser.get_node_name()
				if node == "entry":
					row = {}
				elif not parser.is_empty():
					field = node
			XMLParser.NODE_TEXT, XMLParser.NODE_CDATA:
				if not field.is_empty():
					row[field] = str(row.get(field, "")) + parser.get_node_data()
			XMLParser.NODE_ELEMENT_END:
				var node: String = parser.get_node_name()
				if node == "entry":
					var id: int = int(str(row.get("nId", "0")))
					if id > 0:
						rows[id] = {"type": int(str(row.get("nType", "0"))), "start": _plain(str(row.get("szStartTime", ""))).strip_edges()}
					row = {}
				elif node == field:
					field = ""
	if rows.is_empty():
		return false
	templates = rows
	for id: int in rows:
		client.act_types[id] = int(rows[id].type)
	return true

func _plain(text: String) -> String:
	if not "&" in text:
		return text
	return text.replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", "\"").replace("&apos;", "'").replace("&amp;", "&")


static func section_kind(section: int) -> String:
	if section >= TOP_SECTION:
		return "epic"
	if section >= 13:
		return "diamon"
	return ["bronze", "silver", "golden", "platnum"][clampi((section - 1) / 3, 0, 3)]


static func section_text(section: int) -> String:
	if section <= 0:
		return NO_SECTION
	return str(SECTION_NAMES[mini(section, TOP_SECTION) - 1])


static func section_score(section: int) -> int:
	return 1000 + 50 * (clampi(section, 1, TOP_SECTION) - 1)


static func point(section: int, elo: int) -> int:
	return (elo - section_score(section if section > 0 else 1)) * 2



static func point_parts(section: int, elo: int) -> Array:
	var value: int = maxi(0, point(section, elo))
	var top: bool = section >= TOP_SECTION
	if top:
		return [str(value), ""]
	return ["%d/100" % value, POINT_UP if value >= 100 else ""]


static func fill_width(value: int) -> float:
	var fill: Array = Ladder.INFO.fill
	return float(fill[clampi(value, 1, fill.size()) - 1])


func tip_state(now: int = -1) -> Array:
	var id: int = client.act_first([LADDER_ACT])
	if id == 0 or not client.acts.has(id):
		return ["", "", ""]
	if now < 0:
		now = int(Time.get_unix_time_from_system())
	var info: Array = client.acts[id]
	var to_start: int = int(info[0]) - now
	var to_end: int = int(info[0]) + int(info[1]) - now
	if to_end < 0:
		return ["over", "", ""]
	if to_start >= 0:
		if to_start > SHOW_AT:
			var start: String = str(templates.get(id, {}).get("start", ""))
			return ["start", OPEN_TEXT, start.substr(start.find(",") + 1) if start.contains(",") else start]
		return ["front", FRONT_TEXT, clock(to_start)]
	return ["acting", ACTING_TEXT, clock(to_end)]

static func clock(seconds: int) -> String:
	seconds = maxi(0, seconds)
	return "%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]

func _section() -> int:
	return int(client.call("ladder_section")) if client.has_method("ladder_section") else 0



func reward_open() -> bool:
	return _reward_open


static func reward_name(section: int) -> String:
	if section <= 0:
		section = 1
	if section <= TOP_SECTION:
		return str(SECTION_NAMES[section - 1])
	return LEGEND if section == TOP_SECTION + 1 else ""


func reward_end(unix: int) -> int:
	var stage: Dictionary = client.stages.get(ELO_SESSION, {}) if client != null else {}
	var next: int = int(stage.get("next", 0))
	if next > 0:
		return next
	var day: Dictionary = Time.get_datetime_dict_from_unix_time(unix + ZONE)
	var year: int = int(day.year)
	var month: int = int(day.month) + 1
	if month > 12:
		month = 1
		year += 1
	return Time.get_unix_time_from_datetime_dict({"year": year, "month": month, "day": 1, "hour": 0, "minute": 0, "second": 0}) - ZONE - 1


func reward_rows(unix: int = -1) -> Array:
	if unix < 0:
		unix = int(now.call()) if now.is_valid() else int(Time.get_unix_time_from_system())
	var day: Dictionary = Time.get_datetime_dict_from_unix_time(reward_end(unix) + ZONE)
	var date: String = "%d/%d/%d" % [int(day.day), int(day.month), int(day.year)]
	var pre: int = int(client.technologies[11]) if client.technologies.size() > 11 else 0
	return [_split(str(Reward.WORDS.end), "@time@", date), _split(str(Reward.WORDS.cur), "@name@", reward_name(_section())), 
		_split(str(Reward.WORDS.pre), "@name@", reward_name(pre))]

static func _split(text: String, mark: String, value: String) -> Array:
	var at: int = text.find(mark)
	return [text.substr(0, at), value, text.substr(at + mark.length())]



func _elo() -> int:
	var value: int = int(client.call("ladder_elo")) if client.has_method("ladder_elo") else 0
	if value <= 0:
		return section_score(maxi(1, _section()))
	return value




func rule_open() -> int:
	return _rule


func rule_content() -> float:
	return 3.0 * float(Rules.GAP) + 2.0 * float(Rules.LABEL_H) + _desc_high()


func rule_most() -> float:
	return maxf(0.0, rule_content() - float(Rules.VIEW[3]))

func rule_top() -> float:
	return _rule_top


func rule_link_shown() -> bool:
	var rule: Array = Rules.RULES.get(str(_rule), [])
	return rule.size() >= 4 and (int(rule[2]) > 0 or int(rule[3]) > 0)

func _rule_text(rule: Array) -> String:
	return str(rule[1]).replace("#ENTER#", "\n")


func _desc_high() -> float:
	var rule: Array = Rules.RULES.get(str(_rule), [])
	if rule.size() < 4:
		return 0.0
	var font_size: int = maxi(6, roundi(15.0 * _f))
	var lines: Vector2 = _face(ARIAL_BOLD).get_multiline_string_size(_rule_text(rule), HORIZONTAL_ALIGNMENT_LEFT, float(Rules.DESC_W) * _f, font_size)
	return lines.y / _f + 4.0

func _rule_frame() -> Vector2:
	return _centre(float(Rule.BOX[0]), float(Rule.BOX[1]))


func _rule_view() -> Rect2:
	var view: Array = Rules.VIEW
	return Rect2(_rule_frame() + _v(view), Vector2(float(view[2]), float(view[3])))

func _rule_scroll(value: float) -> void :
	_rule_top = clampf(roundf(value), 0.0, rule_most())

func _step_rule(id: String) -> void :
	_rule_scroll(_rule_top + (RULE_LINE if id == "rule:down" else - RULE_LINE))


func _tick_rule() -> void :
	if _rule_clip == null:
		return
	_rule_clip.visible = _rule > 0
	if _rule <= 0:
		return
	var view: Rect2 = _rule_view()
	_rule_clip.position = (view.position * _f).round()
	_rule_clip.size = (view.size * _f).round()
	_rule_scroll(_rule_top)
	_rule_clip.queue_redraw()
	if not _rep_id.is_empty():
		if _held and _press == _rep_id and _hit_at(get_local_mouse_position()) == _rep_id:
			if _time >= _rep_next:
				_step_rule(_rep_id)
				_rep_next = maxf(_rep_next + REPEAT_STEP, _time - REPEAT_STEP)
		else:
			_rep_id = ""

func _close_rule() -> void :
	_rule = 0
	_rule_top = 0.0
	_rule_bar = []
	_rule_grab = false
	_rep_id = ""
	_rep_skip = false
	if _rule_clip != null:
		_rule_clip.visible = false



func _rule_activate(id: String) -> void :
	match id:
		"rule:ok", "rule:close":
			_close_rule()
		"rule:link":
			var rule: Array = Rules.RULES.get(str(_rule), [])
			if rule.size() >= 4 and Rules.RULES.has(str(int(rule[3]))):
				_rule = int(rule[3])
				_rule_scroll(_rule_top)
		"rule:up", "rule:down":
			if _rep_skip:
				_rep_skip = false
			else:
				_step_rule(id)
		"rule:pgup":
			_rule_scroll(_rule_top - float(Rules.VIEW[3]))
		"rule:pgdn":
			_rule_scroll(_rule_top + float(Rules.VIEW[3]))



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(Hall.FILE, Hall.R)
		_use(Quick.FILE, Quick.R)
		_use(ActHall.FILE, ActHall.R)
		_use(Ladder.FILE, Ladder.R)
		_use(Reward.FILE, Reward.R)
		_use(Rule.FILE, Rule.R)
		_use(Rules.FILE, Rules.R)
	_scene()
	var frame: Vector2 = _at("hall")
	_frows(_parts.get("hall", []), frame)
	_draw_tip(frame)


	if not client.pairing.is_empty():
		_draw_waiting(frame)
	_frows(_parts.get("info", []), frame)
	_draw_info(frame)
	_frows(_parts.get("top", []), _at("top"))
	var side: Vector2 = _at("list")
	_frows(_parts.get("list", []), side)
	_draw_players(side)
	_draw_chat()
	_draw_menu()
	if not _viewing.is_empty():
		_draw_viewing()
	if _reward_open:
		_draw_reward()
	if _rule > 0:
		_draw_rule()
	match _sheet_id:
		"create":
			_draw_create()
		"find":
			_draw_find()
		_:
			_hide_edits()
	if _focus != null and _focus.visible:
		_focus.grab_focus.call_deferred()
		_focus.select_all.call_deferred()
		_focus = null


func _open(kind: String) -> void :
	if client.is_pairing():
		say(client.INVITE_PAIRING)
		return
	if kind == "create" and client.has_method("ladder_check"):
		var why: String = str(client.call("ladder_check"))
		if not why.is_empty():
			say(why)
			return
	_sheet_id = kind
	match kind:
		"create":
			ArenaUi.flash_text(_name, _default_name())
			_code.text = ""
			_locked = false
			_party = 3
			_focus = _name if _can_name() else null
		"find":
			_id.text = ""
			_key.text = ""
			_focus = _id

func _close() -> void :
	_sheet_id = ""
	_focus = null
	_hide_edits()


func sheet_open() -> String:
	return _sheet_id


func _can_name() -> bool:
	return _vip_level(int(client.character.get("vipPoints", 0))) >= 3


func _default_name() -> String:
	var who: String = str(client.character.get("name", client.account.get("name", ""))).strip_edges()
	return "Room của " + who if not who.is_empty() else "Room của tôi"



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
		_fwords(NAME_TIP, BOLD, 12.0, Color("ff9a0c"), "l", at + Vector2(127, 97), 320.0, 1.0)
	at += lift
	_fbutton("check", "public_checkbox_checked" if _locked else "public_checkbox_bk", at + Vector2(40, 125))
	_fblit("gameroom_createroom_password_t", at + Vector2(65, 128))
	_fblit("public_input_bk_m", at + Vector2(113, 122))
	_fput(_code, Rect2(at + Vector2(125, 124), Vector2(187, 30)), 20.0, "c", _locked)
	_fblit("gameroom_roomtype_bk", at + Vector2(23, 165))
	_fblit("gameroom_roomtype_bk", at + Vector2(23, 215))


	var five: bool = _party != 3
	_fblit("gameroom_roomtype_selected", at + Vector2(29, 171.0 if five else 221.0))
	_fwords(PARTY_5, BOLD, 17.0, Color.WHITE if five else Color("d6ecff") * _glow("type:random"), "c", at + Vector2(33, 171), 98.0, 2.0, 40.0, true, 
		PARTY_RIM_ON if five else PARTY_RIM_OFF)
	_hit("type:random", Rect2((at + Vector2(29, 171)) * _f, Vector2(140, 40) * _f), false)
	_fwords(PARTY_3, BOLD, 17.0, Color("d6ecff") * _glow("type:three") if five else Color.WHITE, "c", at + Vector2(33, 221), 98.0, 2.0, 40.0, true, 
		PARTY_RIM_OFF if five else PARTY_RIM_ON)
	_hit("type:three", Rect2((at + Vector2(29, 221)) * _f, Vector2(140, 40) * _f), false)
	_fblit("roomtype_info_bk", at + Vector2(175, 164))
	_fpara(ROOM_5 if five else ROOM_3, BOLD, 16.0, INFO, at + Vector2(185, 176), 250.0)
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


func _submit() -> void :
	if client.is_pairing():
		_close()
		say(client.INVITE_PAIRING)
		return
	var why: String = ""
	match _sheet_id:
		"create":
			var title: String = _name.text.strip_edges() if _can_name() else ""
			if title == _default_name():
				title = ""
			var code: int = _number(_code.text) if _locked else 0
			_close()
			why = client.ladder_create(title, code, _party)
		"find":
			var id: int = _number(_id.text)
			if id <= 0:
				say(client.LADDER_TIP_NO_ID)
				return
			var code: int = _number(_key.text)
			_close()
			why = client.ladder_join(id, code)
	if not why.is_empty():
		say(why)

func _sheet_activate(id: String) -> void :
	match id:
		"type:random":
			_party = 5
		"type:three":
			_party = 3
		"check":
			_locked = not _locked
			_code.text = ""
			if _locked:
				_focus = _code
		"ok":
			_submit()
		"cancel":
			_close()



func _draw_reward() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), REWARD_SHADE)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var box: Vector2 = Vector2(Reward.SIZE[0], Reward.SIZE[1])
	var at: Vector2 = _centre(box.x, box.y)
	_hit("panel", Rect2(at * _f, box * _f), false)
	_fblit("lw_bg", at)
	_fblit("lw_title", at + _v(Reward.TITLE))
	var px: float = float(Reward.PX)
	for kind: String in Reward.ORDER:
		_fblit("lw_medal_" + kind, at + _v(Reward.MEDALS[kind]))
	for label: Array in Reward.LABELS:
		_fwords(str(label[0]), ARIAL_BOLD, px, Color.WHITE, "c", at + Vector2(float(label[1]), float(label[2])), float(label[3]), 0.0, 0.0, true)
	var gold: Color = Color(str(Reward.GOLD))
	var rows: Array = reward_rows()
	var keys: Array = ["end", "cur", "pre"]
	for i: int in range(keys.size()):
		var field: Array = Reward.FIELDS[keys[i]]
		var spot: Vector2 = at + _v(field)
		var room: float = float(field[2])
		var parts: Array = rows[i]
		var x: float = _fwords(str(parts[0]), ARIAL_BOLD, px, Color.WHITE, "l", spot, room, 0.0, 0.0, false)
		x += _fwords(str(parts[1]), ARIAL_BOLD, px, gold, "l", spot + Vector2(x, 0), maxf(1.0, room - x), 0.0, 0.0, false)
		if not str(parts[2]).is_empty():
			_fwords(str(parts[2]), ARIAL_BOLD, px, Color.WHITE, "l", spot + Vector2(x, 0), maxf(1.0, room - x), 0.0, 0.0, false)
	var note: Array = Reward.FIELDS.note
	_fwords(str(Reward.NOTE), ARIAL_BOLD, px, Color.WHITE, "l", at + _v(note), float(note[2]), 0.0, 0.0, true)
	_fbutton("reward:close", "public_button_close", at + _v(Reward.CLOSE))



func _draw_rule() -> void :
	var box: Array = Rule.BOX
	var at: Vector2 = _window(float(box[0]), float(box[1]), "rule:close")
	var spot: Dictionary = Rule.AT
	var canvas: Array = spot["canvas"]
	_round(Rect2((at + _v(canvas)) * _f, Vector2(float(canvas[2]), float(canvas[3])) * _f), RULE_BG, 20.0)
	_fblit("rl_title", at + _v(spot["title"]))
	var view: Array = Rules.VIEW
	_draw_rule_bar(at + Vector2(float(view[0]) + float(view[2]) - float(Rules.BAR), float(view[1])), float(view[3]))
	if rule_link_shown():
		var link: Array = Rules.LINK
		_hit("rule:link", Rect2((at + _v(link)) * _f, Vector2(float(link[2]), float(link[3])) * _f), false)
	var ok: Vector2 = at + _v(spot["ok"])
	_fbutton("rule:ok", "public_button_window_green", ok)
	_fblit("title_title_confirm_green_t", ok + Vector2(40, 7), 0.0, 0.0, _glow("rule:ok"))



func _draw_rule_bar(at: Vector2, high: float) -> void :
	_rule_bar = []
	var most: float = rule_most()
	if most <= 0.0:
		return
	var bar: float = float(Rules.BAR)
	var track: float = high - 2.0 * bar
	_fblit("lu_sb_bk", at + Vector2(0, bar), bar, track)
	_fbutton("rule:up", "lu_sb_up", at)
	_fbutton("rule:down", "lu_sb_down", at + Vector2(0, bar + track))
	var thumb: float = maxf(20.0, track * high / (most + high))
	var y: float = at.y + bar + (track - thumb) * clampf(_rule_top / most, 0.0, 1.0)
	_hit("rule:pgup", Rect2(Vector2(at.x, at.y + bar) * _f, Vector2(bar, y - at.y - bar) * _f), false)
	_hit("rule:pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(bar, at.y + bar + track - y - thumb) * _f), false)
	_fslice("lu_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:rule"))
	_hit("slide:rule", Rect2(Vector2(at.x, y) * _f, Vector2(bar, thumb) * _f), false)
	_rule_bar = [track, thumb, most]




func _draw_rule_text() -> void :
	var rule: Array = Rules.RULES.get(str(_rule), [])
	if rule.size() < 4:
		return
	var c: Control = _rule_clip
	c.draw_set_transform( - c.position)
	var frame: Vector2 = _rule_frame()
	var o: Vector2 = frame + _v(Rules.VIEW) - Vector2(0, _rule_top)
	var wide: float = float(Rules.VIEW[2])
	var gap: float = float(Rules.GAP)
	_clip_label(str(rule[0]), o, wide)
	var desc: Vector2 = o + Vector2(0, float(Rules.LABEL_H) + gap)
	var font: Font = _face(ARIAL_BOLD)
	var font_size: int = maxi(6, roundi(15.0 * _f))
	var origin: Vector2 = Vector2(desc.x, desc.y + 2.0) * _f + Vector2(0, font.get_ascent(font_size))
	var text: String = _rule_text(rule)
	var room: float = float(Rules.DESC_W) * _f
	c.draw_multiline_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, room, font_size, -1, maxi(1, roundi(_f)), RULE_RIM)
	c.draw_multiline_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, room, font_size, -1, RULE_INK)
	if int(rule[2]) > 0:
		_clip_label(str(Rules.REWARD), desc + Vector2(0, _desc_high() + gap), wide)
	var cell: Array = _cells.get("lu_link", [])
	if rule_link_shown() and not cell.is_empty() and cell[0] != null:
		var region: Array = cell[1]
		var link: Array = Rules.LINK
		c.draw_texture_rect_region(cell[0], Rect2((frame + _v(link)) * _f, Vector2(float(link[2]), float(link[3])) * _f), 
			Rect2(region[0], region[1], region[2], region[3]), _glow("rule:link"))
	c.draw_set_transform(Vector2.ZERO)


func _clip_label(text: String, at: Vector2, wide: float) -> void :
	var font: Font = _face(ARIAL_BOLD)
	var font_size: int = maxi(6, roundi(18.0 * _f))
	var origin: Vector2 = Vector2(at.x, at.y + 2.0 + 18.0 * 0.55) * _f
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	_rule_clip.draw_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, wide * _f, font_size, maxi(1, roundi(1.5 * _f)), RULE_RIM)
	_rule_clip.draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, wide * _f, font_size, Color.WHITE)


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



func _draw_info(frame: Vector2) -> void :
	var section: int = _section()
	if section > 0:
		var kind: String = section_kind(section)
		_fblit("ld_frame_" + kind, frame + _v(Ladder.INFO.section))
		_fblit("ld_medal_" + kind, frame + _v(Ladder.INFO.medal[kind]))
	var texts: Dictionary = Ladder.INFO.texts
	var name_row: Array = texts.lblName
	_fwords(str(client.character.get("name", "")), ARIAL_BOLD, float(name_row[4]), NAME_TINT, "l", frame + _v(name_row), 320.0, 1.0, 0.0, true, 
		NAME_RIM)
	var section_row: Array = texts.lblSection
	_fwords(section_text(section), ARIAL_BOLD, float(section_row[4]), Color(str(section_row[5])), "l", frame + _v(section_row), 320.0, 1.0, 0.0, 
		true, NAME_RIM)
	var point_row: Array = texts.lblBattlePoint
	var px: float = float(point_row[4])
	var at: Vector2 = frame + _v(point_row)
	var parts: Array = point_parts(section, _elo())
	var head: float = _fwords(POINT_HEAD, ARIAL_BOLD, px, Color(str(point_row[5])), "l", at, 400.0, 0.0, 0.0, false)
	var number: float = _fwords(str(parts[0]), ARIAL_BOLD, px, POINT_GOLD, "l", at + Vector2(head, 0), 200.0, 0.0, 0.0, false)
	if not str(parts[1]).is_empty():
		_fwords(str(parts[1]), ARIAL_BOLD, px, Color(str(point_row[5])), "l", at + Vector2(head + number, 0), 400.0, 0.0, 0.0, false)
	var bar: Vector2 = frame + _v(Ladder.INFO.bar)
	_fblit("ld_bp_empty", bar)
	var wide: float = fill_width(point(section, _elo()))
	if wide > 0.0:
		_fpart("ld_bp_full", bar, Rect2(Vector2.ZERO, Vector2(wide, _cell_size("ld_bp_full").y)))


func _draw_tip(frame: Vector2) -> void :
	var state: Array = tip_state()
	if str(state[0]).is_empty():
		return
	var at: Vector2 = frame + _v(ActHall.TIP.at)
	var art: String = "front" if state[0] == "start" else str(state[0])
	_fblit("ah_tip_" + art, at + _v(ActHall.TIP.art[art]))
	if state[0] == "over":
		return
	var label: Array = ActHall.TIP.texts.lblActState
	_fwords(str(state[1]), ARIAL_BOLD, float(label[4]), Color(str(label[5])), "l", at + Vector2(float(label[0]), float(label[1]) - 10.0), 100.0, 1.0, 
		20.0, true, STATE_RIM)
	var count: Array = ActHall.TIP.texts.lblMatchCountdown
	_fwords(str(state[2]), ARIAL_BOLD, float(count[4]), Color(str(count[5])), "l", at + Vector2(float(count[0]), float(count[1]) - 10.0), 86.0, 0.0, 
		20.0, true)



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
		_fwords(str(daily_text[i]), BOLD, float(label[2]), Color.WHITE, "c", daily + Vector2(237.0 + float(label[0]) - 60.0, float(label[1])), 120.0, 1.5, 0.0, 
			true, DAILY_RIM)
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
	_fblit("gda_qm_cancel_t", broad + Vector2(59, 80) + ((_cell_size("gda_qm_btn") - _cell_size("gda_qm_cancel_t")) / 2.0).round())
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

func _v(pair: Variant) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))



func _activate(id: String) -> void :
	if _rule > 0:
		_rule_activate(id)
		return
	if not _sheet_id.is_empty():
		_sheet_activate(id)
		return
	if id.begins_with("qm:"):
		return
	if id == "match:cancel":
		client.stop_match()
		return
	if client.is_pairing() and id in PAIR_LOCKED:
		say(client.INVITE_PAIRING)
		return
	match id:
		"create", "find":
			_open(id)
		"reward":
			_reward_open = true
		"reward:close":
			_reward_open = false
		"rule":
			_rule = Rules.LADDER
			_rule_top = 0.0
		"quick":
			var why: String = client.ladder_match()
			if not why.is_empty():
				say(why)
		"watch":
			page_asked.emit("board")
		"tab:act":
			page_asked.emit("act")
		"tab:pvp":
			_to_arena()
		"tab:league":
			var need: int = client.TEAM_JOIN_LEVEL
			if int(client.character.get("level", 0)) < need:
				say(TIP_96.replace("@num1@", str(need)))
				return
			client.hall_tab(client.TEAM_ROOM)
			closed.emit()
		"back":
			client.back_to_lobby()
			closed.emit()
		_:
			_shared(id)


func _to_arena() -> void :
	client.hall_tab(2)
	closed.emit()


func chat_busy() -> bool:
	return not _sheet_id.is_empty() or _rule > 0 or _reward_open or super ()


func _escape() -> bool:
	if not _sheet_id.is_empty():
		_close()
		return true
	if _rule > 0:
		_close_rule()
		return true
	if _reward_open:
		_reward_open = false
		return true
	return super ()

func _wheel(step: int, at: Vector2) -> void :
	if _rule > 0:

		if _rule_view().has_point(at / _f):
			_rule_scroll(_rule_top + float(step) * RULE_WHEEL)
		return
	if not _sheet_id.is_empty() or not _viewing.is_empty() or _reward_open:
		return
	_wheel_list(step, at)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _rule > 0 and not _rule_grab and _rule_view().has_point(from / _f):
		_rule_scroll(_rule_top - moved.y / _f)

func _gui_input(event: InputEvent) -> void :
	if _rule > 0 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var id: String = _hit_at(event.position)

		if id in ["rule:up", "rule:down"]:
			_step_rule(id)
			_rep_id = id
			_rep_next = _time + REPEAT_DELAY
			_rep_skip = true
		elif id == "slide:rule" and not _rule_bar.is_empty():
			_rule_grab = true
			_rule_grab_at = event.position
			_rule_grab_top = _rule_top
	elif event is InputEventMouseMotion and _rule_grab:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT) or _rule_bar.is_empty():
			_rule_grab = false
		else:
			var step: float = maxf(0.001, (float(_rule_bar[0]) - float(_rule_bar[1])) / float(_rule_bar[2]))
			_rule_scroll(_rule_grab_top + (event.position.y - _rule_grab_at.y) / _f / step)
			accept_event()
			return
	super (event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_rep_id = ""
		_rep_skip = false
		_rule_grab = false

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		if client.is_pairing():
			say(client.INVITE_PAIRING)
			return
		_to_arena()
