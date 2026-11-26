extends RefCounted






const INTERVAL_MS: int = 300000
const BAD: int = -1
const NONE: int = 0
const HAS: int = 1


static func want(last_ms: int, now_ms: int, force: bool) -> bool:
	return force or last_ms < 0 or now_ms - last_ms >= INTERVAL_MS


static func due(body: PackedByteArray) -> int:
	var text: String = body.get_string_from_utf8()
	if text.is_empty():
		return BAD
	var json: JSON = JSON.new()
	if json.parse(text) != OK:
		return BAD
	var data: Variant = json.data
	if not (data is Dictionary) or (data as Dictionary).get("ok") == null:
		return BAD
	return NONE if str(data["ok"]).is_empty() else HAS
