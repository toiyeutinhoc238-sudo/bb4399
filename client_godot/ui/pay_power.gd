extends "flash_screen.gd"













const Atlas = preload("paypower_atlas.gd")

signal closed

const SIZE: Vector2 = Vector2(398, 326)
const AT: Vector2 = Vector2(301, 137)
const CASH: int = 1
const GIFT: int = 3
const FREE: Color = Color("fff352")
const SHORT: Color = Color("ff0000")
const CAN: Color = Color("ffffff")
const RIM: Color = Color("017ac3")
const SHOW_IN: Array = ["lobby", "hall", "room"]
const TIP_ENOUGH: String = "Mua %d Thể Lực"
const TIP_SHORT: String = "Thiếu Thể Lực, không thể vào PB!\nHãy dùng Xu mua %d Thể Lực."
const TIP_POOR: String = "Xu không đủ, hãy nạp tiền"
const TIP: String = "Lượt mua càng nhiều, giá càng cao"
const NAME_CASH: String = "Xu"
const NAME_GIFT: String = "Xu Khóa"
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."
const LINE: float = 24.0

var _buy_tip: String = ""

func chat_busy() -> bool:
	return false

func _setup() -> void :
	visible = false
	if client != null:
		client.changed.connect(_follow)


func _follow() -> void :
	if visible and (client == null or client.state not in SHOW_IN):
		close()

func open() -> void :
	if visible or client == null or client.state not in SHOW_IN:
		return
	var thew: int = int(client.character.get("thew", 0))
	_buy_tip = (TIP_ENOUGH if thew >= Atlas.ADD else TIP_SHORT) % Atlas.ADD
	_hover = ""
	_press = ""
	visible = true

func close() -> void :
	if not visible:
		return
	visible = false
	closed.emit()


func _has_point(point: Vector2) -> bool:
	return visible and Rect2((_stage() + AT) * _f, SIZE * _f).has_point(point)




static func cost_of(thew_buy: int) -> int:
	return int(Atlas.COST[clampi(thew_buy, 0, Atlas.COST.size() - 1)])


static func coin_list(price: int, gift: int, cash: int) -> Array:
	gift = maxi(0, gift)
	cash = maxi(0, cash)
	if gift + cash < price:
		return []
	if gift >= price:
		return [[GIFT, price]]
	var out: Array = []
	if gift != 0:
		out.append([GIFT, gift])
	out.append([CASH, price - gift])
	return out

func cost() -> int:
	return cost_of(int(client.character.get("thew_buy", 0)))

func coins() -> Array:
	return coin_list(cost(), int(client.currency.get("m_iSilver", 0)), int(client.currency.get("m_iCash", 0)))


func cash_labels() -> Array:
	var list: Array = coins()
	if list.is_empty():
		return [str(cost()), SHORT, "0", SHORT]
	var out: Array = ["0", CAN, "0", FREE]
	for pair: Array in list:
		if int(pair[0]) == GIFT:
			out[2] = str(int(pair[1]))
		elif int(pair[0]) == CASH:
			out[0] = str(int(pair[1]))
	return out

func buy_tip() -> String:
	return _buy_tip



func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	var base: Vector2 = _stage() + AT
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_fblit("pp_frame", base + _xy(Atlas.FRAME))
	_fblit("pp_coin", base + _xy(Atlas.COIN))
	_fblit("pp_cash", base + _xy(Atlas.ICON["cash"]))
	_fblit("pp_gift", base + _xy(Atlas.ICON["gift"]))
	var shown: Array = cash_labels()
	_label("label2", NAME_CASH, base, Color.WHITE)
	_label("lblCostCash", str(shown[0]), base, shown[1])
	_label("label1", NAME_GIFT, base, Color.WHITE)
	_label("lblGift", str(shown[2]), base, shown[3])
	_draw_buy_tip(base)
	_label("lblTip", TIP, base, Color(str(Atlas.TEXT["lblTip"][5])))
	_fbutton("ok", "pp_ok", base + _xy(Atlas.UP["btnConfirm"]))
	_fbutton("close", "pp_close", base + _xy(Atlas.UP["btnCancel"]))


func _label(key: String, text: String, base: Vector2, color: Color) -> void :
	var spec: Array = Atlas.TEXT[key]
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), color, str(spec[7]), 
		base + Vector2(float(spec[0]), float(spec[1])), float(spec[2]))


func _draw_buy_tip(base: Vector2) -> void :
	var spec: Array = Atlas.TEXT["txtBuyTip"]
	var left: Vector2 = base + Vector2(float(spec[0]) + 10.0, float(spec[1]) + 10.0)
	var wide: float = float(spec[2]) - 20.0
	var lines: Array = wrap_lines(_buy_tip, float(spec[4]), wide)
	for i in range(lines.size()):
		_fwords(str(lines[i]), ARIAL_BOLD, float(spec[4]), Color(str(spec[5])), "c", left + Vector2(0, LINE * i), wide, 1.5, 0.0, false, RIM)


func wrap_lines(text: String, px: float, wide: float) -> Array:
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(px * _f))
	var limit: float = wide * _f
	var out: Array = []
	for part: String in text.split("\n"):
		var line: String = ""
		for word: String in part.split(" "):
			var next: String = word if line.is_empty() else line + " " + word
			if not line.is_empty() and font.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > limit:
				out.append(line)
				line = word
			else:
				line = next
		out.append(line)
	return out



func _activate(id: String) -> void :
	match id:
		"close":
			close()
		"ok":
			var list: Array = coins()
			if list.is_empty():
				say(TIP_POOR)
			elif client.buy_thew(list):
				close()
			else:
				say(OFFLINE)

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
