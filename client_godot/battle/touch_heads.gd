extends RefCounted














const TouchLq = preload("touch_lq.gd")
const TankPortrait = preload("../ui/tank_portrait.gd")
const TankPreview = preload("../ui/tank_preview.gd")
const TankState = preload("../ui/tankstate_atlas.gd")

const ON: bool = true
const R: float = 14.0
const RING: float = 2.6
const PITCH: float = 36.0
const NAME_PX: float = 7.0
const ROW_GAP: float = 6.0
const EDGE: float = 3.0
const TOP: float = 6.0
const MIN_K: float = 0.6
const FACE_C: Vector2 = Vector2(100, 108)
const FACE_R: float = 66.0
const OWN: Color = Color("47e05e")
const FOE: Color = Color("ff4636")
const LOST_A: float = 0.26
const SELF_RIM: Color = Color("ffd84a")
const CD_READY: Color = Color("3fe04f")
const DEAD_TINT: Color = Color(0.5, 0.5, 0.5, 1.0)
const DEAD_VEIL: Color = Color(0.32, 0.32, 0.34, 0.5)
const VIP_COLOR: Color = Color("fff000")
const SEG: int = 40





static func layout(hud, battle, n: int) -> Dictionary:
	var view: Control = hud.view
	var u: float = TouchLq.unit(view.size)
	var base: float = hud.layout_scale()
	var texture: Texture2D = view._textures.get("minimap")
	var mm: Vector2 = TouchLq.map_fit(texture.get_size()) * TouchLq.TouchLayout.mm_scale() if texture != null and hud.minimap_shown(battle) else Vector2.ZERO
	var right: bool = mm.x > 0 and TouchLq.TouchLayout.mm_right()
	var map: Rect2 = Rect2(hud.touch_map_origin(mm), mm * base)

	var safe_in: Vector4 = hud.get("safe_in") if hud.get("safe_in") is Vector4 else Vector4.ZERO
	var safe_tr: Vector2 = hud.get("safe_tr") if hud.get("safe_tr") is Vector2 else Vector2.ZERO
	var ping: Rect2 = ping_rect(hud, map)
	var score_l: float = view.size.x / 2.0 - 150.0 * base
	var score_r: float = view.size.x / 2.0 + 150.0 * base
	var lo: float
	var hi: float
	if right:
		lo = score_r + EDGE * u
		hi = (map.position.x if mm.x > 0 else view.size.x - safe_in.z) - EDGE * u
	else:
		lo = (map.end.x if mm.x > 0 else TouchLq.MAP_AT * base + safe_in.x) + EDGE * u
		hi = score_l - EDGE * u
	var want: float = maxf(1.0, n) * PITCH * u
	var k: float = clampf((hi - lo) / want, MIN_K, 1.0)
	var pitch: float = PITCH * u * k
	if n * pitch > hi - lo:
		pitch = maxf(1.0, (hi - lo) / maxf(1.0, n))
	var r: float = R * u * k
	var ring: float = RING * u * k
	var name: float = NAME_PX * u * k
	var row_h: float = 2.0 * (r + ring) + name * 1.2 + 2.0 * u * k
	var width: float = n * pitch
	var top: float = (TouchLq.SYS_H * base + safe_tr.y + EDGE * u) if right else (safe_in.y + TOP * u)
	var x: float = hi - width if right else lo
	return {"at": Vector2(x, top), "k": k, "pitch": pitch, "r": r, "ring": ring, "name": name, "row_h": row_h, "right": right, 
		"rect": Rect2(x, top, width, 2.0 * row_h + ROW_GAP * u * k), "ping": ping, "map": map}


static func ping_rect(hud, map: Rect2) -> Rect2:
	var view: Control = hud.view
	var k: float = hud.layout_scale()
	var side: float = clampf(46.0 * k, view.size.y * 0.06, view.size.y * 0.11)
	if map.size.x <= 0:
		return Rect2(Vector2(12, view.size.y * 0.24), Vector2(side, side))
	var col: float = 4.0 * minf(view.size.x / 1266.0, view.size.y / 600.0) + (float(TankState.LAYOUT.size[0]) + 4.0) * k
	var left: bool = map.get_center().x > view.size.x * 0.5
	var x: float = map.position.x - col - 8.0 - side if left else map.end.x + col + 8.0
	return Rect2(Vector2(clampf(x, 4.0, maxf(4.0, view.size.x - side - 4.0)), map.position.y), Vector2(side, side))



static func draw(hud, battle, lists: Dictionary, self_camp: int, look: bool) -> void :
	var view: Control = hud.view
	var own: int = self_camp if self_camp in [1, 2] else 1
	var rows: Array = [lists.get(own, []), lists.get(3 - own, [])]
	var n: int = maxi(rows[0].size(), rows[1].size())
	var g: Dictionary = layout(hud, battle, n)
	var u: float = TouchLq.unit(view.size)
	var tiles: Dictionary = {}
	var talks: Array = []
	var chips: Array = []
	var clock: float = float(battle.clock)
	view.draw_set_transform(Vector2.ZERO)
	for row in range(2):
		var ids: Array = rows[row]
		var y: float = g.at.y + row * (g.row_h + ROW_GAP * u * g.k) + g.r + g.ring
		for i in range(ids.size()):
			var tank: Dictionary = battle.tanks[ids[i]]

			var slot: int = n - ids.size() + i if g.right else i
			var c: Vector2 = Vector2(g.at.x + (slot + 0.5) * g.pitch, y)
			var camp: int = int(tank.get("camp", 0))
			var blue: bool = self_camp != 0 and camp == self_camp
			var cd_shown: bool = not look and camp == self_camp
			_tile(hud, battle, tank, c, g, blue, cd_shown, clock)
			tiles[int(tank.id)] = [c, row]
			if look or (battle.watch_shown and camp == self_camp):
				var edge: float = g.r + g.ring
				hud.look_heads[int(tank.id)] = Rect2(c - Vector2(g.pitch * 0.5, edge), Vector2(g.pitch, edge * 2.0))
				var gold: bool = ( not battle.look_free and int(tank.id) == int(battle.look_target)) if look\
				else (int(tank.id) == int(battle.scroll_id) and int(tank.id) != int(battle.self_id))
				if gold:
					view.draw_set_transform(Vector2.ZERO)
					view.draw_arc(c, edge, 0.0, TAU, 32, hud.LOOK_GOLD, 2.0 * u)
			var bubble: Dictionary = battle.bubbles.get(int(tank.account), battle.bubbles.get(int(tank.id), {}))
			if not bubble.is_empty():
				var side: Dictionary = TankState.LAYOUT.left
				var chat: Vector2 = Vector2(side.chat[0], side.chat[1]) + Vector2(float(side.talk_dx), 0)
				var under: Vector2 = Vector2(c.x - g.r, g.rect.end.y + 2.0 * u)
				talks.append([under - chat * hud.scale, bubble])
			if not look and int(tank.get("account", 0)) > 0 and int(tank.get("account", 0)) != int(battle.self_id):
				var at: Vector2 = c + Vector2(g.r + g.ring, g.r + g.ring) * 0.72
				chips.append([at - hud.VOICE_CHIP_LEFT * hud.scale, false, int(tank.account)])
	hud.touch_round = {"rect": g.rect, "k": g.k, "r": g.r, "pitch": g.pitch, "tiles": tiles, "ping": g.ping, "rows": [rows[0].duplicate(), rows[1].duplicate()]}
	for talk: Array in talks:
		hud._at(talk[0])
		hud._state_talk(talk[1], false)
	view.draw_set_transform(Vector2.ZERO)
	hud._voice_chips(chips, view.get_local_mouse_position())

static func _tile(hud, battle, tank: Dictionary, c: Vector2, g: Dictionary, blue: bool, cd_shown: bool, clock: float) -> void :
	var view: Control = hud.view
	var r: float = g.r
	var ring: float = g.ring
	var u: float = TouchLq.unit(view.size)
	var dead: bool = bool(tank.get("dead", false)) or int(tank.get("hp", 0)) <= 0
	var me: bool = int(tank.id) == int(battle.self_id)
	var brief: Dictionary = hud.brief_of(battle, int(tank.account))
	var other: Dictionary = brief.get("otherData") if brief.get("otherData") is Dictionary else {}
	view.draw_circle(c, r + ring, Color(0.02, 0.03, 0.06, 0.72))
	view.draw_circle(c, r, Color(0.12, 0.16, 0.24, 0.9))
	if not brief.is_empty():
		_face(hud, other, c, r, DEAD_TINT if dead else Color.WHITE, clock)
	if dead:
		view.draw_circle(c, r, DEAD_VEIL)
	var color: Color = OWN if blue else FOE
	var mid: float = r + ring * 0.5
	var max_hp: float = maxf(1.0, float(tank.get("max_hp", 1)))
	var fill: float = 0.0 if dead else clampf(float(tank.get("hp", 0)) / max_hp, 0.0, 1.0)
	view.draw_arc(c, mid, 0, TAU, SEG, Color(color, LOST_A), ring, true)
	if fill > 0.0:

		view.draw_arc(c, mid, - PI / 2.0, - PI / 2.0 + TAU * fill, maxi(4, ceili(SEG * fill)), color, ring, true)
	if me:
		view.draw_arc(c, r + ring + 1.1 * u * g.k, 0, TAU, SEG, SELF_RIM, 1.6 * u * g.k, true)
	var font: Font = hud.bold
	if dead and me and float(battle.respawn) > 0.0:
		var fs: int = maxi(9, roundi(r * 1.05))
		var text: String = str(ceili(float(battle.respawn)))
		var base: Vector2 = c + Vector2( - r, fs * 0.36)
		view.draw_string_outline(font, base, text, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, 3, Color(0, 0, 0, 0.9))
		view.draw_string(font, base, text, HORIZONTAL_ALIGNMENT_CENTER, r * 2.0, fs, Color.WHITE)
	if cd_shown and not dead:
		var b: Vector2 = c + Vector2(r + ring, - (r + ring)) * 0.72
		var cd: String = hud.state_cd_text(battle.camp_cd(int(tank.id)))
		if cd.is_empty():
			var br: float = 3.6 * u * g.k
			view.draw_circle(b, br + 1.0 * u * g.k, Color(0, 0, 0, 0.8))
			view.draw_circle(b, br, CD_READY)
			view.draw_circle(b + Vector2(-0.35, -0.35) * br, br * 0.38, Color(1, 1, 1, 0.65))
		else:
			var fs2: int = maxi(8, roundi(6.6 * u * g.k))
			var br2: float = maxf(fs2 * 0.62, 4.6 * u * g.k)
			view.draw_circle(b, br2, Color(0.05, 0.07, 0.12, 0.92))
			view.draw_arc(b, br2, 0, TAU, 20, Color(1, 1, 1, 0.5), 1.0, true)
			var at: Vector2 = b + Vector2( - br2 * 1.5, fs2 * 0.36)
			view.draw_string(font, at, cd, HORIZONTAL_ALIGNMENT_CENTER, br2 * 3.0, fs2, Color.WHITE)
	if not brief.is_empty():
		var data: Dictionary = brief.charData
		var size: int = maxi(8, roundi(float(g.name)))
		var name: String = hud._fit(str(data.get("szName", "")), g.pitch - 2.0, size)
		var ink: Color = VIP_COLOR if int(data.get("nVipLevel", 0)) > 0 else Color.WHITE
		if dead:
			ink = Color(0.8, 0.8, 0.8)
		var at2: Vector2 = Vector2(c.x - g.pitch * 0.5, c.y + r + ring + size * 0.95)
		view.draw_string_outline(font, at2, name, HORIZONTAL_ALIGNMENT_CENTER, g.pitch, size, 5 if dead else 3, Color(0, 0, 0, 1.0 if dead else 0.85))
		view.draw_string(font, at2, name, HORIZONTAL_ALIGNMENT_CENTER, g.pitch, size, ink)


static func _face(hud, other: Dictionary, c: Vector2, r: float, tint: Color, clock: float) -> void :
	face_on(hud.view, hud, other, c, r, tint, clock)


static func face_on(canvas: CanvasItem, hud, other: Dictionary, c: Vector2, r: float, tint: Color, clock: float) -> void :
	var pack = hud.pack
	var tank_id: int = int(other.get("tankId", 0))
	if pack == null or pack.state != "ready" or tank_id <= 0:
		return
	var worn: int = int(other.get("tankExternal", 0))
	var look: Array = hud._avatar_look(tank_id, worn, maxi(1, int(other.get("tankLevel", 1))), int(other.get("haloId", 0)))
	var face: String = str(look[0])
	if not face.is_empty():
		var shot: Array = hud._film_of(face)
		var picture: Texture2D = pack.picture(shot[1])
		if picture != null:
			var zoom: float = r / FACE_R
			var origin: Vector2 = c - FACE_C * zoom
			var spot: Rect2 = TankPortrait.still_rect(shot[0], origin, zoom, shot[2])
			if spot.has_area():
				var pts: PackedVector2Array = PackedVector2Array()
				var uvs: PackedVector2Array = PackedVector2Array()
				for i in range(SEG):
					var p: Vector2 = c + Vector2.from_angle(TAU * i / SEG) * r
					pts.append(p)
					uvs.append((p - spot.position) / spot.size)
				canvas.draw_colored_polygon(pts, tint, uvs, picture)
			return
	var art: Dictionary = pack.external_art(pack.art_external(str(worn), tank_id))
	if TankPreview.ready(art):
		TankPreview.draw(canvas, art, c + Vector2(0, r * 0.1), 0.3 * r / (TankPortrait.BOX * 0.27 * 0.5), 4, clock)
		canvas.draw_set_transform(Vector2.ZERO)
