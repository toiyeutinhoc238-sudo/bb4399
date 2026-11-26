extends "hall_screen.gd"










const Boss = preload("world_boss_atlas.gd")
const Help = preload("master_atlas.gd")

signal closed

const DELAY: float = 1.0
const SHOW_VALUE: int = 10000000
const FRAMES: int = 100
const HP_WIDE: float = 458.0
const FLY_TIME: float = 1.0
const PURPLE: Color = Color("d65cff")
const PURPLE_RIM: Color = Color("3a0057")
const SELF: Color = Color("00fcff")


const RULE_TITLE: String = "boss Thế Giới"
const RULE_TEXT: String = "Mở HĐ boss thế giới, người chơi từ lv10 đều được tham gia.\n2.Khi BOSS chưa bị hạ, người chơi được hồi sinh vô hạn để tham gia chiến đấu, lượt chết càng nhiều, thời gian hồi sinh càng dài.\n3. Khi chết, người chơi tốn xu để hồi sinh ngay.\n4.Căn cứ sát thương người chơi tạo lên BOSS để xếp hạng Sát Thương. Khi HĐ kết thúc, xếp hạng Sát Thương càng cao, thưởng càng lớn.\n5. Người chơi đánh cú cuối cùng còn được nhận thêm phần thưởng là Bạc.\n6.Tiền nhận được từ phần thưởng có thể dùng đổi đạo cụ hiếm dùng đổi trợ thủ tư chất cao hơn."
const RULE_RIM: Color = Color("005797")
const DEAD: String = "Boss đã bị diệt"
const WAIT: String = "Kẻ Hủy Diệt chưa mở. Mở lúc %s."
const DAYS: Array = ["CN", "Thứ 2", "Thứ 3", "Thứ 4", "Thứ 5", "Thứ 6", "Thứ 7"]
const CD_TEXT: String = "CD @time@s"
const OUT_RANK: String = ">500"
const MAX_ROWS: int = 11

var _open_at: float = 0.0
var _opened: bool = false
var _live: bool = false
var _fly_n: int = 0
var _fly_at: float = -10.0
var _fly_value: int = 0
var _fly_from: Vector2 = Vector2.ZERO
var _fly_move: Vector2 = Vector2.ZERO
var _rule: bool = false

func chat_busy() -> bool:
	return _rule or super ()

func _setup() -> void :
	super ()
	_add_parts(Boss.PLACE)

func _frames() -> Dictionary:
	return Boss.FRAME

func _shown() -> void :
	_reset_list()
	_rule = false
	if client == null:
		return
	if is_visible_in_tree():
		_open_at = _time
		_opened = false
		_live = true
		_fly_n = int(client.world_boss.get("drop_n", 0))
		_fly_at = -10.0
	elif _live:

		_live = false
		_opened = false
		client.world_boss_close()

func _tick(_delta: float) -> void :
	if client == null:
		return
	_tick_list()
	if _live and not _opened and _time - _open_at >= DELAY:
		_opened = true
		client.world_boss_open()
	var count: int = int(client.world_boss.get("drop_n", 0))
	if count != _fly_n:
		_fly_n = count

		if _opened:
			_fly()




static func hp_text(hp: int, top: int) -> String:
	if hp < SHOW_VALUE:
		return str(hp)
	return "%.2f%%" % (100.0 * hp / top) if top > 0 else "0.00%"


static func fill_width(hp: int, top: int) -> int:
	if top <= 0:
		return 0
	var frame: int = clampi(int(float(FRAMES) * hp / top), 1, FRAMES)
	return roundi(445.0 * (frame - 1) / (FRAMES - 1))


static func wait_text(start: int, end: int) -> String:
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(start + 25200)
	var e: Dictionary = Time.get_datetime_dict_from_unix_time(maxi(start, end) + 25200)
	var close: String = "24:00" if end - start >= 60 and int(e.hour) == 0 and int(e.minute) == 0 else "%02d:%02d" % [int(e.hour), int(e.minute)]
	return WAIT % ("%02d:%02d-%s %s %02d/%02d" % [int(d.hour), int(d.minute), close, DAYS[int(d.weekday)], int(d.day), int(d.month)])


func cd_left() -> int:
	return maxi(0, int(client.world_boss.get("enter_at", 0)) - int(Time.get_unix_time_from_system()))



func rank_rows() -> Array:
	var boss: Dictionary = client.world_boss
	var out: Array = []
	var rows: Array = boss.get("rows", [])
	for i in range(mini(rows.size(), MAX_ROWS - 1)):
		var row: Array = rows[i]
		out.append([i + 1, str(row[1]), int(row[2]), str(row[0])])
	if int(boss.get("harm", 0)) > 0 and int(boss.get("rank", 0)) > 10:
		out.append([int(boss.rank), str(client.character.get("name", "")), int(boss.harm), client.char_uuid])
	return out

func _fly() -> void :
	var boss: Dictionary = client.world_boss
	var top: int = int(boss.get("max", 0))
	_fly_value = absi(int(boss.get("drop", 0)))
	_fly_from = Vector2(HP_WIDE * int(boss.get("hp", 0)) / top if top > 0 else 0.0, 0)
	_fly_move = Vector2(200.0 * randf(), -50.0 - 100.0 * randf())
	_fly_at = _time



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
		_use(Hall.FILE, Hall.R)
		_use(Boss.FILE, Boss.R)
		_use(Help.FILE, {"ms_help_ok": Help.R["ms_help_ok"]})
	_scene()
	var frame: Vector2 = _at("hall")
	var hall_rows: Array = _parts.get("hall", [])
	if Boss.AWARDS.is_empty():

		hall_rows = hall_rows.filter( func(row: Array) -> bool: return str(row[3]) != "wb_award")
	_frows(hall_rows, frame)
	_fblit("wb_boss", frame + Vector2(float(Boss.BOSS[0]), float(Boss.BOSS[1])))
	if _opened:
		_draw_hp(frame + Vector2(float(Boss.HP.at[0]), float(Boss.HP.at[1])))
	_draw_ranks(frame)
	_draw_awards(frame)
	var left: int = cd_left()
	if left > 0:
		_fwords(CD_TEXT.replace("@time@", str(left)), ARIAL_BOLD, float(Boss.CD[4]), Color(str(Boss.CD[5])), "l", 
			frame + Vector2(float(Boss.CD[0]), float(Boss.CD[1])), 290.0, 1.0, 0.0, false)
	var side: Vector2 = _at("list")
	_frows(_parts.get("list", []), side)
	_draw_players(side)
	_draw_chat()
	_draw_menu()
	if not _viewing.is_empty():
		_draw_viewing()
	if _rule:
		_draw_rule()



func _draw_rule() -> void :
	var box: Array = Help.SIZES["help"]
	var at: Vector2 = _window(float(box[0]), float(box[1]))
	var title: Array = Help.HELP_TEXT["lblTile"]
	_fwords(RULE_TITLE, ARIAL_BOLD, float(title[4]), Color(str(title[5])), str(title[7]), at + Vector2(float(title[0]), float(title[1])), 
		float(title[2]), 1.0, 0.0, true)
	var desc: Array = Help.HELP_TEXT["levelDesc"]
	var face: Font = _face(ARIAL_BOLD)
	var px: int = maxi(6, roundi(float(desc[4]) * _f))
	var lines: int = maxi(1, int(float(desc[3]) * _f / face.get_height(px)))
	var origin: Vector2 = (at + Vector2(float(desc[0]), float(desc[1]) + 2.0)) * _f + Vector2(0, face.get_ascent(px))
	draw_multiline_string_outline(face, origin, RULE_TEXT, HORIZONTAL_ALIGNMENT_LEFT, float(desc[2]) * _f, px, lines, maxi(1, roundi(_f)), RULE_RIM)
	draw_multiline_string(face, origin, RULE_TEXT, HORIZONTAL_ALIGNMENT_LEFT, float(desc[2]) * _f, px, lines, Color(str(desc[5])))
	var ok: Array = Help.HELP["btnConfirm"]
	_fbutton("rule_ok", "ms_help_ok", at + Vector2(float(ok[0]), float(ok[1])))


func _draw_hp(at: Vector2) -> void :
	var squash: Vector2 = Vector2(float(Boss.HP.scale[0]), float(Boss.HP.scale[1]))
	var boss: Dictionary = client.world_boss
	var hp: int = int(boss.get("hp", 0))
	var top: int = int(boss.get("max", 0))
	if top > 0:
		var back: Vector2 = _cell_size("wb_hp_bk")
		_fblit("wb_hp_bk", at, back.x * squash.x, back.y * squash.y)
		var wide: int = fill_width(hp, top)
		var cell: Array = _cells.get("wb_hp_fill", [])
		if wide > 0 and not cell.is_empty() and cell[0] != null:
			var region: Array = cell[1]
			var from: Vector2 = at + Vector2(float(Boss.HP.fill[0]) * squash.x, float(Boss.HP.fill[1]) * squash.y)
			draw_texture_rect_region(cell[0], Rect2(from * _f, Vector2(wide * squash.x, float(region[3]) * squash.y) * _f), 
				Rect2(float(region[0]), float(region[1]), float(wide), float(region[3])))
	var label: Array = Boss.HP.texts.lblHP
	var px: float = float(label[4]) * squash.y
	_fwords(hp_text(hp, top), ARIAL_BOLD, px, Color(str(label[5])), "c", at + Vector2(float(label[0]) * squash.x - 150.0, float(label[1]) * squash.y), 
		300.0, 1.0, 26.0 * squash.y, false)
	var age: float = _time - _fly_at
	if age >= 0.0 and age < FLY_TIME and _fly_value > 0:
		var step: float = age / FLY_TIME
		var spot: Vector2 = _fly_from + _fly_move * step
		var grow: float = 1.0 + 0.2 * step
		_fwords("-%d" % _fly_value, ARIAL_BOLD, 22.0 * grow * squash.y, Color(PURPLE, 1.0 - 0.5 * step), "l", 
			at + Vector2(spot.x * squash.x, spot.y * squash.y), 400.0, 1.5, 0.0, false, Color(PURPLE_RIM, 1.0 - 0.5 * step))


func _draw_ranks(frame: Vector2) -> void :
	var list: Array = Boss.LIST
	var rows: Array = rank_rows()
	var row_high: float = float(list[4])
	for i in range(mini(rows.size(), MAX_ROWS)):
		var row: Array = rows[i]
		var at: Vector2 = frame + Vector2(float(list[0]), float(list[1]) + row_high * i)
		var mine: bool = not client.char_uuid.is_empty() and str(row[3]) == client.char_uuid
		var color: Color = SELF if mine else Color.WHITE
		var rank: int = int(row[0])
		if rank >= 1 and rank <= 5:
			var mid: Array = Boss.ROW.rank_mid
			var cell: Vector2 = _cell_size("wb_rank%d" % rank)
			_fblit("wb_rank%d" % rank, at + Vector2(float(mid[0]), float(mid[1])) - cell / 2.0)
		else:
			_row_text(OUT_RANK if rank == 0 else str(rank), "lblRank", at, color, mine)
		_row_text(str(row[1]), "lblName", at, color, mine)
		_row_text(str(row[2]), "lblHarmValue", at, color, mine)
		_fblit("wb_cutline", at + Vector2(float(Boss.ROW.cutline[0]), float(Boss.ROW.cutline[1])))

func _row_text(text: String, key: String, at: Vector2, color: Color, mine: bool) -> void :
	var label: Array = Boss.ROW[key]
	var px: float = float(Boss.ROW["self"][1]) if mine else float(label[4])
	_fwords(text, ARIAL_BOLD, px, color, str(label[7]), at + Vector2(float(label[0]), float(label[1])), float(label[2]), 1.0, 
		float(Boss.LIST[4]))


func _draw_awards(frame: Vector2) -> void :
	var tiles: Dictionary = Boss.TILES
	var cols: int = maxi(1, int(tiles.cols))
	for i in range(mini(Boss.AWARDS.size(), 10)):
		var item: Array = Boss.ITEMS.get(str(Boss.AWARDS[i]), ["", ""])
		var at: Vector2 = frame + Vector2(float(tiles.at[0]) + float(tiles.step[0]) * (i % cols), float(tiles.at[1]) + float(tiles.step[1]) * (i / cols))
		var icon: Texture2D = pack.picture(str(item[1])) if not str(item[1]).is_empty() else null
		if icon != null:
			draw_texture_rect(icon, Rect2(at * _f, Vector2(40, 40) * _f), false)
		_fwords(str(item[0]), ARIAL_BOLD, 13.0, Color.WHITE, "l", at + Vector2(40, 0), 96.0, 1.0, 40.0)



func _activate(id: String) -> void :
	if _rule:

		if id in ["rule_ok", "cancel"]:
			_rule = false
		return
	match id:
		"enter":

			var left: int = cd_left()
			var wait: int = client.world_boss_wait_at()
			if wait > 0:
				var info: Array = client.acts.get(8, [])
				say(wait_text(wait, wait + (int(info[1]) if info.size() >= 2 else 0)))
			elif left > 0:
				say(CD_TEXT.replace("@time@", str(left)))
			elif int(client.world_boss.get("hp", 0)) <= 0:
				say(DEAD)
			elif not client.world_boss_join():
				say("Chưa vào được lúc này.")
		"rule":
			_rule = true
		"back":
			closed.emit()
		_:
			_shared(id)

func _wheel(step: int, at: Vector2) -> void :
	if not _viewing.is_empty() or _rule:
		return
	_wheel_list(step, at)


func _escape() -> bool:
	if not _rule:
		return super ()
	_rule = false
	return true

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode == KEY_ESCAPE:
		closed.emit()
		get_viewport().set_input_as_handled()
