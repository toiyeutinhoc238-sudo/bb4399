extends RefCounted

const FILE: String = "res://assets/ui/hall/mail.png"

const R: Dictionary = {
	"ml_add_friend": [615, 1140, 101, 31], 
	"ml_ask": [625, 574, 369, 199], 
	"ml_ask_guy": [443, 574, 180, 292], 
	"ml_ask_no": [105, 1140, 100, 33], 
	"ml_ask_ok": [207, 1140, 100, 33], 
	"ml_base": [157, 1089, 106, 40], 
	"ml_blue": [309, 1140, 100, 33], 
	"ml_close": [820, 1140, 24, 24], 
	"ml_env_close": [265, 1089, 47, 38], 
	"ml_env_item": [108, 1089, 47, 45], 
	"ml_env_open": [57, 1089, 49, 48], 
	"ml_env_sys_close": [897, 1026, 50, 50], 
	"ml_env_sys_open": [949, 1026, 50, 50], 
	"ml_frame": [2, 2, 854, 570], 
	"ml_from_label": [932, 1140, 45, 17], 
	"ml_hint_icon": [788, 1140, 30, 27], 
	"ml_item_bg": [2, 1089, 53, 49], 
	"ml_next": [718, 1140, 33, 29], 
	"ml_prev": [753, 1140, 33, 29], 
	"ml_reply": [411, 1140, 100, 33], 
	"ml_row": [2, 1026, 403, 61], 
	"ml_row_on": [407, 1026, 403, 61], 
	"ml_row_x": [909, 1140, 21, 20], 
	"ml_sys_tip": [812, 1026, 83, 58], 
	"ml_tab_all_off": [436, 1089, 101, 33], 
	"ml_tab_all_on": [539, 1089, 101, 33], 
	"ml_tab_sent_off": [642, 1089, 101, 33], 
	"ml_tab_sent_on": [745, 1089, 101, 33], 
	"ml_tab_unread_off": [848, 1089, 101, 33], 
	"ml_tab_unread_on": [2, 1140, 101, 33], 
	"ml_write": [513, 1140, 100, 33], 
	"wr_close": [846, 1140, 24, 24], 
	"wr_frame": [2, 574, 439, 450], 
	"wr_friend": [872, 1140, 35, 21], 
	"wr_send": [314, 1089, 120, 35], 
}

const FRAME = [2, 2]

const NODES = {"btnMailList": [37, 50, 101, 33], "btnUnreadMail": [135, 50, 101, 33], "btnSendedMail": [233, 50, 101, 33], "btnMailLast": [165, 458, 33, 29], "btnMailNext": [269, 458, 33, 29], "btnWriteMail": [43, 509, 100, 33], "btnReply": [171, 509, 100, 33], "btnReturn": [303, 509, 100, 33], "txtMailContent": [469, 122, 360, 235], "btnAddFriend": [465, 365, 101, 31], "btnClose": [819, 15, 24, 24], "itemGrid0": [467, 423, 55, 55], "itemGrid1": [533, 423, 55, 55], "itemGrid2": [599, 423, 55, 55], "tankGrid": [665, 423, 55, 55], "imgSysTip": [746, 346, 83, 58], "image1": [725, 436, 30, 27], "mailpalyernameimage": [476, 69, 45, 17], "lstMail": [30, 90, 404, 366], "base_write": [40, 505], "base_reply": [168, 505], "base_return": [300, 505]}

const TEXT = {"lblPageNum": [210, 462, 46, 0, 14, "ffffff", 1, "c"], "lblSenderName": [534, 66, 0, 0, 14, "ffffff", 0, "l"], "lblMailTitle": [534, 90, 0, 0, 14, "ffffff", 0, "l"], "txtMailContent": [469, 122, 360, 235, 14, "8d2d00", 1, "l"], "text1": [755.5, 430, 75.5, 0, 12, "ffffff", 1, "l"], "lblSysTip": [569, 369, 260, 24, 14, "ff0000", 1, "r"]}

const ROW = {"btnBackground": [0, 0, 403, 61], "btnClose": [375, 5, 21, 20], "imgMailIcon": [11.5, 11.5, 47, 38], "lblTitle": [70, 20.5, 300, 0, 16, "8d2d00", 1, "l"], "lblName": [70, 45.5, 0, 0, 13, "8d2d00", 1, "l"], "lblLeftTime": [394, 45.5, 0, 0, 13, "8d2d00", 1, "r"]}

const SENT = {"lblMailTitle": [534, 90, 0, 0, 14, "ffffff", 0, "l"], "txtMailContent": [469, 122, 360, 235, 14, "8d2d00", 1, "l"], "lblReceiverName": [534, 65, 0, 0, 14, "ffffff", 0, "l"]}

const WFRAME = [2, 2]

const WRITE = {"btnFriend": [300, 59, 35, 21], "btnClose": [404, 15, 24, 24], "btnSend": [161.5, 402, 120, 35], "lblReciverName": [101, 58, 181, 0, 14, "ffffff", 0, "l"], "lblEmailTitle": [98, 95, 298, 0, 14, "ffffff", 0, "l"], "txtContent": [36.5, 141, 370, 234, 14, "8d2d00", 0, "l"]}

const PANELS = {"ask": [46, 1]}

const ASK = {"btnCancel": [240, 133, 100, 33], "btnConfirm": [120, 133, 100, 33], "txtContent": [102, 38, 270, 90, 14, "ffffff", 1, "l"]}
