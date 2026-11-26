extends RefCounted

const FILE: String = "res://assets/ui/hall/room.png"

const R: Dictionary = {
	"gameroom_avatar_card_button_bk": [816, 1348, 90, 28], 
	"gameroom_avatar_card_button_bk_s": [908, 1348, 90, 28], 
	"gameroom_avatar_card_button_bk_ss": [2, 1423, 90, 28], 
	"gameroom_avatar_card_button_s": [248, 1423, 26, 26], 
	"gameroom_avatar_card_close_t": [410, 1224, 80, 113], 
	"gameroom_avatar_card_ico_addfriend_s": [276, 1423, 26, 26], 
	"gameroom_avatar_card_ico_info_s": [304, 1423, 26, 26], 
	"gameroom_avatar_card_ico_quit_s": [332, 1423, 26, 26], 
	"gameroom_avatar_card_name": [550, 1423, 132, 22], 
	"gameroom_avatar_card_waitplayer_t": [293, 1224, 115, 119], 
	"gameroom_b2_changeteam_t": [684, 1423, 60, 18], 
	"gameroom_button_host": [360, 1423, 26, 26], 
	"gameroom_button_interact": [388, 1423, 26, 26], 
	"gameroom_button_title_roompassword_t": [746, 1423, 69, 17], 
	"gameroom_cancelready_button_t": [662, 1224, 84, 84], 
	"gameroom_cancelready_disable_button_t": [748, 1224, 84, 84], 
	"gameroom_mapcard": [2, 900, 232, 322], 
	"gameroom_mapcard_select": [236, 900, 232, 322], 
	"gameroom_pvp5v5_playerbox_blueteam": [470, 900, 156, 156], 
	"gameroom_pvp5v5_playerbox_myself": [628, 900, 156, 156], 
	"gameroom_pvp5v5_playerbox_redteam": [786, 900, 156, 156], 
	"gameroom_pvp_selectmap_bk": [2, 2, 794, 447], 
	"gameroom_pvp_selectmap_shadow": [2, 451, 794, 447], 
	"gameroom_ready_button_t": [834, 1224, 84, 84], 
	"gameroom_startgame_background_t": [2, 1224, 289, 122], 
	"gameroom_startgame_button_t": [920, 1224, 84, 84], 
	"gameroom_title_teamnumber_t": [817, 1423, 55, 17], 
	"map_random_s": [492, 1224, 168, 100], 
	"public_btn_next_s2": [81, 1348, 52, 57], 
	"public_btn_prev_s2": [135, 1348, 52, 57], 
	"public_button_2_blue": [718, 1348, 96, 28], 
	"public_button_2_s_blue": [416, 1423, 86, 25], 
	"public_label40x20": [504, 1423, 44, 24], 
	"public_lock": [2, 1348, 77, 73], 
	"public_n_onebtn_bk": [189, 1348, 194, 53], 
	"public_tip_msg": [216, 1423, 30, 27], 
	"roomteam_ready_s_t": [568, 1348, 120, 36], 
	"roomteam_roommaster_t": [94, 1423, 120, 27], 
	"tank_ico_rent_t": [690, 1348, 26, 30], 
	"title_selectmap_t": [385, 1348, 181, 53], 
}

const FRAME: Dictionary = {
	"hall": [-9, -9], 
	"list": [804, 36], 
	"chat": [0, 398], 
	"input": [0, 557], 
	"menu": [242, 552], 
	"start": [489, 427], 
}

const SEAT_X: Array = [20, 177, 334, 491, 648]
const SEAT_Y: Array = [81, 239]


const POSTERS: Array = [0, 1, 4, 7, 9, 10, 12, 14, 17, 18, 19, 20, 21, 30, 34, 35, 36, 37, 40, 50, 70, 130, 169, 170, 333, 334]
const SMALLS: Array = [0, 1, 4, 7, 9, 10, 12, 14, 17, 18, 19, 20, 21, 30, 34, 35, 36, 37, 40, 50, 70, 130, 169, 170, 333, 334]


const DRAWN: Array = ["p1", "p10", "p12", "p130", "p14", "p17", "p170", "p18", "p21", "p37", "p4", "p40", "p50", "p70", "p9", "s1", "s10", "s12", "s130", "s14", "s169", "s17", "s170", "s18", "s19", "s20", "s21", "s34", "s35", "s36", "s37", "s4", "s50", "s7", "s70", "s9"]

const PLACE: Array = [
	["hall", 0, 0, "arena_bg", "", 0, 0, 100, 0], 
	["hall", 92, 53, "public_label40x20", "", 0, 0, 100, 0], 
	["hall", 35, 54, "gameroom_title_teamnumber_t", "", 0, 0, 100, 0], 
	["hall", 978, 15, "public_button_close", "leave", 0, 0, 100, 1], 
	["list", 0, 0, "gameroom_roomplayerlist_bk", "", 0, 0, 100, 0], 
	["list", 9, 40, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], 
	["list", 9, 106, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], 
	["list", 9, 172, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], 
	["list", 9, 238, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], 
	["list", 9, 304, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], 
	["list", 9, 370, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], 
	["list", 9, 436, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], 
]
