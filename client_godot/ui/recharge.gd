extends "quick_buy.gd"









const RechargeAtlas = preload("recharge_atlas.gd")

const TIP_430: String = "Không thể gia hạn"
const DAY_TEXT: String = "@coinType@/@num1@ ngày"
const ROLL: Color = Color("fff000")
const SIZE: Vector2 = Vector2(422, 362)
const RADIO: Vector2 = Vector2(135, 73)
const STEP: float = 30.0

var _name: String = ""


func renew(tid: int, kind: int, name: String) -> bool:
	if kind not in [ShopModel.RENEW_AVATAR, ShopModel.RENEW_DECOR]:
		say(TIP_430)
		return false
	_name = name
	return ask(tid, kind, 1, false)


func _on_query(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_asking = false
	if _ask.is_empty() or client.state not in ALLOWED:
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty():
		say(NO_REPLY)
		return
	var row: Dictionary = parse_last(body)
	if row.is_empty():
		say(TIP_430)
		return
	row["name"] = _name
	_rec = row
	_index = 0
	_cash_radio = true
	_open = true
	mouse_filter = MOUSE_FILTER_STOP

func _numbered() -> bool:
	return false

func _amount() -> int:
	return 1


static func tier(rec: Dictionary, index: int) -> int:
	return int((rec.a if rec.agio else rec.p)[index])


static func renew_needs(rec: Dictionary, index: int) -> Array:
	var first: int = tier(rec, index)
	if int(rec.ct2) == 0:
		if int(rec.ct) == 2:
			return ["goldOnly", 0, first, 0]
		return ["present" if rec.cash_only else "cashGift", first, 0, 0]
	return ["", first, int((rec.a2 if rec.agio else rec.p2)[index]), 0]


static func label(rec: Dictionary, index: int) -> String:
	var price: int = tier(rec, index)
	if price <= 0:
		return TIP_417
	var coin: String = str(ShopModel.COIN_NAME[ShopModel.coin_index(int(rec.ct))])
	return str(price) + DAY_TEXT.replace("@coinType@", coin).replace("@num1@", str(int(ShopModel.DAYS[index])))

func _quote() -> Array:
	var need: Array = renew_needs(_rec, _index)
	return [need, plan(str(need[0]), _cash_radio, int(need[1]), int(need[2]), int(need[3]), _balance())]

func _confirm() -> void :
	if not _open or _rec.is_empty():
		return
	if tier(_rec, _index) <= 0:
		say(TIP_417)
		return
	super ()



func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Hall.FILE, Hall.R)
		_use(Shop.FILE, Shop.R)
		_use(RechargeAtlas.FILE, RechargeAtlas.R)
	_hide_edits()
	if not _open or _rec.is_empty():
		return
	var at: Vector2 = _window(SIZE.x, SIZE.y)
	_fmid("rc_title", at + Vector2(0, 19), SIZE.x)
	_fblit("rc_word_time", at + Vector2(53, 76))
	_fblit("rc_word_pay", at + Vector2(53, 191))
	var icon: Vector2 = _cell_size("shop_radio")
	for i in range(3):
		var spot: Vector2 = at + RADIO + Vector2(0, STEP * i)
		_fblit("shop_label200", spot + Vector2(33, -2))
		var id: String = "rc:%d" % i
		var live: bool = tier(_rec, i) > 0

		var chosen: bool = live and _index == i
		var mark: Vector2 = spot + Vector2(5, roundf((25.0 - icon.y) / 2.0))
		_fblit("shop_radio_sel" if chosen else "shop_radio", mark)
		var tint: Color = Color.WHITE
		if not live:
			tint = DIM
		elif not chosen and _hover == id and _press.is_empty():
			tint = ROLL
		_fwords(label(_rec, i), BOLD, 14.0, tint, "l", spot + Vector2(36, 0), 190.0, 1.0, 25.0)
		if live:
			_hit(id, Rect2(spot * _f, Vector2(230, 25) * _f), false)
	_draw_pay(at + Vector2(136, 187))
	_draw_ok(at + Vector2(151, 310))



func _activate(id: String) -> void :
	if not _open:
		return
	if id.begins_with("rc:"):
		var i: int = int(id.substr(3))
		if i >= 0 and i < 3 and tier(_rec, i) > 0:
			_index = i
		return
	if id in ["less", "more", "present", "friend"]:
		return
	super (id)
