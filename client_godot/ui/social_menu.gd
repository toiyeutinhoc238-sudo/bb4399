extends RefCounted









const AT: Vector2 = Vector2(614, -91)
const MASTER_Y: float = -60.0
const HISTORY_Y: float = -27.0
const MAIL_Y: float = 6.0
const REP_Y: float = 39.0
const SIDE: float = 29.0
const CLOVER: Vector2 = Vector2(6, 6)
const MASTER_TIP: Vector2 = Vector2(19, -69)
const MAIL_TIP: Vector2 = Vector2(19, -4)
const NUM_SIDE: float = 25.0
const MP_HIGH: float = 19.0
const MAIN_DOT: Vector2 = Vector2(634, 5)
const MORE: String = "!"
const TEXTURES: Dictionary = {"button": "res://assets/ui/hall/master_button.png", "clover": "res://assets/ui/hall/master_clover.png", 
	"mail": "res://assets/ui/hall/social_mail.png", "rep": "res://assets/ui/hall/social_rep.png", 
	"history": "res://assets/ui/hall/social_history.png"}
const TIPS: Dictionary = {"social:master": "Sư đồ", "social:history": "Lịch sử đấu", "social:rep": "Uy tín"}

var open: bool = false
var master_on: bool = false
var _master_rev: int = -1
var _tex: Dictionary = {}


static func label(count: int) -> String:
	if count <= 0:
		return ""
	return MORE if count > 9 else str(count)


func refresh(client: Variant) -> void :
	var model: Variant = client.master
	if model == null or client.master_rev == _master_rev:
		return
	_master_rev = client.master_rev
	if not master_on:
		master_on = not model.master.is_empty() or model.has_prentice() or not model.apply_list().is_empty() or not model.real_apply.is_empty()

func master_label(client: Variant) -> String:
	return label(client.master.apply_list().size()) if master_on and client.master != null else ""


func activate(id: String) -> bool:
	if id == "social":
		open = not open
		return true
	if id.begins_with("social:"):
		open = false
	return false



func parts(down: String) -> Array:
	if not open:
		return []
	if _tex.is_empty():
		for key: String in TEXTURES:
			_tex[key] = load(TEXTURES[key]) if ResourceLoader.exists(TEXTURES[key]) else null
	var out: Array = []
	if master_on:
		out.append(["social:master", _tex["button"], Rect2(AT + Vector2(0, MASTER_Y), Vector2(SIDE, SIDE))])
		out.append(["social:master", _tex["clover"], Rect2(AT + Vector2(0, MASTER_Y) + CLOVER, Vector2(18, 18))])
	out.append(["social:history", _tex["button"], Rect2(AT + Vector2(0, HISTORY_Y), Vector2(SIDE, SIDE))])
	out.append(["social:history", _tex["history"], Rect2(AT + Vector2(0, HISTORY_Y) + CLOVER, Vector2(18, 18))])
	out.append(["social:mail", _tex["button"], Rect2(AT + Vector2(0, MAIL_Y), Vector2(SIDE, SIDE))])
	out.append(["social:mail", _tex["mail"], Rect2(AT + Vector2(0, MAIL_Y), Vector2(30, 30))])
	var shift: Vector2 = Vector2(1, 1) if down == "social:rep" else Vector2.ZERO
	out.append(["social:rep", _tex["rep"], Rect2(AT + Vector2(0, REP_Y) + shift, Vector2(SIDE, SIDE))])
	return out


func hits() -> Array:
	if not open:
		return []
	var out: Array = []
	if master_on:
		out.append(["social:master", Rect2(AT + Vector2(0, MASTER_Y), Vector2(SIDE, SIDE))])
	out.append(["social:history", Rect2(AT + Vector2(0, HISTORY_Y), Vector2(SIDE, SIDE))])
	out.append(["social:mail", Rect2(AT + Vector2(0, MAIL_Y), Vector2(SIDE, SIDE))])
	out.append(["social:rep", Rect2(AT + Vector2(0, REP_Y), Vector2(SIDE, SIDE))])
	return out



func tips(client: Variant) -> Array:
	var unread: int = int(client.mail_unread)
	if not open:
		return [[Rect2(MAIN_DOT - Vector2(3, 3), Vector2(NUM_SIDE, NUM_SIDE)), ""]] if unread > 0 else []
	var out: Array = []
	var master: String = master_label(client)
	if not master.is_empty():
		out.append([Rect2(AT + MASTER_TIP, Vector2(NUM_SIDE, MP_HIGH)), master])
	if unread > 0:
		out.append([Rect2(AT + MAIL_TIP, Vector2(NUM_SIDE, NUM_SIDE)), label(unread)])
	return out
