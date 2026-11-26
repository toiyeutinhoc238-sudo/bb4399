extends RefCounted

const FILE: String = "res://assets/ui/hall/pve_result.png"

const R: Dictionary = {
	"pq_back": [444, 2455, 156, 47], 
	"pq_bg1": [2, 425, 1000, 390], 
	"pq_bg2": [2, 817, 1000, 390], 
	"pq_bg2_lose": [2, 1209, 1000, 390], 
	"pq_card": [250, 2364, 165, 83], 
	"pq_double": [655, 2364, 64, 63], 
	"pq_exp_title": [2, 2455, 440, 48], 
	"pq_glow_0": [2, 1601, 213, 211], 
	"pq_glow_1": [217, 1601, 213, 211], 
	"pq_glow_2": [432, 1601, 213, 211], 
	"pq_glow_3": [647, 1601, 213, 211], 
	"pq_glow_4": [2, 1814, 213, 211], 
	"pq_glow_5": [217, 1814, 213, 211], 
	"pq_glow_6": [432, 1814, 213, 211], 
	"pq_glow_7": [647, 1814, 213, 211], 
	"pq_glow_8": [2, 2027, 213, 211], 
	"pq_glow_9": [217, 2027, 213, 211], 
	"pq_lose": [417, 2364, 117, 67], 
	"pq_num5": [330, 2505, 330, 38], 
	"pq_panel": [2, 2, 477, 421], 
	"pq_rank_1": [872, 2455, 80, 40], 
	"pq_rank_2": [2, 2505, 80, 40], 
	"pq_rank_3": [84, 2505, 80, 40], 
	"pq_rank_4": [166, 2505, 80, 40], 
	"pq_rank_5": [248, 2505, 80, 40], 
	"pq_reward_line": [294, 2547, 435, 18], 
	"pq_reward_word": [105, 2547, 87, 21], 
	"pq_score_3": [785, 2455, 43, 43], 
	"pq_score_4": [830, 2455, 40, 43], 
	"pq_score_5": [745, 2455, 38, 45], 
	"pq_score_6": [684, 2455, 59, 45], 
	"pq_score_7": [602, 2455, 80, 45], 
	"pq_score_l_3": [631, 2240, 92, 91], 
	"pq_score_l_4": [725, 2240, 85, 91], 
	"pq_score_l_5": [549, 2240, 80, 95], 
	"pq_score_l_6": [428, 2240, 119, 95], 
	"pq_score_l_7": [270, 2240, 156, 95], 
	"pq_tip": [432, 2027, 420, 164], 
	"pq_tip_helper": [2, 2364, 246, 89], 
	"pq_tip_vip": [2, 2240, 266, 122], 
	"pq_title": [721, 2364, 182, 53], 
	"pq_vip": [662, 2505, 79, 33], 
	"pq_w_damage": [743, 2505, 101, 24], 
	"pq_w_dead": [846, 2505, 101, 24], 
	"pq_w_exp": [194, 2547, 98, 19], 
	"pq_w_merit": [731, 2547, 64, 17], 
	"pq_w_time": [2, 2547, 101, 24], 
	"pq_win": [536, 2364, 117, 67], 
}

const SIZE = [1000, 600]

const BG = {"first": [0, 82], "second": [0, 102]}

const PAGE1 = {"cvsDamage": [309, 225, 215, 50], "cvsDead": [309, 283, 215, 50], "cvsPassTime": [309, 341, 215, 50], "imgDamage": [559, 224, 0, 0], "imgDead": [559, 285, 0, 0], "imgPassTime": [559, 344, 0, 0], "imgTotalScore": [745, 276, 0, 0], "title": [409, 0, 182, 53], "damage": [199, 228, 101, 24], "dead": [199, 286, 101, 24], "time": [199, 344, 101, 24], "glow": [637, 175]}

const PAGE2 = {"image8": [371, 86, 477, 421], "image4": [392, 166, 435, 18], "image3": [566, 156, 87, 21], "cvsItem": [389, 182, 440, 174], "image7": [402, 411, 98, 19], "frmExpPercent": [401.5, 430, 416, 30], "exp_title": [390, 107, 440, 48], "merit": [402, 464, 64, 17], "frmCharInfo": [175, 103, 180, 388], "imgWin": [441.5, 0, 117, 67], "imgLose": [441.5, 0, 117, 67], "btnBack": [336, 543, 156, 47], "btnBack_lose": [422, 543, 156, 47], "imgDouble": [806, 140, 64, 63], "imgVipExp": [804, 424, 79, 33], "frmResultTip": [400, 171, 420, 164]}

const TEXTS = {"lblExp": [711, 411, 100, 0, 16, "008dd2", 1, "r"], "lblMerit": [710, 463, 100, 0, 16, "008dd2", 1, "r"], "lblBack": [343, 553, 142, 0, 14, "ffffff", 1, "c"], "lblBack_lose": [429, 553, 142, 0, 14, "ffffff", 1, "c"], "lblWave": [746, 353, 0, 0, 18, "ffe868", 1, "c"]}

const CARD = {"imgChar": [43, -15, 0, 0], "imgGold": [41, 312, 0, 0], "imgTankAvatar": [-25, 50, 0, 0], "frmCurrentLevel": [3, 2, 80, 40], "image9": [7, 279, 168, 25], "image10": [7, 307, 168, 25], "image11": [7, 335, 168, 25], "image0": [7, 337, 168, 25], "imgRank": [58, 246, 80, 40], "hidden": ["frmStarBeHarm", "frmStarDie", "frmStarTime", "image11", "image2", "lblCoin"], "panel": [7, 279], "state": "mutiRankBanCoin"}

const CARD_TEXTS = {"lblExp": [68, 306, 100, 0, 16, "ffffff", 1, "r"], "lblCoin": [68, 334, 100, 0, 16, "ffffff", 1, "r"], "lblCharName": [-10, 224, 200, 0, 16, "ffffff", 1, "c"], "lblScore": [70, 276, 100, 0, 16, "ffffff", 1, "r"], "lblMerit": [68, 336, 100, 0, 16, "ffffff", 1, "r"]}

const TIP = {"panel": [0, 0], "vip": [77, 30, 266, 122], "helper": [87, 38, 246, 89]}

const NUM5 = {"cell": [30, 38], "step": 30, "scale": 0.8, "colon": 10, "colon_x": 60, "sec_x": [90, 120]}

const GLOW = {"count": 10, "step": 4, "period": 40, "fps": 24}

const ITEMS = [389, 182, 82, 82, 5, 2, 10]

const SCORE = [3, 7]
