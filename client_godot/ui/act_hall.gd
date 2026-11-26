extends "hall_screen.gd"
const AppSession = preload("res://net/app_session.gd")











const Quick = preload("quickmatch_atlas.gd")
const ActHall = preload("act_hall_atlas.gd")
const GarageModel = preload("garage_model.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")

signal closed

const TYPES: Array = [3, 28, 32]
const LIVE_TEXT: Color = Color("fffad6")
const LIVE_RIM: Color = Color("5a0002")
const IDLE_TEXT: Color = Color("b6f7ff")
const IDLE_RIM: Color = Color("050e35")
const LINE: float = 19.0
const STATE_RIM: Color = Color(0.843, 0.275, 0.071, 0.8)
const TIME_GOLD: Color = Color("fcff00")
const TIME_RIM: Color = Color(0.0, 0.4, 0.682, 0.8)
const SHOW_AT: int = 1800
const OPEN_TEXT: String = "Thời gian mở :"
const FRONT_TEXT: String = "Bắt đầu sau :"
const ACTING_TEXT: String = "Kết thúc sau :"
const SOON: String = "%s đang được chuyển sang HTML5."
const MODES: Dictionary = {"tab:ladder": "Đấu Xếp Hạng"}
const TIP_96: String = "LV @num1@ mới được vào Guild"
const ACTS_PATH: String = "/xml/ActivityTemplate_table.xml"
const WEEK_SIZE: Vector2 = Vector2(501, 301)
const WEEK_MOST: int = 8
const WEEK_TITLE: String = "TANK TUẦN"
const WEEK_INK: Color = Color("fff3c4")
const WEEK_BOX: Color = Color(0, 0, 0, 0.45)

const TT1_COLS: int = 4
const TT1_CELL: float = 96.0
const TT1_STEP: float = 104.0
const TT1_PAD: float = 31.0
const TT1_LT: Vector2 = Vector2(15, 46)
const TT1_RB: Vector2 = Vector2(15, 62)

var templates: Dictionary = {}
var _http: HTTPRequest
var _asking: bool = false
var _week_open: bool = false
var _week: Array = []

func _setup() -> void :
	super ()
	_add_parts(ActHall.PLACE)
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		_asking = false
		if result == HTTPRequest.RESULT_SUCCESS and code == 200:
			read_templates(body))

func _frames() -> Dictionary:
	return ActHall.FRAME

func _shown() -> void :
	_reset_list()
	_week_open = false
	if client != null and is_visible_in_tree() and templates.is_empty() and not _asking and _http != null and is_inside_tree():
		var url: String = client.config.origin + ACTS_PATH
		_asking = _http.request(url, AppSession.headers(url)) == OK

func _tick(_delta: float) -> void :
	if client == null:
		return
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
						rows[id] = {"type": int(str(row.get("nType", "0"))), "time": _plain(str(row.get("szTimeDesc", ""))).replace("#ENTER#", "\n").strip_edges(), 
							"start": _plain(str(row.get("szStartTime", ""))).strip_edges()}
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


func template_of(type: int) -> Dictionary:
	var best: int = 0
	for id: int in templates:
		if int(templates[id].type) == type and (best == 0 or id < best):
			best = id
	return templates.get(best, {})



func lit(type: int, now: int = -1) -> bool:
	var id: int = client.act_first([type])
	if id == 0:
		return false
	if now < 0:
		now = int(Time.get_unix_time_from_system())
	var info: Array = client.acts[id]
	return now > int(info[0]) and now < int(info[0]) + int(info[1])



func tip_state(now: int = -1) -> Array:
	var id: int = client.match_act_id()
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



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(Hall.FILE, Hall.R)
		_use(Quick.FILE, Quick.R)
		_use(ActHall.FILE, ActHall.R)
	_scene()
	var frame: Vector2 = _at("hall")
	_frows(_parts.get("hall", []), frame)
	for type: int in TYPES:
		_draw_info(frame, type)
	_draw_tip(frame)
	if not client.pairing.is_empty():
		_draw_waiting(frame)
	var side: Vector2 = _at("list")
	_frows(_parts.get("list", []), side)
	_draw_players(side)
	_draw_chat()
	_draw_menu()
	if not _viewing.is_empty():
		_draw_viewing()
	if _week_open:
		_draw_week()


func _draw_info(frame: Vector2, type: int) -> void :
	var key: String = str(type)
	var at: Vector2 = frame + Vector2(float(ActHall.INFO.at[key][0]), float(ActHall.INFO.at[key][1]))
	var on: bool = lit(type)
	var suffix: String = "active" if on else "no_active"
	_fblit("gameroom_act_img_%s_%s_t" % [str(ActHall.INFO.kind[key]), suffix], at + _v(ActHall.INFO.bg))
	_fblit("gameroom_act_img_act_tip_" + suffix, at + _v(ActHall.INFO.tip))
	if type == 32:
		_fblit("gameroom_act_word_show_tank_%s_t" % suffix, at + _v(ActHall.INFO.tank_word))
		var button: Rect2 = _fblit("gameroom_act_btn_show_tank_" + suffix, at + _v(ActHall.INFO.tank_btn), 0.0, 0.0, _glow("tank"))
		_hit("tank", button, false)
	var text: Array = ActHall.INFO.text
	var lines: Array = []
	for part: String in str(template_of(type).get("time", "")).split("\n"):
		lines.append_array(_wrap(part, float(text[4]), float(text[2]) - 4.0))
	var color: Color = LIVE_TEXT if on else IDLE_TEXT
	var rim: Color = LIVE_RIM if on else IDLE_RIM
	var most: int = maxi(1, floori(float(text[3]) / LINE))
	for i in range(mini(lines.size(), most)):
		_fwords(str(lines[i]), ARIAL_BOLD, float(text[4]), color, "c", at + Vector2(float(text[0]), float(text[1]) + LINE * i), float(text[2]), 1.0, 
			0.0, false, rim)


func _wrap(line: String, px: float, wide: float) -> Array:
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(px * _f))
	var out: Array = []
	var current: String = ""
	for word: String in line.split(" ", false):
		var trial: String = word if current.is_empty() else current + " " + word
		if not current.is_empty() and font.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > wide * _f:
			out.append(current)
			current = word
		else:
			current = trial
	if not current.is_empty() or out.is_empty():
		out.append(current)
	return out


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
	var wait: Dictionary = ActHall.WAIT
	var at: Vector2 = frame + _v(wait.at)
	var from: Rect2 = Rect2(0.0, float(wait.from), float(wait.size[0]), float(wait.size[1]))
	_fpart("gda_qm_bk", at, from)
	_fpart("gameroom_pvpReadyRoom1000x600_shadow", at, from)

	_hit("qm:block", Rect2((at + Vector2(456, 0)) * _f, Vector2(338, 158) * _f), false)
	var broad: Vector2 = at + _v(wait.broad)
	_fblit("gda_qm_wait_t", broad + _v(wait.title))
	var since: int = int(client.pairing.get("since", Time.get_ticks_msec()))
	var spent: int = maxi(0, floori((Time.get_ticks_msec() - since) / 1000.0))
	var clock_row: Array = wait.clock
	_fwords("%02d:%02d" % [floori(spent / 60.0), spent % 60], ARIAL_BOLD, float(clock_row[4]), TIME_GOLD, "c", 
		at + Vector2(float(clock_row[0]), float(clock_row[1])), float(clock_row[2]), 2.0, 0.0, true, TIME_RIM)
	var spot: Vector2 = broad + _v(wait.cancel)
	var button: Rect2 = _fblit("gda_qm_btn", spot, 0.0, 0.0, _glow("match:cancel"))
	_hit("match:cancel", button, false)
	_fblit("gda_qm_cancel_t", spot + ((_cell_size("gda_qm_btn") - _cell_size("gda_qm_cancel_t")) / 2.0).round())

func _v(pair: Variant) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))




func open_week(tanks: Array) -> void :
	_viewing = {}
	_week = tanks.duplicate()
	_week_open = true

func close_week() -> void :
	_week_open = false
	_week = []






static func tt1_rows(count: int) -> int:
	return maxi(1, ceili(float(mini(count, WEEK_MOST)) / TT1_COLS))


static func tt1_size(rows: int) -> Vector2:
	var grid: Vector2 = Vector2(TT1_COLS, rows) * TT1_STEP - Vector2.ONE * (TT1_STEP - TT1_CELL)
	return grid + Vector2.ONE * TT1_PAD * 2.0 + TT1_LT + TT1_RB

func _draw_week() -> void :
	var rows: int = tt1_rows(_week.size())
	var box: Vector2 = tt1_size(rows)
	var at: Vector2 = _window(box.x, box.y, "wl_close")
	_fwords(WEEK_TITLE, ARIAL_BOLD, 18.0, WEEK_INK, "c", at + Vector2(0, 14), box.x, 1.0, 28.0)
	var grid: Vector2 = at + TT1_LT + Vector2.ONE * TT1_PAD
	for i in range(rows * TT1_COLS):
		var cell: Vector2 = grid + Vector2(i % TT1_COLS, i / TT1_COLS) * TT1_STEP
		_round(Rect2(cell * _f, Vector2.ONE * TT1_CELL * _f), WEEK_BOX, 6.0)
	for i in range(mini(_week.size(), WEEK_MOST)):
		var cell: Vector2 = grid + Vector2(i % TT1_COLS, i / TT1_COLS) * TT1_STEP
		var tid: int = int(_week[i])
		_week_tank(tid, cell + Vector2(8.0, 8.0 if i < TT1_COLS else 9.0) + Vector2(100, 100) * 0.4, 0.4)
		_fwords(week_name(tid), ARIAL_BOLD, 14.0, Color.WHITE, "c", cell + Vector2(0, 72), TT1_CELL, 1.0, 20.0)


func week_name(tid: int) -> String:
	return GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(tid), ""))) if pack != null else ""


func _week_tank(tid: int, c: Vector2, zoom: float) -> void :
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tid, 1, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), 0, 1)
	if TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, c * _f, zoom * _f, _time) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tid))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46) * zoom
		TankPreview.draw(self, art, (pod - Vector2(0, 52) * zoom) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * zoom * _f, 4, _time)

func chat_busy() -> bool:
	return super () or _week_open

func _escape() -> bool:
	if _week_open:
		close_week()
		return true
	return super ()



func _activate(id: String) -> void :
	if _week_open:
		if id == "wl_close":
			close_week()
		return
	if id.begins_with("qm:"):
		return
	if id == "match:cancel":
		client.stop_match()
		return
	if client.is_pairing() and (id == "quick" or id == "back" or id.begins_with("tab:")):
		say(client.INVITE_PAIRING)
		return
	if id == "tab:ladder":
		page_asked.emit("ladder")
		return
	if id == "tab:league":
		_to_clan()
		return
	if MODES.has(id):
		say(SOON % str(MODES[id]))
		return
	match id:
		"quick":
			var why: String = client.act_match()
			if not why.is_empty():
				say(why)
		"tank":
			open_week(client.fire_ball_tanks)
		"tab:pvp":
			closed.emit()
		"back":
			client.back_to_lobby()
			closed.emit()
		_:
			_shared(id)



func _to_clan() -> void :
	var need: int = client.TEAM_JOIN_LEVEL
	if int(client.character.get("level", 0)) < need:
		say(TIP_96.replace("@num1@", str(need)))
		return
	client.hall_tab(client.TEAM_ROOM)
	closed.emit()

func _wheel(step: int, at: Vector2) -> void :
	if not _viewing.is_empty() or _week_open:
		return
	_wheel_list(step, at)

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode == KEY_ESCAPE:
		closed.emit()
		get_viewport().set_input_as_handled()
