extends RefCounted

const FILE: String = "res://assets/ui/hall/world_boss.png"

const R: Dictionary = {
	"wb_award": [652, 2, 296, 82], 
	"wb_board": [2, 2, 308, 323], 
	"wb_boss": [312, 2, 338, 320], 
	"wb_cutline": [2, 432, 280, 2], 
	"wb_enter": [286, 327, 198, 48], 
	"wb_hp_bk": [536, 327, 458, 33], 
	"wb_hp_fill": [97, 403, 445, 21], 
	"wb_quick_bk": [2, 327, 282, 74], 
	"wb_rank1": [544, 403, 40, 20], 
	"wb_rank2": [586, 403, 40, 20], 
	"wb_rank3": [628, 403, 40, 20], 
	"wb_rank4": [670, 403, 40, 20], 
	"wb_rank5": [712, 403, 40, 20], 
	"wb_rule": [486, 327, 48, 48], 
	"wb_title": [2, 403, 93, 27], 
	"wb_top1": [754, 403, 40, 20], 
	"wb_top2": [796, 403, 40, 20], 
	"wb_top3": [838, 403, 40, 20], 
}

const FRAME = {"hall": [-9, -9], "list": [804, 36], "chat": [-2, 398], "input": [-2, 557], "menu": [242, 552]}

const PLACE = [["hall", 0, 0, "arena_bg", "", 0, 0, 100, 0], ["hall", 16, 46, "gameroom_pvpReadyRoom1000x600_shadow", "", 0, 0, 100, 0], ["hall", 462, 21, "wb_title", "", 0, 0, 100, 0], ["hall", 488, 49, "wb_board", "", 0, 0, 100, 0], ["hall", 494, 383, "wb_award", "", 0, 0, 100, 0], ["hall", 500, 492, "wb_quick_bk", "", 0, 0, 100, 0], ["hall", 511, 505, "wb_enter", "enter", 0, 0, 100, 1], ["hall", 723, 505, "wb_rule", "rule", 0, 0, 100, 1], ["hall", 979, 15, "public_button_close", "back", 0, 0, 100, 1], ["list", 0, 0, "gameroom_roomplayerlist_bk", "", 0, 0, 100, 0], ["list", 9, 40, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 106, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 172, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 238, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 304, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 370, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0], ["list", 9, 436, "gameroom_roomplayerlist_item", "", 0, 0, 100, 0]]

const PANELS = {"board": [488, 49], "award": [494, 383]}

const LIST = [500, 111, 278, 244, 22]

const ROW = {"lblHarmValue": [188, 0, 100, 0, 12, "ffffff", 1, "c"], "lblRank": [0, 0, 48, 0, 12, "ffffff", 1, "c"], "lblName": [48, 0, 140, 0, 12, "ffffff", 1, "c"], "rank_mid": [19.0, 11], "cutline": [-1, 20], "self": ["00fcff", 14]}

const CD = [495, 476, 0, 0, 14, "42ff5d", 1, "l"]

const HP = {"at": [27.74, 50], "scale": [0.94, 0.9], "fill": [7, 6], "texts": {"lblHP": [229, 2, 0, 0, 20, "ffffff", 1, "c"], "lblName0": [0, 34, 0, 0, 12, "ffffff", 1, "l"], "lblName1": [196, 34, 0, 0, 12, "ffffff", 1, "l"], "lblName2": [392, 34, 0, 0, 12, "ffffff", 1, "l"], "lblMyHarm": [0, 49, 0, 0, 12, "00fcff", 1, "c"]}, "ranks": {"0": [-36, 34], "1": [160, 34], "2": [356, 34]}}

const BOSS = [72.9, 91.5]

const TILES = {"at": [500, 419], "step": [142, 46], "cols": 2}

const AWARDS = [8000004, 2004004]

const ITEMS = {"8000004": ["Hồng Kim Bảo", "l/it/shuijingyingbi.webp"], "2004004": ["1000Bạc", "l/it/yinbi1000.webp"]}
