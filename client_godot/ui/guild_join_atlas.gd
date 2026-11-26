extends RefCounted

const FILE: String = "res://assets/ui/hall/guild_join.png"

const R: Dictionary = {
	"gj_apply": [631, 831, 120, 35], 
	"gj_apply_base": [526, 831, 103, 37], 
	"gj_apply_off": [753, 831, 120, 35], 
	"gj_buy": [2, 893, 60, 32], 
	"gj_check_off": [457, 893, 27, 26], 
	"gj_check_on": [428, 893, 27, 27], 
	"gj_create": [2, 503, 398, 326], 
	"gj_cut": [2, 927, 781, 2], 
	"gj_down": [64, 893, 96, 30], 
	"gj_find": [402, 503, 358, 258], 
	"gj_new": [274, 831, 124, 46], 
	"gj_next": [260, 893, 33, 29], 
	"gj_ok": [875, 831, 120, 35], 
	"gj_panel": [2, 2, 788, 499], 
	"gj_prev": [295, 893, 33, 29], 
	"gj_quick": [2, 831, 270, 60], 
	"gj_request": [486, 893, 38, 22], 
	"gj_request_off": [526, 893, 38, 22], 
	"gj_search": [400, 831, 124, 46], 
	"gj_title": [330, 893, 96, 27], 
	"gj_up": [162, 893, 96, 30], 
	"gj_watch": [566, 893, 22, 22], 
}

const PANEL = [20, 55]

const AT = {"image1": [461, 21, 96, 27], "btnPreviousPage": [705, 404, 33, 29], "btnNextPage": [747, 404, 33, 29], "btnJoinCorps": [508, 435, 270, 60], "btnCreateCorps": [515, 502, 124, 46], "btnSearchCorps": [649, 502, 124, 46], "cbShowCanJoin": [508, 400, 27, 26], "lstClan": [23, 75, 780, 320]}

const ROW = {"btnWatch": [688, 4, 22, 22], "btnRequest": [711, 5, 38, 22], "cut": [0, 30, 781, 2]}

const ROW_TEXT = {"lblActValue": [123, 5, 60, 0, 13, "ffffff", 1, "c"], "lblClanName": [2, 6, 110, 0, 13, "ffffff", 1, "c"], "lblNum": [194, 6, 60, 0, 13, "ffffff", 1, "c"], "lblLevelLimit": [255, 6, 60, 0, 13, "ffffff", 1, "c"], "lblLadder": [325, 6, 60, 0, 13, "ffffff", 1, "c"], "lblNotice": [394, 6, 200, 0, 13, "ffffff", 1, "l"], "lblAutoJoin": [600, 6, 80, 0, 13, "ffffff", 1, "c"]}

const CREATE = {"btnCancel": [359, 15, 24, 24], "txtClanName": [94, 170, 210, 35], "btnConfirm": [139, 274, 120, 35], "txtCorpsName": [94, 93, 210, 35], "lblTip": [60, 216, 250, 0], "btnBuy": [314, 211, 60, 32]}

const CREATE_SIZE = [398, 326]

const FIND = {"btnClose": [319, 15, 24, 24], "txtClanName": [74, 112, 210, 35], "btnConfirm": [119, 206, 120, 35]}

const FIND_SIZE = [358, 258]

const APPLY = {"base_l": [18, 456, 103, 37], "base_r": [338, 456, 103, 37], "btnPre": [20, 459, 96, 30], "btnNext": [340, 459, 96, 30], "btnJoinClan": [169, 456, 120, 35]}
