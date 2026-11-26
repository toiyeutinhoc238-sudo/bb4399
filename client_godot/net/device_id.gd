extends RefCounted








const DeviceIdPc = preload("res://net/device_id_pc.gd")
const WireKey = preload("res://net/device_wire_key.gd")
const PC_WAIT_MS: int = 8000
const SALT: String = "lcbb-dv1|"
const LOCAL_FILE: String = "user://dv1.id"
const WEB_JS: String = "(function(){try{var ls='';try{ls=localStorage.getItem('lcbb_dv1')||'';if(!/^[0-9a-f]{32}$/.test(ls)){var a=new Uint8Array(16);crypto.getRandomValues(a);ls=Array.prototype.map.call(a,function(b){return('0'+b.toString(16)).slice(-2);}).join('');localStorage.setItem('lcbb_dv1',ls);}}catch(e){ls='';}\nvar n=navigator,p=[String(n.userAgent||'').replace(/[0-9._]+/g,''),n.language,(n.languages||[]).join(','),n.platform,n.hardwareConcurrency,n.deviceMemory,n.maxTouchPoints,\nscreen.width+'x'+screen.height+'x'+screen.colorDepth,window.devicePixelRatio];try{p.push(Intl.DateTimeFormat().resolvedOptions().timeZone);}catch(e){}\ntry{var c=document.createElement('canvas'),g=c.getContext('webgl')||c.getContext('experimental-webgl');if(g){var d=g.getExtension('WEBGL_debug_renderer_info');\np.push(d?g.getParameter(d.UNMASKED_VENDOR_WEBGL)+'|'+g.getParameter(d.UNMASKED_RENDERER_WEBGL):g.getParameter(g.RENDERER),g.getParameter(g.MAX_TEXTURE_SIZE));\nvar l=g.getExtension('WEBGL_lose_context');if(l)l.loseContext();}}catch(e){}\ntry{var k=document.createElement('canvas');k.width=240;k.height=60;var x=k.getContext('2d');x.textBaseline='top';x.font='16px Arial';x.fillStyle='#f60';x.fillRect(100,1,62,20);\nx.fillStyle='#069';x.fillText('LCBB dv1 Ơư₫',2,15);x.fillStyle='rgba(102,204,0,.7)';x.fillText('LCBB dv1 Ơư₫',4,17);p.push(k.toDataURL());}catch(e){}\nreturn JSON.stringify({ls:ls,fp:p.join('~')});}catch(e){return '';}})()"









static var platform: String = ""
static var run: Callable
static var js: Callable
static var unique: Callable
static var local_file: String = LOCAL_FILE
static var _cache: Dictionary = {}
static var _task: int = -1
static var _worker: DeviceIdPc = null


static func reset() -> void :
	platform = ""
	run = Callable()
	js = Callable()
	unique = Callable()
	local_file = LOCAL_FILE
	_cache = {}
	_task = -1
	_worker = null

static func detect() -> String:
	if not platform.is_empty():
		return platform
	if OS.has_feature("web"):
		return "web"
	if OS.has_feature("android"):
		return "android"
	if OS.has_feature("ios"):
		return "ios"
	if OS.has_feature("windows") or OS.has_feature("macos") or OS.has_feature("linuxbsd"):
		return "pc"
	return ""


static func warm() -> void :
	if detect() != "pc" or ( not OS.has_feature("windows") and not run.is_valid()) or _worker != null or not _cache.is_empty():
		return
	_worker = DeviceIdPc.new()
	_worker.run = run
	_worker.unique = unique
	if run.is_valid():
		_worker.collect()
	else:
		_task = WorkerThreadPool.add_task(_worker.collect, false, "dvb1 mã máy")


static func payload() -> Dictionary:
	if not _cache.is_empty():
		return _cache.duplicate(true)
	var plat: String = detect()
	var raw: Array = []
	var late: bool = false
	match plat:
		"pc":
			if OS.has_feature("windows") or run.is_valid():
				warm()
				if _task >= 0:
					var until: int = Time.get_ticks_msec() + PC_WAIT_MS
					while not WorkerThreadPool.is_task_completed(_task) and Time.get_ticks_msec() < until:
						OS.delay_msec(20)
					late = not WorkerThreadPool.is_task_completed(_task)
					if not late:
						WorkerThreadPool.wait_for_task_completion(_task)
						_task = -1
				raw = _worker.raw.duplicate() if _worker != null and not late else []
			else:
				raw.append(["uid", _unique()])
			raw.append(["ls", local_id()])
		"android":
			raw.append(["aid", _unique()])
			raw.append(["ls", local_id()])
		"ios":
			raw.append(["idfv", _unique()])
			raw.append(["ls", local_id()])
		"web":
			raw = web_raw()
	var ids: Array = []
	for pair: Array in raw:
		var value: String = str(pair[1]).strip_edges()
		if value.is_empty():
			continue
		var id: String = "%s:%s" % [pair[0], (SALT + str(pair[0]) + "|" + value).sha256_text()]
		if not ids.has(id):
			ids.append(id)
	if ids.is_empty():
		return {}
	if late:
		return {"p": plat, "ids": ids}
	_cache = {"p": plat, "ids": ids}
	return _cache.duplicate(true)


static func wire() -> Dictionary:
	var d: Dictionary = payload()
	if d.is_empty():
		return {}
	var key: PackedByteArray = WireKey.bytes()
	if key.size() != 64:
		return d
	var crypto: Crypto = Crypto.new()
	var iv: PackedByteArray = crypto.generate_random_bytes(16)
	var body: PackedByteArray = JSON.stringify(d).to_utf8_buffer()
	var pad: int = 16 - body.size() % 16
	for i in pad:
		body.append(pad)
	var aes: AESContext = AESContext.new()
	aes.start(AESContext.MODE_CBC_ENCRYPT, key.slice(0, 32), iv)
	var head: PackedByteArray = iv + aes.update(body)
	aes.finish()
	var tag: PackedByteArray = crypto.hmac_digest(HashingContext.HASH_SHA256, key.slice(32, 64), head)
	return {"p": d["p"], "x": Marshalls.raw_to_base64(head + tag)}

static func _unique() -> String:
	if unique.is_valid():
		return str(unique.call())
	return OS.get_unique_id()


static func local_id() -> String:
	var old: String = FileAccess.get_file_as_string(local_file).strip_edges() if FileAccess.file_exists(local_file) else ""
	if old.length() == 32 and old.is_valid_hex_number():
		return old
	var fresh: String = Crypto.new().generate_random_bytes(16).hex_encode()
	var f: FileAccess = FileAccess.open(local_file, FileAccess.WRITE)
	if f == null:
		return fresh
	f.store_string(fresh)
	f.close()
	return fresh

static func web_raw() -> Array:
	var out: Variant = js.call(WEB_JS) if js.is_valid() else JavaScriptBridge.eval(WEB_JS, true)
	var parsed: Variant = JSON.parse_string(str(out)) if typeof(out) == TYPE_STRING and not str(out).is_empty() else null
	if not parsed is Dictionary:
		return []
	return [["ls", str(parsed.get("ls", ""))], ["fp", str(parsed.get("fp", ""))]]
