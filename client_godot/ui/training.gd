extends "flash_screen.gd"















const Arena = preload("arena_atlas.gd")
const Atlas = preload("training_atlas.gd")

signal closed

const SHOW_IN: Array = ["lobby"]
const PLAYABLE: Array = [101, 102]
const MODE_LIVE: int = 3
const MODE_BASE: int = 1
const MODE_OCCUPY: int = 2
const TEACH: Array = [82]
const MODES: Dictionary = {"hot": MODE_LIVE, "base": MODE_BASE, "flag": MODE_OCCUPY}
const BUTTONS: Dictionary = {"hot": ["btnHot", "image9"], "base": ["btnBase", "image7"], "flag": ["btnFlag", "image8"]}
const SOON: String = "Bản đồ huấn luyện này đang được chuyển sang HTML5."
const OFFLINE: String = "Chưa kết nối máy chủ, thử lại sau."
const LINE: float = 20.0

var _tab: String = "pvp"
var _mode: int = MODE_LIVE
var _list: Array = []
var _sel: int = 0

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	if client != null:
		client.changed.connect(_follow)


func _follow() -> void :
	if visible and (client == null or client.state not in SHOW_IN):
		close()

func open() -> void :
	if visible or client == null or client.state not in SHOW_IN:
		return
	_tab = "pvp"
	_show_mode(MODE_LIVE)
	_hover = ""
	_press = ""
	_toast = ""
	visible = true

func close() -> void :
	if not visible:
		return
	visible = false
	closed.emit()




static func maps_of(mode: int) -> Array:
	return Array(Atlas.LISTS.get(str(mode), []))

static func map_name(id: int) -> String:
	var row: Array = Atlas.MAPS.get(str(id), [])
	return str(row[0]) if not row.is_empty() else str(id)

static func map_desc(id: int) -> String:
	var row: Array = Atlas.MAPS.get(str(id), [])
	return str(row[1]) if not row.is_empty() else ""

func tab() -> String:
	return _tab

func mode() -> int:
	return _mode

func maps() -> Array:
	return _list.duplicate()

func selected() -> int:
	return int(_list[_sel]) if _sel >= 0 and _sel < _list.size() else 0

func _show_mode(value: int) -> void :
	_mode = value
	_list = maps_of(value)
	_sel = 0

func _show_teach() -> void :
	_list = TEACH.duplicate()
	_sel = 0



func _xy(spot: Array) -> Vector2:
	return Vector2(roundf(float(spot[0])), roundf(float(spot[1])))

func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Atlas.FILE, Atlas.R)
	var at: Vector2 = _window(float(Atlas.FRAME[0]), float(Atlas.FRAME[1]))
	_fblit("tr_title", at + _xy(Atlas.AT["title"]))
	_fbutton("ok", "tr_confirm", at + _xy(Atlas.AT["btnConfirm"]))
	_fblit("tr_outer", at + _xy(Atlas.AT["outer"]))
	var pvp: bool = _tab == "pvp"
	_fbutton("tab:teach", "tr_tab_teach_off" if pvp else "tr_tab_teach_on", at + _xy(Atlas.AT["btnTutorial"]))
	_fblit("tr_roomtype_bk", at + _xy(Atlas.AT["image9"]))
	if pvp:
		for key: String in BUTTONS:
			var pair: Array = BUTTONS[key]
			if key != "hot":
				_fblit("tr_roomtype_bk", at + _xy(Atlas.AT[pair[1]]))
			_fbutton("mode:" + key, "tr_%s_%s" % [key, "on" if int(MODES[key]) == _mode else "off"], at + _xy(Atlas.AT[pair[0]]))
	else:
		_fbutton("mode:happy", "tr_happy_on", at + _xy(Atlas.AT["btnHappy"]))
	_fbutton("tab:pvp", "tr_tab_pvp_on" if pvp else "tr_tab_pvp_off", at + _xy(Atlas.AT["btnPvp"]))
	_draw_accordion(at + _xy(Atlas.AT["acc"]))
	_fblit("tr_build_pvp" if pvp else "tr_build_teach", at + _xy(Atlas.AT["imgBuild" if pvp else "imgBuildTeach"]))


func _draw_accordion(base: Vector2) -> void :
	var wide: float = float(Atlas.AT["acc"][2])
	var head: float = float(Atlas.HEADER[0])
	var body: float = maxf(0.0, float(Atlas.AT["acc"][3]) - head * _list.size())
	var y: float = 0.0
	for i in range(_list.size()):
		var id: String = "head:%d" % i
		var rect: Rect2 = _fblit("tr_head_on" if i == _sel else "tr_head", base + Vector2(0, y), wide, head, _glow(id) if i != _sel else Color.WHITE)
		if i != _sel:
			_hit(id, rect, false)
		var pad: float = float(Atlas.HEADER[2])
		_fwords(map_name(int(_list[i])), ARIAL_BOLD, float(Atlas.HEADER[1]), Color(str(Atlas.HEADER[3])), "l", base + Vector2(pad, y), wide - pad - 8.0, 0.0, head)
		y += head
		if i == _sel:
			_draw_content(base + Vector2(0, y), body, map_desc(int(_list[i])))
			y += body


func _draw_content(base: Vector2, high: float, text: String) -> void :
	var edge: float = float(Atlas.CONTENT["edge"])
	var wide: float = float(Atlas.CONTENT["w"])
	if high < edge * 2.0:
		return
	_fblit("tr_top", base, wide, edge)
	_fblit("tr_mid", base + Vector2(0, edge), wide, high - edge * 2.0)
	_fblit("tr_btm", base + Vector2(0, high - edge), wide, edge)
	var spec: Array = Atlas.CONTENT["desc"]
	var px: float = float(spec[4])
	var left: Vector2 = base + Vector2(float(spec[0]), float(spec[1]))
	var room: int = int(floorf((minf(float(spec[3]), high - float(spec[1])) - 2.0) / LINE))
	var lines: Array = wrap_lines(text, px, float(spec[2]))
	for i in range(mini(lines.size(), room)):
		_fwords(str(lines[i]), ARIAL_BOLD, px, Color(str(spec[5])), "l", left + Vector2(0, LINE * i), float(spec[2]), 0.0, 0.0, false)


func wrap_lines(text: String, px: float, wide: float) -> Array:
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(px * _f))
	var limit: float = wide * _f
	var out: Array = []
	for part: String in text.split("\n"):
		var line: String = ""
		for word: String in part.split(" "):
			var next: String = word if line.is_empty() else line + " " + word
			if not line.is_empty() and font.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x > limit:
				out.append(line)
				line = word
			else:
				line = next
		out.append(line)
	return out



func _activate(id: String) -> void :
	if not visible:
		return
	if id.begins_with("head:"):
		var index: int = int(id.substr(5))
		if index >= 0 and index < _list.size():
			_sel = index
		return
	match id:
		"cancel":
			close()
		"ok":
			_confirm()
		"tab:pvp":
			if _tab != "pvp":
				_tab = "pvp"
				_show_mode(MODE_LIVE)
		"tab:teach":
			if _tab != "teach":
				_tab = "teach"
				_show_teach()
		"mode:hot", "mode:base", "mode:flag":
			if _tab == "pvp":
				_show_mode(int(MODES[id.substr(5)]))
		"mode:happy":
			if _tab == "teach":
				_show_teach()


func _confirm() -> void :
	var id: int = selected()
	if id <= 0:
		close()
		return
	if id not in PLAYABLE:
		say(SOON)
		return
	if client != null and client.select_tutor_map(id):
		close()
	else:
		say(OFFLINE)

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
