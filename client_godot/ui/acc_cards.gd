extends RefCounted









const DAY: int = 86400
const HOUR: int = 3600
const MINUTE: int = 60
const ENTER: String = "#ENTER#"



const EXP_TIP: String = "X2 EXP nhân vật#ENTER#Thời gian x2 còn @time@"

const TANK_TIME_TIP: String = "Tank EXPx2 #ENTER# Lượt trạng thái EXPx2 còn @time@"
const TANK_COUNT_TIP: String = "Tank EXPx2 #ENTER# Lượt trạng thái EXPx2 còn @time@"
const EXPIRED: String = "Quá hạn"
const MATERIAL: String = "X2 vật liệu"
const TOKEN: String = "X2 Bạc"
const DAYS_LEFT: String = "Còn @num1@ ngày"
const USES_LEFT: String = "Còn @num1@ lượt (hiệu lực với trận thắng)"
const TIME_FIRST: String = "T.gian ưu tiên dùng còn"
const DAY_HOURS: String = "@day@ ngày @time@ giờ"
const DAYS: String = "@day@ ngày"
const HOURS: String = "@time@ giờ"
const MINUTES: String = "@time@ phút"
const HOUR_MINUTES: String = "@hour@ giờ @time@ phút"

const PLUS: Array = [["acc_material", "materialDoubleTime", "materialDoubleUse", MATERIAL], ["acc_token", "tokenDoubleTime", "tokenDoubleUse", TOKEN]]


static func day_hours(seconds: int) -> String:
	var hours: int = ceili(seconds / float(HOUR))
	if hours < 24:
		return HOURS.replace("@time@", str(hours))
	var days: int = floori(hours / 24.0)
	hours %= 24
	return DAY_HOURS.replace("@day@", str(days)).replace("@time@", str(hours)) if hours > 0 else DAYS.replace("@day@", str(days))


static func hours_minutes(seconds: int) -> String:
	var minutes: int = ceili(seconds / float(MINUTE))
	if minutes < 60:
		return MINUTES.replace("@time@", str(minutes))
	var hours: int = floori(minutes / 60.0)
	minutes %= 60
	return HOUR_MINUTES.replace("@hour@", str(hours)).replace("@time@", str(minutes)) if minutes > 0 else HOURS.replace("@time@", str(hours))


static func card(cell: String, tip: String) -> Array:
	var lines: Array = []
	for line: String in tip.replace(ENTER, "\n").split("\n"):
		if not line.strip_edges().is_empty():
			lines.append(line.strip_edges())
	if lines.is_empty():
		return [cell, "", ""]
	return [cell, str(lines[0]), "\n".join(PackedStringArray(lines.slice(1)))]


static func cards(basic: Dictionary, now: int) -> Array:
	var out: Array = []
	var exp_over: int = int(basic.get("expDoubleTime", 0))
	if exp_over >= now:
		var left: int = exp_over - now - 1
		out.append(card("acc_exp", EXP_TIP.replace("@time@", day_hours(left) if left >= DAY else hours_minutes(left))))
	var tank_over: int = int(basic.get("tankExpDoubleTime", 0))
	var tank_left: int = tank_over - now - 1
	if tank_over > 0 and tank_left > 0:
		var time: String = EXPIRED
		if tank_left > DAY:
			time = day_hours(tank_left)
		elif tank_left > MINUTE:
			time = hours_minutes(tank_left)
		out.append(card("acc_tank_time", TANK_TIME_TIP.replace("@time@", time)))
	var tank_uses: int = int(basic.get("tankExpDoubleUse", 0))
	if tank_uses > 0:
		out.append(card("acc_tank_count", TANK_COUNT_TIP.replace("@time@", str(tank_uses))))
	for row: Array in PLUS:
		var rest: int = int(basic.get(str(row[1]), 0)) - now - 1
		var uses: int = int(basic.get(str(row[2]), 0))
		if rest <= 0 and uses <= 0:
			continue
		var days: int = ceili(rest / float(DAY)) if rest > 0 else 0
		var tip: String = str(row[3]) + "\n"
		if days > 0:
			tip += DAYS_LEFT.replace("@num1@", str(days)) + "\n"
		if uses > 0:
			tip += USES_LEFT.replace("@num1@", str(uses))
		if days > 0 and uses > 0:
			tip += "\n" + TIME_FIRST
		out.append(card(str(row[0]), tip))
	return out
