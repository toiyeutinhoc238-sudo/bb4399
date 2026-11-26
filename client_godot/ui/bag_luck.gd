extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")














const Atlas = preload("bag_luck_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const Arena = preload("arena_atlas.gd")
const QuestAtlas = preload("quest_atlas.gd")
const RewardPopup = preload("reward_popup.gd")
const RewardFly = preload("reward_fly.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const ShopModel = preload("shop_model.gd")
const OpenUi = preload("open_ui_note.gd")

signal closed(note: String)
signal buy_asked(tid: int, count: int, tip: String)

const UI_LUCK: int = 32
const ROLL: int = 13
const ACT_TYPE: int = 137
const CONVERT_TYPE: int = 32
const PER_PAGE: int = 4
const PAGE_BUTTONS: int = 5
const ITEM_COUNT: int = 12
const WAIT_ROLL: float = 6.0
const GAMBLE_OP: int = 9

const NONE: int = 0
const BEGIN: int = 1
const DURACT: int = 2
const END: int = 3
const TANK_CARD: int = 46
const TANK_SKIN: int = 29
const PATHS: Dictionary = {"convert": "/xml/ItemConvertTemplate_table.xml", "acts": "/xml/ActivityTemplate_table.xml"}
const CELLS: Array = ["public_bk", "public_bk_b2", "public_bk_bc", "public_bk_bc_r", "public_bk_c", "public_bk_l", "public_bk_lt", 
	"public_bk_oc", "public_bk_ol", "public_bk_or", "public_bk_pattern", "public_bk_r", "public_bk_rt", "public_bk_ti", 
	"public_button_close", "public_window_button_bk", "public_button_window_green"]

const TIP_FULL: String = "Kho đầy, hãy sắp xếp trước"
const TIP_LACK: String = "Thiếu @item@"
const TIP_HAVE_TANK: String = "Đã có Tank này, không thể đổi lại"
const TIP_HAVE_SKIN: String = "Đã có vỏ này, không thể đổi lại"
const TIP_NO_TANK: String = "Chưa có【@name@】, không thể đổi skin 【@item@】"
const OFFLINE: String = "Chưa gửi được, hãy thử lại."
const AWARD_ROWS: int = 6
const DIM: Color = Color(0, 0, 0, 0.4)
const OK_GOLD: Color = Color("fff352")
const COUNT_INK: Color = Color("fdc45f")
const SPECIAL_INK: Color = Color("ffff00")
const CELL_RIM: Color = Color(0, 0, 0, 0.8)


var _slots: Array = Atlas.SLOTS.duplicate(true)
var _state: int = NONE
var _batch: bool = false
var _x: float = 0.0
var _tw_on: bool = false
var _tw_from: float = 0.0
var _tw_to: float = 0.0
var _tw_len: float = 1.0
var _tw_at: float = 0.0
var _tw_ease: String = "lin"
var _cur: int = 0
var _last: int = 0
var _selected: Array = []
var _reward_on: bool = false
var _reward_at: float = 0.0
var _one: bool = true
var _waiting: bool = false
var _wait_at: float = 0.0
var _kept: Array = []

var _fund: int = -1
var _time_live: String = ""
var _time_xml: String = ""
var _rows: Array = []
var _roll_index: int = -1
var _roll_every: float = 20.0
var _roll_running: bool = false
var _roll_next: float = 0.0
var _labels: Array = []
var _start_due: float = -1.0
var _ticker: Control = null
var _ticker_rect: Rect2 = Rect2()
var _cover: Array = []

var _convert_raw: Array = []
var _converts: Array = []
var _page: int = 0
var _page_first: int = 0
var _pick: Dictionary = {}
var _amount: int = 1
var _qty: LineEdit
var _sent_at: float = -10.0

var _sheet_id: String = ""
var _reward: RefCounted = RewardPopup.new()
var _award: Array = []
var _flies: Array = []
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _placed: Array = []
var _counts: Dictionary = {}
var _counted_at: float = -10.0
var _stale: bool = true
var _ui_wait: bool = false
var _base: Vector2 = Vector2.ZERO
var _http: HTTPRequest
var _queue: Array = []
var _loading: String = ""
var _bad: Dictionary = {}


class TickerBox extends Control:
	var paint: Callable

	func _draw() -> void :
		if paint.is_valid():
			paint.call(self)

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_selected.resize(ITEM_COUNT)
	_selected.fill(false)
	_qty = _fedit(4, true)
	_qty.text_changed.connect( func(_text: String) -> void : _on_qty_input())
	_qty.text_submitted.connect( func(_text: String) -> void : _confirm_convert())
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_http)
	var box: TickerBox = TickerBox.new()
	box.paint = _paint_ticker
	box.clip_contents = true
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.visible = false
	add_child(box)
	_ticker = box
	pack.picture_ready.connect( func(path: String) -> void :
		if path in ["l/fair.json", "l/bag.json", "l/garage.json", "l/events.json"]:
			_stale = true)
	client.awarded.connect(_on_award)
	client.rolled.connect(_on_rolled)
	client.noticed.connect( func(text: String) -> void :
		if is_visible_in_tree():
			say(text))
	if client.has_signal("luck_lines"):
		client.connect("luck_lines", _on_lines)
		client.connect("luck_fund", func(value: int) -> void : _fund = value)
		client.connect("luck_slots", _on_slots)
		client.connect("luck_time", func(text: String) -> void : _time_live = text.replace("#ENTER#", " ").strip_edges())


func open() -> void :
	_reward.reset()
	_flies = []
	RewardFly.reset(self)
	_toast = ""
	_hover = ""
	_press = ""
	_close_sheet()
	_tip = []
	_kept = []
	_stop_spin()
	_stale = true
	_counted_at = -10.0
	_page = 0
	_page_first = 0
	pack.load_fair()
	pack.load_bag()
	pack.load_garage()
	pack.load_events()
	if not client.bag_loaded:
		client.request_bags()
	_ui_wait = OpenUi.note(client, pack, UI_LUCK) == OpenUi.WAIT
	if client.has_method("luck_ui"):
		client.luck_ui(true)
		client.luck_list()
	if _convert_raw.is_empty():
		_fetch("convert")
	if _time_xml.is_empty():
		_fetch("acts")
	visible = true
	_start_due = _time + 1.0


func close(note: String = "") -> void :
	if not visible:
		return
	_reward.reset()
	_close_sheet()
	_stop_spin()
	_kept = []
	_flies = []
	RewardFly.reset(self)
	_ui_wait = false
	if client.has_method("luck_ui"):
		client.luck_ui(false)
	visible = false
	_ticker.visible = false
	_hide_edits()
	closed.emit(note)

func chat_busy() -> bool:
	return visible

func _shown() -> void :
	if _qty == null or _ticker == null:
		return
	if not is_visible_in_tree():
		_hide_edits()
		_ticker.visible = false



func _fetch(kind: String) -> void :
	if kind == _loading or kind in _queue:
		return
	_queue.append(kind)
	_pump()

func _pump() -> void :
	if not _loading.is_empty() or _queue.is_empty():
		return
	_loading = str(_queue.pop_front())
	_http.cancel_request()
	var url: String = client.config.origin + str(PATHS.get(_loading, ""))
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
			"convert":
				_convert_raw = _xml_rows(body, "entry")
				ok = not _convert_raw.is_empty()
				_stale = true
			"acts":
				ok = _read_acts(body)
	_bad[kind] = not ok
	_pump()


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


func _read_acts(body: PackedByteArray) -> bool:
	var rows: Array = _xml_rows(body, "entry")
	if rows.is_empty():
		return false
	for row: Dictionary in rows:
		if int(row.get("nType", "0")) == ACT_TYPE:
			_time_xml = str(row.get("szTimeDesc", "")).replace("#ENTER#", " ").strip_edges()
			break
	return true

func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))

func _pages(count: int) -> int:
	return maxi(1, ceili(float(count) / float(PER_PAGE)))

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

func _need() -> int:
	return 1 if _one else 10


func _bag_full() -> bool:
	var grocery: int = int(BagModel.capacity("vp", 0, pack.bag, client.character)[1])
	var material: int = int(BagModel.capacity("mat", 0, pack.bag, client.character)[1])
	return BagModel.first_empty(client.bags, 2, grocery) == -1 or BagModel.first_empty(client.bags, 3, material) == -1

func _slot_index(id: int) -> int:
	for i: int in _slots.size():
		if int(_slots[i][0]) == id:
			return i
	return -1


func _on_slots(body: PackedByteArray) -> void :
	if body.size() < 6 or body.decode_u32(0) != ROLL:
		return
	var count: int = body.decode_u16(4)
	if count > ITEM_COUNT or body.size() - 6 != count * 16:
		return
	var updates: Dictionary = {}
	for k: int in count:
		var at: int = 6 + k * 16
		var index: int = _slot_index(int(body.decode_u32(at)))
		var item: int = int(body.decode_u32(at + 4))
		var amount: int = int(body.decode_u32(at + 8))
		if index < 0 or item == 0 or amount == 0:
			return
		updates[index] = [item, amount]
	for index: int in updates:
		_slots[index][1] = updates[index][0]
		_slots[index][2] = updates[index][1]


func _on_lines(rows: Array) -> void :
	var list: Array = []
	for row: Variant in rows:
		if not (row is Array) or (row as Array).size() < 2 or str(row[0]).is_empty():
			continue
		list.append(str(row[0]) if int(row[1]) <= 1 else "%s x%d" % [str(row[0]), int(row[1])])
	_rows = list
	if not list.is_empty():
		_set_duration()
		_begin_roll()




func _set_duration() -> void :
	var count: int = _rows.size()
	var every: float = 20.0 if count <= 1 else (5.0 if count < 4 else 1.0)
	if every != _roll_every:
		_roll_every = every
		if _roll_running:
			_roll_next = _time + every

func _begin_roll() -> void :
	if _roll_running:
		return
	_roll_running = true
	_roll_index = -1
	_roll_handler()
	_roll_next = _time + _roll_every

func _roll_index_of(p: int) -> int:
	var count: int = _rows.size()
	if p < 0:
		return 0
	if count < 1:
		return p
	if p >= count:
		return _roll_index_of(count - p)
	return p

func _roll_handler() -> void :
	var index: int = _roll_index_of(_roll_index + 1)
	if index >= _rows.size():
		return
	_roll_index = index
	_labels.append([str(_rows[index]), _time])

func _roll_tick() -> void :
	if _start_due >= 0.0 and _time >= _start_due:
		_start_due = -1.0
		_begin_roll()
	if _roll_running and _time >= _roll_next:
		_roll_next = _time + _roll_every
		_roll_handler()
	var life: float = float(Atlas.TICKER["time"])
	_labels = _labels.filter( func(label: Array) -> bool: return _time - float(label[1]) < life)



func _tween(from: float, to: float, length: float, ease: String) -> void :
	_x = from
	_tw_from = from
	_tw_to = to
	_tw_len = maxf(0.01, length)
	_tw_at = _time
	_tw_ease = ease
	_tw_on = true

func _eased(t: float) -> float:
	match _tw_ease:
		"in":
			return t * t
		"quad":
			return 1.0 - (1.0 - t) * (1.0 - t)
		"sine":
			return sin(t * PI / 2.0)
	return t

func _stop_spin() -> void :
	_tw_on = false
	_batch = false
	_waiting = false
	_state = NONE

func _refresh_display() -> void :
	for i: int in ITEM_COUNT:
		_selected[i] = i == _cur

func _deselect_all() -> void :
	_selected.fill(false)

func _spin_tick() -> void :
	if _tw_on:
		var t: float = clampf((_time - _tw_at) / _tw_len, 0.0, 1.0)
		_x = lerpf(_tw_from, _tw_to, _eased(t))
		if _batch:
			var odd: bool = int(_x) % 2 == 1
			for i: int in ITEM_COUNT:
				_selected[i] = (i % 2 == 1) == odd
		else:
			_cur = int(floorf(fmod(_x, float(ITEM_COUNT))))
			_refresh_display()
		if t >= 1.0:
			_tw_on = false
			_on_tween_end()
	elif _state == DURACT and _waiting and _time - _wait_at >= WAIT_ROLL:
		_waiting = false
		_state = NONE
		_show_kept()


func _start_roll() -> void :
	if _state != NONE:
		return
	if _bag_full():
		say(TIP_FULL)
		return
	var need: int = _need()
	var have: int = _have(Atlas.NEED)
	if need > have:
		buy_asked.emit(int(Atlas.BUY), need - have, TIP_LACK.replace("@item@", str(_item(int(Atlas.NEED), 1).name)))
		return
	if _one:
		_begin_rolling(_last)
	else:
		_begin_batch()

func _begin_rolling(index: int) -> void :
	_batch = false
	_cur = index
	_tween(index, index + 24, 2.0, "in")
	_state = BEGIN
	_reward_on = false

func _begin_batch() -> void :
	_batch = true
	_state = BEGIN
	_reward_on = false
	_tween(0, 10, 2.0, "in")

func _on_tween_end() -> void :
	if _batch:
		if _state == BEGIN:
			_batch = false
			_deselect_all()
			_state = NONE
			_request()
		return
	match _state:
		BEGIN:
			_tween(_cur, _cur + 36, 1.5, "lin")
			_state = DURACT
		DURACT:
			_request()
		END:
			_state = NONE
			_reward_on = true
			_reward_at = _time
			_show_kept()
	_refresh_display()


func _request() -> void :
	var sent: bool = client.has_method("luck_spin") and client.luck_spin( not _one)
	if not sent:
		say(OFFLINE)
		_state = NONE
		return
	if _state == DURACT:
		_waiting = true
		_wait_at = _time


func _on_rolled(slot: int) -> void :
	if not is_visible_in_tree() or _state != DURACT or not _waiting:
		return
	_waiting = false
	var target: int = _slot_index(slot)
	_last = target
	_tween(_cur, target + ITEM_COUNT, 2.0 * (1.1 - 0.2 * randf()), "quad" if randf() < 0.5 else "sine")
	_state = END



func _on_award(info: Dictionary) -> void :
	if not is_visible_in_tree() or client.award_op in [1, 7, 13, 14, 15, 19, 26, 27, 29, 30]:
		return
	if client.award_show == 0 or client.award_op == 8:
		info = info.duplicate()
		info["fly"] = true
	if client.award_op == GAMBLE_OP:
		var ext: Variant = client.get("award_ext")
		if ext != null and int(ext) != 0:
			_deselect_all()
		if _state == END or (_state == DURACT and _waiting):
			_kept.append(info)
			return
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
	if bool(info.get("fly", false)):
		_fly(info)
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
	_close_sheet()
	_award = lines
	_sheet_id = "award"



func _build_converts() -> void :
	_converts = []
	var names: Dictionary = pack.lobby.get("tanks", {})
	var defaults: Dictionary = pack.index.get("tanks", {})
	var skins: Dictionary = pack.garage.get("skin_items", {})
	for row: Dictionary in _convert_raw:
		var result: int = int(row.get("nNewItemId", "0"))
		if int(row.get("nType", "0")) != CONVERT_TYPE or result <= 0:
			continue
		var gt: int = 6 if skins.has(str(result)) else (2 if names.has(str(result)) else 4)
		var rec: Dictionary = {"tid": result, "gt": gt}
		if not ShopModel.describe(rec, pack.bag, pack.garage, names, defaults):
			continue
		var count: int = maxi(1, int(row.get("nNewItemCount", "1")))
		var gift: Dictionary = _item(result, count)
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
		_converts.append({"id": int(row.get("nId", "0")), "items": items, "gift": gift, "gt": gt, "count": count, 
			"max": int(row.get("nConvertMax", "0")), "heft": int(row.get("nHeft", "0"))})
	_converts.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.heft) > int(b.heft) if int(a.heft) != int(b.heft) else int(a.id) < int(b.id))
	_go_page(_page)

func _shown_converts() -> Array:
	return _converts.slice(_page * PER_PAGE, _page * PER_PAGE + PER_PAGE)


func _go_page(page: int) -> void :
	var pages: int = _pages(_converts.size())
	_page = clampi(page, 0, pages - 1)
	if _page >= _page_first + PAGE_BUTTONS:
		_page_first = _page - PAGE_BUTTONS + 1
	elif _page < _page_first:
		_page_first = _page
	_page_first = clampi(_page_first, 0, maxi(0, pages - PAGE_BUTTONS))


func _convert_click(index: int) -> void :
	var rows: Array = _shown_converts()
	if index < 0 or index >= rows.size():
		return
	var rec: Dictionary = rows[index]
	var tid: int = int(rec.gift.id)
	var row_value: Variant = pack.bag.get("items", {}).get(str(tid))
	var row: Array = row_value if row_value is Array else []
	if row.size() >= 10:
		var type: int = int(row[4])
		var reuse: int = int(row[9])
		if type == TANK_CARD:
			if ShopModel.owned({"gt": 2, "tid": reuse}, client.tanks, client.bags) > 0:
				say(TIP_HAVE_TANK)
				return
		elif type == TANK_SKIN:
			if reuse != 0 and ShopModel.owned({"gt": 2, "tid": reuse}, client.tanks, client.bags) == 0:
				var tank: Variant = pack.lobby.get("tanks", {}).get(str(reuse))
				if tank == null:
					return
				say(TIP_NO_TANK.replace("@name@", str(tank)).replace("@item@", BagModel.clean(str(row[0]))))
				return
			if ShopModel.owned({"gt": 6, "tid": tid}, client.tanks, client.bags) > 0:
				say(TIP_HAVE_SKIN)
				return
	_open_confirm(rec)


func _most(rec: Dictionary) -> int:
	var most: int = 99999999
	for pair: Array in rec.items:
		if int(pair[0]) != 0 and int(pair[1]) > 0:
			most = mini(most, _have(int(pair[0])) / int(pair[1]))
	if int(rec.gt) == 6:
		most = mini(most, 1)
	elif int(rec.max) != 0:
		most = mini(most, int(rec.max))
	return maxi(0, most)

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
	var value: int = clampi(int(typed) if typed.is_valid_int() else 1, 1, maxi(1, _most(_pick)))
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
	var rec: Dictionary = _pick
	var amount: int = _amount
	_close_sheet()
	if amount < 1 or _time - _sent_at < 1.0:
		return
	if not client.convert_item(int(rec.id), amount):
		say(OFFLINE)
		return
	_sent_at = _time

func _close_sheet() -> void :
	if _sheet_id == "award" and _reward.request_close(self):
		return
	_sheet_id = ""
	_pick = {}
	_award = []
	_hide_edits()



func _activate(id: String) -> void :
	if not _sheet_id.is_empty():
		_sheet_activate(id)
		return
	match id:
		"close":
			close("")
		"start":
			_start_roll()
		"one":
			_one = true
		"ten":
			_one = false
		"prev":
			_go_page(_page - 1)
		"next":
			_go_page(_page + 1)
		_:
			if id.begins_with("cv:"):
				_convert_click(int(id.substr(3)))
			elif id.begins_with("page:"):
				_go_page(int(id.substr(5)))

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

func _input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.echo:
		return
	match event.keycode:
		KEY_ESCAPE:
			if _sheet_id.is_empty():
				close("")
			else:
				_close_sheet()
		KEY_ENTER, KEY_KP_ENTER:
			match _sheet_id:
				"award":
					_close_sheet()
				"confirm":
					_confirm_convert()
				_:
					return
		_:
			return
	get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and is_visible_in_tree() and event is InputEventKey:
		get_viewport().set_input_as_handled()

func _tick(_delta: float) -> void :
	_tick_award()
	if _ui_wait and OpenUi.note(client, pack, UI_LUCK) != OpenUi.WAIT:
		_ui_wait = false
	if _time - _counted_at > 0.25:
		_recount()
	if _stale and not pack.bag.is_empty() and not pack.garage.is_empty() and not _convert_raw.is_empty():
		_stale = false
		_build_converts()
	_spin_tick()
	_roll_tick()
	_place_ticker()



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		var cells: Dictionary = {}
		for key: String in CELLS:
			if Arena.R.has(key):
				cells[key] = Arena.R[key]
		_use(Arena.FILE, cells)
		var fly: Dictionary = {}
		for name: String in ["qu_fly_gold", "qu_fly_gift"]:
			if QuestAtlas.R.has(name):
				fly[name] = QuestAtlas.R[name]
		_use(QuestAtlas.FILE, fly)
	_tip = []
	_placed = []
	_cover = []
	var frame: Dictionary = Atlas.FRAME
	var box: Vector2 = _v(frame["size"])
	var base: Vector2 = _centre(box.x, box.y)
	_base = base
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_hit("panel", Rect2(base * _f, box * _f), false)
	_fblit("lk_frame", base + _v(frame["frame"]))
	_draw_cells(base)
	_draw_start(base)
	_draw_labels(base)
	_draw_converts(base)
	_draw_pager(base)
	_fbutton("close", "lk_close", base + _v(frame["btnClose"]))
	var winning: Array = frame["cpWinningInfo"]
	_ticker_rect = Rect2((base + _v(winning)) * _f, Vector2(float(winning[2]), float(winning[3])) * _f)
	match _sheet_id:
		"award":
			_draw_award()
		"confirm":
			_draw_confirm()
		_:
			_draw_tip()
	_draw_flies()
	if _qty.visible and not _qty in _placed:
		_qty.visible = false
		_qty.release_focus()


func _place_ticker() -> void :
	if _ticker == null:
		return
	var show: bool = visible and is_visible_in_tree() and _ticker_rect.size.x > 0.0 and not _labels.is_empty()
	for rect: Rect2 in _cover:
		if show and rect.intersects(_ticker_rect):
			show = false
	if show and not _toast.is_empty() and _time - _toast_at <= 2.6:
		show = not _toast_rect().intersects(_ticker_rect)
	_ticker.visible = show
	if not show:
		return
	_ticker.position = _ticker_rect.position
	_ticker.size = _ticker_rect.size
	_ticker.modulate = Color(0.65, 0.65, 0.65, 1.0) if not _sheet_id.is_empty() else Color.WHITE
	_ticker.queue_redraw()

func _toast_rect() -> Rect2:
	var font_size: int = maxi(6, roundi(32 * _u))
	var width: float = ARIAL_BOLD.get_string_size(_toast, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x + 96.0 * _u
	return Rect2(Vector2((size.x - width) / 2.0, size.y * 0.3), Vector2(width, 88.0 * _u))


func _paint_ticker(canvas: Control) -> void :
	var spec: Dictionary = Atlas.TICKER
	var px: float = float(spec["px"])
	var font_size: int = maxi(6, roundi(px * _f))
	var glow: Array = Atlas.GLOW["ticker"]
	var rim: Color = Color(str(glow[0]), float(glow[1]))
	var ink: Color = Color(str(spec["color"]))
	var life: float = float(spec["time"])
	var lift: float = (ARIAL_BOLD.get_ascent(font_size) - ARIAL_BOLD.get_descent(font_size)) / 2.0
	var wide: float = canvas.size.x
	for label: Array in _labels:
		var y: float = lerpf(float(spec["from"]), float(spec["to"]), clampf((_time - float(label[1])) / life, 0.0, 1.0))
		var at: Vector2 = Vector2(0.0, (y + 2.0 + px * 0.55) * _f + lift)
		canvas.draw_string_outline(ARIAL_BOLD, at, str(label[0]), HORIZONTAL_ALIGNMENT_CENTER, wide, font_size, maxi(1, roundi(2.0 * _f)), rim)
		canvas.draw_string(ARIAL_BOLD, at, str(label[0]), HORIZONTAL_ALIGNMENT_CENTER, wide, font_size, ink)


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


func _label(spec: Array, text: String, at: Vector2, glow: Array = [], ink: Color = Color(0, 0, 0, 0)) -> void :
	if text.is_empty():
		return
	var fixed: bool = float(spec[2]) > 0.0
	var color: Color = ink if ink.a > 0.0 else Color(str(spec[5]))
	var rim: Color = Color(str(glow[0]), float(glow[1])) if glow.size() >= 4 else SHADE
	var edge: float = clampf(float(glow[2]) / 2.0 + (0.5 if float(glow[3]) >= 8.0 else 0.0), 1.0, 2.0) if glow.size() >= 4 else 1.0
	_fwords(text, BOLD if int(spec[6]) == 1 else REGULAR, float(spec[4]), color, str(spec[7]), at + Vector2(float(spec[0]), float(spec[1])), 
		float(spec[2]) if fixed else 400.0, edge, float(spec[3]), fixed, rim)


func _draw_cells(base: Vector2) -> void :
	var layout: Dictionary = Atlas.CELLS
	var item: Array = layout["item"]
	var select: Array = layout["select"]
	var name_box: Array = layout["name"]
	var count_at: Array = layout["count"]
	var side: Vector2 = _v(layout["size"])
	for i: int in ITEM_COUNT:
		var at: Vector2 = base + _v(layout["at"][i])
		var slot: Array = _slots[i]
		var special: int = int(slot[3])
		var count: int = int(slot[2])
		var gift: Dictionary = _item(int(slot[1]), count)
		if special == 2:
			_rays(at)
		_fit(_gift_art(gift), at + Vector2(float(item[0]), float(item[1])), Vector2(float(item[2]), float(item[3])))
		if _selected[i]:
			_fblit("lk_select", at + Vector2(float(select[0]), float(select[1])), float(select[2]), float(select[3]))
		if _reward_on and i == _last:
			_draw_reward(at + _v(layout["reward"]))
		var ink: Color = SPECIAL_INK if special in [1, 2] else Color.WHITE

		var title: String = _cell_cut(str(gift.name) + ("x%d" % count if count > 1 else ""), float(name_box[2]))
		_fwords(title, BOLD, 12.0, ink, "c", at + Vector2(float(name_box[0]), float(name_box[1])), float(name_box[2]), 1.0, float(name_box[3]), false, CELL_RIM)
		if count > 1:
			_fwords("x%d" % count, BOLD, 16.0, ink, "r", at + Vector2(float(count_at[0]) - 70.0, float(count_at[1])), 70.0, 1.0, 0.0, true, CELL_RIM)
		_peek_item(Rect2(at * _f, side * _f), gift)


func _cell_cut(text: String, wide: float) -> String:
	var face: Font = _face(BOLD)
	var font_size: int = maxi(6, roundi(12.0 * _f))
	var room: float = (wide - 5.0) * _f
	if face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= room:
		return text
	var keep: String = text
	while keep.length() > 1 and face.get_string_size(keep + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
		keep = keep.left(keep.length() - 1)
	return keep + "..."


func _rays(at: Vector2) -> void :
	var effect: Dictionary = Atlas.EFFECT
	var frames: Array = effect["frames"]
	var row: Array = frames[int(_time * float(effect["fps"])) % frames.size()]
	var box: Array = effect["box"]
	var k: float = float(box[2]) / float(effect["stage"][0])
	var pivot: Vector2 = at + Vector2(float(box[0]), float(box[1])) + Vector2(float(effect["center"][0]), float(effect["center"][1])) * k
	var side: float = float(effect["side"]) * float(effect["scale"]) * k
	for layer: Variant in row:
		if layer == null or float(layer[1]) <= 0.0:
			continue
		_turned("lk_rays", pivot, Vector2( - side, - side) / 2.0, float(layer[0]), Vector2(side, side), Color(1, 1, 1, float(layer[1])))


func _draw_reward(centre: Vector2) -> void :
	var effect: Dictionary = Atlas.REWARD
	var flip: Array = effect["flip"]
	var frame: int = int((_time - _reward_at) * float(effect["fps"])) % flip.size()
	_fblit("lk_rw%d" % int(flip[frame]), centre + _v(effect["ring"]))
	var stars: Array = effect["star"]
	var star: Variant = stars[frame % stars.size()]
	if star is Array and float(star[4]) > 0.0:
		var side: Vector2 = _v(effect["star_side"]) * float(star[1])
		_turned("lk_star", centre + Vector2(float(star[2]), float(star[3])), - side / 2.0, float(star[0]), side, Color(1, 1, 1, float(star[4])))


func _draw_start(base: Vector2) -> void :
	var frame: Dictionary = Atlas.FRAME
	_fbutton("start", "lk_start", base + _v(frame["btnStart"]))
	var start: Dictionary = Atlas.START
	var frames: Array = start["frames"]
	_fblit("lk_st%d" % int(frames[int(_time * float(start["fps"])) % frames.size()]), base + _v(frame["imgStart"]) + _v(start["offset"]), 0.0, 0.0, _glow("start"))
	_fbutton("one", "lk_chk_on" if _one else "lk_chk", base + _v(frame["rbtOne"]))
	_fbutton("ten", "lk_chk" if _one else "lk_chk_on", base + _v(frame["rbtTen"]))

func _draw_labels(base: Vector2) -> void :
	var texts: Dictionary = Atlas.TEXTS
	var glow: Dictionary = Atlas.GLOW
	_label(texts["lblGiftNum"], str(_fund) if _fund >= 0 else "", base, glow["gift"])
	_label(texts["_VNLuckSoltFrame_Label2"], str(Atlas.LABEL2), base, glow["label"])
	var when : String = _time_live if not _time_live.is_empty() else (_time_xml if not _time_xml.is_empty() else str(Atlas.ACT_TIME))
	_label(texts["lblActTime"], when , base, glow["label"])
	_label(texts["lblItemCount"], "%d/%d" % [_have(int(Atlas.NEED)), _need()], base, [], COUNT_INK)
	_label(texts["lblItemCnt"], "%s : %d" % [str(_item(int(Atlas.TICKET), 1).name), _have(int(Atlas.TICKET))], base, glow["cnt"])


func _draw_converts(base: Vector2) -> void :
	var layout: Dictionary = Atlas.CONVERT
	var texts: Dictionary = layout["texts"]
	var icon: Array = layout["imgItem"]
	var fresh: Array = layout["new_item"]
	var rows: Array = _shown_converts()
	for k: int in mini(rows.size(), PER_PAGE):
		var rec: Dictionary = rows[k]
		var at: Vector2 = base + _v(layout["rows"][k])
		var stuff: Array = rec.items[0]
		_fblit("lk_coin_bg", at + _v(layout["coin_bg"]))
		var material: Dictionary = _item(int(stuff[0]), int(stuff[1]))
		var icon_rect: Rect2 = Rect2((at + _v(icon)) * _f, Vector2(float(icon[2]), float(icon[3])) * _f)
		_fit(_gift_art(material), at + _v(icon), Vector2(float(icon[2]), float(icon[3])), 1.0)
		_label(texts["lblItemCnt"], str(int(stuff[1])), at)
		_fblit("lk_new_bg", at + _v(layout["frmNewItem"]))
		var gift: Dictionary = rec.gift
		_fit(_gift_art(gift), at + _v(fresh) + Vector2(6, 6), Vector2(float(fresh[2]) - 12.0, float(fresh[3]) - 12.0))
		var quality: int = int(gift.quality)
		if quality >= 2 and quality <= 5:
			_fblit("lk_iq%d" % quality, at + _v(layout["quality"]))
		_label(texts["lblNum"], str(int(rec.count)), at)
		_label(texts["lblItemName"], GarageModel.cap(str(gift.name)), at)
		_fbutton("cv:%d" % k, "lk_convert", at + _v(layout["btnConvert"]))
		_peek_item(icon_rect, material)
		_peek_item(Rect2((at + _v(fresh)) * _f, Vector2(float(fresh[2]), float(fresh[3])) * _f), gift)


func _draw_pager(base: Vector2) -> void :
	if _converts.is_empty():
		return
	var at: Vector2 = base + _v(Atlas.FRAME["numPaging"])
	var pages: int = _pages(_converts.size())
	var count: int = mini(PAGE_BUTTONS, pages)
	for i: int in count:
		var page: int = _page_first + i
		var id: String = "page:%d" % page
		var spot: Vector2 = at + Vector2(34.0 * (i + 1), 0)
		_fblit("lk_page_on" if page == _page else "lk_page", spot + Vector2(1, 1), 0.0, 0.0, _glow(id))
		_hit(id, Rect2(spot * _f, Vector2(26, 26) * _f), false)
		_fwords(str(page + 1), BOLD, 12.0, Color.WHITE, "c", spot, 26.0, 1.0, 26.0)
	if _page > 0:
		_fbutton("prev", "lk_prev", at)
	if _page < pages - 1:
		_fbutton("next", "lk_next", at + Vector2(34.0 * (count + 1), 0))

func _can_peek(rect: Rect2) -> bool:
	if not _tip_ok() or not _sheet_id.is_empty() or not rect.has_point(get_local_mouse_position()):
		return false
	return _hover == "panel"


func _peek_item(rect: Rect2, gift: Dictionary) -> void :
	if not gift.is_empty() and _can_peek(rect):
		var rec: Dictionary = _gift_rec(gift)
		if not rec.is_empty():
			_tip = [rect, "", "", Color.WHITE, rec]
			return
		_tip = [rect, GarageModel.cap(str(gift.name)), str(gift.get("desc", "")), BagModel.tint(int(gift.quality), Color.WHITE)]


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
	if _tip.size() > 4 and _tip[4] is Dictionary:
		FlashTip.show(self, [], _ctip)
		var box: Rect2 = FlashTip.item(self, _tip[4])
		_cover.append(Rect2(box.position * _f, box.size * _f))
		return
	if _tip.is_empty() and FlashTip.show(self, _tip, _ctip):
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
	var rect: Rect2 = Rect2(at * _f, Vector2(wide, high) * _f)
	_cover.append(rect)
	_round(rect, Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 10)


func _draw_confirm() -> void :
	if _pick.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	var box: Vector2 = Vector2(358, 300)
	var at: Vector2 = _centre(box.x, box.y)
	var layout: Dictionary = Atlas.CONFIRM
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_hit("panel", Rect2(at * _f, box * _f), false)
	_fblit("lk_cc_frame", at + _v(layout["frame"]))
	_fbutton("cc_close", "lk_cc_close", at + _v(layout["btnCancel"]))
	_fbutton("cc_dec", "lk_dec", at + _v(layout["btnDec"]))
	_fbutton("cc_add", "lk_add", at + _v(layout["btnAdd"]))
	_fbutton("cc_ok", "lk_ok", at + _v(layout["btnConfirm"]))
	var field: Array = layout["txtBuyNum"]
	var rect: Rect2 = Rect2(at + Vector2(float(field[0]), float(field[1])), Vector2(float(field[2]), float(field[3])))
	_fput(_qty, rect, 20.0, "c")
	_qty.add_theme_color_override("font_color", OK_GOLD)
	_placed.append(_qty)


func _draw_award() -> void :
	_reward.paint(self)
	_cover.append(Rect2(_centre(529.0, 630.0) * _f, Vector2(529, 630) * _f))



func _fly(info: Dictionary) -> void :
	_flies.append_array(RewardFly.begin(self, info))

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

func _tick_award() -> void :
	if _sheet_id == "award" and _reward.tick(self):
		_close_sheet()
