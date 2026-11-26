extends RefCounted

const FILE: String = "res://assets/ui/hall/corps_rank.png"

const R: Dictionary = {
	"cr_bg": [2, 2, 870, 504], 
	"cr_close": [943, 1196, 24, 24], 
	"cr_cut": [88, 1257, 781, 2], 
	"cr_list": [2, 508, 788, 342], 
	"cr_list_solo": [2, 852, 788, 342], 
	"cr_mine": [837, 1196, 104, 26], 
	"cr_mine_solo": [2, 1257, 84, 21], 
	"cr_next": [767, 1196, 33, 29], 
	"cr_pager": [593, 1196, 66, 40], 
	"cr_prev": [802, 1196, 33, 29], 
	"cr_reward": [485, 1196, 106, 40], 
	"cr_round1": [225, 1196, 128, 45], 
	"cr_round2": [355, 1196, 128, 45], 
	"cr_solo": [661, 1196, 104, 34], 
	"cr_title": [792, 852, 221, 59], 
	"cr_title_solo": [2, 1196, 221, 59], 
}

const SIZE = [870, 504]

const NODES = {"cimagechecklocal1": [312.5, -4, 221, 59], "btnLastPage": [693, 446, 33, 29], "btnNextPage": [795, 446, 33, 29], "btnRound1": [450, 437, 128, 45], "btnRound2": [450, 437, 128, 45], "btnViewReward": [582, 437, 106, 40], "imgSelfRank": [38, 441, 104, 26], "btnClose": [828, 27, 24, 24], "frmCorpsList": [31, 82, 788, 350], "pager": [727, 443, 66, 40], "imgSelfRankSolo": [38, 445, 84, 21]}

const TEXTS = {"lblPage": [731, 449, 57, 0, 16, "ffffff", 1, "c"], "lblSelfRank": [143, 441, 70, 0, 18, "005797", 1, "c"], "lblSelfRankSolo": [126, 442, 70, 0, 18, "005797", 1, "c"]}

const PAGE_RIM = ["996633", 0.8]

const LIST = {"point": [0, 4], "solo": [0, 4]}

const LST = [4, 26, 780, 320, 32]

const DARK = [0, 83, 145, 68]

const HELP = [752, 4, 16, 16]

const HELP_TIP = "Trợ thủ sẽ hỗ trợ chiến lực cho người chơi trong trận chiến gần nhất"

const ROW_POINT = {"lblRank": [0, 5, 80, 0, 14, "ffffff", 1, "c"], "lblLeaderName": [347, 6, 110, 0, 12, "ffffff", 1, "l"], "lblCorpsName": [120, 6, 160, 0, 12, "ffffff", 1, "l"], "lblCorpsPoint": [488, 6, 80, 0, 12, "ffffff", 1, "c"], "lblPetPoint": [578, 6, 80, 0, 12, "ffffff", 1, "c"]}

const ROW_SOLO = {"lblRank": [0, 5, 80, 0, 14, "ffffff", 1, "c"], "lblPlayerName": [112, 6, 110, 0, 12, "ffffff", 1, "l"], "lblWinPoint": [333, 6, 160, 0, 12, "ffffff", 1, "l"], "lblCorpsPoint": [508, 6, 80, 0, 12, "ffffff", 1, "c"], "lblPetPoint": [679, 6, 80, 0, 12, "ffffff", 1, "c"]}

const ROW_NODES = {"imgRank": [23, -1, 32, 32], "btnSoloRank": [674, -1, 104, 34], "cutline": [0, 30, 781, 2]}

const RANK_IMAGES = 50
