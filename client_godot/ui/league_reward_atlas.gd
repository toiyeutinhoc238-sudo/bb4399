extends RefCounted

const FILE: String = "res://assets/ui/hall/league_reward.png"

const R: Dictionary = {
	"lr_aw_bg": [2, 555, 84, 84], 
	"lr_aw_gift": [489, 555, 58, 58], 
	"lr_aw_money": [549, 555, 50, 50], 
	"lr_close": [601, 555, 24, 24], 
	"lr_frame": [2, 2, 594, 551], 
	"lr_q1": [88, 555, 74, 74], 
	"lr_q2": [164, 555, 74, 74], 
	"lr_q3": [240, 555, 74, 74], 
	"lr_q4": [316, 555, 74, 74], 
	"lr_q5": [392, 555, 74, 74], 
	"lr_row": [620, 2, 360, 90], 
	"lr_sb_bk": [598, 2, 20, 100], 
	"lr_sb_down": [627, 555, 19, 19], 
	"lr_sb_thumb": [468, 555, 19, 64], 
	"lr_sb_up": [648, 555, 19, 19], 
}

const FRAME = [19, 18]

const SIZE = [615, 571]

const CLOSE = [577, 33, 24, 24]

const TITLE = [142.5, 16, 330, 52]

const LIST = [54, 84, 522, 451]

const BAR = 19

const ROW = [497, 170]

const ROW_BG = [0, 78]

const ROW_NAME = [5, 4, 0, 0, 18, "ffffff", 1, "l"]

const TILES = [[6, 43], [105, 43], [203, 43], [301, 43], [400, 43]]

const AWARD = {"bg": [3.5, 0], "quality": [9, 5], "item": [7.5, 4], "coin": [20.5, 7], "gift": [16.5, 3], "lblRewardName": [12.5, 78, 66, 0, 12, "ffffff", 1, "c"], "lblNum": [0.5, 82, 90, 0, 13, "ffffff", 1, "c"]}

const GIFT_NAME = "Xu Khóa"

const MONEY_NAME = "Bạc"

const PRIZES = [[2007101, "Quà Team Hạng 1", [["gift", 200], [3000001, 250, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 200, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 100, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007102, "Quà Team Hạng 2", [["gift", 150], [3000001, 200, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 150, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 70, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007103, "Quà Team Hạng 3", [["gift", 100], [3000001, 150, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 100, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 50, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007104, "Quà Team Hạng 4", [["gift", 50], [3000001, 100, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 50, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 30, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007105, "Quà Team Hạng 5", [["gift", 50], [3000001, 100, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 50, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 30, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007106, "Quà Team Hạng 6", [["gift", 50], [3000001, 100, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 50, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 30, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007107, "Quà Team Hạng 7", [["gift", 50], [3000001, 100, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 50, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 30, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007108, "Quà Team Hạng 8", [["gift", 50], [3000001, 100, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 50, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 30, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007109, "Quà Team Hạng 9", [["gift", 50], [3000001, 100, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 50, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 30, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]], [2007110, "Quà Team Hạng 10", [["gift", 50], [3000001, 100, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000052, 50, "Hồng Bảo", "icon_upitem_f_02", 1], [2004051, 30, "Huy chương vinh dự Team", "xunzhang_laodong", 2]]]]
