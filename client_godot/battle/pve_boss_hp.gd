extends RefCounted














const Boss = preload("../ui/world_boss_atlas.gd")
const Table = preload("pve_boss_table.gd")

const SELF_PATH: String = "res://battle/pve_boss_hp.gd"
const META: StringName = &"pve_boss_hp"
const PVE_ROOMS: Array = [3, 4, 8, 50, 51, 52, 53, 7, 14]
const GB_ROOM: int = 14
const GB_TEMPLATE: int = 10001
const AINPC_KIND: int = 5
const FRAMES: int = 100
const WIDE: float = 458.0
const STEP: float = 43.0
const BOTTOM: float = 120.0
const NAME_X: float = -200.0
const NAME_WIDE: float = 200.0
const NAME_SIZE: int = 22
const HP_SIZE: int = 16
const NAME_INK: Color = Color("ffde00")
const NAME_RIM: Color = Color("4d1700")

var battle_key: String = ""


var bars: Array = []
var hidden: bool = false
var _talk_on: bool = false
var _dialog_on: bool = false
var _sheet: Variant = null

static func is_pve(battle: Object) -> bool:
	var room: Variant = battle.get("room_type")
	return room != null and int(room) in PVE_ROOMS


static func boss_row(template: int) -> Array:
	var row: Variant = Table.BOSS.get(str(template))
	return row if row is Array else []


static func of(hud: Object) -> RefCounted:
	if not hud.has_meta(META):
		hud.set_meta(META, load(SELF_PATH).new())
	return hud.get_meta(META)


static func draw_on(hud: Object, battle: Object, game: Node) -> void :
	if hud == null or battle == null or not is_pve(battle):
		return
	var me: RefCounted = of(hud)
	me.step(battle)
	if not me.hidden and not me.bars.is_empty():
		me.paint(hud, battle)


static func frame_of(hp: int, top: int) -> int:
	if top <= 0:
		return 1
	return clampi(int(float(FRAMES) * hp / top), 1, FRAMES)


static func fill_width(hp: int, top: int) -> int:
	if top <= 0:
		return 0
	return roundi(445.0 * (frame_of(hp, top) - 1) / (FRAMES - 1))

static func hp_text(hp: int, top: int) -> String:
	return "%d/%d" % [hp, top]


static func origin(view_size: Vector2, k: float, index: int) -> Vector2:
	return Vector2(floorf(view_size.x / 2.0 - WIDE / 2.0 * k), view_size.y - (BOTTOM + STEP * index) * k)


static func name_room(view_width: float, k: float) -> int:
	return int(maxf(NAME_WIDE - 4.0, (view_width / maxf(k, 0.01) - WIDE) / 2.0 - 8.0))


static func hp_of(battle: Object, bar: Dictionary) -> int:
	var total: int = 0
	var npcs: Dictionary = battle.npcs
	for uid: int in bar.uids:
		if npcs.has(uid):
			total += maxi(0, int(npcs[uid].get("hp", 0)))
	return total

func _bar_of(group: int) -> Dictionary:
	for bar: Dictionary in bars:
		if int(bar.group) == group:
			return bar
	return {}


func step(battle: Object) -> void :
	var key: String = "%d:%d" % [battle.get_instance_id(), int(battle.get("begun") if battle.get("begun") != null else 0)]
	if key != battle_key:
		battle_key = key
		bars.clear()
		hidden = false
		_talk_on = false
		_dialog_on = false
	var talk_on: bool = battle.has_method("talk_now") and not battle.talk_now().is_empty()
	if talk_on != _talk_on:
		_talk_on = talk_on
		hidden = talk_on
	var dialog_on: bool = battle.has_method("battle_dialog_now") and not battle.battle_dialog_now().is_empty()
	if dialog_on != _dialog_on:
		_dialog_on = dialog_on
		hidden = dialog_on
	var npcs: Dictionary = battle.npcs
	for bar: Dictionary in bars.duplicate():
		for uid: int in (bar.uids as Array).duplicate():
			if not npcs.has(uid):
				bar.uids.erase(uid)
		if (bar.uids as Array).is_empty():
			bars.erase(bar)
	for id: int in npcs:
		if id >> 26 != AINPC_KIND:
			continue
		var row: Array = boss_row(int(npcs[id].get("template", 0)))
		if row.is_empty() and int(npcs[id].get("template", 0)) == GB_TEMPLATE and int(battle.get("room_type")) == GB_ROOM:
			var gb_map: Variant = battle.get("map_id")
			row = [GB_TEMPLATE, str(preload("../i18n.gd").map_info(int(gb_map) if gb_map != null else 0).get("boss", "BOSS"))]
		if row.is_empty():
			continue
		var bar: Dictionary = _bar_of(int(row[0]))
		if bar.is_empty():
			bars.append({"group": int(row[0]), "name": str(row[1]), "uids": [id], "top": maxi(0, int(npcs[id].get("max_hp", 0))), 
				"fit": null, "fit_w": -1})
		elif not (bar.uids as Array).has(id):
			bar.uids.append(id)
			bar.top = int(bar.top) + maxi(0, int(npcs[id].get("max_hp", 0)))

func _texture() -> Texture2D:
	if _sheet == null:
		_sheet = load(Boss.FILE) if ResourceLoader.exists(Boss.FILE) else false
	return _sheet if _sheet is Texture2D else null

func _cell(view: Control, sheet: Texture2D, name: String, at: Vector2, wide: float = -1.0) -> void :
	var region: Array = Boss.R.get(name, [])
	if sheet == null or region.is_empty():
		return
	var w: float = float(region[2]) if wide < 0.0 else wide
	view.draw_texture_rect_region(sheet, Rect2(at, Vector2(w, float(region[3]))), 
		Rect2(float(region[0]), float(region[1]), w, float(region[3])))


func paint(hud: Object, battle: Object) -> void :
	var view: Control = hud.view
	var sheet: Texture2D = _texture()
	var k: float = float(hud.scale)
	for i in range(bars.size()):
		var bar: Dictionary = bars[i]
		hud._at(origin(view.size, k, i))
		var hp: int = hp_of(battle, bar)
		var top: int = int(bar.top)
		_cell(view, sheet, "wb_hp_bk", Vector2.ZERO)
		var wide: int = fill_width(hp, top)
		if wide > 0:
			_cell(view, sheet, "wb_hp_fill", Vector2(float(Boss.HP.fill[0]), float(Boss.HP.fill[1])), float(wide))
		hud._text(Vector2(0, 5), hp_text(hp, top), Color.WHITE, HP_SIZE, HORIZONTAL_ALIGNMENT_CENTER, WIDE, true, 0)
		var room: int = name_room(view.size.x, k)
		if bar.fit == null or int(bar.fit_w) != room:
			bar.fit = hud._fit(str(bar.name), float(room), NAME_SIZE) if hud.has_method("_fit") else str(bar.name)
			bar.fit_w = room
		var label: String = str(bar.fit)
		if not label.is_empty() and hud.bold != null:

			var base: Vector2 = Vector2(NAME_X + NAME_WIDE - 2.0 - float(room), NAME_SIZE + 1)
			view.draw_string_outline(hud.bold, base, label, HORIZONTAL_ALIGNMENT_RIGHT, float(room), NAME_SIZE, 4, NAME_RIM)
			view.draw_string(hud.bold, base, label, HORIZONTAL_ALIGNMENT_RIGHT, float(room), NAME_SIZE, NAME_INK)
	view.draw_set_transform(Vector2.ZERO)
