extends RefCounted

const FILE: String = "res://assets/ui/hall/reward_popup.png"

const R: Dictionary = {
	"rw_close": [280, 1149, 24, 24], 
	"rw_fly_gift": [2, 1047, 100, 100], 
	"rw_fly_money": [104, 1047, 100, 100], 
	"rw_fly_package": [750, 1047, 72, 61], 
	"rw_grid_1": [512, 632, 508, 298], 
	"rw_grid_2": [2, 632, 508, 413], 
	"rw_grid_3": [512, 2, 508, 522], 
	"rw_grid_4": [2, 2, 508, 628], 
	"rw_icon_cash": [824, 1047, 50, 50], 
	"rw_icon_exp": [876, 1047, 50, 50], 
	"rw_icon_fizz": [928, 1047, 50, 50], 
	"rw_icon_gift": [2, 1149, 50, 50], 
	"rw_icon_honor": [54, 1149, 50, 50], 
	"rw_icon_money": [106, 1149, 50, 50], 
	"rw_icon_thew": [292, 1047, 76, 76], 
	"rw_item_bg": [206, 1047, 84, 84], 
	"rw_ok_skin": [158, 1149, 120, 35], 
	"rw_ok_word": [306, 1149, 39, 21], 
	"rw_quality_blue": [370, 1047, 74, 74], 
	"rw_quality_green": [446, 1047, 74, 74], 
	"rw_quality_orange": [522, 1047, 74, 74], 
	"rw_quality_purple": [598, 1047, 74, 74], 
	"rw_quality_white": [674, 1047, 74, 74], 
}

const FRAMES = {"1": {"size": [529, 300], "panel": [19, 0], "cell": "rw_grid_1", "slots": [[38.5, 78, 91, 110], [128.5, 78, 91, 110], [218.5, 78, 91, 110], [308.5, 78, 91, 110], [398.5, 78, 91, 110]], "nodes": {"box41": [35, 62, 460, 140], "btnClose": [491, 33, 24, 24], "btnConfirm": [204.5, 250, 120, 35]}, "texts": {"lblAwardExplain": [34.5, 209, 460, 0, 14, "ffffff", 1, "c"]}, "confirm": {"label": "(3s)", "fontSize": 12, "color": "e85f37", "icon_size": [39, 21]}}, "2": {"size": [529, 415], "panel": [19, 0], "cell": "rw_grid_2", "slots": [[38.5, 78, 91, 110], [128.5, 78, 91, 110], [218.5, 78, 91, 110], [308.5, 78, 91, 110], [398.5, 78, 91, 110], [38.5, 187, 91, 110], [128.5, 187, 91, 110], [218.5, 187, 91, 110], [308.5, 187, 91, 110], [398.5, 187, 91, 110]], "nodes": {"box41": [35, 62, 460, 250], "btnClose": [491, 33, 24, 24], "btnConfirm": [204.5, 365, 120, 35]}, "texts": {"lblAwardExplain": [34.5, 321, 460, 0, 14, "ffffff", 1, "c"]}, "confirm": {"label": "(3s)", "fontSize": 12, "color": "e85f37", "icon_size": [39, 21]}}, "3": {"size": [529, 524], "panel": [19, 0], "cell": "rw_grid_3", "slots": [[38.5, 78, 91, 110], [128.5, 78, 91, 110], [218.5, 78, 91, 110], [308.5, 78, 91, 110], [398.5, 78, 91, 110], [38.5, 187, 91, 110], [128.5, 187, 91, 110], [218.5, 187, 91, 110], [308.5, 187, 91, 110], [398.5, 187, 91, 110], [38.5, 296, 91, 110], [128.5, 296, 91, 110], [218.5, 296, 91, 110], [308.5, 296, 91, 110], [398.5, 296, 91, 110]], "nodes": {"box41": [35, 62, 460, 360], "btnClose": [491, 33, 24, 24], "btnConfirm": [204.5, 474, 120, 35]}, "texts": {"lblAwardExplain": [34.5, 430, 460, 0, 14, "ffffff", 1, "c"]}, "confirm": {"label": "(3s)", "fontSize": 12, "color": "e85f37", "icon_size": [39, 21]}}, "4": {"size": [529, 630], "panel": [19, 0], "cell": "rw_grid_4", "slots": [[38.5, 78, 91, 110], [128.5, 78, 91, 110], [218.5, 78, 91, 110], [308.5, 78, 91, 110], [398.5, 78, 91, 110], [38.5, 187, 91, 110], [128.5, 187, 91, 110], [218.5, 187, 91, 110], [308.5, 187, 91, 110], [398.5, 187, 91, 110], [38.5, 296, 91, 110], [128.5, 296, 91, 110], [218.5, 296, 91, 110], [308.5, 296, 91, 110], [398.5, 296, 91, 110], [38.5, 405, 91, 110], [128.5, 405, 91, 110], [218.5, 405, 91, 110], [308.5, 405, 91, 110], [398.5, 405, 91, 110]], "nodes": {"box41": [35, 62, 460, 470], "btnClose": [491, 33, 24, 24], "btnConfirm": [204.5, 580, 120, 35]}, "texts": {"lblAwardExplain": [34.5, 538, 460, 0, 14, "ffffff", 1, "c"]}, "confirm": {"label": "(3s)", "fontSize": 12, "color": "e85f37", "icon_size": [39, 21]}}}

const ITEM = {"size": [91, 110], "bg": [3.5, 0, 84, 84], "icon": [7.5, 4.0, 76, 76], "quality": [9, 5, 74, 74], "name": {"width": 66, "horizontalCenter": 0, "bottom": 32, "fontSize": 12, "color": "ffffff", "bold": true, "align": "center", "wordWrap": true}, "count": {"x": 0.5, "y": 82, "width": 90, "fontSize": 13, "color": "ffffff", "bold": true, "align": "center"}, "small_count": {"horizontalCenter": 20, "y": 52, "hide_name": true}, "shadow": {"color": "005797", "alpha": 0.8, "blurX": 2, "blurY": 2, "strength": 10}, "icons": {"money": {"cell": "rw_icon_money", "rect": [20.5, 7.0, 50, 50], "label": "银币", "quality": "white"}, "exp": {"cell": "rw_icon_exp", "rect": [20.5, 7.0, 50, 50], "label": "经验", "quality": "white"}, "gift": {"cell": "rw_icon_gift", "rect": [20.5, 7.0, 50, 50], "label": "礼券", "quality": "green"}, "cash": {"cell": "rw_icon_cash", "rect": [20.5, 7.0, 50, 50], "label": "点券", "quality": "green"}, "honor": {"cell": "rw_icon_honor", "rect": [20.5, 7.0, 50, 50], "label": "荣誉", "quality": "white"}, "thew": {"cell": "rw_icon_thew", "rect": [7.5, 4.0, 76, 76], "label": "体力", "quality": "white"}, "fizz": {"cell": "rw_icon_fizz", "rect": [20.5, 7.0, 50, 50], "label": "活跃", "quality": "white"}}, "qualities": {"white": {"cell": "rw_quality_white", "rect": [9, 5, 74, 74]}, "green": {"cell": "rw_quality_green", "rect": [9, 5, 74, 74]}, "blue": {"cell": "rw_quality_blue", "rect": [9, 5, 74, 74]}, "purple": {"cell": "rw_quality_purple", "rect": [9, 5, 74, 74]}, "orange": {"cell": "rw_quality_orange", "rect": [9, 5, 74, 74]}}, "count_format": "integer decimal; ItemTool.transformAwardNum returns count.toString()", "tank": {"scale": 0.37, "size": 200, "x": 8.5, "y": 4, "quality": "purple"}}

const FLY = {"art": {"money": {"cell": "rw_fly_money", "size": [100, 100], "logical": "rez/zh_CN/effect/diamond_Big.png"}, "gift": {"cell": "rw_fly_gift", "size": [100, 100], "logical": "rez/zh_CN/effect/gift_big.png"}, "package": {"cell": "rw_fly_package", "size": [72, 61], "logical": "rez/zh_CN/gui_summer/controls/main/PackageIcon.png"}}, "package_rect": [0, 0, 72, 61], "package_offset": [10, 2], "clip_offset": [38, 30]}

const EFFECT = {"open_ms": 500, "open_scale": [0.1, 1], "open_alpha": [0, 1], "open_ease": "Back.easeOut", "close_ms": 500, "close_scale": [1, 0.1], "close_alpha": [1, 0], "close_ease": "Back.easeIn", "auto_close_seconds": 3, "close_on_any_click": true}
