extends "flash_screen.gd"








const Award = preload("league_award_atlas.gd")
const Arena = preload("arena_atlas.gd")
const GarageModel = preload("garage_model.gd")
const TankPortrait = preload("tank_portrait.gd")

signal closed

const W: float = 810.0
const H: float = 498.0
const DIM: float = 0.4
const PANEL: Vector2 = Vector2(250, 336)
const PANEL_Y: float = 56.0


const ART_DIR: String = "res://assets/ui/hall/"
const STRIP: Rect2 = Rect2(2, 20, 246, 46)
const TOP: float = 18.0
const VC_NAVY: Color = Color("0b2447")
const PANEL_GAP: float = 10.0
const CELL: float = 76.0
const CELL_GAP: float = 6.0
const SHADOW: Color = Color("06325a")
const YELLOW: Color = Color("ffe45c")
const PALE: Color = Color("cfeaff")
const HOURS: Array = [24, 24, 72]

const REWARDS: Dictionary = {1: [8000005, 1000, 3000], 2: [8000005, 1000, 3000], 3: [8000005, 1000, 3000], 
	4: [2004603, 1, 3], 5: [2004603, 1, 3], 6: [2004604, 1, 3], 7: [4050013, 4, 8], 8: [4050013, 4, 8], 9: [2004602, 1, 2]}
const GROUP_NAMES: Array = ["1 sao", "2 sao", "3 sao"]

const CHESTS: Dictionary = {2004603: ["Rương Viễn Chinh Đồng", "", "gift_shenmiqiu02", 3], 2004604: ["Rương Viễn Chinh Bạc", "", "gift_shenmiqiu03", 4], 
	2004602: ["Rương Viễn Chinh Vàng", "", "gift_pvp2", 5]}
const WAIT: float = 8.0
const PICK: Vector2 = Vector2(560, 420)
const PICK_COLS: int = 6
const PICK_ROWS: int = 3
const PICK_STEP: Vector2 = Vector2(84, 100)
const ASK: Vector2 = Vector2(440, 220)

var draft: Array = [0, 0, 0, 0, 0, 0, 0, 0, 0]
var picking: int = 0
var asking: int = 0
var sent: Array = []
var _wait: Array = [-100.0, -100.0, -100.0]
var _rev: int = -1
var _state: String = ""
var _roster: Array = []
var _roster_key: String = ""
var _scroll: int = 0
var _vc_art: Dictionary = {}


func art(name: String) -> Texture2D:
	if not _vc_art.has(name):
		var path: String = ART_DIR + name + ".png"
		var tex: Variant = load(path) if ResourceLoader.exists(path) else null
		_vc_art[name] = tex if tex is Texture2D else false
	var got: Variant = _vc_art[name]
	return got if got is Texture2D else null

func chat_busy() -> bool:
	return visible

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Arena.FILE, Arena.R)
	_use(Award.FILE, Award.R)
	if client != null:
		client.changed.connect(_follow)




static func unlocked(cell: int, owned: int) -> bool:
	return cell >= 1 and cell <= 9 and (cell <= 3 or owned >= cell)


static func phase(times: Array, group: int, now: int) -> String:
	var at: int = int(times[group - 1]) if group >= 1 and group <= times.size() else 0
	if at <= 0:
		return "idle"
	return "done" if now - at >= int(HOURS[group - 1]) * 3600 else "run"


static func left(times: Array, group: int, now: int) -> int:
	var at: int = int(times[group - 1]) if group >= 1 and group <= times.size() else 0
	return maxi(0, int(HOURS[group - 1]) * 3600 - (now - at)) if at > 0 else 0


static func clock(seconds: int) -> String:
	seconds = maxi(0, seconds)
	return "%02d:%02d:%02d" % [seconds / 3600, (seconds / 60) % 60, seconds % 60]


static func cells_of(group: int) -> Array:
	return [group * 3 - 2, group * 3 - 1, group * 3]


static func reward_label(cell: int) -> String:
	var row: Array = REWARDS.get(cell, [0, 0, 0])
	return str(row[1]) if int(row[1]) == int(row[2]) else "%d–%d" % [int(row[1]), int(row[2])]



func open() -> void :
	if visible:
		return
	_hover = ""
	_press = ""
	picking = 0
	asking = 0
	_scroll = 0
	_state = str(client.state) if client != null else ""
	_rev = int(client.expedition_rev) if client != null else -1
	_wait = [-100.0, -100.0, -100.0]
	_tidy()
	if pack != null:
		pack.load_garage()
		pack.load_bag()
	visible = true

func close() -> void :
	if not visible:
		return
	visible = false
	picking = 0
	asking = 0
	closed.emit()


func _follow() -> void :
	if not visible or client == null:
		return
	if str(client.state) != _state or not bool(client.expedition.get("live", false)):
		close()
		return
	if int(client.expedition_rev) != _rev:
		_rev = int(client.expedition_rev)
		_wait = [-100.0, -100.0, -100.0]
		_tidy()


func _tidy() -> void :
	if client == null:
		return
	var times: Array = client.expedition.get("times", [0, 0, 0])
	var busy: Array = _busy_tanks()
	var mine: Array = _owned_ids()
	var owned: int = owned_count()
	for cell in range(1, 10):
		var group: int = (cell + 2) / 3
		var tank: int = int(draft[cell - 1])
		if tank <= 0:
			continue
		if phase(times, group, client.expedition_now()) != "idle" or not unlocked(cell, owned) or busy.has(tank) or ( not mine.is_empty() and not mine.has(tank)):
			draft[cell - 1] = 0


func _busy_tanks() -> Array:
	var out: Array = []
	var tanks: Array = client.expedition.get("tanks", [])
	for i in range(mini(9, tanks.size())):
		if int(tanks[i]) > 0:
			out.append(int(tanks[i]))
	return out

func _rows() -> Array:
	if client == null or pack == null:
		return []
	var key: String = "%d:%d" % [client.tanks.size(), pack.garage.get("tanks", {}).size()]
	if key != _roster_key:
		_roster_key = key
		_roster = GarageModel.roster(client.tanks, pack.garage, pack.lobby.get("tanks", {}), pack.index.get("tanks", {}), int(Time.get_unix_time_from_system()))
	return _roster


func _owned_ids() -> Array:
	var out: Array = []
	if client == null:
		return out
	for inst: Variant in client.tanks.values():
		if inst is Dictionary and int(inst.get("m_contType", -1)) == GarageModel.OWN:
			var id: int = int(inst.get("m_tpltId", 0))
			if id > 0 and not out.has(id):
				out.append(id)
	return out


func owned_count() -> int:
	return maxi(int(client.expedition.get("owned", 0)), _owned_ids().size()) if client != null else 0


func choices() -> Array:
	var busy: Array = _busy_tanks()
	var out: Array = []
	var mine: Array = _owned_ids()
	for rec: Dictionary in _rows():
		var id: int = int(rec.get("id", 0))
		if mine.has(id) and not busy.has(id) and not draft.has(id):
			out.append(rec)
	return out

func _rec(id: int) -> Dictionary:
	for rec: Dictionary in _rows():
		if int(rec.get("id", 0)) == id:
			return rec
	return {"id": id, "name": str(pack.lobby.get("tanks", {}).get(str(id), id)) if pack != null else str(id), "ext": 0}


func tank_at(cell: int) -> int:
	var group: int = (cell + 2) / 3
	if phase(client.expedition.get("times", [0, 0, 0]), group, client.expedition_now()) == "idle":
		return int(draft[cell - 1])
	var tanks: Array = client.expedition.get("tanks", [])
	return int(tanks[cell - 1]) if cell - 1 < tanks.size() else 0

func _waiting(group: int) -> bool:
	return _time - float(_wait[group - 1]) < WAIT



func _paint() -> void :
	var at: Vector2 = _window(W, H, "close", DIM)
	_fwords("VIỄN CHINH", ARIAL_BOLD, 20.0, YELLOW, "c", at + Vector2(0, 20), W, 2.0, 27.0, false, Color(SHADOW, 0.95))
	var times: Array = client.expedition.get("times", [0, 0, 0])
	var now: int = client.expedition_now()
	var owned: int = owned_count()
	var items: Dictionary = pack.bag.get("items", {})
	var back: Texture2D = art("vc_backdrop")
	if back != null:
		var area: Vector2 = Vector2(3.0 * PANEL.x + 2.0 * PANEL_GAP, PANEL.y)
		var got: Vector2 = Vector2(back.get_size())
		var wide: float = minf(got.x, got.y * area.x / area.y)
		var high: float = wide * area.y / area.x
		draw_texture_rect_region(back, Rect2((at + Vector2(20, PANEL_Y)) * _f, area * _f), Rect2((got.x - wide) / 2.0, (got.y - high) / 2.0, wide, high))
	for group in range(1, 4):
		_draw_group(at + Vector2(20.0 + (group - 1) * (PANEL.x + PANEL_GAP), PANEL_Y), group, times, now, owned, items)
	_fwords("Ô 1–3 luôn mở; ô N (4–9) mở khi sở hữu ít nhất N tank (không tính tank thuê). Đang sở hữu: %d tank." % owned, 
		ARIAL_BOLD, 12.0, Color.WHITE, "c", at + Vector2(20, PANEL_Y + PANEL.y + 6.0), W - 40.0, 1.5, 0.0, true, Color(SHADOW, 0.9))
	_fwords("Tank đi viễn chinh vẫn ra trận bình thường. Gọi về sớm: tank về ngay, không có thưởng.", 
		ARIAL_BOLD, 12.0, PALE, "c", at + Vector2(20, PANEL_Y + PANEL.y + 24.0), W - 40.0, 1.5, 0.0, true, Color(SHADOW, 0.9))
	_ebutton("shut", "Đóng", at + Vector2(floorf((W - 120.0) / 2.0), H - 17.0 - 35.0), true)
	if picking > 0:
		_paint_pick()
	elif asking > 0:
		_paint_ask()

func _draw_group(at: Vector2, group: int, times: Array, now: int, owned: int, items: Dictionary) -> void :
	_round(Rect2(at * _f, PANEL * _f), Color(SHADOW, 0.45), 14.0, Color(1, 1, 1, 0.35), 2.0)
	var strip: Texture2D = art("vc_team%d" % group)
	if strip != null:
		draw_texture_rect(strip, Rect2((at + STRIP.position) * _f, STRIP.size * _f), false)
	for k in range(group):
		_star(at + Vector2(PANEL.x / 2.0 + (k - (group - 1) / 2.0) * 20.0, 10.5), 8.0)
	var title: String = "Đội %s · %d giờ" % [GROUP_NAMES[group - 1], int(HOURS[group - 1])]
	if strip != null:
		_fwords(title, ARIAL_BOLD, 15.0, Color.WHITE, "c", at + Vector2(STRIP.position.x + 12.0, STRIP.position.y), STRIP.size.x - 24.0, 2.5, STRIP.size.y, 
			true, Color(VC_NAVY, 0.95))
	else:
		_fwords(title, ARIAL_BOLD, 13.0, Color.WHITE, "c", at + Vector2(0, 30), PANEL.x, 1.5, 0.0, true, Color(SHADOW, 0.9))
	var state: String = phase(times, group, now)
	var cells: Array = cells_of(group)
	for k in range(3):
		var cell: int = int(cells[k])
		var spot: Vector2 = at + Vector2(5.0 + k * (CELL + CELL_GAP), 52.0 + TOP)
		_draw_tank_cell(spot, cell, tank_at(cell), state, unlocked(cell, owned))
		_draw_reward(spot + Vector2(0, 112), cell, items, unlocked(cell, owned))
	_fwords("Thưởng mỗi tank khi đội trở về", ARIAL_BOLD, 11.0, PALE, "c", at + Vector2(0, 148 + TOP), PANEL.x, 1.2, 0.0, true, Color(SHADOW, 0.9))
	var line: String = "Chọn tank rồi bấm Xuất phát"
	var color: Color = PALE
	if state == "run":
		line = "Còn lại " + clock(left(times, group, now))
		color = YELLOW
	elif state == "done":
		line = "Đội đã trở về!"
		color = Color("5cf2ff")
	var badge: Texture2D = art("vc_return") if state == "done" else null
	if badge != null:
		draw_texture_rect(badge, Rect2((at + Vector2(32, 253 + TOP - 6.0)) * _f, Vector2(84, 28) * _f), false)
		_fwords(line, ARIAL_BOLD, 13.0, color, "l", at + Vector2(120, 250 + TOP), PANEL.x - 126.0, 1.5, 0.0, true, Color(SHADOW, 0.9))
	else:
		_fwords(line, ARIAL_BOLD, 13.0, color, "c", at + Vector2(0, 250 + TOP), PANEL.x, 1.5, 0.0, true, Color(SHADOW, 0.9))
	var btn: Vector2 = at + Vector2(floorf((PANEL.x - 120.0) / 2.0), 272 + TOP)
	var wait: bool = _waiting(group)
	match state:
		"idle":
			var any: bool = false
			for cell: Variant in cells:
				any = any or int(draft[int(cell) - 1]) > 0
			_ebutton("go:%d" % group, "Xuất phát", btn, any and not wait)
		"run":
			_ebutton("back:%d" % group, "Gọi về", btn, not wait)
		_:
			_ebutton("claim:%d" % group, "Nhận thưởng", btn, not wait)


func _draw_tank_cell(at: Vector2, cell: int, tank: int, state: String, usable: bool) -> void :
	var rect: Rect2 = Rect2(at * _f, Vector2(CELL, CELL) * _f)
	var lit: bool = _hover == "cell:%d" % cell and _press.is_empty() and state == "idle" and usable
	_round(rect, Color(SHADOW, 0.7) if usable else Color(0, 0, 0, 0.35), 10.0, Color(1, 1, 1, 0.8 if lit else (0.4 if usable else 0.15)), 2.0)
	if tank > 0:
		var rec: Dictionary = _rec(tank)
		var face: String = GarageModel.face(pack.garage, int(rec.get("ext", 0))) if not pack.garage.is_empty() else ""
		if not TankPortrait.draw(self, pack, face, 0, (at + Vector2(CELL / 2.0, CELL / 2.0 + 4.0)) * _f, 0.34 * _f, _time, "l/t", true, rect):
			_fwords("?", ARIAL_BOLD, 22.0, PALE, "c", at + Vector2(0, 24), CELL)
		_fwords(str(rec.get("name", tank)), ARIAL_BOLD, 11.0, Color.WHITE, "c", at + Vector2(-3, CELL + 3.0), CELL + 6.0, 1.2, 0.0, true, Color(SHADOW, 0.9))
	elif not usable:
		_lock(rect.get_center() - Vector2(0, 8) * _f, 36.0, Color(1, 1, 1, 0.55))
		_fwords("Cần %d tank" % cell, ARIAL_BOLD, 11.0, PALE, "c", at + Vector2(0, 50), CELL, 1.2, 0.0, true, Color(SHADOW, 0.9))
	elif state == "idle":
		_plus(rect.get_center(), 40.0, Color(1, 1, 1, 0.85))
	_hit("cell:%d" % cell, rect, false)


func _draw_reward(at: Vector2, cell: int, items: Dictionary, usable: bool) -> void :
	var tint: Color = Color(1, 1, 1, 1.0 if usable else 0.35)
	var spot: Dictionary = Award.TILE
	_fblit("la_tile", at + Vector2(float(spot["bg"][0]), float(spot["bg"][1])), 0.0, 0.0, tint)
	var item: int = int(REWARDS[cell][0])
	var found: Variant = items.get(str(item))
	var more: Array = found if found is Array else CHESTS.get(item, [])
	var quality: int = int(more[3]) if more.size() > 3 else 0
	if quality >= 2 and quality <= 5:
		_fblit("la_q%d" % quality, at + Vector2(float(spot["quality"][0]), float(spot["quality"][1])), 0.0, 0.0, tint)
	var box: Array = spot["item"]
	if more.size() > 2 and not str(more[2]).is_empty():
		var picture: Texture2D = pack.picture("l/it/%s.webp" % str(more[2]))
		if picture != null and picture.get_width() > 4:
			var k: float = minf(float(box[2]) / picture.get_width(), float(box[3]) / picture.get_height())
			draw_texture_rect(picture, Rect2((at + Vector2(float(box[0]), float(box[1]))) * _f, Vector2(picture.get_size()) * k * _f), false, tint)
	var label: Array = spot["lblNum"]
	_fwords(reward_label(cell), ARIAL_BOLD, 12.0, Color(1, 1, 1, tint.a), "c", at + Vector2(float(label[0]), float(label[1])), float(label[2]))
	if more.size() > 0 and _hover == "prize:%d" % cell:
		_fwords(str(more[0]), ARIAL_BOLD, 11.0, YELLOW, "c", at + Vector2(-20, -14), CELL + 40.0, 1.2, 0.0, true, Color(SHADOW, 0.95))
	_hit("prize:%d" % cell, Rect2(at * _f, Vector2(CELL, 68) * _f), false)


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


func _paint_pick() -> void :
	var at: Vector2 = _window(PICK.x, PICK.y, "pick_close", 0.3)
	_fwords("Chọn tank cho ô %d" % picking, ARIAL_BOLD, 18.0, YELLOW, "c", at + Vector2(0, 20), PICK.x, 2.0, 27.0, false, Color(SHADOW, 0.95))
	var list: Array = choices()
	if list.is_empty():
		var text: String = "Đang tải danh sách tank…" if pack.garage.is_empty() else "Không còn tank sở hữu nào rảnh để chọn."
		_fwords(text, ARIAL_BOLD, 14.0, Color.WHITE, "c", at + Vector2(0, 170), PICK.x, 1.5, 0.0, true, Color(SHADOW, 0.9))
	var rows: int = ceili(list.size() / float(PICK_COLS))
	_scroll = clampi(_scroll, 0, maxi(0, rows - PICK_ROWS))
	var x0: float = floorf((PICK.x - (PICK_COLS - 1) * PICK_STEP.x - CELL) / 2.0)
	for i in range(_scroll * PICK_COLS, mini(list.size(), (_scroll + PICK_ROWS) * PICK_COLS)):
		var rec: Dictionary = list[i]
		var k: int = i - _scroll * PICK_COLS
		var spot: Vector2 = at + Vector2(x0 + (k % PICK_COLS) * PICK_STEP.x, 60.0 + (k / PICK_COLS) * PICK_STEP.y)
		var id: String = "pick:%d" % int(rec.get("id", 0))
		var rect: Rect2 = Rect2(spot * _f, Vector2(CELL, CELL) * _f)
		var lit: bool = _hover == id and _press.is_empty()
		_round(rect, Color(SHADOW, 0.7), 10.0, Color(1, 1, 1, 0.85 if lit else 0.4), 2.0)
		var face: String = GarageModel.face(pack.garage, int(rec.get("ext", 0)))
		TankPortrait.draw(self, pack, face, 0, (spot + Vector2(CELL / 2.0, CELL / 2.0 + 4.0)) * _f, 0.34 * _f, _time, "l/t", true, rect)
		_fwords("Cấp %d" % int(rec.get("level", 1)), ARIAL_BOLD, 10.0, YELLOW, "l", spot + Vector2(5, 3), CELL - 8.0, 1.2, 0.0, true, Color(SHADOW, 0.9))
		_fwords(str(rec.get("name", "")), ARIAL_BOLD, 11.0, Color.WHITE, "c", spot + Vector2(-3, CELL + 3.0), CELL + 6.0, 1.2, 0.0, true, Color(SHADOW, 0.9))
		_hit(id, rect, false)
	if rows > PICK_ROWS:
		_fwords("%d / %d (lăn chuột để xem thêm)" % [_scroll + 1, rows - PICK_ROWS + 1], ARIAL_BOLD, 11.0, PALE, "c", at + Vector2(0, PICK.y - 82.0), 
			PICK.x, 1.2, 0.0, true, Color(SHADOW, 0.9))
	_ebutton("pick_close", "Đóng", at + Vector2(floorf((PICK.x - 120.0) / 2.0), PICK.y - 17.0 - 35.0), true)


func _paint_ask() -> void :
	var at: Vector2 = _window(ASK.x, ASK.y, "ask_no", 0.3)
	_fwords("GỌI VỀ SỚM", ARIAL_BOLD, 18.0, YELLOW, "c", at + Vector2(0, 20), ASK.x, 2.0, 27.0, false, Color(SHADOW, 0.95))
	_fpara("Gọi đội viễn chinh %s trở về ngay? Tank về lại kho nhưng KHÔNG nhận được phần thưởng." % GROUP_NAMES[asking - 1], 
		ARIAL_BOLD, 14.0, Color.WHITE, at + Vector2(40, 66), ASK.x - 80.0, 3)
	_ebutton("ask_ok", "Gọi về", at + Vector2(ASK.x / 2.0 - 130.0, ASK.y - 17.0 - 35.0), true)
	_ebutton("ask_no", "Huỷ", at + Vector2(ASK.x / 2.0 + 10.0, ASK.y - 17.0 - 35.0), true)



func _wheel(step: int, _at: Vector2) -> void :
	if picking > 0:
		_scroll = maxi(0, _scroll + step)

func _send(type: int, group: int, tanks: Array = []) -> void :
	if not client.expedition_send(type, group, tanks):
		say("Viễn chinh chưa mở.")
		return
	sent.append([type, group] + tanks)
	_wait[group - 1] = _time

func _activate(id: String) -> void :
	if picking > 0:
		if id == "pick_close":
			picking = 0
		elif id.begins_with("pick:"):
			var tank: int = int(id.get_slice(":", 1))
			if not draft.has(tank):
				draft[picking - 1] = tank
			picking = 0
		return
	if asking > 0:
		if id == "ask_ok":
			_send(377, asking)
			asking = 0
		elif id == "ask_no":
			asking = 0
		return
	var tail: int = int(id.get_slice(":", 1)) if id.contains(":") else 0
	match id.get_slice(":", 0):
		"close", "shut":
			close()
		"cell":
			_cell(tail)
		"go":
			var tanks: Array = []
			for cell: Variant in cells_of(tail):
				tanks.append(int(draft[int(cell) - 1]))
			_send(376, tail, tanks)
		"back":
			asking = tail
		"claim":
			_send(378, tail)


func _cell(cell: int) -> void :
	if cell < 1 or cell > 9:
		return
	var group: int = (cell + 2) / 3
	if phase(client.expedition.get("times", [0, 0, 0]), group, client.expedition_now()) != "idle":
		say("Đội %s đang viễn chinh." % GROUP_NAMES[group - 1])
		return
	if not unlocked(cell, owned_count()):
		say("Cần sở hữu ít nhất %d tank để mở ô này." % cell)
		return
	if int(draft[cell - 1]) > 0:
		draft[cell - 1] = 0
		return
	picking = cell
	_scroll = 0

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode == KEY_ESCAPE:
		if picking > 0:
			picking = 0
		elif asking > 0:
			asking = 0
		else:
			close()
		get_viewport().set_input_as_handled()
