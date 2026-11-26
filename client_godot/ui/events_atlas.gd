extends RefCounted

const FILE: String = "res://assets/ui/hall/events.png"

const R: Dictionary = {
	"ev_aw_bg": [698, 1004, 84, 84], 
	"ev_aw_exp": [2, 1353, 50, 50], 
	"ev_aw_gift": [673, 1277, 58, 58], 
	"ev_aw_money": [54, 1353, 50, 50], 
	"ev_aw_thew": [784, 1004, 76, 76], 
	"ev_become": [627, 1353, 91, 34], 
	"ev_btn_done": [370, 1277, 99, 61], 
	"ev_btn_sign": [471, 1277, 99, 61], 
	"ev_btn_vip": [572, 1277, 99, 61], 
	"ev_chest": [230, 1277, 68, 68], 
	"ev_chest_sel": [300, 1277, 68, 68], 
	"ev_close": [180, 1405, 24, 24], 
	"ev_detail": [529, 1353, 96, 38], 
	"ev_got12": [106, 1353, 50, 50], 
	"ev_got21": [158, 1353, 50, 50], 
	"ev_got5": [210, 1353, 50, 50], 
	"ev_halo_btn": [573, 1004, 123, 85], 
	"ev_halo_chest": [483, 1004, 88, 88], 
	"ev_iq2": [262, 1353, 46, 46], 
	"ev_iq3": [310, 1353, 46, 46], 
	"ev_iq4": [358, 1353, 46, 46], 
	"ev_iq5": [406, 1353, 46, 46], 
	"ev_pass": [733, 1277, 69, 51], 
	"ev_progress": [206, 1405, 303, 10], 
	"ev_q1": [862, 1004, 74, 74], 
	"ev_q2": [938, 1004, 74, 74], 
	"ev_q3": [2, 1277, 74, 74], 
	"ev_q4": [78, 1277, 74, 74], 
	"ev_q5": [154, 1277, 74, 74], 
	"ev_rb_buy": [720, 1353, 140, 33], 
	"ev_rb_get": [862, 1353, 140, 33], 
	"ev_rb_got": [2, 1405, 140, 33], 
	"ev_rb_pay": [454, 1353, 73, 43], 
	"ev_rebate": [2, 594, 671, 408], 
	"ev_rule": [2, 1004, 479, 271], 
	"ev_sign": [2, 2, 669, 590], 
	"ev_signed": [144, 1405, 34, 33], 
	"ev_today": [804, 1277, 69, 51], 
	"ev_weekend": [875, 1277, 67, 51], 
	"ev_weekend_grey": [944, 1277, 67, 51], 
}

const PANELS = {"sign": [19, 8], "rule": [19, 7], "rebate": [19, 8]}

const SIGN = {"btnClose": [652, 33, 24, 24], "btnBecomeVip": [549, 483, 91, 34], "btnSignin": [545, 519, 99, 61], "imgSignInProgress": [124, 545, 303, 10], "btnSigninDetail": [454, 71, 96, 38], "frmCount5Day": [159, 517, 68, 68], "frmCount12Day": [292, 517, 68, 68], "frmCount21Day": [423, 517, 68, 68], "lblSigninTitle": [255, 71, 0, 0, 24, "0b333c", 1, "l"], "lblSignInDays": [104, 540, 0, 0, 12, "ffffff", 1, "c"], "swf": [593, 550], "rule": [95, 160], "day_x": [54, 124, 195, 266, 337, 408, 478], "day_y": [157, 210, 263, 316, 369, 422], "vip_items": [566, 120, 60]}

const RULE = {"btnClose": [462, 33, 24, 24]}

const REBATE = {"btnClose": [654, 33, 24, 24], "btnGetAward": [260, 367, 140, 33], "btnBuy": [260, 368, 140, 33], "frmAwardItem0": [243, 135, 91, 110], "frmAwardItem1": [356, 135, 91, 110], "btnContinuePay": [571, 308, 73, 43], "_RebateFrame_Label1": [221, 217, 0, 0, 14, "ffff00", 1, "l"], "_RebateFrame_Text1": [241, 241, 400, 0, 12, "ffffff", 1, "l"], "lblCanGetCount": [242, 311, 0, 0, 26, "fdff60", 1, "l"], "lblLeftDay": [523, 311, 0, 0, 26, "fdff60", 1, "l"]}

const AWARD = {"bg": [3.5, 0], "quality": [9, 5], "item": [7.5, 4], "coin": [20.5, 7], "gift": [16.5, 3], "thew": [7.5, 4.0], "lblRewardName": [12.5, 78, 66, 0, 12, "ffffff", 1, "c"], "lblNum": [0.5, 82, 90, 0, 13, "ffffff", 1, "c"]}
