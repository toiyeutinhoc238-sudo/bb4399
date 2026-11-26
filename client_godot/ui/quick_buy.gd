extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")














const ShopModel = preload("shop_model.gd")
const GarageModel = preload("garage_model.gd")
const Shop = preload("shop_atlas.gd")
const Arena = preload("arena_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Atlas = preload("quickbuy_atlas.gd")
const ShopRecommend = preload("shop_recommend.gd")
const FriendPick = preload("friend_pick.gd")
const Mysterious = preload("mysterious_store.gd")

signal closed
signal gold_access_asked

const WAIT: float = 8.0
const REPEAT_DELAY: float = 0.5
const REPEAT_STEP: float = 0.035
const MAX_COUNT: int = 999
const CAN_BUY: Color = Color("fff352")
const NO_ENOUGH: Color = Color("ff0000")
const NO_ENOUGH_RIM: Color = Color(0.424, 0.051, 0.051, 0.8)
const DIM: Color = Color("aab3b3")
const FRAME: Vector2 = Vector2(136, 274)
const ALLOWED: Array = ["lobby", "hall", "room"]


const GOLD_ONLY: int = 1
const CASH_ONLY: int = 2
const CASH_GIFT_MIX: int = 3
const PVP_COIN_ONLY: int = 4
const GIFT_ONLY: int = 5
const PVP_STATES: Array = ["cashGiftPvp", "pvpCoin", "cashPvp", "giftPvp"]

const TIP_417: String = "Chưa bán"
const TIP_79: String = "Xu không đủ, hãy nạp tiền"
const TIP_286: String = "không đủ @num1@Lv, không thể mua"
const TIP_425: String = "Thiếu Bạc, thi đấu Đấu So Tài hoặc Đấu Xếp Hạng nhận Bạc."
const BOUGHT: String = "Mua thành công"
const NO_REPLY: String = "Máy chủ chưa phản hồi, thử lại sau."
const TIP_40: String = "Chọn đối tượng tặng trước"
const TIP_93: String = "Không thể tự tặng bản thân"
const PRESENTED: int = 5



const ROW_CASH: Array = [["bg", 32, 3], ["icon", 1, 42, 5], ["name", "Xu", 65, 7], ["val", "cash", 106, 7]]
const ROW_GIFT: Array = [["bg", 32, 33], ["icon", 3, 42, 35], ["name", "Xu Khóa", 65, 37], ["val", "gift", 106, 37]]
const LAYOUT: Dictionary = {
	"": [ROW_CASH, ROW_GIFT, [["bg", 32, 63], ["icon", 2, 42, 65], ["name", "Bạc", 65, 67], ["val", "second", 106, 66]], 
		[["radio", "pay:cash", 4, 1], ["radio", "pay:gold", 4, 61]]], 
	"present": [ROW_CASH], 
	"goldOnly": [[["bg", 32, 3], ["icon", 2, 42, 5], ["name", "Bạc", 65, 7], ["val", "second", 106, 6]]], 
	"cashGift": [ROW_CASH, ROW_GIFT], 
	"cashGold": [ROW_CASH, [["bg", 32, 33], ["icon", 2, 42, 35], ["name", "Bạc", 65, 37], ["val", "second", 106, 35]], 
		[["radio", "pay:cash", 4, 1], ["radio", "pay:gold", 4, 32]]], 
	"pvpCoin": [[["bg", 32, 3], ["icon", 0, 40, 2], ["name", "", 67, 5], ["val", "second", 106, 5]]], 
	"giftPvp": [[["bg", 32, 3], ["icon", 3, 42, 5], ["name", "Xu Khóa", 65, 7], ["val", "gift", 106, 7]], 
		[["bg", 32, 33], ["icon", 0, 42, 32], ["name", "", 67, 37], ["val", "second", 106, 35]], 
		[["radio", "pay:cash", 4, 1], ["radio", "pay:gold", 4, 32]]], 
	"cashPvp": [ROW_CASH, [["bg", 32, 33], ["icon", 0, 38, 34], ["name", "", 67, 37], ["val", "second", 106, 35]], 
		[["radio", "pay:cash", 4, 1], ["radio", "pay:gold", 4, 32]]], 
	"cashGiftPvp": [ROW_CASH, ROW_GIFT, [["bg", 32, 63], ["icon", 0, 42, 62], ["name", "", 67, 67], ["val", "second", 106, 66]], 
		[["radio", "pay:cash", 4, 1], ["radio", "pay:gold", 4, 61]]], 
}

var fetch: Callable
var _http: HTTPRequest
var _asking: bool = false
var _ask: Dictionary = {}
var _rec: Dictionary = {}
var _wait_bag: bool = false
var _open: bool = false
var _recommend: bool = false
var _index: int = 0
var _rows: Array = []
var _enable: int = MAX_COUNT
var _cash_radio: bool = true
var _count: LineEdit
var _focus: LineEdit
var _pending: Dictionary = {}
var _told_at: float = -10.0
var _rep_id: String = ""
var _rep_next: float = 0.0
var _rep_skip: bool = false
var _present: bool = false
var _friend: LineEdit
var _pick = FriendPick.new()
var _gift: Dictionary = {}

func chat_busy() -> bool:
	return _open

func _setup() -> void :
	mouse_filter = MOUSE_FILTER_IGNORE
	_count = _fedit(5, true)
	_count.add_theme_color_override("font_color", CAN_BUY)
	_count.add_theme_color_override("font_uneditable_color", CAN_BUY)
	_count.text_changed.connect( func(_text: String) -> void : _on_count_input())
	_count.text_submitted.connect( func(_text: String) -> void : _present_send() if _present else _confirm())
	_friend = _name_fedit()
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_query)
	if pack != null:
		pack.picture_ready.connect( func(path: String) -> void :
			if path == "l/bag.json" and _wait_bag:
				_wait_bag = false
				_show_row())
	if client != null:
		client.bought.connect(_on_bought)
		client.noticed.connect( func(_text: String) -> void :

			if not _pending.is_empty() or not _gift.is_empty() or _time - _toast_at < 1.0:
				_told_at = _time
				if _toast.begins_with("Chưa mua được"):
					_toast = "")

func _shown() -> void :
	if not is_visible_in_tree():
		_hide_edits()
		_open = false
		_rep_id = ""
		_pick.close()
		mouse_filter = MOUSE_FILTER_IGNORE



func ask(tid: int, kind: int = ShopModel.BUY, count: int = 1, present: bool = true) -> bool:
	if client == null or pack == null or tid <= 0 or client.state not in ALLOWED or _asking or _open:
		return false
	_ask = {"tid": tid, "kind": kind, "count": maxi(1, count), "present": present}
	_rec = {}
	_wait_bag = false
	var url: String = client.config.origin + "/goodsshopquickquery.php?tid=%d&char=%s&noCache=%d" % [tid, client.char_uuid.uri_encode(), randi() % 1000000]
	_asking = true
	visible = true
	if fetch.is_valid():
		fetch.call(url)
		return true
	_http.cancel_request()
	if _http.request(url, AppSession.headers(url)) != OK:
		_asking = false
		say(NO_REPLY)
		return false
	return true



func mystic(tank: int, msbt: int, item: int, ori: int, disc: int) -> bool:
	if client == null or pack == null or item <= 0 or tank <= 0 or client.state not in ALLOWED or _asking or _open:
		return false
	_ask = {"tid": item, "kind": ShopModel.BUY, "count": 1, "present": false, "mystic": [tank, msbt]}
	_rec = {"gid": item, "gt": 1, "tid": item, "lv": 0, "vip": 0, "cnt": [0, 0, 0], "ct": 1, "ct2": 0, "p": [ori, 0, 0], "p2": [0, 0, 0], 
		"a": [disc, 0, 0], "a2": [0, 0, 0], "agio": true, "cash_only": true, "limit": 1, "bought": 0, "token": 0, "reuse_d": 0}
	_wait_bag = false
	visible = true
	if pack.bag.is_empty() and not pack.base.is_empty():
		_wait_bag = true
		pack.load_bag()
		return true
	_show_row()
	return true

func _on_query(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_asking = false
	if _ask.is_empty() or client.state not in ALLOWED:
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty():
		say(NO_REPLY)
		return
	var row: Dictionary = parse_last(body)
	if row.is_empty():
		say(TIP_417)
		return
	_rec = row
	if pack.bag.is_empty() and not pack.base.is_empty():
		_wait_bag = true
		pack.load_bag()
		return
	_show_row()



static func parse_last(body: PackedByteArray) -> Dictionary:
	var parser: XMLParser = XMLParser.new()
	if body.is_empty() or parser.open_buffer(body) != OK:
		return {}
	var last: Dictionary = {}
	while parser.read() == OK:
		if parser.get_node_type() != XMLParser.NODE_ELEMENT or parser.get_node_name() != "row":
			continue
		var a: Dictionary = {}
		for i in range(parser.get_attribute_count()):
			a[parser.get_attribute_name(i).strip_edges()] = parser.get_attribute_value(i).strip_edges()
		var n: Callable = func(key: String) -> int: return int(str(a.get(key, "0")))
		var rec: Dictionary = {"gid": n.call("goods_id"), "gt": n.call("goods_type"), "tid": n.call("template_oid"), 
			"lv": n.call("limit_level"), "vip": n.call("vip_level"), "cnt": [n.call("count_1"), n.call("count_2"), n.call("count_3")], 
			"ct": n.call("coin_type"), "ct2": n.call("coin_type2"), 
			"p": [n.call("price1"), n.call("price2"), n.call("price3")], 
			"p2": [n.call("price2_1"), n.call("price2_2"), n.call("price2_3")], 
			"a": [n.call("agio_price1"), n.call("agio_price2"), n.call("agio_price3")], 
			"a2": [n.call("agio_price2_1"), n.call("agio_price2_2"), n.call("agio_price2_3")], 
			"agio": n.call("is_agio") == 1, "cash_only": n.call("can_use_gift") == 0, 
			"limit": n.call("char_limit_count"), "bought": n.call("char_count"), "token": n.call("token_itemid")}
		if int(rec.gid) > 0:
			last = rec
	return last

func _show_row() -> void :
	if _rec.is_empty() or client.state not in ALLOWED:
		return
	if not ShopModel.describe(_rec, pack.bag, pack.garage, pack.lobby.get("tanks", {}), pack.index.get("tanks", {})):
		say(TIP_417 if not pack.bag.is_empty() else NO_REPLY)
		_rec = {}
		return
	_enable = maxi(1, int(_rec.limit) - int(_rec.bought)) if int(_rec.limit) > 0 else MAX_COUNT
	_recommend = ShopRecommend.active(_rec)
	_rows = ShopRecommend.rows(_rec, str(ShopModel.COIN_NAME[ShopModel.coin_index(int(_rec.ct))])) if _recommend else []
	_index = ShopRecommend.initial(_rec, int(_ask.count), _rows) if _recommend else 0
	_cash_radio = true
	_present = false
	_friend.text = ""
	_pick.close()
	_gift = {}
	_open = true
	mouse_filter = MOUSE_FILTER_STOP
	_count.text = ""
	_set_count(int(_ask.count))
	if _recommend and ShopRecommend.resets(_rec, int(_ask.count)):
		_set_count(1)
	_focus = _count

func close() -> void :
	_close()

func _close() -> void :
	var was: bool = _open
	_open = false
	_focus = null
	_rep_id = ""
	_pick.close()
	_hide_edits()
	mouse_filter = MOUSE_FILTER_IGNORE
	if was:
		closed.emit()

func _numbered() -> bool:
	return int(_rec.get("gt", 0)) != 6

func _amount() -> int:
	return clampi(int(_count.text), 0, MAX_COUNT)


func _set_count(value: int) -> void :
	var text: String = str(clampi(value, 1, _enable))
	if _count.text != text:
		_count.text = text
		_count.caret_column = text.length()


func _on_count_input() -> void :
	var text: String = _count.text
	if text.is_empty() or text.substr(0, 1) < "1":
		_count.text = "1"
		_count.caret_column = 1
	_set_count(int(_count.text))


static func needs(rec: Dictionary, amount: int, index: int) -> Array:
	var need: int = int((rec.a if rec.agio else rec.p)[index]) * amount
	if int(rec.ct2) == 0:
		match int(rec.ct):
			2:
				return ["goldOnly", 0, need, 0]
			7:
				return ["pvpCoin", 0, 0, need]
			_:
				return ["present" if rec.cash_only else "cashGift", need, 0, 0]
	var need2: int = int((rec.a2 if rec.agio else rec.p2)[index]) * amount
	match int(rec.ct2):
		2:
			return ["cashGold" if rec.cash_only else "", need, need2, 0]
		7:
			if int(rec.ct) == 3:
				return ["giftPvp", need, 0, need2]
			return ["cashPvp" if rec.cash_only else "cashGiftPvp", need, 0, need2]
	return ["", 0, 0, 0]


static func pay_type(state: String, cash_radio: bool) -> int:
	match state:
		"goldOnly":
			return GOLD_ONLY
		"present":
			return CASH_ONLY
		"cashGift":
			return CASH_GIFT_MIX
		"pvpCoin":
			return PVP_COIN_ONLY
		"cashGiftPvp":
			return CASH_GIFT_MIX if cash_radio else PVP_COIN_ONLY
		"giftPvp":
			return GIFT_ONLY if cash_radio else PVP_COIN_ONLY
		"cashGold":
			return CASH_ONLY if cash_radio else GOLD_ONLY
		"cashPvp":
			return CASH_ONLY if cash_radio else PVP_COIN_ONLY
	return CASH_GIFT_MIX if cash_radio else GOLD_ONLY


static func coin_type(state: String, cash_radio: bool) -> int:
	match state:
		"goldOnly":
			return 2
		"pvpCoin":
			return 7
		"present", "cashGift":
			return 1
		"cashGiftPvp", "cashPvp":
			return 1 if cash_radio else 7
		"giftPvp":
			return 3 if cash_radio else 7
	return 1 if cash_radio else 2



static func plan(state: String, cash_radio: bool, need_cash: int, need_gold: int, need_pvp: int, bal: Dictionary) -> Dictionary:
	var text: Dictionary = {"cash": 0, "gift": 0, "second": need_pvp if state in PVP_STATES else need_gold}
	var on: Dictionary = {"cash": false, "gift": false, "second": false}
	var gift: int = int(bal.get("gift", 0))
	if state == "giftPvp":
		text.gift = need_cash
	else:
		var rest: int = need_cash - gift
		if rest > 0:
			text.gift = gift
		else:
			rest = 0
			text.gift = need_cash
		text.cash = rest
	var pay: int = pay_type(state, cash_radio)
	var bill: Dictionary = {"temp": 0, "text": text, "on": on, "list": []}
	match pay:
		GOLD_ONLY:
			bill.temp = need_gold
			_spend(bill, "second", int(bal.get("gold", 0)), 2)
		CASH_ONLY:
			bill.temp = need_cash
			_spend(bill, "cash", int(bal.get("cash", 0)), 1)
		PVP_COIN_ONLY:
			bill.temp = need_pvp
			_spend(bill, "second", int(bal.get("token", 0)), 7)
		CASH_GIFT_MIX:
			bill.temp = need_cash if cash_radio else need_gold
			_spend_gift(bill, gift)
			_spend(bill, "cash", int(bal.get("cash", 0)), 1)
		GIFT_ONLY:
			bill.temp = need_cash if cash_radio else need_gold
			_spend_gift(bill, gift)
	var temp: int = int(bill.temp)
	var red: Dictionary = {"cash": false, "gift": false, "second": false}
	if temp > 0:
		match pay:
			GOLD_ONLY, PVP_COIN_ONLY:
				red.second = true
			CASH_ONLY:
				red.cash = true
			CASH_GIFT_MIX:
				red.cash = true
				red.gift = true
			GIFT_ONLY:
				red.gift = true
	return {"pay": pay, "coin": coin_type(state, cash_radio), "text": text, "on": on, "red": red, "list": bill.list, "enough": temp <= 0}


static func _spend(bill: Dictionary, key: String, have: int, coin: int) -> void :
	bill.on[key] = true
	var shown: int = int(bill.temp)
	if have >= shown:
		bill.temp = 0
	bill.text[key] = shown
	if int(bill.temp) <= 0 and shown > 0:
		bill.list.append([coin, shown])


static func _spend_gift(bill: Dictionary, gift: int) -> void :
	bill.on.gift = true
	var used: int = gift
	if used < int(bill.temp):
		bill.temp = int(bill.temp) - used
	else:
		used = int(bill.temp)
		bill.temp = 0
	bill.text.gift = used
	if used > 0:
		bill.list.append([3, used])

func _balance() -> Dictionary:
	var money: Dictionary = client.currency
	return {"cash": int(money.get("m_iCash", 0)), "gift": int(money.get("m_iSilver", 0)), "gold": int(money.get("m_iGolden", 0)), 
		"token": 0}


func _can_present() -> bool:
	return bool(_ask.get("present", true)) and int(_rec.get("ct", 0)) == 1

func _quote() -> Array:
	var need: Array = needs(_rec, _amount(), _index)
	if _present:
		need = ["present", int((_rec.a if _rec.agio else _rec.p)[_index]) * _amount(), 0, 0]
	return [need, plan(str(need[0]), _cash_radio, int(need[1]), int(need[2]), int(need[3]), _balance())]


func _single_price(coin: int) -> int:
	if coin == int(_rec.ct):
		return int((_rec.a if _rec.agio else _rec.p)[_index])
	return int((_rec.a2 if _rec.agio else _rec.p2)[_index])


func _confirm() -> void :
	if not _open or _rec.is_empty():
		return
	var quote: Array = _quote()
	var bill: Dictionary = quote[1]
	if not bill.enough:
		if int(bill.pay) == PVP_COIN_ONLY:
			gold_access_asked.emit()
		else:
			say(TIP_79)
		return
	for pair: Array in bill.list:
		if int(pair[0]) == 2 and int(pair[1]) != 0 and int(_rec.lv) > int(client.character.get("level", 0)):
			say(TIP_286.replace("@num1@", str(int(_rec.lv))))
			return
	var coin: int = int(bill.coin)
	var name: String = GarageModel.cap(str(_rec.get("name", "")))
	var gid: int = int(_rec.gid)
	var sent: bool
	if _ask.has("mystic"):
		sent = client.buy_mystical(int(_ask.mystic[0]), int(_ask.mystic[1]))
	else:
		sent = client.buy_goods_vec(int(_ask.kind), gid, coin, _single_price(coin), maxi(1, _amount()), bill.list)
	_close()
	if sent:
		_pending = {"gid": gid, "name": name, "at": _time}
	else:
		say("Chưa mua được lúc này.")


func _present_send() -> void :
	if not _open or _rec.is_empty() or not _present or not _gift.is_empty():
		return
	var name: String = _friend.text.strip_edges()
	if name.is_empty():
		say(TIP_40)
		return
	if not bool(_quote()[1].enough):
		say(TIP_79)
		return
	if name == str(client.character.get("name", client.account.get("name", ""))):
		say(TIP_93)
		return
	var gid: int = int(_rec.gid)
	if client.present_goods(gid, _single_price(1), maxi(1, _amount()), name):
		_gift = {"gid": gid, "name": name, "at": _time}
	else:
		say("Chưa tặng được lúc này.")

func _on_bought(ok: bool, goods: int) -> void :
	if not _gift.is_empty() and ( not ok or goods == 0 or goods == int(_gift.gid)):
		var asked: float = float(_gift.at)
		_gift = {}
		if ok and client.bought_kind == PRESENTED:
			_close()
		elif not ok and _told_at < asked:
			say("Chưa tặng được.")
		return
	if _pending.is_empty() or (ok and goods != 0 and goods != int(_pending.gid)):
		return
	var name: String = str(_pending.name)
	var asked: float = float(_pending.at)
	_pending = {}
	if ok:
		say(BOUGHT)
		if not client.bag_loaded:
			client.request_bags()
	elif _told_at < asked:
		say("Chưa mua được %s." % name)

func _tick(_delta: float) -> void :
	if (_open or _asking or _wait_bag) and client.state not in ALLOWED:
		_asking = false
		_wait_bag = false
		_ask = {}
		_close()
	if not _pending.is_empty() and _time - float(_pending.at) > WAIT:
		_pending = {}
		say(NO_REPLY)
	if not _gift.is_empty() and _time - float(_gift.at) > WAIT:
		_gift = {}
		say(NO_REPLY)
	if _open and not _rep_id.is_empty():
		if _held and _press == _rep_id and _hit_at(get_local_mouse_position()) == _rep_id:
			if _time >= _rep_next:
				_step(_rep_id)
				_rep_next = maxf(_rep_next + REPEAT_STEP, _time - REPEAT_STEP)
		else:
			_rep_id = ""
	if not _open and not _asking and not _wait_bag and _pending.is_empty() and _gift.is_empty() and _time - _toast_at > 2.7 and visible:
		visible = false

func _step(id: String) -> void :
	_set_count(_amount() + (1 if id == "more" else -1))



func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Hall.FILE, Hall.R)
		_use(Shop.FILE, Shop.R)
		_use(Atlas.FILE, Atlas.R)
		FriendPick.cells(self)
	if not _open or _rec.is_empty():
		_hide_edits()
		return
	var at: Vector2 = _window(398.0, 498.0)
	_fmid("shop_title_confirmpaygood", at + Vector2(0, 19), 398.0)

	var cell: Vector2 = at + Vector2(23.0 if _recommend else 123.0, 58)
	_fblit("shop_goodscell_bk", cell)
	_fit(_icon(), cell + Vector2(27, 26), Vector2(100, 100))
	_fwords(GarageModel.cap(str(_rec.get("name", ""))), BOLD, 16.0, Color.WHITE, "c", cell + Vector2(-14, 148), 180.0, 1.5, 22.0)
	if _numbered():
		_fblit("shop_title_buynum", at + Vector2(36, 237))
		_fbutton("less", "shop_num_minus", at + Vector2(173, 236))
		_fblit("shop_input_bk_ss", at + Vector2(203, 230))
		_fput(_count, Rect2(at + Vector2(223, 233), Vector2(60, 30)), 20.0, "c")
		_fbutton("more", "public_button_num_plus", at + Vector2(307, 236))
	else:
		_hide_edits()
	if _recommend:
		_draw_recommend(at + ShopRecommend.FRAME)
	_fblit("shop_title_pay", at + Vector2(36, 279))
	_draw_pay(at + FRAME)
	_fblit("shop_word_consume_tips", at + Vector2(170, 368))
	if _can_present():
		_fbutton("present", "public_checkbox_checked" if _present else "public_checkbox_bk", at + Vector2(44, 395))
		_hit("present", _fblit("qb_present", at + Vector2(71, 399)), false)
		_fblit("qb_friend_bk", at + Vector2(136, 391))
		_fput(_friend, Rect2(at + Vector2(142, 395), Vector2(198, 27)), 16.0)
		_fbutton("friend", "qb_findfriend", at + Vector2(346, 398))
	else:
		_present = false
	if _present:
		_draw_ok(at + Vector2(139, 446), "gift", "qb_confirmpresent")
	else:
		_draw_ok(at + Vector2(139, 446))
	if _pick.open:
		_pick.draw(self, at + Vector2(398, 391 - FriendPick.ChatFriend.SIZE.y))
	if _focus != null and _focus.visible:
		_focus.grab_focus.call_deferred()
		_focus.select_all.call_deferred()
		_focus = null


func _draw_pay(base: Vector2) -> void :
	var quote: Array = _quote()
	var state: String = str(quote[0][0])
	var bill: Dictionary = quote[1]
	for row: Array in LAYOUT.get(state, LAYOUT[""]):
		for part: Array in row:
			var spot: Vector2 = base + Vector2(float(part[-2]), float(part[-1]))
			match str(part[0]):
				"bg":
					_fblit("shop_label200", spot)
				"icon":
					if int(part[1]) == 0:
						_fit(_token_icon(), spot, Vector2(24, 24), 1.0)
					else:
						_fblit(str(Shop.COINS[ShopModel.coin_index(int(part[1]))][1]), spot)
				"name":
					var label: String = str(part[1]) if not str(part[1]).is_empty() else _token_name()
					_fwords(label, BOLD, 14.0, Color.WHITE, "l", spot, 87.0, 1.0)
				"val":
					var key: String = str(part[1])
					var tint: Color = (NO_ENOUGH if bill.red[key] else CAN_BUY) if bill.on[key] else DIM
					var rim: Color = NO_ENOUGH_RIM if bill.on[key] and bill.red[key] else SHADE
					_fwords(Mysterious.comma(int(bill.text[key])), BOLD, 14.0, tint, "r", spot, 120.0, 1.5 if bill.red[key] else 1.0, 0.0, true, rim)
				"radio":
					var id: String = str(part[1])
					var chosen: bool = _cash_radio == (id == "pay:cash")
					_fbutton(id, "shop_radio_sel" if chosen else "shop_radio", spot)


func _draw_recommend(base: Vector2) -> void :
	for row: Dictionary in _rows:
		var k: int = int(row.k)
		var id: String = "pick:%d" % k
		var spot: Vector2 = base + Vector2(4, float(ShopRecommend.RADIO_Y[k]))
		_fbutton(id, "shop_radio_sel" if k == _index else "shop_radio", spot)
		_hit(id, Rect2(spot * _f, Vector2(ShopRecommend.LABEL_X - 4.0 + ShopRecommend.LABEL_WIDE, 26) * _f), false)
		_fwords(str(row.text), BOLD, 14.0, Color.WHITE, "l", base + Vector2(ShopRecommend.LABEL_X, float(ShopRecommend.LABEL_Y[k])), ShopRecommend.LABEL_WIDE)
		if not str(row.agio).is_empty():
			_fwords(str(row.agio), BOLD, 12.0, ShopRecommend.AGIO, "r", base + Vector2(0, float(ShopRecommend.AGIO_Y[k])), ShopRecommend.WIDE)


func _draw_ok(at: Vector2, id: String = "ok", word: String = "shop_title_confirmpay") -> void :
	var lit: Color = _glow(id)
	_hit(id, _fblit("shop_button_red", at, 0.0, 0.0, lit), false)
	_fblit(word, at + ((Vector2(120, 35) - _cell_size(word)) / 2.0).round(), 0.0, 0.0, lit)


func _icon() -> Texture2D:
	var path: String = str(_rec.get("icon", ""))
	for key: String in ["art", "face"]:
		if path.is_empty():
			path = str(_rec.get(key, ""))
	return pack.picture(path) if not path.is_empty() else null

func _token_row() -> Array:
	var tid: int = int(_rec.get("token", 0))
	return pack.bag.get("items", {}).get(str(tid), []) if tid > 0 else []

func _token_name() -> String:
	var row: Array = _token_row()
	return GarageModel.cap(str(row[0])) if row.size() >= 10 else ""

func _token_icon() -> Texture2D:
	var row: Array = _token_row()
	return pack.picture("l/it/%s.webp" % str(row[2])) if row.size() >= 10 and not str(row[2]).is_empty() else null


func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false)



func _gui_input(event: InputEvent) -> void :

	if _open and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var id: String = _hit_at(event.position)
		if id in ["less", "more"] and _numbered():
			_step(id)
			_rep_id = id
			_rep_next = _time + REPEAT_DELAY
			_rep_skip = true
	super (event)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_rep_id = ""
		_rep_skip = false

func _input(event: InputEvent) -> void :
	if _open and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if _open and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()

func _wheel(step: int, at: Vector2) -> void :
	if _open:
		_pick.wheel(step, at)

func _drag(moved: Vector2, from: Vector2) -> void :
	if _open:
		_pick.drag(moved, from, _mobile, _f)

func _activate(id: String) -> void :
	if not _open:
		return
	var picked: Array = _pick.activate(id)
	if bool(picked[0]):
		if not str(picked[1]).is_empty():
			_friend.text = str(picked[1])
			_friend.caret_column = _friend.text.length()
		return
	if id.begins_with("pay:"):
		_cash_radio = id == "pay:cash"
		return
	if id.begins_with("pick:"):
		var k: int = int(id.substr(5))
		if _recommend and ShopRecommend.has_row(_rows, k):
			_index = k
			if not ShopRecommend.skin(_rec):
				_set_count(1)
		return
	match id:
		"cancel":
			_close()
		"ok":
			_confirm()
		"less", "more":
			if _rep_skip:
				_rep_skip = false
			elif _numbered():
				_step(id)
		"present":
			if _can_present() and _gift.is_empty():
				_present = not _present
		"friend":
			if _can_present():
				_pick.toggle(client.friends)
		"gift":
			_present_send()
