extends RefCounted







const QUEST_DONE: int = 3
const QUEST_TYPES: Array = [3, 41, 4, 5, 10, 11, 12, 21, 22, 23, 24, 25, 42]
const T_TYPE: int = 0
const T_SHOW: int = 15
const FIZZ_FROM: int = 700
const FIZZ_TO: int = 706
const FPS: float = 24.0
const UNKNOWN: int = -1
const NONE: int = 0
const HAS: int = 1


static func quest_due(quests: Dictionary, templates: Dictionary) -> bool:
	if templates.is_empty():
		return false
	for key: Variant in quests:
		var info: Variant = quests[key]
		if not (info is Array) or (info as Array).is_empty() or int(info[0]) != QUEST_DONE:
			continue
		var row: Variant = templates.get(str(int(key)))
		if row is Array and (row as Array).size() > T_SHOW and int(row[T_SHOW]) == 1 and QUEST_TYPES.has(int(row[T_TYPE])):
			return true
	return false


static func fizz_state(stages: Dictionary, cleared: Dictionary) -> int:
	for stage: int in range(FIZZ_FROM, FIZZ_TO + 1):
		if stages.has(stage):
			return HAS if int((stages[stage] as Dictionary).get("reward", 0)) == 1 else NONE
	for stage: int in range(FIZZ_FROM, FIZZ_TO + 1):
		if cleared.has(stage):
			return NONE
	return UNKNOWN


static func frame(seconds: float, frames: int) -> int:
	return int(maxf(0.0, seconds) * FPS) % maxi(1, frames)
