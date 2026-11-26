extends RefCounted

const FILE: String = "res://assets/ui/hall/master.png"

const R: Dictionary = {
	"ms_agree": [824, 2068, 58, 26], 
	"ms_apply": [2, 1562, 454, 504], 
	"ms_apply_list": [458, 1562, 422, 308], 
	"ms_btn_apply": [628, 2068, 96, 28], 
	"ms_btn_charge": [726, 2068, 96, 28], 
	"ms_btn_reward": [456, 2068, 100, 33], 
	"ms_card": [2, 2068, 164, 75], 
	"ms_card_discard": [47, 2145, 38, 18], 
	"ms_card_remove": [87, 2145, 38, 18], 
	"ms_card_sel": [168, 2068, 164, 75], 
	"ms_card_watch": [127, 2145, 38, 18], 
	"ms_cut390": [2, 2169, 390, 2], 
	"ms_cut542": [185, 2145, 542, 2], 
	"ms_disagree": [884, 2068, 58, 26], 
	"ms_find": [2, 522, 599, 518], 
	"ms_help": [167, 2145, 16, 16], 
	"ms_help_ok": [334, 2068, 120, 35], 
	"ms_join": [26, 2145, 19, 19], 
	"ms_main": [2, 2, 809, 518], 
	"ms_next": [558, 2068, 33, 29], 
	"ms_prev": [593, 2068, 33, 29], 
	"ms_row_baishi": [944, 2068, 38, 24], 
	"ms_row_shoutu": [984, 2068, 38, 24], 
	"ms_row_watch": [2, 2145, 22, 22], 
	"ms_student": [2, 1042, 579, 518], 
}

const SIZES = {"main": [830, 520], "student": [600, 520], "find": [620, 520], "card": [164, 75], "row": [542, 30], "apply": [458, 508], "apply_row": [390, 32], "help": [422, 362]}

const PANELS = {"main": [19, 0], "student": [19, 0], "find": [19, 0], "apply": [2, 2], "apply_list": [18, 122]}

const MAIN = {"btnClose": [792, 33, 24, 24], "btnViewApply": [49, 465, 96, 28], "btnChargeReward": [152, 465, 96, 28], "txtHelper": [286, 107, 491, 382], "imgHelp": [770, 52, 16, 16], "join": [134, 463, 19, 19], "list": [55, 80, 181, 379]}

const MAIN_TEXT = {"lblNum": [131, 472.5, 25, 0, 11, "ffffff", 1, "c"], "txtHelper": [286, 107, 491, 382, 12, "ffffff", 1, "l"]}

const STUDENT = {"btnClose": [562, 33, 24, 24], "lstQuest": [56, 178, 490, 318], "imgHelp": [543, 60, 16, 16], "cvsMaster": [40, 67, 164, 75], "btnGetReward": [458, 89, 100, 33]}

const FIND = {"btnClose": [582, 33, 24, 24], "btnLastPage": [266, 407, 33, 29], "btnNextPage": [316, 407, 33, 29], "imgHelp": [564, 54, 16, 16], "lstFindStudent": [39, 94, 542, 300], "title": [219, 0, 182, 53]}

const FIND_TEXT = {"txtNoMasterTip": [64.5, 164, 491, 192, 24, "ffffff", 1, "c"]}

const CARD = {"imgHead": [7, 7, 40, 40], "imgVip": [128, 31, 36, 18], "btnWatch": [52, 49, 38, 18], "btnRemove": [97, 49, 38, 18], "level": [7, 47, 40, 20]}

const CARD_TEXT = {"lblName": [53, 7, 100, 22, 12, "ffffff", 1, "l"], "lblValue": [48, 27, 96, 0, 12, "ffffff", 0, "l"]}

const ROW = {"imgVipLevel": [147, 6, 36, 18], "btnWatch": [475, 4, 22, 22], "btnGetStudent": [498, 2, 38, 24], "level": [0, 5, 40, 20], "cut": [0, 28, 542, 2]}

const ROW_TEXT = {"lblName": [39, 15, 140, 0, 14, "ffffff", 1, "l"], "lblClanName": [352, 15, 120, 0, 12, "ffffff", 1, "c"], "lblElo": [184, 15, 80, 0, 14, "ffffff", 1, "c"], "lblHelperScore": [263, 15, 90, 0, 14, "ffffff", 1, "c"]}

const APPLY = {"btnClose": [419, 14, 24, 24], "list": [22, 126, 414, 300]}

const APPLY_ROW = {"btnApprove": [275, 3, 58, 26], "btnReject": [332, 3, 58, 26], "btnWatch": [128, 4, 22, 22], "level": [1, 6, 40, 20], "cut": [0, 30, 390, 2]}

const APPLY_TEXT = {"lblName": [41, 17, 90, 0, 12, "ffffff", 1, "l"], "lblSex": [157, 7, 30, 0, 12, "ffffff", 1, "l"], "lblTime": [186, 7, 90, 0, 12, "ffffff", 1, "l"]}

const HELP = {"btnCancel": [383, 15, 24, 24], "btnConfirm": [151, 310, 120, 35]}

const HELP_TEXT = {"levelDesc": [34, 66, 358, 232, 12, "ffffff", 1, "l"], "lblTile": [126, 22, 170, 0, 17, "ffffff", 1, "c"]}

const COLUMNS = [[223, 94, 80, 300], [392, 94, 120, 300]]
