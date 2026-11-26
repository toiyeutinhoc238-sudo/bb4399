extends Control
const Client = preload("game_client.gd")
const BattleView = preload("battle/battle_view.gd")
const TouchGfx = preload("battle/touch_gfx.gd")
const AssetPack = preload("battle/asset_pack.gd")
const Lobby = preload("ui/lobby.gd")
const Arena = preload("ui/arena.gd")
const RoomView = preload("ui/room.gd")
const PveRoomView = preload("ui/ladder_room.gd")
const Gate = preload("ui/gate.gd")


const APP_TITLE: String = "Tank Ghost"
const BrowserZoom = preload("ui/browser_zoom.gd")
const WebPaste = preload("ui/web_paste.gd")
const ChatBox = preload("ui/chat_modern.gd")
const Friends = preload("ui/friends.gd")
const Garage = preload("ui/garage.gd")
const Bag = preload("ui/bag.gd")
const Mail = preload("ui/mail.gd")
const SettingsView = preload("ui/settings.gd")
const Shop = preload("ui/shop.gd")
const HelperView = preload("ui/helper.gd")
const CrystalView = preload("ui/crystal.gd")
const RankView = preload("ui/rank.gd")
const GuildView = preload("ui/guild.gd")
const WorldBossView = preload("ui/world_boss.gd")
const PveHallView = preload("ui/pve_hall.gd")
const LeagueView = preload("ui/league.gd")
const BoardView = preload("ui/leaderboard.gd")
const QuestView = preload("ui/quest.gd")
const EventsView = preload("ui/events.gd")
const FairView = preload("ui/fair.gd")
const ActHallView = preload("ui/act_hall.gd")
const TerritoryMapView = preload("ui/territory_map.gd")
const DebugOverlay = preload("ui/debug_overlay.gd")
const CrashReport = preload("net/crash_report.gd")
const LadderHallView = preload("ui/ladder_hall.gd")
const Sound = preload("audio.gd")
const Settings = preload("settings.gd")
const BuildTag = preload("ui/build_tag.gd")
const MouseCursor = preload("ui/cursor.gd")
const ExitGuard = preload("ui/exit_guard.gd")
const PcMouse = preload("ui/pc_mouse.gd")
const AppZoom = preload("ui/app_zoom.gd")
const RankUp = preload("ui/rank_up.gd")
const PopQueue = preload("ui/pop_queue.gd")
const LobbyPreload = preload("ui/lobby_preload.gd")
const Pk2 = preload("ui/pk2.gd")
const BattleWarm = preload("battle_warm.gd")
const LevelUp = preload("ui/level_up.gd")
const LadderUp = preload("ui/ladder_up.gd")
const HonorView = preload("ui/honor_view.gd")
const AchieveMv = preload("ui/achieve_mv.gd")
const TankUpFx = preload("ui/tank_up_fx.gd")
const PayPower = preload("ui/pay_power.gd")
const QuickBuy = preload("ui/quick_buy.gd")
const TankRent = preload("ui/tank_rent.gd")
const GuildDonate = preload("ui/guild_donate.gd")
const Recharge = preload("ui/recharge.gd")
const PlayerInfo = preload("ui/player_info.gd")
const ChallengeView = preload("ui/challenge.gd")
const MysteriousStore = preload("ui/mysterious_store.gd")
const BonfireView = preload("ui/bonfire.gd")
const LuckView = preload("ui/bag_luck.gd")
const ExpeditionView = preload("ui/expedition.gd")
const GuildBossView = preload("ui/guild_boss.gd")
const MysticalShop = preload("ui/mystical_shop.gd")
const RandQuest = preload("ui/rand_quest.gd")
const MasterView = preload("ui/master.gd")
const ReputationView = preload("ui/reputation.gd")
const MatchHistoryView = preload("ui/match_history.gd")
const Training = preload("ui/training.gd")
const SelectTank = preload("ui/select_tank.gd")
const MessageBox = preload("ui/message_box.gd")
const ScrollBulletin = preload("ui/scroll_bulletin.gd")
const RoomInvite = preload("ui/room_invite.gd")
const GoldAccess = preload("ui/gold_access.gd")
const TankFastConvert = preload("ui/tank_fast_convert.gd")
const TankConvertAsk = preload("ui/tank_convert_ask.gd")
const GuildTeamInvite = preload("ui/guild_team_invite.gd")
const ActStartAsk = preload("ui/act_start_ask.gd")
const VipLevelGift = preload("ui/vip_level_gift.gd")
const PrivateChatSelect = preload("ui/private_chat_select.gd")
const NewbieLogin = preload("ui/newbie_login.gd")
const PairConfirm = preload("ui/pair_confirm.gd")
const SecondPwd = preload("ui/second_pwd.gd")
const ItemGuide = preload("ui/item_guide.gd")

var client: Client
var _battle_view: BattleView
var _pack: AssetPack
var _lobby: Lobby
var _arena: Arena
var _room_view: RoomView
var _gate: Gate
var _chat: ChatBox
var _friends: Friends
var _garage: Garage
var _tank_up: TankUpFx
var _gift_movie: Control
var _bag: Bag
var _luck_view: Control
var _exped_view: Control
var _gboss_view: Control
var _mail: Mail
var _settings: SettingsView
var _shop: Shop
var _helper: HelperView
var _crystal: CrystalView
var _rank: RankView
var _guild: GuildView
var _boss: WorldBossView
var _pve: PveHallView
var _league: LeagueView
var _board: BoardView
var _quest: QuestView
var _events: EventsView
var _fair: FairView
var _act_hall: ActHallView
var _ladder_hall: LadderHallView
var _territory: TerritoryMapView
var _audio: Sound
var _tag: BuildTag
var _in_battle: bool = false
var _lobby_wait: LobbyPreload
var _pk2: Pk2
var _pops: PopQueue
var _evq1_mysterious: bool = false
var _evq1_slots: Array = []
var _page: String = ""
var _return: String = ""


var _overlay: Dictionary = {}
var _select_tank: Control = null
var _chat_page: String = ""
var _test_events: Control
var _create_pending: bool = false


const WARM_OWN_MS: int = 4000
const WARM_CAP_MS: int = 12000
var _warm_scene: int = -1
var _warm_since: int = 0
var _warm_own: Array = []
var _warm_all: Array = []
var _warm_kin: Array = []
var _room_map: int = 0
var _warm_map: Array = []



const LOAD_DEADLINE_MS: int = 27000
var _warm_hud: Array = []
var _warm_hud_ainpc: bool = false
var _warm_tick: float = 0.0
var _room_warm: String = ""

func _enter_tree() -> void :
	get_window().title = APP_TITLE

func _ready() -> void :
	if _pc_outdated():
		return
	if _pk1_old_app():
		return
	_apk_pbe_notice()
	if TouchGfx.touch_screen():
		_mobile_scale()
		get_window().size_changed.connect(_mobile_scale)
	elif OS.has_feature("web"):
		add_child(BrowserZoom.new())
	if OS.has_feature("web"):
		add_child(WebPaste.new())

	_apply_fps_cap("")
	Settings.watch(_apply_fps_cap)
	if client == null:
		client = Client.new()
	client.changed.connect(_refresh)
	add_child(client)
	if DebugOverlay.wanted():
		var debug_overlay = DebugOverlay.new()
		debug_overlay.client = client
		add_child(debug_overlay)
	var crash_report: Node = CrashReport.new()
	crash_report.client = client
	crash_report.mem_extra = func() -> String: return _pack.mem_groups() if _pack != null else ""
	add_child(crash_report)
	crash_report.add_to_group(ExitGuard.QT1_GROUP)
	_pack = AssetPack.new()
	add_child(_pack)
	_pack.add_to_group(ExitGuard.QT1_GROUP)
	_pack.map_ready.connect(_map_ready)
	_pack.picture_ready.connect( func(_path: String) -> void : _refresh())
	_pack.map_progress.connect( func(id: int, _fraction: float) -> void :
		if client.map_fetch and client.battle.map_id == id:
			_report_load())
	_pack.configure()
	_audio = Sound.new()
	_audio.pack = _pack
	add_child(_audio)
	client.can_fetch_map = _pack.wants_map
	client.battle.skill_known = _pack.known_skill
	client.battle.normal_shot = _pack.normal_shot
	client.battle.still_buff = _pack.still_buff
	client.battle.warm_still = _pack.warm_still
	client.battle.skill_flow = _pack.skill_flow
	client.battle.buff_show = _pack.buff_show
	_battle_view = BattleView.new()
	_battle_view.client = client
	_battle_view.pack = _pack
	_battle_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_battle_view)
	_lobby = Lobby.new()
	_lobby.client = client
	_lobby.pack = _pack
	_lobby.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_lobby.play.connect( func() -> void : client.open_hall())
	_lobby.find_room.connect( func() -> void : client.open_hall())
	_lobby.create_room.connect( func() -> void :
		_create_pending = true
		client.open_hall())
	add_child(_lobby)

	_pk2 = Pk2.new()
	_pk2.client = client
	add_child(_pk2)
	_lobby_wait = LobbyPreload.new()
	_lobby_wait.client = client
	_lobby_wait.pk2 = _pk2
	_pk2.mounted.connect(_refresh)
	_lobby_wait.pack = _pack
	_lobby_wait.lobby = _lobby
	_lobby_wait.changed.connect(_refresh)
	add_child(_lobby_wait)
	_arena = Arena.new()
	_room_view = PveRoomView.new()
	_friends = Friends.new()
	_garage = Garage.new()
	_bag = Bag.new()
	_mail = Mail.new()
	_settings = SettingsView.new()
	_shop = Shop.new()
	_helper = HelperView.new()
	_crystal = CrystalView.new()
	_rank = RankView.new()
	_guild = GuildView.new()
	_boss = WorldBossView.new()
	_pve = PveHallView.new()
	_league = LeagueView.new()
	_board = BoardView.new()
	_quest = QuestView.new()
	_events = EventsView.new()
	_fair = FairView.new()
	_act_hall = ActHallView.new()
	for screen: Control in [_arena, _room_view, _friends, _garage, _bag, _mail, _settings, _shop, _helper, _crystal, _rank, _guild, _boss, _board, _quest, _events, _fair, _league, _act_hall, _pve]:
		screen.client = client
		screen.pack = _pack
		screen.visible = false
		screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(screen)

	_ladder_hall = LadderHallView.new()
	_ladder_hall.client = client
	_ladder_hall.pack = _pack
	_ladder_hall.visible = false
	_ladder_hall.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_ladder_hall)
	_territory = TerritoryMapView.new()
	_territory.client = client
	_territory.pack = _pack
	_territory.visible = false
	_territory.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_territory)

	_chat = ChatBox.new()
	_chat.client = client
	_chat.pack = _pack
	_chat.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_chat)

	var test_events: = preload("ui/test_events.gd").new()
	test_events.client = client
	test_events.pack = _pack
	test_events.lobby = _lobby
	test_events.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(test_events)
	_test_events = test_events


	_overlay = {"friends": _friends, "tank": _garage, "bag": _bag, "mail": _mail, "settings": _settings, "shop": _shop, "helper": _helper, 
		"crystal": _crystal, "rank": _rank, "board": _board, "quest": _quest, "events": _events, "fair": _fair}
	for page: Control in _overlay.values():
		page.overlay = true
		move_child(page, -1)
	for screen: Control in [_lobby, _arena, _room_view, _friends, _garage, _bag, _mail, _shop, _helper, _crystal, _guild, _boss, _board, _quest, _events, _fair, _act_hall, _pve]:
		screen.chat_asked.connect(_chat.open)

	for screen: Control in [_lobby, _arena, _room_view, _guild, _boss, _pve, _league, _act_hall, _ladder_hall]:
		if screen != null and screen.has_signal("talent_asked"):
			screen.connect("talent_asked", _bar_talent.bind(screen))
	for screen: Control in [_lobby, _arena, _room_view, _chat, _bag, _shop, _helper, _crystal, _guild, _boss, _quest, _events, _fair, _garage, _league, _act_hall, _pve]:
		screen.page_asked.connect( func(id: String) -> void :


			var parts: PackedStringArray = id.split(":")
			_return = _page if _page in ["shop", "bag", "helper", "crystal", "guild", "quest", "events", "fair", "tank", "act"] and parts[0] != _page else ""

			if _page in ["pve", "boss", "league"] and _overlay.has(parts[0]):
				_return = _page
			_page = parts[0]
			if _page == "board":
				_board.tab = parts[1] if parts.size() > 1 else ""
			if _page == "quest":
				_quest.tab = parts[1] if parts.size() > 1 else "auto"
			if _page == "events":
				_events.tab = parts[1] if parts.size() > 1 else "auto"
			if _page == "fair":
				_fair.tab = parts[1] if parts.size() > 1 else "wheel"
				_fair.act_want = int(parts[2]) if parts.size() > 2 else 0
			if _page == "shop":
				_shop.gift_to = ":".join(parts.slice(2)) if parts.size() > 2 and parts[1] == "gift" else ""
			if _page == "shop" and parts.size() > 1 and parts[1] != "gift":
				_shop.cat = int(parts[1])
				_shop.want = int(parts[2]) if parts.size() > 2 else 0
			if _page == "pve" and parts.size() > 1:
				_pve.open_map(int(parts[1]))
			if _page == "act" and client.state == "lobby":
				client.open_hall()
			if _page == "tank" and parts.size() > 2 and parts[1] == "rent":
				_garage.want_rent(int(parts[2]))
			_refresh())
	_room_view.whisper.connect(_chat.open_whisper)
	_arena.whisper.connect(_chat.open_whisper)
	for screen: Control in [_friends, _garage, _bag, _mail, _settings, _shop, _helper, _crystal, _rank, _guild, _boss, _board, _quest, _events, _fair, _league, _pve, _territory]:
		screen.closed.connect( func() -> void :
			_page = _return
			_return = ""
			_refresh())

	for asker: Control in [_quest, _fair]:
		asker.arena_asked.connect( func() -> void :
			_page = ""
			_return = ""
			if client.state == "lobby":
				client.open_hall()
			_refresh())
	_friends.whisper.connect(_chat.open_whisper)
	_guild.whisper.connect(_chat.open_whisper)
	_boss.whisper.connect(_chat.open_whisper)
	_pve.whisper.connect(_chat.open_whisper)

	_act_hall.whisper.connect(_chat.open_whisper)
	_act_hall.closed.connect( func() -> void :
		_page = ""
		_return = ""
		_refresh())

	_fair.event_asked.connect( func(_room: int) -> void :
		_page = "act"
		_return = ""
		if client.state == "lobby":
			client.open_hall()
		var why: String = client.act_match()
		_refresh()
		if not why.is_empty():
			_act_hall.say(why))


	_ladder_hall.chat_asked.connect(_chat.open)
	_ladder_hall.whisper.connect(_chat.open_whisper)
	_board.whisper.connect(_chat.open_whisper)
	_ladder_hall.closed.connect( func() -> void :
		_page = ""
		_return = ""
		_refresh())
	_ladder_hall.page_asked.connect( func(id: String) -> void :
		var parts: PackedStringArray = id.split(":")
		_page = parts[0]
		_return = "ladder" if _page not in ["ladder", "act"] else ""
		if _page == "board":
			_board.tab = parts[1] if parts.size() > 1 else ""
		if _page == "quest":
			_quest.tab = parts[1] if parts.size() > 1 else "auto"
		if _page == "events":
			_events.tab = parts[1] if parts.size() > 1 else "auto"
		if _page == "fair":
			_fair.tab = parts[1] if parts.size() > 1 else "wheel"
			_fair.act_want = int(parts[2]) if parts.size() > 2 else 0
		if _page == "shop" and parts.size() > 1:
			_shop.cat = int(parts[1])
			_shop.want = int(parts[2]) if parts.size() > 2 else 0
		_refresh())
	_settings.sign_out.connect(_sign_out)
	_gate = Gate.new()
	_gate.client = client
	_gate.pack = _pack
	_gate.lobby_wait = _lobby_wait
	_gate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_gate)
	_tag = BuildTag.new()
	add_child(_tag)
	var exit_guard: Node = ExitGuard.new()
	exit_guard.client = client
	exit_guard.pack = _pack
	exit_guard.battle_view = _battle_view
	exit_guard.host = self
	add_child(exit_guard)
	if PcMouse.app():
		var pc_mouse: Node = PcMouse.new()
		pc_mouse.client = client
		add_child(pc_mouse)
	if AppZoom.active():
		var app_zoom: Node = AppZoom.new()
		app_zoom.client = client
		add_child(app_zoom)
	var cursor: Node = MouseCursor.new()
	cursor.client = client
	cursor.battle = _battle_view
	cursor.bag = _bag
	add_child(cursor)

	_pops = PopQueue.new()
	_pops.client = client
	add_child(_pops)

	_gift_movie = preload("ui/gift_movie.gd").new()
	_gift_movie.client = client
	_gift_movie.pack = _pack
	_gift_movie.room = _room_view
	_gift_movie.visible = false
	_gift_movie.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_gift_movie)
	client.gift_used.connect(_gift_movie.used)

	var rank_up: Control = RankUp.new()
	rank_up.queue = _pops
	rank_up.client = client
	rank_up.pack = _pack
	rank_up.visible = false
	rank_up.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(rank_up)


	var level_up: Control = LevelUp.new()
	level_up.queue = _pops
	level_up.client = client
	level_up.pack = _pack
	level_up.visible = false
	level_up.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(level_up)

	var ladder_up: Control = LadderUp.new()
	ladder_up.queue = _pops
	ladder_up.client = client
	ladder_up.pack = _pack
	ladder_up.visible = false
	ladder_up.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(ladder_up)

	_tank_up = TankUpFx.new()
	_tank_up.queue = _pops
	_tank_up.client = client
	_tank_up.pack = _pack
	_tank_up.visible = false
	_tank_up.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_tank_up)

	var achieve_mv: Control = AchieveMv.new()
	achieve_mv.queue = _pops
	achieve_mv.client = client
	achieve_mv.pack = _pack
	achieve_mv.visible = false
	achieve_mv.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(achieve_mv)

	var honor_view: Control = HonorView.new()
	honor_view.queue = _pops
	honor_view.client = client
	honor_view.pack = _pack
	honor_view.visible = false
	honor_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(honor_view)
	_pops.register(LevelUp.FIRST_PAY_ID, func(_value: Variant) -> bool:
		_return = _page if _page != "events" else ""
		_page = "events"
		_events.tab = "first"
		_refresh()
		return true)
	_events.visibility_changed.connect( func() -> void :
		if _pops.popping == LevelUp.FIRST_PAY_ID and not _events.visible:
			_pops.closed())

	var pay_power: Control = PayPower.new()
	pay_power.client = client
	pay_power.pack = _pack
	pay_power.visible = false
	pay_power.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pay_power)
	_lobby.stamina_asked.connect(pay_power.open)
	_pve.stamina_asked.connect(pay_power.open)
	_room_view.connect("stamina_asked", pay_power.open)

	var master_view: Control = MasterView.new()
	master_view.client = client
	master_view.pack = _pack
	master_view.visible = false
	master_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(master_view)
	if _lobby.has_signal("master_asked"):
		_lobby.connect("master_asked", master_view.open)

	var reputation_view: Control = ReputationView.new()
	reputation_view.client = client
	reputation_view.pack = _pack
	reputation_view.visible = false
	reputation_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(reputation_view)
	_lobby.connect("reputation_asked", reputation_view.open)

	var history_view: Control = MatchHistoryView.new()
	history_view.client = client
	history_view.pack = _pack
	history_view.visible = false
	history_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(history_view)
	_lobby.connect("history_asked", history_view.open)
	for screen: Control in [_arena, _room_view, _guild, _boss, _league, _act_hall, _pve, _ladder_hall]:
		if screen.has_signal("master_asked"):
			screen.connect("master_asked", master_view.open)
		if screen.has_signal("reputation_asked"):
			screen.connect("reputation_asked", reputation_view.open)
		if screen.has_signal("history_asked"):
			screen.connect("history_asked", history_view.open)


	var challenge_view: Control = ChallengeView.new()
	challenge_view.client = client
	challenge_view.pack = _pack
	challenge_view.visible = false
	challenge_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(challenge_view)
	_lobby.challenge_asked.connect(challenge_view.open)
	_quest.challenge_asked.connect(challenge_view.open)
	challenge_view.page_asked.connect( func(id: String) -> void : _lobby.page_asked.emit(id))
	_board.closed.connect(challenge_view.back_from_board)

	var mystical: Control = MysticalShop.new()
	mystical.client = client
	mystical.pack = _pack
	mystical.visible = false
	mystical.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(mystical)
	_lobby.mystical_asked.connect(mystical.open)

	var mysterious: Control = MysteriousStore.new()
	mysterious.client = client
	mysterious.pack = _pack
	mysterious.visible = false
	mysterious.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(mysterious)
	_lobby.mysterious_asked.connect(mysterious.open)
	client.mysterious_enabled.connect( func() -> void :
		if PopQueue.held():
			_evq1_mysterious = true
		else:
			mysterious.open())

	var rand_quest: Control = RandQuest.new()
	rand_quest.client = client
	rand_quest.pack = _pack
	rand_quest.visible = false
	rand_quest.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(rand_quest)
	if _lobby.has_signal("rand_quest_asked"):
		_lobby.rand_quest_asked.connect(rand_quest.open)
	rand_quest.page_asked.connect( func(id: String) -> void : _lobby.page_asked.emit(id))
	rand_quest.play_asked.connect( func() -> void : client.open_hall())
	var bonfire: Control = BonfireView.new()
	bonfire.client = client
	bonfire.pack = _pack
	bonfire.visible = false
	bonfire.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bonfire)
	_lobby.bonfire_asked.connect(bonfire.open)
	_fair.bonfire_asked.connect(bonfire.open)


	_luck_view = LuckView.new()
	_luck_view.client = client
	_luck_view.pack = _pack
	_luck_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_luck_view)
	_lobby.luck_asked.connect( func() -> void :
		if not _luck_view.visible and client.state == "lobby":
			_luck_view.open())

	_fair.luck_asked.connect( func() -> void :
		( func() -> void :
			if not _luck_view.visible and client.state == "lobby":
				_luck_view.open()).call_deferred())
	_luck_view.closed.connect( func(note: String) -> void :
		if not note.is_empty() and _lobby.visible:
			_lobby.say(note))


	_exped_view = ExpeditionView.new()
	_exped_view.client = client
	_exped_view.pack = _pack
	_exped_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_exped_view)
	_lobby.expedition_asked.connect( func() -> void :
		if not _exped_view.visible and client.state == "lobby":
			_exped_view.open())

	var player_info: Control = PlayerInfo.new()
	player_info.client = client
	player_info.pack = _pack
	player_info.visible = false
	player_info.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(player_info)
	_lobby.player_info_asked.connect(player_info.open)
	_board.player_info_asked.connect(player_info.open)
	player_info.whisper.connect(_chat.open_whisper)
	_friends.player_info_asked.connect(player_info.open)
	_chat.player_info_asked.connect(player_info.open)
	_guild.player_info_asked.connect(player_info.open)
	_room_view.player_info_asked.connect(player_info.open)
	master_view.player_info_asked.connect(player_info.open)
	challenge_view.player_info_asked.connect(player_info.open)

	var item_guide: Control = ItemGuide.new()
	item_guide.client = client
	item_guide.pack = _pack
	item_guide.visible = false
	item_guide.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(item_guide)
	_bag.guide_asked.connect(item_guide.open)
	_helper.guide_asked.connect(item_guide.open)
	_garage.guide_asked.connect(item_guide.open)


	var guide_hid: Array = [false]
	item_guide.page_asked.connect( func(id: String) -> void :
		if id.begins_with("tank:rent:") and item_guide.visible:
			guide_hid[0] = true
			item_guide.visible = false
		_bag.page_asked.emit(id))
	_garage.rent_left.connect( func() -> void :
		if guide_hid[0]:
			guide_hid[0] = false
			item_guide.visible = client.state in item_guide.SHOW_IN)


	item_guide.expedition_asked.connect( func() -> void :
		if _exped_view.visible or client.state != "lobby":
			return
		_exped_view.open()
		if _exped_view.visible and item_guide.visible:
			guide_hid[0] = true
			item_guide.visible = false)
	_exped_view.closed.connect( func() -> void :
		if guide_hid[0]:
			guide_hid[0] = false
			item_guide.visible = client.state in item_guide.SHOW_IN)
	item_guide.arena_asked.connect( func() -> void :
		_page = ""
		_return = ""
		if client.state == "lobby":
			client.open_hall()
		_refresh())

	var quick_buy: Control = QuickBuy.new()
	quick_buy.client = client
	quick_buy.pack = _pack
	quick_buy.visible = false
	quick_buy.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(quick_buy)
	_lobby.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))
	_guild.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))
	bonfire.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))
	_fair.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))

	_bag.quick_buy_asked.connect( func(tid: int, tip: String) -> void :
		if quick_buy.ask(tid) and not tip.is_empty():
			quick_buy.say(tip))

	_bag.luck_buy_asked.connect( func(tid: int, count: int, tip: String) -> void :
		if quick_buy.ask(tid, QuickBuy.ShopModel.BUY, count) and not tip.is_empty():
			quick_buy.say(tip))
	_luck_view.buy_asked.connect( func(tid: int, count: int, tip: String) -> void :
		if quick_buy.ask(tid, QuickBuy.ShopModel.BUY, count) and not tip.is_empty():
			quick_buy.say(tip))
	var recharge: Control = Recharge.new()
	recharge.client = client
	recharge.pack = _pack
	recharge.visible = false
	recharge.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(recharge)
	_bag.renew_asked.connect( func(tid: int, kind: int, name: String) -> void : recharge.renew(tid, kind, name))
	var guild_donate: Control = GuildDonate.new()
	guild_donate.client = client
	guild_donate.pack = _pack
	guild_donate.visible = false
	guild_donate.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(guild_donate)
	_guild.donate_asked.connect( func(tid: int) -> void : guild_donate.donate(tid))


	_gboss_view = GuildBossView.new()
	_gboss_view.client = client
	_gboss_view.pack = _pack
	_gboss_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_gboss_view)
	_guild.boss_asked.connect( func() -> void :
		if not _gboss_view.visible and client.state == "lobby":
			_gboss_view.open())
	item_guide.guild_boss_asked.connect( func() -> void :
		if _gboss_view.visible or client.state != "lobby":
			return
		_gboss_view.open()
		if _gboss_view.visible and item_guide.visible:
			guide_hid[0] = true
			item_guide.visible = false)
	_gboss_view.closed.connect( func() -> void :
		if guide_hid[0]:
			guide_hid[0] = false
			item_guide.visible = client.state in item_guide.SHOW_IN)

	_crystal.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))

	_helper.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))
	_garage.quick_buy_asked.connect( func(tid: int, count: int) -> void : quick_buy.ask(tid, QuickBuy.ShopModel.BUY, count))
	mystical.buy_asked.connect( func(tank: int, msbt: int, item: int, ori: int, disc: int) -> void : quick_buy.mystic(tank, msbt, item, ori, disc))


	var approach: Control = preload("ui/approach_tank.gd").new()
	approach.client = client
	approach.pack = _pack
	approach.visible = false
	approach.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(approach)
	_garage.tank_buy_asked.connect( func(tid: int, now: String, after: String) -> void : approach.ask(tid, now, after))
	_tank_up.tank_buy_asked.connect( func(tid: int, now: String, after: String) -> void : approach.ask(tid, now, after))

	_battle_view.pvp_result.tank_buy_asked.connect( func(tid: int) -> void : approach.ask(tid))

	player_info.tank_buy_asked.connect( func(tid: int) -> void : approach.ask(tid))

	_room_view.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))

	_room_view.connect("cash_back_asked", func(tid: int, kind: int) -> void : quick_buy.ask(tid, kind))

	_bag.horn_asked.connect( func(channel: int) -> void : _chat.open_horn(channel))

	_chat.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))
	item_guide.quick_buy_asked.connect( func(tid: int) -> void : quick_buy.ask(tid))



	var gold_access: Control = GoldAccess.new()
	gold_access.client = client
	gold_access.pack = _pack
	gold_access.visible = false
	gold_access.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(gold_access)
	quick_buy.gold_access_asked.connect(gold_access.open)
	approach.gold_access_asked.connect(gold_access.open)
	_tank_up.gold_access_asked.connect(gold_access.open)
	mysterious.gold_access_asked.connect(gold_access.open)
	gold_access.matching_asked.connect( func() -> void :
		quick_buy.close()
		approach.close()
		mysterious.cancel_buy()
		_page = ""
		_return = ""
		if client.state == "lobby":
			client.open_hall()
		elif client.state == "hall":
			client.ladder_leave()
			client.hall_tab(2)
		var why: String = client.quick_match()
		_refresh()
		if not why.is_empty():
			_arena.say(why))


	var tank_ask: Control = TankConvertAsk.new()
	tank_ask.client = client
	tank_ask.pack = _pack
	tank_ask.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(tank_ask)
	tank_ask.closed.connect( func(note: String) -> void :
		if not note.is_empty():
			_say_on_top(note))
	var fast_convert: Control = TankFastConvert.new()
	fast_convert.client = client
	fast_convert.pack = _pack
	fast_convert.describe = tank_ask._describe
	fast_convert.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(fast_convert)
	client.materials_added.connect( func(slots: Array) -> void :
		if PopQueue.held():
			_evq1_slots.append_array(slots)
		else:
			fast_convert.offer(slots))
	_pops.released.connect( func() -> void :
		if _evq1_mysterious:
			_evq1_mysterious = false
			mysterious.open()
		if not _evq1_slots.is_empty():
			var slots: Array = _evq1_slots.duplicate()
			_evq1_slots.clear()
			fast_convert.offer(slots)
		client.changed.emit())
	fast_convert.convert_asked.connect( func(tid: int) -> void :
		tank_ask.hall = _arena.hall
		move_child(tank_ask, get_child_count() - 1)
		tank_ask.open(tid))

	var training: Control = Training.new()
	training.client = client
	training.pack = _pack
	training.visible = false
	training.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(training)
	_lobby.training_asked.connect(training.open)


	var newbie_login: Control = NewbieLogin.new()
	newbie_login.queue = _pops
	newbie_login.client = client
	newbie_login.pack = _pack
	newbie_login.visible = false
	newbie_login.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(newbie_login)
	_lobby.newbie_asked.connect(newbie_login.open)


	var select_tank: Control = SelectTank.new()
	select_tank.client = client
	select_tank.pack = _pack
	select_tank.visible = false
	select_tank.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(select_tank)
	_select_tank = select_tank


	select_tank.pick_asked.connect( func(id: int) -> void : client.pick_tank(id))
	select_tank.lock_asked.connect( func() -> void : client.lock_tank())


	select_tank.rent_asked.connect( func(id: int) -> void : _bag.page_asked.emit("tank:rent:%d" % id))
	client.changed.connect( func() -> void : select_tank.can_pick = client.can_pick_tank())
	_tl1a_setup(select_tank)
	_cr2_setup(select_tank)


	var pair_confirm: Control = PairConfirm.new()
	pair_confirm.client = client
	pair_confirm.pack = _pack
	pair_confirm.visible = false
	pair_confirm.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(pair_confirm)


	var room_invite: Control = RoomInvite.new()
	room_invite.client = client
	room_invite.pack = _pack
	room_invite.visible = false
	room_invite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(room_invite)
	room_invite.accepted.connect( func() -> void :
		_page = ""
		_return = ""
		_refresh())

	var guild_team_invite: Control = GuildTeamInvite.new()
	guild_team_invite.client = client
	guild_team_invite.pack = _pack
	guild_team_invite.visible = false
	guild_team_invite.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(guild_team_invite)


	var act_ask: Control = ActStartAsk.new()
	var vip_gift: Control = VipLevelGift.new()
	for pop: Control in [act_ask, vip_gift]:
		pop.set("queue", _pops)
	var chat_pick: Control = PrivateChatSelect.new()
	for pop: Control in [act_ask, vip_gift, chat_pick]:
		pop.client = client
		pop.pack = _pack
		pop.visible = false
		pop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(pop)
	act_ask.page_asked.connect( func(id: String) -> void : _lobby.page_asked.emit(id))
	_chat.whisper_pick_asked.connect(chat_pick.open)
	chat_pick.picked.connect(_chat.open_whisper)




	var main_pwd: Control = SecondPwd.new()
	var check_pwd: Control = SecondPwd.new()
	for pwd: Control in [main_pwd, check_pwd]:
		pwd.client = client
		pwd.pack = _pack
		pwd.visible = false
		pwd.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(pwd)
	_settings.pwd_asked.connect(main_pwd.open)
	client.pwd_check_asked.connect( func() -> void : check_pwd.open("check"))
	client.pwd_result.connect( func(op: int, ok: bool) -> void :
		var text: String = SecondPwd.tip_for(op, ok, client.pwd_lock)
		if ok:
			check_pwd.close()
			if op != 1:
				main_pwd.close()
		if check_pwd.visible:
			check_pwd.say(text)
		elif main_pwd.visible:
			main_pwd.say(text)
		elif client.state == "battle":
			client.chat_note(text)
		else:
			client.noticed.emit(text))
	client.pwd_notice.connect( func(left: int) -> void : client.chat_note(SecondPwd.notice_text(left)))

	client.hire_presented.connect( func(giver: String, tank: int, level: int, hours: int) -> void :
		var title: String = str(_pack.lobby.get("tanks", {}).get(str(tank), "")) if _pack != null else ""
		if title.is_empty():
			return
		var text: String = TankRent.hire_note(giver, title, level, hours)
		if client.state == "battle":
			client.chat_note(text)
		else:
			client.noticed.emit(text))


	var message_box: Control = MessageBox.new()
	message_box.client = client
	message_box.pack = _pack
	message_box.visible = false
	message_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(message_box)

	var scroll_bulletin: Control = ScrollBulletin.new()
	scroll_bulletin.client = client
	scroll_bulletin.pack = _pack
	scroll_bulletin.visible = false
	scroll_bulletin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll_bulletin)
	_refresh()


func _apply_fps_cap(key: String) -> void :
	if key.is_empty() or key == "fps_cap" or key == "tc_fps" or key == "tc_eco":
		Engine.max_fps = TouchGfx.fps_limit(_fps_where())


func _fps_where() -> int:
	return TouchGfx.where_now(client == null or client.state == "battle", Time.get_ticks_msec())


func _input(_event: InputEvent) -> void :
	TouchGfx.poke()



func _process(delta: float) -> void :
	_layers()
	if TouchGfx.touch_device() and DisplayServer.get_name() != "headless":
		var fps: int = TouchGfx.fps_limit(_fps_where())
		if Engine.max_fps != fps:
			Engine.max_fps = fps
	if client == null or _pack == null or client.state != "battle" or client.battle.started or client.load_done():
		return
	_warm_tick += delta
	if _warm_tick < 0.2:
		return
	_warm_tick = 0.0
	if _warm_hud_ainpc and _pack.ainpc_settled:
		_warm_hud_ainpc = false
		_warm_hud = BattleWarm.jobs(_pack, client.battle)
	if client.map_fetch and _past_deadline():
		_pack.force_map(client.battle.map_id)
	_report_load()
	if client.battle.supported() and _warm_ready():
		_pack.ios_keep(_warm_own)
		client.complete_battle_load()




const DL_QUIT_DELAY: float = 1.0


static func dl_quit_after_open(android: bool, pc_app: bool, web: bool) -> bool:
	return (android or pc_app) and not web



static func dl_quit_delay(android: bool, delay: float) -> float:
	return 0.0 if android else maxf(delay, 0.0)



static func open_download_and_quit(tree: SceneTree, url: String, delay: float = DL_QUIT_DELAY) -> bool:
	if url.is_empty():
		return false
	OS.shell_open(url)
	if tree == null or not dl_quit_after_open(OS.has_feature("android"), OS.has_feature("pc_app"), OS.has_feature("web")):
		return false
	dl_quit_later(tree, dl_quit_delay(OS.has_feature("android"), delay))
	return true



static func dl_quit_later(tree: SceneTree, delay: float, fn: Callable = Callable()) -> void :
	if delay <= 0.0:
		ExitGuard.quit_app(tree, fn)
		return
	tree.create_timer(delay, true).timeout.connect( func() -> void : ExitGuard.quit_app(tree, fn))





const PC_MIN_EXE: int = 421
const PC_SETUP_URL: String = ""

static func pc_exe_outdated(tag: String) -> bool:
	var m: RegExMatch = RegEx.create_from_string("^G6b(\\d+)$").search(tag.strip_edges())
	return m == null or int(m.get_string(1)) < PC_MIN_EXE

func _pc_outdated() -> bool:
	if not OS.has_feature("pc_app"):
		return false
	var tag: String = FileAccess.get_file_as_string("res://assets/apk_build.txt") if FileAccess.file_exists("res://assets/apk_build.txt") else "dev"
	if not pc_exe_outdated(tag):
		return false
	_pc_mark_ok()
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.05, 0.08, 1.0)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.custom_minimum_size = Vector2(620, 0)
	box.add_theme_constant_override("separation", 18)
	dim.add_child(box)
	var title: Label = Label.new()
	title.text = "Bản cài đặt này đã cũ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("f2b544"))
	box.add_child(title)
	var msg: Label = Label.new()
	msg.text = "Hãy đăng xuất, gỡ cài đặt bản này (Start Menu → Tank Ghost → Gỡ cài đặt) rồi tải và cài bộ cài mới để tiếp tục chơi.\nTài khoản và nhân vật giữ nguyên."
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 18)
	msg.add_theme_color_override("font_color", Color("e7eef2"))
	box.add_child(msg)
	var get_new: Button = Button.new()
	get_new.text = "TẢI BỘ CÀI MỚI"
	get_new.custom_minimum_size = Vector2(0, 56)
	get_new.add_theme_font_size_override("font_size", 22)
	get_new.pressed.connect( func() -> void : open_download_and_quit(get_tree(), PC_SETUP_URL))
	box.add_child(get_new)
	var quit: Button = Button.new()
	quit.text = "Thoát"
	quit.custom_minimum_size = Vector2(0, 40)
	quit.pressed.connect( func() -> void : ExitGuard.quit_app(get_tree()))
	box.add_child(quit)
	return true



const APK_PBE_URL: String = ""
const APK_PBE_FIRST: int = 0
const APK_PBE_SEEN: String = "user://pbe_apk_notice.txt"

static func apk_before_pbe(tag: String) -> bool:
	var m: RegExMatch = RegEx.create_from_string("^mh1r(\\d+)$").search(tag.strip_edges())
	return m != null and int(m.get_string(1)) < APK_PBE_FIRST

func _apk_pbe_notice() -> void :
	if not OS.has_feature("android"):
		return
	var tag: String = FileAccess.get_file_as_string("res://assets/apk_build.txt") if FileAccess.file_exists("res://assets/apk_build.txt") else "dev"
	var today: String = Time.get_date_string_from_system()
	if not apk_before_pbe(tag) or FileAccess.get_file_as_string(APK_PBE_SEEN).strip_edges() == today:
		return
	var seen: FileAccess = FileAccess.open(APK_PBE_SEEN, FileAccess.WRITE)
	if seen != null:
		seen.store_string(today)
	var layer: CanvasLayer = CanvasLayer.new()
	layer.layer = 120
	add_child(layer)
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.05, 0.08, 0.92)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(dim)
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.custom_minimum_size = Vector2(620, 0)
	box.add_theme_constant_override("separation", 18)
	dim.add_child(box)
	var title: Label = Label.new()
	title.text = ""
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("f2b544"))
	box.add_child(title)
	var msg: Label = Label.new()
	msg.text = ""
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 18)
	msg.add_theme_color_override("font_color", Color("e7eef2"))
	box.add_child(msg)
	var get_new: Button = Button.new()
	get_new.text = ""
	get_new.custom_minimum_size = Vector2(0, 56)
	get_new.add_theme_font_size_override("font_size", 22)
	get_new.pressed.connect( func() -> void : open_download_and_quit(get_tree(), APK_PBE_URL))
	box.add_child(get_new)
	var later: Button = Button.new()
	later.text = "Để sau"
	later.custom_minimum_size = Vector2(0, 44)
	later.pressed.connect(layer.queue_free)
	box.add_child(later)








const PK1_MARK: String = "res://assets/pk1_enc.json"
const PK1_APK_URL: String = ""
const PK1_PC_URL: String = ""
const PK1_RECHECK: float = 300.0
var _pk1_up: Node = null
var _pk1_note: Label = null


static func pk1_app_outdated(android: bool, pc_app: bool, has_mark: bool) -> bool:
	return (android or pc_app) and not has_mark

func _pk1_old_app() -> bool:
	var android: bool = OS.has_feature("android")
	if not pk1_app_outdated(android, OS.has_feature("pc_app"), FileAccess.file_exists(PK1_MARK)):
		return false
	_pc_mark_ok()
	var dim: ColorRect = ColorRect.new()
	dim.color = Color(0.02, 0.05, 0.08, 1.0)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)
	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	box.grow_horizontal = Control.GROW_DIRECTION_BOTH
	box.grow_vertical = Control.GROW_DIRECTION_BOTH
	box.custom_minimum_size = Vector2(620, 0)
	box.add_theme_constant_override("separation", 18)
	dim.add_child(box)
	var title: Label = Label.new()
	title.text = "Phiên bản ứng dụng đã cũ"
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("f2b544"))
	box.add_child(title)
	var msg: Label = Label.new()
	if android:
		msg.text = "Hãy tải và cài ứng dụng mới để tiếp tục chơi.\nCài đè lên bản này, không cần gỡ. Tài khoản và dữ liệu giữ nguyên."
	else:
		msg.text = "Hãy tải bộ cài mới, thoát game rồi chạy bộ cài (cài đè vào thư mục cũ, không cần gỡ) để tiếp tục chơi.\nTài khoản và nhân vật giữ nguyên."
	msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg.add_theme_font_size_override("font_size", 18)
	msg.add_theme_color_override("font_color", Color("e7eef2"))
	box.add_child(msg)
	var get_new: Button = Button.new()
	get_new.text = "TẢI BẢN MỚI" if android else "TẢI BỘ CÀI MỚI"
	get_new.custom_minimum_size = Vector2(0, 56)
	get_new.add_theme_font_size_override("font_size", 22)
	var url: String = PK1_APK_URL if android else PK1_PC_URL
	get_new.pressed.connect( func() -> void : open_download_and_quit(get_tree(), url))
	box.add_child(get_new)
	var quit: Button = Button.new()
	quit.text = "Thoát"
	quit.custom_minimum_size = Vector2(0, 40)
	quit.pressed.connect( func() -> void : ExitGuard.quit_app(get_tree()))
	box.add_child(quit)
	_pk1_note = Label.new()
	_pk1_note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_pk1_note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_pk1_note.add_theme_font_size_override("font_size", 15)
	_pk1_note.add_theme_color_override("font_color", Color("9fb3bf"))
	box.add_child(_pk1_note)
	if SettingsView.BUILD != "dev":
		_pk1_up = load("res://ui/android_update.gd").new()
		_pk1_up.set("build", SettingsView.BUILD)
		_pk1_up.connect("ready_tag", func(tag: String) -> void : _pk1_note.text = "Đã tải bản %s, mở lại game để dùng." % tag)
		add_child(_pk1_up)
		_pk1_up.call("check")
		var again: Timer = Timer.new()
		again.wait_time = PK1_RECHECK
		again.autostart = true
		again.timeout.connect( func() -> void : _pk1_up.call("check"))
		add_child(again)
	return true

func _pc_mark_ok() -> void :
	var up: Node = preload("res://ui/android_update.gd").new()
	up.build = SettingsView.BUILD
	up.mark_ok()
	up.free()

func _report_load() -> void :
	var map_part: float = _pack.map_fraction(client.battle.map_id) if client.map_fetch else 1.0
	client.report_load(int(60.0 * map_part + 39.0 * _pack.warm_fraction(_warm_gate())))



func _warm_gate() -> Array:
	return _warm_kin + _warm_map + _warm_hud


func _past_deadline() -> bool:
	return _warm_scene == client.battle.scene_id and Time.get_ticks_msec() - _warm_since >= LOAD_DEADLINE_MS


func _start_warm() -> void :
	_warm_scene = client.battle.scene_id
	_warm_since = Time.get_ticks_msec()
	_room_map = 0
	_pack.load_bundle()
	_pack.load_mapart()
	_pack.refill_fx()
	_pack.refill_map(client.battle.map_id)
	var looks: Array = []
	var mine: Variant = client.battle.appearances.get(client.account_oid)
	if mine is Dictionary:
		looks.append(mine)
	_warm_own = _pack.warm_battle(looks)
	_warm_hud = BattleWarm.jobs(_pack, client.battle)
	_warm_hud_ainpc = BattleWarm.needs_ainpc(_pack, client.battle)
	_warm_map = _pack.warm_map(client.battle.map_id)
	for id: Variant in client.battle.appearances:
		if int(id) != client.account_oid:
			looks.append(client.battle.appearances[id])
	_warm_all = _pack.warm_battle(looks)
	_warm_kin = _pack.warm_battle(looks, 2)
	_pack.warm_first(_warm_own + _warm_hud + _warm_map)
	_pack.ios_trim_battle(client.battle.map_id, _warm_all + _warm_map + _warm_hud)
	_pack.pc_trim_battle(client.battle.map_id, _warm_kin + _warm_own + _warm_map + _warm_hud)
	_pack.pc_want(_warm_all + _warm_kin + _warm_own + _warm_map + _warm_hud, true)



func _warm_ready() -> bool:
	var waited: int = Time.get_ticks_msec() - _warm_since
	if _past_deadline():
		return true
	if client.battle.enter_type == 0 and not client.battle.look:
		return not _warm_hud_ainpc and _pack.warm_fraction(_warm_gate()) >= 1.0
	if waited >= WARM_CAP_MS or _pack.warm_fraction(_warm_all + _warm_map) >= 1.0:
		return true
	return waited >= WARM_OWN_MS and _pack.warm_fraction(_warm_own + _warm_map) >= 1.0




func _warm_room() -> void :
	if _pack.state != "ready" or _pack.fx.is_empty():
		return
	_pack.load_bundle()
	_pack.load_mapart()
	var looks: Array = []
	var tank: Dictionary = client.current_tank()
	if not tank.is_empty():
		looks.append({"tank": int(tank.get("m_tpltId", 0)), "external": int(tank.get("m_externalId", 0)), "level": int(tank.get("m_level", 0)), "halo": int(tank.get("m_haloId", 0))})
	if client.state == "room":
		for look: Variant in client.room_state.appearances.values():
			if look is Dictionary:
				looks.append(look)
	for pick: Variant in client.pair_scene.get("picks", {}).values():
		if pick is Dictionary and int(pick.get("tank", 0)) > 0:
			looks.append({"tank": int(pick.tank), "external": int(pick.get("ext", 0)), "level": int(pick.get("level", 0)), "halo": int(pick.get("halo", 0))})
	var map: int = int(client.pair_scene.get("map", 0))
	if map <= 0 and client.state == "room" and not _pack.ios_shrink:
		map = int(client.room_state.room.get("roomConfig", {}).get("m_nMapId", 0))
	if map > 0 and map != _room_map and _pack.wants_map(map):
		_room_map = map
		_pack.request_map(map)
		_pack.pc_trim_maps(map)
	var stamp: String = ""
	for look: Dictionary in looks:
		stamp += "%d:%d," % [int(look.get("tank", 0)), int(look.get("external", 0))]
	if stamp == _room_warm or looks.is_empty():
		return
	_room_warm = stamp
	_pack.pc_want(_pack.warm_battle(looks, 0 if _pack.ios_shrink else 2), false)

var _bcm1_told: Dictionary = {}


func _bcm1_tell(what: String, id: int, ok: bool) -> void :
	var key: String = "%d:%s" % [client.battle.scene_id, what]
	if _bcm1_told.has(key):
		return
	if _bcm1_told.size() >= 32:
		_bcm1_told.clear()
	_bcm1_told[key] = true
	push_error("bcm1 %s m%d c%d ok=%s run=%s n=%d %s" % [what, id, client.battle.cosmic, ok, client.battle.started, 
		client.bcm1_tries(), _pack.map_report(id) if _pack != null else "-"])

func _map_ready(id: int, ok: bool) -> void :
	if client.state != "battle" and ok and id == _room_map:
		_pack.warm_map(id)
	if client.state != "battle" or not client.map_fetch or client.battle.map_id != id:
		return
	var attached: bool = ok and client.battle.attach_map(id, _pack.map_doc(id))


	if attached and not client.battle.started:
		if _warm_map.is_empty():
			_warm_map = _pack.warm_map(id)
		_warm_hud = BattleWarm.jobs(_pack, client.battle)
		_warm_hud_ainpc = BattleWarm.needs_ainpc(_pack, client.battle)
		_pack.warm_first(_warm_own + _warm_hud + _warm_map)
	if not attached:
		_bcm1_tell("gan", id, ok)
	client.finish_map_fetch(attached)

func _mobile_scale() -> void :

	var window: Window = get_window()
	window.content_scale_size = Vector2i(960, 540) if window.size.x > window.size.y else Vector2i(540, 960)

func _sign_out() -> void :
	_gate.reset()
	client.logout()


func _say_on_top(note: String) -> void :
	var top: Control = _overlay.get(_page)
	if top != null:
		top.say(note)
		return
	for screen: Control in [_lobby, _arena, _room_view]:
		if screen != null and screen.visible:
			screen.say(note)
			return


func _page_lives(id: String) -> bool:
	if id in ["act", "ladder"]:
		return client.state == "hall"
	if id == "pve":
		return client.state == "lobby"
	if id == "territory":
		return client.state in ["lobby", "hall"]
	return true





func _layers() -> void :
	if _chat == null or _test_events == null or _gate == null:
		return
	var top: Control = _overlay.get(_page)
	_chat.page_over = top != null and top.visible


	var lift: bool = (_chat.is_open() or _chat._horn != 0) and (top != null or not _chat.docked())
	if not lift and _chat.get_index() > _test_events.get_index():
		move_child(_chat, _test_events.get_index())
	elif lift and _chat.get_index() < _test_events.get_index():
		move_child(_chat, _gate.get_index() - 1)
	var cap: Control = _chat if lift else _gate
	if top != null and top.visible and _select_tank != null and _select_tank.visible:


		_above(top, _select_tank)
		if lift:
			_above(_chat, top)
	elif top != null and top.get_index() != cap.get_index() - 1:
		move_child(top, cap.get_index() - 1)
	_pick_cover()
	var keys: bool = (top == null or lift) and not (_talent_from != null and _talent_view != null and _talent_view.visible)
	if _chat.is_processing_unhandled_key_input() != keys:
		_chat.set_process_unhandled_key_input(keys)
	if not keys:
		var focus: Control = get_viewport().gui_get_focus_owner()
		if focus != null and _chat.is_ancestor_of(focus):
			focus.release_focus()


func _above(node: Control, under: Control) -> void :
	var at: int = under.get_index()
	if node.get_index() != at + 1:
		move_child(node, at if node.get_index() < at else at + 1)



func _pick_cover() -> void :
	if _select_tank == null:
		return
	var top: Control = _overlay.get(_page)
	var cover: bool = top != null and top.visible and _select_tank.visible
	cover = cover or (_pick_crystal != null and _pick_crystal.visible and _crystal_host == _select_tank)
	cover = cover or (_talent_view != null and _talent_view.visible and _talent_from == null and _talent_host == _select_tank)
	if cover and not _select_tank.get("covered"):
		var focus: Control = get_viewport().gui_get_focus_owner()
		if focus != null and _select_tank.is_ancestor_of(focus):
			focus.release_focus()
	_select_tank.set("covered", cover)

func _refresh() -> void :
	if _tag != null:
		_tag.set_state(client.state)
	if _gate != null:
		_gate.visible = client.state not in ["battle", "lobby", "hall", "room"]
	var waiting: bool = _lobby_wait != null and _lobby_wait.sync()
	if waiting and _gate != null:
		_gate.visible = true
	if _pops != null:
		_pops.hold = waiting
	if client.state not in ["lobby", "hall", "room"]:
		_page = ""
		_return = ""

	if client.world_boss_return and client.state == "lobby":
		client.world_boss_return = false
		_page = "boss"
		_return = ""

	if client.guild_boss_return and client.state == "lobby":
		client.guild_boss_return = false
		_page = "guild"
		_return = ""
		if _gboss_view != null and bool(client.guild_boss.get("live", false)):
			_gboss_view.open()

	if int(client.pve_return) > 0 and client.state == "lobby":
		_pve.come_back(int(client.pve_return))
		client.pve_return = 0
		_page = "pve"
		_return = ""

	if client.act_return and client.state == "hall":
		client.act_return = false
		_page = "act"
		_return = ""
	if _page == "act" and client.state != "hall":
		_page = ""
	if _page == "pve" and client.state != "lobby":
		_page = ""
	if _page == "territory" and client.state not in ["lobby", "hall"]:
		_page = ""

	if "ladder_return" in client and client.ladder_return and client.state == "hall":
		client.ladder_return = false
		_page = "ladder"
		_return = ""
	if _page == "ladder" and client.state != "hall":
		_page = ""

	if client.state == "hall" and client.hall_type == 9 and _page != "ladder" and (_page.is_empty() or _return != "ladder")\
	and client.has_method("ladder_leave"):
		client.call("ladder_leave")
	if _audio != null:
		var pairing: String = SelectTank.music_for(client)
		Sound.music(pairing if not pairing.is_empty() else Sound.track_for(client.state, client.battle.ended))
	if (client.state == "battle") != _in_battle:
		_in_battle = client.state == "battle"
		if _in_battle and _battle_view != null:
			_battle_view.camera_zoom = Settings.level("zoom")
	if not _page_lives(_return):
		_return = ""


	var lid: String = _return if _overlay.has(_page) else ""
	var shown: Array[String] = [_page, lid]
	var under: bool = _page.is_empty() or (_overlay.has(_page) and (lid.is_empty() or _overlay.has(lid)))
	if _lobby != null:
		_lobby.visible = client.state == "lobby" and under and not waiting
		if _luck_view != null and _luck_view.visible and not _lobby.visible:
			_luck_view.close("")
		if _exped_view != null and _exped_view.visible and not _lobby.visible:
			_exped_view.close()
		if _gboss_view != null and _gboss_view.visible and client.state != "lobby":
			_gboss_view.close()
	if _arena != null:
		_arena.hall = _lobby.backdrop_hall()
		_room_view.hall = _arena.hall
		_friends.hall = _arena.hall
		_garage.hall = _arena.hall
		_bag.hall = _arena.hall
		if _luck_view != null:
			_luck_view.hall = _arena.hall
		if _exped_view != null:
			_exped_view.hall = _arena.hall
		if _gboss_view != null:
			_gboss_view.hall = _arena.hall
		_mail.hall = _arena.hall
		_settings.hall = _arena.hall
		_shop.hall = _arena.hall
		_helper.hall = _arena.hall
		_crystal.hall = _arena.hall
		_rank.hall = _arena.hall
		_guild.hall = _arena.hall
		_boss.hall = _arena.hall
		_pve.hall = _arena.hall
		_league.hall = _arena.hall
		_board.hall = _arena.hall
		_quest.hall = _arena.hall
		_events.hall = _arena.hall
		_fair.hall = _arena.hall
		_arena.visible = client.state == "hall" and under
		_room_view.visible = client.state == "room" and under
		_friends.visible = "friends" in shown
		_garage.visible = "tank" in shown
		_bag.visible = "bag" in shown
		_mail.visible = "mail" in shown
		_settings.visible = "settings" in shown
		_shop.visible = "shop" in shown
		_helper.visible = "helper" in shown
		_crystal.visible = "crystal" in shown
		_rank.visible = "rank" in shown
		_guild.visible = "guild" in shown
		_boss.visible = _page == "boss" or lid == "boss"
		_pve.visible = _page == "pve" and client.state == "lobby" or lid == "pve"
		_league.visible = _page == "league" or lid == "league"
		_territory.hall = _arena.hall
		_territory.visible = _page == "territory" and client.state in ["lobby", "hall"] or lid == "territory"
		_board.visible = "board" in shown
		_quest.visible = "quest" in shown
		_events.visible = "events" in shown
		_fair.visible = "fair" in shown
		_act_hall.hall = _arena.hall
		_act_hall.visible = client.state == "hall" and "act" in shown
		_ladder_hall.hall = _arena.hall
		_ladder_hall.visible = client.state == "hall" and "ladder" in shown

		var top: Control = _overlay.get(_page)
		var focus: Control = get_viewport().gui_get_focus_owner()
		for screen: Control in [_lobby, _arena, _room_view, _test_events, _guild, _boss, _pve, _league, _act_hall, _ladder_hall, _territory] + _overlay.values():
			var hidden: bool = top != null and screen != null and screen != top and screen.visible
			if screen != null and screen == _talent_from and _talent_view != null and _talent_view.visible:
				hidden = true
			if screen != null:
				screen.set("covered", hidden)
			if hidden and focus != null and screen.is_ancestor_of(focus):
				focus.release_focus()
	_talent_bar_cover()
	if _chat != null:

		var base: String = _page
		if _overlay.has(_page):
			base = "" if _overlay.has(lid) else lid
		var host: Control = {"guild": _guild, "boss": _boss, "pve": _pve, "act": _act_hall}.get(base, {"lobby": _lobby, "hall": _arena, "room": _room_view}.get(client.state))
		if base == "ladder" and _ladder_hall != null:
			host = _ladder_hall
		if host != _chat.host or _page != _chat_page:
			_chat.close()
			_chat.host = host
			_chat_page = _page
		_chat.on_friends = _page == "friends"
		_chat.sync()


		_chat.muted = "league" in shown or "territory" in shown
		if _chat.muted and _chat.is_open():
			_chat.close()
	_layers()

	if client.state == "lobby" and _pack.state == "ready" and not waiting:
		_pack.want_fallback_font()

	if _create_pending and client.state != "lobby":
		_create_pending = false
		if client.state == "hall":
			_arena.open_create()
	if client.state != "battle":
		_warm_scene = -1
		if _pack != null and _pack.pc_leave_battle():
			_room_warm = ""
	elif not client.battle.started and _warm_scene != client.battle.scene_id:
		_start_warm()
	if client.state in ["lobby", "hall", "room"]:
		_warm_room()

	if client.state == "battle" and _pack != null and client.battle.active and not client.battle.ended and not client.map_fetch\
	and not client.battle.supported():
		_bcm1_tell("cho%d" % client.bcm1_tries(), client.battle.map_id, false)
		client.bcm1_retry_map(_pack.wants_map(client.battle.map_id))
	if _battle_view != null:
		_battle_view.visible = client.state == "battle"
		if client.state == "battle" and client.battle.supported() and not client.battle.started:
			_battle_view.load_assets()
			if _warm_ready():
				_pack.ios_keep(_warm_own)
				client.complete_battle_load()
		elif client.state == "battle" and client.map_fetch:
			_pack.request_map(client.battle.map_id)

			for look: Dictionary in client.battle.appearances.values():
				_pack.external_art(_pack.art_external(str(look.get("external", 0)), int(look.get("tank", 0))))





var _talent_host: Control = null
var _talent_view: Control = null
var _talent_from: Control = null

func _tl1a_setup(host: Control) -> void :
	_talent_host = host
	host.connect("talent_asked", open_talent)
	host.visibility_changed.connect( func() -> void :
		if not host.visible and _talent_view != null and _talent_view.visible and _talent_view.has_method("close"):
			_talent_view.call("close"))
	client.noticed.connect( func(text: String) -> void :
		if _talent_view != null and _talent_view.is_visible_in_tree() and _talent_view.has_method("say"):
			_talent_view.call("say", text))


func open_talent(tank_uuid: String = "") -> void :
	if not preload("res://ui/lobby_bar.gd").talent_script_ok():
		return
	if _talent_view == null:
		var script: Script = load("res://ui/talent.gd") as Script
		if script == null:
			return
		var view: Variant = script.new()
		if not view is Control:
			return
		_talent_view = view
		_talent_view.set("client", client)
		_talent_view.set("pack", _pack)
		_talent_view.visible = false
		_talent_view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(_talent_view)
		_talent_view.visibility_changed.connect(_talent_cover)
	if _talent_from != null and _gate != null:
		move_child(_talent_view, _gate.get_index())
	elif _talent_host != null:
		move_child(_talent_view, _talent_host.get_index() + 1)
	if _talent_view.has_method("open_for"):
		_talent_view.call("open_for", client, tank_uuid)
	_talent_cover()


func _talent_cover() -> void :
	if _talent_view != null and not _talent_view.visible and _talent_from != null:
		var from: Control = _talent_from
		_talent_from = null
		if is_instance_valid(from):
			from.set("covered", false)
		_refresh()
		return
	if _talent_host != null and _talent_view != null:
		if _talent_host == _select_tank:
			_pick_cover()
		else:
			_talent_host.set("covered", _talent_view.visible and _talent_from == null)
	_talent_bar_cover()






var _crystal_host: Control = null
var _pick_crystal: Control = null

func _cr2_setup(host: Control) -> void :
	if not host.has_signal("crystal_asked"):
		return
	_crystal_host = host
	host.connect("crystal_asked", open_crystal)
	host.visibility_changed.connect( func() -> void :
		if not host.visible and _pick_crystal != null and _pick_crystal.visible:
			_pick_crystal.visible = false)


func open_crystal(tank_uuid: String = "") -> void :
	if _crystal_host == null or not _crystal_host.is_visible_in_tree():
		return
	if _pick_crystal == null:
		var view: CrystalView = CrystalView.new()
		view.client = client
		view.pack = _pack
		view.overlay = true
		view.visible = false
		view.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		add_child(view)
		view.closed.connect( func() -> void : view.visible = false)
		view.visibility_changed.connect(_crystal_cover)
		_pick_crystal = view
	if _arena != null:
		_pick_crystal.set("hall", _arena.hall)
	move_child(_pick_crystal, _crystal_host.get_index() + 1)
	var tank: Dictionary = {}
	if not tank_uuid.is_empty():
		for inst: Dictionary in client.tanks.values():
			if str(inst.get("m_tankUuid", "")) == tank_uuid:
				tank = inst
				break
	if tank.is_empty() and _crystal_host.has_method("my_tank") and int(_crystal_host.call("my_tank")) > 0:
		tank = {"m_tpltId": int(_crystal_host.call("my_tank"))}
	var scheme: int = int(_crystal_host.call("crystal_index")) + 1 if _crystal_host.has_method("crystal_index") else 0
	_pick_crystal.call("open_for", tank, scheme)
	_crystal_cover()


func _crystal_cover() -> void :
	if _crystal_host == null or _pick_crystal == null:
		return
	if _crystal_host == _select_tank:
		_pick_cover()
		return
	var talent: bool = _talent_view != null and _talent_view.visible and _talent_from == null and _talent_host == _crystal_host
	_crystal_host.set("covered", _pick_crystal.visible or talent)



func _bar_talent(tank_uuid: String, from: Control) -> void :
	if not preload("res://ui/lobby_bar.gd").talent_script_ok():
		return
	_talent_from = from
	if _chat != null and _chat.is_open():
		_chat.close()
	open_talent(tank_uuid)
	if _talent_view == null or not _talent_view.visible:
		_talent_from = null
		return
	_refresh()


func _talent_bar_cover() -> void :
	if _talent_from == null or _talent_view == null or not _talent_view.visible:
		return
	if not is_instance_valid(_talent_from) or not _talent_from.is_visible_in_tree():
		if _talent_view.has_method("close"):
			_talent_view.call("close")
		return
	_talent_from.set("covered", true)
