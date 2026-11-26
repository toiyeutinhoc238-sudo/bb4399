extends RefCounted

const FILE: String = "res://assets/ui/hall/master_task.png"

const R: Dictionary = {
	"mt_box": [2, 487, 520, 388], 
	"mt_box_master": [2, 877, 520, 365], 
	"mt_bracket": [524, 877, 16, 93], 
	"mt_get": [509, 1244, 100, 33], 
	"mt_get_bk": [542, 877, 106, 40], 
	"mt_row": [2, 1244, 469, 34], 
	"mt_take": [611, 1244, 100, 33], 
	"mt_tick": [473, 1244, 34, 34], 
	"mt_win": [2, 2, 579, 483], 
}

const TASK = [468, 152, 34]

const TASK_TEXT = {"lblTitle": [34, 5, 220, 0, 14, "ffffff", 1, "l"], "lblCheckPoint": [304, 8, 70, 0, 12, "ffffff", 1, "l"], "lblAmity": [386, 8, 0, 0, 12, "ffffff", 1, "l"], "lblThew": [412, 58, 0, 0, 12, "ffffff", 1, "c"]}

const TASK_AT = {"get": [364, 85], "bracket": [7, 52], "bracket_only": [0, 52], "cells": [[24, 38], [108, 38], [192, 38], [276, 38], [382, 38]], "cells_only": [[22, 38], [112, 38], [202, 38], [292, 38], [382, 38]]}

const AWARD = {"bg": [3.5, 0], "quality": [9, 5], "item": [7.5, 4], "coin": [20.5, 7], "gift": [16.5, 3], "lblRewardName": [12.5, 78, 66, 0, 12, "ffffff", 1, "c"], "lblNum": [0.5, 82, 90, 0, 13, "ffffff", 1, "c"]}

const WIN = [600, 490]

const WIN_AT = {"win": [19, 5], "box": [40, 80], "box_master": [40, 103], "get_bk": [455, 65], "take": [458, 69], "close": [562, 33]}

const QUEST = {"": [56, 93, 490, 364], "master": [56, 121, 490, 336]}

const BENEFIT = [134, 74, 0, 0, 16, "ffffff", 1, "l"]

const CONDS = {"1": ["Tổ đội Thầy Trò vượt PB 5 lần", 5, 150, 100, 101], "2": ["Tổ đội Thầy Trò vượt PB 20 lần", 20, 30, 200, 201], "3": ["Tổ đội Thầy Trò tham gia đấu So Tài 3 trận", 3, 100, 300, 301], "4": ["Tổ đội Thầy Trò tham gia đấu So Tài 10 trận", 10, 20, 400, 401], "5": ["Độ Hoạt Động của Trò đạt 150", 150, 100, 500, 501], "6": ["Trò đạt lv8", 8, 500, 0, 0], "7": ["Trò đạt lv10", 10, 400, 0, 0], "8": ["Trò đạt lv12", 12, 300, 0, 0], "9": ["Trò đạt lv14", 14, 200, 0, 0], "10": ["Trò đạt lv16", 16, 100, 0, 0], "11": ["Tổ đội Thầy Trò vượt Lần Đầu Dẫn Binh (khó)", 1, 500, 0, 0], "12": ["Tổ đội Thầy Trò vượt Nguồn Gốc Hủy Diệt (khó)", 1, 200, 0, 0], "13": ["Độ Hoạt Động của Trò đạt 200", 200, 1000, 0, 0], "14": ["Trò tặng Thầy 1 món quà", 1, 1000, 0, 0], "15": ["Thầy tặng Trò 1 món quà", 1, 500, 0, 0]}

const AWARDS = {"100": [200, 0, 1000, 5, [[4020004, 1, "Mảnh lõi No.4", "icon_zhushou_suipian4", 1], [3700003, 2, "Chip siêu dẫn No.3", "icon_zhushou_jingyan03", 2]]], "101": [40, 0, 2500, 0, [[4020002, 5, "Mảnh lõi No.2", "icon_zhushou_suipian2", 0], [3700003, 2, "Chip siêu dẫn No.3", "icon_zhushou_jingyan03", 2]]], "200": [200, 0, 1000, 5, [[4020004, 1, "Mảnh lõi No.4", "icon_zhushou_suipian4", 1], [3700003, 2, "Chip siêu dẫn No.3", "icon_zhushou_jingyan03", 2]]], "201": [40, 0, 2500, 0, [[4020002, 5, "Mảnh lõi No.2", "icon_zhushou_suipian2", 0], [3700003, 2, "Chip siêu dẫn No.3", "icon_zhushou_jingyan03", 2]]], "300": [250, 0, 1250, 5, [[3000051, 20, "Topaz", "icon_upitem_f_01", 0], [3000001, 10, "Mảnh Sắt", "icon_upitem_a_01", 0]]], "301": [50, 0, 3125, 0, [[3000051, 20, "Topaz", "icon_upitem_f_01", 0], [3000001, 10, "Mảnh Sắt", "icon_upitem_a_01", 0]]], "400": [250, 0, 1250, 5, [[3000051, 10, "Topaz", "icon_upitem_f_01", 0], [3000001, 5, "Mảnh Sắt", "icon_upitem_a_01", 0]]], "401": [50, 0, 3125, 0, [[3000051, 10, "Topaz", "icon_upitem_f_01", 0], [3000001, 5, "Mảnh Sắt", "icon_upitem_a_01", 0]]], "500": [300, 0, 1500, 0, [[4020004, 1, "Mảnh lõi No.4", "icon_zhushou_suipian4", 1], [3000051, 10, "Topaz", "icon_upitem_f_01", 0], [3000001, 10, "Mảnh Sắt", "icon_upitem_a_01", 0]]], "501": [60, 0, 3750, 0, [[4020002, 10, "Mảnh lõi No.2", "icon_zhushou_suipian2", 0], [3000051, 20, "Topaz", "icon_upitem_f_01", 0], [3000001, 20, "Mảnh Sắt", "icon_upitem_a_01", 0]]]}

const PRESENTS = {"2006100": [[2005016, 1, "Trứng trợ thủ sơ cấp", "", 2], [2003017, 1, "Heo Đất", "chuxuguan", 1], [3000001, 50, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000051, 20, "Topaz", "icon_upitem_f_01", 0], [3700003, 1, "Chip siêu dẫn No.3", "icon_zhushou_jingyan03", 2]], "2006101": [[2005017, 1, "Trứng trợ thủ trung cấp", "", 3], [2003017, 3, "Heo Đất", "chuxuguan", 1], [3000001, 300, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000051, 100, "Topaz", "icon_upitem_f_01", 0], [3000148, 1, "Thạch Anh Mặt Trời", "icon_skillitem_01", 3], [3700004, 1, "Chip siêu dẫn No.4", "icon_zhushou_jingyan04", 2]], "2006102": [[2005018, 1, "Trứng trợ thủ cao cấp", "egg_random_helper03", 4], [2003017, 5, "Heo Đất", "chuxuguan", 1], [3000001, 1000, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000051, 300, "Topaz", "icon_upitem_f_01", 0], [3000148, 2, "Thạch Anh Mặt Trời", "icon_skillitem_01", 3], [3700005, 1, "Chip siêu dẫn No.5", "icon_zhushou_jingyan05", 3]], "2006103": [[2003017, 1, "Heo Đất", "chuxuguan", 1], [3000001, 200, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000051, 100, "Topaz", "icon_upitem_f_01", 0], [3700003, 10, "Chip siêu dẫn No.3", "icon_zhushou_jingyan03", 2], [3000147, 1, "Thủy Tinh Moonlight", "icon_superskillitem_01", 2]], "2006104": [[2003017, 3, "Heo Đất", "chuxuguan", 1], [3000001, 1500, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000051, 500, "Topaz", "icon_upitem_f_01", 0], [3700004, 10, "Chip siêu dẫn No.4", "icon_zhushou_jingyan04", 2], [3800002, 2, "Siêu tinh thể cấp 2", "icon_zhushou_qianghua02", 1], [3000147, 2, "Thủy Tinh Moonlight", "icon_superskillitem_01", 2]], "2006105": [[2003017, 5, "Heo Đất", "chuxuguan", 1], [3000001, 5000, "Mảnh Sắt", "icon_upitem_a_01", 0], [3000051, 1500, "Topaz", "icon_upitem_f_01", 0], [3700005, 10, "Chip siêu dẫn No.5", "icon_zhushou_jingyan05", 3], [3800002, 5, "Siêu tinh thể cấp 2", "icon_zhushou_qianghua02", 1], [3000148, 3, "Thạch Anh Mặt Trời", "icon_skillitem_01", 3]]}
