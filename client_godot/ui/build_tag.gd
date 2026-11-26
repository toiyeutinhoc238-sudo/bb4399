extends Control




const BUILD: String = preload("res://ui/settings.gd").BUILD
const CTip = preload("res://ui/ctool_tip.gd")
const BOLD: Font = preload("res://assets/fonts/BeVietnamPro-Bold.ttf")
const LobbyBar = preload("res://ui/lobby_bar.gd")
const AVOID_STATES: Array = ["lobby", "hall", "room"]
const AVOID_GAP: float = 3.0
const GATE_STATES: Array = ["login", "auth", "servers", "connecting", "characters"]
const CHECK_STATES: Array = ["login", "servers", "lobby"]
const RECHECK: float = 180.0
const FETCH_JS: String = "window.__bbVer='';fetch(new URL('version.txt',document.baseURI).href+'?'+Date.now(),{cache:'no-store'})"\
+ ".then(function(r){return r.ok?r.text():'';}).then(function(t){window.__bbVer=(t||'').trim()||'-';})"\
+ ".catch(function(){window.__bbVer='-';});"
const RELOAD_JS: String = "(function(){var k='bbVerReload',n=Date.now(),l=0;try{l=+sessionStorage.getItem(k)||0;}catch(e){}"\
+ "if(n-l<60000)return false;try{sessionStorage.setItem(k,String(n));}catch(e){}try{window.__bbExit&&window.__bbExit.leave();}catch(e){}location.reload();return true;})()"




const GL_LOST_JS: String = "(function(){if(window.__bbGlLost)return;window.__bbGlLost=1;window.addEventListener('webglcontextlost',function(e){"\
+ "var k='bbGlReload',n=Date.now(),l=0;try{l=+sessionStorage.getItem(k)||0;}catch(x){}if(n-l<30000)return;"\
+ "try{sessionStorage.setItem(k,String(n));}catch(x){}e.stopImmediatePropagation();try{window.__bbExit&&window.__bbExit.leave();}catch(y){}location.reload();},true);})()"

var state: String = ""
var newer: String = ""
var _web: bool = OS.has_feature("web") and BUILD != "dev"
var _waiting: float = 0.0
var _poll: float = 0.0
var _since: float = 0.0
var _banner: Rect2 = Rect2()
var _hidden: bool = false
var _lift: float = 0.0
var _app: Node = null
var _app_ready: bool = false





const AUTO_FILE: String = "user://pck/auto_restart.txt"
const AUTO_IDLE: int = 5000
var pc_app: bool = false
var restart_fn: Callable = Callable()
var quit_fn: Callable = Callable()
var auto_file: String = AUTO_FILE
var _last_input: int = 0
var _auto_tag: String = ""
var _restarting: bool = false








const GATE_LAYER: int = 120
const RESTART_WAIT: float = 8.0
const GATE_STALL: float = 15.0
var android_app: bool = false
static var hold: bool = false
var gate_view: String = ""
var _gate_result: bool = false
var _gate_error: String = ""
var _gate_skip: bool = false
var _restart_wait: float = 0.0
var _gate_still: float = 0.0
var _gate_bytes: float = -2.0
var _gate_layer: CanvasLayer = null
var _gate_title: Label = null
var _gate_note: Label = null
var _gate_bar: ProgressBar = null
var _gate_go: Button = null
var _gate_skip_btn: Button = null

func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if _web:
		JavaScriptBridge.eval(GL_LOST_JS, true)
	if (OS.has_feature("android") or OS.has_feature("pc_app")) and BUILD != "dev":
		_app = load("res://ui/android_update.gd").new()
		_app.set("build", BUILD)
		_app.connect("ready_tag", _on_app_ready)
		_app.connect("finished", _on_app_finished)
		add_child(_app)
		pc_app = not OS.has_feature("android")
		android_app = not pc_app
		if android_app:
			_app.call("check")
			_sync_gate()
	_check()

func _exit_tree() -> void :
	if android_app:
		hold = false

func _on_app_ready(tag: String) -> void :
	newer = tag
	_app_ready = true
	_gate_result = true
	_gate_error = ""
	queue_redraw()
	_auto_restart()
	_sync_gate()



func _on_app_finished(kind: String, was: String) -> void :
	if kind == "error":
		if not _gate_result or was != "version":
			var why: Variant = _app.get("last_error") if _app != null else null
			_gate_error = str(why) if why != null and not str(why).is_empty() else "lỗi"
	else:
		_gate_result = true
		_gate_error = ""
	_sync_gate()

func set_state(next: String) -> void :
	if next == state:
		return
	state = next
	if state in CHECK_STATES:
		_check()
	if _app != null:
		_app.call("on_state", state)
	queue_redraw()
	_auto_restart()
	_sync_gate()

func _check() -> void :
	_since = 0.0
	if not _web or _waiting > 0.0:
		return
	JavaScriptBridge.eval(FETCH_JS, true)
	_waiting = 8.0


func tag_rect() -> Rect2:
	return _rect_at(_lift)

func _rect_at(lift: float) -> Rect2:
	var px: int = 12
	var width: float = BOLD.get_string_size("Bản " + BUILD, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
	return Rect2(size.x - width - 12.0, size.y - 8.0 - lift - BOLD.get_ascent(px) - 2.0, width + 4.0, BOLD.get_height(px) + 4.0)


func _place() -> float:
	if state not in AVOID_STATES:
		return 0.0
	var bars: Array = LobbyBar.live(self)
	if bars.is_empty():
		return 0.0
	var lift: float = 0.0
	var rect: Rect2 = _rect_at(0.0)
	for _round: int in range(4):
		var moved: bool = false
		for bar: Dictionary in bars:
			for hit: Array in bar["hits"]:
				var r: Rect2 = (hit[1] as Rect2).grow(AVOID_GAP)
				if r.intersects(rect):
					var up: float = rect.end.y - r.position.y
					lift += up
					rect.position.y -= up
					moved = true
		if not moved:
			break
	return roundf(lift)

func _process(delta: float) -> void :
	var lift: float = _place()
	if lift != _lift:
		_lift = lift
		queue_redraw()
	var hide: bool = state != "battle" and not CTip.showing.is_empty() and CTip.covers(get_global_transform_with_canvas() * tag_rect())
	if hide != _hidden:
		_hidden = hide
		queue_redraw()
	if _app != null:
		if _app_ready and (pc_app or android_app) and _auto_tag != newer:
			_auto_restart()
		if android_app:
			if _restarting:
				_restart_wait += delta
				if _restart_wait >= RESTART_WAIT:
					_restarting = false
			var got: float = float(_app.call("progress")) if _app.has_method("progress") else -1.0
			if got != _gate_bytes:
				_gate_bytes = got
				_gate_still = 0.0
			else:
				_gate_still += delta
			_sync_gate()
		_since += delta
		if state != "battle" and _since >= RECHECK:
			_since = 0.0
			_app.call("check")
		return
	if not _web:
		return
	_since += delta
	if _waiting <= 0.0:
		if state != "battle" and _since >= RECHECK:
			_check()
		return
	_waiting -= delta
	_poll -= delta
	if _poll > 0.0:
		return
	_poll = 0.25
	var got: String = str(JavaScriptBridge.eval("window.__bbVer||''", true))
	if got.is_empty():
		return
	_waiting = 0.0
	if got == "-" or got == BUILD or not RegEx.create_from_string("^[A-Za-z0-9._-]{1,32}$").search(got):
		return
	newer = got
	if state in GATE_STATES or state.is_empty():
		JavaScriptBridge.eval(RELOAD_JS, true)
	queue_redraw()

func _input(event: InputEvent) -> void :
	if event is InputEventKey or event is InputEventMouseButton or event is InputEventScreenTouch:
		_last_input = Time.get_ticks_msec()
	if not gate_view.is_empty():
		if event is InputEventKey:
			get_viewport().set_input_as_handled()
		return
	if newer.is_empty() or state == "battle" or _banner.size == Vector2.ZERO:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and _banner.has_point(make_input_local(event).position):
		get_viewport().set_input_as_handled()
		if _app_ready:
			if pc_app or android_app:
				restart_app()
			elif quit_fn.is_valid():
				quit_fn.call()
			else:
				get_tree().quit()
			return
		JavaScriptBridge.eval("try{window.__bbExit&&window.__bbExit.leave();}catch(e){}location.reload()", true)

func _draw() -> void :
	_banner = Rect2()
	if state == "battle":
		return


	if newer.is_empty() or not gate_view.is_empty():
		return
	var text: String = banner_text() % newer
	var tpx: int = 15
	var tw: float = BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, tpx).x
	_banner = Rect2((size.x - tw) / 2.0 - 18.0, 6.0, tw + 36.0, 32.0)
	draw_rect(_banner, Color(0.96, 0.55, 0.12, 0.95))
	draw_rect(_banner, Color(0.35, 0.16, 0.0, 1.0), false, 2.0)
	var base: Vector2 = Vector2(_banner.position.x + 18.0, _banner.position.y + 22.0)
	draw_string_outline(BOLD, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, tpx, 4, Color(0.3, 0.12, 0.0, 1.0))
	draw_string(BOLD, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, tpx, Color.WHITE)


func banner_text() -> String:
	if not _app_ready:
		return "Có bản mới %s — bấm vào đây để tải lại"
	if android_app:
		return "Có bản mới %s, khởi động lại để cập nhật — bấm vào đây"
	return "Có bản mới %s — bấm để về màn cập nhật" if pc_app else "Đã tải bản mới %s — bấm để đóng, mở lại app để dùng"



func restart_app() -> void :
	if _restarting:
		return
	_restarting = true
	_restart_wait = 0.0

	var args: PackedStringArray = PackedStringArray() if android_app else restart_args()
	if restart_fn.is_valid():
		restart_fn.call(args)
		return
	OS.set_restart_on_exit(true, args)
	get_tree().quit()



static func restart_args() -> PackedStringArray:
	var args: PackedStringArray = OS.get_cmdline_args()
	var user: PackedStringArray = OS.get_cmdline_user_args()
	if not user.is_empty() and not args.has("--") and not args.has("++"):
		args.append("--")
		args.append_array(user)
	return args




func _auto_restart() -> bool:
	if not (_app_ready and (pc_app or android_app)) or _restarting or newer.is_empty() or _auto_tag == newer:
		return false
	if not (state in GATE_STATES or state.is_empty()):
		return false

	var waits: bool = not android_app or _gate_skip
	if waits and _last_input > 0 and Time.get_ticks_msec() - _last_input < AUTO_IDLE:
		return false
	_auto_tag = newer
	var done: String = FileAccess.get_file_as_string(auto_file).strip_edges() if FileAccess.file_exists(auto_file) else ""
	if done == newer:
		return false
	DirAccess.make_dir_recursive_absolute(auto_file.get_base_dir())
	var f: FileAccess = FileAccess.open(auto_file, FileAccess.WRITE)
	if f == null:
		return false
	f.store_string(newer)
	f.close()
	restart_app()
	return true


func gate_state() -> String:
	if not android_app or _app == null or _gate_skip or not (state in GATE_STATES or state.is_empty()):
		return ""
	if _restarting:
		return "restart"
	if _app_ready:
		return "ready"
	if str(_app.get("stage")) == "pck":
		return "load"
	if not _gate_error.is_empty():
		return "error"
	if not _gate_result:
		return "check"
	return ""


func gate_text(view: String) -> PackedStringArray:
	var want: String = str(_app.call("target")) if _app != null and _app.has_method("target") else ""
	if want.is_empty():
		want = newer
	var tag: String = (" " + want) if not want.is_empty() else ""
	match view:
		"check":
			return PackedStringArray(["Đang kiểm tra bản cập nhật…", "Bản đang chạy: " + BUILD])
		"load":
			var got: float = float(_app.call("progress")) if _app != null and _app.has_method("progress") else -1.0
			var pct: String = (" %d %%" % int(floorf(got * 100.0))) if got >= 0.0 else ""
			return PackedStringArray(["Đang tải bản cập nhật…" + pct, "Bản" + tag + " — tải xong app tự khởi động lại"])
		"error":
			if _gate_error in ["verify", "sum", "version text"]:
				return PackedStringArray(["Không tải được bản cập nhật", "Tệp cập nhật không khớp — bấm Thử lại để tải lại (" + _gate_error + ")"])
			return PackedStringArray(["Không tải được bản cập nhật", "Kiểm tra mạng rồi bấm Thử lại (" + _gate_error + ")"])
		"ready":
			return PackedStringArray(["Đã tải xong bản mới" + tag, "Bấm Khởi động lại để dùng bản mới"])
		"restart":
			return PackedStringArray(["Đang khởi động lại để cập nhật…", "Bản" + tag])
	return PackedStringArray(["", ""])

func _sync_gate() -> void :
	var view: String = gate_state()
	if android_app:
		hold = not view.is_empty()
	if view.is_empty() and _gate_layer == null:
		gate_view = ""
		return
	if view != gate_view:
		if gate_view.is_empty() and not view.is_empty() and is_inside_tree():
			get_viewport().gui_release_focus()
		gate_view = view
		_gate_still = 0.0
		queue_redraw()
	if view.is_empty():
		_gate_layer.visible = false
		return
	if _gate_layer == null:
		_build_gate()
	_gate_layer.visible = true
	var text: PackedStringArray = gate_text(view)
	_gate_title.text = text[0]
	_gate_note.text = text[1]
	var got: float = float(_app.call("progress")) if view == "load" and _app != null and _app.has_method("progress") else -1.0
	_gate_bar.visible = view == "load"
	_gate_bar.value = maxf(got, 0.0) * 100.0
	_gate_go.visible = view in ["error", "ready"]
	_gate_go.text = "Thử lại" if view == "error" else "Khởi động lại"
	_gate_skip_btn.visible = view in ["error", "ready"] or (view in ["check", "load"] and _gate_still >= GATE_STALL)

func _gate_box(fill: Color, edge: Color, radius: int) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = edge
	box.set_border_width_all(2)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 18
	box.content_margin_right = 18
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box

func _gate_button(text: String, fill: Color, edge: Color) -> Button:
	var b: Button = Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(170, 46)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_font_override("font", BOLD)
	b.add_theme_font_size_override("font_size", 17)
	b.add_theme_color_override("font_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color(1, 0.95, 0.75))
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_stylebox_override("normal", _gate_box(fill, edge, 8))
	b.add_theme_stylebox_override("hover", _gate_box(fill.lightened(0.12), edge, 8))
	b.add_theme_stylebox_override("pressed", _gate_box(fill.darkened(0.2), edge, 8))
	return b

func _build_gate() -> void :
	_gate_layer = CanvasLayer.new()
	_gate_layer.layer = GATE_LAYER
	add_child(_gate_layer)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.04, 0.08, 0.86)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gate_layer.add_child(dim)
	var center: CenterContainer = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	dim.add_child(center)
	var panel: PanelContainer = PanelContainer.new()
	var frame: StyleBoxFlat = _gate_box(Color(0.07, 0.13, 0.22, 0.97), Color(0.96, 0.62, 0.16), 12)
	frame.content_margin_left = 30
	frame.content_margin_right = 30
	frame.content_margin_top = 22
	frame.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", frame)
	center.add_child(panel)
	var col: VBoxContainer = VBoxContainer.new()
	col.custom_minimum_size = Vector2(420, 0)
	col.add_theme_constant_override("separation", 14)
	panel.add_child(col)
	_gate_title = Label.new()
	_gate_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gate_title.add_theme_font_override("font", BOLD)
	_gate_title.add_theme_font_size_override("font_size", 22)
	_gate_title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.35))
	_gate_title.add_theme_color_override("font_outline_color", Color(0.25, 0.1, 0.0))
	_gate_title.add_theme_constant_override("outline_size", 4)
	col.add_child(_gate_title)
	_gate_bar = ProgressBar.new()
	_gate_bar.show_percentage = false
	_gate_bar.custom_minimum_size = Vector2(420, 18)
	_gate_bar.add_theme_stylebox_override("background", _gate_box(Color(0.02, 0.05, 0.1), Color(0.3, 0.42, 0.6), 9))
	var fill: StyleBoxFlat = _gate_box(Color(0.96, 0.58, 0.14), Color(1.0, 0.8, 0.4), 9)
	fill.set_content_margin_all(0)
	_gate_bar.add_theme_stylebox_override("fill", fill)
	col.add_child(_gate_bar)
	_gate_note = Label.new()
	_gate_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_gate_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_gate_note.add_theme_font_override("font", BOLD)
	_gate_note.add_theme_font_size_override("font_size", 15)
	_gate_note.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	col.add_child(_gate_note)
	var row: HBoxContainer = HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 18)
	col.add_child(row)
	_gate_go = _gate_button("Thử lại", Color(0.13, 0.48, 0.86), Color(0.55, 0.8, 1.0))
	_gate_go.pressed.connect(_on_gate_go)
	row.add_child(_gate_go)
	_gate_skip_btn = _gate_button("Vào bản hiện tại", Color(0.28, 0.32, 0.4), Color(0.6, 0.66, 0.76))
	_gate_skip_btn.pressed.connect(_on_gate_skip)
	row.add_child(_gate_skip_btn)


func _on_gate_go() -> void :
	if gate_view == "ready":
		restart_app()
	elif gate_view == "error" and _app != null:
		_gate_error = ""
		_app.call("check")
	_sync_gate()


func _on_gate_skip() -> void :
	_gate_skip = true
	_sync_gate()
