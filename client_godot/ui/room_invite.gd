extends "flash_screen.gd"











const Atlas = preload("invite_atlas.gd")
const Text = preload("../i18n.gd")
const Pve = preload("pve_hall_atlas.gd")
const HelperModel = preload("helper_model.gd")
const PopQueue = preload("pop_queue.gd")




const HELD_TTL: float = 60.0
const HELD_NOTE: String = " (đang chơi sự kiện — đóng màn để trả lời)"

signal accepted

const DIM: Color = Color(0, 0, 0, 76.0 / 255.0)
const SHOW_IN: Array = ["lobby", "hall"]
const NAME_INK: Color = Color("ff6d06")
const FRIEND_INK: Color = Color("49ff5e")
const LABEL_RIM: Color = Color(22 / 255.0, 0, 0, 0.8)
const LINE: float = 18.0
const GUTTER: float = 2.0
const REJECT_STRANGER: int = 65536



const WORDS: Dictionary = {
	1: "@name@ mời bạn vào Room [Đấu Tự Do]", 
	2: "@name@ mời bạn vào Room [Đấu So Tài]", 
	5: "@name@ mời bạn vào Room [Đấu Team]", 
	9: "@name@ mời bạn vào Room [Đấu Xếp Hạng]", 
	8: "@name@ mời bạn đi PB 2 người", 
	3: "@name@ mời bạn cùng khiêu chiến với[@map@], chiến lực đề nghị @num1@", 
	4: "@name@ mời bạn cùng khiêu chiến với[@map@], chiến lực đề nghị @num1@", 
}
const HARD: String = "Khó"
const CHAPTER: String = "Chương @num1@"
const HARD_INK: Color = Color("ff0000")
const NEED_OK: Color = Color("00ff00")
const NEED_NEAR: Color = Color("ffae00")
const OTHER: String = "@name@ mời bạn gia nhập room"
const FRIEND: String = "Bạn của bạn là @name@"
const TIP_681: String = "Bạn đã chọn chặn người lạ mời, có thể vào Thiết Lập để hủy"
const FRIEND_ONLY_HINT: String = "Bật / tắt ở Cài đặt › Khác: Chặn người lạ gửi lời mời thi đấu."

func chat_busy() -> bool:
	return visible

var _held_key: String = ""
var _evq1_at: int = 0
var _held_clock: Timer

func _setup() -> void :
	visible = false
	if client != null:
		client.changed.connect(_follow)
	_held_clock = Timer.new()
	_held_clock.wait_time = 1.0
	_held_clock.autostart = true
	add_child(_held_clock)
	_held_clock.timeout.connect(_follow)

func _invite_key() -> String:
	var info: Dictionary = invite()
	return "" if info.is_empty() else "%d:%d:%d" % [int(info.get("from", 0)), int(info.get("room", 0)), int(info.get("type", 0))]


func _follow() -> void :
	if client == null:
		return
	if not client.room_invite.is_empty() and client.state not in SHOW_IN:
		client.decline_invite(false)
		return
	var show: bool = not client.room_invite.is_empty()
	if not show:
		_held_key = ""
	else:
		var key: String = _invite_key()
		var held: bool = PopQueue.held()
		if held and key != _held_key and not visible:
			_held_key = key
			_evq1_at = Time.get_ticks_msec()
			var line: String = message()
			if not line.is_empty():
				client.chat_note(line + HELD_NOTE)
		if key == _held_key and not visible and float(Time.get_ticks_msec() - _evq1_at) / 1000.0 > HELD_TTL:
			_held_key = ""
			client.decline_invite(false)
			return
		if held:
			show = false
	if show != visible:
		visible = show
		_toast = ""
	if show:
		queue_redraw()

func invite() -> Dictionary:
	return client.room_invite if client != null else {}



func runs() -> Array:
	var info: Dictionary = invite()
	if info.is_empty():
		return []
	var name: String = str(info.get("name", ""))
	var type: int = int(info.get("type", 0))
	var line: String = str(WORDS.get(type, OTHER))
	var fill: Dictionary = {"@name@": []}
	if type in [3, 4]:
		var map: Array = Pve.MAPS.get(str(int(info.get("map", 0))), [])
		if map.is_empty():
			return []
		var hard: bool = int(map[9]) == 2
		var title: String = Text.map_name(int(info.get("map", 0))) + ("(" + HARD + ")" if hard else "")
		var chapter: int = chapter_of(int(info.get("map", 0)))
		if chapter != 0 and type == 4:
			title = CHAPTER.replace("@num1@", str(chapter)) + " " + title
		var need: int = int(map[4])
		var mine: int = my_helper()
		fill["@map@"] = [[title, HARD_INK if hard else Color.WHITE]]
		fill["@num1@"] = [[str(need), NEED_OK if mine >= need else (NEED_NEAR if mine >= need * 0.8 else HARD_INK)]]
	else:
		line = line.replace("@map@", Text.map_name(int(info.get("map", 0))))
	if is_friend(name):
		var cut: int = FRIEND.find("@name@")
		fill["@name@"].append([FRIEND.left(cut), FRIEND_INK])
		fill["@name@"].append([name, NAME_INK])
		if cut + 6 < FRIEND.length():
			fill["@name@"].append([FRIEND.substr(cut + 6), FRIEND_INK])
	else:
		fill["@name@"].append([name, NAME_INK])
	var out: Array = []
	while not line.is_empty():
		var key: String = ""
		var at: int = line.length()
		for token: String in fill:
			var hit: int = line.find(token)
			if hit >= 0 and hit < at:
				at = hit
				key = token
		if at > 0:
			out.append([line.left(at), Color.WHITE])
		if key.is_empty():
			break
		out.append_array(fill[key])
		line = line.substr(at + key.length())
	return out


static func chapter_of(map: int) -> int:
	for city: Array in Pve.CITIES.values():
		if int(city[1]) == map or int(city[2]) == map:
			return int(city[6])
	return 0


func my_helper() -> int:
	if client == null or pack == null or client.battle_helper.is_empty():
		return 0
	if pack.helper.is_empty():
		pack.load_helper()
		return 0
	for inst: Variant in client.bags.get(5, []):
		if inst is Dictionary and str((inst as Dictionary).get("m_itemUuid", "")) == client.battle_helper:
			return int(HelperModel.record(inst, pack.helper, pack.bag, client.battle_helper).get("score", 0))
	return 0


func message() -> String:
	var text: String = ""
	for run: Array in runs():
		text += str(run[0])
	return text

func is_friend(who: String) -> bool:
	if client == null:
		return false
	for brief: Variant in client.friends.values():
		if brief is Dictionary and str(brief.get("m_name", "")) == who:
			return true
	return false


func friend_only() -> bool:
	return client != null and (int(client.character.get("setting_flag", 0)) & REJECT_STRANGER) != 0

func _xy(spot: Array) -> Vector2:
	return Vector2(float(spot[0]), float(spot[1]))

func _paint() -> void :
	if _cells.is_empty():
		_use(Atlas.FILE, Atlas.R)
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(float(Atlas.SIZE[0]), float(Atlas.SIZE[1]))
	var frame: Vector2 = at + _xy(Atlas.PANELS["frame"])
	_hit("panel", Rect2(frame * _f, _cell_size("iv_frame") * _f), false)
	_fblit("iv_frame", frame)
	_flow(runs(), at + _xy(Atlas.NODES["txtContent"]), float(Atlas.NODES["txtContent"][2]), float(Atlas.TEXTS["txtContent"][4]))
	var chk: Vector2 = at + _xy(Atlas.NODES["chkFriendOnly"])
	_fblit("iv_chk_on" if friend_only() else "iv_chk_off", chk)
	var label: Array = Atlas.TEXTS["label1"]
	var wide: float = _fwords(str(Atlas.LABEL), ARIAL_BOLD, float(label[4]), Color(str(label[5])), "l", at + _xy(label), 240.0, 1.0, 0.0, false, LABEL_RIM)
	var right: float = float(label[0]) + wide
	_hit("friend_only", Rect2(chk * _f, Vector2(right - float(Atlas.NODES["chkFriendOnly"][0]), 24.0) * _f))
	_fbutton("ok", "iv_ok", at + _xy(Atlas.NODES["btnConfirm"]))
	_fbutton("no", "iv_no", at + _xy(Atlas.NODES["btnCancel"]))
	_fblit("iv_guy", at + _xy(Atlas.GUY))


func _flow(parts: Array, at: Vector2, wide: float, px: float) -> int:
	var font: Font = _face(ARIAL_BOLD)
	var size_px: int = maxi(6, roundi(px * _f))
	var limit: float = (wide - GUTTER * 2.0) * _f
	var origin: Vector2 = (at + Vector2(GUTTER, 2.0)) * _f + Vector2(0, font.get_ascent(size_px))
	var x: float = 0.0
	var line: int = 0
	for run: Array in parts:
		var words: PackedStringArray = str(run[0]).split(" ")
		for i in range(words.size()):
			var word: String = words[i] + (" " if i < words.size() - 1 else "")
			if word.is_empty():
				continue
			var bare: float = font.get_string_size(word.rstrip(" "), HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
			if x > 0.0 and x + bare > limit:
				line += 1
				x = 0.0
			draw_string(font, origin + Vector2(x, LINE * _f * line), word, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px, run[1])
			x += font.get_string_size(word, HORIZONTAL_ALIGNMENT_LEFT, -1, size_px).x
	return line + 1



func _activate(id: String) -> void :
	if client == null or invite().is_empty():
		return
	if id == "ok":
		var name: String = str(invite().get("name", ""))
		var stranger_off: bool = friend_only() and is_friend(name)
		var idle: bool = client._room_action <= 0.0
		var reason: String = client.accept_invite()
		if stranger_off:
			client.message_box.emit(TIP_681)
		if not reason.is_empty():
			client.noticed.emit(reason)
		elif idle and client._room_action > 0.0:
			accepted.emit()
	elif id == "no":
		client.decline_invite()
	elif id == "friend_only":

		var on: bool = not friend_only()
		if not client.change_setting(int(client.character.get("setting_flag", 0)) ^ REJECT_STRANGER):
			say(FRIEND_ONLY_HINT)
		elif on and not is_friend(str(invite().get("name", ""))):
			client.decline_invite()
			client.message_box.emit(TIP_681)

func _input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		client.decline_invite()
		get_viewport().set_input_as_handled()


func _unhandled_key_input(event: InputEvent) -> void :
	if visible and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode in [KEY_ENTER, KEY_KP_ENTER]:
		get_viewport().set_input_as_handled()
