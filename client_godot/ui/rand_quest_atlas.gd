extends RefCounted

const FILE: String = "res://assets/ui/hall/rand_quest.png"

const R: Dictionary = {
	"rq_close": [308, 554, 24, 24], 
	"rq_frame": [2, 2, 659, 550], 
	"rq_get": [2, 554, 100, 33], 
	"rq_goto": [104, 554, 100, 33], 
	"rq_has": [663, 2, 92, 59], 
	"rq_icon": [757, 2, 50, 50], 
	"rq_icon_has": [809, 2, 50, 50], 
	"rq_icon_has_white": [861, 2, 50, 50], 
	"rq_join": [206, 554, 100, 33], 
	"rq_refresh": [913, 2, 34, 34], 
	"rq_refresh_off": [949, 2, 34, 34], 
}

const SIZE = [680, 570]

const FRAME = [19, 18]

const CLOSE = [642, 33, 24, 24]

const TITLE = [175, 16, 330, 52]

const LIST = [39, 76, 603, 445]

const CVS = [592, 116]

const STEP = 111

const BAR = 19

const BG = [3, 7]

const GUILD_T = [1, 7]

const REFRESH = [416, 15]

const JOIN = [465, 36, 100, 40]

const BTN = [465, 36]

const BTN_FLASH = [465, 36, 100, 40]

const HAS = [473, 26]

const GOLD = [20, 23]

const NAME_T = [110, 24]

const TIP = [50, 529]

const TEXTS = {"lblAward": [6, 81, 103, 0, 12, "ffe430", 1, "c"], "lblCheckName": [160, 21, 295, 0, 14, "ffffff", 1, "l"], "lblCheckCount": [352, 32.5, 53, 0, 14, "ffffff", 1, "l"], "lblCheckDesc": [110, 66, 300, 45, 12, "c0d6ff", 1, "l"]}

const FRAMES = 26

const BOB = [0.0, -0.25, -0.5, -0.75, -1.0, -1.25, -1.5, -1.75, -2.0, -2.25, -2.5, -2.75, -3.0, -2.75, -2.55, -2.3, -2.1, -1.85, -1.6, -1.4, -1.15, -0.9, -0.7, -0.45, -0.25, 0.0]

const GLOW = [0.0, 0.0431, 0.0824, 0.1255, 0.1686, 0.2078, 0.251, 0.2941, 0.3333, 0.3765, 0.4196, 0.4588, 0.502, 0.4627, 0.4235, 0.3843, 0.349, 0.3098, 0.2706, 0.2314, 0.1922, 0.1529, 0.1176, 0.0784, 0.0392, 0.0]

const SIDE = 50

const REFRESH_MAX = 3

const QUESTS = {"34001": [34, 0, "Nhiệm vụ ngày", "Hoàn thành 3 nhiệm vụ ngày bên dưới", 3, 10000], "35001": [35, 1, "Chiến binh", "Tham gia 3 trận PvP", 3, 4000], "35002": [35, 1, "Thắng lợi", "Thắng 2 trận PvP", 2, 5000], "35003": [35, 1, "Bền bỉ", "Tham gia 5 trận PvP", 5, 6000], "37001": [37, 2, "Xe tủ", "Thắng 2 trận PvP bằng tank đã sở hữu", 2, 5000], "37002": [37, 2, "Chiến xa quen thuộc", "Tham gia 3 trận PvP bằng tank đã sở hữu", 3, 4000], "40001": [40, 4, "Nâng cấp", "Nâng cấp hoặc cường hoá tank 1 lần", 1, 3000], "39001": [39, 3, "Quân đoàn", "Tham gia 3 trận PvP khi đã vào quân đoàn", 3, 5000]}
