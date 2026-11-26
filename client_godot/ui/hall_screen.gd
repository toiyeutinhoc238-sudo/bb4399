extends "flash_screen.gd"








const Text = preload("../i18n.gd")
const Atlas = preload("arena_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Love = preload("love.gd")
const NameStyles = preload("name_styles.gd")
const SocialMenu = preload("social_menu.gd")
const LobbyBar = preload("lobby_bar.gd")
const Friends = preload("friends.gd")
const FriendsAtlas = preload("friends_atlas.gd")
const MasterModel = preload("master_model.gd")

signal whisper(name: String)
signal master_asked
signal reputation_asked
signal history_asked
signal talent_asked(tank_uuid: String)

const CARDS: int = 7

const CARD_BOX: Vector2 = Vector2(159, 66)
const LIST_CLIP: Vector2 = Vector2(159, 464)
const HALL_ORNATE: String = "l/hl/%s.webp"

const LIST_TABS: Array = [["guild", 15, "gameroom_roomplayerlist_label_team_t"], ["friend", 71, "gameroom_roomplayerlist_label_friend_t"], 
	["room", 127, "gameroom_roomplayerlist_label_hall_t"]]
const CHAT_TABS: Array = [["all", "Tổng"], ["room", "Room"], ["camp", "Team"], ["guild", "Guild"], ["whisper", "Chat riêng"]]
const CHAT_LINES: int = 5
const CHAT_GLASS: Color = Color("0a1729", 0.9)
const CHAT_EDGE: Color = Color("2c5d8f", 0.7)
const ChatBg = preload("chat_bg.gd")
const CHAT_IDLE: float = 0.5
const CHAT_SIDE: Array = [[53, "chat_chat_clear"], [77, "chat_chat_up"], [101, "chat_chat_down"], [125, "chat_chat_downend"]]

const PAGES: Dictionary = {"nav:shop": "shop", "nav:friends": "friends", "nav:rank": "rank", "nav:crystal": "crystal", "nav:tank": "tank", 
	"nav:support": "helper", "nav:bag": "bag", "col:quest": "quest", "settings": "settings"}

const TIERS: Array = ["Đồng", "Bạc", "Vàng", "Bạch Kim", "Kim Cương", "Chỉ Huy"]
const ROMAN: Array = ["I", "II", "III", "IV"]
const TITLE_RIM: Color = Color("0d4f96")

const CHAT_PILL: float = 280.0
const PILL_WIDE: float = 448.0
const BAR_GAP: float = 8.0
const BAR_EASE: float = 0.15

var _parts: Dictionary = {}
var _tab: String = "guild"
var _list_first: int = 0
var _pending: bool = false
var _chat_tab: String = "all"
var _bag_asked: bool = false
var _list_clip: Rect2 = Rect2()
var _viewing: Dictionary = {}
var _view_at: Vector2 = Vector2.ZERO
var _view_hide_at: float = -1.0
var _view_rect: Rect2 = Rect2()
var _chat_mark: int = -1
var _social = SocialMenu.new()
var _bar_open: float = 0.0
var _bar_clock: float = -1.0

var bar_style: String:
	get:
		return LobbyBar.current()
var chat_glass: Rect2 = Rect2()

var chat_lit: bool = false:
	set(on):
		if on != chat_lit:
			chat_lit = on
			queue_redraw()


var chat_tint: Array = []:
	set(value):
		if value != chat_tint:
			chat_tint = value
			queue_redraw()



func chat_cover() -> Array:
	if _chat_mark < 0 or _chat_mark > _hits.size():
		return []
	return _hits.slice(_chat_mark).map( func(hit: Array) -> Rect2: return hit[1])



func chat_busy() -> bool:
	return false

func _setup() -> void :
	_parts["menu"] = []
	for row: Array in Hall.PLACE:
		if str(row[0]) == "menu":
			_parts["menu"].append(row)
	client.noticed.connect( func(text: String) -> void :
		if is_visible_in_tree():
			say(text))
	client.friend_result.connect( func(_ok: bool, text: String) -> void :
		if is_visible_in_tree():
			say(text))


func _add_parts(rows: Array) -> void :
	for row: Array in rows:
		if not _parts.has(row[0]):
			_parts[row[0]] = []
		_parts[row[0]].append(row)


func _frames() -> Dictionary:
	return Atlas.FRAME


func _at(frame: String) -> Vector2:
	var row: Array = _frames()[frame]
	return _stage() + Vector2(float(row[0]), float(row[1]))

func _reset_list() -> void :
	_list_first = 0
	_pending = true
	_bag_asked = false
	_viewing = {}

static func _number(text: String) -> int:
	return clampi(int(text.strip_edges()), 0, 4294967295) if text.strip_edges().is_valid_int() else 0



static func _map_cut(full: String) -> int:
	return maxi(full.rfind("["), full.rfind("("))

static func map_title(id: int) -> String:
	var full: String = Text.map_name(id)
	var cut: int = _map_cut(full)
	return full.left(cut).strip_edges() if cut > 0 else full

static func map_mode(id: int) -> String:
	var full: String = Text.map_name(id)
	var cut: int = _map_cut(full)
	if cut <= 0:
		return ""
	var words: PackedStringArray = full.substr(cut + 1).rstrip("])").strip_edges().split(" ", false)
	for index in range(words.size()):
		words[index] = words[index].left(1).to_upper() + words[index].substr(1)
	return " ".join(words)


static func section_name(section: int) -> String:
	if section <= 0:
		return ""
	if section >= 17:
		return str(TIERS[5])
	if section >= 13:
		return "%s %s" % [TIERS[4], ROMAN[section - 13]]
	return "%s %s" % [TIERS[(section - 1) / 3], ROMAN[(section - 1) % 3]]


static func medal(section: int) -> int:
	if section >= 17:
		return 6
	if section >= 13:
		return 5
	return clampi((section - 1) / 3 + 1, 1, 4)


static func name_style(vip: int) -> Array:
	if vip <= 0:
		return [Color.WHITE, Color(0, 0, 0, 0.8)]
	if vip < 3:
		return [Color("e6f83c"), Color("2c6400")]
	if vip < 6:
		return [Color("f6bcff"), Color("6a00a6")]
	return [Color("ffd84a"), Color("7a2600")]


static func vip_of(who: Dictionary) -> int:
	return clampi(int(who.get("nVipLevel", 0)) % 100, 0, 12)

func _scroll(step: int) -> void :
	_list_first = clampi(_list_first + step, 0, maxi(0, client.players(_tab).size() - CARDS))


func _tick_list() -> void :
	_scroll(0)
	if _pending and client.request_players(_tab):
		_pending = false
	if not _viewing.is_empty():

		if _view_rect.has_point(get_local_mouse_position()):
			_view_hide_at = -1.0
		elif _view_hide_at < 0.0:
			_view_hide_at = _time + Friends.MENU_TIME
		if _view_hide_at >= 0.0 and _time >= _view_hide_at:
			_hide_view()


func _wheel_list(step: int, at: Vector2) -> bool:
	if Rect2(_at("list") * _f, Vector2(194, 521) * _f).has_point(at):
		_scroll(step)
		return true
	return false



func _head(who: Dictionary) -> Texture2D:
	var key: String = str(pack.lobby.get("avatars", {}).get(str(int(who.get("nAvatar", 0))), ""))
	return pack.picture("l/h/%s.webp" % key) if not key.is_empty() else null


func _draw_players(frame: Vector2) -> void :
	for tab: Array in LIST_TABS:
		var id: String = "list:" + str(tab[0])
		var at: Vector2 = frame + Vector2(float(tab[1]), 6)
		_hit(id, _fblit("gameroom_roomplayerlist_label_selected" if _tab == str(tab[0]) else "gameroom_roomplayerlist_label_bk", at, 0.0, 0.0, _glow(id)), false)
		var word: Vector2 = _cell_size(str(tab[2]))
		_fblit(str(tab[2]), at + Vector2(roundf((53.0 - word.x) / 2.0), roundf((25.0 - word.y) / 2.0)))
	var people: Array = client.players(_tab)
	_list_clip = Rect2(frame + Vector2(5, 37), LIST_CLIP)
	_fblit("public_darkgreen_scrollbar_bk", frame + Vector2(164, 37), 20.0, 464.0)
	_fbutton("list:up", "public_darkgreen_scrollbar_up", frame + Vector2(165, 38))
	_fbutton("list:down", "public_darkgreen_scrollbar_down", frame + Vector2(165, 482))
	if people.size() > CARDS:
		var high: float = maxf(24.0, 426.0 * CARDS / people.size())
		var most: int = people.size() - CARDS
		var knob: Rect2 = _fblit("public_darkgreen_scrollbar_block", frame + Vector2(165, 56.0 + roundf((426.0 - high) * _list_first / most)), 18.0, high, _glow("slide:list"))
		_knob_hit("slide:list", knob, _list_first, most, (426.0 - high) * _f, func(value: float) -> void : _list_first = clampi(roundi(value), 0, most))
	for slot in range(clampi(people.size() - _list_first, 0, CARDS)):
		_draw_card(frame + Vector2(5, 37 + 66 * slot), people[_list_first + slot], _list_first + slot)


func _can_invite(_who: Dictionary) -> bool:
	return false





static func hall_ornate_path(live: Variant, hall: Dictionary, item: int) -> String:
	if item <= 0:
		return ""
	var table: Variant = (live as Dictionary).get("hornate") if live is Dictionary else null
	var stem: Variant = (table as Dictionary)[str(item)] if table is Dictionary and (table as Dictionary).has(str(item)) else\
	(hall.get("ornate") as Dictionary).get(str(item), "") if hall.get("ornate") is Dictionary else ""
	return HALL_ORNATE % stem if stem is String and not (stem as String).is_empty() else ""



static func hall_pack_anim(live: Variant, hall: Dictionary, path: String) -> Variant:
	var fresh: Variant = (live as Dictionary).get("anim") if live is Dictionary else null
	if path.is_empty() or (fresh is Dictionary and (fresh as Dictionary).has(path)) or not (hall.get("anim") is Dictionary):
		return null
	return (hall.get("anim") as Dictionary).get(path)



static func hall_region(row: Variant, now_ms: int) -> Rect2:
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


static func hall_ornate_at(card: Vector2, size: Vector2) -> Vector2:
	return card + ((CARD_BOX - size) / 2.0 + Vector2(0, 2) + Vector2(0.5, 0.5)).floor()


func _draw_hall_ornate(at: Vector2, who: Dictionary) -> void :
	var item: int = int(who.get("nDecorateId", 0))
	if item <= 0 or pack == null:
		return
	if pack.has_method("load_gda_hall"):
		pack.load_gda_hall()
	var live: Variant = pack.get("live")
	var hall: Dictionary = pack.get("gda_hall") if pack.get("gda_hall") is Dictionary else {}
	var path: String = hall_ornate_path(live, hall, item)
	var still: Texture2D = pack.picture(path) if not path.is_empty() else null
	if still == null:
		return
	var moving: Variant = hall_pack_anim(live, hall, path)
	var region: Rect2 = hall_region(moving, Time.get_ticks_msec()) if moving != null else Rect2()
	var sheet: Texture2D = pack.picture(str((moving as Array)[0])) if region.has_area() else null
	if sheet == null or sheet.get_width() < region.end.x or sheet.get_height() < region.end.y:
		sheet = still
		region = Rect2(Vector2.ZERO, still.get_size())
	var box: Rect2 = Rect2(hall_ornate_at(at, region.size), region.size)
	var cut: Rect2 = box.intersection(_list_clip) if _list_clip.has_area() else box
	if cut.has_area():
		draw_texture_rect_region(sheet, Rect2(cut.position * _f, cut.size * _f), Rect2(region.position + cut.position - box.position, cut.size))

func _draw_card(at: Vector2, who: Dictionary, index: int) -> void :
	_draw_hall_ornate(at, who)

	_hit("who:%d" % index, Rect2(at * _f, Vector2(159, 66) * _f), false)
	var head: Texture2D = _head(who)
	var face: Rect2 = Rect2((at + Vector2(7, 6)) * _f, Vector2(40, 40) * _f)
	if head != null:
		draw_texture_rect(head, face, false)
	else:
		draw_rect(face, Color(0, 0, 0, 0.28))
	var vip: int = vip_of(who)
	var style: Array = name_style(vip)
	var love_on: bool = Love.near(client, int(who.get("nAcctId", 0)))
	var love_room: float = (68.0 if vip > 0 else 103.0) - (24.0 if love_on else 0.0)
	if NameStyles.paint(self, str(who.get("szName", "")), BOLD, 12.0, "l", at + Vector2(53, 6), love_room, 1.0, 22.0): style = [Color(0, 0, 0, 0), Color(0, 0, 0, 0)]
	var love_used: float = _fwords(str(who.get("szName", "")), BOLD, 12.0, style[0], "l", at + Vector2(53, 6), love_room, 1.0, 22.0, true, style[1])
	if love_on:
		Love.fdraw(self, at + Vector2(53.0 + love_used + Love.NAME_GAP, 10.0), Love.SIDE)
	if vip > 0:
		_fblit("vip_%d" % vip, at + Vector2(122, 10))
	_fblit("level_%d" % clampi(int(who.get("bLevel", 1)), 0, 40), at + Vector2(7, 46), 40.0, 20.0)
	_level_fx(int(who.get("bLevel", 1)), at + Vector2(7, 46), 40.0)
	var section: int = int(who.get("eloSectionId", 0))
	if section > 0:
		var badge: Texture2D = pack.picture("l/bxh/s%d.webp" % medal(section))
		if badge != null:
			var high: float = 22.5
			draw_texture_rect(badge, Rect2((at + Vector2(53, 22)) * _f, Vector2(high * badge.get_width() / maxf(1.0, badge.get_height()), high) * _f), false)
		_fwords(section_name(section), BOLD, 12.0, Color.WHITE, "l", at + Vector2(77, 26), 48.0, 1.0)
	_fbutton("see:%d" % index, "gameroom_button_watch_t", at + Vector2(47, 46))
	if _can_invite(who):
		_fbutton("invite:%d" % index, "gameroom_button_invite_t", at + Vector2(87, 46))
	var honor: int = int(who.get("nHonorId", 0))
	if honor > 0:
		if pack.bag.is_empty():
			if not _bag_asked:
				_bag_asked = true
				pack.load_bag()
		else:
			var row: Array = pack.bag.get("honors", {}).get(str(honor), [])
			var art: String = str(row[2]) if row.size() > 2 else ""
			var icon: Texture2D = pack.picture("l/hn/%s.webp" % art) if not art.is_empty() else null
			if icon != null:
				draw_texture_rect(icon, Rect2((at + Vector2(127, 44)) * _f, Vector2(20, 20) * _f), false)


func _channel_name() -> String:
	return "Thế Giới"


func _team_open() -> bool:
	return false



func _draw_chat() -> void :
	_chat_mark = -1
	chat_glass = Rect2()
	if chat_modern:
		chat_dock = Rect2((_at("input") + Vector2(6, -3)) * _f, Vector2(CHAT_PILL, 43) * _f)


		var top: Vector2 = _at("chat") - Vector2(0, 6)
		var bottom: float = chat_dock.position.y / _f
		if bottom - top.y > 40.0:
			var room: float = minf(448.0, floorf(_fw + 0.01) - top.x - 10.0)
			chat_glass = Rect2((top + Vector2(2, 2)) * _f, Vector2(room + 8.0, bottom - top.y - 2.0) * _f)
			var fade: float = 1.0 if chat_lit else CHAT_IDLE
			var fill: Color = Color(CHAT_GLASS, CHAT_GLASS.a * fade)
			var edge: Color = Color(CHAT_EDGE, CHAT_EDGE.a * fade)
			if chat_tint.size() == 3:
				var mix: float = clampf(float(chat_tint[2]), 0.0, 1.0)
				fill = ChatBg.blend(ChatBg.glass(str(chat_tint[1]), Color(CHAT_GLASS, CHAT_GLASS.a * CHAT_IDLE)), ChatBg.glass(str(chat_tint[0]), CHAT_GLASS), mix)
				edge = Color(CHAT_EDGE, CHAT_EDGE.a * lerpf(CHAT_IDLE, 1.0, mix))
			_round(chat_glass, fill, 10.0, edge, 1.0)
			_hit("chat", chat_glass, false)
		_chat_mark = _hits.size()
		return
	var frame: Vector2 = _at("chat")
	_hit("chat", _fblit("chat_chatBk", frame + Vector2(0, -6)), false)
	for i in range(CHAT_TABS.size()):
		var key: String = str(CHAT_TABS[i][0])
		var id: String = "chan:" + key
		var at: Vector2 = frame + Vector2(31 + 71 * i, 1)
		_hit(id, _fblit("chat_chat_channel_select" if _chat_tab == key else "chat_chat_channel_item", at, 0.0, 0.0, _glow(id)), false)

		_fwords(str(CHAT_TABS[i][1]), BOLD, 12.0, Color(1, 1, 1, 0.45 if key == "camp" and not _team_open() else 0.92), "c", at, 69.0, 1.0, 25.0)
	for side: Array in CHAT_SIDE:
		_fblit(str(side[1]), frame + Vector2(10, float(side[0])))
	var lines: Array = []
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		var where: String = str(line.get("tab", "all"))
		if _chat_tab == "all" or where.is_empty() or where == _chat_tab:
			lines.push_front(line)
			if lines.size() >= CHAT_LINES:
				break
	for i in range(lines.size()):
		var line: Dictionary = lines[i]
		var at: Vector2 = frame + Vector2(33, 28 + 24 * i)
		var head: String = str(line.get("head", "")) + str(line.get("name", ""))
		var ink: PackedColorArray = NameStyles.chat_colors(client, line, head)
		if not ink.is_empty():
			NameStyles.place(self, head, SEMI, 14.0, "l", at, 390.0, 1.0, 24.0, false, ink, true)
			line = line.merged({"name_color": Color(0, 0, 0, 0)}, true)
		var used: float = _fwords(head, SEMI, 14.0, line.get("name_color", Color.WHITE), "l", at, 390.0, 1.0, 24.0, false) if not head.is_empty() else 0.0
		if 390.0 - used > 20.0:
			_fwords(str(line.get("text", "")), REGULAR, 14.0, line.get("color", Color.WHITE), "l", at + Vector2(used + 3.0, 0), 387.0 - used, 1.0, 24.0, false)

	var track: Rect2 = Rect2((frame + Vector2(428, 28)) * _f, Vector2(16, 120) * _f)
	draw_rect(track, Color("17558f", 0.9))
	for end: int in range(2):
		var cell: Rect2 = Rect2(track.position + Vector2(0, 104.0 * _f * end), Vector2(16, 16) * _f)
		draw_rect(cell, Color("1f9be8"))
		draw_rect(cell, Color("6cc8ff"), false, maxf(1.0, _f))
		var centre: Vector2 = cell.get_center()
		var way: float = 1.0 if end == 1 else -1.0
		draw_colored_polygon(PackedVector2Array([centre + Vector2(-3.5, -2.0 * way) * _f, centre + Vector2(3.5, -2.0 * way) * _f, centre + Vector2(0, 2.5 * way) * _f]), Color.WHITE)
	var row: Vector2 = _at("input")

	LobbyBar.input_row(self, bar_style, _f, Rect2(row + Vector2(6, 1), Vector2(CHAT_PILL, 34)), _channel_name(), "", 
		2 if _press == "chat" else (1 if _hover == "chat" and _press.is_empty() else 0), false)
	chat_dock = Rect2((row + Vector2(6, -3)) * _f, Vector2(CHAT_PILL, 43) * _f)
	_hit("chat", chat_dock, false)




func bar_area() -> Rect2:
	var menu: Vector2 = _at("menu")
	if _bar_clock >= 0.0:
		_bar_open = move_toward(_bar_open, 1.0 if chat_lit else 0.0, maxf(0.0, _time - _bar_clock) / BAR_EASE)
	_bar_clock = _time
	var pill: float = _at("input").x + 6.0
	var left: float = maxf(menu.x, pill + lerpf(CHAT_PILL, PILL_WIDE, _bar_open) + BAR_GAP)
	return Rect2(Vector2(left, menu.y), Vector2(maxf(1.0, menu.x + 754.0 - left), 48.0))




func _draw_menu() -> void :
	var menu: Vector2 = _at("menu")
	_social.refresh(client)
	var area: Rect2 = bar_area()
	LobbyBar.panel(self, bar_style, _f, area)
	var badges: Dictionary = {}
	if not _social.open and not _social.tips(client).is_empty():
		badges["social"] = ""
	var off: Array = [] if LobbyBar.talent_block(client).is_empty() else ["nav:talent"]
	for hit: Array in LobbyBar.menu(self, bar_style, _f, area, _hover, _press, badges, [], Vector2.ZERO, off, LobbyBar.hidden_ids(client)):
		_hit(str(hit[0]), hit[1], false)
		if str(hit[0]) == "social":
			menu.x = (hit[1] as Rect2).get_center().x / _f - (SocialMenu.AT.x + SocialMenu.SIDE / 2.0)
	for part: Array in _social.parts(_press):
		var rect: Rect2 = part[2]
		var lit: float = _shine(str(part[0]))
		if part[1] != null:
			draw_texture_rect(part[1], Rect2((menu + rect.position) * _f, rect.size * _f), false, Color(lit, lit, lit, 1.0))
	for hit: Array in _social.hits():
		var rect: Rect2 = hit[1]
		_hit(str(hit[0]), Rect2((menu + rect.position) * _f, rect.size * _f), false)
	if not _social.open:
		return
	for tip: Array in _social.tips(client):
		var box: Rect2 = tip[0]
		var at: Vector2 = menu + box.position
		_fblit("public_tip", at + (box.size - _cell_size("public_tip")) / 2.0)
		if not str(tip[1]).is_empty():
			_fwords(str(tip[1]), BOLD, 11.0, Color.WHITE, "c", at, box.size.x, 0.0, box.size.y)


func _confirm(at: Vector2, wide: float, high: float, word: String) -> void :
	var lit: Color = _glow("ok")
	_hit("ok", _fmid("public_button_window_green", at + Vector2(0, high - 52.0), wide, lit), false)
	_fmid(word, at + Vector2(0, high - 45.0), wide, lit)


func _word_button(id: String, at: Vector2, word: String) -> void :
	var lit: Color = _glow(id)
	_hit(id, _fblit("public_button_window_green", at, 0.0, 0.0, lit), false)
	_fwords(word, BOLD, 14.0, Color.WHITE, "c", at, 120.0, 1.5, 33.0, true, Color("2c6400"))




func _draw_viewing() -> void :
	if not _cells.has("fr_watch"):
		_use(FriendsAtlas.FILE, {"fr_cutline": FriendsAtlas.R["fr_cutline"], "fr_watch": FriendsAtlas.R["fr_watch"]})
	var high: float = _view_high()
	var at: Vector2 = _stage() + _view_at
	_view_rect = Rect2(at * _f, Vector2(Friends.MENU_W, high) * _f)
	_hit("panel", _view_rect, false)
	_round(_view_rect, Color("e9f9ff", 0.98), 20.0, Color.WHITE, 4.0)
	_fwords(str(_viewing.get("szName", "")), ARIAL_BOLD, 16, Color("f16422"), "l", at + Vector2(10, 5), 160)
	var lines: Array = Friends.state_lines(_view_state())
	for i in range(2):
		if not str(lines[i]).is_empty():
			_fwords(_view_cut(str(lines[i])), ARIAL_BOLD, 14, Friends.LINK, "l", at + Vector2(10, 30 + 20 * i), Friends.STATE_LABEL_W, 0.0, 0.0, false)
	_fblit("fr_cutline", at + Vector2(8, 75), 0.0, 0.0, Color(1, 1, 1, 0.8))
	var font_size: int = maxi(6, roundi(14.0 * _f))
	var y: float = 76.0
	for item: Array in view_items():
		var id: String = str(item[0])
		var label: String = str(item[1])
		var on: bool = bool(item[2])
		var wide: float = ARIAL_BOLD.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f + 5.0
		var cell: Rect2 = Rect2(at + Vector2(2, y), Vector2(wide, 20))
		var ink: Color = Friends.LINK if on else Friends.LINK_OFF
		if on and _hover == id:
			_round(Rect2(cell.position * _f, cell.size * _f), Friends.LINK_ROLL, 4.0)
			ink = Color.WHITE
		_fwords(label, ARIAL_BOLD, 14, ink, "c", cell.position, cell.size.x, 0.0, 20.0, false)
		if on:
			_hit(id, Rect2(cell.position * _f, cell.size * _f), false)
		y += 20.0
	_fbutton("po:watch", "fr_watch", at + Vector2(114, high - 29.0))



func _open_view(who: Dictionary) -> void :
	_viewing = who
	_place_view(get_local_mouse_position())
	_view_hide_at = _time + Friends.MENU_TIME
	var uuid: String = str(who.get("szCharUuid", ""))
	if not uuid.is_empty() and uuid != "0":
		client.request_char_state(uuid)


func _place_view(mouse: Vector2) -> void :
	var high: float = _view_high()
	var at: Vector2 = mouse / _f - _stage()
	_view_at = Vector2(clampf(at.x, 0.0, 1000.0 - Friends.MENU_W), clampf(at.y, 0.0, 600.0 - high))
	_view_rect = Rect2((_stage() + _view_at) * _f, Vector2(Friends.MENU_W, high) * _f)

func _hide_view() -> void :
	_viewing = {}
	_view_hide_at = -1.0
	_view_rect = Rect2()


func _view_high() -> float:
	var master: bool = ("master" in client) and client.master != null and client.master.have_master()
	return (314.0 if int(client.character.get("level", 0)) < Friends.GRADUATE_LEVEL and not master else 288.0) + Love.menu_extra(client)


func _view_state() -> Dictionary:
	var uuid: String = str(_viewing.get("szCharUuid", ""))
	if uuid.is_empty() or uuid == "0":
		return {}
	return client.char_states.get(uuid, {})


func _view_cut(text: String) -> String:
	var font: Font = _face(ARIAL_BOLD)
	var px: int = maxi(6, roundi(14.0 * _f))
	var room: float = (Friends.STATE_LABEL_W - 4.0) * _f
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x <= room:
		return text
	var dots: float = font.get_string_size("...", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	var keep: String = text
	while not keep.is_empty() and font.get_string_size(keep, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x + dots > room:
		keep = keep.left(-1)
	return keep + "..."



func _view_invitable(me: bool) -> bool:
	var uuid: String = str(_viewing.get("szCharUuid", ""))
	if me or int(client.guild.get("nGuildId", 0)) <= 0 or ( not uuid.is_empty() and client.guild_members.has(uuid)):
		return false
	var reply: Dictionary = _view_state()
	if not reply.is_empty():
		return Friends.guild_open(reply)
	var oid: int = int(_viewing.get("nAcctId", 0))
	for member: Dictionary in client.guild_members.values():
		if oid > 0 and int(member.get("nAcctId", 0)) == oid:
			return false
	return true



func view_items() -> Array:
	var name: String = str(_viewing.get("szName", ""))
	var me: bool = _is_self(name)
	var items: Array = [["po:add", "Thêm bạn bè", not me and not _is_friend(name)]]
	if _view_high() - Love.menu_extra(client) > 300.0:
		items.append(["po:master", "Bái làm Sư Phụ", not me])
	if Love.shown(client):
		items.append(["po:love", "Tỏ tình", Love.can_invite(client, int(_viewing.get("nAcctId", 0)), me)])
	items.append_array([["po:chat", "Chat riêng", not me], ["po:copy", "Copy tên gọi", true], ["po:black", "Thêm vào sổ đen", not me and not client.is_black_name(name)], 
		["po:guild", "Mời vào Guild", _view_invitable(me)], ["po:delete", "Xóa", false], Friends.state_item("po:", _view_state())])
	if int(client.character.get("gm_level", 0)) > 0:
		items.append(["po:gm", "Thao tác GM", true])
	return items





func _view_action(key: String) -> void :
	var name: String = str(_viewing.get("szName", ""))
	if name.is_empty():
		return
	for item: Array in view_items():
		if str(item[0]) == "po:" + key and not bool(item[2]):
			return
	match key:
		"add":
			if client.is_black_name(name):
				say(Friends.FRIEND_TXT8)
			elif client.add_friend(name):
				say("Đã gửi kết bạn tới %s." % name)
			_hide_view()
		"master":
			var uuid: String = str(_viewing.get("szCharUuid", ""))
			if not uuid.is_empty() and uuid != "0":
				client.master_send(709, MasterModel.apply_relation(uuid, MasterModel.MAT_ENGAGE_MASTER))
		"chat":
			if int(client.character.get("level", 0)) < Friends.PM_LEVEL:
				say("Đạt lv10 được PM")
				return
			_hide_view()
			whisper.emit(name)
		"copy":
			DisplayServer.clipboard_set(name)
			_hide_view()
		"black":
			client.add_black(name)
			_hide_view()
		"guild":
			var mine: String = client.guild_self_uuid()
			var boss: bool = not mine.is_empty() and mine in [str(client.guild.get("leaderUuid", "")), str(client.guild.get("viceLeaderUuid", ""))]
			if (int(client.guild.get("iSettingBit", 0)) & Friends.GUILD_OP_MEMBER_INVITE) == 0 and not boss:
				say(Friends.TIP_680)
			elif client.guild_invite(str(_viewing.get("szCharUuid", "")), client.guild_self_team):
				say(Friends.CORPS_TEXT28)
		"love":
			var love_acct: int = int(_viewing.get("nAcctId", 0))
			_hide_view()
			preload("love_ask.gd").open_for(self, "invite", name, love_acct)
		"gm":
			if not _is_self(name):
				preload("gm_option.gd").open_for(self, name)
		"watch":
			var uuid: String = str(_viewing.get("szCharUuid", ""))
			_hide_view()
			_ask_profile(uuid)
		"watch_battle":
			var reply: Dictionary = _view_state()
			var look_oid: int = int(_viewing.get("nAcctId", 0))
			_hide_view()
			if int(reply.get("m_nState", 0)) == Friends.PS_BATTLE:
				var text: String = client.look_scene_oid(int(reply.get("m_nSceneId", 0)), look_oid)
				if not text.is_empty():
					say(text)
		"enter_room":
			var reply: Dictionary = _view_state()
			_hide_view()
			if int(reply.get("m_nState", 0)) == Friends.PS_ROOM:
				var text: String = client.join_friend_room(int(reply.get("m_nRoomId", 0)), int(reply.get("m_nRoomType", 0)))
				if not text.is_empty():
					say(text)




func _ask_profile(uuid: String) -> void :
	if uuid.is_empty() or uuid == "0":
		say("Chưa xem được hồ sơ người chơi này.")
		return
	if has_signal(&"player_info_asked") and not get_signal_connection_list(&"player_info_asked").is_empty():
		emit_signal(&"player_info_asked", uuid)
		return
	var parent: Node = get_parent()
	if parent == null:
		return
	for node: Node in parent.get_children():
		var script: Script = node.get_script() as Script
		if script != null and script.resource_path.ends_with("ui/player_info.gd") and node.has_method("open"):
			node.call("open", uuid)
			return

func _is_self(name: String) -> bool:
	return not name.is_empty() and name == str(client.character.get("name", ""))

func _is_friend(name: String) -> bool:
	for friend: Variant in client.friends.values():
		if friend is Dictionary and str(friend.get("m_name", "")) == name:
			return true
	return false


func _invite(name: String) -> void :
	if client.invite_friend(name):
		say("Đang mời %s…" % name)

func _notification(what: int) -> void :
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		_social = SocialMenu.new()




func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and not _viewing.is_empty() and not _view_rect.has_point(event.position):
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_hide_view()
		elif event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var keep: Dictionary = _viewing
			_viewing = {}
			super (event)
			_viewing = keep
			return
	super (event)


func _draw() -> void :
	super ()
	if _hover.begins_with("who:"):
		mouse_default_cursor_shape = CURSOR_ARROW

func _input(event: InputEvent) -> void :
	if is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE and _escape():
		get_viewport().set_input_as_handled()


func _escape() -> bool:
	if _viewing.is_empty():
		return false
	_hide_view()
	return true


func _shared(id: String) -> bool:
	if _social.activate(id):
		return true
	match id:
		"social:mail":
			page_asked.emit("mail")
			return true
		"social:master":
			master_asked.emit()
			return true
		"social:rep":
			reputation_asked.emit()
			return true
		"social:history":
			history_asked.emit()
			return true
	if id.begins_with("chan:"):
		_chat_tab = id.substr(5)
		return true
	if id.begins_with("see:") or id.begins_with("who:"):

		var people: Array = client.players(_tab)
		var index: int = int(id.substr(4))
		if index >= 0 and index < people.size():
			_open_view(people[index])
		return true
	if id.begins_with("po:"):
		_view_action(id.substr(3))
		return true
	if id.begins_with("invite:"):
		var people: Array = client.players(_tab)
		var index: int = int(id.substr(7))
		if index >= 0 and index < people.size():
			_invite(str(people[index].get("szName", "")))
		return true
	if id == "nav:talent":
		var why: String = LobbyBar.talent_block(client)
		if why.is_empty():
			talent_asked.emit(LobbyBar.talent_tank(client))
		else:
			say(why)
		return true
	if PAGES.has(id):
		page_asked.emit(str(PAGES[id]))
		return true
	match id:
		"list:up":
			_scroll(-1)
		"list:down":
			_scroll(1)
		"list:guild", "list:friend", "list:room":
			_tab = id.substr(5)
			_list_first = 0
			_pending = true
		"chat":
			chat_asked.emit()
		"sheet:dm":
			var name: String = str(_viewing.get("szName", ""))
			_viewing = {}
			whisper.emit(name)
		"sheet:friend":
			var name: String = str(_viewing.get("szName", ""))
			_viewing = {}
			if _is_friend(name):
				say("%s đã là bạn bè." % name)
			elif client.add_friend(name):
				say("Đã gửi kết bạn tới %s." % name)
		"sheet:invite":
			var name: String = str(_viewing.get("szName", ""))
			_viewing = {}
			_invite(name)
		"cancel":
			if not _escape():
				return false
		_:
			return false
	return true
