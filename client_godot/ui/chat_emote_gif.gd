extends RefCounted







const KEEP_MS: int = 40
const SIDE: int = 48
const LIMIT: int = 1024

var width: int = 0
var height: int = 0
var frames: Array = []
var delays: PackedInt32Array = PackedInt32Array()
var total: int = 0
var done: bool = false
var failed: bool = false

var _data: PackedByteArray = PackedByteArray()
var _pos: int = 0
var _global: Array = []
var _canvas: Image
var _saved: Image
var _disposal: int = 0
var _delay: int = 0
var _transparent: int = -1
var _last_disposal: int = 0
var _last_rect: Rect2i = Rect2i()
var _side: Vector2i = Vector2i.ZERO


func open(data: PackedByteArray) -> bool:
	_data = data
	failed = true
	if data.size() < 13:
		return false
	var head: String = data.slice(0, 6).get_string_from_ascii()
	if head != "GIF89a" and head != "GIF87a":
		return false
	width = data.decode_u16(6)
	height = data.decode_u16(8)
	if width <= 0 or height <= 0 or width > LIMIT or height > LIMIT:
		return false
	var flags: int = data[10]
	_pos = 13
	if flags & 128:
		var count: int = 2 << (flags & 7)
		if _pos + count * 3 > data.size():
			return false
		_global = _palette(_pos, count)
		_pos += count * 3
	_canvas = Image.create(width, height, false, Image.FORMAT_RGBA8)
	var scale: float = minf(1.0, float(SIDE) / float(maxi(width, height)))
	_side = Vector2i(maxi(1, roundi(width * scale)), maxi(1, roundi(height * scale)))
	failed = false
	return true


func step() -> bool:
	if done or failed:
		return false
	while _pos < _data.size():
		var tag: int = _data[_pos]
		if tag == 33:
			if _pos + 2 > _data.size():
				break
			var label: int = _data[_pos + 1]
			_pos += 2
			if label == 249 and _pos + 5 <= _data.size() and _data[_pos] >= 4:
				var packed: int = _data[_pos + 1]
				_disposal = (packed >> 2) & 7
				_delay = _data.decode_u16(_pos + 2)
				_transparent = _data[_pos + 4] if packed & 1 else -1
			_skip_blocks()
		elif tag == 44:
			_frame()
			return not failed
		else:
			break
	done = true
	if frames.is_empty():
		failed = true
	return false


func decode_all() -> bool:
	while step():
		pass
	return not failed



func frame_at(ms: int) -> Texture2D:
	if frames.is_empty():
		return null
	if frames.size() == 1 or total <= 0:
		return frames[0]
	var t: int = ms % total
	var sum: int = 0
	for i in range(frames.size()):
		sum += delays[i]
		if t < sum:
			return frames[i]
	return frames[-1]

func _palette(at: int, count: int) -> Array:
	var out: Array = []
	for i in range(count):
		out.append(PackedByteArray([_data[at + i * 3], _data[at + i * 3 + 1], _data[at + i * 3 + 2], 255]))
	return out

func _skip_blocks() -> void :
	while _pos < _data.size():
		var n: int = _data[_pos]
		_pos += 1
		if n == 0:
			return
		_pos += n

func _frame() -> void :
	if _pos + 10 > _data.size():
		_pos = _data.size()
		return
	var left: int = _data.decode_u16(_pos + 1)
	var top: int = _data.decode_u16(_pos + 3)
	var w: int = _data.decode_u16(_pos + 5)
	var h: int = _data.decode_u16(_pos + 7)
	var flags: int = _data[_pos + 9]
	_pos += 10
	var palette: Array = _global
	if flags & 128:
		var count: int = 2 << (flags & 7)
		if _pos + count * 3 > _data.size():
			_pos = _data.size()
			return
		palette = _palette(_pos, count)
		_pos += count * 3

	if _last_disposal == 2 and _last_rect.has_area():
		_canvas.fill_rect(_last_rect, Color(0, 0, 0, 0))
	elif _last_disposal == 3 and _saved != null:
		_canvas.copy_from(_saved)
	var disposal: int = _disposal
	var delay: int = (_delay if _delay > 1 else 10) * 10
	var rect: Rect2i = Rect2i(left, top, w, h).intersection(Rect2i(0, 0, width, height))
	if disposal == 3:
		_saved = _canvas.duplicate()
	var keep: bool = frames.is_empty() or delays[delays.size() - 1] >= KEEP_MS
	if not keep and disposal in [2, 3]:
		if _pos < _data.size():
			_pos += 1
		_skip_blocks()
	else:
		var pixels: PackedByteArray = _lzw(w * h, palette, _transparent)
		if flags & 64:
			pixels = _deinterlace(pixels, w, h)
		if w > 0 and h > 0 and rect.has_area():
			var image: Image = Image.create_from_data(w, h, false, Image.FORMAT_RGBA8, pixels)
			_canvas.blend_rect(image, Rect2i(0, 0, w, h), Vector2i(left, top))
	if keep:
		frames.append(_snapshot())
		delays.append(delay)
	else:
		delays[delays.size() - 1] += delay
	total += delay
	_last_disposal = disposal
	_last_rect = rect
	_disposal = 0
	_delay = 0
	_transparent = -1

func _snapshot() -> Texture2D:
	var image: Image = _canvas.duplicate()
	if _side != Vector2i(width, height):
		image.fix_alpha_edges()
		image.resize(_side.x, _side.y, Image.INTERPOLATE_BILINEAR)
	return ImageTexture.create_from_image(image)


func _lzw(count: int, palette: Array, transparent: int) -> PackedByteArray:
	var out: PackedByteArray = PackedByteArray()
	if _pos >= _data.size():
		out.resize(count * 4)
		return out
	var low: int = _data[_pos]
	_pos += 1
	var stream: PackedByteArray = PackedByteArray()
	while _pos < _data.size():
		var n: int = _data[_pos]
		_pos += 1
		if n == 0:
			break
		stream.append_array(_data.slice(_pos, _pos + n))
		_pos += n
	if low < 2 or low > 8:
		out.resize(count * 4)
		return out
	var clear: int = 1 << low
	var finish: int = clear + 1
	var roots: Array = []
	for k in range(clear):
		if k == transparent or k >= palette.size():
			roots.append(PackedByteArray([0, 0, 0, 0]))
		else:
			roots.append(palette[k])
	var starts: PackedInt32Array = PackedInt32Array()
	starts.resize(4096)
	var lengths: PackedInt32Array = PackedInt32Array()
	lengths.resize(4096)
	var size: int = low + 1
	var next: int = clear + 2
	var mask: int = (1 << size) - 1
	var prev: int = -1
	var prev_start: int = 0
	var prev_len: int = 0
	var acc: int = 0
	var bits: int = 0
	var i: int = 0
	var limit: int = stream.size()
	var done_px: int = 0
	while done_px < count:
		while bits < size and i < limit:
			acc |= stream[i] << bits
			i += 1
			bits += 8
		if bits < size:
			break
		var code: int = acc & mask
		acc >>= size
		bits -= size
		if code == clear:
			size = low + 1
			mask = (1 << size) - 1
			next = clear + 2
			prev = -1
			continue
		if code == finish:
			break
		var length: int = 0
		if code < clear:
			out.append_array(roots[code])
			length = 1
		elif code < next and prev != -1:
			out.append_array(out.slice(starts[code] * 4, (starts[code] + lengths[code]) * 4))
			length = lengths[code]
		elif code == next and prev != -1:
			out.append_array(out.slice(prev_start * 4, (prev_start + prev_len) * 4))
			out.append_array(out.slice(prev_start * 4, prev_start * 4 + 4))
			length = prev_len + 1
		else:
			break
		if prev != -1 and next < 4096:
			starts[next] = prev_start
			lengths[next] = prev_len + 1
			next += 1
			if next == (1 << size) and size < 12:
				size += 1
				mask = (1 << size) - 1
		prev = code
		prev_start = done_px
		prev_len = length
		done_px += length
	out.resize(count * 4)
	return out


func _deinterlace(pixels: PackedByteArray, w: int, h: int) -> PackedByteArray:
	var rows: Array = []
	rows.resize(h)
	var row: int = 0
	for pass_rule: Array in [[0, 8], [4, 8], [2, 4], [1, 2]]:
		var y: int = int(pass_rule[0])
		while y < h:
			rows[y] = pixels.slice(row * w * 4, (row + 1) * w * 4)
			row += 1
			y += int(pass_rule[1])
	var out: PackedByteArray = PackedByteArray()
	for part: Variant in rows:
		out.append_array(part)
	return out
