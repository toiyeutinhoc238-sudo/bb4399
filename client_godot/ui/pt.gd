extends "tev_window.gd"











signal closed(note: String)

const OnAtlas = preload("on_atlas.gd")
const PtAtlas = preload("pt_atlas.gd")
const On = preload("on.gd")
const LeagueAward = preload("league_award_atlas.gd")
const TevWheel = preload("tev_wheel.gd")
const PT_TIP: String = "Pháo Thủ Bắn Bia"
const POLL_TICKS: int = 120
const ARM_MS: float = 4000.0
const PT_W: float = 960.0
const PT_H: float = 580.0
const PT_CX: float = 370.0
const PT_CY: float = 315.0
const FLOAT_MS: float = 1400.0
const BANNER_MS: float = 1200.0
const RETRY_MS: float = 1000.0
const RETRIES: int = 5
const IDLE_NOTE: String = "Ván Pháo Thủ Bắn Bia vẫn đang mở, mở lại để bắn tiếp."

const W: float = 700.0
const GROUND: float = 428.0
const PX: float = 88.0
const PY: float = 338.0
const BARREL: float = 48.0
const G: float = 520.0
const VMIN: float = 180.0
const VMAX: float = 620.0
const WIND_K: int = 12
const BR: float = 7.0
const MAX_STEPS: int = 900
const A_MAX: int = 850
const V_MIN: int = 10
const BULL: float = 0.4
const DT: float = 1.0 / 120.0
const DT_MS: float = 1000.0 / 120.0

const FIELD_X: float = 28.0
const FIELD_Y: float = 74.0
const FIELD_W: float = 684.0
const FIELD_H: float = 482.0
const S: float = 684.0 / 700.0
const OY: float = 87.0
const AIM_NEAR: float = 30.0
const AIM_FAR: float = 230.0
const RULES: String = ("• Nhấn giữ trên trường bắn rồi kéo để chỉnh góc và lực, thả tay để bắn (kéo ra sau pháo để huỷ).\n"
	+ "• Gió đổi sau mỗi phát: xem cờ gió và con số trên cao.\n"
	+ "• Hạ hết bia, bóng bay, bia bay để qua ải; ải sau xa hơn, nhỏ hơn, nhanh hơn, có thêm cột chắn.\n"
	+ "• Mỗi ải có số đạn giới hạn, hết đạn là hết ván.\n")

static var s_pt_shown: bool = false
static var _pt_tex: Texture2D = null
static var _on_tex: Texture2D = null
static var _tex_tried: bool = false

var poll_in: int = 4
var pt_visible: bool = false
var loaded: bool = false
var token: String = ""
var used: int = 0
var turns_max: int = 0
var lv: int = 0
var gap: int = 900
var pts: Dictionary = {"pb": 100, "pl": 60, "pm": 150, "pbu": 100, "cp": 20, "cm": 5, "pc": 50, "pa": 30}
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
var score: int = 0
var shots: int = 0
var hits: int = 0
var bulls: int = 0
var combo: int = 0
var max_combo: int = 0
var stage_no: int = 0
var stage: Dictionary = {}
var stage_at: float = 0.0
var end_wanted: bool = false
var quit: bool = false
var result: Variant = null
var aim_a: int = 450
var aim_v: int = 60
var aiming: bool = false
var aim_cancel: bool = false
var queued: bool = false
var fly: Dictionary = {}
var gust_note: Dictionary = {}
var gst: bool = false
var pending: Array = []
var shot_url: String = ""
var retry_at: float = 0.0
var retries: int = 0
var combo_pop_at: float = 0.0
var pfx: Array = []
var floats: Array = []
var now_skew: float = 0.0

var _parts: Dictionary = {}

func _setup() -> void :
	art_dir = ""
	art_files = []
	win_size = Vector2(PT_W, PT_H)
	super ()
	var regions: Dictionary = {}
	for name: String in ["la_tile", "la_q2", "la_q3", "la_q4", "la_q5"]:
		regions[name] = LeagueAward.R[name]
	_use(LeagueAward.FILE, regions)
	pt_visible = s_pt_shown

static func reset_statics() -> void :
	s_pt_shown = false

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
	pt_visible = false
	loaded = false
	token = ""
	used = 0
	turns_max = 0
	lv = 0
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
	result = null
	score = 0
	pfx = []
	floats = []
	reset_statics()



static func r3(v: float) -> float:
	return floor(v * 1000.0 + 0.5) / 1000.0


static func offset(o: Dictionary, t_ms: float) -> float:
	var am: float = float(o["am"])
	var pe: float = float(o["pe"])
	if am == 0.0 or pe == 0.0:
		return 0.0
	var u: float = t_ms / pe + float(o["ph"]) / 1000.0
	var f: float = u - floor(u)
	var tri: float = 1.0 - 4.0 * absf(f - 0.5)
	return am * (tri * (1.5 - 0.5 * tri * tri))


static func pos_at(o: Dictionary, t_ms: float) -> Array:
	var d: float = offset(o, t_ms)
	if str(o["ax"]) == "y":
		return [float(o["x"]), float(o["y"]) + d]
	return [float(o["x"]) + d, float(o["y"])]




static func sim(st: Dictionary, alive: Array, a: int, v: int, wind: int, t0: float, path: Variant = null, gust: Dictionary = {}) -> Dictionary:
	var rad: float = float(a) * PI / 1800.0
	var speed: float = VMIN + (VMAX - VMIN) * float(v) / 100.0
	var vx: float = r3(speed * cos(rad))
	var vy: float = r3( - speed * sin(rad))
	var x: float = r3(PX + BARREL * cos(rad))
	var y: float = r3(PY - BARREL * sin(rad))
	var ax: float = float(wind * WIND_K)
	var gk: int = MAX_STEPS + 1
	var gax: float = ax
	var gay: float = G
	if not gust.is_empty():
		gk = int(gust.get("k", MAX_STEPS + 1))
		gax = ax + float(int(gust.get("x", 0)) * WIND_K) / 1000.0
		gay = G + float(int(gust.get("y", 0)) * WIND_K) / 1000.0
	var walls: Array = st.get("o", [])
	var targets: Array = st.get("t", [])
	var record: bool = path is Array
	for k in range(1, MAX_STEPS + 1):
		if k < gk:
			vx += ax * DT
			vy += G * DT
		else:
			vx += gax * DT
			vy += gay * DT
		x += vx * DT
		y += vy * DT
		if record:
			(path as Array).append(Vector2(x, y))
		var tt: float = t0 + float(k) * DT_MS
		for i in range(walls.size()):
			var o: Dictionary = walls[i]
			var op: Array = pos_at(o, tt)
			var ox: float = op[0]
			var oy: float = op[1]
			if x >= ox - BR and x <= ox + float(o["w"]) + BR and y >= oy - BR and y <= oy + float(o["h"]) + BR:
				return {"k": k, "x": x, "y": y, "what": "o", "i": i, "bull": false}
		for i in range(targets.size()):
			if i >= alive.size() or not int(alive[i]):
				continue
			var tg: Dictionary = targets[i]
			var tp: Array = pos_at(tg, tt)
			var dx: float = x - float(tp[0])
			var dy: float = y - float(tp[1])
			var d2: float = dx * dx + dy * dy
			var rr: float = float(tg["r"]) + BR
			if d2 <= rr * rr:
				var cr: float = dx * vy - dy * vx
				var br: float = float(tg["r"]) * BULL
				return {"k": k, "x": x, "y": y, "what": "t", "i": i, "bull": str(tg["k"]) != "l" and cr * cr <= br * br * (vx * vx + vy * vy)}
		if y >= GROUND:
			return {"k": k, "x": x, "y": y, "what": "g", "i": -1, "bull": false}
		if x > W + 40.0 or x < -40.0:
			return {"k": k, "x": x, "y": y, "what": "x", "i": -1, "bull": false}
	return {"k": MAX_STEPS, "x": x, "y": y, "what": "x", "i": -1, "bull": false}


static func world(x: float, y: float) -> Vector2:
	return Vector2(FIELD_X + x * S, OY + y * S)

static func pivot() -> Vector2:
	return world(PX, PY)



static func _textures() -> void :
	if _tex_tried:
		return
	_tex_tried = true
	if ResourceLoader.exists(PtAtlas.FILE):
		_pt_tex = load(PtAtlas.FILE) as Texture2D
	if ResourceLoader.exists(OnAtlas.FILE):
		_on_tex = load(OnAtlas.FILE) as Texture2D

func load_art() -> void :
	_art_asked = true

func art_pending() -> int:
	return 0 if _art_asked else -1

func retry_art() -> void :
	pass

func art(name: String) -> Texture2D:
	if _parts.has(name):
		return _parts[name]
	_textures()
	var row: Array = []
	var atlas: Texture2D = null
	if PtAtlas.R.has(name):
		row = PtAtlas.R[name]
		atlas = _pt_tex
	elif OnAtlas.R.has(name):
		row = OnAtlas.R[name]
		atlas = _on_tex
	if atlas == null:
		return null
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = atlas
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part

func button_icon() -> Texture2D:
	return art("btn_pt")

func button_word() -> Texture2D:
	return art("word_pt")


func _spr(name: String, rect: Rect2, alpha: float = 1.0) -> void :
	var texture: Texture2D = art(name)
	if texture != null:
		draw_texture_rect(texture, Rect2(rect.position * _f, rect.size * _f), false, Color(1, 1, 1, alpha))


func _spr_c(name: String, centre: Vector2, wide: float, rot: float = 0.0, alpha: float = 1.0, flip: bool = false) -> void :
	var texture: Texture2D = art(name)
	if texture == null:
		return
	var size: Vector2 = Vector2(wide, wide * float(texture.get_height()) / float(texture.get_width()))
	draw_set_transform(centre * _f, rot, Vector2(-1.0 if flip else 1.0, 1.0))
	draw_texture_rect(texture, Rect2( - size / 2.0 * _f, size * _f), false, Color(1, 1, 1, alpha))
	draw_set_transform_matrix(Transform2D.IDENTITY)



func boot() -> void :
	poll_in = POLL_TICKS
	if not loading:
		load_pt("/cannon.xml?t=", "poll")

func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = POLL_TICKS
		if not loading:
			load_pt("/cannon.xml?t=", "poll")

func button_visible() -> bool:
	return pt_visible

func button_dot() -> bool:
	return pt_visible and (live or used < turns_max)

func refresh_button() -> void :
	queue_redraw()

func busy() -> bool:
	return action == "start" or action == "end" or end_wanted

func open() -> void :
	if opened or not pt_visible:
		return
	arm_at = 0.0
	tab = 0
	aiming = false
	show_window()
	load_art()
	if pack != null:
		pack.load_bag()
	if action.is_empty() or action == "poll":
		load_pt("/cannon.xml?t=", "poll")

func close(note: String = "") -> void :
	if not opened:
		return
	if live:
		note = IDLE_NOTE
	hide_window()
	arm_at = 0.0
	aiming = false
	queued = false
	end_wanted = false
	pfx = []
	floats = []
	poll_in = POLL_TICKS
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



func load_pt(prefix: String, what: String) -> void :
	fetch(prefix + str(int(now_ms())), what)

func _failed(what: String) -> void :
	if what == "shot":
		retry_at = now_ms() + RETRY_MS
		retries += 1
		return
	if what == "start" or what == "end":
		tip("Không kết nối được máy chủ, hãy thử lại.")

static func _int(at: Dictionary, key: String) -> int:
	return TevWheel.as_int(str(at.get(key, "")))

static func _row(node: Dictionary) -> Dictionary:
	var at: Dictionary = node["at"]
	return {"r": _int(at, "r"), "n": str(at.get("n", "")), "s": _int(at, "s"), "a": _int(at, "a"), "me": str(at.get("me", "")) == "1"}

static func _evs(xml: Variant) -> PackedStringArray:
	if not (xml is Dictionary):
		return PackedStringArray()
	for node: Dictionary in kids(xml, "run"):
		return str(node["at"].get("ev", "")).split(",", false)
	return PackedStringArray()


static func _parse(text: String) -> Variant:
	var xml: Variant = On.parse_deep(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	return xml

func _reply(text: String, what: String) -> void :
	var xml: Variant = _parse(text)
	if what == "shot" and not fly.is_empty():
		var evs: PackedStringArray = _evs(xml)
		if xml != null and (evs.has("sync") or evs.has("bad") or evs.has("fast")):
			fly = {}
		elif xml != null and take_shot(xml):
			pending = [text, now_ms()]
			return
		elif xml != null:
			fly["ok"] = true
			pending = [text, now_ms()]
			return

	take_reply(xml, what, now_ms())



func take_shot(xml: Dictionary) -> bool:
	for node: Dictionary in kids(xml, "run"):
		for kid: Dictionary in node["kids"]:
			if str(kid["tag"]) != "shot":
				continue
			var a: Dictionary = kid["at"]
			var res: Dictionary = fly["res"]
			if a.has("gx") and a.has("gy") and a.has("gk"):
				var gust: Dictionary = {"k": _int(a, "gk"), "x": _int(a, "gx"), "y": _int(a, "gy")}
				var pts: Array = []
				res = sim(stage, stage["alive"], int(fly["a"]), int(fly["v"]), int(fly.get("w", stage.get("wind", 0))), float(int(fly["t0"])), pts, gust)
				fly["path"] = PackedVector2Array(pts)
				gust_note = {"x": int(gust["x"]), "y": int(gust["y"]), "l": clampi(_int(a, "gl"), 1, 3), "at": now_ms()}
			var what: String = str(a.get("what", ""))
			if not what.is_empty() and (what != str(res["what"]) or _int(a, "i") != int(res["i"]) or _int(a, "k") != int(res["k"])):
				var size: int = (fly["path"] as PackedVector2Array).size()
				res = {"k": clampi(_int(a, "k"), 1, maxi(1, size)), "x": float(_int(a, "x")), "y": float(_int(a, "y")), "what": what, "i": _int(a, "i"), 
					"bull": false}
			if not what.is_empty():
				res["bull"] = str(a.get("bull", "")) == "1"
			fly["res"] = res
			fly["ok"] = true
			return true
	return false


func take_reply(xml: Variant, what: String, came: float) -> void :
	var was_live: bool = live
	var notice: String = ""
	var light: bool = false
	if what == "poll":
		fly = {}
		pending = []
	if xml != null:
		var at: Dictionary = xml["at"]
		notice = str(at.get("notice", ""))
		light = str(at.get("light", "")) == "1"
		pt_visible = str(at.get("visible", "")) == "1"
		s_pt_shown = pt_visible
		if pt_visible and not light:
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
			lv = _int(at, "lv")
			gap = maxi(0, _int(at, "gap"))
			gst = str(at.get("gst", "")) == "1"
			for key: String in pts:
				pts[key] = _int(at, key)
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
		if what == "shot":
			retry_at = now_ms() + RETRY_MS
			retries += 1
			return
		if what == "start" or what == "end":
			notice = "Thao tác chưa thành công, hãy thử lại sau."
	elif not pt_visible:
		reset_run()
	else:
		if what == "shot":
			retries = 0
			retry_at = 0.0
		var runs: Array = kids(xml, "run")
		if not runs.is_empty():
			take_run(runs[0], came)
		elif not light:
			reset_run()
	refresh_button()
	if opened and not pt_visible:
		close()
	if not notice.is_empty():
		tip(notice)
	if light and was_live and not live and pt_visible:
		load_pt("/cannon.xml?t=", "poll")
		return
	pump()

func reset_run() -> void :
	live = false
	stage = {}
	fly = {}
	pending = []
	queued = false
	aiming = false
	end_wanted = false
	retry_at = 0.0
	retries = 0
	arm_at = 0.0
	quit = false
	shot_url = ""

static func take_stage(node: Dictionary) -> Dictionary:
	var at: Dictionary = node["at"]
	var out: Dictionary = {"n": _int(at, "n"), "ammo": _int(at, "ammo"), "left": _int(at, "left"), "shot": _int(at, "shot"), "lt": _int(at, "lt"), 
		"wind": _int(at, "wind"), "wmax": _int(at, "wmax"), "t": [], "o": [], "alive": []}
	for kid: Dictionary in node["kids"]:
		var a: Dictionary = kid["at"]
		var row: Dictionary = {"x": float(_int(a, "x")), "y": float(_int(a, "y")), "ax": str(a.get("ax", "x")), "am": float(_int(a, "am")), 
			"pe": float(_int(a, "pe")), "ph": float(_int(a, "ph"))}
		if str(kid["tag"]) == "t":
			row["k"] = str(a.get("k", "b"))
			row["r"] = float(_int(a, "r"))
			(out["t"] as Array).append(row)
			(out["alive"] as Array).append(1 if str(a.get("a", "1")) == "1" else 0)
		elif str(kid["tag"]) == "o":
			row["w"] = float(_int(a, "w"))
			row["h"] = float(_int(a, "h"))
			(out["o"] as Array).append(row)
	return out


func take_run(node: Dictionary, came: float) -> void :
	var at: Dictionary = node["at"]
	var evs: PackedStringArray = str(at.get("ev", "")).split(",", false)
	var same_run: bool = live and _int(at, "id") == run
	var before: int = score
	score = _int(at, "score")
	shots = _int(at, "shots")
	hits = _int(at, "hits")
	bulls = _int(at, "bulls")
	var new_combo: int = _int(at, "combo")
	if new_combo > combo and new_combo > 1:
		combo_pop_at = now_ms()
	combo = new_combo
	max_combo = _int(at, "mc")
	stage_no = _int(at, "sn")
	var st_node: Dictionary = {}
	for kid: Dictionary in node["kids"]:
		if str(kid["tag"]) == "stage":
			st_node = kid
	if str(at.get("st", "")) != "live" or evs.has("end"):
		if live and not quit:
			float_text("Hết đạn!" if evs.has("out") else "Ván đã kết thúc", 26)
		if same_run and score > before:
			gain(score - before)
		result = {"score": score, "sn": stage_no, "hits": hits, "bulls": bulls, "mc": max_combo}
		reset_run()
		return
	live = true
	result = null
	run = _int(at, "id")
	if not st_node.is_empty():
		var fresh: Dictionary = take_stage(st_node)
		var el: float = float(_int(at, "el"))
		var retake: bool = not same_run or stage.is_empty() or int(stage["n"]) != int(fresh["n"]) or evs.has("sync") or evs.has("bad")\
		or evs.has("fast") or (stage.get("t", []) as Array).size() != (fresh["t"] as Array).size()
		if retake:
			stage = fresh
			stage_at = came - el
		else:
			for key: String in ["left", "shot", "lt", "wind", "wmax", "ammo"]:
				stage[key] = fresh[key]
			stage["alive"] = fresh["alive"]
	if evs.has("clear"):
		banner("banner_clear", "Qua Ải " + str(stage_no - 1) + "!")
		for i in 5:
			fx("fx_star", Vector2(150.0 + 110.0 * i, 160.0 + 40.0 * float(i % 2)), 70.0, 700.0, float(i) * 90.0)
	elif evs.has("fast"):
		tip("Bắn nhanh quá, chờ nạp đạn một chút nhé.")
	if same_run and score > before:
		gain(score - before)


func pump() -> void :
	if not action.is_empty() or not live:
		return
	var at: float = now_ms()
	if retry_at != 0.0:
		if at < retry_at:
			return
		retry_at = 0.0
		if retries > RETRIES or shot_url.is_empty():
			retries = 0
			load_pt("/cannon.xml?t=", "poll")
			return
		fetch(shot_url, "shot")
		return
	if not fly.is_empty() or not pending.is_empty():
		return
	if end_wanted:
		end_wanted = false
		queued = false
		load_pt("/cannon-end.xml?k=" + TevWheel.uri_component(token) + "&r=" + str(run) + "&t=", "end")
		return
	if queued and ready_in() <= 0.0:
		queued = false
		fire()


func ready_in() -> float:
	if stage.is_empty():
		return 1000000000.0
	var min_t: float = float(int(stage["lt"]) + gap) if int(stage["shot"]) > 0 else 200.0
	return min_t - (now_ms() - stage_at)

func can_fire() -> bool:
	return loaded and live and not stage.is_empty() and int(stage["left"]) > 0 and fly.is_empty() and pending.is_empty() and action.is_empty()\
	and retry_at == 0.0 and not end_wanted and ready_in() <= 0.0


func fire() -> void :
	if not can_fire():
		return
	var t0: int = int(now_ms() - stage_at)
	var pts: Array = []
	var res: Dictionary = sim(stage, stage["alive"], aim_a, aim_v, int(stage["wind"]), float(t0), pts)
	var path: PackedVector2Array = PackedVector2Array(pts)
	fly = {"at": now_ms(), "t0": t0, "a": aim_a, "v": aim_v, "w": int(stage["wind"]), "path": path, "res": res, "ok": false}
	gust_note = {}
	shot_url = ("/cannon-shot.xml?k=" + TevWheel.uri_component(token) + "&r=" + str(run) + "&n=" + str(int(stage["shot"])) + "&a=" + str(aim_a)
		+ "&v=" + str(aim_v) + "&t=" + str(t0))
	retries = 0
	fetch(shot_url, "shot")
	var rad: float = float(aim_a) * PI / 1800.0
	var muzzle: Vector2 = world(PX + BARREL * cos(rad), PY - BARREL * sin(rad))
	fx("fx_muzzle", muzzle + Vector2(cos(rad), - sin(rad)) * 12.0, 34.0, 160.0, 0.0, - rad)
	fx("fx_smoke", muzzle, 30.0, 700.0, 40.0, 0.0, 1.6)


func land() -> void :
	var res: Dictionary = fly["res"]
	fly = {}
	var p: Vector2 = world(float(res["x"]), float(res["y"]))
	match str(res["what"]):
		"t":
			var i: int = int(res["i"])
			var tg: Dictionary = stage["t"][i]
			stage["alive"][i] = 0
			if str(tg["k"]) == "l":
				fx("fx_pop", p, float(tg["r"]) * S * 2.6, 420.0)
			else:
				fx("fx_boom", p, float(tg["r"]) * S * 2.8, 520.0)
			if bool(res["bull"]):
				fx("fx_star", p, float(tg["r"]) * S * 3.0, 700.0, 60.0)
		"o":
			fx("fx_dust", p, 40.0, 520.0)
		"g":
			fx("fx_dust", Vector2(p.x, world(0, GROUND).y - 8.0), 46.0, 560.0)
	if not pending.is_empty():
		var text: String = pending[0]
		var came: float = pending[1]
		pending = []
		take_reply(_parse(text), "shot", came)



func on_start() -> void :
	if busy() or live or used >= turns_max or action == "shot":
		return
	result = null
	combo = 0
	quit = false
	load_pt("/cannon-start.xml?k=" + TevWheel.uri_component(token) + "&t=", "start")

func on_surrender() -> void :
	if not live or busy():
		return
	if arm_at == 0.0:
		arm_at = now_ms()
		return
	arm_at = 0.0
	end_wanted = true
	quit = true
	aiming = false
	pump()

func set_tab(index: int) -> void :
	tab = index


func aim_to(p: Vector2) -> void :
	var c: Vector2 = pivot()
	var dx: float = p.x - c.x
	var dy: float = c.y - p.y
	aim_cancel = p.x < c.x - 12.0
	if aim_cancel:
		return
	var deg: float = clampf(rad_to_deg(atan2(maxf(dy, 0.0), maxf(dx, 0.001))), 0.0, float(A_MAX) / 10.0)
	aim_a = clampi(roundi(deg * 10.0), 0, A_MAX)
	var dist: float = Vector2(dx, dy).length()
	aim_v = clampi(roundi(10.0 + 90.0 * (dist - AIM_NEAR) / (AIM_FAR - AIM_NEAR)), V_MIN, 100)

func aim_ok() -> bool:
	return loaded and live and not stage.is_empty() and not end_wanted and action != "end"


func release() -> void :
	aiming = false
	if aim_cancel:
		aim_cancel = false
		return
	queued = true
	pump()


func _top_hit(point: Vector2) -> String:
	for i in range(_hits.size() - 1, -1, -1):
		if (_hits[i][1] as Rect2).has_point(point):
			return str(_hits[i][0])
	return ""

func _gui_input(event: InputEvent) -> void :
	if opened and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and _top_hit(event.position) == "range" and aim_ok():
			aiming = true
			aim_cancel = false
			_mouse = Vector2(-1, -1) if _mobile else event.position
			aim_to(event.position / _f - frame_at())
			accept_event()
			return
		if not event.pressed and aiming:
			aim_to(event.position / _f - frame_at())
			release()
			accept_event()
			return
	if opened and aiming and event is InputEventMouseMotion:
		aim_to(event.position / _f - frame_at())
		accept_event()
		return
	super (event)

func _anim() -> void :
	var at: float = now_ms()
	pfx = pfx.filter( func(e: Dictionary) -> bool: return at < float(e["at"]) + float(e["dur"]))
	floats = floats.filter( func(e: Dictionary) -> bool: return at - float(e["at"]) < (BANNER_MS if str(e["kind"]) == "banner" else FLOAT_MS))
	if arm_at != 0.0 and at - arm_at > ARM_MS:
		arm_at = 0.0
	if not fly.is_empty() and bool(fly.get("ok", false)) and (at - float(fly["at"])) / DT_MS >= float(int(fly["res"]["k"])):
		land()
	pump()



func fx(name: String, centre: Vector2, wide: float, dur: float, delay: float = 0.0, rot: float = 0.0, grow: float = 1.25) -> void :
	if not opened:
		return
	pfx.append({"name": name, "x": centre.x, "y": centre.y, "w": wide, "at": now_ms() + delay, "dur": dur, "rot": rot, "grow": grow})

func banner(name: String, text: String) -> void :
	if not opened:
		return
	if art(name) == null:
		float_text(text, 26)
		return
	floats = floats.filter( func(e: Dictionary) -> bool: return str(e["kind"]) != "banner")
	floats.append({"kind": "banner", "name": name, "at": now_ms()})

func gain(value: int) -> void :
	if not opened or value <= 0:
		return
	floats = floats.filter( func(e: Dictionary) -> bool: return str(e["kind"]) != "gain")
	floats.append({"kind": "gain", "text": "+" + str(value), "at": now_ms(), "y": 140.0})

func float_text(text: String, px: int) -> void :
	if not opened:
		return
	floats = floats.filter( func(e: Dictionary) -> bool: return str(e["kind"]) != "float")
	floats.append({"kind": "float", "text": text, "size": px, "at": now_ms(), "y": 286.0})



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
	var high: float = float(lines.size()) * size * On.ON_LINE + float(lines.size() - 1) * leading
	while high > h and size > 10.0:
		size -= 1.0
		lines = _wrap(text, size, w, indent)
		high = float(lines.size()) * size * On.ON_LINE + float(lines.size() - 1) * leading
	var y: float = p.y + maxf(0.0, (h - high) / 2.0)
	for row: Array in lines:
		var off: float = float(row[1])
		_fwords(str(row[0]), ARIAL, size, rgb(color), align.substr(0, 1), Vector2(p.x + off, y), w - off, 1.5, size * On.ON_LINE, false, rgb(408373))
		y += size * On.ON_LINE + leading

func _glyphs(text: String, at: Vector2, k: float, alpha: float = 1.0) -> void :
	_textures()
	var info: Array = On.digits_width(text)
	if _on_tex == null or not bool(info[1]):
		var size: int = maxi(6, roundi(28.0 * k * _f))
		draw_string(ARIAL_BOLD, at * _f + Vector2(0, ARIAL_BOLD.get_ascent(size)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(rgb(16771218), alpha))
		return
	var base: Array = OnAtlas.R["digits_gold"]
	var cursor: int = 0
	for i in text.length():
		var g: int = On.ON_GLYPHS.find(text[i])
		var src: Rect2 = Rect2(float(base[0]) + float(On.ON_GLYPH_X[g]), float(base[1]), float(On.ON_GLYPH_W[g]), 36.0)
		draw_texture_rect_region(_on_tex, Rect2((at + Vector2(float(cursor) * k, 0.0)) * _f, Vector2(float(On.ON_GLYPH_W[g]), 36.0) * k * _f), src, 
			Color(1, 1, 1, alpha))
		cursor += int(On.ON_GLYPH_A[g])

func _digits_width(text: String) -> float:
	var info: Array = On.digits_width(text)
	return float(info[0]) if bool(info[1]) else ceilf(_width(text, 28.0, ARIAL_BOLD) + 8.0)

func _digits_box(text: String, box: Rect2) -> void :
	var dw: float = _digits_width(text)
	var s: float = minf(1.0, minf(box.size.x / dw, box.size.y / 36.0))
	_glyphs(text, Vector2(float(roundi(box.position.x + (box.size.x - dw * s) / 2.0)), float(roundi(box.position.y + (box.size.y - 36.0 * s) / 2.0))), s)



func _chrome(at: Vector2) -> void :
	var cell_size: Vector2 = _cell_size("public_button_close")
	_fbutton("close", "public_button_close", at + Vector2(PT_W - 15.0 - cell_size.x, 15.0))

func _body(at: Vector2) -> void :
	pic("onet_bg", at)
	_spr("range", Rect2(at + Vector2(FIELD_X, FIELD_Y), Vector2(FIELD_W, FIELD_H)))
	var playing: bool = loaded and live and not stage.is_empty()
	if playing:
		_hit("range", Rect2((at + Vector2(FIELD_X, FIELD_Y)) * _f, Vector2(FIELD_W, FIELD_H) * _f), false)
		_field(at)
	else:
		_cannon(at, aim_a)
	_title(at)
	if not loaded:
		_ot(at + Vector2(16, 300), 714, 30, 16, 16774352, 408373, "center", "Đang tải...", true)
	else:
		_stats(at)
		_ranking(at)
		if not live:
			_intro(at)
	_draw_floats(at)

func _title(at: Vector2) -> void :
	_spr("title", Rect2(at + Vector2(228, -5), Vector2(434, 434.0 * 121.0 / 660.0)))


func _field(at: Vector2) -> void :
	var t_ms: float = now_ms() - stage_at
	if not fly.is_empty():
		t_ms = float(int(fly["t0"])) + (now_ms() - float(fly["at"]))
	for o: Dictionary in stage["o"]:
		var op: Array = pos_at(o, t_ms)
		_pillar(at, float(op[0]), float(op[1]), float(o["w"]), float(o["h"]))
	var targets: Array = stage["t"]
	for i in range(targets.size()):
		if not int(stage["alive"][i]):
			continue
		var tg: Dictionary = targets[i]
		var tp: Array = pos_at(tg, t_ms)
		_target(at, tg, float(tp[0]), float(tp[1]), i)
	_cannon(at, int(fly["a"]) if not fly.is_empty() else aim_a)
	if aiming and not aim_cancel:
		_aim(at)
	if not fly.is_empty():
		var path: PackedVector2Array = fly["path"]
		var last: int = path.size() - 1 if bool(fly.get("ok", false)) else maxi(0, path.size() - 2)
		var step: int = clampi(int((now_ms() - float(fly["at"])) / DT_MS), 0, last)
		if not path.is_empty():
			var b: Vector2 = path[step]
			var p: Vector2 = at + world(b.x, b.y)
			if p.y < at.y + FIELD_Y + 4.0:
				_spr_c("arrow", Vector2(p.x, at.y + FIELD_Y + 14.0), 26.0, - PI / 2.0, 0.9)
			else:
				_spr_c("ball", p, 15.0)
	_wind(at)
	var now: float = now_ms()
	for e: Dictionary in pfx:
		var part: float = (now - float(e["at"])) / float(e["dur"])
		if part < 0.0 or part >= 1.0:
			continue
		var k: float = 1.0 + (float(e["grow"]) - 1.0) * part
		_spr_c(str(e["name"]), at + Vector2(float(e["x"]), float(e["y"])), float(e["w"]) * k, float(e["rot"]), 1.0 if part < 0.55 else (1.0 - part) / 0.45)
	var t_left: float = ready_in()
	if aiming:
		_ot(at + Vector2(FIELD_X + 12, 360), 200, 20, 14, 16774352, 408373, "left", "Góc %d°  ·  Lực %d" % [roundi(float(aim_a) / 10.0), aim_v], true)
		_ot(at + Vector2(FIELD_X, 528), FIELD_W, 20, 12, 16774352, 408373, "center", "Thả tay để bắn · kéo ra sau pháo để huỷ" if not aim_cancel else "Thả tay để huỷ", false)
	elif shots == 0 and fly.is_empty() and pending.is_empty():
		_ot(at + Vector2(FIELD_X, 528), FIELD_W, 20, 13, 16774352, 408373, "center", "Nhấn giữ trên trường bắn rồi kéo để ngắm, thả tay để bắn", true)
	elif queued and t_left > 0.0:
		_ot(at + Vector2(FIELD_X + 12, 360), 200, 20, 13, 16774352, 408373, "left", "Đang nạp đạn...", true)


func _pillar(at: Vector2, x: float, y: float, w: float, h: float) -> void :
	var texture: Texture2D = art("pillar")
	if texture == null:
		return
	var region: Rect2 = (texture as AtlasTexture).region
	var shaft: Array = PtAtlas.A["pillar_shaft"]
	var caps: Array = PtAtlas.A["pillar_caps"]
	var wide: float = w * S / (float(shaft[1]) - float(shaft[0]))
	var top_left: Vector2 = at + world(x, y) - Vector2(wide * float(shaft[0]), 0.0)
	var high: float = h * S
	var cap_t: float = minf(high * 0.3, wide * region.size.y * float(caps[0]) / region.size.x)
	var cap_b: float = minf(high * 0.25, wide * region.size.y * float(caps[1]) / region.size.x)
	var src_t: float = region.size.y * float(caps[0])
	var src_b: float = region.size.y * float(caps[1])
	var atlas: Texture2D = (texture as AtlasTexture).atlas
	draw_texture_rect_region(atlas, Rect2(top_left * _f, Vector2(wide, cap_t) * _f), Rect2(region.position, Vector2(region.size.x, src_t)))
	draw_texture_rect_region(atlas, Rect2((top_left + Vector2(0, cap_t)) * _f, Vector2(wide, high - cap_t - cap_b) * _f), 
		Rect2(region.position + Vector2(0, src_t), Vector2(region.size.x, region.size.y - src_t - src_b)))
	draw_texture_rect_region(atlas, Rect2((top_left + Vector2(0, high - cap_b)) * _f, Vector2(wide, cap_b) * _f), 
		Rect2(region.position + Vector2(0, region.size.y - src_b), Vector2(region.size.x, src_b)))


func _target(at: Vector2, tg: Dictionary, x: float, y: float, i: int) -> void :
	var r: float = float(tg["r"]) * S
	var c: Vector2 = at + world(x, y)
	match str(tg["k"]):
		"b":
			var post: Texture2D = art("board_post")
			if post != null:
				var region: Rect2 = (post as AtlasTexture).region
				var wide: float = r * 2.0
				var base_h: float = wide * region.size.y / region.size.x * 0.45
				var ground_y: float = at.y + OY + GROUND * S + 6.0
				var atlas: Texture2D = (post as AtlasTexture).atlas
				var stick_src: Rect2 = Rect2(region.position, Vector2(region.size.x, region.size.y * 0.55))
				var base_src: Rect2 = Rect2(region.position + Vector2(0, region.size.y * 0.55), Vector2(region.size.x, region.size.y * 0.45))
				var stick_top: float = c.y + r * 0.6
				if ground_y - base_h > stick_top:
					draw_texture_rect_region(atlas, Rect2(Vector2(c.x - wide / 2.0, stick_top) * _f, Vector2(wide, ground_y - base_h - stick_top) * _f), stick_src)
				draw_texture_rect_region(atlas, Rect2(Vector2(c.x - wide / 2.0, ground_y - base_h) * _f, Vector2(wide, base_h) * _f), base_src)
			_spr_c("board_face", c, r * 2.0 * 1.04)
		"l":
			var name: String = ["balloon_r", "balloon_b", "balloon_o"][i % 3]
			var texture: Texture2D = art(name)
			if texture != null:
				var wide: float = r * 2.0 * 1.06
				var high: float = wide * float(texture.get_height()) / float(texture.get_width())
				var body: float = float(PtAtlas.A["balloon_body"][0])
				draw_texture_rect(texture, Rect2(Vector2(c.x - wide / 2.0, c.y - high * body) * _f, Vector2(wide, high) * _f), false)
		_:
			_spr_c("flyer", c, r * 2.0 / float(PtAtlas.A["flyer_face"][0]) * 1.04)


func _cannon(at: Vector2, a: int) -> void :
	var rad: float = float(a) * PI / 1800.0
	var c: Vector2 = at + pivot()
	var barrel: Texture2D = art("barrel")
	if barrel != null:
		var piv: Array = PtAtlas.A["barrel_pivot"]
		var length: float = BARREL * S / (1.0 - float(piv[0]))
		var high: float = length * float(barrel.get_height()) / float(barrel.get_width())
		draw_set_transform(c * _f, - rad, Vector2.ONE)
		draw_texture_rect(barrel, Rect2(Vector2( - length * float(piv[0]), - high * float(piv[1])) * _f, Vector2(length, high) * _f), false)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	var body: Texture2D = art("chassis")
	if body != null:
		var cp: Array = PtAtlas.A["chassis_pivot"]
		var wide: float = 88.0
		var high: float = wide * float(body.get_height()) / float(body.get_width())
		draw_texture_rect(body, Rect2((c - Vector2(wide * float(cp[0]), high * float(cp[1]))) * _f, Vector2(wide, high) * _f), false)


func _aim(at: Vector2) -> void :
	var rad: float = float(aim_a) * PI / 1800.0
	var dir: Vector2 = Vector2(cos(rad), - sin(rad))
	var muzzle: Vector2 = at + world(PX + BARREL * cos(rad), PY - BARREL * sin(rad))
	var length: float = 26.0 + 46.0 * float(aim_v - V_MIN) / float(100 - V_MIN)
	_spr_c("arrow", muzzle + dir * (length / 2.0 + 4.0), length, - rad, 0.95)


func _wind(at: Vector2) -> void :
	var wind: int = int(stage.get("wind", 0))
	var spot: Vector2 = at + Vector2(318, 104)
	_spr_c("windsock", spot, 44.0 if wind != 0 else 38.0, 0.0, 1.0, wind < 0)
	_gust(spot)
	if wind == 0:
		_ot(spot + Vector2(28, -11), 120, 22, 14, 16774352, 408373, "left", "Lặng gió", true)
		return
	_ot(spot + Vector2(28, -21), 120, 20, 14, 16774352, 408373, "left", "Gió " + str(absi(wind)), true)
	var length: float = 22.0 + 6.0 * float(absi(wind))
	_spr_c("arrow", spot + Vector2(30.0 + length / 2.0, 9.0), length, 0.0 if wind > 0 else PI, 1.0)


func _gust(spot: Vector2) -> void :
	if gust_note.is_empty() or not live:
		return
	var l: int = int(gust_note["l"])
	var alpha: float = clampf((now_ms() - float(gust_note["at"])) / 250.0, 0.0, 1.0)
	var gx: float = float(int(gust_note["x"]))
	var gy: float = float(int(gust_note["y"]))
	if gx != 0.0 or gy != 0.0:
		_spr_c("arrow", spot + Vector2(40, 33), 14.0 + 5.0 * float(l), atan2(gy, gx), 0.9 * alpha)
	_ot(spot + Vector2(54, 24), 130, 18, 12, 16774352, 408373, "left", ["Gió giật nhẹ", "Gió giật vừa", "Gió giật mạnh"][l - 1], true, alpha)

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
	pic("tab_on" if on else ("tab_hover" if _hover == id and not _mobile else "tab_off"), p)
	_ot(p + Vector2(3, 4), 56, 18, 12, 1195577 if on else 16774352, -1, "center", label, true)
	if not on:
		_hit(id, Rect2(p * _f, Vector2(62, 26) * _f), false)

func _stats(at: Vector2) -> void :
	var left_turns: String = str(maxi(0, turns_max - used)) + "/" + str(turns_max)
	if live and not stage.is_empty():
		pic("stage_badge", at + Vector2(754, 73))
		_ot(at + Vector2(760, 77), 60, 19, 16, 16774352, 7938841, "center", "ẢI " + str(stage_no), true)
		pic("mode_chip", at + Vector2(832, 73))
		var tl: int = 0
		for x: Variant in stage["alive"]:
			tl += int(x)
		_ot(at + Vector2(838, 78), 88, 18, 12, 16774352, -1, "center", "Bia còn: " + str(tl), true)
		pic("stat_plate", at + Vector2(755, 106))
		_ot(at + Vector2(765, 110), 156, 16, 12, 16774352, -1, "center", "Đạn còn", false)
		var ammo: int = int(stage["ammo"])
		var left: int = int(stage["left"])
		var step: float = minf(18.0, 150.0 / float(maxi(1, ammo)))
		var x0: float = 843.0 - step * float(ammo) / 2.0 + step / 2.0
		for i in ammo:
			_spr_c("ball", at + Vector2(x0 + step * float(i), 144), minf(15.0, step - 2.0), 0.0, 1.0 if i < left else 0.25)
		pic("score_label", at + Vector2(766, 168))
		_digits_box(str(score), Rect2(at + Vector2(757, 190), Vector2(124, 36)))
		if combo > 1:
			var part: float = (now_ms() - combo_pop_at) / 300.0
			var s: float = 1.0 + 0.25 * sin(part * PI) if combo_pop_at != 0.0 and part < 1.0 else 1.0
			var box: Vector2 = at + Vector2(905, 196)
			_spr(("combo_badge"), Rect2(box + Vector2(-30, -21) * s, Vector2(60, 42) * s))
			_glyphs("x" + str(combo), box + Vector2(-16, -6) * s, 0.5 * s)
		pic("pairs_bar", at + Vector2(755, 227))
		_ot(at + Vector2(762, 230), 162, 16, 12, 16774352, -1, "center", "Trúng " + str(hits) + " · Hồng tâm " + str(bulls), true)
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
	var picture: Texture2D = pack.picture(path) if pack != null and not path.is_empty() else null
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

func rules_body() -> String:
	return (RULES
		+ "• Bia " + str(int(pts["pb"])) + " · Bóng bay " + str(int(pts["pl"])) + " · Bia bay " + str(int(pts["pm"])) + " điểm; trúng hồng tâm +"
		+ str(int(pts["pbu"])) + ". Trúng liên tiếp tăng Combo (+" + str(int(pts["cp"])) + "% mỗi bậc).\n"
		+ "• Đầu hàng vẫn giữ điểm đã đạt. Ván điểm cao nhất trong ngày được xếp hạng."
		+ ("\n• Yêu cầu cấp " + str(lv) + "." if lv > 0 else "")
		+ ("\n• Gió giật: mỗi phát có thêm một cơn gió giật nhỏ ngẫu nhiên làm đạn lệch đôi chút — xem dấu gió giật dưới cờ gió." if gst else ""))

func _intro(at: Vector2) -> void :
	var free_turn: bool = used < turns_max
	pic("card_frame", at + Vector2(113, 116))
	if result != null:
		var res: Dictionary = result
		pic("ribbon_result", at + Vector2(218, 112))
		_ot(at + Vector2(173, 199), 400, 23, 17, 14087133, -1, "center", "ĐIỂM CỦA BẠN", false)
		_digits_box(str(int(res["score"])), Rect2(at + Vector2(253, 232), Vector2(240, 36)))
		var chips: Array = ["Ải " + str(int(res["sn"])), str(int(res["hits"])) + " trúng", "x" + str(int(res["mc"]))]
		for k in 3:
			pic("chip_plate", at + Vector2(173 + 140 * k, 304))
			if k == 1:
				_spr("board_face", Rect2(at + Vector2(185 + 140 * k, 309), Vector2(20, 20)))
			else:
				pic("ico_stage" if k == 0 else "ico_combo", at + Vector2(185 + 140 * k, 309))
			_ot(at + Vector2(210 + 140 * k, 309), 69, 20, 13, 16774352, -1, "center", str(chips[k]), true)
		var msg: String = "Lượt chơi đã kết thúc."
		if best > 0:
			msg = "Kỷ lục hôm nay: " + num(best) + " điểm" + (" · Hạng " + str(rank) if rank > 0 else "")
		_op(at + Vector2(158, 361), 430, 54, 16, 16774352, "center", msg + "\nChỉ ván điểm cao nhất trong ngày được xếp hạng.", 6, 0)
	else:
		pic("ribbon_rules", at + Vector2(218, 112))
		_op(at + Vector2(157, 188), 432, 238, 15, 16774352, "left", rules_body(), 5, 10)
	var label: String = "ĐANG VÀO..." if action == "start" else ("BẮT ĐẦU" if free_turn else "HẾT LƯỢT HÔM NAY")
	_obutton("start", "gold", at + Vector2(263, 448), label, free_turn and not busy())

func _draw_floats(at: Vector2) -> void :
	var now: float = now_ms()
	for e: Dictionary in floats:
		var kind: String = str(e["kind"])
		if kind == "banner":
			var part: float = (now - float(e["at"])) / BANNER_MS
			if part >= 1.0:
				continue
			var s: float = 0.6 + 0.5 * part / 0.12 if part < 0.12 else (1.1 - 0.1 * (part - 0.12) / 0.08 if part < 0.2 else 1.0)
			var alpha: float = 1.0 if part < 0.75 else (1.0 - part) / 0.25
			var texture: Texture2D = art(str(e["name"]))
			if texture != null:
				draw_texture_rect(texture, Rect2((at + Vector2(PT_CX, PT_CY) + Vector2(-150, -45) * s) * _f, Vector2(texture.get_size()) * s * _f), false, Color(1, 1, 1, alpha))
		else:
			var part: float = (now - float(e["at"])) / FLOAT_MS
			if part >= 1.0:
				continue
			var alpha: float = 1.0 if part < 0.7 else (1.0 - part) / 0.3
			var y: float = float(e["y"]) - float(int(30.0 * part))
			if kind == "gain":
				var k: float = 28.0 / 36.0
				var dw: float = _digits_width(str(e["text"]))
				_glyphs(str(e["text"]), at + Vector2(float(roundi(PT_CX - dw * k / 2.0)), y), k, alpha)
			else:
				_ot(at + Vector2(FIELD_X, y), FIELD_W, 44, float(e["size"]), 16774352, 408373, "center", str(e["text"]), true, alpha)
