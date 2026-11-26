extends RefCounted

const FILE: String = "res://assets/ui/hall/player_info.png"

const R: Dictionary = {
	"pi_buy": [372, 568, 100, 30], 
	"pi_close": [588, 568, 24, 24], 
	"pi_frame": [2, 2, 824, 564], 
	"pi_hb_bar": [364, 568, 6, 48], 
	"pi_hb_box": [850, 2, 84, 84], 
	"pi_hb_glass": [224, 568, 65, 66], 
	"pi_hb_star": [716, 568, 23, 22], 
	"pi_honor_box": [312, 568, 50, 50], 
	"pi_honor_on": [561, 568, 25, 24], 
	"pi_row_on": [2, 568, 220, 76], 
	"pi_sb_bk": [828, 2, 20, 100], 
	"pi_sb_down": [799, 568, 19, 19], 
	"pi_sb_thumb": [291, 568, 19, 64], 
	"pi_sb_up": [820, 568, 19, 19], 
	"pi_section": [765, 568, 32, 21], 
	"pi_t_all": [841, 568, 50, 18], 
	"pi_t_all_on": [893, 568, 50, 18], 
	"pi_t_clan": [945, 568, 50, 18], 
	"pi_t_clan_on": [2, 646, 50, 18], 
	"pi_t_ladder": [614, 568, 49, 22], 
	"pi_t_pvp": [665, 568, 49, 22], 
	"pi_tab_on": [474, 568, 85, 26], 
	"pi_view": [741, 568, 22, 22], 
}

const FRAME = [2, 2]

const SIZE = [828, 568]

const SPOT = {"lblCharOid": [305, 57, 170, 0], "lblGlamourValue": [82, 353, 82, 27], "lblRomanticValue": [82, 386, 82, 27], "lblPlayerName": [69, 61, 152, 24], "cvsCharLevel": [11, 55, 80, 40], "imgCharAvatar": [32, 94, 180, 240], "btnClose": [789, 15, 24, 24], "imgVip": [153, 99, 57, 41], "txtCorpsName": [58, 425, 152, 27], "txtCorpsLevel": [90, 424, 122, 27], "btnWatchCorps": [210, 428, 22, 22], "txtTeamName": [58, 467, 152, 27], "btnWatchTeam": [210, 470, 22, 22], "lblTeamLevel": [88, 466, 122, 27], "lblKillerKing": [288, 129, 82, 27], "imgSectionIcon": [255, 102, 32, 21], "lblSection": [288, 101, 82, 27], "lblDestory": [716, 129, 82, 27], "txtKda": [577, 129, 82, 27], "lblEscape": [577, 101, 82, 27], "lblWinMatch": [431, 101, 82, 27], "txtAssist": [431, 129, 82, 27], "cvsTank": [483, 275, 324, 250], "lblTankName": [557, 450, 0, 28], "lblTankBattlePoint": [720, 398, 82, 27], "imgTankScoreHelp": [723, 404, 16, 16], "lblTankWin": [720, 427, 82, 27], "lblTankKill": [720, 456, 82, 27], "lblTankAssist": [720, 485, 82, 27], "btnBuyTank": [534, 482, 100, 30], "frmHelperBox": [726, 325, 84, 84]}

const TABS = [["all", 486.5, 54.0, 85, 26, 1], ["pvp", 563.5, 54.0, 85, 26, 0], ["ladder", 640.5, 54.0, 85, 26, 0], ["clan", 716.5, 54.0, 85, 26, 1]]
