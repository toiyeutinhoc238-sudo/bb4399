extends RefCounted





const REGULAR: FontVariation = preload("res://assets/fonts/flash_ui.tres")
const BOLD: FontVariation = preload("res://assets/fonts/flash_ui_bold.tres")
const OPEN_SANS: FontFile = preload("res://assets/fonts/OpenSans-VF.tres")


const ASK_JS: String = "(async function () {\n\tvar cb = window.__lcbbFontCb, key = 'lcbb_flash_fonts';\n\tfunction done() { delete window.__lcbbFontCb; if (cb) cb.apply(null, arguments); }\n\tfunction mark() { try { localStorage.setItem(key, 'asked'); } catch (e) {} }\n\ttry {\n\t\tif (!window.isSecureContext || typeof window.queryLocalFonts !== 'function') return done('unsupported');\n\t\tvar state = 'prompt';\n\t\ttry { state = (await navigator.permissions.query({name: 'local-fonts'})).state; } catch (e) {}\n\t\tif (state === 'denied') return done('denied');\n\t\tvar asked = '';\n\t\ttry { asked = localStorage.getItem(key) || ''; } catch (e) {}\n\t\tif (state !== 'granted' && asked) return done('asked');\n\t\tvar t0 = performance.now(), list;\n\t\ttry {\n\t\t\tlist = await window.queryLocalFonts({postscriptNames: ['Tahoma', 'Tahoma-Bold']});\n\t\t} catch (e) {\n\t\t\tif (e && e.name !== 'SecurityError') mark();\n\t\t\treturn done('error:' + (e && e.name || 'unknown'));\n\t\t}\n\t\tmark();\n\t\tvar pick = {};\n\t\tfor (var i = 0; i < list.length; i++) pick[list[i].postscriptName] = list[i];\n\t\tif (!pick['Tahoma'] || !pick['Tahoma-Bold']) return done('missing');\n\t\tvar regular = new Uint8Array(await (await pick['Tahoma'].blob()).arrayBuffer());\n\t\tvar bold = new Uint8Array(await (await pick['Tahoma-Bold'].blob()).arrayBuffer());\n\t\tdone('ok', regular, bold, Math.round(performance.now() - t0));\n\t} catch (e) {\n\t\tdone('error:' + (e && e.name || 'unknown'));\n\t}\n})();"






























static var state: String = ""
static var _callback: JavaScriptObject = null


static func ask() -> void :
	if state != "" or not OS.has_feature("web"):
		return
	state = "asking"
	_callback = JavaScriptBridge.create_callback( func(args: Array) -> void : _answered(args))
	JavaScriptBridge.get_interface("window").set("__lcbbFontCb", _callback)
	JavaScriptBridge.eval(ASK_JS, true)

static func _answered(args: Array) -> void :
	var result: String = str(args[0]) if args.size() > 0 else "error"
	if result != "ok" or args.size() < 3:
		state = "fallback:" + result
		return
	var regular: PackedByteArray = JavaScriptBridge.js_buffer_to_packed_byte_array(args[1])
	var bold: PackedByteArray = JavaScriptBridge.js_buffer_to_packed_byte_array(args[2])
	var started: int = Time.get_ticks_usec()
	if not use_local(regular, bold):
		state = "fallback:bad"
		return
	state = "local"

	print("flash_fonts: Tahoma của máy %d + %d KB, JS %d ms, Godot %d ms, 16 px ascent %d descent %d" % [regular.size() / 1024, 
		bold.size() / 1024, int(args[3]) if args.size() > 3 else -1, (Time.get_ticks_usec() - started) / 1000, 
		int(REGULAR.get_ascent(16)), int(REGULAR.get_descent(16))])


static func use_local(regular: PackedByteArray, bold: PackedByteArray) -> bool:
	if not _sfnt(regular) or not _sfnt(bold):
		return false
	var faces: Array[FontFile] = []
	for bytes: PackedByteArray in [regular, bold]:
		var face: FontFile = FontFile.new()
		face.antialiasing = OPEN_SANS.antialiasing
		face.hinting = OPEN_SANS.hinting
		face.subpixel_positioning = OPEN_SANS.subpixel_positioning
		face.allow_system_fallback = OPEN_SANS.allow_system_fallback
		face.data = bytes
		if face.get_font_name().is_empty():
			return false
		faces.append(face)
	REGULAR.set_base_font(faces[0])
	BOLD.set_base_font(faces[1])
	_redraw()
	return true


static func reset() -> void :
	REGULAR.set_base_font(OPEN_SANS)
	BOLD.set_base_font(OPEN_SANS)
	state = ""
	_redraw()


static func _sfnt(bytes: PackedByteArray) -> bool:
	if bytes.size() < 1024:
		return false
	var head: PackedByteArray = bytes.slice(0, 4)
	return head == PackedByteArray([0, 1, 0, 0]) or head == "true".to_ascii_buffer() or head == "OTTO".to_ascii_buffer()


static func _redraw() -> void :
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null and tree.root != null:
		tree.root.propagate_call(&"queue_redraw")
