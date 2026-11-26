extends RefCounted

const FILE: String = "res://assets/ui/hall/guild.png"

const R: Dictionary = {
	"gu_appoint": [702, 849, 96, 28], 
	"gu_ask": [2, 648, 369, 199], 
	"gu_ask_guy": [793, 2, 180, 292], 
	"gu_ask_no": [124, 849, 100, 33], 
	"gu_ask_ok": [226, 849, 100, 33], 
	"gu_cj": [2, 398, 436, 248], 
	"gu_cj_line": [465, 916, 400, 2], 
	"gu_cj_watch": [591, 886, 22, 22], 
	"gu_closed": [805, 886, 18, 18], 
	"gu_contribute": [681, 886, 60, 18], 
	"gu_create_team": [800, 849, 96, 28], 
	"gu_dlg_ok": [2, 849, 120, 35], 
	"gu_donate": [743, 886, 60, 18], 
	"gu_ex": [440, 398, 364, 207], 
	"gu_ex_line": [2, 920, 390, 2], 
	"gu_gift": [430, 849, 66, 29], 
	"gu_info": [2, 2, 298, 394], 
	"gu_join_league": [700, 648, 198, 48], 
	"gu_league": [395, 648, 282, 74], 
	"gu_leave": [898, 849, 96, 28], 
	"gu_level_up": [2, 886, 96, 28], 
	"gu_list": [302, 2, 489, 315], 
	"gu_match_rule": [900, 648, 48, 48], 
	"gu_member_invite": [328, 849, 100, 33], 
	"gu_member_op": [615, 886, 22, 22], 
	"gu_menu_line": [394, 920, 160, 2], 
	"gu_my_clan": [100, 886, 96, 28], 
	"gu_open": [825, 886, 18, 18], 
	"gu_rank": [198, 886, 96, 28], 
	"gu_recruit": [394, 886, 91, 27], 
	"gu_rename": [498, 849, 66, 29], 
	"gu_row_line": [2, 916, 461, 2], 
	"gu_sb_bk": [373, 648, 20, 100], 
	"gu_sb_down": [639, 886, 19, 19], 
	"gu_sb_thumb": [679, 648, 19, 64], 
	"gu_sb_up": [660, 886, 19, 19], 
	"gu_set_notice": [296, 886, 96, 28], 
	"gu_skill": [566, 849, 66, 29], 
	"gu_team_op": [533, 886, 56, 26], 
	"gu_title": [487, 886, 44, 27], 
	"gu_watch": [634, 849, 66, 29], 
}

const PANELS = {"list": [23, 52], "info": [514, 51]}

const FRAME = {"hall": [-9, -9], "list": [804, 36], "chat": [-2, 398], "input": [-2, 557], "menu": [242, 552]}

const PLACE = [["hall", 0, 0, "arena_bg", "", 0, 0, 100, 0], ["hall", 16, 46, "gameroom_pvpReadyRoom1000x600_shadow", "", 0, 0, 100, 0], ["hall", 487, 21, "gu_title", "", 0, 0, 100, 0], ["hall", 23, 52, "gu_list", "", 0, 0, 100, 0], ["hall", 514, 51, "gu_info", "", 0, 0, 100, 0], ["hall", 500, 462, "gu_league", "", 0, 0, 100, 0], ["hall", 979, 15, "public_button_close", "back", 0, 0, 100, 1], ["list", 0, 0, "gameroom_roomplayerlist_bk", "", 0, 0, 100, 0], ["list", 9, 40, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 106, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 172, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 238, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 304, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 370, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 436, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0]]

const BUTTONS = {"member": [["btnJoinLeague", "gu_join_league", 511, 475], ["btnMyClan", "gu_my_clan", 161, 368], ["btnMemberInvite", "gu_member_invite", 369, 366], ["btnWatchMatchRule", "gu_match_rule", 723, 475], ["btnSkill", "gu_skill", 558, 402], ["btnCorpsGift", "gu_gift", 630, 402], ["btnRank", "gu_rank", 702, 402], ["btnLeaveClan", "gu_leave", 265, 368], ["btnCorpsCountribute", "gu_contribute", 731, 165], ["btnDonate", "gu_donate", 731, 199]], "teamLeader": [["btnJoinLeague", "gu_join_league", 511, 475], ["btnMyClan", "gu_my_clan", 24, 368], ["btnWatchMatchRule", "gu_match_rule", 723, 475], ["btnSkill", "gu_skill", 558, 402], ["btnCorpsGift", "gu_gift", 630, 402], ["btnRank", "gu_rank", 702, 402], ["btnLeaveClan", "gu_leave", 211, 368], ["btnCorpsCountribute", "gu_contribute", 731, 165], ["btnDonate", "gu_donate", 731, 199], ["btnRecruitManage", "gu_recruit", 420, 370]], "viceLeader": [["btnJoinLeague", "gu_join_league", 511, 475], ["btnMyClan", "gu_my_clan", 24, 368], ["btnWatchMatchRule", "gu_match_rule", 723, 475], ["btnSkill", "gu_skill", 558, 402], ["btnCorpsGift", "gu_gift", 630, 402], ["btnRank", "gu_rank", 702, 402], ["btnLeaveClan", "gu_leave", 123, 368], ["btnCorpsCountribute", "gu_contribute", 731, 165], ["btnDonate", "gu_donate", 731, 199], ["btnCreateTeam", "gu_create_team", 222, 368], ["btnAppoint", "gu_appoint", 321, 368], ["btnRecruitManage", "gu_recruit", 420, 370], ["btnCorpsLevelUp", "gu_level_up", 700, 236], ["btnSetNotice", "gu_set_notice", 700, 268]], "manageClan": [["btnJoinLeague", "gu_join_league", 511, 475], ["btnMyClan", "gu_my_clan", 24, 368], ["btnWatchMatchRule", "gu_match_rule", 723, 475], ["btnSkill", "gu_skill", 558, 402], ["btnCorpsGift", "gu_gift", 630, 402], ["btnRank", "gu_rank", 702, 402], ["btnLeaveClan", "gu_leave", 123, 368], ["btnCorpsCountribute", "gu_contribute", 731, 165], ["btnDonate", "gu_donate", 731, 199], ["btnCreateTeam", "gu_create_team", 222, 368], ["btnAppoint", "gu_appoint", 321, 368], ["btnRecruitManage", "gu_recruit", 420, 370], ["btnCorpsRename", "gu_rename", 730, 68], ["btnCorpsLevelUp", "gu_level_up", 700, 236], ["btnSetNotice", "gu_set_notice", 700, 268]]}

const INFO = {"lblClanName": [604, 66, 194, 32, 13, "ffffff", 1, "l"], "lblClanLeaderName": [604, 99, 194, 32, 13, "ffffff", 1, "l"], "txtActiveValue": [604, 132, 194, 32, 13, "ffffff", 1, "l"], "txtCoin": [604, 166, 194, 32, 13, "ffffff", 1, "l"], "txtNotice": [533, 294, 262, 75, 12, "ffffff", 0, "l"], "txtLevel": [604, 234, 194, 32, 13, "ffffff", 1, "l"], "txtTeamMoney": [604, 200, 194, 32, 13, "ffffff", 1, "l"]}

const BADGE = [610, 107, 40, 20]

const ACT_TIME = [642, 529, 0, 0, 14, "ffffff", 1, "c"]

const TREE = [27, 75, 480, 288]

const ASK = {"panel": [46, 1], "btnCancel": [240, 133, 100, 33], "btnConfirm": [120, 133, 100, 33], "txtContent": [102, 38, 270, 90, 14, "ffffff", 1, "l"]}

const DIALOGS = {"cj": {"size": [468, 368], "panel": [16, 59], "list": [19, 83, 429, 220], "ok": [174, 316], "close": [429, 15]}, "ex": {"size": [398, 326], "panel": [17, 55], "list": [21, 78, 356, 180], "ok": [139, 274], "close": [359, 15], "bed": [135, 270]}}
