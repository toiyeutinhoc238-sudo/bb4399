extends RefCounted










const Happy = preload("../ui/happy_atlas.gd")
const TankPortrait = preload("../ui/tank_portrait.gd")
const TankPreview = preload("../ui/tank_preview.gd")
const GarageModel = preload("../ui/garage_model.gd")
const TimeOver = preload("../ui/timeover_atlas.gd")
const SELF_PATH: String = "res://battle/happy_hud.gd"
const META: StringName = &"happy_hud"
const ROOM_HAPPY: int = 100
const ASSIST: Color = Color("ffb400")
const RANK: Color = Color("fff04a")
const CARD: Color = Color("ff4bec")
const KILL: Color = Color("ff3d2e")
const GLOW: Color = Color(22 / 255.0, 0, 0, 0.8)
const NORMAL_STEP: int = 65
const SELF_STEP: int = 85
const BRIEF_MAX: int = 2
const BRIEF_LINE: float = 18.0
const KILL_MAX: int = 40
const KILL_LINE: float = 18.0
const KILL_SHOWN: int = 4
const TALK_TIME: float = 5.0
const TALK_LINE: float = 18.0
const TALK_LINES: int = 3
const TALK_TEXT: Color = Color("160000")
const AVATAR_ZOOM: float = 0.25
const FLY_FPS: float = 24.0
const FLY_FRAMES: int = 24
const FLY_SPEED: float = 8.0
const FLY_ACCEL: float = 0.5
const TIPS: Dictionary = {
	188: "Hạng nhất bị hạ, bạn được @num1@ điểm", 
	189: "May quá, kiếm được @num1@ điểm", 
	190: "Hạng nhất bị hạ, bạn được thêm @num1@ điểm", 
	191: "Hủy Tank thứ @num1@, được @num2@ điểm", 
	192: "Bị đánh bại đầu tiên, mất @num1@ điểm", 
	198: "Tham gia phá Tank thứ @num1@, được @num2@ điểm", 
	199: "Bạn đã phá 1 chiếc Tank, được @num1@ điểm", 
	204: "Thông tin chiến trường thay đổi rất nhanh, trong nháy mắt hạng của bạn đã là hạng @num1@", 
	205: "Bạn @num1@ @killType@ @name@ @num2@, nhận được @num3@ điểm", 
	206: "Bạn @num1@ @killType@ có xếp hạng thấp hơn bạn là @name@ @num2@, không được điểm", 
	207: "Bạn @num1@ may mắn nhận được thẻ @num2@ điểm", 
	208: "Đòn chí mạng", 
	209: "Tham gia đánh bại", 
	210: "Hạng @num1@", 
	211: "Không may, mất @num1@ điểm", 
	212: "Bạn @num1@ không may nhận được thẻ @num2@ điểm", 
}

var key: String = ""
var frames: Dictionary = {}
var order: Array = []
var inited: bool = false
var sig: String = ""
var width: int = 0
var last_score: int = 0
var last_rank: int = 0
var brief: Array = []
var kill_text: Array = []
var flies: Array = []
var client = null
var pack = null
var _sheet: Variant = null


static func of(hud: Object) -> RefCounted:
	if not hud.has_meta(META):
		hud.set_meta(META, load(SELF_PATH).new())
	return hud.get_meta(META)

static func draw_on(hud, battle, game) -> void :
	if battle == null or battle.mode != "happy":
		return
	var me: RefCounted = of(hud)
	me.pack = hud.pack
	me.hook(game)
	me.sync(battle)
	me.paint(hud, battle)

func hook(game) -> void :
	if game == null or not game is Object:
		return
	client = game
	if game.has_signal("happy_packet") and not game.is_connected("happy_packet", _on_packet):
		game.connect("happy_packet", _on_packet)

func _ensure(battle) -> void :
	var now: String = "%d:%d" % [battle.get_instance_id(), int(battle.begun)]
	if now == key:
		return
	key = now
	frames = {}
	order = []
	inited = false
	sig = ""
	width = 0
	last_score = 0
	last_rank = 0
	brief = []
	kill_text = []
	flies = []



func sync(battle) -> void :
	_ensure(battle)
	if not inited and ( not battle.roster.is_empty() or not battle.happy.is_empty()):
		_init_players(battle)
		inited = true
	if battle.happy.is_empty():
		return
	var now: String = "%s|%s" % [str(battle.happy), str(battle.tanks.keys())]
	if now != sig:
		sig = now
		_refresh(battle)

func _init_players(battle) -> void :
	var me: int = int(battle.self_id)
	var list: Array = []
	for brief_row: Variant in battle.roster:
		if brief_row is Dictionary and brief_row.get("charData") is Dictionary and int(brief_row.get("bCamp", 1)) == 1:
			list.append(brief_row)
	if list.is_empty():
		for brief_row: Variant in battle.roster:
			if brief_row is Dictionary and brief_row.get("charData") is Dictionary:
				list.append(brief_row)
	var x: int = 0
	for i in range(list.size()):
		var account: int = int(list[i].charData.get("nAcctId", 0))
		var obj: int = _tank_of(battle, account)
		var frame: Dictionary = _blank(obj, account, account == me)
		_dress(frame, list[i])
		frame.rank = i + 1
		frame.x = x
		x += SELF_STEP if frame.self else NORMAL_STEP
		frames[obj] = frame
		order.append(obj)
	width = x



func _refresh(battle) -> void :
	for obj: int in frames:
		frames[obj].visible = false
	var x: int = 0
	var rank: int = 0
	for obj: int in order_of(battle.happy):
		rank += 1
		var fresh_self: bool = false
		if not frames.has(obj):
			var made: Dictionary = _create(battle, obj)
			if made.is_empty():
				continue
			fresh_self = bool(made.self)
			frames[obj] = made
			order.append(obj)
		var frame: Dictionary = frames[obj]
		frame.visible = true
		frame.rank = rank
		frame.score = int(battle.happy[obj]) / 1000
		frame.x = x
		x += SELF_STEP if fresh_self else NORMAL_STEP
	width = x

func _create(battle, obj: int) -> Dictionary:
	if battle.tanks.has(obj):
		var tank: Dictionary = battle.tanks[obj]
		var account: int = int(tank.get("account", obj))
		var frame: Dictionary = _blank(obj, account, account == int(battle.self_id))
		_dress(frame, brief_of(battle, account))
		return frame
	if battle.npcs.has(obj):
		var row: Array = pack.ainpc_row(int(battle.npcs[obj].get("template", 0))) if pack != null else []
		var frame: Dictionary = _blank(obj, 0, false)
		frame.npc = true
		frame.name = str(row[4]) if row.size() > 4 else ""
		frame.ext = int(row[0]) if row.size() > 0 else 0
		return frame
	return {}

static func _blank(obj: int, account: int, mine: bool) -> Dictionary:
	return {"obj": obj, "account": account, "self": mine, "npc": false, "name": "", "tank": 0, "ext": 0, "level": 1, 
		"x": 0, "rank": 0, "score": -1, "visible": true, "hp": 0.0}


static func _dress(frame: Dictionary, brief_row: Dictionary) -> void :
	if brief_row.is_empty():
		return
	var data: Dictionary = brief_row.get("charData") if brief_row.get("charData") is Dictionary else {}
	var other: Dictionary = brief_row.get("otherData") if brief_row.get("otherData") is Dictionary else {}
	frame.name = str(data.get("szName", ""))
	frame.tank = int(other.get("tankId", 0))
	frame.ext = int(other.get("tankExternal", 0))
	frame.level = maxi(1, int(other.get("tankLevel", 1)))

static func brief_of(battle, account: int) -> Dictionary:
	for row: Variant in battle.roster:
		if row is Dictionary and row.get("charData") is Dictionary and int(row.charData.get("nAcctId", 0)) == account:
			return row
	return {}

static func _tank_of(battle, account: int) -> int:
	for tank: Dictionary in battle.tanks.values():
		if int(tank.get("account", 0)) == account:
			return int(tank.id)
	return account

static func _name_of(battle, obj: int, ainpc: Callable = Callable()) -> String:
	if battle.tanks.has(obj):
		return str(battle.tanks[obj].get("name", ""))
	if battle.npcs.has(obj) and ainpc.is_valid():
		var row: Array = ainpc.call(int(battle.npcs[obj].get("template", 0)))
		return str(row[4]) if row.size() > 4 else ""
	return ""


func _on_packet(type: int, value: Dictionary) -> void :
	if client == null or not is_instance_valid(client) or client.battle == null:
		return
	var battle = client.battle
	if battle.mode != "happy":
		return
	_ensure(battle)
	match type:
		1573:
			var scores: Dictionary = battle.happy.duplicate()
			for row: Variant in value.get("m_values", []):
				if row is Dictionary:
					scores[int(row.get("m_obj", 0))] = int(row.get("m_value", 0))
			_no_change(scores, int(battle.self_id))
		1574:
			_score_in(battle, value)
		1566:
			if int(battle.room_type) == ROOM_HAPPY:
				_kill_in(battle, value.get("m_killInfo") if value.get("m_killInfo") is Dictionary else value)



func _score_in(battle, value: Dictionary) -> void :
	var row: Dictionary = value.get("m_values") if value.get("m_values") is Dictionary else {}
	var obj: int = int(row.get("m_obj", 0))
	var me: int = int(battle.self_id)
	var mine: bool = me != 0 and obj == me
	var scores: Dictionary = battle.happy.duplicate()
	var target: int = int(value.get("m_target", 0))
	var self_old: int = rank_in(scores, obj) if mine else 0
	var target_old: int = rank_in(scores, target) if mine else 0
	var before: int = int(scores.get(obj, 0))
	scores[obj] = int(row.get("m_value", 0))
	_no_change(scores, me)
	if not mine:
		return
	var cv: int = (int(row.get("m_value", 0)) - before) / 1000
	if cv == 0:
		return
	flies.append({"value": cv, "t": float(battle.clock)})
	var name: String = _name_of(battle, target, pack.ainpc_row if pack != null else Callable())
	var out: Dictionary = score_tips(int(value.get("m_reaon", 0)), cv, rank_in(scores, target), self_old, target_old, name)
	if not str(out.kill).is_empty():
		_kill_line(battle, str(out.kill))
	if not str(out.brief).is_empty():
		_brief_line(str(out.brief), out.color)


func _no_change(scores: Dictionary, me: int) -> void :
	var now: int = int(scores.get(me, 0))
	var rank: int = rank_in(scores, me)
	if last_score == now and last_rank != rank:
		_brief_line(_sub(TIPS[204], "@num1@", str(rank)), RANK)
	last_rank = rank
	last_score = now




func _kill_in(battle, info: Dictionary) -> void :
	var me: int = int(battle.self_id)
	var killer: int = int(info.get("m_killerObjId", 0))
	var dead: int = int(info.get("m_deadObjId", 0))
	if me == 0 or killer == dead or not battle.tanks.has(dead) or battle.npcs.has(killer):
		return
	var helpers: Array = []
	for helper: Variant in info.get("m_assistTankId", []):
		helpers.append(int(helper))
	if killer != me and not helpers.has(me):
		return
	if killer == me:
		return
	if higher(battle.happy, dead, me):
		return
	_brief_line(no_score_tip(rank_in(battle.happy, me), rank_in(battle.happy, dead), str(battle.tanks[dead].get("name", "")), 
		killer == me), Color.WHITE)

func _brief_line(text: String, color: Color) -> void :
	if brief.size() >= BRIEF_MAX:
		brief.pop_front()
	brief.append({"text": text, "color": color})



func _kill_line(battle, text: String) -> void :
	if shared_kill_area(battle):
		if battle.kill_lines.size() >= KILL_MAX:
			battle.kill_lines.pop_front()
		battle.kill_lines.append({"text": text, "key": 0, "t": float(battle.clock)})
		return
	if kill_text.size() >= KILL_MAX:
		kill_text.pop_front()
	kill_text.append({"text": text, "t": float(battle.clock)})

static func shared_kill_area(battle) -> bool:
	return battle != null and "kill_lines" in battle and battle.has_method("kill_segments")\
	and not battle.kill_segments({"text": "x"}, {}).is_empty()



static func rank_in(scores: Dictionary, id: int) -> int:
	var mine: int = int(scores.get(id, 0))
	if mine / 1000 <= 0:
		return 0
	var rank: int = 1
	for other: Variant in scores:
		var value: int = int(scores[other])
		if int(other) != id and (value > mine or (value == mine and int(other) < id)):
			rank += 1
	return rank


static func higher(scores: Dictionary, id: int, than: int) -> bool:
	var a: int = int(scores.get(id, 0))
	var b: int = int(scores.get(than, 0))
	return a > b or (a == b and id < than)


static func order_of(scores: Dictionary) -> Array:
	var list: Array = []
	for obj: Variant in scores:
		list.append(int(obj))
	list.sort_custom( func(a: int, b: int) -> bool:
		var va: int = int(scores[a])
		var vb: int = int(scores[b])
		return va > vb or (va == vb and a < b))
	return list


static func rank_desc(rank: int) -> String:
	return "" if rank <= 0 else _sub(TIPS[210], "@num1@", str(rank))


static func _sub(text: String, wild: String, value: String) -> String:
	var at: int = text.find(wild)
	if at < 0:
		return text
	return text.left(at) + value + text.substr(at + wild.length())


static func kill_tip(kind: int, self_old: int, target_old: int, name: String, cv: int) -> String:
	var text: String = _sub(TIPS[205], "@num1@", rank_desc(self_old))
	text = _sub(text, "@killType@", str(TIPS.get(kind, "")))
	text = _sub(text, "@name@", name)
	text = _sub(text, "@num2@", rank_desc(target_old))
	return _sub(text, "@num3@", str(cv))


static func card_tip(self_old: int, cv: int) -> String:
	var text: String = _sub(TIPS[207 if cv > 0 else 212], "@num1@", rank_desc(self_old))
	return _sub(text, "@num2@", str(cv))


static func no_score_tip(self_rank: int, dead_rank: int, name: String, killed: bool) -> String:
	var text: String = _sub(TIPS[206], "@num1@", rank_desc(self_rank))
	text = _sub(text, "@num2@", rank_desc(dead_rank))
	text = _sub(text, "@name@", name)
	return _sub(text, "@killType@", str(TIPS[208 if killed else 209]))


static func score_tips(reason: int, cv: int, r: int, self_old: int, target_old: int, name: String) -> Dictionary:
	var out: Dictionary = {"kill": "", "brief": "", "color": Color.WHITE}
	match reason:
		13:
			out.kill = _sub(TIPS[188], "@num1@", str(cv))
			out.brief = kill_tip(209, self_old, target_old, name, cv)
			out.color = ASSIST
		12:
			out.kill = _sub(TIPS[189], "@num1@", str(cv)) if cv >= 0 else _sub(TIPS[211], "@num1@", str( - cv))
			out.brief = card_tip(self_old, cv)
			out.color = CARD
		11:
			out.kill = _sub(TIPS[190], "@num1@", str(cv))
			out.brief = kill_tip(208, self_old, target_old, name, cv)
			out.color = KILL
		4:
			out.kill = _sub(TIPS[199], "@num1@", str(cv)) if r <= 0 else _sub(_sub(TIPS[191], "@num1@", str(r)), "@num2@", str(cv))
			out.brief = kill_tip(208, self_old, target_old, name, cv)
			out.color = KILL
		15:
			out.kill = _sub(TIPS[199], "@num1@", str(cv)) if r <= 0 else _sub(_sub(TIPS[198], "@num1@", str(r)), "@num2@", str(cv))
			out.brief = kill_tip(209, self_old, target_old, name, cv)
			out.color = ASSIST
		14:
			out.kill = _sub(TIPS[192], "@num1@", str( - cv))
	return out


static func fly_state(frames_done: int) -> Vector2:
	var speed: float = FLY_SPEED
	var rise: float = 0.0
	var alpha: float = 1.0
	for i in range(frames_done):
		if speed > 0.0:
			rise += speed
			speed -= FLY_ACCEL
			alpha = clampf(speed, 0.0, 1.0)
	return Vector2(rise, alpha)


static func digit_x(n: int, i: int, mine: bool) -> int:
	var at: Array = Happy.NUM2.self if mine else Happy.NUM2.other
	return int(at[0]) + int((int(Happy.NUM2.rect) - n * int(Happy.NUM2.step)) / 2.0) + i * int(Happy.NUM2.step)


func _tex() -> Texture2D:
	if _sheet == null:
		_sheet = load(Happy.FILE) if ResourceLoader.exists(Happy.FILE) else false
	return _sheet if _sheet is Texture2D else null

func _cell(hud, name: String, at: Vector2, tint: Color = Color.WHITE, size: Vector2 = Vector2(-1, -1)) -> void :
	var sheet: Texture2D = _tex()
	if sheet == null or not Happy.R.has(name):
		return
	var r: Array = Happy.R[name]
	var wide: Vector2 = Vector2(float(r[2]), float(r[3])) if size.x < 0 else size
	hud.view.draw_texture_rect_region(sheet, Rect2(at, wide), Rect2(r[0], r[1], r[2], r[3]), tint)


func _part(hud, name: String, index: int, cell: Vector2, row: int, at: Vector2, tint: Color = Color.WHITE) -> void :
	var sheet: Texture2D = _tex()
	if sheet == null or not Happy.R.has(name):
		return
	var r: Array = Happy.R[name]
	hud.view.draw_texture_rect_region(sheet, Rect2(at, cell), Rect2(float(r[0]) + index * cell.x, float(r[1]) + row * cell.y, cell.x, cell.y), tint)


static func draw_top(hud, battle) -> void :
	var me: RefCounted = of(hud)
	me.pack = hud.pack
	var top: Dictionary = Happy.TOP
	me._cell(hud, "vv_timeboard", Vector2(top.timeboard[0], top.timeboard[1]))
	if battle.clock_icon:
		me._cell(hud, "vv_clock", Vector2(top.clock[0], top.clock[1]))
	if battle.clock_shown:
		var count: Array = top.count
		var text: String = hud.clock_text(int(battle.clock_left))
		var size: int = int(TimeOver.CLOCK[0])
		var base: Vector2 = Vector2(float(count[0]), float(count[1]) + size + 1)
		hud.view.draw_string_outline(hud.bold, base, text, HORIZONTAL_ALIGNMENT_CENTER, float(count[2]), size, 3, Color(1, 1, 1, 0.9))
		hud.view.draw_string(hud.bold, base, text, HORIZONTAL_ALIGNMENT_CENTER, float(count[2]), size, Color.BLACK)
	if battle.over_shown and hud.pack != null:
		var over: Dictionary = hud.pack.effect(TimeOver.OVER)
		if not over.is_empty():
			hud._fx_frame(over, Vector2(top.over[0], top.over[1]), int(floor(battle.clock * TimeOver.FPS)) % over.data.frames.size())

func paint(hud, battle) -> void :
	var view: Control = hud.view
	var k: float = hud.scale
	var origin: Vector2 = Vector2(roundf(view.size.x / 2.0 - width / 2.0 * k), 0)
	for obj: int in order:
		var frame: Dictionary = frames[obj]
		var actor: Dictionary = battle.tanks.get(obj, battle.npcs.get(obj, {}))
		if not actor.is_empty():
			frame.hp = clampf(float(actor.get("hp", 0)) / maxf(1.0, float(actor.get("max_hp", 1))), 0.0, 1.0)
		if not frame.visible:
			continue
		var at: Vector2 = origin + Vector2(float(frame.x), 0) * k
		hud._at(at)
		_frame(hud, battle, frame, at)
	_brief(hud)
	if not kill_text.is_empty() and not shared_kill_area(battle):
		_kills(hud)
	_flies(hud, battle)
	view.draw_set_transform(Vector2.ZERO)


func _frame(hud, battle, frame: Dictionary, at: Vector2) -> void :
	var mine: bool = bool(frame.self)
	var side: String = "self" if mine else "other"
	var lay: Dictionary = Happy.PLAYER[side]
	var texts: Dictionary = Happy.PLAYER_TEXTS[side]
	_cell(hud, "vv_pf_self" if mine else "vv_pf_other", Vector2.ZERO)
	var av: Array = lay.avatarview1
	_avatar(hud, frame, Vector2(float(av[0]), float(av[1])) + Vector2.ONE * TankPortrait.BOX * 0.5 * AVATAR_ZOOM, at, float(battle.clock))
	var label: Array = texts.lblPlayerName
	var name: String = hud._fit(str(frame.name), float(label[2]) - 4.0, int(label[4]))
	hud._text(Vector2(float(label[0]), float(label[1])), name, Color(str(label[5])), int(label[4]), HORIZONTAL_ALIGNMENT_CENTER, 
		float(label[2]), false, 3)
	var bar: Array = lay.pgsTankBlood
	_hp(hud, Rect2(float(bar[0]), float(bar[1]), float(bar[2]), float(bar[3])), float(frame.hp))
	var rank: int = int(frame.rank)
	if rank >= 1 and rank <= int(Happy.RANKS):
		_cell(hud, "vv_hr_%d" % rank, Vector2(float(lay.imgRank[0]), float(lay.imgRank[1])))
	if int(frame.score) >= 0:
		var digits: String = str(int(frame.score))
		var row: Array = Happy.NUM2.self if mine else Happy.NUM2.other
		var cell: Vector2 = Vector2(float(Happy.NUM2.cell[0]), float(Happy.NUM2.cell[1]))
		for i in range(digits.length()):
			_part(hud, "vv_num2", int(digits[i]), cell, 0 if mine else 1, Vector2(digit_x(digits.length(), i, mine), float(row[1])))
	if not bool(frame.npc):
		var talk: Dictionary = battle.bubbles.get(int(frame.account), battle.bubbles.get(int(frame.obj), {}))
		if not talk.is_empty() and float(battle.clock) - float(talk.get("t", -100.0)) <= TALK_TIME:
			_talk(hud, lay, texts, str(talk.get("text", "")))


func _hp(hud, rect: Rect2, fraction: float) -> void :
	var top: Color = Color(str(Happy.BAR.track[0]))
	var bottom: Color = Color(str(Happy.BAR.track[1]))
	hud.view.draw_polygon(PackedVector2Array([rect.position, Vector2(rect.end.x, rect.position.y), rect.end, Vector2(rect.position.x, rect.end.y)]), 
		PackedColorArray([top, top, bottom, bottom]))
	if fraction > 0.0:
		_cell(hud, "vv_bar", rect.position, Color.WHITE, Vector2(rect.size.x * fraction, rect.size.y))


func _talk(hud, lay: Dictionary, texts: Dictionary, text: String) -> void :
	var y: float = float(lay.chat[1])
	_cell(hud, "vv_talk_1", Vector2(4, y + 1))
	_cell(hud, "vv_talk_2", Vector2(float(lay.image2[0]), float(lay.image2[1])))
	_cell(hud, "vv_talk_3", Vector2(float(lay.image3[0]), float(lay.image3[1])))
	var spot: Array = texts.txtChatContent
	var lines: Array[String] = hud._wrap_lines(text, float(spot[2]), int(spot[4]))
	for i in range(mini(lines.size(), TALK_LINES)):
		hud._text(Vector2(float(spot[0]), float(spot[1]) + i * TALK_LINE), lines[i], TALK_TEXT, int(spot[4]), HORIZONTAL_ALIGNMENT_LEFT, 
			-1, true, 0)


func _avatar(hud, frame: Dictionary, centre: Vector2, at: Vector2, clock: float) -> void :
	if pack == null or str(pack.get("state")) != "ready":
		return
	var tank_id: int = int(frame.tank)
	var ext: int = int(frame.ext)
	if ext <= 0 and tank_id > 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, int(frame.level), {})
	if ext > 0 and hud._portrait(GarageModel.face(pack.garage, ext), 0, centre, AVATAR_ZOOM, clock, Color.WHITE):
		return
	if tank_id <= 0:
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(int(frame.ext)), tank_id))
	if TankPreview.ready(art):
		TankPreview.draw(hud.view, art, at + centre * hud.scale, 0.27 * hud.scale, 4, clock)
		hud._at(at)


func _brief(hud) -> void :
	if brief.is_empty():
		return
	var spot: Array = Happy.GAME.txtHappyTip
	var k: float = hud.scale
	hud._at(Vector2(hud.view.size.x / 2.0 - float(spot[2]) / 2.0 * k, float(spot[1]) * k))
	for i in range(brief.size()):
		hud._text(Vector2(0, i * BRIEF_LINE), str(brief[i].text), brief[i].color, int(spot[4]), HORIZONTAL_ALIGNMENT_CENTER, 
			float(spot[2]), false, 3)


func _kills(hud) -> void :
	var spot: Array = Happy.GAME.txtKillArea
	var k: float = hud.scale
	hud._at(Vector2(hud.view.size.x - float(spot[2]) * k, float(spot[1]) * k))
	var size: int = int(spot[4])
	var ascent: float = hud.font.get_ascent(size)
	var from: int = maxi(0, kill_text.size() - KILL_SHOWN)
	for i in range(from, kill_text.size()):
		var base: Vector2 = Vector2(2, 2 + (i - from) * KILL_LINE + ascent)
		var text: String = str(kill_text[i].text)
		hud.view.draw_string_outline(hud.font, base, text, HORIZONTAL_ALIGNMENT_RIGHT, float(spot[2]) - 4, size, 3, GLOW)
		hud.view.draw_string(hud.font, base, text, HORIZONTAL_ALIGNMENT_RIGHT, float(spot[2]) - 4, size, Color.WHITE)


func _flies(hud, battle) -> void :
	var keep: Array = []
	var cell: Vector2 = Vector2(float(Happy.FLY.cell[0]), float(Happy.FLY.cell[1]))
	for fly: Dictionary in flies:
		var done: int = int(floor((float(battle.clock) - float(fly.t)) * FLY_FPS))
		if done >= FLY_FRAMES:
			continue
		keep.append(fly)
		var state: Vector2 = fly_state(maxi(0, done))
		if state.y <= 0.0:
			continue
		hud._at(hud.view.size / 2.0 + Vector2(0, - state.x) * hud.scale)
		var strip: String = "vv_fly_up" if int(fly.value) > 0 else "vv_fly_down"
		var tint: Color = Color(1, 1, 1, state.y)
		var digits: String = str(absi(int(fly.value)))
		_part(hud, strip, 0, cell, 0, Vector2( - float(Happy.FLY.step), 0), tint)
		for i in range(digits.length()):
			_part(hud, strip, int(digits[i]) + 1, cell, 0, Vector2(i * float(Happy.FLY.step), 0), tint)
	flies = keep
