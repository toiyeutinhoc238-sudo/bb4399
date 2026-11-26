extends RefCounted










const IsleAtlas = preload("island_atlas.gd")
const CuoiAtlas = preload("island_cuoi_atlas.gd")
const IslandNoel = preload("island_noel.gd")

const RECHECK_MS: int = 60000
const FADE: float = 1.0
const LIGHT_PERIOD: Array = [1.4, 1.9, 2.5]
const LIGHT_PHASE: Array = [0.0, 0.37, 0.71]
const GLOW_COL: Color = Color8(255, 214, 140)
const WARM_COL: Color = Color8(255, 190, 100)
const GLINTS: int = 140
const GLINTS_LOW: int = 50

const PETALS: Array = [46, 34, 16]
const PETAL_AREA: float = 1366.0 * 768.0
const PETAL_FALL: Array = [12.0, 22.0]
const PETAL_SWAY: Array = [10.0, 26.0]
const PETAL_SIZE: Array = [1.1, 1.6]

var season: bool = true
var auto_night: bool = false
var shown: String = ""
var _due: int = -1
var _fade_from: String = ""
var _fade_at: float = -1.0
var _glints: Array = []
var _sea_key: String = ""
var _petals: Array = []
var _petal_key: String = ""
var _meshes: Dictionary = {}
var drew: Dictionary = {}
var _dot: Texture2D
var _glow: Texture2D
var _line: Texture2D

func _init() -> void :
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
	return CuoiAtlas.SHARED + CuoiAtlas.DAY + CuoiAtlas.NIGHT + CuoiAtlas.FX

func need(m: String) -> Array:
	return CuoiAtlas.SHARED + (CuoiAtlas.NIGHT if m == "n" else CuoiAtlas.DAY)

func file(name: String, m: String) -> String:
	if not CuoiAtlas.SHARED.has(name + ".webp"):
		return CuoiAtlas.SUB + m + "_" + name + ".webp"
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
	var fx: Texture2D = _tex(view, CuoiAtlas.FX[1])
	if fx != null:
		_draw_lights(view, fx, t)
	var s: float = float(view._isle_s)
	var lo: bool = low()

	for i in range(CuoiAtlas.GLOWS.size()):
		if lo and i > 0:
			break
		var gw: Array = CuoiAtlas.GLOWS[i]
		var breathe: float = 1.0 if lo else 0.8 + 0.2 * sin(TAU * (t / float(gw[3]) + float(gw[4])))
		var col: Color = WARM_COL
		col.a = float(gw[2]) * breathe
		var r: float = float(gw[1]) * s
		var c: Vector2 = _isle(view, gw[0])
		view.draw_texture_rect(_glow, Rect2((c - Vector2(r, r * 0.8)) * f, Vector2(2.0 * r, 1.6 * r) * f), false, col)
	var centre: Vector2 = _isle(view, CuoiAtlas.PORTAL)
	var radius: float = 52.0 * s
	view.draw_texture_rect(_glow, Rect2((centre - Vector2(radius, radius / 1.25)) * f, Vector2(2.0 * radius, 2.0 * radius / 1.25) * f), false, Color(0.45, 0.62, 1.0, (0.1 + 0.08 * sin(TAU * t / 2.3)) * 1.6))


func draw_sky(view: Object, t: float) -> void :
	if not fx_on() or shown == "":
		return
	drew["sky"] = true
	_draw_petals(view, t, shown == "n", low())

func counts() -> Dictionary:
	return {"glints": _glints.size(), "petals": _petals.size()}


func _sea(view: Object) -> void :
	var wide: float = view._fw
	var high: float = view._fh
	var lo: bool = low()
	var key: String = "%d|%d|%.4f|%s|%s" % [roundi(wide), roundi(high), float(view._isle_s), view._isle_o, lo]
	if key == _sea_key:
		return
	_sea_key = key
	_glints.clear()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4242
	var want_glints: int = GLINTS_LOW if lo else GLINTS
	var pts: Array = CuoiAtlas.SEA_PTS
	for i in range(0, pts.size(), 3):
		var at: Vector2 = _isle(view, Vector2(float(pts[i]), float(pts[i + 1])))
		if at.x < 2.0 or at.y < 2.0 or at.x > wide - 2.0 or at.y > high - 2.0:
			continue
		_glints.append([at.x, at.y, int(pts[i + 2]), rng.randf_range(0.0, 3.0), rng.randf_range(2.2, 3.6), rng.randi_range(3, 7)])
		if _glints.size() >= want_glints:
			break


func _draw_lights(view: Object, fx: Texture2D, t: float) -> void :
	var f: float = view._f
	var s: float = view._isle_s
	var at: Transform2D = Transform2D(0.0, Vector2(s * f, s * f), 0.0, view._isle_o * f)
	var dim_on: bool = not low()
	for g in range(CuoiAtlas.LIGHT_GROUPS):
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
	var runs: Array = CuoiAtlas.LIGHT_RUNS_N[g][row]
	var cell: Vector2 = CuoiAtlas.LIGHT_CELL
	var tile: float = float(CuoiAtlas.LIGHT_TILE)
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


func _draw_petals(view: Object, t: float, night: bool, lo: bool) -> void :
	var tex: Texture2D = _tex(view, CuoiAtlas.FX[2])
	if tex == null:
		return
	var wide: float = view._fw
	var high: float = view._fh
	var key: String = "%s|%s|%d|%d" % [night, lo, roundi(wide), roundi(high)]
	if key != _petal_key:
		_petal_key = key
		_petals.clear()
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		rng.seed = 1411
		var area: float = clampf(wide * high / PETAL_AREA, 0.35, 2.5)
		var n: int = roundi(float(PETALS[2 if lo else (1 if night else 0)]) * area)
		for i in range(n):
			_petals.append([rng.randf(), rng.randf_range(-20.0, high), rng.randf_range(PETAL_FALL[0], PETAL_FALL[1]), 
				rng.randf_range(PETAL_SWAY[0], PETAL_SWAY[1]), rng.randf_range(3.5, 6.5), rng.randf_range(1.2, 2.6), 
				rng.randf_range(0.0, TAU), rng.randf_range(-1.2, 1.2), rng.randi_range(0, CuoiAtlas.PETAL.size() - 1), 
				rng.randf_range(PETAL_SIZE[0], PETAL_SIZE[1]), rng.randf_range(0.0, TAU)])
	var f: float = view._f
	var k: float = 0.62 if night else 1.0
	var tsz: Vector2 = Vector2(tex.get_width(), tex.get_height())
	for p: Array in _petals:
		var sway: float = sin(TAU * t / float(p[4]) + float(p[10]))
		var x: float = fposmod(float(p[0]) * wide + float(p[3]) * sway, wide)
		var y: float = fposmod(float(p[1]) + float(p[2]) * t, high + 24.0) - 12.0
		var rot: float = float(p[6]) + float(p[7]) * t + 0.5 * sway
		var flip: float = cos(TAU * t / float(p[5]) + float(p[6]))
		var cell: Array = CuoiAtlas.PETAL[int(p[8])]
		var half: Vector2 = Vector2(float(cell[2]), float(cell[3])) * 0.25 * float(p[9])
		var u: Vector2 = Vector2(cos(rot), sin(rot)) * half.x * maxf(0.18, absf(flip))
		var v: Vector2 = Vector2( - sin(rot), cos(rot)) * half.y
		var shade: float = k * (1.0 if flip >= 0.0 else 0.8)
		var col: Color = Color(shade, shade, shade, 0.92)
		var c: Vector2 = Vector2(x, y)
		var uv0: Vector2 = Vector2(float(cell[0]), float(cell[1])) / tsz
		var uv1: Vector2 = Vector2(float(cell[0]) + float(cell[2]), float(cell[1]) + float(cell[3])) / tsz
		view.draw_primitive(PackedVector2Array([(c - u - v) * f, (c + u - v) * f, (c + u + v) * f, (c - u + v) * f]), 
			PackedColorArray([col, col, col, col]), 
			PackedVector2Array([uv0, Vector2(uv1.x, uv0.y), uv1, Vector2(uv0.x, uv1.y)]), tex)
