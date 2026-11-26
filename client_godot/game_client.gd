extends Node

const SafeJson = preload("res://net/safe_json.gd")
signal changed
signal gift_used(value: Dictionary)
signal noticed(text: String)
signal bulletin_rolled(text: String)
signal message_box(text: String)
signal friend_result(ok: bool, text: String)
signal awarded(info: Dictionary)
signal item_failed(cont: int, slot: int)
signal item_swapped(cont: int, slot_a: int, slot_b: int)


signal tank_changed(uuid: String, op: int)
signal mail_result(ok: bool, op: int, uuid: String)
signal bought(ok: bool, goods: int)
signal rolled(slot: int)
signal roll_list(kind: int, rows: Array)

signal luck_lines(rows: Array)
signal luck_fund(value: int)
signal luck_slots(body: PackedByteArray)
signal luck_time(text: String)
signal prize_result(award: int, ok: bool)
signal crystal_result(op: String, ok: bool)
signal military_star(prev: int, star: int)
signal ladder_section_up(old: int, now: int)
signal level_up(level: int)
signal happy_packet(type: int, value: Dictionary)
signal global_horn_heard(text: String)
signal impeach_result(ret: int)
signal skin_chip_added(skin: int, delta: int)
signal room_password_asked(room_id: int, kind: int)
signal pwd_result(op: int, ok: bool)
signal pwd_check_asked
signal pwd_notice(left: int)
signal hire_presented(giver: String, tank: int, level: int, hours: int)
signal bonfire_tossed
signal challenge_result(info: Dictionary)
signal materials_added(slots: Array)
signal tank_achieved(tank: Dictionary)
signal skin_achieved(item: int)
signal honor_added(ids: Array)
signal voice_notice(op: int, scope: String, code: String)
const CHAT_KEEP: int = 80

const CHAT_LABELS: Dictionary = {1: "Mật", 2: "Sảnh", 4: "Đội", 8: "Phòng", 16: "Phe", 32: "Phòng", 64: "Phe", 128: "Thế giới", 256: "Loa", 1024: "Bang", 2048: "Toàn máy chủ"}


const FRIEND_RESULTS: Dictionary = {0: "Không tìm thấy người chơi", 1: "Đã gửi lời mời kết bạn", 2: "Danh sách chờ đã đầy", 
	3: "Người này đã chặn bạn", 4: "Người này không nhận kết bạn", 5: "Đã gửi trước đó", 6: "Đã là bạn bè", 
	7: "Không thể tự kết bạn với mình", 8: "Người này nằm trong danh sách chặn của bạn", 9: "Danh sách bạn bè đã đầy"}
const RELATION_ATTENTION: int = 1
const RELATION_BLACK: int = 2
const QUICK_ADD_LIST: int = 11
const CHAT_TINTS: Dictionary = {1: "f78fec", 4: "49ff5e", 16: "49ff5e", 64: "49ff5e", 128: "ffd76a", 256: "ffb347", 1024: "49ff5e", 2048: "ff8f8f"}

const CHAT_TABS: Dictionary = {1: "whisper", 4: "guild", 1024: "guild", 8: "room", 32: "room", 16: "camp", 64: "camp"}

const CHAT_SEND: Array = [1, 2, 8, 16, 1024]

const PLAYER_TABS: Dictionary = {"guild": 3, "friend": 2, "room": 0}

const CHAT_HORNS: Dictionary = {128: 2100001, 256: 2100002}
const HORN_COOLDOWN: float = 15.0

const Config = preload("client_config.gd")
const Auth = preload("net/auth_client.gd")
const Transport = preload("net/byte_transport.gd")
const TCP = preload("net/tcp_transport.gd")
const WS = preload("net/websocket_transport.gd")
const Frames = preload("net/frame_stream.gd")
const Codec = preload("net/protocol/protocol_codec.gd")
const IDs = preload("net/battle_protocol/message_ids.gd")
const Decoder = preload("net/packet_decoder.gd")
const RoomState = preload("battle/room_state.gd")
const BattleState = preload("battle/battle_state.gd")
const Mirror = preload("battle/battle_mirror.gd")
var _mirror: Mirror = Mirror.new()
const MasterModel = preload("ui/master_model.gd")
const PveHallAtlas = preload("ui/pve_hall_atlas.gd")
const MapText = preload("i18n.gd")
const Gifts = preload("ui/room_gift_atlas.gd")
const OpenSkinAtlas = preload("ui/open_skin_atlas.gd")

var room_state: RoomState = RoomState.new()

var master = MasterModel.new()
var master_rev: int = 0

const MASTER_SEND: Array = [708, 709, 710, 711, 712, 713, 716]
var battle: BattleState = BattleState.new()



var room_observers: Dictionary = {}


var pair_scene: Dictionary = {}




var pairing: Dictionary = {}

var pair_confirm: Dictionary = {}

var quick_pair: bool = false
var _quick_sent_at: int = -100000
var _quick_wait_until: int = -100000


var _quick_armed: bool = false




var _pair_again_at: int = -100000
const PAIR_AGAIN_WINDOW: int = 15000


var _quick_type: int = 0




var _pair_left_at: int = -100000
const PAIR_LEFT_WINDOW: int = 3000




var room_hold: Dictionary = {}
var _room_snap: Dictionary = {}


var _held_mates: Dictionary = {}
var _held_mates_at: int = -100000
const HELD_MATES_FRESH: int = 120000
var _leave_sent_at: int = -100000
const ROOM_HOLD_WAIT: int = 1500
const ROOM_HOLD_BACK: int = 3000
const ROOM_SNAP_FRESH: int = 1500
var _stop_sent_at: int = -100000



var _kt2_stop_at: int = -100000
const PAIR_STOP_WAIT: int = 8000
const PAIR_GIVE_UP: int = 900000


var _pick_sent: Array = [0, -100000]
var _lock_sent_at: int = -100000
var award_show: int = 1
var award_op: int = 0
var award_ext: int = 0
const PAIR_RAW: Array = [1719, 1720, 1741, 1742, 1750, 3504]
const PAIR_STOPPED_SELF: String = "Có người chơi chưa xác nhận, tiếp tục tìm trận"
const PAIR_STOPPED: String = "Do chưa xác định, bắt cặp đã dừng"
const PAIR_STOP_LOCAL: String = "Đã hủy phối hợp."
const PAIR_GAVE_UP: String = "Chờ ghép trận quá lâu, đã tự hủy phối hợp. Bấm Bắt đầu để ghép lại."
const PAIR_ROBOT_WAIT: int = 5000



var weekly_tanks: Dictionary = {}



var room_invite: Dictionary = {}
var _decoder: Decoder = Decoder.new()

const PfDecode = preload("net/fast_decode.gd")
const Wifi4g = preload("net/wifi4g.gd")
const PF_BUDGET_USEC: int = 3000
const PF_BACKLOG: int = 240
var _pf_decoder: PfDecode = PfDecode.new()
var _pf_queue: Array[PackedByteArray] = []
var _pf_head: int = 0
var _pf_start: int = 0
var _pf_count: int = 0
var _pf_poll_at: int = 0
var _pf_pong_at: int = 0
var _pf_draining: bool = false
var ignored_layouts: Dictionary = {}
var _hall_poll: float = 0.0
var _room_action: float = 0.0
var _exit_held: bool = false
var _exit_main: bool = false
var _load_pending: bool = false
var _load_acked: bool = false
var _load_reported: int = 0


const LOAD_RESEND_MS: int = 5000
const LOAD_RESENDS: int = 2
var _load_acked_at: int = 0
var _load_resent: int = 0
var loading_held: bool = false

var can_fetch_map: Callable = func(_id: int) -> bool: return false
var map_fetch: bool = false

const BCM1_TRIES: int = 4
const BCM1_GAP_MS: int = 5000
var _bcm1_tries: int = 0
var _bcm1_at: int = -100000
var config: Config = Config.new()
var auth: Auth
var transport_factory: Callable
var state: String = "login"
var status: String = "Đăng nhập để chơi."
var error_code: String = ""
var account: Dictionary = {}
var server: Dictionary = {}
var region: Dictionary = {}
var characters: Array = []
var creating: bool = false
var _create_sent: bool = false


const CHAR_NAME_LIMIT: int = 15

const CREATE_FAIL: Dictionary = {0: "Tên nhân vật vô hiệu", 1: "Tên nhân vật tồn tại", 2: "Location vô hiệu", 
	3: "Chứa từ không hợp lệ", 4: "Tên nhân vật quá dài, tối đa %d ký tự" % CHAR_NAME_LIMIT, 5: "Lỗi server tạm thời", 
	8: "Server này đã tắt chức năng tạo nhân vật mới.", 9: "Tên nhân vật quá ngắn, tối thiểu phải 4 ký tự"}
var character: Dictionary = {}
var currency: Dictionary = {}



var buy_life: Dictionary = {}
var buy_life_rev: int = 0
var technologies: Array = []
var ladder_old: int = 0
var tanks: Dictionary = {}
var old_skins: Dictionary = {}
const TANK_UP_SKIN_MS: int = 5000
var _tank_up_msec: int = -100000
var _skin_filmed: Dictionary = {}
var _chip_asked: Dictionary = {}


var bags: Dictionary = {}
var bag_loaded: bool = false
var bag_opened: bool = false
var bag_rev: int = 0
var battle_helper: String = ""


var smart_slots: Array[int] = [1, 2, 3, 4, 10, 13]
var option_ready: bool = false
var _key_board_set: Array = []


const KEY_DEFAULT: Array[int] = [82, 69, 32, 81, 1000, 1001, 71, 70, 90, 88, 67, 66, 72]
var key_map: Dictionary = {}

var crystal_schemes: Dictionary = {}
var crystal_names: Dictionary = {}
var crystal_free_at: int = 0
var crystal_loaded: bool = false
var crystal_rev: int = 0

var mails: Array = []
var mail_unread: int = 0
var mail_bodies: Dictionary = {}
var mail_loaded: bool = false
var mail_rev: int = 0
var sprays: Array = []
var honors: Array = []
var honors_worn: Array = []
var achievements: Dictionary = {}
var _bag_asked: float = -10.0
var _bag_tries: int = 0



var _bags_stale: bool = false
var account_id: int = 0
var account_oid: int = 0
var first_charge: int = 0

var pwd_has: bool = false
var pwd_lock: bool = true
var pwd_ticket: int = 0
var _pwd_tiped: bool = false
var _pwd_auto_at: float = -100.0
var ping_count: int = 0
const BG_PUMP_JS: String = "(function(){if(window.__bbPump)return;var w=new Worker(URL.createObjectURL(new Blob(['setInterval(function(){postMessage(0)},50)'],{type:'text/javascript'})));w.onmessage=function(){var cb=window.__bbPumpCb;if(cb)cb();};window.__bbPump=w;})()"
var _bg_pump: JavaScriptObject = null




const BG_LOOP_JS: String = "(function(){if(window.__bbLoop)return;var W=window,D=document,raf=W.requestAnimationFrame.bind(W),caf=W.cancelAnimationFrame.bind(W);var n=0,jobs=new Map(),wk=null,on=false;var st={ms:50,ticks:0,runs:0,hid:0,shown:0,err:0,hidden:D.hidden};function run(id){var j=jobs.get(id);if(!j)return;jobs.delete(id);caf(j.n);st.runs++;try{j.f(performance.now())}catch(e){st.err++;setTimeout(function(){throw e})}}W.requestAnimationFrame=function(f){var id=++n,j={f:f,n:0};jobs.set(id,j);j.n=raf(function(t){var k=jobs.get(id);if(k){jobs.delete(id);k.f(t)}});if(D.hidden)wake();return id};W.cancelAnimationFrame=function(id){var j=jobs.get(id);if(j){jobs.delete(id);caf(j.n)}};function wake(){if(on)return;on=true;if(!wk){wk=new Worker(URL.createObjectURL(new Blob(['var t=0;onmessage=function(e){clearInterval(t);t=0;if(e.data>0)t=setInterval(function(){postMessage(0)},e.data)}'],{type:'text/javascript'})));wk.onmessage=tick}wk.postMessage(st.ms)}function sleep(){if(!on)return;on=false;wk.postMessage(0)}function tick(){if(!D.hidden){sleep();return}st.ticks++;var ids=[];jobs.forEach(function(_,id){ids.push(id)});for(var i=0;i<ids.length;i++)run(ids[i])}D.addEventListener('visibilitychange',function(){st.hidden=D.hidden;if(D.hidden){st.hid++;wake()}else{st.shown++;sleep()}var cb=W.__bbVisCb;if(cb)cb(D.hidden)});if(D.hidden)wake();W.__bbLoop=st;})()"

const BG_RELEASE_KEYS: Array[int] = [KEY_SPACE, KEY_LEFT, KEY_UP, KEY_RIGHT, KEY_DOWN, KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META, KEY_TAB, KEY_ENTER]
var _bg_vis: JavaScriptObject = null

var bg_hidden: bool = false
var page_hidden_probe: Callable
var _mw_probe_ms: int = -100000
var _proc_ms: float = 0.0
var _skew: float = 0.0
var latency_ms: int = -1
var _ping_sent: int = 0
var unknown_ids: Array[int] = []
var _token: String = ""
var _session: int = 0
var _role: String = ""
var _phase: String = ""
var _channel: Transport
var _frames: Frames = Frames.new()
var _codec: Codec = Codec.new()
var _deadline: float = 0.0
var _wsd_old: bool = false
var _idle: float = 0.0


const IDLE_LIMIT: float = 110.0
var _ping: float = 0.0
var _pending_character: String = ""
var _has_login: bool = false
var char_uuid: String = ""
var _chat_sent: float = -10.0
var _normal_sent: float = -100.0
var chat_log: Array = []
var chat_rev: int = 0

const CHAT_TEA: int = 4096
const TEA_LOG_MAX: int = 60
var tea_log: Array = []
var tea_rev: int = 0


var _horn_spent: Dictionary = {}
var _horn_sent: float = -100.0
var _whisper: Dictionary = {}
var whisper_to: Dictionary = {}
var _players_sent: Dictionary = {}
var friends: Dictionary = {}
var friends_loaded: bool = false
var friend_suggestions: Array = []
var friend_rev: int = 0
var blacks: Dictionary = {}
var char_states: Dictionary = {}
var friend_applies: Array = []
var friend_apply_count: int = 0
var _friend_pending: String = ""
var _friend_sent: float = -10.0
var _suggest_sent: float = -10.0
var _invites: Dictionary = {}
var guild: Dictionary = {}
var guild_teams: Array = []
var guild_members: Dictionary = {}
var guild_briefs: Dictionary = {}
var guild_self_team: int = 0
var guild_channel: String = ""
var guild_rev: int = 0
var guild_skill_slots: Dictionary = {}
var guild_skill_flag: int = 0
var guild_skill_self: Dictionary = {}
var guild_skill_corps: Dictionary = {}
var _guild_asked: float = -10.0

var guild_applies: Array = []
var guild_inviters: Dictionary = {}




var guild_team_invite: Dictionary = {}
var guild_team_invite_rev: int = 0
var guild_req_join: int = 0
var guild_tip_due: bool = false
var guild_gift_time: int = 0

var quests: Dictionary = {}
var quests_loaded: bool = false
var stages: Dictionary = {}
var stages_cleared: Dictionary = {}
var acts: Dictionary = {}
var act_rev: int = 0

var world_boss: Dictionary = {}
var world_boss_rev: int = 0
var world_boss_return: bool = false


var pve_cities: Dictionary = {}
var pve_records: Dictionary = {}
var _pve_record_wait: Array = []
var pve_scenes: Dictionary = {}
var pve_rev: int = 0

var pve_sweep_awards: Array = []
var pve_sweep_rev: int = 0
var pve_return: int = 0
var pve_chapter: int = -1

var league_url: String = ""
var league_rev: int = 0
var league_enroll_n: int = 0
var league_enroll_code: int = -1


signal league_award_result(result: int, award_id: int)

const EVENT_ROOMS: Dictionary = {3: 100, 28: 11, 32: 13}
const TIP_683: String = "Cần tối thiểu 1 tank giới hạn mỗi tuần"
const TIP_689: String = "Hiện không trong thời gian sự kiện"
var act_types: Dictionary = {}
var fire_ball_tanks: Array = []
var hall_room: int = 100
var act_return: bool = false


const TEAM_ROOM: int = 5
const TEAM_ACT: int = 1
const TEAM_JOIN_LEVEL: int = 5
var hall_type: int = 2
var team_match: Dictionary = {}
var _team_polled_at: int = -100000
var _team_armed: bool = false

const LEAGUE_TIPS: Array = ["Báo danh thành công", "Không có cấp này", "Không có Team này", "Chưa mở báo danh", "Đã đóng báo danh", 
	"Báo danh đủ", "Lv team không đủ", "Danh Vọng team không đủ", "Thứ tự trong Chiến Xếp Hạng Team chưa đủ", "Team không đủ thành viên", 
	"Tạo team quá trễ", "Quỹ Team không đủ", "Team bạn đã báo danh", "Không tìm được khu tương ứng"]
var stage_progress: Dictionary = {}




const DAILY_MODES: Array = [3, 2, 0, 4]
const DAILY_SETTLE_MAX: Dictionary = {0: 3, 1: 3, 2: 3, 3: 3, 4: 3}
const STAGE_DROPS: int = 9
var quest_rev: int = 0
signal stage_reaped(result: int, stage: int)
signal quest_failed(quest: int)


const FNUT_BONFIRE: int = 8
var bonfire_count: int = 0
var bonfire_add: int = 0
var bonfire_param: int = 0
var bonfire_completed: int = 0
var bonfire_rev: int = 0
var _bonfire_subscribed: bool = false
var sign_in: Dictionary = {}
var limits: Dictionary = {}
var event_rev: int = 0


var challenge: Dictionary = {}
var challenge_loaded: bool = false
var challenge_rev: int = 0


var mystic_tank: int = 0
var mystic_end: int = 0

signal mysterious_enabled
signal mysterious_purchased(pos: int)
var mysterious_goods: Array = []
var mysterious_last: int = 0
var mysterious_refresh: int = 0
var mysterious_rev: int = 0
var mysterious_acts: Array = []

var tank_rents: Array = []
var tank_rent_got: bool = false
var tank_rent_rev: int = 0


var expedition: Dictionary = {"times": [0, 0, 0], "tanks": [0, 0, 0, 0, 0, 0, 0, 0, 0], "live": false, "offset": 0, "owned": 0}
var expedition_rev: int = 0


var guild_boss: Dictionary = {"live": false}
var guild_boss_awards: Array = []
var guild_boss_feed: Array = []
var guild_boss_rev: int = 0
var guild_boss_return: bool = false

var skin_chips: Dictionary = {}
var skin_chip_rev: int = 0

func _ready() -> void :
	if auth == null:
		auth = Auth.new()
	add_child(auth)
	auth.completed.connect(_on_auth)
	wifi4g.setup()
	if not get_tree().root.window_input.is_connected(kphim1_event):
		get_tree().root.window_input.connect(kphim1_event)
	server = config.server_entry()
	if OS.has_feature("web"):
		_bg_pump = JavaScriptBridge.create_callback(_pump_hidden)
		JavaScriptBridge.get_interface("window").set("__bbPumpCb", _bg_pump)
		JavaScriptBridge.eval(BG_PUMP_JS, true)
		_bg_vis = JavaScriptBridge.create_callback(_on_page_visibility)
		JavaScriptBridge.get_interface("window").set("__bbVisCb", _bg_vis)
		JavaScriptBridge.eval(BG_LOOP_JS, true)
		if bool(JavaScriptBridge.eval("document.hidden", true)):
			set_page_hidden(true)





func _pump_hidden(_args: Array) -> void :
	if Time.get_ticks_msec() - _proc_ms >= 100:
		_process(0.0)

func _on_page_visibility(args: Array) -> void :
	set_page_hidden( not args.is_empty() and bool(args[0]))





func set_page_hidden(hidden: bool) -> void :
	if hidden == bg_hidden:
		return
	bg_hidden = hidden
	RenderingServer.render_loop_enabled = not hidden
	if not hidden:
		return
	release_held_input()
	battle.held_direction = 8
	if is_inside_tree():
		get_tree().root.propagate_notification(NOTIFICATION_APPLICATION_FOCUS_OUT)



func _notification(what: int) -> void :
	if not (OS.has_feature("android") or OS.has_feature("ios")):
		return
	if what == NOTIFICATION_APPLICATION_PAUSED:
		set_page_hidden(true)
	elif what == NOTIFICATION_APPLICATION_RESUMED:
		set_page_hidden(false)



func _mw_page_check() -> void :
	if not bg_hidden:
		return
	var now: int = Time.get_ticks_msec()
	if now - _mw_probe_ms < 1000:
		return
	_mw_probe_ms = now
	var hidden: Variant = null
	if page_hidden_probe.is_valid():
		hidden = page_hidden_probe.call()
	elif OS.has_feature("web"):
		hidden = JavaScriptBridge.eval("document.hidden", true)
	if hidden != null and not bool(hidden):
		set_page_hidden(false)








const KPHIM1_KEYS: Array[int] = [KEY_W, KEY_A, KEY_S, KEY_D, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
const KPHIM1_QUIET_S: float = 1.2
const KPHIM1_QUIET_MAX_S: float = 3.0
const KPHIM1_STEP_MAX_S: float = 0.1
var _kp_key: int = 0
var _kp_quiet: float = 0.0
var _kp_seen: bool = false
var _kp_gap: float = 0.0
var _kp_freed: int = 0
var _kp_self_up: int = 0
var kphim1_released: int = 0
var kphim1_repressed: int = 0

func kphim1_limit() -> float:
	return clampf(_kp_gap * 1.5 + 0.2, KPHIM1_QUIET_S, KPHIM1_QUIET_MAX_S)


func kphim1_event(event: InputEvent) -> void :
	var key: InputEventKey = event as InputEventKey
	if key == null:
		return
	var code: int = int(key.physical_keycode)
	if code == KEY_NONE or code == KEY_BACKSPACE:
		return
	if not key.pressed and code == _kp_self_up:
		_kp_self_up = 0
		return
	if not key.echo and code == _kp_freed:
		_kp_freed = 0
	if not key.pressed:
		if code == _kp_key:
			_kp_key = 0
		return
	if key.echo:
		_kp_seen = true
		if code == _kp_key:
			_kp_gap = maxf(_kp_gap, _kp_quiet)
		if code == _kp_freed and not Input.is_physical_key_pressed(code as Key):
			_kp_freed = 0
			kphim1_repressed += 1
			_kphim1_send.call_deferred(code, true)
	_kp_key = code
	_kp_quiet = 0.0

func _kphim1_send(code: int, pressed: bool) -> void :
	var ev: InputEventKey = InputEventKey.new()
	ev.keycode = code as Key
	ev.physical_keycode = code as Key
	ev.key_label = code as Key
	ev.pressed = pressed
	Input.parse_input_event(ev)

func _kphim1_tick(delta: float) -> void :
	if _kp_key == 0:
		return
	_kp_quiet += clampf(delta, 0.0, KPHIM1_STEP_MAX_S)
	if not _kp_seen or state != "battle" or bg_hidden or not _kp_key in KPHIM1_KEYS or _kp_quiet < kphim1_limit():
		return
	var code: int = _kp_key
	_kp_key = 0
	if not Input.is_physical_key_pressed(code as Key):
		return
	_kp_freed = code
	_kp_self_up = code
	kphim1_released += 1
	_kphim1_send(code, false)



func kphim1_release_keys(only_moves: bool = false) -> int:
	var keys: Array[int] = []
	keys.append_array(KPHIM1_KEYS)
	if not only_moves:
		for code: Variant in BG_RELEASE_KEYS:
			keys.append(int(code))
		for code: int in range(KEY_0, KEY_9 + 1):
			keys.append(code)
		for code: int in range(KEY_A, KEY_Z + 1):
			keys.append(code)
		for code: Variant in key_map.values():
			if typeof(code) == TYPE_INT and int(code) > 0 and int(code) < 1000:
				keys.append(int(code))
	var done: Array[int] = []
	for code: int in keys:
		if done.has(code):
			continue
		if Input.is_physical_key_pressed(code as Key) or Input.is_key_pressed(code as Key):
			done.append(code)
			_kphim1_send(code, false)
	if not done.is_empty():
		_kp_key = 0
		_kp_quiet = 0.0
	return done.size()


func release_held_input() -> void :
	var keys: Array[int] = BG_RELEASE_KEYS.duplicate()
	for code: int in range(KEY_0, KEY_9 + 1) + range(KEY_A, KEY_Z + 1):
		keys.append(code)
	for code: Variant in key_map.values():
		if (code is int) and int(code) > 0 and int(code) < 1000 and not int(code) in keys:
			keys.append(int(code))
	for code: int in keys:
		if Input.is_physical_key_pressed(code as Key) or Input.is_key_pressed(code as Key):
			var up: InputEventKey = InputEventKey.new()
			up.keycode = code as Key
			up.physical_keycode = code as Key
			up.key_label = code as Key
			up.pressed = false
			Input.parse_input_event(up)
	var viewport: Viewport = get_viewport() if is_inside_tree() else null
	for button: int in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
		if Input.is_mouse_button_pressed(button as MouseButton):
			var release: InputEventMouseButton = InputEventMouseButton.new()
			release.button_index = button as MouseButton
			release.pressed = false
			if viewport != null:
				release.position = viewport.get_mouse_position()
				release.global_position = release.position
			Input.parse_input_event(release)

func login(username: String, password: String, key: String) -> void :
	logout()
	state = "auth"
	status = "Đang đăng nhập…"
	changed.emit()
	_rc_key = key
	auth.login(config.origin, username, password, key)

func _on_auth(result: Dictionary) -> void :
	if _rc_auth:
		_rc_on_auth(result)
		return
	if state != "auth":
		return
	if not result.get("ok", false):
		_fail(str(result.get("error", "Đăng nhập không thành công.")), str(result.get("code", "")))
		return
	account = result["account"].duplicate()
	_token = result["authToken"]
	_rc_token = str(result.get("resumeToken", ""))
	server = config.server_entry()
	state = "servers"
	status = "Chọn máy chủ."
	changed.emit()

func select_server(sid: int) -> void :
	if state != "servers" or sid != 299001:
		return
	_connect_role("login")

func _connect_role(role: String) -> void :
	_close_channel()
	var endpoint: Dictionary = config.endpoint(role, region)
	if endpoint.is_empty():
		_fail("Chưa cấu hình địa chỉ máy chủ đăng nhập." if role == "login" else "Địa chỉ cổng vào game không hợp lệ.", "ENDPOINT")
		return
	_role = role
	state = "connecting"
	_phase = "connect"
	status = "Đang kết nối máy chủ đăng nhập…" if role == "login" else "Đang kết nối máy chủ game…"
	_deadline = 0.0
	_idle = 0.0
	_ping = 0.0
	_frames = Frames.new()
	_channel = transport_factory.call() if transport_factory.is_valid() else (WS.new() if config.transport_kind == "websocket" else TCP.new())
	_channel.opened.connect(_on_opened)
	_channel.bytes_received.connect(_on_bytes)
	_channel.ended.connect(_on_end)
	if _channel.start(endpoint) != OK:
		if _wsd_fall():
			return
		_fail("Không kết nối được máy chủ đăng nhập." if role == "login" else "Không kết nối được máy chủ game.", "CONNECT")
	changed.emit()



func _wsd_fall() -> bool:
	if _channel == null or not config.direct_ready() or _phase not in ["connect", "version"]:
		return false
	config.direct_off = true
	_wsd_old = true
	_connect_role(_role)
	return true

func _on_opened() -> void :
	_phase = "version"
	_send("AuthMessage.RequestProtocolVersion", {"m_auth_ver": 3, "m_gate_ver": 18, 
		"m_mixAuth": 0, "m_client_ver": "curVersion" if _role == "login" else "1.0.1.8480"})

func _send(short_name: String, fields: Dictionary) -> void :
	fields = _mirror.send(battle, short_name, fields)
	var encoded: Dictionary = _codec.encode_frame("sixcube.protocol." + short_name, fields)
	if _channel == null and _rc_until > 0:
		return
	if not encoded["ok"] or _channel == null:
		_fail("Không tạo được yêu cầu gửi máy chủ.", "PROTOCOL")
		return
	var bytes: PackedByteArray = encoded["data"]
	if bytes.decode_s16(2) in [450, 501, 503, 600, 601, 602, 603, 604, 605, 607, 608, 613]:
		var padding: int = (8 - (bytes.size() - 2) % 8) % 8
		bytes.resize(bytes.size() + padding)
		bytes.encode_u16(0, bytes.size())
	if _channel.send_bytes(bytes) != OK:
		_fail("Kết nối không gửi được dữ liệu.", "CONNECTION")


func _send_raw(type: int, body: PackedByteArray) -> void :
	if _channel == null:
		return
	var output: StreamPeerBuffer = StreamPeerBuffer.new()
	output.big_endian = false
	output.put_u16(body.size() + 8)
	output.put_16(type)
	output.put_u32(0)
	output.put_data(body)
	if _channel.send_bytes(output.data_array) != OK:
		_fail("Kết nối không gửi được dữ liệu.", "CONNECTION")




func send_gm_command(command: String) -> bool:
	if _role != "gate" or _phase != "world" or int(character.get("gm_level", 0)) <= 0 or command.strip_edges().is_empty():
		return false
	_send("SystemMessage.GmCommand", {"m_command": command, "m_gmName": str(character.get("name", ""))})
	return true



func send_result_chat(text: String) -> bool:
	text = text.strip_edges()
	if text.is_empty() or not battle.active or not pvp_result():
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _chat_sent < 2.0:
		battle.chat_rejected("Nói quá nhanh")
		return false
	_chat_sent = now
	var me: Dictionary = battle.tanks.get(account_oid, {})
	var name: String = str(me.get("name", battle.names.get(account_oid, character.get("name", ""))))
	var stamp: int = int(battle.server_ms) if battle.server_ms > 0 else int(Time.get_unix_time_from_system() * 1000)
	_send_chat_packet(battle.CHAT_SCENE, name, text, "", 0, stamp)
	return true



func send_battle_chat(text: String, channel: int, honor: bool = false) -> bool:
	text = text.strip_edges()
	if text.is_empty() or not battle.active or (battle.ended and not honor) or channel not in [battle.CHAT_SCENE, battle.CHAT_CAMP]:
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _chat_sent < 2.0:
		battle.chat_rejected("Nói quá nhanh")
		return false
	_chat_sent = now
	var me: Dictionary = battle.tanks.get(account_oid, {})
	if battle.look and me.is_empty() and not battle.names.has(account_oid):
		me = {"name": str(character.get("name", ""))}
	var stamp: int = int(battle.server_ms) if battle.server_ms > 0 else int(Time.get_unix_time_from_system() * 1000)
	_send_chat_packet(channel, str(me.get("name", battle.names.get(account_oid, ""))), text, "", 0, stamp)
	return true




func send_pair_chat(text: String) -> bool:
	text = text.strip_edges()
	if text.is_empty() or pair_scene.is_empty() or battle.active or state not in ["lobby", "hall", "room"]:
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _chat_sent < 2.0:
		return false
	_chat_sent = now
	_send_chat_packet(battle.CHAT_CAMP, str(character.get("name", account.get("name", ""))), text, "", 0, int(Time.get_unix_time_from_system() * 1000))
	return true


func _send_chat_packet(channel: int, sender: String, text: String, receiver: String, receiver_oid: int, stamp: int, extra: Dictionary = {}) -> void :
	var sex: int = int(character.get("sexes", 0))
	_send("ChatMessage.ChatMessage", {"m_contents": {"channel": channel, "senderVipLvl": 0, 
		"senderGmLv": int(character.get("gm_level", 0)), "receiverVipLvl": 0, "senderOid": account_oid, 
		"senderUuid": char_uuid, "sender": sender, "senderGid": account_oid, 
		"receiverOid": receiver_oid, "receiverUuid": "", "receiver": receiver, "content": text.replace("<", "&lt;"), 
		"paramVec": "{\"sex\":%d}" % sex if extra.is_empty() else JSON.stringify({"sex": sex}.merged(extra))}, 
		"m_recvClientTime": {"lowpart": stamp & 4294967295, "hipart": stamp >> 32}, 
		"m_recvChatTime": {"lowpart": 0, "hipart": 0}})




func send_chat(text: String, channel: int = 2, extra: Dictionary = {}, world: bool = false) -> bool:
	text = text.strip_edges()
	if text.is_empty() or battle.active or state not in ["lobby", "hall", "room"] or channel not in CHAT_SEND:
		return false
	if channel in [8, 16] and state != "room":
		chat_note("Vào phòng chờ rồi mới nói ở kênh này được.")
		return false
	var receiver: String = ""
	var receiver_oid: int = 0
	if channel == 1 and not (text.begins_with("/r ") or text == "/r" or text.begins_with("/w ")):
		if whisper_to.is_empty():
			chat_note("Nhắn riêng: /w tên nội dung")
			return false
		receiver = str(whisper_to.get("name", ""))
		receiver_oid = int(whisper_to.get("oid", 0))
	if text.begins_with("/r ") or text == "/r":
		if _whisper.is_empty():
			chat_note("Chưa có ai nhắn mật cho bạn.")
			return false
		channel = 1
		receiver = str(_whisper.get("name", ""))
		receiver_oid = int(_whisper.get("oid", 0))
		text = text.substr(2).strip_edges()
	elif text.begins_with("/w "):
		var rest: String = text.substr(3).strip_edges()
		var cut: int = rest.find(" ")

		for brief: Dictionary in friends.values():
			var known: String = str(brief.get("m_name", ""))
			if known.length() > cut and rest.begins_with(known + " "):
				cut = known.length()
		if cut <= 0:
			chat_note("Nhắn mật: /w tên nội dung")
			return false
		channel = 1
		receiver = rest.substr(0, cut)
		text = rest.substr(cut + 1).strip_edges()
	if text.is_empty():
		return false


	if channel == 2 and state == "room" and not world:
		channel = 8
	var now: float = Time.get_ticks_msec() / 1000.0

	if channel == 2 and now - _normal_sent < 30.0:
		chat_note("Giãn cách phát ngôn 30s")
		return false
	if now - _chat_sent < 2.0:
		chat_note("Nói quá nhanh")
		return false
	_chat_sent = now
	if channel == 2:
		_normal_sent = now
	if channel == 1:
		whisper_to = {"name": receiver, "oid": receiver_oid}
	var who: String = str(character.get("name", account.get("name", "")))
	_send_chat_packet(channel, who, text, receiver, receiver_oid, int(Time.get_unix_time_from_system() * 1000), extra)
	return true


func chat_wait(channel: int) -> float:
	var now: float = Time.get_ticks_msec() / 1000.0
	var wait: float = 2.0 - (now - _chat_sent)
	if channel == 2 and state != "room":
		wait = maxf(wait, 30.0 - (now - _normal_sent))
	return maxf(0.0, wait)




func send_chat_channel(text: String, channel: int, extra: Dictionary = {}) -> bool:
	text = text.strip_edges()
	if text.is_empty() or battle.active or state not in ["lobby", "hall", "room"] or channel not in [4, 128, 256]:
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	var id: int = int(CHAT_HORNS.get(channel, 0))
	if id == 0:
		if now - _chat_sent < 2.0:
			chat_note("Nói quá nhanh")
			return false
		if not in_chat_team():
			chat_note("Chưa vào Team")
			return false
	elif horn_count(channel) <= 0:
		chat_note("Không đủ loa lớn, hãy mua thêm" if channel == 256 else "Không đủ loa nhỏ, hãy mua thêm")
		return false
	elif now - _horn_sent < HORN_COOLDOWN:
		chat_note("Loa đang hồi — chờ %ds rồi dùng lại." % ceili(HORN_COOLDOWN - (now - _horn_sent)))
		return false
	_chat_sent = now
	if id != 0:
		_horn_sent = now
		var raw: int = _horn_raw(id)
		_horn_spent[id] = [bags.get(2), raw, raw - horn_count(channel) + 1]
	var who: String = str(character.get("name", account.get("name", "")))
	_send_chat_packet(channel, who, text, "", 0, int(Time.get_unix_time_from_system() * 1000), extra)
	return true





func equip_chat_frame(id: String) -> bool:
	var frame: String = "none" if id == "reset" else id
	if not (battle.active or state in ["lobby", "hall", "room"]) or RegEx.create_from_string("^[a-z0-9_]{1,40}$").search(frame) == null:
		return false
	var who: String = str(character.get("name", account.get("name", "")))
	_send_chat_packet(2, who, "[equip-frame:%s]" % frame, "", 0, int(Time.get_unix_time_from_system() * 1000))
	return true





const CHAT_GLOBAL: int = 2048
const CHAT_GLOBAL_HORN: int = 2100007

func global_horn_count() -> int:
	var raw: int = _horn_raw(CHAT_GLOBAL_HORN)
	var spent: Array = _horn_spent.get(CHAT_GLOBAL_HORN, [])
	if spent.size() == 3 and is_same(spent[0], bags.get(2)) and int(spent[1]) == raw:
		raw -= int(spent[2])
	return maxi(0, raw)

func send_global_horn(text: String) -> bool:
	text = text.strip_edges()
	if text.is_empty() or battle.active or state not in ["lobby", "hall", "room"]:
		return false
	if global_horn_count() <= 0:
		chat_note("Không đủ Loa Liên Server, hãy mua thêm")
		return false
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _horn_sent < HORN_COOLDOWN:
		chat_note("Loa đang hồi — chờ %ds rồi dùng lại." % ceili(HORN_COOLDOWN - (now - _horn_sent)))
		return false
	_chat_sent = now
	_horn_sent = now
	var raw: int = _horn_raw(CHAT_GLOBAL_HORN)
	_horn_spent[CHAT_GLOBAL_HORN] = [bags.get(2), raw, raw - global_horn_count() + 1]
	var who: String = str(character.get("name", account.get("name", "")))
	_send_chat_packet(CHAT_GLOBAL, who, text, "", 0, int(Time.get_unix_time_from_system() * 1000))
	return true


func horn_count(channel: int) -> int:
	var id: int = int(CHAT_HORNS.get(channel, 0))
	var raw: int = _horn_raw(id)
	var spent: Array = _horn_spent.get(id, [])
	if spent.size() == 3 and is_same(spent[0], bags.get(2)) and int(spent[1]) == raw:
		raw -= int(spent[2])
	return maxi(0, raw)

func _horn_raw(id: int) -> int:
	var count: int = 0
	for item: Dictionary in bags.get(2, []):
		if id != 0 and int(item.get("m_templateId", 0)) == id:
			count += maxi(1, int(item.get("m_count", 1)))
	return count


func in_chat_team() -> bool:
	if guild.is_empty():
		return false
	var uuid: String = guild_self_uuid()
	return guild_self_team != 0 if uuid.is_empty() else int(guild_members[uuid].get("nTeamId", 0)) != 0


func chat_note(text: String, color: Color = Color("ffd700")) -> void :
	_chat_line({"head": "", "name": "", "name_color": Color.WHITE, "text": text, "color": color, "tab": ""})



func _room_note(type: int, value: Dictionary) -> void :
	if room_state.room.is_empty():
		return
	var id: int = 0
	var name: String = ""
	var text: String = ""
	if type == 1702:
		var brief: Dictionary = value.get("m_charData", {}).get("charData", {})
		id = int(brief.get("nAcctId", 0))
		if room_state.members.has(id):
			return
		name = str(brief.get("szName", ""))
		text = "Đã vào room"
	elif type == 1701 and int(value.get("m_roomOp", 0)) in [1, ROPT_KICKOUT]:
		id = int(value.m_nTarget) if int(value.m_nTarget) != 0 else int(value.m_nStartOid)
		name = str(room_state.members.get(id, {}).get("data", {}).get("charData", {}).get("szName", ""))
		text = "Đã rời room"
	if id == 0 or id == account_oid or name.is_empty():
		return
	_chat_line({"head": "", "name": name, "name_color": Color("ff3333"), "text": text, "color": Color.WHITE, "tab": "room"})



func _gift_note(value: Dictionary) -> void :
	var giver: int = int(str(value.get("m_nCharUuid", "")).to_int())
	var name: String = str(room_state.members.get(giver, {}).get("data", {}).get("charData", {}).get("szName", ""))
	var item: String = ""
	for row: Array in Gifts.ITEMS:
		if int(row[0]) == int(value.get("m_nItemId", 0)):
			item = str(row[1])
	if name.is_empty() or item.is_empty():
		return
	_chat_line({"head": "", "name": name, "name_color": Color("ff0000"), "text": "đã sử dụng %s  đối với %s" % [item, str(value.get("m_targetName", ""))], "color": Color.WHITE, "tab": "room"})




func _room_char_change(value: Dictionary) -> void :
	var player: Dictionary = value.get("m_charData", {})
	var other: Dictionary = value.get("m_otherData", {})
	var id: int = int(player.get("nAcctId", 0))
	if room_state.room.is_empty() or id == 0 or other.is_empty() or not room_state.members.get(id, {}).has("data"):
		return
	var brief: Dictionary = room_state.members[id].data.duplicate()
	brief["charData"] = player
	brief["otherData"] = other
	room_state.brief(brief)






func _room_observer(type: int, value: Dictionary) -> bool:
	if type == 1700:
		room_observers.clear()
		for entry: Dictionary in value.get("observerVec", []):
			var seen: Dictionary = entry.get("charBrief", {})
			var seen_id: int = int(seen.get("charData", {}).get("nAcctId", 0))
			if seen_id != 0:
				room_observers[seen_id] = seen
		return false
	if room_state.room.is_empty():
		room_observers.clear()
		return type == 1702 and int(value.get("isObserver", 0)) != 0
	if type == 1702:
		if int(value.get("isObserver", 0)) == 0:
			room_observers.erase(int(value.get("m_charData", {}).get("charData", {}).get("nAcctId", 0)))
			return false
		var brief: Dictionary = value.get("m_charData", {})
		var id: int = int(brief.get("charData", {}).get("nAcctId", 0))
		if id != 0 and not room_state.members.has(id):
			room_observers[id] = brief
		return true
	var op: int = int(value.get("m_roomOp", 0))
	var oid: int = int(value.get("m_nStartOid", 0))
	if op == 1:
		var gone: int = int(value.get("m_nTarget", 0)) if int(value.get("m_nTarget", 0)) != 0 else oid
		if gone == account_oid:
			room_observers.clear()
		elif room_observers.has(gone):
			_room_observer_note(room_observers[gone], "Đã rời room")
			room_observers.erase(gone)
	elif op == 9 and room_state.members.get(oid, {}).has("data"):
		var seated: Dictionary = room_state.members[oid].data.duplicate()
		_room_observer_note(seated, "Đã rời room")
		room_state.members.erase(oid)
		seated["bCamp"] = 0
		room_observers[oid] = seated
	elif op == 10 and room_observers.has(oid):
		var watcher: Dictionary = room_observers[oid].duplicate()
		room_observers.erase(oid)
		watcher["bCamp"] = int(value.get("m_nTarget", 0))
		room_state.members.erase(oid)
		room_state.brief(watcher)
		_room_observer_note(watcher, "Đã vào room")
	return false


func _room_observer_note(brief: Dictionary, text: String) -> void :
	var name: String = str(brief.get("charData", {}).get("szName", ""))
	if int(brief.get("charData", {}).get("nAcctId", 0)) == account_oid or name.is_empty():
		return
	_chat_line({"head": "", "name": name, "name_color": Color("ff3333"), "text": text, "color": Color.WHITE, "tab": "room"})

func _chat_line(line: Dictionary) -> void :
	line["seq"] = chat_rev + 1
	chat_log.append(line)
	if chat_log.size() > CHAT_KEEP:
		chat_log = chat_log.slice(chat_log.size() - CHAT_KEEP / 2)
	chat_rev += 1


func _receive_chat(message: Dictionary) -> void :
	var contents: Dictionary = message.get("m_contents", {})
	var channel: int = int(contents.get("channel", 0))
	var text: String = BattleState.chat_text(str(contents.get("content", "")))
	if channel == CHAT_TEA and not text.is_empty():
		_receive_tea_chat(contents, text)
		return
	if text.is_empty() or not CHAT_LABELS.has(channel):
		return
	var sender: int = int(contents.get("senderOid", 0))
	var outgoing: bool = channel == 1 and sender == account_oid
	var vip: int = int(contents.get("receiverVipLvl" if outgoing else "senderVipLvl", 0)) % 100



	var in_room: bool = false
	var label: String = "Phòng" if in_room else str(CHAT_LABELS[channel])
	if channel == 1 and not outgoing:
		_whisper = {"name": str(contents.get("sender", "")), "oid": sender}
		whisper_to = _whisper.duplicate()
	_chat_line({"head": "[" + label + "]" + ("Nói với " if outgoing else ""), "name": str(contents.get("receiver" if outgoing else "sender", "")), 
		"name_color": Color("#" + BattleState.CHAT_VIP_COLOR[mini(vip, BattleState.CHAT_VIP_COLOR.size()) - 1]) if vip > 0 else Color("6b93ee"), 
		"text": ": " + text, "color": Color("#" + str(CHAT_TINTS.get(channel, "e8e8e8"))), 
		"tab": "room" if in_room else str(CHAT_TABS.get(channel, "all"))})

	chat_log[-1].merge({"channel": channel, "oid": sender, "raw": str(contents.get("content", "")), "gm": int(contents.get("senderGmLv", 0))})

	chat_log[-1].merge({"uuid": str(contents.get("receiverUuid" if outgoing else "senderUuid", "")), 
		"who_oid": int(contents.get("receiverOid", 0)) if outgoing else sender})

	var media: Dictionary = preload("res://ui/chat_media.gd").from_wire(str(contents.get("paramVec", "")), text)
	if not media.is_empty():
		chat_log[-1]["media"] = media

	var post: int = preload("res://ui/forum.gd").from_wire(str(contents.get("paramVec", "")), text)
	if post > 0:
		chat_log[-1]["post"] = post

	var tea: int = preload("res://ui/tea_room.gd").from_wire(str(contents.get("paramVec", "")), text)
	if tea > 0:
		chat_log[-1]["tea"] = tea

	var rp: Dictionary = preload("res://ui/red_envelope.gd").from_wire(str(contents.get("paramVec", "")), text) if channel in [2, 1024] else {}
	if not rp.is_empty():
		chat_log[-1]["rp"] = rp
		if channel == 2:
			chat_log[-1]["tab"] = "all"
			chat_log[-1]["head"] = "[" + str(CHAT_LABELS[2]) + "]"
		preload("res://ui/red_envelope.gd").heard()


func _receive_tea_chat(contents: Dictionary, text: String) -> void :
	var sender: int = int(contents.get("senderOid", 0))
	tea_log.append({"oid": sender, "uuid": str(contents.get("senderUuid", "")), "name": str(contents.get("sender", "")), 
		"text": text, "raw": str(contents.get("content", "")), "vip": int(contents.get("senderVipLvl", 0)) % 100, 
		"gm": int(contents.get("senderGmLv", 0)), "own": sender == account_oid})
	if tea_log.size() > TEA_LOG_MAX:
		tea_log = tea_log.slice(tea_log.size() - TEA_LOG_MAX)
	tea_rev += 1




func send_tea_chat(text: String) -> String:
	text = text.strip_edges()
	if text.is_empty():
		return "-"
	if battle.active or state not in ["lobby", "hall", "room"]:
		return "Đã rời Phòng Trà."
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _chat_sent < 2.0:
		return "Nói quá nhanh"
	_chat_sent = now
	var who: String = str(character.get("name", account.get("name", "")))
	_send_chat_packet(CHAT_TEA, who, text, "", 0, int(Time.get_unix_time_from_system() * 1000))
	return ""

func clear_tea_log() -> void :
	tea_log = []
	tea_rev += 1









const BUY_LIFE_77: String = "Lượt hồi sinh miễn phí còn lại: %d"
const BUY_LIFE_283: String = "(Cần %d Bạc)"
const BUY_LIFE_284: String = "(Cần %d Xu)"
const BUY_LIFE_285: String = "Hết lượt hồi sinh"
const BUY_LIFE_289: String = "Xu không đủ"
func _receive_buy_life(body: PackedByteArray) -> void :
	if body.size() < 12 or not (battle.active and not battle.ended):
		return
	var free: int = body.decode_s32(0)
	var coin: int = body.decode_s32(4)
	var cash: int = body.decode_s32(8)
	var enabled: bool = true
	var info: Dictionary = {"scene": battle.scene_id, "spawns": battle.self_spawns, "free": free, "coin": coin, "cash": cash, "type": 0, "num": 0}
	if free > 0:
		info.tip = BUY_LIFE_77 % free
	elif coin > 0 and int(currency.get("m_iGolden", 0)) >= coin:
		info.type = 2
		info.num = coin
		info.tip = BUY_LIFE_283 % coin
	elif cash > 0:
		info.type = 1
		info.num = cash
		enabled = int(currency.get("m_iCash", 0)) >= cash
		info.tip = BUY_LIFE_284 % cash if enabled else BUY_LIFE_289
	else:
		info.tip = BUY_LIFE_285
		enabled = false
	info.enabled = enabled
	buy_life = info
	buy_life_rev += 1
	changed.emit()


func buy_life_shown() -> bool:
	return buy_life.has("tip") and battle.active and not battle.ended and int(buy_life.scene) == battle.scene_id\
	and int(buy_life.spawns) == battle.self_spawns



func request_buy_life(coin_type: int) -> bool:
	if _role != "gate" or not (battle.active and battle.started and not battle.ended) or battle.look:
		return false
	_send("SceneMessage.RequestBuyLife", {"m_nSceneId": battle.scene_id, "m_type": coin_type})
	return true


func ask_buy_life() -> bool:
	return int(character.get("setting_flag", 0)) & 1 == 0



func set_ask_buy_life(ask: bool) -> bool:
	if _role != "gate" or _phase != "world" or state != "battle" or not character.has("setting_flag"):
		return false
	var flags: int = int(character["setting_flag"])
	character["setting_flag"] = (flags & ~ 1 if ask else flags | 1) & 4294967295
	_send("CharMessage.RequestChangeSetting", {"m_setting": int(character["setting_flag"])})
	changed.emit()
	return true

func send_signal(signal_type: int, pos: Vector2) -> void :
	if not (battle.active and battle.started and not battle.ended):
		return
	if battle.look:
		return

	var body: PackedByteArray = PackedByteArray()
	body.resize(10)
	body.encode_u32(0, battle.scene_id)
	body.encode_s16(4, clampi(int(pos.x), 0, 32767))
	body.encode_s16(6, clampi(int(pos.y), 0, 32767))
	body[8] = signal_type
	_send_raw(511, body)



func request_spray() -> bool:
	if not (battle.active and battle.started and not battle.ended) or not battle.tanks.has(battle.self_id):
		return false
	var pos: Vector2 = battle.tanks[battle.self_id].pos
	pos = _mirror.point(battle, pos)
	var body: PackedByteArray = PackedByteArray()
	body.resize(8)
	body.encode_u32(0, battle.scene_id)
	body.encode_s16(4, clampi(int(pos.x), 0, 32767))
	body.encode_s16(6, clampi(int(pos.y), 0, 32767))
	_send_raw(507, body)
	return true


func request_surrender() -> void :
	if not (battle.active and battle.started and not battle.ended):
		return
	var body: PackedByteArray = PackedByteArray()
	body.resize(4)
	body.encode_u32(0, battle.scene_id)
	_send_raw(512, body)


func vote_surrender(agree: bool) -> void :
	if battle.vote.is_empty() or battle.ended:
		return
	var body: PackedByteArray = PackedByteArray()
	body.resize(5)
	body.encode_u8(0, 2 if agree else 1)
	body.encode_u32(1, battle.scene_id)
	_send_raw(513, body)
	battle.vote["voted"] = true

func _on_bytes(data: PackedByteArray) -> void :
	var stream: Frames = _frames
	var result: Dictionary = stream.feed(data)
	if not result["ok"]:

		_pf_drain(stream, false)
		if _frames == stream and _channel != null:
			_fail("Dữ liệu kết nối không hợp lệ.", "PROTOCOL")
		return
	if _pf_draining:

		for frame in result["frames"]:
			if _frames != stream or _channel == null:
				break
			_handle_frame(frame)
		return
	for frame: PackedByteArray in result["frames"]:
		if frame.decode_s16(2) == 1003:
			_pf_pong_at = _pf_poll_at if _pf_start > 0 else Time.get_ticks_msec()
		_pf_queue.append(frame)
	_pf_drain(stream, true)




func _pf_poll() -> void :
	_pf_start = Time.get_ticks_usec()
	_pf_poll_at = Time.get_ticks_msec()
	_pf_count = 0
	if _pf_head < _pf_queue.size():
		_pf_drain(_frames, true)
	if _channel != null:
		_channel.poll()
	_pf_start = 0



func _pf_drain(stream: Frames, budget: bool) -> void :
	var limit: bool = budget and _pf_start > 0 and not bg_hidden and state == "battle" and battle.active and battle.started\
	and not battle.ended and _pf_queue.size() - _pf_head <= PF_BACKLOG
	_pf_draining = true
	while _pf_head < _pf_queue.size():
		if _frames != stream or _channel == null:
			break
		if limit and _pf_count > 0 and Time.get_ticks_usec() - _pf_start >= PF_BUDGET_USEC:
			break
		var frame: PackedByteArray = _pf_queue[_pf_head]
		_pf_head += 1
		_pf_count += 1
		_handle_frame(frame)
	_pf_draining = false
	if _pf_head >= _pf_queue.size() or _frames != stream or _channel == null:
		_pf_queue.clear()
		_pf_head = 0





func _pf_flush() -> void :
	if _channel != null:
		_pf_start = 0
		_channel.poll()


func _pf_decode(frame: PackedByteArray) -> Dictionary:
	var packet: Dictionary = _pf_decoder.decode_frame(frame)
	return packet if not packet.is_empty() else _decoder.decode_frame(frame)


func _receive_voice(body: PackedByteArray) -> void :
	if body.size() < 5:
		return
	var op: int = body[0]
	var at: int = 1
	var parts: Array[String] = []
	for _i in range(2):
		if at + 2 > body.size():
			return
		var n: int = body.decode_u16(at)
		at += 2
		if n > 64 or at + n > body.size():
			return
		parts.append(body.slice(at, at + n).get_string_from_utf8())
		at += n
	if op < 1 or op > 6 or (op >= 4 and parts[0] != "tea"):
		return
	voice_notice.emit(op, parts[0], parts[1])


func _receive_expedition(body: PackedByteArray) -> void :
	if body.size() < 48:
		return
	var times: Array = []
	var tanks: Array = []
	for i in range(3):
		times.append(int(body.decode_u32(i * 4)))
	for i in range(9):
		tanks.append(int(body.decode_u32(12 + i * 4)))
	var live: bool = body.size() >= 60 and int(body.decode_u32(48)) == 1
	var offset: int = int(body.decode_u32(52)) - int(Time.get_unix_time_from_system()) if live else 0
	expedition = {"times": times, "tanks": tanks, "live": live, "offset": offset, "owned": int(body.decode_u32(56)) if live else 0}
	expedition_rev += 1
	changed.emit()


func expedition_now() -> int:
	return int(Time.get_unix_time_from_system()) + int(expedition.get("offset", 0))



func expedition_send(type: int, group: int, tanks: Array = []) -> bool:
	if _role != "gate" or _phase != "world" or not bool(expedition.get("live", false)) or type not in [376, 377, 378] or group < 1 or group > 3:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(group)
	if type == 376:
		for i in range(3):
			body.put_u32(maxi(0, int(tanks[i])) if i < tanks.size() else 0)
	_send_raw(type, body.data_array)
	return true


static func _gb_utf(s: StreamPeerBuffer) -> Variant:
	if s.get_available_bytes() < 2:
		return null
	var n: int = s.get_u16()
	if s.get_available_bytes() < n:
		return null
	return s.get_utf8_string(n) if n > 0 else ""






static func parse_guild_boss(body: PackedByteArray) -> Dictionary:
	var s: StreamPeerBuffer = StreamPeerBuffer.new()
	s.data_array = body
	s.big_endian = false
	if s.get_available_bytes() < 2:
		return {}
	var flash: Dictionary = {}
	for i in range(s.get_u16()):
		if s.get_available_bytes() < 12:
			return {}
		var id: int = s.get_u32()
		var dead: int = s.get_u32()
		var opened: int = s.get_u32()
		var round_id: Variant = _gb_utf(s)
		var lucky: Variant = _gb_utf(s)
		if round_id == null or lucky == null or s.get_available_bytes() < 2:
			return {}
		var rows: Array = []
		for k in range(s.get_u16()):
			var uid: Variant = _gb_utf(s)
			var name: Variant = _gb_utf(s)
			if uid == null or name == null or s.get_available_bytes() < 8:
				return {}
			rows.append({"uid": uid, "name": name, "dmg": s.get_32(), "close_at": s.get_u32()})
		rows.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a.dmg) > int(b.dmg))
		flash[id] = {"dead_time": dead, "open_at": opened, "round": round_id, "lucky": lucky, "rows": rows}
	if s.get_available_bytes() < 17 or s.get_u32() != 1:
		return {"live": false}
	var info: Dictionary = {"live": true, "now": s.get_u32(), "role": s.get_u8(), "entries": s.get_u16(), "entries_max": s.get_u16(), 
		"cooldown": s.get_u32()}
	var guild_name: Variant = _gb_utf(s)
	if guild_name == null or s.get_available_bytes() < 2:
		return {}
	info["guild"] = guild_name
	var bosses: Array = []
	for i in range(s.get_u16()):
		if s.get_available_bytes() < 10:
			return {}
		var boss: Dictionary = {"id": s.get_u32(), "tier": s.get_u16(), "map": s.get_u32()}
		var name: Variant = _gb_utf(s)
		var desc: Variant = _gb_utf(s)
		if name == null or desc == null or s.get_available_bytes() < 37:
			return {}
		boss.merge({"name": name, "desc": desc, "max_hp": s.get_u32(), "hp": s.get_u32(), "status": s.get_u8(), "close_at": s.get_u32(), 
			"summons": s.get_u8(), "tank_ok": s.get_u8() == 1})
		var need_a: Array = [s.get_u16(), s.get_u16()]
		var need_b: Array = [s.get_u16(), s.get_u16()]
		boss.merge({"need": [need_a, need_b], "base": s.get_u32(), "rand": s.get_u32(), "attack": s.get_u16()})
		var avatar: Variant = _gb_utf(s)
		if avatar == null:
			return {}
		boss["avatar"] = avatar
		boss.merge(flash.get(boss.id, {"dead_time": 0, "open_at": 0, "round": "", "lucky": "", "rows": []}))
		bosses.append(boss)
	info["bosses"] = bosses
	return info


func _receive_guild_boss(type: int, body: PackedByteArray) -> void :
	var s: StreamPeerBuffer = StreamPeerBuffer.new()
	s.data_array = body
	s.big_endian = false
	if type == 1833:
		var info: Dictionary = parse_guild_boss(body)
		if info.is_empty():
			return
		info["offset"] = int(info.get("now", 0)) - int(Time.get_unix_time_from_system()) if bool(info.live) else 0
		guild_boss = info
	elif type == 1352:
		if body.size() < 2 or body.size() < 2 + 16 * body.decode_u16(0):
			return
		var list: Array = []
		for i in range(s.get_u16()):
			list.append({"boss": s.get_u32(), "base": s.get_u32(), "rand": s.get_u32(), "time": s.get_u32()})
		guild_boss_awards = list
	else:
		if body.size() < 2:
			return
		var list: Array = []
		for i in range(s.get_u16()):
			var boss: Variant = _gb_utf(s)
			var guild_name: Variant = _gb_utf(s)
			if boss == null or guild_name == null or s.get_available_bytes() < 4:
				return
			list.append({"boss": boss, "guild": guild_name, "time": s.get_u32()})
		guild_boss_feed = list
	guild_boss_rev += 1
	changed.emit()


func guild_boss_now() -> int:
	return int(Time.get_unix_time_from_system()) + int(guild_boss.get("offset", 0))


func guild_boss_send(type: int, boss: int) -> bool:
	if _role != "gate" or _phase != "world" or not bool(guild_boss.get("live", false)) or type not in [323, 324] or boss <= 0:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(boss)
	_send_raw(type, body.data_array)
	return true


func _honor_list(value: Dictionary) -> void :
	var rows: Array = value.get("m_honorList", [])
	var op: int = int(value.get("m_nOpType", 1))
	if op != 0 and op != 2:
		honors = rows.duplicate()
		return
	var ids: Array = rows.map( func(row: Variant) -> int: return int((row as Dictionary).get("nHonorId", 0)) if row is Dictionary else 0)
	honors = honors.filter( func(row: Variant) -> bool: return not (row is Dictionary and ids.has(int(row.get("nHonorId", 0)))))
	if op == 0:
		honors.append_array(rows)
		if not ids.is_empty():
			honor_added.emit(ids)

func _handle_frame(frame: PackedByteArray) -> void :
	var type: int = frame.decode_s16(2)
	_idle = 0.0


	if type == 903:
		if _phase != "version" or frame.size() != 20:
			_fail("Máy chủ trả về phiên bản giao thức không đúng.", "PROTOCOL")
			return
		_phase = "bootstrap"
		_deadline = 0.0
		_wsd_old = false
		if _role == "login":
			_send("AuthMessage.RequestAuthLogin", {"m_microclient": 0, 
				"m_name": str(account["username"]), "m_passwd": _token, "m_adult": "1", 
				"m_time": "", "m_platform": "", "m_channel": "", "m_token": "", 
				"m_passport": "", "m_clientSid": 299001})
			_token = ""
		else:
			_send("AuthMessage.RequestServerLogin", {"m_session": _session, "m_nAcctId": account_id})
			_session = 0
		return
	if type == 908:
		_fail("Phiên đăng nhập bị từ chối.", "SESSION")
		return
	if type == 1409:
		_receive_expedition(frame.slice(8))
		return
	if type in [1833, 1352, 1840]:
		_receive_guild_boss(type, frame.slice(8))
		return
	if type == 1576:
		_receive_buy_life(frame.slice(8))
		return
	if type == 1975:
		_receive_voice(frame.slice(8))
		return
	if type in [4235, 4238, 1114]:
		_receive_bonfire(type, frame.slice(8))
		return
	if type == 1107:

		if frame.size() >= 12:
			rolled.emit(int(frame.decode_u32(8)))
		return
	if type in [4223, 1515, 4250, 4251] and _luck_raw(type, frame):
		return
	if type == 1157:

		var rows: Variant = SafeJson.parse(frame.slice(8).get_string_from_utf8())
		if rows is Array:
			tank_rents = []
			for row: Variant in rows:
				if row is Dictionary:
					tank_rents.append(row)
			tank_rent_got = true
			tank_rent_rev += 1
			changed.emit()
		return
	if type == 1041 or type == 1042:

		bought_kind = int(frame.decode_s32(8)) if type == 1041 and frame.size() >= 12 else 0
		bought.emit(type == 1041, int(frame.decode_u32(12)) if type == 1041 and frame.size() >= 16 else 0)
		return
	if type == 1056:

		var size: int = int(frame.decode_u16(8)) if frame.size() >= 10 else 0
		battle_helper = frame.slice(10, 10 + size).get_string_from_utf8() if size > 0 and frame.size() >= 10 + size else ""
		bag_rev += 1
		changed.emit()
		return
	if type == 1950:

		var body: PackedByteArray = frame.slice(8)
		var count: int = int(body.decode_u16(0)) if body.size() >= 2 else 0
		for i in range(count):
			var at: int = 2 + i * 16
			if at + 16 > body.size():
				break
			acts[int(body.decode_u32(at))] = [int(body.decode_u32(at + 4)), int(body.decode_u32(at + 8)), int(body.decode_u32(at + 12))]
		act_rev += 1
		changed.emit()
		return
	if type == 1952 or type == 1953:

		if _receive_world_boss(type, frame.slice(8)):
			changed.emit()
		return
	if type in [1300, 1303, 1304, 1516]:

		if _receive_pve(type, frame.slice(8)):
			changed.emit()
		return
	if type == 1305:

		if _receive_pve_sweep(frame.slice(8)):
			changed.emit()
		return
	if type in [1454, 1455, 1457, 1458, 1459, 1461]:
		_receive_crystal(type, frame.slice(8))
		return
	if type in [1250, 1251, 1252, 1253, 1254, 1306, 1307, 1308, 1309]:
		_receive_quest(type, frame.slice(8))
		quest_rev += 1
		changed.emit()
		return
	if type in [1413, 1414, 1415, 1416, 1417, 1838]:

		_receive_challenge(type, frame.slice(8))
		return
	if type in [81, 1045, 1049, 1400]:
		_receive_event(type, frame.slice(8))
		event_rev += 1
		changed.emit()
		return
	if type in [1350, 1351, 1832]:


		if _receive_guild_skill(type, frame.slice(8)):
			changed.emit()
		else:
			_ignore_packet(type)
		return
	if type in [1801, 1802, 1803]:


		var size: int = int(frame.decode_u16(8)) if frame.size() >= 10 else 0
		var uuid: String = frame.slice(10, 10 + size).get_string_from_utf8() if type == 1802 and size > 0 and frame.size() >= 10 + size else ""
		if type != 1802 or uuid == guild_self_uuid():
			_clear_guild()
		else:
			guild_members.erase(uuid)
			guild_briefs.erase(uuid)
			guild_rev += 1
		changed.emit()
		return
	if type == 30001:
		_receive_weekly(frame.slice(8))
		changed.emit()
		return
	if type == 1027:


		var thew_body: PackedByteArray = frame.slice(8)
		if not character.is_empty():
			if thew_body.size() >= 12:
				character["thew"] = thew_body.decode_s32(0)
				character["thew_buy"] = thew_body.decode_s32(4)
			elif thew_body.size() >= 4:
				character["thew"] = thew_body.decode_s16(0)
				character["thew_buy"] = thew_body.decode_s16(2)
		changed.emit()
		return
	if type == 1962:

		var balls: PackedByteArray = frame.slice(8)
		fire_ball_tanks = []
		for i in range(int(balls.decode_u16(0)) if balls.size() >= 2 else 0):
			if 2 + i * 4 + 4 > balls.size():
				break
			fire_ball_tanks.append(int(balls.decode_u32(2 + i * 4)))
		changed.emit()
		return
	if type in PAIR_RAW:


		_receive_pair(type, frame.slice(8))
		changed.emit()
		return
	if type == 1590:


		auto_bullet()
		return
	if type == 1512:


		if frame.size() >= 12:
			impeach_result.emit(int(frame.decode_u32(8)))
		return
	if type == 1011 or type == 1012 or type == 1013:
		_create_reply(type, frame)
		return
	if type == 1823:



		if _role == "gate" and not guild.is_empty():
			if state == "battle":
				guild_tip_due = true
			else:
				noticed.emit(GUILD_APPLY_TIP)
			chat_note(GUILD_APPLY_TIP)
			guild_req_join += 1
			guild_rev += 1
			changed.emit()
		return
	var packet: Dictionary = _pf_decode(frame)
	if not packet["ok"]:
		if _needs_packet(type):
			_fail("Gói dữ liệu không hợp lệ (" + str(type) + ").", "PROTOCOL")
		else:
			_ignore_packet(type)
		return
	var value: Dictionary = packet["value"]
	if type == 1047:
		_receive_option(str(value.get("m_strOption", "")))
		changed.emit()
		return
	if _role == "gate" and _receive_talent(type, value):
		changed.emit()
		return
	if _role == "gate" and _receive_guild(type, value):
		guild_rev += 1
		changed.emit()
		return

	if _role == "gate" and master.receive(type, value, char_uuid, int(character.get("level", 0))):
		master_rev += 1
		while not master.tips.is_empty():
			chat_note(str(master.tips.pop_front()))
		changed.emit()
		return
	if _role == "gate" and _receive_mysterious_store(type, value):
		changed.emit()
		return

	if _role == "gate" and _receive_friends(type, value):
		friend_rev += 1
		changed.emit()
		return
	if _phase == "world" and _handle_play_packet(type, value):
		return
	match type:
		901:
			if _role != "login" or _phase != "bootstrap":
				_fail("Máy chủ đăng nhập trả lời không đúng thứ tự.", "PROTOCOL")
				return
			_session = value["m_sessionkey"]
			account_id = value["m_nAcctId"]
			_has_login = true
		902:
			_fail(str(value["m_errMsg"]) if not str(value["m_errMsg"]).is_empty() else "Đăng nhập bị từ chối.", str(value["m_reason"]))
		904:
			_fail("Phiên bản trò chơi bị từ chối.", str(value["m_reason"]))
		906:
			if not _has_login or _role != "login":
				_fail("Danh sách máy chủ đến trước khi đăng nhập xong.", "PROTOCOL")
				return
			for candidate in value["m_regions"]:
				if candidate["region_id"] == 299001:
					region = candidate.duplicate()
					_connect_role("gate")
					return
			_fail("Máy chủ BangBang đang không mở.", "SERVER")
		909:
			_fail("Máy chủ đã đóng phiên chơi.", str(value["m_reason"]))
		1006:
			_fail("Không vào được thế giới game.", str(value["m_reason"]))
		1014:
			characters = value["m_list"]
			var wanted: String = str(account.get("name", ""))
			if wanted.is_empty():
				wanted = str(account.get("username", ""))
			for candidate in characters:
				if candidate["m_basic"]["name"] == wanted:
					_pending_character = candidate["m_charUuid"]
					character = candidate["m_basic"].duplicate()
					break
			if _pending_character.is_empty() and characters.size() == 1:
				_pending_character = characters[0]["m_charUuid"]
				character = characters[0]["m_basic"].duplicate()
			if _rc_until > 0 and not _rc_uuid.is_empty():
				for candidate in characters:
					if str(candidate["m_charUuid"]) == _rc_uuid:
						_pending_character = _rc_uuid
						character = candidate["m_basic"].duplicate()
			if _pending_character.is_empty():
				state = "characters"
				status = "Tài khoản chưa có nhân vật." if characters.is_empty() else "Chọn nhân vật."
		1005:
			account_oid = value["m_account_oid"]


			if not _pending_character.is_empty():
				char_uuid = _pending_character
			_pending_character = ""
			state = "lobby"
			_phase = "world"
			status = "Đã vào máy chủ BangBang."
			if _role == "gate":
				request_applies()
		1016:
			character = value["m_charData"].duplicate()
			currency = value["m_currency"].duplicate()
			_set_technologies(value["m_technoVec"])
		1039:
			currency = value["m_currency"].duplicate()
		1031:

			first_charge = int(value.get("m_nChargeCount", 0))
		1033:

			pwd_has = int(value.get("m_bHasPwd", 0)) == 1
			pwd_ticket = int(value.get("m_nDelPwdTicket", 0))
			if not pwd_has:
				pwd_lock = false
			if not _pwd_tiped:
				_pwd_tiped = true
				var left: int = pwd_ticket - int(Time.get_unix_time_from_system())
				if left > 0:
					pwd_notice.emit(left)
		1034:

			var op: int = int(value.get("m_nOpType", 0))
			var ok: bool = int(value.get("m_bResult", 0)) == 1
			if ok and op == 1:
				pwd_lock = false
			elif ok and op in [3, 7]:
				pwd_lock = true
			pwd_result.emit(op, ok)
		1035:
			pwd_check_asked.emit()
		1158, 1159:

			hire_presented.emit(str(value.get("m_strPresentName", "")) if type == 1158 else "", int(value.get("m_nTankId", 0)), 
				int(value.get("m_nTankLevel", 0)), int(value.get("m_nHireTime", 0)))
		1407:

			mystic_tank = int(value.get("m_tankId", 0))
			mystic_end = int(value.get("m_recommendEndTime", 0))
		1036:

			character["setting_flag"] = int(value.get("m_setting", 0))
		1023:
			character["avatarId"] = value["m_avatarId"]
			bag_rev += 1
		1150:

			if int(value.get("m_notifyType", 0)) == 1:
				tanks.clear()
			for tank: Dictionary in value.get("m_tankVec", []):
				tanks[str(tank.get("m_tankUuid", ""))] = tank

			if int(value.get("m_notifyType", 0)) == 2 and int(value.get("m_contType", 0)) == 0:
				for tank: Variant in value.get("m_tankVec", []):
					if tank is Dictionary:
						tank_achieved.emit(tank)
		1163:

			for chip: Dictionary in value.get("m_vecChip", []):
				skin_chips[int(chip.get("m_nSkinId", 0))] = int(chip.get("m_nSchedule", 0))
			skin_chip_rev += 1
			_auto_check_chip(skin_chips.keys())
		1164:

			if int(value.get("m_nResult", 0)) == 1:
				var chip_id: int = int(value.get("m_nSkinId", 0))
				var chip_old: int = int(skin_chips.get(chip_id, 0))
				skin_chips[chip_id] = int(value.get("m_nSchedule", 0))
				skin_chip_rev += 1
				_auto_check_chip([chip_id])
				skin_chip_added.emit(chip_id, int(skin_chips[chip_id]) - chip_old)
		1165:




			if int(value.get("m_nResult", 0)) != 1:
				_chip_asked.erase(int(value.get("m_nSkinId", 0)))
			elif Time.get_ticks_msec() - _tank_up_msec < TANK_UP_SKIN_MS:
				_skin_new(int(value.get("m_nSkinId", 0)), owns_skin(int(value.get("m_nSkinId", 0))))
		1100:
			_receive_items(value)
		1101:

			var swap_cont: int = int(value.get("m_contType", 0))
			var slot_a: int = int(value.get("m_slotA", -1))
			var slot_b: int = int(value.get("m_slotB", -1))
			if slot_a != slot_b and bags.has(swap_cont):
				for item: Dictionary in bags[swap_cont]:
					var at_slot: int = int(item.get("m_slotNo", -1))
					if at_slot == slot_a:
						item["m_slotNo"] = slot_b
					elif at_slot == slot_b:
						item["m_slotNo"] = slot_a
				bags[swap_cont].sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("m_slotNo", 0)) < int(b.get("m_slotNo", 0)))
				bag_rev += 1
			item_swapped.emit(swap_cont, slot_a, slot_b)
		1102:
			_put_item(int(value.get("m_contType", 0)), value.get("m_item", {}))
			bag_rev += 1

			if int(value.get("m_contType", 0)) == 3 and not (value.get("m_item", {}) as Dictionary).is_empty():
				materials_added.emit([int(value.get("m_item", {}).get("m_slotNo", -1))])
		1103:
			var gone: Array = value.get("m_slotVec", [])
			var gone_ids: Array = value.get("m_itemUuidVec", [])
			var cont: int = int(value.get("m_contType", 0))
			if bags.has(cont):
				bags[cont] = bags[cont].filter( func(item: Dictionary) -> bool:
					return not gone.has(int(item.get("m_slotNo", -1))) and not gone_ids.has(str(item.get("m_itemUuid", ""))))
			bag_rev += 1
		1115:
			sprays = value.get("m_sprayList", []).duplicate()
			bag_rev += 1
		1116:
			if not sprays.has(int(value.get("m_sprayId", 0))):
				sprays.append(int(value.get("m_sprayId", 0)))
			bag_rev += 1
		1022:
			character["sprayId"] = int(value.get("m_sprayId", 0))
			bag_rev += 1
		1037:
			character["grocery_add"] = int(value.get("m_nAdd", 0))
			bag_rev += 1
		3216:

			if str(value.get("m_szUuid", "")) == char_uuid and not char_uuid.is_empty():
				_set_technologies(value.get("m_technoVec", []), int(value.get("m_eloUpType", 1)) == 0)
		85:

			if int(value.get("m_bType", 0)) == 8:
				var section_vec: Array = technologies.duplicate()
				if section_vec.size() > 10:
					section_vec[10] = int(value.get("m_upUint", 0))
					_set_technologies(section_vec, true)

			if int(value.get("m_bType", 0)) == 27:
				var star_was: int = int(character.get("nMilitaryStar", 0))
				character["nMilitaryStar"] = int(value.get("m_upUint", 0))
				bag_rev += 1
				military_star.emit(star_was, int(character["nMilitaryStar"]))
		1029:
			_honor_list(value)
			bag_rev += 1
		1256:
			achievements.clear()
			for row: Variant in value.get("m_acemVec", []):
				if row is Dictionary:
					achievements[int(row.get("m_nId", 0))] = [int(row.get("m_nState", 0)), int(row.get("m_nCheckCount", 0))]
			bag_rev += 1
		1255:
			var acem: Dictionary = value.get("m_acemInfo", {})
			if int(acem.get("m_nId", 0)) > 0:
				achievements[int(acem.get("m_nId", 0))] = [int(acem.get("m_nState", 0)), int(acem.get("m_nCheckCount", 0))]
				bag_rev += 1
		1028:
			character["honor_id"] = int(value.get("m_honorId", 0))
			honors_worn = []
			for field: String in ["m_honorId", "m_honorId2", "m_honorId3", "m_honorId4"]:
				if int(value.get(field, 0)) > 0:
					honors_worn.append(int(value.get(field, 0)))
			bag_rev += 1
		1104:
			if battle.active and int(value.get("m_opType", 0)) in battle.PVP_AWARDS:
				battle.pvp_award = value.duplicate(true)
			elif battle.active and int(value.get("m_opType", 0)) in PVE_AWARDS and pve_result_map(battle.map_id):
				battle.pvp_award = value.duplicate(true)
			var info: Dictionary = value.get("m_info", {})
			var got: Array = []
			var base_awards: Dictionary = {}
			for group: Dictionary in info.get("m_settleItemVec", []):
				for entry: Dictionary in group.get("m_itemVec", []):
					if int(entry.get("m_itemId", 0)) > 0 and int(entry.get("m_count", 0)) > 0:
						got.append([int(entry.m_itemId), int(entry.m_count)])
						if int(group.get("m_nType", 0)) in [0, 7]:
							var tid: int = int(entry.m_itemId)
							base_awards[tid] = int(base_awards.get(tid, 0)) + int(entry.m_count)
			if battle.active and not got.is_empty():
				_bags_stale = true
			var base_items: Array = []
			for tid: int in base_awards:
				base_items.append([tid, int(base_awards[tid])])
			award_show = int(value.get("m_isShow", 1))
			award_op = int(value.get("m_opType", 0))
			award_ext = int(value.get("m_nExtInfo", 0))

			awarded.emit({"coins": [int(info.get("m_cash", 0)), int(info.get("m_gift", 0)), int(info.get("m_golden", 0))], 
				"exp": int(info.get("m_exp", 0)), "items": got, "base_items": base_items, 
				"glory": int(info.get("m_glory", 0)), "fizz": int(info.get("m_fizz", 0)), "tanks": info.get("m_tankVec", [])})
		1018:
			prize_result.emit(int(value.get("m_awardId", 0)), int(value.get("m_isOk", 1)) == 0)
		1515:
			var rows: Array = []
			for entry: Dictionary in value.get("m_list", []):
				rows.append([str(entry.get("m_strName", "")), int(entry.get("m_rollId", 0)), int(entry.get("m_iCount", 0)), int(entry.get("m_nTime", 0))])
			roll_list.emit(int(value.get("m_nType", 0)), rows)
		1510:
			_gift_note(value)
			gift_used.emit(value)
		1113:
			item_failed.emit(int(value.get("m_contType", 0)), int(value.get("m_slotNo", -1)))
		1151:
			var updated: Dictionary = value.get("m_tankInst", {})
			var updated_id: String = str(updated.get("m_tankUuid", ""))

			if int(value.get("m_opType", 0)) == 19 and tanks.has(updated_id):
				updated["m_extFlag"] = int(tanks[updated_id].get("m_extFlag", 0))
			if int(updated.get("m_extFlag", 0)) == 2:
				for other: Dictionary in tanks.values():
					other["m_extFlag"] = 0

			if int(value.get("m_opType", 0)) == 10 and tanks.has(updated_id):
				var before: Dictionary = tanks[updated_id]
				if int(before.get("m_contType", 0)) == 0 and int(before.get("m_externalId", 0)) != 0:
					old_skins[int(before.get("m_tpltId", 0))] = int(before.get("m_externalId", 0))
			tanks[updated_id] = updated
			if int(value.get("m_opType", 0)) == 2:
				_tank_up_msec = Time.get_ticks_msec()
			tank_changed.emit(updated_id, int(value.get("m_opType", 0)))
		1174:


			if int(value.get("m_valType", -1)) == 0:
				var prof_tplt: int = int(value.get("m_tankId", 0))
				var prof_new: int = maxi(0, int(value.get("m_battleVal", 0)))
				for prof_uuid: Variant in tanks.keys():
					var prof_tank: Dictionary = tanks[prof_uuid]
					if int(prof_tank.get("m_tpltId", 0)) == prof_tplt and int(prof_tank.get("m_contType", -1)) == 0:
						prof_tank["m_proficiencyVal"] = prof_new
						tank_changed.emit(str(prof_uuid), -1)
		1160:

			var haloed: String = str(value.get("m_sTankUUID", ""))
			var worked: bool = int(value.get("m_bSuccess", 0)) != 0 and tanks.has(haloed)
			if worked:
				tanks[haloed]["m_haloId"] = int(value.get("m_nHaloId", 0))
			tank_changed.emit(haloed, 20 if worked else 21)
		1230:
			mail_unread = maxi(0, int(value.get("m_count", 0)))
			mail_rev += 1
		1231:
			mails.clear()
			for brief: Dictionary in value.get("m_briefList", []):
				mails.append(_mail_brief(brief))
			for known: String in mail_bodies.keys():
				if _mail_at(known) < 0:
					mail_bodies.erase(known)
			mail_loaded = true
			mail_rev += 1
		1232:
			var inside: Dictionary = value.get("m_info", {})
			var gifts: Array = []
			for gift: Dictionary in inside.get("m_itemVec", []):
				gifts.append([str(gift.get("m_itemUuid", "")), int(gift.get("m_templateId", 0)), maxi(1, int(gift.get("m_count", 1)))])
			mail_bodies[str(inside.get("m_strUuid", ""))] = {"text": str(inside.get("m_strText", "")), "cash": maxi(0, int(inside.get("m_cashNum", 0))), "items": gifts}
			mail_rev += 1
		1233:
			var done: bool = int(value.get("m_result", 0)) != 0
			var which: String = str(value.get("m_strMailUuid", ""))

			if done and int(value.get("m_opType", 0)) == 5 and not which.is_empty() and _mail_at(which) >= 0:
				mails.remove_at(_mail_at(which))
				mail_bodies.erase(which)

			if int(value.get("m_opType", 0)) == 8 and which.is_empty():
				mail_bodies.clear()
			mail_rev += 1
			mail_result.emit(done, int(value.get("m_opType", 0)), which)
		1234:
			var fresh: Dictionary = _mail_brief(value.get("m_briefInfo", {}))
			var spot: int = _mail_at(str(fresh.uuid))
			if spot >= 0:
				mails[spot] = fresh
			elif not str(fresh.uuid).is_empty():
				mails.push_front(fresh)
			mail_rev += 1
		1003:
			ping_count += 1
			if _ping_sent > 0:


				latency_ms = (_pf_pong_at if _pf_pong_at >= _ping_sent else Time.get_ticks_msec()) - _ping_sent
				_ping_sent = 0
			_pf_pong_at = 0
			battle.observe_clock(value.m_recvTime, latency_ms)
	changed.emit()



func _receive_items(value: Dictionary) -> void :
	var cont: int = int(value.get("m_contType", 0))
	var list: Array = value.get("m_itemVec", [])
	var sku1_new: int = 0
	if cont == 6 and int(value.get("m_notifyType", 0)) in [2, 4]:
		for item: Variant in list:
			if item is Dictionary and not owns_skin(int((item as Dictionary).get("m_templateId", 0))):
				sku1_new = int((item as Dictionary).get("m_templateId", 0))
				break
	if int(value.get("m_notifyType", 0)) == 5:
		for item: Dictionary in list:
			_put_item(cont, item)
	elif int(value.get("m_notifyType", 0)) == 1 or cont in [2, 3, 10] or not bags.has(cont):
		bags[cont] = list.duplicate()
		bags[cont].sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("m_slotNo", 0)) < int(b.get("m_slotNo", 0)))
	else:
		for item: Dictionary in list:
			_put_item(cont, item)
	bag_loaded = true
	bag_rev += 1

	if cont == 3 and int(value.get("m_notifyType", 0)) in [2, 4] and not list.is_empty():
		var slots: Array = []
		for item: Variant in list:
			if item is Dictionary:
				slots.append(int(item.get("m_slotNo", -1)))
		materials_added.emit(slots)

	if cont == 6 and sku1_new > 0:
		_skin_new(sku1_new, false)

func _put_item(cont: int, item: Dictionary) -> void :
	if item.is_empty():
		return
	var list: Array = bags.get(cont, [])
	var slot: int = int(item.get("m_slotNo", -1))
	var at: int = list.size()
	for i: int in list.size():
		if int(list[i].get("m_slotNo", -2)) == slot:
			at = i
			break
	if at < list.size():
		list[at] = item
	else:
		list.append(item)
		list.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("m_slotNo", 0)) < int(b.get("m_slotNo", 0)))
	bags[cont] = list


func bag_item(cont: int, slot: int) -> Dictionary:
	for item: Dictionary in bags.get(cont, []):
		if int(item.get("m_slotNo", -1)) == slot:
			return item
	return {}



func request_bags() -> void :
	if _role == "gate" and _phase == "world" and state in ["lobby", "hall", "room"]:
		_bag_asked = Time.get_ticks_msec() / 1000.0
		_bag_tries += 1
		_send("ItemMessage.RequestContainerItemMessage", {"m_contType": 0})

func _bag_ready(cont: int, slot: int) -> bool:
	return state in ["lobby", "hall", "room"] and (slot < 0 or not bag_item(cont, slot).is_empty())



func use_item(cont: int, slot: int, count: int = 1, target: String = "") -> bool:
	if not _bag_ready(cont, slot) or (slot < 0 and cont != 7):
		return false
	_send("ItemMessage.RequestUseItem", {"m_contType": cont, "m_iSlotNo": slot, "m_targetUuid": target, "m_iCount": maxi(count, 1), "m_bAuto": 0})
	if cont == 7:
		character["decorateId"] = int(bag_item(cont, slot).get("m_templateId", 0)) if slot >= 0 else 0
		bag_rev += 1
		changed.emit()
	return true



func sel_award_use(slot: int, count: int, pick: int) -> bool:
	if slot < 0 or count < 1 or pick < 1 or pick > 4 or not _bag_ready(2, slot):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(2)
	body.put_16(slot)
	body.put_32(count)
	body.put_32(pick)
	_send_raw(170, body.data_array)
	return true


func sort_bag(cont: int) -> bool:
	if not (cont in [2, 3]) or not _bag_ready(cont, -1):
		return false
	_send("ItemMessage.RequestCleanUpCont", {"m_contType": cont})
	return true


func sell_item(cont: int, slot: int) -> bool:
	if not (cont in [2, 3]) or slot < 0 or not _bag_ready(cont, slot):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(cont)
	body.put_16(slot)
	_send_raw(151, body.data_array)
	return true



func swap_item(cont: int, origin: int, dest: int, count: int) -> bool:
	if not (cont in [2, 3]) or origin < 0 or dest < 0 or origin == dest or count < 1 or not _bag_ready(cont, origin):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(cont)
	body.put_16(origin)
	body.put_16(dest)
	body.put_32(count)
	_send_raw(150, body.data_array)
	return true





func _quest_info(body: PackedByteArray, at: int) -> void :

	quests[body.decode_u32(at)] = [body.decode_u32(at + 4), body.decode_u32(at + 8), body.decode_u32(at + 12), 
		body.decode_u32(at + 16), body.decode_u32(at + 20), body.decode_u32(at + 24)]

func _receive_quest(type: int, body: PackedByteArray) -> void :
	match type:
		1250:

			var count: int = int(body.decode_u16(0)) if body.size() >= 2 else 0
			var kind: int = int(body.decode_s32(2 + count * 28)) if body.size() >= 6 + count * 28 else 1
			if kind != 2:
				quests = {}
			for i in range(count):
				if 2 + (i + 1) * 28 > body.size():
					break
				_quest_info(body, 2 + i * 28)
			quests_loaded = true
		1251:
			if body.size() >= 28:
				_quest_info(body, 0)
		1252:
			var count: int = int(body.decode_u16(0)) if body.size() >= 2 else 0
			for i in range(count):
				if 6 + i * 4 > body.size():
					break
				quests.erase(int(body.decode_u32(2 + i * 4)))
		1253:

			pass
		1254:
			quest_failed.emit(int(body.decode_u32(0)) if body.size() >= 4 else 0)
		1306:

			if body.size() >= 28:
				var stage: int = int(body.decode_u32(0))
				if stage >= 700 and stage <= 706:

					for other in range(700, 707):
						stages.erase(other)
					stages_cleared.erase(706)
				elif stage >= 1500 and stage <= 1507:

					for other in range(1500, 1508):
						stages.erase(other)
						stages_cleared.erase(other)
				elif stage >= 1600 and stage <= 1611:


					for other in range(1600, 1612):
						stages.erase(other)
						stages_cleared.erase(other)
				elif stage >= 1800 and stage <= 1809:


					for other in range(1800, 1810):
						stages.erase(other)
						stages_cleared.erase(other)
				elif stage >= 1000 and stage <= 1004:

					for other in range(1000, 1005):
						stages.erase(other)
						stages_cleared.erase(other)
				stages[stage] = {"reward": int(body.decode_u32(4)), "reaped": int(body.decode_u32(8)), 
					"next": int(body.decode_u32(12)), "flag": int(body.decode_u32(16)), "level": int(body.decode_u32(20)), 
					"value": int(body.decode_u32(24))}
		1307:
			if body.size() >= 8:
				stage_reaped.emit(int(body.decode_u32(0)), int(body.decode_u32(4)))
		1308:
			if body.size() >= 4:
				var last: int = int(body.decode_u32(0))
				if last >= 700 and last <= 706:
					for other in range(700, 707):
						stages.erase(other)
				elif last >= 1500 and last <= 1507:
					for other in range(1500, 1508):
						stages.erase(other)
				elif last >= 1000 and last <= 1004:
					for other in range(1000, 1005):
						stages.erase(other)
				elif last == 1400:
					stages.erase(last)
				stages_cleared[last] = int(body.decode_u32(4)) if body.size() >= 8 else 0
		1309:

			if body.size() >= 6:
				var now: Array = []
				var top: Array = []
				var count: int = int(body.decode_u16(4))
				var at: int = 6
				for i in range(count):
					if at + 4 > body.size():
						break
					now.append(int(body.decode_u32(at)))
					at += 4
				if at + 2 <= body.size():
					var limit: int = int(body.decode_u16(at))
					at += 2
					for i in range(limit):
						if at + 4 > body.size():
							break
						top.append(int(body.decode_u32(at)))
						at += 4
				stage_progress[int(body.decode_u32(0))] = [now, top]


func daily_progress() -> Array:
	var got: Variant = stage_progress.get(STAGE_DROPS)
	var now: Array = got[0] if got is Array and not (got as Array).is_empty() and got[0] is Array else []
	var out: Array = []
	for id: int in DAILY_MODES:
		var top: int = int(DAILY_SETTLE_MAX.get(id, 0)) if got != null else 0
		var cur: int = int(now[id]) if id < now.size() else 0
		out.append("%d/%d" % [mini(cur, top), top])
	return out

func _receive_event(type: int, body: PackedByteArray) -> void :
	match type:
		1400:

			if body.size() >= 28:
				sign_in = {"flag": int(body.decode_u32(0)), "vip_flag": int(body.decode_u32(4)), "year": int(body.decode_u32(8)), 
					"month": int(body.decode_u32(12)), "day": int(body.decode_u32(16)), "count": int(body.decode_u32(20)), 
					"stage": int(body.decode_u32(24))}
		81:

			if body.size() >= 8:
				character["cashback_times"] = int(body.decode_u32(0))
				character["cashback_picked"] = int(body.decode_u32(4))
		1049:

			if body.size() >= 20:
				character["vipPoints"] = int(body.decode_u32(0))
				character["vipTime"] = int(body.decode_u32(4))
				character["vipPointsAddToday"] = int(body.decode_u32(12))
				character["superVipTime"] = int(body.decode_u32(16))
		1045:
			var count: int = int(body.decode_u16(0)) if body.size() >= 2 else 0
			for i in range(count):
				if 10 + i * 8 > body.size():
					break
				limits[int(body.decode_u32(2 + i * 8))] = int(body.decode_s32(6 + i * 8))


func sign_in_today() -> bool:
	if not _crystal_ready():
		return false
	_send_raw(360, PackedByteArray())
	return true


func sign_in_mark(days: int) -> bool:
	if not _crystal_ready() or days <= 0:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(days)
	_send_raw(361, body.data_array)
	return true


func sign_in_vip() -> bool:
	if not _crystal_ready():
		return false
	_send_raw(362, PackedByteArray())
	return true


func cashback_pick() -> bool:
	if not _crystal_ready():
		return false
	_send_raw(80, PackedByteArray())
	return true


func quest_complete(quest: int, choice: int = 0) -> bool:
	if not _crystal_ready() or int(quests.get(quest, [0])[0]) != 3:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(quest)
	body.put_u32(maxi(0, choice))
	_send_raw(280, body.data_array)
	return true


func quest_open_ui(ui: int) -> bool:
	if not _crystal_ready() or ui < 1 or ui > 255:
		return false
	_send_raw(281, PackedByteArray([ui]))
	return true



func rand_quest_switch(quest: int) -> bool:
	if not _crystal_ready() or quest <= 0:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(quest)
	_send_raw(285, body.data_array)
	return true


func stage_reap(stage: int, show: bool = true) -> bool:
	if not _crystal_ready() or stage <= 0:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(stage)
	body.put_u8(1 if show else 0)
	_send_raw(74, body.data_array)
	return true




func roulette_spin(kind: int, ten: bool) -> bool:
	if not _crystal_ready() or not kind in [1, 3]:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(kind)
	body.put_u8(1 if ten else 0)
	_send_raw(161, body.data_array)
	return true


func roulette_list(kind: int) -> bool:
	if not _crystal_ready() or not kind in [1, 3]:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(kind)
	_send_raw(554, body.data_array)
	return true




func _luck_raw(type: int, frame: PackedByteArray) -> bool:
	var body: int = frame.size() - 8
	match type:
		4223:
			if body >= 6:
				if frame.decode_u32(8) == 13:
					luck_lines.emit(_luck_rows(frame, 12))
			elif body >= 4:
				luck_fund.emit(int(frame.decode_u32(8)))
			return true
		1515:
			if body >= 6 and frame.decode_u32(8) == 13:
				luck_lines.emit(_luck_rows(frame, 12))
				return true
			return false
		4250:
			if body > 0:
				luck_slots.emit(frame.slice(8))
			return true
		4251:
			if body >= 2:
				var count: int = frame.decode_u16(8)
				if count <= 128 and body == 2 + count:
					luck_time.emit(frame.slice(10, 10 + count).get_string_from_utf8())
			return true
	return false


static func _luck_rows(frame: PackedByteArray, at: int) -> Array:
	var rows: Array = []
	if frame.size() < at + 2:
		return rows
	var count: int = frame.decode_u16(at)
	var cursor: int = at + 2
	for i: int in count:
		if frame.size() - cursor < 6:
			break
		var length: int = frame.decode_u16(cursor + 4)
		cursor += 6
		if frame.size() - cursor < length + 8:
			break
		var name: String = frame.slice(cursor, cursor + length).get_string_from_utf8()
		cursor += length + 4
		rows.append([name, int(frame.decode_u32(cursor))])
		cursor += 4
	return rows


func bonfire_open() -> bool:
	if not _crystal_ready():
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(FNUT_BONFIRE)
	_send_raw(354, body.data_array)
	_bonfire_subscribed = true
	return true

func bonfire_close() -> bool:
	if _role != "gate" or _phase != "world" or not _bonfire_subscribed:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(FNUT_BONFIRE)
	_send_raw(355, body.data_array)
	_bonfire_subscribed = false
	return true

func _receive_bonfire(type: int, body: PackedByteArray) -> void :
	match type:
		4235:
			if body.size() < 12:
				return
			bonfire_count = int(body.decode_u32(0))
			bonfire_add = int(body.decode_u32(4))
			bonfire_param = int(body.decode_s32(8))
		4238:
			if body.size() < 4:
				return
			bonfire_completed = int(body.decode_u32(0))
		1114:
			if body.is_empty():
				bonfire_tossed.emit()
			return
		_:
			return
	bonfire_rev += 1
	changed.emit()


func luck_ui(open: bool) -> bool:
	if not _crystal_ready():
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(4)
	_send_raw(354 if open else 355, body.data_array)
	return true


func luck_list() -> bool:
	if not _crystal_ready():
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(13)
	_send_raw(554, body.data_array)
	return true


func luck_spin(ten: bool) -> bool:
	if not _crystal_ready():
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(13)
	body.put_u8(1 if ten else 0)
	_send_raw(161, body.data_array)
	return true



func convert_item(convert: int, count: int) -> bool:
	if not _crystal_ready() or convert <= 0 or count < 1 or count > 9999:
		return false
	_send("ItemMessage.RequestConvertItem", {"m_convertVec": [{"m_nConvertId": convert, "m_nConvertCnt": count}], "m_coinVec": []})
	return true



func convert_items(infos: Array, coins: Array) -> bool:
	if not _crystal_ready() or infos.is_empty() or infos.size() > 64 or coins.size() > 4:
		return false
	var vec: Array = []
	for info: Variant in infos:
		if not (info is Array) or info.size() < 2 or int(info[0]) <= 0 or int(info[1]) < 1 or int(info[1]) > 9999:
			return false
		vec.append({"m_nConvertId": int(info[0]), "m_nConvertCnt": int(info[1])})
	var pay: Array = []
	for coin: Variant in coins:
		if not (coin is Array) or coin.size() < 2 or int(coin[0]) < 0 or int(coin[1]) < 0:
			return false
		pay.append({"m_coinType": int(coin[0]), "m_value": int(coin[1])})
	_send("ItemMessage.RequestConvertItem", {"m_convertVec": vec, "m_coinVec": pay})
	return true


func draw_award(award: int, code: String = "") -> bool:
	if not _crystal_ready() or award <= 0 or code.length() > 64:
		return false
	_send("AwardMessage.RequestDrawAward", {"m_awardId": award, "m_validate": code})
	return true

func _receive_crystal(type: int, body: PackedByteArray) -> void :
	match type:
		1454:

			var out: Dictionary = {}
			var count: int = int(body.decode_u16(0)) if body.size() >= 2 else 0
			for i in range(count):
				var at: int = 2 + i * 124
				if at + 124 > body.size():
					break
				var slots: Array = []
				for k in range(30):
					slots.append(int(body.decode_u32(at + 4 + k * 4)))
				out[int(body.decode_u32(at))] = slots
			crystal_schemes = out
			crystal_loaded = true
		1455:

			var names: Dictionary = {}
			var count: int = int(body.decode_u16(0)) if body.size() >= 2 else 0
			var at: int = 2
			for i in range(count):
				if at + 6 > body.size():
					break
				var size: int = int(body.decode_u16(at + 4))
				if at + 6 + size > body.size():
					break
				names[int(body.decode_u32(at))] = body.slice(at + 6, at + 6 + size).get_string_from_utf8()
				at += 6 + size
			crystal_names = names
		1457:
			crystal_result.emit("rename", body.size() >= 1 and body[0] == 0)
			return
		1459:
			crystal_result.emit("forge", body.size() >= 1 and body[0] == 0)
			return
		1461:
			crystal_free_at = int(body.decode_u32(0)) if body.size() >= 4 else 0
		_:
			return
	crystal_rev += 1
	changed.emit()
	if type == 1454:
		crystal_result.emit("schemes", true)
	elif type == 1461:
		crystal_result.emit("make", true)




func _receive_challenge(type: int, body: PackedByteArray) -> void :
	var input: StreamPeerBuffer = StreamPeerBuffer.new()
	input.big_endian = false
	input.data_array = body
	match type:
		1413:
			if body.size() < 40:
				return
			for key: String in ["count", "buy", "buy_limit", "seq_win", "win", "lose", "cool", "rank", "today_seq", "atk"]:
				challenge[key] = int(input.get_u32())
			challenge_loaded = true
		1414:
			if body.size() < 7:
				return
			var info: Dictionary = {"win": input.get_u8() == 1, "silver": int(input.get_u32()), "items": []}
			for i in range(int(input.get_u16())):
				if input.get_available_bytes() < 8:
					break
				info["items"].append([int(input.get_u32()), int(input.get_u32())])
			challenge_result.emit(info)
			return
		1415:
			var rows: Array = []
			var count: int = int(input.get_u16()) if body.size() >= 2 else 0
			for i in range(count):
				var enemy: Variant = _challenge_utf(input)
				if enemy == null or input.get_available_bytes() < 12:
					break
				rows.append({"enemy": enemy, "result": int(input.get_u32()), "rank": int(input.get_u32()), "time": int(input.get_u32())})
			challenge["history"] = rows
		1416:
			if body.size() < 33:
				return
			var has: int = input.get_u8()
			var rank: int = int(input.get_u32())
			challenge["yesterday"] = {"has": has == 1, "rank": rank, "award": _challenge_award(input)}
		1417:
			if body.size() < 28:
				return
			challenge["now"] = _challenge_award(input)
		1838:
			var cards: Array = []
			var count: int = int(input.get_u16()) if body.size() >= 2 else 0
			for i in range(count):
				if input.get_available_bytes() < 4:
					break
				var oid: int = int(input.get_u32())
				var uuid: Variant = _challenge_utf(input)
				var name: Variant = _challenge_utf(input) if uuid != null else null
				if name == null or input.get_available_bytes() < 60:
					break
				var card: Dictionary = {"oid": oid, "uuid": uuid, "name": name}
				for key: String in ["avatar", "item", "level", "up_level", "grade", "up_cost", "grade_cost", "tank_level", "tank_id", 
						"external", "seq_win", "win", "lose", "rank", "atk"]:
					card[key] = int(input.get_u32())
				cards.append(card)
			challenge["enemies"] = cards
	challenge_rev += 1
	changed.emit()


static func _challenge_utf(input: StreamPeerBuffer) -> Variant:
	if input.get_available_bytes() < 2:
		return null
	var size: int = int(input.get_u16())
	if input.get_available_bytes() < size:
		return null
	return input.get_utf8_string(size) if size > 0 else ""


static func _challenge_award(input: StreamPeerBuffer) -> Array:
	var award: Array = []
	for i in range(7):
		award.append(int(input.get_u32()) if input.get_available_bytes() >= 4 else 0)
	return award

func _crystal_ready() -> bool:
	return _role == "gate" and _phase == "world" and state in ["lobby", "hall", "room"]



func master_send(type: int, body: PackedByteArray) -> bool:
	if not _crystal_ready() or type not in MASTER_SEND or (6 + body.size()) % 8 != 0:
		return false
	if type == 712 and (body.size() < 4 or body.decode_u32(0) != MasterModel.CSOT_TRAINEE):
		return false
	_send_raw(type, body)
	return true


func crystal_request() -> bool:
	if not _crystal_ready():
		return false
	_send_raw(423, PackedByteArray())
	return true



func crystal_save(scheme: int, slots: Array) -> bool:
	if not _crystal_ready() or scheme < 1 or scheme > 5 or slots.size() != 30:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(scheme)
	for item: int in slots:
		body.put_u32(maxi(0, item))
	_send_raw(424, body.data_array)
	return true


func crystal_rename(scheme: int, name: String) -> bool:
	var text: PackedByteArray = name.to_utf8_buffer()
	if not _crystal_ready() or not crystal_schemes.has(scheme) or text.size() > 32:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(scheme)
	body.put_u16(text.size())
	body.put_data(text)
	_send_raw(425, body.data_array)
	return true




func crystal_forge(sell: bool, items: Array) -> bool:
	if not _crystal_ready() or items.is_empty() or items.size() > 64:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(1 if sell else 0)
	body.put_u16(items.size())
	for item: int in items:
		body.put_u32(item)
	_send_raw(426, body.data_array)
	return true



func crystal_make(kind: int) -> bool:
	if not _crystal_ready() or not kind in [2, 3, 4, 5, 6]:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(kind)
	_send_raw(430, body.data_array)
	return true


func challenge_open() -> bool:
	if not _crystal_ready():
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(1)
	_send_raw(356, body.data_array)
	return true


func challenge_award() -> bool:
	if not _crystal_ready():
		return false
	_send_raw(357, PackedByteArray())
	return true


func challenge_fight(rank: int, uuid: String, self_rank: int) -> bool:
	var text: PackedByteArray = uuid.to_utf8_buffer()
	if not _crystal_ready() or rank <= 0 or text.is_empty() or text.size() > 128:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(rank)
	body.put_u16(text.size())
	body.put_data(text)
	body.put_u32(maxi(0, self_rank))
	_send_raw(359, body.data_array)
	return true


func challenge_buy() -> bool:
	if not _crystal_ready():
		return false
	_send_raw(574, PackedByteArray())
	return true




func _helper_ready(slot: int) -> bool:
	return _bag_ready(5, slot) and slot >= 0


func helper_plant(slot: int, exp_slot: int = -1) -> bool:
	if not _helper_ready(slot):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_16(slot)
	body.put_32(exp_slot)
	_send_raw(156, body.data_array)
	return true


func helper_strengthen(slot: int) -> bool:
	if not _helper_ready(slot):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_16(slot)
	_send_raw(157, body.data_array)
	return true


func helper_compose(slot: int, mats: Array) -> bool:
	if not _helper_ready(slot):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_16(slot)
	body.put_u16(mats.size())
	for mat: int in mats:
		body.put_16(mat)
	_send_raw(158, body.data_array)
	return true


func helper_trans(slot_a: int, slot_b: int) -> bool:
	if not (_helper_ready(slot_a) and _helper_ready(slot_b)) or slot_a == slot_b:
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_16(slot_a)
	body.put_16(slot_b)
	_send_raw(159, body.data_array)
	return true


func helper_split(slots: Array) -> bool:
	if slots.is_empty() or not _bag_ready(5, -1):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(5)
	body.put_u16(slots.size())
	for slot: int in slots:
		body.put_16(slot)
	_send_raw(162, body.data_array)
	return true


func helper_battle(uuid: String) -> bool:
	if uuid.is_empty() or not _bag_ready(5, -1):
		return false
	var text: PackedByteArray = uuid.to_utf8_buffer()
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u16(text.size())
	body.put_data(text)
	_send_raw(166, body.data_array)
	return true


func spend_golden(amount: int) -> void :
	if amount > 0:
		currency["m_iGolden"] = maxi(0, int(currency.get("m_iGolden", 0)) - amount)
		changed.emit()


func expand_bag() -> bool:
	if not _bag_ready(2, -1):
		return false
	_send("ItemMessage.RequestExpandContainer", {"m_nType": 2})
	return true



func use_spray(id: int) -> bool:
	if id <= 0 or not _bag_ready(2, -1):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u32(id)
	_send_raw(73, body.data_array)
	return true


func wear_honors(ids: Array) -> bool:
	if not _bag_ready(0, -1):
		return false
	var slots: Array = [0, 0, 0, 0]
	for i: int in mini(4, ids.size()):
		slots[i] = int(ids[i])
	_send("CharMessage.RequestChangeHonor", {"m_nHonorId": slots[0], "m_nHonorId2": slots[1], "m_nHonorId3": slots[2], "m_nHonorId4": slots[3]})
	return true


func current_tank() -> Dictionary:
	for tank: Dictionary in tanks.values():
		if int(tank.get("m_extFlag", 0)) == 2:
			return tank
	return {} if tanks.is_empty() else tanks.values()[0]

func choose_character(index: int) -> void :
	if state != "characters" or index < 0 or index >= characters.size():
		return
	character = characters[index]["m_basic"].duplicate()
	_pending_character = str(characters[index]["m_charUuid"])



func _create_reply(type: int, frame: PackedByteArray) -> void :
	if type == 1011:
		characters = []
		creating = true
		_create_sent = false
		state = "characters"
		status = "Tối đa %d ký tự" % CHAR_NAME_LIMIT
	elif type == 1012:
		creating = false
		_create_sent = false
		state = "connecting"
		_deadline = 0.0
		status = "Đang vào sảnh…"
	else:
		_create_sent = false
		var reason: int = int(frame.decode_u32(8)) if frame.size() >= 12 else 0
		status = str(CREATE_FAIL.get(reason, "Tạo nhân vật chưa xử lý thất bại:%d" % reason))
	changed.emit()



func create_character(typed: String, sex: int) -> bool:
	if not creating or _create_sent or _role != "gate" or typed.is_empty() or not (sex in [1, 2]):
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_32(sex)
	for text: String in [typed, "", ""]:
		var bytes: PackedByteArray = text.to_utf8_buffer()
		body.put_u16(bytes.size())
		body.put_data(bytes)
	_send_raw(64, body.data_array)
	_create_sent = true
	status = "Đang yêu cầu tạo nhân vật..."
	changed.emit()
	return true

func _ignore_packet(type: int) -> void :
	if not ignored_layouts.has(type):
		ignored_layouts[type] = true

		print("Ignoring unused/unsupported packet type ", type)
		if unknown_ids.size() < 32:
			unknown_ids.append(type)

func _needs_packet(type: int) -> bool:
	if type in [902, 904, 909, 1006]:
		return true
	if state == "connecting" or state == "characters":
		return type in [901, 906, 1005, 1014, 1016]
	if state in ["lobby", "hall", "room", "battle"]:
		if type in [1700, 1701, 1702, 1704, 1705, 1707, 1708, 1724, 1727]:
			return true
		if state != "battle" and type in [1720, 1721, 1722, 1728]:
			return true
		if state == "battle" and battle.supported():
			return type in [1550, 1551, 1552, 1553, 1554, 1555, 1556, 1560, 1564, 1566, 1572, 1586, 1603, 1605]
	return false

func _handle_play_packet(type: int, value: Dictionary) -> bool:
	if type == 1019:

		if int(value.get("m_nChar", 0)) == account_oid:
			if int(value.get("m_type", 0)) == 1:
				character["level"] = int(value.get("m_nLevel", 0))
				level_up.emit(int(character["level"]))
			elif int(value.get("m_type", 0)) == 2:
				character["milLevel"] = int(value.get("m_nLevel", 0))
			changed.emit()
		return true
	if type == 1020:

		if int(value.get("m_type", 0)) == 1:
			character["exp"] = int(value.get("m_nExp", 0))
			changed.emit()
		return true
	if type == 1836:

		league_url = str(value.get("m_websvc", ""))
		league_rev += 1
		changed.emit()
		return true
	if type == 1834:

		var code: int = int(value.get("m_result", -1))
		if code >= 0 and code < LEAGUE_TIPS.size():
			noticed.emit(str(LEAGUE_TIPS[code]))
		league_enroll_code = code
		league_enroll_n += 1
		changed.emit()
		return true
	if type == 1835:

		league_award_result.emit(int(value.get("m_result", -1)), int(value.get("m_awardId", 0)))
		return true
	if type == 1821:

		if int(value.get("m_roomType", 0)) != TEAM_ROOM:
			return false
		_receive_team_match(value)
		changed.emit()
		return true
	if type == 1721 and state in ["lobby", "hall", "room"]:
		var mates: Dictionary = _pair_mates()
		_pair_reset()
		_pair_start(value)
		pair_scene["mates"] = mates
		changed.emit()
		return true
	if type == 1722 and state in ["lobby", "hall", "room"]:

		if _pair_turn(value):
			changed.emit()
		return true
	if type == 1715:
		_receive_invite(value)
		return true
	if type == 1716:

		_receive_char_state(value)
		return true
	if type == 1720:

		pair_scene.clear()
		changed.emit()
		return true
	if type == 1711:

		_room_char_change(value)
		changed.emit()
		return true
	if type in [1700, 1701, 1702] and _room_observer(type, value):

		changed.emit()
		return true
	if type in [1700, 1701, 1702, 1703, 1704, 1706, 1724, 1727, 1728]:
		var pve_was: bool = type == 1701 and pve_room()
		var ladder_was: bool = type == 1701 and ladder_room()
		var pair_was: bool = type == 1701 and pair_room()
		var pve_map: int = int(room_state.room.get("roomConfig", {}).get("m_nMapId", 0))
		room_state.self_id = account_oid
		_room_note(type, value)
		if type == 1701 and int(value.get("m_roomOp", 0)) == ROPT_KICKOUT and int(value.get("m_nTarget", 0)) == account_oid and not room_state.room.is_empty():
			var kicker: String = str(room_state.members.get(int(value.get("m_nStartOid", 0)), {}).get("data", {}).get("charData", {}).get("szName", ""))
			if kicker.is_empty():
				kicker = str(room_observers.get(int(value.get("m_nStartOid", 0)), {}).get("charData", {}).get("szName", ""))
			noticed.emit(KICKED_TIP.replace("@name@", kicker))
		if type == 1701 and int(value.get("m_roomOp", 0)) == ROPT_PASSWORD:
			noticed.emit("Máy chủ chưa hỗ trợ đặt mật mã phòng.")
		if type == 1701 and int(value.get("m_roomOp", 0)) in [ROPT_CLOSE, ROPT_OPEN] and int(value.get("m_nTarget", 0)) == 0:
			noticed.emit("Máy chủ chưa hỗ trợ %s." % ("đóng ghế" if int(value.m_roomOp) == ROPT_CLOSE else "mở ghế"))
		var hold: bool = pair_was and int(value.get("m_roomOp", 0)) == 1 and _room_hold_snap(value)
		room_state.receive(type, value)
		if pair_was and room_state.room.is_empty():
			_pair_left_at = Time.get_ticks_msec()
		if hold and room_state.room.is_empty():
			_room_hold_start(ladder_was)
		if type == 1700:
			room_hold.clear()
			_held_mates = {}
		if type == 1700:
			_pair_left_at = -100000
			if int(value.get("m_bType", 0)) in [PVP_ROOM, LADDER_ROOM] and not pair_confirm.is_empty():

				pairing.clear()
				_pair_close()
				_quick_end()
		if not pair_scene.is_empty() and type in [1727, 1728]:
			_pair_pick(type, value)
		if type == 1700:
			state = "room"
			status = "Phòng " + str(value.m_nRoomId) + " · " + str(value.m_szName)

			hall_type = TEAM_ROOM if int(value.get("m_bType", 0)) == TEAM_ROOM else 2
			if hall_type != TEAM_ROOM:
				_team_disarm()
		elif pve_was and room_state.room.is_empty():
			state = "lobby"
			status = "Đã về Sảnh PHỤ BẢN."
			pve_return = maxi(1, pve_map)
		elif ladder_was and room_state.room.is_empty():


			state = "hall"
			status = "Đấu Trường · Đấu Xếp Hạng"
			ladder_return = true
		elif type == 1701 and room_state.room.is_empty():


			if not battle.active:
				_team_disarm()
				state = "hall"
				status = "Đấu Trường · So Tài"
				refresh_rooms()
		elif type == 1701 and int(value.m_roomOp) in [103, 104] and (int(value.m_nTarget) == account_oid or int(value.m_roomOp) == 104):
			state = "room"
			pair_scene.clear()
			battle.active = false
			map_fetch = false
			status = "Đã về phòng."
		if type == 1727 and battle.active:
			battle.appearances = room_state.appearances.duplicate(true)
		changed.emit()
		return true
	if type == 1705:
		pair_scene.clear()
		_pair_reset()
		_load_acked = false
		_load_resent = 0
		_exit_held = false
		_exit_main = false
		for brief: Dictionary in value.m_charData:
			room_state.brief(brief)
		map_fetch = false
		_load_pending = false
		_bcm1_tries = 0
		_bcm1_at = -100000
		battle.bundled_map4 = not bool(can_fetch_map.call(4))
		battle.begin(value, account_oid, room_state.appearances)
		if battle.look:
			battle.look_setup(_look_oid)
		state = "battle"
		map_fetch = not battle.supported() and bool(can_fetch_map.call(battle.map_id))
		status = "Đang tải bản đồ…" if battle.supported() or map_fetch else "Bản đồ chưa chuyển đổi"
		_send("RoomMessage.SyncLoadAndDelay", {"m_nSceneId": battle.scene_id, "m_nTankId": account_oid, "m_nDelay": 0, "m_nLoaded": 0})
		if latency_ms < 0 and _ping_sent == 0:
			_ping = config.ping_seconds
		_load_reported = 0

		_load_pending = not battle.supported() and not map_fetch
		changed.emit()
		return true
	if type == 1744:


		if battle.active:
			battle.tank_ranks[int(value.get("m_nOid", 0))] = int(value.get("m_nRank", 0))
		return true
	if type == 1709:


		if int(value.m_nTankId) == account_oid:
			return true
		if battle.active and not battle.started:
			battle.load_rates[int(value.m_nTankId)] = {"loaded": int(value.m_nLoaded), "delay": int(value.m_nDelay)}
		elif battle.active and loading_held:
			battle.load_rates[int(value.m_nTankId)] = {"loaded": int(value.m_nLoaded), "delay": int(value.m_nDelay)}
		return true
	if type == 1743:


		if battle.active:
			for prof_info: Variant in value.get("infoVec", []):
				if prof_info is Dictionary:
					var prof_val: int = int(prof_info.get("m_proficiencyVal", 0))
					battle.tank_prof[int(prof_info.get("m_charId", 0))] = -1 if prof_val < 0 or prof_val > 2147483647 else prof_val
		return true
	if type == 1707:
		if int(value.m_nCharId) == account_oid:
			if int(value.m_nErrId) != 0:
				_exit_main = false
				status = "Chưa rời trận được (mã " + str(value.m_nErrId) + ")."
			elif pve_result_board():


				_exit_held = true
			elif solo_battle() and battle.ended:


				_exit_held = true
			else:


				var main_hall: bool = solo_battle() or _exit_main
				if _exit_main:
					room_state.room.clear()
					room_state.members.clear()
				_exit_main = false
				battle.active = false
				map_fetch = false
				state = "lobby" if main_hall else ("room" if not room_state.room.is_empty() else "hall")
				status = "Đã về sảnh." if main_hall else "Đã về phòng."
				if guild_tip_due:

					guild_tip_due = false
					noticed.emit(GUILD_APPLY_TIP)
				if battle.look and not main_hall and room_state.room.is_empty():


					noticed.emit(LOOK_EXIT)

			world_boss_return = int(value.m_nErrId) == 0 and battle.map_id == 40002 and int(world_boss.get("hp", 0)) > 0

			guild_boss_return = int(value.m_nErrId) == 0 and int(battle.room_type) == 14 and state == "lobby"

			act_return = int(value.m_nErrId) == 0 and int(battle.room_type) in EVENT_ROOMS.values() and state == "hall"
			if act_return:
				hall_room = int(battle.room_type)


			var pair_again_reply: bool = Time.get_ticks_msec() - _pair_again_at < PAIR_AGAIN_WINDOW
			_pair_again_at = -100000
			if act_return and pair_again_reply:
				var pair_again_now: int = Time.get_ticks_msec()
				quick_pair = true
				_quick_sent_at = pair_again_now
				_quick_wait_until = pair_again_now + 10000
				_quick_armed = true
				_hall_poll = 0
				_quick_type = int(battle.room_type)

			ladder_return = int(value.m_nErrId) == 0 and int(battle.room_type) == LADDER_ROOM and state == "hall"
			changed.emit()
		return true
	if type == 1729:
		status = "Phòng này cần mật khẩu bằng số. Nhập mật khẩu rồi vào lại."
		_room_action = 0
		noticed.emit("Phòng này có mật mã.")

		room_password_asked.emit(int(value.get("m_nRoomId", 0)), int(value.get("m_nRoomType", 0)))
		changed.emit()
		return true
	if type == 450 or type == 3502:

		if type == 450 and is_black(str(value.get("m_contents", {}).get("senderUuid", ""))):
			return true
		if type == 3502 and _renaming and str(value.get("m_szContent", "")).begins_with(RENAME_DONE):
			_renaming = false
			character["name"] = str(value.get("m_szContent", "")).trim_prefix(RENAME_DONE)
			changed.emit()


		if type == 3502 and int(value.get("m_nPos", 0)) & 64 and state in ["lobby", "hall", "room", "battle"]:
			var box: String = BattleState.chat_text(str(value.get("m_szContent", "")))
			if not box.is_empty():
				message_box.emit(box)
		if type == 450 and int(value.get("m_contents", {}).get("channel", 0)) == CHAT_GLOBAL and not str(value.get("m_contents", {}).get("content", "")).is_empty():
			global_horn_heard.emit(str(value.get("m_contents", {}).get("content", "")))

		if type == 3502 and int(value.get("m_nPlayItemId", 0)) > 0 and not battle.active and state != "battle":
			gift_used.emit({"m_nItemId": int(value.get("m_nPlayItemId", 0)), "bulletin": true})
		if battle.active:
			if type == 450:
				battle.receive_chat(value)
			else:
				battle.receive_bulletin(value)
		elif type == 450:
			_receive_chat(value)
		elif state in ["lobby", "hall", "room"]:

			var tip: String = BattleState.chat_text(str(value.get("m_szContent", "")))
			var pos: int = int(value.get("m_nPos", 0))
			if not tip.is_empty() and pos & 1:
				var tint: String = str(value.get("m_szColor", "")).trim_prefix("#")
				chat_note(tip, Color("#" + tint) if tint.is_valid_html_color() else Color("ffd700"))
			if not tip.is_empty() and pos & 2:
				noticed.emit(tip)

			if not tip.is_empty() and pos & 4:
				bulletin_rolled.emit(tip)
		return true
	if battle.active and ((type >= 1550 and type <= 1710) or (type >= 1731 and type <= 1736)):
		_mirror.receive(battle, type, value)
		if type == 1573 or type == 1574 or type == 1566:
			happy_packet.emit(type, value)
		if type == 1553 and int(value.get("m_acctOid", 0)) == battle.self_id and not buy_life.is_empty():
			buy_life = {}
			buy_life_rev += 1
		battle.receive(type, value)
		if type in [1550, 1586, 1708]:
			status = "Trận đấu đã kết thúc" if battle.ended else ("Đang trong trận" if battle.supported() else "Bản đồ chưa chuyển đổi")
			changed.emit()
		return true
	return false






var _attention: Dictionary = {}
var _attention_loaded: = false

func _receive_friends(type: int, value: Dictionary) -> bool:
	match type:
		1508, 10005:
			friends.clear()
			for brief: Dictionary in value.get("m_briefVec" if type == 1508 else "m_vecFriend", []):
				var buuid: String = str(brief.get("m_charUuid", ""))
				if type == 1508 and blacks.has(buuid):
					blacks[buuid] = brief

				if type == 1508 and _attention_loaded and not _attention.has(buuid):
					continue
				friends[buuid] = brief
			friends_loaded = true
		1900:
			var keep: Dictionary = {}
			for info: Dictionary in value.get("m_attentionVec", []):
				keep[str(info.get("m_friendUuid", ""))] = true
			_attention = keep
			_attention_loaded = true
			var black: Dictionary = {}
			for buuid: String in value.get("m_blackVec", []):
				black[buuid] = blacks.get(buuid, {})
			blacks = black
			for uuid: String in friends.keys():
				if not keep.has(uuid):
					friends.erase(uuid)
		10001:
			for brief: Dictionary in value.get("m_vecFriends", []):
				friends[str(brief.get("m_charUuid", ""))] = brief
			friends_loaded = true
		1509, 10006:
			for brief: Dictionary in ([value.get("m_data", {})] if type == 1509 else value.get("m_vecData", [])):
				var uuid: String = str(brief.get("m_charUuid", ""))
				if friends.has(uuid):
					friends[uuid] = brief
				if blacks.has(uuid):
					blacks[uuid] = brief
		1902:

			var flag: int = int(value.get("m_type", 0))
			var uuid: String = str(value.get("m_charUuid", ""))
			if flag & RELATION_ATTENTION:
				friends.erase(uuid)
				_attention.erase(uuid)
			elif flag & RELATION_BLACK:
				blacks.erase(uuid)
		1903:

			var flag: int = int(value.get("m_type", 0))
			var brief: Dictionary = value.get("m_info", {})
			var uuid: String = str(brief.get("m_charUuid", ""))
			if uuid.is_empty():
				return false
			if flag & RELATION_ATTENTION:
				_attention[uuid] = true
				if not blacks.erase(uuid):
					return false
			elif flag & RELATION_BLACK:
				friends.erase(uuid)
				_attention.erase(uuid)
				blacks[uuid] = brief
			else:
				return false
		10002:
			friend_applies = value.get("m_applyList", []).duplicate()
			friend_apply_count = friend_applies.size()
		10003:
			friend_apply_count = int(value.get("m_applyCount", 0))
		10004:
			var code: int = int(value.get("m_result", 0))
			_friend_pending = ""
			friend_result.emit(code == 1, str(FRIEND_RESULTS.get(code, "Không kết bạn được (mã %d)" % code)))
		1703:
			if int(value.get("m_listType", 0)) != QUICK_ADD_LIST:
				return false
			friend_suggestions = value.get("m_playerList", [])
		_:
			return false
	return true




func _receive_guild(type: int, value: Dictionary) -> bool:
	match type:
		1800:
			guild = value.get("m_info", {})
			guild_teams = value.get("m_teamVec", []).duplicate()
			guild_self_team = int(value.get("m_selfTeamId", 0))
			var keep: Dictionary = {}
			for team: Dictionary in guild_teams:
				keep[int(team.get("nTeamId", 0))] = true
			for uuid: String in guild_members.keys():
				if not keep.has(int(guild_members[uuid].get("nTeamId", 0))):
					guild_members.erase(uuid)
		1831:
			var team_id: int = int(value.get("m_nTeamId", 0))
			for uuid: String in guild_members.keys():
				if int(guild_members[uuid].get("nTeamId", 0)) == team_id:
					guild_members.erase(uuid)
			for member: Dictionary in value.get("m_memberVec", []):
				guild_members[str(member.get("charUuid", ""))] = member
		1828:
			guild = value.get("m_info", {})
		1829, 1805:
			var member: Dictionary = value.get("m_info" if type == 1829 else "m_newMember", {})
			if not str(member.get("charUuid", "")).is_empty():
				guild_members[str(member.charUuid)] = member
		1814, 1826:
			var info: Dictionary = value.get("m_info", {})
			var found: bool = false
			for index: int in guild_teams.size():
				if int(guild_teams[index].get("nTeamId", 0)) == int(info.get("nTeamId", -1)):
					guild_teams[index] = info
					found = true
			if not found and not info.is_empty():
				guild_teams.append(info)
		1827:
			var gone: int = int(value.get("m_nTeamId", 0))
			guild_teams = guild_teams.filter( func(team: Dictionary) -> bool: return int(team.get("nTeamId", 0)) != gone)
		1830:

			guild_team_invite = {"starter": str(value.get("m_szStarter", "")), "uuid": str(value.get("m_charUuid", "")), 
				"team": int(value.get("m_nTeamId", 0)), "team_name": str(value.get("m_nTeamName", ""))}
			guild_team_invite_rev += 1
		1032:

			guild_gift_time = int(value.get("m_nTime", 0))
		1816:

			guild_applies = value.get("m_charVec", []).duplicate()
			guild_inviters = {}
			for invite: Dictionary in value.get("m_inviteVec", []):
				guild_inviters[int(invite.get("nAcctId", 0))] = str(invite.get("szInviteName", ""))
			guild_req_join = guild_applies.size()
			guild_rev += 1
		1824:

			guild_req_join = maxi(0, int(value.get("m_count", 0)))
			noticed.emit(GUILD_APPLY_LOGIN.replace("@num1@", str(guild_req_join)))
			chat_note(GUILD_APPLY_LOGIN.replace("@num1@", str(guild_req_join)))
			guild_rev += 1
		1509:
			var brief: Dictionary = value.get("m_data", {})
			if guild_members.has(str(brief.get("m_charUuid", ""))):
				guild_briefs[str(brief.m_charUuid)] = brief
				guild_rev += 1
			return false
		_:
			return false
	return true


func guild_self_uuid() -> String:
	for uuid: String in guild_members:
		if int(guild_members[uuid].get("nAcctId", 0)) == account_id:
			return uuid
	return ""

func _clear_guild() -> void :
	guild = {}
	guild_teams = []
	guild_members.clear()
	guild_briefs.clear()
	guild_self_team = 0
	guild_channel = ""
	guild_skill_slots = {}
	guild_skill_flag = 0
	guild_skill_self = {}
	guild_skill_corps = {}
	guild_applies = []
	guild_inviters = {}
	guild_req_join = 0
	guild_tip_due = false
	guild_rev += 1




func _receive_guild_skill(type: int, body: PackedByteArray) -> bool:
	var wide: int = 12 if type == 1350 else 8
	if body.size() < 2 or 2 + int(body.decode_u16(0)) * wide > body.size():
		return false
	var count: int = int(body.decode_u16(0))
	var rows: Array = []
	var at: int = 2
	for i in range(count):
		rows.append([int(body.decode_u32(at)), int(body.decode_u32(at + 4)), int(body.decode_u32(at + 8)) if wide == 12 else 0])
		at += wide
	if type == 1350:
		guild_skill_slots = {}
		for row: Array in rows:
			guild_skill_slots[int(row[0])] = [int(row[1]), int(row[2])]
		guild_skill_flag = int(body.decode_u32(at)) if at + 4 <= body.size() else 0
	else:
		var reset: bool = at + 4 > body.size() or int(body.decode_u32(at)) == 1
		var table: Dictionary = {} if reset else (guild_skill_self if type == 1351 else guild_skill_corps).duplicate()
		for row: Array in rows:
			table[int(row[0])] = int(row[1])
		if type == 1351:
			guild_skill_self = table
		else:
			guild_skill_corps = table
	guild_rev += 1
	return true



func world_boss_open() -> bool:
	if _phase != "world":
		return false
	_send("ActivityMessage.OpenBossActUI", {})
	return true

func world_boss_close() -> bool:
	if _phase != "world":
		return false
	_send("ActivityMessage.CloseBossActUI", {})
	return true

func world_boss_join() -> bool:
	if _phase != "world" or state not in ["lobby", "hall"]:
		return false
	_send("ActivityMessage.ActivityEnterBoss", {"m_iResetCD": 0})
	return true



func pve_info() -> bool:
	if _phase != "world" or state not in ["lobby", "hall"]:
		return false
	_send("ChapterMessage.RequestSoloPveInfoMessage", {})
	return true



func pve_hall(site: int) -> bool:
	if _phase != "world" or state != "lobby":
		return false
	_send("RoomMessage.RequestInHall", {"m_bType": 4, "m_iSite": site})
	return true


func pve_out_hall() -> bool:
	if _phase != "world" or state != "lobby":
		return false
	_send("RoomMessage.RequestOutHall", {})
	return true


func pve_hall_kind(kind: int, site: int) -> bool:
	if _phase != "world" or state != "lobby" or kind not in [3, 4]:
		return false
	_send("RoomMessage.RequestInHall", {"m_bType": kind, "m_iSite": site})
	return true


func pve_room() -> bool:
	return state == "room" and int(room_state.room.get("m_bType", 0)) in [3, 4, 8]

func _pve_room_free() -> bool:
	return _phase == "world" and state == "lobby" and not battle.active and room_state.room.is_empty() and _room_action <= 0


func pve_create(map: int, kind: int = 4) -> bool:
	if map <= 0 or not _pve_room_free():
		return false
	_room_action = 1
	_send("RoomMessage.RequestCreateRoom", {"m_bType": kind, "m_bMode": 0, "m_mapId": map, "m_passWord": 0, "m_szName": "", "m_nItemId": 0})
	return true



func pve_join(id: int, map: int, kind: int = 4, password: int = 0) -> bool:
	if (id <= 0 and map <= 0) or not _pve_room_free():
		return false
	_room_action = 1
	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": id, "m_bType": kind, "m_bMode": 0, "m_mapId": map, "m_nPassword": password, "m_nContestId": 0})
	return true


func pve_room_op(op: int) -> bool:
	if not pve_room() or op not in [1, 2, 3, 24] or _room_action > 0:
		return false
	room_op(op, 4294967295)
	return true


func pve_sweep(map: int, count: int) -> bool:
	if _phase != "world" or state != "lobby" or map <= 0 or count < 1 or count > 10:
		return false
	_send("ChapterMessage.RequestSweepSoloMap", {"m_nCityId": map, "m_nCount": count})
	return true


func pve_reset_enter(map: int) -> bool:
	if _phase != "world" or map <= 0:
		return false
	_send("CharMessage.RequestRestMapEnterCount", {"m_nMapId": map})
	return true



static func parse_sweep_awards(body: PackedByteArray) -> Array:
	if body.size() < 2:
		return []
	var count: int = body.decode_u16(0)
	var at: int = 2
	var runs: Array = []
	for i in range(count):
		if body.size() < at + 18:
			return []
		var run: Dictionary = {"cash": body.decode_s32(at), "gift": body.decode_s32(at + 4), "golden": body.decode_s32(at + 8), 
			"glory": body.decode_s32(at + 12), "vecs": [], "tanks": []}
		var vecs: int = body.decode_u16(at + 16)
		at += 18
		for j in range(vecs):
			if body.size() < at + 6:
				return []
			var kind: int = int(body.decode_u32(at))
			var items: int = body.decode_u16(at + 4)
			at += 6
			if body.size() < at + items * 8:
				return []
			var pairs: Array = []
			for k in range(items):
				pairs.append([int(body.decode_u32(at)), body.decode_s32(at + 4)])
				at += 8
			run.vecs.append([kind, pairs])
		if body.size() < at + 2:
			return []
		var tanks: int = body.decode_u16(at)
		at += 2
		if body.size() < at + tanks * 4 + 6:
			return []
		for k in range(tanks):
			run.tanks.append(int(body.decode_u32(at)))
			at += 4
		run.exp = body.decode_s32(at)
		run.fizz = body.decode_u16(at + 4)
		at += 6
		runs.append(run)
	return runs

func _receive_pve_sweep(body: PackedByteArray) -> bool:
	var runs: Array = parse_sweep_awards(body)
	if runs.is_empty():
		return false
	pve_sweep_awards = runs
	pve_sweep_rev += 1
	return true




const PVE_RECORD_DAYS: int = 7
func pve_record(map_id: int, ask: bool = true, now: int = -1) -> Dictionary:
	var record: Dictionary = pve_records.get(map_id, {})
	if record.is_empty():
		if ask and map_id > 0 and map_id not in _pve_record_wait and _phase == "world" and _channel != null:
			_send("CharMessage.RequestPveRecord", {"m_nMapId": map_id})
			_pve_record_wait.append(map_id)
		return record
	if now < 0:
		now = int(Time.get_unix_time_from_system())
	if now - int(record.get("pass", 0)) >= PVE_RECORD_DAYS * 86400 and int(record.get("pass", 0)) != 0:
		record = {"pass": 0, "use": 0, "names": []}
		pve_records[map_id] = record
	return record




func _receive_pve(type: int, body: PackedByteArray) -> bool:
	if type == 1300:
		if body.size() < 6:
			return false
		pve_scenes[int(body.decode_u32(0))] = int(body.decode_u16(4))
		pve_rev += 1
		return true
	if type == 1516:
		if body.size() < 14:
			return false
		var names: Array = []
		var at: int = 14
		for i in range(int(body.decode_u16(12))):
			if at + 4 > body.size():
				return false
			at += 4
			for part in range(2):
				if at + 2 > body.size():
					return false
				var size: int = int(body.decode_u16(at))
				if at + 2 + size > body.size():
					return false
				if part == 1:
					names.append(body.slice(at + 2, at + 2 + size).get_string_from_utf8())
				at += 2 + size
		pve_records[int(body.decode_u32(0))] = {"pass": int(body.decode_u32(4)), "use": int(body.decode_u32(8)), "names": names}
		_pve_record_wait.erase(int(body.decode_u32(0)))
		pve_rev += 1
		return true
	if body.size() < 2:
		return false
	var count: int = int(body.decode_u16(0))
	if body.size() < 2 + count * 18:
		return false
	if type == 1303:
		pve_cities.clear()
	for i in range(count):
		var at: int = 2 + i * 18
		pve_cities[int(body.decode_u32(at))] = [int(body.decode_u32(at + 4)), int(body[at + 8]), int(body[at + 9])]
		pve_cities[int(body.decode_u32(at))].append(int(body.decode_u32(at + 10)) if body.size() >= at + 14 else 0)
		pve_cities[int(body.decode_u32(at))].append(int(body.decode_u32(at + 14)))
	pve_rev += 1
	return true


func league_enroll(session: int, team: int) -> bool:
	if _phase != "world" or state not in ["lobby", "hall"] or session <= 0 or team <= 0:
		return false
	_send("LeagueMessage.LeagueRequestEnroll", {"m_team_id": team, "m_session": session, "m_zone_id": 0})
	return true



func league_award(award_id: int) -> bool:
	if _phase != "world" or state not in ["lobby", "hall"] or award_id <= 0:
		return false
	_send("LeagueMessage.LeagueRequestAward", {"m_awardId": award_id})
	return true





func _receive_world_boss(type: int, body: PackedByteArray) -> bool:
	var head: int = 26 if type == 1952 else 14
	if body.size() < head:
		return false
	var rows: Array = []
	var at: int = head
	for i in range(int(body.decode_u16(head - 2))):
		var row: Array = []
		for part in range(2):
			if at + 2 > body.size():
				return false
			var size: int = int(body.decode_u16(at))
			if at + 2 + size > body.size():
				return false
			row.append(body.slice(at + 2, at + 2 + size).get_string_from_utf8())
			at += 2 + size
		if at + 4 > body.size():
			return false
		row.append(int(body.decode_s32(at)))
		at += 4
		rows.append(row)
	var real: int = int(body.decode_s32(at)) if at + 4 <= body.size() else -1
	var hp: int = maxi(0, int(body.decode_s32(4)))
	var lost: int = real if real >= 0 else int(world_boss.get("hp", 0)) - hp
	if int(world_boss.get("max", 0)) > 0 and lost > 0:
		world_boss["drop"] = lost
		world_boss["drop_n"] = int(world_boss.get("drop_n", 0)) + 1
	world_boss["hp"] = hp
	world_boss["max"] = maxi(0, int(body.decode_s32(8)))
	world_boss["rows"] = rows
	if type == 1952:
		world_boss["harm"] = int(body.decode_s32(12))
		world_boss["rank"] = int(body.decode_u32(16))
		world_boss["enter_at"] = int(body.decode_u32(20))
	world_boss_rev += 1
	return true


func request_guild() -> bool:
	var now: float = Time.get_ticks_msec() / 1000.0
	if _phase != "world" or now - _guild_asked < 3.0:
		return false
	_guild_asked = now
	_send("TeamMessage.RequestInGuildUI", {})
	return true



func guild_kickout(uuid: String, team: int) -> bool:
	if _phase != "world" or uuid.is_empty():
		return false
	_send("TeamMessage.RequestGuildKickout", {"m_targetUuid": uuid, "m_nTeamId": team})
	return true



func guild_leave() -> bool:
	if _phase != "world":
		return false
	_send("TeamMessage.RequestLeaveGuild", {})
	return true




func guild_set_notice(text: String) -> bool:
	if _phase != "world":
		return false
	_send("TeamMessage.RequestSetNotice", {"m_szNotice": text})
	return true




func guild_upgrade() -> bool:
	if _phase != "world":
		return false
	_send("TeamMessage.RequestGuildUpgrade", {})
	return true




func guild_gift() -> bool:
	if _phase != "world":
		return false
	_send("TeamMessage.RequestGuildGift", {})
	return true




func guild_skill_learn(id: int) -> bool:
	if _phase != "world":
		return false
	_send("CharMessage.RequestLearnGuildSkill", {"m_nGuildSkillId": id})
	return true


func guild_skill_research(id: int) -> bool:
	if _phase != "world":
		return false
	_send("TeamMessage.RequestResearchGuildSkill", {"m_nGuildSkillId": id})
	return true


func guild_skill_unlock(slot: int) -> bool:
	if _phase != "world":
		return false
	_send("CharMessage.RequestUnlockSkillSlot", {"m_nSkillSlot": slot})
	var bit: int = 0
	if slot >= 4 and slot <= 8:
		bit = 1 << (slot - 4)
	elif slot < 5:
		bit = 1 << slot
	if bit != 0:
		guild_skill_flag |= bit
	guild_rev += 1
	changed.emit()
	return true


func guild_skill_set(id: int, level: int, slot: int) -> bool:
	if _phase != "world":
		return false
	_send("CharMessage.RequestSetGuildSkill", {"m_skillSlotInfo": {"m_nSkillSlot": slot, "m_nSkillId": id, "m_nSkillLevel": level}})
	guild_skill_slots[slot] = [id, level]
	guild_rev += 1
	changed.emit()
	return true



func guild_change_post(uuid: String, post: int, team: int) -> bool:
	if _phase != "world" or uuid.is_empty():
		return false
	_send("TeamMessage.RequestChangePost", {"m_targetUuid": uuid, "m_iPost": post, "m_nTeamId": team})
	return true



func guild_move_member(orig_team: int, orig_uuid: String, dest_team: int, dest_uuid: String) -> bool:
	if _phase != "world" or orig_uuid.is_empty():
		return false
	_send("TeamMessage.RequestMoveMember", {"m_nOrigTeamId": orig_team, "m_origUuid": orig_uuid, 
		"m_nDestTeamId": dest_team, "m_destUuid": dest_uuid})
	return true



func guild_invite_member(team: int, uuid: String) -> bool:
	if _phase != "world" or uuid.is_empty():
		return false
	_send("TeamMessage.RequestInviteMember", {"m_nTeamId": team, "m_charUuid": uuid})
	return true




func guild_team_invite_answer(accept: bool) -> bool:
	var invite: Dictionary = guild_team_invite
	guild_team_invite = {}
	changed.emit()
	if not accept or invite.is_empty() or _phase != "world":
		return false
	_send("TeamMessage.AcceptChangeTeam", {"m_nTeamId": int(invite.team), "m_charUuid": str(invite.uuid)})
	return true




func guild_invite(target: String, team: int) -> bool:
	if _phase != "world" or target.is_empty():
		return false
	_send("TeamMessage.RequestGuildInvite", {"m_nTargeter": target, "m_nTeamId": team})
	return true




func guild_create_team(name: String) -> bool:
	if _phase != "world" or name.is_empty():
		return false
	var text: PackedByteArray = name.to_utf8_buffer()
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u16(text.size())
	body.put_data(text)
	_send_raw(68, body.data_array)
	return true



func guild_create(guild_name: String, team_name: String) -> bool:
	if _phase != "world" or guild_name.is_empty() or team_name.is_empty():
		return false
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	for text: PackedByteArray in [guild_name.to_utf8_buffer(), team_name.to_utf8_buffer()]:
		body.put_u16(text.size())
		body.put_data(text)
	_send_raw(69, body.data_array)
	return true



func guild_join_apply(gid: int, invite: String = "", fast: bool = false) -> bool:
	if _phase != "world" or not guild.is_empty():
		return false
	_send("TeamMessage.RequestJoinApply", {"m_nGuildId": gid, "m_szInviteName": invite, "m_isFastJoin": 1 if fast else 0})
	return true



func guild_team_pve(open: bool) -> bool:
	if _phase != "world":
		return false
	_send("TeamMessage.RequestChangeTeamPveFlag", {"m_isOpen": 1 if open else 0})
	return true


func guild_apply_list_request() -> bool:
	if _phase != "world" or guild.is_empty():
		return false
	_send("TeamMessage.RequestApplyList", {})
	return true



func guild_approve_apply(uuid: String, team: int) -> bool:
	if _phase != "world" or uuid.is_empty():
		return false
	_send("TeamMessage.RequestApproveApply", {"m_charUuid": uuid, "m_nTeamId": team})
	_drop_apply(uuid)
	return true


func guild_reject_apply(uuid: String) -> bool:
	if _phase != "world":
		return false
	_send("TeamMessage.RequestRejectApply", {"m_charUuid": uuid})
	if uuid.is_empty():
		guild_applies = []
		guild_req_join = 0
		guild_rev += 1
		changed.emit()
	else:
		_drop_apply(uuid)
	return true

func _drop_apply(uuid: String) -> void :
	guild_applies = guild_applies.filter( func(brief: Dictionary) -> bool: return str(brief.get("m_charUuid", "")) != uuid)
	guild_req_join = maxi(0, guild_req_join - 1)
	guild_rev += 1
	changed.emit()



func guild_op(kind: int, param: int) -> bool:
	if _phase != "world" or guild.is_empty():
		return false
	_send("TeamMessage.RequestGuildOp", {"m_type": kind, "m_iparam": param})
	return true



func guild_set_recruit(text: String) -> bool:
	if _phase != "world" or guild.is_empty():
		return false
	var words: PackedByteArray = text.to_utf8_buffer()
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	body.put_u16(words.size())
	body.put_data(words)
	_send_raw(663, body.data_array)
	return true





const RENAME_DONE: String = "Đã đổi tên thành "
var _renaming: bool = false
func rename_char(name: String) -> bool:
	if _phase != "world" or name.is_empty():
		return false
	_renaming = true
	_send("CharMessage.RequestChangeName", {"m_newName": name, "m_sexes": 0})
	return true


func rename_team(team: int, name: String) -> bool:
	if _phase != "world" or name.is_empty():
		return false
	_send("TeamMessage.RequestChangeTeamName", {"m_newName": name, "m_nTeamId": team})
	return true


func rename_guild(name: String) -> bool:
	if _phase != "world" or name.is_empty():
		return false
	_send("TeamMessage.RequestChangeGuildName", {"m_newName": name})
	return true



func add_friend(name: String, origin: int = 0) -> bool:
	name = name.strip_edges()
	if name.is_empty() or _phase != "world" or friend_busy():
		return false
	_friend_pending = name
	_friend_sent = Time.get_ticks_msec() / 1000.0
	_send("FriendMessage.RequestAddFriend", {"m_targetName": name, "m_applyOrigin": origin})
	return true


func friend_busy() -> bool:
	return not _friend_pending.is_empty() and Time.get_ticks_msec() / 1000.0 - _friend_sent < 6.0


func delete_friend(uuid: String) -> bool:
	if not friends.has(uuid) or _phase != "world":
		return false
	_send("FriendMessage.RequestDeleteRelation", {"m_charUuid": uuid, "m_type": 1})
	return true



func add_black(name: String) -> bool:
	name = name.strip_edges()
	if name.is_empty() or _phase != "world":
		return false
	_send("FriendMessage.RequestAddRelation", {"m_strName": name, "m_type": RELATION_BLACK})
	return true


func delete_black(uuid: String) -> bool:
	if not blacks.has(uuid) or _phase != "world":
		return false
	_send("FriendMessage.RequestDeleteRelation", {"m_charUuid": uuid, "m_type": RELATION_BLACK})
	return true


func is_black(uuid: String) -> bool:
	return not uuid.is_empty() and blacks.has(uuid)


func is_black_name(name: String) -> bool:
	name = name.strip_edges()
	for brief: Dictionary in blacks.values():
		if not brief.is_empty() and str(brief.get("m_name", "")) == name:
			return true
	return false


func refresh_friends() -> void :
	if _phase == "world":
		_send("FriendMessage.RequestRefreshFriendData", {})



func approve_friend(uuid: String) -> bool:
	return _apply_op(uuid, "FriendMessage.ApproveFriendApply", {"m_approveUuid": uuid})

func ignore_friend(uuid: String) -> bool:
	return _apply_op(uuid, "FriendMessage.IgnoreFriendApply", {"m_ignoreUuid": uuid})

func approve_all_friends() -> bool:
	return _apply_op("", "FriendMessage.ApproveAllFriendApply", {})

func ignore_all_friends() -> bool:
	return _apply_op("", "FriendMessage.IgnoreAllFriendApply", {})

func _apply_op(uuid: String, kind: String, body: Dictionary) -> bool:
	if _phase != "world" or friend_applies.is_empty():
		return false
	var keep: Array = [] if uuid.is_empty() else friend_applies.filter( func(info: Dictionary) -> bool: return str(info.get("m_charUuid", "")) != uuid)
	if keep.size() == friend_applies.size():
		return false
	friend_applies = keep
	friend_apply_count = keep.size()
	friend_rev += 1
	_send(kind, body)
	changed.emit()
	return true


func request_applies() -> void :
	if _phase == "world":
		_send("FriendMessage.RequestFriendApplyList", {})


func quick_friends(count: int = 5) -> bool:
	var now: float = Time.get_ticks_msec() / 1000.0
	if _phase != "world" or now - _suggest_sent < 1.0:
		return false
	_suggest_sent = now
	var body: PackedByteArray = PackedByteArray()
	body.resize(8)
	body.encode_u32(0, clampi(count, 1, 10))
	_send_raw(707, body)
	return true


func invite_friend(name: String) -> bool:
	var now: float = Time.get_ticks_msec() / 1000.0
	if state != "room" or battle.active or name.is_empty() or not can_invite(name):
		return false
	_invites[name] = now
	_send("RoomMessage.RequestRoomInvite", {"m_target": name})
	return true

func can_invite(name: String) -> bool:
	return state == "room" and Time.get_ticks_msec() / 1000.0 - float(_invites.get(name, -10.0)) >= 5.0



func request_players(tab: String) -> bool:
	var now: float = Time.get_ticks_msec() / 1000.0
	if _phase != "world" or not PLAYER_TABS.has(tab) or now - float(_players_sent.get(tab, -10.0)) < 0.6:
		return false
	_players_sent[tab] = now
	_send("RoomMessage.RequestPlayerList", {"m_listType": PLAYER_TABS[tab], "m_iSite": 0})
	return true


func players(tab: String) -> Array:
	var kind: int = int(PLAYER_TABS.get(tab, -1))
	if kind == 0:
		kind = 4 if state == "room" else 1
	return room_state.lists.get(kind, [])

func open_hall() -> void :
	if state not in ["lobby", "hall"]:
		return
	room_state.self_id = account_oid
	state = "hall"
	status = "Đấu Trường · So Tài"
	hall_type = 2
	refresh_rooms()
	_send("RoomMessage.RequestPlayerList", {"m_listType": 3, "m_iSite": 0})
	changed.emit()

func refresh_rooms(site: int = 0) -> void :
	if state != "hall":
		return
	_hall_poll = 0
	if hall_type == TEAM_ROOM:
		_team_poll()
		return
	if hall_type == LADDER_ROOM:
		return
	_send("RoomMessage.RequestInHall", {"m_bType": 2, "m_iSite": site})

func back_to_lobby() -> void :
	if state != "hall":
		return
	_send("RoomMessage.RequestOutHall", {})
	state = "lobby"
	status = "Đã vào máy chủ BangBang."
	changed.emit()







func create_room(name: String, password: int = 0, kind: int = 1, map: int = 4, mode: int = 0) -> void :
	if state != "hall" or _room_action > 0 or kind not in [1, PVP_ROOM]:
		return
	_room_action = 1

	_send("RoomMessage.RequestCreateRoom", {"m_bType": kind, "m_bMode": GIAIDAU1_MODE if kind == 1 and mode == GIAIDAU1_MODE else 0, "m_mapId": 0 if kind == PVP_ROOM else maxi(0, map), 
		"m_passWord": maxi(0, password), "m_szName": name.strip_edges().left(40), "m_nItemId": 0})

func join_room(id: int, password: int = 0, watch: bool = false) -> void :
	if state != "hall" or not room_state.rooms.has(id) or _room_action > 0:
		return
	_room_action = 1


	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": id, "m_bType": 2, "m_bMode": GIAIDAU1_MODE if watch else 0, 
		"m_mapId": 0, "m_nPassword": password, "m_nContestId": 0})








const INVITE_JOIN: Dictionary = {1: 2, 2: 2}



const FRIEND_PVE: Array = [3, 4, 8]

func _receive_invite(value: Dictionary) -> void :
	if not room_invite.is_empty() or state not in ["lobby", "hall"] or battle.active:
		return
	var name: String = str(value.get("m_start", "")).strip_edges()
	var room: int = int(value.get("m_nRoomId", 0))
	if name.is_empty() or room <= 0:
		return
	room_invite = {"name": name, "room": room, "type": int(value.get("m_bType", 0)), "password": int(value.get("m_nPassword", 0)), 
		"from": int(value.get("m_nStartId", 0)), "map": int(value.get("m_nMapId", 0)), "mode": int(value.get("m_nBattleMode", 0))}
	changed.emit()




func accept_invite() -> String:
	var invite: Dictionary = room_invite
	room_invite = {}
	changed.emit()
	if invite.is_empty():
		return ""
	if not pair_scene.is_empty():
		return INVITE_PAIRING
	if is_pairing():
		return INVITE_PAIRING
	if state not in ["lobby", "hall"] or battle.active or _room_action > 0:
		return ""
	_room_action = 1
	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": int(invite.room), "m_bType": int(INVITE_JOIN.get(int(invite.type), int(invite.type))), "m_bMode": 0, 
		"m_mapId": 0, "m_nPassword": int(invite.password), "m_nContestId": 0})
	return ""

const INVITE_PAIRING: String = "Đang phối hợp, không thể thao tác"



func decline_invite(reject: bool = true) -> void :
	if room_invite.is_empty():
		return
	var from: int = int(room_invite.get("from", 0))
	room_invite = {}
	if reject:
		_send("RoomMessage.RejectRoomInvite", {"m_nStartId": from})
	changed.emit()



const PS_ROOM: int = 2
const PS_BATTLE: int = 4
const LOOK_READY: bool = true
const GUILD_APPLY_TIP: String = "Có người chơi xin gia nhập Guild"

const GUILD_APPLY_LOGIN: String = "Có @num1@ người chơi xin gia nhập Guild, hãy xử lý kịp thời"
const LOOK_EXIT: String = "Thoát xem"
var _look_oid: int = 0
var _look_hint: int = 0
const LOOK_SOON: String = "Xem trận đang được chuyển sang HTML5."
const ROOM_FULL: String = "Số người trong room đã đầy, không thể vào"



func request_char_state(uuid: String) -> void :
	if uuid.is_empty() or _phase != "world":
		return
	char_states.erase(uuid)
	_send("CharMessage.RequestCharState", {"m_targetUuid": uuid})

func _receive_char_state(value: Dictionary) -> void :
	var uuid: String = str(value.get("m_szTargetUuid", ""))
	if uuid.is_empty():
		return
	char_states[uuid] = value.duplicate()
	changed.emit()



func look_scene(scene: int) -> String:
	if scene <= 0:
		return ""
	if not LOOK_READY:
		return LOOK_SOON
	if state not in ["lobby", "hall"] or battle.active or not room_state.room.is_empty():
		return ""


	_look_oid = _look_hint if _look_hint != 0 else _look_oid_of(scene)
	_send("RoomMessage.RequestLookScene", {"m_nSceneId": scene})
	return ""


func look_scene_oid(scene: int, oid: int) -> String:
	_look_hint = oid
	var text: String = look_scene(scene)
	_look_hint = 0
	return text

func _look_oid_of(scene: int) -> int:
	for uuid: String in char_states:
		var reply: Dictionary = char_states[uuid]
		if int(reply.get("m_nSceneId", 0)) == scene and int(reply.get("m_nState", 0)) == PS_BATTLE and friends.has(uuid):
			return int(friends[uuid].get("m_accountId", 0))
	return 0





func join_friend_room(room: int, type: int) -> String:
	if room <= 0:
		return ""
	if is_pairing():
		return INVITE_PAIRING
	if state not in ["lobby", "hall"] or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	var listed: Dictionary = room_state.rooms.get(room, {})
	if not listed.is_empty() and int(listed.get("m_nNum", 0)) >= maxi(1, int(listed.get("m_nMax", 10))):
		return ROOM_FULL
	_room_action = 1
	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": room, "m_bType": type if type in FRIEND_PVE else 0, "m_bMode": 0, "m_mapId": 0, 
		"m_nPassword": 0, "m_nContestId": 0})
	return ""





func is_pairing() -> bool:
	if not pairing.is_empty() or not pair_confirm.is_empty() or not pair_scene.is_empty() or not room_hold.is_empty():
		return true
	return quick_pair and Time.get_ticks_msec() - _quick_sent_at < 2000






func quick_match() -> String:
	if is_pairing():
		return INVITE_PAIRING
	if state != "hall" or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	if AT_MATCH_PVP in act_types.values() and not act_going(AT_MATCH_PVP):
		return TIP_689
	var now: int = Time.get_ticks_msec()
	quick_pair = true
	_quick_sent_at = now
	_quick_type = 0
	_quick_wait_until = now + 10000
	_quick_armed = true
	_send("RoomMessage.RequestStartMatch", {"m_bType": 2})
	return ""




func stop_match() -> bool:
	var now: int = Time.get_ticks_msec()
	if pairing.is_empty() or now - _stop_sent_at < 3000:
		return false
	_stop_sent_at = now
	_kt2_stop_at = now
	_send("RoomMessage.RequestStopMatch", {})
	return true



func confirm_pair() -> bool:
	if not quick_pair or pair_confirm.is_empty() or bool(pair_confirm.mine):
		return false
	pair_confirm["mine"] = true
	pair_flush()
	changed.emit()
	return true



func pair_flush() -> void :
	if pair_confirm.is_empty():
		return
	var elapsed: int = Time.get_ticks_msec() - int(pair_confirm.at)
	if bool(pair_confirm.mine) and not bool(pair_confirm.sent) and quick_pair and (int(pair_confirm.robots) <= 0 or elapsed >= PAIR_ROBOT_WAIT):
		pair_confirm["sent"] = true
		var body: PackedByteArray = PackedByteArray()
		body.resize(4)
		body.encode_u32(0, int(pair_confirm.scene))
		_send_raw(619, body)
	if elapsed >= int(pair_confirm.seconds) * 1000:
		var rq1_back: bool = quick_pair and bool(pair_confirm.mine) and bool(pair_confirm.sent)
		_pair_close()
		if rq1_back:
			_quick_wait_until = Time.get_ticks_msec() + 3000
			_quick_armed = true
		else:
			_quick_end()
		changed.emit()



func _pair_close() -> void :
	if pair_confirm.is_empty():
		return
	if quick_pair and int(pair_confirm.confirmed) < int(pair_confirm.total):
		noticed.emit(PAIR_STOPPED_SELF if bool(pair_confirm.mine) else PAIR_STOPPED)
	pair_confirm.clear()


func _pair_left_recent(now: int) -> bool:
	return now - _pair_left_at < PAIR_LEFT_WINDOW

func _quick_end() -> void :
	quick_pair = false
	_quick_type = 0
	_quick_wait_until = -100000
	_quick_armed = false


func _pair_reset() -> void :
	pairing.clear()
	pair_confirm.clear()
	_quick_end()
	_pair_again_at = -100000
	_room_hold_drop(false)



func _room_hold_snap(value: Dictionary) -> bool:
	var now: int = Time.get_ticks_msec()
	if _room_snap.is_empty() or now - int(_room_snap.at) > ROOM_SNAP_FRESH:
		_room_snap = {"room": room_state.room.duplicate(true), "members": room_state.members.duplicate(true), 
			"appearances": room_state.appearances.duplicate(true), "at": now}
	var who: int = int(value.get("m_nTarget", 0)) if int(value.get("m_nTarget", 0)) != 0 else int(value.get("m_nStartOid", 0))
	return who == account_oid and now - _leave_sent_at > ROOM_SNAP_FRESH and not battle.active


func _room_hold_start(ladder: bool) -> void :
	room_hold = {"left": {"room": room_state.room.duplicate(true), "members": room_state.members.duplicate(true), 
		"appearances": room_state.appearances.duplicate(true)}, "ladder": ladder, "at": Time.get_ticks_msec(), "seen": false}
	room_state.room = _room_snap.room.duplicate(true)
	room_state.members = _room_snap.members.duplicate(true)
	room_state.appearances = _room_snap.appearances.duplicate(true)
	_held_mates = _mates_of(room_state.members)
	_held_mates_at = Time.get_ticks_msec()
	_room_snap = {}


static func _mates_of(members: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for id: Variant in members:
		out[int(id)] = true
	return out



func _pair_mates() -> Dictionary:
	var out: Dictionary = _mates_of(room_state.members)
	if Time.get_ticks_msec() - _held_mates_at <= HELD_MATES_FRESH:
		out.merge(_held_mates)
	_held_mates = {}
	_held_mates_at = -100000
	return out



func _room_hold_drop(rooms: bool) -> void :
	if room_hold.is_empty():
		return
	var left: Dictionary = room_hold.left
	var ladder: bool = bool(room_hold.ladder)
	room_hold.clear()
	room_state.room = left.room
	room_state.members = left.members
	room_state.appearances = left.appearances
	if state != "room":
		return
	state = "hall"
	if ladder:
		status = "Đấu Trường · Đấu Xếp Hạng"
		ladder_return = true
	else:
		_team_disarm()
		status = "Đấu Trường · So Tài"
		if rooms:
			refresh_rooms()


func _room_hold_tick() -> void :
	var now: int = Time.get_ticks_msec()
	if not pairing.is_empty() or not pair_confirm.is_empty() or not pair_scene.is_empty():
		room_hold["at"] = now
		room_hold["seen"] = bool(room_hold.seen) or not pair_confirm.is_empty()
		return
	if state != "room" or battle.active:
		_room_hold_drop(false)
	elif now - int(room_hold.at) > (ROOM_HOLD_BACK if bool(room_hold.seen) else ROOM_HOLD_WAIT):
		_room_hold_drop(true)
		changed.emit()



func _pair_watch() -> void :
	var now: int = Time.get_ticks_msec()
	if _kt2_stop_at == -100000:
		if PAIR_GIVE_UP > 0 and now - int(pairing.get("since", now)) >= PAIR_GIVE_UP and stop_match():
			noticed.emit(PAIR_GAVE_UP)
		return
	if now - _kt2_stop_at < PAIR_STOP_WAIT:
		return
	_kt2_stop_at = -100000
	pairing.clear()
	_quick_end()
	noticed.emit(PAIR_STOP_LOCAL)
	changed.emit()



func _receive_pair(type: int, body: PackedByteArray) -> void :
	var now: int = Time.get_ticks_msec()
	match type:
		1719:

			if body.size() < 13:
				return
			if pair_room() or _pair_left_recent(now):


				quick_pair = true
				_quick_armed = true
				_quick_wait_until = maxi(_quick_wait_until, now + 3000)
			if quick_pair and pairing.is_empty() and not _quick_armed and now > _quick_wait_until:
				_quick_end()
			_quick_armed = false
			var waited: int = clampi(int(body.decode_u32(0)), 0, 3600)
			pairing = {"since": now - waited * 1000, "type": int(body.decode_u8(4)), "avg": int(body.decode_u32(5)), "count": int(body.decode_u32(9))}
			_stop_sent_at = -100000
			_kt2_stop_at = -100000
		3504:

			if body.size() < 11:
				return
			if not pairing.is_empty():
				pairing["avg"] = int(body.decode_u32(3))
				pairing["count"] = int(body.decode_u32(7))
			elif quick_pair and int(body.decode_u32(7)) == 0 and pair_confirm.is_empty() and pair_scene.is_empty() and (_quick_armed or now - _quick_sent_at < 3000)\
			and (_quick_type == 0 or int(body.decode_u8(2)) == _quick_type):
				_quick_end()
		1720:

			var rkm1_queued: bool = not pairing.is_empty()
			pairing.clear()
			pair_scene.clear()
			if body.size() >= 4:
				_quick_end()
			elif quick_pair or _pair_left_recent(now) or rkm1_queued:
				quick_pair = true
				_quick_wait_until = now + 3000
				_quick_armed = true
		1742:

			if body.size() < 20:
				return
			pairing.clear()
			if _team_armed and team_room():

				quick_pair = true
				_quick_wait_until = maxi(_quick_wait_until, now + 3000)
			elif pair_room() and quick_pair:
				_quick_wait_until = maxi(_quick_wait_until, now + 3000)
			elif _pair_left_recent(now):
				quick_pair = true
				_quick_armed = true
				_quick_wait_until = maxi(_quick_wait_until, now + 3000)
			_pair_left_at = -100000
			if quick_pair and not _quick_armed and now > _quick_wait_until:
				_quick_end()
			_quick_armed = false
			pair_confirm = {"seconds": clampi(int(body.decode_s32(0)), 1, 600), "total": clampi(int(body.decode_s32(4)), 1, 20), 
				"confirmed": maxi(0, int(body.decode_s32(8))), "robots": maxi(0, int(body.decode_s32(12))), "scene": int(body.decode_u32(16)), 
				"at": now, "mine": false, "sent": false}
		1741:
			if body.size() >= 4 and not pair_confirm.is_empty():
				pair_confirm["confirmed"] = clampi(int(body.decode_s32(0)), 0, int(pair_confirm.total))
		1750:

			_pair_close()
			if quick_pair:
				_quick_wait_until = now + 3000
				_quick_armed = true




func team_act() -> int:
	for id: int in act_types:
		if int(act_types[id]) == TEAM_ACT:
			return id
	return TEAM_ACT


func team_act_open() -> bool:
	return act_now_state(team_act()) == 2


func team_room() -> bool:
	return state == "room" and int(room_state.room.get("m_bType", 0)) == TEAM_ROOM



func team_hall(site: int = -1) -> void :
	if state != "hall" or hall_type != TEAM_ROOM:
		return
	_hall_poll = 0
	_team_polled_at = Time.get_ticks_msec()
	_send("RoomMessage.RequestInHall", {"m_bType": TEAM_ROOM, "m_iSite": site})



func hall_tab(type: int) -> void :
	if state != "hall" or type == hall_type or type not in [2, TEAM_ROOM]:
		return
	hall_type = type
	room_state.rooms.clear()
	_team_polled_at = -100000
	refresh_rooms()
	changed.emit()


func _team_poll() -> void :
	var rows: int = room_state.rooms.size()
	var since: int = Time.get_ticks_msec() - _team_polled_at
	if rows >= 8 or since < (5000 if rows == 0 else 10000):
		return
	team_hall(-1)


func team_row_mine(room: Dictionary) -> bool:
	var team: int = int(room.get("m_nTeamId", room.get("clanId", 0)))
	return guild_self_team != 0 and team == guild_self_team




func team_match_join(id: int = 0) -> String:
	if is_pairing():
		return INVITE_PAIRING
	if state not in ["lobby", "hall"] or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	_room_action = 1
	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": maxi(0, id), "m_bType": TEAM_ROOM, "m_bMode": 0, "m_mapId": 0, "m_nPassword": 0, 
		"m_nContestId": 0})
	return ""




func territory_join(slot: int) -> String:
	if is_pairing():
		return INVITE_PAIRING
	if slot < 1 or slot > 15 or state not in ["lobby", "hall"] or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	_room_action = 1
	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": 0, "m_bType": 12, "m_bMode": 0, "m_mapId": 1201000 + slot, "m_nPassword": 0, 
		"m_nContestId": 0})
	return ""



func team_pve_enter() -> String:
	if is_pairing():
		return INVITE_PAIRING
	if state not in ["lobby", "hall"] or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	_room_action = 1
	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": 0, "m_bType": 3, "m_bMode": 0, "m_mapId": 0, "m_nPassword": 0, "m_nContestId": 0})
	return ""


func team_pair_start() -> bool:
	if not team_room() or not pair_scene.is_empty():
		return false
	_send("TeamMessage.TeamMatchStartPair", {})
	return true


func team_pair_stop() -> bool:
	if not team_room() or not pair_scene.is_empty():
		return false
	_send_raw(568, PackedByteArray())
	return true


func team_seat(join: bool) -> bool:
	if not team_room():
		return false
	room_op(2 if join else 3, 4294967295)
	return true

func _receive_team_match(value: Dictionary) -> void :
	var brief: Dictionary = value.get("m_cgTeamBrief", {}) if value.get("m_cgTeamBrief", {}) is Dictionary else {}
	var phase: int = int(value.get("m_nState", 0))
	team_match = {"state": phase, "start": int(value.get("m_nStartTime", 0)), "notify": int(value.get("m_notifyType", 0)), 
		"team_id": int(brief.get("m_nTeamId", 0)), "name": str(brief.get("m_szName", "")), "place": int(brief.get("m_iPlace", 0)), 
		"glory": int(brief.get("m_iGlory", 0)), "rev": int(team_match.get("rev", 0)) + 1}
	var now: int = Time.get_ticks_msec()
	if phase in [7, 8] and team_room() and room_state.is_ready():

		_team_armed = true
		quick_pair = true
		_quick_sent_at = now - 3000
		_quick_wait_until = now + 3600000
	elif _team_armed:
		_team_disarm()

func _team_disarm() -> void :
	if not _team_armed:
		return
	_team_armed = false
	if pair_confirm.is_empty() and pair_scene.is_empty():
		_quick_end()



const LEAGUE_ROOM: int = 6





const TERRITORY_ROOM: int = 12



const PICK_TYPES: Array = [1, 2, LEAGUE_ROOM, 9, 11, 13, 100, TEAM_ROOM, TERRITORY_ROOM]


const PICK_SHARED: Array = [1, 2, TERRITORY_ROOM]


const PICK_CONTS: Array = [0, 1, 4]






func league_queue() -> String:
	if is_pairing():
		return INVITE_PAIRING
	if state not in ["lobby", "hall"] or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	var now: int = Time.get_ticks_msec()
	quick_pair = true
	_quick_sent_at = now
	_quick_type = 0
	_quick_wait_until = now + 10000
	_quick_armed = true
	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": 0, "m_bType": LEAGUE_ROOM, "m_bMode": 0, "m_mapId": 0, "m_nPassword": 0, 
		"m_nContestId": 0})
	return ""



func world_boss_wait_at(now: int = -1) -> int:
	var info: Variant = acts.get(8)
	if not (info is Array and (info as Array).size() >= 3) or int(info[2]) != 1:
		return 0
	if now < 0:
		now = int(Time.get_unix_time_from_system())
	return int(info[0]) if int(info[0]) > now else 0


func act_now_state(id: int, now: int = -1) -> int:
	var info: Variant = acts.get(id)
	if not (info is Array and (info as Array).size() >= 3):
		return 3
	var start: int = int(info[0])
	var end: int = start + int(info[1])
	if start == 0 and end == 0:
		return 3
	if now < 0:
		now = int(Time.get_unix_time_from_system())
	if now >= end:
		return 3
	return 1 if now < start else 2


func act_going(type: int, now: int = -1) -> bool:
	for id: int in acts:
		if int(act_types.get(id, -1)) == type and int(acts[id][2]) != 3 and act_now_state(id, now) == 2:
			return true
	return false



func match_act_id() -> int:
	return act_first(EVENT_ROOMS.keys())



func act_first(types: Array) -> int:
	var rows: Array = []
	for id: int in acts:
		if int(act_types.get(id, -1)) in types:
			rows.append([id, int(acts[id][2]), int(acts[id][0])])
	if rows.is_empty():
		return 0
	rows.sort_custom( func(a: Array, b: Array) -> bool:
		var ka: int = [2, 1, 0, 3][clampi(int(a[1]), 0, 3)]
		var kb: int = [2, 1, 0, 3][clampi(int(b[1]), 0, 3)]
		if ka != kb:
			return ka < kb
		return int(a[2]) < int(b[2]) if int(a[2]) != int(b[2]) else int(a[0]) < int(b[0]))
	return int(rows[0][0])


func act_match_room() -> int:
	return int(EVENT_ROOMS.get(int(act_types.get(match_act_id(), -1)), 100))




func act_match() -> String:
	var type: int = int(act_types.get(match_act_id(), -1))
	if not EVENT_ROOMS.has(type):
		return event_match(100)
	if type == 32:
		var owned: bool = false
		for inst: Dictionary in tanks.values():
			if int(inst.get("m_contType", -1)) == 0 and int(inst.get("m_tpltId", 0)) in fire_ball_tanks:
				owned = true
				break
		if not owned:
			return TIP_683
	return event_match(int(EVENT_ROOMS[type]))




func event_match(room: int) -> String:
	if is_pairing():
		return INVITE_PAIRING
	if room not in EVENT_ROOMS.values() or state != "hall" or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	hall_room = room
	var type: int = int(EVENT_ROOMS.find_key(room))
	if type in act_types.values() and not act_going(type):
		return TIP_689
	var now: int = Time.get_ticks_msec()
	quick_pair = true
	_quick_sent_at = now
	_quick_type = 0
	_quick_wait_until = now + 10000
	_quick_armed = true
	_quick_type = room
	_send("RoomMessage.RequestStartMatch", {"m_bType": room})
	return ""



const LADDER_ROOM: int = 9
const LADDER_ACT: int = 14
const LADDER_LEVEL: int = 15
const LADDER_TANKS: int = 5
const LADDER_TIP_TANKS: String = "Có @num1@ tank vĩnh viễn mới được tham gia Đấu Xếp Hạng"
const LADDER_TIP_LEVEL: String = "Nhân vật lv@num1@, có @num2@ tank vĩnh viễn mới được tham gia Đấu Xếp Hạng"
const LADDER_TIP_NO_ID: String = "Nhập số room"
var ladder_return: bool = false



func ladder_tab() -> void :
	if state != "hall" or hall_type == LADDER_ROOM:
		return
	hall_type = LADDER_ROOM
	room_state.rooms.clear()
	_hall_poll = 0
	_send("RoomMessage.RequestInHall", {"m_bType": LADDER_ROOM, "m_iSite": -1})
	changed.emit()



func ladder_leave() -> void :
	if hall_type != LADDER_ROOM:
		return
	hall_type = 2
	room_state.rooms.clear()
	_hall_poll = 5.0



func ladder_check(now: int = -1) -> String:
	var own: int = 0
	for inst: Dictionary in tanks.values():
		if int(inst.get("m_contType", -1)) == 0:
			own += 1
	if LADDER_LEVEL == 0:
		if own < LADDER_TANKS:
			return LADDER_TIP_TANKS.replace("@num1@", str(LADDER_TANKS))
	elif int(character.get("level", 0)) < LADDER_LEVEL or own < LADDER_TANKS:
		return LADDER_TIP_LEVEL.replace("@num1@", str(LADDER_LEVEL)).replace("@num2@", str(LADDER_TANKS))
	var id: int = act_first([LADDER_ACT])
	if id != 0 and acts.has(id):
		if now < 0:
			now = int(Time.get_unix_time_from_system())
		var info: Array = acts[id]
		if now < int(info[0]) or now > int(info[0]) + int(info[1]):
			return TIP_689
	return ""




func ladder_match() -> String:
	if is_pairing():
		return INVITE_PAIRING
	if state != "hall" or hall_type != LADDER_ROOM or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	var why: String = ladder_check()
	if not why.is_empty():
		return why
	var now: int = Time.get_ticks_msec()
	quick_pair = true
	_quick_sent_at = now
	_quick_type = LADDER_ROOM
	_quick_wait_until = now + 10000
	_quick_armed = true
	_send("RoomMessage.RequestStartMatch", {"m_bType": LADDER_ROOM})
	return ""






func ladder_create(name: String, password: int, size: int = 5) -> String:
	if is_pairing():
		return INVITE_PAIRING
	if state != "hall" or hall_type != LADDER_ROOM or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	var why: String = ladder_check()
	if not why.is_empty():
		return why
	_room_action = 1
	_send("RoomMessage.RequestCreateRoom", {"m_bType": LADDER_ROOM, "m_bMode": 3 if size == 3 else 5, "m_mapId": 0, "m_passWord": maxi(0, password), 
		"m_szName": name.strip_edges().left(40), "m_nItemId": 0})
	return ""




func ladder_join(id: int, password: int) -> String:
	if id <= 0:
		return LADDER_TIP_NO_ID
	if is_pairing():
		return INVITE_PAIRING
	if state != "hall" or hall_type != LADDER_ROOM or battle.active or not room_state.room.is_empty() or _room_action > 0:
		return ""
	_room_action = 1
	_send("RoomMessage.RequestJoinRoom", {"m_nRoomId": id, "m_bType": LADDER_ROOM, "m_bMode": 0, 
		"m_mapId": 0, "m_nPassword": maxi(0, password), "m_nContestId": 0})
	return ""


func ladder_room() -> bool:
	return state == "room" and int(room_state.room.get("m_bType", 0)) == LADDER_ROOM

const PVP_ROOM: int = 2
const AT_MATCH_PVP: int = 45
const TIP_97: String = "Ít nhất cần @num1@ người mới có thể vào game"


func pvp_room() -> bool:
	return state == "room" and int(room_state.room.get("m_bType", 0)) == PVP_ROOM


func pair_room() -> bool:
	return pvp_room() or ladder_room()





func pvp_room_match() -> String:
	if not pvp_room() or not room_state.is_host() or battle.active:
		return ""
	var least: int = int(room_state.room.get("m_nMin", 0))
	if room_state.members.size() < least:
		return TIP_97.replace("@num1@", str(least))
	if is_pairing():
		return INVITE_PAIRING
	if AT_MATCH_PVP in act_types.values() and not act_going(AT_MATCH_PVP):
		return TIP_689
	var now: int = Time.get_ticks_msec()
	quick_pair = true
	_quick_sent_at = now
	_quick_type = 0
	_quick_wait_until = now + 10000
	_quick_armed = true
	_send("RoomMessage.RequestStartMatch", {"m_bType": PVP_ROOM})
	return ""




func ladder_room_match() -> String:
	if is_pairing():
		return INVITE_PAIRING
	if not ladder_room() or not room_state.is_host() or battle.active:
		return ""
	var why: String = ladder_check()
	if not why.is_empty():
		return why
	var now: int = Time.get_ticks_msec()
	quick_pair = true
	_quick_sent_at = now
	_quick_type = LADDER_ROOM
	_quick_wait_until = now + 10000
	_quick_armed = true
	_send("RoomMessage.RequestStartMatch", {"m_bType": LADDER_ROOM})
	return ""




func _set_technologies(vec: Array, battle: bool = false) -> void :
	var was: int = ladder_section()
	technologies = vec.duplicate()
	if technologies.size() > 10:
		if not battle:
			was = ladder_section()
		ladder_old = was
		ladder_section_up.emit(was, ladder_section())


func ladder_section() -> int:
	return int(technologies[10]) if technologies.size() > 10 else 0


func ladder_elo() -> int:
	return int(technologies[8]) if technologies.size() > 8 else 0


func can_pick_tank() -> bool:
	return not pair_scene.is_empty() and not battle.active and state in ["lobby", "hall", "room"]



func pair_round() -> bool:
	return not pair_scene.is_empty() and (int(pair_scene.get("type", 0)) == 9 or not (pair_scene.get("turn", {}) as Dictionary).is_empty())



func pair_camp() -> int:
	for brief: Dictionary in pair_scene.get("chars", []):
		if int(brief.get("charData", {}).get("nAcctId", 0)) == account_oid:
			return int(brief.get("bCamp", 1))
	return 1


func self_turn() -> bool:
	return int((pair_scene.get("turn", {}) as Dictionary).get("camp", 0)) == pair_camp()


func pair_all_locked() -> bool:
	if pair_scene.is_empty():
		return false
	var chars: Array = pair_scene.get("chars", [])
	var done: int = 0
	for brief: Dictionary in chars:
		if bool(pair_scene.get("locked", {}).get(int(brief.get("charData", {}).get("nAcctId", 0)), false)):
			done += 1
	return not chars.is_empty() and done >= chars.size()




func _pair_turn(value: Dictionary) -> bool:
	if pair_scene.is_empty() or int(value.get("m_nSceneId", 0)) != int(pair_scene.get("scene", 0)):
		return false
	var camp: int = int(value.get("m_campId", 0))
	var open: int = 0
	for brief: Dictionary in pair_scene.get("chars", []):
		var oid: int = int(brief.get("charData", {}).get("nAcctId", 0))
		if int(brief.get("bCamp", 1)) == camp and not bool(pair_scene.get("locked", {}).get(oid, false)):
			open += 1
	var count: int = int(value.get("m_iLockNum", 0))
	pair_scene["turn"] = {"camp": camp, "time": int(value.get("m_nTime", 0)), "at": Time.get_ticks_msec(), "count": count, 
		"max": mini(count, open), "done": 0}
	return true



func _pick_inst(tank: int) -> Dictionary:
	var now: int = int(Time.get_unix_time_from_system())
	var best: Dictionary = {}
	for inst: Dictionary in tanks.values():
		var cont: int = int(inst.get("m_contType", -1))
		if int(inst.get("m_tpltId", 0)) != tank or cont not in PICK_CONTS:
			continue
		if cont != 0 and int(inst.get("m_existTime", 0)) - now <= 0:
			continue
		if best.is_empty() or PICK_CONTS.find(cont) < PICK_CONTS.find(int(best.m_contType)):
			best = inst
	return best


func _pair_mate_tank(tank: int) -> bool:
	if int(pair_scene.get("type", 0)) in PICK_SHARED:
		return false
	var camps: Dictionary = {}
	for brief: Dictionary in pair_scene.get("chars", []):
		camps[int(brief.get("charData", {}).get("nAcctId", 0))] = int(brief.get("bCamp", 1))
	var own: int = int(camps.get(account_oid, 1))
	var picks: Dictionary = pair_scene.get("picks", {})
	for oid: int in picks:
		if oid != account_oid and int(camps.get(oid, -1)) == own and int(picks[oid].get("tank", 0)) == tank:
			return true
	return false




func pick_tank(tank: int) -> bool:
	if not can_pick_tank() or tank <= 0 or bool(pair_scene.get("locked", {}).get(account_oid, false)):
		return false
	if int(pair_scene.get("picks", {}).get(account_oid, {}).get("tank", 0)) == tank or _pair_mate_tank(tank):
		return false
	var inst: Dictionary = _pick_inst(tank)
	var now: int = Time.get_ticks_msec()
	if inst.is_empty() or (int(_pick_sent[0]) == tank and now - int(_pick_sent[1]) < 1000):
		return false
	_pick_sent = [tank, now]
	var body: PackedByteArray = PackedByteArray()
	body.resize(13)
	body.encode_u32(0, int(pair_scene.scene))
	body.encode_u32(4, tank)
	body.encode_u32(8, int(inst.m_contType))
	body.encode_u8(12, int(pair_scene.type))
	_send_raw(215, body)
	return true



func lock_tank() -> bool:
	if not can_pick_tank() or bool(pair_scene.get("locked", {}).get(account_oid, false)):
		return false
	if pair_round() and not self_turn():
		return false
	var now: int = Time.get_ticks_msec()
	if int(pair_scene.get("picks", {}).get(account_oid, {}).get("tank", 0)) <= 0 or now - _lock_sent_at < 1000:
		return false
	_lock_sent_at = now
	var body: PackedByteArray = PackedByteArray()
	body.resize(4)
	body.encode_u32(0, int(pair_scene.scene))
	_send_raw(614, body)
	return true






func pick_weekly_tank(tank: int) -> bool:
	if not can_pick_tank() or int(pair_scene.get("type", 0)) != 2 or tank <= 0 or bool(pair_scene.get("locked", {}).get(account_oid, false)):
		return false
	var row: Dictionary = weekly_row(tank, int(Time.get_unix_time_from_system()))
	if row.is_empty() or not bool(row.get("eligible", false)):
		return false
	if int(pair_scene.get("picks", {}).get(account_oid, {}).get("tank", 0)) == tank or _pair_mate_tank(tank):
		return false
	var now: int = Time.get_ticks_msec()
	if int(_pick_sent[0]) == tank and now - int(_pick_sent[1]) < 1000:
		return false
	_pick_sent = [tank, now]
	var body: PackedByteArray = PackedByteArray()
	body.resize(13)
	body.encode_u32(0, int(pair_scene.scene))
	body.encode_u32(4, tank)
	body.encode_u32(8, 3)
	body.encode_u8(12, 2)
	_send_raw(215, body)
	return true

func ready_room() -> void :
	if state == "room":
		room_op(3 if room_state.is_ready() else 2)

func start_room() -> void :
	if state == "room" and room_state.is_host():

		room_op(24)


func switch_camp() -> void :
	if state == "room":
		room_op(4)


func set_map(id: int) -> void :
	if state == "room" and room_state.is_host() and id >= 0:
		_send("RoomMessage.RequestSetMap", {"m_nMapId": id})



func change_battle_tank(uuid: String) -> void :
	if state in ["lobby", "hall", "room"] and tanks.has(uuid):
		_send("TankMessage.ChangeBattleTank", {"m_tankUuid": uuid})

func _tank_ready(uuid: String) -> bool:
	return state in ["lobby", "hall", "room"] and tanks.has(uuid)



func wear_skin(uuid: String, skin: String) -> bool:
	if not _tank_ready(uuid):
		return false
	_send("TankMessage.RequestChangeSkin", {"m_tankUuid": uuid, "m_skinUuid": skin, "m_contType": 6})
	return true



func buy_skin_chip(skin: int, coin: int, batch: bool) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or battle.active:
		return false
	if skin <= 0 or coin not in [1, 7]:
		return false
	_send("TankMessage.RequestBuyTankSkinChip", {"m_bBatch": 1 if batch else 0, "m_nSkinId": skin, "m_nCoinType": coin})
	return true




func _auto_check_chip(ids: Array) -> void :
	for id: Variant in ids:
		var row: Array = OpenSkinAtlas.CHIP.get(str(id), [])
		if not row.is_empty() and int(row[0]) <= int(skin_chips.get(int(id), 0)) and not owns_skin(int(id)) and not _chip_asked.has(int(id)):
			_chip_asked[int(id)] = true
			_send("TankMessage.RequestGetTankSkin", {"m_nSkinId": int(id)})


func owns_skin(id: int) -> bool:
	if id <= 0:
		return false
	for item: Variant in bags.get(6, []):
		if item is Dictionary and int((item as Dictionary).get("m_templateId", 0)) == id:
			return true
	return false


func _skin_new(id: int, owned: bool) -> void :
	if id <= 0 or owned or _skin_filmed.has(id):
		return
	_skin_filmed[id] = true
	skin_achieved.emit(id)



func _mail_brief(brief: Dictionary) -> Dictionary:
	return {"uuid": str(brief.get("m_strUuid", "")), "sender": str(brief.get("m_strSender", "")), "title": str(brief.get("m_strTitle", "")), 
		"deadline": int(brief.get("m_nArriveTime", 0)), "unread": int(brief.get("m_nMailState", 0)) == 0, "gift": int(brief.get("m_nSendMode", 0)) != 0}

func _mail_at(uuid: String) -> int:
	for index: int in range(mails.size()):
		if str(mails[index].uuid) == uuid:
			return index
	return -1

func _mail_ready() -> bool:
	return _role == "gate" and _phase == "world" and state in ["lobby", "hall", "room"]



func _mail_op(uuid: String, op: int) -> bool:
	if not _mail_ready() or ( not uuid.is_empty() and _mail_at(uuid) < 0):
		return false
	_send("MailMessage.RequestMailOperate", {"m_strUuid": uuid, "m_opType": op})
	return true

func request_mails() -> bool:
	return _mail_op("", 1)

func open_mail(uuid: String) -> bool:
	return not uuid.is_empty() and _mail_op(uuid, 4)

func delete_mail(uuid: String) -> bool:
	return not uuid.is_empty() and _mail_op(uuid, 5)

func delete_read_mails() -> bool:
	return _mail_op("", 5)

func claim_all_mails() -> bool:
	return _mail_op("", 8)



func claim_mail(uuid: String) -> bool:
	var body: Dictionary = mail_bodies.get(uuid, {})
	if not _mail_ready() or _mail_at(uuid) < 0 or body.is_empty():
		return false
	var items: Array = body.get("items", [])
	var cash: bool = int(body.get("cash", 0)) > 0
	if not items.is_empty():
		var out: StreamPeerBuffer = _tank_body(uuid)
		var item: PackedByteArray = str(items[0][0]).to_utf8_buffer()
		out.put_u16(item.size())
		out.put_data(item)
		_send_raw(272, out.data_array)
	if cash:
		_mail_op(uuid, 8)
	return cash or not items.is_empty()




func send_mail(receiver: String, title: String, text: String) -> bool:
	if not _mail_ready():
		return false
	var out: StreamPeerBuffer = _tank_body(receiver)
	for part: String in [title, text.replace("\r\n", "#ENTER#").replace("\r", "#ENTER#").replace("\n", "#ENTER#")]:
		var bytes: PackedByteArray = part.to_utf8_buffer()
		out.put_u16(bytes.size())
		out.put_data(bytes)
	out.put_32(0)
	out.put_u16(0)
	out.put_u16(0)
	out.put_32(0)
	out.put_u16(0)
	_send_raw(270, out.data_array)
	return true




var bought_kind: int = 0



func present_goods(goods: int, price: int, count: int, receiver: String) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or goods <= 0 or price < 0 or receiver.strip_edges().is_empty():
		return false
	_send("TradeMessage.PresentGoodsMessage", {"m_goodsId": goods, "m_price": price, "m_count": clampi(count, 1, 999), 
		"m_receiverName": receiver, "m_text": ""})
	return true

func buy_goods(kind: int, goods: int, coin: int, price: int, count: int) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or goods <= 0 or price < 0:
		return false
	_send("TradeMessage.BuyGoodsMessage", {"m_type": kind, "m_info": {"m_goodsId": goods, "m_coinType": coin, "m_price": price, 
		"m_count": clampi(count, 1, 999)}, "m_coinVec": [{"m_coinType": coin, "m_value": price * clampi(count, 1, 999)}]})
	return true





func buy_goods_vec(kind: int, goods: int, coin: int, price: int, count: int, coins: Array) -> bool:
	if _role != "gate" or _phase != "world" or (state not in ["lobby", "hall", "room"] and not pvp_result()) or goods <= 0 or price < 0:
		return false
	var vec: Array = []
	for pair in coins:
		vec.append({"m_coinType": int(pair[0]), "m_value": int(pair[1])})
	_send("TradeMessage.BuyGoodsMessage", {"m_type": kind, "m_info": {"m_goodsId": goods, "m_coinType": coin, "m_price": price, 
		"m_count": clampi(count, 1, 9999 if kind == 8 else 999)}, "m_coinVec": vec})
	return true


func use_halo(uuid: String, halo: int) -> bool:
	if not _tank_ready(uuid) or halo < 0:
		return false
	_send("TankMessage.RequestUseTankHalo", {"m_sTankUUID": uuid, "m_nHaloId": halo})
	return true

func _tank_body(uuid: String) -> StreamPeerBuffer:
	var body: StreamPeerBuffer = StreamPeerBuffer.new()
	body.big_endian = false
	var text: PackedByteArray = uuid.to_utf8_buffer()
	body.put_u16(text.size())
	body.put_data(text)
	return body



func level_up_tank(uuid: String) -> bool:
	if not _tank_ready(uuid):
		return false
	_send_raw(203, _tank_body(uuid).data_array)
	return true



func strengthen_tank(uuid: String) -> bool:
	if not _tank_ready(uuid):
		return false
	var body: StreamPeerBuffer = _tank_body(uuid)
	body.put_u32(0)
	_send_raw(204, body.data_array)
	return true



func _pair_start(value: Dictionary) -> void :
	var picks: Dictionary = {}
	for brief: Dictionary in value.get("m_charData", []):
		var other: Dictionary = brief.get("otherData", {})
		picks[int(brief.charData.nAcctId)] = {"tank": int(other.get("tankId", 0)), "ext": int(other.get("tankExternal", 0)), 
			"frame": int(other.get("skinFrameType", 0)), "level": int(other.get("tankLevel", 0)), "halo": int(other.get("haloId", 0))}
	var locked: Dictionary = {}
	for oid in value.get("m_lockCharIdVec", []):
		locked[int(oid)] = true
	pair_scene = {"scene": int(value.get("m_nSceneId", 0)), "map": int(value.get("m_nMapId", 0)), "type": int(value.get("m_type", 0)), 
		"chars": (value.get("m_charData", []) as Array).duplicate(true), "locked": locked, "picks": picks, 
		"time": int(value.get("m_nTime", 0)), "at": Time.get_ticks_msec(), 


		"turn": {}, "shown": picks.duplicate(true), "all_at": 0}



func _receive_weekly(body: PackedByteArray) -> void :
	var data: Variant = SafeJson.parse(body.get_string_from_utf8())
	if data is Dictionary and data.get("offers") is Dictionary:
		weekly_tanks = (data.offers as Dictionary).duplicate(true)


func weekly_row(tank: int, now: int) -> Dictionary:
	var row: Variant = weekly_tanks.get(str(tank))
	if row is Dictionary and float(row.get("endAt", 0)) > now:
		return row
	return {}

const RKP1_EMPTY_SEAT: bool = true

func _pair_pick(type: int, value: Dictionary) -> void :
	var oid: int = int(value.get("m_nCharOid", 0))
	var pick: Dictionary = pair_scene.picks.get(oid, {"tank": 0, "ext": 0, "frame": 0, "level": 0, "halo": 0})
	if int(pick.get("tank", 0)) != int(value.get("m_nTankId", 0)):
		pick.level = 0
		pick.ext = 0
	pick.tank = int(value.get("m_nTankId", 0))
	if type == 1727:
		pick.ext = int(value.get("m_nTankExt", 0))
		pick.frame = int(value.get("m_nSkinFrameType", 0))


		if RKP1_EMPTY_SEAT and int(pick.tank) <= 0 and pair_scene.has("shown") and not bool(pair_scene.get("locked", {}).get(oid, false)):
			pair_scene.shown[oid] = pick.duplicate()
	else:
		var fresh: bool = not bool(pair_scene.locked.get(oid, false))
		pair_scene.locked[oid] = true

		if fresh and pair_scene.has("turn") and not (pair_scene.turn as Dictionary).is_empty():
			pair_scene.turn["done"] = int(pair_scene.turn.get("done", 0)) + 1
		if pair_scene.has("shown"):
			pair_scene.shown[oid] = pick.duplicate()
		if fresh and pair_all_locked():
			pair_scene["all_at"] = Time.get_ticks_msec()
	pair_scene.picks[oid] = pick

func leave_room() -> void :
	pair_scene.clear()
	if state == "room":
		_leave_sent_at = Time.get_ticks_msec()
		room_op(1)



func room_op(op: int, target: int = 0) -> void :
	if _room_action > 0:
		return
	_room_action = 0.3
	_send("RoomMessage.RequestRoomOp", {"m_roomOp": op, "m_nTarget": target})



const ROPT_PASSWORD: int = 23



const ROPT_CLOSE: int = 21
const ROPT_OPEN: int = 22
func room_seat(op: int) -> bool:
	if state != "room" or not room_state.is_host() or op not in [ROPT_CLOSE, ROPT_OPEN]:
		return false
	room_op(op)
	return true
func room_password(code: int) -> bool:
	if state != "room" or not room_state.is_host() or code < 0 or code > 999999 or (code != 0 and str(code).contains("0")):
		return false
	room_op(ROPT_PASSWORD, code)
	return true




const ROPT_KICKOUT: int = 20
const KICK_ROOMS: Array = [1, 2, 4, 9]

const KICKED_TIP: String = "Bạn bị[@name@] kick khỏi room"
func kick(id: int) -> bool:
	if state != "room" or not room_state.is_host() or id <= 0 or id == room_state.self_id or not (room_state.members.has(id) or (tournament_room() and room_observers.has(id))):
		return false
	if int(room_state.room.get("m_bType", 0)) not in KICK_ROOMS:
		return false
	room_op(ROPT_KICKOUT, id)
	return true





const GIAIDAU1_MODE: int = 20
const ROPT_TO_OB: int = 9
const ROPT_TO_NORMAL: int = 10
func tournament_room() -> bool:
	return int(room_state.room.get("m_bType", 0)) == 1 and int(room_state.room.get("m_mode", 0)) == GIAIDAU1_MODE


static func tournament_row(row: Dictionary) -> bool:
	return int(row.get("m_type", 0)) == 1 and int(row.get("m_mode", 0)) == GIAIDAU1_MODE


func room_watching() -> bool:
	return tournament_room() and room_observers.has(account_oid) and not room_state.members.has(account_oid)


func seat_watch(watch: bool) -> void :
	if state == "room" and tournament_room():
		room_op(ROPT_TO_OB if watch else ROPT_TO_NORMAL)


func give_host(id: int) -> void :
	if state == "room" and room_state.is_host() and id > 0 and id != room_state.self_id:
		room_op(26, id)


func solo_battle() -> bool:
	return battle.room_type == 4 and room_state.room.is_empty()



const PVP_RESULT_ROOMS: Array = [1, 2, 9, 11, 13, 15, 16, 17, 18, 19]


func pvp_result() -> bool:
	return state == "battle" and battle.ended and battle.room_type in PVP_RESULT_ROOMS and not solo_battle()


const PVE_RESULT_MAPS: Array = [2, 11, 16]
const PVE_AWARDS: Array = [1, 14]
func pve_result_map(map_id: int) -> bool:
	return int(MapText.map_info(map_id).get("type", 0)) in PVE_RESULT_MAPS


func pve_result_board() -> bool:
	return state == "battle" and battle.ended and not battle.look and pve_result_map(battle.map_id)




func _pve_result_back() -> bool:
	if not pve_result_board():
		return false
	battle.active = false
	map_fetch = false
	if room_state.room.is_empty():
		state = "lobby"
		status = "Đã về sảnh."
		var row: Variant = PveHallAtlas.MAPS.get(str(battle.map_id), [])
		if battle.cosmic == 0 and row is Array and (row as Array).size() > 2 and int(row[2]) <= 1:
			pve_return = maxi(1, battle.map_id)
	else:
		state = "room"
		status = "Đã về phòng."
		if not room_state.is_host():
			pve_room_op(3)
	changed.emit()
	return true


func pve_result_held() -> bool:
	return _exit_held and pve_result_board()


func exit_battle_to_lobby() -> void :
	if pvp_result():
		leave_battle(3)


func leave_battle(kind: int = 2) -> void :
	if state == "battle" and _exit_held:
		_exit_held = false
		if _pve_result_back():
			return
		battle.active = false
		map_fetch = false
		state = "lobby"
		status = "Đã về sảnh."
		changed.emit()
		return
	if state == "battle" and _room_action <= 0:
		_room_action = 1
		_exit_main = kind == 3
		_send("RoomMessage.RequestExitBattleEnd", {"m_type": 3 if kind == 3 else 2})



const PAIR_AGAIN_OK: bool = true
func pair_again() -> bool:
	if not PAIR_AGAIN_OK or state != "battle" or not battle.ended or _room_action > 0:
		return false
	_room_action = 1
	_exit_main = false
	_pair_again_at = Time.get_ticks_msec()
	_send("RoomMessage.RequestExitBattleEnd", {"m_type": 1})
	return true

func complete_battle_load() -> void :
	if state == "battle" and not _load_acked:
		_load_pending = true


func load_done() -> bool:
	return _load_acked or _load_pending


func report_load(percent: int) -> void :
	percent = clampi(percent, 0, 99)
	if state == "battle" and not _load_acked:

		battle.load_rates[account_oid] = {"loaded": maxi(percent, int(battle.load_rates.get(account_oid, {}).get("loaded", 0))), "delay": maxi(0, latency_ms)}
	if state == "battle" and not _load_acked and percent >= _load_reported + 10:
		_load_reported = percent
		_send("RoomMessage.SyncLoadAndDelay", {"m_nSceneId": battle.scene_id, "m_nTankId": account_oid, "m_nDelay": clampi(latency_ms, 0, 9999), "m_nLoaded": percent})

func finish_map_fetch(ok: bool) -> void :
	if not map_fetch:
		return
	map_fetch = false
	if not ok and state == "battle":
		status = "Bản đồ chưa chuyển đổi"
		complete_battle_load()
	changed.emit()




func bcm1_retry_map(wants: bool) -> bool:
	if state != "battle" or map_fetch or not wants or not battle.active or battle.ended or battle.supported():
		return false
	var now: int = Time.get_ticks_msec()
	if _bcm1_tries >= BCM1_TRIES or now - _bcm1_at < BCM1_GAP_MS:
		return false
	_bcm1_tries += 1
	_bcm1_at = now
	map_fetch = true
	status = "Đang tải bản đồ…"
	return true

func bcm1_tries() -> int:
	return _bcm1_tries

func move_battle(direction: int) -> void :
	if bg_hidden:
		direction = 8
	battle.held_direction = direction
	var request: Dictionary = battle.next_move(direction)
	if state == "battle" and not request.is_empty():
		_send("MovementMessage.RequestMoveForward", request)


func _receive_option(text: String) -> void :
	var data: Variant = SafeJson.parse(text) if not text.is_empty() else null
	var slots: Array[int] = []
	_key_board_set = []
	if data is Dictionary:
		if data.get("skillSlot") is Array:
			for item in data["skillSlot"]:
				if (item is float or item is int) and not int(item) in slots:
					slots.append(int(item))
		if data.get("keyBoardSet") is Array:
			for item in data["keyBoardSet"]:
				if item is String:
					_key_board_set.append(item)
	smart_slots = slots
	key_map = _parse_key_map(_key_board_set)
	option_ready = true


static func _parse_key_map(entries: Array) -> Dictionary:
	var map: Dictionary = {}
	for item in entries:
		var pair: PackedStringArray = str(item).split("-")
		if pair.size() == 2 and pair[0].is_valid_int() and pair[1].is_valid_int():
			map[int(pair[0])] = int(pair[1])
	for code: int in KEY_DEFAULT:
		if not map.has(code):
			map[code] = code
	return map



func key_action(code: int) -> int:
	if code <= 0:
		return 0
	var map: Dictionary = key_map if not key_map.is_empty() else _parse_key_map([])
	for action: int in map:
		if int(map[action]) == code:
			return action
	return 0 if map.has(code) else code




func change_setting(flags: int) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or not character.has("setting_flag"):
		return false
	character["setting_flag"] = flags & 4294967295
	_send("CharMessage.RequestChangeSetting", {"m_setting": int(character["setting_flag"])})
	changed.emit()
	return true



func protect_pwd_op(op: int, pwd: String = "", change: String = "") -> bool:
	if _role != "gate" or _phase != "world" or op < 1 or op > 7:
		return false
	_send("CharMessage.RequestProtectPwdOp", {"m_nOpType": op, "m_strPwd": pwd, "m_strPwdChange": change})
	return true



func select_tutor_map(id: int) -> bool:
	if _role != "gate" or _phase != "world" or state != "lobby" or id <= 0:
		return false
	_send("ChapterMessage.RequestSelectTutorMap", {"m_nMapId": id})
	return true



func buy_thew(coins: Array) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or coins.is_empty():
		return false
	var vec: Array = []
	for pair in coins:
		if not (pair is Array) or (pair as Array).size() < 2 or int(pair[0]) not in [1, 3] or int(pair[1]) <= 0:
			return false
		vec.append({"m_coinType": int(pair[0]), "m_value": int(pair[1])})
	_send("CharMessage.RequestBuyThew", {"m_coinVec": vec})
	return true




func hire_tank(tank_id: int, level: int, hours: int, coin_type: int, price: int, vip_free: int = 0) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or battle.active:
		return false
	if tank_id <= 0 or level <= 0 or hours <= 0 or coin_type not in [1, 2, 3] or price < 0:
		return false
	var body: PackedByteArray = PackedByteArray()
	body.resize(21)
	body.encode_u32(0, tank_id)
	body.encode_u32(4, level)
	body.encode_u32(8, hours)
	body.encode_u32(12, coin_type)
	body.encode_u32(16, price)
	body.encode_u8(20, clampi(vip_free, 0, 1))
	_send_raw(202, body)
	return true




func present_hire(tank_id: int, level: int, hours: int, price: int, receiver: String) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or battle.active:
		return false
	var name: PackedByteArray = receiver.strip_edges().to_utf8_buffer()
	if tank_id <= 0 or level <= 0 or hours <= 0 or price <= 0 or name.is_empty():
		return false
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	out.big_endian = false
	for v: int in [tank_id, level, hours, price]:
		out.put_u32(v)
	out.put_u16(name.size())
	out.put_data(name)
	_send_raw(209, out.data_array)
	return true





func _receive_mysterious_store(type: int, value: Dictionary) -> bool:
	if type not in [1108, 1109, 1111, 1112]:
		return false
	if int(value.get("m_storeType", value.get("m_ntoreType", 0))) != 1:
		return true
	if type != 1109:
		mysterious_last = int(value.get("m_lastUpdate", 0))
		mysterious_refresh = int(value.get("m_refreshCount", 0))
	if type == 1108:
		mysterious_goods = (value.get("m_storeGoods", []) as Array).duplicate(true)
	elif type == 1109:
		var pos: int = int(value.get("m_itemPos", -1))
		if pos >= 0 and pos < mysterious_goods.size():
			mysterious_goods[pos] = (value.get("m_storeGood", {}) as Dictionary).duplicate(true)
			mysterious_purchased.emit(pos)
	mysterious_rev += 1
	if type == 1112:
		mysterious_enabled.emit()
	return true


func request_mysterious_store() -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or battle.active:
		return false
	var body: PackedByteArray = PackedByteArray()
	body.resize(4)
	body.encode_u32(0, 1)
	_send_raw(256, body)
	return true


func buy_mysterious_store(pos: int, count: int) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or battle.active:
		return false
	if pos < 0 or pos >= mini(6, mysterious_goods.size()) or count < 1 or count > 65535:
		return false
	if count > int(mysterious_goods[pos].get("m_nLeftCount", 0)):
		return false
	var body: PackedByteArray = PackedByteArray()
	body.resize(6)
	body.encode_u16(0, 1)
	body.encode_u16(2, pos)
	body.encode_u16(4, count)
	_send_raw(258, body)
	return true

func buy_mystical(tank_id: int, kind: int) -> bool:
	if _role != "gate" or _phase != "world" or state not in ["lobby", "hall", "room"] or battle.active:
		return false
	if tank_id <= 0 or kind not in [1, 2, 3, 4]:
		return false
	var body: PackedByteArray = PackedByteArray()
	body.resize(8)
	body.encode_u32(0, tank_id)
	body.encode_u32(4, kind)
	_send_raw(259, body)
	return true



func save_char_option(slots: Array[int], keys: Dictionary) -> bool:
	if not option_ready or _role != "gate" or _phase != "world":
		return false
	var clean: Array[int] = []
	for slot: int in slots:
		if slot in [1, 2, 3, 4, 10, 13] and not slot in clean:
			clean.append(slot)
	clean.sort()
	var entries: Array = []
	for action: int in keys:
		if int(keys[action]) != action:
			entries.append("%d-%d" % [action, int(keys[action])])
	smart_slots = clean
	_key_board_set = entries
	key_map = _parse_key_map(entries)
	_send("CharMessage.RequestSetCharOption", {"m_strOption": JSON.stringify({"skillSlot": clean, "keyBoardSet": entries})})
	changed.emit()
	return true


func smart_slot(slot: int) -> bool:
	return slot in smart_slots or (slot in [4, 13] and (4 in smart_slots or 13 in smart_slots))


func set_smart_slot(slot: int, on: bool) -> bool:
	if not option_ready or _role != "gate" or _phase != "world" or not slot in [1, 2, 3, 4, 10, 13]:
		return false
	var slots: Array[int] = smart_slots.duplicate()
	if slot in [4, 13]:
		slot = 13 if 13 in slots else 4
		slots.erase(4)
		slots.erase(13)
	else:
		slots.erase(slot)
	if on:
		slots.append(slot)
	slots.sort()
	smart_slots = slots
	_send("CharMessage.RequestSetCharOption", {"m_strOption": JSON.stringify({"skillSlot": slots, "keyBoardSet": _key_board_set})})
	changed.emit()
	return true

func use_skill(slot: int, aim: Vector2, target_id: int = 0) -> bool:
	if bg_hidden:
		return false
	var request: Dictionary = battle.skill_request(slot, aim, target_id)
	if state != "battle" or request.is_empty():
		return false
	_send("TankMessage.RequestUseSkill", request)
	return true



func cache_skill_dest(dest: Vector2) -> void :
	if bg_hidden:
		return
	if state == "battle" and battle.alive():
		_send("SkillMessage.RequestCacheSkillDestPos", {"m_sceneId": battle.scene_id, 
			"m_destX": clampi(int(dest.x), -32768, 32767), "m_destY": clampi(int(dest.y), -32768, 32767)})


var auto_aim: Vector2 = Vector2.ZERO




func auto_bullet() -> void :
	if state != "battle" or not battle.active or not battle.tanks.has(battle.self_id):
		return
	var me: Dictionary = battle.tanks[battle.self_id]
	var pos: Vector2 = me.pos
	var dest: Vector2 = auto_aim if auto_aim != Vector2.ZERO else pos + Vector2.from_angle(float(me.get("cannon_rot", 0.0))) * 350.0
	_send("SkillMessage.RequestAutoBullet", {"m_sceneId": battle.scene_id, 
		"m_startX": clampi(int(pos.x), -32768, 32767), "m_startY": clampi(int(pos.y), -32768, 32767), 
		"m_destX": clampi(int(dest.x), -32768, 32767), "m_destY": clampi(int(dest.y), -32768, 32767)})




func impeach(target: int, uuid: String, name: String, mask: int) -> bool:
	var happy: bool = state == "battle" and battle.ended and int(battle.room_type) == 100
	if not battle.active or not (pvp_result() or happy) or mask < 1 or mask > 63 or target <= 0 or target == account_oid:
		return false
	if uuid.to_utf8_buffer().size() > 256 or name.to_utf8_buffer().size() > 256:
		return false
	_send("CharMessage.ImpeachBadPlayer", {"m_type": mask, "m_nActId": target, "m_uuid": uuid, "m_name": name})
	return true

func _process(delta: float) -> void :




	var now: float = Time.get_ticks_usec() / 1000.0
	var real: float = (now - _proc_ms) / 1000.0 if _proc_ms > 0 else delta
	var spent: float = delta if absf(_skew + real - delta) < 0.004 else real + _skew
	_skew += real - spent
	delta = clampf(spent, 0.0, 0.5)
	_proc_ms = now
	if real > RA1_GAP_S and _channel != null:
		_ra1_resync("gap %d s" % int(real))
	_rc_tick()
	if wifi4g.tick(_rc_ms(), _rc_until > 0):
		_w4g_lost()
	_room_action = maxf(0, _room_action - delta)
	_mw_page_check()
	_kphim1_tick(delta)
	if not pair_confirm.is_empty():
		pair_flush()
	if not pairing.is_empty():
		_pair_watch()
	if not room_hold.is_empty():
		_room_hold_tick()
	if battle.active:
		battle.tick(delta)

	for request: Dictionary in battle.step_requests:
		if state == "battle" and _channel != null:
			_send("MovementMessage.RequestMoveForward", request)
	battle.step_requests.clear()
	if _channel == null:
		return
	_pf_poll()
	if _channel == null:
		return
	if int(_channel.get("flood") if _channel.get("flood") != null else 0) > 0:
		_ra1_resync("flood %s" % str(_channel.get("backlog")))
		if _channel == null:
			return
	if _load_pending:
		_load_pending = false
		_load_acked = true
		_load_acked_at = Time.get_ticks_msec()
		battle.load_rates[account_oid] = {"loaded": 100, "delay": maxi(0, latency_ms)}

		_send("RoomMessage.SyncLoadAndDelay", {"m_nSceneId": battle.scene_id, "m_nTankId": account_oid, "m_nDelay": 0, "m_nLoaded": 100})
	elif _load_acked and _load_resent < LOAD_RESENDS and state == "battle" and battle.active and not battle.started and not battle.ended\
	and not battle.look and Time.get_ticks_msec() - _load_acked_at >= LOAD_RESEND_MS:
		_load_resent += 1
		_load_acked_at = Time.get_ticks_msec()
		_send("RoomMessage.SyncLoadAndDelay", {"m_nSceneId": battle.scene_id, "m_nTankId": account_oid, "m_nDelay": 0, "m_nLoaded": 100})

	if pwd_has and pwd_ticket > 0 and pwd_ticket < int(Time.get_unix_time_from_system()) and _phase == "world"\
	and Time.get_ticks_msec() / 1000.0 - _pwd_auto_at > 10.0:
		_pwd_auto_at = Time.get_ticks_msec() / 1000.0
		protect_pwd_op(2)

	if not bag_loaded and _bag_tries < 4 and not currency.is_empty() and Time.get_ticks_msec() / 1000.0 - _bag_asked > 3.0:
		request_bags()
	if _bags_stale and not battle.active and _role == "gate" and _phase == "world" and state in ["lobby", "hall", "room"]:
		_bags_stale = false
		request_bags()
	if state == "hall":
		_hall_poll += delta
		if _hall_poll >= 5.0:
			refresh_rooms()

	if not _pending_character.is_empty() and state != "lobby":
		var uuid: String = _pending_character
		char_uuid = uuid
		_pending_character = ""
		state = "connecting"
		_deadline = 0.0
		status = "Đang vào sảnh…"
		_send("WorldMessage.WorldEnterMessage", {"m_char_uuid": uuid, "m_loginId": "", 
			"m_accountId": 0, "m_strEnterKey": "", "m_bIsFirstLogin": 0})
		changed.emit()
	_deadline += delta
	_idle += delta
	_ping += delta
	if state == "connecting" and _deadline > config.direct_seconds and _wsd_fall():
		return
	if (state == "connecting" and _deadline > config.timeout_seconds) or _idle > IDLE_LIMIT:
		if not _rc_begin("Kết nối quá thời gian chờ.", "TIMEOUT"):
			_fail("Kết nối quá thời gian chờ.", "TIMEOUT")
	elif _role == "gate" and _phase != "connect" and _phase != "version" and _ping >= config.ping_seconds:
		_ping = 0.0
		_ping_sent = Time.get_ticks_msec()
		_send("SystemMessage.RequestPing", {})
		if state == "battle" and not OS.has_feature("web"):
			_pf_flush()

func _on_end(reason: String) -> void :
	if _pf_head < _pf_queue.size():

		var stream: Frames = _frames
		_pf_drain(stream, false)
		if _frames != stream or _channel == null:
			return
	if _wsd_fall():
		return
	if not _rc_begin(reason, "DISCONNECTED"):
		_fail(reason, "DISCONNECTED")

func _close_channel() -> void :
	_pf_queue.clear()
	_pf_head = 0
	if _channel != null:
		_channel.opened.disconnect(_on_opened)
		_channel.bytes_received.disconnect(_on_bytes)
		_channel.ended.disconnect(_on_end)
		_channel.stop()
		_channel = null

func logout() -> void :
	_close_channel()
	if _wsd_old:
		_wsd_old = false
		config.direct_off = false
	if auth != null:
		auth.cancel()
	_token = ""
	_session = 0
	_has_login = false
	account.clear()
	region.clear()
	characters.clear()
	character.clear()
	currency.clear()
	technologies.clear()
	ladder_old = 0
	tanks.clear()
	old_skins.clear()
	bags.clear()
	bag_loaded = false
	skin_chips.clear()
	_skin_filmed.clear()
	_chip_asked.clear()
	skin_chip_rev += 1
	smart_slots = [1, 2, 3, 4, 10, 13]
	option_ready = false
	_key_board_set = []
	key_map = {}
	crystal_schemes = {}
	crystal_names = {}
	crystal_free_at = 0
	crystal_loaded = false
	quests = {}
	quests_loaded = false
	stages = {}
	acts = {}
	stages_cleared = {}
	stage_progress = {}
	quest_rev += 1
	bonfire_count = 0
	bonfire_add = 0
	bonfire_param = 0
	bonfire_completed = 0
	bonfire_rev += 1
	_bonfire_subscribed = false
	sign_in = {}
	challenge = {}
	challenge_loaded = false
	challenge_rev += 1
	mystic_tank = 0
	mystic_end = 0
	mysterious_goods = []
	mysterious_last = 0
	mysterious_refresh = 0
	mysterious_acts = []
	mysterious_rev += 1
	limits = {}
	event_rev += 1
	mails.clear()
	mail_bodies.clear()
	mail_unread = 0
	mail_loaded = false
	mail_rev += 1
	bag_rev += 1
	sprays.clear()
	honors.clear()
	honors_worn.clear()
	achievements.clear()
	_bag_asked = -10.0
	_bag_tries = 0
	_bags_stale = false
	unknown_ids.clear()
	ignored_layouts.clear()
	room_state.clear()
	room_observers.clear()
	_held_mates = {}
	battle.clear()
	pair_scene.clear()
	pairing.clear()
	pair_confirm.clear()
	_quick_end()
	_pair_again_at = -100000
	weekly_tanks.clear()
	_talent_reset()
	room_invite.clear()
	guild_team_invite.clear()
	chat_log.clear()
	chat_rev += 1
	_whisper.clear()
	whisper_to.clear()
	_players_sent.clear()
	friends.clear()
	friends_loaded = false
	blacks.clear()
	friend_suggestions.clear()
	friend_applies.clear()
	friend_apply_count = 0
	friend_rev += 1
	char_states.clear()
	master.clear()
	master_rev += 1
	_friend_pending = ""
	_invites.clear()
	_clear_guild()
	_guild_asked = -10.0
	world_boss.clear()
	world_boss_return = false
	guild_boss = {"live": false}
	guild_boss_awards = []
	guild_boss_feed = []
	guild_boss_return = false
	pve_cities.clear()
	pve_records.clear()
	_pve_record_wait.clear()
	pve_scenes.clear()
	pve_sweep_awards = []
	pve_sweep_rev += 1
	pve_return = 0
	pve_rev += 1
	league_url = ""
	league_rev += 1
	league_enroll_code = -1
	fire_ball_tanks = []
	act_return = false
	hall_room = 100
	ladder_return = false
	hall_type = 2
	team_match = {}
	_team_polled_at = -100000
	_team_armed = false
	_load_pending = false
	_load_acked = false
	_load_resent = 0
	map_fetch = false
	account_id = 0
	account_oid = 0
	first_charge = 0
	pwd_has = false
	pwd_lock = true
	pwd_ticket = 0
	_pwd_auto_at = -100.0
	ping_count = 0
	_pending_character = ""
	creating = false
	_create_sent = false
	if not _rc_inner:
		Auth.forget_voice()
		_pwd_tiped = false
		_rc_token = ""
		_rc_key = ""
		_rc_until = 0
		_rc_next = 0
		_rc_auth = false
	state = "login"
	status = "Đăng nhập để chơi."
	error_code = ""
	changed.emit()

func _fail(message: String, code: String) -> void :
	logout()
	status = message
	error_code = code
	changed.emit()







const RC_BATTLE: bool = false






const RC_DONE: Array[String] = ["hall", "room", "battle"]
static var rc_battle: bool = true
const RC_CODES: Array[int] = [1006, -1]
const RC_MAX: int = 5
const RC_WINDOW_MS: int = 300000
const RC_LIMIT_MS: int = 120000
const RC_WAIT_MS: Array[int] = [1000, 4000, 8000, 15000, 30000]
const RC_STATUS: String = "Mất kết nối, đang kết nối lại…"
var rc_clock: Callable
var _rc_token: String = ""
var _rc_key: String = ""
var _rc_tries: Array[int] = []
var _rc_until: int = 0
var _rc_next: int = 0
var _rc_n: int = 0
var _rc_auth: bool = false
var _rc_inner: bool = false
var _rc_reason: String = ""
var _rc_code: String = ""
var _rc_uuid: String = ""
var wifi4g: Wifi4g = Wifi4g.new()

func _rc_ms() -> int:
	return int(rc_clock.call()) if rc_clock.is_valid() else Time.get_ticks_msec()

func reconnecting() -> bool:
	return _rc_until > 0


func _rc_begin(message: String, code: String) -> bool:
	if code == "DISCONNECTED":
		var value: Variant = _channel.get("close_code") if _channel != null else null
		if value == null or int(value) not in RC_CODES:
			return false
	elif code != "TIMEOUT":
		return false
	if _rc_until <= 0:
		if _rc_token.is_empty() or _role != "gate" or _phase != "world" or not _rc_allowed() or _rc_left() <= 0:
			return false
		_rc_until = _rc_ms() + RC_LIMIT_MS
		_rc_n = 0
		_rc_reason = message
		_rc_code = code
		_rc_uuid = char_uuid
		if _rc_left() < RC_MAX:
			config.direct_off = true
	_rc_wait()
	return true

func _rc_allowed() -> bool:
	if rc_battle:
		return true
	return state in ["lobby", "hall"] and not battle.active and room_state.room.is_empty() and pair_scene.is_empty()\
	and pair_confirm.is_empty() and not loading_held and not _load_pending


func _rc_left() -> int:
	var now: int = _rc_ms()
	var kept: Array[int] = []
	for at: int in _rc_tries:
		if now - at < RC_WINDOW_MS:
			kept.append(at)
	_rc_tries = kept
	return RC_MAX - _rc_tries.size()


func _rc_wait() -> void :
	_rc_inner = true
	logout()
	_rc_inner = false
	_rc_auth = false
	if _rc_n >= RC_WAIT_MS.size() or _rc_left() <= 0 or _rc_token.is_empty() or _rc_ms() >= _rc_until:
		_rc_give_up()
		return
	_rc_next = _rc_ms() + RC_WAIT_MS[_rc_n]
	state = "connecting"
	status = RC_STATUS
	changed.emit()

func _rc_tick() -> void :
	if _rc_until <= 0:
		return
	if _phase == "world" and (state == "lobby" or (rc_battle and state in RC_DONE)):
		_rc_until = 0
		_rc_next = 0
		return
	if _rc_ms() >= _rc_until:
		_rc_give_up()
	elif _rc_next > 0 and _rc_ms() >= _rc_next:
		_rc_try()

func _rc_try() -> void :
	_rc_next = 0
	if _rc_left() <= 0 or _rc_token.is_empty():
		_rc_give_up()
		return
	_rc_tries.append(_rc_ms())
	_rc_n += 1
	_rc_auth = true
	state = "connecting"
	status = "Đang kết nối lại… (lần %d/%d)" % [_rc_n, RC_WAIT_MS.size()]
	changed.emit()
	auth.resume(config.origin, _rc_token, _rc_key)

func _rc_on_auth(result: Dictionary) -> void :
	_rc_auth = false
	if not result.get("ok", false):
		if str(result.get("code", "")) in ["NETWORK", "RESPONSE"]:
			_rc_wait()
		else:
			_fail(str(result.get("error", "Phiên nối lại đã hết hạn, vui lòng đăng nhập lại")), str(result.get("code", "")))
		return
	account = result["account"].duplicate()
	_token = result["authToken"]
	_rc_token = str(result.get("resumeToken", ""))
	server = config.server_entry()
	_connect_role("login")





func _w4g_lost() -> void :
	if _rc_until > 0:
		if not _rc_auth and _rc_next > 0:
			_rc_next = _rc_ms()
		return
	if _channel == null or not _rc_begin("Mất kết nối với máy chủ.", "TIMEOUT"):
		return
	_rc_next = _rc_ms()
	status = Wifi4g.STATUS
	changed.emit()





const RA1_GAP_S: float = 20.0
const RA1_HOLD_MS: int = 60000
const RA1_PVE_ROOMS: Array = [3, 4, 8]
const RA1_STATUS: String = "Đang đồng bộ lại trận…"
var _ra1_at: int = 0
var ra1_last: String = ""

func _ra1_resync(why: String) -> bool:
	if _rc_until > 0 or _channel == null or _phase != "world" or state != "battle" or not battle.active or not battle.started or battle.ended:
		return false
	if int(battle.room_type) in RA1_PVE_ROOMS:
		return false
	var at: int = _rc_ms()
	if _ra1_at > 0 and at - _ra1_at < RA1_HOLD_MS:
		return false
	_ra1_at = at
	ra1_last = why
	print("ra1c đồng bộ lại trận: ", why)
	if not _rc_begin("Mất kết nối với máy chủ.", "TIMEOUT"):
		return false
	_rc_next = _rc_ms()
	status = RA1_STATUS
	changed.emit()
	return true

func _rc_give_up() -> void :
	var message: String = _rc_reason if not _rc_reason.is_empty() else "Mất kết nối với máy chủ."
	var code: String = _rc_code if not _rc_code.is_empty() else "DISCONNECTED"
	_rc_until = 0
	_rc_next = 0
	_fail(message, code)

func _exit_tree() -> void :
	_close_channel()








signal talent_changed(kind: String, uuid: String)

const TALENT_OP_ADD: int = 1
const TALENT_OP_SAVE: int = 2
const TALENT_OP_RESET: int = 3
const TALENT_OP_DEL: int = 4
const TALENT_OP_SET_CUR: int = 5
const TALENT_OP_ALL_PAGE: int = 6
const TALENT_OP_COPY: int = 7
const TALENT_TANK_OP: int = 20
const TALENT_FLAG: int = 1
const TALENT_SAVED: String = "Đã lưu"
const TALENT_DEFAULT_NAME: String = "Kỹ Thuật mặc định"
const TALENT_ASK_GAP_MS: int = 3000

var talent_pages: Array = []
var talent_total_point: int = 0
var talent_buy_count: int = 0
var talent_ready: bool = false
var talent_rev: int = 0
var _talent_asked_ms: int = 0


func talent_open() -> bool:
	return (int(character.get("actionFlag", 0)) & TALENT_FLAG) != 0


func talent_request_all() -> void :
	var now: int = Time.get_ticks_msec()
	if _talent_asked_ms > 0 and now - _talent_asked_ms < TALENT_ASK_GAP_MS:
		return
	if _talent_send("TalentMessage.RequestOpTalentPage", {"opType": TALENT_OP_ALL_PAGE, "strPageUuid": "", "tankUuid": ""}):
		_talent_asked_ms = maxi(1, now)


func talent_add_page(name: String, buy_type: int = 0) -> void :
	_talent_send("TalentMessage.RequestAddTalentPage", {"strPageName": name, "nBuyType": clampi(buy_type, 0, 255)})


func talent_save_page(page: Dictionary) -> void :
	var tree: Array = []
	for cell: Variant in page.get("tree", []):
		if cell is Array and cell.size() >= 2:
			tree.append({"nTalentId": clampi(int(cell[0]), 0, 4294967295), "nLevel": clampi(int(cell[1]), 0, 65535)})
	if tree.size() > 65535:
		return
	_talent_send("TalentMessage.RequestSaveTalentPage", {"talentPage": {"strUuid": str(page.get("uuid", "")), 
		"strPageName": str(page.get("name", "")), "talentTree": tree, "nCreateTime": clampi(int(page.get("ct", 0)), 0, 4294967295)}})


func talent_op(op: int, page_uuid: String, tank_uuid: String = "") -> void :
	if op == TALENT_OP_ALL_PAGE:
		talent_request_all()
		return
	_talent_send("TalentMessage.RequestOpTalentPage", {"opType": clampi(op, 0, 4294967295), "strPageUuid": page_uuid, "tankUuid": tank_uuid})



func talent_page_of_tank(tank_uuid: String) -> Dictionary:
	if talent_pages.is_empty():
		return {}
	var inst: Dictionary = tanks.get(tank_uuid, {})
	var page: Dictionary = talent_page(str(inst.get("talPageUuid", inst.get("m_talPageUuid", ""))))
	return page if not page.is_empty() else talent_pages[0]


func talent_page(uuid: String) -> Dictionary:
	if uuid.is_empty():
		return {}
	for page: Dictionary in talent_pages:
		if str(page.uuid) == uuid:
			return page
	return {}


static func talent_page_name(page: Dictionary) -> String:
	var name: String = str(page.get("name", ""))
	return name if not name.is_empty() else TALENT_DEFAULT_NAME

func _talent_send(short_name: String, fields: Dictionary) -> bool:
	if _phase != "world" or _channel == null:
		return false
	_send(short_name, fields)
	return true


static func _talent_from(raw: Dictionary) -> Dictionary:
	var tree: Array = []
	for grid: Dictionary in raw.get("talentTree", []):
		tree.append([int(grid.get("nTalentId", 0)), int(grid.get("nLevel", 0))])
	return {"uuid": str(raw.get("strUuid", "")), "name": str(raw.get("strPageName", "")), "tree": tree, "ct": int(raw.get("nCreateTime", 0))}



func _talent_put(page: Dictionary) -> void :
	for i in range(talent_pages.size()):
		if str(talent_pages[i].uuid) == str(page.uuid):
			if int(talent_pages[i].ct) == int(page.ct):
				talent_pages[i] = page
				return
			talent_pages.remove_at(i)
			break
	var at: int = talent_pages.size()
	while at > 0 and int(talent_pages[at - 1].ct) > int(page.ct):
		at -= 1
	talent_pages.insert(at, page)


func _receive_talent(type: int, value: Dictionary) -> bool:
	match type:
		1150:
			for tank: Variant in value.get("m_tankVec", []):
				if tank is Dictionary:
					tank["talPageUuid"] = str(tank.get("m_talPageUuid", ""))
			return false
		1151:
			var inst: Variant = value.get("m_tankInst", {})
			if not inst is Dictionary:
				return false
			inst["talPageUuid"] = str(inst.get("m_talPageUuid", ""))
			if int(value.get("m_opType", 0)) != TALENT_TANK_OP:
				return false


			var uuid: String = str(inst.get("m_tankUuid", ""))
			if tanks.has(uuid):
				inst["m_extFlag"] = int(tanks[uuid].get("m_extFlag", 0))
			tanks[uuid] = inst
			talent_rev += 1
			talent_changed.emit("tank", uuid)
			return true
		1450:
			var page: Dictionary = _talent_from(value.get("talentPage", {}))
			var op: int = int(value.get("opType", 0))
			if op == TALENT_OP_ADD:
				_talent_put(page)
				talent_rev += 1
				talent_changed.emit("add", str(page.uuid))
			elif op == TALENT_OP_SAVE:
				_talent_put(page)
				talent_rev += 1
				talent_changed.emit("save", str(page.uuid))
				noticed.emit(TALENT_SAVED)
			return true
		1451:
			var target: String = str(value.get("strPageUuid", ""))
			var kind: int = int(value.get("opType", 0))
			var known: Dictionary = talent_page(target)
			if kind == TALENT_OP_RESET and not known.is_empty():
				known.tree = []
				talent_rev += 1
				talent_changed.emit("reset", target)
			elif kind == TALENT_OP_DEL and not known.is_empty():
				talent_pages.erase(known)
				talent_rev += 1
				talent_changed.emit("del", target)
			return true
		1452:
			var pages: Array = []
			for raw: Variant in value.get("talentPageVec", []):
				if raw is Dictionary:
					pages.append(_talent_from(raw))
			talent_pages = []
			for page: Dictionary in pages:
				_talent_put(page)
			talent_total_point = int(value.get("talTotalPoint", 0))
			talent_buy_count = int(value.get("buyPageCount", 0))
			talent_ready = true
			_talent_asked_ms = 0
			talent_rev += 1
			talent_changed.emit("info", "")
			return true
		1453:
			talent_total_point = int(value.get("talTotalPoint", 0))
			talent_rev += 1
			talent_changed.emit("point", "")
			return true
	return false


func _talent_reset() -> void :
	talent_pages = []
	talent_total_point = 0
	talent_buy_count = 0
	talent_ready = false
	_talent_asked_ms = 0
	talent_rev += 1
