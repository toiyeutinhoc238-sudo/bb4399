extends "master_task_draw.gd"











const RQ = preload("rand_quest_atlas.gd")
const Rules = preload("rand_quest_rules.gd")

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const UI_RAND_QUEST: int = 34
const TITLE: String = "NHIỆM VỤ NGÀY"
const TITLE_INK: Color = Color("1f86e0")
const TITLE_SHADOW: Color = Color(0, 0.16, 0.4, 0.35)
const AWARD: String = "+@money@ Vàng"
const REFRESH_TIP: String = "Được làm mới NV @num1@ lần"
const NAME_TAG: String = "Nhiệm vụ:"
const GUILD_TAG: String = "Quân đoàn"
const JOIN: String = "VÀO QUÂN ĐOÀN"
const TIP: String = "Nhiệm vụ ngày làm mới lúc 0:00 mỗi ngày."
const ROW_FILL: Color = Color(0.02, 0.16, 0.36, 0.55)
const ROW_EDGE: Color = Color("3c8fd8", 0.7)
const GUILD_FILL: Color = Color(0.22, 0.12, 0.03, 0.55)
const GUILD_EDGE: Color = Color("e0a040", 0.75)
const AWARD_RIM: Color = Color("1d73a5")
const NAME_RIM: Color = Color("0b5a92")
const OFF: Color = Color(1, 1, 1, 0.55)

var _top: float = 0.0
var _bar: Array = []
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_top: float = 0.0
var _list: Rect2 = Rect2()
var _rows: Dictionary = {}

signal play_asked

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_use(RQ.FILE, RQ.R)
	var lr: Dictionary = {"lr_aw_money": LRAtlas.R["lr_aw_money"]}
	for key: String in LRAtlas.R:
		if key.begins_with("lr_sb_"):
			lr[key] = LRAtlas.R[key]
	_use(LRAtlas.FILE, lr)
	if client != null:
		client.changed.connect(_follow)

func open() -> void :
	if client == null:
		return
	if not Rules.open(client.quests):
		say("Chức năng chưa mở")
		return
	_top = 0.0
	_grab = false
	visible = true
	client.quest_open_ui(UI_RAND_QUEST)
	queue_redraw()

func close() -> void :
	visible = false
	_grab = false

func _follow() -> void :
	if not visible or client == null:
		return
	if client.state not in ["lobby", "hall", "room"]:
		close()
		return
	queue_redraw()

func _guild_id() -> int:
	return int(client.guild.get("nGuildId", 0)) if client != null else 0


func _most(count: int) -> float:
	var content: float = float(maxi(0, count - 1) * int(RQ.STEP) + int(RQ.CVS[1])) if count > 0 else 0.0
	return maxf(0.0, content - float(RQ.LIST[3]))

func _scroll(value: float) -> void :
	_top = clampf(value, 0.0, _most(Rules.order(client.quests).size()))
	queue_redraw()

func _paint() -> void :
	_rows = {}
	_clip = Rect2()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	if client == null:
		return
	var at: Vector2 = _centre(float(RQ.SIZE[0]), float(RQ.SIZE[1]))
	var frame: Vector2 = at + _v(RQ.FRAME)
	_hit("panel", Rect2(frame * _f, _cell_size("rq_frame") * _f), false)
	_fblit("rq_frame", frame)
	var spot: Array = RQ.TITLE
	var title: Vector2 = at + Vector2(float(spot[0]), float(spot[1]))
	_fwords(TITLE, ARIAL_BOLD, 24.0, TITLE_SHADOW, "c", title + Vector2(0, 2), float(spot[2]), 3.0, float(spot[3]), true, TITLE_SHADOW)
	_fwords(TITLE, ARIAL_BOLD, 24.0, TITLE_INK, "c", title, float(spot[2]), 3.0, float(spot[3]), true, Color.WHITE)
	_draw_list(at)
	_fwords(TIP, ARIAL, 12.0, Color("c0d6ff"), "l", at + _v(RQ.TIP), 560.0, 1.0, 16.0, true, Color(0, 0, 0, 0.7))
	_fbutton("close", "rq_close", at + _v(RQ.CLOSE))
	_draw_refresh_tip()

func _draw_list(at: Vector2) -> void :
	var quests: Dictionary = client.quests
	var order: Array = Rules.order(quests)
	var most: float = _most(order.size())
	_top = clampf(_top, 0.0, most)
	var box: Vector2 = at + Vector2(float(RQ.LIST[0]), float(RQ.LIST[1]))
	var wide: float = float(RQ.LIST[2]) - (float(RQ.BAR) if most > 0.0 else 0.0)
	_list = Rect2(box * _f, Vector2(float(RQ.LIST[2]), float(RQ.LIST[3])) * _f)
	_clip = Rect2(box * _f, Vector2(wide, float(RQ.LIST[3])) * _f)
	var slots: Dictionary = Rules.slot_ids(quests)
	for i: int in order.size():
		var cvs: int = int(order[i])
		var corner: Vector2 = box + Vector2(0, float(i * int(RQ.STEP)) - _top)
		if corner.y + float(RQ.CVS[1]) < box.y or corner.y > box.y + float(RQ.LIST[3]):
			continue
		_draw_cvs(cvs, Rules.cvs_id(quests, cvs), corner, slots)
	_clip = Rect2()
	_bar = []
	if most > 0.0:
		var track: float = float(RQ.LIST[3]) - 2.0 * float(RQ.BAR)
		_bar = _draw_bar("rbar", box + Vector2(float(RQ.LIST[2]) - float(RQ.BAR), 0), track, _top, most, float(RQ.LIST[3]))


func _cround(rect: Rect2, fill: Color, edge: Color) -> void :
	var cut: Rect2 = rect.intersection(_clip)
	if not cut.has_area():
		return
	if cut.is_equal_approx(rect):
		_round(rect, fill, 5.0 * _f, edge, 1.5)
		return
	draw_rect(cut, fill)
	draw_rect(cut, edge, false, 1.5)

func _draw_cvs(cvs: int, id: int, corner: Vector2, slots: Dictionary) -> void :
	var guild_box: bool = cvs == 4
	var bg: Vector2 = corner + _v(RQ.BG)
	_cround(Rect2(bg * _f, Vector2(578, 104) * _f), GUILD_FILL if guild_box else ROW_FILL, GUILD_EDGE if guild_box else ROW_EDGE)
	if guild_box:
		_cwords(GUILD_TAG, ARIAL_BOLD, 11.0, Color("ffd27a"), "l", corner + _v(RQ.GUILD_T) + Vector2(8, 2), 80.0, 14.0, true, Color(0, 0, 0, 0.8))
	var row: Array = Rules.template(id)
	var state: String = Rules.item_state(client.quests, id, _guild_id())
	if not state.is_empty():
		var info: Array = client.quests[id]
		_cblit("lr_aw_money", corner + _v(RQ.GOLD))
		_label("lblAward", AWARD.replace("@money@", str(int(row[5]))), corner, AWARD_RIM)
		_cwords(NAME_TAG, ARIAL_BOLD, 12.0, Color("8fd3ff"), "l", corner + _v(RQ.NAME_T) + Vector2(0, -1), 50.0, 16.0, true, NAME_RIM)
		_label("lblCheckName", str(row[2]), corner, NAME_RIM)
		_label("lblCheckCount", "%d/%d" % [mini(int(info[1]), int(row[4])), int(row[4])], corner, NAME_RIM)
		var desc: Array = RQ.TEXTS["lblCheckDesc"]
		var lines: Array = _wrap(str(row[3]), float(desc[4]), float(desc[2]))
		for k: int in mini(lines.size(), 3):
			_cwords(str(lines[k]), ARIAL_BOLD, float(desc[4]), Color(str(desc[5])), "l", corner + Vector2(float(desc[0]), float(desc[1]) + k * 15.0), float(desc[2]), 15.0, true, Color(0, 0, 0, 0.6))
	match state:
		"NOAWARD":
			_row_button("goto%d" % cvs, "rq_goto", corner + _v(RQ.BTN), id)
		"CANAWARD":
			_row_button("get%d" % cvs, "rq_get", corner + _v(RQ.BTN), id)
		"GETAWARD":
			_cblit("rq_has", corner + _v(RQ.HAS))

	if cvs == 1 or cvs == 2:
		var on: bool = id > 0 and Rules.refresh_left(client.limits) > 0 and Rules.state_of(client.quests, id) != Rules.OVER
		var spot: Vector2 = corner + _v(RQ.REFRESH)
		if on:
			_row_button("refresh%d" % cvs, "rq_refresh", spot, id)
		else:
			var shown: Rect2 = _cblit("rq_refresh_off", spot).intersection(_clip) if _clip.has_area() else Rect2()
			if shown.has_area():
				_hit("refresh%d" % cvs, shown, false)

	if guild_box and _guild_id() == 0:
		var sel3: int = int(slots.get(3, 0))
		var kind: Array = Rules.template(sel3)
		if sel3 > 0 and not kind.is_empty() and int(kind[0]) == Rules.GUILD:
			var join: Vector2 = corner + _v(RQ.BTN)
			_row_button("join", "rq_join", join, sel3)
			_cwords(JOIN, ARIAL_BOLD, 13.0, Color.WHITE, "c", join + Vector2(0, 8), 100.0, 16.0, true, Color("3f7a10"))

func _row_button(id: String, cell: String, at: Vector2, quest: int) -> void :
	_cbutton(id, cell, at)
	_rows[id] = quest


func _label(key: String, text: String, corner: Vector2, rim: Color) -> void :
	var spec: Array = RQ.TEXTS[key]
	var px: float = float(spec[4])
	var high: float = float(spec[3]) if float(spec[3]) > 0.0 else px + 4.0
	var y: float = float(spec[1]) - (high / 2.0 if key == "lblCheckCount" else 0.0)
	var align: String = str(spec[7])
	var x: float = float(spec[0])
	_cwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, px, Color(str(spec[5])), align, corner + Vector2(x, y), float(spec[2]), high, true, rim)


func _draw_refresh_tip() -> void :
	if not _hover.begins_with("refresh"):
		return
	var anchor: Rect2 = Rect2()
	for hit: Array in _hits:
		if str(hit[0]) == _hover:
			anchor = hit[1]
	if not anchor.has_area():
		return
	var text: String = REFRESH_TIP.replace("@num1@", str(Rules.refresh_left(client.limits)))
	var wide: float = _measure(text, ARIAL, 12.0) + 20.0
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	_round(Rect2(at * _f, Vector2(wide, 26) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(text, ARIAL, 12.0, Color.WHITE, "l", at + Vector2(10, 4), wide - 20.0, 1.0, 18.0)

func refresh_tip() -> String:
	return REFRESH_TIP.replace("@num1@", str(Rules.refresh_left(client.limits))) if client != null else ""

func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "rbar:up":
		_scroll(_top - 20.0)
	elif id == "rbar:down":
		_scroll(_top + 20.0)
	elif id == "rbar:pgup":
		_scroll(_top - float(RQ.LIST[3]))
	elif id == "rbar:pgdn":
		_scroll(_top + float(RQ.LIST[3]))
	elif id.begins_with("get"):
		client.quest_complete(int(_rows.get(id, 0)), 0)
	elif id.begins_with("refresh"):
		if _rows.has(id) and Rules.refresh_left(client.limits) > 0:
			client.rand_quest_switch(int(_rows[id]))
	elif id.begins_with("goto"):
		var kind: Array = Rules.template(int(_rows.get(id, 0)))
		close()
		if not kind.is_empty() and int(kind[0]) == Rules.RESEARCH:
			page_asked.emit("tank")
		else:
			play_asked.emit()
	elif id == "join":
		close()
		page_asked.emit("guild")

func _wheel(step: int, at: Vector2) -> void :
	if _list.has_point(at):
		_scroll(_top + step * 40.0)

func _drag(moved: Vector2, from: Vector2) -> void :
	if not _grab and _list.has_point(from):
		_scroll(_top - moved.y / _f)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _hit_at(event.position) == "slide:rbar" and not _bar.is_empty():
			_grab = true
			_grab_at = event.position
			_grab_top = _top
		elif not event.pressed:
			_grab = false
	elif event is InputEventMouseMotion and _grab:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_grab = false
		else:
			var step: float = maxf(0.001, (float(_bar[0]) - float(_bar[1])) / float(_bar[2]))
			_scroll(_grab_top + (event.position.y - _grab_at.y) / _f / step)
			accept_event()
			return
	super (event)

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
