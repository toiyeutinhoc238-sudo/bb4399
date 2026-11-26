extends "flash_screen.gd"












const Atlas = preload("events_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")



const FlaPlayer = preload("fla_player.gd")
const MOVIE_SIGN: String = "fla/qd"
const MOVIE_CHEST: String = "fla/isel"
const AtlasV = preload("eventsv_atlas.gd")
const AtlasW = preload("eventsw_atlas.gd")
const AtlasF = preload("eventsf_atlas.gd")
const AtlasP = preload("eventsp_atlas.gd")
const Arena = preload("arena_atlas.gd")
const RewardPopup = preload("reward_popup.gd")
const RewardFly = preload("reward_fly.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")

signal closed

const TABS: Array = ["sign", "card", "accum", "growth", "vip", "first"]
const MONTH_TOP: Color = Color("fcdd68")
const MONTH_BOTTOM: Color = Color("f7f8cc")

const SIZES: Dictionary = {"sign": Vector2(690, 600), "card": Vector2(692, 418), "accum": Vector2(880, 630), "growth": Vector2(902, 592), "vip": Vector2(682, 610), 
	"first": Vector2(747, 450)}
const CLOSES: Dictionary = {"sign": Vector2(652, 33), "card": Vector2(654, 33), "accum": Vector2(842, 33), "growth": Vector2(841, 71), "vip": Vector2(644, 33), 
	"first": Vector2(675, 70)}

const Q_DESC: int = 2
const Q_COUNT: int = 4
const Q_EXP: int = 6
const Q_GOLD: int = 7
const Q_GIFT: int = 8
const Q_THEW: int = 9
const Q_ITEMS: int = 10
const Q_HEFT: int = 14
const UI_VIP: int = 15
const FIRST: int = 1400
const FIRST_SLOTS: int = 4
const ACCUM_FROM: int = 1500
const ACCUM_TO: int = 1507
const ACCUM_TYPE: int = 15
const VIP_LEVEL_FROM: int = 1600
const VIP_LEVEL_TO: int = 1611
const VIP_AWARD_AT: Vector2 = Vector2(511, 175)
const PRIV_SIZE: Vector2 = Vector2(860, 591)
const PRIV_ROW: float = 22.0
const PERK_GREEN: Color = Color("00f350")
const VIP_GLOW: Color = Color("0390d3")
const DAY: int = 86400
const VN: int = 25200
const COINS: Array = ["Xu", "Xu Khóa", "Bạc"]
const AWARD_ROWS: int = 6

const WAITING: int = 0
const DOING: int = 1
const CAN_GET: int = 2
const GETTED: int = 3
const FINISH: int = 4
const BAR: float = 19.0
const ROW_H: float = 40.0
const ROWS_SHOWN: int = 7
const VIEW_H: float = 291.0
const VIEW_STEP: float = 15.0
const GROW_H: float = 150.0
const GROW_SHOWN: int = 2
const DIM: Color = Color(0, 0, 0, 0.4)
const TILE_RIM: Color = Color("005797", 0.8)
const ROW_RIM: Color = Color("0b4f8a", 0.8)
const PICK_RIM: Color = Color("a93201")
const RED_TEXT: Color = Color("ff514f")
const OK_GOLD: Color = Color("fff352")
const SOON: String = "Mục này đang được chuyển sang HTML5."
const TOPUP: String = "Chưa đủ điều kiện nhận quà này."
const TOPUP_PC: String = "Nạp Xu chưa mở trên app PC, hãy nạp ở bản Flash."

const PRIV_NAMES: Array = ["TG Hồi Sinh", "Lượt Hồi Sinh", "Cộng Bạc,EXP", "Vật Liệu PB", "Tăng Thể Lực thêm mỗi ngày", 
	"Đấu Khiên Chiến không CD", "Càn quét 10 lần liền", "Lượt thuê miễn phí", "Vòng Quay VIP"]

var tab: String = "auto"
var _tab: int = 0
var _from: String = ""
var _auto: bool = false
var _rule: bool = false
var _priv: int = 0
var _rev: int = -1
var _built_at: float = 0.0
var _due: Dictionary = {}
var _grows: Array = []
var _accum_pick: int = -1
var _accum_first: int = 0
var _view: float = 0.0
var _content_h: float = 0.0
var _grow_first: int = 0
var _pull: float = 0.0
var _sent_at: float = -10.0
var _wait: int = 0
var _wait_at: float = 0.0
var _note: String = ""
var _note_at: float = 0.0
var _told: bool = false
var _failed: bool = false
var _sheet_id: String = ""
var _flies: Array = []
var _reward: RefCounted = RewardPopup.new()
var _award: Array = []
var _tip: Array = []
var _movies: Dictionary = {}
var drawn_movies: Array = []
var _ctip: CTip = CTip.new()
var _clip: Rect2 = Rect2()
var _bars: Dictionary = {}
var _grab: String = ""
var _grab_at: Vector2 = Vector2.ZERO
var _grab_first: float = 0.0
var _list_rect: Rect2 = Rect2()
var _view_rect: Rect2 = Rect2()
var _grow_rect: Rect2 = Rect2()
var _wraps: Dictionary = {}
var _greys: Dictionary = {}

func _setup() -> void :
	pack.picture_ready.connect(_on_pack)
	client.awarded.connect(_on_award)
	client.stage_reaped.connect(_on_reaped)
	client.quest_failed.connect(_on_failed)

func _shown() -> void :
	_tip = []
	_grab = ""
	if not is_visible_in_tree():
		return
	pack.load_events()
	pack.load_quest()
	pack.load_bag()
	pack.load_eventsx()
	if pack.events.is_empty():
		_failed = false
	_rev = -1
	_wait = 0
	_note = ""
	_told = false
	_reward.reset()
	_flies = []
	RewardFly.reset(self)
	_sheet_id = ""
	_rule = false
	if tab.is_empty():
		return
	_auto = tab == "auto"
	_tab = maxi(0, TABS.find(tab))
	tab = ""
	_from = ""
	_priv = 0
	_accum_pick = -1
	_accum_first = 0
	_view = 0.0
	_grow_first = 0
	_pull = 0.0

func _on_pack(path: String) -> void :
	if path == "l/events.json":
		_failed = pack.events.is_empty()
		_rev = -1
	elif path == "l/quest.json" or path == "l/eventsx.json":
		_rev = -1
	elif path == "l/bag.json":
		_wraps.clear()


func chat_busy() -> bool:
	return not _sheet_id.is_empty() or _rule or _priv > 0



func _kind() -> String:
	return str(TABS[_tab])

func _now() -> int:
	return int(Time.get_unix_time_from_system())

func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))

func _coin_art(index: int) -> String:
	var coins: Array = pack.lobby.get("coins", [])
	return "l/c/%s.webp" % str(coins[index]) if index >= 0 and index < coins.size() and not str(coins[index]).is_empty() else ""


func _item(id: int, count: int) -> Dictionary:
	var info: Variant = pack.events.get("items", {}).get(str(id))
	var row: Array = info if info is Array and (info as Array).size() >= 4 else []
	if row.is_empty():
		var other: Variant = pack.quest.get("items", {}).get(str(id))
		row = other if other is Array and (other as Array).size() >= 3 else []
	var found: Variant = pack.bag.get("items", {}).get(str(id))
	var more: Array = found if found is Array else []
	var title: String = "Vật phẩm %d" % id
	if not more.is_empty() and not str(more[0]).is_empty():
		title = BagModel.clean(str(more[0]))
	elif not row.is_empty() and not str(row[0]).is_empty():
		title = str(row[0])
	var icon: String = str(row[1]) if row.size() > 1 and not str(row[1]).is_empty() else (str(more[2]) if more.size() > 2 else "")
	var quality: int = int(row[2]) if row.size() > 2 else (int(more[3]) if more.size() > 3 else 0)
	var head: bool = (row.size() > 3 and int(row[3]) == 1) or (more.size() > 5 and int(more[5]) == 4)
	var art: String = ""
	if not icon.is_empty():
		art = ("l/av/" if head else "l/it/") + icon + ".webp"
	return {"kind": "item", "id": id, "count": count, "name": title, "art": art, "quality": quality, 
		"desc": GarageModel.plain(str(more[1])) if more.size() >= 10 else ""}


func _coin(index: int, count: int) -> Dictionary:
	var label: String = str(COINS[index]) if index >= 0 and index < COINS.size() else "Xu"
	return {"kind": "gift" if index == 1 else "money", "id": 0, "count": count, "name": label, "art": _coin_art(index), 
		"quality": 2 if index == 1 else 1, "desc": ""}


func _gifts(rewards: Variant) -> Array:
	var out: Array = []
	if rewards is Array:
		for reward: Variant in rewards:
			if not (reward is Array) or (reward as Array).size() < 2:
				continue
			if int(reward[0]) == 0:
				if (reward as Array).size() >= 3:
					out.append(_coin(int(reward[1]), int(reward[2])))
			else:
				out.append(_item(int(reward[0]), int(reward[1])))
	return out



func _today() -> int:
	return int(client.sign_in.get("day", 0))

func _signed(day: int) -> bool:
	return ((int(client.sign_in.get("flag", 0)) >> day) & 1) == 1

func _vip_signed(day: int) -> bool:
	return ((int(client.sign_in.get("vip_flag", 0)) >> day) & 1) == 1


func _weekday(day: int) -> int:
	var at: int = Time.get_unix_time_from_datetime_dict({"year": int(client.sign_in.get("year", 2026)), "month": int(client.sign_in.get("month", 1)), 
		"day": day, "hour": 12, "minute": 0, "second": 0})
	return int(Time.get_datetime_dict_from_unix_time(at).get("weekday", 0))


func _sign_box(day: int) -> int:
	var months: Array = pack.events.get("sign", [])
	var month: int = int(client.sign_in.get("month", 0))
	var days: Array = months[month - 1] if month >= 1 and month <= months.size() and months[month - 1] is Array else []
	return int(days[day - 1]) if day >= 1 and day <= days.size() else 0

func _month_days() -> int:
	var year: int = int(client.sign_in.get("year", 2026))
	var month: int = int(client.sign_in.get("month", 1))
	if month == 2:
		return 29 if (year % 4 == 0 and year % 100 != 0) or year % 400 == 0 else 28
	return 30 if month in [4, 6, 9, 11] else 31


func _next_mark() -> int:
	var stage: int = int(client.sign_in.get("stage", 0))
	for row: Array in pack.events.get("marks", []):
		if int(row[0]) > stage:
			return int(row[0])
	return 0


func _mark_state(mark: int) -> int:
	if int(client.sign_in.get("stage", 0)) >= mark:
		return 2
	if int(client.sign_in.get("count", 0)) < mark:
		return 0
	return 1 if mark == _next_mark() else 3



func _vip_points() -> int:
	return int(client.character.get("vipPoints", 0))


func _my_vip() -> int:
	var level: int = 0
	for row: Array in pack.events.get("vip", []):
		if _vip_points() >= int(row[0]):
			level += 1
	return level

func _vip_until() -> int:
	return maxi(int(client.character.get("vipTime", 0)), int(client.character.get("superVipTime", 0)))


func _vip_on() -> bool:
	return _vip_until() > _now() and _my_vip() > 0

func _vip_gift_open() -> bool:
	return _vip_on() and not client.sign_in.is_empty() and not _vip_signed(_today())



func _vip_level_stage() -> int:
	var stage: int = 0
	for key: Variant in client.stages:
		if int(key) >= VIP_LEVEL_FROM and int(key) <= VIP_LEVEL_TO:
			stage = maxi(stage, int(key))
	for key: Variant in client.stages_cleared:
		if int(key) >= VIP_LEVEL_FROM and int(key) <= VIP_LEVEL_TO and int(key) >= stage:
			return 0
	return stage


func _vip_level_ready(stage: int) -> bool:
	return stage != 0 and stage == _vip_level_stage() and int(client.stages.get(stage, {}).get("reward", 0)) == 1


func _vip_level_mark(index: int) -> Array:
	var marks: Array = pack.eventsx.get("vip_level", [])
	if index < 0 or index >= marks.size() or not marks[index] is Array or (marks[index] as Array).size() < 4:
		return []
	return marks[index]



func _priv_lines(cur: int) -> Array:
	var rows: Array = pack.events.get("vip", [])
	if cur < 1 or cur > rows.size() or (rows[cur - 1] as Array).size() < 10:
		return []
	var perk: Array = rows[cur - 1]
	var extra: Array = pack.eventsx.get("vip_more", [])
	var more: Array = extra[cur - 1] if cur <= extra.size() and extra[cur - 1] is Array and (extra[cur - 1] as Array).size() >= 4 else [0, 0, 0, 0]
	var lines: Array = [["Hồ Vàng tăng ", str(int(more[3])), " Vàng/ngày"], ["Thời gian hồi sinh giảm  ", str(int(perk[1])), " s"], 
		["Lượt hồi sinh miễn phí + ", str(int(perk[6])), " lần"], ["Bạc + ", str(int(perk[3])), "%"]]
	if int(perk[8]) > 0:
		lines.append(["Càn quét 10 lần liền", "", ""])
	lines.append(["EXP + ", str(int(perk[2])), "%"])
	if int(more[0]) > 0:
		lines.append(["Đấu Khiên Chiến không CD", "", ""])
	lines.append(["Vật Liệu PB + ", str(int(perk[5])), "%"])
	lines.append(["Tăng thêm ", str(int(perk[7])), " Thể Lực mỗi ngày"])
	lines.append(["Đổi Hết", "", ""])
	if int(perk[9]) > 0:
		lines.append(["Vòng Quay VIP", "", ""])
	if int(more[2]) > 0:
		lines.append(["Lượt thuê miễn phí ", str(int(more[2])), " lần"])
	return lines



func _card_until() -> int:
	return int(client.character.get("cashback_times", 0))

func _card_days() -> int:
	var times: int = _card_until()
	var picked: int = int(client.character.get("cashback_picked", 0))
	if times <= picked:
		return 0
	var today: int = ((_now() + VN) / DAY) * DAY - VN
	return maxi(0, (mini(today, times) - picked) / DAY)




func _accum_current() -> int:
	for stage: int in range(ACCUM_FROM, ACCUM_TO + 1):
		if client.stages.has(stage):
			return stage
	return 0

func _accum_done() -> bool:
	for stage: int in range(ACCUM_FROM, ACCUM_TO + 1):
		if client.stages_cleared.has(stage):
			return true
	return false


func _accum_total() -> int:
	var total: int = -1
	var progress: Variant = client.stage_progress.get(ACCUM_TYPE)
	if progress is Array and not progress.is_empty() and progress[0] is Array and not progress[0].is_empty():
		total = int(progress[0][0])
	var current: int = _accum_current()
	if current != 0:
		total = maxi(total, int(client.stages[current].get("value", 0)))
	return total

func _accum_open() -> bool:
	var current: int = _accum_current()
	return current != 0 and int(client.stages[current].get("reward", 0)) == 1


func _accum_row_state(stage: int) -> int:
	var current: int = _accum_current()
	if current == 0:
		return GETTED if _accum_done() else WAITING
	if stage == current:
		if int(client.stages[current].get("reward", 0)) == 1:
			return GETTED if _accum_done() else CAN_GET
		return DOING
	return GETTED if stage < current else WAITING


func _accum_default() -> int:
	var rows: Array = pack.events.get("accum", [])
	for want: int in [CAN_GET, DOING]:
		for i: int in rows.size():
			if _accum_row_state(int(rows[i][0])) == want:
				return i
	var last: int = -1
	for i: int in rows.size():
		if _accum_row_state(int(rows[i][0])) == GETTED:
			last = i
	return mini(last + 1, rows.size() - 1) if last >= 0 else 0




func _first_done() -> bool:
	return client.stages_cleared.has(FIRST) and not client.stages.has(FIRST)


func _first_open() -> bool:
	return not _first_done() and client.stages.has(FIRST) and int(client.stages[FIRST].get("reward", 0)) == 1


func _first_gifts() -> Array:
	var row: Array = pack.events.get("first", [])
	var gifts: Array = _gifts(row[2] if row.size() >= 3 else [])
	var out: Array = []
	for kind: String in ["money", "gift", "item"]:
		for gift: Dictionary in gifts:
			if str(gift.kind) == kind and out.size() < FIRST_SLOTS:
				out.append(gift)
	return out



func _growth() -> Dictionary:
	return pack.events.get("growth", {})

func _growth_on() -> bool:
	return int(client.limits.get(int(_growth().get("limit", 1018)), 0)) > 0

func _tmpl(quest: int) -> Array:
	var row: Variant = pack.quest.get("quests", {}).get(str(quest))
	return row if row is Array and (row as Array).size() > Q_ITEMS else []

func _state(quest: int) -> int:
	return int(client.quests.get(quest, [0])[0])

func _count(quest: int) -> int:
	var info: Array = client.quests.get(quest, [])
	return int(info[1]) if info.size() > 1 else 0



func _grow_progress(quest: int, need: int) -> String:
	var info: Array = client.quests.get(quest, [])
	var st: int = int(info[0]) if info.size() > 0 else 0
	if need <= 0 or not (st == 2 or st == 3):
		return ""
	return "%d/%d" % [need if st == 3 else clampi(_count(quest), 0, need), need]


func _grow_rank(quest: int) -> int:
	if not client.quests.has(quest) or _state(quest) == 4:
		return 2
	return 0 if _state(quest) == 3 else 1

func _grow_before(a: int, b: int) -> bool:
	var ra: int = _grow_rank(a)
	var rb: int = _grow_rank(b)
	if ra != rb:
		return ra < rb
	var ha: Array = _tmpl(a)
	var hb: Array = _tmpl(b)
	var wa: int = int(ha[Q_HEFT]) if ha.size() > Q_HEFT else 0
	var wb: int = int(hb[Q_HEFT]) if hb.size() > Q_HEFT else 0
	if wa != wb:
		return wa > wb
	return a < b

func _quest_gifts(row: Array) -> Array:
	var out: Array = []
	if int(row[Q_EXP]) > 0:
		out.append({"kind": "exp", "id": 0, "count": int(row[Q_EXP]), "name": "EXP", "art": "", "quality": 1, "desc": ""})
	if int(row[Q_GOLD]) > 0:
		out.append(_coin(2, int(row[Q_GOLD])))
	if int(row[Q_GIFT]) > 0:
		out.append(_coin(1, int(row[Q_GIFT])))
	if int(row[Q_THEW]) > 0:
		out.append({"kind": "thew", "id": 0, "count": int(row[Q_THEW]), "name": "Thể Lực", "art": "", "quality": 1, "desc": ""})
	for pair: Variant in row[Q_ITEMS]:
		if pair is Array and (pair as Array).size() >= 2 and int(pair[0]) != 0:
			out.append(_item(int(pair[0]), int(pair[1])))
	return out

func _rebuild(changed: bool) -> void :
	_due = {"sign": 0, "card": 0, "accum": 0, "growth": 0, "vip": 0, "first": 1 if _first_open() else 0}
	if not client.sign_in.is_empty():
		_due["sign"] = (0 if _signed(_today()) else 1) + (1 if _vip_gift_open() else 0) + (1 if _next_mark() != 0 and _mark_state(_next_mark()) == 1 else 0)
	_due["card"] = 1 if _card_days() > 0 else 0
	_due["accum"] = 1 if _accum_open() else 0
	_grows = []
	for quest: Variant in _growth().get("quests", []):
		_grows.append(int(quest))
		if _growth_on() and client.quests.has(int(quest)) and _state(int(quest)) == 3:
			_due["growth"] += 1
	_grows.sort_custom(_grow_before)
	if _auto and not client.sign_in.is_empty():
		_auto = false
		for index: int in TABS.size():
			if int(_due[TABS[index]]) > 0:
				_tab = index
				break
	var rows: Array = pack.events.get("accum", [])
	if changed or _accum_pick < 0 or _accum_pick >= rows.size():
		_accum_pick = _accum_default()
		_accum_first = clampi(clampi(_accum_first, _accum_pick - ROWS_SHOWN + 1, _accum_pick), 0, maxi(0, rows.size() - ROWS_SHOWN))
		_view = 0.0

func _tick(_delta: float) -> void :
	_tick_award()
	if not _note.is_empty() and _time >= _note_at:
		say(_note)
		_note = ""
	if pack.events.is_empty():
		return
	if _kind() == "sign":
		_tick_movies(_delta)
	var rev: int = client.event_rev * 100003 + client.quest_rev
	if rev != _rev or _time - _built_at > 5.0:
		var changed: bool = rev != _rev
		_rev = rev
		_built_at = _time
		_rebuild(changed)
	if _kind() == "vip" and not _told:
		_told = true
		client.quest_open_ui(UI_VIP)
	if _wait != 0 and (_state(_wait) != 3 or _time - _wait_at > 4.0):
		_wait = 0

func _on_award(info: Dictionary) -> void :
	if not is_visible_in_tree():
		return

	if client.award_op in [1, 7, 9, 13, 14, 15, 19, 26, 27, 29, 30]:
		return
	if client.award_show == 0 or client.award_op == 8:
		_note = ""
		_flies.append_array(RewardFly.begin(self, info))
		return
	var lines: Array = BagModel.award_lines(info, pack.bag)
	if not RewardPopup.has_rewards(info):
		return
	_reward.begin(self, info)
	_note = ""
	if _sheet_id == "award":
		for line: Array in lines:
			var merged: bool = false
			for old: Array in _award:
				if str(old[0]) == str(line[0]):
					old[1] = int(old[1]) + int(line[1])
					merged = true
			if not merged:
				_award.append(line)
		return
	_award = lines
	_sheet_id = "award"

func _on_reaped(result: int, stage: int) -> void :
	var vip_level: bool = stage >= VIP_LEVEL_FROM and stage <= VIP_LEVEL_TO
	if not is_visible_in_tree() or not (stage == FIRST or (stage >= ACCUM_FROM and stage <= ACCUM_TO) or vip_level):
		return
	match result:
		0:
			_note = "Đã nhận quà lần đầu." if stage == FIRST else ("Đã nhận quà cấp VIP." if vip_level else "Đã nhận quà mốc tích lũy.")
			_note_at = _time + 1.2
		1:
			say("Quà này đã nhận rồi.")
		_:
			say("Chưa đủ điều kiện nhận quà này.")

func _on_failed(quest: int) -> void :
	if quest != _wait:
		return
	_wait = 0
	_note = ""
	if is_visible_in_tree():
		say("Chưa nhận được quà này.")




func _cut_tex(texture: Texture2D, dest: Rect2, src: Rect2, tint: Color = Color.WHITE) -> void :
	if texture == null or dest.size.x <= 0.0 or dest.size.y <= 0.0:
		return
	if not _clip.has_area():
		draw_texture_rect_region(texture, dest, src, tint)
		return
	var cut: Rect2 = dest.intersection(_clip)
	if not cut.has_area():
		return
	var k: Vector2 = src.size / dest.size
	draw_texture_rect_region(texture, cut, Rect2(src.position + (cut.position - dest.position) * k, cut.size * k), tint)

func _cblit(cell_name: String, at: Vector2, wide: float = 0.0, high: float = 0.0, tint: Color = Color.WHITE) -> Rect2:
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty():
		return Rect2(at * _f, Vector2(wide, high) * _f)
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(wide if wide > 0.0 else float(region[2]), high if high > 0.0 else float(region[3])) * _f)
	_cut_tex(cell[0], rect, Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])), tint)
	return rect

func _cpic(texture: Texture2D, rect: Rect2, tint: Color = Color.WHITE) -> void :
	if texture != null:
		_cut_tex(texture, rect, Rect2(Vector2.ZERO, texture.get_size()), tint)


func _cwords(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, wide: float, edge: float = 0.0, high: float = 0.0, shrink: bool = true, rim: Color = SHADE) -> float:
	if _clip.has_area():
		var middle: float = (at.y + (high / 2.0 if high > 0.0 else 2.0 + px * 0.55)) * _f
		var half: float = px * 0.6 * _f
		if middle - half < _clip.position.y - 1.0 or middle + half > _clip.end.y + 1.0:
			return 0.0
	return _fwords(text, font, px, color, align, at, wide, edge, high, shrink, rim)


func _chit(id: String, rect: Rect2) -> void :
	var cut: Rect2 = rect.intersection(_clip) if _clip.has_area() else rect
	if cut.has_area():
		_hit(id, cut, false)

func _cbutton(id: String, cell_name: String, at: Vector2) -> void :
	_chit(id, _cblit(cell_name, at, 0.0, 0.0, _glow(id)))


func _spans(parts: Array, px: float, align: String, at: Vector2, wide: float, edge: float, high: float, rim: Color) -> void :
	var face: Font = ARIAL_BOLD
	var font_size: int = maxi(6, roundi(px * _f))
	var widths: Array = []
	var total: float = 0.0
	for part: Array in parts:
		var width: float = face.get_string_size(str(part[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f
		widths.append(width)
		total += width
	var x: float = at.x if align == "l" else (at.x + (wide - total) / 2.0 if align == "c" else at.x + wide - total)
	for i: int in parts.size():
		_cwords(str(parts[i][0]), BOLD, px, parts[i][1], "l", Vector2(x, at.y), float(widths[i]) + 2.0, edge, high, false, rim)
		x += float(widths[i])


func _fit_rect(texture: Texture2D, rect: Rect2) -> Rect2:
	var full: Vector2 = texture.get_size()
	if full.x <= 0.0 or full.y <= 0.0:
		return rect
	var ratio: float = minf(rect.size.x / full.x, rect.size.y / full.y)
	var shown: Vector2 = full * ratio
	return Rect2(rect.position + (rect.size - shown) / 2.0, shown)


func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false)


func _grey(texture: Texture2D) -> Texture2D:
	if texture == null or texture.get_width() <= 4:
		return texture
	var key: int = texture.get_instance_id()
	if _greys.has(key):
		return _greys[key]
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		_greys[key] = texture
		return texture
	image = image.duplicate()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var data: PackedByteArray = image.get_data()
	for i: int in range(0, data.size(), 4):
		var v: int = clampi(roundi(0.3086 * data[i] + 0.6094 * data[i + 1] + 0.082 * data[i + 2]), 0, 255)
		data[i] = v
		data[i + 1] = v
		data[i + 2] = v
	var out: ImageTexture = ImageTexture.create_from_image(Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data))
	_greys[key] = out
	return out


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


func _pulse() -> float:
	return 0.55 + 0.45 * (0.5 + 0.5 * sin(_time * 4.0))


func _tick_movies(delta: float) -> void :
	for key: String in [MOVIE_SIGN, MOVIE_CHEST]:
		if _movies.has(key):
			if _movies[key] != null:
				_movies[key].advance(delta)
			continue
		var fx: Dictionary = pack.effect(key)
		if not FlaPlayer.valid(fx.get("data")):
			continue
		var player: FlaPlayer = FlaPlayer.new()
		if player.add_clip(fx) < 0:
			player.free()
			_movies[key] = null
			continue
		player.visible = false
		add_child(player)
		_movies[key] = player


func _movie(key: String, at: Vector2, scale_by: float) -> void :
	_movies[key].paint(self, Transform2D(0.0, Vector2(scale_by, scale_by) * _f, 0.0, at * _f))
	drawn_movies.append([key, at, scale_by])

func _movie_ready(key: String) -> bool:
	return _movies.get(key) != null



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(AtlasV.FILE, AtlasV.R)
		_use(AtlasW.FILE, AtlasW.R)
		_use(AtlasF.FILE, AtlasF.R)
		_use(AtlasP.FILE, AtlasP.R)
		_use(Arena.FILE, Arena.R)
		_use(TL1_FILE, TL1_CELLS)
		_use(TL2_FILE, TL2_CELLS)
	_tip = []
	drawn_movies = []
	_bars = {}
	_clip = Rect2()
	_list_rect = Rect2()
	_view_rect = Rect2()
	_grow_rect = Rect2()
	var kind: String = _kind()
	var box: Vector2 = SIZES[kind]
	var base: Vector2 = _centre(box.x, box.y)
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_hit("panel", Rect2(base * _f, box * _f), false)
	if pack.events.is_empty():
		_draw_loading(kind, base, box)
	else:
		match kind:
			"sign":
				_draw_sign(base)
			"card":
				_draw_card(base)
			"accum":
				_draw_accum(base)
			"growth":
				_draw_growth(base)
			"vip":
				_draw_vip(base)
			"first":
				_draw_first(base)
	_fbutton("close", "ef_close" if kind == "first" else "ev_close", base + CLOSES[kind])
	if _rule and kind == "sign":
		_draw_rule(base)
	if _priv > 0 and kind == "vip" and not pack.events.is_empty():
		_draw_priv(base)
	if _sheet_id == "award":
		_draw_award()
	elif not _rule:
		_draw_tip()
	_flies = RewardFly.paint(self, _flies)



const TL1_FILE: String = "res://assets/ui/hall/tichluy1.png"
const TL1_CELLS: Dictionary = {"tl_title": [2, 0, 180, 31], "tl_now": [0, 34, 112, 45], "tl_now_off": [114, 34, 112, 45]}
const TL1_TITLE: Rect2 = Rect2(331, 0, 180, 31)



const TL2_FILE: String = "res://assets/ui/hall/tichluy2.png"
const TL2_CELLS: Dictionary = {"ew_tc": [0, 0, 859, 617], "ef_first": [0, 619, 722, 378]}


func _tl1_panel(at: Vector2) -> void :
	if _cells.get("tl_title", [null])[0] == null or _cells.get("ew_tc", [null])[0] == null:
		_fblit("ew_tc", at)
		return
	var size: Vector2 = _cell_size("ew_tc")
	var t: Rect2 = TL1_TITLE
	_fpart("ew_tc", at, Rect2(0, 0, t.position.x, t.end.y))
	_fpart("ew_tc", at + Vector2(t.end.x, 0), Rect2(t.end.x, 0, size.x - t.end.x, t.end.y))
	_fpart("ew_tc", at + Vector2(0, t.end.y), Rect2(0, t.end.y, size.x, size.y - t.end.y))
	_fblit("tl_title", at + t.position)


func _accum_button(stage: int) -> String:
	var current: int = _accum_current()
	if _accum_done() or (current != 0 and stage < current):
		return "got"
	if current != 0 and stage == current and int(client.stages[current].get("reward", 0)) == 1:
		return "now"
	return "off"

func _draw_static(kind: String, base: Vector2) -> void :
	match kind:
		"sign":
			_fblit("ev_sign", base + _v(Atlas.PANELS["sign"]))
		"card":
			_fblit("ev_rebate", base + _v(Atlas.PANELS["rebate"]))
		"accum":
			_tl1_panel(base + _v(AtlasV.PANELS["tc"]))
		"growth":
			_fblit("eg_grow", base + _v(AtlasW.PANELS["grow"]))
		"vip":
			_fblit("ew_vip", base + _v(AtlasV.PANELS["vip"]))
		"first":
			_fblit("ef_first", base + _v(AtlasF.PANELS["first"]))

func _draw_loading(kind: String, base: Vector2, box: Vector2) -> void :
	_draw_static(kind, base)
	var text: String = "Chưa tải được dữ liệu sự kiện, hãy mở lại sau." if _failed else "Đang tải dữ liệu sự kiện…"
	_fwords(text, BOLD, 16.0, Color.WHITE, "c", base + Vector2(0, box.y / 2.0 - 12.0), box.x, 1.5, 24.0, false, TILE_RIM)


func _draw_tile(gift: Dictionary, at: Vector2) -> void :
	_cblit("ev_aw_bg", at + _v(Atlas.AWARD["bg"]))
	_cblit("ev_q%d" % clampi(int(gift.quality), 1, 5), at + _v(Atlas.AWARD["quality"]))
	match str(gift.kind):
		"item":
			var art: String = str(gift.get("art", ""))
			var picture: Texture2D = pack.picture(art) if not art.is_empty() else null
			if picture != null:
				_cpic(picture, _fit_rect(picture, Rect2((at + _v(Atlas.AWARD["item"])) * _f, Vector2(76, 76) * _f)))
		"exp":
			_cblit("ev_aw_exp", at + _v(Atlas.AWARD["coin"]))
		"money":
			_cblit("ev_aw_money", at + _v(Atlas.AWARD["coin"]))
		"gift":
			_cblit("ev_aw_gift", at + _v(Atlas.AWARD["gift"]))
		"thew":
			_cblit("ev_aw_thew", at + _v(Atlas.AWARD["thew"]))
	var lines: Array = _wrap(str(gift.name), BOLD, 12.0, 66.0)
	for i: int in lines.size():
		_cwords(str(lines[i]), BOLD, 12.0, Color.WHITE, "c", at + Vector2(12.5, 78.0 - 14.0 * lines.size() + 14.0 * i), 66.0, 1.0, 14.0, false, TILE_RIM)
	if int(gift.count) != 0:
		_cwords(str(int(gift.count)), BOLD, 13.0, Color.WHITE, "c", at + Vector2(0.5, 82), 90.0, 1.0, 0.0, true, TILE_RIM)
	_peek_item(Rect2((at + Vector2(3.5, 0)) * _f, Vector2(84, 84) * _f), gift)

func _can_peek(rect: Rect2, id: String) -> bool:
	if not _tip_ok() or not _grab.is_empty() or not _sheet_id.is_empty() or _rule:
		return false
	var mouse: Vector2 = get_local_mouse_position()
	if not rect.has_point(mouse) or (_clip.has_area() and not _clip.has_point(mouse)):
		return false
	return _hover == "panel" or ( not id.is_empty() and _hover == id)


func _peek_item(rect: Rect2, gift: Dictionary, id: String = "") -> void :
	if _can_peek(rect, id):
		var rec: Dictionary = _gift_rec(gift)
		if not rec.is_empty():
			_tip = [rect, "", "", Color.WHITE, rec]
			return
		_tip = [rect, GarageModel.cap(str(gift.name)), str(gift.get("desc", "")), BagModel.tint(int(gift.quality), Color.WHITE)]


func _peek_gifts(rect: Rect2, title: String, gifts: Array, id: String = "") -> void :
	if not _can_peek(rect, id):
		return
	var lines: PackedStringArray = PackedStringArray()
	for gift: Dictionary in gifts:
		lines.append("%s ×%d" % [GarageModel.cap(str(gift.name)), int(gift.count)])
	_tip = [rect, title, "\n".join(lines), Color("fcdd68")]


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
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 10).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 10)


func _scrollbar(key: String, at: Vector2, track: float, shown: float, total: float, first: float) -> void :
	_fblit("ew_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton(key + ":up", "ew_sb_up", at)
	_fbutton(key + ":down", "ew_sb_down", at + Vector2(0, BAR + track))
	var most: float = total - shown
	if most <= 0.0:
		return
	var thumb: float = maxf(20.0, track * shown / total)
	var top: float = at.y + BAR + (track - thumb) * clampf(first / most, 0.0, 1.0)
	_hit(key + ":pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, top - at.y - BAR) * _f), false)
	_hit(key + ":pgdn", Rect2(Vector2(at.x, top + thumb) * _f, Vector2(BAR, at.y + BAR + track - top - thumb) * _f), false)
	var slide: String = "slide:" + key
	_fslice("ew_sb_thumb", Vector2(at.x, top), thumb, 4.0, _glow(slide))
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



func _draw_sign(base: Vector2) -> void :
	_draw_static("sign", base)
	_fbutton("rule", "ev_detail", base + _v(Atlas.SIGN["btnSigninDetail"]))
	if client.sign_in.is_empty():
		_fwords("Đang tải dữ liệu điểm danh…", BOLD, 16.0, Color.WHITE, "c", base + Vector2(0, 288), 690.0, 1.5, 24.0, false, TILE_RIM)
		return
	var now: int = _now()
	var today: int = _today()
	var vip_card: bool = _vip_until() > now

	_fgrad_words("Tháng %d" % int(client.sign_in.get("month", 0)), BOLD, 24.0, MONTH_TOP, MONTH_BOTTOM, base + _v(Atlas.SIGN["lblSigninTitle"]), 180.0)

	var xs: Array = Atlas.SIGN["day_x"]
	var ys: Array = Atlas.SIGN["day_y"]
	var week: Array = pack.events.get("week", [])
	var start: int = _weekday(1)
	for day: int in range(1, _month_days() + 1):
		var slot: int = start + day - 1
		var col: int = slot % 7
		var row: int = slot / 7
		if row >= ys.size():
			break
		var at: Vector2 = base + Vector2(float(xs[col]), float(ys[row]))
		var past: bool = day < today
		if col == 0 or col == 6:
			_fblit("ev_weekend_grey" if past else "ev_weekend", at)
		if day == today:
			_fblit("ev_today", at)
		elif past:
			_fblit("ev_pass", at)
		var gifts: Array = _gifts(week[col]) if col < week.size() else []

		var box: int = _sign_box(day)
		var art: String = str(_item(box, 1).get("art", "")) if box > 0 else ""
		var picture: Texture2D = pack.picture(art) if not art.is_empty() else null
		if picture != null and picture.get_width() > 4:
			var shown: Texture2D = _grey(picture) if past else picture
			draw_texture_rect(shown, _fit_rect(shown, Rect2((at + Vector2(10, 1)) * _f, Vector2(50, 50) * _f)), false)
		_fwords(str(day), BOLD, 20.0, Color.WHITE, "r", at + Vector2(0, 33), 67.0, 1.5, 24.0, false, Color("002659"))
		if _signed(day):
			_fblit("ev_signed", at + Vector2(18, 9))
		var id: String = ""
		if day == today and ( not _signed(day) or (_vip_on() and not _vip_signed(day))):
			id = "day:%d" % day
			_hit(id, Rect2(at * _f, Vector2(69, 51) * _f), false)
		if box > 0 and (pack.bag.get("items", {}) as Dictionary).has(str(box)):
			_peek_item(Rect2(at * _f, Vector2(69, 51) * _f), _item(box, 1), id)
		else:
			_peek_gifts(Rect2(at * _f, Vector2(69, 51) * _f), "Quà điểm danh ngày %d" % day, gifts, id)

	var level: int = maxi(_my_vip(), 1)
	var vip_rows: Array = pack.events.get("vip_gift", [])
	var vip_gifts: Array = _gifts(vip_rows[level - 1]) if level <= vip_rows.size() else []
	var spot: Array = Atlas.SIGN["vip_items"]
	for i: int in mini(vip_gifts.size(), 6):
		var gift: Dictionary = vip_gifts[i]
		var at: Vector2 = base + Vector2(float(spot[0]), float(spot[1]) + float(spot[2]) * i)
		if int(gift.quality) > 1:
			_fblit("ev_iq%d" % clampi(int(gift.quality), 2, 5), at + Vector2(6, 6))
		var art: String = str(gift.get("art", ""))
		var picture: Texture2D = pack.picture(art) if not art.is_empty() else null
		if picture != null and picture.get_width() > 4:
			draw_texture_rect(picture, _fit_rect(picture, Rect2((at + Vector2(4, 4)) * _f, Vector2(52, 49) * _f)), false)
		_fwords(str(int(gift.count)), BOLD, 11.0, Color.WHITE, "r", at + Vector2(-30, 37), 85.0, 1.0, 0.0, false)
		_peek_item(Rect2((at + Vector2(4, 4)) * _f, Vector2(52, 49) * _f), gift)

	var count: int = int(client.sign_in.get("count", 0))
	var px: float = 0.0
	if count <= 5:
		px = count / 5.0 * 42.0
	elif count <= 12:
		px = 99.0 + (count - 5) / 7.0 * 75.0
	else:
		px = 231.0 + (count - 12) / 9.0 * 72.0
	px = minf(px, 303.0)
	if px > 0.0:
		_fpart("ev_progress", base + _v(Atlas.SIGN["imgSignInProgress"]), Rect2(0, 0, px, 10))
	_fwords(str(count), BOLD, 12.0, Color.WHITE, "c", base + _v(Atlas.SIGN["lblSignInDays"]), 22.0, 1.0, 0.0, false)

	var stage: int = int(client.sign_in.get("stage", 0))
	var marks: Array = pack.events.get("marks", [])
	var keys: Array = ["frmCount5Day", "frmCount12Day", "frmCount21Day"]
	var chosen: int = 0 if stage < 5 else (1 if stage < 12 else 2)
	for i: int in mini(marks.size(), keys.size()):
		var need: int = int(marks[i][0])
		var at: Vector2 = base + _v(Atlas.SIGN[keys[i]])
		var can: bool = count >= need and stage < need
		_fblit("ev_chest_sel" if i == chosen else "ev_chest", at)
		if stage >= need:
			_fblit("ev_got%d" % need, at + Vector2(9, 9))
		else:
			var picture: Texture2D = pack.picture("l/it/gift_totalday_%d.webp" % need)
			if picture != null and picture.get_width() > 4:
				draw_texture_rect(picture, _fit_rect(picture, Rect2((at + Vector2(9, 9)) * _f, Vector2(50, 50) * _f)), false)
		var id: String = ""
		if can:
			if i == chosen:
				if _movie_ready(MOVIE_CHEST):
					_movie(MOVIE_CHEST, at + Vector2(34, 34), 0.5)
				else:
					_fblit("ev_halo_chest", at + Vector2(-10, -10), 0.0, 0.0, Color(1, 1, 1, _pulse()))
			id = "mark:%d" % need
			_hit(id, Rect2(at * _f, Vector2(68, 68) * _f), false)
		_peek_gifts(Rect2(at * _f, Vector2(68, 68) * _f), "Quà điểm danh %d ngày" % need, _gifts(marks[i][1]), id)

	var enabled: bool = ( not _vip_signed(today)) if vip_card else ( not _signed(today))
	var cell: String = ("ev_btn_vip" if vip_card else "ev_btn_sign") if enabled else "ev_btn_done"
	var button: Vector2 = base + _v(Atlas.SIGN["btnSignin"])
	var lit: bool = not _signed(today) or (vip_card and not _vip_signed(today))
	if lit and not _movie_ready(MOVIE_SIGN):
		var halo: Vector2 = _cell_size("ev_halo_btn")
		_fblit("ev_halo_btn", base + _v(Atlas.SIGN["swf"]) - halo / 2.0, 0.0, 0.0, Color(1, 1, 1, _pulse()))
	if enabled:
		_fbutton("sign_btn", cell, button)
	else:
		_fblit(cell, button)
	if not vip_card:
		_fbutton("become", "ev_become", base + _v(Atlas.SIGN["btnBecomeVip"]))
	if lit and _movie_ready(MOVIE_SIGN):
		_movie(MOVIE_SIGN, base + _v(Atlas.SIGN["swf"]), 1.0)


func _draw_rule(base: Vector2) -> void :
	_hit("panel", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = base + _v(Atlas.SIGN["rule"])
	_fblit("ev_rule", at + _v(Atlas.PANELS["rule"]))
	_fbutton("rule_close", "ev_close", at + _v(Atlas.RULE["btnClose"]))






const CARD_TILES: Array = [[238.5, 135], [402.5, 135]]

func _card_tile(index: int) -> Vector2:
	return _v(CARD_TILES[index])

func _draw_card(base: Vector2) -> void :
	_draw_static("card", base)
	var card: Dictionary = pack.events.get("card", {})
	var cash: int = int(card.get("cash", 0))
	var item: Dictionary = _item(int(card.get("item", 0)), 0)
	var coin: Dictionary = _coin(1, 0)
	coin["name"] = "%d%s" % [cash, "Xu Khóa"]
	_draw_tile(coin, base + _card_tile(0))
	_draw_tile(item, base + _card_tile(1))
	_fwords("Quy tắc nhận:", BOLD, 14.0, Color("ffff00"), "l", base + _v(Atlas.REBATE["_RebateFrame_Label1"]), 300.0, 1.0, 0.0, false, TILE_RIM)
	var text: String = "1、 Trong %d ngày nhận %d Xu Khóa/ngày, tặng thêm %d [%s].\n2、 Nếu chưa nhận thưởng, có thể tích lũy nhận lúc nào cũng được." % [
		int(card.get("days", 0)), cash, int(card.get("count", 0)), GarageModel.cap(str(item.name))]
	var lines: Array = _wrap(text, BOLD, 12.0, 400.0)
	var spot: Vector2 = base + _v(Atlas.REBATE["_RebateFrame_Text1"])
	for i: int in lines.size():
		_fwords(str(lines[i]), BOLD, 12.0, Color.WHITE, "l", spot + Vector2(0, 16.0 * i), 400.0, 1.0, 0.0, false, TILE_RIM)
	var now: int = _now()
	var days: int = _card_days()
	var left: int = maxi(0, ceili(float(_card_until() - now) / DAY))
	_fwords(str(days), BOLD, 26.0, Color("fdff60"), "l", base + _v(Atlas.REBATE["lblCanGetCount"]), 80.0, 1.0, 0.0, false, TILE_RIM)
	_fwords(str(left), BOLD, 26.0, Color("fdff60"), "l", base + _v(Atlas.REBATE["lblLeftDay"]), 80.0, 1.0, 0.0, false, TILE_RIM)
	if days > 0:
		_fbutton("card", "ev_rb_get", base + _v(Atlas.REBATE["btnGetAward"]))
	elif left > 0:
		_fblit("ev_rb_got", base + _v(Atlas.REBATE["btnGetAward"]))
	else:
		_fbutton("shop_card", "ev_rb_buy", base + _v(Atlas.REBATE["btnBuy"]))
	if left > 0:
		_fbutton("shop_card", "ev_rb_pay", base + _v(Atlas.REBATE["btnContinuePay"]))



func _draw_accum(base: Vector2) -> void :
	_draw_static("accum", base)
	var rows: Array = pack.events.get("accum", [])
	_fwords(str(maxi(0, _accum_total())), BOLD, 16.0, Color("fede04"), "l", base + _v(AtlasV.TC["lblPoint"]), 70.0, 1.0, 0.0, true)

	var spec: Array = AtlasV.TC["list"]
	var list: Rect2 = Rect2(base + _v(spec), Vector2(float(spec[2]), float(spec[3])))
	_list_rect = Rect2(list.position * _f, list.size * _f)
	_accum_first = clampi(_accum_first, 0, maxi(0, rows.size() - ROWS_SHOWN))
	_clip = _list_rect
	for k: int in ROWS_SHOWN + 1:
		var i: int = _accum_first + k
		if i >= rows.size():
			break
		var at: Vector2 = list.position + Vector2(0, ROW_H * k)
		var on: bool = i == _accum_pick
		var rim: Color = PICK_RIM if on else ROW_RIM
		_cblit("ew_sub_on" if on else "ew_sub", at)
		_cwords(str(i), BOLD, 14.0, Color.WHITE, "c", at + Vector2(4, 8), 20.0, 1.0, 0.0, false, rim)
		_cwords("Tích lũy %d xu" % int(rows[i][1]), BOLD, 13.0, Color.WHITE, "l", at + Vector2(33, 0), 136.0, 1.0, ROW_H, true, rim)
		match _accum_row_state(int(rows[i][0])):
			DOING:
				_cblit("ew_underway", at + Vector2(146, 5.5))
			FINISH:
				_cblit("ew_finish", at + Vector2(146, 5.5))
		_chit("row:%d" % i, Rect2(at * _f, Vector2(196, ROW_H) * _f))
	_clip = Rect2()
	if rows.size() > ROWS_SHOWN:
		_scrollbar("list", base + Vector2(list.end.x - base.x - BAR, list.position.y - base.y), list.size.y - 2.0 * BAR, ROWS_SHOWN, rows.size(), _accum_first)
	if _accum_pick < 0 or _accum_pick >= rows.size():
		return

	var row: Array = rows[_accum_pick]
	var gifts: Array = _gifts(row[2])
	var vspec: Array = AtlasV.TC["vBoxReward"]
	var view: Rect2 = Rect2(base + _v(vspec), Vector2(float(vspec[2]), float(vspec[3])))
	_view_rect = Rect2(view.position * _f, view.size * _f)
	var tile_rows: int = ceili(gifts.size() / 5.0)
	_content_h = 6.0 + 59.0 + 10.0 + (22.0 + tile_rows * 110.0) + 10.0 + 22.0 + 30.0
	_view = clampf(_view, 0.0, maxf(0.0, _content_h - VIEW_H))
	_clip = _view_rect
	_cwords("Tích lũy %d xu" % int(row[1]), BOLD, 27.0, Color.WHITE, "l", base + _v(AtlasV.TC["txtDesz"]) - Vector2(0, _view), 427.0, 1.5, 0.0, true, Color("0b333c"))
	_cblit("ew_tc_head", base + _v(AtlasV.TC["head"]) - Vector2(0, _view))
	var tiles: Vector2 = base + _v(AtlasV.TC["tiles"]) - Vector2(0, _view)
	for j: int in gifts.size():
		_draw_tile(gifts[j], tiles + Vector2(91.0 * (j % 5), 110.0 * (j / 5)))
	_clip = Rect2()
	if _content_h > VIEW_H:
		_scrollbar("view", Vector2(view.end.x - BAR, view.position.y), view.size.y - 2.0 * BAR, VIEW_H, _content_h, _view)

	match _accum_button(int(row[0])):
		"got":
			_fblit("ew_tc_got", base + _v(AtlasV.TC["btnGeted"]))
		"now":
			_fbutton("claim_accum", "tl_now", base + _v(AtlasV.TC["btnGoCharge"]))
		_:
			_fblit("tl_now_off", base + _v(AtlasV.TC["btnGoCharge"]))



func _draw_growth(base: Vector2) -> void :
	_draw_static("growth", base)
	_fblit("eg_tab", base + _v(AtlasW.GROW["btnConsumeBack"]))
	var spec: Array = AtlasW.GROW["list"]
	var list: Rect2 = Rect2(base + _v(spec), Vector2(float(spec[2]), float(spec[3])))
	_grow_rect = Rect2(list.position * _f, list.size * _f)
	_grow_first = clampi(_grow_first, 0, maxi(0, _grows.size() - GROW_SHOWN))
	_clip = _grow_rect
	for k: int in 4:
		var i: int = _grow_first + k
		var at: Vector2 = list.position + Vector2(0, GROW_H * k)
		if i >= _grows.size() or at.y >= list.end.y:
			break
		_draw_grow_row(int(_grows[i]), at)
	_clip = Rect2()
	if _grows.size() > GROW_SHOWN:
		_scrollbar("grow", Vector2(list.end.x - BAR, list.position.y), list.size.y - 2.0 * BAR, GROW_SHOWN, _grows.size(), _grow_first)

func _draw_grow_row(quest: int, at: Vector2) -> void :
	_cblit("eg_row", at + _v(AtlasW.GROW_ROW["bg"]))
	var row: Array = _tmpl(quest)
	if not row.is_empty():

		var text: String = str(row[Q_DESC])
		var need: String = str(int(row[Q_COUNT]))
		var cut: int = text.find(need)
		var parts: Array = [[text, Color.WHITE]]
		if cut >= 0:
			parts = [[text.substr(0, cut), Color.WHITE], [need, Color("ffff00")], [text.substr(cut + need.length()), Color.WHITE]]

		var done: String = _grow_progress(quest, int(row[Q_COUNT]))
		if not done.is_empty():
			parts.append([" (", Color.WHITE])
			parts.append([done, Color("00ff00") if _state(quest) == 3 else Color.WHITE])
			parts.append([")", Color.WHITE])
		_spans(parts, 16.0, "l", at + _v(AtlasW.GROW_ROW["llbDesc"]), 450.0, 1.0, 0.0, Color("0753b9"))
		var gifts: Array = _quest_gifts(row)
		for j: int in gifts.size():
			_draw_tile(gifts[j], at + _v(AtlasW.GROW_ROW["tiles"]) + Vector2(91.0 * j, 0))
	if not _growth_on():
		_cbutton("shop_growth", "eg_active", at + _v(AtlasW.GROW_ROW["btnActiveQuest"]))
	elif not client.quests.has(quest) or _state(quest) == 4:
		_cblit("eg_got", at + _v(AtlasW.GROW_ROW["imgGetedAward"]))
	elif _state(quest) == 3 and _wait != quest:
		_cbutton("claim:q%d" % quest, "eg_get", at + _v(AtlasW.GROW_ROW["btnGetAward"]))
	else:
		_cblit("eg_get_off", at + _v(AtlasW.GROW_ROW["btnGetAward"]))



func _draw_vip(base: Vector2) -> void :
	_draw_static("vip", base)
	var now: int = _now()
	var until: int = _vip_until()
	var on: bool = until > now
	var rows: Array = pack.events.get("vip", [])
	var top: int = rows.size()
	var level: int = _my_vip()
	var points: int = _vip_points()

	var avatars: Dictionary = pack.lobby.get("avatars", {})
	var key: String = str(avatars.get(str(int(client.character.get("avatarId", 0))), ""))
	var head: Texture2D = pack.picture("l/h/%s.webp" % key) if not key.is_empty() else null
	if head != null and head.get_width() > 4:
		draw_texture_rect(head, Rect2((base + _v(AtlasV.VIP["imgHead"])) * _f, Vector2(60, 60) * _f), false)
	else:
		_fblit("ew_head", base + _v(AtlasV.VIP["imgHead"]))
	_fwords(str(client.character.get("name", "")), BOLD, 14.0, Color("004b9e"), "l", base + _v(AtlasV.VIP["lblCharName"]), 300.0, 0.0, 0.0, false)
	var badge: String = ("ew_vip%d" if on else "ew_vipn%d") % level
	if level > 0 and _cells.has(badge):
		_fblit(badge, base + _v(AtlasV.VIP["imgVipLevel"]))
	var next_points: int = int(rows[level][0]) if level < top else (int(rows[top - 1][0]) if top > 0 else 0)
	if on:
		_fblit("ew_c19", base + _v(AtlasV.VIP["cimagechecklocal19"]))
		_fblit("ew_c0", base + _v(AtlasV.VIP["cimagechecklocal0"]))
		_fwords(BagModel.fmt_left(maxi(0, until - now)), BOLD, 12.0, Color.WHITE, "l", base + _v(AtlasV.VIP["lblLeftVipDay"]), 95.0, 1.0, 0.0, true, Color("0390d3"))
		_fbutton("shop_vip", "ew_more", base + _v(AtlasV.VIP["btnMoreVip"]))
		_fblit("ew_c21", base + _v(AtlasV.VIP["cimagechecklocal21"]))
		_fwords(str(int(client.character.get("vipPointsAddToday", 0))), BOLD, 14.0, Color.WHITE, "l", base + _v(AtlasV.VIP["lblVipTodayPoint"]), 99.0, 1.0, 0.0, false)
		_fblit("ew_vipadd", base + _v(AtlasV.VIP["vipadd"]))
		_fwords(str(points), BOLD, 14.0, Color("ffed58"), "c", base + _v(AtlasV.VIP["lblVipPoint"]), 75.0, 1.0, 22.92, false)
		if level < top:
			_fwords("Trở thành", BOLD, 14.0, Color.WHITE, "c", base + _v(AtlasV.VIP["vipProcessLbl"]), 39.0, 1.0, 22.92, true)
			_fblit("ew_vips%d" % (level + 1), base + _v(AtlasV.VIP["imgVipNextLevel"]))
			_spans([["Thiếu ", Color.WHITE], [str(maxi(0, next_points - points)), RED_TEXT]], 14.0, "l", base + _v(AtlasV.VIP["lblNextViplvNeed"]), 157.35, 1.0, 22.0, SHADE)
	else:
		_fblit("ew_c22", base + _v(AtlasV.FIRST["c22"]))
		_fblit("ew_buy_bg", base + _v(AtlasV.FIRST["img_buyVip_bg"]))
		_fbutton("shop_vip", "ew_buy", base + _v(AtlasV.FIRST["btnBuyVip"]))
		_fblit("ew_tobe", base + _v(AtlasV.FIRST["imgTobeVipTip"]))
	_fbutton("priv", "ew_priv", base + _v(AtlasV.VIP["btnVipPrivilege"]))

	if level > 0:
		_fblit("ew_vips%d" % level, base + _v(AtlasV.VIP["imgCurVip"]))
	if level < top:
		_fblit("ew_vips%d" % (level + 1), base + _v(AtlasV.VIP["imgNextVip"]))
	var px: float = minf(321.0, 321.0 * points / float(next_points)) if next_points > 0 else 0.0
	if px > 0.0:
		_fpart("ew_bar", base + _v(AtlasV.VIP["imgVipProcess"]), Rect2(0, 0, minf(px, 316.0), 20))
	_spans([[str(points), RED_TEXT], ["/%d" % next_points, Color.WHITE]], 15.0, "c", base + _v(AtlasV.VIP["lblVipProcessInfo"]), 321.0, 1.0, 22.0, SHADE)
	var award: String = "Tăng thành VIP%d được nhận 1 quà VIP%d" % [level + 1, level + 1] if level < top else "VIP đạt giới hạn"
	_fwords(award, BOLD, 16.0, Color.WHITE, "c", base + _v(AtlasV.VIP["lblGetAwardDesc"]), 377.0, 1.0, 38.0, true)

	var perk: Array = rows[maxi(level, 1) - 1] if top > 0 else []
	for i: int in AtlasV.PRIV.size():
		var spec: Array = AtlasV.PRIV[i]
		var at: Vector2 = base + _v(spec)
		var value: String = _perk_value(str(spec[2]), perk)
		if not value.is_empty():
			_fwords(value, BOLD, 12.0, Color.WHITE, "r", at + Vector2(0, 44), 75.0, 1.0, 0.0, false)
		if not str(spec[3]).is_empty() and _perk_locked(str(spec[3]), perk, level):
			_fblit("ew_lock", at + Vector2(11.5, -3.5))
		_fwords(str(PRIV_NAMES[i]), BOLD, 11.0, Color.WHITE, "c", at + Vector2(0, 78), 100.0, 1.0, 16.0, true)

	_draw_vip_award(base + VIP_AWARD_AT, level, "vip_award", {})


func _perk_value(label: String, perk: Array) -> String:
	if perk.size() < 10:
		return ""
	match label:
		"lblRelive":
			return "-%dGiây" % int(perk[1])
		"lblLifeAdd":
			return "+%d" % int(perk[6])
		"lblGolden":
			return "+%d%%" % int(perk[4])
		"lblPveDrop":
			return "+%d%%" % int(perk[5])
		"lblExtraThew":
			return "%d" % int(perk[7])
		"lblFreeRent":
			return "0"
	return ""

func _perk_locked(lock: String, perk: Array, level: int) -> bool:
	match lock:
		"imgLockChallenge":
			return level == 0
		"imgLockSweep":
			return perk.size() < 10 or int(perk[8]) != 1
		"imgLockGambling":
			return perk.size() < 10 or int(perk[9]) != 1
	return true



func _draw_vip_award(at: Vector2, index: int, id: String, tip: Dictionary) -> void :
	var mark: Array = _vip_level_mark(index)
	if mark.is_empty():
		return
	var gift: Dictionary = _item(int(mark[2]), int(mark[3]))
	var rect: Rect2 = Rect2(at * _f, Vector2(81, 81) * _f)
	if _vip_level_ready(int(mark[0])):
		_fblit("ep_halo", at - Vector2(10, 10), 0.0, 0.0, Color(1, 1, 1, _pulse()))
	var art: String = str(gift.get("art", ""))
	var picture: Texture2D = pack.picture(art) if not art.is_empty() else null
	if picture != null:
		draw_texture_rect(picture, _fit_rect(picture, rect), false)
	_hit(id, rect, false)
	_peek_item(rect, gift if tip.is_empty() else tip, id)



func _draw_priv(vip_base: Vector2) -> void :
	var base: Vector2 = vip_base + (SIZES["vip"] - PRIV_SIZE) / 2.0
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("pshade", Rect2(Vector2.ZERO, size), false)
	_hit("ppanel", Rect2(base * _f, PRIV_SIZE * _f), false)
	_fblit("ep_priv", base + _v(AtlasP.PANELS["priv"]))
	var rows: Array = pack.events.get("vip", [])
	var top: int = rows.size()
	var level: int = _my_vip()
	var points: int = _vip_points()
	var cur: int = clampi(_priv, 1, maxi(1, top))

	var need: int = int(rows[mini(level, top - 1)][0]) if top > 0 else 0
	if level > 0 and _cells.has("ew_vip%d" % level):
		_fblit("ew_vip%d" % level, base + _v(AtlasP.PRIV["imgCurVip"]))
	if level < top and _cells.has("ew_vip%d" % (level + 1)):
		_fblit("ew_vip%d" % (level + 1), base + _v(AtlasP.PRIV["imgNextVip"]))
	var px: float = minf(361.0, floorf(361.0 * points / float(need))) if need > 0 else 0.0
	if px > 0.0:
		_fpart("ep_bar", base + _v(AtlasP.PRIV["csvVipProcess"]), Rect2(0, 0, minf(px, 356.0), 20))
	_spans([[str(points), RED_TEXT], ["/%d" % need, Color.WHITE]], 15.0, "c", base + _v(AtlasP.PRIV["lblVipProcessInfo"]), 361.0, 1.0, 22.0, VIP_GLOW)
	_fbutton("pmore", "ep_more", base + _v(AtlasP.PRIV["btnMoreVip"]))

	if _cells.has("ew_vips%d" % cur):
		_fblit("ew_vips%d" % cur, base + _v(AtlasP.PRIV["imgCurPageVip"]))
	_fwords("Điểm Tôn Quý:", BOLD, 14.0, Color.WHITE, "c", base + Vector2(195, 161), 127.0, 1.0, 22.92, true, VIP_GLOW)
	_fwords(str(int(rows[cur - 1][0])) if top > 0 else "0", BOLD, 14.0, Color("ffed58"), "c", base + _v(AtlasP.PRIV["lblVipPoint"]), 59.0, 1.0, 22.92, true, VIP_GLOW)
	var desc: Array = AtlasP.PRIV["desc"]
	var lines: Array = _priv_lines(cur)
	for i: int in lines.size():
		var line: Array = lines[i]
		var parts: Array = [[str(line[0]), Color.WHITE]]
		if not str(line[1]).is_empty():
			parts.append([str(line[1]), PERK_GREEN])
		if not str(line[2]).is_empty():
			parts.append([str(line[2]), Color.WHITE])
		_spans(parts, 15.0, "l", base + Vector2(float(desc[0]), float(desc[1]) + PRIV_ROW * i), float(desc[2]), 1.0, PRIV_ROW - 1.0, SHADE)
	_fwords("Quà Ngày", BOLD, 15.0, Color.WHITE, "c", base + Vector2(583, 323), 81.0, 0.0, 22.0, true)
	_fwords("Quà Lv VIP%d" % cur, BOLD, 15.0, Color.WHITE, "c", base + Vector2(553, 450), 146.0, 0.0, 22.0, true)

	var extra: Array = pack.eventsx.get("vip_more", [])
	var daily: int = int(extra[cur - 1][1]) if cur <= extra.size() and extra[cur - 1] is Array and (extra[cur - 1] as Array).size() >= 2 else 0
	_draw_vip_award(base + _v(AtlasP.PRIV["vipLvAward1"]), cur - 1, "priv_award1", _item(daily, 1) if daily > 0 else {})
	_draw_vip_award(base + _v(AtlasP.PRIV["vipLvAward0"]), cur - 1, "priv_award0", {})
	if cur >= 2:
		_fbutton("pleft", "ep_left", base + _v(AtlasP.PRIV["btnLeft"]))
	else:
		_fblit("ep_left_off", base + _v(AtlasP.PRIV["btnLeft"]))
	if cur < top:
		_fbutton("pright", "ep_right", base + _v(AtlasP.PRIV["btnRight"]))
	else:
		_fblit("ep_right_off", base + _v(AtlasP.PRIV["btnRight"]))
	_fbutton("pclose", "ep_close", base + _v(AtlasP.PRIV["btnClose"]))




func _draw_first(base: Vector2) -> void :
	_draw_static("first", base)
	var gifts: Array = _first_gifts()
	for i: int in gifts.size():
		var at: Vector2 = base + _v(AtlasF.FIRST["award%d" % (i + 1)])
		if i == 0:

			_fblit("ef_halo_tile", at + _v(Atlas.AWARD["bg"]) - Vector2(10, 10), 0.0, 0.0, Color(1, 1, 1, _pulse()))
		_draw_tile(gifts[i], at)
	var button: Vector2 = base + _v(AtlasF.FIRST["btnGetAward"])
	if _first_done():
		_fblit("ef_get_off", button)
		return
	var halo: Vector2 = _cell_size("ef_halo_btn")
	_fblit("ef_halo_btn", button + Vector2(69.5, 26.5) - halo / 2.0, 0.0, 0.0, Color(1, 1, 1, _pulse()))
	if not client.stages.has(FIRST):
		_fbutton("topup", "ef_go", base + _v(AtlasF.FIRST["btnGotoCharge"]))
	elif _first_open():
		_fbutton("claim_first", "ef_get", button)
	else:
		_fblit("ef_get_off", button)


func _draw_award() -> void :
	_reward.paint(self)



func _send(sent: bool, wait_note: String) -> void :
	if not sent:
		say("Chưa gửi được, hãy thử lại.")
		return
	_sent_at = _time
	_note = wait_note
	_note_at = _time + 2.0

func _ready_to_send() -> bool:
	return _time - _sent_at >= 1.0

func _sign_today() -> void :
	if client.sign_in.is_empty():
		return
	if _signed(_today()):
		say("Hôm nay đã điểm danh rồi.")
	elif _ready_to_send():
		_send(client.sign_in_today(), "Đã điểm danh hôm nay.")

func _sign_vip() -> void :
	if not _vip_on():
		say("Cần thẻ VIP còn hạn để nhận quà VIP.")
	elif _vip_signed(_today()):
		say("Hôm nay đã nhận quà VIP rồi.")
	elif _ready_to_send():
		_send(client.sign_in_vip(), "Đã nhận quà VIP hôm nay.")


func _press_sign() -> void :
	if client.sign_in.is_empty():
		return
	if _vip_until() > _now():
		if not _vip_on():
			_open_vip("sign")
		elif not _signed(_today()):
			_sign_today()
		else:
			_sign_vip()
	else:
		_sign_today()

func _tap_day(day: int) -> void :
	if day != _today():
		return
	if not _signed(day):
		_sign_today()
	elif _vip_on() and not _vip_signed(day):
		_sign_vip()

func _claim_mark(mark: int) -> void :
	match _mark_state(mark):
		0:
			say("Cần điểm danh đủ %d ngày trong tháng để mở rương này." % mark)
		2:
			say("Rương này đã nhận rồi.")
		_:

			var next: int = _next_mark()
			if next != 0 and _ready_to_send():
				_send(client.sign_in_mark(next), "Đã mở rương %d ngày." % next)

func _card_pick() -> void :
	if _card_days() <= 0:
		say("Hôm nay đã nhận quà thẻ tháng rồi." if _card_until() > _now() else "Thẻ tháng chưa kích hoạt.")
	elif _ready_to_send():
		_send(client.cashback_pick(), "Đã nhận quà thẻ tháng.")

func _reap_accum() -> void :
	var current: int = _accum_current()
	if current == 0 or not _accum_open():
		say("Chưa đạt mốc tích lũy này.")
	elif _ready_to_send():
		_send(client.stage_reap(current, true), "")


func _reap_first() -> void :
	if _first_done():
		say("Quà này đã nhận rồi.")
	elif not _first_open():
		say("Chưa đủ điều kiện nhận quà này.")
	elif _ready_to_send():
		_send(client.stage_reap(FIRST, true), "")

func _claim_quest(quest: int) -> void :
	if not _growth_on() or not client.quests.has(quest) or _state(quest) != 3 or _wait != 0 or not _ready_to_send():
		return
	if client.quest_complete(quest, 0):
		_sent_at = _time
		_wait = quest
		_wait_at = _time
		_note = "Đã nhận quà trưởng thành."
		_note_at = _time + 2.0
	else:
		say("Chưa gửi được, hãy thử lại.")


func _reap_vip_level(index: int) -> void :
	var mark: Array = _vip_level_mark(index)
	if mark.is_empty() or not _vip_level_ready(int(mark[0])) or not _ready_to_send():
		return
	_send(client.stage_reap(int(mark[0]), true), "")


func _activate_priv(id: String) -> void :
	var top: int = pack.events.get("vip", []).size()
	match id:
		"pclose":
			_priv = 0
		"pleft":
			if _priv >= 2:
				_priv -= 1
		"pright":
			if _priv < top:
				_priv += 1
		"pmore":
			_activate_shop_vip()
		"priv_award0", "priv_award1":
			_reap_vip_level(_priv - 1)

func _activate_shop_vip() -> void :
	var sold: Array = pack.events.get("vip_cards", [])
	page_asked.emit("shop:1:%d" % (int(sold[sold.size() - 1][0]) if not sold.is_empty() else 0))

func _open_vip(from: String) -> void :
	_from = from
	_tab = TABS.find("vip")


func _close() -> void :
	if not _from.is_empty() and TABS.has(_from):
		_tab = TABS.find(_from)
		_from = ""
		return
	_from = ""
	closed.emit()

func _activate(id: String) -> void :
	if not _sheet_id.is_empty():
		if id in ["ok", "shade"]:
			_close_sheet()
		return
	if _rule:
		if id == "rule_close":
			_rule = false
		return
	if _priv > 0:
		_activate_priv(id)
		return
	if id.begins_with("day:"):
		_tap_day(int(id.substr(4)))
		return
	if id.begins_with("mark:"):
		_claim_mark(int(id.substr(5)))
		return
	if id.begins_with("row:"):
		var index: int = int(id.substr(4))
		if index != _accum_pick:
			_accum_pick = index
			_view = 0.0
		return
	if id.begins_with("claim:q"):
		_claim_quest(int(id.substr(7)))
		return
	match id:
		"close":
			_close()
		"rule":
			_rule = true
		"sign_btn":
			_press_sign()
		"become":
			_open_vip("sign")
		"card":
			_card_pick()
		"claim_accum":
			_reap_accum()
		"claim_first":
			_reap_first()
		"shop_card":

			page_asked.emit("shop:4:%d" % int(pack.events.get("card", {}).get("id", 0)))
		"shop_growth":
			page_asked.emit("shop:1:%d" % int(_growth().get("item", 0)))
		"shop_vip":
			_activate_shop_vip()
		"topup":
			if not OS.has_feature("pc_app"):
				say(TOPUP)
		"priv":
			_priv = clampi(_my_vip(), 1, maxi(1, pack.events.get("vip", []).size()))
		"vip_award":
			_reap_vip_level(_my_vip())
		_:
			if id.contains(":") and not id.begins_with("slide:"):
				var parts: PackedStringArray = id.split(":")
				_scroll_by(parts[0], parts[1])


func _scroll_by(key: String, how: String) -> void :
	var page: bool = how == "pgup" or how == "pgdn"
	var way: int = -1 if how == "up" or how == "pgup" else 1
	match key:
		"list":
			_set_bar(key, float(_accum_first + way * (ROWS_SHOWN if page else 1)))
		"view":
			_set_bar(key, _view + way * (VIEW_H if page else VIEW_STEP))
		"grow":
			_set_bar(key, float(_grow_first + way * (GROW_SHOWN if page else 1)))

func _bar_value(key: String) -> float:
	match key:
		"list":
			return float(_accum_first)
		"view":
			return _view
		"grow":
			return float(_grow_first)
	return 0.0

func _set_bar(key: String, value: float) -> void :
	match key:
		"list":
			_accum_first = clampi(roundi(value), 0, maxi(0, pack.events.get("accum", []).size() - ROWS_SHOWN))
		"view":
			_view = clampf(value, 0.0, maxf(0.0, _content_h - VIEW_H))
		"grow":
			_grow_first = clampi(roundi(value), 0, maxi(0, _grows.size() - GROW_SHOWN))

func _wheel(step: int, at: Vector2) -> void :
	if not _sheet_id.is_empty() or _rule or _priv > 0:
		return
	if _list_rect.has_point(at):
		_set_bar("list", float(_accum_first + step))
	elif _view_rect.has_point(at):
		_set_bar("view", _view + step * VIEW_STEP)
	elif _grow_rect.has_point(at):
		_set_bar("grow", float(_grow_first + step))


func _drag(moved: Vector2, from: Vector2) -> void :
	if not _grab.is_empty() or not _sheet_id.is_empty() or _rule or _priv > 0:
		return
	if _view_rect.has_point(from):
		_set_bar("view", _view - moved.y / _f)
		return
	var key: String = "list" if _list_rect.has_point(from) else ("grow" if _grow_rect.has_point(from) else "")
	if key.is_empty():
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, (ROW_H if key == "list" else GROW_H) * _f)
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

func _input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if not _sheet_id.is_empty() and event.keycode in [KEY_ESCAPE, KEY_ENTER, KEY_KP_ENTER]:
		_close_sheet()
		get_viewport().set_input_as_handled()
	elif _rule and event.keycode == KEY_ESCAPE:
		_rule = false
		get_viewport().set_input_as_handled()
	elif _priv > 0 and event.keycode == KEY_ESCAPE:
		_priv = 0
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or _rule or _priv > 0 or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()

func _close_sheet() -> void :
	if _sheet_id == "award" and _reward.request_close(self):
		return
	_sheet_id = ""
	_award = []

func _tick_award() -> void :
	if _sheet_id == "award" and _reward.tick(self):
		_close_sheet()
