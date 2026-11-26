extends RefCounted

var origin: String = "http://127.0.0.1:8080"
var transport_kind: String = "websocket"
var websocket_origin: String = ""
var login_host: String = "127.0.0.1"
var login_port: int = 9000
var local_test_only: bool = false
var timeout_seconds: float = 15.0
var ping_seconds: float = 10.0


const DEFAULT_ORIGIN: String = "http://127.0.0.1:8080"
const DEFAULT_ASSET_ROOT: String = "http://127.0.0.1:8080/godot/a/"
const SERVER_CFG: String = "user://server.cfg"

const DIRECT_WS: String = ""
const DIRECT_PAGES: Array[String] = []
var fallback_ws_origin: String = ""
var direct_seconds: float = 4.0
var direct_off: bool = false

static func _load_override() -> ConfigFile:
	if OS.has_feature("web") or not FileAccess.file_exists(SERVER_CFG):
		return null
	var cfg: ConfigFile = ConfigFile.new()
	return cfg if cfg.load(SERVER_CFG) == OK else null

static func resolved_origin() -> String:
	var raw: String = str(ProjectSettings.get_setting("bangbang/android_origin", DEFAULT_ORIGIN)).strip_edges()
	if not OS.has_feature("web"):
		var env_origin: String = OS.get_environment("BB_ORIGIN").strip_edges()
		if not env_origin.is_empty():
			raw = env_origin
		var cfg: ConfigFile = _load_override()
		if cfg != null and cfg.has_section_key("bangbang", "origin"):
			var val: String = str(cfg.get_value("bangbang", "origin", "")).strip_edges()
			if not val.is_empty():
				raw = val
	return raw.trim_suffix("/") if not raw.is_empty() else DEFAULT_ORIGIN

static func resolved_asset_root() -> String:
	var cur_origin: String = resolved_origin()
	var raw: String = str(ProjectSettings.get_setting("bangbang/android_asset_root", "")).strip_edges()
	var custom_asset: bool = false
	if not OS.has_feature("web"):
		var cfg: ConfigFile = _load_override()
		if cfg != null and cfg.has_section_key("bangbang", "asset_root"):
			var val: String = str(cfg.get_value("bangbang", "asset_root", "")).strip_edges()
			if not val.is_empty():
				raw = val
				custom_asset = true
	if raw.is_empty() or ( not custom_asset and raw == DEFAULT_ASSET_ROOT and cur_origin != DEFAULT_ORIGIN):
		return cur_origin + "/godot/a/"
	return raw if raw.ends_with("/") else raw + "/"

static func resolved_update_page() -> String:
	var raw: String = str(ProjectSettings.get_setting("bangbang/android_page", "")).strip_edges()
	if not OS.has_feature("web"):
		var cfg: ConfigFile = _load_override()
		if cfg != null and cfg.has_section_key("bangbang", "android_page"):
			raw = str(cfg.get_value("bangbang", "android_page", "")).strip_edges()
	return raw

func _init() -> void :
	login_host = str(ProjectSettings.get_setting("bangbang/native_login_host", "127.0.0.1"))
	login_port = int(ProjectSettings.get_setting("bangbang/native_login_port", 9000))
	if not OS.has_feature("web"):
		var env_host: String = OS.get_environment("BB_LOGIN_HOST").strip_edges()
		if not env_host.is_empty():
			login_host = env_host
		var env_port: String = OS.get_environment("BB_LOGIN_PORT").strip_edges()
		if env_port.is_valid_int() and env_port.to_int() > 0:
			login_port = env_port.to_int()
		var cfg: ConfigFile = _load_override()
		if cfg != null:
			if cfg.has_section_key("bangbang", "login_host"):
				var h: String = str(cfg.get_value("bangbang", "login_host", "")).strip_edges()
				if not h.is_empty():
					login_host = h
			if cfg.has_section_key("bangbang", "login_port"):
				var p: int = int(cfg.get_value("bangbang", "login_port", login_port))
				if p >= 1 and p <= 65535:
					login_port = p
			if cfg.has_section_key("bangbang", "transport_kind"):
				var tk: String = str(cfg.get_value("bangbang", "transport_kind", "")).strip_edges()
				if tk in ["websocket", "tcp"]:
					transport_kind = tk
	var app: String = resolved_origin()
	if not app.is_empty():
		origin = app
	pick_websocket_route()

func pick_websocket_route() -> void :
	websocket_origin = origin.replace("https://", "wss://").replace("http://", "ws://")
	fallback_ws_origin = ""
	if origin in DIRECT_PAGES:
		fallback_ws_origin = websocket_origin
		websocket_origin = DIRECT_WS


func direct_ready() -> bool:
	return not fallback_ws_origin.is_empty() and not direct_off

func endpoint(role: String, region: Dictionary = {}) -> Dictionary:
	if role not in ["login", "gate", "comm"]:
		return {}
	if transport_kind == "websocket":
		if not websocket_origin.begins_with("ws://") and not websocket_origin.begins_with("wss://"):
			return {}
		var base: String = fallback_ws_origin if direct_off and not fallback_ws_origin.is_empty() else websocket_origin
		return {"url": base + "/ws/" + role, "origin": origin}
	var host: String = login_host if role == "login" else str(region.get(role + "_realm", "127.0.0.1"))
	var port: int = login_port if role == "login" else int(region.get(role + "_port", 9001))
	if host.is_empty() or port < 1 or port > 65535:
		return {}
	if local_test_only and (host != "127.0.0.1" or port in [9000, 9001, 41843]):
		return {}
	return {"host": host, "port": port}

func server_entry() -> Dictionary:

	return {"sid": 299001, "name": "BangBang", "ip": login_host, "port": login_port, 
		"isDefault": 1, "isMaintaining": 0, "cantCreate": 0, "openDesc": ""}
