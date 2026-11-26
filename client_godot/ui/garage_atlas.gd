extends RefCounted

const FILE: String = "res://assets/ui/hall/garage.png"

const R: Dictionary = {
	"garage_btn_buy": [228, 1047, 107, 38], 
	"garage_btn_convert": [337, 1047, 107, 38], 
	"garage_btn_convitem": [518, 937, 59, 59], 
	"garage_btn_halo": [454, 937, 62, 65], 
	"garage_btn_levelup": [848, 937, 133, 47], 
	"garage_btn_onbattle": [132, 1129, 64, 30], 
	"garage_btn_rank": [337, 1129, 56, 27], 
	"garage_btn_rent": [198, 1129, 67, 29], 
	"garage_btn_skin": [2, 1047, 122, 43], 
	"garage_cell_bg": [609, 618, 104, 117], 
	"garage_cell_off": [715, 618, 104, 117], 
	"garage_cell_orange": [268, 937, 91, 104], 
	"garage_cell_purple": [361, 937, 91, 104], 
	"garage_cell_sel": [821, 618, 104, 117], 
	"garage_f_all": [446, 1047, 72, 35], 
	"garage_f_all_on": [520, 1047, 72, 35], 
	"garage_f_dps": [594, 1047, 72, 35], 
	"garage_f_dps_on": [668, 1047, 72, 35], 
	"garage_f_rent": [372, 1092, 67, 35], 
	"garage_f_rent_on": [441, 1092, 67, 35], 
	"garage_f_support": [742, 1047, 72, 35], 
	"garage_f_support_on": [816, 1047, 72, 35], 
	"garage_f_tank": [890, 1047, 72, 35], 
	"garage_f_tank_on": [2, 1092, 72, 35], 
	"garage_frame": [2, 2, 1002, 614], 
	"garage_lv_0": [687, 1129, 44, 21], 
	"garage_lv_1": [90, 1163, 36, 21], 
	"garage_lv_10": [636, 1129, 49, 21], 
	"garage_lv_11": [560, 1129, 49, 22], 
	"garage_lv_2": [733, 1129, 42, 21], 
	"garage_lv_3": [777, 1129, 42, 21], 
	"garage_lv_4": [821, 1129, 42, 21], 
	"garage_lv_5": [865, 1129, 42, 21], 
	"garage_lv_6": [909, 1129, 42, 21], 
	"garage_lv_7": [953, 1129, 42, 21], 
	"garage_lv_8": [2, 1163, 42, 21], 
	"garage_lv_9": [46, 1163, 42, 21], 
	"garage_mark_free": [126, 1047, 49, 40], 
	"garage_mark_owned": [474, 1129, 41, 23], 
	"garage_mark_rare": [177, 1047, 49, 40], 
	"garage_mark_rent": [794, 937, 52, 49], 
	"garage_mark_unbuy": [517, 1129, 41, 23], 
	"garage_mark_vipfree": [639, 937, 49, 51], 
	"garage_onbattle": [70, 1129, 60, 32], 
	"garage_onbattle_lbl": [149, 1163, 46, 17], 
	"garage_pg": [422, 1129, 24, 25], 
	"garage_pg_next": [267, 1129, 33, 29], 
	"garage_pg_on": [448, 1129, 24, 25], 
	"garage_pg_prev": [302, 1129, 33, 29], 
	"garage_qa": [510, 1092, 66, 32], 
	"garage_qa_on": [578, 1092, 66, 32], 
	"garage_qs": [646, 1092, 66, 32], 
	"garage_qs_on": [714, 1092, 66, 32], 
	"garage_qss": [782, 1092, 66, 32], 
	"garage_qss_on": [850, 1092, 66, 32], 
	"garage_qsss": [918, 1092, 66, 32], 
	"garage_qsss_on": [2, 1129, 66, 32], 
	"garage_skill_ring": [579, 937, 58, 57], 
	"garage_skin_orange": [2, 937, 131, 108], 
	"garage_skin_purple": [135, 937, 131, 108], 
	"garage_star": [611, 1129, 23, 22], 
	"garage_star_bg": [395, 1129, 25, 25], 
	"garage_type_energy": [690, 937, 50, 50], 
	"garage_type_phys": [742, 937, 50, 50], 
	"garage_up_tip": [128, 1163, 19, 19], 
	"garage_w_attr": [76, 1092, 72, 35], 
	"garage_w_attr_on": [150, 1092, 72, 35], 
	"garage_w_sum": [224, 1092, 72, 35], 
	"garage_w_sum_on": [298, 1092, 72, 35], 
	"garage_wiz_attr": [514, 618, 93, 210], 
	"garage_wiz_bg": [2, 618, 286, 317], 
	"garage_wiz_sum": [290, 618, 222, 284], 
}

const FRAME = [1000, 600]

const PANELS = {"garage_frame": [1, -18], "garage_wiz_bg": [0, 31], "garage_wiz_sum": [31, 45], "garage_wiz_attr": [25, 45]}

const NODES = {"btnClose": [971, 4, 24, 24], "lblTankName": [372, 58, 234, 0], "btnAll": [18, 42, 72, 35], "btnAttack": [88, 42, 72, 35], "btnPanzer": [158, 42, 72, 35], "btnAssist": [228, 42, 72, 35], "btnCanRent": [298, 42, 67, 35], "imgOnBattle": [32, 77, 60, 32], "viewAvatar": [400, 153, 200, 200], "imgTankType": [375, 98, 50, 50], "imgTankLevel": [465, 34, 50, 21], "skillGift": [415, 409, 50, 50], "skillNormal": [474, 410, 50, 50], "skillEx": [534, 410, 50, 50], "btnRent": [613, 406, 67, 29], "btnLevelUp": [434, 529, 133, 47], "imgTankUpTip": [547, 530, 19, 19], "btnConvert": [377, 529, 107, 38], "btnBuy": [517, 529, 107, 38], "btnOnBattle": [467, 371.5, 64, 30], "lblOnBattle": [476, 378, 46, 17], "lblExistTime": [318, 365, 140, 44], "imgSkinFrame": [697, 427, 131, 108], "viewSkin": [712, 431, 200, 200], "btnTankSkin": [842, 501, 122, 43], "btnSkinQuaA": [836, 424, 66, 32], "btnSkinQuaS": [904, 424, 66, 32], "btnSkinQuaSS": [836, 462, 66, 32], "btnSkinQuaSSS": [904, 462, 66, 32], "lblSkinFrameTip": [706, 541, 270, 46], "btnConvertItem": [618, 240, 59, 59], "btnTankHalo": [618, 300, 62, 65], "lblAchievedLevel": [370, 510, 260, 0]}

const TEXTS = {"lblTankName": [372, 58, 234, 0, 16, "ffffff", 1, "c"], "lblExistTime": [318, 365, 140, 44, 12, "ff9d9d", 1, "c"], "lblSkinFrameTip": [706, 541, 270, 46, 14, "ffffff", 1, "l"], "lblAchievedLevel": [370, 510, 260, 0, 14, "ffffff", 1, "c"]}

const RINGS = [[411, 405], [471, 406], [530, 406]]

const CELLS = [[10, 76], [112, 76], [214, 76], [60, 166], [162, 166], [10, 256], [112, 256], [214, 256], [60, 346], [162, 346], [10, 436], [112, 436], [214, 436]]

const CELL = {"imgSkinFrame": [7, 6, 91, 104], "viewAvatar": [4, 5, 200, 200], "imgRent": [8, 1, 52, 49], "imgFreeMark": [7, 5, 49, 40], "imgVipFreeMark": [7, 2, 49, 51], "imgMarkUnbuy": [31, 86, 41, 23], "imgMarkAchieved": [31, 86, 41, 23], "imgRare": [7, 5, 49, 40], "bg": [52.0, 58.5, 0, 0]}

const CELL_LEVEL = [32, 87, 40, 24, 14, "fdf63a", 1, "c"]

const ON_BATTLE = [22, 1]

const PAGER = {"box": [70, 552, 196, 30], "prev": [70, 552, 33, 29], "next": [233, 552, 33, 29], "first": [104, 552], "step": 34, "back": [1, 1, 24, 25], "num": [0, 4, 26, 20, 12, "ffffff", 1, "c"]}

const WIZ = [687, 45]

const WNODES = {"btnSum": [0, 0, 72, 35], "btnAttr": [71, 0, 72, 35], "imgBg0": [116, 73, 25, 25], "imgStar0": [117, 75, 23, 22], "imgBg1": [144, 73, 25, 25], "imgStar1": [145, 75, 23, 22], "imgBg2": [172, 73, 25, 25], "imgStar2": [173, 75, 23, 22], "btnMilitaryRank": [223, 314, 56, 27]}

const WTEXT = {"lblTankDec": [116, 45, 160, 24, 16, "b1e4f9", 1, "l"], "lblTitle": [23, 274, 160, 0, 16, "0b333c", 1, "l"], "lblSkinAttr": [23, 295, 200, 0, 14, "0b333c", 1, "l"], "lblMilitaryRankAttr": [23, 316, 200, 0, 14, "0b333c", 1, "l"], "lblHp": [141, 44, 0, 0, 16, "ffffff", 1, "l"], "lblAtk": [141, 70, 0, 0, 16, "ffffff", 1, "l"], "lblCentesis": [141, 96, 0, 0, 16, "ffffff", 1, "l"], "lblPhysicDF": [141, 122, 0, 0, 16, "ffffff", 1, "l"], "lblEneryDF": [141, 150, 0, 0, 16, "ffffff", 1, "l"], "lblSpeed": [141, 180, 0, 0, 16, "ffffff", 1, "l"], "lblFireRate": [141, 208, 0, 0, 16, "ffffff", 1, "l"], "lblFireRange": [141, 236, 0, 0, 16, "ffffff", 1, "l"]}

const RADAR = {"c": [144, 234], "r": 74, "color": "00ff00"}
