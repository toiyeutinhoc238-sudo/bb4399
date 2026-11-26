extends RefCounted

const FILE: String = "res://assets/ui/hall/league_info.png"

const R: Dictionary = {
	"li_aw_bg": [872, 576, 84, 84], 
	"li_close": [638, 1000, 24, 24], 
	"li_cut": [2, 1031, 836, 2], 
	"li_enter": [442, 1000, 96, 28], 
	"li_find": [374, 1000, 66, 29], 
	"li_frame": [2, 2, 951, 572], 
	"li_lose": [2, 931, 117, 67], 
	"li_next": [240, 931, 83, 58], 
	"li_next_off": [325, 931, 83, 58], 
	"li_pre": [410, 931, 83, 58], 
	"li_pre_off": [495, 931, 83, 58], 
	"li_rank": [2, 576, 868, 353], 
	"li_reward": [540, 1000, 96, 28], 
	"li_win": [121, 931, 117, 67], 
	"li_zone0": [580, 931, 91, 29], 
	"li_zone0_on": [673, 931, 91, 29], 
	"li_zone1": [766, 931, 91, 29], 
	"li_zone1_on": [859, 931, 91, 29], 
	"li_zone2": [2, 1000, 91, 29], 
	"li_zone2_on": [95, 1000, 91, 29], 
	"li_zone3": [188, 1000, 91, 29], 
	"li_zone3_on": [281, 1000, 91, 29], 
}

const FRAME = [19, 18]

const SIZE = [972, 592]

const BUTTONS = {"btnClose": [934, 33, 24, 24], "btnPreRound": [11, 108, 83, 58], "btnNextRound": [877, 108, 83, 58], "btnZone0": [94, 129, 91, 29], "btnZone1": [184, 129, 91, 29], "btnZone2": [274, 129, 91, 29], "btnZone3": [364, 129, 91, 29], "btnCurReward": [779, 116, 96, 28], "btnEnterLeagueRoom": [680, 116, 96, 28], "btnFind": [854, 531, 66, 29]}

const TITLE = [486, 22]

const PHASE = {"at": [65, 73], "wide": 842, "back": [12, 0, 822, 26, "062c61"], "fill": [12, 1, 822, 22, "257bb4"], "arrow": "f16422", "head": 30, "title": [96, 22, 15]}

const LABELS = {"lblRoundName": [100, 100, 400, 30, 18, "ffffff", 1, "l"], "lblMatchTime": [446, 119, 235, 0, 14, "005797", 1, "l"]}

const FIND = [660, 531, 190, 31]

const RANK = [51, 179]

const HEAD = [[317, 176, "Tên Team"], [462, 176, "Uy vọng"], [552, 176, "Tích điểm"], [642, 176, "Thắng/Thua"], [732, 176, "Tỉ lệ thắng"], [846, 176, "Thao tác"]]

const LIST = [55, 198, 860, 330, 32]

const ROW = {"stripe": [0, 83, 145, 68], "cut": [0, 30], "lblRank": [2, 6, 160, 0, 12, "ffffff", 0, "c"], "lblClanName": [162, 6, 200, 0, 12, "ffffff", 0, "c"], "lblGlory": [362, 6, 90, 0, 12, "ffffff", 0, "c"], "lblScore": [452, 6, 90, 0, 12, "ffffff", 0, "c"], "lblWinCount": [542, 6, 90, 0, 12, "ffffff", 0, "c"], "lblWinRate": [632, 6, 90, 0, 12, "ffffff", 0, "c"]}

const REWARD = {"win_t": [160, 190], "lose_t": [693, 190], "win": [180, 222], "lose": [520, 222], "pitch": [90, 102], "cols": 3, "max": 9}
