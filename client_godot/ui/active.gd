extends "flash_screen.gd"









const Atlas = preload("active_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const GradLabel = preload("grad_label.gd")
const SCRIPT_PATH: String = "res://ui/active.gd"
const NODE_NAME: String = "ActiveView"
const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const UI_ACTIVE: int = 57
const CKT_OPEN_UI: int = 27
const QST_COMPLETE: int = 3
const Q_CHECK_TYPE: int = 12
const Q_CHECK_ID: int = 13
const SHOWN: int = 5
const ITEM_INK: Color = Color("fefefe")

const CANT_GET: String = "cant"
const GETED: String = "geted"
const CAN_GET: String = "can"
const ACTIVATE: String = "activate"

var _state: String = ""
var _told: bool = false
var _tip: Array = []
var _ctip: CTip = CTip.new()


static func open_for(host: Control) -> Control:
	if host == null or host.client == null or host.pack == null or host.get_parent() == null:
		return null
	var parent: Node = host.get_parent()
	var view: Control = parent.get_node_or_null(NODE_NAME) as Control
	if view == null:
		view = load(SCRIPT_PATH).new()
		view.name = NODE_NAME
		view.client = host.client
		view.pack = host.pack
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		parent.add_child(view)
	elif view.visible:
		return null
	view.client = host.client
	view.pack = host.pack
	parent.move_child(view, parent.get_child_count() - 1)
	return view if view.open() else null

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)

func open() -> bool:
	if visible or client == null or pack == null:
		return false
	_state = client.state
	_told = false
	_tip = []
	pack.load_quest()
	pack.load_bag()
	visible = true
	var view: Viewport = get_viewport()
	if view != null:
		view.gui_release_focus()
	queue_redraw()
	return true

func close() -> void :
	if not visible:
		return
	visible = false
	_tip = []

func _tick(_delta: float) -> void :
	if client == null or client.state != _state:
		close()
		return
	if not _told and not pack.quest.is_empty() and client.quests_loaded:
		_told = true
		if wants_open_note():
			client.quest_open_ui(UI_ACTIVE)


func wants_open_note() -> bool:
	var quests: Dictionary = pack.quest.get("quests", {})
	for key: Variant in client.quests:
		var info: Variant = client.quests[key]
		if info is Array and not (info as Array).is_empty() and int(info[0]) == QST_COMPLETE:
			continue
		var row: Variant = quests.get(str(key))
		if row is Array and (row as Array).size() > Q_CHECK_ID and int(row[Q_CHECK_TYPE]) == CKT_OPEN_UI and int(row[Q_CHECK_ID]) == UI_ACTIVE:
			return true
	return false


func stages() -> Array:
	return pack.quest.get("stages", []) if pack != null else []


func current() -> int:
	for stage: Variant in stages():
		if client.stages.has(int(stage[0])):
			return int(stage[0])
	return 0


func cleared() -> bool:
	for stage: Variant in stages():
		if client.stages_cleared.has(int(stage[0])):
			return true
	return false


func fizz() -> int:
	var total: int = maxi(0, int(client.character.get("iFizz", 0)))
	var now: int = current()
	if now != 0:
		total = maxi(total, int(client.stages[now].get("value", 0)))
	return total

func week_fizz() -> int:
	return maxi(0, int(client.character.get("iWeekFizz", 0)))


func progress(points: int) -> int:
	var all: Array = stages()
	var total: int = 0
	for i: int in all.size():
		var need: int = int(all[i][1])
		var prev: int = int(all[i - 1][1]) if i > 0 else 0
		var span: int = int(Atlas.PGB[i]) if i < Atlas.PGB.size() else 0
		if points <= need:
			if need > prev:
				total += int(float(span) * float(points - prev) / float(need - prev))
			break
		total += span
	return clampi(total, 0, int(Atlas.PROGRESS[2]))


func reward_state(index: int, points: int) -> String:
	var all: Array = stages()
	if index < 0 or index >= all.size():
		return ""
	var stage: int = int(all[index][0])
	var now: int = current()
	var bonus: int = int(client.stages[now].get("reward", 0)) if now != 0 else -1
	if points < int(all[index][1]):
		return CANT_GET
	if cleared() or (now != 0 and (now > stage or (now == stage and bonus == 0))):
		return GETED
	if (now == 0 and index == 0) or (now == stage and bonus == 1):
		return CAN_GET
	return ACTIVATE

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var frame: Vector2 = _xy(Atlas.FRAME)
	var at: Vector2 = _centre(frame.x, frame.y)
	_hit("panel", Rect2(at * _f, frame * _f), false)
	_fblit("act_frame", at + _xy(Atlas.BODY))
	_tip = []
	var mouse: Vector2 = get_local_mouse_position()
	var points: int = fizz()
	var all: Array = stages()
	var width: int = progress(points)
	if width > 0:
		_fpart("act_progress", at + _xy(Atlas.PROGRESS), Rect2(0, 0, width, float(Atlas.PROGRESS[3])))
	for i: int in mini(SHOWN, mini(all.size(), Atlas.ITEMS.size())):
		var spot: Dictionary = Atlas.ITEMS[i]
		var look: String = reward_state(i, points)
		var img: Vector2 = at + _xy(spot["img"])
		var id: String = "item%d" % i
		var rect: Rect2 = Rect2(img * _f, Vector2(50, 50) * _f)
		_hit(id, rect, false)
		if look == GETED:
			_fblit("act_geted", at + _xy(spot["geted"]))
		elif look == CAN_GET:
			var cells: Array = Atlas.FX["cells"]
			var cell: String = str(cells[int(_time * float(Atlas.FX["rate"])) % cells.size()])
			_fblit(cell, at + _xy(spot["fx"]) - _xy(Atlas.FX["stage"]) / 2.0 + _xy(Atlas.FX["at"]))
		var label: Array = spot["label"]
		_fwords(str(int(all[i][1])), ARIAL_BOLD, 14.0, ITEM_INK, "c", at + Vector2(float(label[0]), float(label[1])), float(label[2]))
		if not _mobile and rect.has_point(mouse) and (_hover == "panel" or _hover == id):
			_tip = [rect, "", "", Color.WHITE, FlashTip.simulate(int(all[i][2]), pack.bag, {})]
	_glabel(Atlas.WORDS["daily"], Atlas.LABELS["daily"], Atlas.DAILY_INK, at)
	_glabel(str(points), Atlas.LABELS["daily_value"], Atlas.DAILY_INK, at)
	_glabel(Atlas.WORDS["week"], Atlas.LABELS["week"], Atlas.WEEK_INK, at)
	_glabel(str(week_fizz()), Atlas.LABELS["week_value"], Atlas.WEEK_INK, at)
	for key: String in ["daily", "week"]:
		var id: String = "tips_" + key
		var rect: Rect2 = _fbutton(id, "act_tips", at + _xy(Atlas.TIPS[key]))
		if not _mobile and _hover == id and rect.has_point(mouse):
			_tip = [rect, str(Atlas.WORDS[key + "_tip"]), ""]
	var bar: Dictionary = Atlas.SCROLL
	var x: float = float(bar["x"])
	_fblit("act_sb_up", at + Vector2(x, float(bar["up"][0])))
	_fblit("act_sb_track", at + Vector2(x, float(bar["track"][0])))
	_fblit("act_sb_down", at + Vector2(x, float(bar["down"][0])))
	_fbutton("close", "act_close", at + Vector2(float(Atlas.CLOSE[0]), float(Atlas.CLOSE[1])))
	FlashTip.show(self, _tip, _ctip)


func _glabel(text: String, spec: Array, ink: Array, base: Vector2) -> void :
	var px: float = float(spec[3])
	var font: Font = _face(BOLD)
	var wide: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f
	var left: Vector2 = base + Vector2(float(spec[0]) + roundf((float(spec[2]) - wide) / 2.0), float(spec[1]))
	GradLabel.flex(self, text, font, px, left, GradLabel.measured_high(px), _f, Color(str(ink[0])), Color(str(ink[1])), Color(str(ink[2])))

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id.begins_with("item"):
		var index: int = int(id.substr(4))
		var all: Array = stages()
		if index < 0 or index >= mini(SHOWN, all.size()) or reward_state(index, fizz()) != CAN_GET:
			return
		client.stage_reap(int(all[index][0]), true)

func _input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree() or not (event is InputEventKey):
		return
	var key: InputEventKey = event
	if key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
		close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
