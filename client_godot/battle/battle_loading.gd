extends Control














const Text = preload("../i18n.gd")
const TankPortrait = preload("../ui/tank_portrait.gd")
const TankPreview = preload("../ui/tank_preview.gd")
const GarageModel = preload("../ui/garage_model.gd")
const Proficiency = preload("../ui/proficiency.gd")

const COSMIC_ITEMS: Dictionary = {"2620002": ["Chìa Khóa Bí Cảnh Vũ Trụ No.2", "yaoshi1001", 5], "2620003": ["Chìa Khóa Bí Cảnh Vũ Trụ No.3", "yaoshi1001", 5], "2620004": ["Chìa Khóa Bí Cảnh Vũ Trụ No.4", "yaoshi1001", 5], "2620005": ["Chìa Khóa Bí Cảnh Vũ Trụ No.5", "yaoshi1001", 5], "2620006": ["Chìa Khóa Bí Cảnh Vũ Trụ No.6", "yaoshi1001", 5], "2620007": ["Chìa Khóa Bí Cảnh Vũ Trụ No.7", "yaoshi1001", 5], "2620008": ["Chìa Khóa Bí Cảnh Vũ Trụ No.8", "yaoshi1001", 5], "2620009": ["Chìa Khóa Bí Cảnh Vũ Trụ No.9", "yaoshi1001", 5], "2620010": ["Chìa Khóa Bí Cảnh Vũ Trụ No.10", "yaoshi1001", 5], "2620011": ["Chìa Khóa Bí Cảnh Vũ Trụ No.11", "yaoshi1001", 5], "2620012": ["Chìa Khóa Bí Cảnh Vũ Trụ No.12", "yaoshi1001", 5], "2620013": ["Chìa Khóa Bí Cảnh Vũ Trụ No.13", "yaoshi1001", 5], "2620014": ["Chìa Khóa Bí Cảnh Vũ Trụ No.14", "yaoshi1001", 5], "2620015": ["Chìa Khóa Bí Cảnh Vũ Trụ No.15", "yaoshi1001", 5], "2620016": ["Chìa Khóa Bí Cảnh Vũ Trụ No.16", "yaoshi1001", 5], "2620017": ["Chìa Khóa Bí Cảnh Vũ Trụ No.17", "yaoshi1001", 5], "2620018": ["Chìa Khóa Bí Cảnh Vũ Trụ No.18", "yaoshi1001", 5], "2620019": ["Chìa Khóa Bí Cảnh Vũ Trụ No.19", "yaoshi1001", 5], "2620020": ["Chìa Khóa Bí Cảnh Vũ Trụ No.20", "yaoshi1001", 5], "2620021": ["Chìa Khóa Bí Cảnh Vũ Trụ No.21", "yaoshi1001", 5], "2620022": ["Chìa Khóa Bí Cảnh Vũ Trụ No.22", "yaoshi1001", 5], "2620023": ["Chìa Khóa Bí Cảnh Vũ Trụ No.23", "yaoshi1001", 5], "2620024": ["Chìa Khóa Bí Cảnh Vũ Trụ No.24", "yaoshi1001", 5], "2620025": ["Chìa Khóa Bí Cảnh Vũ Trụ No.25", "yaoshi1001", 5], "2620026": ["Chìa Khóa Bí Cảnh Vũ Trụ No.26", "yaoshi1001", 5], "2620027": ["Chìa Khóa Bí Cảnh Vũ Trụ No.27", "yaoshi1001", 5], "2620028": ["Chìa Khóa Bí Cảnh Vũ Trụ No.28", "yaoshi1001", 5], "2620029": ["Chìa Khóa Bí Cảnh Vũ Trụ No.29", "yaoshi1001", 5], "2620030": ["Chìa Khóa Bí Cảnh Vũ Trụ No.30", "yaoshi1001", 5], "2620031": ["Chìa Khóa Bí Cảnh Vũ Trụ No.31", "yaoshi1001", 5], "3700006": ["Chip siêu dẫn No.6", "icon_zhushou_jingyan06", 3], "3700007": ["Chip siêu dẫn No.7", "icon_zhushou_jingyan07", 4], "3700008": ["Chip siêu dẫn No.8", "icon_zhushou_jingyan08", 4], "4051001": ["Tinh hoa nguyệt thạch cấp 1", "icon_gz_nlk_02", 1], "4051002": ["Tinh hoa nguyệt thạch cấp 2", "icon_gz_nlk_03", 1], "4051003": ["Tinh hoa nguyệt thạch cấp 3", "icon_gz_nlk_04", 2], "4051004": ["Tinh hoa nguyệt thạch cấp 4", "icon_gz_nlk_05", 2], "4051005": ["Tinh hoa nguyệt thạch cấp 5", "icon_gz_nlk_06", 3], "4051006": ["Tinh hoa nguyệt thạch cấp 6", "icon_gz_nlk_07", 3], "4051007": ["Tinh hoa nguyệt thạch cấp 7", "icon_gz_nlk_08", 4], "4051121": ["Mảnh Tinh Hoa Nguyệt Thạch Lv1", "icon_yueshilv01", 2], "4051122": ["Mảnh Tinh Hoa Nguyệt Thạch Lv2", "icon_yueshilv02", 2], "4051123": ["Mảnh Tinh Hoa Nguyệt Thạch Lv3", "icon_yueshilv03", 3], "4051124": ["Mảnh Tinh Hoa Nguyệt Thạch Lv4", "icon_yueshilv04", 3], "4051125": ["Mảnh Tinh Hoa Nguyệt Thạch Lv5", "icon_yueshilv05", 4], "4051126": ["Mảnh Tinh Hoa Nguyệt Thạch Lv6", "icon_yueshilv06", 4], "4051127": ["Mảnh Tinh Hoa Nguyệt Thạch Lv7", "icon_yueshilv07", 5]}
const COSMIC_MOON: Array = [5, 10, 15, 20, 25, 30, 35]
const HelperModel = preload("../ui/helper_model.gd")
const BagModel = preload("../ui/bag_model.gd")
const HelperTip = preload("../ui/helper_tip.gd")
const Love = preload("../ui/love.gd")
const NameStyles = preload("../ui/name_styles.gd")

const BACK: Color = Color("0054b3")
const PVE_TYPES: Array = [2, 3, 4, 9, 10, 11, 16]
const HAPPY_ROOMS: Array = [100, 101]
const PVP_CELLS: Array = [0, 1, 2, 3, 4, 6, 7, 8, 9, 10]
const HAPPY_CELLS: Array = [0, 9, 7, 1, 2, 6]
const PVP_POS: Dictionary = {0: Vector2(-510, -104), 1: Vector2(-310, -208), 2: Vector2(-310, -1), 3: Vector2(-510, -309), 
	4: Vector2(-510, 100), 6: Vector2(278, -104), 7: Vector2(75, -208), 8: Vector2(75, -1), 9: Vector2(278, -309), 10: Vector2(278, 100)}
const HAPPY_POS: Dictionary = {0: Vector2(68, -213), 1: Vector2(-121, -311), 2: Vector2(-310, -213), 6: Vector2(-310, -20), 
	7: Vector2(-121, 78), 9: Vector2(68, -20)}
const SOLE_POS: Vector2 = Vector2(-412.5, -95)
const BACK_POS: Vector2 = Vector2(-122.5, 45)
const CELL: Vector2 = Vector2(235, 190)
const ROBOT_MAX: int = 100000
const WAIT: int = 61
const SECTIONS: Array = [[3, "bronze"], [6, "silver"], [9, "golden"], [12, "platnum"], [16, "diamon"], [17, "epic"]]

const VIP_TONES: Array = [["f3fd12", "449900", "004400"], ["ffc6fe", "aa00ff", "7700cc"], ["ffff44", "ff2200", "6c400b"]]
const LEAVE_AFTER: float = 20.0
const HELPER_AT: Rect2 = Rect2(140, 10, 50, 50)
const HONOR_AT: Rect2 = Rect2(20.5, 51, 30, 30)
const SKILL_AT: Rect2 = Rect2(195, 80, 30, 30)


const TANK_RANK_AT: Rect2 = Rect2(-1.5, 70, 40, 40)
const TANK_RANK_INK: Color = Color("ffff1f")
const TANK_RANK_GLOW: Color = Color(0.678, 0.145, 0.0, 0.8)









const TT3_SIDE: float = 43.0
const TT3_CACHE_MAX: int = 32
const TT3_SHARP_UP: float = 0.6
const TT3_SHARP_DOWN: float = 1.2
const PROF_AT: Rect2 = Rect2(235.0 - 52.5 - TT3_SIDE / 2.0, 37.0 - TT3_SIDE / 2.0, TT3_SIDE, TT3_SIDE)




const VS1_SKILL_AT: Rect2 = Rect2(186, 80, 30, 30)
const VS1_PING_GAP: float = 3.0
const VS1_PING_LEFT: float = 166.0
const VS1_PING_BOTTOM: float = 143.0
const PROF_HALO: float = 3.0
const PROF_HALO_ALPHA: float = 0.4
const PROF_PING_MIN_PX: float = 9.0

const PING1_GAP: float = 3.0
const PING1_INK: float = 0.75
const PROF_BACK: String = "rim"
var prof_back: String = PROF_BACK
var ping1_k: float = 0.0
var _prof_halo: GradientTexture2D = null
const CLAN_PAD: float = 34.0
const TIP_WIDE: float = 230.0
const TIP_BORDER: Color = Color(0.435, 0.816, 1.0, 0.55)
const PVE_TIP_EVERY: float = 7.0
const BOSS_AT: Vector2 = Vector2(266, -80)
const REWARD_AT: Vector2 = Vector2(267, 80)
const REWARD_TILE: Vector2 = Vector2(136, 40)
const REWARD_MAX: int = 10
const REWARD_TITLE: String = "l/gda/awardgoods.webp"
const REWARD_BACK: Color = Color(0.008, 0.169, 0.502, 0.4)
const TIP_PILL: Vector2 = Vector2(460, 50)
const TIP_LINE_AT: Vector2 = Vector2(0, 228)
const WORDTIP_SCALE: float = 0.7

const PREVIEW_MID_Y: float = -215.0
const PREVIEW_GAP: float = 3.0
const PREVIEW_LABEL_H: float = 22.0
const PREVIEW_LABEL_GUTTER: float = 2.0


const PREVIEWS: Array = [1, 4, 7, 9, 10, 12, 14, 17, 18, 19, 20, 21, 30, 34, 35, 36, 37, 40, 50, 70, 101, 102, 103, 104, 130, 152, 166, 167, 169, 170, 175, 177, 333, 334, 1201, 1202]



const ENTRY_RING: int = 612111
const HOLD_MAX: float = 35.0
const ALL_READY_GRACE: float = 1.5

var client: Node
var pack: Node
var hud
var seconds: float = 0.0
var _s: float = 1.0
var _scene: int = -1
var _time: float = 0.0
var _beat: int = 0
var _robots: Dictionary = {}
var _box: StyleBoxFlat = StyleBoxFlat.new()
var _tip_box: StyleBoxFlat = StyleBoxFlat.new()
var _asked_scene: int = -1
var _mouse: Vector2 = Vector2(-1, -1)
var _tips: Array = []
var _love_tones: Dictionary = {}
var _love_names: Dictionary = {}
var _pve: bool = false
var _pve_tip: String = ""
var _pve_tip_at: float = -1.0
var _panel: StyleBoxFlat = StyleBoxFlat.new()
var _hold_done: int = -1
var _hold_for: int = -1
var _hold_at: float = 0.0
var _all_since: float = -1.0
var hold_why: String = ""
var _prewarm_for: String = ""
const PREWARM_USEC: int = 3000

func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

func _notification(what: int) -> void :
	if what == NOTIFICATION_VISIBILITY_CHANGED and not visible:
		_scene = -1
		_mouse = Vector2(-1, -1)
		if pack != null and pack.has_method("drop_fresh"):
			pack.drop_fresh()
		if client != null and client.get("loading_held") != null:
			client.loading_held = false
	elif what == NOTIFICATION_MOUSE_EXIT:
		_mouse = Vector2(-1, -1)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		_mouse = event.position
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_mouse = event.position
		_chat_click(event.position)



func _chat_click(point: Vector2) -> void :
	var view: Variant = hud.view if hud != null else null
	if view == null or view.chat_ui == null or not view.chat_ui.click(point):
		return
	view.loading_chat_focus()
	accept_event()


static func state_of(battle, map_type: int) -> String:
	if battle.enter_type == 1:
		return "reconnect"
	if battle.enter_type == 2:
		return "look"
	if battle.room_type in HAPPY_ROOMS:
		return "happy_sole" if _camps(battle)[0].size() == 1 else "happy"
	return "pve" if map_type in PVE_TYPES else "pvp"


static func _camps(battle) -> Array:
	var a: Array = []
	var b: Array = []
	for brief: Dictionary in battle.roster:
		if int(brief.get("bCamp", 0)) == 2:
			b.append(brief)
		else:
			a.append(brief)
	if battle.room_type in HAPPY_ROOMS and battle.enter_type != 2:
		for i in range(a.size()):
			if _id(a[i]) == battle.self_id:
				a.push_front(a.pop_at(i))
				break
	return [a, b]

static func _id(brief: Dictionary) -> int:
	return int(brief.get("charData", {}).get("nAcctId", 0))


static func self_camp(battle) -> int:
	for brief: Dictionary in battle.roster:
		if _id(brief) == battle.self_id:
			return int(brief.get("bCamp", 1))
	return int(battle.roster[0].get("bCamp", 1)) if battle.enter_type == 2 and not battle.roster.is_empty() else 1


static func slots(battle, state: String) -> Array:
	var camps: Array = _camps(battle)
	var out: Array = []
	if state in ["reconnect", "look"]:
		for brief: Dictionary in battle.roster:
			if _id(brief) == battle.self_id or state == "look":
				out.append({"cell": 0, "pos": BACK_POS, "brief": brief, "camp": int(brief.get("bCamp", 1))})
				break
		return out
	if state in ["happy", "happy_sole"]:
		for i in range(mini(camps[0].size(), HAPPY_CELLS.size())):
			var cell: int = HAPPY_CELLS[i]
			out.append({"cell": cell, "pos": SOLE_POS if state == "happy_sole" else HAPPY_POS[cell], "brief": camps[0][i], "camp": 1})
		return out
	for side in range(2):
		if side == 1 and state == "pve":
			break
		for i in range(mini(camps[side].size(), 5)):
			var cell: int = PVP_CELLS[i + side * 5]
			out.append({"cell": cell, "pos": PVP_POS[cell], "brief": camps[side][i], "camp": side + 1})
	return out


static func robot_rate(before: int, mine: int, second: int, roll: int) -> int:
	return maxi(before, mini(100, maxi(mine + roll + 1, second * (roll + 5))))

static func section_name(id: int) -> String:
	if id <= 0:
		return ""
	for row: Array in SECTIONS:
		if id <= int(row[0]):
			return str(row[1])
	return ""


static func military_rank(ranks: Array, stars: int) -> int:
	var out: int = 0
	for i in range(ranks.size()):
		var nodes: Array = ranks[i][2]
		if (int(nodes[0][0]) if not nodes.is_empty() else 0) <= stars:
			out = i + 1
	return out

static func ping_color(delay: int) -> Color:
	if delay < 0:
		return Color("c0c0c0")
	return Color("00ff00") if delay <= 200 else Color("ffff00") if delay <= 400 else Color("ff0000")


static func ping_text(delay: int) -> String:
	return "%dms" % delay if delay >= 0 else "--ms"


static func guild_skill(guild: Dictionary, packed: int, pve: bool) -> int:
	var pair: Array = guild.get(str(packed), [])
	if pair.size() < 2:
		return 0
	return int(pair[1] if pve else pair[0])


static func team_rank_path(place: int, clan: int) -> String:
	return "l/gda/cr/rank_%d.webp" % place if place >= 1 and place <= clan else ""


static func ornate_path(ornate: Dictionary, item: int) -> String:
	var stem: String = str(ornate.get(str(item), "")) if item > 0 else ""
	return "" if stem.is_empty() else "l/gda/or/%s.webp" % stem




static func ornate_live(live: Variant, ornate: Dictionary, item: int) -> String:
	var table: Variant = (live as Dictionary).get("lornate") if live is Dictionary else null
	if item > 0 and table is Dictionary and (table as Dictionary).has(str(item)):
		var stem: Variant = (table as Dictionary)[str(item)]
		return "l/gda/or/%s.webp" % stem if stem is String and not (stem as String).is_empty() else ""
	return ornate_path(ornate, item)



static func ornate_pack_anim(live: Variant, gda: Dictionary, path: String) -> Variant:
	var fresh: Variant = (live as Dictionary).get("anim") if live is Dictionary else null
	if path.is_empty() or (fresh is Dictionary and (fresh as Dictionary).has(path)) or not (gda.get("anim") is Dictionary):
		return null
	return (gda.get("anim") as Dictionary).get(path)




static func ornate_region(row: Variant, now_ms: int) -> Rect2:
	if not (row is Array) or (row as Array).size() < 6 or not ((row as Array)[5] is Array) or ((row as Array)[5] as Array).is_empty():
		return Rect2()
	var line: Array = row
	var seq: Array = line[5]
	var wide: float = float(line[2])
	var high: float = float(line[3])
	var cols: int = maxi(1, int(line[4]))
	if wide <= 0.0 or high <= 0.0 or float(line[1]) <= 0.0:
		return Rect2()
	var cell: int = maxi(0, int(seq[int(float(now_ms) * float(line[1]) / 1000.0) % seq.size()]))
	var row_at: int = int(float(cell) / float(cols))
	return Rect2(float(cell - row_at * cols) * wide, float(row_at) * high, wide, high)



static func helper_game(who: Node) -> bool:
	var battle = who.battle
	return HelperModel.famulus_game(int(battle.room_type), [int(battle.map_id), int(who.room_state.room.get("roomConfig", {}).get("m_nMapId", 0))])

static func helper_record(helper: Dictionary, more: Dictionary, other: Dictionary) -> Dictionary:
	var inst: Dictionary = {"m_templateId": int(other.get("btItemId", 0)), "m_level": int(other.get("btLevel", 0)), 
		"m_rank": int(other.get("btRank", 0)), "m_upLevel": int(other.get("btUpLevel", 0)), "m_upCost": int(other.get("btUpCost", 0)), 
		"m_rankCost": int(other.get("btRankCost", 0))}
	return HelperModel.record(inst, helper, {"more": more}, "")


static func helper_lines(rec: Dictionary) -> String:
	if rec.is_empty():
		return ""
	return "\n".join(PackedStringArray([
		"Loại: %s" % str(HelperModel.TYPES.get(int(rec.type), "—")), 
		"Tư chất: %d" % int(rec.apt), 
		"LV: %d/%d" % [int(rec.lv), int(rec.lv_max)], 
		"Cường hóa: %d/%d" % [int(rec.up), int(rec.up_max)], 
		"Sao: %d/%d" % [int(rec.rank), int(rec.rank_max)], 
		"Chiến Lực: %d" % int(rec.score)]))

func stuck() -> bool:
	if client != null and client.battle.started:
		return false
	return visible and seconds >= LEAVE_AFTER



func hold() -> bool:
	if client == null or not visible:
		return false
	var battle = client.battle
	var key: int = int(battle.begun)
	if not battle.active or not battle.started or battle.ended or battle.look or battle.enter_type in [1, 2] or _hold_done == key:
		if client.get("loading_held") != null:
			client.loading_held = false
		return false
	if _hold_for != key:
		_hold_for = key
		_hold_at = seconds
		_all_since = -1.0
	var why: String = hold_release(battle)
	if client.get("loading_held") != null:
		client.loading_held = why.is_empty()
	if why.is_empty():
		return true
	_hold_done = key
	hold_why = why
	print("[BG4] vào trận cùng phòng: %s, giữ %.1f s sau 1586" % [why, maxf(0.0, seconds - _hold_at)])
	return false



func hold_release(battle) -> String:
	var others: Array = []
	for brief: Dictionary in battle.roster:
		var id: int = _id(brief)
		if id > 0 and id != battle.self_id and not _robot(id, battle):
			others.append(id)
	if others.is_empty():
		return "một mình"
	for buff in battle.tanks.get(battle.self_id, {}).get("buffs", {}).values():
		if buff is Dictionary and int(buff.get("m_nBuffTpltId", 0)) == ENTRY_RING:
			return "vòng bảo vệ"
	var all: bool = true
	for id: int in others:
		if int(battle.load_rates.get(id, {}).get("loaded", 0)) < 100:
			all = false
			break
	if not all:
		_all_since = -1.0
	elif _all_since < 0.0:
		_all_since = seconds
	elif seconds - _all_since >= ALL_READY_GRACE:
		return "đủ 100 %"
	if seconds >= HOLD_MAX:
		return "quá hạn"
	return ""

func _process(delta: float) -> void :
	var gate_pack: Variant = pack if pack != null else (get_parent().get("pack") if get_parent() != null else null)
	if gate_pack is Node and (gate_pack as Node).get("decode_gate") != self:
		(gate_pack as Node).set("decode_gate", self)
	if not visible or client == null:
		return
	var battle = client.battle
	if battle.scene_id != _scene:
		_scene = battle.scene_id
		seconds = 0.0
		_beat = 0
		_robots.clear()
		_pve_tip = ""
		_pve_tip_at = -1.0
	seconds += delta
	_time += delta
	var pve_now: bool = state_of(battle, int(Text.map_info(battle.map_id).get("type", 0))) == "pve"
	if pack != null and pack.state == "ready":
		pack.load_garage()
		pack.load_rank()
		if _asked_scene != _scene:
			_asked_scene = _scene
			pack.load_gda_loading()
			if pve_now:
				pack.load_gda_pveload()
			for brief: Dictionary in battle.roster:
				if helper_game(client) and int(brief.get("otherData", {}).get("btItemId", 0)) > 0:
					pack.load_helper()
					break
	while _beat < int(seconds):
		_beat += 1
		var mine: int = _rate(battle.self_id, battle)
		for brief: Dictionary in battle.roster:
			var id: int = _id(brief)
			if _robot(id, battle):
				_robots[id] = robot_rate(int(_robots.get(id, 0)), mine, _beat, randi() % 10)
	var tips: Array = pack.gda_pveload.get("tips", []) if pack != null else []
	if pve_now and not tips.is_empty() and (_pve_tip_at < 0.0 or seconds - _pve_tip_at >= PVE_TIP_EVERY):
		_pve_tip = random_tip(tips, randf())
		_pve_tip_at = seconds
	if battle.started:
		for id in battle.bubbles.keys():
			var bubble: Dictionary = battle.bubbles[id]
			var said: float = float(bubble.get("t", 0.0))
			if battle.clock - said <= 5.0 and float(battle.load_chat.get(id, {}).get("t", -1.0)) < said:
				battle.load_chat[id] = bubble.duplicate()
	for id: int in battle.load_chat.keys():
		if battle.clock - float(battle.load_chat[id].get("t", 0.0)) > 5.0:
			battle.load_chat.erase(id)
	var emo: Variant = get_parent().get("_emotes") if get_parent() != null else null
	if emo is Object and (emo as Object).get("loaded") == true and "%s:%d" % [str((emo as Object).get("rev")), _scene] != _prewarm_for\
	and hud != null and hud.has_method("talk_prewarm") and client.get("_load_acked") == true\
	and hud.talk_prewarm((emo as Object).get("packs"), PREWARM_USEC):
		_prewarm_for = "%s:%d" % [str((emo as Object).get("rev")), _scene]
	queue_redraw()


static func _robot(id: int, battle) -> bool:
	return id <= ROBOT_MAX and id != battle.self_id and not battle.load_rates.has(id)

func _rate(id: int, battle) -> int:
	if _robot(id, battle):
		return int(_robots.get(id, 0))
	return clampi(int(battle.load_rates.get(id, {}).get("loaded", 0)), 0, 100)



func decode_budgeted() -> bool:
	var who: Node = _gate_client()
	if visible or who == null or str(who.get("state")) != "battle":
		return false
	var battle: Variant = who.get("battle")
	if not battle is Object or (battle as Object).get("started") != true:
		return false
	var view: Node = get_parent()
	return view is CanvasItem and (view as CanvasItem).is_visible_in_tree()



func touch_wanted() -> bool:
	var who: Node = _gate_client()
	var state: String = str(who.get("state")) if who != null else ""
	if state == "hall" or state == "room":
		return true
	if state != "battle":
		return false
	var battle: Variant = who.get("battle")
	return visible or (battle is Object and (battle as Object).get("started") != true)

func _gate_client() -> Node:
	if client != null:
		return client
	var view: Node = get_parent()
	var other: Variant = view.get("client") if view != null else null
	return other if other is Node else null



const TOUCH_PER_FRAME: int = 64
func _touch_gpu() -> void :
	if pack == null or size.x < 1.0 or size.y < 1.0 or not pack.has_method("fresh_textures"):
		return
	for texture: Variant in pack.fresh_textures(TOUCH_PER_FRAME):
		if texture is Texture2D:
			draw_texture_rect_region(texture, Rect2(0, 0, 1, 1), Rect2(0, 0, 1, 1))

func _draw() -> void :
	_touch_gpu()
	draw_rect(Rect2(Vector2.ZERO, size), BACK)
	_tips.clear()
	if client == null or hud == null:
		return
	var battle = client.battle
	_s = hud.layout_scale()
	var c: Vector2 = size / 2
	var map_type: int = int(Text.map_info(battle.map_id).get("type", 0))
	_pve = map_type in PVE_TYPES
	var state: String = state_of(battle, map_type)
	_pic("bk", c + (Vector2(13, -28) if state == "pve" else Vector2.ZERO) * _s, true)
	_pic("shadow", c + Vector2(0, -100) * _s, true)
	if state == "pve":
		_boss(c, battle.map_id)
	var mine: int = self_camp(battle)

	var cup_look: bool = state == "look" and battle.roster.size() > 1 and client.has_method("tournament_room") and client.tournament_room()
	var love_slots: Array = slots(battle, "pvp" if cup_look else state)
	_love_seats(love_slots)
	for slot: Dictionary in love_slots:
		_cell(c + slot.pos * _s, slot.brief, int(slot.camp), mine, state == "look", battle)
	match state:
		"pvp":
			_map_box(c, battle.map_id)
			_pic("vs", c, true)
			_clock(c, false)
		"pve":
			_pic("vs", c, true)
			_clock(c, false)
			_rewards(c, battle.map_id, int(battle.cosmic))
			_tip_line(c)
			_pic("wordtip_bk", c + Vector2(0, -288) * _s, true, WORDTIP_SCALE)
			_pic("wordtip_shadow", c + Vector2(0, -288) * _s, true, WORDTIP_SCALE)
			_text(c + Vector2(-398, -305) * _s, battle.title(), Color("ffff00"), 24, HORIZONTAL_ALIGNMENT_CENTER, 797)
		"happy", "happy_sole":
			_clock(c, true)
		_:
			if cup_look:
				_pic("vs", c, true)
				_text(c + Vector2(-260, -300) * _s, "Đang vào xem trận", Color("ffff00"), 30, HORIZONTAL_ALIGNMENT_CENTER, 520)
			else:
				_text(c + Vector2(-400, -10) * _s, "Đang vào lại trận" if state == "reconnect" else "Đang vào xem trận", Color("ffff00"), 30, 
					HORIZONTAL_ALIGNMENT_CENTER, 800)
	_chat_frame(c)
	_draw_tip()



func _chat_frame(c: Vector2) -> void :
	var view: Variant = hud.view
	if view == null or not view.has_method("loading_chat_focus"):
		return
	hud.scale = _s
	hud.chat_frame(self, Vector2(c.x - 232 * _s, minf(c.y + 269 * _s, size.y - 40 * _s)))
	draw_set_transform(Vector2.ZERO)


func _pic(name: String, at: Vector2, middle: bool = false, scale: float = 1.0) -> void :
	var texture: Texture2D = hud.tex("loading/" + name)
	if texture == null:
		return
	var px: Vector2 = texture.get_size() * scale * _s
	draw_texture_rect(texture, Rect2(at - px / 2 if middle else at, px), false)


func _text(at: Vector2, text: String, color: Color, px: float, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT, width: float = -1.0, 
		edge: Color = Color.BLACK) -> void :
	var points: int = maxi(8, int(round(px * _s)))
	var base: Vector2 = at + Vector2(0, points + 1)
	var wide: float = width * _s if width > 0 else -1.0
	draw_string_outline(hud.bold, base, text, align, wide, points, maxi(2, int(round(3 * _s))), Color(edge, 0.9))
	draw_string(hud.bold, base, text, align, wide, points, color)


func _para(left: float, mid_y: float, text: String, px: float, width: float, color: Color, edge: Color, 
		align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> void :
	var points: int = maxi(8, int(round(px * _s)))
	var wide: float = width * _s
	var high: float = hud.bold.get_multiline_string_size(text, align, wide, points).y
	var base: Vector2 = Vector2(left, mid_y - high / 2.0 + hud.bold.get_ascent(points))
	draw_multiline_string_outline(hud.bold, base, text, align, wide, points, -1, maxi(2, int(round(3 * _s))), Color(edge, 0.9))
	draw_multiline_string(hud.bold, base, text, align, wide, points, -1, color)


func _boss(c: Vector2, map_id: int) -> void :
	var path: String = pve_boss(pack.gda_pveload, map_id) if pack != null else ""
	var art: Texture2D = pack.picture(path) if not path.is_empty() else null
	if art != null:
		var px: Vector2 = art.get_size() * _s
		draw_texture_rect(art, Rect2(c + BOSS_AT * _s - px / 2.0, px), false)



func _rewards(c: Vector2, map_id: int, cosmic: int = 0) -> void :
	var data: Dictionary = pack.gda_pveload if pack != null else {}
	var items: Array = cosmic_drops(cosmic) if cosmic > 0 else pve_drops(data, map_id)
	if items.is_empty():
		return
	var lay: Dictionary = reward_layout(items.size())
	var box: Vector2 = lay["size"]
	var o: Vector2 = c + (REWARD_AT - box / 2.0) * _s
	_panel.bg_color = REWARD_BACK
	_panel.set_border_width_all(0)
	_panel.set_corner_radius_all(maxi(1, roundi(8.0 * _s)))
	draw_style_box(_panel, Rect2(o, box * _s))
	var title: Texture2D = pack.picture(REWARD_TITLE)
	if title != null:
		draw_texture_rect(title, Rect2(o + Vector2((box.x - title.get_width()) / 2.0, 5) * _s, title.get_size() * _s), false)
	var info: Dictionary = data.get("items", {})
	for i in range(items.size()):
		var row: Array = info.get(str(items[i]), [])
		if row.size() < 4 and COSMIC_ITEMS.has(str(items[i])):
			var ci: Array = COSMIC_ITEMS[str(items[i])]
			row = [ci[0], ci[1], ci[2], ""]
		_reward(o + (lay["cells"][i] as Vector2) * _s, row)



func _reward(o: Vector2, row: Array) -> void :
	if row.size() < 4:
		return
	var key: String = str(row[1])
	var icon: Texture2D = pack.picture("l/it/%s.webp" % key) if not key.is_empty() else null
	if icon != null:
		draw_texture_rect(icon, Rect2(o, Vector2(40, 40) * _s), false)
	_para(o.x + 40.0 * _s, o.y + REWARD_TILE.y / 2.0 * _s, str(row[0]), 13, 96, Color.WHITE, Color("086da5"))
	_tip_at(Rect2(o, REWARD_TILE * _s), str(row[0]), str(row[3]), BagModel.tint(int(row[2]), Color.WHITE))


func _tip_line(c: Vector2) -> void :
	var mid: Vector2 = c + TIP_LINE_AT * _s
	_panel.bg_color = Color(REWARD_BACK, 0.3)
	_panel.set_border_width_all(0)
	_panel.set_corner_radius_all(maxi(1, roundi(25.0 * _s)))
	draw_style_box(_panel, Rect2(mid - TIP_PILL / 2.0 * _s, TIP_PILL * _s))
	if not _pve_tip.is_empty():
		_para(mid.x - 215.0 * _s, mid.y, _pve_tip, 16, 430, Color.WHITE, Color.BLACK, HORIZONTAL_ALIGNMENT_CENTER)




func _map_box(c: Vector2, map_id: int) -> void :
	var path: String = preview_path(map_id)
	var picture: Texture2D = pack.picture(path) if pack != null and not path.is_empty() else null
	var box: Dictionary = map_box_layout(picture.get_size() if picture != null else Vector2.ZERO)
	if picture != null:
		var frame: Rect2 = box["frame"]
		var border: Color = Color("0077d3")
		var o: Vector2 = c + frame.position * _s
		var w: float = 3.0 * _s
		draw_rect(Rect2(o, Vector2(frame.size.x * _s, w)), border)
		draw_rect(Rect2(o + Vector2(0, frame.size.y * _s - w), Vector2(frame.size.x * _s, w)), border)
		draw_rect(Rect2(o + Vector2(0, w), Vector2(w, frame.size.y * _s - 2 * w)), border)
		draw_rect(Rect2(o + Vector2(frame.size.x * _s - w, w), Vector2(w, frame.size.y * _s - 2 * w)), border)
		var inner: Rect2 = box["image"]
		draw_texture_rect(picture, Rect2(c + inner.position * _s, inner.size * _s), false)
	var points: int = maxi(8, int(round(13.0 * _s)))
	var line: float = box["label_top"] + PREVIEW_LABEL_GUTTER
	draw_string(hud.bold, c + Vector2(-200.0 * _s, line * _s + hud.bold.get_ascent(points)), client.battle.title(), HORIZONTAL_ALIGNMENT_CENTER, 
		400.0 * _s, points, Color.WHITE)



static func preview_path(map_id: int) -> String:
	return "l/map/mini%d.webp" % map_id if PREVIEWS.has(map_id) else ""



static func map_box_layout(image: Vector2) -> Dictionary:
	var frame: Vector2 = image + Vector2(6, 6) if image != Vector2.ZERO else Vector2.ZERO
	var gap: float = PREVIEW_GAP if frame != Vector2.ZERO else 0.0
	var top: float = PREVIEW_MID_Y - (frame.y + gap + PREVIEW_LABEL_H) / 2.0
	return {"frame": Rect2(Vector2( - frame.x / 2.0, top), frame), "image": Rect2(Vector2( - frame.x / 2.0 + 3.0, top + 3.0), image), 
		"label_top": top + frame.y + gap}


func _clock(center: Vector2, number: bool) -> void :
	var radius: float = 60.0 * _s
	draw_arc(center, radius, 0, TAU, 72, Color(0, 0.11, 0.3, 0.75), 9.0 * _s, true)
	var part: float = clampf(seconds / float(WAIT), 0.0, 1.0)
	if part > 0.002:
		draw_arc(center, radius, - PI / 2, - PI / 2 + TAU * part, 72, Color("ffe14a"), 5.0 * _s, true)
	if number:
		_text(center + Vector2(-60, -22) * _s, str(maxi(0, WAIT - int(minf(seconds, WAIT)))), Color.WHITE, 30, HORIZONTAL_ALIGNMENT_CENTER, 120)


func _cell(o: Vector2, brief: Dictionary, camp: int, mine: int, look: bool, battle) -> void :
	var data: Dictionary = brief.get("charData", {})
	var other: Dictionary = brief.get("otherData", {})
	var id: int = int(data.get("nAcctId", 0))
	var me: bool = id == battle.self_id and not look
	var same: bool = camp == mine and not look
	var blue: bool = camp == 2 if look else camp == mine
	var section: String = section_name(int(data.get("preEloSectionId", 0))) if same else ""
	if not section.is_empty():
		_pic("section_" + section, o + Vector2(-13, -17) * _s)
	if me:
		_pic("hexagon_light", o + Vector2(-4, -4) * _s)
	_pic("hexagon", o)
	var gda: Dictionary = pack.gda_loading if pack != null else {}
	var live: Variant = pack.get("live") if pack != null else null
	var ornate: String = ornate_live(live, gda.get("ornate", {}), int(data.get("nDecorateId", 0)))
	var frame: Texture2D = pack.picture(ornate) if not ornate.is_empty() else null
	var moving: Variant = ornate_pack_anim(live, gda, ornate) if frame != null else null
	var region: Rect2 = ornate_region(moving, Time.get_ticks_msec()) if moving != null else Rect2()
	var sheet: Texture2D = pack.picture(str((moving as Array)[0])) if region.has_area() else null
	if sheet != null and sheet.get_width() >= region.end.x and sheet.get_height() >= region.end.y:
		draw_texture_rect_region(sheet, Rect2(o + (CELL - region.size) / 2 * _s, region.size * _s), region)
	elif frame != null:
		draw_texture_rect(frame, Rect2(o + (CELL - frame.get_size()) / 2 * _s, frame.get_size() * _s), false)
	_tank(o + Vector2(118, 84) * _s, other)
	_pic("img_loading_bg", o + Vector2(51.5, 166) * _s)
	var rate: int = _rate(id, battle)
	var bar: Texture2D = hud.tex("loading/img_loading")
	if bar != null and rate > 0:
		var part: float = rate / 100.0
		draw_texture_rect_region(bar, Rect2(o + Vector2(52.5, 167) * _s, Vector2(130.0 * part, 14) * _s), 
			Rect2(0, 0, bar.get_width() * part, bar.get_height()))
	_clan(o, data, Color("a6d0ff") if blue else Color("ff8080"), gda)
	_tt3_helper_card = not tt3_helper_row(client, other, gda).is_empty()
	_helper(o, other, gda)
	_name(o, data)
	_honor(o, other, gda)
	if int(other.get("tryTank", 0)) == 1:
		_pic("rent", o + Vector2(17.5, 95) * _s, true)
	_skill(o, other, gda)
	_text(o + Vector2(0, 164) * _s, "%d%%" % rate, Color.WHITE, 12, HORIZONTAL_ALIGNMENT_CENTER, CELL.x)
	if me:
		var sample: Variant = client.get("latency_ms") if client != null else null
		var delay: int = int(sample) if sample != null else -1
		_vs1_ping(o, ping_text(delay), ping_color(delay))
	if battle.load_chat.has(id):
		_bubble(o + Vector2(28, 63) * _s, battle.load_chat[id])
	if same:
		_tank_rank(o, int(battle.tank_ranks.get(id, 0)), other)
	if same and pack != null:
		var ranks: Array = pack.rank.get("ranks", [])
		var rank: int = military_rank(ranks, int(data.get("nMilitaryStar", 0)))
		var badge: Texture2D = pack.picture("l/mr/b%d.webp" % int(ranks[rank - 1][1])) if rank > 0 else null
		if badge == null and rank > 0:
			pack.picture_again("l/mr/b%d.webp" % int(ranks[rank - 1][1]), QH1_AGAIN)
		if badge != null:
			var px: Vector2 = badge.get_size() * 0.4 * QH1_GROW * _s
			var spot: Rect2 = Rect2(o + Vector2(52.5, 37) * _s - px / 2, px)
			_qh1_badge(badge, spot)
			_tip_at(spot, "", str(ranks[rank - 1][0]), Color.WHITE)
	_tank_prof(o, id, me, same, battle)



func _tank_prof(o: Vector2, id: int, me: bool, same: bool, battle) -> void :
	var val: int = _prof_val(id, me, same, battle)
	var icon: Texture2D = Proficiency.icon(val, true)
	if icon == null:
		return
	var spot: Rect2 = Rect2(o + PROF_AT.position * _s, PROF_AT.size * _s)
	var crisp: Array = _tt3_icon(icon, spot)
	var tex: Texture2D = crisp[0]
	var at: Rect2 = crisp[1]
	if prof_back == "rim":
		var d: float = clampf(1.5 * _s, 1.0, 2.0)
		for k in range(8):
			draw_texture_rect(tex, Rect2(at.position + Vector2.from_angle(k * PI / 4) * d, at.size), false, Color(0, 0, 0, 0.85))
	else:
		if _prof_halo == null:
			_prof_halo = prof_halo_texture()
		var r: float = (PROF_AT.size.x / 2 + PROF_HALO) * _s
		draw_texture_rect(_prof_halo, Rect2(spot.get_center() - Vector2(r, r), Vector2(r, r) * 2), false)
	draw_texture_rect(tex, at, false)
	_tip_at(spot, "", Proficiency.tip(val), Color.WHITE)

var _tt3_cache: Dictionary = {}


static func tt3_fit(spot: Rect2, xf: Transform2D) -> Array:
	var k: Vector2 = xf.get_scale()
	if k.x <= 0.0 or k.y <= 0.0 or absf(xf.get_rotation()) > 0.0001 or absf(xf.get_skew()) > 0.0001:
		return [spot, Vector2i.ZERO]
	var px: Vector2i = Vector2i(maxi(1, roundi(spot.size.x * k.x)), maxi(1, roundi(spot.size.y * k.y)))
	var at: Vector2 = (xf * spot.get_center() - Vector2(px) / 2.0).round()
	return [Rect2(xf.affine_inverse() * at, Vector2(px) / k), px]


static func tt3_scale(icon: Texture2D, px: Vector2i) -> Texture2D:
	var img: Image = icon.get_image() if icon != null else null
	if img == null or img.is_empty():
		return null
	img = img.duplicate()
	if img.is_compressed() and img.decompress() != OK:
		return null
	img.convert(Image.FORMAT_RGBA8)
	img.fix_alpha_edges()
	var up: bool = px.x >= img.get_width()
	img.resize(px.x, px.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(tt3_sharpen(img, TT3_SHARP_UP if up else TT3_SHARP_DOWN))



static func tt3_sharpen(img: Image, amount: float) -> Image:
	var w: int = img.get_width()
	var h: int = img.get_height()
	if amount <= 0.0 or w < 3 or h < 3:
		return img
	var src: PackedByteArray = img.get_data()
	var out: PackedByteArray = src.duplicate()
	for y in range(h):
		for x in range(w):
			var m: int = (y * w + x) * 4
			var blur: PackedFloat32Array = PackedFloat32Array([0.0, 0.0, 0.0, 0.0])
			var lo: PackedInt32Array = PackedInt32Array([255, 255, 255, 255])
			var hi: PackedInt32Array = PackedInt32Array([0, 0, 0, 0])
			for dy in [-1, 0, 1]:
				var row: int = clampi(y + dy, 0, h - 1) * w
				for dx in [-1, 0, 1]:
					var n: int = (row + clampi(x + dx, 0, w - 1)) * 4
					var wt: float = (2 - absi(dx)) * (2 - absi(dy)) / 16.0
					for ch in range(4):
						var v: int = src[n + ch]
						blur[ch] += v * wt
						lo[ch] = mini(lo[ch], v)
						hi[ch] = maxi(hi[ch], v)
			var luma: float = 0.299 * (src[m] - blur[0]) + 0.587 * (src[m + 1] - blur[1]) + 0.114 * (src[m + 2] - blur[2])
			for ch in range(4):
				var o: float = src[m + ch] + amount * (luma if ch < 3 else src[m + 3] - blur[3])
				out[m + ch] = clampi(roundi(clampf(o, lo[ch], hi[ch])), 0, 255)
	return Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, out)


func _tt3_icon(icon: Texture2D, spot: Rect2) -> Array:
	var xf: Transform2D = get_viewport().get_final_transform() * get_global_transform_with_canvas() if is_inside_tree() else Transform2D()
	var fit: Array = tt3_fit(spot, xf)
	var px: Vector2i = fit[1]
	if px.x <= 0:
		return [icon, spot]
	if px == Vector2i(icon.get_size()):
		return [icon, fit[0]]
	var key: String = "%d:%d:%d" % [icon.get_instance_id(), px.x, px.y]
	if not _tt3_cache.has(key):
		if _tt3_cache.size() >= TT3_CACHE_MAX:
			_tt3_cache.clear()
		_tt3_cache[key] = tt3_scale(icon, px)
	var tex: Variant = _tt3_cache[key]
	return [tex, fit[0]] if tex is Texture2D else [icon, spot]

var _tt3_helper_card: bool = false


static func tt3_helper_row(who: Node, other: Dictionary, gda: Dictionary) -> Array:
	if who == null or not helper_game(who):
		return []
	var row: Array = gda.get("helper", {}).get(str(int(other.get("btItemId", 0))), [])
	return row if row.size() >= 4 and not str(row[1]).is_empty() else []


func _prof_val(id: int, me: bool, _same: bool, battle) -> int:
	if _pve or _tt3_helper_card:
		return -1
	var val: int = int(battle.tank_prof.get(id, -1))
	if val < 0 and me and client != null:
		val = Proficiency.of_tank(client.current_tank())
	return val


static func prof_halo_texture() -> GradientTexture2D:
	var ramp: Gradient = Gradient.new()
	ramp.offsets = PackedFloat32Array([0.0, 0.75, 1.0])
	ramp.colors = PackedColorArray([Color(0, 0, 0, PROF_HALO_ALPHA), Color(0, 0, 0, PROF_HALO_ALPHA), Color(0, 0, 0, 0)])
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.gradient = ramp
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 64
	tex.height = 64
	return tex




static func vs1_ping_place(s: float, k: float, w: float) -> Array:
	var box: Rect2 = vs1_ping_box(s, k, w)
	if box.position.x < VS1_PING_LEFT - 0.001 or box.end.y > VS1_PING_BOTTOM + 0.001:
		return []
	var edge: float = prof_ping_rim(s, k) / 2.0 / s
	return [box.end.x - edge, box.end.y - edge]


static func vs1_ping_box(s: float, k: float, w: float) -> Rect2:
	var ink: float = prof_ping_points(s, k) * PING1_INK / s
	var edge: float = prof_ping_rim(s, k) / 2.0 / s
	var top: float = VS1_SKILL_AT.end.y + VS1_PING_GAP - edge
	var bottom: float = VS1_SKILL_AT.end.y + VS1_PING_GAP + ink + edge
	var end: float = minf(VS1_SKILL_AT.get_center().x + w / 2.0 + edge, ping1_hex_right(bottom) - PING1_GAP)
	return Rect2(end - w - 2.0 * edge, top, w + 2.0 * edge, bottom - top)


static func ping1_hex_right(y: float) -> float:
	return 234.0 - absf(y - 94.0) * 56.0 / 95.0



static func prof_ping_points(s: float, k: float) -> int:
	return maxi(maxi(1, int(round(10 * s))), ceili(PROF_PING_MIN_PX / maxf(k, 0.01) - 0.001))



static func prof_ping_rim(s: float, k: float) -> int:
	return maxi(maxi(1, int(round(3 * s))) + 1, ceili(3.0 / maxf(k, 0.01)))


func _screen_k() -> float:
	var k: float = 1.0
	if is_inside_tree():
		k = (get_viewport().get_final_transform() * get_global_transform_with_canvas()).get_scale().x
	return k if k > 0.0 else 1.0


func _vs1_ping(o: Vector2, text: String, color: Color) -> void :
	var k: float = ping1_k if ping1_k > 0.0 else _screen_k()
	var points: int = prof_ping_points(_s, k)
	var w: float = hud.bold.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, points).x / _s
	var spot: Array = vs1_ping_place(_s, k, w)
	if spot.is_empty():
		return
	var base: Vector2 = o + Vector2(float(spot[0]) - 100.0, float(spot[1])) * _s
	draw_string_outline(hud.bold, base, text, HORIZONTAL_ALIGNMENT_RIGHT, 100 * _s, points, prof_ping_rim(_s, k), Color.BLACK)
	_text(base - Vector2(0, points + 1), text, color, points / _s, HORIZONTAL_ALIGNMENT_RIGHT, 100)

func _clan(o: Vector2, data: Dictionary, color: Color, gda: Dictionary) -> void :
	var team: String = str(data.get("szTeamName", ""))
	var path: String = team_rank_path(int(data.get("nTeamPlace", 0)), int(gda.get("clan", 0)))
	var badge: Texture2D = pack.picture(path) if pack != null and not path.is_empty() else null
	if badge == null:
		if not team.is_empty():
			_text(o + Vector2(0, 6) * _s, team, color, 12, HORIZONTAL_ALIGNMENT_CENTER, CELL.x)
		return
	var points: int = maxi(8, int(round(12 * _s)))
	var text_w: float = hud.bold.get_string_size(team, HORIZONTAL_ALIGNMENT_LEFT, -1, points).x / _s if not team.is_empty() else 0.0
	var left: float = (CELL.x - CLAN_PAD - text_w) / 2.0
	draw_texture_rect(badge, Rect2(o + Vector2(left, 0) * _s, badge.get_size() * _s), false)
	if not team.is_empty():
		_text(o + Vector2(left + CLAN_PAD, 6) * _s, team, color, 12)


func _helper(o: Vector2, other: Dictionary, gda: Dictionary) -> void :
	if not helper_game(client):
		return
	var more: Dictionary = gda.get("helper", {})
	var row: Array = more.get(str(int(other.get("btItemId", 0))), [])
	if row.size() < 4 or str(row[1]).is_empty():
		return
	var icon: Texture2D = pack.picture("l/it/%s.webp" % str(row[1]))
	var spot: Rect2 = Rect2(o + HELPER_AT.position * _s, HELPER_AT.size * _s)
	if icon != null:
		draw_texture_rect(icon, spot, false)
	var rec: Dictionary = helper_record(pack.helper, more, other)
	var title: String = str(rec.name) if not rec.is_empty() else BagModel.clean(str(row[0]))
	var quality: int = int(rec.quality) if not rec.is_empty() else int(row[2])
	_tip_at(spot, title, helper_lines(rec), BagModel.tint(quality, Color.WHITE))

	if not _tips.is_empty() and _tips[_tips.size() - 1][0] == spot and (rec.get("tpl", []) as Array).size() >= 17:
		_tips[_tips.size() - 1] = [spot, title, "", Color.WHITE, rec, more]


func _honor(o: Vector2, other: Dictionary, gda: Dictionary) -> void :
	var info: Array = gda.get("honor", {}).get(str(int(other.get("honorId", 0))), [])
	if info.size() < 2:
		return
	var icon: Texture2D = pack.picture("l/hn/%s.webp" % str(info[1]))
	var spot: Rect2 = Rect2(o + HONOR_AT.position * _s, HONOR_AT.size * _s)
	if icon != null:
		draw_texture_rect(icon, spot, false, Color(1.3, 1.3, 1.3) if spot.has_point(_mouse) else Color.WHITE)
	_tip_at(spot, "", str(info[0]), Color.WHITE)




const QH1_AGAIN: float = 20.0
const QH1_CACHE_MAX: int = 48
const QH1_GROW: float = 1.15
const QH1_SHARP_K: float = 0.8
const QH1_SHARP_MIN: float = 2.0
const QH1_SHARP_MAX: float = 2.5
const QH1_SMALL: int = 28
const QH1_SMALL_AMOUNT: float = 3.0
const QH1_SMALL_KNEE: float = 25.5
var _qh1_cache: Dictionary = {}


static func qh1_fit(spot: Rect2, xf: Transform2D) -> Array:
	var k: Vector2 = xf.get_scale()
	if k.x <= 0.0 or k.y <= 0.0 or absf(xf.get_rotation()) > 0.0001 or absf(xf.get_skew()) > 0.0001:
		return [spot, Vector2i.ZERO]
	var px: Vector2i = Vector2i(maxi(1, roundi(spot.size.x * k.x)), maxi(1, roundi(spot.size.y * k.y)))
	var at: Vector2 = (xf * spot.get_center() - Vector2(px) / 2.0).round()
	return [Rect2(xf.affine_inverse() * at, Vector2(px) / k), px]


static func qh1_shrink(badge: Texture2D, px: Vector2i) -> Texture2D:
	var img: Image = badge.get_image() if badge != null else null
	if img == null or img.is_empty():
		return null
	img = img.duplicate()
	if img.is_compressed() and img.decompress() != OK:
		return null
	img.convert(Image.FORMAT_RGBA8)
	img.fix_alpha_edges()
	var amount: float = clampf(QH1_SHARP_K * float(img.get_width()) / float(px.x), QH1_SHARP_MIN, QH1_SHARP_MAX)
	var knee: float = 0.0
	if maxi(px.x, px.y) <= QH1_SMALL:
		amount = QH1_SMALL_AMOUNT
		knee = QH1_SMALL_KNEE
	img.resize(px.x, px.y, Image.INTERPOLATE_LANCZOS)
	return ImageTexture.create_from_image(qh1_sharpen(img, amount, knee))







static func qh1_sharpen(img: Image, amount: float, knee: float = 0.0) -> Image:
	var w: int = img.get_width()
	var h: int = img.get_height()
	if amount <= 0.0 or w < 3 or h < 3:
		return img
	var src: PackedByteArray = img.get_data()
	var row: PackedInt32Array = PackedInt32Array()
	row.resize(w * h * 4)
	for y in range(h):
		for x in range(w):
			var l: int = (y * w + maxi(x - 1, 0)) * 4
			var m: int = (y * w + x) * 4
			var r: int = (y * w + mini(x + 1, w - 1)) * 4
			for ch in range(4):
				row[m + ch] = src[l + ch] + 2 * src[m + ch] + src[r + ch]
	var out: PackedByteArray = src.duplicate()
	for y in range(h):
		var up: int = maxi(y - 1, 0) * w
		var dn: int = mini(y + 1, h - 1) * w
		for x in range(w):
			var m: int = (y * w + x) * 4
			var d: PackedFloat32Array = PackedFloat32Array([0.0, 0.0, 0.0, 0.0])
			for ch in range(4):
				d[ch] = src[m + ch] - (row[(up + x) * 4 + ch] + 2 * row[m + ch] + row[(dn + x) * 4 + ch]) / 16.0
			if knee <= 0.0:
				for ch in range(4):
					out[m + ch] = clampi(roundi(src[m + ch] + amount * d[ch]), 0, 255)
				continue
			var luma: float = 0.299 * d[0] + 0.587 * d[1] + 0.114 * d[2]
			for ch in range(4):
				var lo: int = 255
				var hi: int = 0
				for yy in [up, y * w, dn]:
					for xx in [maxi(x - 1, 0), x, mini(x + 1, w - 1)]:
						lo = mini(lo, src[(yy + xx) * 4 + ch])
						hi = maxi(hi, src[(yy + xx) * 4 + ch])
				var o: float = src[m + ch] + amount * (luma if ch < 3 else d[ch])
				if o > hi:
					o = hi + knee * tanh((o - hi) / knee)
				elif o < lo:
					o = lo - knee * tanh((lo - o) / knee)
				out[m + ch] = clampi(roundi(o), 0, 255)
	return Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, out)

func _qh1_badge(badge: Texture2D, spot: Rect2) -> void :
	var xf: Transform2D = get_viewport().get_final_transform() * get_global_transform_with_canvas() if is_inside_tree() else Transform2D()
	var fit: Array = qh1_fit(spot, xf)
	var px: Vector2i = fit[1]
	if px.x <= 0 or px.x >= badge.get_width() or px.y >= badge.get_height():
		draw_texture_rect(badge, spot, false)
		return
	var key: String = "%d:%d:%d" % [badge.get_instance_id(), px.x, px.y]
	if not _qh1_cache.has(key):
		if _qh1_cache.size() >= QH1_CACHE_MAX:
			_qh1_cache.clear()
		_qh1_cache[key] = qh1_shrink(badge, px)
	var small: Variant = _qh1_cache[key]
	if small is Texture2D:
		draw_texture_rect(small, fit[0], false)
	else:
		draw_texture_rect(badge, spot, false)



func _tank_rank(o: Vector2, rank: int, other: Dictionary) -> void :
	if rank <= 0:
		return
	var spot: Rect2 = Rect2(o + TANK_RANK_AT.position * _s, TANK_RANK_AT.size * _s)
	var back: Texture2D = hud.tex("loading/tank_rank_bg")
	if back != null:
		draw_texture_rect(back, spot, false)
	var points: int = maxi(8, int(round(16 * _s)))
	var wide: float = 50.0 * _s
	var mid: Vector2 = spot.get_center()
	var base: Vector2 = Vector2(mid.x - wide / 2.0, mid.y + (hud.bold.get_ascent(points) - hud.bold.get_descent(points)) / 2.0)
	draw_string_outline(hud.bold, base, str(rank), HORIZONTAL_ALIGNMENT_CENTER, wide, points, maxi(2, int(round(3 * _s))), TANK_RANK_GLOW)
	draw_string(hud.bold, base, str(rank), HORIZONTAL_ALIGNMENT_CENTER, wide, points, TANK_RANK_INK)
	var tank: String = ""
	if pack != null:
		tank = GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(int(other.get("tankId", 0))), "")))
	_tip_at(spot, "", ("Hạng %d %s" % [rank, tank]).strip_edges(), Color.WHITE)


func _skill(o: Vector2, other: Dictionary, gda: Dictionary) -> void :
	var skill: int = guild_skill(gda.get("guild", {}), int(other.get("commandSkill", 0)), _pve)
	if skill <= 0:
		return
	var hud_row: Array = pack.skill_hud(skill)
	var icon: Texture2D = pack.icon("s", str(hud_row[0])) if not hud_row.is_empty() else null
	var at: Rect2 = VS1_SKILL_AT
	var spot: Rect2 = Rect2(o + at.position * _s, at.size * _s)
	if icon != null:
		draw_texture_rect(icon, spot, false)
	var info: Array = gda.get("skill", {}).get(str(skill), [])
	if info.size() >= 2:
		_tip_at(spot, str(info[0]), str(info[1]), Color.WHITE)




static func cosmic_drops(n: int) -> Array:
	var out: Array = []
	if n < 100:
		out.append(2620001 + n)
	out.append_array([3700006, 3700007, 3700008])
	if n in COSMIC_MOON:
		out.append_array([4051000 + n / 5, 4051120 + n / 5])
	return out

static func pve_drops(pveload: Dictionary, map_id: int) -> Array:
	var row: Array = pveload.get("maps", {}).get(str(map_id), [])
	var items: Array = row[1] if row.size() >= 2 and row[1] is Array else []
	return items.slice(0, REWARD_MAX).map( func(item: Variant) -> int: return int(item))


static func pve_boss(pveload: Dictionary, map_id: int) -> String:
	var row: Array = pveload.get("maps", {}).get(str(map_id), [])
	var stem: String = str(row[0]) if row.size() >= 1 else ""
	return "" if stem.is_empty() else "l/gda/boss/%s.webp" % stem



static func reward_layout(count: int) -> Dictionary:
	var wide: float = 148.0 if count < 4 else 296.0
	var cols: int = 1 if count < 4 else 2
	var rows: int = ceili(count / float(cols))
	var used: float = cols * REWARD_TILE.x + (cols - 1) * 6.0
	var left: float = 6.0 + floorf((wide - 12.0 - used) / 2.0)
	var cells: Array = []
	for i in range(count):
		cells.append(Vector2(left + (i % cols) * (REWARD_TILE.x + 6.0), 36.0 + int(i / cols) * (REWARD_TILE.y + 6.0)))
	return {"size": Vector2(wide, 30.0 + 12.0 + rows * REWARD_TILE.y + maxi(0, rows - 1) * 6.0), "cells": cells}


static func random_tip(tips: Array, roll: float) -> String:
	if tips.is_empty():
		return ""
	return str(tips[clampi(int(tips.size() * roll), 0, tips.size() - 1)])


func _love_seats(shown: Array) -> void :
	_love_tones = {}
	_love_names = {}
	if shown.size() < 2:
		return
	var accts: Array = []
	for slot: Dictionary in shown:
		var data: Dictionary = (slot.get("brief", {}) as Dictionary).get("charData", {})
		var acct: int = int(data.get("nAcctId", 0))
		accts.append(acct)
		if acct > 0:
			_love_names[acct] = str(data.get("szName", ""))
	_love_tones = Love.tones(client, accts)


func _tip_at(spot: Rect2, title: String, body: String, tint: Color) -> void :
	if ( not title.is_empty() or not body.is_empty()) and spot.has_point(_mouse):
		_tips.append([spot, title, body, tint])


func _draw_tip() -> void :
	if _tips.is_empty():
		return
	var tip: Array = _tips[_tips.size() - 1]
	if tip.size() >= 6 and _s > 0.0:
		var rec: Dictionary = tip[4]
		var more: Dictionary = tip[5]
		HelperTip.show(self, _s, size / _s, _mouse / _s, client, pack.helper, more, rec, HelperTip.context(client, rec, more), true, pack.picture)
		return
	var anchor: Rect2 = tip[0]
	var title: String = str(tip[1])
	var body: String = str(tip[2])
	var wide: float = TIP_WIDE * _s
	var pad: float = 10.0 * _s
	var title_px: int = maxi(8, roundi(13.0 * _s))
	var body_px: int = maxi(8, roundi(12.0 * _s))
	var title_h: float = 20.0 * _s if not title.is_empty() else 0.0
	var body_h: float = 0.0
	if not body.is_empty():
		body_h = hud.font.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, wide - pad * 2.0, body_px, 10).y
	var high: float = 6.0 * _s + title_h + body_h + 8.0 * _s
	var at: Vector2 = Vector2(anchor.end.x + 6.0 * _s, anchor.position.y)
	if at.x + wide > size.x:
		at.x = anchor.position.x - 6.0 * _s - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, size.y - high))
	_tip_box.bg_color = Color(0, 0, 0, 0.86)
	_tip_box.border_color = TIP_BORDER
	_tip_box.set_border_width_all(maxi(1, roundi(1.5 * _s)))
	_tip_box.set_corner_radius_all(maxi(2, roundi(8.0 * _s)))
	draw_style_box(_tip_box, Rect2(at, Vector2(wide, high)))
	if not title.is_empty():
		draw_string(hud.bold, at + Vector2(pad, 6.0 * _s + title_px), title, HORIZONTAL_ALIGNMENT_LEFT, wide - pad * 2.0, title_px, tip[3])
	if not body.is_empty():
		draw_multiline_string(hud.font, at + Vector2(pad, 6.0 * _s + title_h + body_px), body, HORIZONTAL_ALIGNMENT_LEFT, wide - pad * 2.0, 
			body_px, 10, Color.WHITE)


func _name(o: Vector2, data: Dictionary) -> void :
	var vip: int = int(data.get("nVipLevel", 0))
	var level: int = vip % 100
	var color: Color = Color.WHITE
	var edge: Color = Color.BLACK
	if level > 0:
		var icon: Texture2D = hud.tex("loading/vip/%s%d" % ["SV" if vip >= 100 else "V", mini(level, 15)])
		if icon != null:
			var px: Vector2 = icon.get_size() * _s
			draw_texture_rect(icon, Rect2(o + Vector2(43, 153) * _s - Vector2(0, px.y / 2), px), false)
		var tone: Array = VIP_TONES[0 if level < 3 else 1 if level < 6 else 2]
		color = Color(str(tone[0])).lerp(Color(str(tone[1])), 0.3)
		edge = Color(str(tone[2]))
	var who: String = str(data.get("szName", ""))
	var ink: PackedColorArray = NameStyles.colors_of(client, int(data.get("nAcctId", 0)), who)
	if Love.has(client, int(data.get("nAcctId", 0))):
		var love_pt: int = maxi(8, int(round(13 * _s)))
		if hud.bold.get_string_size(who, HORIZONTAL_ALIGNMENT_LEFT, -1, love_pt).x > 127 * _s:
			while who.length() > 1 and hud.bold.get_string_size(who + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, love_pt).x > 127 * _s:
				who = who.left(-1)
			who = who.strip_edges() + "…"
		var love_w: float = hud.bold.get_string_size(who, HORIZONTAL_ALIGNMENT_LEFT, -1, love_pt).x
		var love_acct: int = int(data.get("nAcctId", 0))
		var love_tone: int = Love.tone_of(_love_tones, love_acct)
		var love_spot: Rect2 = Rect2(o + Vector2(78, 144) * _s + Vector2(love_w + Love.NAME_GAP * _s, 0), Vector2(Love.SIDE, Love.SIDE) * _s)
		Love.draw(self, love_spot, 1.0, 1.0, -1, love_tone)
		_tip_at(love_spot.grow(3.0 * _s), Love.tip(client, love_acct, _love_names), "", Love.tone_ink(love_tone))
	if not ink.is_empty():
		var points: int = maxi(8, int(round(13 * _s)))
		NameStyles.draw_tinted(self, hud.bold, points, o + Vector2(78, 143) * _s + Vector2(0, points + 1), who, ink, maxi(2, int(round(3 * _s))), 
			NameStyles.RIM, "l", 145 * _s)
		return
	_text(o + Vector2(78, 143) * _s, who, color, 13, HORIZONTAL_ALIGNMENT_LEFT, 145, edge)


func _tank(center: Vector2, other: Dictionary) -> void :
	var tank_id: int = int(other.get("tankId", 0))
	if pack == null or pack.state != "ready" or tank_id <= 0:
		return
	var level: int = int(other.get("tankLevel", 0))
	var worn: int = int(other.get("tankExternal", 0))
	var ext: int = worn if worn > 0 else GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, maxi(1, level), {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(other.get("haloId", 0)), level)
	if TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, center, 0.8 * _s, _time, "l/t", false):
		_pet(center, other, 0.8 * _s)
		return
	if pack.garage.is_empty() and seconds < 3.0:
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(worn), tank_id))
	if TankPreview.ready(art):
		TankPreview.draw(self, art, center + Vector2(0, 12) * _s, 0.9 * _s, 4, _time)
	_pet(center, other, 0.8 * _s)


const LOAD_PET_AT: Vector2 = Vector2(62, -52)


const LOAD_PET_HIDDEN: int = 12

func load_pet_item(other: Dictionary) -> int:
	var item: int = int(other.get("btItemId", 0))
	if item <= 0 or int(client.battle.room_type) == LOAD_PET_HIDDEN or not helper_game(client):
		return 0
	return item



func load_pet_layers(other: Dictionary) -> Array:
	var item: int = load_pet_item(other) if pack != null else 0
	var pet: Array = pack.pet_of(item) if item > 0 else []
	if pet.is_empty():
		return []
	var rank: int = int(other.get("btRank", 0))
	var keys: Array = []
	for key: String in [pack.pet_star(rank), str(pet[0]), pack.pet_star_front(rank)]:
		if not key.is_empty():
			keys.append(key)
	return keys

func _pet(center: Vector2, other: Dictionary, zoom: float) -> void :
	var keys: Array = load_pet_layers(other)
	if keys.is_empty():
		return
	var world: Transform2D = Transform2D(0.0, Vector2(zoom, zoom), 0.0, center + LOAD_PET_AT * zoom)
	for key: String in keys:
		var asset: Dictionary = pack.effect(key)
		if asset.is_empty() or (asset.data.frames as Array).is_empty():
			continue
		TankPreview._frame(self, asset, int(_time * 24.0) % (asset.data.frames as Array).size(), world)
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _bubble(at: Vector2, bubble: Dictionary) -> void :
	var points: int = maxi(8, int(round(12 * _s)))
	var wide: float = 164.0 * _s
	var text: String = str(bubble.get("text", ""))
	var need: Vector2 = hud.font.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, wide, points, 3)
	_box.bg_color = Color(bubble.get("bg", Color("fff6d5")), 0.95)
	_box.border_color = bubble.get("border", Color("b48a46"))
	_box.set_border_width_all(1)
	_box.set_corner_radius_all(6)
	draw_style_box(_box, Rect2(at, Vector2(minf(need.x, wide) + 16 * _s, need.y + 8 * _s)))
	draw_multiline_string(hud.font, at + Vector2(8 * _s, 4 * _s + points), text, HORIZONTAL_ALIGNMENT_LEFT, wide, points, 3, 
		bubble.get("fg", Color("3b2a10")))
