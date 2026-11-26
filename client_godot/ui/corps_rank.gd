extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")














const Atlas = preload("corps_rank_atlas.gd")
const CTip = preload("ctool_tip.gd")
const Board = preload("leaderboard_atlas.gd")
const CorpsReward = preload("corps_reward.gd")

signal closed

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const NONE: String = "Không có"
const PAGE_NUM: int = 10
const RANK_PATH: String = "/cGuildMatchRankList.php?rd=%d&page=%d&limit=%d&noCache=%s"
const SELF_PATH: String = "/cQueryGuildMatchRank.php?round=%d&gid=%d&noCache=%s"
const SOLO_PATH: String = "/cGetGuildMatchPlayerRank.php?round=%d&gid=%d&page=%d&limit=%d&noCache=%s"
const SOLO_SELF_PATH: String = "/cQueryGuildMatchCharRank.php?rd=%d&gid=%d&char_uuid=%s&noCache=%s"
const ROUND1_ACTS: Array = [3001]
const WIN_STEP: int = 10000

var fetch: Callable
var round_step: int = 2

var guild: Dictionary = {}
var solo: Dictionary = {}
var _want: Dictionary = {}
var _http: Dictionary = {}
var _turn: int = 0
var _reward: Control = null
var _tip: Array = []
var _ctip: CTip = CTip.new()

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Board.FILE, Board.R)
	_use(Atlas.FILE, Atlas.R)
	guild = _blank()
	solo = _blank()
	for kind: String in ["rank", "self", "solo", "solo_self"]:
		var http: HTTPRequest = HTTPRequest.new()
		http.timeout = 10
		http.accept_gzip = false
		add_child(http)
		http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
			on_reply(kind, result, code, body))
		_http[kind] = http

func _blank() -> Dictionary:
	return {"open": false, "page": 1, "total": 1, "page_text": "1/1", "rows": [], "self_text": "", "self_on": true, "corps": 0}




func open() -> void :
	_cancel_all()
	_turn += 1
	round_step = 1 if round1_on() else 2
	guild = _blank()
	guild.open = true
	solo = _blank()
	_tip = []
	_hover = ""
	_press = ""
	visible = true
	_ask_rank()
	_ask_self()


func open_solo(corps_id: int) -> void :
	for kind: String in ["solo", "solo_self"]:
		_drop(kind)
	solo = _blank()
	solo.open = true
	solo.corps = corps_id
	solo.self_on = corps_id == own_guild()
	_hover = ""
	_press = ""
	_ask_solo()
	if solo.self_on:
		_ask_solo_self()

func close_solo() -> void :
	for kind: String in ["solo", "solo_self"]:
		_drop(kind)
	solo = _blank()

func close() -> void :
	_cancel_all()
	if _reward != null:
		_reward.visible = false
	if not visible:
		return
	visible = false
	guild = _blank()
	solo = _blank()
	_tip = []
	closed.emit()

func is_open() -> bool:
	return visible and bool(guild.open)

func solo_open() -> bool:
	return is_open() and bool(solo.open)

func reward_open() -> bool:
	return _reward != null and _reward.visible


func state() -> String:
	if not is_open():
		return ""
	if solo_open():
		return "SOLO"
	return "CORPS_R1" if round_step == 1 else "CORPS"


func chat_busy() -> bool:
	return visible

func _shown() -> void :
	if not is_visible_in_tree():
		_cancel_all()

func own_guild() -> int:
	return int(client.guild.get("nGuildId", 0)) if client != null else 0


func round1_on(now: int = -1) -> bool:
	if client == null:
		return false
	if now < 0:
		now = int(Time.get_unix_time_from_system())
	for id: int in ROUND1_ACTS:
		var info: Variant = client.acts.get(id)
		if not (info is Array and (info as Array).size() >= 2):
			continue
		var start: int = int(info[0])
		var end: int = start + int(info[1])
		if (start != 0 or end != 0) and now >= start and now <= end:
			return true
	return false



func _ask_rank() -> void :
	_ask("rank", int(guild.page), RANK_PATH % [round_step, int(guild.page), PAGE_NUM, str(randf())])

func _ask_self() -> void :
	_ask("self", 0, SELF_PATH % [round_step, own_guild(), str(randf())])

func _ask_solo() -> void :
	_ask("solo", int(solo.page), SOLO_PATH % [round_step, int(solo.corps), int(solo.page), PAGE_NUM, str(randf())])

func _ask_solo_self() -> void :
	var uuid: String = str(client.char_uuid) if client != null else ""
	_ask("solo_self", 0, SOLO_SELF_PATH % [round_step, int(solo.corps), uuid.uri_encode(), str(randf())])


func _ask(kind: String, page: int, path: String) -> void :
	if client == null:
		return
	var origin: String = str(client.config.origin)
	if origin.is_empty() and not fetch.is_valid():
		return
	_want[kind] = [_turn, page]
	var done: int
	if fetch.is_valid():
		var got: Variant = fetch.call(origin + path)
		done = int(got) if got is int else OK
	else:
		var http: HTTPRequest = _http[kind]
		http.cancel_request()
		var url: String = origin + path
		done = http.request(url, AppSession.headers(url))
	if done != OK:
		_want.erase(kind)

func _drop(kind: String) -> void :
	if _http.has(kind):
		(_http[kind] as HTTPRequest).cancel_request()
	_want.erase(kind)

func _cancel_all() -> void :
	for kind: String in _http:
		(_http[kind] as HTTPRequest).cancel_request()
	_want = {}


func on_reply(kind: String, result: int, code: int, body: PackedByteArray) -> void :
	if not _want.has(kind):
		return
	var asked: Array = _want[kind]
	_want.erase(kind)
	if int(asked[0]) != _turn or result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty():
		return
	var text: String = body.get_string_from_utf8()
	if text.strip_edges().is_empty():
		return
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return
	var data: Variant = json.data
	match kind:
		"rank":
			if is_open():
				_take_list(guild, data, false)
		"self":
			if is_open():
				guild.self_text = _rank_word(data)
		"solo":
			if solo_open():
				_take_list(solo, data, true)
		"solo_self":
			if solo_open():
				solo.self_text = _rank_word(data)


func _take_list(win: Dictionary, data: Variant, single: bool) -> void :
	var obj: Dictionary = data if data is Dictionary else {}
	var amount: int = int(_num(obj.get("amount")))
	var total: int = ceili(amount / float(PAGE_NUM))
	win.total = total if total > 0 else 1
	win.page_text = "%d/%d" % [int(win.page), int(win.total)]
	var items: Variant = obj.get("datas")
	if not (items is Array):
		return
	var rows: Array = []
	for item: Variant in items:
		if not (item is Dictionary):
			continue
		var row: Dictionary = item
		if single:
			var attack: int = int(_num(row.get("btk")))
			rows.append({"rank": int(_num(row.get("rk"))), "name": _as_text(row.get("pn")), 
				"win": int(attack / WIN_STEP) if attack >= WIN_STEP else 1, "point": int(_num(row.get("sc"))), "pet": attack})
		else:
			rows.append({"rank": int(_num(row.get("r"))), "gid": int(_num(row.get("gid"))), "name": _as_text(row.get("gn")), 
				"leader": _as_text(row.get("gl")), "point": int(_num(row.get("sc"))), "pet": int(_num(row.get("batk")))})
	win.rows = rows


func _rank_word(data: Variant) -> String:
	var rank: int = int(_num((data as Dictionary).get("rank"))) if data is Dictionary else 0
	return NONE if rank == 0 else str(rank)

static func _num(value: Variant) -> float:
	if value is int or value is float:
		return float(value)
	if value is String and (value as String).is_valid_float():
		return (value as String).to_float()
	return 0.0

static func _as_text(value: Variant) -> String:
	return "" if value == null else str(value)




func _turn_page(win: Dictionary, step: int) -> void :
	var page: int = int(win.page) + step
	if page < 1 or page > int(win.total):
		return
	win.page = page
	if win == solo:
		_ask_solo()
	else:
		_ask_rank()


func _pick_round(step: int) -> void :
	_drop("rank")
	round_step = step
	guild.page = 1
	guild.total = 1
	guild.rows = []
	_ask_rank()

func page_text(single: bool = false) -> String:
	return str((solo if single else guild).page_text)

func rows(single: bool = false) -> Array:
	return (solo if single else guild).rows

func self_text(single: bool = false) -> String:
	return str((solo if single else guild).self_text)

func self_shown() -> bool:
	return bool(solo.self_on)



func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))

func _node(name: String) -> Vector2:
	return _v(Atlas.NODES[name])

func _paint() -> void :
	_tip = []
	if bool(guild.open):
		_draw_window(guild, false)
	if bool(solo.open):
		_draw_window(solo, true)
	_draw_tip(_tip[0] if not _tip.is_empty() else Rect2(), str(_tip[1]) if not _tip.is_empty() else "")


func _draw_window(win: Dictionary, single: bool) -> void :
	var pre: String = "solo_" if single else ""
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var box: Vector2 = _v(Atlas.SIZE)
	var o: Vector2 = _centre(box.x, box.y)
	_hit("panel", Rect2(o * _f, box * _f), false)
	_fblit("cr_bg", o)
	_fblit("cr_title_solo" if single else "cr_title", o + _node("cimagechecklocal1"))
	var list: Vector2 = o + _node("frmCorpsList")
	_fblit("cr_list_solo" if single else "cr_list", list + _v(Atlas.LIST["solo" if single else "point"]))
	var lst: Array = Atlas.LST
	var top: Vector2 = list + Vector2(float(lst[0]), float(lst[1]))
	var shown: Array = win.rows
	for i: int in mini(shown.size(), PAGE_NUM):
		_draw_row(shown[i], top + Vector2(0, i * float(lst[4])), i, single)
	if single:
		var help: Rect2 = Rect2(list + _v(Atlas.HELP), Vector2(float(Atlas.HELP[2]), float(Atlas.HELP[3])))
		var help_rect: Rect2 = Rect2(help.position * _f, help.size * _f)
		_hit("help", help_rect, false)
		if _hover == "help" and _tip_ok():
			_tip = [help_rect, Atlas.HELP_TIP]

	_fblit("cr_pager", o + _node("pager"))
	_fbutton(pre + "prev", "cr_prev", o + _node("btnLastPage"))
	_fbutton(pre + "next", "cr_next", o + _node("btnNextPage"))
	_label(Atlas.TEXTS["lblPage"], str(win.page_text), o, Color(str(Atlas.PAGE_RIM[0]), float(Atlas.PAGE_RIM[1])))

	if single:
		if bool(win.self_on):
			_fblit("cr_mine_solo", o + _node("imgSelfRankSolo"))
			_label(Atlas.TEXTS["lblSelfRankSolo"], str(win.self_text), o)
	else:
		_fblit("cr_mine", o + _node("imgSelfRank"))
		_label(Atlas.TEXTS["lblSelfRank"], str(win.self_text), o)

		if round_step == 1:
			_fblit("cr_round1", o + _node("btnRound1"))
			_fbutton("round2", "cr_round2", o + _node("btnRound2"))
		else:
			_fbutton("round1", "cr_round1", o + _node("btnRound1"))
		_fbutton("reward", "cr_reward", o + _node("btnViewReward"))
	_fbutton(pre + "close", "cr_close", o + _node("btnClose"))


func _label(spot: Array, text: String, o: Vector2, rim: Color = Color(0, 0, 0, 0)) -> void :
	if text.is_empty():
		return
	_fwords(text, ARIAL_BOLD if int(spot[6]) == 1 else ARIAL, float(spot[4]), Color(str(spot[5])), str(spot[7]), o + _v(spot), 
		float(spot[2]), 1.0 if rim.a > 0.0 else 0.0, 0.0, true, rim)


func _draw_row(row: Dictionary, at: Vector2, index: int, single: bool) -> void :
	var nodes: Dictionary = Atlas.ROW_NODES
	var rank: int = int(row.rank)
	var spots: Dictionary = Atlas.ROW_SOLO if single else Atlas.ROW_POINT
	if rank <= Atlas.RANK_IMAGES:
		if rank > 0:
			_fblit("lb_cr%d" % rank, at + _v(nodes["imgRank"]))
	else:
		_cell(spots["lblRank"], str(rank), at)
	if single:
		_cell(spots["lblPlayerName"], str(row.name), at)
		_cell(spots["lblWinPoint"], str(int(row.win)), at)
		_cell(spots["lblCorpsPoint"], str(int(row.point)), at)
		_cell(spots["lblPetPoint"], str(int(row.pet)), at)
	else:
		_cell(spots["lblCorpsName"], str(row.name), at)
		_cell(spots["lblLeaderName"], str(row.leader), at)
		_cell(spots["lblCorpsPoint"], str(int(row.point)), at)
		_cell(spots["lblPetPoint"], str(int(row.pet)), at)
		_fbutton("solo:%d" % index, "cr_solo", at + _v(nodes["btnSoloRank"]))
	_fblit("cr_cut", at + _v(nodes["cutline"]))


func _cell(spot: Array, text: String, at: Vector2) -> void :
	var font: Font = ARIAL_BOLD if int(spot[6]) == 1 else ARIAL
	var px: float = float(spot[4])
	var wide: float = float(spot[2])
	var shown: String = _cut(text, font, px, wide)
	_fwords(shown, font, px, Color(str(spot[5])), str(spot[7]), at + _v(spot), wide, 0.0, 0.0, false)
	if shown != text and _tip_ok() and _press.is_empty():
		var rect: Rect2 = Rect2((at + _v(spot)) * _f, Vector2(wide, px + 4.0) * _f)
		if rect.has_point(get_local_mouse_position()):
			_tip = [rect, text]


func _draw_tip(anchor: Rect2, body: String) -> void :
	_ctip.draw(self, (str(anchor) + body) if not body.is_empty() else "", body, get_local_mouse_position() / _f, Vector2(_fw, _fh), _f)


func _clip(text: String, font: Font, px: float, room: float, tail: String = "") -> String:
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	if face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
		return text
	for keep in range(text.length() - 1, 0, -1):
		var short: String = text.left(keep) + tail
		if face.get_string_size(short, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
			return short
	return text if text.length() <= 1 else text.left(1) + tail


func _cut(text: String, font: Font, px: float, wide: float) -> String:
	return _clip(text, font, px, wide - 5.0, "...")



func _activate(id: String) -> void :
	if bool(solo.open):

		match id:
			"solo_close":
				close_solo()
			"solo_prev":
				_turn_page(solo, -1)
			"solo_next":
				_turn_page(solo, 1)
		return
	if id.begins_with("solo:"):
		var index: int = id.get_slice(":", 1).to_int()
		if index >= 0 and index < (guild.rows as Array).size():
			open_solo(int(guild.rows[index].get("gid", 0)))
		return
	match id:
		"close":
			close()
		"prev":
			_turn_page(guild, -1)
		"next":
			_turn_page(guild, 1)
		"round1":
			_pick_round(1)
		"round2":
			_pick_round(2)
		"reward":
			_open_reward()


func _open_reward() -> void :
	if _reward == null:
		_reward = CorpsReward.new()
		_reward.client = client
		_reward.pack = pack
		_reward.hall = hall
		add_child(_reward)
		_reward.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_reward.open()

func _unhandled_key_input(event: InputEvent) -> void :


	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_ESCAPE:
			if bool(solo.open):
				close_solo()
			else:
				close()
		KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_PAGEUP, KEY_PAGEDOWN, KEY_ENTER, KEY_KP_ENTER:
			pass
		_:
			return
	get_viewport().set_input_as_handled()
