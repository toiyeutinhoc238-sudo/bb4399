extends RefCounted













const BOX: float = 200.0
const BOTTOM: Vector2 = Vector2(100, 146)
const SURFACE: Vector2 = Vector2(100, 120)
const MASTER_ITEM: int = 7003002
const MASTER_LEVEL: int = 6
const FPS: float = 24.0



static func halo_item(known: Dictionary, worn: int, level: int) -> int:
	if worn > 0 and known.has(str(worn)):
		return worn
	return MASTER_ITEM if level >= MASTER_LEVEL and known.has(str(MASTER_ITEM)) else 0


static func level_fx_tier(level: int) -> int:
	if level < 11:
		return 0
	return 6 if level >= 36 else (5 if level >= 31 else (4 if level >= 26 else (3 if level >= 21 else (2 if level >= 16 else 1))))


static func level_fx(canvas: CanvasItem, pack, level: int, at: Vector2, wide: float, f: float, time: float) -> void :
	var tier: int = level_fx_tier(level)
	if pack == null or pack.state != "ready" or tier == 0:
		return
	var anim: Dictionary = pack.effect("ui/level_effect%d" % tier)
	if anim.is_empty():
		return
	var stage: Array = anim.data.get("stage", [80, 40])
	_layer(canvas, anim, at * f, wide / maxf(1.0, float(stage[0])) * f, time)


static func frame_at(count: int, time: float) -> int:
	return int(time * FPS) % maxi(1, count)









static func draw(canvas: CanvasItem, pack, face: String, item: int, center: Vector2, zoom: float, time: float, folder: String = "l/t", fetch: bool = true, clip: Rect2 = Rect2(), grow: float = 1.0, still: Texture2D = null, mask: PackedVector2Array = PackedVector2Array()) -> bool:
	if face.is_empty():
		return false
	var origin: Vector2 = center - Vector2(BOX, BOX) * 0.5 * zoom
	var keys: Array = pack.halo_ui(item) if item > 0 else []
	var ring: float = zoom * (float(keys[2]) if keys.size() > 2 else 1.0)
	if keys.size() >= 2:
		_layer(canvas, pack.effect(str(keys[0])), origin + BOTTOM * zoom, ring, time, clip, mask)
	var film: Array = movie(pack.garage, face)
	var part: Dictionary = {}
	if not film.is_empty() and still == null:
		part = pack.effect(str(film[0])) if fetch else pack.effect_cached(str(film[0]))


	var shrink: float = fit(film)
	if not part.is_empty():
		if shrink != 1.0:
			_layer(canvas, part, center - Vector2(float(film[1]), float(film[2])) * 0.5 * zoom * shrink, zoom * shrink, time, clip, mask)
		else:
			_layer(canvas, part, origin + movie_origin(film) * zoom, zoom, time, clip, mask)
	else:
		var picture: Texture2D = still if still != null else pack.picture("%s/%s.webp" % ["l/t" if not film.is_empty() else folder, face])
		if picture != null:
			var spot: Rect2 = still_rect(film, origin, zoom, side(pack.garage, face) if folder == "l/t" else BOX)

			if grow != 1.0:
				spot = Rect2(center + (spot.position - center) * grow, spot.size * grow)
			if not mask.is_empty():
				_cut(canvas, picture, spot, Rect2(Vector2.ZERO, picture.get_size()), clip, mask)
			elif not clip.has_area():
				canvas.draw_texture_rect(picture, spot, false)
			else:
				_cut(canvas, picture, spot, Rect2(Vector2.ZERO, picture.get_size()), clip)
	if keys.size() >= 2:
		_layer(canvas, pack.effect(str(keys[1])), origin + SURFACE * zoom, ring, time, clip, mask)
	return true


static func movie(garage: Dictionary, face: String) -> Array:
	var row: Variant = garage.get("swf", {}).get(face, [])
	return row if row is Array and row.size() >= 4 and not str(row[0]).is_empty() else []






const SSK8_FIT: Array[String] = ["face/abao_pf01", "face/dabai104", "face/douwa03_pf02", "face/eling_sss01", "face/gongfuxiongmao_pf02", 
	"face/haiyao_pf02", "face/jinmuyan_pf02", "face/lanpangzi_pf01", "face/libai_pf02", "face/liao_pf12", "face/nazi03", "face/sima03", 
	"face/sishen_pf11", "face/sishi_pf11", "face/wukongsss", "face/xingjue03", "face/zhaoyun_pf01", "face/zhaoyun_pf03", "face/zuozhu03"]

static func fit(film: Array) -> float:
	if film.size() < 3:
		return 1.0
	var key: String = str(film[0])
	if not key.begins_with("face/300_") and not SSK8_FIT.has(key):
		return 1.0
	return BOX / maxf(BOX, maxf(float(film[1]), float(film[2])))


static func movie_origin(film: Array) -> Vector2:
	return (Vector2(BOX, BOX) - Vector2(float(film[1]), float(film[2]))) * 0.5 + skofs1_shift(film)




const SKOFS1_SHIFT: Dictionary = {"face/cike_pf01": Vector2(-36, -29), "face/zhaoyun_pf05": Vector2(-33, -27), 
	"face/bika_pf03": Vector2(-42, -24), "face/jinshanshan03": Vector2(-37, -18), "face/jinshanshan_pf01": Vector2(-38, -14), 
	"face/gilgamesh_ss_portrait_v4": Vector2(-38, -14)}

static func skofs1_shift(film: Array) -> Vector2:
	if film.is_empty():
		return Vector2.ZERO
	var shift: Variant = SKOFS1_SHIFT.get(str(film[0]), Vector2.ZERO)
	return shift if shift is Vector2 else Vector2.ZERO


static func side(garage: Dictionary, face: String) -> float:
	return float(garage.get("sides", {}).get(face, BOX))



static func still_rect(film: Array, origin: Vector2, zoom: float, edge: float = BOX) -> Rect2:

	var span: float = maxf(BOX, float(film[3])) * fit(film) if not film.is_empty() else edge
	return Rect2(origin + (Vector2(BOX - span, BOX - span) * 0.5 + skofs1_shift(film)) * zoom, Vector2(span, span) * zoom)


static func hexagon(c: Vector2, r: float) -> PackedVector2Array:
	var points: PackedVector2Array = PackedVector2Array()
	for i in range(6):
		points.append(c + Vector2.UP.rotated(TAU / 6.0 * i) * r)
	return points



static func ring(canvas: CanvasItem, pack, item: int, at: Vector2, zoom: float, time: float, layers: int = 0) -> bool:
	var keys: Array = pack.halo_ui(item) if item > 0 else []
	if keys.size() < 2:
		return false
	var scale: float = zoom * (float(keys[2]) if keys.size() > 2 else 1.0)
	if layers != 2:
		_layer(canvas, pack.effect(str(keys[0])), at, scale, time)
	if layers != 1:
		_layer(canvas, pack.effect(str(keys[1])), at + (SURFACE - BOTTOM) * zoom, scale, time)
	return true



static func _cut(canvas: CanvasItem, page: Texture2D, spot: Rect2, from: Rect2, clip: Rect2, mask: PackedVector2Array = PackedVector2Array()) -> void :
	if not mask.is_empty():
		if not spot.has_area():
			return
		var quad: PackedVector2Array = PackedVector2Array([spot.position, Vector2(spot.end.x, spot.position.y), spot.end, Vector2(spot.position.x, spot.end.y)])
		var ratio: Vector2 = from.size / spot.size
		var page_size: Vector2 = page.get_size()
		for poly: PackedVector2Array in Geometry2D.intersect_polygons(quad, mask):
			if poly.size() < 3:
				continue
			var uvs: PackedVector2Array = PackedVector2Array()
			for p: Vector2 in poly:
				uvs.append((from.position + (p - spot.position) * ratio) / page_size)
			canvas.draw_colored_polygon(poly, Color.WHITE, uvs, page)
		return
	var shown: Rect2 = spot.intersection(clip)
	if not shown.has_area() or not spot.has_area():
		return
	var ratio: Vector2 = from.size / spot.size
	canvas.draw_texture_rect_region(page, shown, Rect2(from.position + (shown.position - spot.position) * ratio, shown.size * ratio))

static func _layer(canvas: CanvasItem, part: Dictionary, at: Vector2, zoom: float, time: float, clip: Rect2 = Rect2(), mask: PackedVector2Array = PackedVector2Array()) -> void :
	if part.is_empty():
		return
	var frames: Array = part.data.frames
	var frame: Dictionary = frames[frame_at(frames.size(), time)]
	var pivot: Vector2 = Vector2(float(frame.pivot[0]), float(frame.pivot[1]))
	var rect: Rect2 = Rect2(float(frame.rect[0]), float(frame.rect[1]), float(frame.rect[2]), float(frame.rect[3]))
	if rect.size.x <= 0.0 or rect.size.y <= 0.0:
		return
	if clip.has_area() or not mask.is_empty():
		_cut(canvas, part.pages[int(frame.page)], Rect2(at - pivot * zoom, rect.size * zoom), rect, clip, mask)
		return
	canvas.draw_texture_rect_region(part.pages[int(frame.page)], Rect2(at - pivot * zoom, rect.size * zoom), rect)
