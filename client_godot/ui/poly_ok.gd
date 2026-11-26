extends RefCounted


const MIN_SPAN: float = 0.5
const MIN_AREA: float = 0.05

static func ok(points: PackedVector2Array) -> bool:
	if points.size() < 3:
		return false
	var lo: Vector2 = points[0]
	var hi: Vector2 = points[0]
	var area: float = 0.0
	for i: int in points.size():
		var p: Vector2 = points[i]
		if not p.is_finite():
			return false
		lo = lo.min(p)
		hi = hi.max(p)
		var q: Vector2 = points[(i + 1) % points.size()]
		area += p.x * q.y - q.x * p.y
	return hi.x - lo.x >= MIN_SPAN and hi.y - lo.y >= MIN_SPAN and absf(area) * 0.5 >= MIN_AREA
