extends RefCounted












const TECHNIQUE: Dictionary = {
	"pr_t_kill": "Kẻ Tàn Sát: Lượt diệt địch tối đa ", 
	"pr_t_assist": "Vua Trợ Công: Lượt trợ công tối đa ", 
	"pr_t_kda": "Vua Toàn Năng: Địch tử vong trợ công tổng đánh giá tối đa", 
	"pr_t_destroy": "Vua Phá Hoại: Tạo sát thương lớn lên căn cứ và tháp pháo địch", 
}
const FRIEND: String = "Thêm làm bạn bè"
const REPORT: String = "báo cáo"

const FILL: Color = Color("e9f9ff")
const EDGE: Color = Color.WHITE
const INK: Color = Color("086da5")
const RADIUS: float = 4.0
const PX: float = 12.0
const INSET: float = 4.0
const WRAP: float = 182.0
const LEADING: float = 2.0
const SHOW: float = 0.1
const HIDE: float = 10.0
const SCRUB: float = 0.1
const OFFSET: Vector2 = Vector2(11, 22)


var probe: Variant = null
var _spots: Array = []
var _key: String = ""
var _since: float = 0.0
var _shown: bool = false
var _shown_at: float = 0.0
var _gone: bool = false
var _left_at: float = -100.0
var _at: Vector2 = Vector2.ZERO
var _text: String = ""
var _was_held: bool = false
var _box: StyleBoxFlat = StyleBoxFlat.new()


func begin() -> void :
	_spots.clear()


func reset() -> void :
	_spots.clear()
	_key = ""
	_shown = false
	_gone = false
	_left_at = -100.0
	_was_held = false


func add(key: String, rect: Rect2, text: String) -> Rect2:
	if not text.is_empty() and rect.has_area():
		_spots.append([key, rect, text])
	return rect


func pick(mouse: Vector2) -> Array:
	for i in range(_spots.size() - 1, -1, -1):
		var spot: Array = _spots[i]
		if Rect2(spot[1]).has_point(mouse):
			return [str(spot[0]), str(spot[2])]
	return []

func spots() -> Array:
	return _spots.duplicate()

func showing() -> bool:
	return _shown

func text() -> String:
	return _text if _shown else ""

func corner() -> Vector2:
	return _at


static func layout(text: String, font: Font, f: float) -> Dictionary:
	var size: int = maxi(6, roundi(PX * f))
	var lines: Array[String] = []
	var line: String = ""
	for word: String in text.strip_edges(false, true).split(" "):
		var next: String = word if line.is_empty() else line + " " + word
		if not line.is_empty() and font.get_string_size(next, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / f > WRAP:
			lines.append(line)
			line = word
		else:
			line = next
	lines.append(line)
	var widest: float = 0.0
	for one: String in lines:
		widest = maxf(widest, font.get_string_size(one, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / f)
	var tall: float = font.get_height(size) / f
	var text_high: float = lines.size() * tall + (lines.size() - 1) * LEADING
	return {"lines": lines, "wide": float(int(widest + 8.0)), "high": float(int(float(int(text_high + 6.0)) * 1.1)), "line": tall + LEADING, 
		"size": size}


static func place(mouse: Vector2, wide: float, high: float, stage: Vector2) -> Vector2:
	var at: Vector2 = mouse + OFFSET
	if at.x + wide > stage.x:
		at.x = stage.x - wide
	if at.y + high > stage.y:
		at.y = stage.y - high
	return at


func frame(canvas: CanvasItem, f: float, stage: Vector2, mouse: Vector2, over: bool, blocked: bool, now: float, held: bool, font: Font) -> void :
	step(f, stage, mouse, over, blocked, now, held, font)
	if _shown:
		_draw(canvas, f, font)




func step(f: float, stage: Vector2, mouse: Vector2, over: bool, blocked: bool, now: float, held: bool, font: Font) -> void :
	if probe is Vector2:
		mouse = probe
		over = true
	var press: bool = held and not _was_held
	_was_held = held
	var hit: Array = pick(mouse) if over and not blocked else []
	var key: String = str(hit[0]) if not hit.is_empty() else ""
	if key != _key:
		if _shown:
			_left_at = now
		_shown = false
		_gone = false
		_key = key
		_since = now
		if not key.is_empty() and now - _left_at < SCRUB:
			_show(str(hit[1]), mouse, now, f, stage, font)
	if _key.is_empty():
		return
	if not _shown and not _gone and now - _since >= SHOW:
		_show(str(hit[1]), mouse, now, f, stage, font)
	if _shown and (press or now - _shown_at >= HIDE):
		if press:
			_left_at = now
		_shown = false
		_gone = true

func _show(text: String, mouse: Vector2, now: float, f: float, stage: Vector2, font: Font) -> void :
	var box: Dictionary = layout(text, font, f)
	_text = text
	_at = place(mouse / f, float(box.wide), float(box.high), stage)
	_shown = true
	_shown_at = now

func _draw(canvas: CanvasItem, f: float, font: Font) -> void :
	var box: Dictionary = layout(_text, font, f)
	var rect: Rect2 = Rect2(_at * f, Vector2(float(box.wide), float(box.high)) * f)
	_box.bg_color = FILL
	_box.border_color = EDGE
	_box.set_border_width_all(maxi(1, roundi(f)))
	_box.set_corner_radius_all(maxi(1, roundi(RADIUS * f)))
	_box.anti_aliasing = true
	canvas.draw_style_box(_box, rect)
	var size: int = int(box.size)
	var lines: Array = box.lines
	for i in range(lines.size()):
		var base: Vector2 = Vector2(_at.x + INSET, _at.y + INSET + i * float(box.line)) * f + Vector2(0, font.get_ascent(size))
		canvas.draw_string(font, base, str(lines[i]), HORIZONTAL_ALIGNMENT_LEFT, -1, size, INK)
