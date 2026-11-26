extends "pvp_result.gd"











const Happy = preload("../ui/happy_atlas.gd")
const ROOM_HAPPY: int = 100
const SELF_RING: Color = Color("ffff00")
const CONTINUE_TIP: String = "Ghép tiếp đang được chuyển sang HTML5."
const VIP_NAME: Color = Color("fff000")
const HEAD_ZOOM: float = 0.5
const STAGE_TANK_ZOOM: float = 0.65
const ROW_TANK_ZOOM: float = 0.17

func _setup() -> void :
	super ()
	_use(Happy.FILE, Happy.R)
	var vips: Dictionary = {}
	for cell: String in Hall.R:
		if cell.begins_with("vip_"):
			vips[cell] = Hall.R[cell]
	_use(Hall.FILE, vips)


static func wanted(game) -> bool:
	return game != null and game.state == "battle" and game.battle.ended and int(game.battle.room_type) == ROOM_HAPPY

func _activate(id: String) -> void :


	if not _report.is_empty() or id.begins_with("report:"):
		super (id)
		return
	match id:
		"back":
			client.leave_battle(2)
		"continue":


			if not client.has_method("pair_again") or ( not client.pair_again() and int(client.get("_room_action")) <= 0):
				say(CONTINUE_TIP)
		_:
			super (id)


static func happy_rows(outcome: Dictionary, roster: Array, names: Dictionary, tanks: Dictionary = {}) -> Array:
	var present: Dictionary = {}
	for tank: Variant in tanks.values():
		if tank is Dictionary:
			present[int(tank.get("account", 0))] = true
	var rows: Array = []
	for row: Dictionary in players(outcome, roster, names):
		if bool(row.leave) or ( not present.is_empty() and not present.has(int(row.id))):
			continue
		row.char_level = int(_brief_of(roster, int(row.id)).get("charData", {}).get("bLevel", 1))
		rows.append(row)
	for i in range(rows.size()):
		rows[i].rank = i + 1
	return rows



func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(Happy.SIZE[0]), float(Happy.SIZE[1]))
	_hit("panel", Rect2(o * _f, Vector2(float(Happy.SIZE[0]), float(Happy.SIZE[1])) * _f), false)
	var battle = client.battle
	_fblit("pr_bg", o + Vector2(2, 2))
	_fblit("pr_chat", o + _v(Happy.NODES["cvsChat"]))
	_fblit("pr_brief", o + _v(Happy.NODES["frmResult"]) + Vector2(7, 0))
	_fblit("vv_board", o + _v(Happy.PANELS["board"]))
	_fblit("vv_stage", o + _v(Happy.PANELS["stage"]))
	_rows(o, battle)

	_chat(o + Vector2(-1, 0), battle)
	_brief(o + Vector2(2, 219), battle)
	_stage_avatar(o, battle)
	_fbutton("continue", "vv_continue", o + _v(Happy.NODES["btnContinue"]))
	if not client.room_state.room.is_empty():
		_fblit("vv_backtip", o + _v(Happy.NODES["cvsBackTip"]))
		var spec: Array = Happy.TEXTS["lblPlayerBackNum"]
		_fwords(BACK_TIP % 0, ARIAL_BOLD, float(spec[4]), Color(str(spec[5])), str(spec[7]), o + Vector2(float(spec[0]), float(spec[1])), 
			float(spec[2]))
		_fbutton("back", "vv_backroom", o + _v(Happy.NODES["btnBackRoom"]))
	else:
		_fbutton("back", "vv_backhall", o + _v(Happy.NODES["btnBackHall"]))
	if not _report.is_empty():
		_report_window()

func _rows(o: Vector2, battle) -> void :
	var friends: Dictionary = {}
	for brief: Dictionary in client.friends.values():
		friends[str(brief.get("m_name", ""))] = true
	var rows: Array = happy_rows(battle.outcome, battle.roster, battle.names, battle.tanks)
	var list: Array = Happy.LIST
	for i in range(mini(int(list[3]), rows.size())):
		_row(o + Vector2(float(list[0]), float(list[1]) + float(list[2]) * i), rows[i], battle, friends)

func _row(at: Vector2, row: Dictionary, battle, friends: Dictionary) -> void :
	var mine: bool = int(row.id) == int(battle.self_id)
	if mine:
		var ring: Array = Happy.ROW["canvas1"]
		_round(Rect2((at + Vector2(float(ring[0]), float(ring[1]))) * _f, Vector2(float(ring[2]), float(ring[3])) * _f), Color(0, 0, 0, 0), 5.0, 
			SELF_RING, 3.0 / 2.0)
	var rank: int = int(row.rank)
	if rank >= 1 and rank <= int(Happy.RANKS):
		_fblit("vv_rank_%d" % rank, at + _v(Happy.ROW["imgRank"]))
	var avatar: Array = Happy.ROW["avatar"]
	var half: float = TankPortrait.BOX * ROW_TANK_ZOOM / 2.0
	_row_tank(row, at + Vector2(float(avatar[0]) + half, float(avatar[1]) + half), ROW_TANK_ZOOM)
	_fblit("level_%d" % clampi(int(row.get("char_level", 1)), 0, 40), at + _v(Happy.ROW["cvsLevel"]), 40.0, 20.0)
	_level_fx(int(row.get("char_level", 1)), at + _v(Happy.ROW["cvsLevel"]), 40.0)
	var tone: Color = Color(str(Happy.ROW_TEXTS["lblPlayerName"][5])) if mine else ENEMY_COLOR
	for key: String in ["lblPlayerName", "lblBattleData"]:
		var spec: Array = Happy.ROW_TEXTS[key]
		var text: String = str(row.name) if key == "lblPlayerName" else str(int(row.score) / 1000)
		_fwords(text, ARIAL_BOLD, float(spec[4]), tone, str(spec[7]), at + Vector2(float(spec[0]), float(spec[1])), float(spec[2]))
	if not mine:
		if not _asked.has(int(row.id)) and not friends.has(str(row.name)):
			_fbutton("friend:%d" % int(row.id), "pr_friend", at + _v(Happy.ROW["btnAddFriend"]))
		if not _reported.has(int(row.id)):
			_fbutton("report:%d" % int(row.id), "vv_report", at + _v(Happy.ROW["btnReport"]))
	_fblit("pr_cut", at + Vector2(0, 34))


func _stage_avatar(o: Vector2, battle) -> void :
	var killer: int = int(battle.outcome.get("m_nKiller", 0))
	_fblit("vv_killer", o + _v(Happy.NODES["imgKiller"]))
	if killer != 0 and killer == int(battle.outcome.get("m_nAssister", 0)):
		_fblit("vv_king", o + _v(Happy.NODES["imgAssistKing"]))
	var brief: Dictionary = _brief_of(battle.roster, killer)
	if killer == 0 or brief.is_empty():
		return
	var data: Dictionary = brief.get("charData", {})
	var other: Dictionary = brief.get("otherData", {})
	var spot: Array = Happy.NODES["tankAvatar"]
	var half: float = TankPortrait.BOX * STAGE_TANK_ZOOM / 2.0
	_portrait(int(other.get("tankId", 0)), int(other.get("tankExternal", 0)), int(other.get("tankLevel", 1)), int(other.get("haloId", 0)), 
		o + Vector2(float(spot[0]) + half, float(spot[1]) + half), STAGE_TANK_ZOOM)
	var key: String = str(pack.lobby.get("avatars", {}).get(str(int(data.get("nAvatar", 0))), "")) if pack != null else ""
	var head: Texture2D = pack.picture("l/h/%s.webp" % key) if not key.is_empty() else null
	if head != null:
		var face: Array = Happy.NODES["imgCharAvatar"]
		var wide: Vector2 = Vector2(head.get_width(), head.get_height()) * (60.0 / maxf(1.0, float(head.get_width())))

		draw_texture_rect(head, Rect2((o + Vector2(float(face[0]), float(face[1]))) * _f, Vector2( - wide.x, wide.y) * _f), false)
	var vip: int = clampi(int(data.get("nVipLevel", 0)) % 100, 0, 12)
	if vip > 0:
		_fblit("vip_%d" % vip, o + _v(Happy.NODES["imgVipLevel"]))
	var spec: Array = Happy.TEXTS["lblPlayerName"]
	_fwords(str(data.get("szName", "")), ARIAL, float(spec[4]), VIP_NAME if vip > 0 else Color.WHITE, "l", 
		o + Vector2(float(spec[0]), float(spec[1])), 200.0, 0.0, 0.0, false)
