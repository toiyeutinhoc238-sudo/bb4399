extends "fair.gd"


const Bonfire = preload("bonfire_atlas.gd")
const Data = preload("bonfire_data.gd")
const SHOW_IN: Array = ["lobby", "hall", "room"]
const FIRE_QUESTS: Array = [7101, 7103, 7105, 7107]
const HEADS: Array = [[32, 173], [55, 67], [304, 67], [329, 173], [304, 277]]

var _fire: int = 0
var _fire_rev: int = -1
var _last_fire_info: Array = []
var _fire_stage: int = 1
var _pending_add: int = 0
var _fly_start: float = -10.0
var _fly_queued: bool = false
var _next_fly: float = 0.0
var _heads: Array = []
var _quest_scroll: float = 0.0
var _preview_scroll: float = 0.0
var _quest_rect: Rect2 = Rect2()
var _preview_rect: Rect2 = Rect2()
var _quest_thumb_rect: Rect2 = Rect2()
var _preview_thumb_rect: Rect2 = Rect2()

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_qty = _fedit(6, true)
	_qty.text_changed.connect( func(_text: String) -> void : _on_qty_input())
	_qty.text_submitted.connect( func(_text: String) -> void : _confirm_convert())
	_use(Atlas.FILE, Atlas.R)
	_use(AtlasC.FILE, AtlasC.R)
	_use(Arena.FILE, Arena.R)
	_use(QuestAtlas.FILE, QuestAtlas.R)
	_use(Bonfire.FILE, Bonfire.R)
	for spec: Dictionary in Bonfire.FIRE.values():
		_use(str(spec.file), spec.regions)
	_use(str(Bonfire.MATCH.file), Bonfire.MATCH.regions)
	if client != null:
		client.changed.connect(_follow_bonfire)
		client.bonfire_tossed.connect(_toss_self)
		client.awarded.connect(_on_award)

func chat_busy() -> bool:
	return visible




static func activity_open(now: int, acts: Dictionary) -> bool:
	var info: Variant = acts.get(int(Data.ACTIVITY.id))
	if not (info is Array and (info as Array).size() >= 3):
		return false
	return now >= int(info[0]) and now < int(info[0]) + int(info[1])

func open() -> void :
	if visible or client == null or client.state not in SHOW_IN:
		return
	if not client.bonfire_open():
		return
	_fire = int(client.bonfire_count)
	_fire_rev = -1
	_last_fire_info = []
	_pending_add = 0
	_fly_queued = false
	_fly_start = -10.0
	_next_fly = _time + 2.0
	_quest_scroll = 0.0
	_preview_scroll = 0.0
	_heads = []
	_hover = ""
	_press = ""
	visible = true
	if pack != null:
		pack.load_bag()
		pack.load_fair()
		pack.load_quest()
	_recount()
	_follow_bonfire()
	_pending_add = 0
	_fly_queued = false
	_reward.reset()
	_sheet_id = ""
	_flies = []
	RewardFly.reset(self)
	_note = ""
	_toast = ""

func close() -> void :
	if not visible:
		return
	client.bonfire_close()
	_close_sheet()
	_heads = []
	_pending_add = 0
	_fly_queued = false
	_reward.reset()
	_sheet_id = ""
	_flies = []
	RewardFly.reset(self)
	_note = ""
	_toast = ""
	visible = false
	closed.emit()

func _close() -> void :
	close()

func _shown() -> void :
	if not is_visible_in_tree():
		_hide_edits()

func _follow_bonfire() -> void :
	if not visible:
		return
	if client.state not in SHOW_IN:
		close()
		return
	if _fire_rev != int(client.bonfire_rev):
		_fire_rev = int(client.bonfire_rev)
		var info: Array = [client.bonfire_count, client.bonfire_add, client.bonfire_param]
		if info == _last_fire_info:
			return
		_last_fire_info = info
		_fire = int(client.bonfire_count)
		_pending_add = int(client.bonfire_add)
		_fly_queued = _pending_add > 0
		_fly_start = -10.0
		_fire_stage = 0
		for id: int in FIRE_QUESTS:
			if _fire < _threshold(id):
				break
			_fire_stage += 1
		_fire_stage = maxi(1, _fire_stage)

func fire_value() -> int:
	return _fire

func fire_stage() -> int:
	return _fire_stage

func _threshold(id: int) -> int:
	var row: Array = pack.quest.get("quests", {}).get(str(id), []) if pack != null else []
	return int(row[4]) if row.size() > 4 else int(Data.QUESTS.get(str(id), {}).get("check", 0))

func wood_slot() -> int:
	for inst: Dictionary in client.bags.get(2, []):
		if int(inst.get("m_templateId", 0)) == int(Data.ACTIVITY.wood) and int(inst.get("m_count", 0)) > 0:
			return int(inst.get("m_slotNo", -1))
	return -1

func can_add() -> bool:
	return _my_level() >= int(Data.ACTIVITY.level) and wood_slot() >= 0

func converts() -> Array:
	var rows: Array = []
	for source: Dictionary in Data.CONVERTS:
		var rec: Dictionary = source.duplicate(true)
		rec.gift = _item(int(rec.result), int(rec.count))
		rec.gt = 4
		rec.begin = _when(str(rec.begin))
		rec.end = _when(str(rec.end))
		rows.append(rec)
	return rows

func _shown_converts() -> Array:
	return converts()

func _sort_type() -> int:
	return 28

func quest_ids() -> Array:
	var ids: Array = []
	for key: String in Data.QUESTS:
		var id: int = int(key)
		if not client.quests.has(id):
			continue
		var spec: Dictionary = Data.QUESTS[key]
		if _now() < _when(str(spec.get("start", ""))) or _now() > _when(str(spec.get("end", ""))):
			continue
		ids.append(id)
	ids.sort_custom( func(a: int, b: int) -> bool:
		var sa: int = int(client.quests[a][0])
		var sb: int = int(client.quests[b][0])
		var ga: int = 0 if sa == 3 else (2 if sa == 4 else 1)
		var gb: int = 0 if sb == 3 else (2 if sb == 4 else 1)
		if ga != gb:
			return ga < gb
		return int(Data.QUESTS[str(a)].heft) > int(Data.QUESTS[str(b)].heft) if a != b else a < b)
	return ids

func _tick(_delta: float) -> void :
	_tick_award()
	if _time - _counted_at > 0.25:
		_recount()
	if _fly_queued and _time >= _next_fly:
		_fly_queued = false
		_fly_start = _time
		_next_fly = _time + 2.0
		var count: int = 1
		for threshold: int in [50, 100, 200, 500]:
			if _pending_add > threshold:
				count += 1
		var places: Array = [0, 1, 2, 3, 4]
		places.shuffle()
		for i: int in count:
			_heads.append({"at": _time, "place": HEADS[places[i]], "avatar": 2801001 if randi() % 2 == 0 else 2802001, "self": false})
	if _pending_add > 0 and not _fly_queued and _time - _fly_start >= 1.0:
		_fire += _pending_add
		_pending_add = 0
	_heads = _heads.filter( func(row: Dictionary) -> bool: return _time - float(row.at) < 2.0)
	if not _note.is_empty() and _time >= _note_at:
		say(_note)
		_note = ""

func _toss_self() -> void :
	if visible:
		_heads.append({"at": _time, "place": [55, 277], "avatar": int(client.character.get("avatarId", 0)), "self": true})

func _paint() -> void :
	_tip = []
	_placed = []
	var base: Vector2 = _centre(824, 526)
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_hit("panel", Rect2(base * _f, Vector2(824, 526) * _f), false)
	_fblit("bf_frame", base + _v(Bonfire.PANELS.frame))
	_draw_fire(base)
	_draw_heads(base)
	_fwords(str(Data.WORDS.fire), ARIAL_BOLD, 18, Color.WHITE, "c", base + Vector2(68, 153), 300, 1.0, 25)
	_fwords(str(_fire), ARIAL_BOLD, 18, Color.WHITE, "c", base + Vector2(68, 180), 300, 1.0, 25)
	if _time - _fly_start < 1.5 and _fly_start >= 0:
		var age: float = _time - _fly_start
		var add: int = int(client.bonfire_add)
		var alpha: float = 1.0 if age < 1.0 else 1.0 - (age - 1.0) * 2.0
		var w: float = ARIAL_BOLD.get_string_size(str(_fire), HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		_fwords("+%d" % add, ARIAL, 18, Color(1, 0, 0, alpha), "l", base + Vector2(218 + w / 2.0, 180 - minf(age, 1.0) * 50), 100, 1.0, 25, false, Color(1, 1, 1, alpha))
	if can_add():
		_fbutton("add", "bf_add", base + Vector2(151, 367))
	else:
		_fblit("bf_add_off", base + Vector2(151, 367))
	_fbutton("close", "bf_close", base + _v(Bonfire.AT.btnClose))
	_fwords(str(Data.WORDS.rule), ARIAL_BOLD, 14, Color.WHITE, "r", base + Vector2(572, 32), 200, 1.0, 22)
	var rule: Rect2 = _fbutton("rule", "bf_rule", base + _v(Bonfire.AT.btnRule))
	if _hover == "rule":
		_tip = [rule, str(Data.RULE), "", Color.WHITE, null]
	if _my_level() >= int(Data.ACTIVITY.level):
		_fwords(str(Data.WORDS.stage), ARIAL_BOLD, 18, Color.WHITE, "c", base + Vector2(445, 62), 350, 1.0, 26)
		var n: int = int(client.bonfire_completed)
		var received: String = str(Data.WORDS.received_wan if n > 100000 else Data.WORDS.received).replace("@num1@", str(int(n / 10000) if n > 100000 else n))
		_fwords(received, ARIAL_BOLD, 14, Color.WHITE, "l", base + Vector2(446, 94), 350, 1.0, 20)
		_draw_quests(base)
	else:
		var lines: PackedStringArray = str(Data.WORDS.low).split("\n")
		for i: int in lines.size():
			_fwords(lines[i], ARIAL_BOLD, 18, Color.WHITE, "c", base + Vector2(440, 188 - lines.size() * 12 + i * 24), 360, 1.0, 24)
	var rows: Array = converts()
	for i: int in rows.size():
		_draw_cell(base + Vector2(438, 307 + 101 * i), rows[i], i)
	_draw_preview(base)
	match _sheet_id:
		"confirm":
			_draw_confirm(true)
		"swap":
			_draw_confirm(false)
			_draw_swap()
		"award":
			_draw_award()
		"rule":
			var at: Vector2 = _window(440, 260, "rule_close")
			_fwords(str(Data.WORDS.rule), ARIAL_BOLD, 18, Color.WHITE, "c", at + Vector2(0, 17), 440, 1.0, 26)
			_fpara(str(Data.RULE), ARIAL, 14, Color.WHITE, at + Vector2(25, 65), 390, 9)
		_:
			_draw_tip()
	_a18_draw_flies()
	for edit: LineEdit in _edits:
		if not _placed.has(edit):
			edit.visible = false

func _draw_fire(base: Vector2) -> void :

	var key: String = str(mini(_fire_stage, 2))
	var spec: Dictionary = Bonfire.FIRE[key]
	var names: Array = spec["keys"]
	_fblit(str(names[int(_time * float(spec.fps)) % names.size()]), base + Vector2(92.5, 48))

func _draw_heads(base: Vector2) -> void :
	for row: Dictionary in _heads:
		var age: float = _time - float(row.at)
		var pos: Vector2 = base + _v(row.place)
		if age < 1.7:
			var alpha: float = minf(1.0, age / 0.5) if age <= 1.5 else maxf(0.0, 1.0 - (age - 1.5) / 0.2)
			_fblit("bf_head_self" if row["self"] else "bf_head", pos, 0, 0, Color(1, 1, 1, alpha))
			if row["self"]:
				_fwords(str(client.character.get("name", "")), ARIAL_BOLD, 14, Color(1, 1, 0, alpha), "c", pos + Vector2(-62.5, 75), 200, 1.0, 23)
			var path: String = str(pack.lobby.get("avatars", {}).get(str(row.avatar), ""))
			if not path.is_empty():
				_fit(pack.picture("l/h/%s.webp" % path), pos + Vector2(7.5, 7.5), Vector2(60, 60), 1, Color(1, 1, 1, alpha))
		if age >= 0.5:
			var progress: float = clampf((age - 0.5) / 1.5, 0, 1)
			var eased: float = 1.0 - pow(1.0 - progress, 4)
			var start: Vector2 = pos + Vector2(37.5, 37.5)
			var pivot: Vector2 = (1.0 - eased) * (1.0 - eased) * start + 2.0 * eased * (1.0 - eased) * (base + Vector2(220, 150)) + eased * eased * (base + Vector2(220, 290))
			var spec: Dictionary = Bonfire.MATCH
			var names: Array = spec["keys"]
			_fblit(str(names[int((age - 0.5) * float(spec.fps)) % names.size()]), pivot - Vector2(53, 53), 0, 0, Color(1, 1, 1, 1.0 - progress))


func _clip_cell(key: String, rect: Rect2, clip: Rect2) -> Rect2:
	var cell: Array = _cells.get(key, [])
	if cell.is_empty():
		return Rect2()
	var target: Rect2 = rect.intersection(clip)
	if target.has_area() and cell[0] != null:
		var region: Rect2 = Rect2(cell[1][0], cell[1][1], cell[1][2], cell[1][3])
		var scale: Vector2 = region.size / rect.size
		draw_texture_rect_region(cell[0], Rect2(target.position * _f, target.size * _f), Rect2(region.position + (target.position - rect.position) * scale, target.size * scale))
	return Rect2(target.position * _f, target.size * _f)

func _grid50(at: Vector2, gift: Dictionary, clip: Rect2) -> void :
	var rect: Rect2 = Rect2(at, Vector2(50, 50))

	_clip_cell("bf_grid50", rect, clip)
	var image: Texture2D = _gift_art(gift)
	if image != null:
		var k: float = minf(46.0 / image.get_width(), 46.0 / image.get_height())
		var extent: Vector2 = image.get_size() * k
		var dest: Rect2 = Rect2(at + (Vector2(50, 50) - extent) / 2.0, extent)
		var cut: Rect2 = dest.intersection(clip)
		if cut.has_area():
			draw_texture_rect_region(image, Rect2(cut.position * _f, cut.size * _f), Rect2((cut.position - dest.position) / k, cut.size / k))
	_peek_item(Rect2(rect.intersection(clip).position * _f, rect.intersection(clip).size * _f), gift)

func _draw_quests(base: Vector2) -> void :
	var ids: Array = quest_ids()
	var clip: Rect2 = Rect2(base + Vector2(446, 119), Vector2(350, 174))
	_quest_rect = Rect2(clip.position * _f, clip.size * _f)
	var most: float = maxf(0.0, ids.size() * 65.0 - 174.0)
	_quest_scroll = clampf(_quest_scroll, 0, most)
	for i: int in ids.size():
		var id: int = int(ids[i])
		var pos: Vector2 = clip.position + Vector2(0, 65 * i - _quest_scroll)
		if pos.y + 65 < clip.position.y or pos.y > clip.end.y:
			continue
		_clip_cell("bf_bar_track", Rect2(pos + Vector2(1, 23), _cell_size("bf_bar_track")), clip)
		var w: float = clampf(float(client.bonfire_count) / maxi(1, _threshold(id)) * 192, 0, _cell_size("bf_bar_thumb").x)
		_clip_cell("bf_bar_thumb", Rect2(pos + Vector2(1, 23), _cell_size("bf_bar_thumb")), clip.intersection(Rect2(pos + Vector2(1, 23), Vector2(w, 19))))
		if pos.y + 23 >= clip.position.y and pos.y + 46 <= clip.end.y:
			_fwords("%d/%d" % [int(client.bonfire_count), _threshold(id)], ARIAL_BOLD, 14, Color.WHITE, "c", pos + Vector2(1, 23), 192, 1.0, 20)
		var row: Array = pack.quest.get("quests", {}).get(str(id), [])
		if row.size() > 10:
			var rewards: Array = row[10]
			for j: int in rewards.size():
				_grid50(pos + Vector2(197 + 75 * j, 7.5), _item(int(rewards[j][0]), int(rewards[j][1])), clip)
		var over: bool = int(client.quests[id][0]) == 4
		var key: String = "bf_has_award" if over else ("bf_award" if int(client.bonfire_count) >= _threshold(id) else "bf_award_off")
		var sz: Vector2 = _cell_size(key)
		var button: Rect2 = _clip_cell(key, Rect2(pos + Vector2(256, (65 - sz.y) / 2), sz), clip)
		if not over and int(client.bonfire_count) >= _threshold(id):
			_hit("quest:%d" % id, button, false)
	if most > 0:
		var bar: Vector2 = clip.position + Vector2(326, 0)
		_fblit("bf_scroll_track", bar, 24, 174)
		_fbutton("quest_up", "bf_scroll_up", bar)
		_fbutton("quest_down", "bf_scroll_down", bar + Vector2(0, 150))
		var high: float = maxf(20, 126.0 * 174.0 / (ids.size() * 65.0))
		var thumb: Rect2 = _fblit("bf_scroll_thumb", bar + Vector2(3, 24 + (126 - high) * _quest_scroll / most), 18, high)
		_quest_thumb_rect = thumb
		_hit("quest_thumb", thumb, false)

func _draw_preview(base: Vector2) -> void :
	var clip: Rect2 = Rect2(base + Vector2(86, 435.5), Vector2(330, 56))
	_preview_rect = Rect2(clip.position * _f, Vector2(330, 75) * _f)
	_fpara(str(Data.WORDS.preview), ARIAL_BOLD, 16, Color.WHITE, base + Vector2(21, 449), 60, 3)
	_preview_scroll = clampf(_preview_scroll, 0, maxf(0, Data.PRESENT_ROWS.size() * 55 - 5 - 330))
	for i: int in Data.PRESENT_ROWS.size():
		var row: Dictionary = Data.PRESENT_ROWS[i]
		_grid50(clip.position + Vector2(i * 55 - _preview_scroll, 0), _item(int(row.nReuseA), int(row.iCount)), clip)
	var at: Vector2 = base + Vector2(86, 486.5)
	_hscroll_image("bf_scroll_track", at, 330, 24)
	_hscroll_image("bf_scroll_up", at, 24, 24)
	_hscroll_image("bf_scroll_down", at + Vector2(306, 0), 24, 24)
	_hit("preview_left", Rect2(at * _f, Vector2(24, 24) * _f), false)
	_hit("preview_right", Rect2((at + Vector2(306, 0)) * _f, Vector2(24, 24) * _f), false)
	var most: float = maxf(1, Data.PRESENT_ROWS.size() * 55 - 5 - 330)
	var wide: float = maxf(20, 282.0 * 330.0 / (Data.PRESENT_ROWS.size() * 55 - 5))
	var thumb_at: Vector2 = at + Vector2(24 + (282 - wide) * _preview_scroll / most, 3)
	_hscroll_image("bf_scroll_thumb", thumb_at, wide, 18)
	_preview_thumb_rect = Rect2(thumb_at * _f, Vector2(wide, 18) * _f)
	_hit("preview_thumb", _preview_thumb_rect, false)

func _hscroll_image(key: String, at: Vector2, wide: float, high: float) -> void :
	draw_set_transform((at + Vector2(0, high)) * _f, - PI / 2.0)
	_fblit(key, Vector2.ZERO, high, wide)
	draw_set_transform_matrix(Transform2D.IDENTITY)

func _activate(id: String) -> void :
	if not visible:
		return
	if _sheet_id == "rule":
		if id in ["rule_close", "shade"]:
			_close_sheet()
		return
	if not _sheet_id.is_empty():
		_sheet_activate(id)
		return
	if id in ["close", "cancel"]:
		close()
	elif id == "add":
		if can_add():
			client.use_item(2, wood_slot())
	elif id == "rule":
		_sheet_id = "rule"
	elif id.begins_with("quest:"):
		var quest: int = int(id.substr(6))
		if _my_level() >= int(Data.ACTIVITY.level) and quest_ids().has(quest) and int(client.bonfire_count) >= _threshold(quest):
			client.quest_complete(quest)
	elif id.begins_with("convert:"):
		_recount()
		var rows: Array = converts()
		for rec: Dictionary in rows:
			if int(rec.id) == int(id.substr(8)) and bool(_convert_button(rec)[1]):
				_open_confirm(rec)
	elif id.begins_with("cv_do:"):
		_recount()
		_convert_do(int(id.substr(6)))
	elif id.begins_with("cv_buy:"):
		quick_buy_asked.emit(int(id.substr(7)))
	elif id == "quest_up":
		_quest_scroll -= 65
	elif id == "quest_down":
		_quest_scroll += 65
	elif id == "preview_left":
		_preview_scroll -= 55
	elif id == "preview_right":
		_preview_scroll += 55

func _wheel(step: int, at: Vector2) -> void :
	if not _sheet_id.is_empty():
		return
	if _quest_rect.has_point(at):
		_quest_scroll += step * 32.5
	elif _preview_rect.has_point(at):
		_preview_scroll += step * 55

func _drag(moved: Vector2, from: Vector2) -> void :
	if not _sheet_id.is_empty():
		return
	if _quest_rect.has_point(from):
		_quest_scroll += moved.y / _f * (float(quest_ids().size()) * 65.0 / 174.0) if _quest_thumb_rect.has_point(from) else - moved.y / _f
	elif _preview_rect.has_point(from):
		_preview_scroll += moved.x / _f * (Data.PRESENT_ROWS.size() * 55.0 / 330.0) if _preview_thumb_rect.has_point(from) else - moved.x / _f

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		if not _sheet_id.is_empty():
			_close_sheet()
		else:
			close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
