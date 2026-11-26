extends RefCounted

const FILE: String = "res://assets/ui/hall/skin_get_locked.png"

const R: Dictionary = {
	"sgl_buyskin": [704, 2, 92, 30], 
	"sgl_buytank": [798, 2, 92, 30], 
	"sgl_close": [892, 2, 24, 24], 
	"sgl_frame": [2, 2, 700, 485], 
}

const SIZE = [700, 485]

const NODES = {"btnClose": [662, 33, 24, 24], "btnBuyTank": [304, 430, 92, 30], "btnBuySkin": [304, 430, 92, 30], "avBase": [64, 206, 200, 200], "avNew": [433, 163, 200, 200], "lblLevlDesc": [50.0, 75, 600, 0], "lblSkinAttr": [432, 361, 0, 0], "lblGetTankTip": [150.0, 399, 400, 0]}

const STYLE = {"level": ["ff5b5e", 16, "11459c"], "attr": ["ffffff", 14, "e36805"], "tip": ["ff7878", 16, "751111"], "hot": "fff224", "base_scale": 0.8}

const WORDS = {"CONTROL_TEXT508": "Nhận tank xong mới được mua skin", "CONTROL_TEXT509": "Kích hoạt thuộc tính skin: @text1@", "CONTROL_TEXT510": "Tank tăng đến lv @num1@ ", "TIP_81": "Nhận tank trước mới được dùng skin!"}
