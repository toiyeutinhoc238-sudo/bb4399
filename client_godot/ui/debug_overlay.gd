extends CanvasLayer




class ErrLog extends Logger:
	var lines: Array[String] = []
	var lock: Mutex = Mutex.new()

	func _log_error(function: String, file: String, line: int, code: String, rationale: String, _editor_notify: bool, 
			error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void :
		var kind: String = "SCRIPT ERROR" if error_type == ERROR_TYPE_SCRIPT else ("WARNING" if error_type == ERROR_TYPE_WARNING else "ERROR")
		_add("%s: %s %s @ %s:%d (%s)" % [kind, code, rationale, file.get_file(), line, function])

	func _log_message(message: String, error: bool) -> void :
		if error:
			_add(message.strip_edges())

	func _add(text: String) -> void :
		lock.lock()
		lines.append(text.substr(0, 220))
		if lines.size() > 12:
			lines.pop_front()
		lock.unlock()

	func snapshot() -> Array[String]:
		lock.lock()
		var copy: Array[String] = lines.duplicate()
		lock.unlock()
		return copy

static func wanted() -> bool:
	if not OS.has_feature("web"):
		return false
	return str(JavaScriptBridge.eval("location.search", true)).contains("debug=1")

var client: Node
var _log: ErrLog = ErrLog.new()
var _label: Label
var _tick: float = 0.0

func _ready() -> void :
	layer = 128
	OS.add_logger(_log)
	var panel: PanelContainer = PanelContainer.new()
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(0.25, 0, 0, 0.82)
	box.set_content_margin_all(6)
	panel.add_theme_stylebox_override("panel", box)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.position = Vector2(8, 40)
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 12)
	_label.add_theme_color_override("font_color", Color(1, 0.9, 0.9))
	_label.custom_minimum_size = Vector2(620, 0)
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	panel.add_child(_label)
	add_child(panel)

func _exit_tree() -> void :
	OS.remove_logger(_log)

func _process(delta: float) -> void :
	_tick += delta
	if _tick < 0.25:
		return
	_tick = 0.0
	var rows: Array[String] = ["DEBUG (?debug=1)"]
	if client != null:
		rows.append(_state())
		rows.append("Nhạc: %s" % str(JavaScriptBridge.eval("window.__bbMusicState ? window.__bbMusicState() : 'n/a'", true)))
	var errors: Array[String] = _log.snapshot()
	rows.append("Lỗi: %d" % errors.size())
	rows.append_array(errors)
	_label.text = "\n".join(rows)


func _state() -> String:
	var c = client
	var pair: Dictionary = c.pair_scene
	var me: int = int(c.account_oid)
	var text: String = "state=%s acc=%d uuid=%s" % [str(c.state), me, str(c.char_uuid)]
	if not pair.is_empty():
		var oids: Array = []
		for brief: Dictionary in pair.get("chars", []):
			oids.append(int(brief.get("charData", {}).get("nAcctId", 0)))
		text += "\npair type=%d scene=%d can_pick=%s round=%s self_turn=%s camp=%d turn=%s pick=%s locked=%s inChars=%s chars=%s" % [
			int(pair.get("type", 0)), int(pair.get("scene", 0)), str(c.can_pick_tank()), str(c.pair_round()), str(c.self_turn()), 
			int(c.pair_camp()), str(pair.get("turn", {})), str(pair.get("picks", {}).get(me, {})), 
			str(pair.get("locked", {}).get(me, false)), str(oids.has(me)), str(oids)]
	var b = c.battle
	if b != null and b.active:
		text += "\nbattle map=%d room=%d look=%s started=%s ended=%s self=%d hasSelf=%s alive=%s tanks=%s" % [
			int(b.map_id), int(b.room_type), str(b.look), str(b.started), str(b.ended), int(b.self_id), str(b.tanks.has(b.self_id)), 
			str(b.alive()), str(b.tanks.keys())]
	return text
