extends "tev_window.gd"


















signal closed(note: String)

const On = preload("on.gd")
const TevWheel = preload("tev_wheel.gd")
const FP_TIP: String = "Phượng Hoàng Tung Cánh"
const FILE: String = "res://assets/ui/fp/fp.png"

const R: Dictionary = {"btn": [0, 0, 50, 50], "word": [0, 52, 68, 16], "bird": [72, 0, 200, 131], "lid": [280, 0, 103, 68], 
	"col": [72, 140, 64, 400], "sky": [400, 0, 528, 320]}
const FILE_FX: String = "res://assets/ui/fp/fp_fx.png"
const FILE_SKY: String = "res://assets/ui/fp/fp_sky.png"

const R2: Dictionary = {"band": [1, 460, 878, 105], "banner": [1, 184, 727, 151], "cap": [1, 754, 140, 36], "cld0": [1, 663, 246, 89], "cld1": [1, 567, 246, 94], "cld2": [625, 567, 244, 91], "f_bl": [462, 337, 122, 110], "f_bot": [238, 754, 65, 24], "f_emb": [602, 663, 151, 76], "f_orn": [920, 663, 41, 41], "f_side": [860, 663, 30, 50], "f_tl": [313, 337, 147, 110], "f_top": [143, 754, 93, 24], "isl0": [1, 337, 310, 121], "isl1": [730, 184, 288, 150], "isl2": [249, 663, 173, 85], "isl3": [424, 663, 176, 79], "isl4": [755, 663, 103, 54], "w_b": [906, 663, 12, 48], "w_bl": [437, 567, 92, 92], "w_br": [531, 567, 92, 92], "w_in": [1, 1, 309, 181], "w_l": [305, 754, 48, 12], "w_r": [355, 754, 48, 12], "w_t": [892, 663, 12, 48], "w_tl": [249, 567, 92, 92], "w_tr": [343, 567, 92, 92]}
const FS: float = 0.21


const WB: float = 20.0
const WC: float = 42.0
const WIN_PAD: float = 4.0
const WIN_IN_PAD: float = 2.5

const WARM_TOP: Color = Color("3a170d")
const WARM_LOW: Color = Color("1c0906")
const WARM_EDGE: Color = Color("e3a94a")
const WARM_MUTED: Color = Color("ecd2ad")

const ISLES: Array = [["isl0", 60.0, 296.0, 0.62], ["isl4", 430.0, 168.0, 0.62], ["isl1", 640.0, 70.0, 0.6], ["isl3", 1010.0, 318.0, 0.62], ["isl2", 1290.0, 214.0, 0.62]]
const CLOUDS: Array = [["cld0", 160.0, 30.0, 0.62], ["cld1", 880.0, 150.0, 0.58], ["cld2", 1380.0, 60.0, 0.62]]
const POLL_TICKS: int = 120
const RETRY_MS: float = 1000.0
const RETRIES: int = 5
const FP_W: float = 988.0
const FP_H: float = 560.0
const FIELD_X: float = 44.0
const FIELD_Y: float = 62.0
const SIDE_X: float = 688.0
const SIDE_W: float = 280.0
const BIRD_W: float = 66.0
const LID_W: float = 76.0
const LID_H: float = 40.0
const CAP_W: float = 70.0
const CAP_H: float = 18.0
const BANNER_W: float = 400.0
const BANNER_CY: float = 20.0
const BANNER_DY: float = 1.0
const BANNER_TW: float = 250.0
const ADOPT_MS: int = 1500
const AUTO_MS: int = 1000

const U: int = 100
const HZ: int = 60
const W: int = 600
const H: int = 440
const BX: int = 150
const BR: int = 12
const Y0: int = 200
const G: int = 40
const FLAP: int = -720
const VMAX: int = 1000
const V0: int = 250
const VSTEP: int = 2
const VCAP: int = 50
const CW: int = 64
const SP: int = 240
const FIRST: int = 420
const GAP0: int = 160
const GAPMIN: int = 118
const GAPSTEP: int = 3
const GAPEVERY: int = 5
const MAX_STEPS: int = 30000
const MINGAP: int = 3
const MAX_FLAPS: int = 3500
const B36: String = "0123456789abcdefghijklmnopqrstuvwxyz"

const DTRIG: int = 160
const SLD: int = 30
const FAR: int = 1 << 62
const CHUNK_GAP_MS: float = 150.0
const CHUNK_RETRY_MS: float = 500.0
const STALL_MS: float = 12000.0
const STALL_SHOW_MS: float = 250.0
const RULES_V2: String = ("\n• Đường bay hiện dần khi Phượng Hoàng tới gần: có cột gạch bất ngờ trượt lên hoặc xuống, có lúc gió giật đẩy lên hoặc xuống"
	+ " (chữ \"Gió giật\" báo trước khoảng nửa giây).\n• Lượt bay có nhịp phản xạ nhanh hơn người thường được lưu lại để kiểm tra, không tính xếp hạng và quà.")
const MEDALS: Array[Color] = [Color("ffd84a"), Color("d8e4f0"), Color("e0a060")]
const NOTES: Dictionary = {
	"quit": "Lượt bay đã huỷ trước khi cất cánh.", 
	"idle": "Lượt bay quá hạn nên không được tính điểm.", 
	"bad": "Nhật ký vỗ cánh không hợp lệ, lượt này không tính điểm.", 
	"fast": "Đồng hồ lượt bay chạy nhanh bất thường, lượt này không tính điểm.", 
	"slow": "Lượt bay kéo dài quá lâu (mạng chậm hoặc máy bị treo), lượt này không tính điểm.", 
	"perf": "Nhịp phản xạ của lượt bay này hoàn hảo bất thường: điểm được lưu để kiểm tra, không tính xếp hạng và quà.", 
	"lost": "Máy chủ vừa khởi động lại nên lượt bay dừng giữa chừng (không tính lượt), hãy bay lượt mới.", 
}

static var s_fp_shown: bool = false
static var _fp_tex: Texture2D = null
static var _tex_tried: bool = false
static var _fx_tex: Texture2D = null
static var _sky_tex: Texture2D = null
static var s_v2: bool = false

var poll_in: int = 4
var fp_visible: bool = false
var loaded: bool = false
var token: String = ""
var used: int = 0
var turns_max: int = 0
var lv: int = 0
var wait_ms: int = 6000
var day: String = ""
var best: int = 0
var rank: int = 0
var ybest: int = 0
var yrank: int = 0
var yset: bool = false
var yit: String = ""
var tiers: Array = []
var top: Array = []
var ytop: Array = []
var tab: int = 0

var phase: String = "idle"
var run: int = 0
var gaps: PackedInt32Array = PackedInt32Array()
var bird: Dictionary = {}
var prev: Dictionary = {}
var flaps: Array = []
var fi: int = 0
var t0_us: int = 0
var auto_at: float = 0.0
var end_url: String = ""
var sent_token: String = ""
var resent: bool = false
var retry_at: float = 0.0
var retries: int = 0
var result: Dictionary = {}
var close_note: String = ""
var dead_at: float = 0.0
var flap_at: float = -1000.0
var sparks: Array = []
var clock_us: int = -1
var _parts: Dictionary = {}
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()
var _d_now: float = 0.0

var v2: bool = false
var cs: Dictionary = {}
var ne: int = 0
var nb: int = 0
var cur: Dictionary = {}
var chunk_ok: bool = false
var chunk_busy: bool = false
var ask_at: float = 0.0
var stall_at: float = 0.0

func _setup() -> void :
	art_dir = ""
	art_files = []
	win_size = Vector2(FP_W, FP_H)
	super ()
	fp_visible = s_fp_shown
	_rng.seed = 20261108

static func reset_statics() -> void :
	s_fp_shown = false
	s_v2 = false

func now_us() -> int:
	return clock_us if clock_us >= 0 else Time.get_ticks_usec()

func now_ms() -> float:
	return float(now_us()) / 1000.0

func reset() -> void :
	reset_run()
	close()
	if _http != null:
		_http.cancel_request()
	loading = false
	action = ""
	poll_in = 4
	fp_visible = false
	loaded = false
	token = ""
	used = 0
	turns_max = 0
	best = 0
	rank = 0
	ybest = 0
	yrank = 0
	yset = false
	yit = ""
	tiers = []
	top = []
	ytop = []
	tab = 0
	result = {}
	reset_statics()



static func gap_h(i: int) -> int:
	return maxi(GAPMIN, GAP0 - (i / GAPEVERY) * GAPSTEP)

static func speed_of(passed: int) -> int:
	return V0 + mini(passed, VCAP) * VSTEP

static func new_bird() -> Dictionary:
	return {"k": 0, "y": Y0 * U, "vy": 0, "d": 0, "passed": 0, "dead": "", "at": -1}


static func step(b: Dictionary, g: PackedInt32Array, go: bool) -> Dictionary:
	if not str(b["dead"]).is_empty():
		return b
	var r: int = BR * U
	if go:
		b["vy"] = FLAP
	b["vy"] = mini(int(b["vy"]) + G, VMAX)
	b["y"] = int(b["y"]) + int(b["vy"])
	b["d"] = int(b["d"]) + speed_of(int(b["passed"]))
	if int(b["y"]) < r:
		b["y"] = r
		b["vy"] = 0
	var k: int = int(b["k"])
	b["k"] = k + 1
	var y: int = int(b["y"])
	if y + r >= H * U:
		b["dead"] = "g"
		b["at"] = k
		return b
	var j: int = int(b["passed"])
	var left: int = (FIRST + j * SP) * U - int(b["d"])
	if j < g.size() and left <= (BX + BR) * U and left + CW * U >= (BX - BR) * U:
		var c: int = g[j] * U
		var h: int = gap_h(j) * U / 2
		if y - r < c - h or y + r > c + h:
			b["dead"] = "p"
			b["at"] = k
			return b
	if left + CW * U < (BX - BR) * U:
		b["passed"] = j + 1
		if j + 1 >= g.size():
			b["dead"] = "n"
			b["at"] = k
			return b
	if int(b["k"]) >= MAX_STEPS:
		b["dead"] = "t"
		b["at"] = k
	return b


static func sim(g: PackedInt32Array, list: Array) -> Dictionary:
	var b: Dictionary = new_bird()
	var i: int = 0
	while str(b["dead"]).is_empty():
		var go: bool = i < list.size() and int(list[i]) == int(b["k"])
		if go:
			i += 1
		step(b, g, go)
	return {"score": int(b["passed"]), "at": int(b["at"]), "why": str(b["dead"]), "y": int(b["y"]), "d": int(b["d"])}


static func encode(list: Array) -> String:
	var out: String = ""
	for i in list.size():
		var v: int = clampi(int(list[i]) - (int(list[i - 1]) if i > 0 else 0), 0, 36 * 36 - 1)
		out += B36[v / 36] + B36[v % 36]
	return out

static func decode(text: String) -> Array:
	var out: Array = []
	if text.length() % 2 != 0:
		return []
	for i in range(0, text.length(), 2):
		var a: int = B36.find(text[i])
		var b: int = B36.find(text[i + 1])
		if a < 0 or b < 0:
			return []
		var v: int = a * 36 + b
		out.append(v if out.is_empty() else int(out[-1]) + v)
	return out

static func gaps_of(text: String) -> PackedInt32Array:
	var out: PackedInt32Array = PackedInt32Array()
	for part: String in text.split(",", false):
		out.append(TevWheel.as_int(part))
	return out




static func d_trig(j: int) -> int:
	return (FIRST + j * SP - BX - DTRIG) * U


static func limit_of(known: int, n: int) -> int:
	return FAR if known >= n else d_trig(known)


static func gust_at(c: Dictionary, d: int) -> int:
	var off: int = d - d_trig(0)
	if off < 0:
		return 0
	var spu: int = SP * U
	var j: int = off / spu
	if j >= int(c["n"]):
		return 0
	var ga: int = (c["ga"] as PackedInt32Array)[j]
	if ga == 0:
		return 0
	var x: int = off - j * spu
	var gs: int = (c["gs"] as PackedInt32Array)[j]
	var gl: int = (c["gl"] as PackedInt32Array)[j]
	return ga if x >= gs * U and x < (gs + gl) * U else 0


static func centre_at(c: Dictionary, j: int, d: int) -> int:
	var x: int = d - d_trig(j)
	var t: int = 0 if x <= 0 else mini(x, SLD * U)
	return (c["c0"] as PackedInt32Array)[j] * U + ((c["m"] as PackedInt32Array)[j] * t) / SLD

static func step2(b: Dictionary, c: Dictionary, go: bool) -> Dictionary:
	if not str(b["dead"]).is_empty():
		return b
	var r: int = BR * U
	if go:
		b["vy"] = FLAP
	b["vy"] = mini(int(b["vy"]) + G + gust_at(c, int(b["d"])), VMAX)
	b["y"] = int(b["y"]) + int(b["vy"])
	b["d"] = int(b["d"]) + speed_of(int(b["passed"]))
	if int(b["y"]) < r:
		b["y"] = r
		b["vy"] = 0
	var k: int = int(b["k"])
	b["k"] = k + 1
	var y: int = int(b["y"])
	if y + r >= H * U:
		b["dead"] = "g"
		b["at"] = k
		return b
	var j: int = int(b["passed"])
	var left: int = (FIRST + j * SP) * U - int(b["d"])
	if left <= (BX + BR) * U and left + CW * U >= (BX - BR) * U:
		var cc: int = centre_at(c, j, int(b["d"]))
		var h: int = gap_h(j) * U / 2
		if y - r < cc - h or y + r > cc + h:
			b["dead"] = "p"
			b["at"] = k
			return b
	if left + CW * U < (BX - BR) * U:
		b["passed"] = j + 1
		if j + 1 >= int(c["n"]):
			b["dead"] = "n"
			b["at"] = k
			return b
	if int(b["k"]) >= MAX_STEPS:
		b["dead"] = "t"
		b["at"] = k
	return b


static func can_step(b: Dictionary, lim: int) -> bool:
	return int(b["d"]) + speed_of(int(b["passed"])) < lim


static func sim2(c: Dictionary, list: Array, lim: int = FAR) -> Dictionary:
	var b: Dictionary = new_bird()
	var i: int = 0
	while str(b["dead"]).is_empty():
		if not can_step(b, lim):
			b["dead"] = "q"
			b["at"] = int(b["k"]) - 1
			break
		var go: bool = i < list.size() and int(list[i]) == int(b["k"])
		if go:
			i += 1
		step2(b, c, go)
	return {"score": int(b["passed"]), "at": int(b["at"]), "why": str(b["dead"]), "y": int(b["y"]), "d": int(b["d"]), "k": int(b["k"])}

static func new_cursor() -> Dictionary:
	return {"k": 0, "d": 0, "passed": 0}


static func dist_at(cu: Dictionary, k: int, n: int) -> int:
	while int(cu["k"]) < k and int(cu["k"]) < MAX_STEPS:
		cu["d"] = int(cu["d"]) + speed_of(int(cu["passed"]))
		cu["k"] = int(cu["k"]) + 1
		var p: int = int(cu["passed"])
		if p < n and (FIRST + p * SP + CW) * U - int(cu["d"]) < (BX - BR) * U:
			cu["passed"] = p + 1
	return int(cu["d"])


static func reveal_count(cu: Dictionary, s: int, l: int, n: int) -> int:
	var d: int = dist_at(cu, s + l, n)
	var j: int = d / (SP * U)
	while j > 0 and d_trig(j) > d:
		j -= 1
	while j < n and d_trig(j) <= d:
		j += 1
	return mini(n, j)



static func _textures() -> void :
	if _tex_tried:
		return
	_tex_tried = true
	if ResourceLoader.exists(FILE):
		_fp_tex = load(FILE) as Texture2D
	if ResourceLoader.exists(FILE_FX):
		_fx_tex = load(FILE_FX) as Texture2D
	if ResourceLoader.exists(FILE_SKY):
		_sky_tex = load(FILE_SKY) as Texture2D

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
	if _fp_tex == null or not R.has(name):
		return null
	var row: Array = R[name]
	var part: AtlasTexture = AtlasTexture.new()
	part.atlas = _fp_tex
	part.region = Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))
	_parts[name] = part
	return part

func button_icon() -> Texture2D:
	return art("btn")

func button_word() -> Texture2D:
	return art("word")

static func region(name: String) -> Rect2:
	var row: Array = R[name]
	return Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))


func _blit(part: String, dst: Rect2, clip: Rect2, flip: bool = false, tint: Color = Color.WHITE, src_override: Rect2 = Rect2()) -> void :
	_textures()
	if _fp_tex == null or dst.size.x <= 0.0 or dst.size.y <= 0.0:
		return
	var src: Rect2 = src_override if src_override.has_area() else region(part)
	var vis: Rect2 = dst.intersection(clip)
	if vis.size.x <= 0.01 or vis.size.y <= 0.01:
		return
	var kx: float = src.size.x / dst.size.x
	var ky: float = src.size.y / dst.size.y
	var sx: float = (dst.end.x - vis.end.x) * kx if flip else (vis.position.x - dst.position.x) * kx
	var s: Rect2 = Rect2(src.position.x + sx, src.position.y + (vis.position.y - dst.position.y) * ky, vis.size.x * kx, vis.size.y * ky)
	var r: Rect2 = Rect2(vis.position * _f, vis.size * _f)
	if flip:
		draw_set_transform(Vector2(r.end.x, r.position.y), 0.0, Vector2(-1, 1))
		draw_texture_rect_region(_fp_tex, Rect2(Vector2.ZERO, r.size), s, tint)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	else:
		draw_texture_rect_region(_fp_tex, r, s, tint)


func _piece(tex: Texture2D, src: Rect2, dst: Rect2, clip: Rect2 = Rect2(), fh: bool = false, fv: bool = false, tint: Color = Color.WHITE) -> void :
	if tex == null or dst.size.x <= 0.0 or dst.size.y <= 0.0:
		return
	var vis: Rect2 = dst.intersection(clip) if clip.has_area() else dst
	if vis.size.x <= 0.01 or vis.size.y <= 0.01:
		return
	var k: Vector2 = src.size / dst.size
	var sx: float = (dst.end.x - vis.end.x) * k.x if fh else (vis.position.x - dst.position.x) * k.x
	var sy: float = (dst.end.y - vis.end.y) * k.y if fv else (vis.position.y - dst.position.y) * k.y
	var s: Rect2 = Rect2(src.position + Vector2(sx, sy), vis.size * k)
	var r: Rect2 = Rect2(vis.position * _f, vis.size * _f)
	if fh or fv:
		draw_set_transform(Vector2(r.end.x if fh else r.position.x, r.end.y if fv else r.position.y), 0.0, Vector2(-1.0 if fh else 1.0, -1.0 if fv else 1.0))
		draw_texture_rect_region(tex, Rect2(Vector2.ZERO, r.size), s, tint)
		draw_set_transform_matrix(Transform2D.IDENTITY)
	else:
		draw_texture_rect_region(tex, r, s, tint)

static func fx_region(name: String) -> Rect2:
	var row: Array = R2[name]
	return Rect2(float(row[0]), float(row[1]), float(row[2]), float(row[3]))


func _fxp(name: String, p: Vector2, k: float, clip: Rect2 = Rect2(), fh: bool = false, fv: bool = false, tint: Color = Color.WHITE) -> void :
	if _fx_tex == null:
		return
	var src: Rect2 = fx_region(name)
	_piece(_fx_tex, src, Rect2(p, src.size * k), clip, fh, fv, tint)


func _fx_run(name: String, dst: Rect2, horiz: bool, unit: float) -> void :
	if _fx_tex == null:
		return
	var length: float = dst.size.x if horiz else dst.size.y
	if length <= 0.5:
		return
	var n: int = maxi(1, roundi(length / unit))
	var step: float = length / float(n)
	var src: Rect2 = fx_region(name)
	for i in n:
		var r: Rect2 = Rect2(dst.position + (Vector2(step * float(i), 0) if horiz else Vector2(0, step * float(i))), Vector2(step, dst.size.y) if horiz else Vector2(dst.size.x, step))
		_piece(_fx_tex, src, r)


func _frame(o: Vector2) -> void :
	if _fx_tex == null:
		_plate(Rect2((o - Vector2(6, 6)) * _f, Vector2(W + 12, H + 12) * _f), Color(0, 0, 0, 0), Color(GLASS_EDGE, 0.85), 14.0, 3.0)
		return
	var w: float = float(W)
	var h: float = float(H)

	_fx_run("f_top", Rect2(o + Vector2(163.0 * FS, -53.0 * FS), Vector2(w - 326.0 * FS, 58.0 * FS)), true, 222.0 * FS)
	_fx_run("f_bot", Rect2(o + Vector2(103.0 * FS, h - 5.0 * FS), Vector2(w - 206.0 * FS, 58.0 * FS)), true, 154.0 * FS)
	var side_y: float = 129.0 * FS
	var side_h: float = h - 132.0 * FS - side_y
	_fx_run("f_side", Rect2(o + Vector2(-65.0 * FS, side_y), Vector2(72.0 * FS, side_h)), false, 118.0 * FS)
	if _fx_tex != null:
		var src: Rect2 = fx_region("f_side")
		var n: int = maxi(1, roundi(side_h / (118.0 * FS)))
		var step: float = side_h / float(n)
		for i in n:
			_piece(_fx_tex, src, Rect2(o + Vector2(w + 65.0 * FS - 72.0 * FS, side_y + step * float(i)), Vector2(72.0 * FS, step)), Rect2(), true)

	for fy: float in [0.27, 0.6]:
		_fxp("f_orn", o + Vector2(-87.0 * FS, h * fy), 0.5)
		_fxp("f_orn", o + Vector2(w + 87.0 * FS - 98.0 * FS, h * fy), 0.5, Rect2(), true)

	_fxp("f_tl", o + Vector2(-187.0 * FS, -133.0 * FS), 0.5)
	_fxp("f_tl", o + Vector2(w - 163.0 * FS, -133.0 * FS), 0.5, Rect2(), true)
	_fxp("f_bl", o + Vector2(-187.0 * FS, h - 132.0 * FS), 0.5)
	_fxp("f_bl", o + Vector2(w - 103.0 * FS, h - 132.0 * FS), 0.5, Rect2(), true)

	_fxp("f_emb", o + Vector2(w / 2.0 - 180.0 * FS, h - 2.0), 0.5)


func _banner(at: Vector2) -> void :
	if _fx_tex == null or not R2.has("banner"):
		var ribbon: Rect2 = _rect(at, 300, -14, 340, 46)
		var _ink: Color = _tab_plate(ribbon, true, false, 24.0)
		_tx("PHƯỢNG HOÀNG TUNG CÁNH", 17.0, ON_GOLD, "c", at + Vector2(300, 9), 340.0, BOLD, GOLD_RIM, 2.5)
		return
	var src: Rect2 = fx_region("banner")
	var bw: float = BANNER_W
	var bh: float = bw * src.size.y / src.size.x
	var cx: float = FIELD_X + float(W) / 2.0
	var top: float = BANNER_CY - bh / 2.0
	_piece(_fx_tex, src, Rect2(at + Vector2(cx - bw / 2.0, top), Vector2(bw, bh)))
	_tx("PHƯỢNG HOÀNG TUNG CÁNH", 17.0, Color("fff4d6"), "c", at + Vector2(cx - BANNER_TW / 2.0, BANNER_CY + BANNER_DY), BANNER_TW, BOLD, Color("5a1000"), 3.0)


func _embers(o: Vector2, d_px: float) -> void :
	var span: float = float(W) + 40.0
	for i in 26:
		var sd: float = float((i * 7919 + 13) % 997) / 997.0
		var sp: float = 16.0 + 26.0 * fmod(sd * 13.7, 1.0)
		var life: float = (float(H) + 30.0) / sp
		var ph: float = fmod(_time + sd * life * 3.0, life)
		var y: float = float(H) + 10.0 - ph * sp
		var x: float = fmod(sd * span * 7.3 - d_px * 0.55 + sin(_time * 1.3 + float(i)) * 9.0, span)
		if x < 0.0:
			x += span
		x -= 20.0
		if x < 2.0 or x > float(W) - 2.0 or y < 2.0 or y > float(H) - 2.0:
			continue
		var a: float = 0.7 * sin(ph / life * PI)
		var r: float = 1.1 + fmod(sd * 5.0, 1.5)
		var c: Color = Color("ffd070").lerp(Color("ff6a1e"), ph / life)
		draw_circle((o + Vector2(x, y)) * _f, r * 2.6 * _f, Color(c, a * 0.22), true, -1.0, true)
		draw_circle((o + Vector2(x, y)) * _f, r * _f, Color(c, a), true, -1.0, true)


func _layers(o: Vector2, clip: Rect2, d_px: float) -> void :
	for layer: Array in [[CLOUDS, 1800.0, 0.22], [ISLES, 1600.0, 0.4]]:
		var span: float = float(layer[1])
		var shift: float = fmod(d_px * float(layer[2]), span)
		for e: Array in layer[0]:
			var src: Rect2 = fx_region(str(e[0]))
			var size: Vector2 = src.size * float(e[3])
			for rep_i in 2:
				var x: float = float(e[1]) - shift + span * float(rep_i)
				if x > float(W) or x + size.x < 0.0:
					continue
				_fxp(str(e[0]), o + Vector2(x, float(e[2])), float(e[3]), clip)
	var band: Rect2 = fx_region("band")
	var bk: float = 0.6
	var tw: float = band.size.x * bk
	var th: float = band.size.y * bk
	var bx: float = - fmod(d_px * 0.7, tw)
	while bx < float(W):
		_fxp("band", o + Vector2(bx, float(H) - th + 4.0), bk, clip)
		bx += tw - 1.0



func boot() -> void :
	poll_in = POLL_TICKS
	if not loading:
		load_fp("/phoenix-flight.xml?t=", "poll")

func beat() -> void :
	if opened:
		return
	poll_in -= 1
	if poll_in <= 0:
		poll_in = POLL_TICKS
		if not loading:
			load_fp("/phoenix-flight.xml?t=", "poll")

func button_visible() -> bool:
	return fp_visible

func button_dot() -> bool:
	return fp_visible and used < turns_max

func refresh_button() -> void :
	queue_redraw()

func busy() -> bool:
	return action == "start" or action == "end" or phase == "send"

func chat_busy() -> bool:
	return opened

func open() -> void :
	if opened or not fp_visible:
		return
	tab = 0
	close_note = ""
	if phase == "result":
		phase = "idle"
	show_window()
	load_art()
	if pack != null:
		pack.load_bag()
	if action.is_empty() or action == "poll":
		load_fp("/phoenix-flight.xml?t=", "poll")


func close(note: String = "") -> void :
	if not opened:
		return
	if phase == "fly":
		_fast_forward()
		note = "Phượng Hoàng đã hạ cánh, kết quả lượt bay đang được chấm."
	elif phase == "ready":
		send_end(true)
	hide_window()
	sparks = []
	poll_in = POLL_TICKS
	closed.emit(note)

func leave() -> void :
	close()

func _activate(id: String) -> void :
	if rules_click(id):
		return
	if id == "close":
		close()
	elif id == "start":
		on_start()
	elif id.begins_with("tab:"):
		set_tab(id.substr(4).to_int())

func set_tab(index: int) -> void :
	tab = clampi(index, 0, 2)
	queue_redraw()



func load_fp(prefix: String, what: String) -> void :
	fetch(prefix + str(int(now_ms())), what)

func on_start() -> void :
	if busy() or phase in ["ready", "fly"] or not loaded:
		return
	if used >= turns_max:
		tip("Hôm nay bạn đã bay hết lượt, mai quay lại nhé!")
		return
	result = {}
	sent_token = token
	resent = false
	load_fp(_start_url(), "start")


func _start_url() -> String:
	return "/phoenix-flight-start.xml?k=" + TevWheel.uri_component(token) + "&v=2&t="


func send_end(quit: bool = false) -> void :
	var list: Array = []
	var at: int = -1
	var score: int = 0
	if not quit:
		at = int(bird.get("at", -1))
		score = int(bird.get("passed", 0))
		for k: Variant in flaps:
			if int(k) <= at:
				list.append(int(k))
	end_url = "/phoenix-flight-end.xml?k=%s&r=%d&f=%s&s=%d&p=%d&t=" % [TevWheel.uri_component(token), run, encode(list), at, score]
	sent_token = token
	retries = 0
	retry_at = 0.0
	phase = "idle" if quit else "send"
	fetch(end_url + str(int(now_ms())), "end")

func _failed(what: String) -> void :
	if what == "chunk":
		chunk_busy = false
		ask_at = now_ms() + CHUNK_RETRY_MS
		return
	if what == "end":
		_end_retry()
	elif what == "start":
		tip("Không kết nối được máy chủ, hãy thử lại.")

func _end_retry() -> void :
	retries += 1
	if retries <= RETRIES:
		retry_at = now_ms() + RETRY_MS
		return
	retry_at = 0.0
	if phase == "send":
		phase = "idle"
	tip("Không gửi được kết quả lượt bay, hãy kiểm tra mạng.")

static func _int(at: Dictionary, key: String) -> int:
	return TevWheel.as_int(str(at.get(key, "")))

static func _row(node: Dictionary) -> Dictionary:
	var at: Dictionary = node["at"]
	return {"r": _int(at, "r"), "n": str(at.get("n", "")), "s": _int(at, "s"), "me": str(at.get("me", "")) == "1"}

static func _parse(text: String) -> Variant:
	var xml: Variant = On.parse_deep(text)
	if xml == null and not text.contains("<"):
		xml = {"tag": "", "at": {}, "kids": []}
	return xml

func _reply(text: String, what: String) -> void :
	take_reply(_parse(text), what)

func take_reply(xml: Variant, what: String) -> void :
	if what == "chunk":
		what = _chunk_reply(xml)
		if what.is_empty():
			return
	if xml == null:
		if what == "end":
			_end_retry()
		elif what == "start":
			tip("Thao tác chưa thành công, hãy thử lại sau.")
		return
	var at: Dictionary = xml["at"]
	var notice: String = str(at.get("notice", ""))
	var was_best: int = best
	fp_visible = str(at.get("visible", "")) == "1"
	s_fp_shown = fp_visible
	if fp_visible:
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
		wait_ms = maxi(2000, _int(at, "wait"))
		day = str(at.get("day", ""))
		best = _int(at, "best")
		rank = _int(at, "rank")
		ybest = _int(at, "ybest")
		yrank = _int(at, "yrank")
		yset = str(at.get("yset", "")) == "1"
		yit = str(at.get("yit", ""))
		tiers = got_tiers
		top = got_top
		ytop = got_ytop
		loaded = true
	else:
		reset_run()
		refresh_button()
		if opened:
			close()
		if not notice.is_empty():
			tip(notice)
		return
	var runs: Array = kids(xml, "run")
	var node: Dictionary = runs[0] if not runs.is_empty() else {}
	var rat: Dictionary = node.get("at", {})

	if not notice.is_empty() and (what == "end" or what == "start") and token != sent_token and not token.is_empty() and not resent:
		resent = true
		sent_token = token
		if what == "end":
			end_url = _with_token(end_url)
			fetch(end_url + str(int(now_ms())), "end")
		else:
			load_fp(_start_url(), "start")
		return
	if what == "start":
		if str(rat.get("st", "")) == "live":
			_adopt(rat)
		else:
			phase = "idle"
	elif what == "end":
		retry_at = 0.0
		if not rat.is_empty() and _int(rat, "id") == run and str(rat.get("st", "")) == "done":
			var evs: PackedStringArray = str(rat.get("ev", "")).split(",", false)
			result = {"score": _int(rat, "score"), "note": str(rat.get("note", "")), "old": evs.has("old"), "was_best": was_best, 
				"steps": _int(rat, "steps")}
			if phase == "send" or phase == "idle":
				phase = "result" if opened else "idle"
		elif phase == "send":
			phase = "idle"
	elif what == "poll":
		if phase == "idle" and str(rat.get("st", "")) == "live" and _int(rat, "el") < wait_ms - ADOPT_MS:
			_adopt(rat)
	refresh_button()
	if not notice.is_empty():
		tip(notice)

func _with_token(url: String) -> String:
	var head: String = "/phoenix-flight-end.xml?k="
	var rest: String = url.substr(head.length())
	var cut: int = rest.find("&")
	return head + TevWheel.uri_component(token) + (rest.substr(cut) if cut >= 0 else "")



func _adopt(rat: Dictionary) -> void :
	reset_run()
	run = _int(rat, "id")
	if str(rat.get("v", "")) == "2":
		_adopt2(rat)
		if nb <= 0:
			reset_run()
			return
	else:
		gaps = gaps_of(str(rat.get("g", "")))
	if gaps.is_empty() and not v2:
		phase = "idle"
		return
	phase = "ready"
	auto_at = now_ms() + float(maxi(0, wait_ms - AUTO_MS - _int(rat, "el")))
	result = {}

func reset_run() -> void :
	phase = "idle"
	run = 0
	gaps = PackedInt32Array()
	bird = new_bird()
	prev = bird.duplicate()
	flaps = []
	fi = 0
	t0_us = 0
	auto_at = 0.0
	retry_at = 0.0
	retries = 0
	sparks = []
	v2 = false
	cs = {}
	ne = 0
	nb = 0
	cur = {}
	chunk_ok = false
	chunk_busy = false
	ask_at = 0.0
	stall_at = 0.0



func _adopt2(rat: Dictionary) -> void :
	var n: int = clampi(_int(rat, "n"), 0, 1000)
	v2 = true
	s_v2 = true
	var z: PackedInt32Array = PackedInt32Array()
	z.resize(n)
	z.fill(0)
	cs = {"n": n, "L": clampi(_int(rat, "L"), 1, 600), "c0": z.duplicate(), "m": z.duplicate(), "ga": z.duplicate(), "gs": z.duplicate(), "gl": z.duplicate()}
	cur = new_cursor()
	_absorb(rat)


func _absorb(rat: Dictionary) -> bool:
	if not v2 or _int(rat, "id") != run:
		return false
	var n: int = int(cs["n"])
	var cb: PackedStringArray = str(rat.get("cb", "")).split(";")
	if cb.size() == 2:
		var c0: PackedInt32Array = cs["c0"]
		var i: int = maxi(0, TevWheel.as_int(cb[0]))
		for part: String in cb[1].split(",", false):
			if i >= n:
				break
			c0[i] = TevWheel.as_int(part)
			i += 1
		cs["c0"] = c0
		nb = maxi(nb, i)
	var ce: PackedStringArray = str(rat.get("ce", "")).split(";")
	if ce.size() == 2:
		var m: PackedInt32Array = cs["m"]
		var ga: PackedInt32Array = cs["ga"]
		var gs: PackedInt32Array = cs["gs"]
		var gl: PackedInt32Array = cs["gl"]
		var i: int = maxi(0, TevWheel.as_int(ce[0]))
		for part: String in ce[1].split(",", false):
			var q: PackedStringArray = part.split(":")
			if i >= n or q.size() != 4:
				break
			m[i] = TevWheel.as_int(q[0])
			ga[i] = TevWheel.as_int(q[1])
			gs[i] = TevWheel.as_int(q[2])
			gl[i] = TevWheel.as_int(q[3])
			i += 1
		cs["m"] = m
		cs["ga"] = ga
		cs["gs"] = gs
		cs["gl"] = gl
		ne = mini(maxi(ne, i), nb)
	return true


func _send_chunk() -> void :
	var s: int = int(bird["k"]) if chunk_ok else 0
	var list: Array = []
	if chunk_ok:
		for k: Variant in flaps:
			if int(k) < s:
				list.append(int(k))
	chunk_busy = true
	fetch(("/phoenix-flight-end.xml?k=%s&c=1&r=%d&f=%s&s=%d&h=%d&t=" % [TevWheel.uri_component(token), run, encode(list), s, ne]) + str(int(now_ms())), "chunk")


func _ask() -> void :
	if not v2 or phase != "fly" or chunk_busy or now_ms() < ask_at:
		return
	if chunk_ok and reveal_count(cur, int(bird["k"]), int(cs["L"]), int(cs["n"])) <= ne:
		return
	_send_chunk()


func _chunk_reply(xml: Variant) -> String:
	chunk_busy = false
	if xml == null:
		ask_at = now_ms() + CHUNK_RETRY_MS
		return ""
	if str((xml["at"] as Dictionary).get("c", "")) == "1":
		var had: int = ne
		for node: Dictionary in kids(xml, "run"):
			if _absorb(node["at"]):
				chunk_ok = true
		ask_at = 0.0 if ne > had else now_ms() + CHUNK_GAP_MS
		return ""
	var runs: Array = kids(xml, "run")
	var rat: Dictionary = (runs[0] as Dictionary).get("at", {}) if not runs.is_empty() else {}
	if v2 and phase == "fly" and not rat.is_empty() and _int(rat, "id") == run and str(rat.get("st", "")) == "done":
		phase = "send"
		resent = true
		return "end"
	ask_at = now_ms() + CHUNK_RETRY_MS
	return "poll"


func _pump2(due: int) -> void :
	var lim: int = limit_of(ne, int(cs["n"]))
	while int(bird["k"]) < due and str(bird["dead"]).is_empty() and can_step(bird, lim):
		prev = bird.duplicate()
		var go: bool = fi < flaps.size() and int(flaps[fi]) == int(bird["k"])
		if go:
			fi += 1
		step2(bird, cs, go)
		if int(bird["k"]) % 2 == 0:
			_spark()
	if not str(bird["dead"]).is_empty():
		_died()
		return
	if int(bird["k"]) < due:
		var t: float = now_ms()
		if stall_at <= 0.0:
			stall_at = t
		elif t - stall_at > STALL_MS:
			_give_up()
			return
		t0_us = now_us() - (int(bird["k"]) * 1000000 + HZ - 1) / HZ
	else:
		stall_at = 0.0
	_ask()

func _give_up() -> void :
	bird["dead"] = "q"
	bird["at"] = int(bird["k"]) - 1
	stall_at = 0.0
	tip("Mất kết nối máy chủ quá lâu nên lượt bay dừng tại đây.")
	_died()


func _gust_fx(o: Vector2, clip: Rect2, d: int, t: float) -> void :
	var off: int = d - d_trig(0)
	if off < 0:
		return
	var j: int = off / (SP * U)
	if j >= ne:
		return
	var ga: int = (cs["ga"] as PackedInt32Array)[j]
	if ga == 0:
		return
	var x: int = off - j * SP * U
	var gs: int = (cs["gs"] as PackedInt32Array)[j] * U
	var ge: int = gs + (cs["gl"] as PackedInt32Array)[j] * U
	if x >= ge:
		return
	var up: bool = ga < 0
	var word: String = "Gió giật đẩy lên" if up else "Gió giật đẩy xuống"
	if x < gs:
		_tx(word, 18.0, Color(1.0, 0.86, 0.35, 0.6 + 0.4 * sin(t / 70.0)), "c", o + Vector2(0, 84), float(W), BOLD, Color(GOLD_RIM, 0.9), 3.0)
		return
	_tx(word, 18.0, Color("fff1b0"), "c", o + Vector2(0, 84), float(W), BOLD, Color(GOLD_RIM, 0.9), 3.0)
	for i in 7:
		var ph: float = fmod(t / 4.0 + float(i) * 37.0, 120.0) * 3.6
		var a0: Vector2 = o + Vector2(float(BX) - 120.0 + float(i) * 44.0, (float(H) - ph) if up else ph)
		var a1: Vector2 = a0 + Vector2(0, -26.0 if up else 26.0)
		if clip.has_point(a0) and clip.has_point(a1):
			draw_line(a0 * _f, a1 * _f, Color(1, 1, 1, 0.35), 2.0 * _f, true)




func flap() -> void :
	if phase == "ready":
		phase = "fly"
		t0_us = now_us()
		bird = new_bird()
		prev = bird.duplicate()
		flaps = [0]
		fi = 0
		flap_at = now_ms()
		if v2:
			_send_chunk()
		pump()
		return
	if phase != "fly":
		return
	pump()
	if phase != "fly" or flaps.size() >= MAX_FLAPS:
		return
	var k: int = int(bird["k"])
	var last: int = int(flaps[-1])
	if last >= k:
		return
	if k - last < MINGAP:
		k = last + MINGAP
	flaps.append(k)
	flap_at = now_ms()


func pump() -> void :
	if phase == "ready" and auto_at > 0.0 and now_ms() >= auto_at:
		flap()
		return
	if phase != "fly":
		return
	var due: int = mini(MAX_STEPS, int((now_us() - t0_us) * HZ / 1000000) + 1)
	if v2:
		_pump2(due)
		return
	while int(bird["k"]) < due and str(bird["dead"]).is_empty():
		prev = bird.duplicate()
		var go: bool = fi < flaps.size() and int(flaps[fi]) == int(bird["k"])
		if go:
			fi += 1
		step(bird, gaps, go)
		if int(bird["k"]) % 2 == 0:
			_spark()
	if not str(bird["dead"]).is_empty():
		_died()

func _fast_forward() -> void :
	var lim: int = limit_of(ne, int(cs["n"])) if v2 else FAR
	while str(bird["dead"]).is_empty():
		if v2 and not can_step(bird, lim):
			bird["dead"] = "q"
			bird["at"] = int(bird["k"]) - 1
			break
		prev = bird.duplicate()
		var go: bool = fi < flaps.size() and int(flaps[fi]) == int(bird["k"])
		if go:
			fi += 1
		if v2:
			step2(bird, cs, go)
		else:
			step(bird, gaps, go)
	_died()

func _died() -> void :
	dead_at = now_ms()
	for i in 10:
		var a: float = _rng.randf() * TAU
		sparks.append({"x": float(bird["d"]) / U + BX + cos(a) * 8.0, "y": float(bird["y"]) / U + sin(a) * 8.0, "at": dead_at, "dur": 700.0, 
			"r": 3.0 + _rng.randf() * 3.0, "vx": cos(a) * 60.0, "vy": sin(a) * 60.0, "c": 1})
	send_end()

func _spark() -> void :
	if sparks.size() >= 40:
		sparks.pop_front()
	sparks.append({"x": float(bird["d"]) / U + BX - 28.0, "y": float(bird["y"]) / U + 4.0 + _rng.randf_range(-5.0, 5.0), "at": now_ms(), 
		"dur": 520.0, "r": 2.5 + _rng.randf() * 3.0, "vx": _rng.randf_range(-20.0, 0.0), "vy": _rng.randf_range(-14.0, 14.0), "c": 0})

func _tick(delta: float) -> void :
	super (delta)
	if opened or phase in ["fly", "ready"]:
		pump()

func _anim() -> void :
	var t: float = now_ms()
	sparks = sparks.filter( func(e: Dictionary) -> bool: return t < float(e["at"]) + float(e["dur"]))
	if retry_at > 0.0 and t >= retry_at and not loading:
		retry_at = 0.0
		fetch(end_url + str(int(t)), "end")




func _top_hit(point: Vector2) -> String:
	for i in range(_hits.size() - 1, -1, -1):
		if (_hits[i][1] as Rect2).has_point(point):
			return str(_hits[i][0])
	return ""

func _gui_input(event: InputEvent) -> void :
	if opened and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed\
	and phase in ["ready", "fly"] and _top_hit(event.position) == "field":
		flap()
		accept_event()
		return
	super (event)

func _input(event: InputEvent) -> void :
	if not opened or not is_visible_in_tree() or not (event is InputEventKey) or not event.pressed or event.echo:
		return
	if not ((event as InputEventKey).keycode in [KEY_SPACE, KEY_UP, KEY_W]) or not (phase in ["ready", "fly"]) or rules_on:
		return
	var focus: Control = get_viewport().gui_get_focus_owner() if get_viewport() != null else null
	if focus is LineEdit or focus is TextEdit:
		return
	flap()
	get_viewport().set_input_as_handled()



func rules_title() -> String:
	return "PHƯỢNG HOÀNG TUNG CÁNH"

func rules_text() -> String:
	return ("• Chạm vào khung bay, bấm chuột hoặc phím Space (↑, W) để Phượng Hoàng vỗ cánh bay lên; thả ra thì trọng lực kéo xuống.\n"
		+ "• Luồn qua khe giữa các cột gạch: mỗi cột vượt qua được 1 điểm. Chạm cột hoặc chạm đất là hết lượt bay.\n"
		+ "• Càng bay xa tốc độ càng tăng, khe càng hẹp và lệch nhau nhiều hơn.\n"
		+ "• Mỗi ngày " + str(turns_max) + " lượt, lượt mới lúc 00:00. Điểm cao nhất trong ngày được tính xếp hạng; bằng điểm thì ai đạt trước xếp trên.\n"
		+ "• Sau 00:00, quà xếp hạng hôm qua gửi vào Hộp thư.\n"
		+ "• Máy chủ chấm lại từng lượt theo nhật ký vỗ cánh và thời gian bay thật."
		+ (RULES_V2 if v2 or s_v2 else ""))


func _tx(text: String, px: float, color: Color, align: String, p: Vector2, w: float, font: Font = SEMI, rim: Color = Color(0, 0, 0, 0), thick: float = 3.0) -> void :
	var size: float = px * 2.0
	while size > 16.0 and _measure(text, font, size) > w * 2.0:
		size -= 1.0
	var at: Vector2 = Vector2(p.x if align == "l" else (p.x + w / 2.0 if align == "c" else p.x + w), p.y) * _f
	if rim.a > 0.0:
		var font_size: int = maxi(6, roundi(size * _u))
		var origin: Vector2 = at
		var mode: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
		if align == "c":
			origin.x -= w * _f / 2.0
			mode = HORIZONTAL_ALIGNMENT_CENTER
		elif align == "r":
			origin.x -= w * _f
			mode = HORIZONTAL_ALIGNMENT_RIGHT
		origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
		draw_string_outline(font, origin, text, mode, w * _f, font_size, maxi(2, roundi(thick * _f)), rim)
		draw_string(font, origin, text, mode, w * _f, font_size, color)
		return
	_string(text, font, size, color, align, at, w * _f)

func _rect(at: Vector2, x: float, y: float, w: float, h: float) -> Rect2:
	return Rect2((at + Vector2(x, y)) * _f, Vector2(w, h) * _f)

func _body(at: Vector2) -> void :

	var frame: Rect2 = _rect(at, 0, 0, FP_W, FP_H)
	if _warm():
		_plate(Rect2(frame.position + Vector2(0, 6) * _f, frame.size), Color(0, 0, 0, 0.35), Color(0, 0, 0, 0), 14.0, 0.0)
		_fp_window(at)
	else:
		draw_rect(Rect2(frame.position + Vector2(0, 6) * _f, frame.size), Color(0, 0, 0, 0.35))
		_grad(frame, Color("0d3a73"), NAVY, Color(GLASS_EDGE, 0.95), 28.0, 3.0)
		_plate(_rect(at, 5, 5, FP_W - 10.0, FP_H - 10.0), Color(0, 0, 0, 0), Color(BTN_EDGE, 0.22), 22.0, 2.0)
		_stars(at)
	_field(at)
	_side(at)
	_banner(at)

func _chrome(at: Vector2) -> void :
	rules_button(at + Vector2(FP_W - 76.0, 24.0), 14.0)
	var rect: Rect2 = _rect(at, FP_W - 50.0, 9, 32, 32)
	if _warm():
		draw_circle(rect.get_center(), 18.5 * _f, Color("7a3e0c"), true, -1.0, true)
	var lit: bool = _hover == "close" and _press.is_empty() and not _mobile
	_grad(rect, BTN_TOP.lightened(0.12) if lit else BTN_TOP, BTN_LOW, Color(BTN_EDGE, 0.95), 32.0, 2.0)
	var c: Vector2 = rect.get_center()
	var s: float = 7.0 * _f
	draw_line(c + Vector2( - s, - s), c + Vector2(s, s), BLUE_RIM, maxf(2.0, 5.0 * _f), true)
	draw_line(c + Vector2( - s, s), c + Vector2(s, - s), BLUE_RIM, maxf(2.0, 5.0 * _f), true)
	draw_line(c + Vector2( - s, - s), c + Vector2(s, s), Color.WHITE, maxf(1.5, 3.0 * _f), true)
	draw_line(c + Vector2( - s, s), c + Vector2(s, - s), Color.WHITE, maxf(1.5, 3.0 * _f), true)
	_hit("close", rect.grow(4.0 * _f), false)


func _warm() -> bool:
	return _fx_tex != null and R2.has("w_tl")


func _win_piece(name: String, dst: Rect2, pad: float = WIN_PAD) -> void :
	var src: Rect2 = fx_region(name).grow( - pad)
	_piece(_fx_tex, src, dst)


func _fp_window(at: Vector2) -> void :
	_win_piece("w_in", Rect2(at + Vector2(WB, WB), Vector2(FP_W - 2.0 * WB, FP_H - 2.0 * WB)), WIN_IN_PAD)
	_win_piece("w_t", Rect2(at + Vector2(WC, 0), Vector2(FP_W - 2.0 * WC, WB)))
	_win_piece("w_b", Rect2(at + Vector2(WC, FP_H - WB), Vector2(FP_W - 2.0 * WC, WB)))
	_win_piece("w_l", Rect2(at + Vector2(0, WC), Vector2(WB, FP_H - 2.0 * WC)))
	_win_piece("w_r", Rect2(at + Vector2(FP_W - WB, WC), Vector2(WB, FP_H - 2.0 * WC)))
	_win_piece("w_tl", Rect2(at, Vector2(WC, WC)))
	_win_piece("w_tr", Rect2(at + Vector2(FP_W - WC, 0), Vector2(WC, WC)))
	_win_piece("w_bl", Rect2(at + Vector2(0, FP_H - WC), Vector2(WC, WC)))
	_win_piece("w_br", Rect2(at + Vector2(FP_W - WC, FP_H - WC), Vector2(WC, WC)))


func _fp_panel(rect: Rect2, selected: bool = false) -> void :
	if _warm():
		_grad(rect, Color(WARM_TOP, 0.94), Color(WARM_LOW, 0.94), Color(GOLD, 0.95) if selected else Color(WARM_EDGE, 0.8))
	else:
		_panel(rect, selected)


func _muted(alpha: float = 1.0) -> Color:
	return Color(WARM_MUTED, alpha) if _warm() else Color(MUTED, alpha)


func _stars(at: Vector2) -> void :
	var lcg: int = 7919
	for i in 64:
		lcg = (lcg * 1103515245 + 12345) & 2147483647
		var x: float = 10.0 + float(lcg % int(FP_W - 20.0))
		lcg = (lcg * 1103515245 + 12345) & 2147483647
		var y: float = 10.0 + float(lcg % 540)
		var tw: float = 0.35 + 0.65 * absf(sin(_time * (0.6 + float(i % 5) * 0.25) + float(i)))
		var r: float = 0.8 + float(i % 3) * 0.45
		draw_circle((at + Vector2(x, y)) * _f, r * _f, Color(0.75, 0.9, 1.0, 0.55 * tw), true, -1.0, true)

func _field(at: Vector2) -> void :
	var o: Vector2 = at + Vector2(FIELD_X, FIELD_Y)
	var clip: Rect2 = Rect2(o, Vector2(W, H))
	_plate(Rect2((o - Vector2(6, 6)) * _f, Vector2(W + 12, H + 12) * _f), Color(GLASS_LOW, 0.95), Color(0, 0, 0, 0) if _fx_tex != null else Color(GLASS_EDGE, 0.85), 14.0, 3.0)
	var t: float = now_ms()
	var frac: float = 0.0
	if phase == "fly" and str(bird["dead"]).is_empty():
		var tau: float = float(now_us() - t0_us) * float(HZ) / 1000000.0
		frac = clampf(tau - float(int(bird["k"]) - 1), 0.0, 1.0)
	var bd: Dictionary = bird if not bird.is_empty() else new_bird()
	var pv: Dictionary = prev if not prev.is_empty() else bd
	var d_px: float = lerpf(float(pv["d"]), float(bd["d"]), frac) / float(U)
	var y_px: float = lerpf(float(pv["y"]), float(bd["y"]), frac) / float(U)
	var vy: float = float(bd["vy"])
	_d_now = d_px
	if _sky_tex != null and _fx_tex != null:

		var sz: Vector2 = Vector2(_sky_tex.get_size())
		var stw: float = sz.x * float(H) / sz.y
		var sx0: float = - fmod(d_px * 0.12, stw * 2.0)
		var sn: int = 0
		while sx0 < float(W):
			_piece(_sky_tex, Rect2(Vector2.ZERO, sz), Rect2(o + Vector2(sx0, 0), Vector2(stw, H)), clip, sn % 2 == 1)
			sx0 += stw
			sn += 1
		_layers(o, clip, d_px)
	else:
		_old_sky(o, clip, d_px)
	if not gaps.is_empty() or v2:
		_columns(o, clip, d_px, int(bd["passed"]))
	if _fx_tex != null:
		_embers(o, d_px)
	_trail_bird(o, t, bd, y_px, vy)
	_frame(o)
	if v2 and phase == "fly":
		_gust_fx(o, clip, int(bd["d"]), t)

	if phase in ["fly", "send"]:
		_tx(str(int(bd["passed"])), 34.0, Color.WHITE, "c", o + Vector2(0, 38), float(W), BOLD, Color(GOLD_RIM, 0.95), 4.0)
	_hit("field", Rect2(o * _f, Vector2(W, H) * _f), false)
	_overlay(o, t)


func _old_sky(o: Vector2, clip: Rect2, d_px: float) -> void :

	var sky: Rect2 = region("sky")
	var tile_w: float = sky.size.x * float(H) / sky.size.y
	var shift: float = fmod(d_px * 0.3, tile_w * 2.0)
	var x: float = - shift
	var n: int = 0
	while x < float(W):
		_blit("sky", Rect2(o + Vector2(x, 0), Vector2(tile_w, H)), clip, n % 2 == 1, Color(0.82, 0.88, 1.0))
		x += tile_w
		n += 1

	var top_c: Color = Color(NAVY, 0.45)
	var mid_c: Color = Color(NAVY, 0.0)
	var low_c: Color = Color("ff8a2a", 0.22)
	var a: Vector2 = o * _f
	var bw: float = W * _f
	var bh: float = H * _f
	draw_polygon(PackedVector2Array([a, a + Vector2(bw, 0), a + Vector2(bw, bh * 0.45), a + Vector2(0, bh * 0.45)]), PackedColorArray([top_c, top_c, mid_c, mid_c]))
	draw_polygon(PackedVector2Array([a + Vector2(0, bh * 0.6), a + Vector2(bw, bh * 0.6), a + Vector2(bw, bh), a + Vector2(0, bh)]), PackedColorArray([mid_c, mid_c, low_c, low_c]))


func _trail_bird(o: Vector2, t: float, bd: Dictionary, y_px: float, vy: float) -> void :
	var d_px: float = _d_now

	for e: Dictionary in sparks:
		var age: float = (t - float(e["at"])) / float(e["dur"])
		if age < 0.0 or age > 1.0:
			continue
		var px: float = float(e["x"]) - d_px + float(e["vx"]) * age
		var py: float = float(e["y"]) + float(e["vy"]) * age
		if px < 0.0 or px > float(W) or py < 0.0 or py > float(H):
			continue
		var c: Color = Color("ffd25a").lerp(Color("ff4a12"), age) if int(e["c"]) == 0 else Color("fff0a0").lerp(Color("ff7a1a"), age)
		draw_circle((o + Vector2(px, py)) * _f, float(e["r"]) * (1.0 - age * 0.6) * _f, Color(c, 0.85 * (1.0 - age)), true, -1.0, true)

	var by: float = y_px
	var rot: float = clampf(vy / float(VMAX) * 0.9, -0.45, 0.9)
	if phase in ["idle", "ready"]:
		by = float(Y0) + sin(_time * 3.2) * 7.0
		rot = sin(_time * 3.2 + 1.2) * 0.08
	elif phase in ["send", "result"] and dead_at > 0.0:
		var fall: float = clampf((t - dead_at) / 600.0, 0.0, 1.0)
		by = lerpf(y_px, float(H) - 18.0, fall * fall) if str(bd["dead"]) != "g" else y_px
		rot = lerpf(rot, 1.2, fall)
	var flick: float = clampf(1.0 - (t - flap_at) / 160.0, 0.0, 1.0)
	_bird(o + Vector2(float(BX), by), rot, 1.0 + 0.08 * flick, 1.0 if phase != "send" else 0.85)

	draw_line((o + Vector2(0, H - 1)) * _f, (o + Vector2(W, H - 1)) * _f, Color("ffb630", 0.8), maxf(1.0, 2.0 * _f), true)

func _columns(o: Vector2, clip: Rect2, d_px: float, passed: int) -> void :
	var col: Rect2 = region("col")
	var j: int = maxi(0, passed - 2)
	var dn: int = int(d_px * float(U))
	while j < (nb if v2 else gaps.size()):
		var left: float = float(FIRST + j * SP) - d_px
		if left > float(W):
			break
		if left + float(CW) + 8.0 >= 0.0:
			var c: float = (float(centre_at(cs, j, dn)) / float(U)) if v2 else float(gaps[j])
			var half: float = float(gap_h(j)) / 2.0
			var top_len: float = c - half
			var low_y: float = c + half
			var low_len: float = float(H) - low_y
			if top_len > 0.0:
				var src: Rect2 = Rect2(col.position.x, col.end.y - minf(col.size.y, top_len), col.size.x, minf(col.size.y, top_len))
				_blit("col", Rect2(o + Vector2(left, 0), Vector2(CW, top_len)), clip, false, Color.WHITE, src)
				_cap(Rect2(o + Vector2(left - (CAP_W - CW) / 2.0, top_len - CAP_H), Vector2(CAP_W, CAP_H)), clip, true)
			if low_len > 0.0:
				var src2: Rect2 = Rect2(col.position.x, col.position.y, col.size.x, minf(col.size.y, low_len))
				_blit("col", Rect2(o + Vector2(left, low_y), Vector2(CW, low_len)), clip, false, Color.WHITE, src2)
				_cap(Rect2(o + Vector2(left - (CAP_W - CW) / 2.0, low_y), Vector2(CAP_W, CAP_H)), clip, false)
		j += 1


func _cap(dst: Rect2, clip: Rect2, top: bool) -> void :
	if _fx_tex == null:
		var lid: Rect2 = Rect2(dst.position.x - (LID_W - CAP_W) / 2.0, dst.end.y - LID_H if top else dst.position.y, LID_W, LID_H)
		_blit("lid", lid, clip)
		return
	_piece(_fx_tex, fx_region("cap"), dst, clip, false, top)

func _bird(centre: Vector2, rot: float, grow: float, alpha: float) -> void :
	var texture: Texture2D = art("bird")
	if texture == null:
		return
	var size: Vector2 = Vector2(BIRD_W, BIRD_W * float(texture.get_height()) / float(texture.get_width())) * grow

	draw_circle(centre * _f, 20.0 * grow * _f, Color("ff9a1e", 0.18 * alpha), true, -1.0, true)
	draw_set_transform(centre * _f, rot, Vector2.ONE)
	draw_texture_rect(texture, Rect2(Vector2( - size.x * 0.55, - size.y * 0.5) * _f, size * _f), false, Color(1, 1, 1, alpha))
	draw_set_transform_matrix(Transform2D.IDENTITY)

func _overlay(o: Vector2, t: float) -> void :
	if not loaded:
		_card(o, 140.0, 96.0)
		_tx("Đang tải...", 16.0, ON_BLUE, "c", o + Vector2(0, H / 2.0), float(W), SEMI)
		return
	if phase == "idle":
		_card(o, 128.0, 140.0)
		var left: int = maxi(0, turns_max - used)
		_tx("Phượng Hoàng Tung Cánh" if left > 0 else "Hôm nay đã bay hết lượt", 20.0, ON_GOLD, "c", o + Vector2(0, 166), float(W), BOLD, GOLD_RIM, 3.0)
		_tx("Nhấn BẮT ĐẦU để cất cánh" if left > 0 else "Lượt mới lúc 00:00, mai quay lại nhé!", 14.0, ON_BLUE, "c", o + Vector2(0, 202), float(W), SEMI)
		_tx("Còn " + str(left) + "/" + str(turns_max) + " lượt hôm nay", 12.0, _muted(0.95), "c", o + Vector2(0, 234), float(W), SEMI)
	elif phase == "ready":
		var left_s: int = maxi(0, ceili((auto_at - t) / 1000.0))
		_card(o, 300.0, 100.0)
		_tx("Chạm vào khung · bấm chuột · phím Space", 15.0, ON_BLUE, "c", o + Vector2(0, 330), float(W), SEMI)
		_tx("để vỗ cánh" + ("  ·  tự cất cánh sau " + str(left_s) + " giây" if auto_at > 0.0 else ""), 13.0, Color(GOLD, 1.0), "c", o + Vector2(0, 362), float(W), SEMI)
	elif phase == "fly" and stall_at > 0.0 and t - stall_at >= STALL_SHOW_MS:
		_card(o, 180.0, 70.0)
		_tx("Đang chờ máy chủ…", 16.0, ON_BLUE, "c", o + Vector2(0, 215), float(W), SEMI)
	elif phase == "send":
		_card(o, 180.0, 70.0)
		_tx("Đang chấm điểm…", 16.0, ON_BLUE, "c", o + Vector2(0, 215), float(W), SEMI)
	elif phase == "result":
		_result(o)


func _card(o: Vector2, y: float, h: float) -> void :
	_fp_panel(Rect2((o + Vector2(110, y)) * _f, Vector2(W - 220, h) * _f))

func _result(o: Vector2) -> void :
	draw_rect(Rect2(o * _f, Vector2(W, H) * _f), Color(NAVY, 0.45))
	var box: Vector2 = o + Vector2(120, 70)
	var bw: float = W - 240.0
	_fp_panel(Rect2(box * _f, Vector2(bw, 300) * _f), true)
	var _ink: Color = _tab_plate(Rect2((box + Vector2(bw / 2.0 - 90.0, -16)) * _f, Vector2(180, 36) * _f), true, false, 20.0)
	_tx("KẾT QUẢ", 16.0, ON_GOLD, "c", box + Vector2(bw / 2.0 - 90.0, 2), 180.0, BOLD, GOLD_RIM, 2.5)
	var score: int = int(result.get("score", 0))
	var note: String = str(result.get("note", ""))
	_tx(str(score), 48.0, Color("ffe27a"), "c", box + Vector2(0, 74), bw, BOLD, Color(GOLD_RIM, 1.0), 5.0)
	_tx("cột vượt qua", 13.0, ON_BLUE, "c", box + Vector2(0, 112), bw, SEMI)
	var line: String = ""
	if note.is_empty() and score > int(result.get("was_best", 0)) and score > 0:
		line = "Kỷ lục mới hôm nay!"
	elif NOTES.has(note):
		line = str(NOTES[note])
	elif bool(result.get("old", false)):
		line = "Lượt bay này đã được chấm trước đó."
	if not line.is_empty():
		_tx(line, 13.0, Color("ffd84a") if note.is_empty() else Color("ff9b8a"), "c", box + Vector2(14, 142), bw - 28.0, SEMI)
	_tx("Kỷ lục hôm nay: " + str(best) + ("   ·   Hạng " + str(rank) if rank > 0 else ""), 13.0, Color(CREAM, 0.95), "c", box + Vector2(0, 172), bw, SEMI)
	var left: int = maxi(0, turns_max - used)
	_button("start", "BAY TIẾP" if left > 0 else "HẾT LƯỢT", Rect2((box + Vector2(bw / 2.0 - 100.0, 204)) * _f, Vector2(200, 46) * _f), true, 
		left > 0 and not busy(), 34.0)
	_tx("Còn " + str(left) + " lượt hôm nay", 12.0, _muted(0.95), "c", box + Vector2(0, 272), bw, SEMI)

func _side(at: Vector2) -> void :
	var x: float = SIDE_X

	_fp_panel(_rect(at, x, 56, SIDE_W, 112))
	_side_trim(_rect(at, x, 56, SIDE_W, 112))
	var left: int = maxi(0, turns_max - used)
	_tx("Lượt còn hôm nay", 12.0, _muted(1.0), "c", at + Vector2(x, 76), SIDE_W / 2.0, SEMI)
	_tx(str(left) + "/" + str(turns_max), 22.0, ON_GOLD, "c", at + Vector2(x, 104), SIDE_W / 2.0, BOLD, GOLD_RIM, 3.0)
	_tx("Kỷ lục hôm nay", 12.0, _muted(1.0), "c", at + Vector2(x + SIDE_W / 2.0, 76), SIDE_W / 2.0, SEMI)
	_tx(str(best) if best > 0 else "—", 22.0, ON_GOLD, "c", at + Vector2(x + SIDE_W / 2.0, 104), SIDE_W / 2.0, BOLD, GOLD_RIM, 3.0)
	draw_line((at + Vector2(x + SIDE_W / 2.0, 66)) * _f, (at + Vector2(x + SIDE_W / 2.0, 120)) * _f, Color(WARM_EDGE, 0.45) if _warm() else Color(GLASS_EDGE, 0.35), maxf(1.0, _f))
	_tx(("Hạng hôm nay: " + str(rank)) if rank > 0 else "Chưa có điểm hôm nay", 12.0, ON_BLUE, "c", at + Vector2(x, 146), SIDE_W, SEMI)

	var labels: Array = ["Hôm nay", "Hôm qua", "Quà"]
	for i in 3:
		var r: Rect2 = _rect(at, x + float(i) * 94.0, 180, 92, 32)
		var id: String = "tab:%d" % i
		var ink: Color = _tab_plate(r, tab == i, _hover == id and not _mobile, 16.0)
		_string(str(labels[i]), SEMI, 26.0, ink, "c", r.get_center(), r.size.x)
		if tab != i:
			_hit(id, r, false)

	var list_rect: Rect2 = _rect(at, x, 218, SIDE_W, 226)
	_fp_panel(list_rect)
	_side_trim(list_rect)
	if tab == 2:
		_rewards(at + Vector2(x, 218))
	else:
		_ranking(at + Vector2(x, 218))

	var label: String = "BẮT ĐẦU"
	var enabled: bool = loaded and left > 0 and not busy() and phase in ["idle", "result"]
	if phase in ["ready", "fly"]:
		label = "ĐANG BAY…"
	elif phase == "send" or action == "start":
		label = "ĐANG CHỜ…"
	elif loaded and left <= 0:
		label = "HẾT LƯỢT"
	_button("start", label, _rect(at, x, 456, SIDE_W, 50), true, enabled, 36.0)
	_tx("Mỗi ngày " + str(turns_max) + " lượt · lượt mới lúc 00:00", 11.0, _muted(0.95), "c", at + Vector2(x, 522), SIDE_W, SEMI)


func _side_trim(r: Rect2) -> void :
	if _fx_tex == null:
		return
	_box.draw_center = false
	_plate(r.grow(-3.0 * _f), Color(0, 0, 0, 0), Color(1.0, 0.56, 0.2, 0.55), 12.0, 1.0)
	_box.draw_center = true

func _ranking(p: Vector2) -> void :
	var list: Array = top if tab == 0 else ytop
	_tx("#", 11.0, Color(GOLD, 1.0), "c", p + Vector2(8, 16), 26.0, SEMI)
	_tx("Tên", 11.0, Color(GOLD, 1.0), "l", p + Vector2(42, 16), 150.0, SEMI)
	_tx("Điểm", 11.0, Color(GOLD, 1.0), "r", p + Vector2(190, 16), 76.0, SEMI)
	var i: int = 0
	for row: Dictionary in list:
		if i >= 10:
			break
		var y: float = 34.0 + float(i) * 16.5
		var me: bool = bool(row["me"])
		if me:
			_plate(Rect2((p + Vector2(6, y)) * _f, Vector2(SIDE_W - 12.0, 16) * _f), Color(BTN_GOLD, 0.25), Color(GOLD, 0.6), 6.0, 1.0)
		elif i % 2 == 0:
			draw_rect(Rect2((p + Vector2(6, y)) * _f, Vector2(SIDE_W - 12.0, 16) * _f), Color(1, 1, 1, 0.04))
		var place: int = int(row["r"])
		var medal: Color = Color(0, 0, 0, 0)
		if place >= 1 and place <= 3:
			medal = MEDALS[place - 1]
		if medal.a > 0.0:
			draw_circle((p + Vector2(21, y + 8)) * _f, 7.0 * _f, medal, true, -1.0, true)
		var ink: Color = Color("ffe27a") if me else Color(CREAM, 0.95)
		_tx(str(place), 10.5, Color("3a1a00") if medal.a > 0.0 else ink, "c", p + Vector2(8, y + 8), 26.0, SEMI)
		_tx(str(row["n"]), 11.0, ink, "l", p + Vector2(42, y + 8), 150.0, SEMI)
		_tx(num(int(row["s"])), 11.0, ink, "r", p + Vector2(190, y + 8), 76.0, SEMI)
		i += 1
	if i == 0:
		_tx("Chưa có ai ghi điểm" if tab == 0 else "Hôm qua chưa có ai ghi điểm", 12.0, _muted(1.0), "c", p + Vector2(0, 100), SIDE_W, SEMI)
	var mine: String = ""
	if tab == 0:
		mine = ("Bạn: hạng " + str(rank) + " · " + num(best) + " điểm") if rank > 0 else ("Bạn: " + num(best) + " điểm" if best > 0 else "Bạn chưa có điểm hôm nay")
	else:
		mine = ("Bạn: hạng " + str(yrank) + " · " + num(ybest) + " điểm") if yrank > 0 else "Hôm qua bạn chưa có hạng"
		if yset and not yit.is_empty():
			mine += " · đã gửi quà"
	_plate(Rect2((p + Vector2(6, 204)) * _f, Vector2(SIDE_W - 12.0, 18) * _f), Color("5a2410", 0.75) if _warm() else Color(BTN_LOW, 0.55), Color(WARM_EDGE, 0.5) if _warm() else Color(BTN_EDGE, 0.35), 8.0, 1.0)
	_tx(mine, 11.0, Color("ffe27a"), "c", p + Vector2(6, 213), SIDE_W - 12.0, SEMI)

func _rewards(p: Vector2) -> void :
	var y: float = 12.0
	var any: bool = false
	for tier: Dictionary in tiers:
		var items: Array = []
		for part: String in str(tier["it"]).split(",", false):
			var bits: PackedStringArray = part.split(":")
			if bits.size() > 1 and TevWheel.as_int(bits[0]) > 0:
				items.append([TevWheel.as_int(bits[0]), maxi(1, TevWheel.as_int(bits[1]))])
		if items.is_empty() or y > 170.0:
			continue
		any = true
		var a: int = int(tier["a"])
		var b: int = int(tier["b"])
		_plate(Rect2((p + Vector2(8, y)) * _f, Vector2(SIDE_W - 16.0, 42) * _f), Color("4a1c0c", 0.55) if _warm() else Color(BTN_LOW, 0.35), Color(WARM_EDGE, 0.4) if _warm() else Color(BTN_EDGE, 0.3), 10.0, 1.0)
		_tx("Hạng " + str(a) if a == b else "Hạng " + str(a) + "–" + str(b), 12.0, ON_GOLD, "c", p + Vector2(10, y + 21), 70.0, BOLD, GOLD_RIM, 2.0)
		for k in mini(4, items.size()):
			var c: Vector2 = p + Vector2(104.0 + float(k) * 44.0, y + 21.0)
			_plate(Rect2((c - Vector2(18, 18)) * _f, Vector2(36, 36) * _f), Color("160604", 0.9) if _warm() else Color(GLASS_LOW, 0.9), Color(WARM_EDGE, 0.55) if _warm() else Color(GLASS_EDGE, 0.5), 8.0, 1.0)
			icon(int(items[k][0]), 30.0, c)
			_tx("x" + str(items[k][1]), 9.5, Color.WHITE, "r", c + Vector2(-18, 12), 34.0, BOLD, Color(0, 0, 0, 0.9), 2.0)
			tip_area(Rect2(c - Vector2(18, 18), Vector2(36, 36)), int(items[k][0]), "")
		y += 48.0
	if not any:
		_tx("Phần thưởng xếp hạng", 13.0, ON_GOLD, "c", p + Vector2(0, 80), SIDE_W, BOLD, GOLD_RIM, 2.0)
		_tx("sẽ được công bố sau.", 12.0, ON_BLUE, "c", p + Vector2(0, 104), SIDE_W, SEMI)
	_tx("Quà gửi vào Hộp thư sau 00:00", 11.0, _muted(1.0), "c", p + Vector2(0, 213), SIDE_W, SEMI)
