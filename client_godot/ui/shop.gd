extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")
















const ShopModel = preload("shop_model.gd")
const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const Atlas = preload("shop_atlas.gd")

const NAPTIEN1_HIDE: bool = true
const Arena = preload("arena_atlas.gd")
const Hall = preload("hall_atlas.gd")
const HallScreen = preload("hall_screen.gd")
const ShopTry = preload("shop_try.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const ShopRecommend = preload("shop_recommend.gd")
const NameStyles = preload("name_styles.gd")
const Mysterious = preload("mysterious_store.gd")
const QuickAtlas = preload("quickbuy_atlas.gd")
const FriendPick = preload("friend_pick.gd")
const BagScreen = preload("bag.gd")
const BagAtlas = preload("bag_atlas.gd")

signal closed

const SMALL: int = 6
const BIG: int = 3
const BIG_TABS: Array = [2, 7, 3, 9]
const GOODS: Vector2 = Vector2(224, 51)
const BEGIN: Vector2 = Vector2(11, 88)
const STEP: Vector2 = Vector2(250, 190)
const PRICE: Color = Color("8c4500")
const NOTE: Color = Color("975317")
const HAVE: Color = Color("ff9b4b")
const COUNT: Color = Color("fefefe")
const PAGE_ON: Color = Color("126df6")
const PAGE_OFF: Color = Color("fbf8f8")
const COST: Color = Color("fff352")
const SHORT: Color = Color("ff6b5b")
const SIGNS: Array = ["discount", "hot", "limitquantity", "limittime", "new"]
const DOTS: int = 20
const WAIT: float = 8.0
const TANK_VIEW_TIP: String = "Xem trước Tank"
const EFFECT: Color = Color("ffaea3")
const CARD_DESC: Color = Color("e86655")
const TRY_TIP: String = "Thử đồ"
const TIP_40: String = "Chọn đối tượng tặng trước"
const TIP_79: String = "Xu không đủ, hãy nạp tiền"
const TIP_93: String = "Không thể tự tặng bản thân"
const TEXT_447: String = "VP VIP, không thể tặng bạn"
const PRESENTED: int = 5


const PRESENT_AT: Dictionary = {
	"item": [Vector2(44, 395), Vector2(71, 399), Vector2(136, 391), Vector2(346, 398), Vector2(139, 446), Vector2(398, 126)], 
	"tank": [Vector2(44, 419), Vector2(71, 423), Vector2(136, 418), Vector2(346, 425), Vector2(139, 468), Vector2(398, 153)], 
	"avatar": [Vector2(249, 360), Vector2(276, 364), Vector2(244, 391), Vector2(454, 398), Vector2(199, 447), Vector2(518, 126)], 
}

var cat: int = 0
var want: int = 0
var gift_to: String = ""
var _gt: int = 1
var _st: int = 1


const BOUND_ST: int = 100
var _page: int = 0
var _rows: Dictionary = {}
var _bad: Dictionary = {}
var _list: Array = []
var _http: HTTPRequest
var _asking: String = ""
var _want: String = ""
var _stale: bool = true
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _sheet_id: String = ""
var _sheet_key: String = ""
var _sheet_coin: int = 0
var _sheet_tier: int = 0
var _sheet_renew: bool = false
var _sheet_pick: int = 0
var _sheet_rows: Array = []
var _count: LineEdit
var _focus: LineEdit
var _pending: Dictionary = {}
var _bag_failed: bool = false
var _garage_failed: bool = false
var _try_avatar: String = ""
var _try_ornate: int = 0
var _worn: Array = []
var _tank_view: Array = []
var _present: bool = false
var _present_lock: bool = false
var _friend: LineEdit
var _pick = FriendPick.new()
var _gift: Dictionary = {}

func chat_busy() -> bool:
	return not _sheet_id.is_empty()

func _setup() -> void :
	_count = _fedit(3, true)
	_count.text_submitted.connect( func(_text: String) -> void : _present_send() if _present else _confirm())
	_friend = _name_fedit()
	_http = HTTPRequest.new()
	_http.timeout = 10
	_http.accept_gzip = false
	add_child(_http)
	_http.request_completed.connect(_on_catalog)
	pack.picture_ready.connect( func(path: String) -> void :
		if path == "l/bag.json":
			_bag_failed = pack.bag.is_empty()
			_stale = true
		elif path == "l/garage.json":
			_garage_failed = pack.garage.is_empty()
			_stale = true)
	client.noticed.connect( func(text: String) -> void :
		if is_visible_in_tree():
			say(text))
	client.bought.connect(_on_bought)

func _shown() -> void :
	if _http == null:
		return
	_close()
	if not is_visible_in_tree():
		gift_to = ""
		return
	pack.load_bag()
	pack.load_garage()
	pack.load_bagx()
	_try_avatar = ""
	_try_ornate = 0
	_worn = []
	if not client.bag_loaded:
		client.request_bags()
	if not gift_to.is_empty():
		say("Chọn quà rồi bấm Tặng — người nhận: %s" % gift_to)

	if cat != 0:
		_gt = cat
		_st = 1
		_page = 0
		cat = 0
	else:
		want = 0
	_rows.clear()
	_bad.clear()
	_list = []
	_bag_failed = false
	_garage_failed = false
	_stale = true
	_fetch(_slot())


func _slot() -> String:
	return "%d:%d" % [_gt, 1 if _st == BOUND_ST else _st]

func _fetch(slot: String) -> void :
	if not _asking.is_empty():
		_want = slot
		return
	_bad.erase(slot)
	_asking = slot
	var part: PackedStringArray = slot.split(":")
	var url: String = client.config.origin + "/goodsshopquery.php?gt=%s&st=%s&p=0&r=10000" % [part[0], part[1]]
	if _http.request(url, AppSession.headers(url)) != OK:
		_asking = ""
		_bad[slot] = true

func _on_catalog(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
	var slot: String = _asking
	_asking = ""
	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		_rows[slot] = ShopModel.parse(body)
	else:
		_bad[slot] = true
	_stale = true
	if not _want.is_empty():
		var next: String = _want
		_want = ""
		if not _rows.has(next):
			_fetch(next)

func _on_bought(ok: bool, goods: int) -> void :
	if not _gift.is_empty() and ( not ok or goods == 0 or goods == int(_gift.gid)):
		_gift = {}
		if ok and client.bought_kind == PRESENTED:
			_close()
		elif not ok and _time - _toast_at > 0.3:
			say("Chưa tặng được.")
		return
	if _pending.is_empty() or (ok and goods != 0 and goods != int(_pending.gid)):
		return
	var name: String = str(_pending.name)
	var renew: bool = bool(_pending.renew)
	_pending = {}
	if ok:
		say(("Đã gia hạn %s." if renew else "Đã mua %s.") % name)
		if not client.bag_loaded:
			client.request_bags()
	elif _time - _toast_at > 0.3:
		say("Chưa mua được %s." % name)

func _tick(_delta: float) -> void :
	if not _worn.is_empty() and _worn != _worn_now():
		_try_avatar = ""
		_try_ornate = 0
		_worn = []
	if not _pending.is_empty() and _time - float(_pending.at) > WAIT:
		_pending = {}
		say("Máy chủ chưa phản hồi, thử lại sau.")
	if not _gift.is_empty() and _time - float(_gift.at) > WAIT:
		_gift = {}
		say("Máy chủ chưa phản hồi, thử lại sau.")
	if _sheet_id == "buy" and _count.visible:
		var top: int = _max_count()
		if not _count.text.is_empty() and int(_count.text) > top:
			_count.text = str(top)
			_count.caret_column = _count.text.length()
	if not _stale:
		return
	_stale = false
	_list = []
	var slot: String = _slot()
	if not _rows.has(slot) or _packs_loading():
		return
	var names: Dictionary = pack.lobby.get("tanks", {})
	var defaults: Dictionary = pack.index.get("tanks", {})
	for rec: Dictionary in _rows[slot]:
		if not rec.has("ok"):
			rec["ok"] = ShopModel.describe(rec, pack.bag, pack.garage, names, defaults)
		if rec.ok and (_st != BOUND_ST or ShopModel.passes(rec, "bound")):
			_list.append(rec)
	if want != 0 and not _list.is_empty():
		for i in range(_list.size()):
			if int(_list[i].tid) == want:
				_page = i / _per()
				break
		want = 0
	_page = clampi(_page, 0, maxi(0, page_count(_list.size(), _per()) - 1))
	if not _sheet_id.is_empty() and _sheet_rec().is_empty():
		_close()

func _worn_now() -> Array:
	return [int(client.character.get("avatarId", 0)), int(client.character.get("decorateId", 0))]

func _packs_loading() -> bool:
	return (pack.bag.is_empty() and not _bag_failed) or (pack.garage.is_empty() and not _garage_failed) or pack.lobby.is_empty()

func _loading() -> bool:
	return not _bad.has(_slot()) and ( not _rows.has(_slot()) or _packs_loading())

func _find(key: String) -> Dictionary:
	for rec: Dictionary in _list:
		if str(rec.key) == key:
			return rec
	return {}

func _sheet_rec() -> Dictionary:
	return _find(_sheet_key)

func _per() -> int:
	return BIG if _gt in BIG_TABS else SMALL


static func page_count(total: int, per: int) -> int:
	return ceili(total / float(maxi(1, per)))


static func frame_of(tab: int, rec: Dictionary) -> String:
	if not tab in BIG_TABS:
		return "item"
	match int(rec.get("gt", 0)):
		2:
			return "tank"
		6:
			return "skin"
	return "avatar"



static func card_desc(fx: Dictionary, rec: Dictionary) -> String:
	var tid: int = int(rec.get("tid", 0))
	return BagModel.decor_fx(fx, tid) if int(rec.get("gt", 0)) == 8 else BagModel.avatar_fx(fx, tid)



static func signs(rec: Dictionary) -> Array:
	var flags: Array = [rec.get("agio", false), rec.get("hot", false), rec.get("limit", false), rec.get("ltime", false), rec.get("fresh", false)]
	var out: Array = []
	for i in range(flags.size()):
		if flags[i] and out.size() < 2:
			out.append(SIGNS[i])
	return out

func _set_tab(gt: int, st: int) -> void :
	if gt == _gt and st == _st:
		return
	_gt = gt
	_st = st
	_page = 0
	_list = []
	_stale = true
	if not _rows.has(_slot()):
		_fetch(_slot())

func _turn(step: int, wrap: bool) -> void :
	var count: int = page_count(_list.size(), _per())
	if count > 0:
		_page = wrapi(_page + step, 0, count) if wrap else clampi(_page + step, 0, count - 1)

func _vip() -> int:
	return _vip_level(int(client.character.get("vipPoints", 0)))


func _gate(rec: Dictionary) -> Array:
	var own: int = ShopModel.owned(rec, client.tanks, client.bags)
	if own == 1:
		return ["Đã có", false, "Bạn đã có %s này." % ("xe" if int(rec.gt) == 2 else "skin"), false]
	if int(rec.lv) > int(client.character.get("level", 1)):
		return ["Cấp %d" % int(rec.lv), false, "Cần đạt cấp %d để mua." % int(rec.lv), false]
	if int(rec.vip) > _vip():
		return ["VIP %d" % int(rec.vip), false, "Cần VIP %d để mua." % int(rec.vip), false]
	if not client.bag_loaded and int(rec.gt) in [3, 6, 8]:
		return ["Mua", false, "Đang tải túi đồ…", false]
	var renew: bool = own == 2
	if not _pending.is_empty() or not _gift.is_empty():
		return ["Gia hạn" if renew else "Mua", false, "Đang chờ máy chủ xác nhận lần mua trước…", renew]
	return ["Gia hạn" if renew else "Mua", true, "", renew]


func _max_count() -> int:
	var rec: Dictionary = _sheet_rec()
	if rec.is_empty() or _sheet_renew or not ShopModel.multi(rec):
		return 1
	return ShopModel.COUNT_CAP


func _open_buy(rec: Dictionary, present: bool = false) -> void :
	var gate: Array = _gate(rec)
	if present and not _gift.is_empty():
		say("Đang chờ máy chủ xác nhận lần tặng trước…")
		return
	if not present and not gate[1]:
		say(str(gate[2]))
		return
	_sheet_id = "buy"
	_sheet_key = str(rec.key)
	_sheet_renew = bool(gate[3]) and not present
	_sheet_tier = 0
	_present = present and _can_present(rec)
	_present_lock = _present and _item_sheet(rec)
	if _present and not _item_sheet(rec) and int(rec.vip) > 0:
		_present = false
		say(TEXT_447)
	_friend.text = gift_to if _present else ""
	_pick.close()

	_sheet_coin = 0
	if rec.alt:
		var first: Dictionary = ShopModel.tiers(rec, 0)[0]
		if ShopModel.spendable(rec, 0, client.currency) < int(first.unit) and ShopModel.spendable(rec, 1, client.currency) >= int(ShopModel.tiers(rec, 1)[0].unit):
			_sheet_coin = 1
	_count.text = "1"
	_sheet_rows = ShopRecommend.rows(rec, _coin_name(int(rec.ct))) if _recommend_on(rec) else []
	_sheet_pick = ShopRecommend.initial(rec, 1, _sheet_rows)
	if _max_count() > 1:
		_focus = _count


func _recommend_on(rec: Dictionary) -> bool:
	return _item_sheet(rec) and ShopRecommend.active(rec)


func _item_sheet(rec: Dictionary) -> bool:
	var gt: int = int(rec.gt)
	return gt not in [2, 3, 6, 8] or (gt == ShopRecommend.SKIN_GT and ShopRecommend.skin(rec))

func _close() -> void :
	_sheet_id = ""
	_sheet_key = ""
	_focus = null
	_present = false
	_present_lock = false
	_pick.close()
	_hide_edits()


func _can_present(rec: Dictionary) -> bool:
	return not rec.is_empty() and int(rec.ct) == 1 and not _sheet_renew


func _present_kind(rec: Dictionary) -> String:
	if _item_sheet(rec):
		return "item"
	return "avatar" if int(rec.gt) in [3, 8] else "tank"


func _quote() -> Array:
	var rec: Dictionary = _sheet_rec()
	var tiers: Array = ShopModel.tiers(rec, _sheet_coin)
	_sheet_tier = clampi(_sheet_tier, 0, tiers.size() - 1)
	var tier: Dictionary = tiers[_sheet_tier]
	if _recommend_on(rec):
		tier = {"k": _sheet_pick, "unit": ShopRecommend.unit(rec, _sheet_coin, _sheet_pick), "old": 0}
	var amount: int = clampi(int(_count.text) if not _count.text.is_empty() else 1, 1, _max_count())
	if _present:
		return [tier, amount, int(tier.unit) * amount, int(client.currency.get("m_iCash", 0))]
	return [tier, amount, int(tier.unit) * amount, ShopModel.spendable(rec, _sheet_coin, client.currency)]


func _present_send() -> void :
	var rec: Dictionary = _sheet_rec()
	if _sheet_id != "buy" or rec.is_empty() or not _present or not _gift.is_empty():
		return
	var name: String = _friend.text.strip_edges()
	if name.is_empty():
		say(TIP_40)
		return
	_sheet_coin = 0
	var quote: Array = _quote()
	if int(quote[3]) < int(quote[2]):
		say(TIP_79)
		return
	if name == str(client.character.get("name", client.account.get("name", ""))):
		say(TIP_93)
		return
	var gid: int = int(rec.gid)
	if client.present_goods(gid, int(quote[0].unit), int(quote[1]), name):
		_gift = {"gid": gid, "name": name, "at": _time}
	else:
		say("Chưa tặng được lúc này.")

func _confirm() -> void :
	var rec: Dictionary = _sheet_rec()
	if _sheet_id != "buy" or rec.is_empty():
		_close()
		return
	var quote: Array = _quote()
	var renew: bool = _sheet_renew
	var gate: Array = _gate(rec)
	if not gate[1]:
		say(str(gate[2]))
		return
	if int(quote[3]) < int(quote[2]):
		say("Không đủ %s." % _coin_name(ShopModel.pay_coin(rec, _sheet_coin)))
		return
	_close()
	var tier: Dictionary = quote[0]
	if client.buy_goods(ShopModel.buy_type(rec, renew), int(rec.gid), ShopModel.pay_coin(rec, _sheet_coin), int(tier.unit), int(quote[1])):
		_pending = {"gid": int(rec.gid), "name": GarageModel.cap(str(rec.name)), "renew": renew, "at": _time}
	else:
		say("Chưa mua được lúc này.")

func _bump(by: int) -> void :
	_count.text = str(clampi(int(_count.text) + by, 1, _max_count()))
	_count.caret_column = _count.text.length()
	if _count.has_focus() and preload("res://battle/touch_gfx.gd").touch_screen():
		_count.release_focus()

func _coin_name(ct: int) -> String:
	return str(ShopModel.COIN_NAME[ShopModel.coin_index(ct)])



func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Hall.FILE, Hall.R)
		_use(Atlas.FILE, Atlas.R)
		ShopTry.use(self)
		_use(QuickAtlas.FILE, QuickAtlas.R)
		_use(BagAtlas.FILE, {"bag_x2_mat": BagAtlas.R["bag_x2_mat"], "bag_x2_tok": BagAtlas.R["bag_x2_tok"]})
		FriendPick.cells(self)
	_tip = []
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	var base: Vector2 = _stage() + Vector2(float(Atlas.FRAME.shop[0]), float(Atlas.FRAME.shop[1]))
	_frows(Atlas.PLACE.filter( func(r: Array) -> bool: return not (NAPTIEN1_HIDE and str(r[3]) == "shop_recharge")), base)
	_draw_self(base)
	_draw_coins(base)
	_draw_tabs(base)
	_draw_goods(base)
	_draw_pager(base)
	if _sheet_id == "buy":
		_draw_buy()
		if _sheet_id != "buy" or not _can_present(_sheet_rec()):
			_pick.close()
	elif _sheet_id == "tank":
		_hide_edits()
		_tip = ShopTry.draw(self, _sheet_rec(), _tank_view)
		_draw_tip()
	else:
		_hide_edits()
		_draw_tip()
	if _focus != null and _focus.visible:
		if not preload("res://battle/touch_gfx.gd").touch_screen():
			_focus.grab_focus.call_deferred()
			_focus.select_all.call_deferred()
		_focus = null




func _draw_self(base: Vector2) -> void :
	var at: Vector2 = base + Vector2(16, 49)
	var basic: Dictionary = client.character
	var decor: int = _try_ornate if _try_ornate > 0 else int(basic.get("decorateId", 0))
	var stem: String = str(pack.bagx.get("ornate", {}).get(str(decor), ""))
	var box: Rect2 = BagScreen._ornate_box(at - Vector2(19, 50), stem)
	if box.size.x > 0.0:
		var frame: Texture2D = pack.picture(BagScreen.ornate_picture(stem))
		if frame != null and frame.get_width() > 4:
			draw_texture_rect(frame, Rect2(box.position * _f, box.size * _f), false)
	_fblit("level_%d" % clampi(int(basic.get("level", 1)), 0, 40), at + Vector2(-2, 10), 56.0, 28.0)
	_level_fx(int(basic.get("level", 1)), at + Vector2(-2, 10), 56.0)
	var vip: int = mini(12, _vip())
	var style: Array = HallScreen.name_style(vip)
	var who: String = str(basic.get("name", client.account.get("name", "")))
	if not NameStyles.paint(self, who, BOLD, 13.0, "c", at + Vector2(48, 13), 152.0, 1.0, 24.0):
		_fwords(who, BOLD, 13.0, style[0], "c", at + Vector2(48, 13), 152.0, 1.0, 24.0, true, style[1])
	var key: String = str(pack.lobby.get("avatars", {}).get(str(int(basic.get("avatarId", 0))), ""))
	var path: String = _try_avatar if not _try_avatar.is_empty() else ("l/av/%s.webp" % key if not key.is_empty() else "")
	var figure: Texture2D = pack.picture(path) if not path.is_empty() else null
	if figure != null and figure.get_width() > 4:
		draw_texture_rect(figure, Rect2((at + Vector2(15, 44)) * _f, Vector2(180, 240) * _f), false)
	if vip > 0:
		_fblit("shop_vip%d" % mini(12, vip), at + Vector2(141, 45))
	var now: int = int(Time.get_unix_time_from_system())
	for row: Array in BagScreen.X2_ROWS:
		var left: int = int(basic.get(str(row[2]), 0)) - now
		var uses: int = int(basic.get(str(row[3]), 0))
		if left <= 0 and uses <= 0:
			continue
		var spot: Array = BagAtlas.X2[str(row[0])]
		var rect: Rect2 = _fblit(str(row[1]), at + Vector2(float(spot[0]), float(spot[1])))
		var id: String = "x2:" + str(row[1])
		_hit(id, rect, false)
		_hint(id, rect, BagScreen.x2_tip(str(row[4]), left, uses))
	var fx: Dictionary = pack.bagx.get("fx", {})
	var worn_decor: int = int(basic.get("decorateId", 0))
	var worn_avatar: int = int(basic.get("avatarId", 0))
	if worn_decor > 0:
		_fwords(BagModel.decor_fx(fx, worn_decor), BOLD, 13.0, EFFECT, "c", at + Vector2(8.5, 255), 193.0, 1.0)
	if worn_avatar > 0:
		_fwords(BagModel.avatar_fx(fx, worn_avatar), BOLD, 13.0, EFFECT, "c", at + Vector2(8.5, 273), 193.0, 1.0)


func _draw_coins(base: Vector2) -> void :
	for row: Array in Atlas.COINS:
		var at: Vector2 = base + Vector2(21, float(row[0]))
		_fwords(str(row[2]), BOLD, 14.0, Color.WHITE, "c", at + Vector2(33, 3), 60.0, 1.0, 24.0)
		_fwords(Mysterious.comma(int(client.currency.get(str(row[3]), 0))), BOLD, 14.0, Color.WHITE, "r", at + Vector2(74, 3), 120.0, 1.0, 24.0)


func _draw_tabs(base: Vector2) -> void :
	var goods: Vector2 = base + GOODS
	for tab: Array in Atlas.NAV:
		var gt: int = int(tab[0])
		var id: String = "cat:%d" % gt
		var at: Vector2 = goods + Vector2(float(tab[1]), 4)
		_fbutton(id, "shop_nav_sel" if gt == _gt else "shop_nav", at)
		var word: String = str(tab[2])
		_fblit(word, at + ((Vector2(101, 33) - _cell_size(word)) / 2.0).round(), 0.0, 0.0, _glow(id))
	for i in range(Atlas.SUB.size()):
		var sub: Array = Atlas.SUB[i]
		var st: int = int(sub[0])
		var id: String = "sub:%d" % st
		var at: Vector2 = goods + Vector2(16.0 + float(sub[1]), 50)
		_fbutton(id, "shop_sub_%s%s" % [str(sub[2]), "_sel" if st == _st else ""], at)
		_fwords(str(sub[3]), BOLD, 14.0, Color.WHITE, "c", at + Vector2(6 if i == 0 else 4, 3), 80.0, 1.0, 24.0)

func _draw_goods(base: Vector2) -> void :
	var goods: Vector2 = base + GOODS
	var middle: Vector2 = goods + Vector2(1, 34 + 190)
	if _bad.has(_slot()):
		_fwords("Không tải được cửa hàng — bấm để thử lại.", BOLD, 15.0, Color.WHITE, "c", middle, 776.0, 1.5, 30.0)
		_hit("retry", Rect2(middle * _f, Vector2(776, 30) * _f), false)
		return
	if _loading():
		_fwords("Đang tải cửa hàng…", BOLD, 15.0, Color.WHITE, "c", middle, 776.0, 1.5, 30.0)
		return
	var per: int = _per()
	var start: int = _page * per
	for i in range(clampi(_list.size() - start, 0, per)):
		var rec: Dictionary = _list[start + i]
		var kind: String = frame_of(_gt, rec)
		if kind == "item":
			_draw_item(rec, goods + BEGIN + Vector2((i % 3) * STEP.x, (i / 3) * STEP.y))
		else:
			_draw_big(rec, kind, goods + BEGIN + Vector2(i * STEP.x, 0))


func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false)


func _card_art(rec: Dictionary) -> Texture2D:
	var path: String = str(rec.art) if rec.avatar else (str(rec.face) if not str(rec.face).is_empty() else str(rec.icon))
	return pack.picture(path) if not path.is_empty() else null




func _shoptt1_art(rec: Dictionary) -> Array:
	if int(rec.gt) == 8:
		var stem: String = str(pack.bagx.get("ornate", {}).get(str(int(rec.tid)), ""))
		if not stem.is_empty():
			return [pack.picture("l/or/%s.webp" % stem), 1.0]
	return [_card_art(rec), 1.0 if rec.avatar else 2.0]





func _shoptt1_name(rec: Dictionary, o: Vector2) -> void :
	var text: String = GarageModel.cap(str(rec.name))
	var span: Callable = func(t: String, px: float) -> float: return _face(BOLD).get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, maxi(6, roundi(px * _f))).x / _f
	if span.call(text, 14.0) <= 120.0:
		_fwords(text, BOLD, 14.0, Color.WHITE, "c", o + Vector2(10, 13), 230.0, 1.0, 24.0)
		return
	var left: float = 58.0 if not signs(rec).is_empty() else 10.0
	var wide: float = 184.0 - left
	var words: PackedStringArray = text.split(" ", false)
	if span.call(text, 11.0) <= wide or words.size() < 2:
		_fwords(text, BOLD, 14.0, Color.WHITE, "c", o + Vector2(left, 13), wide, 1.0, 24.0)
		return
	var cut: int = 1
	var worst: float = INF
	for k in range(1, words.size()):
		var w: float = maxf(span.call(" ".join(words.slice(0, k)), 11.0), span.call(" ".join(words.slice(k)), 11.0))
		if w < worst:
			worst = w
			cut = k
	_fwords(" ".join(words.slice(0, cut)), BOLD, 11.0, Color.WHITE, "c", o + Vector2(left, 12), wide, 1.0, 13.0)
	_fwords(" ".join(words.slice(cut)), BOLD, 11.0, Color.WHITE, "c", o + Vector2(left, 25), wide, 1.0, 13.0)

func _coin(ct: int, at: Vector2) -> void :
	_fblit(str(Atlas.COINS[ShopModel.coin_index(ct)][1]), at)


func _card_coin(rec: Dictionary) -> int:
	return 3 if _st == BOUND_ST and int(rec.ct) == 1 and rec.gift else int(rec.ct)




func _peek(rec: Dictionary, at: Vector2, box: Vector2, extra: Dictionary = {}, no_time: bool = false) -> void :
	var rect: Rect2 = Rect2(at * _f, box * _f)
	if _sheet_id.is_empty() and _press.is_empty() and rect.has_point(get_local_mouse_position()):
		var item: Dictionary = FlashTip.simulate(int(rec.tid), pack.bag, extra)
		item["tip_opts"] = {"no_time": no_time}
		_tip = [rect, "", "", Color.WHITE, item]


func _hint(id: String, rect: Rect2, text: String) -> void :
	if _hover == id and _sheet_id.is_empty() and _press.is_empty():
		_tip = [rect, text, "", Color.WHITE]

func _signs(rec: Dictionary, o: Vector2, wide: float, high: float) -> void :
	var marks: Array = signs(rec)
	if marks.size() > 0:
		_fblit("shop_sign_" + str(marks[0]), o + Vector2(2, 2))
	if marks.size() > 1 and _cells.has("shop_sign_%s_rb" % str(marks[1])):
		var name: String = "shop_sign_%s_rb" % str(marks[1])
		var cell: Vector2 = _cell_size(name)
		_fblit(name, o + Vector2(wide - 1.0 - cell.x, high - 2.0 - cell.y))


func _have(at: Vector2, wide: float, px: float) -> void :
	_fwords("Đã có", BOLD, px, HAVE, "c", at, wide, 1.0, px + 8.0)


func _draw_item(rec: Dictionary, o: Vector2) -> void :
	var key: String = str(rec.key)
	_fblit("shop_card", o + Vector2(-2, -2))
	_fwords(GarageModel.cap(str(rec.name)), BOLD, 14.0, Color.WHITE, "c", o + Vector2(16, 13), 219.0, 1.0, 24.0)
	_fit(_card_art(rec), o + Vector2(15, 61), Vector2(100, 100))
	_peek(rec, o + Vector2(15, 61), Vector2(100, 100))
	var tier: Dictionary = ShopModel.tiers(rec, 0)[0]
	var ct: int = _card_coin(rec)
	if int(tier.old) > 0:

		_fblit("shop_price_bg", o + Vector2(126, 64))
		_coin(ct, o + Vector2(132, 68))
		_struck(Mysterious.comma(int(tier.old)), o + Vector2(161, 69), 80.0)
	else:
		_fpara(GarageModel.plain(str(rec.desc)), REGULAR, 12.0, NOTE, o + Vector2(124, 59), 116.0, 2)
	_coin(ct, o + Vector2(134, 102))
	var used: float = _fwords(Mysterious.comma(int(tier.unit)), BOLD, 14.0, PRICE, "l", o + Vector2(161, 103), 80.0, 0.0, 24.0)
	if rec.alt:
		_coin(int(rec.ct2), o + Vector2(maxf(214.0, 161.0 + used + 4.0), 102))
	if int(rec.cnt) > 1:
		_fwords("x%d" % int(rec.cnt), BOLD, 24.0, COUNT, "r", o + Vector2(0, 130), 120.0, 1.5)
	if ShopModel.owned(rec, client.tanks, client.bags) == 1:
		_have(o + Vector2(125, 133), 60.0, 16.0)
	else:
		var renew: bool = ShopModel.owned(rec, client.tanks, client.bags) == 2
		_fbutton(("repay:" if renew else "buy:") + key, "shop_repay_s" if renew else "shop_buy_s", o + Vector2(123, 133))
	if int(rec.ct) == 1:
		_fbutton("gift:" + key, "shop_present_s", o + Vector2(184, 133))

	if not ShopTry.target(pack.garage, pack.index.get("tanks", {}), int(rec.tid)).is_empty():
		_hint("tankview:" + key, _fbutton("tankview:" + key, "shop_view3", o + Vector2(185, 9)), TANK_VIEW_TIP)
	_signs(rec, o, 250.0, 190.0)


func _struck(text: String, at: Vector2, wide: float) -> float:
	var used: float = _fwords(text, BOLD, 14.0, PRICE, "l", at, wide, 0.0, 24.0)
	draw_line((at + Vector2(-1, 12)) * _f, (at + Vector2(used + 1.0, 12)) * _f, PRICE, maxf(1.0, _f), true)
	return used


func _draw_big(rec: Dictionary, kind: String, o: Vector2) -> void :
	var key: String = str(rec.key)
	_fblit("shop_bigcard", o + Vector2(-2, -2))

	if kind == "avatar":
		_shoptt1_name(rec, o)
	else:
		_fwords(GarageModel.cap(str(rec.name)), BOLD, 14.0, Color.WHITE, "c", o + Vector2(10, 13), 230.0, 1.0, 24.0)
	var own: int = ShopModel.owned(rec, client.tanks, client.bags)
	var gift: bool = int(rec.ct) == 1
	match kind:
		"tank":
			_fit(pack.picture(str(rec.face)), o + Vector2(27, 46), Vector2(196, 196))

			_draw_skills(rec, o)
			if own == 1:
				_have(o + Vector2(-5, 337), 125.0, 16.0)
			else:
				_fbutton("buy:" + key, "shop_buy_s", o + Vector2(24, 336))
			if gift:
				_fbutton("gift:" + key, "shop_present_s", o + Vector2(95, 336))
		"skin":
			_fit(pack.picture(str(rec.face)), o + Vector2(27, 68), Vector2(196, 196))
			_peek(rec, o + Vector2(27, 68), Vector2(196, 196), {"type": 29, "face": str(rec.face)}, true)
			if own == 1:
				_have(o + Vector2(0, 334), 125.0 if gift else 250.0, 20.0)
			else:
				_fbutton("buy:" + key, "shop_buy", o + Vector2(32, 336))
			if gift:
				_fbutton("gift:" + key, "shop_present", o + Vector2(125, 336))
		_:
			var shoptt1: Array = _shoptt1_art(rec)
			_fit(shoptt1[0], o + Vector2(37, 41), Vector2(180, 240), shoptt1[1])
			_peek(rec, o + Vector2(37, 41), Vector2(180, 240), {}, true)
			var renew: bool = own == 2
			_fbutton(("repay:" if renew else "buy:") + key, "shop_repay" if renew else "shop_buy", o + Vector2(32, 336))
			if gift and int(rec.vip) == 0:
				_fbutton("gift:" + key, "shop_present", o + Vector2(125, 336))
			_hint("try:" + key, _fbutton("try:" + key, "shop_view3", o + Vector2(185, 9)), TRY_TIP)

			var desc: String = card_desc(pack.bagx.get("fx", {}), rec)
			if not desc.is_empty():
				_fwords(desc, BOLD, 13.0, CARD_DESC, "c", o + Vector2(0, 281), 250.0, 0.0)
	_price_row(rec, o + Vector2(0, 302))
	if int(rec.vip) > 0:
		_fblit("shop_viplimit_bk", o + Vector2(176, 37))
		_fblit("shop_viplimit_word", o + Vector2(176, 37) + ((_cell_size("shop_viplimit_bk") - _cell_size("shop_viplimit_word")) / 2.0).round())
	_signs(rec, o, 250.0, 380.0)



func _price_row(rec: Dictionary, at: Vector2) -> void :
	var tier: Dictionary = ShopModel.tiers(rec, 0)[0]
	var ct: int = _card_coin(rec)
	var parts: Array = []
	if int(tier.old) > 0:
		parts = [["coin", ct], ["cut", Mysterious.comma(int(tier.old))], ["coin", ct], ["text", Mysterious.comma(int(tier.unit))]]
	elif rec.alt:
		parts = [["coin", ct], ["text", Mysterious.comma(int(tier.unit))], ["or", 0], ["coin", int(rec.ct2)], ["text", Mysterious.comma(int(ShopModel.tiers(rec, 1)[0].unit))]]
	else:
		parts = [["coin", ct], ["text", Mysterious.comma(int(tier.unit))]]
	var font_size: int = maxi(6, roundi(14.0 * _f))
	var widths: Array = []
	var total: float = 0.0
	for part: Array in parts:
		var w: float = 26.0
		if part[0] == "or":
			w = 13.0 + 8.0
		elif part[0] != "coin":
			w = ARIAL_BOLD.get_string_size(str(part[1]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f + 10.0
		widths.append(w)
		total += w
	var x: float = (135.0 if parts.size() == 2 else 125.0) - total / 2.0
	for i in range(parts.size()):
		var part: Array = parts[i]
		var spot: Vector2 = at + Vector2(roundf(x), 0)
		match str(part[0]):
			"coin":
				_coin(int(part[1]), spot)
			"or":
				_fblit("shop_or", spot + Vector2(0, 8))
			"cut":
				_struck(str(part[1]), spot + Vector2(2, 2), float(widths[i]))
			_:
				_fwords(str(part[1]), BOLD, 14.0, PRICE, "l", spot + Vector2(2, 2), float(widths[i]), 0.0, 24.0)
		x += float(widths[i])


func _draw_skills(rec: Dictionary, o: Vector2) -> void :
	var list: Array = pack.garage.get("tanks", {}).get(str(int(rec.tid)), {}).get("skills", [])
	if list.size() < 4:
		return
	var ids: Array = [int(list[3]) if int(list[3]) > 0 else int(list[2]), int(list[0]), int(list[1])]
	for i in range(3):
		var id: int = int(ids[i])
		if id <= 0:
			continue
		var at: Vector2 = o + Vector2(44.0 + 56.0 * i, 248)
		var hud: Array = pack.skill_hud(id)
		_fit(pack.icon("s", str(hud[0])) if not hud.is_empty() else null, at, Vector2(50, 50), 4.0)
		var rect: Rect2 = Rect2(at * _f, Vector2(50, 50) * _f)
		if _sheet_id.is_empty() and _press.is_empty() and rect.has_point(get_local_mouse_position()):
			_tip = [rect, "", "", Color.WHITE, {"skill": id}]


func _draw_pager(base: Vector2) -> void :
	var count: int = page_count(_list.size(), _per()) if not _loading() and not _bad.has(_slot()) else 0
	var shown: int = mini(count, DOTS)
	var list_w: float = shown * 28.0 + 60.0
	var left: Vector2 = base + Vector2(301.0 + floorf((616.0 - list_w) / 2.0), 539)
	_fbutton("page:prev", "public_btn_s2_prev", left)
	_fbutton("page:next", "public_btn_s2_next", left + Vector2(list_w + 2.5 - 33.0, -1.5))
	for i in range(shown):
		var at: Vector2 = left + Vector2(32.0 + 28.0 * i, 2)
		var id: String = "page:%d" % i
		_hit(id, _fblit("shop_pager", at, 24.0, 24.0, _glow(id)), false)
	if _page < shown:
		_fblit("shop_pager_sel", left + Vector2(33.0 + 28.0 * _page, 2))
	for i in range(shown):
		_fwords(str(i + 1), BOLD, 12.0, PAGE_ON if i == _page else PAGE_OFF, "c", left + Vector2(32.0 + 28.0 * i, 2), 24.0, 0.0, 24.0)

func _draw_tip() -> void :
	if FlashTip.show(self, _tip, _ctip):
		return
	var anchor: Rect2 = _tip[0]
	var body: String = str(_tip[2])
	var wide: float = 230.0
	var body_px: int = maxi(6, roundi(12.0 * _f))
	var body_h: float = ARIAL.get_multiline_string_size(body, HORIZONTAL_ALIGNMENT_LEFT, (wide - 20.0) * _f, body_px, 8).y / _f if not body.is_empty() else 0.0
	var high: float = 30.0 + body_h + (8.0 if body_h > 0.0 else 0.0)
	var at: Vector2 = Vector2(anchor.end.x / _f + 6.0, anchor.position.y / _f)
	if at.x + wide > _fw:
		at.x = anchor.position.x / _f - 6.0 - wide
	at.y = clampf(at.y, 0.0, maxf(0.0, _fh - high))
	_round(Rect2(at * _f, Vector2(wide, high) * _f), Color(0, 0, 0, 0.86), 8.0, Color("6fd0ff", 0.55), 1.5)
	_fwords(str(_tip[1]), BOLD, 13.0, _tip[3], "l", at + Vector2(10, 6), wide - 20.0, 1.0, 20.0)
	if body_h > 0.0:
		_fpara(body, REGULAR, 12.0, Color.WHITE, at + Vector2(10, 26), wide - 20.0, 8)



func _draw_buy() -> void :
	var rec: Dictionary = _sheet_rec()
	if rec.is_empty():
		return
	if _item_sheet(rec):
		_draw_buy_item(rec)
		return
	match int(rec.gt):
		3, 8:
			_draw_buy_avatar(rec)
		2, 6:
			_draw_buy_tank(rec)



func _draw_buy_item(rec: Dictionary) -> void :
	var at: Vector2 = _window(398.0, 498.0)
	_fmid("shop_title_confirmpaygood", at + Vector2(0, 19), 398.0)
	var recommend: bool = _recommend_on(rec)
	var cell: Vector2 = at + Vector2(ShopRecommend.CELL_X if recommend else ShopRecommend.CELL_X_PLAIN, 58)
	_fblit("shop_goodscell_bk", cell)
	_fit(_card_art(rec), cell + Vector2(26, 26), Vector2(100, 100))
	if recommend:
		_fwords(GarageModel.cap(str(rec.name)), BOLD, 16.0, Color.WHITE, "c", Vector2(cell.x - 14.0, at.y + 212.0), 180.0, 1.5, 24.0)
	else:
		_fwords(GarageModel.cap(str(rec.name)), BOLD, 16.0, Color.WHITE, "c", at + Vector2(24, 212), 350.0, 1.5, 24.0)
	if int(rec.gt) == ShopRecommend.SKIN_GT:
		_hide_edits()
	else:
		var multi: bool = _max_count() > 1
		_fblit("shop_title_buynum", at + Vector2(36, 237))
		_fbutton("less", "shop_num_minus", at + Vector2(173, 236))
		_fblit("shop_input_bk_ss", at + Vector2(203, 230))
		_fput(_count, Rect2(at + Vector2(223, 233), Vector2(60, 30)), 20.0, "c", multi)
		_fbutton("more", "public_button_num_plus", at + Vector2(307, 236))
		if multi:
			_draw_max(at + Vector2(334, 234))
	if recommend:
		_draw_recommend(at + ShopRecommend.FRAME)
	_fblit("shop_title_pay", at + Vector2(36, 279))
	_draw_pay(rec, at + Vector2(136, 274))
	_fblit("shop_word_consume_tips", at + Vector2(170, 368))
	_draw_present(rec, at)


func _draw_max(at: Vector2) -> void :
	var rect: Rect2 = Rect2(at * _f, Vector2(46, 28) * _f)
	_round(rect, Color("1f74c8") * _glow("max"), 6.0, Color("9fd6ff"), 1.0)
	_fwords("Tối đa", BOLD, 13.0, Color.WHITE, "c", at + Vector2(0, 5), 46.0, 1.0, 18.0)
	_hit("max", rect, false)


func _most() -> int:
	var quote: Array = _quote()
	var unit: int = int(quote[0].unit)
	var top: int = _max_count()
	if unit <= 0:
		return top
	return clampi(floori(float(quote[3]) / float(unit)), 1, top)


func _draw_buy_tank(rec: Dictionary) -> void :
	_hide_edits()
	var at: Vector2 = _window(398.0, 520.0)
	_fmid("shop_title_confirmpaygood", at + Vector2(0, 19), 398.0)
	_fblit("shop_tankcell_bk", at + Vector2(88, 46))
	_fit(pack.picture(str(rec.face)) if not str(rec.face).is_empty() else _card_art(rec), at + Vector2(99, 57), Vector2(200, 200))
	_fwords(GarageModel.cap(str(rec.name)), BOLD, 16.0, Color.WHITE, "c", at + Vector2(88, 264), 222.0, 1.5, 24.0)
	_fblit("shop_title_pay", at + Vector2(36, 296))
	_draw_pay(rec, at + Vector2(136, 291))
	_fblit("shop_word_consume_tips", at + Vector2(170, 390))
	_draw_present(rec, at)


func _draw_buy_avatar(rec: Dictionary) -> void :
	_hide_edits()
	var at: Vector2 = _window(518.0, 498.0)
	_fmid("shop_title_confirmpaygood", at + Vector2(0, 19), 518.0)
	_fblit("shop_tankcell_bk", at + Vector2(25, 60), 200.0, 280.0)
	var shoptt1: Array = _shoptt1_art(rec)
	_fit(shoptt1[0], at + Vector2(35, 80), Vector2(180, 240), shoptt1[1])
	_fwords(GarageModel.cap(str(rec.name)), BOLD, 16.0, Color.WHITE, "l", at + Vector2(240, 67), 250.0, 1.5, 24.0)
	var tiers: Array = ShopModel.tiers(rec, _sheet_coin)
	var quote: Array = _quote()
	for i in range(tiers.size()):
		var tier: Dictionary = tiers[i]
		var row: Vector2 = at + Vector2(244, 120.0 + 35.0 * i)
		var id: String = "tier:%d" % i
		_fbutton(id, "shop_radio_sel" if i == _sheet_tier else "shop_radio", row)
		_hit(id, Rect2(row * _f, Vector2(240, 26) * _f), false)
		_fwords("%d ngày" % int(ShopModel.DAYS[int(tier.k)]), BOLD, 14.0, Color.WHITE, "l", row + Vector2(32, 0), 80.0, 1.0, 26.0)
		_coin(ShopModel.pay_coin(rec, _sheet_coin), row + Vector2(112, 0))
		_fwords(Mysterious.comma(int(tier.unit)), BOLD, 14.0, COST, "l", row + Vector2(142, 0), 100.0, 1.0, 26.0)
	_fblit("shop_title_pay", at + Vector2(244, 225))
	_draw_pay(rec, at + Vector2(244, 252), quote)
	_draw_present(rec, at)


func _draw_pay(rec: Dictionary, at: Vector2, quote: Array = []) -> void :
	if quote.is_empty():
		quote = _quote()
	var amount: int = int(quote[1])
	if _present:

		_fbutton("coin:0", "shop_radio_sel", at + Vector2(4, 1))
		_fblit("shop_label200", at + Vector2(32, 1))
		_coin(1, at + Vector2(42, 3))
		_fwords(_coin_name(1), BOLD, 13.0, Color.WHITE, "l", at + Vector2(70, 3), 60.0, 1.0, 26.0)
		_fwords(Mysterious.comma(int(quote[2])), BOLD, 14.0, SHORT if int(quote[3]) < int(quote[2]) else COST, "r", at + Vector2(108, 3), 120.0, 1.0, 26.0)
		return
	for i in range(2 if rec.alt else 1):
		var row: Vector2 = at + Vector2(0, 34.0 * i)
		var id: String = "coin:%d" % i
		var ct: int = ShopModel.pay_coin(rec, i)
		var tiers: Array = ShopModel.tiers(rec, i)
		var cost: int = int(tiers[clampi(_sheet_tier, 0, tiers.size() - 1)].unit) * amount
		if _recommend_on(rec):
			cost = ShopRecommend.unit(rec, i, _sheet_pick) * amount
		_fbutton(id, "shop_radio_sel" if i == _sheet_coin else "shop_radio", row + Vector2(4, 1))
		_fblit("shop_label200", row + Vector2(32, 1))
		_hit(id, Rect2(row * _f, Vector2(236, 30) * _f), false)
		_coin(ct, row + Vector2(42, 3))
		_fwords(_coin_name(ct), BOLD, 13.0, Color.WHITE, "l", row + Vector2(70, 3), 60.0, 1.0, 26.0)
		var short: bool = ShopModel.spendable(rec, i, client.currency) < cost
		_fwords(Mysterious.comma(cost), BOLD, 14.0, SHORT if short else COST, "r", row + Vector2(108, 3), 120.0, 1.0, 26.0)


func _draw_recommend(base: Vector2) -> void :
	for row: Dictionary in _sheet_rows:
		var k: int = int(row.k)
		var id: String = "pick:%d" % k
		var spot: Vector2 = base + Vector2(4, float(ShopRecommend.RADIO_Y[k]))
		_fbutton(id, "shop_radio_sel" if k == _sheet_pick else "shop_radio", spot)
		_hit(id, Rect2(spot * _f, Vector2(ShopRecommend.LABEL_X - 4.0 + ShopRecommend.LABEL_WIDE, 26) * _f), false)
		_fwords(str(row.text), BOLD, 14.0, Color.WHITE, "l", base + Vector2(ShopRecommend.LABEL_X, float(ShopRecommend.LABEL_Y[k])), ShopRecommend.LABEL_WIDE)
		if not str(row.agio).is_empty():
			_fwords(str(row.agio), BOLD, 12.0, ShopRecommend.AGIO, "r", base + Vector2(0, float(ShopRecommend.AGIO_Y[k])), ShopRecommend.WIDE)


func _draw_ok(at: Vector2, id: String = "ok", word: String = "shop_title_confirmpay") -> void :
	var lit: Color = _glow(id)
	_hit(id, _fblit("shop_button_red", at, 0.0, 0.0, lit), false)
	_fblit(word, at + ((Vector2(120, 35) - _cell_size(word)) / 2.0).round(), 0.0, 0.0, lit)


func _draw_present(rec: Dictionary, at: Vector2) -> void :
	var kind: String = _present_kind(rec)
	var spot: Array = PRESENT_AT[kind]
	if not _can_present(rec):
		_present = false
		_draw_ok(at + Vector2(139, 446) if kind == "item" else (at + Vector2(139, 468) if kind == "tank" else at + Vector2(199, 446)))
		return
	var box: String = "public_checkbox_checked" if _present else "public_checkbox_bk"
	if _present_lock:
		_fblit(box, at + spot[0])
	else:
		_fbutton("present", box, at + spot[0])
		_hit("present", _fblit("qb_present", at + spot[1]), false)
	if _present_lock:
		_fblit("qb_present", at + spot[1])
	_fblit("qb_friend_bk", at + spot[2])
	_fput(_friend, Rect2(at + spot[2] + Vector2(6, 4), Vector2(198, 27)), 16.0)
	_fbutton("friend", "qb_findfriend", at + spot[3])
	if _present:
		_draw_ok(at + spot[4], "give", "qb_confirmpresent")
	else:
		_draw_ok(at + (spot[4] if kind != "avatar" else Vector2(199, 446)))
	if _pick.open:
		_pick.draw(self, at + spot[5])



func _wheel(step: int, at: Vector2) -> void :
	if _sheet_id.is_empty():
		_turn(step, false)
	else:
		_pick.wheel(step, at)

func _drag(moved: Vector2, from: Vector2) -> void :
	if not _sheet_id.is_empty():
		_pick.drag(moved, from, _mobile, _f)

func _input(event: InputEvent) -> void :
	if not _sheet_id.is_empty() and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		_close()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	match event.keycode:
		KEY_ESCAPE:
			closed.emit()
		KEY_LEFT:
			_turn(-1, false)
		KEY_RIGHT:
			_turn(1, false)
		_:
			return
	get_viewport().set_input_as_handled()

func _activate(id: String) -> void :
	if not _sheet_id.is_empty():
		var picked: Array = _pick.activate(id)
		if bool(picked[0]):
			if not str(picked[1]).is_empty():
				_friend.text = str(picked[1])
				_friend.caret_column = _friend.text.length()
			return
		if id.begins_with("coin:"):
			if not _present:
				_sheet_coin = int(id.substr(5))
		elif id.begins_with("tier:"):
			_sheet_tier = int(id.substr(5))
		elif id.begins_with("pick:"):
			var rec: Dictionary = _sheet_rec()
			var k: int = int(id.substr(5))
			if not rec.is_empty() and _recommend_on(rec) and ShopRecommend.has_row(_sheet_rows, k):
				_sheet_pick = k
				if not ShopRecommend.skin(rec):
					_count.text = "1"
					_count.caret_column = 1
		match id:
			"shade", "cancel", "tank_ok":
				_close()
			"tank_buy":

				var rec: Dictionary = _sheet_rec()
				_close()
				if not rec.is_empty():
					_open_buy(rec)
			"ok":
				_confirm()
			"give":
				_present_send()
			"present":
				_toggle_present()
			"friend":
				if _can_present(_sheet_rec()):
					_pick.toggle(client.friends)
			"less":
				_bump(-1)
			"more":
				_bump(1)
			"max":
				_bump(_most() - int(_count.text))
		return
	var cut: int = id.find(":")
	var head: String = id.left(cut) if cut >= 0 else id
	var tail: String = id.substr(cut + 1) if cut >= 0 else ""
	match head:
		"cat":
			_set_tab(int(tail), 1)
		"sub":
			_set_tab(_gt, int(tail))
		"page":
			if tail == "prev":
				_turn(-1, true)
			elif tail == "next":
				_turn(1, true)
			else:
				_page = int(tail)
		"buy", "repay":
			var rec: Dictionary = _find(tail)
			if not rec.is_empty():
				_open_buy(rec)
		"gift":
			var rec: Dictionary = _find(tail)
			if not rec.is_empty():
				_open_buy(rec, true)
		"try":
			_try(_find(tail))
		"tankview":
			var rec: Dictionary = _find(tail)
			var view: Array = ShopTry.target(pack.garage, pack.index.get("tanks", {}), int(rec.get("tid", 0)))
			if not view.is_empty():
				_sheet_id = "tank"
				_sheet_key = tail
				_tank_view = view
		"topup":
			say("Nạp đang được chuyển sang HTML5.")
		"bag":
			page_asked.emit("bag")
		"retry":
			_fetch(_slot())
		"close":
			closed.emit()


func _toggle_present() -> void :
	var rec: Dictionary = _sheet_rec()
	if _sheet_id != "buy" or not _can_present(rec) or _present_lock or not _gift.is_empty():
		return
	if not _present and not _item_sheet(rec) and int(rec.vip) > 0:
		say(TEXT_447)
		return
	_present = not _present
	if _present:
		_sheet_coin = 0


func _try(rec: Dictionary) -> void :
	if rec.is_empty():
		return
	if int(rec.gt) == 8:
		if str(pack.bagx.get("ornate", {}).get(str(int(rec.tid)), "")).is_empty():
			say("Chưa có ảnh xem thử của món này.")
			return
		_try_ornate = int(rec.tid)
	elif rec.avatar and not str(rec.art).is_empty():
		_try_avatar = str(rec.art)
	else:
		say("Chưa có ảnh xem thử của món này.")
		return
	_worn = _worn_now()
