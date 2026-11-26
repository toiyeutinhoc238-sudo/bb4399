extends RefCounted











const BagModel = preload("bag_model.gd")
const WIDE: float = 252.0
const BEGIN_Y: float = 10.0
const LABEL: float = 16.0
const PARA: float = 10.0
const X: float = 5.0
const TEXT_WIDE: float = 244.0
const ICON: float = 50.0
const SPACE: float = 120.0
const FIRST: float = 5.0
const GOLD: float = 22.0
const GOLD_X: float = 65.0
const TITLE_PX: float = 14.0
const PX: float = 12.0
const DEC: Color = Color("cccccc")
const PRESENT: Color = Color("ffcc00")
const SELL: Color = Color("2097c8")
const DROP: Color = Color("ffff00")
const EFFECT: Color = Color("00ff00")
const LIMIT: Color = Color("c70000")
const QUALITY: Dictionary = {2: Color("15ee19"), 3: Color("06fffc"), 4: Color("ff6eff")}
const ORANGE: Color = Color("f18819")
const BIND_SIDE: float = 30.0
const TIME_START: int = 4
const SYS_BIND: int = 1
const T_PRESENT: int = 20
const T_DROP: int = 27
const T_AVATAR: int = 28
const T_DECORATE: int = 30
const T_AVATAR_CARD: int = 32
const T_GIVE_ITEM: int = 52
const T_TANK_SKIN: int = 29
const T_LADDER_FRAME: int = 64
const GIVE_ITEM: int = 1
const GIVE_COIN: int = 2
const GIVE_TANK: int = 3

const WORDS: Dictionary = {"ITEM_TEXT1": "[Thưởng]", "ITEM_TEXT2": "[Giới thiệu]", "ITEM_TEXT3": "[Hiệu quả]", 
	"ITEM_TEXT6": "[Có thể nhận những VP sau]", "ITEM_TEXT10": "[Giới Hạn Dùng]", "ITEM_TEXT11": "Có tank [@name@]", 
	"TIP_6": "Hiệu lực vĩnh viễn", "TIP_7": "Ngày", "TIP_8": "Thời gian có hiệu lực", "TIP_9": "Quá hạn", "TIP_223": "Thời hạn: @time@", 
	"TIP_382": "Dùng xong nhận được thời trang @time@ ngày", "TIP_453": "@text1@x@num1@", "TIP_483": "Nhấp bán VP trong túi", 
	"CONTROL_TEXT38": "@name@ (skin)"}

const COIN_NAMES: Dictionary = {1: "Xu", 2: "Bạc", 3: "Xu Khóa", 4: "Huy chương", 7: "Xu Vàng"}

static func tint(quality: int) -> Color:
	if quality <= 1:
		return Color.WHITE
	return QUALITY.get(quality, ORANGE)







static func layout(rec: Dictionary, data: Dictionary, ctx: Dictionary, tall: Callable) -> Dictionary:
	var ops: Array = []
	var y: float = BEGIN_Y
	var kind: int = int(rec.get("type", 0))
	var id: int = int(rec.get("id", 0))
	var row: Array = data.get("items", {}).get(str(id), [])

	ops.append(["label", str(rec.get("name", "")), Vector2(X, y), TITLE_PX, tint(int(rec.get("quality", 0))), true, 0.0])
	y += LABEL
	if bool(rec.get("bind", false)):
		ops.append(["cell", "itp_bind", Rect2(WIDE - BIND_SIDE - 1.0, 4.0, BIND_SIDE, BIND_SIDE)])
	y += PARA
	if kind == T_DROP:
		ops.append(["label", WORDS.ITEM_TEXT6, Vector2(X, y), PX, DROP, false, 0.0])
	else:
		ops.append(["label", WORDS.ITEM_TEXT2, Vector2(X, y), PX, DEC, false, 0.0])
	y += LABEL
	var desc: String = str(rec.get("desc", ""))
	var rows: Array = (ctx.rich as Callable).call(desc) if ctx.has("rich") and not desc.is_empty() else []
	if not rows.is_empty():
		var line: float = float(ctx.get("line", LABEL))
		ops.append(["rich", rows, Vector2(X + 2.0, y), PX, line])
		y += rows.size() * line + 6.0
	else:
		var high: float = float(tall.call(desc, TEXT_WIDE, PX)) if not desc.is_empty() and not ctx.has("rich") else 0.0
		if high > 0.0:
			ops.append(["para", desc, Vector2(X, y), TEXT_WIDE, PX, DEC])
		y += high + 6.0
	var sale: int = int(row[7]) if row.size() >= 10 else 0
	if sale > 0:
		ops.append(["label", WORDS.TIP_483, Vector2(X, y), PX, SELL, false, 0.0])
		y += LABEL
	match kind:
		T_PRESENT:
			y = _presents(ops, y, id, data, ctx)
			var need: int = int(rec.get("reuse", 0))
			if need != 0 and not ctx.get("owned", []).has(need):
				y += PARA
				ops.append(["label", WORDS.ITEM_TEXT10, Vector2(X, y), PX, LIMIT, false, 0.0])
				y += LABEL
				var tank: String = str(ctx.get("tanks", {}).get(str(need), need))
				ops.append(["label", WORDS.ITEM_TEXT11.replace("@name@", tank), Vector2(X, y), PX, Color.WHITE, false, 0.0])
				y += LABEL
		T_AVATAR:
			y = _effect(ops, y, BagModel.avatar_fx(ctx.get("fx", {}), id))
			y += LABEL
			if not str(rec.get("art", "")).is_empty():
				ops.append(["pic", str(rec.art), Rect2(0, y, 135, 180)])
			y += 180.0 + LABEL
		T_DECORATE:
			y = _decorate(ops, y, id, ctx)
		T_TANK_SKIN:
			y += LABEL
			if not str(rec.get("face", "")).is_empty():
				ops.append(["face", str(rec.face), Rect2(26, y, 200, 200)])
			y += 200.0
		T_LADDER_FRAME:
			y += LABEL
			if not str(rec.get("art", "")).is_empty():
				ops.append(["pic", str(rec.art), Rect2(76, y, 100, 100)])
			y += 120.0
		T_GIVE_ITEM:
			var target: Array = data.get("items", {}).get(str(int(rec.get("reuse", 0))), [])
			if target.size() >= 10 and int(target[4]) == T_DECORATE:
				y = _decorate(ops, y, int(rec.reuse), ctx)

	if not bool(ctx.get("no_time", false)):
		y += LABEL
		var life: int = int(rec.get("life", 0))
		var span: String
		if life == 0:
			var limit: String = str(data.get("limits", {}).get(str(id), "0"))
			span = WORDS.TIP_6 if limit == "0" else WORDS.TIP_223.replace("@time@", limit)
		elif int(rec.get("flag", 0)) & TIME_START:
			var left: int = life - int(ctx.get("now", 0))
			span = WORDS.TIP_9 if left < 0 else WORDS.TIP_8 + str(ceili(left / 86400.0)) + WORDS.TIP_7
		elif kind == T_AVATAR_CARD:
			span = WORDS.TIP_382.replace("@time@", str(life))
		else:
			span = WORDS.TIP_8 + str(life) + WORDS.TIP_7
		ops.append(["label", span, Vector2(X, y), PX, Color.WHITE, false, 0.0])
		y += LABEL

	if sale > 1:
		var coin: String = str(ctx.get("coins", {}).get(str(int(row[8])), ""))
		var spot: Vector2 = Vector2(WIDE - GOLD_X, y - LABEL)
		if not coin.is_empty():
			ops.append(["cell", coin, Rect2(spot, Vector2(GOLD, GOLD))])
		ops.append(["label", str(sale), spot + Vector2(GOLD, 0), PX, DEC, true, 0.0])
	return {"wide": WIDE, "high": y + LABEL, "ops": ops}


static func _presents(ops: Array, y: float, id: int, data: Dictionary, ctx: Dictionary) -> float:
	var gifts: Array = data.get("presents", {}).get(str(id), [])
	if gifts.is_empty():
		return y
	y += PARA
	ops.append(["label", WORDS.ITEM_TEXT1, Vector2(X, y), PX, PRESENT, false, 0.0])
	y += LABEL + FIRST
	var skins: Array = data.get("skins", [])
	for i in range(gifts.size()):
		if i % 2 == 0 and i != 0:
			y += ICON + LABEL
		var gift: Array = gifts[i]
		var x0: float = X + SPACE * float(i % 2)
		var cell: Rect2 = Rect2(x0 + (SPACE - ICON) / 2.0, y, ICON, ICON)
		var count: String = str(int(gift[2]))
		match int(gift[0]):
			GIVE_COIN:
				var name: String = str(COIN_NAMES.get(int(gift[1]), ""))
				ops.append(["label", WORDS.TIP_453.replace("@text1@", name).replace("@num1@", count), Vector2(x0, y + ICON), PX, Color.WHITE, false, SPACE])
				var big: String = str(ctx.get("bigs", {}).get(str(int(gift[1])), ""))
				if not big.is_empty():
					ops.append(["cell", big, cell])
			GIVE_ITEM:
				var item: Array = data.get("items", {}).get(str(int(gift[1])), [])
				var more: Array = data.get("more", {}).get(str(int(gift[1])), [])
				if item.size() >= 10 or more.size() >= 4:
					var name: String = str(item[0]) if item.size() >= 10 else str(more[0])
					if skins.has(int(gift[1])):
						name = WORDS.CONTROL_TEXT38.replace("@name@", name)
					var quality: int = int(item[3]) if item.size() >= 10 else int(more[2])
					ops.append(["label", WORDS.TIP_453.replace("@text1@", name).replace("@num1@", count), Vector2(x0, y + ICON), PX, tint(quality), false, SPACE])
					var key: String = str(item[2]) if item.size() >= 10 else str(more[1])
					if not key.is_empty():
						var fashion: bool = item.size() >= 10 and int(item[5]) == 4
						ops.append(["pic", ("l/av/" if fashion else "l/it/") + key + ".webp", cell])
			GIVE_TANK:
				var tank: String = str(ctx.get("tanks", {}).get(str(int(gift[1])), ""))
				if not tank.is_empty():
					ops.append(["label", tank, Vector2(x0, y + ICON), PX, PRESENT, false, SPACE])
	return y + ICON + LABEL


static func _effect(ops: Array, y: float, text: String) -> float:
	if text.is_empty():
		return y
	y += PARA
	ops.append(["label", WORDS.ITEM_TEXT3, Vector2(X, y), PX, EFFECT, false, 0.0])
	y += LABEL
	ops.append(["label", text, Vector2(X, y), PX, EFFECT, false, 0.0])
	return y + LABEL


static func _decorate(ops: Array, y: float, id: int, ctx: Dictionary) -> float:
	y = _effect(ops, y, BagModel.decor_fx(ctx.get("fx", {}), id))
	y += LABEL
	var stem: String = str(ctx.get("ornate", {}).get(str(id), ""))
	if not stem.is_empty():
		ops.append(["pic", "l/or/%s.webp" % stem, Rect2((WIDE - 180.0) / 2.0, y, 180, 240)])
	var me: String = str(ctx.get("me", ""))
	if not me.is_empty():
		ops.append(["pic", "l/av/%s.webp" % me, Rect2((WIDE - 126.0) / 2.0, y + 54.0, 126, 168)])
	return y + 250.0



static func place(mouse: Vector2, size: Vector2, stage: Vector2) -> Vector2:
	var at: Vector2 = Vector2(mouse.x - size.x, mouse.y)
	if at.x < 0.0:
		at.x = mouse.x
	if mouse.y > stage.y - size.y:
		at.y = mouse.y - size.y
	at.y = maxf(0.0, at.y)
	return at
