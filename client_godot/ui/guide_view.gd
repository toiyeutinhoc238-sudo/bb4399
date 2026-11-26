extends Control














const Guide = preload("guide.gd")
const Atlas = preload("guide_atlas.gd")
const NewbieLogin = preload("newbie_login.gd")
const Sound = preload("res://audio.gd")
const Settings = preload("res://settings.gd")
const ARIAL: Font = preload("res://assets/fonts/flash_ui.tres")
const BOLD: Font = preload("res://assets/fonts/flash_ui_bold.tres")


const HOSTS: Dictionary = {
	"lobby": {
		"gameMain": {"btnPvp": "mode:pvp", "btnPvE": "mode:pve", "btnRank": "nav:leaderboard", "btnCorps": "nav:guild"}, 
		"buttonCanvas": {"btnTank": "nav:tank", "btnHelper": "nav:support", "btnCrystal": "nav:crystal", "btnShop": "nav:shop", 
			"btnFriend": "nav:friends", "btnMilRank": "nav:rank", "btnPackage": "nav:bag"}, 
		"mainAct": {"btnDailyReward": "event:daily", "cvsSignInReward": "event:daily", "cvsNewBieReward": "event:newbie", "loginReward": "event:daily"}, 
		"mainLeft": {"cvsInsideQuest": "col:quest"}}, 
	"arena": {"gameHallPvp": {"btnQuickJoin": "quick", "btnLadder": "tab:ladder"}}, 

	"garage": {"tankWindow": {"btnLevelUp": "levelup", "btnBuy": "buy", "btnOnBattle": "onbattle"}, 
		"tankUpWindow": {"btnUpgrade": "up_btn"}}, 

	"helper": {"helperWindow": {"btnLevelUp": "tab:lv", "btnStrengthen": "tab:st", "btnUpGrade": "tab:gr", "btnConvert": "tab:cv", 
			"btnSetBallte": "set_battle", "btnSplitAll": "split_all"}, 
		"helperUpWindow": {"btnConfirm": "do"}, "helperStWindow": {"btnConfirm": "do"}, "helperStarWindow": {"btnConfirm": "do"}, 
		"helperCvtWindow": {"btnConfirm": "do"}}, 

	"select_tank": {"pvpSelectTankWindow": {"btnConfirm": "confirm"}}, 

	"quest": {"questWindow": {"btnGoTo": "goto", "btnGetReward": "get"}}, 

	"crystal": {"crystalWindow": {"firstCrystalItem": "row:0", "btnSave": "save"}}}


const OPEN_TEMP: Array = ["garage", "select_tank", "crystal"]

const OPEN_KEEP: Array = ["crystal"]

const LOADS: Dictionary = {"garage": "tank", "crystal": "crystal"}
const TIP: float = 300.0


const TIP_TEXT: Dictionary = {"down": ["c", 150.0, 216.0], "up": ["c", 150.0, 84.0], "left": ["l", 80.0, 150.0], "right": ["r", 236.0, 150.0]}
const TIP_COLOR: Color = Color("aacce6")
const TIP_RIM: Color = Color(0, 0, 0, 0.6)
const FILM: Dictionary = {"focus": "gda/guide_focus", "up": "gda/guide_help_up", "down": "gda/guide_help_down", "left": "gda/guide_help_left", 
	"right": "gda/guide_help_right", "jiaoguan": "gda/guide_jiaoguan", "mouse": "gda/guide_mouse_tip"}

var host: Control
var kind: String = "lobby"
var guide: RefCounted
var _time: float = 0.0
var _seen: bool = false
var _rev: int = -1
var _lab: String = ""
var _box_id: int = 0
var _box_from: float = 0.0
var _box_on: bool = false
var _tip_key: String = ""
var _tip_from: float = 0.0
var _tip_on: bool = false
var _hole: Rect2 = Rect2()
var _hole_live: bool = true
var _picked: String = ""
var _pick_seen: int = -1
var _press_hole: bool = false
var _music: Rect2 = Rect2()
var _tex: Texture2D


static func shared(source: Node) -> RefCounted:
	if source.has_meta(Guide.META):
		return source.get_meta(Guide.META)
	var made: RefCounted = Guide.new()
	made.client = source
	source.set_meta(Guide.META, made)
	return made

func setup(owner: Control, where: String) -> void :
	host = owner
	kind = where
	name = "GuideView"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_tex = load(Atlas.FILE) if ResourceLoader.exists(Atlas.FILE) else null

func _client() -> Node:
	return host.get("client") if host != null else null

func _process(delta: float) -> void :
	_time += delta
	var source: Node = _client()
	if source == null:
		return
	if guide == null:
		guide = shared(source)
	guide.sync()
	var shown: bool = host.is_visible_in_tree()
	if not shown:
		_seen = false
		_set_block(false)
		_box_on = false
		_tip_on = false
		_press_hole = false
		return
	var first: bool = not _seen
	if first:
		_picked = ""
		_pick_seen = -1
	if first and LOADS.has(kind):
		guide.loaded[str(LOADS[kind])] = true
	var lab: String = str(host.get("_state")) if kind == "helper" else ""
	var moved: bool = not first and lab != _lab
	_lab = lab
	if (first or moved or int(source.quest_rev) != _rev) and bool(source.quests_loaded):
		_rev = int(source.quest_rev)
		var opening: bool = first and kind in OPEN_TEMP
		if (opening and kind not in OPEN_KEEP) or moved:
			guide.release_normal()
		if not opening or not guide.check_temp():
			guide.check()
	_seen = true
	_special()
	if not guide.tip.is_empty() and _tip_key != _key(guide.tip):
		_tip_key = _key(guide.tip)
		_tip_from = _time
	if guide.pending != _box_id:
		_box_id = guide.pending
		_box_from = _time
		if _box_id != 0:
			var row: Dictionary = Guide.direct_row(_box_id)
			if not str(row.get("sound", "")).is_empty():
				Sound.play("u/levelup")
	queue_redraw()

static func _key(row: Dictionary) -> String:
	return "%d:%d:%d" % [int(row["quest"]), int(row["state"]), int(row["step"])]



func _special() -> void :
	if kind == "quest":
		_special_quest()
		return
	if guide.tip.is_empty():
		return
	match kind:
		"garage":
			_special_garage()
			return
		"helper":
			_special_helper()
			return
		"crystal":
			_special_crystal()
			return
	if kind != "lobby" or str(guide.tip["ui"]) != "mainAct" or str(guide.tip["button"]) != "checkSeven":
		return
	if _busy():
		return
	var found: Dictionary = guide.tip
	guide.tip = {}
	if NewbieLogin.cleared(_client()):

		guide.set_guide_quest(int(found["quest"]), Guide.GOING, Guide.MAX_STEP)
		return
	guide.set_guide_quest(int(found["quest"]), Guide.GOING, int(found["step"]))
	guide.next_step(found)



func _special_garage() -> void :
	var found: Dictionary = guide.tip
	var ui: String = str(found["ui"])
	var button: String = str(found["button"])
	if ui != "selectTank" and not (button == "close" and ui in ["tankWindow", "tankUpWindow"]):
		return
	if _busy():
		return
	guide.tip = {}
	guide.tip_set = false
	if ui == "selectTank":
		if int(button) > 0 and host.has_method("guide_select"):
			host.guide_select(int(button))
		guide.next_step(found)
		return
	if host.has_method("guide_close"):
		host.guide_close(ui)
	guide.set_guide_quest(int(found["quest"]), int(found["state"]), int(found["step"]))
	guide.next_step(found)




func _special_helper() -> void :
	var found: Dictionary = guide.tip
	var button: String = str(found["button"])
	if str(found["ui"]) != "helperWindow" or button not in ["close", "putHelper", "put2ConvertHelper"]:
		return
	if _busy():
		return
	if button == "close":
		guide.tip = {}
		guide.tip_set = false
		if host.has_method("guide_close"):
			host.guide_close("helperWindow")
		guide.set_guide_quest(int(found["quest"]), int(found["state"]), int(found["step"]))
		guide.next_step(found)
		return
	var done: int = int(host.guide_put(button == "put2ConvertHelper")) if host.has_method("guide_put") else 0
	if done < 0:
		return
	guide.tip = {}
	guide.tip_set = false
	if done > 0:
		guide.next_step(found)




func _special_quest() -> void :
	if not bool(host.guide_open("questWindow")) or not bool(host.get("_primed")):
		_picked = ""
		_pick_seen = -1
		return
	var pick: int = int(host.get("_pick"))
	if _pick_seen >= 0 and pick != _pick_seen and not guide.last_complete.is_empty() and int(guide.last_complete["quest"]) != pick:
		guide.release_normal()
	_pick_seen = pick
	if _busy():
		return
	if not guide.closing.is_empty():
		var ui: String = guide.closing
		guide.closing = ""
		if ui == "questWindow":
			host.guide_close(ui)
			return
	if guide.award != 0:
		if not bool(host.guide_select(guide.award)):
			return
		guide.show_award()
		_picked = _key(guide.tip) if not guide.tip.is_empty() else ""
		_pick_seen = int(host.get("_pick"))
		return
	var found: Dictionary = guide.tip
	if found.is_empty() or str(found["ui"]) != "questWindow":
		_picked = ""
		return
	if _picked != _key(found):
		if not bool(host.guide_select(int(found["quest"]))):
			return
		_picked = _key(found)
		_pick_seen = int(host.get("_pick"))
	if str(found["button"]) != "close":
		return
	guide.tip = {}
	guide.tip_set = false
	_picked = ""
	host.guide_close("questWindow")

	guide.set_guide_quest(int(found["quest"]), int(found["state"]), int(found["step"]))
	guide.next_step(found)


func _special_crystal() -> void :
	var found: Dictionary = guide.tip
	if str(found["ui"]) != "crystalWindow" or str(found["button"]) != "close" or _busy():
		return
	guide.tip = {}
	guide.tip_set = false
	if host.has_method("guide_close"):
		host.guide_close("crystalWindow")
	guide.set_guide_quest(int(found["quest"]), int(found["state"]), int(found["step"]))
	guide.next_step(found)


func _busy() -> bool:
	if bool(host.get("covered")):
		return true
	if kind == "arena" and ( not str(host.get("_sheet_id")).is_empty() or bool(_client().is_pairing())):
		return true
	var main: Node = host.get_parent()
	if main == null:
		return false

	var past_host: bool = false
	var past_pop: bool = false
	var pop_before: bool = false
	for child: Node in main.get_children():
		if child == host:
			past_host = true
			past_pop = pop_before
		elif not past_host and "popping" in child:
			pop_before = true
		elif past_host and not past_pop and "popping" in child:
			past_pop = true
			if not str(child.get("popping")).is_empty():
				return true
		elif past_pop and child is CanvasItem and (child as CanvasItem).visible:
			return true
	return false

func _scale() -> float:
	return maxf(0.01, float(host.get("_f")))



func _rect(id: String) -> Rect2:
	var found: Rect2 = Rect2()
	var any: bool = false
	for hit: Array in host.get("_hits"):
		if str(hit[0]) != id:
			continue
		var piece: Rect2 = hit[1]
		if not any:
			found = piece
			any = true
		elif found.grow(1.0).intersects(piece):
			found = found.merge(piece)
	return found


func _target(row: Dictionary) -> String:
	var table: Dictionary = HOSTS.get(kind, {}).get(str(row["ui"]), {})
	var button: String = str(row["button"])
	if not table.has(button):
		return ""
	if host.has_method("guide_open") and not bool(host.guide_open(str(row["ui"]))):
		return ""
	if button == "loginReward" and not NewbieLogin.cleared(_client()) and _rect("event:newbie").has_area():
		return "event:newbie"
	return str(table[button])

func _set_block(on: bool) -> void :
	mouse_filter = Control.MOUSE_FILTER_STOP if on else Control.MOUSE_FILTER_IGNORE

func _has_point(point: Vector2) -> bool:
	if _box_on:
		return true
	if _tip_on and bool(guide.tip.get("modal", false)):
		return not _hole.has_point(point)
	return false

func _draw() -> void :
	_box_on = false
	_tip_on = false
	if guide == null or host == null or not host.is_visible_in_tree():
		_set_block(false)
		return
	var busy: bool = _busy()
	if guide.pending != 0 and not busy:
		_draw_box()
		_box_on = true
	elif not guide.tip.is_empty() and not busy and not guide.direct_open:
		_draw_tip()
	_set_block(_box_on or (_tip_on and bool(guide.tip.get("modal", false))))



func _draw_tip() -> void :
	var row: Dictionary = guide.tip
	var id: String = _target(row)
	if id.is_empty():
		return
	var rect: Rect2 = _rect(id)
	var live: bool = true
	if not rect.has_area() and host.has_method("guide_spot"):
		rect = host.guide_spot(id)
		live = false
	if rect.size == Vector2.ZERO:
		return
	if bool(row["modal"]) and not guide.tip_set:
		guide.tip_set = true
		guide.set_guide_quest(int(row["quest"]), int(row["state"]), int(row["step"]))
	if int(row["delay"]) > 0 and _time - _tip_from >= float(row["delay"]) / 1000.0:
		_end_tip.call_deferred()
		return
	_tip_on = true
	_hole = rect
	_hole_live = live
	var f: float = _scale()
	if bool(row["modal"]):
		var dim: Color = Color(0, 0, 0, float(Atlas.DIM["modal"]))
		draw_rect(Rect2(0, 0, size.x, rect.position.y), dim)
		draw_rect(Rect2(0, rect.end.y, size.x, size.y - rect.end.y), dim)
		draw_rect(Rect2(0, rect.position.y, rect.position.x, rect.size.y), dim)
		draw_rect(Rect2(rect.end.x, rect.position.y, size.x - rect.end.x, rect.size.y), dim)
	var comp: Rect2 = Rect2(rect.position / f, rect.size / f)
	var arrow: String = str(row["arrow"]) if str(row["arrow"]) in ["up", "left", "right"] else "down"
	var at: Vector2 = tip_origin(comp, arrow)
	var spot: Vector2 = Vector2.ZERO
	match arrow:
		"up":
			spot = Vector2(TIP / 2.0, - comp.size.y / 2.0)
		"down":
			spot = Vector2(TIP / 2.0, TIP + comp.size.y / 2.0)
		"left":
			spot = Vector2( - comp.size.x / 2.0, TIP / 2.0)
		"right":
			spot = Vector2(TIP + comp.size.x / 2.0, TIP / 2.0)
	var focus: int = _focus_frame(_time - _tip_from)
	if focus >= 0:
		var stage: Array = _stage("focus")
		_film("focus", focus, at + spot - Vector2(float(stage[0]), float(stage[1])) / 2.0)
	var help: Array = Atlas.HELP[arrow]
	_film(arrow, int((_time - _tip_from) * float(Atlas.FX_FPS)), at + Vector2(float(help[0]), float(help[1])), true)
	var text: String = str(row["tip"])
	if not text.is_empty():
		var place: Array = TIP_TEXT[arrow]
		_words(text, BOLD, float(Atlas.HELP["size"]), TIP_COLOR, str(place[0]), at + Vector2(float(place[1]), float(place[2])), TIP_RIM, 4.0)


static func tip_origin(comp: Rect2, arrow: String) -> Vector2:
	var gap: float = float(Atlas.HELP_GAP)
	match arrow:
		"up":
			return Vector2(comp.get_center().x - TIP / 2.0, comp.end.y + gap)
		"left":
			return Vector2(comp.end.x + gap, comp.get_center().y - TIP / 2.0)
		"right":
			return Vector2(comp.position.x - TIP - gap, comp.get_center().y - TIP / 2.0)
	return Vector2(comp.get_center().x - TIP / 2.0, comp.position.y - TIP - gap)


static func _focus_frame(elapsed: float) -> int:
	var count: int = int(Atlas.FX[0][1])
	var run: float = float(count) / float(Atlas.FX_FPS)
	var cycle: float = run + float(Atlas.FOCUS_REPLAY)
	var inside: float = fmod(maxf(0.0, elapsed), cycle)
	return int(inside * float(Atlas.FX_FPS)) if inside < run else -1

func _end_tip() -> void :
	if guide != null and not guide.tip.is_empty():
		guide.finish_tip()

func _input(event: InputEvent) -> void :
	if not _tip_on or _box_on or not event is InputEventMouseButton or event.button_index != MOUSE_BUTTON_LEFT:
		return
	var local: Vector2 = (make_input_local(event) as InputEventMouseButton).position
	if event.pressed:
		_press_hole = _hole.has_point(local)
	elif _press_hole:
		_press_hole = false

		if _hole_live and _hole.has_point(local) and (int(guide.tip.get("delay", 0)) <= 0 or not bool(guide.tip.get("modal", false))):
			_end_tip.call_deferred()

func _gui_input(event: InputEvent) -> void :
	if _box_on:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			if _music.has_point(event.position):
				Settings.put("music", not Settings.on("music"))
			elif _button_shown():
				_box_click()
		accept_event()
	elif _tip_on and bool(guide.tip.get("modal", false)):
		accept_event()



func _button_shown() -> bool:
	var row: Dictionary = Guide.direct_row(_box_id)
	var wait: float = float(Atlas.TYPE[1]) / float(Atlas.FX_FPS)
	if str(row.get("frame_state", "")) == "GuideQuestComplete":
		wait += float(Atlas.REWARD_DELAY) / 1000.0
	return _time - _box_from >= wait


func _box_click() -> void :
	Sound.click()
	var next: int = guide.direct_click(_box_id)
	if next != 0:
		guide.pending = next
		return
	guide.pending = 0
	guide.direct_open = false
	guide.check.call_deferred()


func box_text(id: int) -> String:
	var text: String = str(Guide.direct_row(id).get("content", ""))
	var at: int = text.find("#n#")
	if at >= 0:
		text = text.substr(0, at) + "\n" + text.substr(at + 3)
	at = text.find("#name#")
	if at >= 0:
		var who: String = str(_client().character.get("name", ""))
		text = text.substr(0, at) + who + text.substr(at + 6)
	return text

func _draw_box() -> void :
	var row: Dictionary = Guide.direct_row(_box_id)
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, float(Atlas.DIM["direct"])))
	var f: float = _scale()
	var wide: float = floorf(size.x / f + 0.01)
	var high: float = floorf(size.y / f + 0.01)
	var base: Vector2 = Vector2(roundf((wide - float(Atlas.FRAME[0])) / 2.0), roundf((high - float(Atlas.FRAME[1])) / 2.0))
	var elapsed: float = _time - _box_from
	var frame: int = int(elapsed * float(Atlas.FX_FPS))
	var image: String = str(row.get("image", ""))
	if Atlas.IMAGES.has(image):
		var key: String = str(Atlas.IMAGES[image])
		var count: int = _count(key)
		var index: int = frame
		if key.ends_with("_tianqi") and index > int(Atlas.TIANQI_LOOP[1]):
			index = int(Atlas.TIANQI_LOOP[0]) + (index - int(Atlas.TIANQI_LOOP[0])) % (int(Atlas.TIANQI_LOOP[1]) - int(Atlas.TIANQI_LOOP[0]) + 1)
		elif count > 0:
			index = mini(index, count - 1) if count == 1 else index % count
		_film_key(key, index, base + Vector2(float(Atlas.CENTER[0]), float(Atlas.CENTER[1])))
	_film("jiaoguan", frame, base + Vector2(float(Atlas.JIAOGUAN[0]), float(Atlas.JIAOGUAN[1])), true)
	_cell("gda_guide_bubble", base + Vector2(float(Atlas.BUBBLE[0]), float(Atlas.BUBBLE[1])))
	var music: Array = Atlas.MUSIC
	_music = Rect2((base + Vector2(float(music[0]), float(music[1]))) * f, Vector2(float(music[2]), float(music[3])) * f)
	_cell("gda_guide_music_on" if Settings.on("music") else "gda_guide_music_off", base + Vector2(float(music[0]), float(music[1])))
	var label: Array = Atlas.NAME
	_words(str(label[5]), BOLD, float(label[2]), Color(str(label[3])), "l", base + Vector2(float(label[0]), float(label[1]) + 2.0 + float(label[2]) * 0.55), 
		Color(str(label[4])), 3.0)
	if frame >= int(Atlas.TYPE[0]):
		var body: Array = Atlas.TEXT
		var font_size: int = maxi(6, roundi(float(body[3]) * f))
		draw_multiline_string(BOLD, (base + Vector2(float(body[0]), float(body[1]) + 2.0)) * f + Vector2(0, BOLD.get_ascent(font_size)), box_text(_box_id), 
			HORIZONTAL_ALIGNMENT_LEFT, float(body[2]) * f, font_size, -1, Color(str(body[4])))
	if _button_shown():
		var button: Array = Atlas.BUTTON
		var text: String = str(row.get("button", ""))
		if text.is_empty():
			text = str(Atlas.CONTINUE)
		var middle: Vector2 = base + Vector2(float(button[0]), float(button[1]) + 2.0 + float(button[2]) * 0.55)
		var width: float = _words(text, BOLD, float(button[2]), Color(str(button[3])), "r", middle, Color(0, 0, 0, 0), 0.0)
		var line_y: float = (middle.y + float(button[2]) * 0.5) * f
		draw_line(Vector2((middle.x - width) * f, line_y), Vector2(middle.x * f, line_y), Color(str(button[3])), maxf(1.0, f))
		_film("mouse", frame, base + Vector2(float(Atlas.MOUSE_TIP[0]), float(Atlas.MOUSE_TIP[1])), true)



func _cell(name: String, at: Vector2) -> void :
	var region: Array = Atlas.R.get(name, [])
	if _tex == null or region.is_empty():
		return
	var f: float = _scale()
	draw_texture_rect_region(_tex, Rect2(at * f, Vector2(float(region[2]), float(region[3])) * f), Rect2(region[0], region[1], region[2], region[3]))


func _words(text: String, font: Font, px: float, color: Color, align: String, at: Vector2, rim: Color, edge: float) -> float:
	var f: float = _scale()
	var font_size: int = maxi(6, roundi(px * f))
	var width: float = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var origin: Vector2 = at * f
	if align == "c":
		origin.x -= width / 2.0
	elif align == "r":
		origin.x -= width
	origin.y += (font.get_ascent(font_size) - font.get_descent(font_size)) / 2.0
	if edge > 0.0 and rim.a > 0.0:
		draw_string_outline(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, maxi(1, roundi(edge * f)), rim)
	draw_string(font, origin, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)
	return width / f

func _stage(film: String) -> Array:
	var key: String = str(FILM[film])
	for fx: Array in Atlas.FX:
		if str(fx[0]) == key:
			return fx[2]
	return [0, 0]

func _count(key: String) -> int:
	for fx: Array in Atlas.FX:
		if str(fx[0]) == key:
			return int(fx[1])
	return 0

func _film(film: String, frame: int, at: Vector2, loop: bool = false) -> void :
	var key: String = str(FILM[film])
	var count: int = _count(key)
	if loop and count > 0:
		frame = frame % count
	_film_key(key, frame, at)


func _film_key(key: String, index: int, at: Vector2) -> void :
	var pack: Node = host.get("pack")
	if pack == null:
		return
	var fx: Dictionary = pack.effect_cached(key)
	if fx.is_empty():
		pack.effect(key)
		return
	var frames: Array = fx.get("data", {}).get("frames", [])
	var pages: Array = fx.get("pages", [])
	if index < 0 or index >= frames.size():
		return
	var cell: Dictionary = frames[index]
	var page: int = int(cell.get("page", 0))
	if page >= pages.size() or pages[page] == null:
		return
	var rect: Array = cell.get("rect", [0, 0, 0, 0])
	var pivot: Array = cell.get("pivot", [0, 0])
	var f: float = _scale()
	var src: Rect2 = Rect2(float(rect[0]), float(rect[1]), float(rect[2]), float(rect[3]))
	draw_texture_rect_region(pages[page], Rect2((at - Vector2(float(pivot[0]), float(pivot[1]))) * f, src.size * f), src)
