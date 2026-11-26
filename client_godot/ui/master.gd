extends "master_task_draw.gd"














const Atlas = preload("master_atlas.gd")
const CTip = preload("ctool_tip.gd")
const LB = preload("leaderboard_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Arena = preload("arena_atlas.gd")
const FriendsAtlas = preload("friends_atlas.gd")
const HallScreen = preload("hall_screen.gd")
const NameStyles = preload("name_styles.gd")
const OpenUi = preload("open_ui_note.gd")
const Model = preload("master_model.gd")
const MasterReward = preload("master_reward.gd")

signal closed
signal player_info_asked(uuid: String)

const UI_MASTER_PRENTICE: int = 21
const SHOW_IN: Array = ["lobby", "hall", "room"]
const DIM: Color = Color(0, 0, 0, 0.4)
const ASK_SIZE: Vector2 = Vector2(450, 220)
const CARD_ROWS: int = 5
const FIND_ROWS: int = 10
const APPLY_ROWS: int = 9
const HELPER_RIM: Color = Color("005797")
const FIND_INK: Color = Color("ff8f22")
const FIND_RIM: Color = Color("6c400b")
const NO_TIP_GLOW: Color = Color("0390d3", 0.8)
const AMITY: String = "Điểm Tình: @num1@"
const AMITY_TIP: String = "Điểm Tình"
const LAST_LOGIN: String = "T/g login trước: @time@"
const ASK_PRENTICE: String = "Giải trừ quan hệ thầy trò với @name@ sẽ xóa Điểm Tình của đôi bên, và trong 24 giờ kế không thể thu học trò mới"
const ASK_MASTER: String = "Giải trừ quan hệ thầy trò với @name@ sẽ xóa Điểm Tình của đôi bên, và trong 24 giờ kế không thể bái sư"
const ASK_GONE: String = "Giải trừ quan hệ thầy trò với @name@"
const LIMIT: String = "Đạt giới hạn học trò"
const NO_MASTER: String = "Sư phụ không online\nHãy thử lại sau\nLv18 được Bái Sư Thu Đồ rồi"
const TITLE: String = "Hệ thống Sư Đồ"
const HELP: String = "1. Học trò có thể chọn thầy và bái sư, thầy chủ động đi tìm học trò.\n2. Người chơi dưới lv18 chỉ có thể làm học trò đi bái sư.\n3. Người chơi từ lv18 trở lên có thể làm thầy và nhận học trò.\n4. Khi học trò đạt lv18 sẽ tự động xuất sư, nhận thưởng xuất sư, gửi qua thư.\n5. Khi học trò xuất sư, thầy cũng được quà, gửi qua thư.\n6. Thưởng xuất sư căn cứ điểm Tình nhiều hay ít mà quà lớn hay nhỏ.\n7. Điểm tình chia thành 3 bậc, dưới 4500, từ 4500-7k, 7k trở lên\n8. Thầy và trò có thể tổ đội làm PB, đánh PVE, làm nv mỗi ngày để tăng điểm Tình.\n9. Học trò nạp tiền thầy sẽ được nhận 5% xu khóa."
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."
const SEX: Array = ["Nữ", "Nam"]
const GREY: Vector3 = Vector3(0.3086, 0.6094, 0.082)
const MAIN_QUEST: Array = [286, 105, 491, 388]
const PULL: float = 76.0

var _state: String = ""
var _apply: bool = false
var _help: bool = false
var _ask: Dictionary = {}
var _sel: int = 0
var _page: int = 1
var _apply_top: int = 0
var _find_base: int = -1
var _real_base: int = -1
var _seen_master: int = -1
var _seen_prentice: int = -1
var _seen_apply: int = -1
var _seen_find: int = -1
var _ui_wait: bool = false
var _tips: Array = []
var _ctip: CTip = CTip.new()
var _quest: Array = []
var _quest_on: bool = false
var _quest_uuid: String = ""
var _qtop: int = 0
var _qrect: Rect2 = Rect2()
var _qbar: Array = []
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_top: float = 0.0
var _pull: float = 0.0
var _seen_quest: int = -1
var _reward: Control = null
var _grey: Dictionary = {}
var now_override: int = 0

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)
	var lb: Dictionary = {}
	for key: String in LB.R:
		if key.begins_with("lb_v") or key.begins_with("lb_sv"):
			lb[key] = LB.R[key]
	_use(LB.FILE, lb)
	var levels: Dictionary = {}
	for key: String in Hall.R:
		if key.begins_with("level_"):
			levels[key] = Hall.R[key]
	_use(Hall.FILE, levels)
	var arena: Dictionary = {}
	for key: String in Arena.R:
		if key.begins_with("public_"):
			arena[key] = Arena.R[key]
	_use(Arena.FILE, arena)
	var ask: Dictionary = {}
	for key: String in FriendsAtlas.R:
		if key.begins_with("fr_ask"):
			ask[key] = FriendsAtlas.R[key]
	_use(FriendsAtlas.FILE, ask)
	_use_task()
	if client != null:
		client.changed.connect(_follow)


func open() -> void :
	_state = ""
	_apply = false
	_help = false
	_ask = {}
	_sel = 0
	_page = 1
	_apply_top = 0
	_quest = []
	_quest_on = false
	_quest_uuid = ""
	_qtop = 0
	_grab = false
	_toast = ""
	_hover = ""
	_press = ""
	var m: Model = _model()
	if m != null:
		_sync(m)
		_seen_master = m.master_rev
		_seen_prentice = m.prentice_rev
		_seen_apply = m.apply_rev
		_seen_find = m.find_rev
		_seen_quest = m.quest_rev
		if pack != null:
			pack.load_bag()
	visible = true
	_ui_wait = client != null and OpenUi.note(client, pack, UI_MASTER_PRENTICE) == OpenUi.WAIT
	_enter(_state_for())

func close() -> void :
	if not visible:
		return
	visible = false
	_state = ""
	_apply = false
	_help = false
	_ask = {}
	_ui_wait = false
	_grab = false
	if _reward != null:
		_reward.close()
	closed.emit()

func chat_busy() -> bool:
	return visible

func state() -> String:
	return _state

func apply_open() -> bool:
	return _apply

func help_open() -> bool:
	return _help

func asking() -> Dictionary:
	return _ask


func quest_rows() -> Array:
	return _quest

func quest_shown() -> bool:
	return _quest_on

func quest_uuid() -> String:
	return _quest_uuid

func reward_window() -> Control:
	return _reward

func reward_open() -> bool:
	return _reward != null and _reward.visible

func _has_point(_point: Vector2) -> bool:
	return visible

func _follow() -> void :
	if visible and (client == null or client.state not in SHOW_IN):
		close()

func _model() -> Model:
	if client == null:
		return null
	var m: Variant = client.get("master")
	return m as Model if m is Model else null


func _sync(m: Model) -> void :
	if client == null:
		return
	m.level = int(client.character.get("level", m.level))
	if not str(client.char_uuid).is_empty():
		m.my_uuid = str(client.char_uuid)


func _state_for() -> String:
	var m: Model = _model()
	if m == null:
		return "main"
	_sync(m)
	if m.have_master():
		return "student"
	if m.has_prentice():
		return "main"
	if m.level < Model.GRADUATE_LEVEL:
		return "find"
	return "main"

func _enter(want: String) -> void :
	if want == _state:
		return
	_state = want
	_sel = 0
	_quest = []
	_quest_on = false
	_quest_uuid = ""
	_qtop = 0
	if want in ["main", "student"]:
		_refresh_quest()
	if want == "find":

		_page = 1
		var m: Model = _model()
		_find_base = m.find_rev if m != null else -1
		_send(708, Model.square_list(Model.PLT_MASTERLIST, _page), false)

func _now() -> int:
	return now_override if now_override > 0 else int(Time.get_unix_time_from_system())


func _send(type: int, body: PackedByteArray, loud: bool = true) -> bool:
	var ok: bool = client != null and client.has_method("master_send") and bool(client.call("master_send", type, body))
	if not ok and loud:
		say(OFFLINE)
	return ok

func _tick(_delta: float) -> void :
	if _ui_wait and client != null and OpenUi.note(client, pack, UI_MASTER_PRENTICE) != OpenUi.WAIT:
		_ui_wait = false
	var m: Model = _model()
	if m == null:
		return
	_sync(m)
	if m.master_rev != _seen_master:

		_seen_master = m.master_rev
		_enter(_state_for())
	if m.prentice_rev != _seen_prentice:

		_seen_prentice = m.prentice_rev
		_sel = 0
		if _state == "main":
			_refresh_quest()
	if m.quest_rev != _seen_quest:

		_seen_quest = m.quest_rev
		if _state in ["main", "student"]:
			_refresh_quest()
	if m.apply_rev != _seen_apply:

		_seen_apply = m.apply_rev
		if _apply:
			_send(716, Model.apply_list_request(), false)
	if m.find_rev != _seen_find:
		_seen_find = m.find_rev
		if _state == "find":
			_page = maxi(1, m.find_page)


func _refresh_quest() -> void :
	var m: Model = _model()
	if m == null:
		return
	var uuid: String = ""
	if _state == "student":
		uuid = str(Model._dict(m.master.get("m_brief", {})).get("m_charUuid", ""))
		if uuid.is_empty() or not m.quests.has(uuid):
			return
	elif _sel >= 0 and _sel < m.prentices.size():
		uuid = str(Model._dict(Model._dict(m.prentices[_sel]).get("m_brief", {})).get("m_charUuid", ""))
	if uuid.is_empty() or not m.quests.has(uuid):
		_quest = []
		_quest_on = false
		_quest_uuid = ""
		_qtop = 0
		return
	_quest = m.sort_quests(uuid)
	_quest_on = true
	_quest_uuid = uuid
	_qtop = 0


func quest_row(info: Dictionary, k: int) -> Dictionary:
	var cond: Variant = TaskAtlas.CONDS.get(str(int(info.get("m_nQuestId", 0))))
	if not (cond is Array):
		return {"title": "", "award": false}
	var m: Model = _model()
	var award: int = int(cond[4]) if m != null and m.have_master() else int(cond[3])
	var has_award: bool = TaskAtlas.AWARDS.has(str(award))
	var state: int = int(info.get("m_nState", 0))
	return {"title": str(cond[0]), 
		"check": CHECK.replace("@num1@", str(int(info.get("m_nCheckCount", 0)))).replace("@num2@", str(int(cond[1]))), 
		"amity": AMITY_PLUS.replace("@num1@", str(int(cond[2]))) if int(cond[2]) > 0 else "", 
		"tick": state == Model.QST_OVER, "award": has_award, 
		"get": "quest_get:%d" % k if has_award and state == Model.QST_COMPLETE else "", 
		"tiles": award_tiles(award) if has_award else [], "thew": award_thew(award) if has_award else 0}


func _quest_high(info: Variant) -> float:
	var cond: Variant = TaskAtlas.CONDS.get(str(int(Model._dict(info).get("m_nQuestId", 0))))
	if not (cond is Array):
		return float(TaskAtlas.TASK[2])
	var m: Model = _model()
	var award: int = int(cond[4]) if m != null and m.have_master() else int(cond[3])
	return float(TaskAtlas.TASK[1]) if TaskAtlas.AWARDS.has(str(award)) else float(TaskAtlas.TASK[2])

func _quest_spot() -> Array:
	return Atlas.STUDENT["lstQuest"] if _state == "student" else MAIN_QUEST


func quest_max() -> int:
	var high: float = float(_quest_spot()[3])
	var used: float = 0.0
	var fit: int = 0
	for k in range(_quest.size() - 1, -1, -1):
		used += _quest_high(_quest[k])
		if used > high:
			break
		fit += 1
	return maxi(0, _quest.size() - maxi(1, fit))

func quest_top() -> int:
	return _qtop

func _quest_scroll(value: float) -> void :
	_qtop = clampi(roundi(value), 0, quest_max())

func _open_reward(amity: int) -> void :
	var m: Model = _model()
	if _reward == null:
		_reward = MasterReward.new()
		_reward.client = client
		_reward.pack = pack
		add_child(_reward)
		_reward.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_reward.open(amity, m != null and m.have_master())




func cards() -> Array:
	var m: Model = _model()
	return m.prentices if m != null else []


func find_rows() -> Array:
	var m: Model = _model()
	if m == null or m.find_rev == _find_base or m.find_type == 0:
		return []
	return m.find_list

func find_received() -> bool:
	var m: Model = _model()
	return m != null and m.find_rev != _find_base and m.find_type != 0


func apply_rows() -> Array:
	var m: Model = _model()
	if m == null or m.real_rev == _real_base:
		return []
	return m.real_apply

func apply_count() -> int:
	var m: Model = _model()
	return m.apply_list().size() if m != null else 0

func _frame_width() -> float:
	return float(Atlas.SIZES.get(_state if _state != "" else "main", [830, 520])[0])


func _frame() -> Vector2:
	return _stage() + Vector2(int((1000.0 - _frame_width()) / 2.0), int((600.0 - 520.0) / 2.0))

func _apply_at() -> Vector2:
	var size_apply: Array = Atlas.SIZES["apply"]
	return _frame() + Vector2(0.5 * (_frame_width() - float(size_apply[0])), 0.5 * (520.0 - float(size_apply[1])))



func _activate(id: String) -> void :
	var m: Model = _model()
	if not _ask.is_empty():
		match id:
			"ask_ok":

				var uuid: String = str(_ask.get("m_charUuid", ""))
				_ask = {}
				if not uuid.is_empty():
					_send(712, Model.delete_relation(uuid))
			"ask_no":
				_ask = {}
		return
	if _help:
		if id in ["cancel", "help_ok"]:
			_help = false
		return
	if _apply:
		if id == "apply_close":
			_apply = false
		elif id.begins_with("apply_ok:"):
			var row: Dictionary = _apply_row(id)
			if row.is_empty() or m == null:
				return
			if m.prentices.size() < Model.PRENTICE_LIMIT:
				_send(710, Model.uuid_only(str(row.get("m_charUuid", ""))))
			else:
				say(LIMIT)
		elif id.begins_with("apply_no:"):
			var row: Dictionary = _apply_row(id)
			if row.is_empty() or m == null:
				return
			var uuid: String = str(row.get("m_charUuid", ""))
			if _send(711, Model.uuid_only(uuid)):
				m.del_apply(uuid)
		elif id.begins_with("apply_watch:"):
			var row: Dictionary = _apply_row(id)
			if not row.is_empty():
				player_info_asked.emit(str(row.get("m_charUuid", "")))
		return
	if id == "close":
		close()
	elif id == "help":
		_help = true
	elif id == "view_apply":
		_open_apply()
	elif id == "charge":

		var at: int = _sel
		_open_reward(int(Model._dict(m.prentices[at]).get("m_nAmity", 0)) if m != null and at >= 0 and at < m.prentices.size() else 0)
	elif id == "reward":

		_open_reward(int(m.master.get("m_nAmity", 0)) if m != null else 0)
	elif id.begins_with("card:"):

		var k: int = int(id.substr(5))
		if k != _sel:
			_sel = k
			_refresh_quest()
		_refresh_quest()
	elif id.begins_with("quest_get:"):

		var at: int = int(id.get_slice(":", 1))
		if at < 0 or at >= _quest.size() or _quest_uuid.is_empty():
			return
		_send(713, Model.award_request(_quest_uuid, int(Model._dict(_quest[at]).get("m_nQuestId", 0))))
	elif id == "qbar:up":
		_quest_scroll(_qtop - 1)
	elif id == "qbar:down":
		_quest_scroll(_qtop + 1)
	elif id == "qbar:pgup":
		_quest_scroll(_qtop - 2)
	elif id == "qbar:pgdn":
		_quest_scroll(_qtop + 2)
	elif id.begins_with("card_watch:") or id.begins_with("card_remove:"):
		var brief: Dictionary = _card_brief(id)
		if brief.is_empty():
			return
		if id.begins_with("card_watch:"):
			player_info_asked.emit(str(brief.get("m_charUuid", "")))
		else:
			_ask = brief
	elif id == "prev":
		if _page > 1:
			_page -= 1
			_send(708, Model.square_list(Model.PLT_MASTERLIST, _page))
	elif id == "next":
		_page += 1
		_send(708, Model.square_list(Model.PLT_MASTERLIST, _page))
	elif id.begins_with("find_watch:") or id.begins_with("find_get:"):
		var at: int = int(id.get_slice(":", 1))
		var rows: Array = find_rows()
		if at < 0 or at >= rows.size() or m == null:
			return
		var brief: Dictionary = rows[at] if rows[at] is Dictionary else {}
		var uuid: String = str(brief.get("szCharUuid", ""))
		if uuid.is_empty():
			return
		if id.begins_with("find_watch:"):
			player_info_asked.emit(uuid)
		else:

			var kind: int = Model.MAT_ENGAGE_MASTER if m.find_type == Model.PLT_MASTERLIST else Model.MAT_RECEIVE_PRENTICE
			_send(709, Model.apply_relation(uuid, kind))

func _open_apply() -> void :
	if _apply:
		return
	_apply = true
	_apply_top = 0
	var m: Model = _model()
	_real_base = m.real_rev if m != null else -1
	if m != null:
		_seen_apply = m.apply_rev
	_send(716, Model.apply_list_request(), false)

func _apply_row(id: String) -> Dictionary:
	var at: int = int(id.get_slice(":", 1))
	var rows: Array = apply_rows()
	if at < 0 or at >= rows.size() or not (rows[at] is Dictionary):
		return {}
	return rows[at]


func _card_brief(id: String) -> Dictionary:
	var at: int = int(id.get_slice(":", 1))
	var m: Model = _model()
	if m == null:
		return {}
	if at < 0:
		return Model._dict(m.master.get("m_brief", {}))
	if at >= m.prentices.size():
		return {}
	return Model._dict(Model._dict(m.prentices[at]).get("m_brief", {}))

func _wheel(step: int, at: Vector2) -> void :
	if _apply and _ask.is_empty() and not _help:
		_apply_top = clampi(_apply_top + step, 0, maxi(0, apply_rows().size() - APPLY_ROWS))
	elif not _apply and not _help and _ask.is_empty() and _qrect.has_point(at):
		_quest_scroll(_qtop + step)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _grab or _apply or _help or not _ask.is_empty() or not _qrect.has_point(from):
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, PULL * _f)
	while _pull >= pitch:
		_pull -= pitch
		_quest_scroll(_qtop + 1)
	while _pull <= - pitch:
		_pull += pitch
		_quest_scroll(_qtop - 1)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pull = 0.0
			if _hit_at(event.position) == "slide:qbar" and not _qbar.is_empty():
				_grab = true
				_grab_at = event.position
				_grab_top = float(_qtop)
		else:
			_grab = false
	elif event is InputEventMouseMotion and _grab:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_grab = false
		else:
			var step: float = maxf(0.001, (float(_qbar[0]) - float(_qbar[1])) / float(_qbar[2]))
			_quest_scroll(_grab_top + (event.position.y - _grab_at.y) / _f / step)
			accept_event()
			return
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		if not _ask.is_empty():
			_ask = {}
		elif _help:
			_help = false
		elif _apply:
			_apply = false
		else:
			close()
		get_viewport().set_input_as_handled()




func _label(spec: Array, text: String, o: Vector2, mid: bool, tint: Color = Color(0, 0, 0, 0), rim: Color = SHADE, edge: float = 1.0) -> void :
	if text.is_empty():
		return
	var wide: float = float(spec[2])
	var left: float = float(spec[0])
	var align: String = str(spec[7])
	if wide <= 0.0:
		wide = 600.0
		if align == "c":
			left -= 300.0
		elif align == "r":
			left -= 600.0
	var top: float = float(spec[1]) - (12.0 if mid else 0.0)
	var ink: Color = Color(str(spec[5])) if tint.a <= 0.0 else tint
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), ink, align, o + Vector2(left, top), wide, edge, 24.0 if mid else 0.0, float(spec[2]) > 0.0, rim)


func _para(text: String, font: Font, px: float, color: Color, at: Vector2, wide: float, high: float, rim: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void :
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	var lines: int = maxi(1, int(high * _f / face.get_height(font_size)))
	var origin: Vector2 = Vector2(at.x, at.y + 2.0) * _f + Vector2(0, face.get_ascent(font_size))
	draw_multiline_string_outline(face, origin, text, align, wide * _f, font_size, lines, maxi(1, roundi(_f)), rim)
	draw_multiline_string(face, origin, text, align, wide * _f, font_size, lines, color)

func _small_vip(vip: int, at: Vector2) -> void :
	var level: int = clampi(vip % 100, 0, 15)
	if level > 0:
		_fblit(("lb_sv%d" if vip >= 100 else "lb_v%d") % level, at)

func _level(level: int, at: Vector2) -> void :
	_fblit("level_%d" % clampi(level, 0, 40), at, 40.0, 20.0)
	_level_fx(level, at, 40.0)

func _tip(rect: Rect2, text: String) -> void :
	if not text.is_empty():
		_tips.append([rect, text])

func _paint() -> void :
	_tips = []
	_item_tip = []
	_qbar = []
	_qrect = Rect2()
	_clip = Rect2()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _frame()
	var panel: String = {"main": "ms_main", "student": "ms_student", "find": "ms_find"}.get(_state, "ms_main")
	var frame: Rect2 = _fblit(panel, o + _v(Atlas.PANELS.get(_state if _state != "" else "main", [19, 0])))
	_hit("panel", frame, false)
	match _state:
		"student":
			_paint_student(o)
		"find":
			_paint_find(o)
		_:
			_paint_main(o)
	var open_layer: bool = _apply or _help or not _ask.is_empty()
	if _apply:
		_paint_apply()
	if _help:
		_paint_help()
	if not _ask.is_empty():
		_paint_ask()
	if not open_layer and not reward_open():
		_paint_tip()
		_draw_item_tip()

func _paint_main(o: Vector2) -> void :
	var n: Dictionary = Atlas.MAIN
	var list: Array = n["list"]
	var all: Array = cards()
	for i in range(mini(all.size(), CARD_ROWS)):
		var info: Dictionary = Model._dict(all[i])
		_paint_card(o + Vector2(float(list[0]), float(list[1]) + 75.0 * i), info, i, i == _sel, "ms_card_discard")
	if _quest_on:
		_paint_quests(o)
	else:
		_para(HELP, ARIAL_BOLD, 12.0, Color.WHITE, o + _v(Atlas.MAIN_TEXT["txtHelper"]), float(Atlas.MAIN_TEXT["txtHelper"][2]), 
			float(Atlas.MAIN_TEXT["txtHelper"][3]), HELPER_RIM)
	_fbutton("view_apply", "ms_btn_apply", o + _v(n["btnViewApply"]))
	_fbutton("charge", "ms_btn_charge", o + _v(n["btnChargeReward"]))
	var count: int = apply_count()
	if count > 0:

		_fblit("ms_join", o + _v(n["join"]))
		_label(Atlas.MAIN_TEXT["lblNum"], str(count), o, true, Color(0, 0, 0, 0), SHADE, 0.0)
	_fbutton("help", "ms_help", o + _v(n["imgHelp"]))
	_fbutton("close", "public_button_close", o + _v(n["btnClose"]))

func _paint_student(o: Vector2) -> void :
	var n: Dictionary = Atlas.STUDENT
	var m: Model = _model()
	if m != null and not m.master.is_empty():
		_paint_card(o + _v(n["cvsMaster"]), m.master, -1, false, "ms_card_remove")
	if _quest_on:
		_paint_quests(o)
	_fbutton("reward", "ms_btn_reward", o + _v(n["btnGetReward"]))
	_fbutton("help", "ms_help", o + _v(n["imgHelp"]))
	_fbutton("close", "public_button_close", o + _v(n["btnClose"]))


func _paint_quests(o: Vector2) -> void :
	var spot: Array = _quest_spot()
	var at: Vector2 = o + _v(spot)
	var wide: float = float(spot[2])
	var high: float = float(spot[3])
	var most: int = quest_max()
	_qtop = clampi(_qtop, 0, most)
	_qrect = Rect2(at * _f, Vector2(wide, high) * _f)
	_clip = Rect2(at * _f, Vector2(wide - (BAR if most > 0 else 0.0), high) * _f)
	var y: float = 0.0
	for k in range(_qtop, _quest.size()):
		if y >= high:
			break
		var info: Dictionary = Model._dict(_quest[k])
		_draw_task(at + Vector2(0, y), quest_row(info, k), false)
		y += _quest_high(info)
	_clip = Rect2()
	if most > 0:
		_qbar = _draw_bar("qbar", at + Vector2(wide - BAR, 0), high - 2.0 * BAR, float(_qtop), float(most), 2.0)


func _paint_card(at: Vector2, info: Dictionary, k: int, selected: bool, remove_cell: String) -> void :
	var brief: Dictionary = Model._dict(info.get("m_brief", {}))
	var c: Dictionary = Atlas.CARD
	var rect: Rect2 = _fblit("ms_card_sel" if selected else "ms_card", at)
	if k >= 0:
		_hit("card:%d" % k, rect, false)
	var head: Rect2 = Rect2(at + _v(c["imgHead"]), Vector2(40, 40))
	var online: bool = int(brief.get("m_online", 0)) == 1
	_paint_head(int(brief.get("m_avatarId", 0)), head, online)
	if not online:
		_tip(Rect2(head.position * _f, head.size * _f), LAST_LOGIN.replace("@time@", _login_text(int(brief.get("m_lastLoginTime", 0)))))
	var vip: int = int(brief.get("m_vipLevel", 0))
	var name: String = str(brief.get("m_name", ""))
	var spec: Array = Atlas.CARD_TEXT["lblName"]
	if not NameStyles.paint(self, name, ARIAL_BOLD, float(spec[4]), "l", at + _v(spec), float(spec[2]), 1.0, float(spec[3])):
		var style: Array = HallScreen.name_style(clampi(vip % 100, 0, 12))
		_fwords(name, ARIAL_BOLD, float(spec[4]), style[0], "l", at + _v(spec), float(spec[2]), 1.0, float(spec[3]), true, style[1])

	var vip_cell: String = ("lb_sv%d" if vip >= 100 else "lb_v%d") % clampi(vip % 100, 0, 15)
	_small_vip(vip, at + Vector2(164.0 - _cell_size(vip_cell).x, float(c["imgVip"][1])))
	var value: Array = Atlas.CARD_TEXT["lblValue"]
	_label(value, AMITY.replace("@num1@", str(int(info.get("m_nAmity", 0)))), at, false, Color.WHITE, SHADE, 0.0)
	_tip(Rect2((at + _v(value)) * _f, Vector2(float(value[2]), 18.0) * _f), AMITY_TIP)
	_level(int(brief.get("m_level", 0)), at + _v(c["level"]))
	_fbutton("card_watch:%d" % k, "ms_card_watch", at + _v(c["btnWatch"]))
	_fbutton("card_remove:%d" % k, remove_cell, at + _v(c["btnRemove"]))

func _paint_head(avatar: int, rect: Rect2, online: bool) -> void :
	if pack == null:
		return
	var key: String = str(pack.lobby.get("avatars", {}).get(str(avatar), ""))
	if key.is_empty():
		return
	var path: String = "l/h/%s.webp" % key
	var picture: Texture2D = pack.picture(path)
	if picture == null or picture.get_width() <= 4:
		return
	if not online:
		picture = _greyed(path, picture)
	draw_texture_rect(picture, Rect2(rect.position * _f, rect.size * _f), false)


func _greyed(path: String, picture: Texture2D) -> Texture2D:
	if _grey.has(path):
		return _grey[path]
	var image: Image = picture.get_image()
	if image == null:
		return picture
	image = image.duplicate()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var px: Color = image.get_pixel(x, y)
			var l: float = px.r * GREY.x + px.g * GREY.y + px.b * GREY.z
			image.set_pixel(x, y, Color(l, l, l, px.a))
	var out: ImageTexture = ImageTexture.create_from_image(image)
	_grey[path] = out
	return out


func _login_text(stamp: int) -> String:
	if stamp <= 0:
		return ""
	var local: int = stamp + int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(local)
	return "%02dh%02d'  %02d-%02d-%04d" % [int(d.hour), int(d.minute), int(d.day), int(d.month), int(d.year)]

func _paint_find(o: Vector2) -> void :
	var n: Dictionary = Atlas.FIND
	var list: Array = n["lstFindStudent"]
	var rows: Array = find_rows()
	var m: Model = _model()
	var kind: int = m.find_type if m != null else Model.PLT_MASTERLIST
	for i in range(mini(rows.size(), FIND_ROWS)):
		if rows[i] is Dictionary:
			_paint_find_row(o + Vector2(float(list[0]), float(list[1]) + 30.0 * i), rows[i], i, kind)
	if find_received() and rows.is_empty() and kind == Model.PLT_MASTERLIST:
		var spec: Array = Atlas.FIND_TEXT["txtNoMasterTip"]
		_para(NO_MASTER, ARIAL_BOLD, float(spec[4]), Color.WHITE, o + _v(spec), float(spec[2]), float(spec[3]), NO_TIP_GLOW, 
			HORIZONTAL_ALIGNMENT_CENTER)
	_fbutton("prev", "ms_prev", o + _v(n["btnLastPage"]))
	_fbutton("next", "ms_next", o + _v(n["btnNextPage"]))
	_fbutton("help", "ms_help", o + _v(n["imgHelp"]))
	_fbutton("close", "public_button_close", o + _v(n["btnClose"]))


func _paint_find_row(at: Vector2, brief: Dictionary, k: int, kind: int) -> void :
	var r: Dictionary = Atlas.ROW
	var t: Dictionary = Atlas.ROW_TEXT
	_level(int(brief.get("bLevel", 0)), at + _v(r["level"]))
	_label(t["lblName"], str(brief.get("szName", "")), at, true, FIND_INK, FIND_RIM, 1.0)
	_small_vip(int(brief.get("nVipLevel", 0)), at + _v(r["imgVipLevel"]))
	_label(t["lblElo"], str(int(brief.get("iElo", 0))), at, true, Color.WHITE, SHADE, 0.0)
	_label(t["lblHelperScore"], str(int(brief.get("nBoosterAttack", 0))), at, true, Color.WHITE, SHADE, 0.0)
	_label(t["lblClanName"], str(brief.get("szTeamName", "")), at, true, FIND_INK, FIND_RIM, 1.0)
	_fbutton("find_watch:%d" % k, "ms_row_watch", at + _v(r["btnWatch"]))
	_fbutton("find_get:%d" % k, "ms_row_baishi" if kind == Model.PLT_MASTERLIST else "ms_row_shoutu", at + _v(r["btnGetStudent"]))
	_fblit("ms_cut542", at + _v(r["cut"]))


func _paint_apply() -> void :
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _apply_at()
	var frame: Rect2 = _fblit("ms_apply", at + _v(Atlas.PANELS["apply"]))
	_hit("panel", frame, false)
	_fblit("ms_apply_list", at + _v(Atlas.PANELS["apply_list"]))
	var list: Array = Atlas.APPLY["list"]
	var rows: Array = apply_rows()
	_apply_top = clampi(_apply_top, 0, maxi(0, rows.size() - APPLY_ROWS))
	for k in range(_apply_top, mini(rows.size(), _apply_top + APPLY_ROWS)):
		if rows[k] is Dictionary:
			_paint_apply_row(at + Vector2(float(list[0]), float(list[1]) + 32.0 * (k - _apply_top)), rows[k], k)
	_fbutton("apply_close", "public_button_close", at + _v(Atlas.APPLY["btnClose"]))


func _paint_apply_row(at: Vector2, brief: Dictionary, k: int) -> void :
	var r: Dictionary = Atlas.APPLY_ROW
	var t: Dictionary = Atlas.APPLY_TEXT
	_level(int(brief.get("m_level", 0)), at + _v(r["level"]))
	_label(t["lblName"], str(brief.get("m_name", "")), at, true, Color.WHITE, SHADE, 0.0)
	_fbutton("apply_watch:%d" % k, "ms_row_watch", at + _v(r["btnWatch"]))
	_label(t["lblSex"], SEX[1] if int(brief.get("m_sex", 0)) == 1 else SEX[0], at, false, Color.WHITE, SHADE, 0.0)
	_label(t["lblTime"], _since(brief), at, false, Color.WHITE, SHADE, 0.0)
	_fbutton("apply_ok:%d" % k, "ms_agree", at + _v(r["btnApprove"]))
	_fbutton("apply_no:%d" % k, "ms_disagree", at + _v(r["btnReject"]))
	_fblit("ms_cut390", at + _v(r["cut"]))


func _since(brief: Dictionary) -> String:
	if int(brief.get("m_online", 0)) == 1:
		return "Online"
	var days: int = int(float(_now() - int(brief.get("m_lastLoginTime", 0))) / 86400.0)
	if days < 1:
		return "Hôm nay"
	if days > 30:
		return ">30 ngày"
	return "%d ngày trước" % days


func _paint_help() -> void :
	var size_help: Array = Atlas.SIZES["help"]
	var at: Vector2 = _window(float(size_help[0]), float(size_help[1]))
	_label(Atlas.HELP_TEXT["lblTile"], TITLE, at, false)
	var desc: Array = Atlas.HELP_TEXT["levelDesc"]
	_para(HELP, ARIAL_BOLD, float(desc[4]), Color.WHITE, at + _v(desc), float(desc[2]), float(desc[3]), HELPER_RIM)
	_fbutton("help_ok", "ms_help_ok", at + _v(Atlas.HELP["btnConfirm"]))


func _paint_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(ASK_SIZE.x, ASK_SIZE.y)
	_hit("panel", Rect2(at * _f, ASK_SIZE * _f), false)
	_fblit("fr_ask", at + Vector2(46, 1))
	_fblit("fr_ask_guy", at + Vector2(-80, -76))
	_fpara(ask_text(), ARIAL_BOLD, 14, Color.WHITE, at + Vector2(102, 38), 270, 5)
	_fbutton("ask_ok", "fr_ask_ok", at + Vector2(120, 133))
	_fbutton("ask_no", "fr_ask_no", at + Vector2(240, 133))


func ask_text() -> String:
	if _ask.is_empty():
		return ""
	var m: Model = _model()
	var text: String = ASK_MASTER if m != null and m.have_master() else ASK_PRENTICE
	if int(_ask.get("m_online", 0)) == 0 and _now() - int(_ask.get("m_lastLoginTime", 0)) > 3 * 86400:
		text = ASK_GONE
	return text.replace("@name@", str(_ask.get("m_name", "")))


func _paint_tip() -> void :
	var mouse: Vector2 = get_local_mouse_position()
	var key: String = ""
	var text: String = ""
	for one: Array in _tips:
		if (one[0] as Rect2).has_point(mouse):
			key = str(one[0])
			text = str(one[1])
			break
	_ctip.draw(self, key, text, mouse / _f, Vector2(_fw, _fh), _f)
