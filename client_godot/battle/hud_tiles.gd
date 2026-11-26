extends RefCounted















const TankState = preload("../ui/tankstate_atlas.gd")
const NameStyles = preload("../ui/name_styles.gd")
const RingMesh = preload("ring_mesh.gd")
const PHASES: int = 8
const BOX: Array = [Rect2(0, 0, 62, 71), Rect2(-64, -1, 192, 71), Rect2(1, 0, 60, 60), Rect2(-12, 29, 92, 39), Rect2(-12, 29, 92, 39), 
	Rect2(-3, -2, 70, 71), Rect2(-34, -14, 134, 48), Rect2(-34, -14, 134, 48)]
const VIP_COLOR: Color = Color("fff000")
const NAME_RIM: Color = Color(0, 0, 0, 0.9)
const CD_RIM: Color = Color("1a1a1a")
const MEMO_MAX: int = 64

static var enabled: bool = true

var sinking: bool = false
var live: bool = false
var sink: Array = []
var memo: Dictionary = {}
var tiles: Array = []
var _key: Array = []
var _legal: bool = false
var hits: int = 0
var builds: int = 0
var runs: int = 0
var ordered: int = 0
var solos: int = 0
var rekeys: int = 0
var inf_hits: int = 0



func tile(hud, battle, tank: Dictionary, brief: Dictionary, right: bool, blue: bool, cd_shown: bool, cd: String, tint: Color, pve: bool, 
		origin: Vector2) -> void :
	var sheet: Texture2D = hud._state_sheet()
	var has: bool = not brief.is_empty()
	var other: Dictionary = brief.get("otherData") if brief.get("otherData") is Dictionary else {}
	var data: Dictionary = brief.charData if has else {}
	var full: String = str(data.get("szName", "")) if has else ""
	var styled: PackedColorArray = NameStyles.colors_of(hud.view.client, int(tank.get("account", 0)), full) if has else PackedColorArray()
	var max_hp: float = maxf(1.0, float(tank.get("max_hp", 1)))
	var fill: float = clampf(float(tank.get("hp", 0)) / max_hp, 0.0, 1.0)
	var star: bool = has and pve
	var sig: Array = [sheet, right, blue, has, int(other.get("skinFrameType", 0)) if has else 0, (int(data.get("nVipLevel", 0)) > 0) if has else false, 
		full, styled, roundf(float(TankState.LAYOUT.hp[2]) * fill), star, (int(other.get("tryTank", 0)) == 1) if star else false, 
		mini(int(other.get("tankLevel", 0)), 6) if star else 0, cd_shown, cd if cd_shown else "", hud.bold, hud.font]
	var id: int = int(tank.id)
	var hit: Variant = memo.get(id)
	if hit == null or hit[0] != sig:
		if memo.size() >= MEMO_MAX:
			memo.clear()
		hit = _build(hud, sig)
		memo[id] = hit
		builds += 1
	else:
		hits += 1
	var clock: float = float(battle.clock)
	var avatar: Variant = []
	var solo: bool = bool(hit[2])
	if has:
		sink = []
		live = false
		sinking = true
		hud._state_avatar(other, origin, tint, clock)
		sinking = false
		if live:
			avatar = null
			solo = true
		else:
			avatar = sink
			var box: Rect2 = BOX[1]
			for op: Array in sink:
				if not box.encloses(op[2]):
					solo = true
					break
	tiles.append([origin, hit[1], avatar, other, tint, clock, solo])

func _build(hud, sig: Array) -> Array:
	var layout: Dictionary = TankState.LAYOUT
	var right: bool = sig[1]
	var blue: bool = sig[2]
	var side: Dictionary = layout.right if right else layout.left
	var sheet: Texture2D = sig[0]
	var bold: Font = sig[14]
	var font: Font = sig[15]
	var ops: Array = []
	for p in PHASES:
		ops.append([])
	_img(ops[0], sheet, "tl_bg", Vector2(layout.bg[0], layout.bg[1]))
	if sig[3]:
		var frame_type: int = sig[4]
		if frame_type in [1, 2]:
			_img(ops[2], sheet, "tl_frame_%d" % frame_type, Vector2(layout.frame[0], layout.frame[1]))
		var name_color: Color = VIP_COLOR if sig[5] else Color.WHITE
		var full: String = sig[6]
		var name: String = hud._fit(full, float(layout.name[2]) - 4.0, int(layout.name[3]))
		var base: Vector2 = Vector2(layout.name[0], float(layout.name[1]) + 2.0 + int(layout.name[3]))
		var styled: PackedColorArray = sig[7]
		if styled.is_empty():
			ops[3].append([1, bold, base, name, HORIZONTAL_ALIGNMENT_CENTER, float(layout.name[2]), int(layout.name[3]), 2, NAME_RIM])
			ops[4].append([2, bold, base, name, HORIZONTAL_ALIGNMENT_CENTER, float(layout.name[2]), int(layout.name[3]), name_color])
		else:
			var inks: PackedColorArray = NameStyles.tints(styled, full.length())
			if name != full:
				inks = inks.slice(0, maxi(1, name.length() - 3))
			ops[4].append([3, bold, base, name, HORIZONTAL_ALIGNMENT_CENTER, float(layout.name[2]), int(layout.name[3]), inks])
	_img(ops[5], sheet, "tl_hp_blue" if blue else "tl_hp_red", Vector2(layout.hp[0], layout.hp[1]), 1.0, Color.WHITE, sig[8])
	if sig[9]:
		var key: String = "tl_rent" if sig[10] else "tl_star_%d" % int(sig[11])
		if TankState.R.has(key):
			var k: float = float(layout.star_scale)
			var at: Vector2 = Vector2(float(side.get("star_right", 0)) - float(TankState.R[key][2]) * k, float(side.get("star_y", 0)))
			if not right:
				var spot: Array = side.star_blue if blue else side.star
				at = Vector2(spot[0], spot[1])
			_img(ops[5], sheet, key, at, k)
	if sig[12]:
		_img(ops[5], sheet, "tl_cd_bg", Vector2(side.cd_bg[0], side.cd_bg[1]))
		var text: String = sig[13]
		if text.is_empty():
			_img(ops[5], sheet, "tl_cd_ready", Vector2(side.cd_ready[0], side.cd_ready[1]))
		else:
			var label: Array = side.cd_label
			var at: Vector2 = Vector2(label[0], float(label[1]) + 2.0 + 14.0)
			ops[6].append([1, font, at, text, HORIZONTAL_ALIGNMENT_CENTER, float(label[2]), 14, 3, CD_RIM])
			ops[7].append([2, font, at, text, HORIZONTAL_ALIGNMENT_CENTER, float(label[2]), 14, Color.WHITE])
	var solo: bool = false
	for p in PHASES:
		var box: Rect2 = BOX[p]
		for op: Array in ops[p]:
			if not box.encloses(rect_of(op)):
				solo = true
	return [sig, ops, solo]


static func _img(into: Array, sheet: Texture2D, key: String, pos: Vector2, k: float = 1.0, tint: Color = Color.WHITE, width: float = -1.0) -> void :
	if sheet == null:
		return
	var r: Array = TankState.R.get(key, [])
	if r.is_empty():
		return
	var w: float = float(r[2]) if width < 0 else width
	if w <= 0:
		return
	into.append([0, sheet, Rect2(pos, Vector2(w, float(r[3])) * k), Rect2(r[0], r[1], w, r[3]), tint])



static func rect_of(op: Array) -> Rect2:
	var kind: int = op[0]
	if kind == 0 or kind == 4:
		return op[2]
	var f: Font = op[1]
	var base: Vector2 = op[2]
	var width: float = op[5]
	var size: int = op[6]
	var rim: float = float(op[7]) if kind == 1 else (2.0 if kind == 3 else 0.0)
	var wide: float = f.get_string_size(str(op[3]), HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var left: float = base.x - maxf(0.0, wide - width) - size - rim
	var right: float = base.x + maxf(width, wide) + size + rim
	return Rect2(left, base.y - 2.0 * size - rim, right - left, 3.0 * size + 2.0 * rim)

func _emit(view: CanvasItem, ops: Array) -> void :
	for op: Array in ops:
		var kind: int = op[0]
		if kind == 0:
			view.draw_texture_rect_region(op[1], op[2], op[3], op[4])
		elif kind == 1:
			view.draw_string_outline(op[1], op[2], op[3], op[4], op[5], op[6], op[7], op[8])
		elif kind == 2:
			view.draw_string(op[1], op[2], op[3], op[4], op[5], op[6], op[7])
		elif kind == 3:
			NameStyles.draw_tinted(view, op[1], op[6], op[2], op[3], op[7], 2, NAME_RIM, "c", op[5], true)
		else:
			view.draw_texture_rect(op[1], op[2], false, op[4])


func _seq(hud, t: Array) -> void :
	hud._at(t[0])
	var ops: Array = t[1]
	_emit(hud.view, ops[0])
	if t[2] == null:
		hud._state_avatar(t[3], t[0], t[4], t[5])
	else:
		_emit(hud.view, t[2])
	for p in range(2, PHASES):
		_emit(hud.view, ops[p])


func _run(hud, a: int, b: int) -> void :
	if b - a < 2:
		if b > a:
			_seq(hud, tiles[a])
		return
	runs += 1
	var at: int = -1
	for p in PHASES:
		for i in range(a, b):
			var t: Array = tiles[i]
			var ops: Array = t[2] if p == 1 else t[1][p]
			if ops.is_empty():
				continue
			if i != at:
				hud._at(t[0])
				at = i
			_emit(hud.view, ops)


static func legal(origins: Array, scale: float) -> bool:
	var spans: Array = []
	for o: Vector2 in origins:
		var own: Array = []
		for r: Rect2 in BOX:
			own.append(Rect2(o + r.position * scale, r.size * scale))
		var above: Array = []
		above.resize(PHASES)
		var acc: Rect2 = own[PHASES - 1]
		for p in range(PHASES - 2, -1, -1):
			above[p] = acc
			acc = acc.merge(own[p])
		spans.append([own, above])
	for j in spans.size():
		for i in j:
			for p in PHASES - 1:
				if (spans[j][0][p] as Rect2).intersects(spans[i][1][p]):
					return false
	return true


func flush(hud) -> void :
	sinking = false
	var n: int = tiles.size()
	if n == 0:
		return
	var key: Array = [hud.scale]
	for t: Array in tiles:
		key.append(t[0])
	if key != _key:
		_key = key
		_legal = legal(key.slice(1), float(hud.scale))
		rekeys += 1
	if not _legal:
		ordered += 1
		for t: Array in tiles:
			_seq(hud, t)
	else:
		var start: int = 0
		for i in n:
			if tiles[i][6]:
				solos += 1
				_run(hud, start, i)
				_seq(hud, tiles[i])
				start = i + 1
		_run(hud, start, n)
	hud._at(tiles[n - 1][0])
	tiles.clear()



static func infinity(points: PackedVector2Array) -> Array:
	var dark: Array = RingMesh.polyline_aa(points, Color(0, 0, 0, 0.9), 5.0)
	var lit: Array = RingMesh.polyline_aa(points, Color.WHITE, 2.4)
	if dark.is_empty() or lit.is_empty():
		return []
	var n: int = points.size()
	var one: PackedInt32Array = RingMesh.indices(n)
	var idx: PackedInt32Array = one.duplicate()
	var shift: int = n * 2 * 3
	for i: int in one:
		idx.append(i + shift)
	return [idx, (dark[0] as PackedVector2Array) + (lit[0] as PackedVector2Array), (dark[1] as PackedColorArray) + (lit[1] as PackedColorArray)]
