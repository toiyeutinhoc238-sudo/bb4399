extends RefCounted

const FILE: String = "res://assets/ui/hall/bag.png"

const R: Dictionary = {
	"bag_ach": [286, 1246, 485, 59], 
	"bag_ach_sel": [2, 1348, 485, 59], 
	"bag_ask": [350, 968, 369, 199], 
	"bag_ask_guy": [694, 566, 180, 292], 
	"bag_ask_no": [124, 1409, 100, 33], 
	"bag_ask_ok": [226, 1409, 100, 33], 
	"bag_btn_buyspray": [2, 1246, 100, 100], 
	"bag_btn_choose": [880, 1409, 96, 28], 
	"bag_btn_gift": [2, 1446, 96, 28], 
	"bag_btn_pay": [394, 1446, 81, 28], 
	"bag_btn_sell": [100, 1446, 96, 28], 
	"bag_btn_shop": [198, 1446, 96, 28], 
	"bag_btn_strip": [328, 1409, 100, 33], 
	"bag_btn_tidy": [296, 1446, 96, 28], 
	"bag_card": [526, 566, 166, 326], 
	"bag_cell_bg": [547, 1348, 55, 55], 
	"bag_check": [868, 1348, 41, 40], 
	"bag_clock": [848, 1446, 22, 22], 
	"bag_coin_0": [654, 1446, 26, 26], 
	"bag_coin_1": [682, 1446, 26, 26], 
	"bag_coin_2": [710, 1446, 26, 26], 
	"bag_exp_bar": [579, 1476, 162, 14], 
	"bag_exp_track": [441, 1476, 136, 16], 
	"bag_frame": [2, 2, 866, 562], 
	"bag_honor_cell": [816, 1348, 50, 50], 
	"bag_honor_on": [911, 1348, 41, 40], 
	"bag_input": [872, 1446, 138, 21], 
	"bag_lock": [477, 1446, 28, 28], 
	"bag_menu_btn": [605, 1409, 60, 32], 
	"bag_navw_0": [2, 1476, 37, 21], 
	"bag_navw_1": [41, 1476, 37, 21], 
	"bag_navw_2": [80, 1476, 37, 21], 
	"bag_navw_3": [239, 1476, 35, 19], 
	"bag_navw_4": [119, 1476, 37, 21], 
	"bag_navw_5": [158, 1476, 37, 21], 
	"bag_opt_on": [507, 1446, 85, 26], 
	"bag_optw_all": [197, 1476, 40, 19], 
	"bag_optw_done": [387, 1476, 52, 17], 
	"bag_optw_todo": [318, 1476, 67, 17], 
	"bag_overdue": [667, 1409, 45, 32], 
	"bag_p_acem": [2, 566, 522, 400], 
	"bag_p_spray": [721, 968, 287, 110], 
	"bag_pager_bg": [430, 1409, 86, 33], 
	"bag_pay_bg": [518, 1409, 85, 32], 
	"bag_pg_first": [714, 1409, 46, 29], 
	"bag_pg_last": [762, 1409, 46, 29], 
	"bag_pg_next": [810, 1409, 33, 29], 
	"bag_pg_prev": [845, 1409, 33, 29], 
	"bag_q2": [604, 1348, 51, 51], 
	"bag_q3": [657, 1348, 51, 51], 
	"bag_q4": [710, 1348, 51, 51], 
	"bag_q5": [763, 1348, 51, 51], 
	"bag_sb_bk": [104, 1246, 20, 100], 
	"bag_sb_block": [870, 2, 19, 505], 
	"bag_sb_down": [276, 1476, 19, 19], 
	"bag_sb_up": [297, 1476, 19, 19], 
	"bag_select": [489, 1348, 56, 56], 
	"bag_spray_cell": [126, 1246, 78, 78], 
	"bag_spray_sel": [206, 1246, 78, 78], 
	"bag_use": [2, 968, 346, 276], 
	"bag_use_max": [594, 1446, 58, 26], 
	"bag_use_minus": [794, 1446, 25, 25], 
	"bag_use_ok": [2, 1409, 120, 35], 
	"bag_use_plus": [821, 1446, 25, 25], 
	"bag_x2_mat": [738, 1446, 26, 26], 
	"bag_x2_tok": [766, 1446, 26, 26], 
}

const FRAME = [870, 566]

const PANELS = {"bag_frame": [2, 2], "bag_card": [279, 111], "bag_p_acem": [270, 100], "bag_p_spray": [323, 130], "bag_ask": [46, 1]}

const TABS = [[244, 54, 101, 33], [342, 54, 101, 33], [440, 54, 101, 33], [538, 54, 101, 33], [636, 54, 101, 33], [734, 54, 101, 33]]
const CLOSE = [831, 15, 24, 24]

const LEFT = {"pgsExp": [82, 358, 136, 16], "lblClanName": [82, 382, 138, 21], "lblWinRate": [82, 411, 138, 21], "lblEscapeRate": [82, 440, 138, 21], "txtTeamRank": [82, 469, 138, 21], "imgRank": [17, 60, 80, 40], "imgCharAvatar": [34, 94, 180, 240], "imgVip": [160, 95, 57, 41], "lblPlayerName": [67, 63, 152, 24, 12, "ffffff", 1, "c"], "lblAvatarDesc": [27.5, 323, 193, 0, 13, "ffaea3", 1, "c"], "lblIndidualDesc": [27.5, 305, 193, 0, 13, "ffaea3", 1, "c"]}

const VP = {"item0": [285, 113, 55, 55], "btnSell": [700, 445, 96, 28], "btnGoShop": [700, 475, 96, 28], "btnTidy": [700, 413, 96, 28], "btnQuickGift": [596, 475, 96, 28], "image5": [497, 411.5, 86, 33], "btnLastPage": [463.5, 413.5, 33, 29], "btnNextPage": [583.5, 413.5, 33, 29], "image6": [284, 401, 26, 26], "image7": [284, 426, 26, 26], "image0": [284, 451, 26, 26], "lblPage": [511.5, 428, 57, 0, 15, "ffffff", 1, "c"], "lblExtend": [540, 428, 0, 0, 16, "42ff5d", 1, "c"], "label2": [314, 429, 0, 0, 16, "ffffff", 1, "l"], "lblGold": [314, 454, 0, 0, 16, "ffffff", 1, "l"], "lblCash": [314, 404, 0, 0, 16, "ffffff", 1, "l"]}

const MAT = {"item0": [285, 113, 55, 55], "btnSell": [700, 445, 96, 28], "btnTidy": [700, 413, 96, 28], "image5": [497, 411.5, 86, 33], "btnFirstPage": [417, 413.5, 46, 29], "btnLastPage": [463.5, 413.5, 33, 29], "btnNextPage": [583.5, 413.5, 33, 29], "btnLastestPage": [617, 413.5, 46, 29], "lblPage": [511.5, 428, 57, 0, 15, "ffffff", 1, "c"]}

const CELL = {"imgQuality": [2, 2, 51, 51], "imgIcon": [3, 3, 50, 50], "imgOverTime": [5.0, 11.5, 45, 32], "imgSelectItemBg": [-1, -1, 56, 56], "lblNum": [55, 37, 0, 18], "pitch": 57, "cols": 9, "rows": 5}

const CARDS = {"x": [279, 457, 635], "imgAvatar0": [293, 156, 180, 240], "imgAvatarSelect0": [401, 117, 41, 40], "btnPayBackground0": [317, 396, 85, 32], "btnPayAvater0": [319, 398, 81, 28], "lblAvatarTime0": [289, 376, 146, 0, 12, "ffffff", 1, "c"], "lblAvatar1": [306, 122, 113, 0, 14, "ffffff", 1, "c"], "lblEffect0": [362, 348, 0, 0, 13, "ffaea3", 1, "c"]}
const PAGER_INFO = {"btnFirstPage1": [417, 454, 46, 29], "btnLastPage3": [463.5, 454, 33, 29], "btnNextPage5": [583.5, 454, 33, 29], "btnLastPage4": [617, 454, 46, 29], "lblPage4": [511.5, 468.5, 57, 0, 15, "ffffff", 1, "c"]}
const PAGER_DECOR = {"btnFirstPage1": [417, 442, 46, 29], "btnLastPage3": [463.5, 442, 33, 29], "btnNextPage5": [583.5, 442, 33, 29], "btnLastPage4": [617, 442, 46, 29], "btnCancleIndividual": [490, 476, 100, 33], "lblPage4": [511.5, 456.5, 57, 0, 15, "ffffff", 1, "c"]}

const ACEM = {"btnAll": [507, 138, 85, 26], "btnComplete": [594, 138, 85, 26], "btnUnreach": [681, 138, 85, 26], "lstSkillSelect": [312, 430, 470, 70], "lblAcemNum": [364, 145, 80, 0, 12, "ffffff", 1, "c"], "lblTips": [306, 465, 480, 0, 14, "ffffff", 1, "c"], "lblAcemPoint": [373, 104, 60, 0, 12, "ffffff", 1, "c"], "list": [301, 172, 487, 244], "row": 62}
const ACH_ROW = {"lblName": [61, 7, 266, 0, 16, "f16422", 1, "l"], "lblProgress": [477, 31, 0, 0, 13, "f16422", 1, "r"], "lblDesc": [61, 31, 266, 0, 13, "f16422", 1, "l"], "lblAchievementScore": [477, 7, 0, 0, 13, "f16422", 1, "r"]}

const SPRAY = {"tileSpray": [276, 247, 526, 173], "btnBuySpray": [670, 133, 100, 100], "btnFirstPage2": [417, 429, 46, 29], "btnLastPage5": [463.5, 429, 33, 29], "btnNextPage2": [583.5, 429, 33, 29], "btnLastPage6": [617, 428, 46, 29], "btnChooseSpray": [492, 462, 96, 28], "imgSpray": [425, 150, 80, 80], "lblSprayItemNum": [677, 107, 88, 0, 14, "ffffff", 1, "c"], "lblPage2": [505.5, 443.5, 63, 0, 15, "ffffff", 1, "c"], "_CharFrame_Text1": [322.5, 95, 287, 0, 12, "ffffff", 1, "l"], "_CharFrame_Label3": [486, 467, 0, 0, 13, "ffffff", 1, "r"], "wordSpray": [323, 147, 0, 0, 16, "ffffff", 1, "r"], "pager_bg": [497, 425]}

const ASK = {"btnCancel": [240, 133, 100, 33], "btnConfirm": [120, 133, 100, 33], "txtContent": [102, 38, 270, 90, 14, "ffffff", 1, "l"]}
const MENU = {"btnUse": [3, 1, 60, 32], "btnSell": [3, 33, 60, 32]}

const COINS = [[284, 401], [284, 426], [284, 451]]
const X2 = {"imgMeterialPlus": [34, 100, 26, 26], "imgTokenPlus": [64, 100, 26, 26]}

const USE = {"panel": [2, 2], "close": [311, 15, 24, 24], "imgQuality": [66, 81, 46, 46], "imgItem": [64, 79, 52, 49], "txtUseNum": [145, 155, 60, 30], "btnAddNum": [232.5, 157.5, 25, 25], "btnReduceNum": [92.5, 157.5, 25, 25], "btnMax": [261, 157, 58, 26], "btnConfirm": [115, 228, 120, 35], "lblNum": [30, 112, 85, 0, 11, "ffffff", 1, "r"], "_ItemUseAskFrame_Label1": [120, 73, 200, 0, 16, "ffffff", 1, "l"], "lblItemNum": [120, 105, 200, 0, 16, "ffffff", 1, "l"]}
