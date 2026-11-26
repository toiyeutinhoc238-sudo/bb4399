extends RefCounted

const FILE: String = "res://assets/ui/hall/friends.png"

const R: Dictionary = {
	"fr_add_black": [416, 606, 104, 44], 
	"fr_add_box": [506, 2, 354, 254], 
	"fr_add_friend": [522, 606, 104, 44], 
	"fr_ask": [2, 606, 369, 199], 
	"fr_ask_guy": [324, 2, 180, 292], 
	"fr_ask_no": [872, 606, 100, 33], 
	"fr_ask_ok": [2, 807, 100, 33], 
	"fr_close": [412, 807, 24, 24], 
	"fr_closed": [534, 807, 10, 13], 
	"fr_cutline": [561, 807, 160, 2], 
	"fr_female": [438, 807, 16, 23], 
	"fr_frame": [2, 2, 320, 602], 
	"fr_male": [456, 807, 16, 23], 
	"fr_offline": [474, 807, 16, 23], 
	"fr_ok": [628, 606, 120, 35], 
	"fr_ok_off": [750, 606, 120, 35], 
	"fr_open": [546, 807, 13, 10], 
	"fr_sb_bk": [373, 606, 20, 100], 
	"fr_sb_down": [492, 807, 19, 19], 
	"fr_sb_thumb": [395, 606, 19, 64], 
	"fr_sb_up": [513, 807, 19, 19], 
	"fr_title_add": [234, 807, 108, 30], 
	"fr_title_black": [104, 807, 128, 30], 
	"fr_watch": [344, 807, 66, 29], 
}

const PANELS = {"frame": [2, 2], "add": [2, 2], "ask": [46, 1]}

const FRAME = {"cvsCharLevel": [103, 80, 80, 40], "imgHead": [30, 55, 64, 64], "txtSearch": [31, 131, 267, 32], "btnAddFriend": [40, 510, 104, 44], "btnAddBlack": [170, 510, 104, 44], "btnClose": [285, 15, 24, 24], "tree": [28, 180, 264, 320], "area": [25, 175, 270, 330], "_FriendsFrame_Label1": [102, 19, 120, 0, 17, "ffffff", 1, "c"], "lblPlayerName": [175, 80, 120, 0, 16, "ffffff", 1, "l"]}

const ADD = {"title": [125, 23], "title_black": [115, 23], "word": [60, 86], "btnCancel": [319, 15, 24, 24], "txtPlayerName": [74, 121, 210, 35], "btnConfirm": [119, 206, 120, 35]}

const OPTION = {"lblCharName": [10, 5, 0, 0, 12, "f16422", 0, "l"], "lblTeamName": [10, 50, 156, 0, 12, "086da5", 0, "l"], "lblCorpsName": [10, 30, 156, 0, 12, "086da5", 0, "l"], "vbox": [2, 76, 170, 208], "watch": [114, 259], "watch_master": [114, 285], "cutline": [8, 75]}

const ASK = {"btnCancel": [240, 133, 100, 33], "btnConfirm": [120, 133, 100, 33], "txtContent": [102, 38, 270, 90, 14, "ffffff", 1, "l"]}
