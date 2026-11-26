extends "league_reward.gd"






const CORPS_TITLE: String = "THƯỞNG LÃNH THỔ CHIẾN"

func prizes() -> Array:
	return []

func _draw_title(o: Vector2) -> void :
	var spot: Array = Atlas.TITLE
	var at: Vector2 = o + _v(spot)
	_fwords(CORPS_TITLE, ARIAL_BOLD, 24.0, TITLE_SHADOW, "c", at + Vector2(0, 2), float(spot[2]), 3.0, float(spot[3]), true, TITLE_SHADOW)
	_fwords(CORPS_TITLE, ARIAL_BOLD, 24.0, TITLE_INK, "c", at, float(spot[2]), 3.0, float(spot[3]), true, Color.WHITE)
