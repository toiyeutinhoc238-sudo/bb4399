extends Node




















signal mounted

const MAN: String = "res://assets/pk2.json"
const DIR: String = "/tmp/pk2/"
const WAIT: Array[float] = [1.0, 2.0, 4.0, 8.0, 15.0]
const STALL: float = 45.0
const POLL: float = 0.1
const PC_DELAY: float = 3.0
const VERIFY_MS: int = 6
const VERIFY_CHUNK: int = 1 << 18

const JS_START: String = "(function(u,p,n,id){var W=window,T=W.performance,j={id:id,state:'busy',got:0,err:'',mode:'',buf:null,t0:T.now(),ms:0};W.__lcbbPk2Job=j;\nfunction live(){return W.__lcbbPk2Job===j}\nfunction fin(b){if(!live())return;j.ms=Math.round(T.now()-j.t0);try{if(typeof engine!=='undefined'&&engine&&typeof engine.copyToFS==='function'){if(W.__lcbbOwn)W.__lcbbOwn(b.buffer);engine.copyToFS(p,b.buffer);j.mode='fs'}else{j.buf=b;j.mode='buf'}j.state='ok'}catch(e){j.state='err';j.err='ghi FS: '+String((e&&e.message)||e).slice(0,120)}}\nW.fetch(u).then(function(r){if(r.status!==200)throw new Error('mã '+r.status);\nif(!r.body||!r.body.getReader)return r.arrayBuffer().then(function(b){if(b.byteLength!==n)throw new Error('lệch cỡ '+b.byteLength+'/'+n);j.got=n;fin(new Uint8Array(b))});\nvar out=new Uint8Array(n),rd=r.body.getReader();\nfunction step(){return rd.read().then(function(x){if(!live()){try{rd.cancel()}catch(e){}return}\nif(x.done){if(j.got!==n)throw new Error('lệch cỡ '+j.got+'/'+n);fin(out);return}\nvar v=x.value;if(j.got+v.length>n)throw new Error('dài quá '+(j.got+v.length)+'/'+n);out.set(v,j.got);j.got+=v.length;return step()})}\nreturn step()}).catch(function(e){if(live()){j.state='err';j.buf=null;j.err=String((e&&e.message)||e).slice(0,160)}});\nreturn 1})(%s,%s,%d,%d)"











var client: Node
var active: bool = false
var packs: Array = []
var done: int = 0
var bytes_done: int = 0
var bytes_all: int = 0
var tries: int = 0
var last_error: String = ""
var _base: String = ""
var _busy: bool = false
var _job: int = 0
var _got: int = 0
var _moved_at: float = 0.0
var _poll_at: float = 0.0
var _retry_at: float = -1.0
var _clock: float = 0.0
var _t0: int = 0
var _state: String = ""
var _wait_i: int = 0
var _net_ms: int = 0
var _hold: bool = true
var _mobile: bool = false
var _vf: FileAccess = null
var _vctx: HashingContext = null
var _vp: Dictionary = {}
var _vpath: String = ""
var _vt0: int = 0
var _vms: int = 0

func _ready() -> void :
	_t0 = Time.get_ticks_msec()
	if not OS.has_feature("web") or not FileAccess.file_exists(MAN):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(MAN))
	if not (data is Dictionary) or not (data.get("packs") is Array):
		push_error("[pk2] pk2.json hỏng")
		return
	for p: Variant in data["packs"]:
		if p is Dictionary and str(p.get("name", "")).ends_with(".e.pck") and not str(p["name"]).contains("/"):
			packs.append({"name": str(p["name"]), "size": int(p.get("size", 0)), "sha256": str(p.get("sha256", ""))})
			bytes_all += int(p.get("size", 0))
	if packs.is_empty():
		return
	active = true
	_mobile = OS.has_feature("web_ios") or OS.has_feature("web_android")
	_base = str(JavaScriptBridge.eval("new URL('pk2/', document.baseURI).href", true))
	DirAccess.make_dir_recursive_absolute(DIR)
	_publish()
	_next()

func is_done() -> bool:
	return not active or done >= packs.size()


func fraction() -> float:
	if is_done():
		return 1.0
	var now: int = bytes_done
	if _busy or _vf != null:
		now += mini(_got, int(packs[done]["size"]))
	return clampf(float(now) / maxf(1.0, float(bytes_all)), 0.0, 0.999)


func kick() -> void :
	if active and not is_done() and not _busy and _vf == null:
		_retry_at = -1.0
		_next()

func _process(delta: float) -> void :
	if not active or is_done():
		return
	_clock += delta
	if client != null:
		var s: String = str(client.get("state"))
		if s != _state:
			var was: String = _state
			_state = s
			if was == "battle" or s in ["lobby", "hall", "room", "characters"]:
				kick()
	if _vf != null:
		_verify_step()
		return
	if _hold:
		if _may_start():
			_next()
		return
	if _busy:
		if _clock >= _poll_at:
			_poll_at = _clock + POLL
			_poll()
	elif _retry_at >= 0.0 and _clock >= _retry_at:
		_retry_at = -1.0
		_next()

func _in_battle() -> bool:
	return client != null and str(client.get("state")) == "battle"


func _may_start() -> bool:
	if client == null:
		return true
	if str(client.get("state")) != "login":
		return true
	return not _mobile and _clock >= PC_DELAY

func _next() -> void :
	if _busy or _vf != null or is_done():
		return
	if _hold:
		if not _may_start():
			_publish()
			return
		_hold = false
		print("[pk2] bst2: bắt đầu tải gói phụ (trạng thái %s, %d ms từ khởi động)" % [str(client.get("state")) if client != null else "-", Time.get_ticks_msec() - _t0])
	if _in_battle():
		_retry_at = _clock + 2.0
		return
	var p: Dictionary = packs[done]
	_busy = true
	tries += 1
	_job += 1
	_got = 0
	_moved_at = _clock
	_poll_at = _clock + POLL
	var path: String = DIR + str(p["name"])
	DirAccess.remove_absolute(path)
	var ok: Variant = JavaScriptBridge.eval(JS_START % [JSON.stringify(_base + str(p["name"])), JSON.stringify(path), int(p["size"]), _job], true)
	if not ok:
		_fail("không gọi được fetch")
	else:
		_publish()


func _poll() -> void :
	var p: Dictionary = packs[done]
	var line: String = str(JavaScriptBridge.eval("(function(j){return j&&j.id===%d?j.state+' '+j.got+' '+j.mode+' '+j.ms:''})(window.__lcbbPk2Job)" % _job, true))
	var f: PackedStringArray = line.split(" ")
	if f.size() < 4:
		_fail("%s: mất lượt tải bên trang" % p["name"])
		return
	var got: int = int(f[1])
	if got != _got:
		_got = got
		_moved_at = _clock
	if f[0] == "busy":
		if _clock - _moved_at > STALL:
			_drop()
			_fail("%s: im %.0f s (%d/%d byte)" % [p["name"], STALL, _got, int(p["size"])])
		return
	if f[0] == "err":
		var why: String = str(JavaScriptBridge.eval("(function(j){return j?j.err:''})(window.__lcbbPk2Job)", true))
		_drop()
		_fail("%s: %s" % [p["name"], why])
		return
	var path: String = DIR + str(p["name"])
	if f[2] == "buf":
		var body: Variant = JavaScriptBridge.eval("(function(j){var b=j.buf;j.buf=null;return b})(window.__lcbbPk2Job)", true)
		_drop()
		if not (body is PackedByteArray):
			_fail("%s: không nhận được byte" % p["name"])
			return
		var w: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		if w == null:
			_fail("không ghi được %s (%d)" % [p["name"], FileAccess.get_open_error()])
			return
		w.store_buffer(body)
		var werr: int = w.get_error()
		w.close()
		if werr != OK:
			DirAccess.remove_absolute(path)
			_fail("ghi %s lỗi %d" % [p["name"], werr])
			return
	else:
		_drop()
	_net_ms = int(f[3])
	_verify_begin(p, path)

func _drop() -> void :
	JavaScriptBridge.eval("(function(W){if(W.__lcbbPk2Job&&W.__lcbbPk2Job.id===%d)W.__lcbbPk2Job=null})(window)" % _job, true)


func _verify_begin(p: Dictionary, path: String) -> void :
	_busy = false
	_vt0 = Time.get_ticks_msec()
	_vms = 0
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		_fail("không mở được %s (%d)" % [p["name"], FileAccess.get_open_error()])
		return
	if int(f.get_length()) != int(p["size"]):
		var n: int = int(f.get_length())
		f.close()
		DirAccess.remove_absolute(path)
		_fail("%s lệch cỡ %d/%d" % [p["name"], n, p["size"]])
		return
	_vctx = HashingContext.new()
	_vctx.start(HashingContext.HASH_SHA256)
	_vp = p
	_vpath = path
	_vf = f
	_publish()
	_verify_step()

func _verify_step() -> void :
	var t: int = Time.get_ticks_msec()
	while _vf.get_position() < _vf.get_length():
		_vctx.update(_vf.get_buffer(VERIFY_CHUNK))
		if Time.get_ticks_msec() - t >= VERIFY_MS:
			_vms += Time.get_ticks_msec() - t
			return
	_vms += Time.get_ticks_msec() - t
	_vf.close()
	_vf = null
	var ok: bool = _vctx.finish().hex_encode() == str(_vp["sha256"])
	_vctx = null
	var p: Dictionary = _vp
	_vp = {}
	if not ok:
		DirAccess.remove_absolute(_vpath)
		_fail("%s lệch sha256" % p["name"])
		return
	_mount(p, _vpath)

func _mount(p: Dictionary, path: String) -> void :
	_busy = false
	var t_v: int = _vt0
	var why: String = ""
	var t_m: int = Time.get_ticks_msec()
	if not why.is_empty():
		DirAccess.remove_absolute(path)
		_fail(why)
		return
	if not ProjectSettings.load_resource_pack(path, true, 0):
		DirAccess.remove_absolute(path)
		_fail("gắn %s lỗi" % p["name"])
		return
	done += 1
	bytes_done += int(p["size"])
	_got = 0
	_wait_i = 0
	var t_e: int = Time.get_ticks_msec()
	print("[pk2] gắn %s (%d/%d, %d byte, tải %d ms, kiểm %d ms / %d ms khung, gắn %d ms, %d ms từ khởi động)" % [p["name"], done, packs.size(), int(p["size"]), 
		_net_ms, t_m - t_v, _vms, t_e - t_m, t_e - _t0])
	_publish()
	if is_done():
		print("[pk2] đủ %d gói, %d byte, %d lượt tải, %d ms" % [packs.size(), bytes_all, tries, Time.get_ticks_msec() - _t0])
		mounted.emit()
	else:
		_next()

func _fail(why: String) -> void :
	_busy = false
	_got = 0
	last_error = why
	var wait: float = WAIT[mini(_wait_i, WAIT.size() - 1)]
	_wait_i += 1
	_retry_at = _clock + wait
	print("[pk2] lỗi %s, thử lại sau %.0f s" % [why, wait])
	_publish()


func _verify(path: String, p: Dictionary) -> String:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return "không mở được %s (%d)" % [p["name"], FileAccess.get_open_error()]
	if int(f.get_length()) != int(p["size"]):
		return "%s lệch cỡ %d/%d" % [p["name"], f.get_length(), p["size"]]
	var ctx: HashingContext = HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	while f.get_position() < f.get_length():
		ctx.update(f.get_buffer(1 << 20))
	f.close()
	if ctx.finish().hex_encode() != str(p["sha256"]):
		return "%s lệch sha256" % p["name"]
	return ""

func _publish() -> void :
	if OS.has_feature("web"):
		JavaScriptBridge.eval("window.__lcbbPk2={state:'%s',done:%d,packs:%d,bytes:%d,all:%d,tries:%d,ms:%d,err:%s}" % [
			"ok" if is_done() else ("busy" if _busy or _vf != null else ("hold" if _hold else "wait")), done, packs.size(), bytes_done, bytes_all, tries, Time.get_ticks_msec() - _t0, 
			JSON.stringify(last_error)], true)
