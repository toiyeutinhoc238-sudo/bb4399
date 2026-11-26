extends "flash_screen.gd"

















const TankRentAtlas = preload("tank_rent_atlas.gd")
const GarageAtlas = preload("garage_atlas.gd")
const GarageModel = preload("garage_model.gd")
const FlashTip = preload("flash_tip.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const ShopModel = preload("shop_model.gd")
const OpenUi = preload("open_ui_note.gd")
const FriendPick = preload("friend_pick.gd")
const AccCards = preload("acc_cards.gd")

signal closed(note: String)
signal quick_buy_asked(tid: int, count: int)
signal tank_buy_asked(tid: int, now: String, after: String)
signal convert_asked(tid: int)

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const OFF: Color = Color(0.55, 0.55, 0.55, 1.0)
const OVER_TIME: float = 5.0
const ROWS: int = 5
const COIN_NAMES: Dictionary = {1: "Xu", 2: "Bạc", 3: "Xu khóa"}
const CELL_BG: Array = ["", "trent_cell_mid", "trent_cell_high"]
const CAN_PAY: Color = Color("fff352")
const NO_PAY: Color = Color("ff0000")
const NO_PAY_RIM: Color = Color("6c0d0d")
const TIP_PRESENT_NAME: String = "Chọn đối tượng tặng trước"
const TIP_VIP_LEVEL: String = "VIP@num1@ được thuê miễn phí, hãy tăng VIP"
const TIP_VIP_USED: String = "Đã hết lượt thuê miễn phí trong tháng"
const TIP_SHORT: String = "Thiếu @name@"
const TIP_HIGHER: String = "Đã có @name@ cao cấp hơn, không cần thuê"
const TIP_DONE: String = "Thuê @name@ thành công"
const TIP_OWNED: String = "Đã có @name@"
const TIP_SAME: String = "Bạn đã có @name@ cùng LV, không cần thuê"
const TIP_PRESENT_COIN: String = "Chỉ được dùng Xu tặng bạn"
const TIP_GIVEN: String = "@name@ tặng bạn @text1@（LV@num1@）@num2@"
const TIP_PRESENTED: String = "Tặng bạn @num1@@name@ thành công"
const LEFT: String = "Thời gian thuê còn: @time@"
const VIP_TIMES: String = "Mỗi tháng được thuê miễn phí @num1@/@num2@"
const NO_CHIPS: String = "Không nhận Mảnh"
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."

var _tank: int = 0
var _level: int = 0
var _day: int = 0
var _top: int = 0
var _present: bool = false
var _locked_until: float = -1.0
var _rev: int = -1
var _friend: LineEdit
var _ui_wait: bool = false
var _pick = FriendPick.new()

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(TankRentAtlas.FILE, TankRentAtlas.R)
	var levels_art: Dictionary = {}
	for key: String in GarageAtlas.R:
		if key.begins_with("garage_lv_"):
			levels_art[key] = GarageAtlas.R[key]
	_use(GarageAtlas.FILE, levels_art)
	FriendPick.cells(self)
	_friend = _name_fedit()
	_friend.text_changed.connect( func(text: String) -> void :

		_present = text != "")
	if client != null:
		client.tank_changed.connect(_on_tank_changed)
		client.noticed.connect( func(text: String) -> void :

			if is_visible_in_tree():
				say(text))


func open(tank_id: int) -> void :
	_tank = tank_id
	_level = 0
	_day = 0
	_top = 0
	_present = false
	_locked_until = -1.0
	_toast = ""
	_hover = ""
	_press = ""
	if _friend != null:
		_friend.text = ""
	_pick.close()
	if pack != null:
		pack.load_garagex()
		pack.load_bag()
	_rev = client.tank_rent_rev if client != null else -1
	_pick_level(0)
	visible = true
	_ui_wait = client != null and OpenUi.note(client, pack, OpenUi.UI_HIRE_TANK) == OpenUi.WAIT

func close(note: String = "") -> void :
	if not visible:
		return
	visible = false
	_ui_wait = false
	_pick.close()
	_hide_edits()
	closed.emit(note)

func chat_busy() -> bool:
	return visible

func current_tank() -> int:
	return _tank

func current_level() -> int:
	return _level

func current_day() -> int:
	return _day

func presenting() -> bool:
	return _present




func catalog() -> Array:
	if client != null and client.tank_rent_got:
		return client.tank_rents
	return pack.garagex.get("rent", []) if pack != null else []


func levels() -> Array:
	var out: Array = []
	for row: Variant in catalog():
		if row is Dictionary and int(row.get("tank_id", 0)) == _tank and not out.has(int(row.get("tank_lv", 0))):
			out.append(int(row.get("tank_lv", 0)))
	out.sort()
	return out.slice(0, 3)


func rows() -> Array:
	var out: Array = []
	for row: Variant in catalog():
		if row is Dictionary and int(row.get("tank_id", 0)) == _tank and int(row.get("tank_lv", 0)) == _level:
			out.append(row)
	return out

func row() -> Dictionary:
	var list: Array = rows()
	return list[_day] if _day >= 0 and _day < list.size() else {}


static func on_sale(rec: Dictionary) -> bool:
	var agio: int = int(rec.get("agio_price", 0))
	return agio > 0 and agio < int(rec.get("price", 0))


static func pay(rec: Dictionary) -> int:
	if int(rec.get("vip_freelv", 0)) > 0:
		return 0
	return int(rec.get("agio_price", 0)) if on_sale(rec) else int(rec.get("price", 0))

func balance(coin: int) -> int:
	return ShopModel.balance(client.currency, coin) if coin in [1, 2, 3] else 0


func shortfall(rec: Dictionary) -> int:
	if rec.is_empty() or int(rec.get("vip_freelv", 0)) > 0:
		return 0
	return maxi(0, pay(rec) - balance(int(rec.get("coin_type", 0))))


static func hire_text(hours: int) -> String:
	if hours > 24:
		var days: float = hours / 24.0
		return "%s ngày" % (str(int(days)) if is_equal_approx(days, floorf(days)) else String.num(days))
	return "%d giờ" % hours


static func time_text(seconds: int) -> String:
	if seconds / 86400 > 0:
		var hours: int = ceili(seconds / 3600.0)
		if hours < 24:
			return "%d giờ" % hours
		var days: int = hours / 24
		hours %= 24
		return "%d ngày %d giờ" % [days, hours] if hours > 0 else "%d ngày" % days
	var minutes: int = ceili(seconds / 60.0)
	if minutes < 60:
		return "%d phút" % minutes
	var whole: int = minutes / 60
	minutes %= 60
	return "%d giờ %d phút" % [whole, minutes] if minutes > 0 else "%d giờ" % whole

func tank_name() -> String:
	return str(pack.lobby.get("tanks", {}).get(str(_tank), str(_tank)))


func owned() -> Dictionary:
	var best: Dictionary = {}
	for inst: Dictionary in client.tanks.values():
		if int(inst.get("m_tpltId", 0)) == _tank and int(inst.get("m_contType", -1)) == GarageModel.OWN\
		and (best.is_empty() or int(inst.get("m_level", 1)) > int(best.get("m_level", 1))):
			best = inst
	return best


func rented(level: int, now: int) -> Dictionary:
	for inst: Dictionary in client.tanks.values():
		if int(inst.get("m_tpltId", 0)) == _tank and int(inst.get("m_contType", -1)) == GarageModel.HIRE\
		and int(inst.get("m_level", 0)) == level and int(inst.get("m_existTime", 0)) > now:
			return inst
	return {}


func rentable() -> Array:
	var listed: Array = []
	for rec: Variant in catalog():
		if rec is Dictionary and not listed.has(int(rec.get("tank_id", 0))):
			listed.append(int(rec.get("tank_id", 0)))
	var out: Array = []
	for inst: Dictionary in client.tanks.values():
		var id: int = int(inst.get("m_tpltId", 0))
		if listed.has(id) and not out.has(id):
			out.append(id)
	listed.sort()
	for id: int in listed:
		if not out.has(id):
			out.append(id)
	return out


func chips() -> Array:
	var entry: Variant = pack.garagex.get("tanks", {}).get(str(_tank), [])
	return entry if entry is Array and entry.size() >= 2 and int(entry[1]) > 0 else []

func vip_level() -> int:
	var now: int = int(Time.get_unix_time_from_system())
	if int(client.character.get("vipTime", 0)) <= now:
		return 0
	return _vip_level(int(client.character.get("vipPoints", 0)))


func confirm_tip() -> String:
	var rec: Dictionary = row()
	if rec.is_empty():
		return ""
	var title: String = tank_name()
	var own: Dictionary = owned()
	if not own.is_empty():
		if int(own.get("m_level", 1)) > int(rec.get("tank_lv", 0)):
			return TIP_HIGHER.replace("@name@", title)
		if int(own.get("m_level", 1)) == int(rec.get("tank_lv", 0)):
			return TIP_SAME.replace("@name@", title)
	var vip: int = int(rec.get("vip_freelv", 0))
	if vip > 0:
		if vip_level() < vip:
			return TIP_VIP_LEVEL.replace("@num1@", str(vip))
		return TIP_VIP_USED
	if shortfall(rec) > 0:
		return TIP_SHORT.replace("@name@", str(COIN_NAMES.get(int(rec.get("coin_type", 0)), "Xu")))
	return ""


func present_tip() -> String:
	var rec: Dictionary = row()
	if rec.is_empty() or not _present:
		return ""
	if _friend == null or _friend.text.is_empty():
		return TIP_PRESENT_NAME


	if int(rec.get("vip_freelv", 0)) > 0 or int(rec.get("coin_type", 0)) != 1:
		return TIP_PRESENT_COIN
	if int(rec.get("price", 0)) > balance(1):
		return TIP_SHORT.replace("@name@", "Xu")
	return ""


static func hire_note(giver: String, title: String, level: int, hours: int) -> String:
	var span: String = AccCards.day_hours(hours * 3600)
	if giver.is_empty():
		return TIP_PRESENTED.replace("@name@", title).replace("@num1@", span)
	return TIP_GIVEN.replace("@name@", giver).replace("@text1@", title).replace("@num1@", str(level)).replace("@num2@", span)

func rent_ready() -> bool:
	return not rows().is_empty() and _time >= _locked_until




func _pick_level(level: int) -> void :
	var all: Array = levels()
	_level = level if all.has(level) else (int(all[0]) if not all.is_empty() else 0)
	var count: int = rows().size()
	_day = clampi(_day, 0, maxi(0, count - 1))
	_top = clampi(_top, 0, maxi(0, count - ROWS))
	if _day < _top:
		_top = _day
	elif _day >= _top + ROWS:
		_top = _day - ROWS + 1


func _switch(step: int) -> void :
	var all: Array = rentable()
	if all.is_empty():
		return
	var at: int = all.find(_tank)
	var next: int = 0
	if at < 0:
		next = 0 if step > 0 else all.size() - 1
	else:
		next = (at + step + all.size()) % all.size()
	_tank = int(all[next])
	_present = false
	if _friend != null:
		_friend.text = ""
	_pick.close()
	_pick_level(_level)

func _confirm() -> void :
	if not rent_ready():
		return
	var tip: String = confirm_tip()
	if not tip.is_empty():
		say(tip)
		return
	var rec: Dictionary = row()
	if rec.is_empty():
		return
	if not client.hire_tank(_tank, int(rec.get("tank_lv", 0)), int(rec.get("hire_time", 0)), int(rec.get("coin_type", 0)), pay(rec), 0):
		say(OFFLINE)
		return
	_locked_until = _time + OVER_TIME


func _present_send() -> void :
	var rec: Dictionary = row()
	if rec.is_empty() or not _present:
		return
	var tip: String = present_tip()
	if not tip.is_empty():
		say(tip)
		return
	if not client.present_hire(_tank, int(rec.get("tank_lv", 0)), int(rec.get("hire_time", 0)), int(rec.get("price", 0)), _friend.text):
		say(OFFLINE)

func _on_tank_changed(uuid: String, op: int) -> void :

	if not visible or op != 11:
		return
	if int(client.tanks.get(uuid, {}).get("m_tpltId", 0)) == _tank:
		close(TIP_DONE.replace("@name@", tank_name()))

func _tick(_delta: float) -> void :
	if _ui_wait and client != null and OpenUi.note(client, pack, OpenUi.UI_HIRE_TANK) != OpenUi.WAIT:
		_ui_wait = false
	if client != null and client.tank_rent_rev != _rev:

		_rev = client.tank_rent_rev
		_pick_level(_level)

func _activate(id: String) -> void :
	var picked: Array = _pick.activate(id)
	if bool(picked[0]):
		if not str(picked[1]).is_empty():

			_friend.text = str(picked[1])
			_friend.caret_column = _friend.text.length()
			_present = true
		return
	if id.begins_with("cell:"):
		var all: Array = levels()
		var k: int = int(id.substr(5))
		if k >= 0 and k < all.size():
			_pick_level(int(all[k]))
		return
	if id.begins_with("row:"):
		_day = clampi(int(id.substr(4)), 0, maxi(0, rows().size() - 1))
		return
	match id:
		"close":
			close("")
		"prev":
			_switch(-1)
		"next":
			_switch(1)
		"rent":
			_confirm()
		"present":
			_present_send()
		"present_chk":
			_present = not _present
		"friend":
			_pick.toggle(client.friends)
		"buy":
			if not owned().is_empty():
				say(TIP_OWNED.replace("@name@", tank_name()))
			elif not tank_buy_asked.get_connections().is_empty():
				tank_buy_asked.emit(_tank, "", "")
			else:
				say("Mua tank đang được chuyển sang HTML5.")
		"charge":
			say("Nạp đang được chuyển sang HTML5.")
		"exchange":
			if not convert_asked.get_connections().is_empty():
				convert_asked.emit(_tank)
			else:
				say("Đổi tank bằng mảnh đang được chuyển sang HTML5.")
		"add":
			_add_chips()


func _add_chips() -> void :
	var entry: Array = chips()
	if entry.is_empty():
		return
	var need: int = int(entry[1])
	var have: int = GarageModel.have(client.bags, int(entry[0]))
	if have < need:
		quick_buy_asked.emit(int(entry[0]), need - have)

func _wheel(step: int, at: Vector2) -> void :
	if _pick.wheel(step, at):
		return
	var count: int = rows().size()
	if count > ROWS:
		_top = clampi(_top + step, 0, count - ROWS)

func _drag(moved: Vector2, from: Vector2) -> void :
	_pick.drag(moved, from, _mobile, _f)

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close("")
	elif event.keycode not in [KEY_ENTER, KEY_KP_ENTER]:
		return
	get_viewport().set_input_as_handled()



func _v(at: Array) -> Vector2:
	return Vector2(float(at[0]), float(at[1]))


func _label(spec: Array, text: String, base: Vector2, color: Color, edge: float = 1.0, rim: Color = SHADE) -> float:
	return _fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), color, str(spec[7]), 
		base + Vector2(float(spec[0]), float(spec[1]) - 10.0), float(spec[2]), edge, 20.0, true, rim)


func _fbtn(id: String, cell: String, at: Vector2, enabled: bool) -> void :
	if enabled:
		_fbutton(id, cell, at)
	else:
		_fblit(cell, at, 0.0, 0.0, OFF)

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(TankRentAtlas.SIZE[0]), float(TankRentAtlas.SIZE[1]))
	var frame: Rect2 = _fblit("trent_frame", o + _v(TankRentAtlas.FRAME))
	_hit("panel", frame, false)
	var n: Dictionary = TankRentAtlas.NODES
	var alive: bool = not levels().is_empty()
	var now: int = int(Time.get_unix_time_from_system())
	_draw_cells(o)
	_draw_prices(o)
	_draw_money(o)
	var left: Dictionary = rented(_level, now)
	if not left.is_empty():
		var spec: Array = TankRentAtlas.TEXTS["lblRentDesc"]
		_label(spec, LEFT.replace("@time@", time_text(int(left.get("m_existTime", 0)) - now)), o, Color(str(spec[5])))
	if owned().is_empty() and not chips().is_empty():
		_draw_exchange(o)
	_fblit("trent_chk_on" if _present else "trent_chk_off", o + _v(n["chkPresent"]))
	_hit("present_chk", Rect2((o + _v(n["chkPresent"])) * _f, Vector2(22, 23) * _f), false)
	_fput(_friend, Rect2(o + _v(n["txtFriendName"]) + Vector2(14, 0), Vector2(float(n["txtFriendName"][2]) - 28.0, float(n["txtFriendName"][3]))), 14.0)
	_fbutton("friend", "trent_friend", o + _v(n["btnFriend"]))
	if _present:
		_fbtn("present", "trent_present", o + _v(n["btnRentPresent"]), alive)
	else:
		_fbtn("rent", "trent_rent", o + _v(n["btnRent"]), rent_ready())
	_fbtn("buy", "trent_buy", o + _v(n["btnBuy"]), alive)
	_fbtn("prev", "trent_prev", o + _v(n["btnPrev"]), alive)
	_fbtn("next", "trent_next", o + _v(n["btnNext"]), alive)
	_fbutton("close", "trent_close", o + _v(n["btnClose"]))
	if _hover == "item":
		_draw_item_tip(o)
	if _pick.open:

		_pick.draw(self, o + Vector2(float(TankRentAtlas.SIZE[0]), float(n["txtFriendName"][1]) - FriendPick.ChatFriend.SIZE.y))


func _draw_cells(o: Vector2) -> void :
	var all: Array = levels()
	var title: String = tank_name()
	var spec: Array = TankRentAtlas.CELL_TEXTS["lblTankName"]
	for k in range(all.size()):
		var level: int = int(all[k])
		var chosen: bool = level == _level
		var cell: Vector2 = o + _v(TankRentAtlas.NODES["cvsTank%d" % k])
		var id: String = "cell:%d" % k
		var tint: Color = _glow(id)
		if not str(CELL_BG[k]).is_empty():
			_fblit(str(CELL_BG[k]) + ("_sel" if chosen else ""), cell + _v(TankRentAtlas.CELL["bg"]), 0.0, 0.0, tint)
		_fblit("trent_plate", cell + _v(TankRentAtlas.CELL["plate"]))
		_fblit("garage_lv_%d" % clampi(level, 0, 11), cell + _v(TankRentAtlas.CELL["level"]))
		_fblit("trent_cbox_s_on" if chosen else "trent_cbox_s_off", cell + _v(TankRentAtlas.CELL["cbox"]))
		_draw_tank(level, cell + _v(TankRentAtlas.CELL["tank"]), float(TankRentAtlas.CELL["zoom"]))
		_label(spec, title, cell, Color(str(spec[5])))
		_hit(id, Rect2(cell * _f, Vector2(120, 152) * _f), false)


func _draw_tank(level: int, c: Vector2, zoom: float) -> void :
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), _tank, level, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), 0, level)
	if TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, c * _f, zoom * _f, _time) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), _tank))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46) * zoom
		TankPortrait.ring(self, pack, item, pod * _f, zoom * _f, _time, 1)
		TankPreview.draw(self, art, (pod - Vector2(0, 52) * zoom) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * zoom * _f, 4, _time)
		TankPortrait.ring(self, pack, item, pod * _f, zoom * _f, _time, 2)


func _draw_prices(o: Vector2) -> void :
	var list: Array = rows()
	var at: Vector2 = o + _v(TankRentAtlas.PRICE["at"])
	var step: float = float(TankRentAtlas.PRICE["row"])
	var p: Dictionary = TankRentAtlas.PRICE_ROW
	var t: Dictionary = TankRentAtlas.PRICE_TEXTS
	var rim: Color = Color(TankRentAtlas.PRICE_GLOW)
	var ink: Color = Color(str(t["lblRentTime"][5]))
	for j in range(_top, mini(list.size(), _top + ROWS)):
		var rec: Dictionary = list[j]
		var r: Vector2 = at + Vector2(0, (j - _top) * step)
		var id: String = "row:%d" % j
		_fblit("trent_pr_bg", r + _v(p["bg"]), 0.0, 0.0, _glow(id))
		_fblit("trent_pr_bg_s", r + _v(p["bg_s"]))
		if j == _day:
			_fblit("trent_pr_sel", r + _v(p["sel"]))
		_fblit("trent_pr_line", r + _v(p["line"]))
		_fblit("trent_cbox_on" if j == _day else "trent_cbox_off", r + _v(p["cbox"]))
		_label(t["lblRentTime"], hire_text(int(rec.get("hire_time", 0))), r, ink, 1.0, rim)
		if int(rec.get("vip_freelv", 0)) > 0:

			_label(t["lblVipRentTimes"], VIP_TIMES.replace("@num1@", "0").replace("@num2@", "0"), r, ink, 1.0, rim)
		else:
			var coin: int = int(rec.get("coin_type", 0))
			if coin in [1, 2, 3]:
				_fblit("trent_coin%d" % coin, r + _v(p["coin"]), float(p["coin"][2]), float(p["coin"][3]))
			var price: Array = t["lblRentPrice"]
			var wide: float = _label(price, str(int(rec.get("price", 0))), r, ink, 1.0, rim)
			if on_sale(rec):
				var y: float = r.y + float(price[1])
				draw_line(Vector2(r.x + float(price[0]), y) * _f, Vector2(r.x + float(price[0]) + wide, y) * _f, ink, maxf(1.0, _f))
				_label(t["lblSalePrice"], str(int(rec.get("agio_price", 0))), r, ink, 1.0, rim)
		var back: int = int(rec.get("back_chip", 0))
		if back == 0:
			_label(t["lblNoRentChips"], NO_CHIPS, r, ink, 1.0, rim)
		else:
			_fblit("trent_chip", r + _v(p["chip"]), float(p["chip"][2]), float(p["chip"][3]))
			_label(t["lblRentChips"], "X %d" % back, r, ink, 1.0, rim)
		_label(t["lblRentDesc"], str(rec.get("desc", "")), r, ink, 1.0, rim)
		_hit(id, Rect2(r * _f, Vector2(530, step) * _f), false)


func _draw_money(o: Vector2) -> void :
	var rec: Dictionary = row()
	if rec.is_empty():
		return
	var coin: int = int(rec.get("coin_type", 0))
	if coin not in [1, 2, 3]:
		return
	var c: Dictionary = TankRentAtlas.CUR
	var have: int = balance(coin)
	var values: Array = [pay(rec), shortfall(rec)]
	var spot: Array = c["value_present"] if coin == 1 else c["value_gold"]
	for k in range(2):
		var base: Vector2 = o + Vector2(float(c["x"][k]), float(c["y"]))
		_fblit("trent_cur_row", base + _v(c["row"]))
		_fblit("trent_coin%d" % coin, base + _v(c["icon"]))
		_fwords(str(COIN_NAMES[coin]), ARIAL_BOLD, 14.0, Color.WHITE, "l", base + _v(c["name"]), float(c["name"][2]), 1.0)
		var value: int = int(values[k])
		var short: bool = value > have
		_fwords(str(value), ARIAL_BOLD, 14.0, NO_PAY if short else CAN_PAY, "r", base + _v(spot), float(spot[2]), 
			1.0 if short else 0.0, 0.0, true, NO_PAY_RIM)
	if coin == 1:
		_fbutton("charge", "trent_charge", o + _v(TankRentAtlas.NODES["btnCharge"]))


func _draw_exchange(o: Vector2) -> void :
	var entry: Array = chips()
	var n: Dictionary = TankRentAtlas.NODES
	var need: int = int(entry[1])
	var have: int = GarageModel.have(client.bags, int(entry[0]))
	_fblit("trent_item_bg", o + _v(n["itemBg"]))
	var quality: int = int(entry[4]) if entry.size() > 4 else 0
	if quality >= 2:
		_fblit("trent_q%d" % mini(quality, 5), o + _v(n["imgQuality"]))
	var box: Rect2 = Rect2((o + _v(n["imgItem"])) * _f, Vector2(float(n["imgItem"][2]), float(n["imgItem"][3])) * _f)
	var icon: Texture2D = pack.picture("l/it/%s.webp" % str(entry[3])) if entry.size() > 3 and not str(entry[3]).is_empty() else null
	if icon != null:
		draw_texture_rect(icon, box, false)
	_hit("item", box, false)
	var bar: Vector2 = o + _v(n["processExchange"])
	_fblit("trent_bar_bg", bar)
	var fill: float = floorf(138.0 * minf(1.0, float(have) / float(need)))
	if fill > 0.0:
		_fpart("trent_bar", bar, Rect2(0, 0, fill, 17))
	var spec: Array = TankRentAtlas.TEXTS["lblTankChips"]
	_label(spec, "%d/%d" % [have, need], o, Color(str(spec[5])))
	_fbtn("exchange", "trent_exchange", o + _v(n["btnExchange"]), have >= need)
	_fbtn("add", "trent_add", o + _v(n["btnAdd"]), have < need)


func _draw_item_tip(o: Vector2) -> void :
	var entry: Array = chips()
	if entry.size() < 3 or str(entry[2]).is_empty():
		return

	if pack != null and int(entry[0]) > 0:
		pack.load_bag()
		var extra: Dictionary = {}
		if not (pack.bag.get("items", {}) as Dictionary).has(str(int(entry[0]))):
			extra = {"name": str(entry[2]), "quality": int(entry[4]) if entry.size() > 4 else 0}
			if entry.size() > 3 and not str(entry[3]).is_empty():
				extra["art"] = "l/it/%s.webp" % str(entry[3])
				extra["icon"] = extra.art
		FlashTip.item(self, FlashTip.simulate(int(entry[0]), pack.bag, extra))
		return
	var at: Vector2 = o + _v(TankRentAtlas.NODES["imgItem"]) + Vector2(0, -30)
	var wide: float = ARIAL_BOLD.get_string_size(str(entry[2]), HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(12.0 * _f))).x / _f + 16.0
	_round(Rect2(at * _f, Vector2(wide, 24) * _f), Color(0, 0, 0, 0.82), 6.0, Color("6fd0ff", 0.6), 1.0)
	_fwords(str(entry[2]), ARIAL_BOLD, 12.0, Color.WHITE, "c", at, wide, 0.0, 24.0)
