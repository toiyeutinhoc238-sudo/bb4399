extends "flash_screen.gd"













const Atlas = preload("rankup_atlas.gd")
const CTip = preload("ctool_tip.gd")
const PopQueue = preload("pop_queue.gd")
const POP_ID: String = "rank_up"

signal closed

const SIZE: Vector2 = Vector2(480, 350)
const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const ORDER: Array = [6, 7, 3, 12, 1, 14]
const ICONS: Array = ["phy_arm", "eng_arm", "ctsis_arm", "hpmax", "atk", "common_cool"]
const ATTR_NAMES: Dictionary = {1: "TC", 3: "Xuyên Thấu", 6: "Giáp Vật Lý", 7: "Khiên Năng Lượng", 12: "HP", 14: "CD Skill"}
const SLOTS: int = 5
const DONE: String = "Kích hoạt thành công:"
const EFFECT: String = "Hiệu quả: %s"
const NO_RANK: String = "Không Quân Hàm"
const BADGE_SCALE: float = 0.65
const SHOW_IN: Array = ["lobby", "hall", "room"]

var queue: PopQueue
var prev_star: int = -1
var pending: int:
	get:
		return int(queue.param(POP_ID, -1)) if queue != null else -1
var _raw: Array = []
var _index: Dictionary = {}
var _tip: String = ""
var _ctip: CTip = CTip.new()

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	if queue == null:
		queue = PopQueue.new()
		queue.client = client
		add_child(queue)
	queue.register(POP_ID, _open)
	if client != null:
		client.military_star.connect(notice)
		client.changed.connect(_pump)
	if pack != null:
		pack.picture_ready.connect( func(path: String) -> void :
			if path == "l/rank.json":
				_drain())


func notice(prev: int, star: int) -> void :
	if pack.rank.is_empty():
		if _raw.size() < 16:
			_raw.append([prev, star])
		pack.load_rank()
		return
	if not queue.has(POP_ID) and crosses(prev, star):
		queue.append(POP_ID, prev)
	_pump()


func _open(prev: Variant) -> bool:
	prev_star = int(prev)
	_pump()
	return true


func _drain() -> void :
	if pack.rank.is_empty():
		return
	_index.clear()
	var rows: Array = _raw
	_raw = []
	for row: Array in rows:
		notice(int(row[0]), int(row[1]))


func _pump() -> void :
	if client == null:
		return
	if client.state not in SHOW_IN and client.state != "battle":
		prev_star = -1
		_raw.clear()
	var want: bool = prev_star >= 0 and client.state in SHOW_IN
	if visible != want:
		visible = want

func close() -> void :
	if prev_star < 0:
		return
	prev_star = -1
	visible = false
	closed.emit()
	queue.closed()



func _ranks() -> Array:
	return pack.rank.get("ranks", [])

func _count() -> int:
	return _ranks().size()

func _rank(rank: int) -> Array:
	var list: Array = _ranks()
	return list[rank - 1] if rank >= 1 and rank <= list.size() else ["", 1, []]

func _name(rank: int) -> String:
	return str(_rank(rank)[0])

func _badge_path(rank: int) -> String:
	return "l/mr/b%d.webp" % int(_rank(rank)[1])


func _start(rank: int) -> int:
	var nodes: Array = _rank(rank)[2]
	return int(nodes[0][0]) if not nodes.is_empty() else 0


func rank_at(star: int) -> int:
	if _index.is_empty():
		var list: Array = _ranks()
		for i in range(list.size()):
			for node: Array in list[i][2]:
				_index[int(node[0])] = i + 1
	return int(_index.get(star, 0))

func _max() -> int:
	return int(pack.rank.get("max", 510))


func crosses(prev: int, star: int) -> bool:
	for at in range(mini(star, _max()), prev, -1):
		if rank_at(at) > 0:
			return true
	return false

func _stars() -> int:
	return clampi(int(client.character.get("nMilitaryStar", 0)), 0, _max())


func view() -> Array:
	if pack.rank.is_empty():
		return []
	for star in range(_stars(), -1, -1):
		var now: int = rank_at(star)
		if now > 0:
			var next: int = now + 1 if now < _count() else now
			return [now, next, star, _start(next)]
	return []


func totals(star: int) -> Array:
	var sum: Array = []
	sum.resize(ORDER.size())
	sum.fill(0.0)
	for rank: Array in _ranks():
		for node: Array in rank[2]:
			var at: int = int(node[0])
			if at < 1 or at > star or (node[1] as Array).is_empty():
				continue
			for attr: Array in (node[1] as Array) + (node[2] as Array):
				var slot: int = ORDER.find(int(attr[0]))
				if slot >= 0:
					sum[slot] = float(sum[slot]) + float(attr[2])
	return sum



func items() -> Array:
	var shown: Array = view()
	if shown.is_empty() or prev_star < 0:
		return []
	var before: Array = totals(prev_star)
	var after: Array = totals(int(shown[2]))
	var out: Array = []
	for i in range(ORDER.size()):
		var delta: float = float(after[i]) - float(before[i])
		if out.size() >= SLOTS or delta <= 0.0:
			continue
		var kind: int = int(ORDER[i])
		var value: String = ("-%.1f%%" % (delta * 100.0)) if kind == 14 else ("+%.2f" % delta)
		out.append([ICONS[i], EFFECT % (str(ATTR_NAMES.get(kind, "")) + value)])
	return out


func item_left(count: int) -> float:
	return floorf((SIZE.x - float(Atlas.ITEM[0]) * count) / 2.0)



func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	_tip = ""
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(SIZE.x, SIZE.y)
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_fblit("ru_frame", base + _xy(Atlas.FRAME))
	var shown: Array = view()
	if shown.is_empty():
		_label("lblMRNow", NO_RANK, base)
		_label("lblMRNext", NO_RANK, base)
		_label("_MilitaryRankUpFrame_Label3", DONE, base)
	else:
		_draw_head(base, shown)
		_draw_items(base)
	_fbutton("ok", "ru_ok", (base + _xy(Atlas.UP["btnConfirm"])).floor())
	_fbutton("close", "ru_close", base + _xy(Atlas.UP["btnClose"]))
	_draw_tip()


func _draw_head(base: Vector2, shown: Array) -> void :
	_badge(int(shown[0]), base, Atlas.UP["imgRankNow"])
	_badge(int(shown[1]), base, Atlas.UP["imgRankNext"])
	_label("lblMRNow", _name(int(shown[0])), base)
	_label("lblMRNext", _name(int(shown[1])), base)
	_label("_MilitaryRankUpFrame_Label3", DONE, base)
	var bar: Vector2 = (base + _xy(Atlas.UP["mcProgress"])).floor()
	var value: int = int(shown[2])
	var most: int = int(shown[3])
	_fblit("ru_pr_bk", bar + _xy(Atlas.BAR["bk"]))
	var ratio: float = 1.0 if most <= 0 else clampf(float(value) / float(most), 0.0, 1.0)
	var fill: Vector2 = _cell_size("ru_pr")
	if ratio > 0.0:
		_fpart("ru_pr", bar + _xy(Atlas.BAR["fill"]), Rect2(Vector2.ZERO, Vector2(roundf(fill.x * ratio), fill.y)))
	_fwords("%d/%d" % [value, most], ARIAL, 12.0, Color.WHITE, "c", bar, fill.x if fill.x > 0.0 else 181.0, 0.0, 17.0, false)


func _badge(rank: int, base: Vector2, spot: Array) -> void :
	var picture: Texture2D = pack.picture(_badge_path(rank))
	if picture == null:
		return
	var span: Vector2 = picture.get_size() * BADGE_SCALE
	draw_texture_rect(picture, Rect2((base + Vector2(float(spot[0]) - span.x / 2.0, float(spot[1]))) * _f, span * _f), false)


func _draw_items(base: Vector2) -> void :
	var list: Array = items()
	var left: float = item_left(list.size())
	var top: float = float(Atlas.UP["hbRankItem"][1])
	var mouse: Vector2 = get_local_mouse_position()
	for i in range(list.size()):
		var rect: Rect2 = _fblit("ru_i_" + str(list[i][0]), base + Vector2(left + float(Atlas.ITEM[0]) * i, top))
		if _tip_ok() and _hover == "panel" and rect.has_point(mouse):
			_tip = str(list[i][1])


func _label(key: String, text: String, base: Vector2) -> void :
	var spec: Array = Atlas.TEXT[key]
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), Color(str(spec[5])), str(spec[7]), base + Vector2(float(spec[0]), float(spec[1])), float(spec[2]))



func _draw_tip() -> void :
	_ctip.draw(self, _tip, _tip, get_local_mouse_position() / _f, Vector2(_fw, _fh), _f)



func _activate(id: String) -> void :
	if id in ["ok", "close"]:
		close()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		close()
		get_viewport().set_input_as_handled()
	elif event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
