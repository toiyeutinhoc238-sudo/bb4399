extends RefCounted





const Atlas = preload("guide_atlas.gd")

const META: String = "gda_guide"
const NEW: int = 1
const GOING: int = 2
const COMPLETE: int = 3
const OVER: int = 4
const MAX_STEP: int = 4294967295
const DIALOG: int = 1
const ENTER_MAP: int = 2

const GATED_GOING: Array = ["package", "shop", "tankWindow", "tankTryList", "selectTank", "clanView", "talentWindow", "crystalWindow", "activeView"]
const GATED_COMPLETE: Array = ["package", "shop", "tankWindow", "tankTryList", "clanView", "talentWindow", "crystalWindow", "activeView"]
const WORLD: Array = ["lobby", "hall", "room", "battle"]



const MODULE: Dictionary = {"tankWindow": "tank", "tankTryList": "tank", "selectTank": "tank", "crystalWindow": "crystal"}
const GET_AWARD: String = "Nhấn nhận thưởng"

signal going(row: Dictionary)
signal complete(row: Dictionary)
signal direct(id: int)

var client: Node
var guided: Dictionary = {}
var directs: Dictionary = {}
var last_going: Dictionary = {}
var last_complete: Dictionary = {}
var temp: Dictionary = {}
var direct_open: bool = false
var pending: int = 0
var tip: Dictionary = {}
var tip_set: bool = false
var sent_maps: Array = []
var loaded: Dictionary = {}
var award: int = 0
var closing: String = ""
var _oid: int = -1
var _away: bool = true


func sync() -> void :
	if client == null:
		return
	if str(client.state) not in WORLD:
		_away = true
		return
	if _away or int(client.account_oid) != _oid:
		_away = false
		_oid = int(client.account_oid)
		guided.clear()
		directs.clear()
		last_going = {}
		last_complete = {}
		temp = {}
		direct_open = false
		pending = 0
		tip = {}
		tip_set = false
		loaded.clear()
		award = 0
		closing = ""


static func row(quest: int, state: int, step: int) -> Dictionary:
	var data: Array = Atlas.GUIDE.get("%d:%d:%d" % [quest, state, step], [])
	if data.is_empty():
		return {}
	return {"quest": quest, "state": state, "step": step, "modal": int(data[0]) == 1, "ui": str(data[1]), "button": str(data[2]), 
		"arrow": str(data[3]), "x": int(data[4]), "y": int(data[5]), "tip": str(data[6]), "delay": int(data[7]), "sz_state": str(data[8])}


static func direct_row(id: int) -> Dictionary:
	var data: Array = Atlas.DIRECT.get(str(id), [])
	if data.is_empty():
		return {}
	return {"id": id, "type": int(data[0]), "next": int(data[1]), "content": str(data[2]), "button": str(data[3]), "image": str(data[4]), 
		"map": int(data[5]), "quest": int(data[6]), "sound": str(data[7]), "frame_state": str(data[8])}

func info_state(quest: int) -> int:
	if client == null or not client.quests.has(quest):
		return -1
	var info: Variant = client.quests[quest]
	return int(info[0]) if info is Array and not (info as Array).is_empty() else -1

func is_guided(quest: int, state: int, step: int) -> bool:
	return guided.has(quest) and (guided[quest] as Dictionary).has(state) and int(guided[quest][state]) >= (step & 4294967295)

func set_guide_quest(quest: int, state: int, step: int) -> void :
	step = step & 4294967295
	if not guided.has(quest):
		guided[quest] = {}
	guided[quest][state] = step
	if state == GOING and row(quest, GOING, (step + 1) & 4294967295).is_empty():
		if not last_going.is_empty() and int(last_going["quest"]) == quest:
			last_going = {}



func quest_list() -> Array:
	var list: Array = []
	if client == null:
		return list
	for quest: Variant in client.quests:
		var data: Array = Atlas.QUESTS.get(str(int(quest)), [])
		if not data.is_empty() and int(data[0]) in Atlas.LIST_TYPES:
			list.append(int(quest))
	list.sort_custom(_before)
	return list


func _before(a: int, b: int) -> bool:
	var sa: int = info_state(a)
	var sb: int = info_state(b)
	if sa < 0 and sb >= 0:
		return false
	if sb < 0 and sa >= 0:
		return true
	if sa >= 0 and sb >= 0:
		if sa == COMPLETE and sb != COMPLETE:
			return true
		if sa != COMPLETE and sb == COMPLETE:
			return false
		if sa == OVER and sb != OVER:
			return false
		if sa != OVER and sb == OVER:
			return true
	var ha: int = int(Atlas.QUESTS[str(a)][1])
	var hb: int = int(Atlas.QUESTS[str(b)][1])
	if ha != hb:
		return ha > hb
	return a <= b


func check() -> void :
	sync()
	if direct_open or client == null:
		return
	var list: Array = quest_list()
	if str(client.state) != "battle":
		for quest: int in list:
			if _direct_handle(quest):
				return
	for quest: int in list:
		if _need_guide(quest):
			return

func _direct_handle(quest: int) -> bool:
	var data: Array = Atlas.QUESTS.get(str(quest), [])
	if data.is_empty():
		return false
	match info_state(quest):
		NEW, GOING:
			if int(data[2]) != 0 and not directs.has(int(data[2])):
				_show_direct_guide(int(data[2]))
				return true
		COMPLETE:
			if int(data[3]) != 0 and not directs.has(int(data[3])):
				_show_direct_guide(int(data[3]))
				return true
	return false

func _need_guide(quest: int) -> bool:
	var state: int = info_state(quest)
	if state < 0:
		return false
	var at: int = GOING if state == NEW else state
	var step: int = 0
	if at == GOING:
		step = 0 if last_going.is_empty() else int(last_going["step"])
	elif at == COMPLETE:
		step = 0 if last_complete.is_empty() else int(last_complete["step"])
	if is_guided(quest, at, step):
		return false
	var found: Dictionary = row(quest, at, step)
	if found.is_empty():
		return false
	if int(found["state"]) == state or (int(found["state"]) == GOING and state == NEW):
		if int(found["state"]) == GOING:
			show_going(quest, step)
		else:
			_tip(found)
			complete.emit(found)
		return true
	return false


func show_going(quest: int, step: int) -> void :
	var found: Dictionary = row(quest, GOING, step)
	if found.is_empty():
		return
	match str(found["ui"]):
		"checkGuide":
			check()
			return
		"enterMap":
			_tutor(int(str(found["button"])))
			return
		"setOnBattleTank":

			set_guide_quest(quest, GOING, step)
			show_going(quest, step + 1)
			return
		"checkPveOpen":

			set_guide_quest(quest, GOING, MAX_STEP)
			check()
			return
	if str(found["ui"]) in GATED_GOING and not loaded.has(MODULE.get(str(found["ui"]), "")):
		temp = found
		return
	last_going = found
	_tip(found)
	going.emit(found)


func show_complete(quest: int, step: int) -> void :
	var found: Dictionary = row(quest, COMPLETE, step)
	if found.is_empty():
		return
	match str(found["ui"]):
		"checkGuide":
			check()
			return
		"setOnBattleTank", "switchToPvp":

			set_guide_quest(quest, COMPLETE, step)
			show_complete(quest, step + 1)
			return
	if str(found["ui"]) in GATED_COMPLETE and not loaded.has(MODULE.get(str(found["ui"]), "")):
		temp = found
		return
	last_complete = found
	_tip(found)
	complete.emit(found)



func check_temp() -> bool:
	sync()
	if temp.is_empty():
		return false
	var found: Dictionary = temp
	temp = {}
	if int(found["state"]) == GOING:
		last_going = found
		_tip(found)
		going.emit(found)
	else:
		last_complete = found
		_tip(found)
		complete.emit(found)
	return true



func release_normal() -> void :
	if not tip.is_empty() and not bool(tip.get("modal", false)):
		tip = {}
		tip_set = false




func _tip(found: Dictionary) -> void :
	if int(found["state"]) == COMPLETE and int(found["step"]) == 0 and str(found["ui"]) in ["", "close"]:
		found = found.duplicate()
		found.merge({"ui": "mainLeft", "button": "cvsInsideQuest", "arrow": "left", "tip": Atlas.QUEST_DONE, "modal": false, "delay": 0, 
			"award": true}, true)
	if not tip.is_empty() and int(tip["quest"]) == int(found["quest"]) and int(tip["state"]) == int(found["state"]) and int(tip["step"]) == int(found["step"]):
		return
	tip = found
	tip_set = false


func finish_tip() -> void :
	var found: Dictionary = tip
	if found.is_empty():
		return
	tip = {}
	if not tip_set:
		set_guide_quest(int(found["quest"]), int(found["state"]), int(found["step"]))
	tip_set = false
	if bool(found.get("award", false)):
		award = int(found["quest"])
		return
	if found.has("then_close"):
		if bool(found["then_close"]):
			closing = str(found["ui"])
		return
	next_step(found)



func show_award() -> void :
	var quest: int = award
	award = 0
	var first: Dictionary = row(quest, COMPLETE, 0)
	if first.is_empty():
		return
	last_complete = first
	var found: Dictionary = first.duplicate()
	found.merge({"ui": "questWindow", "button": "btnGetReward", "arrow": "down", "x": 460, "y": 190, "tip": GET_AWARD, "modal": false, 
		"delay": 0, "then_close": str(first["ui"]) == "close"}, true)
	tip = found
	tip_set = false


func next_step(found: Dictionary) -> void :
	var quest: int = int(found["quest"])
	var step: int = int(found["step"]) + 1
	if int(found["state"]) == GOING:
		if not row(quest, GOING, step).is_empty():
			show_going(quest, step)
	elif not row(quest, COMPLETE, step).is_empty():
		show_complete(quest, step)


func _show_direct_guide(id: int) -> void :
	directs[id] = true
	show_direct(id)


func show_direct(id: int) -> void :
	var found: Dictionary = direct_row(id)
	if found.is_empty():
		return
	match int(found["type"]):
		DIALOG:
			pending = id
			direct_open = true
			direct.emit(id)
		ENTER_MAP:
			_tutor(int(found["map"]))


func direct_click(id: int) -> int:
	var found: Dictionary = direct_row(id)
	if found.is_empty():
		return id
	if int(found["map"]) != 0:
		_tutor(int(found["map"]))
		return 0
	if int(found["quest"]) != 0:

		return _next_direct(int(found["next"])) if int(found["next"]) != 0 else 0
	if int(found["next"]) != 0:
		return _next_direct(int(found["next"]))
	return 0


func _next_direct(id: int) -> int:
	var found: Dictionary = direct_row(id)
	if found.is_empty():
		return 0
	if int(found["type"]) != DIALOG:
		direct_open = false
		show_direct(id)
		return 0
	return id


func _tutor(map: int) -> void :
	if client != null and map > 0 and client.select_tutor_map(map):
		sent_maps.append(map)
