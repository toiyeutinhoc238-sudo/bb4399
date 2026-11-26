extends "../ui/flash_screen.gd"












const Text = preload("../i18n.gd")
const TankPortrait = preload("../ui/tank_portrait.gd")
const TankPreview = preload("../ui/tank_preview.gd")
const GarageModel = preload("../ui/garage_model.gd")
const KEY: String = "rmv/parts"
const FPS: float = 24.0
const ORIGIN: Vector2 = Vector2(225, 100)
const DIM: Color = Color(0, 0, 0, 153 / 255.0)
const SHOW_PLAYER: Array = [2, 9, 11, 13, 5, 6, 16, 17, 18, 19]
const TEAM_PVE_MODE: int = 8
const LOAD_WAIT: float = 4.0
const HOLD: float = 1.0
const BOY: int = 2801001
const GIRL: int = 2802001
const NAME_COLOR: Color = Color("fffa7f")
const NAME_GLOW: Color = Color("eb3801")
const TANK_COLOR: Color = Color.WHITE
const AVATAR: Vector2 = Vector2(180, 240)
const CARD_PLANES: int = 4
const MAX_CARDS: int = 3
const PLAYING: Array = ["wait", "title", "medal", "hold"]

signal shake
signal closed

var hud
var phase: String = ""
var win: bool = false
var show_player: bool = false
var count: int = 0
var labels: Array = []
var ids: Array = []
var players: Array = []
var frame: int = 0
var heard: Array = []
var _clock: float = 0.0
var _wait: float = 0.0
var _hold: float = 0.0
var _fired: Dictionary = {}
var _primed: bool = false
var _film: Dictionary = {}
var _planes: Array[Control] = []
var _shot: Dictionary = {}

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	for i in range(MAX_CARDS * CARD_PLANES + 1):
		var plane: Control = Control.new()
		plane.mouse_filter = Control.MOUSE_FILTER_IGNORE
		plane.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		plane.draw.connect(_draw_plane.bind(i))
		add_child(plane)
		_planes.append(plane)

func _process(delta: float) -> void :
	_follow(delta)
	super (delta)


func playing() -> bool:
	if phase.is_empty():
		return _due()
	return phase in PLAYING


func _follow(delta: float) -> void :
	if client == null:
		return
	var battle = client.battle
	if client.state != "battle" or not battle.ended:
		if not phase.is_empty():
			reset()
		if not _primed and client.state == "battle" and battle.started and pack != null and pack.state == "ready":
			_primed = true
			pack.effect(KEY, true)
			pack.sound("s/u/bg_down.mp3", true)
			pack.sound("s/u/medal_down.mp3", true)
		return
	if phase.is_empty():
		if not _due():
			phase = "done"
			return
		_begin()
	if phase in PLAYING:
		step(delta)

func reset() -> void :
	phase = ""
	visible = false
	frame = 0
	players = []
	labels = []
	ids = []
	heard = []
	_film = {}
	_shot = {}
	_fired = {}

func _due() -> bool:
	if client == null or pack == null or client.state != "battle" or not client.battle.ended:
		return false
	if pack.state != "ready" or pack.effect_failed(KEY):
		return false
	return not _team_pve_loss()


func _team_pve_loss() -> bool:
	var battle = client.battle
	return int(Text.map_info(int(battle.map_id)).get("modeType", -1)) == TEAM_PVE_MODE and not _won()

func _won() -> bool:
	var battle = client.battle
	return int(battle.outcome.get("m_winCamp", 0)) == battle.self_camp()



static func order(killer: int, assister: int, kda: int) -> Dictionary:
	var arr: Array = [[killer & 4294967295, 2], [assister & 4294967295, 3], [kda & 4294967295, 1]]
	if _later(arr[0], arr[1]):
		_swap(arr, 0)
	if _later(arr[1], arr[2]):
		_swap(arr, 1)
		if _later(arr[0], arr[1]):
			_swap(arr, 0)
	if int(arr[1][0]) != int(arr[2][0]):
		arr.push_front(arr.pop_back())
	var out: Dictionary = {"labels": [], "ids": []}
	for pair: Array in arr:
		out.labels.append(int(pair[1]))
		if not out.ids.has(int(pair[0])):
			out.ids.append(int(pair[0]))
	return out


static func _later(a: Array, b: Array) -> bool:
	return int(a[0]) < int(b[0])

static func _swap(arr: Array, at: int) -> void :
	var keep: Array = arr[at]
	arr[at] = arr[at + 1]
	arr[at + 1] = keep

func _begin() -> void :
	var battle = client.battle
	win = _won()
	show_player = int(battle.room_type) in SHOW_PLAYER
	var sorted: Dictionary = order(int(battle.outcome.get("m_nKiller", 0)), int(battle.outcome.get("m_nAssister", 0)), int(battle.outcome.get("m_nKDA", 0)))
	labels = sorted.labels
	ids = sorted.ids
	count = ids.size()
	players = _players(ids)
	phase = "wait"
	frame = 0
	heard = []
	_clock = 0.0
	_wait = 0.0
	_hold = 0.0
	_fired = {}
	_shot = {}
	visible = true
	pack.load_garage()
	_film = pack.effect(KEY)

func _brief(id: int) -> Dictionary:
	for brief: Variant in client.battle.roster:
		if brief is Dictionary and int(brief.get("charData", {}).get("nAcctId", 0)) & 4294967295 == id:
			return brief
	return {}


func _players(list: Array) -> Array:
	var battle = client.battle
	var me: int = int(client.account_oid) & 4294967295
	var own: Dictionary = _brief(me)
	var camp: int = int(own.get("bCamp", battle.self_camp()))
	var out: Array = []
	for id: int in list:
		var brief: Dictionary = _brief(id)
		if brief.is_empty():
			out.append({})
			continue
		var char: Dictionary = brief.get("charData", {})
		var other: Dictionary = brief.get("otherData", {})
		var avatar: int = int(char.get("nAvatar", 0))
		if avatar == 0:
			avatar = BOY if randf() < 0.5 else GIRL
		var tank_id: int = int(other.get("tankId", 0))
		var worn: int = int(other.get("tankExternal", 0))
		var level: int = int(other.get("tankLevel", 1))
		var variant: int = 2 if id == me else 1 if int(brief.get("bCamp", -1)) == camp else 0
		if hud != null and hud.pack == null:
			hud.pack = pack
		out.append({"id": id, "name": str(char.get("szName", "")), "avatar": avatar, "tank": tank_id, "worn": worn, 
			"level": level, "halo": int(other.get("haloId", 0)), "variant": variant, 
			"tank_name": hud.suitable_name(worn, tank_id) if hud != null else ""})
	return out


func step(delta: float) -> void :
	if phase == "wait":
		_wait += delta
		_film = pack.effect(KEY) if pack != null else {}
		if _film.is_empty():
			if pack == null or pack.effect_failed(KEY) or _wait >= LOAD_WAIT:
				_finish()
			return
		phase = "title"
		_clock = 0.0
		delta = 0.0
	if not phase in PLAYING:
		return
	_clock += delta
	if phase == "title":
		var title: Dictionary = _title()
		frame = int(title.from) + int(_clock * FPS)
		if frame >= int(title.to):
			if not show_player:
				_finish()
				return
			phase = "medal"
			_clock = 0.0
	if phase == "medal" or phase == "hold":
		var segment: Dictionary = _segment()
		frame = int(segment.from) + int(_clock * FPS)
		if phase == "medal" and frame >= int(segment.to):
			phase = "hold"
			_hold = 0.0
		elif phase == "hold":
			_hold += delta
			if _hold >= HOLD:
				_finish()
				return
		_events(segment)
	_build()

func _finish() -> void :
	phase = "done"
	visible = false
	_shot = {}
	closed.emit()

func _title() -> Dictionary:
	return _film.data.film.title.get("win" if win else "lose", {})

func _segment() -> Dictionary:
	return _film.data.film.segments.get(str(clampi(count, 1, 3)), {})


func _events(segment: Dictionary) -> void :
	var events: Dictionary = _film.data.film.get("events", {})
	for i in range(segment.cards.size()):
		var e: int = frame - int(segment.cards[i][0]) + 1
		if e >= int(events.get("card_sound", 1)) and not _fired.has("card%d" % i):
			_fired["card%d" % i] = true
			heard.append("u/bg_down")
			Sound.play("u/bg_down")
	for i in range(segment.medals.size()):
		var e: int = frame - int(segment.medals[i][0]) + 1
		if e >= int(events.get("medal_sound", 8)) and not _fired.has("medal%d" % i):
			_fired["medal%d" % i] = true
			heard.append("u/medal_down")
			Sound.play("u/medal_down")
		if e >= int(events.get("medal_down", 15)) and not _fired.has("down%d" % i):
			_fired["down%d" % i] = true
			heard.append("shake")
			shake.emit()



static func _mat(row: Array, at: int) -> Transform2D:
	if row.size() < at + 6:
		return Transform2D.IDENTITY
	return Transform2D(Vector2(float(row[at]), float(row[at + 1])), Vector2(float(row[at + 2]), float(row[at + 3])), Vector2(float(row[at + 4]), float(row[at + 5])))


static func _mix(row: Array, at: int, parent: Array) -> Array:
	if row.size() < at + 8:
		return parent
	var out: Array = []
	out.resize(8)
	for i in range(4):
		out[i] = float(row[at + i]) * float(parent[i])
		out[4 + i] = float(row[at + 4 + i]) * float(parent[i]) + float(parent[4 + i])
	return out

static func _alpha(cx: Array) -> float:
	return clampf(float(cx[3]) + float(cx[7]) / 255.0, 0.0, 1.0)

static func _tint(cx: Array) -> Color:
	return Color(float(cx[0]) + float(cx[4]) / 255.0, float(cx[1]) + float(cx[5]) / 255.0, float(cx[2]) + float(cx[6]) / 255.0, _alpha(cx))

const NO_TINT: Array = [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0]

func _build() -> void :
	_shot = {"title": [], "cards": [], "medals": []}
	if _film.is_empty():
		_push()
		return
	if phase == "title":
		var title: Dictionary = _title()
		var rows: Array = title.rows
		var row: Array = rows[clampi(frame - int(title.from), 0, rows.size() - 1)]
		_root(_shot.title, str(int(title.root)), int(row[0]), _mat(row, 1), _mix(row, 7, NO_TINT), {})
	elif phase == "medal" or phase == "hold":
		var segment: Dictionary = _segment()
		for i in range(mini(MAX_CARDS, segment.cards.size())):
			var card: Array = segment.cards[i]
			var place: Transform2D = _mat(card, 1)
			var ctx: Dictionary = {"card": i, "low": [], "high": [], "tank": {}, "split": false, "place": place, 
				"player": players[i] if i < players.size() else {}}
			var e: int = frame - int(card[0]) + 1
			if e >= 1:
				_root([], "31", e, place, _mix(card, 7, NO_TINT), ctx)
			_shot.cards.append(ctx)
		for i in range(segment.medals.size()):
			var medal: Array = segment.medals[i]
			var e: int = frame - int(medal[0]) + 1
			if e >= 1:
				_root(_shot.medals, "54", e, _mat(medal, 1), _mix(medal, 7, NO_TINT), {"medal": i})
	_push()

func _root(into: Array, key: String, e: int, xf: Transform2D, cx: Array, ctx: Dictionary) -> void :
	var film: Dictionary = _film.data.film
	var frames: Array = film.roots.get(key, [])
	if frames.is_empty():
		return
	var at: int = clampi(mini(e, int(film.stops.get(key, frames.size() - 1))), 0, frames.size() - 1)
	_walk(into, frames[at], xf, cx, 0, e, ctx, true)

func _walk(into: Array, ops: Array, xf: Transform2D, cx: Array, mode: int, e: int, ctx: Dictionary, top: bool) -> void :
	var film: Dictionary = _film.data.film
	for op: Array in ops:
		var list: Array = into
		if top and ctx.has("low"):
			list = ctx.high if ctx.split else ctx.low
		match int(op[0]):
			0:
				_leaf(list, int(op[1]), xf * _mat(op, 2), _mix(op, 8, cx), mode if not mode in [0, 1, 2] else int(op[16]) if op.size() > 16 else 0)
			1:
				var clip: Array = film.clips.get(str(op[1]), [])
				if not clip.is_empty():
					_walk(list, clip[posmod(e - int(op[2]), clip.size())], xf * _mat(op, 3), _mix(op, 9, cx), mode if not mode in [0, 1, 2] else int(op[17]), 0, ctx, false)
			3:
				var variants: Array = film.picks.get(str(op[1]), [])
				if not variants.is_empty():
					var variant: int = _pick(ctx, e - int(op[2]), variants.size())
					_walk(list, variants[clampi(variant, 0, variants.size() - 1)], xf * _mat(op, 3), _mix(op, 9, cx), mode if not mode in [0, 1, 2] else int(op[17]), 0, ctx, false)
			2:
				_slot(list, str(op[1]), xf * _mat(op, 2), _mix(op, 8, cx), ctx)


func _pick(ctx: Dictionary, age: int, total: int) -> int:
	if ctx.has("medal"):
		return int(labels[int(ctx.medal)]) - 1 if int(ctx.medal) < labels.size() else 0
	if ctx.has("card"):
		var who: Dictionary = ctx.player
		return int(who.variant) if not who.is_empty() else posmod(age, total)
	return 0

func _leaf(into: Array, index: int, xf: Transform2D, cx: Array, mode: int) -> void :
	var frames: Array = _film.data.frames
	if index < 0 or index >= frames.size():
		return
	var alpha: float = _alpha(cx)
	if alpha <= 0.003:
		return
	var part: Dictionary = frames[index]
	var k: float = maxf(0.0001, float(part.get("k", 1.0)))
	var at: Transform2D = xf * Transform2D(0.0, Vector2(1.0 / k, 1.0 / k), 0.0, Vector2.ZERO)
	var pivot: Vector2 = Vector2(float(part.pivot[0]), float(part.pivot[1]))
	var rect: Rect2 = Rect2(float(part.rect[0]), float(part.rect[1]), float(part.rect[2]), float(part.rect[3]))
	if mode == 9:
		into.append([0, int(part.page), at, Rect2( - pivot, rect.size), rect, Color(0, 0, 0, alpha)])
		return
	var white: float = float(cx[4]) / 255.0
	var ghost: int = int(_film.data.film.white.get(str(index), -1))
	if white > 0.008 and ghost >= 0 and ghost < frames.size():

		into.append([0, int(part.page), at, Rect2( - pivot, rect.size), rect, Color(1, 1, 1, alpha * (1.0 - white) / maxf(1e-06, 1.0 - alpha * white))])
		var shade: Dictionary = frames[ghost]
		var cut: Rect2 = Rect2(float(shade.rect[0]), float(shade.rect[1]), float(shade.rect[2]), float(shade.rect[3]))
		into.append([0, int(shade.page), at, Rect2( - pivot, cut.size), cut, Color(1, 1, 1, alpha * white)])
		return
	into.append([0, int(part.page), at, Rect2( - pivot, rect.size), rect, _tint(cx)])

func _slot(into: Array, name: String, xf: Transform2D, cx: Array, ctx: Dictionary) -> void :
	if ctx.has("medal"):
		if name == "cvs_xunzhangmingzi" and int(ctx.medal) < labels.size():
			_leaf(into, int(_film.data.film.words.get(str(labels[int(ctx.medal)]), -1)), xf, cx, 0)
		return
	if not ctx.has("card"):
		return
	if name == "cvs_juesetanke":
		ctx.tank = {"xf": xf, "cx": cx}
		ctx.split = true
		return
	var who: Dictionary = ctx.player
	if who.is_empty() or _alpha(cx) <= 0.003:
		return
	match name:
		"cvs_tankemingzi":
			into.append([2, str(who.tank_name), xf, 14.0, Color(TANK_COLOR, _alpha(cx)), Color(0, 0, 0, 0)])
		"cvs_juesemingzi":
			into.append([2, str(who.name), xf, 18.0, Color(NAME_COLOR, _alpha(cx)), Color(NAME_GLOW, _alpha(cx))])
		"cvs_jueserenwu":
			_portrait(into, who, xf, cx, ctx.place)


func _portrait(into: Array, who: Dictionary, xf: Transform2D, cx: Array, place: Transform2D) -> void :
	var key: String = str(pack.lobby.get("avatars", {}).get(str(who.avatar), ""))
	if key.is_empty():
		return
	var path: String = "l/av/%s.webp" % key
	var picture: Texture2D = pack.picture(path)
	if picture == null:
		return
	var whole: Rect2 = Rect2( - AVATAR / 2.0, AVATAR)
	var dest: Rect2 = whole
	if absf(place.determinant()) > 1e-06:
		var inner: Transform2D = place.affine_inverse() * xf
		var mask: Array = _film.data.film.get("mask", [])
		if mask.size() >= 4 and absf(inner.x.y) < 0.0001 and absf(inner.y.x) < 0.0001 and inner.x.x > 0.0 and inner.y.y > 0.0:
			var s: Vector2 = Vector2(inner.x.x, inner.y.y)
			var shown: Rect2 = Rect2(inner.origin + whole.position * s, whole.size * s).intersection(Rect2(float(mask[0]), float(mask[1]), float(mask[2]), float(mask[3])))
			if shown.size.x <= 0.0 or shown.size.y <= 0.0:
				return
			dest = Rect2((shown.position - inner.origin) / s, shown.size / s)
	var ratio: Vector2 = picture.get_size() / AVATAR
	var src: Rect2 = Rect2((dest.position - whole.position) * ratio, dest.size * ratio)
	var white: float = float(cx[4]) / 255.0
	var alpha: float = _alpha(cx)
	if white > 0.008:
		into.append([1, path, xf, dest, src, Color(1, 1, 1, alpha * (1.0 - white) / maxf(1e-06, 1.0 - alpha * white))])
		into.append([1, path, xf, dest, src, Color(4, 4, 4, alpha * white)])
	else:
		into.append([1, path, xf, dest, src, _tint(cx)])


func _push() -> void :
	var cards: Array = _shot.get("cards", [])
	for i in range(_planes.size()):
		var plane: Control = _planes[i]
		var kind: int = i % CARD_PLANES
		var card: int = i / CARD_PLANES
		if i < MAX_CARDS * CARD_PLANES and (kind == 1 or kind == 2):
			var tank: Dictionary = cards[card].tank if card < cards.size() else {}
			var cx: Array = tank.get("cx", NO_TINT)
			var alpha: float = _alpha(cx) if not tank.is_empty() else 0.0
			var white: float = float(cx[4]) / 255.0
			if kind == 1:
				plane.self_modulate = Color(1, 1, 1, alpha * (1.0 - white) / maxf(1e-06, 1.0 - alpha * white)) if white > 0.008 else _tint(cx) if alpha > 0.0 else Color(1, 1, 1, 0)
			else:
				plane.self_modulate = Color(4, 4, 4, alpha * white) if white > 0.008 else Color(1, 1, 1, 0)
		plane.queue_redraw()



func _base() -> Transform2D:
	_metrics()
	return Transform2D(0.0, Vector2(_f, _f), 0.0, (_stage() + ORIGIN) * _f)

func _paint() -> void :
	if not phase in PLAYING:
		return
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_replay(self, _shot.get("title", []), _base())

func _draw_plane(index: int) -> void :
	if _shot.is_empty() or client == null or pack == null or not phase in PLAYING:
		return
	var plane: Control = _planes[index]
	var base: Transform2D = _base()
	if index >= MAX_CARDS * CARD_PLANES:
		_replay(plane, _shot.get("medals", []), base)
		return
	var cards: Array = _shot.get("cards", [])
	if index / CARD_PLANES >= cards.size():
		return
	var card: Dictionary = cards[index / CARD_PLANES]
	match index % CARD_PLANES:
		0:
			_replay(plane, card.low, base)
		3:
			_replay(plane, card.high, base)
		_:
			if plane.self_modulate.a > 0.003:
				_draw_tank(plane, card, base)



func _draw_tank(plane: Control, card: Dictionary, base: Transform2D) -> void :
	var who: Dictionary = card.player
	if who.is_empty() or card.tank.is_empty() or int(who.tank) <= 0:
		return
	var at: Transform2D = base * (card.tank.xf as Transform2D)
	var level: int = maxi(1, int(who.level))
	var ext: int = int(who.worn)
	if ext <= 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(who.tank), level, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(who.halo), level)
	plane.draw_set_transform_matrix(at)
	if not TankPortrait.draw(plane, pack, GarageModel.face(pack.garage, ext), item, Vector2(100, 100), 1.0, _time):
		var art: Dictionary = pack.external_art(pack.art_external(str(int(who.worn)), int(who.tank)))
		if TankPreview.ready(art):
			TankPreview.draw(plane, art, at * Vector2(100, 114), at.x.length(), 4, _time)
	plane.draw_set_transform_matrix(Transform2D.IDENTITY)

func _replay(canvas: CanvasItem, list: Array, base: Transform2D) -> void :
	var pages: Array = _film.get("pages", [])
	for cmd: Array in list:
		match int(cmd[0]):
			0:
				if int(cmd[1]) < pages.size() and pages[int(cmd[1])] != null:
					canvas.draw_set_transform_matrix(base * (cmd[2] as Transform2D))
					canvas.draw_texture_rect_region(pages[int(cmd[1])], cmd[3], cmd[4], cmd[5])
			1:
				var picture: Texture2D = pack.picture(str(cmd[1]))
				if picture != null:
					canvas.draw_set_transform_matrix(base * (cmd[2] as Transform2D))
					canvas.draw_texture_rect_region(picture, cmd[3], cmd[4], cmd[5])
			2:
				_label(canvas, str(cmd[1]), base * (cmd[2] as Transform2D), float(cmd[3]), cmd[4], cmd[5])
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)


func _label(canvas: CanvasItem, text: String, at: Transform2D, px: float, color: Color, glow: Color) -> void :
	if text.is_empty():
		return
	var s: float = at.x.length()
	var font_size: int = maxi(6, roundi(px * s))
	var font: Font = ARIAL_BOLD
	var wide: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var origin: Vector2 = at.origin + Vector2( - wide / 2.0, (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0)
	canvas.draw_set_transform_matrix(Transform2D.IDENTITY)
	if glow.a > 0.0:
		canvas.draw_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(3.0 * s)), glow)
	canvas.draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
