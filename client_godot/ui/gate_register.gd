extends RefCounted































const Register = preload("res://net/register_client.gd")

const SUBTITLE: String = "Tạo tài khoản mới để vào trận"
const HEADLINE: String = "Đăng ký tài khoản"
const ENTRY_TEXT: String = "CHƯA CÓ TÀI KHOẢN? ĐĂNG KÝ NGAY"

const ENTRY_WAIT: String = "MỞ ĐĂNG KÝ SAU %s"
const ENTRY_LEFT: String = "ĐĂNG KÝ NGAY · CÒN %d SUẤT"
const ENTRY_FULL: String = "ĐÃ HẾT SUẤT ĐĂNG KÝ ĐỢT NÀY"
const ENTRY_CLOSED: String = "CHƯA MỞ ĐĂNG KÝ TÀI KHOẢN"
const ENTRY_DUE: String = "ĐANG MỞ ĐĂNG KÝ…"
const ENTRY_PICK: String = "CHỌN ĐỀ TRƯỚC · MỞ SAU %s"
const POLL_OPEN_MS: int = 20000
const POLL_WAIT_MS: int = 120000
const POLL_IDLE_MS: int = 60000
var reload_jitter: Vector2i = Vector2i(300, 4000)
const SUBMIT_TEXT: String = "ĐĂNG KÝ & VÀO GAME"
const BUSY_TEXT: String = "ĐANG ĐĂNG KÝ..."
const BACK_ASK: String = "Đã có tài khoản?"
const BACK_LINK: String = "Đăng nhập"
const CAPTCHA_HINT: String = "Chạm ảnh để đổi mã"
const CAPTCHA_WAIT: String = "Đang tải…"
const CAPTCHA_RETRY: String = "Chạm để tải lại"
const DONE_TEXT: String = "Đăng ký thành công, đang vào game…"

const MAIL_ROW: Array = ["Email", "Gmail hoặc email thật để nhận mã"]
const MAIL_CODE_ROW: Array = ["Mã trong email", "6 chữ số"]
const MAIL_SEND_TEXT: String = "GỬI MÃ VỀ EMAIL"
const MAIL_SENDING_TEXT: String = "ĐANG GỬI MÃ..."
const MAIL_STEP1: String = "Bước 1/2 · mỗi email một tài khoản"
const MAIL_STEP2: String = "Bước 2/2 · mã đã gửi tới %s"
const RESEND_TEXT: String = "Gửi lại mã"
const RESEND_WAIT: String = "Gửi lại (%ds)"
const MAIL_HINT: String = "Xem cả hộp Spam / Quảng cáo"
const MAIL_MAX: int = 100

const QUIZ_PICK1: String = "Bước 1/2 · chọn lĩnh vực và mức, đúng %d/%d câu là qua"
const QUIZ_STEP1: String = "Bước 1/2 · %s · đúng %d/%d câu là qua"
const QUIZ_STEP2: String = "Bước 2/2 · đã qua đề, tạo tài khoản"
const QUIZ_TABS: Array = ["HỌC TẬP", "LOẠN CHIẾN"]
const QUIZ_GROUPS: Array = ["hoc", "game"]

const QUIZ_PICK1_ONE: String = "Bước 1/2 · chọn một ô, làm đúng là qua"
const PUZ_STEP1: String = "Bước 1/2 · %s · chạm 2 ô để đổi chỗ"
const PUZ_HEAD: String = "GHÉP HÌNH · %s · %d×%d"
const PUZ_HEAD_N: String = "HÌNH %d/%d · %s · %d×%d"
const PUZ_NEED: String = "Chạm một ô rồi chạm ô khác để đổi chỗ. Xếp đúng hình rồi hãy bấm nộp."
const PUZ_FAIL: String = "Hình xếp chưa đúng, đã xáo lại — thử lần nữa nhé."
const PUZ_FAIL_WAIT: String = "Hình xếp chưa đúng. Chờ %s rồi bấm LÀM ĐỀ để xếp hình mới."
const TAB_GAP: float = 8.0
const PIC_BOX: float = 150.0
const PIC_GAP: float = 10.0
const PUZ_TOP: float = 172.0
const QUIZ_HEAD: String = "CÂU %d/%d · %s"
const QUIZ_PREV: String = "« Câu trước"
const QUIZ_BACK: String = "« Chọn lại"
const QUIZ_START: String = "LÀM ĐỀ"
const QUIZ_NEXT: String = "CÂU TIẾP THEO"
const QUIZ_DONE: String = "NỘP BÀI"
const QUIZ_CHECKING: String = "ĐANG CHẤM BÀI..."
const QUIZ_LOADING: String = "ĐANG TẢI..."
const QUIZ_RELOAD: String = "TẢI LẠI"
const QUIZ_WAIT_ROOMS: String = "Đang tải danh sách lĩnh vực…"
const QUIZ_NO_ROOMS: String = "Chưa tải được danh sách, bấm TẢI LẠI."
const QUIZ_WAIT: String = "Đang tải đề…"
const QUIZ_CHOOSE: String = "Chọn một lĩnh vực trong danh sách."
const QUIZ_EMPTY_LV: String = "Lĩnh vực này chưa có câu mức %s, chọn mức khác."
const QUIZ_PICK: String = "Chọn một đáp án rồi bấm tiếp."
const QUIZ_FAIL: String = "Bạn đúng %d/%d câu, cần %d câu. Đã đổi đề mới cùng lĩnh vực."
const QUIZ_PAGE: String = "Trang %d/%d"

const QUIZ_EARLY_SUB: String = "Chọn trước lĩnh vực và mức · tới giờ đề tự hiện"
const QUIZ_EARLY_WAIT: String = "ĐỀ HIỆN SAU %s"
const QUIZ_EARLY_DUE: String = "ĐANG MỞ ĐỀ…"
const QUIZ_EARLY_OK: String = "Đã chọn xong, cứ để nguyên thẻ này: tới giờ đề tự hiện."
const QUIZ_EARLY_ROOMS: String = "Danh sách lĩnh vực sẽ hiện khi tới giờ mở đăng ký."
const QUIZ_FAIL_WAIT: String = "Bạn đúng %d/%d câu, cần %d câu. Chờ %s rồi bấm LÀM ĐỀ để làm đề mới."
const QUIZ_CAP_ROW: String = "Gõ 4 số trong ảnh"
const QUIZ_CAP_NEED: String = "Gõ 4 chữ số trong ảnh mã của câu này rồi bấm tiếp."
const QUIZ_HERE_HINT: String = "XANH = còn mã · ĐỎ = đã có người lấy · số = người đang ở"
const QUIZ_TAKEN: String = "Ô bạn chọn vừa có người lấy mã — chọn ô XANH khác."
const QUIZ_FULL_LV: String = "Ô này đã có người lấy mã — chọn ô XANH khác nhé."
const FREE_INK: Color = Color("3ccf6e")
const FULL_INK: Color = Color("ff5a5a")
const QUIZ_CAP_BAD: String = " Có %d câu gõ sai mã nên không được tính."
const QUIZ_CAP_NEXT: String = "Câu %d cũng gõ sai mã — gõ lại mã mới trong ảnh."

const RC_ROW: Array = ["Mã đăng ký", "Nhập mã đăng ký"]
const RC_MAX: int = 64
const RC_STEP1: String = "Bước 1/2 · nhập mã đăng ký được cấp"
const RC_STEP2: String = "Bước 2/2 · đã có mã, tạo tài khoản"
const RC_NEXT: String = "TIẾP TỤC"
const RC_BACK: String = "« Đổi mã đăng ký"
const RC_HINT: String = "Mỗi mã chỉ dùng được một lần, gõ hoa hay thường đều được"
const RC_NEED: String = "Nhập mã đăng ký để tiếp tục."
const RC_TITLE: String = "CÁC BƯỚC ĐĂNG KÝ"
const RC_TIPS: Array = ["Nhập mã đăng ký bạn được cấp", "Đặt tên tài khoản và mật khẩu", "Gõ 4 số trong ảnh rồi vào game"]
const RC_GAP: float = 8.0
const RC_LINE: float = 18.0
const RC_LINES: int = 2
const RC_BOX_Y: float = 268.0
const RC_BOX_H: float = 150.0
const QUIZ_KEYS: Array = ["A", "B", "C", "D", "E", "F"]
const TAB_Y: float = 146.0
const LV_Y: float = 184.0
const GRID_Y: float = 206.0
const PAGER_Y: float = 390.0
const PICK_H: float = 30.0
const CELL_W: float = 175.0
const CELL_H: float = 32.0
const CELL_STEP: float = 36.0
const GRID_COLS: int = 1
const GRID_ROWS: int = 5
const NAME_W: float = 158.0
const PART_X: float = 200.0
const PART_STEP: float = 65.0
const PART_W: float = 62.0
const HERE_MS: int = 5000
const HERE_STALE_MS: int = 15000
const ANS_Y: float = 240.0
const ANS_STEP: float = 50.0
const ANS_GAP: float = 8.0

const ROWS: Array = [
	["Tài khoản", "4–20 ký tự: a–z, 0–9, dấu _"], 
	["Mật khẩu", "Ít nhất 6 ký tự"], 
	["Nhập lại mật khẩu", "Gõ lại mật khẩu ở trên"], 
	["Mã xác nhận", "4 chữ số trong ảnh"], 
]

const TOP: float = 156.0
const STEP: float = 72.0
const FIELD_DY: float = 13.0
const FIELD_H: float = 44.0
const SUBMIT_Y: float = 445.0
const SUBMIT_H: float = 50.0
const BASE_H: float = 549.0
const CAPTCHA_W: float = 138.0
const CAPTCHA_FILL: Color = Color("e4e8ee")
const MAX_LINES: int = 3
const ENTRY_DY: float = 10.0
const ENTRY_H: float = 40.0
const NAME_RE: String = "^[a-z0-9_]{4,20}$"
const MIN_PASSWORD: int = 6
const MAX_PASSWORD: int = 64

var view
var net: Register
var on: bool = false
var edits: Array = []
var name_edit: LineEdit
var pass_edit: LineEdit
var again_edit: LineEdit
var code_edit: LineEdit
var captcha_id: String = ""
var captcha: ImageTexture = null
var loading: bool = false
var sending: bool = false
var error: String = ""
var focus: LineEdit = null
var opened: int = 0
var all_edits: Array = []
var email_edit: LineEdit
var mcode_edit: LineEdit
var mail_mode: bool = false
var step: int = 1
var mail_to: String = ""
var resend_at: int = 0
var _ticking: bool = false
var st: Dictionary = {}
var st_at: int = -1
var st_busy: bool = false
var open_tick: int = 0
var due_armed: bool = false
var reloads: int = 0
var _st_timer: bool = false

var clock: Callable
var reload_hook: Callable
var quiz_mode: bool = false
var rooms: Dictionary = {}
var rooms_loading: bool = false
var tab: int = 0
var pages_at: Array = [0, 0]
var room_id: String = ""
var lv: int = 0
var quiz: Dictionary = {}
var quiz_loading: bool = false
var qi: int = 0
var picks: Array = []
var quiz_token: String = ""
var early: bool = false
var early_armed: bool = false
var early_try: bool = false
var qcap_edit: LineEdit
var qcaps: Array = []
var qtex: Array = []
var qbad: Array = []
var qpic: Array = []
var zsel: int = -1
var here_at: int = -1
var here_busy: bool = false
var here_sent: Array = []
var _here_timer: bool = false
var rc_mode: bool = false
var rcode_edit: LineEdit
var rc_error: String = ""

func setup(gate) -> void :
	view = gate
	net = Register.new()
	net.name = "RegisterClient"
	gate.add_child(net)
	net.captcha_done.connect(_on_captcha)
	net.register_done.connect(_on_register)
	net.code_done.connect(_on_code)
	net.status_done.connect(_on_status)
	net.quiz_done.connect(_on_quiz)
	net.check_done.connect(_on_check)
	net.rooms_done.connect(_on_rooms)
	net.here_done.connect(_on_here)
	name_edit = gate._field(str(ROWS[0][1]), 20)
	pass_edit = gate._field(str(ROWS[1][1]), MAX_PASSWORD)
	again_edit = gate._field(str(ROWS[2][1]), MAX_PASSWORD)
	code_edit = gate._fedit(4, true)
	code_edit.placeholder_text = str(ROWS[3][1])
	code_edit.add_theme_font_override("font", gate.ARIAL)
	code_edit.add_theme_color_override("caret_color", gate.ACCENT)
	code_edit.add_theme_color_override("font_placeholder_color", gate.SOFT)
	for edit: LineEdit in [pass_edit, again_edit]:
		edit.secret = true
		edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PASSWORD
	email_edit = gate._field(str(MAIL_ROW[1]), MAIL_MAX)
	email_edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_EMAIL_ADDRESS
	mcode_edit = gate._fedit(6, true)
	mcode_edit.placeholder_text = str(MAIL_CODE_ROW[1])
	mcode_edit.add_theme_font_override("font", gate.ARIAL)
	mcode_edit.add_theme_color_override("caret_color", gate.ACCENT)
	mcode_edit.add_theme_color_override("font_placeholder_color", gate.SOFT)
	qcap_edit = gate._fedit(4, true)
	qcap_edit.placeholder_text = QUIZ_CAP_ROW
	qcap_edit.add_theme_font_override("font", gate.ARIAL)
	qcap_edit.add_theme_color_override("caret_color", gate.ACCENT)
	qcap_edit.add_theme_color_override("font_placeholder_color", gate.SOFT)
	qcap_edit.text_submitted.connect( func(_text: String) -> void : submit())
	rcode_edit = gate._field(str(RC_ROW[1]), RC_MAX)
	rcode_edit.text_changed.connect( func(value: String) -> void :
		var up: String = value.to_upper()
		if up != value:
			var caret: int = rcode_edit.caret_column
			rcode_edit.text = up
			rcode_edit.caret_column = mini(caret, up.length()))
	rcode_edit.text_submitted.connect( func(_text: String) -> void : submit())
	all_edits = [name_edit, pass_edit, again_edit, code_edit, email_edit, mcode_edit, qcap_edit, rcode_edit]
	_set_edits()
	email_edit.text_changed.connect( func(value: String) -> void :
		var clean: String = value.replace(" ", "")
		if clean != value:
			var caret: int = email_edit.caret_column
			email_edit.text = clean
			email_edit.caret_column = mini(caret, clean.length()))
	email_edit.text_submitted.connect( func(_text: String) -> void : _next(code_edit))
	mcode_edit.text_submitted.connect( func(_text: String) -> void : _next(name_edit))
	name_edit.text_changed.connect( func(value: String) -> void :
		var clean: String = value.to_lower().replace(" ", "")
		if clean != value:
			var caret: int = name_edit.caret_column
			name_edit.text = clean
			name_edit.caret_column = mini(caret, clean.length()))
	name_edit.text_submitted.connect( func(_text: String) -> void : _next(pass_edit))
	pass_edit.text_submitted.connect( func(_text: String) -> void : _next(again_edit))
	again_edit.text_submitted.connect( func(_text: String) -> void : _next(again_edit if mail_mode else code_edit))
	code_edit.text_submitted.connect( func(_text: String) -> void : submit())


func rows() -> Array:
	if rc_mode:
		if step == 1:
			return [[RC_ROW[0], rcode_edit]]
		return [[ROWS[0][0], name_edit], [ROWS[1][0], pass_edit], [ROWS[2][0], again_edit], [ROWS[3][0], code_edit]]
	if quiz_mode and step == 1:
		return []
	if not mail_mode:
		return [[ROWS[0][0], name_edit], [ROWS[1][0], pass_edit], [ROWS[2][0], again_edit], [ROWS[3][0], code_edit]]
	if step == 1:
		return [[MAIL_ROW[0], email_edit], [ROWS[3][0], code_edit]]
	return [[MAIL_CODE_ROW[0], mcode_edit], [ROWS[0][0], name_edit], [ROWS[1][0], pass_edit], [ROWS[2][0], again_edit]]

func _set_edits() -> void :
	edits = rows().map( func(row: Array) -> LineEdit: return row[1])
	if quiz_mode and step == 1 and quiz_caps():
		edits.append(qcap_edit)


func quiz_caps() -> bool:
	var items: Array = quiz_items()
	return not items.is_empty() and qtex.size() == items.size() and qtex[0] != null


func _goto(n: int) -> void :
	if qi < qcaps.size():
		qcaps[qi] = qcap_edit.text
	qi = n
	zsel = -1
	qcap_edit.text = str(qcaps[qi]) if qi < qcaps.size() else ""
	if quiz_caps() and not view._mobile:
		focus = qcap_edit

func submit_y() -> float:
	if (quiz_mode or rc_mode) and step == 1:
		return SUBMIT_Y
	return TOP + STEP * rows().size() + 1.0

func base_h() -> float:
	return BASE_H - (SUBMIT_Y - submit_y())


func to_step1() -> void :
	step = 1
	mcode_edit.clear()
	_set_edits()
	refresh()
	if not view._mobile:
		focus = email_edit

func _next(edit: LineEdit) -> void :
	if edit.text.is_empty():
		edit.grab_focus()
	else:
		submit()


func open() -> void :
	var pre: bool = can_pre()
	if view.client.state != "login" or on or not (entry_mode() in ["old", "open"] or pre):
		return
	on = true
	opened += 1
	error = ""
	rc_error = ""
	step = 1
	mail_to = ""
	quiz = {}
	qpic = []
	zsel = -1
	quiz_token = ""
	early = pre
	if early:
		quiz_mode = true
		mail_mode = false
	if st.get("regcode") == true and not early:
		rc_mode = true
		quiz_mode = false
		mail_mode = false
	elif early:
		rc_mode = false
	_set_edits()
	for edit: LineEdit in all_edits:
		edit.clear()
	var typed: String = view.username.text.strip_edges().to_lower()
	if not typed.is_empty() and RegEx.create_from_string(NAME_RE).search(typed) != null and not view._remember:
		name_edit.text = typed
	if not early:
		refresh()
	if quiz_mode:
		_quiz_start()
	focus = null if view._mobile or quiz_mode else (rcode_edit if rc_mode else (email_edit if mail_mode else name_edit))


func close() -> void :
	if not on:
		return
	on = false
	early = false
	early_try = false
	sending = false
	loading = false
	net.cancel()
	st_busy = false
	quiz_loading = false
	rooms_loading = false
	here_busy = false
	here_at = -1
	quiz = {}
	quiz_token = ""
	for edit: LineEdit in [pass_edit, again_edit, code_edit, mcode_edit, qcap_edit, rcode_edit]:
		edit.clear()
	rc_error = ""
	qcaps = []
	qtex = []
	qpic = []
	zsel = -1
	error = ""
	focus = null
	view._focus_login()

func refresh() -> void :
	if sending:
		return
	loading = true
	captcha_id = ""
	captcha = null
	code_edit.clear()
	net.fetch_captcha(view.client.config.origin)


func check() -> Array:
	if mail_mode and step == 1:
		var mail: String = email_edit.text.strip_edges()
		if mail.is_empty():
			return ["Nhập email để nhận mã xác minh.", email_edit]
		if mail.length() > MAIL_MAX or RegEx.create_from_string("^[^@\\s]+@[^@\\s]+\\.[^@\\s]{2,}$").search(mail) == null:
			return ["Email chưa đúng dạng (ví dụ: ten@gmail.com).", email_edit]
		return _check_captcha()
	if mail_mode and mcode_edit.text.length() != 6:
		return ["Nhập 6 chữ số trong email vừa nhận.", mcode_edit]
	var who: String = name_edit.text.strip_edges().to_lower()
	if who.is_empty():
		return ["Nhập tên tài khoản.", name_edit]
	if who.length() < 4 or who.length() > 20:
		return ["Tên tài khoản dài 4–20 ký tự.", name_edit]
	if RegEx.create_from_string(NAME_RE).search(who) == null:
		return ["Tên tài khoản chỉ gồm chữ thường a–z, số 0–9 và dấu _ (không dấu, không cách).", name_edit]
	var secret: String = pass_edit.text
	if secret.is_empty():
		return ["Nhập mật khẩu.", pass_edit]
	if secret.length() < MIN_PASSWORD:
		return ["Mật khẩu phải có ít nhất %d ký tự." % MIN_PASSWORD, pass_edit]
	if secret.length() > MAX_PASSWORD:
		return ["Mật khẩu dài tối đa %d ký tự." % MAX_PASSWORD, pass_edit]
	if secret.to_lower() == who:
		return ["Mật khẩu không được trùng tên tài khoản.", pass_edit]
	if again_edit.text != secret:
		return ["Hai lần nhập mật khẩu chưa khớp.", again_edit]
	if mail_mode:
		return ["", null]
	return _check_captcha()

func _check_captcha() -> Array:
	if captcha_id.is_empty():
		return ["Chưa tải được mã xác nhận, chạm ảnh để tải lại." if not loading else "Đang tải mã xác nhận, chờ một chút.", code_edit]
	if code_edit.text.length() != 4:
		return ["Nhập 4 chữ số trong ảnh xác nhận.", code_edit]
	return ["", null]

func submit() -> void :
	if not on or sending or view.client.state != "login":
		return
	if view.pc_closed():
		view.say(view.PC_OFF_TEXT)
		return
	if quiz_mode and step == 1:
		_quiz_submit()
		return
	if rc_mode and (step == 1 or rc_code().is_empty()):
		_rc_next()
		return
	var bad: Array = check()
	if not str(bad[0]).is_empty():
		error = str(bad[0])
		focus = bad[1]
		view.queue_redraw()
		return
	error = ""
	sending = true
	if mail_mode and step == 1:
		email_edit.text = email_edit.text.strip_edges()
		net.send_code(view.client.config.origin, email_edit.text, captcha_id, code_edit.text)
		view.queue_redraw()
		return
	name_edit.text = name_edit.text.strip_edges().to_lower()
	if mail_mode:
		net.send(view.client.config.origin, name_edit.text, pass_edit.text, "", "", {"email": email_edit.text, "emailCode": mcode_edit.text})
	elif rc_mode:
		net.send(view.client.config.origin, name_edit.text, pass_edit.text, captcha_id, code_edit.text, {}, "", rc_code())
	elif quiz_mode:
		net.send(view.client.config.origin, name_edit.text, pass_edit.text, captcha_id, code_edit.text, {}, quiz_token)
	else:
		net.send(view.client.config.origin, name_edit.text, pass_edit.text, captcha_id, code_edit.text)
	view.queue_redraw()

func _on_captcha(result: Dictionary) -> void :
	loading = false
	if not on:
		return
	if result.get("ok", false):
		captcha_id = str(result["id"])
		captcha = ImageTexture.create_from_image(result["image"])
		if (result.get("regcode", false) == true) != rc_mode:
			_rc_set(result.get("regcode", false) == true)
		var want: bool = result.get("email", false) == true
		var want_quiz: bool = result.get("quiz", false) == true
		if want_quiz != quiz_mode and (step == 1 or not want_quiz):
			quiz_mode = want_quiz
			if not quiz_mode:
				step = 1
				quiz_token = ""
			_set_edits()
			if not view._mobile and not quiz_mode:
				focus = name_edit
		if want != mail_mode:
			mail_mode = want
			step = 1
			_set_edits()
			if not view._mobile:
				focus = email_edit if mail_mode else name_edit
		if quiz_mode and step == 1:
			_quiz_start()
	else:
		captcha_id = ""
		captcha = null
		error = str(result.get("error", ""))
		_stale(result)
	view.queue_redraw()

func _on_register(result: Dictionary) -> void :
	sending = false
	if not on:
		return
	if result.get("ok", false):
		var who: String = str(result["username"])
		var secret: String = pass_edit.text
		on = false
		error = ""
		for edit: LineEdit in edits:
			edit.clear()
		rcode_edit.clear()
		view.username.text = who
		view.password.text = secret
		view.say(DONE_TEXT)
		view.sign_in()
		return
	error = str(result.get("error", "Đăng ký không thành công, thử lại sau."))
	_stale(result)
	var code: String = str(result.get("code", ""))
	if code.contains("REG_CODE"):
		if not rc_mode:
			_rc_set(true)
		step = 1
		_set_edits()
		rc_error = error
		error = ""
		refresh()
		focus = null if view._mobile else rcode_edit
		view.queue_redraw()
		return
	if code in ["BAD_USERNAME", "RESERVED_USERNAME", "USERNAME_TAKEN"]:
		focus = name_edit
	elif code in ["WEAK_PASSWORD", "BAD_PASSWORD"]:
		pass_edit.clear()
		again_edit.clear()
		focus = pass_edit
	elif code == "BAD_CAPTCHA":
		focus = code_edit
	elif code == "BAD_EMAIL_CODE":
		mcode_edit.clear()
		focus = mcode_edit
	elif code in ["NEED_QUIZ", "QUIZ_EXPIRED", "QUIZ_FULL"]:
		var said: String = error
		quiz_mode = true
		mail_mode = false
		rc_mode = false
		quiz_token = ""
		quiz = {}
		step = 1
		_set_edits()
		_quiz_start()
		error = said
		focus = null
		view.queue_redraw()
		return
	elif mail_mode and code in ["EMAIL_CODE_EXPIRED", "EMAIL_USED", "BAD_EMAIL", "EMAIL_DOMAIN", "NEED_EMAIL"]:
		var said: String = error
		to_step1()
		error = said
		if view._mobile:
			focus = null
		view.queue_redraw()
		return
	if result.get("renew", false) and not mail_mode:
		var said: String = error
		refresh()
		error = said
	if view._mobile:
		focus = null
	view.queue_redraw()


func _on_code(result: Dictionary) -> void :
	sending = false
	if not on:
		return
	if result.get("ok", false):
		step = 2
		mail_to = str(result.get("to", "")).left(28)
		resend_at = Time.get_ticks_msec() + int(result.get("resend", 60)) * 1000
		error = ""
		code_edit.clear()
		captcha_id = ""
		_set_edits()
		focus = null if view._mobile else mcode_edit
		view.queue_redraw()
		return
	error = str(result.get("error", "Chưa gửi được mã, thử lại sau."))
	_stale(result)
	var code: String = str(result.get("code", ""))
	if code in ["BAD_EMAIL", "EMAIL_DOMAIN", "EMAIL_USED", "EMAIL_WAIT", "EMAIL_LIMIT"]:
		focus = email_edit
	elif code == "BAD_CAPTCHA":
		focus = code_edit
	elif code == "EMAIL_OFF":
		mail_mode = false
		step = 1
		_set_edits()
	if result.get("renew", false) or code in ["EMAIL_OFF", "BAD_EMAIL"]:
		var said: String = error
		refresh()
		error = said
	if view._mobile:
		focus = null
	view.queue_redraw()

func resend_left() -> int:
	return maxi(0, ceili((resend_at - Time.get_ticks_msec()) / 1000.0))




func _quiz_start() -> void :
	if room_list().is_empty() and not rooms_loading:
		_load_rooms()

func _load_rooms() -> void :
	rooms_loading = true
	net.fetch_rooms(view.client.config.origin)
	view.queue_redraw()

func room_list() -> Array:
	return rooms.get("rooms", []) as Array


func tab_list() -> Array:
	var groups: Array = rooms.get("groups", []) as Array
	if not groups.is_empty():
		return groups
	var out: Array = []
	for i in range(QUIZ_GROUPS.size()):
		out.append({"g": str(QUIZ_GROUPS[i]), "tab": str(QUIZ_TABS[i]), "count": int(rooms.get("count", 3)), "pass": int(rooms.get("pass", 2))})
	return out

func tab_at() -> int:
	return clampi(tab, 0, tab_list().size() - 1)


func is_puzzle(n: int) -> bool:
	var items: Array = quiz_items()
	return n >= 0 and n < items.size() and (items[n] as Dictionary).has("z") and n < picks.size() and typeof(picks[n]) == TYPE_ARRAY


func tab_rooms() -> Array:
	var want: String = str(tab_list()[tab_at()]["g"])
	return room_list().filter( func(r: Dictionary) -> bool: return str(r["g"]) == want)

func pages() -> int:
	return maxi(1, ceili(tab_rooms().size() / float(GRID_COLS * GRID_ROWS)))

func page() -> int:
	return clampi(int(pages_at[tab_at()]) if tab_at() < pages_at.size() else 0, 0, pages() - 1)

func chosen_room() -> Dictionary:
	for r: Dictionary in room_list():
		if str(r["id"]) == room_id:
			return r
	return {}

func level_name(i: int) -> String:
	var names: Array = rooms.get("levels", ["Dễ", "Vừa", "Khó"]) as Array
	return str(names[clampi(i, 0, names.size() - 1)])


func in_quiz() -> bool:
	return quiz_loading or not quiz_items().is_empty()

func _load_quiz() -> void :
	quiz = {}
	qi = 0
	picks = []
	qcaps = []
	qtex = []
	qbad = []
	qpic = []
	zsel = -1
	qcap_edit.clear()
	quiz_loading = true
	net.fetch_quiz(view.client.config.origin, room_id, lv)
	view.queue_redraw()

func quiz_items() -> Array:
	return quiz.get("items", []) as Array


func _quiz_submit() -> void :
	if quiz_loading:
		return
	if early:
		var c: Dictionary = chosen_room()
		if room_list().is_empty():
			if not rooms_loading:
				_load_rooms()
		elif c.is_empty():
			error = QUIZ_CHOOSE
		elif int((c["l"] as Array)[lv]) <= 0:
			error = QUIZ_EMPTY_LV % level_name(lv)
		elif is_full(room_id, lv):
			error = QUIZ_FULL_LV
		else:
			error = QUIZ_EARLY_OK
		view.queue_redraw()
		return
	var items: Array = quiz_items()
	if items.is_empty():
		if room_list().is_empty():
			if not rooms_loading:
				error = ""
				_load_rooms()
			return
		var r: Dictionary = chosen_room()
		if r.is_empty():
			error = QUIZ_CHOOSE
		elif int((r["l"] as Array)[lv]) <= 0:
			error = QUIZ_EMPTY_LV % level_name(lv)
		elif is_full(room_id, lv):
			error = QUIZ_FULL_LV
		else:
			error = ""
			_load_quiz()
		view.queue_redraw()
		return
	if not is_puzzle(qi) and int(picks[qi]) < 0:
		error = QUIZ_PICK
		view.queue_redraw()
		return
	if is_puzzle(qi) and error != PUZ_NEED and (picks[qi] as Array) == range((picks[qi] as Array).size()):
		error = PUZ_NEED
		view.queue_redraw()
		return
	if quiz_caps() and qcap_edit.text.length() != 4:
		error = QUIZ_CAP_NEED
		focus = qcap_edit
		view.queue_redraw()
		return
	error = ""
	if not qbad.is_empty():
		var next: int = -1
		for n: int in qbad:
			if n > qi and (next < 0 or n < next):
				next = n
		if next >= 0:
			_goto(next)
			error = QUIZ_CAP_NEXT % (next + 1)
			view.queue_redraw()
			return
	elif qi < items.size() - 1:
		_goto(qi + 1)
		view.queue_redraw()
		return
	_goto(qi)
	sending = true
	net.check_quiz(view.client.config.origin, str(quiz["id"]), picks, qcaps if quiz_caps() else [])
	view.queue_redraw()

func pick(i: int) -> void :
	var items: Array = quiz_items()
	if sending or items.is_empty() or is_puzzle(qi) or i < 0 or i >= (items[qi]["a"] as Array).size():
		return
	picks[qi] = i
	if error == QUIZ_PICK:
		error = ""
	view.queue_redraw()


func pick_cell(pos: int) -> void :
	if sending or quiz_loading or not is_puzzle(qi):
		return
	var order: Array = picks[qi]
	if pos < 0 or pos >= order.size():
		return
	if zsel < 0 or zsel >= order.size():
		zsel = pos
	elif zsel == pos:
		zsel = -1
	else:
		var held: int = int(order[zsel])
		order[zsel] = int(order[pos])
		order[pos] = held
		zsel = -1
	if error == PUZ_NEED:
		error = ""
	view.queue_redraw()


func pick_room(i: int) -> void :
	var list: Array = tab_rooms()
	if in_quiz() or i < 0 or i >= list.size():
		return
	room_id = str(list[i]["id"])
	var l: Array = list[i]["l"] as Array
	if not cell_ok(room_id, l, lv):
		for k in range(l.size()):
			if cell_ok(room_id, l, k):
				lv = k
				break
	if error in [QUIZ_CHOOSE] or error.begins_with(QUIZ_EMPTY_LV.get_slice("%", 0)):
		error = ""
	_here_poll(true)
	view.queue_redraw()


func pick_part(i: int, k: int) -> void :
	var list: Array = tab_rooms()
	if in_quiz() or i < 0 or i >= list.size() or k < 0 or k > 2 or not cell_ok(str(list[i]["id"]), list[i]["l"] as Array, k):
		return
	room_id = str(list[i]["id"])
	lv = k
	if error in [QUIZ_CHOOSE] or error.begins_with(QUIZ_EMPTY_LV.get_slice("%", 0)):
		error = ""
	_here_poll(true)
	view.queue_redraw()


func is_full(id: String, k: int) -> bool:
	var row: Variant = (rooms.get("full", {}) as Dictionary).get(id)
	return typeof(row) == TYPE_ARRAY and k >= 0 and k < (row as Array).size() and int(row[k]) == 1


func cell_ok(id: String, l: Array, k: int) -> bool:
	return int(l[k]) > 0 and not is_full(id, k)


func _mark_full(id: String, k: int) -> void :
	if rooms.is_empty() or id.is_empty():
		return
	var full: Dictionary = rooms.get("full", {}) as Dictionary
	var row: Array = (full.get(id, [0, 0, 0]) as Array).duplicate()
	if k >= 0 and k < row.size():
		row[k] = 1
	full[id] = row
	rooms["full"] = full
	if room_id == id and lv == k:
		room_id = ""


func _drop_full() -> void :
	if not in_quiz() and not room_id.is_empty() and is_full(room_id, lv):
		room_id = ""
		error = QUIZ_TAKEN


func here_count(id: String, k: int) -> int:
	var row: Variant = (rooms.get("on", {}) as Dictionary).get(id)
	return int(row[k]) if typeof(row) == TYPE_ARRAY and k < (row as Array).size() else 0


func here_key() -> String:
	if not quiz.is_empty() and not str(quiz.get("room", "")).is_empty():
		return "%s.%d" % [str(quiz["room"]), int(quiz.get("lv", lv))]
	var r: Dictionary = chosen_room()
	if r.is_empty() or int((r["l"] as Array)[lv]) <= 0:
		return ""
	return "%s.%d" % [room_id, lv]


func _here_poll(now: bool = false) -> void :
	if not on or not quiz_mode or step != 1 or room_list().is_empty():
		return
	if here_busy and not now and _now() - here_at < HERE_STALE_MS:
		return
	if not now and here_at >= 0 and _now() - here_at < HERE_MS:
		return
	here_busy = true
	here_at = _now()
	var key: String = here_key()
	here_sent.append(key)
	net.poll_here(view.client.config.origin, key)

func _on_here(result: Dictionary) -> void :
	here_busy = false
	if not on or rooms.is_empty() or not result.get("ok", false):
		return
	rooms["on"] = result.get("on", {})
	rooms["full"] = result.get("full", {})
	_drop_full()
	view.queue_redraw()


func _here_tick() -> void :
	if _here_timer:
		return
	_here_timer = true
	var g = view
	g.get_tree().create_timer(1.0).timeout.connect( func() -> void :
		_here_timer = false
		if is_instance_valid(g) and g.client.state == "login" and on:
			g.queue_redraw())

func _on_rooms(result: Dictionary) -> void :
	rooms_loading = false
	if not on:
		return
	if result.get("ok", false):
		rooms = result
		var tabs: Array = tab_list()
		while pages_at.size() < tabs.size():
			pages_at.append(0)
		tab = tab_at()
		for i in range(tabs.size()):
			pages_at[i] = clampi(int(pages_at[i]), 0, maxi(0, ceili(room_list().filter( func(r: Dictionary) -> bool: return str(r["g"]) == str(tabs[i]["g"])).size() / float(GRID_COLS * GRID_ROWS)) - 1))
		if chosen_room().is_empty():
			room_id = ""
		_drop_full()
	else:
		rooms = {}
		error = str(result.get("error", QUIZ_NO_ROOMS))
		_stale(result)
		if early and str(result.get("code", "")) == "REG_CLOSED":
			error = QUIZ_EARLY_ROOMS
		if str(result.get("code", "")) == "QUIZ_OFF":
			quiz_mode = false
			_set_edits()
			var said: String = error
			refresh()
			error = said
	view.queue_redraw()

func _on_quiz(result: Dictionary) -> void :
	quiz_loading = false
	var auto: bool = early_try
	early_try = false
	if not on:
		return
	if auto and not result.get("ok", false) and str(result.get("code", "")) == "REG_CLOSED" and result.get("later", false):
		early = true
		if st.get("ok") == true:
			st["state"] = "wait"
			open_tick = maxi(open_tick, _now() + 3000)
		_resync()
		view.queue_redraw()
		return
	if result.get("ok", false):
		quiz = result
		qi = 0
		picks = []
		picks.resize(quiz_items().size())
		picks.fill(-1)
		qpic = []
		zsel = -1
		for i in range(picks.size()):
			var it: Dictionary = quiz_items()[i]
			var art: Variant = it["z"]["img"] if it.has("z") else it.get("pic")
			qpic.append(ImageTexture.create_from_image(art) if art != null else null)
			if it.has("z"):
				picks[i] = range(int(it["z"]["cols"]) * int(it["z"]["rows"]))
		qtex = quiz_items().map( func(it: Dictionary) -> Variant: return ImageTexture.create_from_image(it["img"]) if it.get("img") != null else null)
		qcaps = []
		qcaps.resize(qtex.size())
		qcaps.fill("")
		qbad = []
		qcap_edit.clear()
		focus = qcap_edit if quiz_caps() and not view._mobile else null
	else:
		quiz = {}
		error = str(result.get("error", QUIZ_WAIT))
		_stale(result)
		var code: String = str(result.get("code", ""))
		var said: String = error
		if code == "QUIZ_OFF":
			quiz_mode = false
			_set_edits()
			refresh()
		elif code == "QUIZ_FULL":
			_mark_full(room_id, lv)
			_here_poll(true)
		elif code == "QUIZ_ROOM":
			rooms = {}
			room_id = ""
			_load_rooms()
		error = said
	view.queue_redraw()

func _on_check(result: Dictionary) -> void :
	sending = false
	zsel = -1
	var puz: bool = not quiz_items().is_empty() and quiz_items().all( func(it: Dictionary) -> bool: return it.has("z"))
	if not on:
		return
	if str(result.get("code", "")) == "QUIZ_CAP_RETRY":
		if quiz_caps() and _cap_retry(result):
			view.queue_redraw()
			return
		result["renew"] = true
	qbad = []
	if result.get("ok", false) and result.get("pass", false):
		quiz_token = str(result["token"])
		quiz = {}
		step = 2
		error = ""
		_set_edits()
		refresh()
		focus = null if view._mobile else name_edit
	elif result.get("ok", false) and int(result.get("wait", 0)) > 0:
		quiz = {}
		picks = []
		qpic = []
		var sec: int = ceili(int(result["wait"]) / 1000.0)
		error = QUIZ_FAIL_WAIT % [int(result.get("score", 0)), int(result.get("total", 0)), int(result.get("need", 0)), ("%d giây" % sec) if sec < 120 else ("%d phút" % ceili(sec / 60.0))]
		if puz:
			error = PUZ_FAIL_WAIT % (("%d giây" % sec) if sec < 120 else ("%d phút" % ceili(sec / 60.0)))
		if int(result.get("cap_bad", 0)) > 0:
			error += QUIZ_CAP_BAD % int(result["cap_bad"])
	elif result.get("ok", false):
		error = QUIZ_FAIL % [int(result.get("score", 0)), int(result.get("total", 0)), int(result.get("need", 0))]
		if puz:
			error = PUZ_FAIL
		if int(result.get("cap_bad", 0)) > 0:
			error += QUIZ_CAP_BAD % int(result["cap_bad"])
		var said: String = error
		_load_quiz()
		error = said
	else:
		error = str(result.get("error", "Chưa chấm được bài, thử lại sau."))
		_stale(result)
		var said: String = error
		if str(result.get("code", "")) == "QUIZ_OFF":
			quiz_mode = false
			_set_edits()
			refresh()
		elif str(result.get("code", "")) == "QUIZ_FULL":
			var id: String = str(quiz.get("room", room_id))
			var k: int = int(quiz.get("lv", lv))
			quiz = {}
			picks = []
			qpic = []
			room_id = id
			lv = k
			_mark_full(id, k)
			_here_poll(true)
		elif result.get("renew", false) or str(result.get("code", "")) == "QUIZ_EXPIRED":
			_load_quiz()
		error = said
	view.queue_redraw()


func _cap_retry(result: Dictionary) -> bool:
	var bad: Array = result.get("bad", []) as Array
	var imgs: Array = result.get("imgs", []) as Array
	if bad.is_empty() or bad.size() != imgs.size() or bad.any( func(n: int) -> bool: return n < 0 or n >= qtex.size()):
		return false
	for i in range(bad.size()):
		qtex[int(bad[i])] = ImageTexture.create_from_image(imgs[i])
		qcaps[int(bad[i])] = ""
	qbad = bad.duplicate()
	qbad.sort()
	qi = int(qbad[0])
	zsel = -1
	qcap_edit.text = ""
	error = str(result.get("error", ""))
	if not view._mobile:
		focus = qcap_edit
	return true



func _chip(id: String, label: String, place: Rect2, chosen: bool, dim: bool = false, px: float = 12.0, spacing: float = 1.0, pad: float = 18.0, tint: int = 0) -> void :
	var g = view
	var f: float = g._f
	var box: Rect2 = Rect2(place.position * f, place.size * f)
	if tint == 2:
		dim = true
		chosen = false
	var lit: bool = g._hover == id and not dim and not chosen
	var fill: Color = g.FIELD
	var edge: Color = g.ACCENT if lit else g.FIELD_EDGE
	if tint == 1:
		fill = Color(FREE_INK, 0.22 if lit else 0.12)
		edge = Color(FREE_INK, 1.0 if lit else 0.7)
	elif tint == 2:
		fill = Color(FULL_INK, 0.16)
		edge = Color(FULL_INK, 0.7)
	if chosen:
		fill = Color(g.ORANGE, 0.16)
		edge = g.ORANGE
	g._round(box, fill, 12.0, edge, 2.0)
	var size: float = px
	while size > 9.0 and g._flen(label, g.ARIAL_BOLD, size) + spacing * label.length() > place.size.x - pad:
		size -= 1.0
	var ink: Color = Color.WHITE if chosen or lit else g.LABEL
	if tint == 2:
		ink = Color("ffb5b5")
	elif dim:
		ink = Color(g.SOFT, 0.45)
	g._spaced(label, g.ARIAL_BOLD, size, ink, place.get_center(), spacing if size >= px else 0.0, "c")
	if not dim:
		g._hit(id, box, false)


func _paint_pick(o: Vector2) -> void :
	var g = view
	var tabs: Array = tab_list()
	var tab_w: float = (358.0 - TAB_GAP * (tabs.size() - 1)) / tabs.size()
	var few: bool = tabs.size() <= 2
	for i in range(tabs.size()):
		_chip("reg:tab%d" % i, str(tabs[i]["tab"]), Rect2(o + Vector2(36 + (tab_w + TAB_GAP) * i, TAB_Y), Vector2(tab_w, PICK_H)), tab_at() == i, false, 
			12.0 if few else 11.0, 1.0 if few else 0.0, 18.0 if few else 10.0)
	g._spaced(QUIZ_HERE_HINT, g.ARIAL, 12, g.SOFT, o + Vector2(g.CARD_W / 2.0, LV_Y + 6.0), 0.0, "c")
	var list: Array = tab_rooms()
	if list.is_empty():
		g._spaced(QUIZ_WAIT_ROOMS if rooms_loading else QUIZ_NO_ROOMS, g.ARIAL, 14, g.SOFT, o + Vector2(g.CARD_W / 2.0, GRID_Y + 78.0), 0.0, "c")
		return
	var per: int = GRID_COLS * GRID_ROWS
	var at: int = page()
	for k in range(per):
		var idx: int = at * per + k
		if idx >= list.size():
			break
		var y: float = GRID_Y + CELL_STEP * k
		var id: String = str(list[idx]["id"])
		var mine: bool = id == room_id
		_chip("reg:room%d" % idx, str(list[idx]["n"]), Rect2(o + Vector2(36, y), Vector2(NAME_W, CELL_H)), mine, false, 13.0, 0.0, 12.0)
		for p in range(3):
			var empty: bool = int((list[idx]["l"] as Array)[p]) <= 0
			var tint: int = 0 if empty else (2 if is_full(id, p) else 1)
			var label: String = "%s · %d" % [level_name(p).to_upper(), here_count(id, p)]
			_chip("reg:pt%d_%d" % [idx, p], label, Rect2(o + Vector2(PART_X + PART_STEP * p, y), Vector2(PART_W, CELL_H)), mine and lv == p and not empty, empty, 12.0, 0.0, 8.0, tint)
	if pages() > 1:
		_chip("reg:pgp", "‹", Rect2(o + Vector2(36, PAGER_Y), Vector2(60, PICK_H)), false, at <= 0, 16.0, 0.0)
		_chip("reg:pgn", "›", Rect2(o + Vector2(334, PAGER_Y), Vector2(60, PICK_H)), false, at >= pages() - 1, 16.0, 0.0)
		g._spaced(QUIZ_PAGE % [at + 1, pages()], g.ARIAL, 13, g.SOFT, o + Vector2(g.CARD_W / 2.0, PAGER_Y + PICK_H / 2.0), 0.0, "c")


func _paint_quiz(o: Vector2) -> void :
	var g = view
	var f: float = g._f
	var items: Array = quiz_items()
	if items.is_empty():
		g._spaced(QUIZ_WAIT, g.ARIAL, 14, g.SOFT, o + Vector2(g.CARD_W / 2.0, TOP + 130.0), 0.0, "c")
		return
	var it: Dictionary = items[qi]
	var head: String = QUIZ_HEAD % [qi + 1, items.size(), level_name(int(quiz.get("lv", lv))).to_upper()]
	if is_puzzle(qi):
		var zc: int = int(it["z"]["cols"])
		var zr: int = int(it["z"]["rows"])
		head = PUZ_HEAD % [level_name(int(quiz.get("lv", lv))).to_upper(), zc, zr] if items.size() == 1\
		else PUZ_HEAD_N % [qi + 1, items.size(), level_name(int(quiz.get("lv", lv))).to_upper(), zc, zr]
	g._spaced(head, g.ARIAL_BOLD, 11, g.LABEL, o + Vector2(36, TOP), 1.0)
	if not sending:
		var back: String = QUIZ_PREV if qi > 0 else QUIZ_BACK
		var back_lit: bool = g._hover == "reg:prev"
		var wide: float = g._flen(back, g.ARIAL_BOLD, 12)
		g._spaced(back, g.ARIAL_BOLD, 12, Color.WHITE if back_lit else g.ACCENT, o + Vector2(394, TOP), 0.0, "r")
		g._hit("reg:prev", Rect2((o + Vector2(386.0 - wide, TOP - 13.0)) * f, Vector2(wide + 16.0, 26) * f), false)
	if is_puzzle(qi):
		_paint_puzzle(o, it)
		return
	var pic: ImageTexture = qpic[qi] if qi < qpic.size() else null
	var px: float = 15.0
	var lh: float = 20.0
	var lines: PackedStringArray = g._wrap(str(it["q"]), g.ARIAL_BOLD, px, 358)
	if lines.size() > (3 if pic == null else 2):
		px = 13.0
		lh = 17.0
		lines = g._wrap(str(it["q"]), g.ARIAL_BOLD, px, 358)
	var shown: int = mini(lines.size(), 5 if pic == null else 3)
	for i in range(shown):
		var line: String = lines[i]
		if i == shown - 1 and lines.size() > shown:
			line = line.left(maxi(0, line.length() - 1)) + "…"
		g._spaced(line, g.ARIAL_BOLD, px, Color.WHITE, o + Vector2(36, TOP + 26.0 + lh * i))
	var answers: Array = it["a"]
	var top_y: float = maxf(ANS_Y, TOP + 26.0 + lh * (shown - 1) + 22.0)
	if pic != null:
		top_y = TOP + 26.0 + lh * (shown - 1) + 20.0
	var floor_y: float = _cap_row(o)
	var step_y: float = minf(ANS_STEP, (floor_y - top_y) / answers.size())
	var high: float = step_y - ANS_GAP
	var left: float = 36.0
	var ans_w: float = 358.0
	if pic != null:
		var span: float = step_y * answers.size() - ANS_GAP
		var side: float = minf(PIC_BOX, span)
		var pic_at: Vector2 = o + Vector2(36, top_y + (span - side) / 2.0)
		g._round(Rect2(pic_at * f, Vector2(side, side) * f), g.FIELD, 12.0, g.FIELD_EDGE, 2.0)
		var fit: float = minf((side - 8.0) / pic.get_width(), (side - 8.0) / pic.get_height())
		var seen_pic: Vector2 = Vector2(pic.get_width(), pic.get_height()) * fit
		g.draw_texture_rect(pic, Rect2((pic_at + (Vector2(side, side) - seen_pic) / 2.0) * f, seen_pic * f), false)
		left += side + PIC_GAP
		ans_w -= side + PIC_GAP
	for i in range(answers.size()):
		var y: float = top_y + step_y * i
		var box: Rect2 = Rect2((o + Vector2(left, y)) * f, Vector2(ans_w, high) * f)
		var chosen: bool = int(picks[qi]) == i
		var lit: bool = g._hover == "reg:ans%d" % i and not sending
		g._round(box, Color(g.ORANGE, 0.16) if chosen else g.FIELD, 12.0, g.ORANGE if chosen else (g.ACCENT if lit else g.FIELD_EDGE), 2.0)
		var mid: float = y + high / 2.0
		g._spaced(str(QUIZ_KEYS[i]), g.ARIAL_BOLD, 14, g.ORANGE if chosen else g.ACCENT, o + Vector2(left + 22.0, mid), 0.0, "c")
		var text: String = str(answers[i])
		var size: float = 14.0
		while size > 10.0 and g._flen(text, g.ARIAL, size) > ans_w - 58.0:
			size -= 1.0
		g._spaced(text, g.ARIAL, size, Color.WHITE if chosen or lit else g.LABEL, o + Vector2(left + 42.0, mid))
		if not sending:
			g._hit("reg:ans%d" % i, box, false)


func _cap_row(o: Vector2) -> float:
	var g = view
	var f: float = g._f
	var floor_y: float = SUBMIT_Y - 10.0
	if quiz_caps():
		floor_y -= FIELD_H + 6.0
		_field(qcap_edit, Rect2(o + Vector2(36, floor_y + 6.0), Vector2(358.0 - CAPTCHA_W - 10.0, FIELD_H)))
		var cap_at: Vector2 = o + Vector2(394.0 - CAPTCHA_W, floor_y + 6.0)
		var cap_box: Rect2 = Rect2(cap_at * f, Vector2(CAPTCHA_W, FIELD_H) * f)
		g._round(cap_box, CAPTCHA_FILL, 10.0)
		if qtex[qi] != null:
			var seen: Vector2 = Vector2(126, 42)
			g.draw_texture_rect(qtex[qi], Rect2((cap_at + (Vector2(CAPTCHA_W, FIELD_H) - seen) / 2.0) * f, seen * f), false)
		g._round(cap_box, Color(0, 0, 0, 0), 10.0, g.FIELD_EDGE, 2.0)
	return floor_y


func puzzle_rect(o: Vector2, floor_y: float) -> Rect2:
	var tex: ImageTexture = qpic[qi] if qi < qpic.size() else null
	if tex == null or tex.get_height() <= 0:
		return Rect2()
	var room: float = floor_y - 4.0 - PUZ_TOP
	var wide: float = minf(358.0, room * tex.get_width() / float(tex.get_height()))
	var tall: float = wide * tex.get_height() / float(tex.get_width())
	return Rect2(o + Vector2(36.0 + (358.0 - wide) / 2.0, PUZ_TOP + (room - tall) / 2.0), Vector2(wide, tall))


func _paint_puzzle(o: Vector2, it: Dictionary) -> void :
	var g = view
	var f: float = g._f
	var floor_y: float = _cap_row(o)
	var place: Rect2 = puzzle_rect(o, floor_y)
	var order: Array = picks[qi]
	var cols: int = int(it["z"]["cols"])
	var rows: int = int(it["z"]["rows"])
	if place.size.x <= 0.0 or order.size() != cols * rows:
		return
	var tex: ImageTexture = qpic[qi]
	var part: Vector2 = Vector2(floorf(tex.get_width() / float(cols)), floorf(tex.get_height() / float(rows)))
	var cell: Vector2 = Vector2(place.size.x / cols, place.size.y / rows)
	g._round(Rect2((place.position - Vector2(3, 3)) * f, (place.size + Vector2(6, 6)) * f), g.FIELD, 8.0, g.FIELD_EDGE, 2.0)
	var marked: Array = []
	for pos in range(order.size()):
		var k: int = int(order[pos])
		var id: String = "reg:pz%d" % pos
		var box: Rect2 = Rect2((place.position + Vector2(cell.x * (pos % cols), cell.y * floorf(pos / float(cols)))) * f, cell * f)
		g.draw_texture_rect_region(tex, box.grow(-0.5 * f), Rect2(Vector2(part.x * (k % cols), part.y * floorf(k / float(cols))), part))
		if pos == zsel:
			marked.append([box, g.ORANGE, 3.0])
		elif g._hover == id and not sending:
			marked.append([box, g.ACCENT, 2.0])
		if not sending:
			g._hit(id, box, false)
	for m: Array in marked:
		if m[1] == g.ORANGE:
			g.draw_rect((m[0] as Rect2).grow(-0.5 * f), Color(g.ORANGE, 0.22), true)
		g.draw_rect((m[0] as Rect2).grow(-1.5 * f), m[1], false, float(m[2]) * f)


func activate(id: String) -> void :
	match id:
		"reg:open":
			open()
		"reg:back", "reg:close":
			close()
		"reg:cap":
			if not loading:
				error = ""
				refresh()
		"reg:submit":
			submit()
		"reg:rcback":
			if not sending and rc_mode and step == 2:
				step = 1
				error = ""
				_set_edits()
				focus = null if view._mobile else rcode_edit
				view.queue_redraw()
		"reg:resend":
			if not sending and resend_left() == 0:
				error = ""
				to_step1()
		"reg:prev":
			if not sending and qi > 0:
				_goto(qi - 1)
				error = ""
			elif not sending and not quiz_loading:
				quiz = {}
				picks = []
				qpic = []
				zsel = -1
				error = ""
			view.queue_redraw()
		"reg:pgp", "reg:pgn":
			if not in_quiz():
				pages_at[tab_at()] = clampi(page() + (1 if id == "reg:pgn" else -1), 0, pages() - 1)
				view.queue_redraw()
		_:
			if id.begins_with("reg:tab"):
				if not in_quiz() and id.trim_prefix("reg:tab").is_valid_int():
					tab = clampi(int(id.trim_prefix("reg:tab")), 0, tab_list().size() - 1)
					view.queue_redraw()
			elif id.begins_with("reg:pz"):
				if id.trim_prefix("reg:pz").is_valid_int():
					pick_cell(int(id.trim_prefix("reg:pz")))
			elif id.begins_with("reg:ans"):
				pick(int(id.trim_prefix("reg:ans")))
			elif id.begins_with("reg:room"):
				pick_room(int(id.trim_prefix("reg:room")))
			elif id.begins_with("reg:pt"):
				var ik: PackedStringArray = id.trim_prefix("reg:pt").split("_")
				if ik.size() == 2:
					pick_part(int(ik[0]), int(ik[1]))




func entry(at: Vector2, busy: bool) -> void :
	var g = view
	var f: float = g._f
	_poll()
	var mode: String = entry_mode()
	var can: bool = (mode in ["old", "open"] or can_pre()) and not busy
	var plate: Rect2 = Rect2((at + Vector2(36, ENTRY_DY)) * f, Vector2(358, ENTRY_H) * f)
	var lit: bool = g._hover == "reg:open" and can
	g._round(plate, g.FIELD, 14.0, g.ACCENT if lit else g.FIELD_EDGE, 2.0)
	var ink: Color = Color.WHITE if lit else g.ACCENT
	if mode in ["full", "closed"]:
		ink = Color(g.SOFT, 0.8)
	elif busy:
		ink = Color(ink, 0.5)
	g._spaced(entry_text(), g.ARIAL_BOLD, 12, ink, plate.get_center() / f, 0.7, "c")
	if can:
		g._hit("reg:open", plate, false)
	if mode == "due":
		_due()
	if mode in ["wait", "due"]:
		_tick(1.0)
	elif mode == "open" and int(st.get("left", -1)) >= 0:
		_tick(5.0)



func _now() -> int:
	return int(clock.call()) if clock.is_valid() else Time.get_ticks_msec()


func entry_mode() -> String:
	if st.get("ok") != true:
		return "old"
	var state: String = str(st.get("state", ""))
	if state == "wait":
		return "wait" if open_tick > _now() else "due"
	return state

func wait_left() -> int:
	return maxi(0, ceili((open_tick - _now()) / 1000.0))

func hms() -> String:
	var left: int = wait_left()
	return "%02d:%02d:%02d" % [left / 3600, (left / 60) % 60, left % 60]


func can_pre() -> bool:
	return st.get("quiz") == true and entry_mode() in ["wait", "due"]


func _early_tick() -> void :
	if entry_mode() == "wait":
		_tick(1.0)
		return
	if early_armed:
		return
	early_armed = true
	var g = view
	var jitter: int = randi_range(reload_jitter.x, reload_jitter.y)
	g.get_tree().create_timer(jitter / 1000.0).timeout.connect( func() -> void :
		early_armed = false
		if is_instance_valid(g) and on and early:
			_early_go())


func _early_go() -> void :
	early = false
	if error in [QUIZ_EARLY_OK, QUIZ_EARLY_ROOMS]:
		error = ""
	_resync()
	if room_list().is_empty():
		if not rooms_loading:
			_load_rooms()
	else:
		var c: Dictionary = chosen_room()
		if not c.is_empty() and int((c["l"] as Array)[lv]) > 0 and not in_quiz():
			error = ""
			early_try = true
			_load_quiz()
	view.queue_redraw()

func _resync() -> void :
	if not st_busy:
		st_busy = true
		net.fetch_status(view.client.config.origin)

func entry_text() -> String:
	match entry_mode():
		"wait":
			return (ENTRY_PICK if st.get("quiz") == true else ENTRY_WAIT) % hms()
		"due":
			return ENTRY_DUE
		"full":
			return ENTRY_FULL
		"closed":
			return ENTRY_CLOSED
		"open":
			var left: int = int(st.get("left", -1))
			return ENTRY_TEXT if left < 0 else ENTRY_LEFT % left
	return ENTRY_TEXT


func _poll() -> void :
	if st_busy:
		return
	var mode: String = entry_mode()
	var every: int = POLL_IDLE_MS
	if mode == "open" and int(st.get("left", -1)) >= 0:
		every = POLL_OPEN_MS
	elif mode == "open":
		every = POLL_WAIT_MS
	elif mode == "wait":
		if open_tick - _now() < 15000:
			return
		every = POLL_WAIT_MS
	elif mode == "due":
		return
	if st_at >= 0 and _now() - st_at < every:
		return
	st_busy = true
	net.fetch_status.call_deferred(view.client.config.origin)

func _on_status(result: Dictionary) -> void :
	st_busy = false
	st_at = _now()
	if result.get("ok") == true:
		st = result
		if str(result.get("state", "")) == "wait":
			open_tick = st_at + int(result.get("wait_ms", 1000))
	elif st.get("ok") != true:
		st = result
	due_armed = false
	view.queue_redraw()


func _stale(result: Dictionary) -> void :
	if str(result.get("code", "")) in ["REG_FULL", "REG_CLOSED"]:
		st_at = -1


func _due() -> void :
	if due_armed:
		return
	due_armed = true
	var g = view
	var jitter: int = randi_range(reload_jitter.x, reload_jitter.y)
	g.get_tree().create_timer(jitter / 1000.0).timeout.connect( func() -> void :
		if not is_instance_valid(g) or g.client.state != "login" or not g.is_visible_in_tree() or on:
			due_armed = false
			return
		if OS.has_feature("web") or reload_hook.is_valid():
			reloads += 1
			if reload_hook.is_valid():
				reload_hook.call()
			else:
				JavaScriptBridge.eval("location.reload()")
		else:
			st_busy = true
			net.fetch_status(g.client.config.origin))


func _tick(sec: float) -> void :
	if _st_timer:
		return
	_st_timer = true
	var g = view
	g.get_tree().create_timer(sec).timeout.connect( func() -> void :
		_st_timer = false
		if is_instance_valid(g) and g.client.state == "login" and ( not on or early):
			g.queue_redraw())

func _lines() -> PackedStringArray:
	if error.is_empty():
		return PackedStringArray()
	var lines: PackedStringArray = view._wrap(error, view.ARIAL, 13, 332)
	return lines.slice(0, MAX_LINES)


func error_h() -> float:
	var lines: PackedStringArray = _lines()
	return 0.0 if lines.is_empty() else 22.0 + view.ERROR_LINE * lines.size()


func rise(extra: float) -> float:
	if view.logo == null:
		return 0.0
	return clampf(floorf(view._fh + 0.01) - 8.0 - (base_h() + extra), 0.0, view.LOGO_GROW)

func paint() -> void :
	var g = view
	var f: float = g._f
	g._login_bg()
	var lines: PackedStringArray = _lines()
	var extra: float = error_h()
	var up: float = rise(extra)
	var high: float = base_h() + extra + up
	var o: Vector2 = g._centre(g.CARD_W, high)
	o.y = maxf(0.0, o.y)
	g._card.set_corner_radius_all(maxi(1, roundi(14.0 * f)))
	g._card.set_border_width_all(maxi(1, roundi(f)))
	g._card.shadow_size = maxi(1, roundi(40.0 * f))
	g._card.shadow_offset = Vector2(0, 24.0 * f)
	g.draw_style_box(g._card, Rect2(o * f, Vector2(g.CARD_W, high) * f))

	var shut: bool = g._hover == "reg:close"
	g._spaced("×", g.ARIAL, 28.0 * (1.05 if shut else 1.0), g.CLOSE_LIT if shut else g.CLOSE, o + Vector2(402, 29), 0.0, "c")
	g._hit("reg:close", Rect2((o + Vector2(389, 15)) * f, Vector2(26, 28) * f), false)
	if g.logo != null:
		g._draw_logo(g._logo_rect(o, g.SUB_Y + up))
		g._spaced(subtitle(), g.ARIAL, 14, g.SOFT, o + Vector2(g.CARD_W / 2.0, g.SUB_Y + up), 0.0, "c")
		o.y += up
	else:
		g._spaced(g.KICKER, g.ARIAL_BOLD, 10, g.ACCENT, o + Vector2(36, 46.75), 2.0)
		g._spaced(HEADLINE, g.ARIAL_BOLD, 28, Color.WHITE, o + Vector2(36, 83.6), -2.0)
		g._spaced(subtitle(), g.ARIAL, 14, g.SOFT, o + Vector2(36, g.SUB_Y))
	var had: Array = edits
	_set_edits()
	if had != edits:
		g._hide_except(edits)
	if early:
		_early_tick()
	if quiz_mode and step == 1:
		_here_poll()
		_here_tick()
		if in_quiz():
			_paint_quiz(o)
		else:
			_paint_pick(o)
	var shown: Array = rows()
	for i in range(shown.size()):
		var edit: LineEdit = shown[i][1]
		var y: float = TOP + STEP * i
		g._spaced(str(shown[i][0]), g.ARIAL_BOLD, 11, g.LABEL, o + Vector2(36, y), 1.0)
		var wide: float = 358.0 - (CAPTCHA_W + 10.0 if edit == code_edit or edit == mcode_edit else 0.0)
		_field(edit, Rect2(o + Vector2(36, y + FIELD_DY), Vector2(wide, FIELD_H)))
		if edit == code_edit:
			_captcha(o + Vector2(394.0 - CAPTCHA_W, y + FIELD_DY), o + Vector2(394, y))
		elif edit == mcode_edit:
			_resend(o + Vector2(394.0 - CAPTCHA_W, y + FIELD_DY), o + Vector2(394, y))
	if rc_mode:
		_paint_rc(o)

	var top_y: float = submit_y()
	var plate: Rect2 = Rect2((o + Vector2(36, top_y)) * f, Vector2(358, SUBMIT_H) * f)
	var lit: bool = g._hover == "reg:submit" and not sending
	g.draw_rect(plate, g.SUBMIT_LIT if lit else g.SUBMIT)
	var label: String = BUSY_TEXT if sending else SUBMIT_TEXT
	if rc_mode and step == 1:
		label = RC_NEXT
	elif mail_mode and step == 1:
		label = MAIL_SENDING_TEXT if sending else MAIL_SEND_TEXT
	elif quiz_mode and step == 1:
		if early:
			label = (QUIZ_EARLY_WAIT % hms()) if entry_mode() == "wait" else QUIZ_EARLY_DUE
		elif sending:
			label = QUIZ_CHECKING
		elif quiz_loading or (rooms_loading and room_list().is_empty()):
			label = QUIZ_LOADING
		elif in_quiz():
			label = QUIZ_NEXT if qi < quiz_items().size() - 1 else QUIZ_DONE
		else:
			label = QUIZ_RELOAD if room_list().is_empty() else QUIZ_START
	g._spaced(label, g.ARIAL_BOLD, 12, Color.WHITE if lit else g.SUBMIT_INK, plate.get_center() / f, 0.7, "c")
	g._hit("reg:submit", plate, false)
	var below: float = top_y + SUBMIT_H
	if not lines.is_empty():
		g._round(Rect2((o + Vector2(36, below)) * f, Vector2(358, extra) * f), g.ERROR_FILL, 12.0, g.ERROR_EDGE, 2.0)
		for i in range(lines.size()):
			g._spaced(lines[i], g.ARIAL, 13, g.ERROR_INK, o + Vector2(49, below + 11.0 + g.ERROR_LINE * (i + 0.5)))

	var mid: float = below + extra + 27.0
	var ask: float = g._flen(BACK_ASK + " ", g.ARIAL, 13)
	var link: float = g._flen(BACK_LINK, g.ARIAL_BOLD, 13)
	var left: float = g.CARD_W / 2.0 - (ask + link) / 2.0
	g._spaced(BACK_ASK, g.ARIAL, 13, g.SOFT, o + Vector2(left, mid))
	var back_lit: bool = g._hover == "reg:back"
	g._spaced(BACK_LINK, g.ARIAL_BOLD, 13, Color.WHITE if back_lit else g.ACCENT, o + Vector2(left + ask, mid))
	if back_lit:
		g.draw_line((o + Vector2(left + ask, mid + 9.0)) * f, (o + Vector2(left + ask + link, mid + 9.0)) * f, Color.WHITE, maxf(1.0, f))
	g._hit("reg:back", Rect2((o + Vector2(36, mid - 14.0)) * f, Vector2(358, 28) * f), false)
	if focus != null and focus.visible and focus.editable:
		focus.grab_focus()
		focus = null


func _field(edit: LineEdit, place: Rect2) -> void :
	var g = view
	var f: float = g._f
	var box: Rect2 = Rect2(place.position * f, place.size * f)
	var lit: bool = edit.has_focus()
	if lit:
		g._round(box.grow(3.0 * f), Color(g.ACCENT, 0.2), 20.0)
	g._round(box, g.FIELD, 14.0, g.ACCENT if lit else g.FIELD_EDGE, 2.0)
	for look: String in ["normal", "focus", "read_only"]:
		var empty: StyleBox = edit.get_theme_stylebox(look)
		empty.content_margin_left = 14.0 * f
		empty.content_margin_right = 14.0 * f
	g._fput(edit, place, 16, "l", not sending)


func _captcha(at: Vector2, hint_at: Vector2) -> void :
	var g = view
	var f: float = g._f
	g._spaced(CAPTCHA_HINT, g.ARIAL, 11, g.SOFT, hint_at, 0.0, "r")
	var box: Rect2 = Rect2(at * f, Vector2(CAPTCHA_W, FIELD_H) * f)
	var lit: bool = g._hover == "reg:cap" and not loading
	g._round(box, CAPTCHA_FILL, 10.0)
	if captcha != null:
		var shown: Vector2 = Vector2(126, 42)
		g.draw_texture_rect(captcha, Rect2((at + (Vector2(CAPTCHA_W, FIELD_H) - shown) / 2.0) * f, shown * f), false)
	else:
		g._spaced(CAPTCHA_WAIT if loading else CAPTCHA_RETRY, g.ARIAL_BOLD, 12, g.SUBMIT_INK, box.get_center() / f, 0.0, "c")
	g._round(box, Color(0, 0, 0, 0), 10.0, g.ACCENT if lit else g.FIELD_EDGE, 2.0)
	g._hit("reg:cap", box, false)




func rc_code() -> String:
	return rcode_edit.text.strip_edges().to_upper()


func _rc_set(want: bool) -> void :
	rc_mode = want
	step = 1
	rc_error = ""
	if want:
		quiz_mode = false
		mail_mode = false
		early = false
		quiz_token = ""
		quiz = {}
	_set_edits()
	if not view._mobile:
		focus = rcode_edit if want else name_edit


func _rc_next() -> void :
	var typed: String = rc_code()
	if typed.is_empty():
		step = 1
		_set_edits()
		rc_error = RC_NEED
		focus = rcode_edit
		view.queue_redraw()
		return
	rcode_edit.text = typed
	rc_error = ""
	error = ""
	step = 2
	_set_edits()
	if captcha_id.is_empty() and not loading:
		refresh()
	focus = null if view._mobile else name_edit
	view.queue_redraw()

func rc_lines() -> PackedStringArray:
	if rc_error.is_empty():
		return PackedStringArray()
	return view._wrap(rc_error, view.ARIAL, 13, 358).slice(0, RC_LINES)


func _paint_rc(o: Vector2) -> void :
	var g = view
	var f: float = g._f
	if step != 1:
		if not sending:
			var back_lit: bool = g._hover == "reg:rcback"
			var wide: float = g._flen(RC_BACK, g.ARIAL_BOLD, 12)
			g._spaced(RC_BACK, g.ARIAL_BOLD, 12, Color.WHITE if back_lit else g.ACCENT, o + Vector2(394, TOP), 0.0, "r")
			g._hit("reg:rcback", Rect2((o + Vector2(386.0 - wide, TOP - 13.0)) * f, Vector2(wide + 16.0, 26) * f), false)
		return
	var y: float = TOP + FIELD_DY + FIELD_H + RC_GAP + 8.0
	var lines: PackedStringArray = rc_lines()
	if lines.is_empty():
		g._spaced(RC_HINT, g.ARIAL, 12, g.SOFT, o + Vector2(36, y))
	for i in range(lines.size()):
		g._spaced(lines[i], g.ARIAL, 13, g.ERROR_INK, o + Vector2(36, y + RC_LINE * i))
	var box: Vector2 = o + Vector2(36, RC_BOX_Y)
	g._round(Rect2(box * f, Vector2(358, RC_BOX_H) * f), Color(g.FIELD, 0.6), 14.0, g.FIELD_EDGE, 1.0)
	g._spaced(RC_TITLE, g.ARIAL_BOLD, 11, g.LABEL, box + Vector2(18, 24), 1.0)
	for i in range(RC_TIPS.size()):
		var cy: float = 58.0 + 32.0 * i
		var now: bool = i == 0
		g._round(Rect2((box + Vector2(18, cy - 11.0)) * f, Vector2(22, 22) * f), g.ACCENT if now else Color(g.ACCENT, 0.16), 11.0)
		g._spaced(str(i + 1), g.ARIAL_BOLD, 12, g.SUBMIT_INK if now else g.ACCENT, box + Vector2(29, cy), 0.0, "c")
		g._spaced(str(RC_TIPS[i]), g.ARIAL, 13, Color.WHITE if now else g.SOFT, box + Vector2(52, cy))

func subtitle() -> String:
	if rc_mode:
		return RC_STEP1 if step == 1 else RC_STEP2
	if quiz_mode:
		if step == 2:
			return QUIZ_STEP2
		if early:
			return QUIZ_EARLY_SUB
		var items: Array = quiz_items()
		if not items.is_empty():
			if is_puzzle(qi):
				return PUZ_STEP1 % str(chosen_room().get("n", items[0].get("s", "")))
			return QUIZ_STEP1 % [str(chosen_room().get("n", items[0].get("s", ""))), int(quiz.get("pass", 0)), items.size()]
		if not (rooms.get("groups", []) as Array).is_empty():
			var grp: Dictionary = tab_list()[tab_at()]
			return QUIZ_PICK1_ONE if int(grp["count"]) <= 1 else QUIZ_PICK1 % [int(grp["pass"]), int(grp["count"])]
		return QUIZ_PICK1 % [int(rooms.get("pass", 2)), int(rooms.get("count", 3))]
	if not mail_mode:
		return SUBTITLE
	return MAIL_STEP1 if step == 1 else MAIL_STEP2 % mail_to


func _resend(at: Vector2, hint_at: Vector2) -> void :
	var g = view
	var f: float = g._f
	g._spaced(MAIL_HINT, g.ARIAL, 11, g.SOFT, hint_at, 0.0, "r")
	var box: Rect2 = Rect2(at * f, Vector2(CAPTCHA_W, FIELD_H) * f)
	var left: int = resend_left()
	var can: bool = left == 0 and not sending
	var lit: bool = can and g._hover == "reg:resend"
	g._round(box, g.FIELD, 14.0, g.ACCENT if lit else g.FIELD_EDGE, 2.0)
	var ink: Color = Color.WHITE if lit else g.ACCENT
	g._spaced(RESEND_TEXT if left == 0 else RESEND_WAIT % left, g.ARIAL_BOLD, 12, ink if can else Color(g.SOFT, 0.8), box.get_center() / f, 0.0, "c")
	if can:
		g._hit("reg:resend", box, false)
	elif on and step == 2 and not _ticking:
		_ticking = true
		g.get_tree().create_timer(1.0).timeout.connect( func() -> void :
			_ticking = false
			if is_instance_valid(g):
				g.queue_redraw())
