extends Control









const Atlas = preload("../ui/chatf_atlas.gd")
const REGULAR: Font = preload("res://assets/fonts/flash_ui.tres")
const BOLD: Font = preload("res://assets/fonts/flash_ui_bold.tres")
const PANEL: Vector2 = Vector2(300, 88)
const CONTROL_W: float = 22.0
const LINE: float = 20.0
const PX: int = 14
const PAD: float = 2.0
const PAGE: float = 40.0
const EMO_SIDE: float = 24.0
const GLOW: Color = Color(22 / 255.0, 0.0, 0.0, 0.8)
const SIDE: Array = [["clear", "chatf_clear", 0.0], ["up", "chatf_up", 22.0], ["down", "chatf_down", 44.0], ["bottom", "chatf_end", 66.0]]

const BAR_BUTTONS: Array = [["send", "chatf_send", 342.0], ["quick", "chatf_quick", 381.0], ["emote", "chatf_emote", 414.0]]
const BAR_SIZE: Vector2 = Vector2(464, 40)
const TIPS: Dictionary = {"clear": "Xóa", "up": "Lên", "down": "Xuống", "bottom": "Cuối", "channel": "Nhấp đổi kênh.", "send": "Gửi", 
	"quick": "Trả lời nhanh", "emote": "Chọn biểu cảm"}
const EMO_W: float = 286.0
const EMO_CELL: float = 36.0
const EMO_COLS: int = 7
const EMO_GRID_X: float = 17.0
const EMO_ICON: float = 28.0
const EMO_PAGE: int = 21
const DRAFT_ICON: float = 22.0
const QUICK_AT: Vector2 = Vector2(368, -264)

const PHRASES: Array = ["Tuyển người đi đấu So Tài đây !!!", "Tuyển người đi đấu Xếp Hạng đây !!!", "Tuyển người vào Guild đây !!!", 
	"Tuyển người vào đi Phụ Bản đây !!!", "Cần thêm bạn đi PvP chung đây !!!", "Cần vào Guild đây !!!", "Cần đi đấu So Tài đây !!!", 
	"Cần đi đấu Xếp Hạng đây !!!", "Kéo mình phụ bản với"]

const BAR_BG: Array = [["chat_chatbghead", 6.0, -3.0, 0.0], ["chat_chatbgmid", 116.0, -3.0, 313.0], ["chat_chatbgtail", 429.0, -3.0, 0.0], 
	["chat_iptbghead", 116.0, 4.0, 0.0], ["chat_iptbgmid", 134.0, 4.0, 221.0], ["chat_iptbgtail", 355.0, 4.0, 0.0]]

var view: Control
var emotes: Node
var input: LineEdit
var atlas: Texture2D
var up: float = 0.0
var picker: bool = false
var quick: bool = false
var emo_frames: bool = false
var emo_pack: String = ""
var emo_page: int = 0
var tokens: Dictionary = {}
var hover: String = ""
var bar: Vector2 = Vector2(-1, -1)
var s: float = 1.0
var rows_shown: Array = []
var draft_shown: Array = []
var _hits: Dictionary = {}
var _tips: Dictionary = {}
var _rows: Array = []
var _key: Array = []
var _lines: Control
var _tip: Control
var _draft: Control
var _tip_id: String = ""
var _tip_at: float = 0.0
var _clock: float = 0.0
var _box: StyleBoxFlat = StyleBoxFlat.new()
var _panel: Rect2 = Rect2()

func _ready() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if atlas == null and ResourceLoader.exists(Atlas.FILE):
		atlas = load(Atlas.FILE)
	_lines = Control.new()
	_lines.name = "ChatLines"
	_lines.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_lines.clip_contents = true
	_lines.draw.connect(_draw_lines)
	add_child(_lines)
	_tip = Control.new()
	_tip.name = "ChatTip"
	_tip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tip.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_tip.draw.connect(_draw_tip)
	add_child(_tip)


func attach(line: LineEdit) -> void :
	input = line
	_draft = Control.new()
	_draft.name = "ChatDraft"
	_draft.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_draft.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_draft.draw.connect(_draw_draft)
	line.add_child(_draft)

func _battle():
	return view.client.battle if view != null and view.client != null else null


func sync(delta: float) -> void :
	_clock += delta

	var now: String = "" if view._touch or not view.chat_bar_shown() else hit_at(view.get_local_mouse_position())
	hover = now
	if now != _tip_id:
		_tip_id = now
		_tip_at = _clock
	_hits = {"emo": {}, "quick": {}, "bar": {}, "panel": {}}
	_tips = {}
	var hud = view._hud
	s = hud.scale
	_panel = hud.chat_panel
	_lines.visible = _panel.size.x > 0.0 and not view.chat_loading
	_lines.position = _panel.position
	_lines.size = _panel.size
	if not view.chat_bar_shown():
		picker = false
	z_index = 1 if view.chat_loading else 0
	queue_redraw()
	_lines.queue_redraw()
	_tip.queue_redraw()
	if _draft != null:
		_draft.queue_redraw()

func _hit(layer: String, id: String, rect: Rect2) -> void :
	if not _hits.has(layer):
		_hits[layer] = {}
	_hits[layer][id] = rect


func hit_at(point: Vector2) -> String:
	for layer: String in ["emo", "quick", "bar", "panel"]:
		var found: String = ""
		for id: String in (_hits.get(layer, {}) as Dictionary):
			if (_hits[layer][id] as Rect2).has_point(point):

				if found.is_empty() or found in ["emo_panel", "quick_panel", "bar"]:
					found = id
		if not found.is_empty():
			return found
	return ""


func click(point: Vector2) -> bool:
	if not view.chat_bar_shown():
		return false
	var id: String = hit_at(point)
	if id.is_empty():
		return false
	activate(id)
	return true


func activate(id: String) -> void :
	_activate(id)
	if view.chat_bar_shown() and input != null and input.visible:
		input.grab_focus()

func _activate(id: String) -> void :
	var battle = _battle()
	if id.begins_with("emo:"):
		_choose(int(id.substr(4)))
		return
	if id.begins_with("emotab:"):
		emo_pack = id.substr(7)
		emo_page = 0
		return
	if id.begins_with("emomode:"):
		emo_frames = id == "emomode:frames"
		emo_page = 0
		return
	if id.begins_with("emopage:"):
		emo_page = maxi(0, emo_page + int(id.substr(8)))
		return
	if id.begins_with("emoframe:"):



		if view != null and view.client != null:
			view.client.equip_chat_frame(id.substr(9))
		picker = false
		return
	if id.begins_with("say:"):

		input.text = str(PHRASES[int(id.substr(4))])
		input.caret_column = input.text.length()
		view.submit_chat()
		quick = false
		return
	match id:
		"clear":

			if battle != null:
				battle.chat_clear()
			up = 0.0
		"up":
			up = minf(up + PAGE, _max_up())
		"down":
			up = maxf(0.0, up - PAGE)
		"bottom":
			up = 0.0
		"channel":
			view.cycle_chat_channel()
		"send":
			view.submit_chat()
		"quick":
			quick = true
		"quick_close":
			quick = false
		"emote":

			picker = not picker
			if picker:
				emo_frames = false
				if emotes != null:
					emotes.refresh(true)
		"emo_close":
			picker = false



func _font(bold: bool) -> Font:
	return BOLD if bold else REGULAR


func text_width() -> float:
	return (PANEL.x - (CONTROL_W if view.chat_open else 0.0)) - 2.0 * PAD


func rows() -> Array:
	var battle = _battle()
	if battle == null:
		return []
	var width: float = text_width()
	var key: Array = [battle.get_instance_id(), battle.chat_seq, battle.chat_from, battle.chat.size(), width, emotes.rev if emotes != null else 0, 
		emotes.loaded if emotes != null else false]
	if key == _key:
		return _rows
	_key = key
	up = 0.0
	_rows = []
	for line: Dictionary in battle.chat_shown():
		_rows.append_array(_wrap_line(line, width))
	return _rows


func _wrap_line(line: Dictionary, width: float) -> Array:
	var parts: Array = []
	if not str(line.get("head", "")).is_empty():
		parts.append([str(line.head), true, line.get("color", Color.WHITE)])
	if not str(line.get("name", "")).is_empty():
		parts.append([str(line.name), true, line.get("name_color", Color.WHITE)])
	var color: Color = line.get("color", Color.WHITE)
	var raw: String = str(line.get("raw", ""))
	if raw.is_empty() or emotes == null or not emotes.has_emote(raw):
		parts.append([str(line.get("text", "")), false, color])
	else:
		var first: bool = true
		for piece: Array in emotes.pieces(raw):
			if piece[0] == "emote":
				if first:
					parts.append([": ", false, color])
				parts.append(["", false, color, str(piece[1])])
			else:
				parts.append([(": " if first else "") + str(piece[1]), false, color])
			first = false
	var out: Array = []
	var row: Array = []
	var x: float = 0.0
	for part: Array in parts:
		if part.size() > 3:
			if x > 0.0 and x + EMO_SIDE > width:
				out.append(row)
				row = []
				x = 0.0
			row.append(["", false, part[2], x, part[3]])
			x += EMO_SIDE
			continue
		var font: Font = _font(part[1])
		var rest: String = str(part[0])
		while not rest.is_empty():
			var fit: int = _fit(rest, font, width - x)
			if fit >= rest.length():
				row.append([rest, part[1], part[2], x])
				x += font.get_string_size(rest, HORIZONTAL_ALIGNMENT_LEFT, -1, PX).x
				break
			var cut: int = rest.substr(0, fit + 1).rfind(" ") if fit > 0 else -1
			if cut <= 0:
				if x > 0.0:
					out.append(row)
					row = []
					x = 0.0
					rest = rest.lstrip(" ")
					continue
				cut = maxi(1, fit)
				row.append([rest.substr(0, cut), part[1], part[2], x])
				rest = rest.substr(cut)
			else:
				row.append([rest.substr(0, cut), part[1], part[2], x])
				rest = rest.substr(cut + 1).lstrip(" ")
			out.append(row)
			row = []
			x = 0.0
	if not row.is_empty():
		out.append(row)
	return out

func _fit(text: String, font: Font, room: float) -> int:
	var low: int = 0
	var high: int = text.length()
	while low < high:
		var mid: int = (low + high + 1) / 2
		if font.get_string_size(text.substr(0, mid), HORIZONTAL_ALIGNMENT_LEFT, -1, PX).x <= room + 0.01:
			low = mid
		else:
			high = mid - 1
	return low

func _content_height() -> float:
	return rows().size() * LINE + 2.0 * PAD

func _max_up() -> float:
	return maxf(0.0, _content_height() - PANEL.y)


func _draw_lines() -> void :
	rows_shown = []
	var battle = _battle()
	if battle == null:
		return
	_lines.draw_set_transform(Vector2.ZERO, 0, Vector2(s, s))
	var left: float = 0.0
	if view.chat_open:
		left = CONTROL_W
		for item: Array in SIDE:
			var id: String = str(item[0])
			var spot: Vector2 = Vector2(0, float(item[2]))
			_cell(_lines, str(item[1]), spot, Vector2.ZERO, _lit(id))
			_hit("panel", id, Rect2(_panel.position + spot * s, Vector2(22, 22) * s))
	var all: Array = rows()
	up = clampf(up, 0.0, _max_up())
	var top: float = _max_up() - up
	for i in range(all.size()):
		var y: float = PAD + i * LINE - top
		if y + LINE < - EMO_SIDE or y > PANEL.y:
			continue
		var shown: Array = []
		for seg: Array in all[i]:
			var x: float = left + PAD + float(seg[3])
			if seg.size() > 4:
				shown.append("@" + str(seg[4]))
				_emote(_lines, str(seg[4]), Rect2(x, y - 2.0, EMO_SIDE, EMO_SIDE))
				continue
			shown.append(str(seg[0]))
			var font: Font = _font(seg[1])
			var base: Vector2 = Vector2(x, y + (LINE + font.get_ascent(PX) - font.get_descent(PX)) / 2.0)
			_lines.draw_string_outline(font, base, str(seg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, PX, 3, GLOW)
			_lines.draw_string(font, base, str(seg[0]), HORIZONTAL_ALIGNMENT_LEFT, -1, PX, seg[2])
		if y >= - LINE and y < PANEL.y:
			rows_shown.append(shown)




func draw_bar(origin: Vector2, canvas: CanvasItem = null) -> void :
	var c: CanvasItem = canvas if canvas != null else view
	bar = origin
	_hit("bar", "bar", Rect2(origin, BAR_SIZE * s))
	_hit("bar", "channel", Rect2(origin + Vector2(13, 6) * s, Vector2(91, 27) * s))
	for item: Array in BAR_BUTTONS:
		var id: String = str(item[0])
		var spot: Vector2 = Vector2(float(item[2]), 3)
		if id == "send":

			_cell(c, "chatf_send", spot + Vector2(4, 6), Vector2.ZERO, _lit(id))
		else:
			_cell(c, str(item[1]), spot, Vector2(32, 28), _lit(id))
		_hit("bar", id, Rect2(origin + spot * s, Vector2(32, 28) * s))


func _draw() -> void :

	if not view.chat_bar_shown() or bar.x < 0.0 or ( not view.chat_loading and view._hud.rects.get("chat_text", Rect2()).size.x <= 0.0):
		return
	draw_set_transform(bar, 0, Vector2(s, s))
	if quick:
		_draw_quick()
	if picker:
		_draw_picker()
	draw_set_transform(Vector2.ZERO)

func _draw_quick() -> void :
	var at: Vector2 = QUICK_AT
	_cell(self, "chatf_quick_bk", at)
	_hit("quick", "quick_panel", Rect2(bar + at * s, Vector2(264, 264) * s))
	_words(self, "Câu trò chuyện có sẵn:", BOLD, 16, Color("38f929"), "l", at + Vector2(8, 13), 210.0, 0.0, 1.0)
	_cell(self, "chatf_quick_close", at + Vector2(225, 6), Vector2.ZERO, _lit("quick_close"))
	_hit("quick", "quick_close", Rect2(bar + (at + Vector2(225, 6)) * s, Vector2(25, 22) * s))
	for i in range(PHRASES.size()):
		var id: String = "say:%d" % i
		var spot: Vector2 = at + Vector2(8, 43 + 24 * i)
		_hit("quick", id, Rect2(bar + spot * s, Vector2(240, 22) * s))
		_words(self, str(PHRASES[i]), REGULAR, 12, Color("f16422") if hover == id else Color.WHITE, "l", spot + Vector2(2, 0), 236.0, 22.0)


func picker_layout() -> Dictionary:
	var packs: Array = emotes.picker_packs() if emotes != null else []
	var ids: Array = packs.map( func(pack: Dictionary) -> String: return str(pack["id"]))
	if not ids.has(emo_pack):
		emo_pack = str(ids[0]) if not ids.is_empty() else ""
	var tabs: Array = []
	var tab_x: float = 8.0
	var tab_y: float = 43.0
	for pack: Dictionary in packs:
		var name: String = str(pack["label"]) if not str(pack["label"]).is_empty() else str(pack["id"])
		var wide: float = maxf(44.0, name.length() * 7.0 + 18.0)
		if tab_x > 8.0 and tab_x + wide > EMO_W - 8.0:
			tab_x = 8.0
			tab_y += 26.0
		tabs.append([str(pack["id"]), name, tab_x, tab_y, wide])
		tab_x += wide + 4.0
	var grid_y: float = tab_y + 30.0
	var high: float = grid_y + 3.0 * EMO_CELL + 14.0
	return {"at": Vector2(maxf(0.0, 414.0 + 32.0 - EMO_W), - high - 4.0), "high": high, "grid_y": grid_y, "tabs": tabs}

func _draw_picker() -> void :
	var layout: Dictionary = picker_layout()
	var at: Vector2 = layout.at
	var high: float = layout.high
	var grid_y: float = layout.grid_y
	var box: Rect2 = Rect2(at, Vector2(EMO_W, high))
	for i in range(3, 0, -1):
		_round(box.grow(i), Color("160000", 0.2), 11 + i)
	_round(box, Color("29e9f9"), 11)
	_round(Rect2(at + Vector2(3, 3), Vector2(EMO_W - 6.0, high - 6.0)), Color("00579d"), 8)
	_round(Rect2(at + Vector2(5, 5), Vector2(EMO_W - 10.0, high - 10.0)), Color("0065ac"), 6)
	draw_rect(Rect2(at + Vector2(3, 35), Vector2(EMO_W - 6.0, 2.0)), Color("29e9f9"))
	_hit("emo", "emo_panel", Rect2(bar + at * s, box.size * s))
	_tile(at + Vector2(7, grid_y - 6.0), Vector2(EMO_W - 14.0, 3.0 * EMO_CELL + 12.0), Color("004f8f"), Color("15aad4"))
	for mode: Array in [["frames", "Khung chat", 70.0, 86.0], ["emotes", "Emote", 8.0, 58.0]]:
		var id: String = "emomode:" + str(mode[0])
		var active: bool = (str(mode[0]) == "frames") == emo_frames
		var over: bool = not active and hover == id
		var spot: Vector2 = at + Vector2(float(mode[2]), 5)
		var wide: float = float(mode[3])
		_tile(spot, Vector2(wide, 26), Color("004f8f") if active else (Color("0a86cc") if over else Color("0065ac")), Color("29e9f9") if active or over else Color("15aad4"))
		_words(self, str(mode[1]), BOLD, 14, Color("38f929") if active else Color("bfe6f7"), "c", spot + Vector2(0, 3), wide)
		if not active:
			_hit("emo", id, Rect2(bar + spot * s, Vector2(wide, 26) * s))
	var choices: Array = ["reset"]
	if emotes != null:
		for pack: Dictionary in emotes.frame_packs():
			choices.append(str(pack["id"]))
	var items: Array = (emotes.pack_of[emo_pack] as Dictionary)["items"] if emotes != null and not emo_pack.is_empty() else []
	var count: int = choices.size() if emo_frames else items.size()
	var pages: int = maxi(1, ceili(count / (6.0 if emo_frames else float(EMO_PAGE))))
	emo_page = clampi(emo_page, 0, pages - 1)
	_words(self, "%d/%d" % [emo_page + 1, pages], BOLD, 12, Color.WHITE, "c", at + Vector2(EMO_W - 97.0, 9), 34.0)
	_page_button(-1, emo_page > 0, at + Vector2(EMO_W - 119.0, 8))
	_page_button(1, emo_page + 1 < pages, at + Vector2(EMO_W - 63.0, 8))
	_cell(self, "chatf_quick_close", at + Vector2(EMO_W - 39.0, 7), Vector2.ZERO, _lit("emo_close"))
	_hit("emo", "emo_close", Rect2(bar + (at + Vector2(EMO_W - 39.0, 7)) * s, Vector2(25, 22) * s))
	if emo_frames:
		_words(self, "Nhấn vào khung để dùng cho tin nhắn", REGULAR, 12, Color("bfe6f7"), "l", at + Vector2(10, 45), EMO_W - 20.0)
		for i in range(6):
			var n: int = emo_page * 6 + i
			if n >= choices.size():
				break
			var frame: String = str(choices[n])
			var id: String = "emoframe:" + frame
			var spot: Vector2 = at + Vector2(13.0 + (i % 2) * 133.0, grid_y + floorf(i / 2.0) * 38.0)
			var colors: Array = _frame_colors(frame)
			var name: String = "Mặc định" if frame == "reset" else str((emotes.pack_of[frame] as Dictionary)["label"])
			_round(Rect2(spot, Vector2(127, 34)), Color(0, 0, 0, 0), 9, Color("f16422") if hover == id else Color("004f8f"), 2)
			_round(Rect2(spot + Vector2(3, 3), Vector2(121, 28)), colors[0], 7, colors[1], 2)
			_words(self, name, BOLD, 12, colors[2], "c", spot + Vector2(0, 7), 127.0)
			_hit("emo", id, Rect2(bar + spot * s, Vector2(127, 34) * s))
			_tips[id] = "Khung mặc định" if frame == "reset" else "Dùng khung " + name
		return
	for tab: Array in layout.tabs:
		var id: String = "emotab:" + str(tab[0])
		var spot: Vector2 = at + Vector2(float(tab[2]), float(tab[3]))
		var wide: float = float(tab[4])
		var selected: bool = str(tab[0]) == emo_pack
		var over: bool = hover == id
		_tile(spot, Vector2(wide, 22), Color("f16422") if selected else (Color("0a86cc") if over else Color("004f8f")), Color("ffb38a") if selected else (Color("29e9f9") if over else Color("15aad4")))
		_words(self, str(tab[1]), BOLD, 12, Color.WHITE, "c", spot + Vector2(0, 2), wide)
		_hit("emo", id, Rect2(bar + spot * s, Vector2(wide, 22) * s))
		_tips[id] = str(tab[1])
	for i in range(EMO_PAGE):
		var n: int = emo_page * EMO_PAGE + i
		var spot: Vector2 = at + Vector2(EMO_GRID_X + (i % EMO_COLS) * EMO_CELL, grid_y + floorf(i / float(EMO_COLS)) * EMO_CELL)
		if n >= items.size():
			_tile(spot, Vector2(EMO_CELL, EMO_CELL), Color("00579d"), Color("10659f"))
			continue
		var id: String = "emo:%d" % n
		var item: String = str(items[n])
		var over: bool = hover == id
		_tile(spot, Vector2(EMO_CELL, EMO_CELL), Color("f16422") if over else Color("0065ac"), Color("ffb38a") if over else Color("1683c0"))
		_emote(self, "%s:%s" % [emo_pack, item], Rect2(spot + Vector2.ONE * (EMO_CELL - EMO_ICON) / 2.0, Vector2(EMO_ICON, EMO_ICON)))
		_hit("emo", id, Rect2(bar + spot * s, Vector2(EMO_CELL, EMO_CELL) * s))
		var code: String = emotes.code(emo_pack, item)
		_tips[id] = emotes.label(emo_pack, item) + ("  /" + code if not code.is_empty() else "")
	if emotes == null or not emotes.loaded:
		_words(self, "Đang tải danh sách biểu cảm…", BOLD, 12, Color("bfe6f7"), "c", at + Vector2(7, grid_y - 6.0), EMO_W - 14.0, 3.0 * EMO_CELL + 12.0)

func _tile(spot: Vector2, wide: Vector2, fill: Color, line: Color) -> void :
	_round(Rect2(spot + Vector2(1, 1), wide - Vector2(2, 2)), fill, 5, line, 1)

func _page_button(step: int, live: bool, spot: Vector2) -> void :
	var alpha: float = 1.0 if live else 0.4
	_round(Rect2(spot, Vector2(20, 20)), Color("008095", alpha), 3)
	_round(Rect2(spot, Vector2(20, 18)), Color("29e9f9", alpha), 3)
	var tip: float = 6.0 if step < 0 else 14.0
	var base: float = 13.0 if step < 0 else 7.0
	draw_colored_polygon(PackedVector2Array([spot + Vector2(tip, 9), spot + Vector2(base, 4), spot + Vector2(base, 14)]), Color(1, 1, 1, alpha))
	if live:
		_hit("emo", "emopage:%d" % step, Rect2(bar + spot * s, Vector2(20, 20) * s))

func _frame_colors(id: String) -> Array:
	if id == "reset":
		return [Color("ffffff"), Color("8291a5"), Color("172c49")]
	var frame: Array = (emotes.pack_of.get(id, {}) as Dictionary).get("frame", [])
	return frame if frame.size() == 3 else [Color("172c49"), Color("75bfff"), Color("eff7ff")]


func _choose(n: int) -> void :
	picker = false
	if emotes == null or emo_pack.is_empty() or not emotes.pack_of.has(emo_pack):
		return
	var items: Array = (emotes.pack_of[emo_pack] as Dictionary)["items"]
	if n < 0 or n >= items.size():
		return
	insert_emote(emo_pack, str(items[n]))


func insert_emote(pack: String, item: String) -> bool:
	if emotes == null or input == null or not emotes.usable(pack, item):
		return false
	var text: String = input.text
	var start: int = clampi(input.caret_column, 0, text.length())
	var end: int = start
	if input.has_selection():
		start = clampi(input.get_selection_from_column(), 0, text.length())
		end = clampi(input.get_selection_to_column(), start, text.length())
	var token: String = "[emote:%s:%s]" % [pack, item]
	var marker: String = token
	var short: String = ""
	var code: String = emotes.code(pack, item)
	if not code.is_empty():
		token = "/" + code
		if not emotes.expand_codes(text.substr(0, start) + token).ends_with("]"):
			token = " " + token
		if end < text.length() and text.unicode_at(end) >= 48 and text.unicode_at(end) <= 57:
			token += " "
	else:
		short = "[%s]" % item
		var suffix: int = 2
		while tokens.has(short) and str(tokens[short]) != marker:
			short = "[%s %d]" % [item, suffix]
			suffix += 1
		token = short
	var joined: String = text.substr(0, start) + token + text.substr(end)
	if input.max_length > 0 and joined.length() > input.max_length:
		var battle = _battle()
		if battle != null:
			battle.chat_rejected("Ô nhập đã đủ %d ký tự." % input.max_length)
		return false
	if not short.is_empty():
		tokens[short] = marker
	input.text = joined
	input.caret_column = start + token.length()
	return true



func draft_spans() -> Array:
	var out: Array = []
	if emotes == null or input == null:
		return out
	var text: String = input.text
	var spans: Array = emotes.find_codes(text)
	var start: int = text.find("[")
	while start >= 0:
		var close: int = text.find("]", start)
		if close < 0:
			break
		var token: String = str(tokens.get(text.substr(start, close - start + 1), ""))
		if token.begins_with("[emote:") and token.ends_with("]"):
			spans.append([start, close + 1, token.substr(7, token.length() - 8)])
		start = text.find("[", close + 1)
	for span: Array in spans:
		var key: String = str(span[2])
		if emotes.usable(key.get_slice(":", 0), key.get_slice(":", 1)):
			out.append(span)
	return out


func draft_covers() -> Array:
	var out: Array = []
	if input == null or not input.visible or input.text.is_empty():
		return out
	var text: String = input.text
	var font: Font = input.get_theme_font("font")
	var px: int = input.get_theme_font_size("font_size")
	var scroll: float = float(input.call("get_scroll_offset")) if input.has_method("get_scroll_offset") else 0.0
	var high: float = input.size.y
	var side: float = minf(DRAFT_ICON * s, high - 2.0 * s)
	var picked: bool = input.has_selection()
	var from: int = input.get_selection_from_column() if picked else 0
	var to: int = input.get_selection_to_column() if picked else 0
	for span: Array in draft_spans():
		var start: int = int(span[0])
		var end: int = int(span[1])
		if picked and from < end and to > start:
			continue
		var x: float = scroll + font.get_string_size(text.substr(0, start), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x
		var run: float = scroll + font.get_string_size(text.substr(0, end), HORIZONTAL_ALIGNMENT_LEFT, -1, px).x - x
		if x < -0.01 or x + run > input.size.x + 0.01:
			continue
		var icon: Rect2 = Rect2(Vector2(x + maxf(0.0, (run - side) / 2.0), maxf(0.0, (high - side) / 2.0)), Vector2(side, side))
		out.append([Rect2(x, 0.0, run, high), icon, str(span[2])])
	return out

func _draw_draft() -> void :
	draft_shown = []
	if bar.x < 0.0 or emotes == null:
		return
	for cover: Array in draft_covers():
		var key: String = str(cover[2])
		var tex: Texture2D = emotes.texture(key)
		if emotes.state(key) == "bad":
			continue
		for piece: Array in BAR_BG:
			_draft_bar(str(piece[0]), Vector2(float(piece[1]), float(piece[2])), float(piece[3]), cover[0])
		draft_shown.append(key)
		if tex == null or tex.get_width() <= 0 or tex.get_height() <= 0:
			continue
		var box: Rect2 = cover[1]
		var scale: float = minf(box.size.x / tex.get_width(), box.size.y / tex.get_height())
		var shown: Vector2 = Vector2(tex.get_width(), tex.get_height()) * scale
		_draft.draw_texture_rect(tex, Rect2(box.position + (box.size - shown) / 2.0, shown), false)

func _draft_bar(name: String, at: Vector2, wide: float, area: Rect2) -> void :
	var tex: Texture2D = view._hud.tex(name)
	if tex == null:
		return
	var dest: Rect2 = Rect2(bar + at * s - input.position, Vector2(wide if wide > 0.0 else float(tex.get_width()), float(tex.get_height())) * s)
	var part: Rect2 = dest.intersection(area)
	if part.size.x <= 0.0 or part.size.y <= 0.0:
		return
	var scale: Vector2 = Vector2(tex.get_width() / dest.size.x, tex.get_height() / dest.size.y)
	_draft.draw_texture_rect_region(tex, part, Rect2((part.position - dest.position) * scale, part.size * scale))



func _lit(id: String) -> Color:
	return Color(1.16, 1.16, 1.16, 1.0) if hover == id else Color.WHITE


func _cell(c: CanvasItem, name: String, at: Vector2, wide: Vector2 = Vector2.ZERO, tint: Color = Color.WHITE) -> void :
	var region: Array = Atlas.R.get(name, [])
	if atlas == null or region.is_empty():
		return
	var size: Vector2 = wide if wide != Vector2.ZERO else Vector2(float(region[2]), float(region[3]))
	c.draw_texture_rect_region(atlas, Rect2(at, size), Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3])), tint)

func _emote(c: CanvasItem, key: String, box: Rect2) -> void :
	if emotes == null:
		return
	var tex: Texture2D = emotes.texture(key)
	if tex == null or tex.get_width() <= 0 or tex.get_height() <= 0:
		return
	var scale: float = minf(box.size.x / tex.get_width(), box.size.y / tex.get_height())
	var shown: Vector2 = Vector2(tex.get_width(), tex.get_height()) * scale
	c.draw_texture_rect(tex, Rect2(box.position + (box.size - shown) / 2.0, shown), false)


func _words(c: CanvasItem, text: String, font: Font, px: int, color: Color, align: String, at: Vector2, wide: float, high: float = 0.0, rim: float = 0.0) -> void :
	var shown: int = px
	while shown > 8 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, shown).x > wide:
		shown -= 1
	var middle: float = at.y + (high / 2.0 if high > 0.0 else 2.0 + px * 0.55)
	var base: Vector2 = Vector2(at.x, middle + (font.get_ascent(shown) - font.get_descent(shown)) / 2.0)
	var mode: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
	if align == "c":
		mode = HORIZONTAL_ALIGNMENT_CENTER
	elif align == "r":
		mode = HORIZONTAL_ALIGNMENT_RIGHT
	if rim > 0.0:
		c.draw_string_outline(font, base, text, mode, wide, shown, maxi(1, roundi(rim)), Color(GLOW, GLOW.a * color.a))
	c.draw_string(font, base, text, mode, wide, shown, color)

func _round(rect: Rect2, fill: Color, radius: int, edge: Color = Color(0, 0, 0, 0), width: int = 0) -> void :
	_box.bg_color = fill
	_box.set_corner_radius_all(maxi(1, mini(radius, floori(rect.size.y / 2.0))))
	_box.border_color = edge
	_box.set_border_width_all(width)
	draw_style_box(_box, rect)


func _draw_tip() -> void :
	if view._touch or _tip_id.is_empty() or _clock - _tip_at < 0.1 or hover != _tip_id:
		return
	var text: String = str(TIPS.get(_tip_id, _tips.get(_tip_id, "")))
	if text.is_empty():
		return
	var wide: float = BOLD.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12).x + 12.0
	var mouse: Vector2 = view.get_local_mouse_position()
	var at: Vector2 = mouse / s + Vector2(11, 22)
	at.x = clampf(at.x, 0.0, maxf(0.0, view.size.x / s - wide))
	at.y = clampf(at.y, 0.0, maxf(0.0, view.size.y / s - 22.0))
	_tip.draw_set_transform(Vector2.ZERO, 0, Vector2(s, s))
	_box.bg_color = Color("e9f9ff")
	_box.set_corner_radius_all(4)
	_box.border_color = Color.WHITE
	_box.set_border_width_all(1)
	_tip.draw_style_box(_box, Rect2(at, Vector2(wide, 22)))
	_words(_tip, text, BOLD, 12, Color("086da5"), "l", at + Vector2(6, 0), wide - 12.0, 22.0)


func tip_text() -> String:
	if _tip_id.is_empty() or hover != _tip_id:
		return ""
	return str(TIPS.get(_tip_id, _tips.get(_tip_id, "")))
