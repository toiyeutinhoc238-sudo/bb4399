extends "flash_screen.gd"










const Award = preload("league_award_atlas.gd")
const Arena = preload("arena_atlas.gd")
const Boss = preload("world_boss_atlas.gd")

signal closed

const W: float = 810.0
const H: float = 500.0
const DIM: float = 0.4
const PANEL: Vector2 = Vector2(250, 342)
const PANEL_Y: float = 54.0
const PANEL_GAP: float = 10.0
const CELL: float = 76.0
const SHADOW: Color = Color("06325a")
const YELLOW: Color = Color("ffe45c")
const PALE: Color = Color("cfeaff")
const OK_GREEN: Color = Color("7cfc00")
const PINK: Color = Color("ff9a9a")
const CYAN: Color = Color("5cf2ff")
const WAIT: float = 8.0
const RANK: Vector2 = Vector2(460, 420)
const RANK_ROWS: int = 10

const LOCKED: int = 0
const IDLE: int = 1
const OPEN: int = 2
const DEAD: int = 3
const EXPIRED: int = 4

const FACE_DIR: String = "res://assets/ui/hall/"
const TINTS: Array = [Color(1.0, 0.86, 0.62), Color(0.7, 0.88, 1.0), Color(1.0, 0.62, 0.55)]

const CHESTS: Dictionary = {990031101: ["Rương Boss Guild I", "", "gift_shenmiqiu03", 3], 990031102: ["Rương May Mắn I", "", "gift_pvp2", 4], 
	990031103: ["Rương Boss Guild II", "", "gift_shenmiqiu03", 4], 990031104: ["Rương May Mắn II", "", "gift_pvp2", 4], 
	990031105: ["Rương Boss Guild III", "", "gift_shenmiqiu03", 5], 990031106: ["Rương May Mắn III", "", "gift_pvp2", 5]}
const ROLES: Dictionary = {0: "Thành viên", 1: "Hội phó", 2: "Hội trưởng"}

var ranking: int = 0
var sent: Array = []
var _wait: Dictionary = {}
var _rev: int = -1
var _state: String = ""
var _faces: Dictionary = {}

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Arena.FILE, Arena.R)
	_use(Award.FILE, Award.R)
	_use(Boss.FILE, Boss.R)
	if client != null:
		client.changed.connect(_follow)




static func action(info: Dictionary, boss: Dictionary, awards: Array, now: int) -> Array:
	var id: int = int(boss.get("id", 0))
	match int(boss.get("status", LOCKED)):
		IDLE, EXPIRED:
			if int(info.get("role", 0)) >= 1 and int(info.get("role", 0)) <= 2:
				return ["summon", "Triệu hồi", int(boss.get("summons", 0)) > 0]
			return ["", "Chờ triệu hồi", false]
		OPEN:
			var can: bool = int(info.get("entries", 0)) < int(info.get("entries_max", 0)) and bool(boss.get("tank_ok", false))\
			and int(info.get("cooldown", 0)) <= now and int(boss.get("close_at", 0)) - now >= 10
			return ["enter", "Vào đánh", can]
		DEAD:
			for award: Dictionary in awards:
				if int(award.get("boss", 0)) == id:
					return ["claim", "Nhận rương", true]
			return ["", "Đã hạ", false]
	return ["", "Chưa mở", false]


static func status_line(info: Dictionary, boss: Dictionary, now: int) -> Array:
	match int(boss.get("status", LOCKED)):
		IDLE:
			return ["Chưa triệu hồi · còn %d lượt triệu hồi" % int(boss.get("summons", 0)), PALE]
		EXPIRED:
			return ["Boss đã rời đi · còn %d lượt triệu hồi" % int(boss.get("summons", 0)), PALE]
		OPEN:
			var line: String = "Boss rời đi sau " + clock(int(boss.get("close_at", 0)) - now)
			if int(info.get("cooldown", 0)) > now:
				line += " · chờ %d giây" % (int(info.get("cooldown", 0)) - now)
			return [line, YELLOW]
		DEAD:
			var lucky: String = str(boss.get("lucky", ""))
			return ["Đã hạ! May mắn: " + lucky if not lucky.is_empty() else "Đã hạ boss hôm nay!", CYAN]
	return ["Hạ boss trước đó hôm nay để mở", PALE]


static func clock(seconds: int) -> String:
	seconds = maxi(0, seconds)
	if seconds >= 3600:
		return "%d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]
	return "%02d:%02d" % [seconds / 60, seconds % 60]


static func need_text(boss: Dictionary) -> String:
	var parts: Array = []
	for need: Variant in boss.get("need", []):
		if need is Array and need.size() >= 2 and int(need[1]) > 0:
			parts.append("%d tank cấp %d+" % [int(need[1]), int(need[0])])
	return "Cần " + ", ".join(parts) if not parts.is_empty() else ""


static func hp_text(hp: int, top: int) -> String:
	if top <= 0:
		return ""
	if top >= 10000000:
		return "%d%%" % ceili(100.0 * hp / top)
	return "%d/%d" % [hp, top]


static func rank_of(rows: Array, uid: String) -> int:
	for i in range(rows.size()):
		if str(rows[i].get("uid", "")) == uid and not uid.is_empty():
			return i + 1
	return 0



func open() -> void :
	if visible:
		return
	_hover = ""
	_press = ""
	ranking = 0
	_state = str(client.state) if client != null else ""
	_rev = int(client.guild_boss_rev) if client != null else -1
	_wait = {}
	if pack != null:
		pack.load_bag()
	visible = true

func close() -> void :
	if not visible:
		return
	visible = false
	ranking = 0
	closed.emit()


func _follow() -> void :
	if not visible or client == null:
		return
	if str(client.state) != _state or not bool(client.guild_boss.get("live", false)):
		close()
		return
	if int(client.guild_boss_rev) != _rev:
		_rev = int(client.guild_boss_rev)
		_wait = {}

func _waiting(id: int) -> bool:
	return _time - float(_wait.get(id, -100.0)) < WAIT

func _boss(id: int) -> Dictionary:
	for boss: Dictionary in client.guild_boss.get("bosses", []):
		if int(boss.get("id", 0)) == id:
			return boss
	return {}



func _paint() -> void :
	var at: Vector2 = _window(W, H, "close", DIM)
	_fwords("BOSS GUILD", ARIAL_BOLD, 20.0, YELLOW, "c", at + Vector2(0, 20), W, 2.0, 27.0, false, Color(SHADOW, 0.95))
	var info: Dictionary = client.guild_boss
	var now: int = client.guild_boss_now()
	var bosses: Array = info.get("bosses", [])
	if int(info.get("role", 255)) == 255 or bosses.is_empty():
		_fwords("Bạn cần gia nhập Guild để đánh Boss Guild.", ARIAL_BOLD, 16.0, Color.WHITE, "c", at + Vector2(0, 200), W, 1.5, 0.0, true, 
			Color(SHADOW, 0.9))
	else:
		for i in range(mini(3, bosses.size())):
			_draw_boss(at + Vector2(20.0 + i * (PANEL.x + PANEL_GAP), PANEL_Y), bosses[i], info, now)
		var role: String = str(ROLES.get(int(info.get("role", 0)), ""))
		var line: String = "Guild %s · %s · Lượt vào trận hôm nay: %d/%d" % [str(info.get("guild", "")), role, int(info.get("entries", 0)), 
			int(info.get("entries_max", 0))]
		_fwords(line, ARIAL_BOLD, 12.0, Color.WHITE, "c", at + Vector2(20, PANEL_Y + PANEL.y + 4.0), W - 40.0, 1.5, 0.0, true, Color(SHADOW, 0.9))
		_fwords("Gây ít nhất 1% máu boss để nhận Rương thường; một người được Rương May Mắn. Bấm ảnh boss để xem bảng sát thương.", 
			ARIAL_BOLD, 11.0, PALE, "c", at + Vector2(20, PANEL_Y + PANEL.y + 21.0), W - 40.0, 1.5, 0.0, true, Color(SHADOW, 0.9))
	var feed: Array = client.guild_boss_feed
	if not feed.is_empty():
		var last: Dictionary = feed[feed.size() - 1]
		_fwords("Mới nhất: Guild %s đã hạ %s" % [str(last.get("guild", "")), str(last.get("boss", ""))], ARIAL_BOLD, 11.0, YELLOW, "c", 
			at + Vector2(20, PANEL_Y + PANEL.y + 38.0), W - 40.0, 1.5, 0.0, true, Color(SHADOW, 0.9))
	_ebutton("shut", "Đóng", at + Vector2(floorf((W - 120.0) / 2.0), H - 17.0 - 35.0), true)
	if ranking > 0:
		_paint_rank()

func _draw_boss(at: Vector2, boss: Dictionary, info: Dictionary, now: int) -> void :
	var id: int = int(boss.get("id", 0))
	var tier: int = clampi(int(boss.get("tier", 1)), 1, 3)
	var status: int = int(boss.get("status", LOCKED))
	var dark: bool = status == LOCKED
	_round(Rect2(at * _f, PANEL * _f), Color(SHADOW, 0.45), 14.0, Color(1, 1, 1, 0.35), 2.0)
	_fwords(str(boss.get("name", "")), ARIAL_BOLD, 15.0, YELLOW if not dark else PALE, "c", at + Vector2(0, 6), PANEL.x, 1.5, 0.0, true, 
		Color(SHADOW, 0.95))

	var face_rect: Rect2 = Rect2((at + Vector2(55, 28)) * _f, Vector2(140, 112) * _f)
	var lit: bool = _hover == "rank:%d" % id and _press.is_empty()
	_round(face_rect, Color(0, 0, 0, 0.3), 10.0, Color(1, 1, 1, 0.6 if lit else 0.2), 2.0)
	var face: Variant = _portrait(tier)
	var tint: Color = Color(0.35, 0.35, 0.4) if dark else Color.WHITE
	if face is Texture2D:
		var k: float = minf(140.0 / face.get_width(), 112.0 / face.get_height())
		var box: Vector2 = Vector2(face.get_size()) * k
		draw_texture_rect(face, Rect2((at + Vector2(55, 28) + (Vector2(140, 112) - box) / 2.0) * _f, box * _f), false, tint)
	else:
		_fblit("wb_boss", at + Vector2(66, 28), 118.0, 112.0, tint * TINTS[tier - 1])
	if dark:
		_lock(face_rect.get_center(), 40.0, Color(1, 1, 1, 0.7))
	for k in range(tier):
		_star(at + Vector2(PANEL.x / 2.0 + (k - (tier - 1) / 2.0) * 20.0, 150.0), 8.0)
	_hit("rank:%d" % id, face_rect, false)

	var top: int = int(boss.get("max_hp", 0))
	var hp: int = int(boss.get("hp", 0))
	var bar: Vector2 = at + Vector2(15, 162)
	_fblit("wb_hp_bk", bar, 220.0, 18.0)
	var frac: float = clampf(float(hp) / top, 0.0, 1.0) if top > 0 else 0.0
	if frac > 0.0:
		_fblit("wb_hp_fill", bar + Vector2(3, 3), 214.0 * frac, 12.0)
	_fwords(hp_text(hp, top), ARIAL_BOLD, 11.0, Color.WHITE, "c", bar, 220.0, 1.2, 18.0)
	var line: Array = status_line(info, boss, now)
	_fwords(str(line[0]), ARIAL_BOLD, 11.0, line[1], "c", at + Vector2(4, 184), PANEL.x - 8.0, 1.2, 0.0, true, Color(SHADOW, 0.9))
	var need: String = need_text(boss)
	if not need.is_empty():
		var ok: bool = bool(boss.get("tank_ok", false))
		_fwords(need + (" ✓" if ok else ""), ARIAL_BOLD, 11.0, OK_GREEN if ok else PINK, "c", at + Vector2(4, 201), PANEL.x - 8.0, 1.2, 0.0, true, 
			Color(SHADOW, 0.9))
	var items: Dictionary = pack.bag.get("items", {}) if pack != null else {}
	_draw_chest(at + Vector2(32, 220), int(boss.get("base", 0)), "Thường", items, not dark)
	_draw_chest(at + Vector2(PANEL.x - 32.0 - CELL, 220), int(boss.get("rand", 0)), "May mắn", items, not dark)
	var act: Array = action(info, boss, client.guild_boss_awards, now)
	var key: String = "%s:%d" % [str(act[0]) if not str(act[0]).is_empty() else "none", id]
	_ebutton(key, str(act[1]), at + Vector2(floorf((PANEL.x - 120.0) / 2.0), PANEL.y - 43.0), bool(act[2]) and not _waiting(id))


func _draw_chest(at: Vector2, item: int, label: String, items: Dictionary, usable: bool) -> void :
	var tint: Color = Color(1, 1, 1, 1.0 if usable else 0.35)
	var spot: Dictionary = Award.TILE
	_fblit("la_tile", at + Vector2(float(spot["bg"][0]), float(spot["bg"][1])), 0.0, 0.0, tint)
	var found: Variant = items.get(str(item))
	var more: Array = found if found is Array else CHESTS.get(item, [])
	var quality: int = int(more[3]) if more.size() > 3 else 0
	if quality >= 2 and quality <= 5:
		_fblit("la_q%d" % quality, at + Vector2(float(spot["quality"][0]), float(spot["quality"][1])), 0.0, 0.0, tint)
	var box: Array = spot["item"]
	if more.size() > 2 and not str(more[2]).is_empty() and pack != null:
		var picture: Texture2D = pack.picture("l/it/%s.webp" % str(more[2]))
		if picture != null and picture.get_width() > 4:
			var k: float = minf(float(box[2]) / picture.get_width(), float(box[3]) / picture.get_height())
			draw_texture_rect(picture, Rect2((at + Vector2(float(box[0]), float(box[1]))) * _f, Vector2(picture.get_size()) * k * _f), false, tint)
	var spot_label: Array = spot["lblNum"]
	_fwords(label, ARIAL_BOLD, 12.0, Color(1, 1, 1, tint.a), "c", at + Vector2(float(spot_label[0]), float(spot_label[1])), float(spot_label[2]))
	if more.size() > 0 and _hover == "chest:%d" % item:
		_fwords(str(more[0]), ARIAL_BOLD, 11.0, YELLOW, "c", at + Vector2(-20, -14), CELL + 40.0, 1.2, 0.0, true, Color(SHADOW, 0.95))
	_hit("chest:%d" % item, Rect2(at * _f, Vector2(CELL, 68) * _f), false)

func _portrait(tier: int) -> Variant:
	if not _faces.has(tier):
		var path: String = FACE_DIR + "gb_boss_%02d.png" % tier
		_faces[tier] = load(path) if ResourceLoader.exists(path) else false
	return _faces[tier]


func _ebutton(id: String, text: String, at: Vector2, on: bool) -> void :
	var rect: Rect2 = _fblit("public_button_window_green" if on else "public_button_window_gray", at, 0.0, 0.0, _glow(id) if on else Color.WHITE)
	_fwords(text, ARIAL_BOLD, 14.0, Color.WHITE if on else Color("eeeeee"), "c", at, 120.0, 0.0, 35.0)
	_hit(id if on else id + ":off", rect, false)

func _star(c: Vector2, r: float) -> void :
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(10):
		var angle: float = - PI / 2.0 + PI * i / 5.0
		points.append((c + Vector2(cos(angle), sin(angle)) * (r if i % 2 == 0 else r * 0.45)) * _f)
	draw_colored_polygon(points, Color("ffd02a"))
	points.append(points[0])
	draw_polyline(points, Color("8a4a00"), maxf(1.0, _f), true)


func _paint_rank() -> void :
	var at: Vector2 = _window(RANK.x, RANK.y, "rank_close", 0.3)
	var boss: Dictionary = _boss(ranking)
	_fwords("Sát thương · " + str(boss.get("name", "")), ARIAL_BOLD, 17.0, YELLOW, "c", at + Vector2(0, 20), RANK.x, 2.0, 27.0, false, 
		Color(SHADOW, 0.95))
	var rows: Array = boss.get("rows", [])
	var me: String = client.guild_self_uuid()
	if rows.is_empty():
		_fwords("Chưa có ai gây sát thương.", ARIAL_BOLD, 14.0, Color.WHITE, "c", at + Vector2(0, 170), RANK.x, 1.5, 0.0, true, Color(SHADOW, 0.9))
	var shown: Array = rows.slice(0, RANK_ROWS)
	var mine: int = rank_of(rows, me)
	if mine > RANK_ROWS:
		shown.append(rows[mine - 1])
	var top: int = maxi(1, int(boss.get("max_hp", 0)))
	for i in range(shown.size()):
		var row: Dictionary = shown[i]
		var place: int = i + 1 if i < RANK_ROWS else mine
		var y: float = 58.0 + i * 26.0
		var own: bool = str(row.get("uid", "")) == me and not me.is_empty()
		if own:
			_round(Rect2((at + Vector2(30, y - 2)) * _f, Vector2(RANK.x - 60.0, 24) * _f), Color(1, 1, 1, 0.15), 6.0)
		if place <= 3:
			_fblit("wb_top%d" % place, at + Vector2(36, y + 1))
		else:
			_fwords(str(place), ARIAL_BOLD, 13.0, Color.WHITE, "c", at + Vector2(36, y), 40.0, 1.2, 22.0)
		_fwords(str(row.get("name", "")), ARIAL_BOLD, 13.0, CYAN if own else Color.WHITE, "l", at + Vector2(86, y), 200.0, 1.2, 22.0)
		var dmg: int = int(row.get("dmg", 0))
		_fwords("%d (%.1f%%)" % [dmg, 100.0 * dmg / top], ARIAL_BOLD, 13.0, YELLOW, "r", at + Vector2(RANK.x - 190.0, y), 150.0, 1.2, 22.0)
	_ebutton("rank_close", "Đóng", at + Vector2(floorf((RANK.x - 120.0) / 2.0), RANK.y - 17.0 - 35.0), true)



func _send(type: int, id: int) -> void :
	if not client.guild_boss_send(type, id):
		say("Boss Guild chưa mở.")
		return
	sent.append([type, id])
	_wait[id] = _time

func _activate(id: String) -> void :
	if ranking > 0:
		if id == "rank_close":
			ranking = 0
		return
	var tail: int = int(id.get_slice(":", 1)) if id.contains(":") else 0
	match id.get_slice(":", 0):
		"close", "shut":
			close()
		"rank":
			ranking = tail
		"summon", "enter":
			_send(323, tail)
		"claim":
			_send(324, tail)
		"none":
			var boss: Dictionary = _boss(tail)
			if int(boss.get("status", LOCKED)) == LOCKED:
				say("Hãy hạ boss trước đó hôm nay để mở boss này.")

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		if ranking > 0:
			ranking = 0
		else:
			close()
		get_viewport().set_input_as_handled()
