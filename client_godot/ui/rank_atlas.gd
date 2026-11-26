extends RefCounted

const FILE: String = "res://assets/ui/hall/rank.png"

const R: Dictionary = {
	"rk_b_bk": [184, 1146, 129, 114], 
	"rk_b_lbk": [315, 1146, 115, 102], 
	"rk_card_off": [826, 597, 180, 197], 
	"rk_card_on": [2, 1146, 180, 197], 
	"rk_close": [978, 1345, 23, 23], 
	"rk_frame": [2, 2, 1000, 593], 
	"rk_i_atk_off": [528, 1146, 74, 80], 
	"rk_i_atk_on": [604, 1146, 74, 80], 
	"rk_i_common_cool_off": [764, 1146, 47, 54], 
	"rk_i_common_cool_on": [813, 1146, 47, 54], 
	"rk_i_ctsis_arm_off": [862, 1146, 47, 54], 
	"rk_i_ctsis_arm_on": [911, 1146, 47, 54], 
	"rk_i_eng_arm_off": [960, 1146, 47, 54], 
	"rk_i_eng_arm_on": [2, 1345, 47, 54], 
	"rk_i_hpmax_off": [51, 1345, 47, 54], 
	"rk_i_hpmax_on": [100, 1345, 47, 54], 
	"rk_i_phy_arm_off": [149, 1345, 47, 54], 
	"rk_i_phy_arm_on": [198, 1345, 47, 54], 
	"rk_list_frame": [2, 597, 822, 547], 
	"rk_m_bk": [432, 1146, 94, 83], 
	"rk_m_lbk": [680, 1146, 82, 73], 
	"rk_pg1": [2, 1401, 24, 22], 
	"rk_pg1_on": [28, 1401, 24, 22], 
	"rk_pg2": [54, 1401, 24, 22], 
	"rk_pg2_on": [80, 1401, 24, 22], 
	"rk_pg3": [106, 1401, 24, 22], 
	"rk_pg3_on": [132, 1401, 24, 22], 
	"rk_pg4": [158, 1401, 24, 22], 
	"rk_pg4_on": [184, 1401, 24, 22], 
	"rk_pg5": [210, 1401, 24, 22], 
	"rk_pg5_on": [236, 1401, 24, 22], 
	"rk_pg6": [262, 1401, 24, 22], 
	"rk_pg6_on": [288, 1401, 24, 22], 
	"rk_pg7": [314, 1401, 24, 22], 
	"rk_pg7_on": [340, 1401, 24, 22], 
	"rk_pg8": [366, 1401, 24, 22], 
	"rk_pg8_on": [392, 1401, 24, 22], 
	"rk_pg_next": [368, 1345, 25, 26], 
	"rk_pg_prev": [395, 1345, 25, 26], 
	"rk_pr": [422, 1345, 276, 23], 
	"rk_pr_bk": [700, 1345, 276, 23], 
	"rk_preview": [247, 1345, 90, 32], 
	"rk_star": [339, 1345, 27, 26], 
}

const FRAME = [0, -17]

const LIST_FRAME = [0, -17]

const MAIN = {"imgRankNow": [73, 43, 0, 0], "imgRankNext": [499, 43, 0, 0], "mcProgress": [188, 84, 276, 23], "btnPreview": [281, 123, 90, 32], "imgNextSpec": [674, 418, 0, 0], "frmAttrPhyArm": [29, 217, 94, 83], "frmAttrEnyArm": [109, 361, 94, 83], "frmAttrCtsisArm": [269, 266, 94, 83], "frmAttrHpMax": [348, 408, 94, 83], "frmAttrAtk": [503, 297, 94, 83], "frmAttrCommonCool": [876, 409, 94, 83], "imgNextActiveStar": [533, 528, 0, 0]}

const TEXT = {"_MilitaryRankFrame_CGradientLabel1": [188, 62, 200, 0, 16, "7dfdff", 1, "l"], "_MilitaryRankFrame_CGradientLabel2": [267, 62, 200, 0, 16, "7dfdff", 1, "r"], "lblMRNow": [53, 134, 120, 0, 16, "fff959", 1, "c"], "lblMRNext": [479, 134, 120, 0, 16, "fff959", 1, "c"], "lblTips": [226, 95.5, 200, 0, 16, "ffffff", 0, "c"], "lblNextActiveDesc": [250, 528, 282, 0, 16, "ffffff", 1, "r"], "lblActiveCondition": [561, 528, 80, 0, 16, "fff959", 1, "l"], "_MilitaryRankFrame_CGradientLabel3": [722, 63, 200, 0, 16, "7dfdff", 1, "c"], "_MilitaryRankFrame_Label5": [646, 94, 175, 0, 18, "ffffff", 1, "r"], "_MilitaryRankFrame_Label6": [646, 129, 175, 0, 18, "ffffff", 1, "r"], "_MilitaryRankFrame_Label7": [646, 164, 175, 0, 18, "ffffff", 1, "r"], "_MilitaryRankFrame_Label8": [646, 199, 175, 0, 18, "ffffff", 1, "r"], "_MilitaryRankFrame_Label9": [646, 234, 175, 0, 18, "ffffff", 1, "r"], "_MilitaryRankFrame_Label10": [646, 269, 175, 0, 18, "ffffff", 1, "r"], "lblAttrPhyArm": [6, 304, 140, 0, 14, "ffffff", 1, "c"], "lblAttrEnyArm": [86, 443, 140, 0, 14, "ffffff", 1, "c"], "lblAttrCtsisArm": [246, 348, 140, 0, 14, "ffffff", 1, "c"], "lblAttrHpMax": [325, 490, 140, 0, 14, "ffffff", 1, "c"], "lblAttrAtk": [498, 410, 140, 0, 14, "ffffff", 1, "c"], "lblAttrCommonCool": [853, 491, 140, 0, 14, "ffffff", 1, "c"], "_MilitaryRankFrame_CGradientLabel4": [767, 418, 110, 0, 16, "fca738", 1, "c"], "lblPhyArm": [840, 94, 150, 0, 18, "fff959", 1, "l"], "lblEnyArm": [840, 129, 150, 0, 18, "fff959", 1, "l"], "lblCtsisArm": [840, 164, 150, 0, 18, "fff959", 1, "l"], "lblMaxHp": [840, 199, 150, 0, 18, "fff959", 1, "l"], "lblAtk": [840, 234, 150, 0, 18, "fff959", 1, "l"], "lblCommonCool": [840, 269, 150, 0, 18, "fff959", 1, "l"], "lblProduce": [665, 305, 305, 69, 14, "ffffff", 1, "l"], "lblActiveTips": [651, 513, 320, 0, 14, "ffffff", 1, "c"]}

const CLOSE = {"main": [977, 0], "list": [799, 0]}

const LIST = {"numPage": [81, 491, 660, 26], "frmRank1": [39, 53, 180, 197], "frmRank2": [227, 53, 180, 197], "frmRank3": [415, 53, 180, 197], "frmRank4": [603, 53, 180, 197], "frmRank5": [39, 266, 180, 197], "frmRank6": [227, 266, 180, 197], "frmRank7": [415, 266, 180, 197], "frmRank8": [603, 266, 180, 197]}

const CARD = {"lblRankName": [20, 197, 140, 0, 16, "ffffff", 1, "c"], "lblRankCondition": [0, 90.5, 180, 0, 14, "fff000", 1, "c"]}
