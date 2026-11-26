extends RefCounted





const Client = preload("../game_client.gd")

const STAGE: int = 800
const FIRST: int = 800
const LAST: int = 899
const RESEND: float = 3.0


static func stage(source: Client) -> Dictionary:
	if source == null or not source.stages.has(STAGE):
		return {}
	return source.stages[STAGE] as Dictionary


static func cleared(source: Client) -> bool:
	if source == null:
		return false
	for key: Variant in source.stages_cleared.keys():
		if int(key) >= FIRST and int(key) <= LAST:
			return true
	return false


static func due(source: Client) -> bool:
	return int(stage(source).get("reward", 0)) == 1


static func act_shown(source: Client) -> bool:
	return not stage(source).is_empty() and not cleared(source) and due(source)


static func right_shown(source: Client) -> bool:
	return not stage(source).is_empty() and not cleared(source)
