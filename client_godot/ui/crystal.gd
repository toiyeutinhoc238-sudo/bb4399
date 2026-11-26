extends "flash_screen.gd"




















const CrystalModel = preload("crystal_model.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const TankPortrait = preload("tank_portrait.gd")
const Crystal = preload("crystal_atlas.gd")
const Atlas = preload("bag_atlas.gd")
const Arena = preload("arena_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Rule = preload("rule_atlas.gd")
const ItemTip = preload("item_tip.gd")
const TipAtlas = preload("item_tip_atlas.gd")
const FlaPlayer = preload("fla_player.gd")
const FlashScreen = preload("flash_screen.gd")
const RewardPopup = preload("reward_popup.gd")
const RewardFly = preload("reward_fly.gd")

signal closed
signal quick_buy_asked(tid: int)

const SCHEME_ITEM: int = 5600001
const GROCERY: int = 2

const MAIN_BOX: Vector2 = Vector2(954, 550)
const SELL_BOX: Vector2 = Vector2(676, 488)
const CONV_BOX: Vector2 = Vector2(900, 560)
const ADAPT: Vector2 = Vector2(1440, 900)
const MAKE_AT: Vector2 = Vector2(120, 50)
const TYPES: Array = [0, 2, 3, 4]
const ROWS: int = 7
const ROW_PITCH: float = 50.0
const NAME_PITCH: float = 68.0
const NAMES_SHOWN: int = 5
const NAME_CHARS: int = 6
const SELL_COLS: int = 5
const SELL_LINES: int = 2
const CONV_PAGE: int = 8
const ROMAN: Array = ["I", "II", "III", "IV", "V"]
const SELL_CHECKS: Array = [[45, 409], [120, 409], [195, 409], [45, 445], [120, 445]]
const SELL_MARKS: Array = ["_NewCrystalSellFrame_Text3", "_NewCrystalSellFrame_Text4", "_NewCrystalSellFrame_Text5", "_NewCrystalSellFrame_Text6", "_NewCrystalSellFrame_Text7"]
const WAIT: float = 8.0
const LOCK_INK: Color = Color("ff9c00")
const ATTR_INK: Color = Color("fefdfb")
const ATTR_RIM: Color = Color("0f578d")
const HEAD_INK: Color = Color("fefdfb")
const HINT_INK: Color = Color("0a3766")
const HEAD_WIDE: float = 150.0
const LABEL_INK: Color = Color("bdcde6")
const PITY_INK: Color = Color("59e695")
const TIME_INK: Color = Color("ffff00")
const ROW_INK: Color = Color("fefdfb")
const NONE_INK: Color = Color("ff0000")
const GLOW_INK: Color = Color("fcfc70", 0.55)
const TIP_620: String = "Thiếu tiền"




const TIP_WIDE: float = 252.0
const TIP_FILL: Color = Color("0a3766", 0.75)
const TIP_ICON: float = 100.0
const TIP_X: float = 110.0
const TIP_OPERATE: Color = Color("aaaaaa")
const TIP_OPEN: Color = Color("00ff00")
const TIP_SHUT: Color = Color("ff0000")

const TIP_KIND_INK: Dictionary = {1: Color("c350ff"), 2: Color("ff0000"), 3: Color("ffc600"), 4: Color("009dff")}
const TIP_KIND_NAME: Dictionary = {1: "Tử Thạch", 2: "Hồng Thạch", 3: "Ruby", 4: "Lam Thạch"}
const TIP_KIND_DESC: Dictionary = {1: "Tinh Thể A nhận thêm tăng ích thuộc tính.", 2: "Tinh Thể B thích hợp Công Vật Lý.", 
	3: "Tinh Thể C thích hợp phòng thủ.", 4: "Tinh Thể D thích hợp thuộc tính năng lượng."}
const TIP_WORDS: Dictionary = {"CRYSTAL_TYPE_DESC0": "Vào ô Mảnh Tinh Thế nhấp 1 @item@ để nhận tăng ích.", "CRYSTAL_TYPE_DESC5": "Loại:", 
	"CRYSTAL_TYPE_DESC6": "LV:", "CRYSTAL_TYPE_DESC7": "Hiệu quả:", "CRYSTAL_TYPE_DESC8": "Nhấp khảm/gỡ", "CRYSTAL_LEVEL": "Lv @num1@ mở"}
const RULE_MAKE: int = 17
const RULE_BG: Color = Color("1376ba")
const RULE_INK: Color = Color("bce0fe")
const RULE_RIM: Color = Color("005486")
const RULE_TITLE_H: float = 26.0






const FX_AT: Vector2 = Vector2(457, 59)
const FX_FPS: float = 24.0
const FX_SLOTS: Array = [[223, 134], [86.5, 208], [359.45, 206.8], [33.05, 335.95], [427.5, 335.05]]
const FX_SLOT_FRAME: Array = [64, 70, 72, 76, 80]
const FX_DONE: int = 110
const FX_SKIP: int = 63
const FX_ICON: float = 0.75
const FX_OK: Vector2 = Vector2(683.5, 478)
const FX_KEY: String = "crm/make"
const FX_Q4: String = "crm/q4"
const FX_Q5: String = "crm/q5"
const FX_NAMES: Array = ["cvs_tubiao01", "cvs_tubiao02", "cvs_tubiao03", "cvs_tubiao04", "cvs_tubiao05"]
const FX_GIVE_UP: float = 15.0
const SETTLE_CRYSTAL_MAKE: int = 19
const OPEN_FX: float = 0.5

var _scheme: int = 0
var _tmp: Array = []
var _base: Array = []
var _state: String = ""
var _type: int = 0
var _scroll: int = 0
var _strip: int = 0
var _rmd_lv: int = 3
var _have: Dictionary = {}
var _list: Array = []
var _rmd: Array = []
var _sheet_id: String = ""
var _layer: String = ""
var _back_to: String = ""
var _ask_kind: String = ""
var _ask_to: int = 0
var _sell_list: Array = []
var _sell_pick: Dictionary = {}
var _sell_levels: Array = [false, false, false, false, false]
var _sell_scroll: int = 0
var _conv_levels: Array = [true, true, true, true, true]
var _conv_page: int = 1
var _conv_list: Array = []
var _make_at: float = -10.0
var _conv_at: float = -10.0
var _reward: Array = []
var _popup: RefCounted = RewardPopup.new()
var _flies: Array = []
var _name: LineEdit
var _name_prev: String = ""
var _renaming: bool = false
var _focus: LineEdit
var _pending: Dictionary = {}
var _data_failed: bool = false
var _bag_failed: bool = false
var _rev: int = -1
var _crev: int = -1
var _tip: Array = []
var _rule: int = 0
var _save_rect: Rect2 = Rect2()
var _make_open_at: float = -10.0
var _fx_at: float = -10.0
var _fx_items: Array = []
var _fx_tip: int = 0
var _fx: FlaPlayer = null
var _fx_top: FlashScreen = null
var _fx_done: bool = false
var _fx_ok: Vector2 = Vector2.ZERO
var _fx_scale: Vector2 = Vector2(1, 1)
var for_pick: bool = false
var pick_tank: Dictionary = {}
var pick_scheme: int = 0
const PICK_BLOCKED: String = "Đang chọn tank: mục này chỉ mở ở sảnh."

func chat_busy() -> bool:
	return true

func _setup() -> void :
	_name = _fedit(0)
	_name.text_changed.connect( func(value: String) -> void :
		var kept: String = max_chars(_name_prev, value, NAME_CHARS)
		if kept != value:
			var caret: int = _name.caret_column - (value.length() - kept.length())
			_name.text = kept
			_name.caret_column = clampi(caret, 0, kept.length())
		_name_prev = kept)
	_name.text_submitted.connect( func(_text: String) -> void : _commit_name())
	_name.focus_exited.connect( func() -> void :
		if _renaming and is_visible_in_tree():
			_commit_name())
	pack.picture_ready.connect( func(path: String) -> void :
		if path == "l/crystal.json":
			_data_failed = pack.crystal.is_empty()
			_rev = -1
		elif path == "l/bag.json":
			_bag_failed = pack.bag.is_empty()
			_rev = -1)
	client.noticed.connect( func(text: String) -> void :
		if is_visible_in_tree():

			if str(_pending.get("op", "")) == "make":
				_pending.told = true
			else:
				_pending = {}
			say(text))
	client.crystal_result.connect(_on_result)
	client.awarded.connect(_on_award)
	var guide_view: Control = preload("guide_view.gd").new()
	guide_view.setup(self, "crystal")
	add_child(guide_view)

func _shown() -> void :
	if _name == null:
		return
	_renaming = false
	_close()
	if not is_visible_in_tree():
		return
	pack.load_crystal()
	pack.load_crystalx()
	pack.load_bag()
	if not client.bag_loaded:
		client.request_bags()
	elif not client.crystal_loaded:
		client.crystal_request()
	_data_failed = false
	_bag_failed = false
	_pending = {}
	_scheme = 0
	_tmp = CrystalModel.empty_page()
	_base = _tmp.duplicate()
	_state = ""
	_type = 0
	_scroll = 0
	_strip = 0
	_rmd_lv = 3
	_back_to = ""
	_reward = []
	_popup.reset()
	_flies = []
	RewardFly.reset(self)
	_tip = []
	_rev = -1
	_crev = -1

func _tick(_delta: float) -> void :
	if _popup.tick(self) and _sheet_id == "award":
		_finish()
	_tick_pending()
	_fx_fetch()
	if _rev == client.bag_rev and _crev == client.crystal_rev:
		return
	var clean: bool = _tmp == _base
	_rev = client.bag_rev
	_crev = client.crystal_rev
	_have = CrystalModel.owned(client.bags)
	_preload()
	if not client.crystal_loaded:
		return
	if _scheme == 0:

		_scheme = pick_scheme if for_pick and pick_scheme > 0 else maxi(1, int(_tank().get("m_crystalSchemeId", 0)))
		var ids: Array = _ids()
		_strip = clampi(ids.find(_scheme) - (NAMES_SHOWN - 1), 0, maxi(0, ids.size() + 1 - NAMES_SHOWN))
		clean = true
	if clean:
		_tmp = _server(_scheme).duplicate()
		_base = _tmp.duplicate()
	if _sheet_id == "sell":
		_build_sell()

func _tick_pending() -> void :
	if _pending.is_empty():
		return
	var op: String = str(_pending.op)
	if op == "settle":

		if client.bag_rev != int(_pending.rev) or _time - float(_pending.at) > 1.5:
			_pending = {}
		return
	if op == "make" and float(_pending.answered) >= 0.0:
		var gained: Array = _gained(_pending.before)
		if not gained.is_empty():
			if float(_pending.seen) < 0.0:
				_pending.seen = _time
			elif _time - float(_pending.seen) > 0.25:
				var award: Array = _pending.get("award", [])
				var entries: Array = award if not award.is_empty() else _gained_ids(_pending.before)
				_pending = {}
				_back_to = "make" if _sheet_id == "make" else ""
				_close()
				_reward = gained
				_fx_items = fx_pick(entries, int(pack.crystal.get("piece", 8000024)), func() -> float: return randf())
				_fx_at = _time
				_sheet_id = "reward"
				_fx_start()
			return
		if _time - float(_pending.answered) > 1.5:
			var told: bool = bool(_pending.get("told", false))
			_pending = {}
			if not told:
				say("Chưa chế tạo được: không đủ tiền hoặc chưa tới lượt miễn phí.")
			return
	if _time - float(_pending.at) > WAIT:
		_pending = {}
		say("Máy chủ chưa phản hồi, thử lại sau.")

func _loading() -> bool:
	return (pack.crystal.is_empty() and not _data_failed) or (pack.bag.is_empty() and not _bag_failed) or not client.bag_loaded or not client.crystal_loaded



func _server(page: int) -> Array:
	var value: Variant = client.crystal_schemes.get(page)
	return value if value is Array and value.size() == CrystalModel.SLOTS else CrystalModel.empty_page()

func _level() -> int:
	return int(client.character.get("level", 1))


func _tank() -> Dictionary:
	return pick_tank if for_pick and not pick_tank.is_empty() else client.current_tank()


func open_for(tank: Dictionary, scheme: int) -> void :
	for_pick = true
	pick_tank = tank.duplicate()
	pick_scheme = scheme
	if visible:
		_shown()
	else:
		visible = true

func _tank_name() -> String:
	var tank: Dictionary = _tank()
	if tank.is_empty():
		return ""
	return GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(int(tank.get("m_tpltId", 0))), "Xe chủ chiến")))

func _preload() -> void :
	if pack.bag.is_empty():
		return
	var ids: Dictionary = _have.duplicate()
	for slots: Variant in client.crystal_schemes.values():
		if slots is Array:
			for item: Variant in slots:
				ids[int(item)] = 1
	for item: int in ids:
		var path: String = _icon(item)
		if item > 0 and not path.is_empty():
			pack.picture(path)

func _icon(item: int) -> String:
	var more: Array = pack.bag.get("more", {}).get(str(item), [])
	return "l/it/%s.webp" % str(more[1]) if more.size() >= 2 and not str(more[1]).is_empty() else ""


func _fx_fetch() -> void :
	for key: String in [FX_KEY, FX_Q4, FX_Q5]:
		if pack.effect_cached(key).is_empty() and not pack.effect_failed(key):
			pack.effect(key)


func _fx_start() -> void :
	_fx_stop()
	_fx_done = false
	var make: Dictionary = pack.effect_cached(FX_KEY)
	if make.is_empty() or not FlaPlayer.valid(make.get("data")):
		return
	var player: FlaPlayer = FlaPlayer.new()
	if player.add_clip(make, "label01" if _fx_items.size() > 1 else "label02") < 0:
		player.free()
		return
	player.event.connect(_fx_event)
	var top: FlashScreen = FlashScreen.new()
	top.mouse_filter = MOUSE_FILTER_IGNORE
	top.draw.connect(_fx_paint)
	_fx = player
	_fx_top = top
	add_child(player)
	add_child(top)
	move_child(player, 0)
	move_child(top, 1)

func _fx_stop() -> void :
	for node: Node in [_fx, _fx_top]:
		if node != null:
			if node.get_parent() == self:
				remove_child(node)
			node.queue_free()
	_fx = null
	_fx_top = null



func _fx_event(name: String) -> void :
	if name != "mc_complete" or _fx == null or _fx_done:
		return
	_fx_done = true
	for i in range(mini(_fx_items.size(), FX_NAMES.size())):
		var level: int = CrystalModel.level(pack.crystal, int(_fx_items[i]))
		var spot: Variant = _fx.named.get(FX_NAMES[i])
		if level < 4 or spot == null:
			continue
		var quality: Dictionary = pack.effect_cached(FX_Q4 if level == 4 else FX_Q5)
		if not quality.is_empty():
			_fx.add_clip(quality, "", Transform2D(0.0, (spot.xf as Transform2D).origin))


func _fx_finished() -> bool:
	if _fx != null:
		return _fx_done or _time - _fx_at >= FX_GIVE_UP
	return fx_frame(_time - _fx_at) >= FX_DONE


func _fx_paint() -> void :
	if _fx_top == null or _sheet_id != "reward":
		return
	_fx_top._cells = _cells
	_fx_top._hover = _hover
	_fx_top._press = _press
	_fx_top._fw = _fw
	_fx_top._fh = _fh
	if _fx_finished():
		_fx_top._u = _fx_scale.x
		_fx_top._f = _fx_scale.y
		_fx_top._fblit("crystal_ok", _fx_ok, 0.0, 0.0, _fx_top._glow("reward:ok"))
	if _fx_tip > 0:
		_fx_top._u = _u
		_fx_top._f = _f
		_draw_item_tip(_fx_tip, _fx_top)

func _pic(item: int) -> Texture2D:
	var path: String = _icon(item)
	return null if path.is_empty() else pack.picture(path)

func _gained(before: Dictionary) -> Array:
	var now: Dictionary = CrystalModel.owned(client.bags)
	var ids: Array = []
	for item: int in now:
		if int(now[item]) > int(before.get(item, 0)):
			ids.append(item)
	ids.sort_custom( func(a: int, b: int) -> bool:
		if CrystalModel.level(pack.crystal, a) != CrystalModel.level(pack.crystal, b):
			return CrystalModel.level(pack.crystal, a) > CrystalModel.level(pack.crystal, b)
		return a < b)
	var out: Array = []
	for item: int in ids:
		out.append([CrystalModel.title(pack.crystal, item), int(now[item]) - int(before.get(item, 0)), _icon(item)])
	return out


func _gained_ids(before: Dictionary) -> Array:
	var now: Dictionary = CrystalModel.owned(client.bags)
	var out: Array = []
	for item: int in now:
		if int(now[item]) > int(before.get(item, 0)):
			out.append([item, int(now[item]) - int(before.get(item, 0))])
	return out

func _wait(op: String, extra: Dictionary = {}) -> void :
	_pending = {"op": op, "at": _time}
	_pending.merge(extra)


func _ids() -> Array:
	var seen: Dictionary = {}
	for key: Variant in client.crystal_names.keys():
		if int(key) > 0:
			seen[int(key)] = true
	for key: Variant in client.crystal_schemes.keys():
		if int(key) > 0:
			seen[int(key)] = true
	if _scheme > 0:
		seen[_scheme] = true
	var out: Array = seen.keys()
	out.sort()
	return out if not out.is_empty() else [1]


func _scheme_name(id: int) -> String:
	var custom: String = str(client.crystal_names.get(id, "")).strip_edges()
	if not custom.is_empty():
		return custom
	if id == 1:
		return "DPS"
	if id == 2:
		return "Sinh Tồn"
	return "Tùy chỉnh %d" % id

func _dirty() -> bool:
	return _tmp != _base

func _spare(item: int) -> int:
	return int(_have.get(item, 0)) - int(CrystalModel.used(_tmp).get(item, 0))


func _rows() -> Array:
	var used: Dictionary = CrystalModel.used(_tmp)
	var out: Array = []
	for item: int in _have:
		var k: int = CrystalModel.kind(pack.crystal, item)
		if k <= 0 or int(_have[item]) - int(used.get(item, 0)) <= 0:
			continue
		if _type != 0 and k != _type:
			continue
		out.append(item)
	out.sort_custom( func(a: int, b: int) -> bool:
		var ka: int = CrystalModel.kind(pack.crystal, a)
		var kb: int = CrystalModel.kind(pack.crystal, b)
		if ka != kb:
			return ka < kb
		var la: int = CrystalModel.level(pack.crystal, a)
		var lb: int = CrystalModel.level(pack.crystal, b)
		if la != lb:
			return la > lb
		return a < b)
	return out


func _val(attr: Array) -> String:
	var value: float = float(attr[2])
	var text: String = ""
	if int(attr[1]) == 2:
		text = ("%.1f" % absf(value * 100.0)).trim_suffix(".0") + "%"
	else:
		text = CrystalModel.number(value)
	return ("-" if value < 0.0 else "+") + text

func _desc(item: int) -> Array:
	var out: Array = []
	for attr: Array in CrystalModel.attrs(pack.crystal, item):
		out.append(_val(attr) + " " + CrystalModel.attr_name(pack.crystal, attr))
	if out.is_empty():
		out.append(GarageModel.cap(CrystalModel.title(pack.crystal, item)))
	return out

func _attr_lines() -> Array:
	var out: Array = []
	for row: Array in CrystalModel.totals(pack.crystal, _tmp):
		out.append("%s: %s" % [CrystalModel.attr_name(pack.crystal, row), _val(row)])
	return out


func _can_add(slots: Array) -> bool:
	var lv: int = _level()
	var open: Dictionary = {}
	for i in range(mini(slots.size(), CrystalModel.SLOTS)):
		if int(slots[i]) <= 0 and CrystalModel.slot_level(pack.crystal, i) <= lv:
			open[CrystalModel.slot_kind(pack.crystal, i)] = true
	if open.is_empty():
		return false
	var used: Dictionary = CrystalModel.used(slots)
	for item: int in _have:
		if int(_have[item]) - int(used.get(item, 0)) > 0 and open.has(CrystalModel.kind(pack.crystal, item)) and CrystalModel.need_level(pack.crystal, item) <= lv:
			return true
	return false


func _chips() -> int:
	var piece: int = int(pack.crystal.get("piece", 8000024))
	var total: int = 0
	for cont: Variant in client.bags.values():
		if cont is Array:
			for inst: Variant in cont:
				if inst is Dictionary and int(inst.get("m_templateId", 0)) == piece:
					total += maxi(1, int(inst.get("m_count", 1)))
	return total

func _adapt() -> float:
	return minf(1.0, minf(_fw / ADAPT.x, _fh / ADAPT.y))

func _v(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _free_now() -> bool:
	return int(Time.get_unix_time_from_system()) >= client.crystal_free_at


func _pity(limit: int, gift: bool) -> String:
	var turn: int = int(client.limits.get(limit, 0)) + 1
	if turn % 5 == 0:
		return "Chế tạo ra Tinh Thể Lv2~3" if gift else "Chế tạo ra Tinh Thể Lv4~5"
	var n: int = 5 - turn % 5 + 1
	return ("Chế tạo lại %d lần, sẽ có Tinh Thể Lv2~3" if gift else "Chế tạo %d lần, sẽ có Tinh Thể Lv4~5") % n

func _clock(seconds: int) -> String:
	return "%02d:%02d:%02d" % [floori(seconds / 3600.0), floori((seconds % 3600) / 60.0), seconds % 60]



func _on_result(op: String, ok: bool) -> void :
	if _pending.is_empty() or not is_visible_in_tree():
		return
	var mine: String = str(_pending.op)
	if mine == "save" and op == "schemes":
		var page: int = int(_pending.page)
		var kept: bool = client.crystal_schemes.has(page) and client.crystal_schemes[page] == _pending.slots
		_pending = {}
		if page == _scheme:
			_tmp = _server(page).duplicate()
			_base = _tmp.duplicate()
		say("Đã lưu Bảng Tinh Thể" if kept else "Máy chủ không nhận nhóm này, đã trả về bản cũ.")
	elif mine == "rename" and op == "rename":
		_pending = {}
		say("Đã lưu tên" if ok else "Không đổi được tên nhóm.")
	elif mine == "forge" and op == "forge":
		var ask: Dictionary = _pending
		if not ok:
			_pending = {}
			say("Máy chủ từ chối, chưa có gì thay đổi.")
			return
		say("Đã bán %d viên, nhận %d mảnh chip." % [int(ask.n), int(ask.gain)])

		client.request_bags()
		_pending = {"op": "settle", "at": _time, "rev": int(ask.rev)}
	elif mine == "make" and op == "make":
		_pending.answered = _time


func _on_award(info: Dictionary) -> void :
	if is_visible_in_tree() and str(_pending.get("op", "")) == "make" and client.award_op == SETTLE_CRYSTAL_MAKE:
		_pending.award = info.get("items", []).duplicate(true)
	if not is_visible_in_tree() or str(_pending.get("op", "")) == "make" or _sheet_id == "reward":
		return
	if not RewardPopup.has_rewards(info):
		return
	if _popup.active and _popup.closing_at >= 0.0:
		_flies.append_array(RewardFly.begin(self, _popup.info))
		_popup.reset()
	if _sheet_id != "award":
		_back_to = _sheet_id if _sheet_id in ["sell", "convert", "make"] else ""
		_close()
		_popup.reset()
	_popup.begin(self, info)
	_sheet_id = "award"




func guide_open(ui: String) -> bool:
	return ui == "crystalWindow" and _sheet_id.is_empty() and _rule == 0 and not _loading()


func guide_close(_ui: String) -> void :
	_close()
	closed.emit()


func guide_spot(id: String) -> Rect2:
	return _save_rect if id == "save" else Rect2()



func _close() -> void :
	_fx_stop()
	_sheet_id = ""
	_rule = 0
	_focus = null
	_hide_edits()


func _award_close() -> void :
	_popup.request_close(self)
	_finish()

func _finish() -> void :
	var back: String = _back_to
	_close()
	_back_to = ""
	_reward = []
	_fx_items = []
	_fx_tip = 0
	if back == "sell":
		_build_sell()
	if back in ["sell", "convert", "make"]:
		_sheet_id = back

func _switch(id: int) -> void :
	_scheme = id
	_tmp = _server(id).duplicate()
	_base = _tmp.duplicate()

func _pick_scheme(id: int) -> void :
	if id <= 0 or id == _scheme:
		return
	if _dirty():
		_ask("switch", id)
	else:
		_switch(id)

func _ask(kind: String, to: int = 0) -> void :
	_close()
	_ask_kind = kind
	_ask_to = to
	_sheet_id = "ask"

func _answer(yes: bool) -> void :
	var kind: String = _ask_kind
	var to: int = _ask_to
	_close()
	match kind:
		"switch":
			if yes:
				_switch(to)
		"tank":
			if yes:
				page_asked.emit("tank")
		"leave":
			if yes:
				_save()
			closed.emit()

func _leave() -> void :
	if _dirty() and not _loading():
		_ask("leave")
	else:
		closed.emit()



func _quick_buy(tid: int) -> void :
	if for_pick:
		say(PICK_BLOCKED)
	else:
		quick_buy_asked.emit(tid)



func _try_add(item: int) -> void :
	var i: int = _free_slot(item)
	while i >= 0:
		_tmp[i] = item
		if _spare(item) <= 0:
			break
		i = _free_slot(item, true)




func _free_slot(item: int, quiet: bool = false) -> int:
	var need: int = 30 if CrystalModel.row(pack.crystal, item).is_empty() else CrystalModel.need_level(pack.crystal, item)
	var lv: int = _level()
	if need > lv:
		if not quiet:
			say("Nhân vật lv%d mở" % need)
		return -1
	var k: int = CrystalModel.kind(pack.crystal, item)
	for i in range(mini(_tmp.size(), CrystalModel.SLOTS)):
		var held: int = int(_tmp[i])
		if CrystalModel.slot_kind(pack.crystal, i) != k or (held > 0 and not CrystalModel.row(pack.crystal, held).is_empty()):
			continue
		if CrystalModel.slot_level(pack.crystal, i) > lv:
			break
		return i
	if not quiet:
		say("Hết Tinh Thể được đặt vào")
	return -1


func _scheme_card_slot() -> int:
	for inst: Variant in client.bags.get(GROCERY, []):
		if inst is Dictionary and int(inst.get("m_templateId", 0)) == SCHEME_ITEM:
			return int(inst.get("m_slotNo", -1))
	return -1

func _save() -> void :
	if not _dirty():
		return
	if not _pending.is_empty():
		say("Đang chờ máy chủ…")
		return
	if client.crystal_save(_scheme, _tmp):
		_wait("save", {"page": _scheme, "slots": _tmp.duplicate()})
	else:
		say("Chưa lưu được lúc này.")

func _rename() -> void :
	if _renaming:
		return
	if not client.crystal_schemes.has(_scheme):
		say("Lưu nhóm Tinh Thể này trước rồi mới đổi tên.")
		return
	_renaming = true
	_name.text = _scheme_name(_scheme)
	_name_prev = _name.text
	_focus = _name



static func max_chars(prev: String, value: String, limit: int) -> String:
	if value.length() <= limit:
		return value
	var head: int = 0
	while head < prev.length() and head < value.length() and prev[head] == value[head]:
		head += 1
	var tail: int = 0
	while tail < prev.length() - head and tail < value.length() - head\
	and prev[prev.length() - 1 - tail] == value[value.length() - 1 - tail]:
		tail += 1
	var added: String = value.substr(head, value.length() - head - tail)
	return value.left(head) + added.left(maxi(0, limit - head - tail)) + value.right(tail)

func _commit_name() -> void :
	if not _renaming:
		return
	_renaming = false
	var old: String = _scheme_name(_scheme)
	var text: String = _name.text
	_name.text = old
	if _name.has_focus():
		_name.release_focus()
	if text == old:
		return
	text = text.replace(" ", "")
	if not text.is_empty():
		for key: Variant in client.crystal_names.keys():
			if int(key) != _scheme and str(client.crystal_names[key]).strip_edges() == text:
				say("Đã có nhóm Tinh Thể cùng tên")
				return
	if not _pending.is_empty():
		say("Đang chờ máy chủ…")
		return
	if client.crystal_rename(_scheme, text):
		_wait("rename")
	else:
		say("Không đổi được tên nhóm.")


func _open_sell() -> void :
	_close()
	_tmp = _server(_scheme).duplicate()
	_base = _tmp.duplicate()
	_build_sell()
	_sheet_id = "sell"

func _build_sell() -> void :
	var pages: Array = []
	for slots: Variant in client.crystal_schemes.values():
		if slots is Array:
			pages.append(slots)
	var held: Dictionary = CrystalModel.held(pages)
	var out: Array = []
	for item: int in _have:
		if CrystalModel.row(pack.crystal, item).is_empty():
			continue
		for _n in range(int(_have[item]) - int(held.get(item, 0))):
			out.append(item)
	out.sort_custom( func(a: int, b: int) -> bool:
		var la: int = CrystalModel.level(pack.crystal, a)
		var lb: int = CrystalModel.level(pack.crystal, b)
		if la != lb:
			return la < lb
		var ka: int = CrystalModel.kind(pack.crystal, a)
		var kb: int = CrystalModel.kind(pack.crystal, b)
		if ka != kb:
			return ka < kb
		return a < b)
	_sell_list = out
	_sell_pick = {}
	_sell_levels = [false, false, false, false, false]
	_sell_scroll = 0

func _sell_lines() -> int:
	return ceili(_sell_list.size() / float(SELL_COLS))

func _sell_total() -> int:
	var total: int = 0
	for index: int in _sell_pick:
		if index < _sell_list.size():
			total += CrystalModel.pieces(pack.crystal, int(_sell_list[index]))
	return total


func _sell_level(lv: int) -> void :
	if lv < 0 or lv >= 5:
		return
	_sell_levels[lv] = not bool(_sell_levels[lv])
	_sell_pick = {}
	for index in range(_sell_list.size()):
		var level: int = CrystalModel.level(pack.crystal, int(_sell_list[index]))
		if level >= 1 and level <= 5 and bool(_sell_levels[level - 1]):
			_sell_pick[index] = true

func _sell() -> void :
	if _sell_pick.is_empty():
		say("Hãy chọn Tinh Thể cần bán.")
		return
	if not _pending.is_empty():
		say("Đang chờ máy chủ…")
		return
	var picks: Array = _sell_pick.keys()
	picks.sort()
	var ids: Array = []
	var gain: int = 0
	for index: int in picks:
		if index < _sell_list.size() and ids.size() < CrystalModel.FORGE_CAP:
			ids.append(int(_sell_list[index]))
			gain += CrystalModel.pieces(pack.crystal, int(_sell_list[index]))
	if ids.is_empty():
		return
	if client.crystal_forge(true, ids):
		_wait("forge", {"sell": true, "n": ids.size(), "gain": gain, "rev": client.bag_rev})
	else:
		say("Chưa thao tác được lúc này.")


func _open_convert() -> void :
	_close()
	pack.load_crystalx()
	_conv_levels = [true, true, true, true, true]
	_conv_page = 1
	_sheet_id = "convert"

func _conv_rows() -> Array:
	var out: Array = []
	for row: Variant in pack.crystalx.get("convert", []):
		if not (row is Array and row.size() >= 6):
			continue
		var lv: int = CrystalModel.level(pack.crystal, int(row[1]))
		if lv >= 1 and lv <= 5 and not bool(_conv_levels[lv - 1]):
			continue
		out.append(row)
	return out

func _conv_pages() -> int:
	return maxi(1, ceili(_conv_list.size() / float(CONV_PAGE)))

func _convert(index: int) -> void :
	if index < 0 or index >= _conv_list.size():
		return
	var row: Array = _conv_list[index]
	if _chips() < int(row[4]):
		say("Thiếu mảnh chip, không thể đổi")
		return
	if _time - _conv_at < 1.0:
		return
	if client.convert_item(int(row[0]), 1):
		_conv_at = _time
	else:
		say("Chưa đổi được, thử lại sau.")

func _open_make() -> void :
	_close()
	_sheet_id = "make"
	_make_open_at = _time


func _make(kind: int) -> void :
	if not kind in [2, 3, 4, 5, 6] or _time - _make_at < 1.5:
		return
	if not _pending.is_empty():
		say("Đang chờ máy chủ…")
		return
	var cost: Array = CrystalModel.make_cost(pack.crystal, kind)
	if kind in CrystalModel.MAKE_GIFT and int(client.currency.get("m_iSilver", 0)) < int(cost[1]):
		say("Xu Khóa không đủ, chế tạo thất bại")
		return
	if kind in CrystalModel.MAKE_CASH and int(client.currency.get("m_iCash", 0)) < int(cost[1]):
		say("Xu không đủ, chế tạo thất bại")
		return
	if kind == CrystalModel.MAKE_FREE and not _free_now():
		return
	if client.crystal_make(kind):
		_make_at = _time
		_wait("make", {"kind": kind, "before": CrystalModel.owned(client.bags), "answered": -1.0, "seen": -1.0})
	else:
		say("Chưa thao tác được lúc này.")





func _label(spec: Array, text: String, o: Vector2, tint: Color = Color(0, 0, 0, 0), mid: bool = false, edge: float = 1.0) -> void :
	var wide: float = float(spec[2])
	var left: float = float(spec[0])
	var align: String = str(spec[7])
	if wide <= 0.0:
		wide = 600.0
		if align == "c":
			left -= 300.0
		elif align == "r":
			left -= 600.0
	var top: float = float(spec[1]) - (12.0 if mid else 0.0)
	var ink: Color = Color(str(spec[5])) if tint.a <= 0.0 else tint
	_fwords(text, BOLD if int(spec[6]) == 1 else REGULAR, float(spec[4]), ink, align, o + Vector2(left, top), wide, edge, 24.0 if mid else 0.0, float(spec[2]) > 0.0)


func _digits(value: int, at: Vector2, row: int = 0) -> void :
	var text: String = str(maxi(0, value))
	for i in range(text.length()):
		_fpart("number", Vector2(at.x - 10.0 * (text.length() - i), at.y), Rect2(10.0 * int(text[i]), 14.0 * row, 10, 14))


func _draw_token(at: Vector2) -> void :
	_fblit("crystal_piece", at + Vector2(4, 2))
	_digits(_chips(), at + Vector2(92, 8))
	_fbutton("token:plus", "public_button_num_plus", at + Vector2(96, 2.5))

func _hexagon(c: Vector2, r: float, ink: Color) -> void :
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(6):
		var angle: float = PI / 6.0 + i * PI / 3.0
		points.append((c + Vector2(cos(angle), sin(angle)) * r) * _f)
	draw_colored_polygon(points, ink)

func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0, alpha: float = 1.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false, Color(1, 1, 1, alpha))




static func socket_icon(picture_size: Vector2, at: Vector2) -> Array:
	var k: float = minf(52.0 / picture_size.x, 60.0 / picture_size.y)
	var mask: PackedVector2Array = PackedVector2Array()
	for i in range(6):
		mask.append(at + Vector2(26, 30) + Vector2.UP.rotated(TAU / 6.0 * i) * 27.0)
	return [Rect2(at + Vector2(1, 3), picture_size * k), mask]

func _socket_icon(picture: Texture2D, at: Vector2) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var spot: Array = socket_icon(Vector2(picture.get_size()), at)
	var mask: PackedVector2Array = PackedVector2Array()
	for p: Vector2 in spot[1]:
		mask.append(p * _f)
	var rect: Rect2 = spot[0]
	TankPortrait._cut(self, picture, Rect2(rect.position * _f, rect.size * _f), Rect2(Vector2.ZERO, picture.get_size()), Rect2(), mask)


func _peek(item: int, rect: Rect2, index: int = -1) -> void :
	if _layer != _sheet_id or not _press.is_empty() or not rect.has_point(get_local_mouse_position()):
		return
	if item > 0 and CrystalModel.row(pack.crystal, item).is_empty():
		return
	_tip = [rect, item, index]



static func tip_layout(data: Dictionary, item: int, index: int, player_level: int, val: Callable) -> Dictionary:
	var ops: Array = []
	var y: float = 10.0
	if item > 0:
		var k: int = CrystalModel.kind(data, item)
		ops.append(["icon", Rect2(5, 0, TIP_ICON, TIP_ICON)])
		ops.append(["label", str(TIP_WORDS.CRYSTAL_TYPE_DESC5) + str(TIP_KIND_NAME.get(k, "")), Vector2(TIP_X, y), TIP_KIND_INK.get(k, Color.WHITE)])
		y += 16.0
		var lv: int = CrystalModel.level(data, item)
		ops.append(["label", str(TIP_WORDS.CRYSTAL_TYPE_DESC6) + (str(ROMAN[lv - 1]) if lv >= 1 and lv <= ROMAN.size() else ""), Vector2(TIP_X, y), Color.WHITE])
		y += 16.0

		var attrs: PackedStringArray = PackedStringArray()
		for attr: Array in CrystalModel.attrs(data, item):
			attrs.append(str(val.call(attr)) + " " + str(data.get("attrs", {}).get(str(int(attr[0])), "")))
		ops.append(["para", str(TIP_WORDS.CRYSTAL_TYPE_DESC7) + "\n".join(attrs), Vector2(TIP_X, y), TIP_WIDE - TIP_X])
		y += 32.0
		ops.append(["label", str(TIP_WORDS.CRYSTAL_TYPE_DESC8), Vector2(TIP_X, y), TIP_OPERATE])
		y += 16.0
	else:
		var k: int = CrystalModel.slot_kind(data, index)
		var need: int = CrystalModel.slot_level(data, index)
		var kind_name: String = str(TIP_KIND_NAME.get(k, ""))
		ops.append(["label", kind_name, Vector2(5, y), TIP_KIND_INK.get(k, Color.WHITE)])
		ops.append(["label", str(TIP_WORDS.CRYSTAL_TYPE_DESC0).replace("@item@", kind_name), Vector2(5, y + 16.0), Color.WHITE])
		ops.append(["label", str(TIP_KIND_DESC.get(k, "")), Vector2(5, y + 32.0), Color.WHITE])
		ops.append(["label", str(TIP_WORDS.CRYSTAL_LEVEL).replace("@num1@", str(need)), Vector2(5, y + 48.0), TIP_SHUT if need > player_level else TIP_OPEN])
		y += 64.0
	return {"high": y + 16.0, "ops": ops}

func _draw_tip() -> void :
	if _tip.is_empty():
		return
	var item: int = int(_tip[1])
	var tip: Dictionary = tip_layout(pack.crystal, item, int(_tip[2]), _level(), _val)
	var size: Vector2 = Vector2(TIP_WIDE, float(tip.high))
	var at: Vector2 = ItemTip.place(get_local_mouse_position() / _f, size, Vector2(_fw, _fh))
	_round(Rect2(at * _f, size * _f), TIP_FILL, 12.0)
	for op: Array in tip.ops:
		match str(op[0]):
			"icon":
				var box: Rect2 = op[1]
				var picture: Texture2D = _pic(item)
				if picture != null and picture.get_width() > 4:
					var k: float = minf(box.size.x / picture.get_width(), box.size.y / picture.get_height())
					draw_texture_rect(picture, Rect2((at + box.position) * _f, Vector2(picture.get_size()) * k * _f), false)
			"label":

				_fwords(str(op[1]), REGULAR, 12.0, op[3], "l", at + op[2], 400.0, 0.0, 0.0, false)
			"para":
				_fpara(str(op[1]), REGULAR, 12.0, Color.WHITE, at + op[2] + Vector2(2, 0), float(op[3]) - 4.0)

func _shade(wide: float, high: float) -> Vector2:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(wide, high)
	_hit("panel", Rect2(at * _f, Vector2(wide, high) * _f), false)
	return at


func _draw_bar(prefix: String, at: Vector2, high: float, first: int, shown: int, total: int, apply: Callable) -> void :
	if total <= shown:
		return
	_fbutton(prefix + ":up", "bag_sb_up", at)
	_fbutton(prefix + ":down", "bag_sb_down", at + Vector2(0, high - 19.0))
	var track: float = high - 38.0
	_fblit("bag_sb_bk", at + Vector2(0, 19), 0.0, track)
	var thumb: float = maxf(20.0, track * shown / float(total))
	var top: float = (track - thumb) * first / float(total - shown)
	var knob: Rect2 = _fblit("bag_sb_block", at + Vector2(0, 19.0 + top), 0.0, thumb, _glow("slide:" + prefix))
	_knob_hit("slide:" + prefix, knob, first, total - shown, (track - thumb) * _f, apply)



func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Hall.FILE, Hall.R)
		_use(Atlas.FILE, Atlas.R)
		_use(Crystal.FILE, Crystal.R)
		_use(Rule.FILE, Rule.R)
		_use(TipAtlas.FILE, TipAtlas.R)
	_tip = []
	_layer = "rule" if _rule > 0 else ""
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(MAIN_BOX.x, MAIN_BOX.y)
	_hit("panel", Rect2(base * _f, MAIN_BOX * _f), false)
	_draw_main(base)
	if _sheet_id.is_empty() and not _loading() and not _data_failed and not _bag_failed:
		var want: String = _scheme_name(_scheme)
		if not _renaming and _name.text != want:
			_name.text = want
		_fput(_name, Rect2(base + Vector2(16, 78), Vector2(198, 30)), 14.0, "l", _renaming)
	else:
		_hide_edits()
	_layer = "rule" if _rule > 0 else _sheet_id
	match _sheet_id:
		"ask":
			_draw_ask()
		"sell":
			_draw_sell()
			_draw_tip()
		"convert":
			_draw_convert()
			_draw_tip()
		"make":
			_draw_make()
		"reward":
			if _back_to == "make":
				_draw_make()
			_draw_reward()
		"award":
			pass
		_:
			_draw_tip()
	if _rule > 0:
		_draw_rule()
	_popup.paint(self)
	_flies = RewardFly.paint(self, _flies)
	if _focus != null and _focus.visible:
		_focus.grab_focus.call_deferred()
		_focus.select_all.call_deferred()
		_focus = null

func _draw_main(base: Vector2) -> void :
	_save_rect = Rect2()
	_fblit("crystal_frame", base + Vector2(-8, -18))
	_fbutton("close", "crystal_close", base + Vector2(925, -5))
	_fbutton("tab:set", "crystal_set_on" if _state.is_empty() else "crystal_set", base + Vector2(10, 37))
	_fbutton("tab:rmd", "crystal_rmd_on" if _state == "recommend" else "crystal_rmd", base + Vector2(88, 37))
	_fblit("crystal_input", base + Vector2(10, 78))
	if _renaming:
		_fblit("crystal_rename_off", base + Vector2(217, 78))
	else:
		_fbutton("rename", "crystal_rename", base + Vector2(217, 78))
	_fbutton("open:convert", "crystal_convert", base + Vector2(16, 502))
	_fbutton("open:sell", "crystal_sell", base + Vector2(98, 502))
	_fbutton("open:make", "crystal_make", base + Vector2(180, 502))
	_draw_token(base + Vector2(270, 501))
	if _data_failed or _bag_failed:
		_fwords("Không tải được dữ liệu Tinh Thể. Đóng rồi mở lại.", BOLD, 16.0, Color.WHITE, "c", base + Vector2(177, 260), 600.0, 1.0, 24.0)
		return
	if _loading():
		_fwords("Đang tải Tinh Thể…", BOLD, 16.0, Color.WHITE, "c", base + Vector2(177, 260), 600.0, 1.0, 24.0)
		return
	if _state == "recommend":
		_draw_rmd(base + Vector2(10, 114))
	else:
		_draw_list(base + Vector2(10, 110))
	_label(Crystal.MAIN["_NewCrystalFrame_Label1"], "Nhóm Tinh Thể", base, HEAD_INK, true)
	_draw_strip(base)
	_draw_sockets(base)
	_label(Crystal.MAIN["lblTotalLv"], str(CrystalModel.level_sum(pack.crystal, _tmp)), base, HEAD_INK)
	_label(Crystal.MAIN["_NewCrystalFrame_Label2"], "Tổng Lv Tinh Thể", base, HEAD_INK)


	var head4: Array = Crystal.MAIN["_NewCrystalFrame_Label4"]
	_fwords("Tinh Thể tăng thuộc tính", BOLD, float(head4[4]), HEAD_INK, "c", base + Vector2(float(head4[0]) - HEAD_WIDE / 2.0, float(head4[1])), HEAD_WIDE, 1.0, 0.0, true)
	var lines: Array = _attr_lines()
	for i in range(mini(12, lines.size())):
		_fwords(str(lines[i]), BOLD, 13.0, ATTR_INK, "c", base + Vector2(792, 276.0 + i * 20.0), 150.0, 1.5, 0.0, true, ATTR_RIM)
	if _dirty():
		_save_rect = _fbutton("save", "crystal_save", base + Vector2(817, 78))
	else:
		_save_rect = _fblit("crystal_save_off", base + Vector2(817, 78))
	_fbutton("reset", "crystal_reset", base + Vector2(817, 122))
	_label(Crystal.MAIN["_NewCrystalFrame_Label5"], "Nhấp trái khảm/gỡ Tinh Thể", base, HINT_INK, false, 0.0)


func _draw_strip(base: Vector2) -> void :
	var ids: Array = _ids()
	var total: int = ids.size() + 1
	_strip = clampi(_strip, 0, maxi(0, total - NAMES_SHOWN))
	if _strip >= 1:
		_fbutton("strip:left", "crystal_left", base + Vector2(371, 77))
	else:
		_fblit("crystal_left_off", base + Vector2(371, 77))
	if _strip < total - NAMES_SHOWN:
		_fbutton("strip:right", "crystal_right", base + Vector2(740, 77))
	else:
		_fblit("crystal_right_off", base + Vector2(740, 77))
	for j in range(mini(NAMES_SHOWN, total - _strip)):
		var index: int = _strip + j
		var at: Vector2 = base + Vector2(402.0 + j * NAME_PITCH, 74.0)
		if index >= ids.size():
			_fbutton("scheme:add", "crystal_name_add", at + Vector2(-3, 1.5))
			continue
		var id: int = int(ids[index])
		_fbutton("scheme:%d" % id, "crystal_name_on" if id == _scheme else "crystal_name", at + Vector2(-3, 1.5))
		_label(Crystal.NAME["lblName"], _scheme_name(id), at, Color(0, 0, 0, 0), true)
		if _can_add(_tmp if id == _scheme else _server(id)):
			_fblit("crystal_dot", at + Vector2(49, 0))


func _draw_sockets(base: Vector2) -> void :
	var lv: int = _level()
	var first: int = 999
	for i in range(CrystalModel.SLOTS):
		var need: int = CrystalModel.slot_level(pack.crystal, i)
		if need > lv:
			first = mini(first, need)
	for i in range(mini(CrystalModel.SLOTS, Crystal.SOCKETS.size())):
		var spot: Array = Crystal.SOCKETS[i]
		var at: Vector2 = base + Vector2(float(spot[0]), float(spot[1]))
		var k: int = CrystalModel.slot_kind(pack.crystal, i)
		var need: int = CrystalModel.slot_level(pack.crystal, i)
		var cell: String = "crystal_sock_%d" % clampi(k, 2, 4)
		if need <= lv:
			if _state.is_empty() and _type == k:
				_hexagon(at + Vector2(26, 30), 31.0, GLOW_INK)
			var rect: Rect2 = _fbutton("sock:%d" % i, cell, at)
			var item: int = int(_tmp[i]) if i < _tmp.size() else 0
			if item > 0:
				_socket_icon(_pic(item), at)
			_peek(item, rect, i)
		elif need == first:
			_fblit(cell, at)
			_fblit("crystal_lock", at + Vector2(10, 10))
			_peek(0, Rect2(at * _f, Vector2(52, 60) * _f), i)
			_fwords("LV%d" % need, REGULAR, 16.0, LOCK_INK, "c", at + Vector2(-274, 9), 600.0, 1.0, 24.0, false)
			_fwords("Mở", BOLD, 14.0, LOCK_INK, "c", at + Vector2(-274, 25), 600.0, 1.0, 24.0, false)
		else:
			_fblit("crystal_gray", at)
			_fblit("crystal_lock", at + Vector2(10, 10))
			_peek(0, Rect2(at * _f, Vector2(52, 60) * _f), i)


func _draw_list(o: Vector2) -> void :
	var radios: Array = Crystal.LIST["radios"]
	for i in range(TYPES.size()):
		_fbutton("type:%d" % i, "crystal_type%d%s" % [i, "_on" if _type == int(TYPES[i]) else ""], o + _v(radios[i]))
	_list = _rows()
	var n: int = _list.size()
	_scroll = clampi(_scroll, 0, maxi(0, n - ROWS))
	var used: Dictionary = CrystalModel.used(_tmp)
	for r in range(mini(ROWS, n - _scroll)):
		var item: int = int(_list[_scroll + r])
		_draw_row(item, o + Vector2(0, 37.0 + r * ROW_PITCH), "row:%d" % (_scroll + r), int(_have.get(item, 0)) - int(used.get(item, 0)), ROW_INK, 107.0)
	_draw_bar("scroll", o + Vector2(231, 37), 350.0, _scroll, ROWS, n, func(value: float) -> void : _scroll = clampi(roundi(value), 0, maxi(0, n - ROWS)))

func _draw_row(item: int, at: Vector2, id: String, count: int, ink: Color, wide: float) -> void :
	if _hover == id:
		_fblit("crystal_row_on", at + Vector2(0, -2))
	else:
		_fblit("crystal_row", at + Vector2(0, 2))
	var rect: Rect2 = Rect2(at * _f, Vector2(202, 50) * _f)
	_hit(id, rect, false)
	_fit(_pic(item), at + Vector2(3, 3), Vector2(44, 44), 1.0)
	var lines: Array = _desc(item)
	var shown: int = mini(2, lines.size())
	for j in range(shown):
		_fwords(str(lines[j]), BOLD, 12.0, ink, "l", at + Vector2(48, 18.0 - (shown - 1) * 7.0 + j * 14.0), wide, 1.0, 14.0)
	_fwords("x%d" % count, BOLD, 12.0, NONE_INK if count <= 0 else ink, "r", at + Vector2(-403, 13), 600.0, 1.0, 24.0, false)
	_peek(item, rect)


func _draw_rmd(o: Vector2) -> void :
	var tank: Dictionary = _tank()
	pack.load_garage()
	_draw_tank(o, tank)
	_fblit("crystal_tank_bk", o + Vector2(85, 30))
	_label(Crystal.RMD["lblTankName"], _tank_name(), o)
	_fbutton("tank", "crystal_tank", o + Vector2(141, 67))
	var tpl: String = str(int(tank.get("m_tpltId", 0)))
	var info: Variant = pack.garage.get("tanks", {}).get(tpl, {})
	var pos: String = str(info.get("pos", "")) if info is Dictionary else ""
	_label(Crystal.RMD["lblTankPos"], "Định Vị: " + pos, o)
	_label(Crystal.RMD["_NewCrystalRmdLstFrame_Label3"], "Đề Cử:", o)
	var levels: Array = Crystal.RMD["levels"]
	for i in range(5):
		_fbutton("rlv:%d" % (i + 1), "crystal_lv%d%s" % [i, "_on" if _rmd_lv == i + 1 else ""], o + _v(levels[i]))
	var table: Variant = pack.crystal.get("rmd", {}).get(tpl, {})
	var picked: Variant = table.get(str(_rmd_lv), []) if table is Dictionary else []
	_rmd = picked if picked is Array else []
	var used: Dictionary = CrystalModel.used(_tmp)
	for r in range(mini(3, _rmd.size())):
		var item: int = int(_rmd[r])
		var at: Vector2 = o + Vector2(0, 197.0 + r * ROW_PITCH)
		_draw_row(item, at, "rmd:%d" % r, int(_have.get(item, 0)) - int(used.get(item, 0)), LABEL_INK, 113.0)
		_fbutton("buy:%d" % r, "crystal_buy", at + Vector2(207, 11))

func _draw_tank(o: Vector2, tank: Dictionary) -> void :
	if tank.is_empty() or pack.state != "ready" or pack.garage.is_empty():
		return
	var level: int = maxi(1, int(tank.get("m_level", 1)))
	var ext: int = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), int(tank.get("m_tpltId", 0)), level, tank)
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(tank.get("m_haloId", 0)), level)
	TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, (o + Vector2(55, 55)) * _f, 0.5 * _f, _time)



func _draw_sell() -> void :
	var at: Vector2 = _shade(SELL_BOX.x, SELL_BOX.y)
	_fblit("crystal_sell_frame", at + Vector2(-13, -18))
	_fbutton("sell:close", "crystal_close", at + Vector2(652, -5))
	var lines: int = _sell_lines()
	_sell_scroll = clampi(_sell_scroll, 0, maxi(0, lines - SELL_LINES))
	for r in range(SELL_LINES):
		for c in range(SELL_COLS):
			var index: int = (_sell_scroll + r) * SELL_COLS + c
			if index >= _sell_list.size():
				break
			var item: int = int(_sell_list[index])
			var cell: Vector2 = at + Vector2(23.0 + c * 125.0, 40.0 + r * 185.0)
			var rect: Rect2 = _fbutton("sell:cell:%d" % index, "crystal_tile", cell)
			_fit(_pic(item), cell + Vector2(10.5, 4), Vector2(100, 100), 1.0)
			var desc: Array = _desc(item)
			for j in range(mini(2, desc.size())):
				_fwords(str(desc[j]), BOLD, 12.0, ROW_INK, "c", cell + Vector2(5.5, 110.0 + j * 14.0), 110.0, 1.0, 14.0)
			_fblit("crystal_cb_on" if _sell_pick.has(index) else "crystal_cb", cell + Vector2(43.5, 138))
			_peek(item, rect)
	if _sell_list.is_empty():
		_fwords("Không có Tinh Thể rảnh để bán.", BOLD, 14.0, Color.WHITE, "c", at + Vector2(23, 200), 630.0, 1.0, 24.0)
	_draw_bar("sellbar", at + Vector2(654, 40), 370.0, _sell_scroll, SELL_LINES, lines, 
		func(value: float) -> void : _sell_scroll = clampi(roundi(value), 0, maxi(0, lines - SELL_LINES)))
	for i in range(5):
		_fbutton("sell:lv:%d" % i, "crystal_cb_on" if bool(_sell_levels[i]) else "crystal_cb", at + _v(SELL_CHECKS[i]))
		_label(Crystal.SELL[SELL_MARKS[i]], "Cấp " + str(ROMAN[i]), at)
	_label(Crystal.SELL["_NewCrystalSellFrame_Text1"], "Bán nhận được", at)
	_fblit("crystal_piece", at + Vector2(533, 412))
	_fwords(str(_sell_total()), BOLD, 16.0, ROW_INK, "l", at + Vector2(568, 415), 100.0)
	_label(Crystal.SELL["_NewCrystalSellFrame_Label1"], "Đã lắp tinh thể không thể bán", at)
	_fbutton("sell:ok", "crystal_sell_ok", at + Vector2(533, 445))



func _draw_convert() -> void :
	var at: Vector2 = _shade(CONV_BOX.x, CONV_BOX.y)
	_fblit("crystal_conv_frame", at + Vector2(2, -18))
	_fbutton("conv:close", "crystal_close", at + Vector2(861, -5))
	_conv_list = _conv_rows()
	var pages: int = _conv_pages()
	_conv_page = clampi(_conv_page, 1, pages)
	var chips: int = _chips()
	if pack.crystalx.is_empty():
		_fwords("Đang tải bảng đổi…", BOLD, 16.0, Color.WHITE, "c", at + Vector2(150, 250), 600.0, 1.0, 24.0)
	else:
		var spots: Array = Crystal.CONVERT["items"]
		for i in range(CONV_PAGE):
			var index: int = (_conv_page - 1) * CONV_PAGE + i
			if index >= _conv_list.size():
				break
			_draw_conv_item(index, at + _v(spots[i]), chips)
	var levels: Array = Crystal.CONVERT["levels"]
	for i in range(5):
		var spot: Vector2 = at + _v(levels[i])
		if bool(_conv_levels[i]):
			_fbutton("conv:lv:%d" % i, "crystal_cl%d_on" % i, spot + Vector2(-3, -2))
		else:
			_fbutton("conv:lv:%d" % i, "crystal_cl%d" % i, spot)
	_draw_pager(at + Vector2(450, 509), pages)
	_draw_token(at + Vector2(731, 505))


func _draw_pager(c: Vector2, pages: int) -> void :
	var shown: int = mini(pages, 20)
	var wide: float = 25.0 + 4.0 + shown * 26.0 - 2.0 + 4.0 + 25.0
	var x: float = c.x - wide / 2.0
	_fbutton("conv:prev", "crystal_pg_prev", Vector2(x, c.y - 2.0))
	x += 29.0
	for i in range(shown):
		var page: int = i + 1
		_fbutton("conv:page:%d" % page, "crystal_pg%d%s" % [page, "_on" if page == _conv_page else ""], Vector2(x, c.y))
		x += 26.0
	_fbutton("conv:next", "crystal_pg_next", Vector2(x + 2.0, c.y - 2.0))

func _draw_conv_item(index: int, at: Vector2, chips: int) -> void :
	var row: Array = _conv_list[index]
	var item: int = int(row[1])
	var cost: int = int(row[4])
	_fblit("crystal_conv_tile", at)
	_fwords(GarageModel.cap(CrystalModel.title(pack.crystal, item)), BOLD, 14.0, Color.WHITE, "c", at + Vector2(2, 3), 200.0, 1.0)
	_fit(_pic(item), at + Vector2(52, 42), Vector2(100, 100), 1.0)
	_peek(item, Rect2((at + Vector2(52, 42)) * _f, Vector2(100, 100) * _f))
	_fblit("crystal_piece", at + Vector2(57, 148))
	_fwords(str(cost), BOLD, 14.0, Color.WHITE, "l", at + Vector2(83, 153), 100.0, 1.0)
	var id: String = "conv:item:%d" % index
	_fblit("crystal_conv_btn", at + Vector2(66.5, 185), 0.0, 0.0, Color(0.55, 0.55, 0.55, 1.0) if chips < cost else _glow(id))
	_hit(id, Rect2((at + Vector2(66.5, 185)) * _f, Vector2(71, 29) * _f), false)




func _draw_make() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var keep_u: float = _u
	var keep_f: float = _f
	var k: float = _adapt()
	var o: Vector2 = Vector2(roundf((_fw / k - ADAPT.x) / 2.0), roundf((_fh / k - ADAPT.y) / 2.0))
	_u = keep_u * k
	_f = keep_f * k
	_draw_make_box(o + MAKE_AT)
	_u = keep_u
	_f = keep_f

func _draw_make_box(at: Vector2) -> void :
	_hit("panel", Rect2(at * _f, Vector2(1200, 800) * _f), false)
	var bg: Texture2D = pack.picture("l/cr/make_bg.webp")
	if bg != null:
		draw_texture_rect(bg, Rect2((at + Vector2(-15, -50)) * _f, Vector2(1230, 870) * _f), false)
	_fbutton("make:close", "crystal_close", at + Vector2(1176, -35))
	_fbutton("make:info", "crystal_info", at + Vector2(744, 28))
	var prices: Dictionary = Crystal.MAKE["price"]
	_fbutton("make:5", "crystal_mk_one", at + Vector2(328, 634))
	_price("crystal_gift", 5, at + _v(prices["coin_one"]))
	_fbutton("make:6", "crystal_mk_five", at + Vector2(439, 634))
	_price("crystal_gift", 6, at + _v(prices["coin_five"]))
	if _free_now():
		_fbutton("make:2", "crystal_mk_free", at + Vector2(673, 634))
	else:
		_fbutton("make:3", "crystal_mk_one", at + Vector2(673, 634))
		_price("crystal_cash", 3, at + _v(prices["cash_one"]))
		_fblit("crystal_clock", at + Vector2(650, 613))
		var left: int = maxi(0, client.crystal_free_at - int(Time.get_unix_time_from_system()))
		_fwords("%s miễn phí" % _clock(left), BOLD, 14.0, TIME_INK, "l", at + Vector2(671, 610), 125.0, 1.0, 0.0, false)
	_fbutton("make:4", "crystal_mk_five", at + Vector2(784, 634))
	_price("crystal_cash", 4, at + _v(prices["cash_five"]))
	_fwords(_pity(284, true), BOLD, 14.0, PITY_INK, "c", at + Vector2(270, 592), 300.0, 1.0)
	_fwords(_pity(285, false), BOLD, 14.0, PITY_INK, "c", at + Vector2(617, 592), 300.0, 1.0)

func _price(icon: String, kind: int, at: Vector2) -> void :
	_fblit(icon, at)
	_fwords(str(int(CrystalModel.make_cost(pack.crystal, kind)[1])), BOLD, 14.0, Color.WHITE, "l", at + Vector2(26, 5), 80.0, 1.0)



func _draw_reward() -> void :
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_fx_tip = 0
	var keep_u: float = _u
	var keep_f: float = _f
	var k: float = _adapt()
	var o: Vector2 = Vector2(roundf((_fw / k - ADAPT.x) / 2.0), roundf((_fh / k - ADAPT.y) / 2.0))
	_u = keep_u * k
	_f = keep_f * k
	var mouse: Vector2 = get_local_mouse_position()
	if _fx != null:
		_draw_reward_live(o, mouse)
		_u = keep_u
		_f = keep_f
		return
	var frame: int = fx_frame(_time - _fx_at)
	for i in range(mini(_fx_items.size(), FX_SLOTS.size())):
		var alpha: float = fx_alpha(i, frame)
		var picture: Texture2D = _pic(int(_fx_items[i]))
		if alpha <= 0.0 or picture == null or picture.get_width() <= 4:
			continue
		var cell: Rect2 = fx_icon(i, Vector2(picture.get_size()))
		var px: Rect2 = Rect2((o + cell.position) * _f, cell.size * _f)
		draw_texture_rect(picture, px, false, Color(1, 1, 1, alpha))
		if _press.is_empty() and px.has_point(mouse):
			_fx_tip = int(_fx_items[i])
	if frame >= FX_DONE:
		_fbutton("reward:ok", "crystal_ok", o + FX_OK)
	_u = keep_u
	_f = keep_f
	if _fx_tip > 0:
		_draw_item_tip(_fx_tip)



func _draw_reward_live(o: Vector2, mouse: Vector2) -> void :
	_fx.position = (o + FX_AT) * _f
	_fx.scale = Vector2(_f, _f)
	var pics: Dictionary = {}
	var cells: Array = []
	for i in range(mini(_fx_items.size(), FX_NAMES.size())):
		var picture: Texture2D = _pic(int(_fx_items[i]))
		if picture == null or picture.get_width() <= 4:
			continue
		var cell: Rect2 = Rect2(Vector2.ZERO, fx_icon(i, Vector2(picture.get_size())).size)
		pics[FX_NAMES[i]] = [[picture, cell]]
		cells.append([i, cell])
	_fx.set_attach(pics)
	var at: Vector2 = mouse / _f - o - FX_AT
	for pair: Array in cells:
		var spot: Variant = _fx.named.get(FX_NAMES[int(pair[0])])
		if spot == null or not _press.is_empty():
			continue
		var xf: Transform2D = spot.xf
		if absf(xf.determinant()) < 1e-06:
			continue
		if (pair[1] as Rect2).has_point(xf.affine_inverse() * at):
			_fx_tip = int(_fx_items[int(pair[0])])
	_fx_ok = o + FX_OK
	_fx_scale = Vector2(_u, _f)
	if _fx_finished():
		_hit("reward:ok", Rect2(_fx_ok * _f, _cell_size("crystal_ok") * _f), false)
	_fx_top.position = Vector2.ZERO
	_fx_top.size = size
	_fx_top.queue_redraw()


static func fx_frame(age: float) -> int:
	return floori(maxf(0.0, age) * FX_FPS) + 1 + FX_SKIP


static func fx_alpha(index: int, frame: int) -> float:
	var at: int = int(FX_SLOT_FRAME[index])
	return 0.0 if frame < at else (0.5 if frame == at else 1.0)


static func fx_icon(index: int, picture_size: Vector2) -> Rect2:
	var spot: Array = FX_SLOTS[index]
	var k: float = minf(FX_ICON, minf(100.0 * FX_ICON / maxf(1.0, picture_size.x), 100.0 * FX_ICON / maxf(1.0, picture_size.y)))
	return Rect2(FX_AT + Vector2(float(spot[0]), float(spot[1])), picture_size * k)



static func fx_pick(entries: Array, piece: int, rng: Callable) -> Array:

	var vec: Array = []
	for entry: Variant in entries:
		for _k in range(clampi(int(entry[1]) if entry is Array and entry.size() > 1 else 1, 1, FX_SLOTS.size())):
			vec.append(entry)
	for _n in range(vec.size()):
		var first: Variant = vec.pop_front()
		vec.insert(mini(int(float(rng.call()) * vec.size() + 1.0), vec.size()), first)
	var out: Array = []
	for entry: Variant in vec:
		var item: int = 0
		if entry is Array:
			item = int(entry[0]) if not entry.is_empty() else 0
		else:
			item = int(entry)
		if item > 0 and item != piece and out.size() < FX_SLOTS.size():
			out.append(item)
	return out


func _draw_item_tip(item: int, pen: FlashScreen = null) -> void :
	if pen == null:
		pen = self
	var rec: Dictionary = BagModel.entry("crystal", {"m_templateId": item, "m_count": 1}, pack.bag, client.character, int(Time.get_unix_time_from_system()))
	var owned: Array = []
	for tank: Variant in client.tanks.values():
		if tank is Dictionary and int(tank.get("m_contType", -1)) == GarageModel.OWN:
			owned.append(int(tank.get("m_tpltId", 0)))
	var ctx: Dictionary = {"now": int(Time.get_unix_time_from_system()), "tanks": pack.lobby.get("tanks", {}), "owned": owned, 
		"fx": pack.bagx.get("fx", {}), "ornate": pack.bagx.get("ornate", {}), "bigs": TipAtlas.BIG_OF, "coins": TipAtlas.COIN_OF, 
		"me": str(pack.lobby.get("avatars", {}).get(str(int(client.character.get("avatarId", 0))), ""))}
	var tall: Callable = func(text: String, wide: float, px: float) -> float:
		var font_size: int = maxi(6, roundi(px * pen._f))
		return ARIAL.get_multiline_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, (wide - 4.0) * pen._f, font_size).y / pen._f
	var tip: Dictionary = ItemTip.layout(rec, pack.bag, ctx, tall)
	var box: Vector2 = Vector2(float(tip.wide), float(tip.high))
	var at: Vector2 = ItemTip.place(get_local_mouse_position() / pen._f, box, Vector2(pen._fw, pen._fh))
	pen._round(Rect2(at * pen._f, box * pen._f), Color(0, 0, 0, 0.8), 12.0)
	for op: Array in tip.ops:
		match str(op[0]):
			"label":
				var wide: float = float(op[6])
				if wide > 0.0:
					pen._fwords(str(op[1]), BOLD if op[5] else REGULAR, float(op[3]), op[4], "c", at + op[2] + Vector2(wide / 2.0 - 200.0, 0), 400.0, 0.0, 0.0, false)
				else:
					pen._fwords(str(op[1]), BOLD if op[5] else REGULAR, float(op[3]), op[4], "l", at + op[2], 400.0, 0.0, 0.0, false)
			"para":
				pen._fpara(str(op[1]), REGULAR, float(op[4]), op[5], at + op[2] + Vector2(2, 0), float(op[3]) - 4.0)
			"cell":
				var cell: Rect2 = op[2]
				pen._fblit(str(op[1]), at + cell.position, cell.size.x, cell.size.y)
			"pic":
				var cell: Rect2 = op[2]
				var picture: Texture2D = pack.picture(str(op[1]))
				if picture != null and picture.get_width() > 4:
					var k: float = minf(cell.size.x / picture.get_width(), cell.size.y / picture.get_height())
					pen.draw_texture_rect(picture, Rect2((at + cell.position) * pen._f, Vector2(picture.get_size()) * k * pen._f), false)



func _draw_ask() -> void :
	var at: Vector2 = _shade(450.0, 220.0)
	_fblit("bag_ask_guy", at + Vector2(-80, -76))
	_fblit("bag_ask", at + Vector2(46, 1))
	var text: String = "Chưa lưu, có lưu rồi tắt không?" if _ask_kind == "leave" else "Chưa lưu, tiếp tục?"
	_fpara(text, BOLD, 14.0, Color.WHITE, at + Vector2(102, 38), 270.0, 5)
	_fbutton("ask:ok", "bag_ask_ok", at + Vector2(120, 133))
	_fbutton("ask:no", "bag_ask_no", at + Vector2(240, 133))




func _draw_rule() -> void :
	var box: Array = Rule.BOX
	var at: Vector2 = _window(float(box[0]), float(box[1]), "rule:close")
	var spot: Dictionary = Rule.AT
	var canvas: Array = spot["canvas"]
	_round(Rect2((at + _v(canvas)) * _f, Vector2(float(canvas[2]), float(canvas[3])) * _f), RULE_BG, 20.0)
	_fblit("rl_title", at + _v(spot["title"]))
	var rule: Array = Rule.RULES.get(str(_rule), [])
	if rule.size() >= 2:
		var desc: Array = spot["desc"]
		var o: Vector2 = at + _v(desc)
		_fwords(str(rule[0]), BOLD, 18.0, Color.WHITE, "l", o, float(desc[2]), 1.5, 0.0, false, RULE_RIM)
		_rim_para(str(rule[1]).replace("#ENTER#", "\n"), 15.0, RULE_INK, o + Vector2(0, RULE_TITLE_H + 6.0), 457.0, 1.0)
	var ok: Vector2 = at + _v(spot["ok"])
	_fbutton("rule:ok", "public_button_window_green", ok)
	_fblit("title_title_confirm_green_t", ok + Vector2(40, 7), 0.0, 0.0, _glow("rule:ok"))


func _rim_para(text: String, px: float, color: Color, at: Vector2, wide: float, edge: float) -> void :
	var font: Font = _face(BOLD)
	var font_size: int = maxi(6, roundi(px * _f))
	var origin: Vector2 = Vector2(at.x, at.y + 2.0) * _f + Vector2(0, font.get_ascent(font_size))
	draw_multiline_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, wide * _f, font_size, -1, maxi(1, roundi(edge * _f)), RULE_RIM)
	draw_multiline_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, wide * _f, font_size, -1, color)



func _wheel(step: int, at: Vector2) -> void :
	if _rule > 0:
		return
	match _sheet_id:
		"sell":
			_sell_scroll = clampi(_sell_scroll + step, 0, maxi(0, _sell_lines() - SELL_LINES))
		"convert":
			_conv_page = clampi(_conv_page + step, 1, _conv_pages())
		"":
			var spot: Vector2 = at / _f - _centre(MAIN_BOX.x, MAIN_BOX.y)
			if _state.is_empty() and Rect2(10, 147, 250, 350).has_point(spot):
				_scroll = clampi(_scroll + step, 0, maxi(0, _list.size() - ROWS))
			elif Rect2(371, 72, 402, 40).has_point(spot):
				_strip = clampi(_strip + step, 0, maxi(0, _ids().size() + 1 - NAMES_SHOWN))




func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and _sheet_id == "make" and _rule == 0\
	and _time - _make_open_at < OPEN_FX:
		_press = ""
		accept_event()
		return
	super (event)

func _input(event: InputEvent) -> void :
	if (_sheet_id.is_empty() and _rule == 0) or not is_visible_in_tree():
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _rule > 0:
			_rule = 0
		elif _sheet_id == "award":
			_award_close()
		elif _sheet_id == "reward" and _fx_finished():
			_finish()
		elif _sheet_id == "reward":
			pass
		else:
			_close()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or not (event is InputEventKey and event.pressed):
		return
	if event.keycode != KEY_ESCAPE or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if _renaming:
		_renaming = false
		_name.text = _scheme_name(_scheme)
		_name.release_focus()
	else:
		_leave()
	get_viewport().set_input_as_handled()

func _activate(id: String) -> void :
	if _sheet_id == "award":
		if id == "ok":
			_award_close()
		return
	if _renaming and id != "rename":
		_commit_name()
	var parts: PackedStringArray = id.split(":")
	var head: String = parts[0]
	var tail: String = parts[1] if parts.size() > 1 else ""
	var arg: int = int(parts[parts.size() - 1])
	match head:
		"close":
			_leave()
		"tab":
			if tail == "rmd":
				if _state != "recommend":
					_rmd_lv = 3
				_state = "recommend"
			else:
				_state = ""
		"type":
			if arg >= 0 and arg < TYPES.size():
				_type = int(TYPES[arg])
				_scroll = 0
		"row":
			if arg >= 0 and arg < _list.size():
				_try_add(int(_list[arg]))
		"rmd":
			if arg >= 0 and arg < _rmd.size():
				var item: int = int(_rmd[arg])
				if _spare(item) > 0:
					_try_add(item)
				elif _free_slot(item) >= 0:

					_quick_buy(item)
		"buy":
			if arg >= 0 and arg < _rmd.size():
				_quick_buy(int(_rmd[arg]))
		"rlv":
			_rmd_lv = clampi(arg, 1, 5)
		"tank":
			if for_pick:
				say(PICK_BLOCKED)
			elif _dirty():
				_ask("tank")
			else:
				page_asked.emit("tank")
		"rename":
			_rename()
		"sock":
			if arg >= 0 and arg < _tmp.size() and int(_tmp[arg]) > 0:
				_tmp[arg] = 0
		"scheme":
			if tail == "add":
				var card: int = _scheme_card_slot()
				if card < 0:
					_quick_buy(SCHEME_ITEM)
				elif not client.use_item(GROCERY, card, 1):
					say("Chưa dùng được lúc này.")
			else:
				_pick_scheme(arg)
		"strip":
			var last: int = maxi(0, _ids().size() + 1 - NAMES_SHOWN)
			if tail == "left":
				_strip = clampi(_strip - 1, 0, last)
			else:
				_strip = clampi(_strip + 1, 0, last)
		"save":
			_save()
		"reset":
			_tmp = CrystalModel.empty_page()
		"open":
			if tail == "sell":
				_open_sell()
			elif tail == "convert":
				_open_convert()
			elif tail == "make":
				_open_make()
		"token":
			say(TIP_620)
		"scroll":
			var top: int = maxi(0, _list.size() - ROWS)
			if tail == "up":
				_scroll = clampi(_scroll - 1, 0, top)
			else:
				_scroll = clampi(_scroll + 1, 0, top)
		"sellbar":
			var bottom: int = maxi(0, _sell_lines() - SELL_LINES)
			if tail == "up":
				_sell_scroll = clampi(_sell_scroll - 1, 0, bottom)
			else:
				_sell_scroll = clampi(_sell_scroll + 1, 0, bottom)
		"sell":
			_sell_click(tail, arg)
		"conv":
			_conv_click(tail, arg)
		"make":
			if tail == "close":
				_close()
			elif tail == "info":
				_rule = RULE_MAKE
			else:
				_make(arg)
		"rule":
			_rule = 0
		"reward":
			_finish()
		"ask":
			_answer(tail == "ok")

func _sell_click(what: String, arg: int) -> void :
	match what:
		"close":
			_close()
		"cell":
			if _sell_pick.has(arg):
				_sell_pick.erase(arg)
			elif arg >= 0 and arg < _sell_list.size():
				_sell_pick[arg] = true
		"lv":
			_sell_level(arg)
		"ok":
			_sell()

func _conv_click(what: String, arg: int) -> void :
	match what:
		"close":
			_close()
		"lv":
			if arg >= 0 and arg < 5:
				_conv_levels[arg] = not bool(_conv_levels[arg])
				_conv_page = 1
		"item":
			_convert(arg)
		"page":
			_conv_page = clampi(arg, 1, _conv_pages())
		"prev":
			_conv_page = maxi(1, _conv_page - 1)
		"next":
			_conv_page = mini(_conv_pages(), _conv_page + 1)
