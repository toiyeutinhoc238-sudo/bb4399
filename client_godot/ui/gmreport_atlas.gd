extends RefCounted

const FILE: String = "res://assets/ui/hall/gmreport.png"

const R: Dictionary = {
	"gmr_check_off": [198, 2, 27, 26], 
	"gmr_check_on": [169, 2, 27, 27], 
	"gmr_confirm": [2, 2, 120, 35], 
	"gmr_player": [251, 2, 28, 14], 
	"gmr_report": [227, 2, 22, 22], 
	"gmr_title": [124, 2, 43, 27], 
}

const FRAME = [398, 396]

const NODES = {"title": [177.5, 19, 43, 27], "player": [50, 68, 28, 14], "level": [203, 105, 56, 28], "confirm": [139, 344, 120, 35]}

const NAME = [203, 138, 152, 24, 16, "005797", 1, "l"]

const AVATAR = {"centre": [144, 135], "zoom": 0.5}

const WARN = [300, 18, "ffffff", 1]

const REASONS = [["AFK/Rời trận", 1], ["Phá trận", 8], ["Cố ý nộp mạng", 2], ["Dùng Auto/Bot", 16], ["Lăng mạ/Quấy rối", 4], ["Gian lận/Hack", 32], ["Quấy rối bằng mic", 64]]

const REASON_BOX = {"x": [37, 219], "y": 194, "step": 26, "icon": [27, 27], "gap": 6, "text": [14, "005797", 1]}

const REPORT = [278, 9, 22, 22]
