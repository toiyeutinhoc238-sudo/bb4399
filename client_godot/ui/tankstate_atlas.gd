extends RefCounted

const FILE: String = "res://assets/ui/hall/tankstate.png"

const R: Dictionary = {
	"tl_bg": [2, 2, 62, 71], 
	"tl_cd_bg": [364, 2, 24, 24], 
	"tl_cd_ready": [390, 2, 24, 24], 
	"tl_frame_1": [66, 2, 60, 60], 
	"tl_frame_2": [128, 2, 60, 60], 
	"tl_hp_blue": [488, 75, 56, 7], 
	"tl_hp_red": [546, 75, 56, 7], 
	"tl_rent": [416, 2, 37, 21], 
	"tl_star_1": [190, 2, 27, 26], 
	"tl_star_2": [219, 2, 27, 26], 
	"tl_star_3": [248, 2, 27, 26], 
	"tl_star_4": [277, 2, 27, 26], 
	"tl_star_5": [306, 2, 27, 26], 
	"tl_star_6": [335, 2, 27, 26], 
	"tl_talk_l1": [455, 2, 160, 20], 
	"tl_talk_l2": [617, 2, 160, 20], 
	"tl_talk_l3": [779, 2, 160, 20], 
	"tl_talk_r1": [2, 75, 160, 20], 
	"tl_talk_r2": [164, 75, 160, 20], 
	"tl_talk_r3": [326, 75, 160, 20], 
}

const LAYOUT = {"size": [64, 71], "bg": [0, 0, 62, 71], "frame": [1, 0, 60, 60], "avatar": [3, 0, 0.27], "avatar_hit": [3, 0, 54, 54], "name": [2, 41, 64, 11], "hp": [3, 62, 56, 7], "star_scale": 0.75, "left": {"star": [-2, -2], "star_blue": [-1, 0], "cd_bg": [40, 0], "cd_label": [39, 1, 26, 14], "cd_ready": [40, -2], "chat": [35, 15], "talk_dx": 20, "text": [25, 15, 145]}, "right": {"star_right": 65, "star_y": -1, "cd_bg": [0, 0], "cd_label": [-2, 1, 26, 14], "cd_ready": [0, -2], "chat": [-170, 15], "talk_dx": 20, "text": [26, 14, 145]}, "column": {"left": [4, 122], "right_margin": 4, "top": 122, "step": 72, "max": 6}, "talk": [160, 20], "talk_alpha": 0.8}
