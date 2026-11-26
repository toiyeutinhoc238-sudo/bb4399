extends RefCounted









const KEYS: Array = ["default", "black", "blue", "teal", "violet", "wine", "green", "earth", "clear"]
const NAMES: Dictionary = {"default": "Mặc định", "black": "Đen", "blue": "Xanh dương", "teal": "Xanh ngọc", "violet": "Tím", 
	"wine": "Đỏ rượu", "green": "Xanh lá", "earth": "Nâu đất", "clear": "Trong suốt"}


const RGB: Dictionary = {"black": Color("000000"), "blue": Color("164494"), "teal": Color("084f4d"), "violet": Color("65279c"), 
	"wine": Color("8f1d39"), "green": Color("14521f"), "earth": Color("6e3a16")}

const SWATCH: Dictionary = {"black": Color("000000"), "blue": Color("1d59c2"), "teal": Color("0c7d79"), "violet": Color("8332c9"), 
	"wine": Color("bd264b"), "green": Color("208030"), "earth": Color("9c531f")}

const LEGACY: Dictionary = {"night": "blue", "slate": "teal", "maroon": "wine", "moss": "green"}
const STRENGTHS: Array = ["Nhạt", "Vừa", "Đậm"]
const HOVER_A: Array = [0.36, 0.43, 0.5]
const IDLE_A: Array = [0.12, 0.2, 0.28]
const DEFAULT_ALPHA: int = 1


static func keys(hover: bool) -> Array:
	return KEYS.filter( func(key: String) -> bool: return not (hover and key == "clear"))


static func sane(value: Variant, hover: bool) -> String:
	if not value is String:
		return "default"
	var key: String = str(LEGACY.get(str(value), str(value)))
	return key if keys(hover).has(key) else "default"

static func sane_alpha(value: Variant) -> int:
	return int(value) if value is int and int(value) >= 0 and int(value) < STRENGTHS.size() else DEFAULT_ALPHA


static func lobby(key: String, strength: int, hover: bool, base: Color) -> Color:
	if key == "clear":
		return Color(base, 0.0)
	if not RGB.has(key):
		return base
	var level: int = clampi(strength, 0, STRENGTHS.size() - 1)
	return Color(RGB[key], float(HOVER_A[level] if hover else IDLE_A[level]))



static func glass(key: String, base: Color) -> Color:
	return Color(RGB[key], base.a) if RGB.has(key) else base


static func blend(idle: Color, hover: Color, mix: float) -> Color:
	if idle.a <= 0.0:
		idle = Color(hover, 0.0)
	if hover.a <= 0.0:
		hover = Color(idle, 0.0)
	return idle.lerp(hover, clampf(mix, 0.0, 1.0))


static func swatch(key: String) -> Color:
	return SWATCH[key] if SWATCH.has(key) else Color("0a1729")
