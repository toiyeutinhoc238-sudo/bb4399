extends RefCounted




















const FEATHER_SIZE: float = 1.25
const CMP_EPSILON: float = 1e-05
const TANK_R: float = 37.0
const TANK_W: float = 3.0
const TANK_N: int = 65
const ARC_N: int = 72
const TANK_MARGIN: float = 48.0
const LOW: float = 128.0
const HIGH: float = 524288.0
const BUILD_US: int = 600
const SWEEP_EVERY: int = 120
const KEEP_FRAMES: int = 120
const X1: Vector2 = Vector2(1, 0)
const Y1: Vector2 = Vector2(0, 1)

static var enabled: bool = true

static var _f: PackedFloat32Array = PackedFloat32Array([0.0])
static var _idx: Dictionary = {}
static var _white: Dictionary = {}

var frame: int = -1
var _stamp: Array = []
var _spent: int = 0
var _swept: int = - SWEEP_EVERY
var _cls: Dictionary = {}
var _cols: Dictionary = {}
var _camp: Dictionary = {}
var tank_hits: int = 0
var tank_miss: int = 0
var camp_hits: int = 0
var camp_miss: int = 0
var builds: int = 0
var flushes: int = 0



func tick(f: int, stamp: Array) -> void :
	frame = f
	_spent = 0
	if stamp != _stamp:
		if not _stamp.is_empty():
			flushes += 1
		_stamp = stamp
		_cls.clear()
		_camp.clear()
	if f - _swept >= SWEEP_EVERY:
		_swept = f
		for key: Array in _camp.keys():
			if f - int(_camp[key][0]) > KEEP_FRAMES:
				_camp.erase(key)
		if _cols.size() > 64:
			_cols.clear()
		if _cls.size() > 256:
			_cls.clear()

func can_build() -> bool:
	return _spent < BUILD_US


func tank(ci: RID, pos: Vector2, color: Color) -> bool:
	var ax: int = axis(pos.x, TANK_MARGIN)
	var ay: int = axis(pos.y, TANK_MARGIN)
	if ax < 0 or ay < 0:
		tank_miss += 1
		return false
	var k: int = (ax << 24) | ay
	var local: Variant = _cls.get(k)
	if local == null:
		if _spent >= BUILD_US:
			tank_miss += 1
			return false
		var t0: int = Time.get_ticks_usec()
		local = tank_local(ax, ay)
		_cls[k] = local
		builds += 1
		_spent += Time.get_ticks_usec() - t0
	var cols: Variant = _cols.get(color)
	if cols == null:
		cols = ring_colors(color, TANK_N)
		_cols[color] = cols
	RenderingServer.canvas_item_add_triangle_array(ci, indices(TANK_N), Transform2D(X1, Y1, pos) * (local as PackedVector2Array), cols)
	tank_hits += 1
	return true


func camp(ci: RID, key: Array) -> bool:
	var e: Variant = _camp.get(key)
	if e == null:
		return false
	e[0] = frame
	for mc: Array in e[1]:
		RenderingServer.canvas_item_add_mesh(ci, mc[1], Transform2D.IDENTITY, mc[2])
	camp_hits += 1
	return true


func camp_build(ci: RID, key: Array, pos: Vector2, arcs: Array) -> bool:
	var t0: int = Time.get_ticks_usec()
	var meshes: Array = []
	for arc: Array in arcs:
		var g: Array = polyline_aa(arc_points(pos, float(arc[0]), 0.0, TAU, ARC_N), arc[1], 1.0)
		if g.is_empty():
			camp_miss += 1
			_spent += Time.get_ticks_usec() - t0
			return false
		var m: ArrayMesh = mesh(g[0], ARC_N)
		meshes.append([m, m.get_rid(), arc[1]])
	_camp[key] = [frame, meshes]
	builds += 1
	_spent += Time.get_ticks_usec() - t0
	return camp(ci, key)

func camp_count() -> int:
	return _camp.size()

func class_count() -> int:
	return _cls.size()


static func axis(x: float, margin: float) -> int:
	if not (x >= LOW and x < HIGH):
		return -1
	var hi: int = nearest_po2(int(x))
	if float(hi) <= x:
		hi <<= 1
	var lo: int = hi >> 1
	if x - margin < lo or x + margin >= hi:
		return -1
	return (lo << 1) | (int(x * (8388608.0 / lo)) & 1)


static func axis_ref(a: int) -> float:
	var lo: int = a >> 1
	return 1.5 * lo + (a & 1) * (lo / 8388608.0)


static func tank_local(ax: int, ay: int) -> PackedVector2Array:
	var ref: Vector2 = Vector2(axis_ref(ax), axis_ref(ay))
	var g: Array = polyline_aa(circle_points(ref, TANK_R), Color.WHITE, TANK_W)
	return Transform2D(X1, Y1, - ref) * (g[0] as PackedVector2Array)

static func f32(x: float) -> float:
	_f[0] = x
	return _f[0]


static func aa_width(w: float) -> float:
	if w > 0.0:
		if w <= FEATHER_SIZE * 2.0 + CMP_EPSILON:
			return f32(w * 0.5)
		elif w <= FEATHER_SIZE * 4.0 + CMP_EPSILON:

			var os: float = f32(w * 0.5)
			var oe: float = f32(w - f32(FEATHER_SIZE * 0.5))
			var t: float = f32(f32(w - FEATHER_SIZE * 2.0) / f32(FEATHER_SIZE * 4.0 - FEATHER_SIZE * 2.0))
			return f32(os + f32(f32(oe - os) * t))
		else:
			return f32(w - f32(FEATHER_SIZE * 0.5))
	return w


static func circle_points(pos: Vector2, r: float) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	pts.resize(65)
	var step: float = f32(TAU / 64.0)
	var rf: float = f32(r)
	for i in 64:
		var a: float = f32(i * step)
		pts[i] = Vector2.from_angle(a) * rf + pos
	pts[64] = pts[0]
	return pts


static func arc_points(center: Vector2, r: float, start: float, end: float, count: int) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	pts.resize(count)
	var s: float = f32(start)
	var d: float = f32(f32(end) - s)
	d = f32(clampf(d, - TAU, TAU))
	var rf: float = f32(r)
	var den: float = f32(count - 1.0)
	for i in count:
		var th: float = f32(f32(f32(i / den) * d) + s)
		pts[i] = center + Vector2.from_angle(th) * rf
	return pts

static func _seg_dir(p: PackedVector2Array, i: int, prev: Vector2) -> Vector2:
	if i == p.size() - 1:
		return prev
	var d: Vector2 = (p[i + 1] - p[i]).normalized()
	if d.is_zero_approx():
		return prev
	return d

static func _edge_offset(seg: Vector2, prev: Vector2) -> Vector2:
	var length: float = 1.0
	var bis: Vector2 = (prev * seg.length() - seg * prev.length()).normalized()
	var ang: float = Vector2(bis.dot(prev), bis.cross(prev)).angle()
	var s: float = Vector2.from_angle(ang).y
	if not (absf(s) < f32(CMP_EPSILON)) and not seg.is_equal_approx(prev):
		length = f32(1.0 / s)
		length = clampf(length, -3.0, 3.0)
	else:
		bis = seg.orthogonal()
	if bis.is_zero_approx():
		bis = seg.orthogonal()
	return bis * length


static func polyline_aa(p: PackedVector2Array, color: Color, width: float) -> Array:
	var n: int = p.size()
	if n < 3:
		return []
	var w: float = aa_width(f32(width))
	if w < 0.0:
		return []
	if not p[0].is_equal_approx(p[n - 1]):
		return []
	var first: Vector2 = Vector2.ZERO
	var last: Vector2 = Vector2.ZERO
	for i in range(1, n):
		first = (p[i] - p[i - 1]).normalized()
		if not first.is_zero_approx():
			break
	for i in range(n - 1, 0, -1):
		last = (p[i] - p[i - 1]).normalized()
		if not last.is_zero_approx():
			break
	var border_size: float = FEATHER_SIZE
	if w < 1.0:
		border_size = f32(border_size * w)
	var half: float = f32(w * 0.5)
	var m: int = n * 2
	var verts: PackedVector2Array = PackedVector2Array()
	verts.resize(m * 3)
	var prev: Vector2 = Vector2.ZERO
	for i in n:
		var seg: Vector2 = _seg_dir(p, i, prev)
		if i == 0:
			prev = last
		elif i == n - 1:
			prev = first
		var base: Vector2 = _edge_offset(seg, prev)
		var edge: Vector2 = base * half
		var border: Vector2 = base * border_size
		var pos: Vector2 = p[i]
		var j: int = i * 2
		var a: Vector2 = pos + edge
		var b: Vector2 = pos - edge
		verts[j] = a
		verts[j + 1] = b
		verts[m + j] = a
		verts[m + j + 1] = a + border
		verts[2 * m + j] = b
		verts[2 * m + j + 1] = b - border
		prev = seg
	return [verts, ring_colors(color, n)]


static func ring_colors(color: Color, n: int) -> PackedColorArray:
	var m: int = n * 2
	var cols: PackedColorArray = PackedColorArray()
	cols.resize(m * 3)
	cols.fill(color)
	var c2: Color = Color(color.r, color.g, color.b, 0)
	for j in range(m + 1, m * 3, 2):
		cols[j] = c2
	return cols


static func mesh(verts: PackedVector2Array, n: int) -> ArrayMesh:
	var white: Variant = _white.get(n)
	if white == null:
		white = ring_colors(Color.WHITE, n)
		_white[n] = white
	var arr: Array = []
	arr.resize(Mesh.ARRAY_MAX)
	arr[Mesh.ARRAY_VERTEX] = verts
	arr[Mesh.ARRAY_COLOR] = white
	arr[Mesh.ARRAY_INDEX] = indices(n)
	var m: ArrayMesh = ArrayMesh.new()
	m.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arr, [], {}, Mesh.ARRAY_FLAG_USE_2D_VERTICES)
	return m


static func indices(n: int) -> PackedInt32Array:
	var got: Variant = _idx.get(n)
	if got != null:
		return got
	var m: int = n * 2
	var out: PackedInt32Array = PackedInt32Array()
	out.resize(3 * (m - 2) * 3)
	var w: int = 0
	for s in 3:
		var o: int = s * m
		for k in range(m - 2):
			if k % 2 == 0:
				out[w] = o + k
				out[w + 1] = o + k + 1
			else:
				out[w] = o + k + 1
				out[w + 1] = o + k
			out[w + 2] = o + k + 2
			w += 3
	_idx[n] = out
	return out
