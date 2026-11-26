extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")










const Atlas = preload("tank_convert_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const FairAtlas = preload("fair_atlas.gd")
const AtlasC = preload("fairc_atlas.gd")
const AtlasS = preload("fairs_atlas.gd")
const QuestAtlas = preload("quest_atlas.gd")
const Arena = preload("arena_atlas.gd")
const BarAtlas = preload("approach_tank_atlas.gd")
const RewardPopup = preload("reward_popup.gd")
const RewardFly = preload("reward_fly.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const ShopModel = preload("shop_model.gd")

signal closed(note: String)
signal quick_buy_asked(tid: int)

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const OK_GOLD: Color = Color("fff352")
const SHORT_RED: Color = Color("d70018")
const PATH: String = "/xml/ItemConvertTemplate_table.xml"
const VN: int = 25200
const COINS: Array = ["Xu", "Xu Khóa", "Bạc"]
const AWARD_ROWS: int = 6
const ACT_TYPE: int = 4
const TOKEN_ID: int = 8000005
const DEPTH: int = 4
const BAR: float = 19.0
const PAGE: float = 368.0
const LINE: float = 5.0
const WHEEL_PX: float = 15.0
const REPEAT_DELAY: float = 0.5
const REPEAT_STEP: float = 0.035
const RETRY: float = 5.0
const T_SWAP: String = "Tốn %d xu thay thế %d xu khóa"
const T_SILENT: String = "Chưa đổi được: thiếu nguyên liệu, thiếu Xu hoặc đã có skin này."
const T_UNSENT: String = "Chưa gửi được, hãy thử lại."

var _tank: int = 0
var _state: String = ""
var _raw: Array = []
var _loading: String = ""
var _fetch_at: float = -100.0
var _http: HTTPRequest
var _stale: bool = true
var _mine: Array = []
var _rows: Array = []
var _by_result: Dictionary = {}
var _sig: Array = []
var _counts: Dictionary = {}
var _memo: Dictionary = {}
var _top: float = 0.0
var _bar: Array = []
var _rep_id: String = ""
var _rep_next: float = 0.0
var _rep_skip: bool = false
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_top: float = 0.0
var _list_rect: Rect2 = Rect2()
var _clipper: Control
var _clip_ops: Array = []
var _hole_px: Rect2 = Rect2()
var _sheet_id: String = ""
var _reward: RefCounted = RewardPopup.new()
var _award: Array = []
var _pick: Dictionary = {}
var _amount: int = 1
var _qty: LineEdit
var _placed: Array = []
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _sent_at: float = -10.0
var _note: String = ""
var _note_at: float = 0.0
var _flies: Array = []

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)
	_use(AtlasC.FILE, AtlasC.R)
	_use(FairAtlas.FILE, {"fa_dec": FairAtlas.R["fa_dec"], "fa_add": FairAtlas.R["fa_add"]})
	_use(BarAtlas.FILE, {"apt_sb_bk": BarAtlas.R["apt_sb_bk"], "apt_sb_up": BarAtlas.R["apt_sb_up"], 
		"apt_sb_down": BarAtlas.R["apt_sb_down"], "apt_sb_thumb": BarAtlas.R["apt_sb_thumb"]})
	var shared: Dictionary = {}
	for key: String in Arena.R:
		if key.begins_with("public_"):
			shared[key] = Arena.R[key]
	_use(Arena.FILE, shared)
	var fly: Dictionary = {}
	for key: String in ["qu_fly_gold", "qu_fly_gift"]:
		if QuestAtlas.R.has(key):
			fly[key] = QuestAtlas.R[key]
	_use(QuestAtlas.FILE, fly)
	_qty = _fedit(4, true)
	_qty.text_changed.connect( func(_text: String) -> void : _on_qty_input())
	_qty.text_submitted.connect( func(_text: String) -> void : _confirm_convert())
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_http)
	_clipper = Control.new()
	_clipper.clip_contents = true
	_clipper.show_behind_parent = true
	_clipper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_clipper)
	_clipper.draw.connect(_replay)
	if pack != null:
		pack.picture_ready.connect( func(path: String) -> void :
			if path in ["l/fair.json", "l/bag.json", "l/garage.json", "l/events.json"]:
				_stale = true)
	if client != null:
		client.awarded.connect(_on_award)
		client.noticed.connect( func(text: String) -> void :
			if is_visible_in_tree():
				_note = ""
				say(text))


func open(tank: int) -> void :
	_tank = tank
	_state = str(client.state)
	_top = 0.0
	_bar = []
	_reward.reset()
	_close_sheet()
	_tip = []
	_flies = []
	RewardFly.reset(self)
	_note = ""
	_toast = ""
	_hover = ""
	_press = ""
	_rep_id = ""
	_rep_skip = false
	_grab = false
	_stale = true
	_sig = []
	pack.load_fair()
	pack.load_bag()
	pack.load_garage()
	pack.load_events()
	if not client.bag_loaded:
		client.request_bags()
	visible = true
	_fetch()

func close(note: String = "") -> void :
	if not visible:
		return
	visible = false
	_reward.reset()
	_close_sheet()
	_flies = []
	RewardFly.reset(self)
	_rep_id = ""
	_grab = false
	closed.emit(note)

func chat_busy() -> bool:
	return visible

func tank() -> int:
	return _tank

func rows() -> Array:
	return _rows

func top() -> float:
	return _top

func max_top() -> float:
	var count: int = _rows.size()
	if count == 0:
		return 0.0
	var high: float = count * float(Atlas.ROW[1]) + (count - 1) * float(Atlas.ROW[2])
	return maxf(0.0, high - PAGE)

func _shown() -> void :
	if _qty != null and not is_visible_in_tree():
		_hide_edits()



func _fetch() -> void :
	if not _loading.is_empty() or not _raw.is_empty():
		return
	_fetch_at = _time
	if client.config.local_test_only or str(client.config.origin).is_empty():
		return
	_loading = "xml"
	var url: String = client.config.origin + PATH
	if _http.request(url, AppSession.headers(url)) != OK:
		_loading = ""

func _on_http(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	if _loading != "xml":
		return
	_loading = ""
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		var rows: Array = _xml_rows(body, "entry")
		if not rows.is_empty():
			_raw = rows
			_stale = true


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



func _now() -> int:
	return int(Time.get_unix_time_from_system())

func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))



static func _stamp(text: String) -> int:
	var value: String = text.strip_edges()
	if value.is_empty():
		return 0
	var parts: PackedStringArray = value.replace("T", " ").split(" ", false)
	var day: PackedStringArray = parts[0].split("-")
	if day.size() < 3:
		return 0
	var date: Dictionary = {"year": int(day[0]), "month": int(day[1]), "day": int(day[2]), "hour": 0, "minute": 0, "second": 0}
	var clock: PackedStringArray = parts[1].split(":") if parts.size() > 1 else PackedStringArray()
	var extra: int = 0
	for i in range(mini(3, clock.size())):
		extra += int(clock[i]) * [3600, 60, 1][i]
	return Time.get_unix_time_from_datetime_dict(date) + extra - VN


func _when(text: String) -> int:
	var value: String = text.strip_edges()
	return 0 if value.is_empty() or value == "0" else _stamp(value)


func _build() -> void :
	_stale = false
	_by_result = {}
	_mine = []
	var now: int = _now()
	for row: Dictionary in _raw:
		var begin: int = _when(str(row.get("szBegin", "")))
		var end: int = _when(str(row.get("szEnd", "")))
		if now < begin or (end != 0 and now > end):
			continue
		var result: int = int(row.get("nNewItemId", "0"))
		var items: Array = []
		for slot: int in range(1, 6):
			items.append([int(row.get("nItemId%d" % slot, "0")), int(row.get("iCount%d" % slot, "0"))])
		var rec: Dictionary = {"id": int(row.get("nId", "0")), "type": int(row.get("nType", "0")), "ct": int(row.get("nCoinType", "0")), 
			"price": int(row.get("iPrice", "0")), "max": int(row.get("nConvertMax", "0")), "begin": begin, "end": end, "result": result, 
			"count": maxi(1, int(row.get("nNewItemCount", "1"))), "items": items}
		var key: String = str(result)
		if not _by_result.has(key):
			_by_result[key] = []
		_by_result[key].append(rec)
		var owner: Array = Atlas.TANK_OF.get(key, [])
		if owner.size() < 2 or int(owner[0]) != _tank:
			continue
		rec["kind"] = int(owner[1])
		rec["gift"] = _describe(result, int(rec.count))
		var tiles: Array = []
		for k: int in 3:
			tiles.append(_item(int(items[k][0]), int(items[k][1])) if int(items[k][0]) != 0 else {})
		rec["tiles"] = tiles
		_mine.append(rec)
	_recount()
	_sort_rows()


func _describe(result: int, count: int) -> Dictionary:
	var names: Dictionary = pack.lobby.get("tanks", {})
	var defaults: Dictionary = pack.index.get("tanks", {})
	var skins: Dictionary = pack.garage.get("skin_items", {})
	var gift: Dictionary = _item(result, count)
	var gt: int = 6 if skins.has(str(result)) else (2 if names.has(str(result)) else 4)
	var rec: Dictionary = {"tid": result, "gt": gt}
	if ShopModel.describe(rec, pack.bag, pack.garage, names, defaults):
		if not str(rec.name).is_empty():
			gift.name = str(rec.name)
		var picture: String = str(rec.face) if not str(rec.face).is_empty() else str(rec.icon)
		if not picture.is_empty():
			gift.art = picture
		gift.quality = maxi(int(gift.quality), int(rec.quality))
		if str(gift.desc).is_empty():
			gift.desc = str(rec.desc)
	return gift


func _sort_rows() -> void :
	var ready: Array = []
	var rest: Array = []
	for rec: Dictionary in _mine:
		if _can_rec(rec, 1, 0):
			ready.append(rec)
		else:
			rest.append(rec)
	_rows = ready + rest
	_scroll(_top)

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
	_counts = {}
	_memo = {}
	for cont: Variant in client.bags.keys():
		for inst: Variant in client.bags[cont]:
			if inst is Dictionary:
				var id: int = int(inst.get("m_templateId", 0))
				_counts[id] = int(_counts.get(id, 0)) + maxi(1, int(inst.get("m_count", 1)))

func _have(id: int) -> int:
	return int(_counts.get(id, 0))

func _cash(key: String) -> int:
	return int(client.currency.get(key, 0))


func _wallet(ct: int) -> int:
	if ct == 3:
		return ShopModel.balance(client.currency, 1) + ShopModel.balance(client.currency, 3)
	return ShopModel.balance(client.currency, ct)


func _price_ok(rec: Dictionary) -> bool:
	var price: int = int(rec.price)
	match int(rec.ct):
		1:
			return _cash("m_iCash") >= price
		2:
			return _cash("m_iGolden") >= price
		3:
			return _cash("m_iCash") + _cash("m_iSilver") >= price
	return false


func _can_rec(rec: Dictionary, n: int, depth: int) -> bool:
	var key: String = "%d:%d:%d" % [int(rec.id), n, depth]
	if _memo.has(key):
		return bool(_memo[key])
	var cost: int = int(rec.price) * n
	var ok: bool = false
	match int(rec.ct):
		0:
			ok = true
		1:
			ok = _cash("m_iCash") >= cost
		2:
			ok = _cash("m_iGolden") >= cost
		3:
			ok = _cash("m_iSilver") >= cost
		7:
			ok = _have(TOKEN_ID) >= cost
	if ok:
		for pair: Array in rec.items:
			var need: int = int(pair[1]) * n
			if int(pair[0]) == 0 or need == 0:
				continue
			var have: int = _have(int(pair[0]))
			if have < need and not _can_make(int(pair[0]), need - have, depth + 1):
				ok = false
				break
	_memo[key] = ok
	return ok


func _can_make(id: int, n: int, depth: int) -> bool:
	if depth > DEPTH:
		return false
	for rec: Dictionary in _by_result.get(str(id), []):
		if _can_rec(rec, n, depth):
			return true
	return false


func _has_tank(tank: int) -> bool:
	for inst: Variant in client.tanks.values():
		if inst is Dictionary and int(inst.get("m_tpltId", 0)) == tank and int(inst.get("m_contType", -1)) == GarageModel.OWN:
			return true
	return false


func _has_skin(id: int) -> bool:
	for inst: Variant in client.bags.get(6, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == id and int(inst.get("m_count", 0)) > 0 and int(inst.get("m_lifeTime", 0)) == 0:
			return true
	return false


func _enough(rec: Dictionary) -> bool:
	if int(rec.price) > 0 and not _price_ok(rec):
		return false
	for k: int in 3:
		var pair: Array = rec.items[k]
		if int(pair[0]) != 0 and _have(int(pair[0])) < int(pair[1]):
			return false
	return true


func _convert_state(rec: Dictionary) -> Array:
	if int(rec.type) == ACT_TYPE:
		var now: int = _now()
		if (int(rec.begin) > 0 and int(rec.begin) > now) or (int(rec.end) > 0 and int(rec.end) < now):
			return [false, false]
	return [true, _enough(rec) and not (int(rec.kind) == int(Atlas.TYPES["skin"]) and _has_skin(int(rec.result)))]


func _most(rec: Dictionary) -> int:
	var most: int = 99999999
	if int(rec.price) > 0:
		most = _wallet(int(rec.ct)) / int(rec.price)
	for pair: Array in rec.items:
		if int(pair[0]) != 0 and int(pair[1]) > 0:
			most = mini(most, _have(int(pair[0])) / int(pair[1]))
	if int(rec.kind) == int(Atlas.TYPES["skin"]):
		most = mini(most, 1)
	elif int(rec.max) != 0:
		most = mini(most, int(rec.max))
	return maxi(0, most)




func _convert_do(index: int) -> void :
	if index < 0 or index >= _rows.size():
		return
	var rec: Dictionary = _rows[index]
	var state: Array = _convert_state(rec)
	if not (bool(state[0]) and bool(state[1])):
		return
	var words: Dictionary = Atlas.WORDS
	var kind: int = int(rec.kind)
	if kind == int(Atlas.TYPES["card"]) and _has_tank(_tank):
		say(str(words["TIP_769"]))
		return
	if kind == int(Atlas.TYPES["skin"]):
		if _tank != 0 and not _has_tank(_tank):
			var name_of: String = str(pack.lobby.get("tanks", {}).get(str(_tank), ""))
			say(str(words["CONTROL_TEXT461"]).replace("@name@", name_of).replace("@item@", GarageModel.cap(str(rec.gift.name))))
			return
		if _has_skin(int(rec.result)):
			say(str(words["TIP_285"]))
			return
	_open_confirm(rec)

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
		if ShopModel.balance(client.currency, 3) < int(_pick.price) * _amount:
			_sheet_id = "swap"
			return
	_send_convert()

func _send_convert() -> void :
	var rec: Dictionary = _pick
	var amount: int = _amount
	_close_sheet()
	if _time - _sent_at < 1.0:
		return
	if not client.convert_item(int(rec.id), amount):
		say(T_UNSENT)
		return
	_sent_at = _time
	_note = T_SILENT
	_note_at = _time + 2.0

func _close_sheet() -> void :
	if _sheet_id == "award" and _reward.request_close(self):
		return
	_sheet_id = ""
	_pick = {}
	_award = []
	_hide_edits()

func _on_award(info: Dictionary) -> void :
	if not is_visible_in_tree() or client.award_op in [1, 7, 9, 13, 14, 15, 19, 26, 27, 29, 30]:
		return
	if client.award_show == 0 or client.award_op == 8:
		info = info.duplicate()
		info["fly"] = true
	_show_award(info)

func _show_award(info: Dictionary) -> void :
	var lines: Array = BagModel.award_lines(info, pack.bag)
	if not RewardPopup.has_rewards(info):
		return
	_note = ""
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
	_tip = []

func _scroll(value: float) -> void :
	_top = clampf(roundf(value), 0.0, max_top())

func _step_bar(id: String) -> void :
	_scroll(_top + (LINE if id == "bar:down" else - LINE))

func _tick(_delta: float) -> void :
	_tick_award()
	if not visible:
		return
	if str(client.state) != _state:
		close("")
		return
	if _raw.is_empty() and _loading.is_empty() and _time - _fetch_at >= RETRY:
		_fetch()
	if not _note.is_empty() and _time >= _note_at:
		say(_note)
		_note = ""
	var sig: Array = [client.bag_rev, _cash("m_iCash"), _cash("m_iSilver"), _cash("m_iGolden")]
	if _stale and not _raw.is_empty() and not pack.bag.is_empty() and not pack.garage.is_empty():
		_sig = sig
		_build()
	elif sig != _sig:
		_sig = sig
		_recount()
		_sort_rows()
	if not _rep_id.is_empty():
		if _held and _press == _rep_id and _hit_at(get_local_mouse_position()) == _rep_id:
			if _time >= _rep_next:
				_step_bar(_rep_id)
				_rep_next = maxf(_rep_next + REPEAT_STEP, _time - REPEAT_STEP)
		else:
			_rep_id = ""

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

func _activate(id: String) -> void :
	if not _sheet_id.is_empty():
		_sheet_activate(id)
		return
	if id.begins_with("cv_do:"):
		_convert_do(int(id.substr(6)))
	elif id.begins_with("cv_buy:"):
		quick_buy_asked.emit(int(id.substr(7)))
	else:
		match id:
			"close":
				close("")
			"bar:up", "bar:down":
				if _rep_skip:
					_rep_skip = false
				else:
					_step_bar(id)
			"bar:pgup":
				_scroll(_top - PAGE)
			"bar:pgdn":
				_scroll(_top + PAGE)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _sheet_id.is_empty():
		var id: String = _hit_at(event.position)

		if id in ["bar:up", "bar:down"]:
			_step_bar(id)
			_rep_id = id
			_rep_next = _time + REPEAT_DELAY
			_rep_skip = true
		elif id == "slide:bar" and not _bar.is_empty():
			_grab = true
			_grab_at = event.position
			_grab_top = _top
	elif event is InputEventMouseMotion and _grab:
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_grab = false
		elif not _bar.is_empty():
			var step: float = maxf(0.001, (float(_bar[0]) - float(_bar[1])) / float(_bar[2]))
			_scroll(_grab_top + (event.position.y - _grab_at.y) / _f / step)
			accept_event()
			return
	super (event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_rep_id = ""
		_rep_skip = false
		_grab = false

func _wheel(step: int, at: Vector2) -> void :
	if _sheet_id.is_empty() and _list_rect.has_point(at):
		_scroll(_top + step * WHEEL_PX)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _sheet_id.is_empty() and not _grab and _list_rect.has_point(from):
		_scroll(_top - moved.y / _f)

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
		_:
			return
	get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_ESCAPE:
			close("")
		KEY_UP:
			_scroll(_top - LINE)
		KEY_DOWN:
			_scroll(_top + LINE)
		KEY_PAGEUP:
			_scroll(_top - PAGE)
		KEY_PAGEDOWN:
			_scroll(_top + PAGE)
		KEY_ENTER, KEY_KP_ENTER:
			pass
		_:
			return
	get_viewport().set_input_as_handled()



func _cblit(cell_name: String, at: Vector2, wide: float = 0.0, high: float = 0.0, tint: Color = Color.WHITE) -> Rect2:
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty():
		return Rect2(at * _f, Vector2(wide, high) * _f)
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(wide if wide > 0.0 else float(region[2]), high if high > 0.0 else float(region[3])) * _f)
	if cell[0] != null:
		_clip_ops.append([0, cell[0], rect, Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])), tint])
	return rect

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


func _cfit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 1.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	_cpic(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f))

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
	var top_left: Vector2 = (rect.position * k).round() / k
	var end: Vector2 = (rect.end * k).round() / k
	return Rect2(top_left, end - top_left)


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



func _paint() -> void :
	_tip = []
	_placed = []
	_clip_ops = []
	var o: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	var vb: Array = Atlas.NODES["vbConvert"]
	var hole: Rect2 = Rect2(o + _v(vb), Vector2(float(vb[2]), float(vb[3])))
	_list_rect = Rect2(hole.position * _f, hole.size * _f)
	_hole_px = _snap(_list_rect)
	if _clipper.position != _hole_px.position or _clipper.size != _hole_px.size:
		_clipper.position = _hole_px.position
		_clipper.size = _hole_px.size
	var full: Rect2 = Rect2(Vector2.ZERO, size)
	for strip: Rect2 in _strips(full, _hole_px):
		draw_rect(strip, DIM)
	_crect(full, DIM)
	_hit("shade", full, false)
	_draw_frame(o)
	_hit("panel", Rect2(o * _f, Vector2(float(Atlas.SIZE[0]), float(Atlas.SIZE[1])) * _f), false)
	var pitch: float = float(Atlas.ROW[1]) + float(Atlas.ROW[2])
	for index: int in _rows.size():
		var y: float = index * pitch - _top
		if y + float(Atlas.ROW[1]) <= 0.0 or y >= PAGE:
			continue
		_draw_cell(hole.position + Vector2(0, y), _rows[index], index)
	_draw_bar(o + Vector2(float(vb[0]) + float(vb[2]) - BAR, float(vb[1])), PAGE - 2.0 * BAR)
	_fbutton("close", "tcv_close", o + _v(Atlas.NODES["btnClose"]))
	match _sheet_id:
		"award":
			_draw_award()
		"confirm":
			_draw_confirm(true)
		"swap":
			_draw_confirm(false)
			_draw_swap()
		_:
			_draw_tip()
	_draw_flies()
	_clipper.visible = _sheet_id != "award"
	_clipper.queue_redraw()
	if _qty.visible and not _qty in _placed:
		_qty.visible = false
		_qty.release_focus()


func _draw_frame(o: Vector2) -> void :
	var cell: Array = _cells.get("tcv_frame", [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var panel: Rect2 = Rect2((o + _v(Atlas.FRAME_AT)) * _f, Vector2(float(region[2]), float(region[3])) * _f)
	var origin: Vector2 = Vector2(float(region[0]), float(region[1]))
	for strip: Rect2 in _strips(panel, _hole_px):
		draw_texture_rect_region(cell[0], strip, Rect2(origin + (strip.position - panel.position) / _f, strip.size / _f))
	_clip_ops.append([0, cell[0], panel, Rect2(origin, Vector2(float(region[2]), float(region[3]))), Color.WHITE])


func _draw_cell(at: Vector2, rec: Dictionary, index: int) -> void :
	_cblit("fa_cv_cell", at)
	var tiles: Array = AtlasC.CELL["tiles"]
	var slot: int = 0
	if int(rec.price) > 0:
		var coin: Dictionary = _coin(ShopModel.coin_index(int(rec.ct)), int(rec.price))
		_draw_tile(at + _v(tiles[0]), coin, str(int(rec.price)), Color.WHITE if _price_ok(rec) else SHORT_RED, false, "")
		slot += 1
	for k: int in 3:
		var pair: Array = rec.items[k]
		if int(pair[0]) != 0 and slot < tiles.size():
			var have: int = _have(int(pair[0]))
			var short: bool = have < int(pair[1]) and _can_make(int(pair[0]), 1, 1)
			_draw_tile(at + _v(tiles[slot]), rec.tiles[k], "%d/%d" % [have, int(pair[1])], Color.WHITE, short, "")
		slot += 1
	_draw_reward(at + _v(AtlasC.CELL["reward"]), rec.gift)
	_draw_convert_button(at + _v(AtlasC.CELL["button"]), rec, index)
	_buy_hit(at, rec)


func _draw_tile(at: Vector2, gift: Dictionary, number: String, color: Color, short: bool, id: String) -> void :
	var rect: Rect2 = _cblit("fa_cv_tile", at + Vector2(4, 0))
	var quality: int = int(gift.get("quality", 1))
	if quality >= 2 and quality <= 5:
		_cblit("fa_iq%d" % quality, at + Vector2(10, 6))
	_cfit(_gift_art(gift), at + Vector2(12, 10), Vector2(52, 49), 1.0)
	_cwords(number, BOLD, 12.0, color, "c", at + Vector2(-5, 63), 85.0)
	if short:
		_cblit("fa_cv_tip", at + Vector2(54, 1))
	_peek_item(rect, gift, id)


func _draw_reward(at: Vector2, gift: Dictionary) -> void :
	var rect: Rect2 = _cblit("fa_cv_reward", at)
	_cfit(_gift_art(gift), at + Vector2(4, 4), Vector2(76, 76), 1.0)
	if int(gift.count) > 1:
		_cwords(str(int(gift.count)), BOLD, 12.0, Color.WHITE, "r", at + Vector2(7, 59), 70.0)
	_cwords(GarageModel.cap(str(gift.name)), BOLD, 12.0, BagModel.tint(int(gift.quality), Color.WHITE), "c", at + Vector2(-18, 79), 120.0)
	_peek_item(rect, gift, "")

func _draw_convert_button(at: Vector2, rec: Dictionary, index: int) -> void :
	var state: Array = _convert_state(rec)
	if not bool(state[0]):
		return
	if bool(state[1]):
		var id: String = "cv_do:%d" % index
		_chit(id, _cblit("fa_cv_btn", at, 0.0, 0.0, _glow(id)))
	else:
		_cblit("fa_cv_btn_off", at)


static func can_buy(tid: int) -> bool:
	var ids: Array = AtlasS.CAN_BUY
	var at: int = ids.bsearch(tid)
	return at < ids.size() and int(ids[at]) == tid


func _buy_hit(at: Vector2, rec: Dictionary) -> void :
	var tid: int = 0
	for k: int in 3:
		var id: int = int(rec.items[k][0])
		if id != 0 and can_buy(id):
			tid = id
	if tid != 0:
		_chit("cv_buy:%d" % tid, Rect2(at * _f, Vector2(80, 33) * _f))


func _draw_bar(at: Vector2, track: float) -> void :
	_bar = []
	var most: float = max_top()
	if most <= 0.0:
		return
	_fblit("apt_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("bar:up", "apt_sb_up", at)
	_fbutton("bar:down", "apt_sb_down", at + Vector2(0, BAR + track))
	var thumb: float = maxf(20.0, track * PAGE / (most + PAGE))
	var y: float = at.y + BAR + (track - thumb) * clampf(_top / most, 0.0, 1.0)
	_hit("bar:pgup", Rect2(Vector2(at.x, at.y + BAR) * _f, Vector2(BAR, y - at.y - BAR) * _f), false)
	_hit("bar:pgdn", Rect2(Vector2(at.x, y + thumb) * _f, Vector2(BAR, at.y + BAR + track - y - thumb) * _f), false)
	_fslice("apt_sb_thumb", Vector2(at.x, y), thumb, 4.0, _glow("slide:bar"))
	_hit("slide:bar", Rect2(Vector2(at.x, y) * _f, Vector2(BAR, thumb) * _f), false)
	_bar = [track, thumb, most]


func _fslice(cell_name: String, at: Vector2, high: float, cap: float, tint: Color) -> void :
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


func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false)

func _gift_art(gift: Dictionary) -> Texture2D:
	var path: String = str(gift.get("art", ""))
	return pack.picture(path) if not path.is_empty() else null

func _can_peek(rect: Rect2, id: String) -> bool:
	if not _tip_ok() or not _sheet_id.is_empty():
		return false
	var mouse: Vector2 = get_local_mouse_position()
	if not rect.has_point(mouse) or not _hole_px.has_point(mouse):
		return false
	return _hover == "panel" or ( not id.is_empty() and _hover == id)


func _peek_item(rect: Rect2, gift: Dictionary, id: String) -> void :
	if not gift.is_empty() and _can_peek(rect, id):
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
		_fput(_qty, rect, 20.0, "c")
		_placed.append(_qty)
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

func _draw_award() -> void :
	_reward.paint(self)



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
