extends RefCounted






const UI_TEAM: int = 3
const UI_GUILD: int = 20
const UI_HIRE_TANK: int = 27
const UI_LADDER: int = 31
const CKT_OPEN_UI: int = 27
const QST_COMPLETE: int = 3
const Q_CHECK_TYPE: int = 12
const Q_CHECK_ID: int = 13

const WAIT: int = -1
const SKIP: int = 0
const SENT: int = 1


static func ready(client: Object, pack: Object) -> bool:
	return client != null and pack != null and pack.quest is Dictionary and not pack.quest.is_empty() and bool(client.quests_loaded)


static func wanted(client: Object, pack: Object, ui: int) -> bool:
	if not ready(client, pack):
		return false
	var rows: Variant = pack.quest.get("quests", {})
	if not rows is Dictionary:
		return false
	for key: Variant in client.quests:
		var info: Variant = client.quests[key]
		if not info is Array or info.is_empty() or int(info[0]) == QST_COMPLETE:
			continue
		var row: Variant = rows.get(str(key))
		if row is Array and row.size() > Q_CHECK_ID and int(row[Q_CHECK_TYPE]) == CKT_OPEN_UI and int(row[Q_CHECK_ID]) == ui:
			return true
	return false


static func note(client: Object, pack: Object, ui: int) -> int:
	if not ready(client, pack):
		if pack != null:
			pack.load_quest()
		return WAIT
	if not wanted(client, pack, ui):
		return SKIP
	return SENT if client.quest_open_ui(ui) else SKIP
