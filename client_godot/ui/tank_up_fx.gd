extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")















const Atlas = preload("tank_skin_locked_atlas.gd")
const FlaPlayer = preload("fla_player.gd")
const PopQueue = preload("pop_queue.gd")
const GarSkin = preload("gar_skin_atlas.gd")
const GarageModel = preload("garage_model.gd")
const Garage = preload("garage.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const QuickBuy = preload("quick_buy.gd")
const ShopModel = preload("shop_model.gd")


signal tank_buy_asked(tid: int, now: String, after: String)
signal gold_access_asked

const LOCKED_ID: String = "tank_skin_locked"
const FX: Dictionary = {"level": "fla/tpl", "strengthen": "fla/tps", "light": "fla/tpb"}
const SOUND: Dictionary = {"level": "u/very_happy", "strengthen": "u/small_happy"}
const SHOW: float = 1.5
const FRAME: float = 860.0
const LIGHT_STAGE: float = 400.0
const BANNER_LIFT: float = -116.0
const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const COIN_TOKEN: int = 7
const TIP_81: String = "Nhận tank trước mới được dùng skin!"

const GLOW: Dictionary = {"lblLevlDesc": "11459c", "lblSkinAttr": "e36905", "lblGetTankTip": "0d3d94", "lblPrice": "751011"}

var queue: PopQueue
var _prosit: Dictionary = {}
var _nodes: Dictionary = {}
var _car: Control
var _locked: Dictionary = {}
var _http: HTTPRequest
var _ticket: int = 0
var _warm: bool = false

func chat_busy() -> bool:
	return not _locked.is_empty() and visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_use(Atlas.FILE, Atlas.R)
	if queue == null:
		queue = PopQueue.new()
		queue.client = client
		add_child(queue)
	queue.register(LOCKED_ID, _open_locked)
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_goods)
	if client != null:
		client.tank_changed.connect(_on_tank_changed)
		client.changed.connect(_on_state)


func _warm_up() -> void :
	if _warm or pack == null or pack.state != "ready":
		return
	_warm = true
	for key: String in FX.values():
		pack.effect(key, true)
	for key: String in SOUND.values():
		pack.sound("s/%s.mp3" % key, true)

func _on_state() -> void :
	if client == null:
		return
	_warm_up()
	if client.state not in PopQueue.LIVE:
		_stop_prosit()
		_locked = {}
		mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh()


func _refresh() -> void :
	var want: bool = ( not _prosit.is_empty() or not _locked.is_empty()) and client != null and client.state in PopQueue.OPEN_IN
	if visible != want:
		visible = want



func _on_tank_changed(uuid: String, op: int) -> void :
	if op not in [2, 4] or client == null or not client.tanks.has(uuid) or client.state not in PopQueue.OPEN_IN:
		return
	_warm_up()
	var strengthen: bool = op == 4
	_stop_prosit()
	_prosit = {"uuid": uuid, "strengthen": strengthen, "at": _time}
	_car = Control.new()
	_car.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_car.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_car.draw.connect(_paint_car)
	add_child(_car)
	Sound.play(str(SOUND["strengthen" if strengthen else "level"]))
	_refresh()

func _stop_prosit() -> void :
	for player: Variant in _nodes.values():
		if is_instance_valid(player):
			player.queue_free()
	_nodes = {}
	if is_instance_valid(_car):
		_car.queue_free()
	_car = null
	_prosit = {}


func _end_prosit() -> void :
	var uuid: String = str(_prosit.uuid)
	var strengthen: bool = bool(_prosit.strengthen)
	_stop_prosit()
	_refresh()
	if strengthen or client == null or not client.tanks.has(uuid):
		return
	var inst: Dictionary = client.tanks[uuid]
	if not locked_skin(int(inst.get("m_tpltId", 0)), int(inst.get("m_level", 0))).is_empty():
		queue.append(LOCKED_ID, {"uuid": uuid})


static func locked_skin(tank: int, level: int) -> Array:
	for row: Array in GarSkin.SKINS.get(str(tank), []):
		if int(row[4]) == level:
			return row
	return []


func _prosit_at() -> Vector2:
	return _stage() + Vector2(int((1000.0 - FRAME) / 2.0), int((600.0 - FRAME) / 2.0))


func _prosit_tick() -> void :
	if _time - float(_prosit.at) >= SHOW:
		_end_prosit()
		return
	var keys: Dictionary = {"light": str(FX.light), "banner": str(FX["strengthen" if bool(_prosit.strengthen) else "level"])}
	for name: String in keys:
		if _nodes.has(name):
			continue
		var fx: Dictionary = pack.effect(str(keys[name]))
		if not FlaPlayer.valid(fx.get("data")):
			continue
		var player: FlaPlayer = FlaPlayer.new()
		if player.add_clip(fx) < 0:
			player.free()
			continue
		add_child(player)
		_nodes[name] = player
		if name == "banner":
			_prosit.stage = (fx.data as Dictionary).get("stage", [400, 200])
		if name == "light":
			move_child(player, _car.get_index())
	var top: Vector2 = _prosit_at()
	var centre: Vector2 = top + Vector2(FRAME, FRAME) / 2.0
	if _nodes.has("light"):
		var k: float = FRAME / LIGHT_STAGE
		_nodes.light.transform = Transform2D(0.0, Vector2(k * _f, k * _f), 0.0, top * _f)
	if _nodes.has("banner"):
		var stage: Array = _prosit.get("stage", [400, 200])
		var at: Vector2 = centre + Vector2( - float(stage[0]) / 2.0, BANNER_LIFT - float(stage[1]) / 2.0)
		_nodes.banner.transform = Transform2D(0.0, Vector2(_f, _f), 0.0, at.round() * _f)
	if is_instance_valid(_car):
		_car.queue_redraw()


func _paint_car() -> void :
	if _prosit.is_empty() or client == null or pack == null or not client.tanks.has(str(_prosit.uuid)):
		return
	var inst: Dictionary = client.tanks[str(_prosit.uuid)]
	var tank: int = int(inst.get("m_tpltId", 0))
	var level: int = maxi(1, int(inst.get("m_level", 1)))
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank, level, inst)
	var halo: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(inst.get("m_haloId", 0)), level)
	_tank_face(_car, ext, tank, halo, _prosit_at() + Vector2(FRAME, FRAME) / 2.0, 1.0)


func _tank_face(canvas: CanvasItem, ext: int, tank: int, halo: int, c: Vector2, zoom: float) -> void :
	var face: String = GarageModel.face(pack.garage, ext)
	if TankPortrait.draw(canvas, pack, face, halo, c * _f, zoom * _f, _time) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tank))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46) * zoom
		TankPreview.draw(canvas, art, (pod - Vector2(0, 52) * zoom) * _f, minf(1.7, 160.0 / TankPreview.extent(art)) * zoom * _f, 4, _time)

func _tick(_delta: float) -> void :
	if not _prosit.is_empty():
		_prosit_tick()



func _open_locked(value: Variant) -> bool:
	if not value is Dictionary or client == null or pack == null:
		return false
	var uuid: String = str((value as Dictionary).get("uuid", ""))
	if not client.tanks.has(uuid):
		return false
	var inst: Dictionary = client.tanks[uuid]
	var tank: int = int(inst.get("m_tpltId", 0))
	var level: int = int(inst.get("m_level", 0))
	var row: Array = locked_skin(tank, level)
	if row.is_empty():
		return false
	_ticket += 1
	_locked = {"uuid": uuid, "inst": inst.duplicate(), "tank": tank, "level": level, "row": row, "goods": {}, "price": -1, "ticket": _ticket}
	_hover = ""
	_press = ""
	mouse_filter = Control.MOUSE_FILTER_STOP
	pack.load_garage()
	pack.load_garagex()
	if tank_owned(inst) and not skin_held(int(row[0])):
		_query(int(row[0]))
	_refresh()
	return true

func close() -> void :
	if _locked.is_empty():
		return
	_locked = {}
	_ticket += 1
	_http.cancel_request()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_refresh()
	queue.closed()


static func tank_owned(inst: Dictionary) -> bool:
	return not str(inst.get("m_tankUuid", "")).is_empty() and int(inst.get("m_contType", -1)) == GarageModel.OWN


func skin_held(item: int) -> bool:
	for inst: Variant in client.bags.get(6, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == item and int(inst.get("m_count", 0)) > 0:
			return true
	return false


func _query(tid: int) -> void :
	_http.cancel_request()
	var url: String = client.config.origin + "/goodsshopquickquery.php?tid=%d&char=%s&noCache=%d" % [tid, client.char_uuid.uri_encode(), randi() % 1000000]
	var ticket: int = _ticket
	_http.set_meta("ticket", ticket)
	_http.request(url, AppSession.headers(url))


func _on_goods(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	if _locked.is_empty() or int(_http.get_meta("ticket", -1)) != int(_locked.ticket):
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		return
	var rec: Dictionary = QuickBuy.parse_last(body)
	if rec.is_empty():
		return
	_locked.goods = rec
	_locked.price = goods_price(rec)

static func goods_price(rec: Dictionary) -> int:
	if int(rec.get("ct", 0)) == COIN_TOKEN:
		return int((rec.a if bool(rec.agio) else rec.p)[0])
	if int(rec.get("ct2", 0)) == COIN_TOKEN:
		return int((rec.a2 if bool(rec.agio) else rec.p2)[0])
	return -1

func tokens() -> int:
	return GarageModel.have(client.bags, Atlas.TOKEN) if client != null else 0


func skin_attr() -> String:
	var quality: int = int(GarSkin.EXTQ.get(str(int(_locked.row[1])), 0))
	if quality < 2 or quality > 5:
		return ""
	return Garage.skin_type_desc(pack.garagex.get("skin", {}).get(str(int(_locked.tank)), []), quality - 1, GarSkin.BUFF)

func _activate(id: String) -> void :
	match id:
		"close":
			close()
		"buy_tank":
			var tank: int = int(_locked.tank)
			close()
			tank_buy_asked.emit(tank, "", TIP_81)
		"buy_skin":
			var goods: Dictionary = _locked.goods
			if goods.is_empty():
				return
			var price: int = int(_locked.price)
			if price < 0 or tokens() < price:
				gold_access_asked.emit()
			elif not client.buy_goods(ShopModel.BUY, int(goods.gid), COIN_TOKEN, price, 1):
				say("Chưa kết nối máy chủ, thử lại sau.")
				return
			close()

func _unhandled_key_input(event: InputEvent) -> void :

	if _locked.is_empty() or not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close()
	elif event.keycode not in [KEY_ENTER, KEY_KP_ENTER]:
		return
	get_viewport().set_input_as_handled()



func _v(at: Array) -> Vector2:
	return Vector2(float(at[0]), float(at[1]))


func _label(spec: Array, parts: Array, base: Vector2, rim: Color) -> void :
	var px: float = float(spec[4])
	var font: Font = _face(ARIAL_BOLD if int(spec[6]) == 1 else ARIAL)
	var font_size: int = maxi(6, roundi(px * _f))
	var widths: Array = []
	var total: float = 0.0
	for part: Array in parts:
		var w: float = font.get_string_size(str(part[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f
		widths.append(w)
		total += w
	var at: Vector2 = base + _v(spec)
	if str(spec[7]) == "c":
		at.x += (float(spec[2]) - total) / 2.0
	for i in range(parts.size()):
		_fwords(str(parts[i][0]), font, px, parts[i][1], "l", at, float(widths[i]) + 2.0, 1.0, 0.0, false, rim)
		at.x += float(widths[i])

func _paint() -> void :
	if _locked.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	var frame: Rect2 = _fblit("tsl_frame", o + _v(Atlas.FRAME_AT))
	_hit("panel", frame, false)
	var n: Dictionary = Atlas.NODES
	var t: Dictionary = Atlas.TEXTS
	var w: Dictionary = Atlas.WORDS
	var ink: Color = Color(Atlas.NUMBER)
	var row: Array = _locked.row
	var tank: int = int(_locked.tank)
	var level: int = int(_locked.level)
	var desc: PackedStringArray = str(w["CONTROL_TEXT510"]).split("@num1@")
	_label(t["lblLevlDesc"], [[desc[0], Color(str(t["lblLevlDesc"][5]))], [str(level), ink], [desc[1] if desc.size() > 1 else "", Color(str(t["lblLevlDesc"][5]))]], 
		o, Color(str(GLOW["lblLevlDesc"])))
	var base: Array = Atlas.AVATAR["base"]
	var fresh: Array = Atlas.AVATAR["new"]
	_tank_face(self, GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank, level, {}), tank, 0, o + _v(base), float(base[2]))
	_tank_face(self, int(row[1]), tank, 0, o + _v(fresh), float(fresh[2]))
	var attr: PackedStringArray = str(w["CONTROL_TEXT509"]).split("@text1@")
	_label(t["lblSkinAttr"], [[attr[0], Color(str(t["lblSkinAttr"][5]))], [skin_attr(), ink], [attr[1] if attr.size() > 1 else "", Color(str(t["lblSkinAttr"][5]))]], 
		o, Color(str(GLOW["lblSkinAttr"])))
	if not tank_owned(_locked.inst):
		_label(t["lblGetTankTip"], [[str(w["CONTROL_TEXT508"]), Color(str(t["lblGetTankTip"][5]))]], o, Color(str(GLOW["lblGetTankTip"])))
		_fbutton("buy_tank", "tsl_buy_tank", o + _v(n["btnBuyTank"]))
	elif not (_locked.goods as Dictionary).is_empty():
		_fblit("tsl_price", o + _v(Atlas.PRICE_AT))
		var box: Vector2 = o + _v(n["cvsGoodsInfo"])
		_fblit("tsl_token", box + _v(Atlas.GOODS["icon"]))
		var price: int = int(_locked.price)
		if price >= 0:
			_fwords(str(price), ARIAL_BOLD, 16.0, Color.WHITE, "l", box + _v(Atlas.GOODS["price"]), 90.0, 1.0, 0.0, true, Color(str(GLOW["lblPrice"])))
		_fbutton("buy_skin", "tsl_buy_skin", o + _v(n["btnBuySkin"]))
	_fbutton("close", "tsl_close", o + _v(n["btnClose"]))
