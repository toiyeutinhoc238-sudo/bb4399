extends RefCounted


const FILE: String = "res://assets/ui/hall/room_gift.png"

const R: Dictionary = {
	"gda_rg_bg": [2, 2, 154, 167], 
	"gda_rg_it_gift_rocket1": [158, 2, 80, 80], 
	"gda_rg_it_gift_rocket2": [240, 2, 80, 80], 
	"gda_rg_it_gift_rocket3": [322, 2, 80, 80], 
	"gda_rg_it_loveheart1": [404, 2, 80, 80], 
	"gda_rg_it_loveheart2": [2, 171, 80, 80], 
	"gda_rg_it_loveheart3": [84, 171, 80, 80], 
	"gda_rg_item_bg": [166, 171, 42, 42], 
}


const ITEMS: Array = [
	[2001001, "Love", "Món quà tặng người yêu thể hiện tình yêu vô bờ bến trong trái tim bạn. Sử dụng tăng điểm lãng mạn +1.\nNgười nhận tăng điểm quyến rũ quyến rũ +1\nHP: +2% Hiệu ứng kéo dài trong một trận chiến", 3, "loveheart1", 0], 
	[2001011, "trái tim chân thành", "Món quà tặng người yêu thể hiện tình yêu vô bờ bến trong trái tim bạn.\nNgười cho: Giá trị lãng mạn +10\nNgười nhận: Giá trị quyến rũ +10 HP: +4%\nHiệu ứng kéo dài trong một trận chiến", 3, "loveheart2", 0], 
	[2001013, "Lời thề của nhau", "Món quà tặng người yêu thể hiện tình yêu vô bờ bến trong trái tim bạn.\nNgười cho: Giá trị lãng mạn +100\nNgười nhận: Giá trị quyến rũ +100 HP: +8%\nHiệu ứng kéo dài trong một trận chiến", 3, "loveheart3", 0], 
	[2001002, "pháo hoa", "Đốt pháo hoa trang trí để thêm vào lễ kỷ niệm.\nNgười cho: Giá trị lãng mạn +1\nNgười nhận: Giá trị quyến rũ +1 Sức tấn công: +2%\nHiệu ứng kéo dài trong một trận chiến", 3, "gift_rocket1", 0], 
	[2001012, "Pháo hoa", "Đốt pháo hoa trang trí để thêm vào lễ kỷ niệm.\nNgười cho: Giá trị lãng mạn +10\nNgười nhận: Giá trị quyến rũ +10 Sức tấn công: +4%\nHiệu ứng kéo dài trong một trận chiến", 3, "gift_rocket2", 0], 
	[2001014, "Sao đầy trời", "Đốt pháo hoa trang trí để thêm vào lễ kỷ niệm.\nNgười cho: Giá trị lãng mạn +100\nNgười nhận: Giá trị quyến rũ +100 Sức tấn công: +8%\nHiệu ứng kéo dài trong một trận chiến", 3, "gift_rocket3", 0], 
]
