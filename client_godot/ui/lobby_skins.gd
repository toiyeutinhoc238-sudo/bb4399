extends RefCounted





const LobbyBar = preload("lobby_bar.gd")


const LIST: Array = [
	{"id": "bright", "name": "", "note": "", "ready": true}, 
	{"id": "glass", "name": "", "note": "", "ready": true}, 
]

static func entries() -> Array:
	return LIST.filter( func(entry: Dictionary) -> bool: return bool(entry.get("ready", false)) and LobbyBar.valid(str(entry.get("id", ""))))

static func name_of(entry: Dictionary) -> String:
	var id: String = str(entry.get("id", ""))
	var text: String = str(entry.get("name", ""))
	return text if not text.is_empty() else str(LobbyBar.NAMES.get(id, id))

static func note_of(entry: Dictionary) -> String:
	var id: String = str(entry.get("id", ""))
	var text: String = str(entry.get("note", ""))
	return text if not text.is_empty() else str(LobbyBar.NOTES.get(id, ""))
