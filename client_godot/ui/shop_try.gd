extends RefCounted








const Atlas = preload("shop_try_atlas.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const TankPreview = preload("tank_preview.gd")
const TankPortrait = preload("tank_portrait.gd")


const OK: String = "tank_ok"
const BUY: String = "tank_buy"



static func target(garage: Dictionary, defaults: Dictionary, tid: int) -> Array:
	var row: Array = Atlas.TANKVIEW.get(str(tid), [])
	if row.size() < 2 or not garage.get("tanks", {}).has(str(int(row[0]))):
		return []
	var tank: int = int(row[0])
	var ext: int = int(row[1]) if int(row[1]) > 0 else GarageModel.exterior(garage, defaults, tank, 1, {})
	return [tank, ext]



static func skill_ids(garage: Dictionary, tank: int) -> Array:
	var list: Array = garage.get("tanks", {}).get(str(tank), {}).get("skills", [])
	if list.size() < 4:
		return []
	return [int(list[3]) if int(list[3]) > 0 else int(list[2]), int(list[0]), int(list[1])]


static func use(screen: Control) -> void :
	screen._use(Atlas.FILE, Atlas.R)





static func draw(screen: Control, rec: Dictionary, view: Array, buy: bool = true, under: Callable = Callable()) -> Array:
	var garage: Dictionary = screen.pack.garage
	var at: Vector2 = screen._window(float(Atlas.FRAME[0]), float(Atlas.FRAME[1]))
	if under.is_valid():
		under.call(at)
	if view.size() < 2:
		return []
	var tank: int = int(view[0])
	var ext: int = int(view[1])
	var n: Dictionary = Atlas.NODES
	var info: Dictionary = garage.get("tanks", {}).get(str(tank), {})

	screen._fblit("stry_type_phys" if int(info.get("type", 1)) == 1 else "stry_type_energy", at + _v(n.type))
	var name: String = BagModel.clean(str(screen.pack.lobby.get("tanks", {}).get(str(tank), "")))
	if name.is_empty():
		name = GarageModel.cap(str(rec.get("name", "")))
	var label: Array = Atlas.NAME
	screen._fwords(name, screen.ARIAL_BOLD, float(label[3]), Color.WHITE, "c", at + Vector2(float(label[0]), float(label[1])), float(label[2]), 1.0, 24.0, true)
	screen._fblit("stry_booth", at + _v(n.booth))
	_pod(screen, tank, ext, at + _v(n.avatar) + Vector2(100, 100))
	var tip: Array = []
	var ids: Array = skill_ids(garage, tank)
	for i in range(ids.size()):
		var spot: Vector2 = at + _v(n.skills) + Vector2(56.0 * i, 0)
		var rect: Rect2 = Rect2(spot * screen._f, Vector2(50, 50) * screen._f)
		var id: int = int(ids[i])
		if id <= 0:
			continue
		var hud: Array = screen.pack.skill_hud(id)
		screen._fit(screen.pack.icon("s", str(hud[0])) if not hud.is_empty() else null, spot, Vector2(50, 50), 4.0)
		if screen._press.is_empty() and rect.has_point(screen.get_local_mouse_position()):
			tip = [rect, "", "", Color.WHITE, {"skill": id}]

	var lit: Color = screen._glow(OK)
	var confirm: Vector2 = at + _v(n.confirm)
	screen._hit(OK, screen._fblit("public_button_window_green", confirm, 0.0, 0.0, lit), false)
	screen._fblit("title_title_confirm_green_t", confirm + ((Vector2(120, 35) - screen._cell_size("title_title_confirm_green_t")) / 2.0).round(), 0.0, 0.0, lit)
	if buy:
		screen._fbutton(BUY, "shop_buy", at + _v(n.buy))
	return tip



static func _pod(screen: Control, tank: int, ext: int, c: Vector2) -> void :
	var pack: Node = screen.pack
	var f: float = screen._f
	var key: String = GarageModel.face(pack.garage, ext)
	var folder: String = "l/t"
	if not key.is_empty() and pack.garage.get("big", []).has(key) and pack.picture("l/tb/%s.webp" % key) != null:
		folder = "l/tb"
	if TankPortrait.draw(screen, pack, key, 0, c * f, f, screen._time, folder) or pack.state != "ready":
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(ext), tank))
	if TankPreview.ready(art):
		var pod: Vector2 = c + Vector2(0, 46)
		TankPreview.draw(screen, art, (pod - Vector2(0, 52)) * f, minf(1.7, 160.0 / TankPreview.extent(art)) * f, 4, screen._time)

static func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))
