extends Control



const BADGE: String = "res://assets/brand/pbe_badge.png"
const SOLID: Rect2 = Rect2(43, 31, 561, 371)
const HIGH: float = 0.326
const AT: Vector2 = Vector2(1.007, 1.011)

var art: Texture2D = null

func _ready() -> void :
	name = "PbeBadge"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	art = load(BADGE) as Texture2D if ResourceLoader.exists(BADGE) else null
	resized.connect(queue_redraw)


static func badge_rect(logo: Vector2, room: Vector2, mark: Vector2) -> Rect2:
	if logo.x <= 0.0 or logo.y <= 0.0 or mark.y <= 0.0:
		return Rect2()
	var k: float = minf(room.x / logo.x, room.y / logo.y)
	var solid: Rect2 = Rect2(SOLID.position * k, SOLID.size * k)
	var high: float = solid.size.y * HIGH
	var wide: float = high * mark.x / mark.y
	var corner: Vector2 = solid.position + solid.size * AT
	return Rect2(corner - Vector2(wide, high), Vector2(wide, high))

func _draw() -> void :
	var host: TextureRect = get_parent() as TextureRect
	if art == null or host == null or host.texture == null:
		return
	draw_texture_rect(art, badge_rect(host.texture.get_size(), host.size, art.get_size()), false)
