extends RefCounted

const Codec = preload("battle_protocol/protocol_codec.gd")
var codec: Codec = Codec.new()

func _attempt(frame: PackedByteArray, body: PackedByteArray, type: int, rule: String) -> Dictionary:
	var adapted: PackedByteArray = frame.slice(0, 8)
	adapted.append_array(body)
	adapted.encode_u16(0, adapted.size())
	adapted.encode_s16(2, type)
	var result: Dictionary = codec.decode_frame(adapted)
	if result.ok:
		result["type"] = frame.decode_s16(2)
		result["compatibility"] = rule
	return result

func decode_frame(frame: PackedByteArray, direction: String = "s2c") -> Dictionary:
	var result: Dictionary = codec.decode_frame(frame)
	if result.ok or frame.size() < 8 or frame.size() > 65535 or frame.decode_u16(0) != frame.size():
		return result
	var type: int = frame.decode_s16(2)
	var body: PackedByteArray = frame.slice(8)
	if direction == "c2s":

		if (frame.size() - 2) % 8 == 0:
			for count in range(1, mini(7, body.size()) + 1):
				if body[body.size() - count] != 0:
					break
				var unpadded: Dictionary = _attempt(frame, body.slice(0, body.size() - count), type, "flash-zero-padding")
				if unpadded.ok:
					return unpadded
		if type == 600:
			var extended: PackedByteArray = body.duplicate()
			extended.resize(body.size() + 4)
			return _attempt(frame, extended, type, "bot-create-omits-item-id")
	else:
		if type in [1351, 1832] and body.size() >= 2 and body.size() == 2 + body.decode_u16(0) * 8:

			body.resize(body.size() + 4)
			return _attempt(frame, body, type, "guild-snapshot-omits-op-type")
		if type == 1708 and body.size() > 0 and body[-1] == 0:
			return _attempt(frame, body.slice(0, body.size() - 1), type, "battle-end-zero-suffix")
		if type == 1602:

			return _attempt(frame, body, 1555, "object-snapshot-alias-1555")
		if type in [1585, 1595]:


			var keep: int = 7 if type == 1585 else 5
			if body.size() > keep:
				return _attempt(frame, body.slice(0, keep), type, "battle-exp-reserved-suffix")
		if type == 1842 and body.size() == 4 and body.decode_u32(0) <= 255:
			return _attempt(frame, body.slice(0, 1), type, "guild-hint-u32")


		for count in range(1, mini(8, body.size()) + 1):
			var trimmed: Dictionary = _attempt(frame, body.slice(0, body.size() - count), type, "as3-trailing-bytes")
			if trimmed.ok:
				return trimmed
	return result
