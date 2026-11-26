extends "flash_screen.gd"


const Atlas = preload("mysterious_store_atlas.gd")
const BagModel = preload("bag_model.gd")
const TYPE: int = 107
const SHOW_IN: Array = ["lobby", "hall", "room"]
const VN: int = 25200
const PRICE_RIM: Color = Color("086da5", 0.8)
signal closed
signal gold_access_asked

var _count: LineEdit
var _buy_pos: int = -1
var _buy_good: Dictionary = {}
var _buy_last: int = 0
var _clock: Callable
var _timer_text: String = "30:00"
var _open_day: int = -1
var _repeat: String = ""
var _repeat_at: float = 0.0
var _repeat_skip: bool = false

static func is_open(game: Object, now: int = -1) -> bool:
	if game == null:
		return false
	if now < 0:
		now = int(Time.get_unix_time_from_system())
	if not game.mysterious_acts.is_empty():
		for row: Dictionary in game.mysterious_acts:
			if int(row.start) > 0 and int(game.character.get("level", 0)) >= int(row.level) and now >= int(row.start) and now <= int(row.start) + int(row.duration) * 60:
				return true
		return false
	return game.act_going(TYPE, now)

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)
	_count = _fedit(5, true)
	_count.add_theme_color_override("font_color", Color("fff352"))
	_count.add_theme_color_override("font_uneditable_color", Color("fff352"))
	_count.text_changed.connect( func(_text: String) -> void : _set_count(_amount()))
	_count.text_submitted.connect( func(_text: String) -> void : _confirm())
	if client != null:
		client.changed.connect(_follow)
		client.mysterious_purchased.connect( func(_pos: int) -> void :
			if visible:
				say(Atlas.WORDS["STORE_TXT7"]))

func chat_busy() -> bool:
	return visible

func _now() -> int:
	return int(_clock.call()) if _clock.is_valid() else int(Time.get_unix_time_from_system())

func open() -> void :
	if visible or client == null or client.state not in SHOW_IN or not is_open(client, _now()):
		return
	_hover = ""
	_press = ""
	_timer_text = "30:00"
	_open_day = (_now() + VN) / 86400
	_cancel_buy()
	visible = true
	if pack != null:
		pack.load_bag()
	client.request_mysterious_store()

func close() -> void :
	if not visible:
		return
	_cancel_buy()
	visible = false
	closed.emit()

func _shown() -> void :
	if not is_visible_in_tree():
		_cancel_buy()

func _follow() -> void :
	if not visible:
		return
	if client.state not in SHOW_IN or not is_open(client, _now()):
		close()
	elif _buy_pos >= 0:

		var row: Dictionary = goods(_buy_pos)
		if client.mysterious_last != _buy_last or row.is_empty() or int(row.get("m_nItemId", 0)) != int(_buy_good.get("m_nItemId", 0)) or int(row.get("m_nPrice", 0)) != int(_buy_good.get("m_nPrice", 0)) or int(row.get("m_nLeftCount", 0)) <= 0 or owned(row):
			_cancel_buy()
		else:
			_set_count(_amount())

func goods(pos: int) -> Dictionary:
	return client.mysterious_goods[pos] if client != null and pos >= 0 and pos < mini(6, client.mysterious_goods.size()) else {}

func owned(row: Dictionary) -> bool:
	var item: int = int(row.get("m_nItemId", 0))
	var spec: Array = Atlas.ITEMS.get(str(item), [])
	if spec.is_empty():
		return false
	if int(spec[0]) == 29:
		for inst: Dictionary in client.bags.get(6, []):
			if int(inst.get("m_templateId", 0)) == item and int(inst.get("m_count", 0)) > 0 and int(inst.get("m_lifeTime", 0)) == 0:
				return true
	elif int(spec[0]) in [20, 27, 69] and int(spec[1]) > 0:
		for inst: Variant in client.tanks.values():
			if inst is Dictionary and int(inst.get("m_tpltId", 0)) == int(spec[1]) and int(inst.get("m_contType", -1)) == 0:
				return true
	return false

func _tick(_delta: float) -> void :
	if not visible or client == null:
		return
	if not is_open(client, _now()):
		close()
		return
	var now: int = _now()
	var day: int = (now + VN) / 86400
	var ask: bool = day != _open_day
	if ask:
		_open_day = day
	var left: int = clampi(client.mysterious_last + 1800 - now, 0, 1800) if client.mysterious_last > 0 else 1800
	if left == 0 and _timer_text != "00:00":
		ask = true
	_timer_text = "%02d:%02d" % [left / 60, left % 60]
	if ask:
		client.request_mysterious_store()
	if not _repeat.is_empty() and _time >= _repeat_at:
		_step(_repeat)
		_repeat_at = _time + 0.2

func _item(item: int) -> Array:
	return pack.bag.get("items", {}).get(str(item), []) if pack != null else []

func _name(item: int) -> String:
	var row: Array = _item(item)
	if not row.is_empty():
		return BagModel.clean(str(row[0]))
	var more: Array = pack.bag.get("more", {}).get(str(item), []) if pack != null else []
	return BagModel.clean(str(more[0])) if not more.is_empty() else ""

func _picture(item: int) -> Texture2D:
	var row: Array = _item(item)
	var key: String = str(row[2]) if row.size() >= 10 else ""
	if key.is_empty() and pack != null:
		var more: Array = pack.bag.get("more", {}).get(str(item), [])
		if more.size() > 1:
			key = str(more[1])
	return pack.picture("l/it/%s.webp" % key) if pack != null and not key.is_empty() else null

func _fit(picture: Texture2D, at: Vector2) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var scale: float = minf(100.0 / picture.get_width(), 100.0 / picture.get_height())
	var extent: Vector2 = Vector2(picture.get_size()) * scale
	draw_texture_rect(picture, Rect2((at + (Vector2(100, 100) - extent) / 2.0) * _f, extent * _f), false)


static func comma(number: int) -> String:
	var text: String = str(number)
	var out: String = ""
	for i in range(text.length()):
		if i > 0 and (text.length() - i) % 3 == 0:
			out += ","
		out += text[i]
	return out

func _price(row: Dictionary, price: int, at: Vector2, enough: bool = true) -> void :
	var coin: int = int(row.get("m_nCoinType", 0))
	if coin not in [1, 2, 3, 7]:
		return
	_fblit("cm_coin%d" % coin, at + Vector2(0, 2))

	_fwords(comma(price), ARIAL_BOLD, 14, Color("ffff00") if enough else Color("ff1414"), "l", at + Vector2(30, 4), 70, 1.5, 0.0, true, PRICE_RIM)

func _paint() -> void :
	if not visible:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(816, 551)
	_fblit("cm_frame", at)
	_fblit("cm_title", at + Vector2(317.5, 37))
	_fbutton("cancel", "cm_close", at + Vector2(782, 68))
	for pos in range(6):
		var row: Dictionary = goods(pos)
		if row.is_empty():
			continue
		_draw_card(pos, row, at + Vector2(20 + (pos % 3) * 252, 107 + (pos / 3) * 190))
	_fwords(_timer_text, ARIAL_BOLD, 16, Color.YELLOW, "l", at + Vector2(20, 504), 500)
	if _buy_pos >= 0:
		_draw_buy()

func _draw_card(pos: int, row: Dictionary, at: Vector2) -> void :
	_fblit("cm_card", at)
	var item: int = int(row.get("m_nItemId", 0))
	_fwords(_name(item), ARIAL_BOLD, 16, Color.WHITE, "c", at + Vector2(27, 14), 200)
	_fit(_picture(item), at + Vector2(16, 63))
	if int(row.get("m_nOriginPrice", 0)) > 0:
		_fblit("cm_price_bg", at + Vector2(128, 64))
		_price(row, int(row.m_nOriginPrice), at + Vector2(131, 66))
		_fblit("cm_line", at + Vector2(131, 79))
	_price(row, int(row.get("m_nPrice", 0)), at + Vector2(131, 101))
	if owned(row):
		_fblit("cm_achieved", at + Vector2(139, 135))
	else:
		_fbutton("buy:%d" % pos, "cm_buy", at + Vector2(139, 135))
	_fwords(str(Atlas.WORDS["STORE_TXT6"]).replace("@num1@", str(int(row.get("m_nLeftCount", 0)))), ARIAL, 12, Color("975317"), "l", at + Vector2(16, 168), 180)

func _draw_buy() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(398, 400)
	_fblit("cm_ask", at + Vector2(2, 2))
	_fbutton("buy:cancel", "cm_close", at + Vector2(359, 15))
	_fit(_picture(int(_buy_good.get("m_nItemId", 0))), at + Vector2(149, 82))
	_fwords(_name(int(_buy_good.get("m_nItemId", 0))), ARIAL_BOLD, 16, Color.WHITE, "c", at + Vector2(20, 207), 358)
	_fbutton("less", "cm_ask_reduce", at + Vector2(137, 253))
	_fbutton("more", "cm_ask_add", at + Vector2(271, 253))
	_fput(_count, Rect2(at + Vector2(187, 250), Vector2(60, 30)), 20, "c")
	var total: int = _amount() * int(_buy_good.get("m_nPrice", 0))
	_price(_buy_good, total, at + Vector2(144, 290), _balance(int(_buy_good.get("m_nCoinType", 0))) >= total)
	_fbutton("confirm", "cm_ask_ok", at + Vector2(139, 348))

func _amount() -> int:
	return clampi(int(_count.text), 1, maxi(1, int(goods(_buy_pos).get("m_nLeftCount", 0)))) if _count != null else 1

func _set_count(amount: int) -> void :
	if _count != null:
		_count.text = str(clampi(amount, 1, maxi(1, int(goods(_buy_pos).get("m_nLeftCount", 0)))))


func cancel_buy() -> void :
	_cancel_buy()

func _cancel_buy() -> void :
	_buy_pos = -1
	_buy_good = {}
	_repeat = ""
	if _count != null:
		_count.visible = false

func _balance(coin: int) -> int:
	match coin:
		1: return int(client.currency.get("m_iCash", 0))
		2: return int(client.currency.get("m_iGolden", 0))
		3: return int(client.currency.get("m_iSilver", 0))
		7:
			var total: int = 0
			for bag: Variant in client.bags.values():
				for item: Dictionary in bag:
					if int(item.get("m_templateId", 0)) == 8000005:
						total += int(item.get("m_count", 0))
			return total
	return -1

func _confirm() -> void :
	if _buy_pos < 0 or not visible:
		return
	var row: Dictionary = goods(_buy_pos)
	if row.is_empty() or int(row.get("m_nLeftCount", 0)) <= 0 or owned(row):
		_cancel_buy()
		say(Atlas.WORDS["STORE_TXT5"])
		return
	if client.mysterious_last != _buy_last or int(row.get("m_nItemId", 0)) != int(_buy_good.get("m_nItemId", 0)) or int(row.get("m_nPrice", 0)) != int(_buy_good.get("m_nPrice", 0)) or int(row.get("m_nCoinType", 0)) != int(_buy_good.get("m_nCoinType", 0)):
		_cancel_buy()
		return
	var total: int = _amount() * int(row.get("m_nPrice", 0))
	if _balance(int(row.get("m_nCoinType", 0))) < total:
		var tip: String = "Xu không đủ, hãy nạp tiền"
		match int(row.get("m_nCoinType", 0)):
			2: tip = "Bạc không đủ"
			3: tip = "Xu Khóa không đủ"
			7:
				gold_access_asked.emit()
				return
		say(tip)
		return
	if client.buy_mysterious_store(_buy_pos, _amount()):
		_cancel_buy()

func _step(id: String) -> void :
	if _buy_pos >= 0:
		_set_count(_amount() + (-1 if id == "less" else 1))

func _activate(id: String) -> void :
	if id == "cancel":
		close()
	elif id == "buy:cancel":
		_cancel_buy()
	elif id == "confirm":
		_confirm()
	elif id in ["less", "more"]:
		if _repeat_skip:
			_repeat_skip = false
		else:
			_step(id)
	elif id.begins_with("buy:") and _buy_pos < 0:
		var pos: int = int(id.substr(4))
		var row: Dictionary = goods(pos)
		if row.is_empty() or owned(row):
			return
		if int(row.get("m_nLeftCount", 0)) == 0:
			say(Atlas.WORDS["STORE_TXT5"])
			return
		_buy_pos = pos
		_buy_good = row.duplicate(true)
		_buy_last = client.mysterious_last
		_set_count(1)
		_count.visible = true
		_count.grab_focus()
		_count.select_all()

func _gui_input(event: InputEvent) -> void :
	if _buy_pos >= 0 and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var id: String = _hit_at(event.position)
			if id in ["less", "more"]:
				_step(id)
				_repeat = id
				_repeat_at = _time + 0.2
				_repeat_skip = true
		else:
			_repeat = ""
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		if _buy_pos >= 0:
			_cancel_buy()
		else:
			close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		if _buy_pos >= 0:
			_confirm()
		get_viewport().set_input_as_handled()
