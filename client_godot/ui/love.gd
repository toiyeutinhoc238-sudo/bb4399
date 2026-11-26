extends RefCounted
const AppSession = preload("res://net/app_session.gd")
const SafeJson = preload("res://net/safe_json.gd")
const LoveArt = preload("love_art.gd")
const LobbyThemes = preload("lobby_themes.gd")

















const ROOT: String = "/api/love/"
const PAIRS_PATH: String = "/api/couples.json"
const PAIRS_EVERY: float = 60.0
const STATE_OPEN: float = 20.0
const STATE_IDLE: float = 90.0
const STATE_FIRST: float = 600.0
const AGAIN: float = 20.0
const NOTE_LIFE: float = 15.0
const NEED: int = 200
const HEART_PNG: String = "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"
const OFF_TEXT: String = "Tính năng Người Yêu đang tạm đóng."
const WED: String = ROOT + "wed/"
const WED_KINDS: Array = ["wed", "slots", "hall", "ring_buy", "ring_up", "propose", "answer", "refuse", "withdraw", "book", "guests", "unbook", "join", "bless"]
const SILENT: Array = ["pairs", "state", "peek", "wed", "slots", "theme"]
const THEME_AGAIN: float = 30.0
const THEME_SLOW: float = 600.0
const THEME_WAIT: float = 3.0
const WED_RETRY: float = 600.0
const RIM_WHITE: Color = Color(1, 1, 1)
const RIM_GOLD: Color = Color(1.0, 0.82, 0.3)
const NET_TEXT: String = "Người Yêu chỉ có khi chơi trực tuyến."
const WED_OFF_TEXT: String = "Nhẫn & Lễ cưới chưa mở."
const RING_NAMES: Array = ["", "Nhẫn Bạc", "Nhẫn Vàng", "Nhẫn Kim Cương"]

static var pairs: Dictionary = {}
static var pairs_on: bool = false
static var battle_heart: bool = false
static var state: Dictionary = {}
static var gate: int = 0
static var peeks: Dictionary = {}
static var rev: int = 0
static var asks: Array = []
static var fetch: Callable
static var _notes: Array = []
static var _pairs_at: float = -1000.0
static var _state_at: float = -1000.0
static var _failed: float = -1000.0
static var _queue: Array = []
static var _busy: Array = []
static var _http: HTTPRequest = null
static var _client: Object = null
static var _kicked: bool = false
static var _hearts: Dictionary = {}
static var _heart_src: Image = null
static var _gold: bool = false
static var wed: Dictionary = {}
static var wed_gate: int = 0
static var slots_data: Dictionary = {}
static var hall_data: Dictionary = {}
static var _wed_off_at: float = -1000.0
static var theme_acct: int = 0
static var theme_got: bool = false
static var _theme_at: float = -1000.0
static var _theme_wait: float = 0.0
static var _theme_tries: int = 0

static func reset() -> void :
	pairs = {}
	pairs_on = false
	battle_heart = false
	state = {}
	gate = 0
	peeks = {}
	rev = 0
	asks = []
	fetch = Callable()
	_notes = []
	_pairs_at = -1000.0
	_state_at = -1000.0
	_failed = -1000.0
	_queue = []
	_busy = []
	_client = null
	_kicked = false
	_gold = false
	wed = {}
	wed_gate = 0
	slots_data = {}
	hall_data = {}
	_wed_off_at = -1000.0
	theme_acct = 0
	theme_got = false
	_theme_at = -1000.0
	_theme_wait = 0.0
	_theme_tries = 0
	LobbyThemes.cuoi_ok = false

static func _now() -> float:
	return Time.get_ticks_msec() / 1000.0


static func _origin(client: Object) -> Variant:
	var config: Variant = client.get("config") if client != null else null
	if config == null:
		return null
	if (str(config.get("origin")).is_empty() or config.get("local_test_only") == true) and not fetch.is_valid():
		return null
	return str(config.get("origin"))


static func me(client: Object) -> int:
	if client == null:
		return 0
	var oid: int = int(client.get("account_oid")) if client.get("account_oid") != null else 0
	if oid > 0:
		return oid
	return int(client.get("account_id")) if client.get("account_id") != null else 0




static func has(client: Object, acct: int) -> bool:
	_want_pairs(client)
	var hit: bool = pairs_on and acct > 0 and pairs.has(acct)
	_gold = hit and married(acct)
	return hit



static func near(client: Object, acct: int) -> bool:
	if not has(client, acct):
		return false
	var mine: int = me(client)
	var ok: bool = mine > 0 and (acct == mine or partner_of(client, mine) == acct)
	_gold = ok and married(acct)
	return ok


static func married(acct: int) -> bool:
	var row: Variant = pairs.get(acct)
	return row is Array and (row as Array).size() > 2 and int(row[2]) == 2

static func partner_of(client: Object, acct: int) -> int:
	_want_pairs(client)
	var row: Variant = pairs.get(acct)
	return int(row[0]) if row is Array else 0


static func battle_on(client: Object) -> bool:
	_want_pairs(client)
	return pairs_on and battle_heart


static func shown(client: Object) -> bool:
	_want_pairs(client)
	return pairs_on and gate != -1


static func menu_extra(client: Object) -> float:
	return 20.0 if shown(client) else 0.0


static func can_invite(client: Object, acct: int, is_me: bool) -> bool:
	if is_me or not shown(client):
		return false
	var mine: int = me(client)
	if mine > 0 and pairs.has(mine):
		return false
	if not couple().is_empty():
		return false
	return acct <= 0 or not pairs.has(acct)

static func couple() -> Dictionary:
	var c: Variant = state.get("couple")
	return c if c is Dictionary else {}

static func incoming() -> Array:
	var rows: Variant = state.get("incoming")
	return rows if rows is Array else []

static func outgoing() -> Array:
	var rows: Variant = state.get("outgoing")
	return rows if rows is Array else []

static func close_list() -> Array:
	var rows: Variant = state.get("close")
	return rows if rows is Array else []

static func incoming_count() -> int:
	return incoming().size() if gate == 1 else 0

static func need() -> int:
	var rules: Variant = state.get("rules")
	return int(rules.get("loveNeed", NEED)) if rules is Dictionary else NEED

static func rule(key: String, fallback: int) -> int:
	var rules: Variant = state.get("rules")
	return int(rules.get(key, fallback)) if rules is Dictionary else fallback

static func peek_of(acct: int) -> Dictionary:
	var p: Variant = peeks.get(acct)
	return p if p is Dictionary else {}


static func days_text(days: int) -> String:
	return "Bên nhau %d ngày" % maxi(1, days)




static func wed_on() -> bool:
	return gate == 1 and wed_gate == 1 and wed.get("on") == true


static func wcouple() -> Dictionary:
	var c: Variant = wed.get("couple")
	return c if c is Dictionary and wed_on() else {}

static func wrule(key: String, fallback: int) -> int:
	var rules: Variant = wed.get("rules")
	return int(rules.get(key, fallback)) if rules is Dictionary else fallback

static func _wlist(key: String) -> Array:
	var rows: Variant = wed.get(key)
	if not rows is Array or not wed_on():
		return []
	return (rows as Array).filter( func(row: Variant) -> bool: return row is Dictionary)

static func rings() -> Array:
	return _wlist("rings")

static func ring(tier: int) -> Dictionary:
	for r: Dictionary in rings():
		if int(r.get("tier", 0)) == tier:
			return r
	return {}

static func ring_name(tier: int) -> String:
	var r: Dictionary = ring(tier)
	if not r.is_empty():
		return str(r.get("name", ""))
	return str(RING_NAMES[tier]) if tier > 0 and tier < RING_NAMES.size() else ""



const RING_ART: Array = ["", "l/it/loveheart2.webp", "l/it/loveheart3.webp", "l/it/loveheart1.webp"]

const HALL_ART: String = "l/it/valentineDay_2016.webp"
const HALL_ART_CUT: Rect2 = Rect2(0, 15, 180, 105)

static func ring_art(tier: int) -> String:
	return str(RING_ART[tier]) if tier > 0 and tier < RING_ART.size() else ""

static func ring_tex(pack: Variant, tier: int) -> Texture2D:
	if tier <= 0 or tier >= RING_ART.size():
		return null
	var t: Texture2D = LoveArt.tex("ring%d" % tier)
	if t == null and pack != null:
		t = pack.picture(ring_art(tier))
	return t


static func hall_tex() -> Texture2D:
	return LoveArt.tex("hall")


static func bag_n(tier: int) -> int:
	var bag: Variant = wed.get("bag")
	if not bag is Dictionary or not wed_on():
		return 0
	return int(bag.get(str(tier), bag.get(tier, 0)))


static func best_ring() -> int:
	for tier: int in [3, 2, 1]:
		if bag_n(tier) > 0:
			return tier
	return 0

static func propose_in() -> Array:
	return _wlist("proposeIn")

static func propose_out() -> Array:
	return _wlist("proposeOut")

static func invites() -> Array:
	return _wlist("invites")

static func wedding() -> Dictionary:
	var w: Variant = wed.get("wedding")
	return w if w is Dictionary and wed_on() else {}

static func bless_lines() -> Array:
	var rows: Variant = wed.get("bless")
	return rows if rows is Array else []


static func thousands(n: int) -> String:
	var digits: String = str(absi(n))
	var out: String = ""
	while digits.length() > 3:
		out = "." + digits.right(3) + out
		digits = digits.left(digits.length() - 3)
	return ("-" if n < 0 else "") + digits + out

static func price_text(price: int, currency_name: String) -> String:
	return "%s %s" % [thousands(price), currency_name]


static func up_cost(tier: int) -> Array:
	var target: Dictionary = ring(tier)
	if target.is_empty():
		return [0, ""]
	var old: Dictionary = ring(int(wcouple().get("ringTier", 0)))
	var price: int = int(target.get("price", 0))
	if not old.is_empty() and str(old.get("currency", "")) == str(target.get("currency", "")):
		price = maxi(0, price - int(old.get("price", 0)))
	return [price, str(target.get("curName", ""))]


static func vn_time(unix: int) -> String:
	var vn: Dictionary = Time.get_datetime_dict_from_unix_time(unix + 7 * 3600)
	return "%02d:%02d %02d/%02d" % [int(vn.hour), int(vn.minute), int(vn.day), int(vn.month)]


static func clock(seconds: int) -> String:
	seconds = maxi(0, seconds)
	if seconds >= 3600:
		return "%d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]
	return "%d:%02d" % [seconds / 60, seconds % 60]





static func heart(px: int = 14, gold: bool = false, tone: int = 0) -> Texture2D:
	px = clampi(px, 8, 96)
	tone = TONE_HALF if tone == TONE_HALF else posmod(tone, TONE_COUNT)
	var key: int = px + (1000 if gold else 0) + (tone + 2) * 10000
	var hit: Variant = _hearts.get(key)
	if hit is Texture2D:
		return hit
	if _heart_src == null:
		_heart_src = Image.new()
		if _heart_src.load_png_from_buffer(Marshalls.base64_to_raw(HEART_PNG)) != OK:
			_heart_src = null
			return null
		_heart_src.convert(Image.FORMAT_RGBA8)
	var inner: Image = _heart_src.duplicate()
	inner.resize(px - 2, px - 2, Image.INTERPOLATE_LANCZOS)
	_tone_paint(inner, tone)
	var out: Image = Image.create_empty(px, px, false, Image.FORMAT_RGBA8)
	var core: PackedFloat32Array = PackedFloat32Array()
	core.resize(px * px)
	for y in range(px - 2):
		for x in range(px - 2):
			core[(y + 1) * px + x + 1] = inner.get_pixel(x, y).a
	var rim: PackedFloat32Array = _grow(core, px)
	for y in range(px):
		for x in range(px):
			var i: int = y * px + x
			var c: Color = Color(0.05, 0.02, 0.04, rim[(y - 1) * px + x - 1] * 0.6 if x > 0 and y > 0 else 0.0)
			c = c.blend(Color(RIM_GOLD if gold else RIM_WHITE, rim[i]))
			if x >= 1 and y >= 1 and x < px - 1 and y < px - 1:
				c = c.blend(inner.get_pixel(x - 1, y - 1))
			out.set_pixel(x, y, c)
	if tone == TONE_HALF:
		for y in range(px):
			for x in range(px):
				var fade: Color = out.get_pixel(x, y)
				fade.a *= HALF_FADE
				out.set_pixel(x, y, fade)
	var tex: ImageTexture = ImageTexture.create_from_image(out)
	_hearts[key] = tex
	return tex



const TONE_COUNT: int = 5
const TONE_HALF: int = -1
const TONE_HUES: Array = [-1.0, 0.1, 0.78, 0.47, 0.6]
const TONE_LIFT: Array = [1.0, 1.22, 1.08, 1.08, 1.08]
const TONE_INK: Array = [Color(1.0, 0.56, 0.68), Color(1.0, 0.76, 0.42), Color(0.8, 0.64, 1.0), Color(0.5, 0.92, 0.82), Color(0.56, 0.77, 1.0)]
const HALF_INK: Color = Color(1.0, 0.8, 0.86)
const HALF_WHITE: float = 0.55
const HALF_FADE: float = 0.8
const LONE_TEXT: String = "Đã có Người Yêu"




static func tones(client: Object, accts: Array) -> Dictionary:
	_want_pairs(client)
	var out: Dictionary = {}
	if not pairs_on:
		return out
	var seat: Dictionary = {}
	for value: Variant in accts:
		var id: int = int(value)
		if id > 0 and not seat.has(id):
			seat[id] = seat.size()
	var mine: int = me(client)
	var order: Array = []
	for id: int in seat:
		if not pairs.has(id):
			continue
		var mate: int = _mate(id)
		if mate > 0 and mate != id and seat.has(mate) and _mate(mate) == id:
			if int(seat[id]) < int(seat[mate]):
				if mine > 0 and (id == mine or mate == mine):
					order.push_front([id, mate])
				else:
					order.append([id, mate])
		else:
			out[id] = TONE_HALF
	for i in range(order.size()):
		out[order[i][0]] = i % TONE_COUNT
		out[order[i][1]] = i % TONE_COUNT
	return out


static func tone_of(table: Dictionary, acct: int) -> int:
	return int(table.get(acct, 0))


static func tone_ink(tone: int) -> Color:
	return HALF_INK if tone == TONE_HALF else TONE_INK[posmod(tone, TONE_COUNT)]



static func tip(client: Object, acct: int, names: Dictionary) -> String:
	var mate: int = _mate(acct)
	var name: String = str(names.get(mate, "")) if mate > 0 else ""
	if name.is_empty() and acct > 0 and acct == me(client):
		var pair: Dictionary = couple()
		if int(pair.get("partnerId", mate)) == mate:
			name = str(pair.get("partnerName", ""))
	if name.strip_edges().is_empty():
		return LONE_TEXT
	return ("Vợ Chồng: %s" if married(acct) else "Người Yêu: %s") % name.strip_edges()

static func _mate(acct: int) -> int:
	var row: Variant = pairs.get(acct)
	return int(row[0]) if row is Array and not (row as Array).is_empty() else 0


static func _tone_paint(img: Image, tone: int) -> void :
	if tone == 0:
		return
	for y in range(img.get_height()):
		for x in range(img.get_width()):
			var c: Color = img.get_pixel(x, y)
			if c.a <= 0.0:
				continue
			if tone == TONE_HALF:
				img.set_pixel(x, y, Color(lerpf(c.r, 1.0, HALF_WHITE), lerpf(c.g, 1.0, HALF_WHITE), lerpf(c.b, 1.0, HALF_WHITE), c.a))
			else:
				img.set_pixel(x, y, Color.from_hsv(float(TONE_HUES[tone]), c.s, minf(1.0, c.v * float(TONE_LIFT[tone])), c.a))


static func _grow(src: PackedFloat32Array, side: int) -> PackedFloat32Array:
	var out: PackedFloat32Array = src.duplicate()
	for y in range(side):
		for x in range(side):
			var best: float = src[y * side + x]
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var nx: int = x + dx
					var ny: int = y + dy
					if nx >= 0 and ny >= 0 and nx < side and ny < side:
						best = maxf(best, src[ny * side + nx])
			out[y * side + x] = best
	return out




static func draw(canvas: CanvasItem, rect: Rect2, alpha: float = 1.0, extra: float = 1.0, gold: int = -1, tone: int = 0) -> void :
	if canvas == null:
		return
	var k: float = extra
	if canvas.is_inside_tree():
		k *= (canvas.get_viewport().get_final_transform() * canvas.get_global_transform_with_canvas()).get_scale().x
	var tex: Texture2D = heart(int(round(rect.size.x * k)), _gold if gold < 0 else gold == 1, tone)
	if tex != null:
		canvas.draw_texture_rect(tex, rect, false, Color(1, 1, 1, alpha))




const SIDE: float = 14.0
const NAME_GAP: float = 4.0
const ROOM_GAP: float = 6.0
const BATTLE_SIDE: float = SIDE
const BATTLE_NAME_GAP: float = NAME_GAP

static func battle_name_rect(pos: Vector2, name_y: float, text_w: float, vip_w: float, vip_h: float, floor_y: float, text_mid: float = -1.0) -> Rect2:
	var shift: float = - vip_w / 2.0
	var left: float = -100.0 + shift + (floorf((200.0 - text_w) / 2.0) if text_w <= 200.0 else 0.0)
	var right: float = left + text_w
	if vip_w > 0.0:
		right = maxf(right, (text_w - vip_w) / 2.0 + vip_w)
	var mid: float = name_y + 7.0 + vip_h / 2.0 if vip_h > 0.0 else (text_mid if text_mid >= 0.0 else name_y + 15.0)
	var top: float = maxf(floor_y, mid - BATTLE_SIDE / 2.0)
	return Rect2(pos + Vector2(ceilf(right + BATTLE_NAME_GAP), roundf(top)), Vector2(BATTLE_SIDE, BATTLE_SIDE))


static func battle_show(client: Object, acct: int) -> bool:
	if acct <= 0 or not battle_on(client):
		return false
	var mine: int = me(client)
	var shown_here: bool = mine > 0 and pairs.has(mine) and (acct == mine or acct == partner_of(client, mine))
	_gold = shown_here and married(acct)
	return shown_here


static func fdraw(screen: CanvasItem, at: Vector2, side: float, gold: int = -1, tone: int = 0) -> Rect2:
	var f: float = float(screen.get("_f")) if screen != null and screen.get("_f") != null else 1.0
	var rect: Rect2 = Rect2(at * f, Vector2(side, side) * f)
	draw(screen, rect, 1.0, 1.0, gold, tone)
	return rect


static func clip(screen: CanvasItem, font: Font, text: String, px: float, wide: float) -> String:
	var f: float = float(screen.get("_f")) if screen != null and screen.get("_f") != null else 1.0
	if screen != null and screen.has_method("_face"):
		font = screen.call("_face", font)
	var size: int = maxi(6, roundi(px * f))
	if font == null or font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x <= wide * f:
		return text
	var cut: String = text
	while cut.length() > 1 and font.get_string_size(cut + "…", HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > wide * f:
		cut = cut.substr(0, cut.length() - 1)
	return cut.strip_edges() + "…"


static func text_w(screen: CanvasItem, font: Font, text: String, px: float) -> float:
	var f: float = float(screen.get("_f")) if screen != null and screen.get("_f") != null else 1.0
	if screen != null and screen.has_method("_face"):
		font = screen.call("_face", font)
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * f))).x / f if font != null else 0.0




static func tick(client: Object, open: bool, love_tab: bool) -> void :
	if not open:
		return
	var every: float = STATE_OPEN if love_tab else STATE_IDLE
	if _now() - _state_at >= every and _now() - _failed >= AGAIN:
		want_state(client, false)

static func want_state(client: Object, force: bool) -> void :
	if _queued("state"):
		return
	if not force and _now() - _state_at < STATE_OPEN:
		return
	_state_at = _now()
	_ask(client, ["state", ROOT + "state", HTTPClient.METHOD_GET, ""])

static func _want_pairs(client: Object) -> void :
	if client == null or _queued("pairs"):
		return
	var t: float = _now()
	if t - _pairs_at < PAIRS_EVERY or t - _failed < AGAIN:
		return
	if _origin(client) == null:
		return
	_pairs_at = t
	_ask(client, ["pairs", PAIRS_PATH, HTTPClient.METHOD_GET, ""])
	if gate == 0 and t - _state_at >= STATE_FIRST:
		want_state(client, true)

static func peek(client: Object, acct: int) -> void :
	if acct > 0 and not _queued("peek"):
		_ask(client, ["peek", ROOT + "peek?id=%d" % acct, HTTPClient.METHOD_GET, str(acct)])

static func invite(client: Object, acct: int, name: String) -> void :
	var query: String = "to=%d" % acct if acct > 0 else "name=" + name.strip_edges().uri_encode()
	_ask(client, ["invite", ROOT + "invite?" + query, HTTPClient.METHOD_POST, name.strip_edges()])

static func accept(client: Object, id: int, name: String) -> void :
	_ask(client, ["accept", ROOT + "accept?id=%d" % id, HTTPClient.METHOD_POST, name])

static func reject(client: Object, id: int, name: String) -> void :
	_ask(client, ["reject", ROOT + "reject?id=%d" % id, HTTPClient.METHOD_POST, name])

static func cancel(client: Object, id: int, name: String) -> void :
	_ask(client, ["cancel", ROOT + "cancel?id=%d" % id, HTTPClient.METHOD_POST, name])

static func breakup(client: Object) -> void :
	_ask(client, ["breakup", ROOT + "breakup", HTTPClient.METHOD_POST, ""])

static func block(client: Object, on: bool) -> void :
	_ask(client, ["block", ROOT + "block?on=%d" % (1 if on else 0), HTTPClient.METHOD_POST, ""])


static func want_wed(client: Object) -> void :
	if not _queued("wed"):
		_ask(client, ["wed", WED + "state", HTTPClient.METHOD_GET, ""])

static func want_slots(client: Object, day: int) -> void :
	if not _queued("slots"):
		_ask(client, ["slots", WED + "slots?day=%d" % day, HTTPClient.METHOD_GET, str(day)])

static func want_hall(client: Object, id: int) -> void :
	if id > 0 and not _queued("hall"):
		_ask(client, ["hall", WED + "hall?id=%d" % id, HTTPClient.METHOD_GET, str(id)])

static func ring_buy(client: Object, tier: int) -> void :
	_ask(client, ["ring_buy", WED + "ring/buy?tier=%d" % tier, HTTPClient.METHOD_POST, ring_name(tier)])

static func ring_up(client: Object, tier: int) -> void :
	_ask(client, ["ring_up", WED + "ring/upgrade?tier=%d" % tier, HTTPClient.METHOD_POST, ring_name(tier)])

static func propose(client: Object, tier: int, partner: String) -> void :
	_ask(client, ["propose", WED + "propose?tier=%d" % tier, HTTPClient.METHOD_POST, partner])

static func answer(client: Object, id: int, yes: bool, name: String) -> void :
	_ask(client, ["answer" if yes else "refuse", WED + "answer?id=%d&yes=%d" % [id, 1 if yes else 0], HTTPClient.METHOD_POST, name])

static func withdraw(client: Object, id: int) -> void :
	_ask(client, ["withdraw", WED + "withdraw?id=%d" % id, HTTPClient.METHOD_POST, ""])

static func _csv(ids: Array) -> String:
	var parts: PackedStringArray = []
	for id: Variant in ids:
		parts.append(str(int(id)))
	return ",".join(parts)

static func book(client: Object, at: int, guests: Array) -> void :
	_ask(client, ["book", WED + "book?at=%d&guests=%s" % [at, _csv(guests)], HTTPClient.METHOD_POST, vn_time(at)])

static func set_guests(client: Object, id: int, guests: Array) -> void :
	_ask(client, ["guests", WED + "guests?id=%d&guests=%s" % [id, _csv(guests)], HTTPClient.METHOD_POST, ""])

static func unbook(client: Object, id: int) -> void :
	_ask(client, ["unbook", WED + "unbook?id=%d" % id, HTTPClient.METHOD_POST, ""])

static func join(client: Object, id: int) -> void :
	if not _queued("join"):
		_ask(client, ["join", WED + "join?id=%d" % id, HTTPClient.METHOD_POST, str(id)])



static func want_theme(client: Object) -> bool:
	var acct: int = me(client)
	if acct != theme_acct:
		theme_acct = acct
		theme_got = false
		_theme_at = -1000.0
		_theme_wait = 0.0
		_theme_tries = 0
		LobbyThemes.cuoi_ok = false
	if acct <= 0 or theme_got:
		return false
	if _queued("theme"):
		return _theme_tries == 1 and _now() - _theme_at < THEME_WAIT
	if _now() - _theme_at < maxf(_theme_wait, THEME_WAIT if _theme_tries < 3 else THEME_AGAIN):
		return false
	_theme_at = _now()
	_theme_tries += 1
	_ask(client, ["theme", WED + "theme", HTTPClient.METHOD_GET, str(acct)])
	return _theme_tries == 1 and _queued("theme")


static func set_hall_name(client: Object, name: String) -> void :
	var clean: String = name.strip_edges()
	_ask(client, ["hall_name", WED + "name?name=" + clean.uri_encode(), HTTPClient.METHOD_POST, clean])

static func bless(client: Object, id: int, k: int) -> void :
	_ask(client, ["bless", WED + "bless?id=%d&k=%d" % [id, k], HTTPClient.METHOD_POST, str(id)])


static func busy(kind: String) -> bool:
	return _queued(kind)

static func _queued(kind: String) -> bool:
	if not _busy.is_empty() and str(_busy[0]) == kind:
		return true
	for job: Array in _queue:
		if str(job[0]) == kind:
			return true
	return false


static func take(kinds: Array = []) -> Array:
	var out: Array = []
	var keep: Array = []
	var t: float = _now()
	for note: Dictionary in _notes:
		if t - float(note.get("at", t)) > NOTE_LIFE:
			continue
		if kinds.is_empty() or kinds.has(str(note.get("kind", ""))):
			out.append(note)
		else:
			keep.append(note)
	_notes = keep
	return out

static func _note(kind: String, text: String, ok: bool) -> void :
	_notes.append({"kind": kind, "text": text, "ok": ok, "at": _now()})
	if _notes.size() > 20:
		_notes = _notes.slice(_notes.size() - 20)



static func _ask(client: Object, job: Array) -> void :
	var origin: Variant = _origin(client)
	if origin == null:
		if not str(job[0]) in SILENT:
			_note(str(job[0]), NET_TEXT, false)
		return
	_client = client
	job[1] = str(origin) + str(job[1])
	_queue.append(job)
	_next()

static func _next() -> void :
	if not _busy.is_empty() or _queue.is_empty():
		return
	_busy = _queue.pop_front()
	var url: String = str(_busy[1])
	var method: int = int(_busy[2])
	asks.append([method, url])
	if fetch.is_valid():
		if int(fetch.call(url, method)) != OK:
			_fail()
		return
	var host_node: Node = _client as Node
	if host_node == null or not host_node.is_inside_tree():
		_busy = []
		_queue = []
		return
	var headers: PackedStringArray = AppSession.headers(url)
	if _http != null and is_instance_valid(_http):
		_http.cancel_request()
	if _http == null or not is_instance_valid(_http):
		_http = HTTPRequest.new()
		_http.timeout = 20.0
		if OS.has_feature("web"):
			_http.accept_gzip = false
		_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, data: PackedByteArray) -> void :
			done(result, code, data))
		_http.ready.connect( func() -> void :
			if _http.request(url, headers, method, "") != OK:
				_fail(), CONNECT_ONE_SHOT)
		host_node.add_child.call_deferred(_http)
	elif _http.request(url, headers, method, "") != OK:
		_fail()

static func _fail() -> void :
	if not _busy.is_empty() and not str(_busy[0]) in SILENT:
		_note(str(_busy[0]), "Lỗi mạng — thử lại.", false)
	_busy = []
	_failed = _now()
	rev += 1
	_kick()


static func _kick() -> void :
	var host: Node = _client as Node if _client != null and is_instance_valid(_client) else null
	if fetch.is_valid() or host == null or not host.is_inside_tree():
		_next()
		return
	if _kicked:
		return
	_kicked = true
	host.get_tree().process_frame.connect( func() -> void :
		_kicked = false
		_next(), CONNECT_ONE_SHOT)


static func done(result: int, code: int, body: PackedByteArray) -> void :
	if _busy.is_empty():
		return
	var job: Array = _busy
	if result != HTTPRequest.RESULT_SUCCESS:
		_fail()
		return
	var data: Variant = SafeJson.parse(body.get_string_from_utf8())
	if str(job[0]) in ["theme", "hall_name"]:
		_busy = []
		_love2_done(job, code, data)
		rev += 1
		_kick()
		return
	if str(job[0]) in WED_KINDS and (code in [404, 405, 501] or (code >= 400 and not data is Dictionary)):
		_busy = []
		_wed_off(str(job[0]))
		rev += 1
		_kick()
		return
	if not data is Dictionary:
		_fail()
		return
	_busy = []
	var kind: String = str(job[0])
	var arg: String = str(job[3])
	if kind == "pairs":
		_take_pairs(data)
	elif data.get("ok") != true:
		var off: bool = data.get("on") == false
		if off and kind in WED_KINDS:
			_wed_off(kind)
		elif off:
			gate = -1
			state = {}
		if code == 401:
			_failed = _now()
		elif not kind in SILENT and not (off and kind in WED_KINDS):
			_note(kind, str(data.get("error", "Có lỗi, thử lại sau.")), false)
	else:
		match kind:
			"state":
				gate = 1 if data.get("on") == true else -1
				state = data if gate == 1 else {}
				if gate == 1 and (wed_gate != -1 or _now() - _wed_off_at >= WED_RETRY):
					_requeue(job, "wed", WED + "state")
			"wed":
				wed_gate = 1 if data.get("on") == true else -1
				wed = data if wed_gate == 1 else {}
				if wed_gate == -1:
					_wed_off_at = _now()
			"slots":
				slots_data = data
			"hall", "join":
				hall_data = data
			"bless":
				var fresh: Variant = data.get("hall")
				if fresh is Dictionary:
					hall_data = fresh
				var gain: int = int(data.get("gain", 0))
				_note(kind, "Đã chúc phúc! Đôi uyên ương +%d thân mật." % gain if gain > 0 else "Đã chúc phúc!", true)
			"ring_buy":
				_note(kind, "Đã mua %s. Nhẫn nằm trong túi nhẫn." % str(data.get("name", arg)), true)
			"ring_up":
				_note(kind, "Đã nâng nhẫn cưới lên %s." % ring_name(int(data.get("ringTier", 0))), true)
			"propose":
				_note(kind, "Đã cầu hôn %s. Chờ người ấy trả lời." % (arg if not arg.is_empty() else "người ấy"), true)
			"answer", "refuse":
				if data.get("married") == true:
					_note(kind, "Bạn và %s đã thành Vợ Chồng!" % str(data.get("partnerName", arg)), true)
					_pairs_at = -1000.0
				else:
					_note(kind, "Đã từ chối lời cầu hôn. Nhẫn vẫn trong túi người ấy.", true)
			"withdraw":
				_note(kind, "Đã rút lại lời cầu hôn.", true)
			"book":
				_note(kind, "Đã đặt Lễ đường lúc %s." % arg, true)
			"guests":
				_note(kind, "Đã lưu danh sách khách mời (%d người)." % int(data.get("guests", 0)), true)
			"unbook":
				_note(kind, "Đã huỷ Lễ đường. Khung giờ được trả lại.", true)
			"peek":
				peeks[int(arg)] = data
			"invite":
				_note(kind, "Đã gửi lời tỏ tình tới %s. Chờ người ấy trả lời." % (arg if not arg.is_empty() else "người ấy"), true)
			"accept":
				_note(kind, "Bạn và %s đã thành Người Yêu!" % str(data.get("partnerName", arg)), true)
				_pairs_at = -1000.0
			"reject":
				_note(kind, "Đã từ chối lời tỏ tình của %s." % arg, true)
			"cancel":
				_note(kind, "Đã rút lại lời tỏ tình gửi %s." % arg, true)
			"breakup":
				if int(wcouple().get("state", 1)) == 2:
					_note(kind, "Đã ly hôn. Nhẫn cưới đã mất, sau %d ngày mới có đôi mới." % rule("breakupWaitDays", 7), true)
				else:
					_note(kind, "Đã chia tay. Sau %d ngày mới tỏ tình lại được." % rule("breakupWaitDays", 7), true)
				_pairs_at = -1000.0
			"block":
				_note(kind, "Đã chặn lời tỏ tình." if data.get("blockInvites") == true else "Đã mở lại lời tỏ tình.", true)
		if kind in ["invite", "accept", "reject", "cancel", "breakup", "block", "ring_buy", "ring_up", "propose", "answer", "refuse", "withdraw", "book", "guests", "unbook"]:
			_requeue(job, "state", ROOT + "state")
			_state_at = _now()
	rev += 1
	_kick()


static func _love2_done(job: Array, code: int, data: Variant) -> void :
	var kind: String = str(job[0])
	var ok: bool = data is Dictionary and data.get("ok") == true and code < 400
	if kind == "theme":
		if str(job[3]) != str(theme_acct):
			return
		if ok:
			theme_got = true
			LobbyThemes.cuoi_ok = str(data.get("theme", "")) == "cuoi"
		else:
			_theme_wait = THEME_SLOW if code in [404, 405, 501] else THEME_AGAIN
			_theme_at = _now()
		return
	if ok:
		var own: String = str(data.get("name", ""))
		var title: String = str(data.get("hallName", ""))
		_note(kind, ("Đã đặt tên sảnh lễ: %s." % own) if not own.is_empty() else ("Đã dùng tên mặc định: %s." % title), true)
		var c: Variant = wed.get("couple")
		if c is Dictionary:
			c["hallName"] = title
			c["hallOwn"] = own
		if hall_data.get("ok") == true and str(hall_data.get("role", "")) == "couple":
			hall_data["hallName"] = title
		_requeue(job, "wed", WED + "state")
	elif code in [404, 405, 501]:
		_note(kind, "Máy chủ chưa hỗ trợ đặt tên sảnh lễ.", false)
	else:
		var err: String = str(data.get("error", "")) if data is Dictionary else ""
		_note(kind, err if not err.is_empty() else "Chưa đặt được tên sảnh — thử lại.", false)


static func _requeue(job: Array, kind: String, path: String) -> void :
	if _queued(kind):
		return
	var url: String = str(job[1])
	_queue.append([kind, url.substr(0, url.find(ROOT)) + path, HTTPClient.METHOD_GET, ""])


static func _wed_off(kind: String) -> void :
	wed_gate = -1
	wed = {}
	slots_data = {}
	hall_data = {}
	_wed_off_at = _now()
	if not kind in SILENT:
		_note(kind, WED_OFF_TEXT, false)


static func _take_pairs(data: Dictionary) -> void :
	pairs_on = data.get("on") == true
	battle_heart = data.get("battleHeart") == true
	var fresh: Dictionary = {}
	var rows: Variant = data.get("pairs")
	if pairs_on and rows is Array:
		for row: Variant in rows:
			if not row is Array or (row as Array).size() < 2:
				continue
			var a: int = int(row[0])
			var b: int = int(row[1])
			if a <= 0 or b <= 0 or a == b:
				continue
			var since: int = int(row[2]) if (row as Array).size() > 2 else 0
			var kind: int = int(row[3]) if (row as Array).size() > 3 else 1
			fresh[a] = [b, since, kind]
			fresh[b] = [a, since, kind]
	pairs = fresh
