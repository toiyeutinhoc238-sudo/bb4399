extends "flash_screen.gd"











const HelperModel = preload("helper_model.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const Atlas = preload("helper_atlas.gd")
const Arena = preload("arena_atlas.gd")
const UpAtlas = preload("helper_up_atlas.gd")
const SelectSheet = preload("helper_select.gd")
const GradLabel = preload("grad_label.gd")
const HelperTip = preload("helper_tip.gd")
const FlaPlayer = preload("fla_player.gd")
const RewardPopup = preload("reward_popup.gd")
const RewardFly = preload("reward_fly.gd")

signal closed
signal quick_buy_asked(tid: int)
signal guide_asked(tid: int)

const HELP_INK: Color = Color("42ff5d")
const HELP_RIM: Color = Color("005797")
const COIN_LOW: Color = Color("ff0000")
const LACK_TINT: Color = Color(0.6, 0.6, 0.6, 1.0)
const WAIT: float = 8.0



const STAR_FX: Dictionary = {"frame": "fla/hsf", "gear": "fla/hgl", "item": "fla/hil", "star": "fla/has"}
const STAR_AT: Vector2 = Vector2(-10, 52)
const STAR_CENTRE: Vector2 = Vector2(250, 250)
const STAR_BOX: Array = [Vector2(-250, -57), Vector2(136, -57)]
const STAR_SOUND: String = "u/helper_star_gear"
const STAR_SEND: float = 6.0
const STAR_END: float = 8.0
const EXP_ITEM: int = 3700001
const MEMORY_LOW: int = 4010000
const MEMORY_HIGH: int = 4000001

const TIP: Dictionary = {
	228: "Đặt trợ thủ vào", 
	229: "Đặt trợ thủ thứ 2", 
	230: "Đưa vào Vật Liệu Tăng Cấp", 
	231: "Thiếu vật liệu, cần @num1@ vật liệu đổi", 
	233: "Tỉ lệ thành công 100%, không cần thêm vật liệu tăng tỉ lệ thành công nữa", 
	240: "Hãy đưa vào vật liệu cường hóa", 
	247: "Lv tiểu trợ thủ đã vượt mưc, không thể tăng tiếp", 
	248: "Số lần cường hóa tiểu trợ thủ đã vượt mức, không thể cường hóa tiếp", 
	249: "Câp sao tiểu trợ thủ đã vượt mức, không thể thêm sao nữa", 
	250: "Trợ thủ Lv@num1@ cao hơn giới hạn LV trợ thủ @num2@, không thể chuyển", 
	251: "Lượt cường hóa trợ thủ @num1@ cao hơn giới hạn lượt cường hóa  trợ thủ @num2@, không thể chuyển", 
	252: "Cấp sao trợ thủ @num1@ cao hơn giới hạn cấp sao trợ thủ @num2@, không thể chuyển", 
	254: "Vật liệu đưa vào có Lv không phù hơp yêu cầu cường hóa tiểu trợ thủ", 
	258: "Thiếu vật liệu thêm sao", 
	259: "Vật liệu đưa vào có Lv không phù hơp yêu cầu thêm sao tiểu trợ thủ", 
	265: "Trợ thủ đang trang bị không thể tách", 
	266: "Hẫy đặt trợ thủ", 
	270: "Không đủ Bạc", 
	272: "Chuyển đổi lv, số lần cường hóa và cấp sao của hai Trợ Thủ, tiếp tục không?", 
	446: "Đặt trợ thủ cần đổi", 
	480: "Không có trợ thủ phù hợp điều kiện tách", 
}

const SHORT: Dictionary = {1: "TC", 2: "XG", 3: "PT", 4: "HP"}
const LONG: Dictionary = {1: "TC:", 2: "XG:", 3: "PT:", 4: "HP:"}
const SPLIT_ASK: String = "Đồng ý tách vật phẩm @name@ không?"
const SPLIT_INFO: String = "Tư chất @num1@, lv@num2@, lượt cường hóa @num3@, cấp sao @num4@"
const BULK_ASK: String = "Tách hết @n@ trợ thủ thường?"
const BULK_TOP: String = "LV cao nhất @lv@."
const BULK_SKIP: String = "Bỏ qua @m@ con đã nâng sao/cường hóa."
const BULK_GAIN: String = "Nhận lại vật liệu theo tư chất."
const HELP_LABEL: String = "Giải thích"
const INSTR_TITLE: Dictionary = {"level": "Giải thích", "split": "Giải thích Tách", "stth": "Giải thích", "upgrade": "Giải thích", "convert": "Giải thích", "helper": "Giải thích"}

const INSTR_TEXT: Dictionary = {
	"level": "1. Lv Trợ Thủ càng cao, thuộc tính cơ bản càng lớn. \n2.Có thể dùng vật liệu tăng cấp “Chip siêu dẫn”, để tăng lv Trợ Thủ. \n3. Tư chất Trợ Thủ càng cao, giới hạn có thể tăng lv càng cao. \n4. Vật liệu tăng lv “Chip siêu dẫn” có nhiều cấp, “Chip siêu dẫn” càng tốt thì EXP cung cấp càng cao. \n5. Thông qua phụ bản để nhận “Chip siêu dẫn”.", 
	"split": "1. Tách trợ thủ có thể nhận vật liệu tăng lv, cường hóa, tăng sao... cho trợ thủ. \n2. Tư chất càng cao thì tách được vật liệu càng tốt. \n3.Có thể tách được vật liệu hiếm, dùng trong giao diện đổi trợ thủ hiếm.", 
	"stth": "1. Trên cơ bản tăng lv Trợ Thủ, số lần cường hóa càng nhiều, điểm thuộc tính cường hóa càng lớn.\n2. Trợ Thủ khác loại, có thuộc tính cường hóa khác nhau, số lần cường hóa càng cao, đặc điểm Trợ Thủ càng nổi bật.\n3. Dùng vật liệu cường hóa “Tinh Thể Siêu Năng”, tăng số lần cường hóa Trợ Thủ.\n4. Cường hóa thất bại sẽ tăng mức hoàn thành, mức hoàn thành càng cao, năng lực càng cao.\n5. Tư chất trợ thủ càng cao, số lần cường hóa càng nhiều. \n6. Vật liệu cường hóa “Tinh Thể Siêu Năng” có nhiều cấp, căn cứ số lần cường hóa của Trợ Thủ hiện tại khác nhau, cần lv “Tinh Thể Siêu Năng” khác nhau. \n7. “Tinh Thể Siêu Năng”  nhận qua phụ bản, cũng có thể mua ở shop.", 
	"upgrade": "1. Trên cơ bản tăng lv Trợ Thủ, tăng theo cấp sao, sẽ tăng lượng lớn thuộc tính cơ bản.\n2. Dùng vật liệu tăng sao “Hạt Nhân Vạn Năng”, tăng cấp sao Trợ Thủ.\n3.  Tăng sao thất bại, sẽ tăng mắc hoàn thành tăng sao của Trợ Thủ, mức độ càng cao, năng lực nhận được càng cao.\n4. Tư chất trợ thủ càng cao, giới hạn tăng sao càng cao.\n5. Vật liệu tăng sao “Hạt Nhân Siêu Năng” có nhiều cấp, dựa vào cấp sao Trợ Thủ hiện tại khác nhau, cấn “Hạt Nhân Siêu Năng”  có lv cũng khác nhau.\n6. “Hạt Nhân Siêu Năng”  nhận qua phụ bản, đủ số lượng “Mảnh Hạt Nhân” cũng có thể đổi được, hoặc mua ở shop.\n7.“Mảnh Hạt Nhân”  nhận qua phụ bản.", 
	"convert": "1. Thông qua chức năng chuyển đổi có thể chuyển đổi lv, số lần cường hóa và cấp sao của Trợ Thủ.\n2. Chuyển đổi cần tốn vật liệu chuyển đối “Máy lưu trữ thông tin”.\n3. “Máy lưu trữ thông tin” có thể đổi từ số lượng “Mảnh máy lưu trữ”nhất định, cũng có thể mua ở shop.", 
}

const BUBBLES: Array = ["Điểm tư chất Trợ Thủ \nCàng cao càng tốt.", "Tiến độ cường hóa\nLượt cường hóa càng nhiều\nnăng lực càng đột phá.", "Cấp sao trợ thủ,\ncấp sao tăng,\nthì năng lực tăng.", "Lv Trợ Thủ\ncàng cao\nthuộc tính càng cao"]
const PVE_TEXT: String = "Thông qua phụ bản nhận được Trợ Thủ."
const UP_TIP: String = "Mức hoàn thành thể hiện tỉ lệ năng lực hiện có được"
const NOT_SOLD: String = "Chưa bán"
const LAB_HELP: Dictionary = {"lv": "level", "st": "stth", "gr": "upgrade", "cv": "convert"}

const MAIN_BOX: Dictionary = {"lv": "frmLevelMainHelper", "st": "frmStrengthenMainHelper", "gr": "frmGradeMainHelper", "cv": "frmConvertMainHelper"}
const MAT_BOX: Dictionary = {"lv": "frmExpItem", "st": "frmStrengthenItem0", "gr": "frmGradeMeterial", "cv": "frmTransItem"}
const NANO_BOX: Array = ["frmGradeItem0", "frmGradeItem1", "frmGradeItem2"]
const SECOND_BOX: String = "frmConvertSecondHelper"

const RESULT_BOX: Dictionary = {"frmLevelResultHelper": "", "frmStrengthenResultHelper": "up", "frmGradeResultHelper": "rank"}

var _state: String = "lv"
var _list: Array = []
var _rev: int = -1
var _lead: String = ""
var _second: String = ""
var _mat: Dictionary = {}
var _cut: Array = [null, {}]
var _lack: Array = []
var _nano: Array = [-1, -1, -1]
var _dots: Dictionary = {}
var _helper_row: int = 0
var _mat_row: int = 0
var _splitting: bool = false
var _sheet_id: String = ""
var _select: RefCounted = SelectSheet.new()
var _sheet_key: String = ""
var _ask: Dictionary = {}
var _reward: RefCounted = RewardPopup.new()
var _flies: Array = []
var _pending: Dictionary = {}
var _helper_failed: bool = false
var _bag_failed: bool = false
var _tip: Array = []
var _htip: Array = []
var _up_fx: Dictionary = {}
var _score_fx: Dictionary = {}
var _fx_asked: bool = false
var _star_fx: Dictionary = {}
var _star_nodes: Dictionary = {}

func chat_busy() -> bool:
	return not _sheet_id.is_empty()

func _setup() -> void :
	pack.picture_ready.connect( func(path: String) -> void :
		if path == "l/helper.json":
			_helper_failed = pack.helper.is_empty()
			_rev = -1
		elif path == "l/bag.json":
			_bag_failed = pack.bag.is_empty()
			_rev = -1)
	client.noticed.connect( func(text: String) -> void :
		if is_visible_in_tree():
			_pending = {}
			say(text))
	client.awarded.connect(_on_award)
	var guide_view: Control = preload("guide_view.gd").new()
	guide_view.setup(self, "helper")
	add_child(guide_view)



func guide_open(ui: String) -> bool:
	if not _sheet_id.is_empty() or _loading():
		return false
	match ui:
		"helperUpWindow":
			return _state == "lv"
		"helperStWindow":
			return _state == "st"
		"helperStarWindow":
			return _state == "gr"
		"helperCvtWindow":
			return _state == "cv"
	return ui == "helperWindow"



func guide_put(two: bool) -> int:
	if _loading() or _rev != client.bag_rev:
		return -1
	var main: String = str(client.battle_helper)
	if main.is_empty():
		return 0
	if two:
		var first: String = str(_list[0].uuid) if not _list.is_empty() else ""
		if first.is_empty() or first == main or _find(main).is_empty():
			return 0
		_lead = main
		_second = first
	elif not _find(main).is_empty():
		_lead = main
		if _second == main:
			_second = ""
	_nano = [-1, -1, -1]
	_auto()
	return 1


func guide_close(_ui: String) -> void :
	closed.emit()


func _shown() -> void :
	_close()
	_reward.reset()
	_flies = []
	RewardFly.reset(self)
	_star_stop()
	_splitting = false
	_up_fx = {}
	_score_fx = {}
	if not is_visible_in_tree():
		return
	_state = "lv"
	_lead = ""
	_second = ""
	_mat = {}
	_lack = []
	_nano = [-1, -1, -1]
	_helper_row = 0
	_mat_row = 0
	pack.load_helper()
	pack.load_bag()
	if not client.bag_loaded:
		client.request_bags()
	_helper_failed = false
	_bag_failed = false
	_pending = {}
	_rev = -1

func _tick(_delta: float) -> void :
	if _reward.tick(self) and _sheet_id == "award":
		_sheet_id = ""
	if not _fx_asked and pack.state == "ready":
		_fx_asked = true
		for key: String in UpAtlas.FX.values() + STAR_FX.values():
			pack.effect(key, true)
		pack.sound("s/%s.mp3" % STAR_SOUND, true)
	if not _star_fx.is_empty():
		_star_tick()
	if not _up_fx.is_empty():
		if _time - float(_up_fx.at) >= float(UpAtlas.FX_SHOW):
			_up_fx = {}
		elif not _up_fx.has("from") and not pack.effect_cached(str(_up_fx.key)).is_empty():
			_up_fx["from"] = _time
	if not _score_fx.is_empty() and _score_frames() >= _score_steps() + int(UpAtlas.SCORE_STEPS[1]):
		_score_fx = {}
	if not _pending.is_empty() and _time - float(_pending.at) > WAIT:
		_pending = {}
		say("Máy chủ chưa phản hồi, thử lại sau.")
	if _loading() or _rev == client.bag_rev:
		return
	_rev = client.bag_rev
	_rebuild()

func _loading() -> bool:
	return (pack.helper.is_empty() and not _helper_failed) or (pack.bag.is_empty() and not _bag_failed) or not client.bag_loaded


func _rebuild() -> void :
	_list = HelperModel.roster(client.bags, pack.helper, pack.bag, client.battle_helper) if not pack.helper.is_empty() else []
	_list.sort_custom( func(a: Dictionary, b: Dictionary) -> bool:
		for key: String in ["apt", "rank", "up", "lv"]:
			if int(a[key]) != int(b[key]):
				return int(a[key]) > int(b[key])
		return int(a.slot) < int(b.slot))
	if _find(_lead).is_empty():
		_lead = ""
	if _second == _lead or _find(_second).is_empty():
		_second = ""
	if _state == "cv" and not _convert_open():
		_state = "lv"
	_settle()
	_trim_nano()
	_auto()
	_dots = {"lv": _can_grow("lv"), "st": _can_grow("st"), "gr": _can_grow("gr")}
	_helper_row = clampi(_helper_row, 0, maxi(0, _lines(_list.size()) - int(Atlas.GRIDS.helper.rows)))
	_mat_row = clampi(_mat_row, 0, maxi(0, _lines(_mat_list().size()) - int(Atlas.GRIDS.material.rows)))
	if _sheet_id == "ask" and not str(_ask.get("uuid", "")).is_empty() and _find(str(_ask.uuid)).is_empty():
		_close()

func _lines(count: int) -> int:
	return int(ceil(count / 5.0))

func _find(uuid: String) -> Dictionary:
	if uuid.is_empty():
		return {}
	for rec: Dictionary in _list:
		if str(rec.uuid) == uuid:
			return rec
	return {}


func _convert_open() -> bool:
	for rec: Dictionary in _list:
		if int(rec.apt) > 1:
			return true
	return false

func _golden() -> int:
	return int(client.currency.get("m_iGolden", 0))


func _item(item: int) -> Array:
	var row: Array = pack.bag.get("items", {}).get(str(item), [])
	if row.size() >= 10:
		return [BagModel.clean(str(row[0])), BagModel.clean(str(row[1])), "l/it/%s.webp" % str(row[2]) if not str(row[2]).is_empty() else "", int(row[3])]
	var more: Array = pack.bag.get("more", {}).get(str(item), [])
	if more.size() >= 4:
		return [BagModel.clean(str(more[0])), "", "l/it/%s.webp" % str(more[1]) if not str(more[1]).is_empty() else "", int(more[2])]
	return ["Vật phẩm %d" % item, "", "", 0]


func _row_for(rec: Dictionary, state: String = "") -> Array:
	if rec.is_empty():
		return []
	match _state if state.is_empty() else state:
		"st":
			return HelperModel.consume(pack.helper, 1, int(rec.up) + 1)
		"gr":
			return HelperModel.consume(pack.helper, 2, int(rec.rank) + 1)
	return []


func _stacks(kind: int) -> Array:
	var meta: Dictionary = pack.helper.get("mats", {})
	var out: Array = []
	for inst: Dictionary in client.bags.get(3, []):
		var item: int = int(inst.get("m_templateId", 0))
		var row: Array = meta.get(str(item), [])
		if row.size() >= 3 and int(row[0]) == kind:
			out.append({"item": item, "slot": int(inst.get("m_slotNo", -1)), "count": maxi(1, int(inst.get("m_count", 1))), "kind": kind, "gain": int(row[1]), "tier": int(row[2])})
	out.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a.slot) < int(b.slot))
	return out

func _only(list: Array, row: Array) -> Array:
	if row.is_empty():
		return list
	return list.filter( func(stack: Dictionary) -> bool: return int(stack.item) == int(row[0]))



func _mat_list() -> Array:
	var rec: Dictionary = _find(_lead)
	match _state:
		"lv":
			return _stacks(HelperModel.EXP_CHIP)
		"st":
			return _only(_stacks(HelperModel.CRYSTAL), _row_for(rec))
		"gr":
			return _stacks(HelperModel.NANO) + _only(_stacks(HelperModel.CORE), _row_for(rec))
		"cv":
			var list: Array = _stacks(HelperModel.MEMORY)
			var two: Dictionary = _find(_second)
			if rec.is_empty() or two.is_empty():
				return list
			return _only(list, [_memory_item(rec, two)])
	return []

func _memory_item(a: Dictionary, b: Dictionary) -> int:
	return MEMORY_LOW if maxi(int(a.apt), int(b.apt)) <= 20 else MEMORY_HIGH


func _left(stack: Dictionary) -> int:
	var left: int = int(stack.count)
	if _state == "lv":
		return maxi(0, left - int(_chip_cut().get(int(stack.slot), 0)))
	if not _mat.is_empty() and int(_mat.slot) == int(stack.slot):
		left -= int(_mat.used)
	for slot: int in _nano:
		if slot == int(stack.slot):
			left -= 1
	return maxi(0, left)



func _chip_cut() -> Dictionary:
	var key: Array = [client.bag_rev, _lead, _mat.get("slot", -2)]
	if _cut[0] == key:
		return _cut[1]
	var cut: Dictionary = {}
	var rec: Dictionary = _find(_lead)
	if not rec.is_empty() and not _mat.is_empty():
		var want: Dictionary = {}
		for step: Dictionary in HelperModel.plan(HelperModel.chips(client.bags, pack.helper), HelperModel.exp_to_max(rec, pack.helper)):
			want[int(step.item)] = int(step.count)
		for stack: Dictionary in _stacks(HelperModel.EXP_CHIP):
			var take: int = mini(int(stack.count), int(want.get(int(stack.item), 0)))
			if take > 0:
				cut[int(stack.slot)] = take
				want[int(stack.item)] -= take
	_cut = [key, cut]
	return cut



func _auto() -> void :
	_mat = {}
	_lack = []
	var rec: Dictionary = _find(_lead)
	if rec.is_empty():
		return
	match _state:
		"lv":
			var chips: Array = _stacks(HelperModel.EXP_CHIP)
			if chips.is_empty():
				_lack = [EXP_ITEM, 1]
			else:
				_mat = {"item": chips[0].item, "count": chips[0].count, "slot": chips[0].slot, "used": chips[0].count}
		"st", "gr":
			var row: Array = _row_for(rec)
			if row.is_empty():
				return
			for stack: Dictionary in _stacks(HelperModel.CRYSTAL if _state == "st" else HelperModel.CORE):
				if int(stack.item) == int(row[0]):
					_mat = {"item": stack.item, "count": stack.count, "slot": stack.slot, "used": 1}
					return
			_lack = [int(row[0]), 1]
		"cv":
			var two: Dictionary = _find(_second)
			if two.is_empty():
				return
			var need: int = HelperModel.convert_need(int(rec.apt), int(two.apt))
			var item: int = _memory_item(rec, two)
			if HelperModel.have(client.bags, item) < need:
				_lack = [item, need]
			else:
				_mat = {"item": item, "count": need, "slot": -1, "used": 0}


func _trim_nano() -> void :
	var meta: Dictionary = pack.helper.get("mats", {})
	var used: Dictionary = {}
	for i in range(_nano.size()):
		var slot: int = int(_nano[i])
		if slot < 0:
			continue
		var inst: Dictionary = client.bag_item(3, slot)
		var row: Array = meta.get(str(int(inst.get("m_templateId", 0))), [])
		used[slot] = int(used.get(slot, 0)) + 1
		if inst.is_empty() or row.size() < 3 or int(row[0]) != HelperModel.NANO or int(used[slot]) > maxi(1, int(inst.get("m_count", 1))):
			_nano[i] = -1


func _nano_picked() -> Array:
	var meta: Dictionary = pack.helper.get("mats", {})
	var out: Array = []
	for slot: int in _nano:
		if slot < 0:
			continue
		var row: Array = meta.get(str(int(client.bag_item(3, slot).get("m_templateId", 0))), [])
		if row.size() >= 3:
			out.append({"tier": int(row[2]), "gain": int(row[1])})
	return out


func _success(rec: Dictionary) -> int:
	var row: Array = _row_for(rec)
	if row.is_empty():
		return 0
	var rate: float = float(row[4])
	if _state == "gr":
		rate += HelperModel.nano_bonus(int(rec.rank), _nano_picked())
	return int(minf(rate, HelperModel.RATE) / HelperModel.RATE * 100.0)


func _can_grow(kind: String) -> bool:
	var rec: Dictionary = {}
	for one: Dictionary in _list:
		if one.battle:
			rec = one
	if rec.is_empty():
		return false
	match kind:
		"lv":
			if int(rec.lv) >= int(rec.lv_max):
				return false
			var gain: int = 0
			for stack: Dictionary in _stacks(HelperModel.EXP_CHIP):
				gain += int(stack.gain) * int(stack.count)
			return gain >= HelperModel.exp_need(pack.helper, int(rec.lv)) - int(rec.exp)
		"st":
			var row: Array = _row_for(rec, "st")
			return int(rec.up) < int(rec.up_max) and not row.is_empty() and HelperModel.have(client.bags, int(row[0])) > 0
		"gr":
			var row: Array = _row_for(rec, "gr")
			return int(rec.rank) < int(rec.rank_max) and not row.is_empty() and HelperModel.have(client.bags, int(row[0])) > 0
	return false



func _activate(id: String) -> void :
	if _sheet_id == "select":
		_select.activate(self, id)
		return
	if _sheet_id == "award":
		if id == "ok":
			_award_close()
		return
	if not _sheet_id.is_empty():
		match id:
			"cancel":
				_close()
			"ok":
				if _sheet_id == "ask":
					_confirm()
				else:
					_close()
		return
	if _splitting:
		_splitting = false
		if id.begins_with("cell:"):
			_split_pick(id.substr(5))
			return
	if id.begins_with("tab:"):
		_set_state(id.substr(4))
	elif id.begins_with("cell:"):
		_pick(id.substr(5))
	elif id.begins_with("mat:"):
		_pick_mat(int(id.substr(4)))
	elif id.begins_with("box:"):
		_clear_box(id.substr(4))
	elif id.begins_with("help:"):
		var key: String = id.substr(5)
		_sheet_key = str(LAB_HELP.get(_state, "level")) if key == "lab" else key
		_sheet_id = "instr"
	elif id.begins_with("sb:"):
		var parts: PackedStringArray = id.split(":")
		if parts.size() == 3:
			_scroll(parts[1], -1 if parts[2] == "up" else 1)
	match id:
		"close":
			closed.emit()
		"do":
			_do()
		"split":
			_splitting = true
		"split_all":
			var bulk: Array = HelperModel.bulk_split(_list, pack.bag)
			if bulk.is_empty():
				_say_tip(480)
			else:
				_ask = {"op": "bulk", "text": _bulk_text(bulk), "uuid": ""}
				_sheet_id = "ask"
		"set_battle":
			_set_battle()
		"buy", "buy2":
			_buy(id)
		"retry":
			_helper_failed = false
			_bag_failed = false
			_rev = -1
			pack.load_helper()
			pack.load_bag()
			if not client.bag_loaded:
				client.request_bags()


func buy_item() -> int:
	if not _mat.is_empty():
		return int(_mat.item)
	return int(_lack[0]) if not _lack.is_empty() else 0


func nano_for(rank: int) -> int:
	var meta: Dictionary = pack.helper.get("mats", {})
	var ids: Array = meta.keys().map( func(key: Variant) -> int: return int(key))
	ids.sort()
	for item: int in ids:
		var row: Array = meta.get(str(item), [])
		if row.size() >= 3 and int(row[0]) == HelperModel.NANO and int(row[2]) == rank / 2:
			return item
	return 0




func _buy(id: String) -> void :
	if _state == "lv":
		return
	if _state == "gr" and id == "buy":
		var rec: Dictionary = _find(_lead)
		if rec.is_empty():
			return
		var nano: int = nano_for(int(rec.rank))
		if nano > 0:
			quick_buy_asked.emit(nano)
		else:
			say(NOT_SOLD)
		return
	var item: int = buy_item()
	if item > 0:
		quick_buy_asked.emit(item)
	elif _state == "cv":
		_say_tip(446)

func _say_tip(code: int, one: String = "", two: String = "") -> void :
	say(str(TIP.get(code, "")).replace("@num1@", one).replace("@num2@", two))

func _fail() -> void :
	say("Chưa thao tác được lúc này.")

func _busy() -> bool:
	if _pending.is_empty():
		return false
	say("Đang chờ máy chủ…")
	return true


func _in_lab(uuid: String) -> bool:
	return not uuid.is_empty() and (uuid == _lead or (_state == "cv" and uuid == _second))


func _set_state(key: String) -> void :
	if key == _state or not Atlas.TABS.has(key) or (key == "cv" and not _convert_open()):
		return
	_state = key
	_nano = [-1, -1, -1]
	_mat_row = 0
	_auto()


func _pick(uuid: String) -> void :
	if _find(uuid).is_empty() or _in_lab(uuid):
		return
	if _state == "cv" and not _lead.is_empty():
		_second = uuid
	else:
		_lead = uuid
		if _second == uuid:
			_second = ""
		_nano = [-1, -1, -1]
	_auto()


func _pick_mat(slot: int) -> void :
	var rec: Dictionary = _find(_lead)
	if rec.is_empty() or _state == "cv":
		return
	for stack: Dictionary in _mat_list():
		if int(stack.slot) != slot or _left(stack) <= 0:
			continue
		var kind: int = int(stack.kind)
		if kind == HelperModel.EXP_CHIP:
			_mat = {"item": stack.item, "count": stack.count, "slot": slot, "used": stack.count}
			_lack = []
		elif kind == HelperModel.CRYSTAL or kind == HelperModel.CORE:
			_mat = {"item": stack.item, "count": stack.count, "slot": slot, "used": 1}
			_lack = []
		elif kind == HelperModel.NANO:
			if _success(rec) >= 100:
				_say_tip(233)
				return
			var free: int = _nano.find(-1)
			if free >= 0:
				_nano[free] = slot
		return



func _clear_box(id: String) -> void :
	if id == str(MAIN_BOX.get(_state, "")):
		_lead = ""
		_second = ""
		_nano = [-1, -1, -1]
		_auto()
	elif id == SECOND_BOX:
		_second = ""
		_auto()
	elif id == str(MAT_BOX.get(_state, "")):
		if not _lack.is_empty():
			guide_asked.emit(int(_lack[0]))
		else:
			_mat = {}
	elif id in NANO_BOX:
		_nano[NANO_BOX.find(id)] = -1


func _do() -> void :
	var rec: Dictionary = _find(_lead)
	match _state:
		"lv":
			if rec.is_empty():
				_say_tip(266)
			elif int(rec.lv) >= int(rec.lv_max):
				_say_tip(247)
			elif _mat.is_empty():
				_say_tip(230)
			elif not _busy():
				if client.helper_plant(int(rec.slot), int(_mat.slot)):
					_wait("lv", rec)
				else:
					_fail()
		"st", "gr":
			var star: bool = _state == "gr"
			if rec.is_empty():
				_say_tip(266)
				return
			if (int(rec.rank) >= int(rec.rank_max)) if star else (int(rec.up) >= int(rec.up_max)):
				_say_tip(249 if star else 248)
				return
			if _mat.is_empty():
				_say_tip(258 if star else 240)
				return
			var row: Array = _row_for(rec)
			if row.is_empty():
				return
			if int(_mat.item) != int(row[0]):
				_say_tip(259 if star else 254)
				return
			if int(row[5]) > _golden():
				_say_tip(270)
				return
			if star and not _star_fx.is_empty():
				return
			if _busy():
				return
			if star and _star_play(rec, int(row[5])):
				return
			var sent: bool = client.helper_compose(int(rec.slot), _nano.filter( func(slot: int) -> bool: return slot >= 0)) if star else client.helper_strengthen(int(rec.slot))
			if not sent:
				_fail()
				return
			_wait("star" if star else "up", rec, {"coin": int(row[5])})
		"cv":
			if rec.is_empty():
				_say_tip(228)
				return
			var two: Dictionary = _find(_second)
			if two.is_empty():
				_say_tip(229)
				return
			if _mat.is_empty():
				_say_tip(231, str(HelperModel.convert_need(int(rec.apt), int(two.apt))))
				return
			for pair: Array in [[rec, two], [two, rec]]:
				var a: Dictionary = pair[0]
				var b: Dictionary = pair[1]
				var one: String = GarageModel.cap(str(a.name))
				var other: String = GarageModel.cap(str(b.name))
				if int(a.lv) > int(b.lv_max):
					_say_tip(250, one, other)
					return
				if int(a.up) > int(b.up_max):
					_say_tip(251, one, other)
					return
				if int(a.rank) > int(b.rank_max):
					_say_tip(252, one, other)
					return
			_ask = {"op": "trans", "text": TIP[272], "uuid": str(rec.uuid)}
			_sheet_id = "ask"


func _split_pick(uuid: String) -> void :
	var rec: Dictionary = _find(uuid)
	if rec.is_empty() or _in_lab(uuid):
		return
	if rec.battle:
		_say_tip(265)
		return
	var info: String = SPLIT_INFO.replace("@num1@", str(int(rec.apt))).replace("@num2@", str(int(rec.lv))).replace("@num3@", str(int(rec.up))).replace("@num4@", str(int(rec.rank)))
	_ask = {"op": "split", "text": SPLIT_ASK.replace("@name@", GarageModel.cap(str(rec.name))) + "\n" + info, "uuid": uuid}
	_sheet_id = "ask"


func _bulk_text(bulk: Array) -> String:
	var top: int = 0
	for rec: Dictionary in bulk:
		top = maxi(top, int(rec.lv))
	var skipped: int = 0
	for rec: Dictionary in _list:
		if HelperModel.bulk_kind(rec, pack.bag) == 1:
			skipped += 1
	var lines: PackedStringArray = [BULK_ASK.replace("@n@", str(bulk.size())), BULK_TOP.replace("@lv@", str(top))]
	if skipped > 0:
		lines.append(BULK_SKIP.replace("@m@", str(skipped)))
	lines.append(BULK_GAIN)
	return "\n".join(lines)


func _set_battle() -> void :
	_select.open(self)


func _confirm() -> void :
	var ask: Dictionary = _ask
	_close()
	if _busy():
		return
	match str(ask.get("op", "")):
		"split":
			var rec: Dictionary = _find(str(ask.get("uuid", "")))
			if rec.is_empty():
				return
			if client.helper_split([int(rec.slot)]):
				_wait("split", rec, {"uuids": [str(rec.uuid)]})
			else:
				_fail()
		"bulk":
			var list: Array = HelperModel.bulk_split(_list, pack.bag)
			if list.is_empty():
				_say_tip(480)
				return
			var slots: Array = []
			var uuids: Array = []
			for rec: Dictionary in list:
				slots.append(int(rec.slot))
				uuids.append(str(rec.uuid))
			if client.helper_split(slots):
				_wait("split", {}, {"uuids": uuids})
			else:
				_fail()
		"trans":
			var a: Dictionary = _find(_lead)
			var b: Dictionary = _find(_second)
			if a.is_empty() or b.is_empty():
				return
			if client.helper_trans(int(a.slot), int(b.slot)):
				_wait("trans", a)
			else:
				_fail()

func _scroll(grid: String, step: int) -> void :
	if not Atlas.GRIDS.has(grid):
		return
	var count: int = _list.size() if grid == "helper" else _mat_list().size()
	var top: int = maxi(0, _lines(count) - int(Atlas.GRIDS[grid].rows))
	if grid == "helper":
		_helper_row = clampi(_helper_row + step, 0, top)
	else:
		_mat_row = clampi(_mat_row + step, 0, top)


func _wheel(step: int, at: Vector2) -> void :
	if _sheet_id == "select":
		_select.wheel(self, step, at)
		return
	if not _sheet_id.is_empty() or _loading():
		return
	var spot: Vector2 = at / _f - _centre(float(Atlas.FRAME[0]), float(Atlas.FRAME[1]))
	for grid: String in ["helper", "material"]:
		var b: Array = Atlas.GRIDS[grid].box
		if Rect2(float(b[0]), float(b[1]), float(b[2]), float(b[3])).has_point(spot):
			_scroll(grid, step)

func _wait(op: String, rec: Dictionary, extra: Dictionary = {}) -> void :
	_pending = {"op": op, "uuid": str(rec.get("uuid", "")), "name": GarageModel.cap(str(rec.get("name", ""))), "before": rec.duplicate(), "at": _time, "rev": client.bag_rev}
	_pending.merge(extra)


func _settle() -> void :
	if _pending.is_empty() or int(_pending.get("rev", -1)) == client.bag_rev:
		return
	var op: String = str(_pending.op)
	var who: String = str(_pending.name)
	if op == "split":
		var left: int = 0
		for uuid: String in _pending.uuids:
			if not _find(uuid).is_empty():
				left += 1
		var gone: int = _pending.uuids.size() - left
		if gone > 0:
			_pending = {}
			say("Đã tách %s." % (who if gone == 1 and not who.is_empty() else "%d trợ thủ" % gone))
		return
	if op == "trans":
		_pending = {}
		say("Chuyển đổi thành công!")
		return
	var rec: Dictionary = _find(str(_pending.uuid))
	if rec.is_empty():
		_pending = {}
		return
	if op == "battle":
		if rec.battle:
			_pending = {}
			say("%s đã là chủ chiến." % who)
		return
	var before: Dictionary = _pending.before
	var moved: bool = false
	for key: String in ["lv", "exp", "up", "upc", "rank", "rankc"]:
		if int(rec[key]) != int(before[key]):
			moved = true
	if not moved:
		return
	var coin: int = int(_pending.get("coin", 0))
	_pending = {}
	match op:
		"lv":
			say("%s lên LV %d." % [who, int(rec.lv)] if int(rec.lv) > int(before.lv) else "%s nhận thêm EXP." % who)
			if int(rec.lv) > int(before.lv) or int(rec.exp) != int(before.exp):
				_celebrate(op, rec, before)
		"up":
			client.spend_golden(coin)
			if int(rec.up) > int(before.up):
				say("Cường hoá thành công: %s +%d." % [who, int(rec.up)])
				_celebrate(op, rec, before)
			else:
				say("Cường hoá thất bại — bảo hiểm %d%%." % HelperModel.luck(pack.helper, 1, int(rec.up), int(rec.upc)))
		"star":
			client.spend_golden(coin)
			_nano = [-1, -1, -1]
			if int(rec.rank) > int(before.rank):
				say("Tăng sao thành công: %s lên %d sao." % [who, int(rec.rank)])
				_celebrate(op, rec, before)
			else:
				say("Tăng sao thất bại — bảo hiểm %d%%." % HelperModel.luck(pack.helper, 2, int(rec.rank), int(rec.rankc)))



func _celebrate(op: String, rec: Dictionary, before: Dictionary) -> void :
	var key: String = str(UpAtlas.FX.get(op, ""))
	if key.is_empty():
		return
	pack.effect(key)
	_up_fx = {"key": key, "at": _time}
	var old: int = int(before.get("score", 0))
	var now: int = int(rec.get("score", 0))
	if now > old:
		_score_fx = {"icon": str(rec.get("icon", "")), "from": old, "to": now, "add": ceili(float(now - old) / float(UpAtlas.SCORE_STEPS[0])), "at": _time}


func _score_frames() -> int:
	return int((_time - float(_score_fx.at)) * float(UpAtlas.FX_FPS))


func _score_steps() -> int:
	return ceili(float(int(_score_fx.to) - int(_score_fx.from)) / float(maxi(1, int(_score_fx.add))))


func _score_value() -> int:
	return mini(int(_score_fx.from) + _score_frames() * int(_score_fx.add), int(_score_fx.to))

func _on_award(info: Dictionary) -> void :
	if not is_visible_in_tree():
		return
	if not RewardPopup.has_rewards(info):
		return
	if _reward.active and _reward.closing_at >= 0.0:
		_flies.append_array(RewardFly.begin(self, _reward.info))
		_reward.reset()
	if _sheet_id != "award":
		_close()
		_reward.reset()
	_reward.begin(self, info)
	_sheet_id = "award"


func _award_close() -> void :
	_reward.request_close(self)
	_close()

func _close() -> void :
	_sheet_id = ""
	_hide_edits()

func _input(event: InputEvent) -> void :
	if not _sheet_id.is_empty() and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _sheet_id == "award":
			_award_close()
		else:
			_close()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	if event.keycode != KEY_ESCAPE:
		return
	if _splitting:
		_splitting = false
	else:
		closed.emit()
	get_viewport().set_input_as_handled()



func _hv(spec: Array, from: int = 0) -> Vector2:
	return Vector2(float(spec[from]), float(spec[from + 1]))

func _paint() -> void :
	if not _cells.has("hp_frame"):
		_use(Arena.FILE, Arena.R)
		_use(Atlas.FILE, Atlas.R)
		_use(UpAtlas.FILE, UpAtlas.R)
	_tip = []
	_htip = []
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var frame: Vector2 = _hv(Atlas.FRAME)
	var base: Vector2 = _centre(frame.x, frame.y)
	_hit("panel", Rect2(base * _f, frame * _f), false)
	_fblit("hp_frame", base + _hv(Atlas.FRAME_AT))
	_fbutton("close", "public_button_close", base + _hv(Atlas.BUTTONS.close))
	_draw_tabs(base)
	_draw_frame_help(base)
	if _loading():
		_fwords("Đang tải dữ liệu trợ thủ…", BOLD, 16.0, Color.WHITE, "c", base + Vector2(0, 280), frame.x, 1.0, 24.0)
	elif _helper_failed or _bag_failed:
		_fwords("Chưa tải được dữ liệu trợ thủ.", BOLD, 16.0, Color.WHITE, "c", base + Vector2(0, 262), frame.x, 1.0, 24.0)
		var spot: Vector2 = base + Vector2(frame.x / 2.0 - 60.0, 296)
		var retry: Rect2 = Rect2(spot * _f, Vector2(120, 32) * _f)
		_round(retry, Color("1d7fd0"), 10.0, Color("9fe0ff"), 1.5)
		_fwords("Thử lại", BOLD, 15.0, Color.WHITE, "c", spot, 120.0, 1.0, 32.0)
		_hit("retry", retry)
	else:
		if _star_fx.is_empty():
			_draw_lab(base + _hv(Atlas.LAB_AT))
		_draw_helpers(base)
		_draw_materials(base)
		for key: String in ["split_all", "split", "set_battle"]:
			_fbutton(key, "hp_" + key, base + _hv(Atlas.BUTTONS[key]))
		_draw_score(base)
		_draw_star(base)
	_draw_up_fx()
	match _sheet_id:
		"instr":
			_draw_instr()
		"ask":
			_draw_ask()
		"award":
			pass
		"select":
			_select.draw(self)
		_:
			_draw_tip()
			if _splitting:

				_fblit("hp_cursor", get_local_mouse_position() / _f - Vector2(24, 24))
	_reward.paint(self)
	_flies = RewardFly.paint(self, _flies)



func _star_play(rec: Dictionary, coin: int) -> bool:
	if pack.effect_cached(str(STAR_FX.frame)).is_empty():
		return false
	var mat: String = str(_item(int(_mat.item))[2]) if not _mat.is_empty() else ""
	_star_fx = {"at": _time, "slot": int(rec.slot), "nano": _nano.filter( func(slot: int) -> bool: return slot >= 0), "uuid": str(rec.uuid), 
		"rec": rec.duplicate(), "coin": coin, "icons": [str(rec.get("icon", "")), mat], "grow": 0.0, "sent": false, "boom": false}
	for key: String in ["ll", "lr", "rl", "el"]:
		var fx: Dictionary = pack.effect_cached(str(STAR_FX.gear if key in ["ll", "lr"] else STAR_FX.item))
		if not FlaPlayer.valid(fx.get("data")):
			continue
		var player: FlaPlayer = FlaPlayer.new()
		if player.add_clip(fx) < 0:
			player.free()
			continue
		player.visible = false
		add_child(player)
		_star_nodes[key] = player
	Sound.play(STAR_SOUND)
	_star_tick()
	return true





func _star_tick() -> void :
	var t: float = _time - float(_star_fx.at)
	if t >= STAR_SEND and not bool(_star_fx.sent):
		_star_send()
	if t >= STAR_END:
		_star_stop()
		return
	var lift: Array = [0.0, 2.0, 4.0, 2.0]
	if t >= 1.0 and t < 4.0:
		_star_fx.grow = lift[int(t)] * (1.0 - 2.0 * randf())
	if _star_scale(t) <= 0.3 and not bool(_star_fx.boom):
		_star_fx.boom = true
		var fx: Dictionary = pack.effect_cached(str(STAR_FX.star))
		if FlaPlayer.valid(fx.get("data")):
			var player: FlaPlayer = FlaPlayer.new()
			if player.add_clip(fx) >= 0:
				add_child(player)
				_star_nodes["boom"] = player
			else:
				player.free()
	_star_place(t)


static func _star_scale(t: float) -> float:
	var u: float = clampf((t - 4.0) / 2.0, 0.0, 1.0)
	return 1.0 - u * u * u * u


static func _star_alpha(t: float) -> float:
	if t < 1.0:
		return t * t
	if t < STAR_SEND:
		return 1.0
	var u: float = clampf((t - STAR_SEND) / (STAR_END - STAR_SEND), 0.0, 1.0)
	return 1.0 - (8.0 * u * u * u * u if u < 0.5 else 1.0 - pow(-2.0 * u + 2.0, 4.0) / 2.0)


static func _star_turn(t: float) -> Vector2:
	var main: float = 0.0
	if t >= 1.0 and t < 2.0:
		main = 360.0 * pow(t - 1.0, 2.0)
	elif t >= 2.0 and t < 3.0:
		main = 720.0 * (t - 2.0)
	elif t >= 3.0 and t < 4.0:
		var u: float = t - 3.0
		main = -360.0 * (1.0 - (1.0 - u) * (1.0 - u))
	var w: float = clampf((t - 4.0) / 2.0, 0.0, 1.0)
	var spin: float = -2160.0 * (2.0 * w * w if w < 0.5 else 1.0 - pow(-2.0 * w + 2.0, 2.0) / 2.0)
	return Vector2(main, spin)


func _star_base() -> Vector2:
	var frame: Vector2 = _hv(Atlas.FRAME)
	return _centre(frame.x, frame.y)


func _star_box(t: float, index: int) -> Transform2D:
	var k: float = _star_scale(t)
	var centre: Vector2 = (_star_base() + STAR_AT + STAR_CENTRE) * _f
	return Transform2D(deg_to_rad(_star_turn(t).y), Vector2(_f, _f), 0.0, centre) * Transform2D(0.0, Vector2(k, k), 0.0, STAR_BOX[index] * k)


func _star_place(t: float) -> void :
	var alpha: float = _star_alpha(t)
	var origin: Vector2 = (_star_base() + STAR_AT) * _f
	var shown: Dictionary = {"ll": t >= 2.0 and t < 3.0, "lr": t >= 2.0 and t < 3.0, "rl": t >= 3.0, "el": t >= 3.0, "boom": true}
	for key: String in _star_nodes:
		var player: FlaPlayer = _star_nodes[key]
		player.visible = bool(shown[key])
		player.modulate.a = alpha
		match key:
			"ll":
				player.transform = Transform2D(0.0, Vector2(_f, _f), 0.0, origin + Vector2(150, 250) * _f)
			"lr":
				player.transform = Transform2D(0.0, Vector2( - _f, _f), 0.0, origin + Vector2(350, 250) * _f)
			"rl", "el":
				player.transform = _star_box(t, 0 if key == "rl" else 1) * Transform2D(0.0, Vector2(57, 57))
			"boom":
				player.transform = Transform2D(0.0, Vector2(_f, _f), 0.0, origin + STAR_CENTRE * _f)


func _star_send() -> void :
	_star_fx.sent = true
	var rec: Dictionary = _find(str(_star_fx.uuid))
	if not client.helper_compose(int(_star_fx.slot), _star_fx.nano):
		_fail()
		return
	_wait("star", rec if not rec.is_empty() else _star_fx.rec, {"coin": int(_star_fx.coin)})


func _star_stop() -> void :
	for player: FlaPlayer in _star_nodes.values():
		if player.get_parent() == self:
			remove_child(player)
		player.queue_free()
	_star_nodes = {}
	_star_fx = {}



func _draw_star(base: Vector2) -> void :
	if _star_fx.is_empty():
		return
	var fx: Dictionary = pack.effect_cached(str(STAR_FX.frame))
	if fx.is_empty():
		return
	var t: float = _time - float(_star_fx.at)
	var alpha: float = _star_alpha(t)
	var turn: Vector2 = _star_turn(t)
	var centre: Vector2 = (base + STAR_AT + STAR_CENTRE) * _f
	var light: Transform2D = Transform2D(deg_to_rad(turn.y), Vector2(_f, _f), 0.0, centre)
	_star_film(fx, 0, light, alpha)
	_star_film(fx, 1, light, alpha)
	_star_film(fx, 2, Transform2D(deg_to_rad(turn.x), Vector2(_f, _f), 0.0, centre), alpha)
	_star_film(fx, 3, Transform2D(deg_to_rad(float(_star_fx.grow)), Vector2(_f, _f), 0.0, centre), alpha)
	var back: float = alpha * pow(1.0 - clampf(t - 3.0, 0.0, 1.0), 2.0)
	for i in range(2):
		if back > 0.0:
			_star_film(fx, 4, light * Transform2D(0.0, STAR_BOX[i]), back)
		var icon: Texture2D = pack.picture(str(_star_fx.icons[i])) if not str(_star_fx.icons[i]).is_empty() else null
		if icon != null and icon.get_width() > 4:
			var k: float = minf(64.0 / icon.get_width(), 64.0 / icon.get_height())
			var extent: Vector2 = Vector2(icon.get_size()) * k
			draw_set_transform_matrix(_star_box(t, i))
			draw_texture_rect(icon, Rect2(Vector2(57, 57) - extent / 2.0, extent), false, Color(1, 1, 1, alpha))
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _star_film(fx: Dictionary, index: int, place: Transform2D, alpha: float) -> void :
	var frames: Array = fx.get("data", {}).get("frames", [])
	var pages: Array = fx.get("pages", [])
	if index >= frames.size():
		return
	var cell: Dictionary = frames[index]
	var page: int = int(cell.get("page", 0))
	if page >= pages.size() or pages[page] == null:
		return
	var rect: Array = cell.get("rect", [0, 0, 0, 0])
	var pivot: Array = cell.get("pivot", [0, 0])
	var src: Rect2 = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	draw_set_transform_matrix(place)
	draw_texture_rect_region(pages[page], Rect2( - Vector2(float(pivot[0]), float(pivot[1])), src.size), src, Color(1, 1, 1, alpha))



func _draw_score(base: Vector2) -> void :
	if _score_fx.is_empty():
		return
	var at: Vector2 = base + _hv(UpAtlas.SCORE_AT)
	var spec: Dictionary = UpAtlas.SCORE
	_fblit("gda_up_bar", at + _hv(spec.bar))
	var icon: String = str(_score_fx.icon)
	if not icon.is_empty():
		_hfit(pack.picture(icon), at + _hv(spec.helper), _hv(spec.helper, 2), 1.0)
	_fblit("gda_up_prowess", at + _hv(spec.word))
	var box: Array = spec.number
	var digits: String = str(_score_value())

	var step: float = float(spec.digit)
	var zoom: float = 1.0
	if float(digits.length()) * step > float(box[2]):
		step = float(box[2]) / float(digits.length())
		zoom = step / float(spec.digit)
	for i in range(digits.length()):
		var x: float = float(i) * step
		if zoom >= 1.0:
			_fblit("gda_up_n" + digits[i], at + Vector2(float(box[0]) + x, float(box[1])))
		else:
			var cell: Vector2 = _cell_size("gda_up_n" + digits[i])
			_fblit("gda_up_n" + digits[i], at + Vector2(float(box[0]) + x, float(box[1]) + cell.y * (1.0 - zoom) / 2.0), cell.x * zoom, cell.y * zoom)
	var change: Array = spec.change
	var right: float = float(UpAtlas.SCORE_SIZE[0]) - float(change[1])
	_fwords("+%d" % (int(_score_fx.to) - int(_score_fx.from)), BOLD, float(change[2]), Color(str(spec.change_color)), "r", 
		at + Vector2(right - 400.0, float(change[0])), 400.0, 0.0, 0.0, false)


func _draw_up_fx() -> void :
	if _up_fx.is_empty() or not _up_fx.has("from"):
		return
	var fx: Dictionary = pack.effect_cached(str(_up_fx.key))
	var frames: Array = fx.get("data", {}).get("frames", [])
	if frames.is_empty():
		return
	var index: int = int((_time - float(_up_fx.from)) * float(UpAtlas.FX_FPS)) % frames.size()
	var at: Vector2 = _centre(float(UpAtlas.FX_SIZE[0]), float(UpAtlas.FX_SIZE[1]))
	_draw_film(fx, index, Transform2D(0.0, Vector2(_f, _f), 0.0, at * _f))
	draw_set_transform_matrix(Transform2D.IDENTITY)


func _draw_film(fx: Dictionary, index: int, place: Transform2D) -> void :
	var frames: Array = fx.get("data", {}).get("frames", [])
	var pages: Array = fx.get("pages", [])
	if index < 0 or index >= frames.size():
		return
	var cell: Dictionary = frames[index]
	var page: int = int(cell.get("page", 0))
	if page >= pages.size() or pages[page] == null:
		return
	var rect: Array = cell.get("rect", [0, 0, 0, 0])
	var pivot: Array = cell.get("pivot", [0, 0])
	var src: Rect2 = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	draw_set_transform_matrix(place)
	draw_texture_rect_region(pages[page], Rect2( - Vector2(float(pivot[0]), float(pivot[1])), src.size), src)


func _draw_tabs(base: Vector2) -> void :
	for key: String in Atlas.TAB_ORDER:
		if key == "cv" and not _convert_open():
			continue
		var t: Array = Atlas.TABS[key]
		var at: Vector2 = base + _hv(t)
		var chosen: bool = key == _state
		var rect: Rect2 = _fblit("hp_tab_on" if chosen else "hp_tab_off", at, 0.0, 0.0, Color.WHITE if chosen else _glow("tab:" + key))
		_fblit("hp_tw_" + key, at + _hv(t, 4))
		if not chosen:
			_hit("tab:" + key, rect, false)
		if bool(_dots.get(key, false)) and Atlas.DOTS.has(key):
			_fblit("hp_dot", base + _hv(Atlas.DOTS[key]))


func _draw_frame_help(base: Vector2) -> void :
	var label: Array = Atlas.HELP.label
	var mark: Array = Atlas.HELP.help
	var wide: float = _hlink(HELP_LABEL, base + _hv(label), float(label[2]))
	_hit("help:helper", Rect2((base + _hv(mark)) * _f, Vector2(float(label[0]) - float(mark[0]) + wide + 2.0, 18.0) * _f), false)
	var split: Array = Atlas.HELP.split
	_hit("help:split", Rect2((base + _hv(split)) * _f, Vector2(float(split[2]), float(split[3])) * _f), false)


func _draw_lab(at: Vector2) -> void :
	var spec: Dictionary = Atlas.LAB[_state]
	var rec: Dictionary = _find(_lead)
	_draw_under(at, spec)
	for one: Array in spec.boxes:
		_draw_box(str(one[0]), str(one[1]), at + _hv(one, 2))
	if spec.top != null:
		_fblit("hp_lab_%s_top" % _state, at + _hv(spec.top))
	match _state:
		"lv":
			_draw_level(at, spec, rec)
		"st", "gr":
			_draw_grow(at, spec, rec)
		"cv":
			_draw_convert(at, spec, rec)
	_draw_attrs(at, spec, rec)
	if _state == "lv" and not rec.is_empty() and int(rec.lv) >= int(rec.lv_max):
		_fblit("hp_lv_max", at + _hv(spec.max))
	else:
		_fbutton("do", "hp_ok_" + _state, at + _hv(spec.ok))
	for key: String in ["buy", "buy2"]:
		if spec.has(key):
			_fbutton(key, "hp_buy", at + _hv(spec[key]))
	_draw_lab_help(at, spec)


func _draw_under(at: Vector2, spec: Dictionary) -> void :
	var cell_id: String = "hp_lab_" + _state
	var full: Vector2 = _cell_size(cell_id)
	var spot: Vector2 = at + _hv(spec.under)
	var hole: Rect2 = Rect2(_hv(spec.help) - _hv(spec.under), Vector2(16, 16))
	if not Rect2(Vector2.ZERO, full).encloses(hole):
		_fblit(cell_id, spot)
		return
	for band: Rect2 in [Rect2(0, 0, full.x, hole.position.y), Rect2(0, hole.end.y, full.x, full.y - hole.end.y), 
			Rect2(0, hole.position.y, hole.position.x, 16), Rect2(hole.end.x, hole.position.y, full.x - hole.end.x, 16)]:
		if band.size.x > 0.0 and band.size.y > 0.0:
			_fpart(cell_id, spot + band.position, band)


func _draw_lab_help(at: Vector2, spec: Dictionary) -> void :
	var px: int = maxi(6, roundi(12.0 * _f))
	var wide: float = ARIAL_BOLD.get_string_size(HELP_LABEL, HORIZONTAL_ALIGNMENT_LEFT, -1, px).x / _f + 5.0
	var mark: Vector2 = _hv(spec.help)
	var right: float = mark.x + 17.0
	var spot: Vector2 = at + Vector2(right - wide - 17.0, mark.y)
	_fpart("hp_lab_" + _state, spot, Rect2(mark - _hv(spec.under), Vector2(16, 16)), _glow("help:lab"))
	_hlink(HELP_LABEL, at + Vector2(right - wide, mark.y - 2.0), wide)
	_hit("help:lab", Rect2(spot * _f, Vector2(17.0 + wide, 18.0) * _f), false)



func _draw_box(id: String, kind: String, at: Vector2) -> void :
	var b: Dictionary = Atlas.BOX[kind]
	var side: float = float(b["size"])
	var rec: Dictionary = {}
	var plus_up: bool = false
	var plus_rank: bool = false
	var item: int = 0
	var count: int = 0
	var lack: bool = false
	var result: bool = RESULT_BOX.has(id)
	if id == str(MAIN_BOX.get(_state, "")):
		rec = _find(_lead)
	elif id == SECOND_BOX:
		rec = _find(_second)
	elif result:
		rec = _find(_lead)
		plus_up = str(RESULT_BOX[id]) == "up"
		plus_rank = str(RESULT_BOX[id]) == "rank"
	elif id == str(MAT_BOX.get(_state, "")):
		if not _lack.is_empty():
			item = int(_lack[0])
			count = int(_lack[1])
			lack = true
		elif not _mat.is_empty():
			item = int(_mat.item)
			count = int(_mat.count)
			if _state == "lv":
				var used: int = 0
				for take: int in _chip_cut().values():
					used += take
				count = maxi(1, used)
			elif _state == "st" or _state == "gr":
				count = maxi(1, int(_mat.used))
	elif id in NANO_BOX:
		var slot: int = int(_nano[NANO_BOX.find(id)])
		if slot >= 0:
			var inst: Dictionary = client.bag_item(3, slot)
			item = int(inst.get("m_templateId", 0))
			count = 1
	_fblit(str(b.bg), at)
	var tip: Array = b.tip
	if not tip.is_empty() and ((rec.is_empty() and item == 0) or lack):
		_fblit(str(tip[0]), at + _hv(tip, 1), float(tip[3]), float(tip[4]))
	var glass: Array = b.glass
	_fblit(str(glass[0]), at + _hv(glass, 1), float(glass[3]), float(glass[4]))
	var rect: Rect2 = Rect2(at * _f, Vector2(side, side) * _f)
	if not rec.is_empty():
		_draw_helper_box(rec, b, at, plus_up, plus_rank)
		if not result:
			_hit("box:" + id, rect, false)
			_htip_on("box:" + id, rect, rec, "", false)
		else:

			_hit("show:" + id, rect, false)
			_htip_on("show:" + id, rect, rec, id, false)
		return
	if item == 0:
		return
	var info: Array = _item(item)
	var path: String = str(info[2])
	if lack:
		if not path.is_empty():
			_hfit(pack.picture(path), at + _hv(b.lack), _hv(b.lack, 2), 2.0, LACK_TINT)
		_hlabel("%d/%d" % [HelperModel.have(client.bags, item), count], b.num, at, COIN_LOW)
	else:
		if not path.is_empty():
			_hfit(pack.picture(path), at + _hv(b.item), _hv(b.item, 2))
		_hlabel(str(count), b.num, at)
	_hit("box:" + id, rect, false)
	_tip_on("box:" + id, rect, GarageModel.cap(str(info[0])), str(info[1]), BagModel.tint(int(info[3]), Color.WHITE))


func _draw_helper_box(rec: Dictionary, b: Dictionary, at: Vector2, plus_up: bool, plus_rank: bool) -> void :
	if not str(rec.icon).is_empty():
		_hfit(pack.picture(str(rec.icon)), at + _hv(b.item), _hv(b.item, 2))
	var star: Array = b.star
	_fblit("hp_star", at + _hv(star), float(star[2]), float(star[3]))
	var rank: int = mini(int(rec.rank) + (1 if plus_rank else 0), int(rec.rank_max))
	_hgrad("%d/%d" % [rank, int(rec.rank_max)], b.lbl_star, at)
	if int(rec.up) != 0:
		_hbar(b.bar, b.rule, at, mini(int(rec.up) + (1 if plus_up else 0), int(rec.up_max)), int(rec.up_max))
	_hgrad(str(int(rec.apt)), b.pot, at)


func _draw_level(at: Vector2, spec: Dictionary, rec: Dictionary) -> void :
	var texts: Dictionary = spec.texts
	var need: int = 0
	var gained: int = 0
	if not rec.is_empty():
		_hlabel("LV.%d" % int(rec.lv), texts.lblNowLevel, at)
		_hlabel("LV.%d" % mini(int(rec.lv) + 1, int(rec.lv_max)), texts.lblNextLevel, at)
		if int(rec.lv) >= int(rec.lv_max):
			return
		need = HelperModel.exp_need(pack.helper, int(rec.lv))
		gained = int(rec.exp)
	_fblit("hp_exp_box", at + _hv(spec.exp_box))
	var frame: int = clampi(int(gained * 101.0 / need) if need > 0 else 0, 0, Atlas.EXP_W.size() - 1)
	var w: float = float(Atlas.EXP_W[frame])
	if w > 0.0:
		var spot: Vector2 = at + _hv(spec.exp_bar)
		_fblit("hp_exp_l", spot)
		if w > 16.0:
			_fblit("hp_exp_m", spot + Vector2(8, 0), w - 16.0, 17.0)
		_fblit("hp_exp_r", spot + Vector2(w - 8.0, 0))
	_hlabel("%d%%" % (int(gained * 100.0 / need) if need > 0 else 0), texts.lblExpPer, at)
	_hlabel("%d/%d" % [gained, need], texts.lblExp, at)


func _draw_grow(at: Vector2, spec: Dictionary, rec: Dictionary) -> void :
	var texts: Dictionary = spec.texts
	var row: Array = _row_for(rec)
	var cost: int = 0 if rec.is_empty() else int(rec.rankc if _state == "gr" else rec.upc)
	var top: int = int(row[3]) if not row.is_empty() else 0
	var used: int = mini(cost, top)
	var frame: int = clampi(int(used * 101.0 / top) if top > 0 else 0, 1, Atlas.UP_W.size())
	var spot: Vector2 = at + _hv(spec.up_bar)
	var track: Rect2 = _fblit("hp_up_track", spot)
	_fpart("hp_up_fill", spot + Vector2(3, 3), Rect2(0, 0, float(Atlas.UP_W[frame - 1]), 6))
	_tip_at(track, "Mức hoàn thành", UP_TIP, Color.WHITE)
	if _state == "st" and not rec.is_empty():
		_hlabel(str(int(rec.up)), texts.lblStrengthenCount, at)
	if rec.is_empty() or row.is_empty():
		return
	_hlabel(str(int(row[5])), texts.lblNeedCoin, at, COIN_LOW if int(row[5]) > _golden() else Color(0, 0, 0, 0))
	_hlabel("%d%%" % _success(rec), texts.lblSuccess, at)
	_hlabel(str(int(float(used) / top * 100.0)), texts.lblLuck, at)


func _draw_convert(at: Vector2, spec: Dictionary, rec: Dictionary) -> void :
	var texts: Dictionary = spec.texts
	for key: String in ["label1", "_HelperLabFrame_Label3"]:
		_hlabel("LV:", texts[key], at)
	for key: String in ["_HelperLabFrame_Label9", "_HelperLabFrame_Label5"]:
		_hlabel("Lượt cường hóa:", texts[key], at)
	var two: Dictionary = _find(_second)
	if not rec.is_empty():
		_hlabel(str(int(rec.lv)), texts.lblMainLevelCount, at)
		_hlabel(str(int(rec.up)), texts.lblMainStthCount, at)
	if not two.is_empty():
		_hlabel(str(int(two.lv)), texts.lblSecondLevelCount, at)
		_hlabel(str(int(two.up)), texts.lblSecondStthCount, at)


func _draw_attrs(at: Vector2, spec: Dictionary, rec: Dictionary) -> void :
	var table: Array = spec.attrs
	for i in range(table.size()):
		var row: Array = table[i]
		var spot: Vector2 = at + _hv(row, 1)
		var kind: int = int(row[3])
		if _state == "st":
			kind = 0 if rec.is_empty() else int(rec.tpl[9 if i == 0 else 12])
			_hlabel(":" if rec.is_empty() else str(SHORT.get(kind, "")), Atlas.ATTR.lblName, spot)
		else:
			_hlabel(str(LONG.get(kind, "")), Atlas.ATTR.lblName, spot)
		if rec.is_empty() or kind < 1 or kind > 4:
			continue
		var now: int = HelperModel.attr(rec, pack.helper, kind)
		var later: int = now
		match _state:
			"lv":
				if int(rec.lv) < int(rec.lv_max):
					later = HelperModel.attr(rec, pack.helper, kind, int(rec.lv) + 1)
			"st":
				if int(rec.up) < int(rec.up_max):
					later = HelperModel.attr(rec, pack.helper, kind, -1, float(int(rec.up) + 1))
			"gr":
				if int(rec.rank) < int(rec.rank_max):
					later = HelperModel.attr(rec, pack.helper, kind, -1, -1.0, float(int(rec.rank) + 1))
		_hlabel(str(now), Atlas.ATTR.lblnow, spot)
		_hlabel(str(later), Atlas.ATTR.lblNext, spot)
		if later != now:
			_hlabel("+%d" % (later - now), Atlas.ATTR.lblChange, spot)


func _draw_helpers(base: Vector2) -> void :
	var grid: Dictionary = Atlas.GRIDS.helper
	var cols: int = int(grid.cols)
	var step: float = float(grid.step)
	var first: Vector2 = base + _hv(grid.first)
	var from: int = _helper_row * cols
	var cell: Dictionary = Atlas.CELL

	var cross: Dictionary = {"lv": "gr", "st": "st", "gr": "lv"}
	var dot: bool = bool(_dots.get(str(cross.get(_state, "")), false))
	for i in range(cols * int(grid.rows)):
		var spot: Vector2 = first + Vector2((i % cols) * step, floori(float(i) / cols) * step)
		_fblit("hp_cell_bg", spot)
		if from + i >= _list.size():
			continue
		var rec: Dictionary = _list[from + i]
		if _in_lab(str(rec.uuid)):
			if rec.battle:
				_fblit("hp_cell_battle", spot + _hv(cell.battle))
			continue
		_draw_cell_helper(rec, spot)
		var id: String = "cell:" + str(rec.uuid)
		var rect: Rect2 = Rect2(spot * _f, _hv(cell.bg, 2) * _f)
		_hit(id, rect)
		_htip_on(id, rect, rec, "", from + i >= 15)
		if rec.battle and dot:
			_fblit("hp_dot", spot + _hv(cell.dot))
	_draw_scroll("helper", _list.size(), base)


func _draw_cell_helper(rec: Dictionary, spot: Vector2) -> void :
	var cell: Dictionary = Atlas.CELL
	if rec.battle:
		_fblit("hp_cell_item", spot + _hv(cell.item_bg))
	var quality: int = int(rec.quality)
	if quality >= 2 and quality <= 5:
		_fblit("hp_q%d" % quality, spot + _hv(cell.quality))
	if not str(rec.icon).is_empty():
		_hfit(pack.picture(str(rec.icon)), spot + _hv(cell.icon), _hv(cell.icon, 2))
	var star: Array = cell.star
	_fblit("hp_star", spot + _hv(star), float(star[2]), float(star[3]))
	_hgrad("%d/%d" % [int(rec.rank), int(rec.rank_max)], cell.lbl_star, spot)
	if int(rec.up) != 0:
		_hbar(cell.bar, cell.rule, spot, int(rec.up), int(rec.up_max))
	_hgrad(str(int(rec.apt)), cell.pot, spot)
	if rec.battle:
		_fblit("hp_cell_battle", spot + _hv(cell.battle))


func _draw_materials(base: Vector2) -> void :
	var grid: Dictionary = Atlas.GRIDS.material
	var cols: int = int(grid.cols)
	var step: float = float(grid.step)
	var first: Vector2 = base + _hv(grid.first)
	var list: Array = _mat_list()
	var from: int = _mat_row * cols
	var cell: Dictionary = Atlas.CELL
	for i in range(cols * int(grid.rows)):
		var spot: Vector2 = first + Vector2((i % cols) * step, floori(float(i) / cols) * step)
		_fblit("hp_cell_bg", spot)
		if from + i >= list.size():
			continue
		var stack: Dictionary = list[from + i]
		var left: int = _left(stack)
		if left <= 0:
			continue
		var info: Array = _item(int(stack.item))
		var quality: int = int(info[3])
		if quality >= 2 and quality <= 5:
			_fblit("hp_q%d" % quality, spot + _hv(cell.quality))
		if not str(info[2]).is_empty():
			_hfit(pack.picture(str(info[2])), spot + _hv(cell.icon), _hv(cell.icon, 2))
		if left > 1:
			_hlabel(str(left), cell.num, spot)
		var id: String = "mat:%d" % int(stack.slot)
		var rect: Rect2 = Rect2(spot * _f, _hv(cell.bg, 2) * _f)
		_hit(id, rect)
		_tip_on(id, rect, GarageModel.cap(str(info[0])), str(info[1]), BagModel.tint(quality, Color.WHITE))
	_draw_scroll("material", list.size(), base)


func _draw_scroll(grid: String, count: int, base: Vector2) -> void :
	var spec: Dictionary = Atlas.GRIDS[grid]
	var shown: int = int(spec.rows)
	var total: int = _lines(count)
	if total <= shown:
		return
	var b: Array = spec.box
	var spot: Vector2 = base + Vector2(float(b[0]) + float(b[2]) - 19.0, float(b[1]))
	var high: float = float(b[3])
	_fbutton("sb:%s:up" % grid, "hp_sb_up", spot)
	_fbutton("sb:%s:down" % grid, "hp_sb_down", spot + Vector2(0, high - 19.0))
	var track: float = high - 38.0
	_hslice("hp_sb_bk", spot + Vector2(0, 19), track)
	var row: int = _helper_row if grid == "helper" else _mat_row
	var thumb: float = maxf(20.0, track * shown / total)
	var y: float = (track - thumb) * row / maxf(1.0, float(total - shown))
	_hslice("hp_sb_thumb", spot + Vector2(0, 19.0 + y), thumb)
	_knob_hit("slide:" + grid, Rect2((spot + Vector2(0, 19.0 + y)) * _f, Vector2(19, thumb) * _f), row, total - shown, (track - thumb) * _f, 
		func(value: float) -> void : _scroll(grid, roundi(value) - (_helper_row if grid == "helper" else _mat_row)))


func _tip_on(id: String, rect: Rect2, title: String, body: String, tint: Color) -> void :
	if _hover == id and _press.is_empty():
		_tip = [rect, title, body, tint]


func _tip_at(rect: Rect2, title: String, body: String, tint: Color) -> void :
	if _hover == "panel" and _press.is_empty() and rect.has_point(get_local_mouse_position()):
		_tip = [rect, title, body, tint]



func _htip_on(id: String, rect: Rect2, rec: Dictionary, result: String, compare: bool) -> void :
	if _hover == id and _press.is_empty():
		_tip = []
		_htip = [rec, result, compare]


func _draw_htip() -> void :
	var rec: Dictionary = _htip[0]
	var more: Dictionary = pack.bag.get("more", {})
	if (rec.get("tpl", []) as Array).size() < 17:
		_tip = [Rect2(get_local_mouse_position(), Vector2.ONE), GarageModel.cap(str(rec.name)), _helper_lines(rec), BagModel.tint(int(rec.quality), Color.WHITE)]
		_htip = []
		_draw_tip()
		return
	HelperTip.show(self, _f, Vector2(_fw, _fh), get_local_mouse_position() / _f, client, pack.helper, more, rec, 
		HelperTip.context(client, rec, more, str(_htip[1])), bool(_htip[2]), pack.picture)


func _helper_lines(rec: Dictionary) -> String:
	var lines: PackedStringArray = PackedStringArray([
		"Loại: %s" % str(HelperModel.TYPES.get(int(rec.type), "—")), 
		"Tư chất: %d" % int(rec.apt), 
		"LV: %d/%d" % [int(rec.lv), int(rec.lv_max)], 
		"Cường hóa: %d/%d" % [int(rec.up), int(rec.up_max)], 
		"Sao: %d/%d" % [int(rec.rank), int(rec.rank_max)], 
		"Chiến Lực: %d" % int(rec.score)])
	if rec.battle:
		lines.append("Đang ra trận")
	return "\n".join(lines)




func _draw_instr() -> void :
	var key: String = _sheet_key if Atlas.INSTR.has(_sheet_key) else "level"
	var spec: Dictionary = Atlas.INSTR[key]
	var area: Array = spec["size"]
	var at: Vector2 = _window(float(area[0]), float(area[1]))
	_hlabel(str(INSTR_TITLE.get(key, HELP_LABEL)), spec.title, at)
	if key == "helper":
		_draw_instr_helper(at, spec)
	else:
		var desc: Array = spec.desc
		var font: Font = BOLD if key in ["level", "split"] else REGULAR
		var lines: int = maxi(1, int(float(desc[3]) * _f / _face(font).get_height(maxi(6, roundi(12.0 * _f)))))
		_hpara(str(INSTR_TEXT.get(key, "")), font, 12.0, Color.WHITE, at + _hv(desc), float(desc[2]), HELP_RIM, lines)
	_fbutton("ok", "hp_instr_ok", at + _hv(spec.ok))


func _draw_instr_helper(at: Vector2, spec: Dictionary) -> void :
	var bubbles: Array = spec.bubbles
	var fill: Color = Color(str(spec.bubble_bg))
	for i in range(mini(bubbles.size(), BUBBLES.size())):
		var one: Array = bubbles[i]
		_round(Rect2((at + _hv(one)) * _f, _hv(one, 2) * _f), fill, 16.0)
		_fpara(str(BUBBLES[i]), BOLD, 12.0, Color.WHITE, at + _hv(one, 4), float(one[6]))
	var sample: Dictionary = {}
	for rec: Dictionary in _list:
		if rec.battle:
			sample = rec
	if sample.is_empty() and not _list.is_empty():
		sample = _list[0]
	var b: Dictionary = Atlas.BOX.l
	var spot: Vector2 = at + _hv(spec.sample)
	_fblit(str(b.bg), spot)
	var glass: Array = b.glass
	_fblit(str(glass[0]), spot + _hv(glass, 1), float(glass[3]), float(glass[4]))
	if not sample.is_empty():
		_draw_helper_box(sample, b, spot, false, false)
	_fblit("hp_pve", at + _hv(spec.pve), 30.0, 27.0)
	_hlabel(PVE_TEXT, spec.pve_text, at, Color(0, 0, 0, 0), 0.0)


func _draw_ask() -> void :
	var at: Vector2 = _shade(450.0, 220.0)
	_fblit("hp_ask_guy", at + Vector2(-80, -76))
	_fblit("hp_ask", at + _hv(Atlas.ASK.panel))
	var words: Array = Atlas.ASK.txtContent
	_fpara(str(_ask.get("text", "")), BOLD, float(words[4]), Color.WHITE, at + _hv(words), float(words[2]), 5)
	_fbutton("ok", "hp_ask_ok", at + _hv(Atlas.ASK.btnConfirm))
	_fbutton("cancel", "hp_ask_no", at + _hv(Atlas.ASK.btnCancel))


func _draw_tip() -> void :
	if not _htip.is_empty():
		_draw_htip()
		return
	if _tip.is_empty():
		return
	var anchor: Rect2 = _tip[0]
	var body: String = str(_tip[2])
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 8)


func _shade(wide: float, high: float) -> Vector2:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(wide, high)
	_hit("panel", Rect2(at * _f, Vector2(wide, high) * _f), false)
	return at




func _hfit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0, tint: Color = Color.WHITE) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false, tint)


func _hslice(cell_id: String, at: Vector2, high: float) -> void :
	var cell: Array = _cells.get(cell_id, [])
	if cell.is_empty() or cell[0] == null or high <= 0.0:
		return
	var region: Array = cell[1]
	var w: float = float(region[2])
	var full: float = float(region[3])
	var cap: float = minf(6.0, floorf(high / 2.0))
	_fpart(cell_id, at, Rect2(0, 0, w, cap))
	_fpart(cell_id, at + Vector2(0, high - cap), Rect2(0, full - cap, w, cap))
	if high - 2.0 * cap > 0.0:
		draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, cap)) * _f, Vector2(w, high - 2.0 * cap) * _f), Rect2(float(region[0]), float(region[1]) + cap, w, full - 2.0 * cap))



func _hlabel(text: String, spec: Array, base: Vector2, tint: Color = Color(0, 0, 0, 0), edge: float = 1.0, rim: Color = SHADE) -> float:
	if text.is_empty():
		return 0.0
	var wide: float = float(spec[2])
	var align: String = str(spec[7])
	var at: Vector2 = base + _hv(spec)
	var shrink: bool = wide > 0.0
	if wide <= 0.0:
		wide = 400.0
		if align == "r":
			at.x -= wide
		elif align == "c":
			at.x -= wide / 2.0
	return _fwords(text, BOLD if int(spec[6]) == 1 else REGULAR, float(spec[4]), tint if tint.a > 0.0 else Color(str(spec[5])), align, at, wide, edge, float(spec[3]), shrink, rim)




func _hgrad(text: String, spec: Array, base: Vector2) -> float:
	var px: float = float(spec[4])
	var high: float = float(spec[3]) if float(spec[3]) > 0.0 else GradLabel.measured_high(px)
	return GradLabel.flex(self, text, _face(BOLD if int(spec[6]) == 1 else REGULAR), px, base + _hv(spec), high, _f)


func _hbar(bar: Array, rule: Array, at: Vector2, up: int, up_max: int) -> void :
	var cell_id: String = str(bar[0])
	var spot: Vector2 = at + _hv(bar, 1)
	var w: float = float(bar[3])
	var h: float = float(bar[4])
	_fblit(cell_id, spot, 0.0, 0.0, Color(1, 1, 1, 0.5))
	if up_max <= 0:
		return
	var steps: int = clampi(ceili(float(mini(up, up_max)) / (float(up_max) / 10.0)), 0, 10)
	var y_off: float = maxf(0.0, float(rule[2]) - steps * float(rule[0]) + float(rule[1]))
	if y_off < h:
		_fpart(cell_id, spot + Vector2(0, y_off), Rect2(0, 0, w, h - y_off))


func _hpara(text: String, font: Font, px: float, color: Color, at: Vector2, wide: float, rim: Color, lines: int = -1) -> void :
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	var origin: Vector2 = Vector2(at.x, at.y + 2.0) * _f + Vector2(0, face.get_ascent(font_size))
	draw_multiline_string_outline(face, origin, text, HORIZONTAL_ALIGNMENT_LEFT, wide * _f, font_size, lines, maxi(1, roundi(_f)), rim)
	draw_multiline_string(face, origin, text, HORIZONTAL_ALIGNMENT_LEFT, wide * _f, font_size, lines, color)


func _hlink(text: String, at: Vector2, wide: float) -> float:
	var shown: float = _fwords(text, BOLD, 12.0, HELP_INK, "l", at, wide, 1.0, 0.0, false, HELP_RIM)
	var y: float = at.y + 2.0 + 12.0 * 0.55 + 6.0
	draw_line(Vector2(at.x, y) * _f, Vector2(at.x + shown, y) * _f, HELP_INK, maxf(1.0, _f))
	return shown
