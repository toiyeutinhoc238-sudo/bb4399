extends "master_task_draw.gd"









const Gift = preload("vip_level_gift_atlas.gd")

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const FROM: int = 1600
const TO: int = 1611
const OPEN_IN: Array = ["lobby", "hall"]
const COUNT_RIM: Color = Color(0, 0, 0, 0.8)

const PopQueue = preload("pop_queue.gd")
var queue: Node = null
var _mark: int = 0
var _done: Dictionary = {}

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_use(Gift.FILE, Gift.R)
	if client != null:
		client.changed.connect(_follow)


func current() -> int:
	var stage: int = 0
	for key: Variant in client.stages:
		if int(key) >= FROM and int(key) <= TO:
			stage = maxi(stage, int(key))
	for key: Variant in client.stages_cleared:
		if int(key) >= FROM and int(key) <= TO and int(key) >= stage:
			return 0
	return stage

func _follow() -> void :
	if client == null:
		return
	if client.state not in OPEN_IN and client.state not in ["battle", "room"]:
		_done.clear()
		if visible:
			visible = false
			_mark = 0
		return
	if visible or client.state not in OPEN_IN or client.battle.active or not client.pair_scene.is_empty():
		return
	if (queue != null and bool(queue.get("hold"))) or PopQueue.held():
		return
	var stage: int = current()
	if stage == 0 or _done.has(stage) or int(client.stages.get(stage, {}).get("reward", 0)) != 1:
		return
	if gifts(stage).is_empty():
		return
	_done[stage] = true
	_mark = stage
	_toast = ""
	visible = true
	queue_redraw()


func vip_of(stage: int) -> int:
	var row: Variant = Gift.STAGES.get(str(stage))
	return int(row[0]) if row is Array else 0


func gifts(stage: int) -> Array:
	var row: Variant = Gift.STAGES.get(str(stage))
	if not (row is Array):
		return []
	var out: Array = []
	for line: Array in Gift.PRESENTS.get(str(int(row[1])), []):
		if int(line[0]) == 2:
			out.append({"kind": "coin", "id": int(line[1]), "count": int(line[2]), "name": str(line[3]), "art": "", "quality": 0, "desc": ""})
		else:
			out.append(_item_cell([int(line[1]), int(line[2]), str(line[3]), str(line[4]), int(line[5])]))
	return out.slice(0, Gift.CELLS.size())


func _close() -> void :
	var stage: int = _mark
	visible = false
	_mark = 0
	if client != null and stage != 0:
		client.stage_reap(stage, true)
	_follow.call_deferred()

func _paint() -> void :
	_item_tip = []
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(float(Gift.SIZE[0]), float(Gift.SIZE[1]))
	var frame: Vector2 = at + _v(Gift.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("vg_frame") * _f), false)
	_fblit("vg_frame", frame)
	var vip: int = vip_of(_mark)
	for key: String in ["imgVipLevel", "imgVipLevel0"]:
		var spot: Array = Gift.NODES[key]
		_fblit("vg_vip%d" % vip, at + _v(spot))
	var cells: Array = gifts(_mark)
	for i: int in cells.size():
		_draw_gift(cells[i], at + _v(Gift.CELLS[i]))
	_fbutton("close", "vg_close", at + _v(Gift.NODES["btnClose"]))
	_fbutton("get", "vg_get", at + _v(Gift.NODES["btnGetReward"]))
	_draw_item_tip()


func _draw_gift(gift: Dictionary, corner: Vector2) -> void :
	_fblit("vg_cell", corner)
	var quality: int = int(gift.quality)
	if str(gift.kind) == "item" and quality >= 2 and quality <= 5:
		_fblit("vg_iq%d" % quality, corner + Vector2(6, 6))
	var box: Rect2 = Rect2((corner + Vector2(4, 4)) * _f, Vector2(52, 49) * _f)
	if str(gift.kind) == "coin":
		var coin: Vector2 = _cell_size("vg_coin2")
		_fblit("vg_coin2", corner + Vector2(4, 4) + (Vector2(52, 49) - coin) / 2.0)
	else:
		var art: String = str(gift.art)
		var picture: Texture2D = pack.picture(art) if pack != null and not art.is_empty() else null
		if picture != null:
			draw_texture_rect(picture, _fit_rect(picture, box), false)
	var spec: Array = Gift.TEXTS["lblNum"]
	var first: Array = Gift.CELLS[0]
	var label: Vector2 = corner + Vector2(float(spec[0]) - float(first[0]), float(spec[1]) - float(first[1]))
	_fwords(str(int(gift.count)), ARIAL_BOLD, float(spec[4]), Color(str(spec[5])), "r", label, float(spec[2]), 1.0, 0.0, true, COUNT_RIM)
	if str(gift.kind) == "item":
		_peek(Rect2(corner * _f, Vector2(58, 58) * _f), gift)

func _activate(id: String) -> void :
	if id in ["close", "get"]:
		_close()

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
