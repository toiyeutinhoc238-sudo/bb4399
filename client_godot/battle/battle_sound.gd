extends RefCounted














const Sound = preload("res://audio.gd")
const Settings = preload("res://settings.gd")



const NARSND1_KEYS: Array[String] = ["shoulijian", "senlinzhinu", "taidixiong_wanju", "siwangshizhe_e_01", "diaochan_k"]
const NARSND1_WAIT_MS: int = 300
const NARSND1_NEAR: float = 220.0
var _narsnd1_fresh: Array[Vector2] = []
const BUFFER: float = 220.0

var _started: bool = false
var _ended: bool = false
var _alive: bool = true
var _camera: Vector2 = Vector2.ZERO
var _half: Vector2 = Vector2(500, 300)
var _seen: Dictionary = {}
var _lit: Dictionary = {}
var _battle_key: int = 0


static func death_name(table: Dictionary, external: String, art: String) -> String:
	var deaths: Dictionary = table.get("d", {})
	return str(deaths.get(external, deaths.get(art, deaths.get("*", ""))))


static func bullet_row(table: Dictionary, exhibit: int) -> Array:
	var row: Variant = table.get("b", {}).get(str(exhibit), [])
	return row if row is Array and row.size() >= 3 else []


static func ainpc_external(row: Array, my_camp: int) -> String:
	if row.size() < 2:
		return ""
	return str(int(row[1]) if int(row[1]) != 0 and my_camp == 1 else int(row[0]))


static func buff_name(table: Dictionary, template: int) -> String:
	return str(table.get("bf", {}).get(str(template), ""))


static func pair(table: Dictionary, key: String, template: int) -> Array:
	var row: Variant = table.get(key, {}).get(str(template), [])
	return row if row is Array and row.size() >= 2 else []


static func gain_at(offset: Vector2, half: Vector2, skill: bool, mine: bool) -> float:
	var gain: float = 1.0 if skill else 0.6
	if mine:
		return gain
	var off: Vector2 = offset.abs()
	if off.x > half.x + BUFFER or off.y > half.y + BUFFER:
		return 0.0
	if off.x > half.x or off.y > half.y:
		return gain * 0.45
	return gain * lerpf(1.0, 0.7, clampf(off.length() / maxf(1.0, half.length()), 0.0, 1.0))



func tick(battle, pack, fx, camera: Vector2, half: Vector2, held: bool = false) -> void :
	if pack == null or pack.sounds.is_empty():
		return
	_camera = camera
	_half = half
	var table: Dictionary = pack.sounds
	var entered: bool = battle.started and not held
	if entered and not _started and not battle.ended:
		Sound.play("u/begin")
	_started = entered
	if battle.ended and not _ended:
		Sound.music("")

		var own: Dictionary = battle.tanks.get(battle.self_id, {})
		if not own.is_empty():
			Sound.play("u/lose" if int(battle.outcome.get("m_winCamp", 0)) != int(own.get("camp", 0)) else "u/win")
	_ended = battle.ended
	var me: Dictionary = battle.tanks.get(battle.self_id, {})
	var alive: bool = me.is_empty() or not me.dead
	if alive and not _alive and battle.started and not battle.ended:
		Sound.play("u/relive")
	_alive = alive
	for effect: Dictionary in battle.effects:
		if effect.has("heard"):
			continue
		effect["heard"] = true
		match str(effect.kind):
			"fire":
				var bullet: Dictionary = effect.get("bullet", {})
				var row: Array = bullet_row(table, fx.exhibit_id(bullet, battle)) if fx.ready() and not bullet.is_empty() else []
				if not row.is_empty() and not str(row[0]).is_empty():
					if NARSND1_KEYS.has(str(row[0])):
						var heard: Array = _at_tracked("f/" + str(row[0]), effect.pos, int(row[2]) == 1, int(bullet.get("shooter", 0)) == battle.self_id)
						if not heard.is_empty():
							bullet["snd"] = heard
					else:
						_at("f/" + str(row[0]), effect.pos, int(row[2]) == 1, int(bullet.get("shooter", 0)) == battle.self_id)
			"hit":
				var bullet: Dictionary = effect.get("bullet", {})
				var row: Array = bullet_row(table, fx.exhibit_id(bullet, battle)) if fx.ready() and not bullet.is_empty() else []
				if not row.is_empty() and not str(row[1]).is_empty():
					_at("x/" + str(row[1]), effect.pos, true, false)
			"skill":
				var entry: Dictionary = pack.skill(int(effect.get("skill", 0)))
				var row: Array = bullet_row(table, int(entry.get("c" if effect.get("ready", false) else "s", 0)))
				var name: String = str(row[0]) if not row.is_empty() else ""

				if name.is_empty() and entry.get("c", 0) == 0 and entry.get("s", 0) == 0:
					name = str(table.get("sk", {}).get(str(int(effect.get("skill", 0))), ""))
				if not name.is_empty():
					var caster: Dictionary = battle.actor(int(effect.get("caster", 0)))
					_at("f/" + name, caster.pos if caster.has("pos") else effect.pos, true, int(effect.get("caster", 0)) == battle.self_id)
			"death":
				var id: int = int(effect.get("actor", 0))
				var external: String = ""
				var art: String = ""
				if battle.tanks.has(id):
					var look: Dictionary = battle.appearances.get(int(battle.tanks[id].get("account", 0)), {})
					external = str(look.get("external", 0))
					art = pack.art_external(external, int(look.get("tank", 0)))
				var name: String = ""
				if battle.tanks.has(id) or id >> 26 != 5:
					name = death_name(table, external, art)
				else:

					name = str(table.get("d", {}).get(_ainpc_external(battle, pack, id), ""))
				if not name.is_empty():
					_at("d/" + name, effect.pos, true, id == battle.self_id)
			"remove":

				var seen: Dictionary = _find(4, int(effect.get("template", 0)), effect.pos)
				var row: Array = pair(table, "c", int(effect.get("template", 0)))
				if not row.is_empty() and not str(row[1]).is_empty() and _item_heard(battle, int(seen.get("camp", 0))):
					_at("f/" + str(row[1]), effect.pos, true, false)
			"destroy":

				var seen: Dictionary = _find(3, int(effect.get("template", 0)), effect.pos)
				var row: Array = pair(table, "n", int(effect.get("template", 0)))
				if not seen.is_empty() and not seen.get("whole", false) and not row.is_empty() and not str(row[1]).is_empty():
					seen["whole"] = true
					_at("n/" + str(row[1]), effect.pos, true, false)

	var buff_table: Dictionary = table.get("bf", {})
	for added: Dictionary in battle.buff_added:
		var name: String = str(buff_table.get(str(int(added.tpl)), ""))
		if not name.is_empty() and battle.started and not battle.ended:
			_at("f/" + name, added.pos, true, bool(added.self))
	battle.buff_added.clear()
	_objects(battle, pack, table)
	_narsnd1_cuts(battle)

	for mark: Dictionary in battle.sprays:
		if not mark.has("heard"):
			mark["heard"] = true
			if not mark.has("sneer"):
				_at("u/spray", mark.pos, true, false)
	if not battle.honors.is_empty():
		var honor: Dictionary = battle.honors[0]
		if float(honor.t) >= 0.0 and not honor.has("heard"):
			honor["heard"] = true
			var voice: String = str(honor.get("voice", ""))
			if not voice.is_empty() and Settings.on("voice"):
				Sound.play("k/" + voice)

func _at(key: String, pos: Vector2, skill: bool, mine: bool) -> void :
	var gain: float = gain_at(pos - _camera, _half, skill, mine)
	if gain > 0.0:
		Sound.play(key, gain)

func _at_tracked(key: String, pos: Vector2, skill: bool, mine: bool) -> Array:
	var gain: float = gain_at(pos - _camera, _half, skill, mine)
	return Sound.play_tracked(key, gain) if gain > 0.0 else []


func _narsnd1_cuts(battle) -> void :
	var fresh: Array[Vector2] = _narsnd1_fresh
	_narsnd1_fresh = []
	if battle.sound_cuts.is_empty():
		return
	var now: int = Time.get_ticks_msec()
	var keep: Array = []
	for cut: Dictionary in battle.sound_cuts:
		var follow: bool = false
		for pos: Vector2 in fresh:
			if pos.distance_to(cut.pos) <= NARSND1_NEAR:
				follow = true
				break
		if follow:
			continue
		if battle.ended or now - int(cut.ms) >= NARSND1_WAIT_MS:
			Sound.cut(cut.snd)
		else:
			keep.append(cut)
	battle.sound_cuts = keep


func _objects(battle, pack, table: Dictionary) -> void :
	if battle.ended or battle.get_instance_id() != _battle_key:
		_battle_key = battle.get_instance_id()
		_seen = {}
		_lit = {}
		Sound.boss = false
		if battle.ended:
			return
	var live: bool = battle.started and not battle.ended
	var hits: Dictionary = table.get("h", {})
	var lit: Dictionary = {}
	for id: int in battle.tanks:
		var tank: Dictionary = battle.tanks[id]
		var mine: bool = id == battle.self_id
		_buffs(table, tank, false, live, mine)
		lit[id] = float(tank.get("lit", -1.0))
		if tank.has("lit") and live and _lit.has(id) and float(_lit[id]) != float(tank.lit):
			var look: Dictionary = battle.appearances.get(int(tank.get("account", 0)), {})
			var hit: String = str(hits.get(str(int(look.get("external", 0))), ""))
			if not hit.is_empty():
				_at("d/" + hit, tank.pos, true, mine)
	var seen: Dictionary = {}
	var bosses: Dictionary = table.get("bo", {})
	var boss: bool = false
	for id: int in battle.npcs:
		var npc: Dictionary = battle.npcs[id]
		var kind: int = id >> 26
		var template: int = int(npc.get("template", 0))
		var first: bool = not _seen.has(id)
		var entry: Dictionary = {"t": template, "pos": npc.get("pos", Vector2.ZERO), "camp": int(npc.get("camp", 0)), 
			"whole": false if first else bool(_seen[id].get("whole", false))}
		var changed: bool = npc.has("lit") and _lit.has(id) and float(_lit[id]) != float(npc.lit)
		lit[id] = float(npc.get("lit", -1.0))
		match kind:
			3:
				var row: Array = pair(table, "n", template)
				if changed and live and not row.is_empty():
					var dead: bool = bool(npc.get("dead", false)) or int(npc.get("hp", 1)) <= 0
					var name: String = str(row[1] if dead else row[0])
					if dead:
						entry.whole = true
					if not name.is_empty():
						_at("n/" + name, entry.pos, true, false)
			4:
				var row: Array = pair(table, "c", template)
				if first:
					_narsnd1_fresh.append(entry.pos as Vector2)
				if first and live and not row.is_empty() and not str(row[0]).is_empty() and _item_heard(battle, int(entry.camp)):
					_at("f/" + str(row[0]), entry.pos, true, false)
			5:
				_buffs(table, npc, first, live, false)
				if changed and live:
					var hit: String = str(hits.get(_ainpc_external(battle, pack, id), ""))
					if not hit.is_empty():
						_at("d/" + hit, entry.pos, true, false)
				if bosses.has(str(template)):
					boss = true
		seen[id] = entry

	for id: int in _seen:
		if not seen.has(id) and not _seen[id].has("gone"):
			var old: Dictionary = _seen[id]
			old["gone"] = true
			seen[id] = old
	_seen = seen
	_lit = lit
	Sound.boss = boss and live


func _buffs(table: Dictionary, obj: Dictionary, fresh: bool, live: bool, mine: bool) -> void :
	var buffs: Variant = obj.get("buffs")
	if not buffs is Dictionary:
		return
	for buff: Variant in (buffs as Dictionary).values():
		if not buff is Dictionary or (buff as Dictionary).has("heard"):
			continue
		buff["heard"] = true
		if not live or ( not buff.has("t0") and not fresh):
			continue
		var name: String = buff_name(table, int(buff.get("m_nBuffTpltId", 0)))
		if not name.is_empty():
			_at("f/" + name, obj.get("pos", Vector2.ZERO), true, mine)


func _item_heard(battle, camp: int) -> bool:
	return bool(battle.look) or camp == 0 or camp == battle.self_camp()

func _ainpc_external(battle, pack, id: int) -> String:
	var template: int = int(battle.npcs[id].get("template", 0)) if battle.npcs.has(id) else int(_seen.get(id, {}).get("t", 0))
	if template == 0 or not pack.has_method("ainpc_row"):
		return ""
	return ainpc_external(pack.ainpc_row(template), battle.self_camp())


func _find(kind: int, template: int, pos: Vector2) -> Dictionary:
	for id: int in _seen:
		var entry: Dictionary = _seen[id]
		if id >> 26 == kind and int(entry.t) == template and (entry.pos as Vector2).distance_to(pos) < 1.0:
			return entry
	return {}
