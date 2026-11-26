extends "flash_screen.gd"









const Horn = preload("chorn_atlas.gd")
const Cs = preload("chat_cs_atlas.gd")
const Tts = preload("chat_tts.gd")
const CS_TOP: float = 28.0
const CS_RIM: Color = Color("6c400b")
const SHOW: float = 30.0
const SIZE: Vector2 = Vector2(548, 46)
const TOP: float = 74.0
const TEXT: Color = Color("ffcc00")
const LOBBY_DROP: float = 64.0

var _rev: int = -1
var _scan: int = 0
var _seq: int = 0
var _line: Dictionary = {}
var _since: float = -100.0
var _cs_line: Dictionary = {}
var _cs_since: float = -100.0
var tts: Node

func _setup() -> void :
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_use(Horn.FILE, Horn.R)
	_use(Cs.FILE, Cs.R)
	tts = Tts.new()
	tts.client = client
	add_child(tts)
	if client != null and client.has_signal("global_horn_heard"):
		client.global_horn_heard.connect(_horn_heard)

func _horn_heard(text: String) -> void :
	tts.speak(text)

func _tick(_delta: float) -> void :
	if client == null or client.chat_rev == _rev:
		return
	_rev = client.chat_rev
	var top: int = _scan
	var big: bool = false
	var cs: bool = false
	for i in range(client.chat_log.size() - 1, -1, -1):
		var line: Dictionary = client.chat_log[i]
		var seq: int = int(line.get("seq", 0))
		if seq <= _scan:
			break
		top = maxi(top, seq)
		var channel: int = int(line.get("channel", 0))
		if channel == 256 and not big:
			big = true
			_seq = seq
			_line = line
			_since = _time
		elif channel == 2048 and not cs:
			cs = true
			_cs_line = line
			_cs_since = _time
		if big and cs:
			break
	_scan = top
	if (big and showing()) or (cs and cs_showing()):
		tts.ding()


func showing() -> bool:
	return not _line.is_empty() and _time - _since < SHOW and client.state in ["lobby", "hall", "room"] and not client.battle.active


func words() -> String:
	return str(_line.get("name", "")) + str(_line.get("text", "")) if showing() else ""


func cs_showing() -> bool:
	return not _cs_line.is_empty() and _time - _cs_since < SHOW and client.state in ["lobby", "hall", "room"] and not client.battle.active


func cs_words() -> String:
	return str(_cs_line.get("name", "")) + str(_cs_line.get("text", "")) if cs_showing() else ""


func _banner(at: Vector2) -> void :
	if Horn.R.has("chorn_bugle_bk"):
		_fblit("chorn_bugle_bk", at)
	else:
		_round(Rect2(at * _f, SIZE * _f), Color(0, 0, 0, 0.6), 46.0, Color(1, 1, 1, 0.8), 2.0)


func drop() -> float:
	return LOBBY_DROP if client.state == "lobby" else 0.0

func _paint() -> void :
	var left: float = roundf((floorf(_fw + 0.01) - SIZE.x) / 2.0)
	if cs_showing():
		var top: Vector2 = Vector2(left, CS_TOP + drop())
		_banner(top)
		_fblit("chatcs_icon", top + Vector2(2, 6))
		_fwords(cs_words(), BOLD, 14.0, TEXT, "l", top + Vector2(33, 12), SIZE.x - 43.0, 1.0, 0.0, true, CS_RIM)
	if not showing():
		return
	var at: Vector2 = Vector2(left, TOP + drop())
	_banner(at)
	_fblit("chorn_music", at + Vector2(2, 6))
	var x: float = 33.0
	if int(_line.get("gm", 0)) >= 6:
		_fblit("chorn_gm", at + Vector2(36, 15))
		x = 64.0
	_fwords(words(), BOLD, 14.0, TEXT, "l", at + Vector2(x, 12), SIZE.x - x - 10.0, 1.0, 0.0, true, Color.BLACK)
