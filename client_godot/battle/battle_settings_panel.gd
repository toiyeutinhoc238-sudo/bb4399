extends "res://ui/settings.gd"









const VOTE_WAIT: String = "Đầu Hàng (@num1@s)"
const VOTE: String = "Đầu Hàng"

var view: Control

func _init() -> void :
	add_child(preload("auto_quality.gd").new())
	visible = false
	focus_mode = Control.FOCUS_NONE
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _setup() -> void :
	closed.connect( func() -> void : visible = false)


func open() -> void :
	if view == null:
		return
	client = view.client
	pack = view.pack
	visible = true
	queue_redraw()


func close() -> void :
	if visible:
		_close()


func key(event: InputEventKey) -> void :
	if visible and _ask.is_empty() and _capture == 0 and event.pressed and not event.echo\
	and (event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE):
		_close()

func _scene() -> void :
	pass

func _tick(delta: float) -> void :
	if client == null or client.battle.ended or not client.battle.active:
		visible = false
		return
	super (delta)

func _slide(key: String, x: float, store: bool) -> void :
	super (key, x, store)
	if key == "zoom" and view != null:
		view.camera_zoom = Settings.level("zoom")



func vote_state() -> Dictionary:
	if client == null:
		return {}
	var battle = client.battle
	if not (battle.started and battle.supported()):
		return {}
	var now: float = battle.now_seconds()
	var wait: int = ceili(battle.vote_next - now)
	return {"wait": wait, "busy": wait > 0 or ( not battle.vote.is_empty() and float(battle.vote.get("end", 0.0)) > now)}


static func vote_text(wait: int) -> String:
	return VOTE_WAIT.replace("@num1@", str(wait)) if wait > 0 else VOTE


func _paint_vote(_base: Vector2) -> void :
	var state: Dictionary = vote_state()
	if state.is_empty():
		return
	_btn("vote", 570, 453, 135, 37, "red", vote_text(int(state.wait)), 17.0, not bool(state.busy))

func _activate(id: String) -> void :
	if id == "vote":
		var state: Dictionary = vote_state()
		if state.is_empty() or state.busy or not _ask.is_empty() or _capture != 0:
			return
		client.request_surrender()
		_finish()
		return
	super (id)
