

extends RefCounted




const Schema = preload("protocol_schema.gd")
const MessageIds = preload("message_ids.gd")
const MAX_BODY_BYTES: int = 65527
const SIZES: Dictionary = {"u8": 1, "i8": 1, "u16": 2, "i16": 2, 
	"u32": 4, "i32": 4, "f32": 4, "utf8": 2, "u64_words": 8, "i64_words": 8}

var _stream: StreamPeerBuffer = StreamPeerBuffer.new()
var _error: String = ""


func _reset(data: PackedByteArray = PackedByteArray()) -> void :
	_stream = StreamPeerBuffer.new()
	_stream.big_endian = false
	_stream.data_array = data
	_error = ""


func _fail(message: String) -> void :
	if _error.is_empty():
		_error = message


func _result(key: String, value: Variant) -> Dictionary:
	if not _error.is_empty():
		return {"ok": false, "error": _error}
	return {"ok": true, key: value}


func _integer(value: Variant, kind: String) -> bool:
	if typeof(value) != TYPE_INT:
		_fail("Integer required: " + kind)
		return false
	var bits: int = int(SIZES[kind]) * 8
	var signed_value: bool = kind.begins_with("i")
	var low: int = - (1 << (bits - 1)) if signed_value else 0
	var high: int = (1 << (bits - 1)) - 1 if signed_value else (1 << bits) - 1
	if value < low or value > high:
		_fail("Integer out of range: " + kind)
		return false
	return true


func _keys(value: Variant, names: Array) -> bool:
	if typeof(value) != TYPE_DICTIONARY:
		_fail("Dictionary required")
		return false
	if value.size() != names.size():
		_fail("Dictionary fields must match the schema exactly")
		return false
	for name in names:
		if not value.has(name):
			_fail("Missing field: " + str(name))
			return false
	return true


func _reserve(count: int) -> bool:
	if _stream.get_position() + count > MAX_BODY_BYTES:
		_fail("Body exceeds the u16 frame budget")
	return _error.is_empty()


func _need(count: int) -> bool:
	if count < 0 or _stream.get_available_bytes() < count:
		_fail("Truncated body at byte " + str(_stream.get_position()))
	return _error.is_empty()


func _put_scalar(kind: String, value: Variant) -> void :
	if not _error.is_empty():
		return
	if kind == "utf8":
		if typeof(value) != TYPE_STRING and typeof(value) != TYPE_PACKED_BYTE_ARRAY:
			_fail("Invalid/oversize string")
			return
		var raw: PackedByteArray
		if typeof(value) == TYPE_STRING:
			if value.length() > 65535:
				_fail("Oversize string")
				return
			for index in range(value.length()):
				var point: int = value.unicode_at(index)
				if point < 0 or point > 1114111 or (point >= 55296 and point <= 57343):
					_fail("Invalid Unicode string")
					return
			raw = value.to_utf8_buffer()
		else:


			raw = value
			if raw.size() > 65535:
				_fail("Oversize string")
				return
			var start: int = 0
			for index in range(raw.size() + 1):
				if index == raw.size() or raw[index] == 0:
					var part: PackedByteArray = raw.slice(start, index)
					if _flash_utf8(part).to_utf8_buffer() != part:
						_fail("Invalid UTF-8 bytes")
						return
					start = index + 1
		if not _integer(raw.size(), "u16") or not _reserve(raw.size() + 2):
			return
		_stream.put_u16(raw.size())
		_stream.put_data(raw)
	elif kind.ends_with("_words"):
		if not _keys(value, ["lowpart", "hipart"]):
			return
		_put_scalar("u32", value["lowpart"])
		_put_scalar("i32" if kind == "i64_words" else "u32", value["hipart"])
	elif kind == "f32":
		if (typeof(value) != TYPE_FLOAT and typeof(value) != TYPE_INT) or not is_finite(float(value)) or absf(float(value)) > 3.402823466385289e+38:
			_fail("Invalid/non-finite f32")
			return
		if _reserve(4):
			_stream.put_float(float(value))
	elif _integer(value, kind) and _reserve(int(SIZES[kind])):
		match kind:
			"u8": _stream.put_u8(value)
			"i8": _stream.put_8(value)
			"u16": _stream.put_u16(value)
			"i16": _stream.put_16(value)
			"u32": _stream.put_u32(value)
			"i32": _stream.put_32(value)


func _flash_utf8(raw: PackedByteArray) -> String:

	var end: int = raw.find(0)
	if end < 0:
		end = raw.size()
	var result: String = ""
	var index: int = 0
	while index < end:
		var lead: int = raw[index]
		if lead < 128:
			result += String.chr(lead)
			index += 1
			continue
		var width: int = 0
		var point: int = 0
		if lead >= 194 and lead <= 223:
			width = 2
			point = lead & 31
		elif lead >= 224 and lead <= 239:
			width = 3
			point = lead & 15
		elif lead >= 240 and lead <= 244:
			width = 4
			point = lead & 7
		if width == 0:
			result += String.chr(65533)
			index += 1
			continue
		var cursor: int = index + 1
		while cursor < index + width and cursor < end:
			var low: int = 128
			var high: int = 191
			if cursor == index + 1:
				if lead == 224: low = 160
				if lead == 237: high = 159
				if lead == 240: low = 144
				if lead == 244: high = 143
			var next: int = raw[cursor]
			if next < low or next > high:
				break
			point = (point << 6) | (next & 63)
			cursor += 1
		result += String.chr(point if cursor == index + width else 65533)
		index = cursor
	return result


func _get_scalar(kind: String) -> Variant:
	if not _need(int(SIZES[kind])):
		return null
	if kind == "utf8":
		var count: int = _stream.get_u16()
		if not _need(count):
			return null
		var pair: Array = _stream.get_data(count)
		var raw: PackedByteArray = pair[1]
		return _flash_utf8(raw)
	if kind.ends_with("_words"):
		var low: int = _stream.get_u32()
		var high: int = _stream.get_32() if kind == "i64_words" else _stream.get_u32()
		return {"lowpart": low, "hipart": high}
	match kind:
		"u8": return _stream.get_u8()
		"i8": return _stream.get_8()
		"u16": return _stream.get_u16()
		"i16": return _stream.get_16()
		"u32": return _stream.get_u32()
		"i32": return _stream.get_32()
		"f32":
			var value: float = _stream.get_float()
			if not is_finite(value):
				_fail("Non-finite f32")
			return value
	_fail("Unknown wire type")
	return null


func _write_class(protocol_class: String, values: Dictionary, depth: int = 0) -> void :
	if not _error.is_empty():
		return
	if depth > 64 or not Schema.CLASSES.has(protocol_class):
		_fail("Unknown class or excessive nesting: " + protocol_class)
		return
	var fields: Array = Schema.CLASSES[protocol_class]["fields"]
	var names: Array = []
	for field in fields:
		names.append(field["name"])
	if not _keys(values, names):
		return
	for field in fields:
		_write_value(field, values[field["name"]], depth)
		if not _error.is_empty():
			return


func _write_value(field: Dictionary, value: Variant, depth: int) -> void :
	match field["kind"]:
		"array":
			if typeof(value) != TYPE_ARRAY:
				_fail("Array required")
				return
			_put_scalar(field["length_type"], value.size())
			for item in value:
				if not _error.is_empty():
					return
				_write_value(field["element"], item, depth)
		"struct":
			if typeof(value) != TYPE_DICTIONARY:
				_fail("Nested dictionary required")
				return
			_write_class(field["class"], value, depth + 1)
		"scalar": _put_scalar(field["type"], value)


func _minimum(field: Dictionary) -> int:
	if field["kind"] == "struct":
		return int(Schema.CLASSES[field["class"]]["min_bytes"])
	if field["kind"] == "array":
		return int(SIZES[field["length_type"]])
	return int(SIZES[field["type"]])


func _read_class(protocol_class: String, depth: int = 0) -> Dictionary:
	var values: Dictionary = {}
	if depth > 64 or not Schema.CLASSES.has(protocol_class):
		_fail("Unknown class or excessive nesting: " + protocol_class)
		return values
	for field in Schema.CLASSES[protocol_class]["fields"]:
		values[field["name"]] = _read_value(field, depth)
		if not _error.is_empty():
			return {}
	return values


func _read_value(field: Dictionary, depth: int) -> Variant:
	match field["kind"]:
		"array":
			var raw_count: Variant = _get_scalar(field["length_type"])
			if not _error.is_empty():
				return null
			var count: int = int(raw_count)
			if not _need(count * _minimum(field["element"])):
				return null
			var values: Array = []
			for index in range(count):
				values.append(_read_value(field["element"], depth))
				if not _error.is_empty():
					return null
			return values
		"struct": return _read_class(field["class"], depth + 1)
		"scalar": return _get_scalar(field["type"])
	_fail("Unknown schema kind")
	return null


func compose(protocol_class: String, args: Array) -> Dictionary:
	_error = ""
	if not Schema.CLASSES.has(protocol_class):
		_fail("Unknown class")
		return _result("value", {})
	var order: Array = Schema.CLASSES[protocol_class]["compose"]
	var values: Dictionary = {}
	if args.size() != order.size():
		_fail("Wrong compose argument count")
	else:
		for index in range(order.size()):
			values[order[index]] = args[index]
	return _result("value", values)


func encode_body(protocol_class: String, values: Dictionary) -> Dictionary:
	_reset()
	_write_class(protocol_class, values)
	return _result("data", _stream.data_array)


func decode_body(protocol_class: String, data: PackedByteArray) -> Dictionary:
	_reset(data)
	if data.size() > MAX_BODY_BYTES:
		_fail("Oversize body")
		return _result("value", {})
	var value: Dictionary = _read_class(protocol_class)
	if _stream.get_available_bytes() != 0:
		_fail("Trailing body bytes")
	return _result("value", value)


func encode_frame(protocol_class: String, values: Dictionary, sequence: int = 0) -> Dictionary:
	var encoded: Dictionary = encode_body(protocol_class, values)
	if not encoded["ok"]:
		return encoded
	if not MessageIds.BY_CLASS.has(protocol_class) or not _integer(sequence, "u32"):
		_fail("Class has no message id or invalid sequence")
		return _result("data", PackedByteArray())
	var body: PackedByteArray = encoded["data"]
	var output: StreamPeerBuffer = StreamPeerBuffer.new()
	output.big_endian = false
	output.put_u16(body.size() + 8)
	output.put_16(int(MessageIds.BY_CLASS[protocol_class]))
	output.put_u32(sequence)
	output.put_data(body)
	return _result("data", output.data_array)


func decode_frame(data: PackedByteArray) -> Dictionary:
	_reset()
	if data.size() < 8 or data.size() > 65535:
		_fail("Invalid frame size (initial 00 00 is not a frame)")
		return _result("value", {})
	var header: StreamPeerBuffer = StreamPeerBuffer.new()
	header.big_endian = false
	header.data_array = data
	var length: int = header.get_u16()
	var message_id: int = header.get_16()
	var sequence: int = header.get_u32()
	if length != data.size() or not MessageIds.BY_ID.has(message_id):
		_fail("Invalid frame length or unknown message id")
		return _result("value", {})
	var protocol_class: String = MessageIds.BY_ID[message_id]
	var decoded: Dictionary = decode_body(protocol_class, data.slice(8))
	if not decoded["ok"]:
		return decoded
	return {"ok": true, "class": protocol_class, "type": message_id, 
		"sequence": sequence, "value": decoded["value"]}
