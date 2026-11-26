extends "flash_screen.gd"











const Atlas = preload("friends_atlas.gd")
const Love = preload("love.gd")
const MasterModel = preload("master_model.gd")

signal closed
signal whisper(name: String)
signal player_info_asked(uuid: String)

const TABS: Array = [["friends", "Bạn bè"], ["apply", "Lời mời"], ["love", "Người Yêu"], ["master", "Sư Đồ"], ["black", "Sổ đen"]]
const TAB_X: Array = [[12.0, 54.0], [70.0, 58.0], [132.0, 72.0], [208.0, 50.0], [262.0, 50.0]]
const TAB_PAD: float = 6.0
const TAB_FONT: float = 12.0
const TAB_GAP: float = 2.0
const HOME: float = 626.0
const TOP: float = 8.0
const FRAME_SIZE: Vector2 = Vector2(324, 584)
const TAB_Y: float = 66.0
const TAB_H: float = 30.0
const SEARCH_Y: float = 104.0
const SEARCH_H: float = 30.0
const LIST_Y: float = 144.0
const LIST_W: float = 288.0
const ROW: float = 56.0
const SHOWN: int = 7
const FRIEND_LIMIT: int = 200
const ASK_SIZE: Vector2 = Vector2(340, 156)
const MENU_W: float = 180.0
const MENU_TIME: float = 3.0
const GRADUATE_LEVEL: int = 18
const PM_LEVEL: int = 10
const LINK: Color = Color("086da5")
const LINK_OFF: Color = Color("aab3b3")
const LINK_ROLL: Color = Color("00adef")
const CARD: Color = Color("0a2448")
const CARD_EDGE: Color = Color(0.25, 0.69, 0.96, 0.22)
const ONLINE: Color = Color("4fe08a")
const BADGE: Color = Color("ff4a4a")
const GUILD_OP_MEMBER_INVITE: int = 1 << 2
const PS_ROOM: int = 2
const PS_BATTLE: int = 4
const STATE_LABEL_W: float = 156.0
const TIP_680: String = "Trưởng Guild chưa mở quyền này"
const CORPS_TEXT28: String = "Thông tin mời đã gửi, chờ đối phương trả lời"
const TIP_428: String = "Nhập nick người chơi"
const TIP_436: String = "Đang trong sổ đen"
const FRIEND_TXT8: String = "Người chơi này nằm trong sổ đen, không thể thêm bạn bè"
const HINTS: Dictionary = {"friends": "Nhập tên để tìm / kết bạn", "apply": "Tìm trong lời mời", "master": "Tìm trong Sư Đồ", 
	"black": "Nhập tên để chặn"}
const EMPTY: Dictionary = {"friends": "Chưa có bạn bè. Nhập tên rồi bấm Kết bạn.", "apply": "Chưa có lời mời kết bạn nào.", 
	"master": "Chưa có Sư phụ / Đồ đệ.", "black": "Sổ đen trống."}

var _tab: String = "friends"
var _pick: String = ""
var _doomed: String = ""
var _doomed_name: String = ""
var _doomed_bl: bool = false
var _want: String = ""
var _want_new: bool = false
var _sheet_id: String = ""
var _asked: String = ""
var _search: LineEdit
var _focus: LineEdit
var _first: int = 0
var _off: Vector2 = Vector2.ZERO
var _grab: String = ""
var _grab_at: Vector2 = Vector2.ZERO
var _grab_off: Vector2 = Vector2.ZERO
var _grab_first: int = 0
var _click_at: Vector2 = Vector2.ZERO
var _menu_uuid: String = ""
var _menu_name: String = ""
var _menu_at: Vector2 = Vector2.ZERO
var _menu_hide_at: float = -1.0
var _menu_mp: bool = false
var _menu_bl: bool = false
var _menu_ap: bool = false
var _frame_rect: Rect2 = Rect2()
var _menu_rect: Rect2 = Rect2()
var _list_rect: Rect2 = Rect2()
var _search_rect: Rect2 = Rect2()

func chat_busy() -> bool:
	return not _sheet_id.is_empty() or (_search != null and _search.has_focus())

func _setup() -> void :
	_search = _name_fedit()
	_search.add_theme_color_override("font_placeholder_color", Color(MUTED, 0.7))
	_search.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_hide_menu())
	_search.text_changed.connect( func(_text: String) -> void :
		_first = 0)
	_search.text_submitted.connect( func(_text: String) -> void :
		_activate("black" if _tab == "black" else ("add" if _tab != "master" else "")))
	if client != null:
		client.friend_result.connect(_on_result)
		client.noticed.connect( func(text: String) -> void :
			if is_visible_in_tree():
				say(text))


func _shown() -> void :
	_close()
	_hide_menu()
	_grab = ""
	if _search != null:
		_search.text = ""
	_off = Vector2.ZERO
	_want = ""
	if client != null:
		_set_tab("apply" if not client.friend_applies.is_empty() else "friends")
	if is_visible_in_tree() and client != null:
		client.refresh_friends()
		client.request_applies()
		Love.want_state(client, true)

func _set_tab(key: String) -> void :
	_tab = key
	_first = 0
	_pick = ""
	_hide_menu()
	if _search != null:
		_search.placeholder_text = str(HINTS.get(key, "Nhập tên để tỏ tình" if key == "love" else ""))

func _close() -> void :
	_sheet_id = ""
	_doomed = ""
	_doomed_name = ""
	_doomed_bl = false
	_focus = null



func _send_add(text: String) -> void :
	var who: String = text.strip_edges()
	if who.is_empty():
		say(TIP_428)
		return
	if who == str(client.character.get("name", "")):
		say("Không thể tự kết bạn với mình.")
		return
	if client.is_black_name(who):
		say(FRIEND_TXT8)
		return
	if client.add_friend(who):
		_asked = who
	elif client.friend_busy():
		say("Đang chờ kết quả lần trước…")
	else:
		say("Chưa gửi được, thử lại sau.")


func _send_black(text: String) -> void :
	var who: String = text.strip_edges()
	if who.is_empty():
		say(TIP_428)
	elif client.is_black_name(who):
		say(TIP_436)
	elif client.add_black(who):
		_search.text = ""

func _on_result(ok: bool, text: String) -> void :
	if _asked.is_empty():
		return
	var who: String = _asked
	_asked = ""
	if ok:
		_want = who
		_want_new = not _is_friend(who)
		if _search != null and _search.text.strip_edges() == who:
			_search.text = ""
		if is_visible_in_tree():
			say("Đã gửi lời mời kết bạn tới %s." % who)
	elif is_visible_in_tree():
		say(text)

func _is_friend(who: String) -> bool:
	for brief: Dictionary in client.friends.values():
		if str(brief.get("m_name", "")) == who:
			return true
	return false

func _apply_brief(uuid: String) -> Dictionary:
	for info: Dictionary in client.friend_applies:
		if str(info.get("m_charUuid", "")) == uuid:
			return info
	return {}




func _guild_invitable(uuid: String, me: bool) -> bool:
	if me or uuid.is_empty() or int(client.guild.get("nGuildId", 0)) <= 0 or client.guild_members.has(uuid):
		return false
	var reply: Dictionary = client.char_states.get(uuid, {})
	if not reply.is_empty():
		return guild_open(reply)
	var account: int = int(client.friends.get(uuid, {}).get("m_accountId", 0))
	for member: Dictionary in client.guild_members.values():
		if account > 0 and int(member.get("nAcctId", 0)) == account:
			return false
	return true




func _invite_guild() -> void :
	if not _guild_invitable(_menu_uuid, _menu_name == str(client.character.get("name", ""))):
		return
	var mine: String = client.guild_self_uuid()
	var boss: bool = not mine.is_empty() and mine in [str(client.guild.get("leaderUuid", "")), str(client.guild.get("viceLeaderUuid", ""))]
	if (int(client.guild.get("iSettingBit", 0)) & GUILD_OP_MEMBER_INVITE) == 0 and not boss:
		say(TIP_680)
	elif client.guild_invite(_menu_uuid, client.guild_self_team):
		say(CORPS_TEXT28)



func _sorted(word: String, from: Variant = null) -> Array:
	var rows: Array = []
	var index: int = 0
	for brief: Dictionary in (client.friends if from == null else from as Dictionary).values():
		index += 1
		if brief.is_empty() or not _match(brief, word):
			continue
		rows.append([0 if int(brief.get("m_online", 0)) != 0 else 1, - int(brief.get("m_level", 0)), index, brief])
	rows.sort_custom( func(a: Array, b: Array) -> bool:
		for i in range(3):
			if a[i] != b[i]:
				return a[i] < b[i]
		return false)
	return rows.map( func(row: Array) -> Dictionary: return row[3])

func _match(brief: Dictionary, word: String) -> bool:
	return word.strip_edges().is_empty() or str(brief.get("m_name", "")).findn(word.strip_edges()) >= 0

func _word() -> String:
	return _search.text if _search != null else ""


func _rows() -> Array:
	return _sorted(_word())


func _list() -> Array:
	var word: String = _word()
	match _tab:
		"apply":
			return client.friend_applies.filter( func(info: Dictionary) -> bool: return _match(info, word))
		"master":
			return _mp_rows().filter( func(brief: Dictionary) -> bool: return _match(brief, word))
		"black":
			return _sorted(word, client.blacks)
		"love":
			return []
	return _sorted(word)

func _row_id(brief: Dictionary) -> String:
	var prefix: String = {"apply": "arow:", "master": "mrow:", "black": "brow:"}.get(_tab, "row:")
	return prefix + str(brief.get("m_charUuid", ""))

func _shown_rows() -> int:
	return SHOWN - 1 if _tab == "apply" else SHOWN

func _index(rows: Array, uuid: String) -> int:
	for i in range(rows.size()):
		if str(rows[i].get("m_charUuid", "")) == uuid:
			return i
	return -1


func _mp_rows() -> Array:
	if client == null or not ("master" in client) or client.master == null:
		return []
	return client.master.relation_list().filter( func(brief: Dictionary) -> bool: return not str(brief.get("m_charUuid", "")).is_empty())

func _mp_brief(uuid: String) -> Dictionary:
	for brief: Dictionary in _mp_rows():
		if str(brief.get("m_charUuid", "")) == uuid:
			return brief
	return {}


func _has_master() -> bool:
	return client != null and ("master" in client) and client.master != null and client.master.have_master()

func _most() -> int:
	if _tab == "love":
		return _love_most()
	return maxi(0, _list().size() - _shown_rows())

func _scroll(delta: int) -> void :
	_first = clampi(_first + delta, 0, _most())

func _reveal(line: int) -> void :
	if line < _first:
		_first = line
	elif line >= _first + _shown_rows():
		_first = line - _shown_rows() + 1


func _step(delta: int) -> void :
	var rows: Array = _list()
	if rows.is_empty():
		return
	var at: int = _index(rows, _pick)
	var next: int = clampi(at + delta, 0, rows.size() - 1) if at >= 0 else (0 if delta > 0 else rows.size() - 1)
	_pick = str(rows[next].get("m_charUuid", ""))
	_reveal(next)

static func presence(brief: Dictionary, now: int) -> String:
	if int(brief.get("m_online", 0)) != 0:
		return "Trực tuyến"
	var seen: int = int(brief.get("m_lastLoginTime", 0))
	if seen <= 0 or now < seen:
		return "Ngoại tuyến"
	var minutes: int = (now - seen) / 60
	if minutes < 1:
		return "Vừa xong"
	if minutes < 60:
		return "%d phút trước" % minutes
	if minutes < 1440:
		return "%d giờ trước" % (minutes / 60)
	if minutes < 43200:
		return "%d ngày trước" % (minutes / 1440)
	return "%d tháng trước" % (minutes / 43200)




func _menu_high() -> float:
	return (314.0 if client != null and int(client.character.get("level", 0)) < GRADUATE_LEVEL and not _has_master() else 288.0)\
	+ Love.menu_extra(client)


func _show_menu(uuid: String, who: String, at: Vector2) -> void :
	var high: float = _menu_high()
	_menu_mp = false
	_menu_bl = false
	_menu_ap = false
	_menu_uuid = uuid
	_menu_name = who
	_menu_at = Vector2(clampf(at.x, 0.0, 1000.0 - MENU_W), clampf(at.y, 0.0, 600.0 - high))
	_menu_rect = Rect2((_stage() + _menu_at) * _f, Vector2(MENU_W, high) * _f)
	_menu_hide_at = _time + MENU_TIME


func _open_menu(uuid: String, who: String, at: Vector2) -> void :
	_show_menu(uuid, who, at)
	client.request_char_state(uuid)



static func state_lines(reply: Dictionary) -> Array:
	if reply.is_empty():
		return ["", ""]
	if int(reply.get("m_nGuildId", 0)) != 0:
		return ["Guild: %s(%d lv)" % [str(reply.get("m_szGuildName", "")), int(reply.get("m_nGuildLevel", 0))], 
			"Team: %s(%dlv)" % [str(reply.get("m_szTeamName", "")), int(reply.get("m_nTeamLevel", 0))]]
	return ["Guild: không", "Team: không"]



static func state_item(prefix: String, reply: Dictionary) -> Array:
	var state: int = int(reply.get("m_nState", 0))
	if state == PS_ROOM:
		return [prefix + "enter_room", "Vào room", true]
	return [prefix + "watch_battle", "Quan sát", state == PS_BATTLE]


static func guild_open(reply: Dictionary) -> bool:
	return int(reply.get("m_nGuildId", 0)) == 0


func _label_cut(text: String, px: float, wide: float) -> String:
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(px * _f))
	var room: float = (wide - 4.0) * _f
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x <= room:
		return text
	var keep: String = text
	var dots: float = font.get_string_size("...", HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	while not keep.is_empty() and font.get_string_size(keep, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x + dots > room:
		keep = keep.left(-1)
	return keep + "..."

func _hide_menu() -> void :
	_menu_uuid = ""
	_menu_name = ""
	_menu_hide_at = -1.0
	_menu_rect = Rect2()
	_menu_mp = false
	_menu_bl = false
	_menu_ap = false




func _fround(rect: Rect2, fill: Color, radius: float, edge: Color = Color(0, 0, 0, 0), width: float = 0.0) -> void :
	_round(Rect2(rect.position * _f, rect.size * _f), fill, radius * 2.0, edge, width * 2.0)


func _fgrad(rect: Rect2, top: Color, bottom: Color, edge: Color, radius: float, border: float = 1.0) -> void :
	_grad(Rect2(rect.position * _f, rect.size * _f), top, bottom, edge, radius * 2.0, border * 2.0)


func _fbtn(id: String, text: String, rect: Rect2, style: String = "blue", on: bool = true, px: float = 13.0) -> void :
	var tones: Dictionary = {"blue": [BTN_TOP, BTN_LOW, BTN_EDGE], "gold": [GOLD_TOP, GOLD_LOW, BTN_GOLD_EDGE], 
		"green": [Color("46d483"), Color("15804a"), Color("bff7d6")], "gray": [Color("53657d"), Color("2c3a4e"), Color(1, 1, 1, 0.28)]}
	var tone: Array = tones.get(style, tones["blue"])
	var ink: Color = Color.WHITE
	if not on:
		_fround(rect, Color("1a2c45", 0.9), 6.0, Color(1, 1, 1, 0.12), 1.0)
		ink = Color(MUTED, 0.5)
	else:
		var lit: float = _shine(id)
		var top: Color = tone[0]
		var low: Color = tone[1]
		if lit > 1.0:
			top = top.lightened(0.14)
			low = low.lightened(0.14)
		elif lit < 1.0:
			top = top.darkened(0.18)
			low = low.darkened(0.18)
		_fgrad(rect, top, low, Color(tone[2], 0.9), 6.0, 1.0)
		_fround(Rect2(rect.position + Vector2(2, 2), Vector2(rect.size.x - 4.0, rect.size.y * 0.45)), Color(1, 1, 1, 0.1), 4.0)
	_fwords(text, ARIAL_BOLD, px, ink, "c", rect.position + Vector2(3, 0), rect.size.x - 6.0, 1.0 if on else 0.0, rect.size.y, true, Color(0, 0, 0, 0.35))
	if on:
		_hit(id, Rect2(rect.position * _f, rect.size * _f), false)


func _face_at(avatar_id: int, rect: Rect2, dim: bool) -> void :
	var r: Rect2 = Rect2(rect.position * _f, rect.size * _f)
	_round(r, Color("16304a"), rect.size.x, Color(1, 1, 1, 0.25), 2.0)
	var key: String = str(pack.lobby.get("avatars", {}).get(str(avatar_id), ""))
	var av_pic: Texture2D = pack.picture("l/av/%s.webp" % key) if not key.is_empty() else null
	if av_pic != null and av_pic.get_width() > 10:
		var crop_w: float = minf(float(av_pic.get_width()) * 0.78, 140.0)
		var crop_x: float = (float(av_pic.get_width()) - crop_w) / 2.0
		var src_rect: Rect2 = Rect2(crop_x, 0.0, crop_w, crop_w)
		draw_texture_rect_region(av_pic, r.grow(-1.5 * _f), src_rect, Color(0.55, 0.55, 0.6) if dim else Color.WHITE)
	else:
		var head: Texture2D = pack.picture("l/h/%s.webp" % key) if not key.is_empty() else null
		if head != null:
			draw_texture_rect(head, r.grow(-1.5 * _f), false, Color(0.55, 0.55, 0.6) if dim else Color.WHITE)
		else:
			_silhouette(r.get_center(), r.size.x, Color(MUTED, 0.55))

func _stow(edit: LineEdit) -> void :
	if edit != null and edit.visible:
		edit.visible = false
		edit.release_focus()

func _over(a: Rect2, b: Rect2) -> bool:
	return a.has_area() and b.has_area() and a.intersects(b)

func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	var base: Vector2 = _stage() + Vector2(HOME, TOP) + _off
	var modal: bool = _sheet_id == "remove"
	var high: float = _menu_high()
	_frame_rect = Rect2(base * _f, FRAME_SIZE * _f)
	_menu_rect = Rect2((_stage() + _menu_at) * _f, Vector2(MENU_W, high) * _f) if not _menu_uuid.is_empty() else Rect2()
	var with_button: bool = _tab != "master"
	var search_box: Rect2 = Rect2(base + Vector2(34, SEARCH_Y), Vector2((184.0 if with_button else 270.0), SEARCH_H))
	_search_rect = Rect2(search_box.position * _f, search_box.size * _f)
	var search_free: bool = not modal and not _over(_search_rect, _menu_rect)
	_scene()
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_hit("panel", _frame_rect, false)
	_paint_frame(base)
	_paint_tabs(base)
	_paint_search(base, with_button)
	if not search_free:
		var shown: String = _search.text if not _search.text.is_empty() else _search.placeholder_text
		_fwords(shown, ARIAL_BOLD, 13, Color.WHITE if not _search.text.is_empty() else Color(MUTED, 0.7), "l", search_box.position, search_box.size.x, 0.0, search_box.size.y)
	_paint_list(base)
	_paint_foot(base)
	if not _menu_uuid.is_empty():
		_paint_menu(_stage() + _menu_at, high)
	if modal:
		_paint_ask()
	if search_free:
		_fput(_search, search_box, 13)
	else:
		_stow(_search)
	if _focus != null and _focus.visible:
		_focus.grab_focus.call_deferred()
		_focus = null


func _paint_frame(base: Vector2) -> void :
	_fgrad(Rect2(base, FRAME_SIZE), Color("0d2f5c", 0.95), Color("061a36", 0.97), Color(GLASS_EDGE, 0.55), 10.0, 1.0)
	_fround(Rect2(base + Vector2(1, 1), Vector2(FRAME_SIZE.x - 2.0, 58)), Color(1, 1, 1, 0.04), 9.0)
	_face_at(int(client.character.get("avatarId", 0)), Rect2(base + Vector2(12, 9), Vector2(44, 44)), false)
	_fwords(str(client.character.get("name", "")), ARIAL_BOLD, 16, Color.WHITE, "l", base + Vector2(66, 10), 200, 1.0, 0.0, true, Color(0, 0, 0, 0.5))
	_fwords("Cấp %d" % int(client.character.get("level", 0)), ARIAL_BOLD, 12, GOLD, "l", base + Vector2(66, 33), 120, 0.0, 0.0)
	draw_line((base + Vector2(10, 60)) * _f, (base + Vector2(FRAME_SIZE.x - 10.0, 60)) * _f, Color(GLASS_EDGE, 0.25), maxf(1.0, _f * 0.6))
	var close: Rect2 = Rect2(base + Vector2(288, 14), Vector2(24, 24))
	var lit: float = _shine("back")
	_fround(close, Color(1, 1, 1, 0.08 * lit), 12.0, Color(1, 1, 1, 0.25 * lit), 1.0)
	var c: Vector2 = close.get_center() * _f
	var s: float = 5.0 * _f
	draw_line(c + Vector2( - s, - s), c + Vector2(s, s), Color(1, 1, 1, 0.9), maxf(1.5, 1.6 * _f), true)
	draw_line(c + Vector2( - s, s), c + Vector2(s, - s), Color(1, 1, 1, 0.9), maxf(1.5, 1.6 * _f), true)
	_hit("back", Rect2(close.position * _f, close.size * _f).grow(3.0 * _f), false)


func _paint_tabs(base: Vector2) -> void :
	var love_tabs: Array = _love_tab_rects(base)
	for i in range(TABS.size()):
		var key: String = str(TABS[i][0])
		var rect: Rect2 = love_tabs[i]
		var id: String = "tab:" + key
		var chosen: bool = _tab == key
		var label: String = str(TABS[i][1])

		if chosen:
			_fgrad(rect, GOLD_TOP, GOLD_LOW, BTN_GOLD_EDGE, 6.0, 1.0)
		else:
			var lit: bool = _hover == id
			_fgrad(rect, TAB_TOP.lightened(0.12) if lit else TAB_TOP, TAB_LOW.lightened(0.1) if lit else TAB_LOW, Color(BTN_EDGE, 0.8 if lit else 0.45), 6.0, 1.0)
		_fwords(label, ARIAL_BOLD, TAB_FONT, Color.WHITE, "c", rect.position + Vector2(TAB_PAD, 0), rect.size.x - 2.0 * TAB_PAD, 1.0, rect.size.y, true, Color(0, 0, 0, 0.35))
		_hit(id, Rect2(rect.position * _f, rect.size * _f), false)
		if key == "apply" or key == "love":
			var count: int = maxi(client.friend_apply_count, client.friend_applies.size()) if key == "apply" else Love.incoming_count()
			if count > 0:
				var dot: Vector2 = (rect.position + Vector2(rect.size.x - 4.0, 2.0)) * _f
				var r: float = 8.0 * _f
				draw_circle(dot, r, Color.WHITE)
				draw_circle(dot, r - maxf(1.0, _f), BADGE)
				_fwords(str(mini(count, 99)), ARIAL_BOLD, 10, Color.WHITE, "c", dot / _f - Vector2(8, 8), 16, 0.0, 16)


func _paint_search(base: Vector2, with_button: bool) -> void :
	var box: Rect2 = Rect2(base + Vector2(12, SEARCH_Y), Vector2((210.0 if with_button else 300.0), SEARCH_H))
	_fround(box, Color("041226", 0.85), 6.0, Color(GLASS_EDGE, 0.45 if _search == null or not _search.has_focus() else 0.9), 1.0)
	var lens: Vector2 = (box.position + Vector2(13, 14)) * _f
	draw_arc(lens, 5.0 * _f, 0.0, TAU, 20, Color(MUTED, 0.8), maxf(1.0, 1.4 * _f), true)
	draw_line(lens + Vector2(3.6, 3.6) * _f, lens + Vector2(7.5, 7.5) * _f, Color(MUTED, 0.8), maxf(1.0, 1.6 * _f), true)
	if not with_button:
		return
	var at: Rect2 = Rect2(base + Vector2(228, SEARCH_Y), Vector2(84, SEARCH_H))
	if _tab == "black":
		_fbtn("black", "Chặn", at, "gray")
	elif _tab == "love":
		_fbtn("add", "Tỏ tình", at, "blue", Love.can_invite(client, 0, false))
	else:
		_fbtn("add", "Kết bạn", at, "blue")


func _paint_list(base: Vector2) -> void :
	if _tab == "love":
		_paint_love(base)
		return
	var rows: Array = _list()
	var shown: int = _shown_rows()
	var at: Vector2 = base + Vector2(12, LIST_Y)
	_list_rect = Rect2(at * _f, Vector2(LIST_W + 12.0, ROW * float(shown)) * _f)
	var most: int = maxi(0, rows.size() - shown)
	_first = clampi(_first, 0, most)
	if rows.is_empty():
		var text: String = str(EMPTY.get(_tab, ""))
		if not _word().strip_edges().is_empty():
			text = "Không thấy \"%s\". Bấm Kết bạn để gửi lời mời." % _word().strip_edges() if _tab in ["friends", "apply"] else "Không có tên phù hợp."
		_fwords(text, ARIAL_BOLD, 13, Color(MUTED, 0.85), "c", at + Vector2(0, 40), LIST_W, 0.0, 24.0)
		return
	var now: int = int(Time.get_unix_time_from_system())
	for i in range(_first, mini(rows.size(), _first + shown)):
		_paint_row(rows[i], at + Vector2(0, ROW * float(i - _first)), now)
	if most > 0:
		var track: Rect2 = Rect2(base + Vector2(305, LIST_Y + 2.0), Vector2(5, ROW * float(shown) - 4.0))
		_fround(track, Color(0, 0, 0, 0.35), 2.5)
		var thumb: float = maxf(24.0, track.size.y * float(shown) / float(rows.size()))
		var top: float = track.position.y + (track.size.y - thumb) * float(_first) / float(most)
		_fround(Rect2(Vector2(track.position.x, top), Vector2(5, thumb)), Color(GLASS_EDGE, 0.75 * _shine("slide:tree")), 2.5)
		_hit("slide:tree", Rect2(Vector2(track.position.x - 5.0, top) * _f, Vector2(15, thumb) * _f), false)


func _paint_row(brief: Dictionary, at: Vector2, now: int) -> void :
	var uuid: String = str(brief.get("m_charUuid", ""))
	var id: String = _row_id(brief)
	var card: Rect2 = Rect2(at + Vector2(0, 2), Vector2(LIST_W, ROW - 4.0))
	var picked: bool = uuid == _pick or ( not _menu_uuid.is_empty() and uuid == _menu_uuid)
	if picked:
		_fgrad(card, Color("1b5aa3", 0.9), Color("103d78", 0.9), Color(GLASS_EDGE, 0.9), 8.0, 1.0)
	else:
		_fround(card, CARD.lightened(0.08) if _hover == id else CARD, 8.0, CARD_EDGE, 1.0)
	_hit(id, Rect2(card.position * _f, card.size * _f), false)
	var asking: bool = _tab == "apply"
	var online: bool = int(brief.get("m_online", 0)) != 0
	_face_at(int(brief.get("m_avatarId", 0)), Rect2(at + Vector2(7, 8), Vector2(40, 40)), not asking and not online)
	if not asking:
		var dot: Vector2 = (at + Vector2(43, 44)) * _f
		draw_circle(dot, 4.5 * _f, Color("061a36"))
		draw_circle(dot, 3.2 * _f, ONLINE if online else Color("6d7d92"))
	var name_w: float = {"apply": 104.0, "black": 148.0, "master": 216.0}.get(_tab, 166.0)
	var love_on: bool = Love.near(client, int(brief.get("m_accountId", 0)))
	var love_used: float = _fwords(str(brief.get("m_name", "")), ARIAL_BOLD, 14, Color.WHITE, "l", at + Vector2(56, 8), name_w - (18.0 if love_on else 0.0), 1.0, 0.0, true, Color(0, 0, 0, 0.45))
	if love_on:
		Love.fdraw(self, at + Vector2(56.0 + love_used + Love.NAME_GAP, 11.0), Love.SIDE)
	var level: String = "Cấp %d" % int(brief.get("m_level", 0))
	var sub: String
	var ink: Color = MUTED
	if asking:
		sub = level
	else:
		sub = "%s · %s" % [level, presence(brief, now)]
		if online:
			ink = ONLINE
	_fwords(sub, ARIAL_BOLD, 11, ink, "l", at + Vector2(56, 30), name_w + 10.0, 0.0, 0.0)
	match _tab:
		"apply":
			_fbtn("accept:" + uuid, "Chấp nhận", Rect2(at + Vector2(166, 14), Vector2(64, 28)), "green", true, 12.0)
			_fbtn("reject:" + uuid, "Từ chối", Rect2(at + Vector2(234, 14), Vector2(50, 28)), "gray", true, 12.0)
		"friends":
			_fbtn("chat:" + uuid, "Nhắn", Rect2(at + Vector2(234, 15), Vector2(50, 26)), "blue", true, 12.0)
		"black":
			_fbtn("unblock:" + uuid, "Bỏ chặn", Rect2(at + Vector2(218, 15), Vector2(66, 26)), "gray", true, 12.0)


func _paint_foot(base: Vector2) -> void :
	if _tab == "apply":
		var any: bool = not client.friend_applies.is_empty()
		var y: float = LIST_Y + ROW * float(SHOWN - 1) + 10.0
		_fbtn("reject_all", "Từ chối tất cả", Rect2(base + Vector2(12, y), Vector2(110, 36)), "gray", any, 13.0)
		_fbtn("accept_all", "Chấp nhận tất cả", Rect2(base + Vector2(128, y), Vector2(184, 36)), "blue", any, 15.0)
		_fwords("Chấp nhận thì cả hai cùng thành bạn bè.", ARIAL_BOLD, 11, Color(MUTED, 0.75), "c", base + Vector2(12, y + 44.0), 300, 0.0, 16.0)
	elif _tab == "love":
		_paint_love_foot(base)
	elif _tab == "friends":
		var online: int = 0
		for brief: Dictionary in client.friends.values():
			if int(brief.get("m_online", 0)) != 0:
				online += 1
		_fwords("Bạn bè: %d/%d · Trực tuyến: %d" % [client.friends.size(), FRIEND_LIMIT, online], ARIAL_BOLD, 12, Color(MUTED, 0.85), "l", base + Vector2(14, LIST_Y + ROW * float(SHOWN) + 8.0), 290, 0.0, 16.0)


func _paint_menu(at: Vector2, high: float) -> void :
	_hit("panel", _menu_rect, false)
	_fround(Rect2(at, Vector2(MENU_W, high)), Color("e9f9ff", 0.98), 10.0, Color.WHITE, 2.0)
	_fwords(_menu_name, ARIAL_BOLD, 16, Color("f16422"), "l", at + Vector2(10, 5), 160)
	var reply: Dictionary = client.char_states.get(_menu_uuid, {})
	var lines: Array = state_lines(reply)
	for i in range(2):
		if not str(lines[i]).is_empty():
			_fwords(_label_cut(str(lines[i]), 14.0, STATE_LABEL_W), ARIAL_BOLD, 14, LINK, "l", at + Vector2(10, 30 + 20 * i), STATE_LABEL_W, 0.0, 0.0, false)
	_fblit("fr_cutline", at + Vector2(8, 75), 0.0, 0.0, Color(1, 1, 1, 0.8))
	var me: bool = _menu_name == str(client.character.get("name", ""))
	var items: Array = [["menu:add", "Thêm bạn bè", not me and not _is_friend(_menu_name)]]
	if high - Love.menu_extra(client) > 300.0:
		items.append(["menu:master", "Bái làm Sư Phụ", not me])
	if Love.shown(client):
		items.append(["menu:love", "Tỏ tình", Love.can_invite(client, _menu_acct(), me)])
	items.append_array([["menu:chat", "Chat riêng", not me], ["menu:copy", "Copy tên gọi", true], ["menu:black", "Thêm vào sổ đen", not me and not client.is_black_name(_menu_name)], 
		["menu:guild", "Mời vào Guild", _guild_invitable(_menu_uuid, me)], ["menu:delete", "Xóa", not _menu_mp and not _menu_ap], state_item("menu:", reply)])
	if int(client.character.get("gm_level", 0)) > 0:
		items.append(["menu:gm", "Thao tác GM", true])
	var font_size: int = maxi(6, roundi(14.0 * _f))
	var y: float = 76.0
	for item: Array in items:
		var id: String = str(item[0])
		var label: String = str(item[1])
		var on: bool = bool(item[2])
		var wide: float = ARIAL_BOLD.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f + 5.0
		var cell: Rect2 = Rect2(at + Vector2(2, y), Vector2(wide, 20))
		var ink: Color = LINK if on else LINK_OFF
		if on and _hover == id:
			_fround(cell, LINK_ROLL, 2.0)
			ink = Color.WHITE
		_fwords(label, ARIAL_BOLD, 14, ink, "c", cell.position, cell.size.x, 0.0, 20.0, false)
		if on:
			_hit(id, Rect2(cell.position * _f, cell.size * _f), false)
		y += 20.0
	_fbutton("menu:watch", "fr_watch", at + Vector2(114, high - 29.0))


func _paint_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.45))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(ASK_SIZE.x, ASK_SIZE.y)
	_hit("panel", Rect2(at * _f, ASK_SIZE * _f), false)
	_fgrad(Rect2(at, ASK_SIZE), Color("0d2f5c", 0.98), Color("061a36", 0.98), Color(GLASS_EDGE, 0.7), 10.0, 1.0)
	_fwords("Xác nhận", ARIAL_BOLD, 15, GOLD, "c", at + Vector2(0, 12), ASK_SIZE.x, 0.0, 20.0)
	_fwords("Có xóa %s khỏi %s không" % [_doomed_name, "Sổ đen" if _doomed_bl else "Bạn bè"], ARIAL_BOLD, 14, Color.WHITE, "c", at + Vector2(16, 44), ASK_SIZE.x - 32.0, 0.0, 40.0)
	_fbtn("ask_no", "Hủy", Rect2(at + Vector2(40, 104), Vector2(120, 34)), "gray", true, 14.0)
	_fbtn("ask_ok", "Xác nhận", Rect2(at + Vector2(180, 104), Vector2(120, 34)), "gold", true, 14.0)




func _love_tab_rects(base: Vector2) -> Array:
	var need: Array = []
	var total: float = 0.0
	for i in range(TABS.size()):
		var wide: float = Love.text_w(self, ARIAL_BOLD, str(TABS[i][1]), TAB_FONT) + 2.0 * TAB_PAD
		need.append(wide)
		total += wide
	var room: float = 300.0 - TAB_GAP * float(TABS.size() - 1)
	var spare: float = (room - total) / float(TABS.size())
	var out: Array = []
	var x: float = 12.0
	for i in range(TABS.size()):
		var wide: float = 312.0 - x if i == TABS.size() - 1 else floorf(float(need[i]) + spare if spare >= 0.0 else float(need[i]) * room / total)
		out.append(Rect2(base + Vector2(x, TAB_Y), Vector2(wide, TAB_H)))
		x += wide + TAB_GAP
	return out

const COUPLE_H: float = 150.0


func _love_rows() -> Array:
	if Love.gate == -1:
		return [["text", 60.0, Love.OFF_TEXT]]
	if Love._origin(client) == null:
		return [["text", 60.0, Love.NET_TEXT]]
	if Love.state.is_empty():
		return [["text", 60.0, "Đang tải…"]]
	var rows: Array = []
	var pair: Dictionary = Love.couple()
	rows.append(["couple", COUPLE_H, pair] if not pair.is_empty() else ["hint", 56.0, {}])
	if Love.wed_on() and not pair.is_empty():
		for row: Dictionary in Love.propose_in():
			rows.append(["pin", ROW, row])
		for row: Dictionary in Love.propose_out():
			rows.append(["pout", ROW, row])
	if Love.wed_on() and not Love.invites().is_empty():
		rows.append(["head", 26.0, "Thiệp mời Lễ cưới (%d)" % Love.invites().size()])
		for row: Dictionary in Love.invites():
			rows.append(["wcard", ROW, row])
	var asks: Array = Love.incoming().filter( func(row: Variant) -> bool: return row is Dictionary)
	if not asks.is_empty():
		rows.append(["head", 26.0, "Lời tỏ tình (%d)" % asks.size()])
		for row: Dictionary in asks:
			rows.append(["in", ROW, row])
	var sent: Array = Love.outgoing().filter( func(row: Variant) -> bool: return row is Dictionary)
	if not sent.is_empty():
		rows.append(["head", 26.0, "Đã tỏ tình"])
		for row: Dictionary in sent:
			rows.append(["out", ROW, row])
	if pair.is_empty():
		rows.append(["head", 26.0, "Thân mật với bạn bè"])
		var close: Array = Love.close_list().filter( func(row: Variant) -> bool: return row is Dictionary)
		if close.is_empty():
			rows.append(["text", 40.0, "Đấu chung đội hoặc tặng quà để tăng thân mật."])
		for row: Dictionary in close:
			rows.append(["close", ROW, row])
	if Love.wed_on() and not pair.is_empty() and not Love.rings().is_empty():
		rows.append(["head", 26.0, "Nhẫn cưới" if int(pair.get("state", 1)) == 2 else "Nhẫn cầu hôn · không giao dịch"])
		var rings: Array = Love.rings()
		var used: float = 0.0
		for row: Array in rows:
			used += float(row[1])


		var ring_h: float = 44.0
		if not rings.is_empty() and used + 44.0 * float(rings.size()) <= ROW * float(SHOWN):
			ring_h = clampf(floorf((ROW * float(SHOWN) - used) / float(rings.size())), 44.0, RING_MAX)
		for r: Dictionary in rings:
			rows.append(["ring", ring_h, r])
	return rows

const RING_MAX: float = 68.0


func _love_most() -> int:
	var rows: Array = _love_rows()
	var room: float = ROW * float(SHOWN)
	var used: float = 0.0
	var i: int = rows.size()
	while i > 0 and used + float(rows[i - 1][1]) <= room:
		used += float(rows[i - 1][1])
		i -= 1
	return i

func _paint_love(base: Vector2) -> void :
	var rows: Array = _love_rows()
	var at: Vector2 = base + Vector2(12, LIST_Y)
	var room: float = ROW * float(SHOWN)
	_list_rect = Rect2(at * _f, Vector2(LIST_W + 12.0, room) * _f)
	var most: int = _love_most()
	_first = clampi(_first, 0, most)
	var y: float = 0.0
	for i in range(_first, rows.size()):
		var high: float = float(rows[i][1])
		if y + high > room:
			break
		_paint_love_row(rows[i], at + Vector2(0, y))
		y += high
	if most > 0:
		var track: Rect2 = Rect2(base + Vector2(305, LIST_Y + 2.0), Vector2(5, room - 4.0))
		_fround(track, Color(0, 0, 0, 0.35), 2.5)
		var thumb: float = maxf(24.0, track.size.y * float(rows.size() - most) / float(rows.size()))
		var top: float = track.position.y + (track.size.y - thumb) * float(_first) / float(most)
		_fround(Rect2(Vector2(track.position.x, top), Vector2(5, thumb)), Color(GLASS_EDGE, 0.75), 2.5)


func _paint_love_row(item: Array, at: Vector2) -> void :
	var kind: String = str(item[0])
	var high: float = float(item[1])
	var card: Rect2 = Rect2(at + Vector2(0, 2), Vector2(LIST_W, high - 4.0))
	match kind:
		"text":
			_fwords(str(item[2]), ARIAL_BOLD, 13, Color(MUTED, 0.85), "c", at + Vector2(8, 0), LIST_W - 16.0, 0.0, high)
		"head":
			_fwords(str(item[2]), ARIAL_BOLD, 12, GOLD, "l", at + Vector2(4, 6), LIST_W - 8.0, 0.0, 16.0)
			draw_line((at + Vector2(4, high - 2.0)) * _f, (at + Vector2(LIST_W - 4.0, high - 2.0)) * _f, Color(GLASS_EDGE, 0.22), maxf(1.0, _f * 0.6))
		"hint":
			_fround(card, CARD, 8.0, CARD_EDGE, 1.0)
			Love.draw(self, Rect2((at + Vector2(12, 14)) * _f, Vector2(28, 28) * _f), 0.45, 1.0, 0)
			_fwords("Chưa có Người Yêu.", ARIAL_BOLD, 14, Color.WHITE, "l", at + Vector2(52, 8), 228, 1.0, 0.0, true, Color(0, 0, 0, 0.45))
			_fwords("Đủ %d thân mật với một bạn bè rồi bấm Tỏ tình." % Love.need(), ARIAL_BOLD, 11, MUTED, "l", at + Vector2(52, 30), 228, 0.0, 0.0)
		"couple":
			var pair: Dictionary = item[2]
			_fgrad(card, Color("1b5aa3", 0.9), Color("103d78", 0.9), Color(GLASS_EDGE, 0.9), 8.0, 1.0)
			var brief: Dictionary = _acct_brief(int(pair.get("partnerId", 0)))
			_face_at(int(brief.get("m_avatarId", 0)), Rect2(at + Vector2(8, 12), Vector2(48, 48)), not brief.is_empty() and int(brief.get("m_online", 0)) == 0)
			var used: float = _fwords(str(pair.get("partnerName", "")), ARIAL_BOLD, 14, Color.WHITE, "l", at + Vector2(64, 8), 128, 1.0, 0.0, true, Color(0, 0, 0, 0.45))
			var wed_pair: bool = int(pair.get("state", 1)) == 2
			Love.fdraw(self, at + Vector2(64.0 + used + Love.NAME_GAP, 11.0), Love.SIDE, 1 if wed_pair else 0)
			_fwords(("Vợ Chồng · %d ngày" % maxi(1, int(pair.get("days", 1)))) if wed_pair else Love.days_text(int(pair.get("days", 1))), ARIAL_BOLD, 12, GOLD, "l", at + Vector2(64, 30), 150, 0.0, 0.0)
			_fwords("Thân mật: %d" % int(pair.get("intimacy", 0)), ARIAL_BOLD, 12, Color.WHITE, "l", at + Vector2(64, 48), 150, 0.0, 0.0)

			_fbtn("love:chat", "Nhắn", Rect2(at + Vector2(218, 10), Vector2(62, 26)), "blue", true, 12.0)
			_love_bar(at + Vector2(12, 72), "Đấu chung hôm nay", int(pair.get("todayMatch", 0)), Love.rule("matchDailyCap", 200))
			_love_bar(at + Vector2(12, 98), "Tặng quà hôm nay", int(pair.get("todayGift", 0)), Love.rule("giftDailyCap", 200))
			if Love.wed_on():
				_love_wed_card(pair, at)
			else:
				_fwords("Mốc kế: %d thân mật" % Love.rule("marryNeed", 2000), ARIAL_BOLD, 12, GOLD, "l", at + Vector2(12, 124), 264, 0.0, 16.0)
		"ring":
			_love_ring_row(item[2], at + Vector2(0, floorf((high - 44.0) / 2.0)), card)
		"wcard":
			var w: Dictionary = item[2]
			_fround(card, CARD, 8.0, CARD_EDGE, 1.0)
			Love.draw(self, Rect2((at + Vector2(14, 16)) * _f, Vector2(24, 24) * _f), 1.0, 1.0, 1)
			_fwords("%s & %s" % [str(w.get("aName", "")), str(w.get("bName", ""))], ARIAL_BOLD, 14, Color.WHITE, "l", at + Vector2(48, 8), 160, 1.0, 0.0, true, Color(0, 0, 0, 0.45))
			var wline: String = "Đang cử hành" if str(w.get("phase", "")) == "open" else "Lễ cưới lúc %s" % str(w.get("time", ""))
			_fwords(wline, ARIAL_BOLD, 11, ONLINE if str(w.get("phase", "")) == "open" else GOLD, "l", at + Vector2(48, 30), 160, 0.0, 0.0)
			_fbtn("love:hall:%d" % int(w.get("id", 0)), "Vào lễ", Rect2(at + Vector2(218, 15), Vector2(66, 26)), "blue", true, 12.0)
		"in", "out", "close", "pin", "pout":
			var row: Dictionary = item[2]
			var acct: int = int(row.get({"in": "fromId", "out": "toId", "pin": "fromId", "pout": "toId"}.get(kind, "id"), 0))
			var name: String = str(row.get({"in": "fromName", "out": "toName", "pin": "fromName", "pout": "toName"}.get(kind, "name"), ""))
			var brief: Dictionary = _acct_brief(acct)
			var id: String = "lrow:%d" % acct
			_fround(card, CARD.lightened(0.08) if _hover == id and not brief.is_empty() else CARD, 8.0, CARD_EDGE, 1.0)
			if not brief.is_empty():
				_hit(id, Rect2(card.position * _f, card.size * _f), false)
			_face_at(int(brief.get("m_avatarId", 0)), Rect2(at + Vector2(7, 8), Vector2(40, 40)), not brief.is_empty() and int(brief.get("m_online", 0)) == 0)
			var name_w: float = {"in": 96.0, "out": 160.0, "pin": 96.0, "pout": 160.0}.get(kind, 150.0)
			_fwords(name, ARIAL_BOLD, 14, Color.WHITE, "l", at + Vector2(56, 8), name_w, 1.0, 0.0, true, Color(0, 0, 0, 0.45))
			var ask_id: int = int(row.get("id", 0))
			if kind == "pin":
				_fwords("Cầu hôn · %s" % Love.ring_name(int(row.get("tier", 0))), ARIAL_BOLD, 11, GOLD, "l", at + Vector2(56, 30), name_w, 0.0, 0.0)
				_fbtn("love:pans:%d" % ask_id, "Đồng ý", Rect2(at + Vector2(160, 14), Vector2(62, 28)), "green", not Love.busy("answer"), 12.0)
				_fbtn("love:pno:%d" % ask_id, "Từ chối", Rect2(at + Vector2(230, 14), Vector2(54, 28)), "gray", not Love.busy("refuse"), 12.0)
			elif kind == "pout":
				_fwords("Đã cầu hôn · %s · chờ trả lời" % Love.ring_name(int(row.get("tier", 0))), ARIAL_BOLD, 11, MUTED, "l", at + Vector2(56, 30), name_w, 0.0, 0.0)
				_fbtn("love:withdraw:%d" % ask_id, "Rút", Rect2(at + Vector2(234, 15), Vector2(50, 26)), "gray", not Love.busy("withdraw"), 12.0)
			elif kind == "in":
				_fwords("Tỏ tình với bạn", ARIAL_BOLD, 11, GOLD, "l", at + Vector2(56, 30), name_w, 0.0, 0.0)
				_fbtn("love:accept:%d" % ask_id, "Đồng ý", Rect2(at + Vector2(160, 14), Vector2(62, 28)), "green", not Love.busy("accept"), 12.0)
				_fbtn("love:reject:%d" % ask_id, "Từ chối", Rect2(at + Vector2(230, 14), Vector2(54, 28)), "gray", not Love.busy("reject"), 12.0)
			elif kind == "out":
				_fwords("Chờ trả lời", ARIAL_BOLD, 11, MUTED, "l", at + Vector2(56, 30), name_w, 0.0, 0.0)
				_fbtn("love:cancel:%d" % ask_id, "Hủy", Rect2(at + Vector2(234, 15), Vector2(50, 26)), "gray", not Love.busy("cancel"), 12.0)
			else:
				var points: int = int(row.get("points", 0))
				var need: int = Love.need()
				_fwords("Thân mật %d/%d" % [points, need], ARIAL_BOLD, 11, ONLINE if points >= need else MUTED, "l", at + Vector2(56, 24), name_w, 0.0, 0.0)
				var bar: Rect2 = Rect2(at + Vector2(56, 44), Vector2(name_w, 4))
				_fround(bar, Color(0, 0, 0, 0.4), 2.0)
				if points > 0:
					_fround(Rect2(bar.position, Vector2(maxf(4.0, bar.size.x * clampf(float(points) / float(maxi(1, need)), 0.0, 1.0)), 4)), GOLD, 2.0)
				_fbtn("love:ask:%d" % ask_id, "Tỏ tình", Rect2(at + Vector2(218, 15), Vector2(66, 26)), "blue", _love_askable(ask_id, points), 12.0)




func _love_wed_card(pair: Dictionary, at: Vector2) -> void :
	var wc: Dictionary = Love.wcouple()
	var line: String = ""
	var tone: Color = GOLD
	if int(pair.get("state", 1)) == 2:
		var w: Dictionary = Love.wedding()
		line = Love.ring_name(int(wc.get("ringTier", 0)))
		if not w.is_empty():
			line += " · Lễ cưới %s" % ("đang cử hành" if str(w.get("phase", "")) == "open" else "lúc " + str(w.get("time", "")))
			_fbtn("love:hall:%d" % int(w.get("id", 0)), "Lễ đường", Rect2(at + Vector2(218, 40), Vector2(62, 26)), "blue", true, 12.0)
		elif Love.wed.get("wedded") == true:
			line += " · Đã cử hành lễ cưới"
		else:
			line += " · Chưa đặt Lễ đường"
			_fbtn("love:book", "Đặt lễ", Rect2(at + Vector2(218, 40), Vector2(62, 26)), "blue", true, 12.0)
	else:
		var now: int = int(Time.get_unix_time_from_system())
		if not Love.propose_out().is_empty():
			line = "Đã cầu hôn, chờ người ấy trả lời."
		elif int(wc.get("proposeWait", 0)) > now:
			line = "Bị từ chối · cầu hôn lại sau %s" % Love.vn_time(int(wc.get("proposeWait", 0)))
		elif wc.get("ready") != true:
			line = "Cầu hôn: thân mật %d/%d · bên nhau %d/%d ngày" % [int(wc.get("intimacy", pair.get("intimacy", 0))), Love.wrule("marryNeed", 2000), 
				int(wc.get("days", pair.get("days", 0))), Love.wrule("marryDays", 7)]
			tone = MUTED
		elif Love.best_ring() <= 0:
			line = "Đủ điều kiện cầu hôn · mua nhẫn ở mục Nhẫn bên dưới"
		else:
			line = "Đủ điều kiện · cầu hôn bằng %s" % Love.ring_name(Love.best_ring())
			tone = ONLINE
		_fbtn("love:propose", "Cầu hôn", Rect2(at + Vector2(218, 40), Vector2(62, 26)), "blue", _love_proposable(), 12.0)
	_fwords(line, ARIAL_BOLD, 12, tone, "l", at + Vector2(12, 124), 264, 0.0, 16.0)


func _love_proposable() -> bool:
	var wc: Dictionary = Love.wcouple()
	if wc.is_empty() or int(wc.get("state", 1)) != 1 or wc.get("ready") != true or Love.best_ring() <= 0 or Love.busy("propose"):
		return false
	if not Love.propose_out().is_empty() or not Love.propose_in().is_empty():
		return false
	return int(wc.get("proposeWait", 0)) <= int(Time.get_unix_time_from_system())



func _love_ring_row(r: Dictionary, at: Vector2, card: Rect2) -> void :
	var tier: int = int(r.get("tier", 0))
	var wc: Dictionary = Love.wcouple()
	var married: bool = int(wc.get("state", Love.couple().get("state", 1))) == 2
	var worn: int = int(wc.get("ringTier", 0))
	_fround(card, CARD.lightened(0.06) if married and tier == worn else CARD, 8.0, Color(GOLD, 0.7) if married and tier == worn else CARD_EDGE, 1.0)
	var side: float = clampf(card.size.y - 12.0, 34.0, 48.0)
	var art: Texture2D = Love.ring_tex(pack, tier)
	if art != null:
		draw_texture_rect(art, Rect2(Vector2(card.position.x + 8.0, card.get_center().y - side / 2.0) * _f, Vector2(side, side) * _f), false)
	var tx: Vector2 = at + Vector2(side - 24.0, 0)
	_fwords(str(r.get("name", "")), ARIAL_BOLD, 13, Color.WHITE, "l", tx + Vector2(48, 5), 146, 1.0, 0.0, true, Color(0, 0, 0, 0.45))
	var price: String = Love.price_text(int(r.get("price", 0)), str(r.get("curName", "")))
	if married:
		if tier == worn:
			_fwords("Nhẫn cưới đang đeo", ARIAL_BOLD, 11, ONLINE, "l", tx + Vector2(48, 24), 146, 0.0, 0.0)
			_fwords("Đang đeo", ARIAL_BOLD, 12, ONLINE, "c", at + Vector2(218, 9), 66, 0.0, 26.0)
		elif tier > worn:
			var cost: Array = Love.up_cost(tier)
			_fwords("Nâng: %s" % Love.price_text(int(cost[0]), str(cost[1])), ARIAL_BOLD, 11, GOLD, "l", tx + Vector2(48, 24), 146, 0.0, 0.0)
			_fbtn("love:up:%d" % tier, "Nâng", Rect2(at + Vector2(218, 9), Vector2(66, 26)), "blue", not Love.busy("ring_up"), 12.0)
		else:
			_fwords(price, ARIAL_BOLD, 11, Color(MUTED, 0.6), "l", tx + Vector2(48, 24), 146, 0.0, 0.0)
		return
	var have: int = Love.bag_n(tier)
	_fwords("%s · trong túi: %d" % [price, have], ARIAL_BOLD, 11, GOLD, "l", tx + Vector2(48, 24), 146, 0.0, 0.0)
	_fbtn("love:buy:%d" % tier, "Mua", Rect2(at + Vector2(218, 9), Vector2(66, 26)), "blue", have < Love.wrule("ringBagMax", 9) and not Love.busy("ring_buy"), 12.0)


func _love_askable(acct: int, points: int) -> bool:
	if points < Love.need() or not Love.couple().is_empty() or Love.busy("invite") or not Love.shown(client):
		return false
	if int(Love.state.get("invitesLeft", 0)) <= 0 or int(Love.state.get("waitUntil", 0)) > int(Time.get_unix_time_from_system()):
		return false
	for row: Variant in Love.outgoing():
		if row is Dictionary and int(row.get("toId", 0)) == acct:
			return false
	return true


func _love_bar(at: Vector2, label: String, value: int, cap: int) -> void :
	_fwords(label, ARIAL_BOLD, 11, MUTED, "l", at, 180, 0.0, 14.0)
	_fwords("%d/%d" % [value, cap], ARIAL_BOLD, 11, ONLINE if value >= cap else Color.WHITE, "r", at + Vector2(184, 0), 80, 0.0, 14.0)
	var bar: Rect2 = Rect2(at + Vector2(0, 16), Vector2(264, 6))
	_fround(bar, Color(0, 0, 0, 0.4), 3.0)
	if value > 0:
		_fround(Rect2(bar.position, Vector2(maxf(6.0, bar.size.x * clampf(float(value) / float(maxi(1, cap)), 0.0, 1.0)), 6)), GOLD, 3.0)


func _paint_love_foot(base: Vector2) -> void :
	if Love.state.is_empty() or Love.gate != 1:
		return
	var y: float = LIST_Y + ROW * float(SHOWN) + 4.0
	var wait: int = int(Love.state.get("waitUntil", 0))
	var text: String = "Lời tỏ tình hôm nay còn %d/%d" % [int(Love.state.get("invitesLeft", 0)), Love.rule("inviteDailyMax", 5)]
	if wait > int(Time.get_unix_time_from_system()):
		var vn: Dictionary = Time.get_datetime_dict_from_unix_time(wait + 7 * 3600)
		text = "Tỏ tình lại sau %02d:%02d %02d/%02d" % [int(vn.hour), int(vn.minute), int(vn.day), int(vn.month)]
	var paired: bool = not Love.couple().is_empty()
	var wed_pair: bool = paired and int(Love.couple().get("state", 1)) == 2
	if paired:
		text = "Vợ Chồng" if wed_pair else "Đã có Người Yêu"
	_fwords(text, ARIAL_BOLD, 12, Color(MUTED, 0.85), "l", base + Vector2(14, y), 108.0 if paired else 174.0, 0.0, 26.0)
	if paired:
		_fbtn("love:divorce" if wed_pair else "love:breakup", "Ly hôn" if wed_pair else "Chia tay", Rect2(base + Vector2(128, y), Vector2(62, 26)), "gray", 
			not Love.busy("breakup"), 12.0)
	var blocked: bool = Love.state.get("blockInvites") == true
	_fbtn("love:block", "Đang chặn tỏ tình" if blocked else "Chặn tỏ tình", Rect2(base + Vector2(196, y), Vector2(116, 26)), "gold" if blocked else "gray", 
		not Love.busy("block"), 12.0)


func _menu_acct() -> int:
	for pool: Dictionary in [client.friends, client.blacks]:
		var brief: Variant = pool.get(_menu_uuid)
		if brief is Dictionary and int(brief.get("m_accountId", 0)) > 0:
			return int(brief.get("m_accountId", 0))
	var info: Dictionary = _apply_brief(_menu_uuid) if _menu_ap else (_mp_brief(_menu_uuid) if _menu_mp else {})
	return int(info.get("m_accountId", 0))

func _acct_brief(acct: int) -> Dictionary:
	if acct > 0 and client != null:
		for brief: Dictionary in client.friends.values():
			if int(brief.get("m_accountId", 0)) == acct:
				return brief
	return {}


func _love_invite_name(text: String) -> void :
	var who: String = text.strip_edges()
	if who.is_empty():
		say(TIP_428)
		return
	var acct: int = 0
	for brief: Dictionary in client.friends.values():
		if str(brief.get("m_name", "")) == who:
			acct = int(brief.get("m_accountId", 0))
	if preload("love_ask.gd").open_for(self, "invite", who, acct) != null and _search != null:
		_search.release_focus()

func _love_action(id: String) -> void :
	var parts: PackedStringArray = id.split(":")
	if parts[0] == "lrow":
		var brief: Dictionary = _acct_brief(int(parts[1]) if parts.size() > 1 else 0)
		if not brief.is_empty():
			_open_menu(str(brief.get("m_charUuid", "")), str(brief.get("m_name", "")), _menu_spot())
		return
	var key: String = parts[1] if parts.size() > 1 else ""
	var num: int = int(parts[2]) if parts.size() > 2 else 0
	match key:
		"accept", "reject":
			for row: Variant in Love.incoming():
				if row is Dictionary and int(row.get("id", 0)) == num:
					if key == "accept":
						Love.accept(client, num, str(row.get("fromName", "")))
					else:
						Love.reject(client, num, str(row.get("fromName", "")))
		"cancel":
			for row: Variant in Love.outgoing():
				if row is Dictionary and int(row.get("id", 0)) == num:
					Love.cancel(client, num, str(row.get("toName", "")))
		"ask":
			for row: Variant in Love.close_list():
				if row is Dictionary and int(row.get("id", 0)) == num:
					preload("love_ask.gd").open_for(self, "invite", str(row.get("name", "")), num)
		"chat":
			var mate: String = str(Love.couple().get("partnerName", ""))
			if int(client.character.get("level", 0)) < PM_LEVEL:
				say("Đạt lv10 được PM")
			elif not mate.is_empty():
				whisper.emit(mate)
		"breakup":
			var pair: Dictionary = Love.couple()
			if not pair.is_empty():
				preload("love_ask.gd").open_for(self, "breakup", str(pair.get("partnerName", "")), int(pair.get("partnerId", 0)))
		"block":
			Love.block(client, Love.state.get("blockInvites") != true)
		"divorce":
			var wife: Dictionary = Love.couple()
			if not wife.is_empty():
				preload("love_ask.gd").open_for(self, "divorce", str(wife.get("partnerName", "")), int(wife.get("partnerId", 0)))
		"propose":
			var mate_pair: Dictionary = Love.couple()
			if _love_proposable():
				preload("love_ask.gd").open_for(self, "propose", str(mate_pair.get("partnerName", "")), int(mate_pair.get("partnerId", 0)), Love.best_ring())
		"pans", "pno":
			for row: Dictionary in Love.propose_in():
				if int(row.get("id", 0)) == num:
					if key == "pans":
						preload("love_ask.gd").open_for(self, "answer", str(row.get("fromName", "")), num, int(row.get("tier", 0)))
					else:
						Love.answer(client, num, false, str(row.get("fromName", "")))
		"withdraw":
			Love.withdraw(client, num)
		"buy":
			preload("love_ask.gd").open_for(self, "buy", "", 0, num)
		"up":
			preload("love_ask.gd").open_for(self, "upgrade", "", 0, num)
		"book":
			preload("love_wed.gd").open_for(self, "book")
		"hall":
			preload("love_wed.gd").open_for(self, "hall", num)



func _tick(_delta: float) -> void :
	if client == null:
		return
	Love.tick(client, is_visible_in_tree(), _tab == "love")
	if is_visible_in_tree():
		for love_note: Dictionary in Love.take(["accept", "reject", "cancel", "block", "refuse", "withdraw"]):
			say(str(love_note.get("text", "")))
	if not _want.is_empty():
		var rows: Array = _sorted("")
		for i in range(rows.size()):
			if str(rows[i].get("m_name", "")) == _want:
				if _want_new and is_visible_in_tree():
					say("%s đã là bạn bè của bạn." % _want)
				if _tab == "friends" and _word().strip_edges().is_empty():
					_pick = str(rows[i].get("m_charUuid", ""))
					_reveal(i)
				_want = ""
				break
	_first = clampi(_first, 0, _most())
	if not _menu_uuid.is_empty():
		if not client.friends.has(_menu_uuid) and not (_menu_mp and not _mp_brief(_menu_uuid).is_empty()) and not (_menu_bl and client.blacks.has(_menu_uuid))\
		and not (_menu_ap and not _apply_brief(_menu_uuid).is_empty()):
			_hide_menu()
		else:

			if _menu_rect.has_point(get_local_mouse_position()):
				_menu_hide_at = -1.0
			elif _menu_hide_at < 0.0:
				_menu_hide_at = _time + MENU_TIME
			if _menu_hide_at >= 0.0 and _time >= _menu_hide_at:
				_hide_menu()
	if _sheet_id == "remove" and not (client.blacks if _doomed_bl else client.friends).has(_doomed):
		_close()


func _menu_spot() -> Vector2:
	return Vector2(HOME + _off.x - MENU_W - 6.0, _click_at.y - _stage().y - 20.0)

func _activate(id: String) -> void :
	if id == "back":
		closed.emit()
	elif id.begins_with("tab:"):
		_set_tab(id.substr(4))
	elif id == "add" and _tab == "love":
		_love_invite_name(_search.text)
	elif id == "add":
		_send_add(_search.text)
	elif id == "black":
		_send_black(_search.text)
	elif id == "cancel" or id == "ask_no":
		_close()
	elif id == "ask_ok" or id == "confirm_remove":
		if _doomed_bl:
			client.delete_black(_doomed)
		elif client.delete_friend(_doomed):
			say("Đã xoá %s khỏi danh sách bạn bè." % _doomed_name)
		_close()
	elif id.begins_with("accept:"):
		var info: Dictionary = _apply_brief(id.substr(7))
		if client.approve_friend(id.substr(7)):
			say("Đã kết bạn với %s." % str(info.get("m_name", "")))
	elif id.begins_with("reject:"):
		client.ignore_friend(id.substr(7))
	elif id == "accept_all":
		var count: int = client.friend_applies.size()
		if client.approve_all_friends():
			say("Đã chấp nhận %d lời mời kết bạn." % count)
	elif id == "reject_all":
		client.ignore_all_friends()
	elif id.begins_with("unblock:"):
		var uuid: String = id.substr(8)
		var brief: Dictionary = client.blacks.get(uuid, {})
		if brief.is_empty():
			return
		_hide_menu()
		_doomed = uuid
		_doomed_name = str(brief.get("m_name", ""))
		_doomed_bl = true
		_sheet_id = "remove"
	elif id.begins_with("row:"):
		var uuid: String = id.substr(4)
		var brief: Dictionary = client.friends.get(uuid, {})
		if brief.is_empty():
			return
		_pick = uuid
		_open_menu(uuid, str(brief.get("m_name", "")), _menu_spot())
	elif id.begins_with("mrow:"):

		var uuid: String = id.substr(5)
		var brief: Dictionary = _mp_brief(uuid)
		if brief.is_empty():
			return
		_pick = uuid
		_open_menu(uuid, str(brief.get("m_name", "")), _menu_spot())
		_menu_mp = true
	elif id.begins_with("brow:"):

		var uuid: String = id.substr(5)
		var brief: Dictionary = client.blacks.get(uuid, {})
		if brief.is_empty():
			return
		_pick = uuid
		_open_menu(uuid, str(brief.get("m_name", "")), _menu_spot())
		_menu_bl = true
	elif id.begins_with("arow:"):

		var uuid: String = id.substr(5)
		var info: Dictionary = _apply_brief(uuid)
		if info.is_empty():
			return
		_pick = uuid
		_open_menu(uuid, str(info.get("m_name", "")), _menu_spot())
		_menu_ap = true
	elif id.begins_with("find:"):
		var uuid: String = id.substr(5)
		var brief: Dictionary = client.friends.get(uuid, {})
		if not brief.is_empty():
			_open_menu(uuid, str(brief.get("m_name", "")), _click_at - _stage())
	elif id.begins_with("chat:"):
		var uuid: String = id.substr(5)
		var brief: Dictionary = client.friends.get(uuid, {})
		if brief.is_empty():
			return
		_pick = uuid
		if int(client.character.get("level", 0)) < PM_LEVEL:
			say("Đạt lv10 được PM")
			return
		whisper.emit(str(brief.get("m_name", "")))
	elif id == "menu:chat":
		if int(client.character.get("level", 0)) < PM_LEVEL:
			say("Đạt lv10 được PM")
			return
		var uuid: String = _menu_uuid
		if (_menu_mp or _menu_bl or _menu_ap) and not client.friends.has(uuid):

			var who: String = _menu_name
			_hide_menu()
			whisper.emit(who)
			return
		_hide_menu()
		_activate("chat:" + uuid)
	elif id == "menu:add":
		if client.is_black_name(_menu_name):
			say(FRIEND_TXT8)
		elif _menu_ap:
			client.approve_friend(_menu_uuid)
		elif client.add_friend(_menu_name):
			_asked = _menu_name
		_hide_menu()
	elif id == "menu:copy":
		DisplayServer.clipboard_set(_menu_name)
		_hide_menu()
	elif id == "menu:black":
		client.add_black(_menu_name)
		_hide_menu()
	elif id == "menu:guild":
		_invite_guild()
	elif id == "menu:master":

		client.master_send(709, MasterModel.apply_relation(_menu_uuid, MasterModel.MAT_ENGAGE_MASTER))
	elif id == "menu:love":
		var love_who: String = _menu_name
		var love_acct: int = _menu_acct()
		_hide_menu()
		preload("love_ask.gd").open_for(self, "invite", love_who, love_acct)
	elif id.begins_with("love:") or id.begins_with("lrow:"):
		_love_action(id)
	elif id == "menu:gm":
		if _menu_name != str(client.character.get("name", "")):
			preload("gm_option.gd").open_for(self, _menu_name)
	elif id == "menu:delete":
		_doomed = _menu_uuid
		_doomed_name = _menu_name
		_doomed_bl = _menu_bl
		_sheet_id = "remove"
		_hide_menu()
	elif id == "menu:watch":
		var watched: String = _menu_uuid
		_hide_menu()
		player_info_asked.emit(watched)
	elif id == "menu:watch_battle":

		var reply: Dictionary = client.char_states.get(_menu_uuid, {})
		var look_oid: int = int(client.friends.get(_menu_uuid, client.blacks.get(_menu_uuid, {})).get("m_accountId", 0))
		_hide_menu()
		if int(reply.get("m_nState", 0)) == PS_BATTLE:
			var text: String = client.look_scene_oid(int(reply.get("m_nSceneId", 0)), look_oid)
			if not text.is_empty():
				say(text)
	elif id == "menu:enter_room":

		var reply: Dictionary = client.char_states.get(_menu_uuid, {})
		_hide_menu()
		if int(reply.get("m_nState", 0)) == PS_ROOM:
			var text: String = client.join_friend_room(int(reply.get("m_nRoomId", 0)), int(reply.get("m_nRoomType", 0)))
			if not text.is_empty():
				say(text)

func _wheel(step: int, at: Vector2) -> void :
	if _sheet_id == "remove" or not _list_rect.has_point(at) or _menu_rect.has_point(at):
		return
	_scroll(step)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var pos: Vector2 = event.position
		_click_at = pos / _f
		if event.pressed:
			var modal: bool = _sheet_id == "remove"
			var on_menu: bool = _menu_rect.has_point(pos)
			if not on_menu:
				_hide_menu()
			if not modal and not on_menu:
				if _hit_at(pos) == "slide:tree":
					_grab = "thumb"
					_grab_at = pos
					_grab_first = _first
				elif _frame_rect.has_point(pos) and not _list_rect.has_point(pos) and not _search_rect.has_point(pos):
					_grab = "frame"
					_grab_at = pos
					_grab_off = _off
		else:
			_grab = ""
	elif event is InputEventMouseMotion and not _grab.is_empty():
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
			_grab = ""
		elif _grab == "frame":
			var home: Vector2 = _stage() + Vector2(HOME, TOP)
			var want: Vector2 = _grab_off + (event.position - _grab_at) / _f
			_off = Vector2(clampf(want.x, 40.0 - FRAME_SIZE.x - home.x, _fw - 40.0 - home.x), clampf(want.y, - home.y, _fh - 40.0 - home.y))
		else:
			var count: int = _list().size()
			var shown: int = _shown_rows()
			var most: int = maxi(0, count - shown)
			if most > 0:
				var track: float = ROW * float(shown) - 4.0
				var thumb: float = maxf(24.0, track * float(shown) / float(count))
				var step: float = maxf(0.001, (track - thumb) / float(most))
				_first = clampi(_grab_first + roundi((event.position.y - _grab_at.y) / _f / step), 0, most)
	super (event)

func _input(event: InputEvent) -> void :
	if not _sheet_id.is_empty() and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or not (event is InputEventKey and event.pressed):
		return
	match event.keycode:
		KEY_ESCAPE:
			if not _menu_uuid.is_empty():
				_hide_menu()
			else:
				closed.emit()
		KEY_UP:
			_step(-1)
		KEY_DOWN:
			_step(1)
		_:
			return
	get_viewport().set_input_as_handled()
