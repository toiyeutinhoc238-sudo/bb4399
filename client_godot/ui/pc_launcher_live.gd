extends RefCounted





const LAUNCHER: String = "res://pc_boot.gd"
const SCENE: String = "res://pc_boot.tscn"
const DROP: Array[String] = ["NẠP GAME"]

const RENAME: Dictionary = {}
const TITLE: String = "Tank Ghost"
const LOGO: String = "res://assets/brand/logo.png"
const Badge = preload("res://ui/pc_launcher_badge.gd")


const OLD_NAME: String = ""
const UNKEY: String = ""
const LINKS_DONE: String = "user://pbe_links.done"


static func apply(host: Node) -> int:
	if host == null or not is_launcher(host):
		return 0
	var n: int = 0
	for child: Node in host.get_children():
		if child is Button and (child as Button).text in DROP:
			host.remove_child(child)
			child.queue_free()
			n += 1
	_rename(host)
	if host.is_inside_tree():
		host.get_window().title = TITLE
	if false:
		rename_links(OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP), OS.get_environment("APPDATA").path_join("Microsoft/Windows/Start Menu/Programs"), 
			exe_tail(OS.get_executable_path()))
		var done: FileAccess = FileAccess.open(LINKS_DONE, FileAccess.WRITE)
		if done != null:
			done.store_string(TITLE)
	return n


static func exe_tail(exe: String) -> String:
	var parts: PackedStringArray = exe.replace("\\", "/").split("/", false)
	return "\\".join(parts.slice(-2)) if parts.size() >= 2 else ""


static func link_points_to(path: String, tail: String) -> bool:
	if tail.is_empty() or not FileAccess.file_exists(path):
		return false
	var raw: String = FileAccess.get_file_as_bytes(path).hex_encode()
	return raw.contains(tail.to_ascii_buffer().hex_encode()) or raw.contains(tail.to_utf16_buffer().hex_encode())



static func rename_links(desktop: String, menu: String, tail: String) -> int:
	var n: int = 0
	var old_link: String = desktop.path_join(OLD_NAME + ".lnk")
	if link_points_to(old_link, tail) and not FileAccess.file_exists(desktop.path_join(TITLE + ".lnk"))\
	and DirAccess.rename_absolute(old_link, desktop.path_join(TITLE + ".lnk")) == OK:
		n += 1
	var old_dir: String = menu.path_join(OLD_NAME)
	if link_points_to(old_dir.path_join(OLD_NAME + ".lnk"), tail) and not DirAccess.dir_exists_absolute(menu.path_join(TITLE))\
	and DirAccess.rename_absolute(old_dir.path_join(OLD_NAME + ".lnk"), old_dir.path_join(TITLE + ".lnk")) == OK:
		n += 1
		if DirAccess.rename_absolute(old_dir, menu.path_join(TITLE)) == OK:
			n += 1
	if n > 0 and OS.has_feature("windows"):
		OS.execute("reg", ["add", UNKEY, "/v", "DisplayName", "/d", TITLE, "/f"])
	return n


static func _rename(node: Node) -> void :
	for child: Node in node.get_children():
		if child is Label and RENAME.has((child as Label).text):
			(child as Label).text = str(RENAME[(child as Label).text])
		elif child is TextureRect and (child as TextureRect).texture != null and (child as TextureRect).texture.resource_path == LOGO\
		and child.get_node_or_null("PbeBadge") == null:
			child.add_child(Badge.new())
		_rename(child)


static func is_launcher(host: Node) -> bool:
	if host.scene_file_path == SCENE:
		return true
	var s: Script = host.get_script() as Script
	return s != null and s.resource_path == LAUNCHER
