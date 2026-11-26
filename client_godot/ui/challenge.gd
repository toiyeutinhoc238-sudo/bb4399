extends "flash_screen.gd"












const Kc = preload("challenge_atlas.gd")
const Hall = preload("hall_atlas.gd")
const Guild = preload("guild_atlas.gd")
const FriendsAtlas = preload("friends_atlas.gd")
const GarageModel = preload("garage_model.gd")
const TankPortrait = preload("tank_portrait.gd")
const BagModel = preload("bag_model.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const Movie = preload("challenge_movie.gd")

signal closed
signal player_info_asked(uuid: String)

const SHOW_IN: Array = ["lobby", "hall"]
const DIM: Color = Color(0, 0, 0, 0.4)
const ASK_SIZE: Vector2 = Vector2(450, 220)
const BAR: float = 19.0
const LINE: float = 16.0
const SHOWN: int = 6
const RIM_CARD: Color = Color("005391", 0.8)
const RIM_BLUE: Color = Color("005797", 0.8)
const RIM_TIME: Color = Color("086da5", 0.8)
const RIM_VIP: Color = Color("005683", 0.8)
const RIM_HISTORY: Color = Color("1a4698")
const RIM_RANK: Color = Color("017ac3", 0.8)
const VIP_INK: Color = Color("fffc00")
const NAME_INK: Color = Color("ffba00")
const WIN_INK: Color = Color("9af91e")
const LOSE_INK: Color = Color("ff4b4b")
const RANK_INK: Color = Color("ffff00")
const FRIEND_SELF: String = "Không thể kết bạn với chính mình"
const BUSY: String = "Đang xử lý…"
const NOT_SENT: String = "Chưa gửi được, hãy thử lại."
const SILVER_NAME: String = "Bạc"
var _ctip: CTip = CTip.new()
var _ctip_hit: bool = false

var _ask: String = ""
var _ask_text: String = ""
var _fight: Dictionary = {}
var _result: Dictionary = {}
var _movie: Control = null
var _pending: Dictionary = {}
var _award_rev: int = -1
var _friended: Dictionary = {}
var _befriend: String = ""
var _first: int = 0
var _lines: Array = []
var _lines_key: String = ""
var _list_rect: Rect2 = Rect2()
var _grab: bool = false
var _grab_at: Vector2 = Vector2.ZERO
var _grab_first: int = 0
var _pull: float = 0.0
var _behind: bool = false

func _setup() -> void :
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	_use(Hall.FILE, Hall.R)
	_use(Guild.FILE, Guild.R)
	var ask: Dictionary = {}
	for key: String in FriendsAtlas.R:
		if key.begins_with("fr_ask"):
			ask[key] = FriendsAtlas.R[key]
	_use(FriendsAtlas.FILE, ask)
	_use(Kc.FILE, Kc.R)
	if client == null:
		return
	client.challenge_result.connect(_on_result)
	client.changed.connect(_follow)
	client.friend_result.connect( func(_ok: bool, text: String) -> void :
		if not _befriend.is_empty():
			_befriend = ""
			if is_visible_in_tree():
				say(text))




func open() -> void :
	if client == null or client.state not in SHOW_IN:
		return
	_reset()
	visible = true
	if pack != null:
		pack.load_garage()
		pack.load_bag()
		Movie.warm(pack, [int(client.character.get("avatarId", 0))])
	if not client.challenge_open():
		say(NOT_SENT)

func close() -> void :
	if not visible:
		return
	visible = false
	_reset()
	closed.emit()


func back_from_board() -> void :
	if not _behind:
		return
	_behind = false
	if client != null and client.state in SHOW_IN:
		visible = true
	else:
		_reset()
		closed.emit()


func chat_busy() -> bool:
	return visible

func asking() -> String:
	return _ask

func result() -> Dictionary:
	return _result


func movie() -> Control:
	return _movie

func _reset() -> void :
	_behind = false
	_ask = ""
	_ask_text = ""
	_fight = {}
	_result = {}
	_pending = {}
	_stop_movie()
	_award_rev = -1
	_first = 0
	_grab = false
	_pull = 0.0
	_hover = ""
	_press = ""


func _follow() -> void :
	if not visible:
		return
	if client.state not in SHOW_IN:
		close()
		return
	if not _fight.is_empty() and client.challenge_rev != int(_fight.rev):
		_fight = {}



func _on_result(info: Dictionary) -> void :
	if not visible or _fight.is_empty():
		return
	var enemy: Dictionary = _fight.enemy
	var win: bool = bool(info.get("win", false))
	var rank: int = int(enemy.get("rank", 0))
	_pending = {"win": win, "silver": int(info.get("silver", 0)), "items": info.get("items", []), "enemy": enemy, "self": _fight.self, 
		"up": rank if win and int(_fight.rank) > rank else 0}
	_fight = {}
	_ask = ""
	_stop_movie()
	_movie = Movie.new()
	_movie.pack = pack
	_movie.win = win
	_movie.mine = _pending.self
	_movie.theirs = enemy
	add_child(_movie)
	_place_movie()
	Sound.play(Movie.SOUND)


func _end_movie() -> void :
	if _movie == null:
		return
	_stop_movie()
	_result = _pending
	_pending = {}
	client.challenge_open()

func _stop_movie() -> void :
	if _movie != null:
		remove_child(_movie)
		_movie.queue_free()
		_movie = null

func _place_movie() -> void :
	_movie.place(_centre(Movie.WIDE, Movie.HIGH) * _f, _f)

func _tick(delta: float) -> void :
	if _movie == null:
		return
	_movie.time += delta
	if _movie.done():
		_end_movie()
	else:
		_place_movie()



static func _v(spec: Array) -> Vector2:
	return Vector2(float(spec[0]), float(spec[1]))

static func _word(key: String, num: Variant = null) -> String:
	var text: String = str(Kc.WORDS.get(key, ""))
	return text if num == null else text.replace("@num1@", str(num))


static func win_rate(mine: int, theirs: int) -> float:
	var k: float = maxf(2.0, float(maxi(mine, theirs)) / 2250.0)
	var d: float = (float(theirs) / k - float(mine) / k) / 400.0
	return 100.0 / (1.0 + pow(10.0, d))


static func judge(rate: float) -> Array:
	var key: String = "judge_389"
	for row: Array in [[1.0, "judge_383"], [35.0, "judge_384"], [45.0, "judge_385"], [60.0, "judge_386"], [90.0, "judge_387"], [95.0, "judge_388"]]:
		if rate <= float(row[0]):
			key = str(row[1])
			break
	var ink: Color = Color("ff0000") if rate <= 1.0 else (Color("ffae00") if rate <= 45.0 else Color("00ff00"))
	return [_word(key), ink]


static func award_left(now: int) -> int:
	var left: int = 86400 - (now + 25200) % 86400
	return left + 72000 if left < 14400 else left - 14400

static func clock(seconds: int) -> String:
	seconds = maxi(0, seconds)
	return "%02d:%02d:%02d" % [seconds / 3600, seconds / 60 % 60, seconds % 60]


static func age(seconds: int) -> String:
	if seconds < 600:
		return _word("just_now")
	if seconds < 3600:
		return _word("minutes").replace("@time@", str(seconds / 60))
	if seconds < 86400:
		return _word("hours").replace("@time@", str(seconds / 3600))
	return _word("days").replace("@time@", str(mini(20, seconds / 86400)))


static func history_parts(row: Dictionary, now: int) -> Array:
	var result: int = int(row.get("result", 0))
	var attacker: bool = result in [1, 2, 5]
	var win: bool = result in [1, 3, 5]
	var lead: String = _word("you_hit" if attacker else "hit_you").replace("@time@", age(now - int(row.get("time", 0))))
	var parts: Array = []
	var cut: int = lead.find("@name@")
	if cut < 0:
		parts.append([lead, Color.WHITE])
	else:
		parts.append([lead.left(cut), Color.WHITE])
		parts.append([str(row.get("enemy", "")), NAME_INK])
		parts.append([lead.substr(cut + 6), Color.WHITE])
	parts.append([" ", Color.WHITE])
	parts.append([_word("you_win" if win else "you_lose"), WIN_INK if win else LOSE_INK])
	parts.append([" ", Color.WHITE])
	var tail: String = _word("rank_rise" if result == 1 else ("rank_fall" if result == 4 else "rank_keep"))
	var spot: int = tail.find("@num1@")
	if spot < 0:
		parts.append([tail, Color.WHITE])
	else:
		parts.append([tail.left(spot), Color.WHITE])
		parts.append([str(int(row.get("rank", 0))), RANK_INK])
		parts.append([tail.substr(spot + 6), Color.WHITE])
	return parts.filter( func(part: Array) -> bool: return not str(part[0]).is_empty())


func _me() -> Dictionary:
	var tank: Dictionary = client.current_tank()
	var helper: int = 0
	for inst: Dictionary in client.bags.get(5, []):
		if not client.battle_helper.is_empty() and str(inst.get("m_itemUuid", "")) == client.battle_helper:
			helper = int(inst.get("m_templateId", 0))
	return {"oid": client.account_id, "uuid": str(client.account_id), "name": str(client.character.get("name", "")), 
		"avatar": int(client.character.get("avatarId", 0)), "item": helper, "tank_id": int(tank.get("m_tpltId", 0)), 
		"tank_level": int(tank.get("m_level", 1)), "external": int(tank.get("m_externalId", 0)), "halo": int(tank.get("m_haloId", 0)), 
		"atk": int(client.challenge.get("atk", 0)), "rank": int(client.challenge.get("rank", 0))}

func _is_friend(nick: String) -> bool:
	if _friended.has(nick):
		return true
	for uuid: String in client.friends:
		if str((client.friends[uuid] as Dictionary).get("m_name", "")) == nick:
			return true
	return false


func _item(item: int) -> Array:
	if pack == null or item <= 0:
		return ["", ""]
	var more: Array = pack.bag.get("more", {}).get(str(item), [])
	if more.size() >= 4 and not str(more[1]).is_empty():
		return ["l/it/%s.webp" % str(more[1]), BagModel.clean(str(more[0]))]
	var row: Array = pack.bag.get("items", {}).get(str(item), [])
	if row.size() >= 10:
		return [("l/av/" if int(row[5]) == 4 else "l/it/") + str(row[2]) + ".webp", str(row[0])]
	return ["", ""]

func _picture(path: String) -> Texture2D:
	return pack.picture(path) if pack != null and not path.is_empty() else null

func _head(avatar: int) -> Texture2D:
	if pack == null:
		return null
	var key: String = str(pack.lobby.get("avatars", {}).get(str(avatar), ""))
	return pack.picture("l/h/%s.webp" % key) if not key.is_empty() else null

func _tank_name(tank_id: int) -> String:
	if pack == null:
		return ""
	return GarageModel.cap(str(pack.lobby.get("tanks", {}).get(str(tank_id), "")))



func _paint() -> void :
	_ctip_hit = false
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var frame: Vector2 = Vector2(float(Kc.FRAME[0]), float(Kc.FRAME[1]))
	var at: Vector2 = _centre(frame.x, frame.y)
	_hit("panel", Rect2(at * _f, frame * _f), false)
	_fblit("kc_frame", at + _v(Kc.BODY))
	var data: Dictionary = client.challenge if client != null else {}
	var enemies: Array = data.get("enemies", [])
	for i: int in mini(enemies.size(), Kc.CARDS.size()):
		_draw_card(enemies[i], at + _v(Kc.CARDS[i]), "c%d" % i, "list", data)
	_draw_side(at, data)
	_draw_reward(at, data)
	_fbutton("watch", "kc_watch", at + _v(Kc.AT["btnWatchRank"]))
	_draw_history(at, data)
	_fbutton("close", "kc_close", at + _v(Kc.AT["btnClose"]))
	if _result.is_empty() and _ask.is_empty() and _movie == null:
		_draw_tips(at, data)
	if not _result.is_empty():
		_draw_result(data)
	if not _ask.is_empty():
		_paint_ask()
	if _movie != null:

		draw_rect(Rect2(Vector2.ZERO, size), DIM)
		_hit("shade", Rect2(Vector2.ZERO, size), false)
		_hit("panel", Rect2(_centre(Movie.WIDE, Movie.HIGH) * _f, Vector2(Movie.WIDE, Movie.HIGH) * _f), false)
	if not _ctip_hit:
		_ctip.draw(self, "", "", get_local_mouse_position() / _f, Vector2(_fw, _fh), _f)


func _draw_card(card: Dictionary, base: Vector2, key: String, mode: String, data: Dictionary) -> void :
	_fblit("kc_card", base + _v(Kc.CARD_BODY))
	var oid: int = int(card.get("oid", 0))
	var mine: bool = mode == "self" or oid == client.account_id
	var nick: String = str(card.get("name", ""))
	_hfit(_head(int(card.get("avatar", 0))), base + _v(Kc.CARD_AT["imgHead"]), Vector2(60, 60))

	if oid != 0:
		var only_info: bool = mode == "self" or _is_friend(nick)
		_fblit("kc_btnbk_ss" if only_info else "kc_btnbk", base + _v(Kc.CARD_AT["imgBg"]))
		if not only_info:
			_fbutton(key + ":add", "kc_add", base + _v(Kc.CARD_AT["btnAddFriend"]))
		_fbutton(key + ":info", "kc_info", base + _v(Kc.CARD_AT["btnPlayerInfo"]))
	var spec: Array = Kc.CARD_TEXTS["lblPlayerName"]
	_fwords(_cut(nick, BOLD, float(spec[4]), float(spec[2])), BOLD, float(spec[4]), Color.WHITE, "l", base + _v(spec), float(spec[2]), 
		1.5, 0.0, false, RIM_CARD)
	_draw_tank_row(card, base)
	_hfit(_picture(str(_item(int(card.get("item", 0)))[0])), base + _v(Kc.CARD_AT["imgHelper"]), Vector2(100, 100))
	_draw_tank(card, base + Vector2(27, 87), 0.25)
	spec = Kc.CARD_TEXTS["lblGeneralScore"]
	_fwords(_word("power_of", int(card.get("atk", 0))), BOLD, float(spec[4]), Color.WHITE, "c", base + _v(spec), float(spec[2]), 1.5, 0.0, 
		true, RIM_BLUE)
	var rank: int = int(card.get("rank", 0))
	if rank >= 1 and rank <= 5:
		var name: String = "kc_rank_%d" % rank
		_fblit(name, base + _v(Kc.CARD_AT["rank"]) - (_cell_size(name) / 2.0).round())
	elif rank > 5:
		spec = Kc.CARD_TEXTS["lblRank"]
		_fwords(_word("rank_of", rank), BOLD, float(spec[4]), Color.WHITE, "c", base + _v(spec), float(spec[2]), 1.5, 0.0, true, RIM_BLUE)
	if mine:
		return
	spec = Kc.CARD_TEXTS["lblJudge"]
	var said: Array = judge(win_rate(int(data.get("atk", 0)), int(card.get("atk", 0))))
	_fwords(str(said[0]), BOLD, float(spec[4]), said[1], "c", base + _v(spec), float(spec[2]), 1.5, 0.0, true, RIM_BLUE)
	if mode == "list":
		_fblit("kc_btn_bg", base + _v(Kc.CARD_AT["imgChallengeBtnBg"]))
		_fbutton(key + ":fight", "kc_challenge", base + _v(Kc.CARD_AT["btnChallenge"]))


func _draw_tank_row(card: Dictionary, base: Vector2) -> void :
	var badge: String = "tklv_%d" % clampi(int(card.get("tank_level", 1)), 1, 11)
	var mark: Vector2 = _cell_size(badge) * 0.75
	var title: String = _tank_name(int(card.get("tank_id", 0)))
	var face: Font = _face(BOLD)
	var text_w: float = face.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(12.0 * _f))).x / _f + 4.0
	var wide: float = maxf(text_w, mark.x)
	var left: Vector2 = base + Vector2(roundf(105.0 - wide / 2.0), 74)
	_fblit(badge, left, mark.x, mark.y)
	if not title.is_empty():
		_fwords(title, BOLD, 12.0, Color.WHITE, "l", left + Vector2(-1, 14), text_w, 1.5, 0.0, false, RIM_CARD)


func _draw_tank(card: Dictionary, centre: Vector2, zoom: float) -> void :
	var tank_id: int = int(card.get("tank_id", 0))
	if tank_id <= 0 or pack == null or pack.state != "ready" or pack.garage.is_empty():
		return
	var level: int = maxi(1, int(card.get("tank_level", 1)))
	var ext: int = int(card.get("external", 0))
	if ext <= 0:
		ext = GarageModel.exterior(pack.garage, pack.index.get("tanks", {}), tank_id, level, {})
	var item: int = TankPortrait.halo_item(pack.fx.get("halo_ui", {}), int(card.get("halo", 0)), level)
	TankPortrait.draw(self, pack, GarageModel.face(pack.garage, ext), item, centre * _f, zoom * _f, _time)


func _draw_side(at: Vector2, data: Dictionary) -> void :
	var loaded: bool = client.challenge_loaded
	var spec: Array = Kc.TEXTS["lblRank"]
	if loaded:
		_fwords(_word("my_rank", int(data.get("rank", 0))), BOLD, float(spec[4]), Color.WHITE, "c", at + _v(spec), float(spec[2]), 1.5, 0.0, 
			true, RIM_BLUE)
		spec = Kc.TEXTS["lblChanllengeTime"]
		_fwords(str(int(data.get("count", 0))), BOLD, float(spec[4]), Color.WHITE, "l", at + _v(spec), 36.0, 1.5, 0.0, false, RIM_TIME)
	_fbutton("buy", "kc_buy", at + _v(Kc.AT["btnBuyChallenge"]))
	var rows: Array = [["_ChallengeFrame_Label3", "cool", "lblCoolTime"], ["_ChallengeFrame_Label6", "power", "lblGeneralScore"], 
		["_ChallengeFrame_Label8", "streak", "lblWinninStreak"]]
	var now: int = int(Time.get_unix_time_from_system())
	for row: Array in rows:
		spec = Kc.TEXTS[str(row[0])]
		_fwords(_word(str(row[1])), BOLD, float(spec[4]), Color.WHITE, "r", at + _v(spec) - Vector2(120, 0), 120.0, 1.5, 0.0, false, RIM_BLUE)
		if not loaded:
			continue
		var value: String = ""
		match str(row[2]):
			"lblCoolTime":
				var left: int = maxi(0, int(data.get("cool", 0)) - now)
				value = "%02d:%02d" % [left / 60, left % 60]
			"lblGeneralScore":
				value = str(int(data.get("atk", 0)))
			"lblWinninStreak":
				value = str(int(data.get("seq_win", 0)))
		spec = Kc.TEXTS[str(row[2])]

		_fwords(value, BOLD, float(spec[4]), Color.WHITE, "l", at + _v(spec) + Vector2(6, 0), float(spec[2]), 1.5, 0.0, false, RIM_BLUE)

	spec = Kc.TEXTS["lblVipTip"]
	var ink: Color = VIP_INK * Color(_shine("vip"), _shine("vip"), _shine("vip"), 1.0)
	var spot: Vector2 = at + _v(spec)
	var wide: float = _fwords(_word("vip_free"), BOLD, float(spec[4]), ink, "l", spot, 90.0, 1.5, 0.0, false, RIM_VIP)
	var base_y: float = spot.y + 2.0 + float(spec[4]) * 1.1
	draw_line(Vector2(spot.x + 2.0, base_y) * _f, Vector2(spot.x + 2.0 + wide, base_y) * _f, ink, maxf(1.0, _f))
	_hit("vip", Rect2(spot * _f, Vector2(wide + 4.0, float(spec[4]) + 6.0) * _f), false)
	var help: Array = Kc.AT["imgScoreHelp"]
	_hit("help", Rect2((at + _v(help)) * _f, Vector2(float(help[2]), float(help[3])) * _f), false)


func _draw_reward(at: Vector2, data: Dictionary) -> void :
	if bool(data.get("yesterday", {}).get("has", false)):
		_fblit("kc_got_bg", at + _v(Kc.AT["imgGetReward"]))
		_fbutton("get", "kc_get", at + _v(Kc.AT["btnGetReward"]))
		return
	_hit("box", _fblit("kc_reward_box", at + _v(Kc.AT["imgReward"])), false)
	var spec: Array = Kc.TEXTS["txtAwardTime"]
	var spot: Vector2 = at + _v(spec)
	var wide: float = float(spec[2])
	_fwords(_word("award_time"), BOLD, float(spec[4]), Color.WHITE, "c", spot, wide, 1.5, 0.0, true, RIM_BLUE)
	_fwords(clock(award_left(int(Time.get_unix_time_from_system()))), BOLD, float(spec[4]), Color.WHITE, "c", spot + Vector2(0, 15), wide, 
		1.5, 0.0, true, RIM_BLUE)


func _draw_history(at: Vector2, data: Dictionary) -> void :
	var spec: Array = Kc.TEXTS["txtHistory"]
	var box: Rect2 = Rect2(at + _v(spec), Vector2(float(spec[2]), float(spec[3])))
	_list_rect = Rect2(box.position * _f, box.size * _f)
	var now: int = int(Time.get_unix_time_from_system())
	var key: String = "%d:%.3f:%d" % [client.challenge_rev, _f, now / 60]
	if key != _lines_key:
		_lines_key = key
		_lines = _wrap_history(data.get("history", []), now, box.size.x - 6.0)
		if _lines.size() > SHOWN:
			_lines = _wrap_history(data.get("history", []), now, box.size.x - BAR - 6.0)
		_scroll(_first)
	for i: int in range(_first, mini(_lines.size(), _first + SHOWN)):
		var x: float = box.position.x + 2.0
		var y: float = box.position.y + 2.0 + float(i - _first) * LINE
		for run: Array in _lines[i]:
			x += _fwords(str(run[0]), REGULAR, 12.0, run[1], "l", Vector2(x, y), 400.0, 2.0, LINE, false, RIM_HISTORY)
	if _lines.size() > SHOWN:
		_vbar(Vector2(box.end.x - BAR, box.position.y), box.size.y, _lines.size(), SHOWN)


func _wrap_history(rows: Array, now: int, wide: float) -> Array:
	var face: Font = _face(REGULAR)
	var font_size: int = maxi(6, roundi(12.0 * _f))
	var lines: Array = []
	for row: Variant in rows:
		if not (row is Dictionary):
			continue
		var line: Array = []
		var used: float = 0.0
		for part: Array in history_parts(row, now):
			var words: PackedStringArray = str(part[0]).split(" ")
			for j: int in words.size():
				var token: String = words[j] + (" " if j < words.size() - 1 else "")
				if token.is_empty():
					continue
				var width: float = face.get_string_size(token.strip_edges(false, true), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f
				if used > 0.0 and used + width > wide and not token.strip_edges().is_empty():
					lines.append(line)
					line = []
					used = 0.0
				if line.is_empty() and token.strip_edges().is_empty():
					continue
				if not line.is_empty() and line[-1][1] == part[1]:
					line[-1][0] = str(line[-1][0]) + token
				else:
					line.append([token, part[1]])
				used += face.get_string_size(token, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f
		if not line.is_empty():
			lines.append(line)
	return lines

func _vbar(bar: Vector2, high: float, count: int, shown: int) -> void :
	var track: float = high - 2.0 * BAR
	_fblit("gu_sb_bk", bar + Vector2(0, BAR), BAR, track)
	_fbutton("sb:up", "gu_sb_up", bar)
	_fbutton("sb:down", "gu_sb_down", bar + Vector2(0, high - BAR))
	var most: int = maxi(0, count - shown)
	if most <= 0:
		return
	var thumb: float = maxf(20.0, track * float(shown) / float(maxi(1, count)))
	var top: float = BAR + roundf((track - thumb) * float(_first) / float(most))
	if top > BAR:
		_hit("sb:pgup", Rect2((bar + Vector2(0, BAR)) * _f, Vector2(BAR, top - BAR) * _f), false)
	if top + thumb < BAR + track:
		_hit("sb:pgdn", Rect2((bar + Vector2(0, top + thumb)) * _f, Vector2(BAR, BAR + track - top - thumb) * _f), false)
	_fslice("gu_sb_thumb", bar + Vector2(0, top), thumb, 4.0, _glow("slide:kc"))
	_hit("slide:kc", Rect2((bar + Vector2(0, top)) * _f, Vector2(BAR, thumb) * _f), false)


func _fslice(cell_name: String, at: Vector2, high: float, cap: float = 4.0, tint: Color = Color.WHITE) -> void :
	var cell: Array = _cells.get(cell_name, [])
	if cell.is_empty() or cell[0] == null:
		return
	var region: Array = cell[1]
	var src: Rect2 = Rect2(float(region[0]), float(region[1]), float(region[2]), float(region[3]))
	var wide: float = src.size.x
	var end: float = minf(cap, floorf(minf(high, src.size.y) / 2.0))
	draw_texture_rect_region(cell[0], Rect2(at * _f, Vector2(wide, end) * _f), Rect2(src.position, Vector2(wide, end)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, end)) * _f, Vector2(wide, high - 2.0 * end) * _f), 
		Rect2(src.position + Vector2(0, end), Vector2(wide, src.size.y - 2.0 * end)), tint)
	draw_texture_rect_region(cell[0], Rect2((at + Vector2(0, high - end)) * _f, Vector2(wide, end) * _f), 
		Rect2(src.position + Vector2(0, src.size.y - end), Vector2(wide, end)), tint)


func _draw_tips(at: Vector2, data: Dictionary) -> void :
	match _hover:
		"help":
			_draw_tip(_rect_of("help"), _word("score_help"))
		"buy":
			var buy: int = int(data.get("buy", 0))
			var limit: int = int(data.get("buy_limit", 0))
			var body: String = _word("buy_left", buy).replace("@num2@", str(limit)) + "\n"
			body += _word("buy_none") if buy >= limit else _word("buy_cost", 2 + 2 * buy)
			_draw_tip(_rect_of("buy"), body)
		"get", "box":
			_draw_popup(at, data)


func _draw_popup(at: Vector2, data: Dictionary) -> void :
	var yesterday: Dictionary = data.get("yesterday", {})
	var award: Array = yesterday.get("award", []) if bool(yesterday.get("has", false)) else data.get("now", [])
	if award.size() < 7:
		return
	var items: Array = []
	for pair: Array in [[award[1], award[2]], [award[3], award[4]], [award[5], award[6]]]:
		if int(pair[0]) > 0 and int(pair[1]) > 0:
			items.append(pair)
	var wide: float = float(Kc.POPUP["wide"])
	var step: float = float(Kc.POPUP["step"])
	var high: float = float(items.size() + 1) * step + 8.0
	var spot: Vector2 = at + Vector2(float(Kc.AT["frmReward"][0]), float(Kc.FRAME[1]) - 43.0 - high)
	_fround(Rect2(spot, Vector2(wide, high)), Color(0, 0, 0, 0.75), 10.0)
	var icon: Array = Kc.POPUP["icon"]
	var word: Array = Kc.POPUP["word"]
	_fblit("kc_diamond", spot + _v(icon))
	_fwords("x %d" % int(award[0]), BOLD, 12.0, Color.WHITE, "l", spot + Vector2(float(word[0]), _v(icon).y + 15.0), float(word[1]), 0.0, 
		0.0, false)
	for i: int in items.size():
		var pair: Array = items[i]
		var row: Vector2 = spot + Vector2(0, step * float(i + 1))
		var found: Array = _item(int(pair[0]))
		_hfit(_picture(str(found[0])), row + _v(icon), Vector2(float(icon[2]), float(icon[3])))
		var text: String = str(found[1]) if not str(found[1]).is_empty() else "#%d" % int(pair[0])
		if int(pair[1]) > 1:
			text += "\n x %d" % int(pair[1])
		_fpara(text, BOLD, 12.0, Color.WHITE, row + Vector2(float(word[0]), _v(icon).y + 15.0), float(word[1]), 3)


func _draw_result(data: Dictionary) -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var frame: Vector2 = Vector2(float(Kc.RESULT[0]), float(Kc.RESULT[1]))
	var base: Vector2 = _centre(frame.x, frame.y)
	_hit("panel", Rect2(base * _f, frame * _f), false)
	_fblit("kc_result", base + _v(Kc.RESULT_BODY))
	_draw_card(_result.self, base + _v(Kc.RESULT_AT["frmCardSelf"]), "rs", "self", data)
	_draw_card(_result.enemy, base + _v(Kc.RESULT_AT["frmCardEnemy"]), "re", "enemy", data)
	_fblit("kc_win" if bool(_result.win) else "kc_lose", base + _v(Kc.RESULT_AT["imgResult"]))
	var spec: Array = Kc.RESULT_TEXTS["lblNewRank"]
	var up: int = int(_result.up)
	_fwords(_word("rank_up", up) if up > 0 else _word("rank_same"), BOLD, float(spec[4]), RANK_INK, "c", base + _v(spec), float(spec[2]), 
		1.5, 0.0, true, RIM_RANK)
	spec = Kc.RESULT_TEXTS["_ChallengeRewardItemFrame_Text1"]
	_fwords(_word("won_list"), BOLD, float(spec[4]), Color.WHITE, "c", base + _v(spec) - Vector2(120, 0), 240.0, 1.5, 0.0, false)
	var tiles: Array = [[0, int(_result.silver)]]
	for pair: Variant in _result.items:
		if pair is Array and (pair as Array).size() >= 2 and tiles.size() < 3:
			tiles.append([int(pair[0]), int(pair[1])])
	var xs: Array = [[292.0], [252.0, 332.0], [212.0, 292.0, 372.0]][tiles.size() - 1]
	for i: int in tiles.size():
		_draw_tile(tiles[i], base + Vector2(float(xs[i]), 175.0), "tile:%d" % i)
	_fbutton("up_helper", "kc_up_helper", base + _v(Kc.RESULT_AT["btnUpHelper"]))
	_fbutton("go_on", "kc_continue", base + _v(Kc.RESULT_AT["btnContinue"]))
	_fbutton("result_close", "kc_close", base + _v(Kc.RESULT_AT["btnClose"]))
	if _ask.is_empty() and _hover.begins_with("tile:"):
		var index: int = int(_hover.substr(5))
		if index >= 0 and index < tiles.size():
			var id: int = int(tiles[index][0])
			if id > 0 and pack != null:
				var extra: Dictionary = {}
				if not (pack.bag.get("items", {}) as Dictionary).has(str(id)) and not str(_item(id)[1]).is_empty():
					extra = {"name": str(_item(id)[1]), "art": str(_item(id)[0]), "icon": str(_item(id)[0])}
				FlashTip.item(self, FlashTip.simulate(id, pack.bag, extra))
			else:
				_draw_box_tip(_rect_of(_hover), SILVER_NAME if id == 0 else str(_item(id)[1]))


func _draw_tile(tile: Array, spot: Vector2, id: String) -> void :
	var box: Array = Kc.TILE["tile"]
	var pic: Array = Kc.TILE["item"]
	var num: Array = Kc.TILE["num"]
	_hit(id, _fblit("kc_tile", spot + _v(box)), false)
	if int(tile[0]) == 0:
		_fblit("kc_gold", spot + _v(pic))
	else:
		_hfit(_picture(str(_item(int(tile[0]))[0])), spot + _v(pic), Vector2(float(pic[2]), float(pic[3])))
	_fwords(str(int(tile[1])), BOLD, float(num[4]), Color.WHITE, "c", spot + _v(num), float(num[2]), 1.0, 0.0, true)


func _paint_ask() -> void :
	draw_rect(Rect2(Vector2.ZERO, size), DIM)
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(ASK_SIZE.x, ASK_SIZE.y)
	_hit("panel", Rect2(at * _f, ASK_SIZE * _f), false)
	_fblit("fr_ask", at + Vector2(46, 1))
	_fblit("fr_ask_guy", at + Vector2(-80, -76))
	_fpara(_ask_text, ARIAL_BOLD, 14, Color.WHITE, at + Vector2(102, 38), 270, 5)
	_fbutton("ask_ok", "fr_ask_ok", at + Vector2(120, 133))
	_fbutton("ask_no", "fr_ask_no", at + Vector2(240, 133))


func _hfit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0, tint: Color = Color.WHITE) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false, tint)


func _draw_tip(anchor: Rect2, body: String) -> void :
	if body.is_empty() or not anchor.has_area():
		return
	_ctip_hit = true
	_ctip.draw(self, str(anchor) + body, body, get_local_mouse_position() / _f, Vector2(_fw, _fh), _f)


func _draw_box_tip(anchor: Rect2, body: String) -> void :
	if body.is_empty() or not anchor.has_area():
		return
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var high: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f + 16.0
	var spot: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if spot.x + wide > _fw:
		spot.x = anchor.position.x / _f - 6.0 - wide
	spot.y = clampf(spot.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(spot * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fpara(body, REGULAR, 12.0, Color.WHITE, spot + Vector2(10, 6), wide - 20.0, 8)

func _rect_of(id: String) -> Rect2:
	for i in range(_hits.size() - 1, -1, -1):
		if str(_hits[i][0]) == id:
			return _hits[i][1]
	return Rect2()


func _fround(rect: Rect2, fill: Color, radius: float, edge: Color = Color(0, 0, 0, 0), width: float = 0.0) -> void :
	_round(Rect2(rect.position * _f, rect.size * _f), fill, radius * 2.0, edge, width * 2.0)


func _clip(text: String, font: Font, px: float, room: float, tail: String = "") -> String:
	var face: Font = _face(font)
	var font_size: int = maxi(6, roundi(px * _f))
	if face.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
		return text
	for keep in range(text.length() - 1, 0, -1):
		var short: String = text.left(keep) + tail
		if face.get_string_size(short, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f <= room:
			return short
	return text if text.length() <= 1 else text.left(1) + tail


func _cut(text: String, font: Font, px: float, wide: float) -> String:
	return _clip(text, font, px, wide - 5.0, "...")



func _scroll(first: int) -> void :
	_first = clampi(first, 0, maxi(0, _lines.size() - SHOWN))

func _activate(id: String) -> void :
	if _movie != null:
		if id == "panel":
			_end_movie()
		return
	if not _ask.is_empty():
		match id:
			"ask_ok":
				var kind: String = _ask
				_ask = ""
				if kind == "buy":
					_buy()
				elif kind == "vip":
					_vip()
			"ask_no":
				_ask = ""
		return
	if not _result.is_empty():
		match id:
			"go_on", "result_close":
				_result = {}
			"up_helper":
				close()
				page_asked.emit("helper")
			_:
				if id.begins_with("rs:") or id.begins_with("re:"):
					_card_click(_result.self if id.begins_with("rs:") else _result.enemy, id.get_slice(":", 1))
		return
	if id.begins_with("c") and id.contains(":") and id.get_slice(":", 0).substr(1).is_valid_int():
		var enemies: Array = client.challenge.get("enemies", [])
		var index: int = int(id.get_slice(":", 0).substr(1))
		if index >= 0 and index < enemies.size():
			_card_click(enemies[index], id.get_slice(":", 1))
		return
	match id:
		"close":
			close()
		"watch":

			if not _fight.is_empty():
				return
			_behind = true
			visible = false
			page_asked.emit("board:challenge")
		"vip":
			_vip()
		"buy":
			_buy_click()
		"get":
			if _award_rev == client.challenge_rev:
				return
			if client.challenge_award():
				_award_rev = client.challenge_rev
			else:
				say(NOT_SENT)
		"sb:up":
			_scroll(_first - 1)
		"sb:down":
			_scroll(_first + 1)
		"sb:pgup":
			_scroll(_first - SHOWN)
		"sb:pgdn":
			_scroll(_first + SHOWN)

func _card_click(card: Dictionary, what: String) -> void :
	match what:
		"add":
			var nick: String = str(card.get("name", ""))
			if _add_friend(nick):
				_friended[nick] = true
		"info":
			if int(card.get("oid", 0)) > 0:
				player_info_asked.emit(str(int(card.get("oid", 0))))
		"fight":
			_fight_click(card)

func _add_friend(nick: String) -> bool:
	if nick.is_empty():
		return false
	if nick == str(client.character.get("name", "")):
		say(FRIEND_SELF)
		return false
	if client.add_friend(nick, 0):
		_befriend = nick
		return true
	say(BUSY)
	return false


func _fight_click(card: Dictionary) -> void :
	if not _fight.is_empty() or not client.challenge_loaded:
		return
	var data: Dictionary = client.challenge
	var buy: int = int(data.get("buy", 0))
	if int(data.get("count", 0)) <= 0:
		if buy >= int(data.get("buy_limit", 0)):
			say(_word("buy_limit"))
		else:
			_ask = "buy"
			_ask_text = _word("buy_out", 2 + 2 * buy)
		return
	if int(data.get("cool", 0)) - int(Time.get_unix_time_from_system()) > 0:
		_ask = "vip"
		_ask_text = _word("vip_ask")
		return
	_fight = {"enemy": card.duplicate(), "self": _me(), "rank": int(data.get("rank", 0)), "rev": client.challenge_rev}
	if not client.challenge_fight(int(card.get("rank", 0)), str(card.get("uuid", "")), int(data.get("rank", 0))):
		_fight = {}
		say(NOT_SENT)
		return
	Movie.warm(pack, [int(card.get("avatar", 0))])


func _buy_click() -> void :
	if not client.challenge_loaded:
		return
	var buy: int = int(client.challenge.get("buy", 0))
	if buy >= int(client.challenge.get("buy_limit", 0)):
		say(_word("buy_limit"))
		return
	var cost: int = 2 + 2 * buy
	if cost > _cash():
		say(_word("no_cash"))
		return
	_ask = "buy"
	_ask_text = _word("buy_ask", cost)

func _buy() -> void :
	if 2 + 2 * int(client.challenge.get("buy", 0)) > _cash():
		say(_word("no_cash"))
	elif not client.challenge_buy():
		say(NOT_SENT)


func _cash() -> int:
	return int(client.currency.get("m_iCash", 0)) + int(client.currency.get("m_iSilver", 0))

func _vip() -> void :
	close()
	page_asked.emit("events:vip")

func _wheel(step: int, at: Vector2) -> void :
	if _ask.is_empty() and _result.is_empty() and _movie == null and _list_rect.has_point(at):
		_scroll(_first + step * 3)


func _drag(moved: Vector2, from: Vector2) -> void :
	if _grab or not _ask.is_empty() or not _result.is_empty() or _movie != null or not _list_rect.has_point(from):
		return
	_pull -= moved.y
	var pitch: float = maxf(8.0, LINE * _f)
	while _pull >= pitch:
		_pull -= pitch
		_scroll(_first + 1)
	while _pull <= - pitch:
		_pull += pitch
		_scroll(_first - 1)


func _gui_input(event: InputEvent) -> void :
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_pull = 0.0
			if _hit_at(event.position) == "slide:kc":
				_grab = true
				_grab_at = event.position
				_grab_first = _first
		else:
			_grab = false
	elif event is InputEventMouseMotion and _grab:
		if (event.button_mask & MOUSE_BUTTON_MASK_LEFT) == 0:
			_grab = false
		else:
			var most: int = maxi(0, _lines.size() - SHOWN)
			if most > 0:
				var track: float = float(Kc.TEXTS["txtHistory"][3]) - 2.0 * BAR
				var thumb: float = maxf(20.0, track * float(SHOWN) / float(maxi(1, _lines.size())))
				var step: float = maxf(0.001, (track - thumb) / float(most))
				_scroll(_grab_first + roundi((event.position.y - _grab_at.y) / _f / step))
			accept_event()
			return
	super (event)

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not (event is InputEventKey and event.pressed):
		return
	if _movie != null:
		if event.keycode == KEY_ESCAPE:
			_end_movie()
		elif event.keycode not in [KEY_UP, KEY_DOWN, KEY_PAGEUP, KEY_PAGEDOWN, KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER]:
			return
		get_viewport().set_input_as_handled()
		return
	match event.keycode:
		KEY_ESCAPE:
			if not _ask.is_empty():
				_ask = ""
			elif not _result.is_empty():
				_result = {}
			else:
				close()
		KEY_UP:
			_scroll(_first - 1)
		KEY_DOWN:
			_scroll(_first + 1)
		KEY_PAGEUP:
			_scroll(_first - SHOWN)
		KEY_PAGEDOWN:
			_scroll(_first + SHOWN)
		KEY_LEFT, KEY_RIGHT, KEY_ENTER, KEY_KP_ENTER:
			pass
		_:
			return
	get_viewport().set_input_as_handled()
