extends RefCounted

const FILE: String = "res://assets/ui/hall/guild_recruit.png"

const R: Dictionary = {
	"rc_agree": [456, 1062, 58, 26], 
	"rc_cut": [2, 1097, 445, 2], 
	"rc_disagree": [516, 1062, 58, 26], 
	"rc_edit": [202, 1062, 76, 31], 
	"rc_edit_dec": [104, 1062, 96, 31], 
	"rc_help": [600, 1062, 16, 16], 
	"rc_invite": [2, 1062, 100, 33], 
	"rc_mng": [2, 2, 520, 528], 
	"rc_ok": [280, 1062, 76, 31], 
	"rc_reject_all": [358, 1062, 96, 28], 
	"rc_set": [2, 532, 520, 528], 
	"rc_tab_mng_off": [748, 532, 100, 36], 
	"rc_tab_mng_on": [850, 532, 100, 36], 
	"rc_tab_set_off": [524, 532, 110, 36], 
	"rc_tab_set_on": [636, 532, 110, 36], 
	"rc_watch": [576, 1062, 22, 22], 
}

const FRAME = [520, 528]

const AT = {"btnClose": [481, 14, 24, 24], "btnApplyManage": [31, 60, 100, 36], "btnRecruit": [134, 60, 110, 36], "btnInvite": [225, 475, 100, 33], "btnRejectAll": [395, 427, 96, 28], "frmSetting": [29, 99, 472, 359], "lstApply": [33, 150, 463, 270]}

const HEADS = [[254, 124], [323, 124]]

const FORM = {"cbAutoIn": [325, 201, 0, 0], "cbBanApply": [325, 241, 0, 0], "cbMemberAuthority": [325, 281, 0, 0], "btnEditDec": [375, 300, 96, 31], "btnConfirmDec": [396, 300, 76, 31], "btnConfirmLevel": [395, 117, 76, 31], "btnEditLevel": [395, 117, 76, 31], "txtLevelLimit": [166, 118, 194, 27], "cbbLadder": [159, 159, 310, 26], "txtDec": [59, 351, 408, 92], "imgHelp": [191, 284, 16, 16]}

const ROW = {"btnApprove": [327, 3, 58, 26], "btnReject": [390, 3, 58, 26], "btnWatch": [163, 5, 22, 22], "cut": [0, 30, 445, 2], "level": [21, 6, 40, 20]}

const ROW_TEXT = {"lblName": [71, 16, 90, 0, 12, "ffffff", 1, "c"], "lblLadder": [192, 7, 60, 0, 12, "ffffff", 1, "c"], "lblReferee": [260, 7, 60, 0, 12, "ffffff", 1, "c"]}
