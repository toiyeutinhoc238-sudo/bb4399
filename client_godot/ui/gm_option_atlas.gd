extends RefCounted

const FILE: String = "res://assets/ui/hall/gm_option.png"

const R: Dictionary = {
	"gmo_1day": [396, 2, 94, 36], 
	"gmo_1week": [492, 2, 94, 36], 
	"gmo_3day": [588, 2, 94, 36], 
	"gmo_close": [684, 2, 23, 23], 
	"gmo_frame": [2, 2, 392, 307], 
}

const FRAME = [392, 300]

const BODY = [0, -7]

const AT = {"btnBanAccount1": [44, 107, 94, 36], "btnBanAccount2": [149, 107, 94, 36], "btnBanAccount3": [254, 107, 94, 36], "btnBanChat1": [44, 217, 94, 36], "btnBanChat2": [149, 217, 94, 36], "btnBanChat3": [254, 217, 94, 36], "btnClose": [369, 10, 23, 23]}

const DAYS = [1, 3, 7]

const FACE = ["gmo_1day", "gmo_3day", "gmo_1week"]

const WORDS = {"ask_chat": "Xác nhận muốn người chơi [@name@] cấm nói @time@ ngày?", "ask_account": "Muốn khóa acc [@name@] @time@ ngày>", "menu": "Thao tác GM"}
