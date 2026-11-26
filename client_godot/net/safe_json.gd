extends RefCounted


static func parse(text: Variant) -> Variant:
	if text == null:
		return null
	var raw: String = text if text is String else str(text)
	if raw.strip_edges().is_empty():
		return null
	var json: JSON = JSON.new()
	return json.data if json.parse(raw) == OK else null
