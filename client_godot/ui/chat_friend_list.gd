extends RefCounted








const AT: Vector2 = Vector2(378, -127)
const SIZE: Vector2 = Vector2(264, 265)
const TAB: Vector2 = Vector2(20, 11)
const CLOSE: Vector2 = Vector2(225, 6)
const LIST: Rect2 = Rect2(7, 44, 250, 216)
const ROW: float = 24.0
const ROWS: int = 9
const BAR: float = 19.0
const LEVEL: Vector2 = Vector2(40, 20)
const NAME_X: float = 39.0
const NAME_W: float = 95.0
const VIP_X: float = 139.0
const SEX_X: float = 174.0
const PAD: float = 2.0
const RENDER_W: float = 230.0
const FONT: float = 14.0
const GLOW: Color = Color("2866b0", 0.8)
const HOVER: Color = Color("29e9f9")
const PICK: Color = Color("38f929")
const WHEEL: int = 3
const SEXES: Dictionary = {1: "Nam", 2: "Nữ"}


static func online(friends: Dictionary) -> Array:
	var out: Array = []
	for brief: Variant in friends.values():
		if brief is Dictionary and int((brief as Dictionary).get("m_online", 0)) == 1:
			out.append(brief)
	return out

static func sex(value: int) -> String:
	return str(SEXES.get(value, ""))


static func vip_cell(vip: int) -> String:
	var level: int = vip % 100
	if level <= 0:
		return ""
	return ("lb_sv%d" if vip >= 100 else "lb_v%d") % mini(level, 15)


static func level_cell(level: int) -> String:
	return "level_%d" % clampi(level, 0, 40)


static func origin(c: Vector2, wide: float, high: float) -> Vector2:
	var at: Vector2 = c + AT
	at.x = clampf(at.x, 0.0, maxf(0.0, floorf(wide + 0.01) - SIZE.x))
	at.y = clampf(at.y, 0.0, maxf(0.0, floorf(high + 0.01) - SIZE.y))
	return at


static func first(top: int, count: int) -> int:
	return clampi(top, 0, maxi(0, count - ROWS))
