extends "flash_screen.gd"




















const Settings = preload("res://settings.gd")
const Atlas = preload("settings_atlas.gd")
const CTip = preload("ctool_tip.gd")
const LobbyBar = preload("lobby_bar.gd")
const LobbyThemes = preload("lobby_themes.gd")
const IslandNoel = preload("island_noel.gd")
const MicEngine = preload("mic_engine.gd")
const St2Skin = preload("st2_skin.gd")
const St2Atlas = preload("st2_atlas.gd")
const PcMouse = preload("pc_mouse.gd")
const AppZoom = preload("app_zoom.gd")
const LobbySkins = preload("lobby_skins.gd")
const ChatBg = preload("chat_bg.gd")
const ChatBox = preload("chat_modern.gd")
const VoiceClient = preload("voice_client.gd")
const PcVoice = preload("res://net/pc_voice.gd")
const SettingsLq = preload("settings_lq.gd")
const SettingsLqRuntime = preload("settings_lq_runtime.gd")

signal closed
signal sign_out
signal pwd_asked(state: String)

const BUILD: String = "G6b835"
const ZOOMS: Array[float] = [1.0, 1.25, 1.5, 1.75, 2.0]
const TABS: Array[String] = ["keys", "video", "sound", "other", "look", "mic"]

const PANEL: Vector2 = Vector2(726, 500)
const TAB_AT: Vector2 = Vector2(13, 61)
const TAB_STEP: float = 57.0
const TAB_SIZE: Vector2 = Vector2(142, 46)
const TAB_ON: float = 150.0
const TAB_NAMES: Dictionary = {"keys": "THAO TÁC", "video": "ĐỒ HỌA", "sound": "ÂM THANH", "other": "KHÁC", "look": "GIAO DIỆN", "mic": "MICRO"}
const TAB_ICONS: Dictionary = {"keys": "tab_keys", "video": "tab_video", "sound": "tab_sound", "other": "tab_other", "look": "tab_look", "mic": "tab_mic"}

const PTT: int = -1
const PTT_NAME: String = "Nói (mic)"
const MIC_NS_NAMES: Array[String] = ["Tắt", "Cơ bản", "Nâng cao"]
const MIC_MODE_NAMES: Dictionary = {"off": "Tắt", "ptt": "Nhấn giữ để nói", "open": "Mở liên tục"}
const MIC_DEFAULT: String = "Mặc định của trình duyệt"

const MIC_MOVE: Array[int] = [65, 68, 83, 87, 37, 38, 39, 40]
const MIC_KEEP: Array[int] = [13, 108, 9, 27]
const MIC_NOTE_SECONDS: float = 6.0
const LOOK_DN: Array = [["auto", "Tự động"], ["day", "Ngày"], ["night", "Đêm"]]
const INK: Color = Color("eff6fd")
const DARK: Color = Color("21507f")
const RIM: Color = Color("123c6e")


const ACTION_NAMES: Array[String] = ["Skill 1", "Skill 2", "Tuyệt Chiêu", "Skill Guild", "Xạ Kích", "Tự động bắn", "Thông Tin Chiến Trường", 
	"Phun Sơn Xe", "Công", "Rút Lui", "Tập hợp", "Về thành", "Xem thuộc tính Tank"]

const ROW_NAMES: Array[String] = ["Skill 1", "Skill 2", "Tuyệt Chiêu", "Skill Guild", "Xạ Kích", "Tự động bắn", "Thông tin trận", 
	"Phun Sơn Xe", "Công", "Rút Lui", "Tập hợp", "Về thành", "Thuộc tính xe"]

const CAMERA: Array[int] = [89, 36]
const CAMERA_NAMES: Array[String] = ["Khóa cam", "Về tank"]

const SMART: Array = [[10, "Skill Thiên Phú"], [1, "Skill đặc tính"], [2, "Skill Cuối"], [4, "Skill Guild"]]
const SMART_ORDER: Array[int] = [3, 1, 0, 2]
const ALL_SMART: Array[int] = [1, 2, 3, 4, 10, 13]


const KEY_NAMES: Dictionary = {
	8: "Backspace", 9: "Tab", 13: "Enter", 16: "Shift", 17: "Ctrl", 19: "Break", 20: "Caps Lock", 27: "Esc", 32: "P. Cách", 
	33: "PageUp", 34: "PageDown", 35: "End", 36: "Home", 37: "←", 38: "↑", 39: "→", 40: "↓", 45: "Insert", 46: "Delete", 
	106: "Phím *", 107: "Phím +", 108: "Phím Enter", 109: "Phím -", 110: "Phím .", 111: "Phím /", 144: "NumLock", 145: "ScrollLock", 
	186: ";", 187: "=", 188: ",", 189: "-", 190: ".", 191: "/", 192: "`", 219: "[", 220: "\\", 221: "]", 222: "'", 
	1000: "Chuột Trái", 1001: "Chuột Phải", 1002: "Phím giữa", 
}

const FLASH_KEYS: Dictionary = {
	KEY_MINUS: 189, KEY_PERIOD: 190, KEY_APOSTROPHE: 222, KEY_COMMA: 188, KEY_SLASH: 191, KEY_SEMICOLON: 186, KEY_EQUAL: 187, 
	KEY_BRACKETLEFT: 219, KEY_BACKSLASH: 220, KEY_BRACKETRIGHT: 221, KEY_QUOTELEFT: 192, 
	KEY_BACKSPACE: 8, KEY_TAB: 9, KEY_ENTER: 13, KEY_KP_ENTER: 108, KEY_SHIFT: 16, KEY_CTRL: 17, KEY_ALT: 18, KEY_PAUSE: 19, 
	KEY_CAPSLOCK: 20, KEY_ESCAPE: 27, KEY_SPACE: 32, KEY_PAGEUP: 33, KEY_PAGEDOWN: 34, KEY_END: 35, KEY_HOME: 36, 
	KEY_LEFT: 37, KEY_UP: 38, KEY_RIGHT: 39, KEY_DOWN: 40, KEY_INSERT: 45, KEY_DELETE: 46, KEY_NUMLOCK: 144, KEY_SCROLLLOCK: 145, 
	KEY_KP_MULTIPLY: 106, KEY_KP_ADD: 107, KEY_KP_SUBTRACT: 109, KEY_KP_PERIOD: 110, KEY_KP_DIVIDE: 111, 
}


const PAN_ROW_K: float = 0.75

const TIPS: Dictionary = {
	"smart:10": ["Skill Thiên Phú", ""], 
	"smart:1": ["Skill đặc tính", ""], 
	"smart:2": ["Skill Cuối", ""], 
	"smart:4": ["Skill Guild", ""], 
	"rule": ["", "Ấn phím, đánh skill về hướng trỏ chuột"], 
	"key:89": ["", "Nhấn: khóa/bỏ khóa camera. Phím Home: về tank, giữ chế độ lia. Mở khóa: đưa chuột sát mép để lia."], 
	"key:36": ["", "Đưa camera về tank, không đổi chế độ khóa/lia."], 
	"cb:skill_fx": ["Hiệu quả", ""], 
	"cb:cursor": ["Hiệu quả chuột", ""], 
	"cursize": ["Cỡ chuột", "Phóng to / thu nhỏ con trỏ chuột (75–200 %). Mặc định 100 %. Bấm để đổi mức."], 
	"full": ["Ẩn hết", "Phủ kín màn hình. Nhấn Esc để thoát."], 
	"cb:skill_name": ["Thoại Skill", ""], 
	"cb:numbers": ["Số sát thương", "Hiện số bay lên trên xe khi mất máu hoặc hồi máu."], 
	"cb:fps": ["Hiện FPS", "Hiện số khung hình mỗi giây cạnh ping trong trận."], 
	"quality": ["Độ nét", "Cao: vẽ đủ nét theo màn hình, kể cả khi phóng to / thu nhỏ trình duyệt. Thấp: vẽ nhẹ hơn cho máy yếu (mờ hơn). Chỉ áp trong trận."], 
	"fpscap": ["Giới hạn FPS", "Trần khung hình mỗi giây của máy này. Bấm để đổi mức. Chọn thấp hơn nếu máy nóng hoặc giật; Không giới hạn = chạy hết sức máy."], 
	"slide:zoom": ["Thu phóng", "Mức phóng lúc trận bắt đầu. Trong trận vẫn lăn chuột để đổi."], 
	"slide:cam_pan_speed": ["Tốc độ lia camera", "Chỉnh nhanh hay chậm khi lia màn hình. Mặc định 70 %."], 
	"cb:pc_mouse_lock": ["Giữ chuột trong cửa sổ", "Trong trận con trỏ không ra khỏi cửa sổ game, lia camera sát mép không trượt sang màn hình khác. Alt+Tab hoặc phím Windows vẫn thả chuột ngay."], 
	"pczoom": ["Thu phóng màn hình", "Thu nhỏ để thấy rộng hơn, chữ và nút nhỏ lại; phóng to để nhìn rõ hơn. Phím tắt: Ctrl − / Ctrl + / Ctrl 0 (về 100 %), ngoài trận giữ Ctrl và lăn chuột. Lưu trên máy này."], 
	"cb:music": ["Nhạc", ""], 
	"cb:sfx": ["Âm thanh", ""], 
	"cb:voice": ["Giọng báo hạ gục", "First Blood, Double Kill, Triple Kill…"], 
	"todo:revive": ["Mua hồi sinh", ""], 
	"todo:fight": ["Chặn người lạ gửi lời mời thi đấu", ""], 
	"todo:guild": ["Chặn người lạ mời vào Guild", ""], 
	"todo:pwd": ["Mật mã cấp 2", ""], 
	"mic:ns:1": ["Chống ồn Cơ bản", "Bộ lọc ồn sẵn có của trình duyệt."], 
	"mic:ns:2": ["Chống ồn Nâng cao", "Lọc ồn mạnh (RNNoise) ngay trong trình duyệt: sạch hơn nhưng tốn CPU hơn."], 
	"mic:ec": ["Khử vọng", "Bỏ tiếng từ loa lọt ngược vào mic."], 
	"mic:agc": ["Tự cân âm lượng", "Trình duyệt tự chỉnh độ lớn giọng cho đều."], 
	"mic:auto": ["Ngưỡng tự động", "Ngưỡng tự theo mức ồn nền. Kéo thanh ngưỡng để đặt tay."], 
	"mic:monitor": ["Nghe thử", "Nghe tiếng mic đã xử lý ngay lúc nói. Đeo tai nghe để không bị hú."], 
	"mic:key": ["Phím nói", "Bấm ô rồi nhấn phím mới. Không nhận phím đang dùng trong trận."], 
	"key:ptt": ["Nói (mic)", "Giữ phím này để nói khi Chế độ mic = Nhấn giữ để nói. Không trùng phím trận."], 
	"mic:hear": ["Tắt / bật nghe", "Tắt nghe: không nghe giọng người khác. Bấm lại để nghe như trước."], 
	"slide:voice_play_vol": ["Âm lượng nghe", "Độ lớn giọng người khác trong voice, 0–200 %."], 
}



const TODO: Dictionary = {}
const PWD_TIP3: String = "Xác nhận mở bảo hộ mật mã cấp 2"


const FLAG_BITS: Dictionary = {"revive": 1, "fight": 65536, "guild": 2097152}
const ASK_UNSET: String = "Có phím chưa thiết lập, thoát chứ?"
const ASK_LOGOUT: String = "Đăng xuất khỏi tài khoản này? Bạn sẽ trở về màn đăng nhập; cài đặt trên máy này vẫn được giữ."
const NOT_READY: String = "Chưa nhận được cài đặt từ máy chủ, thử lại sau."

var _tab: String = "keys"
var _keys: Dictionary = {}
var _ctip: CTip = CTip.new()
var _ask: String = ""
var _ask_tab: String = ""
var _ask_text: String = ""
var _capture: int = 0
var _cant: String = ""
var _pending: int = 0
var _sliding: String = ""
var _tracks: Dictionary = {}
var _other: Dictionary = {}
var _mic_menu: bool = false
var _mic_key: bool = false
var _mic_note: String = ""
var _mic_note_at: float = -100.0
var _o: Vector2 = Vector2.ZERO
var _scroll: Dictionary = {"bar": 0, "theme": 0}
var _scroll_seen: Dictionary = {}
var _strips: Dictionary = {}
var _drag_acc: Dictionary = {}
var _drag_from: Vector2 = Vector2(-1, -1)
var _chat_ref: WeakRef = null
var _chat_seek: float = -100.0
var _chat_cfg: Array = ["default", "default", 1]
var _lq: SettingsLq = null


func _lq_on() -> bool:
	if not SettingsLq.wanted():
		return false
	if _lq == null:
		_lq = SettingsLq.new()
	return true


func _lq_face() -> bool:
	return _lq_on() and _lq.classic.is_empty()

func chat_busy() -> bool:
	return true

func _full() -> bool:
	return DisplayServer.window_get_mode() in [DisplayServer.WINDOW_MODE_FULLSCREEN, DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN]

func _toggle_full() -> void :

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if _full() else DisplayServer.WINDOW_MODE_FULLSCREEN)



static func _v(pair: Array) -> Vector2:
	return Vector2(float(pair[0]), float(pair[1]))


static func key_name(code: int) -> String:
	if KEY_NAMES.has(code):
		return str(KEY_NAMES[code])
	if (code >= 48 and code <= 57) or (code >= 65 and code <= 90):
		return char(code)
	if code >= 96 and code <= 105:
		return "Phím %d" % (code - 96)
	if code >= 112 and code <= 123:
		return "F%d" % (code - 111)
	return ""


static func flash_code(event: InputEventKey) -> int:
	var key: int = event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode
	if FLASH_KEYS.has(key):
		return int(FLASH_KEYS[key])
	if key >= KEY_F1 and key <= KEY_F12:
		return 112 + key - KEY_F1
	if key >= KEY_KP_0 and key <= KEY_KP_9:
		return 96 + key - KEY_KP_0
	if (key >= KEY_A and key <= KEY_Z) or (key >= KEY_0 and key <= KEY_9):
		return key
	return 0


static func can_set(code: int) -> bool:
	if code >= 65 and code <= 90:
		return not code in [65, 68, 83, 87]
	return code in [16, 17, 32, 36, 1000, 1001] or (code >= 48 and code <= 57) or (code >= 96 and code <= 105)


static func conflict(keys: Dictionary, code: int, old: int) -> int:
	for action: int in Client.KEY_DEFAULT + CAMERA:
		if action != old and int(keys.get(action, -1)) == code:
			return action
	return 0


static func sendable(keys: Dictionary) -> Dictionary:
	var out: Dictionary = {}
	for action: int in keys:
		if int(keys[action]) != 0 or action in Client.KEY_DEFAULT:
			out[action] = int(keys[action])
	return out


static func reset_keys(keys: Dictionary) -> Dictionary:
	var out: Dictionary = keys.duplicate()
	for action: int in Client.KEY_DEFAULT + CAMERA:
		out[action] = action
	return out


static func entries(keys: Dictionary) -> Array[String]:
	var out: Array[String] = []
	var kept: Dictionary = sendable(keys)
	for action: int in kept:
		if int(kept[action]) != action:
			out.append("%d-%d" % [action, int(kept[action])])
	out.sort()
	return out

static func action_name(action: int) -> String:
	var camera: int = CAMERA.find(action)
	if camera >= 0:
		return CAMERA_NAMES[camera]
	var row: int = Client.KEY_DEFAULT.find(action)
	return ACTION_NAMES[row] if row >= 0 else key_name(action)


static func missing(keys: Dictionary) -> Array[int]:
	var out: Array[int] = []
	for action: int in Client.KEY_DEFAULT:
		if int(keys.get(action, action)) == 0:
			out.append(action)
	return out


func _committed() -> Dictionary:
	var keys: Dictionary = client.key_map.duplicate() if client != null and not client.key_map.is_empty() else Client._parse_key_map([])
	for action: int in CAMERA:
		if not keys.has(action):
			keys[action] = action if conflict(keys, action, action) == 0 else 0
	return keys

func _current() -> Dictionary:
	return _keys if not _keys.is_empty() else _committed()



func _shown() -> void :
	if not _sliding.is_empty():
		_sliding = ""
		Settings.save()
	if not is_visible_in_tree() and not _keys.is_empty() and missing(_keys).is_empty():
		_commit_keys()
	_keys = {}
	_ask = ""
	_ask_tab = ""
	_ask_text = ""
	_end_capture()
	_mic_leave()
	_scroll_seen = {}
	_drag_acc = {}
	if is_visible_in_tree():
		_tab = "keys"
	if _lq_on():
		_lq.shown(self)

func _tick(_delta: float) -> void :
	if _sliding.is_empty():
		if not _held or not _ask.is_empty() or _capture != 0 or _mic_menu or _mic_key:
			return
		for key: String in _tracks:
			if _grip(_tracks[key]).has_point(_held_at):
				_sliding = key
				break
		if _sliding.is_empty():
			return
	if _held and _tracks.has(_sliding):
		_slide(_sliding, get_local_mouse_position().x, false)
	elif not _held:
		var key: String = _sliding
		_sliding = ""
		Settings.save()
		if key == "sfx_vol":
			Sound.click()


func _grip(track: Rect2) -> Rect2:
	var tall: float = maxf(0.0, (22.0 * _f - track.size.y) / 2.0)
	return track.grow_individual(8.0 * _f, tall, 8.0 * _f, tall)


func _slide(key: String, x: float, store: bool) -> void :
	if not _tracks.has(key):
		return
	var track: Rect2 = _tracks[key]
	var share: float = clampf((x - track.position.x) / maxf(1.0, track.size.x), 0.0, 1.0)
	if key == "zoom":
		Settings.put(key, ZOOMS[roundi(share * 4.0)], store)
	elif key == "cam_pan_speed":
		Settings.put(key, Settings.PAN_MIN + roundi(share * float(Settings.PAN_MAX - Settings.PAN_MIN) / 5.0) * 5, store)
	elif key == "mic_gain" or key == "voice_play_vol":
		Settings.put(key, roundi(share * 200.0), store)
	elif key == "mic_gate":
		Settings.put("mic_gate_auto", false, false)
		Settings.put(key, roundf(share * 100.0) / 100.0, store)
	elif Settings.RANGES.has(key):
		var r: Array = Settings.RANGES[key]
		Settings.put(key, float(r[0]) + share * float(int(r[1]) - int(r[0])), store)
	else:
		Settings.put(key, (1.0 + roundf(share * 99.0)) / 100.0, store)

func _share(key: String) -> float:
	var level: float = Settings.level(key)
	if key == "zoom":
		return clampf(level - 1.0, 0.0, 1.0)
	if key == "cam_pan_speed":
		return clampf((level - float(Settings.PAN_MIN)) / float(Settings.PAN_MAX - Settings.PAN_MIN), 0.0, 1.0)
	if key == "mic_gain" or key == "voice_play_vol":
		return clampf(level / 200.0, 0.0, 1.0)
	if key == "mic_gate":
		return clampf(_mic_gate_now(), 0.0, 1.0)
	if Settings.RANGES.has(key):
		var r: Array = Settings.RANGES[key]
		return clampf((level - float(r[0])) / maxf(1.0, float(int(r[1]) - int(r[0]))), 0.0, 1.0)
	return clampf((level * 100.0 - 1.0) / 99.0, 0.0, 1.0)



func _grade() -> String:
	var fx: bool = Settings.on("skill_fx")
	var words: bool = Settings.on("skill_name")
	var cursor: bool = Settings.on("cursor")
	if fx and words and cursor:
		return "high"
	return "mid" if fx or words or cursor else "low"

func _quality(grade: String) -> void :
	Settings.put("skill_fx", grade == "high", false)
	Settings.put("cursor", grade != "low", false)
	Settings.put("skill_name", grade != "low")




func _rr(x: float, y: float, w: float, h: float) -> Rect2:
	return Rect2((_o + Vector2(x, y)) * _f, Vector2(w, h) * _f)

func _pp(x: float, y: float) -> Vector2:
	return (_o + Vector2(x, y)) * _f


func _tx(value: String, x: float, yc: float, px: float, wide: float, font: Font = St2Skin.BOLD, color: Color = St2Skin.INK, align: String = "l", 
		thick: float = 2.0) -> float:
	var rim: Color = St2Skin.RIM if thick > 0.0 else Color(0, 0, 0, 0)
	return St2Skin.words(self, font, value, px * _f, _rr(x, yc - px, wide, px * 2.0), color, align, rim, thick * _f) / _f


func _icon(name: String, x: float, y: float, k: float = 1.0, tint: Color = Color.WHITE) -> Rect2:
	var reg: Array = St2Atlas.R.get("st2_" + name, [])
	if reg.is_empty():
		return Rect2(_pp(x, y), Vector2.ZERO)
	return St2Skin.icon(self, name, _pp(x, y), float(reg[3]) / St2Atlas.SCALE * _f * k, tint)


func _card(x: float, y: float, w: float, h: float, icon: String, ix: float, iy: float, title: String, tx: float) -> void :
	St2Skin.card(self, _rr(x, y, w, h), _f)
	_icon(icon, ix, iy)
	St2Skin.words(self, St2Skin.XBOLD, title, 20.0 * _f, _rr(tx, iy - 1.0 - 14.0, x + w - tx - 8.0, 28.0), Color.WHITE, "l", St2Skin.RIM, 3.0 * _f, 
		Color(0, 0.1, 0.3, 0.45))


func _btn(id: String, x: float, y: float, w: float, h: float, kind: String, value: String, px: float, live: bool = true) -> Rect2:
	var r: Rect2 = _rr(x, y, w, h)
	St2Skin.button(self, r, _f, kind if live else "gray", value, px, _shine(id) if live else 1.0, 1.0 if live else 0.75)
	if live:
		_hit(id, r, false)
	return r


func _keycell(id: String, x: float, y: float, w: float, h: float, value: String, warn: bool = false, live: bool = true) -> void :
	var r: Rect2 = _rr(x, y, w, h)
	St2Skin.keycell(self, r, _f, _hover == id and _press.is_empty(), (_capture != 0 and _capture_id() == id) or (id == "mic:key" and _mic_key), not live)
	St2Skin.words(self, St2Skin.XBOLD, value, minf(15.0, h * 0.62) * _f, r.grow_individual(-4.0 * _f, 0, -4.0 * _f, 0), St2Skin.WARN if warn else Color.WHITE, "c", 
		St2Skin.RIM, 2.0 * _f)
	if live:
		_hit(id, r, false)

func _capture_id() -> String:
	return "key:ptt" if _capture == PTT else "key:%d" % _capture


func _switch(id: String, x: float, y: float, w: float, h: float, on: bool, live: bool = true) -> void :
	var r: Rect2 = _rr(x, y, w, h)
	St2Skin.switch(self, r, _f, on, 1.0 if live else 0.4, _shine(id) if live else 1.0)
	if live:
		_hit(id, r.grow(3.0 * _f), false)


func _track(key: String, x: float, y: float, w: float, h: float, knob: float, live: bool = true) -> void :
	var r: Rect2 = _rr(x, y, w, h)
	var id: String = "slide:" + key
	St2Skin.track(self, r, _f, _share(key), knob * _f, 1.0 if live else 0.45, _shine(id) if live else 1.0)
	if not live:
		return
	_tracks[key] = r
	_hit(id, _grip(r), false)


func _level_text(key: String) -> String:
	if key == "tc_sens":
		return str(int(Settings.value(key)))
	if key in ["mic_gain", "voice_play_vol", "cam_pan_speed"] or Settings.RANGES.has(key):
		return "%d%%" % int(Settings.value(key))
	return "%d%%" % roundi(Settings.level(key) * 100.0)


func _hint(value: String, color: Color = Color.WHITE, at: Rect2 = Rect2(174, 415, 528, 26)) -> Rect2:
	var r: Rect2 = _rr(at.position.x, at.position.y, at.size.x, at.size.y)
	St2Skin.hint(self, r, _f, value, color)
	return r


func _header(icon: String, title: String, reset: String) -> void :
	_icon(icon, 202, 81)
	St2Skin.words(self, St2Skin.XBOLD, title, 28.0 * _f, _rr(230, 77 - 20, 320, 40), Color.WHITE, "l", St2Skin.RIM, 3.5 * _f, Color(0, 0.1, 0.3, 0.5))
	if reset.is_empty():
		return
	var r: Rect2 = _rr(555, 60, 145, 33)
	St2Skin.button(self, r, _f, "deep", "", 16.0, _shine(reset))
	_icon("refresh", 575, 76.5, 0.95)
	_tx("Về mặc định", 591, 76.5, 16.0, 104, St2Skin.XBOLD, Color.WHITE, "c", 2.5)
	_hit(reset, r, false)

func _paint() -> void :
	_tracks = {}
	if _lq_face():
		_o = _centre(PANEL.x, PANEL.y)
		_lq.paint(self)
		if _capture != 0:
			_paint_capture()
		if not _ask.is_empty():
			_paint_ask()
		return
	_scene()
	if not overlay:
		draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	_o = _centre(PANEL.x, PANEL.y)
	_hit("panel", _rr(0, 0, PANEL.x, PANEL.y), false)
	St2Skin.frame(self, _rr(0, 0, 720, 500), _rr(4, 38, 711, 405), _f)
	St2Skin.content(self, _rr(167, 51, 543, 392), _f)
	St2Skin.title(self, _rr(264, 6, 194, 32), _f, "CÀI ĐẶT")
	var x: Rect2 = _icon("close", 699, 17, 30.0 / maxf(1.0, float(St2Atlas.R.get("st2_close", [0, 0, 0, 59])[3]) / St2Atlas.SCALE), _glow("close"))
	_hit("close", x.grow(2.0 * _f), false)
	_paint_tabs()
	_paint_footer()
	_paint_vote(_o)
	match _tab:
		"keys":
			_paint_keys(_o)
		"video":
			_paint_video(_o)
		"sound":
			_paint_sound(_o)
		"look":
			_paint_look(_o)
		"mic":
			_paint_mic(_o)
		_:
			_paint_other(_o)
	if _capture != 0:
		_paint_capture()
	if not _ask.is_empty():
		_paint_ask()
	elif _capture == 0 and _sliding.is_empty():
		_paint_tip()


func _paint_tabs() -> void :
	for i in TABS.size():
		var tab: String = TABS[i]
		var on: bool = tab == _tab
		var id: String = "tab:" + tab
		var y: float = TAB_AT.y + TAB_STEP * i
		var r: Rect2 = _rr(TAB_AT.x, y, TAB_ON if on else TAB_SIZE.x, TAB_SIZE.y)
		St2Skin.tab(self, r, _f, on, _shine(id))
		_icon(str(TAB_ICONS[tab]), 41, y + 23.0)
		St2Skin.words(self, St2Skin.XBOLD, str(TAB_NAMES[tab]), 17.0 * _f, _rr(70, y + 23.0 - 17.0, 78, 34), Color.WHITE, "l", 
			Color("8a3300") if on else St2Skin.RIM, 3.0 * _f, Color(0, 0, 0, 0.3))
		_hit(id, _rr(TAB_AT.x, y, TAB_SIZE.x, TAB_SIZE.y), false)


func _paint_footer() -> void :
	_icon("user", 25.5, 472.5)
	var name: String = str(client.account.get("username", "")) if client != null else ""
	_tx("Tài khoản: %s" % name, 49, 463.5, 13.0, 260, St2Skin.BOLD, St2Skin.ACCOUNT, "l", 0.0)
	var plat_label: String = "App Android (thử nghiệm)" if OS.has_feature("android") else ("App iOS (thử nghiệm)" if OS.has_feature("ios") else ("App PC (thử nghiệm)" if OS.has_feature("pc_app") or not OS.has_feature("web") else "HTML5 (thử nghiệm)"))
	_tx(plat_label + ("" if BUILD == "dev" else " • %s" % BUILD), 49, 480, 13.0, 260, St2Skin.BOLD, St2Skin.ACCOUNT, "l", 0.0)


func _paint_vote(_base: Vector2) -> void :
	_btn("logout", 570, 453, 135, 37, "red", "ĐĂNG XUẤT", 17.0)


func _paint_keys(_base: Vector2) -> void :
	_header("hdr_keys", "THIẾT LẬP PHÍM", "reset:keys")
	var keys: Dictionary = _current()
	_card(175, 101, 300, 297, "card_battle", 201, 122, "CHIẾN ĐẤU", 226)
	St2Skin.block(self, _rr(182, 142, 285, 184), _f)
	for i in 6:
		var yc: float = 158.5 + 30.3 * i
		if i > 0:
			St2Skin.sep(self, _pp(188, 0).x, _pp(461, 0).x, _pp(0, yc - 15.15).y, _f)
		var action: int = Client.KEY_DEFAULT[i]
		_tx(ROW_NAMES[i], 192.5, yc, 15.0, 92)
		_keycell("key:%d" % action, 287, yc - 12.5, 102.0 if i >= 4 else 62.0, 25, key_name(int(keys.get(action, 0))))
	for index: int in SMART_ORDER:
		var slot: int = int(SMART[index][0])
		var id: String = "smart:%d" % slot
		var yc: float = 158.5 + 30.3 * index
		St2Skin.switch(self, _rr(353, yc - 10.5, 39, 21), _f, client != null and client.smart_slot(slot), 1.0, _shine(id))
		_tx("Thông minh", 396, yc, 12.0, 70, St2Skin.SEMI)
		_hit(id, _rr(351, yc - 13.0, 116, 26), false)
	_btn("common", 189, 332, 272, 28, "blue", "Thi triển thường hết", 16.0)
	_btn("intelligent", 189, 365, 272, 28, "blue", "Thi triển thông minh hết", 16.0)
	_card(484, 101, 218, 297, "card_util", 514, 122, "TIỆN ÍCH", 538)
	St2Skin.block(self, _rr(492, 142, 203, 249), _f)
	var rows: Array = []
	for i in range(6, Client.KEY_DEFAULT.size()):
		var action: int = Client.KEY_DEFAULT[i]
		rows.append(["key:%d" % action, ROW_NAMES[i], key_name(int(keys.get(action, 0))), false])
	for i in CAMERA.size():
		var code: int = int(keys.get(CAMERA[i], 0))
		rows.append(["key:%d" % CAMERA[i], CAMERA_NAMES[i], key_name(code) if code != 0 else "--", false])
	if not _mobile:
		var ptt: int = int(Settings.value("mic_ptt_key"))
		rows.append(["key:ptt", PTT_NAME, ptt_name(ptt), not ptt_block(ptt_flash(ptt), keys).is_empty()])
	var step: float = 24.7 if rows.size() > 9 else 27.0
	for i in rows.size():
		var yc: float = 156.5 + step * i
		if i > 0:
			St2Skin.sep(self, _pp(498, 0).x, _pp(689, 0).x, _pp(0, yc - step / 2.0).y, _f)
		_tx(str(rows[i][1]), 504, yc, 15.0, 107)
		_keycell(str(rows[i][0]), 614, yc - 10.5, 73, 21, str(rows[i][2]), bool(rows[i][3]))
	var unset: bool = not missing(keys).is_empty()
	var text: String = "Có phím chưa thiết lập • Bấm ô phím rồi nhấn phím mới" if unset else "Bấm ô phím rồi nhấn phím mới • Ấn phím, đánh skill về hướng trỏ chuột"
	_hit("rule", _hint(text, St2Skin.BAD if unset else Color.WHITE), false)


func _paint_video(_base: Vector2) -> void :
	_header("hdr_video", "ĐỒ HỌA", "reset:video")
	_card(175, 100, 527, 103, "card_gear", 200, 117.5, "CHẤT LƯỢNG", 222)
	var grade: String = _grade()
	for q: Array in [["low", 185.0, 165.0, "Thấp"], ["mid", 357.0, 159.0, "Vừa"], ["high", 523.0, 166.0, "Cao"]]:
		_btn("q:" + str(q[0]), float(q[1]), 137, float(q[2]), 34, "orange" if grade == str(q[0]) else "blue", str(q[3]), 20.0)
	St2Skin.big_arrow(self, _pp(185, 187.5), _f, true, Color("52b8ff"))
	_tx("Tăng độ mượt", 216, 187.5, 14.0, 84, St2Skin.BOLD)
	var bar: Rect2 = _rr(302, 183.5, 268, 8)
	var pts: PackedVector2Array = PackedVector2Array()
	var cols: PackedColorArray = PackedColorArray()
	var stops: Array = [Color("2fd2ff"), Color("4ef0c0"), Color("d8f040"), Color("ffb21e")]
	for i in stops.size():
		pts.append(Vector2(lerpf(bar.position.x, bar.end.x, float(i) / (stops.size() - 1)), bar.position.y))
		cols.append(stops[i])
	for i in range(stops.size() - 1, -1, -1):
		pts.append(Vector2(lerpf(bar.position.x, bar.end.x, float(i) / (stops.size() - 1)), bar.end.y))
		cols.append(stops[i])
	draw_polygon(pts, cols)
	_tx("Tăng phẩm chất", 572, 187.5, 14.0, 88, St2Skin.BOLD, Color.WHITE, "r")
	St2Skin.big_arrow(self, _pp(690, 187.5), _f, false, Color("ffb21e"))

	_card(175, 211, 236, 190, "card_display", 202, 228.5, "HIỂN THỊ", 226)
	St2Skin.block(self, _rr(182, 243, 222, 153), _f)
	var shows: Array = [["cb:cursor", "Hiệu quả chuột", Settings.on("cursor")], ["full", "Toàn màn hình", _full()], 
		["cb:skill_fx", "Hiệu quả skill", Settings.on("skill_fx")], ["cb:skill_name", "Thoại skill", Settings.on("skill_name")], 
		["cb:numbers", "Số sát thương", Settings.on("numbers")], ["cb:fps", "Hiện FPS", Settings.on("fps")]]
	for i in shows.size():
		var yc: float = 257.0 + 25.3 * i
		if i > 0:
			St2Skin.sep(self, _pp(188, 0).x, _pp(398, 0).x, _pp(0, yc - 12.65).y, _f)
		_tx(str(shows[i][1]), 194, yc, 15.0, 122)
		_switch(str(shows[i][0]), 321, yc - 11.0, 42, 22, bool(shows[i][2]))

	_card(420, 211, 282, 91, "card_perf", 445, 224.5, "HIỆU NĂNG", 470)
	_tx("Độ nét", 435, 252.5, 15.0, 88)
	_cycler("quality", 527, 240, quality_text(int(Settings.value("quality")), Settings.drop))
	_tx("Giới hạn FPS", 435, 285, 15.0, 88)
	_cycler("fpscap", 527, 272, cap_text(int(Settings.value("fps_cap"))))

	_card(420, 308, 282, 104, "card_camera", 446.5, 322, "CAMERA", 471)
	_tx("Thu phóng", 435, 342.5, 13.0, 150)
	_track("zoom", 435, 353, 187, 9, 20.0)
	_tx("100%", 435, 369.5, 11.0, 40, St2Skin.BOLD)
	_tx("200%", 582, 369.5, 11.0, 40, St2Skin.BOLD, Color.WHITE, "r")
	St2Skin.numbox(self, _rr(631, 345, 58, 24), _f, _level_text("zoom"), 15.0)
	_tx("Tốc độ lia camera", 435, 383.5, 13.0, 150)
	_track("cam_pan_speed", 435, 394, 187, 9, 20.0)
	_tx("%d%%" % Settings.PAN_MIN, 435, 410, 11.0, 40, St2Skin.BOLD)
	_tx("%d%%" % Settings.PAN_MAX, 582, 410, 11.0, 40, St2Skin.BOLD, Color.WHITE, "r")
	St2Skin.numbox(self, _rr(631, 386, 58, 24), _f, _level_text("cam_pan_speed"), 15.0)

	_hint("")
	_tx("Cỡ chuột", 214, 428, 13.0, 66, St2Skin.SEMI, Color.WHITE)
	_cycler("cursize", 284, 415, "%d %%" % int(Settings.value("cursor_size")), 116.0)
	if PcMouse.app():
		_tx("Giữ chuột trong cửa sổ khi vào trận", 414, 428, 13.0, 230, St2Skin.SEMI, Color.WHITE)
		_switch("cb:" + PcMouse.KEY, 652, 417, 42, 22, Settings.on(PcMouse.KEY))


func _cycler(id: String, x: float, y: float, value: String, w: float = 160.0) -> void :
	var r: Rect2 = _rr(x, y, w, 26)
	St2Skin.grad(self, r, 5.0 * _f, Color("06306e"), Color("042559"), Color("2f88da"), maxf(1.0, 1.2 * _f))
	_hit(id, r, false)
	for side: int in [0, 1]:
		var hid: String = id + (":prev" if side == 0 else "")
		var b: Rect2 = _rr(x + 2.0 + (w - 28.0) * side, y + 2.0, 24, 22)
		var lit: float = _shine(hid) if side == 0 else _shine(id)
		St2Skin.grad(self, b, 4.0 * _f, St2Skin._lit(Color("1a74d6"), lit), St2Skin._lit(Color("0b4fa8"), lit), Color("5fb4ff", 0.8), maxf(1.0, _f))
		var c: Vector2 = b.get_center()
		var s: float = -1.0 if side == 0 else 1.0
		draw_colored_polygon(PackedVector2Array([c + Vector2(s * 5.0, 0) * _f, c + Vector2( - s * 4.0, -6.0) * _f, c + Vector2( - s * 4.0, 6.0) * _f]), Color.WHITE)
		if side == 0:
			_hit(hid, b, false)
	_tx(value, x + 28.0, y + 13.0, 14.0, w - 56.0, St2Skin.SEMI, Color.WHITE, "c")


static func cap_text(cap: int) -> String:
	return "Không giới hạn" if cap <= 0 else str(cap)


static func quality_text(quality: int, now: int) -> String:
	match quality:
		1:
			return "Cao"
		2:
			return "Thấp"
	return "Tự động" + (" (Vừa)" if now == 1 else " (Thấp)" if now >= 2 else "")


static func prev_of(next: Callable, value: int) -> int:
	var v: int = value
	for i in 16:
		var n: int = int(next.call(v))
		if n == value:
			return v
		v = n
	return value


func _paint_sound(_base: Vector2) -> void :
	_header("hdr_sound", "ÂM THANH", "reset:sound")
	_card(175, 108, 527, 150, "card_volume", 205, 133.5, "ÂM LƯỢNG", 237.5)
	St2Skin.block(self, _rr(182, 155, 513, 97), _f)
	for row: Array in [["music", "Nhạc nền", 179.0], ["sfx", "Âm hiệu", 226.0]]:
		var key: String = str(row[0])
		var yc: float = float(row[2])
		_tx(str(row[1]), 194, yc, 16.0, 104)
		_switch("cb:" + key, 303, yc - 13.0, 49, 26, Settings.on(key))
		_track(key + "_vol", 373.5, yc - 6.5, 232.5, 13, 28.0)
		St2Skin.numbox(self, _rr(616.5, yc - 16.5, 72.5, 32.5), _f, _level_text(key + "_vol"), 17.0)
	St2Skin.sep(self, _pp(188, 0).x, _pp(689, 0).x, _pp(0, 202.5).y, _f)
	_card(175, 270, 527, 123, "card_announce", 210, 295, "GIỌNG BÁO", 250)
	St2Skin.block(self, _rr(182, 316, 513, 71), _f)
	var live: bool = Settings.on("sfx")
	_tx("Giọng báo hạ gục", 194, 341, 16.0, 140, St2Skin.BOLD, Color(1, 1, 1, 1.0 if live else 0.5))
	_switch("cb:voice", 339, 328, 52, 27, Settings.on("voice") and live, live)
	_tx("First Blood, Double Kill, Triple Kill...", 194, 368, 13.0, 300, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)
	_hint("Tắt Âm hiệu thì giọng báo cũng tắt.")


func _paint_other(_base: Vector2) -> void :
	_header("hdr_other", "KHÁC", "")
	_card(175, 108, 527, 112, "card_lock", 205, 131, "BẢO MẬT", 238.5)
	St2Skin.block(self, _rr(182, 155, 513, 59), _f)
	_tx("Mật mã cấp 2", 191.5, 174.5, 18.0, 240)
	var has: bool = client != null and bool(client.pwd_has)
	var locked: bool = has and bool(client.pwd_lock)
	_tx("Chưa đặt" if not has else ("Đang khóa" if locked else "Đã mở khóa"), 191.5, 198.5, 14.0, 240, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)
	var r: Rect2 = _rr(543, 163, 142, 42)
	St2Skin.button(self, r, _f, "blue", "", 16.0, _shine("todo:pwd"))
	_icon("lock_small", 568.5, 184.5, 0.9)
	_tx("Đặt mật mã" if not has else ("Mở khóa" if locked else "Khóa lại"), 584, 184.5, 16.0, 96, St2Skin.XBOLD, Color.WHITE, "c", 2.5)
	_hit("todo:pwd", r, false)
	_card(175, 231, 527, 171, "card_gear", 209, 253, "TUỲ CHỌN", 240)
	St2Skin.block(self, _rr(182, 274, 513, 122), _f)
	var rows: Array = [["revive", "Mua hồi sinh không cần hỏi", 296.0], ["fight", "Chặn lời mời thi đấu từ người lạ", 337.5], 
		["guild", "Chặn lời mời vào Guild từ người lạ", 378.5]]
	for i in rows.size():
		var box: String = str(rows[i][0])
		var yc: float = float(rows[i][2])
		if i > 0:
			St2Skin.sep(self, _pp(188, 0).x, _pp(689, 0).x, _pp(0, yc - 20.5).y, _f)
		_other[box] = _flag_on(box)
		_tx(str(rows[i][1]), 194, yc, 16.0, 420)
		_switch("todo:" + box, 630, yc - 13.5, 51, 27, bool(_other[box]))
	if AppZoom.active():
		_hint("Thu phóng màn hình (lưu trên máy này)")
		_cycler("pczoom", 534, 415, "%d %%" % AppZoom.level())
	else:
		_hint("Các tuỳ chọn này lưu theo tài khoản.")



func _paint_look(_base: Vector2) -> void :
	_header("tab_look", "GIAO DIỆN", "")
	var theme: Dictionary = LobbyThemes.current()

	_strips = {}
	St2Skin.card(self, _rr(173.5, 94.5, 327.5, 124), _f)
	_tx("THANH NÚT SẢNH", 186, 107, 18.0, 220, St2Skin.XBOLD, Color.WHITE, "l", 3.0)
	var bars: Array = LobbySkins.entries()
	var style: String = LobbyBar.current()
	_strip("bar", bars, 2, Rect2(173.5, 94.5, 327.5, 124), 187.5, 491.0, bars.map( func(entry: Dictionary) -> bool: return str(entry["id"]) == style))
	for i in range(_scroll_at("bar", bars.size(), 2), mini(bars.size(), _scroll_at("bar", bars.size(), 2) + 2)):
		var entry: Dictionary = bars[i]
		var key: String = str(entry["id"])
		var x: float = 202.5 + 141.0 * (i - _scroll_at("bar", bars.size(), 2))
		var shot: Rect2 = _look_card("look:bar:" + key, x, 134.0, key == style)
		LobbyBar.preview(self, shot, key)
		if key == style:
			St2Skin.badge(self, _rr(x + 134.0 - 66.0, 171, 62, 14), _f, "ĐANG DÙNG", Color("ffb21e"), Color("ff7a00"))
		_tx(LobbySkins.name_of(entry), x + 6.0, 193.5, 14.0, 122)
		_tx(LobbySkins.note_of(entry), x + 6.0, 207, 11.0, 122, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)

	St2Skin.card(self, _rr(507.5, 94.5, 196.5, 124), _f)
	_tx("CHỦ ĐỀ SẢNH", 518.5, 107, 18.0, 170, St2Skin.XBOLD, Color.WHITE, "l", 3.0)
	var themes: Array = LobbyThemes.entries()
	var chosen: String = str(theme.get("id", ""))
	_strip("theme", themes, 1, Rect2(507.5, 94.5, 196.5, 124), 521.0, 691.0, themes.map( func(entry: Dictionary) -> bool: return str(entry["id"]) == chosen))
	var first: int = _scroll_at("theme", themes.size(), 1)
	for i in range(first, mini(themes.size(), first + 1)):
		var entry: Dictionary = themes[i]
		var id: String = str(entry["id"])
		var shot: Rect2 = _look_card("look:theme:" + id, 535, 142.5, id == chosen)
		draw_rect(shot, Color("0b2a52"))
		for file: Variant in entry.get("preview", []):
			var tex: Texture2D = pack.picture(str(file)) if pack != null else null
			if tex != null:
				draw_texture_rect_region(tex, shot, _cover(shot.size, tex.get_size()))
		_look_edge(shot, id == chosen)
		if id == chosen:
			St2Skin.badge(self, _rr(535 + 142.5 - 66.0, 171, 62, 14), _f, "ĐANG DÙNG", Color("ffb21e"), Color("ff7a00"))
		_tx(str(entry.get("name", id)), 541, 193.5, 14.0, 130)
		_tx(str(entry.get("note", "")), 541, 207, 11.0, 130, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)
	var top: float = 225.0
	if _paint_hall(_o, theme):
		top = 322.0
	_paint_chat_bg(top)
	if top > 225.0:
		_hint("Lưu trên máy này, đổi ngay không cần tải lại.", Color.WHITE, Rect2(174, 428, 528, 17))
	else:
		_hint("Lưu trên máy này, đổi ngay không cần tải lại.")


func _look_card(id: String, x: float, w: float, on: bool) -> Rect2:
	var card: Rect2 = _rr(x, 117.5, w, 98.5)
	var hot: bool = _hover == id and _press.is_empty()
	St2Skin.grad(self, card, 7.0 * _f, Color("0d5cb2", 0.9), Color("0a4a96", 0.9), Color("9fe2ff") if hot else Color("63c6ff", 0.55), maxf(1.0, _f))
	_hit(id, card, false)
	var shot: Rect2 = _rr(x + 1.5, 119.5, w - 3.0, 65.5)
	return shot


func _look_edge(shot: Rect2, on: bool) -> void :
	St2Skin.grad(self, shot, 6.0 * _f, Color(0, 0, 0, 0), Color(0, 0, 0, 0), Color("ffb21e") if on else Color("bfe8ff", 0.6), maxf(1.0, (2.5 if on else 1.0) * _f))


func _scroll_at(strip: String, count: int, shown: int) -> int:
	return clampi(int(_scroll.get(strip, 0)), 0, maxi(0, count - shown))


func _strip(strip: String, list: Array, shown: int, area: Rect2, left: float, right: float, chosen: Array) -> void :
	if not _scroll_seen.has(strip):
		_scroll_seen[strip] = true
		var at: int = chosen.find(true)
		if at >= 0:
			_scroll[strip] = clampi(at - shown + 1, 0, maxi(0, list.size() - shown)) if at >= shown else 0
	var first: int = _scroll_at(strip, list.size(), shown)
	_scroll[strip] = first
	_strips[strip] = [_rr(area.position.x, area.position.y, area.size.x, area.size.y), list.size(), shown]
	var can_left: bool = first > 0
	var can_right: bool = first + shown < list.size()
	for side: int in [0, 1]:
		var id: String = "look:%s:%s" % ["prev" if side == 0 else "next", strip]
		var live: bool = can_left if side == 0 else can_right
		var x: float = left if side == 0 else right
		St2Skin.arrow(self, _pp(x, 157), 23.0 * _f, side == 0, live, _shine(id) if live else 1.0)
		if live:
			_hit(id, _rr(x - 13.0, 144, 26, 26), false)
	if list.size() > shown:
		var pages: int = list.size() - shown + 1
		var x0: float = area.end.x - 14.0 - 9.0 * (pages - 1)
		for i in pages:
			draw_circle(_pp(x0 + 9.0 * i, 107), (3.0 if i == first else 2.2) * _f, Color("ffb21e") if i == first else Color(1, 1, 1, 0.55))



func _paint_hall(_base: Vector2, theme: Dictionary) -> bool:
	var day_night: bool = LobbyThemes.supports(theme, "day_night")
	var fx: bool = LobbyThemes.supports(theme, "fx")
	var noel: bool = str(theme.get("event", "")) != "noel" or (IslandNoel.NOEL_TEST or IslandNoel.in_season(IslandNoel.now()) if IslandNoel.force_season < 0 else IslandNoel.force_season == 1)
	if not noel or ( not day_night and not fx):
		return false
	St2Skin.card(self, _rr(173.5, 225, 530.5, 91), _f)
	_icon("card_gear", 196.5, 236.5, 0.72)
	var w: float = _tx("SẢNH", 212, 236.5, 18.0, 60, St2Skin.XBOLD, Color.WHITE, "l", 3.0)
	St2Skin.badge(self, _rr(212.0 + w + 8.0, 228.5, 38.5, 16), _f, "MỚI", Color("ffe14a"), Color("ffb800"), Color("a01000"), Color(0, 0, 0, 0))
	if day_night:
		_tx("Ngày / đêm", 186, 260, 15.0, 140)
		_tx("Tự động theo giờ", 186, 275, 11.0, 140, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)
		var mode: String = str(Settings.value("lobby_daynight"))
		var xs: Array = [336.5, 456.0, 575.0]
		for i in LOOK_DN.size():
			var key: String = str(LOOK_DN[i][0])
			_btn("look:dn:" + key, float(xs[i]), 252, 113, 24, "orange" if mode == key else "blue", str(LOOK_DN[i][1]), 15.0)
	if fx:
		_tx("Hiệu ứng sảnh", 186, 297.5, 15.0, 140)
		if IslandNoel.low() and not str(theme.get("low_note", "")).is_empty():
			_tx(str(theme["low_note"]), 300, 297.5, 11.0, 322, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)
		_switch("look:fx", 630, 285.5, 56.5, 24, Settings.on("lobby_fx"))
	return true


func _paint_chat_bg(top: float) -> void :
	St2Skin.card(self, _rr(173.5, top, 530.5, 104), _f)
	_icon("card_chat", 197.5, top + 11.5, 0.85)
	_tx("NỀN CHAT", 218.5, top + 11.5, 18.0, 200, St2Skin.XBOLD, Color.WHITE, "l", 3.0)
	var state: Array = _chat_state()
	for row: Array in [["bgh", "Khi rê chuột", 37.0, true], ["bgi", "Khi ẩn", 65.5, false]]:
		var yc: float = top + float(row[2])
		_tx(str(row[1]), 186, yc, 15.0, 120)
		var keys: Array = ChatBg.keys(bool(row[3]))
		var now: String = str(state[0] if bool(row[3]) else state[1])
		for i in keys.size():
			var id: String = "look:%s:%s" % [row[0], keys[i]]
			_swatch(str(keys[i]), _pp(315.0 + 41.5 * i, yc), id, now == str(keys[i]))
	var yc: float = top + 93.0
	_tx("Độ đậm", 186, yc, 15.0, 100)
	var xs: Array = [299.0, 379.0, 460.0]
	for i in ChatBg.STRENGTHS.size():
		_btn("look:bga:%d" % i, float(xs[i]), yc - 10.0, 75, 20, "orange" if int(state[2]) == i else "blue", str(ChatBg.STRENGTHS[i]), 13.0)
	_btn("look:bgreset", 621.5, yc - 10.0, 74.5, 20, "blue", "Mặc định", 13.0)


func _swatch(key: String, c: Vector2, id: String, on: bool) -> void :
	var d: float = 24.0 * _f
	St2Skin.swatch(self, c, d, _f, ChatBg.swatch(key), on, _hover == id and _press.is_empty(), key == "clear")
	var r: float = d / 2.0 - 1.0 * _f
	if key == "default":
		draw_circle(c, r, Color("0a1729"))
		var half: PackedVector2Array = PackedVector2Array()
		for k in range(17):
			half.append(c + Vector2.from_angle(PI * 0.75 + PI * k / 16.0) * r)
		draw_colored_polygon(half, Color.BLACK)
	elif key == "clear":
		draw_line(c + Vector2(-0.7, 0.7) * r, c + Vector2(0.7, -0.7) * r, Color("e0464b"), 2.0 * _f, true)
	_hit(id, Rect2(c - Vector2(d, d) * 0.62, Vector2(d, d) * 1.24), false)


static func _cover(box: Vector2, dim: Vector2) -> Rect2:
	if dim.x <= 0.0 or dim.y <= 0.0 or box.x <= 0.0 or box.y <= 0.0:
		return Rect2(Vector2.ZERO, dim)
	var k: float = minf(dim.x / box.x, dim.y / box.y)
	var take: Vector2 = box * k
	return Rect2((dim - take) / 2.0, take)




func _chat_box() -> Node:
	var node: Object = _chat_ref.get_ref() if _chat_ref != null else null
	if node != null and is_instance_valid(node):
		return node as Node
	if not is_inside_tree() or _time - _chat_seek < 1.0:
		return null
	_chat_seek = _time
	for n: Node in get_tree().root.find_children("*", "", true, false):
		if n != self and n.has_method("_bg_act") and "bg_hover" in n:
			_chat_ref = weakref(n)
			return n
	return null


func _chat_state() -> Array:
	var box: Node = _chat_box()
	if box != null:
		return [str(box.bg_hover), str(box.bg_idle), int(box.bg_alpha)]
	return _chat_cfg


func _chat_load() -> void :
	_chat_cfg = ["default", "default", ChatBg.DEFAULT_ALPHA]
	if not ChatBox.store:
		return
	var cfg: ConfigFile = ConfigFile.new()
	if cfg.load(ChatBox.CONFIG) != OK:
		return
	_chat_cfg = [ChatBg.sane(cfg.get_value("chat", "bg_hover", "default"), true), ChatBg.sane(cfg.get_value("chat", "bg_idle", "default"), false), 
		ChatBg.sane_alpha(cfg.get_value("chat", "bg_alpha", ChatBg.DEFAULT_ALPHA))]



func _chat_act(id: String) -> void :
	var box: Node = _chat_box()
	if box != null:
		box._bg_act(id)
		return
	if id.begins_with("bgh:"):
		_chat_cfg[0] = ChatBg.sane(id.substr(4), true)
	elif id.begins_with("bgi:"):
		_chat_cfg[1] = ChatBg.sane(id.substr(4), false)
	elif id.begins_with("bga:"):
		_chat_cfg[2] = ChatBg.sane_alpha(int(id.substr(4)))
	elif id == "bgreset":
		_chat_cfg = ["default", "default", ChatBg.DEFAULT_ALPHA]
	else:
		return
	if not ChatBox.store:
		return
	var cfg: ConfigFile = ConfigFile.new()
	cfg.load(ChatBox.CONFIG)
	cfg.set_value("chat", "bg_hover", _chat_cfg[0])
	cfg.set_value("chat", "bg_idle", _chat_cfg[1])
	cfg.set_value("chat", "bg_alpha", _chat_cfg[2])
	cfg.save(ChatBox.CONFIG)



func _wheel(step: int, _at: Vector2) -> void :
	if _lq_face() and _ask.is_empty():
		_lq.wheel(self, step)

func _drag(moved: Vector2, from: Vector2) -> void :
	if _lq_face():
		_lq.drag(self, moved, from)
		return
	if _tab != "look" or not _ask.is_empty() or _capture != 0 or not _sliding.is_empty():
		return
	if from != _drag_from:
		_drag_from = from
		_drag_acc = {}
	for strip: String in _strips:
		var info: Array = _strips[strip]
		if not (info[0] as Rect2).has_point(from):
			continue
		var acc: float = float(_drag_acc.get(strip, 0.0)) + moved.x
		var step: float = 60.0 * _f
		while absf(acc) >= step:
			var dir: int = -1 if acc > 0.0 else 1
			_scroll[strip] = clampi(int(_scroll.get(strip, 0)) + dir, 0, maxi(0, int(info[1]) - int(info[2])))
			acc -= step * signf(acc)
		_drag_acc[strip] = acc
		return




func _mic() -> Variant:
	var mic: Variant = MicEngine.shared()
	if not mic.error.is_connected(_mic_error):
		mic.error.connect(_mic_error)
	return mic

func _mic_error(code: String) -> void :
	var text: String = MicEngine.error_text(code)
	if code == "deny" and PcVoice.is_pc():
		text = MIC_PC_DENY
	if not text.is_empty():
		_mic_say(text)

func _mic_say(text: String) -> void :
	_mic_note = text
	_mic_note_at = _time


func _mic_enter() -> void :
	_mic_note = ""
	_mic().list_devices( func(_list: Array) -> void : pass)


func _mic_leave() -> void :
	_mic_menu = false
	_mic_key = false
	if MicEngine._shared != null:
		MicEngine._shared.idle()


func _set_tab(tab: String) -> void :
	if _tab == "mic" and tab != "mic":
		_mic_leave()
	_tab = tab
	if tab == "mic":
		_mic_enter()
	elif tab == "look":
		_chat_load()


func _mic_gate_now() -> float:
	if Settings.on("mic_gate_auto") and MicEngine._shared != null and MicEngine._shared.running:
		return float(MicEngine._shared.gate_level)
	return Settings.level("mic_gate")



static func mic_devices(list: Array) -> Array:
	var out: Array = [{"id": "", "label": MIC_DEFAULT}]
	var n: int = 0
	for item: Variant in list:
		if not item is Dictionary:
			continue
		var id: String = str(item.get("id", ""))
		if id.is_empty() or id == "default" or out.size() >= 8:
			continue
		n += 1
		var label: String = str(item.get("label", "")).strip_edges()
		out.append({"id": id, "label": label if not label.is_empty() else "Mic %d" % n})
	return out

static func mic_device_name(list: Array, id: String) -> String:
	for entry: Dictionary in mic_devices(list):
		if str(entry["id"]) == id:
			return str(entry["label"])
	return "Mic đã chọn (chưa thấy)"


static func ptt_flash(code: int) -> int:
	var event: InputEventKey = InputEventKey.new()
	event.physical_keycode = code as Key
	return flash_code(event)

static func ptt_name(code: int) -> String:
	var name: String = key_name(ptt_flash(code))
	return name if not name.is_empty() else "?"


static func ptt_block(flash: int, keys: Dictionary) -> String:
	var name: String = key_name(flash)
	if flash == 0 or name.is_empty() or flash >= 1000:
		return "Phím này không dùng làm phím nói được."
	if flash in MIC_MOVE:
		return "%s dùng để di chuyển, chọn phím khác." % name
	if flash in MIC_KEEP:
		return "%s không dùng làm phím nói được." % name
	var action: int = conflict(keys, flash, -1)
	if action != 0:
		return "%s đang là phím %s, chọn phím khác." % [name, action_name(action)]
	return ""


static var mic_app: String = ""
const MIC_PC_DENY: String = "Windows đang chặn micro — bật Cài đặt Windows › Quyền riêng tư › Micro (cho ứng dụng máy tính) rồi thử lại."
const MIC_NO_APP: PackedStringArray = ["Micro / nói chuyện thoại chưa có trên app.", "Dùng bản web để nói chuyện trong room."]





static func mic_notice() -> PackedStringArray:
	if mic_app == "web":
		return PackedStringArray()
	if mic_app == "android" or mic_app == "pc":
		return _app_mic_notice(mic_app == "pc")
	if OS.has_feature("android") or OS.has_feature("ios") or OS.has_feature("pc_app") or ( not OS.has_feature("web") and not OS.has_feature("editor")):
		return _app_mic_notice( not OS.has_feature("android") and not OS.has_feature("ios"))
	return PackedStringArray()

static func _app_mic_notice(pc: bool) -> PackedStringArray:
	if not pc or not PcVoice.is_pc():
		return MIC_NO_APP
	var why: String = PcVoice.blocked()
	match why:
		"":
			return PackedStringArray()
		"nosession":
			return PackedStringArray(["Micro cần đăng nhập vào game.", "Đăng nhập rồi mở lại tab này để dùng micro."])
		"fail:runtime":
			return PackedStringArray(["Máy chưa có WebView2 Runtime nên chưa dùng được micro.", 
				"Cài Microsoft Edge WebView2 Runtime (miễn phí) rồi mở lại app."])
		"fail:av", "fail:spawn":
			return PackedStringArray(["Phần mềm diệt virus hoặc Windows đang chặn bbvoice.exe (bộ thoại của app).", "Cho phép tệp này hoặc thêm thư mục game vào danh sách loại trừ, rồi mở lại app."])
	return PackedStringArray(["Bộ thoại của app không chạy được (%s)." % why.trim_prefix("fail:"), "Mở lại app để thử lại."])



func _paint_mic(_base: Vector2) -> void :
	var notice: PackedStringArray = mic_notice()
	if not notice.is_empty():

		_header("hdr_mic", "MICRO", "")
		_card(173.5, 106, 528.5, 160, "card_device", 197.5, 126, "THIẾT BỊ", 222.5)
		_tx(notice[0], 186.5, 175, 15.0, 500)
		_tx(notice[1], 186.5, 205, 13.0, 500, St2Skin.BOLD, St2Skin.ACCOUNT, "l", 0.0)
		return
	var mic: Variant = _mic()
	var level: float = mic.level()
	var mode: String = str(Settings.value("mic_mode"))
	var muted: bool = Settings.on("mic_mute")
	_header("hdr_mic", "MICRO", "reset:mic")

	_card(173.5, 106, 265.5, 160, "card_device", 197.5, 126, "THIẾT BỊ", 222.5)
	St2Skin.block(self, _rr(181, 146, 251, 116), _f)
	_tx("Micro", 186.5, 163.5, 14.0, 52)
	_mic_box("mic:devices", mic_device_name(mic.devices, str(Settings.value("mic_device"))), 241, 152, 186.5, 23)
	St2Skin.sep(self, _pp(186, 0).x, _pp(427, 0).x, _pp(0, 182).y, _f)
	_tx("Âm lượng", 186.5, 194, 12.0, 58)
	_tx("mic", 186.5, 208.5, 12.0, 58)
	_track("mic_gain", 249, 195, 69, 12, 20.0)
	St2Skin.numbox(self, _rr(322, 190, 38.5, 22.5), _f, _level_text("mic_gain"), 11.0)
	_btn("mic:mute", 364.5, 189, 67.5, 25, "orange" if muted else "blue", "BẬT MIC" if muted else "TẮT MIC", 11.0)
	St2Skin.sep(self, _pp(186, 0).x, _pp(427, 0).x, _pp(0, 220).y, _f)
	var voice: Variant = VoiceClient.shared()
	var deaf: bool = str(voice.speaker) == "off"
	_tx("Âm lượng", 186.5, 232.5, 12.0, 58)
	_tx("nghe", 186.5, 247, 12.0, 58)
	_track("voice_play_vol", 249, 233.5, 69, 12, 20.0)
	St2Skin.numbox(self, _rr(322, 228.5, 38.5, 22.5), _f, _level_text("voice_play_vol"), 11.0)
	_btn("mic:hear", 364.5, 227.5, 67.5, 25, "orange" if deaf else "blue", "BẬT NGHE" if deaf else "TẮT NGHE", 11.0)

	_card(446.5, 106, 255.5, 160, "card_proc", 470, 126, "XỬ LÝ TIẾNG", 496.5)
	St2Skin.block(self, _rr(453, 146, 242, 116), _f)
	_tx("Chống ồn", 460, 157, 14.0, 120)
	var ns: int = int(Settings.value("mic_ns"))
	var pills: Array = [[458.5, 72.5], [535.0, 77.5], [616.5, 76.0]]
	for i in MIC_NS_NAMES.size():
		_btn("mic:ns:%d" % i, float(pills[i][0]), 170, float(pills[i][1]), 26, "orange" if ns == i else "blue", MIC_NS_NAMES[i], 13.0)
	_tx("Nâng cao lọc mạnh hơn, tốn CPU hơn.", 460, 208, 11.0, 232, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)
	St2Skin.sep(self, _pp(459, 0).x, _pp(689, 0).x, _pp(0, 220).y, _f)
	_mic_check("mic:ec", "Khử vọng", Settings.on("mic_ec"), 461.5, 230, 495, 60, 12.0)
	_mic_check("mic:agc", "Tự cân âm lượng", Settings.on("mic_agc"), 559, 230, 593, 100, 12.0)

	_card(173.5, 273.5, 265.5, 128.5, "card_mode", 197.5, 293.5, "CHẾ ĐỘ MIC", 220)
	var modes: Dictionary = {"off": [184.0, 52.0], "ptt": [240.0, 110.0], "open": [354.0, 78.0]}
	for key: String in MIC_MODE_NAMES:
		var at: Array = modes[key]
		_btn("mic:mode:" + key, float(at[0]), 321, float(at[1]), 26, "orange" if mode == key else "blue", str(MIC_MODE_NAMES[key]), 13.0)
	match mode:
		"ptt":
			if _mobile:
				_tx("Màn cảm ứng không cần phím nói.", 186.5, 377, 11.0, 246, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)
			else:
				_tx("Phím nói", 186.5, 377, 13.0, 58)
				var code: int = int(Settings.value("mic_ptt_key"))
				var clash: String = ptt_block(ptt_flash(code), _current())
				_keycell("mic:key", 247.5, 361, 43.5, 32.5, "..." if _mic_key else ptt_name(code), not clash.is_empty())
				var warn: bool = not _mic_key and not clash.is_empty()
				var tip: String = clash if warn else ("Nhấn phím mới • Esc hủy" if _mic_key else "Bấm ô rồi nhấn phím mới.")
				var cut: int = tip.find(", ") if warn else -1
				var tint: Color = St2Skin.WARN if warn else St2Skin.SOFT
				if cut > 0:
					_tx(tip.substr(0, cut + 1), 295, 370, 11.0, 137, St2Skin.SEMI, tint, "l", 0.0)
					_tx(tip.substr(cut + 2), 295, 384, 11.0, 137, St2Skin.SEMI, tint, "l", 0.0)
				else:
					_tx(tip, 295, 377, 11.0, 137, St2Skin.SEMI, tint, "l", 0.0)
		"open":
			_tx("Ngưỡng", 186.5, 377, 13.0, 52)
			_track("mic_gate", 240, 372, 110, 10, 18.0)
			_mic_check("mic:auto", "Tự động", Settings.on("mic_gate_auto"), 360, 365, 386, 48)
		_:
			_tx("Mic không tự mở khi chơi.", 186.5, 377, 12.0, 244, St2Skin.SEMI, St2Skin.SOFT, "l", 0.0)

	_card(446.5, 273.5, 255.5, 128.5, "card_test", 471, 292, "KIỂM TRA MIC", 496.5)
	_tx("Mức tiếng", 460, 322, 13.0, 120)
	_mic_meter(Rect2(459, 332.5, 166, 19.5), 0.0 if muted else level, mode == "open", _mic_gate_now(), bool(mic.running))
	var state: String = "Chưa mở"
	var color: Color = St2Skin.SOFT
	if muted:
		state = "Đang tắt"
		color = St2Skin.WARN
	elif bool(mic.waiting):
		state = "Chờ mic…"
	elif bool(mic.running):
		state = ("Qua ngưỡng" if level >= _mic_gate_now() else "Dưới ngưỡng") if mode == "open" else "Đang mở"
		color = St2Skin.LIVE
	_tx(state, 631.5, 341, 11.0, 66, St2Skin.BOLD, color, "l", 0.0)
	var monitoring: bool = bool(mic.monitoring)
	_btn("mic:monitor", 457, 362.5, 76, 30, "orange" if monitoring else "blue", "ĐANG NGHE" if monitoring else "NGHE THỬ", 11.0)
	var test_ms: int = int(mic.test_ms)
	var record: String = "GHI THỬ 5s"
	if test_ms == 0:
		record = "CHỜ MIC…"
	elif test_ms > 0:
		record = "ĐANG GHI %ds" % maxi(1, ceili((5000.0 - test_ms) / 1000.0))
	_btn("mic:record", 536, 362.5, 80, 30, "orange" if test_ms >= 0 else "blue", record, 11.0)
	var playing: bool = bool(mic.playing)
	_btn("mic:play", 619, 362.5, 74, 30, "orange" if playing else "blue", "DỪNG PHÁT" if playing else "PHÁT LẠI", 11.0, playing or bool(mic.has_clip))
	var note: String = _mic_note if not _mic_note.is_empty() and _time - _mic_note_at < MIC_NOTE_SECONDS else ""
	if note.is_empty() and muted:
		note = "Mic đang tắt: bấm BẬT MIC để bật lại."
	if note.is_empty() and deaf:
		note = "Đang tắt nghe: bấm BẬT NGHE để nghe lại giọng người khác."
	_hint(note if not note.is_empty() else "Đeo tai nghe khi Nghe thử để loa không lọt vào mic.", St2Skin.WARN if not note.is_empty() else Color.WHITE)
	if _mic_menu:
		_mic_list(241, 175, 186.5, mic.devices)


func _mic_check(id: String, text: String, on: bool, x: float, y: float, tx: float, wide: float, px: float = 13.0) -> void :
	_check(id, on, x, y)
	_tx(text, tx, y + 12.0, px, wide)
	_hit(id, _rr(x, y, tx - x + wide, 24), false)


func _mic_box(id: String, text: String, x: float, y: float, w: float, h: float) -> void :
	var r: Rect2 = _rr(x, y, w, h)
	var hot: bool = _mic_menu or (_hover == id and _press.is_empty())
	St2Skin.grad(self, r, 5.0 * _f, Color("06306e"), Color("042559"), Color("ffb21e") if _mic_menu else (Color("9fdcff") if hot else Color("2f88da")), maxf(1.0, 1.2 * _f))
	_tx(text, x + 7.0, y + h / 2.0, 11.0, w - 28.0, St2Skin.SEMI, Color.WHITE, "l", 0.0)
	var tip: Vector2 = _pp(x + w - 11.0, y + h / 2.0)
	draw_colored_polygon(PackedVector2Array([tip + Vector2(-5, -3) * _f, tip + Vector2(5, -3) * _f, tip + Vector2(0, 3.5) * _f]), 
		Color("ffb21e") if _mic_menu else Color("99ccff"))
	_hit(id, r, false)


func _mic_list(x: float, y: float, w: float, list: Array) -> void :
	var items: Array = mic_devices(list)
	var current: String = str(Settings.value("mic_device"))
	var box: Rect2 = _rr(x, y, w, 22.0 * items.size() + 4.0)
	St2Skin.grad(self, box, 5.0 * _f, Color("0d4a92", 0.98), Color("06306e", 0.98), Color("9fdcff"), maxf(1.0, 1.2 * _f))
	_hit("mic:menu", box, false)
	for i in items.size():
		var id: String = "mic:dev:%d" % i
		var row: Rect2 = _rr(x + 2.0, y + 2.0 + 22.0 * i, w - 4.0, 22)
		var chosen: bool = str(items[i]["id"]) == current
		if _hover == id and _press.is_empty():
			draw_rect(row, Color(1, 1, 1, 0.14))
		_tx(str(items[i]["label"]), x + 8.0, y + 13.0 + 22.0 * i, 11.0, w - 14.0, St2Skin.SEMI, Color("ffb21e") if chosen else Color.WHITE, "l", 0.0)
		_hit(id, row, false)


func _mic_meter(at: Rect2, level: float, open: bool, gate: float, running: bool) -> void :
	var r: Rect2 = _rr(at.position.x, at.position.y, at.size.x, at.size.y)
	St2Skin.grad(self, r, 4.0 * _f, Color("06183a"), Color("0a2a5a"), Color("2f88da", 0.8), maxf(1.0, _f))
	var share: float = clampf(level, 0.0, 1.0) if running else 0.0
	var lit: int = ceili(share * 20.0 - 0.001) if share > 0.005 else 0
	var gap: float = 2.0 * _f
	var pad: float = 2.0 * _f
	var w: float = (r.size.x - pad * 2.0 - gap * 19.0) / 20.0
	var pass_on: bool = not open or share >= gate
	for i in 20:
		var cell: Rect2 = Rect2(r.position + Vector2(pad + (w + gap) * i, pad), Vector2(w, r.size.y - pad * 2.0))
		var on_color: Color = Color("30f10f") if i < 12 else (Color("fabf01") if i < 16 else Color("ff3a2a"))
		if i < lit and not pass_on:
			on_color = Color("8fb3cf")
		draw_rect(cell, on_color if i < lit else Color("486289"))
	if open:
		var gx: float = r.position.x + r.size.x * clampf(gate, 0.0, 1.0)
		draw_line(Vector2(gx, r.position.y - 3.0 * _f), Vector2(gx, r.end.y + 3.0 * _f), Color("ffb21e"), maxf(1.0, 2.0 * _f))
		draw_colored_polygon(PackedVector2Array([Vector2(gx - 4.0 * _f, r.position.y - 7.0 * _f), Vector2(gx + 4.0 * _f, r.position.y - 7.0 * _f), 
			Vector2(gx, r.position.y - 2.0 * _f)]), Color("ffb21e"))


func _mic_click(what: String) -> void :
	var mic: Variant = _mic()
	if what == "devices":
		_mic_menu = not _mic_menu
		if _mic_menu:
			mic.list_devices( func(_list: Array) -> void : pass)
		return
	if what == "menu":
		return
	_mic_menu = false
	if what.begins_with("dev:"):
		var items: Array = mic_devices(mic.devices)
		var index: int = int(what.substr(4))
		if index >= 0 and index < items.size():
			mic.set_device(str(items[index]["id"]))
	elif what.begins_with("ns:"):
		mic.set_ns(int(what.substr(3)))
	elif what.begins_with("mode:"):
		mic.set_mode(what.substr(5))
		_mic_key = false
	match what:
		"mute":
			mic.set_mute( not Settings.on("mic_mute"))
		"hear":
			var voice: Variant = VoiceClient.shared()
			voice.set_speaker("off" if str(voice.speaker) != "off" else str(voice.speaker_last))
		"ec":
			mic.set_ec( not Settings.on("mic_ec"))
		"agc":
			mic.set_agc( not Settings.on("mic_agc"))
		"auto":
			mic.set_gate(Settings.level("mic_gate"), not Settings.on("mic_gate_auto"))
		"key":
			if not _mobile:
				_mic_key = not _mic_key
				_mic_note = ""
		"monitor":
			mic.monitor( not bool(mic.monitoring))
		"record":
			if int(mic.test_ms) < 0:
				mic.test_record()
		"play":
			mic.test_play()


func _mic_reset() -> void :
	_mic_key = false
	_mic_menu = false
	for key: String in Settings.DEFAULTS:
		if key.begins_with("mic_") or key == "voice_play_vol":
			Settings.put(key, Settings.DEFAULTS[key], false)
	Settings.save()


func _mic_capture(event: InputEventKey) -> void :
	if event.keycode == KEY_ESCAPE or event.physical_keycode == KEY_ESCAPE:
		_mic_key = false
		return
	var why: String = ptt_block(flash_code(event), _current())
	if not why.is_empty():
		_mic_say(why)
		return
	_mic().set_ptt_key(event.physical_keycode if event.physical_keycode != KEY_NONE else event.keycode)
	_mic_key = false
	_mic_note = ""


func _flag_on(box: String) -> bool:
	if client == null:
		return false
	return (int(client.character.get("setting_flag", 0)) & int(FLAG_BITS.get(box, 0))) != 0


func _check(id: String, on: bool, x: float, y: float, live: bool = true) -> void :
	var r: Rect2 = _rr(x, y, 24, 24)
	St2Skin.check(self, r, _f, on, 1.0 if live else 0.45, _shine(id) if live else 1.0)
	if live:
		_hit(id, r, false)


func _paint_capture() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.3))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(400.0, 300.0)
	var r: Rect2 = Rect2(at * _f, Vector2(400.0, 300.0) * _f)
	_hit("panel", r, false)
	St2Skin.dialog(self, r, _f)
	var reg: Array = St2Atlas.R.get("st2_lock_title", [0, 0, 0, 68])
	St2Skin.icon(self, "lock_title", (at + Vector2(200, 92)) * _f, float(reg[3]) / St2Atlas.SCALE * 1.5 * _f)
	var name: String = PTT_NAME if _capture == PTT else action_name(_capture)
	St2Skin.words(self, St2Skin.XBOLD, "Khóa " + name, 22.0 * _f, Rect2((at + Vector2(16, 128)) * _f, Vector2(368, 40) * _f), Color.WHITE, "c", St2Skin.RIM, 3.0 * _f)
	St2Skin.words(self, St2Skin.BOLD, "Nhấn phím để khóa hoặc ESC để hủy", 15.0 * _f, Rect2((at + Vector2(16, 166)) * _f, Vector2(368, 30) * _f), Color.WHITE, "c", St2Skin.RIM, 2.0 * _f)
	if not _cant.is_empty():
		St2Skin.words(self, St2Skin.XBOLD, _cant, 17.0 * _f, Rect2((at + Vector2(16, 206)) * _f, Vector2(368, 34) * _f), St2Skin.WARN, "c", St2Skin.RIM, 2.5 * _f)


func _paint_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(450.0, 220.0)
	var r: Rect2 = Rect2(at * _f, Vector2(450.0, 220.0) * _f)
	_hit("panel", r, false)
	St2Skin.dialog(self, r, _f)
	var reg: Array = St2Atlas.R.get("st2_alert", [0, 0, 0, 80])
	St2Skin.icon(self, "alert", (at + Vector2(58, 78)) * _f, float(reg[3]) / St2Atlas.SCALE * _f)
	var px: int = maxi(6, roundi(15.0 * _f))
	var wide: float = 318.0 * _f
	var lines: int = St2Skin.BOLD.get_multiline_string_size(_ask_text, HORIZONTAL_ALIGNMENT_LEFT, wide, px).y / maxf(1.0, St2Skin.BOLD.get_height(px))
	var top: float = (at.y + 78.0) * _f - lines * St2Skin.BOLD.get_height(px) / 2.0 + St2Skin.BOLD.get_ascent(px)
	var pos: Vector2 = Vector2((at.x + 108.0) * _f, top)
	draw_multiline_string_outline(St2Skin.BOLD, pos, _ask_text, HORIZONTAL_ALIGNMENT_LEFT, wide, px, 5, maxi(1, roundi(3.0 * _f)), St2Skin.RIM)
	draw_multiline_string(St2Skin.BOLD, pos, _ask_text, HORIZONTAL_ALIGNMENT_LEFT, wide, px, 5, Color.WHITE)
	for b: Array in [["ask_ok", 90.0, "green", "Xác nhận"], ["ask_no", 240.0, "blue", "Hủy"]]:
		var br: Rect2 = Rect2((at + Vector2(float(b[1]), 160)) * _f, Vector2(120, 38) * _f)
		St2Skin.button(self, br, _f, str(b[2]), str(b[3]), 17.0, _shine(str(b[0])))
		_hit(str(b[0]), br, false)


func _paint_tip() -> void :
	var key: String = ""
	var text: String = ""
	if TIPS.has(_hover) and _hits.any( func(hit: Array) -> bool: return str(hit[0]) == _hover):
		var tip: Array = TIPS[_hover]
		key = _hover
		text = "\n".join(PackedStringArray(tip.filter( func(part: Variant) -> bool: return not str(part).is_empty())))
	_ctip.draw(self, key, text, get_local_mouse_position() / _f, Vector2(_fw, _fh), _f)



func _activate(id: String) -> void :
	if not _ask.is_empty():
		if id == "ask_ok":
			_ask_yes()
		elif id in ["ask_no", "shade"]:
			_ask_no()
		return
	if _capture != 0:
		return
	if _lq_on() and _lq.activate(self, id):
		return
	if _mic_key and id != "mic:key":
		_mic_key = false
	if _mic_menu and not id.begins_with("mic:"):
		_mic_menu = false
	if id.begins_with("mic:"):
		_mic_click(id.substr(4))
	elif id.begins_with("tab:"):
		_switch_tab(id.substr(4))
	elif id == "key:ptt":
		if not _mobile:
			_capture = PTT
			_cant = ""
			_pending = 0
	elif id.begins_with("key:"):
		if client == null or not client.option_ready:
			say(NOT_READY)
			return
		_capture = int(id.substr(4))
		_cant = ""
		_pending = 0
	elif id.begins_with("smart:"):
		var slot: int = int(id.substr(6))
		if client == null or not client.set_smart_slot(slot, not client.smart_slot(slot)):
			say(NOT_READY)
	elif id.begins_with("slide:"):

		_slide(id.substr(6), get_local_mouse_position().x, true)
	elif id.begins_with("q:"):
		_quality(id.substr(2))
	elif id.begins_with("cb:"):
		var key: String = id.substr(3)
		Settings.put(key, not Settings.on(key))
	elif id.begins_with("look:bar:") and LobbyBar.valid(id.substr(9)):
		Settings.put("lobby_bar", id.substr(9))
	elif id.begins_with("look:theme:") and not LobbyThemes.find(id.substr(11)).is_empty():
		Settings.put("lobby_theme", id.substr(11))
	elif id.begins_with("look:dn:") and Settings.LOBBY_DAYNIGHT.has(id.substr(8)):
		Settings.put("lobby_daynight", id.substr(8))
	elif id == "look:fx:on" or id == "look:fx:off":
		Settings.put("lobby_fx", id == "look:fx:on")
	elif id == "look:fx":
		Settings.put("lobby_fx", not Settings.on("lobby_fx"))
	elif id.begins_with("look:prev:") or id.begins_with("look:next:"):
		var strip: String = id.substr(10)
		var info: Array = _strips.get(strip, [])
		if not info.is_empty():
			_scroll[strip] = clampi(int(_scroll.get(strip, 0)) + (-1 if id.begins_with("look:prev:") else 1), 0, maxi(0, int(info[1]) - int(info[2])))
	elif id.begins_with("look:bg"):
		_chat_act(id.substr(5))
	elif id.begins_with("todo:") and FLAG_BITS.has(id.substr(5)):


		var bit: int = int(FLAG_BITS[id.substr(5)])
		if client == null or not client.change_setting(int(client.character.get("setting_flag", 0)) ^ bit):
			say(NOT_READY)
	elif id == "todo:pwd":
		_pwd_click()
	elif id.begins_with("todo:"):
		say("%s đang được chuyển sang HTML5." % str(TODO.get(id.substr(5), "Mục này")))
	match id:
		"full":
			_toggle_full()
		"ok", "close":
			_close()
		"logout":
			_open_ask("logout", ASK_LOGOUT)
		"common":
			var none: Array[int] = []
			_save_slots(none)
		"intelligent":
			_save_slots(ALL_SMART)
		"reset:keys":

			_keys = {}
			if client == null or not client.save_char_option(ALL_SMART, sendable(reset_keys(_committed()))):
				say(NOT_READY)
		"reset:video":
			_quality("mid")
		"fpscap":
			Settings.put("fps_cap", Settings.next_cap(int(Settings.value("fps_cap"))))
		"quality":
			Settings.put("quality", Settings.next_quality(int(Settings.value("quality"))))
		"quality:prev":
			Settings.put("quality", prev_of(Settings.next_quality, int(Settings.value("quality"))))
		"pczoom", "pczoom:prev":
			Settings.put(AppZoom.KEY, AppZoom.step(AppZoom.level(), -1 if id.ends_with(":prev") else 1))
		"cursize", "cursize:prev":
			Settings.put("cursor_size", Settings.cursor_step(int(Settings.value("cursor_size")), -1 if id.ends_with(":prev") else 1))
		"fpscap:prev":
			Settings.put("fps_cap", prev_of(Settings.next_cap, int(Settings.value("fps_cap"))))
		"reset:mic":
			_mic_reset()
		"reset:sound":
			Settings.put("music", true, false)
			Settings.put("music_vol", 0.5, false)
			Settings.put("sfx", true, false)
			Settings.put("sfx_vol", 0.6, false)
			Settings.put("voice", true)


func _save_slots(slots: Array[int]) -> void :
	if client == null or not client.save_char_option(slots, sendable(_committed())):
		say(NOT_READY)

func _switch_tab(tab: String) -> void :
	if tab == _tab or not tab in TABS:
		return
	if _tab == "keys" and not missing(_current()).is_empty():
		_ask_tab = tab
		_open_ask("leave", ASK_UNSET)
		return
	_commit_keys()
	_set_tab(tab)

func _close() -> void :
	if not missing(_current()).is_empty():
		_open_ask("close", ASK_UNSET)
		return
	_commit_keys()
	_finish()

func _finish() -> void :
	_sliding = ""
	Settings.save()
	closed.emit()


func _commit_keys() -> void :
	if _keys.is_empty():
		return
	var draft: Dictionary = _keys
	_keys = {}
	if client == null or entries(draft) == entries(_committed()):
		return
	if not client.save_char_option(client.smart_slots, sendable(draft)):
		say(NOT_READY)



func _pwd_click() -> void :
	if client == null:
		say(NOT_READY)
	elif not client.pwd_has:
		pwd_asked.emit("set")
	elif client.pwd_lock:
		pwd_asked.emit("unlock")
	else:
		_open_ask("pwd_lock", PWD_TIP3)


func _setup() -> void :
	if SettingsLq.wanted():
		SettingsLqRuntime.ensure(self)
	if client != null:
		client.noticed.connect( func(text: String) -> void :
			if is_visible_in_tree():
				say(text))

func _open_ask(kind: String, text: String) -> void :
	_ask = kind
	_ask_text = text
	_hover = ""
	_press = ""

func _ask_yes() -> void :
	var kind: String = _ask
	_ask = ""
	match kind:
		"pwd_lock":
			if client == null or not client.protect_pwd_op(7):
				say(NOT_READY)
		"logout":
			if missing(_current()).is_empty():
				_commit_keys()
			_keys = {}
			sign_out.emit()
		"leave":
			_commit_keys()
			_set_tab(_ask_tab)
		"close":
			_commit_keys()
			_finish()
		"lq_reset":
			Settings.reset()
			say("Đã khôi phục cài đặt trên máy này.")
		"lq_back":
			_commit_keys()
			_set_tab("keys")
			if _lq != null:
				_lq.classic = ""
		"conflict":
			var draft: Dictionary = _current().duplicate()
			var other: int = conflict(draft, _pending, _capture)
			if other != 0:
				draft[other] = 0
			draft[_capture] = _pending
			_keys = draft
			_end_capture()

func _ask_no() -> void :
	if _ask == "conflict":
		_pending = 0
	_ask = ""


func _capture_key(code: int) -> void :
	if not can_set(code):
		_cant = ("%s không thể coi là phím sử dụng" % key_name(code)).strip_edges()
		return
	if not _mobile and code == ptt_flash(int(Settings.value("mic_ptt_key"))):
		_cant = "%s đang là phím nói (mic)" % key_name(code)
		return
	_cant = ""
	var keys: Dictionary = _current()
	var other: int = conflict(keys, code, _capture)
	if other != 0:
		_pending = code
		_open_ask("conflict", "%s hiện tại là phím %s, đổi thành phím %s chứ?" % [key_name(code), action_name(other), action_name(_capture)])
		return
	var draft: Dictionary = keys.duplicate()
	draft[_capture] = code
	_keys = draft
	_end_capture()

func _end_capture() -> void :
	_capture = 0
	_cant = ""
	_pending = 0

func _gui_input(event: InputEvent) -> void :
	if _capture != 0 and _ask.is_empty() and event is InputEventMouseButton:

		var button: InputEventMouseButton = event
		if not button.pressed and button.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			if _mobile:
				_end_capture()
			elif _capture == PTT:
				if _hit_at(button.position) == "panel":
					_cant = ptt_block(1000, _current())
			elif _hit_at(button.position) == "panel":
				_capture_key(int({MOUSE_BUTTON_LEFT: 1000, MOUSE_BUTTON_RIGHT: 1001}.get(button.button_index, 1002)))
		_held = false
		_press = ""
		accept_event()
		return
	super (event)

func _input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not (event is InputEventKey):
		return
	var key: InputEventKey = event
	if not _ask.is_empty():
		if key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
			_ask_no()
		get_viewport().set_input_as_handled()
	elif _capture != 0:
		if key.pressed and not key.echo:
			if key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE:
				_end_capture()
			elif _capture == PTT:
				var why: String = ptt_block(flash_code(key), _current())
				if not why.is_empty():
					_cant = why
				else:
					_mic().set_ptt_key(key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode)
					_end_capture()
			else:
				_capture_key(flash_code(key))
		get_viewport().set_input_as_handled()
	elif _mic_key:
		if key.pressed and not key.echo:
			_mic_capture(key)
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :
	if not is_visible_in_tree() or not _ask.is_empty() or _capture != 0 or _mic_key:
		return
	var key: InputEventKey = event as InputEventKey
	if key != null and key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
		if _lq_on() and not _lq.classic.is_empty():
			_lq.back(self)
		else:
			_close()
		get_viewport().set_input_as_handled()
