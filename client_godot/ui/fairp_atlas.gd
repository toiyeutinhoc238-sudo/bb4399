extends RefCounted

const FILE: String = "res://assets/ui/hall/fairp.png"

const R: Dictionary = {
	"fa_ac_frame": [2, 528, 791, 507], 
	"fa_ac_item": [2, 1293, 182, 76], 
	"fa_ac_item_on": [186, 1293, 182, 76], 
	"fa_code": [336, 1371, 100, 33], 
	"fa_get": [438, 1371, 100, 33], 
	"fa_get_off": [540, 1371, 100, 33], 
	"fa_go": [642, 1371, 100, 33], 
	"fa_go_off": [744, 1371, 100, 33], 
	"fa_got": [846, 1371, 100, 33], 
	"fa_iv_frame": [2, 1037, 354, 254], 
	"fa_iv_input": [2, 1371, 210, 35], 
	"fa_iv_ok": [214, 1371, 120, 35], 
	"fa_pz_frame": [2, 2, 579, 524], 
	"fa_pz_last": [948, 1371, 33, 29], 
	"fa_pz_next": [983, 1371, 33, 29], 
	"fa_pz_none": [370, 1293, 499, 75], 
	"fa_pz_row": [358, 1037, 532, 116], 
	"fa_sign_on": [871, 1293, 48, 50], 
	"fa_sign_over": [921, 1293, 48, 50], 
	"fa_sign_wait": [971, 1293, 48, 50], 
	"fa_x": [2, 1408, 24, 24], 
}

const PRIZE = {"frame": [19, 0], "rows": [[32.5, 80], [32.5, 210], [32.5, 340]], "btnLastPage": [208, 468, 33, 29], "btnNextPage": [358, 468, 33, 29], "btnClose": [562, 33, 24, 24], "imgNoAward": [50.5, 225.5, 499, 75], "lblPage": [258, 470, 85, 0, 14, "ffffff", 1, "c"]}

const ROW = {"frame": [0, 0], "lblTitle": [48, 8, 262, 0, 14, "ffffff", 1, "l"], "lblEndTime": [408, 8, 120, 0, 12, "ffff00", 1, "l"], "txtDesc": [13, 40, 392, 70, 12, "ffffff", 0, "l"], "button": [417, 57, 100, 33]}

const CODE = {"frame": [2, 2], "txtValidate": [74, 121, 210, 35], "btnCancel": [319, 15, 24, 24], "btnConfirm": [119, 206, 120, 35]}

const CENTER = {"frame": [19, 3], "list": [47, 83, 204, 392, 77], "reward": [313, 217, 76], "btnClose": [774, 33, 24, 24], "btnGoTo": [462, 450, 100, 33], "lblActName": [371, 82, 0, 0, 14, "fff499", 1, "l"], "lblActTime": [371, 132, 358, 0, 14, "ffffff", 1, "l"], "lblStartLevel": [371, 107, 0, 0, 14, "ffffff", 1, "l"], "txtQuestDesc": [313, 185, 380, 0, 13, "ffffff", 1, "l"], "lblTimeCount": [511, 419, 0, 0, 14, "ffff00", 1, "c"]}

const CENTER_ITEM = {"bg": [0, 1], "state": [135, 0], "lblActName": [82, 23, 0, 0, 20, "ffffff", 1, "c"]}
