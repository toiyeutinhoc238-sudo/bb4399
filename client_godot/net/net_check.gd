extends RefCounted











const St2Skin = preload("res://ui/st2_skin.gd")
const Sound = preload("res://audio.gd")


const SETTINGS_READS: Array[String] = []
const ROUNDS: int = 10
const GAP_MS: int = 500
const WAIT_MS: int = 3000
const GRACE_MS: int = 2000

const PING_LATE_MS: int = 1500
const NORMAL_PING: int = 400
const IDLE_STALL: float = 12.0
const JAVA_CLASS: String = "vn.loanchien.net1.Net1"
const OUTER: String = "res://net/net_check.gd"

const BG: Color = Color("061a33")
const ROW_EDGE: Color = Color("2d6fb3")
const SEG: Color = Color("12407a")
const SEG_EDGE: Color = Color("4f9be0")
const ACCENT: Color = Color("ffb630")
const SOFT: Color = Color("9fc3ea")
const GOOD: Color = Color("7ff179")
const BAD: Color = Color("ff6b5a")
const IDLE_CELL: Color = Color("244a78")


static func open_net_check(host: Control) -> Control:
	for child: Node in host.get_children():
		if child is CheckView and not child.is_queued_for_deletion():
			return child
	var panel: CheckView = CheckView.new()
	panel.client = host.get("client")
	panel.host = host
	host.add_child(panel)
	panel.start()
	return panel


static func stats(samples: Array, lost: int) -> Dictionary:
	var sent: int = samples.size() + lost
	var out: Dictionary = {"avg": -1, "jitter": -1, "loss": -1, "sent": sent}
	if sent == 0:
		return out
	out["loss"] = roundi(100.0 * lost / sent)
	if samples.is_empty():
		return out
	var total: float = 0.0
	for ms: Variant in samples:
		total += float(ms)
	out["avg"] = roundi(total / samples.size())
	if samples.size() >= 2:
		var diff: float = 0.0
		for i: int in range(1, samples.size()):
			diff += absf(float(samples[i]) - float(samples[i - 1]))
		out["jitter"] = roundi(diff / (samples.size() - 1))
	else:
		out["jitter"] = 0
	return out


static func verdict(s: Dictionary) -> Array:
	if int(s.get("sent", 0)) == 0:
		return ["Chưa đo", SOFT]
	if int(s["avg"]) < 0:
		return ["Không có trả lời từ máy chủ", BAD]
	if int(s["loss"]) >= 30 or int(s["avg"]) > NORMAL_PING:
		return ["Mạng yếu", BAD]
	if int(s["loss"]) > 0 or int(s["avg"]) >= 200 or int(s["jitter"]) >= 80:
		return ["Tạm được", ACCENT]
	return ["Ổn định", GOOD]

static func ping_color(ms: int) -> Color:
	if ms < 0:
		return SOFT
	return GOOD if ms < 100 else (ACCENT if ms < 200 else BAD)

static func kind_text(kind: String) -> String:
	match kind:
		"wifi":
			return "Wi-Fi"
		"cell", "cellular", "wimax":
			return "4G (di động)"
		"eth", "ethernet":
			return "Có dây"
		"vpn":
			return "VPN"
		"none":
			return "Không có mạng"
	return "Không rõ"


static func network_kind() -> String:
	if OS.has_feature("android") and Engine.has_singleton("JavaClassWrapper"):
		var java: Variant = Engine.get_singleton("JavaClassWrapper").call("wrap", JAVA_CLASS)
		if _has_java(java, "kind"):
			var ctx: Variant = null
			if Engine.has_singleton("AndroidRuntime"):
				ctx = Engine.get_singleton("AndroidRuntime").call("getApplicationContext")
			return str((java as Object).call("kind", ctx))
		return ""
	if OS.has_feature("web"):
		var got: Variant = JavaScriptBridge.eval("(navigator.connection && navigator.connection.type) || ''", true)
		return str(got) if got != null else ""
	return ""


static func _has_java(o: Variant, method: String) -> bool:
	if not (o is Object) or not is_instance_valid(o):
		return false
	var obj: Object = o
	if obj.has_method(method):
		return true
	if obj.has_method("has_java_method"):
		return bool(obj.call("has_java_method", method))
	return false


static func online(client: Object) -> bool:
	if client == null or not is_instance_valid(client) or client.get("_channel") == null:
		return false
	return str(client.get("_role")) == "gate" and not (str(client.get("_phase")) in ["connect", "version"])

static func pending_ms(client: Object, now: int) -> int:
	var sent: int = int(client.get("_ping_sent"))
	return maxi(0, now - sent) if sent > 0 else 0


static func link_bad(client: Object, now: int) -> bool:
	if not online(client):
		return true
	if client.has_method("reconnecting") and bool(client.call("reconnecting")):
		return true
	return pending_ms(client, now) > PING_LATE_MS or float(client.get("_idle")) > IDLE_STALL or int(client.get("latency_ms")) > NORMAL_PING



class CheckView extends Control:
	var client: Object = null
	var host: Control = null
	var clock: Callable = Callable()
	var kind: String = ""
	var samples: Array = []
	var marks: Array = []
	var lost: int = 0
	var round_no: int = 0
	var phase: String = "idle"
	var _base: int = 0
	var _at: int = 0
	var _press: String = ""
	var _hits: Dictionary = {}
	var _k: float = 1.0

	func _init() -> void :
		name = "NetCheck"
		set_anchors_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_STOP
		focus_mode = Control.FOCUS_NONE

	func now_ms() -> int:
		return int(clock.call()) if clock.is_valid() else Time.get_ticks_msec()

	func running() -> bool:
		return phase in ["prior", "gap", "sent", "stale"]


	func start() -> void :
		kind = NetCheck_kind()
		samples.clear()
		marks.clear()
		lost = 0
		round_no = 0
		if not NetCheck_online(client):
			phase = "idle"
			queue_redraw()
			return
		var now: int = now_ms()
		_base = int(client.get("ping_count"))
		_at = now

		phase = "prior" if int(client.get("_ping_sent")) > 0 else "gap"
		queue_redraw()

	func step() -> void :
		if not running():
			return
		if not NetCheck_online(client):
			phase = "done"
			return
		var now: int = now_ms()
		var count: int = int(client.get("ping_count"))
		match phase:
			"prior":
				if count != _base or now - _at >= WAIT_MS:
					phase = "gap"
					_at = now
			"gap":
				if now - _at >= (0 if round_no == 0 else GAP_MS):
					round_no += 1
					_base = count
					_at = now
					var cfg: Variant = client.get("config")
					var every: float = float(cfg.get("ping_seconds")) if cfg is Object else 10.0
					client.set("_ping", maxf(every, float(client.get("_ping"))))
					phase = "sent"
			"sent":
				if count != _base and int(client.get("_ping_sent")) == 0:
					var ms: int = int(client.get("latency_ms"))
					if ms >= 0 and ms <= PING_LATE_MS:
						samples.append(ms)
						marks.append(ms)
					else:
						lost += 1
						marks.append(-1)
					_next(now)
				elif now - _at >= WAIT_MS:
					lost += 1
					marks.append(-1)
					phase = "stale"
					_base = count
					_at = now
			"stale":
				if count != _base or now - _at >= GRACE_MS:
					_next(now)

	func _next(now: int) -> void :
		_at = now
		phase = "done" if round_no >= ROUNDS else "gap"

	func result() -> Dictionary:
		return NetCheck_stats(samples, lost)

	func close() -> void :
		phase = "done"
		if host != null and is_instance_valid(host):
			host.queue_redraw()
		queue_free()

	func _process(_delta: float) -> void :
		step()
		queue_redraw()


	func _outer() -> Script:
		return load(OUTER)

	func NetCheck_kind() -> String:
		return kind if clock.is_valid() and not kind.is_empty() else str(_outer().call("network_kind"))

	func NetCheck_online(c: Object) -> bool:
		return bool(_outer().call("online", c))

	func NetCheck_stats(s: Array, l: int) -> Dictionary:
		return _outer().call("stats", s, l)



	func _r(x: float, y: float, w: float, h: float) -> Rect2:
		return Rect2(Vector2(x, y) * _k, Vector2(w, h) * _k)

	func _t(value: String, x: float, yc: float, px: float, wide: float, color: Color, align: String = "l", font: Font = St2Skin.BOLD) -> void :
		St2Skin.words(self, font, value, px * _k, _r(x, yc - px, wide, px * 2.0), color, align, Color(0, 0, 0, 0.55), maxf(1.0, 1.6 * _k))

	func _b(r: Rect2, fill: Color, edge: Color, radius: float, width: float = 1.5) -> void :
		var box: StyleBoxFlat = StyleBoxFlat.new()
		box.bg_color = fill
		box.border_color = edge
		box.set_corner_radius_all(maxi(1, roundi(radius * _k)))
		box.set_border_width_all(maxi(1, roundi(width * _k)) if edge.a > 0.0 else 0)
		box.anti_aliasing = true
		draw_style_box(box, r)

	func _draw() -> void :
		var outer: Script = _outer()
		_k = maxf(0.05, minf(size.x / 960.0, size.y / 540.0))
		_hits.clear()
		draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.6))
		var w: float = 600.0
		var h: float = 460.0
		var x: float = (size.x / _k - w) / 2.0
		var y: float = (size.y / _k - h) / 2.0
		var card: Rect2 = _r(x, y, w, h)
		_hits["card"] = card
		_b(card, Color(BG, 0.97), Color(ROW_EDGE, 0.8), 14.0, 2.0)
		_t("KIỂM TRA MẠNG", x + 24.0, y + 30.0, 20, 400, ACCENT, "l", St2Skin.XBOLD)
		_t("Ping tới máy chủ game · %d lần, cách nhau 0,5 s" % ROUNDS, x + 24.0, y + 56.0, 12, 440, SOFT)
		var shut: Rect2 = _r(x + w - 52.0, y + 10.0, 40, 40)
		_hits["close"] = shut
		_b(shut, Color(SEG, 0.9 if _press != "close" else 0.6), Color(SEG_EDGE, 0.7), 8.0)
		_t("X", x + w - 52.0, y + 30.0, 18, 40, Color.WHITE, "c", St2Skin.XBOLD)
		var now: int = now_ms()
		var up: bool = bool(outer.call("online", client))
		var bad: bool = bool(outer.call("link_bad", client, now))
		var s: Dictionary = result()
		var head: Array
		if not up:
			head = ["Chưa nối máy chủ game", BAD]
		elif running():
			head = ["Đang đo %d/%d…" % [maxi(1, round_no), ROUNDS], Color.WHITE]
		else:
			head = outer.call("verdict", s)
		var dot: Color = BAD if bad else GOOD
		if not bad or (Time.get_ticks_msec() / 250) % 2 == 0:
			draw_circle(Vector2(x + 34.0, y + 92.0) * _k, 8.0 * _k, dot)
		_t(str(head[0]), x + 52.0, y + 92.0, 17, 500, head[1], "l", St2Skin.XBOLD)
		var cell_w: float = (w - 48.0 - 6.0 * (ROUNDS - 1)) / ROUNDS
		for i: int in ROUNDS:
			var c: Color = IDLE_CELL
			if i < marks.size():
				c = BAD if int(marks[i]) < 0 else outer.call("ping_color", int(marks[i]))
			elif running() and i == marks.size():
				c = Color(SOFT, 0.55 if (Time.get_ticks_msec() / 250) % 2 == 0 else 0.25)
			_b(_r(x + 24.0 + i * (cell_w + 6.0), y + 112.0, cell_w, 10.0), c, Color(0, 0, 0, 0), 4.0, 0.0)
		var live: int = int(client.get("latency_ms")) if up else -1
		var wait: int = int(outer.call("pending_ms", client, now)) if up else 0
		var idle: float = float(client.get("_idle")) if up else -1.0
		var avg: int = int(s["avg"])
		var jit: int = int(s["jitter"])
		var loss: int = int(s["loss"])
		var rows: Array = [
			["Loại mạng", str(outer.call("kind_text", kind)), Color.WHITE], 
			["Ping hiện tại", ("chờ %d ms" % wait) if wait > PING_LATE_MS else (("%d ms" % live) if live >= 0 else "—"), 
				BAD if wait > PING_LATE_MS or live > NORMAL_PING else outer.call("ping_color", live)], 
			["Ping trung bình (%d lần)" % ROUNDS, ("%d ms" % avg) if avg >= 0 else "—", outer.call("ping_color", avg)], 
			["Độ dao động (jitter)", ("%d ms" % jit) if jit >= 0 else "—", SOFT if jit < 0 else (GOOD if jit < 30 else (ACCENT if jit < 80 else BAD))], 
			["Mất / trễ quá 1,5 s (ước tính)", ("%d %%" % loss) if loss >= 0 else "—", SOFT if loss < 0 else (GOOD if loss == 0 else (ACCENT if loss < 20 else BAD))], 
			["Dữ liệu từ máy chủ", "—" if idle < 0 else ("vừa nhận" if idle < 1.0 else "%d s trước" % int(idle)), 
				SOFT if idle < 0 else (BAD if idle > IDLE_STALL else GOOD)], 
		]
		for i: int in rows.size():
			var yc: float = y + 156.0 + 40.0 * i
			if i > 0:
				draw_rect(_r(x + 24.0, yc - 20.0, w - 48.0, 1.0), Color(ROW_EDGE, 0.35))
			_t(str(rows[i][0]), x + 28.0, yc, 15, 300, SOFT)
			_t(str(rows[i][1]), x + w - 288.0, yc, 16, 260, rows[i][2], "r", St2Skin.XBOLD)
		var busy: bool = running() or not up
		var btn: Rect2 = _r(x + (w - 240.0) / 2.0, y + 392.0, 240, 48)
		_hits["again"] = btn
		var fill: Color = Color("1f6fd1") if _press != "again" else Color("17559f")
		_b(btn, Color(fill, 0.45 if busy else 1.0), Color(SEG_EDGE, 0.5 if busy else 1.0), 10.0, 2.0)
		St2Skin.words(self, St2Skin.XBOLD, "ĐANG ĐO…" if running() else "KIỂM TRA LẠI", 16.0 * _k, btn.grow(-6.0 * _k), 
			Color(1, 1, 1, 0.6 if busy else 1.0), "c", Color("08295a"), maxf(1.0, 2.0 * _k))

	func _hit_at(p: Vector2) -> String:
		for id: String in ["close", "again", "card"]:
			if _hits.has(id) and (_hits[id] as Rect2).has_point(p):
				return id
		return "shade"

	func _gui_input(event: InputEvent) -> void :
		if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
			var button: InputEventMouseButton = event
			var id: String = _hit_at(button.position)
			if button.pressed:
				_press = id
			else:
				var was: String = _press
				_press = ""
				if id == was:
					_tap(id)
		accept_event()

	func _tap(id: String) -> void :
		if id == "close" or id == "shade":
			Sound.click()
			close()
		elif id == "again" and not running() and NetCheck_online(client):
			Sound.click()
			start()

	func _input(event: InputEvent) -> void :
		if not is_visible_in_tree() or not (event is InputEventKey):
			return
		var key: InputEventKey = event

		if key.pressed and not key.echo and (key.keycode == KEY_ESCAPE or key.physical_keycode == KEY_ESCAPE):
			close()
			get_viewport().set_input_as_handled()
