extends RefCounted

var _buffer: PackedByteArray = PackedByteArray()
var _greeted: bool = false
var _failed: bool = false

func feed(data: PackedByteArray) -> Dictionary:
	if _failed:
		return {"ok": false}
	if _buffer.size() + data.size() > 327680:
		_failed = true
		return {"ok": false}
	_buffer.append_array(data)
	var cursor: int = 0
	if not _greeted:
		if _buffer.size() < 2:
			return {"ok": true, "frames": []}
		if _buffer.decode_u16(0) != 0:
			_failed = true
			return {"ok": false}
		_greeted = true
		cursor = 2
	var frames: Array[PackedByteArray] = []
	while _buffer.size() - cursor >= 2:
		var length: int = _buffer.decode_u16(cursor)
		if length < 8:
			_failed = true
			return {"ok": false}
		if _buffer.size() - cursor < length:
			break
		frames.append(_buffer.slice(cursor, cursor + length))
		cursor += length
	_buffer = _buffer.slice(cursor)
	return {"ok": true, "frames": frames}
