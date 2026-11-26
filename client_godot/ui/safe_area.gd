extends RefCounted












const CORNER_DP: Vector2 = Vector2(14, 6)
static var forced: Variant = null
static var _memo_key: Array = []
static var _memo: Dictionary = {}

static func _raw() -> Dictionary:
	if forced is Dictionary:
		return forced
	if OS.has_feature("android") or OS.has_feature("ios"):
		var win: Vector2i = DisplayServer.window_get_size()
		var dp: float = DisplayServer.screen_get_scale() if OS.has_feature("ios") else (DisplayServer.screen_get_dpi() / 160.0)
		return {"safe": DisplayServer.get_display_safe_area(), "win": win, "dp": maxf(1.0, dp)}
	if OS.has_feature("web"):
		var w: Vector2i = DisplayServer.window_get_size()
		return {"safe": Rect2i(Vector2i.ZERO, w), "win": w, "dp": maxf(1.0, DisplayServer.screen_get_scale())}
	return {}


static func _state(view_size: Vector2) -> Dictionary:
	var key: Array = [Engine.get_process_frames(), view_size, forced]
	if key == _memo_key:
		return _memo
	var out: Dictionary = {"in": Vector4.ZERO, "dp": 0.0}
	var raw: Dictionary = _raw()
	var win: Vector2 = Vector2(raw.get("win", Vector2i.ZERO))
	if win.x > 0 and win.y > 0 and view_size.x > 0:
		var k: float = view_size.x / win.x
		var safe: Rect2 = Rect2(raw.get("safe", Rect2i(Vector2i.ZERO, Vector2i(win))))
		var l: float = clampf(safe.position.x, 0.0, win.x / 4.0)
		var t: float = clampf(safe.position.y, 0.0, win.y / 4.0)
		var r: float = clampf(win.x - safe.end.x, 0.0, win.x / 4.0)
		var b: float = clampf(win.y - safe.end.y, 0.0, win.y / 4.0)
		if safe.size.x <= 0 or safe.size.y <= 0:
			l = 0.0;t = 0.0;r = 0.0;b = 0.0
		out = {"in": Vector4(l, t, r, b) * k, "dp": float(raw.get("dp", 0.0)) * k}
	_memo_key = key
	_memo = out
	return out

static func inset(view_size: Vector2) -> Vector4:
	return _state(view_size)["in"]

static func corner(view_size: Vector2) -> Vector2:
	return CORNER_DP * float(_state(view_size)["dp"])


static func corner_pad(view_size: Vector2, which: String) -> Vector2:
	var e: Vector4 = inset(view_size)
	var c: Vector2 = corner(view_size)
	var side: float = e.x if which.ends_with("l") else e.z
	var edge: float = e.y if which.begins_with("t") else e.w
	return Vector2(maxf(side, c.x), maxf(edge, c.y))
