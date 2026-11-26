extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")











const SafeJson = preload("res://net/safe_json.gd")
const Atlas = preload("fair_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const HelperModel = preload("helper_model.gd")
const HelperTip = preload("helper_tip.gd")
const CTip = preload("ctool_tip.gd")
const AtlasV = preload("fairv_atlas.gd")
const AtlasC = preload("fairc_atlas.gd")
const AtlasP = preload("fairp_atlas.gd")
const Arena = preload("arena_atlas.gd")
const RewardPopup = preload("reward_popup.gd")
const RewardFly = preload("reward_fly.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const ShopModel = preload("shop_model.gd")

signal closed
signal bonfire_asked
signal arena_asked
signal luck_asked
signal event_asked(room: int)

const TABS: Array = ["wheel", "convert", "prize", "center"]
const SIZES: Dictionary = {"wheel": Vector2(1029, 494), "convert": Vector2(882, 532), "prize": Vector2(600, 526), "center": Vector2(812, 512)}
const CODE_AWARD: int = 900001
const STAGE_FROM: int = 1000
const STAGE_TO: int = 1004
const SPIN_COST: Dictionary = {1: 1, 3: 10}
const VIP_WHEEL: int = 3
const RANK_EVERY: float = 300.0
const RETRY: float = 5.0
const WAIT_ROLL: float = 6.0
const LIST_ROWS: int = 8
const CONVERT_TYPES: Array = [4, 2, 3, 5, 6]
const ACT_TYPE: int = 4
const PRIZE_PAGE: int = 3
const ADT_VALID: int = 2
const ARENA_ACT: int = 4
const VN: int = 25200
const COINS: Array = ["Xu", "Xu Khóa", "Bạc"]
const AWARD_ROWS: int = 6
const DIM: Color = Color(0, 0, 0, 0.4)
const OK_GOLD: Color = Color("fff352")
const SHORT_RED: Color = Color("d70018")
const PAGE_BLUE: Color = Color("126df6")
const PAGE_MAX: int = 20
const TILE_RIM: Color = Color("005797", 0.8)
const SOON: String = "Mục này đang được chuyển sang HTML5."
const T_VIP: String = "VIP%d trở lên được hưởng chức năng này"
const T_SHORT: String = "Bóng Thần Bí không đủ"
const T_MOST: String = "Lượng Bóng Thần Bí hiện tại được đổi %d lần"
const T_SWAP: String = "Tốn %d xu thay thế %d xu khóa"
const T_CLOSED: String = "HĐ chưa mở"
const T_REFRESH: String = "Làm mới mỗi 5'"
const T_VIP_COST: String = "Mỗi lượt tốn 10 Cầu Thần Bí"
const T_LIMIT: String = "Giới hạn lượt đổi %d/%d"
const T_LEVEL: String = "Lv %d"
const T_LOW: String = "Lv%d (Chưa đủ lv tham gia)"
const T_BUSY: String = "Không thể thao tác"
const T_COUNTDOWN: String = "%dgiờ%dphút%dgiây sau sẽ bắt đầu HĐ"
const PATHS: Dictionary = {"rank": "/cMysticBallRank.php?p=0", "convert": "/xml/ItemConvertTemplate_table.xml", "award": "/awardquery.php", 
	"acts": "/xml/ActivityTemplate_table.xml"}

var tab: String = "wheel"
var _tab: int = 0
var _sent_at: float = -10.0
var _note: String = ""
var _note_at: float = 0.0
var _sheet_id: String = ""
var _reward: RefCounted = RewardPopup.new()
var _award: Array = []
var _kept: Array = []
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _placed: Array = []
var _buy: LineEdit
var _qty: LineEdit
var _code: LineEdit
var _counts: Dictionary = {}
var _counted_at: float = -10.0
var _stale: bool = true
var _wraps: Dictionary = {}


var _http: HTTPRequest
var _queue: Array = []
var _loading: String = ""
var _bad: Dictionary = {}
var _retry_at: float = 0.0


var _kind_w: int = 1
var _rot: float = 0.0
var _tw_on: bool = false
var _tw_from: float = 0.0
var _tw_to: float = 0.0
var _tw_len: float = 1.0
var _tw_at: float = 0.0
var _tw_ease: String = "lin"
var _tw_done: String = ""
var _playing: bool = false
var _stop_on: bool = true
var _auto: int = 1
var _auto_ok: bool = true
var _direct: bool = false
var _last_index: int = 0
var _target: int = -1
var _waiting: bool = false
var _wait_at: float = 0.0
var _rank_rows: Array = []
var _rank_page: int = 0
var _page_start: Dictionary = {}
var _rank_at: float = -1000.0
var _roll_rows: Dictionary = {}


var _convert_raw: Array = []
var _converts: Array = []
var _sort: int = 0
var _convert_page: int = 0
var _pick: Dictionary = {}
var _amount: int = 1


var _awards: Array = []
var _user: Dictionary = {}
var _prize_page: int = 0
var _code_row: Dictionary = {}


var _acts: Array = []
var _act_pick: int = -1
var act_want: int = 0
var _want_item: int = 0
var _glow_at: int = -1

func _setup() -> void :
	_buy = _fedit(4, true)
	_buy.text = "1"
	_buy.text_changed.connect( func(_text: String) -> void : _on_count_input())
	_qty = _fedit(4, true)
	_qty.text_changed.connect( func(_text: String) -> void : _on_qty_input())
	_qty.text_submitted.connect( func(_text: String) -> void : _confirm_convert())
	_code = _fedit(32)
	_code.text_submitted.connect( func(_text: String) -> void : _submit_code())
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_http)
	pack.picture_ready.connect( func(path: String) -> void :
		if path in ["l/fair.json", "l/bag.json", "l/garage.json", "l/events.json", "l/helper.json"]:
			_stale = true
			_wraps.clear())
	client.awarded.connect(_on_award)
	client.rolled.connect(_on_rolled)
	client.roll_list.connect( func(kind: int, rows: Array) -> void :
		_roll_rows[kind] = rows)
	client.prize_result.connect(_on_prize)
	client.stage_reaped.connect(_on_reaped)
	client.noticed.connect( func(text: String) -> void :
		if is_visible_in_tree():
			_note = ""
			say(text))

func _shown() -> void :
	_reward.reset()
	_flies = []
	RewardFly.reset(self)
	_sheet_id = ""
	if _buy == null:
		return
	if not is_visible_in_tree():
		_hide_edits()
		_reset_wheel()
		return
	pack.load_fair()
	pack.load_bag()
	pack.load_garage()
	pack.load_events()
	if not client.bag_loaded:
		client.request_bags()
	_note = ""
	_sheet_id = ""
	_tip = []
	_stale = true
	_counted_at = -10.0
	if tab.is_empty():
		return
	_tab = maxi(0, TABS.find(tab))
	tab = ""
	_want_item = 0
	_glow_at = -1
	if _kind() == "convert" and act_want > 0:
		_want_item = act_want
		act_want = 0
	_rank_page = 0
	_page_start = {}
	_convert_page = 0
	_prize_page = 0
	_open_tab()


func chat_busy() -> bool:
	if not _sheet_id.is_empty():
		return true
	for edit: LineEdit in [_buy, _qty, _code]:
		if edit != null and edit.visible and edit.has_focus():
			return true
	return false


func _open_tab() -> void :
	match _kind():
		"wheel":
			client.roulette_list(_kind_w)
			_fetch("rank")
			_rank_at = _time
		"convert":
			if _convert_raw.is_empty():
				_fetch("convert")
		"prize":
			if _awards.is_empty():
				_fetch("award")
			_fetch("user")
		_:
			if _acts.is_empty():
				_fetch("acts")



func _fetch(kind: String) -> void :
	if kind == _loading or kind in _queue:
		return
	_queue.append(kind)
	_pump()

func _pump() -> void :
	if not _loading.is_empty() or _queue.is_empty():
		return
	_loading = str(_queue.pop_front())
	var path: String = str(PATHS.get(_loading, ""))
	if _loading == "user":
		path = "/getuseraward.php?account_id=%d" % client.account_id
	_http.cancel_request()
	var url: String = client.config.origin + path
	if _http.request(url, AppSession.headers(url)) != OK:
		_bad[_loading] = true
		_loading = ""
		_pump.call_deferred()

func _on_http(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	var kind: String = _loading
	_loading = ""
	var ok: bool = result == HTTPRequest.RESULT_SUCCESS and code == 200
	if ok:
		match kind:
			"rank":
				ok = _read_rank(body)
			"convert":
				_convert_raw = _xml_rows(body, "entry")
				ok = not _convert_raw.is_empty()
				_stale = true
			"award":
				ok = _read_awards(body)
			"user":
				ok = _read_user(body)
			"acts":
				ok = _read_acts(body)
	if ok:
		_bad.erase(kind)
	else:
		_bad[kind] = true
	_pump()




func _retry_failed() -> void :
	if _time - _retry_at < RETRY:
		return
	_retry_at = _time
	var kind: String = str({"convert": "convert", "prize": "award", "center": "acts"}.get(_kind(), ""))
	if kind == "convert":
		if pack.bag.is_empty():
			pack.load_bag()
		if pack.garage.is_empty():
			pack.load_garage()
	if kind.is_empty() or not _bad.has(kind):
		return
	_bad.erase(kind)
	var have: Array = _convert_raw if kind == "convert" else (_awards if kind == "award" else _acts)
	if have.is_empty():
		_fetch(kind)


func _xml_rows(body: PackedByteArray, tag: String) -> Array:
	var out: Array = []
	var parser: XMLParser = XMLParser.new()
	if parser.open_buffer(body) != OK:
		return out
	var row: Dictionary = {}
	var inside: bool = false
	var field: String = ""
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				var node: String = parser.get_node_name()
				if node == tag:
					row = {}
					for i: int in parser.get_attribute_count():
						row[parser.get_attribute_name(i)] = _xml_text(parser.get_attribute_value(i))
					if parser.is_empty():
						out.append(row)
					else:
						inside = true
				elif inside and not parser.is_empty():
					field = node
			XMLParser.NODE_TEXT, XMLParser.NODE_CDATA:
				if inside and not field.is_empty():
					row[field] = str(row.get(field, "")) + parser.get_node_data()
			XMLParser.NODE_ELEMENT_END:
				var node: String = parser.get_node_name()
				if node == tag and inside:
					for key: Variant in row.keys():
						row[key] = _xml_text(str(row[key])).strip_edges()
					out.append(row)
					inside = false
				elif node == field:
					field = ""
	return out

func _xml_text(text: String) -> String:
	if not "&" in text:
		return text
	return text.replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", "\"").replace("&apos;", "'").replace("&amp;", "&")

func _json(body: PackedByteArray) -> Variant:
	return SafeJson.parse(body.get_string_from_utf8())

func _read_rank(body: PackedByteArray) -> bool:
	var data: Variant = _json(body)
	if not (data is Dictionary):
		return false
	_rank_rows = []
	for row: Variant in data.get("datas", []):
		if row is Dictionary:
			var who: Variant = row.get("char_name")
			_rank_rows.append([BagModel.clean(str(who)) if who != null else "NULL", int(row.get("consume_count", 0))])
	_rank_page = clampi(_rank_page, 0, maxi(0, _pages(_rank_rows.size(), LIST_ROWS) - 1))
	return true


func _read_awards(body: PackedByteArray) -> bool:
	var rows: Array = _xml_rows(body, "row")
	if rows.is_empty():
		return false
	_awards = []
	for row: Dictionary in rows:
		var id: int = int(row.get("op_act_id", "0"))
		if id <= 0 or not str(row.get("op_act_plat", "")).is_empty():
			continue
		_awards.append({"id": id, "title": BagModel.clean(str(row.get("op_act_name", "")).replace("publiccode", "")), 
			"desc": BagModel.clean(str(row.get("op_act_desc", ""))), "type": int(row.get("op_act_type", "0")), 
			"end": int(row.get("op_act_time_end", "0"))})
	return true

func _read_user(body: PackedByteArray) -> bool:
	var data: Variant = _json(body)
	if not (data is Dictionary):
		return false
	_user = {}
	for key: String in ["ok", "ok_code", "complete", "hide"]:
		var marks: Dictionary = {}
		for part: String in str(data.get(key, "")).split(",", false):
			marks[int(part)] = true
		_user[key] = marks
	return true

func _read_acts(body: PackedByteArray) -> bool:
	var rows: Array = _xml_rows(body, "entry")
	if rows.is_empty():
		return false
	_acts = []
	for row: Dictionary in rows:
		if int(row.get("nId", "0")) > 0:
			client.act_types[int(row.get("nId", "0"))] = int(row.get("nType", "0"))
		if str(row.get("isHide", "0")) == "1" or int(row.get("nId", "0")) <= 0:
			continue
		var drops: Array = []
		for part: String in str(row.get("szDropItems", "")).split("$", false):
			if int(part) > 0:
				drops.append(int(part))
		_acts.append({"id": int(row.get("nId", "0")), "name": BagModel.clean(str(row.get("szName", ""))), "desc": BagModel.clean(str(row.get("szDesc", ""))), 
			"type": int(row.get("nType", "0")), "level": int(row.get("nLevel", "0")), 
			"time": str(row.get("szTimeDesc", "")).replace("#ENTER#", " ").strip_edges(), "drops": drops})
	_act_pick = -1
	return true



func _kind() -> String:
	return str(TABS[_tab])

func _now() -> int:
	return int(Time.get_unix_time_from_system())

func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))

func _pages(count: int, per: int) -> int:
	return maxi(1, ceili(float(count) / float(per)))

func _coin_art(index: int) -> String:
	var coins: Array = pack.lobby.get("coins", [])
	return "l/c/%s.webp" % str(coins[index]) if index >= 0 and index < coins.size() and not str(coins[index]).is_empty() else ""


func _item(id: int, count: int) -> Dictionary:
	var key: String = str(id)
	var out: Dictionary = {"kind": "item", "id": id, "count": count, "name": "Vật phẩm %d" % id, "art": "", "quality": 1, "desc": ""}
	var more_row: Variant = pack.bag.get("items", {}).get(key)
	var more: Array = more_row if more_row is Array else []
	if more.size() >= 10:
		out.desc = GarageModel.plain(str(more[1]))
	var info: Variant = pack.fair.get("items", {}).get(key)
	if not (info is Array and (info as Array).size() >= 4):
		info = pack.events.get("items", {}).get(key)
	if info is Array and (info as Array).size() >= 4:
		if not str(info[0]).is_empty():
			out.name = str(info[0])
		out.quality = int(info[2])
		if (info as Array).size() >= 5 and not str(info[4]).is_empty():
			out.art = "l/t/%s.webp" % info[4]
		elif not str(info[1]).is_empty():
			out.art = ("l/av/" if int(info[3]) == 1 else "l/it/") + str(info[1]) + ".webp"
		return out
	var other: Array = pack.bag.get("more", {}).get(key, [])
	if more.size() >= 6:
		out.name = BagModel.clean(str(more[0]))
		out.quality = int(more[3])
		out.art = ("l/av/" if int(more[5]) == 4 else "l/it/") + str(more[2]) + ".webp" if not str(more[2]).is_empty() else ""
	elif other.size() >= 3:
		out.name = BagModel.clean(str(other[0]))
		out.art = "l/it/%s.webp" % other[1] if not str(other[1]).is_empty() else ""
		out.quality = int(other[2])
	var skin: Array = pack.garage.get("skin_items", {}).get(key, [])
	if skin.size() >= 2:
		var face: String = GarageModel.face(pack.garage, int(skin[1]))
		if not face.is_empty():
			out.art = "l/t/%s.webp" % face
	return out

func _coin(index: int, count: int) -> Dictionary:
	return {"kind": "coin", "id": 0, "count": count, "name": str(COINS[index]) if index >= 0 and index < COINS.size() else "Xu", 
		"art": _coin_art(index), "quality": 2 if index == 1 else 1, "desc": ""}


func _recount() -> void :
	_counted_at = _time
	_counts = {}
	for cont: Variant in client.bags.keys():
		for inst: Variant in client.bags[cont]:
			if inst is Dictionary:
				var id: int = int(inst.get("m_templateId", 0))
				_counts[id] = int(_counts.get(id, 0)) + maxi(1, int(inst.get("m_count", 1)))

func _have(id: int) -> int:
	return int(_counts.get(id, 0))

func _vip_points() -> int:
	return int(client.character.get("vipPoints", 0))

func _vip_until() -> int:
	return maxi(int(client.character.get("vipTime", 0)), int(client.character.get("superVipTime", 0)))

func _my_level() -> int:
	return int(client.character.get("level", 0))

func _date(at: int) -> String:
	var parts: Dictionary = Time.get_datetime_dict_from_unix_time(at + VN)
	return " %02d-%02d-%04d" % [int(parts.get("day", 1)), int(parts.get("month", 1)), int(parts.get("year", 1970))]

func _stamp(text: String) -> int:
	if text.strip_edges().is_empty():
		return 0
	return int(Time.get_unix_time_from_datetime_string(text.strip_edges().replace(" ", "T"))) - VN



func _ball() -> int:
	return int(pack.fair.get("ball", 2600004))

func _balls() -> int:
	return _have(_ball())

func _wheel_rows() -> Array:
	return pack.fair.get("wheel", {}).get(str(_kind_w), [])

func _cost() -> int:
	return int(SPIN_COST.get(_kind_w, 1))

func _max_auto() -> int:
	return _balls() / maxi(1, _cost())

func _can_auto() -> bool:
	return _auto > 1 and _max_auto() > 0


func _stage_now() -> int:
	for stage: int in range(STAGE_FROM, STAGE_TO + 1):
		if client.stages.has(stage):
			return stage
	return 0

func _spins() -> int:
	var now: int = _stage_now()
	return int(client.stages[now].get("value", 0)) if now != 0 else 0


func _gift_state(stage: int, need: int) -> int:
	var now: int = _stage_now()
	if now == 0 or now > stage:
		return 2
	if now == stage:
		if int(client.stages[now].get("reaped", 0)) == 1:
			return 2
		var reward: int = int(client.stages[now].get("reward", 0))
		if reward == 1:
			return 1
		if _spins() >= need:
			return 2
	return 0


func _progress() -> float:
	var count: int = _spins()
	var steps: Array = Atlas.ALMS["steps"]
	var percent: Array = Atlas.ALMS["percent"]
	if count >= int(steps[steps.size() - 1]):
		return 100.0
	var at: int = 0
	for i: int in steps.size():
		if count < int(steps[i]):
			break
		at = i
	var low: float = float(percent[at])
	var high: float = float(percent[at + 1])
	return floorf(low + (high - low) * float(count - int(steps[at])) / float(int(steps[at + 1]) - int(steps[at])))

func _wheel_item(row: Array) -> Dictionary:
	return _item(int(row[1]), int(row[2])) if row.size() >= 3 else {}


func _roll_slot(slot: int) -> Array:
	var wheels: Dictionary = pack.fair.get("wheel", {})
	for kind: String in [str(_kind_w)] + wheels.keys():
		for row: Variant in wheels.get(kind, []):
			if row is Array and int(row[0]) == slot:
				return row
	return []

func _slot_index(slot: int) -> int:
	var rows: Array = _wheel_rows()
	for i: int in rows.size():
		if int(rows[i][0]) == slot:
			return i
	return -1




func _norm(deg: float) -> float:
	var out: float = fposmod(deg, 360.0)
	return out - 360.0 if out > 180.0 else out

func _tween(to: float, length: float, ease: String, done: String) -> void :
	_tw_from = _norm(_rot)
	_tw_to = to
	_tw_len = length
	_tw_at = _time
	_tw_ease = ease
	_tw_done = done
	_tw_on = true

func _eased(t: float) -> float:
	match _tw_ease:
		"in":
			return t * t
		"quad":
			return 1.0 - (1.0 - t) * (1.0 - t)
		"expo":
			return 1.0 if t >= 1.0 else 1.0 - pow(2.0, -10.0 * t)
	return t

func _spin_tick() -> void :
	if _btb_on:
		_btb_tick()
		return
	if _waiting and not _tw_on and _time - _wait_at > WAIT_ROLL:
		_waiting = false
		_set_play(true)
		_stop_on = true
		_show_kept()
	if not _tw_on:
		return
	var t: float = clampf((_time - _tw_at) / maxf(0.01, _tw_len), 0.0, 1.0)
	_rot = _tw_from + (_tw_to - _tw_from) * _eased(t)
	_on_rolling()
	if t < 1.0:
		return
	_tw_on = false
	match _tw_done:
		"play":
			_play_gambling()
		"complete":
			_on_dial_complete()
		"result":
			_on_show_result()


func _on_rolling() -> void :
	var angle: float = _norm(_rot)
	var deg: int = int(angle) if angle >= 0.0 else int(360.0 + angle)
	var index: int = roundi(deg / 36.0)
	if index >= 10:
		index = 0
	_last_index = index
	if _tw_done == "complete" and _can_auto() and _auto_ok and _last_index == 2:
		_request()
		_auto_ok = false

func _star_gambling() -> void :
	_set_play(false)
	_tween(1080.0, 3.0, "in", "play")

func _play_gambling() -> void :
	_tween(7200.0, 10.0, "lin", "complete")

func _on_dial_complete() -> void :
	_stop_on = false
	_request()

func _stop_gambling() -> void :
	var sign: float = -1.0 if randf() > 0.5 else 1.0
	var to: float = 720.0 + _target * 36.0 + sign * randf() * 16.0
	_tween(to, 6.0, "quad" if randf() > 0.5 else "expo", "result")

func _on_show_result() -> void :
	_last_index = _target
	_set_play(true)
	_stop_on = true
	client.roulette_list(_kind_w)
	_show_kept()
	_set_count(int(_buy.text) if _buy.text.is_valid_int() else 1)

func _request() -> void :
	_waiting = true
	_wait_at = _time
	if not client.roulette_spin(_kind_w, false):
		_waiting = false
		_tw_on = false
		_set_play(true)
		_stop_on = true
		say("Chưa gửi được, hãy thử lại.")

func _on_rolled(slot: int) -> void :
	if not is_visible_in_tree() or not _playing:
		return
	if _btb_on:
		_btb_rolled(slot)
		return
	_waiting = false
	if _can_auto():
		_direct = _auto > 1
		_auto -= 1
		_set_count(_auto)
		_play_gambling()
		_auto_ok = true
		return
	_target = maxi(0, _slot_index(slot))
	_direct = false
	_stop_gambling()


func _set_play(on: bool) -> void :
	_playing = not on
	if _buy != null:
		_buy.editable = on


func _set_count(count: int) -> void :
	_recount()
	_auto = maxi(1, mini(count, _max_auto()))
	_buy.text = str(_auto)
	_buy.caret_column = _buy.text.length()

func _on_count_input() -> void :
	if _playing:
		return
	_set_count(int(_buy.text) if _buy.text.is_valid_int() else 0)

func _reset_wheel() -> void :
	_btb_abort()
	_tw_on = false
	_waiting = false
	_playing = false
	_stop_on = true
	_auto_ok = true
	_kept = []
	if _buy != null:
		_buy.editable = true

func _start() -> void :
	if _playing:
		return
	if _kind_w == 3 and (_vip_level(_vip_points()) < VIP_WHEEL or _vip_until() <= _now()):
		say(T_VIP % VIP_WHEEL)
		return
	_recount()
	if _balls() < _cost():
		say(T_SHORT)
		return
	_set_count(int(_buy.text) if _buy.text.is_valid_int() else 0)
	_auto_ok = true
	if _auto >= 2:
		_btb_begin()
		return
	_star_gambling()

func _stop_click() -> void :
	if not _playing or not _stop_on:
		return
	if _btb_on:
		_btb_stop()
		return
	_auto = 1
	_auto_ok = false
	_stop_on = false
	_request()

func _add_count(step: int) -> void :
	if _playing:
		return
	_recount()
	var count: int = (int(_buy.text) if _buy.text.is_valid_int() else 1) + step
	if step > 0 and count > _max_auto():
		count = _max_auto()
		say(T_MOST % _max_auto())
	_set_count(count)

func _switch_wheel(kind: int) -> void :
	if _playing or kind == _kind_w:
		return
	_kind_w = kind
	_last_index = 0
	client.roulette_list(_kind_w)
	_set_count(int(_buy.text) if _buy.text.is_valid_int() else 1)

func _reap(index: int) -> void :
	var stages: Array = pack.fair.get("stages", [])
	if index < 0 or index >= stages.size():
		return
	var stage: int = int(stages[index][0])
	if _gift_state(stage, int(stages[index][1])) != 1 or not _ready_to_send():
		return
	_send(client.stage_reap(stage), "")



func _on_award(info: Dictionary) -> void :
	if not is_visible_in_tree() or client.award_op in [1, 7, 13, 14, 15, 19, 26, 27, 29, 30]:
		return
	if client.award_op == 9 and _btb_eat():
		return
	if client.award_show == 0 or client.award_op == 8:
		info = info.duplicate()
		info["fly"] = true
	if _playing and not _direct:
		_kept.append(info)
		return
	if _playing:
		client.roulette_list(_kind_w)
	_show_award(info)

func _show_kept() -> void :
	var kept: Array = _kept
	_kept = []
	for info: Dictionary in kept:
		_show_award(info)

func _show_award(info: Dictionary) -> void :
	var lines: Array = BagModel.award_lines(info, pack.bag)
	if not RewardPopup.has_rewards(info):
		return
	_note = ""
	if bool(info.get("fly", false)):
		_a18_fly(info)
		return
	_reward.begin(self, info)
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
	if not is_visible_in_tree() or stage < STAGE_FROM or stage > STAGE_TO:
		return
	match result:
		0:
			_note = "Đã nhận rương mốc."
			_note_at = _time + 1.2
		1:
			say("Rương này đã nhận rồi.")
		_:
			say("Chưa đủ lượt quay để mở rương này.")

func _on_prize(award: int, ok: bool) -> void :
	if not is_visible_in_tree():
		return
	_note = ""
	if ok:
		say("Đã gửi quà vào Thư.")
		if _sheet_id == "code" and int(_code_row.get("id", 0)) == award:
			_sheet_id = ""
			_code.text = ""
	elif award != CODE_AWARD:
		_note = "Chưa nhận được quà này."
		_note_at = _time + 0.6
	_fetch("user")

func _send(sent: bool, wait_note: String) -> void :
	if not sent:
		say("Chưa gửi được, hãy thử lại.")
		return
	_sent_at = _time
	_note = wait_note
	_note_at = _time + 2.0

func _ready_to_send() -> bool:
	return _time - _sent_at >= 1.0

func _tick(_delta: float) -> void :
	_tick_award()
	if not _note.is_empty() and _time >= _note_at:
		say(_note)
		_note = ""
	if _time - _counted_at > 0.25:
		_recount()
	_retry_failed()
	if _stale and not pack.bag.is_empty() and not pack.garage.is_empty() and not _convert_raw.is_empty():
		_stale = false
		_build_converts()
	if _want_item > 0 and not _stale:
		_show_item_page(_want_item)
	if _kind() == "wheel":
		_spin_tick()
		if _time - _rank_at >= RANK_EVERY:
			_rank_at = _time
			_fetch("rank")




func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0, tint: Color = Color.WHITE) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false, tint)

func _gift_art(gift: Dictionary) -> Texture2D:
	var path: String = str(gift.get("art", ""))
	return pack.picture(path) if not path.is_empty() else null


func _turned(cell: String, pivot: Vector2, offset: Vector2, angle: float, size_px: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> void :
	draw_set_transform(pivot * _f, deg_to_rad(angle), Vector2.ONE)
	_fblit(cell, offset, size_px.x, size_px.y, tint)
	draw_set_transform_matrix(Transform2D.IDENTITY)


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

func _can_peek(rect: Rect2, id: String) -> bool:
	if not _tip_ok() or not _sheet_id.is_empty():
		return false
	if not rect.has_point(get_local_mouse_position()):
		return false
	return _hover == "panel" or ( not id.is_empty() and _hover == id)


func _peek_item(rect: Rect2, gift: Dictionary, id: String = "") -> void :
	if not gift.is_empty() and _can_peek(rect, id):
		var helper: Dictionary = _helper_rec(gift)
		if not helper.is_empty():
			_tip = [rect, "", "", Color.WHITE, {}, helper]
			return
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


func _helper_rec(gift: Dictionary) -> Dictionary:
	var id: int = int(gift.get("id", 0))
	if str(gift.get("kind", "item")) != "item" or id <= 0 or pack == null:
		return {}
	pack.load_helper()
	pack.load_bag()
	return HelperModel.record({"m_templateId": id, "m_level": 1}, pack.helper, pack.bag, "")


func _gift_rec(gift: Dictionary) -> Dictionary:
	var id: int = int(gift.get("id", 0))
	if str(gift.get("kind", "item")) != "item" or id <= 0 or pack == null:
		return {}
	pack.load_bag()
	var extra: Dictionary = {}
	if not (pack.bag.get("items", {}) as Dictionary).has(str(id)):

		var desc: String = str(gift.get("desc", ""))
		if desc.is_empty():
			pack.load_helper()
			desc = HelperTip.description({"item": id}, pack.helper)
		extra = {"name": str(gift.get("name", "")), "quality": int(gift.get("quality", 0)), "desc": desc}
		if not str(gift.get("art", "")).is_empty() and not str(gift.art).begins_with("l/t/"):
			extra["art"] = str(gift.art)
			extra["icon"] = str(gift.art)
	return FlashTip.simulate(id, pack.bag, extra)

func _draw_tip() -> void :
	if _tip.size() == 6:
		FlashTip.show(self, [], _ctip)
		var more: Dictionary = pack.bag.get("more", {})
		HelperTip.show(self, _f, Vector2(_fw, _fh), get_local_mouse_position() / _f, client, pack.helper, more, _tip[5], HelperTip.context(client, _tip[5], more), false, pack.picture)
		return

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


func _gifts(rewards: Variant) -> Array:
	var out: Array = []
	if rewards is Array:
		for reward: Variant in rewards:
			if not (reward is Array) or (reward as Array).size() < 2:
				continue
			if int(reward[0]) == 0 and (reward as Array).size() >= 3:
				out.append(_coin(int(reward[1]), int(reward[2])))
			elif int(reward[0]) > 0:
				out.append(_item(int(reward[0]), int(reward[1])))
	return out


func _put(edit: LineEdit, rect: Rect2, px: float, align: String, editable: bool = true) -> void :
	_fput(edit, rect, px, align, editable)
	_placed.append(edit)

func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(AtlasV.FILE, AtlasV.R)
		_use(AtlasC.FILE, AtlasC.R)
		_use(AtlasP.FILE, AtlasP.R)
		_use(Arena.FILE, Arena.R)
		_a18_use()
	_tip = []
	_placed = []
	var kind: String = _kind()
	var box: Vector2 = SIZES[kind]
	var base: Vector2 = _centre(box.x, box.y)
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_hit("panel", Rect2(base * _f, box * _f), false)
	match kind:
		"wheel":
			_draw_wheel(base)
		"convert":
			_draw_convert(base)
		"prize":
			_draw_prize(base)
		_:
			_draw_center(base)
	match _sheet_id:
		"award":
			_draw_award()
		"confirm":
			_draw_confirm(true)
		"swap":
			_draw_confirm(false)
			_draw_swap()
		"code":
			_draw_code()
		_:
			_draw_tip()
	_a18_draw_flies()
	for edit: LineEdit in [_buy, _qty, _code]:
		if edit != null and edit.visible and not edit in _placed:
			edit.visible = false
			edit.release_focus()



func _draw_wheel(base: Vector2) -> void :
	var vip: bool = _kind_w == 3
	var panels: Dictionary = (AtlasV.PANELS if vip else Atlas.PANELS)["dial"]
	_fblit("fa_vdial_l" if vip else "fa_dial_l", base + _v(panels["l"]))
	_fblit("fa_vdial_r" if vip else "fa_dial_r", base + _v(panels["r"]))
	var dial: Dictionary = Atlas.DIAL
	var plate: Vector2 = base + _v(dial["plate"])
	_fblit("fa_vplate" if vip else "fa_plate", plate)
	var wedge_pivot: Vector2 = plate + _v(dial["wedge_pivot"])
	_turned("fa_vwedge" if vip else "fa_wedge", wedge_pivot, _v(dial["wedge"]) - _v(dial["wedge_pivot"]), _last_index * 36.0)
	_draw_dial_items(base)
	var pivot: Vector2 = base + _v(dial["pivot"])
	var arrow: Array = dial["imgArrow"]
	_turned("fa_arrow", pivot, Vector2(float(arrow[0]), float(arrow[1])) - _v(dial["pivot"]), _rot)
	_draw_ball(base)
	_btb_draw(base)
	var toggle: Array = dial["btnVIP"]
	var toggle_cell: String = "fa_to_normal" if vip else "fa_to_vip"
	if _playing:
		_fblit(toggle_cell, base + Vector2(float(toggle[0]), float(toggle[1])), 0.0, 0.0, Color(0.6, 0.6, 0.6, 1.0))
	else:
		_fbutton("normal" if vip else "vip", toggle_cell, base + Vector2(float(toggle[0]), float(toggle[1])))
	_a18_tips(base, vip)
	_draw_count(base)
	var count_text: Array = dial["count_text"]
	_fwords(str(_balls()), BOLD, 14.0, Color(AtlasV.COUNT_TEXT) if vip else Color.WHITE, "r", base + Vector2(float(count_text[0]), float(count_text[1])), 
		float(count_text[2]) - 4.0, 0.0, float(count_text[3]))
	_fbutton("buy", "fa_buy", base + _v(dial["buy"]))
	var refresh: Array = dial["_DialFrame_Label2"]
	_fwords(T_REFRESH, BOLD, 12.0, Color("34d54b"), "r", base + Vector2(float(refresh[0]) - 200.0, float(refresh[1])), 200.0)
	if vip:
		var cost_label: Array = dial["_DialFrame_Label1"]
		_fwords(T_VIP_COST, BOLD, 12.0, Color("ffa800"), "l", base + Vector2(float(cost_label[0]), float(cost_label[1])), 300.0)
	_draw_alms(base)
	_draw_lists(base)
	var close: Array = dial["btnClose"]
	if _playing and not _btb_on:
		_fblit("fa_close", base + Vector2(float(close[0]), float(close[1])), 0.0, 0.0, Color(0.6, 0.6, 0.6, 1.0))
	else:
		_fbutton("close", "fa_close", base + Vector2(float(close[0]), float(close[1])))


func _draw_dial_items(base: Vector2) -> void :
	var rows: Array = _wheel_rows()
	var spots: Array = Atlas.ITEMS["at"]
	var icon: Array = Atlas.ITEMS["icon"]
	var label: Array = Atlas.ITEMS["lblItemName"]
	for i: int in mini(rows.size(), spots.size()):
		var row: Array = rows[i]
		var gift: Dictionary = _wheel_item(row)
		if gift.is_empty():
			continue
		var at: Vector2 = base + _v(spots[i])
		var box: Rect2 = Rect2(at + Vector2(float(icon[0]), float(icon[1])), Vector2(float(icon[2]), float(icon[3])))
		var special: int = int(Atlas.SPECIAL.get(str(int(row[0])), 0))
		if special == 2:
			_a18_rays(at)
		_fit(_gift_art(gift), box.position, box.size, 1.0)
		var title: String = GarageModel.cap(str(gift.name)) + ("  x%d" % int(gift.count) if int(gift.count) > 1 else "")
		_fwords(title, BOLD, 12.0, Color("ffff00") if special >= 1 else Color.WHITE, "c", at + Vector2(float(label[0]), float(label[1])), 
			float(label[2]), 0.0, float(label[3]))
		_peek_item(Rect2(box.position * _f, box.size * _f), gift)


func _draw_ball(base: Vector2) -> void :
	var at: Vector2 = base + _v(Atlas.DIAL["ball"])
	var word: Vector2 = base + _v(Atlas.DIAL["word"])
	if not _playing:
		var rect: Rect2 = _fblit("fa_ball", at, 0.0, 0.0, _glow("start"))
		_hit("start", rect, false)
		_fblit("fa_start", word - _cell_size("fa_start") / 2.0, 0.0, 0.0, _glow("start"))
	elif _stop_on:
		var rect: Rect2 = _fblit("fa_ball", at, 0.0, 0.0, _glow("stop"))
		_hit("stop", rect, false)
		_fblit("fa_stop", word - _cell_size("fa_stop") / 2.0, 0.0, 0.0, _glow("stop"))
	else:
		_fblit("fa_ball_off", at)


func _draw_count(base: Vector2) -> void :
	var dial: Dictionary = Atlas.DIAL

	var pill: Array = dial["cimagechecklocal4"]
	_fblit("fa_vpill" if _kind_w == 3 else "fa_pill", base + Vector2(float(pill[0]), float(pill[1])))
	var dec: Array = dial["btnReduceNum"]
	var add: Array = dial["btnAddNum"]
	var tint: Color = Color(0.6, 0.6, 0.6, 1.0)
	if _playing:
		_fblit("fa_dec", base + Vector2(float(dec[0]), float(dec[1])), 0.0, 0.0, tint)
		_fblit("fa_add", base + Vector2(float(add[0]), float(add[1])), 0.0, 0.0, tint)
	else:
		_fbutton("dec", "fa_dec", base + Vector2(float(dec[0]), float(dec[1])))
		_fbutton("add", "fa_add", base + Vector2(float(add[0]), float(add[1])))
	var field: Array = dial["txtBuyNum"]
	var rect: Rect2 = Rect2(base + Vector2(float(field[0]), float(field[1])), Vector2(float(field[2]), float(field[3])))
	if _sheet_id.is_empty():
		_put(_buy, rect, 20.0, "c", not _playing)
	else:
		_fwords(_buy.text, BOLD, 20.0, OK_GOLD, "c", rect.position, rect.size.x, 0.0, rect.size.y)


func _draw_alms(base: Vector2) -> void :
	var alms: Dictionary = Atlas.ALMS
	var vip: bool = _kind_w == 3
	var bar: Vector2 = base + _v(alms["bar"])
	_fblit("fa_vline_bg" if vip else "fa_line_bg", bar)
	var fill: String = "fa_vline_fill" if vip else "fa_line_fill"
	var full: Vector2 = _cell_size(fill)
	var shown: float = roundf(full.x * _progress() / 100.0)
	if shown > 0.0:
		_fpart(fill, bar + _v(alms["fill"]), Rect2(0, 0, shown, full.y))
	var spins: Array = Atlas.DIAL["_DialFrame_Label3"]
	_fwords(str(_spins()), BOLD, 12.0, Color.WHITE, "c", base + Vector2(float(spins[0]), float(spins[1])), float(spins[2]))
	var stages: Array = pack.fair.get("stages", [])
	var xs: Array = alms["x"]
	for i: int in mini(stages.size(), xs.size()):
		var row: Array = stages[i]
		var at: Vector2 = base + Vector2(float(xs[i]), float(alms["y"]))
		var state: int = _gift_state(int(row[0]), int(row[1]))
		_fblit("fa_gift_shadow", at + _v(alms["shadow"]))
		var scale: float = float(alms["scale"][i])
		var side: Vector2 = _cell_size("fa_gift%d" % (i + 1)) * scale
		var lit: float = 1.0 + (0.35 * _pulse() if state == 1 else 0.0)
		var gift_rect: Rect2 = _fblit("fa_gift%d" % (i + 1), at + _v(alms["centre"]) - side / 2.0, side.x, side.y, Color(lit, lit, lit * 0.9, 1.0))
		if state == 2:
			_fblit("fa_stamp", at + _v(alms["stamp"]))
		_fblit("fa_gift_tip", at + _v(alms["tip"]))
		var need: Array = alms["lblRequestCount"]
		_fwords(str(int(row[1])), BOLD, 12.0, Color("ff0000"), "c", at + Vector2(float(need[0]) - 30.0, float(need[1])), 60.0)
		var spot: Rect2 = Rect2(at * _f, Vector2(80, 90) * _f)
		_hit("gift:%d" % i, spot, false)
		_peek_gifts(gift_rect.merge(Rect2((at + Vector2(0, 60)) * _f, Vector2(80, 30) * _f)), "Rương %d lượt" % int(row[1]), 
			_gifts(row[2] if row.size() > 2 else []), "gift:%d" % i)


func _draw_lists(base: Vector2) -> void :
	var lists: Dictionary = Atlas.LISTS
	var rank: Array = lists["rank"]
	var first: int = _rank_page * LIST_ROWS
	for r: int in range(first, mini(first + LIST_ROWS, _rank_rows.size())):
		var y: float = float(rank[1]) + (r - first) * float(rank[4])
		var at: Vector2 = base + Vector2(float(rank[0]), y)
		_fwords(str(_rank_rows[r][0]), BOLD, 12.0, Color.WHITE, "c", at + Vector2(float(lists["rank_name"][0]), 0), float(lists["rank_name"][2]), 0.0, float(rank[4]))
		_fwords(str(_rank_rows[r][1]), BOLD, 12.0, Color.WHITE, "c", at + Vector2(float(lists["rank_value"][0]), 0), float(lists["rank_value"][2]), 0.0, float(rank[4]))
		_fblit("fa_cut", at + _v(lists["cut"]), float(rank[2]), 0.0)
	_draw_pager(base, _pages(_rank_rows.size(), LIST_ROWS), _rank_page)
	var award: Array = lists["award"]
	var rows: Array = _roll_rows.get(_kind_w, [])
	var shown: int = 0
	for k: int in range(rows.size() - 1, -1, -1):
		if shown >= LIST_ROWS:
			break
		var row: Variant = rows[k]
		if not (row is Array) or (row as Array).size() < 3:
			continue
		var at: Vector2 = base + Vector2(float(award[0]), float(award[1]) + shown * float(award[4]))
		shown += 1
		var slot: Array = _roll_slot(int(row[1]))
		var what: String = ""
		if slot.size() >= 3:
			what = GarageModel.cap(str(_item(int(slot[1]), 1).name)) + "  x%d" % int(row[2])
		_fwords(BagModel.clean(str(row[0])), BOLD, 12.0, Color.WHITE, "c", at + Vector2(float(lists["award_name"][0]), 0), float(lists["award_name"][2]), 0.0, float(award[4]))
		_fwords(what, BOLD, 12.0, Color.WHITE, "c", at + Vector2(float(lists["award_value"][0]), 0), float(lists["award_value"][2]), 0.0, float(award[4]))
		_fblit("fa_cut", at + _v(lists["cut"]), float(award[2]), 0.0)



func _draw_pager(base: Vector2, count: int, page: int, frame: Array = [], prefix: String = "rank") -> void :
	var pager: Dictionary = Atlas.PAGER
	var spot: Array = frame if not frame.is_empty() else pager["at"]
	var shown: int = mini(count, PAGE_MAX)
	var start: int = _page_window(int(_page_start.get(prefix, 0)), count, page)
	_page_start[prefix] = start
	var wide: float = shown * float(pager["step"]) + 60.0
	var at: Vector2 = base + Vector2(float(spot[0]) + (float(spot[2]) - wide) / 2.0, float(spot[1]))
	_fbutton(prefix + "_prev", "fa_pg_last", at)
	_fbutton(prefix + "_next", "fa_pg_next", at + Vector2(wide - 19.0, 0))
	for i: int in shown:
		var dot: Vector2 = at + Vector2(float(pager["first"]) + float(pager["step"]) * i, float(pager["dot_y"]))
		var n: int = start + i
		var id: String = "%s_page:%d" % [prefix, n]
		var rect: Rect2 = _fblit("fa_pg_on" if n == page else "fa_pg_dot", dot, 0.0, 0.0, _glow(id))
		_hit(id, rect, false)
		_fwords(str(n + 1), BOLD, 12.0, PAGE_BLUE if n == page else Color.BLACK, "c", dot, 24.0, 0.0, 25.0, true, Color(0, 0, 0, 0))


static func _page_window(start: int, count: int, page: int) -> int:
	var shown: int = mini(count, PAGE_MAX)
	if shown <= 0:
		return 0
	start = clampi(start, 0, count - shown)
	if page < start:
		return maxi(0, page)
	if page >= start + shown:
		return page - shown + 1
	return start




func _build_converts() -> void :
	_converts = []
	var names: Dictionary = pack.lobby.get("tanks", {})
	var defaults: Dictionary = pack.index.get("tanks", {})
	var skins: Dictionary = pack.garage.get("skin_items", {})
	var now: int = _now()
	for row: Dictionary in _convert_raw:
		var type: int = int(row.get("nType", "0"))
		var result: int = int(row.get("nNewItemId", "0"))
		if not type in CONVERT_TYPES or result <= 0:
			continue
		var end: int = _when(str(row.get("szEnd", "")))
		if end > 0 and end < now:
			continue
		var gt: int = 6 if skins.has(str(result)) else (2 if names.has(str(result)) else 4)
		var rec: Dictionary = {"tid": result, "gt": gt}
		if not ShopModel.describe(rec, pack.bag, pack.garage, names, defaults):
			continue
		var gift: Dictionary = _item(result, maxi(1, int(row.get("nNewItemCount", "1"))))
		if not str(rec.name).is_empty():
			gift.name = str(rec.name)
		var picture: String = str(rec.face) if not str(rec.face).is_empty() else str(rec.icon)
		if not picture.is_empty():
			gift.art = picture
		gift.quality = maxi(int(gift.quality), int(rec.quality))
		if str(gift.desc).is_empty():
			gift.desc = str(rec.desc)
		var items: Array = []
		for slot: int in range(1, 6):
			items.append([int(row.get("nItemId%d" % slot, "0")), int(row.get("iCount%d" % slot, "0"))])
		_converts.append({"id": int(row.get("nId", "0")), "type": type, "items": items, "ct": int(row.get("nCoinType", "0")), 
			"price": int(row.get("iPrice", "0")), "gift": gift, "gt": gt, "max": int(row.get("nConvertMax", "0")), 
			"heft": int(row.get("nHeft", "0")), "begin": _when(str(row.get("szBegin", ""))), "end": end})
	_converts.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.heft) > int(b.heft) if int(a.heft) != int(b.heft) else int(a.id) < int(b.id))
	_convert_page = clampi(_convert_page, 0, _pages(_shown_converts().size(), _per_page()) - 1)


func _when(text: String) -> int:
	var value: String = text.strip_edges()
	return 0 if value.is_empty() or value == "0" else _stamp(value)


func _show_item_page(item: int) -> void :
	_want_item = 0
	var type: int = 0
	for row: Dictionary in _convert_raw:
		if int(row.get("nNewItemId", "0")) == item and int(row.get("nType", "0")) in CONVERT_TYPES:
			type = int(row.get("nType", "0"))
			break
	if type == 0:
		return
	_sort = CONVERT_TYPES.find(type)
	_convert_page = 0
	_glow_at = -1
	if type == ACT_TYPE:
		return
	var rows: Array = _shown_converts()
	for k: int in rows.size():
		if int(rows[k].gift.id) == item:
			_convert_page = floori(float(k) / float(_per_page()))
			_glow_at = k
			break

func _sort_type() -> int:
	return int(CONVERT_TYPES[_sort])

func _per_page() -> int:
	return 4 if _sort_type() == ACT_TYPE else 6

func _shown_converts() -> Array:
	var type: int = _sort_type()
	return _converts.filter( func(rec: Dictionary) -> bool: return int(rec.type) == type)


func _wallet(ct: int) -> int:
	if ct == 3:
		return ShopModel.balance(client.currency, 1) + ShopModel.balance(client.currency, 3)
	return ShopModel.balance(client.currency, ct)

func _owned_skin(rec: Dictionary) -> bool:
	return int(rec.gt) == 6 and ShopModel.owned({"gt": 6, "tid": rec.gift.id}, client.tanks, client.bags) > 0


func _enough(rec: Dictionary) -> bool:
	if int(rec.price) > 0 and _wallet(int(rec.ct)) < int(rec.price):
		return false
	var last: int = 4 if int(rec.type) == ACT_TYPE else 3
	for k: int in last:
		var pair: Array = rec.items[k]
		if int(pair[0]) != 0 and _have(int(pair[0])) < int(pair[1]):
			return false
	return true


func _most(rec: Dictionary) -> int:
	var most: int = 99999999
	if int(rec.price) > 0:
		most = _wallet(int(rec.ct)) / int(rec.price)
	for pair: Array in rec.items:
		if int(pair[1]) > 0:
			most = mini(most, _have(int(pair[0])) / int(pair[1]))
	if int(rec.gt) == 6:
		most = mini(most, 1)
	elif int(rec.max) != 0:
		most = mini(most, int(rec.max))
	return maxi(0, most)


func _convert_button(rec: Dictionary) -> Array:
	if int(rec.type) == ACT_TYPE:
		var now: int = _now()
		if (int(rec.begin) > 0 and int(rec.begin) > now) or (int(rec.end) > 0 and int(rec.end) < now):
			return [false, false]
		return [true, _enough(rec)]
	return [true, _enough(rec) and not _owned_skin(rec)]

func _open_confirm(rec: Dictionary) -> void :
	_pick = rec
	_amount = _most(rec)
	_qty.text = str(_amount)
	_sheet_id = "confirm"
	_tip = []

func _on_qty_input() -> void :
	if _pick.is_empty():
		return
	var typed: String = _qty.text.strip_edges()
	var most: int = _most(_pick)
	var value: int = clampi(int(typed) if typed.is_valid_int() else 1, 1, maxi(1, most))
	_amount = value
	if typed != str(value):
		_qty.text = str(value)
		_qty.caret_column = _qty.text.length()

func _step_qty(step: int) -> void :
	var most: int = _most(_pick)
	if (step < 0 and _amount <= 1) or (step > 0 and _amount >= most):
		return
	_amount += step
	_qty.text = str(_amount)


func _confirm_convert() -> void :
	if _pick.is_empty():
		return
	if _amount < 1:
		_close_sheet()
		return
	if int(_pick.ct) == 3 and int(_pick.price) > 0:
		var total: int = int(_pick.price) * _amount
		if ShopModel.balance(client.currency, 3) < total:
			_sheet_id = "swap"
			return
	_send_convert()

func _send_convert() -> void :
	var rec: Dictionary = _pick
	var amount: int = _amount
	_close_sheet()
	if not _ready_to_send():
		return
	_send(client.convert_item(int(rec.id), amount), "Chưa đổi được: thiếu nguyên liệu, thiếu Xu hoặc đã có skin này.")

func _close_sheet() -> void :
	if _sheet_id == "award" and _reward.request_close(self):
		return
	_sheet_id = ""
	_pick = {}
	_code_row = {}
	_award = []
	_hide_edits()



func _draw_convert(base: Vector2) -> void :
	var layout: Dictionary = AtlasC.CONVERT
	_fblit("fa_cv_frame", base + _v(layout["frame"]))
	for k: int in CONVERT_TYPES.size():
		var spot: Array = layout["tabs"][k]
		var at: Vector2 = base + Vector2(float(spot[1]), float(layout["tab_y"]))
		var on: bool = k == _sort
		var id: String = "sort:%d" % k
		var rect: Rect2 = _fblit("fa_tab_on" if on else "fa_tab", at, 0.0, 0.0, Color.WHITE if on else _glow(id))
		_hit(id, rect, false)
		var label: String = "fa_ti_%d" % int(spot[0])
		_fblit(label, at + (_cell_size("fa_tab") - _cell_size(label)) / 2.0)
	var rows: Array = _shown_converts()
	var act: bool = _sort_type() == ACT_TYPE
	var cells: Array = layout["act_cells"] if act else layout["cells"]
	var per: int = _per_page()
	var first: int = _convert_page * per
	for k: int in range(first, mini(first + per, rows.size())):
		var at: Vector2 = base + _v(cells[k - first])
		if act:
			_draw_act_cell(at, rows[k], k)
		else:
			_draw_cell(at, rows[k], k)
	var pager: Array = layout["pager"]
	_draw_pager(base, _pages(rows.size(), per), _convert_page, pager, "cv")
	_fbutton("close", "fa_close", base + _v(layout["close"]))


func _draw_cell(at: Vector2, rec: Dictionary, index: int) -> void :
	_fblit("fa_cv_cell", at)
	if index == _glow_at:
		_round(Rect2((at + Vector2(1, 1)) * _f, Vector2(378, 114) * _f), Color(0, 0, 0, 0), 12.0, Color("ffff00"), 8.0)
	var tiles: Array = AtlasC.CELL["tiles"]
	var slot: int = 0
	if int(rec.price) > 0:
		var coin: Dictionary = _coin(ShopModel.coin_index(int(rec.ct)), int(rec.price))
		_draw_tile(at + _v(tiles[0]), coin, str(int(rec.price)), Color.WHITE if _wallet(int(rec.ct)) >= int(rec.price) else SHORT_RED, false, "cv_tile:%d:0" % index)
		slot += 1
	for k: int in 3:
		var pair: Array = rec.items[k]
		if int(pair[0]) != 0 and slot < tiles.size():
			var have: int = _have(int(pair[0]))
			_draw_tile(at + _v(tiles[slot]), _item(int(pair[0]), int(pair[1])), "%d/%d" % [have, int(pair[1])], Color.WHITE, have < int(pair[1]), 
				"cv_tile:%d:%d" % [index, slot])
		slot += 1
	_draw_reward(at + _v(AtlasC.CELL["reward"]), rec.gift, true, "cv_gift:%d" % index)
	_draw_convert_button(at + _v(AtlasC.CELL["button"]), rec, index)
	_a18_buy_hit(at, rec)


func _draw_act_cell(at: Vector2, rec: Dictionary, index: int) -> void :
	_fblit("fa_cv_act", at)
	var positive: int = 1 if int(rec.price) > 0 else 0
	for pair: Array in rec.items:
		if int(pair[1]) > 0:
			positive += 1
	var spots: Array = (AtlasC.ACT_CELL["four"] + [AtlasC.ACT_CELL["four"][0]]) if positive > 2 else AtlasC.ACT_CELL["two"]
	var slot: int = 0
	if int(rec.price) > 0:
		if int(rec.items[3][1]) <= 0 and slot < spots.size():
			var coin: Dictionary = _coin(ShopModel.coin_index(int(rec.ct)), int(rec.price))
			_draw_tile(at + _v(spots[slot]), coin, str(int(rec.price)), Color.WHITE if _wallet(int(rec.ct)) >= int(rec.price) else SHORT_RED, false, 
				"cv_tile:%d:0" % index)
		slot += 1
	for k: int in 4:
		var pair: Array = rec.items[k]
		if int(pair[0]) != 0 and slot < spots.size():
			_draw_tile(at + _v(spots[slot]), _item(int(pair[0]), int(pair[1])), "%d/%d" % [_have(int(pair[0])), int(pair[1])], Color.WHITE, false, 
				"cv_tile:%d:%d" % [index, slot])
		slot += 1
	_draw_reward(at + _v(AtlasC.ACT_CELL["reward"]), rec.gift, false, "cv_gift:%d" % index)
	_draw_convert_button(at + _v(AtlasC.ACT_CELL["button"]), rec, index)


func _draw_tile(at: Vector2, gift: Dictionary, number: String, color: Color, short: bool, id: String) -> void :
	var rect: Rect2 = _fblit("fa_cv_tile", at + Vector2(4, 0))
	var quality: int = int(gift.get("quality", 1))
	if quality >= 2 and quality <= 5:
		_fblit("fa_iq%d" % quality, at + Vector2(10, 6))
	_fit(_gift_art(gift), at + Vector2(12, 10), Vector2(52, 49), 1.0)
	_fwords(number, BOLD, 12.0, color, "c", at + Vector2(-5, 63), 85.0)
	if short:
		_fblit("fa_cv_tip", at + Vector2(54, 1))
	_peek_item(rect, gift, id)


func _draw_reward(at: Vector2, gift: Dictionary, count: bool, id: String) -> void :
	var rect: Rect2 = _fblit("fa_cv_reward", at)
	_fit(_gift_art(gift), at + Vector2(4, 4), Vector2(76, 76), 1.0)
	if count and int(gift.count) > 1:
		_fwords(str(int(gift.count)), BOLD, 12.0, Color.WHITE, "r", at + Vector2(7, 59), 70.0)
	_reward_name(GarageModel.cap(str(gift.name)), BagModel.tint(int(gift.quality), Color.WHITE), at)
	_peek_item(rect, gift, id)



const NAME_WIDE: float = 104.0
func _reward_name(text: String, color: Color, at: Vector2) -> void :
	var font: Font = _face(BOLD)
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(10.0 * _f))).x <= NAME_WIDE * _f:
		_fwords(text, BOLD, 12.0, color, "c", at + Vector2(42.0 - NAME_WIDE / 2.0, 79), NAME_WIDE)
		return
	var cut: int = text.find(" (")
	if cut <= 0:
		cut = text.rfind(" ", text.length() / 2 + 4)
	if cut <= 0:
		_fwords(text, BOLD, 12.0, color, "c", at + Vector2(42.0 - NAME_WIDE / 2.0, 79), NAME_WIDE)
		return
	_fwords(text.left(cut).strip_edges(), BOLD, 11.0, color, "c", at + Vector2(42.0 - NAME_WIDE / 2.0, 73), NAME_WIDE)
	_fwords(text.substr(cut).strip_edges(), BOLD, 11.0, color, "c", at + Vector2(42.0 - NAME_WIDE / 2.0, 87), NAME_WIDE)

func _draw_convert_button(at: Vector2, rec: Dictionary, index: int) -> void :
	var state: Array = _convert_button(rec)
	if not bool(state[0]):
		return
	if bool(state[1]):
		_fbutton("cv_do:%d" % index, "fa_cv_btn", at)
	else:
		_fblit("fa_cv_btn_off", at)


func _draw_confirm(live: bool) -> void :
	if _pick.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	var box: Vector2 = Vector2(358, 300)
	var at: Vector2 = _centre(box.x, box.y)
	var layout: Dictionary = AtlasC.CONFIRM
	if live:
		_hit("shade", Rect2(Vector2.ZERO, size), false)
		_hit("panel", Rect2(at * _f, box * _f), false)
	_fblit("fa_cc_frame", at + _v(layout["frame"]))
	var dec: Array = layout["btnDec"]
	var add: Array = layout["btnAdd"]
	if live:
		_fbutton("cc_close", "fa_cc_close", at + _v(layout["btnCancel"]))
		_fbutton("cc_dec", "fa_dec", at + Vector2(float(dec[0]), float(dec[1])))
		_fbutton("cc_add", "fa_add", at + Vector2(float(add[0]), float(add[1])))
		_fbutton("cc_ok", "fa_ok", at + _v(layout["btnConfirm"]))
	else:
		_fblit("fa_cc_close", at + _v(layout["btnCancel"]))
		_fblit("fa_dec", at + Vector2(float(dec[0]), float(dec[1])))
		_fblit("fa_add", at + Vector2(float(add[0]), float(add[1])))
		_fblit("fa_ok", at + _v(layout["btnConfirm"]))
	var field: Array = layout["txtBuyNum"]
	var rect: Rect2 = Rect2(at + Vector2(float(field[0]), float(field[1])), Vector2(float(field[2]), float(field[3])))
	if live:
		_put(_qty, rect, 20.0, "c")
	else:
		_fwords(str(_amount), BOLD, 20.0, OK_GOLD, "c", rect.position, rect.size.x, 0.0, rect.size.y)
	if int(_pick.price) > 0:
		var row: Array = layout["rows"]
		var line: Vector2 = at + Vector2(float(row[0]), float(row[1]))
		_fblit("fa_cc_row", line)
		_fit(pack.picture(_coin_art(ShopModel.coin_index(int(_pick.ct)))), line + _v(layout["icon"]), Vector2(22, 22), 1.0)
		var value: Array = layout["value"]
		_fwords(str(int(_pick.price) * _amount), BOLD, 14.0, Color.WHITE, "l", line + Vector2(float(layout["name"][0]), float(value[1])), 160.0, 0.0, 22.0)


func _draw_swap() -> void :
	var total: int = int(_pick.price) * _amount
	var lack: int = maxi(0, total - ShopModel.balance(client.currency, 3))
	var at: Vector2 = _window(358, 200, "swap_no")
	_fwords("Xác nhận", BOLD, 16.0, Color.WHITE, "c", at + Vector2(0, 18), 358.0, 1.0, 28.0)
	_fpara(T_SWAP % [lack, lack], BOLD, 14.0, Color.WHITE, at + Vector2(30, 66), 298.0, 4)
	_fbutton("swap_yes", "fa_ok", at + Vector2(119, 200 - 50))



var _focus_code: bool = false

func _marked(key: String, id: int) -> bool:
	return _user.get(key, {}).has(id)

func _prize_rows() -> Array:
	return _awards.filter( func(row: Dictionary) -> bool: return not _marked("hide", int(row.id)))


func _can_get(row: Dictionary) -> bool:
	var id: int = int(row.id)
	return _marked("ok", id) or (int(row.type) == ADT_VALID and _marked("ok_code", id))

func _draw_prize(base: Vector2) -> void :
	var layout: Dictionary = AtlasP.PRIZE
	_fblit("fa_pz_frame", base + _v(layout["frame"]))
	var rows: Array = _prize_rows()
	var total: int = _pages(rows.size(), PRIZE_PAGE)
	_prize_page = clampi(_prize_page, 0, total - 1)
	var first: int = _prize_page * PRIZE_PAGE
	for k: int in range(first, mini(first + PRIZE_PAGE, rows.size())):
		_draw_prize_row(base + _v(layout["rows"][k - first]), rows[k], k)
	if rows.is_empty() and _loading != "award" and not "award" in _queue:
		_fblit("fa_pz_none", base + _v(layout["imgNoAward"]))
	_fbutton("pz_prev", "fa_pz_last", base + _v(layout["btnLastPage"]))
	_fbutton("pz_next", "fa_pz_next", base + _v(layout["btnNextPage"]))
	var label: Array = layout["lblPage"]
	_fwords("%d/%d" % [_prize_page + 1, total], BOLD, 14.0, Color.WHITE, "c", base + Vector2(float(label[0]), float(label[1])), float(label[2]))
	_fbutton("close", "fa_close", base + _v(layout["btnClose"]))


func _draw_prize_row(at: Vector2, row: Dictionary, index: int) -> void :
	var layout: Dictionary = AtlasP.ROW
	_fblit("fa_pz_row", at + _v(layout["frame"]))
	var title: Array = layout["lblTitle"]
	_fwords(str(row.title), BOLD, 14.0, Color.WHITE, "l", at + Vector2(float(title[0]), float(title[1])), float(title[2]))
	var end: Array = layout["lblEndTime"]
	if int(row.end) > 0:
		_fwords(_date(int(row.end)), BOLD, 12.0, Color("ffff00"), "l", at + Vector2(float(end[0]), float(end[1])), float(end[2]))
	var desc: Array = layout["txtDesc"]
	_fpara(str(row.desc), REGULAR, 12.0, Color.WHITE, at + Vector2(float(desc[0]), float(desc[1])), float(desc[2]), 5)
	var spot: Vector2 = at + _v(layout["button"])
	if _marked("complete", int(row.id)):
		_fblit("fa_got", spot)
	elif int(row.type) == ADT_VALID:
		if _can_get(row):
			_fbutton("pz_code:%d" % index, "fa_code", spot)
		else:
			_fblit("fa_code", spot, 0.0, 0.0, Color(0.55, 0.55, 0.55, 1.0))
	elif _can_get(row):
		_fbutton("pz_get:%d" % index, "fa_get", spot)
	else:
		_fblit("fa_get_off", spot)

func _prize_get(index: int) -> void :
	var rows: Array = _prize_rows()
	if index < 0 or index >= rows.size() or not _can_get(rows[index]) or not _ready_to_send():
		return
	_send(client.draw_award(int(rows[index].id)), "")

func _open_code(index: int) -> void :
	var rows: Array = _prize_rows()
	if index < 0 or index >= rows.size() or not _can_get(rows[index]):
		return
	_code_row = rows[index]
	_code.text = ""
	_sheet_id = "code"
	_focus_code = true
	_tip = []


func _submit_code() -> void :
	if _code_row.is_empty() or _sheet_id != "code":
		return
	var text: String = _code.text.strip_edges()
	if text.is_empty():
		say("Hãy nhập mã quà tặng.")
		return
	if not _ready_to_send():
		return
	_send(client.draw_award(int(_code_row.id), text), "")


func _draw_code() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	var box: Vector2 = Vector2(358, 258)
	var at: Vector2 = _centre(box.x, box.y)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_hit("panel", Rect2(at * _f, box * _f), false)
	var layout: Dictionary = AtlasP.CODE
	_fblit("fa_iv_frame", at + _v(layout["frame"]))
	_fbutton("iv_close", "fa_x", at + _v(layout["btnCancel"]))
	var field: Array = layout["txtValidate"]
	var spot: Vector2 = at + Vector2(float(field[0]), float(field[1]))
	_fblit("fa_iv_input", spot)
	_put(_code, Rect2(spot + Vector2(8, 0), Vector2(float(field[2]) - 16.0, float(field[3]))), 16.0, "l")
	if _focus_code:
		_focus_code = false
		_code.call_deferred("grab_focus")
	_fbutton("iv_ok", "fa_iv_ok", at + _v(layout["btnConfirm"]))



const ACT_ROWS: int = 5
const AT_BOSS: int = 5
const SIGNS: Array = ["fa_sign_wait", "fa_sign_wait", "fa_sign_on", "fa_sign_over"]
const LOW_RED: Color = Color("ff4848")
const TIME_YELLOW: Color = Color("ffff00")


const AC_BAND: Rect2 = Rect2(280, 184, 490, 32)
const AC_BAND_MOVE: float = 477.0
const AC_CLEAN_ROW: float = 160.0
const AC_DESC_LINE: float = 17.0
const AC_VBOX_BOTTOM: float = 482.0

var _act_scroll: int = 0
var _act_rect: Rect2 = Rect2()
var _pull: float = 0.0


func _act_state(act: Dictionary) -> int:
	var info: Variant = client.acts.get(int(act.id))
	if not (info is Array and (info as Array).size() >= 3):
		return 3
	if int(act.type) == AT_BOSS:
		return clampi(int(info[2]), 0, 3)
	var start: int = int(info[0])
	var end: int = start + int(info[1])
	if start == 0 and end == 0:
		return 3
	var now: int = _now()
	if now >= end:
		return 3
	if now < start:
		return 1
	return 2


func _act_started(act: Dictionary) -> bool:
	var info: Variant = client.acts.get(int(act.id))
	if not (info is Array and (info as Array).size() >= 3):
		return false
	var now: int = _now()
	return now >= int(info[0]) and now < int(info[0]) + int(info[1])


func _act_index() -> int:
	if _acts.is_empty():
		return -1
	if act_want > 0:

		for k: int in _acts.size():
			if int(_acts[k].type) == act_want:
				_act_pick = k
				if k < _act_scroll or k >= _act_scroll + ACT_ROWS:
					_act_scroll = clampi(k, 0, maxi(0, _acts.size() - ACT_ROWS))
				break
		act_want = 0
	if _act_pick < 0 or _act_pick >= _acts.size():
		_act_pick = 0
		for k: int in _acts.size():
			if _act_started(_acts[k]):
				_act_pick = k
				break
	return _act_pick

func _scroll_acts(step: int) -> void :
	_act_scroll = clampi(_act_scroll + step, 0, maxi(0, _acts.size() - ACT_ROWS))


func _label(spec: Array, base: Vector2, text: String, wide: float, tint: Color) -> void :
	var at: Vector2 = base + Vector2(float(spec[0]), float(spec[1]))
	var align: String = str(spec[7])
	if float(spec[2]) > 0.0:
		wide = float(spec[2])
	elif align == "c":
		at.x -= wide / 2.0
	_fwords(text, BOLD if int(spec[6]) == 1 else REGULAR, float(spec[4]), tint, align, at, wide)

func _draw_center(base: Vector2) -> void :
	var layout: Dictionary = AtlasP.CENTER
	_fblit("fa_ac_frame", base + _v(layout["frame"]))
	var list: Array = layout["list"]
	var spot: Vector2 = base + Vector2(float(list[0]), float(list[1]))
	_act_rect = Rect2(spot * _f, Vector2(float(list[2]), float(list[3])) * _f)
	var pick: int = _act_index()
	if pick >= 0:
		_scroll_acts(0)
		var item: Dictionary = AtlasP.CENTER_ITEM
		var name_at: Array = item["lblActName"]
		for slot: int in mini(ACT_ROWS, _acts.size() - _act_scroll):
			var k: int = _act_scroll + slot
			var act: Dictionary = _acts[k]
			var at: Vector2 = spot + Vector2(0, float(list[4]) * slot)
			var id: String = "act:%d" % k
			var rect: Rect2 = _fblit("fa_ac_item_on" if k == pick else "fa_ac_item", at + _v(item["bg"]), 0.0, 0.0, Color.WHITE if k == pick else _glow(id))
			_hit(id, rect, false)
			_fblit(SIGNS[_act_state(act)], at + _v(item["state"]))
			_fwords(str(act.name), BOLD, 20.0, Color.WHITE, "c", at + Vector2(float(name_at[0]) - 80.0, float(name_at[1])), 160.0)
		if _acts.size() > ACT_ROWS:
			_draw_act_bar(spot + Vector2(186, 0), float(list[3]))
		_draw_act_detail(base, _acts[pick])
	_fbutton("close", "fa_close", base + _v(layout["btnClose"]))


func _draw_act_bar(at: Vector2, high: float) -> void :
	_round(Rect2(at * _f, Vector2(14, high) * _f), Color(0, 0.13, 0.27, 0.6), 7.0 * _f, Color(0, 0, 0, 0), 0.0)
	var rows: int = _acts.size()
	var thumb: float = maxf(30.0, high * ACT_ROWS / float(rows))
	var y: float = (high - thumb) * _act_scroll / float(maxi(1, rows - ACT_ROWS))
	_round(Rect2((at + Vector2(2, y)) * _f, Vector2(10, thumb) * _f), Color("4cb8ff", 0.85), 5.0 * _f, Color(0, 0, 0, 0), 0.0)
	var most: int = rows - ACT_ROWS
	_knob_hit("slide:act", Rect2((at + Vector2(0, y)) * _f, Vector2(14, thumb) * _f), _act_scroll, most, (high - thumb) * _f, 
		func(value: float) -> void : _act_scroll = clampi(roundi(value), 0, most))


func _draw_act_detail(base: Vector2, act: Dictionary) -> void :
	var layout: Dictionary = AtlasP.CENTER
	_label(layout["lblActName"], base, str(act.name), 380.0, Color("fff499"))
	var level: int = int(act.level)
	var joined: bool = _my_level() >= level
	_label(layout["lblStartLevel"], base, (T_LEVEL if joined else T_LOW) % level, 380.0, Color.WHITE if joined else LOW_RED)
	_label(layout["lblActTime"], base, str(act.time), 358.0, Color.WHITE)
	var desc: Array = layout["txtQuestDesc"]
	var reward: Array = layout["reward"]
	var lines: int = mini(_desc_lines(str(act.desc), float(desc[4]), float(desc[2])), _desc_room(float(reward[1])))
	var drop: float = desc_height(lines)
	_shift_award(base, layout, drop)
	if lines > 0:
		_fpara(str(act.desc), BOLD, float(desc[4]), Color.WHITE, base + Vector2(float(desc[0]), float(desc[1])), float(desc[2]), lines)
	var drops: Array = act.drops
	for k: int in drops.size():
		var at: Vector2 = base + Vector2(float(reward[0]) + 91.0 * (k % 5), float(reward[1]) + drop + 110.0 * floorf(k / 5.0))
		if at.y - base.y >= AC_VBOX_BOTTOM:
			break
		var gift: Dictionary = _item(int(drops[k]), 1)
		var rect: Rect2 = _fblit("fa_cv_reward", at + Vector2(3, 0))
		_fit(_gift_art(gift), at + Vector2(7, 4), Vector2(76, 76), 1.0)
		_peek_item(rect, gift)
	if _act_state(act) == 0:
		var info: Variant = client.acts.get(int(act.id))
		var rest: int = maxi(0, int(info[0]) - _now()) if info is Array else 0
		_label(layout["lblTimeCount"], base, T_COUNTDOWN % [int(rest / 3600.0), int((rest % 3600) / 60.0), rest % 60], 300.0, TIME_YELLOW)
	var go: Array = layout["btnGoTo"]
	var spot: Vector2 = base + Vector2(float(go[0]), float(go[1]))
	if _act_started(act):
		_fbutton("go", "fa_go", spot)
	else:
		_fblit("fa_go_off", spot)


func _desc_lines(text: String, px: float, wide: float) -> int:
	if text.strip_edges().is_empty():
		return 0
	var font: Font = _face(BOLD)
	var font_size: int = maxi(6, roundi(px * _f))
	var high: float = font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, wide * _f, font_size).y
	return maxi(1, roundi(high / maxf(1.0, font.get_height(font_size))))


func _desc_room(reward_y: float) -> int:
	return maxi(1, int((AC_VBOX_BOTTOM - 110.0 - reward_y - 2.0) / AC_DESC_LINE))


static func desc_height(lines: int) -> float:
	return 0.0 if lines <= 0 else AC_DESC_LINE * lines + 2.0



func _shift_award(base: Vector2, layout: Dictionary, drop: float) -> void :
	var cell: Array = _cells.get("fa_ac_frame", [])
	if drop <= 0.0 or cell.is_empty() or cell[0] == null:
		return
	var origin: Vector2 = Vector2(float(cell[1][0]), float(cell[1][1])) - _v(layout["frame"])
	draw_texture_rect_region(cell[0], Rect2((base + AC_BAND.position) * _f, AC_BAND.size * _f), 
		Rect2(origin + Vector2(AC_BAND.position.x, AC_CLEAN_ROW), Vector2(AC_BAND.size.x, 1.0)))
	var moved: Rect2 = Rect2(AC_BAND.position + Vector2(1, 0), Vector2(AC_BAND_MOVE, AC_BAND.size.y))
	draw_texture_rect_region(cell[0], Rect2((base + moved.position + Vector2(0, drop)) * _f, moved.size * _f), 
		Rect2(origin + moved.position, moved.size))



const AT_TEAM_MATCH: int = 1
const AT_TEAM_LEAGUE: int = 2
const AT_LADDER: int = 14
const AT_GUILD_MATCH: int = 30

const AT_VN_LUCK: int = 137



func _go() -> void :
	var pick: int = _act_index()
	if pick < 0:
		return
	var act: Dictionary = _acts[pick]
	if not _act_started(act):
		say(T_CLOSED)
		return
	if _my_level() < int(act.level):
		say(T_LOW % int(act.level))
		return
	var type: int = int(act.type)
	if type == 40:
		bonfire_asked.emit()
		return
	if type == ARENA_ACT:
		arena_asked.emit()
		return
	if not (client.EVENT_ROOMS.has(type) or type in [AT_BOSS, AT_TEAM_MATCH, AT_TEAM_LEAGUE, AT_LADDER, AT_GUILD_MATCH, AT_VN_LUCK]):
		say(SOON)
		return
	if client.state not in ["lobby", "hall"] or client.battle.active or not client.room_state.room.is_empty() or client.is_pairing():
		say(T_BUSY)
		return
	match type:
		AT_BOSS:
			closed.emit()
			page_asked.emit("boss")
		AT_TEAM_LEAGUE:
			closed.emit()
			page_asked.emit("league")
		AT_TEAM_MATCH:
			if _my_level() < int(client.TEAM_JOIN_LEVEL):
				say(T_LOW % int(client.TEAM_JOIN_LEVEL))
				return
			arena_asked.emit()
			client.hall_tab(client.TEAM_ROOM)
		AT_LADDER:
			arena_asked.emit()
		AT_GUILD_MATCH:
			closed.emit()
			page_asked.emit("territory")
		AT_VN_LUCK:
			closed.emit()
			luck_asked.emit()
		_:

			closed.emit()
			client.hall_room = int(client.EVENT_ROOMS[type])
			page_asked.emit("act")



func _draw_award() -> void :
	_reward.paint(self)



func _close() -> void :
	if _playing and not _btb_on:
		return
	_btb_abort()
	_close_sheet()
	closed.emit()

func _convert_do(index: int) -> void :
	var rows: Array = _shown_converts()
	if index < 0 or index >= rows.size():
		return
	var state: Array = _convert_button(rows[index])
	if state[0] and state[1]:
		_open_confirm(rows[index])

func _sheet_activate(id: String) -> void :
	match _sheet_id:
		"award":
			if id in ["ok", "shade"]:
				_close_sheet()
		"confirm":
			match id:
				"cc_close":
					_close_sheet()
				"cc_dec":
					_step_qty(-1)
				"cc_add":
					_step_qty(1)
				"cc_ok":
					_confirm_convert()
		"swap":
			match id:
				"swap_yes":
					_send_convert()
				"swap_no":
					_sheet_id = "confirm"
		"code":
			match id:
				"iv_close":
					_close_sheet()
				"iv_ok":
					_submit_code()

func _activate(id: String) -> void :
	if not _sheet_id.is_empty():
		_sheet_activate(id)
		return
	if id.begins_with("gift:"):
		_reap(int(id.substr(5)))
	elif id.begins_with("rank_page:"):
		_rank_page = clampi(int(id.substr(10)), 0, _pages(_rank_rows.size(), LIST_ROWS) - 1)
	elif id.begins_with("cv_page:"):
		_glow_at = -1
		_convert_page = clampi(int(id.substr(8)), 0, _pages(_shown_converts().size(), _per_page()) - 1)
	elif id.begins_with("sort:"):
		var k: int = clampi(int(id.substr(5)), 0, CONVERT_TYPES.size() - 1)
		if k != _sort:
			_sort = k
			_convert_page = 0
			_glow_at = -1
	elif id.begins_with("cv_do:"):
		_glow_at = -1
		_convert_do(int(id.substr(6)))
	elif id.begins_with("cv_buy:"):
		quick_buy_asked.emit(int(id.substr(7)))
	elif id.begins_with("pz_get:"):
		_prize_get(int(id.substr(7)))
	elif id.begins_with("pz_code:"):
		_open_code(int(id.substr(8)))
	elif id.begins_with("act:"):
		_act_pick = clampi(int(id.substr(4)), 0, maxi(0, _acts.size() - 1))
	else:
		match id:
			"start":
				_start()
			"stop":
				_stop_click()
			"add":
				_add_count(1)
			"dec":
				_add_count(-1)
			"vip":
				_switch_wheel(VIP_WHEEL)
			"normal":
				_switch_wheel(1)
			"buy":
				page_asked.emit("events:card")
			"rank_prev":
				_rank_page = maxi(0, _rank_page - 1)
			"rank_next":
				_rank_page = mini(_pages(_rank_rows.size(), LIST_ROWS) - 1, _rank_page + 1)
			"cv_prev":
				_glow_at = -1
				_convert_page = maxi(0, _convert_page - 1)
			"cv_next":
				_glow_at = -1
				_convert_page = mini(_pages(_shown_converts().size(), _per_page()) - 1, _convert_page + 1)
			"pz_prev":
				_prize_page = maxi(0, _prize_page - 1)
			"pz_next":
				_prize_page = mini(_pages(_prize_rows().size(), PRIZE_PAGE) - 1, _prize_page + 1)
			"go":
				_go()
			"close":
				_close()


func _wheel(step: int, at: Vector2) -> void :
	if not _sheet_id.is_empty() or _kind() != "center":
		return
	if _act_rect.has_point(at):
		_scroll_acts(step)


func _drag(moved: Vector2, from: Vector2) -> void :
	if not _sheet_id.is_empty() or _kind() != "center" or not _act_rect.has_point(from):
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, 77.0 * _f)
	while _pull >= pitch:
		_pull -= pitch
		_scroll_acts(1)
	while _pull <= - pitch:
		_pull += pitch
		_scroll_acts(-1)

func _input(event: InputEvent) -> void :
	if not is_visible_in_tree() or _sheet_id.is_empty() or not (event is InputEventKey and event.pressed) or event.echo:
		return
	match event.keycode:
		KEY_ESCAPE:
			if _sheet_id == "swap":
				_sheet_id = "confirm"
			else:
				_close_sheet()
		KEY_ENTER, KEY_KP_ENTER:
			match _sheet_id:
				"award":
					_close_sheet()
				"confirm":
					_confirm_convert()
				"swap":
					_send_convert()
				"code":
					_submit_code()
		_:
			return
	get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()



const AtlasS = preload("fairs_atlas.gd")
const QuestAtlas = preload("quest_atlas.gd")

signal quick_buy_asked(tid: int)

var _flies: Array = []
var _a18_masks: Dictionary = {}

func _a18_use() -> void :
	_use(AtlasS.FILE, AtlasS.R)
	var fly: Dictionary = {}
	for name: String in ["qu_fly_gold", "qu_fly_gift"]:
		if QuestAtlas.R.has(name):
			fly[name] = QuestAtlas.R[name]
	_use(QuestAtlas.FILE, fly)


static func can_buy(tid: int) -> bool:
	var ids: Array = AtlasS.CAN_BUY
	var at: int = ids.bsearch(tid)
	return at < ids.size() and int(ids[at]) == tid




func _a18_buy_hit(at: Vector2, rec: Dictionary) -> void :
	var tid: int = 0
	for k: int in 3:
		var id: int = int(rec.items[k][0])
		if id != 0 and can_buy(id):
			tid = id
	if tid != 0:
		_hit("cv_buy:%d" % tid, Rect2(at * _f, Vector2(80, 33) * _f), false)



func _a18_rays(at: Vector2) -> void :
	var effect: Dictionary = AtlasS.EFFECT
	var frames: Array = effect["frames"]
	var row: Array = frames[int(_time * float(effect["fps"])) % frames.size()]
	var box: Array = effect["box"]
	var k: float = float(box[2]) / float(effect["stage"][0])
	var pivot: Vector2 = at + Vector2(float(box[0]), float(box[1])) + Vector2(float(effect["center"][0]), float(effect["center"][1])) * k
	var side: float = float(effect["side"]) * float(effect["scale"]) * k
	for layer: Variant in row:
		if layer == null or float(layer[1]) <= 0.0:
			continue
		_turned("fa_rays", pivot, Vector2( - side, - side) / 2.0, float(layer[0]), Vector2(side, side), Color(1, 1, 1, float(layer[1])))



func _a18_tips(base: Vector2, vip: bool) -> void :
	var tip: Dictionary = AtlasS.TIPS["normal" if vip else "vip"]
	var origin: Vector2 = base + Vector2(float(tip["at"][0]), float(tip["at"][1]))
	var flip: Array = tip["flip"]
	var frame: int = int(_time * float(tip["fps"])) % flip.size()
	var sweep: Variant = tip["sweep"][frame]
	if sweep is Array:
		_a18_sweep(origin, tip, sweep as Array)
	var cells: Array = tip["cells"]
	_fblit(str(cells[int(flip[frame])]), origin + Vector2(float(tip["offset"][0]), float(tip["offset"][1])))



func _a18_sweep(origin: Vector2, tip: Dictionary, sweep: Array) -> void :
	var key: String = str(tip["cells"][0])
	if not _a18_masks.has(key):
		var outline: PackedVector2Array = PackedVector2Array()
		for p: Array in tip["mask"]:
			outline.append(Vector2(float(p[0]), float(p[1])))
		_a18_masks[key] = outline
	var mask: PackedVector2Array = _a18_masks[key]
	var place: Transform2D = Transform2D(Vector2(float(sweep[0]), float(sweep[1])), Vector2(float(sweep[2]), float(sweep[3])), 
		Vector2(float(sweep[4]), float(sweep[5])))
	var back: Transform2D = place.affine_inverse()
	var band: Array = tip["band"]
	var stops: Array = tip["stops"]
	for i: int in stops.size() - 1:
		var x0: float = float(stops[i][0])
		var x1: float = float(stops[i + 1][0])
		if x1 - x0 < 0.001:
			continue
		var c0: Color = Color.html(str(stops[i][1]))
		var c1: Color = Color.html(str(stops[i + 1][1]))
		var quad: PackedVector2Array = PackedVector2Array([place * Vector2(x0, float(band[1])), place * Vector2(x1, float(band[1])), 
			place * Vector2(x1, float(band[3])), place * Vector2(x0, float(band[3]))])
		for piece: PackedVector2Array in Geometry2D.intersect_polygons(quad, mask):
			if piece.size() < 3:
				continue
			var points: PackedVector2Array = PackedVector2Array()
			var colors: PackedColorArray = PackedColorArray()
			for p: Vector2 in piece:
				points.append((origin + p) * _f)
				colors.append(c0.lerp(c1, clampf(((back * p).x - x0) / (x1 - x0), 0.0, 1.0)))
			draw_polygon(points, colors)



func _a18_fly(info: Dictionary) -> void :
	_flies.append_array(RewardFly.begin(self, info))

func _a18_draw_flies() -> void :
	_flies = RewardFly.paint(self, _flies)


func _a18_bounce(t: float) -> float:
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

func _a18_bezier(a: Vector2, b: Vector2, c: Vector2, t: float) -> Vector2:
	var u: float = 1.0 - t
	return a * u * u + b * 2.0 * u * t + c * t * t

func _tick_award() -> void :
	if _sheet_id == "award" and _reward.tick(self):
		_close_sheet()





const BTB_WIND: float = 0.6
const BTB_FREE: float = 0.4
const BTB_ACK_GAP: float = 0.25
const BTB_SEND_GAP: float = 0.3
const BTB_ACK_WAIT: float = 2.5
const BTB_LATE: float = 4.0
const BTB_SKIP_MS: int = 10500
const BTB_FLASH: float = 0.45
const BTB_BUDGET: float = 5.5
const T_BTB_PART: String = "Đã quay %d/%d lượt, Bóng Thần Bí còn lại vẫn giữ nguyên."
var _btb_on: bool = false
var _btb_total: int = 0
var _btb_plan: Array = []
var _btb_acked: int = 0
var _btb_pending: int = 0
var _btb_expect: int = 0
var _btb_rev: int = 0
var _btb_send_at: float = -10.0
var _btb_ack_at: float = -10.0
var _btb_roll_at: float = 0.0
var _btb_halt: bool = false
var _btb_fast: bool = false
var _btb_got: Array = []
var _btb_done: int = 0
var _btb_wins: Dictionary = {}
var _btb_state: String = ""
var _btb_at: float = 0.0
var _btb_from: float = 0.0
var _btb_to: float = 0.0
var _btb_cell: int = -1
var _btb_slot: int = 0
var _btb_flash: Array = []
var _btb_skip: int = 0
var _btb_skip_until: int = 0

func _btb_step() -> float:
	if _btb_fast:
		return 0.12
	if _btb_total <= 5:
		return 1.9
	return clampf(BTB_BUDGET / float(_btb_total), 0.04, 0.35)

func _btb_land_len() -> float:
	return 1.5 if _btb_step() >= 1.0 else _btb_step() * 0.7

func _btb_begin() -> void :
	_btb_on = true
	_btb_total = _auto
	_btb_plan = []
	for i: int in _btb_total / 10:
		_btb_plan.append(10)
	for i: int in _btb_total % 10:
		_btb_plan.append(1)
	_btb_acked = 0
	_btb_pending = 0
	_btb_halt = false
	_btb_fast = false
	_btb_got = []
	_btb_done = 0
	_btb_wins = {}
	_btb_flash = []
	_btb_cell = -1
	_btb_send_at = -10.0
	_btb_ack_at = -10.0
	_btb_roll_at = _time
	_waiting = false
	_tw_on = false
	_tw_done = ""
	_set_play(false)
	_stop_on = true
	_rot = _norm(_rot)
	_btb_from = _rot
	_btb_to = _rot + 270.0
	_btb_state = "wind"
	_btb_at = _time
	_btb_send()


func _btb_send() -> void :
	if _btb_halt or _btb_plan.is_empty() or _btb_pending > 0:
		return
	if _time - _btb_ack_at < BTB_ACK_GAP or _time - _btb_send_at < BTB_SEND_GAP:
		return
	if _btb_total <= 5 and _btb_acked - _btb_done >= 2:
		return
	var count: int = int(_btb_plan[0])
	_recount()
	var cost: int = _cost() * count
	if _balls() < cost:
		_btb_halt = true
		return
	_btb_expect = _balls() - cost
	_btb_rev = client.bag_rev
	if not client.roulette_spin(_kind_w, count == 10):
		_btb_halt = true
		say("Chưa gửi được, hãy thử lại.")
		return
	_btb_plan.pop_front()
	_btb_pending = count
	_btb_send_at = _time
	_btb_skip += 1
	_btb_skip_until = Time.get_ticks_msec() + BTB_SKIP_MS

func _btb_ack_tick() -> void :
	if _btb_pending <= 0:
		return
	if client.bag_rev != _btb_rev:
		_btb_rev = client.bag_rev
		_recount()
		if _balls() <= _btb_expect:
			_btb_acked += _btb_pending
			_btb_pending = 0
			_btb_ack_at = _time
			_btb_roll_at = maxf(_btb_roll_at, _time)
			return
	if _time - _btb_send_at > BTB_ACK_WAIT:
		_btb_pending = 0
		_btb_halt = true
		_btb_skip = maxi(0, _btb_skip - 1)

func _btb_rolled(slot: int) -> void :
	_btb_got.append(slot)
	_btb_roll_at = _time


func _btb_eat() -> bool:
	if _btb_skip <= 0:
		return false
	if not _btb_on and Time.get_ticks_msec() > _btb_skip_until:
		_btb_skip = 0
		return false
	_btb_skip -= 1
	return true

func _btb_index(deg: float) -> int:
	var index: int = roundi(fposmod(deg, 360.0) / 36.0)
	return 0 if index >= 10 else index

func _btb_land() -> void :
	var slot: int = int(_btb_got.pop_front())
	_btb_slot = slot
	_btb_cell = _slot_index(slot)
	var cell: int = maxi(0, _btb_cell)
	_rot = _norm(_rot)
	var jitter: float = (randf() * 2.0 - 1.0) * 10.0
	var ahead: float = fposmod(cell * 36.0 + jitter - _rot, 360.0)
	if _btb_step() >= 1.0:
		ahead += 720.0
	elif ahead < 120.0 and not _btb_fast:
		ahead += 360.0
	_btb_from = _rot
	_btb_to = _rot + ahead
	_btb_state = "land"
	_btb_at = _time

func _btb_tick() -> void :
	_btb_ack_tick()
	_btb_send()
	var age: float = _time - _btb_at
	match _btb_state:
		"wind":
			var t: float = clampf(age / BTB_WIND, 0.0, 1.0)
			_rot = _btb_from + (_btb_to - _btb_from) * t * t
			if t >= 1.0:
				_btb_next()
		"free":
			_rot = _btb_from + age * 360.0 / BTB_FREE
			if not _btb_got.is_empty() or _btb_over():
				_btb_next()
		"land":
			var t: float = clampf(age / _btb_land_len(), 0.0, 1.0)
			_rot = _btb_from + (_btb_to - _btb_from) * (1.0 - (1.0 - t) * (1.0 - t))
			if t >= 1.0:
				_btb_done += 1
				_btb_wins[_btb_slot] = int(_btb_wins.get(_btb_slot, 0)) + 1
				_btb_flash.append([_btb_cell, _time])
				if _btb_flash.size() > 4:
					_btb_flash.pop_front()
				if _buy != null:
					_buy.text = str(maxi(0, _btb_total - _btb_done))
				_btb_state = "hold"
				_btb_at = _time
		"hold":
			if age >= _btb_step() - _btb_land_len():
				_btb_next()
		"end":
			if age >= 0.3:
				_btb_finish()
	if _btb_state != "end":
		_last_index = _btb_index(_rot) if _btb_state != "hold" else maxi(0, _btb_cell)


func _btb_over() -> bool:
	if _btb_pending > 0 or not _btb_got.is_empty():
		return false
	if not _btb_halt and not _btb_plan.is_empty():
		return false
	return _btb_done >= _btb_acked or _time - _btb_roll_at > BTB_LATE

func _btb_next() -> void :
	if not _btb_got.is_empty():
		_btb_land()
	elif _btb_over():
		_btb_state = "end"
		_btb_at = _time
	elif _btb_state != "free":
		_rot = _norm(_rot)
		_btb_from = _rot
		_btb_state = "free"
		_btb_at = _time

func _btb_stop() -> void :
	_btb_halt = true
	_btb_fast = true
	_stop_on = false

func _btb_finish() -> void :
	var done: int = _btb_done
	var total: int = _btb_total
	_btb_on = false
	_btb_state = ""
	_last_index = maxi(0, _btb_cell)
	_set_play(true)
	_stop_on = true
	client.roulette_list(_kind_w)
	_show_kept()
	var items: Array = _btb_items()
	if not items.is_empty():
		_show_award({"coins": [0, 0, 0], "exp": 0, "items": items})
	_set_count(total)
	if done < total:
		say(T_BTB_PART % [done, total])


func _btb_items() -> Array:
	var out: Array = []
	var seen: Dictionary = {}
	var order: Array = []
	for row: Variant in _wheel_rows():
		if row is Array and row.size() >= 3:
			order.append(int(row[0]))
	for slot: Variant in _btb_wins.keys():
		if not order.has(int(slot)):
			order.append(int(slot))
	for slot: int in order:
		var wins: int = int(_btb_wins.get(slot, 0))
		var row: Array = _roll_slot(slot)
		if wins <= 0 or row.size() < 3:
			continue
		var id: int = int(row[1])
		if seen.has(id):
			out[int(seen[id])][1] = int(out[int(seen[id])][1]) + wins * int(row[2])
		else:
			seen[id] = out.size()
			out.append([id, wins * int(row[2])])
	return out


func _btb_abort() -> void :
	if not _btb_on:
		return
	_btb_on = false
	_btb_halt = true
	_btb_state = ""
	_btb_got = []
	_set_play(true)
	_stop_on = true

func _btb_draw(base: Vector2) -> void :
	if not _btb_on and _btb_flash.is_empty():
		return
	var spots: Array = Atlas.ITEMS["at"]
	for flash: Array in _btb_flash:
		var cell: int = int(flash[0])
		var age: float = _time - float(flash[1])
		if cell < 0 or cell >= spots.size() or age > BTB_FLASH:
			continue
		var fade: float = 1.0 - age / BTB_FLASH
		var mid: Vector2 = (base + _v(spots[cell]) + Vector2(50.0, 30.0)) * _f
		draw_circle(mid, 36.0 * _f, Color(1.0, 0.92, 0.3, 0.3 * fade))
		draw_arc(mid, (34.0 + 8.0 * (1.0 - fade)) * _f, 0.0, TAU, 40, Color(1.0, 0.95, 0.32, fade), 3.0 * _f, true)
	if not _btb_on:
		return
	for slot: Variant in _btb_wins.keys():
		var cell: int = _slot_index(int(slot))
		if cell < 0 or cell >= spots.size():
			continue
		_fwords("x%d" % int(_btb_wins[slot]), BOLD, 14.0, OK_GOLD, "c", base + _v(spots[cell]) + Vector2(66.0, -6.0), 34.0)
	var word: Vector2 = base + _v(Atlas.DIAL["word"])
	_fwords("%d/%d" % [_btb_done, _btb_total], BOLD, 14.0, Color.WHITE, "c", word + Vector2(-40.0, 22.0), 80.0)
