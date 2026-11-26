extends RefCounted








const Settings = preload("res://settings.gd")
const St2Skin = preload("st2_skin.gd")
const LobbySkins = preload("lobby_skins.gd")
const LobbyBar = preload("lobby_bar.gd")
const LobbyThemes = preload("lobby_themes.gd")
const IslandNoel = preload("island_noel.gd")
const VoiceClient = preload("voice_client.gd")
const PcMouse = preload("pc_mouse.gd")
const TouchGfx = preload("res://battle/touch_gfx.gd")





const CONSUMERS: Array[String] = ["res://battle/touch_lq.gd", "res://battle/touch_cam.gd", "res://battle/touch_layout.gd", "res://battle/touch_life.gd", 
	"res://battle/touch_gfx.gd", "res://net/wifi4g.gd", "res://net/net_check.gd", "res://battle/quick_ping.gd"]
const TOUCH_GFX: String = "res://battle/touch_gfx.gd"

const OWN: Array[String] = ["tc_bright", "master_vol"]

const GATED: Array[String] = ["net_wifi_4g", "cam_pan_speed"]

const TABS: Array[String] = ["ctl", "cam", "gfx", "snd", "look", "misc"]
const TAB_NAMES: Dictionary = {"ctl": "ĐIỀU KHIỂN", "cam": "CAMERA", "gfx": "HÌNH ẢNH", "snd": "ÂM THANH", "look": "GIAO DIỆN", "misc": "KHÁC"}
const TAB_ICONS: Dictionary = {"ctl": "tab_keys", "cam": "card_camera", "gfx": "tab_video", "snd": "tab_sound", "look": "tab_look", "misc": "tab_other"}



const MI_DIR: String = "res://assets/ui/mobile/"
const MI_NAMES: Array[String] = ["aim_marker", "chat_quick", "exit", "layout_edit", "mic", "mic_off", "preset_newbie", "preset_pro", "recenter", "reset", 
	"scoreboard", "settings", "speaker", "speaker_off", "tab_account", "tab_audio", "tab_camera", "tab_controls", "tab_graphics", "tab_network", 
	"tab_other", "tab_privacy"]
const MI_TABS: Dictionary = {"ctl": "tab_controls", "cam": "tab_camera", "gfx": "tab_graphics", "snd": "tab_audio", "look": "layout_edit", "misc": "tab_other"}
const MI_PRESETS: Dictionary = {"new": "preset_newbie", "pro": "preset_pro"}


const PRESETS: Dictionary = {
	"new": {"tc_cast": "tap", "tc_cancel": "zone", "tc_aim": "strong", "tc_target": "near", "tc_stick": "follow", "tc_sens": 50, "tc_self_hold": true, 
		"tc_mark": true, "tc_fire_move": true}, 
	"pro": {"tc_cast": "drag", "tc_cancel": "range", "tc_aim": "off", "tc_target": "hp_pct", "tc_stick": "fixed", "tc_sens": 65, "tc_self_hold": true, 
		"tc_mark": true, "tc_fire_move": true}, 
}
const PRESET_NAMES: Dictionary = {"new": "Tân thủ", "pro": "Cao thủ"}
const ASK_RESET: String = "Đưa mọi cài đặt trên máy này về mặc định? (Mật mã cấp 2, phím trên máy chủ và tuỳ chọn tài khoản giữ nguyên.)"


const BG: Color = Color("061a33")
const SIDE: Color = Color("0a2648")
const ROW: Color = Color("0e3260")
const ROW_EDGE: Color = Color("2d6fb3")
const SEG: Color = Color("12407a")
const SEG_EDGE: Color = Color("4f9be0")
const ON_TOP: Color = Color("ffc540")
const ON_LOW: Color = Color("e66a08")
const ACCENT: Color = Color("ffb630")
const SOFT: Color = Color("9fc3ea")
const GOOD: Color = Color("7ff179")
const BAD: Color = Color("ff6b5a")


static var force_touch: int = -1

static var force_android: int = -1

static var reads_override: Variant = null
static var _reads: Dictionary = {}
static var _reads_done: bool = false
static var _mi: Dictionary = {}

var tab: String = "ctl"
var classic: String = ""
var _scroll: Dictionary = {}
var _content: float = 0.0
var _view: Rect2 = Rect2()
var _k: float = 1.0
var _w: float = 960.0
var _h: float = 540.0
var _x0: float = 184.0
var _x1: float = 946.0
var _y: float = 0.0
var _top: float = 64.0
var _host: Control

static func wanted() -> bool:
	if force_touch >= 0:
		return force_touch == 1
	return TouchGfx.touch_screen()

static func android() -> bool:
	return OS.has_feature("android") if force_android < 0 else force_android == 1


static func mi_tex(name: String, px: float) -> Texture2D:
	var tag: String = "%s_%d" % [name, 64 if px <= 64.0 else 128]
	if not _mi.has(tag):
		var path: String = MI_DIR + tag + ".png"
		_mi[tag] = load(path) as Texture2D if ResourceLoader.exists(path) else null
	return _mi[tag]

static func reset_reads() -> void :
	_reads = {}
	_reads_done = false


static func reads() -> Dictionary:
	if reads_override != null:
		var fake: Dictionary = {}
		for key: Variant in reads_override:
			fake[str(key)] = true
		return fake
	if not _reads_done:
		_reads_done = true
		_reads = {}
		for path: String in CONSUMERS:
			if not ResourceLoader.exists(path):
				continue
			var script: Script = load(path) as Script
			if script == null:
				continue
			for key: Variant in script.get_script_constant_map().get("SETTINGS_READS", []):
				_reads[str(key)] = true
	return _reads


static func live(key: String) -> bool:
	if key in OWN:
		return true
	if key.begins_with("tc_") or key in GATED:
		return reads().has(key)
	return Settings.DEFAULTS.has(key)


static func gfx_weak() -> bool:
	if reads_override != null or not ResourceLoader.exists(TOUCH_GFX):
		return false
	var script: Script = load(TOUCH_GFX) as Script
	if script == null:
		return false
	for method: Dictionary in script.get_script_method_list():
		if str(method.get("name", "")) == "weak":
			return bool(script.call("weak"))
	return false


static func layout_editor() -> Script:
	return tool_script("open_layout_editor")


static func net_check() -> Script:
	return tool_script("open_net_check")


static func quick_chat_editor() -> Script:
	return tool_script("open_quick_chat_editor")


static func tool_script(method: String) -> Script:
	for path: String in CONSUMERS:
		if not ResourceLoader.exists(path):
			continue
		var script: Script = load(path) as Script
		if script == null:
			continue
		for entry: Dictionary in script.get_script_method_list():
			if str(entry.get("name", "")) == method:
				return script
	return null

static func preset_on(name: String) -> bool:
	var keys: Dictionary = PRESETS.get(name, {})
	var any: bool = false
	for key: String in keys:
		if live(key):
			any = true
			if Settings.value(key) != keys[key]:
				return false
	return any

static func apply_preset(name: String) -> void :
	var keys: Dictionary = PRESETS.get(name, {})
	for key: String in keys:
		if live(key):
			Settings.put(key, keys[key], false)
	Settings.save()



func shown(host: Control) -> void :
	classic = ""
	tab = "ctl"
	_scroll = {}
	if host.is_visible_in_tree():
		reset_reads()


func tabs(host: Control) -> Array[String]:
	var list: Array[String] = []
	for name: String in TABS:
		if not rows(host, name).is_empty():
			list.append(name)
	return list



func _choice(key: String, label: String, opts: Array, note: String = "") -> Dictionary:
	var items: Array = []
	for pair: Array in opts:
		items.append(["lq:set:%s:%s" % [key, str(pair[0])], str(pair[1]), Settings.value(key) == pair[0]])
	return {"t": "pick", "label": label, "items": items, "note": note, "key": key}

func _toggle(key: String, label: String, note: String = "") -> Dictionary:
	return {"t": "switch", "id": "lq:tog:" + key, "label": label, "on": Settings.on(key), "note": note, "key": key}

func _slider(key: String, label: String, note: String = "") -> Dictionary:
	return {"t": "slide", "key": key, "label": label, "note": note}


const CAST_CELLS: Array = ["Skill Thiên Phú", "Skill đặc tính", "Skill Cuối", "Skill Guild"]


func rows(host: Control, name: String) -> Array:
	var out: Array = []
	var client: Variant = host.client
	var web: bool = OS.has_feature("web")
	match name:
		"ctl":
			var any_preset: bool = PRESETS["new"].keys().any( func(key: String) -> bool: return live(key))
			if any_preset:
				out.append({"t": "sec", "label": "Kiểu điều khiển"})
				out.append({"t": "pick", "label": "Thiết lập nhanh", "note": "Đổi cùng lúc các mục bên dưới", 
					"items": [["lq:preset:new", PRESET_NAMES["new"], preset_on("new"), MI_PRESETS["new"]], ["lq:preset:pro", PRESET_NAMES["pro"], preset_on("pro"), MI_PRESETS["pro"]]]})
			out.append_array(_live([
				_choice("tc_cast", "Cách dùng chiêu", [["drag", "Kéo nhắm"], ["tap", "Chạm nhanh"]], "Áp cho các ô để \"Theo chung\" ở mục Chiêu theo từng ô"), 
				_toggle("tc_self_hold", "Giữ chiêu hỗ trợ để dùng lên mình"), 
				_toggle("tc_zone", "Vùng chiêu", "Hiện vùng trúng khi giữ / kéo chiêu; Tắt: chỉ khung chỉ hướng"), 
				_toggle("tc_pick", "Chọn mục tiêu bằng ảnh", "Giữ chiêu chọn mục tiêu: hiện ảnh xe trong tầm, kéo tới ảnh để chọn"), 
				_choice("tc_cancel", "Huỷ chiêu", [["zone", "Kéo vào ô Huỷ"], ["range", "Kéo ra ngoài vòng"]]), 
				_slider("tc_sens", "Độ nhạy kéo nhắm"), 
				_choice("tc_stick", "Cần lái", [["follow", "Theo ngón"], ["fixed", "Cố định"]]), 
				_choice("tc_aim", "Hỗ trợ ngắm", [["off", "Tắt"], ["light", "Nhẹ"], ["strong", "Mạnh"]]), 
				_choice("tc_target", "Ưu tiên mục tiêu", [["near", "Gần nhất"], ["hp", "Ít máu"], ["hp_pct", "% máu thấp"]]), 
				_choice("tc_pve", "Mục tiêu PvE", [["near", "Gần nhất"], ["boss", "Ưu tiên trùm"]]), 
				_toggle("tc_mark", "Đánh dấu mục tiêu"), 
				_toggle("tc_fire_move", "Vừa bắn vừa chạy"), 
				_toggle("tc_face_keep", "Giữ hướng nòng", "Thả tay nhắm thì nòng giữ hướng cũ; Tắt: nòng quay theo hướng đi"), 
			]))
			var cells: Array = []
			for i in range(CAST_CELLS.size()):
				cells.append(_choice("tc_cast_%d" % i, str(CAST_CELLS[i]), [["auto", "Theo chung"], ["drag", "Kéo"], ["tap", "Chạm"], ["smart", "Thông minh"]], 
					"Thông minh: chạm là tung vào địch trong tầm (theo Ưu tiên mục tiêu); kéo vẫn nhắm tay" if i == 0 else ""))
			cells = _live(cells)
			if not cells.is_empty():
				out.append({"t": "sec", "label": "Chiêu theo từng ô"})
				out.append_array(cells)
			var buttons: Array = _live([
				_slider("tc_btn_scale", "Cỡ nút"), 
				_slider("tc_btn_alpha", "Độ rõ nút"), 
				_slider("tc_pad_skill", "Cụm chiêu cách góc", "Dời cả cụm BẮN, Tự bắn và chiêu ra xa góc phải dưới; nút đã tự kéo đi theo"), 
				_slider("tc_pad_stick", "Nút di chuyển cách góc", "Dời cần di chuyển ra xa góc trái dưới; vùng chạm giãn theo"), 
				_toggle("tc_btn_fade", "Nút tự mờ", "Có xe hoặc dấu chiêu nằm dưới cụm nút thì nút mờ đi để nhìn rõ chỗ đánh"), 
				_choice("tc_layout", "Bố cục nút", [[0, "Bố cục 1"], [1, "Bố cục 2"], [2, "Bố cục 3"]]), 
			])
			if layout_editor() != null:
				buttons.append({"t": "btn", "id": "lq:layout", "label": "Tự thiết lập nút", "text": "CHỈNH", "note": "Kéo nút tới chỗ vừa tay", "icon": "layout_edit"})
			if not buttons.is_empty():
				out.append({"t": "sec", "label": "Nút cảm ứng"})
				out.append_array(buttons)
			out.append({"t": "sec", "label": "Thi triển thông minh (bàn phím)"})
			for pair: Array in host.SMART:
				var slot: int = int(pair[0])
				out.append({"t": "switch", "id": "smart:%d" % slot, "label": str(pair[1]), "on": client != null and client.smart_slot(slot), 
					"note": "Khi cắm bàn phím: bấm phím là dùng ngay vào mục tiêu gần nhất" if slot == int(host.SMART[0][0]) else ""})
			out.append({"t": "pick", "label": "Tất cả chiêu", "items": [["intelligent", "Thông minh hết", false], ["common", "Thường hết", false]]})
			out.append({"t": "btn", "id": "lq:classic:keys", "label": "Phím tắt bàn phím", "text": "MỞ", "note": "Khi cắm bàn phím / chuột"})
			out.append(_slider("cursor_size", "Cỡ chuột", "Khi cắm chuột: phóng to / thu nhỏ con trỏ"))
		"cam":
			out.append_array(_live([

				_choice("tc_pan", "Cách di chuyển camera", [["swipe", "Vuốt màn hình"], ["minimap", "Bản đồ nhỏ"]]), 
				_choice("tc_pan_dir", "Hướng di chuyển camera", [["lq", "Cùng hướng vuốt"], ["grab", "Ngược hướng vuốt"]]), 
				_choice("tc_view", "Tầm nhìn", [["near", "Gần"], ["mid", "Vừa"], ["far", "Xa"]]), 
				_choice("tc_return", "Tự động đưa camera về tank", [[100, "0,1 giây"], [500, "0,5 giây"], [1500, "1,5 giây"], [3000, "3 giây"], [0, "Tắt"]], 
					"Tính từ lúc thả tay. Tắt: chạm đúp vào sân để đưa camera về"), 
				_choice("tc_smooth", "Độ mượt camera", [["off", "Tắt"], ["low", "Nhẹ"], ["mid", "Vừa"], ["high", "Cao"]], 
					"Camera trôi theo xe mềm hơn; Tắt: dính chặt vào xe"), 
				_slider("cam_pan_speed", "Tốc độ di chuyển camera"), 
				_toggle("tc_frame", "Hiển thị khung camera trên bản đồ nhỏ"), 
				_toggle("tc_mapfollow", "Chạm bản đồ nhỏ để di chuyển camera"), 
				_toggle("tc_edge", "Camera vượt mép bản đồ", "Xe sát mép thì camera ra ngoài biên một ít để nút không che chỗ đánh"), 
			]))
			if PcMouse.app():
				out.append(_toggle(PcMouse.KEY, "Giữ chuột trong cửa sổ khi vào trận", "Lia camera sát mép không trượt sang màn hình khác"))
		"gfx":
			out.append({"t": "sec", "label": "Hình ảnh"})
			if live("tc_gfx"):
				out.append(_choice("tc_gfx", "Chất lượng hiệu ứng", [["low", "Thấp"], ["mid", "Vừa"], ["high", "Cao"]], 
					"Thấp: bớt bóng xe, khói, xác, nổ phụ, rung — đạn, đòn và vùng chiêu luôn hiện"))
			else:
				var grade: String = host._grade()
				out.append({"t": "pick", "label": "Chất lượng hiệu ứng", "note": "Thấp: tắt phim chiêu, tên chiêu", 
					"items": [["q:low", "Thấp", grade == "low"], ["q:mid", "Vừa", grade == "mid"], ["q:high", "Cao", grade == "high"]]})
			if web:
				out.append(_choice("quality", "Độ phân giải", [[0, "Tự động"], [1, "Cao"], [2, "Thấp"]], "Tự động: tự hạ độ nét khi máy chậm"))
			if live("tc_fps"):
				out.append(_choice("tc_fps", "Mức mượt (FPS)", [[30, "30"], [60, "60"], [90, "90"], [0, "Tối đa"]], 
					"Máy bạn nên chọn 30" if gfx_weak() else "30: mát máy, đỡ tốn pin; 90 / Tối đa: nóng máy, tốn pin"))
			else:
				var cap: int = int(Settings.value("fps_cap"))
				var caps: Array = [[30, "30"], [60, "60"], [0, "Tối đa"]]
				if not cap in [30, 60, 0]:
					caps.insert(2, [cap, str(cap)])
				out.append(_choice("fps_cap", "Mức mượt (FPS)", caps, "30: mát máy, đỡ tốn pin"))
			if live("tc_eco"):
				out.append(_toggle("tc_eco", "Tiết kiệm pin", "30 FPS, độ nét thấp hơn chút, bớt hiệu ứng hoà trộn — máy mát, pin lâu hơn"))
			out.append({"t": "switch", "id": "cb:fps", "label": "Hiện FPS và ping", "on": Settings.on("fps")})
			out.append(_slider("tc_bright", "Độ sáng màn hình"))
			if live("tc_outline"):
				out.append(_toggle("tc_outline", "Viền nhân vật", "Viền tối quanh xe giúp dễ nhìn"))
			if web:
				out.append({"t": "switch", "id": "full", "label": "Toàn màn hình", "on": host._full()})
			out.append({"t": "sec", "label": "Trong trận"})
			out.append({"t": "switch", "id": "cb:skill_fx", "label": "Hiệu ứng chiêu", "on": Settings.on("skill_fx"), "note": "Phim nổ, chớp nòng, rung màn"})
			out.append({"t": "switch", "id": "cb:skill_name", "label": "Tên chiêu", "on": Settings.on("skill_name")})
			out.append({"t": "switch", "id": "cb:numbers", "label": "Số sát thương", "on": Settings.on("numbers")})
		"snd":
			out.append(_slider("master_vol", "Âm lượng tổng"))
			out.append({"t": "switch", "id": "cb:music", "label": "Nhạc nền", "on": Settings.on("music")})
			out.append(_slider("music_vol", "Âm lượng nhạc"))
			out.append({"t": "switch", "id": "cb:sfx", "label": "Âm thanh hiệu ứng", "on": Settings.on("sfx")})
			out.append(_slider("sfx_vol", "Âm lượng hiệu ứng"))
			out.append({"t": "switch", "id": "cb:voice", "label": "Giọng báo hạ gục", "on": Settings.on("voice"), "note": "First Blood, Double Kill…"})
			if not (OS.has_feature("web_ios") or OS.has_feature("ios")) and live("tc_vibrate"):
				out.append(_toggle("tc_vibrate", "Rung", "Khi trúng đòn, hạ gục, chiêu hồi xong"))
			out.append({"t": "sec", "label": "Thoại", "icon": "mic"})
			if android() or OS.has_feature("ios"):
				out.append({"t": "info", "label": "Thoại trong phòng", "text": "Chưa có trên app", "note": "Dùng bản web để nói chuyện", "color": SOFT})
			else:
				var voice: Variant = VoiceClient.shared()
				var spk: String = str(voice.speaker)
				out.append({"t": "pick", "label": "Loa thoại", "items": [["lq:spk:all", "Tất cả", spk == "all"], ["lq:spk:room", "Đội", spk == "room"], 
					["lq:spk:off", "Tắt", spk == "off"]]})
				out.append(_slider("voice_play_vol", "Âm lượng nghe"))
				var mode: String = str(Settings.value("mic_mode"))
				out.append({"t": "pick", "label": "Micro", "items": [["mic:mode:off", "Tắt", mode == "off"], ["mic:mode:ptt", "Giữ để nói", mode == "ptt"], 
					["mic:mode:open", "Mở liên tục", mode == "open"]]})
				out.append({"t": "switch", "id": "mic:mute", "label": "Tắt tiếng micro", "on": Settings.on("mic_mute")})
				out.append(_slider("mic_gain", "Âm lượng micro"))
				var ns: int = int(Settings.value("mic_ns"))
				out.append({"t": "pick", "label": "Chống ồn", "items": [["mic:ns:0", "Tắt", ns == 0], ["mic:ns:1", "Cơ bản", ns == 1], ["mic:ns:2", "Nâng cao", ns == 2]]})
				out.append({"t": "switch", "id": "mic:ec", "label": "Khử tiếng vọng", "on": Settings.on("mic_ec")})
				out.append({"t": "switch", "id": "mic:agc", "label": "Tự cân âm lượng micro", "on": Settings.on("mic_agc")})
				out.append({"t": "switch", "id": "mic:auto", "label": "Ngưỡng nhận giọng tự động", "on": Settings.on("mic_gate_auto")})
				out.append(_slider("mic_gate", "Ngưỡng nhận giọng", "Mở liên tục: dưới ngưỡng thì không gửi"))
				out.append({"t": "btn", "id": "lq:classic:mic", "label": "Chọn micro, nghe thử", "text": "MỞ"})
			out.append({"t": "btn", "id": "lq:reset:sound", "label": "Âm thanh về mặc định", "text": "ĐẶT LẠI", "icon": "reset"})
		"look":
			var theme: Dictionary = LobbyThemes.current()
			var noel: bool = str(theme.get("event", "")) != "noel" or (IslandNoel.NOEL_TEST or IslandNoel.in_season(IslandNoel.now()) if IslandNoel.force_season < 0 else IslandNoel.force_season == 1)
			out.append({"t": "sec", "label": "Sảnh"})
			var style: String = LobbyBar.current()
			var bars: Array = []
			for entry: Dictionary in LobbySkins.entries():
				bars.append(["look:bar:" + str(entry["id"]), LobbySkins.name_of(entry), str(entry["id"]) == style])
			if bars.size() > 1:
				out.append({"t": "pick", "label": "Thanh nút sảnh", "items": bars})
			var themes: Array = []
			for entry: Dictionary in LobbyThemes.entries():
				themes.append(["look:theme:" + str(entry["id"]), str(entry.get("name", entry["id"])), str(entry["id"]) == str(theme.get("id", ""))])
			if themes.size() > 1:
				out.append({"t": "pick", "label": "Chủ đề sảnh", "items": themes})
			if noel and LobbyThemes.supports(theme, "day_night"):
				var dn: String = str(Settings.value("lobby_daynight"))
				out.append({"t": "pick", "label": "Ngày / đêm", "note": "Tự động theo giờ", 
					"items": [["look:dn:auto", "Tự động", dn == "auto"], ["look:dn:day", "Ngày", dn == "day"], ["look:dn:night", "Đêm", dn == "night"]]})
			if noel and LobbyThemes.supports(theme, "fx"):
				out.append({"t": "switch", "id": "look:fx", "label": "Hiệu ứng sảnh", "on": Settings.on("lobby_fx")})
			out.append({"t": "btn", "id": "lq:classic:look", "label": "Nền khung chat", "text": "CHỈNH"})
			var hud: Array = _live([
				_choice("tc_mm_side", "Bản đồ nhỏ", [["left", "Bên trái"], ["right", "Bên phải"]]), 
				_slider("tc_mm_scale", "Cỡ bản đồ nhỏ"), 
				_toggle("tc_target_info", "Thông tin mục tiêu"), 
				_toggle("tc_tips", "Gợi ý trong trận"), 
				_toggle("tc_chat", "Khung chat trong trận"), 
				_toggle("tc_ping_mute", "Hạn chế ping", "Ẩn ping và chat lẹ của người khác"), 
			])
			if live("tc_qc") and quick_chat_editor() != null:
				hud.append({"t": "btn", "id": "lq:qc", "label": "Chat lẹ", "text": "SỬA", "note": "8 câu gửi đồng đội bằng một chạm", "icon": "chat_quick"})
			if not hud.is_empty():
				out.append({"t": "sec", "label": "Trong trận"})
				out.append_array(hud)
		"misc":
			out.append({"t": "sec", "label": "Bảo mật", "icon": "tab_privacy"})
			var has: bool = client != null and bool(client.pwd_has)
			var locked: bool = has and bool(client.pwd_lock)
			out.append({"t": "btn", "id": "todo:pwd", "label": "Mật mã cấp 2", "note": "Chưa đặt" if not has else ("Đang khóa" if locked else "Đã mở khóa"), 
				"text": "ĐẶT" if not has else ("MỞ KHÓA" if locked else "KHÓA LẠI")})
			out.append({"t": "sec", "label": "Riêng tư", "icon": "tab_account"})
			out.append({"t": "switch", "id": "todo:revive", "label": "Mua hồi sinh không cần hỏi", "on": host._flag_on("revive")})
			out.append({"t": "switch", "id": "todo:fight", "label": "Chặn lời mời thi đấu từ người lạ", "on": host._flag_on("fight")})
			out.append({"t": "switch", "id": "todo:guild", "label": "Chặn lời mời vào Guild từ người lạ", "on": host._flag_on("guild"), 
				"note": "Lưu theo tài khoản"})
			out.append({"t": "sec", "label": "Mạng", "icon": "tab_network"})
			if android() and live("net_wifi_4g"):
				out.append(_toggle("net_wifi_4g", "Mạng: Wi-Fi + 4G", "Dùng dữ liệu di động khi Wi-Fi yếu/mất"))
			var ms: int = int(client.latency_ms) if client != null else -1
			if net_check() != null:
				out.append({"t": "btn", "id": "lq:netcheck", "label": "Kiểm tra mạng", "text": "KIỂM TRA", "note": net_text(ms)})
			else:
				out.append({"t": "info", "label": "Kiểm tra mạng", "text": net_text(ms), "color": net_color(ms), "note": "Đo liên tục với máy chủ"})
			out.append({"t": "sec", "label": "Khác", "icon": "tab_other"})
			out.append({"t": "btn", "id": "lq:classic:keys", "label": "Bảng cài đặt đầy đủ", "text": "MỞ", "note": "Bảng như bản máy tính"})
			out.append({"t": "btn", "id": "lq:reset_all", "label": "Khôi phục cài đặt máy", "text": "ĐẶT LẠI", "icon": "reset"})
	return out

func _live(list: Array) -> Array:
	return list.filter( func(row: Dictionary) -> bool: return live(str(row.get("key", ""))))

static func net_text(ms: int) -> String:
	if ms < 0:
		return "Đang đo…"
	return "%d ms · %s" % [ms, "Tốt" if ms < 100 else ("Khá" if ms < 200 else "Chậm")]

static func net_color(ms: int) -> Color:
	if ms < 0:
		return SOFT
	return GOOD if ms < 100 else (ACCENT if ms < 200 else BAD)

func _battle(host: Control) -> bool:
	return host.has_method("vote_state")



func _rect(x: float, y: float, w: float, h: float) -> Rect2:
	return Rect2(Vector2(x, y) * _k, Vector2(w, h) * _k)

func _text(value: String, x: float, yc: float, px: float, wide: float, color: Color = Color.WHITE, align: String = "l", font: Font = St2Skin.BOLD) -> float:
	return St2Skin.words(_host, font, value, px * _k, _rect(x, yc - px, wide, px * 2.0), color, align, Color(0, 0, 0, 0.55), maxf(1.0, 1.6 * _k)) / _k

func _box(r: Rect2, fill: Color, edge: Color, radius: float, width: float = 1.5) -> void :
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = edge
	box.set_corner_radius_all(maxi(1, roundi(radius * _k)))
	box.set_border_width_all(maxi(1, roundi(width * _k)) if edge.a > 0.0 else 0)
	box.anti_aliasing = true
	_host.draw_style_box(box, r)


func _mi_icon(name: String, x: float, y: float, side: float, tint: Color = Color.WHITE) -> bool:
	if name.is_empty():
		return false
	var r: Rect2 = _rect(x - side / 2.0, y - side / 2.0, side, side)
	var t: Texture2D = mi_tex(name, r.size.x * _host.get_global_transform_with_canvas().get_scale().x)
	if t == null:
		return false
	_host.draw_texture_rect(t, r, false, tint)
	return true

func _press(id: String, r: Rect2, radius: float) -> void :
	if _host._press == id:
		_box(r, Color(0, 0, 0, 0.25), Color(0, 0, 0, 0), radius, 0.0)

func _metrics(host: Control) -> void :
	_host = host
	_k = maxf(0.05, minf(host.size.x / 960.0, host.size.y / 540.0))
	_w = host.size.x / _k
	_h = host.size.y / _k
	_x0 = 184.0
	_x1 = _w - 12.0
	_top = 64.0

func paint(host: Control) -> void :
	_metrics(host)
	var list: Array[String] = tabs(host)
	if not tab in list:
		tab = list[0] if not list.is_empty() else "ctl"
	host.draw_rect(Rect2(Vector2.ZERO, host.size), Color(BG, 0.88 if _battle(host) else 0.97))
	host._hit("panel", Rect2(Vector2.ZERO, host.size), false)

	_view = _rect(_x0, _top, _x1 - _x0, _h - _top)
	_paint_rows(host, rows(host, tab))

	host.draw_rect(_rect(_x0 - 12.0, 0, _w, _top - 6.0), BG)
	host._hit("panel", _rect(0, 0, _w, _top - 6.0), false)
	host.draw_rect(_rect(0, 0, 172, _h), SIDE)
	host._hit("panel", _rect(0, 0, 172, _h), false)
	var title_x: float = 46.0 if _mi_icon("settings", 29, 31, 28) else 16.0
	_text("CÀI ĐẶT", title_x, 30, 22, 166.0 - title_x, ACCENT, "l", St2Skin.XBOLD)
	_paint_tabs_side(host, list)
	_text(str(TAB_NAMES.get(tab, "")), _x0 + 4.0, 32, 21, 360, Color.WHITE, "l", St2Skin.XBOLD)
	_paint_side_foot(host)

	var x: Rect2 = _rect(_w - 58.0, 8, 46, 46)
	_box(x, Color(SEG, 0.9), SEG_EDGE, 23.0, 2.0)
	St2Skin.icon(host, "close", x.get_center(), 30.0 * _k)
	_press("close", x, 23.0)
	host._hit("close", x.grow(6.0 * _k), false)

func _paint_tabs_side(host: Control, list: Array[String]) -> void :
	for i in list.size():
		var name: String = list[i]
		var r: Rect2 = _rect(8, 62.0 + 60.0 * i, 156, 52)
		var on: bool = name == tab
		if on:
			St2Skin.grad(host, r, 10.0 * _k, Color("2a7fd4"), Color("17539a"), Color("9fe2ff"), maxf(1.0, 1.5 * _k))
			host.draw_rect(_rect(8, 62.0 + 60.0 * i + 8.0, 5, 36), ACCENT)
		_press("tab:" + name, r, 10.0)
		var tint: Color = Color.WHITE if on else Color(1, 1, 1, 0.75)
		if not _mi_icon(str(MI_TABS.get(name, "")), 36, 88.0 + 60.0 * i, 32, tint):
			St2Skin.icon(host, str(TAB_ICONS[name]), (Vector2(36, 88.0 + 60.0 * i)) * _k, 30.0 * _k, tint)
		_text(str(TAB_NAMES[name]), 58, 88.0 + 60.0 * i, 15, 102, Color.WHITE if on else SOFT, "l", St2Skin.XBOLD)
		host._hit("lq:tab:" + name, r, false)


func _paint_side_foot(host: Control) -> void :
	var client: Variant = host.client
	var name: String = str(client.account.get("username", "")) if client != null else ""
	var foot: float = _h - 62.0
	_text(name, 14, foot - 34.0, 12, 146, SOFT, "l", St2Skin.SEMI)
	var plat_label: String = "App Android" if OS.has_feature("android") else ("App iOS" if OS.has_feature("ios") else ("App PC" if OS.has_feature("pc_app") or not OS.has_feature("web") else "HTML5"))
	_text(plat_label + ("" if host.BUILD == "dev" else " · %s" % host.BUILD), 14, foot - 16.0, 11, 146, SOFT, "l", St2Skin.SEMI)
	var r: Rect2 = _rect(10, foot, 152, 44)
	if _battle(host):
		_paint_vote(host, r)
	else:
		St2Skin.grad(host, r, 10.0 * _k, Color("ff6d4d"), Color("c42a17"), Color("ffc2b0"), maxf(1.0, 1.5 * _k))
		if _mi_icon("exit", 34, foot + 22.0, 26):
			_text("ĐĂNG XUẤT", 50, foot + 22.0, 15, 106, Color.WHITE, "c", St2Skin.XBOLD)
		else:
			_text("ĐĂNG XUẤT", 10, foot + 22.0, 15, 152, Color.WHITE, "c", St2Skin.XBOLD)
		_press("logout", r, 10.0)
		host._hit("logout", r, false)


func _paint_vote(host: Control, r: Rect2) -> void :
	var state: Dictionary = host.vote_state()
	if state.is_empty():
		return
	var busy: bool = bool(state.busy)
	if busy:
		_box(r, Color("4a5566"), Color(1, 1, 1, 0.2), 10.0)
	else:
		St2Skin.grad(host, r, 10.0 * _k, Color("ff6d4d"), Color("c42a17"), Color("ffc2b0"), maxf(1.0, 1.5 * _k))
	St2Skin.words(host, St2Skin.XBOLD, host.vote_text(int(state.wait)), 15.0 * _k, r.grow(-6.0 * _k), Color.WHITE if not busy else Color(1, 1, 1, 0.6), "c", 
		Color(0, 0, 0, 0.5), maxf(1.0, 1.6 * _k))
	if not busy:
		_press("vote", r, 10.0)
		host._hit("vote", r, false)

func _paint_rows(host: Control, list: Array) -> void :
	var view_h: float = _h - _top
	_content = 0.0
	for row: Dictionary in list:
		_content += _row_h(row)
	_content += 16.0
	var off: float = clampf(float(_scroll.get(tab, 0.0)), 0.0, maxf(0.0, _content - view_h))
	_scroll[tab] = off
	_y = _top - off
	for row: Dictionary in list:
		var h: float = _row_h(row)
		if _y + h > _top - 70.0 and _y < _h + 10.0:
			_paint_row(host, row, _y, h)
		_y += h
	if _content > view_h:

		var bar_h: float = maxf(30.0, view_h * view_h / _content)
		var bar_y: float = _top + (view_h - bar_h) * (off / maxf(1.0, _content - view_h))
		_box(_rect(_w - 6.0, bar_y, 3, bar_h), Color(SOFT, 0.45), Color(0, 0, 0, 0), 2.0, 0.0)

func _row_h(row: Dictionary) -> float:
	if str(row["t"]) == "sec":
		return 40.0
	return 72.0 if not str(row.get("note", "")).is_empty() else 60.0


func _row_hit(host: Control, id: String, r: Rect2) -> void :
	var cut: Rect2 = r.intersection(_view)
	if cut.has_area():
		host._hit(id, cut, false)

func _paint_row(host: Control, row: Dictionary, y: float, h: float) -> void :
	var kind: String = str(row["t"])
	if kind == "sec":
		var sec_x: float = _x0 + 32.0 if _mi_icon(str(row.get("icon", "")), _x0 + 15.0, y + 23.0, 22) else _x0 + 4.0
		_text(str(row["label"]).to_upper(), sec_x, y + 24.0, 13, 400, ACCENT, "l", St2Skin.XBOLD)
		host.draw_rect(_rect(_x0 + 4.0, y + 36.0, _x1 - _x0 - 8.0, 1), Color(ACCENT, 0.35))
		return
	var card: Rect2 = _rect(_x0, y + 4.0, _x1 - _x0, h - 8.0)
	_box(card, Color(ROW, 0.92), Color(ROW_EDGE, 0.55), 10.0)
	var mid: float = y + h / 2.0
	var note: String = str(row.get("note", ""))
	var ctrl_w: float = minf((_x1 - _x0) * 0.56, 440.0)
	var used: float = {"switch": 72.0, "btn": 132.0}.get(kind, ctrl_w)
	var label_w: float = _x1 - _x0 - used - 44.0
	if note.is_empty():
		_text(str(row["label"]), _x0 + 16.0, mid, 16, label_w, Color.WHITE, "l", St2Skin.BOLD)
	else:
		_text(str(row["label"]), _x0 + 16.0, mid - 10.0, 16, label_w, Color.WHITE, "l", St2Skin.BOLD)
		_text(note, _x0 + 16.0, mid + 14.0, 11.5, label_w, SOFT, "l", St2Skin.SEMI)
	var right: float = _x1 - 14.0
	match kind:
		"pick":
			var items: Array = row["items"]
			var n: int = maxi(1, items.size())
			var seg: float = minf(150.0 if n <= 2 else 124.0, ctrl_w / n)
			var x: float = right - seg * n
			for i in items.size():
				var item: Array = items[i]
				var r: Rect2 = _rect(x + seg * i + 2.0, mid - 20.0, seg - 4.0, 40)
				if bool(item[2]):
					St2Skin.grad(host, r, 9.0 * _k, ON_TOP, ON_LOW, Color("fff3c0"), maxf(1.0, 1.5 * _k))
				else:
					_box(r, Color(SEG, 0.95), Color(SEG_EDGE, 0.7), 9.0)
				_press(str(item[0]), r, 9.0)
				var words: Rect2 = r.grow(-6.0 * _k)
				if item.size() > 3 and _mi_icon(str(item[3]), x + seg * i + 20.0, mid, 26):
					words = words.grow_individual(-26.0 * _k, 0, 0, 0)
				St2Skin.words(host, St2Skin.XBOLD, str(item[1]), 14.0 * _k, words, Color.WHITE, "c", Color("5a2200") if bool(item[2]) else Color("08295a"), 
					maxf(1.0, 2.0 * _k))
				_row_hit(host, str(item[0]), r.grow_individual(0, 6.0 * _k, 0, 6.0 * _k))
		"switch":
			_switch(host, str(row["id"]), bool(row["on"]), right, mid)
		"slide":
			_slide_row(host, str(row["key"]), right, mid, ctrl_w)
		"btn":
			var r: Rect2 = _rect(right - 132.0, mid - 20.0, 132, 40)
			if str(row.get("kind", "")) == "red":
				St2Skin.grad(host, r, 9.0 * _k, Color("ff6d4d"), Color("c42a17"), Color("ffc2b0"), maxf(1.0, 1.5 * _k))
			else:
				St2Skin.grad(host, r, 9.0 * _k, Color("41acf5"), Color("0f4d9e"), Color("a6e6ff"), maxf(1.0, 1.5 * _k))
			_press(str(row["id"]), r, 9.0)
			var words: Rect2 = r.grow(-6.0 * _k)
			if _mi_icon(str(row.get("icon", "")), right - 113.0, mid, 24):
				words = words.grow_individual(-24.0 * _k, 0, 0, 0)
			St2Skin.words(host, St2Skin.XBOLD, str(row["text"]), 14.0 * _k, words, Color.WHITE, "c", Color("08295a"), maxf(1.0, 2.0 * _k))
			_row_hit(host, str(row["id"]), r.grow(4.0 * _k))
		"info":
			_text(str(row["text"]), right - ctrl_w, mid, 16, ctrl_w, row.get("color", Color.WHITE), "r", St2Skin.XBOLD)

func _switch(host: Control, id: String, on: bool, right: float, mid: float) -> void :
	var r: Rect2 = _rect(right - 72.0, mid - 17.0, 72, 34)
	_box(r, Color("2fae4f") if on else Color("33445e"), Color("b9f5c6") if on else Color(SEG_EDGE, 0.5), 17.0, 2.0)
	var knob: Vector2 = Vector2(right - (19.0 if on else 53.0), mid) * _k
	host.draw_circle(knob, 13.0 * _k, Color.WHITE, true, -1.0, true)
	St2Skin.words(host, St2Skin.XBOLD, "BẬT" if on else "TẮT", 10.5 * _k, _rect(right - (68.0 if on else 38.0), mid - 10.0, 34, 20), Color(1, 1, 1, 0.9), "c")
	_press(id, r, 17.0)
	_row_hit(host, id, r.grow(8.0 * _k))


func _slide_row(host: Control, key: String, right: float, mid: float, ctrl_w: float) -> void :
	var wide: float = ctrl_w - 74.0
	var track: Rect2 = _rect(right - 64.0 - wide, mid - 4.0, wide, 8)
	var share: float = clampf(float(host._share(key)), 0.0, 1.0)
	_box(track, Color("08213f"), Color(SEG_EDGE, 0.6), 4.0, 1.0)
	var fill: Rect2 = Rect2(track.position, Vector2(track.size.x * share, track.size.y))
	if fill.size.x > 1.0:
		_box(fill, ON_TOP, Color(0, 0, 0, 0), 4.0, 0.0)
	var knob: Vector2 = Vector2(track.position.x + track.size.x * share, track.get_center().y)
	host.draw_circle(knob, 14.0 * _k, Color.WHITE, true, -1.0, true)
	host.draw_circle(knob, 14.0 * _k, Color(ON_LOW, 0.9), false, maxf(1.0, 2.0 * _k), true)
	_text(str(host._level_text(key)), right - 58.0, mid, 15, 58, Color.WHITE, "r", St2Skin.XBOLD)
	var grip: Rect2 = Rect2(track.position.x, track.position.y - 20.0 * _k, track.size.x, track.size.y + 40.0 * _k)
	if not _view.has_point(Vector2(grip.get_center().x, track.get_center().y)):
		return
	host._tracks[key] = grip
	_row_hit(host, "slide:" + key, host._grip(grip))




func activate(host: Control, id: String) -> bool:
	if not classic.is_empty():
		if id == "close" or id == "ok":
			back(host)
			return true
		return false
	if not id.begins_with("lq:"):
		return false
	var rest: String = id.substr(3)
	if rest.begins_with("tab:"):
		var name: String = rest.substr(4)
		if name in TABS:
			tab = name
	elif rest.begins_with("set:"):
		var parts: PackedStringArray = rest.substr(4).split(":", true, 1)
		if parts.size() == 2 and Settings.DEFAULTS.has(parts[0]):
			var base: Variant = Settings.DEFAULTS[parts[0]]
			Settings.put(parts[0], int(parts[1]) if base is int else parts[1])
	elif rest.begins_with("tog:"):
		var key: String = rest.substr(4)
		if Settings.DEFAULTS.has(key):
			Settings.put(key, not Settings.on(key))
	elif rest.begins_with("preset:"):
		apply_preset(rest.substr(7))
	elif rest.begins_with("spk:"):
		VoiceClient.shared().set_speaker(rest.substr(4))
	elif rest.begins_with("classic:"):
		classic = rest.substr(8)
		host._set_tab(classic if classic in host.TABS else "keys")
	elif rest == "layout":
		var script: Script = layout_editor()
		if script != null:
			script.call("open_layout_editor", host)
	elif rest == "netcheck":
		var net: Script = net_check()
		if net != null:
			net.call("open_net_check", host)
	elif rest == "qc":
		var qc: Script = quick_chat_editor()
		if qc != null:
			qc.call("open_quick_chat_editor", host)
	elif rest == "reset:sound":
		host._activate("reset:sound")
		Settings.put("master_vol", Settings.DEFAULTS["master_vol"], false)
		Settings.put("tc_vibrate", Settings.DEFAULTS["tc_vibrate"])
	elif rest == "reset_all":
		host._open_ask("lq_reset", ASK_RESET)
	return true


func back(host: Control) -> void :
	if not host.missing(host._current()).is_empty():
		host._open_ask("lq_back", host.ASK_UNSET)
		return
	host._commit_keys()
	host._set_tab("keys")
	classic = ""

func drag(host: Control, moved: Vector2, from: Vector2) -> void :
	if not host._sliding.is_empty() or not host._ask.is_empty() or host._capture != 0 or _k <= 0.0:
		return
	if not _view.has_point(from):
		return
	_scroll[tab] = float(_scroll.get(tab, 0.0)) - moved.y / _k

func wheel(_host_: Control, step: int) -> void :
	_scroll[tab] = maxf(0.0, float(_scroll.get(tab, 0.0)) + 60.0 * step)
