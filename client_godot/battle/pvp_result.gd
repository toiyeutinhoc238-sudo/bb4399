extends "../ui/flash_screen.gd"























const Atlas = preload("../ui/pvpresult_atlas.gd")
const Hall = preload("../ui/hall_atlas.gd")
const TankPortrait = preload("../ui/tank_portrait.gd")
const TankPreview = preload("../ui/tank_preview.gd")
const GarageModel = preload("../ui/garage_model.gd")
const Report = preload("../ui/gmreport_atlas.gd")
const VoiceClient = preload("../ui/voice_client.gd")
const VOICE_AT: Vector2 = Vector2(1007.0, 24.0)
const Arena = preload("../ui/arena_atlas.gd")
const Restraint = preload("../ui/restraint_atlas.gd")
const ResultTips = preload("result_tips.gd")
const Ladder = preload("../ui/ladder_hall.gd")
const LobbyBar = preload("../ui/lobby_bar.gd")
const ChatF = preload("../ui/chatf_atlas.gd")




const LADDER_ROOM: int = 9
const SCORE_HEAD_FILE: String = "res://assets/ui/hall/pvpresult_battlescore.png"
const SCORE_HEAD_AT: Vector2 = Vector2(434, 23)
const ELO_UP: Color = Color("44ff00")
const ELO_DOWN: Color = Color("ff4400")

const DIM: Color = Color(0, 0, 0, 0.6)
const ROBOT_MAX: int = 100000
const PVP_COIN: int = 8000005
const DATA_STAT_EXP: int = 10
const DATA_STAT_COIN: int = 11
const FPS: float = 24.0
const EXP_FRAMES: int = 120
const ROW_STEP: float = 36.0
const ROWS: int = 5
const BAR_WIDTH: float = 416.0
const BAR_LABEL_PAD: float = 5.0
const MIN_SCALE: float = 0.2
const MAX_SCALE: float = 0.5
const CHAT_LINE: float = 20.0
const CHAT_ROWS: int = 6
const CHAT_PX: float = 13.0

const CHAT_PANEL: Rect2 = Rect2(40, 404, 456, 159)
const CHAT_TEXT_X: float = 70.0
const CHAT_TEXT_END: float = 476.0
const CHAT_TOP: float = 438.0
const CHAT_BAR: Rect2 = Rect2(482, 440, 4, 116)
const CHAT_INPUT: Rect2 = Rect2(40, 569, 456, 34)
const CHAT_CHIP_W: float = 98.0
const CHAT_SEND_W: float = 56.0
const CHAT_GLASS: Color = Color("0a1729", 0.92)
const CHAT_EDGE: Color = Color("2c5d8f", 0.8)
const CHAT_FIELD: Color = Color("061426")
const CHAT_BODY: Color = Color("e8eef6")
const CHAT_RIM: Color = Color(0, 0, 0, 0.7)
const CHAT_HINT: String = "Nhập tin nhắn…"

const ST_BASE: int = 0
const ST_ACT: int = 1
const ST_VIP: int = 2
const ST_DOUBLE: int = 3
const ST_DAILY: int = 4
const ST_AVATAR: int = 5
const ST_DECORATE: int = 6
const ST_ROOM: int = 7
const ST_TANK_EXP_CARD: int = 20

const SHARES: Array = [["base", "lblBase", "Cơ sở"], ["act", "lblAct", "Hoạt động"], ["double", "lblDouble", "X2"], 
	["avatar", "lblAvatar", "Thời trang"], ["avatar", "lblOrnament", "Trang Sức"], ["daily", "lblDaily", "Hàng ngày :"], 
	["vip", "lblVip", "VIP"]]
const FULL: String = "Đầy lv"

const ROBOT_TIPS: Array = ["Danh sách yêu cầu kết bạn của người này đã đầy", "Người này đã ẩn yêu cầu kết bạn", "Yêu cầu thành công"]

const TABS: Array = [["label1", "Tổng"], ["label4", "Room"], ["label2", "Team"], ["label0", "Guild"], ["label3", "Chat riêng"]]
const CHANNEL: String = "Chiến trường"
const BACK_TIP: String = "%d đã về"

signal tank_buy_asked(tid: int)

const BUY_TIP: String = "Mua tank đang được chuyển sang HTML5."
const BRIEF_CUT: float = 254.0
const BRIEF_EDGE: float = 278.0
const BRIEF_GROW: float = 36.0
const BRIEF_TINT: Color = Color(0.975, 0.975, 0.975)
const RT_BOX: Color = Color(0, 0, 0, 0.45)
const RT_TITLE: Color = Color("fff3c4")

const LEAVE_COLOR: Color = Color("d0d0d0")
const ENEMY_COLOR: Color = Color("ffffff")

const REPORT_LEVEL: int = 10
const REPORT_LIMIT: int = 244
const REPORT_MAX: int = 3
const TIP_495: String = "Đã hết lượt report trong ngày!"
const TIP_496: String = "Chưa đủ Lv10, không thể report!"
const GM_REPORT: String = "Chọn lý do"
const REPORT_WARN: String = "Chú ý: Cố ý report sai sẽ bị phạt!"


const IMPEACH_TIPS: Dictionary = {2: "Đã gửi thông tin báo cáo này, đừng gửi lại nữa!", 3: "Cấm báo cáo", 4: TIP_496, 5: TIP_495}
const WINDOW_CELLS: Array = ["public_bk", "public_bk_b2", "public_bk_bc", "public_bk_bc_r", "public_bk_c", "public_bk_l", "public_bk_lt", 
	"public_bk_oc", "public_bk_ol", "public_bk_or", "public_bk_pattern", "public_bk_r", "public_bk_rt", "public_bk_ti", 
	"public_button_close", "public_window_button_bk"]

var buttons: Dictionary = {}
var _typing: LineEdit
var _asked: Dictionary = {}
var _exp: Dictionary = {}
var _exp_clock: float = 0.0
var _hooked: bool = false
var _chat_scroll: int = 0
var _italic: FontVariation
var _report: Dictionary = {}
var _restraint: int = 0
var _reasons: int = 0
var _reported: Dictionary = {}
var _tips: ResultTips = ResultTips.new()
var voice_drawn: Dictionary = {}

func _setup() -> void :
	_use(Atlas.FILE, Atlas.R)
	var levels: Dictionary = {}
	for cell: String in Hall.R:
		if cell.begins_with("level_"):
			levels[cell] = Hall.R[cell]
	_use(Hall.FILE, levels)
	var frame: Dictionary = {}
	for cell: String in WINDOW_CELLS:
		frame[cell] = Arena.R[cell]
	_use(Arena.FILE, frame)
	_use(Report.FILE, Report.R)
	_use(Restraint.FILE, Restraint.R)
	_use(SCORE_HEAD_FILE, {"pr_battlescore": [0, 0, 52, 13]})
	_use(ChatF.FILE, {"chatf_tab": ChatF.R["chatf_tab"], "chatf_tab_on": ChatF.R["chatf_tab_on"]})
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_italic = FontVariation.new()
	_italic.base_font = ARIAL_BOLD
	_italic.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)
	_typing = _fedit(60)
	_typing.placeholder_text = CHAT_HINT
	_typing.add_theme_font_override("font", ARIAL)
	_typing.add_theme_color_override("font_placeholder_color", Color(1, 1, 1, 0.45))
	_typing.text_submitted.connect( func(text: String) -> void :
		if client != null and client.send_result_chat(text):
			_typing.text = ""
			_chat_scroll = 0)

func _shown() -> void :
	_close_report()
	_close_restraint()
	if not is_visible_in_tree():
		_voice_release()
		_hide_edits()
		return
	_asked.clear()
	_reported.clear()
	_tips.reset()
	_chat_scroll = 0
	_exp_clock = 0.0
	_exp = {}
	if client != null:
		var me: Dictionary = _self_stat()
		_exp = exp_start(int(client.character.get("level", 1)), int(client.character.get("exp", 0)), 
			stat_of(me.get("m_iStatData", []), DATA_STAT_EXP) if not me.is_empty() else 0)

func _tick(delta: float) -> void :
	if client == null:
		return
	if not _hooked:
		_hooked = true
		client.friend_result.connect( func(_ok: bool, text: String) -> void :
			if is_visible_in_tree() and not text.is_empty():
				say(text))
		client.impeach_result.connect( func(ret: int) -> void :
			if is_visible_in_tree() and IMPEACH_TIPS.has(ret):
				say(str(IMPEACH_TIPS[ret])))
	if pack != null and pack.state == "ready":
		pack.load_bag()
		pack.load_garage()
	if _exp.is_empty():
		return
	_exp_clock += delta
	while _exp_clock >= 1.0 / FPS and bool(_exp.get("run", false)):
		_exp_clock -= 1.0 / FPS
		exp_step(_exp)


func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or _typing == null or not event.is_pressed() or event.is_echo() or not _report.is_empty():
		return
	if _restraint > 0:
		if event is InputEventKey and (event as InputEventKey).physical_keycode == KEY_ESCAPE:
			_close_restraint()
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and (event as InputEventKey).physical_keycode in [KEY_ENTER, KEY_KP_ENTER]:
		_typing.grab_focus()
		get_viewport().set_input_as_handled()



func button_rect(key: String) -> Rect2:
	_metrics()
	var o: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	var spec: Array = Atlas.NODES["btnExit"] if key == "exit" else Atlas.NODES["btnBack"]
	return Rect2((o + Vector2(float(spec[0]), 562.0)) * _f, Vector2(float(spec[2]), 47.0) * _f)

func _wheel(step: int, at: Vector2) -> void :
	if not _report.is_empty() or _restraint > 0:
		return
	var o: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	if Rect2((o + CHAT_PANEL.position) * _f, CHAT_PANEL.size * _f).has_point(at):
		_chat_scroll = clampi(_chat_scroll - step, 0, _chat_max())




static func robot(id: int, battle) -> bool:
	if id > ROBOT_MAX or battle == null or battle.load_rates.has(id):
		return false
	for other: Variant in battle.load_rates.keys():
		if int(other) != int(battle.self_id):
			return true
	return false

func _activate(id: String) -> void :
	if not _report.is_empty():
		_report_click(id)
		return
	if _restraint > 0:
		_restraint_click(id)
		return
	if id.begins_with("voice:"):
		var voice: Object = _voice()
		if voice != null:
			voice.dock_click(id)
		return
	if id.begins_with("report:"):
		_open_report(int(id.substr(7)))
		return
	if id.begins_with("friend:"):
		var target: int = int(id.substr(7))
		_asked[target] = true
		if robot(target, client.battle):
			say(str(ROBOT_TIPS[randi() % ROBOT_TIPS.size()]))
			return
		for row: Dictionary in players(client.battle.outcome, client.battle.roster, client.battle.names):
			if int(row.id) == target:
				client.add_friend(str(row.name))
				return
		return
	match id:
		"buy":

			var tid: int = int(_brief_of(client.battle.roster, mvp(client.battle.outcome)).get("otherData", {}).get("tankId", 0))
			if tid > 0 and not owns(client.tanks, tid) and not tank_buy_asked.get_connections().is_empty():
				tank_buy_asked.emit(tid)
			elif tid > 0 and not owns(client.tanks, tid):
				say(BUY_TIP)
		"oppose":

			var target: int = restraint_of(_mvp_tank())
			if target > 0 and _tank_known(target):
				_restraint = target
				_typing.release_focus()
				_block(true)
		"send":
			if client.send_result_chat(_typing.text):
				_typing.text = ""
				_chat_scroll = 0
		"clear":
			client.battle.chat.clear()
			_chat_scroll = 0
		"up":
			_chat_scroll = clampi(_chat_scroll + 1, 0, _chat_max())
		"down":
			_chat_scroll = clampi(_chat_scroll - 1, 0, _chat_max())
		"bottom":
			_chat_scroll = 0



func _paint() -> void :
	_tips.begin()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	_hit("panel", Rect2(o * _f, Vector2(float(Atlas.SIZE[0]), float(Atlas.SIZE[1])) * _f), false)
	for key: String in ["bg", "board", "tank"]:
		if key == "tank":
			_brief_panel(o + _v(Atlas.PANELS["brief"]))
		_fblit("pr_" + key, o + _v(Atlas.PANELS[key]))
	var battle = client.battle
	_boards(o, battle)
	_chat(o, battle)
	_brief(o, battle)
	_tank(o, battle)
	if not client.room_state.room.is_empty():
		_fblit("pr_backtip", o + _v(Atlas.NODES["cvsBackTip"]))
		_label(o, "lblPlayerBackNum", BACK_TIP % 0)
	for key: String in ["exit", "back"]:
		var button: Button = buttons.get(key) as Button
		if button == null or not button.visible:
			continue
		var lit: float = 1.0
		match button.get_draw_mode():
			BaseButton.DRAW_PRESSED, BaseButton.DRAW_HOVER_PRESSED:
				lit = 0.78
			BaseButton.DRAW_HOVER:
				lit = 1.16
		_fblit("pr_exit" if key == "exit" else "pr_back", o + Vector2(585, 563) if key == "exit" else o + Vector2(715, 562), 0.0, 0.0, Color(lit, lit, lit, 1.0))
	var voice: Object = _voice()
	voice_drawn = voice.dock_draw(self, "result", o + VOICE_AT) if voice != null else {}
	if not _report.is_empty():
		_report_window()
	if _restraint > 0:
		_restraint_window()

	_tips.frame(self, _f, Vector2(_fw, _fh), get_local_mouse_position(), not _hover.is_empty(), _mobile or not _report.is_empty() or _restraint > 0, _time, 
		_held, ARIAL_BOLD)


func _voice() -> Object:
	if client == null or not VoiceClient.usable():
		return null
	var voice: Object = VoiceClient.shared()
	voice.attach(client)
	return voice

func _voice_release() -> void :
	var voice: Object = _voice()
	if voice != null:
		voice.dock_release()


func _gui_input(event: InputEvent) -> void :
	var voice: Object = _voice() if _report.is_empty() and _restraint <= 0 else null
	if voice != null:
		voice.dock_touch(self, "result", event)
	super (event)




func _brief_panel(at: Vector2) -> void :
	var wide: float = 450.0
	_fpart("pr_brief", at, Rect2(0, 0, wide, BRIEF_CUT))
	_fpart("pr_brief", at + Vector2(0, BRIEF_CUT), Rect2(0, BRIEF_CUT - BRIEF_GROW - 48.0, wide, BRIEF_GROW), BRIEF_TINT)
	_fpart("pr_brief", at + Vector2(0, BRIEF_CUT + BRIEF_GROW), Rect2(0, BRIEF_CUT, wide, BRIEF_EDGE - BRIEF_CUT))
	_fpart("pr_brief", at + Vector2(0, BRIEF_EDGE), Rect2(0, BRIEF_EDGE, wide, 308.0 - BRIEF_EDGE))

static func _v(spec: Array) -> Vector2:
	return Vector2(float(spec[0]), float(spec[1]))


func _label(o: Vector2, key: String, text: String, color: Variant = null) -> void :
	var spec: Array = Atlas.TEXTS[key]
	var tone: Color = color if color is Color else Color(str(spec[5]))
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), tone, str(spec[7]), o + Vector2(float(spec[0]), float(spec[1])), 
		float(spec[2]), 0.0, float(spec[3]))



func _boards(o: Vector2, battle) -> void :
	var rows: Array = players(battle.outcome, battle.roster, battle.names)
	var parts: Dictionary = split(rows, battle.self_id)
	var me_camp: int = battle.self_camp()
	var win: bool = int(battle.outcome.get("m_winCamp", 0)) == (2 if me_camp == 0 else me_camp)
	_fblit("pr_win", o + _v(Atlas.NODES["imgWinSelf" if win else "imgWinEnemy"]))
	if ladder_room(battle):
		_fblit("pr_battlescore", o + SCORE_HEAD_AT)
	var friends: Dictionary = {}
	for brief: Dictionary in client.friends.values():
		friends[str(brief.get("m_name", ""))] = true
	for side: String in ["self", "other"]:
		var list: Array = parts[side]
		var at: Vector2 = o + _v(Atlas.LISTS[side])
		for i in range(mini(ROWS, list.size())):
			_player_row(at + Vector2(0, ROW_STEP * i), list[i], battle, me_camp, friends)

func _player_row(at: Vector2, row: Dictionary, battle, me_camp: int, friends: Dictionary) -> void :
	_row_tank(row, at + Vector2(23, 19), 0.17)
	var mine: bool = int(row.id) == int(battle.self_id)
	var tone: Color = Color(str(Atlas.ROW_TEXTS["lblPlayerName"][5]))
	if bool(row.leave):
		tone = LEAVE_COLOR
	elif int(row.camp) != (2 if me_camp == 0 else me_camp):
		tone = ENEMY_COLOR
	for key: String in ["lblPlayerName", "lblBattleData"]:
		var spec: Array = Atlas.ROW_TEXTS[key]
		var text: String = str(row.name) if key == "lblPlayerName" else "%d/%d/%d" % [int(row.kill), int(row.dead), int(row.assist)]
		_fwords(text, ARIAL_BOLD, float(spec[4]), tone, str(spec[7]), at + Vector2(float(spec[0]), float(spec[1])), float(spec[2]))
	if ladder_room(battle):
		var virtue: Array = Atlas.ROW_TEXTS["lblVirtue"]
		_fwords(str(battle_point(row)), ARIAL_BOLD, float(virtue[4]), tone, str(virtue[7]), at + Vector2(float(virtue[0]), float(virtue[1])), 
			float(virtue[2]))
		var change: Array = Atlas.ROW_TEXTS["lblEloChange"]
		var shown: Array = elo_change(row)
		_fwords(str(shown[0]), ARIAL_BOLD, float(change[4]), shown[1], str(change[7]), at + Vector2(float(change[0]), float(change[1])), 
			float(change[2]))
	var titles: Array = []
	var outcome: Dictionary = battle.outcome
	for pair: Array in [["m_nKiller", "pr_t_kill"], ["m_nAssister", "pr_t_assist"], ["m_nKDA", "pr_t_kda"], ["m_nDestroyer", "pr_t_destroy"]]:
		if int(outcome.get(pair[0], 0)) == int(row.id) and int(row.id) != 0:
			titles.append(pair[1])
	var box: Array = Atlas.ROW["icons"]
	var x: float = float(box[0]) + float(box[2]) - 22.0 * titles.size()
	for icon: String in titles:
		_tips.add("%d:%s" % [int(row.id), icon], _fblit(icon, at + Vector2(x, float(box[1]))), str(ResultTips.TECHNIQUE.get(icon, "")))
		x += 22.0
	if not mine and not _asked.has(int(row.id)) and not friends.has(str(row.name)):
		var spot: Array = Atlas.ROW["btnAddFriend"]
		var id: String = "friend:%d" % int(row.id)
		_tips.add(id, _fbutton(id, "pr_friend", at + Vector2(float(spot[0]), float(spot[1]))), ResultTips.FRIEND)

	if not mine and me_camp != 0 and int(row.camp) == me_camp and not _reported.has(int(row.id)):
		_tips.add("report:%d" % int(row.id), _fbutton("report:%d" % int(row.id), "gmr_report", at + Vector2(float(Report.REPORT[0]), 
			float(Report.REPORT[1]))), ResultTips.REPORT)
	_fblit("pr_cut", at + Vector2(0, 34))


static func ladder_room(battle) -> bool:
	return battle != null and int(battle.room_type) == LADDER_ROOM


static func battle_point(row: Dictionary) -> int:
	var section: int = int(row.get("section", 0))
	return Ladder.point(section, int(row.get("new_elo", 0))) if section > 0 else 0


static func elo_change(row: Dictionary) -> Array:
	var change: int = (int(row.get("new_elo", 0)) - int(row.get("old_elo", 0))) * 2
	return ["+%d" % change, ELO_UP] if change >= 0 else [str(change), ELO_DOWN]


func _row_tank(row: Dictionary, centre: Vector2, zoom: float) -> void :
	_portrait(int(row.tank), int(row.ext), int(row.level), int(row.halo), centre, zoom)

func _portrait(tank_id: int, ext: int, level: int, halo: int, centre: Vector2, zoom: float) -> void :
	if tank_id <= 0 or pack.state != "ready" or pack.garage.is_empty():
		return
	level = maxi(1, level)
	if ext <= 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, level, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), halo, level)
	if TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, centre * _f, zoom * _f, _time):
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tank_id))
	if TankPreview.ready(art):
		TankPreview.draw(self, art, (centre - Vector2(0, 6) * zoom) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * zoom * _f, 4, _time)




func _chat(o: Vector2, battle) -> void :
	_round(Rect2((o + CHAT_PANEL.position) * _f, CHAT_PANEL.size * _f), CHAT_GLASS, 10.0, CHAT_EDGE, 1.0)
	for i in range(TABS.size()):
		var spot: Vector2 = o + Vector2(66.0 + 71.0 * i, 409.0)
		_fblit("chatf_tab_on" if i == 0 else "chatf_tab", spot)
		_fwords(str(TABS[i][1]), BOLD, 12.0, Color(1, 1, 1, 1.0 if i == 0 else 0.85), "c", spot, 69.0, 1.0, 25.0)
	var rows: Array = _chat_rows(battle, CHAT_TEXT_END - CHAT_TEXT_X - 12.0)
	_chat_scroll = clampi(_chat_scroll, 0, maxi(0, rows.size() - CHAT_ROWS))
	var last: int = rows.size() - _chat_scroll
	var shown: Array = rows.slice(maxi(0, last - CHAT_ROWS), last)
	for i in range(shown.size()):
		var row: Dictionary = shown[i]
		var y: float = o.y + CHAT_TOP + CHAT_LINE * i
		if row.dot is Color:
			draw_circle((o + Vector2(CHAT_TEXT_X + 5.0, y + CHAT_LINE / 2.0)) * _f, 4.5 * _f, CHAT_RIM, true, -1.0, true)
			draw_circle((o + Vector2(CHAT_TEXT_X + 5.0, y + CHAT_LINE / 2.0)) * _f, 3.0 * _f, row.dot, true, -1.0, true)
		var x: float = o.x + CHAT_TEXT_X + 12.0
		for seg: Array in row.segs:
			x += _fwords(str(seg[0]), seg[2], CHAT_PX, seg[1], "l", Vector2(x, y), 600.0, 1.0, CHAT_LINE, false, CHAT_RIM)
	if rows.size() > CHAT_ROWS:
		var track: Rect2 = Rect2((o + CHAT_BAR.position) * _f, CHAT_BAR.size * _f)
		_round(track, Color(1, 1, 1, 0.08), 2.0)
		var high: float = maxf(16.0, CHAT_BAR.size.y * CHAT_ROWS / rows.size())
		var top: float = (CHAT_BAR.size.y - high) * (1.0 - float(_chat_scroll) / float(rows.size() - CHAT_ROWS))
		_round(Rect2((o + CHAT_BAR.position + Vector2(0, top)) * _f, Vector2(CHAT_BAR.size.x, high) * _f), Color("5d8fc4", 0.9), 2.0)
	for pair: Array in [["clear", "btnClear"], ["up", "btnPageUp"], ["down", "btnPagDown"], ["bottom", "btnPageButtom"]]:
		var spec: Array = Atlas.NODES[pair[1]]
		var rect: Rect2 = Rect2((o + Vector2(float(spec[0]), float(spec[1]))) * _f, Vector2(float(spec[2]), float(spec[3])) * _f)
		LobbyBar.pill(self, rect, rect.size.y / 2.0, _f, 2 if _press == str(pair[0]) else (1 if _hover == str(pair[0]) else 0), true)
		_side_glyph(str(pair[0]), rect.get_center(), 4.0 * _f)
		_hit(str(pair[0]), rect)
	_chat_input(o)


func _side_glyph(kind: String, c: Vector2, s: float) -> void :
	var ink: Color = Color(1, 1, 1, 0.92)
	match kind:
		"clear":
			draw_line(c + Vector2( - s, - s) * 0.8, c + Vector2(s, s) * 0.8, ink, maxf(1.5, 0.45 * s), true)
			draw_line(c + Vector2(s, - s) * 0.8, c + Vector2( - s, s) * 0.8, ink, maxf(1.5, 0.45 * s), true)
		"up":
			draw_colored_polygon(PackedVector2Array([c + Vector2( - s, s * 0.55), c + Vector2(s, s * 0.55), c + Vector2(0, - s * 0.75)]), ink)
		"down":
			draw_colored_polygon(PackedVector2Array([c + Vector2( - s, - s * 0.55), c + Vector2(s, - s * 0.55), c + Vector2(0, s * 0.75)]), ink)
		"bottom":
			draw_colored_polygon(PackedVector2Array([c + Vector2( - s, - s * 0.8), c + Vector2(s, - s * 0.8), c + Vector2(0, s * 0.45)]), ink)
			draw_rect(Rect2(c + Vector2( - s, s * 0.6), Vector2(2.0 * s, maxf(1.5, 0.35 * s))), ink)



func _chat_input(o: Vector2) -> void :
	var style: String = LobbyBar.current()
	var row: Rect2 = Rect2(o + CHAT_INPUT.position, CHAT_INPUT.size)
	var box: Rect2 = Rect2(row.position * _f, row.size * _f)
	if style == "glass":
		LobbyBar.grad(self, box, 17.0 * _f, Color(LobbyBar.B_DARK, 0.86), Color(LobbyBar.B_DARK, 0.94), Color(1, 1, 1, 0.24), maxf(1.0, _f))
	else:
		LobbyBar.grad(self, box, 17.0 * _f, Color("0a2246", 0.96), Color("031027", 0.96), Color(LobbyBar.A_STRIP[2], 0.9), maxf(1.0, 1.2 * _f))
	var at: Vector2 = row.position + Vector2(4, 4)
	var chip: Rect2 = Rect2(at * _f, Vector2(CHAT_CHIP_W, 26) * _f)
	if style == "glass":
		LobbyBar.pill(self, chip, 13.0 * _f, _f, 0, true)
	else:
		LobbyBar.key(self, chip, 13.0 * _f, _f)
	_fwords(CHANNEL, BOLD, 12.0, Color.WHITE, "c", at, CHAT_CHIP_W, 1.0, 26.0)
	var send_at: Vector2 = Vector2(row.end.x - 4.0 - CHAT_SEND_W, at.y)
	var go: Rect2 = Rect2(send_at * _f, Vector2(CHAT_SEND_W, 26) * _f)
	var state: int = 2 if _press == "send" else (1 if _hover == "send" else 0)
	if style == "glass":
		var hot: Color = LobbyBar.B_ORANGE.lightened(0.12) if state == 1 else (LobbyBar.B_ORANGE.darkened(0.15) if state == 2 else LobbyBar.B_ORANGE)
		LobbyBar.grad(self, go, 13.0 * _f, hot.lightened(0.15), hot.darkened(0.12), Color(1, 1, 1, 0.35), maxf(1.0, _f))
	else:
		LobbyBar.key(self, go, 13.0 * _f, _f, true, state)
	_fwords("Gửi", BOLD, 13.0, Color.WHITE, "c", send_at, CHAT_SEND_W, 1.0, 26.0)
	_hit("send", go)
	var field: Rect2 = Rect2(Vector2(at.x + CHAT_CHIP_W + 4.0, at.y), Vector2(send_at.x - 4.0 - (at.x + CHAT_CHIP_W + 4.0), 26))
	_round(Rect2(field.position * _f, field.size * _f), CHAT_FIELD, 13.0, Color("2c5d8f", 0.7), 1.0)
	var free: bool = _report.is_empty() and _restraint <= 0
	_fput(_typing, Rect2(field.position + Vector2(10, 0), field.size - Vector2(16, 0)), CHAT_PX, "l", free)
	_typing.mouse_filter = Control.MOUSE_FILTER_STOP if free else Control.MOUSE_FILTER_IGNORE



func _chat_rows(battle, wide: float) -> Array:
	var font_size: int = maxi(6, roundi(CHAT_PX * _f))
	var limit: float = wide * _f
	var rows: Array = []
	for line: Dictionary in battle.chat:
		if preload("chat_mute.gd").hides(battle, line):
			continue
		var head: String = str(line.get("head", ""))
		var tone: Color = line.get("color", Color.WHITE)
		var pieces: Array = []
		if not head.is_empty():
			pieces.append([head if head.ends_with(" ") else head + " ", tone, BOLD])
		if not str(line.get("name", "")).is_empty():
			pieces.append([str(line.name), line.get("name_color", Color.WHITE), BOLD])
		pieces.append([str(line.get("text", "")), CHAT_BODY if not head.is_empty() else tone, REGULAR])
		var row: Dictionary = {"dot": tone, "segs": []}
		var x: float = 0.0
		for piece: Array in pieces:
			var text: String = piece[0]
			var font: Font = _face(piece[2])
			while not text.is_empty():
				var cut: int = text.length()
				while cut > 0 and x + font.get_string_size(text.left(cut), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > limit:
					cut -= 1
				if cut < text.length() and cut > 0:
					var space: int = text.left(cut).rfind(" ")
					if space > 0:
						cut = space + 1
				if cut == 0:
					if x <= 0.0:
						cut = 1
					else:
						rows.append(row)
						row = {"dot": null, "segs": []}
						x = 0.0
						continue
				var part: String = text.left(cut)
				row.segs.append([part, piece[1], piece[2]])
				x += font.get_string_size(part, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
				text = text.substr(cut)
				if not text.is_empty():
					rows.append(row)
					row = {"dot": null, "segs": []}
					x = 0.0
		rows.append(row)
	return rows

func _chat_max() -> int:
	if client == null:
		return 0
	return maxi(0, _chat_rows(client.battle, CHAT_TEXT_END - CHAT_TEXT_X - 12.0).size() - CHAT_ROWS)



func _brief(o: Vector2, battle) -> void :
	_exp_title(o)
	var award: Dictionary = battle.pvp_award
	var me: Dictionary = _self_stat()
	var looking: bool = me.is_empty()

	var goods: Array = [] if looking else rewards(award)
	var slots: int = maxi(int(Atlas.SLOT["min"]), goods.size())
	var cell: Vector2 = o + _v(Atlas.BRIEF["cvsItem"])
	var step: float = float(Atlas.SLOT["step"])
	for i in range(mini(slots, int(Atlas.SLOT["min"]))):
		_slot(cell + Vector2(step * i, 0), goods[i] if i < goods.size() else {})
	_fblit("pr_gold", o + _v(Atlas.GOLD))
	var vip: bool = is_vip(client.character)
	var coin: Array = [] if looking else me.get("m_coinVec", [])
	var char_exp: Array = [] if looking else me.get("m_expVec", [])
	_bar(o + _v(Atlas.BRIEF["frmCoinProgress"]), coin, vip)
	_bar(o + _v(Atlas.BRIEF["frmExpPercent"]), char_exp, vip)
	_award_num(o, "lblCoin", str(0 if looking else stat_of(me.get("m_iStatData", []), DATA_STAT_COIN)))
	_award_num(o, "lblExp", str(0 if looking else stat_of(me.get("m_iStatData", []), DATA_STAT_EXP)))
	_award_num(o, "lblMerit", str(0 if looking else int(me.get("m_iTeamMerit", 0))))



func _award_num(o: Vector2, key: String, text: String) -> void :
	var spec: Array = Atlas.TEXTS[key]
	var px: float = float(spec[4])
	_fwords(text, ARIAL_BOLD, px, Color(str(spec[5])), "r", o + Vector2(float(spec[0]), float(spec[1]) - 2.0 - px * 0.55), float(spec[2]))


func _exp_title(o: Vector2) -> void :
	if _exp.is_empty():
		return
	var level: int = int(_exp.level)
	var need: int = int(_exp.next)

	_fblit("level_%d" % clampi(level, 0, 40), o + _v(Atlas.BRIEF["frmCurrentLevel"]), 64.0, 32.0)
	if need != -1 and level + 1 <= 40:
		_fblit("level_%d" % (level + 1), o + _v(Atlas.BRIEF["frmNextLevel"]), 64.0, 32.0)
	var title: Vector2 = o + _v(Atlas.BRIEF["frmExpTitle"]) + Vector2(float(Atlas.EXP_BAR[0]), float(Atlas.EXP_BAR[1]))
	var bar: Vector2 = Vector2(float(Atlas.EXP_BAR[2]), float(Atlas.EXP_BAR[3]))
	if need <= 0:
		_fpart("pr_xp", title, Rect2(Vector2(0, 99 * bar.y), bar))
		_label(o, "lblCurrentExp", FULL)
		_label(o, "lblNextExp", FULL)
		_label(o, "lblAtk2", "/")
		return
	var now: float = maxf(0.0, float(_exp.cur))
	var frame: int = clampi(roundi(100.0 * now / need), 1, 100)
	_fpart("pr_xp", title, Rect2(Vector2(0, (frame - 1) * bar.y), bar))
	_label(o, "lblExpRate", "%.2f" % (100.0 * now / need))
	_label(o, "lblAtk0", "%")
	_label(o, "lblCurrentExp", str(int(now)))
	_label(o, "lblAtk2", "/")
	_label(o, "lblNextExp", str(need))


func _slot(at: Vector2, good: Dictionary) -> void :
	if good.is_empty():
		_fblit("pr_slot_lose", at)
		return
	_fblit("pr_slot", at)
	var row: Array = pack.bag.get("items", {}).get(str(int(good.id)), [])
	var quality: int = int(row[3]) if row.size() > 3 else 1
	_fblit("pr_q_" + str(Atlas.QUALITY[clampi(quality, 1, 5) - 1]), at + _v(Atlas.SLOT["quality"]))
	var key: String = str(row[2]) if row.size() > 2 else ""
	if not key.is_empty():
		var picture: Texture2D = pack.picture(("l/av/" if row.size() > 5 and int(row[5]) == 4 else "l/it/") + key + ".webp")
		if picture != null:
			var spot: Array = Atlas.SLOT["item"]
			draw_texture_rect(picture, Rect2((at + Vector2(float(spot[0]), float(spot[1]))) * _f, Vector2(float(spot[2]), float(spot[3])) * _f), false)
	var edge: Array = Atlas.SLOT["count"]
	_fwords("x %d" % int(good.count), ARIAL_BOLD, 14.0, Color.WHITE, "r", at + Vector2(float(edge[0]) - 70.0, float(edge[1])), 70.0, 1.0)
	var mark: String = str(Atlas.SIGNS.get(str(good.get("sign", "")), ""))
	if not mark.is_empty():
		_fblit(mark, at + _v(Atlas.SLOT["sign"]))


func _bar(at: Vector2, groups: Array, vip: bool) -> void :
	var share: Dictionary = shares(groups, vip)
	var pct: Array = share.pct
	var xs: Array = share.x
	var scores: Array = share.scores
	if int(share.total) == 0:
		_fblit("pr_fill_base", at + Vector2(3, 3), BAR_WIDTH - 3.0, 24.0)
	else:
		for i in range(SHARES.size()):
			if float(pct[i]) <= 0.0:
				continue
			var fill: String = "pr_fill_" + str(SHARES[i][0])
			if i == SHARES.size() - 1 and not vip:
				fill = "pr_fill_gray"
			_fblit(fill, at + Vector2(float(xs[i]), 3), minf(BAR_WIDTH * float(pct[i]), BAR_WIDTH - float(xs[i])), 24.0)
	_fblit("pr_bar", at)
	if int(share.total) == 0:
		_bar_label("+0", Color(str(Atlas.BAR_TEXTS["lblBase"][5])), at + Vector2(3, 4), BAR_WIDTH, ARIAL_BOLD)
		return
	for i in range(SHARES.size()):
		if float(pct[i]) == 0.0:
			continue
		var key: String = str(SHARES[i][1])
		var tone: Color = Color(str(Atlas.BAR_TEXTS[key][5]))
		var font: Font = ARIAL_BOLD
		if key == "lblVip" and not vip:
			tone = Color.WHITE
			font = _italic
		_bar_label("%s+%d" % [str(SHARES[i][2]), int(scores[i])], tone, at + Vector2(float(xs[i]), 4), BAR_WIDTH * float(pct[i]), font)



func _bar_label(text: String, tone: Color, at: Vector2, wide: float, font: Font) -> void :
	var font_size: int = maxi(6, roundi(14.0 * _f))
	var middle: float = (at.y + 2.0 + 14.0 * 0.55) * _f + (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	draw_string(font, Vector2(at.x * _f, middle), fit_label(text, font, font_size, (wide - BAR_LABEL_PAD) * _f), HORIZONTAL_ALIGNMENT_CENTER, wide * _f, font_size, tone)


static func fit_label(text: String, font: Font, font_size: int, room: float) -> String:
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= room:
		return text
	var cut: String = text
	while cut.length() > 1 and font.get_string_size(cut + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
		cut = cut.substr(0, cut.length() - 1)
	return cut.strip_edges(false, true) + "..."




func _open_report(target: int) -> void :
	if int(client.character.get("level", 1)) < REPORT_LEVEL:
		client.message_box.emit(TIP_496)
		return
	if int(client.limits.get(REPORT_LIMIT, 0)) >= REPORT_MAX:
		client.message_box.emit(TIP_495)
		return
	for row: Dictionary in players(client.battle.outcome, client.battle.roster, client.battle.names):
		if int(row.id) == target:
			_report = row
			_reasons = 0
			_typing.release_focus()
			_block(true)
			return


func _block(on: bool) -> void :
	for button: Variant in buttons.values():
		if button is Control:
			(button as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE if on else Control.MOUSE_FILTER_STOP

func _close_report() -> void :
	if _report.is_empty():
		return
	_report = {}
	_reasons = 0
	_block(false)

func _report_click(id: String) -> void :
	if id.begins_with("reason:"):
		var i: int = int(id.substr(7))
		if i >= 0 and i < Report.REASONS.size():
			_reasons ^= int(Report.REASONS[i][1])
	elif id == "gmr_ok":

		if _reasons == 0:
			say(GM_REPORT)
			return
		client.impeach(int(_report.id), str(_report.get("uuid", "")), str(_report.name), _reasons)
		_reported[int(_report.id)] = true
		_close_report()
	elif id == "gmr_close":
		_close_report()


func _report_window() -> void :
	var at: Vector2 = _window(float(Report.FRAME[0]), float(Report.FRAME[1]), "gmr_close")
	_fblit("gmr_title", at + _v(Report.NODES["title"]))
	_fblit("gmr_player", at + _v(Report.NODES["player"]))
	var row: Dictionary = _report
	_portrait(int(row.tank), int(row.ext), int(row.level), int(row.halo), at + _v(Report.AVATAR["centre"]), float(Report.AVATAR["zoom"]))
	var rank: Array = Report.NODES["level"]
	_fblit("level_%d" % clampi(int(row.get("char_level", 1)), 0, 40), at + _v(rank), float(rank[2]), float(rank[3]))
	var name: Array = Report.NAME
	_fwords(str(row.name), ARIAL_BOLD if int(name[6]) == 1 else ARIAL, float(name[4]), Color(str(name[5])), str(name[7]), at + _v(name), 
		float(name[2]), 0.0, float(name[3]))
	var box: Dictionary = Report.REASON_BOX
	var text: Array = box["text"]
	var icon: Vector2 = _v(box["icon"])
	var font_size: int = maxi(6, roundi(float(text[0]) * _f))
	for i in range(Report.REASONS.size()):
		var spot: Vector2 = at + Vector2(float(box["x"][i % 2]), float(box["y"]) + float(box["step"]) * float(i >> 1))
		var on: bool = (_reasons & int(Report.REASONS[i][1])) != 0
		var id: String = "reason:%d" % i
		_fblit("gmr_check_on" if on else "gmr_check_off", spot, 0.0, 0.0, _glow(id))
		var words: String = str(Report.REASONS[i][0])
		var wide: float = ARIAL_BOLD.get_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f + 4.0
		_fwords(words, ARIAL_BOLD, float(text[0]), Color(str(text[1])), "l", spot + Vector2(icon.x + float(box["gap"]), 0), wide, 0.0, icon.y, false)
		_hit(id, Rect2(spot * _f, Vector2(icon.x + float(box["gap"]) + wide, icon.y) * _f), false)
	var warn: Array = Report.WARN
	_fwords(REPORT_WARN, ARIAL_BOLD, float(warn[1]), Color(str(warn[2])), "c", at + Vector2(0, float(warn[0])), float(Report.FRAME[0]), 0.0, 0.0, false)
	_fbutton("gmr_ok", "gmr_confirm", at + _v(Report.NODES["confirm"]))




static func restraint_of(tank_id: int) -> int:
	return int(Restraint.OPPOSE.get(str(tank_id), [0, ""])[0])

func _tank_known(tank_id: int) -> bool:
	return pack != null and pack.lobby.get("tanks", {}).has(str(tank_id))

func _close_restraint() -> void :
	if _restraint <= 0:
		return
	_restraint = 0
	_block(false)

func _restraint_click(id: String) -> void :
	if id == "rt_close":
		_close_restraint()
	elif id == "rt_buy":

		var target: int = _restraint
		if not owns(client.tanks, target):
			if not tank_buy_asked.get_connections().is_empty():
				tank_buy_asked.emit(target)
			else:
				say(BUY_TIP)
			_close_restraint()


func _restraint_window() -> void :
	var at: Vector2 = _window(float(Restraint.SIZE[0]), float(Restraint.SIZE[1]), "rt_close")
	_fwords(Restraint.TITLE, ARIAL_BOLD, 18.0, RT_TITLE, "c", at + Vector2(0, 14), float(Restraint.SIZE[0]), 1.0, 28.0)
	for key: String in ["name", "inner"]:
		var box: Array = Restraint.BOXES[key]
		_round(Rect2((at + _v(box)) * _f, Vector2(float(box[2]), float(box[3])) * _f), RT_BOX, 6.0)
	_fblit("rt_stage", at + _v(Restraint.STAGE))
	var target: int = _restraint
	_portrait(target, 0, 1, 0, at + _v(Restraint.AVATAR["at"]), float(Restraint.AVATAR["zoom"]))
	var name: Array = Restraint.TEXTS["lblName"]
	var box: Array = Restraint.BOXES["name"]
	_fwords(GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(target), ""))), ARIAL_BOLD, float(name[4]), Color(str(name[5])), "c", 
		at + _v(box), float(box[2]), 0.0, float(box[3]))
	var desc: Array = Restraint.TEXTS["txtDesc"]
	var words: String = str(Restraint.OPPOSE.get(str(_mvp_tank()), [0, ""])[1])
	var px: float = float(desc[4])
	while px > 10.0 and _face(ARIAL_BOLD).get_multiline_string_size(words, HORIZONTAL_ALIGNMENT_LEFT, float(desc[2]) * _f, maxi(6, roundi(px * _f))).y > float(desc[3]) * _f:
		px -= 1.0
	_fpara(words, ARIAL_BOLD, px, Color(str(desc[5])), at + _v(desc), float(desc[2]))
	var buy: Vector2 = at + _v(Restraint.NODES["btnBuy"])
	if owns(client.tanks, target):
		_fblit("rt_owned", buy)
	else:
		_fbutton("rt_buy", "rt_buy", buy)

func _mvp_tank() -> int:
	return int(_brief_of(client.battle.roster, mvp(client.battle.outcome)).get("otherData", {}).get("tankId", 0))



func _tank(o: Vector2, battle) -> void :
	var mvp_id: int = mvp(battle.outcome)
	var brief: Dictionary = _brief_of(battle.roster, mvp_id)
	if mvp_id == 0 or brief.is_empty():
		return
	var other: Dictionary = brief.get("otherData", {})
	var tank_id: int = int(other.get("tankId", 0))
	var view: Array = Atlas.NODES["viewTank"]
	_portrait(tank_id, int(other.get("tankExternal", 0)), int(other.get("tankLevel", 1)), 0, 
		o + Vector2(float(view[0]) + float(view[2]) / 2.0, float(view[1]) + float(view[3]) / 2.0), 1.0)
	_label(o, "lblCharName", str(brief.get("charData", {}).get("szName", "")))
	_label(o, "lblTankName", GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(tank_id), ""))))
	var honors: Array = []
	for pair: Array in [["m_nKiller", "pr_honor_killer"], ["m_nAssister", "pr_honor_assist"], ["m_nKDA", "pr_honor_kda"]]:
		if int(battle.outcome.get(pair[0], 0)) == mvp_id:
			honors.append(pair[1])
	for i in range(honors.size()):
		_fblit(str(honors[i]), o + Vector2(757 + float(Atlas.HONOR[0]) * i, 351))
	if owns(client.tanks, tank_id):
		_fblit("pr_buy_off", o + _v(Atlas.NODES["btnBuy"]))
	else:
		_fbutton("buy", "pr_buy", o + _v(Atlas.NODES["btnBuy"]))
	_fbutton("oppose", "pr_oppose", o + _v(Atlas.NODES["btnOppose"]))



func _self_stat() -> Dictionary:
	if client == null:
		return {}
	for row: Dictionary in client.battle.outcome.get("m_tankVec", []):
		if int(row.get("m_charOid", 0)) == int(client.battle.self_id):
			return row
	return {}

static func stat_of(values: Array, index: int) -> int:
	return int(values[index]) if index < values.size() else 0


static func is_vip(character: Dictionary) -> bool:
	return maxi(int(character.get("vipTime", 0)), int(character.get("superVipTime", 0))) > int(Time.get_unix_time_from_system())


static func owns(tanks: Dictionary, tank_id: int) -> bool:
	for inst: Variant in tanks.values():
		if inst is Dictionary and int(inst.get("m_tpltId", 0)) == tank_id and int(inst.get("m_contType", -1)) == GarageModel.OWN:
			return true
	return false

static func _brief_of(roster: Array, id: int) -> Dictionary:
	for brief: Variant in roster:
		if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) == id:
			return brief
	return {}


static func players(outcome: Dictionary, roster: Array, names: Dictionary) -> Array:
	var rows: Array = []
	for pair: Array in [[outcome.get("m_tankVec", []), false], [outcome.get("m_escapeVec", []), true]]:
		for stat: Dictionary in pair[0]:
			var id: int = int(stat.get("m_charOid", 0))
			var brief: Dictionary = _brief_of(roster, id)
			if brief.is_empty():
				continue
			var values: Array = stat.get("m_iStatData", [])
			var other: Dictionary = brief.get("otherData", {})
			rows.append({"id": id, "name": str(names.get(id, brief.get("charData", {}).get("szName", ""))), 
				"camp": int(stat.get("m_camp", brief.get("bCamp", 0))), "leave": pair[1], "index": rows.size(), 
				"dead": stat_of(values, 0), "kill": stat_of(values, 1), "score": stat_of(values, 2), 
				"assist": stat_of(values, 3), "tank": int(other.get("tankId", 0)), "ext": int(other.get("tankExternal", 0)), 
				"level": int(other.get("tankLevel", 1)), "halo": int(other.get("haloId", 0)), 
				"uuid": str(brief.get("charData", {}).get("szCharUuid", "")), "char_level": int(brief.get("charData", {}).get("bLevel", 1)), 
				"new_elo": int(stat.get("m_iNewElo", 0)), "old_elo": int(stat.get("m_iOldElo", 0)), "section": int(stat.get("m_eloSectionId", 0))})
	rows.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		if a.score != b.score: return a.score > b.score
		if a.kill != b.kill: return a.kill > b.kill
		if a.dead != b.dead: return a.dead < b.dead
		return a.index < b.index)
	return rows


static func split(rows: Array, self_id: int) -> Dictionary:
	var top: int = 2
	for row: Dictionary in rows:
		if int(row.id) == self_id and int(row.camp) == 1:
			top = 1
	var mine: Array = []
	var others: Array = []
	for row: Dictionary in rows:
		if int(row.camp) == top:
			if int(row.id) == self_id:
				mine.push_front(row)
			else:
				mine.append(row)
		else:
			others.append(row)
	return {"self": mine, "other": others, "top": top}


static func mvp(outcome: Dictionary) -> int:
	var winner: Dictionary = {}
	var loser: Dictionary = {}
	for key: String in ["m_tankVec", "m_escapeVec"]:
		for row: Dictionary in outcome.get(key, []):
			var id: int = int(row.get("m_charOid", 0))
			if id == int(outcome.get("m_nVictoryMvp", 0)) and winner.is_empty():
				winner = row
			if id == int(outcome.get("m_nDefeatMvp", 0)) and loser.is_empty():
				loser = row
	if winner.is_empty() or loser.is_empty():
		return 0
	if stat_of(winner.get("m_iStatData", []), 2) >= stat_of(loser.get("m_iStatData", []), 2):
		return int(winner.m_charOid)
	return int(loser.m_charOid)



static func gold_groups(award: Dictionary) -> Array:
	var out: Array = []
	for group: Dictionary in award.get("m_info", {}).get("m_settleItemVec", []):
		var count: int = 0
		for item: Dictionary in group.get("m_itemVec", []):
			if int(item.get("m_itemId", 0)) == PVP_COIN:
				count += int(item.get("m_count", 0))
		if count > 0:
			out.append({"m_type": int(group.get("m_nType", 0)), "m_value": count})
	return out

static func _settle(award: Dictionary, kind: int) -> Array:
	for group: Dictionary in award.get("m_info", {}).get("m_settleItemVec", []):
		if int(group.get("m_nType", -1)) == kind:
			return group.get("m_itemVec", [])
	return []


static func rewards(award: Dictionary) -> Array:
	var out: Array = []
	var base: Dictionary = {}
	for kind: int in [ST_BASE, ST_ROOM]:
		for item: Dictionary in _settle(award, kind):
			var id: int = int(item.get("m_itemId", 0))
			if id != PVP_COIN:
				base[id] = int(base.get(id, 0)) + int(item.get("m_count", 0))
	for id: int in base:
		out.append({"id": id, "count": base[id], "sign": ""})
	for pair: Array in [[ST_DAILY, "daily"], [ST_VIP, "vip"], [ST_DOUBLE, "double"], [ST_DECORATE, "decorate"], [ST_ACT, "act"]]:
		for item: Dictionary in _settle(award, int(pair[0])):
			if int(item.get("m_itemId", 0)) != PVP_COIN:
				out.append({"id": int(item.get("m_itemId", 0)), "count": int(item.get("m_count", 0)), "sign": pair[1]})
	return out


static func shares(groups: Array, vip: bool) -> Dictionary:
	var base: int = 0
	var act: int = 0
	var vip_add: int = 0
	var twice: int = 0
	var daily: int = 0
	var avatar: int = 0
	var ornament: int = 0
	for group: Dictionary in groups:
		var value: int = int(group.get("m_value", 0))
		match int(group.get("m_type", -1)):
			ST_BASE, ST_ROOM:
				base += value
			ST_ACT:
				act = value
			ST_VIP:
				vip_add = value
			ST_DOUBLE, ST_TANK_EXP_CARD:
				twice = value
			ST_DAILY:
				daily = value
			ST_AVATAR:
				avatar = value
			ST_DECORATE:
				ornament = value
	if not vip:
		vip_add = int(base * Atlas.VIP_ADD_EXP / 100.0)
	var scores: Array = [base, act, twice, avatar, ornament, daily, vip_add]
	var total: int = 0
	var count: int = 0
	for score: int in scores:
		total += score
		if score != 0:
			count += 1
	var pct: Array = []
	var xs: Array = []
	if total == 0:
		for i in range(scores.size()):
			pct.append(1.0 if i == 0 else 0.0)
			xs.append(3.0 if i == 0 else 0.0)
		return {"scores": scores, "total": 0, "pct": pct, "x": xs}
	var each: float = MIN_SCALE
	if count * each > 1.0 - MIN_SCALE:
		each = (1.0 - MIN_SCALE) / count
	var rest: float = 1.0 - each * count
	var has_min: bool = false
	for score: int in scores:
		var part: float = each + float(score) / float(total) * rest if score != 0 else 0.0
		if part < MIN_SCALE and score != 0:
			has_min = true
		pct.append(part)
	for i in range(pct.size()):
		if float(pct[i]) > MAX_SCALE and has_min:
			var extra: float = float(pct[i]) - MAX_SCALE
			var takers: int = 0
			for value: float in pct:
				if value != 0.0 and value < MAX_SCALE:
					takers += 1
			if takers > 0:
				for j in range(pct.size()):
					if float(pct[j]) != 0.0 and float(pct[j]) < MAX_SCALE:
						pct[j] = float(pct[j]) + extra / takers
			pct[i] = MAX_SCALE
	var x: float = 0.0
	for i in range(pct.size()):
		if i > 0:
			x += BAR_WIDTH * float(pct[i - 1])
		xs.append(x)
	return {"scores": scores, "total": total, "pct": pct, "x": xs}


static func need_exp(level: int) -> int:
	return int(Atlas.NEED_EXP[level]) if level >= 0 and level < Atlas.NEED_EXP.size() else -1


static func exp_start(level: int, exp: int, pool: int) -> Dictionary:
	var up: bool = exp < pool
	var shown: int = level - 1 if up else level
	var need: int = need_exp(shown)
	var now: int = need + exp - pool if up else exp - pool
	return {"pool": pool, "per": pool / float(EXP_FRAMES), "added": 0.0, "level": shown, "cur": float(now), "next": need, 
		"left": EXP_FRAMES, "char_level": level, "char_exp": exp, "run": need > 0}


static func exp_step(state: Dictionary) -> void :
	if not bool(state.get("run", false)):
		return
	if int(state.left) <= 0 or int(state.next) <= 0:
		state.cur = float(state.char_exp)
		state.level = int(state.char_level)
		state.next = maxi(0, need_exp(int(state.level)))
		state.run = false
		return
	if float(state.cur) >= float(state.next):
		state.cur = float(state.cur) - float(state.next)
		state.level = int(state.level) + 1
		state.next = maxi(0, need_exp(int(state.level)))
	var step: float = minf(float(state.per), float(state.pool) - float(state.added))
	state.cur = float(state.cur) + step
	state.added = float(state.added) + step
	state.left = int(state.left) - 1
