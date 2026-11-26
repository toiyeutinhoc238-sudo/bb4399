extends "flash_screen.gd"














const Atlas = preload("newbie_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const PopQueue = preload("pop_queue.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const POP_ID: String = "newbie_login"

signal closed

const FIRST: int = 1800
const LAST: int = 1809
const TYPE: int = 18
const TYRO: int = 512
const SIZE: Vector2 = Vector2(813, 529)
const DIM: Color = Color(0, 0, 0, 0.4)
const SHOW_IN: Array = ["lobby", "hall", "room"]
const DAY_RIM: Color = Color("0372af")
const NUM_RIM: Color = Color("005797")
const MONEY: int = 2
const RESEND: float = 3.0

var queue: PopQueue
var opened: bool = false
var selected: int = -1
var _seen: int = -1
var _auto: bool = true
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _greys: Dictionary = {}
var _asked: int = 0
var _asked_at: float = -100.0

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	if queue == null:
		queue = PopQueue.new()
		queue.client = client
		add_child(queue)
	queue.register(POP_ID, _open)
	if client != null:
		client.changed.connect(_pump)
		client.stage_reaped.connect( func(_result: int, stage: int) -> void :
			if stage == _asked:
				_asked = 0)




static func current(source: Client) -> int:
	if source == null:
		return 0
	var best: int = 0
	for key: Variant in source.stages.keys():
		var stage: int = int(key)
		if stage >= FIRST and stage <= LAST and stage > best:
			best = stage
	return best


static func cleared(source: Client) -> bool:
	if source == null:
		return false
	for key: Variant in source.stages_cleared.keys():
		if int(key) >= FIRST and int(key) <= LAST:
			return true
	return false


static func shown(source: Client) -> bool:
	return current(source) > 0 and not cleared(source)


static func due(source: Client) -> bool:
	var now: int = current(source)
	return now > 0 and int((source.stages[now] as Dictionary).get("reward", 0)) == 1


static func login_day(source: Client) -> int:
	if source == null:
		return 0
	var progress: Array = source.stage_progress.get(TYPE, [])
	if not progress.is_empty() and not (progress[0] as Array).is_empty():
		return int(progress[0][0])
	var now: int = current(source)
	return int((source.stages[now] as Dictionary).get("value", 0)) if now > 0 else 0


static func index_of(stage: int) -> int:
	for i in range(Atlas.STAGES.size()):
		if int(Atlas.STAGES[i][0]) == stage:
			return i
	return -1


func button() -> String:
	var now: int = current(client)
	if now <= 0 or selected < 0 or selected >= Atlas.STAGES.size():
		return ""
	var stage: int = int(Atlas.STAGES[selected][0])
	if stage > now:
		return ""
	if stage < now or cleared(client):
		return "off"
	return "on" if due(client) else ""


func got(index: int) -> bool:
	return cleared(client) or int(Atlas.STAGES[index][0]) < current(client)




func open() -> void :
	if client == null or current(client) <= 0 or client.state not in SHOW_IN:
		return
	opened = true
	_select_now()
	_pump()


func _open(_param: Variant) -> bool:
	if opened or current(client) <= 0:
		return false
	opened = true
	_select_now()
	_pump()
	return true

func _select_now() -> void :
	_seen = current(client)
	selected = index_of(_seen)


func _pump() -> void :
	if client == null:
		return
	if client.state not in SHOW_IN and client.state != "battle":
		opened = false
		_auto = true
		selected = -1
		_seen = -1
		_asked = 0
	elif _auto and shown(client):
		_auto = false
		if (int(client.character.get("actionFlag", 0)) & TYRO) != 0 and due(client) and not opened and not queue.has(POP_ID):
			queue.append(POP_ID)
	if opened:
		var now: int = current(client)
		if now != _seen:
			_seen = now
			selected = index_of(now)
			_asked = 0
	var want: bool = opened and client.state in SHOW_IN
	if visible != want:
		visible = want

func close() -> void :
	if not opened:
		return
	opened = false
	visible = false
	_tip = []
	closed.emit()
	if queue.popping == POP_ID:
		queue.closed()



func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _item(id: int) -> Array:
	return Atlas.ITEMS.get(str(id), ["", "", 0, ""])

func _paint() -> void :
	if not opened:
		return
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	_tip = []
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(SIZE.x, SIZE.y)
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_fblit("nb_frame", base + _xy(Atlas.FRAME))
	for i in range(mini(Atlas.BOXES.size(), Atlas.STAGES.size())):
		_draw_box(base, i)
	if selected >= 0 and selected < Atlas.STAGES.size():
		var row: Array = Atlas.STAGES[selected]
		_draw_gifts(base, row[4])
		_label("lblDayDesc", Atlas.DAY_DESC % int(row[1]), base, DAY_RIM, 1.0)
	_label("txtCurLoginDay", Atlas.LOGIN % login_day(client), base, SHADE, 0.0)
	var state: String = button()
	var spot: Vector2 = base + _xy(Atlas.NODES["btnGetAward"])
	if state == "on":
		_fbutton("get", "nb_get", spot)
		_draw_fx(2, base + _xy(Atlas.NODES["swfGetAwardEffect"]))
	elif state == "off":
		_fblit("nb_get_off", spot)
	_fbutton("close", "nb_close", base + _xy(Atlas.NODES["btnClose"]))
	_draw_tip()


func _draw_box(base: Vector2, index: int) -> void :
	var spot: Array = Atlas.BOXES[index]
	var kind: String = "big" if int(spot[2]) == 1 else "small"
	var part: Dictionary = Atlas.BOX[kind]
	var at: Vector2 = base + _xy(spot)
	var row: Array = Atlas.STAGES[index]
	var rare: bool = bool(row[3])
	var done: bool = got(index)
	var rect: Rect2 = _fblit("nb_" + kind, at)
	if rare:
		_fblit("nb_%s_rare" % kind, at)
	var art: String = str(_item(int(row[2]))[1])
	var picture: Texture2D = pack.picture(art) if pack != null and not art.is_empty() else null
	var box: Array = part["item"]
	_fit(_red_grey(picture) if done else picture, at + _xy(box), Vector2(float(box[2]), float(box[3])))
	if index == selected:
		_fblit("nb_%s_sel" % kind, at + _xy(part["select"]))
	if rare:
		_draw_fx(1 if kind == "big" else 0, at + _xy(part["rare"]))
	if done:
		_fblit("nb_got", at + _xy(part["got"]))
	_hit("box:%d" % index, rect, false)


func _draw_gifts(base: Vector2, gifts: Array) -> void :
	var mouse: Vector2 = get_local_mouse_position()
	var box: Array = Atlas.TILE["item"]
	var span: Vector2 = Vector2(float(box[2]), float(box[3]))
	var num: Array = Atlas.TILE["num"]
	for j in range(mini(gifts.size(), Atlas.DETAIL.size())):
		var gift: Array = gifts[j]
		var at: Vector2 = base + _xy(Atlas.DETAIL[j])
		var rect: Rect2 = _fblit("nb_tile", at + _xy(Atlas.TILE["bg"]))
		if int(gift[0]) == MONEY:
			var coin: String = "nb_coin%d" % int(gift[1])
			if _cells.has(coin):
				var cell: Vector2 = _cell_size(coin)
				var k: float = minf(span.x / cell.x, span.y / cell.y)
				_fblit(coin, at + _xy(box), cell.x * k, cell.y * k)
		else:
			var info: Array = _item(int(gift[1]))
			var quality: int = int(info[2])
			if quality >= 2:
				_fblit("nb_q%d" % mini(quality, 5), at + _xy(Atlas.TILE["quality"]))
			var art: String = str(info[1])
			_fit(pack.picture(art) if pack != null and not art.is_empty() else null, at + _xy(box), span)
			if _tip_ok() and _hover == "panel" and rect.has_point(mouse) and not str(info[0]).is_empty():
				var rec: Dictionary = _gift_rec({"id": int(gift[1]), "name": GarageModel.cap(BagModel.clean(str(info[0]))), 
					"desc": GarageModel.plain(str(info[3])), "quality": quality, "art": art})
				_tip = [rect, "", "", Color.WHITE, rec] if not rec.is_empty() else [rect, GarageModel.cap(BagModel.clean(str(info[0]))), 
					GarageModel.plain(str(info[3])), BagModel.tint(quality, Color.WHITE)]
		_fwords(str(int(gift[2])), ARIAL_BOLD, 12.0, Color.WHITE, "r", at + Vector2(float(num[0]), float(num[1])), float(num[2]), 
			1.0, 0.0, false, NUM_RIM)


func _fit(picture: Texture2D, at: Vector2, box: Vector2) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(box.x / picture.get_width(), box.y / picture.get_height())
	draw_texture_rect(picture, Rect2(at * _f, Vector2(picture.get_size()) * k * _f), false)


func _label(key: String, text: String, base: Vector2, rim: Color, edge: float) -> void :
	var spec: Array = Atlas.TEXTS[key]
	var wide: float = float(spec[2])
	var font: Font = ARIAL_BOLD if int(spec[6]) == 1 else ARIAL
	if wide <= 0.0:
		wide = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(float(spec[4]) * _f))).x / _f + 4.0
	_fwords(text, font, float(spec[4]), Color(str(spec[5])), str(spec[7]), base + Vector2(float(spec[0]), float(spec[1])), wide, 
		edge, 0.0, false, rim)


func _draw_fx(index: int, at: Vector2) -> void :
	if pack == null:
		return
	var fx: Dictionary = pack.effect(str(Atlas.FX[index][0]))
	var frames: Array = fx.get("data", {}).get("frames", [])
	if frames.is_empty():
		return
	_draw_film(fx, int(_time * Atlas.FX_FPS) % frames.size(), Transform2D(0.0, Vector2(_f, _f), 0.0, at * _f))
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_film(fx: Dictionary, index: int, place: Transform2D) -> void :
	var frames: Array = fx.get("data", {}).get("frames", [])
	var pages: Array = fx.get("pages", [])
	if index < 0 or index >= frames.size():
		return
	var cell: Dictionary = frames[index]
	var page: int = int(cell.get("page", 0))
	if page >= pages.size() or pages[page] == null:
		return
	var rect: Array = cell.get("rect", [0, 0, 0, 0])
	var pivot: Array = cell.get("pivot", [0, 0])
	var src: Rect2 = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	draw_set_transform_matrix(place)
	draw_texture_rect_region(pages[page], Rect2( - Vector2(float(pivot[0]), float(pivot[1])), src.size), src)


func _red_grey(texture: Texture2D) -> Texture2D:
	if texture == null or texture.get_width() <= 4:
		return texture
	var key: int = texture.get_instance_id()
	if _greys.has(key):
		return _greys[key]
	var image: Image = texture.get_image()
	if image == null or image.is_empty():
		_greys[key] = texture
		return texture
	image = image.duplicate()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	var data: PackedByteArray = image.get_data()
	for i: int in range(0, data.size(), 4):
		data[i + 1] = data[i]
		data[i + 2] = data[i]
	var out: ImageTexture = ImageTexture.create_from_image(Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, data))
	_greys[key] = out
	return out



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



func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "get":
		reap()
	elif id.begins_with("box:"):
		var index: int = int(id.substr(4))
		if index >= 0 and index < Atlas.STAGES.size():
			selected = index


func reap() -> bool:
	if button() != "on":
		return false
	var now: int = current(client)
	if _asked == now and _time - _asked_at < RESEND:
		return false
	if not client.stage_reap(now, false):
		return false
	_asked = now
	_asked_at = _time
	return true

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
