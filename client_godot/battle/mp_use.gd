extends RefCounted


static func uses(tank: Dictionary) -> bool:
	if int(tank.get("mp", 0)) > 0:
		tank["mp_seen"] = true
	return bool(tank.get("mp_seen", false))
