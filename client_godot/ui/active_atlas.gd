extends RefCounted

const FILE: String = "res://assets/ui/hall/active.png"

const R: Dictionary = {
	"act_close": [788, 646, 23, 23], 
	"act_frame": [2, 2, 620, 557], 
	"act_fx00": [650, 2, 82, 83], 
	"act_fx01": [734, 2, 82, 83], 
	"act_fx02": [818, 2, 82, 83], 
	"act_fx03": [902, 2, 82, 83], 
	"act_fx04": [2, 561, 82, 83], 
	"act_fx05": [86, 561, 82, 83], 
	"act_fx06": [170, 561, 82, 83], 
	"act_fx07": [254, 561, 82, 83], 
	"act_fx08": [338, 561, 82, 83], 
	"act_fx09": [422, 561, 82, 83], 
	"act_fx10": [506, 561, 82, 83], 
	"act_fx11": [590, 561, 82, 83], 
	"act_fx12": [674, 561, 82, 83], 
	"act_fx13": [758, 561, 82, 83], 
	"act_fx14": [842, 561, 82, 83], 
	"act_fx15": [926, 561, 82, 83], 
	"act_fx16": [2, 646, 82, 83], 
	"act_fx17": [86, 646, 82, 83], 
	"act_fx18": [170, 646, 82, 83], 
	"act_fx19": [254, 646, 82, 83], 
	"act_fx20": [338, 646, 82, 83], 
	"act_fx21": [422, 646, 82, 83], 
	"act_fx22": [506, 646, 82, 83], 
	"act_fx23": [590, 646, 82, 83], 
	"act_geted": [674, 646, 60, 48], 
	"act_progress": [2, 731, 440, 18], 
	"act_sb_down": [736, 646, 24, 24], 
	"act_sb_track": [624, 2, 24, 252], 
	"act_sb_up": [762, 646, 24, 24], 
	"act_tips": [813, 646, 22, 22], 
}

const FRAME = [620, 550]

const BODY = [0, -7]

const CLOSE = [597, 10, 23, 23]

const PROGRESS = [140.0, 106.0, 440, 18]

const PGB = [92, 85, 85, 85, 93]

const ITEMS = [{"img": [204, 56.0], "geted": [199.0, 57.0], "fx": [229.0, 81.0], "label": [204, 128, 50]}, {"img": [288, 56.0], "geted": [283.0, 57.0], "fx": [313.0, 81.0], "label": [288, 128, 50]}, {"img": [373, 56.0], "geted": [368.0, 57.0], "fx": [398.0, 81.0], "label": [373, 128, 50]}, {"img": [457, 56.0], "geted": [452.0, 57.0], "fx": [482.0, 81.0], "label": [457, 128, 50]}, {"img": [544, 56.0], "geted": [539.0, 57.0], "fx": [569.0, 81.0], "label": [544, 128, 50]}]

const FX = {"at": [0, 0], "stage": [82, 83], "rate": 24.0, "cells": ["act_fx00", "act_fx01", "act_fx02", "act_fx03", "act_fx04", "act_fx05", "act_fx06", "act_fx07", "act_fx08", "act_fx09", "act_fx10", "act_fx11", "act_fx12", "act_fx13", "act_fx14", "act_fx15", "act_fx16", "act_fx17", "act_fx18", "act_fx19", "act_fx20", "act_fx21", "act_fx22", "act_fx23"]}

const LABELS = {"daily": [0, 61.0, 200, 18], "daily_value": [0, 90, 200, 24], "week": [16.0, 471.0, 200, 18], "week_value": [16.0, 495, 200, 24]}

const DAILY_INK = ["fff17c", "ff921d", "c02e02"]

const WEEK_INK = ["fffdf7", "fcc92f", "ea410d"]

const TIPS = {"daily": [20, 63.0], "week": [20, 473.0]}

const LIST = [10, 150, 600, 300]

const SCROLL = {"x": 586, "up": [150, 24], "track": [174, 252], "down": [426, 24]}

const WORDS = {"daily": "Độ Hoạt Động", "week": "Độ Hoạt Động Tuần", "daily_tip": "6h sáng hàng ngày làm mới", "week_tip": "6h sáng thứ 2 làm mới"}
