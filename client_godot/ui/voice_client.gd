extends Node


























const Settings = preload("res://settings.gd")
const MicEngine = preload("res://ui/mic_engine.gd")
const AndroidVoice = preload("res://net/android_voice.gd")
const PcVoice = preload("res://net/pc_voice.gd")

signal notice(text: String)
signal tea_voice(text: String)

const SDK_FILE: String = "w/voice/livekit-client.umd.min.js"
const SDK_HASH: String = "26d33bc6acdfd1402d1e960f3ec0f129a67a81ab6b6f9f77f63ee51009ce7519"
const MUTED_MAX: int = 200
const TICKET_CAP: int = 5
const SETTLE: float = 0.6
const RETRY: float = 2.0
const POLL_LIVE: float = 0.1
const POLL_IDLE: float = 0.5
const SPEAKERS: Array = ["all", "room", "off"]
const HIDE: Array = ["off", "auth", "banned", "unsup"]

const SOLO_ROOMS: Array = [3, 4, 8, 50, 51, 52, 53, 7, 14, 100, 101, 102]
const FREE_ROOM: int = 1
const OFF_AGAIN: float = 60.0
const OFF_MAX: int = 5
const NOROOM_AGAIN: float = 5.0
const PICK_KEY: int = -2
const MIC_HOLD_MS: int = 8000
const VoiceUI = preload("res://ui/voice_ui.gd")
const DOCK_FONT: Font = preload("res://assets/fonts/BeVietnamPro-Bold.ttf")
const DOCK_R: float = 12.5
const DOCK_HIT: float = 17.0
const DOCK_GAP: float = 35.0
const DOCK_HOLD: float = 0.3
const DOCK_TAG: Dictionary = {"all": "T", "room": "R", "off": ""}
const SPEAKER_TEXT: Dictionary = {"all": "Loa: Tất cả — nghe cả đội trong trận", "room": "Loa: Room — chỉ nghe tổ đội", "off": "Loa: Tắt"}
const JS: String = "(function () {\n\tif (window.__bbv) return;\n\tvar S = {sdk: '', hash: '', mic: false, mode: 'ptt', mute: false, talk: false, muted: {}, tmic: false, slot: 'room', deaf: {}, vol: 100};\n\t// st2: âm lượng nghe (S.vol 0–200 %). > 100 % cần webAudioMix (GainNode); Safari / iOS chưa ổn với webAudioMix → tối đa 100 %.\n\tvar MIX = !/^((?!chrome|android|crios|fxios|edg).)*safari/i.test(navigator.userAgent || '') && !!(window.AudioContext || window.webkitAudioContext);\n\tfunction vol1(t) { try { if (t && t.kind === 'audio' && t.setVolume) t.setVolume(MIX ? S.vol / 100 : Math.min(1, S.vol / 100)); } catch (e) {} }\n\tvar L = null, sdkP = null, slots = {}, ev = [], tx = null;\n\tfunction push(o) { if (ev.length < 40) ev.push(o); }\n\tfunction hex(b) {\n\t\tvar a = new Uint8Array(b), s = '';\n\t\tfor (var i = 0; i < a.length; i++) s += (a[i] < 16 ? '0' : '') + a[i].toString(16);\n\t\treturn s;\n\t}\n\tfunction micErr(e) { var n = e && e.name; return n === 'NotAllowedError' || n === 'SecurityError' ? 'deny' : 'nomic'; }\n\t// SDK trong gói: tải, kiểm SHA-256, chạy qua blob (UMD gán globalThis.LivekitClient). Không có crypto.subtle → không chạy.\n\tfunction sdk() {\n\t\tif (L) return Promise.resolve(L);\n\t\tif (sdkP) return sdkP;\n\t\tif (!S.sdk || !window.fetch || !window.crypto || !crypto.subtle || !window.Blob || !window.URL) return Promise.reject({code: 'unsup'});\n\t\tsdkP = fetch(S.sdk, {credentials: 'same-origin'}).then(function (r) {\n\t\t\tif (!r.ok) throw {code: 'sdk'};\n\t\t\treturn r.arrayBuffer();\n\t\t}).then(function (b) {\n\t\t\treturn crypto.subtle.digest('SHA-256', b).then(function (d) { if (hex(d) !== S.hash) throw {code: 'sdk'}; return b; });\n\t\t}).then(function (b) {\n\t\t\treturn new Promise(function (ok, no) {\n\t\t\t\tvar url = URL.createObjectURL(new Blob([b], {type: 'text/javascript'})), el = document.createElement('script');\n\t\t\t\tel.onload = function () {\n\t\t\t\t\tURL.revokeObjectURL(url); el.remove();\n\t\t\t\t\tvar lk = window.LivekitClient;\n\t\t\t\t\tif (lk && lk.Room) { L = lk; ok(L); } else no({code: 'sdk'});\n\t\t\t\t};\n\t\t\t\tel.onerror = function () { URL.revokeObjectURL(url); el.remove(); no({code: 'sdk'}); };\n\t\t\t\tel.src = url;\n\t\t\t\tdocument.head.appendChild(el);\n\t\t\t});\n\t\t}).then(function (lk) {\n\t\t\tif (lk.isBrowserSupported && !lk.isBrowserSupported()) throw {code: 'unsup'};\n\t\t\treturn lk;\n\t\t}).catch(function (e) { sdkP = null; L = null; throw {code: (e && e.code) || 'sdk'}; });\n\t\treturn sdkP;\n\t}\n\tvar PV = {tea: 1, kd: 1}; // kd1: slot riêng (mic tmic + loa riêng, chỉ một slot riêng mỗi lúc): tea = Phòng Trà, kd = Kỳ Đài\n\tfunction slot(s) { return slots[s] || (slots[s] = {seq: 0, st: '', room: null, track: null, pubing: false}); }\n\tfunction wantMic(my) {\n\t\tvar lp = my.room && my.room.localParticipant, can = !lp || !lp.permissions || lp.permissions.canPublish !== false;\n\t\t// ptc: mỗi lúc chỉ một slot phát mic (S.slot); slot tea có nút mic riêng (S.tmic).\n\t\t// vc2: ngoài Phòng Trà phát lên cả slot room và battle (tổ đội + cả phe trong trận).\n\t\treturn (S.slot === 'kd' ? my.s === 'kd' : my.s !== 'kd' && (S.slot === 'tea' ? my.s === 'tea' : my.s !== 'tea')) && (PV[my.s] ? S.tmic : S.mic) && S.mode !== 'off' && my.st === 'on' && can;\n\t}\n\t// vc2: người đã nghe ở slot room (tổ đội) thì slot battle không đăng ký lại (khỏi nghe hai lần).\n\tfunction dupe(s, p) {\n\t\tvar r = slots.room;\n\t\treturn s === 'battle' && !!r && r.st === 'on' && !!r.room && !!p && r.room.remoteParticipants.has(p.identity);\n\t}\n\tfunction using() { for (var k in slots) if (slots[k].track || slots[k].pubing) return true; return false; }\n\t// vgap1: hold(ms) — đổi kênh có hẹn ('moved' lúc ghép xong, room → chọn tank, tổng kết → room) giữ luồng mic ms mili giây dù chưa\n\t// slot nào phát: nhả rồi xin lại ngoài cú bấm làm AudioContext ngủ / trình duyệt hỏi lại quyền → mất mic. Mic tắt / chế độ Tắt → nhả.\n\tvar keepTo = 0, keepT = null;\n\tfunction keepOk() { return !!S.mic && S.mode !== 'off' && Date.now() < keepTo; }\n\tfunction letGo() {\n\t\tif (using() || !window.__bbmic) return;\n\t\tif (keepOk()) { if (!keepT) keepT = setTimeout(function () { keepT = null; letGo(); }, keepTo - Date.now() + 20); return; }\n\t\twindow.__bbmic.release('voice');\n\t}\n\t// Nhấn giữ: thả phím vẫn giữ mic 150 ms cho khỏi cụt chữ cuối. Mở liên tục: luôn bật (ngưỡng của mic1 cắt lúc im).\n\tfunction apply(my) {\n\t\tif (!my.track) return;\n\t\tvar on = !S.mute && (S.mode === 'open' || S.talk);\n\t\tif (on) { if (tx) { clearTimeout(tx); tx = null; } if (my.track.isMuted) my.track.unmute().catch(function () {}); }\n\t\telse if (!my.track.isMuted && !tx) {\n\t\t\ttx = setTimeout(function () {\n\t\t\t\ttx = null;\n\t\t\t\tfor (var k in slots) {\n\t\t\t\t\tvar t = slots[k].track;\n\t\t\t\t\tif (t && !t.isMuted && !(!S.mute && (S.mode === 'open' || S.talk))) t.mute().catch(function () {});\n\t\t\t\t}\n\t\t\t}, S.mode === 'ptt' && !S.mute ? 150 : 0);\n\t\t}\n\t}\n\tfunction unpub(my) {\n\t\tvar t = my.track;\n\t\tmy.track = null;\n\t\tif (t && my.room) my.room.localParticipant.unpublishTrack(t, true).catch(function () {});\n\t\tif (t) try { t.stop(); } catch (e) {}\n\t}\n\tfunction publish(my) {\n\t\tvar seq = my.seq;\n\t\tmy.pubing = true;\n\t\tif (!window.__bbmic) { my.pubing = false; push({t: 'mic', err: 'nomic'}); return; }\n\t\twindow.__bbmic.acquire('voice').then(function (stream) {\n\t\t\tvar src = stream && stream.getAudioTracks()[0];\n\t\t\tif (!src) throw {name: 'NotFoundError'};\n\t\t\tif (my.seq !== seq || !wantMic(my)) { my.pubing = false; letGo(); return; }\n\t\t\tvar t = new L.LocalAudioTrack(src.clone(), undefined, true);\n\t\t\treturn my.room.localParticipant.publishTrack(t, {source: L.Track.Source.Microphone, name: 'mic', dtx: true, red: false,\n\t\t\t\taudioPreset: L.AudioPresets.speech, stopMicTrackOnMute: false}).then(function () {\n\t\t\t\tmy.pubing = false;\n\t\t\t\tmy.track = t;\n\t\t\t\tif (my.seq !== seq || !wantMic(my)) { unpub(my); letGo(); return; }\n\t\t\t\tt.mute().then(function () { apply(my); }, function () { apply(my); });\n\t\t\t}, function () { my.pubing = false; try { t.stop(); } catch (e) {} letGo(); push({t: 'fail', s: my.s, code: 'pub'}); });\n\t\t}, function (e) {\n\t\t\tmy.pubing = false;\n\t\t\tif (my.seq === seq) push({t: 'mic', err: micErr(e)});\n\t\t\tletGo();\n\t\t});\n\t}\n\tfunction sync() {\n\t\tfor (var k in slots) {\n\t\t\tvar my = slots[k];\n\t\t\tif (wantMic(my)) { if (!my.track && !my.pubing) publish(my); else apply(my); }\n\t\t\telse if (my.track) { unpub(my); }\n\t\t}\n\t\tletGo();\n\t}\n\tfunction hear(my) {\n\t\tif (!my.room) return;\n\t\tmy.room.remoteParticipants.forEach(function (p) {\n\t\t\tvar off = !!S.muted[p.identity] || !!S.deaf[my.s] || dupe(my.s, p);\n\t\t\tp.audioTrackPublications.forEach(function (pub) {\n\t\t\t\tif (pub.isSubscribed === off || (off && pub.isDesired)) pub.setSubscribed(!off);\n\t\t\t\tif (!off && pub.track) vol1(pub.track);\n\t\t\t});\n\t\t});\n\t}\n\tfunction hearAll() { for (var k in slots) hear(slots[k]); }\n\tfunction drop(my) {\n\t\tmy.seq++;\n\t\tvar room = my.room;\n\t\tunpub(my);\n\t\tmy.room = null; my.st = '';\n\t\tif (room) room.disconnect(true).catch(function () {});\n\t\tdocument.querySelectorAll('audio[data-bbv=\"' + my.s + '\"]').forEach(function (el) { el.remove(); });\n\t\thearAll();\n\t}\n\tfunction join(s, url, token) {\n\t\tvar my = slot(s);\n\t\tmy.s = s;\n\t\tdrop(my);\n\t\tvar seq = my.seq;\n\t\tmy.st = 'join';\n\t\tsdk().then(function (lk) {\n\t\t\tif (my.seq !== seq) return;\n\t\t\tvar E = lk.RoomEvent, room = new lk.Room({adaptiveStream: false, dynacast: false, disconnectOnPageLeave: true, webAudioMix: MIX});\n\t\t\tmy.room = room;\n\t\t\troom.on(E.TrackSubscribed, function (track, pub, p) {\n\t\t\t\tif (my.room !== room || track.kind !== 'audio') return;\n\t\t\t\tif (S.muted[p.identity] || S.deaf[s] || dupe(s, p)) { pub.setSubscribed(false); return; }\n\t\t\t\tvar el = track.attach();\n\t\t\t\tvol1(track);\n\t\t\t\tel.setAttribute('data-bbv', s);\n\t\t\t\tel.style.display = 'none';\n\t\t\t\tdocument.body.appendChild(el);\n\t\t\t});\n\t\t\troom.on(E.TrackUnsubscribed, function (track) { track.detach().forEach(function (el) { el.remove(); }); });\n\t\t\troom.on(E.TrackPublished, function (pub, p) { if (S.muted[p.identity] || S.deaf[s] || dupe(s, p)) pub.setSubscribed(false); });\n\t\t\troom.on(E.ParticipantConnected, function () { if (my.room === room && s === 'room') hearAll(); });\n\t\t\troom.on(E.ParticipantDisconnected, function () { if (my.room === room && s === 'room') hearAll(); });\n\t\t\troom.on(E.ParticipantPermissionsChanged, function (prev, p) {\n\t\t\t\tif (my.room !== room || !p || p !== room.localParticipant) return;\n\t\t\t\tvar can = !(p.permissions && p.permissions.canPublish === false);\n\t\t\t\tif (PV[s]) { if (!can) { unpub(my); letGo(); } push({t: 'can', s: s, v: can ? 1 : 0}); sync(); }\n\t\t\t\telse if (!can) { unpub(my); letGo(); push({t: 'lock'}); }\n\t\t\t\telse sync();\n\t\t\t});\n\t\t\troom.on(E.Disconnected, function () {\n\t\t\t\tif (my.room !== room) return;\n\t\t\t\tunpub(my); my.room = null; my.st = ''; letGo(); hearAll();\n\t\t\t\tpush({t: 'gone', s: s});\n\t\t\t});\n\t\t\treturn room.connect(url, token, {autoSubscribe: true}).then(function () {\n\t\t\t\tif (my.seq !== seq || my.room !== room) { room.disconnect(true).catch(function () {}); return; }\n\t\t\t\tmy.st = 'on';\n\t\t\t\tpush({t: 'on', s: s});\n\t\t\t\troom.startAudio().catch(function () {});\n\t\t\t\thearAll();\n\t\t\t\tsync();\n\t\t\t});\n\t\t}).catch(function (e) {\n\t\t\tif (my.seq !== seq) return;\n\t\t\tvar room = my.room;\n\t\t\tmy.room = null; my.st = '';\n\t\t\tif (room) room.disconnect(true).catch(function () {});\n\t\t\tpush({t: 'fail', s: s, code: (e && e.code) || 'net'});\n\t\t});\n\t}\n\tfunction json(r) {\n\t\treturn r.json().catch(function () { return {ok: false, code: r.status === 401 || r.status === 403 ? 'auth' : (r.status === 429 ? 'rate' : 'net')}; });\n\t}\n\tfunction resume() {\n\t\tfor (var k in slots) if (slots[k].room && slots[k].st === 'on') slots[k].room.startAudio().catch(function () {});\n\t}\n\twindow.__bbv = {\n\t\tcfg: function (o) {\n\t\t\tfor (var k in o) if (Object.prototype.hasOwnProperty.call(S, k)) S[k] = o[k];\n\t\t\tfor (var s in slots) hear(slots[s]);\n\t\t\tsync();\n\t\t\tif (keepT && !keepOk()) { clearTimeout(keepT); keepT = null; letGo(); } // vgap1: mic vừa tắt / chế độ Tắt → thôi giữ\n\t\t},\n\t\tticket: function (s, go) {\n\t\t\ts = s === 'battle' || PV[s] ? s : 'room';\n\t\t\tfetch('/api/voice/ticket?scope=' + s, {method: 'POST', credentials: 'same-origin', cache: 'no-store'}).then(json).then(function (j) {\n\t\t\t\tif (!j || j.ok !== true || typeof j.url !== 'string' || typeof j.token !== 'string') {\n\t\t\t\t\treturn push({t: 'tk', s: s, ok: 0, code: String((j && j.code) || 'net')});\n\t\t\t\t}\n\t\t\t\tpush({t: 'tk', s: s, ok: 1, lock: Number(j.micLockedUntil) || 0, seat: Number(j.seat) || 0});\n\t\t\t\tif (go) join(s, j.url, j.token);\n\t\t\t}, function () { push({t: 'tk', s: s, ok: 0, code: 'net'}); });\n\t\t},\n\t\tleave: function (s) { if (slots[s]) drop(slots[s]); letGo(); },\n\t\thold: function (ms) { keepTo = ms > 0 ? Date.now() + ms : 0; if (keepT) { clearTimeout(keepT); keepT = null; } letGo(); }, // vgap1\n\t\treport: function (id) {\n\t\t\tfetch('/api/voice/report?char=' + encodeURIComponent(String(id)), {method: 'POST', credentials: 'same-origin', cache: 'no-store'})\n\t\t\t\t.then(json).then(function (j) { push({t: 'rep', id: id, ok: j && j.ok === true ? 1 : 0, code: String((j && j.code) || '')}); },\n\t\t\t\tfunction () { push({t: 'rep', id: id, ok: 0, code: 'net'}); });\n\t\t},\n\t\tplay: resume,\n\t\tperm: function () {\n\t\t\tvar q = navigator.permissions && navigator.permissions.query;\n\t\t\tif (!q) return push({t: 'perm', st: ''});\n\t\t\ttry {\n\t\t\t\tnavigator.permissions.query({name: 'microphone'}).then(function (p) { push({t: 'perm', st: String(p.state)}); },\n\t\t\t\t\tfunction () { push({t: 'perm', st: ''}); });\n\t\t\t} catch (e) { push({t: 'perm', st: ''}); }\n\t\t},\n\t\tpoll: function () {\n\t\t\tvar o = ev;\n\t\t\tev = [];\n\t\t\tvar r = {st: {}, pub: 0, tx: 0, me: 0, ps: [], play: 1, ev: o, by: {}};\n\t\t\tfor (var k in slots) {\n\t\t\t\tvar my = slots[k];\n\t\t\t\tr.st[k] = my.st;\n\t\t\t\tif (!my.room || my.st !== 'on') continue;\n\t\t\t\tvar b = r.by[k] = [my.track ? 1 : 0, my.track && !my.track.isMuted ? 1 : 0, my.room.localParticipant.isSpeaking ? 1 : 0];\n\t\t\t\tif (!PV[k]) { if (b[0]) r.pub = 1; if (b[1]) r.tx = 1; if (b[2]) r.me = 1; }\n\t\t\t\tif (!my.room.canPlaybackAudio) r.play = 0;\n\t\t\t\tmy.room.remoteParticipants.forEach(function (p) {\n\t\t\t\t\tvar talk = p.isSpeaking ? 1 : 0;\n\t\t\t\t\tr.ps.push([String(p.identity), Math.round((p.audioLevel || 0) * 100) / 100, talk, k]);\n\t\t\t\t});\n\t\t\t}\n\t\t\treturn JSON.stringify(r);\n\t\t}\n\t};\n\t['pointerdown', 'keydown', 'touchend'].forEach(function (n) { window.addEventListener(n, resume, true); });\n})();"























































































































































































































































static var bridge: Callable
static var calls: Array = []
static var store_path: String = "user://voice.cfg"
static var _shared: Variant = null

var client: Object = null
var speaker: String = "room"
var speaker_last: String = "room"
var mic_on: bool = false
var muted: Dictionary = {}
var available: int = -1
var state: String = ""
var publishing: bool = false
var sending: bool = false
var me_talking: bool = false
var can_play: bool = true
var locked_until: int = 0
var talking: bool = false
var touch_hold: bool = false
var peers: Dictionary = {}
var installed: bool = false

var tea_state: String = ""
var tea_scope: String = "tea"
var tea_mic: bool = false
var tea_deaf: bool = false
var tea_can: bool = false
var tea_publishing: bool = false
var tea_sending: bool = false
var tea_me_talking: bool = false
var tea_peers: Dictionary = {}
var tea_ok: bool = true
var _tea_want: bool = false
var _tea_retry_at: float = -1.0
var _tea_retried: bool = false

var bstate: String = ""
var _battle_key: int = -1
var _battle_ok: bool = true
var _battle_asked: bool = false
var _battle_at: float = 0.0
var _battle_retry_at: float = -1.0
var _battle_retried: bool = false
var _battle_join: bool = false
var _battle_wanted: bool = false
var _battle_off_n: int = 0

var _hide: String = ""
var _off_at: float = -1000.0
var _off_n: int = 0

var _room_id: int = 0
var _room_ok: bool = true
var _probed: int = 0
var _key: String = ""
var _key_at: float = 0.0
var _asked: String = ""
var _retry_at: float = -1.0
var _retried: bool = false
var _tickets: Array = []
var _now: float = 0.0
var _poll_at: float = -1000.0
var _perm_asked: bool = false
var _loaded: bool = false
var _granted: bool = false
var dock_hold_at: float = -1.0
var _dock_key: Array = [-1, ""]

static func shared() -> Variant:
	if _shared == null or not is_instance_valid(_shared):
		_shared = load("res://ui/voice_client.gd").new()
		var tree: SceneTree = Engine.get_main_loop() as SceneTree
		if tree != null and tree.root != null:
			tree.root.add_child.call_deferred(_shared)
	return _shared


static func reset() -> void :
	if _shared != null and is_instance_valid(_shared):
		if _shared.is_inside_tree():
			_shared.get_parent().remove_child(_shared)
		_shared.free()
	_shared = null
	bridge = Callable()
	calls = []
	store_path = "user://voice.cfg"

static func usable() -> bool:
	_link()
	return bridge.is_valid() or OS.has_feature("web")


static func _link() -> void :
	if not bridge.is_valid() and AndroidVoice.is_android():
		bridge = AndroidVoice.bridge()
	elif not bridge.is_valid() and PcVoice.is_pc():
		bridge = PcVoice.bridge()

static func _js(code: String) -> Variant:
	_link()
	if bridge.is_valid():
		calls.append(code)
		return bridge.call(code)
	if OS.has_feature("web"):
		return JavaScriptBridge.eval(code, true)
	return null

func _init() -> void :
	name = "Voice"
	_load()
	Settings.watch(_on_setting)



func _load() -> void :
	if _loaded:
		return
	_loaded = true
	var file: ConfigFile = ConfigFile.new()
	if file.load(store_path) != OK:
		return
	var spk: String = str(file.get_value("v", "spk", "room"))
	speaker = spk if spk in SPEAKERS else "room"
	var last: String = str(file.get_value("v", "spk_last", "room"))
	speaker_last = last if last in ["all", "room"] else "room"
	mic_on = file.get_value("v", "mic", false) == true
	muted = {}
	var ids: Variant = file.get_value("v", "muted", [])
	if ids is Array:
		for id: Variant in ids:
			if (id is int or id is float) and int(id) > 0 and muted.size() < MUTED_MAX:
				muted[int(id)] = true

func _save() -> void :
	var file: ConfigFile = ConfigFile.new()
	file.set_value("v", "spk", speaker)
	file.set_value("v", "spk_last", speaker_last)
	file.set_value("v", "mic", mic_on)
	var ids: Array = muted.keys()
	file.set_value("v", "muted", ids.slice(maxi(0, ids.size() - MUTED_MAX)))
	file.save(store_path)





func eligible() -> bool:
	if client == null or str(client.get("state")) != "room":
		return false
	var room_state: Variant = client.get("room_state")
	if room_state == null or room_state.room.is_empty():
		return false
	if client.has_method("pve_room") and client.call("pve_room"):
		return false
	var observers: Variant = client.get("room_observers")
	return not (observers is Dictionary and observers.has(room_state.self_id))


func shown() -> bool:
	return available == 1 and _room_ok and eligible() and usable()

func connected() -> bool:
	return state == "on"


func battle_room() -> bool:
	if client == null or str(client.get("state")) != "battle":
		return false
	var battle: Variant = client.get("battle")
	if battle == null or bool(battle.get("look")) or bool(battle.get("ended")):
		return false
	var kind: int = int(battle.get("room_type"))
	return kind > 0 and not kind in SOLO_ROOMS


func battle_shown() -> bool:
	if available != 1 or not usable() or not battle_room():
		return false
	if int(client.battle.room_type) == FREE_ROOM:
		return state != ""
	return _battle_ok or state != "" or bstate != ""



func pick_room() -> bool:
	if client == null or not client.has_method("can_pick_tank") or not client.can_pick_tank():
		return false
	var scene: Variant = client.get("pair_scene")
	var kind: int = int(scene.get("type", 0)) if scene is Dictionary else 0
	return kind > 0 and kind != FREE_ROOM and not kind in SOLO_ROOMS


func pick_shown() -> bool:
	return available == 1 and usable() and pick_room() and (_battle_ok or bstate != "")



func result_room() -> bool:
	if client == null or str(client.get("state")) != "battle":
		return false
	var battle: Variant = client.get("battle")
	if battle == null or bool(battle.get("look")) or not bool(battle.get("ended")):
		return false
	var kind: int = int(battle.get("room_type"))
	return kind > 0 and not kind in SOLO_ROOMS


func result_shown() -> bool:
	if available != 1 or not usable() or not result_room():
		return false
	if int(client.battle.room_type) == FREE_ROOM:
		return state != ""
	return _battle_ok or state != "" or bstate != ""


func _fight_type() -> int:
	if battle_room() or result_room():
		return int(client.battle.room_type)
	if pick_room():
		return int(client.pair_scene.get("type", 0))
	return 0


func battle_connected() -> bool:
	return bstate == "on"


func attach(game: Object) -> void :
	if game == null:
		return
	if client != game:
		client = game
	if game.has_signal("voice_notice") and not game.voice_notice.is_connected(on_notice):
		game.voice_notice.connect(on_notice)


func cycle_speaker() -> void :
	var at: int = SPEAKERS.find(speaker)
	set_speaker(str(SPEAKERS[(at + 1) % SPEAKERS.size()]))
	_say(str(SPEAKER_TEXT.get(speaker, "")))

func mic_mode() -> String:
	return str(Settings.value("mic_mode"))


func mic_state() -> String:
	if not mic_on or not _granted or mic_mode() == "off" or is_locked():
		return "off"
	if publishing and (sending and (me_talking or talking)):
		return "talk"
	return "on"

func is_locked() -> bool:
	return locked_until > int(Time.get_unix_time_from_system())

func is_muted(id: int) -> bool:
	return muted.has(id)


func in_voice(id: int) -> bool:
	return peers.has(id)

func is_talking(id: int) -> bool:
	if client != null and id == int(client.room_state.self_id):
		return mic_state() == "talk"
	return peers.has(id) and bool(peers[id][1]) and not muted.has(id)



func set_speaker(mode: String) -> void :
	if not mode in SPEAKERS:
		return
	_install()
	_js("window.__bbv.play()")
	if mode == speaker:
		return
	speaker = mode
	if mode != "off":
		speaker_last = mode
	_save()
	if mode == "off":
		_leave()
		_battle_leave()
		_free_mic()
	else:
		_asked = ""
		_key_at = -1000.0
		_battle_asked = false
		_battle_at = -1000.0

func toggle_mic() -> void :
	if mic_mode() == "off" and not mic_on:
		_say("Chế độ mic đang Tắt — chọn Nhấn giữ hoặc Mở liên tục trong Cài đặt → MICRO.")
		return
	if is_locked() and not mic_on:
		_say("Mic của bạn tạm bị khoá do nhiều tố cáo")
		return
	if not (mic_on and _granted) and not AndroidVoice.mic_ready(toggle_mic, _mic_denied):
		return
	mic_on = not (mic_on and _granted)
	if mic_on:
		_granted = true
	else:
		talking = false
	_save()
	if mic_on and speaker == "off":
		set_speaker(speaker_last)
	_install()
	_js("window.__bbv.play()")
	_push()


func _mic_denied() -> void :
	mic_on = false
	_granted = false
	talking = false
	_save()
	_push()
	_say(AndroidVoice.DENIED_TEXT)

func toggle_mute(id: int) -> void :
	if id <= 0:
		return
	if muted.has(id):
		muted.erase(id)
	elif muted.size() < MUTED_MAX:
		muted[id] = true
	else:
		_say("Danh sách tắt tiếng đã đầy (%d người)." % MUTED_MAX)
		return
	_save()
	_push()

func report(id: int) -> void :
	if id <= 0 or not installed:
		return
	_js("window.__bbv.report(%d)" % id)
	_poll_at = -1000.0


func set_talk(on: bool) -> void :
	if on == talking:
		return
	talking = on
	if installed:
		_push()




func hold_talk(on: bool) -> void :
	if not on:
		if touch_hold:
			touch_hold = false
			set_talk(false)
		return
	if mic_mode() != "ptt":
		return
	if not (mic_on and _granted):
		toggle_mic()
		if not (mic_on and _granted):
			return
	touch_hold = true
	set_talk(true)



func _input(event: InputEvent) -> void :
	if not event is InputEventKey or event.echo or not (mic_on or tea_mic) or mic_mode() != "ptt":
		return
	var key: InputEventKey = event
	var code: int = key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
	if code != int(Settings.value("mic_ptt_key")):
		return
	if key.pressed:
		if _typing() or not ((mic_on and (state == "on" or bstate == "on")) or (tea_mic and tea_state == "on")):
			return
		set_talk(true)
	else:
		set_talk(false)

func _typing() -> bool:
	var focus: Control = get_viewport().gui_get_focus_owner() if get_viewport() != null else null
	return focus is LineEdit or focus is TextEdit

func _notification(what: int) -> void :
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		touch_hold = false
		set_talk(false)

func _process(delta: float) -> void :
	_now += delta
	poll()
	if _tea_retry_at >= 0.0 and _now >= _tea_retry_at:
		_tea_retry_at = -1.0
		if _tea_want and tea_state == "":
			_tea_ticket()
	if touch_hold and not battle_room() and not pick_room():
		hold_talk(false)
	if client == null:
		return
	var where: String = str(client.get("state"))
	_battle_tick()
	if where == "battle" and state != "":
		return
	if not eligible():
		if state != "" or _key != "":
			_leave()
		_key = ""
		_asked = ""
		_retry_at = -1.0
		if where != "battle":
			_room_id = 0
			if _hide == "off":
				_probed = 0
		return
	var room_state: Variant = client.room_state
	var room_id: int = int(room_state.room.get("m_nRoomId", 0))
	if room_id != _room_id:
		_room_id = room_id
		_room_ok = true
		_retried = false
		_off_n = 0
	var key: String = room_key()
	if key != _key:
		_key = key
		_key_at = _now
		_retried = false
	if _retry_at >= 0.0 and _now >= _retry_at:
		_retry_at = -1.0
		_asked = ""
	if available == 0 and _hide == "off" and _probed == _room_id and _off_n < OFF_MAX and _now - _off_at >= OFF_AGAIN:
		_off_n += 1
		_off_at = _now
		_probed = 0
		_asked = ""
	if key != _asked and _now - _key_at >= SETTLE:
		_decide()


func room_key() -> String:
	var room_state: Variant = client.room_state
	var mine: int = _camp_of(room_state.members.get(room_state.self_id, {}))
	var same: int = 0
	for id: Variant in room_state.members:
		if _camp_of(room_state.members[id]) == mine:
			same += 1
	return "%d:%d:%d" % [int(room_state.room.get("m_nRoomId", 0)), mine, 1 if same >= 2 else 0]

static func _camp_of(member: Variant) -> int:
	if not member is Dictionary:
		return 1
	return 2 if int(member.get("data", {}).get("bCamp", 1)) == 2 else 1

func _decide() -> void :
	var want: bool = speaker != "off" and _key.ends_with(":1") and _room_ok
	if available != 1:
		if _probed == _room_id or not usable():
			_asked = _key
			return
		if not _ticket(want):
			return
		_probed = _room_id
		_asked = _key
		return
	if want:
		if _ticket(true):
			_asked = _key
		return
	_asked = _key
	if state != "":
		_leave()


func _ticket(join: bool) -> bool:
	if not _take_ticket():
		_retry_at = float(_tickets[0]) + 60.05
		_asked = _key
		return false
	_install()
	if join:
		state = "join"
	_js("window.__bbv.ticket('room', %s)" % ("true" if join else "false"))
	_poll_at = -1000.0
	return true


func _take_ticket() -> bool:
	var cut: float = _now - 60.0
	while not _tickets.is_empty() and float(_tickets[0]) < cut:
		_tickets.pop_front()
	if _tickets.size() >= TICKET_CAP:
		return false
	_tickets.append(_now)
	return true

func _leave() -> void :
	if installed and state != "":
		_hold_mic()
		_js("window.__bbv.leave('room')")
	state = ""
	publishing = false
	sending = false
	me_talking = false
	peers = {}
	_retry_at = -1.0


func _hide_all(code: String) -> void :
	available = 0
	_hide = code
	_off_at = _now
	_leave()
	_battle_leave()
	_free_mic()




func _battle_tick() -> void :
	var fight: bool = battle_room() or result_room()
	if not fight and not pick_room():
		if bstate != "" or _battle_join:
			_battle_leave()
		_battle_key = -1
		return
	var battle: Variant = client.battle
	var key: int = int(battle.begun) if fight else PICK_KEY
	if key != _battle_key and _battle_key == PICK_KEY and fight and (bstate != "" or _battle_join):
		_battle_key = key
	if key != _battle_key:
		if bstate != "":
			_battle_leave()
		_battle_key = key
		_battle_ok = true
		_battle_asked = false
		_battle_retried = false
		_battle_retry_at = -1.0
		_battle_off_n = 0
		_battle_at = _now
	if fight and not bool(battle.started):
		_battle_at = _now
		return
	if _battle_retry_at >= 0.0 and _now >= _battle_retry_at:
		_battle_retry_at = -1.0
		_battle_asked = false
	if _battle_asked and available == 1 and _battle_retry_at < 0.0 and _battle_want() != _battle_wanted:
		_battle_asked = false
	if available == 0 and _hide == "off" and _battle_asked and _battle_off_n < OFF_MAX and _now - _off_at >= OFF_AGAIN:
		_battle_off_n += 1
		_off_at = _now
		_battle_asked = false
	if _battle_asked or _now - _battle_at < SETTLE:
		return
	_battle_decide()


func _battle_want() -> bool:
	if speaker == "off" or not _battle_ok or not (battle_room() or pick_room() or result_room()) or _fight_type() == FREE_ROOM:
		return false
	return speaker == "all" or state == ""

func _battle_decide() -> void :
	_battle_asked = true
	var want: bool = _battle_want()
	_battle_wanted = want
	if available == 1:
		if want and bstate == "":
			_battle_ticket(true)
		elif not want and bstate != "":
			_battle_leave()
		return
	if not usable() or (available == 0 and _hide != "off"):
		return
	if want:
		_battle_ticket(true)
	elif available == -1 and speaker != "off" and _battle_ok and _fight_type() != FREE_ROOM:
		_battle_ticket(false)

func _battle_ticket(join: bool) -> bool:
	if not _take_ticket():
		_battle_retry_at = float(_tickets[0]) + 60.05
		return false
	_install()
	if join:
		bstate = "join"
		_battle_join = true
	_js("window.__bbv.ticket('battle', %s)" % ("true" if join else "false"))
	_poll_at = -1000.0
	return true

func _battle_leave() -> void :
	if installed and (bstate != "" or _battle_join):
		_hold_mic()
		_js("window.__bbv.leave('battle')")
	bstate = ""
	_battle_join = false
	_battle_retry_at = -1.0





func _hold_mic() -> void :
	if installed and mic_on and _granted and speaker != "off":
		_js("window.__bbv.hold&&window.__bbv.hold(%d)" % MIC_HOLD_MS)


func _free_mic() -> void :
	if installed:
		_js("window.__bbv.hold&&window.__bbv.hold(0)")


func dock_shown(where: String) -> bool:
	return result_shown() if where == "result" else shown()



func dock_draw(screen: CanvasItem, where: String, mic_at: Vector2) -> Dictionary:
	if not dock_shown(where):
		dock_release()
		return {}
	if dock_hold_at >= 0.0 and not bool(screen.get("_held")):
		dock_release()
	var f: float = float(screen.get("_f"))
	var mic: Vector2 = mic_at * f
	var spk: Vector2 = (mic_at + Vector2(DOCK_GAP, 0.0)) * f
	var rad: float = DOCK_R * f
	var half: Vector2 = Vector2(DOCK_HIT, DOCK_HIT) * f
	var hover: String = str(screen.get("_hover"))
	var press: String = str(screen.get("_press"))
	var st: String = mic_state()
	var tag: String = ""
	if st != "off" and mic_mode() == "ptt" and not bool(screen.get("_mobile")):
		var code: int = int(Settings.value("mic_ptt_key"))
		if code != int(_dock_key[0]):
			_dock_key = [code, str(load("res://ui/settings.gd").ptt_name(code))]
		tag = str(_dock_key[1])
	VoiceUI.button(screen, mic, rad, "mic_off" if st == "off" else "mic", st, tag, DOCK_FONT, f, hover == "voice:mic", press == "voice:mic")
	var icon: String = "spk_off" if speaker == "off" else ("spk" if speaker == "all" else "spk_room")
	VoiceUI.button(screen, spk, rad, icon, "off" if speaker == "off" else "on", str(DOCK_TAG.get(speaker, "")), DOCK_FONT, f, 
		hover == "voice:spk", press == "voice:spk")
	var rects: Dictionary = {"mic": Rect2(mic - half, half * 2.0), "spk": Rect2(spk - half, half * 2.0)}
	screen.call("_hit", "voice:mic", rects["mic"], false)
	screen.call("_hit", "voice:spk", rects["spk"], false)
	return rects


func dock_click(id: String) -> bool:
	if id == "voice:mic":
		toggle_mic()
	elif id == "voice:spk":
		cycle_speaker()
	return id == "voice:mic" or id == "voice:spk"



func dock_touch(screen: CanvasItem, where: String, event: InputEvent) -> void :
	if not bool(screen.get("_mobile")) or not event is InputEventMouseButton:
		return
	var button: InputEventMouseButton = event
	if button.button_index != MOUSE_BUTTON_LEFT:
		return
	var now: float = float(screen.get("_time"))
	if button.pressed:
		if str(screen.call("_hit_at", button.position)) == "voice:mic" and dock_shown(where) and mic_state() != "off" and mic_mode() == "ptt":
			dock_hold_at = now
			set_talk(true)
	elif dock_hold_at >= 0.0:
		var long: bool = now - dock_hold_at > DOCK_HOLD
		dock_release()
		if long:
			screen.set("_press", "")


func dock_release() -> void :
	if dock_hold_at >= 0.0:
		set_talk(false)
	dock_hold_at = -1.0

func _install() -> void :
	if installed or not usable():
		return
	installed = true
	MicEngine.shared().prepare()
	_js(JS)
	_push()
	if mic_on and not _perm_asked:
		_perm_asked = true
		_js("window.__bbv.perm()")

func config() -> Dictionary:
	var ids: Dictionary = {}
	for id: int in muted:
		ids["c%d" % id] = 1
	return {"sdk": _sdk_url(), "hash": SDK_HASH, "mic": mic_on and _granted and not is_locked(), "mode": mic_mode(), 
		"mute": Settings.on("mic_mute"), "talk": talking, "muted": ids, 
		"tmic": tea_mic and _granted and not is_locked(), "slot": mic_slot(), "deaf": {tea_scope: 1} if tea_deaf else {}, 
		"vol": int(Settings.value("voice_play_vol"))}


func mic_slot() -> String:
	return tea_scope if _tea_want or tea_state != "" else "room"

func _push() -> void :
	if installed:
		_js("window.__bbv.cfg(%s)" % JSON.stringify(config()))

func _on_setting(key: String) -> void :
	if key.is_empty() or key.begins_with("mic_") or key == "voice_play_vol":
		if key == "mic_mode" or key.is_empty():
			talking = false
		_push()

func _sdk_url() -> String:
	var found: Object = MicEngine.pack
	if found == null:
		found = MicEngine.shared()._find_pack()
	if found != null and found.has_method("url"):
		return str(found.call("url", SDK_FILE))
	return "a/" + SDK_FILE


func poll() -> void :
	if not installed:
		return
	if _now - _poll_at < (POLL_LIVE if state != "" or tea_state != "" or bstate != "" else POLL_IDLE):
		return
	_poll_at = _now
	var raw: String = str(_js("window.__bbv?window.__bbv.poll():''"))
	if raw.is_empty():
		return
	var data: Variant = JSON.parse_string(raw)
	if not data is Dictionary:
		return
	var st: Variant = data.get("st", {})
	var room_st: String = str(st.get("room", "")) if st is Dictionary else ""
	if state == "on" and room_st != "on":
		state = room_st
	elif room_st == "on":
		state = "on"
	var battle_st: String = str(st.get("battle", "")) if st is Dictionary else ""
	if bstate == "on" and battle_st != "on":
		bstate = battle_st
	elif battle_st == "on":
		bstate = "on"
	publishing = int(data.get("pub", 0)) == 1
	sending = int(data.get("tx", 0)) == 1
	me_talking = int(data.get("me", 0)) == 1
	can_play = int(data.get("play", 1)) == 1
	var tea_st: String = str(st.get(tea_scope, "")) if st is Dictionary else ""
	if tea_state == "on" and tea_st != "on":
		tea_state = tea_st
	elif tea_st == "on":
		tea_state = "on"
	var by: Variant = data.get("by", {})
	var tea_by: Variant = by.get(tea_scope, []) if by is Dictionary else []
	var tea_ok_row: bool = tea_by is Array and tea_by.size() >= 3
	tea_publishing = tea_ok_row and int(tea_by[0]) == 1
	tea_sending = tea_ok_row and int(tea_by[1]) == 1
	tea_me_talking = tea_ok_row and int(tea_by[2]) == 1
	peers = {}
	tea_peers = {}
	for row: Variant in data.get("ps", []):
		if row is Array and row.size() >= 3:
			var who: String = str(row[0])
			if who.begins_with("c") and who.substr(1).is_valid_int():
				var into: Dictionary = tea_peers if row.size() >= 4 and str(row[3]) == tea_scope else peers
				into[int(who.substr(1))] = [clampf(float(row[1]), 0.0, 1.0), int(row[2]) == 1]
	for item: Variant in data.get("ev", []):
		if item is Dictionary:
			_event(item)

func _event(item: Dictionary) -> void :
	if str(item.get("s", "")) in ["tea", "kd"]:
		if str(item.get("s", "")) == tea_scope:
			_tea_event(item)
		elif str(item.get("t", "")) == "tk" and int(item.get("ok", 0)) == 1:
			_js("window.__bbv.leave('%s')" % str(item.get("s", "")))
		return
	if str(item.get("s", "")) == "battle":
		_battle_event(item)
		return
	match str(item.get("t", "")):
		"tk":
			if int(item.get("ok", 0)) == 1:
				available = 1
				_room_ok = true
				_hide = ""
				var lock: int = int(item.get("lock", 0))
				if lock > 0:
					locked_until = lock
				return
			if state == "join":
				state = ""
			_ticket_failed(str(item.get("code", "")))
		"on":
			state = "on"
			_retried = false
		"gone":
			state = ""
			publishing = false
			peers = {}
			if eligible() and speaker != "off" and not _retried:
				_retried = true
				_retry_at = _now + RETRY
		"fail":
			state = ""
			var code: String = str(item.get("code", ""))
			if code == "unsup":
				available = 0
				_say("Trình duyệt này không dùng được voice.")
			elif code == "pub":
				_say("Không gửi được tiếng mic — thử bấm mic lại.")
			else:
				_say("Voice tạm không dùng được")
		"mic":
			mic_on = false
			tea_mic = false
			_save()
			_push()
			var text: String = MicEngine.error_text(str(item.get("err", "nomic")))
			if not text.is_empty():
				_say(text)
		"lock":
			if not is_locked():
				locked_until = int(Time.get_unix_time_from_system()) + 3600
			_say("Mic của bạn tạm bị khoá do nhiều tố cáo")
		"rep":
			_say(report_text(int(item.get("ok", 0)) == 1, str(item.get("code", ""))))
		"perm":
			if str(item.get("st", "")) == "granted" and mic_on and AndroidVoice.mic_allowed():
				_granted = true
				_push()
			elif not _granted:
				mic_on = false

func _battle_event(item: Dictionary) -> void :
	match str(item.get("t", "")):
		"tk":
			var joined: bool = _battle_join
			_battle_join = false
			if int(item.get("ok", 0)) == 1:
				available = 1
				_hide = ""
				var lock: int = int(item.get("lock", 0))
				if lock > 0:
					locked_until = lock
				if joined and bstate == "":
					_js("window.__bbv.leave('battle')")
				return
			if bstate == "join":
				bstate = ""
			_battle_failed(str(item.get("code", "")))
		"on":
			bstate = "on"
			_battle_retried = false
		"gone":
			bstate = ""
			if _battle_want() and not _battle_retried:
				_battle_retried = true
				_battle_retry_at = _now + RETRY
		"fail":
			bstate = ""
			var code: String = str(item.get("code", ""))
			if code == "unsup":
				_hide_all("unsup")
				_say("Trình duyệt này không dùng được voice.")
			elif code == "pub":
				_say("Không gửi được tiếng mic — thử bấm mic lại.")
			else:
				_say("Voice tạm không dùng được")

func _battle_failed(code: String) -> void :
	if code in HIDE:
		_hide_all(code)
		return
	match code:
		"solo", "mode", "observer":
			_battle_ok = false
			if available == -1:
				available = 1
			_battle_leave()
		"noroom":
			available = 1
			if not _battle_retried:
				_battle_retried = true
				_battle_retry_at = _now + NOROOM_AGAIN
		"full":
			available = 1
			_battle_ok = false
			_say("Phòng thoại trận đã đủ người")
		"rate":
			available = 1
			_say("Thao tác quá nhanh, thử lại sau.")
			_battle_retry_at = _now + 30.0
		"level":
			available = 1
			_battle_ok = false
			_say("Chưa đủ cấp để dùng voice trong trận")
		_:
			if available == 1:
				_say("Voice tạm không dùng được")





func tea_join(scope: String = "tea") -> void :
	if not usable():
		return
	if scope != tea_scope:
		if _tea_want or tea_state != "":
			tea_leave(tea_scope)
		tea_deaf = false
		tea_scope = scope
	_tea_want = true
	_tea_retried = false
	tea_ok = true
	_install()
	_push()
	if tea_state == "":
		_tea_ticket()


func tea_leave(scope: String = "tea") -> void :
	if scope != tea_scope:
		return
	var had: bool = _tea_want or tea_state != ""
	_tea_want = false
	_tea_retry_at = -1.0
	if installed and had:
		_js("window.__bbv.leave('%s')" % tea_scope)
	tea_state = ""
	tea_mic = false
	tea_can = false
	tea_publishing = false
	tea_sending = false
	tea_me_talking = false
	tea_peers = {}
	if had:
		talking = false
		_push()

func tea_joined() -> bool:
	return _tea_want

func _tea_ticket() -> bool:
	if not _take_ticket():
		_tea_retry_at = float(_tickets[0]) + 60.05
		return false
	_install()
	tea_state = "join"
	_js("window.__bbv.ticket('%s', true)" % tea_scope)
	_poll_at = -1000.0
	return true


func tea_seated(can: bool) -> void :
	if not can and tea_mic:
		tea_mic = false
		talking = false
		_push()
	tea_can = can


func tea_toggle_mic(seated: bool) -> void :
	if not seated:
		_tea_say("Lên ghế mic mới nói được")
		return
	if mic_mode() == "off" and not tea_mic:
		_tea_say("Chế độ mic đang Tắt — chọn Nhấn giữ hoặc Mở liên tục trong Cài đặt → MICRO.")
		return
	if is_locked() and not tea_mic:
		_tea_say("Mic của bạn tạm bị khoá do nhiều tố cáo")
		return
	if not (tea_mic and _granted) and not AndroidVoice.mic_ready(_tea_mic_after, _tea_mic_denied):
		return
	tea_mic = not (tea_mic and _granted)
	if tea_mic:
		_granted = true
	else:
		talking = false
	_install()
	_js("window.__bbv.play()")
	_push()

func _tea_mic_after() -> void :
	tea_toggle_mic(true)

func _tea_mic_denied() -> void :
	tea_mic = false
	_push()
	_tea_say(AndroidVoice.DENIED_TEXT)


func tea_set_deaf(on: bool) -> void :
	_install()
	_js("window.__bbv.play()")
	if on == tea_deaf:
		return
	tea_deaf = on
	_push()


func tea_mic_state() -> String:
	if not tea_mic or not _granted or mic_mode() == "off" or is_locked():
		return "off"
	if tea_publishing and tea_sending and (tea_me_talking or talking):
		return "talk"
	return "on"

func tea_talking(id: int, self_id: int) -> bool:
	if id == self_id:
		return tea_mic_state() == "talk"
	return tea_peers.has(id) and bool(tea_peers[id][1]) and not muted.has(id) and not tea_deaf

func _tea_event(item: Dictionary) -> void :
	match str(item.get("t", "")):
		"tk":
			if int(item.get("ok", 0)) == 1:
				available = 1
				var lock: int = int(item.get("lock", 0))
				if lock > 0:
					locked_until = lock
				if not _tea_want:
					_js("window.__bbv.leave('%s')" % tea_scope)
				return
			if tea_state == "join":
				tea_state = ""
			var code: String = str(item.get("code", ""))
			if code in HIDE:
				tea_ok = false
				_tea_say("Voice %s chưa mở — vẫn nhắn chữ được." % ("Phòng Trà" if tea_scope == "tea" else "Kỳ Đài"))
			elif code == "rate":
				_tea_retry_at = _now + 30.0
				_tea_say("Thao tác quá nhanh, thử lại sau.")
			elif code == "full":
				_tea_say("Phòng thoại đã đủ người")
			else:
				_tea_say("Voice tạm không dùng được")
		"on":
			tea_state = "on"
			_tea_retried = false
		"gone":
			tea_state = ""
			tea_publishing = false
			tea_peers = {}
			if _tea_want and not _tea_retried:
				_tea_retried = true
				_tea_retry_at = _now + RETRY
		"fail":
			tea_state = ""
			var code: String = str(item.get("code", ""))
			if code == "unsup":
				tea_ok = false
				_tea_say("Trình duyệt này không dùng được voice.")
			elif code == "pub":
				_tea_say("Không gửi được tiếng mic — thử bấm mic lại.")
			else:
				_tea_say("Voice tạm không dùng được")
		"can":
			tea_can = int(item.get("v", 0)) == 1
			if not tea_can and tea_mic:
				tea_mic = false
				talking = false
				_push()

func _tea_say(text: String) -> void :
	if not text.is_empty():
		tea_voice.emit(text)

func _ticket_failed(code: String) -> void :
	if code in HIDE:
		_hide_all(code)
		_probed = _room_id
		return
	match code:
		"mode", "observer", "solo":
			_room_ok = false
			if available == -1:
				available = 1
			_leave()
		"noroom":
			available = 1
			_leave()
		"full":
			available = 1
			_say("Phòng thoại đã đủ người")
		"rate":
			available = 1
			_say("Thao tác quá nhanh, thử lại sau.")
			_retry_at = _now + 30.0
		"level":
			_say("Chưa đủ cấp để dùng chế độ Tất cả")
		"offline":
			if available == 1:
				_say("Voice tạm không dùng được")
		_:
			if available == 1:
				_say("Voice tạm không dùng được")


func on_notice(op: int, scope: String, code: String) -> void :
	if scope == "tea" or scope == "kd":
		if op == 6:
			tea_leave(scope)
		return
	if scope == "battle" and op == 1:
		_battle_notice(code)
		return
	match op:
		1:
			_retry_at = -1.0
			if code == "moved":
				_leave()
				_asked = ""
				_key_at = -1000.0
			else:
				_leave()
				if code in ["mode", "observer", "solo"]:
					_room_ok = false
				_asked = _key
		2:
			if code.is_valid_int():
				locked_until = int(code)
			_push()
			_say("Mic của bạn tạm bị khoá do nhiều tố cáo")
		3:
			_hide_all("off")
			_probed = _room_id
			_asked = _key
			_battle_asked = true


func _battle_notice(code: String) -> void :
	_battle_retry_at = -1.0
	_battle_leave()
	if code == "moved":
		_battle_asked = false
		_battle_at = -1000.0
		return
	if code in ["mode", "observer", "solo"]:
		_battle_ok = false
	_battle_asked = true

static func report_text(ok: bool, code: String) -> String:
	if ok:
		return "Đã gửi tố cáo"
	match code:
		"dup":
			return "Bạn đã tố cáo người này rồi"
		"notsame":
			return "Người này không ở cùng phòng thoại"
		"rate":
			return "Thao tác quá nhanh, thử lại sau."
	return "Chưa gửi được tố cáo — thử lại sau."

func _say(text: String) -> void :
	if text.is_empty():
		return
	if _tea_want:
		tea_voice.emit(text)
	elif notice.get_connections().is_empty() and client != null and client.has_method("chat_note"):
		client.chat_note(text)
	else:
		notice.emit(text)
