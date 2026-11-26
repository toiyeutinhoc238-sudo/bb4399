extends RefCounted

const FILE: String = "res://assets/ui/hall/eventsv.png"

const R: Dictionary = {
	"ew_bar": [2, 1348, 316, 20], 
	"ew_buy": [212, 1314, 89, 30], 
	"ew_buy_bg": [200, 1272, 100, 38], 
	"ew_c0": [303, 1314, 78, 27], 
	"ew_c19": [644, 1348, 55, 17], 
	"ew_c21": [449, 1348, 116, 19], 
	"ew_c22": [475, 1314, 384, 23], 
	"ew_finish": [383, 1314, 44, 27], 
	"ew_head": [787, 621, 60, 60], 
	"ew_lock": [687, 621, 77, 73], 
	"ew_more": [402, 1272, 75, 36], 
	"ew_priv": [302, 1272, 98, 37], 
	"ew_sb_bk": [665, 621, 20, 100], 
	"ew_sb_down": [602, 1348, 19, 19], 
	"ew_sb_thumb": [766, 621, 19, 64], 
	"ew_sb_up": [623, 1348, 19, 19], 
	"ew_sub": [710, 1229, 196, 40], 
	"ew_sub_on": [2, 1272, 196, 40], 
	"ew_tc": [2, 2, 859, 617], 
	"ew_tc_get": [479, 1272, 100, 33], 
	"ew_tc_go": [849, 621, 112, 45], 
	"ew_tc_got": [581, 1272, 100, 33], 
	"ew_tc_head": [567, 1348, 33, 19], 
	"ew_tobe": [861, 1314, 122, 22], 
	"ew_underway": [429, 1314, 44, 27], 
	"ew_vip": [2, 621, 661, 606], 
	"ew_vip1": [963, 621, 57, 41], 
	"ew_vip10": [2, 1229, 57, 41], 
	"ew_vip11": [61, 1229, 57, 41], 
	"ew_vip2": [120, 1229, 57, 41], 
	"ew_vip3": [179, 1229, 57, 41], 
	"ew_vip4": [238, 1229, 57, 41], 
	"ew_vip5": [297, 1229, 57, 41], 
	"ew_vip6": [356, 1229, 57, 41], 
	"ew_vip7": [415, 1229, 57, 41], 
	"ew_vip8": [474, 1229, 57, 41], 
	"ew_vip9": [533, 1229, 57, 41], 
	"ew_vipadd": [320, 1348, 127, 20], 
	"ew_vipdef": [683, 1272, 40, 32], 
	"ew_vipn1": [592, 1229, 57, 41], 
	"ew_vipn3": [651, 1229, 57, 41], 
	"ew_vips1": [725, 1272, 40, 32], 
	"ew_vips10": [767, 1272, 40, 32], 
	"ew_vips11": [809, 1272, 40, 32], 
	"ew_vips12": [851, 1272, 40, 32], 
	"ew_vips2": [893, 1272, 40, 32], 
	"ew_vips3": [935, 1272, 40, 32], 
	"ew_vips4": [977, 1272, 40, 32], 
	"ew_vips5": [2, 1314, 40, 32], 
	"ew_vips6": [44, 1314, 40, 32], 
	"ew_vips7": [86, 1314, 40, 32], 
	"ew_vips8": [128, 1314, 40, 32], 
	"ew_vips9": [170, 1314, 40, 32], 
}

const PANELS = {"tc": [19, 11], "vip": [19, 2]}

const TC = {"btnClose": [842, 33, 24, 24], "vBoxReward": [340, 309, 470, 291], "btnGetReward": [594, 570, 100, 33], "btnGoCharge": [588, 562, 112, 45], "btnGeted": [594, 570, 100, 33], "txtDesz": [370, 337, 427, 0, 27, "0b333c", 1, "l"], "lblPoint": [768, 231, 70, 0, 16, "fede04", 1, "l"], "head": [350, 384], "tiles": [346, 406], "list": [72, 305, 200, 295, 40]}

const SUB = {"lblIndex": [7, 8, 0, 0, 14, "ffffff", 1, "c"], "lblDesz": [33, 20, 136, 0, 12, "ffffff", 1, "l"], "icon": [146, 0]}

const VIP = {"btnClose": [644, 33, 24, 24], "imgHead": [46, 86, 60, 60], "imgVipLevel": [117, 95, 57, 41], "cimagechecklocal19": [117, 141, 55, 17], "cimagechecklocal0": [177, 136.95, 78, 27], "btnVipPrivilege": [520, 61, 98, 37], "btnMoreVip": [264, 107, 75, 36], "imgCurVip": [72, 186, 40, 32], "imgNextVip": [444, 186, 40, 32], "imgVipProcess": [120, 196, 316, 20], "cimagechecklocal21": [53, 273, 116, 19], "imgVipNextLevel": [470, 264, 40, 32], "lblCharName": [113, 68, 0, 0, 14, "004b9e", 1, "l"], "lblLeftVipDay": [180, 141, 95, 0, 12, "ffffff", 1, "l"], "lblVipTodayPoint": [173, 271, 99, 0, 14, "ffffff", 1, "l"], "lblVipPoint": [358, 272.05, 75, 22.92, 14, "ffed58", 1, "c"], "vipProcessLbl": [427, 271, 39, 22.92, 14, "ffffff", 1, "c"], "lblNextViplvNeed": [516, 271, 157.35, 22, 14, "ffffff", 1, "l"], "lblVipProcessInfo": [117, 194, 321, 22, 15, "ffffff", 1, "c"], "lblGetAwardDesc": [90, 234, 377, 38, 16, "ffffff", 1, "c"], "vipadd": [238, 273], "frame_head": [43, 83]}

const FIRST = {"img_buyVip_bg": [363, 98, 100, 38], "imgTobeVipTip": [240, 106.25, 122, 22], "btnBuyVip": [369, 99, 89, 30], "c22": [59, 280]}

const PRIV = [[50, 341, "lblRelive", ""], [160, 341, "lblLifeAdd", ""], [270, 341, "lblGolden", ""], [380, 341, "lblPveDrop", ""], [490, 341, "lblExtraThew", ""], [50, 435, "", "imgLockChallenge"], [160, 435, "", "imgLockSweep"], [270, 435, "lblFreeRent", "imgLockFreeRent"], [380, 435, "", "imgLockGambling"]]
