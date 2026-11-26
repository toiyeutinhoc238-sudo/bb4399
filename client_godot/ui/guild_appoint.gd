extends "flash_screen.gd"














const Appoint = preload("guild_appoint_atlas.gd")
const Arena = preload("arena_atlas.gd")
const Guild = preload("guild_atlas.gd")

signal closed(note: String)

const OUTER: Vector2 = Vector2(1018, 618)
const POST_CAPTAIN: int = 5
const POST_VICE: int = 9
const POST_LEADER: int = 10
const MAX_ROWS: int = 12
const DROP_WIDE: float = 160.0
const DROP_ROW: float = 25.0
const DROP_SHOWN: int = 5
const BAR: float = 19.0

const COMBO_EDGE: Color = Color("1b79b4")
const COMBO_TOP: Color = Color("64bbdf")
const COMBO_BOTTOM: Color = Color("108ec6")
const DROP_FILL: Color = Color("0390d3")
const DROP_OVER: Color = Color("31b3e8")
const DROP_PICKED: Color = Color("07629b")
const DUTY_FILL: Color = Color("ff8f22")
const DUTY_RIM: Color = Color("10249bcc")

const TITLE: String = "BỔ NHIỆM"
const HEAD_DUTY: String = "Bổ nhiệm"
const HEAD_RIGHTS: String = "Quyền hạn"
const HEAD_POSTS: Array = ["Guild trưởng", "Phó Guild", "Team trưởng", "Thành viên"]
const HEAD_COLUMNS: Array = [455.0, 525.0, 595.0, 665.0]

const DUTY_LEADER: String = "Guild trưởng"
const DUTY_VICE: String = "Phó Guild"
const DUTY_CAPTAIN: String = "Team trưởng @name@"
const POST_TITLES: Dictionary = {0: "Thành viên", 5: "Team trưởng", 9: "Phó Guild", 10: "Guild trưởng"}
const ASK_POST: String = "Quyết định nhậm chức @name@ là @title1@?"
const ASK_LEADER: String = "Giao chức cho @name@? Bạn sẽ trở thành thành viên thường"
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."

var _drop: int = -1
var _drop_first: int = 0
var _drop_rect: Rect2 = Rect2()
var _ask: Dictionary = {}

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Appoint.FILE, Appoint.R)
	_use(Arena.FILE, {"public_button_close": Arena.R["public_button_close"]})
	var cells: Dictionary = {}
	for key: String in ["gu_ask", "gu_ask_guy", "gu_ask_ok", "gu_ask_no", "gu_sb_bk", "gu_sb_up", "gu_sb_down", "gu_sb_thumb"]:
		cells[key] = Guild.R[key]
	_use(Guild.FILE, cells)

func open() -> void :
	_toast = ""
	_hover = ""
	_press = ""
	_drop = -1
	_ask = {}
	visible = true

func close(note: String = "") -> void :
	if not visible:
		return
	visible = false
	_drop = -1
	_ask = {}
	closed.emit(note)

func chat_busy() -> bool:
	return visible



func _nick(uuid: String) -> String:
	return str(client.guild_briefs.get(uuid, {}).get("m_name", ""))


func _by_merit(uuids: Array) -> Array:
	var known: Array = uuids.filter( func(uuid: String) -> bool: return client.guild_briefs.has(uuid))
	known.sort_custom( func(a: String, b: String) -> bool:
		return int(client.guild_members[a].get("iAllMerit", 0)) > int(client.guild_members[b].get("iAllMerit", 0)))
	return known


func _rows() -> Array:
	var me: String = client.guild_self_uuid()
	var leader: String = str(client.guild.get("leaderUuid", ""))
	var vice: String = str(client.guild.get("viceLeaderUuid", ""))
	var all: Array = client.guild_members.keys()
	var head: bool = not me.is_empty() and me == leader
	var rows: Array = [
		{"duty": DUTY_LEADER, "post": POST_LEADER, "holder": leader, "options": _by_merit(all), "enabled": head}, 
		{"duty": DUTY_VICE, "post": POST_VICE, "holder": vice, "options": _by_merit(all.filter( func(uuid: String) -> bool: return uuid != leader)), "enabled": head}, 
	]
	var teams: Array = client.guild_teams.duplicate()
	teams.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("nLevel", 0)) > int(b.get("nLevel", 0)))
	for team: Dictionary in teams:
		var id: int = int(team.get("nTeamId", 0))
		var crew: Array = all.filter( func(uuid: String) -> bool: return int(client.guild_members[uuid].get("nTeamId", 0)) == id)
		rows.append({"duty": DUTY_CAPTAIN.replace("@name@", str(team.get("strName", ""))), "post": POST_CAPTAIN, 
			"holder": str(team.get("leaderUuid", "")), "options": _by_merit(crew), "enabled": head or ( not me.is_empty() and me == vice)})
	return rows.slice(0, MAX_ROWS)



func _activate(id: String) -> void :
	if not _ask.is_empty():
		match id:
			"ask_ok":
				var sent: bool = client.guild_change_post(str(_ask["uuid"]), int(_ask["post"]), int(_ask["team"]))
				_ask = {}
				if not sent:
					say(OFFLINE)
			"ask_no":
				_ask = {}
		return
	if id.begins_with("opt:"):
		_pick(int(id.substr(4)))
		return
	if id in ["drop_up", "drop_down"]:
		_scroll(-1 if id == "drop_up" else 1)
		return
	if id in ["drop", "slide:drop"]:
		return
	var was: int = _drop
	_drop = -1
	if id == "cancel":
		close("")
	elif id.begins_with("combo:") and int(id.substr(6)) != was:
		_open_drop(int(id.substr(6)))

func _open_drop(index: int) -> void :
	var rows: Array = _rows()
	if index >= rows.size() or not bool(rows[index]["enabled"]) or (rows[index]["options"] as Array).is_empty():
		return
	_drop = index
	var at: int = (rows[index]["options"] as Array).find(str(rows[index]["holder"]))
	_drop_first = clampi(at, 0, maxi(0, (rows[index]["options"] as Array).size() - DROP_SHOWN))


func _pick(option: int) -> void :
	var rows: Array = _rows()
	var index: int = _drop
	_drop = -1
	if index < 0 or index >= rows.size():
		return
	var row: Dictionary = rows[index]
	var options: Array = row["options"]
	if option < 0 or option >= options.size() or str(options[option]) == str(row["holder"]):
		return
	var uuid: String = options[option]
	var post: int = int(row["post"])
	var text: String = ASK_LEADER.replace("@name@", _nick(uuid)) if post == POST_LEADER\
	else ASK_POST.replace("@name@", _nick(uuid)).replace("@title1@", str(POST_TITLES.get(post, "")))
	_ask = {"uuid": uuid, "post": post, "team": int(client.guild_members.get(uuid, {}).get("nTeamId", 0)), "text": text}

func _scroll(step: int) -> void :
	var rows: Array = _rows()
	if _drop < 0 or _drop >= rows.size():
		return
	_drop_first = clampi(_drop_first + step, 0, maxi(0, (rows[_drop]["options"] as Array).size() - DROP_SHOWN))

func _wheel(step: int, at: Vector2) -> void :
	if _drop >= 0 and _ask.is_empty() and Rect2(_drop_rect.position * _f, _drop_rect.size * _f).has_point(at):
		_scroll(step)

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if not _ask.is_empty():
			_ask = {}
		elif _drop >= 0:
			_drop = -1
		else:
			close("")
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()




func _cut(text: String, font: Font, px: float, room: float) -> String:
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	if face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
		return text
	for keep in range(text.length() - 1, 0, -1):
		var short: String = text.left(keep) + "..."
		if face.get_string_size(short, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
			return short
	return "..."

func _frame_at() -> Vector2:
	var frame: Array = Appoint.FRAME
	return _stage() + Vector2(-9, -9) + ((OUTER - Vector2(float(frame[0]), float(frame[1]))) / 2.0).floor()

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _frame_at()
	var frame: Array = Appoint.FRAME
	_hit("panel", Rect2(at * _f, Vector2(float(frame[0]), float(frame[1])) * _f), false)
	_fblit("ap_frame", at)
	var shut: Array = Appoint.AT["btnCancel"]
	_fbutton("cancel", "public_button_close", at + Vector2(float(shut[0]), float(shut[1])))
	_fwords(TITLE, ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2((float(frame[0]) - 182.0) / 2.0, 18), 182.0, 1.5, 28.0)
	_fwords(HEAD_DUTY, ARIAL_BOLD, 14.0, Color.WHITE, "l", at + Vector2(25, 61), 160.0, 1.0, 22.0)
	var heads: Array = Appoint.HEADS
	_fwords(HEAD_RIGHTS, ARIAL_BOLD, 14.0, Color.WHITE, "l", at + Vector2(float(heads[0][0]), float(heads[0][1])), 140.0, 1.0, 22.0)
	for i in range(HEAD_POSTS.size()):
		_fwords(HEAD_POSTS[i], ARIAL_BOLD, 14.0, Color.WHITE, "c", at + Vector2(float(HEAD_COLUMNS[i]), 61), 70.0, 1.0, 22.0)
	var rows: Array = _rows()
	if _drop >= rows.size():
		_drop = -1
	var list: Array = Appoint.AT["lstDuty"]
	for i in range(rows.size()):
		_draw_row(rows[i], i, at + Vector2(float(list[0]), float(list[1]) + 30.0 * i))
	if _drop >= 0:
		_draw_drop(rows[_drop], at + Vector2(float(list[0]), float(list[1]) + 30.0 * _drop))
	if not _ask.is_empty():
		_draw_ask(at)


func _draw_row(row: Dictionary, index: int, at: Vector2) -> void :
	_fblit("ap_row", at + Vector2(0, 1))
	var duty: Array = Appoint.ROW["lblDuty"]
	_fwords(_cut(str(row["duty"]), ARIAL_BOLD, float(duty[4]), float(duty[2])), ARIAL_BOLD, float(duty[4]), DUTY_FILL, "l", 
		at + Vector2(float(duty[0]), float(duty[1])), float(duty[2]), 1.0, 0.0, false, DUTY_RIM)
	var combo: Array = Appoint.ROW["cbbMember"]
	var box: Rect2 = Rect2(at + Vector2(float(combo[0]), float(combo[1])), Vector2(float(combo[2]), float(combo[3])))
	var id: String = "combo:%d" % index
	var enabled: bool = bool(row["enabled"])
	var rect: Rect2 = Rect2(box.position * _f, box.size * _f)
	var edge: Color = COMBO_EDGE if enabled else Color(COMBO_EDGE, 0.5)
	if enabled and (_hover == id or _drop == index):
		_grad(rect, COMBO_BOTTOM, COMBO_BOTTOM, edge, 6.0, 2.0)
	else:
		var alpha: float = 1.0 if enabled else 0.85
		_grad(rect, Color(COMBO_TOP, alpha), Color(COMBO_BOTTOM, alpha), edge, 6.0, 2.0)
	var split: float = box.position.x + box.size.x - 22.0
	draw_line(Vector2(split, box.position.y + 4.0) * _f, Vector2(split, box.end.y - 4.0) * _f, edge, maxf(1.0, _f))
	var mid: float = box.position.y + box.size.y / 2.0
	var right: float = box.end.x
	draw_colored_polygon(PackedVector2Array([Vector2(right - 15.0, mid - 2.0) * _f, Vector2(right - 8.0, mid - 2.0) * _f, Vector2(right - 11.5, mid + 3.0) * _f]), 
		Color.WHITE if enabled else Color("999999"))
	var holder: String = str(row["holder"])
	if (row["options"] as Array).has(holder):
		var room: float = box.size.x - 22.0 - 5.0 - 2.0
		_fwords(_cut(_nick(holder), ARIAL_BOLD, 14.0, room), ARIAL_BOLD, 14.0, Color.WHITE if enabled else Color("aab3b3"), "l", 
			box.position + Vector2(5, 0), room, 0.0, box.size.y, false)
	if enabled:
		_hit(id, rect, false)


func _draw_drop(row: Dictionary, at: Vector2) -> void :
	var options: Array = row["options"]
	var shown: int = mini(DROP_SHOWN, options.size())
	var combo: Array = Appoint.ROW["cbbMember"]
	var high: float = DROP_ROW * shown
	var top: Vector2 = at + Vector2(float(combo[0]), float(combo[1]) + float(combo[3]))
	if top.y + high > floorf(_fh + 0.01):
		top.y = at.y + float(combo[1]) - high
	_drop_rect = Rect2(top, Vector2(DROP_WIDE, high))
	draw_rect(Rect2((top + Vector2(2, 2)) * _f, _drop_rect.size * _f), Color(0, 0, 0, 0.25))
	var rect: Rect2 = Rect2(top * _f, _drop_rect.size * _f)
	draw_rect(rect, DROP_FILL)
	_hit("drop", rect, false)
	var scroll: bool = options.size() > DROP_SHOWN
	var wide: float = DROP_WIDE - (BAR if scroll else 0.0)
	var holder: String = str(row["holder"])
	for k in range(shown):
		var j: int = _drop_first + k
		if j >= options.size():
			break
		var line: Rect2 = Rect2((top + Vector2(0, DROP_ROW * k)) * _f, Vector2(wide, DROP_ROW) * _f)
		var id: String = "opt:%d" % j
		if str(options[j]) == holder:
			draw_rect(line, DROP_PICKED)
		elif _hover == id:
			draw_rect(line, DROP_OVER)
		_fwords(_cut(_nick(str(options[j])), ARIAL, 14.0, wide - 7.0), ARIAL, 14.0, Color.WHITE, "l", 
			top + Vector2(5, DROP_ROW * k), wide - 7.0, 0.0, DROP_ROW, false)
		_hit(id, line, false)
	if scroll:
		var bar: Vector2 = top + Vector2(wide, 0)
		var track: float = high - 2.0 * BAR
		_fblit("gu_sb_bk", bar + Vector2(0, BAR), BAR, track)
		_fbutton("drop_up", "gu_sb_up", bar)
		_fbutton("drop_down", "gu_sb_down", bar + Vector2(0, high - BAR))
		var thumb: float = maxf(10.0, track * float(DROP_SHOWN) / float(options.size()))
		var offset: float = (track - thumb) * float(_drop_first) / float(maxi(1, options.size() - DROP_SHOWN))
		var most: int = options.size() - DROP_SHOWN
		_knob_hit("slide:drop", _fblit("gu_sb_thumb", bar + Vector2(0, BAR + offset), BAR, thumb, _glow("slide:drop")), _drop_first, most, (track - thumb) * _f, 
			func(value: float) -> void : _scroll(roundi(value) - _drop_first))


func _draw_ask(frame: Vector2) -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.4))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var box: Array = Appoint.FRAME
	var at: Vector2 = frame + ((Vector2(float(box[0]), float(box[1])) - Vector2(450, 220)) / 2.0).floor()
	_hit("panel", Rect2(at * _f, Vector2(450, 220) * _f), false)
	var panel: Array = Guild.ASK["panel"]
	_fblit("gu_ask", at + Vector2(float(panel[0]), float(panel[1])))
	_fblit("gu_ask_guy", at + Vector2(-80, -76))
	var words: Array = Guild.ASK["txtContent"]
	_fpara(str(_ask["text"]), ARIAL_BOLD, float(words[4]), Color.WHITE, at + Vector2(float(words[0]), float(words[1])), float(words[2]), 5)
	var ok: Array = Guild.ASK["btnConfirm"]
	var no: Array = Guild.ASK["btnCancel"]
	_fbutton("ask_ok", "gu_ask_ok", at + Vector2(float(ok[0]), float(ok[1])))
	_fbutton("ask_no", "gu_ask_no", at + Vector2(float(no[0]), float(no[1])))
