extends RefCounted

const FILE: String = "res://assets/ui/hall/pvpresult.png"

const R: Dictionary = {
	"pr_back": [896, 2014, 116, 47], 
	"pr_backtip": [74, 2103, 108, 33], 
	"pr_bar": [184, 2103, 416, 30], 
	"pr_bg": [2, 804, 973, 614], 
	"pr_board": [2, 1420, 494, 383], 
	"pr_brief": [498, 1420, 450, 308], 
	"pr_buy": [602, 2103, 78, 30], 
	"pr_buy_off": [682, 2103, 78, 30], 
	"pr_chat": [451, 1805, 462, 200], 
	"pr_cut": [2, 2256, 490, 2], 
	"pr_exit": [2, 2103, 70, 47], 
	"pr_fill_act": [2, 2152, 416, 24], 
	"pr_fill_avatar": [420, 2152, 416, 24], 
	"pr_fill_base": [2, 2178, 416, 24], 
	"pr_fill_daily": [420, 2178, 416, 24], 
	"pr_fill_double": [2, 2204, 416, 24], 
	"pr_fill_gray": [420, 2204, 416, 24], 
	"pr_fill_vip": [2, 2230, 416, 24], 
	"pr_friend": [420, 2230, 22, 22], 
	"pr_gold": [540, 2230, 67, 19], 
	"pr_honor_assist": [190, 2014, 67, 70], 
	"pr_honor_kda": [259, 2014, 67, 70], 
	"pr_honor_killer": [328, 2014, 67, 70], 
	"pr_oppose": [762, 2103, 78, 30], 
	"pr_q_blue": [397, 2014, 67, 67], 
	"pr_q_green": [466, 2014, 67, 67], 
	"pr_q_orange": [535, 2014, 67, 67], 
	"pr_q_purple": [604, 2014, 67, 67], 
	"pr_q_white": [673, 2014, 67, 67], 
	"pr_sign_act": [742, 2014, 50, 52], 
	"pr_sign_daily": [846, 2014, 48, 49], 
	"pr_sign_vip": [794, 2014, 50, 52], 
	"pr_slot": [2, 2014, 92, 87], 
	"pr_slot_lose": [96, 2014, 92, 87], 
	"pr_t_assist": [444, 2230, 22, 22], 
	"pr_t_destroy": [468, 2230, 22, 22], 
	"pr_t_kda": [492, 2230, 22, 22], 
	"pr_t_kill": [516, 2230, 22, 22], 
	"pr_tank": [2, 1805, 447, 207], 
	"pr_win": [915, 1805, 101, 102], 
	"pr_xp": [2, 2, 335, 800], 
}

const SIZE = [977, 618]

const PANELS = {"bg": [2, 2], "board": [14, 22], "chat": [36, 407], "brief": [513, 11], "tank": [514, 335]}

const NODES = {"btnClear": [45, 460, 20, 20], "btnPageUp": [45, 484, 20, 20], "btnPagDown": [45, 508, 20, 20], "btnPageButtom": [45, 532, 20, 20], "btnNow": [66, 408, 69, 25], "btnRoom": [137, 408, 69, 25], "btnClan": [208, 408, 69, 25], "btnCorps": [279, 408, 69, 25], "btnPrivate": [350, 408, 69, 25], "btnChannel": [48, 573.5, 91, 25], "cvsInputArea": [156, 574, 275, 26], "btnSendChat": [379, 580, 25, 16], "btnFriend": [413, 570, 36, 31], "btnQuick": [449, 570, 36, 31], "txtChatPanel": [65, 436, 400, 120], "vsbChatPanel": [463, 436, 16, 120], "cvsPrivateChatNum": [414, 407, 25, 25], "imgWinSelf": [169, 42, 101, 102], "imgWinEnemy": [169, 219, 101, 102], "frmResult": [506, 11, 460, 324], "cvsResultTank": [507, 330, 460, 216], "btnBack": [715, 562, 116, 47], "cvsBackTip": [719, 533, 108, 33], "btnExit": [585, 563, 70, 47], "btnBuy": [755, 481, 78, 30], "btnOppose": [854, 481, 78, 30], "viewTank": [538, 344, 200, 200], "lblTankName": [538, 360, 200, 42], "lblCharName": [760, 425, 192, 34]}

const BRIEF = {"frmExpTitle": [509, 18, 456, 48], "frmCurrentLevel": [509, 26, 80, 40], "frmNextLevel": [901, 26, 80, 40], "frmCoinProgress": [535, 212, 416, 30], "frmExpPercent": [535, 266, 416, 30], "cvsItem": [518, 100, 438, 82]}

const GOLD = [544, 191.5, 67, 19]

const EXP_BAR = [61, 27, 335, 8]

const NEED_EXP = [150, 350, 550, 800, 1000, 1250, 1600, 2000, 2500, 3300, 4500, 5800, 6800, 8300, 10000, 13000, 15000, 19000, 22000, 27000, 42000, 50000, 60000, 73000, 87000, 156000, 191000, 227000, 270000, 330000, 363000, 399300, 439200, 483200, 531500, 956700, 1148000, 1377600, 1653200, 1983800, 1983800]

const VIP_ADD_EXP = 55

const TEXTS = {"label1": [66, 409, 70, 24, 12, "ffffff", 1, "c"], "label4": [137, 409, 70, 24, 12, "ffffff", 1, "c"], "label2": [208, 409, 70, 24, 12, "ffffff", 1, "c"], "label0": [279, 409, 70, 24, 12, "ffffff", 1, "c"], "label3": [350, 409, 70, 24, 12, "ffffff", 1, "c"], "lblChannelName": [68, 577, 52, 19, 12, "ffffff", 1, "c"], "txtInput": [156, 587, 210, 0, 12, "ffffff", 0, "l"], "lblNum": [414, 419.5, 25, 0, 11, "ffffff", 1, "c"], "lblPlayerBackNum": [723, 538, 100, 0, 14, "ffffff", 1, "c"], "lblExpRate": [651, 27, 48, 0, 12, "ffffff", 1, "r"], "lblAtk0": [694, 27, 16, 0, 12, "c9e869", 1, "r"], "lblCurrentExp": [707, 28, 49, 0, 12, "ffffff", 1, "r"], "lblNextExp": [763, 28, 49, 0, 12, "ffffff", 1, "l"], "lblAtk2": [748, 27, 16, 0, 12, "c9e869", 1, "r"], "lblCoin": [849, 204, 100, 0, 16, "008dd2", 1, "r"], "lblExp": [849, 258, 100, 0, 16, "008dd2", 1, "r"], "lblExpFullTip": [643, 276, 260, 0, 12, "008dd2", 1, "l"], "lblMerit": [849, 312, 100, 0, 16, "008dd2", 1, "r"], "lblCharExpFullTip": [643, 276, 260, 0, 12, "008dd2", 1, "l"], "lblTankName": [538, 360, 200, 42, 20, "0b333c", 1, "l"], "lblCharName": [760, 425, 192, 34, 20, "fbfefe", 1, "c"]}

const BAR_TEXTS = {"lblBase": [27, 4, 0, 0, 14, "006520", 1, "c"], "lblAct": [110, 4, 0, 0, 14, "00669b", 1, "c"], "lblDouble": [173, 4, 0, 0, 14, "005dac", 1, "c"], "lblAvatar": [233, 4, 0, 0, 14, "a80082", 1, "c"], "lblOrnament": [233, 4, 0, 0, 14, "a80082", 1, "c"], "lblDaily": [303, 4, 0, 0, 14, "a82f00", 1, "c"], "lblVip": [361, 4, 0, 0, 14, "a80000", 1, "c"]}

const ROW = {"avatar": [6, 2, 0, 0], "cvsLevel": [43, 7, 25, 25], "imgKiller": [166, 7, 22, 22], "imgAss": [188, 7, 22, 22], "imgKda": [210, 7, 22, 22], "imgDestoryer": [232, 7, 22, 22], "btnAddFriend": [253, 9, 22, 22], "btnReport": [278, 9, 22, 22], "icons": [166, 7, 88, 22]}

const ROW_TEXTS = {"lblPlayerName": [76, 8, 100, 0, 13, "fff600", 1, "l"], "lblBattleData": [293, 8, 116, 0, 13, "fff600", 1, "c"], "lblVirtue": [408, 5, 80, 0, 18, "fff600", 1, "c"], "lblEloChange": [460, 0, 30, 0, 12, "44ff00", 1, "r"]}

const HONOR = [67, 70]

const SLOT = {"size": [92, 87], "step": 82, "min": 5, "quality": [13, 8], "item": [14, 8, 64, 64], "count": [77, 51], "sign": [8, 2]}

const QUALITY = ["white", "green", "blue", "purple", "orange"]

const SIGNS = {"act": "pr_sign_act", "daily": "pr_sign_daily", "vip": "pr_sign_vip"}

const LISTS = {"self": [16, 42, 490, 178], "other": [16, 221, 490, 178]}
