extends RefCounted






const ChatAtlas = preload("chatf_atlas.gd")
const ChatFriend = preload("chat_friend_list.gd")
const ChatFriendAtlas = preload("chat_friend_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Leader = preload("leaderboard_atlas.gd")
const MailModel = preload("mail_model.gd")
const BOLD: Font = preload("res://assets/fonts/flash_ui_bold.tres")

var open: bool = false
var list: Array = []
var top: int = 0
var box: Rect2 = Rect2()
var rows: Rect2 = Rect2()
var thumb: Array = []
var _drag_from: Vector2 = Vector2(-1, -1)
var _drag_sum: float = 0.0
var _drag_first: float = 0.0


static func cells(host: Control) -> void :
	var picked: Dictionary = {}
	for key: String in ["chatf_quick_bk", "chatf_quick_close", "chatf_sb_up", "chatf_sb_down", "chatf_sb_bk", "chatf_sb_thumb"]:
		picked[key] = ChatAtlas.R[key]
	host.call("_use", ChatAtlas.FILE, picked)
	host.call("_use", ChatFriendAtlas.FILE, {"chatfr_select_t": ChatFriendAtlas.R["chatfr_select_t"]})
	picked = {}
	for level in range(41):
		picked["level_%d" % level] = Hall.R["level_%d" % level]
	host.call("_use", Hall.FILE, picked)
	picked = {}
	for level in range(1, 16):
		for key: String in ["lb_v%d" % level, "lb_sv%d" % level]:
			if Leader.R.has(key):
				picked[key] = Leader.R[key]
	host.call("_use", Leader.FILE, picked)


func toggle(friends: Dictionary) -> void :
	if open:
		close()
		return
	open = true
	list = []
	for brief: Variant in friends.values():
		if brief is Dictionary:
			list.append(brief)
	top = 0

func close() -> void :
	open = false
	list = []
	top = 0
	box = Rect2()
	rows = Rect2()
	thumb = []

func scroll(step: int) -> void :
	top = ChatFriend.first(top + step, list.size())


func activate(id: String) -> Array:
	if not open:
		return [false, ""]
	if id.begins_with("fpk_row:"):
		var index: int = int(id.substr(8))
		var name: String = str((list[index] as Dictionary).get("m_name", "")) if index >= 0 and index < list.size() else ""
		if index >= 0 and index < list.size():
			close()
		return [true, name]
	match id:
		"fpk_close":
			close()
		"fpk:up":
			scroll(-1)
		"fpk:down":
			scroll(1)
		"fpk:pgup":
			scroll( - ChatFriend.ROWS)
		"fpk:pgdn":
			scroll(ChatFriend.ROWS)
		"fpk:thumb":
			pass
		_:
			return [false, ""]
	return [true, ""]


func wheel(step: int, at: Vector2) -> bool:
	if open and box.has_point(at):
		scroll(step * ChatFriend.WHEEL)
		return true
	return false


func drag(moved: Vector2, from: Vector2, mobile: bool, f: float) -> bool:
	if not open:
		return false
	if from != _drag_from:
		_drag_from = from
		_drag_sum = 0.0
		_drag_first = float(top)
	_drag_sum += moved.y
	var count: int = list.size()
	if not thumb.is_empty() and (thumb[0] as Rect2).has_point(from):
		var room: float = (thumb[1] as Rect2).size.y - (thumb[0] as Rect2).size.y
		var rate: float = (count - ChatFriend.ROWS) / room if room > 0.0 else 0.0
		top = ChatFriend.first(roundi(_drag_first + _drag_sum * rate), count)
		return true
	if mobile and rows.has_point(from):
		top = ChatFriend.first(roundi(_drag_first - _drag_sum / (ChatFriend.ROW * f)), count)
		return true
	return false


func draw(host: Control, at: Vector2) -> void :
	var f: float = float(host.get("_f"))
	var press: String = str(host.get("_press"))
	var hover: String = str(host.get("_hover"))
	var mobile: bool = bool(host.get("_mobile"))
	box = host.call("_fblit", "chatf_quick_bk", at, ChatFriend.SIZE.x, ChatFriend.SIZE.y)
	host.call("_hit", "panel", box, false)
	host.call("_fblit", "chatfr_select_t", at + ChatFriend.TAB)
	host.call("_fbutton", "fpk_close", "chatf_quick_close", at + ChatFriend.CLOSE)
	var origin: Vector2 = at + ChatFriend.LIST.position
	var wide: float = ChatFriend.LIST.size.x - ChatFriend.BAR
	var count: int = list.size()
	top = ChatFriend.first(top, count)
	rows = Rect2(origin * f, Vector2(wide, ChatFriend.LIST.size.y) * f)
	for i in range(top, mini(count, top + ChatFriend.ROWS)):
		var brief: Dictionary = list[i]
		var id: String = "fpk_row:%d" % i
		var o: Vector2 = origin + Vector2(0, ChatFriend.ROW * (i - top))
		var row: Rect2 = Rect2(o * f, Vector2(wide, ChatFriend.ROW) * f)
		if press == id:
			host.draw_rect(row, ChatFriend.PICK)
		elif hover == id and press.is_empty() and not mobile:
			host.draw_rect(row, ChatFriend.HOVER)
		var mid: float = ChatFriend.ROW / 2.0
		host.call("_fblit", ChatFriend.level_cell(int(brief.get("m_level", 0))), o + Vector2(0, mid - ChatFriend.LEVEL.y / 2.0), ChatFriend.LEVEL.x, ChatFriend.LEVEL.y)
		host.call("_level_fx", int(brief.get("m_level", 0)), o + Vector2(0, mid - ChatFriend.LEVEL.y / 2.0), ChatFriend.LEVEL.x)
		var who: String = _fit(MailModel.printable(str(brief.get("m_name", "")), BOLD), ChatFriend.FONT, ChatFriend.NAME_W - 2.0 * ChatFriend.PAD, f)
		host.call("_fwords", who, BOLD, ChatFriend.FONT, Color.WHITE, "l", o + Vector2(ChatFriend.NAME_X + ChatFriend.PAD, 0), ChatFriend.NAME_W, 
			1.0, 0.0, false, ChatFriend.GLOW)
		host.call("_fwords", ChatFriend.sex(int(brief.get("m_sex", 0))), BOLD, ChatFriend.FONT, Color.WHITE, "l", 
			o + Vector2(ChatFriend.SEX_X + ChatFriend.PAD, 0), ChatFriend.RENDER_W - ChatFriend.SEX_X, 1.0, 0.0, false, ChatFriend.GLOW)
		var vip: String = ChatFriend.vip_cell(int(brief.get("m_vipLevel", 0)))
		if not vip.is_empty():
			var high: float = (host.call("_cell_size", vip) as Vector2).y
			host.call("_fblit", vip, o + Vector2(ChatFriend.VIP_X, roundf(mid - high / 2.0)))
		host.call("_hit", id, row, false)
	_draw_bar(host, f, origin.x + wide, origin.y, origin.y + ChatFriend.LIST.size.y, float(count), float(ChatFriend.ROWS), float(top))


func _draw_bar(host: Control, f: float, x: float, y0: float, y1: float, total: float, page: float, value: float) -> void :
	var bar: float = ChatFriend.BAR
	host.call("_hit", "fpk:up", host.call("_fblit", "chatf_sb_up", Vector2(x, y0), bar, bar, host.call("_glow", "fpk:up")), false)
	host.call("_hit", "fpk:down", host.call("_fblit", "chatf_sb_down", Vector2(x, y1 - bar), bar, bar, host.call("_glow", "fpk:down")), false)
	var track: Rect2 = host.call("_fblit", "chatf_sb_bk", Vector2(x, y0 + bar), bar, y1 - y0 - bar * 2.0)
	thumb = []
	if total <= page:
		return
	var grip: float = maxf(10.0 * f, track.size.y * page / total)
	var y: float = track.position.y + (track.size.y - grip) * clampf(value / (total - page), 0.0, 1.0)
	host.call("_hit", "fpk:pgup", Rect2(track.position, Vector2(track.size.x, maxf(0.0, y - track.position.y))), false)
	host.call("_hit", "fpk:pgdn", Rect2(Vector2(track.position.x, y + grip), Vector2(track.size.x, maxf(0.0, track.end.y - y - grip))), false)
	var grab: Rect2 = Rect2(track.position.x, y, track.size.x, grip)
	thumb = [grab, track]
	var cell: Array = (host.get("_cells") as Dictionary).get("chatf_sb_thumb", [])
	if not cell.is_empty() and cell[0] != null:
		var tex: Texture2D = cell[0]
		var src: Rect2 = Rect2(float(cell[1][0]), float(cell[1][1]), float(cell[1][2]), float(cell[1][3]))
		var cap: float = minf(4.0 * f, grip / 2.0)
		var tint: Color = host.call("_glow", "fpk:thumb")
		host.draw_texture_rect_region(tex, Rect2(grab.position, Vector2(grab.size.x, cap)), Rect2(src.position, Vector2(src.size.x, 4)), tint)
		host.draw_texture_rect_region(tex, Rect2(grab.position + Vector2(0, cap), Vector2(grab.size.x, grip - cap * 2.0)), Rect2(src.position + Vector2(0, 4), Vector2(src.size.x, src.size.y - 8.0)), tint)
		host.draw_texture_rect_region(tex, Rect2(grab.position + Vector2(0, grip - cap), Vector2(grab.size.x, cap)), Rect2(src.position + Vector2(0, src.size.y - 4.0), Vector2(src.size.x, 4)), tint)
	host.call("_hit", "fpk:thumb", grab, false)


static func _fit(text: String, px: float, wide: float, f: float) -> String:
	var size: int = maxi(6, roundi(px * f))
	var measure: Callable = func(value: String) -> float: return BOLD.get_string_size(value, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / f
	if measure.call(text) <= wide:
		return text
	var low: int = 0
	var high: int = text.length()
	while low < high:
		var mid: int = (low + high + 1) / 2
		if measure.call(text.substr(0, mid).strip_edges() + "...") <= wide:
			low = mid
		else:
			high = mid - 1
	return text.substr(0, low).strip_edges() + "..."
