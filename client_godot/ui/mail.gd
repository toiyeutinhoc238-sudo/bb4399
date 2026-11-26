extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")


















const Atlas = preload("mail_atlas.gd")
const MailModel = preload("mail_model.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const ChatAtlas = preload("chatf_atlas.gd")
const ChatFriend = preload("chat_friend_list.gd")
const ChatFriendAtlas = preload("chat_friend_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Leader = preload("leaderboard_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")

signal closed

const SIZE: Vector2 = Vector2(858, 574)
const DIM: Color = Color(0, 0, 0, 0.4)
const OFF: Color = Color(0.55, 0.55, 0.55, 1.0)
const INK: Color = Color("8d2d00")
const PER_PAGE: int = 6
const PITCH: float = 62.0
const LIST_HIGH: float = 366.0
const ROW_SIZE: Vector2 = Vector2(403, 61)
const GRIDS: Array = ["itemGrid0", "itemGrid1", "itemGrid2", "tankGrid"]
const EXTRA: Dictionary = {"clear": Vector2(625, 509), "claimall": Vector2(733, 509)}
const WRITE_LEVEL: int = 15
const LOW_LEVEL: String = "≥Lv15 mới được gửi thư"
const WRITE_AT: Vector2 = Vector2(207, 0)
const WRITE_SIZE: Vector2 = Vector2(443, 454)
const TITLE_MAX: int = 20
const TEXT_MAX: int = 200
const TO_EDIT: Rect2 = Rect2(101, 58, 181, 22)
const TITLE_EDIT: Rect2 = Rect2(98, 95, 298, 23)
const BODY_EDIT: Rect2 = Rect2(36.5, 141, 351, 234)
const FRIENDS_AT: Vector2 = Vector2(36, 80)
const NEED_NAME: String = "Nhập tên người nhận"
const NOT_SELF: String = "Người nhận không thể là bản thân"
const NEED_TITLE: String = "Nhập tiêu đề"
const NEED_TEXT: String = "Nội dung thư"
const SENT_OK: String = "Gửi thư thành công"
const TO: String = "To:"
const SENT_FAIL: String = "Chưa tải được thư đã gửi."
const SYSTEM_NAME: String = "Thư Hệ Thống"
const FROM: String = "From:"
const LEFT_TIME: String = "T/g còn: "
const NOT_OFFICIAL: String = "Không phải thư từ NPH, hãy cẩn thận."
const HINT: String = "Bấm nhận\ntất cả quà"
const DELETE_TIP: String = "Xóa thư này"
const ASK_DELETE: String = "Đồng ý xóa thư không?"
const ASK_CLEAR: String = "Xoá mọi thư đã đọc và không còn quà?\nThư chưa đọc và thư còn quà được giữ lại."
const BUSY: String = "Đang xử lý…"
const KEEP_GIFT: String = "Nhận quà trước khi xoá thư."
const SAO_BATTLE: int = 1
const FRIEND_SELF: String = "Không thể kết bạn với chính mình"

var _tab: String = "all"
var _rows: Array = []
var _counts: Array = [0, 0, 0]
var _page: int = 0
var _pick: String = ""
var _rev: int = -1
var _names: Dictionary = {}
var _sheet_id: String = ""
var _doomed: String = ""
var _wait: String = ""
var _wait_at: float = -100.0
var _asked: Dictionary = {}
var _note: RichTextLabel
var _note_key: String = ""
var _note_px: int = 0
var _words_of: String = ""
var _words: String = ""
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _befriend: String = ""
var fetch: Callable
var _http: HTTPRequest
var _sent: Array = []
var _sent_loading: bool = false
var _writing: bool = false
var _to: LineEdit
var _subject: LineEdit
var _body: TextEdit
var _body_box: StyleBoxEmpty = StyleBoxEmpty.new()
var _body_prev: String = ""
var _wfl: bool = false
var _wfl_list: Array = []
var _wfl_top: int = 0
var _wfl_rect: Rect2 = Rect2()
var _wfl_rows: Rect2 = Rect2()
var _thumbs: Dictionary = {}
var _drag_from: Vector2 = Vector2(-1, -1)
var _drag_sum: float = 0.0
var _drag_first: float = 0.0

func chat_busy() -> bool:
	return not _sheet_id.is_empty() or _writing

func _setup() -> void :
	_note = RichTextLabel.new()
	_note.bbcode_enabled = true
	_note.scroll_active = true
	_note.mouse_filter = Control.MOUSE_FILTER_PASS
	_note.add_theme_font_override("normal_font", ARIAL_BOLD)
	_note.add_theme_font_override("bold_font", ARIAL_BOLD)
	_note.add_theme_color_override("default_color", INK)
	_note.visible = false
	add_child(_note)
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_sent)

	_to = _name_fedit()
	_subject = _fedit(TITLE_MAX)
	for edit: LineEdit in [_to, _subject]:
		edit.add_theme_font_override("font", ARIAL)
	_body = TextEdit.new()
	_body.visible = false
	_body.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_body.context_menu_enabled = false
	_body.emoji_menu_enabled = false
	_body.tab_input_mode = false
	_body.caret_blink = true
	for state: String in ["normal", "focus", "read_only"]:
		_body.add_theme_stylebox_override(state, _body_box)
	_body.add_theme_font_override("font", ARIAL)
	_body.add_theme_color_override("font_color", INK)
	_body.add_theme_color_override("caret_color", INK)
	_body.add_theme_color_override("selection_color", Color("0b5fae", 0.45))
	_body.add_theme_color_override("background_color", Color(0, 0, 0, 0))
	_body.get_v_scroll_bar().modulate = Color(1, 1, 1, 0)
	add_child(_body)
	_body.text_changed.connect(_body_cap)
	client.noticed.connect( func(text: String) -> void :
		if is_visible_in_tree():
			say(text))
	client.mail_result.connect(_on_result)
	client.friend_result.connect( func(_ok: bool, text: String) -> void :
		if not _befriend.is_empty():
			_befriend = ""
			if is_visible_in_tree():
				say(text))

func _shown() -> void :
	if _note == null:
		return
	_close()
	_close_write()
	_tip = []
	_http.cancel_request()
	_sent_loading = false
	_sent = []
	if not is_visible_in_tree():
		_note.visible = false
		return
	pack.load_bag()
	client.request_mails()
	_tab = "all"
	_pick = ""
	_page = 0
	_wait = ""
	_asked.clear()
	_note_key = ""
	_rev = -1

func _tick(_delta: float) -> void :
	if client.mail_rev != _rev:
		_rev = client.mail_rev
		if _tab != "sent" and not _pick.is_empty() and MailModel.find(client.mails, _pick).is_empty():
			_pick = ""
		if _sheet_id == "delete" and MailModel.find(client.mails, _doomed).is_empty():
			_close()
		_rebuild()

	if _tab != "sent" and not _pick.is_empty() and not client.mail_bodies.has(_pick) and _time - float(_asked.get(_pick, -10.0)) > 3.0:
		_ask(_pick)




func _rebuild() -> void :
	_rows = _sent if _tab == "sent" else MailModel.rows(client.mails, _tab, _pick)
	_counts = MailModel.counts(client.mails)
	var pages: int = _page_count()
	_page = 0 if pages == 0 else clampi(maxi(_page, 1), 1, pages)
	_names.clear()
	for mail: Dictionary in client.mails:
		_names[str(mail.uuid)] = [MailModel.printable(MailModel.plain(str(mail.title)), ARIAL_BOLD), MailModel.printable(MailModel.plain(str(mail.sender)), ARIAL_BOLD)]

	for mail: Dictionary in _sent:
		_names[str(mail.uuid)] = [MailModel.printable(str(mail.title), ARIAL_BOLD), MailModel.printable(str(mail.receiver), ARIAL_BOLD)]

func _page_count() -> int:
	return ceili(_rows.size() / float(PER_PAGE))


func _page_rows() -> Array:
	return _rows.slice((_page - 1) * PER_PAGE, _page * PER_PAGE) if _page > 0 else []


func _name(uuid: String) -> Array:
	return _names.get(uuid, ["", ""])

func _mail() -> Dictionary:
	return MailModel.find(client.mails, _pick) if not _pick.is_empty() and _tab != "sent" else {}

func _sent_mail() -> Dictionary:
	return MailModel.find(_sent, _pick) if not _pick.is_empty() and _tab == "sent" else {}

func _gifts() -> Array:
	return MailModel.gifts(client.mail_bodies.get(_pick, {}), pack.bag) if client.mail_bodies.has(_pick) else []


func _system(mail: Dictionary) -> bool:
	return bool(mail.get("system", true))


func _friend(who: String) -> bool:
	for brief: Dictionary in client.friends.values():
		if str(brief.get("m_name", "")) == who:
			return true
	return false


static func _span(seconds: int) -> String:
	var hours: int = ceili(maxi(0, seconds) / 3600.0)
	if hours < 24:
		return "%d giờ" % hours
	var days: int = hours / 24
	hours %= 24
	return "%d ngày %d giờ" % [days, hours] if hours > 0 else "%d ngày" % days


func _left_text(mail: Dictionary, now: int) -> String:
	return LEFT_TIME + _span(int(mail.get("deadline", 0)) - now)


func _sender_text(uuid: String) -> String:
	var who: String = str(_name(uuid)[1])
	if _tab == "sent":
		return TO + who
	return SYSTEM_NAME if who.is_empty() else FROM + who


func _body_markup(raw: String) -> String:
	return MailModel.printable(MailModel.markup(raw).replace("[color=#f4ead2]", "[color=#8d2d00]"), ARIAL_BOLD)

func _busy() -> bool:
	return not _wait.is_empty() and _time - _wait_at < 4.0





func _add_friend() -> void :
	var mail: Dictionary = _mail()
	if mail.is_empty() or _system(mail):
		return
	var who: String = str(mail.get("sender", "")).strip_edges()
	if who.is_empty():
		return
	if who == str(client.character.get("name", "")):
		say(FRIEND_SELF)
		return
	if client.add_friend(who, SAO_BATTLE):
		_befriend = who
	else:
		say(BUSY)

func _ask(uuid: String) -> void :
	if client.open_mail(uuid):
		_asked[uuid] = _time

func _select(uuid: String) -> void :
	if uuid == _pick:
		return
	_pick = uuid
	_note_key = ""
	if _tab == "sent":

		if _sent_mail().is_empty():
			_pick = ""
		return
	var mail: Dictionary = _mail()
	if mail.is_empty():
		_pick = ""
		return
	if bool(mail.unread) or not client.mail_bodies.has(uuid):
		_ask(uuid)
	_rebuild()


func _step(by: int) -> void :
	if _rows.is_empty():
		return
	var at: int = -1
	for i in range(_rows.size()):
		if str(_rows[i].uuid) == _pick:
			at = i
	var next: int = clampi(at + by, 0, _rows.size() - 1) if at >= 0 else clampi((_page - 1) * PER_PAGE, 0, _rows.size() - 1)
	_page = next / PER_PAGE + 1
	_select(str(_rows[next].uuid))


func _set_tab(tab: String) -> void :
	if tab == _tab:
		return
	_tab = tab
	_pick = ""
	_page = 0
	if tab == "sent":
		_load_sent()
	_rebuild()


func _load_sent() -> void :
	_sent = []
	if _sent_loading:
		return
	var url: String = client.config.origin + "/getCharSendMail.php?char=%s&noCache=%d" % [client.char_uuid.uri_encode(), randi() % 1000000]
	_sent_loading = true
	if fetch.is_valid():
		fetch.call(url)
		return
	if _http.request(url, AppSession.headers(url)) != OK:
		_sent_loading = false
		say(SENT_FAIL)


func _on_sent(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	_sent_loading = false
	if not is_visible_in_tree():
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_sent = []
		if _tab == "sent":
			say(SENT_FAIL)
	else:
		_sent = MailModel.sent_rows(body)
	if _tab == "sent":
		_pick = ""
		_page = 0
		_rebuild()


func _go(page: int) -> void :
	var pages: int = _page_count()
	if pages == 0:
		return
	var want: int = clampi(page, 1, pages)
	if want == _page:
		return
	_page = want
	_pick = ""

func _close() -> void :
	_sheet_id = ""
	_doomed = ""

func _send(kind: String, sent: bool, sorry: String) -> void :
	if sent:
		_wait = kind
		_wait_at = _time
	else:
		say(sorry)


func _remove(uuid: String) -> void :
	var mail: Dictionary = MailModel.find(client.mails, uuid)
	if mail.is_empty():
		return
	if bool(mail.gift):
		say(KEEP_GIFT)
	elif _busy():
		say(BUSY)
	else:
		_sheet_id = "delete"
		_doomed = uuid

func _claim() -> void :
	if _busy():
		say(BUSY)
	else:
		_send("claim", client.claim_mail(_pick), "Chưa nhận được quà lúc này.")

func _confirm() -> void :
	var kind: String = _sheet_id
	var uuid: String = _doomed
	_close()
	match kind:
		"delete":
			_send("delete", client.delete_mail(uuid), "Chưa xoá được thư lúc này.")
		"clear":
			_send("clear", client.delete_read_mails(), "Chưa xoá được thư lúc này.")

func _on_result(ok: bool, op: int, uuid: String) -> void :
	if not is_visible_in_tree():
		return
	_wait = ""
	match op:
		4:
			if not ok and uuid == _pick:
				_pick = ""
				say("Thư này không còn nữa.")
				client.request_mails()
		5:
			if ok and not uuid.is_empty():
				say("Đã xoá thư.")
		8:
			if not ok and not uuid.is_empty():
				say("Chưa nhận được quà.")
		3:

			if ok:
				say(SENT_OK)
				_clear_write()

func _can_claim_all() -> bool:
	return int(_counts[2]) > 0 and not _busy()

func _can_clear() -> bool:
	return MailModel.has_clearable(client.mails) and not _busy()




func _open_write(receiver: String) -> void :
	if int(client.character.get("level", 1)) < WRITE_LEVEL:
		say(LOW_LEVEL)
		return
	_tip = []
	_writing = true
	_wfl_close()
	_clear_write()
	_to.text = receiver
	_note.visible = false


func _close_write() -> void :
	_writing = false
	_wfl_close()
	if _body != null:
		_hide_edits()
		_body.visible = false
		_body.release_focus()


func _clear_write() -> void :
	_to.text = ""
	_subject.text = ""
	_body.text = ""
	_body_prev = ""



func _send_write() -> void :
	var receiver: String = _to.text
	if receiver.strip_edges().is_empty():
		say(NEED_NAME)
	elif receiver == str(client.character.get("name", "")):
		say(NOT_SELF)
	elif _subject.text.strip_edges().is_empty():
		say(NEED_TITLE)
	elif _body.text.strip_edges().is_empty():
		say(NEED_TEXT)
	elif not client.send_mail(receiver, _subject.text, _body.text):
		say("Chưa gửi được thư lúc này.")


func _body_cap() -> void :
	var now: String = _body.text
	if now.length() <= TEXT_MAX or now.length() <= _body_prev.length():
		_body_prev = now
		return
	var head: int = 0
	var limit: int = mini(now.length(), _body_prev.length())
	while head < limit and now[head] == _body_prev[head]:
		head += 1
	var tail: int = 0
	while tail < limit - head and now[now.length() - 1 - tail] == _body_prev[_body_prev.length() - 1 - tail]:
		tail += 1
	var added: String = now.substr(head, now.length() - head - tail)
	var room: int = maxi(0, TEXT_MAX - (now.length() - added.length()))
	var kept: String = now.left(head) + added.left(room) + now.right(tail)
	var caret: int = head + mini(room, added.length())
	_body_prev = kept
	_body.text = kept
	var before: String = kept.left(mini(caret, kept.length()))
	_body.set_caret_line(before.count("\n"))
	_body.set_caret_column(before.length() - (before.rfind("\n") + 1))

func _body_scroll(lines: float) -> void :
	var bar: VScrollBar = _body.get_v_scroll_bar()
	_body.scroll_vertical = clampf(_body.scroll_vertical + lines, 0.0, maxf(0.0, bar.max_value - bar.page))


func _wfl_toggle() -> void :
	if _wfl:
		_wfl_close()
		return
	_wfl = true
	_wfl_list = []
	for brief: Variant in client.friends.values():
		if brief is Dictionary:
			_wfl_list.append(brief)
	_wfl_top = 0

func _wfl_close() -> void :
	_wfl = false
	_wfl_list = []
	_wfl_top = 0
	_wfl_rect = Rect2()
	_wfl_rows = Rect2()
	_thumbs.erase("wfl")


func _wfl_pick(index: int) -> void :
	if index < 0 or index >= _wfl_list.size():
		return
	_to.text = str((_wfl_list[index] as Dictionary).get("m_name", ""))
	_to.caret_column = _to.text.length()
	_wfl_close()

func _wfl_scroll(step: int) -> void :
	_wfl_top = ChatFriend.first(_wfl_top + step, _wfl_list.size())


func _slide_rate(id: String, span: float) -> float:
	var parts: Array = _thumbs.get(id, [])
	if parts.is_empty():
		return 0.0
	var room: float = (parts[1] as Rect2).size.y - (parts[0] as Rect2).size.y
	return span / room if room > 0.0 else 0.0

func _wheel(step: int, at: Vector2) -> void :
	if not _writing:
		return
	if _wfl and _wfl_rect.has_point(at):
		_wfl_scroll(step * ChatFriend.WHEEL)
	elif _thumbs.has("wb") and (_thumbs["wb"][1] as Rect2).grow(ChatFriend.BAR * _f).has_point(at):
		_body_scroll(step * 3)


func _drag(moved: Vector2, from: Vector2) -> void :
	if not _writing:
		return
	if from != _drag_from:
		_drag_from = from
		_drag_sum = 0.0
		_drag_first = float(_body.scroll_vertical)
		if _wfl:
			_drag_first = float(_wfl_top)
	_drag_sum += moved.y
	var count: int = _wfl_list.size()
	if _wfl and _thumbs.has("wfl") and (_thumbs["wfl"][0] as Rect2).has_point(from):
		_wfl_top = ChatFriend.first(roundi(_drag_first + _drag_sum * _slide_rate("wfl", count - ChatFriend.ROWS)), count)
	elif _wfl and _mobile and _wfl_rows.has_point(from):
		_wfl_top = ChatFriend.first(roundi(_drag_first - _drag_sum / (ChatFriend.ROW * _f)), count)
	elif not _wfl and _thumbs.has("wb") and (_thumbs["wb"][0] as Rect2).has_point(from):
		var bar: VScrollBar = _body.get_v_scroll_bar()
		_body.scroll_vertical = clampf(_drag_first + _drag_sum * _slide_rate("wb", bar.max_value - bar.page), 0.0, maxf(0.0, bar.max_value - bar.page))

func _activate_write(id: String) -> void :
	if id.begins_with("wfl_row:"):
		_wfl_pick(int(id.substr(8)))
		return
	var page: float = maxf(1.0, _body.get_v_scroll_bar().page)
	match id:
		"w:close":
			_close_write()
		"w:send":
			_send_write()
		"w:friend":
			_wfl_toggle()
		"wfl_close":
			_wfl_close()
		"wfl:up":
			_wfl_scroll(-1)
		"wfl:down":
			_wfl_scroll(1)
		"wfl:pgup":
			_wfl_scroll( - ChatFriend.ROWS)
		"wfl:pgdn":
			_wfl_scroll(ChatFriend.ROWS)
		"wb:up":
			_body_scroll(-1.0)
		"wb:down":
			_body_scroll(1.0)
		"wb:pgup":
			_body_scroll( - page)
		"wb:pgdn":
			_body_scroll(page)

func _activate(id: String) -> void :
	if _writing:
		_activate_write(id)
		return
	if not _sheet_id.is_empty():
		match id:
			"ask_ok":
				_confirm()
			"ask_no":
				_close()
		return
	if id.begins_with("mail:"):
		_select(id.substr(5))
		return
	if id.begins_with("del:"):
		_remove(id.substr(4))
		return
	if id.begins_with("gift:"):
		_claim()
		return
	match id:
		"close":
			closed.emit()
		"tab:all", "tab:unread", "tab:sent":
			_set_tab(id.substr(4))
		"reply":

			var mail: Dictionary = _mail()
			if not mail.is_empty():
				_open_write(str(mail.get("sender", "")))
		"friend":
			_add_friend()
		"write":
			_open_write("")
		"prev":
			_go(_page - 1)
		"next":
			_go(_page + 1)
		"claimall":
			_send("claimall", client.claim_all_mails(), "Chưa nhận được quà lúc này.")
		"clear":
			_sheet_id = "clear"
		"off:claimall":
			say(BUSY if _busy() else "Không có quà nào để nhận.")
		"off:clear":
			say(BUSY if _busy() else "Không có thư đã đọc nào để xoá.")

func _input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		return
	if not _sheet_id.is_empty():
		_close()
		get_viewport().set_input_as_handled()
	elif _writing:

		_close_write()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or _writing or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	match event.keycode:
		KEY_ESCAPE:
			closed.emit()
		KEY_UP:
			_step(-1)
		KEY_DOWN:
			_step(1)
		KEY_LEFT, KEY_PAGEUP:
			_go(_page - 1)
		KEY_RIGHT, KEY_PAGEDOWN:
			_go(_page + 1)
		_:
			return
	get_viewport().set_input_as_handled()



func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))


func _spot(id: String) -> Vector2:
	return _v(Atlas.NODES[id])


func _wide(text: String, px: float) -> float:
	return ARIAL_BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f


func _fit_text(text: String, px: float, wide: float) -> String:
	if _wide(text, px) <= wide:
		return text
	var low: int = 0
	var high: int = text.length()
	while low < high:
		var mid: int = (low + high + 1) / 2
		if _wide(text.substr(0, mid).strip_edges() + "...", px) <= wide:
			low = mid
		else:
			high = mid - 1
	return text.substr(0, low).strip_edges() + "..."


func _fit_rect(texture: Texture2D, rect: Rect2) -> Rect2:
	var full: Vector2 = texture.get_size()
	if full.x <= 0.0 or full.y <= 0.0:
		return rect
	var ratio: float = minf(rect.size.x / full.x, rect.size.y / full.y)
	var shown: Vector2 = full * ratio
	return Rect2(rect.position + (rect.size - shown) / 2.0, shown)


func _toggle(id: String, cell_name: String, at: Vector2, enabled: bool, off_hit: bool = false) -> Rect2:
	if enabled:
		return _fbutton(id, cell_name, at)
	var rect: Rect2 = _fblit(cell_name, at, 0.0, 0.0, OFF)
	if off_hit:
		_hit("off:" + id, rect, false)
	return rect

func _paint() -> void :
	if _cells.is_empty():
		_load_cells()
	_tip = []
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(SIZE.x, SIZE.y)
	if _writing:
		_note.visible = false
		_draw_write(base)
		return
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_fblit("ml_frame", base + _v(Atlas.FRAME))
	_draw_tabs(base)
	_draw_list(base)
	_draw_pager(base)
	_draw_detail(base)
	_draw_foot(base)
	_fbutton("close", "ml_close", base + _spot("btnClose"))
	if _sheet_id.is_empty():
		_draw_tip()
	else:
		_note.visible = false
		_draw_ask()


func _load_cells() -> void :
	_use(Atlas.FILE, Atlas.R)
	var cells: Dictionary = {}
	for key: String in ["chatf_quick_bk", "chatf_quick_close", "chatf_sb_up", "chatf_sb_down", "chatf_sb_bk", "chatf_sb_thumb"]:
		cells[key] = ChatAtlas.R[key]
	_use(ChatAtlas.FILE, cells)
	_use(ChatFriendAtlas.FILE, {"chatfr_select_t": ChatFriendAtlas.R["chatfr_select_t"]})
	cells = {}
	for level in range(41):
		cells["level_%d" % level] = Hall.R["level_%d" % level]
	_use(Hall.FILE, cells)
	cells = {}
	for level in range(1, 16):
		for key: String in ["lb_v%d" % level, "lb_sv%d" % level]:
			if Leader.R.has(key):
				cells[key] = Leader.R[key]
	_use(Leader.FILE, cells)


func _draw_tabs(base: Vector2) -> void :
	_fbutton("tab:all", "ml_tab_all_on" if _tab == "all" else "ml_tab_all_off", base + _spot("btnMailList"))
	_fbutton("tab:unread", "ml_tab_unread_on" if _tab == "unread" else "ml_tab_unread_off", base + _spot("btnUnreadMail"))
	_fbutton("tab:sent", "ml_tab_sent_on" if _tab == "sent" else "ml_tab_sent_off", base + _spot("btnSendedMail"))


func _draw_list(base: Vector2) -> void :
	var top: Vector2 = base + _v(Atlas.NODES["lstMail"])
	var wide: float = float(Atlas.NODES["lstMail"][2])
	var loading: bool = _sent_loading if _tab == "sent" else not client.mail_loaded
	if loading or _rows.is_empty():
		var text: String = "Đang tải thư…" if loading else str(MailModel.EMPTY.get(_tab, ""))
		_fwords(text, ARIAL_BOLD, 14.0, Color.WHITE, "c", top + Vector2(0, 160), wide, 1.0, 24.0)
		return
	var now: int = int(Time.get_unix_time_from_system())
	var shown: Array = _page_rows()
	for i in range(shown.size()):
		var mail: Dictionary = shown[i]
		var uuid: String = str(mail.uuid)
		var at: Vector2 = top + Vector2(0, PITCH * i)
		var high: float = minf(ROW_SIZE.y, LIST_HIGH - PITCH * i)
		var id: String = "mail:" + uuid
		_fpart("ml_row_on" if uuid == _pick else "ml_row", at, Rect2(Vector2.ZERO, Vector2(ROW_SIZE.x, high)), _glow(id))
		var envelope: String = _envelope(mail)
		_fblit(envelope, (at + Vector2(35, 30.5) - _cell_size(envelope) / 2.0).floor())
		_fwords(_fit_text(str(_name(uuid)[0]), 16.0, 300.0), ARIAL_BOLD, 16.0, INK, "l", at + Vector2(70, 8.5), 300.0, 0.0, 24.0)
		var left: String = _left_text(mail, now)
		var left_w: float = _wide(left, 13.0)
		_fwords(left, ARIAL_BOLD, 13.0, INK, "r", at + Vector2(394.0 - left_w - 2.0, 35.5), left_w + 2.0, 0.0, 20.0)
		var room: float = 394.0 - left_w - 10.0 - 70.0
		_fwords(_fit_text(_sender_text(uuid), 13.0, room), ARIAL_BOLD, 13.0, INK, "l", at + Vector2(70, 35.5), room, 0.0, 20.0)
		_hit(id, Rect2(at * _f, Vector2(ROW_SIZE.x, high) * _f), false)
		if _tab == "sent":
			continue
		var x: Rect2 = _fbutton("del:" + uuid, "ml_row_x", at + _v(Atlas.ROW["btnClose"]))
		if _hover == "del:" + uuid:
			_tip = [x, DELETE_TIP, "", Color.WHITE]



func _envelope(mail: Dictionary) -> String:
	if _tab == "sent":
		return "ml_env_close"
	if bool(mail.get("gift", false)):
		return "ml_env_item"
	var system: bool = _system(mail)
	if bool(mail.get("unread", false)):
		return "ml_env_sys_close" if system else "ml_env_close"
	return "ml_env_sys_open" if system else "ml_env_open"


func _draw_pager(base: Vector2) -> void :
	var pages: int = _page_count()
	_toggle("prev", "ml_prev", base + _spot("btnMailLast"), _page > 1)
	_toggle("next", "ml_next", base + _spot("btnMailNext"), pages > 1 and _page < pages)
	var spec: Array = Atlas.TEXT["lblPageNum"]
	_fwords("%d/%d" % [_page, pages], ARIAL_BOLD, float(spec[4]), Color.WHITE, "c", base + Vector2(float(spec[0]), float(spec[1])), float(spec[2]), 1.0)


func _draw_detail(base: Vector2) -> void :
	if _tab == "sent":
		_draw_sent_detail(base)
		return
	_fblit("ml_from_label", base + _spot("mailpalyernameimage"))
	_fblit("ml_hint_icon", base + _spot("image1"))
	_fpara(HINT, ARIAL_BOLD, float(Atlas.TEXT["text1"][4]), Color.WHITE, base + _v(Atlas.TEXT["text1"]), float(Atlas.TEXT["text1"][2]) + 20.0, 2)
	var mail: Dictionary = _mail()
	if mail.is_empty():
		_note.visible = false
		return
	var names: Array = _name(_pick)
	_fwords(_fit_text(str(names[1]), 14.0, 290.0), ARIAL, 14.0, Color.WHITE, "l", base + _v(Atlas.TEXT["lblSenderName"]), 290.0)
	_fwords(_fit_text(str(names[0]), 14.0, 290.0), ARIAL, 14.0, Color.WHITE, "l", base + _v(Atlas.TEXT["lblMailTitle"]), 290.0)
	var system: bool = _system(mail)
	if system:
		_fblit("ml_sys_tip", base + _spot("imgSysTip"))
	else:
		var warn: Array = Atlas.TEXT["lblSysTip"]
		_fwords(NOT_OFFICIAL, ARIAL_BOLD, float(warn[4]), Color("ff0000"), "r", base + _v(warn), float(warn[2]), 0.0, float(warn[3]))
	if not _friend(str(names[1])):
		_toggle("friend", "ml_add_friend", base + _spot("btnAddFriend"), not system)
	var content: Array = Atlas.NODES["txtMailContent"]
	if not client.mail_bodies.has(_pick):
		_note.visible = false
		_fwords("Đang mở thư…", ARIAL_BOLD, 14.0, INK, "l", base + _v(content), float(content[2]))
		return
	var raw: String = str(client.mail_bodies[_pick].get("text", ""))
	if raw != _words_of:
		_words_of = raw
		_words = _body_markup(raw)
	_place_note(_pick, _words, Rect2(base + _v(content), Vector2(float(content[2]), float(content[3]))))
	var gifts: Array = _gifts()
	for i in range(mini(gifts.size(), GRIDS.size())):
		var rest: Array = gifts.slice(GRIDS.size()) if i == GRIDS.size() - 1 else []
		_draw_gift(gifts[i], base + _spot(GRIDS[i]), "gift:%d" % i, rest)



func _draw_sent_detail(base: Vector2) -> void :
	var mail: Dictionary = _sent_mail()
	if mail.is_empty():
		_note.visible = false
		return
	var names: Array = _name(_pick)
	_fwords(_fit_text(str(names[1]), 14.0, 290.0), ARIAL, 14.0, Color.WHITE, "l", base + _v(Atlas.SENT["lblReceiverName"]), 290.0)
	_fwords(_fit_text(str(names[0]), 14.0, 290.0), ARIAL, 14.0, Color.WHITE, "l", base + _v(Atlas.SENT["lblMailTitle"]), 290.0)
	var content: Array = Atlas.SENT["txtMailContent"]
	var raw: String = str(mail.get("text", ""))
	if raw != _words_of:
		_words_of = raw
		_words = _body_markup(raw.replace("#ENTER#", "\n"))
	_place_note("sent:" + _pick, _words, Rect2(base + _v(content), Vector2(float(content[2]), float(content[3]))))



func _draw_gift(gift: Dictionary, at: Vector2, id: String, rest: Array) -> void :
	_fblit("ml_item_bg", at + Vector2(1, 1), 0.0, 0.0, _glow(id))
	var icon: Rect2 = Rect2((at + Vector2(3, 3)) * _f, Vector2(50, 50) * _f)
	var picture: Texture2D = null
	if bool(gift.coin):
		var coins: Array = pack.lobby.get("coins", [])
		if coins.size() > 2 and not str(coins[2]).is_empty():
			picture = pack.picture("l/c/%s.webp" % coins[2])
	elif bool(gift.head):
		_avatar(int(gift.id), icon)
	elif not str(gift.icon).is_empty():
		picture = pack.picture("l/it/%s.webp" % gift.icon)
	if picture != null and picture.get_width() > 4:
		draw_texture_rect(picture, _fit_rect(picture, icon), false)
	var count: int = int(gift.count)
	if count > 1:
		_fwords(str(count), ARIAL_BOLD, 12.0, Color.WHITE, "r", at + Vector2(0, 37), 53.0, 1.0, 18.0)
	if not rest.is_empty():
		_fwords("+%d" % rest.size(), ARIAL_BOLD, 12.0, Color("ffe14d"), "l", at + Vector2(4, 2), 40.0, 1.0, 16.0)
	var rect: Rect2 = Rect2(at * _f, Vector2(55, 55) * _f)
	_hit(id, rect, false)
	if _hover == id and not bool(gift.coin) and rest.is_empty():
		_tip = [rect, "", "", Color.WHITE, FlashTip.simulate(int(gift.id), pack.bag, {"name": str(gift.name), "quality": int(gift.quality)})]
	elif _hover == id:
		var quality: int = int(gift.quality)
		var lines: PackedStringArray = PackedStringArray()
		var grade: String = BagModel.quality_name(quality)
		if not grade.is_empty():
			lines.append(grade)
		lines.append("Số lượng: %d" % count)
		for more: Dictionary in rest:
			lines.append("%s ×%d" % [GarageModel.cap(str(more.name)), int(more.count)])
		_tip = [rect, GarageModel.cap(str(gift.name)), "\n".join(lines), BagModel.tint(quality, Color.WHITE)]


func _place_note(key: String, markup: String, rect: Rect2) -> void :
	_note.position = rect.position * _f
	_note.size = rect.size * _f
	var px: int = maxi(6, roundi(14.0 * _f))
	if px != _note_px:
		_note_px = px
		_note.add_theme_font_size_override("normal_font_size", px)
		_note.add_theme_font_size_override("bold_font_size", px)
		_note.add_theme_constant_override("line_separation", maxi(1, roundi(2.0 * _f)))
	if key != _note_key or _note.text != markup:
		_note_key = key
		_note.text = markup
		_note.scroll_to_line(0)
	_note.visible = not markup.is_empty()


func _draw_foot(base: Vector2) -> void :
	_fbutton("write", "ml_write", base + _spot("btnWriteMail"))
	if _tab == "sent":
		return
	_fblit("ml_base", base + _spot("base_reply"))
	var mail: Dictionary = _mail()
	_toggle("reply", "ml_reply", base + _spot("btnReply"), mail.is_empty() or not _system(mail))
	_blue("clear", "Xoá thư đã đọc", base + EXTRA["clear"], _can_clear())
	_blue("claimall", "Nhận tất cả", base + EXTRA["claimall"], _can_claim_all())


func _blue(id: String, text: String, at: Vector2, enabled: bool) -> void :
	_toggle(id, "ml_blue", at, enabled, true)
	_fwords(text, ARIAL_BOLD, 13.0, Color.WHITE if enabled else Color(0.85, 0.85, 0.85, 1.0), "c", at + Vector2(5, 0), 90.0, 1.0, 33.0, true, Color("0b4f8a"))


func _draw_tip() -> void :
	if FlashTip.show(self, _tip, _ctip):
		return
	var anchor: Rect2 = _tip[0]
	var body: String = str(_tip[2])
	var wide: float = 200.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 10).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), ARIAL_BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, ARIAL, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 10)


func _draw_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("ask_shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(450.0, 220.0)
	_hit("ask_panel", Rect2(at * _f, Vector2(450.0, 220.0) * _f), false)
	_fblit("ml_ask_guy", at + Vector2(-80, -76))
	_fblit("ml_ask", at + _v(Atlas.PANELS["ask"]))
	var text: Array = Atlas.ASK["txtContent"]
	_fpara(ASK_CLEAR if _sheet_id == "clear" else ASK_DELETE, ARIAL_BOLD, float(text[4]), Color.WHITE, at + _v(text), float(text[2]), 5)
	_fbutton("ask_ok", "ml_ask_ok", at + _v(Atlas.ASK["btnConfirm"]))
	_fbutton("ask_no", "ml_ask_no", at + _v(Atlas.ASK["btnCancel"]))



func _draw_write(base: Vector2) -> void :
	var at: Vector2 = base + WRITE_AT
	_hit("panel", Rect2(at * _f, WRITE_SIZE * _f), false)
	_fblit("wr_frame", at + _v(Atlas.WFRAME))
	_fbutton("w:friend", "wr_friend", at + _v(Atlas.WRITE["btnFriend"]))
	_fbutton("w:send", "wr_send", at + _v(Atlas.WRITE["btnSend"]))
	_fbutton("w:close", "wr_close", at + _v(Atlas.WRITE["btnClose"]))
	_fput(_to, Rect2(at + TO_EDIT.position, TO_EDIT.size), 14.0)
	var bar: VScrollBar = _body.get_v_scroll_bar()
	_draw_bar("wb", at.x + BODY_EDIT.end.x, at.y + BODY_EDIT.position.y, at.y + BODY_EDIT.end.y, bar.max_value if bar.visible else 0.0, bar.page, bar.value)
	if not _wfl:
		_fput(_subject, Rect2(at + TITLE_EDIT.position, TITLE_EDIT.size), 14.0)
		_place_body(Rect2(at + BODY_EDIT.position, BODY_EDIT.size))
		return
	for edit: Control in [_subject, _body]:
		if edit.visible:
			edit.visible = false
			edit.release_focus()
	_fwords(_subject.text, ARIAL, 14.0, Color.WHITE, "l", at + TITLE_EDIT.position, TITLE_EDIT.size.x, 0.0, TITLE_EDIT.size.y, false)
	_fpara(_body.text, ARIAL, 14.0, INK, at + BODY_EDIT.position + Vector2(2, 2), BODY_EDIT.size.x - 4.0, 13)
	_draw_write_friends(at + FRIENDS_AT)


func _place_body(rect: Rect2) -> void :
	_body.position = rect.position * _f
	_body.size = rect.size * _f
	var px: int = maxi(6, roundi(14.0 * _f))
	if _body.get_theme_font_size("font_size") != px:
		_body.add_theme_font_size_override("font_size", px)
		_body.add_theme_constant_override("line_spacing", maxi(0, roundi(_f)))
	var pad: float = 2.0 * _f
	if not is_equal_approx(_body_box.content_margin_left, pad):
		for side: int in [SIDE_LEFT, SIDE_TOP, SIDE_RIGHT, SIDE_BOTTOM]:
			_body_box.set_content_margin(side, pad)
	if not _body.visible:
		_body.visible = true



func _draw_write_friends(at: Vector2) -> void :
	var box: Rect2 = _fblit("chatf_quick_bk", at, ChatFriend.SIZE.x, ChatFriend.SIZE.y)
	_wfl_rect = box
	_hit("panel", box, false)
	_fblit("chatfr_select_t", at + ChatFriend.TAB)
	_fbutton("wfl_close", "chatf_quick_close", at + ChatFriend.CLOSE)
	var list: Vector2 = at + ChatFriend.LIST.position
	var wide: float = ChatFriend.LIST.size.x - ChatFriend.BAR
	var count: int = _wfl_list.size()
	_wfl_top = ChatFriend.first(_wfl_top, count)
	_wfl_rows = Rect2(list * _f, Vector2(wide, ChatFriend.LIST.size.y) * _f)
	for i in range(_wfl_top, mini(count, _wfl_top + ChatFriend.ROWS)):
		var brief: Dictionary = _wfl_list[i]
		var id: String = "wfl_row:%d" % i
		var o: Vector2 = list + Vector2(0, ChatFriend.ROW * (i - _wfl_top))
		var row: Rect2 = Rect2(o * _f, Vector2(wide, ChatFriend.ROW) * _f)
		if _press == id:
			draw_rect(row, ChatFriend.PICK)
		elif _hover == id and _press.is_empty() and _tip_ok():
			draw_rect(row, ChatFriend.HOVER)
		var mid: float = ChatFriend.ROW / 2.0
		_fblit(ChatFriend.level_cell(int(brief.get("m_level", 0))), o + Vector2(0, mid - ChatFriend.LEVEL.y / 2.0), ChatFriend.LEVEL.x, ChatFriend.LEVEL.y)
		_level_fx(int(brief.get("m_level", 0)), o + Vector2(0, mid - ChatFriend.LEVEL.y / 2.0), ChatFriend.LEVEL.x)
		var who: String = MailModel.printable(str(brief.get("m_name", "")), ARIAL_BOLD)
		_fwords(_fit_text(who, ChatFriend.FONT, ChatFriend.NAME_W - 2.0 * ChatFriend.PAD), ARIAL_BOLD, ChatFriend.FONT, Color.WHITE, "l", 
			o + Vector2(ChatFriend.NAME_X + ChatFriend.PAD, 0), ChatFriend.NAME_W, 1.0, 0.0, false, ChatFriend.GLOW)
		_fwords(ChatFriend.sex(int(brief.get("m_sex", 0))), ARIAL_BOLD, ChatFriend.FONT, Color.WHITE, "l", o + Vector2(ChatFriend.SEX_X + ChatFriend.PAD, 0), 
			ChatFriend.RENDER_W - ChatFriend.SEX_X, 1.0, 0.0, false, ChatFriend.GLOW)
		var vip: String = ChatFriend.vip_cell(int(brief.get("m_vipLevel", 0)))
		if not vip.is_empty():
			_fblit(vip, o + Vector2(ChatFriend.VIP_X, roundf(mid - _cell_size(vip).y / 2.0)))
		_hit(id, row, false)
	_draw_bar("wfl", list.x + wide, list.y, list.y + ChatFriend.LIST.size.y, float(count), float(ChatFriend.ROWS), float(_wfl_top))



func _draw_bar(id: String, x: float, y0: float, y1: float, total: float, page: float, value: float) -> void :
	var bar: float = ChatFriend.BAR
	_hit(id + ":up", _fblit("chatf_sb_up", Vector2(x, y0), bar, bar, _glow(id + ":up")), false)
	_hit(id + ":down", _fblit("chatf_sb_down", Vector2(x, y1 - bar), bar, bar, _glow(id + ":down")), false)
	var track: Rect2 = _fblit("chatf_sb_bk", Vector2(x, y0 + bar), bar, y1 - y0 - bar * 2.0)
	_thumbs.erase(id)
	if total <= page:
		return
	var grip: float = maxf(10.0 * _f, track.size.y * page / total)
	var y: float = track.position.y + (track.size.y - grip) * clampf(value / (total - page), 0.0, 1.0)
	_hit(id + ":pgup", Rect2(track.position, Vector2(track.size.x, maxf(0.0, y - track.position.y))), false)
	_hit(id + ":pgdn", Rect2(Vector2(track.position.x, y + grip), Vector2(track.size.x, maxf(0.0, track.end.y - y - grip))), false)
	var thumb: Rect2 = Rect2(track.position.x, y, track.size.x, grip)
	_thumbs[id] = [thumb, track]
	var cell: Array = _cells.get("chatf_sb_thumb", [])
	if not cell.is_empty() and cell[0] != null:
		var tex: Texture2D = cell[0]
		var src: Rect2 = Rect2(float(cell[1][0]), float(cell[1][1]), float(cell[1][2]), float(cell[1][3]))
		var cap: float = minf(4.0 * _f, grip / 2.0)
		var tint: Color = _glow(id + ":thumb")
		draw_texture_rect_region(tex, Rect2(thumb.position, Vector2(thumb.size.x, cap)), Rect2(src.position, Vector2(src.size.x, 4)), tint)
		draw_texture_rect_region(tex, Rect2(thumb.position + Vector2(0, cap), Vector2(thumb.size.x, grip - cap * 2.0)), Rect2(src.position + Vector2(0, 4), Vector2(src.size.x, src.size.y - 8.0)), tint)
		draw_texture_rect_region(tex, Rect2(thumb.position + Vector2(0, grip - cap), Vector2(thumb.size.x, cap)), Rect2(src.position + Vector2(0, src.size.y - 4.0), Vector2(src.size.x, 4)), tint)
	_hit(id + ":thumb", thumb, false)
