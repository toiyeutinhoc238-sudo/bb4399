extends RefCounted

const FILE: String = "res://assets/ui/hall/guild_team.png"

const R: Dictionary = {
	"gt_body_0": [2, 2, 418, 384], 
	"gt_body_1": [422, 2, 418, 384], 
	"gt_contribute": [206, 388, 96, 28], 
	"gt_enter": [2, 388, 66, 29], 
	"gt_enter_off": [70, 388, 66, 29], 
	"gt_kick": [304, 388, 96, 28], 
	"gt_ok": [842, 2, 120, 35], 
	"gt_rename": [138, 388, 66, 29], 
	"gt_switch_off": [402, 388, 49, 26], 
	"gt_switch_on": [453, 388, 49, 26], 
}

const BOX = [458, 508]

const BODY = {"captain": [20, 54, "gt_body_0"], "teammate": [20, 54, "gt_body_0"], "teammateAndLeader": [20, 54, "gt_body_0"], "leader": [20, 54, "gt_body_1"], "visit": [20, 54, "gt_body_1"]}

const BUTTONS = {"captain": {"btnRename": [328, 72], "btnKickOut": [287, 393], "btnPersonalContribute": [77, 393], "btnInstanceEnterance": [301, 206], "btnInstanceSwitch": [372, 208]}, "teammate": {"btnPersonalContribute": [181, 393], "btnInstanceEnterance": [301, 206]}, "teammateAndLeader": {"btnKickOut": [287, 393], "btnPersonalContribute": [64, 393], "btnInstanceEnterance": [301, 206]}, "leader": {"btnRename": [328, 72], "btnKickOut": [287, 393]}, "visit": {}}

const AT = {"close": [419, 15, 24, 24], "ok": [169, 456, 120, 35], "tip": [203, 147, 16, 16], "help": [203, 213, 16, 16]}

const TEXTS = {"lblClanName": [144, 19, 170, 0, 17, "ffffff", 1, "c"], "txtClanName": [132, 71, 264, 32, 13, "ffffff", 1, "l"], "txtClanLeader": [132, 105, 264, 32, 13, "ffffff", 1, "l"], "lblLevel": [132, 138, 94, 32, 13, "ffffff", 1, "c"], "lblTeamFund": [132, 171, 94, 32, 13, "ffffff", 1, "c"], "lblMaintenance": [132, 204, 94, 32, 13, "ffffff", 1, "c"], "lblTeamCoutribute": [301, 171, 94, 32, 13, "ffffff", 1, "c"], "lblHonor": [301, 138, 94, 32, 13, "ffffff", 1, "c"]}

const LIST = [64, 266, 332, 121]

const COLS = {"lblPost": [262, 15, 50, 0, 12, "ffffff", 1, "l"], "lblMerit": [212, 15, 50, 0, 12, "ffffff", 1, "c"], "lblVirtue": [142, 15, 70, 0, 12, "ffffff", 1, "c"], "lblPlayerName": [44, 15, 100, 0, 12, "ffffff", 1, "l"]}

const KEEP = {"1": [2000, 1000, 2000], "2": [4900, 1125, 2250], "3": [10400, 1250, 2500], "4": [16400, 1375, 2750], "5": [28700, 1500, 3000], "6": [48200, 1625, 3250], "7": [75600, 1750, 3500], "8": [118500, 1875, 3750], "9": [0, 2000, 4000]}

const WORDS = {"maint": "@num1@/ngày", "level_tip": "Team tăng đến lv kế cần tốn @num1@ Uy Vọng Team, nhận uy vọng từ PB Team, đấu xếp hạng Team và Team League. Lv team càng cao, độ cống hiện nhận được càng cao.", "full_lv": "Đầy lv", "no_section": "Không Huy Chương"}
