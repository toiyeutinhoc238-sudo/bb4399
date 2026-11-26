extends Node




const Settings = preload("res://settings.gd")

const POOL: int = 10
const SAME_GAP_MS: int = 70
const LATE_MS: int = 350
const MUSIC_JS: String = "(function(){\nif (window.__bbMusic) return;\nvar a = null, src = '', vol = 1, bad = {};\nvar E = [], cur = null, nx = null, dv = 1, dbad = {}, fade = 0, wt = 0, dh = 0;\nvar ua = (window.navigator && navigator.userAgent) || '';\nvar ios = /iP(hone|ad|od)/.test(ua) || (/Macintosh/.test(ua) && window.navigator && navigator.maxTouchPoints > 1);\nfunction go(x){ var p = x.play(); if (p && p.catch) p.catch(function(){}); }\nfunction bless(x){ if (x.bbOk || !x.bbSrc || x === cur || x.bbGo) return; x.muted = true; var p = x.play();\n\tvar f = function(ok){ if (ok) x.bbOk = 1; if (x !== cur && !x.bbGo) { x.pause(); x.muted = false; } };\n\tif (p && p.then) p.then(function(){ f(1); }, function(){ f(0); }); else f(1); }\nfunction kick(){ [a, dh ? null : cur].forEach(function(x){ if (x && x.paused && !x.ended) go(x); }); }\nfunction gest(){ kick(); if (ios) E.forEach(bless); }\n['pointerdown','keydown','touchend'].forEach(function(n){ window.addEventListener(n, gest, true); });\nwindow.__bbMusic = function(url, volume, plain){\n\tif (plain && bad[url]) url = plain;\n\tvol = Math.max(0, Math.min(1, volume));\n\tif (url === src) { if (a) a.volume = vol; return; }\n\tsrc = url;\n\tif (a) { a.pause(); a.removeAttribute('src'); a.load(); a = null; }\n\tif (!url) return;\n\ta = new Audio(url); a.loop = true; a.preload = 'auto'; a.volume = vol;\n\tif (plain && plain !== url) { var b = a, u = url; b.onerror = function(){ if (a === b) { bad[u] = 1; src = ''; window.__bbMusic(plain, vol); } }; }\n\tkick();\n};\nwindow.__bbMusicState = function(){ return a ? (a.paused ? 'paused ' : 'playing ') + a.currentTime.toFixed(1) + ' ' + src.split('/').pop() : 'none'; };\n// nhac2: nhạc Dash = 2 thẻ <audio> dùng lại (iOS chỉ cho phát thẻ đã \"mở\" bằng lần bấm): cur đang phát, nx = đoạn / bài kế đã tải sẵn.\n// Nối đoạn: theo giờ CỦA THẺ (không theo đồng hồ trận) — nx chạy câm trước biên ~0.6 s, trộn tuyến tính 240 ms quanh biên\n// (iOS không chỉnh được volume → câm / bỏ câm đúng biên); đổi bài = chuyển cứng ở cuối bài.\nfunction spare(){\n\tfor (var i = 0; i < E.length; i++) if (E[i] !== cur && E[i] !== nx) return E[i];\n\tvar x = new Audio(); x.preload = 'auto'; x.bbSrc = ''; x.bbWant = -1; E.push(x);\n\tx.onerror = function(){ if (x.bbSrc) dbad[x.bbSrc] = 1; if (x === nx) { nx = null; stop(); } if (x === cur) cur = null; x.bbSrc = ''; };\n\tx.onloadedmetadata = function(){ if (x.bbWant < 0) return; try { var w = x.bbWant + (x.bbRun ? (performance.now() - x.bbAt) / 1000 : 0);\n\t\tif (x.loop && x.bbDur > 0) w = w % x.bbDur; if (w > 0.05) x.currentTime = w; } catch (e) {} x.bbWant = -1; };\n\treturn x;\n}\nfunction want(x, u, p, run){ if (x.bbSrc !== u) { x.src = u; x.bbSrc = u; } x.bbWant = p; x.bbAt = performance.now(); x.bbRun = run; if (x.readyState >= 1) x.onloadedmetadata(); }\nfunction stop(){ if (wt) { clearInterval(wt); wt = 0; } fade = 0; }\nfunction swap(){\n\tvar o = cur; cur = nx; nx = null; stop();\n\tif (o) { o.pause(); o.volume = dv; o.muted = false; o.bbGo = 0; }\n\tif (!cur) return;\n\tif (!cur.bbGo) { try { cur.currentTime = cur.bbP; } catch (e) {} }\n\tcur.volume = dv; cur.muted = false; cur.bbGo = 0; cur.bbE = -1; cur.loop = false;\n\tif (cur.paused) go(cur);\n}\nfunction watch(){\n\tif (!cur || !nx || !(cur.bbE >= 0)) { stop(); return; }\n\tvar left = cur.ended ? Math.min(0, cur.bbE - cur.currentTime) : cur.bbE - cur.currentTime;\n\tif (!nx.bbX) { if (left <= 0.02 || cur.ended) swap(); return; }\n\tvar lead = Math.min(0.6, nx.bbP - 0.06);\n\tif (!nx.bbGo) {\n\t\tif (left > lead && !cur.ended) return;\n\t\ttry { nx.currentTime = Math.max(0, nx.bbP - left); } catch (e) {}\n\t\tif (ios) nx.muted = true; else nx.volume = 0;\n\t\tnx.bbGo = 1; nx.bbWant = -1; go(nx);\n\t\treturn;\n\t}\n\tif (!fade) {\n\t\tif (left > 0.12 && !cur.ended) return;\n\t\tif ((nx.readyState < 3 || nx.paused) && left > -0.6 && !cur.ended) return;\n\t\tvar w = nx.bbP - left;\n\t\tif (Math.abs(nx.currentTime - w) > 0.08) { try { nx.currentTime = w; } catch (e) {} }\n\t\tfade = performance.now();\n\t}\n\tvar k = (performance.now() - fade) / 240;\n\tif (k >= 1 || cur.ended || (ios && k >= 0.5)) { swap(); return; }\n\tif (!ios) { cur.volume = dv * (1 - k); nx.volume = dv * k; }\n}\n// c = {u, p (giây trong tệp lúc này), l (thẻ tự lặp: bài nguyên tệp lặp một mình), d (độ dài tệp), e (giây trong tệp tới biên, -1 = không)}\n// n = {u, p (giây trong tệp kế lúc tới biên), x (true = trộn)} | null. Trả 1 = tệp c.u không phát được trên máy này.\n// nhac5: keep = 1 → chỉ TẠM DỪNG (rời sảnh / phòng, danh sách vẫn chạy): giữ thẻ + tệp đã tải, quay lại tua đúng giờ máy chủ.\nwindow.__bbDash2 = function(c, n, volume, keep){\n\tdv = Math.max(0, Math.min(1, volume));\n\tif ((!c || !c.u) && keep) { stop(); dh = 1; E.forEach(function(x){ x.pause(); x.bbGo = 0; x.muted = false; x.bbHeld = 1; }); nx = null; return 0; }\n\tdh = 0;\n\tif (!c || !c.u) { stop(); E.forEach(function(x){ x.pause(); x.removeAttribute('src'); x.load(); x.bbSrc = ''; x.bbGo = 0; }); cur = nx = null; return 0; }\n\tif (dbad[c.u]) return 1;\n\tif (cur && cur.bbSrc === c.u) {\n\t\tcur.bbE = c.e; cur.loop = !!c.l; cur.bbDur = c.d;\n\t\tif (!fade) {\n\t\t\tcur.volume = dv;\n\t\t\tif (cur.readyState >= 1 && !cur.seeking && cur.bbWant < 0) {\n\t\t\t\tvar diff = Math.abs(cur.currentTime - c.p);\n\t\t\t\tif (c.l && c.d > 0) diff = Math.min(diff, c.d - diff);\n\t\t\t\tif (diff > (cur.bbHeld || (cur.paused && !cur.ended) ? 0.3 : 2)) { try { cur.currentTime = c.p; } catch (e) {} } // nhac5: vừa tạm dừng → tua sát\n\t\t\t\tcur.bbHeld = 0;\n\t\t\t}\n\t\t}\n\t} else if (cur && nx && nx.bbSrc === c.u && c.p < nx.bbP + (fade || nx.bbGo ? 3 : 1)) {\n\t\tif (!wt) wt = setInterval(watch, 40); // đồng hồ máy chủ qua biên trước thẻ: để watch nối nốt\n\t\treturn 0;\n\t} else if (cur && n && cur.bbSrc === n.u && c.e >= 0 && c.e - c.p < 1.5) {\n\t\treturn 0; // thẻ đã qua biên trước đồng hồ máy chủ một chút\n\t} else {\n\t\tstop();\n\t\tvar x = nx && nx.bbSrc === c.u ? nx : null;\n\t\tfor (var i = 0; !x && i < E.length; i++) if (E[i].bbSrc === c.u) x = E[i]; // nhac5: thẻ đã tải sẵn tệp này (tạm dừng / kế)\n\t\tx = x || cur || spare();\n\t\tif (cur && cur !== x) { cur.pause(); cur.volume = dv; cur.muted = false; }\n\t\tif (nx && nx !== x) { nx.pause(); nx.bbGo = 0; nx.muted = false; }\n\t\tnx = null; cur = x;\n\t\tx.loop = !!c.l; x.bbDur = c.d; x.bbE = c.e; x.volume = dv; x.muted = false; x.bbGo = 0; x.bbHeld = 0;\n\t\twant(x, c.u, c.p, true);\n\t}\n\tif (n && n.u && c.e >= 0 && c.e - c.p < 10 && !dbad[n.u]) {\n\t\tif (!nx || nx.bbSrc !== n.u) {\n\t\t\tif (fade) return 0;\n\t\t\tvar y = nx || spare();\n\t\t\tif (y.bbGo) y.pause();\n\t\t\ty.bbGo = 0; y.loop = false; y.muted = false;\n\t\t\twant(y, n.u, n.x ? Math.max(0, n.p - 0.6) : n.p, false);\n\t\t\tnx = y;\n\t\t}\n\t\tnx.bbP = n.p; nx.bbX = !!n.x;\n\t\tif (c.e - c.p < 2 && !wt) wt = setInterval(watch, 40);\n\t} else if (nx && !fade) { nx.pause(); nx.bbGo = 0; nx.muted = false; nx = null; stop(); }\n\tkick();\n\treturn 0;\n};\nwindow.__bbDashState = function(){ var t = function(x){ return x.bbSrc.split('/').slice(-2).join('/'); };\n\treturn cur ? (cur.paused ? 'paused ' : 'playing ') + cur.currentTime.toFixed(1) + ' ' + t(cur) + (nx ? ' > ' + t(nx) : '') : 'none'; };\n})()"

































































































































const AppSession = preload("res://net/app_session.gd")
const DASH_POLL_MS: int = 15000
const DASH_TICK_MS: int = 500
const DASH_RETRY_MS: int = 60000
const DASH_STALE_MS: int = 40000
const DASH_DRIFT_S: float = 2.0
const DASH_FADE_S: float = 0.24
const DASH_CACHE: int = 3
const DASH_BODY_MAX: int = 64 * 1048576


const DASH_REVIVE_WAIT_MS: int = 11000
const DASH_REVIVE_AGE_MS: int = 1800000
const DASH_WHERE: Array[String] = ["lobby", "hall", "room"]
const DASH_TRACKS: Array[String] = ["login_bgm", "gameroom"]
const DASH_MONTHS: Array[String] = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

static var where: String = ""

static var _live: Node = null

static var boss: bool = false

var pack: Node
var played: int = 0
var _players: Array[AudioStreamPlayer] = []
var _next: int = 0
var _stamp: Dictionary = {}
const CUT_FADE: float = 0.12
var cuts: int = 0
var _gen: Array[int] = []
var _fades: Array = []
var _last: int = -1
var _wanted: Dictionary = {}
var _track: String = ""
var _music: AudioStreamPlayer
var _music_on: String = ""
var _tick_sound: AudioStreamWAV
var _click_stream: AudioStream = null
var _web: bool = false

var _dash: Dictionary = {}
var _dash_on: bool = false
var _dash_hold: bool = false
var _dash_reviving: bool = false
var _dash_web_kept: bool = false
var _dash_dirty: bool = false
var _dash_http: HTTPRequest
var _dash_busy: bool = false
var _dash_asked: int = - DASH_POLL_MS
var _dash_sent: int = 0
var _dash_tick_at: int = 0
var _dash_skew_ok: bool = false
var _dash_lo: float = 0.0
var _dash_hi: float = 0.0
var _dash_bad: Dictionary = {}
var _dash_got: int = -1000000
var _dash_web_url: String = ""
var _dash_re: RegEx
var _dash_sd_re: RegEx

var _dash_player: AudioStreamPlayer
var _dash_player2: AudioStreamPlayer
var _dash_cur_url: String = ""
var _dash_cur_e: float = -1.0
var _dash_nxt: Dictionary = {}
var _dash_fade_at: int = -1
var _dash_cache: Dictionary = {}
var _dash_order: Array[String] = []
var _dash_get: HTTPRequest
var _dash_getting: String = ""
var _dash_getting_id: String = ""
var _dash_failed: Dictionary = {}



static func music(track: String) -> void :
	if _live != null:
		_live._set_music(track)


static func play(key: String, volume: float = 1.0) -> void :
	if _live != null:
		_live._play(key, volume)


static func play_tracked(key: String, volume: float = 1.0) -> Array:
	return _live._play_tracked(key, volume) if _live != null else []


static func cut(handle: Array) -> bool:
	return _live._cut(handle) if _live != null else false

static func click() -> void :
	if _live != null:
		_live._click()


static func track_for(state: String, battle_over: bool) -> String:
	where = state
	match state:
		"room":
			return "gameroom"
		"battle":
			return "" if battle_over else ("fight_boss" if boss else "fight_bg")
	return "login_bgm"



func _ready() -> void :
	_live = self
	_web = OS.has_feature("web")
	process_mode = Node.PROCESS_MODE_ALWAYS
	for i in range(POOL):
		var player: AudioStreamPlayer = AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
	if _web:
		JavaScriptBridge.eval(MUSIC_JS, true)
	else:
		_music = AudioStreamPlayer.new()
		add_child(_music)
		_dash_player = AudioStreamPlayer.new()
		add_child(_dash_player)
		_dash_player2 = AudioStreamPlayer.new()
		add_child(_dash_player2)
	_tick_sound = _make_tick()
	Settings.watch(_changed)

func _exit_tree() -> void :
	if _live == self:
		_live = null

func _changed(key: String) -> void :
	if key in ["", "music", "music_vol"]:
		_apply_music()

func _process(_delta: float) -> void :
	_dash_tick()
	if not _web and _dash_on:
		_dash_watch()
	if not _web and _music_on != _wanted_track():
		_apply_music()
	if _click_stream == null and pack != null and not pack.base.is_empty():
		_click_stream = pack.sound("s/u/click.mp3")
	if _wanted.is_empty() or pack == null:
		return
	var now: int = Time.get_ticks_msec()
	for key: String in _wanted.keys():
		var asked: Array = _wanted[key]
		if now - int(asked[1]) > LATE_MS:
			_wanted.erase(key)
		elif pack.sound("s/%s.mp3" % key) != null:
			_wanted.erase(key)
			_play(key, float(asked[0]))



func _wanted_track() -> String:
	if (_dash_on or _dash_hold) and _dash_here():
		return ""
	return _track if Settings.on("music") and Settings.level("music_vol") > 0.004 else ""

func _set_music(track: String) -> void :
	if track == _track:
		return
	_track = track
	_apply_music()

func _apply_music() -> void :
	_dash_revive()
	_dash_on = _dash_ready()
	_dash_hold = _dash_on or _dash_live()
	_apply_dash()
	var want: String = _wanted_track()
	var volume: float = Settings.level("music_vol")
	if _web:
		var url: String = pack.base + "s/m/%s.mp3" % want if not want.is_empty() and pack != null and not pack.base.is_empty() else ""

		var versioned: String = str(pack.url("s/m/%s.mp3" % want)) if not url.is_empty() and pack.has_method("url") else url
		JavaScriptBridge.eval("window.__bbMusic && window.__bbMusic(%s, %s, %s)" % [JSON.stringify(versioned), "%.3f" % volume, 
			JSON.stringify(url)], true)
		_music_on = want
		return
	_music.volume_db = linear_to_db(maxf(0.0001, volume))
	if want == _music_on:
		return
	if want.is_empty():
		_music.stop()
		_music_on = ""
		return
	var stream: AudioStream = pack.sound("s/m/%s.mp3" % want) if pack != null else null
	if stream == null:
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	_music.stream = stream
	_music.play()
	_music_on = want




func _dash_root() -> String:
	if pack == null or pack.base.is_empty() or pack.local:
		return ""
	return pack.base.trim_suffix("/").get_base_dir() + "/mu/"


func _dash_here() -> bool:
	return where in DASH_WHERE and _track in DASH_TRACKS and Settings.on("music") and Settings.level("music_vol") > 0.004


func _dash_now() -> float:
	if _dash_skew_ok:
		return Time.get_ticks_msec() / 1000.0 + (_dash_lo + _dash_hi) * 0.5
	return Time.get_unix_time_from_system()



func _dash_src(it: Dictionary, t: float) -> Dictionary:
	var n: int = int(it.n)
	if n <= 0:
		return {"u": _dash_root() + str(it.file), "p": t, "k": -1, "e": float(it.dur), "d": float(it.dur)}
	var k: int = clampi(int(floorf(t / (int(it.lf) * float(it.fd)))), 0, n - 1)
	return _dash_seg(it, k, t)

func _dash_seg(it: Dictionary, k: int, t: float) -> Dictionary:
	var n: int = int(it.n)
	var lf: int = int(it.lf)
	var fd: float = float(it.fd)
	var s: float = maxi(0, k * lf - int(it.pf)) * fd
	var e: float = ((k + 1) * lf * fd if k < n - 1 else float(it.dur)) - s
	return {"u": _dash_root() + "%s/%d.mp3" % [str(it.sd), k], "p": t - s, "k": k, "e": e, "d": 0.0}



func _dash_at() -> Dictionary:
	var slot: Dictionary = _dash_slot()
	if slot.is_empty():
		return {}
	var items: Array = _dash.items
	var i: int = int(slot.i)
	var pos: float = float(slot.t)
	var it: Dictionary = items[i]
	if _dash_bad.has(str(it.id)):
		return {}
	var at: Dictionary = _dash_src(it, pos)
	var one_loop: bool = items.size() == 1 and bool(_dash.loop) and int(it.n) <= 0
	at.merge({"i": i, "id": str(it.id), "t": pos, "l": one_loop, "nu": "", "np": 0.0, "nx": false})
	if one_loop:
		at.e = -1.0
	elif int(at.k) >= 0 and int(at.k) < int(it.n) - 1:
		var b: float = (int(at.k) + 1) * int(it.lf) * float(it.fd)
		var nxt: Dictionary = _dash_seg(it, int(at.k) + 1, b)
		at.nu = nxt.u
		at.np = nxt.p
		at.nx = float(nxt.p) >= 0.3
	else:
		var j: int = i + 1
		if j >= items.size():
			j = 0 if bool(_dash.loop) else -1
		if j >= 0 and not _dash_bad.has(str(items[j].id)):
			at.nu = _dash_src(items[j], 0.0).u
	return at



func _dash_slot() -> Dictionary:
	if _dash.is_empty() or not _dash_fresh():
		return {}
	var items: Array = _dash.items
	var total: float = float(_dash.total)
	var pos: float = _dash_now() - float(_dash.start) / 1000.0
	if pos < 0.0 or total <= 0.0:
		return {}
	if bool(_dash.loop):
		pos = fmod(pos, total)
	elif pos >= total - 0.25:
		return {}
	var i: int = 0
	while i < items.size() - 1 and pos >= float(items[i].dur):
		pos -= float(items[i].dur)
		i += 1
	return {"i": i, "t": pos}


func _dash_fresh() -> bool:
	var now: int = Time.get_ticks_msec()
	return now - _dash_got <= DASH_STALE_MS or (_dash_busy and _dash_reviving and now - _dash_sent <= DASH_REVIVE_WAIT_MS)



func _dash_live() -> bool:
	if not _dash_here() or _dash_root().is_empty() or _dash_slot().is_empty():
		return false
	for it: Dictionary in _dash.items:
		if not _dash_bad.has(str(it.id)):
			return true
	return false



func _dash_revive() -> void :
	var now: int = Time.get_ticks_msec()
	if _dash.is_empty() or _dash_busy or now - _dash_got <= DASH_STALE_MS or now - _dash_got > DASH_REVIVE_AGE_MS or _dash_got < _dash_asked:
		return
	if _dash_here() and not _dash_root().is_empty():
		_dash_poll(now)


func _dash_pos() -> float:
	var at: Dictionary = _dash_at()
	return -1.0 if at.is_empty() else float(at.t)


func _dash_ready() -> bool:
	if not _dash_here() or _dash_root().is_empty():
		return false
	var at: Dictionary = _dash_at()
	return not at.is_empty() and (_web or _dash_cache.has(str(at.u)))

func _dash_tick() -> void :
	var now: int = Time.get_ticks_msec()
	if now - _dash_tick_at < DASH_TICK_MS:
		return
	_dash_tick_at = now
	if not _dash_here() or _dash_root().is_empty():
		if _dash_on or _dash_hold:
			_apply_music()
		return
	if not _dash_busy and now - _dash_asked >= DASH_POLL_MS:
		_dash_poll(now)
	if not _web and not _dash.is_empty():
		_dash_fetch()
	var ready: bool = _dash_ready()
	if ready != _dash_on or _dash_dirty or (ready or _dash_live()) != _dash_hold:
		_dash_dirty = false
		_apply_music()
	elif _dash_on:
		_apply_dash()

func _dash_poll(now: int) -> void :
	if _dash_http == null:
		_dash_http = HTTPRequest.new()
		_dash_http.timeout = 10.0
		if _web:
			_dash_http.accept_gzip = false
		_dash_http.request_completed.connect(_dash_polled)
		add_child(_dash_http)
	var url: String = _dash_root() + "state.json?t=%d" % now

	_dash_reviving = not _dash.is_empty() and _dash_got >= _dash_asked and now - _dash_got > DASH_STALE_MS and now - _dash_got <= DASH_REVIVE_AGE_MS
	_dash_asked = now
	_dash_sent = now
	if _dash_http.request(url, AppSession.headers(url)) == OK:
		_dash_busy = true

func _dash_polled(result: int, code: int, headers: PackedStringArray, body: PackedByteArray) -> void :
	_dash_busy = false
	_dash_reviving = false
	var recv: int = Time.get_ticks_msec()
	if result != HTTPRequest.RESULT_SUCCESS or (code != 200 and code != 404):
		return
	_dash_clock(headers, _dash_sent, recv)
	_dash_got = recv
	var next: Dictionary = _dash_parse(JSON.parse_string(body.get_string_from_utf8()) if code == 200 else null)
	if next != _dash:
		_dash = next
		_dash_dirty = true

static func _dash_num(v: Variant) -> float:
	return float(v) if (v is float or v is int) else -1.0


func _dash_parse(data: Variant) -> Dictionary:
	if not (data is Dictionary) or not bool(data.get("on", false)):
		return {}
	if _dash_re == null:
		_dash_re = RegEx.create_from_string("^[0-9a-f]{16}\\.(mp3|ogg)$")
		_dash_sd_re = RegEx.create_from_string("^[0-9a-f]{16}_[0-9a-f]{4}$")
	var v2: Variant = data.get("v2")
	if v2 is Dictionary and v2.get("items") is Array:
		var items: Array = []
		var total: float = 0.0
		for raw: Variant in v2.items:
			var it: Dictionary = _dash_item(raw)
			if it.is_empty():
				items.clear()
				break
			items.append(it)
			total += float(it.dur)
		var start2: float = _dash_num(v2.get("start"))
		if not items.is_empty() and items.size() <= 200 and start2 > 0.0:
			return {"start": start2, "loop": bool(v2.get("loop", false)), "items": items, "total": total}
	var one: Dictionary = _dash_item({"file": data.get("file"), "dur": data.get("dur")})
	var start: float = _dash_num(data.get("start"))
	if one.is_empty() or start <= 0.0:
		return {}
	return {"start": start, "loop": bool(data.get("loop", false)), "items": [one], "total": float(one.dur)}


func _dash_item(raw: Variant) -> Dictionary:
	if not (raw is Dictionary):
		return {}
	var file: String = str(raw.get("file", ""))
	var dur: float = _dash_num(raw.get("dur"))
	if _dash_re.search(file) == null or dur < 1.0 or dur > 14400.0:
		return {}
	var it: Dictionary = {"id": file.get_basename(), "file": file, "kind": file.get_extension(), "dur": dur, "n": 0}
	var n: int = int(_dash_num(raw.get("n")))
	var lf: int = int(_dash_num(raw.get("lf")))
	var pf: int = int(_dash_num(raw.get("pf")))
	var fd: float = _dash_num(raw.get("fd"))
	var sd: String = str(raw.get("sd", ""))
	if n > 0 and n <= 5000 and lf >= 16 and pf >= 0 and pf * 2 <= lf and fd > 0.005 and fd < 0.2 and _dash_sd_re.search(sd) != null\
	and (n - 1) * lf * fd < dur + 0.01 and n * lf * fd > dur - 0.01:
		it.merge({"n": n, "sd": sd, "lf": lf, "pf": pf, "fd": fd}, true)
	return it


func _dash_clock(headers: PackedStringArray, sent: int, recv: int) -> void :
	for h: String in headers:
		if not h.to_lower().begins_with("date:"):
			continue
		var unix: int = _dash_http_date(h.substr(5).strip_edges())
		if unix <= 0:
			return
		var lo: float = unix - recv / 1000.0
		var hi: float = unix + 1.0 - sent / 1000.0
		if _dash_skew_ok and lo <= _dash_hi and hi >= _dash_lo:
			_dash_lo = maxf(_dash_lo, lo)
			_dash_hi = minf(_dash_hi, hi)
		elif not _dash_skew_ok or hi - lo < 10.0:
			_dash_lo = lo
			_dash_hi = hi
			_dash_skew_ok = true
		return


static func _dash_http_date(text: String) -> int:
	var p: PackedStringArray = text.split(" ", false)
	if p.size() < 5:
		return 0
	var month: int = DASH_MONTHS.find(p[2]) + 1
	var hms: PackedStringArray = p[4].split(":")
	if month <= 0 or hms.size() != 3 or not p[1].is_valid_int() or not p[3].is_valid_int():
		return 0
	return Time.get_unix_time_from_datetime_dict({"year": p[3].to_int(), "month": month, "day": p[1].to_int(), 
		"hour": hms[0].to_int(), "minute": hms[1].to_int(), "second": hms[2].to_int()})

func _apply_dash() -> void :
	var at: Dictionary = _dash_at() if _dash_on else {}
	var volume: float = Settings.level("music_vol")
	if _web:
		if at.is_empty():


			var keep: bool = not _dash.is_empty()
			if not _dash_web_url.is_empty() or (_dash_web_kept and not keep):
				JavaScriptBridge.eval("window.__bbDash2 && window.__bbDash2(null, null, 0, %d)" % int(keep), true)
				_dash_web_url = ""
				_dash_web_kept = keep
			return
		_dash_web_kept = false
		var c: Dictionary = {"u": at.u, "p": snappedf(float(at.p), 0.001), "l": at.l, "d": at.d, "e": snappedf(float(at.e), 0.001)}
		var n: Variant = {"u": at.nu, "p": snappedf(float(at.np), 0.001), "x": at.nx} if not str(at.nu).is_empty() else null
		var r: Variant = JavaScriptBridge.eval("window.__bbDash2 ? window.__bbDash2(%s, %s, %.3f) : 1" % [JSON.stringify(c), 
			JSON.stringify(n), volume], true)
		_dash_web_url = str(at.u)
		if r == null or int(r) != 0:
			_dash_bad[str(at.id)] = true
			_dash_on = false
			JavaScriptBridge.eval("window.__bbDash2 && window.__bbDash2(null, null, 0)", true)
			_dash_web_url = ""
		return
	if _dash_player == null:
		return
	if at.is_empty() or not _dash_cache.has(str(at.u)):
		_dash_stop()
		return
	_dash_nxt = {"u": at.nu, "p": float(at.np), "x": bool(at.nx)} if not str(at.nu).is_empty() else {}
	if _dash_cur_url == str(at.u) and _dash_player.playing:
		_dash_cur_e = float(at.e)
		if _dash_fade_at < 0:
			_dash_player.volume_db = linear_to_db(maxf(0.0001, volume))
			var diff: float = absf(_dash_player.get_playback_position() - float(at.p))
			if bool(at.l):
				diff = minf(diff, float(at.d) - diff)
			if diff > DASH_DRIFT_S:
				_dash_player.seek(float(at.p))
		return
	if _dash_fade_at >= 0 and _dash_player2.playing:
		return
	if _dash_cur_url == str(at.nu) and _dash_player.playing and float(at.e) >= 0.0 and float(at.e) - float(at.p) < 1.5:
		return
	_dash_fade_at = -1
	_dash_player2.stop()
	var stream: AudioStream = _dash_cache[str(at.u)]
	_dash_loop(stream, bool(at.l))
	_dash_player.stream = stream
	_dash_player.volume_db = linear_to_db(maxf(0.0001, volume))
	_dash_player.play(float(at.p))
	_dash_cur_url = str(at.u)
	_dash_cur_e = float(at.e)

func _dash_stop() -> void :
	_dash_fade_at = -1
	_dash_cur_url = ""
	_dash_cur_e = -1.0
	if _dash_player != null and _dash_player.playing:
		_dash_player.stop()
	if _dash_player2 != null and _dash_player2.playing:
		_dash_player2.stop()

static func _dash_loop(stream: AudioStream, on: bool) -> void :
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = on
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = on


func _dash_watch() -> void :
	if _dash_cur_url.is_empty() or _dash_cur_e < 0.0 or _dash_nxt.is_empty() or not _dash_cache.has(str(_dash_nxt.u)):
		return
	var volume: float = Settings.level("music_vol")
	var left: float = _dash_cur_e - _dash_player.get_playback_position() if _dash_player.playing else 0.0
	if _dash_fade_at < 0:
		if left > (DASH_FADE_S * 0.5 if bool(_dash_nxt.x) else 0.02):
			return
		var stream: AudioStream = _dash_cache[str(_dash_nxt.u)]
		_dash_loop(stream, false)
		_dash_player2.stream = stream
		if not bool(_dash_nxt.x):
			_dash_player2.volume_db = linear_to_db(maxf(0.0001, volume))
			_dash_player2.play(float(_dash_nxt.p))
			_dash_swap()
			return
		_dash_player2.volume_db = -80.0
		_dash_player2.play(maxf(0.0, float(_dash_nxt.p) - left))
		_dash_fade_at = Time.get_ticks_msec()
		return
	var k: float = (Time.get_ticks_msec() - _dash_fade_at) / (DASH_FADE_S * 1000.0)
	if k >= 1.0 or not _dash_player.playing:
		_dash_player2.volume_db = linear_to_db(maxf(0.0001, volume))
		_dash_swap()
		return
	_dash_player.volume_db = linear_to_db(maxf(0.0001, volume * (1.0 - k)))
	_dash_player2.volume_db = linear_to_db(maxf(0.0001, volume * k))

func _dash_swap() -> void :
	_dash_player.stop()
	var p: AudioStreamPlayer = _dash_player
	_dash_player = _dash_player2
	_dash_player2 = p
	_dash_cur_url = str(_dash_nxt.u)
	_dash_cur_e = -1.0
	_dash_nxt = {}
	_dash_fade_at = -1


func _dash_fetch() -> void :
	var want: Array[String] = []
	var ids: Array[String] = []
	var at: Dictionary = _dash_at()
	if not at.is_empty():
		want = [str(at.u), str(at.nu)]
		ids = [str(at.id), ""]
	elif float(_dash.start) / 1000.0 > _dash_now() and not _dash_bad.has(str(_dash.items[0].id)):
		want = [str(_dash_src(_dash.items[0], 0.0).u)]
		ids = [str(_dash.items[0].id)]
	if not _dash_getting.is_empty() and not want.has(_dash_getting):
		_dash_get.cancel_request()
		_dash_getting = ""
	if not _dash_getting.is_empty():
		return
	for idx in range(want.size()):
		var url: String = want[idx]
		if url.is_empty() or _dash_cache.has(url):
			continue
		if _dash_failed.has(url) and Time.get_ticks_msec() - int(_dash_failed[url]) < DASH_RETRY_MS:
			continue
		if _dash_get == null:
			_dash_get = HTTPRequest.new()
			_dash_get.timeout = 60.0
			_dash_get.body_size_limit = DASH_BODY_MAX
			_dash_get.request_completed.connect(_dash_fetched)
			add_child(_dash_get)
		if _dash_get.request(url, AppSession.headers(url)) == OK:
			_dash_getting = url
			_dash_getting_id = ids[idx] if not ids[idx].is_empty() else _dash_id_of(url)
		else:
			_dash_failed[url] = Time.get_ticks_msec()
		return


static func _dash_id_of(url: String) -> String:
	var tail: String = url.get_base_dir().get_file() if url.ends_with(".mp3") and url.get_base_dir().get_file().length() == 21 else url.get_file()
	return tail.substr(0, 16)

func _dash_fetched(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	var url: String = _dash_getting
	var id: String = _dash_getting_id
	_dash_getting = ""
	if url.is_empty():
		return
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty():
		_dash_failed[url] = Time.get_ticks_msec()
		if result == HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:
			_dash_bad[id] = true
		return
	var stream: AudioStream = AudioStreamOggVorbis.load_from_buffer(body) if url.ends_with(".ogg") else AudioStreamMP3.load_from_buffer(body)
	if stream == null or stream.get_length() <= 0.0:
		_dash_bad[id] = true
		return
	_dash_cache[url] = stream
	_dash_order.append(url)
	while _dash_order.size() > DASH_CACHE:
		var old: String = _dash_order.pop_front()
		if old == _dash_cur_url or ( not _dash_nxt.is_empty() and old == str(_dash_nxt.u)):
			_dash_order.append(old)
			if _dash_order[0] == old:
				break
			continue
		_dash_cache.erase(old)
	_dash_dirty = true



func _gain(volume: float) -> float:
	return clampf(volume, 0.0, 1.0) * Settings.level("sfx_vol") if Settings.on("sfx") else 0.0

func _play(key: String, volume: float) -> void :
	var gain: float = _gain(volume)
	if pack == null or gain <= 0.004:
		return
	var now: int = Time.get_ticks_msec()
	if now - int(_stamp.get(key, -100000)) < SAME_GAP_MS:
		return
	var stream: AudioStream = pack.sound("s/%s.mp3" % key)
	if stream == null:
		if not _wanted.has(key):
			_wanted[key] = [volume, now]
		return
	_stamp[key] = now
	_emit(stream, gain)

func _play_tracked(key: String, volume: float) -> Array:
	_last = -1
	_play(key, volume)
	return [_last, _gen[_last]] if _last >= 0 and _last < _gen.size() else []

func _cut(handle: Array) -> bool:
	if handle.size() != 2:
		return false
	var slot: int = int(handle[0])
	if slot < 0 or slot >= _players.size() or slot >= _gen.size() or _gen[slot] != int(handle[1]):
		return false
	var player: AudioStreamPlayer = _players[slot]
	_gen[slot] += 1
	if not player.playing:
		return false
	var fade: Tween = create_tween()
	fade.tween_property(player, "volume_db", -60.0, CUT_FADE)
	fade.tween_callback(player.stop)
	_fades[slot] = fade
	cuts += 1
	return true

func _click() -> void :
	var gain: float = _gain(0.5)
	if gain <= 0.004:
		return
	if _click_stream == null and pack != null and not pack.base.is_empty():
		_click_stream = pack.sound("s/u/click.mp3")
	_emit(_click_stream if _click_stream != null else _tick_sound, gain)

func _emit(stream: AudioStream, gain: float) -> void :
	var player: AudioStreamPlayer = null
	for candidate: AudioStreamPlayer in _players:
		if not candidate.playing:
			player = candidate
			break
	if player == null:
		player = _players[_next]
		_next = (_next + 1) % _players.size()
	var slot: int = _players.find(player)
	while _gen.size() < _players.size():
		_gen.append(0)
		_fades.append(null)
	if _fades[slot] is Tween and (_fades[slot] as Tween).is_valid():
		(_fades[slot] as Tween).kill()
	_fades[slot] = null
	_gen[slot] += 1
	_last = slot
	player.stream = stream
	player.volume_db = linear_to_db(maxf(0.0001, gain))
	player.play()
	played += 1


func _make_tick() -> AudioStreamWAV:
	var rate: int = 22050
	var count: int = int(rate * 0.05)
	var data: PackedByteArray = PackedByteArray()
	data.resize(count * 2)
	var phase: float = 0.0
	for i in range(count):
		var t: float = float(i) / rate
		phase += TAU * (1500.0 - 9000.0 * t) / rate
		var level: float = sin(phase) * exp( - t * 85.0) * minf(1.0, t * 1800.0) * 0.6
		data.encode_s16(i * 2, int(clampf(level, -1.0, 1.0) * 32767.0))
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav
