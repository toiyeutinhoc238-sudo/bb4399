extends RefCounted


const Atlas = preload("present_tank_glow_atlas.gd")
var _textures: Dictionary = {}
var index: int = -1

static func frame(elapsed: float) -> int:
	return int(floor(maxf(0.0, elapsed) * Atlas.FPS)) % Atlas.COUNT

func reset() -> void :
	index = -1

func draw(lobby: Control, origin: Vector2) -> void :
	index = frame(float(lobby._time))
	var row: Array = Atlas.FRAMES[index]
	var page: int = int(row[0])
	if not _textures.has(page):
		_textures[page] = load(str(Atlas.PAGES[page]))
	var texture: Texture2D = _textures[page]
	if texture == null:
		return
	var f: float = lobby._f
	lobby.draw_texture_rect_region(texture, 
		Rect2((origin + Vector2(float(row[5]), float(row[6]))) * f, Vector2(float(row[3]), float(row[4])) * f), 
		Rect2(float(row[1]), float(row[2]), float(row[3]), float(row[4])))
