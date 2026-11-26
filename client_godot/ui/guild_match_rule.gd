extends RefCounted



const Flash = preload("flash_screen.gd")
const GuildRule = preload("guild_rule_atlas.gd")

static func draw(view) -> void :
	var box: Array = GuildRule.BOX
	var at: Vector2 = bare_window(view, float(box[0]), float(box[1]), "cancel")
	var spot: Dictionary = GuildRule.AT
	view._fblit("gr_body", at + Vector2(float(spot["body"][0]), float(spot["body"][1])))
	var words: Dictionary = GuildRule.WORDS
	var title: Array = words["title"]
	view._fwords(str(title[0]), Flash.ARIAL_BOLD, 16, Color.WHITE, "c", at + Vector2(float(title[1]) - 91.0, float(title[2]) - 1.0), 182, 1.5, 28.0)
	for key: String in ["mode", "time", "rule"]:
		var word: Array = words[key]
		view._fwords(str(word[0]), Flash.ARIAL_BOLD, 13, Color.WHITE, "l", at + Vector2(float(word[1]), float(word[2]) - 3.0), 38, 1.0, 19.0)
	var texts: Dictionary = GuildRule.TEXTS
	for key: String in ["mode", "time"]:
		var cell: Array = spot[key]
		view._fwords(str(texts[key]), Flash.ARIAL_BOLD, 13, Color.WHITE, "l", at + Vector2(float(cell[0]) + 10.0, float(cell[1]) + 5.0), 
			float(cell[2]) - 20.0, 0.0, float(cell[3]) - 10.0)
	var rule: Array = spot["rule"]
	var face: Font = view._face(Flash.ARIAL)
	var f: float = view._f
	var lines: int = maxi(1, floori((float(rule[3]) - 8.0) * f / face.get_height(maxi(6, roundi(12.0 * f)))))
	view._fpara(str(texts["rule"]), Flash.ARIAL, 12, Color.WHITE, at + Vector2(float(rule[0]) + 6.0, float(rule[1]) + 4.0), float(rule[2]) - 12.0, lines)
	view._fbutton("rule_go", "gr_go", at + Vector2(float(spot["go"][0]), float(spot["go"][1])))


static func bare_window(view, wide: float, high: float, close: String) -> Vector2:
	var f: float = view._f
	view._hit("shade", Rect2(Vector2.ZERO, view.size), false)
	var at: Vector2 = view._centre(wide, high)
	view._hit("panel", Rect2(at * f, Vector2(wide, high) * f), false)
	view.draw_rect(Rect2((at + Vector2(12, 43)) * f, Vector2(wide - 24.0, high - 56.0) * f), Flash.WINDOW)
	var full: Vector2 = view._cell_size("public_bk_pattern")
	var part: Vector2 = Vector2(minf(full.x, wide - 24.0), minf(full.y, high - 56.0))
	view._fpart("public_bk_pattern", at + Vector2(12, 43) + (Vector2(wide - 24.0, high - 56.0) - part) / 2.0, Rect2(((full - part) / 2.0).floor(), part))
	view._fblit("public_bk_lt", at)
	view._fblit("public_bk_rt", at + Vector2(wide - 34.0, 0))
	view._fblit("public_bk_bc", at + Vector2(0, high - 90.0))
	view._fblit("public_bk_bc_r", at + Vector2(wide - 30.0, high - 90.0))
	view._fblit("public_bk", at + Vector2(34, 0), wide - 68.0)
	view._fblit("public_bk_b2", at + Vector2(30, high - 68.0), wide - 60.0)
	view._fblit("public_bk_l", at + Vector2(0, 84), 0.0, high - 174.0)
	view._fblit("public_bk_r", at + Vector2(wide - 30.0, 84), 0.0, high - 174.0)
	view._fmid("public_bk_ti", at + Vector2(0, 18), wide)
	view._fblit("public_bk_oc", at + Vector2(43, 9), wide - 86.0)
	view._fblit("public_bk_ol", at + Vector2(35, 9))
	view._fblit("public_bk_or", at + Vector2(wide - 43.0, 9))
	view._fblit("public_bk_c", at + Vector2(wide - 52.0, 13))
	view._fmid("public_window_button_bk", at + Vector2(0, high - 56.0), wide)
	view._fbutton(close, "public_button_close", at + Vector2(wide - 39.0, 15))
	return at
