extends RefCounted











const Boss = preload("../ui/world_boss_atlas.gd")
const Text = preload("../i18n.gd")

const SELF_PATH: String = "res://battle/world_boss_hud.gd"
const META: StringName = &"world_boss_hud"
const MAPT_BOSS: int = 9
const DELAY: float = 1.0
const SHOW_VALUE: int = 10000000
const FRAMES: int = 100
const WIDE: float = 458.0
const HIGH: float = 50.0
const BOTTOM: float = 120.0
const FLY_TIME: float = 1.0
const PURPLE: Color = Color("d65cff")
const PURPLE_RIM: Color = Color("3a0057")
const MY_COLOR: Color = Color("00fcff")
const NAME_TEXT: String = "@name@: @num1@"
const MY_TEXT: String = "Hạng: @num1@ Tổng sát thương: @num2@"
const OUT_RANK: String = "Ngoài TOP 500"

var client: Node = null
var battle_key: String = ""
var started: float = 0.0
var opened: bool = false
var live: bool = false
var _sheet: Variant = null
var _fly_n: int = 0
var _fly_at: float = -10.0
var _fly_value: int = 0
var _fly_from: Vector2 = Vector2.ZERO
var _fly_move: Vector2 = Vector2.ZERO

static func is_boss_map(map_id: int) -> bool:
	return int(Text.map_info(map_id).get("type", 0)) == MAPT_BOSS


static func of(hud: Object) -> RefCounted:
	if not hud.has_meta(META):
		hud.set_meta(META, load(SELF_PATH).new())
	return hud.get_meta(META)


static func draw_on(hud: Object, battle: Object, game: Node) -> void :
	if hud == null or battle == null or game == null or not is_boss_map(int(battle.map_id)):
		return
	var me: RefCounted = of(hud)
	me.step(battle, game)
	if me.opened:
		me.paint(hud, battle)


static func hp_text(hp: int, top: int) -> String:
	if hp < SHOW_VALUE:
		return str(hp)
	return "%.2f%%" % (100.0 * hp / top) if top > 0 else "0.00%"


static func fill_width(hp: int, top: int) -> int:
	if top <= 0:
		return 0
	var frame: int = clampi(int(float(FRAMES) * hp / top), 1, FRAMES)
	return roundi(445.0 * (frame - 1) / (FRAMES - 1))


static func top_text(row: Array) -> String:
	return NAME_TEXT.replace("@name@", str(row[1])).replace("@num1@", str(int(row[2])))


static func my_text(rank: int, harm: int) -> String:
	return MY_TEXT.replace("@num1@", OUT_RANK if rank == 0 else str(rank)).replace("@num2@", str(harm))


static func origin(view_size: Vector2, k: float) -> Vector2:
	return Vector2(floorf(view_size.x / 2.0 - WIDE / 2.0 * k), view_size.y - (BOTTOM + HIGH) * k)


func step(battle: Object, game: Node) -> void :
	var key: String = "%d:%d" % [battle.get_instance_id(), int(battle.get("begun") if battle.get("begun") != null else 0)]
	if key != battle_key:
		if live and is_instance_valid(client):
			_release()
		battle_key = key
		client = game
		started = float(battle.clock)
		opened = false
		live = true
		_fly_at = -10.0
		_fly_n = int(game.world_boss.get("drop_n", 0))
		if not game.changed.is_connected(_on_changed):
			game.changed.connect(_on_changed)
	if not opened and float(battle.clock) - started >= DELAY:
		opened = true

		_fly_n = int(game.world_boss.get("drop_n", 0))
		game.world_boss_open()
	var count: int = int(game.world_boss.get("drop_n", 0))
	if count != _fly_n:
		_fly_n = count
		if opened:
			_fly(float(battle.clock))


func top_rows() -> Array:
	var rows: Array = client.world_boss.get("rows", []) if is_instance_valid(client) else []
	return rows.slice(0, 3)

func _fly(now: float) -> void :
	var boss: Dictionary = client.world_boss
	var top: int = int(boss.get("max", 0))
	_fly_value = absi(int(boss.get("drop", 0)))
	_fly_from = Vector2(WIDE * int(boss.get("hp", 0)) / top if top > 0 else 0.0, 0)
	_fly_move = Vector2(200.0 * randf(), -50.0 - 100.0 * randf())
	_fly_at = now

func fly_age(now: float) -> float:
	return now - _fly_at


func _on_changed() -> void :
	if not is_instance_valid(client) or client.state == "battle":
		return
	if live:
		_release()
	opened = false
	battle_key = ""
	if client.changed.is_connected(_on_changed):
		client.changed.disconnect(_on_changed)

func _release() -> void :
	live = false
	client.world_boss_close()

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
	hud._at(origin(view.size, float(hud.scale)))
	var boss: Dictionary = client.world_boss
	var hp: int = int(boss.get("hp", 0))
	var top: int = int(boss.get("max", 0))
	if top > 0:
		_cell(view, sheet, "wb_hp_bk", Vector2.ZERO)
		var wide: int = fill_width(hp, top)
		if wide > 0:
			_cell(view, sheet, "wb_hp_fill", Vector2(float(Boss.HP.fill[0]), float(Boss.HP.fill[1])), float(wide))
	hud._text(Vector2(0, 2), hp_text(hp, top), Color.WHITE, 20, HORIZONTAL_ALIGNMENT_CENTER, WIDE)
	var rows: Array = top_rows()
	for i in range(rows.size()):
		var spot: Array = Boss.HP.ranks.get(str(i), [0, 34])
		_cell(view, sheet, "wb_top%d" % (i + 1), Vector2(float(spot[0]), float(spot[1])))
		var label: Array = Boss.HP.texts.get("lblName%d" % i, [0, 34])
		hud._text(Vector2(float(label[0]), float(label[1])), top_text(rows[i]), Color.WHITE, 12)
	var harm: int = int(boss.get("harm", 0))
	if harm > 0:
		var mine: Array = Boss.HP.texts.get("lblMyHarm", [0, 49])
		hud._text(Vector2(float(mine[0]), float(mine[1])), my_text(int(boss.get("rank", 0)), harm), MY_COLOR, 12)
	var age: float = fly_age(float(battle.clock))
	if age >= 0.0 and age < FLY_TIME and _fly_value > 0:
		var step_k: float = age / FLY_TIME
		var spot: Vector2 = _fly_from + _fly_move * step_k
		var fade: float = 1.0 - 0.5 * step_k
		var px: int = roundi(22.0 * (1.0 + 0.2 * step_k))
		var base: Vector2 = spot + Vector2(0, px + 1)
		view.draw_string_outline(hud.bold, base, "-%d" % _fly_value, HORIZONTAL_ALIGNMENT_LEFT, -1, px, 3, Color(PURPLE_RIM, fade))
		view.draw_string(hud.bold, base, "-%d" % _fly_value, HORIZONTAL_ALIGNMENT_LEFT, -1, px, Color(PURPLE, fade))
	view.draw_set_transform(Vector2.ZERO)
