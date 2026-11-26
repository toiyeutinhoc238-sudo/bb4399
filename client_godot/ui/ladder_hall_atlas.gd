extends RefCounted

const FILE: String = "res://assets/ui/hall/ladder_hall.png"

const R: Dictionary = {
	"ld_bp_empty": [2, 1542, 564, 27], 
	"ld_bp_full": [2, 1571, 564, 27], 
	"ld_btn_rule_t": [853, 1448, 72, 30], 
	"ld_btn_watch_rank_t": [568, 1571, 111, 22], 
	"ld_btn_watch_reward_t": [710, 1448, 141, 42], 
	"ld_frame_bronze": [2, 314, 516, 187], 
	"ld_frame_diamon": [2, 503, 516, 187], 
	"ld_frame_epic": [2, 692, 516, 187], 
	"ld_frame_golden": [2, 881, 516, 187], 
	"ld_frame_platnum": [2, 1070, 516, 187], 
	"ld_frame_silver": [2, 1259, 516, 187], 
	"ld_info_bg": [2, 2, 786, 310], 
	"ld_medal_bronze": [327, 1448, 86, 90], 
	"ld_medal_diamon": [917, 1259, 98, 102], 
	"ld_medal_epic": [106, 1448, 119, 91], 
	"ld_medal_epic_big": [772, 1259, 143, 109], 
	"ld_medal_golden": [227, 1448, 98, 91], 
	"ld_medal_platnum": [2, 1448, 102, 92], 
	"ld_medal_silver": [415, 1448, 88, 88], 
	"ld_no_coin_bg": [520, 1259, 250, 179], 
	"ld_no_coin_fun_t": [505, 1448, 203, 54], 
}

const FRAME = {"hall": [-9, -9], "top": [-9, -9], "list": [804, 36], "chat": [1, 398], "input": [1, 557], "menu": [242, 552]}

const PLACE = [["hall", 1, 0, "arena_bg", "", 0, 0, 100, 0], ["hall", 18, 47, "gameroom_pvpReadyRoom1000x600_shadow", "", 0, 0, 100, 0], ["hall", 469, 21, "gameroom_title_hall_t", "", 0, 0, 100, 0], ["hall", 979, 15, "public_button_close", "back", 0, 0, 100, 1], ["hall", 22, 51, "gameroom_sort_bk", "", 0, 0, 100, 0], ["hall", 135, 51, "gameroom_sort_bk", "", 0, 0, 100, 0], ["hall", 248, 51, "gameroom_sort_bk", "", 0, 0, 100, 0], ["hall", 360, 51, "gameroom_sort_bk", "", 0, 0, 100, 0], ["hall", 60, 58, "gameroom_sort_title_happygame_t", "tab:act", 0, 0, 100, 0], ["hall", 22, 51, "", "tab:act", 109, 39, 100, 1], ["hall", 166, 60, "gameroom_sort_title_arena_t", "tab:pvp", 0, 0, 100, 0], ["hall", 135, 51, "", "tab:pvp", 109, 39, 100, 1], ["hall", 392, 60, "gameroom_sort_title_teamcompetition_t", "tab:league", 0, 0, 100, 0], ["hall", 361, 51, "", "tab:league", 109, 39, 100, 1], ["hall", 248, 51, "gameroom_sort_selected", "", 0, 0, 100, 0], ["hall", 280, 60, "gameroom_icon_ladder_selected_t", "", 0, 0, 100, 0], ["hall", 534, 429, "gameroom_quickplay_bk_4", "", 0, 0, 100, 0], ["hall", 546, 442, "gameroom_button_red_m", "quick", 0, 0, 100, 1], ["hall", 615, 454, "gameroom_word_quickplay_onlyfont_t", "quick", 0, 0, 100, 0], ["hall", 581, 451, "gameroom_ico_pvp", "quick", 0, 0, 100, 0], ["hall", 650, 499, "gameroom_btn_find_team_t", "find", 0, 0, 100, 1], ["hall", 527, 499, "gameroom_btn_create_team_t", "create", 0, 0, 100, 1], ["hall", 20, 90, "ld_info_bg", "", 0, 0, 100, 0], ["hall", 545, 107, "ld_no_coin_bg", "", 0, 0, 100, 0], ["hall", 568, 222, "ld_no_coin_fun_t", "", 0, 0, 100, 0], ["hall", 598, 113, "ld_medal_epic_big", "", 0, 0, 100, 0], ["top", 416, 244, "ld_btn_watch_rank_t", "watch", 0, 0, 100, 1], ["top", 641, 324, "ld_btn_watch_reward_t", "reward", 0, 0, 100, 1], ["top", 715, 97, "ld_btn_rule_t", "rule", 0, 0, 100, 1], ["list", 0, 0, "gameroom_roomplayerlist_bk", "", 0, 0, 100, 0], ["list", 9, 40, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 106, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 172, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 238, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 304, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 370, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 436, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0]]

const INFO = {"section": [34, 102], "medal": {"bronze": [80.0, 142.0], "silver": [78.5, 143.5], "golden": [74.0, 141.5], "platnum": [73.0, 141.5], "diamon": [73.0, 131.5], "epic": [63.0, 140.0]}, "texts": {"lblSection": [190, 194, 0, 0, 16, "ffffff", 1, "l"], "lblName": [190, 158, 0, 0, 18, "ffffff", 1, "l"], "lblBattlePoint": [56, 308, 0, 0, 14, "ffffff", 1, "l"]}, "bar": [56, 335], "fill": [0, 13, 18, 24, 29, 35, 40, 46, 51, 57, 63, 68, 74, 79, 85, 90, 96, 101, 107, 112, 118, 124, 129, 135, 140, 146, 151, 157, 162, 168, 174, 179, 185, 190, 196, 201, 207, 212, 218, 223, 229, 235, 240, 246, 251, 257, 262, 268, 273, 279, 285, 290, 296, 301, 307, 312, 318, 323, 329, 334, 340, 346, 351, 357, 362, 368, 373, 379, 384, 390, 396, 401, 407, 412, 418, 423, 429, 434, 440, 445, 451, 457, 462, 468, 473, 479, 484, 490, 495, 501, 507, 512, 518, 523, 529, 534, 540, 545, 551, 564]}
