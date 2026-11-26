extends "hall_screen.gd"
const AppSession = preload("res://net/app_session.gd")















const SafeJson = preload("res://net/safe_json.gd")
const Lg = preload("league_atlas.gd")
const LrAtlas = preload("league_reward_atlas.gd")
const Prizes = preload("league_prizes.gd")
const AwardWindow = preload("league_award.gd")
const InfoWindow = preload("league_info.gd")

signal closed

const SOON: String = "%s đang được chuyển sang HTML5."
const TITLE: String = "GIẢI ĐẤU TEAM"
const APPLY_TITLE: String = "BÁO DANH"
const MODE_WORD: String = "Chế độ"

const RULE_TITLE: String = "Giới Thiệu League"
const RULE_SIZE: Vector2 = Vector2(422, 362)
const RULE_DESC: Rect2 = Rect2(34, 66, 358, 266)
const RULE_PX: float = 12.0
const RULE_GLOW: Color = Color("737372cc")
const RULE_RIM: Color = Color("005797")

const TIP0: String = "Phí báo danh @num1@"
const TIP1: String = "Lv team @num1@"
const TIP2: String = "Uy vọng Team @num1@"
const TIP3: String = "Quân số Team @num1@"
const TIP4: String = "T/g tạo team @num1@"
const TIP28: String = "Xếp hạng team thứ @num1@"
const TIP14: String = "T/g báo danh: @num1@ đến @num2@"
const TIP20: String = "Bạn đã bị loại, hãy nỗ lực hơn"
const TIP21: String = "T/g mở đấu: @num1@"
const TIP22: String = "Kết thúc đấu"
const TIP32: String = "(Trận @num1@)"
const TIP_141: String = "Đang nghỉ"
const TIP_316: String = "Không hạn chế"
const TIP_317: String = "Không phần thưởng"
const AWARD_TAKEN: String = "Đã nhận thưởng"
const AWARD_FAILED: String = "Nhận thất bại"
const CORPS_TEXT69: String = "Trưởng Team mới có quyền báo danh"

const KICK_OUT: int = 0
const MOVE_ON: int = 1
const ARMISTICE: int = 2
const GAME_OVER: int = 3
const SHOWN: int = 7
const DROP_SHOWN: int = 2
const BAR: float = 19.0
const PULL: float = 16.0
const MATCH_RIM: Color = Color("017ac3")
const DROP_BG: Color = Color("b0e6ff")
const DROP_EDGE: Color = Color("0075b0")
const DROP_PICK: Color = Color("009fe8")
const HOVER: Color = Color("ffff00")
const TIME_INK: Color = Color("17487c")

var now: Callable = Callable()
var fetch_hook: Callable = Callable()
var _http: Dictionary = {}
var _matches: Array = []
var _sid: int = 0
var _match: Dictionary = {}
var _phases: Array = []
var _rounds: Array = []
var _cur_round: int = 0
var _cur_phase: int = 0
var _vs: int = 0
var _prize_source: Array = []
var _applied: bool = false
var _process_state: int = KICK_OUT
var _awards: int = 0
var _state: String = "NORMAL"
var _time_text: String = ""
var _top: int = 0
var _drop_open: bool = false
var _drop_entered: bool = false
var _drop_top: int = 0
var _apply_open: bool = false
var _rule_text: String = ""
var _rule_open: bool = false
var _rule_top: int = 0
var _rule_most: int = 0
var _rule_rect: Rect2 = Rect2()
var _recheck_at: float = -1.0
var _seen_rev: int = 0
var _seen_enroll: int = 0
var _reward: Control = null
var _award_rows: Array = []
var _award_win: Control = null
var _info_win: Control = null
var _italic: FontVariation = FontVariation.new()
var _bar: Array = []
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_top: float = 0.0
var _pull: float = 0.0
var _list_rect: Rect2 = Rect2()
var _drop_rect: Rect2 = Rect2()
var _wraps: Dictionary = {}

func _setup() -> void :
	super ()
	_add_parts(Lg.PLACE)
	for kind: String in ["list", "info", "check", "award"]:
		_http[kind] = _request(kind)
	if client != null and client.has_signal("league_award_result"):
		client.connect("league_award_result", _on_award_result)
	_italic.base_font = ARIAL_BOLD
	_italic.variation_transform = Transform2D(Vector2(1.0, 0.2), Vector2(0.0, 1.0), Vector2.ZERO)

func _frames() -> Dictionary:
	return Lg.FRAME

func _request(kind: String) -> HTTPRequest:
	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 10
	http.accept_gzip = false
	add_child(http)
	http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			_arrive(kind, SafeJson.parse(body.get_string_from_utf8())))
	return http


func _base() -> String:
	var path: String = str(client.league_url)
	return str(client.config.origin) + (path.trim_suffix("/") if path.begins_with("/") else "")

func _fetch(kind: String, path: String) -> void :
	if fetch_hook.is_valid():
		fetch_hook.call(kind, path)
		return
	if client == null or str(client.config.origin).is_empty() or not _http.has(kind):
		return
	var http: HTTPRequest = _http[kind]
	http.cancel_request()
	var url: String = _base() + path
	http.request(url, AppSession.headers(url))

func _now() -> int:
	return int(now.call()) if now.is_valid() else int(Time.get_unix_time_from_system())

static func _cache_buster() -> String:
	return str(randf())



func _shown() -> void :
	_drop_open = false
	_apply_open = false
	_rule_open = false
	_grab = false
	_recheck_at = -1.0
	if _reward != null:
		_reward.close()
	if _award_win != null:
		_award_win.close()
	if _info_win != null:
		_info_win.close()
	if client == null or not is_visible_in_tree():
		return
	_top = 0
	_seen_rev = int(client.league_rev)
	_seen_enroll = int(client.league_enroll_n)
	_load_list()

func _load_list() -> void :
	_fetch("list", "/cLeagueList.php?noCache=" + _cache_buster())

func _tick(_delta: float) -> void :
	if client == null:
		return
	if int(client.league_rev) != _seen_rev:

		_seen_rev = int(client.league_rev)
		_load_list()
	if int(client.league_enroll_n) != _seen_enroll:

		_seen_enroll = int(client.league_enroll_n)
		_check(0)
	if _recheck_at >= 0.0 and _time >= _recheck_at:
		_recheck_at = -1.0
		_check(0)
	if _drop_open and not _mobile:

		var inside: bool = _drop_rect.has_point(get_local_mouse_position())
		if inside:
			_drop_entered = true
		elif _drop_entered:
			_drop_open = false



static func _int(value: Variant) -> int:
	if value is int or value is float or value is bool:
		return int(value)
	if value is String and (value as String).is_valid_float():
		return int(float(value))
	return 0


static func parse_match(row: Dictionary) -> Dictionary:
	return {"sid": _int(row.get("nSessionId")), "cost": _int(row.get("nEnrollcoin")), "level": _int(row.get("nLevelmin")), 
		"glory": _int(row.get("nGlorymin")), "members": _int(row.get("nMembermin")), "created": _int(row.get("nCreatemin")), 
		"rank": _int(row.get("nPlacemin")), "start": _int(row.get("nEnrollstart")), "close": _int(row.get("nEnrollclose")), 
		"launch": _int(row.get("nLaunch")), "need": _int(row.get("nCanenroll")) == 1, "number": _int(row.get("nNumber")), 
		"name": str(row.get("szMatchName", "")), "state": _int(row.get("nState"))}



static func match_before(a: Dictionary, b: Dictionary) -> bool:
	if int(a.state) != int(b.state):
		return int(a.state) < int(b.state)
	if int(a.state) == 1 and int(a.start) != int(b.start):
		return int(a.start) > int(b.start)
	if int(a.state) == 2 and int(a.launch) != int(b.launch):
		return int(a.launch) < int(b.launch)
	return int(a.sid) > int(b.sid)


static func match_tail(row: Dictionary) -> String:
	return TIP32.replace("@num1@", str(int(row.get("number", 0)))) if int(row.get("number", 0)) != 0 else ""

static func sort_matches(rows: Array) -> Array:
	var out: Array = rows.duplicate()
	out.sort_custom(match_before)
	return out


static func when (unix: int) -> String:
	var day: Dictionary = Time.get_datetime_dict_from_unix_time(unix + 7 * 3600)
	return "%02dh%02d'  %02d-%02d-%04d" % [int(day.hour), int(day.minute), int(day.day), int(day.month), int(day.year)]


static func held_text(unix: int) -> String:
	var day: Dictionary = Time.get_datetime_dict_from_unix_time(unix + 7 * 3600)
	var hour: int = int(day.hour)
	return "%04d/%02d/%02d %02d:%02d" % [int(day.year), int(day.month), int(day.day), 24 if hour == 0 else hour, int(day.minute)]

func matches() -> Array:
	return _matches

func rounds() -> Array:
	return _rounds

func phases() -> Array:
	return _phases


func phase() -> int:
	return _cur_phase

func state() -> String:
	return _state

func time_text() -> String:
	return _time_text

func awards() -> int:
	return _awards

func process_state() -> int:
	return _process_state

func applied() -> bool:
	return _applied

func session() -> int:
	return _sid

func top() -> int:
	return _top


func _self_team() -> Dictionary:
	if client == null or int(client.guild_self_team) == 0:
		return {}
	for team: Variant in client.guild_teams:
		if team is Dictionary and int(team.get("nTeamId", 0)) == int(client.guild_self_team):
			return team
	return {}


func _leader() -> bool:
	var team: Dictionary = _self_team()
	if team.is_empty():
		return false
	var leader: String = str(team.get("leaderUuid", ""))
	return not leader.is_empty() and (leader == str(client.char_uuid) or leader == client.guild_self_uuid())


func _check(kind: int) -> void :
	var team: Dictionary = _self_team()
	if team.is_empty() or _sid == 0:
		return
	_fetch("check", "/cLeagueCheckEnroll.php?sid=%d&tid=%d&type=%d&noCache=%s" % [_sid, int(team.get("nTeamId", 0)), kind, _cache_buster()])


func _select(sid: int) -> void :
	_drop_open = false
	for row: Dictionary in _matches:
		if int(row.sid) == sid:
			_sid = sid
			_match = row
	if _match.is_empty() or int(_match.sid) != sid:
		return
	_time_text = TIP14.replace("@num1@", when (int(_match.start))).replace("@num2@", when (int(_match.close)))
	_fetch("info", "/cLeagueInfo.php?sid=%d?noCache=%s" % [sid, _cache_buster()])
	_check(0)
	_refresh_state()


func _refresh_state() -> void :
	if _match.is_empty():
		return
	var t: int = _now()
	if _self_team().is_empty():
		_state = "CORPS"
		return
	if bool(_match.need):
		if t <= int(_match.start):
			_state = "INIT"
		elif t < int(_match.close) and not _applied:
			_state = "APPLY"
		elif not _applied:
			_state = "WATCH"
		else:
			_state = "NORMAL"
	elif t <= int(_match.launch):
		_state = "INIT"
		_time_text = TIP21.replace("@num1@", when (int(_match.launch)))
	elif not _applied:
		_state = "WATCH"
	else:
		_state = "NORMAL"


func _arm_recheck() -> void :
	_recheck_at = -1.0
	if _match.is_empty() or _applied or not bool(_match.need):
		return
	var t: int = _now()
	if t > int(_match.start) and t < int(_match.close):
		_recheck_at = _time + float(int(_match.close) - t + 10)


func _arrive(kind: String, data: Variant) -> void :
	match kind:
		"list":
			if not data is Array:
				return
			var rows: Array = []
			for row: Variant in data:
				if row is Dictionary:
					rows.append(parse_match(row))
			_matches = sort_matches(rows)
			_drop_top = 0
			if not _matches.is_empty():
				_select(int(_matches[0].sid))
		"info":
			if not data is Dictionary or not (data as Dictionary).get("allPhases") is Array:
				return
			_phases = []
			_rounds = []
			for phase: Variant in data.allPhases:
				if not phase is Dictionary:
					continue
				var id: int = _int(phase.get("nPhaseId"))
				var name: String = str(phase.get("szPhaseName", ""))
				var first: int = _rounds.size()
				var all: Variant = phase.get("allRounds")
				if all is Array:
					for round: Variant in all:
						if round is Dictionary:
							_rounds.append([id, name, _int(round.get("nRoundId")), str(round.get("szRoundName", "")), _int(round.get("nHeldTime")), _rounds.size() == first])
				_phases.append([id, name, first, maxi(1, _int(phase.get("nZonesInitial")))])
			_cur_round = _int(data.get("nCurRound"))
			_cur_phase = phase_of(_cur_round)
			_vs = _int(data.get("nMatchVsNum"))
			var rule: Variant = data.get("szRule")
			_rule_text = "" if rule == null else str(rule).replace("#ENTER#", "\n").replace("\\r\\n", "\n")
			var prizes: Variant = data.get("allPrizes")
			_prize_source = prizes if prizes is Array else []
			_top = 0
			_fetch("award", "/cLeagueAwardForPlayer.php?pid=%s&noCache=%s" % [str(client.char_uuid).uri_encode(), _cache_buster()])
		"check":
			if not data is Dictionary:
				return
			if _int(data.get("type")) == 1:
				_process_state = _int(data.get("tag"))
			else:
				_applied = _int(data.get("tag")) == 1
				_refresh_state()
				_arm_recheck()
				_check(1)
		"award":
			_award_rows = AwardWindow.parse_rows(data)
			_awards = _award_rows.size()
			if award_open():
				_award_win.show_rows(_award_rows)


func phase_of(round_id: int) -> int:
	if _phases.is_empty():
		return 0
	if round_id == 0:
		return int(_phases[-1][0])
	for row: Array in _rounds:
		if int(row[2]) == round_id:
			return int(row[0])
	return 0



func apply_rows() -> Array:
	var team: Dictionary = _self_team()
	if team.is_empty() or _match.is_empty():
		return []
	var members: int = 0
	for uuid: Variant in client.guild_members:
		var member: Variant = client.guild_members[uuid]
		if member is Dictionary and int(member.get("nTeamId", 0)) == int(team.get("nTeamId", 0)):
			members += 1
	var texts: Array = [TIP0, TIP1, TIP2, TIP3, TIP4, TIP28]
	var limits: Array = [int(_match.cost), int(_match.level), int(_match.glory), int(_match.members), int(_match.created), int(_match.rank)]
	var have: Array = [_int(team.get("iCoin")), _int(team.get("nLevel")), _int(team.get("iGlory")), members, _int(team.get("nCreateTime")), 0]
	var out: Array = []
	for i: int in texts.size():
		var limit: int = int(limits[i])
		if limit <= 0:
			out.append([str(texts[i]).replace("@num1@", TIP_316), true])
			continue
		var ok: Variant = null
		if i == 4:
			ok = int(have[i]) <= limit
		elif i != 5:
			ok = int(have[i]) >= limit
		out.append([str(texts[i]).replace("@num1@", when (limit) if i == 4 else str(limit)), ok])
	return out



func _roll(value: int) -> void :
	_top = clampi(value, 0, maxi(0, _rounds.size() - SHOWN))


func _rule_roll(value: int) -> void :
	_rule_top = clampi(value, 0, _rule_most)

func _rule_pitch() -> float:
	return _face(ARIAL_BOLD).get_height(maxi(6, roundi(RULE_PX * _f))) / maxf(_f, 0.001)


func _rule_shown() -> int:
	return maxi(1, floori((RULE_DESC.size.y - 4.0) / _rule_pitch()))


func rule_lines(wide: float) -> Array:
	var out: Array = []
	for part: String in _rule_text.split("\n"):
		out.append_array(_wrap(part, RULE_PX, wide - 4.0))
	return out

func rule_open() -> bool:
	return _rule_open

func _roll_drop(value: int) -> void :
	_drop_top = clampi(value, 0, maxi(0, _matches.size() - DROP_SHOWN))

func reward_open() -> bool:
	return (_reward != null and _reward.visible) or award_open()

func award_open() -> bool:
	return _award_win != null and _award_win.visible

func award_window() -> Control:
	return _award_win

func info_open() -> bool:
	return _info_win != null and _info_win.visible

func info_window() -> Control:
	return _info_win


func _open_info(round_id: int) -> void :
	if _info_win == null:
		_info_win = InfoWindow.new()
		_info_win.client = client
		_info_win.pack = pack
		_info_win.hall = hall
		_info_win.host = self
		_info_win.fetch_hook = fetch_hook
		add_child(_info_win)
		_info_win.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_info_win.queued.connect( func(word: String) -> void :
			if not word.is_empty():
				say(word))
		_info_win.reward_asked.connect( func() -> void :

			_open_awards()
			move_child(_award_win, -1))
	_info_win.show_round(round_id)


func _open_awards() -> void :
	if _award_win == null:
		_award_win = AwardWindow.new()
		_award_win.client = client
		_award_win.pack = pack
		_award_win.hall = hall
		add_child(_award_win)
		_award_win.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_award_win.show_rows(_award_rows)



func _on_award_result(result: int, award_id: int) -> void :
	var word: String = ""
	if result == 0 or result == 2:
		for i: int in _award_rows.size():
			if int(_award_rows[i].aid) == award_id:
				_award_rows.remove_at(i)
				break
		_awards = _award_rows.size()
		if _award_win != null:
			_award_win.remove(award_id)
		if result == 2:
			word = AWARD_TAKEN
	else:
		word = AWARD_FAILED
	if word.is_empty():
		return
	if award_open():
		_award_win.say(word)
	else:
		say(word)


func chat_busy() -> bool:
	return _apply_open or _rule_open or reward_open() or info_open()

func _open_prizes() -> void :
	if _reward == null:
		_reward = Prizes.new()
		_reward.client = client
		_reward.pack = pack
		_reward.hall = hall
		add_child(_reward)
		_reward.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_reward.source = _prize_source
	_reward.open()

func _activate(id: String) -> void :
	if id.begins_with("pick:"):
		var index: int = int(id.substr(5))
		if index >= 0 and index < _matches.size():
			_select(int(_matches[index].sid))
		_drop_open = false
		return
	if id.begins_with("phase:"):
		var phase: int = int(id.substr(6))
		for row: Array in _phases:
			if int(row[0]) == phase:
				_roll(int(row[2]))
		return
	if id.begins_with("details:"):

		var index: int = int(id.substr(8))
		if index >= 0 and index < _rounds.size():
			_open_info(int(_rounds[index][2]))
		return
	match id:
		"select":
			_drop_open = not _drop_open
			_drop_entered = false
		"rule":

			_rule_open = true
			_rule_top = 0
		"rule:close":
			_rule_open = false
		"rl:up":
			_rule_roll(_rule_top - 1)
		"rl:down":
			_rule_roll(_rule_top + 1)
		"rl:pgup":
			_rule_roll(_rule_top - _rule_shown())
		"rl:pgdn":
			_rule_roll(_rule_top + _rule_shown())
		"showreward":
			_open_prizes()
		"enter":
			match _process_state:
				KICK_OUT:
					say(TIP20)
				MOVE_ON:


					var word: String = client.league_queue()
					closed.emit()
					if not word.is_empty():
						client.noticed.emit(word)
				ARMISTICE:
					say(TIP_141)
				GAME_OVER:
					say(TIP22)
		"watch":

			if _cur_round > 0:
				_open_info(_cur_round)
		"joinclan":
			page_asked.emit("guild")
		"apply":
			if not _match.is_empty():
				_apply_open = true
		"apply:close":
			_apply_open = false
		"ok":
			if not _apply_open:
				return
			if not _leader():
				say(CORPS_TEXT69)
				return
			var team: Dictionary = _self_team()
			client.league_enroll(int(_match.sid), int(team.get("nTeamId", 0)))
			_apply_open = false
		"reward":
			if _awards <= 0:
				say(TIP_317)
			else:
				_open_awards()
		"close":
			closed.emit()
		"rb:up":
			_roll(_top - 1)
		"rb:down":
			_roll(_top + 1)
		"rb:pgup":
			_roll(_top - SHOWN)
		"rb:pgdn":
			_roll(_top + SHOWN)
		_:
			_shared(id)

func _escape() -> bool:
	if _rule_open:
		_rule_open = false
		return true
	if award_open():
		_award_win.close()
		return true
	if info_open():
		_info_win.close()
		return true
	if reward_open():
		_reward.close()
		return true
	if _apply_open:
		_apply_open = false
		return true
	if _drop_open:
		_drop_open = false
		return true
	return super ()

func _wheel(step: int, at: Vector2) -> void :
	if _rule_open:
		if _rule_rect.has_point(at):
			_rule_roll(_rule_top + step)
		return
	if _apply_open:
		return
	if _drop_open and _drop_rect.has_point(at):
		_roll_drop(_drop_top + step)
	elif _list_rect.has_point(at):
		_roll(_top + step)


func _drag(moved: Vector2, from: Vector2) -> void :
	var rule: bool = _rule_open and _rule_rect.has_point(from)
	if _grab or (_rule_open and not rule) or ( not rule and (_apply_open or not _list_rect.has_point(from))):
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, PULL * _f)
	while _pull >= pitch:
		_pull -= pitch
		if rule:
			_rule_roll(_rule_top + 1)
		else:
			_roll(_top + 1)
	while _pull <= - pitch:
		_pull += pitch
		if rule:
			_rule_roll(_rule_top - 1)
		else:
			_roll(_top - 1)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pull = 0.0
			var id: String = _hit_at(event.position)

			if _drop_open and id != "select" and not _drop_rect.has_point(event.position):
				_drop_open = false
			if id in ["slide:rb", "slide:rl"] and not _bar.is_empty():
				_grab = true
				_grab_at = event.position
				_grab_top = float(_rule_top if id == "slide:rl" else _top)
		else:
			_grab = false
	elif event is InputEventMouseMotion and _grab:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_grab = false
		else:
			var step: float = maxf(0.001, (float(_bar[0]) - float(_bar[1])) / float(_bar[2]))
			var target: int = roundi(_grab_top + (event.position.y - _grab_at.y) / _f / step)
			if _rule_open:
				_rule_roll(target)
			else:
				_roll(target)
			accept_event()
			return
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if reward_open() or info_open():
		return
	if _rule_open and event.keycode in [KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN]:

		match event.keycode:
			KEY_UP:
				_rule_roll(_rule_top - 1)
			KEY_DOWN:
				_rule_roll(_rule_top + 1)
			KEY_PAGEUP:
				_rule_roll(_rule_top - _rule_shown())
			KEY_PAGEDOWN:
				_rule_roll(_rule_top + _rule_shown())
		get_viewport().set_input_as_handled()
		return
	match event.keycode:
		KEY_ESCAPE:
			closed.emit()
		KEY_UP:
			_roll(_top - 1)
		KEY_DOWN:
			_roll(_top + 1)
		KEY_PAGEUP:
			_roll(_top - SHOWN)
		KEY_PAGEDOWN:
			_roll(_top + SHOWN)
		_:
			return
	get_viewport().set_input_as_handled()



func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))


func _label(text: String, spec: Array, base: Vector2, edge: float = 1.0, rim: Color = SHADE) -> void :
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), Color(str(spec[5])), str(spec[7]), 
		base + Vector2(float(spec[0]), float(spec[1])), float(spec[2]), edge, float(spec[3]), true, rim)

func _measure_bold(text: String, px: float) -> float:
	return ARIAL_BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f


func _wrap(text: String, px: float, wide: float) -> Array:
	var key: String = "%d|%d|%d|%s" % [roundi(px * 100.0), roundi(wide), roundi(_f * 1000.0), text]
	if _wraps.has(key):
		return _wraps[key]
	if _wraps.size() > 200:
		_wraps.clear()
	var out: Array = []
	var line: String = ""
	for word: String in text.split(" ", false):
		var trial: String = word if line.is_empty() else line + " " + word
		if line.is_empty() or _measure_bold(trial, px) <= wide:
			line = trial
		else:
			out.append(line)
			line = word
	out.append(line)
	_wraps[key] = out
	return out

func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(Hall.FILE, Hall.R)
		_use(Lg.FILE, Lg.R)
		_use(LrAtlas.FILE, LrAtlas.R)
	var glyph: int = maxi(1, roundi(_f))
	if _italic.spacing_glyph != glyph:
		_italic.spacing_glyph = glyph
	_scene()
	var o: Vector2 = _at("hall")
	_frows(_parts.get("hall", []), o)
	_fwords(TITLE, ARIAL_BOLD, 24.0, Color.WHITE, "c", o + Vector2(float(Lg.TITLE[0]) - 200.0, float(Lg.TITLE[1])), 400.0, 2.0, 32.0, true, TITLE_RIM)
	for head: Array in Lg.HEAD:
		_fwords(str(head[2]), ARIAL_BOLD, 14.0, Color.WHITE, "c", o + Vector2(float(head[0]) - 80.0, float(head[1])), 160.0, 1.0, 0.0, true, TITLE_RIM)
	_draw_mode(o)
	_draw_match(_match, o + _v(Lg.SELECT.cur), float(Lg.SELECT.cur[2]), float(Lg.SELECT.cur[3]))
	_draw_phases(o)
	_draw_rounds(o)
	_draw_state(o)
	_drop_rect = Rect2()
	if _drop_open:
		_draw_drop(o)
	if _apply_open:
		_draw_apply()
	_rule_rect = Rect2()
	if _rule_open:
		_draw_rule()


func _draw_mode(o: Vector2) -> void :
	var mode: Dictionary = Lg.MODE
	var rect: Array = mode.rect
	_fwords(MODE_WORD, ARIAL_BOLD, 14.0, Color.WHITE, "l", o + Vector2(float(mode.word[0]), float(rect[1])), 62.0, 1.0, float(rect[3]), true, TITLE_RIM)
	var at: Vector2 = o + Vector2(float(rect[0]), float(rect[1]))
	_round(Rect2(at * _f, Vector2(float(rect[2]), float(rect[3])) * _f), Color("062c61"), 8.0, Color("2a8bd0"), 2.0)
	if _vs > 0:
		_fwords("%dV%d" % [_vs, _vs], ARIAL_BOLD, float(mode.label[4]), Color.WHITE, "c", at, float(rect[2]), 1.0, float(rect[3]))


func _draw_match(row: Dictionary, at: Vector2, wide: float, high: float) -> void :
	if row.is_empty():
		return
	var tail: String = match_tail(row)
	var px: float = 16.0
	var lines: Array = []
	while true:
		var small: float = px * 0.75
		lines = []
		for line: String in _wrap(str(row.name), px, wide - 4.0):
			lines.append([line, ""])
		if not tail.is_empty():
			var last: Array = lines[-1]
			if _measure_bold(str(last[0]) + " ", px) + _measure_bold(tail, small) <= wide - 4.0:
				last[1] = tail
			else:
				lines.append(["", tail])
		if lines.size() * (px + 3.0) <= high or px <= 10.0:
			break
		px -= 1.0
	var pitch: float = px + 3.0
	var y: float = at.y + (high - pitch * lines.size()) / 2.0
	for line: Array in lines:
		var head: String = str(line[0])
		var rest: String = str(line[1])
		var small: float = px * 0.75
		var w1: float = _measure_bold(head + (" " if not rest.is_empty() and not head.is_empty() else ""), px) if not head.is_empty() else 0.0
		var w2: float = _measure_bold(rest, small) if not rest.is_empty() else 0.0
		var x: float = at.x + (wide - w1 - w2) / 2.0
		if not head.is_empty():
			_fwords(head, ARIAL_BOLD, px, Color.WHITE, "l", Vector2(x, y), w1 + 2.0, 1.5, pitch, false, MATCH_RIM)
		if not rest.is_empty():
			_fwords(rest, ARIAL_BOLD, small, Color.WHITE, "l", Vector2(x + w1, y + (px - small) * 0.35), w2 + 2.0, 1.5, pitch, false, MATCH_RIM)
		y += pitch


func _draw_phases(o: Vector2) -> void :
	var spec: Dictionary = Lg.PHASE
	var at: Vector2 = o + _v(spec.at)
	var back: Array = spec.back
	var fill: Array = spec.fill
	draw_rect(Rect2((at + _v(back)) * _f, Vector2(float(back[2]), float(back[3])) * _f), Color(str(back[4])))
	draw_rect(Rect2((at + _v(fill)) * _f, Vector2(float(fill[2]), float(fill[3])) * _f), Color(str(fill[4])))
	var count: int = _phases.size()
	if count == 0:
		return
	var index: int = -1
	for i: int in count:
		if int(_phases[i][0]) == _cur_phase:
			index = i
	if index + 1 != 0:
		var left: float = at.x + float(fill[0])
		var right: float = minf(at.x + float(fill[0]) + float(index + 1) / float(count) * float(spec.wide), at.x + float(fill[0]) + float(fill[2]))
		var body: float = maxf(left, right - float(spec.head) * 0.5)
		var top: float = at.y + float(fill[1])
		var low: float = top + float(fill[3])
		draw_colored_polygon(PackedVector2Array([Vector2(left, top) * _f, Vector2(body, top) * _f, Vector2(right, (top + low) / 2.0) * _f, 
			Vector2(body, low) * _f, Vector2(left, low) * _f]), Color(str(spec.arrow)))
	var title: Array = spec.title
	var label_w: float = float(title[0])
	var gap: float = floorf((842.0 - label_w * count) / count)
	var total: float = label_w * count + gap * (count - 1)
	var x0: float = at.x - 120.0 + (842.0 - total) / 2.0
	var size_px: int = maxi(6, roundi(float(title[2]) * _f))
	for i: int in count:
		var id: String = "phase:%d" % int(_phases[i][0])
		var rect: Rect2 = Rect2(Vector2(x0 + (label_w + gap) * i, at.y - 1.0) * _f, Vector2(label_w, float(title[1])) * _f)
		var text: String = str(_phases[i][1])
		var wide: float = _italic.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
		var spot: Vector2 = Vector2(rect.get_center().x - wide / 2.0, rect.get_center().y + (_italic.get_ascent(size_px) - _italic.get_descent(size_px)) / 2.0)
		draw_string_outline(_italic, spot, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, maxi(1, roundi(2.0 * _f)), Color(TITLE_RIM, 0.9))
		draw_string(_italic, spot, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, HOVER if _hover == id and _press.is_empty() else Color.WHITE)
		_hit(id, rect, false)


func _draw_rounds(o: Vector2) -> void :
	var spec: Array = Lg.LIST
	var at: Vector2 = o + _v(spec)
	var wide: float = float(spec[2])
	var high: float = float(spec[3])
	var pitch: float = float(spec[4])
	_list_rect = Rect2(at * _f, Vector2(wide, high) * _f)
	var row: Dictionary = Lg.ROW
	for k: int in SHOWN:
		var index: int = _top + k
		if index >= _rounds.size():
			break
		var item: Array = _rounds[index]
		var base: Vector2 = at + Vector2(0, pitch * k)
		if bool(item[5]):
			_label(str(item[1]), row.lblPhaseName, base)
		_label(str(item[3]), row.lblRoundName, base)
		_label(held_text(int(item[4])), row.lblHeldTime, base)
		_fbutton("details:%d" % index, "lg_details", base + _v(row.details))
		_fblit("lg_cutline", base + _v(row.cutline))
	_draw_bar(at + Vector2(wide - BAR, 0), high - 2.0 * BAR)


func _draw_bar(at: Vector2, track: float) -> void :
	_bar = []
	_fblit("lr_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("rb:up", "lr_sb_up", at)
	_fbutton("rb:down", "lr_sb_down", at + Vector2(0, BAR + track))
	var most: float = float(maxi(0, _rounds.size() - SHOWN))
	if most <= 0.0:
		return
	var thumb: float = maxf(20.0, track * SHOWN / (most + SHOWN))
	var y: float = at.y + BAR + (track - thumb) * clampf(_top / most, 0.0, 1.0)
	_hit("rb:pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, y - at.y - BAR) * _f), false)
	_hit("rb:pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(BAR, at.y + BAR + track - y - thumb) * _f), false)
	_fslice("lr_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:rb"))
	_hit("slide:rb", Rect2(Vector2(at.x, y) * _f, Vector2(BAR, thumb) * _f), false)
	_bar = [track, thumb, most]


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


func _draw_state(o: Vector2) -> void :
	var spec: Dictionary = Lg.STATES.get(_state, Lg.STATES["NORMAL"])
	_frows(spec.rows, o)
	if _awards > 0:
		var badge: Vector2 = o + _v(spec.badge)
		_fblit("public_tip", badge + Vector2(3, 3))
		_fwords("99+" if _awards > 99 else str(_awards), ARIAL_BOLD, 11.0, Color.WHITE, "c", Vector2(badge.x, o.y + float(spec.badge_num[1]) - 10.0), 25.0, 0.0, 20.0)
	var time: Array = spec.time
	if time.is_empty() or _time_text.is_empty():
		return
	var px: float = float(time[4])
	var lines: Array = _wrap(_time_text, px, float(time[2]))
	var pitch: float = px + 4.0
	var y: float = o.y + float(time[1]) + (float(time[3]) - pitch * lines.size()) / 2.0
	for line: Variant in lines:
		_fwords(str(line), ARIAL_BOLD, px, Color(str(time[5])), "c", Vector2(o.x + float(time[0]), y), float(time[2]), 1.0, pitch, true, Color(1, 1, 1, 0.7))
		y += pitch


func _draw_drop(o: Vector2) -> void :
	var spec: Dictionary = Lg.SELECT
	var box: Array = spec.box
	var at: Vector2 = o + _v(box)
	var rect: Rect2 = Rect2(at * _f, Vector2(float(box[2]), float(box[3])) * _f)
	_round(rect, DROP_BG, 16.0, DROP_EDGE, 3.0)
	_drop_rect = rect
	_hit("drop", rect, false)
	var pitch: float = float(spec.row)
	var item_w: float = float(spec.item_wide)
	for k: int in DROP_SHOWN:
		var index: int = _drop_top + k
		if index >= _matches.size():
			break
		var row: Dictionary = _matches[index]
		var spot: Vector2 = at + Vector2(3, 1 + pitch * k)
		var cell: Rect2 = Rect2(spot * _f, Vector2(item_w, pitch) * _f)
		var id: String = "pick:%d" % index
		if int(row.sid) == _sid:
			_round(cell, DROP_PICK, 10.0)
		elif _hover == id and _press.is_empty():
			_round(cell, Color(DROP_PICK, 0.45), 10.0)
		_draw_match(row, spot, item_w, pitch)
		_hit(id, cell, false)




func _draw_rule() -> void :
	var at: Vector2 = _window(RULE_SIZE.x, RULE_SIZE.y, "rule:close")
	_fwords(RULE_TITLE, ARIAL_BOLD, 17.0, Color.WHITE, "c", at + Vector2(roundf((RULE_SIZE.x - 170.0) / 2.0), 22), 170.0, 1.0, 0.0, true, RULE_GLOW)
	var box: Vector2 = at + RULE_DESC.position
	_rule_rect = Rect2(box * _f, RULE_DESC.size * _f)
	var shown: int = _rule_shown()
	var lines: Array = rule_lines(RULE_DESC.size.x)
	var bar: bool = lines.size() > shown
	if bar:
		lines = rule_lines(RULE_DESC.size.x - BAR)
	_rule_most = maxi(0, lines.size() - shown)
	_rule_top = clampi(_rule_top, 0, _rule_most)
	var pitch: float = _rule_pitch()
	for i: int in range(_rule_top, mini(lines.size(), _rule_top + shown)):
		_fwords(str(lines[i]), ARIAL_BOLD, RULE_PX, Color.WHITE, "l", box + Vector2(2, 2 + pitch * (i - _rule_top)), RULE_DESC.size.x - 4.0, 1.0, pitch, 
			false, RULE_RIM)
	if bar:
		_draw_rule_bar(box + Vector2(RULE_DESC.size.x - BAR, 0), RULE_DESC.size.y - 2.0 * BAR)


func _draw_rule_bar(at: Vector2, track: float) -> void :
	_fblit("lr_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("rl:up", "lr_sb_up", at)
	_fbutton("rl:down", "lr_sb_down", at + Vector2(0, BAR + track))
	var most: float = float(_rule_most)
	var shown: float = float(_rule_shown())
	var thumb: float = maxf(20.0, track * shown / (most + shown))
	var y: float = at.y + BAR + (track - thumb) * clampf(_rule_top / most, 0.0, 1.0)
	_hit("rl:pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, y - at.y - BAR) * _f), false)
	_hit("rl:pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(BAR, at.y + BAR + track - y - thumb) * _f), false)
	_fslice("lr_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:rl"))
	_hit("slide:rl", Rect2(Vector2(at.x, y) * _f, Vector2(BAR, thumb) * _f), false)
	_bar = [track, thumb, most]

func _draw_apply() -> void :
	var spec: Dictionary = Lg.APPLY
	var size_f: Vector2 = _v(spec.size)
	var at: Vector2 = _window(size_f.x, size_f.y, "apply:close")
	_fwords(APPLY_TITLE, ARIAL_BOLD, 15.0, Color.WHITE, "c", at + Vector2(roundf((size_f.x - 182.0) / 2.0), 18), 182.0, 1.5, 28.0, true, TITLE_RIM)
	_fblit("lg_applylist", at + _v(spec.list))
	var holder: Vector2 = at + _v(spec.holder)
	var rows: Array = apply_rows()
	for i: int in mini(rows.size(), floori(float(spec.holder[3]) / float(spec.row))):
		var base: Vector2 = holder + Vector2(0, float(spec.row) * i)
		var ok: Variant = rows[i][1]
		if ok is bool:
			_fblit("lg_tick" if ok else "lg_cross", base + _v(spec.mark))
		_fblit("lg_cond_cut", base + _v(spec.cut))
		_label(str(rows[i][0]), spec.text, base)
	_confirm(at, size_f.x, size_f.y, "lg_w_confirm")
