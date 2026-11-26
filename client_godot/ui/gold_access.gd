extends "flash_screen.gd"







const Atlas = preload("gold_access_atlas.gd")

signal matching_asked

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const TITLE: String = "CÁCH KIẾM BẠC"
const TIP_425: String = "Thiếu Bạc, thi đấu Đấu So Tài hoặc Đấu Xếp Hạng nhận Bạc."
const HINT: String = "Thi đấu Đấu So Tài hoặc Đấu Xếp Hạng để nhận Bạc. Bấm VÀO CHIẾN ĐẤU để ghép trận So Tài ngay."
const HIDE_IN: Array = ["login", "auth", "servers", "connecting", "characters", "battle"]

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_use(Atlas.FILE, Atlas.R)
	if client != null:
		client.changed.connect(_follow)


func open() -> void :
	if client != null and (client.state in HIDE_IN or client.battle.active):
		return
	visible = true
	say(TIP_425)
	queue_redraw()

func close() -> void :
	visible = false

func _follow() -> void :
	if visible and (client.state in HIDE_IN or client.battle.active):
		visible = false

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var wide: float = float(Atlas.SIZE[0])
	var at: Vector2 = _centre(wide, float(Atlas.SIZE[1]))
	var frame: Vector2 = at + _xy(Atlas.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("ga_frame") * _f), false)
	_fblit("ga_frame", frame)
	_fwords(TITLE, ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2(158, 17), 160.0, 1.5, 28.0)
	var button: Array = Atlas.NODES["btnMatching"]
	_fpara(HINT, ARIAL_BOLD, 14.0, Color.WHITE, at + Vector2(32, 104), float(button[0]) - 52.0)
	_fbutton("matching", "ga_matching", at + _xy(button))
	_fbutton("close", "ga_close", at + _xy(Atlas.NODES["btnClose"]))



func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "matching":
		close()
		matching_asked.emit()

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
