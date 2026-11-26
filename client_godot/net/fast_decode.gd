extends RefCounted











const Schema = preload("battle_protocol/protocol_schema.gd")
const MessageIds = preload("battle_protocol/message_ids.gd")
const Codec = preload("battle_protocol/protocol_codec.gd")

const OWN_RULES: Array[int] = [1351, 1832, 1708, 1602, 1585, 1595, 1842]
const U8: int = 0
const I8: int = 1
const U16: int = 2
const I16: int = 3
const U32: int = 4
const I32: int = 5
const F32: int = 6
const UTF8: int = 7
const U64W: int = 8
const I64W: int = 9
const ARR: int = 10
const STRUCT: int = 11
const BAD: int = -1
const KINDS: Dictionary = {"u8": U8, "i8": I8, "u16": U16, "i16": I16, "u32": U32, "i32": I32, "f32": F32, "utf8": UTF8, 
	"u64_words": U64W, "i64_words": I64W}
const SIZES: Array[int] = [1, 1, 2, 2, 4, 4, 4, 2, 8, 8]


var _programs: Dictionary = {}
var _utf: Codec = Codec.new()
var _data: PackedByteArray = PackedByteArray()
var _pos: int = 0
var _end: int = 0
var _bad: bool = false

func decode_frame(frame: PackedByteArray) -> Dictionary:
	var size: int = frame.size()
	if size < 8 or size > 65535 or frame.decode_u16(0) != size:
		return {}
	var type: int = frame.decode_s16(2)
	var cls: Variant = MessageIds.BY_ID.get(type)
	if cls == null:
		return {}
	_data = frame
	_pos = 8
	_end = size
	_bad = false
	var value: Dictionary = _read_class(cls, 0)
	var used: int = _pos
	if _bad:
		_data = PackedByteArray()
		return {}
	var left: int = size - used
	if left > 8 or (left > 0 and type in OWN_RULES):
		_data = PackedByteArray()
		return {}
	if left > 0:


		_pos = 8
		_end = used
		value = _read_class(cls, 0)
		if _bad or _pos != used:
			_data = PackedByteArray()
			return {}
	var result: Dictionary = {"ok": true, "class": cls, "type": type, "sequence": frame.decode_u32(4), "value": value}
	if left > 0:
		result["compatibility"] = "as3-trailing-bytes"
	_data = PackedByteArray()
	return result

func _program(cls: String) -> Array:
	var cached: Variant = _programs.get(cls)
	if cached != null:
		return cached
	var out: Array = []
	if not Schema.CLASSES.has(cls):
		out.append(["", BAD, 0, null, 0])
	else:
		for field: Dictionary in Schema.CLASSES[cls]["fields"]:
			out.append(_entry(field))
	_programs[cls] = out
	return out

func _entry(field: Dictionary) -> Array:
	var name: Variant = field.get("name", "")
	match str(field.get("kind", "")):
		"scalar":
			return [name, int(KINDS.get(str(field.get("type", "")), BAD)), 0, null, 0]
		"struct":
			var cls: String = str(field.get("class", ""))
			return [name, STRUCT if Schema.CLASSES.has(cls) else BAD, 0, cls, 0]
		"array":
			var count_op: int = int(KINDS.get(str(field.get("length_type", "")), BAD))
			var element: Dictionary = field.get("element", {})
			var least: int = _minimum(element)
			var ok: bool = count_op >= U8 and count_op <= I32 and least >= 0
			return [name, ARR if ok else BAD, count_op, _entry(element), least]
	return [name, BAD, 0, null, 0]


func _minimum(element: Dictionary) -> int:
	match str(element.get("kind", "")):
		"struct":
			var cls: String = str(element.get("class", ""))
			return int(Schema.CLASSES[cls]["min_bytes"]) if Schema.CLASSES.has(cls) else -1
		"array":
			var op: int = int(KINDS.get(str(element.get("length_type", "")), BAD))
			return SIZES[op] if op >= 0 else -1
		"scalar":
			var op: int = int(KINDS.get(str(element.get("type", "")), BAD))
			return SIZES[op] if op >= 0 else -1
	return -1

func _read_class(cls: String, depth: int) -> Dictionary:
	var values: Dictionary = {}
	if depth > 64:
		_bad = true
		return values
	for e: Array in _program(cls):
		var op: int = e[1]
		var at: int = _pos

		if op == U32:
			if at + 4 > _end:
				_bad = true
				return values
			values[e[0]] = _data.decode_u32(at)
			_pos = at + 4
		elif op == U8:
			if at + 1 > _end:
				_bad = true
				return values
			values[e[0]] = _data[at]
			_pos = at + 1
		elif op == I16:
			if at + 2 > _end:
				_bad = true
				return values
			values[e[0]] = _data.decode_s16(at)
			_pos = at + 2
		elif op == I32:
			if at + 4 > _end:
				_bad = true
				return values
			values[e[0]] = _data.decode_s32(at)
			_pos = at + 4
		else:
			values[e[0]] = _read(e, depth)
			if _bad:
				return values
	return values

func _read(e: Array, depth: int) -> Variant:
	var op: int = e[1]
	var at: int = _pos
	if op >= U8 and op <= F32:
		var size: int = SIZES[op]
		if at + size > _end:
			_bad = true
			return null
		_pos = at + size
		match op:
			U8: return _data[at]
			I8: return _data.decode_s8(at)
			U16: return _data.decode_u16(at)
			I16: return _data.decode_s16(at)
			U32: return _data.decode_u32(at)
			I32: return _data.decode_s32(at)
		var value: float = _data.decode_float(at)
		if not is_finite(value):
			_bad = true
		return value
	if op == ARR:
		var count_op: int = e[2]
		if at + SIZES[count_op] > _end:
			_bad = true
			return null
		_pos = at + SIZES[count_op]
		var n: int = 0
		match count_op:
			U8: n = _data[at]
			I8: n = _data.decode_s8(at)
			U16: n = _data.decode_u16(at)
			I16: n = _data.decode_s16(at)
			U32: n = _data.decode_u32(at)
			I32: n = _data.decode_s32(at)
		if n < 0 or n * int(e[4]) > _end - _pos:
			_bad = true
			return null
		var element: Array = e[3]
		var items: Array = []
		var kind: int = element[1]
		if kind == STRUCT:
			var cls: String = element[3]
			for i in range(n):
				items.append(_read_class(cls, depth + 1))
				if _bad:
					return null
		else:
			for i in range(n):
				items.append(_read(element, depth))
				if _bad:
					return null
		return items
	if op == STRUCT:
		return _read_class(e[3], depth + 1)
	if op == UTF8:
		if at + 2 > _end:
			_bad = true
			return null
		var count: int = _data.decode_u16(at)
		if at + 2 + count > _end:
			_bad = true
			return null
		_pos = at + 2 + count
		return _text(at + 2, count)
	if op == U64W or op == I64W:
		if at + 8 > _end:
			_bad = true
			return null
		_pos = at + 8
		return {"lowpart": _data.decode_u32(at), "hipart": _data.decode_s32(at + 4) if op == I64W else _data.decode_u32(at + 4)}
	_bad = true
	return null


func _text(at: int, count: int) -> String:
	if count == 0:
		return ""
	var raw: PackedByteArray = _data.slice(at, at + count)
	var nul: int = raw.find(0)
	var head: PackedByteArray = raw if nul < 0 else raw.slice(0, nul)
	if head.is_empty():
		return ""
	var probe: PackedByteArray = head.duplicate()
	probe.sort()
	if probe[probe.size() - 1] < 128:
		return head.get_string_from_ascii()
	return _utf._flash_utf8(raw)
