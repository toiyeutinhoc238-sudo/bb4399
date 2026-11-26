extends RefCounted

const FILE: String = "res://assets/ui/hall/crystal.png"

const R: Dictionary = {
	"crystal_buy": [812, 1886, 40, 28], 
	"crystal_cash": [454, 1917, 26, 26], 
	"crystal_cb": [793, 1674, 34, 33], 
	"crystal_cb_on": [829, 1674, 34, 33], 
	"crystal_cl0": [854, 1886, 24, 28], 
	"crystal_cl0_on": [382, 1852, 30, 32], 
	"crystal_cl1": [880, 1886, 24, 28], 
	"crystal_cl1_on": [414, 1852, 30, 32], 
	"crystal_cl2": [906, 1886, 24, 28], 
	"crystal_cl2_on": [446, 1852, 30, 32], 
	"crystal_cl3": [932, 1886, 24, 28], 
	"crystal_cl3_on": [478, 1852, 30, 32], 
	"crystal_cl4": [958, 1886, 24, 28], 
	"crystal_cl4_on": [510, 1852, 30, 32], 
	"crystal_clock": [465, 1972, 18, 18], 
	"crystal_close": [380, 1946, 24, 24], 
	"crystal_conv_btn": [860, 1852, 71, 29], 
	"crystal_conv_frame": [2, 580, 896, 576], 
	"crystal_conv_tile": [706, 1158, 204, 224], 
	"crystal_convert": [566, 1886, 80, 28], 
	"crystal_dot": [444, 1972, 19, 19], 
	"crystal_frame": [2, 2, 972, 576], 
	"crystal_gift": [482, 1917, 26, 26], 
	"crystal_gray": [125, 1674, 52, 60], 
	"crystal_info": [510, 1917, 26, 26], 
	"crystal_input": [618, 1852, 240, 30], 
	"crystal_left": [933, 1852, 33, 29], 
	"crystal_left_off": [968, 1852, 33, 29], 
	"crystal_lock": [759, 1674, 32, 40], 
	"crystal_lv0": [620, 1917, 40, 24], 
	"crystal_lv0_on": [662, 1917, 40, 24], 
	"crystal_lv1": [704, 1917, 40, 24], 
	"crystal_lv1_on": [746, 1917, 40, 24], 
	"crystal_lv2": [788, 1917, 40, 24], 
	"crystal_lv2_on": [830, 1917, 40, 24], 
	"crystal_lv3": [872, 1917, 40, 24], 
	"crystal_lv3_on": [914, 1917, 40, 24], 
	"crystal_lv4": [956, 1917, 40, 24], 
	"crystal_lv4_on": [2, 1946, 40, 24], 
	"crystal_make": [648, 1886, 80, 28], 
	"crystal_mk_five": [2, 1917, 73, 27], 
	"crystal_mk_free": [77, 1917, 73, 27], 
	"crystal_mk_one": [152, 1917, 73, 27], 
	"crystal_name": [865, 1674, 74, 32], 
	"crystal_name_add": [941, 1674, 74, 32], 
	"crystal_name_on": [2, 1852, 74, 32], 
	"crystal_ok": [227, 1917, 73, 27], 
	"crystal_pg1": [406, 1946, 24, 22], 
	"crystal_pg10": [432, 1946, 24, 22], 
	"crystal_pg10_on": [458, 1946, 24, 22], 
	"crystal_pg11": [484, 1946, 24, 22], 
	"crystal_pg11_on": [510, 1946, 24, 22], 
	"crystal_pg12": [536, 1946, 24, 22], 
	"crystal_pg12_on": [562, 1946, 24, 22], 
	"crystal_pg13": [588, 1946, 24, 22], 
	"crystal_pg13_on": [614, 1946, 24, 22], 
	"crystal_pg14": [640, 1946, 24, 22], 
	"crystal_pg14_on": [666, 1946, 24, 22], 
	"crystal_pg15": [692, 1946, 24, 22], 
	"crystal_pg15_on": [718, 1946, 24, 22], 
	"crystal_pg16": [744, 1946, 24, 22], 
	"crystal_pg16_on": [770, 1946, 24, 22], 
	"crystal_pg17": [796, 1946, 24, 22], 
	"crystal_pg17_on": [822, 1946, 24, 22], 
	"crystal_pg18": [848, 1946, 24, 22], 
	"crystal_pg18_on": [874, 1946, 24, 22], 
	"crystal_pg19": [900, 1946, 24, 22], 
	"crystal_pg19_on": [926, 1946, 24, 22], 
	"crystal_pg1_on": [952, 1946, 24, 22], 
	"crystal_pg2": [978, 1946, 24, 22], 
	"crystal_pg20": [2, 1972, 24, 22], 
	"crystal_pg20_on": [28, 1972, 24, 22], 
	"crystal_pg2_on": [54, 1972, 24, 22], 
	"crystal_pg3": [80, 1972, 24, 22], 
	"crystal_pg3_on": [106, 1972, 24, 22], 
	"crystal_pg4": [132, 1972, 24, 22], 
	"crystal_pg4_on": [158, 1972, 24, 22], 
	"crystal_pg5": [184, 1972, 24, 22], 
	"crystal_pg5_on": [210, 1972, 24, 22], 
	"crystal_pg6": [236, 1972, 24, 22], 
	"crystal_pg6_on": [262, 1972, 24, 22], 
	"crystal_pg7": [288, 1972, 24, 22], 
	"crystal_pg7_on": [314, 1972, 24, 22], 
	"crystal_pg8": [340, 1972, 24, 22], 
	"crystal_pg8_on": [366, 1972, 24, 22], 
	"crystal_pg9": [392, 1972, 24, 22], 
	"crystal_pg9_on": [418, 1972, 24, 22], 
	"crystal_pg_next": [566, 1917, 25, 26], 
	"crystal_pg_prev": [593, 1917, 25, 26], 
	"crystal_piece": [538, 1917, 26, 26], 
	"crystal_red": [485, 1972, 15, 15], 
	"crystal_rename": [382, 1917, 34, 26], 
	"crystal_rename_off": [418, 1917, 34, 26], 
	"crystal_reset": [260, 1886, 100, 28], 
	"crystal_right": [2, 1886, 33, 29], 
	"crystal_right_off": [37, 1886, 33, 29], 
	"crystal_rmd": [78, 1852, 74, 32], 
	"crystal_rmd_on": [154, 1852, 74, 32], 
	"crystal_row": [555, 1674, 202, 46], 
	"crystal_row_on": [341, 1674, 212, 54], 
	"crystal_save": [362, 1886, 100, 28], 
	"crystal_save_off": [464, 1886, 100, 28], 
	"crystal_sell": [730, 1886, 80, 28], 
	"crystal_sell_frame": [2, 1158, 702, 514], 
	"crystal_sell_ok": [302, 1917, 78, 26], 
	"crystal_set": [230, 1852, 74, 32], 
	"crystal_set_on": [306, 1852, 74, 32], 
	"crystal_sock_2": [179, 1674, 52, 60], 
	"crystal_sock_3": [233, 1674, 52, 60], 
	"crystal_sock_4": [287, 1674, 52, 60], 
	"crystal_tank": [542, 1852, 74, 31], 
	"crystal_tank_bk": [72, 1886, 186, 28], 
	"crystal_tile": [2, 1674, 121, 176], 
	"crystal_type0": [44, 1946, 40, 24], 
	"crystal_type0_on": [86, 1946, 40, 24], 
	"crystal_type1": [128, 1946, 40, 24], 
	"crystal_type1_on": [170, 1946, 40, 24], 
	"crystal_type2": [212, 1946, 40, 24], 
	"crystal_type2_on": [254, 1946, 40, 24], 
	"crystal_type3": [296, 1946, 40, 24], 
	"crystal_type3_on": [338, 1946, 40, 24], 
}

const FRAME = [954, 550]

const PANELS = {"crystal_frame": [-8, -18], "crystal_sell_frame": [-13, -18], "crystal_conv_frame": [2, -18]}

const SOCKETS = [[397, 130, 52, 60], [454, 231, 52, 60], [566, 130, 52, 60], [340, 130, 52, 60], [511, 231, 52, 60], [622, 130, 52, 60], [370, 182, 52, 60], [427, 280, 52, 60], [593, 182, 52, 60], [314, 182, 52, 60], [482, 280, 52, 60], [650, 182, 52, 60], [286, 231, 52, 60], [538, 280, 52, 60], [677, 231, 52, 60], [314, 280, 52, 60], [398, 329, 52, 60], [650, 280, 52, 60], [286, 329, 52, 60], [454, 329, 52, 60], [677, 329, 52, 60], [314, 380, 52, 60], [511, 329, 52, 60], [650, 380, 52, 60], [286, 430, 52, 60], [565, 329, 52, 60], [677, 430, 52, 60], [340, 430, 52, 60], [482, 380, 52, 60], [622, 430, 52, 60]]

const SOCKET = {"iconLock": [10, 10, 32, 40], "lv": [26, 21, 16, "ff9c00", 0], "open": [26, 37, 14, "ff9c00", 1]}
const CLOSE = [925, -5, 24, 24]

const MAIN = {"btnSet": [10, 37, 74, 32], "btnRecommend": [88, 37, 74, 32], "iptSchemeName": [10, 78, 240, 30], "btnCgName": [217, 78, 34, 26], "btnConvert": [16, 502, 80, 28], "btnSell": [98, 502, 80, 28], "btnMake": [180, 502, 80, 28], "btnLeft": [371, 77, 33, 29], "btnRight": [740, 77, 33, 29], "btnSave": [817, 78, 100, 28], "btnReset": [817, 122, 100, 28], "txtAttr": [792, 276, 150, 250], "crystalToken": [270, 501, 133, 30], "_NewCrystalFrame_Label1": [258, 91.5, 114, 0, 16, "bdcde6", 1, "r"], "_NewCrystalFrame_Label2": [867, 206, 0, 0, 16, "bdcde6", 1, "c"], "lblTotalLv": [867, 170.5, 0, 0, 18, "9aceff", 1, "c"], "_NewCrystalFrame_Label4": [867, 238, 0, 0, 18, "bdcde6", 1, "c"], "_NewCrystalFrame_Label5": [522, 504, 0, 0, 16, "52ccff", 1, "c"], "names": [402, 74, 334, 35], "name_pitch": 70, "token_icon": [274, 516], "token_text": [300, 507, 64, 20], "token_plus": [366, 516]}

const LIST = {"at": [10, 110], "radios": [[0, 3], [46, 3], [92, 3], [138, 3]], "radio": [40, 24], "list": [0, 37, 250, 350], "row": 50}

const ITEM = {"bg": [0, 2, 202, 46], "bgSelect": [0, -2, 212, 54], "iconCrystal": [3, 3, 44, 44], "txtDesc": [48, 25, 107, 0, 12, "fefdfb", 1, "l"], "lblCnt": [197, 25, 0, 0, 12, "fefdfb", 1, "r"]}

const RMD = {"at": [10, 114], "avTank": [5, 5, 200, 200], "btnChangeTank": [141, 67, 74, 31], "lblTankName": [178, 31.5, 0, 0, 16, "ffffff", 1, "c"], "lblTankPos": [0, 110, 0, 0, 14, "5d8dba", 1, "l"], "_NewCrystalRmdLstFrame_Label3": [0, 132, 0, 0, 14, "5d8dba", 1, "l"], "name_bk": [85, 30, 186, 28], "levels": [[0, 163], [46, 163], [92, 163], [138, 163], [184, 163]], "list": [0, 197, 250, 190]}

const RMD_ITEM = {"btnBuy": [207, 11, 40, 28], "txtDesc": [48, 25, 113, 0, 12, "bdcde6", 1, "l"], "lblCnt": [197, 25, 0, 0, 12, "bdcde6", 1, "r"]}

const NAME = {"btnSelect": [-3, 1.5, 74, 32], "imgTip": [49, 0, 19, 19], "lblName": [34, 17.5, 0, 0, 12, "fdfdfd", 1, "c"]}

const SELL = {"size": [676, 488], "btnClose": [652, -5, 24, 24], "btnSell": [533, 445, 78, 26], "_NewCrystalSellFrame_Text1": [528, 415, 0, 0, 16, "fefdfb", 1, "r"], "txtSellTotal": [568, 415, 0, 0, 16, "fefdfb", 1, "r"], "_NewCrystalSellFrame_Text3": [46, 422, 0, 0, 16, "fefdfb", 1, "r"], "_NewCrystalSellFrame_Text4": [125, 422, 0, 0, 16, "fefdfb", 1, "r"], "_NewCrystalSellFrame_Text5": [196, 422, 0, 0, 16, "fefdfb", 1, "r"], "_NewCrystalSellFrame_Text6": [46, 458, 0, 0, 16, "fefdfb", 1, "r"], "_NewCrystalSellFrame_Text7": [121, 458, 0, 0, 16, "fefdfb", 1, "r"], "_NewCrystalSellFrame_Label1": [338, 445, 0, 0, 16, "52ccff", 1, "c"], "checks": [[79, 409], [154, 409], [229, 409], [79, 445], [154, 445]], "list": [23, 40, 650, 370], "cell": [125, 185], "cols": 5, "coin": [533, 412]}

const SELL_ITEM = {"txtDesc": [5.5, 110, 110, 0, 12, "fefdfb", 1, "c"], "icon": [60.5, 4], "check": [43.5, 138]}

const CONVERT = {"size": [900, 560], "btnClose": [861, -5, 24, 24], "items": [[30, 38], [240, 38], [450, 38], [660, 38], [30, 270], [240, 270], [450, 270], [660, 270]], "levels": [[101, 505], [134, 505], [167, 505], [200, 505], [233, 505]], "pager": [450, 509, 30, 26], "token": [731, 505], "token_icon": [735, 520], "token_text": [761, 511, 64, 20]}

const CONVERT_ITEM = {"lblName": [102, 3, 0, 0, 14, "ffffff", 1, "c"], "material": [57, 148], "count": [83, 153], "button": [102, 185], "icon": [52, 42, 100, 100]}

const MAKE = {"size": [1200, 800], "bg": [-15, -50, 1230, 870], "btnClose": [1176, -35, 24, 24], "imgTime": [650, 613, 18, 18], "lblFreeTime": [671, 610, 125, 0, 14, "ffff00", 1, "l"], "coin_one": [328, 634], "coin_five": [439, 634], "cash_one": [673, 634], "cash_five": [784, 634], "free": [673, 634], "price": {"coin_one": [319, 659], "coin_five": [430, 659], "cash_one": [665, 659], "cash_five": [776, 659]}, "info": [744, 28]}

const REWARD = {"size": [1440, 900], "ok": [683.5, 478]}
