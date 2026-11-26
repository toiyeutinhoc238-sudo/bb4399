extends "flash_screen.gd"








const Atlas = preload("tank_fast_convert_atlas.gd")
const AskAtlas = preload("tank_convert_ask_atlas.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")

signal convert_asked(tank: int)

const TEXT485: String = "Đã đủ vật liệu @text1@, có trực tiếp đổi tank @text2@?"
const HINT: String = "Có thể đổi tank tương ứng trong giao diện tank"
const NAME_GOLD: Color = Color("ffcb3e")
const HINT_GREEN: Color = Color("9eff80")
const GLOW: Color = Color("1a4698")
const HIDE_IN: Array = ["login", "auth", "servers", "connecting", "characters", "battle"]

var describe: Callable
var _tank: int = 0
var _tipped: Array = []
var _gift: Dictionary = {}

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Atlas.FILE, Atlas.R)
	if client != null:
		client.changed.connect(_follow)


func offer(slots: Array) -> void :
	if client == null or client.state in HIDE_IN or client.battle.active:
		return
	var tank: int = match_tank(slots)
	if tank == 0 or tank in _tipped:
		return
	_tipped.append(tank)
	open(tank)


func open(tank: int) -> void :
	_tank = tank
	var row: Array = AskAtlas.CONVERT_OF.get(str(tank), [])
	_gift = {}
	if row.size() >= 4:
		_gift = describe.call(int(row[3]), 1) if describe.is_valid() else {"name": "Vật phẩm %d" % int(row[3]), "art": "", "quality": 1}
	_hover = ""
	_press = ""
	visible = true
	queue_redraw()

func close() -> void :
	visible = false


func match_tank(slots: Array) -> int:
	if slots.is_empty():
		return 0
	var counts: Dictionary = {}
	for cont: Variant in client.bags.keys():
		for inst: Variant in client.bags[cont]:
			if inst is Dictionary:
				var id: int = int(inst.get("m_templateId", 0))
				counts[id] = int(counts.get(id, 0)) + maxi(1, int(inst.get("m_count", 1)))
	for slot: Variant in slots:
		var item: Dictionary = client.bag_item(3, int(slot))
		if item.is_empty():
			return 0
		var material: int = int(item.get("m_templateId", 0))
		for key: String in AskAtlas.CONVERT_OF:
			var row: Array = AskAtlas.CONVERT_OF[key]
			if int(row[1]) == material and int(counts.get(material, 0)) >= int(row[2]) and not _owns(int(key)):
				return int(key)
	return 0


func _owns(tank: int) -> bool:
	for inst: Variant in client.tanks.values():
		if inst is Dictionary and int(inst.get("m_tpltId", 0)) == tank and int(inst.get("m_contType", -1)) == GarageModel.OWN:
			return true
	return false


func _follow() -> void :
	if visible and (client.state in HIDE_IN or client.battle.active):
		visible = false

func _origin() -> Vector2:
	return Vector2(floorf(_fw) - float(Atlas.SIZE[0]), floorf(_fh) - float(Atlas.SIZE[1]) - 46.0)


func _has_point(point: Vector2) -> bool:
	return visible and Rect2(_origin() * _f, Vector2(float(Atlas.SIZE[0]), float(Atlas.SIZE[1])) * _f).has_point(point)

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	var at: Vector2 = _origin()
	var frame: Vector2 = at + _xy(Atlas.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("tfc_frame") * _f), false)
	_fblit("tfc_frame", frame)
	var box: Array = Atlas.NODES["imgReward"]
	var art: String = str(_gift.get("art", ""))
	var picture: Texture2D = pack.picture(art) if pack != null and not art.is_empty() else null
	if picture != null and picture.get_width() > 4:
		var full: Vector2 = picture.get_size()
		var k: float = minf(float(box[2]) / full.x, float(box[3]) / full.y)
		var shown: Vector2 = full * minf(k, 1.0)
		var corner: Vector2 = at + _xy(box) + (Vector2(float(box[2]), float(box[3])) - shown) / 2.0
		draw_texture_rect(picture, Rect2(corner * _f, shown * _f), false)
	var label: Array = Atlas.NODES["lblItemName"]
	if not _gift.is_empty():
		_fwords(GarageModel.cap(str(_gift.get("name", ""))), ARIAL_BOLD, 12.0, BagModel.tint(int(_gift.get("quality", 1)), Color.WHITE), "c", 
			at + _xy(label), float(label[2]))
	var name_box: Array = Atlas.NODES["lblTankName"]
	_flow(_runs(), 14.0, at + _xy(name_box) + Vector2(2, 0), float(name_box[2]) - 4.0)
	var hint: Array = Atlas.NODES["_TankFastConvertFrame_Text2"]
	_fwords(HINT, ARIAL_BOLD, 12.0, HINT_GREEN, "c", at + _xy(hint), float(hint[2]), 1.0, 0.0, true, GLOW)
	_fbutton("convert", "tfc_convert", at + _xy(Atlas.NODES["btnConvert"]))
	_fbutton("close", "tfc_close", at + _xy(Atlas.NODES["btnClose"]))


func _runs() -> Array:
	var name: String = str(pack.lobby.get("tanks", {}).get(str(_tank), str(_tank))) if pack != null else str(_tank)
	var out: Array = []
	var rest: String = TEXT485
	while not rest.is_empty():
		var one: int = rest.find("@text1@")
		var two: int = rest.find("@text2@")
		var cut: int = one if two < 0 or (one >= 0 and one < two) else two
		if cut < 0:
			out.append([rest, Color.WHITE])
			break
		if cut > 0:
			out.append([rest.substr(0, cut), Color.WHITE])
		out.append([name, NAME_GOLD])
		rest = rest.substr(cut + 7)
	return out


func _flow(parts: Array, px: float, at: Vector2, wide: float) -> void :
	var face: Font = _face(ARIAL_BOLD)
	var font_size: int = maxi(6, roundi(px * _f))
	var space: float = face.get_string_size(" ", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f
	var step: float = roundf(px * 1.3)
	var x: float = 0.0
	var line: int = 0
	for part: Array in parts:
		var words: PackedStringArray = str(part[0]).split(" ")
		for i: int in words.size():
			var word: String = words[i]
			if i > 0:
				x += space
			if word.is_empty():
				continue
			var width: float = face.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f
			if x > 0.0 and x + width > wide:
				line += 1
				x = 0.0
			_fwords(word, ARIAL_BOLD, px, part[1], "l", at + Vector2(x, line * step), width + 2.0, 1.0, 0.0, false, GLOW)
			x += width



func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "convert":
		var tank: int = _tank
		close()
		convert_asked.emit(tank)
