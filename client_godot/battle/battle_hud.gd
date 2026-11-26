extends RefCounted
const Mp = preload("res://battle/mp_use.gd")







const Text = preload("../i18n.gd")
const PveMapRows = preload("../ui/pve_room_atlas.gd")
const Settings = preload("res://settings.gd")
const SysIcons = preload("sys_icons.gd")
const VoiceClient = preload("../ui/voice_client.gd")
const VoiceUI = preload("../ui/voice_ui.gd")
const FpsMeter = preload("fps_meter.gd")
const BattleSettings = preload("battle_settings.gd")
const TankPortrait = preload("../ui/tank_portrait.gd")
const TankPreview = preload("../ui/tank_preview.gd")
const GarageModel = preload("../ui/garage_model.gd")
const TankState = preload("../ui/tankstate_atlas.gd")
const TimeOver = preload("../ui/timeover_atlas.gd")
const SkillCell = preload("../ui/skillcell_atlas.gd")
const SkillCast = preload("skill_cast.gd")
const DeathRound = preload("../ui/deathround_atlas.gd")
const Happy = preload("happy_hud.gd")
const WorldBoss = preload("world_boss_hud.gd")
const PveBossHp = preload("pve_boss_hp.gd")
const MinimapMarks = preload("minimap_marks.gd")
const MicroHeads = preload("micro_heads.gd")
const EmoteTalk = preload("battle_emote_talk.gd")
const NameStyles = preload("../ui/name_styles.gd")
const TouchLq = preload("touch_lq.gd")
const SafeArea = preload("../ui/safe_area.gd")
const TouchLife = preload("touch_life.gd")
const TouchGfx = preload("touch_gfx.gd")
const HudTiles = preload("hud_tiles.gd")
const TouchHeads = preload("touch_heads.gd")
const DIR: String = "res://assets/hud/"
const SIGNALS: Array[String] = ["atk", "bak", "mst"]
const SIGNAL_KEYS: Array[String] = ["z", "x", "c"]
const SIGNAL_TEX: Array[String] = ["signal_atk", "signal_bak", "signal_mst"]
const SIG_RECTS: Array[String] = ["sig1", "sig2", "sig3"]
const NUM_SHEETS: Dictionary = {"harm": "num_harm", "crit": "num_crit", "cure": "num_cure", "exp": "num_exp"}
const SIGNAL_CD: float = 3.0
const CELL_X: Array[int] = [150, 211, 272, 333]
const KEY_X: Array[int] = [185, 246, 289, 365]
const KEY_NAMES: Array[String] = ["r", "e", "space", "q"]
const NUM_COLS: int = 12


const WATCH_AT: Vector2 = Vector2(63, 122)
const WATCH_TITLE: String = "Xem mục tiêu"
const WATCH_CLICK: String = "Click đổi"





const LOOK_FREE_TEXT: String = "Tự do"
const LOOK_LOCK_TEXT: String = "Cố định"
const LOOK_KEY_TIP: String = "Ấn space bar để đổi hình thức"
const LOOK_EXIT_TIP: String = "Bạn đang ở chế độ xem, click vào đây để thoát"
const NO_EXIT_ROOMS: Array[int] = [1, 2, 9]
const LOOK_GLOW: Color = Color(22 / 255.0, 0, 0, 0.8)
const LOOK_EXIT_GLOW: Color = Color(1, 1, 153 / 255.0, 0.8)
const LOOK_EXIT_SHOW: float = 10.0
const LOOK_HELP_UP: String = "gda/guide_help_up"
const LOOK_FPS: float = 24.0


const LOOK_GOLD: Color = Color("f5d77a")
var look_heads: Dictionary = {}
var look_mode_shown: String = ""
var look_exit_shown: bool = false
var _look_head_down: int = 0

var view: Control
var pack: Node
var font: Font
var bold: Font
var scale: float = 1.0
var rects: Dictionary = {}
var chat_panel: Rect2 = Rect2()
var delay_shown: Dictionary = {}
var fps_rect: Rect2 = Rect2()
var armed: int = 0
var signal_ready: float = 0.0
var touch: bool = false


var safe_in: Vector4 = Vector4.ZERO
var safe_tl: Vector2 = Vector2.ZERO
var safe_tr: Vector2 = Vector2.ZERO
var _tex: Dictionary = {}
var _reported: Dictionary = {}
var _drawn_size: Vector2 = Vector2.ZERO
var _map_scale: float = 1.0
var _map_origin: Vector2 = Vector2.ZERO

var avatar_rects: Dictionary = {}
var hover_tank: int = 0

var avatar_pick: int = 0
var _state_tex: Variant = null
var _talk_cache: Dictionary = {}
var _talk_src: Variant = null
var _cells: Dictionary = {}
var _cells_battle: String = ""

var _cells_id: int = 0
var _cells_begun: int = 0
var _warm_names: PackedStringArray = []
var _warm_next: int = -1
var _warm_map: Array = [null, null]
var _warm_cell: Array = [null, null]
var _memo_src: Array = [null, null, null, null, null]
var _face_memo: Dictionary = {}
var _ring_memo: Dictionary = {}
var _film_memo: Dictionary = {}
var _fit_memo: Dictionary = {}
var _width_memo: Dictionary = {}
var _wrap_memo: Dictionary = {}
var _words_re: RegEx = null
var _inf_key: Vector3 = Vector3(-1000000000.0, -1000000000.0, -1000000000.0)
var _inf_points: PackedVector2Array = []
var _inf_mesh: Array = []
var _h1: HudTiles = HudTiles.new()
var _life_set: Array = []
var _life_skin: Dictionary = {}
var _grid_memo: Dictionary = {}
static var _brief_src: Variant = null
static var _brief_n: int = -1
static var _brief_at: Dictionary = {}


var _round_add: Control = null
var _round_adds: Array = []

var _map_adds: Array = []

var map_marks: Array[String] = []


var _map_drag: bool = false
var _map_hold: bool = false
var _map_center: Vector2 = Vector2.ZERO
var _hold_follow: Vector2 = Vector2.ZERO
var _hold_fresh: bool = false
var _hold_battle: Array = [-1, -1]
var _map_size: Vector2 = Vector2(120, 90)
var _gap_fonts: Dictionary = {}
var _wait_box: StyleBoxFlat = null

func _init(owner: Control, regular: Font, heavy: Font) -> void :
	view = owner
	font = regular
	bold = heavy

func tex(name: String) -> Texture2D:
	var hit: Variant = _tex.get(name, false)
	if hit is bool:
		hit = load(DIR + name + ".png") if ResourceLoader.exists(DIR + name + ".png") else null
		_tex[name] = hit
	return hit


func _warm_tex() -> void :
	if _warm_next < 0:
		_warm_next = 0
		for file: String in ResourceLoader.list_directory(DIR):
			if file.ends_with(".png"):
				_warm_names.append(file.get_basename())
	while _warm_next < _warm_names.size():
		var name: String = _warm_names[_warm_next]
		_warm_next += 1
		if not _tex.has(name):
			tex(name)
			return


func _pack_memo() -> void :
	if pack == null:
		return
	var halo: Variant = pack.fx.get("halo_ui")
	if is_same(_memo_src[0], pack) and is_same(_memo_src[1], pack.garage) and is_same(_memo_src[2], pack.fx)\
	and is_same(_memo_src[3], pack.index) and is_same(_memo_src[4], halo):
		return
	_memo_src = [pack, pack.garage, pack.fx, pack.index, halo]
	_face_memo.clear()
	_ring_memo.clear()
	_film_memo.clear()


func life_set() -> Array:
	if _life_set.is_empty():
		_life_set = [tex("tank_life_empty"), tex("tank_life_warn"), tex("tank_mp_bg"), tex("tank_mp_bar"), tex("battle_level_bg"), 
			tex("battle_level_number")]
	return _life_set

func life_skin(skin: String) -> Texture2D:
	var hit: Variant = _life_skin.get(skin, false)
	if hit is bool:
		hit = tex("tank_life_" + skin)
		_life_skin[skin] = hit
	return hit


func life_grid(max_hp: int, grid_hp: float) -> PackedVector2Array:
	var hit: Variant = _grid_memo.get(max_hp)
	if hit != null:
		return hit
	var ticks: PackedVector2Array = []
	var step: float = 70.0 * grid_hp / float(max_hp)
	var x: float = step
	while step > 1.0 and x < 70.0:
		ticks.append(Vector2(roundi(x) + 0.5, 2))
		ticks.append(Vector2(roundi(x) + 0.5, 8))
		x += step
	if _grid_memo.size() >= 64:
		_grid_memo.clear()
	_grid_memo[max_hp] = ticks
	return ticks

func _at(origin: Vector2) -> void :
	view.draw_set_transform(origin, 0, Vector2(scale, scale))

func _screen(origin: Vector2, rect: Rect2) -> Rect2:
	return Rect2(origin + rect.position * scale, rect.size * scale)

func _img(name: String, pos: Vector2, alpha: float = 1.0) -> void :
	var texture: Texture2D = tex(name)
	if texture != null:
		view.draw_texture(texture, pos, Color(1, 1, 1, alpha))


func _text(pos: Vector2, text: String, color: Color, size: int, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, 
		width: float = -1, heavy: bool = true, outline: int = 3) -> void :
	var f: Font = bold if heavy else font
	var base: Vector2 = pos + Vector2(0, size + 1)
	if outline > 0:
		view.draw_string_outline(f, base, text, align, width, size, outline, Color(0, 0, 0, color.a * 0.9))
	view.draw_string(f, base, text, align, width, size, color)


func _bar_text(pos: Vector2, text: String) -> void :
	var base: Vector2 = pos + Vector2(0, 13)
	view.draw_string_outline(bold, base + Vector2(1, 1), text, HORIZONTAL_ALIGNMENT_CENTER, 102, 12, 4, Color(0, 0, 0, 0.6))
	view.draw_string_outline(bold, base, text, HORIZONTAL_ALIGNMENT_CENTER, 102, 12, 4, Color.BLACK)
	view.draw_string(bold, base, text, HORIZONTAL_ALIGNMENT_CENTER, 102, 12, Color.WHITE)

func _text_width(text: String, size: int) -> float:
	var bucket: Variant = _width_memo.get(size)
	if bucket == null:
		if _width_memo.size() >= 16:
			_width_memo.clear()
		bucket = {}
		_width_memo[size] = bucket
	var hit: Variant = bucket.get(text)
	if hit == null:
		hit = bold.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		if bucket.size() >= 512:
			bucket.clear()
		bucket[text] = hit
	return hit



func layout_scale() -> float:
	if touch:
		return TouchLq.unit(view.size)
	var virtual: Vector2 = view.get_viewport_rect().size
	var css: Vector2 = Settings.css_size(Vector2(view.get_window().size))
	if virtual.x < 1 or css.x < 1:
		return clampf(minf(view.size.x / 1000.0, view.size.y / 600.0), 0.55, 1.0)
	var css_per_unit: float = css.x / virtual.x
	var flash: float = clampf(minf(css.x / 1000.0, css.y / 600.0), 0.55, 1.0)
	return flash / css_per_unit

func draw(battle, client) -> void :
	scale = layout_scale()
	rects.clear()
	chat_panel = Rect2()
	delay_shown = {}
	_warm_tex()
	_pack_memo()
	_drawn_size = view.size
	_safe_sync()
	_map_name(battle)
	_watching(battle)
	_top(battle)
	_sys_bar(client)
	_kill_area(battle)
	_kills(battle)
	_honor(battle)
	if touch:
		scale = TouchLq.COLUMN_K * TouchLq.unit(view.size)
	_columns(battle)
	scale = layout_scale()
	if voice_menu != 0 and not voice_chips.has(voice_menu):
		voice_menu = 0
	Happy.draw_on(self, battle, client)
	_minimap(battle)
	if touch:
		_target_info(battle)
	WorldBoss.draw_on(self, battle, client)
	PveBossHp.draw_on(self, battle, client)
	_bottom(battle)
	if touch:
		scale = TouchLq.BUFF_K * TouchLq.unit(view.size)
	_buffs(battle)
	scale = layout_scale()
	_look_labels(battle)
	_relive(battle)
	_chat(battle)
	_private_chat(battle)
	_talk(battle)
	_battle_dialog(battle)
	_chat_input()
	_time_tip(battle)
	_death_rounds(battle)
	view.draw_set_transform(Vector2.ZERO)
	_voice_menu_draw()


func _safe_sync() -> void :
	safe_in = SafeArea.inset(view.size) if touch else Vector4.ZERO
	safe_tl = SafeArea.corner_pad(view.size, "tl") if touch else Vector2.ZERO
	safe_tr = SafeArea.corner_pad(view.size, "tr") if touch else Vector2.ZERO





const MAP_NAME_HIDDEN_ROOMS: Array = [3, 4, 8, 53, 52, 51]
const MAP_NAME_SIZE: int = 14
var map_name_shown: String = ""

static func map_name_visible(battle) -> bool:
	return not int(battle.room_type) in MAP_NAME_HIDDEN_ROOMS and not Text.map_info(int(battle.map_id)).is_empty()

func _map_name(battle) -> void :
	map_name_shown = ""
	if touch or not map_name_visible(battle):
		return
	map_name_shown = battle.title()
	_at(Vector2.ZERO)
	_text(Vector2(2, 2), map_name_shown, Color.WHITE, MAP_NAME_SIZE, HORIZONTAL_ALIGNMENT_LEFT, -1, true, 2)




func _watching(battle) -> void :
	if not battle.watch_shown:
		return
	_at(WATCH_AT * scale)
	_img("looktip", Vector2.ZERO)
	_text(Vector2(68, 5), WATCH_TITLE, Color("3399cc"), 14, HORIZONTAL_ALIGNMENT_LEFT, -1, false, 0)
	if not str(battle.watch_name).is_empty():
		_text(Vector2(70, 22), _fit(str(battle.watch_name), 100, 16), Color("33ccff"), 16, HORIZONTAL_ALIGNMENT_CENTER, 100, true, 0)
	_text(Vector2(77, 41), WATCH_CLICK, Color("336699"), 12, HORIZONTAL_ALIGNMENT_LEFT, -1, false, 0)



func _look_text(pos: Vector2, text: String, color: Color, size: int, glow: Color, outline: int, 
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1, heavy: bool = true) -> void :
	var f: Font = bold if heavy else font
	var base: Vector2 = pos + Vector2(0, size + 1)
	if outline > 0:
		view.draw_string_outline(f, base, text, align, width, size, outline, glow)
	view.draw_string(f, base, text, align, width, size, color)


func _look_labels(battle) -> void :
	look_mode_shown = ""
	if not battle.look:
		return
	var word: Texture2D = tex("word_look")
	if word != null:
		_at(Vector2(view.size.x / 2 - word.get_width() / 2.0 * scale, 90 * scale))
		view.draw_texture(word, Vector2.ZERO)
	look_mode_shown = LOOK_FREE_TEXT if battle.look_free else LOOK_LOCK_TEXT
	_at(Vector2.ZERO)
	_look_text(Vector2(60, 192), look_mode_shown, Color.WHITE, 20, LOOK_GLOW, 4)
	_look_text(Vector2(60, 222), LOOK_KEY_TIP, Color.WHITE, 14, LOOK_GLOW, 4)



func _look_exit_tip(battle, origin: Vector2) -> void :
	look_exit_shown = false
	if not battle.look or battle.look_tip_at < 0 or battle.clock - battle.look_tip_at >= LOOK_EXIT_SHOW:
		return
	look_exit_shown = true
	_at(origin)
	var right: float = -16.0 + 120.0 - 2.0
	_look_text(Vector2(right - 640.0, 25.0 + 60.0), LOOK_EXIT_TIP, Color(1, 0, 0), 20, LOOK_EXIT_GLOW, 5, HORIZONTAL_ALIGNMENT_RIGHT, 640.0)
	if pack == null or pack.state != "ready":
		return
	var part: Dictionary = pack.effect(LOOK_HELP_UP)
	if part.is_empty() or part.data.frames.is_empty():
		return
	view.draw_set_transform(origin + Vector2(-16.0 + 80.0, 25.0) * scale, 0, Vector2(scale, scale) * 0.5)
	_fx_frame(part, Vector2.ZERO, int((battle.clock - battle.look_tip_at) * LOOK_FPS) % part.data.frames.size())
	_at(origin)


func look_blocked(battle) -> bool:
	var film: bool = view.result_mv != null and view.result_mv.playing()
	return (battle.ended and not film) or view._settings.visible


func look_press(point: Vector2, battle) -> bool:
	_look_head_down = 0
	if not battle.look and battle.watch_shown and not look_blocked(battle):

		for id: int in look_heads:
			if look_heads[id].has_point(point):
				if not battle.watch_pick(id):
					battle.watch_press()
				return true
		return false
	if not battle.look or look_blocked(battle):
		return false
	for id: int in look_heads:
		if look_heads[id].has_point(point):
			_look_head_down = id
			return true
	return false


func look_release(point: Vector2, battle) -> void :
	var head: int = _look_head_down
	_look_head_down = 0
	if head != 0 and not look_blocked(battle) and look_heads.has(head) and look_heads[head].has_point(point) and battle.tanks.has(head):
		battle.look_follow(head)


static func clock_text(left: int) -> String:
	var value: int = maxi(0, left)
	return "%d:%02d" % [floori(value / 60.0), value % 60]


func _fx_frame(part: Dictionary, at: Vector2, index: int) -> void :
	var frames: Array = part.data.frames
	if index < 0 or index >= frames.size():
		return
	var frame: Dictionary = frames[index]
	var rect: Rect2 = Rect2(float(frame.rect[0]), float(frame.rect[1]), float(frame.rect[2]), float(frame.rect[3]))
	if rect.size.x > 0.0 and rect.size.y > 0.0 and int(frame.page) < part.pages.size() and part.pages[int(frame.page)] != null:
		view.draw_texture_rect_region(part.pages[int(frame.page)], Rect2(at - Vector2(float(frame.pivot[0]), float(frame.pivot[1])), rect.size), rect)



func _time_tip(battle) -> void :
	if pack == null or pack.state != "ready":
		return
	if battle.started and battle.clock_running:
		for key: String in TimeOver.TIPS.values():
			pack.effect(key, true)
		pack.effect(TimeOver.OVER, true)
	if battle.time_tip.is_empty():
		return
	var sec: int = int(battle.time_tip.sec)
	var part: Dictionary = pack.effect(str(TimeOver.TIPS.get(sec, "")))
	if part.is_empty():
		return
	_at(Vector2(view.size.x / 2 - TimeOver.GAME_WIDTH / 2.0 * scale, 0))
	var x: int = int((TimeOver.GAME_WIDTH - int(TimeOver.TIP_WIDTH.get(sec, 0))) / 2.0)
	_fx_frame(part, Vector2(x, TimeOver.TIP_Y), battle.time_tip_frame())




func _death_rounds(battle) -> void :
	_round_adds.clear()
	if pack != null and pack.state == "ready" and battle.mode == "death":
		if battle.started:
			for key: String in DeathRound.RESULT_LAYERS + DeathRound.COUNT_LAYERS + [DeathRound.RESULT_ADD, DeathRound.COUNT_ADD, DeathRound.TEXT]:
				pack.effect(key, true)
		var movies: Array = []
		if not battle.round_result.is_empty():
			movies.append([float(battle.round_result.t), 0])
		if not battle.round_count.is_empty():
			movies.append([float(battle.round_count.t), 1])
		movies.sort()
		for movie: Array in movies:
			if int(movie[1]) == 0:
				_round_result(battle)
			else:
				_round_count(battle)
	_round_add_redraw()



func _round_result(battle) -> void :
	_round_movie(result_at(battle), DeathRound.RESULT_LAYERS, DeathRound.RESULT_ADD, battle.round_result_frame(), [[1, DeathRound.RESULT_AT, result_text(battle)]])


func result_at(battle) -> Vector2:
	var at: Vector2 = (view.size - DeathRound.STAGE * scale) / 2
	if battle.round_result.is_empty():
		return at
	var played: Dictionary = battle.round_result
	var age: float = (float(battle.clock) - float(played.t)) * DeathRound.FPS
	if age >= DeathRound.MOVE_AT:
		var k: float = clampf((age - DeathRound.MOVE_AT) / DeathRound.MOVE_FRAMES, 0.0, 1.0)
		k = 1.0 - (1.0 - k) * (1.0 - k)
		at = at.lerp(trophy_center(battle, int(played.camp)) - DeathRound.STAGE / 2 * scale, k)
	return at


static func result_text(battle) -> String:
	if battle.round_result.is_empty():
		return ""
	return "success" if int(battle.round_result.camp) == int(battle.self_camp()) else "fail"


static func count_text(played: Dictionary) -> String:
	if played.is_empty():
		return ""
	var number: int = int(played.round)
	if bool(played.final):
		return "final"
	return str(DeathRound.ROUND_LIST[number - 1]) if number >= 1 and number <= DeathRound.ROUND_LIST.size() else ""


func _round_count(battle) -> void :
	_round_movie((view.size - DeathRound.STAGE * scale) / 2, DeathRound.COUNT_LAYERS, DeathRound.COUNT_ADD, battle.round_count_frame(), 
		[[1, DeathRound.ROUND_AT, count_text(battle.round_count)], [2, DeathRound.START_AT, "start"]])


func _round_movie(at: Vector2, layers: Array, add_key: String, index: int, holders: Array) -> void :
	if index < 0:
		return
	var parts: Array = []
	for key: String in layers:
		parts.append(pack.effect(key))
	var add: Dictionary = pack.effect(add_key)
	var text: Dictionary = pack.effect(DeathRound.TEXT)
	if add.is_empty() or text.is_empty() or parts.any( func(part: Dictionary) -> bool: return part.is_empty()):
		return
	var base: Transform2D = Transform2D(0.0, Vector2(scale, scale), 0.0, at)
	for i in range(parts.size()):
		for holder: Array in holders:
			if int(holder[0]) == i:
				_round_text(base, text, holder[1], index, str(holder[2]))
		view.draw_set_transform_matrix(base)
		_fx_frame(parts[i], Vector2.ZERO, index)
	_round_adds.append([add, base, index])



func _round_text(base: Transform2D, text: Dictionary, rows: Array, index: int, name: String) -> void :
	if name.is_empty() or not DeathRound.TEXT_INDEX.has(name) or index >= rows.size() or (rows[index] as Array).is_empty():
		return
	var row: Array = rows[index]
	var alpha: float = clampf(float(row[9]) + float(row[13]) / 255.0, 0.0, 1.0)
	if alpha <= 0.0:
		return
	view.draw_set_transform_matrix(base * Transform2D(Vector2(float(row[0]), float(row[1])), Vector2(float(row[2]), float(row[3])), 
		Vector2(float(row[4]), float(row[5]))))
	var cell: int = int(DeathRound.TEXT_INDEX[name])
	var white: float = clampf(float(row[10]) / 255.0, 0.0, 1.0)
	if white > 0.008:
		_fx_cell(view, text, cell, Color(1, 1, 1, alpha * (1.0 - white) / maxf(1e-06, 1.0 - alpha * white)))
		_fx_cell(view, text, cell + DeathRound.WHITE, Color(1, 1, 1, alpha * white))
	else:
		_fx_cell(view, text, cell, Color(float(row[6]), float(row[7]), float(row[8]), alpha))


func _fx_cell(target: CanvasItem, part: Dictionary, index: int, tint: Color) -> void :
	var frames: Array = part.data.frames
	if index < 0 or index >= frames.size():
		return
	var frame: Dictionary = frames[index]
	var rect: Rect2 = Rect2(float(frame.rect[0]), float(frame.rect[1]), float(frame.rect[2]), float(frame.rect[3]))
	if rect.size.x > 1.0 and rect.size.y > 1.0 and int(frame.page) < part.pages.size() and part.pages[int(frame.page)] != null:
		target.draw_texture_rect_region(part.pages[int(frame.page)], Rect2( - Vector2(float(frame.pivot[0]), float(frame.pivot[1])), rect.size), rect, tint)


func _round_add_redraw() -> void :
	if _round_add == null or not is_instance_valid(_round_add):
		if _round_adds.is_empty() and _map_adds.is_empty():
			return
		_round_add = Control.new()
		_round_add.name = "DeathRoundAdd"
		_round_add.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_round_add.set_anchors_preset(Control.PRESET_FULL_RECT)
		var blend: CanvasItemMaterial = CanvasItemMaterial.new()
		blend.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		_round_add.material = blend
		_round_add.draw.connect(_draw_round_adds)
		view.add_child.call_deferred(_round_add)
		view.move_child.call_deferred(_round_add, 0)
	_round_add.queue_redraw()

func _draw_round_adds() -> void :
	for job: Array in _map_adds:
		_round_add.draw_set_transform_matrix(job[1])
		_fx_cell(_round_add, job[0], int(job[2]), Color(1, 1, 1, float(job[3])))
	for job: Array in _round_adds:
		_round_add.draw_set_transform_matrix(job[1])
		_fx_cell(_round_add, job[0], int(job[2]), Color.WHITE)
	_round_add.draw_set_transform(Vector2.ZERO)


func round_drawn() -> Dictionary:
	return {"adds": _round_adds.size(), "layer": _round_add != null and is_instance_valid(_round_add)}


func _clock(rect: Rect2, percent: float, mirror: bool = false) -> void :
	percent = clampf(percent, 0, 1)
	if percent <= 0.001:
		return
	var c: Vector2 = rect.get_center()
	var half: Vector2 = rect.size / 2
	var points: PackedVector2Array = [c]
	var start: float = - PI / 2 + (1 - percent) * TAU
	var steps: int = maxi(2, ceili(percent * 72))
	for i in range(steps + 1):
		var angle: float = lerpf(start, 1.5 * PI, float(i) / steps)
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		if mirror:
			dir.x = - dir.x
		var k: float = minf(half.x / maxf(absf(dir.x), 0.0001), half.y / maxf(absf(dir.y), 0.0001))
		points.append(c + dir * k)

	view.draw_colored_polygon(_square_fix(points, rect), Color(0, 0, 0, 0.6))

func _square_fix(points: PackedVector2Array, rect: Rect2) -> PackedVector2Array:
	var out: PackedVector2Array = [points[0]]
	for i in range(1, points.size()):
		if i > 1:
			var a: Vector2 = points[i - 1]
			var b: Vector2 = points[i]
			if absf(a.x - b.x) > 0.01 and absf(a.y - b.y) > 0.01:
				var corner: Vector2 = Vector2(b.x if is_equal_approx(a.y, rect.position.y) or is_equal_approx(a.y, rect.end.y) else a.x, 
					a.y if is_equal_approx(a.y, rect.position.y) or is_equal_approx(a.y, rect.end.y) else b.y)
				out.append(corner)
		out.append(points[i])
	return out

func _bar(name: String, pos: Vector2, size: Vector2, fraction: float) -> void :
	var texture: Texture2D = tex(name)
	fraction = clampf(fraction, 0, 1)
	if texture == null or fraction <= 0:
		return
	view.draw_texture_rect_region(texture, Rect2(pos, Vector2(size.x * fraction, size.y)), 
		Rect2(Vector2.ZERO, Vector2(texture.get_width() * fraction, texture.get_height())))





const DEATH_GM: Vector2 = Vector2(-7.5, 0)
const TROPHY_Y: float = 38.5
const TROPHY_SIZE: Vector2 = Vector2(26, 23)

const DEATH_ROUND: String = "Trận %d"

const ALIVE_GLOW: Array = [Color("067294"), Color("6d0202")]
const ALIVE_GLOW_SIZE: int = 4

var top_drawn: Dictionary = {}

static func trophy_count(max_rounds: int) -> int:
	return clampi(4 - max_rounds, 0, 4)

static func trophy_pos(side: int, i: int) -> Vector2:
	return Vector2(81 - 24 * i if side == 0 else 210 + 24 * i, TROPHY_Y)



func trophy_center(battle, camp: int) -> Vector2:
	var count: int = trophy_count(int(battle.max_rounds))
	if count == 0:
		return Vector2.ZERO
	var side: int = 0 if camp == 1 else 1
	var wins: int = int(battle.a_wins) if side == 0 else int(battle.b_wins)
	var origin: Vector2 = Vector2(view.size.x / 2 - 150 * scale, 0)
	return origin + (DEATH_GM + trophy_pos(side, clampi(wins - 1, 0, count - 1)) + TROPHY_SIZE / 2) * scale


const HP1_AT: Array = [71.5, 56.0]
const HP1_WIDTH: float = 160.0
const HP1_SIZE: int = 16
const HP1_COLOR: Color = Color("ffd84a")

func _top(battle) -> void :
	var origin: Vector2 = Vector2(view.size.x / 2 - 150 * scale, 0)
	_at(origin)
	if battle.mode == "happy":
		Happy.draw_top(self, battle)
		return
	var clock_pos: Vector2 = Vector2(123, 27)
	var show_icon: bool = false
	top_drawn = {"mode": battle.mode}
	match battle.mode:
		"alive":
			var gm: Vector2 = Vector2(3.5, 0)
			_img("alive_bg", gm + Vector2(2, 1))
			_img("alive_left_" + _side(battle, 1), gm + Vector2(20, 6))
			_img("alive_right_" + _side(battle, 2), gm + Vector2(200, 6))
			var cap: int = battle.kill_target if battle.kill_target > 0 else 1 << 30


			var glow_a: Color = ALIVE_GLOW[0 if _side(battle, 1) == "blue" else 1]
			var glow_b: Color = ALIVE_GLOW[0 if _side(battle, 2) == "blue" else 1]
			var kills: Array = [str(mini(battle.red_kills, cap)), str(mini(battle.blue_kills, cap))]
			_look_text(gm + Vector2(16, 9), kills[0], Color("fefefe"), 20, glow_a, ALIVE_GLOW_SIZE, HORIZONTAL_ALIGNMENT_CENTER, 90)
			_look_text(gm + Vector2(193, 9), kills[1], Color("fefefe"), 20, glow_b, ALIVE_GLOW_SIZE, HORIZONTAL_ALIGNMENT_CENTER, 90)
			if battle.kill_target > 0:
				_text(gm + Vector2(108, 7), str(battle.kill_target), Color("fdf8ad"), 15, HORIZONTAL_ALIGNMENT_CENTER, 77, true, 0)
			top_drawn.merge({"bg": "alive_bg", "left": "alive_left_" + _side(battle, 1), "right": "alive_right_" + _side(battle, 2), 
				"a": kills[0], "b": kills[1], "mid": str(battle.kill_target) if battle.kill_target > 0 else "", "glow": [glow_a, glow_b]})
		"occupy":
			var gm: Vector2 = Vector2(-23, 0)
			_img("occupy_bg", gm + Vector2(0, 1))
			_img("occupy_left_" + _side(battle, 1), gm + Vector2(17, 7))
			_img("occupy_right_" + _side(battle, 2), gm + Vector2(225, 7))
			var left_bar: String = "scoreblood_%sleft" % _side(battle, 1)
			var right_bar: String = "scoreblood_%sright" % _side(battle, 2)
			var a_frame: int = occupy_frame(battle.a_score, battle.kill_target)
			var b_frame: int = occupy_frame(battle.b_score, battle.kill_target)
			_occupy_bar(left_bar, gm + Vector2(17, 7), a_frame, false)
			_occupy_bar(right_bar, gm + Vector2(225, 7), b_frame, true)
			top_drawn.merge({"left": left_bar, "right": right_bar, "a_frame": a_frame, "b_frame": b_frame, 
				"a_width": occupy_bar_width(a_frame), "b_width": occupy_bar_width(b_frame)})
			_text(gm + Vector2(28, 7), str(battle.a_score), Color("fbfffe"), 18, HORIZONTAL_ALIGNMENT_CENTER, 90)
			_text(gm + Vector2(232, 7), str(battle.b_score), Color("fbfffe"), 18, HORIZONTAL_ALIGNMENT_CENTER, 90)
			_text(gm + Vector2(128, 7), str(battle.kill_target), Color("fdf8ad"), 14, HORIZONTAL_ALIGNMENT_CENTER, 90)
			for side in range(2):
				var camp: int = side + 1
				for i in range(battle.flags_of(camp)):
					var x: float = 26 + 68 - i * 34 if side == 0 else 221 + i * 34
					_img("flag_%s_%s" % [_side(battle, camp), "left" if side == 0 else "right"], gm + Vector2(x, 38))
			clock_pos = Vector2(123, 31)
		"death":





			var gm: Vector2 = Vector2(3.5, 0)
			_img("alive_bg", gm + Vector2(2, 1))
			_img("alive_left_red", gm + Vector2(20, 6))
			_img("alive_right_blue", gm + Vector2(200, 6))
			var alive: Array = [str(battle.death_alive_count(1)), str(battle.death_alive_count(2))]
			var round_text: String = DEATH_ROUND % int(battle.death_round)
			_text(gm + Vector2(16, 9), alive[0], Color("fefefe"), 20, HORIZONTAL_ALIGNMENT_CENTER, 90, true, 0)
			_text(gm + Vector2(193, 9), alive[1], Color("fefefe"), 20, HORIZONTAL_ALIGNMENT_CENTER, 90, true, 0)
			_text(gm + Vector2(108, 7), round_text, Color("fdf8ad"), 15, HORIZONTAL_ALIGNMENT_CENTER, 77, true, 0)
			for side in range(2):
				var lit: int = battle.trophy_a if side == 0 else battle.trophy_b
				for i in range(trophy_count(int(battle.max_rounds))):
					_img("trophy1" if i < lit else "trophy2", DEATH_GM + trophy_pos(side, i))
			top_drawn.merge({"bg": "alive_bg", "left": "alive_left_red", "right": "alive_right_blue", "a": alive[0], "b": alive[1], 
				"mid": round_text, "glow": []})
		"kill_ai":
			_img("gameboard_bk", Vector2(3.5, 1))
			_kill_ai(battle)
			clock_pos = Vector2(135, 45)
			show_icon = true
		"home":
			_img("gameboard_bk", Vector2(3.5, 1))
			var home: Vector2 = Vector2(3.5 + 43, 1)
			_img("fightstate_bk", home)
			_home_mode(battle, home)
			clock_pos = Vector2(135, 45)
			show_icon = true
		_:


			_img("gameboard_bk", Vector2(3.5, 1))
			clock_pos = Vector2(135, 45)
			show_icon = true
	top_drawn["clock"] = clock_pos
	top_drawn["icon"] = show_icon and battle.clock_icon
	if show_icon and battle.clock_icon:
		_img("icon_clock", Vector2(119, 47))

	if battle.clock_shown:
		_text(clock_pos, clock_text(int(battle.clock_left)), Color.BLACK, int(TimeOver.CLOCK[0]), HORIZONTAL_ALIGNMENT_CENTER, 
			float(TimeOver.CLOCK[1]), true, 0)
	if battle.over_shown and pack != null:
		var over: Dictionary = pack.effect(TimeOver.OVER)
		if not over.is_empty():
			_fx_frame(over, Vector2(TimeOver.OVER_AT[0], TimeOver.OVER_AT[1]), int(floor(battle.clock * TimeOver.FPS)) % over.data.frames.size())

	if battle.over_shown and battle.overtime_seconds > 0 and battle.clock_running and battle.clock_left > 0:
		var hp1_text: String = "Hiệp phụ %ds" % int(battle.clock_left)
		top_drawn["hp1"] = hp1_text
		_text(Vector2(HP1_AT[0], HP1_AT[1]), hp1_text, HP1_COLOR, HP1_SIZE, HORIZONTAL_ALIGNMENT_CENTER, HP1_WIDTH, true, 3)





const KILL_AI_AT: Vector2 = Vector2(3.5 + 27.5 + 10, 0 + 6 + 4)
const KILL_AI_WIDTH: float = 215.0
const KILL_AI_NAME: int = 18
const KILL_AI_TAG: int = 12
const KILL_AI_LOOK: Dictionary = {1: [Color.WHITE, ""], 2: [Color("ff0000"), "Chế độ khó"], 3: [Color("ffff00"), "Chế độ Anh Hùng"]}

static func kill_ai_line(battle) -> Array:
	var row: Array = PveMapRows.MAPS.get(str(int(battle.map_id)), [])
	var look: Array = KILL_AI_LOOK.get(int(row[4]) if row.size() > 4 else 0, [Color.WHITE, ""])
	return [battle.title(), look[1], look[0]]

func _kill_ai(battle) -> void :
	var line: Array = kill_ai_line(battle)
	var name: String = line[0]
	var tag: String = line[1]
	var wide: float = _text_width(name, KILL_AI_NAME) + (_text_width(tag, KILL_AI_TAG) if not tag.is_empty() else 0.0)
	var left: float = KILL_AI_AT.x + (KILL_AI_WIDTH - wide) / 2
	var base: float = KILL_AI_AT.y + KILL_AI_NAME + 1
	_text(Vector2(left, KILL_AI_AT.y), name, line[2], KILL_AI_NAME, HORIZONTAL_ALIGNMENT_LEFT, -1, true, 0)
	if not tag.is_empty():
		_text(Vector2(left + _text_width(name, KILL_AI_NAME), base - KILL_AI_TAG - 1), tag, line[2], KILL_AI_TAG, HORIZONTAL_ALIGNMENT_LEFT, -1, true, 0)
	top_drawn.merge({"bg": "gameboard_bk", "mid": name + tag, "color": line[2]})

func _side(battle, camp: int) -> String:
	return "blue" if camp == battle.self_camp() else "red"

func _camp_color(battle, camp: int) -> Color:
	return Color("49ecff") if camp == battle.self_camp() else Color("ff5a4a")

func _base_percent(battle, camp: int) -> int:
	return view._base_percent(camp)


const HOME_GLOW: Array = [Color(0.4, 0, 0, 0.8), Color(0, 0.2, 0.4, 0.8)]





func _home_mode(battle, home: Vector2) -> void :
	var bases: Dictionary = battle.base_camps()
	for side in range(2):
		var base: Dictionary = bases.get(side + 1, {})
		if base.is_empty():
			continue
		var blue: bool = side + 1 == battle.self_camp()
		var key: String = "left" if side == 0 else "right"
		var at: Vector2 = home + Vector2(5 if side == 0 else 113, 5)
		var width: int = home_bar_width(home_percent(float(base.hp), float(base.max_hp)), side == 1, blue)
		var region: Rect2 = Rect2(0 if side == 0 else 95 - width, 0, width, 33)

		var since: float = battle.clock - float(base.get("lit", -1000.0))
		if width > 0 and since >= 0 and since < 3.0:
			var phase: float = fmod(since, 1.6) / 0.8
			_home_glow(tex("hoomblood_%s_mask" % key), at, region, phase if phase <= 1.0 else 2.0 - phase)
		var bar: Texture2D = tex("hoomblood_%s_%s" % [key, "blue" if blue else "red"])
		if bar != null and width > 0:
			view.draw_texture_rect_region(bar, Rect2(at + region.position, region.size), region)
	_img("homeblood_bk", home + Vector2(14, 7))
	for side in range(2):
		var base: Dictionary = bases.get(side + 1, {})
		if base.is_empty():
			continue
		var text: String = "%d%%" % home_percent(float(base.hp), float(base.max_hp))
		var pos: Vector2 = home + Vector2(11 if side == 0 else 114, 9 + 21)
		view.draw_string_outline(bold, pos, text, HORIZONTAL_ALIGNMENT_CENTER, 90, 20, 6, HOME_GLOW[side])
		view.draw_string(bold, pos, text, HORIZONTAL_ALIGNMENT_CENTER, 90, 20, Color.WHITE)


func _home_glow(mask: Texture2D, at: Vector2, region: Rect2, k: float) -> void :
	if mask == null or k <= 0:
		return
	for r in range(1, 7):
		var color: Color = Color(1, 1, 0, 0.22 * k * (1.0 - (r - 1) / 6.0))
		for i in range(8):
			var off: Vector2 = Vector2.from_angle(i * PI / 4) * r
			view.draw_texture_rect_region(mask, Rect2(at + region.position + off, region.size), region, color)


static func home_percent(hp: float, max_hp: float) -> int:
	if max_hp <= 0:
		return 0
	var pct: int = clampi(int(maxf(0.0, hp) * 100.0 / max_hp), 0, 100)
	return 1 if pct == 0 and hp > 0 else pct




func _occupy_bar(bar: String, at: Vector2, frame: int, right: bool) -> void :
	_img(bar + "_bk", at)
	var width: int = occupy_bar_width(frame)
	var fill: Texture2D = tex(bar)
	if fill != null and width > 0:
		var region: Rect2 = Rect2(109 - width if right else 0, 0, width, 28)
		view.draw_texture_rect_region(fill, Rect2(at + region.position, region.size), region)


static func occupy_frame(score: int, cap: int) -> int:
	if cap <= 0 or score <= 0:
		return 0
	return clampi(int(score * 100.0 / cap), 1, 100)


static func occupy_bar_width(frame: int) -> int:
	return 0 if frame <= 0 else roundi(6 + (frame - 1) * 100 / 99.0)



static func home_bar_width(pct: int, right: bool, blue: bool) -> int:
	if pct <= 0:
		return 0
	if right and (pct == 1 or (pct == 2 and blue)):
		return 95
	return clampi(roundi((pct - 1) * 95.0 / 99.0), 0, 95)







const GOOD_PING: int = 200
const NORMAL_PING: int = 400
const COLOR_GOOD_PING: Color = Color(0, 1, 0)
const COLOR_NORMAL_PING: Color = Color(1, 1, 0)
const COLOR_BAD_PING: Color = Color(1, 0, 0)

static func ping_value(latency_ms: int) -> int:
	return maxi(0, latency_ms)

static func ping_text(latency_ms: int) -> String:
	return "%dms" % ping_value(latency_ms)

static func ping_color(latency_ms: int) -> Color:
	var ping: int = ping_value(latency_ms)
	if ping <= GOOD_PING:
		return COLOR_GOOD_PING
	if ping <= NORMAL_PING:
		return COLOR_NORMAL_PING
	return COLOR_BAD_PING











const SYS_H: float = 30.0
const SYS_H2: float = 39.0
const SYS_LINE: float = 14.0
const SYS_RIGHT: float = 1.0
const SYS_PAD: float = 8.0
const SYS_GAP: float = 8.0
const SYS_INFO_GAP: float = 10.0
const SYS_BTN: float = 22.0
const SYS_PING_W: float = 46.0
const SYS_RADIUS: int = 5
const SYS_BG: Color = Color(0, 0, 0, 0.82)
const SYS_BORDER: Color = Color(0.95, 0.95, 0.95)
const SYS_DIVIDER: Color = Color(1, 1, 1, 0.28)
const SYS_FPS_SAMPLE: String = "888 FPS"
const SYS_GOAL_MIN: float = 40.0


const TOP_RIGHT: Dictionary = {"alive": 294.5, "death": 294.5, "occupy": 323.0, "happy": 208.5}
const TOP_RIGHT_DEFAULT: float = 296.5






const VOICE_UI: = false
const VOICE_TEAL_T: Color = Color("#35b7a2")
const VOICE_TEAL_B: Color = Color("#0b6b5b")
const VOICE_EDGE: Color = Color("#3a0000")
const VOICE_TALK: Color = Color("#4dff7a")
const VOICE_RED: Color = Color("#ff4a3d")
const VOICE_W: float = 6.0 + SYS_BTN + 6.0 + SYS_BTN + 6.0
var voice_ui: bool = VOICE_UI
var voice_spk: String = "spk"
var voice_mic: bool = true
var voice_talk: bool = false
var voice_hold_on: bool = false
const VOICE_TOUCH_SIDE: float = 22.0
const VOICE_TOUCH_DOWN: float = 24.0




const SYS_TOUCH_SIDE: float = 20.0
const SYS_TOUCH_DOWN: float = 20.0
const SYS_TOUCH_GAP: float = 10.0


var sys_bar: Dictionary = {}
var _sys_box: StyleBoxFlat = null
var _goal_memo: Dictionary = {}
var _voice_tex: Dictionary = {}






const VOICE_CHIP_LEFT: Vector2 = Vector2(74, 62)
const VOICE_CHIP_RIGHT: Vector2 = Vector2(-10, 62)
const VOICE_CHIP_R: float = 8.0
const VOICE_CHIP_HIT: float = 12.0
const VOICE_CHIP_HIT_TOUCH: float = 22.0
var voice_chips: Dictionary = {}
var voice_chip_icons: Dictionary = {}
var voice_menu: int = 0
var voice_menu_box: Rect2 = Rect2()
var voice_menu_rows: Dictionary = {}


func score_right(battle) -> float:
	return view.size.x / 2 - 150 * scale + float(TOP_RIGHT.get(str(battle.mode), TOP_RIGHT_DEFAULT)) * scale



func goal_fit(text: String, room: float) -> Array:
	room = maxf(SYS_GOAL_MIN, floorf(room))
	var key: String = "%d|%s" % [int(room), text]
	var hit: Variant = _goal_memo.get(key)
	if hit != null:
		return hit
	var lines: Array = []
	var full: float = _text_width(text, 12)
	if text.is_empty():
		pass
	elif full <= room:
		lines = [text]
	else:
		var wrap: Array[String] = _wrap_raw(text, room, 12)
		if wrap.size() <= 2:
			var lo: float = floorf(full / 2.0) - 8.0
			var hi: float = room
			while hi - lo > 1.0:
				var mid: float = floorf((lo + hi) / 2.0)
				if _wrap_raw(text, mid, 12).size() <= 2:
					hi = mid
				else:
					lo = mid
			wrap = _wrap_raw(text, hi, 12)
			for line: String in wrap:
				lines.append(line.strip_edges())
		else:
			lines = [wrap[0].strip_edges(), _ellipsis(text.substr(wrap[0].length()).strip_edges(), room)]
	var width: float = 0.0
	for line: String in lines:
		width = maxf(width, _text_width(line, 12))
	if _goal_memo.size() >= 64:
		_goal_memo.clear()
	_goal_memo[key] = [lines, width]
	return _goal_memo[key]

func _ellipsis(text: String, width: float) -> String:
	if _text_width(text, 12) <= width:
		return text
	var cut: int = text.length()
	while cut > 1 and _text_width(text.left(cut).strip_edges(false, true) + "…", 12) > width:
		cut -= 1
	return text.left(cut).strip_edges(false, true) + "…"


static func digits_wide(text: String) -> String:
	var out: String = ""
	for i in range(text.length()):
		var ch: String = text[i]
		out += "8" if ch >= "0" and ch <= "9" else ch
	return out

func _sys_bar(client) -> void :
	var battle = client.battle
	_voice_sync(client)
	sys_bar = {}
	fps_rect = Rect2()

	var latency: int = int(client.latency_ms)
	delay_shown = {"text": ping_text(latency), "color": ping_color(latency)}
	if touch:
		delay_shown = TouchLife.ping_shown(client, delay_shown, COLOR_BAD_PING)
	var fps_text: String = ""
	var fps_color: Color = COLOR_GOOD_PING
	var fps_w: float = 0.0
	if Settings.on("fps"):

		FpsMeter.sample(Time.get_ticks_usec())
		var fps: float = Engine.get_frames_per_second()
		var fps_ref: float = FpsMeter.target(TouchGfx.fps_limit(), FpsMeter.refresh_rate())
		var fps_grade: int = FpsMeter.grade(fps, fps_ref)
		fps_color = COLOR_GOOD_PING if fps_grade == 0 else (COLOR_NORMAL_PING if fps_grade == 1 else COLOR_BAD_PING)
		fps_text = "%d FPS" % roundi(fps)
		fps_w = maxf(_text_width(SYS_FPS_SAMPLE, 12), _text_width(fps_text, 12))

	var exit_on: bool = not (battle.room_type in NO_EXIT_ROOMS and not battle.look)
	var goal_on: bool = dest_visible(battle)
	var goal_text: String = str(battle.dest_text) if goal_on else ""
	var info: String = str(battle.info_tip) if goal_on and dest_info_visible(battle) else ""
	var info_w: float = maxf(_text_width(info, 12), _text_width(digits_wide(info), 12)) if not info.is_empty() else 0.0
	goal_on = goal_on and not (goal_text.is_empty() and info.is_empty())
	var board_on: bool = touch
	var sys_gap: float = SYS_TOUCH_GAP if touch else 0.0
	var ping_w: float = 4.0 + SYS_PING_W + (SYS_BTN + sys_gap if exit_on else 0.0) + (SYS_BTN + sys_gap if board_on else 0.0) + SYS_BTN + 4.0
	var fixed: float = ping_w + (SYS_PAD * 2 + fps_w if not fps_text.is_empty() else 0.0) + (VOICE_W if voice_ui else 0.0)
	var limit: float = score_right(battle) + SYS_GAP * scale
	var fit: Array = [[], 0.0]
	if goal_on and not goal_text.is_empty():
		var room: float = (view.size.x - SYS_RIGHT * scale - safe_tr.x - limit) / scale - fixed - SYS_PAD * 2\
		- (SYS_INFO_GAP + info_w if not info.is_empty() else 0.0)
		fit = goal_fit(goal_text, room)
	var lines: Array = fit[0]
	var goal_w: float = float(fit[1])
	var height: float = SYS_H2 if lines.size() > 1 else SYS_H
	var parts: Array = []
	if not fps_text.is_empty():
		parts.append(["fps", SYS_PAD * 2 + fps_w])
	if goal_on:
		var gap: float = SYS_INFO_GAP if goal_w > 0 and info_w > 0 else 0.0
		parts.append(["goal", SYS_PAD * 2 + goal_w + gap + info_w])
	if voice_ui:
		parts.append(["voice", VOICE_W])
	parts.append(["ping", ping_w])
	var total: float = 0.0
	for part: Array in parts:
		total += float(part[1])
	var origin: Vector2 = Vector2(view.size.x - (total + SYS_RIGHT) * scale - safe_tr.x, safe_tr.y)
	_at(origin)
	if _sys_box == null:
		_sys_box = StyleBoxFlat.new()
		_sys_box.bg_color = SYS_BG
		_sys_box.border_color = SYS_BORDER
		_sys_box.set_border_width_all(2)
		_sys_box.set_corner_radius_all(SYS_RADIUS)
		_sys_box.anti_aliasing = true
	view.draw_style_box(_sys_box, Rect2(0, 0, total, height))
	var mid: float = height / 2.0
	var row: float = mid - 9.0
	var btn_y: float = (height - SYS_BTN) / 2.0
	var rects_drawn: Dictionary = {}
	var dividers: Array = []
	var x: float = 0.0
	var exit_x: float = -1.0
	for i in range(parts.size()):
		var kind: String = parts[i][0]
		var width: float = parts[i][1]
		if i > 0:
			view.draw_line(Vector2(x, 8), Vector2(x, height - 8), SYS_DIVIDER, 1.0)
			dividers.append(origin.x + x * scale)
		rects_drawn[kind] = _screen(origin, Rect2(x, 0, width, height))
		match kind:
			"fps":
				_text(Vector2(x + SYS_PAD, row), fps_text, fps_color, 12, HORIZONTAL_ALIGNMENT_CENTER, fps_w, true, 2)
				fps_rect = _screen(origin, Rect2(x, 2, width, height - 4))
			"goal":
				var top: float = row - (SYS_LINE / 2.0) * (lines.size() - 1)
				for n in range(lines.size()):
					_glow_text(Vector2(x + SYS_PAD, top + n * SYS_LINE), str(lines[n]), DEST_TEXT, HORIZONTAL_ALIGNMENT_LEFT, -1)
				if goal_w > 0:
					rects_drawn["goal_text"] = _screen(origin, Rect2(x + SYS_PAD, top + 2, goal_w, SYS_LINE * lines.size()))
				if info_w > 0:
					var info_x: float = x + width - SYS_PAD - info_w
					_glow_text(Vector2(info_x, row), info, DEST_INFO, HORIZONTAL_ALIGNMENT_RIGHT, info_w)
					rects_drawn["info"] = _screen(origin, Rect2(info_x, row + 2, info_w, SYS_LINE))
			"voice":
				var spk_at: Vector2 = Vector2(x + 6, btn_y)
				var mic_at: Vector2 = Vector2(x + 6 + SYS_BTN + 6, btn_y)
				_voice_btn(spk_at, voice_spk, false)
				_voice_btn(mic_at, "mic" if voice_mic else "mic_off", voice_talk)
				rects_drawn["voice_spk"] = _screen(origin, Rect2(spk_at, Vector2(SYS_BTN, SYS_BTN)))
				rects_drawn["voice_mic"] = _screen(origin, Rect2(mic_at, Vector2(SYS_BTN, SYS_BTN)))
				if touch:
					rects["voice_spk"] = _screen(origin, Rect2(spk_at.x - VOICE_TOUCH_SIDE, 0, VOICE_TOUCH_SIDE + SYS_BTN + 3, height + VOICE_TOUCH_DOWN))
					rects["voice_mic"] = _screen(origin, Rect2(mic_at.x - 3, 0, 3 + SYS_BTN + VOICE_TOUCH_SIDE, height + VOICE_TOUCH_DOWN))
				else:
					rects["voice_spk"] = _screen(origin, Rect2(spk_at - Vector2(2, 2), Vector2(SYS_BTN + 4, SYS_BTN + 4)))
					rects["voice_mic"] = _screen(origin, Rect2(mic_at - Vector2(2, 2), Vector2(SYS_BTN + 4, SYS_BTN + 4)))
			"ping":
				_text(Vector2(x + 4, row), str(delay_shown.text), delay_shown.color, 12, HORIZONTAL_ALIGNMENT_CENTER, SYS_PING_W, true, 2)
				if delay_shown.get("dot", false):
					view.draw_circle(Vector2(x + 3.5, mid), 3.0, Color(COLOR_BAD_PING, TouchLife.dot_alpha()))
				rects_drawn["ping_text"] = _screen(origin, Rect2(x + 4, row + 2, SYS_PING_W, SYS_LINE))
				var bx: float = x + 4 + SYS_PING_W
				var row_keys: Array = []
				if exit_on:
					_img("system_exit", Vector2(bx, btn_y))
					rects["exit"] = _screen(origin, Rect2(bx - 2, btn_y - 2, SYS_BTN + 4, SYS_BTN + 4))
					rects_drawn["exit"] = _screen(origin, Rect2(bx, btn_y, SYS_BTN, SYS_BTN))
					row_keys.append("exit")
					exit_x = bx
					bx += SYS_BTN + (SYS_TOUCH_GAP if touch else 0.0)
				else:
					rects.erase("exit")
				if board_on:
					_voice_btn(Vector2(bx, btn_y), "menu", false)
					rects["board"] = _screen(origin, Rect2(bx - 2, btn_y - 2, SYS_BTN + 4, SYS_BTN + 4))
					rects_drawn["board"] = _screen(origin, Rect2(bx, btn_y, SYS_BTN, SYS_BTN))
					row_keys.append("board")
					bx += SYS_BTN + (SYS_TOUCH_GAP if touch else 0.0)
				else:
					rects.erase("board")
				_img("system_set", Vector2(bx, btn_y))
				rects["set"] = _screen(origin, Rect2(bx - 2, btn_y - 2, SYS_BTN + 4, SYS_BTN + 4))
				rects_drawn["set"] = _screen(origin, Rect2(bx, btn_y, SYS_BTN, SYS_BTN))
				row_keys.append("set")
				if exit_x < 0:
					exit_x = bx - SYS_BTN
				if touch:
					_sys_touch_rects(row_keys, rects_drawn, origin.y + (height + SYS_TOUCH_DOWN) * scale)
		x += width
	sys_bar = {"bar": _screen(origin, Rect2(0, 0, total, height)), "height": height * scale, "lines": lines.duplicate(), 
		"parts": rects_drawn, "dividers": dividers, "limit": limit}

	_look_exit_tip(battle, Vector2(origin.x + (exit_x - 71.0) * scale, (btn_y - 4.0) * scale))



func _sys_touch_rects(keys: Array, drawn: Dictionary, bottom: float) -> void :
	for i in range(keys.size()):
		var img: Rect2 = drawn[keys[i]]
		var left: float = img.position.x - (SYS_TOUCH_SIDE * scale if i == 0 else 0.0)
		var right: float = view.size.x if i == keys.size() - 1 else (drawn[keys[i + 1]] as Rect2).position.x - SYS_TOUCH_GAP * scale / 2.0
		if i > 0:
			left = (rects[keys[i - 1]] as Rect2).end.x
		rects[keys[i]] = Rect2(left, 0, right - left, bottom)


func _voice_sync(client) -> void :
	if not VoiceClient.usable():
		return
	var voice: Object = VoiceClient.shared()
	voice.attach(client)
	voice_ui = voice.battle_shown()
	voice_spk = "spk_off" if voice.speaker == "off" else ("spk" if voice.speaker == "all" else "spk_room")
	var mic: String = voice.mic_state()
	voice_mic = mic != "off"
	voice_hold_on = voice.touch_hold and voice_mic
	voice_talk = mic == "talk" or voice_hold_on



func voice_hold(point: Vector2, client) -> bool:
	if not touch or not voice_ui or view.size != _drawn_size or view._touch != touch or not VoiceClient.usable():
		return false
	if not rects.has("voice_mic") or not (rects["voice_mic"] as Rect2).has_point(point):
		return false
	var voice: Object = VoiceClient.shared()
	voice.attach(client)
	if voice.mic_mode() != "ptt":
		return false
	voice.hold_talk(true)
	voice_hold_on = voice.touch_hold
	return true


func voice_hold_end() -> void :
	voice_hold_on = false
	if VoiceClient.usable():
		VoiceClient.shared().hold_talk(false)


func _voice_btn(at: Vector2, icon: String, talk: bool) -> void :
	var r: Rect2 = Rect2(at, Vector2(SYS_BTN, SYS_BTN))
	_sys_grad(r, 4.0, VOICE_TEAL_T, VOICE_TEAL_B, VOICE_EDGE, 1.2)
	_sys_grad(Rect2(r.position + Vector2(1.5, 1.5), Vector2(SYS_BTN - 3, 9)), 3.0, Color(1, 1, 1, 0.45), Color(1, 1, 1, 0.05))
	var px: int = maxi(16, int(ceilf(15.0 * scale * 2.0)))
	var key: String = "%s:%d" % [icon, px]
	if not _voice_tex.has(key):
		_voice_tex[key] = SysIcons.texture(icon, float(px), Color.WHITE, VOICE_RED)
	var texture: Texture2D = _voice_tex[key]
	if texture != null:
		view.draw_texture_rect(texture, Rect2(r.get_center() - Vector2(7.5, 7.5), Vector2(15, 15)), false)
	if talk:
		var loop: PackedVector2Array = _sys_rounded(r.grow(2.5), 6.0)
		loop.append(loop[0])
		view.draw_polyline(loop, VOICE_TALK, 2.2, true)

func _sys_rounded(r: Rect2, rad: float) -> PackedVector2Array:
	rad = minf(rad, minf(r.size.x, r.size.y) * 0.5)
	var pts: PackedVector2Array = PackedVector2Array()
	var corners: Array = [[r.position + Vector2(r.size.x - rad, rad), -90.0], [r.end - Vector2(rad, rad), 0.0], 
		[Vector2(r.position.x + rad, r.end.y - rad), 90.0], [r.position + Vector2(rad, rad), 180.0]]
	for corner: Array in corners:
		for step in range(9):
			var a: float = deg_to_rad(float(corner[1]) + step * 90.0 / 8.0)
			pts.append(corner[0] + Vector2(cos(a), sin(a)) * rad)
	return pts

func _sys_grad(r: Rect2, rad: float, top: Color, bottom: Color, border: Color = Color(0, 0, 0, 0), border_w: float = 1.0) -> void :
	var pts: PackedVector2Array = _sys_rounded(r, rad)
	var colors: PackedColorArray = PackedColorArray()
	for p: Vector2 in pts:
		colors.append(top.lerp(bottom, clampf((p.y - r.position.y) / r.size.y, 0.0, 1.0)))
	view.draw_polygon(pts, colors)
	if border.a > 0.0:
		var loop: PackedVector2Array = pts.duplicate()
		loop.append(pts[0])
		view.draw_polyline(loop, border, border_w, true)





const DEST_TEXT: Color = Color("ffcc00")
const DEST_INFO: Color = Color("00ff24")
const DEST_GLOW: Color = Color(22 / 255.0, 0, 0, 0.8)
const DEST_INFO_TYPES: Array = [1, 12, 13, 15, 17]

static func dest_visible(battle) -> bool:
	return battle != null and battle.dest_shown and battle.mode != "happy"

static func dest_info_visible(battle) -> bool:
	return int(Text.map_info(battle.map_id).get("type", 0)) in DEST_INFO_TYPES

func _glow_text(pos: Vector2, text: String, color: Color, align: HorizontalAlignment, width: float) -> void :
	if text.is_empty():
		return
	var base: Vector2 = pos + Vector2(0, 13)
	view.draw_string_outline(bold, base, text, align, width, 12, 3, DEST_GLOW)
	view.draw_string(bold, base, text, align, width, 12, color)



const KILL_SELF: Color = Color(40 / 255.0, 186 / 255.0, 238 / 255.0)
const KILL_FOE: Color = Color(1, 0, 0)
const KILL_NONE: Color = Color(1, 1, 0)
const KILL_AVATAR_ZOOM: float = 0.17
const KILL_DEAD_AVATAR_X: float = 286.0

const KILL_AREA_Y: float = 40.0
const KILL_AREA_SIZE: Vector2 = Vector2(390, 88)
const KILL_AREA_SIZE_TEXT: int = 14
const KILL_AREA_GUTTER: float = 2.0
var _kill_words: RegEx = null

static func kill_color(battle, camp: int) -> Color:
	if camp < 0:
		return Color.WHITE
	if camp == 0:
		return KILL_NONE
	return KILL_SELF if camp == battle.self_camp() else KILL_FOE




func _kills(battle) -> void :
	if battle.kills.is_empty():
		return
	var origin: Vector2 = Vector2(view.size.x - 320 * scale - safe_in.z, 39 * scale + safe_tr.y)
	var now: float = float(battle.clock)
	_at(origin)
	for i in range(battle.kills.size()):
		var kill: Dictionary = battle.kills[i]
		var alpha: float = battle.kill_row_alpha(kill, now)
		var y: float = battle.kill_row_y(kill, i, now)
		var dead_w: float = _text_width(str(kill.dead), 15)
		var killer_w: float = _text_width(str(kill.killer), 15)
		var dead_x: float = KILL_DEAD_AVATAR_X - dead_w - 3
		var icon_x: float = dead_x - 3 - 28
		var killer_x: float = icon_x - killer_w - 5
		var avatar_x: float = killer_x - 35
		_img("bg_kill", Vector2(avatar_x, y - 2), alpha)
		_kill_avatar(battle, int(kill.get("killer_account", 0)), origin, Vector2(avatar_x, y), alpha)
		_text(Vector2(killer_x, y + 4), str(kill.killer), Color(kill_color(battle, int(kill.killer_camp)), alpha), 15)
		_img("technique_kill", Vector2(icon_x, y + 1), alpha)
		_text(Vector2(dead_x, y + 4), str(kill.dead), Color(kill_color(battle, int(kill.dead_camp)), alpha), 15)
		_kill_avatar(battle, int(kill.get("dead_account", 0)), origin, Vector2(KILL_DEAD_AVATAR_X, y), alpha)



func _kill_avatar(battle, account: int, origin: Vector2, at: Vector2, alpha: float) -> void :
	var other: Variant = brief_of(battle, account).get("otherData")
	if not other is Dictionary or pack == null or pack.state != "ready":
		return
	var tank_id: int = int(other.get("tankId", 0))
	if tank_id <= 0:
		return
	var worn: int = int(other.get("tankExternal", 0))
	var level: int = maxi(1, int(other.get("tankLevel", 1)))
	var center: Vector2 = at + Vector2.ONE * TankPortrait.BOX * 0.5 * KILL_AVATAR_ZOOM
	var look: Array = _avatar_look(tank_id, worn, level, int(other.get("honorId", 0)))
	if _portrait(look[0], look[1], center, KILL_AVATAR_ZOOM, float(battle.clock), Color(1, 1, 1, alpha)):
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(worn), tank_id))
	if TankPreview.ready(art):
		TankPreview.draw(view, art, origin + center * scale, 0.2 * scale, 4, float(battle.clock))
		_at(origin)



static func kill_area_visible(battle) -> bool:
	return battle != null and not dest_info_visible(battle)



func kill_area_lines(battle) -> Array:
	var tips: Dictionary = pack.tips if pack != null else {}
	var fits: int = maxi(1, int((KILL_AREA_SIZE.y - KILL_AREA_GUTTER * 2) / font.get_height(KILL_AREA_SIZE_TEXT)))
	var width: float = KILL_AREA_SIZE.x - KILL_AREA_GUTTER * 2
	var out: Array = [[]]
	for n in range(battle.kill_lines.size() - 1, -1, -1):
		if out.size() >= fits:
			break
		var segments: Array = battle.kill_segments(battle.kill_lines[n], tips)
		if segments.is_empty():
			continue
		var wrapped: Array = _kill_wrap(segments, width)
		wrapped.append_array(out)
		out = wrapped
	return out.slice(maxi(0, out.size() - fits))


func _kill_wrap(segments: Array, width: float) -> Array:
	var lines: Array = [[]]
	var used: float = 0.0
	if _kill_words == null:
		_kill_words = RegEx.create_from_string("\\n|[^\\s]+[ \\t]*|[ \\t]+")
	for part: Array in segments:
		var camp: int = int(part[1])
		for found: RegExMatch in _kill_words.search_all(str(part[0])):
			var word: String = found.get_string()
			if word == "\n":
				lines.append([])
				used = 0.0
				continue
			var w: float = font.get_string_size(word.strip_edges(false, true), HORIZONTAL_ALIGNMENT_LEFT, -1, KILL_AREA_SIZE_TEXT).x
			if used > 0.0 and used + w > width:
				lines.append([])
				used = 0.0
			while w > width and word.length() > 1:
				var cut: int = word.length() - 1
				while cut > 1 and font.get_string_size(word.left(cut), HORIZONTAL_ALIGNMENT_LEFT, -1, KILL_AREA_SIZE_TEXT).x > width:
					cut -= 1
				lines[-1].append([word.left(cut), camp])
				lines.append([])
				word = word.substr(cut)
				w = font.get_string_size(word.strip_edges(false, true), HORIZONTAL_ALIGNMENT_LEFT, -1, KILL_AREA_SIZE_TEXT).x
			lines[-1].append([word, camp])
			used += font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, KILL_AREA_SIZE_TEXT).x
	return lines

func _kill_area(battle) -> void :
	if battle.kill_lines.is_empty() or not kill_area_visible(battle):
		return
	var origin: Vector2 = Vector2(view.size.x - KILL_AREA_SIZE.x * scale - safe_in.z, KILL_AREA_Y * scale + safe_tr.y)
	_at(origin)
	var line_h: float = font.get_height(KILL_AREA_SIZE_TEXT)
	var ascent: float = font.get_ascent(KILL_AREA_SIZE_TEXT)
	var right: float = KILL_AREA_SIZE.x - KILL_AREA_GUTTER
	var lines: Array = kill_area_lines(battle)
	for row in range(lines.size()):
		var line: Array = lines[row]
		if line.is_empty():
			continue
		var total: float = 0.0
		for n in range(line.size()):
			var piece: String = str(line[n][0])
			total += font.get_string_size(piece.strip_edges(false, true) if n == line.size() - 1 else piece, 
				HORIZONTAL_ALIGNMENT_LEFT, -1, KILL_AREA_SIZE_TEXT).x
		var x: float = right - total
		var base_y: float = KILL_AREA_GUTTER + row * line_h + ascent
		for part: Array in line:
			var piece: String = str(part[0])
			var at: Vector2 = Vector2(x, base_y)
			view.draw_string_outline(font, at, piece, HORIZONTAL_ALIGNMENT_LEFT, -1, KILL_AREA_SIZE_TEXT, 3, DEST_GLOW)
			view.draw_string(font, at, piece, HORIZONTAL_ALIGNMENT_LEFT, -1, KILL_AREA_SIZE_TEXT, kill_color(battle, int(part[1])))
			x += font.get_string_size(piece, HORIZONTAL_ALIGNMENT_LEFT, -1, KILL_AREA_SIZE_TEXT).x










const HONOR_H: float = 85.0
const HONOR_TEXT: int = 26
const HONOR_TEXT_MIN: int = 10
const HONOR_PAD: float = 180.0
const HONOR_TEXT_Y: float = 25.5
const HONOR_AVATAR_ZOOM: float = 0.3
const HONOR_FRAME_W: float = 75.0
const HONOR_DEFAULT_LOOK: bool = false
const HONOR_TOUCH_K: float = 0.62
const HONOR_TOUCH_W: float = 0.46
const HONOR_TOUCH_Y: float = 80.0
const HONOR_NAME_MATE: Color = Color(73 / 255.0, 236 / 255.0, 1)
const HONOR_NAME_FOE: Color = Color(1, 121 / 255.0, 121 / 255.0)
var honor_drawn: Dictionary = {}

func _honor(battle) -> void :
	honor_drawn = {}
	if battle.honors.is_empty() or float(battle.honors[0].t) < 0:
		return
	var honor: Dictionary = battle.honors[0]
	var age: float = battle.clock - float(honor.t)
	var alpha: float = clampf(minf(age / 0.2, (2.5 - age) / 0.3), 0, 1)
	var base_scale: float = scale
	if touch:
		scale = base_scale * HONOR_TOUCH_K
	var who_name: String = str(honor.get("name", ""))
	var words: String = str(honor.get("text", ""))
	var limit: float = (view.size.x * HONOR_TOUCH_W if touch else view.size.x - 20.0) / scale
	var fs: int = HONOR_TEXT
	var name_w: float = 0.0
	var words_w: float = 0.0
	var width: float = 0.0
	while true:
		name_w = _text_width(who_name, fs) if not who_name.is_empty() else 0.0
		words_w = _text_width(words, fs)
		width = HONOR_PAD + floorf((name_w + words_w) * 1.1)
		if width <= limit or fs <= HONOR_TEXT_MIN:
			break
		fs -= 1
	width = minf(width, maxf(limit, HONOR_PAD))
	var origin: Vector2 = Vector2(view.size.x / 2 - width * scale / 2, (HONOR_TOUCH_Y if touch else 125.0) * base_scale + safe_in.y)
	_at(origin)
	var mate: bool = int(honor.get("camp", 0)) == battle.self_camp()
	var killer: Dictionary = _honor_who(battle, int(honor.get("killer_account", 0)))
	var victim: Dictionary = _honor_who(battle, int(honor.get("dead_account", 0)))
	var bg: Texture2D = tex("bg_honor")
	if bg != null:
		view.draw_texture_rect(bg, Rect2(1, 0, width - 2, HONOR_H), false, Color(1, 1, 1, alpha))
	if not killer.is_empty():
		_img("avatar_" + ("blue" if mate else "red"), Vector2(0, 0), alpha)
		_honor_avatar(battle, killer, origin, Vector2(8 + TankPortrait.BOX * HONOR_AVATAR_ZOOM / 2, HONOR_H / 2), alpha)
	if not victim.is_empty():
		_img("avatar_" + ("red" if mate else "blue"), Vector2(width - 15 - HONOR_FRAME_W, 0), alpha)
		_honor_avatar(battle, victim, origin, Vector2(width - 22 - TankPortrait.BOX * HONOR_AVATAR_ZOOM / 2, HONOR_H / 2), alpha)
	var text_x: float = (width - floorf((name_w + words_w) * 1.1)) / 2
	var text_y: float = HONOR_TEXT_Y + (HONOR_TEXT - fs) * 0.65
	if not who_name.is_empty():
		_text(Vector2(text_x, text_y), who_name, Color(HONOR_NAME_MATE if mate else HONOR_NAME_FOE, alpha), fs, HORIZONTAL_ALIGNMENT_LEFT, -1, true, 4)
	_text(Vector2(text_x + name_w * 1.1, text_y), words, Color(Color("ffd84a"), alpha), fs, HORIZONTAL_ALIGNMENT_LEFT, -1, true, 4)
	honor_drawn = {"rect": _screen(origin, Rect2(0, 0, width, HONOR_H)), "size": fs, "width": width, "scale": scale, 
		"killer": not killer.is_empty(), "victim": not victim.is_empty()}
	scale = base_scale



func _honor_who(battle, account: int) -> Dictionary:
	if account == 0:
		return {}
	var other: Variant = brief_of(battle, account).get("otherData")
	if not other is Dictionary:
		return {}
	var tank_id: int = int(other.get("tankId", 0))
	var worn: int = int(other.get("tankExternal", 0))
	if worn <= 0 and ( not HONOR_DEFAULT_LOOK or tank_id <= 0):
		return {}
	return {"tank": tank_id, "worn": worn, "level": maxi(1, int(other.get("tankLevel", 1)))}


func _honor_avatar(battle, who: Dictionary, origin: Vector2, center: Vector2, alpha: float) -> void :
	if pack == null or pack.state != "ready":
		return
	var tank_id: int = int(who.tank)
	var worn: int = int(who.worn)
	var look: Array = _avatar_look(tank_id, worn, int(who.level), 0)
	if _portrait(look[0], 0, center, HONOR_AVATAR_ZOOM, float(battle.clock), Color(1, 1, 1, alpha)):
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(worn), tank_id))
	if TankPreview.ready(art):
		TankPreview.draw(view, art, origin + center * scale, 0.35 * scale, 4, float(battle.clock))
		_at(origin)


const ENTER_LOOK: int = 2
const STATE_MAX: int = 6
const STATE_HOVER: Color = Color(1.25, 1.25, 1.25)
const STATE_TALK_LINE: float = 18.0
const STATE_TEXT: Color = Color("160000")



static func columns_of(battle) -> Dictionary:
	var out: Dictionary = {1: [], 2: []}
	if battle.mode == "happy":
		return out
	for tank: Dictionary in battle.tanks.values():
		var camp: int = int(tank.get("camp", 0))
		if out.has(camp) and out[camp].size() < STATE_MAX:
			out[camp].append(int(tank.id))
	return out


static func brief_of(battle, account: int) -> Dictionary:
	var roster: Array = battle.roster
	if not is_same(roster, _brief_src) or roster.size() != _brief_n:
		_brief_src = roster
		_brief_n = roster.size()
		_brief_at.clear()
		for i in range(roster.size()):
			var row: Variant = roster[i]
			if row is Dictionary and row.get("charData") is Dictionary:
				var acct: int = int(row.charData.get("nAcctId", 0))
				if not _brief_at.has(acct):
					_brief_at[acct] = i
	var at: int = int(_brief_at.get(account, -1))
	if at >= 0:
		var hit: Variant = roster[at]
		if hit is Dictionary and hit.get("charData") is Dictionary and int(hit.charData.get("nAcctId", 0)) == account:
			return hit
	for brief: Variant in roster:
		if brief is Dictionary and brief.get("charData") is Dictionary and int(brief.charData.get("nAcctId", 0)) == account:
			return brief
	return {}


static func state_cd_text(seconds: float) -> String:
	var ms: int = int(seconds * 1000.0)
	if ms <= 0:
		return ""
	return "%.1f" % (float(ms) / 1000.0) if ms < 10000 else str(int(round(float(ms) / 1000.0)))

func _state_sheet() -> Texture2D:
	if _state_tex == null:
		_state_tex = load(TankState.FILE) if ResourceLoader.exists(TankState.FILE) else false
	return _state_tex if _state_tex is Texture2D else null

func _state_img(key: String, pos: Vector2, k: float = 1.0, tint: Color = Color.WHITE, width: float = -1.0) -> void :
	var sheet: Texture2D = _state_sheet()
	if sheet == null:
		return
	var r: Array = TankState.R.get(key, [])
	if r.is_empty():
		return
	var w: float = float(r[2]) if width < 0 else width
	if w <= 0:
		return
	view.draw_texture_rect_region(sheet, Rect2(pos, Vector2(w, float(r[3])) * k), Rect2(r[0], r[1], w, r[3]), tint)


func _columns(battle) -> void :
	avatar_rects.clear()
	look_heads.clear()
	touch_round = {}
	voice_chips.clear()
	voice_chip_icons.clear()
	hover_tank = 0
	var lists: Dictionary = columns_of(battle)
	if lists[1].is_empty() and lists[2].is_empty():
		return
	var look: bool = int(battle.enter_type) == ENTER_LOOK
	var self_camp: int = 1 if look else int(battle.self_camp())
	if look:
		self_camp = int(battle.self_camp())
	var column: Dictionary = TankState.LAYOUT.column
	var top: float = float(column.top)
	var touch_left: float = 0.0
	var touch_top: Array = [0.0, 0.0]
	var touch_shift: float = 0.0
	if touch:
		var u: float = TouchLq.unit(view.size)
		var texture: Texture2D = view._textures.get("minimap")
		var base: float = layout_scale()
		var map_w: float = TouchLq.map_fit(texture.get_size()).x * TouchLq.TouchLayout.mm_scale() if texture != null and minimap_shown(battle) else 0.0
		var map_right: bool = TouchLq.TouchLayout.mm_right()
		touch_left = (TouchLq.MAP_AT + (0.0 if map_right else map_w)) * base + 4.0 * u + safe_tl.x
		touch_shift = (TouchLq.MAP_AT + map_w) * base + 4.0 * u if map_right and map_w > 0 else 0.0
		touch_shift += safe_in.z
		touch_top = [2.0 * u + safe_tl.y, TouchLq.SYS_H * base + safe_tr.y]
	if touch and TouchHeads.ON:
		touch_col_x = [touch_left, view.size.x - (float(TankState.LAYOUT.size[0]) + float(column.right_margin)) * scale - touch_shift]
		TouchHeads.draw(self, battle, lists, self_camp, look)
		return
	var mouse: Vector2 = view.get_local_mouse_position()
	var talks: Array = []
	var chips: Array = []
	for camp: int in [1, 2]:
		var right: bool = camp == 2
		var x: float = view.size.x - (float(TankState.LAYOUT.size[0]) + float(column.right_margin)) * scale if right else float(column.left[0]) * scale
		if touch and not right:
			x = touch_left
		elif touch:
			x -= touch_shift
		if touch:
			touch_col_x[1 if right else 0] = x
		for i in range(lists[camp].size()):
			var tank: Dictionary = battle.tanks[lists[camp][i]]
			var origin: Vector2 = Vector2(x, (top + i * float(column.step)) * scale)
			if touch:
				origin.y = float(touch_top[1 if right else 0]) + i * float(column.step) * scale
			var hit: Rect2 = _screen(origin, Rect2(3, 0, 54, 54))
			var hovered: bool = false
			if not look and not touch:
				avatar_rects[int(tank.id)] = hit
				hovered = hit.has_point(mouse)
				if hovered:
					hover_tank = int(tank.id)
			elif look or (battle.watch_shown and camp == self_camp):
				look_heads[int(tank.id)] = hit
				hovered = not touch and hit.has_point(mouse)
			if HudTiles.enabled:
				var cd_shown: bool = not look and camp == self_camp
				_h1.tile(self, battle, tank, brief_of(battle, int(tank.account)), right, self_camp != 0 and camp == self_camp, cd_shown, 
					state_cd_text(battle.camp_cd(int(tank.id))) if cd_shown else "", STATE_HOVER if hovered else Color.WHITE, 
					int(battle.room_type) in PVE_ROOMS, origin)
			else:
				_at(origin)
				_state_frame(battle, tank, right, self_camp != 0 and camp == self_camp, not look and camp == self_camp, hovered, origin)
			var bubble: Dictionary = battle.bubbles.get(int(tank.account), battle.bubbles.get(int(tank.id), {}))
			if not bubble.is_empty():
				talks.append([origin, right, bubble])
			if not look and int(tank.get("account", 0)) > 0 and int(tank.get("account", 0)) != int(battle.self_id):
				chips.append([origin, right, int(tank.account)])
	if HudTiles.enabled:
		_h1.flush(self)
	for talk: Array in talks:
		_at(talk[0])
		_state_talk(talk[2], talk[1])
	_voice_chips(chips, mouse)
	if look and not battle.look_free and look_heads.has(battle.look_target):
		view.draw_set_transform(Vector2.ZERO)
		view.draw_rect(look_heads[battle.look_target], LOOK_GOLD, false, 2.0 * scale)
	elif not look and battle.watch_shown and int(battle.scroll_id) != int(battle.self_id):
		var watched: Rect2 = avatar_rects.get(int(battle.scroll_id), look_heads.get(int(battle.scroll_id), Rect2()))
		if watched.has_area():
			view.draw_set_transform(Vector2.ZERO)
			view.draw_rect(watched, LOOK_GOLD, false, 2.0 * scale)


func _voice_chips(chips: Array, mouse: Vector2) -> void :
	if chips.is_empty() or not voice_ui or not VoiceClient.usable():
		return
	var voice: Object = VoiceClient.shared()
	view.draw_set_transform(Vector2.ZERO)
	var half: float = VOICE_CHIP_HIT_TOUCH * TouchLq.unit(view.size) if touch else VOICE_CHIP_HIT * scale
	var rad: float = VOICE_CHIP_R * scale
	var centers: Array = []
	for chip: Array in chips:
		centers.append((chip[0] as Vector2) + (VOICE_CHIP_RIGHT if chip[1] else VOICE_CHIP_LEFT) * scale)
	for chip: Array in chips:
		var account: int = chip[2]
		var muted: bool = voice.is_muted(account)
		if not muted and not voice.in_voice(account):
			continue
		var center: Vector2 = (chip[0] as Vector2) + (VOICE_CHIP_RIGHT if chip[1] else VOICE_CHIP_LEFT) * scale
		var icon: String = "spk_off" if muted else ("wave" if voice.is_talking(account) else "spk")
		VoiceUI.chip(view, center, rad, icon, VoiceUI.MUTE_FILL if muted else (VoiceUI.WAVE_FILL if icon == "wave" else Color(VoiceUI.WAVE_FILL, 0.55)), scale)
		voice_chip_icons[account] = icon
		var side: float = half
		if touch:
			for other: Vector2 in centers:
				if other != center:
					side = minf(side, maxf(absf(other.x - center.x), absf(other.y - center.y)) / 2.0)
		var hit: Rect2 = Rect2(center - Vector2(side, side), Vector2(side, side) * 2.0)
		if touch and center.distance_to(view._joystick_center()) < 105.0 + half:
			continue
		voice_chips[account] = hit
		if voice_menu == account or ( not touch and hit.has_point(mouse)):
			view.draw_circle(center, rad, Color(1, 1, 1, 0.18))


func _voice_menu_draw() -> void :
	voice_menu_box = Rect2()
	voice_menu_rows = {}
	if voice_menu == 0 or not voice_chips.has(voice_menu) or not VoiceClient.usable():
		return
	var chip: Rect2 = voice_chips[voice_menu]
	var muted: bool = VoiceClient.shared().is_muted(voice_menu)
	var rows: Array = [["mute", "spk" if muted else "spk_off", "Bật tiếng" if muted else "Tắt tiếng"]]
	var box: Vector2 = Vector2(128.0, 8.0 + rows.size() * 28.0) * scale
	var at: Vector2 = Vector2(chip.end.x + 2.0 * scale, chip.get_center().y - box.y * 0.5)
	if chip.get_center().x > view.size.x * 0.5:
		at.x = chip.position.x - 2.0 * scale - box.x
	at.x = clampf(at.x, 0.0, maxf(0.0, view.size.x - box.x))
	at.y = clampf(at.y, 0.0, maxf(0.0, view.size.y - box.y))
	var mouse: Vector2 = view.get_local_mouse_position()
	var hover: String = ""
	voice_menu_box = Rect2(at, box)
	if not touch and voice_menu_box.has_point(mouse):
		hover = "mute"
	voice_menu_rows = VoiceUI.small_menu(view, at, rows, bold, scale, hover)



func _voice_chip_click(point: Vector2, client) -> bool:
	if voice_menu != 0:
		var account: int = voice_menu
		if voice_menu_rows.has("mute") and (voice_menu_rows["mute"] as Rect2).has_point(point):
			voice_menu = 0
			if VoiceClient.usable():
				var voice: Object = VoiceClient.shared()
				voice.attach(client)
				voice.toggle_mute(account)
			return true
		if voice_menu_box.has_point(point):
			return true
		voice_menu = 0
		if voice_chips.has(account) and (voice_chips[account] as Rect2).has_point(point):
			return true
	for account: int in voice_chips:
		if (voice_chips[account] as Rect2).has_point(point):
			voice_menu = account
			return true
	return false

func _state_frame(battle, tank: Dictionary, right: bool, blue: bool, cd_shown: bool, hovered: bool, origin: Vector2) -> void :
	var layout: Dictionary = TankState.LAYOUT
	var side: Dictionary = layout.right if right else layout.left
	_state_img("tl_bg", Vector2(layout.bg[0], layout.bg[1]))
	var brief: Dictionary = brief_of(battle, int(tank.account))
	var other: Dictionary = brief.get("otherData") if brief.get("otherData") is Dictionary else {}
	if not brief.is_empty():
		_state_avatar(other, origin, STATE_HOVER if hovered else Color.WHITE, float(battle.clock))
		var frame_type: int = int(other.get("skinFrameType", 0))
		if frame_type in [1, 2]:
			_state_img("tl_frame_%d" % frame_type, Vector2(layout.frame[0], layout.frame[1]))
		var data: Dictionary = brief.charData
		var name_color: Color = Color("fff000") if int(data.get("nVipLevel", 0)) > 0 else Color.WHITE
		var full: String = str(data.get("szName", ""))
		var name: String = _fit(full, float(layout.name[2]) - 4.0, int(layout.name[3]))
		var base: Vector2 = Vector2(layout.name[0], float(layout.name[1]) + 2.0 + int(layout.name[3]))


		var styled: PackedColorArray = NameStyles.colors_of(view.client, int(tank.get("account", 0)), full)
		if styled.is_empty():
			view.draw_string_outline(bold, base, name, HORIZONTAL_ALIGNMENT_CENTER, float(layout.name[2]), int(layout.name[3]), 2, Color(0, 0, 0, 0.9))
			view.draw_string(bold, base, name, HORIZONTAL_ALIGNMENT_CENTER, float(layout.name[2]), int(layout.name[3]), name_color)
		else:
			var inks: PackedColorArray = NameStyles.tints(styled, full.length())
			if name != full:
				inks = inks.slice(0, maxi(1, name.length() - 3))
			NameStyles.draw_tinted(view, bold, int(layout.name[3]), base, name, inks, 2, Color(0, 0, 0, 0.9), "c", float(layout.name[2]), true)
	var max_hp: float = maxf(1.0, float(tank.get("max_hp", 1)))
	var fill: float = clampf(float(tank.get("hp", 0)) / max_hp, 0.0, 1.0)
	_state_img("tl_hp_blue" if blue else "tl_hp_red", Vector2(layout.hp[0], layout.hp[1]), 1.0, Color.WHITE, roundf(float(layout.hp[2]) * fill))
	if not brief.is_empty() and int(battle.room_type) in PVE_ROOMS:

		var key: String = "tl_rent" if int(other.get("tryTank", 0)) == 1 else "tl_star_%d" % mini(int(other.get("tankLevel", 0)), 6)
		if TankState.R.has(key):
			var k: float = float(layout.star_scale)
			var at: Vector2 = Vector2(float(side.get("star_right", 0)) - float(TankState.R[key][2]) * k, float(side.get("star_y", 0)))
			if not right:
				var spot: Array = side.star_blue if blue else side.star
				at = Vector2(spot[0], spot[1])
			_state_img(key, at, k)

	if cd_shown:
		_state_img("tl_cd_bg", Vector2(side.cd_bg[0], side.cd_bg[1]))
		var text: String = state_cd_text(battle.camp_cd(int(tank.id)))
		if text.is_empty():
			_state_img("tl_cd_ready", Vector2(side.cd_ready[0], side.cd_ready[1]))
		else:
			var label: Array = side.cd_label
			var at: Vector2 = Vector2(label[0], float(label[1]) + 2.0 + 14.0)
			view.draw_string_outline(font, at, text, HORIZONTAL_ALIGNMENT_CENTER, float(label[2]), 14, 3, Color("1a1a1a"))
			view.draw_string(font, at, text, HORIZONTAL_ALIGNMENT_CENTER, float(label[2]), 14, Color.WHITE)


func _fit(text: String, width: float, size: int) -> String:
	if width != floorf(width) or absf(width) > 65536.0:
		return _fit_raw(text, width, size)
	var slot: Vector2 = Vector2(width, size)
	var bucket: Variant = _fit_memo.get(slot)
	if bucket == null:
		if _fit_memo.size() >= 64:
			_fit_memo.clear()
		bucket = {}
		_fit_memo[slot] = bucket
	var hit: Variant = bucket.get(text)
	if hit == null:
		hit = _fit_raw(text, width, size)
		if bucket.size() >= 512:
			bucket.clear()
		bucket[text] = hit
	return hit

func _fit_raw(text: String, width: float, size: int) -> String:
	if bold.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= width:
		return text
	var cut: int = text.length()
	while cut > 1 and bold.get_string_size(text.left(cut) + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width:
		cut -= 1
	return text.left(cut) + "..."




func _state_avatar(other: Dictionary, origin: Vector2, tint: Color, clock: float) -> void :
	var tank_id: int = int(other.get("tankId", 0))
	if pack == null or pack.state != "ready" or tank_id <= 0:
		return
	var worn: int = int(other.get("tankExternal", 0))
	var level: int = maxi(1, int(other.get("tankLevel", 1)))
	var zoom: float = float(TankState.LAYOUT.avatar[2])
	var center: Vector2 = Vector2(TankState.LAYOUT.avatar[0], TankState.LAYOUT.avatar[1]) + Vector2.ONE * TankPortrait.BOX * 0.5 * zoom
	var look: Array = _avatar_look(tank_id, worn, level, int(other.get("haloId", 0)))
	if _portrait(look[0], look[1], center, zoom, clock, tint):
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(worn), tank_id))
	if TankPreview.ready(art):
		if _h1.sinking:
			_h1.live = true
			return
		TankPreview.draw(view, art, origin + center * scale, 0.3 * scale, 4, clock)
		_at(origin)


func _avatar_look(tank_id: int, worn: int, level: int, halo: int) -> Array:
	var bits: int = tank_id | worn | level | halo
	var key: Vector4i = Vector4i(tank_id, worn, level, halo) if bits >= 0 and bits <= 2147483647 else Vector4i(-1, -1, -1, -1)
	var hit: Variant = _face_memo.get(key) if key.x >= 0 else null
	if hit != null:
		return hit
	var ext: int = worn if worn > 0 else GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, level, {})
	var look: Array = [GarageModel.face(pack.garage, ext), TankPortrait.halo_item(pack.fx.get("halo_ui", {}), halo, level)]
	if key.x >= 0:
		if _face_memo.size() >= 256:
			_face_memo.clear()
		_face_memo[key] = look
	return look

func _ring_keys(item: int) -> Array:
	if item <= 0:
		return []
	var hit: Variant = _ring_memo.get(item)
	if hit == null:
		hit = pack.halo_ui(item)
		if _ring_memo.size() >= 256:
			_ring_memo.clear()
		_ring_memo[item] = hit
	return hit

func _film_of(face: String) -> Array:
	var hit: Variant = _film_memo.get(face)
	if hit == null:
		hit = [TankPortrait.movie(pack.garage, face), "l/t/%s.webp" % face, TankPortrait.side(pack.garage, face)]
		if _film_memo.size() >= 256:
			_film_memo.clear()
		_film_memo[face] = hit
	return hit


func _portrait(face: String, item: int, center: Vector2, zoom: float, time: float, tint: Color) -> bool:
	if face.is_empty():
		return false
	var box: Vector2 = Vector2.ONE * TankPortrait.BOX
	var origin: Vector2 = center - box * 0.5 * zoom
	var keys: Array = _ring_keys(item)
	var ring: float = zoom * (float(keys[2]) if keys.size() > 2 else 1.0)
	if keys.size() >= 2:
		_portrait_layer(pack.effect(str(keys[0])), origin + TankPortrait.BOTTOM * zoom, ring, time, tint)
	var shot: Array = _film_of(face)
	var film: Array = shot[0]
	var part: Dictionary = pack.effect_cached(str(film[0])) if not film.is_empty() else {}

	var fit: float = TankPortrait.fit(film)
	if not part.is_empty() and fit != 1.0:
		_portrait_layer(part, center - Vector2(float(film[1]), float(film[2])) * 0.5 * zoom * fit, zoom * fit, time, tint)
	elif not part.is_empty():
		_portrait_layer(part, origin + TankPortrait.movie_origin(film) * zoom, zoom, time, tint)
	else:
		var picture: Texture2D = pack.picture(shot[1])
		if picture != null:
			if _h1.sinking:
				_h1.sink.append([4, picture, TankPortrait.still_rect(film, origin, zoom, shot[2]), null, tint])
			else:
				view.draw_texture_rect(picture, TankPortrait.still_rect(film, origin, zoom, shot[2]), false, tint)
	if keys.size() >= 2:
		_portrait_layer(pack.effect(str(keys[1])), origin + TankPortrait.SURFACE * zoom, ring, time, tint)
	return true

func _portrait_layer(part: Dictionary, at: Vector2, zoom: float, time: float, tint: Color) -> void :
	if part.is_empty():
		return
	var frames: Array = part.data.frames
	var frame: Dictionary = frames[TankPortrait.frame_at(frames.size(), time)]
	var pivot: Vector2 = Vector2(float(frame.pivot[0]), float(frame.pivot[1]))
	var rect: Rect2 = Rect2(float(frame.rect[0]), float(frame.rect[1]), float(frame.rect[2]), float(frame.rect[3]))
	if rect.size.x > 0.0 and rect.size.y > 0.0:
		if _h1.sinking:
			_h1.sink.append([0, part.pages[int(frame.page)], Rect2(at - pivot * zoom, rect.size * zoom), rect, tint])
		else:
			view.draw_texture_rect_region(part.pages[int(frame.page)], Rect2(at - pivot * zoom, rect.size * zoom), rect, tint)


func _words() -> RegEx:
	if _words_re == null:
		_words_re = RegEx.create_from_string("\\S+|\\s")
	return _words_re

func _wrap_lines(text: String, width: float, size: int) -> Array[String]:
	if width != floorf(width) or absf(width) > 65536.0:
		return _wrap_raw(text, width, size)
	var slot: Vector2 = Vector2(width, size)
	var bucket: Variant = _wrap_memo.get(slot)
	if bucket == null:
		if _wrap_memo.size() >= 64:
			_wrap_memo.clear()
		bucket = {}
		_wrap_memo[slot] = bucket
	var hit: Variant = bucket.get(text)
	if hit == null:
		var lines: Array[String] = _wrap_raw(text, width, size)
		if bucket.size() >= 256:
			bucket.clear()
		bucket[text] = lines.duplicate()
		return lines
	var copy: Array[String] = hit.duplicate()
	return copy

func _wrap_raw(text: String, width: float, size: int) -> Array[String]:
	var lines: Array[String] = [""]
	for found: RegExMatch in _words().search_all(text):
		var word: String = found.get_string()
		var line: String = lines[-1] + word
		if bold.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= width or lines[-1].is_empty():
			lines[-1] = line
		elif not word.strip_edges().is_empty():
			lines.append(word)
		while bold.get_string_size(lines[-1], HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width and lines[-1].length() > 1:
			var long: String = lines[-1]
			var cut: int = long.length() - 1
			while cut > 1 and bold.get_string_size(long.left(cut), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width:
				cut -= 1
			lines[-1] = long.left(cut)
			lines.append(long.substr(cut))
	return lines




func _state_talk(bubble: Dictionary, right: bool) -> void :
	var side: Dictionary = TankState.LAYOUT.right if right else TankState.LAYOUT.left
	var tiles: String = "tl_talk_l" if right else "tl_talk_r"
	var chat: Vector2 = Vector2(side.chat[0], side.chat[1])
	var text_box: Array = side.text
	var lines: Array[String] = _wrap_lines(str(bubble.get("text", "")), float(text_box[2]), 14)

	var emo_rows: Array = EmoteTalk.rows(view.get("_emotes") if view != null else null, bubble, font, float(text_box[2]))
	var middle: float = maxf(0.0, (EmoteTalk.height(emo_rows) if not emo_rows.is_empty() else lines.size() * STATE_TALK_LINE) - 20.0)
	var alpha: float = float(TankState.LAYOUT.talk_alpha)
	var x: float = chat.x + float(side.talk_dx)
	var spots: Array = [[1, 0.0, 20.0], [2, 20.0, middle], [3, 20.0 + middle, 20.0]]
	var framed: bool = bubble.has("bg") and bubble.has("border")
	for spot: Array in spots:
		if float(spot[2]) <= 0:
			continue
		var key: String = tiles + str(spot[0])
		var dest: Rect2 = Rect2(Vector2(x, chat.y + float(spot[1])), Vector2(160, float(spot[2])))
		var tinted: Texture2D = _talk_tile(key, bubble) if framed else null
		if tinted != null:
			view.draw_texture_rect(tinted, dest, false, Color(1, 1, 1, alpha))
		elif _state_sheet() != null:
			var r: Array = TankState.R[key]
			var tint: Color = Color(bubble.bg, alpha) if framed else Color(1, 1, 1, alpha)
			view.draw_texture_rect_region(_state_sheet(), dest, Rect2(r[0], r[1], r[2], r[3]), tint)
	var fg: Color = bubble.get("fg", STATE_TEXT) if framed else STATE_TEXT
	var glow: Color = Color(bubble.bg, 0.8) if framed else Color(1, 1, 1, 0.8)
	if not emo_rows.is_empty():

		EmoteTalk.draw(view, view.get("_emotes"), emo_rows, chat + Vector2(float(text_box[0]) + 2.0, float(text_box[1]) + 2.0), font, fg)
		return
	for i in range(lines.size()):
		var base: Vector2 = chat + Vector2(float(text_box[0]) + 2.0, float(text_box[1]) + 2.0 + i * STATE_TALK_LINE + 14.0)
		view.draw_string_outline(bold, base, lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, 2, glow)
		view.draw_string(bold, base, lines[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 14, fg)



func _talk_tile(key: String, bubble: Dictionary) -> Texture2D:
	var bg: Color = bubble.bg
	var border: Color = bubble.border
	var id: String = "%s:%s:%s" % [key, bg.to_html(false), border.to_html(false)]
	if _talk_cache.has(id):
		return _talk_cache[id]
	if _talk_cache.size() > 96:
		_talk_cache.clear()
	var sheet: Texture2D = _state_sheet()
	if _talk_src == null and sheet != null:
		_talk_src = sheet.get_image()
		_talk_src = _talk_src if _talk_src is Image else false
	var image: Image = _talk_src if _talk_src is Image else null
	if image == null:
		_talk_cache[id] = null
		return null
	if image.is_compressed():
		image.decompress()
	var r: Array = TankState.R[key]
	var part: Image = image.get_region(Rect2i(r[0], r[1], r[2], r[3]))
	part.convert(Image.FORMAT_RGBA8)
	var scale_rgb: Vector3 = (Vector3(bg.r8, bg.g8, bg.b8) - Vector3(border.r8, border.g8, border.b8)) / (228.0 - 55.0)
	var base_rgb: Vector3 = Vector3(bg.r8, bg.g8, bg.b8) - scale_rgb * 228.0
	for y in range(part.get_height()):
		for x in range(part.get_width()):
			var c: Color = part.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			var luma: float = (0.299 * c.r + 0.587 * c.g + 0.114 * c.b) * 255.0
			var out: Vector3 = (scale_rgb * luma + base_rgb).clamp(Vector3.ZERO, Vector3.ONE * 255.0) / 255.0
			part.set_pixel(x, y, Color(out.x, out.y, out.z, c.a))
	var made: ImageTexture = ImageTexture.create_from_image(part)
	_talk_cache[id] = made
	return made





const TALK_PREWARM_MAX: int = 64
func talk_prewarm(packs: Array, usec: int) -> bool:
	var until: int = Time.get_ticks_usec() + usec
	for pack: Variant in packs:
		var frame: Variant = (pack as Dictionary).get("frame") if pack is Dictionary and str((pack as Dictionary).get("kind", "")) == "frame" else null
		if not (frame is Array and (frame as Array).size() == 3 and frame[0] is Color and frame[1] is Color):
			continue
		for n in range(6):
			if _talk_cache.size() >= TALK_PREWARM_MAX:
				return true
			var had: int = _talk_cache.size()
			_talk_tile(("tl_talk_l" if n < 3 else "tl_talk_r") + str(n % 3 + 1), {"bg": frame[0], "border": frame[1]})
			if _talk_cache.size() > had and Time.get_ticks_usec() >= until:
				return false
	return true







static func minimap_shown(battle) -> bool:
	return int(battle.enter_type) == ENTER_LOOK or not int(battle.map_id) in MinimapMarks.HIDE_MAPS


func touch_map_origin(map_size: Vector2) -> Vector2:
	var base: float = layout_scale()
	if TouchLq.TouchLayout.mm_right():
		return Vector2(view.size.x - (TouchLq.MAP_AT + map_size.x) * base - safe_in.z, (TouchLq.SYS_H + TouchLq.MAP_AT) * base + safe_tr.y)
	return Vector2(TouchLq.MAP_AT, TouchLq.MAP_AT) * base + safe_tl

func _minimap(battle) -> void :
	_map_adds.clear()
	map_marks.clear()
	if not minimap_shown(battle):
		return
	var look: bool = int(battle.enter_type) == ENTER_LOOK
	var texture: Texture2D = view._textures.get("minimap")
	var map_size: Vector2 = texture.get_size() if texture != null else Vector2(120, 90)
	if touch:
		map_size = TouchLq.map_fit(map_size) * TouchLq.TouchLayout.mm_scale()
	var origin: Vector2 = touch_map_origin(map_size) if touch else Vector2(0, view.size.y - (11 + map_size.y) * scale)
	_at(origin)
	var extent: Vector2 = battle.map.extent
	_map_scale = minf(map_size.x / maxf(1, extent.x), map_size.y / maxf(1, extent.y))
	_map_origin = origin
	_map_size = map_size
	if texture != null and touch:
		view.draw_texture_rect(texture, Rect2(Vector2.ZERO, map_size), false)
	elif texture != null:
		view.draw_texture(texture, Vector2.ZERO)
	else:
		view.draw_rect(Rect2(Vector2.ZERO, map_size), Color(0.05, 0.08, 0.12, 0.7))
	rects["map"] = _screen(origin, Rect2(Vector2.ZERO, map_size))
	var ready: bool = pack != null and pack.state == "ready"
	if ready and not (is_same(_warm_map[0], pack) and is_same(_warm_map[1], pack.index)):
		_warm_map = [pack, pack.index]
		for key: String in [MinimapMarks.ICONS, MinimapMarks.HOME.blue, MinimapMarks.HOME.red] + MinimapMarks.SIGNAL.values() + MinimapMarks.SIGNAL_ADD.values():
			pack.effect(key, true)
	var icons: Dictionary = pack.effect(MinimapMarks.ICONS) if ready else {}
	var camp: int = 1 if look else battle.self_camp()
	if look:
		camp = int(battle.self_camp())

	var statics: bool = int(battle.map.document.get("header", {}).get("gameMode", 0)) not in [4, 5]
	var beach: bool = statics and not battle.map.flags.is_empty()
	var npc_list: Array = battle.npcs.values()
	for i in range(npc_list.size() - 1, -1, -1):
		var npc: Dictionary = npc_list[i]
		var kind: int = int(npc.id) >> 26
		if kind == 5 and ready:
			_map_ainpc(npc, camp, icons, battle)
		elif kind == 3 and statics and not beach and ready:
			_map_static(battle, npc, camp, icons)
	_at(origin)

	var ratio: Vector2 = map_size / Vector2(maxf(1, extent.x), maxf(1, extent.y))
	var scroll: Vector2 = view.size / view._zoom
	var btn: Rect2 = Rect2((view._camera - scroll / 2) * ratio, Vector2(int(scroll.x * ratio.x), int(scroll.y * ratio.y))).intersection(Rect2(Vector2.ZERO, map_size))
	if not (touch and view.get("_tcam") != null and not view._tcam.frame_shown()):
		view.draw_rect(btn, MinimapMarks.BTN_GLOW, false, 3)
		view.draw_rect(btn, MinimapMarks.BTN_COLOR, false, 1)
	if beach and ready:
		_map_beachheads(battle, camp, icons)
	_at(origin)
	var self_tank: Dictionary = {}
	micro_marks.clear()
	for tank: Dictionary in battle.tanks.values():

		if tank.dead or tank.get("hidden", false):
			continue
		if int(tank.id) == battle.self_id:
			self_tank = tank
			continue
		var friendly: bool = battle.mode != "happy" and int(tank.camp) == battle.self_camp()
		_micro("micro_blue" if friendly else "micro_red", tank.pos * _map_scale, micro_head(battle, tank))
	if not self_tank.is_empty():
		_micro("micro_green", self_tank.pos * _map_scale, micro_head(battle, self_tank))
	if ready:

		for mark: Dictionary in battle.signals:
			_map_signal(int(mark.type), mark.pos * _map_scale, float(mark.age))
		if statics and not beach:
			for harm: Dictionary in battle.harms:
				var spot: Vector2 = harm.pos * _map_scale
				_map_signal(4, spot - MinimapMarks.HOME_HALF if int(harm.kind) == 3 else spot.floor(), float(harm.age))
	_at(origin)
	for i in range(3):
		var cell: Rect2 = Rect2(map_size.x + 2, map_size.y - [68, 34, 0][i] - 32, 32, 32)
		if touch:

			cell = Rect2(i * (TouchLq.SIG_CELL + TouchLq.SIG_GAP), map_size.y + TouchLq.SIG_GAP, TouchLq.SIG_CELL, TouchLq.SIG_CELL)
			var sig: Texture2D = tex(SIGNAL_TEX[i])
			if sig != null:
				view.draw_texture_rect(sig, cell, false)
		else:
			_img(SIGNAL_TEX[i], cell.position)
			_key_mark([90, 88, 67][i], cell.position + Vector2(32 - 2, 2), true)
		var left: float = signal_ready - battle.clock
		if left > 0:
			_clock(cell, left / SIGNAL_CD, true)
		if armed == i + 1:
			view.draw_rect(cell.grow(1), Color("ffe14a"), false, 2)
		rects[SIG_RECTS[i]] = _screen(origin, cell.grow_individual(TouchLq.SIG_GAP / 2.0, 0, TouchLq.SIG_GAP / 2.0, 3) if touch else cell)



func _key_mark(action: int, pos: Vector2, right: bool = false) -> void :
	var code: int = int(view.client.key_map.get(action, action)) if view.client != null else action
	var image: String = "key_space" if code == 32 else ("key_" + char(code + 32) if code >= 65 and code <= 90 else "")
	var texture: Texture2D = tex(image) if not image.is_empty() else null
	if texture != null:
		view.draw_texture(texture, pos - Vector2(texture.get_width() if right else 0, 0))
		return
	var label: String = BattleSettings.key_name(code)
	var width: float = _text_width(label, 10)
	_text(pos - Vector2(width if right else 0, 1), label, Color("ff6a5a") if code == 0 else Color.WHITE, 10, HORIZONTAL_ALIGNMENT_LEFT, -1, true, 2)




var micro_marks: Array = []

func _micro(name: String, center: Vector2, head: Rect2 = Rect2()) -> void :
	var texture: Texture2D = tex(name)
	var at: Vector2 = (center - texture.get_size() * 0.5).round() if texture != null else center
	if texture != null:
		view.draw_texture(texture, at)
	var sheet: Texture2D = tex(MicroHeads.SHEET) if head.size.x > 0 else null
	var head_at: Vector2 = (center - head.size * 0.5).round()
	if sheet != null:
		view.draw_texture_rect_region(sheet, Rect2(head_at, head.size), head)
	micro_marks.append([name, at, head if sheet != null else Rect2(), head_at])



static func micro_head(battle, tank: Dictionary) -> Rect2:
	if happy_champion(battle, int(tank.id)):
		return MicroHeads.CHAMPION
	var other: Variant = brief_of(battle, int(tank.get("account", 0))).get("otherData")
	if not other is Dictionary:
		return Rect2()
	return MicroHeads.HEAD.get(int(other.get("tankId", 0)), Rect2())


func _map_cell(part: Dictionary, index: int, at: Vector2, alpha: float = 1.0) -> void :
	if part.is_empty():
		return
	view.draw_set_transform(_map_origin + at * scale, 0, Vector2(scale, scale))
	_fx_cell(view, part, index, Color(1, 1, 1, alpha))

func _map_icon(icons: Dictionary, name: String, at: Vector2) -> void :
	map_marks.append(name)
	_map_cell(icons, int(MinimapMarks.ICON[name]), at)



func _map_static(battle, npc: Dictionary, camp: int, icons: Dictionary) -> void :
	var kind: String = str(battle.map.templates.get(str(int(npc.template)), {}).get("iType", ""))
	var spot: Vector2 = npc.pos * _map_scale
	if kind == "3":
		var side: String = "blue" if int(npc.camp) == camp else "red"
		map_marks.append("home_%s:%d" % [side, home_frame(npc)])
		_map_cell(pack.effect(MinimapMarks.HOME[side]), home_frame(npc), spot - MinimapMarks.HOME_HALF)
	elif kind == "4":
		_map_icon(icons, "cannon_blue" if int(npc.camp) == camp else "cannon_red", spot.floor() - Vector2.ONE * MinimapMarks.CANNON_HALF)


static func home_frame(npc: Dictionary) -> int:
	if npc.get("hp_mark", false) and int(npc.max_hp) > 0:
		return clampi(int(100.0 * int(npc.hp) / int(npc.max_hp)), 1, MinimapMarks.HOME_FRAMES) - 1
	return MinimapMarks.HOME_FRAMES - 1




func _map_ainpc(npc: Dictionary, camp: int, icons: Dictionary, battle = null) -> void :
	if npc.dead or npc.get("hidden", false) or int(npc.max_hp) == -1 or int(npc.max_hp) == 4294967295:
		return
	var template: int = int(npc.template)
	var life: int = ainpc_life(pack.ainpc_row(template), template)
	if life < 0 or life == 1:
		return
	var name: String = "computer_yellow" if int(npc.camp) == 0 else ("computer_blue" if int(npc.camp) == camp else "computer_red")
	if battle != null and happy_champion(battle, int(npc.id)):
		_map_champion((npc.pos * _map_scale).floor())
		return
	if battle != null and happy_champion(battle, 0, int(npc.id)):
		name = "computer_red"
	_map_icon(icons, name, (npc.pos * _map_scale).floor() - Vector2.ONE * MinimapMarks.AINPC_HALF)



static func happy_champion(battle, id: int, lost: int = 0) -> bool:
	if battle.mode != "happy" or int(battle.enter_type) == ENTER_LOOK:
		return false
	var first: int = battle.happy_leader()
	if lost != 0:
		return lost != first and battle.happy_dethroned.has(lost)
	return id != 0 and first == id


func _map_champion(center: Vector2) -> void :
	var sheet: Texture2D = tex(MicroHeads.SHEET)
	if sheet == null:
		return
	map_marks.append("happy_first_grid")
	_at(_map_origin)
	view.draw_texture_rect_region(sheet, Rect2((center - MicroHeads.CHAMPION.size * 0.5).round(), MicroHeads.CHAMPION.size), MicroHeads.CHAMPION)


static func ainpc_life(row: Array, template: int) -> int:
	if row.size() > 3:
		return int(row[3])
	if MinimapMarks.in_ranges(MinimapMarks.AINPC_KNOWN, template):
		return 1 if MinimapMarks.in_ranges(MinimapMarks.AINPC_HIDE, template) else 0
	return -1



func _map_beachheads(battle, camp: int, icons: Dictionary) -> void :
	var points: Dictionary = {}
	for flag: Dictionary in battle.map.flags:
		points[int(flag.iIndex)] = Vector2(float(flag.iCenterX), float(flag.iCenterY))
	for index: int in battle.occupy:
		if not points.has(index):
			continue
		var row: Dictionary = battle.occupy[index]
		var at: Vector2 = points[index] * _map_scale - Vector2.ONE * MinimapMarks.FLAG_HALF
		var owner: int = int(row.camp)
		_map_icon(icons, "small_flag2" if owner == camp else ("small_flag1" if owner in [1, 2] else "small_flag0"), at)
		if int(row.lock) == 1:
			_map_icon(icons, "small_flag_lock", at)


func _map_signal(type: int, at: Vector2, age: float) -> void :
	if not MinimapMarks.SIGNAL.has(type):
		return
	var delay: float = float(MinimapMarks.SIGNAL_DELAY[type])
	var alpha: float = 1.0
	if age > delay:
		var k: float = clampf((age - delay) / MinimapMarks.SIGNAL_FADE, 0.0, 1.0)
		alpha = (1.0 - k) * (1.0 - k)
	if alpha <= 0.0:
		return
	var frame: int = int(age * MinimapMarks.FPS) % (MinimapMarks.SIGNAL_FRAMES - 1)
	_map_cell(pack.effect(MinimapMarks.SIGNAL[type]), frame, at, alpha)
	var add: Dictionary = pack.effect(MinimapMarks.SIGNAL_ADD[type])
	if not add.is_empty():
		_map_adds.append([add, Transform2D(0, Vector2(scale, scale), 0, _map_origin + at * scale), frame, alpha])


func map_adds() -> int:
	return _map_adds.size()



func map_move(point: Vector2) -> void :
	if not rects.has("map") or _map_scale <= 0 or view._zoom <= 0:
		return
	if not rects.map.has_point(point):
		map_release()
		return
	var local: Vector2 = (point - _map_origin) / scale
	var scroll: Vector2 = view.size / view._zoom
	var extent: Vector2 = view.client.battle.map.extent if view.client != null else scroll
	var btn: Vector2 = Vector2(int(scroll.x * _map_size.x / maxf(1, extent.x)), int(scroll.y * _map_size.y / maxf(1, extent.y)))
	var begin: Vector2 = Vector2(int((local.x - btn.x / 2) / _map_scale), int((local.y - btn.y / 2) / _map_scale))
	_map_center = begin + scroll / 2
	_map_drag = true
	_map_hold = true
	_hold_fresh = true


func map_release() -> void :
	_map_drag = false

func map_dragging() -> bool:
	return _map_drag


func look_center(follow: Vector2, battle) -> Vector2:
	var stamp: Array = [int(battle.begun), int(battle.self_spawns)]
	if stamp != _hold_battle:
		_hold_battle = stamp
		_map_drag = false
		_map_hold = false
		_hold_fresh = false
	if _map_drag or (_map_hold and _hold_fresh):
		_hold_fresh = false
		_hold_follow = follow
		return _map_center
	if _map_hold and follow == _hold_follow:
		return _map_center
	_map_hold = false
	return follow


func minimap_to_world(point: Vector2) -> Vector2:
	if not rects.has("map") or not rects.map.has_point(point) or _map_scale <= 0:
		return Vector2(-1, -1)
	return (point - _map_origin) / scale / _map_scale


func _bottom(battle) -> void :
	var origin: Vector2 = _bottom_origin()
	_at(origin)
	var tank: Dictionary = battle.tanks.get(battle.self_id, {})
	if tank.is_empty():
		return
	var level: int = int(tank.get("level", 0))
	var level_mode: int = int(pack.hud.get("levels", {}).get(str(battle.map_id), 0)) if pack != null else 0
	if level_mode > 0 and level > 0:
		var table: Dictionary = pack.hud.get("exp", {}).get(str(level_mode), {})
		var need: int = int(table.get(str(level), 0))
		_img("exp_bg", Vector2(145, 0))
		_bar("exp_bar", Vector2(164, 6), Vector2(221, 7), float(battle.battle_exp) / need if need > 0 else 1.0)
		_text(Vector2(143, 2), str(level), Color.WHITE, 12, HORIZONTAL_ALIGNMENT_CENTER, 24, true, 2)
		_text(Vector2(164, 3), ("%d/%d" % [battle.battle_exp, need]) if need > 0 else "MAX", Color.WHITE, 10, HORIZONTAL_ALIGNMENT_CENTER, 224, true, 2)
	if touch:
		_touch_cells(battle)
		return

	var info: Vector2 = Vector2(7, 10)
	_img("life", info + Vector2(45, 2))
	_infinity(info + Vector2(45 + 79, 14), 9)
	_img("word_hp", info + Vector2(2, 29))
	view.draw_rect(Rect2(info + Vector2(31, 29), Vector2(102, 14)), Color(0, 0, 0, 0.65))
	_bar("play_bar_l", info + Vector2(32, 30), Vector2(100, 12), float(maxi(0, tank.hp)) / maxi(1, tank.max_hp))
	_bar_text(info + Vector2(31, 28), "%d/%d" % [maxi(0, tank.hp), tank.max_hp])

	var uses_mp: bool = Mp.uses(tank)
	if uses_mp:
		_img("word_mp", info + Vector2(0, 48))
		view.draw_rect(Rect2(info + Vector2(31, 48), Vector2(102, 14)), Color(0, 0, 0, 0.65))
		_bar("mp_bar", info + Vector2(32, 49), Vector2(100, 12), float(tank.mp) / maxi(1, tank.max_mp))
		_bar_text(info + Vector2(31, 47), "%d/%d" % [tank.mp, tank.max_mp])

	if pack != null and pack.state == "ready" and not (is_same(_warm_cell[0], pack) and is_same(_warm_cell[1], pack.index)):
		_warm_cell = [pack, pack.index]
		for key: String in [SkillCell.DONE, SkillCell.SELECT, SkillCell.BAN]:
			pack.effect(key, true)
	var has_r: bool = battle.skills.has(10)
	var slots: Array[int] = [10 if has_r else 3, 1, 2, 13 if battle.skills.has(13) else 4]
	for i in range(4):
		_cell(battle, tank, slots[i], Rect2(CELL_X[i], 20, 50, 50), origin)
		if i > 0 or has_r:
			_key_mark([82, 69, 32, 81][i], Vector2(KEY_X[i], 23))
	if battle.skills.has(12):
		_cell(battle, tank, 12, Rect2(394, 30, 40, 40), origin)
		_key_mark(66, Vector2(420, 32))

	if view.controls.auto_fire:

		var label: Vector2 = Vector2(_text_width("TỰ BẮN", 11) + 6, 14)
		var at: Vector2 = info + Vector2( - label.x, 29)
		if rects.has("map") and _screen(origin, Rect2(at, label)).position.x < rects.map.end.x + 34 * scale:
			at = info + Vector2(-4, 13)
		view.draw_rect(Rect2(at, label), Color(0, 0, 0, 0.65))
		_text(at + Vector2(3, -1), "TỰ BẮN", Color(1.0, 0.62, 0.16), 11, HORIZONTAL_ALIGNMENT_LEFT, -1, true, 2)




func _touch_cells(battle) -> void :
	view.draw_set_transform(Vector2.ZERO)
	var u: float = TouchLq.unit(view.size)
	var slots: Array[int] = [10 if battle.skills.has(10) else 3, 1, 2, 13 if battle.skills.has(13) else 4, 12]
	for ordinal in range(5):
		if ordinal == 4 and not battle.skills.has(12):
			continue
		var b: Array = TouchLq.button(view.size, ordinal)
		_round_cell(battle, slots[ordinal], b[0], float(b[1]) * TouchLq.CELL_K, u, TouchLq.TouchLayout.alpha() * _cover())
	_at(_bottom_origin())


func _cover() -> float:
	var lq: Variant = view.get("_lq")
	return float(lq.cover) if lq != null else 1.0




var _crisp: Dictionary = {}



static func touch_icon(pack, key: String) -> Texture2D:
	if pack == null or key.is_empty():
		return null
	var big: Texture2D = pack.icon("s4", key)
	return big if big != null else pack.icon("s", key)

func _crisp_icon(key: String, icon: Texture2D, r: float) -> Texture2D:
	var k_px: float = view.get_global_transform_with_canvas().get_scale().x * view.get_viewport().get_final_transform().get_scale().x
	var px: int = clampi(ceili(r * 2.0 * k_px / 8.0) * 8, 16, 512)
	var crop: int = int(icon.get_width() * 0.76)
	if px <= crop + 8 and px * 4 >= crop * 3:
		return icon
	var k: String = "%s:%d:%d" % [key, px, icon.get_instance_id()]
	if _crisp.has(k):
		return _crisp[k]
	var img: Image = icon.get_image()
	var out: Texture2D = icon
	if img != null and not img.is_empty():
		img = img.duplicate()
		if img.is_compressed():
			img.decompress()
		img.convert(Image.FORMAT_RGBA8)
		var side: int = maxi(1, roundi(minf(img.get_width(), img.get_height()) * 0.76))
		img = img.get_region(Rect2i((img.get_width() - side) / 2, (img.get_height() - side) / 2, side, side))
		img.resize(px, px, Image.INTERPOLATE_LANCZOS)
		out = ImageTexture.create_from_image(img)
	if _crisp.size() > 48:
		_crisp.clear()
	_crisp[k] = out
	return out






const RING_TEX: String = "res://assets/ui/mobile/skill_ring_256.png"
const BURST_TEX: String = "res://assets/ui/mobile/skill_burst_256.png"
const RING_AT: float = 1.09
const RING_FILL: float = 0.82
const RING_SPIN: float = 0.5
const RING_GOLD: Color = Color(1.0, 0.8, 0.28)
const BURST_TIME: float = 14.0 / 24.0
const CD_SHADE: float = 0.38
const CD_FONT: float = 26.0
const CD_TEXT_MIN: float = 0.85
var _ui_texs: Dictionary = {}

func ui_tex(path: String) -> Texture2D:
	if not _ui_texs.has(path):
		_ui_texs[path] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _ui_texs[path]



static func glow(r: float, since: float, now: float) -> Array:
	var k: float = clampf(since / BURST_TIME, 0, 1)
	var burst_a: float = 1.0 - k * k if since >= 0 and since < BURST_TIME else 0.0
	var ring_a: float = clampf((k - 0.4) / 0.6, 0, 1) * (0.82 + 0.18 * sin(now * 3.0))
	return [r * RING_AT * lerpf(0.7, 1.35, k), burst_a, r * RING_AT / RING_FILL, ring_a, fmod(now * RING_SPIN, TAU)]


func _ready_glow(c: Vector2, r: float, u: float, fa: float, since: float) -> void :
	var g: Array = glow(r, since, view._time)
	if float(g[1]) > 0.01:
		var burst: Texture2D = ui_tex(BURST_TEX)
		if burst != null:
			var bh: float = g[0]
			view.draw_texture_rect(burst, Rect2(c - Vector2(bh, bh), Vector2(bh, bh) * 2), false, Color(1, 1, 1, float(g[1]) * fa))
		else:
			view.draw_arc(c, r + 2 * u, 0, TAU, 40, Color(1, 1, 1, 0.9 * fa * (1.0 - since / BURST_TIME)), 4.0 * u, true)
	var a: float = float(g[3]) * fa
	if a <= 0.01:
		return
	var ring: Texture2D = ui_tex(RING_TEX)
	if ring != null:
		var half: float = g[2]
		view.draw_set_transform(c, g[4], Vector2.ONE)
		view.draw_texture_rect(ring, Rect2( - half, - half, half * 2, half * 2), false, Color(1, 1, 1, a))
		view.draw_set_transform(Vector2.ZERO)
	else:
		view.draw_arc(c, r * RING_AT, 0, TAU, 48, Color(RING_GOLD, 0.35 * a), 7.0 * u, true)
		view.draw_arc(c, r * RING_AT, 0, TAU, 48, Color(RING_GOLD, 0.9 * a), 2.5 * u, true)

static func circle_points(c: Vector2, r: float, n: int = 32) -> PackedVector2Array:
	var out: PackedVector2Array = []
	for i in range(n):
		out.append(c + Vector2.from_angle(TAU * i / n) * r)
	return out


func _round_cell(battle, slot: int, c: Vector2, r: float, u: float, fa: float = 1.0) -> void :
	var real: Variant = battle.skills.get(slot)
	view.draw_circle(c, r, Color(0.04, 0.06, 0.1, 0.75 * fa))
	if real == null and slot not in CORPS_SLOTS:
		return
	var cell: Dictionary = cell_state(battle, slot)
	var prop: Dictionary = cell.prop
	var info: Array = pack.skill_hud(int(prop.nPropsId)) if pack != null else []
	var icon: Texture2D = touch_icon(pack, str(info[0])) if info.size() > 0 else null
	if icon != null:
		var sharp: Texture2D = _crisp_icon(str(info[0]), icon, r)
		var pts: PackedVector2Array = circle_points(c, r)
		var uvs: PackedVector2Array = circle_points(Vector2(0.5, 0.5), 0.5 if sharp != icon else 0.38)
		view.draw_colored_polygon(pts, Color(1, 1, 1, fa), uvs, sharp)
	if cell.mp and int(cell.need) > 0:
		view.draw_circle(c, r, Color(0.08, 0.2, 0.65, 0.45 * fa))
	var left: float = float(cell.left)
	if cell.cd and left > 0:
		var total: float = float(info[2] if int(prop.get("iCount", -1)) > 0 and info.size() > 2 else (info[1] if info.size() > 1 else 0)) / 1000.0
		var pct: float = clampf(left / total if total > 0 else 1.0, 0, 1)
		if pct > 0.001:
			var pie: PackedVector2Array = [c]
			var steps: int = maxi(2, ceili(pct * 48))
			var start: float = - PI / 2 + (1 - pct) * TAU
			for i in range(steps + 1):
				pie.append(c + Vector2.from_angle(lerpf(start, 1.5 * PI, float(i) / steps)) * r)
			view.draw_colored_polygon(pie, Color(0, 0, 0, CD_SHADE * fa))
		var label: String = ("%.1f" % left) if left < 10 else str(int(left))
		var fs: int = maxi(14, roundi(CD_FONT * u))
		var ta: float = maxf(fa, minf(CD_TEXT_MIN, TouchLq.TouchLayout.alpha()))
		_text(c - Vector2(r, fs * 0.66), label, Color(1, 1, 1, ta), fs, HORIZONTAL_ALIGNMENT_CENTER, r * 2, true, 5)
	if cell.bans:
		view.draw_circle(c, r, Color(0, 0, 0, 0.5 * fa))
		view.draw_arc(c, r * 0.62, 0, TAU, 32, Color(0.95, 0.2, 0.15, 0.95 * fa), 3.0 * u, true)
		view.draw_line(c + Vector2(-0.44, -0.44) * r, c + Vector2(0.44, 0.44) * r, Color(0.95, 0.2, 0.15, 0.95 * fa), 3.0 * u, true)
	if cell.locks:
		var lock: Texture2D = tex("locked")
		if lock != null:
			var sz: Vector2 = Vector2(29, 38) * (r / 30.0)
			view.draw_texture_rect(lock, Rect2(c - sz / 2, sz), false, Color(1, 1, 1, fa))
	if cell.over:
		_ready_glow(c, r, u, fa, battle.clock - float(cell.t0))
	if cell.selv and view.controls.selected == slot:
		view.draw_arc(c, r + 1 * u, 0, TAU, 40, Color(1.0, 0.88, 0.3, (0.65 + 0.35 * sin(view._time * 8.0)) * fa), 3.0 * u, true)
	if real != null and slot not in CORPS_SLOTS and slot != 12:
		_round_stack(battle, prop, info, c, r, fa)




const STACK_AT: float = 0.56
const STACK_R: float = 0.3
const STACK_FONT: float = 0.44
const STACK_FONT_MIN: int = 12
static func stack_badge(c: Vector2, r: float) -> Array:
	return [c + Vector2(STACK_AT, STACK_AT) * r, STACK_R * r, maxi(STACK_FONT_MIN, roundi(STACK_FONT * r))]



func _round_stack(battle, prop: Dictionary, info: Array, c: Vector2, r: float, fa: float) -> void :
	var count: int = int(prop.get("iCount", -1))
	if count <= 0:
		return
	var badge: Array = stack_badge(c, r)
	var at: Vector2 = badge[0]
	var rad: float = float(badge[1])
	var fs: int = int(badge[2])
	var ta: float = maxf(fa, minf(CD_TEXT_MIN, TouchLq.TouchLayout.alpha()))
	var top: int = int(info[4]) if info.size() > 4 else 0
	var total: float = float(info[1]) if info.size() > 1 else 0.0
	if count < top and total > 0:
		var left: float = clampf((battle._stamp(prop.get("nCountCoolTime")) - battle.now_ms()) / total, 0.0, 1.0)
		if left > 0:
			var from: float = - PI / 2 + TAU * (1.0 - left)
			view.draw_arc(at, rad, from, - PI / 2 + TAU, 48, Color(0, 0, 0, 0.8 * ta), r * 0.16, true)
			view.draw_arc(at, rad, from, - PI / 2 + TAU, 48, Color(1, 1, 1, ta), r * 0.08, true)
	_text(at - Vector2(r, fs * 0.66), "x%d" % count, Color(1, 1, 1, ta), fs, HORIZONTAL_ALIGNMENT_CENTER, r * 2, true, 4)

func _infinity(center: Vector2, a: float) -> void :
	var key: Vector3 = Vector3(center.x, center.y, a)
	if key != _inf_key or a != float(key.z):
		_inf_key = key if a == float(key.z) else Vector3(-1000000000.0, -1000000000.0, -1000000000.0)
		var points: PackedVector2Array = []
		for i in range(41):
			var t: float = TAU * i / 40.0
			var d: float = 1 + sin(t) * sin(t)
			points.append(center + Vector2(a * cos(t) / d, a * sin(t) * cos(t) / d * 1.3))
		_inf_points = points
		_inf_mesh = []
	if HudTiles.enabled:
		if _inf_mesh.is_empty():
			_inf_mesh = HudTiles.infinity(_inf_points)
			if _inf_mesh.is_empty():
				_inf_mesh = [false]
		if _inf_mesh.size() == 3:
			RenderingServer.canvas_item_add_triangle_array(view.get_canvas_item(), _inf_mesh[0], _inf_mesh[1], _inf_mesh[2])
			_h1.inf_hits += 1
			return
	view.draw_polyline(_inf_points, Color(0, 0, 0, 0.9), 5, true)
	view.draw_polyline(_inf_points, Color.WHITE, 2.4, true)



func _cell(battle, _tank: Dictionary, slot: int, rect: Rect2, origin: Vector2) -> void :
	var real: Variant = battle.skills.get(slot)
	view.draw_rect(rect, Color(0.04, 0.06, 0.1, 0.75))
	var k: float = rect.size.x / 50.0
	var frame: Texture2D = tex("skill_bar_2")
	if real == null and slot not in CORPS_SLOTS:

		if frame != null:
			view.draw_texture_rect(frame, Rect2(rect.position - Vector2(6, 6) * k, Vector2(62, 62) * k), false)
		return
	var cell: Dictionary = cell_state(battle, slot)
	var prop: Dictionary = cell.prop
	var info: Array = pack.skill_hud(int(prop.nPropsId)) if pack != null else []
	if real != null and (info.is_empty() or str(info[0]).is_empty()) and not _reported.has(int(prop.nPropsId)):
		_reported[int(prop.nPropsId)] = true
		print("HUD: chiêu %d (ô %d) chưa có icon trong a/i" % [int(prop.nPropsId), slot])
	var icon: Texture2D = pack.icon("s", str(info[0])) if info.size() > 0 and pack != null else null
	if icon != null:
		view.draw_texture_rect(icon, rect, false)
	if cell.mp and int(cell.need) > 0:
		var lack: Texture2D = tex("skill_mp_lack")
		if lack != null:
			view.draw_texture_rect(lack, rect, false)
	var left: float = float(cell.left)
	if cell.cd and left > 0:
		var total: float = float(info[2] if int(prop.get("iCount", -1)) > 0 and info.size() > 2 else (info[1] if info.size() > 1 else 0)) / 1000.0
		_clock(rect, left / total if total > 0 else 1.0)
		var label: String = ("%.1f" % left) if left < 10 else str(int(left))
		_text(rect.position + Vector2(0, rect.size.y * 0.28), label, Color.WHITE, 14, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, true, 3)
	if cell.bans:
		view.draw_rect(Rect2(rect.position, Vector2(SkillCell.BAN_FILL[1], SkillCell.BAN_FILL[1]) * k), Color(0, 0, 0, float(SkillCell.BAN_FILL[0])))
		var ban: Dictionary = pack.effect(SkillCell.BAN) if pack != null else {}
		if not ban.is_empty():
			_cell_fx(ban, rect, origin, Vector2.ZERO, 0)
	if cell.locks:
		var lock: Texture2D = tex("locked")
		if lock != null:
			view.draw_texture_rect(lock, Rect2(rect.position + Vector2(SkillCell.LOCK_AT[0], SkillCell.LOCK_AT[1]) * k, Vector2(29, 38) * k), false)
	if frame != null:
		view.draw_texture_rect(frame, Rect2(rect.position - Vector2(6, 6) * k, Vector2(62, 62) * k), false)
	if cell.over:
		var done: Dictionary = pack.effect(SkillCell.DONE) if pack != null else {}
		if not done.is_empty():
			_cell_fx(done, rect, origin, Vector2.ZERO, done_frame(battle.clock - float(cell.t0)))
	if cell.selv:
		var sel: Dictionary = pack.effect(SkillCell.SELECT) if pack != null else {}
		if not sel.is_empty():
			_cell_fx(sel, rect, origin, Vector2(0, SkillCell.SELECT_Y), int(floor(battle.clock * SkillCell.FPS)) % int(SkillCell.SELECT_FRAMES))
		else:

			var glow: float = 0.65 + 0.35 * sin(view._time * 8.0)
			view.draw_rect(rect.grow(2.0 * scale), Color(1.0, 0.92, 0.35, glow), false, 3.0 * scale)
	if real != null and slot not in CORPS_SLOTS and slot != 12:
		_stack_count(battle, prop, info, rect)




func _stack_count(battle, prop: Dictionary, info: Array, rect: Rect2) -> void :
	var count: int = int(prop.get("iCount", -1))
	if count <= 0:
		return
	var k: float = rect.size.x / 50.0
	var top: int = int(info[4]) if info.size() > 4 else 0
	var total: float = float(info[1]) if info.size() > 1 else 0.0
	if count < top and total > 0:
		var left: float = clampf((battle._stamp(prop.get("nCountCoolTime")) - battle.now_ms()) / total, 0.0, 1.0)
		if left > 0:
			var center: Vector2 = rect.position + Vector2(35, 35) * k
			var from: float = - PI / 2 + TAU * (1.0 - left)
			view.draw_arc(center, 11 * k, from, - PI / 2 + TAU, 48, Color(0, 0, 0, 0.8), 4 * k, true)
			view.draw_arc(center, 11 * k, from, - PI / 2 + TAU, 48, Color.WHITE, 2 * k, true)
	_text(rect.position + Vector2(0, 24) * k, "x%d" % count, Color.WHITE, 14, HORIZONTAL_ALIGNMENT_RIGHT, 45 * k, true, 3)


func _cell_fx(part: Dictionary, rect: Rect2, origin: Vector2, at: Vector2, index: int) -> void :
	var k: float = rect.size.x / 50.0
	view.draw_set_transform(origin + rect.position * scale, 0, Vector2(scale * k, scale * k))
	_fx_frame(part, at, index)
	_at(origin)


static func done_frame(elapsed: float) -> int:
	var n: int = maxi(0, int(floor(elapsed * SkillCell.FPS)))
	var first: int = int(SkillCell.DONE_LOOP[0])
	var last: int = int(SkillCell.DONE_LOOP[1])
	return n if n <= last else first + (n - last - 1) % (last - first + 1)






func cell_state(battle, slot: int) -> Dictionary:
	var begun_v: Variant = battle.get("begun")
	var battle_id: int = battle.get_instance_id()
	var begun: int = int(begun_v) if begun_v != null else 0
	if battle_id != _cells_id or begun != _cells_begun or _cells_battle.is_empty():
		_cells_id = battle_id
		_cells_begun = begun
		var key: String = "%d:%d" % [battle_id, begun]
		if _cells_battle != key:
			_cells.clear()
			_cells_battle = key
	var cell: Dictionary = _cells.get(slot, {})
	if cell.is_empty():
		cell = {"prop": null, "lock": false, "ban": false, "lack": false, "left": 0.0, "need": 0, "active": true, "state": CELL_INI, 
			"picked": false, "cd": true, "over": true, "selv": true, "bans": true, "locks": true, "mp": true, "t0": battle.clock, 
			"sim": {"nPropsId": int(SkillCell.DEFAULT_CORPS), "bSlotno": slot, "iCount": -1, "nEndTime": {}, "nCountCoolTime": {}}}
		_cells[slot] = cell
	var real: Variant = battle.skills.get(slot)
	var corps: bool = slot in CORPS_SLOTS
	var prop: Variant = real if real != null or not corps else cell.sim

	var lock: bool = (slot == 2 and battle.ex_locked()) or (corps and real == null)
	if lock != bool(cell.lock):
		cell.lock = lock
		if lock:
			_cell_enter(cell, CELL_LOCKED, battle.clock)
		else:
			_cell_quit(cell, CELL_LOCKED, battle.clock)
	var ban: bool = slot in BAN_SLOTS and SkillCast.banned(battle, pack, slot)
	if ban != bool(cell.ban):
		cell.ban = ban
		if ban:
			_cell_enter(cell, CELL_BAN, battle.clock)
		else:
			_cell_quit(cell, CELL_BAN, battle.clock)
	var tank: Dictionary = battle.tanks.get(battle.self_id, {})
	if prop != null and not is_same(prop, cell.prop):
		cell.prop = prop
		var info: Array = pack.skill_hud(int(prop.nPropsId)) if pack != null else []
		cell.need = int(info[3]) if info.size() > 3 else 0
		cell.active = not SkillCell.PASSIVE.has(int(prop.nPropsId))
		cell.left = _cell_left(battle, slot, real)
		cell.lack = Mp.uses(tank) and int(cell.need) > 0 and int(tank.get("mp", 0)) < int(cell.need)
		_cell_cd(cell, battle.clock)
		if int(cell.need) > 0:
			_cell_mp(cell, battle.clock)
		_cell_init(cell, battle.clock)
	if cell.prop == null:
		return cell
	if int(cell.need) > 0:
		cell.lack = Mp.uses(tank) and int(tank.get("mp", 0)) < int(cell.need)
		_cell_mp(cell, battle.clock)
	cell.left = _cell_left(battle, slot, real)
	_cell_cd(cell, battle.clock)

	var picked: bool = slot != 0 and view.controls.selected == slot
	if picked != bool(cell.picked):
		cell.picked = picked
		cell.selv = picked
	return cell

const CELL_INI: int = 0
const CELL_OK: int = 1
const CELL_CD: int = 2
const CELL_MP: int = 3
const CELL_BAN: int = 4
const CELL_LOCKED: int = 5
const CORPS_SLOTS: Array[int] = [4, 13]
const BAN_SLOTS: Array[int] = [3, 4, 1, 2, 10, 13]

func _cell_left(battle, slot: int, real: Variant) -> float:
	if real == null:
		return 0.0
	var left: float = battle.cooldown(slot)
	return left if is_finite(left) else 0.0

func _cell_cd(cell: Dictionary, clock: float) -> void :
	if float(cell.left) > 0:
		_cell_enter(cell, CELL_CD, clock)
	else:
		_cell_quit(cell, CELL_CD, clock)

func _cell_mp(cell: Dictionary, clock: float) -> void :
	if cell.lack:
		_cell_enter(cell, CELL_MP, clock)
	else:
		_cell_quit(cell, CELL_MP, clock)

func _cell_quit(cell: Dictionary, state: int, clock: float) -> void :
	if int(cell.state) == state:
		_cell_init(cell, clock)

func _cell_init(cell: Dictionary, clock: float) -> void :
	cell.state = CELL_INI
	if cell.lock:
		_cell_enter(cell, CELL_LOCKED, clock)
	elif cell.ban:
		_cell_enter(cell, CELL_BAN, clock)
	elif cell.prop != null and cell.lack:
		_cell_enter(cell, CELL_MP, clock)
	elif float(cell.left) > 0:
		_cell_enter(cell, CELL_CD, clock)
	else:
		_cell_enter(cell, CELL_OK, clock)

func _cell_enter(cell: Dictionary, state: int, clock: float) -> void :
	if int(cell.state) >= state:
		return
	cell.state = state
	match state:
		CELL_OK:
			cell.over = cell.active
			cell.cd = false
			cell.selv = cell.picked
			cell.bans = false
			cell.locks = false
			cell.mp = false
			cell.t0 = clock
		CELL_CD:
			cell.cd = true
			cell.over = false
			cell.selv = false
			cell.bans = false
			cell.locks = false
		CELL_MP:
			cell.over = false
			cell.selv = false
			cell.bans = false
			cell.locks = false
			cell.mp = true
		CELL_BAN:
			cell.cd = false
			cell.over = false
			cell.selv = false
			cell.bans = true
			cell.locks = false
			cell.mp = false
		CELL_LOCKED:
			cell.cd = false
			cell.over = false
			cell.selv = false
			cell.bans = false
			cell.locks = true
			cell.mp = false


func cell_blocked(battle, slot: int) -> bool:
	return SkillCast.banned(battle, pack, slot) or (slot == 2 and battle.ex_locked())\
	or (slot in CORPS_SLOTS and battle.skills.get(slot) == null)




func buff_cells(battle) -> Array:
	var out: Array = []
	var tank: Dictionary = battle.tanks.get(battle.self_id, {})
	if tank.is_empty() or pack == null:
		return out
	var shown: Array = []
	var ids: Array = tank.buffs.keys()
	ids.sort()
	for inst: int in ids:
		var buff: Dictionary = tank.buffs[inst]
		var info: Array = pack.buff_hud(int(buff.get("m_nBuffTpltId", 0)))
		if info.is_empty() or str(info[0]).is_empty():
			continue
		shown.append([buff, info])
	if level_mode_of(battle) > 0 and battle_level_of(tank) > 0:
		shown.append([{}, []])
	var count: int = mini(shown.size(), 16)
	for index in range(count):
		var row: int = index / 8
		var origin: Vector2 = Vector2(view.size.x / 2 + (320 - 145) * scale, view.size.y - ((5 if row == 0 else 46) + 36) * scale)
		if touch:


			origin = TouchLq.buff_origin(view.size, mini(8, count - row * 8), row, battle.skills.has(12))
		out.append([shown[index][0], shown[index][1], index % 8, origin])
	return out


func level_mode_of(battle) -> int:
	return int(pack.hud.get("levels", {}).get(str(battle.map_id), 0)) if pack != null else 0


static func battle_level_of(tank: Dictionary) -> int:
	return int(tank.get("battle_level", tank.get("level", 0)))

func _buffs(battle) -> void :
	var tank: Dictionary = battle.tanks.get(battle.self_id, {})
	for entry: Array in buff_cells(battle):
		_at(entry[3])
		var i: int = entry[2]
		var buff: Dictionary = entry[0]
		var info: Array = entry[1]
		if buff.is_empty():
			_img("lv%d" % clampi(battle_level_of(tank), 1, 7), Vector2(2 + 36 * i + 2, 2))
			continue
		var cell: Rect2 = Rect2(2 + 36 * i + 2, 2, 32, 32)
		var icon: Texture2D = pack.icon("b", str(info[0]))
		if icon != null:
			view.draw_texture_rect(icon, cell, false)
		else:
			view.draw_rect(cell, Color(0.1, 0.12, 0.16, 0.7))
		var exist: float = float(buff.get("exist", 0))
		if exist > 0 and int(info[1]) != 1:
			_clock(cell, (battle.clock - float(buff.get("t0", battle.clock))) / exist)
		if int(buff.get("m_nStackCount", 0)) > 1:
			_text(Vector2(2 + 36 * i + 1, 19), str(int(buff.m_nStackCount)), Color.WHITE, 12, HORIZONTAL_ALIGNMENT_RIGHT, 34, true, 2)








const TIP_W: float = 252.0
var tip_wide: float = 1.0
const TIP_TEXT_W: float = 240.0
const TIP_LINE: float = 16.0
const TIP_DEC: Color = Color("cccccc")
const TIP_CD: Color = Color("21ac16")
const TIP_MP: Color = Color("529fe4")
const TIP_LOCK: Color = Color("00ff00")
const TIP_LOCK_LV: Color = Color("ff0000")
const TIP_CORPS: Color = Color("ff0000")
const TIP_GUILD_FLAG: int = 1 << 28
const TIP_PASSIVE: int = 3
var hover: Dictionary = {}
var hover_range: float = 0.0


var touch_tip: Dictionary = {}
var tip_rect: Rect2 = Rect2()
var _tip_box: StyleBoxFlat = null


func shown_skill(battle, ordinal: int) -> Array:
	var slot: int = [10 if battle.skills.has(10) else 3, 1, 2, 13 if battle.skills.has(13) else 4, 12][ordinal]
	var real: Variant = battle.skills.get(slot)
	if real != null and int(real.get("nPropsId", 0)) != 0:
		return [slot, int(real.nPropsId)]
	if slot in CORPS_SLOTS:
		return [slot, int(SkillCell.DEFAULT_CORPS)]
	return [slot, 0]


func skill_range(id: int) -> int:
	var rule: Variant = pack.skill_cast(id) if pack != null else null
	if rule is Array:
		return SkillCast._field(rule, 3)
	var tip: Variant = pack.tips.get("skills", {}).get(str(id)) if pack != null else null
	return int(tip[3]) if tip is Array and tip.size() > 3 else 0


func update_hover(point: Vector2, battle, enabled: bool = true) -> void :
	hover = {}
	hover_range = 0.0
	if touch and not touch_tip.is_empty():
		if pack != null and battle != null and not battle.ended and battle.tanks.has(battle.self_id):
			hover = touch_tip
		return
	if not enabled or pack == null or battle == null or battle.ended or not battle.tanks.has(battle.self_id):
		return
	if fps_rect.has_point(point) and not FpsMeter.gpu_name().is_empty():
		hover = {"kind": "gpu", "at": point}
		return
	var ordinal: int = cell_hit(point, battle)
	if ordinal >= 0:
		var shown: Array = shown_skill(battle, ordinal)
		if int(shown[1]) == 0:
			return
		hover = {"kind": "skill", "id": int(shown[1]), "slot": int(shown[0]), "at": point}
		hover_range = float(skill_range(int(shown[1])))
		return
	var tank: Dictionary = battle.tanks[battle.self_id]
	for entry: Array in buff_cells(battle):
		var cell: Rect2 = _screen(entry[3], Rect2(2 + 36 * int(entry[2]), 0, 36, 36))
		if not cell.has_point(point):
			continue
		if (entry[0] as Dictionary).is_empty():
			var brief: Dictionary = brief_of(battle, int(tank.get("account", 0)))
			var other: Dictionary = brief.get("otherData") if brief.get("otherData") is Dictionary else {}
			hover = {"kind": "level", "level": battle_level_of(tank), "tank": int(other.get("tankId", 0)), "at": point}
		else:
			hover = {"kind": "buff", "id": int(entry[0].get("m_nBuffTpltId", 0)), "at": point}
		return



func touch_buff_tip(point: Vector2, battle) -> Dictionary:
	if pack == null or battle == null or battle.ended or not battle.tanks.has(battle.self_id):
		return {}
	var u: float = TouchLq.unit(view.size)
	var k: float = TouchLq.BUFF_K * u
	var tank: Dictionary = battle.tanks[battle.self_id]
	var best: Dictionary = {}
	var near: float = INF
	for entry: Array in buff_cells(battle):
		var cell: Rect2 = Rect2((entry[3] as Vector2) + Vector2(2 + 36 * int(entry[2]), 0) * k, Vector2(36, 36) * k)
		var d: float = cell.get_center().distance_to(point)
		if not cell.grow(TouchLq.BUFF_HIT * u).has_point(point) or d >= near:
			continue
		near = d
		if (entry[0] as Dictionary).is_empty():
			var brief: Dictionary = brief_of(battle, int(tank.get("account", 0)))
			var other: Dictionary = brief.get("otherData") if brief.get("otherData") is Dictionary else {}
			best = {"kind": "level", "id": 0, "level": battle_level_of(tank), "tank": int(other.get("tankId", 0)), "at": cell.get_center(), "box": cell}
		else:
			best = {"kind": "buff", "id": int(entry[0].get("m_nBuffTpltId", 0)), "at": cell.get_center(), "box": cell}
	return best



func touch_tip_position(box: Rect2, size: Vector2) -> Vector2:
	var u: float = TouchLq.unit(view.size)
	var gap: float = 8.0 * u
	var edge: float = 4.0 * u
	var pos: Vector2 = Vector2(box.get_center().x - size.x, box.position.y - gap - size.y)
	if pos.y < edge:
		pos = Vector2(box.position.x - gap - size.x, box.get_center().y - size.y / 2.0)
		if pos.x < edge:
			pos.x = box.end.x + gap
	return Vector2(clampf(pos.x, edge, maxf(edge, view.size.x - size.x - edge)), clampf(pos.y, edge, maxf(edge, view.size.y - size.y - edge)))


static func tip_number(value: float) -> String:
	var tenth: float = snappedf(value, 0.1)
	return str(int(roundf(tenth))) if is_equal_approx(tenth, roundf(tenth)) else String.num(tenth, 1)


func tip_corps(id: int) -> bool:
	var corps: Variant = pack.tips.get("corps", []) if pack != null else []
	if corps is Array:
		for value: Variant in corps:
			if int(value) == id:
				return true
	return false


func level_row(level: int, mode: int, tank_id: int) -> Array:
	var levels: Dictionary = pack.tips.get("levels", {}) if pack != null else {}
	var hit: Variant = levels.get("%d:%d:%d" % [mode, level, tank_id])
	if not hit is Array:
		hit = levels.get("%d:%d:0" % [mode, level])
	return hit if hit is Array else []


func tip_desc_rows(index: int, width: float, size: int) -> Array:
	var desc: Array = pack.tips.get("desc", []) if pack != null else []
	if index < 0 or index >= desc.size() or not desc[index] is Array:
		return []
	var rows: Array = []
	var para: Array = []
	for seg: Variant in desc[index]:
		if not seg is Array or seg.size() < 2:
			continue
		var color: Color = Color.html(str(seg[1])) if Color.html_is_valid(str(seg[1])) else TIP_DEC
		var parts: PackedStringArray = str(seg[0]).split("\n")
		for k in range(parts.size()):
			if k > 0:
				rows.append_array(wrap_rich(para, width, size) if not para.is_empty() else [[]])
				para = []
			if not parts[k].is_empty():
				para.append([parts[k], color])
	if not para.is_empty():
		rows.append_array(wrap_rich(para, width, size))
	return rows



func tip_layout(battle, client) -> Dictionary:
	if str(hover.get("kind", "")) == "gpu":
		return gpu_tip()
	if hover.is_empty() or pack == null or not pack.tips.get("skills") is Dictionary:
		return {}
	var text: Dictionary = pack.tips.get("text", {})
	var items: Array = []
	var y: float = 10.0
	var tank: Dictionary = battle.tanks.get(battle.self_id, {})
	var mode: int = level_mode_of(battle)
	var desc: int = -1
	match str(hover.kind):
		"skill":
			var id: int = int(hover.id)
			var row: Variant = pack.tips.skills.get(str(id))
			if not row is Array or row.size() < 4:
				return {}

			var stunt: Variant = battle.skills.get(2)
			if mode > 0 and stunt != null and int(stunt.get("nPropsId", 0)) == id and battle.ex_locked():
				var parts: PackedStringArray = str(text.get("TIP_540", "")).split("@num1@")
				var line: Array = [[parts[0], TIP_LOCK], [str(int(battle.ex_unlock.get(battle.map_id, 0))), TIP_LOCK_LV]]
				if parts.size() > 1:
					line.append([parts[1], TIP_LOCK])
				items.append({"kind": "rich", "x": 5.0, "y": y, "rows": [line], "size": 12})
				y += 18

			var flag: int = int(client.character.get("actionFlag", 0)) if client != null and client.character is Dictionary else 0
			var guild: int = int(client.guild.get("nGuildId", 0)) if client != null and client.guild is Dictionary else 0
			if (flag & TIP_GUILD_FLAG) != 0 and tip_corps(id) and guild == 0:
				items.append({"kind": "center", "x": 0.0, "y": y, "text": str(text.get("CORPS_TEXT91", "")), "color": TIP_CORPS, "size": 16, "bold": false})
				y += 16 + 16
			items.append({"kind": "label", "x": 5.0, "y": y, "text": str(row[0]), "color": Color.WHITE, "size": 14, "bold": true})
			y += 20
			var info: Array = pack.skill_hud(id)
			var cool: int = int(info[1]) if info.size() > 1 else 0
			if cool > 0:
				var seconds: float = cool / 1000.0
				if mode > 0 and int(row[2]) != TIP_PASSIVE and not tank.is_empty():
					var brief: Dictionary = brief_of(battle, int(tank.get("account", 0)))
					var other: Dictionary = brief.get("otherData") if brief.get("otherData") is Dictionary else {}
					var exp_row: Array = level_row(battle_level_of(tank), mode, int(other.get("tankId", 0)))
					if exp_row.size() > 1:
						seconds *= 1.0 - float(exp_row[1])
				items.append({"kind": "label", "x": 5.0, "y": y, "text": str(text.get("CONTROL_TEXT190", "")).replace("@num1@", tip_number(seconds)), 
					"color": TIP_CD, "size": 12, "bold": false})
				y += 16
			var mp: int = int(info[3]) if info.size() > 3 else 0
			if mp != 0:
				items.append({"kind": "label", "x": 5.0, "y": y, "text": str(text.get("CONTROL_TEXT775", "")).replace("@num1@", str(mp)), 
					"color": TIP_MP, "size": 12, "bold": false})
				y += 16
			y += 10
			items.append({"kind": "label", "x": 5.0, "y": y, "text": str(text.get("ITEM_TEXT2", "")), "color": TIP_DEC, "size": 12, "bold": false})
			y += 16
			desc = int(row[1])
		"buff":
			var row: Variant = pack.tips.get("buffs", {}).get(str(int(hover.id)))
			if not row is Array or row.size() < 2:
				return {}
			items.append({"kind": "label", "x": 5.0, "y": y, "text": str(row[0]), "color": Color.WHITE, "size": 14, "bold": true})
			y += 16 + 10
			items.append({"kind": "label", "x": 5.0, "y": y, "text": str(text.get("TIP_5", "")), "color": TIP_DEC, "size": 12, "bold": false})
			y += 16
			desc = int(row[1])
		"level":
			if int(hover.level) == 0:
				return {}
			var row: Array = level_row(int(hover.level), mode, int(hover.tank))
			if row.is_empty():
				return {}
			items.append({"kind": "label", "x": 5.0, "y": y, "text": str(text.get("CONTROL_TEXT500", "")), "color": Color.WHITE, "size": 14, "bold": true})
			y += 16 + 10
			items.append({"kind": "label", "x": 5.0, "y": y, "text": str(text.get("TIP_5", "")), "color": TIP_DEC, "size": 12, "bold": false})
			y += 16
			desc = int(row[0])
		_:
			return {}
	var rows: Array = tip_desc_rows(desc, TIP_TEXT_W + TIP_W * (tip_wide - 1.0), 12)
	items.append({"kind": "rich", "x": 7.0, "y": y, "rows": rows, "size": 12})
	y += rows.size() * TIP_LINE + 6
	return {"height": y + 16, "items": items}



const GPU_TITLE: String = "Card đồ họa (GPU)"
const GPU_SOFT: String = "Trình duyệt đang vẽ bằng CPU. Bật Tăng tốc phần cứng trong trình duyệt để chơi mượt hơn"
func gpu_tip() -> Dictionary:
	var raw: String = FpsMeter.gpu_name()
	if raw.is_empty():
		return {}
	var items: Array = []
	var y: float = 10.0
	items.append({"kind": "label", "x": 5.0, "y": y, "text": GPU_TITLE, "color": Color.WHITE, "size": 12, "bold": true})
	y += TIP_LINE + 4
	var rows: Array = wrap_rich([[FpsMeter.gpu_short(raw), TIP_DEC]], TIP_TEXT_W, 12)
	items.append({"kind": "rich", "x": 7.0, "y": y, "rows": rows, "size": 12})
	y += rows.size() * TIP_LINE
	if FpsMeter.software(raw):
		var warn: Array = wrap_rich([[GPU_SOFT, TIP_LOCK_LV]], TIP_TEXT_W, 12)
		items.append({"kind": "rich", "x": 7.0, "y": y + 4, "rows": warn, "size": 12})
		y += 4 + warn.size() * TIP_LINE
	return {"height": y + 12, "items": items}


func tip_position(at: Vector2, size: Vector2) -> Vector2:
	var pos: Vector2 = Vector2(at.x - size.x, at.y)
	if pos.x < 0:
		pos.x = at.x
	if at.y > view.size.y - size.y:
		pos.y = maxf(0.0, at.y - size.y)
	return pos


func draw_tip(battle, client) -> void :
	tip_rect = Rect2()
	var layout: Dictionary = tip_layout(battle, client)
	if layout.is_empty():
		return
	scale = layout_scale()
	var wide: float = TIP_W
	if hover.has("box"):
		var room: float = view.size.y - 8.0 * TouchLq.unit(view.size)
		if float(layout.height) * scale > room:
			tip_wide = 2.0
			layout = tip_layout(battle, client)
			tip_wide = 1.0
			wide = TIP_W * 2.0
			scale = minf(scale, room / float(layout.height))
	var size: Vector2 = Vector2(wide, float(layout.height)) * scale
	tip_rect = Rect2(touch_tip_position(hover.box, size) if hover.has("box") else tip_position(hover.at, size), size)
	_at(tip_rect.position)
	if _tip_box == null:
		_tip_box = StyleBoxFlat.new()
		_tip_box.bg_color = Color(0, 0, 0, 0.8)
		_tip_box.set_corner_radius_all(6)
	view.draw_style_box(_tip_box, Rect2(0, 0, wide, float(layout.height)))
	for item: Dictionary in layout.items:
		match str(item.kind):
			"label":
				_text(Vector2(item.x, item.y), str(item.text), item.color, int(item.size), HORIZONTAL_ALIGNMENT_LEFT, -1, bool(item.bold), 0)
			"center":
				_text(Vector2(0, item.y), str(item.text), item.color, int(item.size), HORIZONTAL_ALIGNMENT_CENTER, wide, bool(item.bold), 0)
			"rich":
				draw_rows(item.rows, Vector2(item.x, item.y), int(item.size), TIP_LINE, 0)
	view.draw_set_transform(Vector2.ZERO)











const RELIVE_79: String = "Còn %d s hồi sinh"
const RELIVE_354: String = "Còn %d mạng"
const RELIVE_286: String = "VIP có thể tăng Hp ban đầu"
const RELIVE_287: String = "VIP có thể rút ngắn thời gian đợi hồi sinh"
const KILL_30: String = "Bạn bị %s đánh bại"
const RELIVE_WAIT: String = "Bạn đã tử vong"

const DEAD_WAIT_TIP: String = "Cổ vũ đồng đội đang chiến đấu nào!"
const PVE_ROOMS: Array = [3, 4, 8, 50, 51, 52, 53, 7, 14]
const TEAM_PVE_MODE: int = 8



const KILLER_TIP_RECT: Rect2 = Rect2(112, 66, 436, 80)
const KILLER_TIP_COLOR: Color = Color("f9fc27")
const KILLER_TIP_SIZE: int = 16
const AUTO_SKINS: Array = ["Skin A", "Skin S", "Skin SS", "Skin SSS", "Skin riêng"]
var relive_shown: Dictionary = {}


func suitable_name(ext: int, tank_id: int) -> String:
	if pack == null:
		return ""
	if ext > 0:
		var looks: Dictionary = pack.garage.get("looks", {})
		var lists: Array = [looks.get(str(tank_id), [])]
		lists.append_array(looks.values())
		for rows: Variant in lists:
			for look: Variant in rows:
				if look is Array and look.size() >= 3 and int(look[0]) == ext and not AUTO_SKINS.has(str(look[2])) and not str(look[2]).is_empty():
					return str(look[2])
	return GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(tank_id), "")))



func relive_look(battle) -> Dictionary:
	var tank: Dictionary = battle.tanks.get(battle.self_id, {})
	var death: bool = battle.mode == "death" and tank.get("dead", false)
	if tank.is_empty() or not battle.started or not (battle.respawn > 0 or death):
		return {}
	var pve: bool = int(battle.room_type) in PVE_ROOMS
	var look: Dictionary = {"state": "", "vip": RELIVE_286 if pve else RELIVE_287}
	if battle.respawn <= 0:
		if battle.ended:
			return {}
		if battle.death_wait_cut:
			return {}
		look.text = RELIVE_WAIT
		look.vip = ""
		look.wait = true
		look.tip = DEAD_WAIT_TIP
		return look
	look.text = RELIVE_79 % ceili(battle.respawn)
	if int(tank.get("lives", 0)) > 0:
		look["text"] = str(look.text) + " " + RELIVE_354 % int(tank.lives)
	if pve and int(Text.map_info(int(battle.map_id)).get("modeType", -1)) != TEAM_PVE_MODE:
		return look
	var killer: int = int(battle.self_killer.get("id", 0))
	if killer >> 26 != 0 or not battle.tanks.has(killer):
		return look
	var account: int = int(battle.tanks[killer].get("account", battle.self_killer.get("account", 0)))
	var other: Dictionary = {}
	for brief: Variant in battle.roster:
		if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) == account:
			var data: Variant = brief.get("otherData", {})
			other = data if data is Dictionary else {}
			break
	var tank_id: int = int(other.get("tankId", 0))
	var name: String = suitable_name(int(other.get("tankExternal", 0)), tank_id) if tank_id > 0 else ""
	if other.is_empty() or name.is_empty():
		return look
	look.state = "Tank"
	look.name = name
	look.kill = KILL_30 % name
	look.tank = tank_id
	look.worn = int(other.get("tankExternal", 0))
	look.level = int(other.get("tankLevel", 0))
	look.halo = int(other.get("haloId", 0))
	look.killer_tip = killer_tip(tank_id)
	return look


func killer_tip(tank_id: int) -> String:
	if pack == null or not (pack.lobby is Dictionary):
		return ""
	var tips: Variant = pack.lobby.get("killer_tips", {})
	return str(tips.get(str(tank_id), "")) if tips is Dictionary else ""


func killer_tip_lines() -> int:
	var f: Font = _gap_font(bold, 2)
	return maxi(1, floori((KILLER_TIP_RECT.size.y - 4) / f.get_height(KILLER_TIP_SIZE)))

func _killer_tip(text: String) -> void :
	if text.is_empty():
		return
	var f: Font = _gap_font(bold, 2)
	var at: Vector2 = KILLER_TIP_RECT.position + Vector2(2, 2 + f.get_ascent(KILLER_TIP_SIZE))
	view.draw_multiline_string(f, at, text, HORIZONTAL_ALIGNMENT_LEFT, KILLER_TIP_RECT.size.x - 4, KILLER_TIP_SIZE, 
		killer_tip_lines(), KILLER_TIP_COLOR)



func _relive_avatar(look: Dictionary, origin: Vector2, clock: float) -> void :
	if pack == null or pack.state != "ready" or int(look.tank) <= 0:
		return
	var worn: int = int(look.worn)
	var level: int = maxi(1, int(look.level))
	var ext: int = worn if worn > 0 else GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(look.tank), level, {})
	var item: int = 0 if worn > 0 else TankPortrait.halo_item(pack.fx.get("halo_ui", {}), 0, level)
	if TankPortrait.draw(view, pack, GarageModel.face(pack.garage, ext), item, Vector2(201, 39), 0.25, clock, "l/t", false):
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(worn), int(look.tank)))
	if TankPreview.ready(art):
		TankPreview.draw(view, art, origin + Vector2(201, 42) * scale, 0.28 * scale, 4, clock)
		_at(origin)

func _relive(battle) -> void :
	relive_shown = relive_look(battle)
	if relive_shown.is_empty():
		return
	var look: Dictionary = relive_shown
	if look.get("wait", false):
		_dead_wait(look)
		return
	var tank_state: bool = look.state == "Tank"
	var frame: Vector2 = Vector2(660, 222) if tank_state else Vector2(572, 104)
	var origin: Vector2 = Vector2(view.size.x / 2 - frame.x / 2 * scale, view.size.y - (146 + frame.y) * scale)
	_at(origin)
	var count: Vector2 = Vector2(33, 25)
	if tank_state:
		_img("relive_pvp", Vector2(25, 8))
		count = Vector2(60, 144)
		_relive_avatar(look, origin, float(battle.clock))
		_text(Vector2(238, 24), str(look.kill), Color("ff6a6a"), 14, HORIZONTAL_ALIGNMENT_LEFT, 310, true, 0)
		_killer_tip(str(look.get("killer_tip", "")))
	else:
		_img("relive_pve", Vector2(20.5, 20.5))
	if str(look.vip).is_empty():
		_text(count + Vector2(0, 11), str(look.text), Color("ffff00"), 20, HORIZONTAL_ALIGNMENT_CENTER, 400, true, 0)
	else:
		_text(count, str(look.text), Color("ffff00"), 20, HORIZONTAL_ALIGNMENT_CENTER, 400, true, 0)

		var base: Vector2 = count + Vector2(0, 30 + 15)
		view.draw_string_outline(bold, base, str(look.vip), HORIZONTAL_ALIGNMENT_CENTER, 400, 14, 6, Color("07649d"))
		view.draw_string(bold, base, str(look.vip), HORIZONTAL_ALIGNMENT_CENTER, 400, 14, Color("003660"))

	_buy_life(view.get("client"), origin, Vector2(428, 144) if tank_state else Vector2(400, 25))




const BUY_BUTTON: Rect2 = Rect2(30, 0, 100, 40)
const BUY_TIP_COLOR: Color = Color("ffff00")
const BUY_TIP_GLOW: Color = Color(7 / 255.0, 100 / 255.0, 157 / 255.0, 0.8)
var _gray: Dictionary = {}

func _buy_life(client, origin: Vector2, at: Vector2) -> void :
	if client == null or not client.has_method("buy_life_shown") or not client.buy_life_shown():
		return
	var info: Dictionary = client.buy_life
	var on: bool = bool(info.get("enabled", true))
	var button: Rect2 = Rect2(at + BUY_BUTTON.position, BUY_BUTTON.size)
	var hit: Rect2 = _screen(origin, button)
	rects["relive_buy"] = hit
	var texture: Texture2D = tex("relive_now") if on else _gray_tex("relive_now")
	if texture != null:
		var lit: Color = STATE_HOVER if on and not touch and hit.has_point(view.get_local_mouse_position()) else Color.WHITE
		view.draw_texture_rect(texture, button, false, lit)
	var f: Font = _gap_font(bold, 2)
	var tip: String = str(info.get("tip", ""))
	var base: Vector2 = at + Vector2(0, 35 + 2 + f.get_ascent(12))
	view.draw_string_outline(f, base, tip, HORIZONTAL_ALIGNMENT_CENTER, 160, 12, 6, BUY_TIP_GLOW)
	view.draw_string(f, base, tip, HORIZONTAL_ALIGNMENT_CENTER, 160, 12, BUY_TIP_COLOR)


func _gray_tex(name: String) -> Texture2D:
	if _gray.has(name):
		return _gray[name]
	var source: Texture2D = tex(name)
	if source == null:
		return null
	var image: Image = source.get_image()
	if image == null:
		return source
	image = image.duplicate()
	if image.is_compressed():
		image.decompress()
	image.convert(Image.FORMAT_RGBA8)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var c: Color = image.get_pixel(x, y)
			var l: float = 0.3086 * c.r + 0.6094 * c.g + 0.082 * c.b
			image.set_pixel(x, y, Color(l, l, l, c.a))
	var gray: Texture2D = ImageTexture.create_from_image(image)
	_gray[name] = gray
	return gray



func relive_click(client) -> void :
	var info: Dictionary = client.buy_life
	if not bool(info.get("enabled", true)):
		return
	if int(info.get("type", 0)) != 0 and client.ask_buy_life():
		view.ask_buy_life(int(info.type), int(info.num))
		return
	client.request_buy_life(int(info.get("type", 0)))




func _dead_wait(look: Dictionary) -> void :
	var origin: Vector2 = Vector2(view.size.x / 2 - 426 * scale, view.size.y - (146 + 214) * scale)
	_at(origin)
	_img("wordtip_shadow", Vector2(27.5, 77))
	_img("wordtip_bk", Vector2(27.5, 77))
	var glow: Color = Color(Color("07649d"), 0.8)
	var title: Font = _gap_font(bold, 2)
	var base: Vector2 = Vector2(0, 107 + (title.get_ascent(28) - title.get_descent(28)) / 2)
	view.draw_string_outline(title, base, str(look.text), HORIZONTAL_ALIGNMENT_CENTER, 852, 28, 6, glow)
	view.draw_string(title, base, str(look.text), HORIZONTAL_ALIGNMENT_CENTER, 852, 28, Color("ffff00"))
	if _wait_box == null:
		_wait_box = StyleBoxFlat.new()
		_wait_box.bg_color = Color(Color("0066ae"), 0.8)
		_wait_box.border_color = Color("6bf4ff")
		_wait_box.set_border_width_all(2)
		_wait_box.set_corner_radius_all(10)
	view.draw_style_box(_wait_box, Rect2(218.5, 145, 415, 64))
	var tip: String = str(look.get("tip", ""))
	if not tip.is_empty():
		var small: Font = _gap_font(bold, 2)
		var at: Vector2 = Vector2(220.5, 165 + 16 + 1)
		view.draw_string_outline(small, at, tip, HORIZONTAL_ALIGNMENT_CENTER, 411, 16, 6, glow)
		view.draw_string(small, at, tip, HORIZONTAL_ALIGNMENT_CENTER, 411, 16, Color("ffff00"))


func _gap_font(base: Font, gap: int) -> Font:
	if gap == 0 or base == null:
		return base
	var tag: String = "%d:%d" % [base.get_instance_id(), gap]
	if not _gap_fonts.has(tag):
		var variant: FontVariation = FontVariation.new()
		variant.base_font = base
		if base is FontVariation:
			variant.variation_opentype = (base as FontVariation).variation_opentype
			variant.opentype_features = (base as FontVariation).opentype_features
		variant.spacing_glyph = gap
		_gap_fonts[tag] = variant
	return _gap_fonts[tag]



func wrap_rich(pieces: Array, width: float, size: int) -> Array:
	var rows: Array = [[]]
	var x: float = 0.0
	var words: RegEx = _words()
	for piece: Array in pieces:
		var color: Color = piece[1]
		for found: RegExMatch in words.search_all(str(piece[0])):
			var word: String = found.get_string()
			var w: float = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			if x + w > width and x > 0:
				rows.append([])
				x = 0.0
				if word.strip_edges().is_empty():
					continue
			while w > width and word.length() > 1:
				var cut: int = word.length() - 1
				while cut > 1 and font.get_string_size(word.left(cut), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width:
					cut -= 1
				rows[-1].append([word.left(cut), color])
				rows.append([])
				word = word.substr(cut)
				w = font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
			rows[-1].append([word, color])
			x += w
	return rows

func draw_rows(rows: Array, pos: Vector2, size: int, line: float, outline: int = 2, alpha: float = 1.0) -> void :
	for i in range(rows.size()):
		var x: float = pos.x
		for seg: Array in rows[i]:
			var base: Vector2 = Vector2(x, pos.y + i * line + size + 1)
			var color: Color = Color(seg[1], seg[1].a * alpha)
			if outline > 0:
				view.draw_string_outline(font, base, seg[0], HORIZONTAL_ALIGNMENT_LEFT, -1, size, outline, Color(0, 0, 0, 0.85 * alpha))
			view.draw_string(font, base, seg[0], HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
			x += font.get_string_size(seg[0], HORIZONTAL_ALIGNMENT_LEFT, -1, size).x

func _chat_rows(lines: Array, width: float) -> Array:
	var rows: Array = []
	for line: Dictionary in lines:
		var pieces: Array = []
		if not str(line.head).is_empty():
			pieces.append([line.head, line.color])
		if not str(line.name).is_empty():
			pieces.append([line.name, line.name_color])
		pieces.append([line.text, line.color])
		rows.append_array(wrap_rich(pieces, width, 12))
	return rows



func _chat(_battle) -> void :
	var origin: Vector2 = Vector2(0, 22 * scale)
	if touch and not TouchLq.TouchLayout.chat_on():
		return
	if touch:


		var map_bottom: float = TouchLq.MAP_AT * scale + rects.map.size.y if rects.has("map") else -1.0
		origin = Vector2(TouchLq.MAP_AT * scale, (map_bottom + (TouchLq.SIG_GAP + TouchLq.SIG_CELL + 4) * scale) if map_bottom >= 0 else 4 * scale)
		origin += safe_tl
		if TouchLq.TouchLayout.mm_right():
			origin.x += 4.0 * TouchLq.unit(view.size) + (float(TankState.LAYOUT.size[0]) + 4.0) * scale
	_at(origin)
	if touch and not view.chat_open:

		view.draw_rect(Rect2(0, 0, 44, 22), Color(0, 0.33, 0.6, 0.75))
		_text(Vector2(0, 3), "Chat", Color.WHITE, 12, HORIZONTAL_ALIGNMENT_CENTER, 44, true, 2)
		rects["chat"] = _screen(origin, Rect2(-4, -4, 52, 30))
		origin += Vector2(0, 26 * scale)
	chat_panel = _screen(origin, Rect2(Vector2.ZERO, Vector2(300, 88)))


func _private_chat(battle) -> void :
	if touch and not TouchLq.TouchLayout.chat_on():
		return
	if battle.private_chat.is_empty() or battle.clock > battle.private_until:
		return
	var rows: Array = _chat_rows(battle.private_chat.slice(maxi(0, battle.private_chat.size() - 6)), 300)
	var fit: int = 6
	rows = rows.slice(maxi(0, rows.size() - fit))
	if touch and chat_panel.size.y > 0:
		_at(Vector2(safe_tl.x, chat_panel.end.y))
		draw_rows(rows, Vector2(2, 2), 12, 17)
		return
	_at(Vector2(0, view.size.y - (110 + 110) * scale))
	draw_rows(rows, Vector2(2, 110 - rows.size() * 17 - 2), 12, 17)






func _talk(battle) -> void :
	if not battle.has_method("talk_now") or pack == null:
		return
	var dialogs: Variant = battle.map.document.get("visual", {}).get("dialogs") if battle.map_loaded else null
	if dialogs is Dictionary:
		for row: Variant in (dialogs as Dictionary).values():
			if row is Dictionary:
				for key: String in [str(row.get("head", "")), str(row.get("bg", ""))]:
					if not key.is_empty() and not view._textures.has(key):
						pack.want_map_image(view._map_id, key)
	if battle.has_method("talk_images"):
		for key: String in battle.talk_images():
			pack.effect(key, true)
	var talk: Dictionary = battle.talk_now()
	if talk.is_empty():
		return
	var origin: Vector2 = Vector2(talk_left(0.0 if touch or not rects.has("map") else (rects["map"] as Rect2).end.x, scale), view.size.y - (260 + 50) * scale)
	_at(origin)
	if bool(talk.get("pack", false)):
		var bg_part: Dictionary = pack.effect(str(talk.bg))
		if not _pack_size(bg_part).is_zero_approx():
			_pack_pic(origin, bg_part, Vector2(35, 104))
		var head_part: Dictionary = pack.effect(str(talk.head))
		var head_size: Vector2 = _pack_size(head_part)
		if not head_size.is_zero_approx():
			_pack_pic(origin, head_part, Vector2(444 - 333 - head_size.x, 260 - 12 - head_size.y))
	else:
		var bg: Texture2D = view._textures.get(str(talk.bg))
		if bg != null:
			view.draw_texture(bg, Vector2(35, 104))
		var head: Texture2D = view._textures.get(str(talk.head))
		if head != null:
			view.draw_texture(head, Vector2(444 - 333 - head.get_width(), 260 - 12 - head.get_height()))

	view.draw_multiline_string(bold, Vector2(121, 138 + bold.get_ascent(16)), str(talk.text), HORIZONTAL_ALIGNMENT_LEFT, 
		311, 16, -1, Color.WHITE)




const TALK_LEFT: float = 187.0
const TALK_MAP_CLEAR: float = 100.0
static func talk_left(map_end: float, k: float) -> float:
	return maxf(TALK_LEFT * k, map_end + TALK_MAP_CLEAR * k)


func _pack_size(part: Dictionary) -> Vector2:
	if part.is_empty() or part.data.frames.is_empty():
		return Vector2.ZERO
	var rect: Array = part.data.frames[0].rect
	return Vector2(float(rect[2]), float(rect[3]))


func _pack_pic(origin: Vector2, part: Dictionary, at: Vector2) -> void :
	view.draw_set_transform(origin + at * scale, 0, Vector2(scale, scale))
	_fx_cell(view, part, 0, Color.WHITE)
	_at(origin)



const TARGET_Y: float = 64.0
const TARGET_W: float = 190.0
var target_shown: int = 0
var target_box: Rect2 = Rect2()
var touch_col_x: Array = [0.0, 0.0]
var touch_round: Dictionary = {}
var _target_style: StyleBoxFlat = null

func _target_info(battle) -> void :
	target_shown = 0
	target_box = Rect2()
	if not TouchLq.TouchLayout.target_info() or battle.get("hit_target") == null:
		return
	var tank: Dictionary = battle.tanks.get(int(battle.hit_target), {})
	if tank.is_empty() or tank.dead or tank.get("hidden", false) or battle.clock - float(battle.hit_target_at) > TouchLq.TouchLayout.TARGET_SHOW:
		return
	target_shown = int(tank.id)
	var origin: Vector2 = Vector2(floorf(view.size.x / 2 - TARGET_W / 2 * scale), floorf(TARGET_Y * scale + safe_in.y))
	var shield: int = int(tank.get("shield", 0))
	var high: float = 42.0 if shield > 0 else 36.0
	target_box = _screen(origin, Rect2(0, 0, TARGET_W, high))
	_at(origin)
	if _target_style == null:
		_target_style = StyleBoxFlat.new()
		_target_style.bg_color = SYS_BG
		_target_style.border_color = Color(SYS_BORDER, 0.5)
		_target_style.set_border_width_all(1)
		_target_style.set_corner_radius_all(SYS_RADIUS)
		_target_style.anti_aliasing = true
	view.draw_style_box(_target_style, Rect2(0, 0, TARGET_W, high))
	var hp: int = maxi(0, int(tank.hp))
	var top: int = maxi(1, int(tank.max_hp))
	_text(Vector2(8, 2), str(tank.name), Color.WHITE, 12, HORIZONTAL_ALIGNMENT_LEFT, TARGET_W - 80, true, 2)
	_text(Vector2(TARGET_W - 78, 3), "%d/%d" % [hp, top], Color("ffd7d0"), 11, HORIZONTAL_ALIGNMENT_RIGHT, 70, true, 2)
	view.draw_rect(Rect2(8, 21, TARGET_W - 16, 9), Color(0, 0, 0, 0.7))
	view.draw_rect(Rect2(9, 22, (TARGET_W - 18) * clampf(float(hp) / top, 0, 1), 7), Color("e0392b"))
	if shield > 0:
		view.draw_rect(Rect2(8, 33, TARGET_W - 16, 5), Color(0, 0, 0, 0.7))
		view.draw_rect(Rect2(9, 34, (TARGET_W - 18) * clampf(float(shield) / top, 0, 1), 3), Color("4fb3ff"))






const BATTLE_DIALOG_SIZE: Vector2 = Vector2(700, 200)
const DIALOG_Y_OFFSET: int = 50
var battle_dialog_shown: String = ""
var battle_dialog_at: Vector2 = Vector2.ZERO

func _battle_dialog(battle) -> void :
	battle_dialog_shown = ""
	battle_dialog_at = Vector2.ZERO
	if not battle.has_method("battle_dialog_now") or pack == null:
		return
	var dialog: Dictionary = battle.battle_dialog_now()
	if dialog.is_empty():
		return
	if touch and not bool(dialog.title) and not TouchLq.TouchLayout.tips_on():
		return
	var high: float = BATTLE_DIALOG_SIZE.y * scale
	var top: float = (view.size.y - high) / 2 if bool(dialog.title) else view.size.y - high - DIALOG_Y_OFFSET * scale
	var origin: Vector2 = Vector2(floorf((view.size.x - BATTLE_DIALOG_SIZE.x * scale) / 2), floorf(top))
	var part: Dictionary = pack.effect(str(dialog.image))
	var size: Vector2 = _pack_size(part)
	if size.is_zero_approx():
		return
	var at: Vector2 = Vector2(floorf((BATTLE_DIALOG_SIZE.x - size.x) / 2), BATTLE_DIALOG_SIZE.y - size.y)
	battle_dialog_shown = str(dialog.image)
	battle_dialog_at = origin + at * scale
	_pack_pic(origin, part, at)


func _chat_input() -> void :
	if not view.chat_open:
		return
	chat_frame(view, Vector2(view.size.x / 2 - 232 * scale, view.size.y - (105 + 40) * scale))


func chat_frame(canvas: CanvasItem, origin: Vector2) -> void :
	canvas.draw_set_transform(origin, 0, Vector2(scale, scale))
	for part: Array in [["chat_chatbghead", 6, -3, 0], ["chat_chatbgmid", 116, -3, 313], ["chat_chatbgtail", 429, -3, 0], 
			["chat_iptbghead", 116, 4, 0], ["chat_iptbgmid", 134, 4, 221], ["chat_iptbgtail", 355, 4, 0]]:
		var texture: Texture2D = tex(str(part[0]))
		if texture == null:
			continue
		var at: Vector2 = Vector2(float(part[1]), float(part[2]))
		if int(part[3]) > 0:
			canvas.draw_texture_rect(texture, Rect2(at, Vector2(float(part[3]), texture.get_height())), false)
		else:
			canvas.draw_texture(texture, at)
	var base: Vector2 = Vector2(33, 9 + 12 + 1)
	canvas.draw_string_outline(bold, base, view.chat_channel_name(), HORIZONTAL_ALIGNMENT_CENTER, 52, 12, 2, Color(0, 0, 0, 0.9))
	canvas.draw_string(bold, base, view.chat_channel_name(), HORIZONTAL_ALIGNMENT_CENTER, 52, 12, Color.WHITE)
	rects["chat_channel"] = _screen(origin, Rect2(13, 6, 91, 27))
	rects["chat_text"] = _screen(origin, Rect2(123, 7, 213, 26))

	if view.chat_ui != null:
		view.chat_ui.s = scale
		view.chat_ui.draw_bar(origin, canvas)



func draw_numbers(battle, offset: Vector2, zoom: float) -> void :
	for entry: Dictionary in battle.numbers:
		var frames: float = (battle.clock - float(entry.t)) * 24.0
		var speed: float = 8.0 - 0.5 * frames
		var alpha: float = clampf(speed, 0, 1)
		if alpha <= 0:
			continue
		var rise: float = 8.0 * frames - 0.25 * frames * maxf(0, frames - 1)
		var center: Vector2 = entry.pos + Vector2(float(entry.dx), -40 - rise)
		view.draw_set_transform(offset + center * zoom, 0, Vector2(zoom, zoom))
		_number(str(entry.kind), int(entry.value), alpha)
	view.draw_set_transform(Vector2.ZERO)

func _number(kind: String, value: int, alpha: float) -> void :
	var sheet: Texture2D = tex(NUM_SHEETS.get(kind, "num_harm"))
	if sheet == null:
		return
	var digits: String = str(absi(value))
	var cols: Array[int] = []
	if kind == "harm":
		cols.append(10)
	elif kind == "cure" or kind == "exp":
		cols.append(11)
	for ch in digits:
		cols.append(int(ch))
	var cw: float = sheet.get_width() / float(NUM_COLS)
	var ch_h: float = sheet.get_height()
	var prefix: Texture2D = tex("prefix_crit") if kind == "crit" else (tex("prefix_exp") if kind == "exp" else null)
	var suffix: Texture2D = tex("suffix_exp") if kind == "exp" else null
	var width: float = cols.size() * cw + (prefix.get_width() if prefix != null else 0.0) + (suffix.get_width() if suffix != null else 0.0)
	var x: float = - width / 2
	var tint: Color = Color(1, 1, 1, alpha)
	if prefix != null:
		view.draw_texture(prefix, Vector2(x, - prefix.get_height() / 2.0), tint)
		x += prefix.get_width()
	for col in cols:
		view.draw_texture_rect_region(sheet, Rect2(x, - ch_h / 2, cw, ch_h), Rect2(col * cw, 0, cw, ch_h), tint)
		x += cw
	if suffix != null:
		view.draw_texture(suffix, Vector2(x, - suffix.get_height() / 2.0), tint)



func click(point: Vector2, client) -> bool:
	var battle = client.battle
	if view.size != _drawn_size or view._touch != touch:
		return false
	if _voice_chip_click(point, client):
		return true
	if rects.has("exit") and rects.exit.has_point(point):
		view.ask_exit()
		return true
	if rects.has("set") and rects.set.has_point(point):
		view.toggle_menu()
		return true
	if rects.has("board") and rects.board.has_point(point):
		view.toggle_score_board()
		return true
	if rects.has("relive_buy") and (rects["relive_buy"] as Rect2).has_point(point):
		relive_click(client)
		return true
	for key: String in ["voice_spk", "voice_mic"]:
		if rects.has(key) and (rects[key] as Rect2).has_point(point):
			if voice_ui and VoiceClient.usable():
				var voice: Object = VoiceClient.shared()
				voice.attach(client)
				if key == "voice_spk":
					voice.cycle_speaker()
				else:
					voice.toggle_mic()
			return true


	if view.chat_ui != null and view.chat_ui.click(point):
		return true
	if not view.chat_open and rects.has("chat") and rects.chat.has_point(point):
		view.open_chat()
		return true
	for i in range(3):
		var key: String = "sig%d" % (i + 1)
		if rects.has(key) and rects[key].has_point(point):
			arm_signal(i + 1, battle)
			return true
	var on_map: Vector2 = minimap_to_world(point)
	if on_map.x < 0:
		if look_press(point, battle):
			return true
		for id: int in avatar_rects:
			if avatar_rects[id].has_point(point):

				if armed == 0:
					avatar_pick = id
				return true

	if armed > 0 and not (on_map.x >= 0 and int(battle.enter_type) == ENTER_LOOK):
		var dest: Vector2 = on_map if on_map.x >= 0 else view.screen_to_world(point)
		client.send_signal(armed, dest)
		signal_ready = battle.clock + SIGNAL_CD
		armed = 0
		return true
	if on_map.x >= 0:
		if battle.look and not battle.look_free:
			battle.look_set_free(true)
		map_move(point)
		return true
	return false


func arm_signal(kind: int, battle) -> void :
	if battle.look:
		return
	if battle.clock < signal_ready:
		return
	armed = 0 if armed == kind else kind

func _bottom_origin() -> Vector2:
	scale = layout_scale()
	return Vector2(view.size.x / 2 - 266 * scale, view.size.y - 76 * scale - safe_in.w)


func cell_slot(battle, ordinal: int) -> int:
	var slot: int = [10 if battle.skills.has(10) else -1, 1, 2, 13 if battle.skills.has(13) else 4, 12][ordinal]
	return slot if slot >= 0 and battle.skills.get(slot) != null else -1

func cell_rect(ordinal: int) -> Rect2:
	var rect: Rect2 = Rect2(394, 30, 40, 40) if ordinal == 4 else Rect2(CELL_X[ordinal], 20, 50, 50)
	return _screen(_bottom_origin(), rect)


func skill_at(point: Vector2, battle, margin: float = 0) -> int:
	if touch:
		return -1
	for ordinal in range(5):
		var slot: int = cell_slot(battle, ordinal)
		if slot >= 0 and cell_rect(ordinal).grow(margin * scale).has_point(point):
			return -1 if cell_blocked(battle, slot) else slot
	return -1



func cell_hit(point: Vector2, battle, margin: float = 0) -> int:
	if touch or not battle.tanks.has(battle.self_id):
		return -1
	for ordinal in range(5):
		if (ordinal < 4 or battle.skills.has(12)) and cell_rect(ordinal).grow(margin * scale).has_point(point):
			return ordinal
	return -1
