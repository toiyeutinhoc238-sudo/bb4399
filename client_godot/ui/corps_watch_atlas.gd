extends RefCounted

const FILE: String = "res://assets/ui/hall/corps_watch.png"

const R: Dictionary = {
	"cw_corps": [2, 2, 418, 384], 
	"cw_line": [842, 2, 160, 2], 
	"cw_team": [422, 2, 418, 384], 
}

const BOX = [458, 508]

const BODY = {"corps": [20, 54, "cw_corps"], "team": [20, 54, "cw_team"]}

const AT = {"close": [419, 15, 24, 24], "tip": [203, 147, 16, 16]}

const TEXTS_CORPS = {"lblClanName": [144, 19, 170, 0, 17, "ffffff", 1, "c"], "txtCorpsLevel": [302, 139, 94, 32, 13, "ffffff", 1, "c"], "txtClanName": [132, 71, 264, 32, 13, "ffffff", 1, "l"], "txtClanLeader": [132, 105, 264, 32, 13, "ffffff", 1, "l"], "txtNowNumber": [130, 139, 94, 32, 13, "ffffff", 1, "c"]}

const TEXTS_TEAM = {"lblClanName": [144, 19, 170, 0, 17, "ffffff", 1, "c"], "txtClanName": [132, 71, 264, 32, 13, "ffffff", 1, "l"], "txtClanLeader": [132, 105, 264, 32, 13, "ffffff", 1, "l"], "lblLevel": [132, 138, 94, 32, 13, "ffffff", 1, "c"], "lblTeamFund": [132, 171, 94, 32, 13, "ffffff", 1, "c"], "lblTeamCoutribute": [301, 171, 94, 32, 13, "ffffff", 1, "c"], "lblHonor": [301, 138, 94, 32, 13, "ffffff", 1, "c"]}

const LIST = {"corps": [64, 197, 332, 182], "team": [64, 266, 332, 121]}

const LEGION = {"lblTeamName": [1, 15, 120, 0, 13, "ffffff", 1, "l"], "lblPlayerName": [104, 15, 120, 0, 13, "ffffff", 1, "l"], "lblRank": [212, 16, 50, 0, 12, "ffffff", 1, "c"], "lblMumberCount": [262, 15, 50, 0, 13, "ffffff", 1, "l"]}

const MENU = [180, 155]

const LINE = [8, 35]

const MENU_TEXTS = {"lblCharName": [10, 5, 0, 0, 16, "f16422", 0, "l"], "btnAddFriend": [10, 40, 0, 0, 14, "086da5", 1, "l"], "btnPrivateChat": [10, 65, 0, 0, 14, "086da5", 1, "l"], "btnCopyName": [10, 90, 0, 0, 14, "086da5", 1, "l"]}

const WORDS = {"friend": "Thêm bạn bè", "chat": "Chat riêng", "copy": "Copy tên gọi"}
