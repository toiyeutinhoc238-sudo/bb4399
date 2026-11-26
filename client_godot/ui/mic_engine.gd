extends RefCounted
















const SafeJson = preload("res://net/safe_json.gd")
const Settings = preload("res://settings.gd")
const AndroidVoice = preload("res://net/android_voice.gd")
const PcVoice = preload("res://net/pc_voice.gd")

signal error(code: String)
signal devices_changed(list: Array)

const DIR: String = "w/mic/"
const FILES: Dictionary = {"js": "rnnoise_worklet.js", "wasm": "rnnoise.wasm", "simd": "rnnoise_simd.wasm"}
const POLL_BUSY: float = 0.05
const POLL_IDLE: float = 0.5
const JS: String = "(function () {\n\tif (window.__bbmic) return;\n\tvar HASH = {js: '1e06facbb3d7459b89769aa4247cd4b71263e6662e4da0c54763f3bf06f5893b',\n\t\twasm: '8b60a2ab88fdae2d1a9f940249d0eb072f28ba8e796f7304347b4e07839c8853',\n\t\tsimd: '378fd17c294db15ee4e818ba5ef072242a21c8ad7445b483f7f46d7dc4f2c253'};\n\tvar SIMD = new Uint8Array([0, 97, 115, 109, 1, 0, 0, 0, 1, 5, 1, 96, 0, 1, 123, 3, 2, 1, 0, 10, 10, 1, 8, 0, 65, 0, 253, 15, 253, 98, 11]);\n\tvar RN = '@sapphi-red/web-noise-suppressor/rnnoise';\n\tvar C = {dev: '', gain: 1, mute: false, ns: 1, ec: true, agc: true, gate: 0.35, auto: true, mode: 'ptt', urls: {}};\n\tvar A = null, raw = null, src = null, pend = null, again = false;\n\tvar users = {}, out = [], devs = null, lvl = 0, buf = null, g = {db: -100, open: true, thr: -49};\n\tvar rn = {js: null, bin: null, p: null, pctx: null, ready: null, bad: false};\n\tvar mon = false, tr = null, clip = '', au = null;\n\tfunction push(o) { if (out.length < 20) out.push(o); }\n\tfunction count() { return Object.keys(users).length; }\n\tfunction nsWant() { return C.ns === 2 && rn.bad ? 1 : C.ns; }\n\tfunction oops(e) {\n\t\tvar n = e && e.name;\n\t\tif (n !== 'bbmic-idle') push({err: n === 'NotAllowedError' || n === 'SecurityError' ? 'deny' : 'nomic'});\n\t}\n\tfunction stop(s) { s.getTracks().forEach(function (t) { t.onended = null; t.stop(); }); }\n\tfunction live(s) { return s.getAudioTracks().some(function (t) { return t.readyState === 'live'; }); }\n\tfunction resume() {\n\t\tif (A && count() && A.ctx.state !== 'running' && A.ctx.state !== 'closed') A.ctx.resume().catch(function () {});\n\t}\n\t// Ngưỡng nhận giọng (chạy trong AudioWorklet): mức RMS dBFS mỗi khối; tự động = nền ồn (mượt 50 ms, xuống nhanh, lên 3 dB/giây) + 12 dB,\n\t// kẹp -60..-25; trễ 4 dB, giữ 300 ms, mở 5 ms / đóng 50 ms. on = false (nhấn giữ / tắt) → cho qua hết, vẫn đo.\n\tfunction gateSrc() {\n\t\tclass G extends AudioWorkletProcessor {\n\t\t\tconstructor() {\n\t\t\t\tsuper();\n\t\t\t\tvar me = this;\n\t\t\t\tme.on = false; me.thr = -49; me.auto = true; me.floor = null; me.p = 0; me.t = 0; me.open = true; me.hold = 0; me.k = 1; me.n = 0; me.bye = false;\n\t\t\t\tme.port.onmessage = function (e) {\n\t\t\t\t\tvar d = e.data || {};\n\t\t\t\t\tif (d.on !== undefined) me.on = d.on;\n\t\t\t\t\tif (d.thr !== undefined) me.thr = d.thr;\n\t\t\t\t\tif (d.auto !== undefined) me.auto = d.auto;\n\t\t\t\t\tif (d.bye) me.bye = true;\n\t\t\t\t\tif (d.reset) { me.floor = null; me.p = 0; me.t = 0; } // nguồn đổi (mic / chống ồn) → đo lại nền ồn\n\t\t\t\t};\n\t\t\t}\n\t\t\tprocess(ins, outs) {\n\t\t\t\tif (this.bye) return false;\n\t\t\t\tvar x = ins[0] && ins[0][0], y = outs[0] && outs[0][0];\n\t\t\t\tif (!x || !y) return true;\n\t\t\t\tvar s = 0, i;\n\t\t\t\tfor (i = 0; i < x.length; i++) s += x[i] * x[i];\n\t\t\t\tvar db = 10 * Math.log10(s / x.length + 1e-12), dt = x.length / sampleRate;\n\t\t\t\t// Nền ồn: mức mượt 50 ms; khối lặng tuyệt đối (< -100 dBFS: tắt mic, đang đổi mic) bỏ qua để nền không tụt sâu.\n\t\t\t\tif (db > -100) {\n\t\t\t\t\tthis.p += (s / x.length - this.p) * Math.min(1, dt / 0.05);\n\t\t\t\t\tthis.t += dt;\n\t\t\t\t\tvar lv = 10 * Math.log10(this.p + 1e-12);\n\t\t\t\t\tif (this.floor === null) { if (this.t >= 0.1) this.floor = lv; }\n\t\t\t\t\telse if (lv < this.floor) this.floor += (lv - this.floor) * Math.min(1, dt / 0.2);\n\t\t\t\t\telse this.floor += Math.min(lv - this.floor, 3 * dt);\n\t\t\t\t}\n\t\t\t\tvar thr = this.auto ? Math.max(-60, Math.min(-25, (this.floor === null ? -72 : this.floor) + 12)) : this.thr;\n\t\t\t\tif (db >= thr || (this.open && db >= thr - 4)) { this.open = true; this.hold = 0.3; }\n\t\t\t\telse { this.hold -= dt; if (this.hold <= 0) this.open = false; }\n\t\t\t\tvar want = !this.on || this.open ? 1 : 0, up = 1 / (0.005 * sampleRate), down = 1 / (0.05 * sampleRate);\n\t\t\t\tfor (i = 0; i < x.length; i++) {\n\t\t\t\t\tthis.k = want > this.k ? Math.min(want, this.k + up) : Math.max(want, this.k - down);\n\t\t\t\t\ty[i] = x[i] * this.k;\n\t\t\t\t}\n\t\t\t\tthis.n += x.length;\n\t\t\t\tif (this.n >= 1024) { this.n = 0; this.port.postMessage({db: db, open: this.open, thr: thr}); }\n\t\t\t\treturn true;\n\t\t\t}\n\t\t}\n\t\tregisterProcessor('bbmic-gate', G);\n\t}\n\tfunction build(rate) {\n\t\tvar AC = window.AudioContext || window.webkitAudioContext;\n\t\tif (!AC) return false;\n\t\tvar ctx;\n\t\ttry { ctx = rate ? new AC({sampleRate: rate, latencyHint: 'interactive'}) : new AC({latencyHint: 'interactive'}); }\n\t\tcatch (e) { try { ctx = new AC(); } catch (e2) { return false; } }\n\t\tvar a = {ctx: ctx, rate: rate, rn: null, rnOn: false, gate: null, key: '', nsb: 0};\n\t\ta.head = ctx.createGain();\n\t\ta.head.channelCount = 1; a.head.channelCountMode = 'explicit'; a.head.channelInterpretation = 'speakers';\n\t\ta.amp = ctx.createGain();\n\t\ta.an = ctx.createAnalyser(); a.an.fftSize = 1024; a.an.smoothingTimeConstant = 0;\n\t\ta.out = ctx.createGain();\n\t\ta.mon = ctx.createGain();\n\t\ta.dest = ctx.createMediaStreamDestination();\n\t\ta.head.connect(a.amp); a.amp.connect(a.an); a.amp.connect(a.out); a.out.connect(a.dest); a.out.connect(a.mon); a.mon.connect(ctx.destination);\n\t\tA = a;\n\t\tapply();\n\t\tif (ctx.audioWorklet && window.Blob && window.URL && window.AudioWorkletNode) {\n\t\t\tvar url = URL.createObjectURL(new Blob(['(' + gateSrc.toString() + ')();'], {type: 'text/javascript'}));\n\t\t\tctx.audioWorklet.addModule(url).then(function () {\n\t\t\t\tURL.revokeObjectURL(url);\n\t\t\t\tif (A !== a) return;\n\t\t\t\tvar n = new AudioWorkletNode(ctx, 'bbmic-gate', {numberOfInputs: 1, numberOfOutputs: 1, outputChannelCount: [1],\n\t\t\t\t\tchannelCount: 1, channelCountMode: 'explicit'});\n\t\t\t\tn.port.onmessage = function (e) { if (A === a && e.data) g = e.data; };\n\t\t\t\ta.amp.disconnect(a.out); a.amp.connect(n); n.connect(a.out);\n\t\t\t\ta.gate = n;\n\t\t\t\tapply();\n\t\t\t}).catch(function () { URL.revokeObjectURL(url); });\n\t\t}\n\t\treturn true;\n\t}\n\tfunction teardown() {\n\t\tif (!A) return;\n\t\tif (A.gate) try { A.gate.port.postMessage({bye: true}); } catch (e) {}\n\t\ttry { A.ctx.close(); } catch (e) {}\n\t\tA = null; g = {db: -100, open: true, thr: -49};\n\t}\n\tfunction refloor() { if (A && A.gate) A.gate.port.postMessage({reset: true}); }\n\tfunction apply() {\n\t\tif (!A) return;\n\t\t[[A.head.gain, C.mute ? 0 : 1], [A.amp.gain, C.gain], [A.mon.gain, mon ? 1 : 0]].forEach(function (p) {\n\t\t\tp[0].cancelScheduledValues(0); p[0].value = p[1];\n\t\t});\n\t\tif (A.gate) A.gate.port.postMessage({on: C.mode === 'open', thr: -70 + 60 * C.gate, auto: C.auto});\n\t}\n\tfunction cons(useDev) {\n\t\tvar c = {echoCancellation: C.ec, noiseSuppression: nsWant() === 1, autoGainControl: C.agc, channelCount: 1};\n\t\tif (useDev && C.dev) c.deviceId = {exact: C.dev};\n\t\treturn {audio: c};\n\t}\n\tfunction getMic() {\n\t\tvar md = navigator.mediaDevices;\n\t\tif (!md || !md.getUserMedia) return Promise.reject({name: 'NotFoundError'});\n\t\treturn md.getUserMedia(cons(true)).catch(function (e) {\n\t\t\tif (!C.dev || !e || (e.name !== 'OverconstrainedError' && e.name !== 'NotFoundError')) throw e;\n\t\t\tpush({err: 'lost'}); // mic đã chọn không còn → mic mặc định (cài đặt giữ nguyên, cắm lại là dùng lại)\n\t\t\treturn md.getUserMedia(cons(false));\n\t\t});\n\t}\n\tfunction attach(s) {\n\t\tvar old = raw, oldSrc = src, n;\n\t\ttry { n = A.ctx.createMediaStreamSource(s); }\n\t\tcatch (e) {\n\t\t\t// Firefox: mic khác tần số mẫu của AudioContext 48 kHz → dựng lại theo tần số mặc định (khi đó không có RNNoise).\n\t\t\tif (!A.rate || A.fed) throw e;\n\t\t\tteardown();\n\t\t\tif (!build(0)) throw e;\n\t\t\tn = A.ctx.createMediaStreamSource(s);\n\t\t}\n\t\traw = s; src = n; A.fed = true;\n\t\tn.connect(A.head);\n\t\trefloor();\n\t\tif (oldSrc) try { oldSrc.disconnect(); } catch (e) {}\n\t\tif (old && old !== s) stop(old);\n\t\tA.key = JSON.stringify(cons(true));\n\t\tA.nsb = nsWant() === 1 ? 1 : 0;\n\t\ts.getAudioTracks().forEach(function (t) {\n\t\t\tt.onended = function () { if (raw === s && count()) swap().catch(oops); }; // rút mic giữa chừng\n\t\t});\n\t}\n\t// Chrome dùng chung một nguồn thu cho mọi track đang sống của cùng mic: xin lại khi track cũ còn chạy thì vẫn nhận xử lý\n\t// (ec/ns/agc) CŨ → luôn dừng track cũ trước rồi mới xin (đổi cài đặt / thiết bị: lặng ~0,1 s).\n\tfunction drop() {\n\t\tif (raw) { var s = raw; raw = null; stop(s); }\n\t\tif (src) { try { src.disconnect(); } catch (e) {} src = null; }\n\t}\n\t// Xin luồng mic theo cấu hình hiện tại rồi gắn vào đồ thị; luồng ra (A.dest.stream) giữ nguyên qua mọi lần đổi.\n\tfunction swap() {\n\t\tif (pend) { again = true; return pend; }\n\t\tpend = (C.ns === 2 && !rn.bad ? loadRn().catch(function () {}) : Promise.resolve()).then(function () { drop(); return getMic(); }).then(function (s) {\n\t\t\tpend = null;\n\t\t\tif (!count() || !A) { stop(s); throw {name: 'bbmic-idle'}; }\n\t\t\tattach(s); wire(); resume();\n\t\t\tif (again) { again = false; swap().catch(oops); }\n\t\t\treturn A.dest.stream;\n\t\t}, function (e) { pend = null; again = false; throw e; });\n\t\treturn pend;\n\t}\n\tfunction open() {\n\t\tif (!A && !build(48000)) return Promise.reject({name: 'NotSupportedError'});\n\t\tif (raw && !pend && live(raw)) { resume(); return Promise.resolve(A.dest.stream); }\n\t\treturn pend || swap();\n\t}\n\tfunction acquire(who) {\n\t\tusers[who] = 1;\n\t\treturn open().catch(function (e) { release(who); throw e; });\n\t}\n\tfunction release(who) {\n\t\tdelete users[who];\n\t\tif (count()) return;\n\t\tdrop();\n\t\tif (A && A.ctx.state === 'running') A.ctx.suspend().catch(function () {});\n\t\tlvl = 0;\n\t}\n\tfunction hex(b) {\n\t\tvar a = new Uint8Array(b), s = '';\n\t\tfor (var i = 0; i < a.length; i++) s += (a[i] < 16 ? '0' : '') + a[i].toString(16);\n\t\treturn s;\n\t}\n\tfunction get(url, hash) {\n\t\treturn fetch(url, {credentials: 'same-origin'}).then(function (r) {\n\t\t\tif (!r.ok) throw new Error('http ' + r.status);\n\t\t\treturn r.arrayBuffer();\n\t\t}).then(function (b) {\n\t\t\tif (!window.crypto || !crypto.subtle) return b;\n\t\t\treturn crypto.subtle.digest('SHA-256', b).then(function (d) { if (hex(d) !== hash) throw new Error('hash'); return b; });\n\t\t});\n\t}\n\tfunction rnFail() {\n\t\tif (rn.bad) return;\n\t\trn.bad = true;\n\t\tpush({err: 'ns'});\n\t\twire();\n\t\tif (raw && count()) swap().catch(oops); // bật lại noiseSuppression của trình duyệt\n\t}\n\tfunction loadRn() {\n\t\tif (!A) return Promise.reject(new Error('ctx'));\n\t\tvar ctx = A.ctx;\n\t\tif (rn.ready === ctx) return Promise.resolve();\n\t\tif (rn.p && rn.pctx === ctx) return rn.p;\n\t\tif (rn.bad || !ctx.audioWorklet || !window.AudioWorkletNode || typeof WebAssembly === 'undefined' || ctx.sampleRate !== 48000\n\t\t\t|| !C.urls.js || !C.urls.wasm || !C.urls.simd) { rnFail(); return Promise.reject(new Error('ns')); }\n\t\tvar simd = false;\n\t\ttry { simd = WebAssembly.validate(SIMD); } catch (e) {}\n\t\trn.pctx = ctx;\n\t\tvar p = rn.p = Promise.all([rn.js ? Promise.resolve(rn.js) : get(C.urls.js, HASH.js),\n\t\t\trn.bin ? Promise.resolve(rn.bin) : get(simd ? C.urls.simd : C.urls.wasm, simd ? HASH.simd : HASH.wasm)]).then(function (r) {\n\t\t\trn.js = r[0]; rn.bin = r[1];\n\t\t\tvar url = URL.createObjectURL(new Blob([r[0]], {type: 'text/javascript'}));\n\t\t\treturn ctx.audioWorklet.addModule(url).then(function () {\n\t\t\t\tURL.revokeObjectURL(url);\n\t\t\t\tif (rn.p === p) rn.p = null;\n\t\t\t\trn.ready = ctx;\n\t\t\t\twire();\n\t\t\t}, function (e) { URL.revokeObjectURL(url); throw e; });\n\t\t}).catch(function (e) {\n\t\t\tif (rn.p === p) rn.p = null;\n\t\t\tif (A && ctx === A.ctx) rnFail();\n\t\t\tthrow e;\n\t\t});\n\t\treturn p;\n\t}\n\t// Gắn / gỡ RNNoise giữa head và amp. Nút RNNoise giữ lại cho lần bật sau (bộ xử lý của thư viện không nhận lệnh huỷ).\n\tfunction wire() {\n\t\tif (!A) return;\n\t\tvar want = C.ns === 2 && !rn.bad && rn.ready === A.ctx;\n\t\tif (want && !A.rn) {\n\t\t\ttry {\n\t\t\t\tA.rn = new AudioWorkletNode(A.ctx, RN, {numberOfInputs: 1, numberOfOutputs: 1, outputChannelCount: [1], channelCount: 1,\n\t\t\t\t\tchannelCountMode: 'explicit', channelInterpretation: 'speakers', processorOptions: {maxChannels: 1, wasmBinary: rn.bin}});\n\t\t\t} catch (e) { A.rn = null; rnFail(); return; }\n\t\t}\n\t\tif (want && !A.rnOn) {\n\t\t\tA.head.disconnect(A.amp); A.head.connect(A.rn); A.rn.connect(A.amp); A.rnOn = true; refloor();\n\t\t} else if (!want && A.rnOn) {\n\t\t\tA.head.disconnect(A.rn); A.rn.disconnect(); A.head.connect(A.amp); A.rnOn = false; refloor();\n\t\t}\n\t}\n\tfunction meter() {\n\t\tif (!A || !raw) { lvl = 0; return 0; }\n\t\tif (!buf || buf.length !== A.an.fftSize) buf = new Float32Array(A.an.fftSize);\n\t\tA.an.getFloatTimeDomainData(buf);\n\t\tvar s = 0;\n\t\tfor (var i = 0; i < buf.length; i++) s += buf[i] * buf[i];\n\t\tvar v = Math.max(0, Math.min(1, (10 * Math.log10(s / buf.length + 1e-12) + 70) / 60));\n\t\tlvl = Math.max(v, lvl * 0.8);\n\t\treturn lvl;\n\t}\n\tfunction mime() {\n\t\tvar types = ['audio/webm;codecs=opus', 'audio/ogg;codecs=opus', 'audio/mp4', 'audio/webm'];\n\t\tfor (var i = 0; i < types.length; i++) if (MediaRecorder.isTypeSupported && MediaRecorder.isTypeSupported(types[i])) return types[i];\n\t\treturn '';\n\t}\n\tfunction stopPlay() { if (au) { au.pause(); au = null; } }\n\tvar api = window.__bbmic = {\n\t\tcfg: function (o) {\n\t\t\tvar key = A && raw ? A.key : '';\n\t\t\tfor (var k in o) if (Object.prototype.hasOwnProperty.call(C, k)) C[k] = o[k];\n\t\t\tapply();\n\t\t\tif (C.ns === 2 && A && raw && !rn.bad) loadRn().catch(function () {});\n\t\t\twire();\n\t\t\tif (raw && count() && JSON.stringify(cons(true)) !== key) swap().catch(oops);\n\t\t},\n\t\tacquire: acquire,\n\t\trelease: release,\n\t\tstream: function () { return A ? A.dest.stream : null; },\n\t\tmuted: function () { return !!C.mute; },\n\t\tdevices: function () {\n\t\t\tvar md = navigator.mediaDevices;\n\t\t\tif (!md || !md.enumerateDevices) { devs = []; return; }\n\t\t\tmd.enumerateDevices().then(function (l) {\n\t\t\t\tdevs = l.filter(function (d) { return d.kind === 'audioinput'; }).map(function (d) { return {id: d.deviceId, label: d.label || ''}; });\n\t\t\t}, function () { devs = []; });\n\t\t},\n\t\tmonitor: function (on) {\n\t\t\tif (!!on === mon) return;\n\t\t\tmon = !!on;\n\t\t\tapply();\n\t\t\tif (mon) acquire('mon').catch(function (e) { mon = false; apply(); oops(e); });\n\t\t\telse release('mon');\n\t\t},\n\t\ttest: function () {\n\t\t\tif (tr) return;\n\t\t\tif (C.mute) return push({err: 'muted'});\n\t\t\tif (typeof MediaRecorder === 'undefined') return push({err: 'rec'});\n\t\t\tstopPlay();\n\t\t\tvar me = tr = {t0: 0, r: null};\n\t\t\tacquire('test').then(function (s) {\n\t\t\t\tif (tr !== me) { release('test'); return; }\n\t\t\t\tvar parts = [], r, m = mime(), opt = {audioBitsPerSecond: 32000};\n\t\t\t\tif (m) opt.mimeType = m;\n\t\t\t\ttry { r = new MediaRecorder(s, opt); } catch (e) { tr = null; release('test'); return push({err: 'rec'}); }\n\t\t\t\tme.r = r;\n\t\t\t\tr.ondataavailable = function (e) { if (e.data && e.data.size) parts.push(e.data); };\n\t\t\t\tr.onstop = function () {\n\t\t\t\t\trelease('test');\n\t\t\t\t\tif (tr === me) tr = null;\n\t\t\t\t\tif (clip) URL.revokeObjectURL(clip);\n\t\t\t\t\tclip = parts.length ? URL.createObjectURL(new Blob(parts, {type: (r.mimeType || m || 'audio/webm').split(';')[0]})) : '';\n\t\t\t\t\tif (!clip) push({err: 'rec'});\n\t\t\t\t};\n\t\t\t\tme.t0 = Date.now();\n\t\t\t\tr.start();\n\t\t\t\tsetTimeout(function () { if (r.state !== 'inactive') r.stop(); }, 5000);\n\t\t\t}, function (e) { if (tr === me) tr = null; oops(e); });\n\t\t},\n\t\tplay: function () {\n\t\t\tif (au) return stopPlay();\n\t\t\tif (!clip) return push({err: 'noclip'});\n\t\t\tvar a = au = new Audio(clip);\n\t\t\ta.onended = function () { if (au === a) au = null; };\n\t\t\ta.play().catch(function () { if (au === a) { au = null; push({err: 'play'}); } });\n\t\t},\n\t\tidle: function () {\n\t\t\tstopPlay();\n\t\t\tif (tr && tr.r && tr.r.state !== 'inactive') tr.r.stop();\n\t\t\tapi.monitor(false);\n\t\t},\n\t\tpoll: function () {\n\t\t\tvar o = out;\n\t\t\tout = [];\n\t\t\tvar r = {run: raw ? 1 : 0, wait: pend ? 1 : 0, lvl: meter(), db: g.db, open: g.open ? 1 : 0, gthr: (g.thr + 70) / 60,\n\t\t\t\tns: A && raw ? (A.rnOn ? 2 : A.nsb) : -1, rate: A ? A.ctx.sampleRate : 0, mon: mon ? 1 : 0,\n\t\t\t\ttrec: tr ? (tr.r ? Date.now() - tr.t0 : 0) : -1, clip: clip ? 1 : 0, play: au ? 1 : 0, out: o};\n\t\t\tif (devs) { r.devs = devs; devs = null; }\n\t\t\treturn JSON.stringify(r);\n\t\t}\n\t};\n\t['pointerdown', 'keydown', 'touchend'].forEach(function (n) { window.addEventListener(n, resume, true); });\n\tif (navigator.mediaDevices && navigator.mediaDevices.addEventListener)\n\t\tnavigator.mediaDevices.addEventListener('devicechange', function () { api.devices(); });\n})();"

























































































































































































































































































































































static var bridge: Callable
static var calls: Array = []
static var pack: Object = null
static var _shared: Variant = null

var installed: bool = false
var running: bool = false
var waiting: bool = false
var level_now: float = 0.0
var gate_open: bool = true
var gate_level: float = 0.35
var ns_active: int = -1
var sample_rate: int = 0
var monitoring: bool = false
var test_ms: int = -1
var has_clip: bool = false
var playing: bool = false
var devices: Array = []
var _cbs: Array[Callable] = []
var _poll_at: float = -1000.0
var _tree: SceneTree = null


static func shared() -> Variant:
	if _shared == null:
		_shared = load("res://ui/mic_engine.gd").new()
	return _shared


static func reset() -> void :
	if _shared != null:
		_shared._untick()
	_shared = null
	bridge = Callable()
	calls = []
	pack = null

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
	Settings.watch(_on_setting)


func prepare() -> bool:
	if not usable():
		return false
	if not installed:
		installed = true
		_js(JS)
		_push()
		_tick()
	return true


func config() -> Dictionary:
	return {
		"dev": str(Settings.value("mic_device")), "gain": float(Settings.value("mic_gain")) / 100.0, "mute": Settings.on("mic_mute"), 
		"ns": int(Settings.value("mic_ns")), "ec": Settings.on("mic_ec"), "agc": Settings.on("mic_agc"), "gate": Settings.level("mic_gate"), 
		"auto": Settings.on("mic_gate_auto"), "mode": str(Settings.value("mic_mode")), 
		"urls": {"js": _url(FILES.js), "wasm": _url(FILES.wasm), "simd": _url(FILES.simd)}, 
	}

func _push() -> void :
	if installed:
		_js("window.__bbmic.cfg(%s)" % JSON.stringify(config()))

func _on_setting(key: String) -> void :
	if key.is_empty() or key.begins_with("mic_"):
		_push()

func _url(file: String) -> String:
	var found: Object = pack if pack != null else _find_pack()
	if found != null and found.has_method("url"):
		return str(found.call("url", DIR + file))
	return "a/" + DIR + file

func _find_pack() -> Object:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var level: Array[Node] = [tree.root]
	for _depth in range(3):
		var next: Array[Node] = []
		for node: Node in level:
			for child: Node in node.get_children():
				var script: Script = child.get_script() as Script
				if script != null and script.resource_path == "res://battle/asset_pack.gd":
					return child
				next.append(child)
		level = next
	return null



func set_device(id: String) -> void :
	Settings.put("mic_device", id)

func set_gain(percent: int) -> void :
	Settings.put("mic_gain", percent)

func set_mute(on: bool) -> void :
	Settings.put("mic_mute", on)


func set_ns(value: int) -> void :
	Settings.put("mic_ns", value)

func set_ec(on: bool) -> void :
	Settings.put("mic_ec", on)

func set_agc(on: bool) -> void :
	Settings.put("mic_agc", on)


func set_gate(value: float, auto: bool) -> void :
	Settings.put("mic_gate", value)
	Settings.put("mic_gate_auto", auto)


func set_mode(mode: String) -> void :
	Settings.put("mic_mode", mode)

func set_ptt_key(keycode: int) -> void :
	Settings.put("mic_ptt_key", keycode)




func list_devices(cb: Callable) -> void :
	if not prepare():
		cb.call([])
		return
	_cbs.append(cb)
	_js("window.__bbmic.devices()")
	_poll_at = -1000.0


func level() -> float:
	poll()
	return level_now


func monitor(on: bool) -> void :
	if not prepare():
		if on:
			error.emit("nomic")
		return
	if on and not AndroidVoice.mic_ready(_monitor_after, _perm_denied):
		return
	monitoring = on
	_js("window.__bbmic.monitor(%s)" % ("true" if on else "false"))
	_poll_at = -1000.0


func test_record() -> void :
	if not prepare():
		error.emit("nomic")
		return
	if not AndroidVoice.mic_ready(test_record, _perm_denied):
		return
	_js("window.__bbmic.test()")
	_poll_at = -1000.0

func _monitor_after() -> void :
	monitor(true)

func _perm_denied() -> void :
	error.emit("deny")


func test_play() -> void :
	if not prepare():
		return
	_js("window.__bbmic.play()")
	_poll_at = -1000.0


func idle() -> void :
	if installed:
		monitoring = false
		_js("window.__bbmic.idle()")
		_poll_at = -1000.0

func busy() -> bool:
	return running or waiting or test_ms >= 0 or playing or monitoring


func poll() -> void :
	if not installed:
		return
	var now: float = Time.get_ticks_msec() / 1000.0
	if now - _poll_at < (POLL_BUSY if busy() or not _cbs.is_empty() else POLL_IDLE):
		return
	_poll_at = now
	var data: Variant = SafeJson.parse(str(_js("window.__bbmic?window.__bbmic.poll():''")))
	if not data is Dictionary:
		return
	running = int(data.get("run", 0)) == 1
	waiting = int(data.get("wait", 0)) == 1
	level_now = clampf(float(data.get("lvl", 0.0)), 0.0, 1.0)
	gate_open = int(data.get("open", 1)) == 1
	gate_level = clampf(float(data.get("gthr", 0.35)), 0.0, 1.0)
	ns_active = int(data.get("ns", -1))
	sample_rate = int(data.get("rate", 0))
	monitoring = int(data.get("mon", 0)) == 1
	test_ms = int(data.get("trec", -1))
	has_clip = int(data.get("clip", 0)) == 1
	playing = int(data.get("play", 0)) == 1
	for raw: Variant in data.get("out", []):
		if raw is Dictionary and raw.has("err"):
			error.emit(str(raw.err))
	if data.get("devs") is Array:
		devices = []
		for item: Variant in data.devs:
			if item is Dictionary:
				devices.append({"id": str(item.get("id", "")), "label": str(item.get("label", ""))})
		var waiting_cbs: Array[Callable] = _cbs
		_cbs = []
		for cb: Callable in waiting_cbs:
			if cb.is_valid():
				cb.call(devices.duplicate(true))
		devices_changed.emit(devices.duplicate(true))

func _tick() -> void :
	_tree = Engine.get_main_loop() as SceneTree
	if _tree != null and not _tree.process_frame.is_connected(poll):
		_tree.process_frame.connect(poll)

func _untick() -> void :
	if _tree != null and _tree.process_frame.is_connected(poll):
		_tree.process_frame.disconnect(poll)
	_tree = null


static func error_text(code: String) -> String:
	match code:
		"deny", "nomic":
			return str(load("res://ui/chat_media.gd").call("error_text", {"error": code}))
		"lost":
			return "Không thấy mic đã chọn — đang dùng mic mặc định."
		"ns":
			return "Trình duyệt này không chạy được chống ồn Nâng cao — đang dùng chống ồn Cơ bản."
		"rec":
			return "Trình duyệt này không ghi thử được."
		"noclip":
			return "Chưa có bản ghi thử — bấm Ghi thử trước."
		"play":
			return "Không phát được bản ghi thử."
		"muted":
			return "Mic đang tắt — bật mic trong Cài đặt rồi thử lại."
	return ""
