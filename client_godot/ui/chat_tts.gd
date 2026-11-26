extends Node
const AppSession = preload("res://net/app_session.gd")









const Settings = preload("res://settings.gd")

const PATH: String = "/api/chat-tts.mp3"
const MAX: int = 3
const BODY_LIMIT: int = 2 * 1024 * 1024 + 1024
const QUIET: float = 0.004
const RETRY: float = 2.0
const BUGLE_PATH: String = "/rez/vi_VN/sound/ui/dalaba.mp3"
const BUGLE_WAIT: float = 3.0


static var fetch: Callable

static var fetch_bugle: Callable

var client: Object
var asked: PackedStringArray = PackedStringArray()
var played: int = 0
var dropped: int = 0
var _loading: int = 0
var retried: int = 0
var dinged: int = 0
var _again: Array = []
var _clock: float = 0.0
var _bugle: AudioStreamMP3 = null
var _bugle_loading: bool = false
var _bugle_want: float = -100.0
var _players: Array[AudioStreamPlayer] = []
var _ding_player: AudioStreamPlayer = null

func _ready() -> void :
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void :
	_clock += delta
	while not _again.is_empty() and float(_again[0][1]) <= _clock:
		var text: String = str(_again.pop_front()[0])
		speak(text, false)


func _maybe_retry(text: String, result: int, code: int, again: bool) -> void :
	if not again:
		return
	if result == HTTPRequest.RESULT_SUCCESS and code < 500:
		return
	retried += 1
	_again.append([text, _clock + RETRY])


static func url_of(origin: String, text: String) -> String:
	return origin + PATH + "?q=" + text.uri_encode()


static func gain() -> float:
	return Settings.level("sfx_vol") if Settings.on("sfx") else 0.0


func speak(text: String, again: bool = true) -> bool:
	if text.is_empty() or gain() <= QUIET or client == null:
		return false
	if preload("res://battle/chat_mute.gd").quiet_horn(client):
		return false
	var config: Variant = client.get("config")
	if config == null:
		return false
	var origin: String = str(config.get("origin"))
	if (origin.is_empty() or config.get("local_test_only") == true) and not fetch.is_valid():
		return false
	if _loading >= MAX:
		dropped += 1
		return false
	var url: String = url_of(origin, text)
	asked.append(url)
	if fetch.is_valid():
		var got: Variant = fetch.call(url)
		if got is PackedByteArray:
			heard(HTTPRequest.RESULT_SUCCESS, 200, got)
		elif int(got) >= 400:
			_maybe_retry(text, HTTPRequest.RESULT_SUCCESS, int(got), again)
		else:
			_maybe_retry(text, HTTPRequest.RESULT_CANT_CONNECT, 0, again)
		return true
	if not is_inside_tree():
		return false
	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 15.0
	http.body_size_limit = BODY_LIMIT
	if OS.has_feature("web"):
		http.accept_gzip = false
	http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		_loading -= 1
		http.queue_free()
		if not heard(result, code, body):
			_maybe_retry(text, result, code, again), CONNECT_ONE_SHOT)
	add_child(http)
	_loading += 1
	if http.request(url, AppSession.headers(url)) != OK:
		_loading -= 1
		http.queue_free()
		return false
	return true


func heard(result: int, code: int, body: PackedByteArray) -> bool:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.size() < 128:
		return false
	var level: float = gain()
	if level <= QUIET:
		return false
	var stream: AudioStreamMP3 = AudioStreamMP3.new()
	stream.data = body
	if stream.get_length() <= 0.0:
		return false
	stream.loop = false
	if not _play(stream, level):
		return false
	played += 1
	return true


func ding() -> bool:
	var level: float = gain()
	if level <= QUIET or client == null:
		return false
	if preload("res://battle/chat_mute.gd").quiet_horn(client):
		return false
	if _bugle != null:
		dinged += 1
		return _ding(_bugle, level)
	_bugle_want = _clock
	if _bugle_loading:
		return false
	var config: Variant = client.get("config")
	if config == null:
		return false
	var origin: String = str(config.get("origin"))
	if (origin.is_empty() or config.get("local_test_only") == true) and not fetch_bugle.is_valid():
		return false
	var url: String = origin + BUGLE_PATH
	if fetch_bugle.is_valid():
		var got: Variant = fetch_bugle.call(url)
		_bugle_got(got if got is PackedByteArray else PackedByteArray())
		return true
	if not is_inside_tree():
		return false
	var http: HTTPRequest = HTTPRequest.new()
	http.timeout = 15.0
	http.body_size_limit = BODY_LIMIT
	if OS.has_feature("web"):
		http.accept_gzip = false
	http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
		_bugle_loading = false
		http.queue_free()
		_bugle_got(body if result == HTTPRequest.RESULT_SUCCESS and code == 200 else PackedByteArray()), CONNECT_ONE_SHOT)
	add_child(http)
	_bugle_loading = true
	if http.request(url, AppSession.headers(url)) != OK:
		_bugle_loading = false
		http.queue_free()
		return false
	return true


func _bugle_got(body: PackedByteArray) -> void :
	if body.size() < 128:
		return
	var stream: AudioStreamMP3 = AudioStreamMP3.new()
	stream.data = body
	if stream.get_length() <= 0.0:
		return
	stream.loop = false
	_bugle = stream
	var level: float = gain()
	if _clock - _bugle_want <= BUGLE_WAIT and level > QUIET:
		dinged += 1
		_ding(stream, level)


func _ding(stream: AudioStream, level: float) -> bool:
	if _ding_player == null:
		_ding_player = AudioStreamPlayer.new()
		add_child(_ding_player)
	_ding_player.stream = stream
	_ding_player.volume_db = linear_to_db(maxf(0.0001, level))
	_ding_player.play()
	return true

func _play(stream: AudioStream, level: float) -> bool:
	var player: AudioStreamPlayer = null
	for candidate: AudioStreamPlayer in _players:
		if not candidate.playing:
			player = candidate
			break
	if player == null:
		if _players.size() >= MAX:
			dropped += 1
			return false
		player = AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
	player.stream = stream
	player.volume_db = linear_to_db(maxf(0.0001, level))
	player.play()
	return true
