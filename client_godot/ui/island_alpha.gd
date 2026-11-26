extends RefCounted









const IsleAtlas = preload("island_atlas.gd")
const AlphaAtlas = preload("island_alpha_atlas.gd")
const IslandNoel = preload("island_noel.gd")

const RECHECK_MS: int = 60000
const FADE: float = 1.0
const LIGHT_PERIOD: Array = [1.3, 1.75, 2.2]
const LIGHT_PHASE: Array = [0.0, 0.37, 0.71]
const GLOW_COL: Color = Color8(255, 214, 120)
const PORTAL: Vector2 = Vector2(786, 398)

const BEACONS: Array = [[Vector2(924, 379), Color8(255, 60, 50), 0.0], [Vector2(924, 392), Color8(70, 150, 255), 0.5], [Vector2(315, 295), Color8(255, 60, 50), 0.25]]
const BEACON_PERIOD: float = 1.1

const BEAMS: Array = [
	[Vector2(972, 436), "isle", -100.0, 28.0, 9.0, 0.0], 
	[Vector2(0.16, 1.03), "frame", -62.0, 22.0, 11.0, 0.35], 
	[Vector2(0.66, 1.03), "frame", -118.0, 24.0, 10.0, 0.7], 
]
const BEAM_LEN: float = 820.0
const BEAM_HALF: float = 4.5
const BEAM_COL: Color = Color(1.0, 0.95, 0.82)
const GLINTS: int = 140
const GLINTS_LOW: int = 50

const FW_RISE: float = 0.6
const FW_LIFE: float = 1.8
const FW_GAP: Array = [0.9, 2.2]
const FW_GAP_LOW: Array = [3.0, 5.0]
const FW_MAX: int = 3
const FW_PARTS: int = 28
const FW_PARTS_LOW: int = 16
const FW_COLS: Array = [Color8(255, 214, 110), Color8(255, 92, 70), Color8(255, 248, 235), Color8(255, 160, 60)]

const BALLOON_SPEED: Array = [26.0, 46.0]
const BALLOON_GAP: Array = [1.6, 3.2]
const BALLOON_GAP_LOW: Array = [4.0, 7.0]
const BALLOON_MAX: int = 9
const BALLOON_MAX_LOW: int = 3

const CONFETTI: Array = [70, 50, 24]
const CONFETTI_AREA: float = 1366.0 * 768.0
const CONFETTI_COLS: Array = [Color8(232, 50, 42), Color8(245, 184, 46), Color8(244, 241, 234), Color8(245, 122, 31), Color8(70, 150, 255)]

var season: bool = true
var auto_night: bool = false
var shown: String = ""
var _due: int = -1
var _fade_from: String = ""
var _fade_at: float = -1.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _glints: Array = []
var _far: Array = []
var _sea_key: String = ""
var _fireworks: Array = []
var _fw_next: float = NAN
var _balloons: Array = []
var _bal_next: float = NAN
var _last_t: float = -1.0
var _confetti: Array = []
var _confetti_key: String = ""
var _meshes: Dictionary = {}
var drew: Dictionary = {}
var _dot: Texture2D
var _glow: Texture2D
var _line: Texture2D

func _init() -> void :
	_rng.seed = 20261028
	_dot = IslandNoel._radial([[0.0, 1.0], [0.55, 0.8], [1.0, 0.0]])
	_glow = IslandNoel._radial([[0.0, 1.0], [0.3, 0.83], [0.5, 0.56], [0.7, 0.26], [0.85, 0.08], [1.0, 0.0]])
	_line = IslandNoel._linear(Vector2(1, 0))

static func low() -> bool:
	return IslandNoel.low()

static func fx_on() -> bool:
	return IslandNoel.fx_on()

func refresh(force: bool = false) -> void :
	var tick: int = Time.get_ticks_msec()
	if not force and _due >= 0 and tick < _due:
		return
	_due = tick + RECHECK_MS
	auto_night = IslandNoel.night_at(IslandNoel.now())

func want() -> String:
	var mode: String = IslandNoel.mode_setting()
	if mode == "night" or (mode == "auto" and auto_night):
		return "n"
	return "d"


func files() -> Array:
	return AlphaAtlas.SHARED + AlphaAtlas.DAY + AlphaAtlas.NIGHT + AlphaAtlas.FX

func need(m: String) -> Array:
	return AlphaAtlas.SHARED + (AlphaAtlas.NIGHT if m == "n" else AlphaAtlas.DAY)

func file(name: String, m: String) -> String:
	if not AlphaAtlas.SHARED.has(name + ".webp"):
		return AlphaAtlas.SUB + m + "_" + name + ".webp"
	return name + ".webp"

func show(m: String, time: float) -> void :
	drew = {}
	if shown != "" and shown != m:
		_fade_from = shown
		_fade_at = time
	shown = m

func fade(time: float) -> float:
	if _fade_from == "" or _fade_at < 0.0:
		return 0.0
	var u: float = (time - _fade_at) / FADE
	if u >= 1.0 or u < 0.0:
		_fade_from = ""
		return 0.0
	return 1.0 - u

func fade_mode() -> String:
	return _fade_from


func _tex(view: Object, file_name: String) -> Texture2D:
	return view.pack._pictures.get(IsleAtlas.DIR + file_name) as Texture2D

static func _isle(view: Object, at: Vector2) -> Vector2:
	return view._isle_o + at * float(view._isle_s)


func draw_ground(view: Object, t: float) -> void :
	if not fx_on() or shown == "":
		return
	var night: bool = shown == "n"
	drew["ground"] = true
	var f: float = view._f
	var fx: Texture2D = _tex(view, AlphaAtlas.FX[1] if night else AlphaAtlas.FX[0])
	if fx != null:
		_draw_flags(view, fx, t)
		if night:
			_draw_lights(view, fx, t)
	_sea(view)
	var gl_a: float = 0.4 if night else 0.55
	for g: Array in _glints:
		var ph: float = fposmod((t - float(g[3])) / float(g[4]), 1.0)
		if ph > 0.45:
			continue
		var col: Color = (Color8(255, 214, 140) if int(g[2]) == 1 else Color8(232, 228, 214)) if night else Color.WHITE
		col.a = sin(ph / 0.45 * PI) * gl_a
		var span: float = float(g[5]) + 1.0
		view.draw_texture_rect(_line, Rect2(Vector2(float(g[0]) - span, float(g[1])) * f, Vector2(2.0 * span, 1.0) * f), false, col)
	if not night:
		return
	var s: float = float(view._isle_s)
	var centre: Vector2 = _isle(view, PORTAL)
	var radius: float = 52.0 * s
	view.draw_texture_rect(_glow, Rect2((centre - Vector2(radius, radius / 1.25)) * f, Vector2(2.0 * radius, 2.0 * radius / 1.25) * f), false, Color(0.45, 0.62, 1.0, (0.1 + 0.08 * sin(TAU * t / 2.3)) * 1.6))
	for b: Array in BEACONS:
		var on: float = clampf(sin(TAU * (t / BEACON_PERIOD + float(b[2]))) * 1.6, 0.0, 1.0)
		if on <= 0.0:
			continue
		var at: Vector2 = _isle(view, b[0])
		var col: Color = b[1]
		col.a = 0.75 * on
		var r: float = 9.0 * s
		view.draw_texture_rect(_glow, Rect2((at - Vector2(r, r)) * f, Vector2(2.0 * r, 2.0 * r) * f), false, col)
		col = col.lerp(Color.WHITE, 0.5)
		col.a = on
		r = 2.2 * s
		view.draw_texture_rect(_dot, Rect2((at - Vector2(r, r)) * f, Vector2(2.0 * r, 2.0 * r) * f), false, col)
	drew["beams"] = _draw_beams(view, t)
	_draw_fireworks(view, t)


func draw_sky(view: Object, t: float) -> void :
	if not fx_on() or shown == "":
		return
	var night: bool = shown == "n"
	var lo: bool = low()
	if _last_t >= 0.0 and t < _last_t - 0.5:
		_balloons.clear()
		_fireworks.clear()
		_bal_next = NAN
		_fw_next = NAN
	_last_t = t
	drew["sky"] = true
	_draw_balloons(view, t, night, lo)
	_draw_confetti(view, t, night, lo)

func counts() -> Dictionary:
	return {"glints": _glints.size(), "far": _far.size(), "fireworks": _fireworks.size(), "balloons": _balloons.size(), "confetti": _confetti.size()}


func _sea(view: Object) -> void :
	var wide: float = view._fw
	var high: float = view._fh
	var lo: bool = low()
	var key: String = "%d|%d|%.4f|%s|%s" % [roundi(wide), roundi(high), float(view._isle_s), view._isle_o, lo]
	if key == _sea_key:
		return
	_sea_key = key
	_glints.clear()
	_far.clear()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4242
	var want_glints: int = GLINTS_LOW if lo else GLINTS
	var pts: Array = AlphaAtlas.SEA_PTS
	for i in range(0, pts.size(), 3):
		var at: Vector2 = _isle(view, Vector2(float(pts[i]), float(pts[i + 1])))
		if at.x < 2.0 or at.y < 2.0 or at.x > wide - 2.0 or at.y > high - 2.0:
			continue
		if _glints.size() < want_glints:
			_glints.append([at.x, at.y, int(pts[i + 2]), rng.randf_range(0.0, 3.0), rng.randf_range(2.2, 3.6), rng.randi_range(3, 7)])
		elif int(pts[i + 2]) == 2 and _far.size() < 60 and at.x > 40.0 and at.x < wide - 40.0 and at.y > 50.0 and at.y < high * 0.8:
			_far.append(at)
		if _glints.size() >= want_glints and _far.size() >= 60:
			break


func _draw_flags(view: Object, fx: Texture2D, t: float) -> void :
	var box: Rect2 = AlphaAtlas.FLAG_BOX
	var step: float = 5.0
	var x: float = 0.0
	while x < box.size.x:
		var w: float = minf(step, box.size.x - x)
		var dx: float = sin(TAU * t / 1.7 + 0.21 * (box.position.x + x))
		var src: Rect2 = Rect2(AlphaAtlas.FLAG_AT + Vector2(x, 0), Vector2(w, box.size.y))
		view.draw_texture_rect_region(fx, view._isle_rect(box.position + Vector2(x + dx, 0), Vector2(w, box.size.y)), src)
		x += step


func _draw_lights(view: Object, fx: Texture2D, t: float) -> void :
	var f: float = view._f
	var s: float = view._isle_s
	var at: Transform2D = Transform2D(0.0, Vector2(s * f, s * f), 0.0, view._isle_o * f)
	var dim_on: bool = not low()
	for g in range(AlphaAtlas.LIGHT_GROUPS):
		var b: float = clampf((0.5 + 0.5 * sin(TAU * (t / float(LIGHT_PERIOD[g]) + float(LIGHT_PHASE[g]))) - 0.25) * 1.6, 0.0, 1.0)
		if b < 1.0 and dim_on:
			drew["dim"] = true
			view.draw_mesh(_light_mesh(g, 0, fx), fx, at, Color(0, 0, 0, 1.0 - b))
		if b > 0.0:
			var col: Color = GLOW_COL
			col.a = b
			view.draw_mesh(_light_mesh(g, 1, fx), fx, at, col)

func _light_mesh(g: int, row: int, fx: Texture2D) -> ArrayMesh:
	var key: String = "%d|%d|%d" % [g, row, fx.get_instance_id()]
	if _meshes.has(key):
		return _meshes[key]
	var runs: Array = AlphaAtlas.LIGHT_RUNS_N[g][row]
	var cell: Vector2 = AlphaAtlas.LIGHT_CELL
	var tile: float = float(AlphaAtlas.LIGHT_TILE)
	var k: Vector2 = IsleAtlas.WORLD / cell
	var origin: Vector2 = Vector2(cell.x * g, cell.y * row)
	var tex: Vector2 = Vector2(fx.get_width(), fx.get_height())
	var pts: PackedVector2Array = PackedVector2Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	for i in range(0, runs.size(), 3):
		var a: Vector2 = Vector2(float(runs[i + 1]), float(runs[i])) * tile
		var b: Vector2 = a + Vector2(float(runs[i + 2]) * tile, tile)
		for c: Vector2 in [a, Vector2(b.x, a.y), b, a, b, Vector2(a.x, b.y)]:
			pts.append(c * k)
			uvs.append((origin + c) / tex)
	var mesh: ArrayMesh = ArrayMesh.new()
	if not pts.is_empty():
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = pts
		arrays[Mesh.ARRAY_TEX_UV] = uvs
		mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	if _meshes.size() > 12:
		_meshes.clear()
	_meshes[key] = mesh
	return mesh


func _draw_beams(view: Object, t: float) -> int:
	var f: float = view._f
	var n: int = 0
	for beam: Array in BEAMS:
		if n > 0 and low():
			break
		var src: Vector2 = beam[0]
		var at: Vector2 = _isle(view, src) if str(beam[1]) == "isle" else Vector2(src.x * float(view._fw), src.y * float(view._fh))
		var ang: float = deg_to_rad(float(beam[2]) + float(beam[3]) * sin(TAU * (t / float(beam[4]) + float(beam[5]))))
		var half: float = deg_to_rad(BEAM_HALF)
		var far: float = BEAM_LEN
		var dir_a: Vector2 = Vector2(cos(ang - half), sin(ang - half))
		var dir_b: Vector2 = Vector2(cos(ang + half), sin(ang + half))
		var side: Vector2 = Vector2( - sin(ang), cos(ang)) * 2.0
		var mid: float = 0.45
		var c0: Color = BEAM_COL
		c0.a = 0.2
		var c1: Color = BEAM_COL
		c1.a = 0.08
		var c2: Color = BEAM_COL
		c2.a = 0.0
		view.draw_polygon(PackedVector2Array([(at - side) * f, (at + side) * f, (at + dir_b * far * mid) * f, (at + dir_a * far * mid) * f]), 
			PackedColorArray([c0, c0, c1, c1]))
		view.draw_polygon(PackedVector2Array([(at + dir_a * far * mid) * f, (at + dir_b * far * mid) * f, (at + dir_b * far) * f, (at + dir_a * far) * f]), 
			PackedColorArray([c1, c1, c2, c2]))
		if str(beam[1]) == "isle":
			var r: float = 8.0 * float(view._isle_s)
			view.draw_texture_rect(_glow, Rect2((at - Vector2(r, r)) * f, Vector2(2.0 * r, 2.0 * r) * f), false, Color(1.0, 0.93, 0.7, 0.85))
		n += 1
	return n


func _draw_fireworks(view: Object, t: float) -> void :
	if _far.is_empty():
		return
	var lo: bool = low()
	if is_nan(_fw_next):
		_fw_next = t + 1.0
	if t >= _fw_next:
		var gap: Array = FW_GAP_LOW if lo else FW_GAP
		_fw_next = t + _rng.randf_range(float(gap[0]), float(gap[1]))
		if _fireworks.size() < (1 if lo else FW_MAX):
			var at: Vector2 = _far[_rng.randi_range(0, _far.size() - 1)]
			var parts: int = FW_PARTS_LOW if lo else FW_PARTS
			var angs: PackedFloat32Array = PackedFloat32Array()
			var vels: PackedFloat32Array = PackedFloat32Array()
			for i in range(parts):
				angs.append(TAU * i / parts + _rng.randf_range(-0.08, 0.08))
				vels.append(_rng.randf_range(0.85, 1.1))
			_fireworks.append([at.x, at.y, t + FW_RISE, _rng.randi_range(0, FW_COLS.size() - 1), _rng.randf_range(38.0, 60.0), angs, vels])
	var f: float = view._f
	var keep: Array = []
	for fw: Array in _fireworks:
		var boom: float = float(fw[2])
		if t > boom + FW_LIFE:
			continue
		keep.append(fw)
		var at: Vector2 = Vector2(float(fw[0]), float(fw[1]))
		var col: Color = FW_COLS[int(fw[3])]
		if t < boom:
			var u: float = 1.0 - (boom - t) / FW_RISE
			var p: Vector2 = at + Vector2(0, 90.0 * (1.0 - u))
			for j in range(4):
				var c: Color = Color(1.0, 0.9, 0.7, 0.8 * (1.0 - j / 4.0))
				var r: float = 1.6 - j * 0.25
				view.draw_texture_rect(_dot, Rect2((p + Vector2(0, j * 4.0) - Vector2(r, r)) * f, Vector2(2.0 * r, 2.0 * r) * f), false, c)
			continue
		var age: float = t - boom
		var life: float = age / FW_LIFE
		if age < 0.3:
			var flash: float = 1.0 - age / 0.3
			var fr: float = 26.0
			view.draw_texture_rect(_glow, Rect2((at - Vector2(fr, fr)) * f, Vector2(2.0 * fr, 2.0 * fr) * f), false, Color(col.r, col.g, col.b, 0.5 * flash))
		var spread: float = float(fw[4]) * (1.0 - exp(-3.2 * age))
		var drop: float = 16.0 * age * age
		var a: float = pow(1.0 - life, 1.3)
		var angs: PackedFloat32Array = fw[5]
		var vels: PackedFloat32Array = fw[6]
		var twinkle: bool = life > 0.55
		for i in range(angs.size()):
			if twinkle and (i + int(t * 14.0)) % 3 == 0:
				continue
			var d: Vector2 = Vector2(cos(angs[i]), sin(angs[i])) * vels[i]
			var p: Vector2 = at + d * spread + Vector2(0, drop)
			var c: Color = col.lerp(Color.WHITE, 0.35 * (1.0 - life))
			c.a = a
			var r: float = 1.7
			view.draw_texture_rect(_dot, Rect2((p - Vector2(r, r)) * f, Vector2(2.0 * r, 2.0 * r) * f), false, c)
			c.a = a * 0.45
			var q: Vector2 = at + d * spread * 0.8 + Vector2(0, drop * 0.8)
			r = 1.2
			view.draw_texture_rect(_dot, Rect2((q - Vector2(r, r)) * f, Vector2(2.0 * r, 2.0 * r) * f), false, c)
	_fireworks = keep
	drew["fireworks"] = _fireworks.size()


func _draw_balloons(view: Object, t: float, night: bool, lo: bool) -> void :
	var sheet: Texture2D = _tex(view, AlphaAtlas.FX[2])
	if sheet == null:
		return
	var wide: float = view._fw
	var high: float = view._fh
	if is_nan(_bal_next):
		_bal_next = t + 1.0
		for i in range(2 if lo else 4):
			_spawn_balloon(wide, t - _rng.randf_range(2.0, (high + 120.0) / BALLOON_SPEED[1]))
	if t >= _bal_next:
		var gap: Array = BALLOON_GAP_LOW if lo else BALLOON_GAP
		_bal_next = t + _rng.randf_range(float(gap[0]), float(gap[1]))
		if _balloons.size() < (BALLOON_MAX_LOW if lo else BALLOON_MAX):
			_spawn_balloon(wide, t)
	var f: float = view._f
	var tint: Color = Color(0.72, 0.7, 0.8) if night else Color.WHITE
	var keep: Array = []
	for b: Array in _balloons:
		var cell: Array = AlphaAtlas.BALLOON[int(b[0])]
		var dim: Vector2 = Vector2(float(cell[2]), float(cell[3])) * 0.5 * float(b[6])
		var age: float = t - float(b[2])
		var y: float = high + 10.0 - float(b[3]) * age
		if y + dim.y < -10.0:
			continue
		keep.append(b)
		var sway: float = sin(TAU * age / float(b[5]) + float(b[7]))
		var x: float = float(b[1]) + float(b[4]) * sway
		view.draw_set_transform(Vector2(x, y) * f, 0.07 * cos(TAU * age / float(b[5]) + float(b[7])), Vector2(f, f))
		view.draw_texture_rect_region(sheet, Rect2( - dim.x / 2.0, 0.0, dim.x, dim.y), Rect2(float(cell[0]), float(cell[1]), float(cell[2]), float(cell[3])), tint)
	view.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_balloons = keep
	drew["balloons"] = _balloons.size()

func _spawn_balloon(wide: float, t0: float) -> void :
	var cell: int = _rng.randi_range(0, AlphaAtlas.BALLOON.size() - 1)
	var size: float = _rng.randf_range(0.55, 0.85) if cell >= 4 else _rng.randf_range(0.6, 1.0)
	_balloons.append([cell, _rng.randf_range(30.0, wide - 30.0), t0, _rng.randf_range(BALLOON_SPEED[0], BALLOON_SPEED[1]), 
		_rng.randf_range(6.0, 16.0), _rng.randf_range(3.0, 5.5), size, _rng.randf_range(0.0, TAU)])


func _draw_confetti(view: Object, t: float, night: bool, lo: bool) -> void :
	var wide: float = view._fw
	var high: float = view._fh
	var key: String = "%s|%s|%d|%d" % [night, lo, roundi(wide), roundi(high)]
	if key != _confetti_key:
		_confetti_key = key
		_confetti.clear()
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 2810
		var area: float = clampf(wide * high / CONFETTI_AREA, 0.35, 2.5)
		var n: int = roundi(float(CONFETTI[2 if lo else (1 if night else 0)]) * area)
		for i in range(n):
			_confetti.append([rng.randf(), rng.randf_range(-20.0, high), rng.randf_range(18.0, 34.0), rng.randf_range(6.0, 18.0), 
				rng.randf_range(2.5, 5.0), rng.randf_range(0.5, 1.3), rng.randf_range(0.0, TAU), rng.randf_range(-2.5, 2.5), 
				rng.randi_range(0, CONFETTI_COLS.size() - 1), rng.randf_range(2.4, 3.6), rng.randf_range(1.3, 2.0)])
	var f: float = view._f
	var k: float = 0.78 if night else 1.0
	for c: Array in _confetti:
		var x: float = fposmod(float(c[0]) * wide + float(c[3]) * sin(TAU * t / float(c[4]) + float(c[6])), wide)
		var y: float = fposmod(float(c[1]) + float(c[2]) * t, high + 20.0) - 10.0
		var rot: float = float(c[6]) + float(c[7]) * t
		var flip: float = maxf(0.15, absf(cos(TAU * t / float(c[5]) + float(c[6]))))
		var u: Vector2 = Vector2(cos(rot), sin(rot)) * float(c[9]) * 0.5 * flip
		var v: Vector2 = Vector2( - sin(rot), cos(rot)) * float(c[10]) * 0.5
		var col: Color = CONFETTI_COLS[int(c[8])]
		col = Color(col.r * k * (0.75 + 0.25 * flip), col.g * k * (0.75 + 0.25 * flip), col.b * k * (0.75 + 0.25 * flip), 0.95)
		var p: Vector2 = Vector2(x, y)
		view.draw_primitive(PackedVector2Array([(p - u - v) * f, (p + u - v) * f, (p + u + v) * f, (p - u + v) * f]), PackedColorArray([col, col, col, col]), PackedVector2Array())
