extends RefCounted

const FILE: String = "res://assets/ui/hall/league.png"

const R: Dictionary = {
	"lg_apply": [2, 765, 270, 60], 
	"lg_applylist": [2, 525, 378, 238], 
	"lg_board": [198, 2, 788, 252], 
	"lg_btnbk": [712, 827, 136, 58], 
	"lg_btnbk_l": [274, 765, 270, 60], 
	"lg_chat_cvt": [382, 525, 464, 163], 
	"lg_cond_cut": [2, 929, 350, 2], 
	"lg_cross": [976, 827, 34, 34], 
	"lg_cutline": [2, 925, 761, 2], 
	"lg_details": [238, 889, 58, 28], 
	"lg_droparrow": [377, 889, 23, 17], 
	"lg_enter": [546, 765, 270, 60], 
	"lg_joinclan": [2, 827, 270, 60], 
	"lg_list_cvt": [2, 2, 194, 521], 
	"lg_reward": [850, 827, 124, 46], 
	"lg_rule": [38, 889, 98, 31], 
	"lg_select": [546, 827, 164, 59], 
	"lg_showreward": [138, 889, 98, 31], 
	"lg_tick": [2, 889, 34, 34], 
	"lg_w_confirm": [298, 889, 77, 21], 
	"lg_watch": [274, 827, 270, 60], 
}

const FRAME = {"hall": [-9, -9]}

const PLACE = [["hall", 0, 0, "arena_bg", "", 0, 0, 100, 0], ["hall", 16, 46, "gameroom_pvpReadyRoom1000x600_shadow", "", 0, 0, 100, 0], ["hall", 20, 144, "lg_board", "", 0, 0, 100, 0], ["hall", 813, 45, "lg_list_cvt", "", 0, 0, 100, 0], ["hall", 10, 410, "lg_chat_cvt", "", 0, 0, 100, 0], ["hall", 24, 55, "lg_select", "select", 0, 0, 100, 1], ["hall", 159, 78, "lg_droparrow", "", 0, 0, 100, 0], ["hall", 584, 53, "lg_rule", "rule", 0, 0, 100, 1], ["hall", 694, 53, "lg_showreward", "showreward", 0, 0, 100, 1], ["hall", 979, 15, "public_button_close", "close", 0, 0, 100, 1]]

const STATES = {"NORMAL": {"rows": [["hall", 508, 417, "lg_btnbk_l", "", 0, 0, 100, 0], ["hall", 508, 417, "lg_enter", "enter", 0, 0, 100, 1], ["hall", 578, 484, "lg_btnbk", "", 0, 0, 100, 0], ["hall", 584, 490, "lg_reward", "reward", 0, 0, 100, 1]], "badge": [685, 488], "badge_num": [685, 500.5], "time": []}, "APPLY": {"rows": [["hall", 508, 395, "lg_btnbk_l", "", 0, 0, 100, 0], ["hall", 508, 395, "lg_apply", "apply", 0, 0, 100, 1], ["hall", 578, 454, "lg_btnbk", "", 0, 0, 100, 0], ["hall", 584, 460, "lg_reward", "reward", 0, 0, 100, 1]], "badge": [685, 455], "badge_num": [685, 467.5], "time": [481, 512, 320, 58, 12, "17487c", 1, "c"]}, "WATCH": {"rows": [["hall", 508, 417, "lg_btnbk_l", "", 0, 0, 100, 0], ["hall", 508, 417, "lg_watch", "watch", 0, 0, 100, 1], ["hall", 578, 484, "lg_btnbk", "", 0, 0, 100, 0], ["hall", 584, 490, "lg_reward", "reward", 0, 0, 100, 1]], "badge": [685, 488], "badge_num": [685, 500.5], "time": []}, "CORPS": {"rows": [["hall", 508, 417, "lg_btnbk_l", "", 0, 0, 100, 0], ["hall", 508, 417, "lg_joinclan", "joinclan", 0, 0, 100, 1], ["hall", 578, 484, "lg_btnbk", "", 0, 0, 100, 0], ["hall", 584, 490, "lg_reward", "reward", 0, 0, 100, 1]], "badge": [685, 488], "badge_num": [685, 500.5], "time": []}, "INIT": {"rows": [["hall", 578, 484, "lg_btnbk", "", 0, 0, 100, 0], ["hall", 584, 490, "lg_reward", "reward", 0, 0, 100, 1]], "badge": [685, 488], "badge_num": [685, 500.5], "time": [518, 421, 260, 58, 12, "17487c", 1, "c"]}}

const BOARD = [20, 144]

const HEAD = [[103, 127, "Giai đoạn"], [262, 127, "Vòng"], [501, 127, "Thời gian bắt đầu"], [734, 128, "Thao tác"]]

const LIST = [23, 148, 780, 243, 32]

const ROW = {"lblPhaseName": [0, 6, 160, 0, 12, "ffffff", 1, "c"], "lblRoundName": [159, 6, 160, 0, 12, "ffffff", 1, "c"], "lblHeldTime": [318, 6, 320, 0, 12, "ffffff", 1, "c"], "details": [677, 2], "cutline": [0, 30]}

const PHASE = {"at": [192, 89], "wide": 602, "back": [12, 0, 582, 26, "062c61"], "fill": [12, 1, 582, 22, "257bb4"], "arrow": "f16422", "head": 30, "title": [96, 24, 15]}

const SELECT = {"cur": [29, 60, 130, 50], "box": [30, 121, 136, 146], "list_high": 144, "row": 50, "item_wide": 130}

const MODE = {"word": [190, 61], "rect": [254, 58, 50, 22], "label": [263, 63, 32, 0, 11, "ffffff", 1, "c"]}

const TITLE = [509, 20]

const APPLY = {"size": [422, 362], "list": [22, 56], "holder": [26, 60, 370, 230], "row": 32, "mark": [0, -1], "cut": [0, 30], "text": [41, 5, 300, 0, 13, "ffffff", 1, "l"]}
