extends RefCounted








const Settings = preload("res://settings.gd")
const IsleAtlas = preload("island_atlas.gd")
const NoelAtlas = preload("island_noel_atlas.gd")

const VN: int = 25200
const MODES: Array[String] = ["auto", "day", "night"]
const RECHECK_MS: int = 60000
const FADE: float = 1.0
const NOEL_TEST: bool = false

static var force_season: int = -1
static var now_override: int = -1


const SNOW: Array = [[1.0, 0.55, 16.0, 6.0, 260], [1.6, 0.75, 34.0, 10.0, 130], [2.8, 0.9, 70.0, 16.0, 45]]
const SNOW_LOW: Array = [[1.3, 0.65, 28.0, 8.0, 90]]
const SNOW_DAY: float = 0.6
const SNOW_AREA: float = 1366.0 * 768.0
const LIGHT_PERIOD: Array = [1.3, 1.75, 2.2]
const LIGHT_PHASE: Array = [0.0, 0.37, 0.71]
const GLOW_COL: Color = Color8(255, 214, 120)
const TREE_STAR: Vector2 = Vector2(463, 351)
const PORTAL: Vector2 = Vector2(786, 398)
const CHIMNEY: Vector2 = Vector2(247, 274)
const GLINTS: int = 140
const GLINTS_LOW: int = 50
const SEA_STARS: int = 22
const PUFFS: int = 14
const SLEIGH_CROSS: float = 8.0
const SLEIGH_GAP: Array = [30.0, 60.0]
const SLEIGH_FIRST: float = 6.0
const SLEIGH_W: float = 120.0

var season: bool = false
var auto_night: bool = false
var shown: String = ""
var _due: int = -1
var _fade_from: String = ""
var _fade_at: float = -1.0
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _flakes: Array = []
var _flake_key: String = ""
var _glints: Array = []
var _stars: Array = []
var _sea_key: String = ""
var _puffs: Array = []
var _sleigh_at: float = -1.0
var _meshes: Dictionary = {}

var drew: Dictionary = {}
var _dot: Texture2D
var _snow: Texture2D
var _line: Texture2D
var _col: Texture2D
var _glow: Texture2D

func _init() -> void :
	_rng.seed = 20261224
	_dot = _radial([[0.0, 1.0], [0.55, 0.8], [1.0, 0.0]])
	_snow = _radial([[0.0, 1.0], [0.5, 1.0], [0.56, 0.16], [1.0, 0.0]])
	_glow = _radial([[0.0, 1.0], [0.3, 0.83], [0.5, 0.56], [0.7, 0.26], [0.85, 0.08], [1.0, 0.0]])
	_line = _linear(Vector2(1, 0))
	_col = _linear(Vector2(0, 1))
	for i in range(PUFFS):
		_puffs.append([i * 0.55, _rng.randi_range(0, NoelAtlas.SMOKE.size() - 1), _rng.randf_range(-3.0, 3.0)])

static func _radial(stops: Array) -> Texture2D:
	var grad: Gradient = Gradient.new()
	grad.offsets = PackedFloat32Array(stops.map( func(s: Array) -> float: return float(s[0])))
	grad.colors = PackedColorArray(stops.map( func(s: Array) -> Color: return Color(1, 1, 1, float(s[1]))))
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(1.0, 0.5)
	tex.width = 32
	tex.height = 32
	return tex


static func _linear(axis: Vector2) -> Texture2D:
	var grad: Gradient = Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	grad.colors = PackedColorArray([Color(1, 1, 1, 0), Color(1, 1, 1, 1), Color(1, 1, 1, 0)])
	var tex: GradientTexture2D = GradientTexture2D.new()
	tex.gradient = grad
	tex.fill_from = Vector2.ZERO
	tex.fill_to = axis
	tex.width = 32 if axis.x > 0 else 4
	tex.height = 4 if axis.x > 0 else 32
	return tex


static func now() -> int:
	return now_override if now_override >= 0 else int(Time.get_unix_time_from_system())


static func in_season(unix: int) -> bool:
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(unix + VN)
	var m: int = int(d["month"])
	var day: int = int(d["day"])
	return (m == 10 and day >= 24) or m == 11 or m == 12 or (m == 1 and day <= 5)


static func night_at(unix: int) -> bool:
	var hour: int = int(Time.get_datetime_dict_from_unix_time(unix + VN)["hour"])
	return hour < 6 or hour >= 18

static func mode_setting() -> String:
	var mode: String = str(Settings.value("lobby_daynight"))
	return mode if MODES.has(mode) else "auto"

static func fx_on() -> bool:
	return Settings.on("lobby_fx")


static func low() -> bool:
	var quality: int = int(Settings.value("quality"))
	return quality == 2 or (quality == 0 and Settings.drop >= 2)


func refresh(force: bool = false) -> void :
	var tick: int = Time.get_ticks_msec()
	if not force and _due >= 0 and tick < _due:
		return
	_due = tick + RECHECK_MS
	var unix: int = now()
	season = NOEL_TEST or in_season(unix) if force_season < 0 else force_season == 1
	auto_night = night_at(unix)


func want() -> String:
	var mode: String = mode_setting()
	if mode == "night" or (mode == "auto" and auto_night):
		return "n"
	return "d"



func files() -> Array:
	if not season:
		return IsleAtlas.FILES
	return NoelAtlas.SHARED + NoelAtlas.DAY + NoelAtlas.NIGHT + NoelAtlas.FX


func need(m: String) -> Array:
	if not season:
		return IsleAtlas.FILES
	return NoelAtlas.SHARED + (NoelAtlas.NIGHT if m == "n" else NoelAtlas.DAY)


func file(name: String, m: String) -> String:
	if season and not NoelAtlas.SHARED.has(name + ".webp"):
		return NoelAtlas.SUB + m + "_" + name + ".webp"
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


func draw_ground(view: Object, t: float) -> void :
	if not season or not fx_on() or shown == "":
		return
	var night: bool = shown == "n"
	drew["ground"] = true
	var f: float = view._f
	var fx: Texture2D = _tex(view, NoelAtlas.FX[1] if night else NoelAtlas.FX[0])
	if fx != null:
		_draw_flags(view, fx, t)
		_draw_lights(view, fx, t, night)
	var pul: float = 0.5 + 0.5 * sin(TAU * t / 1.4)
	_star4(view, _isle(view, TREE_STAR), 5.0 + 3.0 * pul, 0.55 + 0.35 * pul, Color8(255, 236, 150))
	if night:
		var centre: Vector2 = _isle(view, PORTAL)
		var radius: float = 52.0 * float(view._isle_s)
		var a: float = (0.1 + 0.08 * sin(TAU * t / 2.3)) * 1.6
		view.draw_texture_rect(_glow, Rect2((centre - Vector2(radius, radius / 1.25)) * f, Vector2(2.0 * radius, 2.0 * radius / 1.25) * f), false, Color(0.45, 0.62, 1.0, a))
	_sea(view)
	var gl_a: float = 0.45 if night else 0.55
	for g: Array in _glints:
		var ph: float = fposmod((t - float(g[3])) / float(g[4]), 1.0)
		if ph > 0.45:
			continue
		var a: float = sin(ph / 0.45 * PI) * gl_a
		var col: Color = (Color8(255, 214, 140) if int(g[2]) == 1 else Color8(232, 228, 214)) if night else Color.WHITE
		col.a = a
		var span: float = float(g[5]) + 1.0
		view.draw_texture_rect(_line, Rect2(Vector2(float(g[0]) - span, float(g[1])) * f, Vector2(2.0 * span, 1.0) * f), false, col)
	if night:
		var many: Array = []
		for s: Array in _stars:
			var v: float = 0.5 + 0.5 * sin(TAU * (t / float(s[3]) + float(s[2])))
			many.append([Vector2(float(s[0]), float(s[1])), float(s[4]) * (0.6 + 0.4 * v), 0.25 + 0.6 * v * v])
		_stars4(view, many, Color8(255, 246, 220))
	_draw_smoke(view, t, night)


func draw_sky(view: Object, t: float) -> void :
	if not season or not fx_on() or shown == "":
		return
	var night: bool = shown == "n"
	var lo: bool = low()
	var f: float = view._f
	var wide: float = view._fw
	var high: float = view._fh
	drew["snow"] = true
	if night and not lo:
		_draw_sleigh(view, t, wide)
	var key: String = "%s|%s|%d|%d" % [shown, lo, roundi(wide), roundi(high)]
	if key != _flake_key:
		_flake_key = key
		_make_snow(wide, high, night, lo)
	var col: Color = Color8(246, 242, 234) if night else Color.WHITE
	for layer: Array in _flakes:
		var r: float = float(layer[0])
		var half: float = r * 2.2 + 0.5
		col.a = float(layer[1])
		var sway: float = float(layer[2])
		var xs: PackedFloat32Array = layer[3]
		var ys: PackedFloat32Array = layer[4]
		var vs: PackedFloat32Array = layer[5]
		var phs: PackedFloat32Array = layer[6]
		var pws: PackedFloat32Array = layer[7]
		var dim: Vector2 = Vector2(2.0 * half, 2.0 * half) * f
		for i in range(xs.size()):
			var x: float = fposmod(xs[i] * wide + sway * sin(TAU * t / pws[i] + phs[i]), wide)
			var y: float = fposmod(ys[i] + vs[i] * t, high + 20.0) - 10.0
			view.draw_texture_rect(_snow, Rect2(Vector2(x - half, y - half) * f, dim), false, col)


func counts() -> Dictionary:
	var snow: int = 0
	for layer: Array in _flakes:
		snow += (layer[3] as PackedFloat32Array).size()
	return {"layers": _flakes.size(), "snow": snow, "glints": _glints.size(), "stars": _stars.size(), "sleigh": _sleigh_at}

func _make_snow(wide: float, high: float, night: bool, lo: bool) -> void :
	_flakes.clear()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 7151
	var area: float = clampf(wide * high / SNOW_AREA, 0.35, 2.5)
	for layer: Array in (SNOW_LOW if lo else SNOW):
		var n: int = roundi(float(layer[4]) * area * (1.0 if night else SNOW_DAY))
		var xs: PackedFloat32Array = PackedFloat32Array()
		var ys: PackedFloat32Array = PackedFloat32Array()
		var vs: PackedFloat32Array = PackedFloat32Array()
		var phs: PackedFloat32Array = PackedFloat32Array()
		var pws: PackedFloat32Array = PackedFloat32Array()
		for i in range(n):
			xs.append(rng.randf())
			ys.append(rng.randf_range(-20.0, high))
			vs.append(float(layer[2]) * rng.randf_range(0.8, 1.2))
			phs.append(rng.randf_range(0.0, TAU))
			pws.append(rng.randf_range(2.5, 5.5))
		_flakes.append([float(layer[0]), float(layer[1]), float(layer[3]), xs, ys, vs, phs, pws])


func _sea(view: Object) -> void :
	var wide: float = view._fw
	var high: float = view._fh
	var lo: bool = low()
	var key: String = "%d|%d|%.4f|%s|%s" % [roundi(wide), roundi(high), float(view._isle_s), view._isle_o, lo]
	if key == _sea_key:
		return
	_sea_key = key
	_glints.clear()
	_stars.clear()
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 4242
	var want_glints: int = GLINTS_LOW if lo else GLINTS
	var pts: Array = NoelAtlas.SEA_PTS
	for i in range(0, pts.size(), 3):
		var at: Vector2 = _isle(view, Vector2(float(pts[i]), float(pts[i + 1])))
		if at.x < 2.0 or at.y < 2.0 or at.x > wide - 2.0 or at.y > high - 2.0:
			continue
		if _glints.size() < want_glints:
			_glints.append([at.x, at.y, int(pts[i + 2]), rng.randf_range(0.0, 3.0), rng.randf_range(2.2, 3.6), rng.randi_range(3, 7)])
		elif _stars.size() < SEA_STARS and int(pts[i + 2]) == 0 and at.y < high * 0.92:
			_stars.append([at.x, at.y, rng.randf(), rng.randf_range(1.6, 3.2), rng.randf_range(3.0, 6.5)])
		if _glints.size() >= want_glints and _stars.size() >= SEA_STARS:
			break

static func _isle(view: Object, at: Vector2) -> Vector2:
	return view._isle_o + at * float(view._isle_s)


func _star4(view: Object, at: Vector2, size: float, a: float, col: Color) -> void :
	var f: float = view._f
	col.a = a
	view.draw_texture_rect(_line, Rect2(Vector2(at.x - 2.0 * size, at.y - 0.9) * f, Vector2(4.0 * size, 1.8) * f), false, col)
	view.draw_texture_rect(_col, Rect2(Vector2(at.x - 0.9, at.y - 2.0 * size) * f, Vector2(1.8, 4.0 * size) * f), false, col)
	view.draw_texture_rect(_dot, Rect2((at - Vector2(0.6, 0.6) * size) * f, Vector2(1.2, 1.2) * size * f), false, col)


func _stars4(view: Object, items: Array, col: Color) -> void :
	var f: float = view._f
	for pass_i in range(3):
		var tex: Texture2D = _line if pass_i == 0 else (_col if pass_i == 1 else _dot)
		for it: Array in items:
			var at: Vector2 = it[0]
			var size: float = it[1]
			col.a = it[2]
			var r: Rect2
			if pass_i == 0:
				r = Rect2(Vector2(at.x - 2.0 * size, at.y - 0.9) * f, Vector2(4.0 * size, 1.8) * f)
			elif pass_i == 1:
				r = Rect2(Vector2(at.x - 0.9, at.y - 2.0 * size) * f, Vector2(1.8, 4.0 * size) * f)
			else:
				r = Rect2((at - Vector2(0.6, 0.6) * size) * f, Vector2(1.2, 1.2) * size * f)
			view.draw_texture_rect(tex, r, false, col)


func _draw_flags(view: Object, fx: Texture2D, t: float) -> void :
	var box: Rect2 = NoelAtlas.FLAG_BOX
	var step: float = 5.0
	var x: float = 0.0
	while x < box.size.x:
		var w: float = minf(step, box.size.x - x)
		var dx: float = sin(TAU * t / 1.7 + 0.21 * (box.position.x + x))
		var src: Rect2 = Rect2(NoelAtlas.FLAG_AT + Vector2(x, 0), Vector2(w, box.size.y))
		view.draw_texture_rect_region(fx, view._isle_rect(box.position + Vector2(x + dx, 0), Vector2(w, box.size.y)), src)
		x += step



func _draw_lights(view: Object, fx: Texture2D, t: float, night: bool) -> void :
	var f: float = view._f
	var s: float = view._isle_s
	var at: Transform2D = Transform2D(0.0, Vector2(s * f, s * f), 0.0, view._isle_o * f)
	var m: String = "n" if night else "d"
	var dim_on: bool = not (night and low())
	for g in range(NoelAtlas.LIGHT_GROUPS):
		var b: float = clampf((0.5 + 0.5 * sin(TAU * (t / float(LIGHT_PERIOD[g]) + float(LIGHT_PHASE[g]))) - 0.25) * 1.6, 0.0, 1.0)
		if b < 1.0 and dim_on:
			drew["dim"] = true
			view.draw_mesh(_light_mesh(m, g, 0, fx), fx, at, Color(0, 0, 0, 1.0 - b))
		if b > 0.0:
			var col: Color = GLOW_COL
			col.a = b
			view.draw_mesh(_light_mesh(m, g, 1, fx), fx, at, col)


func _light_mesh(m: String, g: int, row: int, fx: Texture2D) -> ArrayMesh:
	var key: String = "%s|%d|%d|%d" % [m, g, row, fx.get_instance_id()]
	if _meshes.has(key):
		return _meshes[key]
	var runs: Array = (NoelAtlas.LIGHT_RUNS_N if m == "n" else NoelAtlas.LIGHT_RUNS_D)[g][row]
	var cell: Vector2 = NoelAtlas.LIGHT_CELL
	var tile: float = float(NoelAtlas.LIGHT_TILE)
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
	if _meshes.size() > 24:
		_meshes.clear()
	_meshes[key] = mesh
	return mesh


func _draw_smoke(view: Object, t: float, night: bool) -> void :
	var sheet: Texture2D = _tex(view, NoelAtlas.FX[2])
	if sheet == null:
		return
	var f: float = view._f
	var s: float = view._isle_s
	var chim: Vector2 = _isle(view, CHIMNEY)
	var tint: Color = Color(0.8, 0.78, 0.8) if night else Color.WHITE
	for p: Array in _puffs:
		var age: float = fposmod(t - float(p[0]), 7.7)
		if age > 5.5:
			continue
		var u: float = age / 5.5
		var cell: Array = NoelAtlas.SMOKE[int(p[1])]
		var k: float = (0.05 + 0.1 * u) * s
		var dim: Vector2 = Vector2(float(cell[4]), float(cell[5])) * k
		var centre: Vector2 = Vector2(chim.x + float(p[2]) + 14.0 * u + 4.0 * sin(age * 1.3), chim.y - 70.0 * u * s)
		tint.a = minf(1.0, age / 0.5) * pow(1.0 - u, 1.3) * (0.55 if night else 0.75)
		view.draw_texture_rect_region(sheet, Rect2((centre - dim / 2.0) * f, dim * f), Rect2(float(cell[0]), float(cell[1]), float(cell[2]), float(cell[3])), tint)


func _draw_sleigh(view: Object, t: float, wide: float) -> void :
	var sheet: Texture2D = _tex(view, NoelAtlas.FX[3])
	if sheet == null:
		return
	if _sleigh_at < 0.0 or t < _sleigh_at - SLEIGH_GAP[1] - 1.0:
		_sleigh_at = t + SLEIGH_FIRST
	if t > _sleigh_at + SLEIGH_CROSS:
		_sleigh_at = t + _rng.randf_range(float(SLEIGH_GAP[0]), float(SLEIGH_GAP[1]))
	if t < _sleigh_at:
		return
	var u: float = (t - _sleigh_at) / SLEIGH_CROSS
	drew["sleigh"] = true
	var sx: float = -180.0 + (wide + 360.0) * u
	var sy: float = 120.0 - 60.0 * sin(u * PI) + 4.0 * sin(t * 6.0)
	var trail: Array = []
	for j in range(16):
		var tx: float = sx - 50.0 - j * 9.0
		if tx >= 0.0 and tx < wide:
			trail.append([Vector2(tx, sy + 8.0 + j * 1.2 + 2.0 * sin(t * 9.0 + j)), 2.6 - j * 0.12, 0.85 * (1.0 - j / 16.0)])
	_stars4(view, trail, Color8(255, 222, 130))
	var fr: Array = NoelAtlas.SLEIGH[int(t * 8.0) % NoelAtlas.SLEIGH.size()]
	var dim: Vector2 = Vector2(SLEIGH_W, SLEIGH_W * float(fr[3]) / float(fr[2]))
	var f: float = view._f
	view.draw_texture_rect_region(sheet, Rect2((Vector2(sx, sy) - dim / 2.0) * f, dim * f), Rect2(float(fr[0]), float(fr[1]), float(fr[2]), float(fr[3])))
