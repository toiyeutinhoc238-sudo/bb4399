extends RefCounted













const GRADUATE_LEVEL: int = 18
const PRENTICE_LIMIT: int = 5
const PER_PAGE: int = 10
const SRS_MASTER: int = 1
const SRS_PRENTICE: int = 2
const MAT_RECEIVE_PRENTICE: int = 0
const MAT_ENGAGE_MASTER: int = 1
const PLT_MASTERLIST: int = 12
const PLT_PRENTICELIST: int = 13
const CSOT_TRAINEE: int = 1
const SEND_OK: Array = [708, 709, 710, 711, 712, 713, 716]
const RECEIVE: Array = [1703, 1905, 1906, 1907, 1908, 1909, 1910, 1911, 1913]
const QST_GOING: int = 2
const QST_COMPLETE: int = 3
const QST_OVER: int = 4
const APPLY_TIP: String = "Nhận 1 yêu cầu bái sư"

var master: Dictionary = {}
var prentices: Array = []
var master_apply: Array = []
var prentice_apply: Array = []
var real_apply: Array = []
var find_list: Array = []
var find_type: int = 0
var find_page: int = 1
var master_rev: int = 0
var prentice_rev: int = 0
var apply_rev: int = 0
var real_rev: int = 0
var find_rev: int = 0
var quests: Dictionary = {}
var quest_rev: int = 0
var quest_tick: int = 0
var tips: Array = []
var my_uuid: String = ""
var level: int = 0



func receive(type: int, value: Dictionary, uuid: String, char_level: int) -> bool:
	if type not in RECEIVE:
		return false
	my_uuid = uuid
	level = char_level
	match type:
		1703:
			var kind: int = int(value.get("m_listType", 0))
			if kind != PLT_MASTERLIST and kind != PLT_PRENTICELIST:
				return false
			find_type = kind
			find_page = int(value.get("m_pageNumber", 1))
			find_list = _array(value.get("m_playerList", []))
			find_rev += 1
		1905:
			_add_apply(value)
		1906:
			_init_relations(_array(value.get("m_vecMPBrief", [])))
		1907:
			var made: Dictionary = _dict(value.get("m_mpBrief", {}))
			_analyze(made)
			if int(made.get("m_nIdentity", 0)) == SRS_PRENTICE:
				del_apply(_uuid(made))
		1908:
			_analyze(_dict(value.get("m_mpBrief", {})))
		1909:
			quests[str(value.get("m_strUuid", ""))] = _array(value.get("m_vecQuest", []))
			quest_rev += 1
		1910:
			_update_quest(str(value.get("m_strUuid", "")), _dict(value.get("m_nQuestInfo", {})))
		1911:
			if int(value.get("m_nType", 0)) != CSOT_TRAINEE:
				return false
			var gone: String = str(value.get("m_tgtUuid", ""))
			if not master.is_empty() and _uuid(master) == gone:
				master = {}
				master_rev += 1
			else:
				remove_prentice(gone)
		1913:
			real_apply = _array(value.get("m_applyList", []))
			prentice_apply = real_apply.duplicate()
			real_rev += 1
	return true

func clear() -> void :
	master = {}
	prentices = []
	master_apply = []
	prentice_apply = []
	real_apply = []
	find_list = []
	find_type = 0
	find_page = 1
	quests = {}
	tips = []
	quest_rev += 1
	quest_tick += 1
	master_rev += 1
	prentice_rev += 1
	apply_rev += 1
	real_rev += 1
	find_rev += 1




func have_master() -> bool:
	return not master.is_empty() and _uuid(master) != my_uuid

func has_prentice() -> bool:
	return not prentices.is_empty()


func can_be_master() -> bool:
	return master.is_empty() and level >= GRADUATE_LEVEL


func apply_list() -> Array:
	return prentice_apply if can_be_master() else master_apply


func relation_list() -> Array:
	if not master.is_empty():
		return [_dict(master.get("m_brief", {}))]
	var out: Array = []
	for one: Dictionary in prentices:
		out.append(_dict(one.get("m_brief", {})))
	return out

func del_apply(uuid: String) -> void :
	var list: Array = apply_list()
	for i in range(list.size()):
		if str(_dict(list[i]).get("m_charUuid", "")) == uuid:
			list.remove_at(i)
			apply_rev += 1
			return

func remove_prentice(uuid: String) -> void :
	for i in range(prentices.size()):
		if _uuid(prentices[i]) == uuid:
			prentices.remove_at(i)
			prentice_rev += 1
			return

func _init_relations(list: Array) -> void :
	for one: Variant in list:
		var brief: Dictionary = _dict(one)
		match int(brief.get("m_nIdentity", 0)):
			SRS_MASTER:
				master = brief
				master_rev += 1
				return
			SRS_PRENTICE:


				var uuid: String = _uuid(brief)
				var found: bool = false
				for i in range(prentices.size()):
					if _uuid(prentices[i]) == uuid:
						prentices[i] = brief
						found = true
						break
				if not found:
					prentices.append(brief)
	prentice_rev += 1


func _analyze(brief: Dictionary) -> void :
	match int(brief.get("m_nIdentity", 0)):
		SRS_MASTER:
			master = brief
			master_rev += 1
		SRS_PRENTICE:
			var uuid: String = _uuid(brief)
			for i in range(prentices.size()):
				if _uuid(prentices[i]) == uuid:
					prentices[i] = brief
					prentice_rev += 1
					return
			prentices.append(brief)
			prentice_rev += 1


func _update_quest(uuid: String, info: Dictionary) -> void :
	if not quests.has(uuid):
		return
	var id: int = int(info.get("m_nQuestId", 0))
	for one: Variant in quests[uuid]:
		var quest: Dictionary = _dict(one)
		if int(quest.get("m_nQuestId", -1)) == id:
			quest["m_nState"] = int(info.get("m_nState", 0))
			quest["m_nCheckCount"] = int(info.get("m_nCheckCount", 0))
			quest_tick += 1
			return



func sort_quests(uuid: String) -> Array:
	if not quests.has(uuid):
		return []
	var list: Array = quests[uuid]
	flash_sort(list, _rule_quest)
	return list


static func _rule_quest(a: Variant, b: Variant) -> int:
	var x: Dictionary = _dict(a)
	var y: Dictionary = _dict(b)
	if int(x.get("m_nState", 0)) == QST_COMPLETE or int(y.get("m_nState", 0)) == QST_COMPLETE:
		return -1
	if int(x.get("m_nState", 0)) == QST_OVER or int(y.get("m_nState", 0)) == QST_OVER:
		return 1
	return 1 if int(x.get("m_nQuestId", 0)) > int(y.get("m_nQuestId", 0)) else -1


static func flash_sort(list: Array, cmp: Callable) -> void :
	if list.size() < 2:
		return
	var stack: Array = []
	var lo: int = 0
	var hi: int = list.size() - 1
	while true:
		var span: int = hi - lo + 1
		if span == 3:
			if cmp.call(list[lo], list[lo + 1]) > 0:
				_swap(list, lo, lo + 1)
				if cmp.call(list[lo + 1], list[lo + 2]) > 0:
					_swap(list, lo + 1, lo + 2)
					if cmp.call(list[lo], list[lo + 1]) > 0:
						_swap(list, lo, lo + 1)
			elif cmp.call(list[lo + 1], list[lo + 2]) > 0:
				_swap(list, lo + 1, lo + 2)
				if cmp.call(list[lo], list[lo + 1]) > 0:
					_swap(list, lo, lo + 1)
		elif span == 2:
			if cmp.call(list[lo], list[lo + 1]) > 0:
				_swap(list, lo, lo + 1)
		elif span >= 4:
			_swap(list, lo + span / 2, lo)
			var left: int = lo
			var right: int = hi + 1
			while true:
				left += 1
				while left <= hi and cmp.call(list[left], list[lo]) <= 0:
					left += 1
				right -= 1
				while right > lo and cmp.call(list[right], list[lo]) >= 0:
					right -= 1
				if right < left:
					break
				_swap(list, left, right)
			_swap(list, lo, right)
			if right - 1 - lo >= hi - left:
				if lo + 1 < right:
					stack.append([lo, right - 1])
				if left < hi:
					lo = left
					continue
			else:
				if left < hi:
					stack.append([left, hi])
				if lo + 1 < right:
					hi = right - 1
					continue
		if stack.is_empty():
			return
		var top: Array = stack.pop_back()
		lo = int(top[0])
		hi = int(top[1])

static func _swap(list: Array, i: int, j: int) -> void :
	var keep: Variant = list[i]
	list[i] = list[j]
	list[j] = keep

func _add_apply(value: Dictionary) -> void :
	var buddy: Dictionary = _dict(value.get("m_Buddy", {}))
	var list: Array = prentice_apply if int(value.get("m_nApplyType", 0)) == MAT_ENGAGE_MASTER else master_apply
	var uuid: String = str(buddy.get("m_charUuid", ""))
	for one: Variant in list:
		if str(_dict(one).get("m_charUuid", "")) == uuid:
			return
	list.append(buddy)
	apply_rev += 1
	tips.append(APPLY_TIP)

static func _uuid(brief: Variant) -> String:
	return str(_dict(_dict(brief).get("m_brief", {})).get("m_charUuid", ""))

static func _dict(value: Variant) -> Dictionary:
	return value if value is Dictionary else {}

static func _array(value: Variant) -> Array:
	return (value as Array).duplicate() if value is Array else []



static func pad(body: PackedByteArray) -> PackedByteArray:
	var out: PackedByteArray = body.duplicate()
	out.resize(out.size() + (8 - (6 + out.size()) % 8) % 8)
	return out

static func _utf(out: StreamPeerBuffer, text: String) -> void :
	var bytes: PackedByteArray = text.to_utf8_buffer()
	out.put_u16(bytes.size())
	out.put_data(bytes)

static func _buffer() -> StreamPeerBuffer:
	var out: StreamPeerBuffer = StreamPeerBuffer.new()
	out.big_endian = false
	return out


static func square_list(kind: int, page: int, per: int = PER_PAGE) -> PackedByteArray:
	var out: StreamPeerBuffer = _buffer()
	out.put_u32(kind)
	out.put_u32(page)
	out.put_u32(per)
	return pad(out.data_array)


static func apply_relation(uuid: String, apply_type: int) -> PackedByteArray:
	var out: StreamPeerBuffer = _buffer()
	_utf(out, uuid)
	out.put_u32(apply_type)
	return pad(out.data_array)


static func uuid_only(uuid: String) -> PackedByteArray:
	var out: StreamPeerBuffer = _buffer()
	_utf(out, uuid)
	return pad(out.data_array)


static func delete_relation(uuid: String) -> PackedByteArray:
	var out: StreamPeerBuffer = _buffer()
	out.put_u32(CSOT_TRAINEE)
	_utf(out, uuid)
	return pad(out.data_array)


static func award_request(uuid: String, cond: int) -> PackedByteArray:
	var out: StreamPeerBuffer = _buffer()
	_utf(out, uuid)
	out.put_u32(cond)
	return pad(out.data_array)


static func apply_list_request() -> PackedByteArray:
	return pad(PackedByteArray())
