extends "flash_screen.gd"










const Atlas = preload("talent_atlas.gd")
const Code = preload("talent_code.gd")
const Ask = preload("exitask_atlas.gd")
const CTip = preload("ctool_tip.gd")
const ItemTip = preload("item_tip.gd")
const GarageModel = preload("garage_model.gd")
const TankPortrait = preload("tank_portrait.gd")

signal closed
signal tank_select_asked(tplt: int)

const SCOPE_NOTE: String = "Chỉ áp dụng trong PvP và trận sự kiện"
const INVALID_CODE: String = "Mã Kỹ Thuật không hợp lệ"
const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const SHOW_MAX: int = 5
const ADD_LEVEL: int = 15
const NAME_CHARS: int = 6
const TIP_WIDE: float = 252.0
const TIP_LINE: float = 16.0
const TIP_GAP: float = 10.0
const TIP_CHARS: int = 35
const ASK_LINE: float = 18.0
const ASK_GUTTER: float = 2.0
const SERIES_KEYS: Array = ["frmSeriesAtk", "frmSeriesDef", "frmSeriesComm"]
const INFO_BUTTONS: Array = [["save", "btnSaveTalent"], ["reset", "btnResetTalent"], ["delete", "btnDeleteTalent"], ["share", "btnShareTalent"]]
const FREE: int = 0
const LOCK_PART: int = 1
const LOCK_ALL: int = 2

var watch_name: String = ""
var _watch: bool = false
var _watch_tree: Array = []
var _cur: String = ""
var _tmp: Array = []
var _max: int = 0
var _start: int = 0
var _has_init: bool = false
var _copying: bool = false
var _compare: String = ""
var _page_name: String = ""
var _name_text: String = ""
var _renaming: bool = false
var _name: LineEdit = null
var _name_prev: String = ""
var _ask: Dictionary = {}
var _tip: CTip = CTip.new()
var _tip_quiet: String = ""
var _wired: Client = null



func _setup() -> void :
	_use(Atlas.FILE, Atlas.R)
	_use(Ask.FILE, Ask.R)
	_name = _fedit(NAME_CHARS)
	_name.visible = false
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_name.text_changed.connect( func(value: String) -> void :
		var kept: String = max_chars(_name_prev, value, NAME_CHARS)
		if kept != value:
			var caret: int = _name.caret_column - (value.length() - kept.length())
			_name.text = kept
			_name.caret_column = clampi(caret, 0, kept.length())
		_name_prev = kept)
	_name.text_submitted.connect( func(_value: String) -> void : _name.release_focus())
	_name.focus_exited.connect( func() -> void :
		if _renaming:
			_commit_name())


func open_for(who: Variant = null, tank_uuid: String = "") -> void :
	if who is Client:
		client = who
	if client == null:
		return
	_wire()
	_reset_state()
	_watch = false
	var page: Dictionary = _call_dict("talent_page_of_tank", [tank_uuid])
	_cur = str(page.get("uuid", ""))
	_compare = tank_uuid if client.tanks.has(tank_uuid) else str(client.current_tank().get("m_tankUuid", ""))
	_update_view()
	_select_first()
	visible = true
	queue_redraw()


func open_watch(code: Variant, name: Variant = "") -> bool:
	var tree: Array = Code.valid_watch_code(code)
	if tree.is_empty():
		if client != null:
			if is_visible_in_tree():
				say(INVALID_CODE)
			else:
				client.noticed.emit(INVALID_CODE)
		return false
	if client == null:
		return false
	_wire()
	_reset_state()
	_watch = true
	_watch_tree = tree
	watch_name = Code.clean_name(name)
	_cur = ""
	_compare = str(client.current_tank().get("m_tankUuid", ""))
	_update_view()
	_select_first()
	visible = true
	queue_redraw()
	return true

func close() -> void :
	if _renaming:
		_cancel_name()
	_ask = {}
	_copying = false
	_hide_edits()
	CTip.note(self, Rect2(), _f)
	if visible:
		visible = false
		closed.emit()

func chat_busy() -> bool:
	return true

func _shown() -> void :
	if not is_visible_in_tree():
		_ask = {}
		_hide_edits()
		CTip.note(self, Rect2(), _f)

func _reset_state() -> void :
	_has_init = false
	_copying = false
	_start = 0
	_ask = {}
	_renaming = false
	_tip_quiet = ""
	_watch_tree = []
	watch_name = ""
	_tmp = []
	_page_name = ""
	_name_text = ""
	_toast = ""

func _wire() -> void :
	if _wired == client:
		return
	_wired = client
	if client.has_signal("talent_changed"):
		client.connect("talent_changed", _on_talent)
	client.level_up.connect( func(_level: int) -> void :
		if visible:
			_update_view()
			queue_redraw())



func _pages() -> Array:
	var value: Variant = client.get("talent_pages") if client != null else null
	return value if value is Array else []

func _page(uuid: String) -> Dictionary:
	if uuid.is_empty():
		return {}
	for page: Variant in _pages():
		if page is Dictionary and str(page.get("uuid", "")) == uuid:
			return page
	return {}

func _call_dict(method: String, args: Array) -> Dictionary:
	if client == null or not client.has_method(method):
		return {}
	var value: Variant = client.callv(method, args)
	return value if value is Dictionary else {}

func _send(method: String, args: Array) -> bool:
	if client == null or not client.has_method(method):
		return false
	client.callv(method, args)
	return true

func _level() -> int:
	return int(client.character.get("level", 0)) if client != null else 0

func _total_point() -> int:
	var value: Variant = client.get("talent_total_point") if client != null else null
	return int(value) if value != null else 0

func _buy_count() -> int:
	var value: Variant = client.get("talent_buy_count") if client != null else null
	return int(value) if value != null else 0


static func page_name(page: Dictionary) -> String:
	var name: String = str(page.get("name", ""))
	return name if not name.is_empty() else str(Atlas.WORDS["CONTROL_TEXT605"])



func _update_view() -> void :
	_max = Code.active(_watch_tree) if _watch else _total_point()

func _select_first() -> void :
	var pages: Array = _pages()
	if _watch:
		_set_tree(_watch_tree)
		if pages.is_empty():
			_send("talent_request_all", [])
		return
	if pages.is_empty():
		_send("talent_request_all", [])
		return
	if _cur.is_empty() or _page(_cur).is_empty():
		_cur = str(pages[0].get("uuid", ""))
	_select(_cur)

func _select(uuid: String) -> void :
	var page: Dictionary = _page(uuid)
	if page.is_empty():
		return
	if _renaming:
		_cancel_name()
	_cur = uuid
	_page_name = page_name(page)
	_name_text = _page_name
	_set_tree(page.get("tree", []))


func _set_tree(tree: Variant) -> void :
	_tmp = Code.fit(Code.clone(tree if tree is Array else []), _max)

func _on_talent(kind: String, uuid: String) -> void :
	if not visible:
		return
	match kind:
		"save", "reset":
			if _copying:
				_copying = false
				_watch = false
				_cur = uuid
				_update_view()
				_select(uuid)
			elif not _watch and uuid == _cur:
				_select(uuid)
		"add":
			if _watch:
				_copying = false
				_watch = false
				_update_view()
				_select(uuid)
				if _cur != uuid:
					_set_tree(_watch_tree)
			else:
				_select(uuid)
		"del":
			if not _watch:
				_cur = ""
				_start = 0
				_select_first()
		"info":
			if not _has_init:
				_has_init = true
				_select_first()
		"point":
			if not _watch:
				_max = _total_point()
	queue_redraw()

func need_save() -> bool:
	if _watch:
		return false
	var page: Dictionary = _page(_cur)
	if page.is_empty():
		return false
	return not Code.is_equal(page.get("tree", []), _tmp) or _page_name != _name_text

func save_talent() -> bool:
	var page: Dictionary = _page(_cur)
	if page.is_empty():
		return false
	var text: String = _name_text
	if text.is_empty():
		say(str(Atlas.WORDS["TIP_600"]))
		return false
	text = text.replace("<", "").replace(">", "")
	if text.is_empty():
		say(str(Atlas.WORDS["TIP_614"]))
		return false
	return _send("talent_save_page", [{"uuid": _cur, "name": text, "tree": Code.clone(_tmp), "ct": int(page.get("ct", 0))}])




func _tree_lock(series: int) -> int:
	if _watch:
		return FREE
	var level: int = _level()
	if level < Code.math(66, "VAL%d" % (series * 2)):
		return LOCK_ALL
	if level < Code.math(65, "VAL%d" % (series * 2)):
		return LOCK_PART
	return FREE


func grid_state(id: int) -> String:
	var r: Array = Code.row(id)
	if r.is_empty():
		return "un_show"
	if not _watch:
		var level: int = _level()
		if level < int(r[5]):
			return "un_show"
		if level < int(r[6]):
			return "un_open"
	var lv: int = Code.level_of(_tmp, id)
	if not Code.is_available(_tmp, id, lv, _max):
		return "un_available"
	if lv == 0:
		return "un_active"
	return "nor_active" if Code.group_max(int(r[0]), int(r[1])) > 1 else "spe"

func grid_step(id: int, delta: int) -> bool:
	if _watch:
		return false
	var state: String = grid_state(id)
	if state in ["un_show", "un_open", "un_available"]:
		return false
	var lv: int = Code.level_of(_tmp, id)
	if (delta > 0 and lv >= Code.max_lv(id)) or (delta < 0 and lv <= 0):
		return false
	var out: Variant = Code.transform(_tmp, id, delta, _max)
	if out == null:
		return false
	_set_tree(out)
	return true



func _activate(id: String) -> void :
	if not _ask.is_empty():
		if id == "ask:ok" or id == "ask:no":
			var ask: Dictionary = _ask
			_ask = {}
			var action: Variant = ask.get("ok" if id == "ask:ok" else "no")
			if action is Callable and (action as Callable).is_valid():
				(action as Callable).call()
		return
	if id.begins_with("grid:"):
		_tip_quiet = id
		grid_step(int(id.substr(5)), 1)
		return
	if id.begins_with("radio:"):
		var uuid: String = id.substr(6)
		if need_save():
			save_talent()
		_select(uuid)
		return
	if id.begins_with("advice:"):
		var i: int = int(id.substr(7))
		_set_tree(Code.decode(str(Atlas.ADVICE_CODES[i])))
		return
	match id:
		"close":
			if need_save():
				_ask_box(str(Atlas.WORDS["TIP_610"]), func() -> void :
					save_talent()
					close(), close)
			else:
				close()
		"first":
			_start = 0
		"pre":
			_start = maxi(0, _start - 1)
		"next":
			if _start < _page_limit():
				_start += 1
		"last":
			_start = maxi(0, _page_limit())
		"radio_add":
			_add_page()
		"name_edit":
			_begin_name()
		"save":
			save_talent()
		"reset":
			_ask_box(str(Atlas.WORDS["TIP_607"]), func() -> void : _send("talent_op", [3, _cur]))
		"delete":
			_ask_box(str(Atlas.WORDS["TIP_603"]), func() -> void : _send("talent_op", [4, _cur]))
		"share":
			_share()
		"copy":
			_copy()
		"change_tank":
			_change_tank()


func _page_limit() -> int:
	var n: int = _pages().size()
	return n - SHOW_MAX if n >= Code.math(149, "MAX") else n - (SHOW_MAX - 1)

func _add_page() -> void :
	var pages: Array = _pages()
	if pages.size() < Code.math(149, "FREE") + _buy_count():
		_send("talent_add_page", [Code.next_page_name(pages), 0])

func _share() -> void :
	var code: String = Code.encode(_tmp)
	if code.is_empty():
		say(str(Atlas.WORDS["share_empty"]))
		return
	client.send_chat(str(Atlas.WORDS["CHAT_31"]), 2, {"talentCode": code, "talentName": _page_name})

func _copy() -> void :
	var code: String = Code.encode(_tmp)
	if code.is_empty():
		say(str(Atlas.WORDS["copy_empty"]))
		return
	if _send("talent_op", [7, code, str(Atlas.WORDS["copy_name"])]):
		_copying = true

func _change_tank() -> void :
	var inst: Dictionary = client.tanks.get(_compare, {})
	var tplt: int = int(inst.get("m_tpltId", 0))
	if not get_signal_connection_list("tank_select_asked").is_empty():
		tank_select_asked.emit(tplt)
		return
	var owned: Array = []
	for one: Variant in client.tanks.values():
		if one is Dictionary and int(one.get("m_tpltId", 0)) not in owned:
			owned.append(int(one.get("m_tpltId", 0)))
	owned.sort()
	if owned.is_empty():
		return
	set_compare_tank(int(owned[(owned.find(tplt) + 1) % owned.size()]))


func set_compare_tank(tplt: int) -> void :
	for uuid: Variant in client.tanks:
		if int(client.tanks[uuid].get("m_tpltId", 0)) == tplt:
			_compare = str(uuid)
			queue_redraw()
			return

func _ask_box(text: String, ok: Callable, no: Callable = Callable()) -> void :
	if _renaming:
		_commit_name()
	_ask = {"text": text, "ok": ok, "no": no}



func _begin_name() -> void :
	if _watch or _page(_cur).is_empty():
		return
	_renaming = true
	_name.text = _name_text
	_name_prev = _name_text
	_name.mouse_filter = Control.MOUSE_FILTER_STOP
	_fput(_name, _name_rect(), 16.0, "l", true)
	_name.grab_focus()
	_name.select_all()

func _commit_name() -> void :
	_renaming = false
	_name_text = _name.text if not _name.text.is_empty() else _page_name
	_end_name()

func _cancel_name() -> void :
	_renaming = false
	_end_name()

func _end_name() -> void :
	_name.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if _name.has_focus():
		_name.release_focus()
	_name.visible = false

func _name_rect() -> Rect2:
	var info: Vector2 = _info_at()
	var box: Array = Atlas.INFO["txtNameEdit"]
	return Rect2(info + Vector2(float(box[0]), float(Atlas.INFO["cvsNameEdit"][1])), Vector2(float(box[2]), 30.0))


static func max_chars(prev: String, value: String, limit: int) -> String:
	if value.length() <= limit:
		return value
	var head: int = 0
	while head < prev.length() and head < value.length() and prev[head] == value[head]:
		head += 1
	var tail: int = 0
	while tail < prev.length() - head and tail < value.length() - head and prev[prev.length() - 1 - tail] == value[value.length() - 1 - tail]:
		tail += 1
	var added: String = value.substr(head, value.length() - head - tail)
	return value.left(head) + added.left(maxi(0, limit - head - tail)) + value.right(tail)



func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _renaming:
		_name.release_focus()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed and _ask.is_empty():
			var id: String = _hit_at(event.position)
			if id.begins_with("grid:"):
				_tip_quiet = id
				grid_step(int(id.substr(5)), -1)
				queue_redraw()
		accept_event()
		return
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not event is InputEventKey or not event.pressed or event.echo:
		return
	var key: InputEventKey = event
	if key.keycode != KEY_ESCAPE or key.ctrl_pressed or key.alt_pressed or key.meta_pressed:
		return
	if not _ask.is_empty():
		_ask = {}
	elif _renaming:
		_cancel_name()
	else:
		close()
	get_viewport().set_input_as_handled()



func _xy(row: Array) -> Vector2:
	return Vector2(float(row[0]), float(row[1]))

func _info_at() -> Vector2:
	var o: Vector2 = _centre(float(Atlas.FRAME[0]), float(Atlas.FRAME[1]))
	return o + _xy(Atlas.WATCH["cvsTalentInfo"] if _watch else Atlas.NODES["cvsTalentInfo"])

func _paint() -> void :
	if not _tip_quiet.is_empty() and _hover != _tip_quiet:
		_tip_quiet = ""
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(Atlas.FRAME[0]), float(Atlas.FRAME[1]))
	_hit("panel", Rect2(o * _f, Vector2(float(Atlas.FRAME[0]), float(Atlas.FRAME[1])) * _f), false)
	_fblit("tl_talent_view_BG", o)
	_fblit("tl_talent_tree_view_BG", o + _xy(Atlas.WATCH["cimagechecklocal2"] if _watch else Atlas.NODES["cimagechecklocal2"]))
	_fbutton("close", "tl_close", o + _xy(Atlas.NODES["btnClose"]))
	_draw_info(_info_at())
	_draw_tree(o + _xy(Atlas.WATCH["cvsTalentTree"] if _watch else Atlas.NODES["cvsTalentTree"]))
	if not _watch:
		_draw_radio(o + _xy(Atlas.NODES["boxTalentRadio"]))
	for pair: Array in [["first", "tl_btn_first", "btnFirst"], ["pre", "tl_btn_pre", "btnPre"], ["next", "tl_btn_next", "btnNext"], ["last", "tl_btn_last", "btnLast"]]:
		_fbutton(str(pair[0]), str(pair[1]), o + _xy(Atlas.NODES[pair[2]]))
	if not _watch:
		_draw_advice(o)
		_fblit("tl_img_advice_title_t", o + _xy(Atlas.NODES["cimagechecklocal1"]))
	_fblit("tl_talent_title_t", o + _xy(Atlas.NODES["title"]))
	if not _watch:
		_fbutton("help", "tl_icon_talent_helper", o + _xy(Atlas.NODES["chighlightbutton1"]))
	var mouse: Vector2 = get_local_mouse_position() / _f
	if _ask.is_empty():
		_tip.draw(self, "help" if _hover == "help" else "", help_text(), mouse, Vector2(_fw, _fh), _f)
		if _hover.begins_with("grid:") and _hover != _tip_quiet:
			_draw_grid_tip(int(_hover.substr(5)), mouse)
		if _renaming:
			_fput(_name, _name_rect(), 16.0, "l", true)
	else:
		_tip.draw(self, "", "", mouse, Vector2(_fw, _fh), _f)
		_name.visible = false
		_draw_ask()


static func help_text() -> String:
	var lines: PackedStringArray = str(Atlas.WORDS["HELP"]).split("\n")
	if lines.size() >= 3:
		lines[2] = SCOPE_NOTE
	else:
		lines.append(SCOPE_NOTE)
	return "\n".join(lines)

func _skin_button(id: String, icon: String, at: Vector2, wide: float, high: float, enabled: bool, skin_on: String, skin_off: String, icon_off: String) -> void :
	var rect: Rect2
	if enabled:
		rect = _fblit(skin_on, at, 0.0, 0.0, _glow(id))
		_hit(id, rect, false)
	else:
		_fblit(skin_off, at)
	var name: String = icon if enabled or icon_off.is_empty() else icon_off
	var cell: Vector2 = _cell_size(name)
	_fblit(name, at + Vector2(roundf((wide - cell.x) / 2.0), roundf((high - cell.y) / 2.0)), 0.0, 0.0, _glow(id) if enabled else Color.WHITE)

func _draw_info(info: Vector2) -> void :
	var page: Dictionary = _page(_cur)
	if not _watch:
		_fblit("tl_img_edit_name_BG", info + _xy(Atlas.INFO["cvsNameEdit"]))
		var edit_at: Vector2 = info + _xy(Atlas.INFO["btnNameEdit"])
		if _renaming or page.is_empty():
			_fblit("tl_btn_name_edit", edit_at)
		else:
			_fbutton("name_edit", "tl_btn_name_edit", edit_at)
		if not _renaming:
			var rect: Rect2 = _name_rect()
			_fwords(_name_text, ARIAL_BOLD, 16.0, Color.WHITE, "l", rect.position, rect.size.x, 0.0, rect.size.y)
		var remain: Array = Atlas.INFO_TEXT["txtRemainPoint"]
		_fwords(str(Atlas.WORDS["CONTROL_TEXT600"]).replace("@num1@", str(_max - Code.active(_tmp))), ARIAL_BOLD, float(remain[4]), Color(str(remain[5])), 
			"c", info + Vector2(float(remain[0]) - 100.0, float(remain[1])), 200.0, 1.0, 0.0, false, Color("b4e0ee"))
		var states: Dictionary = {"save": need_save(), "reset": Code.active(_tmp) != 0 and not page.is_empty(), "delete": _pages().size() > 1 and not page.is_empty(), 
			"share": true}
		for pair: Array in INFO_BUTTONS:
			var id: String = str(pair[0])
			var box: Array = Atlas.INFO[pair[1]]
			_skin_button(id, "tl_btn_%s_enable_t" % id, info + _xy(box), float(box[2]), float(box[3]), bool(states[id]), "tl_btn_enable_skin", "tl_btn_unable_skin", 
				"tl_btn_%s_unable_t" % id)
	else:
		var box: Array = Atlas.INFO["btnCopyTalent"]
		_skin_button("copy", "tl_btn_copy_enable_t", info + _xy(box), float(box[2]), float(box[3]), true, "tl_btn_enable_skin", "tl_btn_unable_skin", "tl_btn_copy_unable_t")
	for line: Array in Atlas.LINES:
		_fblit("tl_img_split_line", info + _xy(line))
	_fblit("tl_img_radar_BG", info + _xy(Atlas.INFO["cimagechecklocal2"]))
	for attr: Array in Atlas.ATTRS:
		_fblit("tl_img_attr%d_t" % int(attr[0]), info + Vector2(float(attr[1]), float(attr[2])))
	_draw_radar(info + _xy(Atlas.INFO["cvsRadar"]))
	_fblit("tl_img_avatar_BG", info + _xy(Atlas.INFO["cimagechecklocal1"]))
	var av: Array = Atlas.INFO["avTank"]
	_draw_tank(info + Vector2(float(av[0]) + float(av[2]) * 0.15, float(av[1]) + float(av[3]) * 0.15))
	_fbutton("change_tank", "tl_btn_select_tank_t", info + _xy(Atlas.INFO["btnChangeTank"]))

func _compare_tank() -> Dictionary:
	var inst: Variant = client.tanks.get(_compare, {})
	return inst if inst is Dictionary else {}

func _draw_tank(centre: Vector2) -> void :
	var tank: Dictionary = _compare_tank()
	if tank.is_empty() or pack.state != "ready" or pack.garage.is_empty():
		return
	var level: int = maxi(1, int(tank.get("m_level", 1)))
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(tank.get("m_tpltId", 0)), level, tank)
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(tank.get("m_haloId", 0)), level)
	TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, centre * _f, 0.3 * _f, _time)


func compare_attrs() -> Array:
	var tank: Dictionary = _compare_tank()
	if tank.is_empty() or pack == null:
		return []
	var row: Variant = pack.garage.get("tanks", {}).get(str(int(tank.get("m_tpltId", 0))), {})
	var attrs: Variant = row.get("attrs", []) if row is Dictionary else []
	return attrs if attrs is Array else []


static func radar_points(centre: Vector2, ratios: Array) -> PackedVector2Array:
	var out: PackedVector2Array = PackedVector2Array()
	for i in range(ratios.size()):
		out.append(centre + Vector2(62.0 * float(ratios[i]), 0.0).rotated(deg_to_rad(i * 60.0 + 270.0)))
	return out

static func _area(poly: PackedVector2Array) -> float:
	var sum: float = 0.0
	for i in range(poly.size()):
		sum += poly[i].cross(poly[(i + 1) % poly.size()])
	return absf(sum) / 2.0

func _fill(poly: PackedVector2Array, color: Color) -> void :
	if poly.size() >= 3 and _area(poly) > 0.01 and not Geometry2D.triangulate_polygon(poly).is_empty():
		draw_colored_polygon(poly, color)

func _draw_radar(centre: Vector2) -> void :
	var attrs: Array = compare_attrs()
	var tank: Array = Code.radar([], attrs)
	var mine: Array = Code.radar(_tmp, attrs)
	if tank.size() < 6 or mine.size() < 6:
		return
	var c: Vector2 = centre * _f
	var tp: PackedVector2Array = radar_points(centre, tank)
	var mp: PackedVector2Array = radar_points(centre, mine)
	for i in range(6):
		tp[i] *= _f
		mp[i] *= _f
	var red: Color = Color(1, 0, 0, 0.4)
	var green: Color = Color(0, 1, 0, 0.4)

	for i in range(6):
		var j: int = (i + 1) % 6
		var a: PackedVector2Array = PackedVector2Array([c, mp[i], mp[j]])
		var b: PackedVector2Array = PackedVector2Array([c, tp[i], tp[j]])
		if _area(a) <= 0.01:
			_fill(b, red)
			continue
		if _area(b) <= 0.01:
			_fill(a, red)
			continue
		for part: PackedVector2Array in Geometry2D.clip_polygons(a, b):
			_fill(part, red)
		for part: PackedVector2Array in Geometry2D.clip_polygons(b, a):
			_fill(part, red)
	var width: float = maxf(1.0, _f)
	var ring: PackedVector2Array = mp.duplicate()
	ring.append(mp[0])
	draw_polyline(ring, Color(1, 0, 0), width, true)
	ring = tp.duplicate()
	ring.append(tp[0])
	draw_polyline(ring, Color(1, 0, 0), width, true)

	for i in range(6):
		_fill(PackedVector2Array([c, tp[i], tp[(i + 1) % 6]]), green)
	draw_polyline(ring, Color(0, 1, 0), width, true)

func _draw_tree(tree_at: Vector2) -> void :
	for k in range(3):
		var series: int = k + 1
		var s: Vector2 = Vector2(tree_at.x - float(Atlas.SERIES["frmSeriesAtk"][0]) + float(Atlas.SERIES[SERIES_KEYS[k]][0]), tree_at.y)
		var lock: int = _tree_lock(series)
		_fblit("tl_talent_tree_BG", s + _xy(Atlas.TREE["tree_BG"]))
		if lock == LOCK_ALL:
			_fblit("tl_tree_lock_all", s + _xy(Atlas.TREE["lock_all"]))
			var all: Array = Atlas.TREE_TEXT["lblUnlockAllLevel"]
			_fwords(str(Atlas.WORDS["CONTROL_TEXT606"]).replace("@num1@", str(Code.math(66, "VAL%d" % (series * 2)))), ARIAL_BOLD, float(all[4]), Color(str(all[5])), 
				"c", s + Vector2(float(all[0]) - 120.0, float(all[1])), 240.0, 1.5, 0.0, false, Color("005391"))
		elif lock == LOCK_PART:
			_fblit("tl_tree_lock_part", s + _xy(Atlas.TREE["lock_part"]))
		_fblit("tl_talent_tree_title_BG", s + _xy(Atlas.TREE["title_BG"]))
		if lock != LOCK_ALL:
			for key: String in Atlas.SLOTS:
				var parts: PackedStringArray = key.split("_")
				if lock == LOCK_PART and parts[1] != "1":
					continue
				var id: int = Code.loc_template(series, int(parts[0]), int(parts[1]))
				if id != 0:
					_draw_grid(id, s + _xy(Atlas.SLOTS[key]))
		if lock == LOCK_PART:
			var part: Array = Atlas.TREE_TEXT["lblUnlockPartLevel"]
			_fwords(str(Atlas.WORDS["CONTROL_TEXT606"]).replace("@num1@", str(Code.math(65, "VAL%d" % (series * 2)))), ARIAL_BOLD, float(part[4]), Color(str(part[5])), 
				"c", s + Vector2(float(part[0]) - 90.0, float(part[1])), 180.0, 0.0, 0.0, false)

func _draw_grid(id: int, at: Vector2) -> void :
	var r: Array = Code.row(id)
	var state: String = grid_state(id)
	_fblit("tl_talent_grid_BG", at + _xy(Atlas.GRID["grid_BG"]))
	if state == "un_show":
		return
	if state == "un_open":
		_fblit("tl_talent_un_open", at + _xy(Atlas.GRID["un_open"]))
		var open: Array = Atlas.GRID_TEXT["lblOpenLv"]
		_fwords(str(int(r[6])), ARIAL_BOLD, float(open[4]), Color(str(open[5])), "c", at + Vector2(0.0, float(open[1]) - 10.0), 48.0, 0.0, 20.0, false)
		return
	var grey: bool = state == "un_available"
	var icon: String = ("tlg_ic_" if grey else "tl_ic_") + str(r[7])
	var cell: Vector2 = _cell_size(icon)
	var centre: Vector2 = _xy(Atlas.GRID["icon"])
	var lit: Color = _glow("grid:%d" % id)
	var tint: Color = Color(lit.r, lit.g, lit.b, 0.2 if state == "un_active" else 1.0)
	_fblit(icon, at + Vector2(roundf(centre.x - cell.x / 2.0), roundf(centre.y - cell.y / 2.0)), 0.0, 0.0, tint)
	if state == "spe":
		_fblit("tl_spe_%d" % maxi(1, int(r[1]) / 2), at + _xy(Atlas.GRID["level_frame"]))
	else:
		_fblit("tlg_nor_active_level" if grey else "tl_nor_active_level", at + _xy(Atlas.GRID["level_frame"]))
		_fblit("tlg_talent_level_BG" if grey else "tl_talent_level_BG", at + _xy(Atlas.GRID["level_BG"]))
		var label: Array = Atlas.GRID_TEXT["lblLevel"]
		var color: Color = Color("eaeaea") if grey else (Color("00ff00") if state == "un_active" else Color(str(label[5])))
		_fwords("%d/%d" % [Code.level_of(_tmp, id), int(r[3])], ARIAL_BOLD, float(label[4]), color, "r", at + Vector2(float(label[0]) - 46.0, float(label[1])), 46.0, 
			0.0, float(label[3]), false)
	_hit("grid:%d" % id, Rect2(at * _f, Vector2(48, 48) * _f), false)


func tip_lines(id: int) -> Array:
	var r: Array = Code.row(id)
	if r.is_empty():
		return []
	var lv: int = Code.level_of(_tmp, id)
	var top: int = int(r[3])
	var out: Array = []
	var y: float = 10.0
	out.append([str(r[8]), true, 14.0, Color.WHITE, y])
	y += TIP_LINE
	out.append([str(Atlas.WORDS["CONTROL_TEXT602"]).replace("@num1@", str(lv)).replace("@num2@", str(top)), true, 14.0, Color("00ff00"), y])
	y += TIP_LINE
	if not _watch and lv < top:
		var s: int = int(r[0])
		var g: int = int(r[1])
		if Code.group_total(_tmp, s, g) >= Code.group_max(s, g):
			var names: Array = []
			for cell: Array in _tmp:
				var other: int = int(cell[0])
				if int(cell[1]) != 0 and other != id and Code.series_of(other) == s and Code.group_of(other) == g:
					names.append(str(Code.row(other)[8]))
			if not names.is_empty():
				var text: String = str(Atlas.WORDS["CONTROL_TEXT604"]).replace("@name@", "、".join(PackedStringArray(names)))
				for chunk: String in _chunks(text):
					out.append([chunk, true, 12.0, Color("ff0000"), y])
					y += TIP_LINE
	for chunk: String in _chunks(Code.desc(id, lv)):
		out.append([chunk, false, 12.0, Color.WHITE, y])
		y += TIP_LINE
	if lv > 0 and lv < top:
		y += TIP_GAP
		out.append([str(Atlas.WORDS["CONTROL_TEXT603"]), false, 12.0, Color.WHITE, y])
		y += TIP_LINE
		for chunk: String in _chunks(Code.desc(id, lv + 1)):
			out.append([chunk, false, 12.0, Color.WHITE, y])
			y += TIP_LINE
	out.append(["", false, 12.0, Color.WHITE, y])
	return out


static func _chunks(text: String) -> Array:
	var out: Array = []
	var at: int = 0
	while at < text.length():
		out.append(text.substr(at, TIP_CHARS))
		at += TIP_CHARS
	return out

func _draw_grid_tip(id: int, mouse: Vector2) -> void :
	var lines: Array = tip_lines(id)
	if lines.is_empty():
		return
	var high: float = float(lines[-1][4]) + TIP_LINE
	var tip_size: Vector2 = Vector2(TIP_WIDE, high)
	var at: Vector2 = ItemTip.place(mouse, tip_size, Vector2(_fw, _fh))
	_round(Rect2(at * _f, tip_size * _f), Color(0, 0, 0, 0.8), 6.0 * 2.0)
	for line: Array in lines:
		if str(line[0]).is_empty():
			continue
		_fwords(str(line[0]), ARIAL_BOLD if bool(line[1]) else ARIAL, float(line[2]), line[3], "l", at + Vector2(5.0, float(line[4])), TIP_WIDE - 5.0, 0.0, 0.0, false)
	CTip.note(self, Rect2(at, tip_size), _f)

func _draw_radio(box: Vector2) -> void :
	var pages: Array = _pages()
	var n: int = pages.size()
	var count: int = n + 1 if _level() >= ADD_LEVEL and n < Code.math(149, "MAX") else n
	count = mini(count, SHOW_MAX)
	var cell_w: float = float(Atlas.RADIO[0])
	var gap: float = float(Atlas.RADIO[2])
	var label: Array = Atlas.RADIO_TEXT
	for i in range(count):
		var at: Vector2 = box + Vector2(i * (cell_w + gap), 1.0)
		var index: int = _start + i
		if index < n:
			var page: Dictionary = pages[index]
			var uuid: String = str(page.get("uuid", ""))
			var id: String = "radio:" + uuid
			var rect: Rect2 = _fblit("tl_btn_radio_selected" if uuid == _cur else "tl_btn_radio_normal", at, 0.0, 0.0, _glow(id))
			_hit(id, rect, false)
			_fwords(page_name(page), ARIAL_BOLD, float(label[4]), Color(str(label[5])), "c", at + Vector2(float(label[0]), float(label[1])), float(label[2]), 
				1.0, 0.0, true, Color("086da5"))
		elif index == n:
			var rect: Rect2 = _fblit("tl_btn_radio_normal", at, 0.0, 0.0, _glow("radio_add"))
			_hit("radio_add", rect, false)
			var plus: Vector2 = _cell_size("tl_btn_add_talent")
			_fblit("tl_btn_add_talent", at + Vector2(roundf((cell_w - plus.x) / 2.0), roundf((float(Atlas.RADIO[1]) - plus.y) / 2.0)), 0.0, 0.0, _glow("radio_add"))

func _draw_advice(o: Vector2) -> void :
	var level: int = _level()
	for i in range(6):
		if level < Code.math(69, "VAL%d" % (i + 1)):
			continue
		var box: Array = Atlas.NODES["btnAdvice%d" % (i + 1)]
		var icon: int = int(Atlas.ADVICE_ICONS[i])
		var off: String = "tl_advice_%d_unable_t" % icon
		_skin_button("advice:%d" % i, "tl_advice_%d_enable_t" % icon, o + _xy(box), float(box[2]), float(box[3]), level >= Code.math(67, "VAL%d" % (i + 1)), 
			"tl_btn_advice_enable", "tl_btn_advice_unable", off if Atlas.R.has(off) else "")

func _draw_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(float(Ask.SIZE[0]), float(Ask.SIZE[1]))
	var frame: Vector2 = at + _xy(Ask.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("xa_frame") * _f), false)
	_fblit("xa_frame", frame)
	var body: Array = Ask.TEXTS["txtContent"]
	_fpara(str(_ask.get("text", "")), ARIAL_BOLD, float(body[4]), Color(str(body[5])), at + _xy(body) + Vector2(ASK_GUTTER, 0.0), float(body[2]) - ASK_GUTTER * 2.0)
	_fbutton("ask:ok", "xa_ok", at + _xy(Ask.NODES["btnConfirm"]))
	_fbutton("ask:no", "xa_no", at + _xy(Ask.NODES["btnCancel"]))
	_fblit("xa_guy", at + _xy(Ask.GUY))
