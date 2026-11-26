extends RefCounted

const FILE: String = "res://assets/ui/hall/act_hall.png"

const R: Dictionary = {
	"ah_tip_acting": [196, 586, 193, 32], 
	"ah_tip_front": [2, 586, 192, 36], 
	"ah_tip_over": [770, 294, 99, 38], 
	"gameroom_act_btn_show_tank_active": [637, 586, 24, 24], 
	"gameroom_act_btn_show_tank_no_active": [663, 586, 24, 24], 
	"gameroom_act_img_act_tip_active": [423, 586, 28, 28], 
	"gameroom_act_img_act_tip_no_active": [453, 586, 28, 28], 
	"gameroom_act_img_fire_active_t": [2, 2, 254, 290], 
	"gameroom_act_img_fire_no_active_t": [258, 2, 254, 290], 
	"gameroom_act_img_fireball_active_t": [514, 2, 254, 290], 
	"gameroom_act_img_fireball_no_active_t": [2, 294, 254, 290], 
	"gameroom_act_img_happy_active_t": [258, 294, 254, 290], 
	"gameroom_act_img_happy_no_active_t": [514, 294, 254, 290], 
	"gameroom_act_word_show_tank_active_t": [483, 586, 75, 26], 
	"gameroom_act_word_show_tank_no_active_t": [560, 586, 75, 26], 
	"gameroom_ico_happy": [391, 586, 30, 32], 
}

const FRAME = {"hall": [-9, -9], "list": [804, 36], "chat": [1, 398], "input": [1, 557], "menu": [242, 552]}

const PLACE = [["hall", 1, 0, "arena_bg", "", 0, 0, 100, 0], ["hall", 18, 47, "gameroom_pvpReadyRoom1000x600_shadow", "", 0, 0, 100, 0], ["hall", 469, 21, "gameroom_title_hall_t", "", 0, 0, 100, 0], ["hall", 979, 15, "public_button_close", "back", 0, 0, 100, 1], ["hall", 22, 51, "gameroom_sort_bk", "", 0, 0, 100, 0], ["hall", 135, 51, "gameroom_sort_bk", "", 0, 0, 100, 0], ["hall", 248, 51, "gameroom_sort_bk", "", 0, 0, 100, 0], ["hall", 360, 51, "gameroom_sort_bk", "", 0, 0, 100, 0], ["hall", 22, 51, "gameroom_sort_selected", "", 0, 0, 100, 0], ["hall", 60, 58, "gameroom_sort_title_happygame_selected_t", "", 0, 0, 100, 0], ["hall", 166, 60, "gameroom_sort_title_arena_t", "tab:pvp", 0, 0, 100, 0], ["hall", 135, 51, "", "tab:pvp", 109, 39, 100, 1], ["hall", 280, 60, "gameroom_icon_ladder_unselect_t", "tab:ladder", 0, 0, 100, 0], ["hall", 248, 51, "", "tab:ladder", 109, 39, 100, 1], ["hall", 392, 60, "gameroom_sort_title_teamcompetition_t", "tab:league", 0, 0, 100, 0], ["hall", 361, 51, "", "tab:league", 109, 39, 100, 1], ["hall", 534, 456, "gameroom_quickplay_bk_4", "", 0, 0, 100, 0], ["hall", 545, 469, "gameroom_button_red_m", "quick", 0, 0, 100, 1], ["hall", 614, 481, "gameroom_word_quickplay_onlyfont_t", "quick", 0, 0, 100, 0], ["hall", 580, 477, "gameroom_ico_happy", "quick", 0, 0, 100, 0], ["list", 0, 0, "gameroom_roomplayerlist_bk", "", 0, 0, 100, 0], ["list", 9, 40, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 106, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 172, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 238, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 304, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 370, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 436, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0]]

const INFO = {"at": {"3": [33, 98], "28": [290, 98], "32": [547, 98]}, "kind": {"3": "happy", "28": "fire", "32": "fireball"}, "bg": [-2.0, -2.0], "tip": [208, 14], "tank_word": [77, 184], "tank_btn": [156, 185], "text": [5, 68, 240, 115, 15, "b6f7ff", 1, "c"]}

const TIP = {"at": [613, 53], "size": [192, 35], "art": {"front": [0, -0.5], "acting": [0, 1.5], "over": [0, -1.5]}, "texts": {"lblMatchCountdown": [104, 17.5, 0, 0, 16, "ffff00", 1, "l"], "lblActState": [3, 17.5, 0, 0, 14, "ffffff", 1, "l"]}}

const WAIT = {"at": [18, 400], "size": [794, 158], "from": 354, "broad": [475, 0], "title": [70, 24], "cancel": [59, 102], "clock": [475, 57, 298, 0, 22, "fcff00", 1, "c"]}
