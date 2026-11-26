extends RefCounted



const TABS: Array = ["all", "unread", "gift"]
const TAB_NAMES: Array = ["Hộp thư đến", "Chưa đọc", "Có quà"]
const EMPTY: Dictionary = {"all": "Chưa có thư nào", "unread": "Không có thư chưa đọc", "gift": "Không có thư nào còn quà", "sent": "Chưa gửi thư nào"}
const SILVER_ITEM: int = 990030103




static func sent_rows(body: PackedByteArray) -> Array:
	var out: Array = []
	var data: Variant = JSON.parse_string(body.get_string_from_utf8()) if not body.is_empty() else null
	if not data is Array:
		return out
	for item: Variant in data:
		if not item is Dictionary:
			continue
		var row: Dictionary = item
		out.append({"uuid": str(row.get("send_mail_id", "")), "title": str(row.get("mail_title", "")), "receiver": str(row.get("receiver_name", "")), 
			"text": str(row.get("mail_text", "")), "deadline": int(row.get("arrive_time", 0))})
	return out

static func find(mails: Array, uuid: String) -> Dictionary:
	for mail: Dictionary in mails:
		if str(mail.get("uuid", "")) == uuid:
			return mail
	return {}


static func rows(mails: Array, tab: String, keep: String = "") -> Array:
	var out: Array = []
	for mail: Dictionary in mails:
		var fits: bool = tab == "all" or (tab == "unread" and bool(mail.get("unread", false))) or (tab == "gift" and bool(mail.get("gift", false)))
		if fits or ( not keep.is_empty() and str(mail.get("uuid", "")) == keep):
			out.append(mail)
	return out


static func counts(mails: Array) -> Array:
	var unread: int = 0
	var gift: int = 0
	for mail: Dictionary in mails:
		unread += 1 if bool(mail.get("unread", false)) else 0
		gift += 1 if bool(mail.get("gift", false)) else 0
	return [mails.size(), unread, gift]


static func has_clearable(mails: Array) -> bool:
	for mail: Dictionary in mails:
		if not bool(mail.get("unread", false)) and not bool(mail.get("gift", false)):
			return true
	return false


static func left(deadline: int, now: int) -> Array:
	if deadline <= 0:
		return ["", false]
	var span: int = deadline - now
	if span <= 0:
		return ["Hết hạn", true]
	if span >= 86400:
		return ["Còn %d ngày" % (span / 86400), false]
	if span >= 3600:
		return ["Còn %d giờ" % (span / 3600), true]
	return ["Còn %d phút" % maxi(1, span / 60), true]




static func gifts(body: Dictionary, data: Dictionary) -> Array:
	var out: Array = []
	var cash: int = int(body.get("cash", 0))
	if cash > 0:
		out.append({"id": SILVER_ITEM, "name": "Bạc", "icon": "", "quality": 0, "count": cash, "coin": true, "head": false})
	var items: Dictionary = data.get("items", {})
	var more: Dictionary = data.get("more", {})
	for row: Array in body.get("items", []):
		var id: int = int(row[1])
		var count: int = maxi(1, int(row[2]))
		if id == SILVER_ITEM:
			out.append({"id": id, "name": "Bạc", "icon": "", "quality": 0, "count": count, "coin": true, "head": false})
		elif items.has(str(id)):
			var known: Array = items[str(id)]
			var fashion: bool = int(known[5]) == 4
			out.append({"id": id, "name": str(known[0]), "icon": "" if fashion else str(known[2]), "quality": int(known[3]), "count": count, "coin": false, "head": fashion})
		elif more.has(str(id)):
			var extra: Array = more[str(id)]
			out.append({"id": id, "name": str(extra[0]), "icon": str(extra[1]), "quality": int(extra[2]), "count": count, "coin": false, "head": false})
		else:
			out.append({"id": id, "name": "Vật phẩm #%d" % id, "icon": "", "quality": 0, "count": count, "coin": false, "head": false})
	return out


static func markup(text: String) -> String:
	var out: String = text.replace("\r", "").replace("[", "[lb]")
	out = RegEx.create_from_string("(?i)<br\\s*/?>").sub(out, "\n", true)
	out = RegEx.create_from_string("(?i)</p\\s*>").sub(out, "\n", true)
	out = RegEx.create_from_string("(?i)<font[^>]*?color\\s*=\\s*[\"']?#?([0-9a-f]{6})[\"']?[^>]*>").sub(out, "[color=#$1]", true)
	out = RegEx.create_from_string("(?i)<font[^>]*>").sub(out, "[color=#f4ead2]", true)
	out = RegEx.create_from_string("(?i)</font\\s*>").sub(out, "[/color]", true)
	out = RegEx.create_from_string("(?i)<b\\s*>").sub(out, "[b]", true)
	out = RegEx.create_from_string("(?i)</b\\s*>").sub(out, "[/b]", true)
	out = RegEx.create_from_string("<[^<>]{0,200}>").sub(out, "", true)
	return _unescape(out).strip_edges()


static func plain(text: String) -> String:
	var out: String = RegEx.create_from_string("(?i)<br\\s*/?>").sub(text.replace("\r", ""), " ", true)
	out = RegEx.create_from_string("<[^<>]{0,200}>").sub(out, "", true)
	return _unescape(out).replace("\n", " ").strip_edges()


static func printable(text: String, font: Font) -> String:
	var out: String = ""
	for i: int in text.length():
		var code: int = text.unicode_at(i)
		if code < 8192 or font.has_char(code):
			out += text[i]
		elif (code >= 8592 and code <= 8703) or (code >= 10132 and code <= 10175) or (code >= 10496 and code <= 10623):
			out += "»" if font.has_char(187) else "-"
	return out

static func _unescape(text: String) -> String:
	return text.replace("&nbsp;", " ").replace("&lt;", "<").replace("&gt;", ">").replace("&quot;", "\"").replace("&apos;", "'").replace("&#39;", "'").replace("&amp;", "&")
