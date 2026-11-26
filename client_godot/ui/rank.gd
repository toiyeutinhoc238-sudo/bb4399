extends "flash_screen.gd"







const Atlas = preload("rank_atlas.gd")

signal closed

const SIZE: Vector2 = Vector2(1000, 576)
const LIST_SIZE: Vector2 = Vector2(822, 530)
const DIM: Color = Color(0, 0, 0, 0.4)
const PER_PAGE: int = 8
const PAGER_X: float = 306.0
const SLOTS: Array = ["frmAttrPhyArm", "frmAttrEnyArm", "frmAttrCtsisArm", "frmAttrHpMax", "frmAttrAtk"]
const SLOT_LABELS: Array = ["lblAttrPhyArm", "lblAttrEnyArm", "lblAttrCtsisArm", "lblAttrHpMax", "lblAttrAtk"]
const SLOT_ICONS: Array = ["phy_arm", "eng_arm", "ctsis_arm", "hpmax", "atk"]
const ORDER: Array = [6, 7, 3, 12, 1, 14]
const TOTAL_LABELS: Array = ["lblPhyArm", "lblEnyArm", "lblCtsisArm", "lblMaxHp", "lblAtk", "lblCommonCool"]
const ROW_NAMES: Array = ["Giáp Vật Lý:", "Giáp Năng Lượng:", "Xuyên:", "HP:", "TC:", "CD Skill:"]
const ATTR_NAMES: Dictionary = {1: "TC", 3: "Xuyên Thấu", 6: "Giáp Vật Lý", 7: "Khiên Năng Lượng", 12: "HP", 14: "CD Skill"}
const NOW: String = "Hiện tại"
const NEXT: String = "Lv sau"
const TITLE_ATTR: String = "Thuộc Tính Quân Hàm"
const ACTIVATE: String = "Kích hoạt"
const NEXT_ACTIVE: String = "ĐK kích hoạt skill kế tiếp:"
const SPEC_DONE: String = "Đã kích hoạt toàn bộ thuộc tính đặc biệt"
const SPEC_AT: String = "Quân hàm %s kích hoạt thuộc tính"
const UNLOCK_AT: String = "Sao đạt %d sẽ mở"
const INTRO: String = "Giới thiệu:\nCứ mỗi tăng 1 cấp Tank sẽ nhận được 1 Ngôi Sao, tích lũy đạt số lượng nhất định để tăng cấp Quân Hàm và thuộc tính"
const SKY_INK: Color = Color("aefaff")
const GOLD_INK: Color = Color("fcc853")
const SKY_RIM: Color = Color(7 / 255.0, 100 / 255.0, 156 / 255.0, 0.8)
const BAR_RIM: Color = Color(108 / 255.0, 13 / 255.0, 44 / 255.0, 0.5)

var _sheet_id: String = ""
var _page: int = 1
var _failed: bool = false

func chat_busy() -> bool:
	return not _sheet_id.is_empty()

func _setup() -> void :
	pack.picture_ready.connect( func(path: String) -> void :
		if path == "l/rank.json":
			_failed = pack.rank.is_empty()
			if not _failed and is_visible_in_tree():
				_preload())

func _shown() -> void :
	_sheet_id = ""
	if not is_visible_in_tree():
		return
	_page = 1
	_failed = false
	pack.load_rank()
	if not pack.rank.is_empty():
		_preload()


func _preload() -> void :
	var now: int = _current()
	for rank: int in [now, mini(now + 1, _count())]:
		pack.picture(_badge_path(rank))
	for rank in range(1, _count() + 1):
		pack.picture(_badge_path(rank))



func _ranks() -> Array:
	return pack.rank.get("ranks", [])

func _count() -> int:
	return _ranks().size()


func _rank(rank: int) -> Array:
	var list: Array = _ranks()
	return list[rank - 1] if rank >= 1 and rank <= list.size() else ["", 1, []]

func _nodes(rank: int) -> Array:
	return _rank(rank)[2]

func _name(rank: int) -> String:
	return str(_rank(rank)[0])

func _badge_path(rank: int) -> String:
	return "l/mr/b%d.webp" % int(_rank(rank)[1])


func _start(rank: int) -> int:
	var nodes: Array = _nodes(rank)
	return int(nodes[0][0]) if not nodes.is_empty() else 0

func _stars() -> int:
	return clampi(int(client.character.get("nMilitaryStar", 0)), 0, int(pack.rank.get("max", 510)))

func _current() -> int:
	var stars: int = _stars()
	var out: int = 1
	for rank in range(1, _count() + 1):
		if _start(rank) <= stars:
			out = rank
	return out


func _floor_star() -> int:
	var stars: int = _stars()
	var out: int = 0
	for node: Array in _nodes(_current()):
		if int(node[0]) <= stars:
			out = maxi(out, int(node[0]))
	return out



func _slots() -> Array:
	var nodes: Array = _nodes(_current())
	var out: Array = []
	if nodes.size() >= SLOTS.size():
		for i in range(SLOTS.size()):
			out.append([int(nodes[i][0]), nodes[i][1]])
		return out
	for i in range(SLOTS.size()):
		out.append([-1, []])
	for node: Array in nodes:
		for attr: Array in node[1]:
			var at: int = ORDER.find(int(attr[0]))
			if at >= 0 and at < SLOTS.size():
				out[at] = [int(node[0]), (out[at][1] as Array) + [attr]]
	return out


func _plain(value: float) -> String:
	return str(int(roundf(value))) if is_equal_approx(value, roundf(value)) else String.num(value, 4)


func _desc(attrs: Array) -> String:
	var lines: PackedStringArray = PackedStringArray()
	for attr: Array in attrs:
		var kind: int = int(attr[0])
		var value: String = _plain(float(attr[2]))
		if int(attr[1]) == 2:
			value = "%.1f" % (float(attr[2]) * 100.0)
			if value.ends_with("0"):
				value = "%.0f" % (float(attr[2]) * 100.0)
			value += "%"
		lines.append(str(ATTR_NAMES.get(kind, "Thuộc tính %d" % kind)) + ("" if kind == 14 else "+") + value)
	return "\n".join(lines)


func _totals() -> Array:
	var stars: int = _stars()
	var sum: Array = []
	sum.resize(ORDER.size())
	sum.fill(0.0)
	for rank: Array in _ranks():
		for node: Array in rank[2]:
			var star: int = int(node[0])
			if star < 1 or star > stars or (node[1] as Array).is_empty():
				continue
			for attr: Array in (node[1] as Array) + (node[2] as Array):
				var at: int = ORDER.find(int(attr[0]))
				if at >= 0:
					sum[at] = float(sum[at]) + float(attr[2])
	return sum


func _total_texts() -> Array:
	var sum: Array = _totals()
	return ["+%.2f" % float(sum[0]), "+%.2f" % float(sum[1]), "+%.2f" % float(sum[2]), "+" + _plain(float(sum[3])), "+%.2f" % float(sum[4]), 
		"%.1f%%" % (float(sum[5]) * 100.0)]


func _next_special() -> Array:
	var stars: int = _stars()
	var last: Array = []
	for rank in range(1, _count() + 1):
		for node: Array in _nodes(rank):
			if (node[2] as Array).is_empty():
				continue
			if stars < int(node[0]):
				return [rank, node[2], SPEC_AT % _name(rank)]
			last = [rank, node[2], SPEC_DONE]
	return last


func _next_active() -> int:
	var stars: int = _stars()
	var best: int = 0
	for rank: Array in _ranks():
		for node: Array in rank[2]:
			var star: int = int(node[0])
			if star > stars and not (node[1] as Array).is_empty() and (best == 0 or star < best):
				best = star
	return best


func _progress() -> Array:
	var now: int = _current()
	if now < _count():
		return [now + 1, _start(now + 1)]
	return [now, _floor_star()]

func _page_count() -> int:
	return maxi(1, ceili(float(_count()) / float(PER_PAGE)))



func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(SIZE.x, SIZE.y)
	_hit("panel", Rect2(base * _f, SIZE * _f), false)
	_fblit("rk_frame", base + Vector2(float(Atlas.FRAME[0]), float(Atlas.FRAME[1])))
	if pack.rank.is_empty():
		var text: String = "Không tải được bảng quân hàm, mở lại để thử lại." if _failed else "Đang tải quân hàm…"
		_fwords(text, ARIAL_BOLD, 16.0, Color.WHITE, "c", base + Vector2(0, SIZE.y / 2.0 - 12.0), SIZE.x, 1.0, 24.0)
	else:
		_draw_head(base)
		_draw_slots(base)
		_draw_totals(base)
		_draw_special(base)
	_fbutton("close", "rk_close", base + Vector2(float(Atlas.CLOSE["main"][0]), float(Atlas.CLOSE["main"][1])))
	if _sheet_id == "list":
		_draw_list()


func _draw_head(base: Vector2) -> void :
	var now: int = _current()
	var progress: Array = _progress()
	var stars: int = _stars()
	var need: int = int(progress[1])
	_badge(now, base + _spot("imgRankNow"))
	_badge(int(progress[0]), base + _spot("imgRankNext"))
	_label("_MilitaryRankFrame_CGradientLabel1", NOW, base, false, SKY_INK, SKY_RIM, 1.5)
	_label("_MilitaryRankFrame_CGradientLabel2", NEXT, base, false, SKY_INK, SKY_RIM, 1.5)
	var bar: Vector2 = base + _spot("mcProgress")
	_fblit("rk_pr_bk", bar)
	var ratio: float = 1.0 if need <= 0 else clampf(float(stars) / float(need), 0.0, 1.0)
	var fill: Vector2 = _cell_size("rk_pr")
	if ratio > 0.0:
		_fpart("rk_pr", bar, Rect2(Vector2.ZERO, Vector2(roundf(fill.x * ratio), fill.y)))
	_label("lblTips", "%d/%d" % [stars, need], base, true, Color(0, 0, 0, 0), BAR_RIM, 1.0)
	_label("lblMRNow", _name(now), base, false)
	_label("lblMRNext", _name(int(progress[0])), base, false)
	_fbutton("preview", "rk_preview", base + _spot("btnPreview"))


func _draw_slots(base: Vector2) -> void :
	var stars: int = _stars()
	var slots: Array = _slots()
	for i in range(SLOTS.size()):
		var star: int = int(slots[i][0])
		var on: bool = star >= 0 and stars >= star
		var big: bool = i == SLOTS.size() - 1
		var r: Array = Atlas.MAIN[SLOTS[i]]
		var box: Vector2 = Vector2(129, 114) if big else Vector2(float(r[2]), float(r[3]))
		var mid: Vector2 = base + Vector2(float(r[0]), float(r[1])) + box / 2.0
		_centred("rk_b_bk" if big else "rk_m_bk", mid)
		if on:
			_centred("rk_b_lbk" if big else "rk_m_lbk", mid)
		_centred("rk_i_%s_%s" % [SLOT_ICONS[i], "on" if on else "off"], mid)
		_lines(SLOT_LABELS[i], _desc(slots[i][1]), base)


func _draw_totals(base: Vector2) -> void :
	_label("_MilitaryRankFrame_CGradientLabel3", TITLE_ATTR, base, false, SKY_INK, SKY_RIM, 1.5)
	var texts: Array = _total_texts()
	for i in range(ROW_NAMES.size()):
		_label("_MilitaryRankFrame_Label%d" % (i + 5), ROW_NAMES[i], base, false)
		_label(TOTAL_LABELS[i], texts[i], base, false)
	var intro: String = str(pack.rank.get("intro", INTRO))
	_fpara(intro if not intro.is_empty() else INTRO, ARIAL_BOLD, 14.0, Color.WHITE, base + Vector2(665, 305), 305.0)


func _draw_special(base: Vector2) -> void :
	var special: Array = _next_special()
	var r: Array = Atlas.MAIN["frmAttrCommonCool"]
	var mid: Vector2 = base + Vector2(float(r[0]) + float(r[2]) / 2.0, float(r[1]) + float(r[3]) / 2.0)
	_centred("rk_m_bk", mid)
	_centred("rk_i_common_cool_off", mid)
	_label("_MilitaryRankFrame_CGradientLabel4", ACTIVATE, base, false, GOLD_INK, SKY_RIM, 1.5)
	if not special.is_empty():
		_badge(int(special[0]), base + _spot("imgNextSpec"))
		_label("lblActiveTips", str(special[2]), base, false)
		_lines("lblAttrCommonCool", _desc(special[1]), base)
	var star: int = _next_active()
	if star > 0:
		_label("lblNextActiveDesc", NEXT_ACTIVE, base, true)
		_fblit("rk_star", base + _spot("imgNextActiveStar") - Vector2(0, roundf(_cell_size("rk_star").y / 2.0)))
		_label("lblActiveCondition", "x%d" % star, base, true)


func _draw_list() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("list_shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(LIST_SIZE.x, LIST_SIZE.y)
	_hit("list_panel", Rect2(at * _f, LIST_SIZE * _f), false)
	_fblit("rk_list_frame", at + Vector2(float(Atlas.LIST_FRAME[0]), float(Atlas.LIST_FRAME[1])))
	var stars: int = _stars()
	for i in range(PER_PAGE):
		var rank: int = (_page - 1) * PER_PAGE + i + 1
		if rank > _count():
			break
		var r: Array = Atlas.LIST["frmRank%d" % (i + 1)]
		_card(rank, at + Vector2(float(r[0]), float(r[1])), stars >= _start(rank))
	var pager: Array = Atlas.LIST["numPage"]
	var y: float = float(pager[1])
	_fbutton("pg_prev", "rk_pg_prev", at + Vector2(PAGER_X, y))
	for n in range(1, _page_count() + 1):
		_fbutton("pg:%d" % n, "rk_pg%d%s" % [mini(n, 8), "_on" if n == _page else ""], at + Vector2(PAGER_X + 30.0 * n, y + 2.0))
	_fbutton("pg_next", "rk_pg_next", at + Vector2(PAGER_X + 30.0 * (_page_count() + 1), y))
	_fbutton("list_close", "rk_close", at + Vector2(float(Atlas.CLOSE["list"][0]), float(Atlas.CLOSE["list"][1])))


func _card(rank: int, at: Vector2, active: bool) -> void :
	_fblit("rk_card_on", at)
	var picture: Texture2D = pack.picture(_badge_path(rank))
	if picture != null:
		var span: Vector2 = picture.get_size()
		draw_texture_rect(picture, Rect2((at + Vector2(floorf((180.0 - span.x) / 2.0), 50)) * _f, span * _f), false)
	var title: Array = Atlas.CARD["lblRankName"]
	_fwords(_name(rank), ARIAL_BOLD, float(title[4]), Color(str(title[5])), "c", at + Vector2(float(title[0]), float(title[1]) - 23.0), float(title[2]), 0.0, 23.0)
	if active:
		return
	_fblit("rk_card_off", at)
	var cond: Array = Atlas.CARD["lblRankCondition"]
	_fwords(UNLOCK_AT % _start(rank), ARIAL_BOLD, float(cond[4]), Color(str(cond[5])), "c", at + Vector2(float(cond[0]), float(cond[1]) - 10.0), float(cond[2]), 0.0, 20.0)


func _spot(id: String) -> Vector2:
	var r: Array = Atlas.MAIN[id]
	return Vector2(float(r[0]), float(r[1]))


func _centred(name: String, mid: Vector2) -> void :
	_fblit(name, (mid - _cell_size(name) / 2.0).floor())


func _badge(rank: int, at: Vector2) -> void :
	var picture: Texture2D = pack.picture(_badge_path(rank))
	if picture != null:
		draw_texture_rect(picture, Rect2(at * _f, picture.get_size() * _f), false)


func _label(key: String, text: String, base: Vector2, mid: bool, tint: Color = Color(0, 0, 0, 0), rim: Color = SHADE, edge: float = 0.0) -> void :
	if text.is_empty():
		return
	var spec: Array = Atlas.TEXT[key]
	var ink: Color = Color(str(spec[5])) if tint.a <= 0.0 else tint
	var top: float = float(spec[1]) - (12.0 if mid else 0.0)
	_fwords(text, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), ink, str(spec[7]), base + Vector2(float(spec[0]), top), float(spec[2]), edge, 24.0 if mid else 0.0, true, rim)


func _lines(key: String, text: String, base: Vector2) -> void :
	var spec: Array = Atlas.TEXT[key]
	var step: float = float(spec[4]) + 3.0
	var row: int = 0
	for line: String in text.split("\n", false):
		_fwords(line, ARIAL_BOLD if int(spec[6]) == 1 else ARIAL, float(spec[4]), Color(str(spec[5])), str(spec[7]), base + Vector2(float(spec[0]), float(spec[1]) + step * row), float(spec[2]))
		row += 1



func _go(page: int) -> void :
	_page = clampi(page, 1, _page_count())

func _activate(id: String) -> void :
	if _sheet_id == "list":
		if id.begins_with("pg:"):
			_go(int(id.substr(3)))
			return
		match id:
			"list_close":
				_sheet_id = ""
			"pg_prev":
				_go(_page - 1)
			"pg_next":
				_go(_page + 1)
		return
	match id:
		"close":
			closed.emit()
		"preview":
			_sheet_id = "list"
			_page = 1

func _input(event: InputEvent) -> void :
	if not _sheet_id.is_empty() and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_sheet_id = ""
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if _sheet_id == "list":
		match event.keycode:
			KEY_LEFT, KEY_PAGEUP:
				_go(_page - 1)
			KEY_RIGHT, KEY_PAGEDOWN:
				_go(_page + 1)
			_:
				return
	elif event.keycode == KEY_ESCAPE:
		closed.emit()
	else:
		return
	get_viewport().set_input_as_handled()
