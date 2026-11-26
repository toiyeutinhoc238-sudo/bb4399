extends "../ui/flash_screen.gd"




















const BattleSettings = preload("battle_settings.gd")
const SafeArea = preload("../ui/safe_area.gd")
const GarageModel = preload("../ui/garage_model.gd")
const MicroHeads = preload("micro_heads.gd")
const VoiceClient = preload("../ui/voice_client.gd")
const VoiceUI = preload("../ui/voice_ui.gd")
const TOUCH_HEADS: String = "res://battle/touch_heads.gd"
const WIDE: float = 500.0
const HIGH: float = 420.0
const KEY_G: int = 71
const CAMP_A: int = 1
const CAMP_B: int = 2
const ROOM_HAPPY: int = 100
const ENTER_LOOK: int = 2
const TITLE_RED: Color = Color("ff4d57")
const TITLE_BLUE: Color = Color("55aaff")
const HEAD: Color = Color("38f929")
const LABEL_GLOW: Color = Color(22 / 255.0, 0, 0, 0.8)
const GRID_GLOW: Color = Color(0, 0, 0, 0.8)

const COLUMN_WIDE: Array[float] = [102.5, 61.5, 61.5, 61.5, 61.5, 61.5]
const COLUMN_COLORS: Array[Color] = [Color("ffffff"), Color("00ff00"), Color("00ff00"), Color("ffff00"), Color("ff0000"), Color("ffffff")]
const HEAD_CENTRE: Array[float] = [-154.0, -70.0, -10.0, 53.0, 113.0, 173.0]
const GRID_X: float = 45.0
const ROW_HIGH: float = 20.0
const TEXT_GUTTER: float = 5.0

const NAME_TEXT: String = "Tên"
const LEVEL_TEXT: String = "LV Chiến Trường"
const SCORE_TEXT: String = "Điểm MVP"
const KILL_TEXT: String = "Diệt địch"
const DEATH_TEXT: String = "Sống còn"
const ASSIST_TEXT: String = "Trợ thủ"
const ROOM_TEXT: String = "Số room: %d"
const RED_TEXT: String = "Chiến công đội đỏ"
const BLUE_TEXT: String = "Chiến công đội xanh"

var held: int = 0
var _held_seen: bool = false
var _rows: Array = [[], []]
var _built: Array[int] = [-1, -1]
var _battle: Object = null
var _lines: Array = [[], []]
var touch_rects: Dictionary = {}

const T_W: float = 1110.0
const T_GAP: float = 70.0
const T_PAD: float = 12.0
const T_BAND: float = 56.0
const T_HEAD_Y: float = 81.0
const T_ROWS_Y: float = 92.0
const T_FOOT: float = 34.0
const T_KDA_END: float = 190.0
const T_SCORE_END: float = 58.0
const T_MUTE_X: float = 30.0
const T_MUTE_R: float = 17.0
const T_ROW: float = 58.0
const T_AV_R: float = 21.0
const T_GLASS: Color = Color(0.03, 0.045, 0.08, 0.9)
const T_BLUE: Color = Color("2f78e0")
const T_RED: Color = Color("d8394a")
const T_BLUE_RING: Color = Color("55aaff")
const T_RED_RING: Color = Color("ff4d57")
const T_SELF: Color = Color("ffd84a")
const T_GREY: Color = Color("9aa6ba")
const T_DIM: Color = Color("6f7a8e")
const T_SCORE: Color = Color("ffe27a")
const T_KDA_HEAD: String = "%s / %s / %s" % [KILL_TEXT, DEATH_TEXT, ASSIST_TEXT]

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func key(event: InputEventKey, who) -> bool:
	if who == null or who.key_action(BattleSettings.flash_key(event.physical_keycode)) != KEY_G:
		if not event.pressed and held != 0 and event.physical_keycode == held:
			hide_board()
			return true
		return false
	if event.pressed:
		if not event.echo:
			visible = true
			held = event.physical_keycode
			_held_seen = false
	else:
		hide_board()
	return true

func hide_board() -> void :
	visible = false
	held = 0
	_held_seen = false


func _notification(what: int) -> void :
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT] and visible:
		hide_board()

func _tick(_delta: float) -> void :
	if held == 0:
		return
	var down: bool = Input.is_physical_key_pressed(held)
	if down:
		_held_seen = true
	elif _held_seen:
		hide_board()



static func view_camp(battle) -> int:
	var look: bool = int(battle.enter_type) == ENTER_LOOK
	var camp: int = CAMP_A if look else 0
	for brief: Variant in battle.roster:
		if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) == int(battle.self_id):
			if not look or int(brief.get("bCamp", 0)) != 0:
				camp = int(brief.get("bCamp", 0))
			break
	if look and "look_camp_id" in battle:
		camp = int(battle.look_camp_id)
	return camp


static func titles(camp: int) -> Array:
	if camp == CAMP_B:
		return [[RED_TEXT, TITLE_RED], [BLUE_TEXT, TITLE_BLUE]]
	return [[BLUE_TEXT, TITLE_BLUE], [RED_TEXT, TITLE_RED]]


static func heads(level_map: bool) -> Array:
	if level_map:
		return [NAME_TEXT, LEVEL_TEXT, SCORE_TEXT, KILL_TEXT, DEATH_TEXT, ASSIST_TEXT]
	return [NAME_TEXT, SCORE_TEXT, KILL_TEXT, DEATH_TEXT, ASSIST_TEXT, ""]


static func has_brief(battle, members: Dictionary, account: int) -> bool:
	for brief: Variant in battle.roster:
		if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) == account:
			return true
	return members.has(account)


static func rows(battle, members: Dictionary, accounts: Array, level_map: bool) -> Array:
	return strings(entries(battle, members, accounts, level_map))

static func strings(built: Array) -> Array:
	return built.map( func(values: Array) -> Array: return values.slice(0, 6).map( func(value: Variant) -> String: return str(value)))


static func entries(battle, members: Dictionary, accounts: Array, level_map: bool) -> Array:
	var built: Array = []
	for account: int in accounts:
		var tank: Dictionary = battle._tank_of_account(account)
		var stat: Array = battle.score_stats.get(account, [])
		if tank.is_empty() or stat.size() < 5 or not has_brief(battle, members, account):
			continue
		var score: int = int(float(stat[2]) / 1000.0)
		var values: Array = [str(tank.get("name", "")), score, int(stat[1]), int(stat[0]), int(stat[3]), ""]
		if level_map:
			values = [str(tank.get("name", "")), int(stat[4]), score, int(stat[1]), int(stat[0]), int(stat[3])]
		values.append(account)
		built.append(values)
	sort_rows(built)
	return built


static func sort_rows(built: Array) -> void :
	built.sort_custom( func(a: Array, b: Array) -> bool:
		for i in [1, 2, 3]:
			if int(a[i]) != int(b[i]):
				return int(a[i]) > int(b[i])
		return int(a[4]) < int(b[4]))

static func level_map(battle, owner_pack) -> bool:
	return owner_pack != null and int(owner_pack.hud.get("levels", {}).get(str(battle.map_id), 0)) != 0

func _refresh(battle) -> void :
	if battle != _battle:
		_battle = battle
		_built = [-1, -1]
	var members: Dictionary = client.room_state.members if client.get("room_state") != null else {}
	var levels: bool = level_map(battle, pack)
	for side: int in [0, 1]:
		if _built[side] != int(battle.score_revs[side]):
			_built[side] = int(battle.score_revs[side])
			_lines[side] = entries(battle, members, battle.score_a if side == 0 else battle.score_b, levels)
			_rows[side] = strings(_lines[side])

func _paint() -> void :
	var battle = client.get("battle")
	if battle == null:
		return
	_refresh(battle)
	if touch_mode():
		_paint_touch(battle)
		return
	var o: Vector2 = _centre(WIDE, HIGH)

	_round(Rect2(o * _f, Vector2(WIDE, HIGH) * _f), Color(0, 0, 0, 0.7), 30.0, Color(0, 0, 0, 0.7), 2.0)
	var happy: bool = int(battle.room_type) == ROOM_HAPPY
	var names: Array = heads(level_map(battle, pack))
	if not happy:
		var top: Array = titles(view_camp(battle))
		_label(str(top[0][0]), 20.0, top[0][1], o, 0.0, 14.0, 2.0, Color.BLACK)
		_label(str(top[1][0]), 20.0, top[1][1], o, 0.0, 199.0, 2.0, Color.BLACK)
	for i in range(6):
		var fit: float = head_fit(i)
		_label(str(names[i]), 14.0, HEAD, o, HEAD_CENTRE[i], 44.0, 1.5, LABEL_GLOW, fit)
		if not happy:
			_label(str(names[i]), 14.0, HEAD, o, HEAD_CENTRE[i], 230.0, 1.5, LABEL_GLOW, fit)
	_grid(_rows[0], o + Vector2(GRID_X, 70.0), 12 if happy else 6)
	if not happy:
		_grid(_rows[1], o + Vector2(GRID_X, 254.0), 6)
	var room: int = int(client.room_state.room.get("m_nRoomId", 0)) if client.get("room_state") != null else 0
	_label(ROOM_TEXT % room, 14.0, Color.WHITE, o, 0.0, 384.0, 1.5, LABEL_GLOW)
	preload("chat_mute.gd").paint_pc(self, battle, o)



static func head_fit(i: int) -> float:
	var gap: float = INF
	if i > 0:
		gap = minf(gap, HEAD_CENTRE[i] - HEAD_CENTRE[i - 1])
	if i < HEAD_CENTRE.size() - 1:
		gap = minf(gap, HEAD_CENTRE[i + 1] - HEAD_CENTRE[i])
	return gap - 4.0


func _label(text: String, px: float, color: Color, o: Vector2, centre: float, top: float, edge: float, rim: Color, fit: float = 400.0) -> void :
	if text.is_empty():
		return
	_fwords(text, ARIAL_BOLD, px, color, "c", Vector2(o.x + WIDE / 2.0 + centre - fit / 2.0, o.y + top), fit, edge, 0.0, fit < 400.0, rim)



func _grid(lines: Array, at: Vector2, count: int) -> void :
	for r in range(mini(lines.size(), count)):
		var x: float = at.x
		for c in range(6):
			var text: String = _cut(str(lines[r][c]), 12.0, COLUMN_WIDE[c] - TEXT_GUTTER)
			if not text.is_empty():
				_fwords(text, ARIAL, 12.0, preload("chat_mute.gd").grid_ink(self, lines, r, c, COLUMN_COLORS[c]), "c", Vector2(x, at.y + ROW_HIGH * r), COLUMN_WIDE[c], 1.0, ROW_HIGH, false, GRID_GLOW)
			x += COLUMN_WIDE[c]


func _cut(text: String, px: float, wide: float) -> String:
	var font: Font = _face(ARIAL)
	var font_size: int = maxi(6, roundi(px * _f))
	var room: float = wide * _f
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x <= room:
		return text
	var cut: String = text
	while cut.length() > 1 and font.get_string_size(cut + "...", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > room:
		cut = cut.left(cut.length() - 1)
	return cut + "..."



var _k: float = 1.0
var _tb: StyleBoxFlat = StyleBoxFlat.new()
static var _face_on: int = -1
const BattleLoading = preload("battle_loading.gd")
const T_GS_R: float = 13.0
const T_GS_X: float = 72.0
const T_TIP_MS: int = 2200
var _pve: bool = false
var _tip: Array = []



static func guild_skill_of(battle, gda: Dictionary, account: int, pve: bool) -> int:
	if account == int(battle.self_id):
		for slot: int in [4, 13]:
			var real: Variant = battle.skills.get(slot)
			if real is Dictionary and int(real.get("nPropsId", 0)) > 0:
				return int(real.nPropsId)
	var other: Variant = brief_of(battle, account).get("otherData")
	if not other is Dictionary:
		return 0
	return BattleLoading.guild_skill(gda.get("guild", {}), int(other.get("commandSkill", 0)), pve)


func touch_mode() -> bool:
	var host: Node = get_parent()
	return host != null and bool(host.get("_touch"))

static func brief_of(battle, account: int) -> Dictionary:
	for brief: Variant in battle.roster:
		if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) == account:
			return brief
	return {}


static func totals(lines: Array, level_map: bool) -> Array:
	var shift: int = 1 if level_map else 0
	var kill: int = 0
	var score: int = 0
	for line: Array in lines:
		score += int(line[1 + shift])
		kill += int(line[2 + shift])
	return [kill, score]



func tap(at: Vector2) -> bool:
	if not visible or not touch_mode():
		return false
	var battle = client.get("battle") if client != null else null
	if battle == null:
		return false
	if preload("chat_mute.gd").tap_touch(self, battle, at):
		return true
	for spot: Array in touch_rects.get("guild", []):
		if (spot[1] as Vector2).distance_to(at) <= float(spot[2]):
			var info: Array = pack.gda_loading.get("skill", {}).get(str(int(spot[3])), []) if pack != null else []
			_tip = [str(info[0]), spot[1], Time.get_ticks_msec() + T_TIP_MS] if not info.is_empty() else []
			return true
	for spot: Array in touch_rects.get("mute", []):
		if (spot[1] as Vector2).distance_to(at) > float(spot[2]):
			continue
		var account: int = int(spot[0])
		var on: bool = not battle.chat_muted.has(account)
		if on:
			battle.chat_muted[account] = true
			battle.bubbles.erase(account)
		else:
			battle.chat_muted.erase(account)
		preload("chat_mute.gd").refresh(self)
		if bool(spot[3]) and VoiceClient.usable():
			var voice: Object = VoiceClient.shared()
			if voice.is_muted(account) != on:
				voice.toggle_mute(account)
		return true
	return false

func _paint_touch(battle) -> void :
	touch_rects = {"rows": [], "mute": [], "guild": []}
	if pack != null and pack.gda_loading.is_empty():
		pack.load_gda_loading()
	_pve = int(BattleLoading.Text.map_info(battle.map_id).get("type", 0)) in BattleLoading.PVE_TYPES
	var edge: Vector4 = SafeArea.inset(size)
	var room_box: Rect2 = Rect2(Vector2(edge.x, edge.y), size - Vector2(edge.x + edge.z, edge.y + edge.w))
	var happy: bool = int(battle.room_type) == ROOM_HAPPY
	var count: int = clampi(maxi(_lines[0].size(), _lines[1].size()), 1, 6)
	var high: float = T_ROWS_Y + T_ROW * count + T_FOOT
	_k = clampf(minf((room_box.size.x - 32.0) / T_W, (room_box.size.y - 16.0) / (T_ROWS_Y + T_ROW * 6.0 + T_FOOT)), 0.45, 1.6)
	var k: float = _k
	var panel_size: Vector2 = (Vector2(T_W, high) * k).round()
	var panel: Rect2 = Rect2((room_box.position + (room_box.size - panel_size) / 2.0).round(), panel_size)
	touch_rects["panel"] = panel
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.32))
	_tbox(panel, T_GLASS, 16.0 * k, Color(1, 1, 1, 0.12), 1.0)
	var levels: bool = level_map(battle, pack)
	var camp: int = view_camp(battle)
	var ours: int = 1 if camp == CAMP_B else 0
	var half: float = (T_W - 2.0 * T_PAD - T_GAP) / 2.0 * k
	var xs: Array[float] = [panel.position.x + T_PAD * k, panel.position.x + T_PAD * k + half + T_GAP * k]
	var band_y: float = panel.position.y + T_PAD * k
	var sides: Array = []
	if happy:
		var all: Array = _lines[0].slice(0, 12)
		sides = [[all.slice(0, 6), true, 0], [all.slice(6, 12), true, 0]]
	else:
		sides = [[_lines[ours], true, ours], [_lines[1 - ours], false, 1 - ours]]
	var top: Array = titles(camp)
	for i in range(2):
		var x0: float = xs[i]
		var blue: bool = sides[i][1]
		touch_rects["left" if i == 0 else "right"] = Rect2(x0, band_y, half, panel.end.y - band_y)
		if not happy:
			var sum: Array = totals(sides[i][0], levels)
			var band: Rect2 = Rect2(x0, band_y, half, T_BAND * k)
			_tbox(band, Color(T_BLUE if blue else T_RED, 0.55), 10.0 * k, Color(T_BLUE_RING if blue else T_RED_RING, 0.55), 1.0)
			draw_rect(Rect2(band.position + Vector2(10.0 * k, 0), Vector2(band.size.x - 20.0 * k, maxf(1.0, 2.0 * k))), Color(1, 1, 1, 0.35))
			var outer: String = "l" if i == 0 else "r"
			var inner: String = "r" if i == 0 else "l"
			var ox: float = x0 + 16.0 * k if i == 0 else x0 + half - 16.0 * k
			var ix: float = x0 + half - 16.0 * k if i == 0 else x0 + 16.0 * k
			var title_w: float = half - 120.0 * k
			_tword(str(top[sides[i][2]][0]), BOLD, 17.0, Color.WHITE, outer, Vector2(ox, band_y + 20.0 * k), title_w, 1.5)
			_tword("%s: %d" % [SCORE_TEXT, sum[1]], SEMI, 12.0, Color(1, 1, 1, 0.78), outer, Vector2(ox, band_y + 40.0 * k), title_w)
			_tword(str(sum[0]), BOLD, 36.0, Color.WHITE, inner, Vector2(ix, band_y + T_BAND * k / 2.0 + 1.0 * k), 100.0 * k, 2.0)
		var head_y: float = panel.position.y + T_HEAD_Y * k
		var kda_x: float = x0 + half - T_KDA_END * k
		_tword(NAME_TEXT, SEMI, 10.5, T_DIM, "l", Vector2(x0 + 94.0 * k, head_y), 120.0 * k)
		_tword(T_KDA_HEAD, SEMI, 10.5, T_DIM, "c", Vector2(kda_x, head_y), 170.0 * k)
		_tword(SCORE_TEXT, SEMI, 10.5, T_DIM, "r", Vector2(x0 + half - T_SCORE_END * k, head_y), 60.0 * k)
		var lines: Array = sides[i][0]
		var mates: bool = not happy and sides[i][2] == ours and camp != 0 and int(battle.enter_type) != ENTER_LOOK
		for r in range(mini(lines.size(), 6)):
			_touch_row(battle, lines[r], Rect2(x0, panel.position.y + (T_ROWS_Y + T_ROW * r) * k, half, T_ROW * k), r, blue, levels, kda_x, mates)
	if not happy:
		_tword("VS", BOLD, 18.0, Color(1, 1, 1, 0.85), "c", Vector2(panel.get_center().x, band_y + T_BAND * k / 2.0), T_GAP * k, 1.5)
	var room: int = int(client.room_state.room.get("m_nRoomId", 0)) if client.get("room_state") != null else 0
	_tword(ROOM_TEXT % room, REGULAR, 11.0, T_DIM, "c", Vector2(panel.get_center().x, preload("chat_mute.gd").foot_y(panel, k)), 300.0 * k)
	preload("chat_mute.gd").paint_touch(self, battle)
	_guild_tip()


func _touch_row(battle, line: Array, row: Rect2, index: int, blue: bool, levels: bool, kda_x: float, mates: bool) -> void :
	var k: float = _k
	var shift: int = 1 if levels else 0
	var account: int = int(line[6])
	var mine: bool = account == int(battle.self_id)
	var strip: Rect2 = row.grow_individual(0, -2.0 * k, 0, -2.0 * k)
	touch_rects["rows"].append([account, strip])
	if mine:
		_tbox(strip, Color(T_SELF, 0.14), 9.0 * k, Color(T_SELF, 0.9), 1.5 * k)
	elif index % 2 == 0:
		_tbox(strip, Color(1, 1, 1, 0.045), 9.0 * k)
	var mid: float = row.get_center().y
	var c: Vector2 = Vector2(row.position.x + 34.0 * k, mid)
	var r: float = T_AV_R * k
	draw_circle(c, r + 2.5 * k, Color(0, 0, 0, 0.6))
	_touch_face(battle, account, c, r)
	draw_arc(c, r + 1.2 * k, 0.0, TAU, 48, T_SELF if mine else (T_BLUE_RING if blue else T_RED_RING), 2.4 * k, true)
	if VoiceClient.usable() and VoiceClient.shared().is_talking(account):
		VoiceUI.chip(self, c + Vector2(15.0, 15.0) * k, 8.0 * k, "wave", VoiceUI.WAVE_FILL, k)
	var gs_at: Vector2 = Vector2(row.position.x + T_GS_X * k, mid)
	var skill: int = guild_skill_of(battle, pack.gda_loading if pack != null else {}, account, _pve)
	_guild_icon(gs_at, T_GS_R * k, skill)
	if skill > 0:
		touch_rects["guild"].append([account, gs_at, (T_GS_R + 5.0) * k, skill])
	var name_x: float = row.position.x + 94.0 * k
	var name_w: float = kda_x - 84.0 * k - name_x
	_tword(_tfit(str(line[0]), BOLD, 15.0, name_w), BOLD, 15.0, T_SELF if mine else Color.WHITE, "l", Vector2(name_x, mid - 9.0 * k), name_w, 1.0)
	var other: Variant = brief_of(battle, account).get("otherData")
	var sub: String = ""
	if other is Dictionary and pack != null:
		sub = GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(int(other.get("tankId", 0))), "")))
	if levels:
		sub = ("%s · LV %d" % [sub, int(line[1])]) if not sub.is_empty() else "LV %d" % int(line[1])
	_tword(_tfit(sub, REGULAR, 11.0, name_w), REGULAR, 11.0, T_GREY, "l", Vector2(name_x, mid + 11.0 * k), name_w)
	var parts: Array = [str(line[2 + shift]), " / ", str(line[3 + shift]), " / ", str(line[4 + shift])]
	var inks: Array = [Color.WHITE, T_DIM, Color.WHITE, T_DIM, Color.WHITE]
	var fs: int = maxi(6, roundi(17.0 * k))
	var wide: float = 0.0
	for p: String in parts:
		wide += BOLD.get_string_size(p, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	var x: float = kda_x - wide / 2.0
	for j in range(parts.size()):
		_tword(parts[j], BOLD, 17.0, inks[j], "l", Vector2(x, mid), 200.0 * k, 1.0 if j % 2 == 0 else 0.0)
		x += BOLD.get_string_size(parts[j], HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
	_tword(str(line[1 + shift]), BOLD, 19.0, T_SCORE, "r", Vector2(row.end.x - T_SCORE_END * k, mid), 70.0 * k, 1.0)
	if not mine:
		var at: Vector2 = Vector2(row.end.x - T_MUTE_X * k, mid)
		var off: bool = battle.chat_muted.has(account)
		_mute_icon(at, T_MUTE_R * k, off)
		touch_rects["mute"].append([account, at, (T_MUTE_R + 7.0) * k, mates])


func _guild_icon(c: Vector2, r: float, skill: int) -> void :
	var k: float = _k
	draw_circle(c, r + 1.5 * k, Color(0, 0, 0, 0.55))
	var row_hud: Array = pack.skill_hud(skill) if pack != null and skill > 0 else []
	var icon: Texture2D = pack.icon("s", str(row_hud[0])) if not row_hud.is_empty() else null
	if icon == null:
		draw_circle(c, r, Color(0.07, 0.09, 0.15, 0.7))
		draw_arc(c, r - 0.5 * k, 0.0, TAU, 36, Color(1, 1, 1, 0.12), 1.2 * k, true)
		return
	var points: PackedVector2Array = []
	var uvs: PackedVector2Array = []
	var inner: float = 0.86
	for i in range(40):
		var a: float = TAU * i / 40.0
		var d: Vector2 = Vector2(cos(a), sin(a))
		points.append(c + d * r)
		uvs.append(Vector2(0.5, 0.5) + d * 0.5 * inner)
	draw_colored_polygon(points, Color.WHITE, uvs, icon)
	draw_arc(c, r, 0.0, TAU, 40, Color("e8c66a", 0.9), 1.6 * k, true)


func _guild_tip() -> void :
	if _tip.is_empty() or Time.get_ticks_msec() > int(_tip[2]):
		_tip = []
		return
	var k: float = _k
	var text: String = str(_tip[0])
	var fs: int = maxi(6, roundi(13.0 * k))
	var wide: float = BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x + 20.0 * k
	var at: Vector2 = _tip[1]
	var box: Rect2 = Rect2(Vector2(clampf(at.x - wide / 2.0, 4.0, size.x - wide - 4.0), at.y - 46.0 * k), Vector2(wide, 26.0 * k))
	_tbox(box, Color(0.04, 0.06, 0.11, 0.94), 7.0 * k, Color("e8c66a", 0.8), 1.2 * k)
	_tword(text, BOLD, 13.0, Color("ffe9a8"), "c", box.get_center(), wide, 1.0)


func _mute_icon(c: Vector2, r: float, off: bool) -> void :
	var k: float = _k
	draw_circle(c, r, Color(0.07, 0.09, 0.15, 0.88))
	draw_arc(c, r - 0.6 * k, 0.0, TAU, 40, Color(1, 1, 1, 0.14 if off else 0.42), 1.4 * k, true)
	var ink: Color = Color(1, 1, 1, 0.42 if off else 0.95)
	var bubble: Rect2 = Rect2(c + Vector2(-10.5, -9.0) * k, Vector2(21.0, 15.0) * k)
	_tbox(bubble, ink, 5.0 * k)
	draw_colored_polygon(PackedVector2Array([c + Vector2(-6.5, 5.5) * k, c + Vector2(-1.0, 5.5) * k, c + Vector2(-8.0, 11.0) * k]), ink)
	var dark: Color = Color(0.07, 0.09, 0.15, 1.0)
	var s: Vector2 = c + Vector2(-1.5, -1.5) * k
	draw_rect(Rect2(s + Vector2(-5.0, -1.8) * k, Vector2(2.6, 3.6) * k), dark)
	draw_colored_polygon(PackedVector2Array([s + Vector2(-2.6, -1.8) * k, s + Vector2(1.2, -4.6) * k, s + Vector2(1.2, 4.6) * k, s + Vector2(-2.6, 1.8) * k]), dark)
	draw_arc(s + Vector2(1.6, 0) * k, 3.0 * k, -0.9, 0.9, 10, dark, 1.3 * k, true)
	draw_arc(s + Vector2(1.6, 0) * k, 5.6 * k, -0.85, 0.85, 12, dark, 1.3 * k, true)
	if off:
		var a: Vector2 = c + Vector2(-0.62, -0.62) * r * 0.78
		var b: Vector2 = c + Vector2(0.62, 0.62) * r * 0.78
		draw_line(a, b, Color(0, 0, 0, 0.7), 4.2 * k, true)
		draw_line(a, b, Color("ff5d5d"), 2.2 * k, true)


func _touch_face(battle, account: int, c: Vector2, r: float) -> void :
	var other: Variant = brief_of(battle, account).get("otherData")
	var host: Node = get_parent()
	var hud: Variant = host.get("_hud") if host != null else null
	if not other is Dictionary or hud == null:
		return
	if _face_on < 0:
		_face_on = 0
		if ResourceLoader.exists(TOUCH_HEADS):
			for method: Dictionary in (load(TOUCH_HEADS) as GDScript).get_script_method_list():
				if str(method.get("name", "")) == "face_on":
					_face_on = 1
	if _face_on == 1:
		(load(TOUCH_HEADS) as GDScript).call("face_on", self, hud, other, c, r, Color.WHITE, float(battle.clock))
		draw_set_transform(Vector2.ZERO)
		return
	var cell: Rect2 = MicroHeads.HEAD.get(int(other.get("tankId", 0)), Rect2())
	var sheet: Texture2D = hud.tex(MicroHeads.SHEET) if cell.size.x > 0 else null
	if sheet != null:
		var side: float = r * 1.45
		draw_texture_rect_region(sheet, Rect2(c - Vector2(side, side) / 2.0, Vector2(side, side)), cell)

func _tbox(rect: Rect2, fill: Color, radius: float, rim: Color = Color(0, 0, 0, 0), width: float = 0.0) -> void :
	_tb.bg_color = fill
	_tb.set_corner_radius_all(maxi(1, roundi(minf(radius, rect.size.y / 2.0))))
	_tb.border_color = rim
	_tb.set_border_width_all(maxi(1, roundi(width)) if width > 0.0 else 0)
	draw_style_box(_tb, rect)


func _tword(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, wide: float, rim: float = 0.0) -> void :
	if text.is_empty():
		return
	var fs: int = maxi(6, roundi(px * _k))
	while fs > 6 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > wide:
		fs -= 1
	var origin: Vector2 = at
	var mode: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
	if align == "c":
		origin.x -= wide / 2.0
		mode = HORIZONTAL_ALIGNMENT_CENTER
	elif align == "r":
		origin.x -= wide
		mode = HORIZONTAL_ALIGNMENT_RIGHT
	origin.y += (font.get_ascent(fs) - font.get_descent(fs)) / 2.0
	if rim > 0.0:
		draw_string_outline(font, origin, text, mode, wide, fs, maxi(1, roundi(rim * 2.0 * _k)), Color(0, 0, 0, 0.55 * color.a))
	draw_string(font, origin, text, mode, wide, fs, color)


func _tfit(text: String, font: Font, px: float, wide: float) -> String:
	var fs: int = maxi(6, roundi(px * _k))
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x <= wide:
		return text
	var cut: String = text
	while cut.length() > 1 and font.get_string_size(cut + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x > wide:
		cut = cut.left(cut.length() - 1)
	return cut + "…"
