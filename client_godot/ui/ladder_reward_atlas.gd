extends RefCounted

const FILE: String = "res://assets/ui/hall/ladder_reward.png"

const R: Dictionary = {
	"lw_bg": [2, 2, 700, 358], 
	"lw_medal_bronze": [92, 362, 68, 72], 
	"lw_medal_diamon": [704, 2, 98, 102], 
	"lw_medal_epic": [804, 2, 119, 91], 
	"lw_medal_golden": [2, 362, 88, 82], 
	"lw_medal_platnum": [925, 2, 97, 87], 
	"lw_medal_silver": [162, 362, 71, 70], 
	"lw_title": [235, 362, 104, 35], 
}

const SIZE = [700, 358]

const TITLE = [255, -6]

const CLOSE = [665, 20]

const MEDALS = {"bronze": [49.6, 105.0], "silver": [146.4, 106.2], "golden": [237.9, 95.05], "platnum": [337.0, 90.28], "diamon": [435.0, 75.5], "epic": [524.0, 84.0]}

const ORDER = ["bronze", "silver", "golden", "platnum", "diamon", "epic"]

const LABELS = [["Đồng", 34, 188, 100], ["Bạc", 134, 188, 100], ["Vàng", 234, 188, 100], ["Bạch Kim", 334, 188, 100], ["Kim Cương", 434, 188, 100], ["Chỉ Huy", 534, 188, 100]]

const FIELDS = {"end": [44.0, 252.0, 650.0], "cur": [44.0, 282.0, 290.0], "pre": [344.0, 282.0, 315.0], "note": [44.0, 312.0, 650.0]}

const NOTE = "Kết thúc mùa giải sẽ phát khung theo huy chương."

const WORDS = {"end": "Thời gian kết thúc mùa giải này: @time@", "cur": "Hạng hiện tại: @name@", "pre": "Hạng mùa giải trước: @name@"}

const PX = 16

const GOLD = "ffea00"
