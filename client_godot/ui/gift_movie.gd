extends "flash_screen.gd"


















const FlaPlayer = preload("fla_player.gd")


const MOVIES: Dictionary = {
	2001001: ["fla/gl1", 3], 
	2001002: ["fla/gr1", 3], 
	2001011: ["fla/gl2", 4], 
	2001012: ["fla/gr2", 4], 
	2001013: ["fla/gl3", 5], 
	2001014: ["fla/gr3", 5], 
	2001016: ["fla/gr2", 4], 
	2001017: ["fla/gr3", 5], 
}
const CENTRE: Vector2 = Vector2(500, 300)

var room: Control
var _slots: Dictionary = {4: null, 5: null}
var _wait: Array = []

func _setup() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func used(value: Dictionary) -> void :
	var id: int = int(value.get("m_nItemId", 0))
	if not MOVIES.has(id):
		return
	var row: Array = MOVIES[id]
	if int(row[1]) <= 3:
		if not value.get("bulletin", false) and room != null and room.has_method("gift_seat"):
			room.gift_seat(int(str(value.get("m_targetUuid", "")).to_int()), str(row[0]))
		return
	_wait.append(id)
	visible = true

func can_play(quality: int) -> bool:
	if client == null or client.battle.active or client.state == "battle":
		return false
	return client.state == "room" if quality == 4 else quality == 5

func _tick(_delta: float) -> void :
	for id: int in _wait.duplicate():
		var key: String = str(MOVIES[id][0])
		var fx: Dictionary = pack.effect(key)
		if FlaPlayer.valid(fx.get("data")):
			_wait.erase(id)
			_play(int(MOVIES[id][1]), fx)
		elif pack.effect_failed(key):
			_wait.erase(id)
	var at: Vector2 = (_stage() + CENTRE) * _f
	var idle: bool = _wait.is_empty()
	for quality: int in _slots:
		var player: Variant = _slots[quality]
		if player != null:
			player.transform = Transform2D(0.0, Vector2(_f, _f), 0.0, at)
			idle = false
	if idle:
		visible = false

func _play(quality: int, fx: Dictionary) -> void :
	if not can_play(quality):
		return
	_stop(quality)
	var player: FlaPlayer = FlaPlayer.new()
	if player.add_clip(fx) < 0:
		player.free()
		return
	player.event.connect( func(name: String) -> void :
		if name == "mc_complete" and _slots[quality] == player:
			_stop(quality))
	add_child(player)
	move_child(player, 0)
	player.transform = Transform2D(0.0, Vector2(_f, _f), 0.0, (_stage() + CENTRE) * _f)
	_slots[quality] = player

func _stop(quality: int) -> void :
	var player: Variant = _slots[quality]
	_slots[quality] = null
	if player != null and is_instance_valid(player):
		player.visible = false
		player.queue_free()


class SeatFx extends Node2D:
	const LOAD_MS: int = 4000
	var view: Control
	var rows: Array = []

	func play(seat: String, key: String) -> void :
		rows.append({"seat": seat, "key": key, "born": Time.get_ticks_msec(), "player": null})

	func clear() -> void :
		for row: Dictionary in rows:
			if row.player != null and is_instance_valid(row.player):
				row.player.queue_free()
		rows = []

	func _process(_delta: float) -> void :
		if rows.is_empty():
			return
		if view.client == null or view.client.state != "room":
			clear()
			return
		for row: Dictionary in rows.duplicate():
			if row.player == null:
				var fx: Dictionary = view.pack.effect(str(row.key))
				if not FlaPlayer.valid(fx.get("data")):
					if view.pack.effect_failed(str(row.key)) or Time.get_ticks_msec() - int(row.born) > LOAD_MS:
						rows.erase(row)
					continue
				var player: FlaPlayer = FlaPlayer.new()
				if player.add_clip(fx) < 0:
					player.free()
					rows.erase(row)
					continue
				player.event.connect( func(name: String) -> void :
					if name == "mc_complete":
						rows.erase(row)
						player.visible = false
						player.queue_free())
				add_child(player)
				row.player = player
			row.player.transform = view.gift_seat_xf(str(row.seat))
