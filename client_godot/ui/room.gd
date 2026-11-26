extends "hall_screen.gd"



const TankPreview = preload("tank_preview.gd")
const TankPortrait = preload("tank_portrait.gd")
const GarageModel = preload("garage_model.gd")
const Seats = preload("room_atlas.gd")
const GiftMovie = preload("gift_movie.gd")
var _gift_fx: Node2D
const Gifts = preload("room_gift_atlas.gd")
const BagModel = preload("bag_model.gd")
const Ornates = preload("room_seat_atlas.gd")
const BattleState = preload("res://battle/battle_state.gd")


const Clan = preload("guild_match_atlas.gd")
const GuildRule = preload("guild_rule_atlas.gd")
const RuleSheet = preload("guild_match_rule.gd")
const Guild = preload("guild_atlas.gd")
const PlayerInfo = preload("player_info.gd")
const HelperModel = preload("helper_model.gd")
const HelperTip = preload("helper_tip.gd")
const VoiceUI = preload("voice_ui.gd")
const VoiceClient = preload("voice_client.gd")
const Settings = preload("res://settings.gd")
const Shop = preload("shop_atlas.gd")
const Arena = preload("arena.gd")



signal player_info_asked(uuid: String)

signal quick_buy_asked(tid: int)



const HAND_TIP: String = "Cộng đồng"

const HOST_TIP: String = "Chuyển giao đội trưởng"

const HOST_CARD_ROOMS: Array = [1, 2, 9]
const GIFT_SELF: String = "Không thể tự tặng bản thân"
const GIFT_LIFE: float = 5.0
const GIFT_COLS: int = 3
const GIFT_ROWS: int = 3
const GIFT_LIST: Vector2 = Vector2(2, 13.5)
const GROCERY: int = 2


const CARD: Vector2 = Vector2(158, 159)
const HIRE: int = 1

const BUBBLE_AT: Vector2 = Vector2(5, 54)
const BUBBLE_LIFE: float = 5.0
const BUBBLE_TINT: Color = Color(1, 1, 1, 0.8)
const BUBBLE_INK: Color = Color("160000")
const BUBBLE_WRAP: float = 136.0
const PRIVATE: int = 1

const OB_AT: Vector2 = Vector2(387, 54)
const OB_NAME_AT: Vector2 = Vector2(67, 3)
const OB_WIDE: float = 249.0
const OB_RIM: Color = Color("2d85bd")


const MAPS: Array = [1, 4, 7, 9, 10, 12, 14, 17, 18, 19, 20, 21, 30, 34, 35, 36, 37, 40, 50, 70, 169, 170, 333, 334]
const RANDOM: String = "Bản đồ ngẫu nhiên"

const TIP_12: String = "Tất cả người chơi sẵn sàng mới bắt đầu được"
const TIP_97: String = "Ít nhất cần @num1@ người mới có thể vào game"
const TIP_118: String = "Đang sẵn sàng không thể đổi đội ngũ"
const TIP_61: String = "\"Sẵn sàng\" không thể đổi đội"
const TIP_59: String = "Vị trí bên xanh đã đủ"
const TIP_60: String = "Vị trí bên đỏ đã đủ"
const TIP_120: String = "Tại đây không thể chọn Map"

const NO_SERVER: String = "Máy chủ chưa hỗ trợ %s."

const STRIPS: Dictionary = {
	"all": ["gameroom_avatar_card_button_bk", [[58, "add"], [89, "info"], [120, "kick"]]], 
	"no_kick": ["gameroom_avatar_card_button_bk_s", [[89, "add"], [120, "info"]]], 
	"no_add": ["gameroom_avatar_card_button_bk_s", [[89, "info"], [120, "kick"]]], 
	"info": ["gameroom_avatar_card_button_bk_ss", [[120, "info"]]]}
const ICONS: Dictionary = {"add": "gameroom_avatar_card_ico_addfriend_s", "info": "gameroom_avatar_card_ico_info_s", "kick": "gameroom_avatar_card_ico_quit_s"}

const PICK_X: Array = [0, 231, 462, 693]
const STRIP_W: float = 727.0

const CLAN_MAX: int = 5
const CLAN_CARD: Vector2 = Vector2(158, 318)
const CLAN_X: Array = [20, 177, 334, 491, 648]
const CLAN_Y: float = 80.0
const CLAN_PAIR: Vector2 = Vector2(515, 412)
const CLAN_BUBBLE: Vector2 = Vector2(5, 107)
const CLAN_TANK: Vector2 = Vector2(79, 195)
const CLAN_ZOOM: float = 0.7
const CLAN_HELPER: Rect2 = Rect2(99, 121, 50, 50)
const RANK_RIM: Color = Color("086da5", 0.8)
const NO_NEXT_INK: Color = Color("ffe400")
const NO_NEXT_RIM: Color = Color("0b2c4f")

const TMMST_BATTLE: int = 3
const TMMST_PAIR_NONE: int = 6
const TMMST_PAIR_WAIT: int = 7
const TMMST_PAIR_IDLE: int = 8
const TMMST_PAIR_END: int = 9
const TMMST_PAIR_INIT: int = 10
const TMMST_MATCH_OUT: int = 11
const TIP_149: String = "Đã đủ người ra trận"
const TIP_475: String = "Hủy tham gia thi đấu trước rồi hủy xuất chiến"
const CANCEL_ASK: String = "Hủy ghi danh thật sao?"

const NO_NEXT: String = "Chưa lọt vào vòng trong, không thể báo danh"

const ROPT_LOOK_SCENE: int = 6

const ASK_CELLS: Array = ["gu_ask", "gu_ask_guy", "gu_ask_no", "gu_ask_ok"]




const VOICE_MIC: Vector2 = Vector2(646.5, 65.5)
const VOICE_SPK: Vector2 = Vector2(681.5, 65.5)
const VOICE_R: float = 12.5
const VOICE_HIT: float = 17.0
const VOICE_HIT_UP: float = 20.0
const VOICE_MENU: Vector2 = Vector2(505.5, 92)
const VOICE_OB_END: float = 624.0


const GD_FACE: float = 24.0
const GD_FACE_TOUCH: float = 26.0
const GD_GAP: float = 6.0
const GD_GAP_TOUCH: float = 8.0
const GD_MAX: int = 6
const GD_SEAT_AT: Vector2 = Vector2(489, 404)
const GD_HOST: Color = Color("f16422")
const GD_BTN_RIM: Color = Color("1d4f8c")
const GD_DIM: Color = Color(0.55, 0.55, 0.55, 0.75)
const GD_EMPTY: Color = Color(0, 0.04, 0.12, 0.16)
const GD_EMPTY_RIM: Color = Color("1a7fc0")
const GD_XBOLD: Font = preload("res://assets/fonts/BeVietnamPro-ExtraBold.ttf")
const GD_TO_WATCH: String = "GHẾ KHÁN GIẢ"
const GD_TO_FIGHT: String = "VỀ GHẾ ĐẤU"
const GD_CAMP: String = "ĐỔI TEAM"
const GD_CAMP_DIM: Color = Color(1, 1, 1, 0.8)
const GD_OFF_INK: Color = Color("cfcfcf")
const GD_OFF_RIM: Color = Color("4a4a4a")
const GD_NOTE_ROW: float = 22.0
var _gd_greys: Dictionary = {}
var gd_note_box: Rect2 = Rect2()
const GD_LANE_X0: float = 146.0
const GD_LANE_GAP: float = 8.0
var gd_lane: Rect2 = Rect2()
const GD_HOST_MARK: float = 13.0
var _gd_fv: FontVariation = null
const VOICE_CHIP: Vector2 = Vector2(16, 18)
const VOICE_CHIP_LOW: Vector2 = Vector2(16, 100)
const VOICE_CHIP_R: float = 10.0
const VOICE_HOLD: float = 0.3
const VOICE_ROWS: Array = [["all", "spk", "Tất cả", "Nghe cả đội khi vào trận"], ["room", "spk_room", "Room", "Chỉ người cùng room"], 
	["off", "spk_off", "Tắt", "Không nghe ai"]]
const VOICE_TAG: Dictionary = {"all": "T", "room": "R", "off": ""}

var _picking: bool = false
var _pick_first: int = 0
var _pick_id: int = 0
var _last_pick: int = -1
var _last_pick_at: float = -10.0
var _asked_at: float = -100.0
var _shown_at: float = 0.0
var _gift_to: int = 0
var _gift_at: Vector2 = Vector2.ZERO
var _gift_since: float = 0.0
var _gift_row: int = 0
var _note: Array = []
var _love_tones: Dictionary = {}
var _love_names: Dictionary = {}
var _love_card: Rect2 = Rect2()
var _love_built: bool = false
var _htip: Array = []
var _bubbles: Dictionary = {}
var _chat_seq: int = 0
var _clan_room: int = 0
var _clan_sheet: String = ""
var _voice: Object = null
var _voice_menu: String = ""
var _voice_menu_at: Vector2 = Vector2.ZERO
var _voice_hold_at: float = -1.0
var _voice_key: Array = [-1, ""]
var _pwd_open: bool = false
var _pwd_focus: bool = false
var _pwd: LineEdit

func chat_busy() -> bool:
	return _picking or _pwd_open or not _clan_sheet.is_empty() or not _voice_menu.is_empty() or super ()

func _setup() -> void :
	super ()
	_add_parts(Seats.PLACE)
	_gift_fx = GiftMovie.SeatFx.new()
	_gift_fx.view = self
	add_child(_gift_fx)
	move_child(_gift_fx, 0)
	_pwd = _fedit(0, true)
	Arena.flash_limit(_pwd, 6, Arena.PASS_DIGITS)
	_pwd.text_submitted.connect( func(_text: String) -> void : _pwd_click("pwd:ok"))

func _frames() -> Dictionary:
	return Seats.FRAME

func _channel_name() -> String:
	return "Room"

func _team_open() -> bool:
	return true

func _can_invite(who: Dictionary) -> bool:
	var name: String = str(who.get("szName", ""))
	return client.can_invite(name) and not _in_room(name)



func gift_seat(id: int, key: String) -> void :
	if client.pve_room():
		return
	var seat: String = ""
	if client.team_room():
		var slot: int = on_battle(client.room_state).find(id)
		seat = "c:%d" % slot if slot >= 0 and slot < CLAN_MAX else ""
	else:
		var camps: Array = _camps()
		for row in range(2):
			var slot: int = camps[row].find(id)
			if slot >= 0 and slot < Seats.SEAT_X.size():
				seat = "%d:%d" % [row, slot]
	if not seat.is_empty():
		_gift_fx.play(seat, key)



func gift_seat_xf(seat: String) -> Transform2D:
	var frame: Vector2 = _at("hall")
	var part: PackedStringArray = seat.split(":")
	if part[0] == "c":
		return Transform2D(0.0, Vector2(_f, _f), 0.0, (frame + Vector2(float(CLAN_X[int(part[1])]), CLAN_Y)) * _f)
	var at: Vector2 = frame + Vector2(float(Seats.SEAT_X[int(part[1])]) + CARD.x / 4.0, float(Seats.SEAT_Y[int(part[0])]))
	return Transform2D(0.0, Vector2(0.5 * _f, 0.5 * _f), 0.0, at * _f)

func _shown() -> void :
	_picking = false
	_pwd_close()
	_gift_to = 0

	_bubbles.clear()
	_chat_seq = int(client.chat_log[-1].get("seq", 0)) if client != null and not client.chat_log.is_empty() else _chat_seq
	_reset_list()
	_clan_sheet = ""
	_voice_menu = ""
	_voice_release()

	if not is_visible_in_tree() and (client == null or not client.team_room()):
		_clan_room = 0
	if is_visible_in_tree():
		pack.load_garage()
		pack.load_bagx()
		_shown_at = _time


func _tick(_delta: float) -> void :
	_tick_voice()
	_tick_clan()
	if _tab == "room" and not _pending and _time - _asked_at > 20.0:
		_pending = true
	if _pending:
		_asked_at = _time
	_tick_list()
	_tick_gift()
	_tick_bubbles()


func _tick_clan() -> void :
	if not client.team_room():
		_clan_room = 0
		_clan_sheet = ""
		return
	var room_id: int = int(client.room_state.room.get("m_nRoomId", 0))
	if room_id != _clan_room:
		_clan_room = room_id
		_clan_init()




func _clan_init() -> void :
	_tab = "guild"
	_reset_list()
	var list: Array = on_battle(client.room_state)
	if list.size() < CLAN_MAX:
		if int(client.team_match.get("state", 0)) != TMMST_BATTLE:
			client.team_seat(true)
	elif not list.has(client.room_state.self_id):
		say(TIP_149)


static func on_battle(state) -> Array:
	var out: Array = []
	var host: int = int(state.room.get("m_nCreateId", 0))
	for id: int in state.members:
		var member: Dictionary = state.members[id]
		if int(member.get("data", {}).get("bCamp", 1)) == 2 or not bool(member.get("ready", false)):
			continue
		if id == host:
			out.push_front(id)
		else:
			out.append(id)
	return out




static func pair_view(phase: int, on: bool, master: bool, ob: bool) -> Dictionary:
	var view: Dictionary = {"join": true, "cancel": on, "mates": false, "wait": false, "signed": false, "unsign": false, 
		"watch": false, "no_next": false, "exit": on and not ob, "go": not on and not ob}
	match phase:
		TMMST_PAIR_NONE:
			view.join = master
			view.cancel = false
			view.mates = true
			view.unsign = not master
		TMMST_PAIR_WAIT, TMMST_PAIR_IDLE:
			view.join = false
			view.cancel = master
			view.wait = true
			view.signed = not master
		TMMST_PAIR_INIT, TMMST_PAIR_END:
			view.join = false
			view.cancel = false
		TMMST_BATTLE:
			view.join = false
			view.watch = true
		TMMST_MATCH_OUT:
			view.join = false
			view.cancel = false
			view.no_next = true
	return view


static func clock_text(left: int) -> String:
	var seconds: int = maxi(0, left)
	return "%02d:%02d" % [seconds / 60, seconds % 60]




func _tick_bubbles() -> void :
	var lines: Array = client.chat_log
	var last: int = int(lines[-1].get("seq", 0)) if not lines.is_empty() else _chat_seq
	var members: Dictionary = client.room_state.members
	if last > _chat_seq:
		var first: int = lines.size()
		while first > 0 and int(lines[first - 1].get("seq", 0)) > _chat_seq:
			first -= 1
		for i in range(first, lines.size()):
			var line: Dictionary = lines[i]
			var oid: int = int(line.get("oid", 0))
			if oid != 0 and int(line.get("channel", 0)) != PRIVATE and members.has(oid):
				_bubbles[oid] = [BattleState.chat_text(str(line.get("raw", ""))), _time]
		_chat_seq = last
	for oid: int in _bubbles.keys():
		if _time - float(_bubbles[oid][1]) >= BUBBLE_LIFE or not members.has(oid):
			_bubbles.erase(oid)


func _tick_gift() -> void :
	if _gift_to == 0:
		return
	if client.state != "room" or not client.room_state.members.has(_gift_to):
		_gift_to = 0
	elif _gift_here():
		_gift_since = _time
	elif _time - _gift_since >= GIFT_LIFE:
		_gift_to = 0



func _gift_here(at: Vector2 = Vector2(-1, -1)) -> bool:
	if _hover.begins_with("gift:"):
		return true
	if not _mobile:
		return false
	if at.x >= 0.0:
		return _hit_at(at).begins_with("gift:")
	return _held and _hit_at(_held_at).begins_with("gift:")



func _drag(moved: Vector2, from: Vector2) -> void :
	if _mobile and _picking:
		super (Vector2(0.0, moved.x + moved.y), from)
		return
	super (moved, from)

func _swipe_pitch() -> float:
	return 232.0 * _f if _mobile and _picking else super ()

func _wheel(step: int, at: Vector2) -> void :
	if _gift_to != 0 and _gift_here(at):
		_gift_row = clampi(_gift_row + step, 0, maxi(0, ceili(gift_items().size() / float(GIFT_COLS)) - GIFT_ROWS))
	elif _picking:
		_turn_maps(step)
	elif _viewing.is_empty():
		_wheel_list(step, at)

func _map_id() -> int:
	return int(client.room_state.room.get("roomConfig", {}).get("m_nMapId", 0))


func _camps() -> Array:
	var camps: Array = [[], []]
	for id: int in client.room_state.members:
		var member: Dictionary = client.room_state.members[id]
		camps[1 if int(member.data.get("bCamp", 1)) == 2 else 0].append(id)
	return camps

func _my_camp() -> int:
	var me: Dictionary = client.room_state.members.get(client.room_state.self_id, {})
	return 1 if int(me.get("data", {}).get("bCamp", 1)) == 2 else 0

func _half() -> int:
	return maxi(1, int(client.room_state.room.get("m_nMax", 10)) / 2)


func _choices() -> Array:
	var out: Array = [0]
	var known: Dictionary = pack.index.get("maps", {})
	for id: int in MAPS:
		if known.has(str(id)):
			out.append(id)
	return out

func _in_room(name: String) -> bool:
	for member: Dictionary in client.room_state.members.values():
		if str(member.get("data", {}).get("charData", {}).get("szName", "")) == name:
			return true
	return false

func _map_name(id: int) -> String:
	return map_title(id) if id > 0 else RANDOM



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(Hall.FILE, Hall.R)
		_use(Seats.FILE, Seats.R)
		_use(Gifts.FILE, Gifts.R)
		_use(Ornates.FILE, Ornates.R)
		_use(Clan.FILE, Clan.R)
		_use(GuildRule.FILE, GuildRule.R)
		_use(Shop.FILE, {"shop_button_red": Shop.R["shop_button_red"]})
		var ask: Dictionary = {}
		for cell: String in ASK_CELLS:
			ask[cell] = Guild.R[cell]
		_use(Guild.FILE, ask)
	_note = []
	_htip = []
	_love_built = false
	_scene()
	var state = client.room_state
	if state.room.is_empty():
		return
	var frame: Vector2 = _at("hall")
	_frows(_parts.get("hall", []), frame)
	var team: bool = client.team_room()
	_draw_head(frame, not team)
	if team:
		_draw_clan_head(frame)
	_draw_observers(frame)
	if team:
		_draw_clan(frame)
	else:
		_draw_free(frame)
	_draw_voice_bar(frame)
	var side: Vector2 = _at("list")
	_frows(_parts.get("list", []), side)
	_draw_players(side)
	_draw_chat()
	_draw_menu()
	if _picking:
		_draw_picker()
	elif not _viewing.is_empty():
		_draw_viewing()
	if _gift_to != 0 and not _picking:
		_draw_gifts()
	if _clan_sheet == "rule":
		RuleSheet.draw(self)
	elif _clan_sheet == "ask":
		_draw_clan_ask()
	if _pwd_open and client.room_state.is_host() and not client.team_room():
		_draw_pwd()
	elif _pwd_open:
		_pwd_close()
	_draw_voice_menu()
	_draw_note()
	_draw_htip()


func _draw_free(frame: Vector2) -> void :
	var camps: Array = _camps()
	var mine: int = _my_camp()
	_love_seats(camps[0].slice(0, Seats.SEAT_X.size()) + camps[1].slice(0, Seats.SEAT_X.size()))


	for row in range(2):
		for slot in range(Seats.SEAT_X.size() - 1, -1, -1):
			var at: Vector2 = frame + Vector2(float(Seats.SEAT_X[slot]), float(Seats.SEAT_Y[row]))
			_draw_seat(at, row, slot, int(camps[row][slot]) if slot < camps[row].size() else 0, mine)
	var gd_watch: bool = client.room_watching()
	var gd_art: bool = client.tournament_room()
	if gd_watch:
		if gd_art:
			_gd_grey_button("public_button_2_blue", frame + Vector2(595, 404))
			_gd_art(GD_CAMP, 10.0, GD_OFF_INK, frame + Vector2(599, 404), 88.0, 28.0, 3.0, GD_OFF_RIM)
		else:
			_fblit("public_button_2_blue", frame + Vector2(595, 404), 0.0, 0.0, GD_DIM)
			_fmid("gameroom_b2_changeteam_t", frame + Vector2(595, 409), 96.0, GD_DIM)
	else:
		_hit("camp", _fblit("public_button_2_blue", frame + Vector2(595, 404), 0.0, 0.0, _glow("camp")), false)
		if gd_art:
			_gd_art(GD_CAMP, 10.0, _glow("camp"), frame + Vector2(599, 404), 88.0, 28.0, 3.0, GD_BTN_RIM)
		else:
			_fmid("gameroom_b2_changeteam_t", frame + Vector2(595, 409), 96.0, _glow("camp"))
	if client.tournament_room():
		_gd_draw_seat_button(frame, gd_watch)
	_draw_start()


func _draw_head(frame: Vector2, lock: bool = true) -> void :
	var state = client.room_state
	_fwords(_map_name(_map_id()), BOLD, 14.0, Color.WHITE, "c", frame + Vector2(425, 22), 168.0, 1.5)
	_fwords(str(int(state.room.get("m_nRoomId", 0))), BOLD, 12.0, Color.WHITE, "c", frame + Vector2(92, 53), 44.0, 1.0, 24.0)
	if lock and state.is_host():
		_hit("password", _fblit("public_button_2_s_blue", frame + Vector2(704, 53), 0.0, 0.0, _glow("password")), false)
		_fmid("gameroom_button_title_roompassword_t", frame + Vector2(704, 57), 86.0, _glow("password"))



func _draw_observers(frame: Vector2) -> void :
	if client.tournament_room():
		_gd_draw_watchers(frame)
		return
	if client.room_observers.is_empty():
		return
	var names: PackedStringArray = PackedStringArray()
	for id: int in client.room_observers:
		names.append(str(client.room_observers[id].get("charData", {}).get("szName", "")))
	var at: Vector2 = frame + OB_AT
	_fblit("gda_rs_observer_t", at + Vector2(0, 3))
	_fwords(_ob_fit("  ".join(names), VOICE_OB_END - OB_AT.x - OB_NAME_AT.x if _voice_shown() else OB_WIDE), BOLD, 12.0, Color.WHITE, "l", at + OB_NAME_AT, OB_WIDE + 40.0, 1.0, 0.0, false, OB_RIM)



func _gd_draw_watchers(frame: Vector2) -> void :
	var at: Vector2 = frame + OB_AT
	var label: Rect2 = _fblit("gda_rs_observer_t", at + Vector2(0, 3))
	gd_lane = Rect2(Vector2(frame.x + GD_LANE_X0, at.y + 12.0 - GD_NOTE_ROW / 2.0), Vector2(maxf(40.0, label.position.x / _f - GD_LANE_GAP - frame.x - GD_LANE_X0), GD_NOTE_ROW))
	var ids: Array = client.room_observers.keys()
	var cap: int = int(client.room_state.room.get("m_nObNum", 0))
	cap = clampi(maxi(cap if cap > 0 else GD_MAX, ids.size()), 1, GD_MAX)
	_hit("gdob:label", label, false)
	_note_on("gdob:label", label, "Khán giả %d/%d" % [ids.size(), cap], "", Color.WHITE)
	_gd_note_below("gdob:label")
	var face: float = GD_FACE_TOUCH if _mobile else GD_FACE
	var gap: float = GD_GAP_TOUCH if _mobile else GD_GAP

	var room_w: float = (VOICE_MIC.x - VOICE_R - 4.0 if _voice_shown() else OB_AT.x + OB_NAME_AT.x + OB_WIDE - 8.0) - OB_AT.x - OB_NAME_AT.x
	var fit: int = clampi(floori((room_w + gap) / (face + gap)), 1, cap)
	if fit < cap and (face != GD_FACE or gap != GD_GAP):
		face = GD_FACE
		gap = GD_GAP
		fit = clampi(floori((room_w + gap) / (face + gap)), 1, cap)
	var shown: int = ids.size() if ids.size() <= fit else fit - 1
	var top: float = at.y + 12.0 - face / 2.0
	var host: int = int(client.room_state.room.get("m_nCreateId", 0))
	for i in range(fit):
		var spot: Vector2 = Vector2(at.x + OB_NAME_AT.x + i * (face + gap), top)
		var rect: Rect2 = Rect2(spot * _f, Vector2(face, face) * _f)
		if i >= ids.size():
			draw_rect(rect, GD_EMPTY)
			draw_rect(rect.grow(-1.0 * _f), GD_EMPTY_RIM, false, 2.0 * _f)
			continue
		if i >= shown:
			draw_rect(rect, Color("0b2c4f"))
			draw_rect(rect, Color.WHITE if _hover == "gdob:more" else OB_RIM, false, 1.0 * _f)
			_fwords("+%d" % (ids.size() - shown), BOLD, 12.0, Color.WHITE, "c", spot, face, 1.0, face, true, OB_RIM)
			_hit("gdob:more", rect, false)
			_note_on("gdob:more", rect, "Khán giả khác", "\n".join(_gd_names(shown)), Color.WHITE)
			_gd_note_below("gdob:more")
			continue
		var id: int = int(ids[i])
		var who: Dictionary = client.room_observers[id].get("charData", {})
		var hit: String = "gdob:%d" % id
		var lead: bool = id == host
		draw_rect(rect, Color("0b2c4f"))
		var head: Texture2D = _head(who)
		if head != null:
			draw_texture_rect(head, rect.grow(-1.0 * _f), false)
		else:
			_fwords(str(who.get("szName", "?")).left(1).to_upper(), BOLD, 12.0, Color.WHITE, "c", spot, face, 1.0, face, false, OB_RIM)
		draw_rect(rect, GD_HOST if lead else (Color.WHITE if _hover == hit else OB_RIM), false, (2.0 if lead else 1.0) * _f)
		if lead:
			_fblit("gameroom_button_host", spot + Vector2(face - GD_HOST_MARK + 4.0, -4.0), GD_HOST_MARK, GD_HOST_MARK)
		_hit(hit, rect, false)
		_note_on(hit, rect, str(who.get("szName", "")), "Chủ room" if lead else "", Color.WHITE)
		_gd_note_below(hit)



func _gd_note_below(id: String) -> void :
	if _hover == id and _note.size() == 4:

		var gd_room: float = maxf(20.0, gd_lane.size.x - 20.0)
		var gd_body: String = str(_note[2])
		if id == "gdob:more" and not gd_body.is_empty():
			_note[1] = _gd_fit_names(gd_body.split("\n", false), gd_room)
		elif not gd_body.is_empty():
			_note[1] = _gd_cut(str(_note[1]) + " · " + gd_body.replace("\n", ", "), gd_room)
		else:
			_note[1] = _gd_cut(str(_note[1]), gd_room)
		_note[2] = ""
		_note.append(true)


func _gd_px(text: String) -> float:
	return _face(BOLD).get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(12.0 * _f))).x / _f


func _gd_cut(text: String, room: float) -> String:
	if _gd_px(text) <= room:
		return text
	while text.length() > 1 and _gd_px(text + "…") > room:
		text = text.left(-1)
	return text.strip_edges() + "…"


func _gd_fit_names(names: PackedStringArray, room: float) -> String:
	for k in range(names.size(), 0, -1):
		var line: String = ", ".join(names.slice(0, k)) + (" +%d" % (names.size() - k) if k < names.size() else "")
		if _gd_px(line) <= room:
			return line
	var tail: String = " +%d" % (names.size() - 1) if names.size() > 1 else ""
	return _gd_cut(names[0] if not names.is_empty() else "", room - _gd_px(tail)) + tail


func _gd_grey_button(name: String, at: Vector2) -> Rect2:
	var cell: Array = _cells.get(name, [])
	if cell.is_empty() or cell[0] == null:
		return _fblit(name, at, 0.0, 0.0, GD_DIM)
	var region: Array = cell[1]
	var rect: Rect2 = Rect2(at * _f, Vector2(float(region[2]), float(region[3])) * _f)
	var grey: Texture2D = _gd_greys.get(name, null)
	if grey == null:
		var src: Texture2D = cell[0]
		var full: Image = src.get_image()
		if full == null or full.is_empty():
			return _fblit(name, at, 0.0, 0.0, GD_DIM)
		var img: Image = full.duplicate()
		if img.is_compressed():
			img.decompress()
		img = img.get_region(Rect2i(int(region[0]), int(region[1]), int(region[2]), int(region[3])))
		img.convert(Image.FORMAT_RGBA8)
		for y in range(img.get_height()):
			for x in range(img.get_width()):
				var c: Color = img.get_pixel(x, y)
				var l: float = c.r * 0.3086 + c.g * 0.6094 + c.b * 0.082
				img.set_pixel(x, y, Color(l, l, l, c.a))
		grey = ImageTexture.create_from_image(img)
		_gd_greys[name] = grey
	draw_texture_rect(grey, rect, false)
	return rect



func _gd_art(text: String, px: float, color: Color, at: Vector2, wide: float, high: float, edge: float, rim: Color) -> void :
	if _gd_fv == null:
		_gd_fv = FontVariation.new()
		_gd_fv.base_font = GD_XBOLD
		_gd_fv.variation_embolden = 1.1
		_gd_fv.spacing_glyph = 1
	var font: Font = _gd_fv
	var size_px: int = maxi(6, roundi(px * _f))
	while size_px > 6 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > wide * _f:
		size_px -= 1
	var origin: Vector2 = Vector2(at.x, at.y + high / 2.0) * _f
	origin.y += (font.get_ascent(size_px) - font.get_descent(size_px)) / 2.0
	draw_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, size_px, maxi(2, roundi(edge * _f)), Color(rim, rim.a * color.a))
	draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_CENTER, wide * _f, size_px, color)


func _gd_names(first: int) -> PackedStringArray:
	var names: PackedStringArray = PackedStringArray()
	var ids: Array = client.room_observers.keys()
	for i in range(first, ids.size()):
		names.append(str(client.room_observers[ids[i]].get("charData", {}).get("szName", "")))
	return names


func _gd_draw_seat_button(frame: Vector2, watching: bool) -> void :
	var at: Vector2 = frame + GD_SEAT_AT
	_hit("gdseat", _fblit("public_button_2_blue", at, 0.0, 0.0, _glow("gdseat")), false)
	_gd_art(GD_TO_FIGHT if watching else GD_TO_WATCH, 10.0, _glow("gdseat"), at + Vector2(4, 0), 88.0, 28.0, 3.0, GD_BTN_RIM)


func _gd_click(key: String) -> void :
	if key == "more":
		say("Khán giả: " + ", ".join(_gd_names(0)))
		return
	var who: Dictionary = client.room_observers.get(int(key), {}).get("charData", {})
	if not who.is_empty():
		_open_view(who)


func view_items() -> Array:
	var items: Array = super ()
	if _gd_kickable(int(_viewing.get("nAcctId", 0))):
		items.insert(maxi(0, items.size() - 1), ["po:gdkick", "Mời ra khỏi room", true])
	return items

func _gd_kickable(id: int) -> bool:
	return client.tournament_room() and client.room_state.is_host() and id != client.room_state.self_id and client.room_observers.has(id)

func _view_action(key: String) -> void :
	if key == "gdkick":
		var id: int = int(_viewing.get("nAcctId", 0))
		_hide_view()
		if _gd_kickable(id) and not client.kick(id):
			say(NO_SERVER % "mời người chơi ra khỏi phòng")
		return
	super (key)


func _ob_fit(text: String, wide: float = OB_WIDE) -> String:
	var font: Font = _face(BOLD)
	var font_size: int = maxi(6, roundi(12.0 * _f))
	while not text.is_empty() and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x > wide * _f:
		text = text.left(-1)
	return text


func _draw_seat(at: Vector2, row: int, slot: int, id: int, mine: int) -> void :
	var state = client.room_state
	_fblit("gameroom_pvp5v5_playerbox_blueteam" if row == mine else "gameroom_pvp5v5_playerbox_redteam", at)
	if id == 0:
		if slot > _half() - 1:
			var closed: String = "closed:%d:%d" % [row, slot]
			_fmid("gameroom_avatar_card_close_t", at + Vector2(0, 26), 158.0, _glow(closed))
			_hit(closed, Rect2(at * _f, Vector2(158, 159) * _f), false)
		else:
			var wait: String = "wait:%d:%d" % [row, slot]
			var cell: Vector2 = _cell_size("gameroom_avatar_card_waitplayer_t")
			_fblit("gameroom_avatar_card_waitplayer_t", at + ((Vector2(158, 159) - cell) / 2.0).round(), 0.0, 0.0, _glow(wait))
			_hit(wait, Rect2(at * _f, Vector2(158, 159) * _f), false)
		return
	var member: Dictionary = state.members.get(id, {})
	var who: Dictionary = member.get("data", {}).get("charData", {})
	var me: bool = id == state.self_id
	if me:
		_fblit("gameroom_pvp5v5_playerbox_myself", at)
	_draw_ornate(at, int(who.get("nDecorateId", 0)))
	_draw_tank(at, id)
	_fblit("level_%d" % clampi(int(who.get("bLevel", 1)), 0, 40), at + Vector2(5, 65), 40.0, 20.0)
	_level_fx(int(who.get("bLevel", 1)), at + Vector2(5, 65), 40.0)
	if is_hired(member):
		_fblit("tank_ico_rent_t", at + Vector2(12, 12))
	_fmid("gameroom_avatar_card_name", at + Vector2(0, 39), 158.0)
	var vip: int = vip_of(who)
	var style: Array = name_style(vip)
	var love_on: bool = Love.has(client, int(who.get("nAcctId", 0)))
	var love_name: String = str(who.get("szName", ""))
	var love_x: float = 16.0
	var love_wide: float = 120.0
	var love_align: String = "c"
	if love_on:
		var love_limit: float = (142.0 - _cell_size("vip_%d" % vip).x if vip > 0 else 142.0) - Love.ROOM_GAP
		love_name = Love.clip(self, BOLD, love_name, 12.0, love_limit - 16.0 - 18.0)
		love_wide = Love.text_w(self, BOLD, love_name, 12.0) + 1.0
		love_x = clampf(76.0 - (love_wide + 17.0) / 2.0, 16.0, love_limit - love_wide - 17.0)
		love_align = "l"
	if NameStyles.paint(self, love_name, BOLD, 12.0, love_align, at + Vector2(love_x, 41), love_wide, 1.0, 0.0, true): style = [Color(0, 0, 0, 0), Color(0, 0, 0, 0)]
	var love_used: float = _fwords(love_name, BOLD, 12.0, style[0], love_align, at + Vector2(love_x, 41), love_wide, 1.0, 0.0, true, style[1])
	if love_on:
		_love_heart(at + Vector2(love_x + love_used + Love.NAME_GAP, 43), int(who.get("nAcctId", 0)), Rect2(at, Vector2(158, 159)))
	if vip > 0:
		var badge: String = "vip_%d" % vip
		_fblit(badge, at + Vector2(142.0 - _cell_size(badge).x, 44))
	var host_seat: bool = state.is_host() and not me
	var known: bool = me or _is_friend(str(who.get("szName", "")))
	var strip: Array = STRIPS["no_add" if known and host_seat else ("info" if known else ("all" if host_seat else "no_kick"))]
	_fblit(str(strip[0]), at + Vector2(57, 10))
	for button: Array in strip[1]:
		var hit: String = "%s:%d" % [button[1], id]
		_fbutton(hit, "gameroom_avatar_card_button_s", at + Vector2(float(button[0]), 12))
		_fblit(str(ICONS[button[1]]), at + Vector2(float(button[0]), 12), 0.0, 0.0, _glow(hit))
	if id == int(state.room.get("m_nCreateId", 0)):
		_fmid("roomteam_roommaster_t", at + Vector2(0, 119), 158.0)
	elif bool(member.get("ready", false)):
		_fmid("roomteam_ready_s_t", at + Vector2(0, 114), 158.0)
	if host_seat:
		var give: String = "host:%d" % id
		_note_on(give, _fbutton(give, "gameroom_button_host", at + Vector2(121, 67)), HOST_TIP, "", Color.WHITE)
	if not me:
		var hand: String = "hand:%d" % id
		_note_on(hand, _fbutton(hand, "gameroom_button_interact", at + Vector2(121, 97)), HAND_TIP, "", Color.WHITE)
	_draw_voice_seat(at, id, me, is_hired(member))
	_draw_bubble(at, id)
	if me and client.latency_ms >= 0:
		var ms: int = client.latency_ms
		var tint: Color = Color("00ff00") if ms <= 200 else (Color("ffff00") if ms <= 400 else Color("ff0000"))
		_fwords("%dms" % ms, BOLD, 10.0, tint, "r", at + Vector2(0, 137), 153.0, 1.0)








func _draw_ornate(card: Vector2, item: int, box: Vector2 = CARD) -> void :
	var cell: String = str(Ornates.ORNATE.get(item, "")) if item > 0 else ""
	if not cell.is_empty():
		_fblit(cell, card + ((box - _cell_size(cell)) / 2.0 + Vector2(0.5, 0.5)).floor())
		return
	var stem: String = dash_ornate(pack.bagx if pack != null else {}, item)
	if stem.is_empty():
		return
	var picture: Texture2D = pack.picture("l/or/%s.webp" % stem)
	if picture == null or picture.get_width() <= 4:
		return
	var frame: Vector2 = card + ((box - SMALL_FRAME) / 2.0 + Vector2(0.5, 0.5)).floor()
	_cover_round(picture, Rect2(frame + ((SMALL_FRAME - SMALL_FILL) / 2.0).floor(), SMALL_FILL), SMALL_RADIUS)


const SMALL_FRAME: Vector2 = Vector2(158, 159)
const SMALL_FILL: Vector2 = Vector2(152, 153)
const SMALL_RADIUS: float = 6.0



static func dash_ornate(bagx: Dictionary, item: int) -> String:
	if item <= 0:
		return ""
	var table: Variant = bagx.get("ornate")
	var stem: String = str((table as Dictionary).get(str(item), "")) if table is Dictionary else ""
	if stem.is_empty() or not (item >= 990000000 or stem.begins_with("decoration_")):
		return ""
	return stem



static func cover_source(size: Vector2, fill: Vector2) -> Rect2:
	if size.x <= 0.0 or size.y <= 0.0:
		return Rect2()
	var scale: float = maxf(fill.x / size.x, fill.y / size.y)
	var w: float = roundf(size.x * scale)
	var h: float = roundf(size.y * scale)
	var left: float = float(int((fill.x - w) / 2.0))
	var top: float = float(int((fill.y - h) / 2.0))
	return Rect2(Vector2( - left, - top) / scale, fill / scale)



func _cover_round(picture: Texture2D, spot: Rect2, radius: float) -> void :
	var src: Rect2 = cover_source(Vector2(picture.get_size()), spot.size)
	var sheet: Texture2D = picture
	var origin: Vector2 = Vector2.ZERO
	if picture is AtlasTexture and (picture as AtlasTexture).atlas != null:
		sheet = (picture as AtlasTexture).atlas
		origin = (picture as AtlasTexture).region.position
	var whole: Vector2 = Vector2(sheet.get_size())
	if whole.x <= 0.0 or whole.y <= 0.0:
		return
	var inner: Rect2 = Rect2(origin + Vector2(0.5, 0.5), Vector2(picture.get_size()) - Vector2(1, 1))
	var points: = PackedVector2Array()
	var uvs: = PackedVector2Array()
	for p: Vector2 in round_rect(spot.size, radius):
		points.append((spot.position + p) * _f)
		var at: Vector2 = origin + src.position + p / spot.size * src.size
		uvs.append(Vector2(clampf(at.x, inner.position.x, inner.end.x), clampf(at.y, inner.position.y, inner.end.y)) / whole)
	draw_colored_polygon(points, Color.WHITE, uvs, sheet)


static func round_rect(size: Vector2, radius: float) -> PackedVector2Array:
	var r: float = clampf(radius, 0.0, minf(size.x, size.y) / 2.0)
	var out: = PackedVector2Array()
	if r <= 0.0:
		return PackedVector2Array([Vector2.ZERO, Vector2(size.x, 0), size, Vector2(0, size.y)])
	var centres: Array = [Vector2(size.x - r, r), Vector2(size.x - r, size.y - r), Vector2(r, size.y - r), Vector2(r, r)]
	for k in range(4):
		for s in range(7):
			var angle: float = - PI / 2.0 + (float(k) + float(s) / 6.0) * PI / 2.0
			out.append(centres[k] + Vector2(cos(angle), sin(angle)) * r)
	return out




func _draw_bubble(card: Vector2, id: int, spot: Vector2 = BUBBLE_AT) -> void :
	var bubble: Array = _bubbles.get(id, [])
	if bubble.is_empty():
		return
	var at: Vector2 = card + spot
	var text: String = str(bubble[0])
	var size_px: int = maxi(6, roundi(14.0 * _f))
	var text_high: float = _face(BOLD).get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, BUBBLE_WRAP * _f, size_px).y / _f
	var mid: float = bubble_middle(text_high, _cell_size("gda_rs_talk_top").y, _cell_size("gda_rs_talk_bottom").y)
	_fblit("gda_rs_talk_top", at + Vector2(4, 1), 0.0, 0.0, BUBBLE_TINT)
	if mid > 0.0:
		_fblit("gda_rs_talk_middle", at + Vector2(4, 29), 0.0, mid, BUBBLE_TINT)
	_fblit("gda_rs_talk_bottom", at + Vector2(4, 29.0 + mid), 0.0, 0.0, BUBBLE_TINT)
	_fpara(text, BOLD, 14.0, BUBBLE_INK, at + Vector2(7, 18), BUBBLE_WRAP)


static func bubble_middle(text_high: float, top_high: float, bottom_high: float) -> float:
	return maxf(0.0, roundf(text_high - (top_high + bottom_high - 25.0)))


static func is_hired(member: Dictionary) -> bool:
	return int(member.get("data", {}).get("otherData", {}).get("tryTank", 0)) == HIRE


func _tank_level(id: int, look: Dictionary) -> int:
	var level: int = int(look.get("level", 0))
	if level > 0 or id != client.room_state.self_id:
		return level
	for inst: Dictionary in client.tanks.values():
		if int(inst.get("m_tpltId", 0)) == int(look.get("tank", 0)):
			level = maxi(level, int(inst.get("m_level", 1)))
	return level



func _draw_tank(card: Vector2, id: int, offset: Vector2 = Vector2(79, 101), ratio: float = 0.5) -> void :
	var look: Dictionary = client.room_state.appearances.get(id, {})
	var tank_id: int = int(look.get("tank", 0))
	if pack.state != "ready" or tank_id <= 0:
		return
	if pack.garage.is_empty() and _time - _shown_at < 4.0:
		return
	var level: int = _tank_level(id, look)
	var ext: int = int(look.get("external", 0))
	if ext <= 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, maxi(1, level), {})
	var centre: Vector2 = (card + offset) * _f
	var zoom: float = ratio * _f
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(look.get("halo", 0)), level)
	if TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, centre, zoom, _time):
		_draw_room_pet(id, centre, zoom)
		return
	var art: Dictionary = pack.external_art(pack.art_external(str(int(look.get("external", 0))), tank_id))
	if TankPreview.ready(art):
		TankPreview.draw(self, art, centre + Vector2(0, 7) * _f, zoom, 4, _time)
	_draw_room_pet(id, centre, zoom)



const ROOM_PET_AT: Vector2 = Vector2(62, -52)


const ROOM_PET_HIDDEN: int = 12

func room_pet_item(id: int) -> int:
	var room: Dictionary = client.room_state.room
	var kind: int = int(room.get("m_bType", 0))
	var other: Dictionary = client.room_state.members.get(id, {}).get("data", {}).get("otherData", {})
	var item: int = int(other.get("btItemId", 0))
	if item <= 0 or kind == ROOM_PET_HIDDEN or not HelperModel.famulus_game(kind, [int(room.get("roomConfig", {}).get("m_nMapId", 0))]):
		return 0
	return item




func room_pet_layers(id: int) -> Array:
	var item: int = room_pet_item(id)
	var pet: Array = pack.pet_of(item) if item > 0 and pack != null else []
	if pet.is_empty():
		return []
	var rank: int = int(client.room_state.members.get(id, {}).get("data", {}).get("otherData", {}).get("btRank", 0))
	var keys: Array = []
	for key: String in [pack.pet_star(rank), str(pet[0]), pack.pet_star_front(rank)]:
		if not key.is_empty():
			keys.append(key)
	return keys

func _draw_room_pet(id: int, centre: Vector2, zoom: float) -> void :
	if client.team_room() or is_equal_approx(zoom, CLAN_ZOOM * _f):
		return
	var keys: Array = room_pet_layers(id)
	if keys.is_empty():
		return
	var world: Transform2D = Transform2D(0.0, Vector2(zoom, zoom), 0.0, centre + ROOM_PET_AT * zoom)
	for key: String in keys:
		var asset: Dictionary = pack.effect(key)
		if asset.is_empty() or (asset.data.frames as Array).is_empty():
			continue
		TankPreview._frame(self, asset, int(_time * 24.0) % (asset.data.frames as Array).size(), world)
	draw_set_transform_matrix(Transform2D.IDENTITY)





func _draw_clan_head(frame: Vector2) -> void :
	var word: Vector2 = _cell_size("gameroom_word_clancurrentrank_t")
	_fblit("gameroom_word_clancurrentrank_t", frame + Vector2(156, roundf(63.0 - word.y / 2.0)))
	_fblit("public_label40x20", frame + Vector2(244, 53))
	_fwords(str(int(client.team_match.get("place", 0))), BOLD, 12.0, Color.WHITE, "c", frame + Vector2(246, 55), 40.0, 1.0, 0.0, true, RANK_RIM)
	_clan_button("clan:rank", "public_button_2_s_blue", "gameroom_word_allrank_t", frame + Vector2(292, 53))
	_clan_button("clan:rule", "public_button_2_s_blue", "gameroom_word_challengerule_t", frame + Vector2(704, 53))


func _clan_button(id: String, skin: String, word: String, at: Vector2) -> void :
	var lit: Color = _glow(id)
	_hit(id, _fblit(skin, at, 0.0, 0.0, lit), false)
	_fblit(word, at + ((_cell_size(skin) - _cell_size(word)) / 2.0).round(), 0.0, 0.0, lit)



func _draw_clan(frame: Vector2) -> void :
	var list: Array = on_battle(client.room_state)
	_love_seats(list.slice(0, CLAN_MAX))
	for slot in range(CLAN_MAX - 1, -1, -1):
		_draw_clan_card(frame + Vector2(float(CLAN_X[slot]), CLAN_Y), slot, int(list[slot]) if slot < list.size() else 0)
	_draw_pair(frame + CLAN_PAIR)


func _draw_clan_card(at: Vector2, slot: int, id: int) -> void :
	var state = client.room_state
	_fblit("gameroom_avatar_card", at)
	if id == 0:
		var wait: String = "cwait:%d" % slot
		var cell: Vector2 = _cell_size("gameroom_avatar_card_waitplayer_t")
		_fblit("gameroom_avatar_card_waitplayer_t", at + ((CLAN_CARD - cell) / 2.0).round(), 0.0, 0.0, _glow(wait))
		_hit(wait, Rect2(at * _f, CLAN_CARD * _f), false)
		return
	var member: Dictionary = state.members.get(id, {})
	var who: Dictionary = member.get("data", {}).get("charData", {})
	var me: bool = id == state.self_id
	if me:
		_fblit("gameroom_avatar_card_myself", at)
	_draw_ornate(at, int(who.get("nDecorateId", 0)), CLAN_CARD)

	var host_seat: bool = state.is_host() and not me
	var known: bool = me or _is_friend(str(who.get("szName", "")))
	var strip: Array = STRIPS["no_add" if known and host_seat else ("info" if known else ("all" if host_seat else "no_kick"))]
	_fblit(str(strip[0]), at + Vector2(58, 12))
	for button: Array in strip[1]:
		var hit: String = "%s:%d" % [button[1], id]
		_fbutton(hit, "gameroom_avatar_card_button_s", at + Vector2(float(button[0]) + 1.0, 14))
		_fblit(str(ICONS[button[1]]), at + Vector2(float(button[0]) + 1.0, 14), 0.0, 0.0, _glow(hit))
	if not me:
		var hand: String = "hand:%d" % id
		_note_on(hand, _fbutton(hand, "gameroom_button_interact", at + Vector2(121, 70)), HAND_TIP, "", Color.WHITE)

	if host_seat and int(state.room.get("m_bType", 0)) in HOST_CARD_ROOMS:
		var give: String = "host:%d" % id
		_note_on(give, _fbutton(give, "gameroom_button_host", at + Vector2(121, 42)), HOST_TIP, "", Color.WHITE)
	_fmid("gameroom_avatar_card_name", at + Vector2(0, 99), 158.0)
	var vip: int = vip_of(who)
	var style: Array = name_style(vip)
	var love_on: bool = Love.has(client, int(who.get("nAcctId", 0)))
	var love_name: String = str(who.get("szName", ""))
	var love_room: float = 120.0
	if love_on:
		var love_limit: float = (158.0 - 16.0 - _cell_size("vip_%d" % vip).x if vip > 0 else 142.0) - Love.ROOM_GAP
		love_name = Love.clip(self, BOLD, love_name, 12.0, love_limit - 16.0 - 18.0)
		love_room = Love.text_w(self, BOLD, love_name, 12.0) + 1.0
	if NameStyles.paint(self, love_name, BOLD, 12.0, "l", at + Vector2(16, 101), love_room, 1.0, 0.0, true): style = [Color(0, 0, 0, 0), Color(0, 0, 0, 0)]
	var love_used: float = _fwords(love_name, BOLD, 12.0, style[0], "l", at + Vector2(16, 101), love_room, 1.0, 0.0, true, style[1])
	if love_on:
		_love_heart(at + Vector2(16.0 + love_used + Love.NAME_GAP, 103), int(who.get("nAcctId", 0)), Rect2(at, CLAN_CARD))
	_fblit("level_%d" % clampi(int(who.get("bLevel", 1)), 0, 40), at + Vector2(73, 45), 48.0, 24.0)
	_level_fx(int(who.get("bLevel", 1)), at + Vector2(73, 45), 48.0)
	if vip > 0:
		var badge: String = "vip_%d" % vip
		_fblit(badge, at + Vector2(158.0 - 16.0 - _cell_size(badge).x, 104))
	var head: Texture2D = _head(who)
	var face: Rect2 = Rect2((at + Vector2(13, 39)) * _f, Vector2(60, 60) * _f)
	if head != null:
		draw_texture_rect(head, face, false)
	else:
		draw_rect(face, Color(0, 0, 0, 0.28))
	_draw_tank(at, id, CLAN_TANK, CLAN_ZOOM)
	_draw_clan_tank_name(at, id)
	_draw_clan_helper(at, id, member)
	if is_hired(member):
		_fblit("tank_ico_rent_t", at + Vector2(16, 216))
	_draw_bubble(at, id, CLAN_BUBBLE)
	if me and client.latency_ms >= 0:
		var ms: int = client.latency_ms
		var tint: Color = Color("00ff00") if ms <= 200 else (Color("ffff00") if ms <= 400 else Color("ff0000"))
		_fwords("%dms" % ms, BOLD, 10.0, tint, "r", at + Vector2(104, 299), 52.0, 1.0)
	if id == int(state.room.get("m_nCreateId", 0)):
		_fmid("roomteam_room_master_bg", at + Vector2(0, 283), 158.0)
		_fmid("roomteam_room_master_t", at + Vector2(0, 279), 158.0)
	else:
		_fmid("roomteam_room_menber_bg", at + Vector2(0, 282), 158.0)
		if bool(member.get("ready", false)):
			_fblit("roomteam_ready_t", at)
		else:
			_fmid("roomteam_room_member_t", at + Vector2(0, 277), 158.0)
	_draw_voice_seat(at, id, me, false, CLAN_CARD)




func _draw_clan_helper(at: Vector2, id: int, member: Dictionary) -> void :
	var other: Dictionary = member.get("data", {}).get("otherData", {})
	var item: int = int(other.get("btItemId", 0))
	var room: Dictionary = client.room_state.room
	if item <= 0 or pack == null or not HelperModel.famulus_game(int(room.get("m_bType", 0)), [int(room.get("roomConfig", {}).get("m_nMapId", 0))]):
		return
	pack.load_gda_loading()
	var more: Dictionary = pack.gda_loading.get("helper", {})
	var row: Array = more.get(str(item), [])
	if row.size() < 4 or str(row[1]).is_empty():
		return
	var spot: Rect2 = Rect2((at + CLAN_HELPER.position) * _f, CLAN_HELPER.size * _f)
	var icon: Texture2D = pack.picture("l/it/%s.webp" % str(row[1]))
	if icon != null:
		draw_texture_rect(icon, spot, false)
	var hit: String = "bthelper:%d" % id
	_hit(hit, spot, false)
	if _hover != hit or not _press.is_empty():
		return
	pack.load_helper()
	var inst: Dictionary = {"m_templateId": item, "m_level": int(other.get("btLevel", 0)), "m_rank": int(other.get("btRank", 0)), 
		"m_upLevel": int(other.get("btUpLevel", 0)), "m_upCost": int(other.get("btUpCost", 0)), "m_rankCost": int(other.get("btRankCost", 0))}
	var rec: Dictionary = HelperModel.record(inst, pack.helper, {"more": more}, "")
	if (rec.get("tpl", []) as Array).size() >= 17:
		_htip = [rec, more]
	else:
		_note_on(hit, spot, BagModel.clean(str(row[0])), "", BagModel.tint(int(row[2]), Color.WHITE))


func _draw_htip() -> void :
	if _htip.size() < 2:
		return
	var rec: Dictionary = _htip[0]
	var more: Dictionary = _htip[1]
	HelperTip.show(self, _f, Vector2(_fw, _fh), get_local_mouse_position() / _f, client, pack.helper, more, rec, 
		HelperTip.context(client, rec, more), true, pack.picture)


func _clan_name_width(title: String, px: float) -> float:
	return _face(BOLD).get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f



func _draw_clan_tank_name(at: Vector2, id: int) -> void :
	var look: Dictionary = client.room_state.appearances.get(id, {})
	var tank_id: int = int(look.get("tank", 0))
	if tank_id <= 0:
		return
	var title: String = PlayerInfo.skin_name(int(look.get("external", 0)), tank_id)
	if title.is_empty():
		title = GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(tank_id), "")))
	var level: int = _tank_level(id, look)
	var badge: float = 29.0 if level > 0 else 0.0
	var room: float = CLAN_CARD.x - 4.0 - badge
	var text_w: float = _clan_name_width(title, 12.0)
	if text_w > room:
		var cut: String = title
		while cut.length() > 1 and _clan_name_width(cut.strip_edges() + "...", 12.0) > room:
			cut = cut.left(-1)
		title = cut.strip_edges() + "..."
		text_w = _clan_name_width(title, 12.0)
	var left: Vector2 = at + Vector2(roundf((CLAN_CARD.x - badge - text_w) / 2.0), 248)
	if level > 0:
		_fblit("tklv_%d" % clampi(level, 1, 11), left + Vector2(0, 3), 27.0, 15.75)
	if not title.is_empty():
		_fwords(title, BOLD, 12.0, Color.WHITE, "l", left + Vector2(badge, 0), text_w + 6.0, 1.0, 22.0)


func _draw_pair(at: Vector2) -> void :
	var state = client.room_state
	var on: bool = on_battle(state).has(state.self_id)
	var view: Dictionary = pair_view(int(client.team_match.get("state", 0)), on, state.is_host(), not state.members.has(state.self_id))
	var start: int = int(client.team_match.get("start", 0))
	_fblit("gameroom_img_league_pair_bg", at)

	if start > 0:
		_fwords(clock_text(start - int(Time.get_unix_time_from_system())), BOLD, 16.0, Color.WHITE, "c", at + Vector2(37, 11), 100.0, 1.0, 22.0)
	if view.join:
		_clan_button("clan:join", "gameroom_btn_join_league", "gameroom_icon_join_league_t", at + Vector2(162, 9))
	if view.cancel:
		_clan_button("clan:cancel", "gameroom_btn_cancel_join_league", "gameroom_icon_cancel_join_t", at + Vector2(162, 9))
	if start > 0:
		_fblit("gameroom_wd_league_desc1_t", at + Vector2(22, 40))
	else:
		_fblit("league_word_stop_enter_t", at + Vector2(36, 51))
	if view.mates:
		_fblit("gameroom_wd_league_desc2_t", at + Vector2(22, 63))
	if view.wait:
		_fblit("gameroom_wd_league_desc3_t", at + Vector2(10, 63))
	if view.go:
		_clan_button("clan:go", "gameroom_button_s2_orange", "gameroom_word_gobattle_t", at + Vector2(35, 102))
	if view.exit:
		_clan_button("clan:exit", "gameroom_button_s2_blue", "gameroom_word_cancelgobattle_t", at + Vector2(35, 102))
	if view.watch:
		_clan_button("clan:watch", "gameroom_button_s2_cyan", "gameroom_word_viewbattle_t", at + Vector2(35, 102))
	if view.signed:
		_fblit("gameroom_team_signed_t", at + Vector2(161, 14))
	if view.unsign:
		_fblit("gameroom_team_unsign_t", at + Vector2(161, 14))
	if view.no_next:
		_fblit("gameroom_img_league_pair_bg", at)
		_fwords(NO_NEXT, BOLD, 15.0, NO_NEXT_INK, "c", at + Vector2(12, 30), 226.0, 2.0, 40.0, true, NO_NEXT_RIM)


func _draw_clan_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.4))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(450.0, 220.0)
	_hit("panel", Rect2(at * _f, Vector2(450, 220) * _f), false)
	var panel: Array = Guild.ASK["panel"]
	_fblit("gu_ask", at + Vector2(float(panel[0]), float(panel[1])))
	_fblit("gu_ask_guy", at + Vector2(-80, -76))
	var words: Array = Guild.ASK["txtContent"]
	_fpara(CANCEL_ASK, ARIAL_BOLD, float(words[4]), Color.WHITE, at + Vector2(float(words[0]), float(words[1])), float(words[2]), 5)
	var ok: Array = Guild.ASK["btnConfirm"]
	var no: Array = Guild.ASK["btnCancel"]
	_fbutton("ask_ok", "gu_ask_ok", at + Vector2(float(ok[0]), float(ok[1])))
	_fbutton("ask_no", "gu_ask_no", at + Vector2(float(no[0]), float(no[1])))


func _map_art(kind: String, id: int, at: Vector2, wide: float, high: float, shown: float = -1.0) -> void :
	var picture: Texture2D = pack.picture("l/map/%s%d.webp" % [kind, id]) if (Seats.POSTERS if kind == "p" else Seats.SMALLS).has(id) else null
	var cut: float = wide if shown < 0.0 else clampf(shown, 0.0, wide)
	if picture == null:
		if id == 0 and kind == "s":
			_fblit("map_random_s", at)
			return
		draw_rect(Rect2(at * _f, Vector2(cut, high) * _f), Color("0b2c4f"))
		if cut >= wide:
			_fwords(_map_name(id), BOLD, 14.0 if kind == "p" else 12.0, Color.WHITE, "c", at + Vector2(4, 0), wide - 8.0, 1.5, high)
		return
	var scale: Vector2 = picture.get_size() / Vector2(wide, high)
	draw_texture_rect_region(picture, Rect2(at * _f, Vector2(cut, high) * _f), Rect2(Vector2.ZERO, Vector2(cut, high) * scale))
	if cut < wide or not Seats.DRAWN.has("%s%d" % [kind, id]):
		return
	if kind == "p":
		_fwords(map_title(id), BOLD, 20.0, Color.WHITE, "c", at + Vector2(6, 186), wide - 12.0, 2.5, 30.0, true, Color("0b2c4f"))
		var mode: String = map_mode(id)
		if not mode.is_empty():
			_fwords(mode, BOLD, 13.0, Color("ffe066"), "c", at + Vector2(6, 214), wide - 12.0, 1.5, 20.0)
	else:
		_fwords(map_title(id), BOLD, 12.0, Color.WHITE, "l", at + Vector2(6, 76), wide - 12.0, 1.5, 20.0, true, Color("0b2c4f"))


func _draw_start() -> void :
	var state = client.room_state
	var at: Vector2 = _at("start")
	_map_art("s", _map_id(), at + Vector2(11, 9), 168.0, 100.0)
	_hit("map", Rect2((at + Vector2(11, 9)) * _f, Vector2(168, 107) * _f), false)
	_fblit("gameroom_startgame_background_t", at)
	_fblit("gameroom_cancelready_disable_button_t", at + Vector2(190, 16))
	if state.is_host():
		_fbutton("start", "gameroom_startgame_button_t", at + Vector2(190, 16))
	elif not client.room_watching():
		_fbutton("ready", "gameroom_cancelready_button_t" if state.is_ready() else "gameroom_ready_button_t", at + Vector2(190, 16))


func _draw_picker() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("pick:shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(794.0, 447.0)
	_hit("pick:panel", Rect2(at * _f, Vector2(794, 447) * _f), false)
	_fblit("gameroom_pvp_selectmap_bk", at)
	_fblit("gameroom_pvp_selectmap_shadow", at)
	_fmid("title_selectmap_t", at, 794.0)
	_fbutton("pick:close", "public_button_close", at + Vector2(756, 34))
	var maps: Array = _choices()
	var strip: Vector2 = at + Vector2(33, 61)
	for k in range(PICK_X.size()):
		var index: int = _pick_first + k
		if index >= maps.size():
			break
		var id: int = int(maps[index])
		var item: Vector2 = strip + Vector2(float(PICK_X[k]), 4)
		var shown: float = minf(232.0, STRIP_W - float(PICK_X[k]))
		_map_art("p", id, item + Vector2(9, 11), 214.0, 280.0, shown - 9.0)
		var card: String = "gameroom_mapcard_select" if id == _pick_id else "gameroom_mapcard"
		if shown >= 232.0:
			_fblit(card, item)
			_fwords(_map_name(id), BOLD, 13.0, Color.WHITE if id == _pick_id else Color("555555"), "c", item + Vector2(16, 291), 200.0, 0.0, 0.0, true, Color(0, 0, 0, 0))
		else:
			_fpart(card, item, Rect2(0, 0, shown, 322))
		_hit("pick:%d" % k, Rect2(item * _f, Vector2(shown, 322) * _f), false)
	_fbutton("pick:prev", "public_btn_prev_s2", at + Vector2(13, 193))
	_fbutton("pick:next", "public_btn_next_s2", at + Vector2(729, 193))
	_fmid("public_n_onebtn_bk", at + Vector2(0, 380), 794.0)
	_fmid("public_window_button_bk", at + Vector2(0, 393), 794.0)
	var lit: Color = _glow("pick:ok")
	_hit("pick:ok", _fmid("public_button_window_green", at + Vector2(0, 397), 794.0, lit), false)
	_fmid("title_title_confirm_green_t", at + Vector2(0, 404), 794.0, lit)
	_fblit("public_tip_msg", at + Vector2(494.5, 397))
	_fwords("Nhắc nhở: Double click chọn", BOLD, 12.0, Color.WHITE, "l", at + Vector2(528, 403), 230.0, 1.0)
	_fwords("Chọn: " + (_map_name(_pick_id) if _pick_id > 0 else "bản đồ ngẫu nhiên"), BOLD, 12.0, Color.WHITE, "l", at + Vector2(37, 400), 250.0, 1.0)


static func gift_items(now: int = -1) -> Array:
	var clock: int = now if now >= 0 else int(Time.get_unix_time_from_system())
	var out: Array = []
	for row: Array in Gifts.ITEMS:
		if int(row[5]) == 0 or int(row[5]) >= clock:
			out.append(row)
	return out


static func gift_count(bags: Dictionary, tid: int) -> int:
	var total: int = 0
	for inst: Variant in bags.get(GROCERY, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == tid:
			total += int(inst.get("m_count", 0))
	return total


static func gift_slot(bags: Dictionary, tid: int) -> int:
	for inst: Variant in bags.get(GROCERY, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == tid:
			return int(inst.get("m_slotNo", -1))
	return -1


func _draw_gifts() -> void :
	var at: Vector2 = _gift_at
	_fblit("gda_rg_bg", at)
	_hit("gift:panel", Rect2(at * _f, Vector2(154, 167) * _f), false)
	var items: Array = gift_items()
	var list: Vector2 = at + GIFT_LIST
	for k in range(GIFT_COLS * GIFT_ROWS):
		var index: int = _gift_row * GIFT_COLS + k
		if index >= items.size():
			break
		var row: Array = items[index]
		var cell: Vector2 = list + Vector2(50.0 * (k % GIFT_COLS), 50.0 * (k / GIFT_COLS))
		var id: String = "gift:%d" % index
		_fblit("gda_rg_item_bg", cell + Vector2(4, 4), 0.0, 0.0, _glow(id))
		_fblit("gda_rg_it_" + str(row[4]), cell + Vector2(5, 5), 40.0, 40.0, _glow(id))
		var count: int = gift_count(client.bags, int(row[0]))
		if count > 0:
			_fwords(str(count), ARIAL, 12.0, Color.WHITE, "r", cell + Vector2(10, 26), 34.0, 2.0, 18.0)
		var rect: Rect2 = Rect2(cell * _f, Vector2(50, 50) * _f)
		_hit(id, rect, false)
		_note_on(id, rect, str(row[1]), str(row[2]), BagModel.tint(int(row[3]), Color.WHITE))


func _love_seats(ids: Array) -> void :
	_love_built = true
	var accts: Array = []
	_love_names = {}
	for value: Variant in ids:
		var who: Dictionary = client.room_state.members.get(int(value), {}).get("data", {}).get("charData", {})
		var acct: int = int(who.get("nAcctId", 0))
		accts.append(acct)
		if acct > 0:
			_love_names[acct] = str(who.get("szName", ""))
	_love_tones = Love.tones(client, accts)


func _love_heart(at: Vector2, acct: int, card: Rect2) -> void :
	if not _love_built:
		_love_seats(_love_order())
	var tone: int = Love.tone_of(_love_tones, acct)
	var spot: Rect2 = Love.fdraw(self, at, Love.SIDE, -1, tone)
	var key: String = "love:%d" % acct
	_hit(key, spot.grow(3.0 * _f), false)
	_note_on(key, spot, Love.tip(client, acct, _love_names), "", Love.tone_ink(tone))
	if _hover == key:
		_love_card = card


func _love_order() -> Array:
	if has_method("_sites"):
		return (call("_sites") as Array).slice(0, CLAN_MAX)
	return on_battle(client.room_state).slice(0, CLAN_MAX)



func _love_note_at(anchor: Rect2, wide: float, high: float) -> Vector2:
	var heart: Rect2 = Rect2(anchor.position / _f, anchor.size / _f)
	var box: Rect2 = _love_card if _love_card.size.x >= wide else Rect2(0.0, 0.0, _fw, _fh)
	var x: float = clampf(heart.get_center().x - wide / 2.0, box.position.x, maxf(box.position.x, box.end.x - wide))
	x = clampf(x, 0.0, maxf(0.0, _fw - wide))
	var y: float = heart.position.y - LOVE_BAR - high
	if y < 0.0:
		y = heart.end.y + LOVE_BAR
	return Vector2(x, y)

const LOVE_BAR: float = 6.0


func _tap_tip(id: String) -> bool:
	return id.begins_with("love:")


func _note_on(id: String, rect: Rect2, title: String, body: String, tint: Color) -> void :
	if _hover == id and _press.is_empty():
		_note = [rect, title, body, tint]


func _draw_note() -> void :
	gd_note_box = Rect2()
	if _note.is_empty():
		return
	var anchor: Rect2 = _note[0]
	var body: String = str(_note[2])
	var wide: float = 230.0 if not body.is_empty() else 20.0 + ARIAL_BOLD.get_string_size(str(_note[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(12.0 * _f))).x / _f
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 10).y / _f if not body.is_empty() else 0.0
	var high: float = 28.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	if _hover.begins_with("love:"):
		at = _love_note_at(anchor, wide, high)
	var gd_top: float = 5.0
	if _note.size() > 4:

		wide = minf(21.0 + ceilf(_gd_px(str(_note[1]))), gd_lane.size.x)
		high = gd_lane.size.y
		gd_top = (high - 20.0) / 2.0
		body_h = 0.0
		at = Vector2(gd_lane.end.x - wide, gd_lane.position.y)
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	if _note.size() > 4:
		gd_note_box = Rect2(at * _f, Vector2(wide, high) * _f)
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_note[1]), BOLD, 12.0, _note[3], "l", at + Vector2(10, gd_top), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 10)




func _toggle_gifts(target: int) -> void :
	if _gift_to == target:
		_gift_to = 0
		return
	var spot: Vector2 = _held_at / _f + Vector2(-134, 10)
	_gift_at = Vector2(clampf(spot.x, 0.0, maxf(0.0, _fw - 154.0)), clampf(spot.y, 0.0, maxf(0.0, _fh - 167.0)))
	_gift_to = target
	_gift_since = _time
	_gift_row = 0



func _gift_click(index: int) -> void :
	var items: Array = gift_items()
	var target: int = _gift_to
	_gift_to = 0
	if index < 0 or index >= items.size():
		return
	var tid: int = int(items[index][0])
	if gift_count(client.bags, tid) > 0:
		if target == client.room_state.self_id:
			say(GIFT_SELF)
			return
		var uuid: String = str(client.room_state.members.get(target, {}).get("data", {}).get("charData", {}).get("szCharUuid", "")).strip_edges()
		if not uuid.is_empty():
			client.use_item(GROCERY, gift_slot(client.bags, tid), 1, uuid)
	else:
		quick_buy_asked.emit(tid)




func _pwd_show() -> void :
	if client.is_pairing():
		say(client.INVITE_PAIRING)
		return
	var code: int = int(client.room_state.room.get("m_nPassword", 0))
	Arena.flash_text(_pwd, str(code) if code > 0 else "")
	_pwd_open = true
	_pwd_focus = true
	_gift_to = 0

func _pwd_close() -> void :
	_pwd_open = false
	_pwd_focus = false
	if _pwd != null and _pwd.visible:
		_pwd.visible = false
		_pwd.release_focus()



func _draw_pwd() -> void :
	var at: Vector2 = _window(358.0, 258.0, "pwd:close")
	_fwords("ĐẶT MẬT MÃ", BOLD, 15.0, Color.WHITE, "c", at + Vector2(88, 18), 182.0, 1.5, 28.0, true, TITLE_RIM)
	_fwords("Nhập mật mã room muốn lập", BOLD, 13.0, Color.WHITE, "c", at + Vector2(24, 77), 310.0, 1.5, 21.0, true, TITLE_RIM)
	_fmid("public_input_bk_m", at + Vector2(0, 111), 358.0)
	_fput(_pwd, Rect2(at + Vector2(89, 111), Vector2(180, 35)), 16.0, "c")
	_fblit("public_tip_msg", at + Vector2(58, 149))
	_fwords("Mật mã tối đa 6 chữ số từ 1 đến 9", BOLD, 12.0, Color.WHITE, "l", at + Vector2(92, 154), 230.0, 1.0)
	var row: Vector2 = at + Vector2(45, 203)
	_fblit("public_window_button_bk", row)
	_fblit("public_window_button_bk", row + Vector2(140, 0))
	var lit: Color = _glow("pwd:ok")
	var ok: Rect2 = _fblit("public_button_window_green", row + Vector2(4, 4), 0.0, 0.0, lit)
	_hit("pwd:ok", ok, false)
	_fblit("title_title_confirm_green_t", row + Vector2(4, 4) + ((Vector2(120, 35) - _cell_size("title_title_confirm_green_t")) / 2.0).round(), 0.0, 0.0, lit)
	_hit("pwd:del", _fblit("shop_button_red", row + Vector2(144, 4), 0.0, 0.0, _glow("pwd:del")), false)
	_fwords("XÓA MẬT MÃ", BOLD, 14.0, Color.WHITE, "c", row + Vector2(144, 4), 120.0, 1.5, 35.0, true, Color("7a1010"))
	if _pwd_focus and _pwd.visible:
		_pwd_focus = false
		_pwd.grab_focus.call_deferred()
		_pwd.select_all.call_deferred()


func _pwd_click(id: String) -> void :
	match id:
		"pwd:ok":
			var code: int = _number(_pwd.text)
			if code <= 0:
				say("Nhập mật mã room muốn lập")
				return
			_pwd_close()
			client.room_password(code)
		"pwd:del":
			_pwd_close()
			client.room_password(0)
		"pwd:close", "shade":
			_pwd_close()
		_:
			pass

func _escape() -> bool:
	if _pwd_open:
		_pwd_close()
		return true
	if not _voice_menu.is_empty():
		_voice_menu = ""
		return true
	if not _clan_sheet.is_empty():
		_clan_sheet = ""
		return true
	if _gift_to != 0:
		_gift_to = 0
		return true
	if _picking:
		_picking = false
		return true
	return super ()


func _open_picker() -> void :
	var maps: Array = _choices()
	_pick_id = _map_id() if maps.has(_map_id()) else 0
	var index: int = maps.find(_pick_id)
	_pick_first = 0 if index < 3 else index - 1
	_turn_maps(0)
	_last_pick = -1
	_picking = true
	_gift_to = 0

func _turn_maps(step: int) -> void :
	_pick_first = clampi(_pick_first + step, 0, maxi(0, _choices().size() - 3))

func _pick(k: int) -> void :
	var maps: Array = _choices()
	var index: int = _pick_first + k
	if index < 0 or index >= maps.size():
		return
	var id: int = int(maps[index])
	var twice: bool = k < 3 and _last_pick == id and _time - _last_pick_at < 0.4
	_pick_id = id
	_last_pick = id
	_last_pick_at = _time
	if k == 3:
		_turn_maps(1)
	if twice:
		_choose()

func _choose() -> void :
	_picking = false
	client.set_map(_pick_id)


func _change_camp() -> void :
	var state = client.room_state
	if not state.is_host() and state.is_ready():
		say(TIP_61)
		return
	var camps: Array = _camps()
	var mine: int = _my_camp()
	if mine == 0 and camps[1].size() >= _half():
		say(TIP_59)
	elif mine == 1 and camps[0].size() >= _half():
		say(TIP_60)
	else:
		client.switch_camp()


func _start() -> void :
	var state = client.room_state
	var host: int = int(state.room.get("m_nCreateId", 0))
	for id: int in state.members:
		if id != host and not bool(state.members[id].get("ready", false)):
			client.chat_note(TIP_12)
			return
	var least: int = int(state.room.get("m_nMin", 0))
	if state.members.size() < least:
		say(TIP_97.replace("@num1@", str(least)))
		return
	client.start_room()

func _member_name(id: int) -> String:
	return str(client.room_state.members.get(id, {}).get("data", {}).get("charData", {}).get("szName", ""))


func _clan_sheet_click(id: String) -> void :
	match id:
		"ask_ok":
			_clan_sheet = ""
			client.team_pair_stop()
		"cancel", "rule_go", "ask_no":
			_clan_sheet = ""
		_:
			pass


func _clan_click(what: String) -> void :
	var state = client.room_state
	match what:
		"join":
			client.team_pair_start()
		"cancel":
			_clan_sheet = "ask"
			_gift_to = 0
		"go":
			client.team_seat(true)
		"exit":
			var phase: int = int(client.team_match.get("state", 0))
			if on_battle(state).size() == 1 and phase in [TMMST_PAIR_WAIT, TMMST_PAIR_IDLE]:
				say(TIP_475)
			else:
				client.team_seat(false)
		"watch":
			client._look_oid = 0
			client.room_op(ROPT_LOOK_SCENE, int(client.room_state.room.get("m_nRoomId", 0)))
		"rule":
			_clan_sheet = "rule"
			_gift_to = 0
		"rank":
			page_asked.emit("board:team")

func _activate(id: String) -> void :
	var state = client.room_state
	if id.begins_with("love:"):
		return
	if id.begins_with("voice:"):
		_voice_click(id.substr(6))
		return
	if not _voice_menu.is_empty():
		_voice_menu = ""
	if _pwd_open:
		_pwd_click(id)
		return
	if not _clan_sheet.is_empty():
		_clan_sheet_click(id)
		return
	if id.begins_with("clan:"):
		_clan_click(id.substr(5))
		return
	if id.begins_with("cwait:"):
		if state.is_host():
			say(NO_SERVER % "đóng ghế")
		return
	if id.begins_with("gift:"):
		if id != "gift:panel":
			_gift_click(int(id.substr(5)))
		return
	if id.begins_with("hand:"):
		_toggle_gifts(int(id.substr(5)))
		return
	if id.begins_with("pick:"):
		var what: String = id.substr(5)
		match what:
			"close":
				_picking = false
			"prev":
				_turn_maps(-1)
			"next":
				_turn_maps(1)
			"ok":
				_choose()
			"shade", "panel":
				pass
			_:
				_pick(int(what))
		return
	if id.begins_with("gdob:"):
		_gd_click(id.substr(5))
		return
	if id == "gdseat":
		client.seat_watch( not client.room_watching())
		return
	if id.begins_with("wait:") and client.room_watching() and not state.is_host():
		return
	if id.begins_with("wait:"):
		var row: int = int(id.split(":")[1])
		if state.is_host():
			client.room_seat(client.ROPT_CLOSE)
		elif state.is_ready():
			say(TIP_118)
		elif row != _my_camp():
			_change_camp()
		return
	if id.begins_with("closed:"):
		if state.is_host():
			client.room_seat(client.ROPT_OPEN)
		return
	var colon: int = id.find(":")
	var target: int = int(id.substr(colon + 1)) if colon > 0 else 0
	match id.left(colon) if colon > 0 else id:
		"add":
			var name: String = _member_name(target)
			if client.add_friend(name):
				say("Đã gửi kết bạn tới %s." % name)
			return
		"info":
			var uuid: String = str(state.members.get(target, {}).get("data", {}).get("charData", {}).get("szCharUuid", "")).strip_edges()
			if not uuid.is_empty():
				player_info_asked.emit(uuid)
			return
		"kick":
			if not client.kick(target):
				say(NO_SERVER % "mời người chơi ra khỏi phòng")
			return
		"host":
			client.give_host(target)
			return
	match id:
		"leave", "back":
			client.leave_room()
		"password":
			_pwd_show()
		"camp":
			_change_camp()
		"ready":
			client.ready_room()
		"start":
			_start()
		"map":
			var kind: int = int(state.room.get("m_bType", 1))
			if kind == 2 or kind == 9:
				say(TIP_120)
			elif state.is_host():
				_open_picker()
		_:
			_shared(id)




func _voice_get() -> Object:
	if _voice == null and client != null and VoiceClient.usable():
		_voice = VoiceClient.shared()
		_voice.notice.connect(_voice_say)
		if client.has_signal("voice_notice") and not client.voice_notice.is_connected(_voice.on_notice):
			client.voice_notice.connect(_voice.on_notice)
	if _voice != null and _voice.client != client:
		_voice.client = client
	return _voice

func _tick_voice() -> void :
	var voice: Object = _voice_get()
	if (voice == null or not voice.shown()) and not _voice_menu.is_empty():
		_voice_menu = ""
	if _voice_menu.begins_with("who:") and (voice == null or not voice.in_voice(int(_voice_menu.substr(4)))):
		_voice_menu = ""
	if voice != null and _voice_hold_at >= 0.0 and not _held:
		_voice_release()


func _voice_shown() -> bool:
	return _voice != null and _voice.shown()

func _voice_say(text: String) -> void :
	if is_visible_in_tree() and not covered:
		say(text)
	elif client != null:
		client.chat_note(text)

func _voice_release() -> void :
	if _voice_hold_at >= 0.0 and _voice != null:
		_voice.set_talk(false)
	_voice_hold_at = -1.0


func _draw_voice_bar(frame: Vector2) -> void :
	if not _voice_shown():
		return
	var mic: Vector2 = (frame + VOICE_MIC) * _f
	var spk: Vector2 = (frame + VOICE_SPK) * _f
	var rad: float = VOICE_R * _f
	var hit: Vector2 = Vector2(VOICE_HIT, VOICE_HIT_UP) * _f
	var box: Vector2 = Vector2(VOICE_HIT, VOICE_HIT) * 2.0 * _f
	var state: String = _voice.mic_state()
	var tag: String = ""
	if state != "off" and Settings.value("mic_mode") == "ptt" and not _mobile:
		var code: int = int(Settings.value("mic_ptt_key"))
		if code != int(_voice_key[0]):
			_voice_key = [code, str(load("res://ui/settings.gd").ptt_name(code))]
		tag = str(_voice_key[1])
	VoiceUI.button(self, mic, rad, "mic_off" if state == "off" else "mic", state, tag, BOLD, _f, _hover == "voice:mic", _press == "voice:mic")
	_hits.append(["voice:mic", Rect2(mic - hit, box)])
	var mode: String = _voice.speaker
	var icon: String = "spk_off" if mode == "off" else ("spk" if mode == "all" else "spk_room")
	VoiceUI.button(self, spk, rad, icon, "off" if mode == "off" else "on", str(VOICE_TAG.get(mode, "")), BOLD, _f, 
		_hover == "voice:spk" or _voice_menu == "spk", _press == "voice:spk")
	_hits.append(["voice:spk", Rect2(spk - hit, box)])


func _draw_voice_seat(at: Vector2, id: int, me: bool, hired: bool, box: Vector2 = CARD) -> void :
	if not _voice_shown():
		return
	var card: Rect2 = Rect2(at * _f, box * _f)
	if _voice.is_talking(id):
		VoiceUI.glow(self, card.grow(-2.0 * _f), 8.0 * _f, VoiceUI.TALK, _f)
	if me or not _voice.in_voice(id):
		return
	var center: Vector2 = (at + (VOICE_CHIP_LOW if hired else VOICE_CHIP)) * _f
	var rad: float = VOICE_CHIP_R * _f
	if _voice.is_muted(id):
		VoiceUI.chip(self, center, rad, "spk_off", VoiceUI.MUTE_FILL, _f)
	elif _voice.is_talking(id):
		VoiceUI.chip(self, center, rad, "wave", VoiceUI.WAVE_FILL, _f)
	else:
		VoiceUI.chip(self, center, rad, "spk", Color(VoiceUI.WAVE_FILL, 0.55), _f)
	var hit: String = "voice:who:%d" % id
	_hits.append([hit, Rect2(center - Vector2(rad, rad) * 1.3, Vector2(rad, rad) * 2.6)])
	if _hover == hit:
		draw_circle(center, rad, Color(1, 1, 1, 0.15))


func _draw_voice_menu() -> void :
	if _voice_menu.is_empty() or not _voice_shown():
		return
	_hits.append(["voice:shade", Rect2(Vector2.ZERO, size)])
	var frame: Vector2 = _at("hall")
	if _voice_menu == "spk":
		var hover: String = _hover.substr(10) if _hover.begins_with("voice:spk:") else ""
		var corner: Vector2 = frame + VOICE_MENU
		var rows: Dictionary = VoiceUI.speaker_menu(self, corner * _f, VOICE_ROWS, _voice.speaker, (frame.x + VOICE_SPK.x) * _f, BOLD, SEMI, _f, hover, true)
		var box: Rect2 = Rect2(corner * _f, Vector2(236.0, 30.0 + VOICE_ROWS.size() * 40.0 + 6.0) * _f)
		_hits.append(["voice:panel", box])
		for code: String in rows:
			_hits.append(["voice:spk:" + code, rows[code]])
		return
	var id: int = int(_voice_menu.substr(4))
	var hover2: String = ""
	if _hover.begins_with("voice:mute:"):
		hover2 = "mute"
	elif _hover.begins_with("voice:report:"):
		hover2 = "report"
	var muted: bool = _voice.is_muted(id)
	var items: Array = [["mute", "spk" if muted else "spk_off", "Bật tiếng" if muted else "Tắt tiếng"], ["report", "flag", "Tố cáo voice"]]
	var at: Vector2 = _voice_menu_at * _f
	at.x = minf(at.x, size.x - 132.0 * _f)
	at.y = minf(at.y, size.y - 70.0 * _f)
	var cells: Dictionary = VoiceUI.small_menu(self, at, items, BOLD, _f, hover2)
	_hits.append(["voice:panel", Rect2(at, Vector2(128.0, 8.0 + items.size() * 28.0) * _f)])
	for code: String in cells:
		_hits.append(["voice:%s:%d" % [code, id], cells[code]])

func _voice_click(what: String) -> void :
	if _voice == null:
		return
	if what == "mic":
		if _voice_menu == "spk":
			_voice_menu = ""
		_voice.toggle_mic()
	elif what == "spk":
		_voice_menu = "" if _voice_menu == "spk" else "spk"
		_voice.set_speaker(_voice.speaker)
	elif what.begins_with("spk:"):
		_voice.set_speaker(what.substr(4))
		_voice_menu = ""
	elif what.begins_with("who:"):
		var id: int = int(what.substr(4))
		var key: String = "who:%d" % id
		if _voice_menu == key:
			_voice_menu = ""
		else:
			_voice_menu = key
			var hit: Rect2 = Rect2()
			for row: Array in _hits:
				if str(row[0]) == "voice:" + what:
					hit = row[1]
			_voice_menu_at = (hit.position + Vector2(hit.size.x, 0)) / maxf(_f, 0.001)
	elif what.begins_with("mute:"):
		_voice.toggle_mute(int(what.substr(5)))
		_voice_menu = ""
	elif what.begins_with("report:"):
		_voice.report(int(what.substr(7)))
		_voice_menu = ""
	elif what == "shade":
		_voice_menu = ""


func _gui_input(event: InputEvent) -> void :
	if _voice != null and _mobile and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if _hit_at(event.position) == "voice:mic" and _voice.mic_state() != "off" and Settings.value("mic_mode") == "ptt":
				_voice_hold_at = _time
				_voice.set_talk(true)
		elif _voice_hold_at >= 0.0:
			var long: bool = _time - _voice_hold_at > VOICE_HOLD
			_voice_release()
			if long:
				_press = ""
	super (event)
