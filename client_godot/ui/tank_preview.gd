extends RefCounted



static func _xml(part: Dictionary) -> Dictionary:
	var value: Variant = part.data.get("xml")
	return value if value is Dictionary else {}

static func _swf(part: Variant) -> Dictionary:
	if not part is Dictionary or not part.has("data"):
		return {}
	var runtime: Variant = part.data.get("runtime")
	return runtime.swf if runtime is Dictionary and runtime.get("swf") is Dictionary else {}


static func _idle_frame(layer: Dictionary, time: float) -> int:
	var count: int = maxi(1, int(layer.count))
	var labels: Variant = layer.get("labels")
	if labels is Dictionary and labels.has("idle"):
		var first: int = int(labels["idle"])
		var last: int = count
		for value: Variant in labels.values():
			if int(value) > first:
				last = mini(last, int(value))
		return clampi(first + int(time * 24.0) % maxi(1, last - first), 0, count - 1)
	return int(time * 12.0) % count

static func ready(art: Dictionary) -> bool:
	return art.has("body") and ( not _swf(art.body).is_empty() or art.body.data.frames.size() >= 8)


static func extent(art: Dictionary) -> float:
	var body: Dictionary = art.body
	var frames: Array = body.data.frames
	if frames.is_empty():
		return 100.0
	var swf: Dictionary = _swf(body)
	if swf.is_empty():
		var r: Array = frames[0].rect
		return maxf(40.0, maxf(float(r[2]), float(r[3])))
	var most: float = 40.0
	for layer: Dictionary in swf.get("layers", []):
		var m: Array = layer.matrix
		var r: Array = frames[clampi(int(layer.first), 0, frames.size() - 1)].rect
		most = maxf(most, maxf(float(r[2]) * Vector2(m[0], m[1]).length(), float(r[3]) * Vector2(m[2], m[3]).length()))
	return most

static func _frame(canvas: CanvasItem, part: Dictionary, index: int, world: Transform2D) -> void :
	var frames: Array = part.data.frames
	var frame: Dictionary = frames[clampi(index, 0, frames.size() - 1)]
	var r: Array = frame.rect
	var pivot: Array = frame.pivot
	canvas.draw_set_transform_matrix(world)
	canvas.draw_texture_rect_region(part.pages[int(frame.page)], Rect2( - float(pivot[0]), - float(pivot[1]), float(r[2]), float(r[3])), Rect2(r[0], r[1], r[2], r[3]))


static func draw(canvas: CanvasItem, art: Dictionary, at: Vector2, zoom: float, direction: int, time: float) -> void :
	var step: int = posmod(direction - 1, 8)
	var angle: float = step * PI / 4
	var base: Transform2D = Transform2D(0.0, Vector2(zoom, zoom), 0.0, at)
	var body: Dictionary = art.body
	var body_swf: Dictionary = _swf(body)
	if body_swf.is_empty():
		var xml: Dictionary = _xml(body)
		var total: int = body.data.frames.size()
		var per: int = int(xml.get("a", 0))
		if per <= 0:
			per = maxi(1, total / 8)
		var first: int = mini(step * per, total - 1)
		var count: int = clampi(total - first, 1, per)
		var attack: int = int(xml.get("g", 0)) - 1
		var loop: int = attack if attack > 0 and attack < count else count

		var index: int = int(time * 12.0) % loop if int(xml.get("e", 0)) == 1 else 0
		_frame(canvas, body, first + index, base)
	else:
		var shown: int = 0
		for layer: Dictionary in body_swf.get("layers", []):
			if str(layer.name) == "body":
				shown = _idle_frame(layer, time)
		for layer: Dictionary in body_swf.get("layers", []):
			var index: int = shown
			if str(layer.name) != "body":
				var labels: Variant = layer.get("labels")
				index = _idle_frame(layer, time) if labels is Dictionary and labels.has("idle") else mini(shown, int(layer.count) - 1)
			var m: Array = layer.matrix
			var scale: Vector2 = Vector2(Vector2(m[0], m[1]).length(), Vector2(m[2], m[3]).length())
			_frame(canvas, body, int(layer.first) + index, base * Transform2D(angle, scale, 0.0, Vector2(m[4], m[5])))
	if not art.has("turret"):
		canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
		return
	var turret: Dictionary = art.turret
	var turret_swf: Dictionary = _swf(turret)
	if turret_swf.is_empty():
		var xml: Dictionary = _xml(turret)
		var total: int = turret.data.frames.size()
		var interval: int = int(xml.get("b", turret.data.get("timeline", {}).get("ticks_per_frame", 0)))
		var index: int = 0
		if interval > 0 and total > 1 and int(xml.get("d", 0)) == 1:
			index = int(time * 24.0 / interval) % total
		var fixed: int = int(xml.get("e", 0))
		_frame(canvas, turret, index, base * Transform2D(deg_to_rad(fixed) if fixed != 0 else angle, Vector2.ZERO))
	else:
		var segment: Dictionary = turret_swf.idle
		var m: Array = segment.matrix
		var local: Transform2D = Transform2D(Vector2(m[0], m[1]), Vector2(m[2], m[3]), Vector2(m[4], m[5]))
		_frame(canvas, turret, int(segment.first) + int(time * 24.0) % maxi(1, int(segment.count)), base * Transform2D(angle, Vector2.ZERO) * local)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
