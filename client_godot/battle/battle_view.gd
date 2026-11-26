extends Control
const SelfMoveRule = preload("self_move_rule.gd")
const Mp = preload("res://battle/mp_use.gd")
const Controls = preload("battle_input.gd")
const SkillCast = preload("skill_cast.gd")
const Text = preload("../i18n.gd")
const Fx = preload("battle_fx.gd")
const Hud = preload("battle_hud.gd")
const TouchLq = preload("touch_lq.gd")
const TouchLife = preload("touch_life.gd")
const TouchGfx = preload("touch_gfx.gd")
const TouchCam = preload("touch_cam.gd")
const BattleSound = preload("battle_sound.gd")
const Settings = preload("res://settings.gd")
const BattleSettings = preload("battle_settings.gd")
const BattleSettingsPanel = preload("battle_settings_panel.gd")
const Love = preload("../ui/love.gd")
const BattleLoading = preload("battle_loading.gd")
const FlaPlayer = preload("../ui/fla_player.gd")
const DOOR_KEY: String = "fla/bst"
const DOOR_STAGE: Vector2 = Vector2(1920, 1080)
const ExitAsk = preload("../ui/exit_ask.gd")
const PayLife = preload("../ui/pay_life.gd")
const ResultMv = preload("result_mv.gd")
const PvpResult = preload("pvp_result.gd")
const ClanResult = preload("event_clan_result.gd")
const HappyResult = preload("happy_result.gd")
const PveResult = preload("pve_result.gd")
const ScoreBoard = preload("score_board.gd")
const BattleChat = preload("battle_chat.gd")
const Emotes = preload("../ui/chat_emotes.gd")
const NameStyles = preload("../ui/name_styles.gd")
const GRID_HP: float = 500.0

const TECH_ICONS: Array[String] = ["technique_kill", "technique_allround", "technique_assist"]
const GUIDE_BLUE: Color = Color("02f0ff")
const MAPT_PVE_SOLO: int = 4
const LEVEL_RING: int = 15001
const RingMesh = preload("ring_mesh.gd")
var _p3: RingMesh = RingMesh.new()
var client: Node
var pack: Node
var controls: Controls = Controls.new()
var _fx: Fx = Fx.new(self)
var _textures: Dictionary = {}
var _art: Dictionary = {}
var _face: Dictionary = {}
var _body_clock: Dictionary = {}
var _loaded: bool = false

var _fire_tex: Texture2D = null
var _map_id: int = -1
var _map_bundled: bool = false


const DM_ASK_MS: int = 5000
const DM_TELL_MS: int = 40000
var _dm_at: int = 0
var _dm_ask: int = -100000
var _dm_told: int = -1
var _camera: Vector2 = Vector2.ZERO
var _zoom: float = 1.0
var camera_zoom: float = 1.0


var look_zoom: float = 1.0
var _look_center: Vector2 = Vector2(-1, -1)
var _look_begun: int = -1
var _look_pressing: bool = false
var _look_moved: bool = false
var _look_press_at: Vector2 = Vector2.ZERO
var _look_last: Vector2 = Vector2.ZERO
const LOOK_PAN: float = 1100.0
const LOOK_STEP_MAX: float = 0.05
const LOOK_DRAG: float = 6.0
const LOOK_ZOOM_MAX: float = 2.0
var _tint: Color = Color.WHITE
var _spin: float = 0.0
var _alpha: float = 1.0

var _watch_center: Vector2 = Vector2.ZERO
var _watch_seen_id: int = 0
var _watch_seen: Vector2 = Vector2.ZERO
var _watch_jump: int = -1
var _map_press: bool = false
var _map_touch: int = -1
var _shake: Array = []
var _shake_pos: Vector2 = Vector2.ZERO
var _shake_from: float = 0.0
var _shake_t: float = 0.0
var _casting: bool = false
var _cast_time: float = 0.0
var _cast_tick: int = 0
var _cast_sent: Vector2 = Vector2(-1000, -1000)
const TANK_SORT: int = 3
const BUSH_BUFF: int = 16000

const SHOW_PLAIN: Dictionary = {"scale": 1.0, "tint": Color.WHITE, "spin": 0.0, "still": false}
const BattleState = preload("res://battle/battle_state.gd")
const LIFT_BOB: = 5.0
const LIFT_TURNS: = 1.0
const NO_RULES: Array = [0, 0, 0, 0]
const NPC_PARTS: Array = ["", "-base", "-gun"]


const NPC_SWF_ANIM: Array = ["base1.swf", "base2.swf", "base1_break1.swf", "base1_break2.swf", "base1_break3.swf", 
	"base2_break1.swf", "base2_break2.swf", "base2_break3.swf"]
var _my_camp: int = 0
var _npc_meta_src: Dictionary = {}
var _npc_meta_rows: Dictionary = {}
var _npc_tex_src: Dictionary = {}
var _npc_tex: Dictionary = {}
var _npc_pair: Dictionary = {}
var _npc_anim: Dictionary = {}
var _npc_anim_pack: Variant = null
const PH_STARTER: String = "10000001"
var _ph_pack: Variant = null
var _ph_memo: Dictionary = {}
var _ph_turrets: Dictionary = {}
var _offset: Vector2 = Vector2.ZERO
var _time: float = 0.0
var _font: Font = preload("res://assets/fonts/flash_ui_bold.tres")
var _bubble_box: StyleBoxFlat = StyleBoxFlat.new()
var _name_widths: Dictionary = {}
var _title_font: Font = preload("res://assets/fonts/flash_ui_bold.tres")
var _hud: Hud = Hud.new(self, _font, _title_font)
var _touch: bool = false
var _tlife: TouchLife = TouchLife.new()
var _gfx: TouchGfx = TouchGfx.new()
var _joystick: int = -1
var _fire_touch: int = -1
var _aim_touch: int = -1
var _voice_touch: int = -1
var _stick: Vector2 = Vector2.ZERO
var _has_touch_aim: bool = false
var _lq: TouchLq = TouchLq.new()
var _tcam: TouchCam = TouchCam.new()
var _leave: Button
var exit_ask: Control
var pay_ask: Control
var _honor_top: bool = false
var result_mv: Control
var happy_result: Control
var clan_result: Control
var pve_result: Control
var pvp_result: Control
var score_board: Control
var _exit: Button

var _settings: BattleSettingsPanel
var _loading: BattleLoading
var _door: FlaPlayer = null
var _door_for: int = 0
var _sound: BattleSound = BattleSound.new()
var _agree: Button
var _deny: Button
var _vote_end: float = 0.0
var _vote_total: float = 0.0
var profile_draw: bool = false

var chat_open: bool = false
var chat_channel: int = 64
var chat_loading: bool = false
var _chat_input: LineEdit
var chat_ui: Control
var _emotes: Node
var _emote_begun: int = -1
var _mw_begun: int = -1
var draw_samples: Array[float] = []
const StaticLayer = preload("static_layer.gd")
var _g2: StaticLayer = StaticLayer.new()

func _ready() -> void :
	clip_contents = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	_touch = TouchGfx.touch_screen()

	_emotes = Emotes.new()
	_emotes.name = "ChatEmotes"
	_emotes.client = client
	add_child(_emotes)
	chat_ui = BattleChat.new()
	chat_ui.name = "BattleChat"
	chat_ui.view = self
	chat_ui.emotes = _emotes
	add_child(chat_ui)

	score_board = ScoreBoard.new()
	score_board.client = client
	score_board.pack = pack
	score_board.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(score_board)
	_loading = BattleLoading.new()
	_loading.hud = _hud
	add_child(_loading)
	_leave = Button.new()
	_leave.focus_mode = Control.FOCUS_NONE
	_leave.text = "Rời trận"
	_leave.position = Vector2(12, 12)
	_leave.custom_minimum_size = Vector2(150, 40)
	_leave.pressed.connect( func() -> void : controls.clear();client.leave_battle())
	_tone(_leave, true)
	add_child(_leave)

	_exit = Button.new()
	_exit.focus_mode = Control.FOCUS_NONE
	_exit.text = "Về sảnh"
	_exit.visible = false
	_exit.pressed.connect( func() -> void : controls.clear();client.exit_battle_to_lobby())
	_tone(_exit, false)
	add_child(_exit)
	_agree = _vote_button( func() -> void : client.vote_surrender(true))
	_deny = _vote_button( func() -> void : client.vote_surrender(false))
	_chat_input = LineEdit.new()
	_chat_input.visible = false
	_chat_input.max_length = 60
	_chat_input.flat = true
	_chat_input.context_menu_enabled = false
	_chat_input.add_theme_color_override("font_color", Color.WHITE)
	_chat_input.add_theme_font_override("font", _font)
	for state: String in ["normal", "focus", "read_only"]:
		_chat_input.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	_chat_input.text_submitted.connect( func(_text: String) -> void : submit_chat())
	_chat_input.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			close_chat()
			_chat_input.accept_event())
	add_child(_chat_input)
	chat_ui.attach(_chat_input)
	_settings = BattleSettingsPanel.new()
	_settings.view = self
	add_child(_settings)

	result_mv = ResultMv.new()
	result_mv.client = client
	result_mv.pack = pack
	result_mv.hud = _hud
	result_mv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(result_mv)
	result_mv.shake.connect(_result_shake)

	pvp_result = PvpResult.new()
	pvp_result.client = client
	pvp_result.pack = pack
	pvp_result.buttons = {"exit": _exit, "back": _leave}
	pvp_result.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pvp_result)
	move_child(pvp_result, _leave.get_index())
	clan_result = ClanResult.new()
	clan_result.client = client
	clan_result.pack = pack
	clan_result.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(clan_result)
	move_child(clan_result, _leave.get_index() + 1)
	happy_result = HappyResult.new()
	happy_result.client = client
	happy_result.pack = pack
	happy_result.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(happy_result)
	move_child(happy_result, _leave.get_index() + 1)
	pve_result = PveResult.new()
	pve_result.client = client
	pve_result.pack = pack
	pve_result.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pve_result)
	move_child(pve_result, _leave.get_index() + 1)

	pay_ask = PayLife.new()
	pay_ask.client = client
	pay_ask.pack = pack
	pay_ask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pay_ask)

	exit_ask = ExitAsk.new()
	exit_ask.client = client
	exit_ask.pack = pack
	exit_ask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(exit_ask)
	visibility_changed.connect(reset_input)

func _small_button(text: String, action: Callable) -> Button:
	var button: Button = Button.new()
	button.focus_mode = Control.FOCUS_NONE
	button.text = text
	button.custom_minimum_size = Vector2(120, 40)
	button.visible = false
	button.pressed.connect(action)
	_tone(button, false)
	add_child(button)
	return button


func _tone(button: Button, primary: bool) -> void :
	var fill: Color = Color("f39020") if primary else Color("1f78d0")
	var edge: Color = Color("fff3c0") if primary else Color("a6e6ff")
	var ink: Color = Color("fffdf2")
	for state: String in ["normal", "hover", "pressed", "disabled"]:
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = fill
		if state == "hover":
			box.bg_color = fill.lightened(0.14)
		elif state == "pressed":
			box.bg_color = fill.darkened(0.12)
		elif state == "disabled":
			box.bg_color = Color(fill.darkened(0.45), 0.85)
		box.border_color = Color(edge, 0.85 if state != "disabled" else 0.3)
		box.set_border_width_all(2)
		box.set_corner_radius_all(9)
		box.anti_aliasing = true
		box.content_margin_left = 14.0
		box.content_margin_right = 14.0
		button.add_theme_stylebox_override(state, box)
	button.add_theme_font_override("font", _font)
	for name: String in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		button.add_theme_color_override(name, ink)
	button.add_theme_color_override("font_disabled_color", Color(ink, 0.5))
	button.add_theme_color_override("font_outline_color", Color("5a2200") if primary else Color("08295a"))
	button.add_theme_constant_override("outline_size", 6 if primary else 4)

func open_chat() -> void :
	if client == null or (client.battle.ended and not honor_chat()):
		return
	controls.clear()
	if client != null and client.has_method("kphim1_release_keys"):


		client.kphim1_release_keys(true)
	chat_open = true
	_chat_input.visible = true
	_layout_chat()
	_chat_input.grab_focus()
	_emote_refresh()


func _emote_refresh() -> void :
	if _emotes == null or client == null or not ("config" in client):
		return
	_emotes.client = client
	_emotes.refresh()



func honor_chat() -> bool:
	return client != null and client.battle.ended and result_mv != null and result_mv.playing()


func _honor_layer(on: bool) -> void :
	if on == _honor_top or chat_ui == null:
		return
	_honor_top = on
	if on:
		move_child(chat_ui, result_mv.get_index())
		move_child(_chat_input, chat_ui.get_index())
	else:
		move_child(_chat_input, _settings.get_index())
		move_child(chat_ui, _emotes.get_index() + 1)

func close_chat() -> void :
	chat_open = false
	_chat_input.visible = false
	if chat_ui != null:
		chat_ui.picker = false
	if visible and _chat_input.has_focus():
		grab_focus()





func submit_chat() -> void :
	var text: String = _chat_input.text.strip_edges()
	if text.is_empty():
		if not (chat_loading or _loading.visible):
			_chat_input.text = ""
			if chat_ui != null:
				chat_ui.tokens.clear()
			close_chat()
		return
	if _emotes != null and chat_ui != null:
		text = _emotes.expand(text, chat_ui.tokens)
		var refused: String = _emotes.refusal(text)
		if not refused.is_empty():
			client.battle.chat_rejected(refused)
			return
	if client.send_battle_chat(text, chat_channel, honor_chat()):
		_chat_input.text = ""
		if chat_ui != null:
			chat_ui.tokens.clear()
		close_chat()
		if _loading.visible:
			loading_chat_focus()



func _loading_chat() -> void :
	if _loading.visible:
		chat_loading = true
		_chat_input.visible = true
	elif chat_loading:
		chat_loading = false
		close_chat()


func chat_bar_shown() -> bool:
	return chat_open or chat_loading

func loading_chat_focus() -> void :
	_chat_input.visible = true
	_chat_input.grab_focus()

func cycle_chat_channel() -> void :
	chat_channel = 32 if chat_channel == 64 else 64
	if chat_open:
		_chat_input.grab_focus()

func chat_channel_name() -> String:
	return client.battle.CHAT_NAMES.get(chat_channel, "")

func _layout_chat() -> void :
	var rect: Rect2 = _hud.rects.get("chat_text", Rect2())
	if rect.size.x <= 0:
		var s: float = _hud.layout_scale()
		rect = Rect2(Vector2(size.x / 2 - 108 * s, size.y - 138 * s), Vector2(228, 26) * s)
	_chat_input.position = rect.position
	_chat_input.size = rect.size
	_chat_input.add_theme_font_size_override("font_size", maxi(10, roundi(13 * _hud.scale)))

func reset_input() -> void :
	controls.clear()
	_joystick = -1
	_fire_touch = -1
	_aim_touch = -1
	_map_touch = -1
	_hud.map_release()
	if _voice_touch >= 0:
		_voice_touch = -1
		_hud.voice_hold_end()
	_stick = Vector2.ZERO
	_has_touch_aim = false
	_lq.reset()
	_tcam.drop_fingers()
	if visible:
		grab_focus()








func _door_tick() -> void :
	var battle = client.battle
	if pack == null or not battle.active or battle.ended:
		_door_stop()
		return
	if not battle.started:
		pack.effect(DOOR_KEY, true)
		return
	if not _loading.visible and int(battle.begun) != _door_for:
		_door_for = int(battle.begun)
		_door_play()
	if _door != null:
		_door.scale = size / DOOR_STAGE

func _door_play() -> void :
	_door_stop()
	var effect: Dictionary = pack.effect_cached(DOOR_KEY)
	if effect.is_empty() or not FlaPlayer.valid(effect.get("data")):
		return
	var player: FlaPlayer = FlaPlayer.new()
	if player.add_clip(effect) < 0:
		player.free()
		return
	player.event.connect( func(name: String) -> void :
		if name == "mc_complete":
			_door_stop())
	player.scale = size / DOOR_STAGE
	_door = player
	add_child(player)
	move_child(player, _loading.get_index() + 1)

func _door_stop() -> void :
	if _door == null:
		return
	if _door.get_parent() == self:
		remove_child(_door)
	_door.queue_free()
	_door = null


func door_playing() -> bool:
	return _door != null

func _mw_new_battle() -> void :
	_mw_begun = int(client.battle.begun)
	if chat_open:
		close_chat()
	if _settings != null and _settings.visible:
		_settings.visible = false
	reset_input()

func _notification(what: int) -> void :
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		reset_input()
	elif what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		reset_input()
	if what == NOTIFICATION_WM_WINDOW_FOCUS_OUT and client != null and not _touch and client.has_method("kphim1_release_keys"):


		client.kphim1_release_keys()
	if what == NOTIFICATION_WM_MOUSE_EXIT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_cl_blur()

func load_assets() -> void :
	var map = client.battle.map
	if _map_id != map.id or _map_bundled != map.bundled:

		_textures = {}
		_map_bundled = map.bundled
		if map.bundled:
			for name: String in map.document.visual.images:
				_textures[name] = load("res://assets/map4/" + str(map.document.visual.images[name].file))
		elif pack != null:
			_textures = pack.map_textures(map.id)
		if pack != null:
			pack.ainpc_row(0)
			pack.load_tips()
		_map_id = map.id
		_face.clear()
	if _loaded:
		return
	if ResourceLoader.exists("res://assets/fx/fire.png"):
		_fire_tex = load("res://assets/fx/fire.png")
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/tanks.json"))
	for external: String in registry:
		_art[external] = {}
		for part: String in registry[external]:
			var filename: String = "res://assets/" + str(registry[external][part])
			var data: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(filename))
			var pages: Array[Texture2D] = []
			for page: Dictionary in data.pages:
				pages.append(load(filename.get_base_dir() + "/" + str(page.file)))
			_art[external][part] = {"data": data, "pages": pages}
	_loaded = true

func _process(delta: float) -> void :
	if not visible or client == null or client.state != "battle":
		_door_stop()
		if _loading.visible:
			_loading.visible = false
		_loading_chat()
		if pvp_result.visible:
			pvp_result.visible = false
			_dress(false)
		if clan_result.visible:
			clan_result.visible = false
		if happy_result.visible:
			happy_result.visible = false
		if pve_result.visible:
			pve_result.visible = false
		if score_board.visible:
			score_board.hide_board()
		if chat_ui != null and chat_ui.visible:
			chat_ui.visible = false
		return
	if pack != null and not client.battle.face_priority.is_valid():
		client.battle.face_priority = pack.face_priority
	if pack != null and not client.battle.npc_open.is_valid():
		client.battle.npc_open = pack.npc_open
	_tick_faces(client.battle)
	if int(client.battle.begun) != _mw_begun:
		_mw_new_battle()
	_tlife.tick(self, delta)
	_gfx.tick(self, delta)
	_time += delta
	_loading.client = client
	_loading.pack = pack
	result_mv.client = client
	result_mv.pack = pack
	pvp_result.client = client
	pvp_result.pack = pack
	score_board.client = client
	score_board.pack = pack
	pvp_result.visible = _board()
	clan_result.client = client
	clan_result.pack = pack
	clan_result.visible = ClanResult.wanted(client) and not (result_mv != null and result_mv.playing())
	happy_result.client = client
	happy_result.pack = pack
	happy_result.visible = HappyResult.wanted(client) and not (result_mv != null and result_mv.playing())
	pve_result.client = client
	pve_result.pack = pack
	pve_result.visible = PveResult.wanted(client) and not (result_mv != null and result_mv.playing())
	_loading.visible = client.battle.active and ( not client.battle.started or _loading.hold()) and not client.battle.ended and (client.battle.supported() or client.map_fetch)
	_loading_chat()
	_door_tick()
	if client.battle.supported():
		load_assets()
		var center: Vector2 = client.battle.map.extent / 2
		var me: Dictionary = client.battle.tanks.get(client.battle.self_id, {})
		if not me.is_empty():
			center = _follow(me, client.battle)
		if not _touch and not client.battle.look:
			center = _cl_frame(delta, me, client.battle, center)
		if _touch and not client.battle.look:
			center = _tcam.center(self, client.battle, delta, center)
		else:
			center = _hud.look_center(center, client.battle)
		if client.battle.look:
			center = _look_camera(delta, client.battle)

		client.battle.move_lock = not me.is_empty() and not me.dead and (_show_state(me).tint != Color.WHITE or _fly(me, client.battle) != Vector3(0, 0, 1))


		_zoom = TouchLq.zoom_for(size, client.battle.map.extent) if _touch else _hud.layout_scale() * camera_zoom
		if _touch and not client.battle.look:
			_zoom = _tcam.zoom(size, client.battle.map.extent)
		if client.battle.look and not _touch:
			look_zoom = clampf(look_zoom, look_min_zoom(), LOOK_ZOOM_MAX)
			_zoom = _hud.layout_scale() * look_zoom
		var half: Vector2 = size / (2 * _zoom)
		var extent: Vector2 = client.battle.map.extent


		_camera = Vector2(clampf(center.x, minf(half.x, extent.x / 2), maxf(extent.x - half.x, extent.x / 2)), clampf(center.y, minf(half.y, extent.y / 2), maxf(extent.y - half.y, extent.y / 2)) if _touch else clampf(center.y, half.y, maxf(extent.y - half.y, half.y)))
		if _touch and not client.battle.look:
			_camera = TouchCam.clamp_center(center, half, extent, _tcam.edge_pad(half))
		_cl_center = _camera
		if client.battle.look:
			_look_center = _camera
		for request: Dictionary in client.battle.shakes:
			_shake_request(request)
		client.battle.shakes.clear()

		_offset = size / 2 - _camera * _zoom + _shake_now(delta) * (_zoom if _touch else _hud.layout_scale())
		if _touch:
			_lq.frame(self, client.battle, controls, center)
		var movement: Vector2 = Vector2.ZERO if chat_open else _stick if _joystick >= 0 else Vector2(
			int(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - int(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), 
			int(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - int(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
		controls.direction = Controls.direction_for(movement)
		if not _touch:
			controls.aim = screen_to_world(get_local_mouse_position())
		controls.touch = _touch
		client.auto_aim = controls.aim
		controls.hover_tank = _hud.hover_tank

		_hud.update_hover(get_local_mouse_position(), client.battle, not _touch and not exit_ask.visible and not pay_ask.visible and not _settings.visible
			and not score_board.visible and not _loading.visible and not pvp_result.visible and not happy_result.visible and not clan_result.visible and not pve_result.visible)

		controls.tick(delta, client, pack)
		_timing_cast(me, delta)
		_sound.tick(client.battle, pack, _fx, _camera, half, _loading.visible)
	_layout_buttons()
	_honor_layer(honor_chat())
	if chat_open or _loading.visible:
		if client.battle.ended and not honor_chat():
			close_chat()
		else:
			_layout_chat()
	if chat_ui != null:
		chat_ui.visible = true
		if int(client.battle.begun) != _emote_begun:
			_emote_begun = int(client.battle.begun)
			_emote_refresh()
		chat_ui.sync(delta)
	queue_redraw()


func _draw_opened(battle) -> void :
	if not _fx.ready():
		return
	for door: Dictionary in battle.opened:
		var key: String = pack.npc_open(int(door.template))
		var asset: Dictionary = pack.effect(key) if not key.is_empty() else {}
		if not asset.is_empty():
			_fx.frame(asset, mini(int((battle.clock - float(door.t0)) * Fx.FPS), asset.data.frames.size() - 1), door.pos, 0.0)


func _draw_wrecks(battle) -> int:
	var drawn: int = 0
	if not _fx.ready():
		return drawn
	for wreck: Dictionary in battle.wrecks:
		var key: String = pack.npc_left(int(wreck.template), _my_camp == 1)
		var asset: Dictionary = pack.effect(key) if not key.is_empty() else {}
		if not asset.is_empty():
			_fx.frame(asset, 0, wreck.pos, 0.0)
			drawn += 1
	return drawn


func _draw_sprays(battle) -> int:
	var drawn: int = 0


	if not battle.sprays.is_empty():
		draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	for mark: Dictionary in battle.sprays:
		var texture: Texture2D = pack.picture(pack.spray_picture(int(mark.id)))
		if texture != null:
			var alpha: float = clampf(1.0 - (float(mark.age) - float(mark.life)) / float(battle.SPRAY_FADE), 0.0, 1.0)
			draw_texture(texture, (mark.pos as Vector2) - texture.get_size() / 2, Color(1, 1, 1, alpha))
			drawn += 1
	return drawn



func _shake_request(request: Dictionary) -> void :
	if pack == null or not Settings.on("skill_fx") or _gfx.no_shake():
		return
	var kind: int = 0
	if request.has("skill"):
		kind = pack.skill_shake(int(request.skill), bool(request.ready))
	elif request.has("bullet"):
		_fx.pack = pack
		kind = pack.shake_of("bullets", _fx.exhibit_id(request.bullet, client.battle)) if _fx.ready() else 0
	elif request.has("ainpc"):
		kind = pack.shake_of("ainpcs", int(request.ainpc))
	elif Rect2(Vector2.ZERO, size).has_point(_offset + (request.pos as Vector2) * _zoom):

		kind = pack.shake_of("npcs", int(request.npc)) if request.has("npc") else pack.shake_of("items", int(request.item))
	if kind >= 3:
		if int(request.owner) != client.battle.self_id:
			return
		kind -= 2
	if kind == 1 or kind == 2:
		_shake = shake_steps(kind == 2)
		_shake_pos = Vector2.ZERO
		_shake_from = 0.0
		_shake_t = 0.0


func _result_shake() -> void :
	if pack == null or not Settings.on("skill_fx"):
		return
	_shake = shake_steps(false)
	_shake_pos = Vector2.ZERO
	_shake_from = 0.0
	_shake_t = 0.0



static func shake_steps(big: bool) -> Array:
	var mark: float = 1.0 if randf() > 0.5 else -1.0
	var first: float = 10.0 if big else 5.0
	var a: float = mark * (first + 4.0 * randf())
	var b: float = mark * (first + 4.0 * randf())
	if big:
		var steps: Array = [[0.08, 0, a], [0.08, 1, b], [0.075, 0, 0.0], [0.075, 1, 0.0]]
		for amp: float in [8.0, 6.0, 4.0, 2.0]:
			steps.append_array(_shake_pair(0.05, amp, amp))
		return steps
	return _shake_pair(0.05, a, b) + _shake_pair(0.04, 2.0, 2.0)

static func _shake_pair(time: float, x: float, y: float) -> Array:
	if randf() > 0.5:
		return [[time, 0, x], [time, 1, y], [time, 0, 0.0], [time, 1, 0.0]]
	return [[time, 0, x], [time, 0, 0.0], [time, 1, y], [time, 1, 0.0]]


func _shake_now(delta: float) -> Vector2:
	if _shake.is_empty():
		return Vector2.ZERO
	_shake_t += delta
	while not _shake.is_empty() and _shake_t >= float(_shake[0][0]):
		_shake_t -= float(_shake[0][0])
		_shake_pos[int(_shake[0][1])] = float(_shake[0][2])
		_shake.pop_front()
		if not _shake.is_empty():
			_shake_from = _shake_pos[int(_shake[0][1])]
	if _shake.is_empty():
		_shake_pos = Vector2.ZERO
		return Vector2.ZERO
	var left: float = 1.0 - _shake_t / float(_shake[0][0])
	_shake_pos[int(_shake[0][1])] = lerpf(_shake_from, float(_shake[0][2]), 1.0 - left * left)
	return _shake_pos




func _timing_cast(me: Dictionary, delta: float) -> void :
	if me.is_empty() or me.dead or pack == null or _buff_rules(me)[2] <= 0:
		_casting = false
		return
	var tick: int = 1
	if _casting:
		_cast_time += delta
		tick = int(_cast_time * 1000.0 / 60.0)
	else:
		_casting = true
		_cast_time = 0.0
		_cast_tick = 0
	if tick == _cast_tick:
		return
	_cast_tick = tick
	var pos: Vector2 = me.pos
	var angle: float = float(me.get("cannon_rot", pos.angle_to_point(controls.aim)))
	var dest: Vector2 = Vector2(int(pos.x + cos(angle) * 2000.0), int(pos.y + sin(angle) * 2000.0))
	if dest != _cast_sent:
		_cast_sent = dest
		client.cache_skill_dest(dest)



func _buff_rules(obj: Dictionary) -> Array:
	if pack == null or obj.buffs.is_empty():
		return NO_RULES
	var rules: Array = [0, 0, 0, 0]
	for buff: Dictionary in obj.buffs.values():
		var row: Array = pack.buff_rule(int(buff.get("m_nBuffTpltId", 0)))
		for i in range(row.size()):
			if int(row[i]) > 0:
				rules[i] = int(row[i])
	return rules




func _cannon_angle(tank: Dictionary, want: float, rule: Array) -> float:
	var held: bool = rule[1] > 0 and int(tank.id) == client.battle.self_id
	var dt: float = _time - float(tank.get("cannon_at", _time))
	tank.cannon_at = _time
	var shots: int = int(tank.get("shots", 0))
	if tank.has("still_at") and tank.has("cannon_rot"):
		pass
	elif not tank.has("cannon_rot") or (rule[2] <= 0 and not held):
		tank.cannon_rot = want
	elif shots != int(tank.get("cannon_shots", 0)):
		tank.cannon_rot = (tank.pos as Vector2).angle_to_point(tank.aim)
	elif not held:
		tank.cannon_rot = rotate_toward(float(tank.cannon_rot), want, deg_to_rad(float(rule[2])) * dt)
	tank.cannon_shots = shots
	return float(tank.cannon_rot)



func _draw_speed(obj: Dictionary, moving: bool, rule: Array) -> void :
	if rule[3] <= 0 or not moving:
		return
	var asset: Dictionary = pack.effect(pack.tank_speed())
	if asset.is_empty():
		return
	var face: Dictionary = _face.get(int(obj.id), {})
	var angle: float = _face_now(face) if not face.is_empty() else posmod(int(obj.direction) - 1, 8) * PI / 4
	_fx.frame(asset, int(_time * Fx.FPS) % asset.data.frames.size(), obj.pos, angle + _spin, Vector2.ZERO, Color(1, 1, 1, _alpha))





func _follow(me: Dictionary, battle) -> Vector2:
	if not me.dead:
		_watch_center = _free_box(me.pos, battle)
		_watch_seen_id = int(battle.self_id)
		_watch_seen = me.pos
		_watch_jump = int(battle.scroll_jump)
		return _watch_center
	_free_box_stamp = []
	var id: int = int(battle.scroll_id)
	var tank: Dictionary = battle.tanks.get(id, {})
	if _watch_jump != int(battle.scroll_jump):
		_watch_jump = int(battle.scroll_jump)
		if not tank.is_empty():
			_watch_center = tank.pos
	elif not tank.is_empty() and id == _watch_seen_id and tank.pos != _watch_seen:
		_watch_center = tank.pos
	if not tank.is_empty():
		_watch_seen = tank.pos
	_watch_seen_id = id
	return _watch_center






const FREE_BOX: Vector2 = Vector2(200, 50)
var _free_box_at: Vector2 = Vector2.ZERO
var _free_box_stamp: Array = []
func _free_box(pos: Vector2, battle) -> Vector2:
	var stamp: Array = [int(battle.begun), int(battle.self_spawns)]
	if stamp != _free_box_stamp or battle.look or _hud._map_hold or (_tcam.free if _touch else cam_free):
		_free_box_stamp = stamp
		_free_box_at = pos
	_free_box_at = free_box(_free_box_at, pos)
	return _free_box_at


static func free_box(at: Vector2, pos: Vector2) -> Vector2:
	var h: Vector2 = FREE_BOX / 2
	return Vector2(clampf(at.x, pos.x - h.x, pos.x + h.x), clampf(at.y, pos.y - h.y, pos.y + h.y))

func _layout_buttons() -> void :
	var ended: bool = client.battle.ended

	var film: bool = ended and result_mv != null and result_mv.playing()
	_leave.visible = (ended and not film) or _loading.stuck()
	_exit.visible = ended and not film and client.pvp_result()
	if pve_result != null and pve_result.visible:
		_leave.visible = false
	if ended:
		var panel: Rect2 = _result_rect()
		_leave.text = "Về sảnh" if client.solo_battle() else "Về phòng"
		_leave.size = Vector2(220, 48)
		_leave.position = Vector2(panel.get_center().x - 110, panel.end.y - 64)
		if client.pvp_result():
			_exit.size = _leave.size
			_exit.position = Vector2(panel.get_center().x - 230, panel.end.y - 64)
			_leave.position.x = panel.get_center().x + 10
	else:
		_leave.text = "Rời trận"
		_leave.size = Vector2(150, 40)
		_leave.position = Vector2(12, 12)
	_dress(ended and not film and client.pvp_result())
	var battle = client.battle
	var now: float = battle.now_seconds()
	var voting: bool = not ended and not battle.vote.is_empty() and battle.vote.end > now and not battle.vote.mine and not battle.vote.get("voted", false)
	_agree.visible = voting
	_deny.visible = voting
	_place_vote_button(_agree, VOTE_AGREE_X)
	_place_vote_button(_deny, VOTE_DENY_X)


func _board() -> bool:
	return client != null and client.pvp_result() and not (result_mv != null and result_mv.playing())



func _dress(board: bool) -> void :
	for button: Button in [_leave, _exit]:
		button.modulate.a = 0.0 if board else 1.0
		button.clip_text = board
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if board else Control.CURSOR_ARROW
	_leave.custom_minimum_size = Vector2.ZERO if board else Vector2(150, 40)
	if not board:
		return
	pvp_result.size = size
	var exit: Rect2 = pvp_result.button_rect("exit")
	var back: Rect2 = pvp_result.button_rect("back")
	_exit.position = exit.position
	_exit.size = exit.size
	_leave.position = back.position
	_leave.size = back.size

func _result_rect() -> Rect2:
	var rows: int = maxi(1, client.battle.outcome.get("m_tankVec", []).size())
	var panel_size: Vector2 = Vector2(minf(size.x - 24, 760), minf(size.y - 24, 196 + rows * 34))
	return Rect2((size - panel_size) / 2, panel_size)

func screen_to_world(point: Vector2) -> Vector2:
	return (point - _offset) / _zoom




func _look_camera(delta: float, battle) -> Vector2:
	if _look_begun != int(battle.begun):
		_look_begun = int(battle.begun)
		look_zoom = 1.0
		_look_center = battle.map.extent / 2
		_look_pressing = false
		_look_moved = false
	if _hud.map_dragging():
		_look_center = _hud._map_center
		return _look_center
	var target: Dictionary = battle.look_target_tank()
	if not target.is_empty():
		_look_center = target.pos
		return _look_center
	if battle.look_free and not chat_open and not _hud.look_blocked(battle)\
	and not Input.is_key_pressed(KEY_CTRL) and not Input.is_key_pressed(KEY_ALT):
		var pan: Vector2 = Vector2(
			int(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - int(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)), 
			int(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - int(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)))
		if pan != Vector2.ZERO:
			_look_center += pan.normalized() * LOOK_PAN * Settings.pan_scale() / look_zoom * minf(delta, LOOK_STEP_MAX)
	return _look_center


func look_min_zoom() -> float:
	if client == null:
		return 1.0
	var extent: Vector2 = client.battle.map.extent
	var unit: float = _hud.layout_scale()
	if extent.x <= 0 or extent.y <= 0 or unit <= 0:
		return 1.0
	var world: Vector2 = size / unit
	return maxf(0.5, minf(1.0, maxf(world.x / extent.x, world.y / extent.y)))


func look_step_zoom(direction: int) -> void :
	var low: float = look_min_zoom()
	var next: float = roundf((look_zoom + direction * 0.1) * 10.0) / 10.0
	if direction < 0 and next < low:
		next = low
	look_zoom = clampf(next, low, LOOK_ZOOM_MAX)


func look_wheel_zoom(direction: int) -> void :
	if direction > 0 or look_zoom > 1.0:
		look_step_zoom(direction)
		look_zoom = maxf(look_zoom, 1.0) if direction < 0 else look_zoom




func _look_input(event: InputEvent) -> bool:
	var battle = client.battle
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		controls.firing = false
		if event.pressed:
			_look_pressing = false
			_look_moved = false
			var handled: bool = not battle.ended and _hud.click(event.position, client)
			_hud.avatar_pick = 0
			if chat_open and not handled:
				close_chat()
			if not chat_open:
				grab_focus()
			if not handled and not _hud.look_blocked(battle):
				_look_pressing = true
				_look_press_at = event.position
				_look_last = event.position
		else:
			var pressing: bool = _look_pressing
			var dragged: bool = _look_moved
			_look_pressing = false
			_look_moved = false
			_hud.look_release(event.position, battle)
			_hud.map_release()
			if pressing and not dragged and not _hud.look_blocked(battle):
				var id: int = battle.look_nearest(screen_to_world(event.position))
				if id != 0:
					battle.look_follow(id)
		accept_event()
		return true
	if event is InputEventMouseMotion:
		if _hud.map_dragging() or not _look_pressing:
			return false
		if not (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			_look_pressing = false
			_look_moved = false
			return false
		if not _look_moved:
			var gap: Vector2 = (event.position - _look_press_at) / maxf(0.01, _hud.layout_scale())
			if absf(gap.x) + absf(gap.y) < LOOK_DRAG:
				accept_event()
				return true
			_look_moved = true
			if not battle.look_free:
				battle.look_set_free(true)
		if _zoom > 0:
			_look_center += (_look_last - event.position) / _zoom
		_look_last = event.position
		accept_event()
		return true
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
		if event.pressed and not chat_open and not event.ctrl_pressed and not event.alt_pressed and not _hud.look_blocked(battle):
			look_wheel_zoom(1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -1)
		accept_event()
		return true
	if event is InputEventMouseButton and event.button_index in [MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		accept_event()
		return true
	return false



func _look_key(event: InputEventKey) -> void :
	var battle = client.battle
	if event.alt_pressed or event.ctrl_pressed or _hud.look_blocked(battle):
		return
	var code: int = int(event.physical_keycode)
	match code:
		KEY_W, KEY_A, KEY_S, KEY_D, KEY_LEFT, KEY_UP, KEY_RIGHT, KEY_DOWN:
			if not battle.look_free:
				battle.look_set_free(true)
		KEY_SPACE:
			battle.look_set_free( not battle.look_free)
		KEY_Q:
			battle.look_cycle(-1)
		KEY_E:
			battle.look_cycle(1)
		KEY_F:
			battle.look_set_free(false)
		KEY_0:
			battle.look_pick(9)
		KEY_EQUAL, KEY_KP_ADD:
			look_step_zoom(1)
		KEY_MINUS, KEY_KP_SUBTRACT:
			look_step_zoom(-1)
		_:
			if code >= KEY_1 and code <= KEY_9:
				battle.look_pick(code - KEY_1)


func _joystick_center() -> Vector2:
	return TouchLq.stick_idle(size)

func _fire_center() -> Vector2:
	return TouchLq.fire_center(size)

func _slot(index: int) -> int:
	return [13 if client.battle.skills.has(13) else 4, 1, 10, 2][index]

func _gui_input(event: InputEvent) -> void :
	if client == null or client.state != "battle":
		return



	if Input.is_emulating_mouse_from_touch():
		if client.battle.look:
			if event is InputEventScreenTouch or event is InputEventScreenDrag:
				return
		elif event is InputEventMouse and event.device == InputEvent.DEVICE_ID_EMULATION:
			return
	if _touch and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT\
	and score_board.visible and score_board.held == 0:
		if score_board.tap(event.position):
			accept_event()
			return
		score_board.hide_board()
		accept_event()
		return
	if not _touch and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and score_board.visible\
	and preload("res://battle/chat_mute.gd").click_pc(score_board, event.position):
		accept_event()
		return
	if client.battle.look and _look_input(event):
		return
	if _cl_input(event):
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var handled: bool = not client.battle.ended and _hud.click(event.position, client)
			if chat_open and not handled:
				close_chat()
			if not chat_open:
				grab_focus()
			if handled:
				controls.firing = false
				if _hud.armed != 0:
					controls.selected = 0
				if _hud.avatar_pick != 0:
					controls.avatar_tap = _hud.avatar_pick
					if not client.battle.watch_pick(_hud.avatar_pick):
						client.battle.watch_press()
					_hud.avatar_pick = 0
				accept_event()
				return
			var slot: int = -1 if client.battle.ended else _hud.skill_at(event.position, client.battle)
			if slot >= 0:

				controls.queue_skill(slot, event.shift_pressed, true)
				controls.firing = false
				accept_event()
				return
			if not client.battle.ended and _hud.cell_hit(event.position, client.battle) >= 0:

				controls.firing = false
				accept_event()
				return
		_input_job(client.key_action(1000), event.pressed, event)
		if not event.pressed:
			_hud.map_release()
		accept_event()
	elif event is InputEventMouseMotion and _hud.map_dragging():
		_hud.map_move(event.position)
		accept_event()
	elif event is InputEventMouseButton and event.pressed and event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:

		if not chat_open and not event.ctrl_pressed and _hud.cell_hit(event.position, client.battle) < 0:
			camera_zoom = clampf(roundf((camera_zoom + (0.1 if event.button_index == MOUSE_BUTTON_WHEEL_UP else -0.1)) * 10.0) / 10.0, 1.0, 2.0)
		accept_event()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		_input_job(client.key_action(1001), event.pressed, event)
		accept_event()
	elif event is InputEventScreenTouch:
		_touch = true
		if event.pressed and score_board.visible and score_board.held == 0:
			if score_board.tap(event.position):
				accept_event()
				return
			score_board.hide_board()
			accept_event()
			return
		if event.pressed and not client.battle.ended and _hud.voice_hold(event.position, client):
			if _voice_touch < 0:
				_voice_touch = event.index
			accept_event()
			return
		if event.pressed and not client.battle.ended and _hud.click(event.position, client):
			if _hud.map_dragging():
				_map_touch = event.index
			accept_event()
			return
		if event.pressed and chat_open:
			close_chat()
		if event.pressed:

			if client.battle.ended or not _lq.press(self, client.battle, event.index, event.position):
				_aim_touch = event.index
				client.battle.watch_press()
				if not client.battle.ended:
					_tcam.press(self, client.battle, event.index, event.position)
		else:
			if client.battle.look:
				_hud.look_release(event.position, client.battle)
			_lq.release(self, client.battle, event.index, event.position)
			if event.index == _joystick:
				_joystick = -1
				_stick = Vector2.ZERO
			if event.index == _fire_touch:
				_fire_touch = -1
			var panned: bool = _tcam.release(self, event.index, event.position)
			if event.index == _aim_touch:
				_aim_touch = -1
				if not panned:
					client.battle.watch_click()
			if event.index == _map_touch:
				_map_touch = -1
				_hud.map_release()
			if event.index == _voice_touch:
				_voice_touch = -1
				_hud.voice_hold_end()
		accept_event()
	elif event is InputEventScreenDrag:
		if event.index == _map_touch:
			_hud.map_move(event.position)
			if not _hud.map_dragging():
				_map_touch = -1
		else:
			if not _lq.drag(self, event.index, event.position):
				_tcam.drag(self, client.battle, event.index, event.position)
		accept_event()

func _unhandled_key_input(event: InputEvent) -> void :

	if visible and event is InputEventKey and client != null and client.state == "battle" and ( not event.pressed or not _settings.visible) and score_board.key(event, client):
		return
	if visible and event is InputEventKey and not event.pressed and client != null and client.state == "battle"\
	and not client.battle.look and not _settings.visible:
		var up: int = client.key_action(BattleSettings.flash_key(event.physical_keycode))
		if up == 1000 or up == 1001:
			_input_job(up, false, event)
		return
	if not visible or not event is InputEventKey or not event.pressed or event.echo:
		return
	if _settings.visible:
		_settings.key(event)
		return
	match event.physical_keycode:
		KEY_ENTER, KEY_KP_ENTER:
			open_chat()
			return
		KEY_ESCAPE:
			_hud.armed = 0
			return
	if client.battle.look:
		_look_key(event)
		return
	if _cl_key(event):
		return

	_input_job(client.key_action(BattleSettings.flash_key(event.physical_keycode)), true, event)




func _input_job(job: int, pressed: bool, event: InputEvent) -> void :
	match job:
		1000:
			if pressed:
				controls.tapped = true
				_map_press = true
				client.battle.watch_press()
			elif _map_press:
				_map_press = false
				client.battle.watch_click()
			controls.firing = pressed
			return
		1001:
			if not pressed and not (event as InputEventWithModifiers).ctrl_pressed and not client.battle.ended:
				controls.auto_fire = not controls.auto_fire
			return
	if not pressed:
		return

	var shift: bool = (event as InputEventWithModifiers).shift_pressed and not (event is InputEventKey and (event as InputEventKey).physical_keycode == KEY_SHIFT)
	match job:
		81: controls.queue_skill(_slot(0), shift)
		69: controls.queue_skill(1, shift)
		82: controls.queue_skill(10, shift)
		32: controls.queue_skill(2, shift)
		66: controls.queue_skill(12, shift)
		70: client.request_spray()
		90: _arm_signal(1)
		88: _arm_signal(2)
		67: _arm_signal(3)


func _arm_signal(kind: int) -> void :
	_hud.arm_signal(kind, client.battle)
	if _hud.armed != 0:
		controls.selected = 0




func _draw_cast_guide(battle) -> void :
	if not battle.alive() or not battle.tanks.has(battle.self_id):
		return
	var me: Vector2 = battle.tanks[battle.self_id].pos
	if controls.range_tip_left > 0:
		draw_circle(me, controls.range_tip, Color.RED, false, 2.0, true)

	var forced: bool = _hud.hover_range > 0
	if forced:
		draw_circle(me, _hud.hover_range, GUIDE_BLUE, false, 2.0, true)
	if controls.selected == 0:
		return
	if _touch and not _lq.zone_finger(self).is_empty():
		return
	var rule: Variant = SkillCast.rule_of(battle, pack, controls.selected)


	SkillCast.draw_select_circle(self, controls.aim, SkillCast.select_circle(rule))
	var reach: float = SkillCast.guide_range(rule)
	if reach <= 0:
		return
	var gap: Vector2 = controls.aim - me
	if gap.length_squared() > reach * reach and not forced:
		draw_circle(me, reach, GUIDE_BLUE, false, 2.0, true)
	var shape: PackedVector2Array = SkillCast.guide_shape(rule, me, controls.aim, SkillCast.stme4_skill(battle, controls.selected))
	if shape.size() >= 3 and not Geometry2D.triangulate_polygon(shape).is_empty():
		draw_colored_polygon(shape, Color(GUIDE_BLUE, 0.3))
		shape.append(shape[0])
		draw_polyline(shape, Color(GUIDE_BLUE, 0.6), 2.0, true)

func _label(pos: Vector2, text: String, color: Color = Color.WHITE, font_size: int = 16, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1, font: Font = null) -> void :
	font = font if font != null else _font
	draw_string_outline(font, pos, text, align, width, font_size, 3, Color(0, 0, 0, 0.9))
	draw_string(font, pos, text, align, width, font_size, color)

func _ally(camp: int) -> bool:

	return camp == client.battle.self_camp()


func _friendly(obj: Dictionary) -> bool:
	if client.battle.mode == "happy":
		return int(obj.get("id", 0)) == client.battle.self_id
	return _ally(int(obj.get("camp", 0)))

func _draw() -> void :
	var draw_started: int = Time.get_ticks_usec()
	if client == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("172127"))
	var battle = client.battle
	if client.map_fetch:
		var percent: int = int(pack.map_fraction(battle.map_id) * 100) if pack != null else 0
		_label(Vector2(0, size.y / 2), "Đang tải bản đồ %s… %d%%" % [battle.title(), percent], Color.WHITE, 22, HORIZONTAL_ALIGNMENT_CENTER, size.x)
		return
	if not battle.supported():
		_label(Vector2(0, size.y / 2), "Bản đồ %s chưa có trong bản HTML5" % battle.title(), Color.WHITE, 24, HORIZONTAL_ALIGNMENT_CENTER, size.x)
		return
	if not _loaded or _map_id != battle.map.id or not _textures.has("background"):
		_label(Vector2(0, size.y / 2), "Đang tải bản đồ…", Color.WHITE, 20, HORIZONTAL_ALIGNMENT_CENTER, size.x)
		return
	_my_camp = battle.self_camp()
	if not is_same(_npc_meta_src, battle.map.templates):
		_npc_meta_src = battle.map.templates
		_npc_meta_rows.clear()
		_npc_anim.clear()
	if pack != null and not _map_bundled:
		var live: Dictionary = pack.map_textures(battle.map.id)
		if not is_same(live, _textures) and live.get("background") is Texture2D:
			_textures = live
		pack.heal_map(battle.map.id)
		_denmap(battle, live)
	if not is_same(_npc_tex_src, _textures):
		_npc_tex_src = _textures
		_npc_tex.clear()
		_npc_pair.clear()
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	draw_texture(_textures.background, Vector2.ZERO)
	if _touch and not battle.look and _tcam.edge_pad(Vector2.ONE) != Vector4.ZERO:
		_edge_fade(battle.map.extent)
	var air_texture: Texture2D = _textures.get("air")
	if air_texture != null and not battle.air_hidden():
		for air: Dictionary in battle.map.air:
			draw_texture(air_texture, Vector2(air.get("x", air.get("iCenterX", 0)), air.get("y", air.get("iCenterY", 0))) - air_texture.get_size() / 2)
	_fx.pack = pack
	_draw_opened(battle)
	if _gfx.keep_decor():
		_draw_wrecks(battle)
		_draw_sprays(battle)
	for fx: Dictionary in battle.effects:
		if _gfx.hide_fx(fx):
			continue
		_fx.draw_effect(fx, battle, true)
	_draw_bullets(battle, true)
	_draw_portals(battle)
	_draw_flags(battle)


	var layer: Array = []
	var under_sky: Array = []
	var on_sky: Array = []

	var view: Rect2 = Rect2( - _offset / _zoom, size / _zoom).grow(420)
	for npc: Dictionary in _g2.collect(self, battle, view):
		if npc.dead or npc.get("hidden", false) or not view.has_point(npc.pos):
			continue
		if int(npc.id) >> 26 == 4:
			_draw_npc(npc, battle)
			continue

		var meta: Variant = _npc_meta_rows.get(int(npc.template))
		if meta == null:
			meta = _npc_meta(int(npc.template))
		match meta[1]:
			52:
				under_sky.append(npc)
			53:
				on_sky.append(npc)
			_:
				layer.append([meta[2], npc.pos.y, npc.pos.x, int(npc.id), npc, meta])
	for tank: Dictionary in battle.tanks.values():
		if not tank.get("hidden", false) and view.has_point(tank.pos):
			layer.append([TANK_SORT, tank.pos.y, tank.pos.x, int(tank.id), tank])


	layer.sort()
	layer = _g2.merge(layer)
	under_sky.sort_custom(_npc_before)
	on_sky.sort_custom(_npc_before)
	var zoom: float = _zoom
	var offset: Vector2 = _offset
	var lives: Array = []
	_draw_throw_shadows(battle, view)
	for entry: Array in layer:
		if entry.size() == 3:
			_g2.run(entry)
			continue
		var obj: Dictionary = entry[4]
		if not battle.tanks.has(int(obj.id)):
			_draw_npc(obj, battle, entry[5])
			continue
		var fly: Vector3 = _fly(obj, battle)
		var lift: float = battle.throw_scale(obj) * fly.z
		_zoom = zoom * lift
		_offset = offset + obj.pos * zoom * (1 - lift) + Vector2(fly.x, fly.y) * zoom + battle.bump_offset(obj) * zoom


		_alpha = tank_alpha(obj)
		_draw_tank(obj)
		_alpha = 1.0
		_zoom = zoom
		_offset = offset
		if not obj.dead:
			if lift == 1.0 and fly.x == 0.0 and fly.y == 0.0:
				_draw_wall_face(obj, battle)
			lives.append([obj, zoom * fly.z, offset + obj.pos * zoom * (1 - fly.z) + Vector2(fly.x, fly.y) * zoom])

	for life: Array in lives:
		_zoom = life[1]
		_offset = life[2]
		draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
		_draw_life(life[0], battle)
	_zoom = zoom
	_offset = offset
	_g2.sky(self, battle, under_sky, 52)
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	if _textures.has("sky"):
		draw_texture(_textures.sky, Vector2.ZERO)
	_g2.sky(self, battle, on_sky, 53)
	_draw_link_buffs(battle)
	for fx: Dictionary in battle.effects:
		if _gfx.hide_fx(fx):
			continue

		if _fx.draw_effect(fx, battle, false) or fx.kind != "death":
			continue
		draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
		var ratio: float = fx.age / fx.life
		var color: Color = Color("ff814d")
		color.a = 1 - ratio
		draw_circle(fx.pos, lerpf(8, 60, ratio), color, false, 5, true)
	_draw_bullets(battle, false)
	_draw_flag_rings(battle)
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	for tank: Dictionary in battle.tanks.values():
		if battle.mode == "happy" and battle.happy_rank(int(tank.id)) == 1 and not tank.dead and not tank.get("hidden", false):
			_crown(tank.pos)
	_draw_bubbles(battle)
	if Settings.on("numbers"):
		_hud.draw_numbers(battle, _offset, _zoom)
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	_draw_cast_guide(battle)
	if battle.alive() and _touch:
		_lq.draw_world(self, battle)
	draw_set_transform(Vector2.ZERO)
	if battle.ended and not (result_mv != null and result_mv.playing()):

		if not _board() and not pve_result.visible and not happy_result.visible and not clan_result.visible:
			_draw_result()
	else:

		_draw_hud()
		if _touch and not battle.ended:
			_draw_touch()
	if profile_draw and draw_samples.size() < 240:
		draw_samples.append(float(Time.get_ticks_usec() - draw_started) / 1000.0)




func _draw_link_buffs(battle) -> void :
	if pack == null:
		return
	_fx.pack = pack
	var view: Rect2 = Rect2( - _offset / _zoom, size / _zoom).grow(200)
	for group: Dictionary in [battle.tanks, battle.npcs]:
		for obj: Dictionary in group.values():
			var buffs: Variant = obj.get("buffs")
			if buffs == null or (buffs as Dictionary).is_empty():
				continue
			for buff: Dictionary in (buffs as Dictionary).values():
				var link: Dictionary = _fx.link_buff(int(buff.get("m_nBuffTpltId", 0)))
				if link.is_empty():
					continue
				var caster: Dictionary = battle.actor(int(buff.get("m_nCasterId", 0)))
				if not caster.has("pos"):
					continue
				if not buff.has("seen"):
					buff.seen = _time
				if Rect2(caster.pos, Vector2.ZERO).expand(obj.pos).grow(1).intersects(view):
					_fx.draw_link_buff(link, caster.pos, obj.pos, _time - float(buff.seen))


func _draw_bullets(battle, bottom: bool) -> void :
	var view: Rect2 = Rect2( - _offset / _zoom, size / _zoom).grow(200)
	for bullet: Dictionary in battle.bullets.values():

		if _fx.prepare(bullet, battle).has("l") != bottom:
			continue
		if bullet.has("link"):

			if not view.intersects(Rect2(bullet.origin, Vector2.ZERO).expand(bullet.pos).grow(1)):
				continue
		elif not view.has_point(bullet.pos):
			continue
		if _fx.draw_bullet(bullet, battle):
			continue
		draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
		draw_line(bullet.pos, bullet.pos - bullet.pos.direction_to(bullet.dest) * 14, Color("ffcd68"), 5, true)
		draw_circle(bullet.pos, 3, Color.WHITE)


static func tank_alpha(obj: Dictionary) -> float:
	return 0.6 if obj.get("faded", false) else 1.0


static func _npc_before(a: Dictionary, b: Dictionary) -> bool:
	return a.pos.y < b.pos.y if a.pos.y != b.pos.y else a.pos.x < b.pos.x



func _npc_meta(template: int) -> Array:
	var meta: Variant = _npc_meta_rows.get(template)
	if meta == null:
		var row: Dictionary = _npc_meta_src.get(str(template), {})
		var kind: String = str(row.get("iType", ""))
		meta = [row, 52 if kind == "52" else 53 if kind == "53" else 4 if kind == "4" else 0, int(row.get("nSortWeight", TANK_SORT)), 
			int(row.get("nOpCampId", 0)), str(row.get("iCopItType", "")) == "1", int(int(row.get("iImgHeight", 0)) / 2)]
		_npc_meta_rows[template] = meta
	return meta



func _draw_npc(npc: Dictionary, battle, meta: Array = []) -> void :

	var lift: float = battle.throw_scale(npc) if npc.has("throw") else 1.0
	var origin: Vector2 = _offset + npc.pos * _zoom * (1 - lift)
	var grow: Vector2 = Vector2(_zoom * lift, _zoom * lift)
	draw_set_transform(origin, 0, grow)
	var kind: int = int(npc.id) >> 26
	if kind == 4 and _draw_item(npc, battle):
		return
	_alpha = 0.6 if npc.get("faded", false) else 1.0

	var buffed: bool = not npc.buffs.is_empty()
	if buffed:
		_draw_buffs(npc, true, 0.0)
		draw_set_transform(origin, 0, grow)
	if kind == 5 and _draw_ainpc(npc, battle, origin, grow.x):
		if buffed:
			_draw_buffs(npc, false, 0.0)
		_alpha = 1.0
		return
	if meta.is_empty():
		meta = _npc_meta(int(npc.template))
	var row: Dictionary = meta[0]
	if row.is_empty() and kind == 3 and _draw_npc_rt(npc):
		if buffed:
			_draw_buffs(npc, false, 0.0)
		_alpha = 1.0
		return
	var shown: int = int(npc.template) if meta[3] == 0 else _npc_display_id(npc, meta)
	var cannon: bool = meta[1] == 4

	var state: int = 0
	if npc.max_hp > 0 and npc.hp >= 0:
		var pct: int = int(float(npc.hp) / npc.max_hp * 100.0)
		state = 3 if pct <= 25 else 2 if pct <= 50 else 1 if pct <= 75 else 0

	if state > 0 and pack != null and kind == 3 and not npc.has("warm"):
		npc.warm = true
		pack.effect(pack.npc_destroy(int(npc.template), _my_camp == 1))
		pack.effect(pack.npc_left(int(npc.template), _my_camp == 1))


	var glow: float = 1.0 + 0.8 * clampf(1.0 - (battle.clock - float(npc.lit)) / 0.1, 0.0, 1.0) if npc.has("lit") else 1.0
	var tint: Color = Color(glow, glow, glow, _alpha)
	var base: Texture2D = _npc_image(shown, 1, 2 * state) if cannon else null
	var gun: Texture2D = _npc_image(shown, 2, 2 * state + 1 if state > 0 else 0) if cannon else null

	var texture: Texture2D = null
	if not cannon:

		var hit: Variant = _npc_tex.get(shown * 32 + (8 + state if state > 0 and pack != null else 0))
		texture = hit if hit != null else _npc_image(shown, 0, state)
	elif base == null or gun == null:
		texture = _npc_image(shown, 0, 0)
	if base != null and gun != null:

		var angle: float = float(npc.get("gun_angle", 0.0))
		var kick: float = battle.clock - float(npc.get("recoil", -1000.0))
		if kick < 0.3 and npc.has("gun"):
			angle = Fx.rotation(npc.pos, npc.gun)
		else:
			var target: Dictionary = battle.actor(int(npc.get("aim_target", 0)))
			if not target.is_empty() and target.pos != npc.pos:
				angle = Fx.rotation(npc.pos, target.pos)
		npc["gun_angle"] = angle
		var back: Vector2 = Vector2( - sin(angle), cos(angle)) * 10.0 * (1.0 - kick / 0.3) if kick < 0.3 else Vector2.ZERO
		draw_texture(base, npc.pos - base.get_size() / 2, tint)
		draw_set_transform(origin + (npc.pos + back) * grow.x, angle, grow)
		draw_texture(gun, - gun.get_size() / 2, tint)
		draw_set_transform(origin, 0, grow)
	elif texture != null:
		var anim: Dictionary = _npc_swf(shown, state)
		if anim.is_empty():
			draw_texture(texture, npc.pos - texture.get_size() / 2, tint)
		else:

			var cells: Array = anim.data.frames
			var cell: Dictionary = cells[int(_time * Fx.FPS) % cells.size()]
			var r: Array = cell.rect
			var mc: Vector2 = npc.pos - Vector2(float(anim.data.stage[0]), float(anim.data.stage[1])) / 2
			draw_texture_rect_region(anim.pages[int(cell.page)], Rect2(mc.x - float(cell.pivot[0]), mc.y - float(cell.pivot[1]), r[2], r[3]), 
				Rect2(r[0], r[1], r[2], r[3]), tint)
	elif pack == null or pack.state != "ready":

		var color: Color = Color("e9c767") if int(npc.camp) == 0 else (Color("73cbff") if int(npc.camp) == 1 else Color("ff8d81"))
		color.a = _alpha
		if int(npc.id) >> 26 == 5:
			draw_rect(Rect2(npc.pos - Vector2(21, 27), Vector2(42, 54)), color.darkened(0.25))
			draw_line(npc.pos, npc.pos + Vector2.from_angle((int(npc.direction) - 3) * PI / 4) * 35, color, 8, true)
			_label(npc.pos - Vector2(32, 35), "Triệu hồi", color, 13)
		else:
			draw_circle(npc.pos, 12, color, false, 4, true)
			draw_line(npc.pos - Vector2(8, 0), npc.pos + Vector2(8, 0), color, 3)
		draw_set_transform(origin, 0, grow)
	if buffed:
		_draw_buffs(npc, false, 0.0)
		draw_set_transform(origin, 0, grow)
	_alpha = 1.0
	if row.is_empty():
		if npc.max_hp > 0 and npc.hp >= 0 and npc.hp < npc.max_hp:
			_bar(npc.pos + Vector2(-25, 37), 50, float(npc.hp) / npc.max_hp, Color("eda855"))
		return


	var rise: int = 30 if cannon else 16
	if (cannon or meta[4]) and npc.max_hp > 0 and npc.hp >= 0:
		var camp: int = int(npc.camp)
		var skin: String = "yellow" if camp == 0 else ("blue" if camp == _my_camp else "red")
		_life_strip(npc.pos + Vector2(-36, meta[5] - rise), clampf(float(npc.hp) / npc.max_hp, 0, 1), skin, int(npc.max_hp))

	if npc.has("face"):
		var shape: Dictionary = row if shown == int(npc.template) else _npc_meta(shown)[0]
		if not shape.is_empty():
			_draw_face(npc, npc.pos + Vector2(int(int(shape.get("iImgWidth", 0)) / 2), int(int(shape.get("iImgHeight", 0)) / 2)))
			draw_set_transform(origin, 0, grow)




func _draw_npc_rt(npc: Dictionary) -> bool:
	if pack == null or pack.state != "ready" or not pack.fx.has("npc_rt"):
		return false
	var rt: Variant = pack.fx.npc_rt.get(str(int(npc.template)))
	if not rt is Dictionary:
		return false
	var anim: Dictionary = pack.effect(str(rt.get("n", "")))
	if anim.is_empty() or not anim.data.get("frames") is Array or anim.data.frames.is_empty():
		return true
	var cells: Array = anim.data.frames
	var cell: Dictionary = cells[int(_time * Fx.FPS) % cells.size()]
	var r: Array = cell.rect
	var stage: Variant = anim.data.get("stage")
	var half: Vector2 = Vector2(float(stage[0]), float(stage[1])) / 2 if stage is Array and stage.size() >= 2 else Vector2.ZERO
	var mc: Vector2 = npc.pos - half
	draw_texture_rect_region(anim.pages[int(cell.page)], Rect2(mc.x - float(cell.pivot[0]), mc.y - float(cell.pivot[1]), r[2], r[3]), 
		Rect2(r[0], r[1], r[2], r[3]), Color(1, 1, 1, _alpha))
	return true




func _draw_ainpc(npc: Dictionary, battle, origin: Vector2, scale: float) -> bool:
	if pack == null or pack.state != "ready":
		return false
	var row: Array = pack.ainpc_row(int(npc.template))
	if row.size() < 5:
		return true


	if row.size() >= 6 and int(row[5]) == 5:
		return true
	var external: String = str(int(row[1]) if int(row[1]) != 0 and _my_camp == 1 else int(row[0]))

	var shadow: Dictionary = _ph_shadow(npc, row, battle)
	var art: Dictionary = _ph_art(str(shadow.external), int(shadow.tank)) if shadow.has("external") else pack.external_art(external)
	if not art.has("body") and not shadow.has("external"):
		art = _ph_turret_only(external)
	var body_swf: Dictionary = _swf(art.get("body"))
	var body_png: bool = body_swf.is_empty() and art.has("body") and art.body.data.frames.size() >= 8
	var zoom0: float = _zoom
	var offset0: Vector2 = _offset
	_zoom = scale
	_offset = origin
	var look_state: Dictionary = _show_state(npc)
	_hold(npc, look_state.still)
	var grow: float = float(look_state.scale)
	_zoom = scale * grow
	_offset = origin + npc.pos * scale * (1 - grow)
	var glow: float = 1.0 + 0.8 * clampf(1.0 - (battle.clock - float(npc.get("lit", -1000.0))) / 0.1, 0.0, 1.0)
	_tint = look_state.tint * Color(glow, glow, glow, _alpha)
	_spin = float(look_state.spin)
	var moving: bool = npc.pos.distance_to(npc.target) > 0.5
	if not body_swf.is_empty():
		_draw_swf_body(art.body, body_swf, npc, moving)
	elif body_png:
		_draw_png_body(art.body, npc, moving)
	_draw_speed(npc, moving, _buff_rules(npc))
	if art.has("turret"):

		var rotation: float = npc.pos.angle_to_point(npc.aim) + PI / 2 if npc.has("aim") and npc.aim != npc.pos else _face_angle(npc)
		if npc.has("still_at") and npc.has("cannon_rot"):
			rotation = float(npc.cannon_rot)
		npc.cannon_rot = rotation
		var turret_swf: Dictionary = _swf(art.turret)
		if turret_swf.has("idle"):
			_draw_swf_cannon(art.turret, turret_swf, npc, rotation)
		elif not turret_swf.is_empty():
			_ph_layer_cannon(art.turret, turret_swf, npc, rotation)
		else:
			_draw_png_cannon(art.turret, npc, rotation)
	_tint = Color.WHITE
	_spin = 0.0
	_zoom = scale
	_offset = origin
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	if shadow.has("life"):
		_draw_life(shadow.life, battle)
		_zoom = zoom0
		_offset = offset0
		draw_set_transform(origin, 0, Vector2(scale, scale))
		return true
	var camp: int = int(npc.camp)
	var hp: int = int(npc.hp)
	var max_hp: int = int(npc.max_hp)
	var life: int = int(row[3])
	if max_hp > 0 and hp >= 0 and (life == 0 or (life == 2 and hp < max_hp)):
		var skin: String = "yellow" if battle.mode == "happy" or camp == 0 else ("blue" if camp == _my_camp else "red")
		_life_strip(npc.pos + Vector2(-36, 63), clampf(float(hp) / max_hp, 0, 1), skin, max_hp)
	var orb_left: float = orb_time_left(npc, float(battle.clock))
	if orb_left >= 0.0:
		var orb_skin: String = "yellow" if battle.mode == "happy" or camp == 0 else ("blue" if camp == _my_camp else "red")
		_life_strip(npc.pos + Vector2(-36, 63), orb_left, orb_skin, 0)
	if int(row[2]) == 1 and not str(row[4]).is_empty():
		var color: Color = Color("ffff00") if camp == 0 else (Color("28baee") if camp == _my_camp else Color("ff0000"))
		_label(npc.pos + Vector2(-100, 72 + 17), str(row[4]), color, 16, HORIZONTAL_ALIGNMENT_CENTER, 200)
	_zoom = zoom0
	_offset = offset0
	draw_set_transform(origin, 0, Vector2(scale, scale))
	return true





const TMY4_ORB_BAR: bool = true
const TMY4_ORBS: Array[int] = [373201, 373202, 615201, 615202]
const TMY4_ORB_MS: float = 8000.0


static func orb_time_left(npc: Dictionary, clock: float) -> float:
	if not TMY4_ORB_BAR or not npc.has("born") or not (int(npc.get("template", 0)) in TMY4_ORBS):
		return -1.0
	var total: float = float(npc.get("max_hp", 0))
	var left: float = float(npc.get("hp", 0))
	if total <= 1.0 or left <= 0.0:
		total = TMY4_ORB_MS
		left = TMY4_ORB_MS
	return clampf((minf(left, total) - (clock - float(npc.born)) * 1000.0) / total, 0.0, 1.0)



func _ph_art(external: String, tank: int) -> Dictionary:
	var art: Dictionary = _art.get(external, {})
	if not art.is_empty() or pack == null:
		return art
	var first: String = pack.art_external(external, tank)
	art = pack.external_art(first)
	if _ph_ok(art) or not pack.art_settled(first):
		return art
	_ph_check()
	var key: String = first + "|" + str(tank)
	var hit: Variant = _ph_memo.get(key)
	if hit is Dictionary:
		return hit
	var tanks: Dictionary = pack.index.get("tanks", {})
	for alt: String in [str(int(tanks.get(str(tank), -1))), str(int(tanks.get(PH_STARTER, -1)))]:
		if alt == first or not pack.has_external(alt):
			continue
		var other: Dictionary = pack.external_art(alt)
		if not pack.art_settled(alt):
			return art
		if _ph_ok(other):
			_ph_memo[key] = other
			return other
	_ph_memo[key] = art
	return art

static func _ph_ok(art: Dictionary) -> bool:
	return art.has("body") and ( not _swf(art.body).is_empty() or art.body.data.frames.size() >= 8)

func _ph_check() -> void :
	if not is_same(_ph_pack, pack):
		_ph_pack = pack
		_ph_memo = {}
		_ph_turrets = {}


func _ph_turret_only(external: String) -> Dictionary:
	_ph_check()
	var hit: Variant = _ph_turrets.get(external)
	if hit is Dictionary:
		return hit
	var memo: Dictionary = _ph_turrets
	memo[external] = {}
	var parts: Dictionary = pack.index.get("externals", {}).get(external, {})
	if not parts.has("body") and parts.has("turret"):
		pack._component(int(parts.turret), func(value: Variant) -> void :
			if value is Dictionary:
				memo[external] = {"turret": value})
	return memo[external]



func _ph_shadow(npc: Dictionary, row: Array, battle) -> Dictionary:
	if row.size() < 6 or int(row[5]) != 4:
		return {}
	var owner: Dictionary = battle.tanks.get(int(npc.get("owner", 0)), {})
	if owner.is_empty():
		return {}
	var look: Dictionary = client.battle.appearances.get(int(owner.get("account", 0)), {})
	return {"external": str(look.get("external", 0)), "tank": int(look.get("tank", 0)), 
		"life": {"id": int(npc.id), "pos": npc.pos, "camp": int(npc.camp), "hp": int(npc.hp), "max_hp": int(npc.max_hp), 
			"name": str(owner.get("name", "")), "account": int(owner.get("account", 0)), "level": int(owner.get("level", 0))}}



func _ph_layer_cannon(part: Dictionary, swf: Dictionary, tank: Dictionary, rotation: float) -> void :
	var clock: float = float(tank.get("still_at", _time))
	for layer: Dictionary in swf.get("layers", []):
		var m: Array = layer.matrix
		var local: Transform2D = Transform2D(Vector2(m[0], m[1]), Vector2(m[2], m[3]), Vector2(m[4], m[5]))
		var index: int = int(clock * 24.0) % maxi(1, int(layer.count))
		_swf_draw(part, int(layer.first) + index, Transform2D(rotation, _cannon_pos(tank, rotation)) * local)


func _npc_display_id(npc: Dictionary, meta: Array) -> int:
	var partner: int = meta[3]
	if partner == 0 or _my_camp != 1 or pack == null:
		return int(npc.template)
	var key: int = partner * 2 + (1 if meta[1] == 4 else 0)
	if not _npc_pair.has(key):
		if not pack.want_map_image(_map_id, "npc-%d%s" % [partner, "-base" if meta[1] == 4 else ""]):
			return int(npc.template)
		_npc_pair[key] = true
	return partner




func _npc_image(id: int, part: int, broken: int) -> Texture2D:
	if broken > 0 and pack != null:
		var hit: Variant = _npc_tex.get(id * 32 + 8 + broken)
		if hit != null:
			return hit
		var key: String = "npc-%d-state-%d" % [id, broken]
		if _textures.has(key):
			var found: Texture2D = _textures[key]
			if found != null:
				_npc_tex[id * 32 + 8 + broken] = found
			return found
		pack.want_map_image(_map_id, key)
	var cached: Variant = _npc_tex.get(id * 32 + part)
	if cached != null:
		return cached
	var whole: String = "npc-%d%s" % [id, NPC_PARTS[part]]
	if not _textures.has(whole) and pack != null:
		pack.want_map_image(_map_id, whole)
	var texture: Texture2D = _textures.get(whole)
	if texture != null:
		_npc_tex[id * 32 + part] = texture
	return texture



func _npc_swf(id: int, state: int) -> Dictionary:
	if pack == null:
		return {}


	if not is_same(_npc_anim_pack, pack):
		_npc_anim_pack = pack
		_npc_anim.clear()
	var memo: Variant = _npc_anim.get(id * 4 + state)
	if memo is Dictionary:
		if pack.state == "ready":
			return memo
	elif memo != null:
		return {}
	var row: Dictionary = _npc_meta(id)[0]
	var file: String = str(row.get("szImageFile" if state <= 0 else "szBrokenImage%d" % state, ""))
	if not NPC_SWF_ANIM.has(file):
		_npc_anim[id * 4 + state] = false
		return {}
	var anim: Dictionary = pack.effect("npcswf/" + file.get_basename())
	if not anim.is_empty() and anim.data.get("stage") is Array:
		_npc_anim[id * 4 + state] = anim
		return anim
	return {}




static func life_grids(max_hp: int) -> int:
	var grids: int = roundi(float(max_hp) / GRID_HP) if max_hp > 0 else 0
	return grids if grids >= 1 and grids <= 15 else 0

func _life_strip(bar: Vector2, hp: float, skin: String, max_hp: int) -> void :
	var empty: Texture2D = _hud.life_set()[0]
	var full: Texture2D = _hud.life_skin(skin)
	if empty != null and full != null:
		draw_texture(empty, bar)

		var fill: int = clampi(int(hp * 70.0) - 1, 0, 66)
		if fill > 0:
			draw_texture_rect_region(full, Rect2(bar + Vector2(3, 0), Vector2(fill, 14)), Rect2(3, 0, fill, 14))
	else:
		_bar(bar + Vector2(3, 3), 66, hp, Color("1ae524") if skin == "green" else Color("28baee") if skin == "blue" else Color("ff4b3a") if skin == "red" else Color("ffd84a"))

	var grids: int = life_grids(max_hp)
	if grids > 0:


		var ticks: PackedVector2Array = _hud.life_grid(max_hp, GRID_HP)
		if ticks.size() >= 2:
			draw_multiline(Transform2D(0, bar) * ticks, Color.BLACK, 1)



func _denmap(battle, live: Dictionary) -> void :
	var bg: Variant = _textures.get("background")
	if not (bg is Texture2D) or not (bg as Texture2D).has_meta("placeholder"):
		_dm_at = 0
		return
	var now: int = Time.get_ticks_msec()
	if _dm_at == 0:
		_dm_at = now
	var id: int = int(battle.map.id)
	if live.is_empty() and now - _dm_ask >= DM_ASK_MS:
		_dm_ask = now
		pack.request_map(id)
	if now - _dm_at >= DM_TELL_MS and _dm_told != int(battle.scene_id):
		_dm_told = int(battle.scene_id)
		push_error("denmap1 nền tạm %d s map %d %s" % [(now - _dm_at) / 1000, id, pack.bg_report(id, live, _textures)])



func _draw_wall_face(tank: Dictionary, battle) -> void :
	var background: Texture2D = _textures.background
	if background.has_meta("placeholder"):
		return
	var faces: Array = battle.map.wall_faces(tank.pos)
	var feet: Array = battle.map.tree_feet(tank.pos)
	if faces.is_empty() and feet.is_empty():
		return
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	var whole: = Rect2(Vector2.ZERO, background.get_size())
	for face: Rect2 in faces:
		if whole.encloses(face):
			draw_texture_rect_region(background, face, face)
	for outline: PackedVector2Array in feet:
		draw_colored_polygon(outline, Color.WHITE, Transform2D().scaled(Vector2.ONE / battle.map.extent) * outline, background)

func _draw_life(tank: Dictionary, battle) -> void :
	var pos: Vector2 = tank.pos
	var self_tank: bool = int(tank.id) == battle.self_id
	var camp: int = int(tank.get("camp", 0))
	var ally: bool = camp == _my_camp

	var skin: String = "green" if self_tank else ("yellow" if battle.mode == "happy" or camp == 0 else ("blue" if ally else "red"))
	var bar: Vector2 = pos + Vector2(-22, 63)
	var hp: float = float(clampi(int(tank.hp), 0, maxi(1, int(tank.max_hp)))) / maxi(1, int(tank.max_hp))
	var art: Array = _hud.life_set()
	var warn: Texture2D = art[1]
	if warn != null and int(tank.max_hp) > 0 and hp * 100.0 <= 20.0:

		var phase: float = fposmod(battle.clock * 24.0, 24.0)
		var alpha: float = lerpf(0.94, 0.37, phase / 10.0) if phase < 10.0 else lerpf(0.37, 1.0, (phase - 10.0) / 14.0)
		draw_texture_rect(warn, Rect2(bar + Vector2(-13.7, -4.05), Vector2(103.5, 22.6)), false, Color(1, 1, 1, alpha))
	_life_strip(bar, hp, skin, int(tank.max_hp))
	var name_y: float = 72.0
	if int(tank.get("max_mp", 0)) > 0 and Mp.uses(tank):
		name_y = 82.0
		var mp_bg: Texture2D = art[2]
		var mp_bar: Texture2D = art[3]
		if mp_bg != null and mp_bar != null:
			draw_texture(mp_bg, pos + Vector2(-22, 76))
			var width: float = mp_bar.get_width() * clampf(float(tank.get("mp", 0)) / int(tank.max_mp), 0, 1)
			if width > 0:
				draw_texture_rect_region(mp_bar, Rect2(pos + Vector2(-20, 78), Vector2(width, mp_bar.get_height())), Rect2(Vector2.ZERO, Vector2(width, mp_bar.get_height())))
	var level: int = int(tank.get("level", 0))
	var level_bg: Texture2D = art[4]
	var digits: Texture2D = art[5]

	if level > 0 and level_bg != null and digits != null and _hud.level_mode_of(battle) > 0:
		var badge: Vector2 = pos + Vector2(-42, 58)
		draw_texture(level_bg, badge)
		var text: String = str(level)
		var at: Vector2 = badge + (level_bg.get_size() - Vector2(8 * text.length(), 12)) / 2
		for i: int in text.length():
			draw_texture_rect_region(digits, Rect2(at + Vector2(8 * i, 0), Vector2(8, 12)), Rect2(8 * int(text[i]), 0, 8, 12))

	var color: Color = Color("48dd3b") if self_tank else (Color("ffff00") if camp == 0 else (Color("28baee") if ally else Color("ff0000")))


	var tank_name: String = str(tank.name)
	var account: int = int(tank.get("account", 0))
	var tints: PackedColorArray = NameStyles.colors_of(client, account, tank_name)



	var vip: Texture2D = _vip_icon(int(Hud.brief_of(battle, account).get("charData", {}).get("nVipLevel", 0)))
	var shift: float = - float(vip.get_width()) / 2 if vip != null else 0.0
	if tints.is_empty():
		_label(pos + Vector2(-100 + shift, name_y + 17), tank_name, color, 16, HORIZONTAL_ALIGNMENT_CENTER, 200)
	else:
		NameStyles.draw_tinted(self, _font, 16, pos + Vector2(-100 + shift, name_y + 17), tank_name, tints, 3, Color(0, 0, 0, 0.9), "c", 200.0)
	if vip != null:
		draw_texture(vip, pos + vip_at(name_y, _name_width(tank_name), vip.get_width()))


	if Love.battle_show(client, account):
		var love_floor: float = 63.0 + (float(art[0].get_height()) if art[0] != null else 14.0) + 2.0
		if name_y > 72.0 and art[2] != null:
			love_floor = 76.0 + float(art[2].get_height()) + 2.0
		Love.draw(self, Love.battle_name_rect(pos, name_y, _name_width(tank_name), float(vip.get_width()) if vip != null else 0.0, 
			float(vip.get_height()) if vip != null else 0.0, love_floor, name_y + 17.0 + (_font.get_descent(16) - _font.get_ascent(16)) / 2.0), 1.0, _zoom)


	var rating: int = battle.tech_rating_of(account)
	if rating >= 0:
		var honor: Texture2D = _hud.tex(TECH_ICONS[rating])
		if honor != null:
			draw_texture(honor, pos + honor_at(_hud.level_mode_of(battle) > 0))


static func vip_at(name_y: float, text_w: float, icon_w: float) -> Vector2:
	return Vector2((text_w - icon_w) / 2, name_y + 7)


static func honor_at(level_map: bool) -> Vector2:
	return Vector2((-42.0 if level_map else -22.0) - 27.0, 45)


func _vip_icon(vip: int) -> Texture2D:
	var level: int = vip % 100
	if level < 1 or level > 15:
		return null
	return _hud.tex("loading/vip/%s%d" % ["SV" if vip >= 100 else "V", level])


func _name_width(text: String) -> float:
	var hit: Variant = _name_widths.get(text)
	if hit == null:
		if _name_widths.size() >= 256:
			_name_widths.clear()
		hit = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x
		_name_widths[text] = hit
	return hit


func _draw_bubbles(battle) -> void :

	var columns: Dictionary = _hud.columns_of(battle)
	for id: int in battle.bubbles:
		var tank: Dictionary = battle.tanks.get(id, {})
		if tank.is_empty() or tank.dead or tank.get("hidden", false) or id in columns[1] or id in columns[2]:
			continue
		var bubble: Dictionary = battle.bubbles[id]
		var alpha: float = clampf((5.0 - (battle.clock - float(bubble.t))) / 0.3, 0.0, 1.0)
		var rows: Array = _hud.wrap_rich([[str(bubble.text), bubble.get("fg", Color("3b2a10"))]], 150, 13)
		var width: float = 0.0
		for row: Array in rows:
			var w: float = 0.0
			for seg: Array in row:
				w += _hud.font.get_string_size(seg[0], HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
			width = maxf(width, w)

		var lift: float = 94.0 if battle.mode == "happy" and battle.happy_rank(id) == 1 else 56.0
		var box: Rect2 = Rect2(tank.pos + Vector2( - width / 2 - 8, - lift - rows.size() * 16 - 8), Vector2(width + 16, rows.size() * 16 + 8))
		var border: Color = bubble.get("border", Color("b48a46"))
		_bubble_box.bg_color = Color(bubble.get("bg", Color("fff6d5")), 0.95 * alpha)
		_bubble_box.border_color = Color(border, alpha)
		_bubble_box.set_border_width_all(1)
		_bubble_box.set_corner_radius_all(6)
		draw_style_box(_bubble_box, box)
		var tip: Vector2 = Vector2(tank.pos.x, box.end.y)
		draw_colored_polygon(PackedVector2Array([tip + Vector2(-5, -1), tip + Vector2(5, -1), tip + Vector2(0, 6)]), _bubble_box.bg_color)
		draw_polyline(PackedVector2Array([tip + Vector2(-5, 0), tip + Vector2(0, 6), tip + Vector2(5, 0)]), _bubble_box.border_color, 1.0, true)
		_hud.draw_rows(rows, box.position + Vector2(8, 1), 13, 16, 0, alpha)


func _draw_hud() -> void :
	var battle = client.battle
	_hud.pack = pack
	_hud.touch = _touch
	_hud.draw(battle, client)
	_cl_draw_button(battle)
	_draw_tips(battle)
	_draw_vote()
	_hud.draw_tip(battle, client)
	_cl_draw_tip()





const TIP_COLOR: Color = Color("00ff00")
const TIP_Y: float = 150.0
const TIP_W: float = 800.0
const TIP_FONT: int = 20
const TIP_TOUCH_FONT: int = 14
const TIP_TOUCH_W: float = 460.0
var tip_rects: Array[Rect2] = []

func _draw_tips(battle) -> void :
	tip_rects.clear()
	if battle.tips.is_empty():
		return
	var text: String = str(battle.tips[-1].text)
	var k: float = _hud.scale
	var top: float = TIP_Y * k
	var font_size: int = int(TIP_FONT * k)
	var room: float = TIP_W * k
	if _touch:
		k = _hud.layout_scale()
		top = Hud.TARGET_Y * k + _hud.safe_in.y
		if _hud.target_box.has_area():
			top = _hud.target_box.end.y + 4 * k
		font_size = int(TIP_TOUCH_FONT * k)
		room = TIP_TOUCH_W * k
	var font: Font = _hud._gap_font(_hud.bold if _hud.bold != null else _font, maxi(1, roundi(2 * k)))
	var wide: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	if wide > room:
		font_size = maxi(8, int(font_size * room / wide))
		wide = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	while wide > room and text.length() > 1:
		text = text.left(mini(text.length() - 2, int(text.length() * room / wide))) + "…"
		wide = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var base: Vector2 = Vector2(0, floorf(top) + 2 * k + font_size)
	draw_string_outline(font, base, text, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, maxi(2, roundi(3 * k)), Color.BLACK)
	draw_string(font, base, text, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size, TIP_COLOR)
	tip_rects.append(Rect2(Vector2(floorf(size.x / 2 - wide / 2), floorf(top)), Vector2(wide, font_size + 4 * k)))




func ask_exit() -> void :
	if client == null or client.state != "battle" or client.battle.ended:
		return
	controls.clear()
	if client.battle.look:
		client.leave_battle()
		return
	if int(Text.map_info(int(client.battle.map_id)).get("type", 0)) == MAPT_PVE_SOLO:
		client.leave_battle()
		return
	exit_ask.ask()


func ask_buy_life(coin_type: int, num: int) -> void :
	if client == null or client.state != "battle" or client.battle.ended:
		return
	controls.clear()
	pay_ask.ask(coin_type, num)


func toggle_score_board() -> void :
	if score_board.visible:
		score_board.hide_board()
	elif client != null and client.state == "battle" and not client.battle.ended:
		controls.firing = false
		score_board.held = 0
		score_board.visible = true

func toggle_menu() -> void :
	if _settings.visible:
		_settings.close()
	elif not client.battle.ended:
		controls.firing = false
		_settings.open()



const HAPPY_RANK_OFFSET: int = 20
func _crown(at: Vector2) -> void :
	var tex: Texture2D = _hud.tex("happy_first")
	if tex != null:
		draw_texture(tex, at + Vector2( - int(tex.get_width() / 2.0), - HAPPY_RANK_OFFSET - tex.get_height()))


func _draw_portals(battle) -> void :
	if pack == null or battle.map.portals.is_empty():
		return
	for portal: Dictionary in battle.map.portals:
		var art: Dictionary = pack.effect(pack.portal_key(portal))
		if not art.is_empty():
			_fx.frame(art, int(_time * Fx.FPS) % maxi(1, art.data.frames.size()), Vector2(float(portal.iCenterX), float(portal.iCenterY)), 0, Vector2(-36, -36))
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))



func _draw_flags(battle) -> void :
	if pack == null or battle.map.flags.is_empty():
		return
	var ground: Dictionary = pack.effect("occupy/ground")
	for flag: Dictionary in battle.map.flags:
		var pos: Vector2 = Vector2(float(flag.iCenterX), float(flag.iCenterY))
		var state: Dictionary = battle.occupy.get(int(flag.iIndex), {})
		var camp: int = int(state.get("camp", flag.get("iCamp", 0)))
		if not ground.is_empty():
			_fx.frame(ground, 0, pos, 0, Vector2(-60, -60))
		var art: Dictionary = pack.effect("occupy/flag_null" if camp not in [1, 2] else ("occupy/flag_blue" if _ally(camp) else "occupy/flag_red"))
		if not art.is_empty():
			_fx.frame(art, int(_time * Fx.FPS) % maxi(1, art.data.frames.size()), pos, 0, Vector2(-36, -60))
		else:
			draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
			draw_line(pos + Vector2(0, 40), pos - Vector2(0, 50), Color(0.85, 0.85, 0.85), 3)
			draw_colored_polygon(PackedVector2Array([pos - Vector2(0, 50), pos + Vector2(34, -38), pos - Vector2(0, 26)]), Color(0.8, 0.8, 0.8) if camp not in [1, 2] else _camp_color(camp))
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))


func _draw_flag_rings(battle) -> void :
	if pack == null:
		return
	for flag: Dictionary in battle.map.flags:
		var occ: int = int(battle.occupy.get(int(flag.iIndex), {}).get("occupy", 0))
		if occ == 0:
			continue
		var ring: Dictionary = pack.effect("occupy/map_occupy_blue" if _ally(1 if occ < 0 else 2) else "occupy/map_occupy_red")
		if not ring.is_empty():
			var index: int = clampi(absi(occ) * 100 / maxi(1, int(flag.get("iControlSecond", 1))), 1, 100) - 1
			_fx.frame(ring, index, Vector2(float(flag.iCenterX), float(flag.iCenterY)), 0, Vector2(-32, -31))

func _camp_color(camp: int) -> Color:
	return Color("73cbff") if _ally(camp) else Color("ff8d81")

func _base_percent(camp: int) -> int:
	var base: Dictionary = client.battle.base_camps().get(camp, {})
	if base.is_empty() or int(base.max_hp) <= 0:
		return 0
	return clampi(ceili(maxf(0, float(base.hp)) * 100.0 / float(base.max_hp)), 0, 100)

func _pennant(pos: Vector2, color: Color) -> void :
	draw_line(pos, pos + Vector2(0, 16), Color(0.9, 0.9, 0.9), 2)
	draw_colored_polygon(PackedVector2Array([pos, pos + Vector2(12, 4), pos + Vector2(0, 9)]), color)

const VOTE_AGREE_X: float = 27.0
const VOTE_DENY_X: float = 135.0
const VOTE_CELL_STEP: float = 29.0
const VOTE_CLOSE_S: float = 5.0
const VOTE_IMAGES: PackedStringArray = ["", "vote_r", "vote_g", "vote_b"]


func _vote_origin() -> Vector2:
	var s: float = _hud.layout_scale()
	return Vector2(size.x / 2 - 110 * s, 90 * s)


func _vote_button(action: Callable) -> Button:
	var button: Button = _small_button("", action)
	button.custom_minimum_size = Vector2.ZERO
	button.modulate.a = 0.0
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	return button

func _place_vote_button(button: Button, x: float) -> void :
	var s: float = _hud.layout_scale()
	var rect: Rect2 = Rect2(_vote_origin() + Vector2(x, 67) * s, Vector2(57, 27) * s)
	if _touch:
		rect = rect.grow(8 * s)
	button.position = rect.position
	button.size = rect.size


func _vote_cells(vote: Dictionary) -> PackedStringArray:
	var results: Array = vote.get("results", [])
	var count: int = int(vote.count)
	var cells: PackedStringArray = []
	for i in range(5):
		var value: int = 3 if i >= count else (int(results[i]) if i < results.size() else 0)
		cells.append(VOTE_IMAGES[clampi(value, 0, 3)])
	return cells


func _vote_ratio(end: float, remain: float) -> float:
	if end != _vote_end:
		_vote_end = end
		_vote_total = remain
	return clampf(remain / _vote_total, 0, 1) if _vote_total > 0 else 0.0


func _draw_vote_button(button: Button, image: String, x: float) -> void :
	var mode: int = button.get_draw_mode()
	var pressed: bool = mode == BaseButton.DRAW_PRESSED or mode == BaseButton.DRAW_HOVER_PRESSED
	var lit: float = 1.16 if pressed or mode == BaseButton.DRAW_HOVER else 1.0
	var texture: Texture2D = _hud.tex(image)
	if texture != null:
		draw_texture(texture, Vector2(x, 67) + (Vector2.ONE if pressed else Vector2.ZERO), Color(lit, lit, lit, 1.0))



func _draw_vote() -> void :
	var battle = client.battle
	if battle.vote.is_empty():
		return
	var end: float = float(battle.vote.end)
	var remain: float = end - battle.now_seconds()
	var ratio: float = _vote_ratio(end, remain)
	if remain < - VOTE_CLOSE_S:
		return
	var s: float = _hud.layout_scale()
	var full: bool = _agree.visible
	draw_set_transform(_vote_origin(), 0, Vector2(s, s))
	_hud._img("vote_bg" if full else "vote_result_bg", Vector2(25, 0) if full else Vector2.ZERO)
	var first: Vector2 = Vector2(39, 33) if full else Vector2(71, 12)
	var cells: PackedStringArray = _vote_cells(battle.vote)
	for i in range(5):
		if cells[i] != "":
			_hud._img(cells[i], first + Vector2(VOTE_CELL_STEP * i, 0))
	if full:
		var bar: Texture2D = _hud.tex("vote_time_bar")
		if bar != null and ratio > 0:
			draw_texture_rect_region(bar, Rect2(33, 57, 154 * ratio, 4), Rect2(0, 0, 154 * ratio, 4))
		_draw_vote_button(_agree, "vote_agree", VOTE_AGREE_X)
		_draw_vote_button(_deny, "vote_deny", VOTE_DENY_X)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _draw_result() -> void :
	var result: Dictionary = client.battle.result()
	var panel: Rect2 = _result_rect()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.5))
	draw_rect(panel, Color("0b2d58f2"))
	draw_rect(panel, Color("3fb1f5c0"), false, 2)
	var title: String = "HÒA" if result.draw else ("CHIẾN THẮNG" if result.win else "THẤT BẠI")
	var color: Color = Color("ffd25e") if result.win else (Color.WHITE if result.draw else Color("ff8d81"))
	_label(Vector2(panel.position.x, panel.position.y + 48), title, color, 34, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x, _title_font)
	var note: String = "Thời gian trận %s · %s" % [Text.clock(result.seconds), client.battle.title()]
	if result.surrender:

		note = ("Bên Địch Đầu Hàng" if result.win else "Bên Ta Đầu Hàng") + " · " + note
	elif result.draw:
		note = "Hòa! Đội có tổng huy chương thấp hơn sẽ thắng! · " + note
	_label(Vector2(panel.position.x + 12, panel.position.y + 76), note, Color(0.85, 0.9, 1), 15, HORIZONTAL_ALIGNMENT_CENTER, panel.size.x - 24)
	var columns: Array = [["Hạng", 0.0, 50.0], ["Người chơi", 50.0, 0.0], ["Hạ gục", -376.0, 64.0], ["Bị hạ", -308.0, 64.0], 
		["Hỗ trợ", -240.0, 64.0], ["Điểm", -172.0, 64.0], ["Sát thương", -100.0, 100.0]]
	var left: float = panel.position.x + 16
	var right: float = panel.end.x - 16
	var y: float = panel.position.y + 110
	for column: Array in columns:
		var x: float = left + column[1] if column[1] >= 0 else right + column[1]
		_label(Vector2(x, y), column[0], Color(0.7, 0.78, 0.9), 14, HORIZONTAL_ALIGNMENT_LEFT if column[2] == 0 else HORIZONTAL_ALIGNMENT_CENTER, column[2] if column[2] > 0 else -1)
	var rank: int = 0
	for row: Dictionary in result.rows:
		rank += 1
		var top: float = y + 10 + (rank - 1) * 34
		if top + 30 > panel.end.y - 72:
			break
		var tint: Color = Color("73cbff") if _ally(int(row.camp)) else Color("ff8d81")
		draw_rect(Rect2(left, top, right - left, 30), Color("41acf5", 0.28) if row.self else Color("41acf5", 0.08))
		draw_rect(Rect2(left, top, 4, 30), tint)
		var base: float = top + 21
		var cells: Array = [str(rank), str(row.name), str(row.kill), str(row.dead), str(row.assist), str(row.score), str(row.harm)]
		for i in range(cells.size()):
			var column: Array = columns[i]
			var x: float = left + column[1] if column[1] >= 0 else right + column[1]
			var width: float = column[2] if column[2] > 0 else (right - 386) - x
			_label(Vector2(x, base), cells[i], tint if i == 1 else Color.WHITE, 15, HORIZONTAL_ALIGNMENT_LEFT if i == 1 else HORIZONTAL_ALIGNMENT_CENTER, width)

func _bar(pos: Vector2, width: float, fraction: float, color: Color) -> void :
	draw_rect(Rect2(pos - Vector2.ONE, Vector2(width + 2, 7)), Color(0, 0, 0, 0.85))
	draw_rect(Rect2(pos, Vector2(width * clampf(fraction, 0, 1), 5)), color)

func _draw_tank(tank: Dictionary) -> void :
	var pos: Vector2 = tank.pos
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	if tank.dead:

		if pack == null or pack.state != "ready":
			draw_circle(pos, 22, Color(0.16, 0.17, 0.2, 0.8))
		return

	var friendly: bool = (int(tank.id) == client.battle.self_id) if client.battle.mode == "happy" else (int(tank.get("camp", 0)) == _my_camp)
	var color: Color = Color("378ad1") if friendly else Color("cf514e")
	color.a = _alpha

	if RingMesh.enabled:
		_p3_tick()

	var glow: float = 1.0 + 0.8 * clampf(1.0 - (client.battle.clock - float(tank.get("lit", -1000.0))) / 0.1, 0.0, 1.0)
	var rule: Array = _buff_rules(tank)
	var look: Dictionary = client.battle.appearances.get(int(tank.account), {})
	var external: String = str(look.get("external", 0))
	var aim: Vector2 = controls.aim if int(tank.id) == client.battle.self_id and client.battle.alive() else tank.aim
	var look_state: Dictionary = _show_state(tank)
	_hold(tank, look_state.still)
	var rotation: float = _cannon_angle(tank, pos.angle_to_point(aim), rule)
	var art: Dictionary = _ph_art(external, int(look.get("tank", 0)))


	var changed: bool = false
	var bare: bool = false
	if rule[0] > 0 and pack != null and pack.state == "ready":
		if pack.has_external(str(rule[0])):
			var form: Dictionary = pack.external_art(str(rule[0]))
			if form.has("body"):
				art = form
				changed = true
		else:
			bare = true
	var body_swf: Dictionary = _swf(art.get("body"))
	var turret_swf: Dictionary = _swf(art.get("turret"))
	_draw_buffs(tank, true, rotation + PI / 2)
	if bare:
		pass
	elif art.has("body") and ( not body_swf.is_empty() or art.body.data.frames.size() >= 8):
		var moving: bool = pos.distance_to(tank.target) > 0.5

		var zoom0: float = _zoom
		var offset0: Vector2 = _offset
		var grow: float = float(look_state.scale)
		_zoom = zoom0 * grow
		_offset = offset0 + pos * zoom0 * (1 - grow)
		_tint = look_state.tint * Color(glow, glow, glow, _alpha)
		_spin = float(look_state.spin)
		if _gfx.outline:
			_gfx.draw_outline(self, art, body_swf, turret_swf, tank, moving, rotation + PI / 2)
		if not body_swf.is_empty():
			_draw_swf_body(art.body, body_swf, tank, moving)
		else:
			_draw_png_body(art.body, tank, moving)
		_draw_speed(tank, moving, rule)
		if not art.has("turret"):
			pass
		elif turret_swf.has("idle"):
			_draw_swf_cannon(art.turret, turret_swf, tank, rotation + PI / 2)
		elif not turret_swf.is_empty():
			_ph_layer_cannon(art.turret, turret_swf, tank, rotation + PI / 2)
		else:
			_draw_png_cannon(art.turret, tank, rotation + PI / 2)
		_zoom = zoom0
		_offset = offset0
		_tint = Color.WHITE
		_spin = 0.0
		draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	elif pack == null or pack.state != "ready":
		draw_set_transform(_offset + pos * _zoom, (int(tank.direction) - 1) * PI / 4, Vector2(_zoom, _zoom))
		draw_rect(Rect2(-33, -33, 12, 66), Color("252c37"))
		draw_rect(Rect2(21, -33, 12, 66), Color("252c37"))
		draw_rect(Rect2(-24, -30, 48, 60), color)
		draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
		draw_line(pos, pos + Vector2.from_angle(rotation) * 46, Color("252c37"), 13, true)
		draw_line(pos, pos + Vector2.from_angle(rotation) * 46, color.lightened(0.3), 7, true)
		draw_circle(pos, 17, color.lightened(0.2))
	_draw_pet(tank)
	_draw_buffs(tank, false, rotation + PI / 2)
	_draw_hurt(tank)
	_draw_face(tank, tank.pos)








var _pet_gate: Array = [0, false]
const PET_HIDDEN_ROOM: int = 12
func _draw_pet(tank: Dictionary) -> void :
	if pack == null or pack.state != "ready" or not _pet_game():
		return
	var other: Dictionary = Hud.brief_of(client.battle, int(tank.account)).get("otherData", {})
	var pet: Array = pack.pet_of(int(other.get("btItemId", 0)))
	if pet.is_empty():
		return
	var at: Vector2 = Vector2(float(pet[1]), float(pet[2]))

	var rank: int = int(other.get("btRank", 0))
	for key: String in [pack.pet_star(rank), str(pet[0]), pack.pet_star_front(rank)]:
		var asset: Dictionary = pack.effect(key)
		if not asset.is_empty():
			_fx.frame(asset, int(_time * Fx.FPS) % maxi(1, asset.data.frames.size()), tank.pos, 0.0, at, Color(1, 1, 1, _alpha))


func _pet_game() -> bool:
	var key: int = hash([client.battle.get_instance_id(), int(client.battle.map_id), int(client.battle.room_type)])
	if int(_pet_gate[0]) != key:
		_pet_gate = [key, client.get("room_state") != null and int(client.battle.room_type) != PET_HIDDEN_ROOM\
		and BattleLoading.helper_game(client)]
	return bool(_pet_gate[1])




const FACE_WAIT: float = 1.5
func _tick_faces(battle) -> void :
	if battle.faced.is_empty():
		return
	for id: int in battle.faced.keys():
		var obj: Dictionary = battle.actor(id)
		if obj.is_empty() or not obj.has("face"):
			battle.faced.erase(id)
			continue
		var face: Dictionary = obj.face
		var key: String = pack.face_key(int(face.id)) if pack != null and pack.state == "ready" else ""
		var asset: Dictionary = pack.effect(key) if not key.is_empty() else {}
		var gone: bool = false
		if asset.is_empty():
			gone = (pack != null and pack.state == "ready" and pack.effect_failed(key)) or battle.clock - float(face.at) > FACE_WAIT
		else:
			if not face.has("t0"):
				face["t0"] = battle.clock
			gone = int((battle.clock - float(face.t0)) * Fx.FPS) >= asset.data.frames.size()
		if gone:
			obj.erase("face")
			battle.faced.erase(id)

func _draw_face(obj: Dictionary, pos: Vector2) -> void :
	if not obj.has("face") or not obj.face.has("t0") or pack == null:
		return
	var asset: Dictionary = pack.effect(pack.face_key(int(obj.face.id)))
	if asset.is_empty():
		return
	var count: int = asset.data.frames.size()
	_fx.frame(asset, mini(int((client.battle.clock - float(obj.face.t0)) * Fx.FPS), count - 1), pos, 0.0, Vector2.ZERO, Color(1, 1, 1, _alpha))






const FAMULUS_ROOMS: Array[int] = [3, 4, 7, 12, 14, 51]
func _famulus_room() -> bool:
	if int(Text.map_info(int(client.battle.map_id)).get("modeType", -1)) == 8:
		return false
	return int(client.battle.room_type) in FAMULUS_ROOMS

func _draw_famulus(tank: Dictionary) -> void :
	if pack == null or pack.state != "ready" or client.battle.roster.is_empty():
		return
	if not tank.has("famulus"):
		var other: Dictionary = {}
		for brief: Variant in client.battle.roster:
			if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) == int(tank.account):
				other = brief.get("otherData") if brief.get("otherData") is Dictionary else {}
				break
		var row: Array = pack.famulus(int(other.get("btItemId", 0))) if _famulus_room() else []
		var rank: int = int(other.get("btRank", 0))

		var wings: Array = pack.famulus_wings(rank) if rank >= 10 else []
		if row.size() < 3:
			tank.famulus = []
		elif wings.size() >= 2:
			tank.famulus = [str(wings[0]), str(row[0]), str(wings[1]), Vector2(float(row[1]), float(row[2]))]
		else:
			tank.famulus = ["", str(row[0]), pack.famulus_star(rank), Vector2(float(row[1]), float(row[2]))]
	var famulus: Array = tank.famulus
	if famulus.is_empty():
		return
	var at: Vector2 = tank.pos + famulus[3]
	for key: String in [famulus[0], famulus[1], famulus[2]]:
		if key.is_empty():
			continue
		var asset: Dictionary = pack.effect(key)
		if asset.is_empty() or asset.data.frames.is_empty():
			continue
		_fx.frame(asset, int(_time * Fx.FPS) % asset.data.frames.size(), at, 0.0, Vector2.ZERO, Color(1, 1, 1, _alpha))


func _draw_hurt(tank: Dictionary) -> void :
	if not _gfx.keep_hurt():
		return
	if pack == null or int(tank.max_hp) <= 0 or int(tank.hp) * 100 / int(tank.max_hp) > 40:
		tank.erase("hurt_seen")
		return
	var asset: Dictionary = pack.effect(pack.tank_hurt())
	if asset.is_empty():
		return
	if not tank.has("hurt_seen"):
		tank.hurt_seen = _time
	var count: int = asset.data.frames.size()
	_fx.frame(asset, int((_time - float(tank.hurt_seen)) * Fx.FPS) % count, tank.pos, 0.0, Vector2.ZERO, Color(1, 1, 1, _alpha))


func _show_state(obj: Dictionary) -> Dictionary:
	if pack == null or obj.buffs.is_empty():
		return SHOW_PLAIN
	var state: Dictionary = {"scale": 1.0, "tint": Color.WHITE, "spin": 0.0, "still": false}
	var still: int = 0
	for buff: Dictionary in obj.buffs.values():
		var row: Array = pack.buff_show(int(buff.get("m_nBuffTpltId", 0)))
		if row.is_empty():
			continue
		match int(row[0]):
			2, 7:
				still = int(row[0])
			3:
				if still == 0:
					still = 3
			4:
				state.scale = 0.7
			6:
				state.scale = 1.3
			1:
				if int(buff.get("m_nBuffTpltId", 0)) == BattleState.TORNADO_LIFT:
					state.spin = fposmod((client.battle.clock - float(buff.get("t0", client.battle.clock))) * TAU * LIFT_TURNS, TAU)
			5:
				state.spin = fposmod((client.battle.clock - float(buff.get("t0", client.battle.clock))) * TAU * 2.0, TAU)

	if still == 2:
		state.tint = Color(0.62, 0.6, 0.58)
	elif still == 3:
		state.tint = Color(0.55, 0.85, 1.35)
	elif still == 7:
		state.tint = Color(1.45, 1.25, 0.5)
	state.still = still != 0
	return state



func _hold(obj: Dictionary, still: bool) -> void :
	if not still:
		obj.erase("still_at")
	elif not obj.has("still_at"):
		obj.still_at = _time







const THROW_SHADOW_SIZE: Vector2 = Vector2(88, 62)
const THROW_SHADOW_ALPHA: float = 0.5
const THROW_SHADOW_DROP: Vector2 = Vector2(80, 80)
var _throw_shadow_tex: Texture2D = null


static func throw_height(obj: Dictionary) -> float:
	if not obj.has("throw"):
		return 0.0
	var throw: Dictionary = obj.throw
	return sin(clampf(float(throw.t) / maxf(float(throw.duration), 0.001), 0, 1) * PI)


static func throw_shadow(pos: Vector2, h: float, alpha: float = 1.0) -> Array:
	return [pos + THROW_SHADOW_DROP * h, THROW_SHADOW_SIZE * (1.0 - 0.25 * h), THROW_SHADOW_ALPHA * (1.0 - 0.2 * h) * alpha]


static func throw_shadow_image() -> Image:
	var side: int = 64
	var data: PackedByteArray = PackedByteArray()
	data.resize(side * side * 4)
	for y in range(side):
		for x in range(side):
			var d: float = Vector2(x + 0.5 - side / 2.0, y + 0.5 - side / 2.0).length() / (side / 2.0)
			data[(y * side + x) * 4 + 3] = int(round(255.0 * (1.0 - smoothstep(0.5, 1.0, d))))
	return Image.create_from_data(side, side, false, Image.FORMAT_RGBA8, data)

func _draw_throw_shadows(battle, view: Rect2) -> void :
	for tank: Dictionary in battle.tanks.values():
		if tank.has("throw") and not tank.dead and not tank.get("hidden", false) and view.has_point(tank.pos):
			_draw_throw_shadow(tank, throw_shadow(tank.pos, throw_height(tank), tank_alpha(tank)))

func _draw_throw_shadow(_tank: Dictionary, shade: Array) -> void :
	if _throw_shadow_tex == null:
		_throw_shadow_tex = ImageTexture.create_from_image(throw_shadow_image())
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	draw_texture_rect(_throw_shadow_tex, Rect2(shade[0] - shade[1] / 2.0, shade[1]), false, Color(1, 1, 1, shade[2]))



func _fly(tank: Dictionary, battle) -> Vector3:
	if pack == null:
		return Vector3(0, 0, 1)
	var fall: float = battle.lift_fall(tank)
	if fall >= 0.0:
		var drop: float = _bounce_out(fall / BattleState.LIFT_FALL)
		return Vector3(0, - BattleState.LIFT_HEIGHT * (1.0 - drop), 1.2 - 0.2 * drop)
	for buff: Dictionary in tank.buffs.values():
		var row: Array = pack.buff_show(int(buff.get("m_nBuffTpltId", 0)))
		if row.is_empty() or int(row[0]) != 1 or not buff.has("t0"):
			continue
		var total: float = float(row[1]) / 1000.0
		var t: float = battle.clock - float(buff.t0)
		var lift: bool = int(buff.get("m_nBuffTpltId", 0)) == BattleState.TORNADO_LIFT
		if total <= 0 or t < 0 or (t >= total and not lift):
			continue
		var height: float = 0.5 * 30.0 * total * total
		var half: float = total / 2.0
		if t < half:
			var p: float = 1.0 - pow(1.0 - t / half, 4)
			return Vector3(0, - height * p, 1.0 + 0.2 * p)
		if lift:
			return Vector3(0, - height + LIFT_BOB * sin((t - half) * TAU * 2.0), 1.2)
		var q: float = _bounce_out((t - half) / half)
		return Vector3(0, - height * (1.0 - q), 1.2 - 0.2 * q)
	return Vector3(0, 0, 1)

static func _bounce_out(t: float) -> float:
	if t < 1.0 / 2.75:
		return 7.5625 * t * t
	if t < 2.0 / 2.75:
		t -= 1.5 / 2.75
		return 7.5625 * t * t + 0.75
	if t < 2.5 / 2.75:
		t -= 2.25 / 2.75
		return 7.5625 * t * t + 0.9375
	t -= 2.625 / 2.75
	return 7.5625 * t * t + 0.984375




func _draw_buffs(obj: Dictionary, under: bool, cannon: float) -> void :

	var bush: bool = int(obj.get("turf", 0)) != 0 and client.battle.tanks.has(int(obj.id))
	if not bush:
		obj.erase("bush_buff")
	if pack == null or (obj.buffs.is_empty() and not bush):
		return
	var list: Array = obj.buffs.values()
	if bush:
		if not obj.has("bush_buff"):
			obj["bush_buff"] = {"m_nBuffTpltId": BUSH_BUFF}
		list.append(obj.bush_buff)
	var shown: Dictionary = {}
	for buff: Dictionary in list:
		var template: int = int(buff.get("m_nBuffTpltId", 0))
		if template == LEVEL_RING and obj.has("account"):

			var worn: int = int(client.battle.appearances.get(int(obj.account), {}).get("halo", 0))
			template = int(pack.lobby.get("halos", {}).get(str(worn), LEVEL_RING))
		if shown.has(template):
			continue
		shown[template] = true
		var row: Array = pack.buff(template)
		if row.is_empty() or (int(row[1]) == 1 or int(row[1]) == 2) != under:
			continue
		var asset: Dictionary = pack.effect(str(row[0]))
		if asset.is_empty():
			continue
		if not buff.has("seen"):
			buff.seen = _time
		var angle: float = 0.0
		match int(row[2]):
			1:
				angle = _face_angle(obj) if client.battle.tanks.has(int(obj.id)) else (int(obj.direction) - 1) * PI / 4
			2:
				angle = cannon
			4:
				var caster: Dictionary = client.battle.actor(int(buff.get("m_nCasterId", 0)))
				if not caster.is_empty() and caster.pos != obj.pos:
					angle = Fx.rotation(caster.pos, obj.pos)
		var count: int = asset.data.frames.size()
		_fx.frame(asset, int((_time - float(buff.seen)) * Fx.FPS) % count, obj.pos, angle, _centered(asset, true), Color(1, 1, 1, _alpha))


static func _centered(asset: Dictionary, floor_half: bool) -> Vector2:
	var stage: Variant = asset.data.get("stage")
	if not stage is Array or stage.size() < 2 or float(stage[0]) <= 1:
		return Vector2.ZERO
	var half: Vector2 = Vector2(float(stage[0]), float(stage[1])) / 2
	return Vector2(floorf( - half.x), floorf( - half.y)) if floor_half else - half




func _draw_item(item: Dictionary, battle) -> bool:
	var row: Dictionary = pack.item(int(item.template)) if pack != null else {}
	if row.is_empty():
		return false
	if not item.has("seen"):
		item.seen = _time
	var camp: int = int(item.camp)
	var own: bool = camp != 0 and camp == _my_camp
	var radius: float = float(row.get("r", 0))
	if radius > 0:
		_camp_ring(item.pos, radius, camp, own)
	var angle: float = 0.0
	if int(row.get("ro", 0)) != 0:

		var from: Variant = item.get("owner_at")
		if from is Vector2 and from != item.pos:
			angle = Fx.rotation(from, item.pos)
	var icon: Dictionary = pack.effect(str(row.get("i", "")))
	if not icon.is_empty():
		var size: Array = icon.data.get("stage", [0, 0])
		_fx.frame(icon, 0, item.pos, angle, Vector2( - int(float(size[0]) / 2), - int(float(size[1]) / 2)))
	var key: String = str(row.get("n", "")) if camp == 0 else str(row.get("o" if own else "e", ""))
	var cover: Dictionary = pack.effect(key)
	if not cover.is_empty():
		var count: int = cover.data.frames.size()
		var index: int = int((_time - float(item.seen)) * Fx.FPS)
		var plays: int = int(row.get("p", 0))
		index = count - 1 if plays > 0 and index >= count * plays else index % count
		_fx.frame(cover, index, item.pos, angle, _centered(cover, false))
	return true


func _camp_ring(pos: Vector2, radius: float, camp: int, own: bool) -> void :
	var c: Color = Color("ffff00") if camp == 0 else (Color("28baee") if own else Color("fe1c0b"))
	var d: Color = Color("ffff00") if camp == 0 else Color.hex((8364525 if own else 15570047) << 8 | 255)
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))
	var outer: float = radius + 1.5
	if _p3_camp(pos, outer, c, d):
		return
	for step in range(6):
		var u: float = (float(step) + 0.5) / 6.0
		var color: Color = c if u < 0.5 else c.lerp(d, (u - 0.5) * 2)
		color.a = u * 2 if u < 0.5 else lerpf(1.0, 0.1, (u - 0.5) * 2)
		draw_arc(pos, outer - 6 + step + 0.5, 0, TAU, 72, color, 1.0, true)


func _p3_tick() -> void :
	var f: int = Engine.get_process_frames()
	if f != _p3.frame:
		_p3.tick(f, [size, _hud.layout_scale(), camera_zoom, look_zoom, Settings.render_k])


func _p3_tank(pos: Vector2, color: Color) -> bool:
	if not RingMesh.enabled:
		return false
	_p3_tick()
	return _p3.tank(get_canvas_item(), pos, color)


func _p3_camp(pos: Vector2, outer: float, c: Color, d: Color) -> bool:
	if not RingMesh.enabled:
		return false
	_p3_tick()
	var ci: RID = get_canvas_item()
	var key: Array = [pos, outer, c, d]
	if _p3.camp(ci, key):
		return true
	if not _p3.can_build():
		_p3.camp_miss += 1
		return false
	var arcs: Array = []
	for step in range(6):
		var u: float = (float(step) + 0.5) / 6.0
		var color: Color = c if u < 0.5 else c.lerp(d, (u - 0.5) * 2)
		color.a = u * 2 if u < 0.5 else lerpf(1.0, 0.1, (u - 0.5) * 2)
		arcs.append([outer - 6 + step + 0.5, color])
	return _p3.camp_build(ci, key, pos, arcs)


static func _xml(part: Dictionary) -> Dictionary:
	var value: Variant = part.data.get("xml")
	return value if value is Dictionary else {}




func _draw_png_body(body: Dictionary, tank: Dictionary, moving: bool) -> void :
	var xml: Dictionary = _xml(body)
	var total: int = body.data.frames.size()
	var per: int = int(xml.get("a", 0))
	if per <= 0:
		per = maxi(1, total / 8)
	var angle: float = _face_angle(tank, int(xml.get("d", 0)) == 1)
	var step: int = roundi(angle / (PI / 4))
	var first: int = mini(posmod(step, 8) * per, total - 1)
	var count: int = clampi(total - first, 1, per)
	var attack: int = int(xml.get("g", 0)) - 1
	var loop: int = attack if attack > 0 and attack < count else count
	var index: int
	var since: float = float(tank.get("attack", 99.0))
	if tank.has("still_at"):
		index = int(_body_tick(int(tank.id), 0.0) * 12.0) % loop
	elif attack > 0 and attack < count and since * 12.0 < count - attack:
		index = attack + int(since * 12.0)
		_body_clock[int(tank.id)] = [0.0, _time]
	else:

		var gait: String = _gait(tank, moving)
		var rate: float = 2.0 if gait == "rush" else (1.0 if gait == "move" or int(xml.get("e", 0)) == 1 else 0.0)
		index = int(_body_tick(int(tank.id), rate) * 12.0) % loop
	_atlas(body, first + index, tank.pos, angle - step * PI / 4 + _spin)



static func _gait(tank: Dictionary, moving: bool) -> String:
	return str(tank.get("gait", "move")) if moving else "idle"

func _body_tick(id: int, rate: float) -> float:
	var clock: Array = _body_clock.get(id, [0.0, _time])
	if rate > 0:
		clock[0] += (_time - float(clock[1])) * rate
	clock[1] = _time
	_body_clock[id] = clock
	return float(clock[0])



func _draw_png_cannon(turret: Dictionary, tank: Dictionary, rotation: float) -> void :
	var xml: Dictionary = _xml(turret)
	var total: int = turret.data.frames.size()
	var interval: int = int(xml.get("b", turret.data.get("timeline", {}).get("ticks_per_frame", 0)))
	var index: int = 0
	if interval > 0 and total > 1:
		if int(xml.get("d", 0)) == 1:
			index = int(_time * 24.0 / interval) % total
		elif tank.has("fired") and float(tank.fired) * 24.0 < interval * total:
			index = int(float(tank.fired) * 24.0 / interval)
	var fixed: int = int(xml.get("e", 0))
	var angle: float = deg_to_rad(fixed) if fixed != 0 else rotation
	var at: Vector2 = _cannon_pos(tank, rotation)
	_atlas(turret, index, at, angle)

	if _fire_tex != null and int(xml.get("f", 0)) == 0 and tank.has("fired") and Settings.on("skill_fx"):
		var tick: int = int(float(tank.fired) * 24.0) / 2
		if tick < 5:
			draw_set_transform(_offset + at * _zoom, angle, Vector2(_zoom, _zoom))
			draw_texture_rect_region(_fire_tex, Rect2(-57, -140, 112, 149), Rect2(tick * 112, 0, 112, 149))
			draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))


func _cannon_pos(tank: Dictionary, rotation: float) -> Vector2:
	var since: float = float(tank.get("fired", 99.0))
	if since >= 0.3:
		return tank.pos
	var done: float = (sin(PI * (since / 0.3 - 0.5)) + 1.0) / 2.0
	return tank.pos + Vector2( - sin(rotation), cos(rotation)) * roundf(20.0 * (1.0 - done))


static func _swf(part: Variant) -> Dictionary:
	if not part is Dictionary or not part.has("data"):
		return {}
	var runtime: Variant = part.data.get("runtime")
	return runtime.swf if runtime is Dictionary and runtime.get("swf") is Dictionary else {}




static func _swf_frame(layer: Dictionary, state: String, time: float) -> int:
	var count: int = maxi(1, int(layer.count))
	var labels: Variant = layer.get("labels")
	if labels is Dictionary and not labels.is_empty():
		var first: int = int(labels.get(state, labels.get("move", 0)))
		var last: int = count
		for value: Variant in labels.values():
			if int(value) > first:
				last = mini(last, int(value))
		return clampi(first + int(time * 24.0) % maxi(1, last - first), 0, count - 1)
	var delta: int = 2 if state == "rush" else 1
	return int(time * (12.0 if state == "idle" else 24.0)) % maxi(1, (count + delta - 2) / delta) * delta


func _face_angle(tank: Dictionary, instant: bool = false) -> float:
	var target: float = posmod(int(tank.direction) - 1, 8) * PI / 4
	var face: Dictionary = _face.get(int(tank.id), {})
	if face.is_empty() or instant:
		face = {"from": target, "to": target, "t0": _time}
		_face[int(tank.id)] = face
	elif not is_equal_approx(float(face.to), target):
		face.from = _face_now(face)
		face.to = target
		face.t0 = _time
		face.dur = 0.125 if str(tank.get("gait", "")) == "rush" else 0.25
	return _face_now(face)

func _face_now(face: Dictionary) -> float:
	return lerp_angle(float(face.from), float(face.to), clampf((_time - float(face.t0)) / float(face.get("dur", 0.25)), 0.0, 1.0))


func _draw_swf_body(part: Dictionary, swf: Dictionary, tank: Dictionary, moving: bool) -> void :
	var angle: float = _face_angle(tank, int(_xml(part).get("d", 0)) == 1)
	var state: String = _gait(tank, moving)
	var clock: float = float(tank.get("still_at", _time))
	var shown: int = 0
	for layer: Dictionary in swf.get("layers", []):
		if str(layer.name) == "body":
			shown = _swf_frame(layer, state, clock)
	for layer: Dictionary in swf.get("layers", []):
		if _gfx.skip_layer(layer):
			continue
		var index: int = shown
		if str(layer.name) != "body":
			var labels: Variant = layer.get("labels")
			index = _swf_frame(layer, state, clock) if labels is Dictionary and not labels.is_empty() else mini(shown, int(layer.count) - 1)
		var m: Array = layer.matrix
		var scale: Vector2 = Vector2(Vector2(m[0], m[1]).length(), Vector2(m[2], m[3]).length())
		_swf_draw(part, int(layer.first) + index, Transform2D(angle + _spin, scale, 0.0, tank.pos + Vector2(m[4], m[5])))


func _draw_swf_cannon(part: Dictionary, swf: Dictionary, tank: Dictionary, rotation: float) -> void :
	var segment: Dictionary = swf.idle
	var index: int = int(float(tank.get("still_at", _time)) * 24.0) % maxi(1, int(segment.count))
	var fire: Variant = swf.get("fire")
	if fire is Dictionary and tank.has("fired") and float(tank.fired) * 24.0 < float(fire.count) and not tank.has("still_at"):
		segment = fire
		index = int(float(tank.fired) * 24.0)
	var m: Array = segment.matrix
	var local: Transform2D = Transform2D(Vector2(m[0], m[1]), Vector2(m[2], m[3]), Vector2(m[4], m[5]))
	_swf_draw(part, int(segment.first) + index, Transform2D(rotation, _cannon_pos(tank, rotation)) * local)


func _swf_draw(part: Dictionary, index: int, world: Transform2D) -> void :
	var frames: Array = part.data.frames
	var frame: Dictionary = frames[clampi(index, 0, frames.size() - 1)]
	var r: Array = frame.rect
	var pivot: Array = frame.pivot
	draw_set_transform_matrix(Transform2D(0.0, Vector2(_zoom, _zoom), 0.0, _offset) * world)
	draw_texture_rect_region(part.pages[int(frame.page)], Rect2( - float(pivot[0]), - float(pivot[1]), float(r[2]), float(r[3])), Rect2(r[0], r[1], r[2], r[3]), _tint)
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))

func _atlas(part: Dictionary, index: int, pos: Vector2, rotation: float) -> void :
	var frame: Dictionary = part.data.frames[index]
	var r: Array = frame.rect
	var pivot: Array = frame.pivot
	draw_set_transform(_offset + pos * _zoom, rotation, Vector2(_zoom, _zoom))
	draw_texture_rect_region(part.pages[int(frame.page)], Rect2( - float(pivot[0]), - float(pivot[1]), float(r[2]), float(r[3])), Rect2(r[0], r[1], r[2], r[3]), _tint)
	draw_set_transform(_offset, 0, Vector2(_zoom, _zoom))


const EDGE_FADE: float = 56.0
const EDGE_BG: Color = Color("172127")
func _edge_fade(extent: Vector2) -> void :
	var clear: Color = Color(EDGE_BG, 0.0)
	var dark: Color = Color(EDGE_BG, 0.85)
	var f: float = minf(EDGE_FADE, minf(extent.x, extent.y) / 4.0)
	var bands: Array = [
		[Vector2(0, 0), Vector2(extent.x, 0), Vector2(extent.x - f, f), Vector2(f, f)], 
		[Vector2(extent.x, 0), Vector2(extent.x, extent.y), Vector2(extent.x - f, extent.y - f), Vector2(extent.x - f, f)], 
		[Vector2(extent.x, extent.y), Vector2(0, extent.y), Vector2(f, extent.y - f), Vector2(extent.x - f, extent.y - f)], 
		[Vector2(0, extent.y), Vector2(0, 0), Vector2(f, f), Vector2(f, extent.y - f)], 
	]
	for band: Array in bands:
		draw_polygon(PackedVector2Array(band), PackedColorArray([dark, dark, clear, clear]))

func _draw_touch() -> void :
	_lq.draw(self, client.battle)






const ClUiSettings = preload("res://ui/settings.gd")
const ClTip = preload("res://ui/ctool_tip.gd")
const CL_EDGE: float = 24.0
const CL_SPEED: float = 900.0
const CL_EASE: float = 0.08
const CL_STEP_MAX: float = 0.05
const CL_ALPHA_OFF: float = 0.45
const CL_TIP_FREE: String = "Đang lia tự do — bấm để khóa camera về tank"
const CL_TIP_LOCK: String = "Đang khóa theo tank — bấm để bật lia camera"
var cam_free: bool = false
var _cl_center: Vector2 = Vector2.ZERO
var _cl_vel: Vector2 = Vector2.ZERO
var _cl_inside: bool = false
var _cl_drag: bool = false
var _cl_last: Vector2 = Vector2.ZERO
var _cl_mouse: Vector2 = Vector2(-1000000000.0, -1000000000.0)
var _cl_stamp: Array = [-1, -1]
var _cl_init: bool = false
var _cl_dead: bool = false
var _cl_btn_down: bool = false
var _cl_rect: Rect2 = Rect2()
var _cl_rect_frame: int = -10
var _cl_hand: bool = false
var _cl_tip_hush: bool = false
var _cl_tip: ClTip = ClTip.new()
var cl_test_pointer: Variant = null





func _cl_frame(delta: float, me: Dictionary, battle, center: Vector2) -> Vector2:
	if int(battle.begun) != int(_cl_stamp[0]):
		_cl_stamp = [int(battle.begun), -1]
		_cl_init = false
		_cl_dead = false
		_cl_reset()
	if int(battle.self_spawns) != int(_cl_stamp[1]):
		_cl_stamp[1] = int(battle.self_spawns)
		if int(battle.self_spawns) > 0 and not me.is_empty():
			var revive: bool = _cl_init and _cl_dead
			var keep: bool = _cl_init and not _cl_dead and cam_free
			_cl_init = true
			_cl_dead = false
			if revive:
				_cl_back(me)
			elif not keep:
				_cl_reset()
	var gone: bool = not me.is_empty() and bool(me.get("dead", false))
	if gone and not _cl_dead:
		_cl_dead = true
		_cl_stop()
	elif _cl_dead and not gone and not me.is_empty():
		_cl_dead = false
		_cl_back(me)
	var mouse: Vector2 = _cl_pointer()
	if mouse != _cl_mouse:
		_cl_mouse = mouse
		_cl_inside = true
	_cl_cursor(_cl_btn_hit(mouse))
	if not cam_free or _cl_dead:
		_cl_vel = Vector2.ZERO
		return center
	if not _cl_allowed(me) or not _cl_inside or _cl_drag:
		_cl_vel = Vector2.ZERO
		return _cl_center
	var s: float = _hud.layout_scale()
	var bounds: Rect2 = _cl_bounds(battle)
	var p: Vector2 = mouse - bounds.position
	if s <= 0.0 or _zoom <= 0.0 or p.x < 0.0 or p.y < 0.0 or p.x > bounds.size.x or p.y > bounds.size.y:
		_cl_vel = Vector2.ZERO
		return _cl_center
	var step: Array = cl_step(cl_edge(p, bounds.size, CL_EDGE * s), _cl_vel, size / _zoom, bounds.size / s, delta, CL_SPEED * Settings.pan_scale())
	_cl_vel = step[1]
	_cl_center += step[0]
	return _cl_center


func _cl_bounds(battle) -> Rect2:
	var extent: Vector2 = battle.map.extent
	var left: float = size.x / 2.0 - _camera.x * _zoom
	var x0: float = maxf(0.0, left)
	var x1: float = minf(size.x, left + extent.x * _zoom)
	return Rect2(x0, 0.0, maxf(0.0, x1 - x0), size.y)


static func cl_edge(p: Vector2, span: Vector2, band: float) -> Vector2:
	var d: Vector2 = Vector2(_cl_axis(p.x, span.x, band), _cl_axis(p.y, span.y, band))
	if d.length() > 1.0:
		d = d.normalized()
	return d

static func _cl_axis(v: float, w: float, band: float) -> float:
	if band <= 0.0:
		return 0.0
	if v < band:
		return - (band - v) / band
	if v > w - band:
		return (v - w + band) / band
	return 0.0




static func cl_step(d: Vector2, vel: Vector2, view: Vector2, span: Vector2, elapsed: float, speed: float = CL_SPEED) -> Array:
	var e: float = clampf(elapsed, 0.0, CL_STEP_MAX)
	var target: Vector2 = Vector2(d.x * speed * view.x / maxf(span.x, 1.0), d.y * speed * view.y / maxf(span.y, 1.0))
	var decay: float = exp( - e / CL_EASE)
	var move: Vector2 = target * e + (vel - target) * CL_EASE * (1.0 - decay)
	var next: Vector2 = target + (vel - target) * decay
	if d.x == 0.0 and absf(next.x) < 0.5:
		next.x = 0.0
	if d.y == 0.0 and absf(next.y) < 0.5:
		next.y = 0.0
	return [move, next]

func _cl_pointer() -> Vector2:
	if cl_test_pointer is Vector2:
		return cl_test_pointer
	if not is_inside_tree():
		return Vector2(-1000000000.0, -1000000000.0)
	return get_local_mouse_position()


func _cl_allowed(me: Dictionary) -> bool:
	if me.is_empty() or bool(me.get("dead", false)) or _cl_dead or chat_open:
		return false
	if client == null or client.battle.ended:
		return false
	if _settings != null and _settings.visible:
		return false
	var focus: Control = get_viewport().gui_get_focus_owner() if is_inside_tree() else null
	return not (focus is LineEdit or focus is TextEdit)



func _cl_key(event: InputEvent) -> bool:
	var key: InputEventKey = event as InputEventKey
	if key == null or _touch or client == null or client.battle.look:
		return false
	var code: int = ClUiSettings.flash_code(key)
	if code <= 0 or key.alt_pressed or (key.ctrl_pressed and code != 17) or (key.shift_pressed and code != 16):
		return false
	var action: int = client.key_action(code)
	if not action in ClUiSettings.CAMERA:
		return false
	var me: Dictionary = client.battle.tanks.get(client.battle.self_id, {})
	if not _cl_allowed(me):
		return false
	if is_inside_tree():
		get_viewport().set_input_as_handled()
	if action == 89:
		cam_set_free( not cam_free)
	else:
		_cl_drag = false
		_cl_vel = Vector2.ZERO
		_cl_home(me)
	return true


func cam_set_free(on: bool) -> void :
	cam_free = on
	_cl_drag = false
	_cl_vel = Vector2.ZERO
	if not on and client != null:
		_cl_home(client.battle.tanks.get(client.battle.self_id, {}))


func _cl_home(me: Dictionary) -> void :
	if me.is_empty():
		return
	_hud._map_hold = false
	_cl_center = me.pos
	_free_box_at = me.pos



func _cl_input(event: InputEvent) -> bool:
	if _touch or client == null or client.battle.look:
		return false
	var me: Dictionary = client.battle.tanks.get(client.battle.self_id, {})
	if event is InputEventMouseMotion:
		_cl_inside = true
		if not _cl_drag:
			return false
		if not cam_free or not _cl_allowed(me):
			_cl_drag = false
			return false
		if _zoom > 0.0:
			_cl_center += (_cl_last - event.position) / _zoom
		_cl_last = event.position
		accept_event()
		return true
	var button: InputEventMouseButton = event as InputEventMouseButton
	if button == null:
		return false
	match button.button_index:
		MOUSE_BUTTON_MIDDLE:
			if button.pressed:
				if button.ctrl_pressed or button.alt_pressed or not cam_free or not _cl_allowed(me):
					return false
				_cl_drag = true
				_cl_vel = Vector2.ZERO
				_cl_last = button.position
				accept_event()
				return true
			if _cl_drag:
				_cl_drag = false
				accept_event()
				return true
		MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
			if _cl_btn_hit(button.position):
				accept_event()
				return true
		MOUSE_BUTTON_LEFT:
			if button.pressed:
				_cl_tip_hush = true
				_cl_btn_down = _cl_btn_hit(button.position)
				if not _cl_btn_down:
					return false
				if chat_open:
					close_chat()
				grab_focus()
				accept_event()
				return true
			if _cl_btn_down:
				_cl_btn_down = false
				if _cl_btn_hit(button.position) and _cl_allowed(me):
					cam_set_free( not cam_free)
				accept_event()
				return true
	return false

func _cl_btn_hit(pos: Vector2) -> bool:
	return _cl_rect.size.x > 0.0 and _cl_rect.has_point(pos) and Engine.get_process_frames() - _cl_rect_frame <= 2\
	and client != null and not client.battle.ended


func _cl_reset() -> void :
	cam_free = false
	_cl_vel = Vector2.ZERO
	_cl_inside = false
	_cl_drag = false
	_cl_btn_down = false
	_cl_mouse = _cl_pointer()


func _cl_back(me: Dictionary) -> void :
	_cl_stop()
	_cl_home(me)


func _cl_stop() -> void :
	_cl_vel = Vector2.ZERO
	_cl_drag = false
	_cl_btn_down = false


func _cl_blur() -> void :
	_cl_vel = Vector2.ZERO
	_cl_inside = false
	_cl_drag = false


func _cl_cursor(hover: bool) -> void :
	if hover == _cl_hand:
		return
	_cl_hand = hover
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if hover else Control.CURSOR_ARROW


static func cl_round(r: Rect2, radius: float, steps: int = 4) -> PackedVector2Array:
	var k: float = minf(radius, minf(r.size.x, r.size.y) / 2.0)
	if k <= 0.0:
		return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	var centers: Array[Vector2] = [Vector2(r.end.x - k, r.position.y + k), Vector2(r.end.x - k, r.end.y - k), 
		Vector2(r.position.x + k, r.end.y - k), Vector2(r.position.x + k, r.position.y + k)]
	var points: PackedVector2Array = PackedVector2Array()
	for c in range(4):
		for i in range(steps + 1):
			var angle: float = - PI / 2.0 + float(c) * PI / 2.0 + PI / 2.0 * float(i) / float(steps)
			points.append(centers[c] + Vector2(cos(angle), sin(angle)) * k)
	return points

func _cl_shape(points: PackedVector2Array, fill: Color, line: Color, width: float) -> void :
	if fill.a > 0.0:
		draw_colored_polygon(points, fill)
	if width > 0.0 and line.a > 0.0:
		var ring: PackedVector2Array = points.duplicate()
		ring.append(points[0])
		draw_polyline(ring, line, width, true)



func _cl_draw_button(battle) -> void :
	_cl_rect = Rect2()
	if _touch or battle.look or not _hud.rects.has("sig1"):
		return
	var s: float = _hud.scale
	if s <= 0.0:
		return
	var sig: Rect2 = _hud.rects["sig1"]
	var at: Vector2 = sig.position - Vector2(0.0, 34.0) * s
	_cl_rect = Rect2(at, Vector2(32.0, 32.0) * s)
	_cl_rect_frame = Engine.get_process_frames()
	var me: Dictionary = battle.tanks.get(battle.self_id, {})
	var a: Color = Color(1, 1, 1, CL_ALPHA_OFF if _cl_dead or ( not me.is_empty() and bool(me.get("dead", false))) else 1.0)
	var tone: Color = (Color("63e6f2") if cam_free else Color("ebc779")) * a
	var ink: Color = Color("f3f4de") * a
	var none: Color = Color(0, 0, 0, 0)
	draw_set_transform(at, 0.0, Vector2(s, s))
	_cl_shape(cl_round(Rect2(0, 0, 32, 32), 3.5), Color("102535") * a, Color("192d3b") * a, 1.0)
	_cl_shape(cl_round(Rect2(2, 2, 28, 28), 2.5), (Color("164958") if cam_free else Color("514324")) * a, tone, 1.0)
	_cl_shape(cl_round(Rect2(7, 11, 18, 13), 2.0), Color("18303b") * a, ink, 1.5)
	_cl_shape(cl_round(Rect2(11, 8, 8, 3), 0.0), tone, ink, 1.5)
	draw_arc(Vector2(16, 17), 4.0, 0.0, TAU, 32, tone, 1.5, true)
	draw_circle(Vector2(16, 17), 2.25, tone, true, -1.0, true)
	if cam_free:
		draw_polyline(PackedVector2Array([Vector2(4, 8), Vector2(4, 4), Vector2(8, 4)]), tone, 1.5, true)
		draw_polyline(PackedVector2Array([Vector2(24, 28), Vector2(28, 28), Vector2(28, 24)]), tone, 1.5, true)
	else:
		_cl_shape(cl_round(Rect2(23, 21, 5, 7), 2.0), none, tone, 1.5)
		_cl_shape(cl_round(Rect2(21, 25, 9, 5), 0.0), tone, tone, 1.5)
		for stroke: Array in [[Color("18303b"), 4.0], [Color("ffe4a3"), 2.0]]:
			var ink2: Color = stroke[0] * a
			var w: float = stroke[1]
			draw_line(Vector2(6, 6), Vector2(26, 27), ink2, w, true)
			draw_circle(Vector2(6, 6), w / 2.0, ink2, true, -1.0, true)
			draw_circle(Vector2(26, 27), w / 2.0, ink2, true, -1.0, true)
	draw_set_transform(Vector2.ZERO)


func _cl_draw_tip() -> void :
	var mouse: Vector2 = _cl_pointer()
	var hover: bool = _cl_btn_hit(mouse) and not (_settings != null and _settings.visible) and not (exit_ask != null and exit_ask.visible) and not (pay_ask != null and pay_ask.visible)
	if not hover:
		_cl_tip_hush = false
	var s: float = _hud.scale
	if s <= 0.0:
		return
	draw_set_transform(Vector2.ZERO)
	_cl_tip.draw(self, "cam" if hover and not _cl_tip_hush else "", CL_TIP_FREE if cam_free else CL_TIP_LOCK, mouse / s, size / s, s)
	draw_set_transform(Vector2.ZERO)
