extends Node2D











const TouchGfx = preload("../battle/touch_gfx.gd")

signal event(name: String)

const NORMAL: int = 0
const ADD: int = 1
const OVERLAY: int = 2
const TAP_CAP_1D: int = 12
const TAP_CAP_2D: int = 6
const MAX_CATCHUP: int = 4

const SHADER: String = "shader_type canvas_item;\nrender_mode %s;\nuniform vec4 mul = vec4(1.0);\nuniform vec4 add = vec4(0.0);\nuniform vec4 imul = vec4(1.0);\nuniform vec4 iadd = vec4(0.0);\nuniform int fx = 0;\nuniform int cm = 0;\nuniform vec4 cr = vec4(1.0, 0.0, 0.0, 0.0);\nuniform vec4 cg = vec4(0.0, 1.0, 0.0, 0.0);\nuniform vec4 cb = vec4(0.0, 0.0, 1.0, 0.0);\nuniform vec4 ca = vec4(0.0, 0.0, 0.0, 1.0);\nuniform vec4 cmo = vec4(0.0);\nuniform vec2 step_uv = vec2(0.0);\nuniform ivec2 taps = ivec2(0);\nuniform vec2 sig = vec2(0.0);\nuniform vec4 gcol = vec4(1.0);\nuniform float gstr = 1.0;\nuniform vec4 uvr = vec4(-9.0, -9.0, 9.0, 9.0);\n%s\nvec4 cmx(vec4 c) {\n\treturn clamp(vec4(dot(cr, c), dot(cg, c), dot(cb, c), dot(ca, c)) + cmo, 0.0, 1.0);\n}\n\n// TEXTURE không truyền được vào hàm tự viết (shader_compiler: custom_samplers) → lấy mẫu ở fragment() rồi đưa giá trị vào.\nvec4 grab(vec4 raw, vec2 uv) {\n\tif (uv.x < uvr.x || uv.y < uvr.y || uv.x > uvr.z || uv.y > uvr.w) {\n\t\treturn vec4(0.0);\n\t}\n\tvec4 c = clamp(raw * imul + iadd, 0.0, 1.0);\n\tif (cm == 1) {\n\t\tc = cmx(c);\n\t}\n\treturn c;\n}\n\nvoid fragment() {\n\tvec4 s = grab(texture(TEXTURE, UV), UV);\n\tvec4 c = s;\n\tif (fx != 0) {\n\t\tvec4 acc = vec4(0.0);\n\t\tfloat wsum = 0.0;\n\t\tfor (int j = -taps.y; j <= taps.y; j++) {\n\t\t\tfor (int i = -taps.x; i <= taps.x; i++) {\n\t\t\t\tvec2 o = vec2(float(i), float(j));\n\t\t\t\tfloat w = 1.0;\n\t\t\t\tif (sig.x > 0.0) {\n\t\t\t\t\tw *= exp(-o.x * o.x / (2.0 * sig.x * sig.x));\n\t\t\t\t}\n\t\t\t\tif (sig.y > 0.0) {\n\t\t\t\t\tw *= exp(-o.y * o.y / (2.0 * sig.y * sig.y));\n\t\t\t\t}\n\t\t\t\tvec2 qu = UV + o * step_uv;\n\t\t\t\tvec4 q = grab(texture(TEXTURE, qu), qu);\n\t\t\t\tacc += vec4(q.rgb * q.a, q.a) * w;\n\t\t\t\twsum += w;\n\t\t\t}\n\t\t}\n\t\tacc /= max(wsum, 0.00001);\n\t\tif (fx == 1) {\n\t\t\tfloat ga = clamp(acc.a * gstr, 0.0, 1.0) * gcol.a;\n\t\t\tfloat oa = s.a + ga * (1.0 - s.a);\n\t\t\tc = vec4((s.rgb * s.a + gcol.rgb * ga * (1.0 - s.a)) / max(oa, 0.00001), oa);\n\t\t} else {\n\t\t\tc = vec4(acc.rgb / max(acc.a, 0.00001), acc.a);\n\t\t}\n\t}\n\tif (cm == 2) {\n\t\tc = cmx(c);\n\t}\n\tc = clamp(c * mul + add, 0.0, 1.0);\n\t%s\n\tCOLOR = c;\n}\n"










































































const OVERLAY_DECL: String = "uniform sampler2D scr : hint_screen_texture, filter_nearest;"
const OVERLAY_CODE: String = "vec3 b = texture(scr, SCREEN_UV).rgb; c.rgb = mix(2.0 * b * c.rgb, vec3(1.0) - 2.0 * (vec3(1.0) - b) * (vec3(1.0) - c.rgb), step(vec3(0.5), b));"

static var _shaders: Array = []

var attach: Dictionary = {}
var named: Dictionary = {}
var leaves: int = 0
var _clips: Array = []
var _clock: float = 0.0
var _dirty: bool = true
var _pool: Array = []
var _attach_sig: Array = []


static func valid(doc: Variant) -> bool:
	if not doc is Dictionary:
		return false
	for key: String in ["pages", "sizes", "shapes", "sprites", "frames", "fl"]:
		if not doc.has(key):
			return false
	return doc.frames is Array and not doc.frames.is_empty() and doc.pages is Array and doc.sizes is Array\
	and doc.pages.size() == doc.sizes.size()


func add_clip(effect: Dictionary, label: String = "", at: Transform2D = Transform2D.IDENTITY) -> int:
	var doc: Variant = effect.get("data")
	var pages: Variant = effect.get("pages")
	if not valid(doc) or not pages is Array or pages.size() != doc.pages.size():
		return -1
	for texture: Variant in pages:
		if not texture is Texture2D:
			return -1
	var clip: Dictionary = {"doc": doc, "pages": pages, "at": at, "root": {}}
	clip.root = _make(clip, -1, 0)
	_enter(clip, clip.root, false)
	if not label.is_empty():
		goto_label(_clips.size(), label, clip)
	_clips.append(clip)
	_dirty = true
	return _clips.size() - 1

func clips() -> int:
	return _clips.size()


func frame(index: int = 0) -> int:
	return int(_clips[index].root.f) if index < _clips.size() else -1

func playing(index: int = 0) -> bool:
	return index < _clips.size() and bool(_clips[index].root.play)


func goto_label(index: int, label: String, clip: Dictionary = {}) -> bool:
	if clip.is_empty():
		if index >= _clips.size():
			return false
		clip = _clips[index]
	var labels: Dictionary = clip.doc.get("labels", {})
	if not labels.has(label):
		return false
	_goto(clip, clip.root, int(labels[label]))
	clip.root.play = true
	_enter(clip, clip.root, index == 0 and not _clips.is_empty())
	_dirty = true
	return true

func _process(delta: float) -> void :
	if _clips.is_empty() or not is_visible_in_tree():
		return
	advance(delta)
	if _dirty:
		render()


func advance(delta: float) -> void :
	if _clips.is_empty():
		return
	var fps: float = maxf(1.0, float(_clips[0].doc.get("fps", 24.0)))
	_clock += delta
	var steps: int = 0
	while _clock >= 1.0 / fps:
		_clock -= 1.0 / fps
		steps += 1
		if steps > MAX_CATCHUP:
			_clock = 0.0
			break
		step()


func step() -> void :
	for index in range(_clips.size()):
		var clip: Dictionary = _clips[index]
		_advance(clip, clip.root, index == 0)
	_dirty = true



func _make(clip: Dictionary, char_id: int, placed: int) -> Dictionary:
	var inst: Dictionary = {"c": char_id, "pf": placed, "m": Transform2D.IDENTITY, "mul": Color(1, 1, 1, 1), "add": Color(0, 0, 0, 0), 
		"bl": 0, "fl": -1, "n": "", "hide": false, "f": 0, "play": true, "kids": {}}
	var frames: Array = _frames(clip, char_id)
	if not frames.is_empty():
		for op: Dictionary in frames[0]:
			_apply(clip, inst, op, 0)
	return inst


static func _frames(clip: Dictionary, char_id: int) -> Array:
	if char_id < 0:
		return clip.doc.frames
	var sprite: Variant = clip.doc.sprites.get(str(char_id))
	return sprite if sprite is Array else []

static func _key(char_id: int) -> String:
	return "main" if char_id < 0 else str(char_id)

func _apply(clip: Dictionary, inst: Dictionary, op: Dictionary, at: int) -> void :
	var depth: int = int(op.get("d", 0))
	if op.has("x"):
		inst.kids.erase(depth)
		return
	var cur: Variant = inst.kids.get(depth)
	if op.has("c"):
		var char_id: int = int(op.c)
		if cur == null or not op.has("mv"):
			cur = _make(clip, char_id, at)
			inst.kids[depth] = cur
		elif int(cur.c) != char_id:
			var fresh: Dictionary = _make(clip, char_id, at)
			for key: String in ["m", "mul", "add", "bl", "fl", "n", "hide"]:
				fresh[key] = cur[key]
			cur = fresh
			inst.kids[depth] = cur
	if cur == null:
		return
	_props(cur, op)

static func _props(rec: Dictionary, op: Dictionary) -> void :
	if op.has("m"):
		var m: Array = op.m
		rec.m = Transform2D(Vector2(float(m[0]), float(m[1])), Vector2(float(m[2]), float(m[3])), Vector2(float(m[4]), float(m[5])))
	if op.has("cx"):
		var cx: Array = op.cx
		rec.mul = Color(float(cx[0]), float(cx[1]), float(cx[2]), float(cx[3]))
		rec.add = Color(float(cx[4]) / 255.0, float(cx[5]) / 255.0, float(cx[6]) / 255.0, float(cx[7]) / 255.0)
	if op.has("bl"):
		rec.bl = int(op.bl)
	if op.has("f"):
		rec.fl = int(op.f)
	if op.has("n"):
		rec.n = str(op.n)
	if op.has("hide"):
		rec.hide = bool(op.hide)



func _goto(clip: Dictionary, inst: Dictionary, target: int) -> void :
	var frames: Array = _frames(clip, int(inst.c))
	target = clampi(target, 0, frames.size() - 1)
	var recs: Dictionary = {}
	for index in range(target + 1):
		for op: Dictionary in frames[index]:
			var depth: int = int(op.get("d", 0))
			if op.has("x"):
				recs.erase(depth)
				continue
			var rec: Variant = recs.get(depth)
			if op.has("c"):
				if rec == null or not op.has("mv"):
					rec = {"c": int(op.c), "pf": index, "m": Transform2D.IDENTITY, "mul": Color(1, 1, 1, 1), "add": Color(0, 0, 0, 0), 
						"bl": 0, "fl": -1, "n": "", "hide": false}
					recs[depth] = rec
				elif int(rec.c) != int(op.c):
					rec.c = int(op.c)
					rec.pf = index
			if rec != null:
				_props(rec, op)
	var kids: Dictionary = {}
	for depth: int in recs:
		var rec: Dictionary = recs[depth]
		var old: Variant = inst.kids.get(depth)
		var kept: Dictionary = old if old != null and int(old.c) == int(rec.c) and int(old.pf) == int(rec.pf) else _make(clip, int(rec.c), int(rec.pf))
		for key: String in ["m", "mul", "add", "bl", "fl", "n", "hide"]:
			kept[key] = rec[key]
		kids[depth] = kept
	inst.kids = kids
	inst.f = target


func _enter(clip: Dictionary, inst: Dictionary, signal_events: bool) -> void :
	var key: String = _key(int(inst.c))
	var stops: Array = clip.doc.get("stops", {}).get(key, [])
	if stops.has(int(inst.f)) or stops.has(float(inst.f)):
		inst.play = false
	if signal_events:
		var name: String = str(clip.doc.get("events", {}).get(key, {}).get(str(int(inst.f)), ""))
		if not name.is_empty():
			event.emit(name)

func _advance(clip: Dictionary, inst: Dictionary, top: bool) -> void :
	var before: Dictionary = inst.kids.duplicate()
	var frames: Array = _frames(clip, int(inst.c))
	if bool(inst.play) and frames.size() > 1:
		var next: int = int(inst.f) + 1
		if next >= frames.size():
			_goto(clip, inst, 0)
		else:
			inst.f = next
			for op: Dictionary in frames[next]:
				_apply(clip, inst, op, next)
		_enter(clip, inst, top and int(inst.c) < 0)
	for depth: int in before:
		var kid: Dictionary = before[depth]
		if is_same(inst.kids.get(depth), kid) and clip.doc.sprites.has(str(int(kid.c))):
			_advance(clip, kid, false)




static func cx_join(mul: Color, add: Color, parent_mul: Color, parent_add: Color) -> Array:
	return [mul * parent_mul, add * parent_mul + parent_add]


static func filter_plan(list: Array) -> Dictionary:
	var plan: Dictionary = {"fx": 0, "cm": 0, "rows": [], "b": Vector2.ZERO, "p": 1, "c": Color(1, 1, 1, 1), "s": 1.0}
	var rows: Array = []
	for f: Dictionary in list:
		match str(f.get("t", "")):
			"m":
				rows = cm_join(rows, f.m)
				if plan.cm == 0:
					plan.cm = 2 if int(plan.fx) != 0 else 1
			"g", "b":
				if int(plan.fx) != 0:
					continue
				plan.fx = 1 if str(f.t) == "g" else 2
				plan.b = Vector2(float(f.b[0]), float(f.b[1]))
				plan.p = maxi(1, int(f.get("p", 1)))
				if str(f.t) == "g":
					var c: Array = f.c
					plan.c = Color(float(c[0]) / 255.0, float(c[1]) / 255.0, float(c[2]) / 255.0, float(c[3]) / 255.0)
					plan.s = float(f.get("s", 1.0))
	plan.rows = rows
	return plan


static func cm_join(a: Array, b: Array) -> Array:
	if a.is_empty():
		return b.duplicate()
	var out: Array = []
	for r in range(4):
		for c in range(5):
			var v: float = float(b[r * 5 + 4]) if c == 4 else 0.0
			for k in range(4):
				v += float(b[r * 5 + k]) * float(a[k * 5 + c])
			out.append(v)
	return out


static func blur_radius(b: float, passes: int) -> Vector2:
	if b < 1.0:
		return Vector2.ZERO
	if passes <= 1:
		return Vector2(b / 2.0, 0.0)
	return Vector2(passes * b / 2.0, b * sqrt(passes / 12.0))


static func taps_for(rad: float, cap: int) -> int:
	return 0 if rad < 0.5 else clampi(ceili(rad), 1, cap)


static func uv_affine(pts: PackedVector2Array, uvs: PackedVector2Array) -> Transform2D:
	var du1: Vector2 = uvs[1] - uvs[0]
	var du3: Vector2 = uvs[3] - uvs[0]
	var det: float = du1.x * du3.y - du3.x * du1.y
	if absf(det) < 1e-07:
		return Transform2D(Vector2.ZERO, Vector2.ZERO, pts[0])
	var p1: Vector2 = pts[1] - pts[0]
	var p3: Vector2 = pts[3] - pts[0]

	var ix: Vector2 = Vector2(du3.y, - du1.y) / det
	var iy: Vector2 = Vector2( - du3.x, du1.x) / det
	var mx: Vector2 = p1 * ix.x + p3 * ix.y
	var my: Vector2 = p1 * iy.x + p3 * iy.y
	return Transform2D(mx, my, pts[0] - (mx * uvs[0].x + my * uvs[0].y))




func paint(canvas: CanvasItem, xf: Transform2D) -> void :
	for leaf: Dictionary in _build():
		canvas.draw_set_transform_matrix(xf * (leaf.xf as Transform2D))
		canvas.draw_polygon(leaf.pts, PackedColorArray([leaf.mul]), leaf.uvs, leaf.tex)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


func render() -> void :
	_dirty = false
	var out: Array = _build()
	leaves = out.size()
	if not is_inside_tree():
		return
	_fill(out)


func _build() -> Array:
	named = {}
	var out: Array = []
	for index in range(_clips.size()):
		var clip: Dictionary = _clips[index]
		var ctx: Dictionary = {"xf": clip.at, "omul": Color(1, 1, 1, 1), "oadd": Color(0, 0, 0, 0), "imul": Color(1, 1, 1, 1), 
			"iadd": Color(0, 0, 0, 0), "fl": -1, "bl": 0}
		_walk(clip, clip.root, ctx, out, index == 0)
	return out

func _fill(out: Array) -> void :
	while _pool.size() < out.size():
		var item: RID = RenderingServer.canvas_item_create()
		RenderingServer.canvas_item_set_parent(item, get_canvas_item())
		RenderingServer.canvas_item_set_draw_index(item, _pool.size())
		var mat: RID = RenderingServer.material_create()
		RenderingServer.canvas_item_set_material(item, mat)
		_pool.append([item, mat, -1])
	for index in range(_pool.size()):
		var slot: Array = _pool[index]
		RenderingServer.canvas_item_clear(slot[0])
		RenderingServer.canvas_item_set_visible(slot[0], index < out.size())
		if index < out.size():
			_draw_leaf(slot, out[index])

func _walk(clip: Dictionary, inst: Dictionary, ctx: Dictionary, out: Array, first: bool) -> void :
	var depths: Array = inst.kids.keys()
	depths.sort()
	for depth: int in depths:
		var kid: Dictionary = inst.kids[depth]
		if bool(kid.hide):
			continue
		var sub: Dictionary = ctx.duplicate()
		sub.xf = ctx.xf * kid.m
		if int(ctx.fl) < 0:
			var outer: Array = cx_join(kid.mul, kid.add, ctx.omul, ctx.oadd)
			sub.omul = outer[0]
			sub.oadd = outer[1]
			if int(kid.fl) >= 0 and not (clip.doc.fl[int(kid.fl)] as Array).is_empty():
				sub.fl = int(kid.fl)
		else:
			var inner: Array = cx_join(kid.mul, kid.add, ctx.imul, ctx.iadd)
			sub.imul = inner[0]
			sub.iadd = inner[1]
		if int(ctx.bl) in [0, 1] and int(kid.bl) > 1:
			sub.bl = int(kid.bl)
		var shape: Variant = clip.doc.shapes.get(str(int(kid.c)))
		if shape is Array:
			_shape_leaf(clip, shape, sub, out)
		else:
			_walk(clip, kid, sub, out, first)
		if not str(kid.n).is_empty():
			named[str(kid.n)] = {"xf": sub.xf, "alpha": sub.omul.a * sub.imul.a}
			if first and attach.has(str(kid.n)):
				for pic: Array in attach[str(kid.n)]:
					var tex: Texture2D = pic[0]
					var rect: Rect2 = pic[1]
					if tex == null:
						continue
					var pts: PackedVector2Array = PackedVector2Array([rect.position, rect.position + Vector2(rect.size.x, 0), rect.end, 
						rect.position + Vector2(0, rect.size.y)])
					var uvs: PackedVector2Array = PackedVector2Array([Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)])
					out.append(_leaf(clip, sub, tex, Vector2(tex.get_size()), pts, uvs, true))

func _shape_leaf(clip: Dictionary, row: Array, ctx: Dictionary, out: Array) -> void :
	var page: int = int(row[0])
	if page < 0 or page >= clip.pages.size():
		return
	var pts: PackedVector2Array = PackedVector2Array()
	var uvs: PackedVector2Array = PackedVector2Array()
	for k in range(4):
		pts.append(Vector2(float(row[2 + k * 4]), float(row[3 + k * 4])))
		uvs.append(Vector2(float(row[4 + k * 4]), float(row[5 + k * 4])))
	var size: Array = clip.doc.sizes[page]
	out.append(_leaf(clip, ctx, clip.pages[page], Vector2(float(size[0]), float(size[1])), pts, uvs, int(row[1]) != 0))


func _leaf(clip: Dictionary, ctx: Dictionary, tex: Texture2D, tex_size: Vector2, pts: PackedVector2Array, uvs: PackedVector2Array, smooth: bool) -> Dictionary:
	var bl: int = int(ctx.bl)
	var leaf: Dictionary = {"tex": tex, "xf": ctx.xf, "pts": pts, "uvs": uvs, "smooth": smooth, 
		"kind": ADD if bl == 8 else (OVERLAY if bl == 13 else NORMAL), "mul": ctx.omul, "add": ctx.oadd, "imul": ctx.imul, 
		"iadd": ctx.iadd, "fx": 0, "cm": 0}
	if int(ctx.fl) < 0:
		return leaf
	var plan: Dictionary = filter_plan(clip.doc.fl[int(ctx.fl)])
	leaf.cm = plan.cm
	if not (plan.rows as Array).is_empty():
		var m: Array = plan.rows
		leaf.rows = [Vector4(m[0], m[1], m[2], m[3]), Vector4(m[5], m[6], m[7], m[8]), Vector4(m[10], m[11], m[12], m[13]), 
			Vector4(m[15], m[16], m[17], m[18])]
		leaf.cmo = Vector4(float(m[4]) / 255.0, float(m[9]) / 255.0, float(m[14]) / 255.0, float(m[19]) / 255.0)
	if int(plan.fx) == 0:
		return leaf
	var map: Transform2D = uv_affine(pts, uvs)
	var lin: Transform2D = Transform2D(ctx.xf.x, ctx.xf.y, Vector2.ZERO) * Transform2D(map.x, map.y, Vector2.ZERO)
	var texel: Vector2 = Vector2((lin.x / maxf(1.0, tex_size.x)).length(), (lin.y / maxf(1.0, tex_size.y)).length())
	var rx: Vector2 = blur_radius(float(plan.b.x), int(plan.p))
	var ry: Vector2 = blur_radius(float(plan.b.y), int(plan.p))
	var rad: Vector2 = Vector2(rx.x / maxf(0.0001, texel.x), ry.x / maxf(0.0001, texel.y))
	if int(plan.fx) == 2 and rad.x < 0.5 and rad.y < 0.5:
		return leaf
	var cap: int = TAP_CAP_2D if rad.x >= 0.5 and rad.y >= 0.5 else TAP_CAP_1D
	var taps: Vector2i = Vector2i(taps_for(rad.x, cap), taps_for(rad.y, cap))
	var step_tex: Vector2 = Vector2(rad.x / maxf(1.0, taps.x), rad.y / maxf(1.0, taps.y))
	var sig: Vector2 = Vector2.ZERO
	if rx.y > 0.0 and taps.x > 0:
		sig.x = rx.y / maxf(0.0001, texel.x) / maxf(0.0001, step_tex.x)
	if ry.y > 0.0 and taps.y > 0:
		sig.y = ry.y / maxf(0.0001, texel.y) / maxf(0.0001, step_tex.y)
	leaf.fx = plan.fx
	leaf.taps = taps
	leaf.step = step_tex / tex_size
	leaf.sig = sig
	leaf.gcol = plan.c
	leaf.gstr = plan.s

	var lo: Vector2 = Vector2(minf(minf(uvs[0].x, uvs[1].x), minf(uvs[2].x, uvs[3].x)), minf(minf(uvs[0].y, uvs[1].y), minf(uvs[2].y, uvs[3].y)))
	var hi: Vector2 = Vector2(maxf(maxf(uvs[0].x, uvs[1].x), maxf(uvs[2].x, uvs[3].x)), maxf(maxf(uvs[0].y, uvs[1].y), maxf(uvs[2].y, uvs[3].y)))
	leaf.uvr = Vector4(lo.x, lo.y, hi.x, hi.y)
	var grow: Vector2 = rad / tex_size
	var a: Vector2 = lo - grow
	var b: Vector2 = hi + grow
	var big: PackedVector2Array = PackedVector2Array([Vector2(a.x, a.y), Vector2(b.x, a.y), Vector2(b.x, b.y), Vector2(a.x, b.y)])
	var out_pts: PackedVector2Array = PackedVector2Array()
	for uv: Vector2 in big:
		out_pts.append(map * uv)
	leaf.pts = out_pts
	leaf.uvs = big
	return leaf

static func _shader(kind: int) -> Shader:
	if _shaders.is_empty():
		for k in range(3):
			var shader: Shader = Shader.new()
			var mode: String = "blend_add" if k == ADD else "blend_mix"
			shader.code = SHADER % [mode, OVERLAY_DECL if k == OVERLAY else "", OVERLAY_CODE if k == OVERLAY else ""]
			_shaders.append(shader)
	return _shaders[kind]

func _draw_leaf(slot: Array, leaf: Dictionary) -> void :
	var item: RID = slot[0]
	var mat: RID = slot[1]
	var kind: int = int(leaf.kind)
	if kind == OVERLAY and TouchGfx.flat_overlay():
		if int(slot[2]) == OVERLAY:
			RenderingServer.canvas_item_set_copy_to_backbuffer(item, false, Rect2())
		slot[2] = -1
		return
	if int(slot[2]) != kind:
		slot[2] = kind
		RenderingServer.material_set_shader(mat, _shader(kind).get_rid())
		RenderingServer.canvas_item_set_copy_to_backbuffer(item, kind == OVERLAY, Rect2())
	RenderingServer.canvas_item_set_transform(item, leaf.xf)
	RenderingServer.canvas_item_set_default_texture_filter(item, RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_LINEAR if leaf.smooth\
	else RenderingServer.CANVAS_ITEM_TEXTURE_FILTER_NEAREST)
	RenderingServer.material_set_param(mat, "mul", leaf.mul)
	RenderingServer.material_set_param(mat, "add", leaf.add)
	RenderingServer.material_set_param(mat, "imul", leaf.imul)
	RenderingServer.material_set_param(mat, "iadd", leaf.iadd)
	RenderingServer.material_set_param(mat, "fx", int(leaf.fx))
	RenderingServer.material_set_param(mat, "cm", int(leaf.cm))
	if int(leaf.cm) != 0 and leaf.has("rows"):
		var rows: Array = leaf.rows
		RenderingServer.material_set_param(mat, "cr", rows[0])
		RenderingServer.material_set_param(mat, "cg", rows[1])
		RenderingServer.material_set_param(mat, "cb", rows[2])
		RenderingServer.material_set_param(mat, "ca", rows[3])
		RenderingServer.material_set_param(mat, "cmo", leaf.cmo)
	if int(leaf.fx) != 0:
		RenderingServer.material_set_param(mat, "step_uv", leaf.step)
		RenderingServer.material_set_param(mat, "taps", leaf.taps)
		RenderingServer.material_set_param(mat, "sig", leaf.sig)
		RenderingServer.material_set_param(mat, "gcol", leaf.gcol)
		RenderingServer.material_set_param(mat, "gstr", float(leaf.gstr))
		RenderingServer.material_set_param(mat, "uvr", leaf.uvr)
	else:
		RenderingServer.material_set_param(mat, "uvr", Vector4(-9, -9, 9, 9))
	var white: PackedColorArray = PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE, Color.WHITE])
	RenderingServer.canvas_item_add_polygon(item, leaf.pts, white, leaf.uvs, (leaf.tex as Texture2D).get_rid())


func set_attach(value: Dictionary) -> void :
	var sig: Array = []
	for name: String in value:
		for pic: Array in value[name]:
			sig.append([name, pic[0].get_instance_id() if pic[0] != null else 0, pic[1]])
	if sig != _attach_sig:
		_attach_sig = sig
		attach = value
		_dirty = true

func _notification(what: int) -> void :
	if what == NOTIFICATION_PREDELETE or what == NOTIFICATION_EXIT_TREE:
		for slot: Array in _pool:
			RenderingServer.free_rid(slot[0])
			RenderingServer.free_rid(slot[1])
		_pool = []
		_dirty = true
