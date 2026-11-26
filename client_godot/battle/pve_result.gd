extends "pvp_result.gd"













const Pve = preload("../ui/pve_result_atlas.gd")
const PveHall = preload("../ui/pve_hall_atlas.gd")
const Text = preload("../i18n.gd")

const MAP_TYPES: Array = [2, 11, 16]
const BACK_SOLO: String = "Trả về sau %d s"
const BACK_ROOM: String = "Sau %ds về room"
const OVERLAY: Color = Color(0, 0, 0, 192.0 / 255.0)
const FIRST: int = 5
const LAST: int = 5
const SLIDE: float = 0.5
const RETRY: float = 2.0
const VIP_SIX: int = 6
const STAT_DEAD: int = 0
const STAT_KILL: int = 1
const STAT_SCORE: int = 2
const STAT_HARM: int = 6
const STAT_EXP: int = 10

var _clock: float = 0.0
var _lose: bool = false
var _first: int = FIRST
var _backed: bool = false
var _next_back: float = 0.0

func _setup() -> void :
	_use(Atlas.FILE, Atlas.R)
	var levels: Dictionary = {}
	for cell: String in Hall.R:
		if cell.begins_with("level_"):
			levels[cell] = Hall.R[cell]
	_use(Hall.FILE, levels)
	_use(Pve.FILE, Pve.R)
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_italic = FontVariation.new()
	_italic.base_font = ARIAL_BOLD
	_italic.variation_transform = Transform2D(Vector2(1, 0), Vector2(0.2, 1), Vector2.ZERO)


static func wanted(game) -> bool:
	if game == null or game.state != "battle" or not game.battle.ended or game.battle.look:
		return false
	return int(Text.map_info(int(game.battle.map_id)).get("type", 0)) in MAP_TYPES

func _shown() -> void :
	_clock = 0.0
	_backed = false
	_next_back = 0.0
	_exp_clock = 0.0
	_exp = {}
	if not is_visible_in_tree() or client == null:
		return
	_lose = int(client.battle.outcome.get("m_winCamp", 0)) != int(client.battle.self_camp())
	_first = 0 if _lose else FIRST
	var me: Dictionary = _self_stat()
	_exp = exp_start(int(client.character.get("level", 1)), int(client.character.get("exp", 0)), 
		stat_of(me.get("m_iStatData", []), STAT_EXP) if not me.is_empty() else 0)

func _tick(delta: float) -> void :
	if client == null:
		return
	if pack != null and pack.state == "ready":
		pack.load_bag()
		pack.load_garage()
	_clock += delta
	if not _exp.is_empty():
		_exp_clock += delta
		while _exp_clock >= 1.0 / FPS and bool(_exp.get("run", false)):
			_exp_clock -= 1.0 / FPS
			exp_step(_exp)


	if _clock >= float(_first + LAST) and ( not _backed or (_clock >= _next_back and client.pve_result_held())):
		_go_back()


func _go_back() -> void :
	_backed = true
	_next_back = _clock + RETRY
	client.leave_battle(2)

func _wheel(_step: int, _at: Vector2) -> void :
	pass

func _activate(id: String) -> void :
	if id == "back":
		_go_back()


func left_seconds() -> int:
	return maxi(0, _first + LAST - int(floorf(_clock)))



func _paint() -> void :
	if client == null or pack == null:
		return
	draw_rect(Rect2(Vector2.ZERO, size), OVERLAY)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(Pve.SIZE[0]), float(Pve.SIZE[1]))
	_hit("panel", Rect2(o * _f, Vector2(float(Pve.SIZE[0]), float(Pve.SIZE[1])) * _f), false)
	var battle = client.battle
	var me: Dictionary = _self_stat()
	var t: float = 1.0 if _lose else clampf((_clock - float(_first)) / SLIDE, 0.0, 1.0)
	if not _lose and t < 1.0:
		_first_page(o + Vector2( - float(Pve.SIZE[0]) * t, 0), battle, me)
	if _lose or _clock >= float(_first):
		_second_page(o + Vector2(float(Pve.SIZE[0]) * (1.0 - t), 0), battle, me)


func _first_page(o: Vector2, battle, me: Dictionary) -> void :
	_fblit("pq_bg1", o + _v(Pve.BG["first"]))
	_fblit("pq_title", o + _v(Pve.PAGE1["title"]))
	for key: String in ["damage", "dead", "time"]:
		_fblit("pq_w_" + key, o + _v(Pve.PAGE1[key]))
	var values: Array = me.get("m_iStatData", [])
	_number(o + _v(Pve.PAGE1["cvsDamage"]), digits(stat_of(values, STAT_HARM)))
	_number(o + _v(Pve.PAGE1["cvsDead"]), digits(stat_of(values, STAT_DEAD)))
	var seconds: int = int(battle.outcome.get("m_battleTime", 0))
	_number(o + _v(Pve.PAGE1["cvsPassTime"]), clock_cells(seconds / 60, seconds % 60))
	var grade: Dictionary = me.get("m_evalPve", {})
	for pair: Array in [["imgDamage", "m_iHarmEval"], ["imgDead", "m_iDeadEval"], ["imgPassTime", "m_iTimeEval"]]:
		var mark: String = score_cell(int(grade.get(pair[1], 0)), false)
		if not mark.is_empty():
			_fblit(mark, o + _v(Pve.PAGE1[pair[0]]))
	_score_glow(o + _v(Pve.PAGE1["glow"]))
	var total: String = score_cell(int(grade.get("m_iTotalEval", 0)), true)
	if not total.is_empty():
		_fblit(total, o + _v(Pve.PAGE1["imgTotalScore"]) - _cell_size(total) / 2.0)


func _score_glow(at: Vector2) -> void :
	var frame: int = int(_time * float(Pve.GLOW["fps"])) % int(Pve.GLOW["period"])
	var step: int = int(Pve.GLOW["step"])
	var key: int = frame / step
	var mix: float = float(frame % step) / float(step)
	_fblit("pq_glow_%d" % key, at)
	if mix > 0.0:
		_fblit("pq_glow_%d" % ((key + 1) % int(Pve.GLOW["count"])), at, 0.0, 0.0, Color(1, 1, 1, mix))


func _number(at: Vector2, cells: Array) -> void :
	var cell: Array = _cells.get("pq_num5", [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var box: Vector2 = Vector2(float(Pve.NUM5["cell"][0]), float(Pve.NUM5["cell"][1]))
	var zoom: float = float(Pve.NUM5["scale"])
	for item: Array in cells:
		var from: Rect2 = Rect2(float(region[0]) + float(Pve.NUM5["step"]) * int(item[0]), float(region[1]), box.x, box.y)
		draw_texture_rect_region(cell[0], Rect2((at + Vector2(float(item[1]) * zoom, 0)) * _f, box * zoom * _f), from)


func _second_page(o: Vector2, battle, me: Dictionary) -> void :
	_fblit("pq_bg2_lose" if _lose else "pq_bg2", o + _v(Pve.BG["second"]))
	_fblit("pq_panel", o + _v(Pve.PAGE2["image8"]))
	_fblit("pq_exp_title", o + _v(Pve.PAGE2["exp_title"]))

	_exp_title(o + Vector2(-127, 89))
	if _lose:
		var tip: Vector2 = o + _v(Pve.PAGE2["frmResultTip"])
		_fblit("pq_tip", tip + _v(Pve.TIP["panel"]))
		if _vip_self() == VIP_SIX:
			_fblit("pq_tip_helper", tip + _v(Pve.TIP["helper"]))
		else:
			_fblit("pq_tip_vip", tip + _v(Pve.TIP["vip"]))
	else:
		_fblit("pq_reward_line", o + _v(Pve.PAGE2["image4"]))
		_fblit("pq_reward_word", o + _v(Pve.PAGE2["image3"]))
		var goods: Array = pve_rewards(battle.pvp_award)
		var spec: Array = Pve.ITEMS
		var cols: int = int(spec[4])
		for i in range(cols * int(spec[5])):
			_slot(o + Vector2(float(spec[0]) + float(spec[2]) * (i % cols), float(spec[1]) + float(spec[3]) * (i / cols)), 
				goods[i] if i < goods.size() else {})
	var values: Array = me.get("m_iStatData", [])
	_fblit("pq_w_exp", o + _v(Pve.PAGE2["image7"]))
	_pve_label(o, "lblExp", str(stat_of(values, STAT_EXP)))
	var vip: bool = is_vip(client.character)
	var char_exp: Array = me.get("m_expVec", [])
	_bar(o + _v(Pve.PAGE2["frmExpPercent"]), char_exp, vip)
	_fblit("pq_w_merit", o + _v(Pve.PAGE2["merit"]))
	_pve_label(o, "lblMerit", str(int(me.get("m_iTeamMerit", 0))))
	_fblit("pq_lose" if _lose else "pq_win", o + _v(Pve.PAGE2["imgLose" if _lose else "imgWin"]))
	if absf(float(battle.outcome.get("m_svrExpRate", 1.0)) - 1.0) > 0.001:
		_fblit("pq_double", o + _v(Pve.PAGE2["imgDouble"]))
	if int(shares(char_exp, vip).scores[6]) != 0:
		_fblit("pq_vip", o + _v(Pve.PAGE2["imgVipExp"]))
	_card(o + _v(Pve.PAGE2["frmCharInfo"]), battle, me)
	var back: String = "btnBack_lose" if _lose else "btnBack"
	_fbutton("back", "pq_back", o + _v(Pve.PAGE2[back]))
	var words: String = BACK_SOLO if red_num(int(battle.map_id)) <= 1 else BACK_ROOM
	_pve_label(o, "lblBack_lose" if _lose else "lblBack", words % left_seconds())


func _card(at: Vector2, battle, me: Dictionary) -> void :
	var brief: Dictionary = _brief_of(battle.roster, int(battle.self_id))
	var data: Dictionary = brief.get("charData", {})
	var other: Dictionary = brief.get("otherData", {})
	var tank: Array = Pve.CARD["imgTankAvatar"]
	var half: float = TankPortrait.BOX / 2.0
	_fblit("pq_card", at + _v(Pve.CARD["panel"]))
	if pack != null:
		var key: String = str(pack.lobby.get("avatars", {}).get(str(int(data.get("nAvatar", 0))), ""))
		var figure: Texture2D = pack.picture("l/av/%s.webp" % key) if not key.is_empty() else null
		if figure != null and figure.get_width() > 4:
			draw_texture_rect(figure, Rect2((at + _v(Pve.CARD["imgChar"])) * _f, Vector2(180, 240) * _f), false)
	_portrait(int(other.get("tankId", 0)), int(other.get("tankExternal", 0)), int(other.get("tankLevel", 1)), int(other.get("haloId", 0)), 
		at + Vector2(float(tank[0]) + half, float(tank[1]) + half), 1.0)
	_fblit("level_%d" % clampi(int(data.get("bLevel", 1)), 0, 40), at + _v(Pve.CARD["frmCurrentLevel"]), 64.0, 32.0)
	var rank: int = pve_rank(battle.outcome, battle.roster, int(battle.self_id))
	if rank >= 1 and rank <= 5:
		_fblit("pq_rank_%d" % rank, at + _v(Pve.CARD["imgRank"]))
	var values: Array = me.get("m_iStatData", [])
	var name: String = str(battle.names.get(int(battle.self_id), data.get("szName", "")))
	for pair: Array in [["lblCharName", name], ["lblScore", str(stat_of(values, STAT_SCORE) / 1000)], 
			["lblExp", str(stat_of(values, STAT_EXP))], ["lblMerit", str(int(me.get("m_iTeamMerit", 0)))]]:
		var spec: Array = Pve.CARD_TEXTS[pair[0]]
		_fwords(str(pair[1]), ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), Color(str(spec[5])), str(spec[7]), 
			at + Vector2(float(spec[0]), float(spec[1])), float(spec[2]), 0.0, float(spec[3]))


func _pve_label(o: Vector2, key: String, text: String) -> void :
	var spec: Array = Pve.TEXTS[key]
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), Color(str(spec[5])), str(spec[7]), 
		o + Vector2(float(spec[0]), float(spec[1])), float(spec[2]), 0.0, float(spec[3]))


func _vip_self() -> int:
	if client == null or pack == null:
		return 0
	return _vip_level(int(client.character.get("vipPoints", 0)))





static func pve_rewards(award: Dictionary) -> Array:
	var out: Array = []
	var base: Dictionary = {}
	var order: Array = []
	for kind: int in [ST_BASE, ST_ROOM]:
		for item: Dictionary in _settle(award, kind):
			var id: int = int(item.get("m_itemId", 0))
			if not base.has(id):
				order.append(id)
			base[id] = int(base.get(id, 0)) + int(item.get("m_count", 0))
	for id: int in order:
		out.append({"id": id, "count": base[id], "sign": ""})
	for item: Dictionary in _settle(award, ST_ACT):
		out.append({"id": int(item.get("m_itemId", 0)), "count": int(item.get("m_count", 0)), "sign": ""})
	for pair: Array in [[ST_DAILY, "daily"], [ST_VIP, "vip"], [ST_DOUBLE, "double"], [ST_DECORATE, "decorate"]]:
		for item: Dictionary in _settle(award, int(pair[0])):
			out.append({"id": int(item.get("m_itemId", 0)), "count": int(item.get("m_count", 0)), "sign": pair[1]})
	return out


static func pve_rank(outcome: Dictionary, roster: Array, self_id: int) -> int:
	var rows: Array = []
	for stat: Dictionary in outcome.get("m_tankVec", []):
		var id: int = int(stat.get("m_charOid", 0))
		if _brief_of(roster, id).is_empty():
			continue
		var values: Array = stat.get("m_iStatData", [])
		rows.append({"id": id, "score": stat_of(values, STAT_SCORE), "kill": stat_of(values, STAT_KILL), "dead": stat_of(values, STAT_DEAD), 
			"index": rows.size()})
	rows.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		if a.score != b.score: return a.score > b.score
		if a.kill != b.kill: return a.kill > b.kill
		if a.dead != b.dead: return a.dead < b.dead
		return a.index < b.index)
	for i in range(rows.size()):
		if int(rows[i].id) == self_id:
			return i + 1
	return 0


static func red_num(map_id: int) -> int:
	var row: Variant = PveHall.MAPS.get(str(map_id), [])
	return int(row[2]) if row is Array and (row as Array).size() > 2 else 3


static func digits(value: int) -> Array:
	var text: String = str(absi(value))
	var out: Array = []
	for i in range(text.length()):
		out.append([int(text[i]), 30 * i])
	return out


static func clock_cells(minutes: int, seconds: int) -> Array:
	var out: Array = []
	for pair: Array in [[minutes, 0], [seconds, 3]]:
		var text: String = str(absi(int(pair[0])))
		if text.length() == 1:
			text = "0" + text
		for i in range(2):
			out.append([int(text[i]), 30 * (i + int(pair[1]))])
	out.insert(2, [10, 60])
	return out


static func score_cell(grade: int, large: bool) -> String:
	if grade < int(Pve.SCORE[0]) or grade > int(Pve.SCORE[1]):
		return ""
	return ("pq_score_l_%d" if large else "pq_score_%d") % grade
