extends RefCounted





const MAX_MACS: int = 4
const MAX_DISKS: int = 2
const BOARD_PS: String = "$ErrorActionPreference='SilentlyContinue';'bios='+(Get-CimInstance Win32_ComputerSystemProduct).UUID;'mb='+(Get-CimInstance Win32_BaseBoard).SerialNumber;Get-CimInstance Win32_DiskDrive | Where-Object { $_.InterfaceType -ne 'USB' } | ForEach-Object { 'dsk='+$_.SerialNumber }"
const BOARD_JUNK_RE: String = "(?i)\\bo\\.?e\\.?m\\b|default string|to be filled|not (applicable|specified|available)|system serial|base ?board serial|serial ?number|^none$|^n/?a$|^03000200-0400-0500-0006-000700080009$"
const VIRTUAL_RE: String = "(?i)virtual|vmware|virtualbox|hyper-v|vethernet|tap-|wintun|wireguard|vpn|loopback|bluetooth|npcap|zerotier|hamachi|radmin|teredo|docker|miniport|tunnel"

var run: Callable
var unique: Callable
var raw: Array = []

func collect() -> void :
	var out: Array = []
	for mac: String in macs(_exec("getmac", ["/fo", "csv", "/nh", "/v"])):
		out.append(["mac", mac])
	out.append(["hw", machine_guid(_exec("reg", ["query", "HKLM\\SOFTWARE\\Microsoft\\Cryptography", "/v", "MachineGuid", "/reg:64"]))])
	out.append(["uid", str(unique.call()) if unique.is_valid() else OS.get_unique_id()])
	out.append_array(board(_exec("powershell", ["-NoProfile", "-NonInteractive", "-Command", BOARD_PS])))
	raw = out

func _exec(exe: String, args: Array) -> String:
	if run.is_valid():
		return str(run.call(exe, args))
	var lines: Array = []
	if OS.execute(exe, PackedStringArray(args), lines, false, false) != 0:
		return ""
	return "\n".join(PackedStringArray(lines))

static func macs(text: String) -> Array:
	var skip: RegEx = RegEx.create_from_string(VIRTUAL_RE)
	var hexre: RegEx = RegEx.create_from_string("(?i)\\b([0-9a-f]{2})[-:]([0-9a-f]{2})[-:]([0-9a-f]{2})[-:]([0-9a-f]{2})[-:]([0-9a-f]{2})[-:]([0-9a-f]{2})\\b")
	var found: Array = []
	for line: String in text.split("\n", false):
		var cols: PackedStringArray = line.strip_edges().trim_prefix("\"").trim_suffix("\"").split("\",\"")
		if cols.size() < 3 or skip.search(cols[0] + " " + cols[1]) != null:
			continue
		var m: RegExMatch = hexre.search(cols[2])
		if m == null:
			continue
		var mac: String = ""
		for i in range(1, 7):
			mac += m.get_string(i).to_upper()
		if mac == "000000000000" or (mac.substr(0, 2).hex_to_int() & 2) != 0 or found.has(mac):
			continue
		found.append(mac)
	found.sort()
	return found.slice(0, MAX_MACS)

static func machine_guid(text: String) -> String:
	var m: RegExMatch = RegEx.create_from_string("(?i)MachineGuid\\s+REG_SZ\\s+([0-9a-f-]{36})").search(text)
	return m.get_string(1).to_lower() if m != null else ""


static func board(text: String) -> Array:
	var junk: RegEx = RegEx.create_from_string(BOARD_JUNK_RE)
	var one: Dictionary = {}
	var disks: Array = []
	for line: String in text.split("\n", false):
		var eq: int = line.find("=")
		if eq <= 0:
			continue
		var kind: String = line.substr(0, eq).strip_edges()
		var value: String = line.substr(eq + 1).strip_edges()
		var bare: String = value.to_upper().replace("-", "").replace(" ", "").replace(".", "").replace("_", "")
		if value.length() < 4 or bare.replace("0", "").is_empty() or bare.replace("F", "").is_empty() or junk.search(value) != null:
			continue
		if kind == "bios" or kind == "mb":
			if not one.has(kind):
				one[kind] = value
		elif kind == "dsk" and not disks.has(value):
			disks.append(value)
	var out: Array = []
	for kind: String in ["bios", "mb"]:
		if one.has(kind):
			out.append([kind, one[kind]])
	disks.sort()
	for d: String in disks.slice(0, MAX_DISKS):
		out.append(["dsk", d])
	return out
