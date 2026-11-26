extends "flash_screen.gd"









const OpenSkinAtlas = preload("open_skin_atlas.gd")
const GarSkin = preload("gar_skin_atlas.gd")
const GarageModel = preload("garage_model.gd")
const FlashTip = preload("flash_tip.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const ShopModel = preload("shop_model.gd")
const Mysterious = preload("mysterious_store.gd")

signal closed(note: String)

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const COIN_CASH: int = 1
const COIN_TOKEN: int = 7
const TIP_CASH: String = "Xu không đủ, hãy nạp tiền"
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."
const TIPS_WIDE: float = 225.0

const QUALITY_INK: Dictionary = {2: Color("15ee19"), 3: Color("06fffc"), 4: Color("ff6eff"), 5: Color("f18819")}

var _skin: int = 0
var _row: Array = []
var _tank: int = 0
var _rises: Array = []
var _bag_rev: int = -1

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(OpenSkinAtlas.FILE, OpenSkinAtlas.R)
	var shared: Dictionary = {}
	for key: String in ["gar_skin_ach_icon", "gar_skin_ach_bar", "gar_skin_ach_slot", "gar_skin_coin1"]:
		shared[key] = GarSkin.R[key]
	_use(GarSkin.FILE, shared)
	if client != null:
		client.skin_chip_added.connect(_on_chip_added)


func open(skin: int) -> void :
	_skin = skin
	_row = []
	_tank = 0
	for key: String in GarSkin.SKINS:
		for row: Array in GarSkin.SKINS[key]:
			if int(row[0]) == skin and _row.is_empty():
				_row = row
				_tank = int(key)
	_rises = []
	_toast = ""
	_hover = ""
	_press = ""
	if pack != null:
		pack.load_bag()
	_bag_rev = client.bag_rev if client != null else -1
	visible = true

func close(note: String = "") -> void :
	if not visible:
		return
	visible = false
	_rises = []
	closed.emit(note)

func chat_busy() -> bool:
	return visible

func current_skin() -> int:
	return _skin




func chip() -> Array:
	return OpenSkinAtlas.CHIP.get(str(_skin), [])


func schedule() -> int:
	return int(client.skin_chips.get(_skin, 0)) if client != null else 0


func tokens() -> int:
	return GarageModel.have(client.bags, int(OpenSkinAtlas.TOKEN)) if client != null else 0

func cash() -> int:
	return ShopModel.balance(client.currency, COIN_CASH) if client != null else 0


func owned() -> bool:
	if client == null:
		return false
	for inst: Variant in client.bags.get(6, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == _skin and int(inst.get("m_count", 0)) > 0:
			return true
	return false


func _buy(batch: bool) -> void :
	var row: Array = chip()
	if row.is_empty():
		return
	var token_cost: int = int(row[4] if batch else row[2])
	var cash_cost: int = int(row[3] if batch else row[1])
	var coin: int = COIN_TOKEN
	if token_cost > tokens():
		if cash_cost > cash():
			say(TIP_CASH)
			return
		coin = COIN_CASH
	if not client.buy_skin_chip(_skin, coin, batch):
		say(OFFLINE)


func _on_chip_added(skin: int, delta: int) -> void :
	if not visible or skin != _skin:
		return
	var rise: Dictionary = OpenSkinAtlas.RISE
	_rises.append([str(OpenSkinAtlas.WORDS["TIP_653"]).replace("@num1@", str(delta)), Color(str(rise["big" if delta > 1 else "small"])), _time])

func _tick(_delta: float) -> void :
	if client != null and client.bag_rev != _bag_rev:

		_bag_rev = client.bag_rev
		if owned():
			close("")
			return
	var life: float = float(OpenSkinAtlas.RISE["time"])
	_rises = _rises.filter( func(r: Array) -> bool: return _time - float(r[2]) < life)

func _activate(id: String) -> void :
	match id:
		"close":
			close("")
		"buy1":
			_buy(false)
		"buy10":
			_buy(true)

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


func _label(spec: Array, text: String, base: Vector2, middle: bool) -> void :
	var at: Vector2 = base + _v(spec) - (Vector2(0, 10) if middle else Vector2.ZERO)
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), Color(str(spec[5])), str(spec[7]), at, float(spec[2]), 1.0, 
		20.0 if middle else 0.0, true, Color(OpenSkinAtlas.GLOW))

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(OpenSkinAtlas.SIZE[0]), float(OpenSkinAtlas.SIZE[1]))
	var frame: Rect2 = _fblit("open_skin_frame", o + _v(OpenSkinAtlas.FRAME_AT))
	_hit("panel", frame, false)
	var n: Dictionary = OpenSkinAtlas.NODES
	var w: Dictionary = OpenSkinAtlas.WORDS
	var t: Dictionary = OpenSkinAtlas.TEXTS
	_draw_avatar(o)
	if not _row.is_empty():
		_label(t["lblSkinName"], str(_row[3]), o, false)
	_draw_achieve(o)
	_label(t["lblTips"], str(w["TIPS"]), o, true)
	var token_name: String = str((pack.bag.get("items", {}).get(str(OpenSkinAtlas.TOKEN), [""]) as Array)[0])
	_label(t["lblBoxCount"], str(w["TIP_652"]).replace("@name@", token_name).replace("@num1@", str(tokens())), o, true)
	var row: Array = chip()
	if not row.is_empty():
		_draw_price(o + _v(OpenSkinAtlas.PRICE["one"]), int(row[1]), int(row[2]))
		_draw_price(o + _v(OpenSkinAtlas.PRICE["ten"]), int(row[3]), int(row[4]))
	_fbutton("buy1", "open_skin_buy1", o + _v(n["btnBuy1"]))
	_fbutton("buy10", "open_skin_buy10", o + _v(n["btnBuy10"]))
	_fbutton("close", "open_skin_close", o + _v(n["btnClose"]))
	_draw_rises(o)
	if _hover == "avatar" and not _row.is_empty():
		_draw_tip(o)


func _draw_avatar(o: Vector2) -> void :
	var box: Array = OpenSkinAtlas.NODES["avSkin"]
	var zoom: float = float(OpenSkinAtlas.AVATAR["zoom"])
	_hit("avatar", Rect2((o + _v(box)) * _f, Vector2(float(box[2]), float(box[3])) * zoom * _f), false)
	if _row.is_empty():
		return
	var ext: int = int(_row[1])
	var c: Vector2 = o + _v(OpenSkinAtlas.AVATAR["at"])
	var key: String = GarageModel.face(pack.garage, ext)
	var folder: String = "l/t"
	if not key.is_empty() and pack.garage.get("big", []).has(key) and pack.picture("l/tb/%s.webp" % key) != null:
		folder = "l/tb"
	if TankPortrait.draw(self, pack, key, 0, c * _f, zoom * _f, _time, folder) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), _tank))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46) * zoom
		TankPreview.draw(self, art, (pod - Vector2(0, 52) * zoom) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * zoom * _f, 4, _time)


func _draw_achieve(o: Vector2) -> void :
	var a: Dictionary = OpenSkinAtlas.ACHIEVE
	var com: Vector2 = o + _v(a["at"])
	_fblit("gar_skin_ach_icon", com + _v(a["icon"]))
	_fblit("gar_skin_ach_bar", com + _v(a["bar"]))
	var row: Array = chip()
	var need: int = int(row[0]) if not row.is_empty() else 0
	var have: int = schedule()
	if need > 0:
		var slot: Array = a["slot"]
		var fill: float = floorf(float(slot[2]) * clampf(float(have) / float(need), 0.0, 1.0))
		if fill > 0.0:
			_fpart("gar_skin_ach_slot", com + _v(slot), Rect2(0, 0, fill, float(slot[3])))
		var num: Array = OpenSkinAtlas.ACHIEVE_TEXTS["lblNum"]
		_fwords("%d/%d" % [have, need], ARIAL_BOLD, float(num[4]), Color(str(num[5])), "c", o + _v(num), float(num[2]), 1.0, 0.0, true, 
			Color(OpenSkinAtlas.GLOW))
	var tips: Array = OpenSkinAtlas.ACHIEVE_TEXTS["lblTips"]
	var lines: PackedStringArray = _wrap(str(OpenSkinAtlas.WORDS["TIP_169"]), float(tips[4]), TIPS_WIDE)
	for k in range(lines.size()):
		_fwords(lines[k], ARIAL_BOLD, float(tips[4]), Color(str(tips[5])), "l", o + _v(tips) + Vector2(0, 16.0 * k), TIPS_WIDE, 1.0, 0.0, 
			true, Color(OpenSkinAtlas.GLOW))


func _wrap(text: String, px: float, wide: float) -> PackedStringArray:
	var font: Font = _face(ARIAL_BOLD)
	var font_size: int = maxi(6, roundi(px * _f))
	var lines: PackedStringArray = []
	var line: String = ""
	for word: String in text.split(" ", false):
		var next: String = word if line.is_empty() else line + " " + word
		if not line.is_empty() and font.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > wide * _f:
			lines.append(line)
			line = word
		else:
			line = next
	if not line.is_empty():
		lines.append(line)
	return lines


func _draw_price(at: Vector2, cash_cost: int, token_cost: int) -> void :
	var p: Dictionary = OpenSkinAtlas.PRICE
	var k: float = float(p["scale"])
	_price_label(at, "gar_skin_coin1", cash_cost, cash() < cash_cost, k)
	_fwords(str(OpenSkinAtlas.WORDS["OR"]), ARIAL_BOLD, 14.0 * k, Color(str(p["or_color"])), "l", at + Vector2(float(p["or_x"]), float(p["or_y"])) * k, 
		40.0 * k, 1.0, 0.0, true, Color(OpenSkinAtlas.GLOW))
	_price_label(at + Vector2(float(p["second_x"]) * k, 0), "open_skin_token", token_cost, tokens() < token_cost, k)


func _price_label(at: Vector2, icon: String, price: int, short: bool, k: float) -> void :
	var p: Dictionary = OpenSkinAtlas.PRICE
	var box: Array = p["icon"]
	_fblit(icon, at + _v(box) * k, float(box[2]) * k, float(box[3]) * k)
	var count: Array = p["count"]
	_fwords(Mysterious.comma(price), ARIAL_BOLD, 14.0 * k, Color(str(p["short" if short else "color"])), "l", at + _v(count) * k, float(count[2]) * k, 1.0, 
		0.0, true, Color(OpenSkinAtlas.GLOW))


func _draw_rises(o: Vector2) -> void :
	var rise: Dictionary = OpenSkinAtlas.RISE
	var start: Vector2 = _v(rise["at"])
	var life: float = float(rise["time"])
	for r: Array in _rises:
		var p: float = clampf((_time - float(r[2])) / life, 0.0, 1.0)
		var y: float = lerpf(start.y, float(rise["to"]), 1.0 - (1.0 - p) * (1.0 - p))
		var wide: float = _face(ARIAL_BOLD).get_string_size(str(r[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(14.0 * _f))).x / _f + 4.0
		_fwords(str(r[0]), ARIAL_BOLD, 14.0, r[1], "l", o + Vector2(start.x, y), wide, 1.0, 0.0, false)


func _draw_tip(o: Vector2) -> void :

	if pack != null and int(_row[0]) > 0:
		var extra: Dictionary = {}
		if not (pack.bag.get("items", {}) as Dictionary).has(str(int(_row[0]))):
			extra = {"name": str(_row[3]), "quality": int(_row[2]), "type": 29, "desc": str(_row[7])}
		FlashTip.item(self, FlashTip.simulate(int(_row[0]), pack.bag, extra))
		return
	var box: Array = OpenSkinAtlas.NODES["avSkin"]
	var zoom: float = float(OpenSkinAtlas.AVATAR["zoom"])
	var anchor: Rect2 = Rect2(o + _v(box), Vector2(float(box[2]), float(box[3])) * zoom)
	var body: String = GarageModel._marked(str(_row[7]).replace("\n", ""), "", "").strip_edges()
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x + 6.0, anchor.position.y)
	if at.x + wide > _fw:
		at.x = anchor.position.x - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	var q: int = int(_row[2])
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_row[3]), BOLD, 13.0, QUALITY_INK.get(q, Color.WHITE if q <= 1 else QUALITY_INK[5]), "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 8)
