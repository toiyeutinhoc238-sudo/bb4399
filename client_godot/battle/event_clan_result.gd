extends "pvp_result.gd"












const ROOMS: Array = [5]
const BACK_DELAY: float = 10.0
const RETRY: float = 5.0

var since: float = 0.0
var backs: int = 0
var _next_back: float = BACK_DELAY


static func wanted(game) -> bool:
	return game != null and game.state == "battle" and game.battle.ended and int(game.battle.room_type) in ROOMS

func _shown() -> void :
	super ()
	since = 0.0
	backs = 0
	_next_back = BACK_DELAY

func _tick(delta: float) -> void :
	super (delta)
	if client == null:
		return
	since += delta
	if since >= _next_back and wanted(client):
		_next_back = since + RETRY
		backs += 1
		client.leave_battle(2)




func _paint() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var o: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	_hit("panel", Rect2(o * _f, Vector2(float(Atlas.SIZE[0]), float(Atlas.SIZE[1])) * _f), false)
	for key: String in ["bg", "board", "chat", "brief", "tank"]:
		_fblit("pr_" + key, o + _v(Atlas.PANELS[key]))
	var battle = client.battle
	_boards(o, battle)
	_chat(o, battle)
	_brief(o, battle)
	_tank(o, battle)
