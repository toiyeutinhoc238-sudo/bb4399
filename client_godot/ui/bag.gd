extends "flash_screen.gd"
const AppSession = preload("res://net/app_session.gd")






















const BagModel = preload("bag_model.gd")
const GarageModel = preload("garage_model.gd")
const HallScreen = preload("hall_screen.gd")
const Atlas = preload("bag_atlas.gd")
const Shop = preload("shop_atlas.gd")
const Arena = preload("arena_atlas.gd")
const Hall = preload("hall_atlas.gd")
const NameStyles = preload("name_styles.gd")
const BagRename = preload("bag_rename.gd")
const SplitAtlas = preload("bag_split_atlas.gd")
const BagSplit = preload("bag_split.gd")
const BagSelAward = preload("bag_sel_award.gd")
const RewardPopup = preload("reward_popup.gd")
const RewardFly = preload("reward_fly.gd")
const BagLuck = preload("bag_luck.gd")
const BagBrokeEgg = preload("bag_broke_egg.gd")
const EggAtlas = preload("broke_egg_atlas.gd")
const ItemTip = preload("item_tip.gd")
const TipAtlas = preload("item_tip_atlas.gd")
const FlashTip = preload("flash_tip.gd")
const CTip = preload("ctool_tip.gd")
const Mysterious = preload("mysterious_store.gd")
const SelfAtlas = preload("bag_self_atlas.gd")

signal closed
signal quick_buy_asked(tid: int, tip: String)
signal renew_asked(tid: int, kind: int, name: String)
signal horn_asked(channel: int)
signal luck_buy_asked(tid: int, count: int, tip: String)
signal guide_asked(tid: int)

const FRAME: Vector2 = Vector2(870, 566)
const EFFECT: Color = Color("ffaea3")
const EXTEND: Color = Color("42ff5d")
const ACEM_INK: Color = Color("f16422")
const LATE: Color = Color("fe9103")
const COIN_RIM: Color = Color("160000", 0.8)
const SPRAY_RIM: Color = Color("07639c", 0.8)
const MENU_BG: Color = Color("e9f9ff", 0.9)
const DOUBLE: float = 0.4
const SPRAY_PAGE: int = 12
const SPRAY_PITCH: float = 83.0
const HONOR_SHOWN: int = 9
const HONOR_PITCH: float = 52.0
const ACEM_SHOWN: int = 4
const LIST: Rect2 = Rect2(301, 172, 487, 244)
const STRIP: Rect2 = Rect2(312, 430, 470, 70)
const GIFT_TYPE: int = 20
const GIFT_WAIT: float = 2.0
const GIFT_GIVE_UP: float = 15.0
const SCHEME_KEY: int = 5600001
const GIFT_ASK: String = "Có phải muốn mở tất cả quà trong 1 lần"
const TANK_TIP: String = "Có Tank [%s] mới được mở quà này"
const TIP_103: String = "Hãy tới shop mua bình sơn"
const TIP_430: String = "Không thể gia hạn"
const X2_DAYS: String = "Còn %d ngày"
const X2_USES: String = "Còn %d lượt (hiệu lực với trận thắng)"
const X2_FIRST: String = "T.gian ưu tiên dùng còn"
const HONOR_WORN: String = "(Đang đeo)"
const SPRAY_TIP: String = "Khi chiến đấu, ấn phím F để phun hình, đổi hình tốn 1 bình sơn."
const RENEW_KIND: Dictionary = {28: 7, 30: 14}
const SPLIT_HINT: String = "Bấm vào vật phẩm muốn tách."
const SPLIT_AT: Vector2 = Vector2(596, 445)
const PICK_SIZE: float = 64.0
const LOCK_WAIT: float = 5.0

var _cat: String = "vp"
var _list: Array = []
var _pages: Dictionary = {}
var _stale: bool = true
var _fresh_at: float = -100.0
var _rev: int = -1
var _menu_key: String = ""
var _menu_at: Vector2 = Vector2.ZERO
var _selling: bool = false
var _filter: int = 0
var _acems: Array = []
var _scroll: int = 0
var _acem_pick: int = 0
var _honor_scroll: int = 0
var _spray_pick: int = 0
var _last_id: String = ""
var _last_at: float = -10.0
var _sheet_id: String = ""
var _sheet_key: String = ""
var _count: LineEdit
var _focus: LineEdit
var _reward: RefCounted = RewardPopup.new()
var _flies: Array = []
var _failed: bool = false
var _sorting: bool = false
var _tip: Array = []
var _ctip: CTip = CTip.new()
var _gifts: Array = []
var _gift_id: int = 0
var _gift_have: int = 0
var _gift_sent: float = -1.0
var _gift_award: float = -1.0
var _rename: Control = null
var _splitting: bool = false
var _split: Control = null
var _luck: Control = null
var _sel: Control = null
var _egg: Control = null
var _pick_key: String = ""
var _locks: Dictionary = {}

func chat_busy() -> bool:
	return not _sheet_id.is_empty() or _renaming() or _split_open() or _luck_open() or _sel_open() or _egg_open()

func _renaming() -> bool:
	return _rename != null and _rename.visible

func _split_open() -> bool:
	return _split != null and _split.visible

func _luck_open() -> bool:
	return _luck != null and _luck.visible

func _sel_open() -> bool:
	return _sel != null and _sel.visible

func _egg_open() -> bool:
	return _egg != null and _egg.visible

func _setup() -> void :
	_count = _fedit(4, true)
	_count.text_submitted.connect( func(_text: String) -> void : _confirm())
	client.changed.connect( func() -> void : _stale = true)
	pack.picture_ready.connect( func(path: String) -> void :
		if path == "l/bag.json":
			_failed = pack.bag.is_empty()
			_stale = true
		elif path == "l/bagx.json":
			_stale = true)
	client.noticed.connect( func(text: String) -> void :
		if is_visible_in_tree() and not _luck_open():
			say(text))
	client.awarded.connect(_on_award)
	client.item_failed.connect( func(_cont: int, _slot: int) -> void :
		_gift_stop()
		if is_visible_in_tree():
			var instance: Dictionary = client.bag_item(_cont, _slot)
			var item_id: int = int(instance.get("m_templateId", 0))
			var row: Array = pack.bag.get("items", {}).get(str(item_id), [])
			var item_name: String = BagModel._named(row, "Vật phẩm %d" % item_id)
			say("Chưa mở được %s (%d)." % [item_name, item_id]))
	client.item_swapped.connect(_on_swapped)

func _shown() -> void :
	if _count == null:
		return
	_gift_stop()
	_close()
	if _rename != null:
		_rename.close("")
	if _split != null:
		_split.close("")
	if _luck != null:
		_luck.close("")
	if _sel != null:
		_sel.close("")
	if _egg != null:
		_egg.close("")
	_menu_key = ""
	_selling = false
	_splitting = false
	_pick_key = ""
	_locks.clear()
	if not is_visible_in_tree():
		return
	pack.load_bag()
	client.bag_opened = true
	pack.load_bagx()
	if not client.bag_loaded:
		client.request_bags()
	_rep_load()
	_cat = "vp"
	_pages.clear()
	_reward.reset()
	_flies = []
	RewardFly.reset(self)
	_sorting = false
	_failed = false
	_stale = true
	_filter = 0
	_scroll = 0
	_acem_pick = 0
	_honor_scroll = 0
	_spray_pick = 0

func _tick(_delta: float) -> void :
	if _reward.tick(self) and _sheet_id == "award":
		_sheet_id = ""
	if _gift_sent >= 0.0:
		_gift_watch()
	for key: String in _locks.keys():
		if key != _pick_key and _time - float(_locks[key]) > LOCK_WAIT:
			_locks.erase(key)
	if client.bag_rev != _rev:
		_rev = client.bag_rev
		_stale = true
		if _sorting:
			_sorting = false
			say("Đã sắp xếp túi đồ.")
	if _sheet_id == "count":

		var top: int = BagModel.use_max(_sheet_rec())
		if int(_count.text) > top:
			_count.text = str(top)
			_count.caret_column = _count.text.length()

	if not _stale and _time - _fresh_at < 20.0:
		return
	_stale = false
	_fresh_at = _time
	_list = BagModel.entries(_cat, client.bags, client.sprays, client.honors, pack.bag, client.character, client.honors_worn, int(Time.get_unix_time_from_system()))
	_acems = BagModel.acem_list(pack.bagx.get("acem", {}), client.achievements, _filter)
	_scroll = clampi(_scroll, 0, maxi(0, _acems.size() - ACEM_SHOWN))
	if _sheet_id in ["count", "sell", "map_key"] and _sheet_rec().is_empty():
		_close()
	if not _menu_key.is_empty() and _find(_menu_key).is_empty():
		_menu_key = ""
	for key: String in _locks.keys():
		if _find(key).is_empty():
			_locks.erase(key)
	if not _pick_key.is_empty() and _find(_pick_key).is_empty():
		_pick_key = ""

func _loading() -> bool:
	return not client.bag_loaded or (pack.bag.is_empty() and not _failed)

func _find(key: String) -> Dictionary:
	for rec: Dictionary in _list:
		if str(rec.key) == key:
			return rec
	return {}

func _sheet_rec() -> Dictionary:
	return _find(_sheet_key)

func _main(rec: Dictionary) -> Array:
	return BagModel.primary(rec, pack.bag, client.state, BagModel.spray_cans(client.bags), client.honors_worn.size())

func _set_cat(cat: String) -> void :
	_menu_key = ""
	_selling = false
	_splitting = false
	_pick_key = ""
	_locks.clear()
	if cat == _cat:
		return
	_cat = cat
	_list = []
	_stale = true


func _page_count() -> int:
	match _cat:
		"vp":
			return BagModel.pages(int(BagModel.capacity("vp", 0, pack.bag, client.character)[1]), BagModel.PER_PAGE)
		"mat":
			return BagModel.pages(BagModel.MATERIAL_SLOTS, BagModel.PER_PAGE)
		"fashion", "decor":
			return BagModel.pages(_list.size(), BagModel.CARD_PAGE)
		"spray":
			return BagModel.pages(pack.bag.get("sprays", {}).size(), SPRAY_PAGE)
	return 1

func _page() -> int:
	return clampi(int(_pages.get(_cat, 0)), 0, _page_count() - 1)


func _swipe_once() -> bool:
	return _cat != "honor"

func _turn(step: int) -> void :
	_menu_key = ""
	_pages[_cat] = clampi(_page() + step, 0, _page_count() - 1)

func _open(kind: String, key: String) -> void :
	_sheet_id = kind
	_sheet_key = key
	_menu_key = ""
	_selling = false
	_splitting = false
	if kind == "count":
		_count.text = "1"
		_focus = _count

func _close() -> void :
	_sheet_id = ""
	_sheet_key = ""
	_focus = null
	_hide_edits()

func _on_award(info: Dictionary) -> void :
	if not is_visible_in_tree():
		return
	if _luck_open():
		return
	if _gift_sent >= 0.0:
		_gift_award = _time
	if not RewardPopup.has_rewards(info):
		return

	if _reward.active and _reward.closing_at >= 0.0:

		_flies.append_array(RewardFly.begin(self, _reward.info))
		_reward.reset()
	if _sheet_id != "award":
		_close()
		_reward.reset()
	_reward.begin(self, info)
	_sheet_id = "award"


func _award_close() -> void :
	_reward.request_close(self)
	_close()


func _operate(rec: Dictionary) -> void :
	if rec.is_empty():
		return
	var main: Array = _main(rec)
	if not main[2]:
		if not str(main[3]).is_empty():
			say(str(main[3]))
		return
	var sent: bool = true
	match str(main[0]):
		"use":
			var locked: String = _gift_locked(rec)
			if not locked.is_empty():
				say(locked)
				return
			sent = _use_rec(rec, 1)
		"ask":
			_open("count", str(rec.key))
		"wear":
			sent = client.use_item(int(rec.cont), int(rec.slot))
		"strip":
			sent = client.use_item(7, -1)
		"honor_on", "honor_off":
			sent = client.wear_honors(BagModel.honor_toggle(client.honors_worn, int(rec.id)))
		"to_spray":
			_set_cat("spray")
			say("Chọn một hình rồi bấm CHỌN.")
		"horn":
			horn_asked.emit(int(BagModel.SPEAKER_CHANNEL.get(int(rec.id), 0)))
		"wheel":
			page_asked.emit("fair:wheel")
		"luck":
			_open_luck()
		"sel_award":
			_open_sel_award(int(rec.id))
		"egg":
			_open_broke_egg(rec, int(rec.reuse))
		"rename":
			_open_rename(int(rec.id))
		"tip":
			say(str(main[3]))
		"map_key":
			if client.is_pairing():
				say(BagModel.TIP_PAIRING)
			else:
				_open("map_key", str(rec.key))
	if not sent:
		say("Chưa dùng được lúc này.")



func _use_rec(rec: Dictionary, amount: int) -> bool:
	if int(rec.get("type", 0)) == BagModel.DROP:
		var full: String = BagModel.drop_full(client.bags, pack.bag, client.character)
		if not full.is_empty():
			say(full)
			return true
		var hammer: int = int(EggAtlas.HAMMER.get(str(rec.id), 0))
		if hammer > 0:
			_open_broke_egg(rec, hammer)
			return true
	return client.use_item(int(rec.cont), int(rec.slot), amount)


func _open_broke_egg(rec: Dictionary, hammer: int) -> void :
	if _egg == null:
		_egg = BagBrokeEgg.new()
		_egg.client = client
		_egg.pack = pack
		_egg.hall = hall
		add_child(_egg)
		_egg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_egg.quick_buy_asked.connect( func(tid: int) -> void : quick_buy_asked.emit(tid, ""))
		_egg.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
	_menu_key = ""
	_selling = false
	_splitting = false
	_tip = []
	_hover = ""
	_egg.open(int(rec.cont), int(rec.slot), int(rec.id), hammer)


func _open_rename(id: int) -> void :
	if _rename == null:
		_rename = BagRename.new()
		_rename.client = client
		_rename.pack = pack
		_rename.hall = hall
		add_child(_rename)
		_rename.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_rename.quick_buy_asked.connect( func(tid: int) -> void : quick_buy_asked.emit(tid, ""))
		_rename.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
	_menu_key = ""
	_selling = false
	_tip = []
	_hover = ""
	_rename.open(int(BagModel.RENAME_KIND.get(id, BagRename.PLAYER_RENAME)))


func _open_split(rec: Dictionary) -> void :
	if _split == null:
		_split = BagSplit.new()
		_split.client = client
		_split.pack = pack
		_split.hall = hall
		add_child(_split)
		_split.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_split.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
	_menu_key = ""
	_selling = false
	_splitting = false
	_tip = []
	_hover = ""
	_split.open(int(rec.cont), int(rec.slot), int(rec.count), int(BagModel.capacity(_cat, 0, pack.bag, client.character)[1]))



func _open_luck() -> void :
	if _luck == null:
		_luck = BagLuck.new()
		_luck.client = client
		_luck.pack = pack
		_luck.hall = hall
		add_child(_luck)
		_luck.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_luck.buy_asked.connect( func(tid: int, count: int, tip: String) -> void : luck_buy_asked.emit(tid, count, tip))
		_luck.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
	_menu_key = ""
	_selling = false
	_splitting = false
	_tip = []
	_hover = ""
	_luck.open()


func _open_sel_award(id: int) -> void :
	if _sel == null:
		_sel = BagSelAward.new()
		_sel.client = client
		_sel.pack = pack
		_sel.hall = hall
		add_child(_sel)
		_sel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		_sel.closed.connect( func(note: String) -> void :
			if not note.is_empty():
				say(note))
	_menu_key = ""
	_selling = false
	_splitting = false
	_tip = []
	_hover = ""
	_sel.open(id)



func _on_swapped(cont: int, slot_a: int, slot_b: int) -> void :
	for key: String in _locks.keys():
		var rec: Dictionary = _find(key)
		if rec.is_empty() or (int(rec.cont) == cont and int(rec.slot) in [slot_a, slot_b]):
			_locks.erase(key)



func _drag(moved: Vector2, from: Vector2) -> void :


	if _mobile and _pick_key.is_empty() and not (_cat == "vp" and _sheet_id.is_empty() and _hit_at(from).begins_with("item:")):
		super (moved, from)
		return
	if not _pick_key.is_empty() or _cat != "vp" or not _sheet_id.is_empty() or _split_open() or _luck_open() or _sel_open() or _egg_open() or _renaming() or _loading():
		return
	var id: String = _hit_at(from)
	if not id.begins_with("item:"):
		return
	var key: String = id.substr(5)
	if _locks.has(key) or _find(key).is_empty():
		return
	_pick_key = key
	_locks[key] = _time
	_menu_key = ""
	_tip = []


func _gui_input(event: InputEvent) -> void :
	if not _pick_key.is_empty() and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_drop(_hit_at(event.position))
	super (event)



func _drop(id: String) -> void :
	var key: String = _pick_key
	_pick_key = ""
	var rec: Dictionary = _find(key)
	var target: int = -1
	if id.begins_with("item:"):
		var other: Dictionary = _find(id.substr(5))
		if not other.is_empty() and str(other.key) != key and not _locks.has(str(other.key)):
			target = int(other.slot)
	elif id.begins_with("cell:"):
		target = int(id.substr(5))
	if rec.is_empty() or target < 0 or target == int(rec.slot):
		_locks.erase(key)
		return
	if not client.swap_item(int(rec.cont), int(rec.slot), target, int(rec.count)):
		_locks.erase(key)
		say("Chưa thực hiện được lúc này.")

func _ask_sell(rec: Dictionary) -> void :
	if rec.is_empty():
		return
	var sale: Array = BagModel.sale(rec, client.state)
	if not sale[1]:
		say(str(sale[2]) if not str(sale[2]).is_empty() else "Vật phẩm này không thể bán.")
		return
	_open("sell", str(rec.key))

func _ask_expand() -> void :
	var cost: int = BagModel.expand_cost(pack.bag)
	if cost <= 0:
		say("Chưa biết giá mở rộng.")
		return
	if int(client.currency.get("m_iSilver", 0)) < cost:
		say("Không đủ Xu Khóa.")
		return
	_open("expand", "")


func _choose_spray() -> void :
	var id: int = _spray_pick
	if id <= 0:
		say("Hãy chọn một hình phun.")
		return
	if id == int(client.character.get("sprayId", 0)):
		say("Bạn đang dùng hình này.")
		return
	if not _owns_spray(id):
		say("Bạn chưa có hình phun này.")
		return
	if BagModel.spray_cans(client.bags) <= 0:
		quick_buy_asked.emit(BagModel.SPRAY_CAN, TIP_103)
		return
	if not client.use_spray(id):
		say("Chưa thực hiện được lúc này.")

func _owns_spray(id: int) -> bool:
	for value: Variant in client.sprays:
		if int(value) == id:
			return true
	return false


func _renew(rec: Dictionary) -> void :
	if rec.is_empty():
		return
	var kind: int = int(RENEW_KIND.get(int(rec.type), 0))
	if kind == 0:
		say(TIP_430)
		return
	renew_asked.emit(int(rec.id), kind, GarageModel.cap(str(rec.name)))

func _confirm() -> void :
	var kind: String = _sheet_id
	var rec: Dictionary = _sheet_rec()
	if kind == "count" and _count.text.strip_edges().is_empty():
		say("Hãy nhập số lượng dùng")
		return
	var amount: int = int(_count.text)
	_close()
	var sent: bool = true
	match kind:
		"count":
			if not rec.is_empty():
				var locked: String = _gift_locked(rec)
				if not locked.is_empty():
					say(locked)
					return
				sent = _use_rec(rec, clampi(amount, 1, BagModel.use_max(rec)))
		"sell":
			if not rec.is_empty() and BagModel.sale(rec, client.state)[1]:
				sent = client.sell_item(int(rec.cont), int(rec.slot))
		"expand":
			var cost: int = BagModel.expand_cost(pack.bag)
			if cost > 0 and int(client.currency.get("m_iSilver", 0)) >= cost:
				sent = client.expand_bag()
		"gift":
			_gift_start()
		"map_key":

			if not rec.is_empty() and client.state in ["lobby", "hall"] and client.room_state.room.is_empty():
				sent = client.use_item(int(rec.cont), int(rec.slot), 1)
		_:
			return
	if not sent:
		say("Chưa thực hiện được lúc này.")

func _bump(by: int) -> void :
	_count.text = str(clampi(int(_count.text) + by, 1, BagModel.use_max(_sheet_rec())))
	_count.caret_column = _count.text.length()



func _gift_locked(rec: Dictionary) -> String:
	var need: int = int(rec.get("reuse", 0))
	if str(rec.get("cat", "")) != "vp" or int(rec.get("type", 0)) != GIFT_TYPE or need <= 0:
		return ""
	for tank: Variant in client.tanks.values():
		if tank is Dictionary and int(tank.get("m_tpltId", 0)) == need and int(tank.get("m_contType", -1)) == GarageModel.OWN:
			return ""
	return TANK_TIP % str(pack.lobby.get("tanks", {}).get(str(need), need))


func _gift_count(id: int) -> int:
	var total: int = 0
	for inst: Dictionary in client.bags.get(2, []):
		if int(inst.get("m_templateId", 0)) == id:
			total += maxi(1, int(inst.get("m_count", 1)))
	return total

func _gift_stop() -> void :
	_gifts = []
	_gift_id = 0
	_gift_have = 0
	_gift_sent = -1.0
	_gift_award = -1.0



func _gift_start() -> void :
	var rows: Dictionary = pack.bag.get("items", {})
	var list: Array = client.bags.get(2, []).duplicate()
	list.sort_custom( func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("m_slotNo", 0)) < int(b.get("m_slotNo", 0)))
	_gifts = []
	for inst: Dictionary in list:
		var id: int = int(inst.get("m_templateId", 0))
		var row: Array = rows.get(str(id), [])
		if id != SCHEME_KEY and row.size() >= 10 and int(row[4]) == GIFT_TYPE and not _gifts.has(id):
			_gifts.append(id)
	if _gift_sent < 0.0:
		_gift_next()



func _gift_next() -> void :
	_gift_id = 0
	_gift_have = 0
	_gift_sent = -1.0
	_gift_award = -1.0
	var now: int = int(Time.get_unix_time_from_system())
	while not _gifts.is_empty():
		var id: int = int(_gifts[0])
		var pick: Dictionary = {}
		var expired: bool = false
		for inst: Dictionary in client.bags.get(2, []):
			if int(inst.get("m_templateId", 0)) != id or int(inst.get("m_slotNo", -1)) < 0:
				continue
			var rec: Dictionary = BagModel.entry("vp", inst, pack.bag, client.character, now)
			if rec.expired:
				expired = true
			elif pick.is_empty() or int(rec.slot) < int(pick.slot):
				pick = rec
		if pick.is_empty():
			if expired:
				say("Vật phẩm đã hết hạn.")
			_gifts.pop_front()
			continue
		var locked: String = _gift_locked(pick)
		if not locked.is_empty():
			say(locked)
			_gifts.pop_front()
			continue
		if id == SCHEME_KEY or int(pick.type) != GIFT_TYPE or not client.use_item(2, int(pick.slot), 1):
			_gift_stop()
			say("Chưa dùng được lúc này.")
			return
		_gift_id = id
		_gift_have = _gift_count(id)
		_gift_sent = _time
		return




func _gift_watch() -> void :
	var since: float = _time - maxf(_gift_sent, _gift_award)
	if _gift_count(_gift_id) < _gift_have and since >= GIFT_WAIT:
		_gift_next()
		if _sheet_id == "award":
			_award_close()
	elif since > GIFT_GIVE_UP:
		_gift_stop()



func _fit(picture: Texture2D, at: Vector2, box: Vector2, cap: float = 2.0, alpha: float = 1.0) -> void :
	if picture == null or picture.get_width() <= 4:
		return
	var k: float = minf(minf(box.x / picture.get_width(), box.y / picture.get_height()), cap)
	var extent: Vector2 = Vector2(picture.get_size()) * k
	draw_texture_rect(picture, Rect2((at + (box - extent) / 2.0) * _f, extent * _f), false, Color(1, 1, 1, alpha))


func _fbar(name: String, at: Vector2, wide: float, high: float, ratio: float) -> void :
	var cell: Array = _cells.get(name, [])
	if cell.is_empty() or cell[0] == null or ratio <= 0.0:
		return
	var part: float = clampf(ratio, 0.0, 1.0)
	var region: Array = cell[1]
	draw_texture_rect_region(cell[0], Rect2(at * _f, Vector2(wide * part, high) * _f), Rect2(float(region[0]), float(region[1]), float(region[2]) * part, float(region[3])))

func _peek(rec: Dictionary, rect: Rect2, body: String) -> void :
	if _sheet_id.is_empty() and _menu_key.is_empty() and _press.is_empty() and not _renaming() and not _split_open() and not _luck_open() and not _sel_open() and not _egg_open() and _pick_key.is_empty() and rect.has_point(get_local_mouse_position()):
		_tip = [rect, GarageModel.cap(str(rec.name)), body, BagModel.tint(int(rec.quality), Color.WHITE)]


func _peek_hint(rect: Rect2, text: String) -> void :
	_peek({"name": text, "quality": 0}, rect, "")
	if _tip.size() == 4 and _tip[0] == rect:
		_tip = [rect, text, "", Color.WHITE]


func _peek_item(rec: Dictionary, rect: Rect2) -> void :
	_peek(rec, rect, "")
	if _tip.size() == 4 and _tip[0] == rect:
		_tip = [rect, "", "", Color.WHITE, rec]

func _paint() -> void :
	if _cells.is_empty():
		_use(Arena.FILE, Arena.R)
		_use(Hall.FILE, Hall.R)
		_use(Shop.FILE, Shop.R)
		_use(Atlas.FILE, Atlas.R)
		_use(SplitAtlas.FILE, SplitAtlas.R)
		_use(TipAtlas.FILE, TipAtlas.R)
		_use(SelfAtlas.FILE, SelfAtlas.R)
	_tip = []
	_scene()
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var base: Vector2 = _centre(FRAME.x, FRAME.y)
	_hit("panel", Rect2(base * _f, FRAME * _f), false)
	_fblit("bag_frame", base + Vector2(2, 2))
	_fbutton("close", "public_button_close", base + Vector2(831, 15))
	_draw_tabs(base)
	_draw_self(base)
	if _loading():
		_fwords("Đang tải túi đồ…", BOLD, 16.0, Color.WHITE, "c", base + Vector2(270, 300), 580.0, 1.0, 24.0)
	elif _failed:
		_fwords("Không tải được bảng vật phẩm. Đóng rồi mở lại túi đồ.", BOLD, 16.0, Color.WHITE, "c", base + Vector2(270, 300), 580.0, 1.0, 24.0)
	else:
		match _cat:
			"vp", "mat":
				_draw_grid(base)
			"fashion", "decor":
				_draw_cards(base)
			"honor":
				_draw_honor(base)
			"spray":
				_draw_spray(base)
	_draw_menu()
	if _selling and _sheet_id.is_empty():

		_fblit("bag_coin_0", get_local_mouse_position() / _f + Vector2(10, 10))
	if not _pick_key.is_empty():
		_draw_pick()
	if _sheet_id == "count":
		_draw_count()
	else:
		_hide_edits()
		match _sheet_id:
			"sell", "expand", "gift", "map_key":
				_draw_ask()
			"award":
				pass
			_:
				_draw_tip()
	_reward.paint(self)
	_flies = RewardFly.paint(self, _flies)
	if _splitting and _sheet_id.is_empty() and SplitAtlas.CURSOR_OK:

		_fblit("bsp_cursor", get_local_mouse_position() / _f + Vector2(8, 8))
	if _focus != null and _focus.visible:
		if not preload("res://battle/touch_gfx.gd").touch_screen():
			_focus.grab_focus.call_deferred()
			_focus.select_all.call_deferred()
		_focus = null


func _draw_tabs(base: Vector2) -> void :
	for i in range(BagModel.CATS.size()):
		var cat: String = str(BagModel.CATS[i])
		var id: String = "cat:" + cat
		var tab: Array = Atlas.TABS[i]
		var at: Vector2 = base + Vector2(float(tab[0]), float(tab[1]))
		_fbutton(id, "shop_nav_sel" if cat == _cat else "shop_nav", at)
		var word: String = "bag_navw_%d" % i
		_fblit(word, at + ((Vector2(float(tab[2]), float(tab[3])) - _cell_size(word)) / 2.0).round(), 0.0, 0.0, _glow(id))


func _draw_self(base: Vector2) -> void :
	var basic: Dictionary = client.character
	var now: int = int(Time.get_unix_time_from_system())
	_draw_self_frame(base)
	var ornate: String = str(pack.bagx.get("ornate", {}).get(str(int(basic.get("decorateId", 0))), ""))
	var box: Rect2 = _ornate_box(base, ornate)
	if box.size.x > 0.0:
		var frame: Texture2D = pack.picture(ornate_picture(ornate))
		if frame != null and frame.get_width() > 4:
			draw_texture_rect(frame, Rect2(box.position * _f, box.size * _f), false)
	_fblit("level_%d" % clampi(int(basic.get("level", 1)), 0, 40), base + Vector2(17, 60), 56.0, 28.0)
	_level_fx(int(basic.get("level", 1)), base + Vector2(17, 60), 56.0)
	var vip: int = mini(12, _vip_level(int(basic.get("vipPoints", 0))))
	var style: Array = HallScreen.name_style(vip)
	var who: String = str(basic.get("name", client.account.get("name", "")))
	if not NameStyles.paint(self, who, BOLD, 12.0, "c", base + Vector2(67, 63), 152.0, 1.0, 24.0):
		_fwords(who, BOLD, 12.0, style[0], "c", base + Vector2(67, 63), 152.0, 1.0, 24.0, true, style[1])
	var key: String = str(pack.lobby.get("avatars", {}).get(str(int(basic.get("avatarId", 0))), ""))
	var figure: Texture2D = pack.picture("l/av/%s.webp" % key) if not key.is_empty() else null
	if figure != null and figure.get_width() > 4:
		draw_texture_rect(figure, Rect2((base + Vector2(34, 94)) * _f, Vector2(180, 240) * _f), false)
	if vip > 0:
		_fblit("shop_vip%d" % mini(12, vip), base + Vector2(160, 95))
	var at: Vector2 = base + Vector2(19, 50)
	for row: Array in X2_ROWS:
		var left: int = int(basic.get(str(row[2]), 0)) - now
		var uses: int = int(basic.get(str(row[3]), 0))
		if left <= 0 and uses <= 0:
			continue
		var spot: Array = Atlas.X2[str(row[0])]
		var rect: Rect2 = _fblit(str(row[1]), at + Vector2(float(spot[0]), float(spot[1])))
		var id: String = "x2:" + str(row[1])
		_hit(id, rect, false)
		if _hover == id and _sheet_id.is_empty():
			_tip = [rect, x2_tip(str(row[4]), left, uses), "", Color.WHITE]
	var fx: Dictionary = pack.bagx.get("fx", {})
	var decor_fx: String = BagModel.decor_fx(fx, int(basic.get("decorateId", 0))) if int(basic.get("decorateId", 0)) > 0 else ""
	var avatar_fx: String = BagModel.avatar_fx(fx, int(basic.get("avatarId", 0))) if int(basic.get("avatarId", 0)) > 0 else ""
	if not decor_fx.is_empty():
		_fwords(decor_fx, BOLD, 13.0, EFFECT, "c", base + Vector2(27.5, 305), 193.0, 1.0)
	if not avatar_fx.is_empty():
		_fwords(avatar_fx, BOLD, 13.0, EFFECT, "c", base + Vector2(27.5, 323), 193.0, 1.0)
	var level: int = int(basic.get("level", 1))
	var exp: int = int(basic.get("exp", 0))
	var need: int = int(pack.bagx.get("lvexp", {}).get(str(level), 0))
	_fblit("bag_exp_track", base + Vector2(82, 358))
	if need > 0:
		_fbar("bag_exp_bar", base + Vector2(83, 359), 134.0, 14.0, exp / float(need))
	_fwords("%d/%d" % [exp, need] if need > 0 else str(exp), BOLD, EXP_PX, Color.WHITE, "c", base + Vector2(82, 358), 136.0, 0.0, 16.0)
	var guild_name: String = str(client.guild.get("strName", "")) if not client.guild.is_empty() else ""
	var stats: Array = BagModel.game_stats(client.technologies)
	var place: int = 0
	if client.guild_self_team > 0:
		for team: Variant in client.guild_teams:
			if team is Dictionary and int((team as Dictionary).get("nTeamId", 0)) == client.guild_self_team:
				place = int((team as Dictionary).get("nPlace", 0))
	var values: Array = [[382, guild_name if not guild_name.is_empty() else "Chưa gia nhập"], [411, str(stats[0])], [440, _rep_text], [469, "Giải Team: %d" % place]]
	for row: Array in values:


		var spot: Vector2 = Vector2(VALUE_X[1] if int(row[0]) == 469 else VALUE_X[0], float(row[0]))
		_fwords(str(row[1]), BOLD, 12.0, Color.WHITE, "l", base + spot, 138.0 - (spot.x - 82.0) - 2.0, 0.0, 21.0)


func _draw_grid(base: Vector2) -> void :
	var origin: Vector2 = base + Vector2(285, 113)
	var page: int = _page()
	var by_slot: Dictionary = {}
	for rec: Dictionary in _list:
		by_slot[int(rec.slot)] = rec
	var room: int = int(BagModel.capacity(_cat, 0, pack.bag, client.character)[1])
	for i in range(BagModel.PER_PAGE):
		if not cell_shown(page, i, room):
			continue
		var at: Vector2 = origin + Vector2(float(i % 9) * 57.0, float(i / 9) * 57.0)
		_fblit("bag_cell_bg", at)
		var rec: Dictionary = by_slot.get(page * BagModel.PER_PAGE + i, {})
		if not rec.is_empty():
			_draw_cell(rec, at)
		elif _cat == "vp" and page * BagModel.PER_PAGE + i < room:
			_hit("cell:%d" % (page * BagModel.PER_PAGE + i), Rect2(at * _f, Vector2(55, 55) * _f), false)
	_draw_split_btn(base)
	if _cat == "vp":
		_fbutton("tidy", "bag_btn_tidy", base + Vector2(700, 413))
		_fbutton("sellmode", "bag_btn_sell", base + Vector2(700, 445))
		_fbutton("shop", "bag_btn_shop", base + Vector2(700, 475))
		_fbutton("openall", "bag_btn_gift", base + Vector2(596, 475))
		var grocery: int = int(client.character.get("grocery_add", 0))
		if pager_shown(grocery):
			_draw_pager(base, Vector2(497, 411.5), [], [463.5, 413.5], [583.5, 413.5], [], [511.5, 428, 57])
		if extend_shown(grocery):


			var id: String = "expand"
			var box: Vector2 = base + EXTEND_AT - Vector2(60, 10)
			var wide: float = _fwords("Mở rộng kho", BOLD, 16.0, EXTEND * _glow(id), "c", box, 120.0, 0.0, 20.0)
			var under: Vector2 = base + EXTEND_AT + Vector2(0, 9)
			draw_line((under - Vector2(wide / 2.0, 0)) * _f, (under + Vector2(wide / 2.0, 0)) * _f, EXTEND * _glow(id), maxf(1.0, _f))
			_hit(id, Rect2(box * _f, Vector2(120, 20) * _f), false)
	else:
		_fbutton("tidy", "bag_btn_tidy", base + Vector2(700, 413))
		_fbutton("sellmode", "bag_btn_sell", base + Vector2(700, 445))

		_draw_pager(base, Vector2(529, 411.5), [449, 413.5], [495.5, 413.5], [615.5, 413.5], [649, 413.5], [543.5, 428, 57])
	_draw_coins(base)


func _draw_cell(rec: Dictionary, at: Vector2) -> void :
	var key: String = str(rec.key)
	var quality: int = int(rec.quality)
	if quality >= 2 and quality <= 5:
		_fblit("bag_q%d" % quality, at + Vector2(2, 2))
	var icon: Texture2D = pack.picture(str(rec.icon)) if not str(rec.icon).is_empty() else null
	if icon != null and icon.get_width() > 4:
		draw_texture_rect(icon, Rect2((at + Vector2(3, 3)) * _f, Vector2(50, 50) * _f), false)
	if bool(rec.expired):
		_fblit("bag_overdue", at + Vector2(5, 11.5))
	elif bool(rec.timed) and bool(rec.get("soon", false)):
		_fblit("bag_clock", at + Vector2(32, 3))
	if int(rec.count) > 1:
		_fwords(str(int(rec.count)), BOLD, 12.0, Color.WHITE, "r", at + Vector2(5, 37), 50.0, 1.0, 18.0)
	if key == _menu_key:
		_fblit("bag_select", at + Vector2(-1, -1))
	if _locks.has(key):
		_fblit("bag_lock", at + Vector2(14, 14))
	var rect: Rect2 = Rect2(at * _f, Vector2(55, 55) * _f)
	_hit("item:" + key, rect, false)
	_peek_item(rec, rect)


func _draw_split_btn(base: Vector2) -> void :
	var at: Vector2 = base + SPLIT_AT
	_fbutton("splitmode", "bsp_btn", at)
	_fblit("bsp_btn_t", at + ((_cell_size("bsp_btn") - _cell_size("bsp_btn_t")) / 2.0).round(), 0.0, 0.0, _glow("splitmode"))


func _draw_pick() -> void :
	var rec: Dictionary = _find(_pick_key)
	var icon: Texture2D = pack.picture(str(rec.icon)) if not rec.is_empty() and not str(rec.icon).is_empty() else null
	if icon != null and icon.get_width() > 4:
		draw_texture_rect(icon, Rect2(get_local_mouse_position() - Vector2(16, 16) * _f, Vector2(PICK_SIZE, PICK_SIZE) * _f), false)


func _draw_pager(base: Vector2, bg: Vector2, first: Array, prev: Array, next: Array, last: Array, label: Array) -> void :
	_fblit("bag_pager_bg", base + bg)
	if not first.is_empty():
		_fbutton("page:first", "bag_pg_first", base + Vector2(float(first[0]), float(first[1])))
	_fbutton("page:prev", "bag_pg_prev", base + Vector2(float(prev[0]), float(prev[1])))
	_fbutton("page:next", "bag_pg_next", base + Vector2(float(next[0]), float(next[1])))
	if not last.is_empty():
		_fbutton("page:last", "bag_pg_last", base + Vector2(float(last[0]), float(last[1])))
	_fwords("%d/%d" % [_page() + 1, _page_count()], BOLD, 15.0, Color.WHITE, "c", base + Vector2(float(label[0]), float(label[1]) - 10.0), float(label[2]), 1.0, 20.0)


func _draw_coins(base: Vector2) -> void :
	var rows: Array = [["Xu", "m_iCash", 404.0], ["Xu khóa", "m_iSilver", 429.0], ["Bạc", "m_iGolden", 454.0]]
	for i in range(rows.size()):
		var spot: Array = Atlas.COINS[i]
		_fblit("bag_coin_%d" % i, base + Vector2(float(spot[0]), float(spot[1])))
		_fwords("%s: %s" % [str(rows[i][0]), Mysterious.comma(int(client.currency.get(str(rows[i][1]), 0)))], BOLD, 16.0, Color.WHITE, "l", base + Vector2(314, float(rows[i][2])), 150.0, 1.0, 0.0, true, COIN_RIM)


func _draw_cards(base: Vector2) -> void :
	var ordered: Array = BagModel.card_order(_list)
	var page: int = _page()
	var fx: Dictionary = pack.bagx.get("fx", {})
	for i in range(BagModel.CARD_PAGE):
		var index: int = page * BagModel.CARD_PAGE + i
		if index >= ordered.size():
			break
		var rec: Dictionary = ordered[index]
		var key: String = str(rec.key)
		var card: Vector2 = base + Vector2(float(Atlas.CARDS["x"][i]), 111)
		_fblit("bag_card", card)
		if _cat == "fashion":
			var figure: Texture2D = pack.picture(str(rec.art)) if not str(rec.art).is_empty() else null
			if figure != null and figure.get_width() > 4:
				draw_texture_rect(figure, Rect2((card + Vector2(14, 45)) * _f, Vector2(144, 192) * _f), false)
		else:
			var stem: String = str(pack.bagx.get("ornate", {}).get(str(int(rec.id)), ""))
			var art: Texture2D = pack.picture("l/or/%s.webp" % stem) if not stem.is_empty() else (pack.picture(str(rec.icon)) if not str(rec.icon).is_empty() else null)
			_fit(art, card + Vector2(14, 45), Vector2(144, 192))
		_fwords(GarageModel.cap(str(rec.name)), BOLD, 14.0, BagModel.tint(int(rec.quality), Color.WHITE), "c", card + Vector2(27, 11), 113.0, 1.0)
		if bool(rec.active):
			_fblit("bag_check", card + Vector2(122, 6))
		var when : Array = BagModel.card_time(rec)
		var font_size: int = maxi(6, roundi(12.0 * _f))
		var w1: float = ARIAL_BOLD.get_string_size(str( when [0]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f
		var w2: float = ARIAL_BOLD.get_string_size(str( when [1]), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / _f if not str( when [1]).is_empty() else 0.0
		var x0: float = card.x + 10.0 + (146.0 - w1 - w2) / 2.0
		_fwords(str( when [0]), BOLD, 12.0, Color.WHITE, "l", Vector2(x0, card.y + 265.0), w1 + 4.0, 1.0, 0.0, false)
		if w2 > 0.0:
			_fwords(str( when [1]), BOLD, 12.0, LATE, "l", Vector2(x0 + w1, card.y + 265.0), w2 + 4.0, 1.0, 0.0, false)
		var effect: String = BagModel.avatar_fx(fx, int(rec.id)) if _cat == "fashion" else BagModel.decor_fx(fx, int(rec.id))
		if not effect.is_empty():
			_fwords(effect, BOLD, 13.0, EFFECT, "c", card + Vector2(8, 237), 150.0, 1.0)
		if bool(rec.timed):
			_fblit("bag_pay_bg", card + Vector2(38, 285))
			_fbutton("pay:" + key, "bag_btn_pay", card + Vector2(40, 287))
		var rect: Rect2 = Rect2((card + Vector2(14, 45)) * _f, Vector2(144, 192) * _f)
		_hit("card:" + key, rect, false)
		_peek_item(rec, rect)
	if _cat == "fashion":
		_draw_pager(base, Vector2(497, 452), [417, 454], [463.5, 454], [583.5, 454], [617, 454], [511.5, 468.5, 57])
	else:
		_draw_pager(base, Vector2(497, 440), [417, 442], [463.5, 442], [583.5, 442], [617, 442], [511.5, 456.5, 57])
		_fbutton("strip", "bag_btn_strip", base + Vector2(490, 476))


func _draw_honor(base: Vector2) -> void :
	_fblit("bag_p_acem", base + Vector2(270, 100))

	_fblit("bself_acem_pt", base + Vector2(float(SelfAtlas.ACEM_PT_AT[0]), float(SelfAtlas.ACEM_PT_AT[1])))
	_fblit("bself_acem_cnt", base + Vector2(float(SelfAtlas.ACEM_CNT_AT[0]), float(SelfAtlas.ACEM_CNT_AT[1])))
	var acem: Dictionary = pack.bagx.get("acem", {})
	var stats: Array = BagModel.acem_stats(acem, client.achievements)
	_fwords(str(stats[0]), BOLD, 12.0, Color.WHITE, "c", base + Vector2(373, 104), 60.0, 1.0)
	_fwords("%d/%d" % [int(stats[1]), int(stats[2])], BOLD, 12.0, Color.WHITE, "c", base + Vector2(364, 145), 80.0, 1.0)
	var filters: Array = [["btnAll", "bag_optw_all"], ["btnComplete", "bag_optw_done"], ["btnUnreach", "bag_optw_todo"]]
	for i in range(filters.size()):
		var spot: Array = Atlas.ACEM[str(filters[i][0])]
		var at: Vector2 = base + Vector2(float(spot[0]), float(spot[1]))
		var id: String = "filter:%d" % i
		if _filter == i:
			_fblit("bag_opt_on", at)
		var word: String = str(filters[i][1])
		_fblit(word, at + ((Vector2(85, 26) - _cell_size(word)) / 2.0).round(), 0.0, 0.0, _glow(id))
		_hit(id, Rect2(at * _f, Vector2(85, 26) * _f), false)
	var done: Dictionary = client.achievements
	for i in range(ACEM_SHOWN):
		var index: int = _scroll + i
		if index >= _acems.size():
			break
		var id: int = int(_acems[index])
		var row: Array = acem.get(str(id), [])
		if row.size() < 6:
			continue
		var at: Vector2 = base + LIST.position + Vector2(0, float(i) * 62.0)
		_fblit("bag_ach_sel" if id == _acem_pick else "bag_ach", at + Vector2(1, 1))
		if not str(row[2]).strip_edges().is_empty():
			_fit(pack.picture("l/ac/%s.webp" % str(row[2])), at + Vector2(6, 6), Vector2(49, 49))
		_fwords(str(row[0]), BOLD, 16.0, ACEM_INK, "l", at + Vector2(61, 7), 266.0)
		_fwords(str(row[1]), BOLD, 13.0, ACEM_INK, "l", at + Vector2(61, 31), 266.0)

		_fwords("Điểm thành tích: %d" % int(row[3]), BOLD, 13.0, ACEM_INK, "r", at + Vector2(ACEM_TEXT_RIGHT - 200.0, 7), 200.0)
		var need: int = int(row[5])
		if need > 0:
			_fwords("Tiến độ: %d/%d" % [mini(BagModel.acem_count(done, id), need), need], BOLD, 13.0, ACEM_INK, "r", at + Vector2(ACEM_TEXT_RIGHT - 200.0, 31), 200.0)
		_hit("acem:%d" % id, Rect2(at * _f, Vector2(LIST.size.x - ACEM_BAR, 61) * _f), false)


	var x: float = LIST.end.x - ACEM_BAR
	_fbutton("scroll:up", "bag_sb_up", base + Vector2(x, LIST.position.y))
	_fbutton("scroll:down", "bag_sb_down", base + Vector2(x, LIST.end.y - 19.0))
	var track: float = LIST.size.y - 38.0
	_fblit("bag_sb_bk", base + Vector2(x, LIST.position.y + 19.0), 0.0, track)
	if _acems.size() > ACEM_SHOWN:
		var thumb: float = maxf(20.0, track * ACEM_SHOWN / float(_acems.size()))
		var top: float = (track - thumb) * _scroll / float(_acems.size() - ACEM_SHOWN)
		var most: int = _acems.size() - ACEM_SHOWN
		var knob: Rect2 = _fblit("bag_sb_block", base + Vector2(x, LIST.position.y + 19.0 + top), 0.0, thumb, _glow("slide:acem"))
		_knob_hit("slide:acem", knob, _scroll, most, (track - thumb) * _f, func(value: float) -> void : _scroll = clampi(roundi(value), 0, most))
	elif _acems.is_empty() and not acem.is_empty():
		_fwords("Chưa có thành tích nào trong mục này.", BOLD, 14.0, Color.WHITE, "c", base + Vector2(301, 280), 487.0, 1.0)
	var worn: Array = client.honors_worn
	if _list.is_empty():
		_fwords("Hiện không có huân chương! Hãy cố gắng thêm nhé!", BOLD, 14.0, Color.WHITE, "c", base + Vector2(306, 465), 480.0, 1.0)
		return
	var y: float = STRIP.position.y + (10.0 if _list.size() <= HONOR_SHOWN else 0.0)
	_honor_scroll = clampi(_honor_scroll, 0, maxi(0, _list.size() - HONOR_SHOWN))
	for i in range(HONOR_SHOWN):
		var index: int = _honor_scroll + i
		if index >= _list.size():
			break
		var medal: Dictionary = _list[index]
		var id: int = int(medal.id)
		var at: Vector2 = base + Vector2(STRIP.position.x + float(i) * HONOR_PITCH, y)
		_fblit("bag_honor_cell", at)
		_fit(pack.picture(str(medal.icon)), at + Vector2(5, 5), Vector2(40, 40))
		if not worn.is_empty() and int(worn[0]) == id:
			_fblit("bag_honor_on", at + Vector2(26, 26))
		var rect: Rect2 = Rect2(at * _f, Vector2(50, 50) * _f)
		_hit("honor:%d" % id, rect, false)

		var body: String = GarageModel.plain(str(medal.desc))
		if worn.has(id):
			body += HONOR_WORN
		_peek_hint(rect, body)


	if _list.size() > HONOR_SHOWN:
		var most: int = _list.size() - HONOR_SHOWN
		_hscroll("hsb", ["bag_sb_up", "bag_sb_down", "bag_sb_bk", "bag_sb_block"], base + Vector2(STRIP.position.x, STRIP.end.y - 19.0), STRIP.size.x, 
			_honor_scroll, HONOR_SHOWN, _list.size(), func(value: float) -> void : _honor_scroll = clampi(roundi(value), 0, most))


func _draw_spray(base: Vector2) -> void :
	_fblit("bag_p_spray", base + Vector2(323, 130))
	var cans: int = BagModel.spray_cans(client.bags)
	var templates: Dictionary = pack.bag.get("sprays", {})
	var ids: Array = []
	for key: String in templates:
		ids.append(int(key))
	ids.sort()
	_fwords("Đổi hình phun tốn 1 bình sơn", BOLD, 14.0, Color.WHITE, "l", base + Vector2(322.5, 95), 287.0, 1.0, 0.0, true, SPRAY_RIM)
	_fwords("Đang", BOLD, 16.0, Color.WHITE, "l", base + Vector2(330, 150), 90.0, 1.0)
	_fwords("dùng", BOLD, 16.0, Color.WHITE, "l", base + Vector2(330, 172), 90.0, 1.0)
	var current: int = int(client.character.get("sprayId", 0))
	var now_row: Array = templates.get(str(current), [])
	if now_row.size() > 2 and not str(now_row[2]).is_empty():
		_fit(pack.picture("l/sp/%s.webp" % str(now_row[2])), base + Vector2(425, 150), Vector2(80, 80))
	_fwords("Bình X%d" % cans, BOLD, 14.0, Color.WHITE, "c", base + Vector2(677, 107), 88.0, 1.0)
	_fbutton("buyspray", "bag_btn_buyspray", base + Vector2(670, 133))
	var page: int = _page()
	for i in range(SPRAY_PAGE):
		var index: int = page * SPRAY_PAGE + i
		if index >= ids.size():
			break
		var id: int = int(ids[index])
		var row: Array = templates.get(str(id), [])
		var at: Vector2 = base + Vector2(276.0 + float(i % 6) * SPRAY_PITCH, 247.0 + float(i / 6) * SPRAY_PITCH)
		_fblit("bag_spray_cell", at)
		var owned: bool = _owns_spray(id)
		if row.size() > 2 and not str(row[2]).is_empty():
			_fit(pack.picture("l/sp/%s.webp" % str(row[2])), at + Vector2(4, 4), Vector2(70, 70), 2.0, 1.0 if owned else 0.45)
		if id == _spray_pick:
			_fblit("bag_spray_sel", at)
		var rect: Rect2 = Rect2(at * _f, Vector2(78, 78) * _f)
		_hit("spray:%d" % id, rect, false)

		_peek_hint(rect, SPRAY_TIP)
	_draw_pager(base, Vector2(497, 425), [417, 429], [463.5, 429], [583.5, 429], [617, 428], [505.5, 443.5, 63])
	_fbutton("choose", "bag_btn_choose", base + Vector2(492, 462))
	_fwords("Double click", BOLD, 13.0, Color.WHITE, "r", base + Vector2(366, 467), 120.0, 1.0)


func _draw_menu() -> void :
	if _menu_key.is_empty() or not _sheet_id.is_empty():
		return
	var at: Vector2 = _menu_at
	_round(Rect2(at * _f, Vector2(68, 70) * _f), MENU_BG, 10.0, Color.WHITE, 2.0)
	var rows: Array = [["menu:use", 1.0, "Xài"], ["menu:sell", 33.0, "Bán"]]
	for row: Array in rows:
		var id: String = str(row[0])
		var spot: Vector2 = at + Vector2(3, float(row[1]))
		_fbutton(id, "bag_menu_btn", spot)
		_fwords(str(row[2]), BOLD, 16.0, Color.WHITE, "c", spot, 60.0, 1.0, 32.0)

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


func _draw_item_tip(rec: Dictionary) -> void :
	FlashTip.item(self, rec)



func _shade(wide: float, high: float) -> Vector2:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0, 0, 0, 0.35))
	_hit("shade", Rect2(Vector2.ZERO, size), false)
	var at: Vector2 = _centre(wide, high)
	_hit("panel", Rect2(at * _f, Vector2(wide, high) * _f), false)
	return at


func _draw_ask() -> void :
	var at: Vector2 = _shade(450.0, 220.0)
	_fblit("bag_ask_guy", at + Vector2(-80, -76))
	_fblit("bag_ask", at + Vector2(46, 1))
	var text: String = ""
	if _sheet_id == "sell":
		var rec: Dictionary = _sheet_rec()
		text = "Đồng ý bán %d %s không? Nhận về %d %s" % [int(rec.get("count", 1)), GarageModel.cap(str(rec.get("name", ""))), int(rec.get("price", 0)), str(rec.get("coin", ""))]
	elif _sheet_id == "gift":
		text = GIFT_ASK
	elif _sheet_id == "map_key":
		text = BagModel.map_key_ask(_sheet_rec())
	else:
		var slots: int = int(BagModel.capacity("vp", 0, pack.bag, client.character)[1])
		text = "Tốn %d Xu Khóa để mở rộng kho đồ (đang có %d ô). Đồng ý không?" % [BagModel.expand_cost(pack.bag), slots]
	_fpara(text, BOLD, 14.0, Color.WHITE, at + Vector2(102, 38), 270.0, 5)
	_fbutton("ok", "bag_ask_ok", at + Vector2(120, 133))
	_fbutton("cancel", "bag_ask_no", at + Vector2(240, 133))


func _draw_count() -> void :
	var rec: Dictionary = _sheet_rec()
	if rec.is_empty():
		_hide_edits()
		return
	var at: Vector2 = _shade(350.0, 280.0)
	_fblit("bag_use", at + Vector2(2, 2))
	_fbutton("cancel", "public_button_close", at + Vector2(311, 15))
	var quality: int = int(rec.quality)
	if quality >= 2 and quality <= 5:
		_fblit("bag_q%d" % quality, at + Vector2(66, 81), 46.0, 46.0)
	var icon: Texture2D = pack.picture(str(rec.icon)) if not str(rec.icon).is_empty() else null
	if icon != null and icon.get_width() > 4:
		draw_texture_rect(icon, Rect2((at + Vector2(64, 79)) * _f, Vector2(52, 49) * _f), false)
	_fwords(str(int(rec.count)), BOLD, 11.0, Color.WHITE, "r", at + Vector2(30, 112), 85.0, 1.0)
	_fwords("Chọn số lượng dùng", BOLD, 16.0, Color.WHITE, "l", at + Vector2(120, 73), 200.0, 1.0)
	_fwords("Có: %d" % int(rec.count), BOLD, 16.0, Color.WHITE, "l", at + Vector2(120, 105), 200.0, 1.0)
	_fbutton("less", "bag_use_minus", at + Vector2(92.5, 157.5))
	_fput(_count, Rect2(at + Vector2(145, 155), Vector2(60, 30)), 16.0, "c")
	_fbutton("more", "bag_use_plus", at + Vector2(232.5, 157.5))
	_fbutton("max", "bag_use_max", at + Vector2(261, 157))
	_fbutton("ok", "bag_use_ok", at + Vector2(115, 228))



func _wheel(step: int, at: Vector2) -> void :
	if not _sheet_id.is_empty():
		return
	if _cat == "honor":
		var p: Vector2 = at / _f - _centre(FRAME.x, FRAME.y)
		if LIST.has_point(p):
			_scroll = clampi(_scroll + step, 0, maxi(0, _acems.size() - ACEM_SHOWN))
		elif STRIP.has_point(p):
			_honor_scroll = clampi(_honor_scroll + step, 0, maxi(0, _list.size() - HONOR_SHOWN))
		return
	_turn(step)

func _input(event: InputEvent) -> void :
	if not _sheet_id.is_empty() and is_visible_in_tree() and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if _sheet_id == "award":
			_award_close()
		else:
			_close()
		get_viewport().set_input_as_handled()

func _unhandled_key_input(event: InputEvent) -> void :

	if not is_visible_in_tree() or not _sheet_id.is_empty() or not (event is InputEventKey and event.pressed) or event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	match event.keycode:
		KEY_ESCAPE:
			if not _menu_key.is_empty():
				_menu_key = ""
			elif _selling:
				_selling = false
			elif _splitting:
				_splitting = false
			else:
				closed.emit()
		KEY_LEFT:
			_turn(-1)
		KEY_RIGHT:
			_turn(1)
		_:
			return
	get_viewport().set_input_as_handled()


func _double(id: String) -> bool:
	var again: bool = id == _last_id and _time - _last_at < DOUBLE
	_last_id = "" if again else id
	_last_at = _time
	return again

func _activate(id: String) -> void :
	if _sheet_id == "award":
		if id == "ok":
			_award_close()
		return
	if not _sheet_id.is_empty():
		match id:
			"shade", "cancel":
				_close()
			"ok":
				_confirm()
			"less":
				_bump(-1)
			"more":
				_bump(1)
			"max":
				_bump(BagModel.USE_CAP)
		return
	if not _menu_key.is_empty():
		var key: String = _menu_key
		_menu_key = ""
		match id:
			"menu:use":
				_operate(_find(key))
				return
			"menu:sell":
				_ask_sell(_find(key))
				return
	if _selling:
		_selling = false
		if id.begins_with("item:"):
			if not _locks.has(id.substr(5)):
				_ask_sell(_find(id.substr(5)))
			return
		if id in ["shade", "panel", "sellmode"]:
			return
	if _splitting:
		_splitting = false
		if id.begins_with("item:"):
			var rec: Dictionary = _find(id.substr(5))
			if not rec.is_empty() and int(rec.count) > 1 and not _locks.has(str(rec.key)):
				_open_split(rec)
			return
		if id in ["shade", "panel", "splitmode"]:
			return
	var cut: int = id.find(":")
	var head: String = id.left(cut) if cut >= 0 else id
	var tail: String = id.substr(cut + 1) if cut >= 0 else ""
	match head:
		"cat":
			_set_cat(tail)
		"item":
			var rec: Dictionary = _find(tail)
			if rec.is_empty() or _locks.has(tail):
				return
			if _cat == "mat":
				guide_asked.emit(int(rec.id))
				return
			if _double(id):
				_operate(rec)
			else:
				var at: Vector2 = get_local_mouse_position() / _f
				_menu_at = Vector2(minf(at.x, _fw - 70.0), minf(at.y, _fh - 72.0))
				_menu_key = tail
		"card":
			_operate(_find(tail))
		"page":
			match tail:
				"first":
					_turn( - _page_count())
				"prev":
					_turn(-1)
				"next":
					_turn(1)
				"last":
					_turn(_page_count())
		"scroll":
			_scroll = clampi(_scroll + (-1 if tail == "up" else 1), 0, maxi(0, _acems.size() - ACEM_SHOWN))
		"hsb":

			var step: int = {"left": -1, "right": 1, "pgl": - HONOR_SHOWN, "pgr": HONOR_SHOWN}.get(tail, 0)
			_honor_scroll = clampi(_honor_scroll + step, 0, maxi(0, _list.size() - HONOR_SHOWN))
		"tidy":
			if client.sort_bag(int(BagModel.CONT[_cat])):
				_sorting = true
			else:
				say("Chưa sắp xếp được lúc này.")
		"sellmode":
			_selling = true
			say("Bấm vào vật phẩm muốn bán.")
		"splitmode":
			_splitting = true
			say(SPLIT_HINT)
		"shop":
			page_asked.emit("shop")
		"openall":
			_open("gift", "")
		"expand":
			_ask_expand()
		"strip":

			if int(client.character.get("decorateId", 0)) == 0:
				return
			if not client.use_item(7, -1):
				say("Chưa dùng được lúc này.")
		"pay":
			_renew(_find(tail))
		"filter":
			_filter = int(tail)
			_scroll = 0
			_stale = true
		"acem":
			_acem_pick = int(tail)
		"honor":
			var want: int = int(tail)
			var worn: Array = client.honors_worn
			if not worn.is_empty() and int(worn[0]) == want:
				return
			if not client.wear_honors(BagModel.honor_pick(worn, want)):
				say("Chưa thực hiện được lúc này.")
		"spray":
			_spray_pick = int(tail)
			if _double(id):
				_choose_spray()
		"choose":
			_choose_spray()
		"buyspray":
			quick_buy_asked.emit(BagModel.SPRAY_CAN, "")
		"close":
			closed.emit()


const EXP_PX: float = 14.0
const VALUE_X: Array = [92.0, 84.0]
const EXTEND_AT: Vector2 = Vector2(540, 458)
const EXTEND_MAX: int = 32722
const ACEM_BAR: float = 19.0
const ACEM_TEXT_RIGHT: float = 458.0

var rep_get: Callable
var rep_asked: Array = []
var _rep_text: String = ""
var _rep_http: HTTPRequest = null



func _draw_self_frame(base: Vector2) -> void :
	_fblit("bself_bk", base + Vector2(float(SelfAtlas.BK_AT[0]), float(SelfAtlas.BK_AT[1])))
	_fblit("bself_rep", base + Vector2(float(SelfAtlas.REP_AT[0]), float(SelfAtlas.REP_AT[1])))





const X2_ROWS: Array = [["imgMeterialPlus", "bag_x2_mat", "materialDoubleTime", "materialDoubleUse", "X2 vật liệu"], ["imgTokenPlus", "bag_x2_tok", "tokenDoubleTime", "tokenDoubleUse", "X2 Bạc"]]


static func x2_tip(label: String, left: int, uses: int) -> String:
	var days: int = ceili(left / 86400.0) if left > 0 else 0
	var text: String = label
	if days > 0:
		text += X2_DAYS % days + "\n"
	if uses > 0:
		text += X2_USES % uses + "\n"
	if days > 0 and uses > 0:
		text += X2_FIRST
	return text.strip_edges(false, true)

static func _ornate_box(base: Vector2, stem: String) -> Rect2:
	if stem.is_empty() or SelfAtlas.ORB_BLANK.has(stem):
		return Rect2()
	var size: Array = SelfAtlas.ORB.get(stem, [180, 240])
	var frame: Array = SelfAtlas.AVATAR
	var wide: float = float(size[0])
	var high: float = float(size[1])
	return Rect2(base + Vector2(float(frame[0]) + floorf((float(frame[2]) - wide) / 2.0), float(frame[1]) + floorf((float(frame[3]) - high) / 2.0)), Vector2(wide, high))


static func ornate_picture(stem: String) -> String:
	return ("l/orb/%s.webp" if SelfAtlas.ORB.has(stem) else "l/or/%s.webp") % stem


static func cell_shown(page: int, i: int, room: int) -> bool:
	return page * BagModel.PER_PAGE + i < room


static func pager_shown(grocery: int) -> bool:
	return grocery > 0

static func extend_shown(grocery: int) -> bool:
	return grocery < EXTEND_MAX


func _rep_load() -> void :
	_rep_text = ""
	if client == null:
		return
	var url: String = str(client.config.origin) + "/reputation.xml?t=" + str(Time.get_ticks_msec())
	rep_asked.append(url)
	if rep_get.is_valid():
		rep_get.call(url)
		return
	if client.config.get("local_test_only") == true:
		return
	if _rep_http == null:
		_rep_http = HTTPRequest.new()
		_rep_http.timeout = 15.0
		if OS.has_feature("web"):
			_rep_http.accept_gzip = false
		add_child(_rep_http)
		_rep_http.request_completed.connect( func(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void :
			if result == HTTPRequest.RESULT_SUCCESS and code == 200:
				_rep_receive(body.get_string_from_utf8())
			else:
				_rep_fail())
	_rep_http.cancel_request()
	if _rep_http.request(url, AppSession.headers(url)) != OK:
		_rep_fail()

func _rep_receive(text: String) -> void :
	_rep_text = rep_score(text, _rep_text)
	queue_redraw()


func _rep_fail() -> void :
	queue_redraw()



static func rep_score(text: String, keep: String) -> String:
	var at: int = text.find("score=\"")
	if at < 0:
		return keep
	var tail: String = text.substr(at + 7).strip_edges(true, false)
	var minus: bool = tail.begins_with("-")
	if minus or tail.begins_with("+"):
		tail = tail.substr(1)
	var digits: String = ""
	for ch: String in tail:
		if not "0123456789".contains(ch):
			break
		digits += ch
	return "0" if digits.is_empty() else str( - digits.to_int() if minus else digits.to_int())
