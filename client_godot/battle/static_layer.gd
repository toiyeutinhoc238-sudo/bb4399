extends RefCounted











const NEVER: int = -2
const RETRY: int = -1
const MAX_WAIT: int = 32

var enabled: bool = true

var audit_on: bool = false
var audit_checks: int = 0
var audit_fails: int = 0
var audit_last: String = ""
var n_promote: int = 0
var n_demote: int = 0
var n_reset: int = 0
var n_relink: int = 0
var n_fallback: int = 0
var n_drawn: int = 0

var view = null
var _ci: CanvasItem = null
var _battle = null
var _rect: Rect2 = Rect2()
var _frame: int = 0
var _on: bool = false

var _src_battle = null
var _src_npcs = null
var _src_textures = null
var _src_templates = null
var _src_pack = null
var _src_camp: int = -999
var _src_map: int = -999
var _src_clock: float = - INF


var _s_npc: Array = []
var _s_code: PackedInt32Array = PackedInt32Array()
var _s_next: PackedInt32Array = PackedInt32Array()
var _s_wait: PackedInt32Array = PackedInt32Array()


var r_npc: Array = []
var r_id: PackedInt64Array = PackedInt64Array()
var r_hp: Array = []
var r_max: Array = []
var r_lit: Array = []
var r_pos: PackedVector2Array = PackedVector2Array()
var r_tex: Array = []
var r_at: PackedVector2Array = PackedVector2Array()
var r_on: PackedByteArray = PackedByteArray()
var r_vis: PackedByteArray = PackedByteArray()
var r_cls: PackedInt32Array = PackedInt32Array()
var r_key: Array = []
var _by_id: Dictionary = {}
var _gone: int = 0
var _dirty: bool = false
var _ord_layer: PackedInt32Array = PackedInt32Array()
var _keys_layer: Array = []
var _ord_under: PackedInt32Array = PackedInt32Array()
var _ord_over: PackedInt32Array = PackedInt32Array()
var _vis_layer: int = 0
var _vis_under: int = 0
var _vis_over: int = 0
var _e_tex: Texture2D = null
var _e_meta: Array = []



func collect(v, battle, rect: Rect2) -> Array:
	if not enabled:
		_on = false
		return battle.npcs.values()
	_sources(v, battle)
	_on = true
	_battle = battle
	_rect = rect
	_frame += 1
	_vis_layer = 0
	_vis_under = 0
	_vis_over = 0
	var vals: Array = battle.npcs.values()
	var n: int = vals.size()
	if n != _s_npc.size():
		_relink(vals)
	var loose: Array = []
	for i in n:
		var npc: Dictionary = vals[i]
		if not is_same(npc, _s_npc[i]):
			_relink(vals)
		var c: int = _s_code[i]
		if c >= 0:
			var p: Vector2 = npc.pos
			if p == r_pos[c]:
				if not rect.has_point(p):
					r_vis[c] = 0
					continue
				if not npc.dead and npc.hp == r_hp[c] and npc.max_hp == r_max[c] and npc.buffs.is_empty() and not npc.has("throw")\
				and not npc.get("hidden", false) and not npc.get("faded", false) and npc.get("lit") == r_lit[c]\
				and not npc.has("face"):
					r_vis[c] = 1
					var k: int = r_cls[c]
					if k == 0:
						_vis_layer += 1
					elif k == 52:
						_vis_under += 1
					else:
						_vis_over += 1
					continue
			_demote(i, c, npc.dead)
		elif c == RETRY and _frame >= _s_next[i]:
			c = _promote(i, npc)
			if c >= 0:
				if rect.has_point(npc.pos):
					r_vis[c] = 1
					var k: int = r_cls[c]
					if k == 0:
						_vis_layer += 1
					elif k == 52:
						_vis_under += 1
					else:
						_vis_over += 1
				continue
		loose.append(npc)
	if _dirty:
		_rebuild()
	return loose


func merge(layer: Array) -> Array:
	if not _on:
		return layer
	if _vis_layer == 0:
		if audit_on:
			_audit_layer(layer)
		return layer
	var out: Array = []
	var keys: Array = _keys_layer
	var n: int = keys.size()
	var a: int = 0
	for d: Array in layer:
		var lo: int = a
		var hi: int = n
		while lo < hi:
			var mid: int = (lo + hi) >> 1
			if keys[mid] < d:
				lo = mid + 1
			else:
				hi = mid
		if lo > a:
			out.append([a, lo, 0])
			a = lo
		out.append(d)
	if a < n:
		out.append([a, n, 0])
	if audit_on:
		_audit_layer(out)
	return out


func run(mark: Array) -> void :
	var a: int = mark[0]
	var b: int = mark[1]
	var first: bool = true
	for k in range(a, b):
		var r: int = _ord_layer[k]
		if r_vis[r] == 0:
			continue
		if first:
			first = false
			_ci.draw_set_transform(view._offset, 0, Vector2(view._zoom, view._zoom))
		_ci.draw_texture(r_tex[r], r_at[r])
		n_drawn += 1
		if audit_on:
			_audit_record(r)
	if not first:
		view._alpha = 1.0


func sky(v, battle, dyn: Array, cls: int) -> void :
	var nvis: int = _vis_under if cls == 52 else _vis_over
	if not _on or nvis == 0:
		if audit_on and _on:
			_audit_sky(dyn, [], cls)
		for npc: Dictionary in dyn:
			v._draw_npc(npc, battle)
		return
	var ord: PackedInt32Array = _ord_under if cls == 52 else _ord_over
	var seq: Array = []
	var nd: int = dyn.size()
	var tie: bool = false
	for k in range(1, nd):
		if (dyn[k] as Dictionary).pos == (dyn[k - 1] as Dictionary).pos:
			tie = true
			break
	var j: int = 0
	if not tie:
		for r: int in ord:
			if r_vis[r] == 0:
				continue
			var p: Vector2 = r_pos[r]
			while j < nd:
				var q: Vector2 = (dyn[j] as Dictionary).pos
				if q.y < p.y or (q.y == p.y and q.x < p.x):
					seq.append(dyn[j])
					j += 1
				elif q == p:
					tie = true
					break
				else:
					break
			if tie:
				break
			seq.append(r)
	if tie:

		n_fallback += 1
		for npc: Dictionary in _exact_sky(v, battle, cls):
			v._draw_npc(npc, battle)
		return
	while j < nd:
		seq.append(dyn[j])
		j += 1
	if audit_on:
		_audit_sky(dyn, seq, cls)
	var xf: bool = false
	for item: Variant in seq:
		if item is int:
			if not xf:
				xf = true
				_ci.draw_set_transform(v._offset, 0, Vector2(v._zoom, v._zoom))
			_ci.draw_texture(r_tex[item], r_at[item])
			v._alpha = 1.0
			n_drawn += 1
			if audit_on:
				_audit_record(item)
		else:
			v._draw_npc(item, battle)
			xf = false


func _exact_sky(v, battle, cls: int) -> Array:
	var list: Array = []
	for npc: Dictionary in battle.npcs.values():
		if npc.dead or npc.get("hidden", false) or not _rect.has_point(npc.pos):
			continue
		if int(npc.id) >> 26 == 4:
			continue
		var meta: Variant = v._npc_meta_rows.get(int(npc.template))
		if meta == null:
			meta = v._npc_meta(int(npc.template))
		if meta[1] == cls:
			list.append(npc)
	list.sort_custom(Callable(v, "_npc_before"))
	return list

func _sources(v, battle) -> void :
	var clock: float = battle.clock
	if not _on or not is_same(view, v) or not is_same(_src_battle, battle) or not is_same(_src_npcs, battle.npcs)\
	or not is_same(_src_textures, v._textures) or not is_same(_src_templates, battle.map.templates) or not is_same(_src_pack, v.pack)\
	or _src_camp != v._my_camp or _src_map != v._map_id or clock < _src_clock:
		_reset()
		view = v
		_ci = v
		_src_battle = battle
		_src_npcs = battle.npcs
		_src_textures = v._textures
		_src_templates = battle.map.templates
		_src_pack = v.pack
		_src_camp = v._my_camp
		_src_map = v._map_id
	_src_clock = clock

func _reset() -> void :
	_s_npc.clear()
	_s_code.clear()
	_s_next.clear()
	_s_wait.clear()
	r_npc.clear()
	r_id.clear()
	r_hp.clear()
	r_max.clear()
	r_lit.clear()
	r_pos.clear()
	r_tex.clear()
	r_at.clear()
	r_on.clear()
	r_vis.clear()
	r_cls.clear()
	r_key.clear()
	_by_id.clear()
	_ord_layer.clear()
	_keys_layer.clear()
	_ord_under.clear()
	_ord_over.clear()
	_gone = 0
	_dirty = false
	n_reset += 1


func _relink(vals: Array) -> void :
	n_relink += 1
	var n: int = vals.size()
	var s_npc: Array = []
	s_npc.resize(n)
	var s_code: PackedInt32Array = PackedInt32Array()
	s_code.resize(n)
	var s_next: PackedInt32Array = PackedInt32Array()
	s_next.resize(n)
	var s_wait: PackedInt32Array = PackedInt32Array()
	s_wait.resize(n)
	var used: PackedByteArray = PackedByteArray()
	used.resize(r_npc.size())
	for j in n:
		var npc: Dictionary = vals[j]
		s_npc[j] = npc
		var r: int = _by_id.get(int(npc.id), -1)
		if r >= 0 and r_on[r] == 1 and is_same(r_npc[r], npc):
			s_code[j] = r
			used[r] = 1
		else:
			s_code[j] = RETRY
			s_next[j] = _frame
			s_wait[j] = 1
	for r in r_npc.size():
		if r_on[r] == 1 and used[r] == 0:
			_drop(r)
	_s_npc = s_npc
	_s_code = s_code
	_s_next = s_next
	_s_wait = s_wait

func _drop(r: int) -> void :
	r_on[r] = 0
	r_vis[r] = 0
	if int(_by_id.get(r_id[r], -1)) == r:
		_by_id.erase(r_id[r])
	_gone += 1
	_dirty = true

func _demote(i: int, r: int, dead: bool) -> void :
	n_demote += 1
	_drop(r)
	_s_code[i] = NEVER if dead else RETRY
	_s_wait[i] = 1
	_s_next[i] = _frame + 1



func _eligible(npc: Dictionary) -> int:
	if int(npc.id) >> 26 != 3 or npc.dead:
		return NEVER
	var meta: Array = view._npc_meta(int(npc.template))
	if (meta[0] as Dictionary).is_empty() or meta[1] == 4 or meta[4]:
		return NEVER
	if npc.has("throw") or npc.get("hidden", false) or npc.get("faded", false) or not npc.buffs.is_empty():
		return RETRY
	var pack = view.pack
	var shown: int = int(npc.template)
	if meta[3] != 0 and view._my_camp == 1 and pack != null:
		var partner: int = meta[3]
		if not view._npc_pair.has(partner * 2):
			return RETRY
		shown = partner
	var state: int = 0
	if npc.max_hp > 0 and npc.hp >= 0:
		var pct: int = int(float(npc.hp) / npc.max_hp * 100.0)
		state = 3 if pct <= 25 else 2 if pct <= 50 else 1 if pct <= 75 else 0
	if state > 0 and pack != null and not npc.has("warm"):
		return RETRY
	if npc.has("lit"):
		var glow: float = 1.0 + 0.8 * clampf(1.0 - (_battle.clock - float(npc.lit)) / 0.1, 0.0, 1.0)
		if glow != 1.0:
			return RETRY
	var hit: Variant = view._npc_tex.get(shown * 32 + (8 + state if state > 0 and pack != null else 0))
	if hit == null:
		return RETRY
	if pack != null:
		if not is_same(view._npc_anim_pack, pack):
			return RETRY
		var memo: Variant = view._npc_anim.get(shown * 4 + state)
		if not (memo is bool) or memo:
			return RETRY
	_e_tex = hit
	_e_meta = meta
	return 0

func _promote(i: int, npc: Dictionary) -> int:
	var why: int = _eligible(npc)
	if why == 0 and _e_meta[1] != 0:

		var p: Vector2 = npc.pos
		for r in r_npc.size():
			if r_on[r] == 1 and r_cls[r] == _e_meta[1] and r_pos[r] == p:
				why = RETRY
				break
	if why != 0:
		if why == NEVER:
			_s_code[i] = NEVER
		else:
			var wait: int = mini(_s_wait[i] * 2, MAX_WAIT)
			_s_wait[i] = wait
			_s_next[i] = _frame + wait
		return why
	n_promote += 1
	var r: int = r_npc.size()
	var at: Vector2 = npc.pos
	r_npc.append(npc)
	r_id.append(int(npc.id))
	r_hp.append(npc.hp)
	r_max.append(npc.max_hp)
	r_lit.append(npc.get("lit"))
	r_pos.append(at)
	r_tex.append(_e_tex)
	r_at.append(npc.pos - _e_tex.get_size() / 2)
	r_on.append(1)
	r_vis.append(0)
	r_cls.append(_e_meta[1])
	r_key.append([_e_meta[2], npc.pos.y, npc.pos.x, int(npc.id)])
	_by_id[int(npc.id)] = r
	_s_code[i] = r
	_s_wait[i] = 1
	_dirty = true
	return r


func _rebuild() -> void :
	_dirty = false
	var n: int = r_npc.size()
	if _gone > 0:
		var remap: PackedInt32Array = PackedInt32Array()
		remap.resize(n)
		var m: int = 0
		for r in n:
			if r_on[r] == 1:
				remap[r] = m
				if m != r:
					r_npc[m] = r_npc[r]
					r_id[m] = r_id[r]
					r_hp[m] = r_hp[r]
					r_max[m] = r_max[r]
					r_lit[m] = r_lit[r]
					r_pos[m] = r_pos[r]
					r_tex[m] = r_tex[r]
					r_at[m] = r_at[r]
					r_on[m] = 1
					r_vis[m] = r_vis[r]
					r_cls[m] = r_cls[r]
					r_key[m] = r_key[r]
				m += 1
			else:
				remap[r] = -1
		r_npc.resize(m)
		r_id.resize(m)
		r_hp.resize(m)
		r_max.resize(m)
		r_lit.resize(m)
		r_pos.resize(m)
		r_tex.resize(m)
		r_at.resize(m)
		r_on.resize(m)
		r_vis.resize(m)
		r_cls.resize(m)
		r_key.resize(m)
		for i in _s_code.size():
			var c: int = _s_code[i]
			if c >= 0:
				_s_code[i] = remap[c] if remap[c] >= 0 else RETRY
		_by_id.clear()
		for r in m:
			_by_id[r_id[r]] = r
		_gone = 0
		n = m
	var rows: Array = []
	var under: Array = []
	var over: Array = []
	for r in n:
		var k: int = r_cls[r]
		if k == 52:
			under.append(r)
		elif k == 53:
			over.append(r)
		else:
			rows.append(r_key[r] + [r])
	rows.sort()
	_ord_layer.resize(rows.size())
	_keys_layer.resize(rows.size())
	for k in rows.size():
		var r: int = rows[k][4]
		_ord_layer[k] = r
		_keys_layer[k] = r_key[r]
	var before: Callable = func(a: int, b: int) -> bool:
		var pa: Vector2 = r_pos[a]
		var pb: Vector2 = r_pos[b]
		return pa.y < pb.y if pa.y != pb.y else pa.x < pb.x
	under.sort_custom(before)
	over.sort_custom(before)
	_ord_under = PackedInt32Array(under)
	_ord_over = PackedInt32Array(over)



func _fail(what: String) -> void :
	audit_fails += 1
	audit_last = what


func _audit_layer(merged: Array) -> void :
	audit_checks += 1
	var want: Array = []
	for npc: Dictionary in _battle.npcs.values():
		if npc.dead or npc.get("hidden", false) or not _rect.has_point(npc.pos):
			continue
		if int(npc.id) >> 26 == 4:
			continue
		var meta: Array = view._npc_meta(int(npc.template))
		if meta[1] == 52 or meta[1] == 53:
			continue
		want.append([meta[2], npc.pos.y, npc.pos.x, int(npc.id)])
	for tank: Dictionary in _battle.tanks.values():
		if not tank.get("hidden", false) and _rect.has_point(tank.pos):
			want.append([view.TANK_SORT, tank.pos.y, tank.pos.x, int(tank.id)])
	want.sort()
	var got: Array = []
	for e: Array in merged:
		if e.size() == 3:
			for k in range(int(e[0]), int(e[1])):
				var r: int = _ord_layer[k]
				if r_vis[r] == 1:
					got.append(int(r_id[r]))
		else:
			got.append(int(e[3]))
	var ids: Array = []
	for w: Array in want:
		ids.append(int(w[3]))
	if ids != got:
		_fail("layer %s != %s" % [str(got), str(ids)])

func _audit_sky(dyn: Array, seq: Array, cls: int) -> void :
	audit_checks += 1
	var want: Array = []
	for npc: Dictionary in _exact_sky(view, _battle, cls):
		want.append(int(npc.id))
	var got: Array = []
	if seq.is_empty():
		for npc: Dictionary in dyn:
			got.append(int(npc.id))
	else:
		for item: Variant in seq:
			got.append(int(r_id[item]) if item is int else int(item.id))
	if want != got:
		_fail("sky%d %s != %s" % [cls, str(got), str(want)])


func _audit_record(r: int) -> void :
	audit_checks += 1
	var npc: Dictionary = r_npc[r]
	if _eligible(npc) != 0 or not is_same(_e_tex, r_tex[r]) or r_at[r] != npc.pos - _e_tex.get_size() / 2 or not _rect.has_point(npc.pos)\
	or npc.get("hidden", false) or npc.dead:
		_fail("record %d id %d" % [r, int(npc.id)])
