extends "flash_screen.gd"











const HallAtlas = preload("hall_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const MB_FAST_TICKS: int = 25
const BEAT_FAST: float = 0.2
const BEAT_SLOW: float = 1.0
const ACT_STEP: float = 66.0
const MONTHLY_X: float = 330.0
const ROW2_DY: float = 66.0
const ROW_MAX: int = 10


const ORDER: Array = ["mb", "db", "on", "bk", "pn", "ta", "fw", "zp", "fm", "nv", "tp", "kd", "pt", "fp", "dr"]
const ROW1: Array = ["dr", "bk", "on", "pt", "fp"]




const GROWTH_X: float = -66.0
const MODULE_DIR: String = "res://ui/"
const FW_ICON: String = "l/ev/fw/btn_thantai.webp"
const FW_WORD: String = "l/ev/fw/word_thantai.webp"
const FW_TIP: String = "Vòng Quay Thần Tài"



const NO_TIP: Array = ["mb", "db", "on", "bk", "pn", "ta", "fw", "zp", "fm", "nv", "tp", "kd", "pt", "fp", "pen", "dr"]
const LOGGED_OUT: Array = ["login", "auth", "servers", "characters"]

var lobby: Control
var wheel: TevWheel
var events: Dictionary = {}
var spots: Dictionary = {}
var _booted: bool = false
var _beat_acc: float = 0.0
var _fast: int = 0
var _was: String = ""
var _ev_wait: Array = []

func _setup() -> void :
	var later: bool = art_defer and client != null and str(client.state) in PRE_AUTH
	if later:
		visible = false
	_use(HallAtlas.FILE, {"public_tip": HallAtlas.R["public_tip"]})
	wheel = TevWheel.new()
	wheel.client = client
	wheel.pack = pack
	wheel.hub = self
	wheel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(wheel)
	events["fw"] = wheel
	if pack != null:
		pack.picture(FW_ICON)
		pack.picture(FW_WORD)
	for key: String in ORDER:
		var path: String = MODULE_DIR + key + ".gd"
		if key != "fw" and ResourceLoader.exists(path):
			if later:
				_ev_wait.append(key)
			else:
				_ev_load(key)
	_art_hold = _ev_wait.size()


func _ev_load(key: String) -> void :
	if events.has(key):
		return
	var script: Variant = load(MODULE_DIR + key + ".gd")
	if script is GDScript and (script as GDScript).can_instantiate():
		attach(key, (script as GDScript).new())


func ev_ready() -> void :
	while not _ev_wait.is_empty():
		_ev_load(str(_ev_wait.pop_front()))
	_art_hold = 0


func attach(key: String, view: Control) -> Control:
	if events.has(key) or not ORDER.has(key):
		return null
	for field: String in ["client", "pack"]:
		if field in view:
			view.set(field, get(field))
	if "hub" in view:
		view.set("hub", self)
	view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(view)
	if view.has_signal("closed"):
		view.connect("closed", _on_closed)
	events[key] = view
	if _booted and view.has_method("boot"):
		view.call("boot")
	return view

func _on_closed(note: String = "") -> void :
	if not note.is_empty():
		say(note)


func _each(method: String) -> void :
	for key: String in ORDER:
		var view: Variant = events.get(key)
		if view != null and is_instance_valid(view) and (view as Object).has_method(method):
			(view as Object).call(method)

func _ev_shown(key: String) -> bool:
	var view: Variant = events.get(key)
	return view != null and is_instance_valid(view) and (view as Object).has_method("button_visible") and bool((view as Object).call("button_visible"))

func _process(delta: float) -> void :
	if not _ev_wait.is_empty() and client != null and str(client.state) not in PRE_AUTH and _art_turn != Engine.get_process_frames():
		_art_turn = Engine.get_process_frames()
		_ev_load(str(_ev_wait.pop_front()))
		_art_hold = _ev_wait.size()
	if client != null and wheel != null:
		_follow(str(client.state))
		if str(client.state) == "lobby" and _booted:
			_beat_acc += delta
			if _beat_acc >= (BEAT_FAST if _fast < MB_FAST_TICKS else BEAT_SLOW):
				_beat_acc = 0.0
				beat()
	visible = client != null and str(client.state) == "lobby" and (lobby == null or lobby.is_visible_in_tree())
	super (delta)



func _follow(state: String) -> void :
	if state != _was:
		if _was == "lobby":
			_each("leave")
		if state in LOGGED_OUT and _booted:
			_each("reset")
			_booted = false
		_was = state
	if state == "lobby" and not _booted and (lobby == null or lobby.is_visible_in_tree()):
		ev_ready()
		_booted = true
		_fast = 0
		_beat_acc = 0.0
		_each("boot")


func beat() -> void :
	if _fast < MB_FAST_TICKS:
		_fast += 1
	_each("beat")



func slot() -> Vector2:
	if lobby != null and lobby.has_method("_origin") and lobby.has_method("_act_shift"):
		var hidden: Array = lobby.call("_acts_hidden")
		var places: Dictionary = lobby.get("_act_x")
		var x: float = float(places.get("event:monthly", MONTHLY_X)) + float(lobby.call("_act_shift", "event:monthly", hidden))
		return lobby.call("_origin", "acts") + Vector2(x, ROW2_DY)
	var frame: Array = HallAtlas.FRAME["acts"]
	return Vector2(floorf(_fw + 0.01) + float(frame[1]) + MONTHLY_X, float(frame[2]) + ROW2_DY)



func top_slot() -> Vector2:
	if lobby != null and lobby.has_method("_origin") and lobby.has_method("_act_shift"):
		var hidden: Array = lobby.call("_acts_hidden")
		var places: Dictionary = lobby.get("_act_x")
		var x: float = float(places.get("event:growth", GROWTH_X)) + float(lobby.call("_act_shift", "event:growth", hidden))
		return lobby.call("_origin", "acts") + Vector2(x - ACT_STEP, 0.0)
	var frame: Array = HallAtlas.FRAME["acts"]
	return Vector2(floorf(_fw + 0.01) + float(frame[1]) + GROWTH_X - ACT_STEP, float(frame[2]))






func chain() -> Dictionary:
	var at: Vector2 = slot()
	var top: Vector2 = top_slot()
	var right: Vector2 = right_slot()
	var wrap: bool = right != Vector2.INF
	var room: int = maxi(0, ROW_MAX - roundi((right.x - top.x) / ACT_STEP)) if wrap else ROW1.size()
	var row: Dictionary = {}
	var flow: int = 0
	for key: String in ROW1:
		if ORDER.has(key) and _ev_shown(key):
			if room > 0:
				row[key] = top
				top.x -= ACT_STEP
				room -= 1
			else:
				row[key] = _flow_at(right, flow)
				flow += 1
	if wrap and flow == 0:
		flow = clampi(roundi((right.x - at.x) / ACT_STEP), 0, ROW_MAX - 1)
	var out: Dictionary = {}
	for key: String in ORDER:
		if _ev_shown(key) and not ROW1.has(key):
			out[key] = _flow_at(right, flow) if wrap else at
			flow += 1
			at.x -= ACT_STEP
	out.merge(row)
	return out



func right_slot() -> Vector2:
	if lobby == null or not lobby.has_method("_origin") or not lobby.has_method("_act_shift"):
		return Vector2.INF
	var places: Variant = lobby.get("_act_x")
	if not (places is Dictionary) or not (places as Dictionary).has("event:first"):
		return Vector2.INF
	var hidden: Array = lobby.call("_acts_hidden")
	var x: float = float(places["event:first"]) + float(lobby.call("_act_shift", "event:first", hidden))
	return lobby.call("_origin", "acts") + Vector2(x, 0.0)


func _flow_at(right: Vector2, index: int) -> Vector2:
	return right + Vector2( - ACT_STEP * float(index % ROW_MAX), ROW2_DY * float(1 + floori(float(index) / float(ROW_MAX))))

func _paint() -> void :
	spots = chain()
	var daily: Rect2 = _daily_menu()
	for key: String in spots.keys():
		if daily.has_area() and daily.intersects(Rect2(spots[key] * _f, Vector2(50, 50) * _f)):
			spots.erase(key)
			continue
		_paint_button(key, spots[key])


func _daily_menu() -> Rect2:
	if lobby == null or lobby.get("_daily_open") != true:
		return Rect2()
	var got: Variant = lobby.get("daily_rect")
	return got as Rect2 if got is Rect2 else Rect2()

func _paint_button(key: String, at: Vector2) -> void :
	var view: Object = events[key]
	var icon: Texture2D = _ev_art(view, key, "icon")
	var rect: Rect2 = Rect2(at * _f, Vector2(50, 50) * _f)
	if icon != null:
		rect = Rect2(at * _f, Vector2(icon.get_size()) * _f)
		draw_texture_rect(icon, rect, false, _glow(key))
	_hit(key, rect, false)
	var word: Texture2D = _ev_art(view, key, "word")
	if word != null:
		var corner: Vector2 = at + Vector2(float(int((50 - word.get_width()) / 2)), float(50 - word.get_height()))
		draw_texture_rect(word, Rect2(corner * _f, Vector2(word.get_size()) * _f), false)
	if view.has_method("button_dot") and bool(view.call("button_dot")):
		_fblit("public_tip", at + Vector2(30, 0))
	var tip: String = tip_of(key)
	if not tip.is_empty() and not NO_TIP.has(key) and _hover == key and _press.is_empty() and _tip_ok():
		_note(rect, tip)


func _ev_art(view: Object, key: String, part: String) -> Texture2D:
	if key == "fw":
		return pack.picture(FW_ICON if part == "icon" else FW_WORD) if pack != null else null
	if view.has_method("button_" + part):
		var got: Variant = view.call("button_" + part)
		return got as Texture2D if got is Texture2D else null
	var path: Variant = _const(view, key.to_upper() + "_" + part.to_upper())
	if path is String and not str(path).is_empty() and pack != null:
		return pack.picture(str(path))
	return null


func tip_of(key: String) -> String:
	if key == "fw":
		return FW_TIP
	var view: Variant = events.get(key)
	if view == null:
		return ""
	if (view as Object).has_method("button_tip"):
		return str((view as Object).call("button_tip"))
	var text: Variant = _const(view, key.to_upper() + "_TIP")
	return str(text) if text != null else ""

static func _const(view: Object, name: String) -> Variant:
	var script: Variant = view.get_script()
	while script is Script:
		var map: Dictionary = (script as Script).get_script_constant_map()
		if map.has(name):
			return map[name]
		script = (script as Script).get_base_script()
	return null


func _note(anchor: Rect2, text: String) -> void :
	var wide: float = 230.0
	var text_px: int = maxi(6, roundi(12.0 * _f))
	var text_h: float = ARIAL.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, text_px, 8).y / _f
	var high: float = text_h + 16.0
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	draw_multiline_string(ARIAL, Vector2(at.x + 10.0, at.y + 8.0) * _f + Vector2(0, ARIAL.get_ascent(text_px)), text, 
		HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, text_px, 8, Color.WHITE)


func _has_point(point: Vector2) -> bool:
	return not _hit_at(point).is_empty()

func _activate(id: String) -> void :
	if _ev_shown(id) and (events[id] as Object).has_method("open"):
		(events[id] as Object).call("open")
