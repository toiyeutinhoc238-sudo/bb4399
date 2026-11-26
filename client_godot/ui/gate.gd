extends "flash_screen.gd"
















const Atlas = preload("gate_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Create = preload("create_char_atlas.gd")
const BuildTag = preload("build_tag.gd")
const Reg = preload("gate_register.gd")

const SAVE: String = "user://gate.cfg"
const AUTH_FILE: String = "user://gate_auth.dat"
const SALT_FILE: String = "user://gate_salt.bin"
const REMEMBER_APP: String = "Ghi nhớ đăng nhập"


const PC_OFF: bool = false
const PC_OFF_TEXT: String = "Bản máy tính đang tạm đóng, vui lòng chơi trên điện thoại."
const AUTO_TEXT: String = "Đang đăng nhập…"
const SWITCH_TEXT: String = "ĐỔI TÀI KHOẢN"
const AUTO_SAVED_BAD: String = "Không đọc được đăng nhập đã lưu, hãy đăng nhập lại."


const AUTO_KEEP: Array[String] = ["NETWORK", "RESPONSE", "RATE_LIMITED"]


const HOME_JS: String = "try{(window.top||window).location.href=window.location.origin+'/'}catch(e){window.location.href=window.location.origin+'/'}"
const LOGIN_BG: String = "l/gate/login_bg.webp"
const LOADER_BG: String = "l/gate/loader_bg.webp"


const CARD_W: float = 430.0
const CARD_H: float = 569.0
const CARD_FILL: Color = Color(16 / 255.0, 12 / 255.0, 28 / 255.0, 0.96)
const CARD_EDGE: Color = Color(139 / 255.0, 92 / 255.0, 246 / 255.0, 0.45)
const ACCENT: Color = Color("00ff88")
const SOFT: Color = Color("94a3b8")
const LABEL: Color = Color("e2e8f0")
const FIELD: Color = Color(12 / 255.0, 9 / 255.0, 22 / 255.0, 0.95)
const FIELD_EDGE: Color = Color(55 / 255.0, 48 / 255.0, 80 / 255.0, 0.8)
const SUBMIT: Color = Color("00e676")
const SUBMIT_INK: Color = Color("062312")
const SUBMIT_LIT: Color = Color("39ff94")
const ERROR_FILL: Color = Color(80 / 255.0, 18 / 255.0, 32 / 255.0, 0.35)
const ERROR_EDGE: Color = Color(255 / 255.0, 75 / 255.0, 110 / 255.0, 0.6)
const ERROR_INK: Color = Color("ff7b92")
const CLOSE: Color = Color("8e88a8")
const CLOSE_LIT: Color = Color("ffffff")
const KICKER: String = "TANK GHOST"
const HEADLINE: String = "Trở lại chiến trường"


const LOGO: String = "res://assets/brand/logo.png"
const LOGO_SOLID: Rect2 = Rect2(89, 136, 845, 700)


const PBE_BADGE: String = "res://assets/brand/pbe_badge.png"
const PBE_BADGE_TEXT: String = ""
const PBE_BADGE_HIGH: float = 0.326
const PBE_BADGE_AT: Vector2 = Vector2(1.007, 1.011)
const LOGO_TOP: float = 16.0
const LOGO_GROW: float = 40.0
const SUB_Y: float = 145.0
const SUBTITLE: String = "Đăng nhập để tiếp tục cuộc chơi"
const NOTE: String = "Dùng tài khoản BangBang của bạn để vào trận."
const REMEMBER: String = "Ghi nhớ tài khoản"
const SUBMIT_TEXT: String = "ĐĂNG NHẬP & VÀO GAME"
const BUSY_TEXT: String = "ĐANG ĐĂNG NHẬP..."

const FIELDS: Array = [
	["Tài khoản", 172.0, 188.0, "Nhập tài khoản"], 
	["Mật khẩu", 252.0, 268.0, "Nhập mật khẩu"], 
	["Mã truy cập", 332.0, 348.0, "Chỉ cần nhập lần đầu trên máy này"], 
]



const SHOW_KEY: bool = false
const KEY_ROW: float = 83.0
const QUIET: Array[String] = ["Đăng nhập để chơi.", "", "Đang đăng nhập…"]
const ERROR_LINE: float = 18.85


const FRAME_AT: Vector2 = Vector2(172, 70)
const RECENT: String = "Log-in gần đây"
const REGION: String = "Máy chủ"
const LAST_LABEL: String = "Server log-in trước"
const PICK_LABEL: String = "Server hiện tại:"
const GREY: Color = Color("636363")
const ORANGE: Color = Color("ff6600")
const DOUBLE: float = 0.4


const ATTENTION: Array[String] = ["Chơi Game Lành Mạnh", 
	"Hãy sắp xếp thời gian chơi game hợp lý, giữ gìn sức khỏe, cẩn thận lừa đảo."]

const SPARK: Array[float] = [1.0, 0.875, 0.75, 0.625, 0.5, 0.375, 0.25, 0.125, 0.0, 0.109, 0.223, 0.332, 0.445, 0.555, 0.668, 0.777, 0.89, 1.0]

const TARGETS: Dictionary = {"Đang kết nối máy chủ đăng nhập…": 30.0, "Đang kết nối máy chủ game…": 65.0, "Đang vào sảnh…": 92.0}

var username: LineEdit
var password: LineEdit
var key: LineEdit
var _remember: bool = false
var _seen: String = ""
var _pending: String = ""
var _focus: LineEdit
var _pick: int = 0
var _top: int = 0
var _clicked: String = ""
var _clicked_at: float = -10.0
var _percent: float = 1.0
var homed: int = 0

var lobby_wait: Node = null




var auto_enter: bool = true
var _auto_sent: bool = false
var _show_servers: bool = false
const LOBBY_STATUS: String = "Đang tải..."
var _lift: Dictionary = {}
var _variants: Dictionary = {}
var _card: StyleBoxFlat = StyleBoxFlat.new()

var name_edit: LineEdit
var _making: bool = false
var _male: bool = true
var _clip: Dictionary = {"boy": 0, "girl": 0}
var _playing: Dictionary = {"boy": false, "girl": false}
var _clip_time: float = 0.0
var logo: CanvasTexture = null
var badge: CanvasTexture = null


var native_auth: bool = not OS.has_feature("web") and not OS.has_feature("editor")
var auth_file: String = AUTH_FILE
var salt_file: String = SALT_FILE
var _auto: bool = false
var _auto_tried: bool = false
var _auto_held: bool = false
var _held_auth: Array[String] = []
var _flying: bool = false
var reg: Reg = Reg.new()

func _setup() -> void :
	_use(Atlas.FILE, Atlas.R)
	_use(Hall.FILE, Hall.R)
	var art: Texture2D = load(LOGO) if ResourceLoader.exists(LOGO) else null
	if art != null:
		logo = CanvasTexture.new()
		logo.diffuse_texture = art
		logo.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var mark: Texture2D = load(PBE_BADGE) if ResourceLoader.exists(PBE_BADGE) else null
	if mark != null:
		badge = CanvasTexture.new()
		badge.diffuse_texture = mark
		badge.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	username = _field(str(FIELDS[0][3]), 64)
	password = _field(str(FIELDS[1][3]), 256)
	key = _field(str(FIELDS[2][3]), 256)
	password.secret = true
	key.secret = true
	password.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PASSWORD
	key.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PASSWORD
	username.text_submitted.connect( func(_text: String) -> void :
		if password.text.is_empty():
			password.grab_focus()
		else:
			sign_in())
	password.text_submitted.connect( func(_text: String) -> void : sign_in())
	key.text_submitted.connect( func(_text: String) -> void : sign_in())
	if not SHOW_KEY:
		key.visible = false
		key.focus_mode = Control.FOCUS_NONE
	name_edit = _name_fedit()
	reg.setup(self)
	var saved: ConfigFile = ConfigFile.new()
	if saved.load(SAVE) == OK:
		username.text = str(saved.get_value("gate", "username", ""))
		_remember = not username.text.is_empty()
	if native_auth and FileAccess.file_exists(auth_file):
		_remember = true
	_card.bg_color = CARD_FILL
	_card.border_color = CARD_EDGE
	_card.shadow_color = Color(0, 0, 0, 0.6)
	_card.anti_aliasing = true


func _field(hint: String, limit: int) -> LineEdit:
	var edit: LineEdit = _fedit(limit)
	edit.placeholder_text = hint
	edit.add_theme_font_override("font", ARIAL)
	edit.add_theme_color_override("caret_color", ACCENT)
	edit.add_theme_color_override("font_placeholder_color", SOFT)
	return edit


static var pc_force: int = -1
static func pc_closed() -> bool:
	if pc_force >= 0:
		return pc_force == 1
	if not PC_OFF or not OS.has_feature("template"):
		return false
	if OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("web_android") or OS.has_feature("web_ios"):
		return false
	if OS.has_feature("web") and OS.has_feature("web_macos"):
		return int(JavaScriptBridge.eval("navigator.maxTouchPoints||0", true)) <= 1
	return true


func sign_in() -> void :
	if client.state != "login":
		return
	if pc_closed():
		say(PC_OFF_TEXT)
		return
	var who: String = username.text.strip_edges()
	if who.is_empty() or password.text.is_empty():
		say("Nhập tài khoản và mật khẩu.")
		_focus = username if who.is_empty() else password
		return
	var secret: String = password.text
	var code: String = key.text
	password.clear()
	key.clear()
	_pending = who
	_held_auth.clear()
	if native_auth and _remember:
		_held_auth.append_array([secret, code])
	preload("flash_fonts.gd").ask()
	client.login(who, secret, code)
	_flying = true


func reset() -> void :
	password.clear()
	key.clear()
	_held_auth.clear()
	_auto = false
	_flying = false
	_forget()
	if not _remember:
		username.clear()


func _auth_pass(make: bool) -> String:
	var salt: PackedByteArray = FileAccess.get_file_as_bytes(salt_file) if FileAccess.file_exists(salt_file) else PackedByteArray()
	if salt.size() != 32:
		if not make:
			return ""
		salt = Crypto.new().generate_random_bytes(32)
		var out: FileAccess = FileAccess.open(salt_file, FileAccess.WRITE)
		if out == null:
			return ""
		out.store_buffer(salt)
		out.close()
	return (OS.get_unique_id() + salt.hex_encode()).sha256_text()


func _keep(who: String, secret: String, code: String) -> void :
	if not native_auth or who.is_empty() or secret.is_empty():
		return
	var word: String = _auth_pass(true)
	if word.is_empty():
		return
	var out: FileAccess = FileAccess.open_encrypted_with_pass(auth_file, FileAccess.WRITE, word)
	if out == null:
		return
	out.store_var({"u": who, "p": secret, "k": code})
	out.close()


func _recall() -> Dictionary:
	if not native_auth or not FileAccess.file_exists(auth_file):
		return {}
	var word: String = _auth_pass(false)
	var head: PackedByteArray = FileAccess.get_file_as_bytes(auth_file).slice(0, 4)
	if head.get_string_from_ascii() != "GDEC":
		word = ""
	var src: FileAccess = FileAccess.open_encrypted_with_pass(auth_file, FileAccess.READ, word) if not word.is_empty() else null
	var data: Variant = src.get_var(false) if src != null else null
	if src != null:
		src.close()
	if typeof(data) != TYPE_DICTIONARY or typeof(data.get("u")) != TYPE_STRING or typeof(data.get("p")) != TYPE_STRING\
	or typeof(data.get("k")) != TYPE_STRING or str(data["u"]).is_empty() or str(data["p"]).is_empty():
		_forget()
		return {"bad": true}
	return {"u": data["u"], "p": data["p"], "k": data["k"]}


func _forget() -> void :
	if FileAccess.file_exists(auth_file):
		DirAccess.remove_absolute(auth_file)


func _auto_login() -> void :
	if _auto_tried or not native_auth:
		return
	_auto_tried = true
	var saved: Dictionary = _recall()
	if saved.get("bad", false):
		say(AUTO_SAVED_BAD)
		return
	if saved.is_empty():
		return
	_remember = true
	username.text = saved["u"]
	password.text = saved["p"]
	key.text = saved["k"]
	_auto = true
	sign_in()



func _auth_done(ok: bool) -> void :
	var held: Array[String] = _held_auth.duplicate()
	_held_auth.clear()
	var was_auto: bool = _auto
	_auto = false
	if ok:
		if native_auth and _remember and held.size() == 2:
			_keep(_pending, held[0], held[1])
		return
	if not was_auto:
		return
	if client.error_code in AUTO_KEEP:
		var saved: Dictionary = _recall()
		if not saved.is_empty() and not saved.get("bad", false):
			password.text = saved["p"]
			key.text = saved["k"]
	else:
		_forget()


func greeting() -> String:
	var shown: String = str(client.account.get("name", ""))
	var login_name: String = str(client.account.get("username", ""))
	if shown.is_empty() or shown == login_name:
		return login_name
	return "%s (%s)" % [shown, login_name]

func _store() -> void :

	if not _remember and not FileAccess.file_exists(SAVE):
		return
	if _remember and _pending.is_empty():
		return
	var saved: ConfigFile = ConfigFile.new()
	saved.set_value("gate", "username", _pending if _remember else "")
	saved.save(SAVE)

func _tick(delta: float) -> void :
	_ease(delta)
	if client.creating != _making:
		_making = client.creating
		if _making:
			_open_create()
	if _making:
		_clip_time = minf(_clip_time + delta, 0.5)
		while _clip_time >= 1.0 / float(Create.FPS):
			_clip_time -= 1.0 / float(Create.FPS)
			_step("boy")
			_step("girl")
	if _flying and client.state != "auth":
		_flying = false
		_auth_done(client.state != "login")
	if _auto_held and not BuildTag.hold and client.state == _seen:
		_auto_held = false
		if client.state == "login":
			_auto_login()
	if client.state == _seen:
		return
	var before: String = _seen
	_seen = client.state
	if _seen == "servers" and before == "auth":
		_store()
	if _seen == "login" and before.is_empty():
		if BuildTag.hold:
			_auto_held = true
		else:
			_auto_login()
		if client.state != "login":
			return
	if _seen == "login":
		if _auto_sent and not client.error_code.is_empty():
			_show_servers = true
		_auto_sent = false
	elif _seen in ["characters", "lobby"]:
		_auto_sent = false
		_show_servers = false
	if _seen == "servers" and before in ["login", "auth"] and auto_enter and not _show_servers:
		_auto_sent = true
		client.select_server(_server_id())
		if client.state == "servers":
			_auto_sent = false
			_show_servers = true
	if _seen == "login":
		_focus_login()
	if _seen == "connecting" and before != "characters":
		_percent = 1.0
	if _seen == "characters":
		_pick = 0
		_top = 0



func _ease(delta: float) -> void :
	var busy: bool = client.state == "auth"
	var over: Dictionary = {"submit": _hover == "submit" and not busy, "submit_bg": _hover == "submit" and not busy, "close": _hover == "close"}
	for id: String in over:
		var span: float = 0.8 if id == "submit_bg" else 0.3
		_lift[id] = move_toward(float(_lift.get(id, 0.0)), 1.0 if over[id] else 0.0, delta / span)
	if client.state == "connecting" and TARGETS.has(client.status):
		var target: float = float(TARGETS[client.status])
		_percent = clampf(_percent + (target - _percent) * (1.0 - exp( - delta * 1.5)), 1.0, 99.0)
	if client.state in ["lobby", "hall", "room"] and lobby_wait != null:
		_percent = clampf(float(lobby_wait.get("percent")), 1.0, 100.0)

func _shown() -> void :
	if is_visible_in_tree() and client != null and client.state == "login":
		_focus_login()




func _close_shown() -> bool:
	return not (_mobile and not OS.has_feature("web") and client.state == "login")

func _focus_login() -> void :
	if _mobile:
		return
	_focus = username if username.text.is_empty() else password


func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var state: String = client.state
	if event.keycode in [KEY_ENTER, KEY_KP_ENTER] and state == "servers":
		client.select_server(_server_id())
		accept_event()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER] and state == "characters":
		_enter_character()
		accept_event()
	elif event.keycode == KEY_ESCAPE and state in ["auth", "connecting"]:
		_cancel()
		accept_event()

func _server_id() -> int:
	return int(client.config.server_entry().get("sid", 299001))

func _server_name() -> String:
	return str(client.config.server_entry().get("name", "BangBang"))

func chat_busy() -> bool:
	return true

func _cancel() -> void :
	reset()
	client.logout()


func home() -> void :
	homed += 1
	if OS.has_feature("web"):
		JavaScriptBridge.eval(HOME_JS, true)

func _enter_character() -> void :
	if client.creating or client.characters.is_empty():
		return
	client.choose_character(clampi(_pick, 0, client.characters.size() - 1))


func _open_create() -> void :
	if not _cells.has("cc_head"):
		_use(Create.FILE, Create.R)
	name_edit.text = ""
	_set_sex(true)
	if not _mobile:
		_focus = name_edit


func _set_sex(male: bool) -> void :
	_male = male
	_clip["boy"] = int(Create.LABELS["play" if male else "outplay"])
	_clip["girl"] = int(Create.LABELS["outplay" if male else "play"])
	_playing["boy"] = true
	_playing["girl"] = true
	_clip_time = 0.0


func _step(who: String) -> void :
	if not _playing[who]:
		return
	var at: int = int(_clip[who]) + 1
	if at == int(Create.LOOP[0]):
		at = int(Create.LOOP[1])
	if at >= int(Create.OUT_END):
		at = int(Create.OUT_END)
		_playing[who] = false
	_clip[who] = at


func _confirm() -> void :
	if client.creating and not name_edit.text.is_empty():
		client.create_character(name_edit.text, 1 if _male else 2)


func _double(id: String) -> bool:
	var twice: bool = _clicked == id and _time - _clicked_at <= DOUBLE
	_clicked = "" if twice else id
	_clicked_at = _time
	return twice



func _paint() -> void :
	var state: String = client.state
	if state == "auth" and _auto:
		_hide_except([])
		_auto_card()
		return
	if state in ["login", "auth"]:
		if state == "login" and reg.on:
			_hide_except(reg.edits)
			reg.paint()
			return
		_hide_except([username, password, key] if SHOW_KEY else [username, password])
		_login(state == "auth")
		return
	if state == "characters" and client.creating:
		_hide_except([name_edit])
	else:
		_hide_edits()
	_loader_bg()
	if state == "connecting":
		_loading()
	elif state == "servers":
		_servers()
	elif state == "characters":
		if client.creating:
			_create()
		else:
			_characters()
	elif state in ["lobby", "hall", "room"]:
		_loading()
	_attention()


func _hide_except(kept: Array) -> void :
	for edit: LineEdit in _edits:
		if edit.visible and not kept.has(edit):
			edit.visible = false
			edit.release_focus()


func _login_bg() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.027, 0.067, 0.106))
	var picture: Texture2D = pack.picture(LOGIN_BG)
	if picture == null:
		return
	var fit: float = maxf(size.x / maxf(1.0, picture.get_width()), size.y / maxf(1.0, picture.get_height()))
	var shown: Vector2 = Vector2(picture.get_size()) * fit
	draw_texture_rect(picture, Rect2((size - shown) / 2.0, shown), false)


func _loader_bg() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color.BLACK)
	var picture: Texture2D = pack.picture(LOADER_BG)
	if picture == null:
		return
	var full: Vector2 = Vector2(picture.get_size())
	var fit: float = maxf(1.0, maxf(_fw / maxf(1.0, full.x), _fh / maxf(1.0, full.y))) * _f
	var shown: Vector2 = full * fit
	draw_texture_rect(picture, Rect2(((size - shown) / 2.0).round(), shown), false)


func _variant(font: Font, gap: int) -> Font:
	if gap == 0:
		return font
	var tag: String = "%d:%d" % [font.get_instance_id(), gap]
	if not _variants.has(tag):
		var variant: FontVariation = FontVariation.new()
		variant.base_font = font
		if font is FontVariation:
			variant.variation_opentype = (font as FontVariation).variation_opentype
			variant.opentype_features = (font as FontVariation).opentype_features
		variant.spacing_glyph = gap
		_variants[tag] = variant
	return _variants[tag]


func _spaced(label: String, font: Font, px: float, color: Color, at: Vector2, spacing: float = 0.0, align: String = "l") -> float:
	var font_size: int = maxi(6, roundi(px * _f))
	var face: Font = _variant(font, roundi(spacing * _f))
	var wide: float = face.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var x: float = at.x * _f
	if align == "c":
		x -= wide / 2.0
	elif align == "r":
		x -= wide
	var y: float = at.y * _f + (face.get_ascent(font_size) - face.get_descent(font_size)) / 2.0
	draw_string(face, Vector2(x, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	return wide / _f


func _flen(label: String, font: Font, px: float) -> float:
	return font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f


func _wrap(label: String, font: Font, px: float, wide: float) -> PackedStringArray:
	var lines: PackedStringArray = PackedStringArray()
	var line: String = ""
	for word: String in label.split(" ", false):
		var joined: String = word if line.is_empty() else line + " " + word
		if line.is_empty() or _flen(joined, font, px) <= wide:
			line = joined
			continue
		lines.append(line)
		line = word
		if lines.size() == 4:
			return lines
	if not line.is_empty():
		lines.append(line)
	return lines


func _error_lines(busy: bool) -> PackedStringArray:
	if busy or (client.error_code.is_empty() and client.status in QUIET):
		return PackedStringArray()
	return _wrap(client.status, ARIAL, 13, 332)


func _logo_grow(error_h: float) -> float:
	if logo == null:
		return 0.0
	return clampf(floorf(_fh + 0.01) - 8.0 - (_card_h() + error_h), 0.0, LOGO_GROW)


func _card_h() -> float:
	return CARD_H if SHOW_KEY else CARD_H - KEY_ROW


func _logo_rect(o: Vector2, sub_y: float) -> Rect2:
	var k: float = (sub_y - 13.0 - LOGO_TOP) / LOGO_SOLID.size.y
	var at: Vector2 = o + Vector2(CARD_W / 2.0 - LOGO_SOLID.get_center().x * k, LOGO_TOP - LOGO_SOLID.position.y * k)
	return Rect2(at * _f, logo.get_size() * k * _f)


func _draw_logo(box: Rect2) -> void :
	draw_texture_rect(logo, box, false)
	var mark: Rect2 = badge_rect(box)
	if mark.size.x <= 0.0:
		return
	if badge != null:
		draw_texture_rect(badge, mark, false)
		return
	_round(mark, Color("0b5f73"), mark.size.y * 0.3 / _f, Color.WHITE, 2.0)
	_spaced(PBE_BADGE_TEXT, ARIAL_BOLD, mark.size.y * 0.62 / _f, Color.WHITE, mark.get_center() / _f, 1.0, "c")


func badge_rect(box: Rect2) -> Rect2:
	if PBE_BADGE_TEXT.is_empty() or logo == null:
		return Rect2()
	var k: float = box.size.x / logo.get_size().x
	var solid: Rect2 = Rect2(box.position + LOGO_SOLID.position * k, LOGO_SOLID.size * k)
	var high: float = solid.size.y * PBE_BADGE_HIGH
	var wide: float = high * badge.get_size().x / badge.get_size().y if badge != null else high * 2.1
	var corner: Vector2 = solid.position + solid.size * PBE_BADGE_AT
	return Rect2(corner - Vector2(wide, high), Vector2(wide, high))


func _login(busy: bool) -> void :
	_login_bg()
	var lines: PackedStringArray = _error_lines(busy)
	var error_h: float = 0.0 if lines.is_empty() else 22.0 + ERROR_LINE * lines.size()
	var rise: float = _logo_grow(error_h)
	var high: float = _card_h() + error_h + rise
	var o: Vector2 = _centre(CARD_W, high)
	o.y = maxf(0.0, o.y)
	_card.set_corner_radius_all(maxi(1, roundi(14.0 * _f)))
	_card.set_border_width_all(maxi(1, roundi(_f)))
	_card.shadow_size = maxi(1, roundi(40.0 * _f))
	_card.shadow_offset = Vector2(0, 24.0 * _f)
	draw_style_box(_card, Rect2(o * _f, Vector2(CARD_W, high) * _f))

	if _close_shown():
		var shut: float = float(_lift.get("close", 0.0))
		var close_pos: Vector2 = o + Vector2(402, 29)
		if shut > 0.0:
			draw_circle(close_pos * _f, 13.0 * _f, Color(1, 1, 1, 0.08 * shut))
		_spaced("×", ARIAL, 26.0 * (1.0 + 0.08 * shut), CLOSE.lerp(CLOSE_LIT, shut), close_pos, 0.0, "c")
		_hit("close", Rect2((o + Vector2(388, 15)) * _f, Vector2(28, 28) * _f), false)
	if logo != null:
		_draw_logo(_logo_rect(o, SUB_Y + rise))
		_spaced(SUBTITLE, ARIAL, 14, SOFT, o + Vector2(CARD_W / 2.0, SUB_Y + rise), 0.0, "c")
		o.y += rise
	else:
		_spaced(KICKER, ARIAL_BOLD, 10, ACCENT, o + Vector2(36, 46.75), 2.0)
		_spaced(HEADLINE, ARIAL_BOLD, 28, Color.WHITE, o + Vector2(36, 83.6), -2.0)
		_spaced(SUBTITLE, ARIAL, 14, SOFT, o + Vector2(36, SUB_Y))
	var edits: Array[LineEdit] = [username, password, key]
	for i in range(FIELDS.size() if SHOW_KEY else 2):
		var row: Array = FIELDS[i]
		var edit: LineEdit = edits[i]
		_spaced(str(row[0]), ARIAL_BOLD, 11, LABEL, o + Vector2(36, float(row[1])), 1.0)
		var place: Rect2 = Rect2(o + Vector2(36, float(row[2])), Vector2(358, 46))
		var box: Rect2 = Rect2(place.position * _f, place.size * _f)
		var lit: bool = edit.has_focus()
		if lit:
			_round(box.grow(3.0 * _f), Color(ACCENT, 0.25), 20.0)
		_round(box, FIELD, 14.0, ACCENT if lit else FIELD_EDGE, 2.0)
		for look: String in ["normal", "focus", "read_only"]:
			var empty: StyleBox = edit.get_theme_stylebox(look)
			empty.content_margin_left = 14.0 * _f
			empty.content_margin_right = 14.0 * _f
		_fput(edit, place, 16, "l", not busy)
	if not SHOW_KEY:
		o.y -= KEY_ROW

	var tick: Rect2 = Rect2((o + Vector2(36, 408)) * _f, Vector2(16, 16) * _f)
	_round(tick, ACCENT if _remember else FIELD, 5.0, ACCENT if _remember else FIELD_EDGE, 1.5)
	if _remember:
		draw_polyline(PackedVector2Array([tick.position + Vector2(3.5, 8.5) * _f, tick.position + Vector2(6.5, 11.5) * _f, 
			tick.position + Vector2(12.5, 4.5) * _f]), Color(0.02, 0.14, 0.07), maxf(1.8, 2.2 * _f), true)
	var said: float = _spaced(REMEMBER_APP if native_auth else REMEMBER, ARIAL, 13, SOFT, o + Vector2(60, 416))
	_hit("remember", Rect2((o + Vector2(32, 404)) * _f, Vector2(32.0 + said, 24) * _f), false)

	var lift: float = float(_lift.get("submit", 0.0))
	var plate: Rect2 = Rect2((o + Vector2(36, 442)) * _f, Vector2(358, 52) * _f)
	var grow: float = 1.0 + 0.03 * lift
	var shown: Rect2 = Rect2(plate.get_center() - plate.size * grow / 2.0, plate.size * grow)
	_round(shown, SUBMIT if lift == 0.0 else SUBMIT.lerp(SUBMIT_LIT, lift), 14.0)
	_spaced(BUSY_TEXT if busy else SUBMIT_TEXT, ARIAL_BOLD, 12.0 * grow, SUBMIT_INK, shown.get_center() / _f, 0.7 * grow, "c")
	_hit("submit", plate, false)
	if not lines.is_empty():
		_round(Rect2((o + Vector2(36, 496)) * _f, Vector2(358, error_h) * _f), ERROR_FILL, 12.0, ERROR_EDGE, 2.0)
		for i in range(lines.size()):
			_spaced(lines[i], ARIAL, 13, ERROR_INK, o + Vector2(49, 496.0 + 11.0 + ERROR_LINE * (i + 0.5)))

	reg.entry(o + Vector2(0, 496.0 + error_h), busy)
	if _focus != null and _focus.visible and _focus.editable:
		_focus.grab_focus()
		_focus = null


func _auto_card() -> void :
	_login_bg()
	var rise: float = LOGO_GROW if logo != null else 0.0
	var mid: float = SUB_Y + rise
	var high: float = mid + 142.0
	var o: Vector2 = _centre(CARD_W, high)
	o.y = maxf(0.0, o.y)
	_card.set_corner_radius_all(maxi(1, roundi(14.0 * _f)))
	_card.set_border_width_all(maxi(1, roundi(_f)))
	_card.shadow_size = maxi(1, roundi(40.0 * _f))
	_card.shadow_offset = Vector2(0, 24.0 * _f)
	draw_style_box(_card, Rect2(o * _f, Vector2(CARD_W, high) * _f))
	if logo != null:
		_draw_logo(_logo_rect(o, mid))
	else:
		_spaced(KICKER, ARIAL_BOLD, 10, ACCENT, o + Vector2(CARD_W / 2.0, 46.75), 2.0, "c")
		_spaced(HEADLINE, ARIAL_BOLD, 28, Color.WHITE, o + Vector2(CARD_W / 2.0, 83.6), -2.0, "c")
	_spaced(AUTO_TEXT, ARIAL_BOLD, 16, Color.WHITE, o + Vector2(CARD_W / 2.0, mid + 2.0), 0.5, "c")
	_spaced(username.text, ARIAL, 13, SOFT, o + Vector2(CARD_W / 2.0, mid + 28.0), 0.0, "c")
	var track: Rect2 = Rect2((o + Vector2(36, mid + 46.0)) * _f, Vector2(358, 3) * _f)
	draw_rect(track, FIELD_EDGE)
	var run: float = fposmod(_time * 0.8, 1.0)
	var from: float = clampf(run * 1.3 - 0.3, 0.0, 1.0)
	var to: float = clampf(run * 1.3, 0.0, 1.0)
	draw_rect(Rect2(track.position + Vector2(track.size.x * from, 0), Vector2(track.size.x * (to - from), track.size.y)), ACCENT)
	var plate: Rect2 = Rect2((o + Vector2(36, mid + 66.0)) * _f, Vector2(358, 46) * _f)
	var lit: bool = _hover == "switch"
	_round(plate, FIELD, 14.0, ACCENT if lit else FIELD_EDGE, 2.0)
	_spaced(SWITCH_TEXT, ARIAL_BOLD, 12, Color.WHITE if lit else LABEL, plate.get_center() / _f, 0.7, "c")
	_hit("switch", plate, false)


func _frame(o: Vector2, tabs: Array, chosen: int) -> void :
	_fblit("gate_bk", o + Vector2(0, 17))
	_fblit("gate_shadow", o + Vector2(16, 104))
	_fblit("gate_title", o + Vector2(239, -1))
	var x: float = 18.0
	for i in range(tabs.size()):
		var label: String = str(tabs[i])
		var id: String = "region:%d" % i
		var wide: float = maxf(105.0, ceilf(_flen(label, ARIAL_BOLD, 14)) + 25.0)
		var rect: Rect2 = _fblit("gate_region_on" if i == chosen else "gate_region", o + Vector2(x, 55), wide, 32, _glow(id))
		_fwords(label, ARIAL_BOLD, 14, Color.WHITE, "c", o + Vector2(x, 55), wide, 0, 32, false)
		_hit(id, rect, false)
		x += wide
	_fwords(LAST_LABEL, ARIAL_BOLD, 14, GREY, "l", o + Vector2(17, 387), 150, 0, 0, false)
	_fwords(PICK_LABEL, ARIAL_BOLD, 14, GREY, "l", o + Vector2(17, 407), 150, 0, 0, false)
	_fwords(_server_name(), ARIAL_BOLD, 14, ORANGE, "l", o + Vector2(162, 387), 174)
	_fwords(_server_name(), ARIAL_BOLD, 14, ORANGE, "l", o + Vector2(162, 407), 174)
	_fbutton("back", "gate_back", o + Vector2(405, 391))
	_fbutton("enter", "gate_enter", o + Vector2(519, 390))


func _servers() -> void :
	var o: Vector2 = _centre(1000, 600) + FRAME_AT
	_frame(o, [REGION], 0)
	var rect: Rect2 = _fblit("gate_server_on", o + Vector2(14, 104), 0, 0, _glow("server:0"))
	_fwords(_server_name(), ARIAL_BOLD, 14, Color.WHITE, "l", o + Vector2(50, 112), 110)
	_hit("server:0", rect, false)


func _characters() -> void :
	var o: Vector2 = _centre(1000, 600) + FRAME_AT
	_frame(o, [RECENT, REGION], 0)
	var list: Vector2 = o + Vector2(17, 105)
	var count: int = client.characters.size()
	if count == 0:
		_fwords(client.status, ARIAL_BOLD, 14, Color.WHITE, "c", list, 627, 0, 275)
		return
	var bottom: float = list.y + 275.0
	_top = clampi(_top, 0, maxi(0, ceili(count / 2.0) - 3))
	for index in range(_top * 2, count):
		var at: Vector2 = list + Vector2(294.0 * (index % 2), 76.0 * (floori(index / 2.0) - _top))
		if at.y >= bottom:
			break
		var high: float = minf(74.0, bottom - at.y)
		var id: String = "char:%d" % index
		var cell: String = "gate_char_on" if index == _pick else "gate_char"
		var rect: Rect2 = Rect2(at * _f, Vector2(294, high) * _f)
		if high >= 74.0:
			_fblit(cell, at, 0, 0, _glow(id))
		else:
			_fpart(cell, at, Rect2(0, 0, 294, high), _glow(id))
		var basic: Dictionary = client.characters[index].get("m_basic", {})
		if high > 18.0:
			_fpart("level_%d" % clampi(int(basic.get("level", 0)), 0, 40), at + Vector2(2, 18), Rect2(0, 0, 80, minf(40.0, high - 18.0)))
			if high >= 58.0:
				_level_fx(int(basic.get("level", 0)), at + Vector2(2, 18))
		if high >= 27.0:
			_fwords("N.vật: %s" % str(basic.get("name", "?")), ARIAL_BOLD, 14, Color.WHITE, "l", at + Vector2(82, 7), 206)
		if high >= 45.0:
			_fwords("Server: %s" % _server_name(), ARIAL_BOLD, 12, Color.WHITE, "l", at + Vector2(82, 29), 206)
		_hit(id, rect, false)



func _create() -> void :
	var o: Vector2 = _centre(1000, 600)
	var nodes: Dictionary = Create.NODES
	for pair: Array in [["cc_head", "imgBg"], ["cc_title", "imgTitle"], ["cc_input", "txtCharName"]]:
		var spot: Array = nodes[pair[1]]
		_fblit(pair[0], o + Vector2(float(spot[0]), float(spot[1])))
	for pair: Array in [["sex:1", "btnMale", "cc_male"], ["sex:2", "btnFemale", "cc_female"], ["create", "btnConfirm", "cc_ok"]]:
		var spot: Array = nodes[pair[1]]
		var at: Vector2 = o + Vector2(float(spot[0]), float(spot[1]))
		var tint: Color = _glow(pair[0])
		var rect: Rect2 = _fblit(pair[2], at, 0, 0, tint)
		if pair[0] == ("sex:1" if _male else "sex:2"):
			_fblit("cc_sel", at + Vector2(float(Create.RING[0]), float(Create.RING[1])), 0, 0, tint)
		_hit(pair[0], rect, false)
	var tip: Array = Create.TIP
	_fwords(client.status, ARIAL_BOLD, float(tip[4]), Color(str(tip[5])), "c", o + Vector2(0, float(tip[1])), 1000, 0, 0, false)
	var box: Array = nodes["txtCharName"]
	var edit: Array = Create.EDIT
	_fput(name_edit, Rect2(o + Vector2(float(box[0]) + float(edit[0]), float(box[1]) + float(edit[1])), 
		Vector2(float(box[2]) - float(edit[0]) - float(edit[2]), float(edit[3]) + 8.0)), float(edit[3]))
	for who: String in ["boy", "girl"]:
		_figure(who, o + Vector2(float(Create.AT[who][0]), float(Create.AT[who][1])))
	if _focus != null and _focus.visible and _focus.editable:
		_focus.grab_focus()
		_focus = null


func _figure(who: String, at: Vector2) -> void :
	var cell: Array = _cells.get("cc_%s_3" % who, [])
	if cell.is_empty() or cell[0] == null:
		return
	var texture: Texture2D = cell[0]
	var frame: Array = Create.FILM[clampi(int(_clip[who]), 0, Create.FILM.size() - 1)]
	var stage: Transform2D = Transform2D(0.0, Vector2(_f, _f), 0.0, at * _f)
	for row: Array in frame:
		var part: Array = _cells.get("cc_%s_%d" % [who, int(row[0])], [])[1]
		var corner: Array = Create.ORIGIN[who][str(int(row[0]))]
		var color: Color = Color(float(row[7]) + float(row[11]) / 255.0, float(row[8]) + float(row[12]) / 255.0, 
			float(row[9]) + float(row[13]) / 255.0, clampf(float(row[10]) + float(row[14]) / 255.0, 0.0, 1.0))
		if color.a <= 0.0:
			continue
		draw_set_transform_matrix(stage * Transform2D(Vector2(float(row[1]), float(row[2])), Vector2(float(row[3]), float(row[4])), 
			Vector2(float(row[5]), float(row[6]))))
		draw_texture_rect_region(texture, Rect2(float(corner[0]), float(corner[1]), float(part[2]), float(part[3])), 
			Rect2(float(part[0]), float(part[1]), float(part[2]), float(part[3])), color)
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _loading() -> void :
	var at: Vector2 = Vector2(roundf(_fw / 2.0 - 416.0), roundf(_fh - 134.5))
	var done: int = clampi(int(_percent), 1, 100)
	_fblit("gate_track", at)
	_fpart("gate_fill", at, Rect2(0, 0, minf(832.0, 11.0 + 8.2 * (done - 1)), 29))
	var spark: Vector2 = at + Vector2(-4.0 + 8.1 * (done - 1), -15.05)
	_fblit("gate_spark", spark, 0, 0, Color(1, 1, 1, 169.0 / 256.0))
	_fblit("gate_spark", spark, 0, 0, Color(1, 1, 1, SPARK[int(_time * 24.0) % SPARK.size()]))
	_fblit("gate_streak", at + Vector2(-59.5 + 8.1 * (done - 1), 9.95))
	_fwords(LOBBY_STATUS if client.state in ["lobby", "hall", "room"] else client.status, ARIAL_BOLD, 16, Color.WHITE, "c", Vector2(_fw / 2.0 - 300.0, _fh - 160.0), 600, 2, 30, true, Color("2e4b9f", 0.8))
	_fwords("%d%%" % done, ARIAL, 16, Color("c1f0ff"), "c", Vector2(_fw / 2.0 - 100.0, _fh - 114.5), 200, 2, 30, false, Color("717183", 0.8))


func _attention() -> void :
	_fwords(ATTENTION[0], ARIAL, 12, Color.WHITE, "c", Vector2(0, _fh - 30.0), _fw, 1, 0, false, Color(0, 0, 0, 0.5))
	_fwords(ATTENTION[1], ARIAL, 12, Color.WHITE, "c", Vector2(0, _fh - 16.0), _fw, 1, 0, false, Color(0, 0, 0, 0.5))

func _wheel(step: int, _at: Vector2) -> void :
	if client.state == "characters":
		_top = clampi(_top + step, 0, maxi(0, ceili(client.characters.size() / 2.0) - 3))

func _activate(id: String) -> void :
	if id.begins_with("reg:"):
		reg.activate(id)
		return
	var state: String = client.state
	if id == "submit":
		sign_in()
	elif id == "remember":
		_remember = not _remember
		if not _remember:
			_store()
			_forget()
	elif id == "switch":
		_cancel()
		username.clear()
		_focus_login()
	elif id == "close":
		if state == "auth":
			_cancel()
		else:
			home()
	elif id in ["back", "cancel", "signout"]:
		_cancel()
	elif id == "enter":
		if state == "servers":
			client.select_server(_server_id())
		elif state == "characters":
			_enter_character()
	elif id.begins_with("region:"):
		if state == "characters" and id != "region:0":
			say("Chọn nhân vật để vào game.")
	elif id == "server:0":
		if _double(id):
			client.select_server(_server_id())
	elif id == "sex:1" or id == "sex:2":
		_set_sex(id == "sex:1")
	elif id == "create":
		_confirm()
	elif id.begins_with("char:"):
		var index: int = int(id.substr(5))
		_pick = index
		if _double(id):
			client.choose_character(index)
