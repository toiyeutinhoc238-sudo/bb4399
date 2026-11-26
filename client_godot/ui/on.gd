extends "tev_window.gd"













signal closed(note: String)

const OnAtlas = preload("on_atlas.gd")
const LeagueAward = preload("league_award_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const ON_TIP: String = "Nối Hình"
const ON_ICON_ART: String = "btn_noihinh"
const ON_WORD_ART: String = "word_noihinh_t"
const MB_POLL_TICKS: int = 120
const MB_ARM_MS: float = 4000.0
const ON_W: float = 960.0
const ON_H: float = 580.0
const ON_CX: float = 373.0
const ON_CY: float = 316.0
const ON_PX: int = 42
const ON_PY: int = 50
const ON_ICON: int = 34
const ON_FIT_W: float = 690.0
const ON_FIT_H: float = 468.0
const ON_ZOOM_MAX: float = 1.5
const ON_PATH_MS: float = 450.0
const ON_FLOAT_MS: float = 1400.0
const ON_FLOAT_Y: float = 286.0
const ON_RETRY_MS: float = 1000.0
const ON_RETRIES: int = 5
const ON_BATCH: int = 20
const ON_FX_FRAME_MS: float = 100.0
const ON_BANNER_MS: float = 1200.0
const ON_CHARS: String = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const ON_GLYPHS: String = "0123456789+x:"
const ON_GLYPH_X: Array = [0, 27, 46, 72, 97, 125, 151, 179, 205, 233, 261, 287, 314]
const ON_GLYPH_W: Array = [27, 19, 26, 25, 28, 26, 28, 26, 28, 28, 26, 27, 15]
const ON_GLYPH_A: Array = [24, 16, 23, 22, 25, 23, 25, 23, 25, 25, 23, 24, 12]
const ON_SHEETS: Dictionary = {"fx_burst": [64, 64, 4, 8], "fx_sparkle": [32, 32, 3, 6], "fx_firework": [96, 96, 4, 8]}
const ON_LINE: float = 1.15
const TIMEUP_NOTE: String = "Ván Nối Hình vẫn đang tính giờ, mở lại để chơi tiếp."

static var s_on_shown: bool = false
static var _atlas: Texture2D = null
static var _atlas_tried: bool = false

var poll_in: int = 4
var on_visible: bool = false
var loaded: bool = false
var token: String = ""
var used: int = 0
var turns_max: int = 0
var sec: int = 180
var lv: int = 0
var cms: int = 3000
var atlas_name: String = ""
var cell: int = 48
var acols: int = 16
var on_theme: String = ""
var best: int = 0
var rank: int = 0
var bst: int = 0
var ybest: int = 0
var yrank: int = 0
var yset: bool = false
var yit: String = ""
var tiers: Array = []
var top: Array = []
var ytop: Array = []
var tab: int = 0
var arm_at: float = 0.0
var live: bool = false
var run: int = 0
var bn: int = 0
var mode: String = "none"
var cols: int = 0
var rows: int = 0
var kinds: Array = []
var cells: Array = []
var n: int = 0
var sent: Array = []
var queue: Array = []
var sel: int = -1
var lock: bool = false
var end_wanted: bool = false
var ends_at: float = 0.0
var ping_at: float = 0.0
var retry_at: float = 0.0
var retries: int = 0
var score: int = 0
var pairs: int = 0
var combo: int = 0
var last_pair_at: float = 0.0
var result: Variant = null
var quit: bool = false
var pitch_x: int = ON_PX
var pitch_y: int = ON_PY
var ico: int = ON_ICON
var combo_shown: int = -1
var combo_pop_at: float = 0.0
var path_pts: Array = []
var path_at: float = 0.0
var onfx: Array = []
var now_skew: float = 0.0

var _parts: Dictionary = {}
var _layers: Array = []

func _setup() -> void :
	art_dir = ""
	art_files = []
	sheets = ON_SHEETS
	win_size = Vector2(ON_W, ON_H)
	super ()
	var regions: Dictionary = {}
	for name: String in ["la_tile", "la_q2", "la_q3", "la_q4", "la_q5"]:
		regions[name] = LeagueAward.R[name]
	_use(LeagueAward.FILE, regions)
	on_visible = s_on_shown
	_layers = [_make_layer("add1", true), _make_layer("top1", false), _make_layer("add2", true)]

static func reset_statics() -> void :
	s_on_shown = false


func now_ms() -> float:
	return float(Time.get_ticks_msec()) + now_skew

static func rgb(value: int) -> Color:
	return Color8((value >> 16) & 255, (value >> 8) & 255, value & 255)


func reset() -> void :
	reset_run()
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 4
	on_visible = false
	loaded = false
	token = ""
	used = 0
	turns_max = 0
	sec = 180
	lv = 0
	cms = 3000
	atlas_name = ""
	cell = 48
	acols = 16
	on_theme = ""
	best = 0
	rank = 0
	bst = 0
	ybest = 0
	yrank = 0
	yset = false
	yit = ""
	tiers = []
	top = []
	ytop = []
	tab = 0
	run = 0
	bn = 0
	mode = "none"
	cols = 0
	rows = 0
	kinds = []
	ends_at = 0.0
	ping_at = 0.0
	score = 0
	pairs = 0
	combo = 0
	last_pair_at = 0.0
	result = null
	n = 0
	reset_run()
	pitch_x = ON_PX
	pitch_y = ON_PY
	ico = ON_ICON
	_clear_labels()
	path_pts = []
	path_at = 0.0
	onfx = []
	reset_statics()



func _load_atlas() -> Texture2D:
	if not _atlas_tried:
		_atlas_tried = true
		if ResourceLoader.exists(OnAtlas.FILE):
			_atlas = load(OnAtlas.FILE) as Texture2D
	return _atlas

func load_art() -> void :
	_art_asked = true

func art_pending() -> int:
	return 0 if _art_asked else -1

func retry_art() -> void :
	pass

func art(name: String) -> Texture2D:
	if _parts.has(name):
		return _parts[name]
	var atlas: Texture2D = _load_atlas()
	if atlas == null or not OnAtlas.R.has(name):
		return null
	var row: Array = OnAtlas.R[name]
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = atlas
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part

func button_icon() -> Texture2D:
	return art(ON_ICON_ART)

func button_word() -> Texture2D:
	return art(ON_WORD_ART)


func atlas_ok() -> bool:
	return atlas_name.get_slice("?", 0) == OnAtlas.TILES_FILE and art("tiles") != null




func boot() -> void :
	poll_in = MB_POLL_TICKS
	if not loading:
		load_onet("/onet.xml?t=", "poll")


func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = MB_POLL_TICKS
		if not loading:
			load_onet("/onet.xml?t=", "poll")

func button_visible() -> bool:
	return on_visible

func button_dot() -> bool:
	return on_visible and (live or used < turns_max)


func refresh_button() -> void :
	queue_redraw()


func busy() -> bool:
	return action == "start" or action == "end" or end_wanted


func open() -> void :
	if opened or not on_visible:
		return
	arm_at = 0.0
	tab = 0
	sel = -1
	show_window()
	load_art()
	if pack != null:
		pack.load_events()
		pack.load_quest()
		pack.load_bag()
	build()
	if action.is_empty() or action == "poll":
		sent = []
		queue = []
		load_onet("/onet.xml?t=", "poll")


func close(note: String = "") -> void :
	if not opened:
		return
	if live:
		if action.is_empty() and retry_at == 0.0 and ( not sent.is_empty() or not queue.is_empty()):
			send_moves()
		note = TIMEUP_NOTE
	hide_window()
	arm_at = 0.0
	sel = -1
	retry_at = 0.0
	end_wanted = false
	_clear_labels()
	onfx = []
	path_pts = []
	path_at = 0.0
	poll_in = MB_POLL_TICKS
	closed.emit(note)

func leave() -> void :
	close()

func _activate(id: String) -> void :
	if id == "close":
		close()
	elif id == "start":
		on_start()
	elif id == "surrender":
		on_surrender()
	elif id.begins_with("tab:"):
		set_tab(id.substr(4).to_int())


func _clear_labels() -> void :
	combo_shown = -1
	combo_pop_at = 0.0


func build() -> void :
	_tips.clear()
	_clear_labels()
	update_stats()

func _stats_built() -> bool:
	return opened and loaded and live


func update_stats() -> void :
	if not _stats_built():
		return
	if combo != combo_shown:
		if combo > 1 and combo_shown >= 0 and combo > combo_shown:
			combo_pop_at = now_ms()
			play_fx("fx_sparkle", 889.0, 186.0, 0.0)
		combo_shown = combo




func load_onet(prefix: String, what: String) -> void :
	fetch(prefix + str(int(now_ms())), what)
	if not loading and what == "move":
		retry_at = now_ms() + ON_RETRY_MS
		retries += 1


func _failed(what: String) -> void :
	if what == "move":
		retry_at = now_ms() + ON_RETRY_MS
		retries += 1
		return
	if what == "start" or what == "end":
		tip("Không kết nối được máy chủ, hãy thử lại.")
		build()

static func _int(at: Dictionary, key: String) -> int:
	return TevWheel.as_int(str(at.get(key, "")))

static func _row(node: Dictionary) -> Dictionary:
	var at: Dictionary = node["at"]
	return {"r": _int(at, "r"), "n": str(at.get("n", "")), "s": _int(at, "s"), "a": _int(at, "a"), "me": str(at.get("me", "")) == "1"}


func _reply(text: String, what: String) -> void :
	var was_live: bool = live
	var xml: Variant = parse_deep(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	var notice: String = ""
	var light: bool = false
	if xml != null:
		var at: Dictionary = xml["at"]
		notice = str(at.get("notice", ""))
		light = str(at.get("light", "")) == "1"
		on_visible = str(at.get("visible", "")) == "1"
		s_on_shown = on_visible
		if on_visible and not light:
			var got_tiers: Array = []
			for node: Dictionary in kids(xml, "tier"):
				got_tiers.append({"a": _int(node["at"], "a"), "b": _int(node["at"], "b"), "it": str(node["at"].get("it", ""))})
			var got_top: Array = []
			for holder: Dictionary in kids(xml, "top"):
				for node: Dictionary in kids(holder, "p"):
					got_top.append(_row(node))
			var got_ytop: Array = []
			for holder: Dictionary in kids(xml, "ytop"):
				for node: Dictionary in kids(holder, "p"):
					got_ytop.append(_row(node))
			token = str(at.get("k", ""))
			used = _int(at, "used")
			turns_max = _int(at, "max")
			sec = maxi(1, _int(at, "sec"))
			lv = _int(at, "lv")
			cms = _int(at, "cms")
			atlas_name = str(at.get("atlas", ""))
			cell = maxi(1, _int(at, "cell"))
			acols = maxi(1, _int(at, "acols"))
			on_theme = str(at.get("theme", ""))
			best = _int(at, "best")
			rank = _int(at, "rank")
			bst = _int(at, "bst")
			ybest = _int(at, "ybest")
			yrank = _int(at, "yrank")
			yset = str(at.get("yset", "")) == "1"
			yit = str(at.get("yit", ""))
			tiers = got_tiers
			top = got_top
			ytop = got_ytop
			loaded = true
	if xml == null:
		if what == "move":
			retry_at = now_ms() + ON_RETRY_MS
			retries += 1
			return
		if what == "start" or what == "end":
			notice = "Thao tác chưa thành công, hãy thử lại sau."
	elif not on_visible:
		reset_run()
	else:
		retries = 0
		var runs: Array = kids(xml, "run")
		if not runs.is_empty():
			take_run(runs[0], light)
		elif not light:
			reset_run()
	refresh_button()
	if opened and not on_visible:
		close()
	elif opened:
		if not light or was_live != live:
			build()
		else:
			update_stats()
	if not notice.is_empty():
		tip(notice)
	if light and was_live and not live and on_visible:
		load_onet("/onet.xml?t=", "poll")
		return
	pump()


func reset_run() -> void :
	live = false
	cells = []
	sent = []
	queue = []
	sel = -1
	lock = false
	end_wanted = false
	retry_at = 0.0
	retries = 0
	arm_at = 0.0
	quit = false


func take_run(node: Dictionary, light: bool) -> void :
	var at: Dictionary = node["at"]
	var evs: PackedStringArray = str(at.get("ev", "")).split(",")
	var add: int = _int(at, "add")
	var board: Array = decode(str(at.get("board", "")))
	var new_cols: int = _int(at, "cols")
	var new_rows: int = _int(at, "rows")
	var new_bn: int = _int(at, "bn")
	var new_mode: String = str(at.get("mode", ""))
	var take: bool = not light
	var before: int = score
	var same_run: bool = live and _int(at, "id") == run
	score = _int(at, "score")
	pairs = _int(at, "pairs")
	combo = _int(at, "combo")
	if str(at.get("st", "")) != "live" or evs.has("end"):
		if live and not quit:
			banner("banner_timeup", "Hết giờ!")
		result = {"score": score, "bn": new_bn, "pairs": pairs, "mc": _int(at, "mc")}
		reset_run()
		return
	live = true
	result = null
	run = _int(at, "id")
	ends_at = now_ms() + float(_int(at, "left"))
	if evs.has("sync") or evs.has("bad") or evs.has("fast") or evs.has("clear") or evs.has("shuffle"):
		take = true
	if not take:

		take = new_cols != cols or new_rows != rows or new_bn != bn or board.size() != new_cols * new_rows
		var check: Array = board.duplicate()
		var i: int = 0
		while not take and i < queue.size():
			var pair: Array = queue[i]
			if link(check, cols, rows, int(pair[0]), int(pair[1])) == null:
				take = true
			else:
				check[int(pair[0])] = -1
				check[int(pair[1])] = -1
				compact(check, cols, rows, new_mode)
			i += 1
		i = 0
		while not take and i < check.size():
			if int(check[i]) != (int(cells[i]) if i < cells.size() else 0):
				take = true
			i += 1
	n = _int(at, "n")
	sent = []
	if take:
		bn = new_bn
		mode = new_mode
		cols = new_cols
		rows = new_rows
		kinds = ints(str(at.get("kinds", "")))
		cells = board if board.size() == new_cols * new_rows else []
		queue = []
		sel = -1
	lock = not has_pair(cells, cols, rows)
	if evs.has("clear"):
		banner("banner_clear", "Qua Ải " + str(new_bn - 1) + "!  +" + str(add))
		play_fx("fx_firework", 98, 33, 0)
		play_fx("fx_firework", 724, 29, 160)
		play_fx("fx_sparkle", 170, 190, 80)
		play_fx("fx_sparkle", 580, 170, 200)
		play_fx("fx_sparkle", 250, 450, 320)
		play_fx("fx_sparkle", 500, 460, 440)
		play_fx("fx_firework", 373, 150, 360)
	elif evs.has("shuffle"):
		float_text("Hết đường nối, xếp lại bàn!", 20)
	elif evs.has("fast"):
		tip("Bạn nối nhanh quá, chậm lại một chút nhé.")
	if same_run and score > before:
		gain(score - before)

static func ints(text: String) -> Array:
	var out: Array = []
	for part: String in text.split(","):
		if not part.is_empty():
			out.append(TevWheel.as_int(part))
	return out

static func decode(text: String) -> Array:
	var out: Array = []
	for i in text.length():
		out.append(ON_CHARS.find(text[i]))
	return out


func pump() -> void :
	var at: float = now_ms()
	if not action.is_empty() or not live or retry_at != 0.0:
		return
	if not sent.is_empty() or not queue.is_empty():
		send_moves()
		return
	if end_wanted:
		end_wanted = false
		load_onet("/onet-end.xml?k=" + TevWheel.uri_component(token) + "&r=" + str(run) + "&t=", "end")
		return
	if at >= ends_at and at - ping_at >= ON_RETRY_MS:
		ping_at = at
		send_moves()


func send_moves() -> void :
	if sent.is_empty():
		sent = queue.slice(0, ON_BATCH)
		queue = queue.slice(ON_BATCH)
	var parts: PackedStringArray = []
	for pair: Array in sent:
		parts.append(str(int(pair[0])) + "." + str(int(pair[1])))
	load_onet("/onet-move.xml?k=" + TevWheel.uri_component(token) + "&r=" + str(run) + "&n=" + str(n) + "&p=" + ",".join(parts) + "&t=", "move")




func on_start() -> void :
	if busy() or live or used >= turns_max or action == "move":
		return
	result = null
	combo = 0
	last_pair_at = 0.0
	quit = false
	load_onet("/onet-start.xml?k=" + TevWheel.uri_component(token) + "&t=", "start")
	build()


func on_surrender() -> void :
	if not live or busy():
		return
	if arm_at == 0.0:
		arm_at = now_ms()
		build()
		return
	arm_at = 0.0
	end_wanted = true
	quit = true
	sel = -1
	build()
	pump()


func set_tab(index: int) -> void :
	if tab == index:
		return
	tab = index
	build()


func board_down(p: Vector2) -> void :
	var at: float = now_ms()
	if not live or lock or end_wanted or not opened or cells.is_empty() or at >= ends_at:
		return
	fit()
	var cx: int = floori((p.x - float(origin_x())) / float(pitch_x))
	var cy: int = floori((p.y - float(origin_y())) / float(pitch_y))
	if cx < 0 or cy < 0 or cx >= cols or cy >= rows:
		sel = -1
		return
	var index: int = cy * cols + cx
	if int(cells[index]) < 0:
		return
	if sel < 0 or sel == index or int(cells[sel]) != int(cells[index]):
		sel = -1 if sel == index else index
		return
	var path: Variant = link(cells, cols, rows, sel, index)
	if path == null:
		sel = index
		return
	draw_path(path)
	queue.append([sel, index])
	cells[sel] = -1
	cells[index] = -1
	compact(cells, cols, rows, mode)
	sel = -1
	combo = combo + 1 if at - last_pair_at <= float(cms) else 1
	last_pair_at = at
	lock = not has_pair(cells, cols, rows)
	update_stats()
	pump()


func _anim() -> void :
	var at: float = now_ms()
	if path_at != 0.0 and (at - path_at) / ON_PATH_MS >= 1.0:
		path_at = 0.0
		path_pts = []
	step_fx(at)
	if combo_pop_at != 0.0 and at - combo_pop_at >= 300.0:
		combo_pop_at = 0.0
	if arm_at != 0.0 and at - arm_at > MB_ARM_MS:
		arm_at = 0.0
		build()
	if not live:
		return
	if at >= ends_at and sel >= 0:
		sel = -1
	if _stats_built() and combo > 1 and at - last_pair_at > float(cms):
		combo = 0
		update_stats()
	if retry_at != 0.0 and at >= retry_at:
		retry_at = 0.0
		if retries > ON_RETRIES:

			retries = 0
			sent = []
			queue = []
			load_onet("/onet.xml?t=", "poll")
			return
	pump()



static func _cell_of(b: Array, i: int) -> int:
	return int(b[i]) if i >= 0 and i < b.size() else 0

static func cell_free(b: Array, c: int, r: int, x: int, y: int) -> bool:
	return x < 0 or y < 0 or x >= c or y >= r or _cell_of(b, y * c + x) < 0

static func line_clear(b: Array, c: int, r: int, ax: int, ay: int, bx: int, by: int) -> bool:
	var dx: int = 1 if bx > ax else (-1 if bx < ax else 0)
	var dy: int = 1 if by > ay else (-1 if by < ay else 0)
	if dx != 0 and dy != 0:
		return false
	var cx: int = ax + dx
	var cy: int = ay + dy
	while cx != bx or cy != by:
		if not cell_free(b, c, r, cx, cy):
			return false
		cx += dx
		cy += dy
	return true


static func link(b: Array, c: int, r: int, a: int, e: int) -> Variant:
	if a < 0 or e < 0 or a >= c * r or e >= c * r or a == e or _cell_of(b, a) < 0 or _cell_of(b, a) != _cell_of(b, e):
		return null
	var ax: int = a % c
	var ay: int = a / c
	var bx: int = e % c
	var by: int = e / c
	if (ax == bx or ay == by) and line_clear(b, c, r, ax, ay, bx, by):
		return [[ax, ay], [bx, by]]
	if cell_free(b, c, r, ax, by) and line_clear(b, c, r, ax, ay, ax, by) and line_clear(b, c, r, ax, by, bx, by):
		return [[ax, ay], [ax, by], [bx, by]]
	if cell_free(b, c, r, bx, ay) and line_clear(b, c, r, ax, ay, bx, ay) and line_clear(b, c, r, bx, ay, bx, by):
		return [[ax, ay], [bx, ay], [bx, by]]
	var dirs: Array = [1, 0, -1, 0, 0, 1, 0, -1]
	var found: Variant = null
	var best_len: int = 100000
	var d: int = 0
	while d < 8:
		var dx: int = dirs[d]
		var dy: int = dirs[d + 1]
		var cx: int = ax + dx
		var cy: int = ay + dy
		while cx >= -1 and cy >= -1 and cx <= c and cy <= r and cell_free(b, c, r, cx, cy):
			var ex: int = cx if dx != 0 else bx
			var ey: int = by if dx != 0 else cy
			if cell_free(b, c, r, ex, ey) and line_clear(b, c, r, cx, cy, ex, ey) and line_clear(b, c, r, ex, ey, bx, by):
				var length: int = absi(cx - ax) + absi(cy - ay) + absi(ex - cx) + absi(ey - cy) + absi(bx - ex) + absi(by - ey)
				if length < best_len:
					found = [[ax, ay], [cx, cy], [ex, ey], [bx, by]]
					best_len = length
			cx += dx
			cy += dy
		d += 2
	return found

static func has_pair(b: Array, c: int, r: int) -> bool:
	var at: Dictionary = {}
	for i in b.size():
		var k: int = int(b[i])
		if k >= 0:
			if not at.has(k):
				at[k] = []
			(at[k] as Array).append(i)
	for list: Array in at.values():
		for i in list.size():
			for j in range(i + 1, list.size()):
				if link(b, c, r, int(list[i]), int(list[j])) != null:
					return true
	return false


static func line(b: Array, first: int, step: int, count: int, to_end: bool) -> void :
	var keep: Array = []
	for i in count:
		if int(b[first + i * step]) >= 0:
			keep.append(int(b[first + i * step]))
	var from: int = count - keep.size() if to_end else 0
	for i in count:
		b[first + i * step] = keep[i - from] if i >= from and i < from + keep.size() else -1


static func halves(b: Array, first: int, step: int, count: int, apart: bool) -> void :
	var h: int = count / 2
	line(b, first, step, h, not apart)
	line(b, first + h * step, step, count - h, apart)

static func compact(b: Array, c: int, r: int, how: String) -> void :
	if b.size() < c * r:
		return
	if how == "down" or how == "up":
		for i in c:
			line(b, i, c, r, how == "down")
	elif how == "left" or how == "right":
		for i in r:
			line(b, i * c, 1, c, how == "right")
	elif how == "vout" or how == "vin":
		for i in c:
			halves(b, i, c, r, how == "vout")
	elif how == "hout" or how == "hin":
		for i in r:
			halves(b, i * c, 1, c, how == "hout")

static func mode_name(how: String) -> String:
	match how:
		"down":
			return "Rơi xuống"
		"left":
			return "Dồn trái"
		"up":
			return "Dồn lên"
		"right":
			return "Dồn phải"
		"vout":
			return "Tách trên dưới"
		"vin":
			return "Dồn vào giữa"
		"hout":
			return "Tách trái phải"
		"hin":
			return "Dồn giữa ngang"
	return "Đứng yên"

static func pad(value: int) -> String:
	return "0" + str(value) if value < 10 else str(value)




func fit() -> void :
	var z: float = 1.0
	if cols > 0 and rows > 0:
		z = minf(ON_ZOOM_MAX, minf(ON_FIT_W / float((cols + 1) * ON_PX), ON_FIT_H / float((rows + 1) * ON_PY)))
	if z < 1.0:
		z = 1.0
	pitch_x = roundi(float(ON_PX) * z)
	pitch_y = roundi(float(ON_PY) * z)
	ico = roundi(float(ON_ICON) * minf(float(pitch_x) / float(ON_PX), float(pitch_y) / float(ON_PY)))

func origin_x() -> int:
	return int(ON_CX - float(cols * pitch_x) / 2.0)

func origin_y() -> int:
	return int(ON_CY - float(rows * pitch_y) / 2.0)


func board_shown() -> bool:
	return live and not cells.is_empty() and atlas_ok()




func draw_path(path: Array) -> void :
	if not opened or path.size() < 2:
		return
	fit()
	var ox: int = origin_x() + pitch_x / 2
	var oy: int = origin_y() + pitch_y / 2
	var pts: Array = []
	for point: Array in path:
		pts.append([ox + int(point[0]) * pitch_x, oy + int(point[1]) * pitch_y])
	path_pts = pts
	path_at = now_ms()
	play_fx("fx_burst", float(pts[0][0]), float(pts[0][1]), 0.0)
	play_fx("fx_burst", float(pts[pts.size() - 1][0]), float(pts[pts.size() - 1][1]), 0.0)


func dot_at(part: float) -> Array:
	if part < 0.0 or path_pts.size() < 2:
		return []
	var total: float = 0.0
	for i in range(1, path_pts.size()):
		total += absf(float(path_pts[i][0]) - float(path_pts[i - 1][0])) + absf(float(path_pts[i][1]) - float(path_pts[i - 1][1]))
	var go: float = total * minf(1.0, part / 0.8)
	var px: float = float(path_pts[path_pts.size() - 1][0])
	var py: float = float(path_pts[path_pts.size() - 1][1])
	for i in range(1, path_pts.size()):
		var seg: float = absf(float(path_pts[i][0]) - float(path_pts[i - 1][0])) + absf(float(path_pts[i][1]) - float(path_pts[i - 1][1]))
		if seg > 0.0 and go <= seg:
			px = float(path_pts[i - 1][0]) + (float(path_pts[i][0]) - float(path_pts[i - 1][0])) * go / seg
			py = float(path_pts[i - 1][1]) + (float(path_pts[i][1]) - float(path_pts[i - 1][1])) * go / seg
			break
		go -= seg
	return [float(roundi(px - 8.0)), float(roundi(py - 8.0)), 1.0 if part < 0.8 else maxf(0.0, (1.0 - part) / 0.2)]


func play_fx(name: String, x: float, y: float, delay: float) -> void :
	if not opened or not ON_SHEETS.has(name) or art(name) == null:
		return
	var row: Array = ON_SHEETS[name]
	onfx.append({"kind": "frames", "name": name, "x": float(roundi(x - float(row[0]) / 2.0)), "y": float(roundi(y - float(row[1]) / 2.0)), 
		"at": now_ms() + delay})

func _drop_kind(kind: String) -> void :
	onfx = onfx.filter( func(fx: Dictionary) -> bool: return str(fx["kind"]) != kind)


func banner(name: String, text: String) -> void :
	if not opened:
		return
	if art(name) == null:
		float_text(text, 26)
		return
	_drop_kind("banner")
	onfx.append({"kind": "banner", "name": name, "at": now_ms()})


func gain(value: int) -> void :
	if not opened or value <= 0:
		return
	_drop_kind("gain")
	onfx.append({"kind": "gain", "text": "+" + str(value), "at": now_ms(), "y": 109.0})


func float_text(text: String, px: int) -> void :
	if not opened:
		return
	_drop_kind("float")
	onfx.append({"kind": "float", "text": text, "size": px, "at": now_ms(), "y": ON_FLOAT_Y})


func step_fx(at: float) -> void :
	var keep: Array = []
	for fx: Dictionary in onfx:
		var done: bool = false
		var kind: String = str(fx["kind"])
		if kind == "frames":
			if at >= float(fx["at"]):
				done = int((at - float(fx["at"])) / ON_FX_FRAME_MS) >= int(ON_SHEETS[str(fx["name"])][3])
		elif kind == "banner":
			done = (at - float(fx["at"])) / ON_BANNER_MS >= 1.0
		else:
			done = (at - float(fx["at"])) / ON_FLOAT_MS >= 1.0
		if not done:
			keep.append(fx)
	onfx = keep



func _width(text: String, px: float, font: Font) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f



func _ot(p: Vector2, w: float, h: float, px: float, color: int, glow: int, align: String, text: String, bold: bool, alpha: float = 1.0) -> void :
	if text.is_empty():
		return
	var font: Font = ARIAL_BOLD if bold else ARIAL
	var shown: float = px
	while shown > 5.0 and _width(text, shown, font) > w - 1.0:
		shown -= 0.5
	_fwords(text, font, shown, Color(rgb(color), alpha), align.substr(0, 1), p, w, 2.0 if glow >= 0 else 0.0, h, false, 
		rgb(glow) if glow >= 0 else SHADE)


func _wrap(text: String, px: float, w: float, indent: float) -> Array:
	var out: Array = []
	for para: String in text.split("\n"):
		var cur: String = ""
		var first: bool = true
		for word: String in para.split(" "):
			var room: float = w - (0.0 if first else indent)
			var tried: String = word if cur.is_empty() else cur + " " + word
			if cur.is_empty() or _width(tried, px, ARIAL) <= room - 1.0:
				cur = tried
			else:
				out.append([cur, 0.0 if first else indent])
				first = false
				cur = word
		out.append([cur, 0.0 if first else indent])
	return out


func _op(p: Vector2, w: float, h: float, px: float, color: int, align: String, text: String, leading: float, indent: float) -> void :
	var size: float = px
	var lines: Array = _wrap(text, size, w, indent)
	var high: float = float(lines.size()) * size * ON_LINE + float(lines.size() - 1) * leading
	while high > h and size > 10.0:
		size -= 1.0
		lines = _wrap(text, size, w, indent)
		high = float(lines.size()) * size * ON_LINE + float(lines.size() - 1) * leading
	var y: float = p.y + maxf(0.0, (h - high) / 2.0)
	for row: Array in lines:
		var off: float = float(row[1])
		_fwords(str(row[0]), ARIAL, size, rgb(color), align.substr(0, 1), Vector2(p.x + off, y), w - off, 1.5, size * ON_LINE, false, rgb(408373))
		y += size * ON_LINE + leading




static func digits_width(text: String) -> Array:
	var cursor: int = 0
	var wide: int = 1
	for i in text.length():
		var g: int = ON_GLYPHS.find(text[i])
		if g < 0:
			return [0, false]
		wide = maxi(wide, cursor + int(ON_GLYPH_W[g]))
		cursor += int(ON_GLYPH_A[g])
	return [wide, true]


func _glyphs(canvas: CanvasItem, text: String, at: Vector2, k: float, alpha: float = 1.0) -> void :
	var atlas: Texture2D = _load_atlas()
	var info: Array = digits_width(text)
	if atlas == null or not bool(info[1]):
		var size: int = maxi(6, roundi(28.0 * k * _f))
		canvas.draw_string(ARIAL_BOLD, at * _f + Vector2(0, ARIAL_BOLD.get_ascent(size)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(rgb(16771218), alpha))
		return
	var base: Array = OnAtlas.R["digits_gold"]
	var cursor: int = 0
	for i in text.length():
		var g: int = ON_GLYPHS.find(text[i])
		var src: Rect2 = Rect2(float(base[0]) + float(ON_GLYPH_X[g]), float(base[1]), float(ON_GLYPH_W[g]), 36.0)
		canvas.draw_texture_rect_region(atlas, Rect2((at + Vector2(float(cursor) * k, 0.0)) * _f, Vector2(float(ON_GLYPH_W[g]), 36.0) * k * _f), src, 
			Color(1, 1, 1, alpha))
		cursor += int(ON_GLYPH_A[g])

func _text_digits_width(text: String) -> float:
	var info: Array = digits_width(text)
	if bool(info[1]):
		return float(info[0])
	return ceilf(_width(text, 28.0, ARIAL_BOLD) + 8.0)


func _digits_box(canvas: CanvasItem, text: String, origin: Vector2, box: Rect2, k: float = 1.0) -> void :
	var dw: float = _text_digits_width(text)
	var s: float = minf(1.0, minf(box.size.x / dw, box.size.y / 36.0))
	var local: Vector2 = Vector2(float(roundi(box.position.x + (box.size.x - dw * s) / 2.0)), float(roundi(box.position.y + (box.size.y - 36.0 * s) / 2.0)))
	_glyphs(canvas, text, origin + local * k, s * k)



func _make_layer(kind: String, additive: bool) -> Control:
	var layer: Control = Control.new()
	layer.name = "Layer_" + kind
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	if additive:
		var mat: CanvasItemMaterial = CanvasItemMaterial.new()
		mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		layer.material = mat
	layer.draw.connect(_paint_layer.bind(layer, kind))
	add_child(layer)
	return layer

func _draw() -> void :
	super ()
	if _hover == "board":
		mouse_default_cursor_shape = CURSOR_ARROW
	for layer: Control in _layers:
		layer.queue_redraw()

func _gui_input(event: InputEvent) -> void :

	if opened and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _hit_at(event.position) == "board":
		_mouse = Vector2(-1, -1) if _mobile else event.position
		board_down(event.position / _f - frame_at())
		accept_event()
		return
	super (event)

func _lpic(canvas: CanvasItem, name: String, at: Vector2, alpha: float = 1.0, k: float = 1.0) -> void :
	var texture: Texture2D = art(name)
	if texture != null:
		canvas.draw_texture_rect(texture, Rect2(at * _f, Vector2(texture.get_size()) * k * _f), false, Color(1, 1, 1, alpha))

func combo_scale() -> float:
	var part: float = (now_ms() - combo_pop_at) / 300.0
	return 1.0 + 0.25 * sin(part * PI) if combo_pop_at != 0.0 and part < 1.0 else 1.0


func _paint_layer(canvas: Control, kind: String) -> void :
	if not opened or client == null or pack == null:
		return
	var at: Vector2 = frame_at()
	var box: Vector2 = at + Vector2(889, 198)
	var s: float = combo_scale()
	var combo_on: bool = loaded and live and combo > 1
	if kind == "add1":
		if loaded and live:
			_lpic(canvas, "sw_glint", at + Vector2(750, 106))
		if combo_on:
			_lpic(canvas, "combo_glow", box + Vector2(-41, -30) * s, 1.0, s)
	elif kind == "top1":
		if combo_on:
			_lpic(canvas, "combo_badge", box + Vector2(-37, -26) * s, 1.0, s)
			_digits_box(canvas, "x" + str(combo), box, Rect2(-20, -5, 43, 22), s)
	elif kind == "add2":
		var now: float = now_ms()
		if path_at != 0.0:
			var dot: Array = dot_at((now - path_at) / ON_PATH_MS)
			if not dot.is_empty() and (now - path_at) / ON_PATH_MS < 1.0:
				_lpic(canvas, "fx_link_dot", at + Vector2(float(dot[0]), float(dot[1])), float(dot[2]))
		for fx: Dictionary in onfx:
			if str(fx["kind"]) != "frames" or now < float(fx["at"]):
				continue
			var name: String = str(fx["name"])
			var row: Array = ON_SHEETS[name]
			var frame: int = int((now - float(fx["at"])) / ON_FX_FRAME_MS)
			if frame >= int(row[3]):
				continue
			canvas.draw_texture_rect_region(art(name), Rect2((at + Vector2(float(fx["x"]), float(fx["y"]))) * _f, Vector2(float(row[0]), float(row[1])) * _f), 
				sheet_region(name, frame))

func _chrome(at: Vector2) -> void :
	var cell_size: Vector2 = _cell_size("public_button_close")
	_fbutton("close", "public_button_close", at + Vector2(ON_W - 15.0 - cell_size.x, 15.0))

func _body(at: Vector2) -> void :
	pic("onet_bg", at)
	if not loaded:
		_ot(at + Vector2(16, 300), 714, 30, 16, 16774352, 408373, "center", "Đang tải...", true)
	else:
		_stats(at)
		_ranking(at)
		if not live:
			_intro(at)
		elif not atlas_ok():
			_ot(at + Vector2(16, 300), 714, 30, 16, 16774352, 408373, "center", "Đang tải hình...", true)
	_board(at)
	_draw_path(at)
	_draw_floats(at)


func _obutton(id: String, kind: String, p: Vector2, label: String, enabled: bool) -> void :
	var gold: bool = kind == "gold"
	var size: Vector2 = Vector2(220, 44) if gold else Vector2(188, 40)
	var face: String = "normal"
	if not enabled:
		face = "disabled"
	elif _press == id and (_hover == id or _mobile):
		face = "press"
	elif _hover == id and _press.is_empty():
		face = "hover"
	var texture: Texture2D = art("btn_" + kind + "_" + face)
	if texture != null:
		draw_texture_rect(texture, Rect2(p * _f, size * _f), false)
	else:
		_round(Rect2(p * _f, size * _f), Color(rgb(15247674 if gold else 12073003), 1.0 if enabled else 0.5), 16.0)
	var dy: float = 1.0 if face == "press" else 0.0
	if gold:
		_ot(p + Vector2(10, 5 + dy), 200, 32, 18, 6826770 if enabled else 6182216, -1, "center", label, true)
	else:
		_ot(p + Vector2(10, 5 + dy), 168, 28, 17, 16774352 if enabled else 14207416, 8134939 if enabled else 5917248, "center", label, true)
	if enabled:
		_hit(id, Rect2(p * _f, size * _f), false)


func _tab(index: int, p: Vector2, label: String) -> void :
	var on: bool = tab == index
	var id: String = "tab:%d" % index
	var name: String = "tab_on" if on else ("tab_hover" if _hover == id and not _mobile else "tab_off")
	var texture: Texture2D = art(name)
	if texture != null:
		draw_texture_rect(texture, Rect2(p * _f, Vector2(62, 26) * _f), false)
	else:
		_round(Rect2(p * _f, Vector2(62, 26) * _f), rgb(16044666 if on else 3042142), 10.0)
	_ot(p + Vector2(3, 4), 56, 18, 12, 1195577 if on else 16774352, -1, "center", label, true)
	if not on:
		_hit(id, Rect2(p * _f, Vector2(62, 26) * _f), false)


func _arrow(p: Vector2, degrees: float, k: float) -> void :
	var texture: Texture2D = art("mode_arrow")
	draw_set_transform(p * _f, deg_to_rad(degrees), Vector2(k, k))
	if texture != null:
		draw_texture_rect(texture, Rect2(Vector2(-8, -8) * _f, Vector2(16, 16) * _f), false)
	else:
		draw_colored_polygon(PackedVector2Array([Vector2(-6, -4) * _f, Vector2(6, -4) * _f, Vector2(0, 5) * _f]), rgb(16771218))
	draw_set_transform_matrix(Transform2D.IDENTITY)

func _arrows(at: Vector2) -> void :
	match mode:
		"down":
			_arrow(at + Vector2(846, 87), 0, 1)
		"left":
			_arrow(at + Vector2(846, 87), 90, 1)
		"up":
			_arrow(at + Vector2(846, 87), 180, 1)
		"right":
			_arrow(at + Vector2(846, 87), 270, 1)
		"vout":
			_arrow(at + Vector2(845, 81), 180, 0.625)
			_arrow(at + Vector2(845, 93), 0, 0.625)
		"vin":
			_arrow(at + Vector2(845, 81), 0, 0.625)
			_arrow(at + Vector2(845, 93), 180, 0.625)
		"hout":
			_arrow(at + Vector2(845, 81), 90, 0.625)
			_arrow(at + Vector2(845, 93), 270, 0.625)
		"hin":
			_arrow(at + Vector2(845, 81), 270, 0.625)
			_arrow(at + Vector2(845, 93), 90, 0.625)


func _ring(at: Vector2, name: String, fraction: float) -> void :
	var atlas: Texture2D = _load_atlas()
	if atlas == null or fraction <= 0.0 or not OnAtlas.R.has(name):
		return
	var reg: Array = OnAtlas.R[name]
	var corner: Vector2 = Vector2(750, 106)
	var centre: Vector2 = Vector2(795, 171)
	var pts: Array = []
	if fraction >= 0.999:
		for i in 73:
			var a: float = - PI / 2.0 + TAU * float(i) / 72.0
			pts.append(centre + Vector2(cos(a), sin(a)) * 36.0)
	else:
		var steps: int = ceili(72.0 * fraction)
		for i in steps + 1:
			var a: float = - PI / 2.0 + TAU * fraction * float(i) / float(steps)
			pts.append(centre + Vector2(cos(a), sin(a)) * 36.0)
	var tex_size: Vector2 = Vector2(atlas.get_size())
	var origin: Vector2 = Vector2(float(reg[0]), float(reg[1])) - corner
	for i in pts.size() - 1:
		var tri: Array = [centre, pts[i], pts[i + 1]]
		var points: PackedVector2Array = []
		var uvs: PackedVector2Array = []
		for q: Vector2 in tri:
			points.append((at + q) * _f)
			uvs.append((origin + q) / tex_size)
		draw_polygon(points, PackedColorArray([Color.WHITE, Color.WHITE, Color.WHITE]), uvs, atlas)

func _stats(at: Vector2) -> void :
	var left_turns: String = str(maxi(0, turns_max - used)) + "/" + str(turns_max)
	if live:
		pic("stage_badge", at + Vector2(754, 73))
		_ot(at + Vector2(760, 77), 60, 19, 16, 16774352, 7938841, "center", "ẢI " + str(bn), true)
		pic("mode_chip", at + Vector2(832, 73))
		_arrows(at)
		_ot(at + Vector2(857, 78), 70, 18, 12, 16774352, -1, "center", mode_name(mode), true)
		pic("sw_body", at + Vector2(750, 106))
		var ms: float = maxf(0.0, ends_at - now_ms())
		var secs: int = ceili(ms / 1000.0)
		var low: bool = secs <= 30
		_ring(at, "sw_ring_low" if low else "sw_ring", ms / (float(sec) * 1000.0))
		_ot(at + Vector2(769, 160), 52, 23, 18, 16747120 if low else 16774352, 408373, "center", pad(secs / 60) + ":" + pad(secs % 60), true)

		pic("score_label", at + Vector2(854, 112))
		_digits_box(self, str(score), at, Rect2(844, 136, 90, 36))

		pic("pairs_bar", at + Vector2(755, 227))
		var count: int = 0
		for k: Variant in cells:
			if int(k) >= 0:
				count += 1
		_ot(at + Vector2(762, 230), 162, 16, 12, 16774352, -1, "center", "Cặp còn: " + str(count / 2), true)
		var label: String = "ĐANG KẾT THÚC..." if end_wanted or action == "end" else ("BẤM LẦN NỮA ĐỂ DỪNG" if arm_at != 0.0 else "ĐẦU HÀNG")
		_obutton("surrender", "red", at + Vector2(751, 258), label, not busy())
		_ot(at + Vector2(751, 303), 188, 17, 12, 16774352, -1, "center", "Lượt còn: " + left_turns, false)
		return
	pic("stat_plate", at + Vector2(755, 85))
	pic("stat_plate", at + Vector2(755, 155))
	_ot(at + Vector2(765, 91), 156, 18, 13, 16774352, -1, "center", "Lượt còn lại hôm nay", false)
	_ot(at + Vector2(765, 110), 156, 27, 21, 16771218, 408373, "center", left_turns, true)
	_ot(at + Vector2(765, 161), 156, 18, 13, 16774352, -1, "center", "Kỷ lục hôm nay", false)
	_ot(at + Vector2(765, 180), 156, 27, 21, 16771218, 408373, "center", num(best) if best > 0 else "—", true)
	_ot(at + Vector2(755, 228), 176, 18, 12, 14218973, -1, "center", "Hạng hôm nay: " + str(rank) + " · Ải " + str(bst) if rank > 0 else "Chưa có điểm hôm nay", false)
	_op(at + Vector2(755, 267), 180, 45, 14, 16774352, "center", "Mỗi ngày " + str(turns_max) + " lượt miễn phí\nLượt mới lúc 00:00", 4, 0)


func _reward(p: Vector2, k: float, id: int, count: int) -> void :
	var spot: Dictionary = LeagueAward.TILE
	_fblit("la_tile", p + Vector2(float(spot["bg"][0]), float(spot["bg"][1])) * k, 68.0 * k, 68.0 * k)
	var info: Dictionary = item(id)
	var quality: int = int(info["quality"])
	if quality >= 2 and quality <= 5:
		_fblit("la_q%d" % quality, p + Vector2(float(spot["quality"][0]), float(spot["quality"][1])) * k, 56.0 * k, 56.0 * k)
	var box: Array = spot["item"]
	var path: String = str(info["art"])
	var picture: Texture2D = pack.picture(path) if not path.is_empty() else null
	if picture != null and picture.get_width() > 4:
		var fit_k: float = minf(float(box[2]) / picture.get_width(), float(box[3]) / picture.get_height())
		draw_texture_rect(picture, Rect2((p + Vector2(float(box[0]), float(box[1])) * k) * _f, Vector2(picture.get_size()) * fit_k * k * _f), false)
	var label: Array = spot["lblNum"]
	_fwords(str(count), ARIAL_BOLD, 12.0 * k, Color.WHITE, "c", p + Vector2(float(label[0]), float(label[1])) * k, float(label[2]) * k)
	tip_area(Rect2(p + Vector2(4, 0) * k, Vector2(68, 68) * k), id, "")

func _ranking(at: Vector2) -> void :
	var labels: Array = ["Hôm nay", "Hôm qua", "Quà"]
	for i in 3:
		_tab(i, at + Vector2(749 + i * 64, 359), str(labels[i]))
	pic("me_strip", at + Vector2(750, 535))
	if tab == 2:
		var ry: int = 388
		for tier: Dictionary in tiers:
			var items: Array = []
			for part: String in str(tier["it"]).split(","):
				var bits: PackedStringArray = part.split(":")
				if bits.size() > 1 and TevWheel.as_int(bits[0]) > 0:
					items.append(bits)
			if not items.is_empty() and ry <= 496:
				var a: int = int(tier["a"])
				var b: int = int(tier["b"])
				_ot(at + Vector2(754, ry + 10), 62, 16, 12, 16774352, -1, "left", "Hạng " + str(a) if a == b else "Hạng " + str(a) + "-" + str(b), true)
				for j in mini(3, items.size()):
					_reward(at + Vector2(816 + j * 40, ry), 0.46, TevWheel.as_int(items[j][0]), maxi(1, TevWheel.as_int(items[j][1])))
				ry += 36
		if ry == 388:
			_op(at + Vector2(755, 420), 180, 60, 12, 16774352, "center", "Phần thưởng xếp hạng sẽ được công bố sau.", 2, 0)
		_ot(at + Vector2(750, 537), 188, 16, 11, 16773495, -1, "center", "Quà gửi vào Hộp thư sau 00:00", true)
		return
	var list: Array = top if tab == 0 else ytop
	_ot(at + Vector2(751, 386), 20, 14, 10, 16771764, -1, "center", "#", true)
	_ot(at + Vector2(774, 386), 72, 14, 10, 16771764, -1, "left", "Tên", true)
	_ot(at + Vector2(849, 386), 49, 14, 10, 16771764, -1, "center", "Điểm", true)
	_ot(at + Vector2(903, 386), 30, 14, 10, 16771764, -1, "center", "Ải", true)
	var i: int = 0
	for row: Dictionary in list:
		if i < 10:
			var ry: int = 402 + i * 13
			var place: int = int(row["r"])
			if i % 2 == 0:
				pic("row_band", at + Vector2(750, ry))
			var color: int = 16773495 if bool(row["me"]) else 16774352
			if place >= 1 and place <= 3 and art("medal_%d" % place) != null:
				pic("medal_%d" % place, at + Vector2(752, ry))
				_ot(at + Vector2(755, ry + 2), 8, 10, 9, 4074525, -1, "center", str(place), true)
			else:
				_ot(at + Vector2(751, ry), 20, 13, 11, color, -1, "center", str(place), false)
			_ot(at + Vector2(774, ry), 72, 13, 11, color, -1, "left", str(row["n"]), false)
			_ot(at + Vector2(849, ry), 49, 13, 11, color, -1, "right", num(int(row["s"])), false)
			_ot(at + Vector2(903, ry), 30, 13, 11, color, -1, "center", str(int(row["a"])), false)
		i += 1
	if i == 0:
		_ot(at + Vector2(750, 440), 188, 20, 12, 16774352, -1, "center", "Chưa có ai ghi điểm" if tab == 0 else "Hôm qua chưa có ai ghi điểm", false)
	if tab == 0 and rank > 0:
		_ot(at + Vector2(751, 537), 20, 16, 11, 16773495, -1, "center", str(rank), true)
		_ot(at + Vector2(774, 537), 72, 16, 11, 16773495, -1, "left", "Bạn", true)
		_ot(at + Vector2(849, 537), 49, 16, 11, 16773495, -1, "right", num(best), true)
		_ot(at + Vector2(903, 537), 30, 16, 11, 16773495, -1, "center", str(bst), true)
	elif tab == 1 and yrank > 0:
		_ot(at + Vector2(751, 537), 20, 16, 11, 16773495, -1, "center", str(yrank), true)
		_ot(at + Vector2(774, 537), 72, 16, 11, 16773495, -1, "left", "Bạn · đã gửi quà" if yset and not yit.is_empty() else "Bạn", true)
		_ot(at + Vector2(849, 537), 49, 16, 11, 16773495, -1, "right", num(ybest), true)
	else:
		_ot(at + Vector2(750, 537), 188, 16, 11, 16773495, -1, "center", "Bạn chưa có điểm hôm nay" if tab == 0 else "Hôm qua bạn chưa có hạng", true)


func _intro(at: Vector2) -> void :
	var free_turn: bool = used < turns_max
	if art("card_frame") != null:
		pic("card_frame", at + Vector2(113, 116))
	else:
		_round(Rect2((at + Vector2(113, 116)) * _f, Vector2(520, 400) * _f), Color(rgb(739907), 0.95), 28.0)
	if result != null:
		var res: Dictionary = result
		pic("ribbon_result", at + Vector2(218, 112))
		_ot(at + Vector2(173, 199), 400, 23, 17, 14087133, -1, "center", "ĐIỂM CỦA BẠN", false)
		_digits_box(self, str(int(res["score"])), at, Rect2(253, 232, 240, 36))
		var chips: Array = ["Ải " + str(int(res["bn"])), str(int(res["pairs"])) + " cặp", "x" + str(int(res["mc"]))]
		var icons: Array = ["ico_stage", "ico_pairs", "ico_combo"]
		for k in 3:
			pic("chip_plate", at + Vector2(173 + 140 * k, 304))
			pic(str(icons[k]), at + Vector2(185 + 140 * k, 309))
			_ot(at + Vector2(210 + 140 * k, 309), 69, 20, 13, 16774352, -1, "center", str(chips[k]), true)
		var msg: String = "Lượt chơi đã kết thúc."
		if best > 0:
			msg = "Kỷ lục hôm nay: " + num(best) + " điểm" + (" · Hạng " + str(rank) if rank > 0 else "")
		_op(at + Vector2(158, 361), 430, 54, 16, 16774352, "center", msg + "\nChỉ ván điểm cao nhất trong ngày được xếp hạng.", 6, 0)
	else:
		pic("ribbon_rules", at + Vector2(218, 112))
		var rules: String = ("• Nối 2 hình giống nhau bằng đường gấp khúc rẽ tối đa 2 lần, được đi vòng ngoài bàn.\n"
			+ "• Mỗi ải có " + str(sec) + " giây. Dọn sạch bàn để qua ải mới lớn hơn, khó hơn.\n"
			+ "• Từ Ải 3, hình còn lại dồn theo hướng của ải sau mỗi lần nối.\n"
			+ "• Nối liên tiếp trong " + str(cms / 1000) + " giây để tăng Combo và điểm thưởng.\n"
			+ "• Hết giờ là hết ván; Đầu hàng vẫn giữ điểm đã đạt.\n"
			+ "• Ván điểm cao nhất trong ngày được xếp hạng."
			+ ("\n• Yêu cầu cấp " + str(lv) + "." if lv > 0 else ""))
		_op(at + Vector2(157, 191), 432, 218, 16, 16774352, "left", rules, 6, 10)
		_ot(at + Vector2(157, 412), 432, 22, 14, 12513242, -1, "center", "Chủ đề hôm nay: " + on_theme if not on_theme.is_empty() else "Chọn BẮT ĐẦU khi bạn đã sẵn sàng.", false)
	var label: String = "ĐANG VÀO..." if action == "start" else ("BẮT ĐẦU" if free_turn else "HẾT LƯỢT HÔM NAY")
	_obutton("start", "gold", at + Vector2(263, 448), label, free_turn and not busy())


func _board(at: Vector2) -> void :
	fit()
	if not board_shown() or cols <= 0 or rows <= 0:
		return
	var atlas: Texture2D = _load_atlas()
	var tiles: Array = OnAtlas.R["tiles"]
	var native: bool = pitch_x == ON_PX and pitch_y == ON_PY
	var o: Vector2 = at + Vector2(origin_x(), origin_y())
	var size: Vector2 = Vector2(pitch_x, pitch_y)
	for i in cells.size():
		var k: int = int(cells[i])
		if k < 0:
			continue
		var cp: Vector2 = o + Vector2(float(i % cols * pitch_x), float(i / cols * pitch_y))
		var plate: Texture2D = art(("tile_plate_sel_glow" if i == sel else "tile_plate") + ("" if native else "_2x"))
		if plate != null:
			draw_texture_rect(plate, Rect2(cp * _f, size * _f), false)
		else:
			draw_rect(Rect2((cp + Vector2.ONE) * _f, (size - Vector2(2, 2)) * _f), Color8(255, 236, 64) if i == sel else Color8(243, 222, 192))
		if k < kinds.size():
			var t: int = int(kinds[k])
			var src: Rect2 = Rect2(float(t % acols * cell), float(t / acols * cell), float(cell), float(cell))
			if t >= 0 and src.end.x <= float(tiles[2]) and src.end.y <= float(tiles[3]):
				src.position += Vector2(float(tiles[0]), float(tiles[1]))
				var spot: Vector2 = cp + Vector2(float((pitch_x - ico) / 2), float(roundi(4.0 * float(pitch_y) / float(ON_PY))))
				draw_texture_rect_region(atlas, Rect2(spot * _f, Vector2(ico, ico) * _f), src)
	_hit("board", Rect2((at + Vector2(16, 66)) * _f, Vector2(714, 500) * _f), false)

func _cap(p: Vector2, dir: Vector2, radius: float, color: Color) -> void :
	var points: PackedVector2Array = []
	for j in 9:
		points.append(p + dir.rotated( - PI / 2.0 + PI * float(j) / 8.0) * radius)
	draw_colored_polygon(points, color)


func _draw_path(at: Vector2) -> void :
	if path_at == 0.0 or path_pts.size() < 2 or not board_shown():
		return
	var part: float = (now_ms() - path_at) / ON_PATH_MS
	if part >= 1.0:
		return
	var alpha: float = 1.0 if part < 0.5 else (1.0 - part) * 2.0
	var pts: PackedVector2Array = []
	for point: Array in path_pts:
		pts.append((at + Vector2(float(point[0]), float(point[1]))) * _f)
	var glow: Color = rgb(16765272)
	var first_dir: Vector2 = (pts[0] - pts[1]).normalized()
	var last_dir: Vector2 = (pts[pts.size() - 1] - pts[pts.size() - 2]).normalized()
	for pass_w: Array in [[16.0, 0.12], [11.0, 0.2], [6.0, 0.45]]:
		var ink: Color = Color(glow, float(pass_w[1]) * alpha)
		draw_polyline(pts, ink, float(pass_w[0]) * _f, true)
		_cap(pts[0], first_dir, float(pass_w[0]) * _f / 2.0, ink)
		_cap(pts[pts.size() - 1], last_dir, float(pass_w[0]) * _f / 2.0, ink)
	var core: Color = Color(rgb(16773546), alpha)
	draw_polyline(pts, core, 2.0 * _f, true)
	_cap(pts[0], first_dir, _f, core)
	_cap(pts[pts.size() - 1], last_dir, _f, core)


func _draw_floats(at: Vector2) -> void :
	var now: float = now_ms()
	for fx: Dictionary in onfx:
		var kind: String = str(fx["kind"])
		if kind == "banner":
			var part: float = (now - float(fx["at"])) / ON_BANNER_MS
			if part >= 1.0:
				continue
			var s: float = 0.6 + 0.5 * part / 0.12 if part < 0.12 else (1.1 - 0.1 * (part - 0.12) / 0.08 if part < 0.2 else 1.0)
			var alpha: float = 1.0 if part < 0.75 else (1.0 - part) / 0.25
			var texture: Texture2D = art(str(fx["name"]))
			if texture != null:
				draw_texture_rect(texture, Rect2((at + Vector2(ON_CX, ON_CY) + Vector2(-150, -45) * s) * _f, Vector2(texture.get_size()) * s * _f), false, Color(1, 1, 1, alpha))
		elif kind == "gain" or kind == "float":
			var part: float = (now - float(fx["at"])) / ON_FLOAT_MS
			if part >= 1.0:
				continue
			var alpha: float = 1.0 if part < 0.7 else (1.0 - part) / 0.3
			var y: float = float(fx["y"]) - float(int(30.0 * part))
			if kind == "gain":
				var k: float = 28.0 / 36.0
				var dw: float = _text_digits_width(str(fx["text"]))
				_glyphs(self, str(fx["text"]), at + Vector2(float(roundi(ON_CX - dw * k / 2.0)), y), k, alpha)
			else:
				_ot(at + Vector2(16, y), 714, 44, float(fx["size"]), 16774352, 408373, "center", str(fx["text"]), true, alpha)




static func parse_deep(text: String) -> Variant:
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
			if stack.is_empty() or str((stack.back() as Dictionary)["tag"]) != name:
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
		else:
			((stack.back() as Dictionary)["kids"] as Array).append(node)
		if found.get_string(4) == "/":
			if stack.is_empty():
				ended = true
		else:
			stack.append(node)
	var tail: String = text.substr(cursor)
	if root.is_empty() or not stack.is_empty() or tail.contains("<") or not tail.strip_edges().is_empty():
		return null
	return root
