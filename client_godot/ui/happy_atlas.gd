extends RefCounted

const FILE: String = "res://assets/ui/hall/happy.png"

const R: Dictionary = {
	"vv_backhall": [840, 469, 116, 47], 
	"vv_backroom": [2, 539, 116, 47], 
	"vv_backtip": [262, 539, 108, 33], 
	"vv_bar": [645, 588, 50, 5], 
	"vv_board": [2, 2, 494, 383], 
	"vv_clock": [622, 588, 21, 18], 
	"vv_continue": [682, 469, 156, 47], 
	"vv_fly_down": [86, 387, 495, 68], 
	"vv_fly_up": [2, 469, 495, 68], 
	"vv_hr_1": [154, 588, 22, 26], 
	"vv_hr_2": [178, 588, 22, 26], 
	"vv_hr_3": [202, 588, 22, 26], 
	"vv_hr_4": [226, 588, 22, 26], 
	"vv_hr_5": [250, 588, 22, 26], 
	"vv_hr_6": [274, 588, 22, 26], 
	"vv_killer": [372, 539, 164, 30], 
	"vv_king": [538, 539, 164, 30], 
	"vv_num2": [120, 539, 140, 42], 
	"vv_pf_other": [499, 469, 62, 60], 
	"vv_pf_self": [2, 387, 82, 80], 
	"vv_rank_1": [298, 588, 48, 23], 
	"vv_rank_2": [348, 588, 48, 23], 
	"vv_rank_3": [398, 588, 48, 23], 
	"vv_rank_4": [448, 588, 48, 23], 
	"vv_rank_5": [498, 588, 48, 23], 
	"vv_rank_6": [548, 588, 48, 23], 
	"vv_report": [598, 588, 22, 22], 
	"vv_stage": [498, 2, 445, 140], 
	"vv_talk_1": [856, 539, 150, 28], 
	"vv_talk_2": [704, 539, 150, 29], 
	"vv_talk_3": [2, 588, 150, 28], 
	"vv_timeboard": [563, 469, 117, 48], 
}

const SIZE = [977, 618]

const PANELS = {"board": [14, 22], "stage": [516, 16]}

const NODES = {"cvsChat": [35, 407, 464, 203], "lstResult": [14, 11, 0, 0], "cvsResultAvatar": [516, 16, 445, 140], "tankAvatar": [670, 18, 0, 0], "imgCharAvatar": [708, 19, 60, 60], "imgAssistKing": [789, 44, 164, 30], "imgKiller": [789, 21, 164, 30], "imgVipLevel": [586, 136, 36, 18], "frmResult": [508, 230, 460, 324], "btnContinue": [545, 562, 156, 47], "btnBackRoom": [715, 562, 116, 47], "btnBackHall": [715, 562, 116, 47], "cvsBackTip": [719, 533, 108, 33]}

const TEXTS = {"lblPlayerName": [622, 134, 0, 0, 12, "ffffff", 0, "l"], "lblPlayerBackNum": [723, 538, 100, 0, 14, "ffffff", 1, "c"]}

const LIST = [16, 42, 36, 10]

const RANKS = 6

const ROW = {"canvas1": [1, 0.5, 488, 33], "avatar": [56, 2, 0, 0], "cvsLevel": [87, 9, 80, 40], "btnAddFriend": [270, 8, 22, 22], "btnReport": [294, 8, 22, 22], "imgRank": [6, 6, 48, 23]}

const ROW_TEXTS = {"lblPlayerName": [126, 8, 100, 0, 13, "fff600", 1, "l"], "lblBattleData": [319, 7, 90, 0, 16, "fff600", 1, "c"]}

const TOP = {"timeboard": [91.5, 146], "clock": [119.0, 162], "count": [135.0, 160, 60, 16], "over": [148.0, 116.0]}

const GAME = {"txtKillArea": [610, 40, 390, 88, 14, "ffffff", 0, "r"], "txtHappyTip": [100, 95, 800, 50, 14, "ffffff", 0, "c"]}

const PLAYER = {"other": {"image1": [62, 0, 62, 60], "avatarview1": [6, 4, 0, 0], "lblPlayerName": [2, 35, 60, 0], "pgsTankBlood": [6, 49, 50, 6], "imgRank": [0, 0, 0, 0], "cvsChat": [0, 81, 180, 85], "image2": [4, 110, 150, 29], "image3": [4, 139, 150, 28], "txtChatContent": [5, 99, 140, 0], "size": [62, 82], "chat": [0, 81]}, "self": {"image1": [0, 0, 82, 80], "avatarview1": [16, 12, 0, 0], "lblPlayerName": [1, 53, 80, 0], "pgsTankBlood": [6, 68, 70, 6], "imgRank": [0, 0, 0, 0], "cvsChat": [0, 100, 180, 85], "image2": [4, 129, 150, 29], "image3": [4, 158, 150, 28], "txtChatContent": [5, 118, 140, 0], "size": [82, 102], "chat": [0, 100]}}

const PLAYER_TEXTS = {"other": {"lblPlayerName": [2, 35, 60, 0, 12, "ffffff", 0, "c"], "txtChatContent": [5, 99, 140, 0, 14, "160000", 1, "l"]}, "self": {"lblPlayerName": [1, 53, 80, 0, 12, "ffffff", 0, "c"], "txtChatContent": [5, 118, 140, 0, 14, "160000", 1, "l"]}}

const BAR = {"track": ["160000", "330000"], "size": [50, 6]}

const NUM2 = {"cell": [14, 21], "step": 14, "rect": 62, "self": [10, 80], "other": [0, 60]}

const FLY = {"cell": [45, 68], "cell_down": [45, 68], "step": 45}
