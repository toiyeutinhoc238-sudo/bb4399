extends RefCounted

var document: Dictionary = {}
var blocked: Dictionary = {}
var walls: Dictionary = {}
var _faces: Dictionary = {}
var extent: Vector2 = Vector2(1800, 1368)
var templates: Dictionary = {}
var static_npcs: Array = []
var air: Array = []
var flags: Array = []
var portals: Array = []
var bush: Dictionary = {}
var id: int = 0
var bundled: bool = false

const LOS_RANGE: Dictionary = {1: 840, 7: 840, 9: 840, 10: 840, 12: 840, 14: 840, 17: 840, 18: 840, 21: 840, 
	34: 840, 35: 840, 36: 840, 37: 840, 50: 840, 70: 840, 169: 840, 170: 840, 1201: 840, 1202: 840, 30: 720, 40: 600}

const EXTRA_WALLS: Dictionary = {1: [Rect2i(744, 864, 48, 24), Rect2i(720, 888, 72, 72), Rect2i(1680, 336, 96, 72)]}

func load_map() -> bool:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://assets/map4/map.json"))
	bundled = parsed is Dictionary and load_document(parsed, 4)
	return bundled


func load_document(parsed: Dictionary, map_id: int) -> bool:
	if not parsed.get("header") is Dictionary or not parsed.get("visual") is Dictionary or not parsed.get("chunks") is Array:
		return false
	bundled = false
	document = parsed
	id = map_id
	extent = Vector2(document.header.mapWidth, document.header.mapHeight)
	templates = document.visual.get("npc_templates", {})
	static_npcs = []
	air = []
	flags = []
	portals = []
	blocked.clear()
	walls.clear()
	_faces.clear()
	bush.clear()
	for chunk: Dictionary in document.chunks:
		var data: Dictionary = chunk.data
		if data.has("npcs"):
			static_npcs = data.npcs
		if int(chunk.tag) == 5:
			air = data.points
		if int(chunk.tag) == 7:
			flags = data.get("flags", [])
		if int(chunk.tag) == 13:
			portals = data.get("portals", [])
		for grid: Dictionary in data.get("grids", []):
			if int(grid.instanceId) in [-1, -2]:
				blocked[int(grid.gridIndex)] = true
				if int(grid.instanceId) == -1:
					walls[int(grid.gridIndex)] = true
			elif int(grid.instanceId) <= -3 and int(grid.instanceId) >= -256:
				bush[int(grid.gridIndex)] = int(grid.instanceId)
	var columns: int = int(extent.x / 24)
	for wall: Rect2i in EXTRA_WALLS.get(id, []):
		for y in range(wall.position.y, wall.end.y, 24):
			for x in range(wall.position.x, wall.end.x, 24):
				var index: int = int(y / 24.0) * columns + int(x / 24.0)
				blocked[index] = true
				walls[index] = true
	return true

const FACE_COLUMNS: int = 3
const FACE_ROWS: int = 4




func wall_faces(center: Vector2) -> Array:
	var columns: int = int(extent.x / 24)
	var home: int = int(center.y / 24)
	var mid: int = int(center.x / 24)
	var key: int = home * columns + mid
	if _faces.has(key):
		return _faces[key]
	var out: Array = []
	for column in range(maxi(mid - FACE_COLUMNS, 0), mini(mid + FACE_COLUMNS + 1, columns)):
		if walls.has(home * columns + column):
			continue
		var top: int = home + 1
		while top <= home + FACE_ROWS and not _core_wall(top * columns + column, columns):
			top += 1
		var bottom: int = top
		while bottom <= home + FACE_ROWS and _core_wall(bottom * columns + column, columns):
			bottom += 1
		if bottom == top:
			continue
		var rect: = Rect2(column * 24, top * 24, 24, (bottom - top) * 24)
		var last: Rect2 = out[-1] if not out.is_empty() else Rect2()
		if last.end.x == rect.position.x and last.position.y == rect.position.y and last.size.y == rect.size.y:
			out[-1] = last.merge(rect)
		else:
			out.append(rect)
	_faces[key] = out
	return out

func _core_wall(index: int, columns: int) -> bool:
	return walls.has(index) and walls.has(index - columns) and walls.has(index - 1) and walls.has(index + 1)



const TREE_FEET: Dictionary = {1: [
	{"near": Rect2(440, 590, 300, 142), "outline": [Vector2(560, 677), Vector2(622, 677), Vector2(620, 682), Vector2(612, 687), Vector2(606, 693), 
		Vector2(601, 699), Vector2(597, 706), Vector2(574, 707), Vector2(567, 699), Vector2(561, 695), Vector2(559, 686)]}, 
	{"near": Rect2(1440, 1010, 180, 142), "outline": [Vector2(1556, 1098), Vector2(1648, 1098), Vector2(1646, 1112), Vector2(1636, 1121), 
		Vector2(1616, 1122), Vector2(1603, 1128), Vector2(1588, 1128), Vector2(1574, 1122), Vector2(1562, 1110)]}, 
]}

func tree_feet(center: Vector2) -> Array:
	var out: Array = []
	for foot: Dictionary in TREE_FEET.get(id, []):
		if foot.near.has_point(center):
			out.append(PackedVector2Array(foot.outline))
	return out


func bush_id(pos: Vector2) -> int:
	if bush.is_empty() or pos.x < 0 or pos.y < 0:
		return 0
	return int(bush.get(int(pos.y / 24) * int(extent.x / 24) + int(pos.x / 24), 0))


func los_range() -> float:
	var value: float = float(document.get("visual", {}).get("los_range", LOS_RANGE.get(id, 10000)))
	return value if value > 0 else 10000.0



const RUNTIME_WALL: = {"iType": 7, "iWidth": 72, "iHeight": 72}
const RUNTIME_WALLS: Array[int] = [353201, 477201, 478201]
const CRYSTAL_WALL: = {"iType": 7, "iWidth": 96, "iHeight": 96}



func _leaving_wall(center: Vector2, from: Vector2, columns: int) -> bool:
	if from == Vector2.INF:
		return false
	var hits: Vector2 = Vector2.ZERO
	var count: int = 0
	for y in range(3):
		for x in range(3):
			var row: int = int((from.y - 36 + y * 24) / 24)
			var column: int = int((from.x - 36 + x * 24) / 24)
			if blocked.has(row * columns + column):
				hits += Vector2(column * 24 + 12, row * 24 + 12)
				count += 1
	if count == 0:
		return false
	var next: int = 0
	for y in range(3):
		for x in range(3):
			if blocked.has(int((center.y - 36 + y * 24) / 24) * columns + int((center.x - 36 + x * 24) / 24)):
				next += 1
	return next <= count and (center - from).dot(from - hits / count) > 0.0



func can_move(center: Vector2, npcs: Dictionary, from: Vector2 = Vector2.INF) -> bool:
	if center.x < 36 or center.y < 36 or center.x > extent.x - 36 or center.y > extent.y - 36:
		return false

	var columns: int = int(extent.x / 24)
	var walled: bool = false
	for y in range(3):
		for x in range(3):
			var index: int = int((center.y - 36 + y * 24) / 24) * columns + int((center.x - 36 + x * 24) / 24)
			if blocked.has(index):
				walled = true
	if walled and not _leaving_wall(center, from, columns):
		return false
	for npc: Dictionary in npcs.values():
		if npc.dead:
			continue
		var row: Dictionary = templates.get(str(npc.template), CRYSTAL_WALL if int(npc.template) == 9930301 else RUNTIME_WALL if int(npc.template) in RUNTIME_WALLS else {})
		if int(row.get("iType", 51)) in [51, 52, 53]:
			continue
		var width: int = int(row.get("iWidth", 0))
		var height: int = int(row.get("iHeight", 0))
		if width <= 0 or height <= 0:
			continue
		if absf(npc.pos.x - center.x) < (72 + width) / 2.0 and absf(npc.pos.y - center.y) < (72 + height) / 2.0:
			if not _leaving(npc.pos, width, height, center, from):
				return false
	return true


static func _leaving(at: Vector2, width: int, height: int, center: Vector2, from: Vector2) -> bool:
	if not (absf(at.x - from.x) < (72 + width) / 2.0 and absf(at.y - from.y) < (72 + height) / 2.0):
		return false
	return (at - center).length_squared() > (at - from).length_squared()
