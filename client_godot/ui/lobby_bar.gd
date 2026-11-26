extends RefCounted





const Settings = preload("res://settings.gd")
const XBOLD: Font = preload("res://assets/fonts/BeVietnamPro-ExtraBold.ttf")
const SEMI: Font = preload("res://assets/fonts/BeVietnamPro-SemiBold.ttf")
const MEDIUM: Font = preload("res://assets/fonts/BeVietnamPro-Medium.ttf")

const STYLES: Array[String] = ["bright", "glass"]
const NAMES: Dictionary = {"bright": "Kiểu A · Sáng", "glass": "Kiểu B · Kính"}
const NOTES: Dictionary = {"bright": "Nền sáng, nút ảnh bóng", "glass": "Kính tối gọn, icon trắng"}

const MAIN: Array = [["nav:shop", "shop", "SHOP"], ["nav:friends", "friend", "BẠN BÈ"], ["nav:rank", "rank", "QUÂN HÀM"], 
	["nav:crystal", "crystal", "TINH THỂ"], ["nav:tank", "tank", "TANK"], ["nav:talent", "talent", "KỸ THUẬT"], ["nav:support", "helper", "TRỢ THỦ"], 
	["nav:bag", "bag", "TÚI"]]

const ROUND: Array = [["social", "community"], ["col:quest", "mission"], ["settings", "gear"], ["back", "back"]]

const PREVIEW_IDS: Array = ["nav:shop", "nav:tank", "nav:bag", "social", "col:quest", "settings", "back"]
const STRIP: float = 58.0
const PREVIEW_W: float = 560.0

const A_BLUE: Array = [Color("63ccff"), Color("1268c9"), Color("b5ecff"), Color("0b3470")]
const A_ORANGE: Array = [Color("ffd257"), Color("ee6a0c"), Color("fff0b8"), Color("7a2c00")]
const A_STRIP: Array = [Color("16457f"), Color("06183a"), Color("62d8ff")]
const B_GOLD: Color = Color("f2c76b")
const B_ORANGE: Color = Color("ff9d2e")
const B_DARK: Color = Color(0.02, 0.04, 0.09)
const RED: Array = [Color("ff5a4a"), Color("d01c1c")]
const A_GREY: Array = [Color("a4afbd"), Color("56616f"), Color("cfd6df"), Color("2c333d")]


const ART_DIR: String = "res://assets/ui/bbar1/bbar1_"
const ART: Dictionary = {"shop": "shop", "friend": "friend", "rank": "quanham", "crystal": "tinhthe", "tank": "tank", "helper": "trothu", 
	"bag": "box", "gear": "setting", "back": "back", "plus": "add", "expand": "zoom", "send": "send", "reddot": "reddot", "strip": "bar_bg", 
	"community": "mail", "mission": "gift"}
const ART_PILL: float = 164.0 / 75.0
const ART_CAP: float = 64.0
const ART_TOP: float = 8.0
static var _art: Dictionary = {}
const ART_EQ: float = (64.0 / 68.0) * (75.0 / 67.0)
const TRAY_LIGHT: bool = true
static var _pics: bool = true
static var _kt_font: FontVariation = null
const POP_LEASE_MS: int = 120


const SVG: Dictionary = {
	"shop": "<path d=\"M1.8 3.8h3.1l2.5 10.4a1.6 1.6 0 0 0 1.6 1.2h8.7a1.6 1.6 0 0 0 1.5-1.1l2.4-7H6\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.3\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path d=\"M7.2 8.6h13l-1.9 5.2H8.4z\" fill=\"{c}\"/><circle cx=\"9.6\" cy=\"19.6\" r=\"1.9\" fill=\"{c}\"/><circle cx=\"17.2\" cy=\"19.6\" r=\"1.9\" fill=\"{c}\"/>", 
	"friend": "<circle cx=\"16.6\" cy=\"8.4\" r=\"3\" fill=\"{c}\" opacity=\".72\"/><path d=\"M15.4 13.4c.4-.1.9-.1 1.3-.1 3.2 0 5.4 2.3 5.4 6.2h-4.6c0-2.6-.7-4.6-2.1-6.1z\" fill=\"{c}\" opacity=\".72\"/><circle cx=\"9\" cy=\"7.6\" r=\"3.8\" fill=\"{c}\"/><path d=\"M2.2 20.2c0-4.3 3-7 6.8-7s6.8 2.7 6.8 7z\" fill=\"{c}\"/>", 
	"rank": "<path d=\"M12 1.4l1.6 3.3 3.6.5-2.6 2.5.6 3.6L12 9.6l-3.2 1.7.6-3.6-2.6-2.5 3.6-.5z\" fill=\"{c}\"/><path d=\"M3.5 12l8.5 4 8.5-4v2.6l-8.5 4-8.5-4z\" fill=\"{c}\"/><path d=\"M3.5 16.6l8.5 4 8.5-4v2.6l-8.5 4-8.5-4z\" fill=\"{c}\" opacity=\".8\"/>", 
	"crystal": "<path d=\"M6.8 2.8h10.4l4.3 6.2L12 21.8 2.5 9z\" fill=\"{c}\"/><path d=\"M2.5 9h19M9.4 2.8L7.6 9 12 21.8 16.4 9l-1.8-6.2\" fill=\"none\" stroke=\"{d}\" stroke-width=\"1.2\" stroke-linejoin=\"round\" opacity=\".6\"/>", 
	"talent": "<path d=\"M12 8.2v3.4M5.6 15.6v-2.3a1.7 1.7 0 0 1 1.7-1.7h9.4a1.7 1.7 0 0 1 1.7 1.7v2.3M12 11.6v4\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path d=\"M12 1.2l3.7 2.1v4.2L12 9.6 8.3 7.5V3.3z\" fill=\"{c}\"/><circle cx=\"12\" cy=\"5.4\" r=\"1.5\" fill=\"{d}\" opacity=\".6\"/><circle cx=\"5.6\" cy=\"18.8\" r=\"3\" fill=\"{c}\"/><circle cx=\"12\" cy=\"18.8\" r=\"3\" fill=\"{c}\"/><circle cx=\"18.4\" cy=\"18.8\" r=\"3\" fill=\"{c}\"/><circle cx=\"12\" cy=\"18.8\" r=\"1.2\" fill=\"{d}\" opacity=\".55\"/>", 
	"tank": "<rect x=\"1.6\" y=\"13.6\" width=\"20.8\" height=\"6.6\" rx=\"3.3\" fill=\"{c}\"/><path d=\"M4.6 13.6l1.8-4.2h10.4l1.8 4.2z\" fill=\"{c}\"/><rect x=\"8.4\" y=\"6.4\" width=\"7.4\" height=\"4.4\" rx=\"1.4\" fill=\"{c}\"/><rect x=\"15\" y=\"7.4\" width=\"8\" height=\"2.2\" rx=\"1.1\" fill=\"{c}\"/><g fill=\"{d}\" opacity=\".55\"><circle cx=\"5.6\" cy=\"16.9\" r=\"1.4\"/><circle cx=\"9.8\" cy=\"16.9\" r=\"1.4\"/><circle cx=\"14.2\" cy=\"16.9\" r=\"1.4\"/><circle cx=\"18.4\" cy=\"16.9\" r=\"1.4\"/></g>", 
	"helper": "<rect x=\"11.2\" y=\"2.4\" width=\"1.6\" height=\"3\" fill=\"{c}\"/><circle cx=\"12\" cy=\"2.2\" r=\"1.5\" fill=\"{c}\"/><rect x=\"4.4\" y=\"5\" width=\"15.2\" height=\"11\" rx=\"4.2\" fill=\"{c}\"/><circle cx=\"9.3\" cy=\"10.5\" r=\"1.9\" fill=\"{d}\"/><circle cx=\"14.7\" cy=\"10.5\" r=\"1.9\" fill=\"{d}\"/><rect x=\"1.8\" y=\"8.4\" width=\"2.1\" height=\"4.6\" rx=\"1\" fill=\"{c}\"/><rect x=\"20.1\" y=\"8.4\" width=\"2.1\" height=\"4.6\" rx=\"1\" fill=\"{c}\"/><path d=\"M7.2 17.4h9.6l1.6 4.6H5.6z\" fill=\"{c}\"/>", 
	"bag": "<path d=\"M8.8 5.6V4.4a3.2 3.2 0 0 1 6.4 0v1.2\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.1\"/><rect x=\"3.8\" y=\"5.2\" width=\"16.4\" height=\"17\" rx=\"4.2\" fill=\"{c}\"/><rect x=\"7.4\" y=\"13\" width=\"9.2\" height=\"5.8\" rx=\"1.6\" fill=\"{d}\" opacity=\".45\"/><rect x=\"10.9\" y=\"11.8\" width=\"2.2\" height=\"2.8\" rx=\".7\" fill=\"{c}\"/>", 
	"community": "<path d=\"M3.2 3.6h11.6a2.2 2.2 0 0 1 2.2 2.2v6.2a2.2 2.2 0 0 1-2.2 2.2H9.2l-4.1 3.6V14.2H3.2A2.2 2.2 0 0 1 1 12V5.8a2.2 2.2 0 0 1 2.2-2.2z\" fill=\"{c}\"/><path d=\"M19 8.2h1.8A2.2 2.2 0 0 1 23 10.4v5.6a2.2 2.2 0 0 1-2.2 2.2H20v3.2l-3.6-3.2h-5a2.2 2.2 0 0 1-2.2-2.2v-.4h6.4A3.4 3.4 0 0 0 19 12.2z\" fill=\"{c}\" opacity=\".75\"/>", 
	"mission": "<rect x=\"4.6\" y=\"2.6\" width=\"14.8\" height=\"18.8\" rx=\"2.8\" fill=\"{c}\"/><rect x=\"10.7\" y=\"6.2\" width=\"2.6\" height=\"7.8\" rx=\"1.3\" fill=\"{d}\"/><circle cx=\"12\" cy=\"17.3\" r=\"1.5\" fill=\"{d}\"/>", 
	"gear": "<g fill=\"{c}\"><circle cx=\"12\" cy=\"12\" r=\"7.2\"/><rect x=\"10.2\" y=\"1.2\" width=\"3.6\" height=\"5\" rx=\"1\"/><rect x=\"10.2\" y=\"17.8\" width=\"3.6\" height=\"5\" rx=\"1\"/><rect x=\"1.2\" y=\"10.2\" width=\"5\" height=\"3.6\" rx=\"1\"/><rect x=\"17.8\" y=\"10.2\" width=\"5\" height=\"3.6\" rx=\"1\"/><rect x=\"10.2\" y=\"1.2\" width=\"3.6\" height=\"5\" rx=\"1\" transform=\"rotate(45 12 12)\"/><rect x=\"10.2\" y=\"17.8\" width=\"3.6\" height=\"5\" rx=\"1\" transform=\"rotate(45 12 12)\"/><rect x=\"1.2\" y=\"10.2\" width=\"5\" height=\"3.6\" rx=\"1\" transform=\"rotate(45 12 12)\"/><rect x=\"17.8\" y=\"10.2\" width=\"5\" height=\"3.6\" rx=\"1\" transform=\"rotate(45 12 12)\"/></g><circle cx=\"12\" cy=\"12\" r=\"3.1\" fill=\"{d}\"/>", 
	"back": "<path d=\"M8.6 4.6L3.4 10l5.2 5.4\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.7\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/><path d=\"M4.4 10h9.4a5.6 5.6 0 0 1 0 11.2h-3.4\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.7\" stroke-linecap=\"round\"/>", 
	"plus": "<path d=\"M12 4.5v15M4.5 12h15\" stroke=\"{c}\" stroke-width=\"3\" stroke-linecap=\"round\"/>", 
	"expand": "<path d=\"M14 3.5h6.5V10M10 20.5H3.5V14M20.5 3.5l-6.8 6.8M3.5 20.5l6.8-6.8\" fill=\"none\" stroke=\"{c}\" stroke-width=\"2.4\" stroke-linecap=\"round\" stroke-linejoin=\"round\"/>", 
	"caret": "<path d=\"M5 8.5h14L12 16.5z\" fill=\"{c}\"/>", 
}

static var _cache: Dictionary = {}


static var _live: Dictionary = {}
static var _pop_until: int = 0


static func current() -> String:
	var style: String = str(Settings.value("lobby_bar"))
	return style if STYLES.has(style) else STYLES[0]

static func valid(style: Variant) -> bool:
	return style is String and STYLES.has(style)

static var _talent_has: int = -1



static func talent_script_ok() -> bool:
	if _talent_has < 0:
		_talent_has = 1 if ResourceLoader.exists("res://ui/talent.gd") else 0
	return _talent_has == 1


static func talent_block(client: Variant) -> String:
	if client == null or not talent_script_ok():
		return "Kỹ Thuật chưa sẵn sàng."
	if not client.talent_open():
		return "Kỹ Thuật chưa mở cho nhân vật này."
	if talent_tank(client).is_empty():
		return "Chưa có tank — vào TANK chọn xe trước đã."
	return ""


static func hidden_ids(client: Variant) -> Array:
	return ["nav:talent"] if client != null and not client.talent_open() else []


static func talent_tank(client: Variant) -> String:
	if client == null:
		return ""
	return str((client.current_tank() as Dictionary).get("m_tankUuid", ""))


static func art(name: String) -> Texture2D:
	if not _pics or not ART.has(name):
		return null
	if not _art.has(name):
		var path: String = ART_DIR + str(ART[name]) + ".png"
		var tex: Texture2D = load(path) as Texture2D if ResourceLoader.exists(path) else null
		if tex != null:
			var soft: CanvasTexture = CanvasTexture.new()
			soft.diffuse_texture = tex
			soft.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
			tex = soft
		_art[name] = tex
	return _art[name]


static func arted(style: String, name: String) -> bool:
	return style != "glass" and art(name) != null





static func art_button(ci: CanvasItem, name: String, r: Rect2, f: float, state: int = 0, dead: bool = false) -> bool:
	var tex: Texture2D = art(name)
	if tex == null or r.size.x < 1.0 or r.size.y < 1.0:
		return false
	var ts: Vector2 = tex.get_size()
	var side: Vector2 = ts * minf(r.size.x / ts.x, r.size.y / ts.y)
	if state == 2:
		side *= 0.96
	side = side.round()
	var nudge: float = 0.0 if dead else maxf(1.0, roundf(1.5 * f))
	var box: Rect2 = Rect2((r.get_center() - side / 2.0).round() + Vector2(0, - nudge if state == 1 else (nudge if state == 2 else 0.0)), side)
	var drop: float = 0.5 * f if state == 2 else (maxf(2.0, 2.5 * f) if state == 1 else maxf(1.0, 1.5 * f))
	var shade: float = 0.2 if state == 2 else (0.42 if state == 1 else 0.34)
	ci.draw_texture_rect(tex, Rect2(box.position + Vector2(0, drop), box.size), false, Color(0.0, 0.06, 0.18, shade))
	var tone: Color = Color.WHITE
	if dead:
		tone = Color(0.6, 0.62, 0.66, 0.72)
	elif state == 1:
		tone = Color(1.1, 1.1, 1.1)
		ci.draw_texture_rect(tex, box.grow(maxf(1.5, 1.5 * f)), false, Color(1.5, 1.5, 1.5, 0.6))
	elif state == 2:
		tone = Color(0.84, 0.84, 0.84)
	ci.draw_texture_rect(tex, box, false, tone)
	return true



static func _strip_art(ci: CanvasItem, tex: Texture2D, r: Rect2, high: float) -> void :
	r = Rect2(r.position, Vector2(ceilf(r.end.x), ceilf(r.end.y)) - r.position)
	var ts: Vector2 = tex.get_size()
	var k: float = high / ts.y
	var cap: float = minf(roundf(ART_CAP * k), floorf(r.size.x / 2.0))
	var src: float = cap / k
	var rows: Array = [[r.position.y, minf(high, r.size.y), 0.0, ts.y]]
	if r.size.y > high + 0.5:
		rows.append([r.position.y + high, r.size.y - high, ts.y - 1.0, 1.0])
	for row: Array in rows:
		var y: float = row[0]
		var h: float = row[1]
		var sy: float = row[2]
		var sh: float = row[3]
		ci.draw_texture_rect_region(tex, Rect2(r.position.x, y, cap, h), Rect2(0, sy, src, sh))
		ci.draw_texture_rect_region(tex, Rect2(r.position.x + cap, y, r.size.x - 2.0 * cap, h), Rect2(src, sy, ts.x - 2.0 * src, sh))
		ci.draw_texture_rect_region(tex, Rect2(r.end.x - cap, y, cap, h), Rect2(ts.x - src, sy, src, sh))



static func mid(style: String, area: Rect2) -> float:
	var cy: float = area.get_center().y
	var bg: Texture2D = art("strip") if style != "glass" else null
	if bg != null and absf(area.size.y - STRIP) < 0.5:
		cy += STRIP * ART_TOP / bg.get_size().y / 2.0
	return cy



static func _art_pill(ci: CanvasItem, f: float, r: Rect2, name: String, label: String, state: int, dead: bool) -> void :
	var side: Vector2 = Vector2(ART_PILL, 1.0) * minf(r.size.x / ART_PILL, r.size.y)
	side.x = minf(r.size.x, side.x * 1.12)
	if state == 2:
		side *= 0.94
	side = side.round()
	var box: Rect2 = Rect2((r.get_center() - side / 2.0 + Vector2(0, f if state == 2 else 0.0)).round(), side)
	var k: float = box.size.y / 75.0
	var body: Rect2 = Rect2(box.position + Vector2(4.0, 3.0) * k, box.size - Vector2(9.0, 8.0) * k)
	var shade: Color = Color(0.0, 0.06, 0.18, 0.2 if state == 2 else 0.34)
	grad(ci, Rect2(body.position + Vector2(0, 0.5 * f if state == 2 else maxf(1.0, 1.5 * f)), body.size), body.size.y / 2.0, shade, shade)
	var rim: Array = [Color8(230, 250, 254), Color8(208, 226, 239)]
	var tone: Array = [Color8(110, 198, 221), Color8(22, 112, 168)]
	var ink: Color = Color8(16, 84, 140)
	if dead:
		rim = [Color8(238, 244, 248), Color8(214, 222, 230)]
		tone = [Color8(196, 210, 222), Color8(140, 160, 180)]
		ink = Color8(92, 112, 134)
	elif state == 1:
		tone = [tone[0].lightened(0.14), tone[1].lightened(0.14)]
	elif state == 2:
		tone = [tone[0].darkened(0.14), tone[1].darkened(0.14)]
	grad(ci, body, body.size.y / 2.0, rim[0], rim[1])
	var core: Rect2 = body.grow( - maxf(1.0, roundf(4.0 * k)))
	grad(ci, core, core.size.y / 2.0, tone[0], tone[1])
	gloss(ci, core, core.size.y / 2.0, f, 0.3 if state != 2 else 0.14, 0.04)
	var face: Color = Color(1, 1, 1, 0.95) if dead else Color.WHITE


	var font: Font = _pill_font()
	var line: int = maxi(2, roundi(4.0 * k))
	var size: int = maxi(6, roundi(18.0 * k / 0.74))
	var isz: float = roundf(25.0 * k)
	var gap: float = roundf(3.0 * k)
	var room: float = core.size.x - core.size.y * 0.3 - line
	var tw: float = _tw(font, label, size)
	while isz > roundf(18.0 * k) and isz + gap + tw > room:
		isz -= 1.0
	while size > 6 and isz + gap + tw > room:
		size -= 1
		tw = _tw(font, label, size)
	var x: float = roundf(core.get_center().x - (isz + gap + tw) / 2.0)
	icon(ci, name, Vector2(x + isz / 2.0, core.get_center().y), isz, face, ink, Color(ink, 0.6))
	text(ci, font, label, size, Vector2(x + isz + gap, roundf(box.get_center().y + size * 0.37)), face, ink, line)


static func _pill_font() -> Font:
	if _kt_font == null:
		_kt_font = FontVariation.new()
		_kt_font.base_font = XBOLD
		_kt_font.variation_embolden = 1.2
		_kt_font.spacing_glyph = -1
		_kt_font.variation_transform = Transform2D(Vector2(0.84, 0.0), Vector2(0.0, 1.0), Vector2.ZERO)
	return _kt_font






static func layout(style: String, area: Rect2, ids: Array = [], gone: Array = []) -> Dictionary:
	var main: Array = MAIN.filter( func(row: Array) -> bool: return (ids.is_empty() or ids.has(row[0])) and not gone.has(row[0]))
	var round: Array = ROUND.filter( func(row: Array) -> bool: return ids.is_empty() or ids.has(row[0]))
	var cy: float = mid(style, area)
	var glass: bool = style == "glass"
	var side: float = 34.0 if glass else 38.0
	var step: float = 44.0 if glass else 46.0
	var pics: bool = arted(style, "shop")
	if pics:
		main = main.filter( func(row: Array) -> bool: return row[0] != "nav:talent")
	if pics:
		var need: float = maxf(1.0, main.size() * ART_EQ * ART_PILL + round.size())
		var fit: float = (area.size.x - 18.0 - 4.0 * maxf(0.0, main.size() - 1.0) - 8.0 * maxf(0.0, round.size() - 1.0)) / need
		side = clampf(floorf(fit * 2.0) / 2.0, 24.0, minf(36.0, (area.size.y - 6.0) / ART_EQ))
		step = side + 8.0
	var group: float = side + step * maxf(0.0, round.size() - 1.0) if not round.is_empty() else 0.0
	var rx: float = area.end.x - group
	var items: Array = []
	for i in range(round.size()):
		var c: Vector2 = Vector2(rx + side / 2.0 + step * i, cy)
		items.append([str(round[i][0]), str(round[i][1]), "", Rect2(c - Vector2(side, side) / 2.0, Vector2(side, side)), "round"])
	var n: float = maxf(1.0, main.size())
	var lead: float = 26.0 if glass else 18.0
	var room: float = maxf(0.0, rx - lead - area.position.x)
	var out: Dictionary = {"split": rx - (13.0 if glass else 9.0), "stack": false, "font": 11, "bare": false}
	var rows: Array = []
	if glass:
		var wide: float = minf(104.0, room / n)
		var x0: float = rx - lead - wide * main.size()
		var font: int = 11
		while font > 8 and main.any( func(row: Array) -> bool: return _tw(SEMI, str(row[2]), font) > wide - 6.0):
			font -= 1
		out["font"] = font
		out["bare"] = main.any( func(row: Array) -> bool: return _tw(SEMI, str(row[2]), font) > wide - 4.0)
		for i in range(main.size()):
			rows.append([str(main[i][0]), str(main[i][1]), str(main[i][2]), Rect2(x0 + wide * i, cy - 22.0, wide, 44.0), "main"])
	else:
		var gap: float = 4.0 if pics else 6.0
		var high: float = side * ART_EQ if pics else minf(40.0, area.size.y - 6.0)

		var plain: Array = main.filter( func(row: Array) -> bool: return not arted(style, str(row[1])))
		var wide: float = minf(high * ART_PILL if pics else 118.0, (room - gap * (n - 1.0)) / n)
		var extra: float = 0.0
		if pics and not plain.is_empty():
			extra = clampf((room - wide * n - gap * (n - 1.0)) / plain.size(), 0.0, wide * 0.12)
		var x0: float = rx - lead - (wide * main.size() + gap * (main.size() - 1) + extra * plain.size())
		var font: int = 14
		while font > 11 and plain.any( func(row: Array) -> bool: return 22.0 + 6.0 + _tw(XBOLD, str(row[2]), font) + 14.0 > wide):
			font -= 1
		if plain.any( func(row: Array) -> bool: return 22.0 + 6.0 + _tw(XBOLD, str(row[2]), font) + 14.0 > wide):
			out["stack"] = true
			font = 11
			while font > 8 and plain.any( func(row: Array) -> bool: return _tw(XBOLD, str(row[2]), font) + 6.0 > wide):
				font -= 1
			out["bare"] = plain.any( func(row: Array) -> bool: return _tw(XBOLD, str(row[2]), font) + 4.0 > wide)
		out["font"] = font
		var x: float = x0
		for i in range(main.size()):
			var w: float = wide + (extra if plain.has(main[i]) else 0.0)
			rows.append([str(main[i][0]), str(main[i][1]), str(main[i][2]), Rect2(x, cy - high / 2.0, w, high), "main"])
			x += w + gap
	out["items"] = rows + items
	return out

static func _tw(font: Font, text: String, size: int) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x





static func strip(ci: CanvasItem, style: String, f: float, wide: float, high: float, o: Vector2 = Vector2.ZERO, lift: float = 0.0) -> void :
	var tall: float = STRIP + maxf(0.0, lift)
	if style == "glass":
		var top: float = high - tall
		_box(ci, Rect2(o + Vector2(0, (top - 40.0) * f), Vector2(wide, 40.0 + tall) * f), Color(B_DARK, 0.0), Color(B_DARK, 0.86))
		var y: float = o.y + (top + 0.5) * f
		ci.draw_polyline_colors(PackedVector2Array([Vector2(o.x, y), Vector2(o.x + wide * f / 2.0, y), Vector2(o.x + wide * f, y)]), 
			PackedColorArray([Color(B_GOLD, 0.0), Color(B_GOLD, 0.75), Color(B_GOLD, 0.0)]), maxf(1.0, f), true)
		return
	var top: float = high - tall
	var bg: Texture2D = art("strip")
	if bg != null:
		_strip_art(ci, bg, Rect2(o + Vector2(0, top * f), Vector2(wide, tall) * f), STRIP * f)
		return
	_box(ci, Rect2(o + Vector2(0, (top - 6.0) * f), Vector2(wide, 6.0) * f), Color(0, 0, 0, 0), Color(0, 0, 0, 0.35))
	_box(ci, Rect2(o + Vector2(0, top * f), Vector2(wide, tall) * f), A_STRIP[0], A_STRIP[1])
	ci.draw_line(o + Vector2(0, (top + 0.5) * f), o + Vector2(wide, top + 0.5) * f, A_STRIP[2], maxf(1.0, 1.2 * f))
	ci.draw_line(o + Vector2(0, (top + 2.0) * f), o + Vector2(wide, top + 2.0) * f, Color(1, 1, 1, 0.1), maxf(1.0, f))


static func panel(ci: CanvasItem, style: String, f: float, area: Rect2, o: Vector2 = Vector2.ZERO) -> void :
	var r: Rect2 = Rect2(o + area.position * f, area.size * f)
	if style == "glass":
		grad(ci, r, 12.0 * f, Color(B_DARK.lightened(0.04), 0.66), Color(B_DARK, 0.9), Color(1, 1, 1, 0.16), maxf(1.0, f))
		var y: float = r.position.y + 1.5 * f
		ci.draw_polyline_colors(PackedVector2Array([Vector2(r.position.x + 12.0 * f, y), Vector2(r.get_center().x, y), Vector2(r.end.x - 12.0 * f, y)]), 
			PackedColorArray([Color(B_GOLD, 0.0), Color(B_GOLD, 0.7), Color(B_GOLD, 0.0)]), maxf(1.0, f), true)
		return
	grad(ci, Rect2(r.position + Vector2(0, 2.0 * f), r.size), 10.0 * f, Color(0, 0, 0, 0.3), Color(0, 0, 0, 0.3))
	grad(ci, r, 10.0 * f, Color(A_STRIP[0], 0.95), Color(A_STRIP[1], 0.97), Color(A_STRIP[2], 0.85), maxf(1.0, 1.2 * f))
	ci.draw_line(r.position + Vector2(10.0, 2.0) * f, Vector2(r.end.x - 10.0 * f, r.position.y + 2.0 * f), Color(1, 1, 1, 0.12), maxf(1.0, f))






static func menu(ci: CanvasItem, style: String, f: float, area: Rect2, hover: String, press: String, badges: Dictionary = {}, 
		ids: Array = [], o: Vector2 = Vector2.ZERO, off: Array = [], gone: Array = []) -> Array:
	var keep: bool = _pics
	_pics = not ci.has_method("bar_area")
	var lay: Dictionary = layout(style, area, ids, gone)
	var hits: Array = []
	var glass: bool = style == "glass"
	var cy: float = mid(style, area)
	var has_main: bool = (lay["items"] as Array).any( func(item: Array) -> bool: return item[4] == "main")
	var has_round: bool = (lay["items"] as Array).any( func(item: Array) -> bool: return item[4] == "round")
	if has_main and has_round:
		var sx: float = o.x + float(lay["split"]) * f
		var rule: Color = Color(0.36, 0.48, 0.62, 0.45) if arted(style, "strip") else Color(1, 1, 1, 0.16)
		ci.draw_line(Vector2(sx, o.y + (cy - 19.0) * f), Vector2(sx, o.y + (cy + 19.0) * f), rule, maxf(1.0, f))
	var font: int = int(lay["font"])
	var look: Dictionary = {"font": font, "stack": bool(lay["stack"]), "bare": bool(lay["bare"]), "art": _pics}
	var mains: Array = (lay["items"] as Array).filter( func(item: Array) -> bool: return item[4] == "main")
	var bag: Rect2 = Rect2()
	var lent: bool = ids.is_empty() and Time.get_ticks_msec() < _pop_until
	for i in range(mains.size()):
		var item: Array = mains[i]
		var id: String = str(item[0])
		var r: Rect2 = Rect2(o + (item[3] as Rect2).position * f, (item[3] as Rect2).size * f)
		var hot: bool = id == "nav:shop"
		var dead: bool = off.has(id)
		var state: int = 0 if dead else (2 if press == id else (1 if hover == id and press.is_empty() else 0))
		if id == "nav:bag":
			bag = r
		if not (lent and id == "nav:bag"):
			item_face(ci, style, f, r, str(item[1]), str(item[2]), look, hot, state, dead)
		if glass:
			if i < mains.size() - 1:
				ci.draw_line(Vector2(r.end.x, r.position.y + 6.0 * f), Vector2(r.end.x, r.end.y - 6.0 * f), Color(1, 1, 1, 0.08), maxf(1.0, f))
			if badges.has(id):
				badge(ci, Vector2(r.get_center().x + 15.0 * f, r.position.y + 1.0 * f), f, str(badges[id]))
		elif badges.has(id):
			badge(ci, Vector2(r.end.x - 6.0 * f, r.position.y + 3.0 * f), f, str(badges[id]))
		hits.append([id, r])
	for item: Array in lay["items"]:
		if item[4] != "round":
			continue
		var id: String = str(item[0])
		var r: Rect2 = Rect2(o + (item[3] as Rect2).position * f, (item[3] as Rect2).size * f)
		var state: int = 2 if press == id else (1 if hover == id and press.is_empty() else 0)
		var c: Vector2 = r.get_center()
		if glass:
			pill(ci, r, r.size.y / 2.0, f, state)
			icon(ci, str(item[1]), c, 18.0 * f, Color(1, 1, 1, 0.92), Color(0.08, 0.1, 0.18))
			if badges.has(id):
				badge(ci, c + Vector2(13, -15) * f, f, str(badges[id]))
		else:
			if not art_button(ci, str(item[1]), r, f, state):
				key(ci, r, r.size.y / 2.0, f, false, state)
				icon(ci, str(item[1]), c, 21.0 * f, Color.WHITE, A_BLUE[1], Color(A_BLUE[3], 0.85))
			if badges.has(id):
				badge(ci, c + Vector2(14, -16) * f, f, str(badges[id]))
		hits.append([id, r])
	if ids.is_empty():
		_live[ci.get_instance_id()] = {"ref": weakref(ci), "hits": hits.duplicate(), "frame": Engine.get_process_frames(), "style": style, 
			"f": f, "bag": bag, "look": look}
	_pics = keep
	return hits


static func item_face(ci: CanvasItem, style: String, f: float, r: Rect2, name: String, label: String, look: Dictionary, hot: bool, state: int, 
		dead: bool = false) -> void :
	if style == "glass":
		_glass_item(ci, f, r, name, label, int(look.get("font", 11)), hot, state, bool(look.get("bare", false)), dead)
	elif not art_button(ci, name, r, f, state, dead):
		if art("shop") != null:
			_art_pill(ci, f, r, name, label, state, dead)
		else:
			_bright_item(ci, f, r, name, label, int(look.get("font", 11)), bool(look.get("stack", false)), hot, state, bool(look.get("bare", false)), dead)



static func live(viewer: CanvasItem = null) -> Array:
	var out: Array = []
	var now: int = Engine.get_process_frames()
	for key: Variant in _live.keys():
		var row: Dictionary = _live[key]
		var owner: Variant = (row["ref"] as WeakRef).get_ref()
		if owner == null or not is_instance_valid(owner) or not (owner is CanvasItem):
			_live.erase(key)
			continue
		if not (owner as CanvasItem).is_visible_in_tree() or now - int(row["frame"]) > 10:
			continue
		var into: Transform2D = (owner as CanvasItem).get_global_transform()
		if viewer != null:
			into = viewer.get_global_transform().affine_inverse() * into
		var hits: Array = []
		for hit: Array in row["hits"]:
			hits.append([hit[0], into * (hit[1] as Rect2)])
		var bag: Rect2 = row["bag"]
		out.append({"hits": hits, "bag": into * bag if bag.has_area() else Rect2(), "style": row["style"], "f": float(row["f"]) * into.get_scale().x, 
			"look": row["look"], "frame": int(row["frame"])})
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a["frame"]) > int(b["frame"]))
	return out


static func pop_lease() -> void :
	_pop_until = Time.get_ticks_msec() + POP_LEASE_MS



static func bag_pop(ci: CanvasItem, bar: Dictionary, lift: float, grow: float, glow: float) -> void :
	var base: Rect2 = bar.get("bag", Rect2())
	if not base.has_area():
		return
	var style: String = str(bar.get("style", "bright"))
	var f: float = float(bar.get("f", 1.0))
	var r: Rect2 = Rect2(base.get_center() - base.size * grow / 2.0 - Vector2(0, lift), base.size * grow)
	var glass: bool = style == "glass"
	var tone: Color = B_GOLD if glass else A_BLUE[2]
	if glow > 0.0:
		for i in range(3):
			var halo: Rect2 = r.grow((3.0 + 4.0 * i) * f * (0.6 + 0.4 * glow))
			grad(ci, halo, (12.0 + 4.0 * i) * f, Color(tone, 0.2 * glow / (i + 1.0)), Color(tone, 0.08 * glow / (i + 1.0)))
	var keep: bool = _pics
	_pics = bool((bar.get("look", {}) as Dictionary).get("art", true))
	item_face(ci, style, f, r, "bag", "TÚI", bar.get("look", {}), false, 1 if glow > 0.0 else 0)
	_pics = keep
	if glow > 0.0:
		grad(ci, r.grow(1.0 * f), (10.0 if glass else 8.0) * f, Color(1, 1, 1, 0.32 * glow), Color(1, 1, 1, 0.06 * glow), 
			Color(tone, 0.9 * glow), maxf(1.0, 1.6 * f))

static func _bright_item(ci: CanvasItem, f: float, r: Rect2, name: String, label: String, font: int, stack: bool, hot: bool, state: int, 
		bare: bool = false, dead: bool = false) -> void :
	key(ci, r, 8.0 * f, f, hot, state, dead)
	var ink: Color = (A_GREY if dead else (A_ORANGE if hot else A_BLUE))[3]
	var face: Color = Color(1, 1, 1, 0.62) if dead else Color.WHITE
	if bare:
		icon(ci, name, r.get_center(), minf(22.0 * f, r.size.x - 8.0 * f), face, ink, Color(ink, 0.85))
		return
	if stack:
		var tw: float = _tw(XBOLD, label, maxi(4, roundi(font * f)))
		icon(ci, name, Vector2(r.get_center().x, r.position.y + r.size.y * 0.36), 18.0 * f, face, ink, Color(ink, 0.85))
		text(ci, XBOLD, label, maxi(4, roundi(font * f)), Vector2(r.get_center().x - tw / 2.0, r.end.y - 5.0 * f), face, ink, maxi(1, roundi(3.0 * f)))
		return
	var size: int = maxi(4, roundi(font * f))
	var tw: float = _tw(XBOLD, label, size)
	var x: float = r.position.x + (r.size.x - (22.0 * f + 6.0 * f + tw)) / 2.0
	icon(ci, name, Vector2(x + 11.0 * f, r.get_center().y), 22.0 * f, face, ink, Color(ink, 0.85))
	text(ci, XBOLD, label, size, Vector2(x + 28.0 * f, r.get_center().y + size * 0.36), face, ink, maxi(1, roundi(4.0 * f)))

static func _glass_item(ci: CanvasItem, f: float, r: Rect2, name: String, label: String, font: int, hot: bool, state: int, 
		bare: bool = false, dead: bool = false) -> void :
	var cx: float = r.get_center().x
	var top: float = r.position.y
	if state > 0:
		grad(ci, r.grow(-2.0 * f), 10.0 * f, Color(1, 1, 1, 0.12 if state == 1 else 0.05), Color(1, 1, 1, 0.04 if state == 1 else 0.02))
	var dim: float = 0.8 if state == 2 else 1.0
	if bare:
		if hot:
			var spot: Rect2 = Rect2(r.get_center() - Vector2(16, 14) * f, Vector2(32, 28) * f)
			grad(ci, spot, 14.0 * f, Color(B_ORANGE.darkened(1.0 - dim), 0.95), Color("d9530b").darkened(1.0 - dim), Color(1, 0.88, 0.6, 0.9), maxf(1.0, f))
			icon(ci, name, r.get_center(), 20.0 * f, Color.WHITE, Color.BLACK, Color(0.45, 0.15, 0.0, 0.7))
		else:
			icon(ci, name, r.get_center(), minf(24.0 * f, r.size.x - 8.0 * f), Color(dim, dim, dim, 0.36 if dead else 0.94), Color(0.06, 0.09, 0.18), Color(0, 0, 0, 0.6))
		return
	if hot:
		var glow: Rect2 = Rect2(Vector2(cx - 19.0 * f, top - 2.0 * f), Vector2(38, 30) * f)
		var top_c: Color = B_ORANGE.lightened(0.14) if state == 1 else B_ORANGE
		grad(ci, glow, 15.0 * f, Color(top_c.darkened(1.0 - dim), 0.95), Color("d9530b").darkened(1.0 - dim), Color(1, 0.88, 0.6, 0.9), maxf(1.0, f))
		icon(ci, name, Vector2(cx, top + 13.0 * f), 22.0 * f, Color.WHITE, Color.BLACK, Color(0.45, 0.15, 0.0, 0.7))
	else:
		icon(ci, name, Vector2(cx, top + 13.0 * f), 24.0 * f, Color(dim, dim, dim, 0.36 if dead else 0.94), Color(0.06, 0.09, 0.18), Color(0, 0, 0, 0.6))
	var size: int = maxi(4, roundi(font * f))
	var tw: float = _tw(SEMI, label, size)
	text(ci, SEMI, label, size, Vector2(cx - tw / 2.0, top + 42.0 * f), B_GOLD if hot else Color(1, 1, 1, 0.4 if dead else 0.9), Color(0, 0, 0, 0.6), maxi(1, roundi(3.0 * f)))




static func key(ci: CanvasItem, r: Rect2, radius: float, f: float, hot: bool = false, state: int = 0, dead: bool = false) -> void :
	var tone: Array = A_GREY if dead else (A_ORANGE if hot else A_BLUE)
	var top: Color = tone[0]
	var bottom: Color = tone[1]
	if state == 1:
		top = top.lightened(0.16)
		bottom = bottom.lightened(0.16)
	elif state == 2:
		top = top.darkened(0.22)
		bottom = bottom.darkened(0.22)
	grad(ci, Rect2(r.position + Vector2(0, 2.0 * f), r.size), radius, Color(0, 0, 0, 0.35), Color(0, 0, 0, 0.35))
	grad(ci, r, radius, top, bottom, tone[2], maxf(1.0, 1.3 * f))
	gloss(ci, r, radius, f, 0.38 if state != 2 else 0.18, 0.06)


static func pill(ci: CanvasItem, r: Rect2, radius: float, f: float, state: int = 0, strong: bool = false) -> void :
	var a0: float = 0.16 if strong else 0.1
	var a1: float = 0.05 if strong else 0.03
	if state == 1:
		a0 += 0.08
		a1 += 0.04
	elif state == 2:
		a0 *= 0.5
		a1 *= 0.5
	grad(ci, r, radius, Color(1, 1, 1, a0), Color(1, 1, 1, a1), Color(1, 1, 1, 0.26), maxf(1.0, f))


static func badge(ci: CanvasItem, at: Vector2, f: float, label: String) -> void :
	var red: Texture2D = art("reddot")
	if label.is_empty():
		if red != null:
			ci.draw_texture_rect(red, Rect2((at - Vector2(7, 7) * f).round(), (Vector2(14, 14) * f).round()), false)
			return
		var dot: Rect2 = Rect2(at - Vector2(5.5, 5.5) * f, Vector2(11, 11) * f)
		grad(ci, dot, 5.5 * f, RED[0], RED[1], Color(1, 1, 1, 0.95), maxf(1.0, 1.4 * f))
		return
	var size: int = maxi(4, roundi(10.0 * f))
	var tw: float = _tw(XBOLD, label, size)
	if red != null and tw + 6.0 * f <= 17.0 * f:
		ci.draw_texture_rect(red, Rect2((at - Vector2(8.5, 8.5) * f).round(), (Vector2(17, 17) * f).round()), false)
		text(ci, XBOLD, label, size, Vector2(at.x - tw / 2.0, at.y + 3.6 * f), Color.WHITE, Color(0.45, 0.0, 0.0, 0.8), maxi(1, roundi(2.0 * f)))
		return
	var wide: float = maxf(16.0 * f, tw + 9.0 * f)
	var r: Rect2 = Rect2(at - Vector2(wide / 2.0, 8.0 * f), Vector2(wide, 16.0 * f))
	grad(ci, r, 8.0 * f, RED[0], RED[1], Color(1, 1, 1, 0.95), maxf(1.0, 1.4 * f))
	text(ci, XBOLD, label, size, Vector2(at.x - tw / 2.0, at.y + 3.6 * f), Color.WHITE)


static func preview(ci: CanvasItem, rect: Rect2, style: String) -> void :
	var f: float = rect.size.x / PREVIEW_W
	var high: float = rect.size.y / f
	_box(ci, rect, Color("5fb8ef"), Color("1d5f9e"))
	var sea: Rect2 = Rect2(rect.position + Vector2(0, rect.size.y * 0.55), Vector2(rect.size.x, rect.size.y * 0.45))
	_box(ci, sea, Color("2c86c9"), Color("123f73"))
	strip(ci, style, f, PREVIEW_W, high, rect.position)
	menu(ci, style, f, Rect2(10, high - STRIP, PREVIEW_W - 18.0, STRIP), "", "", {"nav:tank": "", "col:quest": "2"}, PREVIEW_IDS, rect.position)




static func _box(ci: CanvasItem, r: Rect2, top: Color, bottom: Color) -> void :
	ci.draw_polygon(PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)]), 
		PackedColorArray([top, top, bottom, bottom]))

static func rounded(r: Rect2, radius: float, top_only: bool = false) -> PackedVector2Array:
	var pts: PackedVector2Array = PackedVector2Array()
	radius = minf(radius, minf(r.size.x, r.size.y) * 0.5)
	if radius <= 0.0:
		return PackedVector2Array([r.position, Vector2(r.end.x, r.position.y), r.end, Vector2(r.position.x, r.end.y)])
	var corners: Array = [[r.position + Vector2(r.size.x - radius, radius), -90.0], [r.end - Vector2(radius, radius), 0.0], 
		[Vector2(r.position.x + radius, r.end.y - radius), 90.0], [r.position + Vector2(radius, radius), 180.0]]
	for i in range(4):
		if top_only and (i == 1 or i == 2):
			pts.append(Vector2(r.end.x if i == 1 else r.position.x, r.end.y))
			continue
		var c: Vector2 = corners[i][0]
		for s in range(9):
			var a: float = deg_to_rad(float(corners[i][1]) + s * 90.0 / 8.0)
			var p: Vector2 = c + Vector2(cos(a), sin(a)) * radius

			if pts.is_empty() or pts[pts.size() - 1].distance_squared_to(p) > 0.0001:
				pts.append(p)
	if pts.size() > 2 and pts[0].distance_squared_to(pts[pts.size() - 1]) <= 0.0001:
		pts.remove_at(pts.size() - 1)
	return pts


static func grad(ci: CanvasItem, r: Rect2, radius: float, top: Color, bottom: Color, border: Color = Color(0, 0, 0, 0), width: float = 1.0) -> void :
	if r.size.x < 1.0 or r.size.y < 1.0:
		return
	var pts: PackedVector2Array = rounded(r, radius)
	var colors: PackedColorArray = PackedColorArray()
	for p: Vector2 in pts:
		colors.append(top.lerp(bottom, clampf((p.y - r.position.y) / r.size.y, 0.0, 1.0)))
	ci.draw_polygon(pts, colors)
	if border.a > 0.0:
		var loop: PackedVector2Array = pts.duplicate()
		loop.append(pts[0])
		ci.draw_polyline(loop, border, width, true)

static func gloss(ci: CanvasItem, r: Rect2, radius: float, f: float, a0: float, a1: float) -> void :
	var g: Rect2 = Rect2(r.position + Vector2(1.5, 1.5) * f, Vector2(r.size.x - 3.0 * f, r.size.y * 0.48))
	if g.size.x < 1.0 or g.size.y < 1.0:
		return
	var pts: PackedVector2Array = rounded(g, maxf(0.0, radius - 1.5 * f), true)
	var colors: PackedColorArray = PackedColorArray()
	for p: Vector2 in pts:
		colors.append(Color(1, 1, 1, lerpf(a0, a1, clampf((p.y - g.position.y) / g.size.y, 0.0, 1.0))))
	ci.draw_polygon(pts, colors)

static func text(ci: CanvasItem, font: Font, value: String, size: int, at: Vector2, color: Color, outline: Color = Color(0, 0, 0, 0), thick: int = 0) -> void :
	if thick > 0 and outline.a > 0.0:
		ci.draw_string_outline(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, thick, outline)
	ci.draw_string(font, at, value, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)



static func input_row(ci: CanvasItem, style: String, f: float, box_flash: Rect2, label: String, hint: String, state: int, grow: bool, 
		o: Vector2 = Vector2.ZERO) -> void :
	var glass: bool = style == "glass"
	var box: Rect2 = Rect2(o + box_flash.position * f, box_flash.size * f)
	var chip: Rect2 = Rect2(box.position + Vector2(4, 4) * f, Vector2(80, 26) * f)
	var size: int = maxi(4, roundi(12.0 * f))
	var cap: Rect2 = Rect2(chip.position, chip.size - Vector2(14, 0) * f)
	var tail: Vector2 = Vector2(chip.end.x - 12.0 * f, chip.get_center().y)
	var spot: Rect2 = Rect2(Vector2(box.end.x - 30.0 * f, box.position.y + 4.0 * f), Vector2(26, 26) * f)
	var base: float = box.get_center().y + size * 0.36
	if glass:
		grad(ci, box, 17.0 * f, Color(B_DARK, 0.55), Color(B_DARK, 0.82), Color(1, 1, 1, 0.24), maxf(1.0, f))
		pill(ci, chip, 13.0 * f, f, state, true)
		centred(ci, SEMI, label, size, cap, Color.WHITE)
		icon(ci, "caret", tail, 10.0 * f, Color(1, 1, 1, 0.85))
		if not hint.is_empty():
			text(ci, MEDIUM, hint, size, Vector2(chip.end.x + 10.0 * f, base), Color(1, 1, 1, 0.5))
		if grow:
			pill(ci, spot, 13.0 * f, f, state)
			icon(ci, "expand", spot.get_center(), 14.0 * f, Color(1, 1, 1, 0.85))
	else:
		grad(ci, box, 8.0 * f, Color("031027", 0.92), Color("0a2246", 0.95), Color("3f7fc4"), maxf(1.0, 1.2 * f))
		key(ci, chip, 7.0 * f, f, false, state)
		centred(ci, XBOLD, label, size, cap, Color.WHITE, A_BLUE[3], maxi(1, roundi(3.0 * f)))
		icon(ci, "caret", tail, 11.0 * f, Color.WHITE)
		if not hint.is_empty():
			text(ci, MEDIUM, hint, size, Vector2(chip.end.x + 10.0 * f, base), Color(0.78, 0.86, 1.0, 0.75))
		if grow and (ci.has_method("bar_area") or not art_button(ci, "expand", spot, f, state)):
			key(ci, spot, 7.0 * f, f, false, state)
			icon(ci, "expand", spot.get_center(), 15.0 * f, Color.WHITE, A_BLUE[3], Color(A_BLUE[3], 0.8))


static func centred(ci: CanvasItem, font: Font, value: String, size: int, r: Rect2, color: Color, outline: Color = Color(0, 0, 0, 0), thick: int = 0) -> void :
	var tw: float = _tw(font, value, size)
	text(ci, font, value, size, Vector2(r.get_center().x - tw / 2.0, r.get_center().y + size * 0.36), color, outline, thick)


static func icon(ci: CanvasItem, name: String, center: Vector2, side: float, c: Color, d: Color = Color.BLACK, shadow: Color = Color(0, 0, 0, 0)) -> void :
	if side < 2.0 or not SVG.has(name):
		return
	var r: Rect2 = Rect2(center - Vector2(side, side) / 2.0, Vector2(side, side))
	if shadow.a > 0.0:
		var under: Texture2D = texture(name, side, shadow, shadow)
		if under != null:
			ci.draw_texture_rect(under, Rect2(r.position + Vector2(0, side * 0.055), r.size), false, Color(1, 1, 1, shadow.a))
	var top: Texture2D = texture(name, side, c, d)
	if top != null:
		ci.draw_texture_rect(top, r, false, Color(1, 1, 1, c.a))


static func texture(name: String, side: float, c: Color, d: Color) -> Texture2D:
	var px: int = clampi(roundi(side * 2.0 / 4.0) * 4, 8, 192)
	var tag: String = "%s|%d|%s|%s" % [name, px, c.to_html(false), d.to_html(false)]
	if _cache.has(tag):
		return _cache[tag]
	if not SVG.has(name):
		return null
	if _cache.size() > 240:
		_cache.clear()
	var body: String = str(SVG[name]).replace("{c}", "#" + c.to_html(false)).replace("{d}", "#" + d.to_html(false))
	var image: Image = Image.new()
	var made: Texture2D = null
	if image.load_svg_from_string("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"24\" height=\"24\" viewBox=\"0 0 24 24\">" + body + "</svg>", px / 24.0) == OK and not image.is_empty():
		made = ImageTexture.create_from_image(image)
	_cache[tag] = made
	return made
