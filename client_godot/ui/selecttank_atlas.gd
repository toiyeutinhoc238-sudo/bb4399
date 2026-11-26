extends RefCounted

const FILE: String = "res://assets/ui/hall/selecttank.png"

const R: Dictionary = {
	"st_arrow_enemy": [455, 1413, 52, 27], 
	"st_arrow_team": [509, 1413, 52, 27], 
	"st_attr": [2, 1259, 389, 83], 
	"st_bg": [2, 2, 1016, 617], 
	"st_chat_bg": [393, 1259, 557, 79], 
	"st_confirm": [187, 1344, 136, 58], 
	"st_confirm_done": [325, 1344, 136, 58], 
	"st_edit_talent": [617, 1413, 35, 24], 
	"st_f_all": [634, 1344, 93, 31], 
	"st_f_all_on": [729, 1344, 93, 31], 
	"st_f_assist": [824, 1344, 93, 31], 
	"st_f_assist_on": [919, 1344, 93, 31], 
	"st_f_attack": [2, 1413, 93, 31], 
	"st_f_attack_on": [97, 1413, 93, 31], 
	"st_f_panzer": [192, 1413, 93, 31], 
	"st_f_panzer_on": [287, 1413, 93, 31], 
	"st_fill": [563, 1344, 38, 39], 
	"st_free": [523, 1344, 38, 41], 
	"st_grid_blue": [219, 621, 178, 98], 
	"st_grid_cover": [296, 1161, 175, 95], 
	"st_grid_empty": [399, 621, 178, 98], 
	"st_grid_frame": [473, 1161, 169, 92], 
	"st_grid_self": [579, 621, 178, 98], 
	"st_grid_unknow": [759, 621, 178, 98], 
	"st_info_bg": [2, 621, 215, 538], 
	"st_lock": [603, 1344, 29, 38], 
	"st_map_cover": [644, 1161, 168, 84], 
	"st_rent": [563, 1413, 52, 27], 
	"st_send": [382, 1413, 71, 29], 
	"st_skill_grid": [463, 1344, 58, 57], 
	"st_switch": [654, 1413, 49, 21], 
	"st_tile": [2, 1161, 96, 96], 
	"st_tile_frame": [100, 1161, 96, 96], 
	"st_tile_on": [198, 1161, 96, 96], 
	"st_x_bg": [2, 1344, 183, 67], 
	"st_x_crystal": [705, 1413, 28, 16], 
	"st_x_talent": [735, 1413, 28, 16], 
}

const SIZE = [1000, 600]

const AT = {"imgTeammateArrow": [213, 24, 52, 27], "imgEnemyArrow": [737, 24, 52, 27], "frmSelf1": [2, 36, 178, 98], "frmSelf2": [2, 134, 178, 98], "frmSelf3": [2, 232, 178, 98], "frmSelf4": [2, 330, 178, 98], "frmSelf5": [2, 428, 178, 98], "frmEnemy1": [820, 36, 178, 98], "frmEnemy2": [820, 134, 178, 98], "frmEnemy3": [820, 232, 178, 98], "frmEnemy4": [820, 330, 178, 98], "frmEnemy5": [820, 428, 178, 98], "btnAll": [234, 59, 93, 31], "btnAttack": [327, 59, 93, 31], "btnPanzer": [420, 59, 93, 31], "btnAssist": [513, 59, 93, 31], "imgMap": [230, 438, 152, 68], "gridCorpsSkill": [404, 435, 50, 50], "imgCorpsSkillLocked": [414, 440, 29, 38], "btnSwitchSkill": [405, 485, 49, 21], "btnConfirm": [641, 442, 136, 58], "swfConfirmEffect": [711, 473, 0, 0], "cvsExtraFunc": [457, 437, 183, 67], "imgCrystalTitle": [464, 449, 28, 16], "imgTalentTitle": [464, 476, 28, 16], "cbTalent": [493, 474, 108, 20], "cbCrystal": [493, 447, 108, 20], "btnEditTalent": [602, 471, 35, 24], "cvsChat": [223, 513, 557, 79], "txtChatArea": [231.5, 525, 540, 25], "txtInput": [234.5, 573.5, 460, 0], "btnSendChat": [701, 558, 71, 29], "cvsTankInfo": [780, 34, 220, 540], "skillGift": [801, 206, 50, 50], "skillNormal": [801, 339, 50, 50], "skillEx": [801, 472, 50, 50], "bg": [-8, -8], "attr": [392, 428], "map_cover": [222, 430], "chat_bg": [223, 513], "x_bg": [457, 437], "info_bg": [782.5, 35.0], "skill_grids": [[796.0, 202.5], [796.0, 334.5], [796.0, 467.5]]}

const GRID_AT = {"imgSkinFrame": [2, 3, 169, 92], "imgUnknow": [56, 6, 67, 67], "imgSkinFrameRed": [6, 3, 169, 92], "cover": [0, 0, 175, 95]}

const TILE_AT = {"imgFreeMark": [1, 1, 38, 41], "imgFillTank": [1, 1, 38, 39], "imgTankLv": [48, 2, 0, 0], "btnRent": [40, 65, 52, 27]}

const TEXT = {"_SelectTankFrameNew_Label1": [0, 1, 204, 0, 16, "ffffff", 1, "c"], "_SelectTankFrameNew_Label2": [796, 1, 204, 0, 16, "ffffff", 1, "c"], "lblSelfCountdown": [257, 23, 142, 0, 20, "ffe92e", 1, "c"], "lblEnemyCountdown": [604, 22, 142, 0, 20, "ffe92e", 1, "c"], "lblMidTips": [500, 20, 0, 0, 24, "ffff00", 1, "c"], "txtChatArea": [231.5, 525, 540, 25, 12, "0b333c", 0, "l"], "txtInput": [234.5, 573.5, 460, 0, 12, "ffffff", 0, "l"], "lblLackTankClassification1": [228, 404, 305, 27, 16, "ffea76", 1, "r"], "lblLackTankClassification2": [536, 404, 245, 27, 16, "ffa8a8", 0, "l"], "lblTankName": [780, 63, 220, 0, 23, "0b333c", 1, "c"], "txtTankIntro": [805.5, 91.5, 169, 73, 18, "ffdd1f", 1, "l"], "lblSkillGiftName": [780, 183, 220, 0, 16, "ffffff", 1, "c"], "lblSkillNormalName": [780, 315, 220, 0, 16, "ffffff", 1, "c"], "lblSkillExName": [780, 447, 220, 0, 16, "ffffff", 1, "c"], "txtSkillGiftIntro": [853, 189, 140, 110, 13, "a6d6ff", 1, "l"], "txtSkillExIntro": [852, 456, 140, 110, 13, "a6d6ff", 1, "l"], "txtSkillNormalIntro": [855, 323, 140, 110, 13, "a6d6ff", 1, "l"], "lblWeekFreeTips": [788.5, 144, 203, 0, 16, "ffffff", 1, "c"], "lblPlayerName": [89, 74, 0, 0, 13, "ffffff", 1, "l"], "lblUseCount": [2, 72, 40, 22, 14, "ffffff", 1, "c"], "lblRareTip": [-2, 72, 100, 22, 14, "ff0000", 1, "c"]}

const LIST = [238, 104, 526, 296]

const COLS = 5

const TITLE_SELF = "Ta"

const TITLE_ENEMY = "Địch"

const MID_TIPS = "Chọn tank xuất chiến"

const NO_TALENT = "Không có Kỹ Thuật"

const NO_CRYSTAL = "Không có Tinh Thể"

const TIP_3 = "Chọn tank xuất chiến"

const TIP_10 = "Bắt Đầu"

const TIP_666 = "Nhắc nhở: Thiếu trận hình"

const CLASSES = ["DPS", "Chống chịu", "Phụ trợ"]

const PHYS = ["Tank Vật Lý", "Tank Năng Lượng"]
