extends RefCounted







const TimeOver = preload("res://ui/timeover_atlas.gd")
const SkillCell = preload("res://ui/skillcell_atlas.gd")
const DeathRound = preload("res://ui/deathround_atlas.gd")
const MinimapMarks = preload("res://battle/minimap_marks.gd")
const ResultMv = preload("res://battle/result_mv.gd")
const BattleHud = preload("res://battle/battle_hud.gd")
const BattleSound = preload("res://battle/battle_sound.gd")
const Settings = preload("res://settings.gd")

const SCENE_ITEMS: Array[int] = [30101, 30102, 30103, 30104, 30105, 30106, 30107]
const ITEM_FIELDS: Array[String] = ["i", "n", "o", "e", "x"]
const OCCUPY: Array[String] = ["occupy/ground", "occupy/flag_null", "occupy/flag_blue", "occupy/flag_red", 
	"occupy/map_occupy_blue", "occupy/map_occupy_red"]

const MINE_BUFFS: Array[int] = [10300102, 10300104, 10300101, 10300103, 10300062, 10300061]
const MAP_EXTRAS: Dictionary = {
	30: {"buffs": [1030003, 1030004], "ainpc": [6010, 6000]}, 
	40: {"buffs": [1030006, 1030007], "ainpc": [6012, 6011]}, 
}
const UI_SOUNDS: Array[String] = ["begin", "win", "lose", "relive", "spray", "bg_down", "medal_down"]



static func jobs(pack, battle) -> Array:
	if pack == null or pack.state != "ready" or pack.fx.is_empty():
		return []
	var out: Array = []
	var seen: Dictionary = {}
	var add: Callable = func(kind: String, key: String) -> void :
		if key.is_empty() or seen.has(kind + key):
			return
		seen[kind + key] = true
		out.append([kind, key])
		match kind:
			"e":
				pack.effect(key, true)
			"s":
				pack.sound(key, true)
			"a":
				pack.external_art(key)

	for key: Variant in TimeOver.TIPS.values():
		add.call("e", str(key))
	add.call("e", TimeOver.OVER)
	for key: String in [SkillCell.DONE, SkillCell.SELECT, SkillCell.BAN, MinimapMarks.ICONS, ResultMv.KEY]:
		add.call("e", key)
	for table: Dictionary in [MinimapMarks.HOME, MinimapMarks.SIGNAL, MinimapMarks.SIGNAL_ADD]:
		for key: Variant in table.values():
			add.call("e", str(key))
	if str(battle.mode) == "death":
		for key: Variant in DeathRound.RESULT_LAYERS + DeathRound.COUNT_LAYERS:
			add.call("e", str(key))
		for key: String in [DeathRound.RESULT_ADD, DeathRound.COUNT_ADD, DeathRound.TEXT]:
			add.call("e", key)
	if bool(battle.look):
		add.call("e", BattleHud.LOOK_HELP_UP)
	if battle.map != null and not battle.map.flags.is_empty():
		for key: String in OCCUPY:
			add.call("e", key)

	for id: int in SCENE_ITEMS:
		var row: Dictionary = pack.item(id)
		for field: String in ITEM_FIELDS:
			add.call("e", str(row.get(field, "")))

	var shots: Array = []
	for sid: int in battle.npc_shot_skills():
		var bullet: int = int(pack.skill(sid).get("b", 0))
		shots.append(bullet)
		var ex: Dictionary = pack.exhibit(bullet)
		for field: String in ["b", "x"]:
			add.call("e", str(ex.get(field, "")))

	var extra: Dictionary = MAP_EXTRAS.get(int(battle.map_id), {})
	if not extra.is_empty():
		var buffs: Array = MINE_BUFFS.duplicate()
		buffs.append_array(extra.buffs)
		for bid: Variant in buffs:
			var row: Array = pack.buff(int(bid))
			if not row.is_empty():
				add.call("e", str(row[0]))
		for template: Variant in extra.ainpc:
			var row: Array = pack.ainpc_row(int(template))
			for i: int in mini(2, row.size()):
				if int(row[i]) != 0:
					add.call("a", str(int(row[i])))

	if Settings.on("sfx") and Settings.level("sfx_vol") > 0.004:
		for name: String in UI_SOUNDS:
			add.call("s", "s/u/%s.mp3" % name)
		for look: Variant in battle.appearances.values():
			if look is Dictionary:
				var external: String = str(int(look.get("external", 0)))
				var death: String = BattleSound.death_name(pack.sounds, external, pack.art_external(external, int(look.get("tank", 0))))
				if not death.is_empty():
					add.call("s", "s/d/%s.mp3" % death)

		var table: Dictionary = pack.sounds
		for look: Variant in battle.appearances.values():
			if look is Dictionary:
				add.call("s", _snd("d", str(table.get("h", {}).get(str(int(look.get("external", 0))), ""))))
		for bullet: int in shots:
			var row: Variant = table.get("b", {}).get(str(bullet))
			if row is Array and (row as Array).size() >= 2:
				add.call("s", _snd("f", str(row[0])))
				add.call("s", _snd("x", str(row[1])))
		var templates: Dictionary = {}
		for id: int in SCENE_ITEMS:
			templates[id] = 4
		for id: Variant in battle.npcs:
			templates[int(battle.npcs[id].get("template", 0))] = int(id) >> 26
		for template: int in templates:
			match int(templates[template]):
				3:
					for name: Variant in BattleSound.pair(table, "n", template):
						add.call("s", _snd("n", str(name)))
				4:
					for name: Variant in BattleSound.pair(table, "c", template):
						add.call("s", _snd("f", str(name)))
				5:
					var row: Array = pack.ainpc_row(template)
					var external: String = BattleSound.ainpc_external(row, battle.self_camp())
					if not external.is_empty():
						add.call("s", _snd("d", str(table.get("d", {}).get(external, ""))))
						add.call("s", _snd("d", str(table.get("h", {}).get(external, ""))))
		if Settings.on("voice"):
			for voice: Variant in pack.sounds.get("k", []):
				add.call("s", "s/k/%s.mp3" % voice)
	return out


static func _snd(folder: String, name: String) -> String:
	return "" if name.is_empty() else "s/%s/%s.mp3" % [folder, name]


static func needs_ainpc(pack, battle) -> bool:
	return MAP_EXTRAS.has(int(battle.map_id)) and pack != null and not bool(pack.ainpc_settled)
