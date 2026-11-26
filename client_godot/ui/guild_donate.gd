extends "quick_buy.gd"










const DonateAtlas = preload("guild_donate_atlas.gd")
const CTip = preload("ctool_tip.gd")
var _ctip: CTip = CTip.new()

const GUILD_ITEM: int = 8000001
const TEAM_ITEM: int = 8000002
const KIND: int = 8
const SHOW: int = 10
const MIN_DONATE: int = 10
const MAX_DONATE: int = 999999990
const UINT: int = 4294967296
const CASH_LIMIT: int = 220
const COIN_LIMIT: int = 12
const SIZE: Vector2 = Vector2(398, 326)
const PAY: Vector2 = Vector2(132, 166)
const DELAY: float = 0.2

const LIMIT_TEXT: String = "@num1@/@num2@"
const TEXT47: String = "Tiền không đủ, không thể quyên góp"
const TIP_435: String = "Mức đóng góp không thể là 0"
const TIP_433: String = "Phải là bội số của 10"
const TEXT70: String = "Giới hạn xu quyên góp mỗi ngày của cá nhân là @num1@"
const TEXT46: String = "Giới hạn góp Bạc mỗi ngày/cá nhân là @num1@"
const COIN_TIP: String = "Lv nhân vật càng cao, giới hạn cống hiến Bạc càng cao"

func _setup() -> void :
	super ()
	_count.max_length = 9

	for link: Dictionary in _count.text_submitted.get_connections():
		_count.text_submitted.disconnect(link.callable)


func donate(tid: int) -> bool:
	if tid not in [GUILD_ITEM, TEAM_ITEM]:
		return false
	return ask(tid, KIND, MIN_DONATE, false)


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
	_index = 0
	_cash_radio = false
	_open = true
	mouse_filter = MOUSE_FILTER_STOP
	_count.text = ""
	_set_count(MIN_DONATE)
	_focus = _count


func limit(cash: bool) -> Array:
	var used: int = int(client.limits.get(CASH_LIMIT if cash else COIN_LIMIT, 0))
	if cash:
		return [used, DonateAtlas.LIMIT_220]
	return [used, maxi(300, int(client.character.get("level", 0)) * 150 - 1500)]

func _numbered() -> bool:
	return true

func _amount() -> int:
	return int(_count.text)


func _set_count(value: int) -> void :
	var have: Array = limit(_cash_radio)
	if value + int(have[0]) > int(have[1]):
		value = posmod(int(have[1]) - int(have[0]), UINT)
	var text: String = str(value)
	if _count.text != text:
		_count.text = text
		_count.caret_column = text.length()


func _on_count_input() -> void :
	_set_count(int(_count.text))


func _step(id: String) -> void :
	var value: int = int(_count.text)
	if id == "more":
		value = mini((value + SHOW) / SHOW * SHOW, MAX_DONATE)
	else:
		value = maxi(posmod(value - SHOW, UINT) / SHOW * SHOW, MIN_DONATE)
	_set_count(value)


func _quote() -> Array:
	var packs: int = _amount() / SHOW
	var need: int = int((_rec.a if _rec.agio else _rec.p)[_index]) * packs
	var state: Array
	if int(_rec.ct2) == 0:
		state = ["goldOnly", 0, need, 0] if int(_rec.ct) == 2 else ["present", need, 0, 0]
	else:
		state = ["cashGold", need, int((_rec.a2 if _rec.agio else _rec.p2)[_index]) * packs, 0]
	return [state, plan(str(state[0]), _cash_radio, int(state[1]), int(state[2]), 0, _balance())]


func _confirm() -> void :
	if not _open or _rec.is_empty():
		return
	var bill: Dictionary = _quote()[1]
	if not bill.enough:
		say(TEXT47)
		return
	for pair: Array in bill.list:
		if int(pair[0]) == 2 and int(pair[1]) != 0 and int(_rec.lv) > int(client.character.get("level", 0)):
			say(TIP_286.replace("@num1@", str(int(_rec.lv))))
			return
	var value: int = _amount()
	if value == 0:
		say(TIP_435)
		return
	if value % SHOW != 0:
		say(TIP_433)
		return
	var have: Array = limit(_cash_radio)
	if value + int(have[0]) > int(have[1]):
		say((TEXT70 if _cash_radio else TEXT46).replace("@num1@", str(int(have[1]))))
		return
	var coin: int = int(bill.coin)
	if not client.buy_goods_vec(KIND, int(_rec.gid), coin, _single_price(coin), value / SHOW, bill.list):
		say("Chưa cống hiến được lúc này.")



func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Hall.FILE, Hall.R)
		_use(Shop.FILE, Shop.R)
		_use(DonateAtlas.FILE, DonateAtlas.R)
	if not _open or _rec.is_empty():
		_hide_edits()
		return
	var at: Vector2 = _window(SIZE.x, SIZE.y)
	_fmid("gd_title_guild" if int(_ask.get("tid", 0)) == GUILD_ITEM else "gd_title_team", at + Vector2(0, 18), SIZE.x)
	_fblit("gd_word_money", at + Vector2(32, 69))
	_fbutton("less", "shop_num_minus", at + Vector2(169, 68))
	_fblit("shop_input_bk_ss", at + Vector2(199, 62))
	_fput(_count, Rect2(at + Vector2(219, 65), Vector2(60, 30)), 20.0, "c")
	_fbutton("more", "public_button_num_plus", at + Vector2(303, 68))
	_fblit("gd_word_today", at + Vector2(32, 107))
	var tip: Array = []
	for row: Array in [[true, 104, "shop_money", "help:cash", 110], [false, 133, "shop_diamond", "help:coin", 138]]:
		var spot: Vector2 = at + Vector2(164, float(row[1]))
		var have: Array = limit(bool(row[0]))
		_fblit("shop_label200", spot, 200.0, 28.0)
		_fblit(str(row[2]), spot + Vector2(11, 1))
		var text: String = LIMIT_TEXT.replace("@num1@", str(int(have[0]))).replace("@num2@", str(int(have[1])))
		_fwords(text, BOLD, 12.0, Color.WHITE, "r", spot, 190.0, 0.0, 28.0)
		var help: Rect2 = _fblit("gd_help", at + Vector2(365, float(row[4])))
		_hit(str(row[3]), help, false)
		if _hover == str(row[3]) and _tip_ok() and _press.is_empty():
			tip = [help, TEXT70.replace("@num1@", str(DonateAtlas.LIMIT_220)) if bool(row[0]) else COIN_TIP]
	_fblit("shop_title_pay", at + Vector2(32, 171))
	_draw_pay(at + PAY)
	_fblit("gd_tip_bk", at + Vector2(61, 235))
	_fblit("gd_tip", at + Vector2(95, 239))
	var lit: Color = _glow("ok")
	var ok: Vector2 = at + Vector2((SIZE.x - 120.0) / 2.0, SIZE.y - 17.0 - 35.0)
	_hit("ok", _fblit("public_button_window_green", ok, 0.0, 0.0, lit), false)
	_fblit("title_title_confirm_green_t", ok + ((Vector2(120, 35) - _cell_size("title_title_confirm_green_t")) / 2.0).round(), 0.0, 0.0, lit)
	_draw_tip(tip[0] if not tip.is_empty() else Rect2(), str(tip[1]) if not tip.is_empty() else "")
	if _focus != null and _focus.visible:
		_focus.grab_focus.call_deferred()
		_focus.select_all.call_deferred()
		_focus = null


func _draw_tip(anchor: Rect2, body: String) -> void :
	_ctip.draw(self, (str(anchor) + body) if not body.is_empty() else "", body, get_local_mouse_position() / _f, Vector2(_fw, _fh), _f)



func _gui_input(event: InputEvent) -> void :
	super (event)
	if _open and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not _rep_id.is_empty():
		_rep_next = _time + DELAY

func _activate(id: String) -> void :
	if not _open:
		return
	if id.begins_with("help:"):
		return
	if id.begins_with("pay:"):
		_cash_radio = id == "pay:cash"
		_set_count(_amount())
		return
	if id in ["present", "friend", "gift"]:
		return
	super (id)
