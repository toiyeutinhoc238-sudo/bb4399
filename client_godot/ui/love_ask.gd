extends "flash_screen.gd"











const FriendsAtlas = preload("friends_atlas.gd")
const Love = preload("love.gd")
const SCRIPT_PATH: String = "res://ui/love_ask.gd"
const NODE_NAME: String = "LoveAsk"
const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const ASK_SIZE: Vector2 = Vector2(450, 220)
const ASK_CELLS: Array = ["fr_ask", "fr_ask_guy", "fr_ask_ok", "fr_ask_no"]
const TEXT_AT: Vector2 = Vector2(102, 38)
const TEXT_WIDE: float = 270.0
const OK_AT: Vector2 = Vector2(120, 133)
const NO_AT: Vector2 = Vector2(240, 133)
const ONLY_AT: Vector2 = Vector2(180, 133)
const MODES: Array = ["invite", "breakup", "propose", "answer", "divorce", "buy", "upgrade", "unbook"]
const NOTE_KIND: Dictionary = {"divorce": "breakup", "buy": "ring_buy", "upgrade": "ring_up"}

var mode: String = ""
var target: String = ""
var acct: int = 0
var extra: int = 0
var phase: String = ""
var reply: String = ""
var _state: String = ""
var _rev: int = -1


static func open_for(host: Control, kind: String, who: String, account: int = 0, tier: int = 0) -> Control:
	if host == null or host.client == null or host.pack == null or host.get_parent() == null:
		return null
	var parent: Node = host.get_parent()
	var view: Control = parent.get_node_or_null(NODE_NAME) as Control
	if view == null:
		view = load(SCRIPT_PATH).new()
		view.name = NODE_NAME
		view.client = host.client
		view.pack = host.pack
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		parent.add_child(view)
	elif view.visible:
		return null
	view.client = host.client
	view.pack = host.pack
	parent.move_child(view, parent.get_child_count() - 1)
	return view if view.open(kind, who, account, tier) else null

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	var ask: Dictionary = {}
	for cell: String in ASK_CELLS:
		ask[cell] = FriendsAtlas.R[cell]
	_use(FriendsAtlas.FILE, ask)

func open(kind: String, who: String, account: int = 0, tier: int = 0) -> bool:
	if visible or client == null or not kind in MODES:
		return false
	if kind == "invite" and (who.strip_edges().is_empty() or who == str(client.character.get("name", ""))):
		return false
	mode = kind
	target = who.strip_edges()
	acct = account
	extra = tier
	phase = ""
	reply = ""
	_state = client.state
	Love.take([note_kind(), "peek"])
	if mode == "invite" and acct > 0:
		Love.peek(client, acct)
	visible = true
	var view: Viewport = get_viewport()
	if view != null:
		view.gui_release_focus()
	queue_redraw()
	return true

func close() -> void :
	if not visible:
		return
	visible = false
	phase = ""
	reply = ""
	mode = ""
	extra = 0


func note_kind() -> String:
	return str(NOTE_KIND.get(mode, mode))

func _tick(_delta: float) -> void :
	if client == null or client.state != _state:
		close()
		return
	if phase == "wait":
		for note: Dictionary in Love.take([note_kind()]):
			reply = str(note.get("text", ""))
			phase = "done"
	if _rev != Love.rev:
		_rev = Love.rev
		queue_redraw()


func ask_text() -> String:
	if phase == "wait":
		return "Đang gửi…"
	if phase == "done":
		return reply
	if mode == "breakup":
		return "Chia tay với %s?\nSau khi chia tay phải chờ %d ngày mới tỏ tình lại được, độ thân mật của hai bạn về 0." % [
			target if not target.is_empty() else "Người Yêu", Love.rule("breakupWaitDays", 7)]
	if mode != "invite":
		return wed_text()
	var lines: Array = ["Tỏ tình với %s?" % target]
	var info: Dictionary = Love.peek_of(acct)
	var need: int = int(info.get("need", Love.need()))
	if acct > 0 and info.is_empty():
		lines.append("Đang xem độ thân mật…")
	elif not info.is_empty():
		if info.get("friends") == false:
			lines.append("Hai bạn cần là bạn bè trước.")
		lines.append("Thân mật: %d/%d" % [int(info.get("points", 0)), need])
		if int(info.get("points", 0)) < need:
			lines.append("Cần đủ %d thân mật (đấu chung đội, tặng quà)." % need)
	else:
		lines.append("Cần là bạn bè và đủ %d thân mật." % need)
	return "\n".join(lines)


func wed_text() -> String:
	var who: String = target if not target.is_empty() else "người ấy"
	var ring_name: String = Love.ring_name(extra)
	match mode:
		"propose":
			return "Cầu hôn %s bằng %s?\nĐồng ý → hai bạn thành Vợ Chồng. Từ chối → nhẫn vẫn trong túi, %d giờ sau mới cầu hôn lại." % [
				who, ring_name, Love.wrule("proposeRejectHours", 24)]
		"answer":
			return "Đồng ý lời cầu hôn của %s?\n%s thành nhẫn cưới, hai bạn thành Vợ Chồng." % [who, ring_name]
		"divorce":
			return "Ly hôn với %s?\nNhẫn cưới sẽ MẤT (không hoàn tiền), chờ %d ngày mới có đôi mới, độ thân mật về 0." % [
				target if not target.is_empty() else "Vợ/Chồng", Love.rule("breakupWaitDays", 7)]
		"buy":
			var r: Dictionary = Love.ring(extra)
			return "Mua %s giá %s?\nĐang có %d chiếc. Nhẫn không giao dịch, không bán lại." % [
				ring_name, Love.price_text(int(r.get("price", 0)), str(r.get("curName", ""))), Love.bag_n(extra)]
		"upgrade":
			var cost: Array = Love.up_cost(extra)
			return "Nâng nhẫn cưới lên %s?\nGiá %s. Nhẫn cũ đổi thành nhẫn mới, không hoàn tiền." % [
				ring_name, Love.price_text(int(cost[0]), str(cost[1]))]
		"unbook":
			return "Huỷ Lễ đường đã đặt?\nKhung giờ được trả lại, khách mời không vào được nữa."
	return ""

func _paint() -> void :
	if mode.is_empty():
		return
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(ASK_SIZE.x, ASK_SIZE.y)
	_hit("panel", Rect2(at * _f, ASK_SIZE * _f), false)
	_fblit("fr_ask", at + Vector2(46, 1))
	_fblit("fr_ask_guy", at + Vector2(-80, -76))
	_fpara(ask_text(), ARIAL_BOLD, 14, Color.WHITE, at + TEXT_AT, TEXT_WIDE, 5)
	if phase == "":
		_fbutton("ask_ok", "fr_ask_ok", at + OK_AT)
		_fbutton("ask_no", "fr_ask_no", at + NO_AT)
	elif phase == "done":
		_fbutton("ask_ok", "fr_ask_ok", at + ONLY_AT)

func _activate(id: String) -> void :
	match id:
		"ask_ok":
			if phase == "done":
				close()
			elif phase == "":
				phase = "wait"
				match mode:
					"breakup", "divorce":
						Love.breakup(client)
					"propose":
						Love.propose(client, extra, target)
					"answer":
						Love.answer(client, acct, true, target)
					"buy":
						Love.ring_buy(client, extra)
					"upgrade":
						Love.ring_up(client, extra)
					"unbook":
						Love.unbook(client, acct)
					_:
						Love.invite(client, acct, target)
				_tick(0.0)
		"ask_no":
			if phase == "":
				close()

func _input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree() or not (event is InputEventKey):
		return
	var key: InputEventKey = event
	if key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
		if phase != "wait":
			close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
