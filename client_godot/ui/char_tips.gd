extends RefCounted







const AccCards = preload("acc_cards.gd")



const THEW_TIP: String = "6:00 sáng mỗi ngày hồi đầy Thể lực lên @num1@ điểm (đang cao hơn thì giữ nguyên)"
const EXP_ICON: Rect2 = Rect2(69, 31, 36, 13)
const EXP_LABEL: Rect2 = Rect2(104, 29, 120, 16)
const THEW_LABEL: Rect2 = Rect2(104, 45, 120, 16)

static func thew_tip(cap: int) -> String:
	return THEW_TIP.replace("@num1@", str(cap))


static func exp_tip(basic: Dictionary, now: int) -> String:
	var over: int = int(basic.get("expDoubleTime", 0))
	if over < now:
		return ""
	var left: int = over - now
	return AccCards.EXP_TIP.replace("@time@", AccCards.day_hours(left) if left >= AccCards.DAY else AccCards.hours_minutes(left))


static func tips(basic: Dictionary, now: int, cap: int) -> Array:
	var out: Array = []
	var exp_text: String = exp_tip(basic, now)
	if not exp_text.is_empty():
		out.append([EXP_ICON, exp_text])
		out.append([EXP_LABEL, exp_text])
	out.append([THEW_LABEL, thew_tip(cap)])
	return out
