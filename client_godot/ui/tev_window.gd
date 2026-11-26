extends "flash_screen.gd"







const ArenaAtlas = preload("arena_atlas.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const AppSession = preload("res://net/app_session.gd")
const PopQueue = preload("pop_queue.gd")
const TICK: float = 0.04
const DIM: Color = Color(0, 0, 0, 0.4)
const NONE: Color = Color(0, 0, 0, 0)
const SHADOW: Color = Color("06325a")

var hub: Control
var opened: bool = false
var fetch_hook: Callable
var art_dir: String = ""
var art_files: Array = []
var art_more: Array = []
var sheets: Dictionary = {}
var win_size: Vector2 = Vector2(880, 580)
var tick: int = 0
var loading: bool = false
var action: String = ""
var _http: HTTPRequest
var _acc: float = 0.0
var _fx: Array = []
var _tips: Array = []
var _ctip: CTip = CTip.new()
var _mouse: Vector2 = Vector2(-1, -1)
var _art_asked: bool = false
var _arrived: Dictionary = {}
var rules_on: bool = false

func _setup() -> void :
	visible = false
	if pack != null:
		pack.picture_ready.connect( func(path: String) -> void :
			if not art_dir.is_empty() and path.begins_with(art_dir):
				_arrived[path] = true)
	_use(ArenaAtlas.FILE, {"public_button_close": ArenaAtlas.R["public_button_close"]})




func frame_at() -> Vector2:
	return _stage() + Vector2(float(int((1000.0 - win_size.x) / 2.0)), float(int((600.0 - win_size.y) / 2.0)))



var holds_popups: bool = true

func show_window() -> void :
	opened = true
	visible = true
	if holds_popups:
		PopQueue.hold_enter(self)
	_acc = 0.0
	_fx.clear()

func hide_window() -> void :
	opened = false
	visible = false
	PopQueue.hold_leave(self)
	rules_on = false
	_fx.clear()
	_tips.clear()
	_hover = ""
	_press = ""

func _tick(delta: float) -> void :
	if not opened:
		return
	_acc += delta
	var steps: int = 0
	while _acc >= TICK and steps < 5:
		_acc -= TICK
		steps += 1
		tick += 1
		_fx_tick()
		_anim()
		if not opened:
			return
	if steps == 5:
		_acc = 0.0


func _anim() -> void :
	pass

func _paint() -> void :
	if not opened:
		return
	_tips.clear()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = frame_at()
	_hit("panel", Rect2(at * _f, win_size * _f), false)
	_body(at)
	_draw_fx(at, "fx")
	_chrome(at)
	_draw_tips()
	if rules_on:
		_rules_panel(at)


func _body(_at: Vector2) -> void :
	pass

func _chrome(_at: Vector2) -> void :
	pass


func _native_close(at: Vector2) -> void :
	var cell: Vector2 = _cell_size("public_button_close")
	_fbutton("close", "public_button_close", at + Vector2(win_size.x - 20.0 - cell.x, 40.0))




func rules_text() -> String:
	return ""

func rules_title() -> String:
	return "LUẬT CHƠI"


func rules_button(centre: Vector2, radius: float = 15.0) -> void :
	var down: bool = _press == "rules" and _hover == "rules"
	var lit: bool = _hover == "rules" and _press.is_empty() and not _mobile
	var c: Vector2 = centre + Vector2(0, 1.0 if down else 0.0)
	draw_circle((c + Vector2(0, 2)) * _f, radius * _f, Color(0, 0, 0, 0.3), true, -1.0, true)
	draw_circle(c * _f, radius * _f, Color("7a3e0c"), true, -1.0, true)
	draw_circle(c * _f, (radius - 2.5) * _f, Color("ffd84a") if lit else Color("ffc21f"), true, -1.0, true)
	draw_circle((c - Vector2(0, radius * 0.4)) * _f, radius * 0.45 * _f, Color(1, 1, 1, 0.3), true, -1.0, true)
	_fwords("?", ARIAL_BOLD, radius * 1.3, Color("6b3a10"), "c", c - Vector2(radius, radius), radius * 2.0, 0.0, radius * 2.0, false)
	var pad: float = radius + 4.0
	_hit("rules", Rect2((centre - Vector2(pad, pad)) * _f, Vector2(pad, pad) * 2.0 * _f), false)


func rules_click(id: String) -> bool:
	if id == "rules":
		rules_on = not rules_text().is_empty()
	elif id == "rules_off":
		rules_on = false
	else:
		return false
	queue_redraw()
	return true


func _rules_panel(at: Vector2) -> void :
	var text: String = rules_text()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.45))
	_hit("rules_off", Rect2(Vector2.ZERO, size), false)
	var wide: float = minf(560.0, win_size.x - 40.0)
	var most: float = minf(win_size.y - 20.0, _fh - 20.0) - 92.0
	var face: Font = _face(ARIAL)
	var px: float = 14.0
	var body: float = 0.0
	while true:
		body = face.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, (wide - 40.0) * _f, maxi(6, roundi(px * _f))).y / _f
		if body <= most or px <= 11.0:
			break
		px -= 0.5
	var high: float = 92.0 + minf(body, most)
	var box: Vector2 = at + Vector2(float(int((win_size.x - wide) / 2.0)), float(int((win_size.y - high) / 2.0)))
	_round(Rect2(box * _f, Vector2(wide, high) * _f), Color("10213f", 0.97), 14.0, Color("ffc21f", 0.9), 2.0)
	_fwords(rules_title(), ARIAL_BOLD, 18.0, Color("ffd84a"), "c", box + Vector2(0, 10), wide, 1.0, 30.0, true, Color("3a1a00"))
	draw_line((box + Vector2(24, 46)) * _f, (box + Vector2(wide - 24.0, 46)) * _f, Color("ffc21f", 0.45), maxf(1.0, _f))
	_fpara(text, ARIAL, px, Color.WHITE, box + Vector2(20, 54), wide - 40.0)
	_fwords("Chạm bất kỳ đâu để đóng", ARIAL, 12.0, Color(1, 1, 1, 0.6), "c", box + Vector2(0, high - 30.0), wide, 0.0, 22.0)


func _wait_panel(at: Vector2, failed: bool) -> void :
	_round(Rect2((at + Vector2(0, 30)) * _f, Vector2(win_size.x, win_size.y - 30.0) * _f), Color(SHADOW, 0.96), 12.0, Color(1, 1, 1, 0.35), 1.0)
	_dbtext(at + Vector2(0, float(int(win_size.y / 2.0)) - 15.0), win_size.x, 30.0, 14.0, Color.WHITE, NONE, "center", 
		"Không tải được giao diện, hãy thử lại." if failed else "Đang tải...")

func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		_mouse = event.position if _tip_ok() else Vector2(-1, -1)
	elif _mobile and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_mouse = event.position
	super (event)

func _shown() -> void :
	_mouse = Vector2(-1, -1)



func art_path(name: String) -> String:
	return art_dir + name + ".webp"

func load_art() -> void :
	if _art_asked or pack == null:
		return
	_art_asked = true
	for name: String in art_files + art_more:
		pack.picture(art_path(name))


func art_pending() -> int:
	if not _art_asked:
		return -1
	var waiting: int = 0
	for name: String in art_files:
		var path: String = art_path(name)
		if not _arrived.has(path) and not (pack._pictures.get(path) is Texture2D):
			waiting += 1
	return waiting


func retry_art() -> void :
	if art_pending() != 0 or art("fw_bg") != null:
		return
	for name: String in art_files + art_more:
		var path: String = art_path(name)
		if not (pack._pictures.get(path) is Texture2D):
			pack._pictures.erase(path)
			_arrived.erase(path)
	_art_asked = false

func art(name: String) -> Texture2D:
	if pack == null:
		return null
	var found: Variant = pack._pictures.get(art_path(name))
	var texture: Texture2D = found if found is Texture2D else null
	if texture == null or texture.get_width() < 4 or texture.get_height() < 4:
		return null
	return texture

func art_size(name: String) -> Vector2:
	var texture: Texture2D = art(name)
	if texture == null:
		return Vector2.ZERO
	if sheets.has(name):
		return Vector2(float(sheets[name][0]), float(sheets[name][1]))
	return Vector2(texture.get_size())


func sheet_region(name: String, frame: int) -> Rect2:
	var row: Array = sheets[name]
	var cols: int = maxi(1, int(row[2]))
	var count: int = maxi(1, int(row[3]))
	var index: int = clampi(frame, 0, count - 1)
	return Rect2(float(index % cols) * float(row[0]), float(index / cols) * float(row[1]), float(row[0]), float(row[1]))


func pic(name: String, at: Vector2, alpha: float = 1.0, tint: Color = Color.WHITE) -> Rect2:
	var texture: Texture2D = art(name)
	if texture == null:
		return Rect2(at * _f, Vector2.ZERO)
	var rect: Rect2 = Rect2(at * _f, Vector2(texture.get_size()) * _f)
	draw_texture_rect(texture, rect, false, Color(tint, tint.a * alpha))
	return rect


func pic_c(name: String, centre: Vector2, alpha: float = 1.0) -> void :
	var texture: Texture2D = art(name)
	if texture != null:
		pic(name, centre - Vector2(float(int(texture.get_width() / 2)), float(int(texture.get_height() / 2))), alpha)


func sheet(name: String, frame: int, at: Vector2, alpha: float = 1.0, tint: Color = Color.WHITE) -> Rect2:
	var texture: Texture2D = art(name)
	var cell: Vector2 = Vector2(float(sheets[name][0]), float(sheets[name][1])) if sheets.has(name) else Vector2.ZERO
	var rect: Rect2 = Rect2(at * _f, cell * _f)
	if texture != null and sheets.has(name):
		draw_texture_rect_region(texture, rect, sheet_region(name, frame), Color(tint, tint.a * alpha))
	return rect



func art_button(id: String, name: String, at: Vector2, state: int, frame_override: int = -1) -> Array:
	var frame: int = 3 if state < 0 else 0
	if state == 1:
		frame = 2 if _press == id else (1 if _hover == id and _press.is_empty() else 0)
	if frame_override >= 0:
		frame = frame_override
	var rect: Rect2 = sheet(name, frame, at, 0.75 if state == 0 else 1.0)
	if state == 1:
		_hit(id, rect, false)
	return [rect, frame]




func _dbtext(at: Vector2, w: float, h: float, px: float, color: Color, glow: Color, align: String, text: String) -> float:
	var y: float = at.y + float(int((h - px * 1.2 - 4.0) / 2.0))
	var x: float = at.x + (2.0 if align == "left" else (-2.0 if align == "right" else 0.0))
	return _fwords(text, ARIAL_BOLD, px, color, align.substr(0, 1), Vector2(x, y), w, 2.0 if glow.a > 0.0 else 0.0, 0.0, false, glow)


func text_width(text: String, px: float) -> float:
	return ARIAL_BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f


func _para_c(at: Vector2, w: float, h: float, px: float, color: Color, text: String) -> void :
	var font_size: int = maxi(6, roundi(px * _f))
	var wide: float = maxf(1.0, (w - 4.0) * _f)
	var high: float = ARIAL_BOLD.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, wide, font_size).y / _f
	var top: float = at.y + float(int((h - (high + 6.0)) / 2.0))
	draw_multiline_string(ARIAL_BOLD, Vector2(at.x + 2.0, top + 2.0) * _f + Vector2(0, ARIAL_BOLD.get_ascent(font_size)), text, 
		HORIZONTAL_ALIGNMENT_CENTER, wide, font_size, -1, color)


func item(id: int) -> Dictionary:
	var info: Variant = pack.events.get("items", {}).get(str(id))
	var row: Array = info if info is Array and (info as Array).size() >= 4 else []
	if row.is_empty():
		var other: Variant = pack.quest.get("items", {}).get(str(id))
		row = other if other is Array and (other as Array).size() >= 3 else []
	var found: Variant = pack.bag.get("items", {}).get(str(id))
	var more: Array = found if found is Array else []
	var title: String = ""
	if not more.is_empty() and not str(more[0]).is_empty():
		title = BagModel.clean(str(more[0]))
	elif not row.is_empty() and not str(row[0]).is_empty():
		title = str(row[0])
	var icon: String = str(row[1]) if row.size() > 1 and not str(row[1]).is_empty() else (str(more[2]) if more.size() > 2 else "")
	var quality: int = int(row[2]) if row.size() > 2 else (int(more[3]) if more.size() > 3 else 0)
	var head: bool = (row.size() > 3 and int(row[3]) == 1) or (more.size() > 5 and int(more[5]) == 4)
	var path: String = ""
	if not icon.is_empty():
		path = ("l/av/" if head else "l/it/") + icon + ".webp"
	return {"id": id, "name": title, "art": path, "quality": quality, 
		"desc": GarageModel.plain(str(more[1])) if more.size() >= 10 else ""}


func item_name(id: int) -> String:
	return str(item(id)["name"])


func icon(id: int, side: float, centre: Vector2, alpha: float = 1.0, scale: float = 1.0) -> bool:
	var path: String = str(item(id)["art"])
	var texture: Texture2D = pack.picture(path) if not path.is_empty() else null
	if texture == null:
		return false
	var k: float = minf(side / maxf(1.0, float(texture.get_width())), side / maxf(1.0, float(texture.get_height()))) * scale
	var shown: Vector2 = Vector2(texture.get_size()) * k
	draw_texture_rect(texture, Rect2((centre - shown / 2.0) * _f, shown * _f), false, Color(1, 1, 1, alpha))
	return true


func tip_area(rect: Rect2, id: int, text: String) -> void :
	var area: Rect2 = Rect2(rect.position * _f, rect.size * _f)
	if id > 0:

		var info: Dictionary = item(id)
		var extra: Dictionary = {}
		if not (pack.bag.get("items", {}) as Dictionary).has(str(id)):
			extra = {"name": str(info["name"]), "quality": int(info["quality"]), "desc": str(info["desc"])}
			if not str(info["art"]).is_empty():
				extra["art"] = str(info["art"])
				extra["icon"] = str(info["art"])
		_tips.append([area, "", "", Color.WHITE, FlashTip.simulate(id, pack.bag, extra)])
	elif not text.is_empty():
		_tips.append([area, text, "", Color.WHITE])

func _draw_tips() -> void :
	var hit: Array = []
	if _tip_ok() and _hover == "panel" and _press.is_empty():
		for i in range(_tips.size() - 1, -1, -1):
			if (_tips[i][0] as Rect2).has_point(_mouse):
				hit = _tips[i]
				break
	if not FlashTip.show(self, hit, _ctip):
		_tip_box(hit[0], str(hit[1]), str(hit[2]), hit[3])


func _tip_box(anchor: Rect2, title: String, body: String, color: Color) -> void :
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 14).y / _f if not body.is_empty() else 0.0
	var head: float = 26.0 if not title.is_empty() else 6.0
	var high: float = head + body_h + 8.0 + (4.0 if title.is_empty() else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	if not title.is_empty():
		_fwords(title, ARIAL_BOLD, 13.0, color, "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, ARIAL, 12.0, Color.WHITE, at + Vector2(10, head), wide - 20.0, 14)


func tip(text: String) -> void :
	if text.is_empty():
		return
	if opened or hub == null:
		say(text)
	else:
		hub.call("say", text)





func fx_add(kind: String, name: String, at: Vector2, opt: Dictionary = {}) -> Dictionary:
	var frames: int = int(sheets[name][3]) if kind == "sheet" and sheets.has(name) else 0
	var fx: Dictionary = {
		"kind": kind, "name": name, "id": int(opt.get("id", 0)), "side": float(opt.get("side", 0.0)), 
		"x": at.x, "y": at.y, "fromX": at.x, "fromY": at.y, 
		"f": int(opt.get("f", 0)) % maxi(1, frames), "tpf": maxi(1, int(opt.get("tpf", 1))), "t": 0, 
		"hold": int(opt.get("hold", -1)), "holdT": int(opt.get("holdT", 0)), "loop": float(opt.get("loop", 0)) > 0.0, 
		"still": frames == 0 or float(opt.get("still", 0)) > 0.0, 
		"vx": float(opt.get("vx", 0.0)), "vy": float(opt.get("vy", 0.0)), "g": float(opt.get("g", 0.0)), "vr": float(opt.get("vr", 0.0)), 
		"tx": float(opt.get("tx", -9999.0)), "ty": float(opt.get("ty", -9999.0)), "ts": float(opt.get("ts", 1.0)), 
		"scale": 1.0, "rot": 0.0, "alpha": float(opt.get("alpha", 1.0)), "fade": int(opt.get("fade", 0)), "age": 0, 
		"layer": str(opt.get("layer", "fx")), 
	}
	var default_life: int = 30 if fx["loop"] or fx["still"] else (frames - int(fx["f"])) * int(fx["tpf"]) + int(fx["holdT"]) + 1
	fx["life"] = int(opt.get("life", default_life))
	_fx.append(fx)
	return fx

func _fx_tick() -> void :
	var keep: Array = []
	for fx: Dictionary in _fx:
		fx["age"] = int(fx["age"]) + 1
		if not fx["still"]:
			if int(fx["f"]) == int(fx["hold"]) and int(fx["holdT"]) > 0:
				fx["holdT"] = int(fx["holdT"]) - 1
			else:
				fx["t"] = int(fx["t"]) + 1
				if int(fx["t"]) >= int(fx["tpf"]):
					fx["t"] = 0
					var frames: int = int(sheets[fx["name"]][3]) if sheets.has(fx["name"]) else 1
					if int(fx["f"]) + 1 < frames:
						fx["f"] = int(fx["f"]) + 1
					elif fx["loop"]:
						fx["f"] = 0
		if float(fx["tx"]) > -9999.0:
			var k: float = minf(1.0, float(fx["age"]) / maxf(1.0, float(fx["life"])))
			k = 1.0 - (1.0 - k) * (1.0 - k)
			fx["x"] = float(fx["fromX"]) + (float(fx["tx"]) - float(fx["fromX"])) * k
			fx["y"] = float(fx["fromY"]) + (float(fx["ty"]) - float(fx["fromY"])) * k
			fx["scale"] = 1.0 + (float(fx["ts"]) - 1.0) * k
		else:
			fx["vy"] = float(fx["vy"]) + float(fx["g"])
			fx["x"] = float(fx["x"]) + float(fx["vx"])
			fx["y"] = float(fx["y"]) + float(fx["vy"])
		fx["rot"] = float(fx["rot"]) + float(fx["vr"])
		var rest: int = int(fx["life"]) - int(fx["age"])
		if int(fx["fade"]) > 0 and rest < int(fx["fade"]):
			fx["alpha"] = maxf(0.0, float(rest) / float(fx["fade"]))
		if rest > 0:
			keep.append(fx)
	_fx = keep


func fx_drop(layer: String) -> void :
	_fx = _fx.filter( func(fx: Dictionary) -> bool: return str(fx["layer"]) != layer)

func _draw_fx(at: Vector2, layer: String) -> void :
	for fx: Dictionary in _fx:
		if str(fx["layer"]) != layer:
			continue
		var centre: Vector2 = (at + Vector2(float(fx["x"]), float(fx["y"]))) * _f
		var alpha: float = float(fx["alpha"])
		var scale: float = float(fx["scale"])
		draw_set_transform(centre, deg_to_rad(float(fx["rot"])), Vector2(scale, scale))
		match str(fx["kind"]):
			"sheet":
				var name: String = str(fx["name"])
				var texture: Texture2D = art(name)
				if texture != null and sheets.has(name):
					var cell: Vector2 = Vector2(float(sheets[name][0]), float(sheets[name][1]))
					var corner: Vector2 = - Vector2(float(int(cell.x / 2.0)), float(int(cell.y / 2.0)))
					draw_texture_rect_region(texture, Rect2(corner * _f, cell * _f), sheet_region(name, int(fx["f"])), Color(1, 1, 1, alpha))
			"pic":
				var texture: Texture2D = art(str(fx["name"]))
				if texture != null:
					var corner: Vector2 = Vector2(fx.get("dx", - float(int(texture.get_width() / 2))), fx.get("dy", - float(int(texture.get_height() / 2))))
					draw_texture_rect(texture, Rect2(corner * _f, Vector2(texture.get_size()) * _f), false, Color(1, 1, 1, alpha))
			"icon":
				var path: String = str(item(int(fx["id"]))["art"])
				var texture: Texture2D = pack.picture(path) if not path.is_empty() else null
				if texture != null:
					var side: float = float(fx["side"])
					var k: float = minf(side / maxf(1.0, float(texture.get_width())), side / maxf(1.0, float(texture.get_height())))
					var shown: Vector2 = Vector2(texture.get_size()) * k
					draw_texture_rect(texture, Rect2( - shown / 2.0 * _f, shown * _f), false, Color(1, 1, 1, alpha))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func fx_burst(name: String, at: Vector2, tpf: int) -> void :
	if art(name) != null and sheets.has(name):
		fx_add("sheet", name, at, {"tpf": tpf})


func fx_sparkles(name: String, at: Vector2, count: int) -> void :
	if art(name) == null or not sheets.has(name):
		return
	for i in count:
		fx_add("sheet", name, at + Vector2((randf() - 0.5) * 60.0, (randf() - 0.5) * 44.0), {"tpf": 2, "vy": -0.6})


func fx_pop_item(id: int, at: Vector2) -> void :
	fx_add("icon", "", at, {"id": id, "side": 56.0, "tx": at.x, "ty": at.y - 74.0, "ts": 1.35, "life": 36, "fade": 12})


func fx_fly(name: String, from: Vector2, to: Vector2, order: int) -> void :
	if art(name) == null:
		return
	fx_add("pic", name, from + Vector2((randf() - 0.5) * 30.0, (randf() - 0.5) * 20.0), 
		{"tx": to.x, "ty": to.y, "ts": 0.8, "life": 18 + order * 3, "fade": 4})




func fetch(url: String, what: String) -> void :
	if _http != null:
		_http.cancel_request()
	action = what
	loading = true
	if fetch_hook.is_valid():
		fetch_hook.call(url)
		return
	if client == null or client.config == null or client.config.local_test_only or str(client.config.origin).is_empty():
		loading = false
		action = ""
		return
	if _http == null:
		_http = HTTPRequest.new()
		_http.timeout = 10.0
		_http.accept_gzip = false
		add_child(_http)
		_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
			arrived(code if result == HTTPRequest.RESULT_SUCCESS else 0, body.get_string_from_utf8()))
	var full: String = str(client.config.origin) + url

	if _http.request(full, AppSession.headers(full)) != OK:
		loading = false
		action = ""


func arrived(code: int, text: String) -> void :
	if not loading:
		return
	loading = false
	var what: String = action
	action = ""
	if code == 200:
		_reply(text, what)
	else:
		_failed(what)

func _reply(_text: String, _what: String) -> void :
	pass

func _failed(_what: String) -> void :
	pass



static func parse_xml(text: String) -> Variant:
	var tags: RegEx = RegEx.create_from_string("<!--[\\s\\S]*?-->|<\\?[\\s\\S]*?\\?>|<!\\[CDATA\\[[\\s\\S]*?\\]\\]>|<!DOCTYPE[^>]*>|<(/?)([A-Za-z_][\\w.:-]*)((?:\\s+[A-Za-z_][\\w.:-]*\\s*=\\s*(?:\"[^\"]*\"|'[^']*'))*)\\s*(/?)>")
	var attrs: RegEx = RegEx.create_from_string("([A-Za-z_][\\w.:-]*)\\s*=\\s*(?:\"([^\"]*)\"|'([^']*)')")
	var root: Dictionary = {}
	var stack: Array = []
	var ended: bool = false
	var cursor: int = 0
	for found: RegExMatch in tags.search_all(text):
		var gap: String = text.substr(cursor, found.get_start() - cursor)
		cursor = found.get_end()
		if gap.contains("<") or (ended and not gap.strip_edges().is_empty()):
			return null
		if found.get_string(2).is_empty():
			continue
		var name: String = found.get_string(2)
		if found.get_string(1) == "/":
			if stack.is_empty() or str(stack.back()) != name:
				return null
			stack.pop_back()
			if stack.is_empty():
				ended = true
			continue
		if ended:
			return null
		var node: Dictionary = {"tag": name, "at": {}, "kids": []}
		for pair: RegExMatch in attrs.search_all(found.get_string(3)):
			var value: String = pair.get_string(2) if pair.get_start(2) >= 0 else pair.get_string(3)
			node["at"][pair.get_string(1)] = unescape(value)
		if root.is_empty():
			root = node
		elif stack.size() == 1:
			(root["kids"] as Array).append(node)
		if found.get_string(4) == "/":
			if stack.is_empty():
				ended = true
		else:
			stack.append(name)
	var tail: String = text.substr(cursor)
	if root.is_empty() or not stack.is_empty() or tail.contains("<") or not tail.strip_edges().is_empty():
		return null
	return root


static func unescape(text: String) -> String:
	if not text.contains("&"):
		return text
	var named: Dictionary = {"amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'"}
	var pattern: RegEx = RegEx.create_from_string("&(#x[0-9A-Fa-f]+|#[0-9]+|amp|lt|gt|quot|apos);")
	var out: String = ""
	var cursor: int = 0
	for found: RegExMatch in pattern.search_all(text):
		out += text.substr(cursor, found.get_start() - cursor)
		var key: String = found.get_string(1)
		if key.begins_with("#x"):
			out += char(key.substr(2).hex_to_int())
		elif key.begins_with("#"):
			out += char(key.substr(1).to_int())
		else:
			out += str(named[key])
		cursor = found.get_end()
	return out + text.substr(cursor)


static func kids(node: Dictionary, tag: String) -> Array:
	var out: Array = []
	for kid: Dictionary in node.get("kids", []):
		if str(kid["tag"]) == tag:
			out.append(kid)
	return out




static func num(value: int) -> String:
	var digits: String = str(absi(value))
	var out: String = ""
	var i: int = digits.length()
	while i > 3:
		out = "." + digits.substr(i - 3, 3) + out
		i -= 3
	out = digits.substr(0, i) + out
	return "-" + out if value < 0 else out


static func left_text(end_at: float, now: float) -> String:
	var secs: int = maxi(0, ceili((end_at - now) / 1000.0))
	var days: int = secs / 86400
	if days > 0:
		return "%d ngày %02d:%02d" % [days, (secs % 86400) / 3600, (secs % 3600) / 60]
	return "%02d:%02d:%02d" % [secs / 3600, (secs % 3600) / 60, secs % 60]


static func percent(value: float) -> String:
	if value <= 0.0:
		return "—"
	var shown: float = roundf(value * 100.0) / 100.0 if value < 0.1 else roundf(value * 10.0) / 10.0
	return String.num(shown, 2).replace(".", ",") + "%"


static func items_of(text: String) -> Array:
	var out: Array = []
	for part: String in text.split(","):
		var cut: int = part.find(":")
		if cut > 0 and part.substr(0, cut).to_int() > 0:
			out.append({"id": part.substr(0, cut).to_int(), "n": maxi(1, part.substr(cut + 1).to_int())})
	return out
