extends RefCounted

const FILE: String = "res://assets/ui/hall/tank_rent.png"

const R: Dictionary = {
	"trent_add": [2, 804, 83, 29], 
	"trent_bar": [2, 865, 138, 17], 
	"trent_bar_bg": [142, 865, 138, 17], 
	"trent_buy": [87, 804, 83, 29], 
	"trent_cbox_off": [718, 835, 25, 25], 
	"trent_cbox_on": [745, 835, 25, 25], 
	"trent_cbox_s_off": [798, 835, 22, 24], 
	"trent_cbox_s_on": [822, 835, 22, 24], 
	"trent_cell_high": [613, 2, 120, 120], 
	"trent_cell_high_sel": [735, 2, 120, 120], 
	"trent_cell_mid": [857, 2, 120, 120], 
	"trent_cell_mid_sel": [2, 646, 120, 120], 
	"trent_charge": [752, 646, 62, 35], 
	"trent_chip": [604, 835, 28, 28], 
	"trent_chk_off": [846, 835, 22, 23], 
	"trent_chk_on": [870, 835, 22, 23], 
	"trent_close": [772, 835, 24, 24], 
	"trent_coin1": [634, 835, 26, 26], 
	"trent_coin2": [662, 835, 26, 26], 
	"trent_coin3": [690, 835, 26, 26], 
	"trent_cur_row": [769, 768, 204, 29], 
	"trent_exchange": [172, 804, 83, 29], 
	"trent_frame": [2, 2, 609, 642], 
	"trent_friend": [894, 835, 35, 21], 
	"trent_item_bg": [124, 646, 68, 68], 
	"trent_next": [658, 646, 45, 46], 
	"trent_plate": [496, 835, 106, 28], 
	"trent_pr_bg": [2, 768, 496, 34], 
	"trent_pr_bg_s": [257, 804, 492, 28], 
	"trent_pr_line": [500, 768, 267, 30], 
	"trent_pr_sel": [2, 835, 492, 28], 
	"trent_present": [426, 646, 114, 46], 
	"trent_prev": [705, 646, 45, 46], 
	"trent_q2": [194, 646, 56, 56], 
	"trent_q3": [252, 646, 56, 56], 
	"trent_q4": [310, 646, 56, 56], 
	"trent_q5": [368, 646, 56, 56], 
	"trent_rent": [542, 646, 114, 46], 
}

const FRAME = [19, 6]

const SIZE = [630, 650]

const NODES = {"txtFriendName": [325, 539, 210, 35], "btnFriend": [535, 546, 35, 21], "btnPrev": [55, 114, 45, 46], "btnNext": [531, 114, 45, 46], "btnRent": [259, 592, 114, 46], "btnRentPresent": [260, 592, 114, 46], "btnBuy": [458.5, 598, 83, 29], "btnClose": [592, 33, 24, 24], "cvsTank0": [108, 80, 120, 152], "cvsTank1": [253, 80, 120, 152], "cvsTank2": [398, 80, 120, 152], "btnCharge": [537, 484, 62, 35], "imgItem": [42.25, 534, 52, 48], "processExchange": [109, 551, 138, 17], "btnExchange": [41, 600, 83, 29], "btnAdd": [124, 600, 83, 29], "chkPresent": [297, 542, 22, 23], "itemBg": [34.25, 524, 68, 68], "imgQuality": [40.2, 530, 56, 56]}

const TEXTS = {"lblNum": [16.25, 570, 85, 0, 12, "ffffff", 1, "r"], "lblTankChips": [114.25, 548, 127.75, 0, 14, "ffffff", 1, "c"], "lblRentDesc": [369, 463, 215, 0, 13, "feef8d", 1, "r"]}

const CELL = {"bg": [0, 0], "plate": [7, 123], "level": [49, 127], "cbox": [11, 124], "tank": [60, 55], "zoom": 0.5}

const CELL_TEXTS = {"lblTankName": [22.5, 91, 75, 0, 12, "f5f200", 1, "c"]}

const PRICE = {"at": [51, 281], "row": 32, "clip": [49, 279, 534, 182]}

const PRICE_ROW = {"bg": [34, -1], "bg_s": [36, 2], "sel": [36, 2], "line": [119, 3], "cbox": [6, 0], "coin": [141, 3, 26, 26], "chip": [282, 2, 28, 28]}

const PRICE_TEXTS = {"lblRentTime": [30, 16, 121, 0, 12, "fcfefe", 1, "c"], "lblVipRentTimes": [124, 16, 121, 0, 12, "fcfefe", 1, "c"], "lblRentPrice": [170, 16, 50, 0, 12, "fcfefe", 1, "l"], "lblNoRentChips": [257, 16, 121, 0, 12, "fcfefe", 1, "c"], "lblRentChips": [309, 16, 78, 0, 12, "fcfefe", 1, "l"], "lblRentDesc": [389, 16, 121, 0, 12, "fcfefe", 1, "c"], "lblSalePrice": [207, 16, 50, 0, 12, "fcfefe", 1, "l"]}

const PRICE_GLOW = "0145aa"

const CUR = {"y": 484, "x": [65, 303], "row": [32, 3], "icon": [42, 5], "name": [65, 7, 87], "value_present": [106, 7, 120], "value_gold": [106, 6, 120]}
