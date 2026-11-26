extends RefCounted

const FILE: String = "res://assets/ui/hall/settings.png"

const R: Dictionary = {
	"settings_ask": [2, 1126, 369, 199], 
	"settings_ask_guy": [2, 832, 180, 292], 
	"settings_ask_no": [573, 1376, 100, 33], 
	"settings_ask_ok": [675, 1376, 100, 33], 
	"settings_cb": [183, 1418, 27, 26], 
	"settings_cb_on": [154, 1418, 27, 27], 
	"settings_close": [807, 1418, 24, 24], 
	"settings_common": [777, 1376, 150, 31], 
	"settings_frame": [2, 2, 726, 510], 
	"settings_intelligent": [2, 1418, 150, 31], 
	"settings_keybox": [475, 514, 400, 307], 
	"settings_ok": [137, 1376, 98, 40], 
	"settings_p_audio": [676, 832, 78, 219], 
	"settings_p_battle": [2, 514, 471, 316], 
	"settings_p_other": [373, 1126, 210, 191], 
	"settings_p_picture": [184, 832, 490, 243], 
	"settings_pwd": [856, 1327, 130, 44], 
	"settings_q_high": [351, 1376, 35, 37], 
	"settings_q_high_on": [388, 1376, 35, 37], 
	"settings_q_low": [425, 1376, 35, 37], 
	"settings_q_low_on": [462, 1376, 35, 37], 
	"settings_q_mid": [499, 1376, 35, 37], 
	"settings_q_mid_on": [536, 1376, 35, 37], 
	"settings_reset": [237, 1376, 112, 38], 
	"settings_rule": [833, 1418, 22, 22], 
	"settings_skill_name": [2, 1451, 89, 18], 
	"settings_tab_off_keys": [300, 1327, 137, 47], 
	"settings_tab_off_other": [439, 1327, 137, 47], 
	"settings_tab_off_sound": [578, 1327, 137, 47], 
	"settings_tab_off_video": [717, 1327, 137, 47], 
	"settings_tab_on_keys": [585, 1126, 147, 47], 
	"settings_tab_on_other": [734, 1126, 147, 47], 
	"settings_tab_on_sound": [2, 1327, 147, 47], 
	"settings_tab_on_video": [151, 1327, 147, 47], 
	"settings_thumb": [760, 1418, 45, 24], 
	"settings_track": [212, 1418, 272, 24], 
	"settings_track_on": [486, 1418, 272, 24], 
	"settings_vote": [2, 1376, 133, 40], 
	"settings_word": [857, 1418, 77, 19], 
}

const PANELS = {"frame": [0, 0], "battle": [184, 79], "picture": [186, 75], "audio": [238, 147], "other": [235, 163], "ask": [46, 1]}

const FRAME = {"tabs": [[30, 119], [30, 174], [30, 229], [30, 284]], "close": [595, 455, 98, 40], "btnClose2": [687, 14, 24, 24], "btnVote": [314, 455, 133, 40], "lblVote": [316, 463, 130, 0, 14, "ffffff", 1, "c"]}

const BATTLE = {"key_box": [[422, 200, 77, 19], [422, 224, 77, 19], [422, 248, 77, 19], [422, 273, 77, 19], [284, 299, 77, 19], [284, 323, 77, 19], [284, 347, 77, 19], [284, 371, 77, 19], [464, 298, 77, 19], [464, 323, 77, 19], [464, 346, 77, 19], [464, 371, 77, 19], [284, 396, 77, 19]], "key_text": [[423, 200, 75, 0, 12, "eff6fd", 1, "c"], [423, 225, 75, 0, 12, "eff6fd", 1, "c"], [423, 248, 75, 0, 12, "eff6fd", 1, "c"], [423, 273, 75, 0, 12, "eff6fd", 1, "c"], [285, 298, 75, 0, 12, "eff6fd", 1, "c"], [285, 322, 75, 0, 12, "eff6fd", 1, "c"], [285, 347, 75, 0, 12, "eff6fd", 1, "c"], [285, 371, 75, 0, 12, "eff6fd", 1, "c"], [465, 297, 75, 0, 12, "eff6fd", 1, "c"], [465, 322, 75, 0, 12, "eff6fd", 1, "c"], [465, 346, 75, 0, 12, "eff6fd", 1, "c"], [465, 371, 75, 0, 12, "eff6fd", 1, "c"], [285, 396, 75, 0, 12, "eff6fd", 1, "c"]], "func_text": [[194, 201, 100, 0, 13, "eff6fd", 1, "l"], [194, 224, 100, 0, 13, "eff6fd", 1, "l"], [194, 249, 100, 0, 13, "eff6fd", 1, "l"], [194, 273, 100, 0, 13, "eff6fd", 1, "l"], [194, 296, 100, 0, 13, "eff6fd", 1, "l"], [194, 321, 100, 0, 13, "eff6fd", 1, "l"], [194, 344, 100, 0, 13, "eff6fd", 1, "l"], [194, 370, 100, 0, 13, "eff6fd", 1, "l"], [374, 296, 100, 0, 13, "eff6fd", 1, "l"], [374, 321, 100, 0, 13, "eff6fd", 1, "l"], [374, 344, 100, 0, 13, "eff6fd", 1, "l"], [374, 370, 100, 0, 13, "eff6fd", 1, "l"], [194, 395, 100, 0, 13, "eff6fd", 1, "l"]], "tip": [597, 335, 75, 0, 13, "eff6fd", 1, "l"], "cb": [[528, 195, 0, 0], [528, 219, 0, 0], [528, 244, 0, 0], [528, 268, 0, 0]], "reset": [583, 73, 112, 38], "common": [312, 125, 150, 31], "intelligent": [460, 125, 150, 31], "rule": [592, 172, 22, 22], "cam": [[374, 395, 100, 464, 396, 77, 22], [374, 420, 100, 464, 421, 77, 22]]}

const PICTURE = {"cimagechecklocal1": [191, 360, 89, 18], "btnReset": [583, 73, 112, 38], "btnLow": [252, 134, 39, 37], "btnMid": [424, 134, 39, 37], "btnHight": [593, 134, 39, 37], "cbNo1": [311, 295, 0, 0], "cbNo3": [311, 233, 0, 0], "cbNo4": [509, 233, 0, 0], "cbNo5": [311, 354, 0, 0], "cbNewtSwitch": [509, 295, 0, 0], "cbFpsSwitch": [509, 350, 0, 0], "_PictureSettings_Label1": [212.2, 179, 0, 0, 12, "eff6fd", 1, "c"], "_PictureSettings_Label2": [560, 179, 0, 0, 12, "eff6fd", 1, "c"]}

const AUDIO = {"cbNo1": [362, 144, 0, 0], "cbNo2": [362, 290, 0, 0], "sliderNo1": [341, 196, 272, 24], "sliderNo2": [341, 335, 272, 24], "btnReset": [583, 73, 112, 38]}

const OTHER = {"cbNo1": [576, 167, 0, 0], "cbNo2": [576, 242, 0, 0], "cbNo3": [576, 318, 0, 0], "btnSetSecondPwd": [555, 64, 130, 44]}

const KEYBOX = {"top": 7, "lblTip": [0, 140, 400, 0, 20, "ffffff", 1, "c"], "_KeyBoardSetCheakFrame_Label2": [0, 170, 400, 0, 15, "ffffff", 1, "c"], "lblCantSet": [0, 203, 400, 0, 20, "ff0000", 1, "c"]}

const ASK = {"btnCancel": [240, 133, 100, 33], "btnConfirm": [120, 133, 100, 33], "txtContent": [102, 38, 270, 90, 14, "ffffff", 1, "l"]}
