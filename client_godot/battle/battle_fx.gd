extends RefCounted













const FPS: float = 24.0
const WAIT: float = 1.5
const HOLD_MAX: float = 20.0
const Settings = preload("res://settings.gd")

var view: CanvasItem
var pack: Node

func _init(owner: CanvasItem) -> void :
	view = owner

func ready() -> bool:
	return pack != null and not pack.fx.is_empty()


var _links: Dictionary = {}
var _links_src: Dictionary = {}
func link_buff(id: int) -> Dictionary:
	if pack == null:
		return {}
	if not is_same(_links_src, pack.fx):
		_links_src = pack.fx
		_links.clear()
	var hit: Variant = _links.get(id)
	if hit == null:
		hit = pack.link_buff(id)
		_links[id] = hit
	return hit


static func rotation(from: Vector2, to: Vector2) -> float:
	return from.angle_to_point(to) + PI / 2


static func edge(start: Vector2, dest: Vector2, extent: Vector2) -> Vector2:
	var direction: Vector2
	if start.x == dest.x and start.y == dest.y:
		return dest
	elif start.x == dest.x:
		direction = Vector2(0, signf(dest.y - start.y))
	elif start.y == dest.y:
		direction = Vector2(signf(dest.x - start.x), 0)
	else:
		var degrees: int = int(rad_to_deg(atan2(dest.y - start.y, dest.x - start.x)) + 90.0)
		direction = Vector2.from_angle(deg_to_rad(degrees - 90.0))
	var reach: float = INF
	if direction.x > 1e-06: reach = minf(reach, (extent.x - start.x) / direction.x)
	elif direction.x < -1e-06: reach = minf(reach, - start.x / direction.x)
	if direction.y > 1e-06: reach = minf(reach, (extent.y - start.y) / direction.y)
	elif direction.y < -1e-06: reach = minf(reach, - start.y / direction.y)
	return start + direction * maxf(reach, 0.0) if is_finite(reach) else dest

static func _vec(value: Variant) -> Vector2:
	return Vector2(float(value[0]), float(value[1])) if value is Array and value.size() == 2 else Vector2.ZERO


func exhibit_id(bullet: Dictionary, battle) -> int:
	var shooter_id: int = int(bullet.get("shooter", 0))
	var shooter: Dictionary = battle.actor(shooter_id)
	var tank: bool = battle.tanks.has(shooter_id)
	var turret: int = 0
	if tank:
		var look: Dictionary = battle.appearances.get(int(shooter.get("account", 0)), {})
		turret = pack.turret_of(pack.art_external(str(look.get("external", 0)), int(look.get("tank", 0))))
	var template: int = int(bullet.get("template", 0))



	if tank and SSK8_HOT.has(template) and pack.skill(int(SSK8_HOT[template])).has("b") and ssk8_susanoo(shooter, battle):
		return pack.fire_exhibit(int(SSK8_HOT[template]), turret, tank)
	return pack.fire_exhibit(template, turret, tank)


const SSK8_HOT: Dictionary = {368100: 368310, 608100: 608310}
const SSK8_SUSANOO: Array[int] = [368301, 608301]


static func ssk8_susanoo(shooter: Dictionary, battle) -> bool:
	for buff: Dictionary in shooter.get("buffs", {}).values():
		if int(buff.get("m_nBuffTpltId", 0)) in SSK8_SUSANOO:
			var exist: float = float(buff.get("exist", 0.0))
			if exist <= 0.0 or not buff.has("t0") or float(battle.clock) - float(buff.t0) < exist + 0.5:
				return true
	return false


func prepare(bullet: Dictionary, battle) -> Dictionary:
	var known: Variant = bullet.get("ex")
	if known != null:
		return known
	if not ready():
		return {}
	var shooter: Dictionary = battle.actor(int(bullet.get("shooter", 0)))
	var ex: Dictionary = pack.exhibit(exhibit_id(bullet, battle))




	if not pack.skill(int(bullet.template)).has("r") and not bullet.has("land") and not pack.normal_shot(int(bullet.template)) and not bullet.has("hold"):
		bullet.dest = edge(bullet.start, bullet.dest, battle.map.extent)
	var camp: int = int(shooter.get("camp", 0))
	bullet.tail = (0 if camp == battle.self_camp() else 1) if camp in [1, 2] else 2
	bullet.ex = ex
	pack.effect(str(ex.get("b", "")))
	pack.effect(str(ex.get("x", "")))
	pack.effect(str(ex.get("lb", "")))
	pack.effect(str(ex.get("lh", "")))
	return ex






const CULL_PAD: float = 4.0
func frame(asset: Dictionary, index: int, pos: Vector2, angle: float, offset: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> void :
	var cells: Variant = asset.get("_pf")
	if cells == null:
		cells = []
		cells.resize(asset.data.frames.size())
		asset["_pf"] = cells
	var i: int = clampi(index, 0, cells.size() - 1)
	var c: Variant = cells[i]
	if c == null:
		var cell: Dictionary = asset.data.frames[i]
		var r: Array = cell.rect
		var pivot: Array = cell.pivot
		var px: float = float(pivot[0])
		var py: float = float(pivot[1])
		var w: float = float(r[2])
		var h: float = float(r[3])
		c = [asset.pages[int(cell.page)], px, py, w, h, Rect2(r[0], r[1], r[2], r[3]), 
			Vector2(maxf(absf(px), absf(w - px)), maxf(absf(py), absf(h - py))).length()]
		cells[i] = c
	var zoom: float = view._zoom
	var at: Vector2 = view._offset + pos * zoom
	var reach: float = (float(c[6]) + offset.length()) * zoom + CULL_PAD
	var box: Vector2 = view.size
	if at.x < - reach or at.y < - reach or at.x > box.x + reach or at.y > box.y + reach:
		return
	view.draw_set_transform(at, angle, Vector2(zoom, zoom))
	view.draw_texture_rect_region(c[0], Rect2(offset.x - float(c[1]), offset.y - float(c[2]), float(c[3]), float(c[4])), c[5], tint)


const HLB1_NO_STANDIN: bool = true


func draw_bullet(bullet: Dictionary, battle) -> bool:
	var ex: Dictionary = prepare(bullet, battle)
	if str(ex.get("bm", "")) == "link":
		return draw_link(bullet, ex)

	if bullet.start != bullet.dest and bullet.pos == bullet.dest:
		return true



	if HLB1_NO_STANDIN and not ex.has("b") and ex.has("u"):
		return true
	var known: Variant = bullet.get("_pfb")
	var image: Dictionary = known if known != null else (pack.effect(str(ex.get("b", ""))) if not ex.is_empty() else {})
	if image.is_empty():
		return false
	if known == null:
		bullet["_pfb"] = image
	var angle: float = rotation(bullet.start, bullet.dest)
	var count: int = image.data.frames.size()
	var index: int = 0
	match str(ex.get("bm", "one")):
		"loop":
			index = int(bullet.age * FPS / maxf(1.0, float(ex.get("bi", 2)))) % count
		"once":
			var total: float = bullet.start.distance_to(bullet.dest)
			index = int(bullet.start.distance_to(bullet.pos) / total * (count - 1)) if total > 0 else 0
		_:
			var tails: Array = ex.get("t", [])
			if tails.size() == 3:
				var seen: Variant = bullet.get("_pft")
				var tail: Dictionary = seen if seen != null else pack.effect(str(tails[int(bullet.get("tail", 2))]))
				if not tail.is_empty():
					if seen == null:
						bullet["_pft"] = tail
					frame(tail, int(bullet.age * FPS) % tail.data.frames.size(), bullet.pos, angle, _vec(ex.get("to")))
	frame(image, index, bullet.pos, angle, _vec(ex.get("bo")))
	return true


static func link_frame(origin: Vector2, head: Vector2, count: int) -> int:
	return clampi(int(origin.distance_to(head)), 1, maxi(1, count))



static func link_angle(bullet: Dictionary) -> float:
	var origin: Vector2 = bullet.get("origin", bullet.start)
	if bullet.get("moved", false) and not origin.is_equal_approx(bullet.pos):
		return origin.angle_to_point(bullet.pos)
	return bullet.start.angle_to_point(bullet.dest)



func draw_link(bullet: Dictionary, ex: Dictionary) -> bool:
	var rope: Dictionary = pack.effect(str(ex.get("b", "")))
	var base: Dictionary = pack.effect(str(ex.get("lb", "")))
	var head: Dictionary = pack.effect(str(ex.get("lh", "")))
	if rope.is_empty() or base.is_empty() or head.is_empty():
		return false
	var origin: Vector2 = bullet.get("origin", bullet.start)
	var angle: float = link_angle(bullet)
	var n: float = float(link_frame(origin, bullet.pos, int(ex.get("ln", 1))))
	if bullet.has("spmtn1_pre"):
		return spmtn1_charge(bullet, base, origin)
	if bullet.has("spmtn1_full"):
		n = float(link_frame(origin, bullet.dest, int(ex.get("ln", 1))))
		if bullet.get("moved", false) and not origin.is_equal_approx(bullet.dest):
			angle = origin.angle_to_point(bullet.dest)
	var tick: int = int(bullet.age * FPS)
	var cut: Vector2 = _vec(ex.get("lc"))
	var slide: Vector2 = _vec(ex.get("lx"))
	var cell: Dictionary = rope.data.frames[tick % rope.data.frames.size()]
	var r: Array = cell.rect
	var pivot: Array = cell.pivot
	var width: float = clampf(cut.x + cut.y * n + float(pivot[0]), 0.0, float(r[2]))
	if width > 0.0:
		view.draw_set_transform(view._offset + origin * view._zoom, angle, Vector2(view._zoom, view._zoom))
		view.draw_texture_rect_region(rope.pages[int(cell.page)], 
			Rect2( - float(pivot[0]), - float(pivot[1]), width, float(r[3])), Rect2(r[0], r[1], width, r[3]))
	frame(base, tick % base.data.frames.size(), origin, angle)
	frame(head, 0, origin, angle, Vector2(slide.x + slide.y * n, 0.0))
	return true


static func flash_rotation(from: Vector2, to: Vector2) -> float:
	var dx: int = int(to.x) - int(from.x)
	var dy: int = int(to.y) - int(from.y)
	if dx == 0:
		return 0.0 if dy < 0 else PI
	return deg_to_rad(float(int(rad_to_deg(atan2(float(dy), float(dx))) + 90.0)))


static func link_buff_frame(from: Vector2, to: Vector2, count: int) -> int:
	var dx: int = int(to.x) - int(from.x)
	var dy: int = int(to.y) - int(from.y)
	return clampi(int(sqrt(float(dx * dx + dy * dy))), 1, maxi(1, count))



static func link_rope_rect(link: Dictionary, cell: Dictionary, n: float) -> Rect2:
	var r: Array = cell.rect
	var pivot: Vector2 = _vec(cell.pivot)
	var across: Vector2 = _vec(link.get("lm"))
	var top: Vector2 = _vec(link.get("lc"))
	var bottom: Vector2 = _vec(link.get("ld"))
	var x0: float = maxf( - pivot.x, across.x)
	var x1: float = minf( - pivot.x + float(r[2]), across.y)
	var y0: float = maxf( - pivot.y, top.x + top.y * n)
	var y1: float = minf( - pivot.y + float(r[3]), bottom.x + bottom.y * n)
	return Rect2(x0, y0, x1 - x0, y1 - y0) if x1 > x0 and y1 > y0 else Rect2()







const SPMTN1_RISE: float = 0.25
const SPMTN1_FADE: float = 0.2
func spmtn1_charge(bullet: Dictionary, base: Dictionary, origin: Vector2) -> bool:
	var age: float = float(bullet.age)
	var k: float = clampf(age / SPMTN1_RISE, 0.0, 1.0)
	var fade: float = clampf((1.2 - age) / SPMTN1_FADE, 0.0, 1.0)
	var pulse: float = 1.0 + (0.08 * sin(age * 38.0) if k >= 1.0 else 0.0)
	var cell: Dictionary = base.data.frames[int(age * FPS) % base.data.frames.size()]
	var r: Array = cell.rect
	var pivot: Array = cell.pivot
	var angle: float = origin.angle_to_point(bullet.dest) if not origin.is_equal_approx(bullet.dest) else 0.0
	var at: Vector2 = view._offset + origin * view._zoom
	for layer: Array in [[0.45 + 0.75 * k, (0.25 + 0.45 * k) * fade], [0.3 + 0.45 * k, (0.45 + 0.55 * k) * fade]]:
		var s: float = float(layer[0]) * pulse * view._zoom
		view.draw_set_transform(at, angle, Vector2(s, s))
		view.draw_texture_rect_region(base.pages[int(cell.page)], Rect2( - float(pivot[0]), - float(pivot[1]), float(r[2]), float(r[3])), 
			Rect2(r[0], r[1], r[2], r[3]), Color(1, 1, 1, float(layer[1])))
	return true


func draw_link_buff(link: Dictionary, origin: Vector2, dest: Vector2, age: float, tint: Color = Color.WHITE) -> bool:
	var rope: Dictionary = pack.effect(str(link.get("b", "")))
	var base: Dictionary = pack.effect(str(link.lb)) if link.has("lb") else {}
	var head: Dictionary = pack.effect(str(link.lh)) if link.has("lh") else {}
	if rope.is_empty() or (link.has("lb") and base.is_empty()) or (link.has("lh") and head.is_empty()):
		return false
	var angle: float = flash_rotation(origin, dest)
	var n: float = float(link_buff_frame(origin, dest, int(link.get("ln", 1))))
	var tick: int = maxi(0, int(age * FPS))
	var cell: Dictionary = rope.data.frames[tick % rope.data.frames.size()]
	var area: Rect2 = link_rope_rect(link, cell, n)
	if area.has_area():
		var r: Array = cell.rect
		view.draw_set_transform(view._offset + origin * view._zoom, angle, Vector2(view._zoom, view._zoom))
		view.draw_texture_rect_region(rope.pages[int(cell.page)], area, 
			Rect2(Vector2(float(r[0]), float(r[1])) + _vec(cell.pivot) + area.position, area.size), tint)
	if not base.is_empty():
		frame(base, tick % base.data.frames.size(), origin, angle, Vector2.ZERO, tint)
	if not head.is_empty():
		var sx: Vector2 = _vec(link.get("lx"))
		var sy: Vector2 = _vec(link.get("ly"))
		frame(head, tick % head.data.frames.size(), origin, angle, Vector2(sx.x + sx.y * n, sy.x + sy.y * n), tint)
	return true







const AIRDROP_FLY: float = 2.0
const AIRDROP_SPAN: float = 500.0
const AIRDROP_HIGH: float = 240.0
const AIRDROP_ITEM_AT: float = 1.0


func airdrop_frames(fx: Dictionary) -> Array:
	var out: Array = []
	var age: float = float(fx.age)
	var left: bool = bool(fx.get("left", true))
	var alive: bool = false
	var item: Dictionary = pack.effect("event/plane_item")
	if age < AIRDROP_FLY:
		alive = true
		var plane: Dictionary = pack.effect("event/feiji" if left else "event/feiji_r")
		if not plane.is_empty():
			var start: float = AIRDROP_SPAN if left else - AIRDROP_SPAN
			out.append({"asset": plane, "index": int(age * FPS) % plane.data.frames.size(), 
				"pos": Vector2(fx.pos.x + start * (1.0 - 2.0 * age / AIRDROP_FLY), fx.pos.y - AIRDROP_HIGH), "offset": Vector2.ZERO})
	if age < AIRDROP_ITEM_AT:
		alive = true
	elif item.is_empty():
		alive = alive or not (pack.effect_failed("event/plane_item") or age > AIRDROP_ITEM_AT + WAIT)
	else:
		if not fx.has("t1"):
			fx.t1 = age
		var index: int = int((age - float(fx.t1)) * FPS)
		if index < item.data.frames.size():
			alive = true
			var stage: Array = item.data.get("stage", [0, 0])
			out.append({"asset": item, "index": index, "pos": fx.pos, "offset": Vector2(float(stage[0]), float(stage[1])) * -0.5})
	fx.life = age + 0.25 if alive else age
	return out

func draw_airdrop(fx: Dictionary, bottom: bool) -> bool:
	if bottom or pack == null:
		return true
	for part: Dictionary in airdrop_frames(fx):
		frame(part.asset, int(part.index), part.pos, 0.0, part.offset)
	return true





func _parts(fx: Dictionary, battle) -> Array:
	var parts: Array = []
	var flashy: bool = Settings.on("skill_fx")
	match str(fx.kind):
		"hit":
			if fx.has("bullet"):
				var bullet: Dictionary = fx.bullet
				var ex: Dictionary = prepare(bullet, battle)
				if ex.has("x") and (flashy or ex.has("xk")):
					parts.append({"key": ex.x, "pos": fx.pos, "angle": rotation(bullet.start, bullet.dest) if ex.has("xr") else 0.0, 
						"offset": _vec(ex.get("xo")), "every": maxf(1.0, float(ex.get("xi", 1))), "bottom": false})
		"fire":
			var bullet: Dictionary = fx.bullet
			prepare(bullet, battle)
			var ex: Dictionary = pack.exhibit(int(pack.skill(int(bullet.template)).get("b", 0)))
			if ex.has("u") and (flashy or ex.has("uk")):
				parts.append({"key": ex.u, "pos": bullet.start, "angle": rotation(bullet.start, bullet.dest) if ex.has("ud") else 0.0, 
					"offset": Vector2.ZERO, "every": 1.0, "bottom": ex.has("l")})
		"skill":
			var entry: Dictionary = pack.skill(int(fx.skill))
			var ids: Array = [entry.get("c", 0)] if fx.ready else [entry.get("s", 0), entry.get("a", 0)]
			var caster: Dictionary = battle.actor(int(fx.caster))
			var at: Vector2 = caster.pos if caster.has("pos") else fx.start


			for id: Variant in ids:
				var ex: Dictionary = pack.exhibit(int(id))
				if ex.has("u") and (flashy or ex.has("uk")):
					parts.append({"key": ex.u, "pos": at, "angle": rotation(fx.start, fx.pos) if ex.has("ud") else 0.0, 
						"offset": Vector2.ZERO, "every": 1.0, "bottom": ex.has("l"), "use": true, "loop": fx.get("hold", false)})
				if ex.has("x") and (flashy or ex.has("xk")):
					parts.append({"key": ex.x, "pos": fx.pos, "angle": rotation(Vector2(fx.start.x, fx.start.x), fx.pos) if ex.has("xr") else 0.0, 
						"offset": _vec(ex.get("xo")), "every": maxf(1.0, float(ex.get("xi", 1))), "bottom": false})

			var name_key: String = pack.skill_name(int(fx.skill))
			if not name_key.is_empty() and int(fx.get("count", 1)) == 1 and (int(entry.get("c", 0)) == 0 or fx.ready) and Settings.on("skill_name"):
				parts.append({"key": name_key, "pos": at, "angle": 0.0, "offset": Vector2.ZERO, "every": 1.0, "bottom": false})
		"death":

			var tank: Dictionary = battle.tanks.get(int(fx.get("actor", 0)), {})
			var look: Dictionary = battle.appearances.get(int(tank.get("account", 0)), {})
			var pair: Array = pack.body_death(str(look.get("external", 0)), int(look.get("tank", 0))) if not fx.has("template") else _ainpc_death(fx, battle)
			for i: int in pair.size():
				if not str(pair[i]).is_empty():
					parts.append({"key": str(pair[i]), "pos": fx.pos, "angle": 0.0, "offset": Vector2.ZERO, "every": 1.0, "bottom": i == 0})

			var face: String = pack.tank_face()
			if not tank.is_empty() and not face.is_empty():
				parts.append({"key": face, "pos": fx.pos, "angle": 0.0, "offset": Vector2.ZERO, "every": 1.0, "bottom": false})
		"remove":

			var key: String = str(pack.item(int(fx.get("template", 0))).get("x", ""))
			if not key.is_empty():
				parts.append({"key": key, "pos": fx.pos, "angle": 0.0, "offset": Vector2.ZERO, "every": 1.0, "bottom": false})
		"destroy":

			var key: String = pack.npc_destroy(int(fx.get("template", 0)), battle.self_camp() == 1)
			if not key.is_empty():
				parts.append({"key": key, "pos": fx.pos, "angle": 0.0, "offset": Vector2.ZERO, "every": 1.0, "bottom": false})
		"born":

			var key: String = pack.tank_born()
			if not key.is_empty():
				parts.append({"key": key, "pos": fx.pos, "angle": 0.0, "offset": Vector2.ZERO, "every": 1.0, "bottom": false})
		"gone":

			var key: String = pack.bullet_gone()
			if not key.is_empty():
				parts.append({"key": key, "pos": fx.pos, "angle": 0.0, "offset": Vector2.ZERO, "every": 1.0, "bottom": false})
		"appear":

			var key: String = pack.ainpc_appear(int(fx.get("template", 0)))
			var maya1_row: Array = pack.ainpc_row(int(fx.get("template", 0)))
			if maya1_row.size() >= 6 and int(maya1_row[5]) == 5:
				key = ""
			if not key.is_empty():
				parts.append({"key": key, "pos": fx.pos, "angle": 0.0, "offset": Vector2.ZERO, "every": 1.0, "bottom": false})
	for part: Dictionary in parts:
		pack.effect(str(part.key))
	return parts



func _ainpc_death(fx: Dictionary, battle) -> Array:
	var row: Array = pack.ainpc_row(int(fx.template))
	if row.size() < 2:
		return []
	if row.size() >= 6 and int(row[5]) == 4:
		var owner: Dictionary = battle.tanks.get(int(fx.get("owner", 0)), {})
		var look: Dictionary = battle.appearances.get(int(owner.get("account", 0)), {})
		return pack.body_death(str(look.get("external", 0)), int(look.get("tank", 0))) if not look.is_empty() else []
	return pack.body_death(str(int(row[1]) if int(row[1]) != 0 and battle.self_camp() == 1 else int(row[0])), 0)



const FX_KINDS: Dictionary = {"hit": true, "fire": true, "skill": true, "remove": true, "death": true, "destroy": true, "born": true, 
	"appear": true, "gone": true}






const NTTG1_BLASTS: Dictionary = {389100: 144.0}
const NTTG1_TIME: float = 0.36
const NTTG1_TOUCH: float = 24.0
const NTTG1_BACK: float = 160.0
const NTTG1_HULL: float = 50.0
const NTTG1_NPC: float = 60.0
const NTTG1_COLOR: Color = Color(1.0, 0.42, 0.72)


func nttg1_center(fx: Dictionary, battle) -> Vector2:
	var bullet: Dictionary = fx.bullet
	var at: Vector2 = fx.pos
	var back: Vector2 = at.move_toward(bullet.get("start", at), NTTG1_BACK)
	var shooter: int = int(bullet.get("shooter", 0))
	var best: float = INF
	var center: Vector2 = at
	for kind: int in 2:
		var list: Dictionary = battle.npcs if kind == 1 else battle.tanks
		for target: Dictionary in list.values():
			var tid: int = int(target.get("id", 0))
			if tid == shooter or target.get("dead", false) or int(target.get("hp", 1)) <= 0 or not (target.get("pos") is Vector2):
				continue
			var radius: float = NTTG1_HULL
			if kind == 1:
				if tid >> 26 != 5:
					continue
				radius = NTTG1_NPC
			elif target.has("throw"):
				continue
			var near: Vector2 = Geometry2D.get_closest_point_to_segment(target.pos, back, at)
			if near.distance_to(target.pos) > NTTG1_TOUCH + radius:
				continue
			var along: float = back.distance_to(near)
			if along < best:
				best = along
				center = target.pos
	return center


func _nttg1_ring(fx: Dictionary, battle, bottom: bool) -> bool:
	if not fx.has("_nttg1_r"):
		fx["_nttg1_r"] = float(NTTG1_BLASTS.get(int(fx.bullet.get("template", 0)), 0.0)) if fx.get("bullet") is Dictionary else 0.0
	var radius: float = fx["_nttg1_r"]
	if radius <= 0.0 or fx.age > NTTG1_TIME:
		return false
	if not fx.has("_nttg1_at"):
		fx["_nttg1_at"] = nttg1_center(fx, battle)
	var t: float = clampf(fx.age / NTTG1_TIME, 0.0, 1.0)
	var zoom: float = view._zoom
	var gfx: Variant = view.get("_gfx")
	view.draw_set_transform(view._offset + (fx["_nttg1_at"] as Vector2) * zoom, 0.0, Vector2(zoom, zoom))
	if bottom:
		if gfx == null or int(gfx.level) > 0:
			view.draw_circle(Vector2.ZERO, radius * lerpf(0.45, 1.0, sqrt(t)), Color(NTTG1_COLOR, 0.2 * (1.0 - t)))
	else:
		view.draw_arc(Vector2.ZERO, radius, 0.0, TAU, 72, Color(NTTG1_COLOR, 0.9 * (1.0 - t * t)), 2.5, true)
	view.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true

func draw_effect(fx: Dictionary, battle, bottom: bool) -> bool:
	var drawn: bool = _draw_effect0(fx, battle, bottom)
	if str(fx.kind) == "hit" and _nttg1_ring(fx, battle, bottom):
		if not bottom:
			fx.life = maxf(float(fx.life), fx.age + 0.1)
		return true
	return drawn

func _draw_effect0(fx: Dictionary, battle, bottom: bool) -> bool:
	if str(fx.kind) == "airdrop":
		return draw_airdrop(fx, bottom)


	if bottom and fx.get("_pf_up", false):
		return true
	if not ready() or not FX_KINDS.has(str(fx.kind)) or (fx.kind == "hit" and not fx.has("bullet")):
		return false
	if not fx.has("parts"):
		fx.parts = _parts(fx, battle)
		var up: bool = true
		for part: Dictionary in fx.parts:
			up = up and not bool(part.bottom)
		fx["_pf_up"] = up
	if fx.parts.is_empty():
		return fx.kind != "death"
	var alive: bool = false
	for part: Dictionary in fx.parts:
		if part.get("done", false):
			continue
		if part.get("use", false) and fx.get("cut", false):
			part.done = true
			continue
		var known: Variant = part.get("_pfa")
		var asset: Dictionary = known if known != null else pack.effect(str(part.key))
		if asset.is_empty():
			if pack.effect_failed(str(part.key)) or fx.age > WAIT:
				part.done = true
			else:
				alive = true
			continue
		if known == null:
			part["_pfa"] = asset
		if not part.has("t0"):
			part.t0 = fx.age
		var index: int = int((fx.age - float(part.t0)) * FPS / float(part.every))
		if index >= asset.data.frames.size():
			if not part.get("loop", false) or fx.age > HOLD_MAX:
				part.done = true
				continue
			index %= asset.data.frames.size()
		alive = true
		if bool(part.bottom) == bottom:
			frame(asset, index, part.pos, float(part.angle), part.offset)
	if not bottom:
		fx.life = fx.age + 0.25 if alive else fx.age
		if str(fx.kind) == "skill" and _ring(fx, battle):
			fx.life = maxf(float(fx.life), fx.age + 0.1)
	return true



const RING_SKILLS: Dictionary = {343301: 600.0, 449301: 600.0, 473301: 600.0}
const RING_TIME: float = 0.6

func _ring(fx: Dictionary, battle) -> bool:
	var radius: float = float(RING_SKILLS.get(int(fx.get("skill", 0)), 0.0))
	if radius <= 0 or fx.get("ready", false) or fx.age > RING_TIME:
		return false
	var caster: Dictionary = battle.actor(int(fx.caster))
	var at: Vector2 = caster.pos if caster.get("pos") is Vector2 else fx.start
	var t: float = clampf(fx.age / RING_TIME, 0.0, 1.0)
	var zoom: float = view._zoom
	view.draw_set_transform(view._offset + at * zoom, 0.0, Vector2(zoom, zoom))
	view.draw_circle(Vector2.ZERO, radius * lerpf(0.25, 1.0, sqrt(t)), Color(0.55, 1.0, 0.2, 0.16 * (1.0 - t)))
	view.draw_arc(Vector2.ZERO, radius, 0.0, TAU, 96, Color(0.7, 1.0, 0.3, 0.85 * (1.0 - t)), 4.0, true)
	view.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return true
