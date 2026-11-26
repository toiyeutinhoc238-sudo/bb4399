extends RefCounted

const MapData = preload("map_data.gd")
const Text = preload("../i18n.gd")
const TimeOver = preload("../ui/timeover_atlas.gd")
const SkillCellAtlas = preload("../ui/skillcell_atlas.gd")
const DeathRound = preload("../ui/deathround_atlas.gd")
const MinimapMarks = preload("minimap_marks.gd")
const SelfMoveRule = preload("self_move_rule.gd")

const PLAY_ATK: Array[int] = [90303, 90313, 9590001]





const NPC_SKILL_SHOTS: Dictionary = {1000041: [1], 1000006: [17, 18, 19, 35]}
const NPC_SHOT_SPEED: float = 1200.0

const NPC_SHOT_SPEEDS: Dictionary = {1000041: 240.0}
const SKILL_MT_SVR_NOTIFY_STOP: int = 5

const LINK_BULLETS: Array[int] = [352501, 474501, 475501, 391211, 991211, 328401]
const HOOK_BUFF: int = 50357


const TRACE_BULLETS: Array[int] = [300, 301]
const TRACE_PICK: float = 96.0
const LINK_LIFE: float = 20.0



const SPMTN1_BEAM: int = 328401
const SPMTN1_PRE: int = -2000328401
const SPMTN1_PRE_LIFE: float = 1.2
const WRECK_TIME: float = 6.0
const SPRAY_TIME: float = 60.0
const SNEER_TIME: float = 30.0




const SNEER: bool = false
const SPRAY_FADE: float = 1.0




const FACE_HELP: int = 1
const FACE_HIT: Array[int] = [2, 3, 4]
const FACE_RELIVE: int = 7
const FACE_LEVEL: int = 8

const BUFF_STEALTH: Array[int] = [4301, 30105, 305202, 307132, 322201, 322303, 330131, 345403, 358902, 368403, 376111, 384208, 390201, 390304, 
	393311, 401202, 443201, 443303, 444201, 444303, 451403, 452403, 458201, 458303, 470131, 476202, 490902, 510501, 510502, 510503, 
	510504, 510505, 510506, 510507, 510508, 510509, 608403, 651403, 676111, 10001002, 10300072]


const NATSU_E_READY: Array[int] = [365201, 365501, 603201, 603501]
const BUFF_SNEAK: Array[int] = [307132, 322201, 322303, 330131, 390201, 393311, 443201, 443303, 444201, 444303, 458201, 458303, 
	470131, 510501, 510502, 510503, 510504, 510505, 510506, 510507, 510508, 510509]
const BUFF_DISAPPEAR: Array[int] = [310302, 326304, 329304, 330143, 339336, 344104, 349302, 354404, 356302, 357402, 367303, 371306, 371401, 
	375302, 375306, 384311, 384333, 404351, 439336, 450104, 459304, 462304, 463302, 464302, 470143, 471104, 472336, 481404, 482404, 
	485302, 486302, 487402, 488402, 607303, 611302, 612306, 612401, 971306, 971401, 613304, 675302, 675306, 9375306]
const BUFF_REVERSAL: Array[int] = [319311, 380126, 619131, 619302, 680126, 10001381, 10200561, 10200891]


const BUFF_AUTO_MOVE: Array[int] = [50352, 50353, 50354, 50355, 50357, 200005, 303134, 317350, 318305, 318417, 321222, 322341, 322350, 
	325607, 367313, 375407, 383443, 384250, 386313, 443341, 443350, 444341, 444350, 458341, 458350, 607313, 621222, 675407]


const BUFF_CHANNEL_LOCK: Array[int] = [395311]
const BUFF_RADAR: Array[int] = [482, 4302, 40109, 103901, 200002, 200004, 307232, 309206, 311422, 321102, 322202, 325613, 357141, 363308, 
	364308, 379411, 402206, 443202, 444202, 458202, 487141, 488141, 601308, 605308, 621102, 663308, 679411, 979411, 10300063, 
	10300101, 10301023, 10302004]
const SIGHT_HURT: float = 5.0
const STEPS: Array[Vector2] = [Vector2(-24, -24), Vector2(0, -24), Vector2(24, -24), Vector2(24, 0), Vector2(24, 24), Vector2(0, 24), Vector2(-24, 24), Vector2(-24, 0), Vector2.ZERO]
var map: MapData = MapData.new()
var map_loaded: bool = false
var bundled_map4: bool = true
var scene_id: int = 0
var map_id: int = 0
var cosmic: int = 0
var self_id: int = 0
var active: bool = false
var started: bool = false
var sound_cuts: Array = []
const NARSND1_EARLY: float = 0.12
var buff_added: Array = []
var ended: bool = false
var outcome: Dictionary = {}
var tanks: Dictionary = {}
var npcs: Dictionary = {}


var faced: Dictionary = {}
var face_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var face_priority: Callable = Callable()
var bullets: Dictionary = {}
var _local_shots: int = 0
var effects: Array[Dictionary] = []


var shakes: Array[Dictionary] = []

var wrecks: Array[Dictionary] = []

var opened: Array[Dictionary] = []
var npc_open: Callable = Callable()

var sprays: Array[Dictionary] = []
var skills: Dictionary = {}

var ex_unlock: Dictionary = SkillCellAtlas.EX_UNLOCK
var begun: int = 0
var appearances: Dictionary = {}
var names: Dictionary = {}
var stats: Array = []
var red_kills: int = 0
var blue_kills: int = 0
var speed: int = 170
var fire_ms: int = 500
var elapsed: float = 0.0
var server_ms: float = 0.0


var clock_offset: float = NAN

var fire_echoes: Array[int] = []

var skill_known: Callable = Callable()
var still_buff: Callable = Callable()
var warm_still: Callable = Callable()
var _warmed: Dictionary = {}
var normal_shot: Callable = Callable()



const BTK2_HOLD: Dictionary = {305411: 1, 309301: 1, 309401: 1, 315201: 1, 316201: 1, 329301: 2, 339401: 1, 340301: 2, 344201: 1, 346301: 1, 346401: 1, 350211: 1, 351301: 1, 360401: 2, 371131: 1, 379211: 1, 379301: 1, 382201: 1, 385111: 1, 391311: 1, 391411: 1, 401411: 1, 402301: 1, 402401: 1, 439401: 1, 441301: 2, 450201: 1, 465211: 1, 466211: 1, 467301: 1, 468301: 1, 471201: 1, 472401: 1, 476411: 1, 493401: 2, 494401: 2, 525201: 1, 612131: 1, 613301: 2, 617301: 1, 617401: 1, 679211: 1, 679301: 1, 899201: 1, 979211: 1, 979301: 1, 985111: 1, 991311: 1, 991411: 1, 338201: 1, 338311: 1, 413201: 1, 413311: 1, 457201: 1, 457311: 1}



const HLB1_HOLD: Dictionary = {311411: 1}

var skill_flow: Callable = Callable()

var ready_until: float = 0.0



const SELF_CHARGE_SKILLS: Dictionary = {377401: true, 677401: true}
var _charge_wait: Array = []
var _charge_seen: Dictionary = {}

var swapped_slots: Array[int] = []

var cooled_slots: Array[int] = []
const NHEN4_CD_EPS: float = 0.2
var start_ms: float = 0.0
var duration: float = 180.0
var respawn: float = 0.0


var self_killer: Dictionary = {}
var self_spawns: int = 0


var born_seen: Dictionary = {}
var deaths: int = 0
var shots: int = 0
var skill_events: int = 0
var hp_events: int = 0
var syncs: int = 0
var npc_moves: int = 0
var expiry_notices: int = 0

var mode: String = "alive"
var kill_target: int = 0
var max_rounds: int = 0
var a_score: int = 0
var b_score: int = 0
var occupy: Dictionary = {}
var a_wins: int = 0
var b_wins: int = 0

var death_alive: Array = []

var death_round: int = 1
var overtime: bool = false
var overtime_seconds: int = 0
var vote: Dictionary = {}
var vote_next: float = 0.0
var tips: Array[Dictionary] = []
var hit_target: int = 0
var hit_target_at: float = -1000.0
var happy: Dictionary = {}
var happy_first: int = 0
var happy_dethroned: Dictionary = {}
var signals: Array[Dictionary] = []

var qp_on: bool = false
var qp_mute: bool = false
const QP_NAMES: Dictionary = {1: "Tấn công!", 2: "Rút lui!", 3: "Tập trung!", 4: "Cẩn thận!"}
const QP_COLORS: Dictionary = {1: Color("ff6a5a"), 2: Color("ffd24a"), 3: Color("5ad2ff"), 4: Color("ffa040")}

var harms: Array[Dictionary] = []
var harm_last: Dictionary = {}
var battle_exp: int = 0
var clock: float = 0.0


var kills: Array[Dictionary] = []
var kill_tick: float = -1.0


var kill_lines: Array[Dictionary] = []
const KILL_LINES_MAX: int = 40
const KILL_ROW_TIME: float = 5.0
const KILL_ROWS: int = 3
const KILL_MIN_SHOW: int = 3
const PVE_ROOMS: Array[int] = [3, 4, 8, 50, 51, 52, 53, 7, 14]
const NPC_KILL_TYPES: Array[int] = [3, 4, 6]
static var _kill_names: Dictionary = {}
var honors: Array[Dictionary] = []
var numbers: Array[Dictionary] = []
const MULTI_KILL: Array[String] = ["Double Kill", "Killing Spree", "Dominating", "Mega Kill", "Unstoppable", "Wicked Sick", "Monster Kill", "Godlike", "Beyond Godlike"]
const NO_DEAD: Array[String] = ["Đã đạt Triple Kill", "Đã đạt Unstoppable", "đã đạt Mega Kill", "đã đạt Unstoppable", "Đã đạt Wicked Sick", "Đã đạt Monster Kill"]
const END_KILL: Array[String] = ["Triple Kill", "Unstoppable", "Mega Kill", "Unstoppable", "Wicked Sick", "Monster Kill"]

const MULTI_VOICE: Array[String] = ["double_kill", "killing_spree", "dominating", "mega_kill", "unstoppable", "holy_shit", "monster_kill", "god_like", "legendary"]
const STREAK_VOICE: Array[String] = ["triple_kill", "unstoppable", "mega_kill", "unstoppable", "holy_shit", "monster_kill"]

const CHAT_PRIVATE: int = 1
const CHAT_SCENE: int = 32
const CHAT_CAMP: int = 64
const CHAT_COLORS: Dictionary = {1: "f78fec", 32: "e8e8e8", 64: "49ff5e"}
const CHAT_NAMES: Dictionary = {1: "Mật", 32: "Chiến trường", 64: "Bên ta"}
const CHAT_VIP_COLOR: Array[String] = ["48ff5e", "48ff5e", "ff48ec", "ff48ec", "ff48ec", "ffc000", "ffc000", "ffc000", "ffc000", "ffc000"]
var chat: Array[Dictionary] = []



var chat_seq: int = 0
var chat_from: int = 0
var private_chat: Array[Dictionary] = []
var private_until: float = -1.0
var private_tipped: bool = false
var bubbles: Dictionary = {}

var camp_skills: Dictionary = {}
var _local_step: bool = false
var ch1: Dictionary = {"rx": -1.0, "end": -100.0}
var ch1_on: bool = CH1_ON
var cl1_on: bool = CL1_ON
var cl1_buf: bool = _cl1_buf_flag()
var cl1: Dictionary = {"glide": 0, "lerp": 0, "snap": 0, "trim": 0, "catch": 0, "x": 0, "back": 0, "ch1": 0}


var held_direction: int = 8

var step_requests: Array[Dictionary] = []
var move_lock: bool = false

var move_rule: SelfMoveRule = SelfMoveRule.new()



const BUMP_TIME: float = 0.16
const BUMP_AMP: float = 3.0
const BUMP_GAP: float = 0.8
var bump_at: float = -1000.0
var bump_dir: Vector2 = Vector2.ZERO

var buff_show: Callable = Callable()

var roster: Array = []
var room_type: int = 0
var enter_type: int = 0

var load_rates: Dictionary = {}

var tank_ranks: Dictionary = {}

var tank_prof: Dictionary = {}

var load_chat: Dictionary = {}

var talks: Array[Dictionary] = []


const DIALOG_BATTLE: int = 1
const DIALOG_COMPLETE: int = 2
const DIALOG_CUSTOM: int = 4
const DIALOG_TITLE: int = 8
const TIP_105: String = "Xong"
static var _dialog_table: Dictionary = {}



const PVP_AWARDS: Array = [7, 13, 15]
var pvp_award: Dictionary = {}




var score_stats: Dictionary = {}


var tech_rating: Array = []
var chat_muted: Dictionary = {}
var score_a: Array[int] = []
var score_b: Array[int] = []
var score_revs: Array[int] = [0, 0]


var self_counts: Array[int] = [0, 0, 0]



var info_tip: String = "0/0/0"


var dest_shown: bool = false
var dest_text: String = ""
var dest_inited: bool = false
var dest_next: int = 0
var dest_timer: float = -1.0


var time_limit: int = -1
var clock_left: int = 0
var clock_shown: bool = true
var clock_icon: bool = true
var over_shown: bool = false
var clock_running: bool = false
var clock_inited: bool = false

var time_tip: Dictionary = {}



var round_result: Dictionary = {}
var round_count: Dictionary = {}


var trophy_a: int = 0
var trophy_b: int = 0
var death_wait_cut: bool = false


var scroll_id: int = 0
var scroll_jump: int = 0
var watch_shown: bool = false
var watch_name: String = ""
var _watch_index: int = 0
var _watch_dead: float = -1.0
var _watch_click: bool = false



const ENTER_LOOKER: int = 2
const LOOK_PICK: float = 75.0
const LOOK_NONE: String = "Không"
var look: bool = false
var look_oid: int = 0
var look_camp_id: int = 1
var look_target: int = 0
var look_free: bool = false
var look_jump: int = 0
var look_tip_at: float = -1.0
var _look_seen: Dictionary = {}
var _look_refresh: float = 0.0

func clear() -> void :
	scene_id = 0
	map_id = 0
	cosmic = 0
	self_id = 0
	active = false
	started = false
	buff_added.clear()
	ended = false
	outcome.clear()
	tanks.clear()
	faced.clear()
	npcs.clear()
	bullets.clear()
	effects.clear()
	shakes.clear()
	wrecks.clear()
	opened.clear()
	sprays.clear()
	skills.clear()
	appearances.clear()
	names.clear()
	stats.clear()
	red_kills = 0
	blue_kills = 0
	elapsed = 0
	server_ms = 0
	start_ms = 0
	respawn = 0
	self_killer.clear()
	fire_echoes.clear()
	_local_step = false
	move_lock = false
	move_rule.reset()
	bump_at = -1000.0
	ready_until = 0.0
	_charge_wait.clear()
	_charge_seen.clear()
	swapped_slots.clear()
	cooled_slots.clear()
	self_spawns = 0
	born_seen.clear()
	deaths = 0
	shots = 0
	skill_events = 0
	hp_events = 0
	syncs = 0
	npc_moves = 0
	expiry_notices = 0
	mode = "alive"
	kill_target = 0
	max_rounds = 0
	a_score = 0
	b_score = 0
	occupy.clear()
	a_wins = 0
	b_wins = 0
	death_alive = []
	death_round = 1
	overtime = false
	overtime_seconds = 0
	time_limit = -1
	clock_left = 0
	clock_shown = true
	clock_icon = true
	over_shown = false
	clock_running = false
	clock_inited = false
	time_tip = {}
	round_result = {}
	round_count = {}
	trophy_a = 0
	trophy_b = 0
	death_wait_cut = false
	scroll_id = 0
	scroll_jump = 0
	watch_shown = false
	watch_name = ""
	_watch_index = 0
	_watch_dead = -1.0
	_watch_click = false
	look = false
	look_oid = 0
	look_camp_id = 1
	look_target = 0
	look_free = false
	look_tip_at = -1.0
	_look_seen.clear()
	_look_refresh = 0.0
	vote.clear()
	vote_next = 0
	tips.clear()
	hit_target = 0
	hit_target_at = -1000.0
	happy.clear()
	happy_first = 0
	happy_dethroned.clear()
	signals.clear()
	harms.clear()
	harm_last.clear()
	battle_exp = 0
	kills.clear()
	kill_tick = -1.0
	kill_lines.clear()
	honors.clear()
	numbers.clear()
	chat.clear()
	chat_seq = 0
	chat_from = 0
	private_chat.clear()
	private_until = -1.0
	private_tipped = false
	bubbles.clear()
	camp_skills.clear()
	roster.clear()
	room_type = 0
	enter_type = 0
	load_rates.clear()
	tank_ranks.clear()
	load_chat.clear()
	tank_prof.clear()
	talks.clear()
	pvp_award.clear()
	score_stats.clear()
	tech_rating.clear()
	chat_muted.clear()
	score_a.clear()
	score_b.clear()
	score_revs = [score_revs[0] + 1, score_revs[1] + 1]
	self_counts = [0, 0, 0]
	info_tip = "0/0/0"
	dest_shown = false
	dest_text = ""
	dest_inited = false
	dest_next = 0
	dest_timer = -1.0



const COSMIC_BASE: int = 7000
const COSMIC_TIME: int = 300
const COSMIC_MAPS: Dictionary = {
	1: 504, 2: 505, 3: 403, 4: 702, 5: 30103, 6: 404, 7: 211, 8: 703, 9: 504, 10: 31203, 
	11: 302, 12: 702, 13: 31201, 14: 212, 15: 31303, 16: 301, 17: 301, 18: 31501, 19: 211, 20: 31503, 
	21: 502, 22: 701, 23: 31401, 24: 212, 25: 30103, 26: 602, 27: 601, 28: 31201, 29: 502, 30: 31302, 
}


static func cosmic_number(id: int) -> int:
	return id - COSMIC_BASE if COSMIC_MAPS.has(id - COSMIC_BASE) else 0


func title() -> String:
	return "Bí Cảnh Vũ Trụ No.%d" % cosmic if cosmic > 0 else Text.map_name(map_id)

func begin(value: Dictionary, account_oid: int, looks: Dictionary) -> void :
	clear()
	begun += 1
	scene_id = int(value.m_nSceneId)
	cosmic = cosmic_number(int(value.m_nMapId))
	map_id = int(COSMIC_MAPS.get(cosmic, value.m_nMapId))
	self_id = account_oid
	appearances = looks.duplicate(true)
	roster = value.get("m_charData", []).duplicate(true)
	room_type = int(value.get("m_type", 0))
	enter_type = int(value.get("m_bEnterType", 0))
	look = enter_type == ENTER_LOOKER
	active = true
	if map.id != map_id or (map.bundled and not bundled_map4):
		map_loaded = false
	if map_id == 4 and not map_loaded and bundled_map4:
		map_loaded = map.load_map()
	if map_loaded:
		_place_map()


func attach_map(id: int, doc: Dictionary) -> bool:
	if not active or ended or id != map_id:
		return false
	if not map_loaded:
		map_loaded = map.load_document(doc, id)
		if map_loaded:
			_place_map()
	return map_loaded



static func win_target(header_kill: int, info: Dictionary) -> int:
	var win: int = int(info.get("win", 0))
	return win if int(info.get("modeType", 0)) == 3 and win > 0 else header_kill

func _place_map() -> void :
	duration = float(map.document.header.gameSecond)
	time_limit = (COSMIC_TIME * (2 if cosmic % 5 == 0 else 1) if cosmic > 0 else int(TimeOver.MAP_TIME.get(map_id, -1)))
	if not clock_inited:
		clock_left = maxi(0, limit_seconds())
	kill_target = int(map.document.header.get("killNum", 0))
	var info: Dictionary = Text.map_info(map_id)
	max_rounds = int(info.get("rounds", 0))
	for entry: Dictionary in map.static_npcs:
		if started and npcs.has(234881024 | int(entry.nInstanceId)):
			continue
		var row: Dictionary = map.templates.get(str(int(entry.templetId)), {})
		add_npc({"m_objId": 234881024 | int(entry.nInstanceId), "m_tplId": int(entry.templetId), 
			"m_x": entry.iCenterX, "m_y": entry.iCenterY, "m_hp": int(row.get("iHp", -1)), 
			"m_maxHp": int(row.get("iHp", -1)), "m_bCamp": int(entry.iCamp)})

	mode = _mode(int(info.get("modeType", 0)), int(map.document.header.get("gameMode", 0)))
	kill_target = win_target(kill_target, info)
	if int(info.get("type", 0)) == 7:
		mode = "happy"




func _mode(mode_type: int, game_mode: int) -> String:
	if mode_type == 2:
		return "occupy"
	if mode_type in [3, 7, 10]:
		return "alive"
	if mode_type == 4:
		return "death"
	if game_mode == 4:
		return "alive"
	if game_mode == 3:
		return "kill_ai"
	if not map.flags.is_empty():
		return "occupy"
	return "home" if base_camps().size() >= 2 else "alive"


func base_camps() -> Dictionary:
	var result: Dictionary = {}
	for npc: Dictionary in npcs.values():
		if str(map.templates.get(str(npc.template), {}).get("iType", "")) == "3" and int(npc.camp) in [1, 2]:
			result[int(npc.camp)] = npc
	return result


func alive_count(camp: int) -> int:
	var count: int = 0
	for tank: Dictionary in tanks.values():
		if int(tank.camp) == camp and not tank.dead:
			count += 1
	return count



func death_alive_count(camp: int) -> int:
	if death_alive.size() == 2:
		return int(death_alive[0 if camp == 1 else 1])
	return alive_count(camp)



func _throw(v: Dictionary) -> void :
	var obj: Dictionary = actor(int(v.m_nObj))
	if obj.is_empty():
		return
	var from: Vector2 = Vector2(v.m_iStartX, v.m_iStartY)
	var to: Vector2 = Vector2(v.m_iDestX, v.m_iDestY)
	var distance: float = from.distance_to(to)
	obj.throw = {"from": from, "to": to, "t": 0.0, "duration": maxf(0.05, float(v.m_nTime) / 1000.0), 
		"max": 0.6 if distance > 480 else 0.2 * (1 - distance / 480) + 0.6}
	obj.pos = from
	obj.target = to
	obj.server = to
	if int(v.m_bType) == 1 and distance > 1:


		obj.direction = _angle_direction(from, to)
	if int(v.m_nObj) == self_id:
		_local_step = false


static func throw_scale(obj: Dictionary) -> float:
	if not obj.has("throw"):
		return 1.0
	var throw: Dictionary = obj.throw
	return 1.0 + float(throw.max) * sin(clampf(float(throw.t) / float(throw.duration), 0, 1) * PI)


static func _happy_tip(reason: int, gained: int) -> String:
	var amount: String = ("+%d" % gained) if gained > 0 else str(gained)
	match reason:
		4: return "Hạ gục địch %s điểm" % amount
		11: return "Hạ gục người dẫn đầu %s điểm" % amount
		12: return "Nhặt thẻ điểm %s điểm" % amount
		13: return "Chia điểm hạ người dẫn đầu %s điểm" % amount
		14: return "Bị hạ khi đang dẫn đầu %s điểm" % amount
		15: return "Hỗ trợ hạ gục %s điểm" % amount
	return "%s điểm" % amount


func happy_rank(id: int) -> int:
	if int(happy.get(id, 0)) / 1000 <= 0:
		return 0
	var rank: int = 1
	for other: int in happy:
		if other != id and (int(happy[other]) > int(happy[id]) or (int(happy[other]) == int(happy[id]) and other < id)):
			rank += 1
	return rank




func happy_leader() -> int:
	var best: int = 0
	var found: bool = false
	for id: int in happy:
		if not found or int(happy[id]) > int(happy[best]) or (int(happy[id]) == int(happy[best]) and id < best):
			best = id
			found = true
	if found and int(happy[best]) / 1000 > 0 and best != happy_first:
		if happy_first != 0:
			happy_dethroned[happy_first] = true
		happy_dethroned.erase(best)
		happy_first = best
	return happy_first



static func chat_frame(raw: String) -> Dictionary:
	var found: RegExMatch = RegEx.create_from_string("\\[chatframe:([0-9A-Fa-f]{6}):([0-9A-Fa-f]{6}):([0-9A-Fa-f]{6})[^\\]]*\\]").search(raw)
	if found == null:
		return {}
	return {"bg": Color("#" + found.get_string(1)), "border": Color("#" + found.get_string(2)), "fg": Color("#" + found.get_string(3))}

static func chat_text(raw: String) -> String:
	var text: String = RegEx.create_from_string("\\[chatframe:[^\\]]*\\]").sub(raw, "", true)
	text = RegEx.create_from_string("\\[emote:[^\\]]*\\]").sub(text, "(^^)", true)
	text = RegEx.create_from_string("<[^>]*>").sub(text, "", true)
	return text.replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", "\"").replace("&amp;", "&").strip_edges()

func _chat_line(line: Dictionary, sys: bool = false) -> void :
	chat_seq += 1
	line["seq"] = chat_seq
	if sys:
		line["sys"] = true
	chat.append(line)
	if sys:

		if chat.size() > 60:
			var kept: Array[Dictionary] = []
			for i in range(chat.size() - 60, chat.size()):
				kept.append(chat[i])
			chat = kept
		return
	var players: Array[Dictionary] = []
	for one: Dictionary in chat:
		if not one.get("sys", false):
			players.append(one)
	if players.size() > 30:

		chat = players.slice(15)
		chat_from = 0


func chat_clear() -> void :
	chat_from = chat_seq


func chat_shown() -> Array[Dictionary]:
	var shown: Array[Dictionary] = []
	for line: Dictionary in chat:
		if int(line.get("seq", 1 << 30)) > chat_from and not preload("chat_mute.gd").hides(self, line):
			shown.append(line)
	return shown


func receive_chat(message: Dictionary) -> void :
	var contents: Dictionary = message.get("m_contents", {})
	var channel: int = int(contents.get("channel", 0))
	if channel not in [CHAT_PRIVATE, CHAT_SCENE, CHAT_CAMP]:
		return
	var raw: String = str(contents.get("content", ""))
	var text: String = chat_text(raw)
	if text.is_empty():
		return
	var sender: int = int(contents.get("senderOid", 0))
	if sender != self_id and chat_muted.has(sender):
		return
	if qp_on and qp_mute and channel == CHAT_CAMP and sender != self_id and str(contents.get("paramVec", "")).contains("\"qc\""):
		return
	var outgoing: bool = channel == CHAT_PRIVATE and sender == self_id
	var vip: int = int(contents.get("receiverVipLvl" if outgoing else "senderVipLvl", 0)) % 100
	var name: String = str(contents.get("receiver" if outgoing else "sender", ""))
	var line: Dictionary = {"head": "[" + CHAT_NAMES[channel] + "]" + ("Nói với " if outgoing else ""), "name": name, 
		"name_color": Color("#" + CHAT_VIP_COLOR[mini(vip, CHAT_VIP_COLOR.size()) - 1]) if vip > 0 else Color("6b93ee"), 
		"text": ": " + text, "color": Color("#" + CHAT_COLORS[channel]), "raw": raw, "from": sender, "ch": channel}
	if channel == CHAT_PRIVATE:
		if not private_tipped:
			private_chat.append(line)
			private_chat.append({"head": "", "name": "", "name_color": Color.WHITE, "text": "Nhập/r+nội dung trò chuyện có thể trả lời nhanh", "color": Color("00ff00")})
			private_tipped = true
		private_chat.append(line)
		if private_chat.size() > 6:
			private_chat = private_chat.slice(private_chat.size() - 6)
		private_until = clock + 10.0
		return
	_chat_line(line)
	if sender != 0 and not preload("chat_mute.gd").drop_bubble(self, sender, channel):
		var bubble: Dictionary = chat_frame(raw)
		bubble["text"] = text
		bubble["raw"] = raw
		bubble["t"] = clock
		bubble["ch"] = channel
		bubbles[sender] = bubble
		if not started:
			load_chat[sender] = bubble.duplicate()




func receive_bulletin(value: Dictionary) -> void :
	var text: String = chat_text(str(value.get("m_szContent", "")))
	if text.is_empty():
		return
	var pos: int = int(value.get("m_nPos", 0))
	if pos & 1:
		var color: String = str(value.get("m_szColor", "")).trim_prefix("#")
		_chat_line({"head": "", "name": "", "name_color": Color.WHITE, "text": text, "color": Color("#" + color) if color.is_valid_html_color() else Color("ffd700")}, true)


func chat_rejected(text: String) -> void :
	_chat_line({"head": "", "name": "", "name_color": Color.WHITE, "text": text, "color": Color("ffd700")}, true)

func tip(text: String) -> void :
	if tips.size() >= 4:
		tips.pop_front()
	tips.append({"text": text, "age": 0.0})



func _kill_info(info: Dictionary) -> void :
	_kill_text(info)
	_pvp_kill(info)
	var killer: Dictionary = actor(int(info.m_killerObjId))
	var dead: Dictionary = actor(int(info.m_deadObjId))
	if killer.is_empty() and dead.is_empty():
		return
	if not tanks.has(int(info.m_killerObjId)):
		return
	var text: String = ""
	var voice: String = ""
	var cont: int = int(info.get("m_contKillCount", 0))
	var streak: int = int(info.get("m_killerKillCount", 0))
	var ended_streak: int = int(info.get("m_deadKillCount", 0))
	if int(info.get("m_isFirstBlood", 0)) != 0:
		text = "First Blood"
		voice = "firstblood"
	elif cont >= 2:
		text = MULTI_KILL[mini(cont - 2, MULTI_KILL.size() - 1)]
		voice = MULTI_VOICE[mini(cont - 2, MULTI_VOICE.size() - 1)]
	elif ended_streak >= 3:
		text = "Phá bỏ kỷ lục %s của %s" % [END_KILL[mini(ended_streak - 3, END_KILL.size() - 1)], str(dead.get("name", ""))]
	elif streak >= 3:
		text = NO_DEAD[mini(streak - 3, NO_DEAD.size() - 1)]
		voice = STREAK_VOICE[mini(streak - 3, STREAK_VOICE.size() - 1)]
	if text.is_empty():
		return
	if honors.size() >= 4:
		honors.pop_front()


	var victim: int = int(dead.get("account", 0)) if ended_streak >= 3 and cont < 2 and int(info.get("m_isFirstBlood", 0)) == 0 else 0
	honors.append({"text": text, "name": str(killer.get("name", "")), "camp": int(killer.get("camp", 0)), "t": -1.0, "voice": voice, 
		"killer_account": int(killer.get("account", 0)), "dead_account": victim})


const KILL_ROW_HEIGHT: float = 30.0
const KILL_TWEEN: float = 0.5

const KILL_TEXT: Dictionary = {
	1: "@killer@ dùng @item@ diệt @decedent@, được First Blood rồi", 
	2: "@killer@ đã diệt @decedent@", 
	3: "@killer@ dùng @item@ diệt @decedent@", 
	5: "@killer@ đã vô địch", 
	6: "@killer@ đã thành Thống Trị Trận Đấu", 
	7: "@killer@ Không Đối Thủ", 
	8: "@killer@ Vô Đối", 
	9: "@killer@ Anh Hùng", 
	10: "@killer@ trở thành Chúa Cứu Thế", 
	11: "@killer@ trở thành Chiến Thần", 
	12: "@killer@ trở thành Truyền Thuyết, tới hạ hắn đi", 
	14: "@killer@ đã hạ @decedent@", 
	15: "@killer@ đã hạ Thống Trị Trận Đấu @decedent@", 
	16: "@killer@ đã hạ @decedent@ Không Đối Thủ", 
	17: "@killer@ đã hạ @decedent@ Vô Đối", 
	18: "@killer@ đã hạ anh hùng @decedent@", 
	19: "@killer@ đã hạ chúa cứu thể @decedent@", 
	20: "@killer@ đã hạ chiến thần @decedent@", 
	21: "@killer@ đã hạ @decedent@ truyền thuyết", 
	22: "@killer@ Double Kill", 
	23: "@killer@ Tripple Kill", 
	24: "@killer@ Unstoppable", 
	25: "@decedent@ đã hy sinh", 
	26: "@killer@ vẻ vang", 
}
const KILL_ASSIST: String = "Hỗ trợ"


const KILL_ASSIST_GAP: String = " "
const KILL_COMMA: String = ", "

static func kill_ease(t: float) -> float:
	var k: float = clampf(t, 0.0, 1.0)
	return 1.0 - (1.0 - k) * (1.0 - k)


static func kill_row_y(row: Dictionary, index: int, now: float) -> float:
	var start: float = float(row.get("ty", now))
	return lerpf(float(row.get("y0", 0.0)), index * KILL_ROW_HEIGHT, kill_ease((now - start) / KILL_TWEEN))

static func kill_row_alpha(row: Dictionary, now: float) -> float:
	return kill_ease((now - float(row.get("t", now))) / KILL_TWEEN) if bool(row.get("fade", false)) else 1.0




func _pvp_kill(info: Dictionary) -> void :
	var killer_id: int = int(info.get("m_killerObjId", 0))
	var dead_id: int = int(info.get("m_deadObjId", 0))
	if room_type in PVE_ROOMS or killer_id >> 26 != 0 or dead_id >> 26 != 0:
		return
	if not tanks.has(killer_id) or not tanks.has(dead_id):
		return
	var killer: Dictionary = tanks[killer_id]
	var dead: Dictionary = tanks[dead_id]
	if kill_tick < 0.0:
		kill_tick = clock + 1.0
	if kills.size() >= KILL_ROWS:
		kills.resize(KILL_ROWS - 1)
	for i in range(kills.size()):
		var row: Dictionary = kills[i]
		row.y0 = kill_row_y(row, i, clock)
		row.ty = clock
		row.fade = false
	kills.push_front({"killer": str(killer.get("name", "")), "dead": str(dead.get("name", "")), 
		"killer_camp": int(killer.get("camp", 0)), "dead_camp": int(dead.get("camp", 0)), "killer_id": killer_id, "dead_id": dead_id, 
		"killer_account": int(killer.get("account", 0)), "dead_account": int(dead.get("account", 0)), 
		"t": clock, "y0": 0.0, "ty": clock, "fade": true})


func _kill_timer(at: float) -> void :
	kill_tick = at + 1.0
	if kills.is_empty():
		kill_tick = -1.0
		return
	for i in range(kills.size()):
		if at - float(kills[i].t) >= KILL_ROW_TIME:
			kills.resize(i)
			return


func _kill_text(info: Dictionary) -> void :
	var killer_id: int = int(info.get("m_killerObjId", 0))
	var dead_id: int = int(info.get("m_deadObjId", 0))
	var skill: int = int(info.get("m_skillId", 0))
	var assists: Array = []
	for helper: Variant in info.get("m_assistTankId", []):
		assists.append(int(helper))
	match killer_id >> 26:
		0:
			_kill_player(info, killer_id, dead_id, skill, assists)
		3:
			if dead_id >> 26 != 3:
				_kill_line(25, {}, _kill_party(dead_id), 0, assists)
		5:
			_kill_line(25, {}, _kill_party(dead_id), 0, assists)


func _kill_player(info: Dictionary, killer_id: int, dead_id: int, skill: int, assists: Array) -> void :
	var killer: Dictionary = _kill_party(killer_id)
	match dead_id >> 26:
		0:
			if killer_id == dead_id:
				_kill_line(26, killer, {}, 0, [])
				return
			var ended: int = int(info.get("m_deadKillCount", 0))
			if int(info.get("m_isFirstBlood", 0)) == 1:
				_kill_line(1, killer, _kill_party(dead_id), skill, assists)
			elif ended >= KILL_MIN_SHOW:
				_kill_line(14 + mini(ended, 10) - 3, killer, _kill_party(dead_id), 0, assists)
			else:
				_kill_line(3, killer, _kill_party(dead_id), skill, assists)
			var streak: int = int(info.get("m_killerKillCount", 0))
			if streak >= KILL_MIN_SHOW:
				_kill_line(5 + mini(streak, 10) - 3, killer, {}, 0, [])
			var cont: int = int(info.get("m_contKillCount", 0))
			if cont > 1:
				_kill_line(22 if cont == 2 else 23 if cont == 3 else 24, killer, {}, 0, [])
		3:
			var npc: Dictionary = npcs.get(dead_id, {})
			if npc.is_empty():
				return
			var kind: String = str(map.templates.get(str(int(npc.template)), {}).get("iType", "")) if map != null else ""
			if not kind.is_valid_int() or not int(kind) in NPC_KILL_TYPES:
				return
			_kill_line(2, killer, _kill_party(dead_id), 0, [])
		5:
			_kill_line(2, killer, _kill_party(dead_id), 0, [])



func _kill_party(id: int) -> Dictionary:
	var kind: int = id >> 26
	if kind == 0:
		var tank: Dictionary = tanks.get(id, {})
		return {"name": str(tank.get("name", "")), "camp": int(tank.get("camp", 0))}
	var npc: Dictionary = npcs.get(id, {})
	if npc.is_empty():
		return {"name": "", "camp": 0}
	if _kill_names.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/i18n/kill_names.json"))
		_kill_names = parsed if parsed is Dictionary else {"npc": {}, "ainpc": {}}
	var table: Dictionary = _kill_names.get("ainpc" if kind == 5 else "npc", {})
	return {"name": str(table.get(str(int(npc.get("template", 0))), "")), "camp": int(npc.get("camp", 0))}


func _kill_line(key: int, killer: Dictionary, dead: Dictionary, skill: int, assists: Array) -> void :
	var helpers: Array = []
	for helper: int in assists:
		var tank: Dictionary = tanks.get(helper, {})
		helpers.append({"name": str(tank.get("name", "")), "camp": int(tank.get("camp", 0))})
	if kill_lines.size() >= KILL_LINES_MAX:
		kill_lines.pop_front()
	kill_lines.append({"key": key, "killer": killer, "dead": dead, "skill": skill, "assists": helpers, "t": clock})



static func kill_segments(line: Dictionary, tips: Dictionary) -> Array:
	if line.has("text"):
		return [[str(line.text), -1]]
	var text: String = str(KILL_TEXT.get(int(line.get("key", 0)), ""))
	if text.is_empty():
		return []
	var item: String = ""
	if text.contains("@item@"):
		var row: Variant = tips.get("skills", {}).get(str(int(line.get("skill", 0))))
		if not row is Array or (row as Array).is_empty():
			return []
		item = str(row[0])
	var killer: Dictionary = line.get("killer", {})
	var dead: Dictionary = line.get("dead", {})
	var out: Array = []
	var rest: String = text
	while not rest.is_empty():
		var at: int = -1
		var tag: String = ""
		for wild: String in ["@killer@", "@item@", "@decedent@"]:
			var found: int = rest.find(wild)
			if found >= 0 and (at < 0 or found < at):
				at = found
				tag = wild
		if at < 0:
			out.append([rest, -1])
			break
		if at > 0:
			out.append([rest.substr(0, at), -1])
		match tag:
			"@killer@":
				out.append([str(killer.get("name", "")), int(killer.get("camp", 0))])
			"@item@":
				out.append([item, -1])
			"@decedent@":
				out.append([str(dead.get("name", "")), int(dead.get("camp", 0))])
		rest = rest.substr(at + tag.length())
	var helpers: Array = line.get("assists", [])
	if not helpers.is_empty():
		out.append(["\n" + KILL_ASSIST + KILL_ASSIST_GAP, -1])
		for i in range(helpers.size()):
			if i > 0:
				out.append([KILL_COMMA, -1])
			out.append([str(helpers[i].get("name", "")), int(helpers[i].get("camp", 0))])
	return out


func _score_data(rows: Array) -> void :
	for row: Variant in rows:
		if not row is Dictionary:
			continue
		var account: int = int(row.get("m_acctOid", 0))
		var tank: Dictionary = _tank_of_account(account)
		if tank.is_empty():
			continue
		var values: Array = row.get("m_iStatData", [])
		score_stats[account] = [_stat(values, 0), _stat(values, 1), _stat(values, 2), _stat(values, 3), int(row.get("m_battlelevel", 0))]
		var camp: int = int(tank.camp)
		if camp == 1:
			if not score_a.has(account):
				score_a.append(account)
			score_revs[0] += 1
		elif camp == 2:
			if not score_b.has(account):
				score_b.append(account)
			score_revs[1] += 1
	_tech_rating_update()



func _tech_rating_update() -> void :
	var top: Array = [0, 0, 0]
	var accounts: Array = score_stats.keys()
	if not accounts.is_empty():
		top = [accounts[0], accounts[0], accounts[0]]
		for account: int in accounts:
			for slot: int in 3:
				if _tech_before(slot, account, int(top[slot])):
					top[slot] = account
	var kill: Array = score_stats.get(top[0], [0, 0, 0, 0])
	var all_round: Array = score_stats.get(top[1], [0, 0, 0, 0])
	var assist: Array = score_stats.get(top[2], [0, 0, 0, 0])
	tech_rating = [top[0] if int(kill[1]) > 0 else 0, top[1] if (int(all_round[2]) > 0 if _mvp_crown() else int(all_round[1]) > 0 and int(all_round[3]) > 0) else 0, top[2] if int(assist[3]) > 0 else 0]




func _tech_before(slot: int, a: int, b: int) -> bool:
	var x: Array = score_stats[a]
	var y: Array = score_stats[b]
	if slot == 1 and _mvp_crown():
		for col: int in [2, 1, 3]:
			if int(x[col]) != int(y[col]):
				return int(x[col]) > int(y[col])
		if int(x[0]) != int(y[0]):
			return int(x[0]) < int(y[0])
		return a < b
	if slot == 1:
		var kx: float = float(int(x[3]) + int(x[1])) / maxf(2.5, float(x[0]))
		var ky: float = float(int(y[3]) + int(y[1])) / maxf(2.5, float(y[0]))
		if kx != ky:
			return kx > ky
		if int(x[3]) + int(x[1]) != int(y[3]) + int(y[1]):
			return int(x[3]) + int(x[1]) > int(y[3]) + int(y[1])
		if int(x[1]) != int(y[1]):
			return int(x[1]) > int(y[1])
	else:
		var column: int = 1 if slot == 0 else 3
		if int(x[column]) != int(y[column]):
			return int(x[column]) > int(y[column])
		if int(x[0]) != int(y[0]):
			return int(x[0]) < int(y[0])
	return a > b


func tech_rating_of(account: int) -> int:
	if account != 0 and tech_rating.size() > 1 and int(tech_rating[1]) == account and _mvp_crown():
		return 1
	return tech_rating.find(account) if account != 0 else -1



func _mvp_crown() -> bool:
	return not (room_type in PVE_ROOMS) and not ffa_room()




func _score_kill(info: Dictionary) -> void :
	var killer: int = int(info.get("m_killerObjId", 0))
	var dead: int = int(info.get("m_deadObjId", 0))
	if killer >> 26 != 0 or dead >> 26 != 0 or not tanks.has(dead):
		return
	var row: Array = _score_row(int(tanks[dead].account))
	row[0] += 1
	if not tanks.has(killer):
		return
	row = _score_row(int(tanks[killer].account))
	row[1] += 1
	for helper: Variant in info.get("m_assistTankId", []):
		if not tanks.has(int(helper)):
			return
		row = _score_row(int(tanks[int(helper)].account))
		row[3] += 1
	_tech_rating_update()


func _score_row(account: int) -> Array:
	if not score_stats.has(account):
		score_stats[account] = [0, 0, 0, 0, 1]
		var camp: int = 0
		for brief: Variant in roster:
			if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) == account:
				camp = int(brief.get("bCamp", 0))
				break
		if camp == 1 and not score_a.has(account):
			score_a.append(account)
		elif camp == 2 and not score_b.has(account):
			score_b.append(account)
	return score_stats[account]


func _score_remove(id: int) -> void :
	if not tanks.has(id):
		return
	var account: int = int(tanks[id].account)
	var listed: int = score_a.size() + score_b.size()
	score_stats.erase(account)
	if score_a.has(account):
		score_a.erase(account)
		score_revs[0] += 1
	if score_b.has(account):
		score_b.erase(account)
		score_revs[1] += 1
	if score_a.size() + score_b.size() != listed:
		_info_tip_update()



func _self_count(info: Dictionary) -> void :
	if not tanks.has(self_id):
		return
	var killer: int = int(info.get("m_killerObjId", 0))
	var dead: int = int(info.get("m_deadObjId", 0))
	if killer == self_id:
		if dead >> 26 == 0:
			self_counts[0] += 1
	elif dead == self_id:
		self_counts[1] += 1
	else:
		for helper: Variant in info.get("m_assistTankId", []):
			if int(helper) == self_id:
				self_counts[2] += 1
				break


func _info_tip_update() -> void :
	for account: int in score_a + score_b:
		if account == self_id and score_stats.has(account):
			var row: Array = score_stats[account]
			info_tip = "%d/%d/%d" % [int(row[1]), int(row[0]), int(row[3])]
			return
	info_tip = "%d/%d/%d" % [self_counts[0], self_counts[1], self_counts[2]]


const WAVE_TIP: String = "Thời gian đến đợt sau còn %s"


func _dest_init() -> void :
	dest_inited = true
	dest_next = 0
	dest_timer = -1.0
	var info: Dictionary = Text.map_info(map_id)
	if info.is_empty():
		dest_shown = false
		return
	dest_shown = true
	if int(info.get("type", 0)) == 1:
		dest_text = str(info.get("goal", ""))
		return
	if create_rules().is_empty():
		dest_shown = false
		return
	_dest_refresh()


func create_rules() -> Array:
	if not map_loaded or map.id != map_id:
		return []
	for chunk: Variant in map.document.get("chunks", []):
		if chunk is Dictionary and int(chunk.get("tag", 0)) == 9 and chunk.get("data") is Dictionary:
			var rules: Variant = chunk.data.get("npcCreateRules", [])
			return rules if rules is Array else []
	return []


func server_second() -> int:
	return int(floor(now_ms() / 1000.0))


func limit_seconds() -> int:
	return time_limit if time_limit >= 0 else int(duration)


func battle_left_second() -> int:
	return int(start_ms / 1000.0) + limit_seconds() + overtime_seconds - server_second()


func _count_init() -> void :
	if limit_seconds() <= 0:
		clock_shown = false
		return
	var left: int = battle_left_second()
	if left <= 0:
		clock_shown = false
		return
	_count_update(left)
	clock_running = true


func _count_update(left: int) -> void :
	clock_left = left
	if left in TimeOver.MARKS:
		_time_tip(left)


func _time_tip(sec: int) -> void :
	time_tip = {"sec": sec, "t": clock}


func _overtime_update() -> void :
	over_shown = overtime
	clock_shown = not overtime
	clock_icon = not overtime
	if overtime:
		_time_tip(0)


func time_tip_frame() -> int:
	if time_tip.is_empty():
		return -1
	return int(floor((clock - float(time_tip.t)) * TimeOver.FPS + 0.0001))


func round_result_frame() -> int:
	if round_result.is_empty():
		return -1
	return mini(int(floor((clock - float(round_result.t)) * DeathRound.FPS + 0.0001)), DeathRound.RESULT_FRAMES - 2)

func round_count_frame() -> int:
	if round_count.is_empty():
		return -1
	return mini(int(floor((clock - float(round_count.t)) * DeathRound.FPS + 0.0001)), DeathRound.COUNT_FRAMES - 2)


func light_trophies() -> void :
	trophy_a = maxi(trophy_a, a_wins)
	trophy_b = maxi(trophy_b, b_wins)


func _round_tick() -> void :
	if not round_result.is_empty():
		var age: float = (clock - float(round_result.t)) * DeathRound.FPS + 0.0001
		if not round_result.lit and age >= DeathRound.MOVE_AT + DeathRound.MOVE_FRAMES:
			round_result.lit = true
			light_trophies()
		if age >= DeathRound.RESULT_FRAMES - 1:
			light_trophies()
			round_result = {}
	if not round_count.is_empty() and (clock - float(round_count.t)) * DeathRound.FPS + 0.0001 >= DeathRound.COUNT_FRAMES - 1:
		round_count = {}

func _time_tick() -> void :
	if not time_tip.is_empty() and time_tip_frame() >= int(TimeOver.TIP_FRAMES.get(int(time_tip.sec), 0)) - 2:
		time_tip = {}
	if not clock_running or not started or ended:
		return
	var left: int = battle_left_second()
	if left == clock_left:
		return
	if left <= 0:
		_count_update(0)
		clock_running = false
		return
	_count_update(left)



func _scroll(id: int) -> void :
	if scroll_id == id:
		return
	scroll_id = id
	if id == self_id:
		watch_name = ""
		return
	var tank: Dictionary = tanks.get(id, {})
	if tank.is_empty():
		return
	watch_name = str(tank.name)


func _scroll_to(id: int) -> void :
	_scroll(id)
	scroll_jump += 1



func watch_change() -> void :
	var camp: int = self_camp()
	var list: Array = []
	for tank: Dictionary in tanks.values():
		if int(tank.camp) == camp:
			list.append(tank)
	var mate: Dictionary = {}
	for i in range(list.size()):
		if _watch_index > list.size() - 1:
			_watch_index = 0
		mate = list[_watch_index]
		_watch_index += 1
		if int(mate.hp) != 0:
			break
	if mate.is_empty():
		return
	_scroll_to(int(mate.id))



func watch_press() -> void :
	if _watch_dead >= 0 and tanks.has(self_id):
		_scroll(self_id)


func watch_click() -> void :
	if _watch_dead >= 0 and _watch_click:
		watch_change()



func _watch_tick() -> void :
	var me: Dictionary = tanks.get(self_id, {})
	if me.is_empty():
		return
	if not me.dead:
		if _watch_dead >= 0 or scroll_id != self_id:
			_watch_dead = -1.0
			_watch_click = false
			watch_shown = false
			_scroll_to(self_id)
		return
	if _watch_dead < 0:
		_watch_dead = clock
		_watch_click = false
		watch_shown = true
	if not _watch_click and clock - _watch_dead >= 2.0:
		_watch_click = true
		watch_change()





func watch_pick(id: int) -> bool:
	if _watch_dead < 0 or id == self_id:
		return false
	var camp: int = self_camp()
	var list: Array = []
	for tank: Dictionary in tanks.values():
		if int(tank.camp) == camp:
			list.append(tank)
	for i in range(list.size()):
		var mate: Dictionary = list[i]
		if int(mate.id) == id:
			if int(mate.hp) == 0 or mate.dead:
				return false
			_watch_index = i + 1
			_watch_click = true
			_scroll_to(id)
			return true
	return false



func look_setup(oid: int) -> void :
	look_oid = oid
	look_camp_id = 1
	if oid == 0:
		return
	for brief: Variant in roster:
		if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) == oid and int(brief.get("bCamp", 0)) != 0:
			look_camp_id = int(brief.bCamp)


func look_tanks() -> Array:
	var list: Array = []
	for tank: Dictionary in tanks.values():
		if int(tank.id) != 0:
			list.append(tank)
	list.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		return int(a.camp) < int(b.camp) if int(a.camp) != int(b.camp) else int(a.id) < int(b.id))
	return list


func look_follow(id: int) -> void :
	look_target = id
	look_free = false
	_scroll(id)
	look_jump += 1
	_look_refresh = 0.0


func look_cycle(step: int) -> void :
	var list: Array = look_tanks()
	var count: int = list.size()
	if count == 0:
		return
	var start: int = -1
	for i in range(count):
		if int(list[i].id) == look_target:
			start = i
	if start < 0:
		start = -1 if step > 0 else 0
	var index: int = start
	for _try in range(count):
		index = posmod(index + step, count)
		if int(list[index].hp) > 0 and not list[index].dead:
			look_follow(int(list[index].id))
			return


func look_pick(index: int) -> void :
	var list: Array = look_tanks()
	if index >= 0 and index < list.size():
		look_follow(int(list[index].id))


func look_nearest(pos: Vector2) -> int:
	var best: int = 0
	var best_d: float = LOOK_PICK * LOOK_PICK
	for tank: Dictionary in tanks.values():
		if int(tank.hp) <= 0 or tank.dead or has_buff(tank, BUFF_DISAPPEAR):
			continue
		var d: float = ((tank.pos as Vector2) - Vector2(0, 18)).distance_squared_to(pos)
		if d < best_d:
			best_d = d
			best = int(tank.id)
	return best


func look_set_free(free: bool) -> void :
	if free:
		look_free = true
		scroll_id = 0
		watch_name = LOOK_NONE
	elif look_target != 0 and tanks.has(look_target):
		look_follow(look_target)
	else:
		look_free = false
		look_cycle(1)
	_look_refresh = 0.0


func look_target_tank() -> Dictionary:
	return {} if look_free else tanks.get(look_target, {})



func _look_tick(delta: float) -> void :
	if not look or not active:
		return
	watch_shown = true
	if look_tip_at < 0 and started:
		look_tip_at = clock
	var fresh: bool = false
	for id: int in tanks:
		if not _look_seen.has(id):
			_look_seen[id] = true
			fresh = true
	if fresh:
		var friend: Dictionary = _tank_of_account(look_oid) if look_oid != 0 else {}
		if not friend.is_empty():
			if look_target != int(friend.id):
				look_follow(int(friend.id))
		elif look_target == 0 or not tanks.has(look_target):
			look_cycle(1)
	_look_refresh -= delta
	if _look_refresh > 0:
		return
	_look_refresh = 0.25
	if look_free:
		return
	var target: Dictionary = tanks.get(look_target, {})
	if target.is_empty() or target.dead:
		look_cycle(1)
	else:
		_scroll(look_target)


func _dest_refresh() -> void :
	dest_next = 0
	dest_timer = -1.0
	var best: int = 2147483647
	var begin_utc: int = int(start_ms / 1000.0)
	var now: int = server_second()
	for rule: Variant in create_rules():
		if not rule is Dictionary:
			continue
		var at: int = begin_utc + int(rule.get("beginSecond", 0))
		var left: int = at - now
		if left > 0 and best > left:
			best = left
			dest_next = at
	if dest_next == 0:
		dest_text = str(Text.map_info(map_id).get("goal", ""))
		return
	dest_text = WAVE_TIP % Text.clock(best)
	dest_timer = 1.0


func _dest_tick(delta: float) -> void :
	if dest_timer < 0:
		return
	if ended:
		dest_timer = -1.0
		return
	dest_timer -= delta
	while dest_timer <= 0:
		dest_timer += 1.0
		var left: int = dest_next - server_second()
		if left < 0:
			_dest_refresh()
			return
		dest_text = WAVE_TIP % Text.clock(left)

func _tank_of_account(account: int) -> Dictionary:
	for id: int in tanks:
		if int(tanks[id].account) == account:
			return tanks[id]
	return {}


func number(pos: Vector2, value: int, kind: String) -> void :
	if numbers.size() >= 48:
		numbers.pop_front()
	var dx: float = 0.0
	for old: Dictionary in numbers:
		if clock - float(old.t) < 0.084 and old.pos.distance_to(pos) < 1.0:
			dx = randf_range(-40, 40)
	numbers.append({"pos": pos, "value": value, "kind": kind, "t": clock, "dx": dx})



func num_focus() -> Array[int]:
	var ids: Array[int] = []
	if look:
		if not look_free and scroll_id != 0 and tanks.has(scroll_id):
			ids.append(scroll_id)
		return ids
	if self_id == 0:
		return ids
	ids.append(self_id)
	var me: Dictionary = tanks.get(self_id, {})
	if not me.is_empty() and me.get("dead", false) and scroll_id != 0 and scroll_id != self_id and tanks.has(scroll_id):
		ids.append(scroll_id)
	return ids


static func num_mine(id: int, focus: Array[int], npc_list: Dictionary) -> bool:
	for _step in range(5):
		if id == 0:
			return false
		if focus.has(id):
			return true
		var npc: Dictionary = npc_list.get(id, {})
		if npc.is_empty():
			return false
		id = int(npc.get("owner", 0))
	return false



static func num_show(target: int, caster: int, focus: Array[int], npc_list: Dictionary) -> bool:
	return focus.is_empty() or focus.has(target) or num_mine(caster, focus, npc_list)

func now_seconds() -> float:
	return server_ms / 1000.0 if server_ms > 0 else Time.get_unix_time_from_system()

func supported() -> bool:
	return map_loaded and map.id == map_id

func alive() -> bool:
	return active and started and not ended and supported() and tanks.has(self_id) and not tanks[self_id].dead

func _position(value: Dictionary) -> Vector2:
	return Vector2(value.m_x, value.m_y)

func add_tank(value: Dictionary) -> void :
	var id: int = int(value.m_objId)
	var pos: Vector2 = _position(value)
	var buffs: Dictionary = {}
	for buff: Dictionary in value.m_buffVec:
		buffs[int(buff.m_nBuffInstId)] = buff
	tanks[id] = {"id": id, "account": int(value.m_acctOid), "pos": pos, "server": pos, "target": pos, 
		"direction": 3, "speed": 0.0, "hp": int(value.m_hp), "max_hp": int(value.m_maxHp), 
		"mp": int(value.m_mp), "max_mp": int(value.m_maxMp), "shield": int(value.m_shield), 
		"camp": int(value.m_iCamp), "name": str(value.m_name), "dead": int(value.m_hp) <= 0, 
		"aim": pos + Vector2(100, 0), "buffs": buffs, "respawn": 0.0, "lives": int(value.get("m_lifeCount", 0)), 
		"battle_level": int(value.get("m_battleLevel", 0)), 


		"level": int(value.get("m_battleLevel", 0))}
	names[int(value.m_acctOid)] = str(value.m_name)

	if int(value.get("m_tankLevel", 0)) >= 8:
		effect(pos, "born")


	elif not tanks[id].dead and born_seen.has(_born_key(value, id)):
		show_face(id, FACE_RELIVE)
	born_seen[_born_key(value, id)] = true
	if id == self_id:
		self_spawns += 1
		respawn = 0
		self_killer.clear()
		_local_step = false
		ready_until = 0.0

func _born_key(value: Dictionary, id: int) -> int:
	var account: int = int(value.get("m_acctOid", 0))
	return account if account != 0 else - id

func add_npc(value: Dictionary) -> void :
	var id: int = int(value.m_objId)
	var buffs: Dictionary = {}
	for buff: Dictionary in value.get("m_buffVec", []):
		buffs[int(buff.m_nBuffInstId)] = buff
	npcs[id] = {"id": id, "template": int(value.m_tplId), "pos": _position(value), 
		"hp": int(value.m_hp), "max_hp": int(value.m_maxHp), "camp": int(value.m_bCamp), 
		"dead": int(value.m_hp) == 0, "buffs": buffs, "shield": int(value.get("m_shield", 0)), 
		"owner": int(value.get("m_ownerId", 0)), 
		"target": _position(value), "server": _position(value), "speed": 0.0, "direction": 3}
	if int(npcs[id].template) == 2301:
		npcs[id].direction = 5

	var owner: Dictionary = actor(int(npcs[id].owner))
	if not owner.is_empty() and owner.get("pos") is Vector2:
		npcs[id]["owner_at"] = owner.pos


	if id >> 26 == 5 and tanks.has(int(npcs[id].owner)):
		var face: int = int(owner.get("direction", 3))
		if face >= 0 and face <= 7:
			npcs[id]["direction"] = face

	npcs[id]["late"] = started

	if id >> 26 == 5:
		npcs[id]["born"] = clock
		effect(_position(value), "appear", {"template": int(value.m_tplId)})

func actor(id: int) -> Dictionary:
	return tanks.get(id, npcs.get(id, {}))



func _trace(bullet: Dictionary, shooter: int) -> void :
	var camp: int = int(actor(shooter).get("camp", 0))
	var best: float = TRACE_PICK
	for list: Dictionary in [tanks, npcs]:
		for target: Dictionary in list.values():
			var tid: int = int(target.get("id", 0))
			if tid == shooter or target.get("dead", false) or (camp in [1, 2] and int(target.get("camp", 0)) == camp):
				continue
			var d: float = (target.pos as Vector2).distance_to(bullet.dest)
			if d < best:
				best = d
				bullet["trace"] = tid
	if bullet.has("trace"):
		bullet["eta"] = maxf(0.08, (bullet.start as Vector2).distance_to(bullet.dest) / float(bullet.speed))



func _trace_speed(bullet: Dictionary, delta: float, dt: float) -> float:
	if not bullet.has("trace"):
		return bullet.speed
	var target: Dictionary = actor(int(bullet.trace))
	if target.is_empty() or target.get("dead", false):
		bullet.erase("trace")
		return bullet.speed
	bullet.dest = target.pos
	var left: float = maxf(float(bullet.eta) - float(bullet.age) + delta, dt)
	return maxf(float(bullet.speed), (bullet.pos as Vector2).distance_to(bullet.dest) / left)





const DN1_NEAR: float = 8.0
const DN1_CATCH: float = 0.12
const DN1_SNAP: float = 0.6
const DN1_SAFE: float = 0.3
const DN1_CAP: float = 1.5
const DN1_SKIP: Dictionary = {326331: true, 459331: true, 462331: true}
func _dn1_defer(id: int, v: Dictionary) -> bool:
	var bullet: Dictionary = bullets[id]
	if bullet.has("blow"):
		return true
	for key: String in ["link", "trace", "land", "throw", "held", "spmtn1_full", "spmtn1_pre"]:
		if bullet.has(key):
			return false
	var tpl: int = int(bullet.get("template", 0))
	if DN1_SKIP.has(tpl) or (SPMTN1_BEAM != 0 and tpl == SPMTN1_BEAM):
		return false
	var normal: bool = normal_shot.is_valid() and bool(normal_shot.call(tpl))
	if not normal:
		return false
	var shooter: int = int(bullet.get("shooter", 0))
	if not tanks.has(shooter) and (shooter >> 26 != 0 or npcs.has(shooter)):
		return false
	for key: String in ["m_delVec", "m_overVec"]:
		for other: Variant in v.get(key, []):
			if int(other) == id:
				return false
	var speed: float = maxf(1.0, float(bullet.speed))
	if (bullet.start as Vector2).distance_to(bullet.dest) / speed > DN1_CAP:
		return false
	var left: float = (bullet.pos as Vector2).distance_to(bullet.dest)
	if left <= DN1_NEAR:
		return false
	bullet["blow"] = float(bullet.age)
	bullet.speed = maxf(speed, left / (DN1_CATCH if left <= speed * DN1_SNAP else 0.001))
	return true

const HIT_TANK: float = 50.0
const HIT_AINPC: float = 60.0


const HIT_PASS_AINPC: Dictionary = {373201: true, 373202: true, 615201: true, 615202: true}

static func pass_ainpc(id: int, npc: Dictionary) -> bool:
	return id >> 26 == 5 and HIT_PASS_AINPC.has(int(npc.get("template", 0)))

func _trace_pass_orb(bullet: Dictionary, shooter: int) -> void :
	if not bullet.has("trace") or not pass_ainpc(int(bullet.trace), actor(int(bullet.trace))):
		return
	var all: Dictionary = npcs
	var rest: Dictionary = {}
	for id: int in all:
		if not pass_ainpc(id, all[id]):
			rest[id] = all[id]
	bullet.erase("trace")
	bullet.erase("eta")
	npcs = rest
	_trace(bullet, shooter)
	npcs = all





func _bullet_contact(bullet: Dictionary, from: Vector2, to: Vector2) -> Variant:
	if bullet.has("link") or from.is_equal_approx(to):
		return null

	if not normal_shot.is_valid() or not bool(normal_shot.call(int(bullet.get("template", 0)))):
		return null
	var shooter: int = int(bullet.get("shooter", 0))
	var owner: Dictionary = actor(shooter)
	var camp: int = int(owner.get("camp", 0)) if not owner.is_empty() else -1
	var best: float = INF
	var hit: Variant = null
	for list: Dictionary in [tanks, npcs]:
		for target: Dictionary in list.values():
			var tid: int = int(target.get("id", 0))
			if tid == shooter or target.get("dead", false) or int(target.get("hp", 1)) <= 0:
				continue
			var radius: float = HIT_TANK
			if list == npcs:
				if tid >> 26 != 5 or pass_ainpc(tid, target):
					continue
				radius = HIT_AINPC
			elif target.has("throw") or has_buff(target, BUFF_DISAPPEAR):
				continue
			var tcamp: int = int(target.get("camp", 0))
			if camp >= 0 and mode != "happy" and tcamp == camp and camp != 0:
				continue
			var p: Vector2 = Geometry2D.get_closest_point_to_segment(target.pos, from, to)
			if p.distance_to(target.pos) > radius:
				continue

			var d: Vector2 = (to - from).normalized()
			var along: float = (target.pos - from).dot(d)
			var half: float = sqrt(maxf(0.0, radius * radius - target.pos.distance_squared_to(from + d * along)))
			var enter: float = clampf(along - half, 0.0, from.distance_to(to))
			if enter < best:
				best = enter
				hit = from + d * enter
	return hit



func effect(pos: Vector2, kind: String, extra: Dictionary = {}) -> void :
	if effects.size() >= 128:
		effects.pop_front()
	var fx: Dictionary = {"pos": pos, "kind": kind, "age": 0.0, "life": 0.65 if kind == "death" else 0.28}
	fx.merge(extra)
	effects.append(fx)




func _use_skill(skill: Dictionary) -> void :
	var id: int = int(skill.m_nSkillId)
	var caster: int = int(skill.m_nCasterId)
	var ready: bool = int(skill.m_isReady) == 1
	var flow: Array = skill_flow.call(id) if skill_flow.is_valid() else [0, 0, 0, 0, 0, true]
	_warm(id)
	if SELF_CHARGE_SKILLS.has(id) and not skill.has("_stm4") and int(flow[3]) != 0:
		var seen_key: String = "%d:%d" % [caster, id]
		var wait_s: float = (int(flow[0]) if int(flow[0]) > 0 else 300) / 1000.0
		if ready:
			_charge_seen[seen_key] = clock
		elif clock - float(_charge_seen.get(seen_key, -1000.0)) > wait_s + 0.5:

			var pre: Dictionary = skill.duplicate()
			pre.m_isReady = 1
			pre["_stm4"] = true
			var keep_ready: float = ready_until
			_use_skill(pre)
			ready_until = keep_ready
			var real: Dictionary = skill.duplicate()
			real["_stm4"] = true
			_charge_wait.append([clock + wait_s, real])
			return
	var charge: int = int(flow[3])
	var extra: Dictionary = {"skill": id, "caster": caster, "ready": ready, "start": Vector2(skill.m_StartX, skill.m_StartY), 
		"count": int(skill.get("m_nCount", 1))}
	if ready:
		extra.charge = charge
		if caster == self_id and int(flow[1]) != 1:
			ready_until = clock + int(flow[0]) / 1000.0
	else:
		extra.hold = int(flow[2]) == SKILL_MT_SVR_NOTIFY_STOP

		if charge != 0 and bool(flow[5]):
			for fx: Dictionary in effects:
				if str(fx.kind) == "skill" and fx.ready and int(fx.caster) == caster and int(fx.get("charge", 0)) == charge:
					fx.cut = true
	if int(flow[4]) == 1 and caster != self_id and tanks.has(caster):
		tanks[caster].aim = Vector2(skill.m_x, skill.m_y)
	effect(Vector2(skill.m_x, skill.m_y), "skill", extra)
	shake({"skill": id, "ready": ready, "owner": caster})
	skill_events += 1


func _charge_tick() -> void :
	var due: Array = []
	var keep: Array = []
	for row: Array in _charge_wait:
		(due if clock >= float(row[0]) else keep).append(row)
	_charge_wait = keep
	for row: Array in due:
		var who: Dictionary = actor(int(row[1].m_nCasterId))
		if not who.is_empty() and not who.get("dead", false):
			_use_skill(row[1])
		else:
			_charge_cancel(int(row[1].m_nCasterId), int(row[1].m_nSkillId))


func _charge_cancel(caster: int, id: int) -> void :
	var keep: Array = []
	for row: Array in _charge_wait:
		if int(row[1].m_nCasterId) != caster or int(row[1].m_nSkillId) != id:
			keep.append(row)
	_charge_wait = keep
	for fx: Dictionary in effects:
		if str(fx.kind) == "skill" and int(fx.get("caster", -1)) == caster and int(fx.get("skill", 0)) == id\
		and (fx.get("ready", false) or float(fx.age) < 0.2):
			fx.cut = true



func _npc_fire_pose(id: int, dest: Vector2, template: int) -> void :
	npcs[id].gun = dest
	npcs[id].recoil = clock
	if id >> 26 == 5:
		npcs[id].aim = dest
		npcs[id].fired = 0.0
		if template in PLAY_ATK:
			npcs[id].attack = 0.0



func _npc_skill_shot(skill: Dictionary, fires: Array) -> void :
	var id: int = int(skill.m_nSkillId)
	var shooter: int = int(skill.m_nCasterId)
	if int(skill.m_isReady) == 1 or not npcs.has(shooter) or not map_id in NPC_SKILL_SHOTS.get(id, []):
		return
	for fire: Dictionary in fires:
		if int(fire.m_objId) == shooter:
			return
	var start: Vector2 = Vector2(skill.m_StartX, skill.m_StartY)
	var dest: Vector2 = Vector2(skill.m_x, skill.m_y)
	if bullets.size() >= 512:
		bullets.erase(bullets.keys()[0])
	var bullet: Dictionary = {"pos": start, "dest": dest, "start": start, "speed": float(NPC_SHOT_SPEEDS.get(id, NPC_SHOT_SPEED)), "age": 0.0, 
		"template": id, "shooter": shooter, "land": true}
	_local_shots += 1
	bullets[ - _local_shots] = bullet
	effect(start, "fire", {"bullet": bullet})
	_npc_fire_pose(shooter, dest, id)


func npc_shot_skills() -> Array:
	var out: Array = []
	for id: int in NPC_SKILL_SHOTS:
		if map_id in NPC_SKILL_SHOTS[id]:
			out.append(id)
	return out


func die(id: int, show: bool = false) -> void :
	var obj: Dictionary = actor(id)
	if obj.is_empty():
		return

	if show and not obj.get("boomed", false) and (tanks.has(id) or id >> 26 == 5):
		obj.boomed = true
		effect(obj.pos, "death", {"actor": id} if tanks.has(id) else
			{"actor": id, "template": int(obj.get("template", 0)), "owner": int(obj.get("owner", 0))})

	if obj.has("face") and tanks.has(id):
		obj.erase("face")
		faced.erase(id)
	if obj.dead:
		return
	obj.dead = true
	obj.hp = 0
	_unlink(id)
	if tanks.has(id):
		_halt(obj, obj.pos)
		deaths += 1
	if id == self_id:
		_local_step = false
		ready_until = 0.0
		death_wait_cut = false


func show_face(id: int, face: int) -> void :
	var tank: Dictionary = tanks.get(id, {})
	if tank.is_empty() or tank.dead or tank.get("hidden", false):
		return
	if tank.has("face"):
		if not face_priority.is_valid() or int(face_priority.call(face)) <= int(face_priority.call(int(tank.face.id))):
			return
	tank["face"] = {"id": face, "at": clock}
	faced[id] = true



func _hit_face(id: int) -> void :
	if face_rng.randi_range(0, 9) < 9:
		return
	show_face(id, FACE_HIT[face_rng.randi_range(0, FACE_HIT.size() - 1)])



func _help_face(id: int) -> void :
	var npc: Dictionary = npcs.get(id, {})
	if npc.is_empty() or str(map.templates.get(str(int(npc.template)), {}).get("iType", "")) != "3":
		return
	if face_rng.randi_range(0, 4) < 4 or npc.has("face"):
		return
	npc["face"] = {"id": FACE_HELP, "at": clock}
	faced[id] = true


const GR1_RESPAWN_GRACE: float = 1.0

func set_hp(id: int, hp: int) -> void :
	var obj: Dictionary = actor(id)
	if obj.is_empty():
		return

	if hp < int(obj.hp):
		obj["lit"] = clock
	if hp <= 0:
		die(id, tanks.has(id))
	else:




		if obj.dead and id == self_id and respawn > GR1_RESPAWN_GRACE:
			return
		obj.hp = hp



		if obj.dead and (id == self_id or (tanks.has(id) and float(obj.respawn) <= 0.0)):
			obj.dead = false
			obj.boomed = false




func _npc_hp(id: int) -> void :
	var npc: Dictionary = npcs.get(id, {})
	if npc.is_empty():
		return
	npc["hp_mark"] = true
	if int(npc.camp) != self_camp():
		return
	var kind: int = int(str(map.templates.get(str(int(npc.template)), {}).get("iType", "0")))
	if kind != 3 and kind != 4:
		return
	var now: int = server_second()
	if harm_last.has(id) and now - int(harm_last[id]) < MinimapMarks.HARM_GAP:
		return
	harm_last[id] = now
	harms.append({"id": id, "pos": npc.pos, "kind": kind, "age": 0.0})




func _scene_talk(talk_id: int) -> void :
	var row: Dictionary = dialog_row(talk_id)
	if row.is_empty() and map_loaded:
		var found: Variant = map.document.get("visual", {}).get("dialogs")
		if not (found is Dictionary and (found as Dictionary).has(str(talk_id))):
			return
	if int(row.get("type", 0)) == DIALOG_COMPLETE:
		tip(TIP_105)
		return
	talks.append({"id": talk_id, "t": clock})
	if talks.size() > 8:
		talks.pop_front()


static func dialog_table() -> Dictionary:
	if _dialog_table.is_empty():
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/i18n/dialogs.json"))
		_dialog_table = parsed if parsed is Dictionary and parsed.get("rows") is Dictionary else {"images": {}, "rows": {}}
	return _dialog_table

static func dialog_row(talk_id: int) -> Dictionary:
	var row: Variant = dialog_table().rows.get(str(talk_id))
	return row if row is Dictionary else {}


static func dialog_image(name: String) -> String:
	var images: Variant = dialog_table().get("images")
	return str(images.get(name, "")) if images is Dictionary and not name.is_empty() else ""


func talk_images() -> Array[String]:
	var keys: Array[String] = []
	for entry: Dictionary in talks:
		var row: Dictionary = dialog_row(int(entry.id))
		for field: String in ["image", "bg"]:
			var key: String = dialog_image(str(row.get(field, "")))
			if not key.is_empty() and not key in keys:
				keys.append(key)
	return keys


func _dialog_text(text: String) -> String:
	var at: int = text.find("#name#")
	if at < 0:
		return text
	return text.substr(0, at) + str(names.get(self_id, "")) + text.substr(at + 6)




func talk_now() -> Dictionary:
	if talks.is_empty():
		return {}
	var found: Variant = map.document.get("visual", {}).get("dialogs") if map_loaded else null
	var rows: Dictionary = found if found is Dictionary else {}
	var shown: Dictionary = {}
	var shown_at: float = - INF
	for entry: Dictionary in talks:
		var data: Dictionary = {}
		var row: Variant = rows.get(str(entry.id))
		if row is Dictionary:
			data = row
		else:
			var table: Dictionary = dialog_row(int(entry.id))
			if int(table.get("type", 0)) != DIALOG_CUSTOM:
				continue
			data = {"text": str(table.get("text", "")), "delay": table.get("delay", 0), "time": table.get("time", 0), 
				"head": dialog_image(str(table.get("image", ""))), "bg": dialog_image(str(table.get("bg", ""))), "pack": true}
		var at: float = float(entry.t) + float(data.get("delay", 0))
		if at <= clock and at >= shown_at:
			shown = data
			shown_at = at
	if shown.is_empty():
		return {}
	var life: float = float(shown.get("time", 5))
	if life != -1 and clock >= shown_at + maxf(life, 0):
		return {}
	return {"text": _dialog_text(str(shown.get("text", ""))), "head": str(shown.get("head", "")), "bg": str(shown.get("bg", "")), 
		"pack": bool(shown.get("pack", false))}




func battle_dialog_now() -> Dictionary:
	var shown: Dictionary = {}
	var shown_id: int = 0
	var shown_at: float = - INF
	for entry: Dictionary in talks:
		var row: Dictionary = dialog_row(int(entry.id))
		var kind: int = int(row.get("type", 0))
		if (kind != DIALOG_BATTLE and kind != DIALOG_TITLE) or str(row.get("image", "")).is_empty():
			continue
		var at: float = float(entry.t) + float(row.get("delay", 0))
		if at <= clock and at >= shown_at:
			shown = row
			shown_id = int(entry.id)
			shown_at = at
	if shown.is_empty():
		return {}
	var life: float = float(shown.get("time", 0))
	if life != -1 and clock >= shown_at + maxf(life, 0):
		return {}
	return {"image": dialog_image(str(shown.image)), "title": int(shown.type) == DIALOG_TITLE, "id": shown_id}

func receive(type: int, v: Dictionary) -> void :
	_ch1_rx()
	match type:
		1550:
			add_tank(v.m_selfData)
			speed = int(v.m_speed)
			fire_ms = int(v.m_fireRate)
			skills.clear()
			for skill: Dictionary in v.m_skillVec:
				skills[int(skill.bSlotno)] = skill

			self_counts = [int(v.get("m_nKillCount", 0)), int(v.get("m_nDeadCount", 0)), int(v.get("m_nAssistCount", 0))]

			battle_exp = int(v.m_selfData.get("m_curBattleExp", battle_exp))
			_info_tip_update()
		1551:
			for tank: Dictionary in v.m_otherList:
				add_tank(tank)
		1552:
			add_tank(v.m_selfData)
		1553:

			var id: int = int(v.m_acctOid)
			if tanks.has(id):
				tanks[id].respawn = float(v.m_iReliveTime) / 1000.0
			if id == self_id:
				respawn = float(v.m_iReliveTime) / 1000.0
		1554:
			var id: int = int(v.m_oid)
			if tanks.has(id) and not _cl1_halt(tanks[id], _position(v)):
				_halt(tanks[id], _position(v))
			if id == self_id:
				_local_step = false
		1555, 1602:
			npcs.clear()
			for obj: Dictionary in v.m_objVec:
				add_npc(obj)
		1556:
			add_npc(v.m_objVec)
		1558:
			var obj: Dictionary = actor(int(v.m_nObjId))
			if not obj.is_empty():
				var buff: Dictionary = v.m_nBuffInfo.duplicate()
				buff["t0"] = clock
				buff["exist"] = float(v.m_nExistTime) / 1000.0
				obj.buffs[int(buff.m_nBuffInstId)] = buff

				if tanks.has(int(v.m_nObjId)) and buff_added.size() < 32:
					buff_added.append({"tpl": int(buff.get("m_nBuffTpltId", 0)), "pos": obj.get("pos", Vector2.ZERO), "self": int(v.m_nObjId) == self_id})
		1559:
			var obj: Dictionary = actor(int(v.m_nObjId))
			if not obj.is_empty():

				if int(obj.buffs.get(int(v.m_nBuffInstId), {}).get("m_nBuffTpltId", 0)) == HOOK_BUFF:
					_unlink(int(v.m_nObjId))
				if int(obj.buffs.get(int(v.m_nBuffInstId), {}).get("m_nBuffTpltId", 0)) == TORNADO_LIFT:
					obj["lift_end"] = clock
				obj.buffs.erase(int(v.m_nBuffInstId))
		1560:
			_update_attr(v)
		1561:
			stats = v.m_statVec
			var revs: int = score_revs[0] + score_revs[1]
			_score_data(v.m_statVec)
			if score_revs[0] + score_revs[1] != revs:
				_info_tip_update()
		1562:
			if bullets.has(int(v.m_bullteId)):
				var bullet: Dictionary = bullets[int(v.m_bullteId)]
				bullet.pos = Vector2(v.m_startX, v.m_startY)
				bullet.start = bullet.pos
				bullet.dest = Vector2(v.m_destX, v.m_destY)
				bullet.erase("trace")
		1564:
			_sync(v)
		1580:
			_scene_talk(int(v.get("m_nTalkId", 0)))
		1566:
			_self_count(v.m_killInfo)
			_info_tip_update()
			_score_kill(v.m_killInfo)
			_kill_info(v.m_killInfo)
			if int(v.m_killInfo.m_deadObjId) == self_id and tanks.has(self_id):
				var killer: int = int(v.m_killInfo.m_killerObjId)
				self_killer = {"id": killer, "account": int(tanks[killer].account) if tanks.has(killer) else 0}
			if SNEER:
				_sneer(v.m_killInfo)
			die(int(v.m_killInfo.m_deadObjId), true)
		1569:
			spray(int(v.m_sprayId), Vector2(v.m_x, v.m_y), SPRAY_TIME)
		1572:
			if int(v.m_nOwnerId) == self_id:
				skills[int(v.m_nPropData.bSlotno)] = v.m_nPropData
				var nhen4_slot: int = int(v.m_nPropData.bSlotno)
				if nhen4_slot != 0 and nhen4_slot not in cooled_slots and cooldown(nhen4_slot) > NHEN4_CD_EPS:
					cooled_slots.append(nhen4_slot)
			if int(v.m_nOwnerId) != self_id or int(v.m_nPropData.bSlotno) == 2:
				camp_skills[int(v.m_nOwnerId)] = v.m_nPropData
		1586:
			started = true
			start_ms = float(v.m_nStartTime) * 1000.0
			server_ms = start_ms
			elapsed = 0


			overtime = int(v.get("m_bOverTime", 0)) != 0
			if clock_inited:
				_overtime_update()
			else:
				clock_inited = true
				_count_init()
			if not dest_inited:
				_dest_init()
		1603:


			var dest_id: int = int(v.m_objId)
			if tanks.has(dest_id):
				tanks[dest_id].aim = Vector2(v.m_destX, v.m_destY)
				if dest_id == self_id:
					tanks[dest_id].cannon_rot = (tanks[dest_id].pos as Vector2).angle_to_point(Vector2(v.m_destX, v.m_destY))
		1605:

			var own_camp: int = self_camp()
			for change: Dictionary in v.m_hpChgInfoVec:
				var obj: Dictionary = actor(int(change.m_objId))

				if tanks.has(int(change.m_objId)) and int(obj.camp) == own_camp:
					var caster: Dictionary = actor(int(change.get("m_casterId", 0)))
					if not caster.is_empty():
						caster["hurt"] = clock
				if int(change.get("m_casterId", 0)) == self_id and int(change.m_objHp) < 0 and tanks.has(int(change.m_objId))\
				and int(change.m_objId) != self_id and (mode == "happy" or int(obj.camp) != own_camp):
					hit_target = int(change.m_objId)
					hit_target_at = clock
				if not obj.is_empty():



					if int(change.m_objHp) != 0 and num_show(int(change.m_objId), int(change.get("m_casterId", 0)), num_focus(), npcs):
						number(obj.pos, int(change.m_objHp), "crit" if int(change.get("m_nFury", 0)) > 0 else ("cure" if int(change.m_objHp) > 0 else "harm"))
				hp_events += 1
		1609:
			speed = int(v.m_speed)
			fire_ms = int(v.m_fireRate)
			if tanks.has(self_id):
				tanks[self_id].max_hp = int(v.m_maxHp)
				tanks[self_id].max_mp = int(v.m_maxMp)
				tanks[self_id].mp = int(v.m_curMp)
				set_hp(self_id, int(v.m_curHp))
		1563:


			effect(_position(v), "airdrop", {"left": randf() > 0.5})
			effects[-1].life = 2.75
		1565:
			_occupy(v.m_occupyVec)
		1570:

			overtime = true
			if clock_inited:
				_overtime_update()
			overtime_seconds = int(v.m_overTime)
			if clock_inited:
				_count_init()
		1597:
			vote = {"count": int(v.m_validCount), "end": float(v.m_nShowEndTime), "sponsor": int(v.m_nSponsor), "results": [], "mine": int(v.m_nSponsor) == self_id}
			vote_next = float(v.m_nNextTime)
		1598:
			if not vote.is_empty():
				vote.count = int(v.m_validCount)
				vote.results = v.get("m_vecVoteInfo", []).duplicate()
		1599:
			vote_next = float(v.m_nTime)
		1573:
			for row: Dictionary in v.m_values:
				happy[int(row.m_obj)] = int(row.m_value)
			happy_leader()
		1574:
			var scorer: int = int(v.m_values.m_obj)
			var before: int = int(happy.get(scorer, 0))
			happy[scorer] = int(v.m_values.m_value)
			happy_leader()
			var gained: int = (int(v.m_values.m_value) - before) / 1000
			if scorer == self_id and gained != 0 and mode != "happy":
				tip(_happy_tip(int(v.m_reaon), gained))
		1578:
			_throw(v)
		1579:

			skills[int(v.m_itemData.bSlotno)] = v.m_itemData
			swapped_slots.append(int(v.m_itemData.bSlotno))
		1581:
			var inst: int = int(v.m_nBuffInstId)
			for group: Dictionary in [tanks, npcs]:
				for obj: Dictionary in group.values():
					if obj.buffs.has(inst):
						obj.buffs[inst].m_nStackCount = int(v.m_nStackCount)
						obj.buffs[inst]["t0"] = clock
						obj.buffs[inst]["exist"] = float(v.m_nExistTime) / 1000.0
		1583:


			var stop_caster: int = int(v.m_nCasterId)
			for fx: Dictionary in effects:
				if int(fx.get("caster", -1)) != stop_caster or str(fx.kind) != "skill":
					continue
				if (fx.get("hold", false) and int(fx.skill) == int(v.m_nSkillId)) or (int(v.m_nSkillId) == 383301 and int(fx.get("charge", 0)) == 90803):
					fx.cut = true
			if SELF_CHARGE_SKILLS.has(int(v.m_nSkillId)):
				_charge_cancel(stop_caster, int(v.m_nSkillId))
			if stop_caster == self_id:
				ready_until = 0.0
		1585:
			if int(v.m_curExp) > battle_exp and tanks.has(self_id) and battle_exp > 0:
				number(tanks[self_id].pos, int(v.m_curExp) - battle_exp, "exp")
			battle_exp = int(v.m_curExp)
		1594:

			var sender: Dictionary = actor(int(v.m_objectId))
			var signal_type: int = int(v.m_iSignalType)
			if not (qp_on and qp_mute and int(v.m_objectId) != self_id):
				signals.append({"pos": Vector2(v.m_iDestX, v.m_iDestY), "type": signal_type, 
					"camp": int(sender.get("camp", 0)), "name": str(sender.get("name", "")), "age": 0.0})
				if qp_on and QP_NAMES.has(signal_type) and not chat_muted.has(int(v.m_objectId)):
					_chat_line({"head": "[" + CHAT_NAMES[CHAT_CAMP] + "]", "name": str(sender.get("name", "")), "name_color": Color("6b93ee"), 
						"text": ": " + str(QP_NAMES[signal_type]), "color": QP_COLORS[signal_type]}, true)
		1595:
			var leveled: Dictionary = actor(int(v.m_objectId))
			if not leveled.is_empty():

				if int(leveled.get("level", 0)) > 0 and int(v.m_Level) > int(leveled.level):
					if int(v.m_objectId) == self_id:
						tip("Lên cấp %d!" % int(v.m_Level))
				leveled.level = int(v.m_Level)
				leveled.battle_level = int(v.m_Level)
		1596:
			if npcs.has(int(v.m_nObjId)):
				npcs[int(v.m_nObjId)].max_hp = int(v.m_nMaxHp)
		1604:
			if npcs.has(int(v.m_nBarbetteId)):
				npcs[int(v.m_nBarbetteId)].aim_target = int(v.m_nTargetId) if int(v.m_isSetTarget) != 0 else 0
		1606:
			var traveler: Dictionary = actor(int(v.m_oid))
			if not traveler.is_empty():
				_halt(traveler, Vector2(v.m_x, v.m_y))
				traveler.erase("throw")
		1708:
			ended = true
			vote.clear()
			outcome = v.duplicate(true)
			_local_step = false
		1710:
			if ended:
				return
			red_kills = int(v.m_nRedKill)
			blue_kills = int(v.m_nBlueKill)
		1731:
			a_score = int(v.m_nRedOccupyScore)
			b_score = int(v.m_nBlueOccupyScore)
		1732:
			if int(v.m_occupyCamp) == 1:
				a_score += int(v.m_occupyScore)
			elif int(v.m_occupyCamp) == 2:
				b_score += int(v.m_occupyScore)
		1733:
			a_wins = int(v.m_nRedWinRound)
			b_wins = int(v.m_nBlueWinRound)
			light_trophies()
			death_round = a_wins + b_wins + 1
		1734:


			_unlink(0)
			death_round = a_wins + b_wins + 1
			start_ms = float(v.m_startTime) * 1000.0
			server_ms = start_ms
			elapsed = 0


			if mode == "death" and clock_inited:
				clock_running = false
				_count_init()

				death_wait_cut = true
				var next_round: int = a_wins + b_wins + 1
				round_count = {"round": next_round, "final": next_round == max_rounds * 2 - 1, "t": clock}
		1736:
			death_alive = [int(v.m_nRedAliveCnt), int(v.m_nBlueAliveCnt)]
		1735:
			if int(v.m_winCamp) == 1:
				a_wins += 1
			elif int(v.m_winCamp) == 2:
				b_wins += 1


			if mode == "death" and clock_inited:
				clock_running = false
				round_result = {"camp": int(v.m_winCamp), "t": clock, "lit": false}

func _update_attr(v: Dictionary) -> void :
	var id: int = int(v.m_acctOid)
	var kind: int = int(v.m_updateType)
	if id == self_id:
		if kind == 1: speed = int(v.m_iUpdateVal)
		if kind == 4: fire_ms = int(v.m_iUpdateVal)
	if not tanks.has(id):
		return
	match kind:
		3: tanks[id].max_hp = int(v.m_iUpdateVal)
		7: set_hp(id, int(v.m_iUpdateVal))
		8: tanks[id].max_mp = int(v.m_iUpdateVal)
		5: tanks[id].lives = int(v.m_iUpdateVal)

func _sync(v: Dictionary) -> void :
	syncs += 1
	for move: Dictionary in v.m_moveVec:
		var id: int = int(move.m_objId)
		var tank: Dictionary = actor(id)
		if tank.is_empty():
			continue
		if npcs.has(id):
			npc_moves += 1
		var pos: Vector2 = _position(move)
		var direction: int = clampi(int(move.m_direction), 0, 8)
		var kind: int = int(move.m_moveType)
		tank.server = pos


		if id == self_id and kind in [0, 2]:
			continue
		var speed_now: float = _ch1_speed(id, tank, maxf(0, float(move.m_speed)), kind, direction, pos)
		var cl1_me: bool = _cl1_sync(id, tank, kind)
		if cl1_me:
			speed_now = _cl1_base(tank, speed_now, kind, direction, pos)
		if kind in [1, 3, 4] or id == self_id:



			var rolling: bool = tank.pos.distance_to(tank.target) > 0.5


			if id != self_id:
				tank.queue = []
				tank.erase("cl1_b")
			if kind == 3 and tank.pos.distance_to(pos) > 0.5:
				tank.direction = _angle_direction(tank.pos, pos)
			elif kind == 5 and direction != 8:
				tank.direction = direction


			if speed_now <= 0 or kind == 5:
				tank.erase("gait")
			elif kind == 3:
				tank.gait = "rush"
			elif not rolling:
				tank.gait = "idle"
			tank.speed = speed_now
			tank.target = pos

			if npcs.has(id):
				tank.tween = true
			if speed_now == 0:
				tank.pos = pos
			if id == self_id:
				_local_step = false
			elif speed_now > 0:
				tank.moving = true
			else:



				tank.moving = false
				var waiting: Array = tank.get("queue", [])
				_begin_step(tank, waiting.pop_front() if not waiting.is_empty() else {"pos": pos, "dir": 8, "speed": 0.0})
		elif tank.get("moving", false):

			var queue: Array = tank.get("queue", [])
			var entry_new: Dictionary = {"pos": pos, "dir": direction, "speed": speed_now}
			if cl1_me:
				_cl1_entry(entry_new, speed_now, cl1_buf, clock)
			queue.append(entry_new)

			if cl1_me and queue.size() > CL1_QMAX:
				var newest: Dictionary = queue.back()
				newest.erase("at")
				queue = []
				tank.queue = queue
				tank.moving = false
				_begin_step(tank, newest)
				cl1.trim = int(cl1.trim) + 1
			elif queue.size() > 1 and speed_now > 0:
				for entry: Dictionary in queue:
					if float(entry.speed) > 0:
						entry.speed = queue.size() * speed_now
			tank.queue = queue
		else:
			var ch1_step: Dictionary = {"pos": pos, "dir": direction, "speed": speed_now}
			if cl1_me:
				ch1_step.cl1 = true
			if not _ch1_hold(tank, ch1_step):
				if cl1_me and cl1_buf:
					ch1_step.at = clock + CL1_BUF_T
					var waiting_buf: Array = tank.get("queue", [])
					waiting_buf.append(ch1_step)
					tank.queue = waiting_buf
				elif cl1_me:
					_cl1_begin(tank, ch1_step)
				else:
					_begin_step(tank, ch1_step)
	for fire: Dictionary in v.m_fireVec:


		if skill_known.is_valid() and not bool(skill_known.call(int(fire.m_nTemplate))):
			continue
		_warm(int(fire.m_nTemplate))
		if int(fire.m_objId) == self_id and fire_echoes.size() < 16:
			fire_echoes.append(int(fire.m_nTemplate))
		var pos: Vector2 = Vector2(fire.m_startX, fire.m_startY)
		var dest: Vector2 = Vector2(fire.m_destX, fire.m_destY)
		if bullets.size() >= 512:
			bullets.erase(bullets.keys()[0])
		var bullet: Dictionary = {"pos": pos, "dest": dest, "start": pos, "speed": maxf(1, float(fire.m_iSpeed)), "age": 0.0, 
			"template": int(fire.m_nTemplate), "shooter": int(fire.m_objId), "sdest": dest}
		if int(fire.m_nTemplate) in LINK_BULLETS:

			bullet["link"] = true
			bullet["origin"] = pos
			bullet["anchor"] = actor(int(fire.m_objId)).get("pos", pos)
		if SPMTN1_BEAM != 0 and int(fire.m_nTemplate) == SPMTN1_BEAM:
			bullet["spmtn1_full"] = true
			if int(fire.m_objId) == self_id:
				bullets.erase(SPMTN1_PRE)
		bullets[int(fire.m_bullteId)] = bullet
		if int(fire.m_nTemplate) in TRACE_BULLETS:
			_trace(bullet, int(fire.m_objId))
			_trace_pass_orb(bullet, int(fire.m_objId))
		if BTK2_HOLD.has(int(fire.m_nTemplate)) and tanks.has(int(fire.m_objId)) and not bullet.has("link") and not bullet.has("spmtn1_full") and not int(fire.m_nTemplate) in TRACE_BULLETS:
			bullet["hold"] = int(BTK2_HOLD[int(fire.m_nTemplate)])
		elif HLB1_HOLD.has(int(fire.m_nTemplate)) and npcs.has(int(fire.m_objId)):
			bullet["hold"] = int(HLB1_HOLD[int(fire.m_nTemplate)])
		effect(pos, "fire", {"bullet": bullet})
		if tanks.has(int(fire.m_objId)):
			tanks[int(fire.m_objId)].aim = dest
			tanks[int(fire.m_objId)].shots = int(tanks[int(fire.m_objId)].get("shots", 0)) + 1
			tanks[int(fire.m_objId)].fired = 0.0
			if int(fire.m_nTemplate) in PLAY_ATK:
				tanks[int(fire.m_objId)].attack = 0.0
		elif npcs.has(int(fire.m_objId)):
			_npc_fire_pose(int(fire.m_objId), dest, int(fire.m_nTemplate))
		shots += 1
	for skill: Dictionary in v.m_skillVec:
		_use_skill(skill)
		_npc_skill_shot(skill, v.m_fireVec)
	for hp: Dictionary in v.m_hpVec:
		var hp_id: int = int(hp.m_objId)
		var was: int = int(tanks[hp_id].hp) if tanks.has(hp_id) else 0
		set_hp(hp_id, int(hp.m_objHp))
		if hp_id >> 26 == 3:
			_npc_hp(hp_id)
			_help_face(hp_id)
		elif tanks.has(hp_id) and int(hp.m_objHp) < was:
			_hit_face(hp_id)
	for dead: Dictionary in v.m_deadVec:
		die(int(dead.m_AINpcId))
	for mp: Dictionary in v.m_mpVec:
		if tanks.has(int(mp.m_objId)):
			tanks[int(mp.m_objId)].mp = int(mp.m_objMp)
	for shield: Dictionary in v.m_shieldVec:
		var obj: Dictionary = actor(int(shield.m_objId))
		if not obj.is_empty():
			obj.shield = int(shield.m_shield)
	for id: int in v.m_delVec:
		_narsnd1_cut(id)
	for id: int in v.m_overVec:
		_narsnd1_cut(id)
	for id: int in v.m_blowUpVec:
		if bullets.has(id) and bullets[id].has("spmtn1_full") and not bullets[id].has("held"):
			bullets[id].pos = bullets[id].dest
	for id: int in v.m_blowUpVec:
		if bullets.has(id) and bullets[id].has("link"):

			bullets[id]["held"] = true
			if bullets[id].get("ex", {}).has("x"):
				effect(bullets[id].pos, "hit", {"bullet": bullets[id]})
			continue
		if bullets.has(id) and _dn1_defer(id, v):
			continue
		if bullets.has(id):
			effect(bullets[id].pos, "hit", {"bullet": bullets[id]})

			shake({"bullet": bullets[id], "owner": int(bullets[id].get("shooter", 0))})
		bullets.erase(id)
	for id: int in v.m_delVec:

		if id >> 26 == 4 and npcs.has(id) and not npcs[id].dead:
			effect(npcs[id].pos, "remove", {"template": int(npcs[id].template)})
		_ainpc_removed(id)
		_npc_removed(id)
		_item_removed(id)
		_bullet_removed(id)
		die(id)
		_actor_removed(id)
		npcs.erase(id)
		_score_remove(id)
		tanks.erase(id)
		bullets.erase(id)
	for id: int in v.m_overVec:


		expiry_notices += 1
		_ainpc_removed(id)
		_npc_removed(id)
		_item_removed(id)
		_bullet_removed(id)
		_actor_removed(id)
		npcs.erase(id)
		_score_remove(id)
		tanks.erase(id)
		bullets.erase(id)




func spray(id: int, pos: Vector2, life: float, sneer: bool = false) -> void :
	if id <= 0:
		return
	if sprays.size() >= 64:
		sprays.pop_front()
	var entry: Dictionary = {"id": id, "pos": pos, "age": 0.0, "life": life}
	if sneer:
		entry["sneer"] = true
	sprays.append(entry)


func _sneer(info: Dictionary) -> void :
	var killer: int = int(info.m_killerObjId)
	if not tanks.has(killer) or not tanks.has(int(info.m_deadObjId)):
		return
	var worn: int = int(appearances.get(int(tanks[killer].get("account", 0)), {}).get("spray", 0))
	spray(worn, Vector2(info.get("m_dead_x", 0), info.get("m_dead_y", 0)), SNEER_TIME, true)




func _ainpc_removed(id: int) -> void :
	if id >> 26 == 5 and npcs.has(id):
		shake({"ainpc": int(npcs[id].template), "owner": int(npcs[id].get("owner", 0))})
		die(id, true)

func _npc_removed(id: int) -> void :
	if id >> 26 == 3 and npcs.has(id):
		effect(npcs[id].pos, "destroy", {"template": int(npcs[id].template)})
		if wrecks.size() >= 64:
			wrecks.pop_front()
		wrecks.append({"pos": npcs[id].pos, "template": int(npcs[id].template), "age": 0.0})
		if npc_open.is_valid() and not str(npc_open.call(int(npcs[id].template))).is_empty():
			opened.append({"pos": npcs[id].pos, "template": int(npcs[id].template), "t0": clock})
		shake({"npc": int(npcs[id].template), "owner": int(npcs[id].get("owner", 0)), "pos": npcs[id].pos})



func _narsnd1_cut(id: int) -> void :
	if not bullets.has(id):
		return
	var bullet: Dictionary = bullets[id]
	if not bullet.has("snd") or bullet.has("narsnd1") or bullet.has("link") or bullet.has("trace"):
		return
	var sdest: Vector2 = bullet.get("sdest", bullet.dest)
	var flight: float = (bullet.start as Vector2).distance_to(sdest) / maxf(1.0, float(bullet.speed))
	if flight - float(bullet.age) <= maxf(NARSND1_EARLY, flight * 0.15):
		return
	bullet["narsnd1"] = true
	sound_cuts.append({"snd": bullet.snd, "pos": bullet.pos, "ms": Time.get_ticks_msec()})



func _bullet_removed(id: int) -> void :
	if bullets.has(id) and not bullets[id].has("link"):
		effect(bullets[id].pos, "gone")


func _actor_removed(id: int) -> void :
	if tanks.has(id) or npcs.has(id):
		_unlink(id)


func _unlink(shooter: int) -> void :
	for id: int in bullets.keys():
		if bullets[id].has("link") and (shooter == 0 or int(bullets[id].shooter) == shooter):
			bullets.erase(id)


func _item_removed(id: int) -> void :
	if id >> 26 == 4 and npcs.has(id):
		shake({"item": int(npcs[id].template), "owner": int(npcs[id].get("owner", 0)), "pos": npcs[id].pos})

func shake(request: Dictionary) -> void :
	if shakes.size() < 16:
		shakes.append(request)


func _occupy(rows: Array) -> void :
	var camp: int = self_camp()
	var before: Dictionary = occupy.duplicate(true)
	for row: Dictionary in rows:
		var index: int = int(row.iIndex)
		var old: int = int(before.get(index, {}).get("camp", 0))
		occupy[index] = {"camp": int(row.iCampId), "lock": int(row.iLock), "occupy": int(row.iOccupy)}
		if before.has(index) and old != int(row.iCampId) and camp != 0:
			if int(row.iCampId) == camp:
				tip("Bên ta đã chiếm cứ điểm")
			elif old == camp:
				tip("Cứ điểm bên ta đã bị chiếm!")
	var total: int = maxi(map.flags.size(), occupy.size())
	if camp == 0 or total == 0 or before.is_empty():
		return
	var owner: int = _sole_owner(occupy, total)
	if owner != 0 and owner != _sole_owner(before, total):
		tip("Bên xanh đã chiếm hết cứ điểm, được x2 tích điểm" if owner == camp else "Bên đỏ đã chiếm hết cứ điểm, được x2 tích điểm")

static func _sole_owner(flags: Dictionary, total: int) -> int:
	var owner: int = -1
	for row: Dictionary in flags.values():
		if owner == -1:
			owner = int(row.camp)
		elif owner != int(row.camp):
			return 0
	return owner if flags.size() == total and owner > 0 else 0

func flags_of(camp: int) -> int:
	var count: int = 0
	for row: Dictionary in occupy.values():
		if int(row.camp) == camp:
			count += 1
	return count

func tick(delta: float) -> void :
	var dt: float = minf(delta, 0.1)
	if active and started and not ended:
		elapsed += delta
		server_ms += delta * 1000.0
	respawn = maxf(0, respawn - delta)
	clock += delta
	if not _charge_wait.is_empty():
		_charge_tick()
	_dest_tick(delta)
	_time_tick()
	_round_tick()
	_watch_tick()
	_look_tick(delta)
	while kill_tick >= 0.0 and clock >= kill_tick:
		_kill_timer(kill_tick)
	while not numbers.is_empty() and clock - float(numbers[0].t) > 1.0:
		numbers.pop_front()
	if not honors.is_empty():
		if float(honors[0].t) < 0:
			honors[0].t = clock
		elif clock - float(honors[0].t) > 2.5:
			honors.pop_front()
	_ch1_pre()
	_cl1_pre()
	for tank: Dictionary in tanks.values():
		if tank.has("throw"):
			_step_throw(tank, delta)
		elif not tank.dead and not ended and (float(tank.speed) > 0 or tank.get("moving", false)):
			_advance(tank, dt, int(tank.id) == self_id)
		if tank.has("fired"):
			tank.fired += delta
		if tank.has("attack"):
			tank.attack += delta
	for npc: Dictionary in npcs.values():
		if npc.has("throw"):
			_step_throw(npc, delta)
		elif not npc.dead and not ended and (float(npc.speed) > 0 or npc.get("moving", false)):
			_advance(npc, delta if npc.get("tween", false) else dt)
		if npc.has("fired"):
			npc.fired += delta
		if npc.has("attack"):
			npc.attack += delta
	for id: int in bullets.keys():
		var bullet: Dictionary = bullets[id]
		bullet.age += delta
		if bullet.has("spmtn1_pre"):
			if not _spmtn1_follow(bullet):
				bullets.erase(id)
			continue
		if bullet.has("link"):

			if not bullet.has("held"):
				bullet.pos = bullet.pos.move_toward(bullet.dest, bullet.speed * dt)
			var owner: Dictionary = actor(int(bullet.shooter))
			if not owner.is_empty() and (bullet.has("moved") or not owner.pos.is_equal_approx(bullet.anchor)):
				bullet["moved"] = true
				bullet.origin = owner.pos
			if bullet.age > LINK_LIFE:
				bullets.erase(id)
			continue
		if bullet.has("blow") and float(bullet.age) - float(bullet.blow) > DN1_SAFE:
			bullet.pos = bullet.dest
			effect(bullet.pos, "hit", {"bullet": bullet})
			shake({"bullet": bullet, "owner": int(bullet.get("shooter", 0))})
			bullets.erase(id)
			continue
		var before: Vector2 = bullet.pos
		bullet.pos = bullet.pos.move_toward(bullet.dest, _trace_speed(bullet, delta, dt) * dt)
		if bullet.has("land") and bullet.pos == bullet.dest:
			effect(bullet.pos, "hit", {"bullet": bullet})
			shake({"bullet": bullet, "owner": int(bullet.get("shooter", 0))})
			bullets.erase(id)
			continue
		var contact: Variant = _bullet_contact(bullet, before, bullet.pos)
		if contact != null:

			bullet.pos = contact
			effect(bullet.pos, "hit", {"bullet": bullet})
			shake({"bullet": bullet, "owner": int(bullet.get("shooter", 0))})
			bullets.erase(id)
			continue
		if bullet.pos == bullet.dest and not bullet.has("trace") and normal_shot.is_valid() and bool(normal_shot.call(int(bullet.get("template", 0)))):

			effect(bullet.pos, "hit", {"bullet": bullet})
			shake({"bullet": bullet, "owner": int(bullet.get("shooter", 0))})
			bullets.erase(id)
			continue
		if bullet.has("hold") and bullet.pos == bullet.dest and not bullet.has("trace") and not bullet.has("link"):

			if int(bullet.hold) == 1:
				effect(bullet.pos, "hit", {"bullet": bullet})
				shake({"bullet": bullet, "owner": int(bullet.get("shooter", 0))})
			else:
				effect(bullet.pos, "gone")
			bullets.erase(id)
			continue
		if bullet.age > 5.0:
			bullets.erase(id)

	for i in range(signals.size() - 1, -1, -1):
		signals[i].age += delta
		if signals[i].age >= float(MinimapMarks.SIGNAL_DELAY.get(int(signals[i].type), 2.0)) + MinimapMarks.SIGNAL_FADE:
			signals.remove_at(i)
	for i in range(harms.size() - 1, -1, -1):
		harms[i].age += delta
		if harms[i].age >= float(MinimapMarks.SIGNAL_DELAY[4]) + MinimapMarks.SIGNAL_FADE:
			harms.remove_at(i)

	for id: int in bubbles.keys():
		if clock - float(bubbles[id].t) > 5.0:
			bubbles.erase(id)
	for i in range(tips.size() - 1, -1, -1):
		tips[i].age += delta
		if tips[i].age > 3.0:
			tips.remove_at(i)
	for i in range(effects.size() - 1, -1, -1):
		effects[i].age += delta
		if effects[i].age > effects[i].life:
			effects.remove_at(i)
	for i in range(wrecks.size() - 1, -1, -1):
		wrecks[i].age += delta
		if wrecks[i].age > WRECK_TIME:
			wrecks.remove_at(i)
	for i in range(sprays.size() - 1, -1, -1):
		sprays[i].age += delta
		if sprays[i].age > float(sprays[i].life) + SPRAY_FADE:
			sprays.remove_at(i)
	_sight()
	held_direction = 8



func _advance(obj: Dictionary, dt: float, own: bool = false) -> void :
	var left: float = dt
	for i in 4:
		if not own and obj.has("cl1_b"):
			obj.speed = _cl1_v(obj)
		var speed_now: float = float(obj.speed)

		if speed_now <= 0 and not obj.get("moving", false):
			return
		var dist: float = obj.pos.distance_to(obj.target)
		if speed_now > 0 and dist > speed_now * left:
			obj.pos = obj.pos.move_toward(obj.target, speed_now * left)
			return
		obj.pos = obj.target
		obj.erase("gait")
		if speed_now > 0:
			left -= dist / speed_now
		if not obj.get("moving", false):


			if own and left > 0 and held_direction >= 0 and held_direction <= 7:
				var request: Dictionary = next_move(held_direction)
				if not request.is_empty():
					step_requests.append(request)
					continue
			return
		obj.moving = false
		var queue: Array = obj.get("queue", [])
		if not own and not queue.is_empty() and clock < float(queue[0].get("at", -1.0)):
			return
		var next_step: Dictionary = queue.pop_front() if not queue.is_empty() else _cl1_idle(obj, own)
		if own:
			_begin_step(obj, next_step)
		else:
			_cl1_begin(obj, next_step)


func _begin_step(obj: Dictionary, step: Dictionary) -> void :
	obj.pos = step.pos
	obj.erase("tween")
	obj.erase("gait")
	obj.erase("cl1_b")
	if not step.has("cl1x"):
		obj.erase("cl1x")
	var dir: int = int(step.dir)
	if float(step.speed) <= 0 and dir >= 0 and dir <= 7 and int(obj.get("template", 0)) == 2301 and (int(obj.get("id", 0)) >> 26) == 5:
		obj.direction = dir
	if dir < 0 or dir > 7 or float(step.speed) <= 0:
		obj.target = step.pos
		obj.moving = false
		obj.queue = []
		return
	obj.direction = dir
	obj.speed = float(step.speed)
	obj.target = step.pos + STEPS[dir]
	obj.moving = true
	if step.has("cl1"):
		obj.cl1_b = float(step.get("cl1v", obj.speed))
		obj.cl1_t = obj.target


static func _angle_direction(from: Vector2, to: Vector2) -> int:
	var deg: float = rad_to_deg(atan2(to.x - from.x, from.y - to.y))
	return (floori(fposmod(deg + 22.0, 360.0) / 45.0) + 1) % 8


static func _halt(obj: Dictionary, pos: Vector2) -> void :
	obj.pos = pos
	obj.erase("tween")
	obj.target = pos
	obj.server = pos
	obj.moving = false
	obj.queue = []
	obj.erase("gait")
	obj.erase("cl1_b")
	obj.erase("cl1x")

func _step_throw(obj: Dictionary, delta: float) -> void :
	var throw: Dictionary = obj.throw
	throw.t += delta
	var ratio: float = clampf(float(throw.t) / float(throw.duration), 0, 1)
	obj.pos = throw.from.lerp(throw.to, ratio)
	if ratio >= 1:
		obj.erase("throw")
		obj.target = throw.to
		obj.moving = false
		obj.queue = []

func next_move(direction: int) -> Dictionary:
	if direction < 0 or direction > 7:
		move_rule.blocked_dir = -1
	if not alive() or direction < 0 or direction > 7 or speed < 12:
		return {}
	var tank: Dictionary = tanks[self_id]



	if move_lock or clock < ready_until or tank.has("throw") or has_buff(tank, BUFF_AUTO_MOVE) or has_buff(tank, BUFF_DISAPPEAR)\
	or has_buff(tank, BUFF_CHANNEL_LOCK):
		return {}


	if _stilled(tank):
		return {}
	if tank.pos.distance_to(tank.target) > 0.5:
		return {}

	if move_rule.waiting(direction, clock):
		return {}
	var held: int = direction

	if has_buff(tank, BUFF_REVERSAL):
		direction = (direction + 4) % 8
	var pos: Vector2 = tank.pos.round()
	move_rule.hit = false
	var step: int = _slide(pos, direction)

	if step < 0 and not move_rule.hit:
		var grid: = Vector2(roundf((pos.x - 12.0) / 24.0) * 24.0 + 12.0, roundf((pos.y - 12.0) / 24.0) * 24.0 + 12.0)
		if grid != pos and _can_move(grid, pos):
			step = _slide(grid, direction)
			if step >= 0:
				pos = grid
	move_rule.settle(held, step >= 0, clock)
	if step < 0 and clock - bump_at >= BUMP_GAP and _bumped(pos, direction):
		bump_at = clock
		bump_dir = STEPS[direction].normalized()
	if step < 0:
		return {}
	tank.direction = step
	tank.target = pos + STEPS[step]
	tank.speed = float(speed)
	tank.erase("gait")
	_local_step = true
	return {"m_start_x": int(pos.x), "m_start_y": int(pos.y), "m_direction": step, "m_sceneId": scene_id}

func _stilled(obj: Dictionary) -> bool:
	if not still_buff.is_valid():
		return false
	for buff: Dictionary in obj.buffs.values():
		if bool(still_buff.call(int(buff.get("m_nBuffTpltId", 0)))):
			return true
	return false


func _warm(id: int) -> void :
	if id <= 0 or _warmed.has(id / 1000) or not warm_still.is_valid():
		return
	_warmed[id / 1000] = true
	warm_still.call(id)



func _can_step(from: Vector2, to: Vector2) -> bool:
	return map.can_move(to, npcs, from) and not _blocked_by_pillar(to, from) and not _blocked_by_tornado(to, from) and not _blocked_by_tank(from, to)\
	and not SelfMoveRule.blocked_by_happy_npc(to, from, tanks.get(self_id, {}), npcs, map_id)\
	and not SelfMoveRule.blocked_by_ghost(to, from, tanks.get(self_id, {}), npcs, ffa_room())



const HAPPY_ROOM: int = 100
const HAPPY_MAPS: Array[int] = [80, 81]
func ffa_room() -> bool:
	return room_type == HAPPY_ROOM or mode == "happy" or map_id in HAPPY_MAPS
const MODE_KILL_KING: int = 10

static func air_off(room: int, map_mode: int) -> bool:
	return map_mode == MODE_KILL_KING or room == HAPPY_ROOM
func air_hidden() -> bool:
	return air_off(room_type, int(Text.map_info(map_id).get("modeType", 0)))

const ENERGY_PILLARS: Array[int] = [1703, 1704]
const ENERGY_PILLAR_REACH: = 60.0
const TORNADO: = 3260216
const TORNADO_GUARD: Array[int] = [10400196]
const TORNADO_REACH: = 132.0

const TORNADO_LIFT: = 10400191
const LIFT_FALL: = 0.75
const LIFT_HEIGHT: = 33.75

const NO_COLLIDE: Array[int] = [392302, 402, 403, 406, 104401, 511111, 309207, 309210, 309215, 402207, 402210, 402215, 321202, 321205, 
	321303, 621202, 621205, 621303, 322304, 443304, 444304, 458304, 469210, 332210, 339204, 339206, 341201, 341202, 341203, 442201, 442202, 
	442203, 344206, 450206, 471206, 348204, 460204, 461204, 648204, 354126, 481126, 482126, 356303, 485303, 486303, 357208, 487208, 488208, 
	371123, 371124, 612123, 612124, 372102, 372103, 614102, 614103, 374413, 674413, 375101, 375102, 675101, 675102, 380214, 380215, 380302, 
	680214, 680215, 680302, 382304, 407321, 439204, 439206, 472204, 472206, 390104, 391214, 330135, 330310, 470135, 470310]




func _blocked_by_pillar(center: Vector2, from: Vector2) -> bool:
	var me: Dictionary = tanks.get(self_id, {})
	if me.is_empty() or has_buff(me, NO_COLLIDE):
		return false
	for npc: Dictionary in npcs.values():
		if npc.dead or not int(npc.template) in ENERGY_PILLARS or int(npc.get("camp", 0)) == int(me.camp):
			continue
		var next: float = center.distance_to(npc.pos)
		var now: float = from.distance_to(npc.pos)
		if next < ENERGY_PILLAR_REACH and not (now < ENERGY_PILLAR_REACH and next >= now):
			return true
	return false



func _blocked_by_tornado(center: Vector2, from: Vector2) -> bool:
	var me: Dictionary = tanks.get(self_id, {})
	if me.is_empty() or has_buff(me, NO_COLLIDE) or not has_buff(me, TORNADO_GUARD):
		return false
	for npc: Dictionary in npcs.values():
		if npc.dead or int(npc.template) != TORNADO:
			continue
		var next: float = center.distance_to(npc.pos)
		var now: float = from.distance_to(npc.pos)
		if next < TORNADO_REACH and not (now < TORNADO_REACH and next >= now):
			return true
	return false

func _blocked_by_tank(from: Vector2, to: Vector2) -> bool:
	var me: Dictionary = tanks.get(self_id, {})
	if me.is_empty() or has_buff(me, NO_COLLIDE):
		return false
	for tank: Dictionary in tanks.values():
		if int(tank.id) == self_id or (int(tank.camp) == int(me.camp) and not ffa_room()) or int(tank.hp) <= 0 or tank.dead:
			continue
		if tank.has("throw") or SelfMoveRule.phases(tank) or has_buff(tank, BUFF_DISAPPEAR):
			continue
		var d: Vector2 = tank.pos - to
		if absf(d.x) < 72 and absf(d.y) < 72:
			var s: Vector2 = tank.pos - from
			if not (absf(s.x) < 72 and absf(s.y) < 72 and d.length_squared() >= s.length_squared()):
				return true
	return false



func _slide(pos: Vector2, direction: int) -> int:
	if _can_move(pos + STEPS[direction], pos):
		return direction
	match direction:
		0, 2, 4, 6:

			var vertical: int = 1 if direction in [0, 2] else 5
			if _can_move(pos + STEPS[vertical], pos):
				return vertical
			var horizontal: int = 7 if direction in [0, 6] else 3
			if _can_move(pos + STEPS[horizontal], pos):
				return horizontal
		1, 5:

			var dy: float = STEPS[direction].y
			if _can_move(pos + Vector2(-24, 0), pos) and _can_move(pos + Vector2(-24, dy), pos):
				return 7
			if _can_move(pos + Vector2(24, 0), pos) and _can_move(pos + Vector2(24, dy), pos):
				return 3
		3, 7:
			var dx: float = STEPS[direction].x
			if _can_move(pos + Vector2(0, -24), pos) and _can_move(pos + Vector2(dx, -24), pos):
				return 1
			if _can_move(pos + Vector2(0, 24), pos) and _can_move(pos + Vector2(dx, 24), pos):
				return 5
	return -1


func _can_move(center: Vector2, from: Vector2) -> bool:
	if not map.can_move(center, npcs, from) or _blocked_by_pillar(center, from) or _blocked_by_tornado(center, from):
		return false
	if SelfMoveRule.blocked_by_happy_npc(center, from, tanks.get(self_id, {}), npcs, map_id):
		move_rule.hit = true
		return false
	if SelfMoveRule.blocked_by_tank(center, from, tanks.get(self_id, {}), tanks, _gone, ffa_room()) or SelfMoveRule.blocked_by_ghost(center, from, tanks.get(self_id, {}), npcs, ffa_room()):
		move_rule.hit = true
		return false
	return true



func _bumped(pos: Vector2, direction: int) -> bool:
	var to: Vector2 = pos + STEPS[direction]
	if not map.can_move(to, {}, pos) or _blocked_by_pillar(to, pos) or _blocked_by_tornado(to, pos):
		return false
	var fixed: Dictionary = {}
	var summoned: Dictionary = {}
	for id: int in npcs:
		if int(npcs[id].get("owner", 0)) != 0:
			summoned[id] = npcs[id]
		else:
			fixed[id] = npcs[id]
	if not map.can_move(to, fixed, pos):
		return false
	if not map.can_move(to, summoned, pos):
		return true


	var hit: bool = move_rule.hit
	var free: bool = _can_move(to, pos)
	move_rule.hit = hit
	return not free


func bump_offset(tank: Dictionary) -> Vector2:
	var t: float = clock - bump_at
	if int(tank.get("id", 0)) != self_id or self_id == 0 or t < 0.0 or t >= BUMP_TIME:
		return Vector2.ZERO
	var u: float = t / BUMP_TIME
	return bump_dir * (BUMP_AMP * sin(u * TAU * 2.0) * (1.0 - u))


func _gone(tank: Dictionary) -> bool:
	return has_buff(tank, BUFF_DISAPPEAR) or flying(tank)


func lift_fall(tank: Dictionary) -> float:
	if not tank.has("lift_end"):
		return -1.0
	var t: float = clock - float(tank.lift_end)
	return t if t < LIFT_FALL else -1.0



func flying(tank: Dictionary) -> bool:
	if not buff_show.is_valid():
		return false
	if lift_fall(tank) >= 0.0:
		return true
	for buff: Dictionary in tank.get("buffs", {}).values():
		if not buff.has("t0"):
			continue
		if int(buff.get("m_nBuffTpltId", 0)) == TORNADO_LIFT:
			return true
		var row: Array = buff_show.call(int(buff.get("m_nBuffTpltId", 0)))
		if row.size() < 2 or int(row[0]) != 1:
			continue
		var total: float = float(row[1]) / 1000.0
		var t: float = clock - float(buff.t0)
		if total > 0 and t >= 0 and t < total:
			return true
	return false

static func has_buff(obj: Dictionary, ids: Array[int]) -> bool:
	for buff: Dictionary in obj.get("buffs", {}).values():
		if int(buff.get("m_nBuffTpltId", 0)) in ids:
			return true
	return false






static var pe1_enabled: bool = true
func _sight() -> void :
	if not pe1_enabled:
		_sight_pe0()
		return
	var camp: int = self_camp()
	if look:
		camp = 0
	var bush: Dictionary = map.bush
	var bushless: bool = bush.is_empty()
	var columns: int = int(map.extent.x / 24)
	var probes: Array[Dictionary] = []
	var prey: Array[Dictionary] = []
	for objs: Array in [tanks.values(), npcs.values()]:
		for obj: Dictionary in objs:
			var id: int = int(obj.id)
			if tanks.has(id) or id >> 26 == 5:
				prey.append(obj)
			if id >> 26 == 4:
				continue
			var at: Vector2 = obj.pos
			obj["turf"] = 0 if bushless or at.x < 0 or at.y < 0 else int(bush.get(int(at.y / 24) * columns + int(at.x / 24), 0))
			if not obj.dead and (id == self_id or (camp != 0 and int(obj.camp) == camp)):
				probes.append(obj)
	var reach: float = map.los_range() * map.los_range()
	for obj: Dictionary in prey:
		var id: int = int(obj.id)
		var is_tank: bool = tanks.has(id)
		var mine: bool = id == self_id or (camp != 0 and int(obj.camp) == camp)

		var seen: bool = camp == 0 or mine or clock - float(obj.get("hurt", -1000.0)) < SIGHT_HURT
		if not seen:
			for probe: Dictionary in probes:
				if probe.pos.distance_squared_to(obj.pos) <= reach and (int(obj.turf) == 0 or int(obj.turf) == int(probe.turf)):
					seen = true
					break
		var buffs: Variant = obj.get("buffs")
		if (buffs == null and not obj.has("buffs")) or (buffs is Dictionary and (buffs as Dictionary).is_empty()):
			obj["hidden"] = not seen
			obj["faded"] = int(obj.turf) != 0
			continue
		var stealth: bool = has_buff(obj, BUFF_STEALTH)
		var exposed: bool = camp == 0 or mine or (is_tank and has_buff(obj, BUFF_RADAR))
		obj["hidden"] = has_buff(obj, BUFF_DISAPPEAR) or not seen or (stealth and not exposed)
		obj["faded"] = int(obj.turf) != 0 or stealth


func _sight_pe0() -> void :
	var camp: int = self_camp()
	if look:
		camp = 0
	var probes: Array[Dictionary] = []
	for group: Dictionary in [tanks, npcs]:
		for obj: Dictionary in group.values():
			if int(obj.id) >> 26 == 4:
				continue
			obj["turf"] = map.bush_id(obj.pos)
			if not obj.dead and (int(obj.id) == self_id or (camp != 0 and int(obj.camp) == camp)):
				probes.append(obj)
	var reach: float = map.los_range() * map.los_range()
	for objs: Array in [tanks.values(), npcs.values()]:
		for obj: Dictionary in objs:
			var is_tank: bool = tanks.has(int(obj.id))
			if not is_tank and int(obj.id) >> 26 != 5:
				continue
			var mine: bool = int(obj.id) == self_id or (camp != 0 and int(obj.camp) == camp)

			var seen: bool = camp == 0 or mine or clock - float(obj.get("hurt", -1000.0)) < SIGHT_HURT
			if not seen:
				for probe: Dictionary in probes:
					if probe.pos.distance_squared_to(obj.pos) <= reach and (int(obj.turf) == 0 or int(obj.turf) == int(probe.turf)):
						seen = true
						break
			var stealth: bool = has_buff(obj, BUFF_STEALTH)
			var exposed: bool = camp == 0 or mine or (is_tank and has_buff(obj, BUFF_RADAR))
			obj["hidden"] = has_buff(obj, BUFF_DISAPPEAR) or not seen or (stealth and not exposed)
			obj["faded"] = int(obj.turf) != 0 or stealth

func now_ms() -> float:
	return float(Time.get_ticks_msec()) + clock_offset if not is_nan(clock_offset) else server_ms

static func _stamp(words: Variant) -> float:
	return float(words.hipart) * 4294967300.0 + float(words.lowpart) if words is Dictionary else 0.0


func cooldown(slot: int) -> float:
	if not skills.has(slot):
		return INF
	var prop: Dictionary = skills[slot]
	var end: float = _stamp(prop.nEndTime)
	if int(prop.get("iCount", -1)) == 0:
		end = maxf(end, _stamp(prop.get("nCountCoolTime")))
	return maxf(0, (end - now_ms()) / 1000.0)


func camp_cd(obj: int) -> float:
	if not camp_skills.has(obj):
		return 0.0
	return maxf(0, (_stamp(camp_skills[obj].get("nEndTime")) - now_ms()) / 1000.0)


func ex_locked() -> bool:
	if not tanks.has(self_id):
		return true
	return int(tanks[self_id].get("battle_level", 0)) < int(ex_unlock.get(map_id, 0))


func skill_request(slot: int, aim: Vector2, target_id: int = 0) -> Dictionary:
	if SPMTN1_BEAM != 0 and skills.has(slot) and int(skills[slot].get("nPropsId", 0)) == SPMTN1_BEAM and alive() and cooldown(slot) <= 0:
		_spmtn1_charge(aim)
	if not alive() or not skills.has(slot) or (slot != 0 and cooldown(slot) > 0):
		return {}
	if int(skills[slot].get("nPropsId", 0)) in NATSU_E_READY:
		ready_until = maxf(ready_until, clock + 0.1)
	return {"m_sceneId": scene_id, "m_targetId": target_id, "m_soltNo": slot, 
		"m_destX": clampi(int(aim.x), 0, int(map.extent.x)), "m_destY": clampi(int(aim.y), 0, int(map.extent.y))}


func _spmtn1_charge(aim: Vector2) -> void :
	var me: Dictionary = actor(self_id)
	if me.is_empty():
		return
	if bullets.has(SPMTN1_PRE):
		bullets[SPMTN1_PRE].dest = aim
		return
	if bullets.size() >= 512:
		bullets.erase(bullets.keys()[0])
	bullets[SPMTN1_PRE] = {"pos": me.pos, "start": me.pos, "origin": me.pos, "anchor": me.pos, "dest": aim, "speed": 1.0, "age": 0.0, 
		"template": SPMTN1_BEAM, "shooter": self_id, "link": true, "spmtn1_pre": true}


func _spmtn1_follow(bullet: Dictionary) -> bool:
	var me: Dictionary = actor(int(bullet.shooter))
	if me.is_empty() or me.get("dead", false) or float(bullet.age) > SPMTN1_PRE_LIFE:
		return false
	bullet.pos = me.pos
	bullet.origin = me.pos
	bullet.start = me.pos
	return true



func observe_clock(words: Dictionary, _rtt_ms: int = -1) -> void :
	var now: float = _stamp(words)
	if now <= 0:
		return
	clock_offset = now - float(Time.get_ticks_msec())
	if started and not ended and now >= start_ms:
		server_ms = now
		elapsed = (server_ms - start_ms) / 1000.0

func self_camp() -> int:
	if look:
		return look_camp_id
	for row: Dictionary in outcome.get("m_tankVec", []):
		if int(row.m_charOid) == self_id:
			return int(row.m_camp)
	return int(tanks[self_id].camp) if tanks.has(self_id) else 0

static func _stat(values: Array, index: int) -> int:
	return int(values[index]) if index < values.size() else 0




func result() -> Dictionary:
	var camp: int = self_camp()
	var rows: Array[Dictionary] = []
	for row: Dictionary in outcome.get("m_tankVec", []):
		var id: int = int(row.m_charOid)
		var values: Array = row.get("m_iStatData", [])
		rows.append({"id": id, "name": str(names.get(id, "Người chơi")), "camp": int(row.m_camp), "self": id == self_id, 
			"dead": _stat(values, 0), "kill": _stat(values, 1), "score": _stat(values, 2), 
			"assist": _stat(values, 3), "harm": _stat(values, 6)})
	rows.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		if a.score != b.score: return a.score > b.score
		if a.kill != b.kill: return a.kill > b.kill
		return a.dead < b.dead)
	var win_type: int = int(outcome.get("m_winType", 1))
	var win_camp: int = int(outcome.get("m_winCamp", 0))
	return {"camp": camp, "win": camp != 0 and win_camp == camp, "draw": win_type == 4, 
		"surrender": win_type == 3, "seconds": int(outcome.get("m_battleTime", 0)), "rows": rows}










const CH1_ON: bool = true
const CH1_GAP: float = 0.2
const CH1_MOVERS: int = 2
const CH1_MAX_T: float = 0.3
const CH1_CATCH_T: float = 0.12
const CH1_SNAP_MAX: float = 96.0
const CH1_BACK_WAIT: float = 0.18
const CH1_HOLD: float = 0.45
const CH1_CALM_T: float = 1.5


func _ch1_rx() -> void :
	if not ch1_on:
		return
	var last: float = float(ch1.rx)
	if last >= 0 and clock - last >= CH1_GAP:
		ch1.end = clock
	ch1.rx = clock


func _ch1_speed(id: int, tank: Dictionary, speed_in: float, kind: int, direction: int, pos: Vector2) -> float:
	if not ch1_on or id == self_id or npcs.has(id) or not tanks.has(id):
		return speed_in
	var speed_out: float = speed_in
	if kind == 0 and direction < 8 and speed_in > 0:
		var norm: float = float(tank.get("ch1_v", 0.0))
		if clock - float(ch1.end) < CH1_CALM_T:
			if norm > 0 and speed_in > norm * 1.15:
				speed_out = norm
		else:
			tank.ch1_v = speed_in
		var gap: float = clock - float(tank.get("ch1_last", -100.0))
		tank.ch1_run = int(tank.get("ch1_run", 0)) + 1 if gap <= STEPS[direction].length() / speed_out * 1.5 + 0.05 else 1
	else:
		tank.ch1_run = 0
	if kind != 0:
		tank.erase("ch1x")
	tank.ch1_last = clock
	tank.ch1_k = kind
	tank.ch1_dir = direction
	tank.ch1_from = pos
	tank.ch1_sv = speed_out
	return speed_out


func _ch1_idle(obj: Dictionary, own: bool) -> Dictionary:
	if ch1_on and not own:
		var step: Dictionary = _ch1_next(obj)
		if not step.is_empty():
			return step
	return {"pos": obj.pos, "dir": 8, "speed": 0.0}


func _ch1_hold(tank: Dictionary, step: Dictionary) -> bool:
	if not ch1_on or not tank.has("ch1x"):
		return false
	var queue: Array = tank.get("queue", [])
	queue.append(step)
	tank.queue = queue
	return true


func _ch1_step_t(t: Dictionary) -> float:
	var d: int = int(t.get("ch1_dir", 8))
	return STEPS[d].length() / maxf(float(t.get("ch1_sv", 0.0)), 1.0) if d >= 0 and d < 8 else 0.0

func _ch1_recent(t: Dictionary) -> bool:
	return int(t.get("ch1_k", -1)) == 0 and int(t.get("ch1_run", 0)) >= 2 and _ch1_step_t(t) > 0\
	and float(t.get("ch1_last", -100.0)) >= float(ch1.rx) - (_ch1_step_t(t) * 1.25 + 0.03)

func _ch1_can_start(obj: Dictionary) -> bool:
	if not _ch1_recent(obj) or float(obj.get("ch1_done", -1.0)) == float(ch1.rx):
		return false
	if clock - float(ch1.rx) < maxf(CH1_GAP, _ch1_step_t(obj) * 1.35):
		return false
	var d: int = int(obj.ch1_dir)
	if obj.pos.distance_to(Vector2(obj.ch1_from) + STEPS[d]) > 0.5:
		return false
	var movers: int = 0
	for t: Dictionary in tanks.values():
		if int(t.id) != self_id and not t.dead and _ch1_recent(t):
			movers += 1
	return movers >= CH1_MOVERS

func _ch1_free(obj: Dictionary, to: Vector2) -> bool:
	if not map.can_move(to, npcs, obj.pos):
		return false
	for t: Dictionary in tanks.values():
		if t.dead or int(t.id) == int(obj.id):
			continue
		var d: Vector2 = Vector2(t.pos) - to
		if absf(d.x) < 60 and absf(d.y) < 60:
			return false
	for npc: Dictionary in npcs.values():
		if npc.dead:
			continue
		if (int(npc.template) in ENERGY_PILLARS and to.distance_to(npc.pos) < ENERGY_PILLAR_REACH + 24)\
		or (int(npc.template) == TORNADO and to.distance_to(npc.pos) < TORNADO_REACH + 24):
			return false
	return true


func _ch1_next(obj: Dictionary) -> Dictionary:
	var id: int = int(obj.get("id", 0))
	if id == self_id or npcs.has(id) or not tanks.has(id) or obj.dead or ended or obj.has("throw")\
	or has_buff(obj, BUFF_AUTO_MOVE) or _stilled(obj):
		return {}
	var x: Dictionary = obj.get("ch1x", {})
	var d: int
	var v: float
	if x.is_empty():
		if not _ch1_can_start(obj):
			return {}
		d = int(obj.ch1_dir)
		v = float(obj.ch1_sv)
	else:
		if obj.pos.distance_to(x.at) > 0.5 or float(ch1.rx) != float(x.rx):
			return {}
		d = int(x.dir)
		v = float(x.v)
		if clock - float(x.t0) + STEPS[d].length() / v > CH1_MAX_T + 0.02:
			return {}
	var to: Vector2 = obj.pos + STEPS[d]
	if not _ch1_free(obj, to):
		return {}
	if x.is_empty():
		x = {"anchor": obj.pos, "t0": clock, "dir": d, "v": v, "rx": float(ch1.rx)}
		obj.ch1x = x
		obj.ch1_done = float(ch1.rx)
		ch1.live = true
		ch1.made = int(ch1.get("made", 0)) + 1
	x.at = to
	return {"pos": obj.pos, "dir": d, "speed": v}


func _ch1_pre() -> void :
	if not ch1_on or ( not bool(ch1.get("live", false)) and clock - float(ch1.rx) < CH1_GAP) or float(ch1.rx) < 0 or ended:
		return
	var live: bool = false
	for t: Dictionary in tanks.values():
		if int(t.id) == self_id:
			continue
		if not t.has("ch1x"):
			if not t.get("moving", false) and t.get("queue", []).is_empty() and Vector2(t.pos).distance_to(t.target) <= 0.5:
				var step: Dictionary = _ch1_next(t)
				if not step.is_empty():
					_begin_step(t, step)
					live = true
			continue
		var x: Dictionary = t.ch1x
		if t.dead or t.has("throw"):
			t.erase("ch1x")
			continue
		live = true
		var queue: Array = t.get("queue", [])
		if float(t.get("ch1_last", -100.0)) > float(x.rx) and not queue.is_empty():
			_ch1_rebase(t, x, queue)
			continue
		if Vector2(t.target).distance_to(x.at) > 0.5:
			t.erase("ch1x")
			continue
		if t.get("moving", false) and clock - float(x.t0) > CH1_MAX_T + 0.02:
			t.target = t.pos
			t.moving = false
			x.at = t.pos
		if float(t.get("ch1_last", -100.0)) <= float(x.rx) and ((float(ch1.rx) != float(x.rx) and clock - float(ch1.end) >= CH1_BACK_WAIT)\
		or clock - float(x.t0) >= CH1_HOLD):
			var back: float = Vector2(t.pos).distance_to(x.anchor)
			t.target = x.anchor
			t.speed = maxf(float(x.v), back / CH1_CATCH_T)
			t.erase("cl1_b")
			t.moving = false
			t.queue = []
			t.erase("ch1x")
			ch1.back = int(ch1.get("back", 0)) + 1
	ch1.live = live


func _ch1_rebase(t: Dictionary, x: Dictionary, queue: Array) -> void :
	t.erase("ch1x")
	var at: Vector2 = t.pos
	var best: int = -1
	var best_d: float = INF
	var segs: Array = []
	for e: Dictionary in queue:
		var a: Vector2 = e.pos
		var dir: int = int(e.dir)
		var b: Vector2 = a + STEPS[dir] if dir >= 0 and dir < 8 and float(e.speed) > 0 else a
		segs.append([a, b])
		var g: Vector2 = Geometry2D.get_closest_point_to_segment(at, a, b)
		if at.distance_to(g) <= best_d + 0.01:
			best_d = at.distance_to(g)
			best = segs.size() - 1
	var to: Vector2 = segs[best][1]
	var ok: bool = best_d <= CH1_SNAP_MAX and queue.size() <= 6
	var n: int = ceili(at.distance_to(to) / 12.0)
	var prev: Vector2 = at
	for i in range(1, n + 1):
		if not ok:
			break
		var p: Vector2 = at.lerp(to, float(i) / n)
		ok = map.can_move(p, npcs, prev)
		prev = p
	if not ok:

		if not t.get("moving", false):
			_begin_step(t, queue.pop_front())
		ch1.snap = int(ch1.get("snap", 0)) + 1
		return
	var rest: Array = queue.slice(best + 1)
	var length: float = at.distance_to(to)
	for s: Array in segs.slice(best + 1):
		length += Vector2(s[0]).distance_to(s[1])
	var v: float = clampf(length / CH1_CATCH_T, float(x.v), float(x.v) * 3.0)
	var e0: Dictionary = queue[best]
	if int(e0.dir) >= 0 and int(e0.dir) < 8 and float(e0.speed) > 0:
		t.direction = int(e0.dir)
	for e: Dictionary in rest:
		e.erase("cl1")
		e.erase("at")
		if float(e.speed) > 0:
			e.speed = v
	t.erase("cl1_b")
	t.target = to
	t.speed = v
	t.queue = rest
	t.moving = Vector2(segs[best][0]) != Vector2(segs[best][1]) or not rest.is_empty()
	t.erase("gait")
	ch1.glide = int(ch1.get("glide", 0)) + 1






















const CL1_ON: bool = true
const CL1_BUF: bool = false
const CL1_BUF_T: float = 0.1
const CL1_N0: float = 2.25
const CL1_KEEP: float = 1.25
const CL1_CATCH_T: float = 0.13
const CL1_QMAX: int = 10
const CL1_GLIDE_MAX: float = 36.0
const CL1_HALT_T: float = 0.1
const CL1_HALT_SNAP: float = 96.0
const CL1_XT: float = 0.15
const CL1_XBACK: float = 0.3
const CL1_RUN_GAP: float = 0.5
const CL1_VR_KEEP: float = 5.0

static func _cl1_buf_flag() -> bool:
	if not CL1_ON or not OS.has_feature("web"):
		return CL1_BUF
	return CL1_BUF or str(JavaScriptBridge.eval("location.search", true)).contains("cl1buf=1")



func _cl1_sync(id: int, tank: Dictionary, kind: int) -> bool:
	if tank.has("cl1x"):
		tank.erase("cl1x")
		tank.erase("cl1_b")
		tank.target = tank.pos
		tank.moving = false
		tank.speed = 0.0
	return cl1_on and id != self_id and tanks.has(id) and not npcs.has(id) and not (kind in [1, 3, 4])



func _cl1_base(tank: Dictionary, v_in: float, kind: int, direction: int, pos: Vector2) -> float:
	tank.cl1_pk = clock
	if kind != 0 or direction < 0 or direction > 7 or v_in <= 0:
		tank.erase("cl1_at")
		return v_in
	if tank.has("cl1_at"):
		var dt: float = clock - float(tank.cl1_at)
		var d: float = pos.distance_to(tank.cl1_from)
		if dt > 0 and dt <= CL1_RUN_GAP and d > 0.5 and d <= 48.0:
			var rate: float = d / dt
			if rate >= 60.0 and rate <= 600.0:
				var n: int = int(tank.get("cl1_n", 0))
				tank.cl1_vr = rate if n == 0 or clock - float(tank.get("cl1_vt", -100.0)) > CL1_VR_KEEP else lerpf(float(tank.cl1_vr), rate, 0.25)
				tank.cl1_n = n + 1
				tank.cl1_vt = clock
	tank.cl1_at = clock
	tank.cl1_from = pos
	var vr: float = float(tank.get("cl1_vr", 0.0))
	if vr <= 0 or int(tank.get("cl1_n", 0)) < 3 or clock - float(tank.get("cl1_vt", -100.0)) > CL1_VR_KEEP:
		return v_in
	return clampf(v_in, vr * 0.85, vr * 1.15)


static func _cl1_entry(entry: Dictionary, v: float, buf: bool, now: float) -> void :
	entry.cl1 = true
	entry.cl1v = v
	if buf:
		entry.at = now + CL1_BUF_T




func _cl1_v(obj: Dictionary) -> float:
	if Vector2(obj.target) != Vector2(obj.get("cl1_t", Vector2.INF)):
		obj.erase("cl1_b")
		obj.erase("cl1_ce")
		return float(obj.speed)
	var base: float = float(obj.cl1_b)
	if obj.has("cl1x"):
		var x: Dictionary = obj.cl1x
		var k: float = 1.0 - (clock - float(x.t0)) / CL1_XT if CL1_XT > 0 else 0.0
		if k <= 0.0:
			obj.target = obj.pos
			obj.moving = false
			obj.erase("cl1_b")
			x.tg = obj.pos
			return 0.0
		return float(x.v) * k
	var d: int = clampi(int(obj.get("direction", 0)), 0, 7)
	var step: float = STEPS[d].length()
	var left: float = Vector2(obj.pos).distance_to(obj.target)
	for e: Dictionary in obj.get("queue", []):
		var ed: int = int(e.dir)
		if ed >= 0 and ed < 8 and float(e.speed) > 0:
			left += STEPS[ed].length()
	var ce: float = float(obj.get("cl1_ce", -1.0))
	if clock >= ce:
		var n0: float = CL1_N0 + (CL1_BUF_T * base / step if cl1_buf else 0.0)
		if left <= n0 * step:
			obj.erase("cl1_ce")
			return base
		ce = clock + CL1_CATCH_T
		obj.cl1_ce = ce
		cl1.catch = int(cl1.get("catch", 0)) + 1
	var extra: float = left - CL1_KEEP * step
	if extra <= 0.5:
		obj.erase("cl1_ce")
		return base
	return base + extra / maxf(ce - clock, 0.05)


func _cl1_line(a: Vector2, b: Vector2) -> bool:
	var n: int = ceili(a.distance_to(b) / 12.0)
	var prev: Vector2 = a
	for i in range(1, n + 1):
		var p: Vector2 = a.lerp(b, float(i) / n)
		if not map.can_move(p, npcs, prev):
			return false
		prev = p
	return true



func _cl1_begin(obj: Dictionary, step: Dictionary) -> void :
	if not cl1_on or not step.has("cl1") or obj.has("throw"):
		_begin_step(obj, step)
		return
	var from: Vector2 = obj.pos
	var d: float = from.distance_to(step.pos)
	if d <= 0.5:
		_begin_step(obj, step)
		return
	var stop: bool = int(step.dir) < 0 or int(step.dir) > 7 or float(step.speed) <= 0
	_begin_step(obj, step)
	if d > (CL1_HALT_SNAP if stop else CL1_GLIDE_MAX) or not _cl1_line(from, obj.target):
		cl1.snap = int(cl1.snap) + 1
		return
	obj.pos = from
	if stop:
		obj.speed = d / CL1_HALT_T
	cl1.glide = int(cl1.glide) + 1


func _cl1_idle(obj: Dictionary, own: bool) -> Dictionary:
	var step: Dictionary = _ch1_idle(obj, own)
	if own or not cl1_on or CL1_XT <= 0 or int(step.dir) != 8 or obj.has("ch1x") or not obj.has("cl1_b"):
		return step
	var d: int = int(obj.get("direction", 8))
	var x: Dictionary = obj.get("cl1x", {})
	if d < 0 or d > 7 or obj.dead or ended or obj.has("throw") or has_buff(obj, BUFF_AUTO_MOVE) or _stilled(obj):
		return step
	if x.is_empty():
		var v: float = float(obj.cl1_b)

		if v <= 0 or Vector2(obj.pos) != Vector2(obj.get("cl1_t", Vector2.INF))\
		or clock - float(obj.get("cl1_pk", -100.0)) > 2.0 * STEPS[d].length() / v + 0.1:
			return step
		x = {"t0": clock, "anchor": obj.pos, "dir": d, "v": v}
	elif clock - float(x.t0) >= CL1_XT or int(x.dir) != d:
		return step
	if not _ch1_free(obj, obj.pos + STEPS[d]):
		return step
	if not obj.has("cl1x"):
		obj.cl1x = x
		cl1.x = int(cl1.get("x", 0)) + 1
	x.tg = obj.pos + STEPS[d]
	return {"pos": obj.pos, "dir": d, "speed": float(x.v), "cl1": true, "cl1x": true}


func _cl1_halt(tank: Dictionary, pos: Vector2) -> bool:
	tank.erase("cl1x")
	if not cl1_on or int(tank.get("id", 0)) == self_id or tank.dead or tank.has("throw") or tank.has("ch1x"):
		return false
	if cl1_buf and (tank.get("moving", false) or not tank.get("queue", []).is_empty()):
		var queue: Array = tank.get("queue", [])
		queue.append({"pos": pos, "dir": 8, "speed": 0.0, "cl1": true, "at": clock + CL1_BUF_T})
		tank.queue = queue
		tank.server = pos
		return true
	var from: Vector2 = tank.pos
	var d: float = from.distance_to(pos)
	if d <= 0.5:
		return false
	if d > CL1_HALT_SNAP or not _cl1_line(from, pos):
		cl1.snap = int(cl1.snap) + 1
		return false
	_halt(tank, pos)
	tank.pos = from
	tank.speed = d / CL1_HALT_T
	cl1.lerp = int(cl1.lerp) + 1
	return true



func _cl1_pre() -> void :
	if not cl1_on or ended:
		return
	for t: Dictionary in tanks.values():
		if int(t.id) == self_id:
			continue
		if t.has("cl1x"):
			_cl1_xtick(t)
		if not cl1_buf or t.dead or t.has("ch1x") or t.has("throw") or t.get("moving", false):
			continue
		var queue: Array = t.get("queue", [])
		if queue.is_empty() or clock < float(queue[0].get("at", -1.0)):
			continue
		_cl1_begin(t, queue.pop_front())

func _cl1_xtick(t: Dictionary) -> void :
	var x: Dictionary = t.cl1x
	if t.dead or t.has("throw") or t.has("ch1x") or Vector2(t.target) != Vector2(x.get("tg", t.target)):
		t.erase("cl1x")
		return
	var anchor: Vector2 = x.anchor
	var d: int = int(x.dir)
	if ch1_on and float(t.get("ch1_done", -1.0)) != float(ch1.rx):

		var at: Vector2 = t.pos
		t.pos = anchor
		var can: bool = _ch1_can_start(t)
		t.pos = at
		if can:
			t.erase("cl1x")
			t.erase("cl1_b")
			t.erase("cl1_ce")
			var to: Vector2 = anchor + STEPS[d]
			t.ch1x = {"anchor": anchor, "t0": clock, "dir": d, "v": float(x.v), "rx": float(ch1.rx), "at": to}
			t.ch1_done = float(ch1.rx)
			ch1.live = true
			ch1.made = int(ch1.get("made", 0)) + 1
			t.direction = d
			t.target = to
			t.speed = float(x.v)
			t.moving = true
			t.queue = []
			cl1.ch1 = int(cl1.get("ch1", 0)) + 1
			return
	if clock - float(x.t0) >= CL1_XBACK:
		t.erase("cl1x")
		t.erase("cl1_b")
		var back: float = Vector2(t.pos).distance_to(anchor)
		t.target = anchor
		t.speed = maxf(float(x.v), back / CL1_HALT_T)
		t.moving = false
		t.queue = []
		cl1.back = int(cl1.get("back", 0)) + 1
