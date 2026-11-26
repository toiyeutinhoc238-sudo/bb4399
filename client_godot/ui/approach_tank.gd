extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")













const QuickBuy = preload("quick_buy.gd")
const ShopModel = preload("shop_model.gd")
const GarageModel = preload("garage_model.gd")
const Shop = preload("shop_atlas.gd")
const Arena = preload("arena_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Atlas = preload("approach_tank_atlas.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const Mysterious = preload("mysterious_store.gd")

signal closed
signal gold_access_asked

const BUY_OK: bool = true
const BUY_TODO: String = "Mua tank đang được chuyển sang HTML5."
const TIP_14: String = "Tạm thời chưa bán"
const MIN_COUNT: int = 1
const MAX_COUNT: int = 999
const EGG: int = 69
const AT: Vector2 = Vector2(276, 40)
const SHOWN: int = 2
const BAR: float = 19.0
const PULL: float = 56.0
const SELECT: Color = Color("ff5100")
const NAME_INK: Color = Color("f16422")
const PRICE_INK: Color = Color("8c4500")

var fetch: Callable
var _http: HTTPRequest
var _asking: bool = false
var _ask: Dictionary = {}
var _got: Array = []
var _wait_bag: bool = false
var _open: bool = false
var _rows: Array = []
var _cur: int = 0
var _numbered: bool = false
var _cash_radio: bool = true
var _top: int = 0
var _count: LineEdit
var _rep_id: String = ""
var _rep_next: float = 0.0
var _rep_skip: bool = false
var _bar: Array = []
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_top: float = 0.0
var _pull: float = 0.0
var _list_rect: Rect2 = Rect2()
var _pending: Dictionary = {}
var _told_at: float = -10.0

func chat_busy() -> bool:
	return _open

func _setup() -> void :
	mouse_filter = MOUSE_FILTER_IGNORE
	_count = _fedit(5, true)
	_count.add_theme_color_override("font_color", QuickBuy.CAN_BUY)
	_count.add_theme_color_override("font_uneditable_color", QuickBuy.CAN_BUY)
	_count.text_changed.connect( func(_text: String) -> void : _on_count_input())
	_count.text_submitted.connect( func(_text: String) -> void : _confirm())
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_query)
	if client != null:
		client.bought.connect(_on_bought)
		client.noticed.connect( func(_text: String) -> void :

			if not _pending.is_empty():
				_told_at = _time)
	if pack != null:
		pack.picture_ready.connect( func(path: String) -> void :
			if path == "l/bag.json" and _wait_bag:
				_wait_bag = false
				_show())

func _shown() -> void :
	if not is_visible_in_tree():
		_hide_edits()
		_open = false
		_rep_id = ""
		_grab = false
		mouse_filter = MOUSE_FILTER_IGNORE



func allowed() -> bool:
	return client.state in QuickBuy.ALLOWED or (client.has_method("pvp_result") and client.pvp_result())




func ask(tid: int, now: String = "", after: String = "", done: Callable = Callable(), fail: Callable = Callable()) -> bool:
	if client == null or pack == null:
		return false
	if not now.is_empty():
		visible = true
		say(now)
	if tid <= 0 or not allowed() or _asking or _wait_bag or _open:
		return false
	_ask = {"tid": tid, "after": after, "done": done, "fail": fail}
	_got = []
	var url: String = client.config.origin + "/cTankRelateGoods.php?tid=%d&char=%s&noCache=%d" % [tid, client.char_uuid.uri_encode(), randi() % 1000000]
	_asking = true
	visible = true
	if fetch.is_valid():
		fetch.call(url)
		return true
	_http.cancel_request()
	if _http.request(url, AppSession.headers(url)) != OK:
		_asking = false
		say(QuickBuy.NO_REPLY)
		return false
	return true


func _on_query(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_asking = false
	if _ask.is_empty() or not allowed():
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty():
		_ask = {}
		say(QuickBuy.NO_REPLY)
		return
	_got = parse_all(body)
	if pack.bag.is_empty() and not pack.base.is_empty():
		_wait_bag = true
		pack.load_bag()
		return
	_show()



static func parse_all(body: PackedByteArray) -> Array:
	var out: Array = []
	var parser: XMLParser = XMLParser.new()
	if body.is_empty() or parser.open_buffer(body) != OK:
		return out
	var depth: int = 0
	while parser.read() == OK:
		match parser.get_node_type():
			XMLParser.NODE_ELEMENT:
				if depth == 1:
					out.append(_fields(parser))
				if not parser.is_empty():
					depth += 1
			XMLParser.NODE_ELEMENT_END:
				depth -= 1
	return out

static func _fields(parser: XMLParser) -> Dictionary:
	var a: Dictionary = {}
	for i in range(parser.get_attribute_count()):
		a[parser.get_attribute_name(i).strip_edges()] = parser.get_attribute_value(i).strip_edges()
	var n: Callable = func(key: String) -> int: return int(str(a.get(key, "0")))
	return {"gid": n.call("goods_id"), "gt": n.call("goods_type"), "tid": n.call("template_oid"), 
		"lv": n.call("limit_level"), "vip": n.call("vip_level"), "cnt": [n.call("count_1"), n.call("count_2"), n.call("count_3")], 
		"ct": n.call("coin_type"), "ct2": n.call("coin_type2"), 
		"p": [n.call("price1"), n.call("price2"), n.call("price3")], 
		"p2": [n.call("price2_1"), n.call("price2_2"), n.call("price2_3")], 
		"a": [n.call("agio_price1"), n.call("agio_price2"), n.call("agio_price3")], 
		"a2": [n.call("agio_price2_1"), n.call("agio_price2_2"), n.call("agio_price2_3")], 
		"agio": n.call("is_agio") == 1, "cash_only": n.call("can_use_gift") == 0, 
		"limit": n.call("char_limit_count"), "bought": n.call("char_count"), "token": n.call("token_itemid"), "kind": ShopModel.BUY}


static func pick(rows: Array, bag: Dictionary) -> Array:
	var out: Array = []
	var seen: Array = []
	var items: Dictionary = bag.get("items", {})
	for rec: Dictionary in rows:
		var tid: int = int(rec.tid)
		if seen.has(tid):
			continue
		var row: Array = items.get(str(tid), [])
		if row.size() >= 10 and int(row[4]) == EGG:
			continue
		out.append(rec)
		seen.append(tid)
	return out


static func first_price(rec: Dictionary) -> int:
	return int((rec.a if rec.agio else rec.p)[0])


static func sort_goods(rows: Array) -> Array:
	var out: Array = rows.duplicate()
	for i in range(1, out.size()):
		var j: int = i
		while j > 0 and _order(out[j - 1], out[j]) > 0:
			var keep: Dictionary = out[j - 1]
			out[j - 1] = out[j]
			out[j] = keep
			j -= 1
	return out

static func _order(a: Dictionary, b: Dictionary) -> int:
	if int(a.ct) == int(b.ct):
		return -1 if first_price(a) < first_price(b) else 1
	return -1


func _show() -> void :
	var asked: Dictionary = _ask
	_ask = {}
	if asked.is_empty() or not allowed():
		return
	var goods: Array = sort_goods(pick(_got, pack.bag))
	_got = []
	if goods.is_empty():
		var fail: Callable = asked.fail
		if fail.is_valid():
			fail.call(int(asked.tid))
		else:
			say(TIP_14)
	elif not _open:
		for rec: Dictionary in goods:
			ShopModel.describe(rec, pack.bag, pack.garage, pack.lobby.get("tanks", {}), pack.index.get("tanks", {}))
		_open_goods(goods)
	if not str(asked.after).is_empty():
		say(str(asked.after))
	var done: Callable = asked.done
	if done.is_valid():
		done.call()


func _open_goods(goods: Array) -> void :
	_rows = goods
	_cur = 0
	_top = 0
	_bar = []
	_grab = false
	_pull = 0.0
	_cash_radio = true
	_numbered = int(goods[0].gt) != 2
	_open = true
	_hover = ""
	_press = ""
	mouse_filter = MOUSE_FILTER_STOP
	_count.text = ""
	_set_count(MIN_COUNT)

func is_open() -> bool:
	return _open

func rows() -> Array:
	return _rows

func current() -> int:
	return _cur

func numbered() -> bool:
	return _numbered

func top() -> int:
	return _top

func max_top() -> int:
	return maxi(0, _rows.size() - SHOWN)

func close() -> void :
	_close()

func _close() -> void :
	var was: bool = _open
	_open = false
	_rep_id = ""
	_grab = false
	_hide_edits()
	mouse_filter = MOUSE_FILTER_IGNORE
	if was:
		closed.emit()

func _rec() -> Dictionary:
	return _rows[_cur] if _cur >= 0 and _cur < _rows.size() else {}

func _amount() -> int:
	return clampi(int(_count.text), 0, MAX_COUNT)


func _set_count(value: int) -> void :
	var text: String = str(clampi(value, MIN_COUNT, MAX_COUNT))
	if _count.text != text:
		_count.text = text
		_count.caret_column = text.length()


func _on_count_input() -> void :
	var text: String = _count.text
	if text.is_empty() or text.substr(0, 1) < "1":
		_count.text = "1"
		_count.caret_column = 1
	_set_count(int(_count.text))



static func needs(rec: Dictionary, amount: int) -> Array:
	var need: int = first_price(rec) * amount
	if int(rec.ct2) == 0:
		match int(rec.ct):
			2:
				return ["goldOnly", 0, need, 0]
			7:
				return ["pvpCoin", 0, 0, need]
			_:
				return ["present" if rec.cash_only else "cashGift", need, 0, 0]
	var need2: int = int((rec.a2 if rec.agio else rec.p2)[0]) * amount
	match int(rec.ct2):
		2:
			return ["cashGold" if rec.cash_only else "", need, need2, 0]
		7:
			return ["cashPvp" if rec.cash_only else "cashGiftPvp", need, 0, need2]
	return ["", 0, 0, 0]

func _balance() -> Dictionary:
	var money: Dictionary = client.currency
	return {"cash": int(money.get("m_iCash", 0)), "gift": int(money.get("m_iSilver", 0)), "gold": int(money.get("m_iGolden", 0)), 
		"token": 0}

func _quote() -> Array:
	var need: Array = needs(_rec(), _amount())
	return [need, QuickBuy.plan(str(need[0]), _cash_radio, int(need[1]), int(need[2]), int(need[3]), _balance())]


static func single_price(rec: Dictionary, coin: int) -> int:
	if coin == int(rec.ct):
		return first_price(rec)
	return int((rec.a2 if rec.agio else rec.p2)[0])


func _confirm() -> void :
	if not _open or _rec().is_empty():
		return
	var rec: Dictionary = _rec()
	var bill: Dictionary = _quote()[1]
	if not bill.enough:
		if int(bill.pay) == QuickBuy.PVP_COIN_ONLY:
			gold_access_asked.emit()
		else:
			say(QuickBuy.TIP_79)
		return
	for pair: Array in bill.list:
		if int(pair[0]) == 2 and int(pair[1]) != 0 and int(rec.lv) > int(client.character.get("level", 0)):
			say(QuickBuy.TIP_286.replace("@num1@", str(int(rec.lv))))
			return
	if not BUY_OK:
		say(BUY_TODO)
		return
	var coin: int = int(bill.coin)
	if client.buy_goods_vec(int(rec.kind), int(rec.gid), coin, single_price(rec, coin), maxi(1, _amount()), bill.list):
		_pending = {"gid": int(rec.gid), "name": GarageModel.cap(str(rec.get("name", ""))), "at": _time}
		_close()
	else:
		say("Chưa mua được lúc này.")


func _on_bought(ok: bool, goods: int) -> void :
	if _pending.is_empty() or (ok and goods != 0 and goods != int(_pending.gid)):
		return
	var name: String = str(_pending.name)
	var asked: float = float(_pending.at)
	_pending = {}
	if ok:
		visible = true
		say(QuickBuy.BOUGHT)
		if not client.bag_loaded:
			client.request_bags()
	elif _told_at < asked:
		visible = true
		say("Chưa mua được %s." % name)

func _scroll(value: float) -> void :
	_top = clampi(roundi(value), 0, max_top())

func _tick(_delta: float) -> void :
	if (_open or _asking or _wait_bag) and not allowed():
		_asking = false
		_wait_bag = false
		_ask = {}
		_got = []
		_close()
	if _open and not _rep_id.is_empty():
		if _held and _press == _rep_id and _hit_at(get_local_mouse_position()) == _rep_id:
			if _time >= _rep_next:
				_step(_rep_id)
				_rep_next = maxf(_rep_next + QuickBuy.REPEAT_STEP, _time - QuickBuy.REPEAT_STEP)
		else:
			_rep_id = ""
	if not _pending.is_empty() and _time - float(_pending.at) > QuickBuy.WAIT:
		_pending = {}
		say(QuickBuy.NO_REPLY)
	if not _open and not _asking and not _wait_bag and _pending.is_empty() and _time - _toast_at > 2.7 and visible:
		visible = false

func _step(id: String) -> void :
	_set_count(_amount() + (1 if id == "more" else -1))



func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))

func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Hall.FILE, Hall.R)
		_use(Shop.FILE, Shop.R)
		_use(Atlas.FILE, Atlas.R)
	if not _open or _rows.is_empty():
		_hide_edits()
		return
	var wide: float = float(Atlas.FRAME[0])
	var at: Vector2 = _frame(wide, float(Atlas.FRAME[1]))
	_fmid("shop_title_confirmpaygood", at + Vector2(0, 19), wide)
	_fblit("apt_box4", at + _v(Atlas.BOX4))
	_draw_list(at + _v(Atlas.AT["lstBuyItem"]))
	if _numbered:
		_fblit("shop_title_buynum", at + _v(Atlas.NUM_TITLE))
		_fbutton("less", "shop_num_minus", at + _v(Atlas.AT["btnReduceNum"]))
		_fblit("shop_input_bk_ss", at + _v(Atlas.NUM_BG))
		var box: Array = Atlas.AT["txtBuyNum"]
		_fput(_count, Rect2(at + _v(box), Vector2(float(box[2]), float(box[3]))), 20.0, "c")
		_fbutton("more", "public_button_num_plus", at + _v(Atlas.AT["btnAddNum"]))
	else:
		_hide_edits()
	_fblit("shop_title_pay", at + _v(Atlas.AT["cimagechecklocal3"]))
	_draw_pay(at + _v(Atlas.AT["frmCurrency"]))
	_fblit("shop_word_consume_tips", at + _v(Atlas.AT["cimagechecklocal4"]))
	_draw_ok(at + _v(Atlas.AT["btnConfirm"]))


func _frame(wide: float, high: float) -> Vector2:
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _stage() + AT
	_hit("panel", Rect2(at * _f, Vector2(wide, high) * _f), false)
	draw_rect(Rect2((at + Vector2(12, 43)) * _f, Vector2(wide - 24.0, high - 56.0) * _f), WINDOW)
	var full: Vector2 = _cell_size("public_bk_pattern")
	var part: Vector2 = Vector2(minf(full.x, wide - 24.0), minf(full.y, high - 56.0))
	_fpart("public_bk_pattern", at + Vector2(12, 43) + (Vector2(wide - 24.0, high - 56.0) - part) / 2.0, Rect2(((full - part) / 2.0).floor(), part))
	_fblit("public_bk_lt", at)
	_fblit("public_bk_rt", at + Vector2(wide - 34.0, 0))
	_fblit("public_bk_bc", at + Vector2(0, high - 90.0))
	_fblit("public_bk_bc_r", at + Vector2(wide - 30.0, high - 90.0))
	_fblit("public_bk", at + Vector2(34, 0), wide - 68.0)
	_fblit("public_bk_b2", at + Vector2(30, high - 68.0), wide - 60.0)
	_fblit("public_bk_l", at + Vector2(0, 84), 0.0, high - 174.0)
	_fblit("public_bk_r", at + Vector2(wide - 30.0, 84), 0.0, high - 174.0)
	_fmid("public_bk_ti", at + Vector2(0, 18), wide)
	_fblit("public_bk_oc", at + Vector2(43, 9), wide - 86.0)
	_fblit("public_bk_ol", at + Vector2(35, 9))
	_fblit("public_bk_or", at + Vector2(wide - 43.0, 9))
	_fblit("public_bk_c", at + Vector2(wide - 52.0, 13))
	_fmid("public_window_button_bk", at + Vector2(0, high - 56.0), wide)
	_fbutton("cancel", "public_button_close", at + _v(Atlas.AT["btnClose"]))
	return at


func _draw_list(at: Vector2) -> void :
	var box: Array = Atlas.AT["lstBuyItem"]
	var wide: float = float(box[2])
	var high: float = float(box[3])
	var row_h: float = float(Atlas.CARD[1])
	_list_rect = Rect2(at * _f, Vector2(wide, high) * _f)
	for k: int in ceili(high / row_h):
		var index: int = _top + k
		if index >= _rows.size():
			break
		var card: Vector2 = at + Vector2(0, k * row_h)
		var shown: float = minf(row_h, high - k * row_h)
		_hit("row:%d" % index, Rect2(card * _f, Vector2(wide - BAR, shown) * _f), false)
		if shown >= row_h:
			_draw_card(index, card)
		else:
			_fpart("apt_card", card + _v(Atlas.CARD_AT["cimagechecklocal2"]), Rect2(0, 0, float(Atlas.CARD_AT["cimagechecklocal2"][2]), shown))
	_draw_bar(at + Vector2(wide - BAR, 0), high - 2.0 * BAR)


func _draw_card(index: int, card: Vector2) -> void :
	var rec: Dictionary = _rows[index]
	var spot: Dictionary = Atlas.CARD_AT
	var chosen: bool = index == _cur
	_fblit("apt_card", card + _v(spot["cimagechecklocal2"]))
	if chosen:
		var edge: Array = spot["canvas1"]
		_round(Rect2((card + _v(edge)) * _f, Vector2(float(edge[2]), float(edge[3])) * _f), Color(0, 0, 0, 0), 24.0, SELECT, 6.0)
	_fblit("shop_radio_sel" if chosen else "shop_radio", card + Vector2(2, 42))
	if int(rec.gt) == 2:
		_draw_tank(int(rec.tid), card + Vector2(80, 50), 0.5)
	else:
		_draw_icon(str(rec.get("icon", "")), card)
	var label: Array = Atlas.CARD_TEXT["lblItemName"]
	_fwords(GarageModel.cap(str(rec.get("name", ""))), BOLD, 16.0, NAME_INK, "l", card + _v(label), float(Atlas.CARD[0]) - float(label[0]), 0.0, 0.0, false)
	_draw_prices(rec, card)


func _draw_prices(rec: Dictionary, card: Vector2) -> void :
	var text: String = Mysterious.comma(first_price(rec))
	var second: int = int((rec.a2 if rec.agio else rec.p2)[0])
	var text2: String = Mysterious.comma(second) if second > 0 else ""
	var w1: float = 26.0 + _tw(text, 14.0) + 5.0
	var w3: float = 26.0 + _tw(text2, 14.0) + 5.0
	var x: float = float(Atlas.CARD[0]) / 2.0 + 64.0 - roundf((w1 + 6.0 + 17.0 + 6.0 + w3) / 2.0)
	var y: float = 75.0
	_coin(int(rec.ct), card + Vector2(x, y))
	_fwords(text, BOLD, 14.0, PRICE_INK, "l", card + Vector2(x + 26.0, y + 3.0), 200.0, 0.0, 0.0, false)
	x += w1 + 6.0
	if int(rec.ct2) != 0:
		_fblit("shop_or", card + Vector2(x + 2.0, y + 8.0))
	x += 17.0 + 6.0
	_coin(int(rec.ct2), card + Vector2(x, y))
	_fwords(text2, BOLD, 14.0, PRICE_INK, "l", card + Vector2(x + 26.0, y + 3.0), 200.0, 0.0, 0.0, false)


func _coin(ct: int, at: Vector2) -> void :
	match ct:
		1, 2, 3:
			_fblit(str(Shop.COINS[ShopModel.coin_index(ct)][1]), at)
		7:
			_fblit("apt_coin_pvp", at)


func _tw(text: String, px: float) -> float:
	if text.is_empty():
		return 0.0
	return _face(BOLD).get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f


func _draw_icon(path: String, card: Vector2) -> void :
	var picture: Texture2D = pack.picture(path) if not path.is_empty() else null
	if picture == null or picture.get_width() <= 4:
		return
	var extent: Vector2 = Vector2(picture.get_size())
	var dest: Rect2 = Rect2(card + Vector2(90.0 - extent.x / 2.0, 6.0), extent)
	var shown: Rect2 = dest.intersection(Rect2(card, _v(Atlas.CARD)))
	if not shown.has_area():
		return
	draw_texture_rect_region(picture, Rect2(shown.position * _f, shown.size * _f), Rect2(shown.position - dest.position, shown.size))


func _draw_tank(tid: int, c: Vector2, zoom: float) -> void :
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tid, 1, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), 0, 1)
	if TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, c * _f, zoom * _f, _time) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tid))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46) * zoom
		TankPortrait.ring(self, pack, item, pod * _f, zoom * _f, _time, 1)
		TankPreview.draw(self, art, (pod - Vector2(0, 52) * zoom) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * zoom * _f, 4, _time)
		TankPortrait.ring(self, pack, item, pod * _f, zoom * _f, _time, 2)


func _draw_bar(at: Vector2, track: float) -> void :
	_fblit("apt_sb_bk", at + Vector2(0, BAR), BAR, track)
	_fbutton("bar:up", "apt_sb_up", at)
	_fbutton("bar:down", "apt_sb_down", at + Vector2(0, BAR + track))
	_bar = []
	var most: float = float(max_top())
	if most <= 0.0:
		return
	var thumb: float = maxf(20.0, track * SHOWN / (most + SHOWN))
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


func _draw_pay(base: Vector2) -> void :
	var quote: Array = _quote()
	var state: String = str(quote[0][0])
	var bill: Dictionary = quote[1]
	for row: Array in QuickBuy.LAYOUT.get(state, QuickBuy.LAYOUT[""]):
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
					var tint: Color = (QuickBuy.NO_ENOUGH if bill.red[key] else QuickBuy.CAN_BUY) if bill.on[key] else QuickBuy.DIM
					var rim: Color = QuickBuy.NO_ENOUGH_RIM if bill.on[key] and bill.red[key] else SHADE
					_fwords(Mysterious.comma(int(bill.text[key])), BOLD, 14.0, tint, "r", spot, 120.0, 1.5 if bill.red[key] else 1.0, 0.0, true, rim)
				"radio":
					var id: String = str(part[1])
					var chosen: bool = _cash_radio == (id == "pay:cash")
					_fbutton(id, "shop_radio_sel" if chosen else "shop_radio", spot)


func _draw_ok(at: Vector2) -> void :
	var lit: Color = _glow("ok")
	_hit("ok", _fblit("shop_button_red", at, 0.0, 0.0, lit), false)
	_fblit("shop_title_confirmpay", at + ((Vector2(120, 35) - _cell_size("shop_title_confirmpay")) / 2.0).round(), 0.0, 0.0, lit)

func _token_row() -> Array:
	var tid: int = int(_rec().get("token", 0))
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
		_pull = 0.0
		var id: String = _hit_at(event.position)

		if id in ["less", "more"] and _numbered:
			_step(id)
			_rep_id = id
			_rep_next = _time + QuickBuy.REPEAT_DELAY
			_rep_skip = true
		elif id == "slide:bar" and not _bar.is_empty():
			_grab = true
			_grab_at = event.position
			_grab_top = float(_top)
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
	if _open and _list_rect.has_point(at):
		_scroll(_top + step)


func _drag(moved: Vector2, from: Vector2) -> void :
	if not _open or _grab or not _list_rect.has_point(from):
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, PULL * _f)
	while _pull >= pitch:
		_pull -= pitch
		_scroll(_top + 1)
	while _pull <= - pitch:
		_pull += pitch
		_scroll(_top - 1)

func _input(event: InputEvent) -> void :
	if _open and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if not _open or not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_UP:
			_scroll(_top - 1)
		KEY_DOWN:
			_scroll(_top + 1)
		KEY_PAGEUP:
			_scroll(_top - SHOWN)
		KEY_PAGEDOWN:
			_scroll(_top + SHOWN)
		KEY_ENTER, KEY_KP_ENTER:
			pass
		_:
			return
	get_viewport().set_input_as_handled()

func _activate(id: String) -> void :
	if not _open:
		return
	if id.begins_with("pay:"):
		_cash_radio = id == "pay:cash"
		return
	if id.begins_with("row:"):
		var index: int = int(id.substr(4))
		if index != _cur and index >= 0 and index < _rows.size():
			_cur = index
			_set_count(MIN_COUNT)
		return
	match id:
		"cancel":
			_close()
		"ok":
			_confirm()
		"less", "more":
			if _rep_skip:
				_rep_skip = false
			elif _numbered:
				_step(id)
		"bar:up":
			_scroll(_top - 1)
		"bar:down":
			_scroll(_top + 1)
		"bar:pgup":
			_scroll(_top - SHOWN)
		"bar:pgdn":
			_scroll(_top + SHOWN)
