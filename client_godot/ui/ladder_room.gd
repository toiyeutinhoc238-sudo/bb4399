extends "pve_room.gd"
















const LRm = preload("ladder_room_atlas.gd")
const Quick = preload("quickmatch_atlas.gd")

const TIME_GOLD: Color = Color("fcff00")
const TIME_RIM: Color = Color(0.0, 0.4, 0.682, 0.8)
const PAIR_TEXT2: String = "Thời hạn: @time@."
const WAIT_SPAN: int = 300
const BROAD: Vector2 = Vector2(482, 395)


func _ladder() -> bool:
	return client != null and client.has_method("pair_room") and client.pair_room()


func _ladder_cells() -> void :
	if _cells.has("lrm_start_bk"):
		return
	_use(LRm.FILE, LRm.R)
	_use(Quick.FILE, Quick.R)

static func _spot(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))





func _sites() -> Array:
	if not _ladder():
		return super ()
	var out: Array = []
	for id: int in client.room_state.members:
		out.append(id)
	return out


func gift_seat(id: int, key: String) -> void :
	if not _ladder():
		super (id, key)
		return
	var slot: int = _sites().find(id)
	if slot >= 0 and slot < CLAN_MAX:
		_gift_fx.play("c:%d" % slot, key)



func _draw_free(frame: Vector2) -> void :
	if not _ladder():
		super (frame)
		return
	_pve_cells()
	_ladder_cells()
	var seats: int = clampi(int(client.room_state.room.get("m_nMax", 10)), 0, CLAN_MAX)
	var sites: Array = _sites()

	for slot in range(CLAN_MAX - 1, -1, -1):
		var at: Vector2 = frame + Vector2(float(CLAN_X[slot]), CLAN_Y)
		if slot >= seats:
			_draw_closed(at, slot)
		else:
			_draw_clan_card(at, slot, int(sites[slot]) if slot < sites.size() else 0)
	_draw_start()


func _draw_start() -> void :
	if not _ladder():
		super ()
		return
	_ladder_cells()
	var frame: Vector2 = _at("hall")
	if not client.pairing.is_empty():
		_draw_broad(frame + BROAD)
		return
	if not client.room_state.is_host():
		_fblit("lrm_box", frame + _spot(LRm.BOX))
		_fblit("lrm_wait_t", frame + _spot(LRm.WORD))
		return
	var at: Vector2 = frame + _spot(LRm.START)
	var map: Vector2 = at + _spot(LRm.MAP)
	_map_art("s", _map_id(), map, 168.0, 100.0)
	_hit("map", Rect2(map * _f, Vector2(float(LRm.MAP[2]), float(LRm.MAP[3])) * _f), false)
	_fblit("lrm_start_bk", at)
	var button: Vector2 = at + _spot(LRm.BUTTON)
	_fblit("gameroom_cancelready_disable_button_t", button)
	_fbutton("start", "gameroom_startgame_button_t", button)


func _draw_broad(broad: Vector2) -> void :
	_fmid("gda_qm_wait_t", broad + Vector2(0, 14), 298.0)
	var since: int = int(client.pairing.get("since", Time.get_ticks_msec()))
	var spent: int = maxi(0, floori((Time.get_ticks_msec() - since) / 1000.0))
	_fwords(_clock_text(spent), BOLD, 22.0, TIME_GOLD, "c", broad + Vector2(0, 40), 298.0, 2.0, 0.0, true, TIME_RIM)
	var button: Rect2 = _fblit("gda_qm_btn", broad + Vector2(59, 80), 0.0, 0.0, _glow("match:cancel"))
	_hit("match:cancel", button, false)
	_fblit("gda_qm_cancel_t", broad + Vector2(59, 80) + ((_cell_size("gda_qm_btn") - _cell_size("gda_qm_cancel_t")) / 2.0).round())
	var avg: int = int(client.pairing.get("avg", 0))
	if avg <= 0 or avg > WAIT_SPAN:
		avg = WAIT_SPAN
	_fwords(PAIR_TEXT2.replace("@time@", _clock_text(avg)), BOLD, 14.0, Color.WHITE, "c", broad + Vector2(0, 127), 298.0, 1.5, 0.0, true, TIME_RIM)

func _clock_text(seconds: int) -> String:
	return "%02d:%02d" % [floori(seconds / 60.0), seconds % 60]



func _activate(id: String) -> void :
	if not _ladder() or not _clan_sheet.is_empty():
		super (id)
		return
	match id:
		"match:cancel":
			client.stop_match()
		"start":
			var why: String = client.pvp_room_match() if client.pvp_room() else client.ladder_room_match()
			if not why.is_empty():
				say(why)
		"map":
			say(TIP_120)
		"leave", "back":
			if client.is_pairing():
				say(client.INVITE_PAIRING)
			else:
				client.leave_room()
		_:
			super (id)
