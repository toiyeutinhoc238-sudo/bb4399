extends RefCounted














const Atlas = preload("present_tank_atlas.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const View = preload("present_tank_view.gd")
const Glow = preload("present_tank_glow.gd")

const ID: String = "present:tank"
const QST_COMPLETE: int = 3
const QST_OVER: int = 4
const Q_COUNT: int = 4
const Q_ITEMS: int = 10

var view: Control = null
var _tex: Texture2D = null
var _sent: Dictionary = {}
var _rect: Rect2 = Rect2()
var _quest: int = 0
var _glow = Glow.new()

func setup(lobby: Control) -> void :
	view = View.new()
	view.client = lobby.client
	view.pack = lobby.pack
	view.visible = false
	view.set_anchors_preset(Control.PRESET_FULL_RECT)
	lobby.add_child(view)
	lobby.visibility_changed.connect( func() -> void :
		if not lobby.is_visible_in_tree():
			view.close())

func busy() -> bool:
	return view != null and view.visible


static func owns(client: Object, tank: int) -> bool:
	if tank <= 0:
		return false
	for inst: Variant in client.tanks.values():
		if inst is Dictionary and int(inst.get("m_tpltId", 0)) == tank and int(inst.get("m_contType", -1)) == GarageModel.OWN:
			return true
	return false



func pick(client: Object) -> int:
	var ids: Array = Atlas.PRESENT.keys()
	ids.sort_custom( func(a: Variant, b: Variant) -> bool: return int(a) < int(b))
	for key: Variant in ids:
		var quest: int = int(key)
		var row: Variant = client.quests.get(quest)
		if not (row is Array) or (row as Array).is_empty() or int(row[0]) == QST_OVER:
			continue
		var tank: int = int(Atlas.PRESENT[key])
		if owns(client, tank):
			if int(row[0]) == QST_COMPLETE and not _sent.has(quest) and client.quest_complete(quest, 0):
				_sent[quest] = true
			continue
		return quest
	return 0


static func reward(pack: Object, quest: int) -> Array:
	var row: Variant = pack.quest.get("quests", {}).get(str(quest))
	if not (row is Array) or (row as Array).size() <= Q_ITEMS:
		return [0, 0]
	var item: int = 0
	for pair: Variant in row[Q_ITEMS]:
		if pair is Array and (pair as Array).size() >= 2 and int(pair[0]) != 0:
			item = int(pair[0])
			break
	return [item, int(row[Q_COUNT])]


static func item_info(pack: Object, item: int) -> Dictionary:
	var info: Variant = pack.quest.get("items", {}).get(str(item))
	var row: Array = info if info is Array else []
	var found: Variant = pack.bag.get("items", {}).get(str(item))
	var more: Array = found if found is Array else []
	var title: String = "Vật phẩm %d" % item
	if not more.is_empty() and not str(more[0]).is_empty():
		title = BagModel.clean(str(more[0]))
	elif not row.is_empty() and not str(row[0]).is_empty():
		title = str(row[0])
	var icon: String = str(row[1]) if row.size() > 1 and not str(row[1]).is_empty() else (str(more[2]) if more.size() > 2 else "")
	var folder: String = "l/av/" if more.size() > 5 and int(more[5]) == 4 else "l/it/"
	return {"name": title, "art": folder + icon + ".webp" if not icon.is_empty() else "", 
		"desc": GarageModel.plain(str(more[1])) if more.size() > 1 else ""}


static func corner(lobby: Control) -> Vector2:
	return Vector2(floorf(lobby._fw + 0.01), floorf(lobby._fh + 0.01)) + Vector2(float(Atlas.AT[0]), float(Atlas.AT[1]))

func draw(lobby: Control) -> void :
	_rect = Rect2()
	_quest = pick(lobby.client)
	if _quest == 0:
		_glow.reset()
		return
	var pack: Object = lobby.pack
	if _tex == null and ResourceLoader.exists(Atlas.FILE):
		_tex = load(Atlas.FILE)
	var f: float = lobby._f
	var at: Vector2 = corner(lobby)
	var n: Dictionary = Atlas.NODES
	var bg: Array = Atlas.R["pt_bg"]
	if _tex != null:
		lobby.draw_texture_rect_region(_tex, Rect2((at + _v(n.bg)) * f, Vector2(float(bg[2]), float(bg[3])) * f), 
			Rect2(bg[0], bg[1], bg[2], bg[3]))

	var row: Variant = lobby.client.quests.get(_quest)
	if row is Array and int(row[0]) == QST_COMPLETE:
		_glow.draw(lobby, at + _v(n.can))
	else:
		_glow.reset()
	var tank: int = int(Atlas.PRESENT.get(str(_quest), 0))
	var gift: Array = reward(pack, _quest)
	var box: Array = n.tank
	_rect = Rect2((at + Vector2(float(box[0]), float(box[1]))) * f, Vector2(float(box[2]), float(box[3])) * f)
	var desc: Array = Atlas.DESC
	if int(gift[1]) > 0:
		var text: String = str(Atlas.TEXT.desc).replace("@num1@", str(int(gift[1])))
		lobby._words(text, lobby.BOLD, float(desc[3]), Color(str(desc[4])), "c", at + Vector2(float(desc[0]), float(desc[1])), float(desc[2]), 1.0)
	if tank == 0 and int(gift[0]) != 0:
		var art: String = str(item_info(pack, int(gift[0])).art)
		var picture: Texture2D = pack.picture(art) if not art.is_empty() else null
		if picture != null and picture.get_width() > 4:

			var k: float = minf(_rect.size.x / picture.get_width(), _rect.size.y / picture.get_height())
			var extent: Vector2 = Vector2(picture.get_size()) * k
			var lit: float = lobby._lit(ID)
			lobby.draw_texture_rect(picture, Rect2(_rect.position + (_rect.size - extent) / 2.0, extent), false, Color(lit, lit, lit, 1.0))
	lobby._hit(ID, _rect)


func tip(lobby: Control) -> void :
	if _quest == 0 or not lobby._tip_ok() or lobby._hover != ID or not lobby._press.is_empty():
		return
	var gift: Array = reward(lobby.pack, _quest)
	if int(Atlas.PRESENT.get(str(_quest), 0)) != 0 or int(gift[0]) == 0:
		return
	lobby.pack.load_bag()
	var info: Dictionary = item_info(lobby.pack, int(gift[0]))
	lobby._hall_tip(_rect, str(info.name), str(info.desc))


func activate(lobby: Control) -> void :
	var quest: int = pick(lobby.client)
	if quest == 0:
		return
	var row: Variant = lobby.client.quests.get(quest)
	if row is Array and int(row[0]) == QST_COMPLETE:
		lobby.client.quest_complete(quest, 0)
		return
	if int(Atlas.PRESENT.get(str(quest), 0)) != 0:
		return
	view.client = lobby.client
	view.pack = lobby.pack
	view.open(Atlas.PREVIEW)

static func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))
