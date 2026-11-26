extends "flash_screen.gd"
























const Film = preload("achieve_film.gd")
const PopQueue = preload("pop_queue.gd")
const GarageModel = preload("garage_model.gd")
const GarSkin = preload("gar_skin_atlas.gd")
const Garage = preload("garage.gd")
const TankPortrait = preload("tank_portrait.gd")
const TankPreview = preload("tank_preview.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")

const TANK_ID: String = "tank_achieve"
const SKIN_ID: String = "skin_achieve"
const DIM: Color = Color(0, 0, 0, 153 / 255.0)
const SOUND: String = "u/ui_gettank"
const SHOW_IN: Array = ["lobby", "hall", "room"]
const LOAD_WAIT: float = 4.0
const SOUND_WAIT: float = 2.0
const BLUR_COPIES: int = 5
const BLUR_ALPHA: float = 0.85
const NAME_GLOW: Color = Color("0066a9")
const ATTR_INK: Color = Color("ffff00")
const ICON: float = 50.0
const AVATAR: Vector2 = Vector2(100, 100)

const QUALITY_INK: Dictionary = {0: "ffffff", 1: "ffffff", 2: "15ee19", 3: "06fffc", 4: "ff6eff"}
const QUALITY_TOP: String = "f18819"

signal closed

var queue: PopQueue
var kind: String = ""
var tank: Dictionary = {}
var skin: Array = []
var skin_tank: int = 0
var _film: Dictionary = {}
var _clock: float = 0.0
var _waited: float = 0.0
var _rolling: bool = false
var _sound_due: bool = false
var _sound_waited: float = 0.0
var _groups: Dictionary = {}
var _shade: Control
var _tip: Array = []
var _ctip: CTip = CTip.new()

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	_shade = _canvas(false)
	_shade.draw.connect( func() -> void :
		if not kind.is_empty():
			_shade.draw_rect(Rect2(Vector2.ZERO, size), DIM))
	_groups = {"tank": _build("tank"), "skin": _build("skin")}
	if queue == null:
		queue = PopQueue.new()
		queue.client = client
		add_child(queue)
	queue.register(TANK_ID, _open_tank)
	queue.register(SKIN_ID, _open_skin)
	if client != null:
		client.tank_achieved.connect(notice_tank)
		client.skin_achieved.connect(notice_skin)
		client.changed.connect(_pump)


func _canvas(add: bool) -> Control:
	var canvas: Control = Control.new()
	canvas.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.show_behind_parent = true
	canvas.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if add:
		var mat: CanvasItemMaterial = CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		canvas.material = mat
	add_child(canvas)
	return canvas




func _build(which: String) -> Array:
	var film: Dictionary = film_of(which)
	var groups: Array = []
	var layers: Array = film["layers"]
	for i in range(layers.size()):
		var layer: Dictionary = layers[i]
		var parts: Array = []
		if str(layer["kind"]) == "spin":
			if not str(layer["key"]).is_empty():
				parts.append([i, "a", bool(layer.get("add", false))])
			parts.append([i, "turn", bool(layer.get("turn_add", false))])
		elif layer.has("adds"):
			parts.append([i, "", false, "n"])
			parts.append([i, "", true, "a"])
		else:
			parts.append([i, "", bool(layer.get("add", false))])
		for part: Array in parts:
			var avatar: bool = str(layer["kind"]) == "slot" and is_avatar(str(layer["name"]))
			var add: bool = bool(part[2])
			if avatar or groups.is_empty() or bool(groups[-1][1]) != add or bool(groups[-1][2]):
				var canvas: Control = _canvas(add)
				var group: Array = [canvas, add, avatar, []]
				canvas.draw.connect(_paint_group.bind(which, group))
				groups.append(group)
			(groups[-1][3] as Array).append([int(part[0]), str(part[1]), str(part[3]) if part.size() > 3 else ""])
	return groups

static func film_of(which: String) -> Dictionary:
	return Film.TANK if which == "tank" else Film.SKIN

static func is_avatar(slot: String) -> bool:
	return slot in ["cvs_tank", "cvs_tankFX", "cvs_oldtank", "cvs_newtank01", "cvs_newtank02"]




func notice_tank(value: Dictionary) -> void :
	if value.is_empty() or kind == "tank" or queue.has(TANK_ID):
		return
	queue.append(TANK_ID, value.duplicate())


func notice_skin(item: int) -> void :
	if item > 0:
		queue.append(SKIN_ID, item)

func _open_tank(value: Variant) -> bool:
	if not value is Dictionary or int((value as Dictionary).get("m_tpltId", 0)) <= 0:
		return false
	tank = value
	_start("tank", Film.TANK)
	return true


func _open_skin(value: Variant) -> bool:
	var found: Array = skin_row(int(value))
	if found.is_empty():
		return false
	skin_tank = int(found[0])
	skin = found[1]
	_start("skin", Film.SKIN)
	return true


static func skin_row(item: int) -> Array:
	for key: String in GarSkin.SKINS:
		for row: Array in GarSkin.SKINS[key]:
			if int(row[0]) == item:
				return [int(key), row]
	return []

func _start(which: String, film: Dictionary) -> void :
	kind = which
	_film = film
	_clock = 0.0
	_waited = 0.0
	_rolling = false
	_sound_due = true
	_sound_waited = 0.0
	_loaded()
	_pump()


func _pump() -> void :
	if client == null:
		return
	if client.state not in SHOW_IN and client.state != "battle":
		kind = ""
		_sound_due = false
	var want: bool = not kind.is_empty() and client.state in SHOW_IN
	if visible != want:
		visible = want

func close() -> void :
	if kind.is_empty():
		return
	kind = ""
	_sound_due = false
	visible = false
	_redraw_all()
	closed.emit()
	queue.closed()


func tick() -> int:
	return floori(_clock * Film.FPS) if _rolling else -1


static func shown(film: Dictionary, at: int) -> int:
	var count: int = int(film["count"])
	var loop: int = int(film["loop"])
	if at < count:
		return at
	if loop >= 0:
		return loop + posmod(at - count, count - loop)
	return count - 1

func frame() -> int:
	var at: int = tick()
	return shown(_film, at) if at >= 0 else -1


func can_close() -> bool:
	var at: int = frame()
	return not kind.is_empty() and at >= 0 and float(_film["button"][at]) >= 1.0


func _loaded() -> bool:
	if pack == null:
		return true
	pack.load_garage()
	pack.load_garagex()
	pack.load_tips()
	var done: bool = not pack.garage.is_empty() and (kind != "skin" or not pack.garagex.is_empty())
	for layer: Dictionary in _film.get("layers", []):
		for key: String in [str(layer.get("key", "")), str(layer.get("turn", ""))]:
			if not key.is_empty() and pack.effect(key).is_empty() and not pack.effect_failed(key):
				done = false
	return done

func _tick(delta: float) -> void :
	if kind.is_empty():
		return
	if _sound_due:
		_sound_waited += delta
		if pack != null and pack.sound("s/%s.mp3" % SOUND) != null:
			_sound_due = false
			Sound.play(SOUND)
		elif _sound_waited > SOUND_WAIT:
			_sound_due = false
	if not _rolling:
		_waited += delta
		_rolling = _loaded() or _waited >= LOAD_WAIT
	else:
		_clock += delta
	_redraw_all()

func _redraw_all() -> void :
	if _shade != null:
		_shade.queue_redraw()
	for which: String in _groups:
		for group: Array in _groups[which]:
			(group[0] as Control).queue_redraw()




func _paint() -> void :
	_tip = []
	if kind.is_empty():
		return
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: int = frame()
	if at < 0 or kind != "tank" or _mobile:
		FlashTip.show(self, _tip, _ctip)
		return
	var mouse: Vector2 = get_local_mouse_position()
	var origin: Transform2D = _origin()
	var ids: Array = skill_ids()
	for layer: Dictionary in _film["layers"]:
		if str(layer["kind"]) != "slot" or not str(layer["name"]).begins_with("cvs_jineng"):
			continue
		var index: int = int(str(layer["name"]).right(2)) - 1
		var row: Array = layer["rows"][at]
		if row.is_empty() or index < 0 or index >= ids.size() or int(ids[index]) <= 0 or float(row[9]) <= 0.01:
			continue
		var rect: Rect2 = (origin * flash_matrix(row)) * Rect2(Vector2.ZERO, Vector2(ICON, ICON))
		if rect.has_point(mouse):
			_tip = [rect, "", "", Color.WHITE, {"skill": int(ids[index])}]
	FlashTip.show(self, _tip, _ctip)


func _origin() -> Transform2D:
	var stage: Vector2 = _film["stage"]
	return Transform2D(0.0, Vector2(_f, _f), 0.0, (_stage() + Film.MOVIE_CENTER - stage / 2.0) * _f)

func _paint_group(which: String, group: Array) -> void :
	var canvas: Control = group[0]
	if which != kind or pack == null or client == null:
		return
	var film: Dictionary = _film
	_metrics()
	var at: int = tick()
	if at < 0:
		return
	var now: int = shown(film, at)
	var origin: Transform2D = _origin()
	for part: Array in group[3]:
		var layer: Dictionary = film["layers"][int(part[0])]
		if not str(part[2]).is_empty() and bool(layer["adds"][now]) != (str(part[2]) == "a"):
			continue
		match str(layer["kind"]):
			"band":
				if now >= int(layer["lo"]) and now <= int(layer["hi"]):
					_put(canvas, pack.effect(str(layer["key"])), now - int(layer["lo"]), origin, Color.WHITE, Vector2.ZERO)
			"anim":
				var row: Array = layer["rows"][now]
				if not row.is_empty():
					_put(canvas, pack.effect(str(layer["key"])), posmod(at - int(layer["born"]), int(layer["period"])), origin * flash_matrix(row), tint(row), _blur(row))
			"spin":
				var row: Array = layer["rows"][now]
				if row.is_empty():
					continue
				var place: Transform2D = origin * flash_matrix(row)
				if str(part[1]) == "a":
					_put(canvas, pack.effect(str(layer["key"])), 0, place, tint(row), _blur(row))
				else:
					var spin: Array = layer["spin"]
					var turn: Transform2D = flash_matrix(layer["inner"]) * flash_matrix(spin[posmod(at - int(layer["born"]), spin.size())])\
					* flash_matrix(spin[0]).affine_inverse() * flash_matrix(layer["bake"]).affine_inverse()
					_put(canvas, pack.effect(str(layer["turn"])), 0, place * turn, tint(row), _blur(row))
			"slot":
				var row: Array = layer["rows"][now]
				if not row.is_empty():
					_slot(canvas, str(layer["name"]), origin * flash_matrix(row), row)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


static func flash_matrix(row: Array) -> Transform2D:
	return Transform2D(Vector2(float(row[0]), float(row[1])), Vector2(float(row[2]), float(row[3])), Vector2(float(row[4]), float(row[5])))


static func tint(row: Array) -> Color:
	return Color(float(row[6]) + float(row[10]) / 255.0, float(row[7]) + float(row[11]) / 255.0, float(row[8]) + float(row[12]) / 255.0, 
		clampf(float(row[9]) + float(row[13]) / 255.0, 0.0, 1.0))

static func _blur(row: Array) -> Vector2:
	return Vector2(float(row[14]), float(row[15])) if row.size() >= 16 else Vector2.ZERO


func _put(canvas: Control, fx: Dictionary, index: int, place: Transform2D, color: Color, blur: Vector2) -> void :
	var frames: Array = fx.get("data", {}).get("frames", [])
	var pages: Array = fx.get("pages", [])
	if index < 0 or index >= frames.size() or color.a <= 0.002:
		return
	var cell: Dictionary = frames[index]
	var page: int = int(cell.get("page", 0))
	if page >= pages.size() or pages[page] == null:
		return
	var px: float = float(fx.get("data", {}).get("px", 1.0))
	var rect: Array = cell.get("rect", [0, 0, 0, 0])
	var pivot: Array = cell.get("pivot", [0, 0])
	var src: Rect2 = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	var dst: Rect2 = Rect2( - Vector2(float(pivot[0]), float(pivot[1])) * px, src.size * px)
	canvas.draw_set_transform_matrix(place)
	if blur.x < 1.0 and blur.y < 1.0:
		canvas.draw_texture_rect_region(pages[page], dst, src, color)
		return
	color.a = 1.0 - pow(1.0 - minf(color.a, BLUR_ALPHA), 1.0 / BLUR_COPIES)
	for i in range(BLUR_COPIES):
		var shift: Vector2 = blur * (float(i) / float(BLUR_COPIES - 1) - 0.5)
		canvas.draw_texture_rect_region(pages[page], Rect2(dst.position + shift, dst.size), src, color)

func _slot(canvas: Control, name: String, place: Transform2D, row: Array) -> void :
	if is_avatar(name):
		_car(canvas, name, place, row)
	elif name.begins_with("cvs_jineng"):
		var ids: Array = skill_ids()
		var index: int = int(name.right(2)) - 1
		if index >= 0 and index < ids.size() and int(ids[index]) > 0:
			var info: Array = pack.skill_hud(int(ids[index]))
			var art: Texture2D = pack.icon("s", str(info[0])) if not info.is_empty() else null
			if art != null:
				_soft(canvas, art, Rect2(Vector2.ZERO, Vector2(ICON, ICON)), place, tint(row), _blur(row))
	elif name.begins_with("cvs_tankemingzhi"):
		_label(canvas, tank_name(), 20.0, Color.WHITE, NAME_GLOW, 3.0, place, row)
	elif name == "cvs_tankname" and not skin.is_empty():
		_label(canvas, skin_title(), 20.0, quality_ink(int(skin[2])), Color.BLACK, 1.5, place, row)
	elif name.begins_with("cvs_shuxing"):
		_label(canvas, skin_attr(), 16.0, ATTR_INK, NAME_GLOW, 3.0, place, row)

func _soft(canvas: Control, art: Texture2D, dst: Rect2, place: Transform2D, color: Color, blur: Vector2) -> void :
	if color.a <= 0.002:
		return
	canvas.draw_set_transform_matrix(place)
	if blur.x < 1.0 and blur.y < 1.0:
		canvas.draw_texture_rect(art, dst, false, color)
		return
	color.a = 1.0 - pow(1.0 - minf(color.a, BLUR_ALPHA), 1.0 / BLUR_COPIES)
	for i in range(BLUR_COPIES):
		var shift: Vector2 = blur * (float(i) / float(BLUR_COPIES - 1) - 0.5)
		canvas.draw_texture_rect(art, Rect2(dst.position + shift, dst.size), false, color)


func _label(canvas: Control, text: String, px: float, ink: Color, rim: Color, edge: float, place: Transform2D, row: Array) -> void :
	if text.is_empty():
		return
	var color: Color = ink * tint(row)
	color = Color(minf(color.r, 1.0), minf(color.g, 1.0), minf(color.b, 1.0), clampf(color.a, 0.0, 1.0))
	if color.a <= 0.002:
		return
	var font: Font = ARIAL_BOLD
	var font_size: int = maxi(6, roundi(px * _f))
	var blur: Vector2 = _blur(row)
	var copies: int = BLUR_COPIES if blur.x >= 1.0 or blur.y >= 1.0 else 1
	if copies > 1:
		color.a = 1.0 - pow(1.0 - minf(color.a, BLUR_ALPHA), 1.0 / copies)
	var wide: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var high: float = font.get_height(font_size)
	var base: Vector2 = Vector2( - wide / 2.0, - high / 2.0 + font.get_ascent(font_size))
	for i in range(copies):
		var shift: Vector2 = blur * (float(i) / float(maxi(1, copies - 1)) - 0.5) if copies > 1 else Vector2.ZERO
		canvas.draw_set_transform_matrix(place * Transform2D(0.0, Vector2(1.0 / _f, 1.0 / _f), 0.0, shift))
		canvas.draw_string_outline(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(edge * _f)), Color(rim, color.a))
		canvas.draw_string(font, base, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)



func _car(canvas: Control, name: String, place: Transform2D, row: Array) -> void :
	var color: Color = tint(row)
	if color.a <= 0.002:
		return
	var tank_id: int = int(tank.get("m_tpltId", 0)) if kind == "tank" else skin_tank
	var level: int = maxi(1, int(tank.get("m_level", 1))) if kind == "tank" else 1
	var ext: int = 0
	var halo: int = 0
	if kind == "tank":
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, level, tank)
		halo = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(tank.get("m_haloId", 0)), level)
	elif name == "cvs_oldtank":
		ext = int(client.old_skins.get(skin_tank, 0))
		if ext == 0:
			ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, 1, {})
	elif not skin.is_empty():
		ext = int(skin[1])
	var blur: Vector2 = _blur(row)
	var copies: int = BLUR_COPIES if blur.x >= 1.0 or blur.y >= 1.0 else 1
	if copies > 1:
		color.a = 1.0 - pow(1.0 - minf(color.a, BLUR_ALPHA), 1.0 / copies)
	canvas.self_modulate = color
	var face: String = GarageModel.face(pack.garage, ext)
	for i in range(copies):
		var shift: Vector2 = blur * (float(i) / float(maxi(1, copies - 1)) - 0.5) if copies > 1 else Vector2.ZERO
		var spot: Transform2D = place * Transform2D(0.0, shift)
		canvas.draw_set_transform_matrix(spot)
		if TankPortrait.draw(canvas, pack, face, halo, AVATAR, 1.0, _time):
			continue
		var art: Dictionary = pack.external_art(pack.art_external(str(ext), tank_id))
		if TankPreview.ready(art):
			var zoom: float = spot.get_scale().x
			TankPreview.draw(canvas, art, spot * (AVATAR - Vector2(0, 6)), minf(1.7, 160.0 / TankPreview.extent(art)) * zoom, 4, _time)




func tank_name() -> String:
	return GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(int(tank.get("m_tpltId", 0))), ""))) if pack != null else ""


func skill_ids() -> Array:
	if pack == null or tank.is_empty():
		return []
	var base: Array = pack.garage.get("tanks", {}).get(str(int(tank.get("m_tpltId", 0))), {}).get("skills", [0, 0, 0, 0]).duplicate()
	while base.size() < 4:
		base.append(0)
	var worn: Array = pack.garage.get("skins", {}).get(str(int(tank.get("m_externalId", 0))), [])
	for i in range(mini(4, worn.size())):
		if int(worn[i]) > 0:
			base[i] = int(worn[i])
	return [int(base[3]) if int(base[3]) > 0 else int(base[2]), int(base[0]), int(base[1])]


func skin_title() -> String:
	return skin_title_of(str(skin[3]), int(skin[2]))

static func skin_title_of(skin_name: String, rank: int) -> String:
	var grade: String = GarageModel.grade(rank)
	if grade.is_empty() or skin_name.ends_with(" " + grade):
		return skin_name + " "
	return "%s %s " % [skin_name, grade]


func skin_attr() -> String:
	if skin.is_empty() or pack == null:
		return ""
	var quality: int = int(GarSkin.EXTQ.get(str(int(skin[1])), 0))
	if quality < 2 or quality > 5:
		return ""
	return Garage.skin_type_desc(pack.garagex.get("skin", {}).get(str(skin_tank), []), quality - 1, GarSkin.BUFF)

static func quality_ink(quality: int) -> Color:
	return Color(str(QUALITY_INK.get(quality, QUALITY_TOP)))



func _activate(id: String) -> void :
	if id == "shade" and can_close():
		close()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		if can_close():
			close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
