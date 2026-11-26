extends "chat_box.gd"
































const PolyOk = preload("res://ui/poly_ok.gd")
const ChatFaces = preload("chat_faces.gd")
const ChatPrivate = preload("chat_private.gd")
const ChatMedia = preload("chat_media.gd")
const Forum = preload("forum.gd")
const ChatBg = preload("chat_bg.gd")
const BattleState = preload("../battle/battle_state.gd")
const TeaRoom = preload("tea_room.gd")
const RedEnvelope = preload("red_envelope.gd")
const VoiceClient = preload("voice_client.gd")
const VoiceUI = preload("voice_ui.gd")
const Settings = preload("res://settings.gd")
const InviteAtlas = preload("invite_atlas.gd")
const LobbyBar = preload("lobby_bar.gd")

const CONFIG: String = "user://chat.cfg"
const MINI_ROWS: Array = [3, 5, 7]
const MINI_PITCH: float = 22.0



const HALO_EDGE: float = 5.0
const HALO_RIM: Color = Color(0, 0, 0, 0.9)
const IDLE: float = 0.6
const RAIL_W: float = 64.0
const COL_W: float = 96.0
const PEER_W: float = 176.0
const FTABS: Array = [["recent", "Gần Đây"], ["contacts", "Liên Hệ"], ["black", "Sổ Đen"]]
const FTAB_H: float = 34.0
const LIST_OPEN: float = 15.0
const LIST_IDLE: float = 90.0
const HEAD_H: float = 46.0
const BAR_H: float = 50.0
const ROW_H: float = 20.0
const GAP: float = 10.0
const FACE_R: float = 17.0
const BUBBLE_PAD: float = 8.0
const WHEEL_PX: float = 60.0
const COLS: Array = [["all", "Tổng"], ["world", "Thế Giới"], ["horn", "Loa"], ["room", "Phòng"], ["team", "Team"], ["guild", "Guild"], ["system", "Hệ Thống"]]
const RAIL: Array = [["chat", "Chat"], ["friends", "Bạn bè"], ["forum", "Diễn đàn"], ["tea", "Phòng Trà"], ["mail", "Thư"], ["collapse", "Thu gọn"]]

const TAGS: Dictionary = {1: ["Mật", Color("f78fec")], 2: ["Thế Giới", Color("6fd0ff")], 4: ["Team", Color("fca238")], 8: ["Phòng", Color("7ee07e")], 
	16: ["Phe", Color("ff8a65")], 32: ["Phòng", Color("7ee07e")], 64: ["Phe", Color("ff8a65")], 128: ["Loa", Color("0ee7ea")], 
	256: ["Loa Lớn", Color("ffcc00")], 1024: ["Guild", Color("4cd964")], 2048: ["Liên SV", Color("ffcc00")], 0: ["Hệ thống", Color("ff6b6b")]}
const GLASS_BG: Color = Color("0a1729", 0.95)
const RAIL_BG: Color = Color("06101e")
const COL_BG: Color = Color("0c1d33")
const HEAD_BG: Color = Color("0f2643")
const BAR_BG: Color = Color("0d2138")
const FIELD: Color = Color("061426")
var _fill: Color = FIELD
var _lit_input: bool = false
const EDGE: Color = Color("2c5d8f")
const PICKED: Color = Color("ff9d2e")
const BLUE: Color = Color("1f8fe0")
const DIM: Color = Color("8fa9c6")
const OTHER_BUBBLE: Color = Color("17314f")
const OWN_BUBBLE: Color = Color("1b5a96")
const REC: Color = Color("e0464b")
const PIC_BOX: Vector2 = Vector2(200, 150)
const MINI_PIC: Vector2 = Vector2(120, 62)
const FR_TABS: Array = [["follow", "Theo Dõi"], ["explore", "Khám Phá"], ["topic", "Chủ Đề"], ["me", "Cá Nhân"]]
const FR_TAB_H: float = 40.0
const FR_SUB_H: float = 32.0
const FR_GAP: float = 10.0
const FR_LINE: float = 19.0
const FR_FEED_LINES: int = 6
const FR_PROFILE_H: float = 76.0
const FR_BELL_OPEN: float = 60.0
const FR_BELL_IDLE: float = 180.0
const FR_TAGS_EVERY: float = 120.0
const FR_CARD: Color = Color("10243d")
const FR_CHROME: Color = Color("0a1729")
const TRAY_W: float = 320.0
const TRAY_HEAD: float = 36.0
const TRAY_BODY: float = 196.0
const TRAY_FOOT: float = 28.0
const TRAY_TABS: Array = [["img", "Ảnh"], ["emo", "Biểu cảm"], ["say", "Câu nhanh"]]
const LX_TAB: Array = ["lx", "Lì xì"]
const LX_RED: Color = Color("d8342c")
const LX_GOLD: Color = Color("ffd257")
const LX_THANK_WAIT: float = 35.0
const LX_SURE: float = 4.0
const LX_PAGES: Array = [["open", "Đang mở"], ["gift", "Được tặng"], ["own", "Tự phát"]]
const ALB_COLS: int = 5
const ALB_ROWS: int = 3
const ALB_CELL: float = 56.0
const ALB_GAP: float = 6.0
const WAIT_MAX: int = 3
const TRAY_EMO_COLS: int = 8
const ALB_SURE: float = 3.0
const PILL_WIDE: float = 448.0
const PILL_BAR_MAX: float = 565.0

static var store: bool = true

var modern: bool = true
var muted: bool = false
var mini_rows: int = 5
var _open: bool = false
var _mini_on: bool = false
var _mini_dim: bool = false
var _view: String = "chat"
var _col: String = "all"
var _col_seen: Dictionary = {}
var _peer: String = ""
var _peer_seen: Dictionary = {}
var _peer_oid: int = 0
var _ftab: String = "recent"
var _pill_skin: String = ""
var _unblock: String = ""
var _unblock_at: float = -10.0
var _list_scroll: int = 0
var _partners_key: Array = []
var _partners: Array = []
var _wiped: int = 0
var _scroll_px: float = 0.0
var _scroll_max: float = 0.0
var _msg_area: Rect2 = Rect2()
var _list_area: Rect2 = Rect2()
var _items_key: Array = []
var _items: Array = []
var _items_h: float = 0.0
var _stamps: Dictionary = {}
var _stamp_rev: int = 0
var _faces_at: float = -10.0
var _faces_rev: int = -1
var _flagged: Control = null
var _drawn: bool = false
var _input_used: bool = false
var _menu_r: Vector2 = Vector2.ZERO
var _pick_r: Vector2 = Vector2.ZERO
var _quick_c: Vector2 = Vector2.ZERO
var _mini_lines: Array = []
var _mini_count: int = 0
var bg_hover: String = "default"
var bg_idle: String = "default"
var _halo: bool = false
var bg_alpha: int = ChatBg.DEFAULT_ALPHA
var _bg_mix: float = 0.0
var _awake: bool = false
var _zone: Rect2 = Rect2()




const HOVER_HOLD: float = 0.3
var _wake: Array = []
var _keep: Array = []
var _cut: Array = []
var _hover_on: bool = false
var _hover_off: float = 0.0
var _media_to: Dictionary = {}
var _media_out: Dictionary = {}
var _media_seen: Dictionary = {}
var _viewing: Dictionary = {}
var _fr_tab: String = "explore"
var _fr_hot: bool = false
var _fr_tag: String = ""
var _fr_user: int = 0
var _fr_page: String = "feed"
var _fr_post: int = 0
var _fr_stack: Array = []
var _fr_scroll: float = 0.0
var _fr_max: float = 0.0
var _fr_area: Rect2 = Rect2()
var _fr_menu: Dictionary = {}
var _fr_more_at: Dictionary = {}
var _fr_sure: String = ""
var _fr_sure_at: float = -10.0
var _fr_text: TextEdit = null
var _fr_say: LineEdit = null
var _fr_said: bool = false
var _fr_wrote: bool = false
var _fr_share: Dictionary = {}
var _fr_lays: Dictionary = {}
var _fr_blocked: Dictionary = {}
var _tray: bool = false
var _tray_tab: String = "img"
var _tray_r: Vector2 = Vector2.ZERO
var _lx_page: String = "open"
var _lx_list: int = 0
var _lx_money: String = "cash"
var _lx_pay: String = "cashgold"
var _tray_back: String = "img"
var _lx_thanks: Dictionary = {}
var _lx_amount: int = 0
var _lx_parts: int = 10
var _lx_sure: String = ""
var _lx_sure_at: float = -100.0
var _lx_wish: String = ""
var _lx_pop: Dictionary = {}
var _tray_min: float = 0.0
var _alb_page: int = 0
var _alb_sure: String = ""
var _alb_sure_at: float = -10.0
var _widen: float = 0.0
var _pill_w: float = 0.0

var _tea_seen: bool = false
var _tea_page: String = "list"
var _tea_say: LineEdit
var _tea_find: LineEdit
var _tea_name: LineEdit
var _tea_pass: LineEdit
var _tea_find_at: float = -1.0
var _tea_used: Dictionary = {}
var _tea_menu: Dictionary = {}
var _tea_dialog: Dictionary = {}
var _tea_form: Dictionary = {"tag": "tangau", "seats": 6, "lock": false, "approve": false}
var _tea_sure: Dictionary = {}
var _tea_notes: Array = []
var _tea_sends: Array = []
var _tea_scroll: float = 0.0
var _tea_max: float = 0.0
var _tea_area: Rect2 = Rect2()
var _tea_list_scroll: float = 0.0
var _tea_list_max: float = 0.0
var _tea_list_area: Rect2 = Rect2()
var _tea_mic_box: Rect2 = Rect2()
var _tea_k: float = 1.0
var _tea_compact: bool = false
var _tea_hold: bool = false
var _tea_hold_at: float = 0.0
var _tea_skip: bool = false
var _tea_items_key: Array = []
var _tea_items_cache: Array = []
var _tea_items_h: float = 0.0
var _tea_foot: Array = []

func _setup() -> void :
	super ()
	_load()
	visible = modern
	_fr_say = _fedit(Forum.COMMENT_MAX)
	_fr_say.placeholder_text = "Viết bình luận…"
	_fr_say.text_submitted.connect( func(_text: String) -> void : _fr_comment())
	_fr_text = TextEdit.new()
	_fr_text.visible = false
	_fr_text.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_fr_text.context_menu_enabled = false
	_fr_text.placeholder_text = "Bạn đang nghĩ gì? Gắn #chủ đề để mọi người tìm thấy…"
	for state: String in ["normal", "focus", "read_only"]:
		_fr_text.add_theme_stylebox_override(state, StyleBoxEmpty.new())
	_fr_text.add_theme_font_override("font", ARIAL)
	_fr_text.add_theme_color_override("font_color", Color.WHITE)
	_fr_text.add_theme_color_override("font_placeholder_color", DIM)
	_fr_text.add_theme_color_override("caret_color", Color.WHITE)
	_fr_text.add_theme_color_override("selection_color", Color("0b5fae"))
	_fr_text.text_changed.connect( func() -> void :
		if _fr_text.text.length() > Forum.TEXT_MAX:
			_fr_text.text = _fr_text.text.substr(0, Forum.TEXT_MAX)
			_fr_text.set_caret_line(_fr_text.get_line_count() - 1)
			_fr_text.set_caret_column(_fr_text.get_line(_fr_text.get_line_count() - 1).length()))
	add_child(_fr_text)
	_use(InviteAtlas.FILE, InviteAtlas.R)
	_tea_setup()

func _release() -> void :
	super ()
	if _fr_text != null and _fr_text.visible:
		_fr_text.visible = false
		_fr_text.release_focus()
	_tea_release()

func _load() -> void :
	if not store:
		return
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(CONFIG) != OK:
		return
	modern = bool(cfg.get_value("chat", "modern", true))
	var rows: int = int(cfg.get_value("chat", "mini_rows", 5))
	mini_rows = rows if MINI_ROWS.has(rows) else 5
	bg_hover = ChatBg.sane(cfg.get_value("chat", "bg_hover", "default"), true)
	bg_idle = ChatBg.sane(cfg.get_value("chat", "bg_idle", "default"), false)
	bg_alpha = ChatBg.sane_alpha(cfg.get_value("chat", "bg_alpha", ChatBg.DEFAULT_ALPHA))
	_tea_seen = bool(cfg.get_value("chat", "tea_seen", false))

func _save() -> void :
	if not store:
		return
	var cfg: ConfigFile = ConfigFile.new()
	cfg.set_value("chat", "modern", modern)
	cfg.set_value("chat", "mini_rows", mini_rows)
	cfg.set_value("chat", "bg_hover", bg_hover)
	cfg.set_value("chat", "bg_idle", bg_idle)
	cfg.set_value("chat", "bg_alpha", bg_alpha)
	cfg.set_value("chat", "tea_seen", _tea_seen)
	cfg.save(CONFIG)


func set_modern(on: bool) -> void :
	if on == modern:
		return
	_release()
	modern = on
	_open = on
	_view = "chat"
	visible = true
	_flag_host()
	_save()

func is_open() -> bool:
	return _open if modern else super ()

func expanded() -> bool:
	return modern and _open

func mini_shown() -> bool:
	return modern and not _open and _mini_on

func view() -> String:
	return _view

func column() -> String:
	return _col

func peer() -> String:
	return _peer

func _ok() -> bool:


	return host != null and client != null and client.state in ["lobby", "hall", "room"] and not muted\
	and client.pair_scene.is_empty()

func open() -> void :
	if not modern:
		super ()
		return
	if not _ok():
		return
	if not _open:
		_scroll_px = 0.0
		_menu = false
		_view = "chat"
	_solo = false
	_open = true
	_focus = true
	_emotes.refresh()

func _show() -> void :
	if not modern:
		super ()
		return
	if not _ok():
		return
	_solo = false
	_open = true
	_focus = true
	_emotes.refresh()

func open_whisper(who: String) -> void :
	if not modern:
		super (who)
		return
	if who.strip_edges().is_empty():
		return
	_peer_pick(who.strip_edges(), 0)
	_show()

func close() -> void :
	if not modern:
		super ()
		return
	_release()
	_open = false
	_tray = false
	_viewing = {}
	_tea_menu = {}
	if str(_tea_dialog.get("kind", "")) != "invite":
		_tea_dialog = {}
	_view = "chat" if _view != "friends" else _view

func _has_point(point: Vector2) -> bool:
	if not modern:
		return super (point)
	return _open or _horn != 0 or _mini_has(point)


func _mini_has(point: Vector2) -> bool:
	return _frame.has_point(point) and not _any_has(_cut, point)

static func _any_has(rects: Array, point: Vector2) -> bool:
	for rect: Rect2 in rects:
		if rect.has_point(point):
			return true
	return false


func _hover_tick(delta: float) -> void :
	if not _mini_on or _open:
		_hover_on = false
		_hover_off = 0.0
		return
	_hover_step(get_local_mouse_position(), delta)


func _hover_step(at: Vector2, delta: float) -> void :
	if _hover_on:
		if _any_has(_keep, at):
			_hover_off = 0.0
		else:
			_hover_off += delta
			if _hover_off >= HOVER_HOLD:
				_hover_on = false
				_hover_off = 0.0
	elif _any_has(_wake, at) and not _any_has(_cut, at):
		_hover_on = true
		_hover_off = 0.0

func _process(delta: float) -> void :
	if not modern:
		super (delta)
		return
	if not is_visible_in_tree():
		return
	_time += delta
	_tick(delta)

	var shown: bool = _open or _mini_on or _mini_dim or _horn != 0 or _time - _toast_at < 2.7 or not _who.is_empty()
	if shown or _drawn:
		queue_redraw()
	_drawn = shown

func _tick(delta: float) -> void :
	if not modern:
		_flag_host()
		super (delta)
		return
	_flag_host()
	_tea_tick()
	if not _ok() or not host.is_visible_in_tree():
		if _open or _input.visible or _horn != 0:
			close()
		_mini_on = false
		_mini_dim = false
		return
	var homed: bool = host.get("_chat_tab") is String
	_mini_on = homed and not host.chat_busy()
	_mini_dim = homed and not _mini_on
	if _solo:
		_mini_on = false
		_mini_dim = false
	super (delta)

	if not _open and _horn == 0 and _input.has_focus() and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not _mini_has(get_local_mouse_position()):
		_input.release_focus()

	if _tray and not _open and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not _mini_has(get_local_mouse_position()):
		_tray = false
	_hover_tick(delta)
	_widen = move_toward(_widen, 1.0 if _mini_on and not _open and _awake else 0.0, delta * 6.0)
	_bg_mix = move_toward(_bg_mix, 1.0 if _mini_on and not _open and _awake else 0.0, delta / 0.15)
	_stamp()
	if client.chat_rev != _faces_rev or _time - _faces_at >= 1.0:
		_faces_at = _time
		_faces_rev = client.chat_rev
		_want_faces()
	_private_tick()
	_media_tick()
	_forum_tick()
	_lx_tick()


func _private_tick() -> void :
	var looking: bool = _open and _view == "friends"
	ChatPrivate.want_list(client, LIST_OPEN if looking else LIST_IDLE)
	if not looking or _peer.is_empty() or _peer_oid <= 0:
		return
	if ChatPrivate.unread(_peer_oid) > 0:
		ChatPrivate.mark_read(client, _peer_oid, ChatPrivate.last_id(_peer_oid))
	if _scroll_max > 0.0 and _scroll_px >= _scroll_max - 1.0:
		ChatPrivate.want_older(client, _peer_oid)


func _flag_host() -> void :
	var on: bool = modern and host != null
	if _flagged != host and is_instance_valid(_flagged) and "chat_modern" in _flagged:
		_flagged.set("chat_modern", false)
	_flagged = host
	if host != null and "chat_modern" in host and host.get("chat_modern") != on:
		host.set("chat_modern", on)


func _stamp() -> void :
	if client.chat_rev == _stamp_rev:
		return
	var time: Dictionary = Time.get_time_dict_from_system()
	var now: String = "%02d:%02d" % [int(time.hour), int(time.minute)]
	for i in range(client.chat_log.size() - 1, -1, -1):
		var seq: int = int(client.chat_log[i].get("seq", 0))
		if seq <= _stamp_rev:
			break
		_stamps[seq] = now
	_stamp_rev = client.chat_rev
	if _stamps.size() > 200 and not client.chat_log.is_empty():
		var oldest: int = int(client.chat_log[0].get("seq", 0))
		for seq: int in _stamps.keys():
			if seq < oldest:
				_stamps.erase(seq)

func stamp(seq: int) -> String:
	return str(_stamps.get(seq, ""))


func _want_faces() -> void :
	ChatFaces.put(client.account_oid, int(client.character.get("avatarId", 0)), int(client.character.get("level", 0)))
	var ids: Array = []
	for i in range(client.chat_log.size() - 1, maxi(-1, client.chat_log.size() - 41), -1):
		var oid: int = _face_id(client.chat_log[i])
		if oid > 0 and not ids.has(oid):
			ids.append(oid)
	if _open and _view == "friends":
		for partner: Dictionary in partners() + contacts() + blacks():
			var oid: int = int(partner.get("oid", 0))
			if oid > 0 and not ids.has(oid):
				ids.append(oid)
	if not ids.is_empty():
		ChatFaces.want(client, ids)


static func _face_id(line: Dictionary) -> int:
	return int(line.get("oid", 0)) if int(line.get("channel", 0)) != 0 else 0



func _in_col(line: Dictionary, col: String) -> bool:
	var channel: int = int(line.get("channel", 0))
	var where: String = str(line.get("tab", ""))
	match col:
		"world":
			return channel == 2 and where == "all"
		"horn":
			return channel in [128, 256, 2048]
		"room":
			return where == "room"
		"team":
			return channel == 4
		"guild":
			return channel == 1024
		"system":
			return channel == 0
	return true

func _of_peer(line: Dictionary, name: String) -> bool:
	return str(line.get("tab", "")) == "whisper" and str(line.get("name", "")) == name


func _wanted(line: Dictionary) -> bool:
	if int(line.get("seq", 0)) <= _wiped:
		return false
	if _view == "friends":
		return not _peer.is_empty() and _of_peer(line, _peer)
	return _in_col(line, _col)

func columns() -> Array:
	var out: Array = []
	for col: Array in COLS:
		if str(col[0]) != "room" or client.state == "room":
			out.append(col)
	return out

func col_unread(col: String) -> bool:
	if _open and _view == "chat" and col == _col:
		return false
	var seen: int = int(_col_seen.get(col, 0))
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		if int(line.get("seq", 0)) <= seen:
			return false
		if col != "all" and _in_col(line, col):
			return true
	return false

func _whispers() -> int:
	if not modern:
		return super ()
	if _open and _view == "friends":
		return 0
	var count: int = 0
	for partner: Dictionary in partners():
		count += int(partner.fresh)
	return count



func partners() -> Array:
	var key: Array = [Engine.get_process_frames(), client.chat_rev, ChatPrivate.rev, _open, _view, _peer]
	if key == _partners_key:
		return _partners
	_partners_key = key
	_partners = _gather_partners()
	return _partners

func _gather_partners() -> Array:
	var out: Array = []
	var named: Dictionary = {}
	var late: Array = []
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		var name: String = str(line.get("name", ""))
		if str(line.get("tab", "")) != "whisper" or name.is_empty() or named.has(name):
			continue
		named[name] = true
		var row: Dictionary = {"name": name, "oid": int(line.get("who_oid", 0)), "fresh": _peer_fresh(name), 
			"last": str(line.get("text", "")).trim_prefix(": "), "at": 0, "mine": str(line.get("head", "")).contains("Nói với ")}
		if ChatPrivate.list_rev < 0 or int(line.get("seq", 0)) > ChatPrivate.list_rev:
			out.append(row)
		else:
			late.append(row)
	for item: Dictionary in ChatPrivate.items:
		var name: String = str(item.name)
		if name.is_empty() or named.has(name):
			continue
		named[name] = true
		ChatFaces.put(int(item.peer), int(item.avatar), int(item.level))
		out.append({"name": name, "oid": int(item.peer), "fresh": _peer_fresh(name), "last": BattleState.chat_text(str(ChatMedia.split_stored(str(item.last.text))[0])), 
			"at": int(item.last.at), "mine": int(item.last.from) == client.account_oid})
	for row: Dictionary in late:
		if not out.any( func(x: Dictionary) -> bool: return str(x.name) == str(row.name)):
			out.append(row)
	return out


func contacts() -> Array:
	return _briefs(client.friends)


func blacks() -> Array:
	return _briefs(client.blacks)

func _briefs(from: Dictionary) -> Array:
	var rows: Array = []
	var index: int = 0
	for uuid: Variant in from:
		var brief: Variant = from[uuid]
		if brief is Dictionary and not str((brief as Dictionary).get("m_name", "")).is_empty():
			rows.append([0 if int(brief.get("m_online", 0)) == 1 else 1, - int(brief.get("m_level", 0)), index, brief, str(uuid)])
		index += 1
	rows.sort()
	return rows.map( func(row: Array) -> Dictionary:
		var brief: Dictionary = row[3]
		return {"name": str(brief.get("m_name", "")), "oid": int(brief.get("m_accountId", 0)), "uuid": str(row[4]), 
			"level": int(brief.get("m_level", 0)), "online": int(brief.get("m_online", 0)) == 1})

func _peer_fresh(name: String) -> int:
	if _open and _view == "friends" and name == _peer:
		return 0
	var seen: int = maxi(int(_peer_seen.get(name, 0)), ChatPrivate.list_rev)
	var count: int = 0
	for item: Dictionary in ChatPrivate.items:
		if str(item.name) == name and int(_peer_seen.get(name, 0)) < ChatPrivate.list_rev:
			count += int(item.unread)
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		if int(line.get("seq", 0)) <= seen:
			break
		if _of_peer(line, name) and not str(line.get("head", "")).contains("Nói với "):
			count += 1
	return count




func _col_pick(col: String) -> void :
	_view = "chat"
	_col = col
	_scroll_px = 0.0
	_col_seen[col] = client.chat_rev
	match col:
		"all", "world":
			_switch("all")
			_chan = 0
		"room":
			_switch("room")
		"guild":
			_switch("guild")
		"team":
			_switch("all")
			_pick(4)
		_:
			if _tab == "whisper":
				_switch("all")

func _peer_pick(name: String, oid: int) -> void :
	_view = "friends"
	_peer = name
	_scroll_px = 0.0
	if oid <= 0:
		for partner: Dictionary in partners() + contacts():
			if str(partner.name) == name and int(partner.oid) > 0:
				oid = int(partner.oid)
				break
	_peer_oid = oid
	ChatPrivate.want_history(client, oid)
	client.whisper_to = {"name": name, "oid": oid}
	_switch("whisper")
	_chan = 0

func _chip_label() -> String:
	if _chan == 2:
		return "Thế Giới"
	if CHANNELS.has(_chan):
		return str(CHANNELS[_chan][0])
	match _tab:
		"room":
			return "Phòng"
		"guild":
			return "Guild"
		"camp":
			return "Phe ta"
		"whisper":
			return "Riêng"
	return "Phòng" if client.state == "room" else "Thế Giới"



func _unhandled_key_input(event: InputEvent) -> void :
	if not modern:
		super (event)
		return
	if not (event is InputEventKey and event.pressed and not event.echo) or client == null or not _ok():
		return
	var enter: bool = event.keycode in [KEY_ENTER, KEY_KP_ENTER]
	if _open or _horn != 0:
		if event.keycode == KEY_ESCAPE:
			if _horn != 0:
				_horn_close()
			elif _open and _tea_escape():
				pass
			elif _picker or _quick or _tray or _menu or not _who.is_empty() or not _viewing.is_empty() or not _fr_menu.is_empty():
				_drop_popups()
			elif _view == "forum" and _fr_page != "feed":
				_fr_go_back()
			else:
				close()
			get_viewport().set_input_as_handled()
		elif enter:
			_focus = true
			get_viewport().set_input_as_handled()
	elif event.keycode == KEY_ESCAPE and not _viewing.is_empty():
		_viewing = {}
		get_viewport().set_input_as_handled()
	elif enter and host.is_visible_in_tree() and not host.chat_busy():
		if _mini_on:
			_focus = true
		else:
			open()
		get_viewport().set_input_as_handled()

func _drop_popups() -> void :
	_viewing = {}
	_fr_menu = {}
	_tea_menu = {}
	_picker = false
	_quick = false
	_tray = false
	_menu = false
	_lx_pop = {}
	_hide_who()

func _wheel(step: int, at: Vector2) -> void :
	if not modern:
		super (step, at)
		return
	if _tea_wheel(step, at):
		return
	if _msg_area.has_point(at):
		_scroll_px = clampf(_scroll_px - step * WHEEL_PX, 0.0, _scroll_max)
	elif _list_area.has_point(at):
		_list_scroll = maxi(0, _list_scroll - step)
	elif _fr_area.has_point(at):
		_fr_scroll = clampf(_fr_scroll + step * WHEEL_PX, 0.0, _fr_max)

func _drag(moved: Vector2, from: Vector2) -> void :
	if not modern:
		super (moved, from)
		return
	if _tea_drag(moved, from):
		return
	if _msg_area.has_point(from):
		_scroll_px = clampf(_scroll_px + moved.y / _f, 0.0, _scroll_max)
	elif _fr_area.has_point(from):
		_fr_scroll = clampf(_fr_scroll - moved.y / _f, 0.0, _fr_max)

func _gui_input(event: InputEvent) -> void :
	if modern and event is InputEventMouse:
		_mouse = event.position
	if modern and _open and _view == "tea":
		_tea_touch(event)
	super (event)

func _activate(id: String) -> void :
	if not modern:
		if id == "m:modern":
			set_modern(true)
			return
		super (id)
		return
	if id.begins_with("m:"):
		_act(id.substr(2))
		return
	if id in ["shade", "panel"] and not _tea_menu.is_empty():
		_tea_menu = {}
		return
	if id in ["shade", "panel"] and not _fr_menu.is_empty():
		_fr_menu = {}
		return
	if id == "shade" and (_picker or _quick or _tray or _menu or not _who.is_empty()):
		_drop_popups()
		return
	if _tray:
		if id.begins_with("say:"):
			var n: int = int(id.substr(4))
			if n >= 0 and n < PHRASES.size() and _send(str(PHRASES[n])):
				_tray = false
			return
		if id.begins_with("emo:"):
			super (id)
			_tray = false
			return
		if not id.begins_with("emo"):
			_tray = false
	super (id)

func _act(id: String) -> void :
	_menu = false
	if id == "plus" or id == "lxb" or id == "tray" or id.begins_with("tray:") or id.begins_with("alb:"):
		_tray_act(id)
		return
	if id.begins_with("lx:"):
		_lx_act(id.substr(3))
		return
	_tray = false
	if id.begins_with("fr:"):
		_fr_act(id.substr(3))
		return
	if id.begins_with("tea:"):
		_tea_act(id.substr(4))
		return
	if not id.begins_with("pic:"):
		_viewing = {}
	if id.begins_with("pic:") or id.begins_with("play:") or id in ["mic", "image", "rec:cancel"]:
		_media_act(id)
		return
	if _picker and not id.begins_with("emo"):
		_picker = false
	if id.begins_with("face:"):
		var face_who: Dictionary = target(_line(int(id.substr(5))))
		if face_who.is_empty():
			return
		var face_uuid: String = str(face_who.get("uuid", ""))
		_hide_who()
		if face_uuid.is_empty() or face_uuid == "0":
			say("Chưa xem được hồ sơ người chơi này.")
		else:
			player_info_asked.emit(face_uuid)
		return
	if id.begins_with("col:"):
		_col_pick(id.substr(4))
		return
	if id.begins_with("peer:"):
		var list: Array = partners()
		var index: int = int(id.substr(5))
		if index >= 0 and index < list.size():
			_peer_pick(str(list[index].name), int(list[index].oid))
		return
	if id.begins_with("bg"):
		_bg_act(id)
		return
	if id.begins_with("mini:"):
		mini_rows = int(id.substr(5))
		_save()
		return
	if id.begins_with("ftab:"):
		_ftab = id.substr(5)
		_list_scroll = 0
		_unblock = ""
		return
	if id.begins_with("contact:"):
		var list: Array = contacts()
		var index: int = int(id.substr(8))
		if index >= 0 and index < list.size():
			_peer_pick(str(list[index].name), int(list[index].oid))
		return
	if id.begins_with("unblock:"):
		var uuid: String = id.substr(8)
		if _unblock == uuid and _time - _unblock_at < 3.0:
			_unblock = ""
			if client.delete_black(uuid):
				say("Đã bỏ chặn.")
		else:
			_unblock = uuid
			_unblock_at = _time
		return
	if id.begins_with("tab:"):
		var key: String = id.substr(4)
		if _viewable(key):
			_mini_tab(key)
		else:
			say("Kênh Team chỉ dùng được trong phòng chờ.")
		return
	match id:
		"expand":
			var whisper: bool = _tab == "whisper"
			open()

			var who: String = str(client.whisper_to.get("name", ""))
			if whisper and _open and _view == "chat":
				if who.is_empty():
					_act("view:friends")
				else:
					_peer_pick(who, int(client.whisper_to.get("oid", 0)))
		"collapse":
			close()
		"view:chat":
			_col_pick(_col if _col != "settings" else "all")
		"view:friends":
			_view = "friends"
			_scroll_px = 0.0
			var list: Array = partners()
			if _peer.is_empty() and not list.is_empty():
				_peer_pick(str(list[0].name), int(list[0].oid))
			elif not _peer.is_empty():
				_peer_pick(_peer, 0)
		"view:forum":
			if _view == "forum" and _fr_page != "feed":
				_fr_stack = []
				_fr_go_back()
			_view = "forum"
		"view:tea":
			if not TeaRoom.shown():
				return
			if not _open:
				open()
			_view = "tea"
			if not _tea_seen:
				_tea_seen = true
				_save()
			_tea_page = "room" if TeaRoom.in_room() else "list"
			TeaRoom.want_list(client, true)
		"view:mail":
			close()
			page_asked.emit("mail")
		"settings":
			_view = "chat"
			_col = "settings"
		"mode:classic":
			set_modern(false)
		"wipe":
			_wiped = client.chat_rev
			_scroll_px = 0.0
			say("Đã xoá màn hình chat.")
		"bottom":
			_scroll_px = 0.0
		"profile":
			var uuid: String = _peer_uuid()
			if uuid.is_empty():
				say("Chưa xem được hồ sơ người chơi này.")
			else:
				player_info_asked.emit(uuid)
		"gift":
			if not _peer.is_empty():
				var who: String = _peer
				close()
				page_asked.emit("shop:gift:" + who)
		"more":
			if not _peer.is_empty():
				_show_who({"name": _peer, "uuid": _peer_uuid(), "oid": _peer_oid}, _mouse / _f - _stage())
		"manage":
			close()
			page_asked.emit("friends")


func _peer_uuid() -> String:
	for row: Dictionary in contacts() + blacks():
		if str(row.name) == _peer:
			return str(row.uuid)
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		var uuid: String = str(line.get("uuid", ""))
		if _of_peer(line, _peer) and not uuid.is_empty() and uuid != "0":
			return uuid
	return ""


func _stored_line(row: Dictionary) -> Dictionary:
	var own: bool = int(row.from) == client.account_oid
	var split: Array = ChatMedia.split_stored(str(row.text))
	var text: String = str(split[0])
	var line: Dictionary = {"head": "[Mật]" + ("Nói với " if own else ""), "name": _peer, "name_color": Color("6b93ee"), "text": ": " + BattleState.chat_text(text), 
		"color": WHISPER, "tab": "whisper", "channel": 1, "oid": int(row.from), "raw": text, "gm": 0, "uuid": "", "who_oid": _peer_oid, 
		"seq": 0, "stamp": _when(int(row.at)), "stored": int(row.id)}
	if not (split[1] as Dictionary).is_empty():
		line["media"] = split[1]
	return line


static func _when(at: int) -> String:
	if at <= 0:
		return ""
	var bias: int = int(Time.get_time_zone_from_system().get("bias", 0)) * 60
	var then: Dictionary = Time.get_datetime_dict_from_unix_time(at + bias)
	var today: Dictionary = Time.get_datetime_dict_from_unix_time(int(Time.get_unix_time_from_system()) + bias)
	var clock: String = "%02d:%02d" % [int(then.hour), int(then.minute)]
	if int(then.day) == int(today.day) and int(then.month) == int(today.month) and int(then.year) == int(today.year):
		return clock
	return "%02d/%02d %s" % [int(then.day), int(then.month), clock]


func _draft_bar(name: String, at: Vector2, wide: float, area: Rect2) -> void :
	if not modern:
		super (name, at, wide, area)
		return
	if name == str(BAR[0][0]):
		_draft.draw_rect(area, _fill)



func _add(rect: Rect2) -> void :
	_frame = rect if not _frame.has_area() else _frame.merge(rect)

func _lr(at: Vector2, wide: Vector2) -> Rect2:
	return Rect2(at * _f, wide * _f)

func _wide(text: String, font: Font, px: float) -> float:
	return _face(font).get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f


func _clip(text: String, font: Font, px: float, room: float) -> String:
	if _wide(text, font, px) <= room:
		return text
	var size: int = maxi(6, roundi(px * _f))
	return text.substr(0, _fit(text, _face(font), size, room - _wide("…", font, px))) + "…"

func _paint() -> void :
	if not modern:
		_field_look(false)
		super ()
		if visible and _frame.has_area():
			_draw_modern_button()
		return
	_frame = Rect2()
	_cut = []
	_tips.clear()
	_mini_lines = []
	_mini_count = 0
	_input_used = false
	_msg_area = Rect2()
	_list_area = Rect2()
	_fr_area = Rect2()
	_fr_said = false
	_fr_wrote = false
	_tea_used = {}
	if host == null:
		return
	if _open:
		_paint_panel()
	elif _mini_on:
		_paint_mini()
	elif _mini_dim:
		_paint_dim()
	if "chat_lit" in host:
		host.chat_lit = _mini_on and not _open and _awake
	if "chat_tint" in host:
		host.chat_tint = [] if bg_default() else [bg_hover, bg_idle, snappedf(_bg_mix, 0.001)]
	if not _input_used and _input.visible:
		_input.visible = false
		_input.release_focus()
	if not _fr_said and _fr_say.visible:
		_fr_say.visible = false
		_fr_say.release_focus()
	if not _fr_wrote and _fr_text.visible:
		_fr_text.visible = false
		_fr_text.release_focus()
	_tea_hide_unused()
	if _open or _mini_on:
		if _quick:
			_add(_draw_quick(_quick_c))
		if _menu:
			_add(_draw_menu(_menu_r))
		if _picker:
			_add(_draw_picker(_pick_r))
		if _tray:
			_add(_draw_tray())
		if not _who.is_empty():
			_add(_draw_who())
		if not _lx_pop.is_empty():
			_add(_draw_lx_pop())
	if not _viewing.is_empty():
		if _open:
			_draw_viewer()
		elif _mini_on and not _viewing.has("forum"):
			var whole: Rect2 = Rect2(Vector2.ZERO, size)
			draw_rect(whole, Color(0, 0, 0, 0.35))
			_hit("m:pic:close", whole, false)
			_add(whole)
			if _input.visible:
				_input.visible = false
				_input.release_focus()
			_draw_viewer()
		else:
			_viewing = {}
	if _horn != 0:
		_draw_horn()
	if _open and _view == "chat" and _col != "settings":
		_col_seen[_col] = client.chat_rev
		if _col == "all":
			for col: Array in COLS:
				_col_seen[str(col[0])] = client.chat_rev
	if _open and _view == "friends":
		_seen["whisper"] = client.chat_rev
		if not _peer.is_empty():
			_peer_seen[_peer] = client.chat_rev
	var edit: LineEdit = _horn_input if _horn != 0 else _input
	if (_open or _horn != 0) and not _mobile and edit.visible and not edit.has_focus():
		_focus = true
	if _focus and edit.visible:
		_focus = false
		edit.grab_focus()
	_draw_tip()


func _draw_modern_button() -> void :
	var at: Vector2 = _frame.position / _f + Vector2(464 - 96, -24)
	if at.y < 0.0:
		at.y = _frame.position.y / _f + 4.0
	var box: Rect2 = _lr(at, Vector2(92, 22))
	_round(box, Color(BLUE, 0.92 if _hover != "m:modern" else 1.0), 10.0, Color("6fd0ff"), 1.0)
	_fwords("Khung mới", BOLD, 12.0, Color.WHITE, "c", at, 92.0, 0.0, 22.0)
	_hit("m:modern", box, false)
	_add(box)



func _paint_mini() -> void :
	var dock: Rect2 = host.chat_dock
	if not dock.has_area():
		return
	var pill: Rect2 = Rect2(dock.position / _f, dock.size / _f)
	var c: Vector2 = _anchor()[0]

	var left: float = c.x + 6.0
	var room: float = minf(448.0, floorf(_fw + 0.01) - left - 4.0)




	var glass: Variant = host.get("chat_glass")
	var walled: bool = glass is Rect2 and (glass as Rect2).has_area()
	_halo = walled or not bg_default()
	var cut: Array = []
	var shaded: bool = false
	if walled and host.has_method("chat_cover"):
		for rect: Rect2 in host.call("chat_cover"):
			if rect.encloses(Rect2(Vector2.ZERO, size)):
				shaded = true
			else:
				cut.append(rect)
	_cut = cut

	_awake = not shaded and (_input.has_focus() or _menu or _picker or _quick or _tray or not _who.is_empty() or _hover_on)
	var fade: float = 1.0 if _awake else IDLE

	var tabs: Vector2 = Vector2(left, c.y + 5.0)
	var want: int = maxi(1, floori((pill.position.y - 2.0 - (tabs.y + 27.0)) / MINI_PITCH)) if walled else mini_rows

	var budget: float = MINI_PITCH * want
	var lines: Array = []
	var tall: Array = []
	var stack: float = 0.0
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		if int(line.get("seq", 0)) <= _wiped:
			break
		if not _shows(line):
			continue
		var high: float = _mini_high(line)
		if stack + high > budget + 0.01:
			high = MINI_PITCH
		lines.push_front(line)
		tall.push_front(high)
		stack += high
		if stack >= budget - 0.01:
			break
	_mini_count = lines.size()
	var top: float = pill.position.y - 2.0 - stack
	if not walled:
		tabs = Vector2(left, top - 29.0)
		if lines.is_empty() and _skin() == "bright" and host.has_method("menu_area") and LobbyBar.art("strip") != null:
			var bar: Rect2 = host.menu_area()
			tabs.y = bar.position.y + LobbyBar.STRIP * LobbyBar.ART_TOP / LobbyBar.art("strip").get_size().y - 25.0
	_mini_tabs(tabs, fade, cut, shaded)
	_tea_mini_chip(tabs + Vector2(376.0 + _tabs_extra(), 0), fade, cut, shaded)
	if lines.is_empty() and walled:
		var hint: Vector2 = Vector2(c.x + 2.0, pill.position.y - 2.0 - MINI_PITCH * 2.0)
		if not _covered(cut, _lr(hint, Vector2(room + 8.0, MINI_PITCH))):
			_fwords("Chưa có tin nhắn — bấm để mở khung chat", REGULAR, 13.0, DIM, "c", hint, room + 8.0, HALO_EDGE, MINI_PITCH, true, HALO_RIM)
	elif walled:
		var y: float = top
		for i in range(lines.size()):
			var at: Vector2 = Vector2(left, y)
			var high: float = float(tall[i])
			y += high
			var free: float = _uncovered(cut, at, room, high)
			if free <= 0.0:
				continue
			var row: Rect2 = _lr(at, Vector2(free, high))
			if not shaded:
				_hit("m:expand", row, false)
				_add(row)
			var hits: int = _hits.size()
			_mini_line(lines[i], at, free, high)
			if shaded:
				_hits.resize(hits)
	elif not lines.is_empty():
		var area: Rect2 = _lr(Vector2(left, top), Vector2(room, stack))
		_round(area.grow(2.0 * _f), bg_tint(Color(0, 0, 0, 0.22), Color(0, 0, 0, 0.22 * IDLE)), 12.0)
		_hit("m:expand", area, false)
		_add(area)
		var y: float = top
		for i in range(lines.size()):
			_mini_line(lines[i], Vector2(left, y), room, float(tall[i]))
			y += float(tall[i])

	if walled and _widen > 0.0:
		var wide: Rect2 = Rect2(pill.position, Vector2(lerpf(pill.size.x, _pill_room(pill, glass), _widen), pill.size.y))
		if not _covered(cut, _lr(wide.position, wide.size)):
			pill = wide
	if not walled and _lit_tabs():
		pill.size.x = _bar_room(pill)
	_pill_w = pill.size.x
	_zone = (glass as Rect2).merge(_lr(pill.position, pill.size)) if walled else _frame.merge(_lr(pill.position, pill.size))

	if walled:
		var narrow: Rect2 = _lr(pill.position, Vector2(minf(pill.size.x, dock.size.x / _f), pill.size.y))
		_wake = [glass, narrow]
		_keep = [glass, _lr(pill.position, pill.size), Rect2(Vector2(pill.position.x * _f, pill.position.y * _f), Vector2(maxf(0.0, size.x - pill.position.x * _f), pill.size.y * _f))]
	else:
		_wake = [_zone]
		_keep = [_zone]
	if _covered(cut, _lr(pill.position, pill.size)):
		return
	if shaded:
		_paint_dim()
	else:
		_draw_pill(pill, fade)



func _pill_room(pill: Rect2, glass: Rect2) -> float:
	var room: float = minf(PILL_WIDE, glass.end.x / _f - pill.position.x)
	var band: Rect2 = _lr(Vector2(pill.end.x, pill.position.y), Vector2(maxf(0.0, room - pill.size.x), pill.size.y))
	var hits: Variant = host.get("_hits")
	if hits is Array and band.has_area():
		for hit: Variant in hits:
			if not (hit is Array and (hit as Array).size() >= 2 and hit[1] is Rect2) or str(hit[0]) == "chat":
				continue
			var rect: Rect2 = hit[1]
			if rect.position.x > band.position.x and rect.intersects(band):
				room = minf(room, rect.position.x / _f - pill.position.x - 6.0)
	return maxf(pill.size.x, room)




func _lit_tabs() -> bool:
	return _skin() == "bright" and host.has_method("menu_area") and LobbyBar.art("strip") != null



func _tab_wide(label: String) -> float:
	var px: int = maxi(6, roundi(12.0 * _f))
	var text: float = _face(BOLD).get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	return maxf(69.0, ceilf((text + 2.0 * maxf(9.0, 8.0 * _f)) / _f))


func _tabs_extra() -> float:
	if not _lit_tabs():
		return 0.0
	var extra: float = 0.0
	for row: Array in TABS:
		extra += _tab_wide(str(row[1])) - 69.0
	return extra


func _tab_blit(name: String, at: Vector2, wide: float, tint: Color) -> Rect2:
	var cell: Array = _cells.get(name, [])
	if cell.is_empty() or cell[0] == null:
		return _fblit(name, at, wide, 0.0, tint)
	var src: Rect2 = Rect2(float(cell[1][0]), float(cell[1][1]), float(cell[1][2]), float(cell[1][3]))
	var cap: float = minf(10.0, floorf(src.size.x / 3.0))
	var x0: float = at.x * _f
	var x1: float = (at.x + wide) * _f
	var y: float = at.y * _f
	var h: float = src.size.y * _f
	draw_texture_rect_region(cell[0], Rect2(x0, y, cap * _f, h), Rect2(src.position, Vector2(cap, src.size.y)), tint)
	draw_texture_rect_region(cell[0], Rect2(x0 + cap * _f, y, x1 - x0 - 2.0 * cap * _f, h), Rect2(src.position + Vector2(cap, 0), Vector2(src.size.x - 2.0 * cap, src.size.y)), tint)
	draw_texture_rect_region(cell[0], Rect2(x1 - cap * _f, y, cap * _f, h), Rect2(src.position + Vector2(src.size.x - cap, 0), Vector2(cap, src.size.y)), tint)
	return Rect2(x0, y, x1 - x0, h)



func _bar_room(pill: Rect2) -> float:
	var lay: Dictionary = LobbyBar.layout(_skin(), host.menu_area(), [], LobbyBar.hidden_ids(client))
	var x: float = INF
	for item: Array in lay["items"]:
		x = minf(x, (item[3] as Rect2).position.x)
	if x == INF:
		return pill.size.x
	return maxf(pill.size.x, minf(PILL_BAR_MAX, floorf(x - 16.0 - pill.position.x)))

func _mini_tabs(at: Vector2, fade: float, cut: Array, shaded: bool) -> void :
	var words: float = 1.0 if fade >= 1.0 else 0.8
	var roomy: bool = _lit_tabs()
	var spot: Vector2 = at
	for i in range(TABS.size()):
		var key: String = str(TABS[i][0])
		var id: String = "m:tab:" + key
		var wide: float = _tab_wide(str(TABS[i][1])) if roomy else 69.0
		if _covered(cut, _lr(spot, Vector2(wide, 25))):
			spot.x += wide + 2.0
			continue
		var glow: Color = _glow(id)
		var face: String = "chatf_tab_on" if _tab == key else "chatf_tab"
		var rect: Rect2 = _tab_blit(face, spot, wide, Color(glow, fade)) if wide > 69.0 else _fblit(face, spot, 0.0, 0.0, Color(glow, fade))
		if not shaded:
			_hit(id, rect, false)
			_add(rect)
		_fwords(str(TABS[i][1]), BOLD, 12.0, Color(1, 1, 1, (0.92 if _viewable(key) else 0.45) * words), "c", spot, wide, 1.0, 25.0)
		spot.x += wide + 2.0
	var fresh: int = _whispers()
	var tip: Vector2 = Vector2(spot.x - 4.0, at.y + 2.0)
	if fresh > 0 and not _covered(cut, _lr(tip, Vector2(19, 19))):
		_fblit("chatf_tip", tip)
		_fwords(str(fresh) if fresh < 100 else "99+", BOLD, 11.0, Color.WHITE, "c", tip, 19.0, 0.0, 19.0)



func _mini_tab(key: String) -> void :
	var col: String = "all"
	for each: Array in columns():
		if str(each[0]) == key and key in ["room", "guild"]:
			col = key
	_col_pick(col)
	_switch(key)
	if host.get("_chat_tab") is String:
		host.set("_chat_tab", key)



func _uncovered(cut: Array, at: Vector2, room: float, high: float = MINI_PITCH) -> float:
	var row: Rect2 = _lr(at, Vector2(room, high))
	var free: float = room
	for over: Rect2 in cut:
		if over.intersects(row):
			free = minf(free, over.position.x / _f - at.x - 4.0)
	return free if free >= 60.0 else 0.0


func _covered(cut: Array, rect: Rect2) -> bool:
	for over: Rect2 in cut:
		if over.intersects(rect):
			return true
	return false



func _paint_dim() -> void :
	var dock: Rect2 = host.chat_dock
	if not dock.has_area():
		return
	var row: Rect2 = Rect2(dock.position / _f + Vector2(0, 4), Vector2(dock.size.x / _f, 34))
	_round(_lr(row.position, row.size), Color("071426", 0.6), 17.0, Color(EDGE, 0.6), 1.0)
	var chip_w: float = 52.0 if row.size.x < 300.0 else 72.0
	var at: Vector2 = row.position + Vector2(4, 4)
	_round(_lr(at, Vector2(chip_w, 26)), Color(TAGS[2][1], 0.15), 13.0, Color(TAGS[2][1], 0.5), 1.0)
	_fwords(_chip_label(), BOLD, 12.0, Color(1, 1, 1, 0.6), "c", at, chip_w - 12.0, 1.0, 26.0)
	var field: Rect2 = Rect2(at + Vector2(chip_w + 4.0, 0), Vector2(row.end.x - 4.0 - (at.x + chip_w + 4.0), 26))
	_round(_lr(field.position, field.size), Color(FIELD, 0.6), 13.0, Color(EDGE, 0.5), 1.0)


func _mini_pic(line: Dictionary) -> Vector2:
	var media: Variant = line.get("media")
	if not (media is Dictionary) or str((media as Dictionary).get("kind", "")) != "img" or int(line.get("channel", 0)) == 0:
		return Vector2.ZERO
	var w: float = float(media.get("w", 0))
	var h: float = float(media.get("h", 0))
	if w <= 0.0 or h <= 0.0:
		w = 4.0
		h = 3.0
	var s: float = minf(MINI_PIC.x / w, MINI_PIC.y / h)
	return Vector2(clampf(w * s, 14.0, MINI_PIC.x), clampf(h * s, 14.0, MINI_PIC.y))


func _mini_high(line: Dictionary) -> float:
	var pic: Vector2 = _mini_pic(line)
	return MINI_PITCH if pic == Vector2.ZERO else ceilf((pic.y + 4.0) / MINI_PITCH - 0.001) * MINI_PITCH


func _mini_line(line: Dictionary, at: Vector2, room: float, high: float = MINI_PITCH) -> void :
	var tag: Array = _tag(line)
	var edge: float = HALO_EDGE if _halo else 1.0
	var rim: Color = HALO_RIM if _halo else SHADE
	if _halo:
		draw_circle((at + Vector2(6, MINI_PITCH / 2.0)) * _f, 4.5 * _f, HALO_RIM, true, -1.0, true)
	draw_circle((at + Vector2(6, MINI_PITCH / 2.0)) * _f, 3.0 * _f, tag[1], true, -1.0, true)
	var x: float = 14.0
	var label: String = "[%s]" % tag[0]
	x += _fwords(label, BOLD, 13.0, tag[1], "l", at + Vector2(x, 0), room - x, edge, MINI_PITCH, false, rim) + 3.0
	var system: bool = int(line.get("channel", 0)) == 0
	var name: String = str(line.get("name", ""))
	if not system and not name.is_empty() and room - x > 30.0:
		var shown: String = _clip(name, BOLD, 13.0, minf(130.0, room - x))
		var used: float = _draw_name(line, shown, at + Vector2(x, 0), room - x, 13.0, MINI_PITCH, edge, rim)
		if not target(line).is_empty() and int(line.get("oid", 0)) != client.account_oid:
			var rect: Rect2 = _lr(at + Vector2(x, 0), Vector2(used, MINI_PITCH))
			_hit("who:%d" % int(line.get("seq", 0)), rect, false)
			_mini_lines.append([int(line.get("seq", 0)), rect])
		x += used
		x += _fwords(":", BOLD, 13.0, Color.WHITE, "l", at + Vector2(x, 0), 8.0, edge, MINI_PITCH, false, rim) + 4.0
	var pic: Vector2 = _mini_pic(line)
	if pic != Vector2.ZERO:
		var media: Dictionary = line.media
		var id: String = str(media.get("id", ""))
		_media_seen[id] = [media, int(line.get("oid", 0)) == client.account_oid]
		var s: float = minf(1.0, (room - x) / pic.x)
		if high > MINI_PITCH + 0.01 and pic.y * s >= 14.0:
			var box: Rect2 = _lr(at + Vector2(x, 2), pic * s)
			_round(box, Color("0a1626"), 6.0, Color(EDGE, 0.55), 1.0)
			var tex: Texture2D = ChatMedia.picture(client, id)
			if tex != null:
				draw_texture_rect(tex, box.grow(-1.0 * _f), false)
			else:
				_fwords("Hết hạn" if ChatMedia.gone(id) else "Đang tải…", REGULAR, 10.0, DIM, "c", at + Vector2(x, 2), pic.x * s, 0.0, pic.y * s)
			_hit("m:pic:" + id, box, false)
		elif room - x >= 30.0:
			var used: float = _fwords(ChatMedia.label(media), BOLD, 13.0, Color("6fd0ff"), "l", at + Vector2(x, 0), room - x, edge, MINI_PITCH, false, rim)
			_hit("m:pic:" + id, _lr(at + Vector2(x, 0), Vector2(used, MINI_PITCH)), false)
		return
	var parts: Array = _body(line) if not system else [[_plain_text(line), false, line.get("color", Color.WHITE)]]
	for part: Array in parts:
		if room - x < 12.0:
			break
		if part.size() > 4:
			if room - x < 20.0:
				break
			_emote(str(part[4]), Rect2(at + Vector2(x, (MINI_PITCH - 20.0) / 2.0), Vector2(20, 20)))
			x += 21.0
			continue
		var text: String = _clip(str(part[0]), REGULAR, 13.0, room - x)
		x += _fwords(text, REGULAR, 13.0, part[2], "l", at + Vector2(x, 0), room - x, edge, MINI_PITCH, false, rim)


func _draw_pill(pill: Rect2, fade: float = 1.0) -> void :
	var row: Rect2 = Rect2(pill.position + Vector2(0, 4), Vector2(pill.size.x, 34))
	var skin: String = _skin()
	if skin == "bright" and host.has_method("menu_area"):
		var bar: Rect2 = host.menu_area()
		row.position.y += LobbyBar.mid(skin, bar) - bar.get_center().y
	var box: Rect2 = _lr(row.position, row.size)
	_pill_skin = skin
	if skin == "glass":
		LobbyBar.grad(self, box, 17.0 * _f, Color(LobbyBar.B_DARK, 0.6 * fade), Color(LobbyBar.B_DARK, 0.86 * fade), Color(1, 1, 1, 0.24 * fade), maxf(1.0, _f))
	elif skin == "bright" and LobbyBar.TRAY_LIGHT and host.has_method("menu_area") and LobbyBar.art("strip") != null:
		LobbyBar.grad(self, box, 17.0 * _f, Color(Color8(230, 247, 253), 0.97 * fade), Color(Color8(200, 225, 239), 0.97 * fade), Color(Color8(118, 146, 172), 0.9 * fade), maxf(1.0, _f))
	elif skin == "bright":
		LobbyBar.grad(self, box, 17.0 * _f, Color("0a2246", 0.94 * fade), Color("031027", 0.94 * fade), Color(LobbyBar.A_STRIP[2], 0.9 * fade), maxf(1.0, 1.2 * _f))
	else:
		_round(box, Color("071426", 0.86 * fade), 17.0, Color(EDGE, 0.9 * fade), 1.0)
	_hit("panel", box, false)
	_add(box)
	var narrow: bool = row.size.x < 300.0
	var chip_w: float = 52.0 if narrow else 72.0
	var x: float = row.position.x + 4.0
	var y: float = row.position.y + 4.0
	_chip(Vector2(x, y), Vector2(chip_w, 26))
	_menu_r = Vector2(x - 11.0, row.position.y - 11.0)
	var right: float = row.end.x - 4.0
	right -= 30.0
	_icon_button("m:expand", "expand", Vector2(right, y), 26.0)
	var send: float = 0.0
	if not narrow:
		var pic: bool = skin == "bright" and host.has_method("menu_area") and LobbyBar.art("send") != null
		send = 59.0 if pic else 48.0
		right -= send + 4.0
		var go: Rect2 = _lr(Vector2(right, y - 0.5), Vector2(send, 27)) if pic else _lr(Vector2(right, y), Vector2(send, 26))
		if pic:
			LobbyBar.art_button(self, "send", go, _f, 1 if _hover == "send" else 0)
		elif skin == "bright":
			LobbyBar.key(self, go, 13.0 * _f, _f, false, 1 if _hover == "send" else 0)
		elif skin == "glass":
			var hot: Color = LobbyBar.B_ORANGE.lightened(0.12) if _hover == "send" else LobbyBar.B_ORANGE
			LobbyBar.grad(self, go, 13.0 * _f, hot.lightened(0.15), hot.darkened(0.12), Color(1, 1, 1, 0.35), maxf(1.0, _f))
		else:
			_round(go, BLUE.lightened(0.12) if _hover == "send" else BLUE, 13.0)
		if not pic:
			_fwords("Gửi", BOLD, 13.0, Color.WHITE, "c", Vector2(right, y), send, 0.0, 26.0)
		_hit("send", go, false)
	right -= 30.0
	_icon_button("m:plus", "plus", Vector2(right, y), 26.0)
	_tray_r = Vector2(right + 26.0, row.position.y)
	_tray_min = row.position.x
	_pick_r = Vector2(right + 28.0 - 453.0, row.position.y + 5.0)
	_quick_c = Vector2(right + 28.0 - 264.0, row.position.y - 267.0) - Vector2(405, -126)
	if RedEnvelope.shown():
		right -= 30.0
		_lx_button(Vector2(right, y), 26.0)
	var field: Rect2 = Rect2(Vector2(x + chip_w + 4.0, y), Vector2(right - 4.0 - (x + chip_w + 4.0), 26))
	_field(field, 13.0, skin == "bright" and LobbyBar.TRAY_LIGHT and host.has_method("menu_area") and LobbyBar.art("strip") != null)
	_pill_skin = ""


func _chip(at: Vector2, wide: Vector2) -> void :
	var box: Rect2 = _lr(at, wide)
	var color: Color = TAGS[2][1]
	if CHANNELS.has(_chan):
		color = CHANNELS[_chan][1]
	elif _tab == "whisper":
		color = WHISPER
	var skin: String = _pill_skin
	if skin == "bright":
		var lit: Color = color.lightened(0.12) if _hover == "channel" else color
		LobbyBar.grad(self, box, wide.y / 2.0 * _f, lit.lightened(0.25), lit.darkened(0.3), lit.lightened(0.55), maxf(1.0, 1.2 * _f))
		LobbyBar.gloss(self, box, wide.y / 2.0 * _f, _f, 0.3, 0.04)
	elif skin == "glass":
		LobbyBar.pill(self, box, wide.y / 2.0 * _f, _f, 1 if _hover == "channel" else 0, true)
		draw_rect(Rect2(box.position + Vector2(wide.y / 2.0 * _f, box.size.y - 2.0 * _f), Vector2(box.size.x - wide.y * _f, 2.0 * _f)), Color(color, 0.9))
	else:
		_round(box, Color(color, 0.22 if _hover != "channel" else 0.34), wide.y / 2.0, Color(color, 0.8), 1.0)
	_fwords(_chip_label(), BOLD, 12.0, Color.WHITE, "c", at + Vector2(0, 0), wide.x - 12.0, 1.0, wide.y)
	_triangle((at + Vector2(wide.x - 9.0, wide.y / 2.0)) * _f, 3.5 * _f, -1.0, Color.WHITE)
	_hit("channel", box, false)


func _field_look(lit: bool) -> void :
	if lit == _lit_input:
		return
	_lit_input = lit
	_input.add_theme_color_override("font_color", Color("1b3a5c") if lit else Color.WHITE)
	_input.add_theme_color_override("font_placeholder_color", Color("6f89a8") if lit else Color(1, 1, 1, 0.55))
	_input.add_theme_color_override("caret_color", Color("1b3a5c") if lit else Color.WHITE)
	_input.add_theme_color_override("selection_color", Color("b8d2ee") if lit else Color("0b5fae"))

func _triangle(c: Vector2, s: float, way: float, color: Color) -> void :
	_poly(PackedVector2Array([c + Vector2( - s, s * 0.6 * - way), c + Vector2(s, s * 0.6 * - way), c + Vector2(0, - s * 0.7 * - way)]), color)


func _field(rect: Rect2, px: float, lit: bool = false) -> void :
	_fill = Color("e6f0fa") if lit else FIELD
	_round(_lr(rect.position, rect.size), _fill, rect.size.y / 2.0, Color("9db8d6") if lit else Color(EDGE, 0.7), 1.0)
	_field_look(lit)
	var who: String = str(client.whisper_to.get("name", ""))
	var hint: String = "Nhập tin nhắn…"
	if _tab == "whisper":
		hint = "Nhắn %s…" % who if not who.is_empty() else "/w tên nội dung"
	if HORNS.has(_chan):
		hint = "Còn %d %s" % [client.horn_count(_chan), HORNS[_chan][0]]
	if _input.placeholder_text != hint:
		_input.placeholder_text = hint
	_fput(_input, Rect2(rect.position + Vector2(10, 0), rect.size - Vector2(16, 0)), px, "l", _horn == 0)
	_input_used = true
	_draft_r = Vector2.ZERO
	_draft.queue_redraw()


func _icon_button(id: String, kind: String, at: Vector2, side: float) -> void :
	var box: Rect2 = _lr(at, Vector2(side, side))
	var lit: bool = _hover == id
	var held: bool = id == "m:plus" and _tray and _tray_tab != "lx"
	var skin: String = _pill_skin
	if skin.is_empty() or not LobbyBar.SVG.has(kind):
		_round(box, Color(PICKED, 0.9) if held else (Color("163a5f") if lit else Color("10253f")), side / 2.0, PICKED if held else Color(EDGE, 0.9), 1.0)
		_glyph(kind, box.get_center(), side * 0.32 * _f, Color.WHITE if lit or held else Color("cfe6ff"))
	elif skin == "bright" and not held and host.has_method("menu_area") and LobbyBar.art_button(self, kind, box, _f, 1 if lit else 0):
		pass
	elif skin == "bright":
		LobbyBar.key(self, box, side / 2.0 * _f, _f, held, 1 if lit else 0)
		var ink: Color = LobbyBar.A_ORANGE[3] if held else LobbyBar.A_BLUE[3]
		LobbyBar.icon(self, kind, box.get_center(), side * 0.6 * _f, Color.WHITE, ink, Color(ink, 0.8))
	else:
		if held:
			LobbyBar.grad(self, box, side / 2.0 * _f, LobbyBar.B_ORANGE.lightened(0.15), LobbyBar.B_ORANGE.darkened(0.12), Color(1, 1, 1, 0.35), maxf(1.0, _f))
		else:
			LobbyBar.pill(self, box, side / 2.0 * _f, _f, 1 if lit else 0)
		LobbyBar.icon(self, kind, box.get_center(), side * 0.55 * _f, Color(1, 1, 1, 0.92), Color(0.08, 0.1, 0.18))
	_hit(id, box, false)
	if id == "m:plus":
		_tips[id] = "Ảnh · Biểu cảm · Câu nhanh"


func _lx_button(at: Vector2, side: float) -> void :
	var id: String = "m:lxb"
	var box: Rect2 = _lr(at, Vector2(side, side))
	var held: bool = _tray and _tray_tab == "lx"
	if held:
		_round(box, Color("ffe9a8"), side / 2.0, PICKED, 2.0)
	else:
		_round(box, LX_GOLD.lightened(0.18 if _hover == id else 0.0), side / 2.0, Color("a81e1e"), 1.0)
	var w: float = roundf(side * 0.46)
	var h: float = roundf(side * 0.58)
	_lx_icon(Rect2(at + Vector2((side - w) / 2.0, (side - h) / 2.0), Vector2(w, h)))
	_hit(id, box, false)
	_tips[id] = "Lì xì"
	if not held and RedEnvelope.dot(client.account_oid):
		draw_circle(box.position + Vector2(box.size.x - 3.0 * _f, 3.0 * _f), 4.5 * _f, Color("ff3b30"), true, -1.0, true)
		draw_circle(box.position + Vector2(box.size.x - 3.0 * _f, 3.0 * _f), 4.5 * _f, Color.WHITE, false, maxf(1.0, _f), true)


func _skin() -> String:
	if host == null or not is_instance_valid(host):
		return ""
	var style: Variant = host.get("bar_style")
	return str(style) if LobbyBar.valid(style) else ""

func _glyph(kind: String, c: Vector2, s: float, color: Color) -> void :
	var w: float = maxf(1.5, s * 0.22)
	match kind:
		"expand":
			for corner: Vector2 in [Vector2(-1, -1), Vector2(1, 1)]:
				var tip: Vector2 = c + corner * s
				draw_line(tip, tip - Vector2(corner.x * s * 0.7, 0), color, w, true)
				draw_line(tip, tip - Vector2(0, corner.y * s * 0.7), color, w, true)
				draw_line(tip, c + corner * s * 0.25, color, w, true)
		"emote":
			draw_arc(c, s, 0.0, TAU, 20, color, w, true)
			draw_circle(c + Vector2( - s * 0.35, - s * 0.25), s * 0.13, color)
			draw_circle(c + Vector2(s * 0.35, - s * 0.25), s * 0.13, color)
			draw_arc(c + Vector2(0, s * 0.05), s * 0.5, 0.35, PI - 0.35, 10, color, w, true)
		"mic":
			_round(Rect2(c + Vector2( - s * 0.35, - s), Vector2(s * 0.7, s * 1.25)), color, s * 0.35 / _u)
			draw_arc(c + Vector2(0, - s * 0.1), s * 0.62, 0.15, PI - 0.15, 10, color, w, true)
			draw_line(c + Vector2(0, s * 0.52), c + Vector2(0, s), color, w, true)
		"image":
			draw_rect(Rect2(c - Vector2(s, s * 0.8), Vector2(s * 2.0, s * 1.6)), color, false, w)
			_poly(PackedVector2Array([c + Vector2( - s * 0.8, s * 0.6), c + Vector2( - s * 0.2, - s * 0.1), c + Vector2(s * 0.2, s * 0.3), 
				c + Vector2(s * 0.45, 0), c + Vector2(s * 0.8, s * 0.6)]), color)
			draw_circle(c + Vector2(s * 0.45, - s * 0.4), s * 0.16, color)
		"quick":
			for i in range(3):
				var y: float = c.y + (i - 1) * s * 0.6
				draw_line(Vector2(c.x - s * 0.8, y), Vector2(c.x + s * 0.8, y), color, w, true)
		"plus":
			draw_line(c - Vector2(s * 0.8, 0), c + Vector2(s * 0.8, 0), color, w * 1.2, true)
			draw_line(c - Vector2(0, s * 0.8), c + Vector2(0, s * 0.8), color, w * 1.2, true)
		"chat":
			_round(Rect2(c - Vector2(s, s * 0.8), Vector2(s * 2.0, s * 1.3)), color, s * 0.5 / _u)
			_poly(PackedVector2Array([c + Vector2( - s * 0.5, s * 0.4), c + Vector2( - s * 0.1, s * 0.4), c + Vector2( - s * 0.6, s * 0.95)]), color)
		"friends":
			draw_circle(c + Vector2( - s * 0.35, - s * 0.35), s * 0.36, color)
			draw_circle(c + Vector2(s * 0.5, - s * 0.25), s * 0.28, Color(color, 0.8))
			draw_arc(c + Vector2( - s * 0.35, s * 0.75), s * 0.7, PI, TAU, 12, color, w * 1.6, true)
			draw_arc(c + Vector2(s * 0.5, s * 0.7), s * 0.5, PI, TAU, 10, Color(color, 0.8), w * 1.4, true)
		"forum":
			draw_rect(Rect2(c - Vector2(s * 0.8, s), Vector2(s * 1.6, s * 2.0)), color, false, w)
			for i in range(3):
				var y: float = c.y - s * 0.45 + i * s * 0.45
				draw_line(Vector2(c.x - s * 0.45, y), Vector2(c.x + s * 0.45, y), color, w, true)
		"mail":
			draw_rect(Rect2(c - Vector2(s, s * 0.7), Vector2(s * 2.0, s * 1.4)), color, false, w)
			draw_polyline(PackedVector2Array([c + Vector2( - s, - s * 0.7), c + Vector2(0, s * 0.1), c + Vector2(s, - s * 0.7)]), color, w, true)
		"collapse":
			draw_polyline(PackedVector2Array([c + Vector2(s * 0.35, - s * 0.8), c + Vector2( - s * 0.45, 0), c + Vector2(s * 0.35, s * 0.8)]), color, w * 1.3, true)
		"bell":
			draw_arc(c + Vector2(0, - s * 0.15), s * 0.6, PI, TAU, 12, color, w, true)
			draw_line(c + Vector2( - s * 0.6, - s * 0.15), c + Vector2( - s * 0.8, s * 0.55), color, w, true)
			draw_line(c + Vector2(s * 0.6, - s * 0.15), c + Vector2(s * 0.8, s * 0.55), color, w, true)
			draw_line(c + Vector2( - s * 0.95, s * 0.55), c + Vector2(s * 0.95, s * 0.55), color, w, true)
			draw_circle(c + Vector2(0, s * 0.82), s * 0.2, color)
			draw_circle(c + Vector2(0, - s * 0.85), s * 0.13, color)
		"heart", "heart_on":
			var points: PackedVector2Array = PackedVector2Array()
			for i in range(32):
				var t: float = TAU * i / 32.0
				points.append(c + Vector2(16.0 * pow(sin(t), 3), - (13.0 * cos(t) - 5.0 * cos(2.0 * t) - 2.0 * cos(3.0 * t) - cos(4.0 * t)) - 1.5) * s / 15.0)
			if kind == "heart_on":
				_poly(points, color)
			else:
				points.append(points[0])
				draw_polyline(points, color, w, true)
		"comment":
			draw_arc(c + Vector2(0, - s * 0.1), s * 0.85, PI * 0.72, PI * 0.72 + TAU * 0.92, 20, color, w, true)
			draw_polyline(PackedVector2Array([c + Vector2( - s * 0.62, s * 0.5), c + Vector2( - s * 0.95, s * 0.95), c + Vector2( - s * 0.2, s * 0.72)]), color, w, true)
		"share":
			var dots: Array = [c + Vector2(s * 0.6, - s * 0.65), c + Vector2( - s * 0.6, 0), c + Vector2(s * 0.6, s * 0.65)]
			draw_line(dots[0], dots[1], color, w, true)
			draw_line(dots[1], dots[2], color, w, true)
			for dot: Vector2 in dots:
				draw_circle(dot, s * 0.28, color)
		"settings":
			draw_arc(c, s * 0.55, 0.0, TAU, 16, color, w * 1.3, true)
			for i in range(8):
				var angle: float = TAU * i / 8.0
				draw_line(c + Vector2(cos(angle), sin(angle)) * s * 0.7, c + Vector2(cos(angle), sin(angle)) * s, color, w * 1.6, true)
		_:
			_tea_glyph(kind, c, s, color)



func panel_rect() -> Rect2:
	var stage: float = floorf(_fw + 0.01)
	return Rect2(0, 0, minf(stage, clampf(stage * 0.48, 560.0, 720.0)), floorf(_fh + 0.01))

func _paint_panel() -> void :
	if _view == "tea":
		_paint_tea()
		return
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.18))
	var panel: Rect2 = panel_rect()
	var box: Rect2 = _lr(panel.position, panel.size)
	draw_rect(box, GLASS_BG)
	draw_line(Vector2(box.end.x, box.position.y), box.end, Color(EDGE, 0.9), maxf(1.0, _f))
	_hit("panel", box, false)
	_add(box)
	_draw_rail(panel)
	var x0: float = RAIL_W
	if _view == "chat":
		_draw_columns(panel)
		x0 += COL_W
	elif _view == "friends":
		_draw_partners(panel)
		x0 += PEER_W
	var area: Rect2 = Rect2(Vector2(x0, HEAD_H), Vector2(panel.size.x - x0, panel.size.y - HEAD_H - BAR_H))
	if _view == "forum":
		_draw_forum(Rect2(Vector2(x0, 0), Vector2(panel.size.x - x0, panel.size.y)))
		return
	if _view == "chat" and _col == "settings":
		_draw_settings(Rect2(Vector2(x0, HEAD_H), Vector2(panel.size.x - x0, panel.size.y - HEAD_H)))
		_draw_head(Rect2(Vector2(x0, 0), Vector2(panel.size.x - x0, HEAD_H)), "Cài đặt", "Tuỳ chỉnh khung chat")
		return
	_draw_messages(area)
	var title: String = _peer if _view == "friends" else _col_name(_col)
	var note: String = ("Chat riêng với %s" % _peer if not _peer.is_empty() else "Chọn người để chat riêng") if _view == "friends" else scope()
	var head: Rect2 = Rect2(Vector2(x0, 0), Vector2(panel.size.x - x0, HEAD_H))
	var room: float = 0.0
	if _view == "friends" and not _peer.is_empty():
		room = _draw_peer_actions(head)
	_draw_head(head, title, note, room)
	_draw_entry(Rect2(Vector2(x0, panel.size.y - BAR_H), Vector2(panel.size.x - x0, BAR_H)))

func _col_name(col: String) -> String:
	for item: Array in COLS:
		if str(item[0]) == col:
			return str(item[1])
	return "Tổng"

func _draw_rail(panel: Rect2) -> void :
	draw_rect(_lr(Vector2.ZERO, Vector2(RAIL_W, panel.size.y)), RAIL_BG)
	var y: float = 10.0
	var rail: Array = RAIL.filter( func(item: Array) -> bool: return str(item[0]) != "tea" or TeaRoom.shown())
	var pitch: float = minf(64.0, floorf((panel.size.y - 12.0) / rail.size()))
	var lift: float = (64.0 - pitch) / 2.0
	for item: Array in rail:
		var key: String = str(item[0])
		var id: String = "m:collapse" if key == "collapse" else "m:view:" + key
		var on: bool = key == _view
		var cell: Rect2 = _lr(Vector2(4, y), Vector2(RAIL_W - 8.0, pitch - 6.0))
		if on:
			_round(cell, Color(PICKED, 0.2), 12.0, Color(PICKED, 0.85), 1.0)
		elif _hover == id:
			_round(cell, Color(1, 1, 1, 0.07), 12.0)
		_glyph(key, (Vector2(RAIL_W / 2.0, y + 22.0 - lift)) * _f, 9.0 * _f, PICKED if on else Color("cfe6ff"))
		_fwords(str(item[1]), BOLD, 11.0, PICKED if on else DIM, "c", Vector2(4, y + 38.0 - lift * 1.5), RAIL_W - 8.0, 0.0, 16.0)
		_hit(id, cell, false)
		if key == "friends":
			_badge(_whispers(), Vector2(RAIL_W - 16.0, y + 6.0))
		if key == "forum":
			_badge(Forum.unread, Vector2(RAIL_W - 16.0, y + 6.0))
		if key == "mail" and int(client.get("mail_unread")) > 0:
			_badge(int(client.get("mail_unread")), Vector2(RAIL_W - 16.0, y + 6.0))
		if key == "tea":
			if TeaRoom.in_room():
				draw_circle(Vector2(RAIL_W - 14.0, y + 9.0) * _f, 4.5 * _f, Color("4dff7a"), true, -1.0, true)
			elif not _tea_seen:
				_round(_lr(Vector2(RAIL_W - 31.0, y + 1.0), Vector2(28, 14)), Color("e5383b"), 7.0, Color.WHITE, 1.0)
				_fwords("MỚI", BOLD, 9.0, Color.WHITE, "c", Vector2(RAIL_W - 31.0, y + 1.0), 28.0, 0.0, 14.0)
		y += pitch

func _badge(count: int, at: Vector2) -> void :
	if count <= 0:
		return
	var text: String = str(count) if count < 100 else "99+"
	var wide: float = maxf(18.0, _wide(text, BOLD, 11.0) + 8.0)
	var box: Rect2 = _lr(at - Vector2(wide / 2.0, 0), Vector2(wide, 18))
	_round(box, Color("e5383b"), 9.0, Color.WHITE, 1.0)
	_fwords(text, BOLD, 11.0, Color.WHITE, "c", at - Vector2(wide / 2.0, 0), wide, 0.0, 18.0)

func _draw_columns(panel: Rect2) -> void :
	draw_rect(_lr(Vector2(RAIL_W, 0), Vector2(COL_W, panel.size.y)), COL_BG)
	var y: float = 10.0
	for item: Array in columns():
		var key: String = str(item[0])
		var id: String = "m:col:" + key
		var on: bool = key == _col
		var cell: Rect2 = _lr(Vector2(RAIL_W + 6.0, y), Vector2(COL_W - 12.0, 38))
		_round(cell, Color(PICKED, 0.9) if on else (Color("173556") if _hover == id else Color("112a47")), 10.0, Color(PICKED, 1.0) if on else Color(EDGE, 0.6), 1.0)
		_fwords(str(item[1]), BOLD, 13.0, Color("1a0f00") if on else Color.WHITE, "c", Vector2(RAIL_W + 6.0, y), COL_W - 12.0, 0.0, 38.0)
		_hit(id, cell, false)
		if col_unread(key):
			draw_circle((Vector2(RAIL_W + COL_W - 12.0, y + 6.0)) * _f, 4.0 * _f, Color("e5383b"), true, -1.0, true)
		y += 44.0
	var gear: Rect2 = _lr(Vector2(RAIL_W + 6.0, panel.size.y - 48.0), Vector2(COL_W - 12.0, 38))
	var on_gear: bool = _col == "settings"
	_round(gear, Color(PICKED, 0.9) if on_gear else Color("112a47"), 10.0, Color(EDGE, 0.6), 1.0)
	_glyph("settings", (Vector2(RAIL_W + 22.0, panel.size.y - 29.0)) * _f, 7.0 * _f, Color("1a0f00") if on_gear else Color.WHITE)
	_fwords("Cài đặt", BOLD, 12.0, Color("1a0f00") if on_gear else Color.WHITE, "l", Vector2(RAIL_W + 34.0, panel.size.y - 48.0), COL_W - 40.0, 0.0, 38.0)
	_hit("m:settings", gear, false)


func _draw_partners(panel: Rect2) -> void :
	draw_rect(_lr(Vector2(RAIL_W, 0), Vector2(PEER_W, panel.size.y)), COL_BG)
	var tab_w: float = (PEER_W - 8.0) / FTABS.size()
	for i in range(FTABS.size()):
		var key: String = str(FTABS[i][0])
		var id: String = "m:ftab:" + key
		var at: Vector2 = Vector2(RAIL_W + 4.0 + tab_w * i, 8.0)
		var cell: Rect2 = _lr(at, Vector2(tab_w - 2.0, FTAB_H - 6.0))
		var on: bool = key == _ftab
		_round(cell, Color(PICKED, 0.9) if on else (Color("173556") if _hover == id else Color("112a47")), 9.0, Color(PICKED, 1.0) if on else Color(EDGE, 0.6), 1.0)
		_fwords(str(FTABS[i][1]), BOLD, 11.0, Color("1a0f00") if on else Color.WHITE, "c", at, tab_w - 2.0, 0.0, FTAB_H - 6.0)
		_hit(id, cell, false)
		if key == "recent" and not on:
			_badge(_whispers_all(), Vector2(at.x + tab_w - 8.0, at.y - 4.0))
	var top: float = FTAB_H + 8.0
	var foot: float = 0.0
	if _ftab == "contacts":
		foot = 44.0
		var manage: Rect2 = _lr(Vector2(RAIL_W + 8.0, panel.size.y - 40.0), Vector2(PEER_W - 16.0, 32))
		_round(manage, BLUE.lightened(0.12) if _hover == "m:manage" else BLUE, 16.0)
		_fwords("+ Thêm / Quản lý bạn", BOLD, 12.0, Color.WHITE, "c", Vector2(RAIL_W + 8.0, panel.size.y - 40.0), PEER_W - 16.0, 0.0, 32.0)
		_hit("m:manage", manage, false)
	var list: Array = partners() if _ftab == "recent" else (contacts() if _ftab == "contacts" else blacks())
	_list_area = _lr(Vector2(RAIL_W, top), Vector2(PEER_W, panel.size.y - top - foot))
	if list.is_empty():
		var empty: Array = {"recent": ["Chưa có cuộc chat nào.", "Bấm tên trong khung chat", "→ Chat riêng."], 
			"contacts": ["Chưa có bạn bè.", "Bấm tên người chơi", "→ Thêm bạn."], "black": ["Sổ Đen trống.", "", ""]}[_ftab]
		for i in range(3):
			_fwords(str(empty[i]), REGULAR, 12.0 if i == 0 else 11.0, DIM, "l", Vector2(RAIL_W + 12.0, top + 4.0 + 20.0 * i), PEER_W - 20.0, 0.0, 20.0)
		return
	var shown: int = maxi(1, int((panel.size.y - top - foot) / 52.0))
	_list_scroll = clampi(_list_scroll, 0, maxi(0, list.size() - shown))
	var y: float = top
	for i in range(_list_scroll, list.size()):
		if y + 52.0 > panel.size.y - foot:
			break
		var row: Dictionary = list[i]
		var name: String = str(row.name)
		var id: String = ("m:peer:%d" if _ftab == "recent" else "m:contact:%d") % i
		var cell: Rect2 = _lr(Vector2(RAIL_W + 4.0, y), Vector2(PEER_W - 8.0, 50))
		if _ftab != "black":
			if name == _peer:
				_round(cell, Color(PICKED, 0.22), 10.0, Color(PICKED, 0.8), 1.0)
			elif _hover == id:
				_round(cell, Color(1, 1, 1, 0.06), 10.0)
		_disc(int(row.oid), Vector2(RAIL_W + 26.0, y + 25.0), 16.0, false)
		var text_w: float = PEER_W - 56.0
		if _ftab == "black":
			text_w -= 46.0
		_fwords(_clip(name, BOLD, 13.0, text_w - 8.0), BOLD, 13.0, Color.WHITE, "l", Vector2(RAIL_W + 48.0, y + 6.0), text_w, 0.0, 20.0, false)
		var sub: String = ""
		var ink: Color = DIM
		if _ftab == "recent":
			sub = ("Bạn: " if bool(row.mine) else "") + str(row.last)
			if sub.is_empty():
				sub = "Đang online" if _is_online(name) else ""
			ink = Color("cfe6ff") if int(row.fresh) > 0 else DIM
		else:
			sub = "Cấp %d · %s" % [int(row.level), "Online" if bool(row.online) else "Ngoại tuyến"]
			ink = Color("7ee07e") if bool(row.online) else DIM
		_fwords(_clip(sub, REGULAR, 11.0, text_w - 8.0), REGULAR, 11.0, ink, "l", Vector2(RAIL_W + 48.0, y + 25.0), text_w, 0.0, 18.0, false)
		if _ftab == "recent":
			_badge(int(row.fresh), Vector2(RAIL_W + PEER_W - 18.0, y + 6.0))
			if int(row.at) > 0 and int(row.fresh) <= 0:
				_fwords(_short_when(int(row.at)), REGULAR, 9.0, DIM, "r", Vector2(RAIL_W + PEER_W - 60.0, y + 4.0), 52.0, 0.0, 14.0, false)
		if _ftab == "black":
			var uuid: String = str(row.uuid)
			var sure: bool = _unblock == uuid and _time - _unblock_at < 3.0
			var at: Vector2 = Vector2(RAIL_W + PEER_W - 56.0, y + 12.0)
			var button: Rect2 = _lr(at, Vector2(48, 26))
			_round(button, Color("e5383b") if sure else (BLUE.lightened(0.12) if _hover == "m:unblock:" + uuid else BLUE), 13.0)
			_fwords("Chắc?" if sure else "Bỏ chặn", BOLD, 10.0, Color.WHITE, "c", at, 48.0, 0.0, 26.0)
			_hit("m:unblock:" + uuid, button, false)
		else:
			_hit(id, cell, false)
		y += 52.0


func _whispers_all() -> int:
	var count: int = 0
	for partner: Dictionary in partners():
		count += int(partner.fresh)
	return count


static func _short_when(at: int) -> String:
	var text: String = _when(at)
	return text.substr(0, 5) if text.length() > 5 else text

func _is_online(name: String) -> bool:
	for brief: Dictionary in ChatFriend.online(client.friends):
		if str(brief.get("m_name", "")) == name:
			return true
	return false


func _draw_head(rect: Rect2, title: String, note: String, busy: float = 0.0) -> void :
	var box: Rect2 = _lr(rect.position, rect.size)
	var behind: bool = busy > 0.0
	if behind:
		draw_rect(_lr(rect.position, Vector2(rect.size.x - busy - 48.0, rect.size.y)), HEAD_BG)
	else:
		draw_rect(box, HEAD_BG)
	draw_line(Vector2(box.position.x, box.end.y), box.end, Color(EDGE, 0.8), maxf(1.0, _f))
	_fwords(_clip(title, BOLD, 16.0, rect.size.x - 70.0 - busy), BOLD, 16.0, Color.WHITE, "l", rect.position + Vector2(14, 4), rect.size.x - 70.0 - busy, 1.0, 22.0)
	_fwords(_clip(note, REGULAR, 11.0, rect.size.x - 70.0 - busy), REGULAR, 11.0, DIM, "l", rect.position + Vector2(14, 24), rect.size.x - 70.0 - busy, 0.0, 18.0)
	var close_at: Vector2 = Vector2(rect.end.x - 40.0, rect.position.y + 9.0)
	var shut: Rect2 = _lr(close_at, Vector2(28, 28))
	_round(shut, Color("1a3a5e") if _hover == "m:collapse" else Color("10253f"), 14.0, Color(EDGE, 0.9), 1.0)
	var c: Vector2 = shut.get_center()
	var s: float = 6.0 * _f
	draw_line(c - Vector2(s, s), c + Vector2(s, s), Color.WHITE, maxf(1.5, 2.0 * _f), true)
	draw_line(c + Vector2( - s, s), c + Vector2(s, - s), Color.WHITE, maxf(1.5, 2.0 * _f), true)
	_hit("m:collapse", shut, false)


func _draw_peer_actions(head: Rect2) -> float:
	draw_rect(_lr(head.position, head.size), HEAD_BG)
	var right: float = head.end.x - 48.0
	var used: float = 0.0
	for item: Array in [["m:more", "⋯", 30.0], ["m:gift", "Tặng Quà", 72.0], ["m:profile", "Hồ Sơ", 58.0]]:
		var wide: float = float(item[2])
		var at: Vector2 = Vector2(right - wide, head.position.y + 10.0)
		var cell: Rect2 = _lr(at, Vector2(wide, 26))
		var id: String = str(item[0])
		_round(cell, BLUE.lightened(0.12) if _hover == id else (BLUE if id != "m:more" else Color("10253f")), 13.0, Color("6fd0ff") if id != "m:more" else Color(EDGE, 0.9), 1.0)
		_fwords(str(item[1]), BOLD, 12.0, Color.WHITE, "c", at, wide, 0.0, 26.0)
		_hit(id, cell, false)
		right -= wide + 6.0
		used += wide + 6.0
	return used


func _draw_entry(rect: Rect2) -> void :
	var box: Rect2 = _lr(rect.position, rect.size)
	draw_rect(box, BAR_BG)
	draw_line(box.position, Vector2(box.end.x, box.position.y), Color(EDGE, 0.8), maxf(1.0, _f))
	var y: float = rect.position.y + 9.0
	var x: float = rect.position.x + 8.0
	var chip: float = 76.0
	if _view == "friends":
		_round(_lr(Vector2(x, y), Vector2(chip, 32)), Color(WHISPER, 0.2), 16.0, Color(WHISPER, 0.8), 1.0)
		_fwords("Riêng", BOLD, 12.0, Color.WHITE, "c", Vector2(x, y), chip, 1.0, 32.0)
	else:
		_chip(Vector2(x, y), Vector2(chip, 32))
	_menu_r = Vector2(x - 11.0, rect.position.y - 11.0)
	x += chip + 6.0
	_icon_button("m:mic", "mic", Vector2(x, y), 32.0)
	var recording: bool = ChatMedia.recording >= 0.0 or ChatMedia.asking_mic
	if recording:
		var dot: Rect2 = _lr(Vector2(x, y), Vector2(32, 32))
		_round(dot, REC, 16.0, Color("ffb3b3"), 1.0)
		_glyph("mic", dot.get_center(), 32.0 * 0.32 * _f, Color.WHITE)
	x += 38.0
	var right: float = rect.end.x - 8.0
	right -= 60.0
	var go: Rect2 = _lr(Vector2(right, y), Vector2(60, 32))
	_round(go, BLUE.lightened(0.12) if _hover == "send" else BLUE, 16.0)
	_fwords("Gửi", BOLD, 14.0, Color.WHITE, "c", Vector2(right, y), 60.0, 0.0, 32.0)
	_hit("send", go, false)
	right -= 38.0
	_icon_button("m:plus", "plus", Vector2(right, y), 32.0)
	_tray_r = Vector2(right + 32.0, rect.position.y)
	_tray_min = 0.0
	_quick_c = Vector2(right + 32.0 - 264.0, rect.position.y - 267.0) - Vector2(405, -126)
	_pick_r = Vector2(right + 32.0 - 453.0, rect.position.y + 5.0)
	if RedEnvelope.shown():
		right -= 38.0
		_lx_button(Vector2(right, y), 32.0)
	if recording:
		_draw_recording(Rect2(Vector2(x, y), Vector2(right - 6.0 - x, 32)))
		return
	if _view == "friends" and _peer.is_empty():
		_round(_lr(Vector2(x, y), Vector2(right - 6.0 - x, 32)), FIELD, 16.0, Color(EDGE, 0.5), 1.0)
		_fwords("Chọn người bên trái để chat riêng", REGULAR, 12.0, DIM, "l", Vector2(x + 12.0, y), right - x - 24.0, 0.0, 32.0)
		return
	_field(Rect2(Vector2(x, y), Vector2(right - 6.0 - x, 32)), 14.0)





func _draw_forum(rect: Rect2) -> void :
	_fr_blocked = {}
	for row: Dictionary in blacks():
		if int(row.oid) > 0:
			_fr_blocked[int(row.oid)] = true
	_fr_more_at = {}
	var top: float = HEAD_H
	if _fr_page == "feed":
		top += FR_TAB_H + (FR_SUB_H if _fr_tab in ["explore", "topic"] else 0.0)
	var bottom: float = rect.end.y - (BAR_H if _fr_page == "post" else 0.0)
	var body: Rect2 = Rect2(Vector2(rect.position.x, top), Vector2(rect.size.x, bottom - top))
	_fr_area = _lr(body.position, body.size)
	if not Forum.online(client):
		var mid: float = body.position.y + body.size.y / 2.0
		_glyph("forum", Vector2(body.get_center().x, mid - 40.0) * _f, 22.0 * _f, Color(DIM, 0.7))
		_fwords("Diễn đàn chỉ có ở bản web", BOLD, 16.0, Color.WHITE, "c", Vector2(body.position.x, mid), body.size.x, 1.0, 26.0)
		_fwords("Đăng nhập bản HTML5 để xem và đăng bài.", REGULAR, 12.0, DIM, "c", Vector2(body.position.x, mid + 26.0), body.size.x, 0.0, 20.0)
	else:
		match _fr_page:
			"post":
				_fr_thread(body)
			"compose":
				_fr_compose(body)
			"notices":
				_fr_notices(body)
			_:
				_fr_feed(body)
	var chrome: Rect2 = _lr(rect.position, Vector2(rect.size.x, top))
	draw_rect(chrome, FR_CHROME)
	_hit("panel", chrome, false)
	var head: Rect2 = Rect2(rect.position, Vector2(rect.size.x, HEAD_H))
	var titles: Dictionary = {"post": ["Bài viết", "Thích, bình luận, chia sẻ vào chat"], "compose": ["Viết bài", "Tối đa %d ký tự, %d ảnh · gắn #chủ đề" % [Forum.TEXT_MAX, Forum.IMAGES_MAX]], 
		"notices": ["Thông báo", "Thích, bình luận và theo dõi mới"]}
	var title: Array = titles.get(_fr_page, ["Diễn đàn", "Đăng bài, ảnh, thích và bình luận ngay trong game"])
	_draw_head(head, str(title[0]), str(title[1]), _fr_head_actions(head))
	if _fr_page == "feed":
		_fr_tabs(Rect2(Vector2(rect.position.x, HEAD_H), Vector2(rect.size.x, top - HEAD_H)))
	if _fr_page == "post":
		_fr_bar(Rect2(Vector2(rect.position.x, bottom), Vector2(rect.size.x, BAR_H)))
	if not _fr_menu.is_empty():
		_fr_draw_menu()


func _fr_head_actions(head: Rect2) -> float:
	draw_rect(_lr(head.position, head.size), HEAD_BG)
	var right: float = head.end.x - 48.0
	if _fr_page != "feed":
		var at: Vector2 = Vector2(right - 84.0, head.position.y + 10.0)
		var cell: Rect2 = _lr(at, Vector2(84, 26))
		_round(cell, Color("1a3a5e") if _hover == "m:fr:back" else Color("10253f"), 13.0, Color(EDGE, 0.9), 1.0)
		_fwords("‹ Quay lại", BOLD, 12.0, Color.WHITE, "c", at, 84.0, 0.0, 26.0)
		_hit("m:fr:back", cell, false)
		return 90.0
	var write_at: Vector2 = Vector2(right - 84.0, head.position.y + 10.0)
	var write: Rect2 = _lr(write_at, Vector2(84, 26))
	_round(write, BLUE.lightened(0.12) if _hover == "m:fr:compose" else BLUE, 13.0, Color("6fd0ff"), 1.0)
	_fwords("✎ Viết bài", BOLD, 12.0, Color.WHITE, "c", write_at, 84.0, 0.0, 26.0)
	_hit("m:fr:compose", write, false)
	var bell_at: Vector2 = Vector2(right - 84.0 - 36.0, head.position.y + 8.0)
	_icon_button("m:fr:bell", "bell", bell_at, 30.0)
	_badge(Forum.unread, bell_at + Vector2(26, -2))
	return 126.0

func _fr_tabs(rect: Rect2) -> void :
	var wide: float = (rect.size.x - 20.0) / FR_TABS.size()
	for i in range(FR_TABS.size()):
		var key: String = str(FR_TABS[i][0])
		var id: String = "m:fr:tab:" + key
		var at: Vector2 = Vector2(rect.position.x + 10.0 + wide * i, rect.position.y + 6.0)
		var cell: Rect2 = _lr(at, Vector2(wide - 6.0, FR_TAB_H - 8.0))
		var on: bool = key == _fr_tab
		_round(cell, Color(PICKED, 0.9) if on else (Color("173556") if _hover == id else Color("112a47")), 10.0, Color(PICKED, 1.0) if on else Color(EDGE, 0.6), 1.0)
		var label: String = str(FR_TABS[i][1])
		if key == "me" and _fr_user > 0:
			label = _clip(str(Forum.profiles.get(_fr_user, {}).get("name", label)), BOLD, 12.0, wide - 16.0)
		_fwords(label, BOLD, 12.0, Color("1a0f00") if on else Color.WHITE, "c", at, wide - 6.0, 0.0, FR_TAB_H - 8.0)
		_hit(id, cell, false)
	var y: float = rect.position.y + FR_TAB_H
	if _fr_tab == "explore":
		var x: float = rect.position.x + 10.0
		for item: Array in [["0", "Mới nhất"], ["1", "Nổi bật 3 ngày"]]:
			var on: bool = (str(item[0]) == "1") == _fr_hot
			var w: float = _wide(str(item[1]), BOLD, 11.0) + 24.0
			_fr_chip("m:fr:hot:" + str(item[0]), str(item[1]), Vector2(x, y + 4.0), w, on)
			x += w + 6.0
	elif _fr_tab == "topic":
		var x: float = rect.position.x + 10.0
		if Forum.tags.is_empty():
			_fwords("Chưa có chủ đề nào — gắn #chủ đề khi viết bài.", REGULAR, 11.0, DIM, "l", Vector2(x, y + 4.0), rect.size.x - 20.0, 0.0, 24.0)
		for row: Dictionary in Forum.tags:
			var tag: String = str(row.tag)
			var text: String = "#%s · %d" % [tag, int(row.n)]
			var w: float = _wide(text, BOLD, 11.0) + 20.0
			if x + w > rect.end.x - 10.0:
				break
			_fr_chip("m:fr:tag:" + tag, text, Vector2(x, y + 4.0), w, tag == _fr_tag)
			x += w + 6.0

func _fr_chip(id: String, text: String, at: Vector2, wide: float, on: bool) -> void :
	var cell: Rect2 = _lr(at, Vector2(wide, 24))
	_round(cell, Color(PICKED, 0.25) if on else (Color("173556") if _hover == id else Color("0f2643")), 12.0, Color(PICKED, 0.9) if on else Color(EDGE, 0.6), 1.0)
	_fwords(text, BOLD, 11.0, PICKED if on else Color("cfe6ff"), "c", at, wide, 0.0, 24.0)
	_hit(id, cell, false)


func _fr_key() -> String:
	match _fr_tab:
		"follow":
			return Forum.feed_key("follow")
		"topic":
			return Forum.feed_key("tag", _fr_tag) if not _fr_tag.is_empty() else ""
		"me":
			return Forum.feed_key("user", str(_fr_user) if _fr_user > 0 else "")
	return Forum.feed_key("hot" if _fr_hot else "new")

func _fr_want_feed(again: bool = false) -> void :
	var key: String = _fr_key()
	if key.is_empty():
		return
	var parts: PackedStringArray = key.split("|", true, 1)
	Forum.want_feed(client, parts[0], parts[1], again)


func _fr_scroll_list(body: Rect2, blocks: Array) -> float:
	var total: float = 8.0
	for block: Array in blocks:
		total += float(block[0]) + FR_GAP
	_fr_max = maxf(0.0, total - body.size.y)
	_fr_scroll = clampf(_fr_scroll, 0.0, _fr_max)
	var y: float = body.position.y + 8.0 - _fr_scroll
	var x: float = body.position.x + 10.0
	var wide: float = body.size.x - 20.0
	for block: Array in blocks:
		var high: float = float(block[0])
		if y + high >= body.position.y - 4.0 and y <= body.end.y + 4.0:
			(block[1] as Callable).call(Vector2(x, y), wide)
		y += high + FR_GAP
	return total

func _fr_feed(body: Rect2) -> void :
	var key: String = _fr_key()
	var blocks: Array = []
	var wide: float = body.size.x - 20.0
	if _fr_tab == "me":
		var user: int = _fr_user if _fr_user > 0 else client.account_oid
		blocks.append([FR_PROFILE_H, func(at: Vector2, w: float) -> void : _fr_profile(user, at, w)])
	var rows: Array = Forum.list(key) if not key.is_empty() else []
	for post: Dictionary in rows:
		if _fr_blocked.has(int(post.by)):
			continue
		blocks.append([float(_fr_lay(post, wide, false).high), func(at: Vector2, w: float) -> void : _fr_card(post, at, w, false)])
	var known: Dictionary = Forum.feed(key) if not key.is_empty() else {}
	var note: String = ""
	if key.is_empty():
		note = "Chọn một chủ đề ở trên." if not Forum.tags.is_empty() else ""
	elif Forum.loading(key):
		note = "Đang tải…"
	elif known.is_empty():
		note = ""
	elif rows.is_empty():
		note = {"follow": "Bạn chưa theo dõi ai — bấm ⋯ trên bài để Theo dõi.", "me": "Chưa có bài nào."}.get(_fr_tab, "Chưa có bài nào — hãy là người đầu tiên!")
	elif not bool(known.more):
		note = "Hết bài."
	if not note.is_empty():
		blocks.append([40.0, func(at: Vector2, w: float) -> void : _fwords(note, REGULAR, 12.0, DIM, "c", at, w, 0.0, 40.0)])
	_fr_scroll_list(body, blocks)
	if not key.is_empty() and _fr_scroll >= _fr_max - 120.0 and bool(known.get("more", false)):
		Forum.want_more(client, key)


func _fr_profile(user: int, at: Vector2, wide: float) -> void :
	var known: Dictionary = Forum.profiles.get(user, {})
	_round(_lr(at, Vector2(wide, FR_PROFILE_H)), FR_CARD, 12.0, Color(EDGE, 0.45), 1.0)
	_disc(user, at + Vector2(40, FR_PROFILE_H / 2.0 - 4.0), 26.0, true)
	var name: String = str(known.get("name", client.character.get("name", "") if user == client.account_oid else ""))
	_fwords(_clip(name, BOLD, 16.0, wide - 200.0), BOLD, 16.0, Color.WHITE, "l", at + Vector2(80, 14), wide - 200.0, 1.0, 24.0, false)
	if not known.is_empty():
		var line: String = "%d bài · %d người theo dõi · đang theo dõi %d" % [int(known.posts), int(known.followers), int(known.following)]
		_fwords(_clip(line, REGULAR, 12.0, wide - 100.0), REGULAR, 12.0, DIM, "l", at + Vector2(80, 42), wide - 100.0, 0.0, 20.0, false)
	if user != client.account_oid and user > 0:
		var on: bool = bool(known.get("followed", false))
		var bat: Vector2 = at + Vector2(wide - 112.0, 16.0)
		var cell: Rect2 = _lr(bat, Vector2(100, 28))
		var id: String = "m:fr:follow:%d" % user
		_round(cell, Color("10253f") if on else (BLUE.lightened(0.12) if _hover == id else BLUE), 14.0, Color(EDGE, 0.9) if on else Color("6fd0ff"), 1.0)
		_fwords("Đang theo dõi" if on else "+ Theo dõi", BOLD, 12.0, Color.WHITE, "c", bat, 100.0, 0.0, 28.0)
		_hit(id, cell, false)


func _fr_lay(post: Dictionary, wide: float, full: bool) -> Dictionary:
	var key: String = "%d|%.1f|%.3f|%s|%d" % [int(post.id), wide, _f, full, str(post.text).length()]
	if _fr_lays.has(key):
		return _fr_lays[key]
	if _fr_lays.size() > 300:
		_fr_lays.clear()
	var room: float = wide - 24.0
	var rows: Array = []
	var text: String = str(post.text).strip_edges()
	if not text.is_empty():
		for para: String in text.split("\n"):
			if para.strip_edges().is_empty():
				rows.append([])
			else:
				rows.append_array(_flow([[para, false, Color("eef5ff")]], room, 13.0)[0])
	var cut: bool = not full and rows.size() > FR_FEED_LINES
	if cut:
		rows = rows.slice(0, FR_FEED_LINES)
	var tags: Array = Forum.tags_of(text)
	var y: float = 52.0
	var text_y: float = y
	y += rows.size() * FR_LINE
	if cut:
		y += 18.0
	var tags_y: float = y + 4.0
	if not tags.is_empty():
		y += 30.0
	var grid: Array = _fr_grid(post.get("images", []), room)
	var grid_y: float = y + 4.0
	var grid_h: float = 0.0
	for cell: Rect2 in grid:
		grid_h = maxf(grid_h, cell.end.y)
	if not grid.is_empty():
		y += grid_h + 10.0
	var lay: Dictionary = {"high": y + 38.0, "rows": rows, "cut": cut, "tags": tags, "text_y": text_y, "tags_y": tags_y, "grid": grid, 
		"grid_y": grid_y, "act_y": y + 4.0}
	_fr_lays[key] = lay
	return lay


func _fr_grid(images: Array, room: float) -> Array:
	var count: int = images.size()
	if count == 0:
		return []
	if count == 1:
		var w: float = float(images[0].get("w", 0))
		var h: float = float(images[0].get("h", 0))
		if w <= 0.0 or h <= 0.0:
			w = 4.0
			h = 3.0
		var s: float = minf(minf(room, 360.0) / w, 260.0 / h)
		return [Rect2(0, 0, clampf(w * s, 90.0, room), clampf(h * s, 90.0, 260.0))]
	var cols: int = 3 if count == 3 else 2
	var side: float = minf((minf(room, 400.0) - 6.0 * (cols - 1)) / cols, 160.0)
	var out: Array = []
	for i in range(count):
		out.append(Rect2((i % cols) * (side + 6.0), floorf(i / float(cols)) * (side + 6.0), side, side))
	return out


func _fr_card(post: Dictionary, at: Vector2, wide: float, full: bool) -> void :
	var lay: Dictionary = _fr_lay(post, wide, full)
	var id: int = int(post.id)
	var by: int = int(post.by)
	var box: Rect2 = _lr(at, Vector2(wide, float(lay.high)))
	_round(box, FR_CARD, 12.0, Color(EDGE, 0.45), 1.0)
	if not full:
		_hit("m:fr:open:%d" % id, box, false)
	_disc(by, at + Vector2(30, 28), 17.0, true)
	var name_room: float = wide - 150.0
	var used: float = _fwords(_clip(str(post.name), BOLD, 13.0, name_room), BOLD, 13.0, Color.WHITE, "l", at + Vector2(56, 8), name_room, 1.0, 20.0, false)
	_hit("m:fr:user:%d" % by, _lr(at + Vector2(8, 6), Vector2(54.0 + used, 44)), false)
	var sub: String = _when(int(post.at))
	if bool(post.followed) and by != client.account_oid:
		sub += " · Đang theo dõi"
	_fwords(sub, REGULAR, 10.0, DIM, "l", at + Vector2(56, 28), name_room, 0.0, 16.0, false)
	var more_at: Vector2 = at + Vector2(wide - 42.0, 10.0)
	var more: Rect2 = _lr(more_at, Vector2(32, 24))
	_round(more, Color("1a3a5e") if _hover == "m:fr:more:%d" % id else Color("0f2643"), 12.0, Color(EDGE, 0.7), 1.0)
	_fwords("⋯", BOLD, 14.0, Color.WHITE, "c", more_at, 32.0, 0.0, 24.0)
	_hit("m:fr:more:%d" % id, more, false)
	_fr_more_at[id] = more_at + Vector2(32, 28)
	var rows: Array = lay.rows
	for i in range(rows.size()):
		for seg: Array in rows[i]:
			_fwords(str(seg[0]), REGULAR, 13.0, seg[1], "l", at + Vector2(12.0 + float(seg[2]), float(lay.text_y) + FR_LINE * i), wide, 0.0, FR_LINE, false)
	if bool(lay.cut):
		_fwords("Xem thêm…", SEMI, 12.0, Color("6fd0ff"), "l", at + Vector2(12, float(lay.text_y) + FR_LINE * rows.size()), 120.0, 0.0, 18.0, false)
	var x: float = 12.0
	for tag: String in lay.tags:
		var text: String = "#" + tag
		var w: float = _wide(text, SEMI, 11.0) + 16.0
		if x + w > wide - 12.0:
			break
		var chip_at: Vector2 = at + Vector2(x, float(lay.tags_y))
		var chip: Rect2 = _lr(chip_at, Vector2(w, 22))
		_round(chip, Color(BLUE, 0.3) if _hover == "m:fr:tag:" + tag else Color(BLUE, 0.16), 11.0, Color("6fd0ff", 0.6), 1.0)
		_fwords(text, SEMI, 11.0, Color("9fdcff"), "c", chip_at, w, 0.0, 22.0)
		_hit("m:fr:tag:" + tag, chip, false)
		x += w + 6.0
	var images: Array = post.get("images", [])
	for i in range(mini(images.size(), (lay.grid as Array).size())):
		var cell: Rect2 = lay.grid[i]
		var shown: Rect2 = Rect2(at + Vector2(12, float(lay.grid_y)) + cell.position, cell.size)
		_fr_pic(str(images[i].id), shown, images.size() > 1)
		_hit("m:fr:pic:%d:%d" % [id, i], _lr(shown.position, shown.size), false)
	var act_y: float = at.y + float(lay.act_y)
	draw_line(_lr(Vector2(at.x + 10.0, act_y - 2.0), Vector2.ZERO).position, _lr(Vector2(at.x + wide - 10.0, act_y - 2.0), Vector2.ZERO).position, Color(EDGE, 0.35), maxf(1.0, _f * 0.5))
	var third: float = (wide - 20.0) / 3.0
	var liked: bool = bool(post.liked)
	var acts: Array = [["m:fr:like:%d" % id, "heart_on" if liked else "heart", str(int(post.likes)) if int(post.likes) > 0 else "Thích", PICKED if liked else Color("cfe6ff")], 
		["m:fr:open:%d" % id if not full else "m:fr:focus", "comment", str(int(post.comments)) if int(post.comments) > 0 else "Bình luận", Color("cfe6ff")], 
		["m:fr:share:%d" % id, "share", "Chia sẻ", Color("cfe6ff")]]
	for i in range(acts.size()):
		var act: Array = acts[i]
		var cell_at: Vector2 = Vector2(at.x + 10.0 + third * i, act_y)
		var cell: Rect2 = _lr(cell_at, Vector2(third, 30))
		if _hover == str(act[0]):
			_round(cell, Color(1, 1, 1, 0.06), 10.0)
		var label_w: float = _wide(str(act[2]), SEMI, 12.0)
		var left: float = cell_at.x + (third - label_w - 24.0) / 2.0
		_glyph(str(act[1]), Vector2(left + 8.0, act_y + 15.0) * _f, 7.0 * _f, act[3])
		_fwords(str(act[2]), SEMI, 12.0, act[3], "l", Vector2(left + 22.0, act_y), label_w + 4.0, 0.0, 30.0, false)
		_hit(str(act[0]), cell, false)


func _fr_pic(image: String, rect: Rect2, cover: bool) -> void :
	var box: Rect2 = _lr(rect.position, rect.size)
	_round(box, Color("0a1626"), 8.0, Color(EDGE, 0.5), 1.0)
	var tex: Texture2D = Forum.picture(client, image)
	if tex == null:
		_fwords("Ảnh đã bị xoá" if Forum.picture_gone(image) else "Đang tải ảnh…", REGULAR, 11.0, DIM, "c", rect.position, rect.size.x, 0.0, rect.size.y)
		return
	var inner: Rect2 = box.grow(-1.0 * _f)
	var natural: Vector2 = tex.get_size()
	if not cover:
		draw_texture_rect(tex, inner, false)
		return
	var aim: float = inner.size.x / maxf(1.0, inner.size.y)
	var src: Rect2 = Rect2(Vector2.ZERO, natural)
	if natural.x / maxf(1.0, natural.y) > aim:
		src.size.x = natural.y * aim
		src.position.x = (natural.x - src.size.x) / 2.0
	else:
		src.size.y = natural.x / aim
		src.position.y = (natural.y - src.size.y) / 2.0
	draw_texture_rect_region(tex, inner, src)


func _fr_thread(body: Rect2) -> void :
	var post: Dictionary = Forum.posts.get(_fr_post, {})
	var blocks: Array = []
	var wide: float = body.size.x - 20.0
	if post.is_empty() or Forum.gone.has(_fr_post):
		var note: String = "Bài đã bị xoá." if Forum.gone.has(_fr_post) else "Đang tải bài…"
		blocks.append([60.0, func(at: Vector2, w: float) -> void : _fwords(note, REGULAR, 13.0, DIM, "c", at, w, 0.0, 60.0)])
		_fr_scroll_list(body, blocks)
		return
	blocks.append([float(_fr_lay(post, wide, true).high), func(at: Vector2, w: float) -> void : _fr_card(post, at, w, true)])
	var comments: Array = Forum.threads.get(_fr_post, [])
	var heading: String = "Bình luận (%d)" % int(post.comments)
	blocks.append([22.0, func(at: Vector2, w: float) -> void : _fwords(heading, BOLD, 13.0, Color.WHITE, "l", at + Vector2(4, 0), w, 1.0, 22.0)])
	var mine: bool = int(post.by) == client.account_oid
	for row: Dictionary in comments:
		if _fr_blocked.has(int(row.by)):
			continue
		var cache: String = "c%d|%.1f|%.3f" % [int(row.id), wide, _f]
		if not _fr_lays.has(cache):
			_fr_lays[cache] = _flow([[str(row.text), false, Color("e3eefc")]], wide - 70.0, 12.0)[0]
		var rows: Array = _fr_lays[cache]
		var high: float = maxf(40.0, 24.0 + rows.size() * 17.0 + 6.0)
		blocks.append([high, func(at: Vector2, w: float) -> void : _fr_comment_row(row, rows, mine, at, w, high)])
	if comments.is_empty():
		var note: String = "Đang tải bình luận…" if Forum.post_loading(_fr_post) else "Chưa có bình luận — viết bình luận đầu tiên."
		blocks.append([36.0, func(at: Vector2, w: float) -> void : _fwords(note, REGULAR, 12.0, DIM, "c", at, w, 0.0, 36.0)])
	_fr_scroll_list(body, blocks)

func _fr_comment_row(row: Dictionary, rows: Array, on_mine: bool, at: Vector2, wide: float, high: float) -> void :
	_round(_lr(at, Vector2(wide, high)), Color("0e2038"), 10.0)
	_disc(int(row.by), at + Vector2(22, 20), 13.0, false)
	var used: float = _fwords(_clip(str(row.name), BOLD, 12.0, wide - 180.0), BOLD, 12.0, Color.WHITE, "l", at + Vector2(44, 4), wide - 180.0, 1.0, 18.0, false)
	_hit("m:fr:user:%d" % int(row.by), _lr(at + Vector2(6, 2), Vector2(44.0 + used, 36)), false)
	_fwords(_when(int(row.at)), REGULAR, 10.0, DIM, "l", at + Vector2(50.0 + used, 4), 90.0, 0.0, 18.0, false)
	for i in range(rows.size()):
		for seg: Array in rows[i]:
			_fwords(str(seg[0]), REGULAR, 12.0, seg[1], "l", at + Vector2(44.0 + float(seg[2]), 22.0 + 17.0 * i), wide, 0.0, 17.0, false)
	if on_mine or int(row.by) == client.account_oid:
		var sure_id: String = "c%d" % int(row.id)
		var sure: bool = _fr_sure == sure_id and _time - _fr_sure_at < 3.0
		var bat: Vector2 = at + Vector2(wide - 58.0, 4.0)
		var cell: Rect2 = _lr(bat, Vector2(50, 20))
		_round(cell, Color("e5383b") if sure else Color("1a2f4a"), 10.0, Color(EDGE, 0.6), 1.0)
		_fwords("Chắc?" if sure else "Xoá", BOLD, 10.0, Color.WHITE, "c", bat, 50.0, 0.0, 20.0)
		_hit("m:fr:unc:%d" % int(row.id), cell, false)


func _fr_bar(rect: Rect2) -> void :
	var box: Rect2 = _lr(rect.position, rect.size)
	draw_rect(box, BAR_BG)
	draw_line(box.position, Vector2(box.end.x, box.position.y), Color(EDGE, 0.8), maxf(1.0, _f))
	_hit("panel", box, false)
	var y: float = rect.position.y + 9.0
	var x: float = rect.position.x + 10.0
	var right: float = rect.end.x - 10.0 - 60.0
	if Forum.gone.has(_fr_post) or not Forum.posts.has(_fr_post):
		return
	if int(client.character.get("level", 0)) < Forum.LEVEL:
		_round(_lr(Vector2(x, y), Vector2(rect.size.x - 20.0, 32)), FIELD, 16.0, Color(EDGE, 0.5), 1.0)
		_fwords("Cần cấp %d để bình luận." % Forum.LEVEL, REGULAR, 12.0, DIM, "l", Vector2(x + 12.0, y), rect.size.x - 44.0, 0.0, 32.0)
		return
	_round(_lr(Vector2(x, y), Vector2(right - 6.0 - x, 32)), FIELD, 16.0, Color(EDGE, 0.7), 1.0)
	_fput(_fr_say, Rect2(Vector2(x + 10.0, y), Vector2(right - 6.0 - x - 16.0, 32)), 14.0, "l", true)
	_fr_said = true
	var go: Rect2 = _lr(Vector2(right, y), Vector2(60, 32))
	_round(go, BLUE.lightened(0.12) if _hover == "m:fr:say" else BLUE, 16.0)
	_fwords("Gửi", BOLD, 14.0, Color.WHITE, "c", Vector2(right, y), 60.0, 0.0, 32.0)
	_hit("m:fr:say", go, false)


func _fr_compose(body: Rect2) -> void :
	var x: float = body.position.x + 12.0
	var wide: float = body.size.x - 24.0
	var y: float = body.position.y + 10.0
	if int(client.character.get("level", 0)) < Forum.LEVEL:
		_fwords("Cần cấp %d để viết trên diễn đàn." % Forum.LEVEL, BOLD, 14.0, Color.WHITE, "c", Vector2(x, y + 60.0), wide, 1.0, 26.0)
		return
	var high: float = clampf(body.size.y - 210.0, 110.0, 200.0)
	_round(_lr(Vector2(x, y), Vector2(wide, high)), FIELD, 12.0, Color(EDGE, 0.8), 1.0)
	_fr_text.position = Vector2(x + 6.0, y + 4.0) * _f
	_fr_text.size = Vector2(wide - 12.0, high - 8.0) * _f
	_fr_text.add_theme_font_size_override("font_size", maxi(8, roundi(14.0 * _f)))
	_fr_text.visible = true
	_fr_wrote = true
	y += high + 4.0
	var count: int = _fr_text.text.length()
	_fwords("Gắn chủ đề bằng #tên (tối đa 5)", REGULAR, 11.0, DIM, "l", Vector2(x + 4.0, y), wide - 90.0, 0.0, 18.0)
	_fwords("%d/%d" % [count, Forum.TEXT_MAX], SEMI, 11.0, Color("ff9a9a") if count >= Forum.TEXT_MAX else DIM, "r", Vector2(x, y), wide - 4.0, 0.0, 18.0)
	y += 26.0
	var side: float = 76.0
	var tx: float = x
	for i in range(Forum.draft.size()):
		var image: Dictionary = Forum.draft[i]
		_fr_pic(str(image.id), Rect2(Vector2(tx, y), Vector2(side, side)), true)
		var drop_at: Vector2 = Vector2(tx + side - 22.0, y + 2.0)
		var drop: Rect2 = _lr(drop_at, Vector2(20, 20))
		_round(drop, Color("e5383b") if _hover == "m:fr:unpick:%d" % i else Color(0, 0, 0, 0.7), 10.0, Color.WHITE, 1.0)
		_fwords("×", BOLD, 13.0, Color.WHITE, "c", drop_at, 20.0, 0.0, 20.0)
		_hit("m:fr:unpick:%d" % i, drop, false)
		tx += side + 8.0
	for i in range(Forum.uploading):
		_round(_lr(Vector2(tx, y), Vector2(side, side)), Color("0a1626"), 8.0, Color(EDGE, 0.5), 1.0)
		_fwords("Đang tải…", REGULAR, 10.0, DIM, "c", Vector2(tx, y), side, 0.0, side)
		tx += side + 8.0
	if Forum.draft.size() + Forum.uploading < Forum.IMAGES_MAX:
		var add: Rect2 = _lr(Vector2(tx, y), Vector2(side, side))
		_round(add, Color("163a5f") if _hover == "m:fr:addimg" else Color("10253f"), 8.0, Color(EDGE, 0.9), 1.0)
		_glyph("image", (Vector2(tx + side / 2.0, y + side / 2.0 - 8.0)) * _f, 9.0 * _f, Color("cfe6ff"))
		_fwords("+ Ảnh", BOLD, 11.0, Color("cfe6ff"), "c", Vector2(tx, y + side - 26.0), side, 0.0, 20.0)
		_hit("m:fr:addimg", add, false)
	y += side + 16.0
	var send_at: Vector2 = Vector2(x + wide - 110.0, y)
	var send: Rect2 = _lr(send_at, Vector2(110, 34))
	var busy: bool = Forum.creating() or Forum.uploading > 0
	_round(send, Color("3a4f66") if busy else (BLUE.lightened(0.12) if _hover == "m:fr:send" else BLUE), 17.0, Color("6fd0ff"), 1.0)
	_fwords("Đang đăng…" if Forum.creating() else "Đăng bài", BOLD, 13.0, Color.WHITE, "c", send_at, 110.0, 0.0, 34.0)
	_hit("m:fr:send", send, false)
	var cancel_at: Vector2 = send_at - Vector2(96, 0)
	var cancel: Rect2 = _lr(cancel_at, Vector2(86, 34))
	_round(cancel, Color("1a3a5e") if _hover == "m:fr:back" else Color("10253f"), 17.0, Color(EDGE, 0.9), 1.0)
	_fwords("Để sau", BOLD, 13.0, Color.WHITE, "c", cancel_at, 86.0, 0.0, 34.0)
	_hit("m:fr:back", cancel, false)

func _fr_notices(body: Rect2) -> void :
	var blocks: Array = []
	var words: Dictionary = {"like": "đã thích bài của bạn", "comment": "đã bình luận bài của bạn", "follow": "đã theo dõi bạn"}
	for i in range(Forum.notices.size()):
		var row: Dictionary = Forum.notices[i]
		if _fr_blocked.has(int(row.by)):
			continue
		var index: int = i
		blocks.append([52.0, func(at: Vector2, w: float) -> void : _fr_notice_row(index, row, str(words.get(str(row.kind), "")), at, w)])
	if blocks.is_empty():
		blocks.append([60.0, func(at: Vector2, w: float) -> void : _fwords("Chưa có thông báo nào.", REGULAR, 12.0, DIM, "c", at, w, 0.0, 60.0)])
	_fr_scroll_list(body, blocks)

func _fr_notice_row(index: int, row: Dictionary, word: String, at: Vector2, w: float) -> void :
	var id: String = "m:fr:note:%d" % index
	_round(_lr(at, Vector2(w, 52)), Color("173556") if _hover == id else FR_CARD, 10.0, Color(EDGE, 0.4), 1.0)
	_disc(int(row.by), at + Vector2(26, 26), 16.0, false)
	var used: float = _fwords(_clip(str(row.name), BOLD, 12.0, w * 0.45), BOLD, 12.0, Color.WHITE, "l", at + Vector2(52, 6), w * 0.45, 1.0, 20.0, false)
	_fwords(word, REGULAR, 12.0, Color("cfe6ff"), "l", at + Vector2(56.0 + used, 6), w - 130.0 - used, 0.0, 20.0)
	var excerpt: String = str(row.get("excerpt", "")).replace("\n", " ")
	if not excerpt.is_empty():
		_fwords(_clip("“" + excerpt + "”", REGULAR, 11.0, w - 130.0), REGULAR, 11.0, DIM, "l", at + Vector2(52, 27), w - 130.0, 0.0, 18.0, false)
	_fwords(_when(int(row.at)), REGULAR, 10.0, DIM, "r", at + Vector2(w - 92.0, 6), 84.0, 0.0, 18.0, false)
	_hit(id, _lr(at, Vector2(w, 52)), false)


func _fr_draw_menu() -> void :
	var id: int = int(_fr_menu.id)
	var post: Dictionary = Forum.posts.get(id, {})
	if post.is_empty() or not _fr_more_at.has(id):
		_fr_menu = {}
		return
	var items: Array = []
	if int(post.by) == client.account_oid:
		var sure: bool = _fr_sure == "p%d" % id and _time - _fr_sure_at < 3.0
		items.append(["m:fr:del:%d" % id, "Bấm lần nữa để xoá" if sure else "Xoá bài", Color("ff9a9a")])
	else:
		items.append(["m:fr:follow:%d" % int(post.by), "Bỏ theo dõi" if bool(post.followed) else "Theo dõi %s" % _clip(str(post.name), SEMI, 12.0, 90.0), Color.WHITE])
		items.append(["m:fr:report:%d" % id, "Đã báo cáo" if Forum.reported.has(id) else "Báo cáo bài", Color("ff9a9a")])
	items.append(["m:fr:share:%d" % id, "Chia sẻ vào chat", Color.WHITE])
	var wide: float = 170.0
	var corner: Vector2 = _fr_more_at[id]
	var at: Vector2 = Vector2(corner.x - wide, corner.y)
	var high: float = items.size() * 32.0 + 8.0
	var limit: float = panel_rect().end.y - 8.0
	if at.y + high > limit:
		at.y = corner.y - 28.0 - high - 4.0
	var box: Rect2 = _lr(at, Vector2(wide, high))
	_round(box, Color("0d2240"), 10.0, Color(EDGE, 1.0), 1.0)
	_hit("m:fr:menu", box, false)
	for i in range(items.size()):
		var item: Array = items[i]
		var cell_at: Vector2 = at + Vector2(4, 4 + 32.0 * i)
		var cell: Rect2 = _lr(cell_at, Vector2(wide - 8.0, 30))
		if _hover == str(item[0]):
			_round(cell, Color(1, 1, 1, 0.08), 8.0)
		_fwords(str(item[1]), SEMI, 12.0, item[2], "l", cell_at + Vector2(10, 0), wide - 28.0, 0.0, 30.0)
		_hit(str(item[0]), cell, false)


func _draw_forum_viewer() -> void :
	var post: Dictionary = Forum.posts.get(int(_viewing.forum), {})
	var images: Array = post.get("images", [])
	if images.is_empty():
		_viewing = {}
		return
	var index: int = clampi(int(_viewing.index), 0, images.size() - 1)
	var panel: Rect2 = panel_rect()
	var box: Rect2 = _lr(panel.position, panel.size)
	draw_rect(box, Color(0, 0, 0, 0.9))
	_hit("m:fr:view:close", box, false)
	var image: Dictionary = images[index]
	var room: Rect2 = panel.grow_individual(-24.0, -24.0, -24.0, -72.0)
	var tex: Texture2D = Forum.picture(client, str(image.id))
	var natural: Vector2 = tex.get_size() if tex != null else Vector2(float(image.get("w", 4)), float(image.get("h", 3)))
	var s: float = minf(room.size.x / maxf(1.0, natural.x), room.size.y / maxf(1.0, natural.y))
	var shown: Vector2 = natural * s
	var at: Vector2 = room.position + (room.size - shown) / 2.0
	if tex != null:
		draw_texture_rect(tex, _lr(at, shown), false)
	else:
		_fwords("Ảnh đã bị xoá" if Forum.picture_gone(str(image.id)) else "Đang tải ảnh…", REGULAR, 14.0, DIM, "c", room.position, room.size.x, 0.0, room.size.y)
	var y: float = panel.end.y - 56.0
	var mid: float = panel.position.x + panel.size.x / 2.0
	var buttons: Array = [["m:fr:view:close", "Đóng"]]
	if images.size() > 1:
		buttons = [["m:fr:view:prev", "‹"], ["m:fr:view:close", "%d / %d" % [index + 1, images.size()]], ["m:fr:view:next", "›"]]
	var x: float = mid - (buttons.size() * 110.0 - 10.0) / 2.0
	for button: Array in buttons:
		var cell: Rect2 = _lr(Vector2(x, y), Vector2(100, 34))
		_round(cell, BLUE.lightened(0.12 if _hover == str(button[0]) else 0.0), 17.0, Color("6fd0ff"), 1.0)
		_fwords(str(button[1]), BOLD, 14.0, Color.WHITE, "c", Vector2(x, y), 100.0, 0.0, 34.0)
		_hit(str(button[0]), cell, false)
		x += 110.0


func _draw_post_card(item: Dictionary, rect: Rect2, own: bool) -> void :
	var line: Dictionary = item["line"]
	var id: int = int(item["post"])
	var box: Rect2 = _lr(rect.position, rect.size)
	_round(box, (OWN_BUBBLE if own else OTHER_BUBBLE).lightened(0.08 if _hover == "m:fr:open:%d" % id else 0.0), 12.0, Color("6fd0ff", 0.75), 1.0)
	var icon: Rect2 = _lr(rect.position + Vector2(8, 9), Vector2(38, 38))
	_round(icon, Color(BLUE, 0.35), 10.0)
	_glyph("forum", icon.get_center(), 9.0 * _f, Color.WHITE)
	_fwords("Bài viết diễn đàn", BOLD, 12.0, Color("9fdcff"), "l", rect.position + Vector2(54, 8), rect.size.x - 62.0, 0.0, 18.0)
	var excerpt: String = str(line.get("text", "")).trim_prefix(": ").trim_prefix(Forum.SHARE_HEAD)
	_fwords(_clip(excerpt, REGULAR, 12.0, rect.size.x - 64.0), REGULAR, 12.0, Color("eef5ff"), "l", rect.position + Vector2(54, 28), rect.size.x - 62.0, 0.0, 18.0, false)
	_hit("m:fr:open:%d" % id, box, false)


func _forum_tick() -> void :
	var looking: bool = _open and _view == "forum"
	Forum.want_bell(client, FR_BELL_OPEN if looking else FR_BELL_IDLE)
	if looking or Forum.uploading > 0:
		Forum.poll()
	for note: Dictionary in Forum.take():
		match str(note.kind):
			"say":
				say(str(note.text))
			"created":
				_fr_text.text = ""
				_fr_stack = []
				_fr_tab = "explore"
				_fr_hot = false
				_fr_page = "post"
				_fr_post = int(note.id)
				_fr_scroll = 0.0
			"removed":
				_fr_lays.clear()
				if _fr_page == "post" and _fr_post == int(note.id):
					_fr_go_back()
	if looking and Forum.online(client):
		if _fr_page == "feed":
			if _fr_tab == "topic":
				Forum.want_tags(client, FR_TAGS_EVERY)
				if _fr_tag.is_empty() and not Forum.tags.is_empty():
					_fr_tag = str(Forum.tags[0].tag)
			var key: String = _fr_key()
			if not key.is_empty() and Forum.feed(key).is_empty():
				_fr_want_feed()
		elif _fr_page == "post" and not Forum.gone.has(_fr_post):
			Forum.want_post(client, _fr_post)
	if _fr_share.is_empty():
		return
	var sent: Variant = client.get("_chat_sent")
	if sent != null and Time.get_ticks_msec() / 1000.0 - float(sent) < 2.05:
		if _time - float(_fr_share.at) > 20.0:
			_fr_share = {}
		return
	var share: Dictionary = _fr_share
	_fr_share = {}
	var wire: Dictionary = {"post": int(share.id)}
	var ok: bool = false
	if int(share.chan) == 4:
		ok = client.send_chat_channel(str(share.text), 4, wire)
	else:
		if str(share.tab) == "whisper":
			client.whisper_to = share.whisper
		ok = client.send_chat(str(share.text), int(SEND_ON.get(str(share.tab), 2)), wire, int(share.chan) == 2)
	if ok:
		say("Đã chia sẻ lên kênh %s." % str(share.label))

func _fr_can() -> bool:
	if int(client.character.get("level", 0)) >= Forum.LEVEL:
		return true
	say("Cần cấp %d để viết trên diễn đàn." % Forum.LEVEL)
	return false

func _fr_push() -> void :
	_fr_stack.append([_fr_page, _fr_post, _fr_tab, _fr_user, _fr_tag, _fr_scroll])
	if _fr_stack.size() > 12:
		_fr_stack.pop_front()

func _fr_go_back() -> void :
	_fr_sure = ""
	if _fr_stack.is_empty():
		_fr_page = "feed"
		_fr_scroll = 0.0
		return
	var last: Array = _fr_stack.pop_back()
	_fr_page = str(last[0])
	_fr_post = int(last[1])
	_fr_tab = str(last[2])
	_fr_user = int(last[3])
	_fr_tag = str(last[4])
	_fr_scroll = float(last[5])


func _fr_open(id: int) -> void :
	if id <= 0:
		return
	if _view == "forum":
		_fr_push()
	else:
		_view = "forum"
		_fr_stack = []
	_fr_page = "post"
	_fr_post = id
	_fr_scroll = 0.0
	Forum.want_post(client, id, true)

func _fr_share_post(id: int) -> void :
	var post: Dictionary = Forum.posts.get(id, {})
	if post.is_empty():
		return
	if HORNS.has(_chan):
		say("Không chia sẻ bằng loa — đổi kênh chat trước.")
		return
	if not _fr_share.is_empty():
		say("Đang chia sẻ bài trước — chờ chút.")
		return
	_fr_share = {"id": id, "text": Forum.share_text(post), "tab": _tab, "chan": _chan, "whisper": client.whisper_to.duplicate(), "label": _chip_label(), "at": _time}

func _fr_comment() -> void :
	var text: String = _fr_say.text.strip_edges()
	if text.is_empty() or _fr_post <= 0 or not _fr_can():
		return
	Forum.comment(client, _fr_post, text)
	_fr_say.text = ""

func _fr_publish() -> void :
	if not _fr_can() or Forum.creating():
		return
	if Forum.uploading > 0:
		say("Chờ ảnh tải xong rồi đăng.")
		return
	var text: String = _fr_text.text.strip_edges()
	if text.is_empty() and Forum.draft.is_empty():
		say("Bài trống — viết gì đó hoặc thêm ảnh.")
		return
	Forum.create(client, text)


func _fr_follows(user: int) -> bool:
	if Forum.profiles.has(user):
		return bool(Forum.profiles[user].followed)
	for post: Dictionary in Forum.posts.values():
		if int(post.by) == user:
			return bool(post.followed)
	return false

func _fr_act(id: String) -> void :
	if not id.begins_with("view:"):
		_viewing = {}
	var menu_was: Dictionary = _fr_menu
	_fr_menu = {}
	var parts: PackedStringArray = id.split(":")
	var arg: String = parts[1] if parts.size() > 1 else ""
	if not menu_was.is_empty() and parts[0] not in ["menu", "more", "del", "follow", "report", "share"]:
		return
	match parts[0]:
		"tab":
			if arg == _fr_tab and _fr_page == "feed" and _fr_user == 0:
				_fr_scroll = 0.0
				_fr_want_feed(true)
				if arg == "topic":
					Forum.want_tags(client, 0.0)
				return
			_fr_tab = arg
			_fr_user = 0
			_fr_page = "feed"
			_fr_stack = []
			_fr_scroll = 0.0
			_fr_want_feed()
		"hot":
			_fr_hot = arg == "1"
			_fr_scroll = 0.0
			_fr_want_feed()
		"tag":
			if _fr_page != "feed":
				_fr_push()
			_fr_tab = "topic"
			_fr_tag = arg
			_fr_page = "feed"
			_fr_scroll = 0.0
			_fr_want_feed()
		"user":
			var user: int = int(arg)
			if user <= 0:
				return
			_fr_push()
			_fr_tab = "me"
			_fr_user = 0 if user == client.account_oid else user
			_fr_page = "feed"
			_fr_scroll = 0.0
			_fr_want_feed(true)
		"open":
			_fr_open(int(arg))
		"more":
			if menu_was.is_empty() or int(menu_was.id) != int(arg):
				_fr_menu = {"id": int(arg)}
		"menu":
			_fr_menu = menu_was
		"like":
			var post: Dictionary = Forum.posts.get(int(arg), {})
			if not post.is_empty() and _fr_can():
				Forum.like(client, int(arg), not bool(post.liked))
		"share":
			_fr_share_post(int(arg))
		"follow":
			if _fr_can():
				Forum.follow(client, int(arg), not _fr_follows(int(arg)))
		"report":
			if not Forum.report(client, int(arg)):
				say("Bạn đã báo cáo bài này.")
		"del":
			if _fr_sure == "p" + arg and _time - _fr_sure_at < 3.0:
				_fr_sure = ""
				Forum.remove(client, int(arg))
			else:
				_fr_sure = "p" + arg
				_fr_sure_at = _time
				_fr_menu = menu_was
		"unc":
			if _fr_sure == "c" + arg and _time - _fr_sure_at < 3.0:
				_fr_sure = ""
				Forum.uncomment(client, _fr_post, int(arg))
			else:
				_fr_sure = "c" + arg
				_fr_sure_at = _time
		"pic":
			_viewing = {"forum": int(arg), "index": int(parts[2]) if parts.size() > 2 else 0}
		"view":
			if arg == "close":
				_viewing = {}
			elif not _viewing.is_empty():
				var count: int = (Forum.posts.get(int(_viewing.forum), {}).get("images", []) as Array).size()
				_viewing.index = posmod(int(_viewing.index) + (1 if arg == "next" else -1), maxi(1, count))
		"compose":
			if _fr_can():
				_fr_push()
				_fr_page = "compose"
				if not _mobile:
					_fr_text.grab_focus.call_deferred()
		"addimg":
			if not Forum.usable():
				say(ChatMedia.why_not("Chọn ảnh"))
			elif Forum.draft.size() + Forum.uploading >= Forum.IMAGES_MAX:
				say("Tối đa %d ảnh mỗi bài." % Forum.IMAGES_MAX)
			else:
				Forum.pick_images()
		"unpick":
			Forum.unpick(int(arg))
		"send":
			_fr_publish()
		"bell":
			_fr_push()
			_fr_page = "notices"
			_fr_scroll = 0.0
			Forum.want_notices(client)
		"note":
			var index: int = int(arg)
			if index >= 0 and index < Forum.notices.size():
				var row: Dictionary = Forum.notices[index]
				if str(row.kind) == "follow" or int(row.post) <= 0:
					_fr_act("user:%d" % int(row.by))
				else:
					_fr_open(int(row.post))
		"back":
			_fr_go_back()
		"say":
			_fr_comment()
		"focus":
			_fr_say.grab_focus()

func _draw_settings(rect: Rect2) -> void :
	var x: float = rect.position.x + 18.0
	var y: float = rect.position.y + 18.0
	_fwords("Kiểu khung chat", BOLD, 14.0, Color.WHITE, "l", Vector2(x, y), 240.0, 0.0, 24.0)
	y += 28.0
	_option("m:noop", "Mới", true, Vector2(x, y), 100.0)
	_option("m:mode:classic", "Cổ điển", false, Vector2(x + 110.0, y), 100.0)
	y += 52.0
	_fwords("Số dòng khi thu gọn", BOLD, 14.0, Color.WHITE, "l", Vector2(x, y), 240.0, 0.0, 24.0)
	y += 28.0
	for i in range(MINI_ROWS.size()):
		var rows: int = int(MINI_ROWS[i])
		_option("m:mini:%d" % rows, str(rows), rows == mini_rows, Vector2(x + 70.0 * i, y), 60.0)
	y += 52.0

	_bg_row("Nền khi rê chuột", true, Vector2(x, y))
	y += 74.0
	_bg_row("Nền khi ẩn", false, Vector2(x, y))
	y += 74.0
	_fwords("Độ đậm nền", BOLD, 14.0, Color.WHITE, "l", Vector2(x, y), 240.0, 0.0, 24.0)
	y += 28.0
	for i in range(ChatBg.STRENGTHS.size()):
		_option("m:bga:%d" % i, str(ChatBg.STRENGTHS[i]), i == bg_alpha, Vector2(x + 70.0 * i, y), 60.0)
	_option("m:bgreset", "Mặc định", false, Vector2(x + 222.0, y), 100.0)
	y += 52.0
	_option("m:wipe", "Xoá màn hình chat", false, Vector2(x, y), 180.0)
	_fwords("Ẩn các tin đang có ở mọi kênh (không xoá ở máy chủ).", REGULAR, 11.0, DIM, "l", Vector2(x, y + 38.0), rect.size.x - 36.0, 0.0, 18.0)

func _option(id: String, text: String, on: bool, at: Vector2, wide: float) -> void :
	var box: Rect2 = _lr(at, Vector2(wide, 34))
	_round(box, Color(PICKED, 0.9) if on else (Color("173556") if _hover == id else Color("112a47")), 12.0, Color(PICKED) if on else Color(EDGE, 0.8), 1.0)
	_fwords(text, BOLD, 13.0, Color("1a0f00") if on else Color.WHITE, "c", at, wide, 0.0, 34.0)
	if id != "m:noop":
		_hit(id, box, false)



func _bg_row(title: String, hover: bool, at: Vector2) -> void :
	var tag: String = "m:bgh:" if hover else "m:bgi:"
	var chosen: String = bg_hover if hover else bg_idle
	var named: String = chosen
	var keys: Array = ChatBg.keys(hover)
	for key: String in keys:
		if _hover == tag + key:
			named = key
	var used: float = _fwords(title, BOLD, 14.0, Color.WHITE, "l", at, 200.0, 0.0, 24.0, false)
	_fwords(str(ChatBg.NAMES[named]), REGULAR, 12.0, PICKED if named == chosen else DIM, "l", at + Vector2(used + 10.0, 0), 150.0, 0.0, 24.0)
	for i in range(keys.size()):
		var key: String = str(keys[i])
		var box: Rect2 = _lr(at + Vector2(38.0 * i - 2.0, 26.0), Vector2(34, 34))
		var c: Vector2 = box.get_center()
		var r: float = 15.0 * _f
		var on: bool = key == chosen
		if on:
			draw_circle(c, r + 2.5 * _f, PICKED, false, 2.0 * _f, true)
		elif _hover == tag + key:
			draw_circle(c, r + 2.0 * _f, Color(BLUE, 0.9), false, 1.5 * _f, true)
		if key == "default":
			draw_circle(c, r, Color("0a1729"), true, -1.0, true)
			var half: PackedVector2Array = PackedVector2Array()
			for k in range(17):
				half.append(c + Vector2.from_angle(PI * 0.75 + PI * k / 16.0) * r)
			_poly(half, Color.BLACK)
		elif key == "clear":
			draw_circle(c, r, Color("27384d"), true, -1.0, true)
			for k in range(-2, 2):
				for j in range(-2, 2):
					if (k + j) % 2 == 0:
						var cell: Rect2 = Rect2(c + Vector2(k, j) * 7.0 * _f, Vector2(7, 7) * _f)
						if cell.get_center().distance_to(c) < r - 3.0 * _f:
							draw_rect(cell, Color("4a5d75"))
			draw_line(c + Vector2(-0.7, 0.7) * r, c + Vector2(0.7, -0.7) * r, Color("e0464b"), 2.0 * _f, true)
		else:
			draw_circle(c, r, ChatBg.swatch(key), true, -1.0, true)
		draw_circle(c, r, Color(EDGE, 0.9) if not on else Color(PICKED, 0.0), false, 1.0 * _f, true)
		_hit(tag + key, box, false)


func bg_default() -> bool:
	return bg_hover == "default" and bg_idle == "default"



func bg_tint(hover_base: Color, idle_base: Color) -> Color:
	if bg_default():
		return hover_base if _awake else idle_base
	return ChatBg.blend(ChatBg.lobby(bg_idle, bg_alpha, false, idle_base), ChatBg.lobby(bg_hover, bg_alpha, true, hover_base), _bg_mix)


func _bg_act(id: String) -> void :
	if id.begins_with("bgh:"):
		bg_hover = ChatBg.sane(id.substr(4), true)
	elif id.begins_with("bgi:"):
		bg_idle = ChatBg.sane(id.substr(4), false)
	elif id.begins_with("bga:"):
		bg_alpha = ChatBg.sane_alpha(int(id.substr(4)))
	elif id == "bgreset":
		bg_hover = "default"
		bg_idle = "default"
		bg_alpha = ChatBg.DEFAULT_ALPHA
	_save()




func _tag(line: Dictionary) -> Array:
	var channel: int = int(line.get("channel", 0))
	if channel == 2 and str(line.get("tab", "")) == "room":
		return TAGS[8]
	return TAGS.get(channel, TAGS[0])


func _body(line: Dictionary) -> Array:
	var parts: Array = _content(line)
	if not parts.is_empty() and (parts[0] as Array).size() <= 4:
		var first: Array = (parts[0] as Array).duplicate()
		first[0] = str(first[0]).trim_prefix(": ")
		parts[0] = first
		if str(first[0]).is_empty() and parts.size() > 1:
			parts.remove_at(0)
	return parts

static func _plain_text(line: Dictionary) -> String:
	return (str(line.get("head", "")) + str(line.get("name", "")) + str(line.get("text", ""))).strip_edges()


func _draw_name(line: Dictionary, name: String, at: Vector2, room: float, px: float, high: float, edge: float = 1.0, rim: Color = SHADE) -> float:
	var ink: PackedColorArray = NameStyles.chat_colors(client, line, name)
	var used: float = 0.0
	if not ink.is_empty():
		used = NameStyles.place(self, name, SEMI, px, "l", at, room, edge, high, false, ink, true, rim)
	else:
		used = _fwords(name, SEMI, px, line.get("name_color", Color.WHITE), "l", at, room, edge, high, false, rim)

	var love_oid: int = int(line.get("who_oid", 0))
	if love_oid <= 0:
		love_oid = int(line.get("oid", 0))
	if love_oid > 0 and int(line.get("channel", 0)) != 0 and used + 18.0 <= room and Love.near(client, love_oid):
		Love.fdraw(self, at + Vector2(used + Love.NAME_GAP, (high - Love.SIDE) / 2.0 if high > Love.SIDE else 0.0), Love.SIDE)
		return used + 18.0
	return used


func _flow(parts: Array, room: float, px: float) -> Array:
	var size: int = maxi(6, roundi(px * _f))
	var font: Font = ARIAL
	var rows: Array = []
	var row: Array = []
	var x: float = 0.0
	var widest: float = 0.0
	for part: Array in parts:
		if part.size() > 4:
			if x > 0.0 and x + EMO_SIDE > room:
				rows.append(row)
				widest = maxf(widest, x)
				row = []
				x = 0.0
			row.append(["", part[2], x, str(part[4])])
			x += EMO_SIDE + 1.0
			continue
		var rest: String = str(part[0])
		while not rest.is_empty():
			var fit: int = _fit(rest, font, size, room - x)
			if fit >= rest.length():
				row.append([rest, part[2], x, ""])
				x += font.get_string_size(rest, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / _f
				break
			var cut: int = rest.substr(0, fit + 1).rfind(" ") if fit > 0 else -1
			if cut <= 0:
				if x > 0.0:
					rows.append(row)
					widest = maxf(widest, x)
					row = []
					x = 0.0
					rest = rest.lstrip(" ")
					continue
				cut = maxi(1, fit)
				row.append([rest.substr(0, cut), part[2], x, ""])
				rest = rest.substr(cut)
			else:
				row.append([rest.substr(0, cut), part[2], x, ""])
				rest = rest.substr(cut + 1).lstrip(" ")
			widest = maxf(widest, x + font.get_string_size(str(row[-1][0]), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / _f)
			rows.append(row)
			row = []
			x = 0.0
	if not row.is_empty():
		rows.append(row)
		widest = maxf(widest, x)
	if rows.is_empty():
		rows.append([])
	return [rows, widest]


func items(wide: float) -> Array:
	var key: Array = [client.chat_rev, client.chat_log.size(), _view, _col, _peer, _wiped, _f, _emotes.rev, wide, client.account_oid, ChatPrivate.rev]
	if key == _items_key:
		return _items
	_items_key = key
	_items = []
	_items_h = 0.0
	var lines: Array = []
	var after: int = 0
	if _view == "friends" and not _peer.is_empty() and ChatPrivate.history.has(_peer_oid):
		var known: Dictionary = ChatPrivate.history[_peer_oid]
		after = int(known.rev)
		if _wiped < after:
			for row: Dictionary in known.rows:
				lines.append(_stored_line(row))
	var saved: Dictionary = {}
	if after > 0 and _wiped < after:
		for row: Dictionary in ChatPrivate.history[_peer_oid].rows:
			var mark: String = "%s|%s" % [int(row.from) == client.account_oid, str(ChatMedia.split_stored(str(row.text))[0])]
			saved[mark] = int(saved.get(mark, 0)) + 1
	for raw: Dictionary in client.chat_log:
		if int(raw.get("seq", 0)) > after:
			lines.append(raw)
		elif after > 0 and _wanted(raw):
			var mark: String = "%s|%s" % [int(raw.get("oid", 0)) == client.account_oid, str(raw.get("raw", ""))]
			if int(saved.get(mark, 0)) > 0:
				saved[mark] = int(saved[mark]) - 1
			else:
				lines.append(raw)
	for raw: Dictionary in lines:
		if not raw.has("stored") and not _wanted(raw):
			continue
		var system: bool = int(raw.get("channel", 0)) == 0
		var own: bool = not system and client.account_oid != 0 and int(raw.get("oid", 0)) == client.account_oid
		var item: Dictionary = {"line": raw, "own": own, "system": system}
		var flow: Array
		if not system and raw.get("rp") is Dictionary:
			var lx_card: Vector2 = Vector2(minf(240.0, wide - 80.0), 64.0)
			item["rp"] = raw.rp
			item["rows"] = []
			item["widest"] = lx_card.x
			item["box"] = lx_card
			item["high"] = 20.0 + lx_card.y + GAP
			_items.append(item)
			_items_h += float(item["high"])
			continue
		if not system and int(raw.get("tea", 0)) > 0:
			var tea_card: Vector2 = Vector2(minf(260.0, wide - 80.0), 56.0)
			item["tea"] = int(raw.tea)
			item["rows"] = []
			item["widest"] = tea_card.x
			item["box"] = tea_card
			item["high"] = 20.0 + tea_card.y + GAP
			_items.append(item)
			_items_h += float(item["high"])
			continue
		if not system and int(raw.get("post", 0)) > 0:
			var card: Vector2 = Vector2(minf(260.0, wide - 80.0), 56.0)
			item["post"] = int(raw.post)
			item["rows"] = []
			item["widest"] = card.x
			item["box"] = card
			item["high"] = 20.0 + card.y + GAP
			_items.append(item)
			_items_h += float(item["high"])
			continue
		if not system and raw.get("media") is Dictionary:
			var box: Vector2 = _media_size(raw.media)
			item["media"] = raw.media
			item["rows"] = []
			item["widest"] = box.x
			item["box"] = box
			item["high"] = 20.0 + box.y + GAP
			_items.append(item)
			_items_h += float(item["high"])
			continue
		if system:
			flow = _flow([[_plain_text(raw), false, raw.get("color", Color.WHITE)]], wide - 80.0, 12.0)
			item["high"] = (flow[0] as Array).size() * 18.0 + 10.0 + GAP
		else:
			flow = _flow(_body(raw), wide - (FACE_R * 2.0 + 14.0) - 48.0 - BUBBLE_PAD * 2.0, 14.0)
			item["high"] = 20.0 + (flow[0] as Array).size() * ROW_H + BUBBLE_PAD * 2.0 - 4.0 + GAP
		item["rows"] = flow[0]
		item["widest"] = flow[1]
		_items.append(item)
		_items_h += float(item["high"])
	return _items

func _draw_messages(area: Rect2) -> void :
	_msg_area = _lr(area.position, area.size)
	var inner: Rect2 = area.grow_individual(-10.0, -8.0, -10.0, -6.0)
	var list: Array = items(inner.size.x)
	_scroll_max = maxf(0.0, _items_h - inner.size.y)
	_scroll_px = clampf(_scroll_px, 0.0, _scroll_max)
	if list.is_empty():
		var empty: String = "Chưa có tin nhắn nào." if _view != "friends" or not _peer.is_empty() else ""
		_fwords(empty, REGULAR, 13.0, DIM, "c", Vector2(inner.position.x, inner.position.y + inner.size.y / 2.0 - 12.0), inner.size.x, 0.0, 24.0)
		return

	var y: float = inner.end.y - _items_h + _scroll_px if _items_h > inner.size.y else inner.position.y
	for item: Dictionary in list:
		var high: float = float(item["high"])
		if y + high >= area.position.y - 40.0 and y <= area.end.y + 40.0:
			if item["system"]:
				_draw_system(item, Vector2(inner.position.x, y), inner.size.x)
			else:
				_draw_item(item, Vector2(inner.position.x, y), inner.size.x)
		y += high
	if _scroll_px > 40.0:
		var at: Vector2 = Vector2(inner.end.x - 74.0, inner.end.y - 34.0)
		var button: Rect2 = _lr(at, Vector2(70, 28))
		_round(button, BLUE, 14.0, Color("6fd0ff"), 1.0)
		_fwords("Mới nhất", BOLD, 12.0, Color.WHITE, "c", at, 70.0, 0.0, 28.0)
		_hit("m:bottom", button, false)

func _draw_system(item: Dictionary, at: Vector2, wide: float) -> void :
	var rows: Array = item["rows"]
	var pill_w: float = minf(wide - 40.0, float(item["widest"]) + 24.0)
	var high: float = rows.size() * 18.0 + 6.0
	var left: float = at.x + (wide - pill_w) / 2.0
	_round(_lr(Vector2(left, at.y), Vector2(pill_w, high)), Color("2a1418", 0.75), 10.0, Color(TAGS[0][1], 0.45), 1.0)
	for i in range(rows.size()):
		var row: Array = rows[i]
		var run: float = 0.0
		if not row.is_empty():
			var last: Array = row[-1]
			run = float(last[2]) + _wide(str(last[0]), REGULAR, 12.0)
		var x: float = left + (pill_w - run) / 2.0
		for seg: Array in row:
			_fwords(str(seg[0]), REGULAR, 12.0, Color("ffd6d6"), "l", Vector2(x + float(seg[2]), at.y + 3.0 + 18.0 * i), wide, 0.0, 18.0, false)


func _draw_item(item: Dictionary, at: Vector2, wide: float) -> void :
	var line: Dictionary = item["line"]
	var own: bool = item["own"]
	var rows: Array = item["rows"]
	var seq: int = int(line.get("seq", 0))
	var face_x: float = at.x + wide - FACE_R - 2.0 if own else at.x + FACE_R + 2.0
	_disc(_face_id(line), Vector2(face_x, at.y + FACE_R + 2.0), FACE_R, true)
	if not own and seq > 0 and not target(line).is_empty():
		_hit("m:face:%d" % seq, _lr(Vector2(face_x - FACE_R, at.y + 2.0), Vector2(FACE_R * 2.0, FACE_R * 2.0)), false)
	var tag: Array = _tag(line)
	var name: String = str(line.get("name", ""))
	if own and int(line.get("channel", 0)) == 1:
		name = str(client.character.get("name", name))
	var when : String = str(line.get("stamp", stamp(seq)))
	var tag_w: float = _wide(str(tag[0]), BOLD, 10.0) + 10.0
	var name_w: float = minf(_wide(name, SEMI, 12.0), 160.0)
	var left: float = at.x + FACE_R * 2.0 + 12.0
	var head_y: float = at.y
	if own:
		var x: float = at.x + wide - FACE_R * 2.0 - 12.0
		x -= tag_w
		_pill_tag(tag, Vector2(x, head_y + 2.0), tag_w)
		x -= name_w + 4.0
		_draw_name(line, _clip(name, SEMI, 12.0, 160.0), Vector2(x, head_y), name_w + 2.0, 12.0, 18.0)
		if not when .is_empty():
			_fwords( when , REGULAR, 10.0, DIM, "r", Vector2(x - 84.0, head_y), 80.0, 0.0, 18.0)
	else:
		var x: float = left
		_pill_tag(tag, Vector2(x, head_y + 2.0), tag_w)
		x += tag_w + 4.0
		var used: float = _draw_name(line, _clip(name, SEMI, 12.0, 160.0), Vector2(x, head_y), 164.0, 12.0, 18.0)
		if seq > 0 and not target(line).is_empty():
			_hit("who:%d" % seq, _lr(Vector2(x, head_y), Vector2(used, 18)), false)
		if not when .is_empty():
			_fwords( when , REGULAR, 10.0, DIM, "l", Vector2(x + used + 6.0, head_y), 80.0, 0.0, 18.0)
	if item.has("media"):
		var box: Vector2 = item["box"]
		_draw_media(item["media"], Rect2(Vector2(at.x + wide - FACE_R * 2.0 - 12.0 - box.x if own else left, at.y + 20.0), box), own)
		return
	if item.has("rp"):
		var lx_card: Vector2 = item["box"]
		_draw_lx_card(item, Rect2(Vector2(at.x + wide - FACE_R * 2.0 - 12.0 - lx_card.x if own else left, at.y + 20.0), lx_card), own)
		return
	if item.has("tea"):
		var tea_card: Vector2 = item["box"]
		_draw_tea_card(item, Rect2(Vector2(at.x + wide - FACE_R * 2.0 - 12.0 - tea_card.x if own else left, at.y + 20.0), tea_card), own)
		return
	if item.has("post"):
		var card: Vector2 = item["box"]
		_draw_post_card(item, Rect2(Vector2(at.x + wide - FACE_R * 2.0 - 12.0 - card.x if own else left, at.y + 20.0), card), own)
		return
	var bubble_w: float = float(item["widest"]) + BUBBLE_PAD * 2.0
	var bubble_h: float = rows.size() * ROW_H + BUBBLE_PAD * 2.0 - 4.0
	var bx: float = at.x + wide - FACE_R * 2.0 - 12.0 - bubble_w if own else left
	var by: float = at.y + 20.0
	var horn: bool = int(line.get("channel", 0)) in [128, 256, 2048]
	var fill: Color = OWN_BUBBLE if own else OTHER_BUBBLE
	if horn:
		fill = Color(tag[1], 0.18).blend(Color(OTHER_BUBBLE, 0.82))
	_round(_lr(Vector2(bx, by), Vector2(bubble_w, bubble_h)), fill, 12.0, Color(tag[1], 0.55) if horn else Color(EDGE, 0.55), 1.0)
	var ink: Color = line.get("color", Color.WHITE)
	if not horn and int(line.get("channel", 0)) not in [4, 1]:
		ink = Color("eef5ff")
	for i in range(rows.size()):
		var y: float = by + BUBBLE_PAD - 2.0 + ROW_H * i
		for seg: Array in rows[i]:
			if not str(seg[3]).is_empty():
				_emote(str(seg[3]), Rect2(Vector2(bx + BUBBLE_PAD + float(seg[2]), y + (ROW_H - EMO_SIDE) / 2.0), Vector2(EMO_SIDE, EMO_SIDE)))
				continue
			_fwords(str(seg[0]), REGULAR, 14.0, ink if seg[1] is not Color or not horn else seg[1], "l", Vector2(bx + BUBBLE_PAD + float(seg[2]), y), bubble_w, 0.0, ROW_H, false)



func _tray_act(id: String) -> void :
	if id == "plus" or id == "lxb":
		var lx: bool = id == "lxb"
		if _tray and (_tray_tab == "lx") == lx:
			_tray = false
			return
		_tray = true
		_picker = false
		_quick = false
		_tray_show("lx" if lx else _tray_back)
		return
	if id == "tray":
		return
	if id == "tray:close":
		_tray = false
		return
	if id.begins_with("tray:"):
		_tray_show(id.substr(5))
		return
	_alb_act(id.substr(4))


func _tray_tabs() -> Array:
	return [LX_TAB] if _tray_tab == "lx" else TRAY_TABS

func _tray_show(tab: String) -> void :
	var known: bool = TRAY_TABS.any( func(row: Array) -> bool: return str(row[0]) == tab)
	_tray_tab = tab if known or (tab == "lx" and RedEnvelope.shown()) else "img"
	if _tray_tab != "lx":
		_tray_back = _tray_tab
	_alb_sure = ""
	_lx_sure = ""
	if _tray_tab == "lx":
		RedEnvelope.want_bag()
	if _tray_tab == "emo":
		_emo_frames = false
		_emotes.refresh(true)
	elif _tray_tab == "img":
		ChatMedia.album_load(client, 0.0, true)


func _upload_lock() -> String:
	if not ChatMedia.album_ban.is_empty():
		return ChatMedia.album_ban
	if ChatMedia.album_loaded and ChatMedia.album_count() >= ChatMedia.album_max:
		return "Kho ảnh đầy (%d/%d) — bỏ bớt ảnh rồi tải tiếp." % [ChatMedia.album_count(), ChatMedia.album_max]
	if ChatMedia.album_count("wait") >= WAIT_MAX:
		return "Đã có %d ảnh chờ GM duyệt — duyệt xong mới tải tiếp được." % WAIT_MAX
	return ""

func _alb_item(id: String) -> Dictionary:
	for item: Dictionary in ChatMedia.album:
		if str(item.get("id", "")) == id:
			return item
	return {}


func _alb_act(what: String) -> void :
	if what == "up":
		var lock: String = _upload_lock()
		if not lock.is_empty():
			say(lock)
			return
		_media_act("image")
		return
	if what.begins_with("page:"):
		_alb_page = maxi(0, _alb_page + int(what.substr(5)))
		return
	if what.begins_with("del:"):
		var gone: String = what.substr(4)
		if _alb_sure == gone and _time - _alb_sure_at < ALB_SURE:
			_alb_sure = ""
			ChatMedia.album_del(client, gone)
		else:
			_alb_sure = gone
			_alb_sure_at = _time
			say("Bấm × lần nữa để bỏ ảnh khỏi kho." if str(_alb_item(gone).get("state", "")) != "wait" else "Bấm × lần nữa để huỷ ảnh đang chờ duyệt.")
		return
	if not what.begins_with("pic:"):
		return
	var item: Dictionary = _alb_item(what.substr(4))
	if item.is_empty():
		return
	match str(item.state):
		"wait":
			say("Ảnh đang chờ GM duyệt")
		"no":
			say("Ảnh bị từ chối — bấm × để bỏ khỏi kho.")
		_:
			var refused: String = _media_refusal()
			if not refused.is_empty():
				say(refused)
				return
			_media_out = {"media": {"id": str(item.id), "kind": "img", "sec": 0, "w": int(item.w), "h": int(item.h)}, 
				"to": {"tab": _tab, "chan": _chan, "whisper": client.whisper_to.duplicate()}, "at": _time}
			_tray = false


func _draw_tray() -> Rect2:
	var high: float = TRAY_HEAD + TRAY_BODY + TRAY_FOOT
	var at: Vector2 = Vector2(clampf(maxf(_tray_r.x - TRAY_W, _tray_min), 0.0, maxf(0.0, floorf(_fw + 0.01) - TRAY_W)), maxf(0.0, _tray_r.y - 6.0 - high))
	var box: Rect2 = _lr(at, Vector2(TRAY_W, high))
	_round(box.grow(2.0 * _f), Color(0, 0, 0, 0.35), 14.0)
	_round(box, GLASS_BG, 12.0, EDGE, 1.0)
	_hit("m:tray", box, false)
	var x: float = at.x + 8.0
	var tabs: Array = _tray_tabs()
	var tab_w: float = 82.0
	for tab: Array in tabs:
		var key: String = str(tab[0])
		var id: String = "m:tray:" + key
		var on: bool = _tray_tab == key
		var cell: Rect2 = _lr(Vector2(x, at.y + 6.0), Vector2(tab_w, 24))
		var lx: bool = key == "lx"
		_round(cell, Color(LX_RED if lx else PICKED, 0.9) if on else (Color("163a5f") if _hover == id else Color("10253f")), 12.0, 
			(LX_GOLD if lx else PICKED) if on else Color(EDGE, 0.9), 1.0)
		_fwords(str(tab[1]), BOLD, 12.0, LX_GOLD if lx and not on else Color.WHITE, "c", Vector2(x, at.y + 6.0), tab_w, 0.0, 24.0)
		if lx and not on and RedEnvelope.dot(client.account_oid):
			draw_circle(cell.position + Vector2(cell.size.x - 6.0 * _f, 5.0 * _f), 3.5 * _f, Color("ff3b30"), true, -1.0, true)
		if not on:
			_hit(id, cell, false)
		x += tab_w + 4.0
	var shut: Rect2 = _lr(Vector2(at.x + TRAY_W - 32.0, at.y + 6.0), Vector2(24, 24))
	_round(shut, Color("163a5f") if _hover == "m:tray:close" else Color("10253f"), 12.0, Color(EDGE, 0.9), 1.0)
	var c: Vector2 = shut.get_center()
	var arm: float = 5.0 * _f
	draw_line(c - Vector2(arm, arm), c + Vector2(arm, arm), Color.WHITE, maxf(1.5, 1.6 * _f), true)
	draw_line(c + Vector2( - arm, arm), c + Vector2(arm, - arm), Color.WHITE, maxf(1.5, 1.6 * _f), true)
	_hit("m:tray:close", shut, false)
	var line_y: float = (at.y + TRAY_HEAD) * _f
	draw_line(Vector2(box.position.x, line_y), Vector2(box.end.x, line_y), Color(EDGE, 0.7), maxf(1.0, _f))
	var body: Rect2 = Rect2(Vector2(at.x, at.y + TRAY_HEAD), Vector2(TRAY_W, TRAY_BODY))
	var foot: Rect2 = Rect2(Vector2(at.x, body.end.y), Vector2(TRAY_W, TRAY_FOOT))
	match _tray_tab:
		"lx":
			_tray_lixi(body, foot)
		"img":
			_tray_album(body, foot)
		"emo":
			_tray_emotes(body, foot)
		_:
			_tray_phrases(body)
	return box


func _tray_pager(id: String, page: int, pages: int, foot: Rect2) -> void :
	if pages <= 1:
		return
	var y: float = foot.position.y + (foot.size.y - 20.0) / 2.0
	var right: float = foot.end.x - 10.0
	_fwords("%d/%d" % [page + 1, pages], BOLD, 12.0, Color.WHITE, "c", Vector2(right - 62.0, y), 40.0, 0.0, 20.0)
	for step: int in [-1, 1]:
		var spot: Vector2 = Vector2(right - 82.0 if step < 0 else right - 20.0, y)
		var live: bool = page > 0 if step < 0 else page + 1 < pages
		var key: String = id % step
		var cell: Rect2 = _lr(spot, Vector2(20, 20))
		_round(cell, Color(BLUE.lightened(0.12) if _hover == key else BLUE, 1.0 if live else 0.35), 10.0)
		var mid: Vector2 = cell.get_center()
		var s: float = 4.5 * _f
		_poly(PackedVector2Array([mid + Vector2(s * step, 0), mid + Vector2( - s * 0.6 * step, - s), mid + Vector2( - s * 0.6 * step, s)]), Color(1, 1, 1, 1.0 if live else 0.45))
		if live:
			_hit(key, cell, false)


func _tray_album(body: Rect2, foot: Rect2) -> void :
	if not ChatMedia.usable():
		_fwords(ChatMedia.why_not("Kho ảnh"), BOLD, 13.0, DIM, "c", body.position, body.size.x, 0.0, body.size.y)
		return
	var per: int = ALB_COLS * ALB_ROWS
	var count: int = ChatMedia.album.size() + 1
	var pages: int = maxi(1, ceili(count / float(per)))
	_alb_page = clampi(_alb_page, 0, pages - 1)
	var grid_w: float = ALB_COLS * ALB_CELL + (ALB_COLS - 1) * ALB_GAP
	var origin: Vector2 = body.position + Vector2((TRAY_W - grid_w) / 2.0, 8.0)
	var lock: String = _upload_lock()
	for i in range(per):
		var n: int = _alb_page * per + i
		var spot: Vector2 = origin + Vector2((i % ALB_COLS) * (ALB_CELL + ALB_GAP), floorf(i / float(ALB_COLS)) * (ALB_CELL + ALB_GAP))
		var cell: Rect2 = _lr(spot, Vector2(ALB_CELL, ALB_CELL))
		if n >= count:
			_round(cell, Color(COL_BG, 0.6), 8.0, Color(EDGE, 0.25), 1.0)
		elif n == 0:
			_alb_upload(spot, cell, lock)
		else:
			_alb_cell(ChatMedia.album[n - 1], spot, cell)
	if not ChatMedia.album_loaded:
		_fwords("Đang tải kho ảnh…", REGULAR, 12.0, DIM, "l", foot.position + Vector2(10, 0), TRAY_W - 110.0, 0.0, foot.size.y)
	elif not ChatMedia.album_ban.is_empty():
		_fwords(ChatMedia.album_ban, SEMI, 11.0, Color("ff8a8a"), "l", foot.position + Vector2(10, 0), TRAY_W - (110.0 if pages > 1 else 20.0), 0.0, foot.size.y)
	else:
		var waits: int = ChatMedia.album_count("wait")
		_fwords("Kho %d/%d · chờ duyệt %d/%d" % [ChatMedia.album_count(), ChatMedia.album_max, waits, WAIT_MAX], SEMI, 11.0, 
			PICKED if waits >= WAIT_MAX else DIM, "l", foot.position + Vector2(10, 0), TRAY_W - 110.0, 0.0, foot.size.y)
	_tray_pager("m:alb:page:%d", _alb_page, pages, foot)

func _alb_upload(spot: Vector2, cell: Rect2, lock: String) -> void :
	var locked: bool = not lock.is_empty()
	var id: String = "m:alb:up"
	_round(cell, Color("10253f") if locked else (Color("1b4a78") if _hover == id else Color("123456")), 8.0, Color(EDGE, 0.6) if locked else Color("6fd0ff"), 1.0)
	var ink: Color = Color(1, 1, 1, 0.35) if locked else Color.WHITE
	_glyph("plus", (spot + Vector2(ALB_CELL / 2.0, 22.0)) * _f, 9.0 * _f, ink)
	_fwords("Tải ảnh", BOLD, 11.0, ink, "c", spot + Vector2(0, 34), ALB_CELL, 0.0, 16.0)
	_hit(id, cell, false)
	_tips[id] = lock if locked else "Tải ảnh lên — GM duyệt xong mới gửi được"


func _alb_cell(item: Dictionary, spot: Vector2, cell: Rect2) -> void :
	var id: String = str(item.id)
	var state: String = str(item.state)
	var hit: String = "m:alb:pic:" + id
	var cut: String = "m:alb:del:" + id
	var lit: bool = _hover == hit or _hover == cut
	_round(cell, Color("0a1626"), 8.0, Color("6fd0ff") if lit and state == "ok" else Color(EDGE, 0.6), 1.0)
	var fade: float = 1.0 if state == "ok" else 0.4
	var tex: Texture2D = ChatMedia.thumb(client, id) if state != "no" else null
	var inner: Rect2 = cell.grow(-3.0 * _f)
	if tex != null:
		var s: float = minf(inner.size.x / maxf(1.0, tex.get_width()), inner.size.y / maxf(1.0, tex.get_height()))
		var shown: Vector2 = tex.get_size() * s
		draw_texture_rect(tex, Rect2(inner.position + (inner.size - shown) / 2.0, shown), false, Color(1, 1, 1, fade))
	elif state != "no":
		_fwords("Hết hạn" if ChatMedia.thumb_gone(id) else "…", REGULAR, 11.0, DIM, "c", spot, ALB_CELL, 0.0, ALB_CELL)
	match state:
		"wait":
			_tips[hit] = "Chờ duyệt"
			if _mobile:
				_round(_lr(spot + Vector2(3, ALB_CELL - 17.0), Vector2(ALB_CELL - 6.0, 14)), Color(0, 0, 0, 0.6), 4.0)
				_fwords("Chờ duyệt", BOLD, 10.0, Color("ffd27a"), "c", spot + Vector2(3, ALB_CELL - 17.0), ALB_CELL - 6.0, 0.0, 14.0)
		"no":
			_round(inner, Color(REC, 0.12), 6.0)
			draw_line(inner.position, inner.end, Color(REC, 0.8), maxf(1.5, 1.5 * _f), true)
			_fwords("Bị từ chối", BOLD, 10.0, Color("ff9a9a"), "c", spot, ALB_CELL, 1.0, ALB_CELL)
			_tips[hit] = "Bị từ chối — tự biến mất sau 3 ngày"
		_:
			_tips[hit] = "Bấm để gửi"
	_hit(hit, cell, false)
	var sure: bool = _alb_sure == id and _time - _alb_sure_at < ALB_SURE
	if not (_mobile or lit or sure or state == "no"):
		return
	var x_at: Vector2 = spot + Vector2(ALB_CELL - 19.0, 3.0)
	var x_box: Rect2 = _lr(x_at, Vector2(16, 16))
	_round(x_box, REC if sure else Color(0, 0, 0, 0.72), 8.0, Color(1, 1, 1, 0.8), 1.0)
	var c: Vector2 = x_box.get_center()
	var arm: float = 3.5 * _f
	draw_line(c - Vector2(arm, arm), c + Vector2(arm, arm), Color.WHITE, maxf(1.2, 1.3 * _f), true)
	draw_line(c + Vector2( - arm, arm), c + Vector2(arm, - arm), Color.WHITE, maxf(1.2, 1.3 * _f), true)
	_hit(cut, x_box, false)
	_tips[cut] = "Bấm lần nữa để bỏ" if sure else ("Huỷ ảnh chờ duyệt" if state == "wait" else "Bỏ khỏi kho")


func _tray_emotes(body: Rect2, foot: Rect2) -> void :
	_emo_frames = false
	var packs: Array = _emotes.picker_packs()
	var ids: Array = packs.map( func(pack: Dictionary) -> String: return str(pack["id"]))
	if not ids.has(_emo_pack):
		_emo_pack = str(ids[0]) if not ids.is_empty() else ""
	var x: float = body.position.x + 8.0
	var y: float = body.position.y + 6.0
	for pack: Dictionary in packs:
		var name: String = str(pack["label"]) if not str(pack["label"]).is_empty() else str(pack["id"])
		var wide: float = minf(TRAY_W - 16.0, maxf(44.0, _wide(name, BOLD, 12.0) + 18.0))
		if x > body.position.x + 8.0 and x + wide > body.end.x - 8.0:
			x = body.position.x + 8.0
			y += 26.0
		var id: String = "emotab:" + str(pack["id"])
		var on: bool = str(pack["id"]) == _emo_pack
		var chip: Rect2 = _lr(Vector2(x, y), Vector2(wide, 22))
		_round(chip, Color(PICKED, 0.9) if on else (Color("163a5f") if _hover == id else Color("10253f")), 11.0, PICKED if on else Color(EDGE, 0.8), 1.0)
		_fwords(name, BOLD, 12.0, Color.WHITE, "c", Vector2(x, y), wide, 0.0, 22.0)
		_hit(id, chip, false)
		x += wide + 4.0
	var grid_y: float = y + 28.0
	var rows: int = maxi(1, floori((body.end.y - 4.0 - grid_y) / EMO_CELL))
	var per: int = TRAY_EMO_COLS * rows
	var items: Array = (_emotes.pack_of[_emo_pack] as Dictionary)["items"] if not _emo_pack.is_empty() and _emotes.pack_of.has(_emo_pack) else []
	var pages: int = maxi(1, ceili(items.size() / float(per)))
	_emo_page = clampi(_emo_page, 0, pages - 1)
	var left: float = body.position.x + (TRAY_W - TRAY_EMO_COLS * EMO_CELL) / 2.0
	for i in range(per):
		var n: int = _emo_page * per + i
		if n >= items.size():
			break
		var spot: Vector2 = Vector2(left + (i % TRAY_EMO_COLS) * EMO_CELL, grid_y + floorf(i / float(TRAY_EMO_COLS)) * EMO_CELL)
		var id: String = "emo:%d" % n
		var item: String = str(items[n])
		var cell: Rect2 = _lr(spot + Vector2(1, 1), Vector2(EMO_CELL - 2.0, EMO_CELL - 2.0))
		if _hover == id:
			_round(cell, Color("163a5f"), 8.0, Color("6fd0ff"), 1.0)
		_emote("%s:%s" % [_emo_pack, item], Rect2(spot + Vector2.ONE * (EMO_CELL - EMO_ICON) / 2.0, Vector2(EMO_ICON, EMO_ICON)))
		_hit(id, cell, false)
		var code: String = _emotes.code(_emo_pack, item)
		_tips[id] = _emotes.label(_emo_pack, item) + ("  /" + code if not code.is_empty() else "")
	if not _emotes.loaded:
		_fwords("Đang tải danh sách biểu cảm…", BOLD, 12.0, DIM, "c", Vector2(body.position.x, grid_y), TRAY_W, 0.0, EMO_CELL * rows)
	_tray_pager("emopage:%d", _emo_page, pages, foot)


func _tray_phrases(body: Rect2) -> void :
	for i in range(PHRASES.size()):
		var id: String = "say:%d" % i
		var at: Vector2 = body.position + Vector2(8, 4.0 + 21.0 * i)
		var row: Rect2 = _lr(at, Vector2(TRAY_W - 16.0, 20))
		if _hover == id:
			_round(row, Color("163a5f"), 6.0)
		_fwords(str(PHRASES[i]), REGULAR, 12.0, PICKED if _hover == id else Color.WHITE, "l", at + Vector2(8, 0), TRAY_W - 32.0, 0.0, 20.0)
		_hit(id, row, false)




func _media_tick() -> void :
	ChatMedia.poll()
	if (ChatMedia.recording >= 0.0 or ChatMedia.asking_mic) and not _open:
		ChatMedia.record_stop(false)
	for result: Variant in ChatMedia.take():
		if not result is Dictionary:
			continue
		if result.has("stage"):
			if str(result.stage) == "pack":
				say("Đang nén ảnh…")
			elif str(result.stage) == "up":
				say("Đang gửi " + ("ảnh…" if str(result.get("kind", "")) == "img" else "ghi âm…"))
			continue
		var kind: String = str(result.get("kind", ""))
		if kind.begins_with("album_"):
			if not bool(result.get("ok", false)):
				var why: String = str(result.get("error", ""))
				say(ChatMedia.error_text(result) if why == "net" else (why if not why.is_empty() else "Không bỏ được ảnh khỏi kho."))
			elif kind == "album_add":
				say("Đã thêm vào kho ảnh.")
			continue
		if bool(result.get("ok", false)) and kind == "img":

			_media_to = {}
			say("Ảnh đã tải lên — chờ GM duyệt…" if str(result.get("state", "")) == "wait" else "Ảnh đã vào kho — bấm ảnh để gửi.")
			ChatMedia.album_load(client, 0.0, true)
		elif bool(result.get("ok", false)) and result.get("media") is Dictionary and not _media_to.is_empty():
			_media_out = {"media": result.media, "to": _media_to, "at": _time}
			_media_to = {}
		else:
			var text: String = ChatMedia.error_text(result)
			if not text.is_empty():
				say(text)
	if _tray and _tray_tab == "img":
		ChatMedia.album_load(client, 15.0 if ChatMedia.album_count("wait") > 0 else 60.0)
	if _media_out.is_empty():
		return
	var sent: Variant = client.get("_chat_sent")
	if sent != null and Time.get_ticks_msec() / 1000.0 - float(sent) < 2.05:
		if _time - float(_media_out.at) > 20.0:
			_media_out = {}
		return
	var media: Dictionary = _media_out.media
	var to: Dictionary = _media_out.to
	_media_out = {}
	var text: String = ChatMedia.label(media)
	if int(to.chan) == 4:
		client.send_chat_channel(text, 4, ChatMedia.wire(media))
		return
	if str(to.tab) == "whisper":
		client.whisper_to = to.whisper
	client.send_chat(text, int(SEND_ON.get(str(to.tab), 2)), ChatMedia.wire(media), int(to.chan) == 2)


func _media_refusal() -> String:
	if not ChatMedia.usable():
		return ChatMedia.why_not("Gửi ảnh / ghi âm")
	if int(client.character.get("level", 0)) < ChatMedia.LEVEL:
		return "Cần cấp %d để gửi ảnh / ghi âm." % ChatMedia.LEVEL
	if HORNS.has(_chan):
		return "Không gửi ảnh / ghi âm bằng loa."
	if _view == "friends" and _peer.is_empty():
		return "Chọn người bên trái để chat riêng trước."
	if not ChatMedia.stage.is_empty() or not _media_out.is_empty():
		return "Đang gửi tệp trước — chờ chút."
	return ""

func _media_act(id: String) -> void :
	if id.begins_with("pic:"):
		var what: String = id.substr(4)
		if what == "close":
			_viewing = {}
		elif what == "report":
			var pic: String = str(_viewing.get("media", {}).get("id", ""))
			if ChatMedia.report(client, pic):
				say("Đã báo cáo ảnh — GM sẽ xem xét.")
			elif ChatMedia.reported.has(pic):
				say("Bạn đã báo cáo ảnh này.")
		elif what == "save":
			var keep: String = str(_viewing.get("media", {}).get("id", ""))
			if ChatMedia.album_has(keep):
				say("Ảnh đã có trong kho.")
			elif ChatMedia.album_loaded and ChatMedia.album_count() >= ChatMedia.album_max:
				say("Kho ảnh đầy (%d/%d) — bỏ bớt ảnh rồi sưu tầm tiếp." % [ChatMedia.album_count(), ChatMedia.album_max])
			elif ChatMedia.album_add(client, keep):
				say("Đang thêm vào kho ảnh…")
		elif _media_seen.has(what):
			_viewing = {"media": _media_seen[what][0], "own": _media_seen[what][1]}
			if not bool(_viewing.own):
				ChatMedia.album_load(client)
		return
	if id.begins_with("play:"):
		if not ChatMedia.usable():
			say(ChatMedia.why_not("Nghe ghi âm"))
		else:
			ChatMedia.play(id.substr(5))
		return
	if id == "rec:cancel":
		ChatMedia.record_stop(false)
		return
	if id == "mic" and (ChatMedia.recording >= 0.0 or ChatMedia.asking_mic):
		ChatMedia.record_stop(true)
		return
	var refused: String = _media_refusal()
	if not refused.is_empty():
		say(refused)
		return
	_media_to = {"tab": _tab, "chan": _chan, "whisper": client.whisper_to.duplicate()}
	if id == "mic":
		ChatMedia.record_start()
	else:
		ChatMedia.pick_image()


func _media_size(media: Dictionary) -> Vector2:
	if str(media.get("kind", "")) == "voice":
		return Vector2(clampf(80.0 + int(media.get("sec", 0)) * 6.0, 90.0, 190.0), 34.0)
	var w: float = float(media.get("w", 0))
	var h: float = float(media.get("h", 0))
	if w <= 0.0 or h <= 0.0:
		return Vector2(160, 120)
	var s: float = minf(PIC_BOX.x / w, PIC_BOX.y / h)
	return Vector2(clampf(w * s, 60.0, PIC_BOX.x), clampf(h * s, 60.0, PIC_BOX.y))

func _draw_media(media: Dictionary, rect: Rect2, own: bool) -> void :
	var id: String = str(media.get("id", ""))
	_media_seen[id] = [media, own]
	var box: Rect2 = _lr(rect.position, rect.size)
	if str(media.get("kind", "")) == "voice":
		var on: bool = ChatMedia.playing == id
		_round(box, OWN_BUBBLE if own else OTHER_BUBBLE, rect.size.y / 2.0, Color("6fd0ff") if on else Color(EDGE, 0.55), 1.0)
		var c: Vector2 = (rect.position + Vector2(17, rect.size.y / 2.0)) * _f
		draw_circle(c, 11.0 * _f, BLUE if not on else PICKED, true, -1.0, true)
		if on:
			for dx: float in [-3.0, 3.0]:
				draw_rect(Rect2(c + Vector2(dx - 1.5, -5.0) * _f, Vector2(3.0, 10.0) * _f), Color.WHITE)
		else:
			_poly(PackedVector2Array([c + Vector2(-3.5, -6.0) * _f, c + Vector2(6.0, 0) * _f, c + Vector2(-3.5, 6.0) * _f]), Color.WHITE)
		var sec: int = int(media.get("sec", 0))
		var bars: int = int((rect.size.x - 70.0) / 5.0)
		var done: float = clampf(ChatMedia.play_at / maxf(1.0, sec), 0.0, 1.0) if on else 0.0
		for i in range(bars):
			var tall: float = 4.0 + 12.0 * absf(sin(i * 1.7 + id.hash() % 7))
			var bx: float = rect.position.x + 34.0 + i * 5.0
			draw_rect(_lr(Vector2(bx, rect.position.y + (rect.size.y - tall) / 2.0), Vector2(2.5, tall)), Color.WHITE if float(i) / bars < done else Color("9cc4ec", 0.75))
		_fwords("%d%s" % [sec, ChatMedia.SECONDS], SEMI, 12.0, Color.WHITE, "r", rect.position + Vector2(0, 0), rect.size.x - 10.0, 0.0, rect.size.y, false)
		_hit("m:play:" + id, box, false)
		return
	_round(box, Color("0a1626"), 10.0, Color(EDGE, 0.55), 1.0)
	var tex: Texture2D = ChatMedia.picture(client, id)
	if tex != null:
		draw_texture_rect(tex, box.grow(-2.0 * _f), false)
	else:
		_fwords("Ảnh đã hết hạn" if ChatMedia.gone(id) else "Đang tải ảnh…", REGULAR, 12.0, DIM, "c", rect.position, rect.size.x, 0.0, rect.size.y)
	_hit("m:pic:" + id, box, false)


func _draw_recording(rect: Rect2) -> void :
	_round(_lr(rect.position, rect.size), Color("3a1016"), rect.size.y / 2.0, Color(REC, 0.9), 1.0)
	var c: Vector2 = (rect.position + Vector2(16, rect.size.y / 2.0)) * _f
	draw_circle(c, 5.0 * _f, Color(REC, 0.55 + 0.45 * absf(sin(_time * 4.0))), true, -1.0, true)
	var note: String = "Đang chờ cho phép dùng mic…"
	if ChatMedia.recording >= 0.0:
		note = "Đang ghi âm %d%s / %d%s — bấm mic để gửi" % [floori(ChatMedia.recording), ChatMedia.SECONDS, ChatMedia.VOICE_SEC, ChatMedia.SECONDS]
	_fwords(note, SEMI, 12.0, Color.WHITE, "l", rect.position + Vector2(28, 0), rect.size.x - 92.0, 0.0, rect.size.y)
	var cancel: Vector2 = Vector2(rect.end.x - 58.0, rect.position.y + 4.0)
	var button: Rect2 = _lr(cancel, Vector2(54, rect.size.y - 8.0))
	_round(button, Color("5a1c22") if _hover != "m:rec:cancel" else Color("7a2830"), (rect.size.y - 8.0) / 2.0, Color(REC, 0.9), 1.0)
	_fwords("Huỷ", BOLD, 12.0, Color.WHITE, "c", cancel, 54.0, 0.0, rect.size.y - 8.0)
	_hit("m:rec:cancel", button, false)


func _draw_viewer() -> void :
	if _viewing.has("forum"):
		_draw_forum_viewer()
		return
	var panel: Rect2 = panel_rect()
	if not _open:
		panel.position.x = floorf((_fw - panel.size.x) / 2.0)
	var box: Rect2 = _lr(panel.position, panel.size)
	draw_rect(box, Color(0, 0, 0, 0.88))
	_hit("m:pic:close", box, false)
	var media: Dictionary = _viewing.media
	var id: String = str(media.get("id", ""))
	var room: Rect2 = panel.grow_individual(-24.0, -24.0, -24.0, -72.0)
	var tex: Texture2D = ChatMedia.picture(client, id)
	var natural: Vector2 = tex.get_size() if tex != null else Vector2(float(media.get("w", 4)), float(media.get("h", 3)))
	var s: float = minf(room.size.x / maxf(1.0, natural.x), room.size.y / maxf(1.0, natural.y))
	var shown: Vector2 = natural * s
	var at: Vector2 = room.position + (room.size - shown) / 2.0
	if tex != null:
		draw_texture_rect(tex, _lr(at, shown), false)
	else:
		_fwords("Ảnh đã hết hạn" if ChatMedia.gone(id) else "Đang tải ảnh…", REGULAR, 14.0, DIM, "c", room.position, room.size.x, 0.0, room.size.y)
	var y: float = panel.end.y - 56.0
	var mid: float = panel.position.x + panel.size.x / 2.0
	var buttons: Array = [["m:pic:close", "Đóng"]]
	if not bool(_viewing.own) and ChatMedia.usable():
		buttons.append(["m:pic:save", "Đã sưu tầm" if ChatMedia.album_has(id) else "Sưu tầm"])
	if not bool(_viewing.own):
		buttons.append(["m:pic:report", "Đã báo cáo" if ChatMedia.reported.has(id) else "Báo cáo"])
	var x: float = mid - (buttons.size() * 110.0 - 10.0) / 2.0
	for button: Array in buttons:
		var cell: Rect2 = _lr(Vector2(x, y), Vector2(100, 34))
		var report: bool = str(button[0]) == "m:pic:report"
		_round(cell, (Color("8a2a30") if report else BLUE).lightened(0.12 if _hover == str(button[0]) else 0.0), 17.0, Color("ff9a9a") if report else Color("6fd0ff"), 1.0)
		_fwords(str(button[1]), BOLD, 13.0, Color.WHITE, "c", Vector2(x, y), 100.0, 0.0, 34.0)
		_hit(str(button[0]), cell, false)
		x += 110.0

func _pill_tag(tag: Array, at: Vector2, wide: float) -> void :
	_round(_lr(at, Vector2(wide, 14)), Color(tag[1], 0.22), 7.0, Color(tag[1], 0.8), 1.0)
	_fwords(str(tag[0]), BOLD, 10.0, tag[1], "c", at, wide, 0.0, 14.0)


func _disc(oid: int, centre: Vector2, radius: float, level: bool) -> void :
	var c: Vector2 = centre * _f
	var r: float = radius * _f
	draw_circle(c, r + 1.5 * _f, Color("6fb6ff", 0.8), true, -1.0, true)
	var face: Array = ChatFaces.of(oid)
	var tex: Texture2D = null
	if not face.is_empty() and pack != null:
		var key: String = str(pack.lobby.get("avatars", {}).get(str(int(face[0])), ""))
		if not key.is_empty():
			tex = pack.picture("l/h/%s.webp" % key)
			if tex == null:
				tex = pack.picture("l/av/%s.webp" % key)
	if tex == null:
		draw_circle(c, r, Color("15304a"), true, -1.0, true)
		_silhouette(c, r * 2.0, Color(MUTED, 0.6))
	else:
		var points: PackedVector2Array = PackedVector2Array()
		var uvs: PackedVector2Array = PackedVector2Array()
		var is_tall: bool = tex.get_height() > tex.get_width()
		var uv_center: Vector2 = Vector2(0.5, 0.28) if is_tall else Vector2(0.5, 0.5)
		var uv_radius: Vector2 = Vector2(0.42, 0.42 * tex.get_width() / tex.get_height()) if is_tall else Vector2(0.5, 0.5)
		for i in range(28):
			var angle: float = TAU * i / 28.0
			var dir: Vector2 = Vector2(cos(angle), sin(angle))
			points.append(c + dir * r)
			uvs.append(uv_center + Vector2(dir.x * uv_radius.x, dir.y * uv_radius.y))
		_poly(points, Color.WHITE, uvs, tex)
	if level and face.size() >= 2 and int(face[1]) > 0:
		_fblit(ChatFriend.level_cell(int(face[1])), centre + Vector2(-15, radius - 8.0), 30.0, 15.0)



func mini_names() -> Array:
	return _mini_lines.duplicate()

func mini_count() -> int:
	return _mini_count

func scroll_px() -> float:
	return _scroll_px

func tea_view() -> String:
	return "" if not (_open and _view == "tea") else ("room" if TeaRoom.in_room() and _tea_page == "room" else "list")

func tea_dialog() -> String:
	return str(_tea_dialog.get("kind", ""))

func tea_menu() -> Array:
	return _tea_menu_rows() if not _tea_menu.is_empty() else []




func _tea_small() -> bool:
	return _mobile or size.y < 560.0

func _tea_setup() -> void :
	_tea_say = _fedit(60)
	_tea_say.placeholder_text = "Nhắn trong phòng…"
	_tea_say.add_theme_color_override("font_placeholder_color", DIM)
	_tea_say.text_submitted.connect( func(_text: String) -> void : _tea_send())
	_tea_find = _fedit(20)
	_tea_find.placeholder_text = "Tìm tên phòng / #số"
	_tea_find.add_theme_color_override("font_placeholder_color", DIM)
	_tea_find.text_changed.connect( func(_text: String) -> void : _tea_find_at = _time + 0.6)
	_tea_find.text_submitted.connect( func(_text: String) -> void : _tea_find_at = _time)
	_tea_name = _fedit(TeaRoom.NAME_MAX)
	_tea_name.placeholder_text = "Tên phòng (2–20 ký tự)"
	_tea_name.add_theme_color_override("font_placeholder_color", DIM)
	_tea_pass = _fedit(4, true)
	_tea_pass.placeholder_text = "4 số"
	_tea_pass.add_theme_color_override("font_placeholder_color", DIM)
	_tea_pass.text_submitted.connect( func(_text: String) -> void : _tea_act("ok"))


func _tea_tick() -> void :
	if client == null:
		return
	_tea_wire()
	if TeaRoom.in_room() and (client.battle.active or client.state == "room"):
		TeaRoom.leave(client)
		_tea_note(str(TeaRoom.OUT.game))
		say(str(TeaRoom.OUT.game))
	if _tea_find_at >= 0.0 and _time >= _tea_find_at:
		_tea_find_at = -1.0
		TeaRoom.set_filter(client, "q", _tea_find.text.strip_edges())
	var looking: bool = _open and _view == "tea"
	TeaRoom.tick(client, looking and _tea_page == "list")
	if _view == "tea" and TeaRoom.gate < 0 and not TeaRoom.in_room():
		_view = "chat"
		_tea_menu = {}
		_tea_dialog = {}
		_tea_page = "list"
		looking = false
	for note: Dictionary in TeaRoom.take():
		match str(note.get("kind", "")):
			"say":
				say(str(note.get("text", "")))
				if TeaRoom.in_room():
					_tea_note(str(note.get("text", "")))
			"joined":
				_tea_notes = []
				_tea_scroll = 0.0
				_tea_menu = {}
				_tea_dialog = {}
				_tea_page = "room"
				if _open:
					_view = "tea"
			"left":
				_tea_notes = []
				_tea_menu = {}
				_tea_page = "list"
				if not _tea_dialog.is_empty() and str(_tea_dialog.kind) in ["invite", "leave", "edit"]:
					_tea_dialog = {}
				_tea_hold_stop()
			"invite":
				if looking:
					_tea_dialog = {"kind": "invite", "seat": int(note.get("seat", 0))}
				else:
					say("Chủ phòng mời bạn lên mic — mở Phòng Trà để nhận.")
			"pass":
				_tea_dialog = {"kind": "pass", "id": int(note.get("id", 0))}
				_tea_pass.text = ""
	if looking and TeaRoom.invite > 0 and _tea_dialog.is_empty():
		_tea_dialog = {"kind": "invite", "seat": TeaRoom.invite}
	if not _tea_dialog.is_empty() and str(_tea_dialog.kind) == "invite" and TeaRoom.invite <= 0:
		_tea_dialog = {}
	if not TeaRoom.in_room() and _tea_page == "room":
		_tea_page = "list"
	if not _tea_sends.is_empty():
		_tea_send_next()


func _tea_wire() -> void :
	if client.has_signal("voice_notice") and not client.voice_notice.is_connected(_tea_notice):
		client.voice_notice.connect(_tea_notice)
	if TeaRoom.voice == null and VoiceClient.usable():
		var v: Object = VoiceClient.shared()
		if v.client != client:
			v.client = client
		if not v.tea_voice.is_connected(_tea_note):
			v.tea_voice.connect(_tea_note)
		if client.has_signal("voice_notice") and not client.voice_notice.is_connected(v.on_notice):
			client.voice_notice.connect(v.on_notice)
		TeaRoom.use_voice(v)
		if TeaRoom.in_room() and not v.tea_joined():
			v.tea_join()
			v.tea_seated(TeaRoom.can_publish())

func _tea_notice(op: int, scope: String, code: String) -> void :
	TeaRoom.on_notice(client, op, scope, code)

func _tea_voice() -> Object:
	var v: Object = TeaRoom.voice
	return v if v != null and is_instance_valid(v) else null


func _tea_note(text: String) -> void :
	if text.strip_edges().is_empty() or not TeaRoom.in_room():
		return
	_tea_notes.append({"text": text, "rev": int(client.tea_rev) if client != null else 0})
	if _tea_notes.size() > 8:
		_tea_notes = _tea_notes.slice(_tea_notes.size() - 8)
	_tea_scroll = 0.0

func _tea_send() -> void :
	var text: String = _tea_say.text.strip_edges()
	if text.is_empty():
		return
	text = _emotes.expand(text, {})
	var refused: String = _emotes.refusal(text)
	if not refused.is_empty():
		say(refused)
		return
	var why: String = client.send_tea_chat(text)
	if why.is_empty():
		_tea_say.text = ""
		_tea_scroll = 0.0
	elif why != "-":
		_tea_note(why)
		say(why)


func _tea_share(kind: String, oid: int = 0, name: String = "") -> void :
	if not TeaRoom.in_room():
		return
	for job: Dictionary in _tea_sends:
		if str(job.kind) == kind and int(job.oid) == oid:
			return
	_tea_sends.append({"kind": kind, "oid": oid, "name": name, "at": _time})
	_tea_send_next()

func _tea_send_next() -> void :
	if _tea_sends.is_empty():
		return
	var job: Dictionary = _tea_sends[0]
	if _time - float(job.at) > 20.0 or not TeaRoom.in_room():
		_tea_sends.pop_front()
		return
	if Time.get_ticks_msec() / 1000.0 - float(client.get("_chat_sent")) < 2.05:
		return
	_tea_sends.pop_front()
	var text: String = TeaRoom.invite_text()
	var extra: Dictionary = TeaRoom.invite_param()
	var ok: bool = false
	match str(job.kind):
		"guild":
			ok = client.send_chat(text, 1024, extra)
		"team":
			ok = client.send_chat_channel(text, 4, extra)
		"pal":
			var keep: Dictionary = client.whisper_to.duplicate()
			client.whisper_to = {"name": str(job.name), "oid": int(job.oid)}
			ok = client.send_chat(text, 1, extra)
			client.whisper_to = keep
	if ok:
		_tea_note("Đã gửi lời mời " + ("vào Guild" if job.kind == "guild" else ("vào Team" if job.kind == "team" else "cho " + str(job.name))) + ".")

func _tea_release() -> void :
	for edit: LineEdit in [_tea_say, _tea_find, _tea_name, _tea_pass]:
		if edit != null and edit.visible:
			edit.visible = false
			edit.release_focus()
	_tea_hold_stop()

func _tea_hide_unused() -> void :
	for pair: Array in [["say", _tea_say], ["find", _tea_find], ["name", _tea_name], ["pass", _tea_pass]]:
		var edit: LineEdit = pair[1]
		if edit != null and edit.visible and not _tea_used.has(pair[0]):
			edit.visible = false
			edit.release_focus()


func _tea_touch(event: InputEvent) -> void :
	if not (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var v: Object = _tea_voice()
	if event.pressed:
		_tea_skip = false
		if _mobile and v != null and _tea_mic_box.has_point(event.position) and v.tea_mic_state() != "off" and v.mic_mode() == "ptt":
			_tea_hold = true
			_tea_hold_at = _time
			v.set_talk(true)
	elif _tea_hold:
		_tea_skip = _time - _tea_hold_at >= 0.35
		_tea_hold_stop()

func _tea_hold_stop() -> void :
	if not _tea_hold:
		return
	_tea_hold = false
	var v: Object = _tea_voice()
	if v != null:
		v.set_talk(false)

func _tea_wheel(step: int, at: Vector2) -> bool:
	if not (_open and _view == "tea"):
		return false
	if _tea_area.has_point(at):
		_tea_scroll = clampf(_tea_scroll - step * WHEEL_PX, 0.0, _tea_max)
		return true
	if _tea_list_area.has_point(at):
		_tea_list_scroll = clampf(_tea_list_scroll - step * WHEEL_PX, 0.0, _tea_list_max)
		return true
	return false

func _tea_drag(moved: Vector2, from: Vector2) -> bool:
	if not (_open and _view == "tea"):
		return false
	if _tea_area.has_point(from):
		_tea_scroll = clampf(_tea_scroll + moved.y / _tea_k, 0.0, _tea_max)
		return true
	if _tea_list_area.has_point(from):
		_tea_list_scroll = clampf(_tea_list_scroll - moved.y / _tea_k, 0.0, _tea_list_max)
		return true
	return false


func _tea_escape() -> bool:
	if _view != "tea":
		return false
	if not _tea_dialog.is_empty():
		if str(_tea_dialog.kind) == "invite":
			TeaRoom.decline()
		_tea_dialog = {}
		return true
	if not _tea_menu.is_empty():
		_tea_menu = {}
		return true
	return false



func _paint_tea() -> void :
	if size.y < 1.0:
		return
	var small: bool = _tea_small()
	var keep: Array = [_f, _u, _fw, _fh]
	if small:
		_f = size.y / 390.0
		_u = _f / 2.0
		_fw = size.x / _f
		_fh = 390.0
	_tea_k = _f
	_tea_compact = small
	_tea_area = Rect2()
	_tea_list_area = Rect2()
	_tea_mic_box = Rect2()
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.18))
	var panel: Rect2 = _tea_panel()
	var box: Rect2 = _lr(panel.position, panel.size)
	draw_rect(box, GLASS_BG)
	draw_line(Vector2(box.end.x, box.position.y), box.end, Color(EDGE, 0.9), maxf(1.0, _f))
	_hit("panel", box, false)
	_add(box)
	var body: Rect2 = Rect2(Vector2(RAIL_W, 0), Vector2(panel.size.x - RAIL_W, panel.size.y))
	if TeaRoom.in_room() and _tea_page == "room":
		_tea_room(body)
	else:
		_tea_list(body)
	_draw_rail(panel)
	if not _tea_menu.is_empty():
		_tea_draw_menu(panel)
	if not _tea_dialog.is_empty():
		_tea_draw_dialog(panel)
	_focus = false
	_f = keep[0]
	_u = keep[1]
	_fw = keep[2]
	_fh = keep[3]

func _tea_panel() -> Rect2:
	var stage: float = floorf(_fw + 0.01)
	if _tea_compact:
		return Rect2(0, 0, stage, floorf(_fh + 0.01))
	return Rect2(0, 0, minf(stage, maxf(panel_rect().size.x, 700.0)), floorf(_fh + 0.01))

func _tea_button(id: String, text: String, at: Vector2, wide: float, high: float, kind: String = "blue", glyph: String = "") -> void :
	var box: Rect2 = _lr(at, Vector2(wide, high))
	var lit: bool = _hover == id
	match kind:
		"orange":
			VoiceUI.grad(self, box, high / 2.0 * _f, VoiceUI.ORG_T.lightened(0.1 if lit else 0.0), VoiceUI.ORG_B, Color(1, 1, 1, 0.6), 1.2 * _f)
		"green":
			VoiceUI.grad(self, box, high / 2.0 * _f, Color("63e08a").lightened(0.1 if lit else 0.0), Color("168a45"), Color(1, 1, 1, 0.5), 1.2 * _f)
		"dark":
			_round(box, Color("163a5f") if lit else Color("10253f"), high, Color(EDGE, 0.9), 1.0)
		_:
			VoiceUI.grad(self, box, high / 2.0 * _f, VoiceUI.BLUE_T.lightened(0.1 if lit else 0.0), VoiceUI.BLUE_B, Color(VoiceUI.BLUE_L, 0.8), 1.2 * _f)
	var x: float = at.x
	var room: float = wide
	if not glyph.is_empty():
		var tw: float = _wide(text, BOLD, 13.0) if not text.is_empty() else 0.0
		var gx: float = at.x + (wide - tw - (18.0 if not text.is_empty() else 0.0)) / 2.0 + 7.0
		_tea_glyph(glyph, Vector2(gx, at.y + high / 2.0) * _f, 6.5 * _f, Color.WHITE)
		x = gx + 11.0
		room = tw + 4.0
		if text.is_empty():
			_hit(id, box, false)
			return
		_fwords(text, BOLD, 13.0, Color.WHITE, "l", Vector2(x, at.y), room, 1.0, high)
	else:
		_fwords(text, BOLD, 13.0, Color.WHITE, "c", Vector2(x, at.y), room, 1.0, high)
	_hit(id, box, false)


func _tea_chibi(a: int, rect: Rect2) -> void :
	var key: String = str(pack.lobby.get("avatars", {}).get(str(a), "")) if pack != null else ""
	var tex: Texture2D = null
	if not key.is_empty():
		tex = pack.picture("l/ch/%s.webp" % key)
		if tex == null:
			tex = pack.picture("l/h/%s.webp" % key)
	var box: Rect2 = _lr(rect.position, rect.size)
	if tex == null or tex.get_width() <= 0:
		_silhouette(box.get_center(), box.size.x * 1.2, Color(MUTED, 0.6))
		return
	var zoom: float = minf(box.size.x / tex.get_width(), box.size.y / tex.get_height())
	var shown: Vector2 = Vector2(tex.get_width(), tex.get_height()) * zoom
	draw_texture_rect(tex, Rect2(Vector2(box.get_center().x - shown.x / 2.0, box.end.y - shown.y), shown), false)


func _tea_face(a: int, centre: Vector2, radius: float) -> void :
	var c: Vector2 = centre * _f
	var r: float = radius * _f
	draw_circle(c, r + 1.5 * _f, Color("6fb6ff", 0.8), true, -1.0, true)
	var key: String = str(pack.lobby.get("avatars", {}).get(str(a), "")) if pack != null and a > 0 else ""
	var tex: Texture2D = pack.picture("l/h/%s.webp" % key) if not key.is_empty() else null
	if tex == null:
		draw_circle(c, r, Color("15304a"), true, -1.0, true)
		_silhouette(c, r * 2.0, Color(MUTED, 0.6))
		return
	var points: PackedVector2Array = PackedVector2Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	for i in range(28):
		var angle: float = TAU * i / 28.0
		var dir: Vector2 = Vector2(cos(angle), sin(angle))
		points.append(c + dir * r)
		uvs.append(Vector2(0.5, 0.5) + dir * 0.5)
	_poly(points, Color.WHITE, uvs, tex)

func _tea_ellipse(c: Vector2, rx: float, ry: float, fill: Color, edge: Color) -> void :
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(32):
		var angle: float = TAU * i / 32.0
		pts.append((c + Vector2(cos(angle) * rx, sin(angle) * ry)) * _f)
	_poly(pts, fill)
	pts.append(pts[0])
	draw_polyline(pts, edge, maxf(1.0, 1.6 * _f), true)

static func _tea_medal(section: int) -> int:
	if section >= 17:
		return 6
	if section >= 13:
		return 5
	return clampi((section - 1) / 3 + 1, 1, 4)


func _tea_avatar(c: int) -> int:
	if c <= 0:
		return 0
	if int(TeaRoom.host_face().get("c", 0)) == c:
		return int(TeaRoom.host_face().get("a", 0))
	for s: Variant in TeaRoom.seats:
		if s is Dictionary and int(s.get("c", 0)) == c:
			return int(s.get("a", 0))
	for p: Variant in TeaRoom.listen.get("top", []):
		if p is Dictionary and int(p.get("c", 0)) == c:
			return int(p.get("a", 0))
	var face: Array = ChatFaces.of(c)
	return int(face[0]) if not face.is_empty() else 0

func _tea_name_of(c: int) -> String:
	if int(TeaRoom.host_face().get("c", 0)) == c:
		return str(TeaRoom.host_face().get("name", ""))
	for s: Variant in TeaRoom.seats:
		if s is Dictionary and int(s.get("c", 0)) == c:
			return str(s.get("name", ""))
	for p: Variant in TeaRoom.listen.get("top", []):
		if p is Dictionary and int(p.get("c", 0)) == c:
			return str(p.get("name", ""))
	for r: Variant in TeaRoom.requests:
		if r is Dictionary and int(r.get("c", 0)) == c:
			return str(r.get("name", ""))
	return ""


func _tea_talking(c: int) -> bool:
	var v: Object = _tea_voice()
	if v == null or c <= 0:
		return false
	return v.tea_talking(c, int(client.account_oid))



func _tea_list(body: Rect2) -> void :
	var cx: float = body.position.x
	var cw: float = body.size.x
	var high: float = body.size.y
	var small: bool = _tea_compact
	var foot: float = 52.0 if small else 64.0
	var top: float = HEAD_H + (70.0 if small else 118.0)
	var cols: int = 3 if small else 2
	var gap: float = 10.0
	var card_w: float = floorf((cw - 24.0 - gap * (cols - 1)) / cols)
	var card_h: float = 112.0 if small else 132.0
	var area: Rect2 = Rect2(Vector2(cx, top), Vector2(cw, high - foot - top))
	_tea_list_area = _lr(area.position, area.size)
	var rows: int = ceili(TeaRoom.rooms.size() / float(cols))
	var total: float = rows * (card_h + gap) + 10.0
	_tea_list_max = maxf(0.0, total - area.size.y)
	_tea_list_scroll = clampf(_tea_list_scroll, 0.0, _tea_list_max)
	for k in range(TeaRoom.rooms.size()):
		var at: Vector2 = Vector2(cx + 12.0 + (k % cols) * (card_w + gap), top + 8.0 + (k / cols) * (card_h + gap) - _tea_list_scroll)
		if at.y + card_h < top - 4.0 or at.y > area.end.y + 4.0:
			continue
		_tea_card(TeaRoom.rooms[k], at, Vector2(card_w, card_h))
	if TeaRoom.rooms.is_empty():
		var note: String = "Phòng Trà chỉ có ở bản web." if not TeaRoom.online(client) else ("Đang tải danh sách…" if not TeaRoom.listed or TeaRoom.busy("list") else "Chưa có phòng phù hợp — tự tạo một phòng nhé!")
		_fwords(note, REGULAR, 13.0, DIM, "c", Vector2(cx, top + 40.0), cw, 0.0, 24.0)

	var cover: Rect2 = _lr(Vector2(cx, 0), Vector2(cw, top))
	draw_rect(cover, GLASS_BG)
	_hit("panel", cover, false)
	draw_rect(_lr(Vector2(cx, 0), Vector2(cw, HEAD_H)), HEAD_BG)
	var here: bool = TeaRoom.in_room()
	_draw_head(Rect2(Vector2(cx, 0), Vector2(cw, HEAD_H)), "Phòng Trà", "Phòng thoại — lên mic trò chuyện cùng cả server", 136.0)
	var button_at: Vector2 = Vector2(cx + cw - 48.0 - 124.0, (HEAD_H - 30.0) / 2.0)
	if here:
		_tea_button("m:tea:room", "Về phòng", button_at, 116.0, 30.0, "green", "tea")
	else:
		_tea_button("m:tea:create", "Tạo phòng", button_at, 116.0, 30.0, "blue", "plus")

	var y: float = HEAD_H + (6.0 if small else 8.0)
	var th: float = 28.0 if small else 30.0
	var x: float = cx + 12.0
	for tab: Array in [["all", "Toàn Server"], ["friend", "Có Bạn Bè"], ["guild", "Guild"]]:
		var label: String = "%s %d" % [tab[1], int(TeaRoom.counts.get(tab[0], 0))]
		var w: float = _wide(label, BOLD, 12.0) + 26.0
		var id: String = "m:tea:f:" + str(tab[0])
		var on: bool = str(TeaRoom.filter.f) == str(tab[0])
		var r: Rect2 = _lr(Vector2(x, y), Vector2(w, th))
		if on:
			VoiceUI.grad(self, r, th / 2.0 * _f, VoiceUI.ORG_T, VoiceUI.ORG_B, Color(1, 1, 1, 0.6), 1.2 * _f)
		else:
			_round(r, Color("163a5f") if _hover == id else Color("10253f"), th, Color(EDGE, 0.9), 1.0)
		_fwords(label, BOLD, 12.0, Color.WHITE if on else Color("cfe6ff"), "c", Vector2(x, y), w, 1.0 if on else 0.0, th)
		_hit(id, r, false)
		x += w + 6.0

	var sy: float = y if small else y + 38.0
	var sx: float = cx + cw - 12.0 - 150.0 - 210.0 if small else cx + 12.0
	var field: Rect2 = _lr(Vector2(sx, sy), Vector2(200, th))
	_round(field, FIELD, th, Color(EDGE, 0.8), 1.0)
	_tea_glyph("search", Vector2(sx + 15.0, sy + th / 2.0) * _f, 5.5 * _f, DIM)
	_fput(_tea_find, Rect2(Vector2(sx + 28.0, sy + 1.0), Vector2(166, th - 2.0)), 13.0)
	_tea_used["find"] = true
	var nx: float = sx + 212.0
	var nid: String = "m:tea:nolock"
	var nolock: bool = bool(TeaRoom.filter.nolock)
	_fblit("iv_chk_on" if nolock else "iv_chk_off", Vector2(nx, sy + (th - 23.0) / 2.0), 20.0, 21.0)
	_lock(Vector2(nx + 32.0, sy + th / 2.0 + 1.0) * _f, 22.0, Color("cfe6ff"))
	_fwords("Ẩn phòng khoá", SEMI, 12.0, Color("cfe6ff") if _hover != nid else Color.WHITE, "l", Vector2(nx + 42.0, sy), 100.0, 0.0, th)
	_hit(nid, _lr(Vector2(nx, sy), Vector2(144, th)), false)

	var cy: float = HEAD_H + (40.0 if small else 84.0)
	var ch: float = 24.0 if small else 26.0
	x = cx + 12.0
	var chips: Array = [["", "Tất cả", Color("cfe6ff")]]
	chips.append_array(TeaRoom.TAGS)
	for tag: Array in chips:
		var w: float = _wide(str(tag[1]), SEMI, 12.0) + (34.0 if not str(tag[0]).is_empty() else 22.0)
		if x + w > cx + cw - 8.0:
			break
		var id: String = "m:tea:tag:" + str(tag[0])
		var on: bool = str(TeaRoom.filter.tag) == str(tag[0])
		var tint: Color = tag[2]
		var r: Rect2 = _lr(Vector2(x, cy), Vector2(w, ch))
		_round(r, Color(tint, 0.3) if on else (Color("163a5f") if _hover == id else Color("0d2138")), ch, Color(tint, 0.9) if on else Color(EDGE, 0.6), 1.0)
		var tx: float = x + 11.0
		if not str(tag[0]).is_empty():
			draw_circle(Vector2(x + 13.0, cy + ch / 2.0) * _f, 4.0 * _f, tint, true, -1.0, true)
			tx = x + 22.0
		_fwords(str(tag[1]), SEMI, 12.0, Color.WHITE if on else Color("cfe6ff"), "l", Vector2(tx, cy), w - (tx - x), 0.0, ch)
		_hit(id, r, false)
		x += w + 6.0

	var fy: float = high - foot
	var fbox: Rect2 = _lr(Vector2(cx, fy), Vector2(cw, foot))
	draw_rect(fbox, BAR_BG)
	draw_line(fbox.position, Vector2(fbox.end.x, fbox.position.y), Color(EDGE, 0.8), maxf(1.0, _f))
	_hit("panel", fbox, false)
	var bh: float = foot - 14.0
	var rw: float = 184.0
	_tea_button("m:tea:random", "VÀO NGẪU NHIÊN", Vector2(cx + 12.0, fy + 7.0), rw, bh, "orange", "dice")
	var rx: float = cx + 12.0 + rw + 8.0
	_tea_button("m:tea:refresh", "Làm mới", Vector2(rx, fy + (foot - 32.0) / 2.0), 96.0, 32.0, "dark", "refresh")
	rx += 104.0
	var right: float = cx + cw - 12.0
	if TeaRoom.pages > 1:
		var pw: float = 112.0
		var px: float = right - pw
		_tea_button("m:tea:page:-1", "", Vector2(px, fy + (foot - 30.0) / 2.0), 30.0, 30.0, "dark", "back")
		_fwords("%d/%d" % [TeaRoom.page, TeaRoom.pages], BOLD, 13.0, Color.WHITE, "c", Vector2(px + 30.0, fy), pw - 60.0, 0.0, foot)
		_tea_button("m:tea:page:1", "", Vector2(px + pw - 30.0, fy + (foot - 30.0) / 2.0), 30.0, 30.0, "dark", "next")
		right = px - 8.0
	var room_w: float = right - rx
	var stats: String = _tea_fit(["%d phòng · %d người đang nghe" % [TeaRoom.total, TeaRoom.people], "%d phòng · %d đang nghe" % [TeaRoom.total, TeaRoom.people], 
		"%d phòng · %d người" % [TeaRoom.total, TeaRoom.people]], SEMI, 12.0, room_w)
	var hint: String = _tea_fit(["Ngẫu nhiên: phòng còn chỗ, không khoá", "Ngẫu nhiên: còn chỗ, không khoá", "Ngẫu nhiên: còn chỗ"], REGULAR, 10.5, room_w)
	_tea_foot = [stats, hint]
	_fwords(stats, SEMI, 12.0, Color.WHITE, "l", Vector2(rx, fy + foot / 2.0 - 18.0), room_w, 0.0, 18.0)
	_fwords(hint, REGULAR, 10.5, DIM, "l", Vector2(rx, fy + foot / 2.0), room_w, 0.0, 16.0)


func _tea_fit(texts: Array, font: Font, px: float, room: float) -> String:
	for text: String in texts:
		if _wide(text, font, px) <= room:
			return text
	return _clip(str(texts[-1]), font, px, room)

func _tea_card(info: Dictionary, at: Vector2, card: Vector2) -> void :
	var id: String = "m:tea:join:%d" % int(info.get("id", 0))
	var full: bool = bool(info.get("full", false))
	var box: Rect2 = _lr(at, card)
	VoiceUI.grad(self, box, 12.0 * _f, Color("173a63").lightened(0.06 if _hover == id else 0.0), Color("0d2340"), Color(EDGE, 0.95), 1.2 * _f)
	var host_info: Dictionary = info.get("host", {})
	var small: bool = _tea_compact
	var chibi_w: float = 62.0 if small else 74.0
	_tea_ellipse(at + Vector2(6.0 + chibi_w / 2.0, card.y - 16.0), chibi_w * 0.42, 7.0, Color("6fd0ff", 0.22), Color("6fd0ff", 0.6))
	_tea_chibi(int(host_info.get("a", 0)), Rect2(at + Vector2(6, 8), Vector2(chibi_w, card.y - 22.0)))
	var x: float = at.x + chibi_w + 14.0
	var room: float = at.x + card.x - x - 10.0
	var nx: float = x
	if bool(info.get("lock", false)):
		_lock((Vector2(x + 7.0, at.y + 17.0)) * _f, 22.0, Color("ffd257"))
		nx += 16.0
	_fwords(_clip(str(info.get("name", "")), BOLD, 15.0, room - (nx - x)), BOLD, 15.0, Color.WHITE, "l", Vector2(nx, at.y + 6.0), room - (nx - x), 1.0, 22.0, false)
	var y2: float = at.y + 31.0
	var tag: String = str(info.get("tag", ""))
	var tw: float = _wide(TeaRoom.tag_name(tag), BOLD, 10.0) + 12.0
	_pill_tag([TeaRoom.tag_name(tag), TeaRoom.tag_color(tag)], Vector2(x, y2 + 2.0), tw)
	var used: float = _fwords("#%d" % int(info.get("id", 0)), SEMI, 11.0, DIM, "l", Vector2(x + tw + 6.0, y2), 60.0, 0.0, 18.0, false)
	if int(info.get("friends", 0)) > 0:
		_fwords("%d bạn" % int(info.get("friends", 0)), BOLD, 11.0, PICKED, "l", Vector2(x + tw + 12.0 + used, y2), 60.0, 0.0, 18.0, false)

	var my: float = at.y + (60.0 if small else 66.0)
	var mic: Array = info.get("mic", [])
	var step: float = 26.0 if small else 30.0
	var radius: float = 10.0 if small else 12.0
	for k in range(mic.size()):
		var c: Vector2 = Vector2(x + radius + k * step, my)
		if c.x + radius > at.x + card.x - 6.0:
			break
		var m: Variant = mic[k]
		if m is Dictionary:
			_tea_face(int(m.get("a", 0)), c, radius)
		elif str(m) == "l":
			draw_circle(c * _f, radius * _f, Color("0b1626"), true, -1.0, true)
			_lock(c * _f + Vector2(0, -1) * _f, radius * 1.4, Color(DIM, 0.9))
		else:
			_tea_dashed(c, radius, Color(DIM, 0.7))

	var by: float = at.y + card.y - (24.0 if small else 30.0)
	var listen: String = "%d/%d" % [int(info.get("n", 0)), int(info.get("max", TeaRoom.PEOPLE_MAX))]
	_tea_glyph("person", Vector2(x + 6.0, by + 9.0) * _f, 5.0 * _f, DIM)
	var lw: float = _fwords(listen, SEMI, 11.0, Color("cfe6ff"), "l", Vector2(x + 14.0, by), 50.0, 0.0, 18.0, false)
	var hx: float = x + 22.0 + lw
	var tail: float = 36.0 if full else 0.0
	_fwords(_clip("Chủ: " + str(host_info.get("name", "")), REGULAR, 11.0, at.x + card.x - hx - 10.0 - tail), REGULAR, 11.0, DIM, "l", Vector2(hx, by), at.x + card.x - hx - 10.0 - tail, 0.0, 18.0, false)
	if full:
		var pr: Rect2 = _lr(Vector2(at.x + card.x - 42.0, by + 1.0), Vector2(34, 16))
		_round(pr, Color(PICKED, 0.25), 8.0, PICKED, 1.0)
		_fwords("đầy", BOLD, 10.0, PICKED, "c", Vector2(at.x + card.x - 42.0, by + 1.0), 34.0, 0.0, 16.0)
		draw_rect(box, Color(0, 0, 0, 0.25))
	_hit(id, box, false)

func _tea_dashed(c: Vector2, radius: float, color: Color) -> void :
	for k in range(10):
		var a0: float = TAU * k / 10.0
		draw_arc(c * _f, radius * _f, a0, a0 + TAU / 20.0, 4, color, maxf(1.0, 1.4 * _f), true)



func _tea_room(body: Rect2) -> void :
	var cx: float = body.position.x
	var cw: float = body.size.x
	var high: float = body.size.y
	var small: bool = _tea_compact
	var head_h: float = 42.0 if small else 52.0
	var bar_h: float = 52.0 if small else 60.0
	var stage: Rect2
	var people: Rect2
	var chat: Rect2
	if small:
		var sw: float = roundf(cw * 0.58)
		stage = Rect2(Vector2(cx, head_h), Vector2(sw, high - head_h - bar_h))
		people = Rect2(Vector2(cx + sw, head_h), Vector2(cw - sw, 44))
		chat = Rect2(Vector2(cx + sw, head_h + 44.0), Vector2(cw - sw, high - head_h - 44.0 - bar_h))
	else:
		var sh: float = clampf(floorf(high * 0.435), 250.0, 338.0)
		stage = Rect2(Vector2(cx, head_h), Vector2(cw, sh))
		people = Rect2(Vector2(cx, head_h + sh), Vector2(cw, 58))
		chat = Rect2(Vector2(cx, head_h + sh + 58.0), Vector2(cw, high - head_h - sh - 58.0 - bar_h))
	_tea_chat(chat)
	_tea_stage(stage)
	_tea_people(people)
	_tea_head(Rect2(Vector2(cx, 0), Vector2(cw, head_h)))
	_tea_bar(Rect2(Vector2(cx, high - bar_h), Vector2(cw, bar_h)))

func _tea_head(r: Rect2) -> void :
	var box: Rect2 = _lr(r.position, r.size)
	draw_rect(box, HEAD_BG)
	draw_line(Vector2(box.position.x, box.end.y), box.end, Color(EDGE, 0.8), maxf(1.0, _f))
	_hit("panel", box, false)
	var small: bool = _tea_compact
	var bh: float = 30.0 if small else 32.0
	var by: float = r.position.y + (r.size.y - bh) / 2.0
	var bw: float = 96.0 if small else 108.0
	_tea_button("m:tea:back", "Danh sách", Vector2(r.position.x + 8.0, by), bw, bh, "blue", "back")
	var x: float = r.position.x + bw + 18.0
	var right: float = r.end.x - 92.0
	var info: Dictionary = TeaRoom.room
	if bool(info.get("lock", false)):
		_lock(Vector2(x + 7.0, r.position.y + (12.0 if small else 15.0)) * _f, 24.0, Color("ffd257"))
		x += 18.0
	var px: float = 15.0 if small else 17.0
	var id_text: String = "#%d" % int(info.get("id", 0))
	var id_w: float = _wide(id_text, SEMI, 12.0) + 8.0
	var name_w: float = _fwords(_clip(str(info.get("name", "")), BOLD, px, right - x - id_w), BOLD, px, Color.WHITE, "l", Vector2(x, r.position.y + (1.0 if small else 3.0)), right - x - id_w, 1.0, 22.0, false)
	_fwords(id_text, SEMI, 12.0, DIM, "l", Vector2(x + name_w + 6.0, r.position.y + (3.0 if small else 5.0)), id_w, 0.0, 20.0, false)
	var y2: float = r.position.y + (22.0 if small else 27.0)
	var tag: String = str(info.get("tag", ""))
	var tw: float = _wide(TeaRoom.tag_name(tag), BOLD, 10.0) + 12.0
	_pill_tag([TeaRoom.tag_name(tag), TeaRoom.tag_color(tag)], Vector2(r.position.x + bw + 18.0, y2 + 2.0), tw)
	var used_seats: int = 0
	for s: Variant in TeaRoom.seats:
		if s is Dictionary and int(s.get("c", 0)) > 0:
			used_seats += 1
	var note: String = "%d/%d · %d/%d ghế mic" % [int(info.get("n", 0)), int(info.get("max", TeaRoom.PEOPLE_MAX)), used_seats, int(info.get("seats", TeaRoom.seats.size()))]
	_tea_glyph("person", Vector2(r.position.x + bw + 26.0 + tw, y2 + 9.0) * _f, 5.0 * _f, DIM)
	_fwords(_clip(note, REGULAR, 11.0, right - (r.position.x + bw + 34.0 + tw)), REGULAR, 11.0, DIM, "l", Vector2(r.position.x + bw + 34.0 + tw, y2), right - (r.position.x + bw + 34.0 + tw), 0.0, 18.0, false)
	_tea_button("m:tea:more", "", Vector2(r.end.x - 84.0, by), 36.0, bh, "blue", "dots")
	var shut: Rect2 = _lr(Vector2(r.end.x - 40.0, r.position.y + (r.size.y - 28.0) / 2.0), Vector2(28, 28))
	_round(shut, Color("1a3a5e") if _hover == "m:collapse" else Color("10253f"), 14.0, Color(EDGE, 0.9), 1.0)
	var c: Vector2 = shut.get_center()
	var s: float = 6.0 * _f
	draw_line(c - Vector2(s, s), c + Vector2(s, s), Color.WHITE, maxf(1.5, 2.0 * _f), true)
	draw_line(c + Vector2( - s, s), c + Vector2(s, - s), Color.WHITE, maxf(1.5, 2.0 * _f), true)
	_hit("m:collapse", shut, false)

const TEA_SPOTS: Dictionary = {
	4: [[0.17, 0.54], [0.83, 0.54], [0.32, 0.83], [0.68, 0.83]], 
	6: [[0.145, 0.54], [0.855, 0.54], [0.315, 0.83], [0.69, 0.83], [0.066, 0.94], [0.934, 0.94]], 
	8: [[0.13, 0.5], [0.87, 0.5], [0.27, 0.76], [0.73, 0.76], [0.06, 0.95], [0.94, 0.95], [0.4, 0.95], [0.6, 0.95]], 
}

func _tea_stage(r: Rect2) -> void :
	var box: Rect2 = _lr(r.position, r.size)
	draw_rect(box, Color("071224"))
	var tex: Texture2D = pack.picture("l/ui/hangar.webp") if pack != null else null
	if tex != null and tex.get_width() > 0:
		var ts: Vector2 = Vector2(tex.get_width(), tex.get_height())
		var zoom: float = maxf(box.size.x / ts.x, box.size.y / ts.y)
		var part: Vector2 = box.size / zoom
		draw_texture_rect_region(tex, box, Rect2((ts - part) / 2.0, part))
	draw_rect(box, Color(0.02, 0.05, 0.12, 0.28))
	_hit("panel", box, false)
	var s: float = r.size.y / 338.0
	var count: int = int(TeaRoom.room.get("seats", TeaRoom.seats.size()))
	var spots: Array = TEA_SPOTS.get(count, TEA_SPOTS[6])
	var shrink: float = 0.85 if count >= 8 else 1.0
	var host_at: Vector2 = Vector2(r.position.x + r.size.x * 0.5, r.position.y + r.size.y * 0.44)
	_tea_seat(0, host_at, s)
	for k in range(mini(count, spots.size())):
		var spot: Array = spots[k]
		_tea_seat(k + 1, Vector2(r.position.x + r.size.x * float(spot[0]), r.position.y + r.size.y * float(spot[1]) - 20.0 * s), s * shrink)
	if TeaRoom.is_host() and not TeaRoom.requests.is_empty():
		var text: String = "%d người xin lên mic" % TeaRoom.requests.size()
		var w: float = _wide(text, BOLD, 12.0) + 40.0
		_tea_button("m:tea:asks", text, r.position + Vector2(10, 10), w, 28.0, "orange", "up")


func _tea_seat(i: int, at: Vector2, s: float) -> void :
	var who: Dictionary = TeaRoom.host_face() if i == 0 else TeaRoom.seat_at(i)
	var c: int = int(who.get("c", 0))
	var id: String = "m:tea:seat:%d" % i
	var lit: bool = _hover == id
	if c <= 0:
		if i == 0:
			return
		var locked: bool = bool(who.get("locked", false))
		var rad: float = 30.0 * s
		var cc: Vector2 = at + Vector2(0, - rad - 8.0 * s)
		_tea_ellipse(at + Vector2(0, -6.0 * s), rad * 1.15, rad * 0.32, Color("6fd0ff", 0.14), Color("6fd0ff", 0.4))
		var circle: Rect2 = _lr(cc - Vector2(rad, rad), Vector2(rad, rad) * 2.0)
		if locked:
			draw_circle(cc * _f, rad * _f, Color("0b1626", 0.92), true, -1.0, true)
			draw_arc(cc * _f, rad * _f, 0, TAU, 40, Color(DIM, 0.7), maxf(1.0, 1.6 * _f), true)
			_lock((cc + Vector2(0, -5.0 * s)) * _f, 34.0 * s, Color(DIM, 0.95))
			_fwords("Đã khoá", SEMI, 10.0 * maxf(s, 0.9), DIM, "c", cc + Vector2( - rad, 6.0 * s), rad * 2.0, 0.0, 14.0)
		else:
			VoiceUI.grad(self, circle, rad * _f, VoiceUI.BLUE_T.lightened(0.12 if lit else 0.0), VoiceUI.BLUE_B, Color(VoiceUI.BLUE_L, 0.95), 1.8 * _f)
			_plus((cc + Vector2(0, -6.0 * s)) * _f, 28.0 * s, Color.WHITE)
			_fwords("Lên mic", BOLD, 10.0 * maxf(s, 0.9), Color.WHITE, "c", cc + Vector2( - rad, 6.0 * s), rad * 2.0, 1.0, 14.0)
		var label: String = "Ghế %d" % i
		var pw: float = _wide(label, SEMI, 11.0) + 18.0
		_round(_lr(Vector2(at.x - pw / 2.0, at.y), Vector2(pw, 18)), Color(0.03, 0.08, 0.16, 0.8), 9.0, Color(EDGE, 0.8), 1.0)
		_fwords(label, SEMI, 11.0, Color("cfe6ff"), "c", Vector2(at.x - pw / 2.0, at.y), pw, 0.0, 18.0)
		_hit(id, circle.merge(_lr(Vector2(at.x - pw / 2.0, at.y), Vector2(pw, 18))), false)
		return
	var big: bool = i == 0
	var cw: float = (90.0 if big else 64.0) * s
	var ch: float = (115.0 if big else 85.0) * s
	var talking: bool = _tea_talking(c)
	var foot: Vector2 = at + Vector2(0, -4.0 * s)
	_tea_ellipse(foot, cw * 0.55, cw * 0.15, Color(TALK_RING if talking else Color("6fd0ff"), 0.22), Color(TALK_RING if talking else Color("6fd0ff"), 0.85 if talking else 0.5))
	var chibi: Rect2 = Rect2(Vector2(at.x - cw / 2.0, foot.y - ch), Vector2(cw, ch))
	_tea_chibi(int(who.get("a", 0)), chibi)
	if lit:
		draw_rect(_lr(chibi.position, chibi.size), Color(1, 1, 1, 0.06))
	if big:
		_tea_glyph("crown", (Vector2(at.x, chibi.position.y - 2.0 * s)) * _f, 11.0 * s * _f, Color("ffd257"))
	elif i > 0:
		_fwords(str(i), BOLD, 11.0, Color.WHITE, "l", chibi.position + Vector2(-2.0, -4.0), 20.0, 1.0, 14.0, false)

	var chip_at: Vector2 = (chibi.position + Vector2(cw + 2.0, 10.0 * s)) * _f
	var v: Object = _tea_voice()
	if bool(who.get("muted", false)):
		VoiceUI.chip(self, chip_at, 10.0 * _f, "mic_off", VoiceUI.RED, _f)
	elif v != null and v.is_muted(c):
		VoiceUI.chip(self, chip_at, 10.0 * _f, "spk_off", VoiceUI.MUTE_FILL, _f)
	elif talking:
		VoiceUI.chip(self, chip_at, 11.0 * _f, "wave", VoiceUI.WAVE_FILL, _f)

	var name: String = _clip(str(who.get("name", "")), SEMI, 12.0, 104.0)
	var rank: int = int(who.get("rank", 0))
	var medal: Texture2D = pack.picture("l/bxh/s%d.webp" % _tea_medal(rank)) if pack != null and rank > 0 else null
	var pw: float = _wide(name, SEMI, 12.0) + (36.0 if medal != null else 18.0)
	var plate: Rect2 = _lr(Vector2(at.x - pw / 2.0, at.y), Vector2(pw, 20))
	_round(plate, Color(0.03, 0.08, 0.16, 0.85), 10.0, Color(TALK_RING, 0.9) if talking else Color(EDGE, 0.85), 1.0)
	var nx: float = at.x - pw / 2.0 + 9.0
	if medal != null:
		draw_texture_rect(medal, _lr(Vector2(nx - 2.0, at.y + 1.0), Vector2(18, 18)), false)
		nx += 18.0
	_fwords(name, SEMI, 12.0, Color.WHITE, "l", Vector2(nx, at.y), pw, 1.0, 20.0, false)
	var hit: Rect2 = _lr(chibi.position, chibi.size).merge(plate)
	if big:
		var tag_at: Vector2 = Vector2(at.x - 46.0, at.y + 26.0 * maxf(s, 0.85))
		var tag: Rect2 = _lr(tag_at, Vector2(92, 20))
		VoiceUI.grad(self, tag, 10.0 * _f, VoiceUI.ORG_T, VoiceUI.ORG_B, Color(1, 1, 1, 0.7), 1.2 * _f)
		_fwords("CHỦ PHÒNG", BOLD, 11.0, Color.WHITE, "c", tag_at, 92.0, 1.0, 20.0)
	_hit(id, hit, false)

const TALK_RING: Color = Color("4dff7a")

func _tea_people(r: Rect2) -> void :
	var box: Rect2 = _lr(r.position, r.size)
	draw_rect(box, Color("0b1b30"))
	draw_line(Vector2(box.position.x, box.end.y), box.end, Color(EDGE, 0.7), maxf(1.0, _f))
	_hit("panel", box, false)
	var small: bool = _tea_compact
	var n: int = int(TeaRoom.listen.get("n", 0))
	var x: float = r.position.x + 12.0
	if small:
		_fwords("Nghe", SEMI, 11.0, DIM, "l", Vector2(x, r.position.y + 4.0), 40.0, 0.0, 16.0)
		_fwords(str(n), BOLD, 14.0, Color.WHITE, "l", Vector2(x, r.position.y + 20.0), 40.0, 0.0, 20.0)
		x += 40.0
	else:
		_fwords("Người nghe", SEMI, 12.0, DIM, "l", Vector2(x, r.position.y + 8.0), 80.0, 0.0, 18.0)
		_fwords(str(n), BOLD, 16.0, Color.WHITE, "l", Vector2(x, r.position.y + 26.0), 80.0, 0.0, 22.0)
		x += 78.0
	var bw: float = 84.0 if small else 104.0
	var right: float = r.end.x - bw - 16.0
	var radius: float = 15.0 if small else 17.0
	var step: float = radius * 2.0 + 6.0
	var top: Array = TeaRoom.listen.get("top", [])
	var shown: int = 0
	var cy: float = r.position.y + r.size.y / 2.0
	for p: Variant in top:
		if not p is Dictionary:
			continue
		if x + step * (shown + 2) > right:
			break
		var c: Vector2 = Vector2(x + radius + shown * step, cy)
		var pid: String = "m:tea:who:%d" % int(p.get("c", 0))
		_tea_face(int(p.get("a", 0)), c, radius)
		if _tea_talking(int(p.get("c", 0))):
			draw_arc(c * _f, (radius + 2.5) * _f, 0, TAU, 32, TALK_RING, maxf(1.5, 2.0 * _f), true)
		_hit(pid, _lr(c - Vector2(radius, radius), Vector2(radius, radius) * 2.0), false)
		shown += 1
	if n > shown:
		var c: Vector2 = Vector2(x + radius + shown * step, cy)
		draw_circle(c * _f, radius * _f, Color("163a5f"), true, -1.0, true)
		_fwords("+%d" % (n - shown), BOLD, 12.0, Color.WHITE, "c", c - Vector2(radius, 10), radius * 2.0, 0.0, 20.0)
	_tea_button("m:tea:invite", "Mời bạn", Vector2(r.end.x - bw - 10.0, cy - 16.0), bw, 32.0, "blue", "invite")


func _tea_items(wide: float) -> Array:
	var key: Array = [TeaRoom.rev, client.tea_rev, _tea_notes.size(), wide, _f, _emotes.rev]
	if key == _tea_items_key:
		return _tea_items_cache
	_tea_items_key = key
	var rows: Array = TeaRoom.chat_lines(client)
	var fresh: int = mini(client.tea_log.size(), maxi(0, int(client.tea_rev) - TeaRoom.mark))
	var base: int = rows.size() - fresh
	var lines: Array = rows.slice(0, base)
	var k: int = 0
	for j in range(fresh):
		var line_rev: int = int(client.tea_rev) - fresh + 1 + j
		while k < _tea_notes.size() and int(_tea_notes[k].rev) < line_rev:
			lines.append({"sys": true, "text": str(_tea_notes[k].text), "c": 0, "name": "", "own": false})
			k += 1
		lines.append(rows[base + j])
	while k < _tea_notes.size():
		lines.append({"sys": true, "text": str(_tea_notes[k].text), "c": 0, "name": "", "own": false})
		k += 1
	var out: Array = []
	_tea_items_h = 0.0
	for row: Dictionary in lines:
		var item: Dictionary = {"row": row}
		if bool(row.sys):
			var flow: Array = _flow([[str(row.text), false, Color.WHITE]], wide - 60.0, 12.0)
			item["rows"] = flow[0]
			item["widest"] = flow[1]
			item["high"] = (flow[0] as Array).size() * 18.0 + 6.0 + 8.0
		else:
			var line: Dictionary = {"text": str(row.text), "raw": str(row.text), "color": Color("eef5ff")}
			var flow: Array = _flow(_body(line), wide - (FACE_R * 2.0 + 14.0) - 48.0 - BUBBLE_PAD * 2.0, 14.0)
			item["rows"] = flow[0]
			item["widest"] = flow[1]
			item["high"] = (0.0 if bool(row.own) else 18.0) + (flow[0] as Array).size() * ROW_H + BUBBLE_PAD * 2.0 - 4.0 + GAP
		out.append(item)
		_tea_items_h += float(item["high"])
	_tea_items_cache = out
	return out

func _tea_chat(r: Rect2) -> void :
	_tea_area = _lr(r.position, r.size)
	var inner: Rect2 = r.grow_individual(-10.0, -8.0, -10.0, -6.0)
	var list: Array = _tea_items(inner.size.x)
	_tea_max = maxf(0.0, _tea_items_h - inner.size.y)
	_tea_scroll = clampf(_tea_scroll, 0.0, _tea_max)
	if list.is_empty():
		_fwords("Chưa có tin nhắn — chào cả phòng một câu nhé!", REGULAR, 13.0, DIM, "c", Vector2(inner.position.x, inner.position.y + inner.size.y / 2.0 - 12.0), inner.size.x, 0.0, 24.0)
		return
	var y: float = inner.end.y - _tea_items_h + _tea_scroll if _tea_items_h > inner.size.y else inner.position.y
	for item: Dictionary in list:
		var high: float = float(item["high"])
		if y + high >= r.position.y - 40.0 and y <= r.end.y + 40.0:
			_tea_line(item, Vector2(inner.position.x, y), inner.size.x)
		y += high

func _tea_line(item: Dictionary, at: Vector2, wide: float) -> void :
	var row: Dictionary = item["row"]
	var rows: Array = item["rows"]
	if bool(row.sys):
		var pill_w: float = minf(wide - 20.0, float(item["widest"]) + 24.0)
		var high: float = rows.size() * 18.0 + 6.0
		var left: float = at.x + (wide - pill_w) / 2.0
		_round(_lr(Vector2(left, at.y), Vector2(pill_w, high)), Color("10253f", 0.85), 10.0, Color(EDGE, 0.6), 1.0)
		for i in range(rows.size()):
			var line_row: Array = rows[i]
			var run: float = 0.0
			if not line_row.is_empty():
				var last: Array = line_row[-1]
				run = float(last[2]) + _wide(str(last[0]), REGULAR, 12.0)
			var x: float = left + (pill_w - run) / 2.0
			for seg: Array in line_row:
				_fwords(str(seg[0]), REGULAR, 12.0, Color("cfe6ff"), "l", Vector2(x + float(seg[2]), at.y + 3.0 + 18.0 * i), wide, 0.0, 18.0, false)
		return
	var own: bool = bool(row.own)
	var c: int = int(row.c)
	var face_x: float = at.x + wide - FACE_R - 2.0 if own else at.x + FACE_R + 2.0
	_tea_face(_tea_avatar(c), Vector2(face_x, at.y + FACE_R + 2.0), FACE_R)
	var left: float = at.x + FACE_R * 2.0 + 12.0
	var by: float = at.y
	if not own:
		_fwords(_clip(str(row.name), SEMI, 12.0, 200.0), SEMI, 12.0, Color("9fdcff"), "l", Vector2(left, at.y), 204.0, 0.0, 18.0, false)
		by += 18.0
	var bubble_w: float = float(item["widest"]) + BUBBLE_PAD * 2.0
	var bubble_h: float = rows.size() * ROW_H + BUBBLE_PAD * 2.0 - 4.0
	var bx: float = at.x + wide - FACE_R * 2.0 - 12.0 - bubble_w if own else left
	_round(_lr(Vector2(bx, by), Vector2(bubble_w, bubble_h)), OWN_BUBBLE if own else OTHER_BUBBLE, 12.0, Color(EDGE, 0.55), 1.0)
	for i in range(rows.size()):
		var y: float = by + BUBBLE_PAD - 2.0 + ROW_H * i
		for seg: Array in rows[i]:
			if not str(seg[3]).is_empty():
				_emote(str(seg[3]), Rect2(Vector2(bx + BUBBLE_PAD + float(seg[2]), y + (ROW_H - EMO_SIDE) / 2.0), Vector2(EMO_SIDE, EMO_SIDE)))
				continue
			_fwords(str(seg[0]), REGULAR, 14.0, Color("eef5ff"), "l", Vector2(bx + BUBBLE_PAD + float(seg[2]), y), bubble_w, 0.0, ROW_H, false)

func _tea_bar(r: Rect2) -> void :
	var box: Rect2 = _lr(r.position, r.size)
	draw_rect(box, BAR_BG)
	draw_line(box.position, Vector2(box.end.x, box.position.y), Color(EDGE, 0.8), maxf(1.0, _f))
	_hit("panel", box, false)
	var small: bool = _tea_compact
	var bh: float = 40.0 if small else 44.0
	var y: float = r.position.y + (r.size.y - bh) / 2.0
	var x: float = r.position.x + 10.0
	var v: Object = _tea_voice()
	var seat: int = TeaRoom.my_seat()
	var seated: bool = seat >= 0
	var mic_w: float = 146.0 if small else 160.0
	var mic: Rect2 = _lr(Vector2(x, y), Vector2(mic_w, bh))
	var title: String
	var sub: String
	var on: bool = false
	var id: String = "m:tea:mic"
	if seated:
		var state: String = v.tea_mic_state() if v != null else "off"
		on = state != "off"
		title = "MIC ĐANG BẬT" if on else "MIC TẮT"
		if v == null:
			sub = "Voice chỉ có ở bản web"
		elif on and v.mic_mode() == "ptt":
			sub = "Giữ nút để nói" if _mobile else "Bấm để tắt · giữ %s" % load("res://ui/settings.gd").ptt_name(int(Settings.value("mic_ptt_key")))
		elif on:
			sub = "Bấm để tắt"
		else:
			sub = "Bấm để bật"
		if on:
			VoiceUI.grad(self, mic, bh / 2.0 * _f, VoiceUI.ORG_T.lightened(0.08 if _hover == id else 0.0), VoiceUI.ORG_B, Color(1, 1, 1, 0.7), 1.4 * _f)
			if state == "talk":
				VoiceUI.glow(self, mic, bh / 2.0 * _f, TALK_RING, _f)
		else:
			VoiceUI.grad(self, mic, bh / 2.0 * _f, VoiceUI.OFF_T.lightened(0.08 if _hover == id else 0.0), VoiceUI.OFF_B, VoiceUI.OFF_L, 1.4 * _f)
		_tea_mic_box = mic
	else:
		var approve: bool = bool(TeaRoom.room.get("approve", false))
		id = "m:tea:ask" if approve else "m:tea:up"
		title = "XIN LÊN MIC" if approve else "LÊN MIC"
		sub = "Chủ phòng duyệt" if approve else "Lên ghế mới nói"
		VoiceUI.grad(self, mic, bh / 2.0 * _f, VoiceUI.BLUE_T.lightened(0.08 if _hover == id else 0.0), VoiceUI.BLUE_B, VoiceUI.BLUE_L, 1.4 * _f)
	VoiceUI.draw_icon(self, "mic" if on or not seated else "mic_off", (Vector2(x + 20.0, y + bh / 2.0)) * _f, 20.0 * _f, Color.WHITE)
	_fwords(title, BOLD, 13.0, Color.WHITE, "l", Vector2(x + 36.0, y + 3.0), mic_w - 40.0, 1.0, 20.0)
	_fwords(sub, REGULAR, 9.5, Color(1, 1, 1, 0.9), "l", Vector2(x + 36.0, y + bh / 2.0), mic_w - 42.0, 0.0, 16.0)
	_hit(id, mic, false)
	x += mic_w + 8.0
	var deaf: bool = v != null and bool(v.tea_deaf)
	var spk: Rect2 = _lr(Vector2(x, y), Vector2(bh, bh))
	VoiceUI.grad(self, spk, 10.0 * _f, (VoiceUI.OFF_T if deaf else VoiceUI.BLUE_T).lightened(0.08 if _hover == "m:tea:deaf" else 0.0), VoiceUI.OFF_B if deaf else VoiceUI.BLUE_B, Color(1, 1, 1, 0.5), 1.2 * _f)
	VoiceUI.draw_icon(self, "spk_off" if deaf else "spk", spk.get_center(), 20.0 * _f, Color.WHITE)
	_hit("m:tea:deaf", spk, false)
	_tips["m:tea:deaf"] = "Bật loa Phòng Trà" if deaf else "Tắt loa Phòng Trà"
	x += bh + 8.0
	var right: float = r.end.x - 10.0
	var leave_w: float = 64.0 if small else 72.0
	right -= leave_w
	_tea_button("m:tea:leave", "Rời", Vector2(right, y), leave_w, bh, "blue", "exit")
	if seat > 0:
		var down_w: float = 88.0 if small else 100.0
		right -= down_w + 6.0
		_tea_button("m:tea:down", "Rời ghế", Vector2(right, y), down_w, bh, "blue", "down")
	right -= 62.0
	_tea_button("m:tea:send", "Gửi", Vector2(right, y), 56.0, bh, "blue")
	var field: Rect2 = Rect2(Vector2(x, y), Vector2(right - 6.0 - x, bh))
	_round(_lr(field.position, field.size), FIELD, 12.0, Color(EDGE, 0.8), 1.0)
	_fput(_tea_say, field.grow_individual(-10.0, -2.0, -8.0, -2.0), 14.0)
	_tea_used["say"] = true



func _tea_open_menu(menu: Dictionary) -> void :
	_tea_menu = menu
	_tea_menu["at"] = _mouse / _tea_k
	_tea_sure = {}

func _tea_menu_rows() -> Array:
	var rows: Array = []
	var me: int = int(client.account_oid)
	var boss: bool = TeaRoom.is_host()
	var v: Object = _tea_voice()
	match str(_tea_menu.get("kind", "")):
		"room":
			rows.append(["invite", "Mời bạn"])
			rows.append(["deaf", "Bật loa" if v != null and bool(v.tea_deaf) else "Tắt loa"])
			if boss:
				rows.append(["edit", "Sửa phòng"])
				rows.append(["close", "Đóng phòng"])
			rows.append(["leave", "Rời phòng"])
		"asks":
			for q: Variant in TeaRoom.requests:
				if q is Dictionary and rows.size() < 8:
					rows.append(["ask:%d" % int(q.get("c", 0)), "Mời %s lên mic" % _clip(str(q.get("name", "")), SEMI, 13.0, 160.0)])
		"share":
			if not client.guild.is_empty():
				rows.append(["guild", "Gửi vào kênh Guild"])
			if client.in_chat_team():
				rows.append(["team", "Gửi vào kênh Team"])
			var pals: int = 0
			for pal: Dictionary in contacts():
				if bool(pal.online) and int(pal.oid) > 0 and pals < 6:
					rows.append(["pal:%d" % int(pal.oid), "Mời " + _clip(str(pal.name), SEMI, 13.0, 170.0)])
					pals += 1
		"seat", "who":
			var i: int = int(_tea_menu.get("i", -1))
			var c: int = int(_tea_menu.get("c", 0))
			if c <= 0:
				if boss and i > 0:
					rows.append(["unlock" if bool(TeaRoom.seat_at(i).get("locked", false)) else "lock", ("Mở khoá ghế %d" if bool(TeaRoom.seat_at(i).get("locked", false)) else "Khoá ghế %d") % i])
				return rows
			if c == me:
				if i > 0:
					rows.append(["self_down", "Rời ghế"])
				rows.append(["info", "Xem thông tin"])
				return rows
			if boss and i > 0:
				rows.append(["down", "Mời xuống mic"])
				rows.append(["unmute" if bool(TeaRoom.seat_at(i).get("muted", false)) else "mute", "Bật mic ghế này" if bool(TeaRoom.seat_at(i).get("muted", false)) else "Tắt mic ghế này"])
				rows.append(["lock", "Khoá ghế %d" % i])
			if boss and i < 0:
				rows.append(["call", "Mời lên mic"])
			rows.append(["info", "Xem thông tin"])
			rows.append(["hush", "Bật lại tiếng" if v != null and v.is_muted(c) else "Tắt tiếng (chỉ mình tôi)"])
			if boss:
				rows.append(["kick", "Mời ra khỏi phòng (cấm 10 phút)"])
				rows.append(["give", "Nhường chủ"])
			rows.append(["report", "Tố cáo voice"])
	return rows

func _tea_draw_menu(panel: Rect2) -> void :
	var rows: Array = _tea_menu_rows()
	if rows.is_empty():
		_tea_menu = {}
		return
	var kind: String = str(_tea_menu.kind)
	var wide: float = 260.0
	var head: float = 36.0 if kind in ["seat", "who"] else 0.0
	var high: float = head + rows.size() * 34.0 + 8.0
	var at: Vector2 = _tea_menu.get("at", Vector2(100, 100))
	at.x = clampf(at.x, RAIL_W + 4.0, panel.end.x - wide - 6.0)
	at.y = clampf(at.y, 6.0, panel.end.y - high - 6.0)
	var box: Rect2 = _lr(at, Vector2(wide, high))
	draw_rect(box.grow(3.0 * _f), Color(0, 0, 0, 0.25))
	VoiceUI.grad(self, box, 10.0 * _f, VoiceUI.PANEL_T, VoiceUI.PANEL_B, Color(VoiceUI.BLUE_L, 0.8), 1.2 * _f)
	_hit("m:tea:menu", box, false)
	_tea_cover(box)
	_add(box)
	var y: float = at.y + 4.0
	if head > 0.0:
		var c: int = int(_tea_menu.get("c", 0))
		var i: int = int(_tea_menu.get("i", -1))
		var title: String = _tea_name_of(c) if c > 0 else "Ghế %d" % i
		if c > 0:
			_tea_face(_tea_avatar(c), Vector2(at.x + 22.0, y + 16.0), 13.0)
		var where: String = "" if c <= 0 else (" · chủ phòng" if i == 0 else (" · ghế %d" % i if i > 0 else " · người nghe"))
		_fwords(_clip(title + where, BOLD, 13.0, wide - 54.0), BOLD, 13.0, Color.WHITE, "l", Vector2(at.x + 42.0, y + 4.0), wide - 50.0, 1.0, 24.0)
		draw_line(_lr(Vector2(at.x + 8.0, y + head - 2.0), Vector2.ZERO).position, _lr(Vector2(at.x + wide - 8.0, y + head - 2.0), Vector2.ZERO).position, Color(1, 1, 1, 0.2), maxf(1.0, _f))
		y += head
	for row: Array in rows:
		var code: String = str(row[0])
		var id: String = "m:tea:do:" + code
		var r: Rect2 = _lr(Vector2(at.x + 4.0, y), Vector2(wide - 8.0, 32))
		if _hover == id:
			_round(r, Color(1, 1, 1, 0.12), 8.0)
		var sure: bool = str(_tea_sure.get("code", "")) == code and _time - float(_tea_sure.get("at", -10.0)) < 3.0
		var danger: bool = code in ["kick", "close", "report", "leave"]
		var label: String = "Bấm lần nữa để xác nhận" if sure else str(row[1])
		_fwords(label, SEMI, 13.0, Color("ffb3a8") if danger or sure else Color.WHITE, "l", Vector2(at.x + 16.0, y), wide - 28.0, 0.0, 32.0)
		_hit(id, r, false)
		y += 34.0




func _tea_cover(over: Rect2) -> void :
	for pair: Array in [["say", _tea_say], ["find", _tea_find]]:
		var edit: LineEdit = pair[1]
		if edit != null and _tea_used.has(pair[0]) and over.intersects(Rect2(edit.position, edit.size)):
			_tea_used.erase(pair[0])
			edit.visible = false
			edit.release_focus()

func _tea_draw_dialog(panel: Rect2) -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_tea_cover(Rect2(Vector2.ZERO, size))
	_hit("m:tea:veil", Rect2(Vector2.ZERO, size), false)
	var kind: String = str(_tea_dialog.kind)
	if kind in ["create", "edit"]:
		_tea_form_dialog(panel, kind == "edit")
		return

	var wide: float = 370.0
	var high: float = 214.0
	var at: Vector2 = Vector2(roundf((panel.size.x - wide) / 2.0), roundf((panel.size.y - high) / 2.0))
	_hit("panel", _lr(at, Vector2(wide, high)), false)
	if not _tea_compact:
		_fblit("iv_guy", at + Vector2(-96.0, high - 196.0), 120.0, 195.0)
	_fblit("iv_frame", at)
	var title: String
	var text: String
	match kind:
		"pass":
			title = "PHÒNG CÓ MẬT KHẨU"
			text = "Nhập mật khẩu 4 số để vào phòng."
		"invite":
			title = "MỜI LÊN MIC"
			text = "Chủ phòng mời bạn lên mic ghế %d. Lên ghế xong mic vẫn tắt — bấm MIC khi muốn nói." % int(_tea_dialog.get("seat", 0))
		"leave":
			title = "RỜI PHÒNG"
			text = "Bạn là chủ phòng. Giao chủ cho người khác rồi rời, hay đóng luôn phòng?"
		_:
			title = ""
			text = ""
	_fwords(title, BOLD, 15.0, Color("ffd257"), "c", at + Vector2(0, 12), wide, 1.0, 24.0)
	_fpara(text, SEMI, 13.0, Color.WHITE, at + Vector2(40, 52), wide - 80.0, 3)
	if kind == "pass":
		var field: Rect2 = Rect2(at + Vector2(wide / 2.0 - 60.0, 110.0), Vector2(120, 32))
		_round(_lr(field.position, field.size), FIELD, 10.0, Color("ffd257", 0.8), 1.0)
		_fput(_tea_pass, field.grow(-4.0), 16.0, "c")
		_tea_used["pass"] = true
		if not _tea_pass.has_focus() and not _mobile:
			_tea_pass.grab_focus()
	var by: float = at.y + high - 50.0
	if kind == "leave":
		_tea_button("m:tea:ok", "Giao & rời", Vector2(at.x + 40.0, by), 130.0, 34.0, "blue")
		_tea_button("m:tea:no", "Đóng phòng", Vector2(at.x + wide - 170.0, by), 130.0, 34.0, "orange")
		return
	var ok: Rect2 = _fblit("iv_ok", Vector2(at.x + 75.0, by))
	var no: Rect2 = _fblit("iv_no", Vector2(at.x + wide - 175.0, by))
	if _hover == "m:tea:ok":
		draw_rect(ok, Color(1, 1, 1, 0.12))
	if _hover == "m:tea:no":
		draw_rect(no, Color(1, 1, 1, 0.12))
	_hit("m:tea:ok", ok, false)
	_hit("m:tea:no", no, false)

func _tea_form_dialog(panel: Rect2, edit: bool) -> void :
	var wide: float = 460.0
	var high: float = 340.0
	var at: Vector2 = Vector2(roundf((panel.size.x - wide) / 2.0), roundf((panel.size.y - high) / 2.0))
	var box: Rect2 = _lr(at, Vector2(wide, high))
	VoiceUI.grad(self, box, 16.0 * _f, VoiceUI.PANEL_T, VoiceUI.PANEL_B, Color("f6c453"), 2.4 * _f)
	draw_rect(box.grow(-6.0 * _f), Color(0, 0, 0, 0))
	_hit("panel", box, false)
	_add(box)
	if not _tea_compact:
		_fblit("iv_guy", at + Vector2(-112.0, high - 230.0), 140.0, 227.0)
	_fwords("SỬA PHÒNG" if edit else "TẠO PHÒNG TRÀ", BOLD, 17.0, Color("ffd257"), "c", at + Vector2(0, 8), wide, 1.0, 28.0)
	var x0: float = at.x + 28.0
	var fx: float = x0 + 92.0
	var fw: float = at.x + wide - 28.0 - fx
	var y: float = at.y + 46.0
	_fwords("Tên phòng", SEMI, 13.0, Color("cfe6ff"), "l", Vector2(x0, y), 90.0, 0.0, 30.0)
	_round(_lr(Vector2(fx, y), Vector2(fw, 30)), FIELD, 10.0, Color(EDGE, 0.9), 1.0)
	_fput(_tea_name, Rect2(Vector2(fx + 8.0, y + 1.0), Vector2(fw - 58.0, 28)), 14.0)
	_tea_used["name"] = true
	_fwords("%d/%d" % [_tea_name.text.length(), TeaRoom.NAME_MAX], REGULAR, 11.0, DIM, "r", Vector2(fx + fw - 50.0, y), 42.0, 0.0, 30.0)
	y += 40.0
	_fwords("Chủ đề", SEMI, 13.0, Color("cfe6ff"), "l", Vector2(x0, y), 90.0, 0.0, 24.0)
	var cx: float = fx
	var cy: float = y
	for tag: Array in TeaRoom.TAGS:
		var w: float = (fw - 12.0) / 3.0
		var id: String = "m:tea:ftag:" + str(tag[0])
		var on: bool = str(_tea_form.tag) == str(tag[0])
		var tint: Color = tag[2]
		var r: Rect2 = _lr(Vector2(cx, cy), Vector2(w, 24))
		_round(r, Color(tint, 0.32) if on else Color("0d2138"), 12.0, Color(tint, 0.95) if on else Color(EDGE, 0.7), 1.0)
		draw_circle(Vector2(cx + 13.0, cy + 12.0) * _f, 4.0 * _f, tint, true, -1.0, true)
		_fwords(str(tag[1]), SEMI, 12.0, Color.WHITE if on else Color("cfe6ff"), "l", Vector2(cx + 22.0, cy), w - 26.0, 0.0, 24.0)
		_hit(id, r, false)
		cx += w + 6.0
		if cx + 10.0 > fx + fw:
			cx = fx
			cy += 28.0
	y = cy + (0.0 if cx == fx else 28.0) + 8.0
	_fwords("Ghế mic", SEMI, 13.0, Color("cfe6ff"), "l", Vector2(x0, y), 90.0, 0.0, 28.0)
	if edit:
		_fwords("%d ghế + ghế chủ · tối đa %d người" % [int(TeaRoom.room.get("seats", 6)), TeaRoom.PEOPLE_MAX], REGULAR, 12.0, DIM, "l", Vector2(fx, y), fw, 0.0, 28.0)
	else:
		var sx: float = fx
		for n: int in TeaRoom.SEATS:
			var id: String = "m:tea:fseat:%d" % n
			var on: bool = int(_tea_form.seats) == n
			var r: Rect2 = _lr(Vector2(sx, y), Vector2(48, 28))
			if on:
				VoiceUI.grad(self, r, 8.0 * _f, VoiceUI.ORG_T, VoiceUI.ORG_B, Color(1, 1, 1, 0.6), 1.2 * _f)
			else:
				_round(r, Color("0d2138"), 8.0, Color(EDGE, 0.8), 1.0)
			_fwords(str(n), BOLD, 14.0, Color.WHITE, "c", Vector2(sx, y), 48.0, 1.0 if on else 0.0, 28.0)
			_hit(id, r, false)
			sx += 54.0
		_fwords("+ ghế chủ · tối đa %d người" % TeaRoom.PEOPLE_MAX, REGULAR, 11.0, DIM, "l", Vector2(sx + 4.0, y), fx + fw - sx - 4.0, 0.0, 28.0)
	y += 38.0
	var locked: bool = bool(_tea_form.lock)
	_fblit("iv_chk_on" if locked else "iv_chk_off", Vector2(x0, y + 3.0))
	_fwords("Mật khẩu", SEMI, 13.0, Color("cfe6ff"), "l", Vector2(x0 + 28.0, y), 80.0, 0.0, 28.0)
	_hit("m:tea:flock", _lr(Vector2(x0, y), Vector2(110, 28)), false)
	if locked:
		_round(_lr(Vector2(fx + 20.0, y), Vector2(90, 28)), FIELD, 8.0, Color("ffd257", 0.8), 1.0)
		_fput(_tea_pass, Rect2(Vector2(fx + 24.0, y + 1.0), Vector2(82, 26)), 14.0, "c")
		_tea_used["pass"] = true
		_fwords("4 số, người vào phải nhập", REGULAR, 11.0, DIM, "l", Vector2(fx + 120.0, y), fw - 120.0, 0.0, 28.0)
	y += 34.0
	var approve: bool = bool(_tea_form.approve)
	_fblit("iv_chk_on" if approve else "iv_chk_off", Vector2(x0, y + 3.0))
	_fwords("Lên mic: chỉ khi chủ phòng mời", SEMI, 13.0, Color("cfe6ff"), "l", Vector2(x0 + 28.0, y), wide - 70.0, 0.0, 28.0)
	_hit("m:tea:fapprove", _lr(Vector2(x0, y), Vector2(wide - 56.0, 28)), false)
	y += 34.0
	if not edit:
		_fpara("Cần cấp %d để tạo phòng · mỗi người 1 phòng, 3 phòng mỗi giờ. Phòng không lưu: đóng khi chủ đóng, khi trống, hoặc khi máy chủ khởi động lại." % TeaRoom.LEVEL_CREATE, REGULAR, 10.5, DIM, Vector2(x0, y), wide - 56.0, 3)
	var by: float = at.y + high - 48.0
	var ok: Rect2 = _fblit("iv_ok", Vector2(at.x + wide / 2.0 - 112.0, by))
	var no: Rect2 = _fblit("iv_no", Vector2(at.x + wide / 2.0 + 12.0, by))
	if _hover == "m:tea:ok":
		draw_rect(ok, Color(1, 1, 1, 0.12))
	if _hover == "m:tea:no":
		draw_rect(no, Color(1, 1, 1, 0.12))
	_hit("m:tea:ok", ok, false)
	_hit("m:tea:no", no, false)

func _tea_open_form(edit: bool) -> void :
	if edit:
		_tea_form = {"tag": str(TeaRoom.room.get("tag", "tangau")), "seats": int(TeaRoom.room.get("seats", TeaRoom.SEATS_DEFAULT)), 
			"lock": bool(TeaRoom.room.get("lock", false)), "approve": bool(TeaRoom.room.get("approve", false))}
		_tea_name.text = str(TeaRoom.room.get("name", ""))
	else:
		_tea_form = {"tag": "tangau", "seats": TeaRoom.SEATS_DEFAULT, "lock": false, "approve": false}
		var who: String = str(client.character.get("name", ""))
		_tea_name.text = ("Phòng của " + who).left(TeaRoom.NAME_MAX) if not who.is_empty() else ""
	_tea_pass.text = ""
	_tea_menu = {}
	_tea_dialog = {"kind": "edit" if edit else "create"}



func _tea_act(id: String) -> void :
	var v: Object = _tea_voice()
	if id != "menu" and not id.begins_with("do:") and not id.begins_with("seat:") and not id.begins_with("who:") and id not in ["more", "asks", "invite"]:
		_tea_menu = {}
	if id.begins_with("f:"):
		_tea_list_scroll = 0.0
		TeaRoom.set_filter(client, "f", id.substr(2))
		return
	if id.begins_with("tag:"):
		_tea_list_scroll = 0.0
		TeaRoom.set_filter(client, "tag", id.substr(4))
		return
	if id.begins_with("page:"):
		_tea_list_scroll = 0.0
		TeaRoom.go_page(client, TeaRoom.page + int(id.substr(5)))
		return
	if id.begins_with("join:"):
		var room_id: int = int(id.substr(5))
		if TeaRoom.in_room() and TeaRoom.room_id() == room_id:
			_tea_page = "room"
			return
		var info: Dictionary = {}
		for r: Dictionary in TeaRoom.rooms:
			if int(r.id) == room_id:
				info = r
		if bool(info.get("full", false)):
			say(str(TeaRoom.CODES.full))
			return
		if bool(info.get("lock", false)):
			_tea_dialog = {"kind": "pass", "id": room_id}
			_tea_pass.text = ""
			return
		TeaRoom.join(client, room_id)
		return
	if id.begins_with("seat:"):
		_tea_seat_click(int(id.substr(5)))
		return
	if id.begins_with("who:"):
		var c: int = int(id.substr(4))
		if c > 0:
			_tea_open_menu({"kind": "who", "i": TeaRoom.seat_of(c), "c": c})
		return
	if id.begins_with("card:"):
		var card_id: int = int(id.substr(5))
		if TeaRoom.gate < 0 and not TeaRoom.in_room():
			say(str(TeaRoom.CODES.off))
			return
		if not _open:
			open()
		_view = "tea"
		_tea_seen = true
		if TeaRoom.in_room() and TeaRoom.room_id() == card_id:
			_tea_page = "room"
		elif card_id > 0:
			_tea_page = "list"
			TeaRoom.join(client, card_id)
		return
	if id.begins_with("ftag:"):
		_tea_form.tag = id.substr(5)
		return
	if id.begins_with("fseat:"):
		_tea_form.seats = int(id.substr(6))
		return
	if id.begins_with("do:"):
		_tea_do(id.substr(3))
		return
	match id:
		"menu", "veil":
			pass
		"create":
			var level: int = int(client.character.get("level", 0))
			if level > 0 and level < TeaRoom.LEVEL_CREATE:
				say("Cần cấp %d để tạo phòng." % TeaRoom.LEVEL_CREATE)
				return
			_tea_open_form(false)
		"room":
			_tea_page = "room"
			TeaRoom.want_state(client, true)
		"back":
			_tea_page = "list"
			TeaRoom.want_list(client, true)
		"refresh":
			TeaRoom.want_list(client, true)
		"random":
			TeaRoom.join(client, 0)
		"nolock":
			_tea_list_scroll = 0.0
			TeaRoom.set_filter(client, "nolock", not bool(TeaRoom.filter.nolock))
		"more":
			_tea_open_menu({"kind": "room"})
		"asks":
			_tea_open_menu({"kind": "asks"})
		"invite":
			_tea_open_menu({"kind": "share"})
			if _tea_menu_rows().is_empty():
				_tea_menu = {}
				say("Chưa có ai để mời — vào Guild / Team hoặc kết bạn trước.")
		"mic":
			if _tea_skip:
				_tea_skip = false
				return
			if v == null:
				say("Voice Phòng Trà chỉ có ở bản web.")
				return
			v.tea_toggle_mic(TeaRoom.my_seat() >= 0)
		"deaf":
			if v == null:
				say("Voice Phòng Trà chỉ có ở bản web.")
				return
			v.tea_set_deaf( not bool(v.tea_deaf))
		"up":
			var free: int = _tea_free_seat()
			if free <= 0:
				say("Hết ghế trống.")
			elif _tea_level_low():
				say("Cần cấp %d để lên mic." % TeaRoom.LEVEL_SEAT)
			else:
				TeaRoom.seat(client, "up", free)
		"ask":
			if _tea_level_low():
				say("Cần cấp %d để lên mic." % TeaRoom.LEVEL_SEAT)
				return
			TeaRoom.seat(client, "ask")
			say("Đã xin chủ phòng cho lên mic.")
		"down":
			TeaRoom.seat(client, "down")
		"send":
			_tea_send()
		"leave":
			if TeaRoom.is_host() and _tea_heir() > 0:
				_tea_dialog = {"kind": "leave"}
			else:
				TeaRoom.leave(client)
		"flock":
			_tea_form.lock = not bool(_tea_form.lock)
		"fapprove":
			_tea_form.approve = not bool(_tea_form.approve)
		"ok":
			_tea_confirm()
		"no":
			var kind: String = str(_tea_dialog.get("kind", ""))
			if kind == "invite":
				TeaRoom.decline()
			elif kind == "leave":
				TeaRoom.host(client, "close")
				TeaRoom.leave(client)
			_tea_dialog = {}

func _tea_level_low() -> bool:
	var level: int = int(client.character.get("level", 0))
	return level > 0 and level < TeaRoom.LEVEL_SEAT

func _tea_free_seat() -> int:
	for k in range(1, int(TeaRoom.room.get("seats", TeaRoom.seats.size())) + 1):
		var s: Dictionary = TeaRoom.seat_at(k)
		if int(s.get("c", 0)) <= 0 and not bool(s.get("locked", false)):
			return k
	return 0


func _tea_heir() -> int:
	var me: int = int(client.account_oid)
	for k in range(1, int(TeaRoom.room.get("seats", TeaRoom.seats.size())) + 1):
		var c: int = int(TeaRoom.seat_at(k).get("c", 0))
		if c > 0 and c != me:
			return c
	for p: Variant in TeaRoom.listen.get("top", []):
		if p is Dictionary and int(p.get("c", 0)) > 0 and int(p.get("c", 0)) != me:
			return int(p.get("c", 0))
	return 0

func _tea_seat_click(i: int) -> void :
	var who: Dictionary = TeaRoom.host_face() if i == 0 else TeaRoom.seat_at(i)
	var c: int = int(who.get("c", 0))
	if c > 0:
		_tea_open_menu({"kind": "seat", "i": i, "c": c})
		return
	if i <= 0:
		return
	if TeaRoom.is_host():
		_tea_open_menu({"kind": "seat", "i": i, "c": 0})
		return
	if bool(who.get("locked", false)):
		say(str(TeaRoom.CODES.seatlock))
		return
	if _tea_level_low():
		say("Cần cấp %d để lên mic." % TeaRoom.LEVEL_SEAT)
		return
	if bool(TeaRoom.room.get("approve", false)):
		TeaRoom.seat(client, "ask", i)
		say("Đã xin chủ phòng cho lên mic.")
		return
	TeaRoom.seat(client, "up", i)

func _tea_do(code: String) -> void :
	var menu: Dictionary = _tea_menu
	var i: int = int(menu.get("i", -1))
	var c: int = int(menu.get("c", 0))
	var v: Object = _tea_voice()
	if code in ["kick", "close"] and not (str(_tea_sure.get("code", "")) == code and _time - float(_tea_sure.get("at", -10.0)) < 3.0):
		_tea_sure = {"code": code, "at": _time}
		return
	_tea_menu = {}
	_tea_sure = {}
	if code.begins_with("ask:"):
		var who: int = int(code.substr(4))
		var free: int = _tea_free_seat()
		if free <= 0:
			say("Hết ghế trống — mời ai đó xuống trước.")
		else:
			TeaRoom.host(client, "invite", who, free)
		return
	if code.begins_with("pal:"):
		var oid: int = int(code.substr(4))
		for pal: Dictionary in contacts():
			if int(pal.oid) == oid:
				_tea_share("pal", oid, str(pal.name))
		return
	match code:
		"invite":
			_tea_open_menu({"kind": "share"})
			_tea_menu["at"] = menu.get("at", Vector2(200, 200))
			if _tea_menu_rows().is_empty():
				_tea_menu = {}
				say("Chưa có ai để mời — vào Guild / Team hoặc kết bạn trước.")
		"deaf":
			if v != null:
				v.tea_set_deaf( not bool(v.tea_deaf))
			else:
				say("Voice Phòng Trà chỉ có ở bản web.")
		"edit":
			_tea_open_form(true)
		"close":
			TeaRoom.host(client, "close")
		"leave":
			_tea_act("leave")
		"guild", "team":
			_tea_share(code)
		"self_down":
			TeaRoom.seat(client, "down")
		"down", "mute", "unmute", "lock", "unlock":
			TeaRoom.host(client, code, c if code in ["down", "mute", "unmute"] else 0, i)
		"call":
			var free: int = _tea_free_seat()
			if free <= 0:
				say("Hết ghế trống — mời ai đó xuống trước.")
			else:
				TeaRoom.host(client, "invite", c, free)
		"kick", "give":
			TeaRoom.host(client, code, c)
		"hush":
			if v != null:
				v.toggle_mute(c)
			else:
				say("Voice Phòng Trà chỉ có ở bản web.")
		"report":
			if v != null:
				v.report(c)
			else:
				say("Voice Phòng Trà chỉ có ở bản web.")
		"info":
			var uuid: String = _tea_uuid(c)
			if uuid.is_empty():
				say("Chưa xem được hồ sơ người chơi này.")
			else:
				player_info_asked.emit(uuid)


func _tea_uuid(c: int) -> String:
	if c == int(client.account_oid):
		return str(client.char_uuid) if client.get("char_uuid") != null else ""
	for row: Dictionary in client.tea_log:
		if int(row.get("oid", 0)) == c and not str(row.get("uuid", "")).is_empty():
			return str(row.uuid)
	for raw: Dictionary in client.chat_log:
		if int(raw.get("oid", 0)) == c and not str(raw.get("uuid", "")).is_empty():
			return str(raw.uuid)
	for pal: Dictionary in contacts():
		if int(pal.oid) == c:
			return str(pal.uuid)
	return ""

func _tea_confirm() -> void :
	var kind: String = str(_tea_dialog.get("kind", ""))
	match kind:
		"pass":
			var pin: String = _tea_pass.text.strip_edges()
			if pin.length() != 4:
				say("Mật khẩu là 4 số.")
				return
			TeaRoom.join(client, int(_tea_dialog.get("id", 0)), pin)
			_tea_dialog = {}
		"invite":
			TeaRoom.seat(client, "accept", int(_tea_dialog.get("seat", 0)))
			_tea_dialog = {}
		"leave":
			var heir: int = _tea_heir()
			_tea_dialog = {}
			TeaRoom.leave(client, heir)
		"create", "edit":
			var name: String = _tea_name.text.strip_edges()
			if name.length() < 2:
				say("Tên phòng cần 2–20 ký tự.")
				return
			var pin: String = _tea_pass.text.strip_edges() if bool(_tea_form.lock) else ""
			if bool(_tea_form.lock) and pin.length() != 4 and not (kind == "edit" and pin.is_empty() and bool(TeaRoom.room.get("lock", false))):
				say("Mật khẩu là 4 số.")
				return
			if kind == "create":
				TeaRoom.create(client, name, str(_tea_form.tag), int(_tea_form.seats), pin, bool(_tea_form.approve))
			else:
				var extra: Dictionary = {"name": name, "tag": str(_tea_form.tag), "approve": bool(_tea_form.approve)}
				if not bool(_tea_form.lock):
					extra["pass"] = ""
				elif not pin.is_empty():
					extra["pass"] = pin
				TeaRoom.host(client, "edit", 0, 0, extra)
			_tea_dialog = {}



func _draw_tea_card(item: Dictionary, rect: Rect2, own: bool) -> void :
	var line: Dictionary = item["line"]
	var id: int = int(item["tea"])
	var hit: String = "m:tea:card:%d" % id
	var box: Rect2 = _lr(rect.position, rect.size)
	_round(box, (OWN_BUBBLE if own else OTHER_BUBBLE).lightened(0.08 if _hover == hit else 0.0), 12.0, Color("ffb15a", 0.8), 1.0)
	var icon: Rect2 = _lr(rect.position + Vector2(8, 9), Vector2(38, 38))
	_round(icon, Color(PICKED, 0.35), 10.0)
	_tea_glyph("tea", icon.get_center(), 9.0 * _f, Color.WHITE)
	_fwords("Phòng Trà · bấm để vào", BOLD, 12.0, Color("ffd6a0"), "l", rect.position + Vector2(54, 8), rect.size.x - 62.0, 0.0, 18.0)
	var excerpt: String = str(line.get("text", "")).trim_prefix(": ").trim_prefix(TeaRoom.SHARE_HEAD)
	_fwords(_clip(excerpt, REGULAR, 12.0, rect.size.x - 64.0), REGULAR, 12.0, Color("eef5ff"), "l", rect.position + Vector2(54, 28), rect.size.x - 62.0, 0.0, 18.0, false)
	_hit(hit, box, false)


func _tea_mini_chip(at: Vector2, fade: float, cut: Array, shaded: bool) -> void :
	if not TeaRoom.in_room():
		return
	var wide: float = 128.0
	var box: Rect2 = _lr(at, Vector2(wide, 25))
	if _covered(cut, box):
		return
	var v: Object = _tea_voice()
	var talk: bool = v != null and v.tea_mic_state() == "talk"
	_round(box, Color("163a2a", 0.92 * fade), 12.0, Color(TALK_RING if talk else Color("63e08a"), 0.85 * fade), 1.0)
	draw_circle(Vector2(at.x + 12.0, at.y + 12.5) * _f, 4.0 * _f, Color(TALK_RING, fade), true, -1.0, true)
	_fwords(_clip("Phòng Trà #%d" % TeaRoom.room_id(), BOLD, 11.0, wide - 26.0), BOLD, 11.0, Color(1, 1, 1, fade), "l", at + Vector2(22, 0), wide - 26.0, 1.0, 25.0)
	if not shaded:
		_hit("m:view:tea", box, false)
		_add(box)

func _tea_glyph(kind: String, c: Vector2, s: float, color: Color) -> void :
	var w: float = maxf(1.5, s * 0.22)
	match kind:
		"tea":
			draw_rect(Rect2(c + Vector2( - s * 0.75, - s * 0.2), Vector2(s * 1.2, s * 0.85)), color)
			draw_arc(c + Vector2(s * 0.5, s * 0.15), s * 0.3, - PI / 2.0, PI / 2.0, 10, color, w, true)
			draw_line(c + Vector2( - s * 0.9, s * 0.8), c + Vector2(s * 0.6, s * 0.8), color, w, true)
			for k in range(3):
				var x: float = c.x - s * 0.45 + k * s * 0.3
				draw_line(Vector2(x, c.y - s * 0.4), Vector2(x + s * 0.1, c.y - s * 0.85), Color(color, 0.8), w * 0.7, true)
		"crown":
			_poly(PackedVector2Array([c + Vector2( - s, s * 0.5), c + Vector2( - s, - s * 0.4), c + Vector2( - s * 0.5, s * 0.05), c + Vector2(0, - s * 0.7), 
				c + Vector2(s * 0.5, s * 0.05), c + Vector2(s, - s * 0.4), c + Vector2(s, s * 0.5)]), color)
		"lock":
			_lock(c, s * 2.0 / _u, color)
		"down", "up":
			var d: float = 1.0 if kind == "down" else -1.0
			draw_line(c + Vector2(0, - s * 0.7 * d), c + Vector2(0, s * 0.7 * d), color, w, true)
			draw_polyline(PackedVector2Array([c + Vector2( - s * 0.5, s * 0.2 * d), c + Vector2(0, s * 0.7 * d), c + Vector2(s * 0.5, s * 0.2 * d)]), color, w, true)
		"person":
			draw_circle(c + Vector2(0, - s * 0.45), s * 0.38, color, true, -1.0, true)
			draw_arc(c + Vector2(0, s * 0.75), s * 0.7, PI, TAU, 12, color, w * 1.3, true)
		"exit":
			draw_polyline(PackedVector2Array([c + Vector2( - s * 0.1, - s * 0.8), c + Vector2( - s * 0.8, - s * 0.8), c + Vector2( - s * 0.8, s * 0.8), c + Vector2( - s * 0.1, s * 0.8)]), color, w, true)
			draw_line(c + Vector2( - s * 0.3, 0), c + Vector2(s * 0.85, 0), color, w, true)
			draw_polyline(PackedVector2Array([c + Vector2(s * 0.45, - s * 0.4), c + Vector2(s * 0.85, 0), c + Vector2(s * 0.45, s * 0.4)]), color, w, true)
		"dots":
			for k in range(3):
				draw_circle(c + Vector2((k - 1) * s * 0.7, 0), s * 0.18, color, true, -1.0, true)
		"back", "next":
			var d: float = 1.0 if kind == "back" else -1.0
			draw_polyline(PackedVector2Array([c + Vector2(s * 0.35 * d, - s * 0.7), c + Vector2( - s * 0.35 * d, 0), c + Vector2(s * 0.35 * d, s * 0.7)]), color, w * 1.2, true)
		"invite":
			draw_circle(c + Vector2( - s * 0.25, - s * 0.4), s * 0.35, color, true, -1.0, true)
			draw_arc(c + Vector2( - s * 0.25, s * 0.75), s * 0.65, PI, TAU, 12, color, w * 1.2, true)
			draw_line(c + Vector2(s * 0.55, - s * 0.2), c + Vector2(s * 1.05, - s * 0.2), color, w, true)
			draw_line(c + Vector2(s * 0.8, - s * 0.45), c + Vector2(s * 0.8, s * 0.05), color, w, true)
		"refresh":
			draw_arc(c, s * 0.7, - PI * 0.1, PI * 1.5, 18, color, w, true)
			_poly(PackedVector2Array([c + Vector2(s * 0.7, - s * 0.55), c + Vector2(s * 1.0, s * 0.05), c + Vector2(s * 0.35, s * 0.0)]), color)
		"search":
			draw_arc(c + Vector2( - s * 0.15, - s * 0.15), s * 0.55, 0, TAU, 16, color, w, true)
			draw_line(c + Vector2(s * 0.25, s * 0.25), c + Vector2(s * 0.8, s * 0.8), color, w * 1.2, true)
		"dice":
			_round(Rect2(c - Vector2(s, s) * 0.85, Vector2(s, s) * 1.7), Color(color, 0.0), s * 0.5 / _u, color, maxf(1.0, w / _u))
			for p: Vector2 in [Vector2(-0.4, -0.4), Vector2(0, 0), Vector2(0.4, 0.4)]:
				draw_circle(c + p * s, s * 0.14, color, true, -1.0, true)
		"plus":
			draw_line(c + Vector2( - s * 0.7, 0), c + Vector2(s * 0.7, 0), color, w * 1.2, true)
			draw_line(c + Vector2(0, - s * 0.7), c + Vector2(0, s * 0.7), color, w * 1.2, true)




func _lx_tick() -> void :
	RedEnvelope.tick(client)
	if _tray_tab == "lx" and not RedEnvelope.shown():
		_tray = false
		_tray_tab = _tray_back
	_lx_thank_tick()
	for note: Dictionary in RedEnvelope.take():
		match str(note.get("kind", "")):
			"say":
				say(str(note.get("text", "")))
			"sent":
				say("Đã phát bao lì xì!")
				_tray = false
				_lx_sure = ""
				if not _lx_wish.is_empty() and _input.text.strip_edges() == _lx_wish:
					_input.text = ""
				_lx_wish = ""
			"opened":
				if int(_lx_pop.get("id", 0)) == int(note.get("id", 0)):
					var data: Dictionary = note.get("data", {})
					_lx_pop = {} if data.is_empty() else {"id": int(note.id), "data": data}
				_lx_thank(note.get("data", {}))


func _lx_thank(data: Dictionary) -> void :
	var amount: int = int(data.get("amount", 0))
	if amount <= 0 or data.get("already", false) or data.get("own", false) or data.get("empty", false):
		return
	var info: Dictionary = data.get("info", {})
	if int(info.get("fromId", 0)) == client.account_oid:
		return
	var from: String = str(info.get("from", "")).strip_edges()
	var text: String = "Cảm ơn %s đã lì xì! Nhận được %s %s" % [from if not from.is_empty() else "bạn", RedEnvelope.group(amount), 
		RedEnvelope.money_name(str(data.get("money", info.get("money", "cash"))))]
	_lx_thanks = {"text": text, "ch": 1024 if str(info.get("ch", "")) == "guild" else 2, "until": _time + LX_THANK_WAIT}


func _lx_thank_tick() -> void :
	if _lx_thanks.is_empty():
		return
	if _time > float(_lx_thanks.until):
		_lx_thanks = {}
		return
	var ch: int = int(_lx_thanks.ch)
	if client.chat_wait(ch) > 0.0:
		return
	client.send_chat(str(_lx_thanks.text), ch)
	_lx_thanks = {}


func _lx_take_wish() -> String:
	_lx_wish = _input.text.strip_edges()
	return _lx_wish


func _lx_act(what: String) -> void :
	if what.begins_with("page:"):
		_lx_page = what.substr(5)
		_lx_sure = ""
		return
	if what.begins_with("list:"):
		_lx_list = maxi(0, _lx_list + int(what.substr(5)))
		return
	if what.begins_with("money:"):
		_lx_money = "silver" if what.substr(6) == "silver" else "cash"
		_lx_sure = ""
		return
	if what.begins_with("amt:"):
		_lx_amount = int(what.substr(4))
		_lx_sure = ""
		return
	if what.begins_with("parts:"):
		_lx_parts = int(what.substr(6))
		_lx_sure = ""
		return
	if what.begins_with("gift:"):
		var bits: PackedStringArray = what.substr(5).split(":")
		if bits.size() == 2:
			if bits[1] == "guild" and RedEnvelope.guild().is_empty():
				say("Vào guild rồi mới phát được bao này.")
				return
			RedEnvelope.send_grant(client, int(bits[0]), bits[1], _lx_take_wish())
		return
	if what.begins_with("own:"):
		var ch: String = what.substr(4)
		var amount: int = _lx_amount_now()
		var refused: String = RedEnvelope.own_refusal(_lx_money, _lx_pay, amount, _lx_parts)
		if ch == "guild" and RedEnvelope.guild().is_empty():
			refused = "Bạn chưa vào guild."
		if not refused.is_empty():
			say(refused)
			return
		if _lx_sure != what or _time - _lx_sure_at > LX_SURE:
			_lx_sure = what
			_lx_sure_at = _time
			say("Bấm lần nữa để phát — trừ %s %s." % [RedEnvelope.group(amount), RedEnvelope.money_name(_lx_pay)])
			return
		_lx_sure = ""
		RedEnvelope.send_own(client, _lx_money, _lx_pay, amount, _lx_parts, ch, _lx_take_wish())
		return
	if what.begins_with("env:") or what.begins_with("card:"):
		_lx_open(int(what.get_slice(":", 1)))
		return
	if what in ["veil", "close"]:
		_lx_pop = {}


func _lx_open(id: int) -> void :
	if id <= 0:
		return
	if RedEnvelope.gate == -1:
		say("Lì xì đang tạm đóng.")
		return
	_tray = false
	_lx_pop = {"id": id, "wait": true}
	RedEnvelope.open_env(client, id)


func _lx_amounts() -> Array:
	var span: Array = RedEnvelope.own().get("cashgold", {}).get("range", [10, 200])
	var out: Array = [20, 50, 100, 200].filter( func(n: int) -> bool: return n >= int(span[0]) and n <= int(span[1]))
	return out if not out.is_empty() else [int(span[0])]

func _lx_amount_now() -> int:
	var list: Array = _lx_amounts()
	return _lx_amount if list.has(_lx_amount) else int(list[0])


func _lx_chip(id: String, text: String, at: Vector2, wide: float, on: bool, live: bool = true) -> void :
	var cell: Rect2 = _lr(at, Vector2(wide, 22))
	_round(cell, Color(LX_RED, 0.9) if on else (Color("163a5f") if _hover == id and live else Color("10253f")), 11.0, 
		LX_GOLD if on else Color(EDGE, 0.9 if live else 0.35), 1.0)
	_fwords(text, BOLD, 11.0, Color(1, 1, 1, 1.0 if live else 0.4), "c", at, wide, 0.0, 22.0)
	if live and not on:
		_hit(id, cell, false)


func _lx_icon(rect: Rect2) -> void :
	var box: Rect2 = _lr(rect.position, rect.size)
	_round(box, LX_RED, 3.0, Color(LX_GOLD, 0.8), 1.0)
	var flap: PackedVector2Array = PackedVector2Array([box.position, Vector2(box.end.x, box.position.y), Vector2(box.get_center().x, box.position.y + box.size.y * 0.42)])
	_poly(flap, Color("a81e1e"))
	draw_circle(Vector2(box.get_center().x, box.position.y + box.size.y * 0.42), box.size.x * 0.2, LX_GOLD, true, -1.0, true)


func _tray_lixi(body: Rect2, foot: Rect2) -> void :
	if not RedEnvelope.usable():
		var why: String = "Đang tải lì xì…"
		if RedEnvelope.bag.get("ingame") == false:
			why = "Vào game rồi mới dùng được lì xì."
		elif not RedEnvelope.bag.is_empty():
			why = "Cần cấp %d trở lên để dùng lì xì." % int(RedEnvelope.bag.get("minLevel", 0))
		_fwords(why, BOLD, 13.0, DIM, "c", body.position, body.size.x, 0.0, body.size.y)
		return
	var me: int = client.account_oid
	var x: float = body.position.x + 10.0
	for page: Array in LX_PAGES:
		var key: String = str(page[0])
		var id: String = "m:lx:page:" + key
		var on: bool = _lx_page == key
		var n: int = 0
		if key == "gift":
			n = RedEnvelope.grants().size()
		elif key == "open":
			n = RedEnvelope.open_list().filter( func(e: Variant) -> bool: return e is Dictionary and RedEnvelope.can_open(e, me)).size()
		_lx_chip(id, str(page[1]) + (" (%d)" % n if n > 0 else ""), Vector2(x, body.position.y + 6.0), 96.0, on)
		x += 100.0
	var area: Rect2 = Rect2(body.position + Vector2(0, 34), Vector2(TRAY_W, body.size.y - 34.0))
	match _lx_page:
		"gift":
			_lx_gifts(area, foot)
		"own":
			_lx_own(area, foot)
		_:
			_lx_opens(area, foot, me)

func _lx_opens(area: Rect2, foot: Rect2, me: int) -> void :
	var rows: Array = RedEnvelope.open_list()
	var per: int = 4
	var pages: int = maxi(1, ceili(rows.size() / float(per)))
	_lx_list = clampi(_lx_list, 0, pages - 1)
	if rows.is_empty():
		_fwords("Chưa có bao lì xì nào đang mở.", SEMI, 12.0, DIM, "c", area.position, area.size.x, 0.0, area.size.y - 8.0)
	for i in range(per):
		var n: int = _lx_list * per + i
		if n >= rows.size():
			break
		var e: Dictionary = rows[n]
		var at: Vector2 = area.position + Vector2(8, 2.0 + 32.0 * i)
		_round(_lr(at, Vector2(TRAY_W - 16.0, 30)), Color(COL_BG, 0.85), 8.0, Color(EDGE, 0.4), 1.0)
		_lx_icon(Rect2(at + Vector2(6, 4), Vector2(18, 22)))
		var room: float = TRAY_W - 112.0
		var where: String = "Guild" if str(e.get("ch", "")) == "guild" else "Thế Giới"
		_fwords(_clip("%s · %s" % [str(e.get("from", "")), where], BOLD, 11.0, room), BOLD, 11.0, Color.WHITE, "l", at + Vector2(30, 1), room, 0.0, 15.0)
		var left: int = maxi(0, int(e.get("parts", 0)) - int(e.get("taken", 0)))
		_fwords("%s %s · còn %d/%d phần" % [RedEnvelope.short(int(e.get("total", 0))), RedEnvelope.money_name(str(e.get("money", ""))), left, int(e.get("parts", 0))], 
			REGULAR, 10.0, DIM, "l", at + Vector2(30, 15), room, 0.0, 14.0)
		var key: String = "m:lx:env:%d" % int(e.get("id", 0))
		var bx: Vector2 = Vector2(at.x + TRAY_W - 16.0 - 70.0, at.y + 4.0)
		if RedEnvelope.can_open(e, me):
			_tea_button(key, "Mở", bx, 64.0, 22.0, "orange")
		elif e.has("mine"):
			_tea_button(key, "+" + RedEnvelope.short(int(e.mine)), bx, 64.0, 22.0, "dark")
		else:
			_tea_button(key, "Xem", bx, 64.0, 22.0, "dark")
	_fwords("Bao Thế Giới hôm nay còn nhận: %d" % int(RedEnvelope.bag.get("serverLeft", 0)), REGULAR, 11.0, DIM, "l", foot.position + Vector2(10, 0), 
		TRAY_W - (110.0 if pages > 1 else 20.0), 0.0, foot.size.y)
	_tray_pager("m:lx:list:%d", _lx_list, pages, foot)

func _lx_gifts(area: Rect2, foot: Rect2) -> void :
	var rows: Array = RedEnvelope.grants()
	if rows.is_empty():
		_fpara("Chưa có bao được tặng. Nạp lần đầu trong ngày, lên mốc VIP hoặc VIP 5 trở lên mỗi ngày sẽ được bao để phát.", SEMI, 12.0, DIM, 
			area.position + Vector2(20, 30), TRAY_W - 40.0, 4)
	var no_guild: bool = RedEnvelope.guild().is_empty()
	for i in range(mini(rows.size(), 4)):
		var g: Dictionary = rows[i]
		var at: Vector2 = area.position + Vector2(8, 2.0 + 32.0 * i)
		_round(_lr(at, Vector2(TRAY_W - 16.0, 30)), Color(COL_BG, 0.85), 8.0, Color(LX_GOLD, 0.35), 1.0)
		_lx_icon(Rect2(at + Vector2(6, 4), Vector2(18, 22)))
		var chans: Array = g.get("ch", ["guild"])
		var room: float = TRAY_W - (166.0 if chans.has("server") else 126.0)
		_fwords(_clip(str(g.get("label", "")), BOLD, 11.0, room), BOLD, 11.0, LX_GOLD, "l", at + Vector2(30, 1), room, 0.0, 15.0)
		_fwords("%s %s · %d phần" % [RedEnvelope.group(int(g.get("total", 0))), RedEnvelope.money_name(str(g.get("money", "cash"))), int(g.get("parts", 0))], 
			REGULAR, 10.0, DIM, "l", at + Vector2(30, 15), room, 0.0, 14.0)
		var id: int = int(g.get("id", 0))
		var right: float = at.x + TRAY_W - 16.0 - 6.0
		if chans.has("server"):
			_tea_button("m:lx:gift:%d:server" % id, "Thế Giới", Vector2(right - 66.0, at.y + 4.0), 66.0, 22.0, "blue")
			_tea_button("m:lx:gift:%d:guild" % id, "Guild", Vector2(right - 120.0, at.y + 4.0), 50.0, 22.0, "dark" if no_guild else "orange")
		else:
			_tea_button("m:lx:gift:%d:guild" % id, "Phát Guild", Vector2(right - 86.0, at.y + 4.0), 86.0, 22.0, "dark" if no_guild else "orange")
	_fwords("Lời chúc = chữ trong ô chat (trống: %s)" % RedEnvelope.WISH, REGULAR, 10.0, DIM, "l", foot.position + Vector2(10, 0), TRAY_W - 20.0, 0.0, foot.size.y)

func _lx_own(area: Rect2, foot: Rect2) -> void :
	var o: Dictionary = RedEnvelope.own()
	var y: float = area.position.y + 2.0
	var lx: float = area.position.x + 10.0
	var cx: float = area.position.x + 56.0
	_fwords("Bao", SEMI, 11.0, DIM, "l", Vector2(lx, y), 44.0, 0.0, 22.0)
	_lx_chip("m:lx:money:cash", "Xu khóa", Vector2(cx, y), 76.0, _lx_money == "cash")
	_lx_chip("m:lx:money:silver", "Bạc", Vector2(cx + 80.0, y), 76.0, _lx_money == "silver")
	y += 26.0
	var cg: Dictionary = o.get("cashgold", {})
	var rate: String = "1 Xu = %s" % ("%d Xu khóa" % int(cg.get("toCash", 1)) if _lx_money == "cash" else "%s Bạc" % RedEnvelope.group(int(cg.get("toSilver", 1000))))
	_fwords("Trả", SEMI, 11.0, DIM, "l", Vector2(lx, y), 44.0, 0.0, 22.0)
	_fwords("Bằng Xu · " + rate, SEMI, 11.0, LX_GOLD, "l", Vector2(cx, y), TRAY_W - cx + area.position.x - 10.0, 0.0, 22.0)
	y += 26.0
	var amount: int = _lx_amount_now()
	var picks: Array = _lx_amounts()
	var step: float = minf(54.0, (TRAY_W - 66.0) / maxf(1.0, picks.size()))
	_fwords("Xu", SEMI, 11.0, DIM, "l", Vector2(lx, y), 44.0, 0.0, 22.0)
	for i in range(picks.size()):
		_lx_chip("m:lx:amt:%d" % int(picks[i]), RedEnvelope.short(int(picks[i])), Vector2(cx + step * i, y), step - 4.0, int(picks[i]) == amount)
	y += 26.0
	var pr: Array = o.get("parts", [5, 50])
	var part_picks: Array = [5, 10, 20, 30, 50].filter( func(n: int) -> bool: return n >= int(pr[0]) and n <= int(pr[1]))
	if not part_picks.has(_lx_parts) and not part_picks.is_empty():
		_lx_parts = int(part_picks[mini(1, part_picks.size() - 1)])
	_fwords("Phần", SEMI, 11.0, DIM, "l", Vector2(lx, y), 44.0, 0.0, 22.0)
	for i in range(part_picks.size()):
		_lx_chip("m:lx:parts:%d" % int(part_picks[i]), str(part_picks[i]), Vector2(cx + 46.0 * i, y), 42.0, int(part_picks[i]) == _lx_parts)
	y += 26.0
	var refused: String = RedEnvelope.own_refusal(_lx_money, _lx_pay, amount, _lx_parts)
	if refused.is_empty():
		var total: int = RedEnvelope.own_total(_lx_money, _lx_pay, amount)
		_fwords("Chia %s %s cho %d người · bạn trả %s %s" % [RedEnvelope.group(total), RedEnvelope.money_name(_lx_money), _lx_parts, RedEnvelope.group(amount), 
			RedEnvelope.money_name(_lx_pay)], SEMI, 11.0, Color("eef5ff"), "c", Vector2(area.position.x + 6.0, y), TRAY_W - 12.0, 0.0, 18.0)
	else:
		_fwords(refused, SEMI, 11.0, Color("ff8a8a"), "c", Vector2(area.position.x + 6.0, y), TRAY_W - 12.0, 0.0, 18.0)
	y += 20.0
	var no_guild: bool = RedEnvelope.guild().is_empty()
	var sure_g: bool = _lx_sure == "own:guild" and _time - _lx_sure_at <= LX_SURE
	var sure_s: bool = _lx_sure == "own:server" and _time - _lx_sure_at <= LX_SURE
	var mid: float = area.position.x + TRAY_W / 2.0
	_tea_button("m:lx:own:guild", "Bấm lần nữa" if sure_g else "Phát Guild", Vector2(mid - 134.0, y), 128.0, 26.0, "dark" if no_guild else ("green" if sure_g else "orange"))
	_tea_button("m:lx:own:server", "Bấm lần nữa" if sure_s else "Phát Thế Giới", Vector2(mid + 6.0, y), 128.0, 26.0, "green" if sure_s else "blue")
	_fwords("Hôm nay còn tự phát %d bao · Xu còn %d" % [int(o.get("sendsLeft", 0)), int(o.get("xuLeft", 0))], REGULAR, 10.0, DIM, "l", 
		foot.position + Vector2(10, 0), TRAY_W - 20.0, 0.0, foot.size.y)


func _draw_lx_card(item: Dictionary, rect: Rect2, _own: bool) -> void :
	var line: Dictionary = item["line"]
	var rp: Dictionary = item["rp"]
	var hit: String = "m:lx:card:%d" % int(rp.get("id", 0))
	var box: Rect2 = _lr(rect.position, rect.size)
	VoiceUI.grad(self, box, 12.0 * _f, LX_RED.lightened(0.12 if _hover == hit else 0.04), Color("a81e1e"), Color(LX_GOLD, 0.85), 1.2 * _f)
	_lx_icon(Rect2(rect.position + Vector2(10, 10), Vector2(34, 44)))
	var room: float = rect.size.x - 62.0
	var wish: String = str(line.get("text", "")).trim_prefix(": ").trim_prefix(RedEnvelope.HEAD)
	_fwords(_clip(wish, BOLD, 13.0, room), BOLD, 13.0, Color("fff3c4"), "l", rect.position + Vector2(54, 9), room, 0.0, 20.0)
	_fwords("Lì xì %s · bấm để mở" % RedEnvelope.money_name(str(rp.get("money", "cash"))), SEMI, 11.0, LX_GOLD, "l", rect.position + Vector2(54, 33), room, 0.0, 18.0)
	_hit(hit, box, false)


func _draw_lx_pop() -> Rect2:
	var whole: Rect2 = Rect2(Vector2.ZERO, size)
	draw_rect(whole, Color(0, 0, 0, 0.45))
	_hit("m:lx:veil", whole, false)
	if _input.visible and not _open:
		_input.visible = false
		_input.release_focus()
	var wide: float = 300.0
	var high: float = 330.0
	var at: Vector2 = Vector2(roundf((size.x / _f - wide) / 2.0), roundf((size.y / _f - high) / 2.0))
	var box: Rect2 = _lr(at, Vector2(wide, high))
	_round(box.grow(3.0 * _f), Color(0, 0, 0, 0.35), 18.0)
	VoiceUI.grad(self, box, 16.0 * _f, Color("e8463a"), Color("a81e1e"), Color(LX_GOLD, 0.85), 1.5 * _f)
	_hit("m:lx:box", box, false)
	draw_arc(Vector2(box.get_center().x, box.position.y - 40.0 * _f), 150.0 * _f, PI * 0.18, PI * 0.82, 32, Color("a81e1e"), 3.0 * _f, true)
	var seal: Vector2 = Vector2(box.get_center().x, box.position.y + 104.0 * _f)
	draw_circle(seal, 28.0 * _f, LX_GOLD, true, -1.0, true)
	draw_circle(seal, 22.0 * _f, Color("c8902a"), false, maxf(1.0, 1.5 * _f), true)
	_fwords("Lộc", BOLD, 16.0, Color("a81e1e"), "c", at + Vector2(0, 92), wide, 0.0, 24.0, false)
	var shut: Rect2 = _lr(at + Vector2(wide - 32.0, 8.0), Vector2(24, 24))
	_round(shut, Color(0, 0, 0, 0.25), 12.0, Color(LX_GOLD, 0.7), 1.0)
	var c: Vector2 = shut.get_center()
	var arm: float = 5.0 * _f
	draw_line(c - Vector2(arm, arm), c + Vector2(arm, arm), Color.WHITE, maxf(1.5, 1.6 * _f), true)
	draw_line(c + Vector2( - arm, arm), c + Vector2(arm, - arm), Color.WHITE, maxf(1.5, 1.6 * _f), true)
	_hit("m:lx:close", shut, false)
	if _lx_pop.get("wait") == true:
		_fwords("Đang mở bao…", BOLD, 15.0, Color("fff3c4"), "c", at + Vector2(0, 160), wide, 0.0, 30.0)
		return whole
	var data: Dictionary = _lx_pop.get("data", {})
	var info: Dictionary = data.get("info", {}) if data.get("info") is Dictionary else {}
	var money: String = RedEnvelope.money_name(str(data.get("money", info.get("money", "cash"))))
	_fwords(_clip("Lì xì của " + str(info.get("from", "")), BOLD, 14.0, wide - 80.0), BOLD, 14.0, LX_GOLD, "c", at + Vector2(40, 12), wide - 80.0, 0.0, 22.0)
	_fwords(_clip(str(info.get("wish", "")), SEMI, 12.0, wide - 40.0), SEMI, 12.0, Color("fff3c4"), "c", at + Vector2(20, 38), wide - 40.0, 0.0, 20.0)
	var big: String
	if data.get("own") == true:
		big = "Bao của bạn"
	elif data.get("empty") == true:
		big = "Bao đã được nhận hết"
	elif data.get("already") == true:
		big = "Bạn đã nhận %s %s" % [RedEnvelope.group(int(data.get("amount", 0))), money]
	else:
		big = "+%s %s" % [RedEnvelope.group(int(data.get("amount", 0))), money]
	var px: float = 22.0 if big.begins_with("+") else 16.0
	_fwords(big, BOLD, px, LX_GOLD, "c", at + Vector2(10, 142), wide - 20.0, 1.0, 32.0)
	_fwords("Đã nhận %d/%d phần · tổng %s %s" % [int(info.get("taken", 0)), int(info.get("parts", 0)), RedEnvelope.group(int(info.get("total", 0))), money], 
		REGULAR, 11.0, Color("ffd6c8"), "c", at + Vector2(10, 176), wide - 20.0, 0.0, 18.0)
	var list: Array = info.get("list", []) if info.get("list") is Array else []
	list.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("amount", 0)) > int(b.get("amount", 0)))
	var best: int = int(info.get("best", 0))
	var y: float = at.y + 200.0
	_round(_lr(Vector2(at.x + 14.0, y), Vector2(wide - 28.0, 118)), Color(0, 0, 0, 0.22), 10.0)
	var rows_n: int = list.size() if list.size() <= 5 else 4
	for i in range(rows_n):
		var r: Dictionary = list[i]
		var ry: float = y + 4.0 + 22.0 * i
		var me: bool = int(r.get("id", 0)) == client.account_oid
		var lucky: bool = best > 0 and int(r.get("id", 0)) == best
		var name_room: float = wide - 140.0 - (64.0 if lucky else 0.0)
		_fwords(_clip(str(r.get("name", "")), SEMI, 12.0, name_room), SEMI, 12.0, LX_GOLD if me else Color.WHITE, "l", Vector2(at.x + 24.0, ry), name_room, 0.0, 20.0)
		if lucky:
			var tag: Rect2 = _lr(Vector2(at.x + 24.0 + name_room + 4.0, ry + 2.0), Vector2(60, 16))
			_round(tag, LX_GOLD, 8.0)
			_fwords("May mắn nhất", BOLD, 9.0, Color("a81e1e"), "c", Vector2(at.x + 24.0 + name_room + 4.0, ry + 2.0), 60.0, 0.0, 16.0)
		_fwords("%s %s" % [RedEnvelope.group(int(r.get("amount", 0))), money], BOLD, 12.0, Color("fff3c4"), "r", Vector2(at.x + wide - 124.0, ry), 100.0, 0.0, 20.0)
	if list.is_empty():
		_fwords("Chưa ai nhận", REGULAR, 12.0, Color("ffd6c8"), "c", Vector2(at.x + 14.0, y), wide - 28.0, 0.0, 118.0)
	elif list.size() > 5:
		_fwords("… và %d người khác" % (list.size() - rows_n), REGULAR, 11.0, Color("ffd6c8"), "c", Vector2(at.x + 14.0, y + 4.0 + 22.0 * rows_n), wide - 28.0, 0.0, 20.0)
	return whole


func _poly(points: PackedVector2Array, color: Color, uvs: PackedVector2Array = PackedVector2Array(), texture: Texture2D = null) -> void :
	if PolyOk.ok(points):
		draw_colored_polygon(points, color, uvs, texture)
