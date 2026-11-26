extends "flash_screen.gd"





































const Atlas = preload("chatf_atlas.gd")
const ChatCTip = preload("ctool_tip.gd")
const Love = preload("love.gd")
const Friends = preload("friends.gd")
const FriendsAtlas = preload("friends_atlas.gd")
const MasterModel = preload("master_model.gd")
const Hall = preload("hall_atlas.gd")
const Horn = preload("chorn_atlas.gd")
const Bugle = preload("chat_bugle.gd")
const Emotes = preload("chat_emotes.gd")
const ChatFriend = preload("chat_friend_list.gd")
const ChatFriendAtlas = preload("chat_friend_atlas.gd")
const Leader = preload("leaderboard_atlas.gd")
const NameStyles = preload("name_styles.gd")

const EMO_W: float = 286.0
const EMO_CELL: float = 36.0
const EMO_COLS: int = 7
const EMO_GRID_X: float = 17.0
const EMO_ICON: float = 28.0
const EMO_PAGE: int = 21
const EMO_SIDE: float = 24.0
const DRAFT_ICON: float = 22.0

const BAR: Array = [["chatf_head", 6.0, -3.0, 0.0], ["chatf_mid", 116.0, -3.0, 313.0], ["chatf_tail", 429.0, -3.0, 0.0], 
	["chatf_ipt_head", 116.0, 4.0, 0.0], ["chatf_ipt_mid", 134.0, 4.0, 221.0], ["chatf_ipt_tail", 355.0, 4.0, 0.0]]


const CHANNELS: Dictionary = {4: ["Team", Color("fca238")], 128: ["Loa", Color("0ee7ea")], 256: ["Loa Lớn", Color("ffcc00")], 2048: ["Liên Server", Color("ffcc00")]}


const HORNS: Dictionary = {128: ["Loa Nhỏ", "Không đủ loa nhỏ."], 256: ["Loa Lớn", "Không đủ loa lớn."], 2048: ["Loa Liên Server", "Không đủ Loa Liên Server."]}

const HORN_ITEMS: Dictionary = {128: 2100001, 256: 2100002}
const HORN_LIMIT: int = 30
const HORN_SIZE: Vector2 = Vector2(500, 150)
const LIMIT: int = 60
const TABS: Array = [["all", "Tổng"], ["room", "Room"], ["camp", "Team"], ["guild", "Guild"], ["whisper", "Chat riêng"]]

const SEND_ON: Dictionary = {"all": 2, "room": 8, "camp": 16, "guild": 1024, "whisper": 1}

const NAMES: Dictionary = {"all": "Thế Giới", "room": "Room", "camp": "Phe ta", "guild": "Guild", "whisper": "Chat riêng"}

const PHRASES: Array = ["Tuyển người đi đấu So Tài đây !!!", "Tuyển người đi đấu Xếp Hạng đây !!!", "Tuyển người vào Guild đây !!!", 
	"Tuyển người vào đi Phụ Bản đây !!!", "Cần thêm bạn đi PvP chung đây !!!", "Cần vào Guild đây !!!", "Cần đi đấu So Tài đây !!!", 
	"Cần đi đấu Xếp Hạng đây !!!", "Kéo mình phụ bản với"]

const FRAMES: Array = ["chatf_bk", "chatf_bk10", "chatf_bk15"]
const EXTRA: Array = [0, 116, 236]
const ROWS: Array = [5, 10, 15]

const SIDE: Array = [["height", "chatf_height", 34], ["clear", "chatf_clear", 53], ["up", "chatf_up", 77], ["down", "chatf_down", 101], ["bottom", "chatf_end", 125]]

const MENU: Array = [["chan:bugle", "/M TG", Color("ffcc00")], ["chan:world", "/L Kênh", Color("0ee7ea")], ["chan:whisper", "    Mật", Color("f78fec")], 
	["chan:team", "/T Team", Color("fc9c38")], ["chan:guild", "/C  Guild", Color("62b5ff")], ["chan:camp", "/J  Bên mình", Color("49ff5e")], 
	["chan:all", "/W  Tổng", Color("e8e8e8")], ["chan:now", "/D Thường", Color("e8e8e8")]]

const TIPS: Dictionary = {"height": "Chỉnh độ cao", "clear": "Xóa", "up": "Lên", "down": "Xuống", "bottom": "Cuối", "channel": "Nhấp đổi kênh.", 
	"send": "Gửi", "friends": "Chat", "quick": "Trả lời nhanh", "emote": "Chọn biểu cảm"}
const WRAP: float = 390.0
const WHISPER: Color = Color("f78fec")
const DOUBLE_CLICK: float = 0.2

signal player_info_asked(uuid: String)
signal quick_buy_asked(tid: int)
signal whisper_pick_asked

var host: Control
var on_friends: bool = false
var _input: LineEdit
var _focus: bool = false
var _tab: String = "all"
var _seen: Dictionary = {}
var _quick: bool = false
var _frame: Rect2 = Rect2()
var _height: int = 0
var _menu: bool = false
var _cleared: int = 0
var _top: int = -1
var _rows: Array = []
var _rows_key: Array = []
var _shown_rows: int = 5
var _mouse: Vector2 = Vector2.ZERO
var _tip_id: String = ""
var _tip_at: float = 0.0
var _chat_ctip: ChatCTip = ChatCTip.new()
var _thumb: Rect2 = Rect2()
var _track: Rect2 = Rect2()
var _sliding: bool = false
var _slide_from: float = 0.0
var _slide_first: int = 0
var _lines_rect: Rect2 = Rect2()
var _drag_from: Vector2 = Vector2(-1, -1)
var _drag_sum: float = 0.0
var _drag_first: int = 0
var _c: Vector2 = Vector2.ZERO
var _chan: int = 0
var _horn: int = 0
var _horn_input: LineEdit

var page_over: bool = false


var _solo: bool = false
var _solo_hid: bool = false
var _bugle: Control
var _emotes: Node
var _picker: bool = false
var _emo_frames: bool = false
var _emo_pack: String = ""
var _emo_page: int = 0
var _tokens: Dictionary = {}
var _draft: Control
var _draft_r: Vector2 = Vector2.ZERO
var _draft_shown: Array = []
var _tips: Dictionary = {}
var _spans: Dictionary = {}
var _who: Dictionary = {}
var _who_at: Vector2 = Vector2.ZERO
var _who_rect: Rect2 = Rect2()
var _who_hide_at: float = -1.0
var _name_at: float = -10.0
var _name_seq: int = 0
var _name_pos: Vector2 = Vector2.ZERO
var _fl: bool = false
var _fl_list: Array = []
var _fl_top: int = 0
var _fl_rect: Rect2 = Rect2()
var _fl_rows: Rect2 = Rect2()
var _fl_track: Rect2 = Rect2()
var _fl_thumb: Rect2 = Rect2()
var _fl_sliding: bool = false
var _fl_slide_from: float = 0.0
var _fl_slide_first: int = 0
var _fl_drag_from: Vector2 = Vector2(-1, -1)
var _fl_drag_sum: float = 0.0
var _fl_drag_first: int = 0

func _setup() -> void :
	visible = false
	_use(Atlas.FILE, Atlas.R)
	_use(Hall.FILE, {"chat_image_warning": Hall.R["chat_image_warning"]})
	_use(Horn.FILE, Horn.R)
	_use(FriendsAtlas.FILE, {"fr_cutline": FriendsAtlas.R["fr_cutline"], "fr_watch": FriendsAtlas.R["fr_watch"]})
	_use(ChatFriendAtlas.FILE, ChatFriendAtlas.R)
	var cells: Dictionary = {}
	for level in range(41):
		cells["level_%d" % level] = Hall.R["level_%d" % level]
	_use(Hall.FILE, cells)
	cells = {}
	for level in range(1, 16):
		for key: String in ["lb_v%d" % level, "lb_sv%d" % level]:
			if Leader.R.has(key):
				cells[key] = Leader.R[key]
	_use(Leader.FILE, cells)
	_horn_input = _fedit(HORN_LIMIT)
	_horn_input.add_theme_font_override("font", ARIAL_BOLD)
	_horn_input.text_submitted.connect( func(_value: String) -> void : _horn_confirm())
	_horn_input.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			_horn_close()
			_horn_input.accept_event())
	_bugle = Bugle.new()
	_bugle.client = client
	_bugle.pack = pack
	_bugle.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_sibling.call_deferred(_bugle)
	_emotes = Emotes.new()
	_emotes.client = client
	add_child(_emotes)
	_input = _fedit(LIMIT)
	_input.add_theme_font_override("font", ARIAL)
	_input.add_theme_color_override("font_placeholder_color", Color(1, 1, 1, 0.55))
	_input.keep_editing_on_text_submit = true
	_input.text_submitted.connect( func(_value: String) -> void : _submit())
	_input.gui_input.connect( func(event: InputEvent) -> void :
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			if _picker:
				_picker = false
			elif _fl:
				_fl_close()
			elif docked():
				_input.release_focus()
			else:
				close()
			_input.accept_event())
	_draft = Control.new()
	_draft.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_draft.focus_mode = Control.FOCUS_NONE
	_draft.clip_contents = true
	_draft.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_draft.draw.connect(_draw_draft)
	_input.add_child(_draft)

func _notification(what: int) -> void :
	if what == NOTIFICATION_PREDELETE and is_instance_valid(_bugle):
		_bugle.queue_free()


func docked() -> bool:
	return host != null and host.get("chat_embedded") == true

func is_open() -> bool:
	return visible and not _solo


func sync() -> void :
	if docked():
		visible = host.visible and client.state == "room"
		if not visible:
			_release()


func open() -> void :
	if host == null or client == null or client.state not in ["lobby", "hall", "room"]:
		return
	if not visible and not docked():
		var chosen: Variant = host.get("_chat_tab")
		if chosen is String and NAMES.has(chosen) and _viewable(chosen):
			_switch(chosen)
	_show()

func _show() -> void :
	if host == null or client == null or client.state not in ["lobby", "hall", "room"]:
		return
	if not visible:
		_top = -1
		_menu = false
	_solo = false
	_solo_hid = false
	_focus = true
	visible = true
	_emotes.refresh()

func open_with(text: String) -> void :
	open()
	if visible:
		_input.text = text
		_input.caret_column = text.length()


func open_whisper(who: String) -> void :
	if who.strip_edges().is_empty():
		return
	client.whisper_to = {"name": who.strip_edges(), "oid": 0}
	_switch("whisper")
	_show()

func close() -> void :
	if visible and host != null and not docked() and host.get("_chat_tab") is String:
		host.set("_chat_tab", _tab)
	_release()
	visible = false

func _release() -> void :
	_hide_edits()
	_horn = 0
	_solo = false
	_solo_hid = false
	_quick = false
	_menu = false
	_picker = false
	_sliding = false
	_frame = Rect2()
	_hide_who()
	_fl_close()

func _has_point(point: Vector2) -> bool:
	return _frame.has_point(point) if docked() and _horn == 0 else true




static func styled(line: Dictionary) -> Dictionary:
	var style: Array = CHANNELS.get(int(line.get("channel", 0)), [])
	if style.is_empty():
		return line
	var out: Dictionary = line.duplicate()
	out["head"] = "[%s]" % style[0]
	out["head_color"] = style[1]
	out["color"] = style[1]
	return out


static func latest(log: Array) -> Array:
	if log.is_empty():
		return []
	var line: Dictionary = styled(log[log.size() - 1])
	return [str(line.get("head", "")) + str(line.get("name", "")), str(line.get("text", "")), line.get("name_color", Color.WHITE), line.get("color", Color.WHITE)]


static func preview(screen: Control, log: Array, at: Vector2, width: float, hint: String) -> void :
	var last: Array = latest(log)
	if last.is_empty():
		screen._string(hint, REGULAR, 28, Color(MUTED, 0.75), "l", at, width)
		return
	var head: String = str(last[0])
	var used: float = screen._string(head, SEMI, 28, last[2], "l", at, width) if not head.is_empty() else 0.0
	used = minf(used, width)
	if width - used > 40.0 * screen._u:
		screen._string(str(last[1]), REGULAR, 28, last[3], "l", at + Vector2(used, 0), width - used)


func tabs() -> Array:
	var out: Array = []
	for tab: Array in TABS:
		if client.state == "room" or str(tab[0]) not in ["room", "camp"]:
			out.append(tab)
	return out

func tab() -> String:
	return _tab

func _switch(id: String) -> void :
	if id != _tab:
		_tab = id
		_top = -1
		_cleared = 0
		_chan = 0
	_quick = false
	_seen[id] = client.chat_rev


func _viewable(id: String) -> bool:
	return id != "camp" or client.state == "room"


func unread(id: String) -> bool:
	if id == "all" or (id == _tab and visible):
		return false
	var seen: int = int(_seen.get(id, 0))
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		if int(line.get("seq", 0)) <= seen:
			return false
		if str(line.get("tab", "")) == id:
			return true
	return false

func _shows(line: Dictionary) -> bool:
	var where: String = str(line.get("tab", "all"))
	return _tab == "all" or where.is_empty() or where == _tab

func _visible_line(line: Dictionary) -> bool:
	return _shows(line) and int(line.get("seq", 0)) > _cleared


func scope() -> String:
	var in_room: bool = client.state == "room"
	if _chan == 2 and in_room:
		return "Thế Giới: mọi người đang online đều thấy"
	match _tab:
		"room":
			return "Nói với cả phòng"
		"camp":
			return "Nói với đồng đội cùng phe"
		"guild":
			return "Nói trong bang hội"
		"whisper":
			var name: String = str(client.whisper_to.get("name", ""))
			return "Nhắn riêng với %s" % name if not name.is_empty() else "Nhắn riêng: /w tên nội dung"
	return "Nói với cả phòng" if in_room else "Sảnh: mọi người đang online đều thấy"




func _send(text: String) -> bool:
	if HORNS.has(_chan):
		if client.horn_count(_chan) <= 0:
			client.send_chat_channel(text, _chan)
			quick_buy_asked.emit(int(HORN_ITEMS[_chan]))
		else:
			open_horn(_chan, text)
		return false
	text = _emotes.expand(text, _tokens)
	var refused: String = _emotes.refusal(text)
	if not refused.is_empty():
		say(refused)
		return false
	if _chan == 2:
		return client.send_chat(text, 2, {}, true)
	if _chan == 4:
		return client.send_chat_channel(text, 4)
	return client.send_chat(text, int(SEND_ON.get(_tab, 2)))

func _submit() -> void :
	var text: String = _input.text.strip_edges()
	if text.is_empty():
		return
	if _send(text):
		_input.text = ""

func _tick(_delta: float) -> void :

	if host == null or not host.is_visible_in_tree() or client.state not in ["lobby", "hall", "room"]\
	or ( not docked() and not client.pair_scene.is_empty()):
		close()
		return
	if not _viewable(_tab):
		_switch("all")
	if not _who.is_empty():

		if _who_rect.has_point(get_local_mouse_position()):
			_who_hide_at = -1.0
		elif _who_hide_at < 0.0:
			_who_hide_at = _time + Friends.MENU_TIME
		if _who_hide_at >= 0.0 and _time >= _who_hide_at:
			_hide_who()
	var tip: String = _hover if TIPS.has(_hover) or _tips.has(_hover) else ""
	if tip != _tip_id:
		_tip_id = tip
		_tip_at = _time

func _unhandled_key_input(event: InputEvent) -> void :
	if not (event is InputEventKey and event.pressed and not event.echo) or client == null:
		return
	if docked():
		if visible and _frame.has_area() and event.keycode in [KEY_ENTER, KEY_KP_ENTER] and not host.chat_busy():
			_focus = true
			get_viewport().set_input_as_handled()
		return
	if visible:
		if event.keycode == KEY_ESCAPE:
			if _horn != 0:
				_horn_close()
			elif _picker:
				_picker = false
			elif _fl:
				_fl_close()
			else:
				close()
			get_viewport().set_input_as_handled()
		elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
			_focus = true
			get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER] and host != null and host.is_visible_in_tree() and not host.chat_busy():
		open()
		get_viewport().set_input_as_handled()

static func _plain(text: String) -> String:
	return text.replace("[", "[lb]")


func _markup() -> String:
	var out: PackedStringArray = PackedStringArray()
	for raw: Dictionary in client.chat_log:
		if not _visible_line(raw):
			continue
		var line: Dictionary = styled(raw)
		var head: String = str(line.get("head", ""))
		var who: String = str(line.get("name", ""))
		var row: String = ""
		if line.has("head_color") and not head.is_empty():
			row += "[color=#%s]%s[/color]" % [(line["head_color"] as Color).to_html(false), _plain(head)]
			head = ""
		if not head.is_empty() or not who.is_empty():
			row += "[color=#%s]%s%s[/color]" % [(line.get("name_color", Color.WHITE) as Color).to_html(false), _plain(head), _plain(who)]
		row += "[color=#%s]%s[/color]" % [(line.get("color", Color.WHITE) as Color).to_html(false), _plain(str(line.get("text", "")))]
		out.append(row)
	if out.is_empty():
		return "[color=#%s]Chưa có tin nhắn nào.\nGõ nội dung rồi nhấn Enter để gửi. Nhắn riêng: /w tên nội dung, trả lời nhanh: /r nội dung.[/color]" % MUTED.to_html(false)
	return "\n".join(out)




func _anchor() -> Array:
	if docked():
		var at: Vector2 = (host.chat_embed.position / _f).round()
		return [at, at + Vector2(0, 165), 7.0, 6.0]
	var homed: bool = host.get("_chat_tab") is String
	if homed and host.has_method("_at") and host.has_method("_frames"):
		var table: Variant = host.call("_frames")
		if table is Dictionary and (table as Dictionary).has("chat") and (table as Dictionary).has("input"):
			return [host.call("_at", "chat") - Vector2(0, 6), host.call("_at", "input"), 7.0, 6.0]
	if homed and host.has_method("_origin"):
		return [host.call("_origin", "chat"), host.call("_origin", "input"), 2.0, 0.0]
	var bottom: float = floorf(_fh + 0.01)
	var row: Vector2 = Vector2(0, bottom - 47.0)
	var dock: Rect2 = host.chat_dock
	if dock.has_area():
		row = (dock.position / _f + Vector2(-6, 3)).round()
	row.x = clampf(row.x, 0.0, maxf(0.0, floorf(_fw + 0.01) - 470.0))
	row.y = minf(row.y, bottom - 43.0)
	return [row - Vector2(0, 165), row, 2.0, 0.0]

func _paint() -> void :
	if host == null:
		return
	if _solo:
		_frame = Rect2()
		_tips.clear()
		if _input.visible:
			_input.visible = false
			_input.release_focus()
		if _horn != 0:
			_draw_horn()
			if not _mobile and not _horn_input.has_focus():
				_focus = true
			if _focus and _horn_input.visible:
				_focus = false
				_horn_input.grab_focus()
		_draw_tip()
		return
	var dock: bool = docked()
	if dock:
		if host.chat_busy() or not host.chat_embed.has_area():
			_release()
			return
	else:
		_hit("shade", Rect2(Vector2.ZERO, size), false)
	var spot: Array = _anchor()
	var c: Vector2 = spot[0]
	var r: Vector2 = spot[1]
	var h: int = 0 if dock else _height
	while h > 0 and c.y - float(EXTRA[h]) < 0.0:
		h -= 1
	_c = c
	var top: float = c.y - float(EXTRA[h])
	var tab_y: float = top + (float(spot[2]) if h == 0 else 6.0)
	_frame = Rect2(Vector2(c.x, top) * _f, Vector2(464, c.y + 163.0 - top) * _f).merge(Rect2((r + Vector2(0, -3)) * _f, Vector2(464, 43) * _f))
	_hit("panel", _frame, false)

	if h > 0 and host.has_method("_origin"):
		_fblit("chat_image_warning", Vector2(c.x, top - 64.0))
	_fblit(str(FRAMES[h]), Vector2(c.x, top))
	for i in range(TABS.size()):
		var key: String = str(TABS[i][0])
		var id: String = "tab:" + key
		var at: Vector2 = Vector2(c.x + 31.0 + 71.0 * i, tab_y)
		_hit(id, _fblit("chatf_tab_on" if _tab == key else "chatf_tab", at, 0.0, 0.0, _glow(id)), false)
		_fwords(str(TABS[i][1]), BOLD, 12.0, Color(1, 1, 1, 0.92 if _viewable(key) else 0.45), "c", at, 69.0, 1.0, 25.0)

	var fresh: int = _whispers()
	if fresh > 0:
		var tip: Vector2 = Vector2(c.x + 379.0, tab_y - (1.0 if h == 0 else 0.0)) + Vector2(3, 3)
		_fblit("chatf_tip", tip)
		_fwords(str(fresh) if fresh < 100 else "99+", BOLD, 11.0, Color.WHITE, "c", tip, 19.0, 0.0, 19.0)
	var rows: Array = _wrap()
	_shown_rows = int(ROWS[h])
	var first: int = _first(rows.size(), _shown_rows)
	var pitch: float = (c.y + 154.0 - top - 34.0) / float(_shown_rows)
	for i in range(first, mini(rows.size(), first + _shown_rows)):
		var y: float = top + 34.0 + pitch * (i - first)
		for seg: Array in rows[i]:
			if seg.size() > 4:
				_emote(str(seg[4]), Rect2(Vector2(c.x + 33.0 + float(seg[3]), y + (pitch - EMO_SIDE) / 2.0), Vector2(EMO_SIDE, EMO_SIDE)))
				continue
			if seg[2] is PackedColorArray:
				NameStyles.place(self, str(seg[0]), SEMI if seg[1] else REGULAR, 14.0, "l", Vector2(c.x + 33.0 + float(seg[3]), y), WRAP + 10.0 - float(seg[3]), 1.0, pitch, false, seg[2], true)
				continue
			_fwords(str(seg[0]), SEMI if seg[1] else REGULAR, 14.0, seg[2], "l", Vector2(c.x + 33.0 + float(seg[3]), y), WRAP + 10.0 - float(seg[3]), 1.0, pitch, false)
		for span: Array in _spans.get(i, []):
			_hit("who:%d" % int(span[2]), Rect2(Vector2(c.x + 33.0 + float(span[0]), y) * _f, Vector2(float(span[1]) - float(span[0]), pitch) * _f), false)
	_lines_rect = Rect2(Vector2(c.x + 30.0, top + 34.0) * _f, Vector2(400.0, pitch * _shown_rows) * _f)
	_draw_bar(c.x + 428.0, top + 34.0, c.y + 154.0, rows.size(), _shown_rows, first)
	for side: Array in SIDE:
		_fbutton(str(side[0]), str(side[1]), Vector2(c.x + 10.0, c.y + float(spot[3]) + float(side[2])))
	_draw_input(r)

	if _fl:
		_frame = _frame.merge(_draw_friend_list(c))
	if _quick:
		_frame = _frame.merge(_draw_quick(c))
	if _menu:
		_frame = _frame.merge(_draw_menu(r))
	_tips.clear()
	if _picker:
		_frame = _frame.merge(_draw_picker(r))
	if not _who.is_empty():
		_frame = _frame.merge(_draw_who())
	if _horn != 0:
		_draw_horn()
	_seen[_tab] = client.chat_rev
	var edit: LineEdit = _horn_input if _horn != 0 else _input
	if not dock and not _mobile and not edit.has_focus():
		_focus = true
	if _focus and edit.visible:
		_focus = false
		edit.grab_focus()
	_draw_tip()



func _draw_input(r: Vector2) -> void :
	_fblit("chatf_head", r + Vector2(6, -3))
	_fblit("chatf_mid", r + Vector2(116, -3), 313.0)
	_fblit("chatf_tail", r + Vector2(429, -3))
	_fblit("chatf_ipt_head", r + Vector2(116, 4))
	_fblit("chatf_ipt_mid", r + Vector2(134, 4), 221.0)
	_fblit("chatf_ipt_tail", r + Vector2(355, 4))
	var label: String = "Room" if _tab == "all" and client.state == "room" else str(NAMES.get(_tab, "Thế Giới"))
	if CHANNELS.has(_chan):
		label = str(CHANNELS[_chan][0])
	if _chan == 2 and client.state == "room":
		label = "Thế Giới"
	_fwords(label, BOLD, 12.0, Color.WHITE, "c", r + Vector2(33, 10), 52.0, 1.0, 19.0)
	_hit("channel", Rect2((r + Vector2(13, 5)) * _f, Vector2(91, 27) * _f), false)
	_fblit("chatf_send", r + Vector2(320, 9), 0.0, 0.0, _glow("send"))
	_hit("send", Rect2((r + Vector2(316, 3)) * _f, Vector2(32, 28) * _f), false)
	for item: Array in [["friends", "chatf_friend", 355.0], ["quick", "chatf_quick", 388.0], ["emote", "chatf_emote", 421.0]]:
		var id: String = str(item[0])
		_hit(id, _fblit(str(item[1]), r + Vector2(float(item[2]), 3), 32.0, 28.0, _glow(id)), false)

	var who: String = str(client.whisper_to.get("name", ""))
	var shift: float = 0.0
	if _tab == "whisper" and not who.is_empty():
		shift = minf(_fwords("Nói với [%s]" % who, BOLD, 14.0, WHISPER, "l", r + Vector2(121, 7), 125.0, 0.0, 26.0, true) + 5.0, 125.0)
	var hint: String = "/w tên nội dung" if _tab == "whisper" and who.is_empty() else ""
	if HORNS.has(_chan):
		hint = "Còn %d %s" % [client.horn_count(_chan), HORNS[_chan][0]]
	if _input.placeholder_text != hint:
		_input.placeholder_text = hint
	_fput(_input, Rect2(r + Vector2(121.0 + shift, 7), Vector2(189.0 - shift, 26)), 12.0, "l", _horn == 0)
	_draft_r = r
	_draft.queue_redraw()




func draft_spans() -> Array:
	var text: String = _input.text
	var spans: Array = _emotes.find_codes(text)
	var start: int = text.find("[")
	while start >= 0:
		var close: int = text.find("]", start)
		if close < 0:
			break
		var token: String = str(_tokens.get(text.substr(start, close - start + 1), ""))
		if token.begins_with("[emote:") and token.ends_with("]"):
			spans.append([start, close + 1, token.substr(7, token.length() - 8)])
		start = text.find("[", close + 1)
	var out: Array = []
	for span: Array in spans:
		var key: String = str(span[2])
		if _emotes.usable(key.get_slice(":", 0), key.get_slice(":", 1)):
			out.append(span)
	return out




func draft_covers() -> Array:
	var out: Array = []
	if not _input.visible or _input.text.is_empty():
		return out
	var text: String = _input.text
	var font: Font = _input.get_theme_font("font")
	var px: int = _input.get_theme_font_size("font_size")
	var scroll: float = float(_input.call("get_scroll_offset")) if _input.has_method("get_scroll_offset") else 0.0
	var high: float = _input.size.y
	var side: float = minf(DRAFT_ICON * _f, high - 2.0 * _f)
	var picked: bool = _input.has_selection()
	var from: int = _input.get_selection_from_column() if picked else 0
	var to: int = _input.get_selection_to_column() if picked else 0
	for span: Array in draft_spans():
		var start: int = int(span[0])
		var end: int = int(span[1])
		if picked and from < end and to > start:
			continue
		var x: float = scroll + font.get_string_size(text.substr(0, start), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var run: float = scroll + font.get_string_size(text.substr(0, end), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x - x
		if x < -0.01 or x + run > _input.size.x + 0.01:
			continue
		var icon: Rect2 = Rect2(Vector2(x + maxf(0.0, (run - side) / 2.0), maxf(0.0, (high - side) / 2.0)), Vector2(side, side))
		out.append([Rect2(x, 0.0, run, high), icon, str(span[2])])
	return out



func _draw_draft() -> void :
	_draft_shown.clear()
	for cover: Array in draft_covers():
		var key: String = str(cover[2])
		var tex: Texture2D = _emotes.texture(key)
		if _emotes.state(key) == "bad":
			continue
		for piece: Array in BAR:
			_draft_bar(str(piece[0]), _draft_r + Vector2(float(piece[1]), float(piece[2])), float(piece[3]), cover[0])
		_draft_shown.append(key)
		if tex == null or tex.get_width() <= 0 or tex.get_height() <= 0:
			continue
		var box: Rect2 = cover[1]
		var scale: float = minf(box.size.x / tex.get_width(), box.size.y / tex.get_height())
		var shown: Vector2 = Vector2(tex.get_width(), tex.get_height()) * scale
		_draft.draw_texture_rect(tex, Rect2(box.position + (box.size - shown) / 2.0, shown), false)


func _draft_bar(name: String, at: Vector2, wide: float, area: Rect2) -> void :
	var cell: Array = _cells.get(name, [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var dest: Rect2 = Rect2(at * _f - _input.position, Vector2(wide if wide > 0.0 else float(region[2]), float(region[3])) * _f)
	var part: Rect2 = dest.intersection(area)
	if part.size.x <= 0.0 or part.size.y <= 0.0:
		return
	var scale: Vector2 = Vector2(float(region[2]) / dest.size.x, float(region[3]) / dest.size.y)
	var src: Rect2 = Rect2(Vector2(float(region[0]), float(region[1])) + (part.position - dest.position) * scale, part.size * scale)
	_draft.draw_texture_rect_region(cell[0], part, src)


func draft_shown() -> Array:
	return _draft_shown.duplicate()



func _wrap() -> Array:
	var key: Array = [client.chat_rev, client.chat_log.size(), _tab, _cleared, _f, _emotes.rev, NameStyles.rev]
	if key == _rows_key:
		return _rows
	_rows_key = key
	_rows = []
	_spans = {}
	var px: int = maxi(6, roundi(14.0 * _f))
	for raw: Dictionary in client.chat_log:
		if not _visible_line(raw):
			continue
		var line: Dictionary = styled(raw)
		var parts: Array = []
		var head: String = str(line.get("head", "")) + str(line.get("name", ""))
		var lead: String = str(line.get("head", ""))
		if line.has("head_color"):

			parts.append([str(line.get("head", "")), true, line["head_color"], true])
			head = str(line.get("name", ""))
			lead = ""
		var named: int = parts.size() if not head.is_empty() and not target(raw).is_empty() else -1
		if not head.is_empty():
			parts.append([head, true, _name_ink(line, head)])
		parts.append_array(_content(line))
		var row: Array = []
		var x: float = 0.0
		for index: int in range(parts.size()):
			var part: Array = parts[index]
			if part.size() > 4:

				if x > 0.0 and x + EMO_SIDE > WRAP:
					_rows.append(row)
					row = []
					x = 0.0
				row.append(["", false, part[2], x, part[4]])
				x += EMO_SIDE
				continue
			var rest: String = str(part[0])
			var whole: int = rest.length()
			var bold: bool = part[1]
			var font: Font = ARIAL_BOLD if bold else ARIAL
			while not rest.is_empty():
				var fit: int = _fit(rest, font, px, WRAP - x)
				if fit >= rest.length():
					if index == named and rest == str(part[0]):
						var x0: float = x + font.get_string_size(lead, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
						var x1: float = x + font.get_string_size(rest, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
						_spans[_rows.size()] = _spans.get(_rows.size(), []) + [[x0, x1, int(raw.get("seq", 0))]]
					row.append([rest, bold, _ink(part[2], whole - rest.length(), rest.length()), x])
					x += font.get_string_size(rest, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
					break
				var cut: int = rest.substr(0, fit + 1).rfind(" ") if fit > 0 else -1
				if cut <= 0:
					if x > 0.0:
						_rows.append(row)
						row = []
						x = 0.0
						rest = rest.lstrip(" ")
						continue
					cut = maxi(1, fit)
					row.append([rest.substr(0, cut), bold, _ink(part[2], whole - rest.length(), cut), x])
					rest = rest.substr(cut)
				else:
					row.append([rest.substr(0, cut), bold, _ink(part[2], whole - rest.length(), cut), x])
					rest = rest.substr(cut + 1).lstrip(" ")
				_rows.append(row)
				row = []
				x = 0.0
			if bold and not row.is_empty() and part.size() < 4:
				x += 3.0
		if not row.is_empty():
			_rows.append(row)
	return _rows



func _name_ink(line: Dictionary, block: String) -> Variant:
	var ink: PackedColorArray = NameStyles.chat_colors(client, line, block)
	return ink if not ink.is_empty() else line.get("name_color", Color.WHITE)


static func _ink(color: Variant, from: int, count: int) -> Variant:
	if color is PackedColorArray:
		return (color as PackedColorArray).slice(from, from + count)
	return color



func _content(line: Dictionary) -> Array:
	var color: Color = line.get("color", Color.WHITE)
	var raw: String = str(line.get("raw", ""))
	if raw.is_empty() or not _emotes.has_emote(raw):
		return [[str(line.get("text", "")), false, color]]
	var out: Array = [[": ", false, color]]
	for piece: Array in _emotes.pieces(raw):
		if piece[0] == "emote":
			out.append(["", false, color, false, str(piece[1])])
		elif out.size() == 1:
			out[0][0] = ": " + str(piece[1])
		else:
			out.append([str(piece[1]), false, color])
	return out


func _emote(key: String, box: Rect2) -> void :
	var tex: Texture2D = _emotes.texture(key)
	if tex == null or tex.get_width() <= 0 or tex.get_height() <= 0:
		return
	var scale: float = minf(box.size.x / tex.get_width(), box.size.y / tex.get_height())
	var shown: Vector2 = Vector2(tex.get_width(), tex.get_height()) * scale
	draw_texture_rect(tex, Rect2((box.position + (box.size - shown) / 2.0) * _f, shown * _f), false)


func _fit(text: String, font: Font, px: int, room: float) -> int:
	var low: int = 0
	var high: int = text.length()
	while low < high:
		var mid: int = ceili((low + high) / 2.0)
		if font.get_string_size(text.substr(0, mid), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f <= room:
			low = mid
		else:
			high = mid - 1
	return low

func _first(count: int, shown: int) -> int:
	var last: int = maxi(0, count - shown)
	return last if _top < 0 else clampi(_top, 0, last)

func _scroll(step: int) -> void :
	var last: int = maxi(0, _rows.size() - _shown_rows)
	var first: int = clampi(_first(_rows.size(), _shown_rows) + step, 0, last)
	_top = -1 if first >= last else first


func _draw_bar(x: float, y0: float, y1: float, count: int, shown: int, first: int) -> void :
	_hit("sb_up", _fblit("chatf_sb_up", Vector2(x, y0), 16.0, 19.0, _glow("sb_up")), false)
	_hit("sb_down", _fblit("chatf_sb_down", Vector2(x, y1 - 19.0), 16.0, 19.0, _glow("sb_down")), false)
	_track = _fblit("chatf_sb_bk", Vector2(x, y0 + 19.0), 16.0, y1 - y0 - 38.0)
	_thumb = Rect2()
	if count <= shown:
		return
	var grip: float = maxf(10.0 * _f, _track.size.y * shown / float(count))
	var y: float = _track.position.y + (_track.size.y - grip) * first / float(count - shown)

	_hit("sb_pgup", Rect2(_track.position, Vector2(_track.size.x, maxf(0.0, y - _track.position.y))), false)
	_hit("sb_pgdn", Rect2(Vector2(_track.position.x, y + grip), Vector2(_track.size.x, maxf(0.0, _track.end.y - y - grip))), false)
	_thumb = Rect2(_track.position.x, y, _track.size.x, grip)
	var cell: Array = _cells.get("chatf_sb_thumb", [])
	if not cell.is_empty() and cell[0] != null:
		var tex: Texture2D = cell[0]
		var src: Rect2 = Rect2(float(cell[1][0]), float(cell[1][1]), float(cell[1][2]), float(cell[1][3]))
		var cap: float = minf(4.0 * _f, grip / 2.0)
		var tint: Color = _glow("slide:bar")
		draw_texture_rect_region(tex, Rect2(_thumb.position, Vector2(_thumb.size.x, cap)), Rect2(src.position, Vector2(src.size.x, 4)), tint)
		draw_texture_rect_region(tex, Rect2(_thumb.position + Vector2(0, cap), Vector2(_thumb.size.x, grip - cap * 2.0)), Rect2(src.position + Vector2(0, 4), Vector2(src.size.x, src.size.y - 8.0)), tint)
		draw_texture_rect_region(tex, Rect2(_thumb.position + Vector2(0, grip - cap), Vector2(_thumb.size.x, cap)), Rect2(src.position + Vector2(0, src.size.y - 4.0), Vector2(src.size.x, 4)), tint)
	_hit("slide:bar", _thumb, false)


func _draw_quick(c: Vector2) -> Rect2:
	var at: Vector2 = c + Vector2(405, -126)
	at.x = clampf(at.x, 0.0, maxf(0.0, floorf(_fw + 0.01) - 264.0))
	at.y = clampf(at.y, 0.0, maxf(0.0, floorf(_fh + 0.01) - 265.0))
	var box: Rect2 = _fblit("chatf_quick_bk", at)
	_hit("panel", box, false)
	_fwords("Câu trò chuyện có sẵn:", BOLD, 16.0, Color("38f929"), "l", at + Vector2(8, 13), 210.0, 1.0)
	_fbutton("quick_close", "chatf_quick_close", at + Vector2(225, 6))
	for i in range(PHRASES.size()):
		var id: String = "say:%d" % i
		_hit(id, Rect2((at + Vector2(8, 43 + 24 * i)) * _f, Vector2(240, 22) * _f), false)
		_fwords(str(PHRASES[i]), REGULAR, 12.0, Color("f16422") if _hover == id else Color.WHITE, "l", at + Vector2(10, 43 + 24 * i), 236.0, 0.0, 22.0)
	return box




func _fl_open() -> void :
	if _fl:
		return
	_fl = true
	_fl_list = ChatFriend.online(client.friends)
	_fl_top = 0


func _fl_close() -> void :
	_fl = false
	_fl_list = []
	_fl_top = 0
	_fl_rect = Rect2()
	_fl_rows = Rect2()
	_fl_sliding = false


func _fl_pick(index: int) -> void :
	if index < 0 or index >= _fl_list.size():
		return
	var name: String = str((_fl_list[index] as Dictionary).get("m_name", ""))
	_fl_close()
	_chan = 0
	open_whisper(name)

func _fl_scroll(step: int) -> void :
	_fl_top = ChatFriend.first(_fl_top + step, _fl_list.size())


func _fl_name(text: String, wide: float) -> String:
	var font: Font = _face(BOLD)
	var px: int = maxi(6, roundi(ChatFriend.FONT * _f))
	var room: float = wide - 4.0
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f <= room:
		return text
	var dots: float = font.get_string_size("...", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
	return text.substr(0, _fit(text, font, px, room - dots)) + "..."




func _draw_friend_list(c: Vector2) -> Rect2:
	var at: Vector2 = ChatFriend.origin(c, _fw, _fh)
	var box: Rect2 = _fblit("chatf_quick_bk", at, ChatFriend.SIZE.x, ChatFriend.SIZE.y)
	_fl_rect = box
	_hit("panel", box, false)
	_fblit("chatfr_select_t", at + ChatFriend.TAB)
	_fbutton("fl_close", "chatf_quick_close", at + ChatFriend.CLOSE)
	var list: Vector2 = at + ChatFriend.LIST.position
	var wide: float = ChatFriend.LIST.size.x - ChatFriend.BAR
	var count: int = _fl_list.size()
	_fl_top = ChatFriend.first(_fl_top, count)
	_fl_rows = Rect2(list * _f, Vector2(wide, ChatFriend.LIST.size.y) * _f)
	for i in range(_fl_top, mini(count, _fl_top + ChatFriend.ROWS)):
		var brief: Dictionary = _fl_list[i]
		var id: String = "fl_row:%d" % i
		var o: Vector2 = list + Vector2(0, ChatFriend.ROW * (i - _fl_top))
		var row: Rect2 = Rect2(o * _f, Vector2(wide, ChatFriend.ROW) * _f)
		if _press == id:
			draw_rect(row, ChatFriend.PICK)
		elif _hover == id and _press.is_empty() and _tip_ok():
			draw_rect(row, ChatFriend.HOVER)
		var mid: float = ChatFriend.ROW / 2.0
		_fblit(ChatFriend.level_cell(int(brief.get("m_level", 0))), o + Vector2(0, mid - ChatFriend.LEVEL.y / 2.0), ChatFriend.LEVEL.x, ChatFriend.LEVEL.y)
		_level_fx(int(brief.get("m_level", 0)), o + Vector2(0, mid - ChatFriend.LEVEL.y / 2.0), ChatFriend.LEVEL.x)
		_fwords(_fl_name(str(brief.get("m_name", "")), ChatFriend.NAME_W), BOLD, ChatFriend.FONT, Color.WHITE, "l", 
			o + Vector2(ChatFriend.NAME_X + ChatFriend.PAD, 0), ChatFriend.NAME_W, 1.0, 0.0, false, ChatFriend.GLOW)
		_fwords(ChatFriend.sex(int(brief.get("m_sex", 0))), BOLD, ChatFriend.FONT, Color.WHITE, "l", o + Vector2(ChatFriend.SEX_X + ChatFriend.PAD, 0), 
			ChatFriend.RENDER_W - ChatFriend.SEX_X, 1.0, 0.0, false, ChatFriend.GLOW)

		var vip: String = ChatFriend.vip_cell(int(brief.get("m_vipLevel", 0)))
		if not vip.is_empty():
			_fblit(vip, o + Vector2(ChatFriend.VIP_X, roundf(mid - _cell_size(vip).y / 2.0)))
		_hit(id, row, false)
	_draw_fl_bar(list.x + wide, list.y, list.y + ChatFriend.LIST.size.y, count, ChatFriend.ROWS, _fl_top)
	return box


func _draw_fl_bar(x: float, y0: float, y1: float, count: int, shown: int, first: int) -> void :
	var bar: float = ChatFriend.BAR
	_hit("fl_up", _fblit("chatf_sb_up", Vector2(x, y0), bar, bar, _glow("fl_up")), false)
	_hit("fl_down", _fblit("chatf_sb_down", Vector2(x, y1 - bar), bar, bar, _glow("fl_down")), false)
	_fl_track = _fblit("chatf_sb_bk", Vector2(x, y0 + bar), bar, y1 - y0 - bar * 2.0)
	_fl_thumb = Rect2()
	if count <= shown:
		return
	var grip: float = maxf(10.0 * _f, _fl_track.size.y * shown / float(count))
	var y: float = _fl_track.position.y + (_fl_track.size.y - grip) * first / float(count - shown)
	_hit("fl_pgup", Rect2(_fl_track.position, Vector2(_fl_track.size.x, maxf(0.0, y - _fl_track.position.y))), false)
	_hit("fl_pgdn", Rect2(Vector2(_fl_track.position.x, y + grip), Vector2(_fl_track.size.x, maxf(0.0, _fl_track.end.y - y - grip))), false)
	_fl_thumb = Rect2(_fl_track.position.x, y, _fl_track.size.x, grip)
	var cell: Array = _cells.get("chatf_sb_thumb", [])
	if not cell.is_empty() and cell[0] != null:
		var tex: Texture2D = cell[0]
		var src: Rect2 = Rect2(float(cell[1][0]), float(cell[1][1]), float(cell[1][2]), float(cell[1][3]))
		var cap: float = minf(4.0 * _f, grip / 2.0)
		var tint: Color = _glow("slide:fl")
		draw_texture_rect_region(tex, Rect2(_fl_thumb.position, Vector2(_fl_thumb.size.x, cap)), Rect2(src.position, Vector2(src.size.x, 4)), tint)
		draw_texture_rect_region(tex, Rect2(_fl_thumb.position + Vector2(0, cap), Vector2(_fl_thumb.size.x, grip - cap * 2.0)), Rect2(src.position + Vector2(0, 4), Vector2(src.size.x, src.size.y - 8.0)), tint)
		draw_texture_rect_region(tex, Rect2(_fl_thumb.position + Vector2(0, grip - cap), Vector2(_fl_thumb.size.x, cap)), Rect2(src.position + Vector2(0, src.size.y - 4.0), Vector2(src.size.x, 4)), tint)
	_hit("slide:fl", _fl_thumb, false)


func _draw_menu(r: Vector2) -> Rect2:
	var room: bool = client.state == "room"
	var high: float = 182.0 if room else 162.0
	var origin: Vector2 = Vector2(r.x + 11.0, r.y + 9.0 - high)
	var box: Rect2 = Rect2(origin * _f, Vector2(80, high) * _f)
	draw_rect(box, Color(0, 0, 0, 0.8))
	draw_rect(box, Color.BLACK, false, maxf(1.0, _f))
	_hit("panel", box, false)
	var y: float = 20.0
	for item: Array in MENU:
		var id: String = str(item[0])
		if id == "chan:camp" and not room:
			continue
		var at: Vector2 = origin + Vector2(0, y)
		var row: Rect2 = Rect2(at * _f, Vector2(80, 20) * _f)
		if _hover == id:
			draw_rect(row, Color("009dff", 0.25))
		_fwords(str(item[1]), BOLD, 12.0, item[2], "l", at + Vector2(2, 0), 78.0, 0.0, 20.0, false)
		_hit(id, row, false)
		y += 20.0
	return box



func _draw_tip() -> void :
	var text: String = ""
	if not ( not _tip_ok() or _tip_id.is_empty() or not _press.is_empty() or _hover != _tip_id):
		text = str(TIPS.get(_tip_id, _tips.get(_tip_id, "")))
	_chat_ctip.draw(self, _tip_id if not text.is_empty() else "", text, _mouse / _f, Vector2(_fw, _fh), _f)


func _whispers() -> int:
	if _tab == "whisper" and visible:
		return 0
	var seen: int = int(_seen.get("whisper", 0))
	var count: int = 0
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		if int(line.get("seq", 0)) <= seen:
			break
		if str(line.get("tab", "")) == "whisper" and not str(line.get("head", "")).contains("Nói với "):
			count += 1
	return count





static func target(line: Dictionary) -> Dictionary:
	var channel: int = int(line.get("channel", 0))
	var name: String = str(line.get("name", "")).strip_edges()
	if channel == 0 or channel == 2048 or name.is_empty() or int(line.get("oid", 0)) == 0:
		return {}
	return {"name": name, "uuid": str(line.get("uuid", "")), "oid": int(line.get("who_oid", 0))}

func _line(seq: int) -> Dictionary:
	for i in range(client.chat_log.size() - 1, -1, -1):
		if int(client.chat_log[i].get("seq", 0)) == seq:
			return client.chat_log[i]
	return {}



func _name_click(seq: int) -> void :
	var who: Dictionary = target(_line(seq))
	if who.is_empty():
		return
	var double: bool = _time - _name_at < DOUBLE_CLICK
	_name_at = -10.0 if double else _time
	_name_seq = 0 if double else seq
	_name_pos = _mouse
	if double:
		_hide_who()
		open_whisper(str(who.name))
		return
	_show_who(who, _mouse / _f - _stage())

	var uuid: String = str(who.get("uuid", ""))
	if uuid != "0":
		client.request_char_state(uuid)


func _double(at: Vector2) -> bool:
	if _name_seq == 0 or _time - _name_at >= DOUBLE_CLICK or at.distance_to(_name_pos) > 6.0 * _f:
		return false
	var who: Dictionary = target(_line(_name_seq))
	_name_at = -10.0
	_name_seq = 0
	if who.is_empty():
		return false
	_hide_who()
	_press = ""
	open_whisper(str(who.name))
	return true



func _who_high() -> float:
	var master: bool = ("master" in client) and client.master != null and client.master.have_master()
	return (314.0 if int(client.character.get("level", 0)) < Friends.GRADUATE_LEVEL and not master else 288.0) + Love.menu_extra(client)


func _show_who(who: Dictionary, at: Vector2) -> void :
	var high: float = _who_high()
	_who = who
	_who_at = Vector2(clampf(at.x, 0.0, 1000.0 - Friends.MENU_W), clampf(at.y, 0.0, 600.0 - high))
	_who_rect = Rect2((_stage() + _who_at) * _f, Vector2(Friends.MENU_W, high) * _f)
	_who_hide_at = _time + Friends.MENU_TIME

func _hide_who() -> void :
	_who = {}
	_who_hide_at = -1.0
	_who_rect = Rect2()

func is_friend(who: String) -> bool:
	for brief: Dictionary in client.friends.values():
		if str(brief.get("m_name", "")) == who:
			return true
	return false


func _guild_invitable(me: bool) -> bool:
	var uuid: String = str(_who.get("uuid", ""))
	if me or int(client.guild.get("nGuildId", 0)) <= 0 or ( not uuid.is_empty() and client.guild_members.has(uuid)):
		return false
	var reply: Dictionary = _who_state()
	if not reply.is_empty():
		return Friends.guild_open(reply)
	var oid: int = int(_who.get("oid", 0))
	for member: Dictionary in client.guild_members.values():
		if oid > 0 and int(member.get("nAcctId", 0)) == oid:
			return false
	return true


func _who_state() -> Dictionary:
	var uuid: String = str(_who.get("uuid", ""))
	if uuid.is_empty() or uuid == "0":
		return {}
	return client.char_states.get(uuid, {})


func _who_cut(text: String) -> String:
	var font: Font = _face(ARIAL_BOLD)
	var px: int = maxi(6, roundi(14.0 * _f))
	var room: float = Friends.STATE_LABEL_W - 4.0
	if font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f <= room:
		return text
	var dots: float = font.get_string_size("...", HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
	return text.substr(0, _fit(text, font, px, room - dots)) + "..."



func who_items() -> Array:
	var name: String = str(_who.get("name", ""))
	var me: bool = name == str(client.character.get("name", ""))
	var items: Array = [["pm:add", "Thêm bạn bè", not me and not is_friend(name)]]
	if _who_high() - Love.menu_extra(client) > 300.0:
		items.append(["pm:master", "Bái làm Sư Phụ", not me])
	if Love.shown(client):
		items.append(["pm:love", "Tỏ tình", Love.can_invite(client, int(_who.get("oid", 0)), me)])
	items.append_array([["pm:chat", "Chat riêng", not me], ["pm:copy", "Copy tên gọi", true], ["pm:black", "Thêm vào sổ đen", not me and not client.is_black_name(name)], 
		["pm:guild", "Mời vào Guild", _guild_invitable(me)], ["pm:delete", "Xóa", false], Friends.state_item("pm:", _who_state())])
	if int(client.character.get("gm_level", 0)) > 0:
		items.append(["pm:gm", "Thao tác GM", true])
	return items


func _draw_who() -> Rect2:
	var high: float = _who_high()
	var at: Vector2 = _stage() + _who_at
	_who_rect = Rect2(at * _f, Vector2(Friends.MENU_W, high) * _f)
	_hit("panel", _who_rect, false)
	_round(_who_rect, Color("e9f9ff", 0.98), 20.0, Color.WHITE, 4.0)
	_fwords(str(_who.get("name", "")), ARIAL_BOLD, 16, Color("f16422"), "l", at + Vector2(10, 5), 160)
	var lines: Array = Friends.state_lines(_who_state())
	for i in range(2):
		if not str(lines[i]).is_empty():
			_fwords(_who_cut(str(lines[i])), ARIAL_BOLD, 14, Friends.LINK, "l", at + Vector2(10, 30 + 20 * i), Friends.STATE_LABEL_W, 0.0, 0.0, false)
	_fblit("fr_cutline", at + Vector2(8, 75), 0.0, 0.0, Color(1, 1, 1, 0.8))
	var font_size: int = maxi(6, roundi(14.0 * _f))
	var y: float = 76.0
	for item: Array in who_items():
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
	_fbutton("pm:watch", "fr_watch", at + Vector2(114, high - 29.0))
	return _who_rect







func _who_action(key: String) -> void :
	var name: String = str(_who.get("name", ""))
	if name.is_empty():
		return
	for item: Array in who_items():
		if str(item[0]) == "pm:" + key and not bool(item[2]):
			return
	match key:
		"add":
			if client.is_black_name(name):
				say(Friends.FRIEND_TXT8)
			elif client.add_friend(name):
				say("Đã gửi kết bạn tới %s." % name)
			_hide_who()
		"master":
			var uuid: String = str(_who.get("uuid", ""))
			if not uuid.is_empty() and uuid != "0":
				client.master_send(709, MasterModel.apply_relation(uuid, MasterModel.MAT_ENGAGE_MASTER))
		"chat":
			if int(client.character.get("level", 0)) < Friends.PM_LEVEL:
				say("Đạt lv10 được PM")
				return
			_hide_who()
			open_whisper(name)
		"copy":
			DisplayServer.clipboard_set(name)
			_hide_who()
		"black":
			client.add_black(name)
			_hide_who()
		"guild":
			var mine: String = client.guild_self_uuid()
			var boss: bool = not mine.is_empty() and mine in [str(client.guild.get("leaderUuid", "")), str(client.guild.get("viceLeaderUuid", ""))]
			if (int(client.guild.get("iSettingBit", 0)) & Friends.GUILD_OP_MEMBER_INVITE) == 0 and not boss:
				say(Friends.TIP_680)
			elif client.guild_invite(str(_who.get("uuid", "")), client.guild_self_team):
				say(Friends.CORPS_TEXT28)
		"love":
			var love_acct: int = int(_who.get("oid", 0))
			_hide_who()
			preload("love_ask.gd").open_for(self, "invite", name, love_acct)
		"gm":
			if name != str(client.character.get("name", "")):
				preload("gm_option.gd").open_for(self, name)
		"watch":
			var uuid: String = str(_who.get("uuid", ""))
			_hide_who()
			if uuid.is_empty() or uuid == "0":
				say("Chưa xem được hồ sơ người chơi này.")
			else:
				player_info_asked.emit(uuid)
		"watch_battle":

			var reply: Dictionary = _who_state()
			var look_oid: int = int(_who.get("oid", 0))
			_hide_who()
			if int(reply.get("m_nState", 0)) == Friends.PS_BATTLE:
				var text: String = client.look_scene_oid(int(reply.get("m_nSceneId", 0)), look_oid)
				if not text.is_empty():
					say(text)
		"enter_room":

			var reply: Dictionary = _who_state()
			_hide_who()
			if int(reply.get("m_nState", 0)) == Friends.PS_ROOM:
				var text: String = client.join_friend_room(int(reply.get("m_nRoomId", 0)), int(reply.get("m_nRoomType", 0)))
				if not text.is_empty():
					say(text)



func _activate(id: String) -> void :

	var aside: bool = id == "friends" or id.begins_with("fl_") or id == "slide:fl" or (id == "panel" and _fl and _fl_rect.has_point(_mouse))
	if id.begins_with("fl_row:"):
		_fl_pick(int(id.substr(7)))
		return
	if aside:
		match id:
			"friends":
				_fl_open()
			"fl_close":
				_fl_close()
			"fl_up":
				_fl_scroll(-1)
			"fl_down":
				_fl_scroll(1)
			"fl_pgup":
				_fl_scroll( - ChatFriend.ROWS)
			"fl_pgdn":
				_fl_scroll(ChatFriend.ROWS)
		return
	if id != "channel":
		_menu = false

	if _picker and not id.begins_with("emo"):
		_picker = false
	if id.begins_with("who:"):
		_name_click(int(id.substr(4)))
		return
	if id.begins_with("pm:"):
		_who_action(id.substr(3))
		return
	if id.begins_with("emo:"):
		_choose(int(id.substr(4)))
		return
	if id.begins_with("emotab:"):
		_emo_pack = id.substr(7)
		_emo_page = 0
		return
	if id.begins_with("emomode:"):
		_emo_frames = id == "emomode:frames"
		_emo_page = 0
		return
	if id.begins_with("emopage:"):
		_emo_page = maxi(0, _emo_page + int(id.substr(8)))
		return
	if id.begins_with("emoframe:"):

		client.equip_chat_frame(id.substr(9))
		_picker = false
		return
	if id.begins_with("tab:"):
		var key: String = id.substr(4)
		if _viewable(key):
			_switch(key)
		else:
			say("Kênh Team chỉ dùng được trong phòng chờ.")
		return
	if id.begins_with("say:"):
		if _send(str(PHRASES[int(id.substr(4))])):
			_quick = false
		return
	if id.begins_with("chan:"):
		_channel(id.substr(5))
		return
	match id:
		"shade", "close":
			close()
		"horn_ok":
			_horn_confirm()
		"horn_cancel":
			_horn_close()
		"send":
			_submit()
			_focus = true
		"quick":
			_quick = not _quick
		"quick_close":
			_quick = false
		"channel":
			_menu = not _menu
		"height":
			_grow()
		"clear":
			_cleared = client.chat_rev
			_top = -1
		"up":
			_scroll(-2)
		"down":
			_scroll(2)
		"bottom":
			_top = -1
		"sb_up":
			_scroll(-1)
		"sb_down":
			_scroll(1)
		"sb_pgup":
			_scroll(-2)
		"sb_pgdn":
			_scroll(2)
		"emote":

			_quick = false
			_picker = not _picker
			if _picker:
				_emo_frames = false
				_emotes.refresh(true)
		"emo_close":
			_picker = false



func _channel(key: String) -> void :
	match key:
		"bugle":
			_pick(256)
		"world":
			_pick(128)
		"team":
			_pick(4)
		"whisper":
			whisper_pick_asked.emit()
		"all":
			_switch("all")
			if client.state == "room":
				_pick(2)
			else:
				_chan = 0
		"now":
			_chan = 0
			_switch("room" if client.state == "room" else "all")
		_:
			if _viewable(key):
				_chan = 0
				_switch(key)
			else:
				say("Kênh Team chỉ dùng được trong phòng chờ.")




func _pick(channel: int) -> void :
	var changed: bool = _chan != channel
	_chan = channel
	_quick = false
	_focus = true
	if changed and HORNS.has(channel) and client.horn_count(channel) <= 0:
		say(str(HORNS[channel][1]))
		quick_buy_asked.emit(int(HORN_ITEMS[channel]))


func send_channel() -> int:
	return _chan if _chan != 0 else int(SEND_ON.get(_tab, 2))







func _draw_picker(r: Vector2) -> Rect2:
	var packs: Array = _emotes.picker_packs()
	var ids: Array = packs.map( func(pack: Dictionary) -> String: return str(pack["id"]))
	if not ids.has(_emo_pack):
		_emo_pack = str(ids[0]) if not ids.is_empty() else ""
	var tabs: Array = []
	var tab_x: float = 8.0
	var tab_y: float = 43.0
	for pack: Dictionary in packs:
		var name: String = str(pack["label"]) if not str(pack["label"]).is_empty() else str(pack["id"])
		var wide: float = maxf(44.0, name.length() * 7.0 + 18.0)
		if tab_x > 8.0 and tab_x + wide > EMO_W - 8.0:
			tab_x = 8.0
			tab_y += 26.0
		tabs.append([str(pack["id"]), name, tab_x, tab_y, wide])
		tab_x += wide + 4.0
	var grid_y: float = tab_y + 30.0
	var high: float = grid_y + 3.0 * EMO_CELL + 14.0
	var at: Vector2 = Vector2(maxf(0.0, r.x + 421.0 + 32.0 - EMO_W), maxf(0.0, r.y - 3.0 - high - 4.0))
	var box: Rect2 = Rect2(at * _f, Vector2(EMO_W, high) * _f)
	for i in range(3, 0, -1):
		_round(box.grow(i * _f), Color("160000", 0.2), 22.0 + i * 2.0)
	_round(box, Color("29e9f9"), 22.0)
	_round(Rect2((at + Vector2(3, 3)) * _f, Vector2(EMO_W - 6.0, high - 6.0) * _f), Color("00579d"), 16.0)
	_round(Rect2((at + Vector2(5, 5)) * _f, Vector2(EMO_W - 10.0, high - 10.0) * _f), Color("0065ac"), 12.0)
	draw_rect(Rect2((at + Vector2(3, 35)) * _f, Vector2(EMO_W - 6.0, 2.0) * _f), Color("29e9f9"))
	_hit("emo_panel", box, false)
	_tile(at + Vector2(7, grid_y - 6.0), Vector2(EMO_W - 14.0, 3.0 * EMO_CELL + 12.0), Color("004f8f"), Color("15aad4"))
	for mode: Array in [["frames", "Khung chat", 70.0, 86.0], ["emotes", "Emote", 8.0, 58.0]]:
		var id: String = "emomode:" + str(mode[0])
		var active: bool = (str(mode[0]) == "frames") == _emo_frames
		var over: bool = not active and _hover == id
		var spot: Vector2 = at + Vector2(float(mode[2]), 5)
		var wide: float = float(mode[3])
		_tile(spot, Vector2(wide, 26), Color("004f8f") if active else (Color("0a86cc") if over else Color("0065ac")), Color("29e9f9") if active or over else Color("15aad4"))
		_fwords(str(mode[1]), BOLD, 14.0, Color("38f929") if active else Color("bfe6f7"), "c", spot + Vector2(0, 3), wide)
		if not active:
			_hit(id, Rect2(spot * _f, Vector2(wide, 26) * _f), false)
	var choices: Array = ["reset"]
	for pack: Dictionary in _emotes.frame_packs():
		choices.append(str(pack["id"]))
	var items: Array = (_emotes.pack_of[_emo_pack] as Dictionary)["items"] if not _emo_pack.is_empty() else []
	var count: int = choices.size() if _emo_frames else items.size()
	var pages: int = maxi(1, ceili(count / (6.0 if _emo_frames else float(EMO_PAGE))))
	_emo_page = clampi(_emo_page, 0, pages - 1)
	_fwords("%d/%d" % [_emo_page + 1, pages], BOLD, 12.0, Color.WHITE, "c", at + Vector2(EMO_W - 97.0, 9), 34.0)
	_page_button(-1, _emo_page > 0, at + Vector2(EMO_W - 119.0, 8))
	_page_button(1, _emo_page + 1 < pages, at + Vector2(EMO_W - 63.0, 8))
	_fbutton("emo_close", "chatf_quick_close", at + Vector2(EMO_W - 39.0, 7))
	if _emo_frames:
		_fwords("Nhấn vào khung để dùng cho tin nhắn", REGULAR, 12.0, Color("bfe6f7"), "l", at + Vector2(10, 45), EMO_W - 20.0)
		for i in range(6):
			var n: int = _emo_page * 6 + i
			if n >= choices.size():
				break
			var frame: String = str(choices[n])
			var id: String = "emoframe:" + frame
			var spot: Vector2 = at + Vector2(13.0 + (i % 2) * 133.0, grid_y + floorf(i / 2.0) * 38.0)
			var colors: Array = _frame_colors(frame)
			var name: String = "Mặc định" if frame == "reset" else str((_emotes.pack_of[frame] as Dictionary)["label"])
			_round(Rect2(spot * _f, Vector2(127, 34) * _f), Color(0, 0, 0, 0), 18.0, Color("f16422") if _hover == id else Color("004f8f"), 4.0)
			var art: Array = _emotes.frame_art(frame)
			if art.is_empty():
				_round(Rect2((spot + Vector2(3, 3)) * _f, Vector2(121, 28) * _f), colors[0], 14.0, colors[1], 4.0)
			else:
				_frame_art(art, spot + Vector2(4, 4), Vector2(119, 26))
			_fwords(name, BOLD, 12.0, colors[2], "c", spot + Vector2(0, 7), 127.0)
			_hit(id, Rect2(spot * _f, Vector2(127, 34) * _f), false)
			_tips[id] = "Khung mặc định" if frame == "reset" else "Dùng khung " + name
		return box
	for tab: Array in tabs:
		var id: String = "emotab:" + str(tab[0])
		var spot: Vector2 = at + Vector2(float(tab[2]), float(tab[3]))
		var wide: float = float(tab[4])
		var selected: bool = str(tab[0]) == _emo_pack
		var over: bool = _hover == id
		_tile(spot, Vector2(wide, 22), Color("f16422") if selected else (Color("0a86cc") if over else Color("004f8f")), Color("ffb38a") if selected else (Color("29e9f9") if over else Color("15aad4")))
		_fwords(str(tab[1]), BOLD, 12.0, Color.WHITE, "c", spot + Vector2(0, 2), wide)
		_hit(id, Rect2(spot * _f, Vector2(wide, 22) * _f), false)
		_tips[id] = str(tab[1])
	for i in range(EMO_PAGE):
		var n: int = _emo_page * EMO_PAGE + i
		var spot: Vector2 = at + Vector2(EMO_GRID_X + (i % EMO_COLS) * EMO_CELL, grid_y + floorf(i / float(EMO_COLS)) * EMO_CELL)
		if n >= items.size():
			_tile(spot, Vector2(EMO_CELL, EMO_CELL), Color("00579d"), Color("10659f"))
			continue
		var id: String = "emo:%d" % n
		var item: String = str(items[n])
		var over: bool = _hover == id
		_tile(spot, Vector2(EMO_CELL, EMO_CELL), Color("f16422") if over else Color("0065ac"), Color("ffb38a") if over else Color("1683c0"))
		_emote("%s:%s" % [_emo_pack, item], Rect2(spot + Vector2.ONE * (EMO_CELL - EMO_ICON) / 2.0, Vector2(EMO_ICON, EMO_ICON)))
		_hit(id, Rect2(spot * _f, Vector2(EMO_CELL, EMO_CELL) * _f), false)
		var code: String = _emotes.code(_emo_pack, item)
		_tips[id] = _emotes.label(_emo_pack, item) + ("  /" + code if not code.is_empty() else "")
	if not _emotes.loaded:
		_fwords("Đang tải danh sách biểu cảm…", BOLD, 12.0, Color("bfe6f7"), "c", at + Vector2(7, grid_y - 6.0), EMO_W - 14.0, 0.0, 3.0 * EMO_CELL + 12.0)
	return box


func _tile(spot: Vector2, wide: Vector2, fill: Color, line: Color) -> void :
	_round(Rect2((spot + Vector2(1, 1)) * _f, (wide - Vector2(2, 2)) * _f), fill, 9.0, line, 2.0)


func _page_button(step: int, live: bool, spot: Vector2) -> void :
	var alpha: float = 1.0 if live else 0.4
	_round(Rect2(spot * _f, Vector2(20, 20) * _f), Color("008095", alpha), 6.0)
	_round(Rect2(spot * _f, Vector2(20, 18) * _f), Color("29e9f9", alpha), 6.0)
	var tip: float = 6.0 if step < 0 else 14.0
	var base: float = 13.0 if step < 0 else 7.0
	draw_colored_polygon(PackedVector2Array([(spot + Vector2(tip, 9)) * _f, (spot + Vector2(base, 4)) * _f, (spot + Vector2(base, 14)) * _f]), Color(1, 1, 1, alpha))
	if live:
		_hit("emopage:%d" % step, Rect2(spot * _f, Vector2(20, 20) * _f), false)



func _frame_art(art: Array, at: Vector2, size: Vector2) -> void :
	var tex: Texture2D = _emotes.texture("%s:%s" % [Emotes.ART_PACK, str(art[0])])
	if tex == null:
		return
	for part: Array in Emotes.nine(Vector2(tex.get_width(), tex.get_height()), float(art[1]), size.x, size.y):
		var dst: Rect2 = part[0]
		draw_texture_rect_region(tex, Rect2((at + dst.position) * _f, dst.size * _f), part[1])


func _frame_colors(id: String) -> Array:
	if id == "reset":
		return [Color("ffffff"), Color("8291a5"), Color("172c49")]
	var frame: Array = (_emotes.pack_of.get(id, {}) as Dictionary).get("frame", [])
	return frame if frame.size() == 3 else [Color("172c49"), Color("75bfff"), Color("eff7ff")]


func _choose(n: int) -> void :
	if _emo_pack.is_empty() or not _emotes.pack_of.has(_emo_pack):
		return
	var items: Array = (_emotes.pack_of[_emo_pack] as Dictionary)["items"]
	if n < 0 or n >= items.size():
		return
	insert_emote(_emo_pack, str(items[n]))
	_picker = false




func insert_emote(pack: String, item: String) -> bool:
	if not _emotes.usable(pack, item):
		return false
	var text: String = _input.text
	var start: int = clampi(_input.caret_column, 0, text.length())
	var end: int = start
	if _input.has_selection():
		start = clampi(_input.get_selection_from_column(), 0, text.length())
		end = clampi(_input.get_selection_to_column(), start, text.length())
	var token: String = "[emote:%s:%s]" % [pack, item]
	var code: String = _emotes.code(pack, item)
	if not code.is_empty():
		token = "/" + code
		if not _emotes.expand_codes(text.substr(0, start) + token).ends_with("]"):
			token = " " + token
		if end < text.length() and text.unicode_at(end) >= 48 and text.unicode_at(end) <= 57:
			token += " "
	else:
		var short: String = "[%s]" % item
		var suffix: int = 2
		while _tokens.has(short) and str(_tokens[short]) != token:
			short = "[%s %d]" % [item, suffix]
			suffix += 1
		_tokens[short] = token
		token = short
	var joined: String = text.substr(0, start) + token + text.substr(end)
	if joined.length() > _input.max_length and _input.max_length > 0:
		say("Ô nhập đã đủ %d ký tự." % _input.max_length)
		return false
	_input.text = joined
	_input.caret_column = start + token.length()
	_focus = true
	return true


func picker() -> bool:
	return _picker


func emotes() -> Node:
	return _emotes




func open_horn(channel: int, text: String = "") -> bool:
	if not HORNS.has(channel) or client == null:
		return false
	if _horn_left(channel) <= 0:
		say(str(HORNS[channel][1]))
		return false
	if page_over and not is_open() and not docked():
		if not _solo:
			_solo_hid = not visible
		_solo = true
		visible = true
	elif not visible and not docked():
		open()
	if not visible:
		return false
	_horn = channel
	_quick = false
	_menu = false
	_horn_input.text = text.left(HORN_LIMIT)
	_horn_input.caret_column = _horn_input.text.length()
	_focus = true
	return true

func horn() -> int:
	return _horn


func _horn_left(channel: int) -> int:
	return client.global_horn_count() if channel == 2048 else client.horn_count(channel)

func _horn_close() -> void :
	_horn = 0
	_horn_input.visible = false
	_focus = true
	if _solo:
		_solo = false
		if _solo_hid:
			_solo_hid = false
			_focus = false
			visible = false



func _horn_confirm() -> void :
	if _horn == 0:
		return
	var text: String = _horn_input.text.strip_edges()
	if text.is_empty():
		say("Nhập nội dung!")
		return
	var content: String = _emotes.expand(text, _tokens)
	var refused: String = _emotes.refusal(content)
	if not refused.is_empty():
		say(refused)
		return
	var sent: bool = client.send_global_horn(content) if _horn == 2048 else client.send_chat_channel(content, _horn)
	if sent and _input.text.strip_edges().left(HORN_LIMIT) == text:
		_input.text = ""
	_horn_input.text = ""
	_horn_close()




func _draw_horn() -> void :
	_hit("horn_block", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(HORN_SIZE.x, HORN_SIZE.y)
	var box: Rect2 = Rect2(at * _f, HORN_SIZE * _f)
	for i in range(3, 0, -1):
		_round(box.grow(i * _f), Color("160000", 0.16), 30.0 + i * 2.0)
	_round(box, Color("85d8f7", 0.95), 30.0, Color.WHITE, 8.0)
	_hit("horn_panel", box, false)
	_fwords("Nhập nội dung loa", BOLD, 20.0, Color("0066cc"), "c", at + Vector2(0, 15), HORN_SIZE.x)
	_fblit("chorn_input", at + Vector2(10, 51))
	_fput(_horn_input, Rect2(at + Vector2(25, 51), Vector2(462, 35)), 16.0)
	_fwords("Còn %d %s" % [_horn_left(_horn), HORNS[_horn][0]], BOLD, 12.0, Color("0066cc"), "r", at + Vector2(10, 86), 480.0, 0.0, 14.0)
	for button: Array in [["horn_ok", "chorn_ok", "chorn_ok_t", 140.0], ["horn_cancel", "chorn_cancel", "chorn_cancel_t", 250.0]]:
		var spot: Vector2 = at + Vector2(float(button[3]), 100)
		_fbutton(str(button[0]), str(button[1]), spot)
		var face: Vector2 = _cell_size(str(button[1]))
		_fblit(str(button[2]), spot + ((face - _cell_size(str(button[2]))) / 2.0).round(), 0.0, 0.0, _glow(str(button[0])))


func _grow() -> void :
	if docked():
		return
	for step in range(1, 3):
		var next: int = (_height + step) % 3
		if next == 0 or _c.y - float(EXTRA[next]) >= 0.0:
			_height = next
			_top = -1
			return

func _wheel(step: int, at: Vector2) -> void :
	if _fl and _fl_rect.has_point(at):
		_fl_scroll(step * ChatFriend.WHEEL)
		return
	if _frame.has_point(at):
		_scroll(step * 3)

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouse:
		_mouse = event.position
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _double(event.position):
			accept_event()
			return

		if event.pressed and not _who.is_empty() and not _who_rect.has_point(event.position):
			_hide_who()
		_sliding = event.pressed and _hit_at(event.position) == "slide:bar"
		if _sliding:
			_slide_from = event.position.y
			_slide_first = _first(_rows.size(), _shown_rows)
		_fl_sliding = event.pressed and _fl and _hit_at(event.position) == "slide:fl"
		if _fl_sliding:
			_fl_slide_from = event.position.y
			_fl_slide_first = _fl_top
	elif event is InputEventMouseMotion and _fl_sliding and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		var top: int = maxi(0, _fl_list.size() - ChatFriend.ROWS)
		var room: float = _fl_track.size.y - _fl_thumb.size.y
		if top > 0 and room > 0.0:
			_fl_top = clampi(_fl_slide_first + roundi((event.position.y - _fl_slide_from) / room * top), 0, top)
	elif event is InputEventMouseMotion and _sliding and event.button_mask & MOUSE_BUTTON_MASK_LEFT:
		var last: int = maxi(0, _rows.size() - _shown_rows)
		var travel: float = _track.size.y - _thumb.size.y
		if last > 0 and travel > 0.0:
			var first: int = clampi(_slide_first + roundi((event.position.y - _slide_from) / travel * last), 0, last)
			_top = -1 if first >= last else first
	super (event)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _mobile and _fl and not _fl_sliding and _fl_rows.has_point(from):

		if from != _fl_drag_from:
			_fl_drag_from = from
			_fl_drag_sum = 0.0
			_fl_drag_first = _fl_top
		_fl_drag_sum += moved.y
		_fl_top = ChatFriend.first(_fl_drag_first - roundi(_fl_drag_sum / (ChatFriend.ROW * _f)), _fl_list.size())
		return
	if not _mobile or _sliding or not _lines_rect.has_point(from):
		return
	if from != _drag_from:
		_drag_from = from
		_drag_sum = 0.0
		_drag_first = _first(_rows.size(), _shown_rows)
	_drag_sum += moved.y
	var last: int = maxi(0, _rows.size() - _shown_rows)
	var first: int = clampi(_drag_first - roundi(_drag_sum / (24.0 * _f)), 0, last)
	_top = -1 if first >= last else first
