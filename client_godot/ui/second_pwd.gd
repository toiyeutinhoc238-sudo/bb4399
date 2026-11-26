extends "flash_screen.gd"












const Atlas = preload("second_pwd_atlas.gd")
const AccCards = preload("acc_cards.gd")
const St2Skin = preload("st2_skin.gd")
const St2Atlas = preload("st2_atlas.gd")

signal closed

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const ASK_DIM: Color = Color(0, 0, 0, 0.35)
const SHOW_IN: Array = ["lobby", "hall", "room", "battle"]
const ASK: Vector2 = Vector2(450, 220)
const INPUTS: Array = ["txtOldPwd", "txtInputPwd", "txtConfrimPwd"]
const MIN_LEN: int = 6
const LINK: Color = Color("b4ff3c")

const ROWS: Dictionary = {"set": {"txtInputPwd": 110.0, "txtConfrimPwd": 156.0}, 
	"reset": {"txtOldPwd": 100.0, "txtInputPwd": 144.0, "txtConfrimPwd": 188.0}, 
	"unlock": {"txtInputPwd": 104.0}, "check": {"txtInputPwd": 104.0}}
const FIELD_X: float = 120.0
const FIELD_W: float = 218.0
const FIELD_H: float = 36.0
const OK_AT: Dictionary = {"set": [75.0, 226.0, 210.0, 42.0], "reset": [75.0, 226.0, 210.0, 42.0], "unlock": [75.0, 228.0, 210.0, 42.0], 
	"check": [75.0, 142.0, 210.0, 42.0]}
const CHECK_Y: Dictionary = {"set": 198.0, "unlock": 206.0}
const TOAST_IN: Rect2 = Rect2(30, 164, 300, 28)

var mode: String = ""
var _inputs: Dictionary = {}
var _help: bool = false
var _ask: String = ""
var _ask_text: String = ""
var _cancel_shown: bool = false
var _focus: String = ""

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	for name: String in INPUTS:
		var edit: LineEdit = _fedit(int(Atlas.INPUT["max"]))
		edit.secret = true
		edit.secret_character = "*"
		edit.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PASSWORD
		edit.add_theme_font_override("font", St2Skin.BOLD)
		edit.text_changed.connect( func(value: String) -> void : _restrict(edit, value))
		_inputs[name] = edit
	if client != null:
		client.changed.connect(_follow)


func _follow() -> void :
	if visible and (client == null or client.state not in SHOW_IN):
		close()


func open(value: String) -> void :
	if visible or client == null or client.state not in SHOW_IN or not Atlas.SIZE.has(value) or value == "help":
		return
	_help = false
	_ask = ""
	_toast = ""
	_hover = ""
	_press = ""
	_cancel_shown = client.pwd_ticket > 0
	_set_mode(value)
	visible = true
	queue_redraw()


func _set_mode(value: String) -> void :
	mode = value
	for edit: LineEdit in _inputs.values():
		edit.text = ""
	_hide_edits()
	_focus = "txtOldPwd" if value == "reset" else "txtInputPwd"

func close() -> void :
	if not visible:
		return
	_hide_edits()
	for edit: LineEdit in _inputs.values():
		edit.text = ""
	visible = false
	mode = ""
	_help = false
	_ask = ""
	closed.emit()

func field(name: String) -> String:
	return (_inputs[name] as LineEdit).text if _inputs.has(name) else ""

func set_field(name: String, value: String) -> void :
	if _inputs.has(name):
		(_inputs[name] as LineEdit).text = value

func help_open() -> bool:
	return _help

func asking() -> String:
	return _ask


func _restrict(edit: LineEdit, value: String) -> void :
	var clean: String = ""
	for i in range(value.length()):
		var c: String = value[i]
		if (c >= "0" and c <= "9") or (c >= "a" and c <= "z") or (c >= "A" and c <= "Z"):
			clean += c
	if clean != value:
		var caret: int = edit.caret_column
		edit.text = clean
		edit.caret_column = mini(caret, clean.length())


static func left_text(left: int) -> String:
	return AccCards.day_hours(left) if left > AccCards.DAY else AccCards.hours_minutes(left)

static func notice_text(left: int) -> String:
	return str(Atlas.WORDS["PWD_TIP17"]).replace("@time@", left_text(left))


static func tip_for(op: int, ok: bool, lock: bool) -> String:
	var pair: Array = {1: ["PWD_TIP8", "PWD_TIP9"], 2: ["PWD_TIP6", "PWD_TIP7"], 3: ["PWD_TIP1", "PWD_TIP2"], 4: ["PWD_TIP10", "PWD_TIP11"], 
		5: ["PWD_TIP12", "PWD_TIP2"], 6: ["PWD_TIP13", "PWD_TIP14"], 7: ["PWD_TIP15", "PWD_TIP16"]}.get(op, [])
	if pair.is_empty():
		return str(int(ok))
	if op == 7:
		return str(Atlas.WORDS[pair[0] if lock else pair[1]])
	return str(Atlas.WORDS[pair[0] if ok else pair[1]])


static func help_text() -> String:
	return str(Atlas.WORDS["HELP_TEXT"]).replace("Bạc) đề sẽ", "Bạc) đều sẽ")


static func ok_text(value: String) -> String:
	return "Mở khóa" if value in ["unlock", "check"] else "Xác nhận"

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))


func origin() -> Vector2:
	var box: Array = Atlas.SIZE.get(mode, [360, 280])
	return _centre(float(box[0]), float(box[1]))




func _brect(at: Vector2, x: float, y: float, w: float, h: float) -> Rect2:
	return Rect2((at + Vector2(x, y)) * _f, Vector2(w, h) * _f)

func _st2_icon(name: String, centre: Vector2, high: float, tint: Color = Color.WHITE) -> Rect2:
	return St2Skin.icon(self, name, centre * _f, high * _f, tint)


func _head(at: Vector2, wide: float, title: String, lock_x: float, text_x: float, close: String) -> void :
	_st2_icon("lock_title", at + Vector2(lock_x, 38), 48.0)
	St2Skin.words(self, St2Skin.XBOLD, title, 25.0 * _f, _brect(at, text_x, 20, wide - text_x - 52.0, 38), Color.WHITE, "l", St2Skin.RIM, 4.0 * _f, 
		Color(0, 0.1, 0.3, 0.5))
	var x: Rect2 = _st2_icon("close", at + Vector2(wide - 26.0, 25), 34.0, Color(_shine(close), _shine(close), _shine(close)))
	_hit(close, x.grow(3.0 * _f), false)


func _pbtn(id: String, r: Rect2, kind: String, value: String, px: float) -> void :
	St2Skin.button(self, r, _f, kind, value, px, _shine(id))
	_hit(id, r, false)

func _paint() -> void :
	if mode.is_empty():
		return
	var box: Array = Atlas.SIZE[mode]
	var wide: float = float(box[0])
	var high: float = float(box[1])
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = origin()
	var frame: Rect2 = Rect2(at * _f, Vector2(wide, high) * _f)
	_hit("panel", frame, false)
	St2Skin.dialog(self, frame, _f)
	_head(at, wide, str(Atlas.TITLES[mode][0]), 66.0, 98.0, "close")
	var rows: Dictionary = ROWS[mode]
	var labels: Dictionary = Atlas.LABELS[mode]
	var live: bool = _ask.is_empty() and not _help
	for name: String in INPUTS:
		if not rows.has(name):
			continue
		var edit: LineEdit = _inputs[name]
		var cy: float = float(rows[name])
		St2Skin.words(self, St2Skin.XBOLD, str(labels[name][0]), 17.0 * _f, _brect(at, 20, cy - 16.0, FIELD_X - 26.0, 32), Color.WHITE, "l", St2Skin.RIM, 3.0 * _f)
		St2Skin.field(self, _brect(at, FIELD_X, cy - FIELD_H / 2.0, FIELD_W, FIELD_H), _f, live and edit.has_focus())
		if live:
			_fput(edit, Rect2(at + Vector2(FIELD_X + 12.0, cy - FIELD_H / 2.0 + 3.0), Vector2(FIELD_W - 18.0, FIELD_H - 6.0)), 18.0)
	if live and not _focus.is_empty():
		var want: LineEdit = _inputs[_focus]
		_focus = ""
		if not _mobile and want.visible:
			want.grab_focus()
	elif not live:
		_hide_edits()
	var ok: Array = OK_AT[mode]
	_pbtn("ok", _brect(at, float(ok[0]), float(ok[1]), float(ok[2]), float(ok[3])), "green", ok_text(mode), 22.0)
	if mode == "unlock":
		_pbtn("change", _brect(at, 18, 126, 158, 32), "blue", "Sửa mật mã", 16.0)
		if _cancel_shown:
			_pbtn("cancel_clean", _brect(at, 184, 126, 158, 32), "orange", "Hủy xóa", 16.0)
		else:
			_pbtn("clean", _brect(at, 184, 126, 158, 32), "blue", "Xóa mật mã", 16.0)
	_paint_help_link(at, wide)
	if CHECK_Y.has(mode):
		_paint_relive(at, wide, float(CHECK_Y[mode]))
	if _help:
		_paint_help(at, wide, high)
	elif not _ask.is_empty():
		_paint_ask(at, wide, high)


func _paint_help_link(at: Vector2, wide: float) -> void :
	var shine: float = _shine("help")
	var q: Rect2 = _st2_icon("question", at + Vector2(wide - 104.0, 66), 26.0, Color(shine, shine, shine))
	var color: Color = St2Skin._lit(LINK, shine)
	var r: Rect2 = _brect(at, wide - 88.0, 54, 80, 24)
	var w: float = St2Skin.words(self, St2Skin.XBOLD, str(Atlas.WORDS["HELP"]), 15.0 * _f, r, color, "l", St2Skin.RIM, 2.5 * _f)
	var base: float = r.get_center().y + 8.0 * _f
	draw_line(Vector2(r.position.x, base), Vector2(r.position.x + w, base), color, maxf(1.0, 1.5 * _f))
	_hit("help", q.merge(Rect2(r.position, Vector2(w, r.size.y))).grow(2.0 * _f), false)


func _paint_relive(at: Vector2, wide: float, cy: float) -> void :
	var text: String = str(Atlas.WORDS["DESZ"])
	var px: int = maxi(6, roundi(15.0 * _f))
	var text_w: float = St2Skin.BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f
	var total: float = minf(28.0 + 10.0 + text_w, wide - 24.0)
	var left: float = floorf((wide - total) / 2.0)
	var on: bool = client != null and (int(client.character.get("setting_flag", 0)) & int(Atlas.CHECK["bit"])) == 0
	var r: Rect2 = _brect(at, left, cy - 14.0, 28, 28)
	St2Skin.check(self, r, _f, on, 1.0, _shine("relive"))
	_hit("relive", r.grow(2.0 * _f), false)
	St2Skin.words(self, St2Skin.BOLD, text, 15.0 * _f, _brect(at, left + 38.0, cy - 14.0, total - 38.0, 28), Color.WHITE, "l", St2Skin.RIM, 2.5 * _f)


func _paint_help(at: Vector2, wide: float, high: float) -> void :
	var size_help: Array = Atlas.SIZE["help"]
	var hw: float = float(size_help[0])
	var hh: float = float(size_help[1])
	var spot: Vector2 = at + Vector2(int((wide - hw) / 2.0), int((high - hh) / 2.0))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var frame: Rect2 = Rect2(spot * _f, Vector2(hw, hh) * _f)
	_hit("panel", frame, false)
	St2Skin.dialog(self, frame, _f)
	_st2_icon("lock_title", spot + Vector2(112, 36), 44.0)
	St2Skin.words(self, St2Skin.XBOLD, str(Atlas.WORDS["HELP"]), 26.0 * _f, _brect(spot, 144, 18, 200, 38), Color.WHITE, "l", St2Skin.RIM, 4.0 * _f, 
		Color(0, 0.1, 0.3, 0.5))
	var x: Rect2 = _st2_icon("close", spot + Vector2(hw - 26.0, 25), 34.0, Color(_shine("help_close"), _shine("help_close"), _shine("help_close")))
	_hit("help_close", x.grow(3.0 * _f), false)
	var px: int = maxi(6, roundi(14.0 * _f))
	var line_h: float = St2Skin.BOLD.get_height(px)
	var wrap: float = (hw - 62.0) * _f
	var y: float = (spot.y + 64.0) * _f
	for line: String in help_text().split("\n", false):
		var text: String = line.strip_edges()
		if text.is_empty():
			continue
		draw_circle(Vector2((spot.x + 30.0) * _f, y + line_h / 2.0), 5.0 * _f, Color.WHITE)
		var pos: Vector2 = Vector2((spot.x + 44.0) * _f, y + St2Skin.BOLD.get_ascent(px))
		draw_multiline_string_outline(St2Skin.BOLD, pos, text, HORIZONTAL_ALIGNMENT_LEFT, wrap, px, -1, maxi(1, roundi(2.5 * _f)), St2Skin.RIM)
		draw_multiline_string(St2Skin.BOLD, pos, text, HORIZONTAL_ALIGNMENT_LEFT, wrap, px, -1, Color.WHITE)
		y += St2Skin.BOLD.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, wrap, px).y + 7.0 * _f
	_pbtn("help_ok", _brect(spot, (hw - 190.0) / 2.0, hh - 58.0, 190, 42), "green", "Xác nhận", 21.0)


func _paint_ask(at: Vector2, wide: float, high: float) -> void :
	draw_rect(Rect2(Vector2.ZERO, size), ASK_DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var spot: Vector2 = at + Vector2(int((wide - ASK.x) / 2.0), int((high - ASK.y) / 2.0))
	var frame: Rect2 = Rect2(spot * _f, ASK * _f)
	_hit("panel", frame, false)
	St2Skin.dialog(self, frame, _f)
	var reg: Array = St2Atlas.R.get("st2_alert", [0, 0, 0, 80])
	St2Skin.icon(self, "alert", (spot + Vector2(58, 78)) * _f, float(reg[3]) / St2Atlas.SCALE * _f)
	var px: int = maxi(6, roundi(15.0 * _f))
	var wrap: float = 318.0 * _f
	var lines: float = St2Skin.BOLD.get_multiline_string_size(_ask_text, HORIZONTAL_ALIGNMENT_LEFT, wrap, px).y / maxf(1.0, St2Skin.BOLD.get_height(px))
	var top: float = (spot.y + 78.0) * _f - lines * St2Skin.BOLD.get_height(px) / 2.0 + St2Skin.BOLD.get_ascent(px)
	var pos: Vector2 = Vector2((spot.x + 108.0) * _f, top)
	draw_multiline_string_outline(St2Skin.BOLD, pos, _ask_text, HORIZONTAL_ALIGNMENT_LEFT, wrap, px, 5, maxi(1, roundi(3.0 * _f)), St2Skin.RIM)
	draw_multiline_string(St2Skin.BOLD, pos, _ask_text, HORIZONTAL_ALIGNMENT_LEFT, wrap, px, 5, Color.WHITE)
	_pbtn("ask_ok", _brect(spot, 90, 160, 120, 38), "green", "Xác nhận", 17.0)
	_pbtn("ask_no", _brect(spot, 240, 160, 120, 38), "blue", "Hủy", 17.0)


func _draw_toast() -> void :
	if mode.is_empty():
		super ()
		return
	var age: float = _time - _toast_at
	if _toast.is_empty() or age > 2.6:
		return
	var alpha: float = clampf(minf(age / 0.15, (2.6 - age) / 0.4), 0.0, 1.0)
	var at: Vector2 = origin()
	var box: Array = Atlas.SIZE[mode]
	var r: Rect2 = Rect2((at + TOAST_IN.position) * _f, TOAST_IN.size * _f)
	if mode != "unlock" or _help or not _ask.is_empty():
		var high: float = float(box[1])
		var over: float = float(Atlas.SIZE["help"][1]) if _help else ASK.y if not _ask.is_empty() else high
		r = _brect(at, 30, maxf(high, (high + over) / 2.0) + 10.0, 300, 32)
	St2Skin.grad(self, r, r.size.y / 2.0, Color("fdfa56", alpha), Color("ffd923", alpha), Color("fff8c0", alpha), maxf(1.0, 1.5 * _f))
	St2Skin.icon(self, "warn", Vector2(r.position.x + 20.0 * _f, r.get_center().y), r.size.y * 0.66, Color(1, 1, 1, alpha))
	St2Skin.words(self, St2Skin.XBOLD, _toast, 15.0 * _f, Rect2(r.position + Vector2(38.0 * _f, 0), Vector2(r.size.x - 48.0 * _f, r.size.y)), 
		Color("6a3200", alpha), "c")



func _activate(id: String) -> void :
	if not _ask.is_empty():
		if id == "ask_ok":
			var kind: String = _ask
			_ask = ""
			if not client.protect_pwd_op(5 if kind == "clean" else 4):
				say(str(Atlas.WORDS["PWD_TIP2"]))
		elif id == "ask_no":
			_ask = ""
		return
	if _help:
		if id in ["help_close", "help_ok"]:
			_help = false
		return
	match id:
		"close":
			close()
		"ok":
			_confirm()
		"change":
			_set_mode("reset")
		"clean":
			_open_ask("clean", str(Atlas.WORDS["TIP_359"]))
		"cancel_clean":
			var left: int = client.pwd_ticket - int(Time.get_unix_time_from_system())
			_open_ask("cancel", str(Atlas.WORDS["TIP_360"]).replace("@time@", left_text(left)))
		"help":
			_help = true
			_hide_edits()
		"relive":
			if client.character.has("setting_flag"):
				client.change_setting(int(client.character["setting_flag"]) ^ int(Atlas.CHECK["bit"]))

func _open_ask(kind: String, text: String) -> void :
	_ask = kind
	_ask_text = text
	_hover = ""
	_press = ""
	_hide_edits()


func _confirm() -> void :
	var first: String = field("txtInputPwd")
	var again: String = field("txtConfrimPwd")
	var old: String = field("txtOldPwd")
	var tip: String = ""
	var sent: bool = true
	match mode:
		"set":
			if again != first:
				tip = "TIP_357"
			elif first.is_empty() or again.is_empty():
				tip = "TIP_358"
			elif again.length() < MIN_LEN:
				tip = "TIP_364"
			else:
				sent = client.protect_pwd_op(3, first)
		"reset":
			if again != first:
				tip = "TIP_357"
			elif old == first:
				tip = "TIP_361"
			elif old.is_empty() or first.is_empty() or again.is_empty():
				tip = "TIP_358"
			elif again.length() < MIN_LEN:
				tip = "TIP_364"
			else:
				sent = client.protect_pwd_op(6, old, first)
		_:
			if first.is_empty():
				tip = "TIP_358"
			else:
				sent = client.protect_pwd_op(1, first)
	if not tip.is_empty():
		say(str(Atlas.WORDS[tip]))
	elif not sent:
		say(str(Atlas.WORDS["PWD_TIP2"]))

func _input(event: InputEvent) -> void :
	if not visible or not is_visible_in_tree() or not (event is InputEventKey):
		return
	var key: InputEventKey = event
	if key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
		if not _ask.is_empty():
			_ask = ""
		elif _help:
			_help = false
		else:
			close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
