extends "flash_screen.gd"










const Atlas = preload("quest_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const FriendsAtlas = preload("friends_atlas.gd")
const RewardPopup = preload("reward_popup.gd")
const RewardFly = preload("reward_fly.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")

signal closed
signal arena_asked
signal challenge_asked


const Q_TYPE: int = 0
const Q_NAME: int = 1
const Q_DESC: int = 2
const Q_CHECK: int = 3
const Q_COUNT: int = 4
const Q_FIZZ: int = 5
const Q_EXP: int = 6
const Q_GOLD: int = 7
const Q_GIFT: int = 8
const Q_THEW: int = 9
const Q_ITEMS: int = 10
const Q_LINK: int = 11
const Q_CHECK_TYPE: int = 12
const Q_CHECK_ID: int = 13
const Q_HEFT: int = 14
const Q_SHOW: int = 15
const Q_CHOICES: int = 16


const LINKS: Dictionary = {1: "arena", 12: "arena", 13: "arena", 18: "arena", 40: "arena", 58: "arena", 69: "arena", 74: "arena", 75: "arena", 
	2: "tank", 3: "guild", 30: "guild", 10: "shop", 32: "shop", 33: "shop", 48: "shop", 78: "shop", 16: "bag", 70: "bag", 
	22: "helper", 27: "helper", 28: "helper", 29: "helper", 52: "crystal", 31: "fair:wheel", 24: "challenge"}
const UI_QUEST: int = 12
const CKT_OPEN_UI: int = 27
const QTT_RANK: int = 5
const CKT_CASH_BACK: int = 87
const CKT_CASH_TODAY: int = 88
const CKT_LOGIN_RANGE: int = 106

const SECTIONS: Array = [[3, 41], [4], [11, 12, 21, 5, 22, 24, 23, 10, 42, 25]]
const NAMES: Array = ["Nhiệm vụ chính", "Nhiệm vụ phụ", "Nhiệm vụ hoạt động"]
const TABS: Dictionary = {"auto": 0, "main": 0, "side": 1, "act": 2}

const HEADS: Array = [[-1, 322, 361, 39], [-1, 38, 361, 78], [-1, 38, 77, 117]]
const MAIN_SIZE: Vector2 = Vector2(812, 512)
const LIVE_SIZE: Vector2 = Vector2(628, 452)
const BAR: float = 19.0
const VIEW_TRACK: float = 368.0
const LIST_TRACK: float = 246.0
const DAILY_TRACK: float = 160.0
const SHOWN: int = 7
const DAILY_SHOWN: int = 6
const PITCH: float = 36.0
const DAILY_PITCH: float = 32.0
const VIEW_STEP: float = 15.0
const VIEW_HIGH: float = 406.0

const NAME_RIM: Color = Color("086da5", 0.8)
const DESC_RIM: Color = Color("0066ae", 0.8)
const GOAL_RIM: Color = Color("0390d3", 0.8)
const TASK_RIM: Color = Color("0066ae", 0.8)
const TILE_RIM: Color = Color("005797", 0.8)
const NO_QUEST_RIM: Color = Color("086da5", 0.8)
const POINT_RIM: Color = Color(1, 1, 1, 0.4)
const STAR_INK: Array = [Color("ffffff"), Color("ffd43f"), Color("ff6c6c")]
const DIM: Color = Color(0, 0, 0, 0.4)
const ASK_SIZE: Vector2 = Vector2(450, 220)
const THEW_FULL: int = 500
const ASK_THEW: String = "Đã đầy thể Lực, nhận nữa sẽ không tăng thêm, nhận chứ?"
const TIP_73: String = "Không thể tiến hành thao tác này"
const SOON: String = "Mục này đang được chuyển sang HTML5."


const LINK_ENTER_MAP: int = 17


const LINK_PVE: Array = [6, 19, 23]
const TUTOR_MAPS: Array = preload("training.gd").PLAYABLE
const TUTOR_LOBBY: String = "Hãy về sảnh chính rồi bấm Đi để vào bản đồ huấn luyện."



const LINK_CLAN_MATCH: int = 14
const GUILD_FLAG: int = 268435456
const TIP_69: String = "Vào Team trước rồi tham gia giải đấu Team"
const TIP_355: String = "Guild chưa mở, hãy làm xong NV PB Chính"

var tab: String = "auto"
var _mode: String = "main"
var _section: int = 0
var _first: int = 0
var _pick: int = 0
var _choice: int = 0
var _scroll: float = 0.0
var _daily_first: int = 0
var _rev: int = -1
var _lists: Array = [[], [], []]
var _daily: Array = []
var _seen: Dictionary = {}
var _quests_obj: Dictionary = {}
var _primed: bool = false
var _keep: bool = false
var _loaded_at_open: bool = false
var _help_at: float = -10.0
var _wait: int = 0
var _ask: int = 0
var _wait_at: float = 0.0
var _chest_at: float = -10.0
var _note: String = ""
var _note_at: float = 0.0
var _reap_pop: int = 0
var _reap_at: float = 0.0
var _told: bool = false
var _failed: bool = false
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _sheet_id: String = ""
var _reward: RefCounted = RewardPopup.new()
var _flies: Array = []
var _grab: String = ""
var _grab_at: Vector2 = Vector2.ZERO
var _grab_first: float = 0.0
var _pull: float = 0.0
var _bars: Dictionary = {}
var _list_rect: Rect2 = Rect2()
var _view_rect: Rect2 = Rect2()
var _daily_rect: Rect2 = Rect2()
var _content_h: float = 0.0
var _clipper: Control
var _clip_ops: Array = []
var _hole_px: Rect2 = Rect2()
var _wraps: Dictionary = {}

func _setup() -> void :
	pack.picture_ready.connect(_on_pack)
	client.awarded.connect(_on_award)
	client.stage_reaped.connect(_on_reaped)
	client.quest_failed.connect(_on_failed)
	_clipper = Control.new()
	_clipper.clip_contents = true
	_clipper.show_behind_parent = true
	_clipper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_clipper)
	_clipper.draw.connect(_replay)
	var guide_view: Control = preload("guide_view.gd").new()
	guide_view.setup(self, "quest")
	add_child(guide_view)

func _shown() -> void :
	_reward.reset()
	_sheet_id = ""
	_flies = []
	RewardFly.reset(self)
	_tip = []
	_grab = ""
	if not is_visible_in_tree():
		return
	pack.load_quest()
	pack.load_questx()
	pack.load_bag()
	if pack.quest.is_empty():
		_failed = false
	_rev = -1
	_wait = 0
	_ask = 0
	_note = ""
	_reap_pop = 0
	_told = false
	_help_at = -10.0
	_primed = false
	_keep = tab.is_empty()
	_loaded_at_open = client.quests_loaded
	if _keep:
		return
	_mode = "live" if tab == "live" else "main"
	_section = int(TABS.get(tab, 0))
	tab = ""
	_first = 0
	_pick = 0
	_choice = 0
	_scroll = 0.0
	_daily_first = 0
	_pull = 0.0
	_seen = {}




func guide_open(ui: String) -> bool:
	return ui == "questWindow" and _mode == "main"



func guide_select(quest: int) -> bool:
	if not _primed or _mode != "main":
		return false
	var section: int = _section_of_quest(quest)
	if section < 0 or not _lists[section].has(quest):
		return true
	var list: Array = _lists[section]
	var index: int = list.find(quest)
	_section = section
	if quest != _pick:
		_pick = quest
		_choice = 0
	_first = int(float(index) / float(list.size()) * float(maxi(0, list.size() - SHOWN)))
	return true


func guide_close(_ui: String) -> void :
	closed.emit()

func _on_pack(path: String) -> void :
	if path == "l/quest.json":
		_failed = pack.quest.is_empty()
		_rev = -1
	elif path == "l/bag.json":
		_wraps.clear()



func _ready_data() -> bool:
	return not pack.quest.is_empty() and client.quests_loaded

func _tmpl(quest: int) -> Array:
	var row: Variant = pack.quest.get("quests", {}).get(str(quest))
	return row if row is Array and row.size() > Q_SHOW else []

func _state(quest: int) -> int:
	return int(client.quests.get(quest, [0])[0])

func _count(quest: int) -> int:
	var info: Array = client.quests.get(quest, [])
	return int(info[1]) if info.size() > 1 else 0

func _title(quest: int, row: Array) -> String:
	return str(row[Q_NAME]) if not str(row[Q_NAME]).is_empty() else "Nhiệm vụ %d" % quest

func _goal(row: Array) -> String:
	return str(row[Q_CHECK]) if not str(row[Q_CHECK]).is_empty() else str(row[Q_DESC])

func _stages() -> Array:
	return pack.quest.get("stages", [])


func _current() -> int:
	for stage: Array in _stages():
		if client.stages.has(int(stage[0])):
			return int(stage[0])
	return 0

func _all_reaped() -> bool:
	var stages: Array = _stages()
	return not stages.is_empty() and client.stages_cleared.has(int(stages[-1][0]))

func _top() -> int:
	var stages: Array = _stages()
	return maxi(1, int(stages[-1][1])) if not stages.is_empty() else 200


func _fizz() -> int:
	var total: int = 0
	for quest: int in _daily:
		if _state(quest) >= 3:
			total += int(_tmpl(quest)[Q_FIZZ])
	total = mini(_top(), total)
	var current: int = _current()
	if current != 0:
		total = maxi(total, int(client.stages[current].get("value", 0)))
	return total


func _wants_open_note() -> bool:
	if _current() == 0 and not _all_reaped():
		return true
	for key: Variant in client.quests:
		var row: Array = _tmpl(int(key))
		if not row.is_empty() and _state(int(key)) == 2 and int(row[Q_CHECK_TYPE]) == CKT_OPEN_UI and int(row[Q_CHECK_ID]) == UI_QUEST:
			return true
	return false

func _extra(quest: int) -> Dictionary:
	var info: Variant = pack.questx.get("quests", {}).get(str(quest))
	return info if info is Dictionary else {}

func _star(quest: int) -> int:
	return clampi(int(_extra(quest).get("star", 0)), 0, 2)

func _ink(quest: int) -> Color:
	return STAR_INK[_star(quest)]

func _section_of(kind: int) -> int:
	for index: int in SECTIONS.size():
		if kind in SECTIONS[index]:
			return index
	return -1

func _section_of_quest(quest: int) -> int:
	var row: Array = _tmpl(quest)
	return _section_of(int(row[Q_TYPE])) if not row.is_empty() else -1


func _rank(quest: int) -> int:
	var state: int = _state(quest)
	return 0 if state == 3 else (2 if state == 4 else 1)

func _before(a: int, b: int) -> bool:
	var rank_a: int = _rank(a)
	var rank_b: int = _rank(b)
	if rank_a != rank_b:
		return rank_a < rank_b
	var heft_a: int = int(_tmpl(a)[Q_HEFT])
	var heft_b: int = int(_tmpl(b)[Q_HEFT])
	return heft_a > heft_b if heft_a != heft_b else a < b

func _ratio(quest: int) -> float:
	return float(_count(quest)) / maxf(1.0, float(_tmpl(quest)[Q_COUNT]))


func _before_daily(a: int, b: int) -> bool:
	var ratio_a: float = _ratio(a)
	var ratio_b: float = _ratio(b)
	if not is_equal_approx(ratio_a, ratio_b):
		return ratio_a > ratio_b
	var heft_a: int = int(_tmpl(a)[Q_HEFT])
	var heft_b: int = int(_tmpl(b)[Q_HEFT])
	return heft_a > heft_b if heft_a != heft_b else a < b

func _rebuild() -> void :
	_lists = [[], [], []]
	_daily = []
	for key: Variant in client.quests:
		var quest: int = int(key)
		var row: Array = _tmpl(quest)
		if row.is_empty() or int(row[Q_SHOW]) != 1:
			continue
		var kind: int = int(row[Q_TYPE])
		if kind == 1:
			_daily.append(quest)
			continue
		var section: int = _section_of(kind)
		if section >= 0:
			_lists[section].append(quest)
	for list: Array in _lists:
		list.sort_custom(_before)
	_daily.sort_custom(_before_daily)

func _sig(quest: int) -> Array:
	var info: Array = client.quests.get(quest, [])
	return [int(info[0]) if info.size() > 0 else 0, int(info[1]) if info.size() > 1 else 0, int(info[4]) if info.size() > 4 else 0]

func _snapshot() -> void :
	_seen = {}
	for key: Variant in client.quests:
		_seen[int(key)] = _sig(int(key))


func _diff() -> Array:
	var out: Array = []
	for key: Variant in client.quests:
		var quest: int = int(key)
		if not _seen.has(quest) or _seen[quest] != _sig(quest):
			out.append(quest)
	for quest: int in _seen:
		if not client.quests.has(quest):
			out.append(quest)
	return out


func _refresh(index: int) -> void :
	var list: Array = _lists[_section]
	_pick = int(list[index]) if index < list.size() else 0
	_choice = 0
	_first = 0


func _keep_pick() -> void :
	var list: Array = _lists[_section]
	_first = clampi(_first, 0, maxi(0, list.size() - SHOWN))
	if not list.has(_pick):
		_refresh(0)


func _select_reward() -> void :
	for section: int in _lists.size():
		var list: Array = _lists[section]
		for index: int in list.size():
			var quest: int = int(list[index])
			if _state(quest) != 3:
				continue
			if int(_tmpl(quest)[Q_TYPE]) == 41:
				return
			_section = section
			_pick = quest
			_choice = 0
			var most: int = maxi(0, list.size() - SHOWN)
			_first = int(float(index) / float(list.size()) * float(most))
			return


func _prime() -> void :
	_primed = true
	_rev = client.quest_rev
	_quests_obj = client.quests
	_rebuild()
	_keep_pick()
	_snapshot()
	if _mode == "main" and not _keep and not _loaded_at_open:
		_select_reward()


func _on_quests_changed() -> void :
	_rev = client.quest_rev
	_rebuild()
	var fresh: bool = not is_same(client.quests, _quests_obj)
	_quests_obj = client.quests
	if _mode == "live":
		_snapshot()
		return
	if fresh:
		_snapshot()
		_refresh(0)
		_select_reward()
		return
	var changed: Array = _diff()
	_snapshot()
	if changed.is_empty():
		_keep_pick()
		return
	for quest: int in changed:
		if _section_of_quest(quest) == _section:
			_refresh(0)
			break
	_keep_pick()
	_select_reward()


func _due(section: int) -> String:
	var count: int = 0
	for quest: int in _lists[section]:
		if _state(quest) == 3:
			count += 1
	return "(Được nhận:%d)" % count if count > 0 else ""


func _item(id: int, count: int) -> Dictionary:
	var info: Variant = pack.quest.get("items", {}).get(str(id))
	var row: Array = info if info is Array else []
	var found: Variant = pack.bag.get("items", {}).get(str(id))
	var more: Array = found if found is Array else []
	var title: String = "Vật phẩm %d" % id
	if not more.is_empty() and not str(more[0]).is_empty():
		title = BagModel.clean(str(more[0]))
	elif not row.is_empty() and not str(row[0]).is_empty():
		title = str(row[0])
	var icon: String = str(row[1]) if row.size() > 1 and not str(row[1]).is_empty() else (str(more[2]) if more.size() > 2 else "")
	var quality: int = int(row[2]) if row.size() > 2 else (int(more[3]) if more.size() > 3 else 0)
	var folder: String = "l/av/" if more.size() > 5 and int(more[5]) == 4 else "l/it/"
	return {"kind": "item", "id": id, "count": count, "name": title, "art": folder + icon + ".webp" if not icon.is_empty() else "", 
		"quality": quality, "desc": GarageModel.plain(str(more[1])) if more.size() >= 10 else ""}


func _gifts(row: Array) -> Array:
	var out: Array = []
	if int(row[Q_EXP]) > 0:
		out.append({"kind": "exp", "id": 0, "count": int(row[Q_EXP]), "name": "EXP", "quality": 1})
	if int(row[Q_GOLD]) > 0:
		out.append({"kind": "money", "id": 0, "count": int(row[Q_GOLD]), "name": "Bạc", "quality": 1})
	if int(row[Q_GIFT]) > 0:
		out.append({"kind": "gift", "id": 0, "count": int(row[Q_GIFT]), "name": "Xu Khóa", "quality": 2})
	if int(row[Q_THEW]) > 0:
		out.append({"kind": "thew", "id": 0, "count": int(row[Q_THEW]), "name": "Thể Lực", "quality": 1})
	for pair: Variant in row[Q_ITEMS]:
		if pair is Array and (pair as Array).size() >= 2 and int(pair[0]) != 0:
			out.append(_item(int(pair[0]), int(pair[1])))
	return out


func _choices(row: Array) -> Array:
	var out: Array = []
	if row.size() > Q_CHOICES and row[Q_CHOICES] is Array:
		for pair: Variant in row[Q_CHOICES]:
			if pair is Array and (pair as Array).size() >= 2 and int(pair[0]) != 0:
				out.append(_item(int(pair[0]), int(pair[1])))
	return out


func _plan(quest: int, row: Array) -> String:
	if int(_extra(quest).get("hide", 0)) != 0:
		return ""
	var count: int = _count(quest)
	if int(row[Q_TYPE]) == QTT_RANK:
		return "Tạm không có hạng" if count == 0 else "Thứ %d" % count
	var check: int = int(row[Q_CHECK_TYPE])
	if check == CKT_CASH_BACK or check == CKT_CASH_TODAY:
		return "Chưa tiêu phí" if count == 0 else "Tiêu phí:%d" % count
	if check == CKT_LOGIN_RANGE:
		return _range_plan(quest)
	return "%d/%d" % [count, int(row[Q_COUNT])]




func _range_plan(quest: int) -> String:
	match _state(quest):
		3:
			return ""
		4:
			return "Đã nhận"
	return "Đã hết giờ" if _count(quest) >= 2 else "Chưa tới giờ"


func _range_right(x0: float) -> float:
	var cell: Array = _cells.get("qu_tick34", [])
	return x0 + 663.0 + (float(cell[1][2]) if not cell.is_empty() else 34.0)



func _goal_wide(quest: int, row: Array, x0: float) -> float:
	if int(row[Q_CHECK_TYPE]) != CKT_LOGIN_RANGE:
		return 280.0
	var plan: String = _plan(quest, row)
	var cell: Array = _cells.get("qu_tick34", [])
	var used: float = (float(cell[1][2]) if not cell.is_empty() else 34.0) if plan.is_empty()\
	else _face(BOLD).get_string_size(plan, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(12.0 * _f))).x / _f
	return clampf(_range_right(x0) - used - 10.0 - (x0 + 337.0), 60.0, 280.0)


func _when(at: int) -> String:
	var day: Dictionary = Time.get_datetime_dict_from_unix_time(at + 7 * 3600)
	return "%02dh%02d'  %02d-%02d-%04d" % [int(day.hour), int(day.minute), int(day.day), int(day.month), int(day.year)]


func _desc_lines(quest: int, row: Array) -> Array:
	var lines: Array = _wrap(str(row[Q_DESC]), BOLD, 13.0, 372.0)
	var info: Array = client.quests.get(quest, [])
	if info.size() > 4 and int(info[4]) != 0:
		lines = lines + _wrap("Thời hạn: " + _when(int(info[4])), BOLD, 13.0, 372.0)
	return lines


func _wrap(text: String, font: Font, px: float, wide: float) -> Array:
	var face: Font = _face(font)
	var key: String = "%d|%d|%d|%d|%s" % [int(face == ARIAL_BOLD), roundi(px * 100.0), roundi(wide), roundi(_f * 1000.0), text]
	if _wraps.has(key):
		return _wraps[key]
	if _wraps.size() > 400:
		_wraps.clear()
	var font_size: int = maxi(6, roundi(px * _f))
	var limit: float = wide * _f
	var out: Array = []
	for part: String in text.split("\n"):
		var line: String = ""
		for word: String in part.split(" "):
			var trial: String = word if line.is_empty() else line + " " + word
			if line.is_empty() or face.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= limit:
				line = trial
			else:
				out.append(line)
				line = word
		out.append(line)
	if out.is_empty():
		out.append("")
	_wraps[key] = out
	return out


func _tiles_high(count: int) -> float:
	return 22.0 + maxf(0.0, ceilf(count / 5.0) * 116.0 - 6.0)

func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))



func _tick(_delta: float) -> void :
	if _sheet_id == "award" and _reward.tick(self):
		_close_sheet()
	if not _note.is_empty() and _time >= _note_at:
		say(_note)
		_note = ""
	if _reap_pop != 0 and _time - _reap_at > 1.2:
		_reap_award()
	if not _ready_data():
		return
	if not _primed:
		_prime()
	elif client.quest_rev != _rev or not is_same(client.quests, _quests_obj):
		_on_quests_changed()
	if not _told:
		_told = true
		if _wants_open_note():
			client.quest_open_ui(UI_QUEST)
	if _wait != 0 and (_state(_wait) != 3 or _time - _wait_at > 4.0):
		_wait = 0


func _on_award(info: Dictionary) -> void :
	if not is_visible_in_tree() or client.award_op in [1, 7, 9, 13, 14, 15, 19, 26, 27, 29, 30]:
		return
	_note = ""
	if _reap_pop != 0:

		_reap_pop = 0
		_flies.append_array(RewardFly.begin(self, info))
		return
	if client.award_show == 0 or client.award_op == 8:
		_flies.append_array(RewardFly.begin(self, info))
	elif RewardPopup.has_rewards(info):
		_reward.begin(self, info)
		_sheet_id = "award"

func _on_reaped(result: int, stage: int) -> void :
	if not is_visible_in_tree():
		return
	for row: Array in _stages():
		if int(row[0]) == stage:
			match result:
				0:
					_reap_pop = stage
					_reap_at = _time
				1:
					say("Rương này đã nhận rồi.")
				_:
					say("Chưa đủ điểm năng động để mở rương này.")

func _reap_award() -> void :
	var stage: int = _reap_pop
	_reap_pop = 0
	for row: Array in _stages():
		if int(row[0]) == stage:
			_flies.append_array(RewardFly.begin(self, {"items": [[int(row[2]), int(row[3])]]}))


func _reward_cell(id: int) -> String:
	for row: Array in _stages():
		if int(row[2]) == id:
			return "qu_chest_has"
	return ""

func _on_failed(_quest: int) -> void :
	_wait = 0
	_note = ""
	if is_visible_in_tree():
		say("Chưa nhận được thưởng nhiệm vụ này.")



func _cblit(cell_name: String, at: Vector2, wide: float = 0.0, high: float = 0.0, tint: Color = Color.WHITE) -> Rect2:
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty():
		return Rect2(at * _f, Vector2(wide, high) * _f)
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(wide if wide > 0.0 else float(region[2]), high if high > 0.0 else float(region[3])) * _f)
	if cell[0] != null:
		_clip_ops.append([0, cell[0], rect, Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])), tint])
	return rect

func _cpart(cell_name: String, at: Vector2, from: Rect2, tint: Color = Color.WHITE) -> void :
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty() or cell[0] == null:
		return
	_clip_ops.append([0, cell[0], Rect2(at * _f, from.size * _f), Rect2(Vector2(float(cell[1][0]), float(cell[1][1])) + from.position, from.size), tint])

func _cpic(texture: Texture2D, rect: Rect2) -> void :
	if texture != null:
		_clip_ops.append([1, texture, rect])

func _crect(rect: Rect2, color: Color) -> void :
	_clip_ops.append([3, rect, color])


func _cwords(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, wide: float, edge: float = 0.0, high: float = 0.0, shrink: bool = true, rim: Color = SHADE) -> float:
	var face: Font = _face(font)
	var shown: float = px
	if shrink:
		while shown > 8.0 and face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(shown * _f))).x > wide * _f:
			shown -= 1.0
	var font_size: int = maxi(6, roundi(shown * 2.0 * _u))
	var middle: float = at.y + (high / 2.0 if high > 0.0 else 2.0 + px * 0.55)
	var x: float = at.x if align == "l" else (at.x + wide / 2.0 if align == "c" else at.x + wide)
	var origin: Vector2 = Vector2(x, middle) * _f
	var width: float = wide * _f
	var mode: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
	if align == "c":
		origin.x -= width / 2.0
		mode = HORIZONTAL_ALIGNMENT_CENTER
	elif align == "r":
		origin.x -= width
		mode = HORIZONTAL_ALIGNMENT_RIGHT
	origin.y += (face.get_ascent(font_size) - face.get_descent(font_size)) / 2.0
	var outline: int = maxi(1, roundi(edge * 2.0 * _u)) if edge > 0.0 else 0
	_clip_ops.append([2, face, origin, text, mode, width, font_size, color, outline, Color(rim, rim.a * color.a)])
	return minf(width, face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x) / _f


func _chit(id: String, rect: Rect2) -> void :
	var cut: Rect2 = rect.intersection(_hole_px)
	if cut.has_area():
		_hit(id, cut, false)

func _replay() -> void :
	_clipper.draw_set_transform( - _clipper.position)
	var top: float = _hole_px.position.y - 60.0 * _f
	var bottom: float = _hole_px.end.y + 60.0 * _f
	for op: Array in _clip_ops:
		match int(op[0]):
			0:
				if (op[2] as Rect2).intersects(_hole_px):
					_clipper.draw_texture_rect_region(op[1], op[2], op[3], op[4])
			1:
				if (op[2] as Rect2).intersects(_hole_px):
					_clipper.draw_texture_rect(op[1], op[2], false)
			2:
				var origin: Vector2 = op[2]
				if origin.y >= top and origin.y <= bottom:
					if int(op[8]) > 0:
						_clipper.draw_string_outline(op[1], origin, op[3], op[4], op[5], op[6], op[8], op[9])
					_clipper.draw_string(op[1], origin, op[3], op[4], op[5], op[6], op[7])
			3:
				_clipper.draw_rect(op[1], op[2])


func _snap(rect: Rect2) -> Rect2:
	var k: float = 1.0
	if is_inside_tree():
		k = (get_viewport().get_final_transform() * get_global_transform_with_canvas()).get_scale().x
	if k <= 0.0:
		k = 1.0
	var top: Vector2 = (rect.position * k).round() / k
	var end: Vector2 = (rect.end * k).round() / k
	return Rect2(top, end - top)


func _strips(outer: Rect2, hole: Rect2) -> Array:
	var cut: Rect2 = outer.intersection(hole)
	if not cut.has_area():
		return [outer]
	var out: Array = []
	if cut.position.y > outer.position.y:
		out.append(Rect2(outer.position, Vector2(outer.size.x, cut.position.y - outer.position.y)))
	if cut.end.y < outer.end.y:
		out.append(Rect2(Vector2(outer.position.x, cut.end.y), Vector2(outer.size.x, outer.end.y - cut.end.y)))
	if cut.position.x > outer.position.x:
		out.append(Rect2(Vector2(outer.position.x, cut.position.y), Vector2(cut.position.x - outer.position.x, cut.size.y)))
	if cut.end.x < outer.end.x:
		out.append(Rect2(Vector2(cut.end.x, cut.position.y), Vector2(outer.end.x - cut.end.x, cut.size.y)))
	return out


func _frame_bg(cell_name: String, panel_at: Vector2) -> void :
	var full: Rect2 = Rect2(Vector2.ZERO, size)
	var path: String = hall_picture(hall, pack.lobby.get("halls", {}))
	var picture: Texture2D = pack.picture(path) if not path.is_empty() else null
	var place: Rect2 = hall_rect(hall, picture.get_size(), size) if picture != null else full
	for strip: Rect2 in _strips(full, _hole_px):
		if not overlay:
			draw_rect(strip, NAVY)
			if picture != null:
				var ratio: Vector2 = picture.get_size() / place.size
				draw_texture_rect_region(picture, strip, Rect2((strip.position - place.position) * ratio, strip.size * ratio))
		draw_rect(strip, DIM)
	if not overlay:
		_crect(full, NAVY)
		_cpic(picture, place)
	_crect(full, DIM)
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var panel: Rect2 = Rect2(panel_at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	var origin: Vector2 = Vector2(float(region[0]), float(region[1]))
	for strip: Rect2 in _strips(panel, _hole_px):
		draw_texture_rect_region(cell[0], strip, Rect2(origin + (strip.position - panel.position) / _f, strip.size / _f))
	_clip_ops.append([0, cell[0], panel, Rect2(origin, Vector2(float(region[2]), float(region[3]))), Color.WHITE])



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		var ask: Dictionary = {}
		for key: String in FriendsAtlas.R:
			if key.begins_with("fr_ask"):
				ask[key] = FriendsAtlas.R[key]
		_use(FriendsAtlas.FILE, ask)
	_tip = []
	_clip_ops = []
	_bars = {}
	var live: bool = _mode == "live"
	var box: Vector2 = LIVE_SIZE if live else MAIN_SIZE
	var base: Vector2 = _centre(box.x, box.y)
	var spec: Array = Atlas.LIVE["list"] if live else Atlas.MAIN["vbox"]
	var hole: Rect2 = Rect2(base + _v(spec), Vector2(float(spec[2]), float(spec[3])))
	_hole_px = _snap(Rect2(hole.position * _f, hole.size * _f))
	if _clipper.position != _hole_px.position or _clipper.size != _hole_px.size:
		_clipper.position = _hole_px.position
		_clipper.size = _hole_px.size
	_frame_bg("qu_live" if live else "qu_main", base + _v(Atlas.PANELS["live" if live else "main"]))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_hit("panel", Rect2(base * _f, box * _f), false)
	if live:
		_draw_live(base)
	else:
		_draw_main(base)
	_draw_flies()
	_draw_tip()
	if _ask != 0:
		_paint_ask()
	_clipper.visible = _sheet_id.is_empty()
	if _sheet_id == "award":
		_reward.paint(self)
	_clipper.queue_redraw()


func _paint_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("ask_shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(ASK_SIZE.x, ASK_SIZE.y)
	_hit("ask_panel", Rect2(at * _f, ASK_SIZE * _f), false)
	_fblit("fr_ask", at + Vector2(46, 1))
	_fblit("fr_ask_guy", at + Vector2(-80, -76))
	_fpara(ASK_THEW, ARIAL_BOLD, 14, Color.WHITE, at + Vector2(102, 38), 270, 5)
	_fbutton("ask_ok", "fr_ask_ok", at + Vector2(120, 133))
	_fbutton("ask_no", "fr_ask_no", at + Vector2(240, 133))


func _draw_main(base: Vector2) -> void :
	_fbutton("close", "qu_close", base + _v(Atlas.MAIN["btnClose"]))
	var loaded: bool = _ready_data() and _primed
	_draw_heads(base, loaded)
	var quest: int = _pick if loaded and _lists[_section].has(_pick) else 0
	var row: Array = _tmpl(quest) if quest != 0 else []
	_view_rect = Rect2((base + Vector2(283, 76)) * _f, Vector2(476, VIEW_HIGH) * _f)
	if row.is_empty():
		_content_h = 0.0
		_scroll = 0.0
	else:
		_draw_detail(base, quest, row)
	var state: int = _state(quest) if not row.is_empty() else 0
	var goto: bool = not row.is_empty() and int(row[Q_LINK]) != 0 and state != 3
	var spot: Vector2 = base + _v(Atlas.MAIN["btnGetReward"])
	if goto or state == 3:
		var cells: Array = Atlas.FX["cells"]
		var cell: String = str(cells[int(_time * float(Atlas.FX["rate"])) % cells.size()])
		if not cell.is_empty():
			_fblit(cell, base + _v(Atlas.MAIN["swfGotoFx"]) + _v(Atlas.FX["at"]))
	if state == 3:
		_fbutton("get", "qu_get", spot)
	else:
		_fblit("qu_get_off", spot)
	if goto:
		_fbutton("goto", "qu_goto", spot)
	if state == 4:
		_hit("panel", _fblit("qu_got", spot), false)
	_draw_help(base)
	if row.is_empty():
		_fwords(_empty_text(), BOLD, 26.0, Color.WHITE, "c", base + Vector2(322, 210), 400.0, 1.0, 0.0, true, NO_QUEST_RIM)


func _empty_text() -> String:
	if not (_ready_data() and _primed):
		return "Không tải được bảng nhiệm vụ. Đóng rồi mở lại." if _failed else "Đang tải nhiệm vụ…"
	return "Hiện chưa có " + str(NAMES[_section])


func _draw_heads(base: Vector2, loaded: bool) -> void :
	var heads: Array = HEADS[_section]
	var top: Vector2 = base + Vector2(49, 80.0 + float(heads[3]))
	_list_rect = Rect2(top * _f, Vector2(186, 284) * _f)
	_fblit("qu_content", top)
	var list: Array = _lists[_section] if loaded else []
	_first = clampi(_first, 0, maxi(0, list.size() - SHOWN))
	for k: int in range(SHOWN + 1):
		var index: int = _first + k
		if index >= list.size():
			break
		_draw_task(int(list[index]), top + Vector2(0, PITCH * k + 2.0), k == SHOWN)
	if list.size() > SHOWN:
		_scrollbar("list", top + Vector2(167, 0), LIST_TRACK, float(SHOWN), float(list.size()), float(_first))
	for i: int in range(3):
		var at: Vector2 = base + Vector2(47, 80.0 + float(heads[i]))
		_hit("head:%d" % i, _fblit("qu_head_on" if i == _section else "qu_head", at), false)
		_fwords(str(NAMES[i]) + (_due(i) if loaded else ""), BOLD, 14.0, Color.WHITE, "l", at + Vector2(32, 0), 148.0, 0.0, 40.0)


func _draw_task(quest: int, at: Vector2, cut: bool) -> void :
	if cut:
		_fpart("qu_task", at + _v(Atlas.TASK["bg"]), Rect2(0, 0, 161, 30))
	else:
		_fblit("qu_task", at + _v(Atlas.TASK["bg"]))
	if quest == _pick:
		_fblit("qu_task_on", at + _v(Atlas.TASK["on"]))
	var extra: Dictionary = _extra(quest)
	var group: int = int(extra.get("group", 0))
	if group == 1 or group == 2:
		_fblit("qu_pvp" if group == 1 else "qu_pve", at)
	_fwords(_title(quest, _tmpl(quest)), BOLD, 13.0, _ink(quest), "l", at + Vector2(31.0 if group == 1 or group == 2 else 24.0, 5.0), 136.0, 1.0, 0.0, true, TASK_RIM)
	if _state(quest) == 3:
		_fblit("qu_tick", at + _v(Atlas.TASK["tick"]))
	elif int(extra.get("rec", 0)) != 0:
		_fblit("qu_rec", at + _v(Atlas.TASK["rec"]))
	_hit("quest:%d" % quest, Rect2(at * _f, Vector2(179, 30.0 if cut else 32.0) * _f), false)


func _draw_detail(base: Vector2, quest: int, row: Array) -> void :
	var desc: Array = _desc_lines(quest, row)
	var head: float = 26.0 + 15.0 * desc.size()
	var choices: Array = _choices(row)
	var gifts: Array = _gifts(row)
	var choose_h: float = _tiles_high(choices.size())
	_content_h = 6.0 + head + 10.0 + 62.0 + 10.0 + choose_h + 10.0 + _tiles_high(gifts.size()) + 30.0
	var most: float = maxf(0.0, _content_h - VIEW_HIGH)
	_scroll = clampf(_scroll, 0.0, most)
	var x0: float = base.x
	var y: float = base.y + 76.0 + 6.0 - _scroll

	_cblit("qu_w_mission", Vector2(x0 + 293, y + 2))
	_cwords(_title(quest, row), BOLD, 14.0, _ink(quest), "l", Vector2(x0 + 343, y), 180.0, 1.0, 0.0, true, NAME_RIM)
	for i: int in desc.size():
		_cwords(str(desc[i]), BOLD, 13.0, Color.WHITE, "l", Vector2(x0 + 315, y + 22.0 + 15.0 * i), 376.0, 1.0, 0.0, false, DESC_RIM)
	_cblit("qu_w_nandu", Vector2(x0 + 615, y))
	var lit: int = mini(_star(quest) + 1, 3)
	for k: int in range(3):
		_cblit("qu_star" if k < lit else "qu_star_off", Vector2(x0 + 664.3 + 23.8 * k, y), 19.55, 18.7)
	_cblit("qu_line", Vector2(x0 + 284.5, y + head))
	y += head + 10.0

	_cblit("qu_w_goal", Vector2(x0 + 293, y))
	_cblit("qu_listbk", Vector2(x0 + 325, y + 19))
	var check: Array = _wrap(_goal(row), BOLD, 12.0, _goal_wide(quest, row, x0))
	if check.size() > 2:
		check = check.slice(0, 2)
	for i: int in check.size():
		var middle: float = y + 41.0 - (check.size() - 1) * 7.5 + 15.0 * i
		_cwords(str(check[i]), BOLD, 12.0, Color.WHITE, "l", Vector2(x0 + 337, middle - 7.5), 280.0, 1.0, 15.0, false, GOAL_RIM)
	if int(row[Q_CHECK_TYPE]) == CKT_LOGIN_RANGE:
		_cwords(_plan(quest, row), BOLD, 12.0, Color.WHITE, "r", Vector2(_range_right(x0) - 160.0, y + 33.5), 160.0, 1.0, 15.0, true, GOAL_RIM)
	else:
		_cwords(_plan(quest, row), BOLD, 14.0, Color.WHITE, "l", Vector2(x0 + 626, y + 30), 110.0, 1.0, 0.0, true, GOAL_RIM)
	if _state(quest) == 3:
		_cblit("qu_tick34", Vector2(x0 + 663, y + 25))
	_cblit("qu_line", Vector2(x0 + 284.5, y + 62))
	y += 62.0 + 10.0

	if not choices.is_empty():
		_award_block("qu_w_choose", choices, Vector2(x0, y), true)
		_cblit("qu_line", Vector2(x0 + 284.5, y + choose_h))
		y += choose_h + 10.0
	_award_block("qu_w_reward", gifts, Vector2(x0, y), false)
	if _content_h > VIEW_HIGH:
		_scrollbar("view", base + Vector2(740, 76), VIEW_TRACK, VIEW_HIGH, _content_h, _scroll)

func _award_block(label_cell: String, gifts: Array, at: Vector2, choose: bool) -> void :
	_cblit(label_cell, at + Vector2(293, 0))
	for i: int in gifts.size():
		var gift: Dictionary = gifts[i]
		var spot: Vector2 = at + Vector2(286.0 + 91.0 * (i % 5), 22.0 + 116.0 * floorf(i / 5.0))
		_draw_tile(gift, spot, choose and int(gift.id) == _choice, "choose:%d" % int(gift.id) if choose else "")


func _draw_tile(gift: Dictionary, at: Vector2, chosen: bool, id: String) -> void :
	_cblit("qu_aw_bg", at + _v(Atlas.AWARD["bg"]))
	_cblit("qu_q%d" % clampi(int(gift.quality), 1, 5), at + _v(Atlas.AWARD["quality"]))
	if chosen:
		_cblit("qu_aw_sel", at + _v(Atlas.AWARD["select"]))
	match str(gift.kind):
		"item":
			var art: String = str(gift.get("art", ""))
			var picture: Texture2D = pack.picture(art) if not art.is_empty() else null
			if picture != null:
				_cpic(picture, _fit_rect(picture, Rect2((at + _v(Atlas.AWARD["item"])) * _f, Vector2(76, 76) * _f)))
		"exp":
			_cblit("qu_aw_exp", at + _v(Atlas.AWARD["coin"]))
		"money":
			_cblit("qu_aw_money", at + _v(Atlas.AWARD["coin"]))
		"gift":
			_cblit("qu_aw_gift", at + Vector2(16.5, 3))
		"thew":
			_cblit("qu_aw_thew", at + _v(Atlas.AWARD["thew"]))
	var lines: Array = _wrap(str(gift.name), BOLD, 12.0, 66.0)
	for i: int in lines.size():
		_cwords(str(lines[i]), BOLD, 12.0, Color.WHITE, "c", at + Vector2(12.5, 78.0 - 14.0 * lines.size() + 14.0 * i), 66.0, 1.0, 14.0, false, TILE_RIM)
	if int(gift.count) != 0:
		_cwords(str(int(gift.count)), BOLD, 13.0, Color.WHITE, "c", at + Vector2(0.5, 82), 90.0, 1.0, 0.0, true, TILE_RIM)
	if chosen:
		_cblit("qu_aw_mark", at + _v(Atlas.AWARD["mark"]))
	if not id.is_empty():
		_chit(id, Rect2(at * _f, Vector2(91, 110) * _f))
	if str(gift.kind) == "item":
		var spot: Rect2 = Rect2((at + Vector2(3.5, 0)) * _f, Vector2(84, 84) * _f)
		if _hole_px.has_point(get_local_mouse_position()) and (_hover == "panel" or _hover == id):
			_peek(spot, gift)


func _fit_rect(texture: Texture2D, rect: Rect2) -> Rect2:
	var full: Vector2 = texture.get_size()
	if full.x <= 0.0 or full.y <= 0.0:
		return rect
	var ratio: float = minf(rect.size.x / full.x, rect.size.y / full.y)
	var shown: Vector2 = full * ratio
	return Rect2(rect.position + (rect.size - shown) / 2.0, shown)


func _peek(rect: Rect2, gift: Dictionary) -> void :
	if not _tip_ok() or not _grab.is_empty() or not rect.has_point(get_local_mouse_position()):
		return
	var rec: Dictionary = _gift_rec(gift)
	if not rec.is_empty():
		_tip = [rect, "", "", Color.WHITE, rec]
		return
	_tip = [rect, GarageModel.cap(str(gift.name)), str(gift.get("desc", "")), BagModel.tint(int(gift.quality), Color.WHITE)]


func _draw_help(base: Vector2) -> void :
	var age: float = _time - _help_at
	if age < 0.0 or age >= 3.0:
		return
	var view: Vector2 = base + _v(Atlas.HELP["view"])
	var frames: Dictionary = Atlas.HELP["frames"]
	var cells: Array = frames["cells"]
	_fblit(str(cells[int(age * float(frames["rate"])) % cells.size()]), view + _v(Atlas.HELP["arrow"]) + _v(frames["at"]))
	_fblit("qu_help_text", view + _v(Atlas.HELP["text"]))


func _draw_live(base: Vector2) -> void :
	_fbutton("close", "qu_close", base + _v(Atlas.LIVE["btnClose"]))
	var fizz: int = _fizz() if _ready_data() else 0
	var bar: Vector2 = base + _v(Atlas.LIVE["bar"])
	var frame: int = clampi(int(fizz * 361.0 / 200.0) - 1, 0, 360)
	if frame == 0:
		_fblit("qu_vip_empty", bar)
	elif frame >= 360:
		_fblit("qu_vip_full", bar)
	else:
		var edge: float = float(Atlas.VIP["edges"][frame])
		_fpart("qu_vip_full", bar, Rect2(0, 0, edge - 5.0, 38))
		_fblit("qu_vip_cap", bar + Vector2(edge - 5.0, 0))
		_fpart("qu_vip_empty", bar + Vector2(edge, 0), Rect2(edge, 0, 509.0 - edge, 38))
	_fwords(str(mini(fizz, 200)), BOLD, 14.0, Color.WHITE, "c", base + _v(Atlas.LIVE["lblPoint"]), 36.0, 1.0, 0.0, true, POINT_RIM)
	var stages: Array = _stages()
	var spots: Array = Atlas.LIVE["chests"]
	var mouse: Vector2 = get_local_mouse_position()
	for i: int in mini(stages.size(), spots.size()):
		var at: Vector2 = base + _v(spots[i])
		var rect: Rect2 = Rect2(at * _f, Vector2(50, 50) * _f)
		var look: String = _chest_look(i, fizz)
		var id: String = "chest:%d" % i
		if look == "cur":
			var cells: Array = Atlas.CUR["cells"]
			_fblit(str(cells[int(_time * float(Atlas.CUR["rate"])) % cells.size()]), at + _v(Atlas.CUR["at"]), 0.0, 0.0, _glow(id))
			_hit(id, rect, false)
		else:
			_fblit("qu_chest_" + look, at)
		if rect.has_point(mouse) and (_hover == "panel" or _hover == id):
			_peek(rect, _item(int(stages[i][2]), 1))
	var list: Array = Atlas.LIVE["list"]
	var top: Vector2 = base + _v(list)
	_daily_rect = Rect2(top * _f, Vector2(float(list[2]), float(list[3])) * _f)
	var daily: Array = _daily if _ready_data() and _primed else []
	_daily_first = clampi(_daily_first, 0, maxi(0, daily.size() - DAILY_SHOWN))
	for k: int in range(DAILY_SHOWN + 1):
		var index: int = _daily_first + k
		if index >= daily.size():
			break
		_draw_daily(int(daily[index]), top + Vector2(0, DAILY_PITCH * k))
	_scrollbar("daily", base + Vector2(567, 184), DAILY_TRACK, float(DAILY_SHOWN), float(daily.size()), float(_daily_first))


func _chest_look(index: int, fizz: int) -> String:
	if _all_reaped():
		return "open"
	var current: int = _current()
	if current == 0:
		return "no" if fizz == 0 else "open"
	var stages: Array = _stages()
	if fizz < int(stages[index][1]):
		return "no"
	var stage: int = int(stages[index][0])
	if stage == current:
		return "cur" if int(client.stages[current].get("reward", 0)) == 1 else "open"
	return "open" if current > stage else "has"


func _draw_daily(quest: int, at: Vector2) -> void :
	var row: Array = _tmpl(quest)
	if row.is_empty():
		return
	_cblit("qu_cut", at + _v(Atlas.ROW["cut"]))
	_cwords(_goal(row), BOLD, 12.0, Color.WHITE, "c", at + Vector2(0, 8), 200.0, 1.0, 16.0, true, GOAL_RIM)
	var total: int = maxi(1, int(row[Q_COUNT]))
	var count: int = _count(quest)
	var meter: Vector2 = at + _v(Atlas.ROW["thermo"])
	var frame: int = clampi(int(count * 100.0 / total) - 1, 0, 99)
	if frame == 0:
		_cblit("qu_th_empty", meter)
	elif frame >= 99:
		_cblit("qu_th_full", meter)
	else:
		var edge: float = float(Atlas.THERMO["edges"][frame])
		_cpart("qu_th_full", meter, Rect2(0, 0, edge - 9.0, 15))
		_cblit("qu_th_cap", meter + Vector2(edge - 9.0, 0))
		_cpart("qu_th_empty", meter + Vector2(edge, 0), Rect2(edge, 0, 114.0 - edge, 15))
	_cwords("%d/%d" % [mini(count, total), total], BOLD, 14.0, Color.WHITE, "l", at + Vector2(319, 8), 60.0, 1.0, 16.0, false, GOAL_RIM)
	_cwords("+%d" % int(row[Q_FIZZ]), BOLD, 14.0, Color.WHITE, "c", at + Vector2(368, 8), 40.0, 1.0, 16.0, true, GOAL_RIM)
	if _state(quest) == 3:
		_cblit("qu_tick", at + _v(Atlas.ROW["tick"]))
	if int(row[Q_LINK]) != 0:
		var id: String = "go:%d" % quest
		_chit(id, _cblit("qu_go", at + _v(Atlas.ROW["go"]), 0.0, 0.0, _glow(id)))


func _scrollbar(key: String, at: Vector2, track: float, shown: float, total: float, first: float) -> void :
	_fblit("qu_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton(key + ":up", "qu_sb_up", at)
	_fbutton(key + ":down", "qu_sb_down", at + Vector2(0, BAR + track))
	var most: float = total - shown
	if most <= 0.0:
		return
	var thumb: float = maxf(20.0, track * shown / total)
	var top: float = at.y + BAR + (track - thumb) * clampf(first / most, 0.0, 1.0)
	_hit(key + ":pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, top - at.y - BAR) * _f), false)
	_hit(key + ":pgdn", Rect2(Vector2(at.x, top + thumb) * _f, Vector2(BAR, at.y + BAR + track - top - thumb) * _f), false)
	var slide: String = "slide:" + key
	_fslice("qu_sb_thumb", Vector2(at.x, top), thumb, 4.0, _glow(slide))
	_hit(slide, Rect2(Vector2(at.x, top) * _f, Vector2(BAR, thumb) * _f), false)
	_bars[key] = [track, thumb, most]


func _fslice(cell_name: String, at: Vector2, high: float, cap: float = 4.0, tint: Color = Color.WHITE) -> void :
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


func _gift_rec(gift: Dictionary) -> Dictionary:
	var id: int = int(gift.get("id", 0))
	if str(gift.get("kind", "item")) != "item" or id <= 0 or pack == null:
		return {}
	pack.load_bag()
	var extra: Dictionary = {}
	if not (pack.bag.get("items", {}) as Dictionary).has(str(id)):
		extra = {"name": str(gift.get("name", "")), "quality": int(gift.get("quality", 0)), "desc": str(gift.get("desc", ""))}
		if not str(gift.get("art", "")).is_empty() and not str(gift.art).begins_with("l/t/"):
			extra["art"] = str(gift.art)
			extra["icon"] = str(gift.art)
	return FlashTip.simulate(id, pack.bag, extra)

func _draw_tip() -> void :

	if FlashTip.show(self, _tip if _tip.size() != 4 else [], _ctip) and _tip.size() != 4:
		return
	if _tip.is_empty():
		return
	var anchor: Rect2 = _tip[0]
	var body: String = str(_tip[2])
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 8)


func _draw_flies() -> void :
	_flies = RewardFly.paint(self, _flies)


func _bounce(t: float) -> float:
	if t < 1.0 / 2.75:
		return 7.5625 * t * t
	if t < 2.0 / 2.75:
		t -= 1.5 / 2.75
		return 7.5625 * t * t + 0.75
	if t < 2.5 / 2.75:
		t -= 2.25 / 2.75
		return 7.5625 * t * t + 0.9375
	t -= 2.625 / 2.75
	return 7.5625 * t * t + 0.984375

func _bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return a * u * u + b * 2.0 * u * t + c * t * t



func _reap(index: int) -> void :
	var stages: Array = _stages()
	if index < 0 or index >= stages.size() or _time - _chest_at < 1.0:
		return
	_chest_at = _time
	if not client.stage_reap(int(stages[index][0]), true):
		say("Chưa gửi được, hãy thử lại.")


func _claim() -> void :
	if _pick == 0 or _state(_pick) != 3 or _wait != 0:
		return
	if not _choices(_tmpl(_pick)).is_empty() and _choice == 0:
		_help_at = _time
		_scroll = 0.0
		return
	if int(_tmpl(_pick)[Q_THEW]) > 0 and int(client.character.get("thew", 0)) >= THEW_FULL:
		_ask = _pick
		return
	_send_claim()


func _send_claim() -> void :
	if client.quest_complete(_pick, _choice):
		_wait = _pick
		_wait_at = _time
		_note = "Đã nhận thưởng nhiệm vụ."
		_note_at = _time + 2.0
	else:
		say("Chưa gửi được, hãy thử lại.")

func _go(quest: int) -> void :
	var row: Array = _tmpl(quest)
	if not row.is_empty() and int(row[Q_LINK]) == LINK_ENTER_MAP:
		_enter_map(int(row[Q_CHECK_ID]))
		return
	if not row.is_empty() and int(row[Q_LINK]) in LINK_PVE:
		_open_pve(int(row[Q_LINK]), int(row[Q_CHECK_ID]))
		return
	if not row.is_empty() and int(row[Q_LINK]) == LINK_CLAN_MATCH:
		_clan_match()
		return
	var target: String = str(LINKS.get(int(row[Q_LINK]), "")) if not row.is_empty() else ""
	match target:
		"":
			say(SOON)
		"arena":
			arena_asked.emit()
		"challenge":
			challenge_asked.emit()
		_:
			page_asked.emit(target)




func _open_pve(link: int, check: int) -> void :
	if client.state == "hall" and client.is_pairing():
		say(client.INVITE_PAIRING)
		return
	if client.state == "hall":
		client.back_to_lobby()
	if client.state != "lobby":
		say(TIP_73)
		return
	closed.emit()
	page_asked.emit("pve" if link == 19 or check <= 0 else ("pve:-%d" if link == 6 else "pve:%d") % check)

func _clan_match() -> void :
	closed.emit()
	if not client.guild.is_empty():
		var why: String = client.team_match_join(0)
		if not why.is_empty():
			client.noticed.emit(why)
		return
	if (int(client.character.get("actionFlag", 0)) & GUILD_FLAG) == 0:
		client.noticed.emit(TIP_355)
		return
	page_asked.emit("guild")
	client.noticed.emit(TIP_69)



func _enter_map(map_id: int) -> void :
	if map_id not in TUTOR_MAPS:
		say(SOON)
	elif client.state != "lobby":
		say(TUTOR_LOBBY)
	elif client.select_tutor_map(map_id):
		closed.emit()
	else:
		say("Chưa gửi được, hãy thử lại.")

func _activate(id: String) -> void :
	if _sheet_id == "award":
		_close_sheet()
		return
	if _ask != 0:
		if id == "ask_ok" and _ask == _pick and _state(_pick) == 3 and _wait == 0:
			_send_claim()
		if id == "ask_ok" or id == "ask_no":
			_ask = 0
		return
	if id == "close":
		closed.emit()
	elif id.begins_with("head:"):
		var index: int = int(id.substr(5))
		if index != _section:
			_section = index
			_refresh(0)
	elif id.begins_with("quest:"):
		var quest: int = int(id.substr(6))
		if quest != _pick:
			_pick = quest
			_choice = 0
	elif id.begins_with("choose:"):
		_choice = int(id.substr(7))
	elif id.begins_with("chest:"):
		_reap(int(id.substr(6)))
	elif id.begins_with("go:") or id == "goto":
		if client.state == "room":
			say(TIP_73)
		else:
			_go(int(id.substr(3)) if id.begins_with("go:") else _pick)
	elif id == "get":
		_claim()
	elif id.contains(":") and not id.begins_with("slide:"):
		var parts: PackedStringArray = id.split(":")
		_scroll_by(parts[0], parts[1])


func _scroll_by(key: String, how: String) -> void :
	var page: bool = how == "pgup" or how == "pgdn"
	var way: int = -1 if how == "up" or how == "pgup" else 1
	match key:
		"list":
			_first = clampi(_first + way * (SHOWN if page else 1), 0, maxi(0, _lists[_section].size() - SHOWN))
		"view":
			_scroll = clampf(_scroll + way * (VIEW_HIGH if page else VIEW_STEP), 0.0, maxf(0.0, _content_h - VIEW_HIGH))
		"daily":
			_daily_first = clampi(_daily_first + way * (DAILY_SHOWN if page else 1), 0, maxi(0, _daily.size() - DAILY_SHOWN))

func _bar_value(key: String) -> float:
	match key:
		"list":
			return float(_first)
		"view":
			return _scroll
		"daily":
			return float(_daily_first)
	return 0.0

func _set_bar(key: String, value: float) -> void :
	match key:
		"list":
			_first = clampi(roundi(value), 0, maxi(0, _lists[_section].size() - SHOWN))
		"view":
			_scroll = clampf(value, 0.0, maxf(0.0, _content_h - VIEW_HIGH))
		"daily":
			_daily_first = clampi(roundi(value), 0, maxi(0, _daily.size() - DAILY_SHOWN))

func _wheel(step: int, at: Vector2) -> void :
	if _sheet_id == "award":
		return
	if _ask != 0:
		return
	if _mode == "live":
		if _daily_rect.has_point(at):
			_set_bar("daily", float(_daily_first + step * 3))
	elif _list_rect.has_point(at):
		_set_bar("list", float(_first + step * 3))
	elif _view_rect.has_point(at):
		_set_bar("view", _scroll + step * VIEW_STEP)


func _drag(moved: Vector2, from: Vector2) -> void :
	if not _grab.is_empty() or _ask != 0:
		return
	if _mode == "main" and _view_rect.has_point(from):
		_set_bar("view", _scroll - moved.y / _f)
		return
	var key: String = "list" if _mode == "main" and _list_rect.has_point(from) else ("daily" if _mode == "live" and _daily_rect.has_point(from) else "")
	if key.is_empty():
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, (PITCH if key == "list" else DAILY_PITCH) * _f)
	while _pull >= pitch:
		_pull -= pitch
		_set_bar(key, _bar_value(key) + 1.0)
	while _pull <= - pitch:
		_pull += pitch
		_set_bar(key, _bar_value(key) - 1.0)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var id: String = _hit_at(event.position)
			if id.begins_with("slide:") and _bars.has(id.substr(6)):
				_grab = id.substr(6)
				_grab_at = event.position
				_grab_first = _bar_value(_grab)
		else:
			_grab = ""
	elif event is InputEventMouseMotion and not _grab.is_empty():
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_grab = ""
		else:
			var bar: Array = _bars.get(_grab, [])
			if not bar.is_empty():
				var step: float = maxf(0.001, (float(bar[0]) - float(bar[1])) / float(bar[2]))
				_set_bar(_grab, _grab_first + (event.position.y - _grab_at.y) / _f / step)
			accept_event()
			return
	super (event)


func _step(by: int) -> void :
	if _ask != 0:
		return
	if _mode == "live":
		_set_bar("daily", float(_daily_first + by))
		return
	var list: Array = _lists[_section]
	if list.is_empty():
		return
	var index: int = clampi(maxi(0, list.find(_pick)) + by, 0, list.size() - 1)
	if int(list[index]) != _pick:
		_pick = int(list[index])
		_choice = 0
	_first = clampi(clampi(_first, index - SHOWN + 1, index), 0, maxi(0, list.size() - SHOWN))

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	match event.keycode:
		KEY_ESCAPE:
			if _ask != 0:
				_ask = 0
				queue_redraw()
			else:
				closed.emit()
		KEY_UP:
			_step(-1)
		KEY_DOWN:
			_step(1)
		_:
			return
	get_viewport().set_input_as_handled()

func chat_busy() -> bool:
	return _sheet_id == "award" or _ask != 0

func _close_sheet() -> void :
	if _reward.request_close(self):
		return
	_sheet_id = ""

func _input(event: InputEvent) -> void :
	if is_visible_in_tree() and _sheet_id == "award" and event is InputEventKey and event.pressed:
		if event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER]:
			_close_sheet()
		get_viewport().set_input_as_handled()
