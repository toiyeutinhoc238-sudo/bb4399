extends RefCounted

const FILE: String = "res://assets/ui/hall/newbie.png"

const R: Dictionary = {
	"nb_act": [60, 658, 50, 50], 
	"nb_act_word": [294, 658, 64, 19], 
	"nb_big": [817, 2, 109, 109], 
	"nb_big_rare": [2, 547, 109, 109], 
	"nb_big_sel": [113, 547, 102, 102], 
	"nb_close": [268, 658, 24, 24], 
	"nb_coin1": [112, 658, 50, 50], 
	"nb_coin2": [164, 658, 50, 50], 
	"nb_coin3": [216, 658, 50, 50], 
	"nb_frame": [2, 2, 813, 543], 
	"nb_get": [631, 547, 88, 59], 
	"nb_get_off": [721, 547, 88, 59], 
	"nb_got": [537, 547, 92, 63], 
	"nb_q2": [811, 547, 56, 56], 
	"nb_q3": [869, 547, 56, 56], 
	"nb_q4": [927, 547, 56, 56], 
	"nb_q5": [2, 658, 56, 56], 
	"nb_small": [217, 547, 83, 83], 
	"nb_small_rare": [302, 547, 83, 83], 
	"nb_small_sel": [387, 547, 78, 78], 
	"nb_tile": [467, 547, 68, 68], 
}

const SIZE = [813, 529]

const FRAME = [0, -14]

const BOXES = [[58, 140, 0], [175, 140, 0], [292, 140, 0], [410, 140, 0], [525, 140, 0], [642, 140, 0], [134, 258, 1], [295, 258, 1], [457, 258, 1], [618, 258, 1]]

const BOX = {"small": {"item": [4, 4, 75, 75], "select": [2.5, 2.5], "got": [-4.5, 10], "rare": [-1.0, -1.0], "size": 83}, "big": {"item": [4.5, 4.5, 100, 100], "select": [3.5, 3.5], "got": [8.5, 23], "rare": [-5.5, -5.5], "size": 109}}

const DETAIL = [[30, 432], [108, 432], [188, 432], [265, 432], [345, 432], [423, 432]]

const TILE = {"bg": [4, 0], "quality": [10, 6], "item": [12, 10, 52, 48], "num": [-14, 46, 85]}

const NODES = {"btnClose": [776, 17, 24, 24], "btnGetAward": [633, 428, 88, 59], "swfGetAwardEffect": [674, 457, 0, 0]}

const TEXTS = {"lblDayDesc": [38, 407, 0, 0, 14, "ffffff", 1, "l"], "txtCurLoginDay": [579, 407, 200, 0, 12, "ffffff", 1, "c"], "lblNum": [16, 478, 85, 0, 12, "ffffff", 1, "r"]}

const STAGES = [[1800, 1, 2000150, false, [[1, 2004595, 1], [1, 3000147, 2], [1, 3000001, 50], [1, 3000051, 50], [2, 2, 10000], [2, 3, 20]]], [1801, 2, 2000151, false, [[2, 3, 40], [2, 2, 20000], [1, 2600004, 3], [1, 3700002, 10], [1, 3000051, 50], [1, 3000001, 50]]], [1802, 3, 2000152, false, [[1, 2200002, 1], [1, 3700003, 10], [1, 3000003, 50], [1, 3000052, 50], [2, 2, 30000], [2, 3, 60]]], [1803, 4, 2000153, false, [[1, 4400002, 1], [1, 3000147, 2], [1, 3000003, 100], [1, 3000052, 100], [2, 2, 50000], [2, 3, 80]]], [1804, 5, 2000154, false, [[2, 3, 100], [1, 3800001, 5], [1, 3700004, 5], [1, 3000148, 3], [1, 3000053, 75], [2, 2, 100000]]], [1805, 6, 2000155, false, [[1, 3000148, 1], [1, 4400002, 2], [1, 2700002, 5], [1, 3700004, 5], [1, 3000147, 3], [2, 2, 150000]]], [1806, 7, 2000156, true, [[1, 2000003, 1], [1, 3000151, 10], [1, 3000148, 3], [1, 3000053, 50], [1, 3000004, 50], [2, 2, 200000]]], [1807, 14, 2000157, false, [[1, 2004596, 1], [1, 2900005, 1], [1, 3000160, 5], [1, 3000053, 75], [1, 3000004, 75], [2, 2, 300000]]], [1808, 21, 2000158, false, [[1, 2004597, 1], [2, 3, 200], [1, 3000148, 3], [1, 3000156, 5], [1, 3000005, 50], [2, 2, 400000]]], [1809, 30, 2000159, false, [[1, 2003042, 1], [1, 3700008, 1], [1, 3800003, 5], [1, 2700002, 20], [1, 3000054, 75], [2, 2, 500000]]]]

const ITEMS = {"2000150": ["Quà Đăng Nhập 1 Ngày", "l/it/feiyicard.webp", 4, "Gói quà chào mừng tân thủ đăng nhập ngày đầu tiên, bao gồm thẻ dùng thử Chiến Binh Vũ Trụ level 4 trong 3 ngày và nhiều phần thưởng khác."], "2004595": ["Gundam（3 ngày）", "l/it/feiyicard.webp", 5, "Sử dụng nó trong gói để có thời gian dùng thử 3 ngày cho tank [Cánh bay cấp 4]."], "3000147": ["Thủy Tinh Moonlight", "l/it/icon_superskillitem_01.webp", 2, "Dùng để nâng cấp 7 tank cơ bản -  Rớt trong giải so tài - xếp hạng hoặc mua trong shop"], "3000001": ["Mảnh Sắt", "l/it/icon_upitem_a_01.webp", 0, "Nguyên liệu lên cấp 1→2 và cường hoá xe cấp 1, cấp 2"], "3000051": ["Topaz", "l/it/icon_upitem_f_01.webp", 0, "Nguyên liệu cường hoá xe cấp 1"], "2000151": ["Quà Đăng Nhập 2 Ngày", "l/it/denglu02.webp", 4, "Mở ra có thể nhận được nhiều phần thưởng khác nhau."], "2600004": ["Bóng Thần Bí", "l/it/shenmiqiu.webp", 2, "Quả cầu pha lê toát ra một hào quang bí ẩn. Bạn có thể mở vòng quay bí ẩn và nhấp đúp để mở nó."], "3700002": ["Chip siêu dẫn No.2", "l/it/icon_zhushou_jingyan02.webp", 1, "Tăng 100 exp trợ thủ — Chip siêu dẫn No.2 làm từ nguyên liệu quý, lưu dữ liệu mật."], "2000152": ["Quà Đăng Nhập 3 Ngày", "l/it/vip02_t.webp", 4, "Gói chào mừng dành cho người mới đăng nhập vào ngày thứ 3. Mở nó để nhận được nhiều phần thưởng khác nhau."], "2200002": ["Thẻ Vip Tuần", "l/it/vip02_t.webp", 1, "Sử dụng để nhận được thời gian vip 7 ngày."], "3700003": ["Chip siêu dẫn No.3", "l/it/icon_zhushou_jingyan03.webp", 2, "Tăng 500 exp trợ thủ — Chip siêu dẫn No.3 làm từ nguyên liệu quý, lưu dữ liệu mật."], "3000003": ["Mảnh Thép", "l/it/icon_upitem_a_03.webp", 1, "Nguyên liệu lên cấp 2→3 và cường hoá xe cấp 3"], "3000052": ["Hồng Bảo", "l/it/icon_upitem_f_02.webp", 1, "Nguyên liệu cường hoá xe cấp 2"], "2000153": ["Quà Đăng Nhập 4 Ngày", "l/it/denglu04.webp", 4, "Gói chào mừng dành cho người mới đăng nhập vào ngày thứ 4. Mở nó để nhận được nhiều phần thưởng khác nhau."], "4400002": ["Lõi vạn năng No.2", "l/it/icon_jiaxingcailiao02.webp", 2, "Nguyên liệu lên sao trợ thủ 3 sao và 4 sao — lõi năng lượng tương thích cao, nguồn động lực trợ thủ."], "2000154": ["Quà Đăng Nhập 5 Ngày", "l/it/denglu05.webp", 4, "Gói chào mừng dành cho người mới đăng nhập ngày thứ 5. Mở nó để nhận được nhiều phần thưởng khác nhau."], "3800001": ["Siêu tinh thể cấp 1", "l/it/icon_zhushou_qianghua01.webp", 1, "Dùng cường hóa trợ thủ lần 1~10 — tinh thể luyện từ khoáng quý, cường độ năng lượng 1."], "3700004": ["Chip siêu dẫn No.4", "l/it/icon_zhushou_jingyan04.webp", 2, "Tăng 1000 exp trợ thủ — Chip siêu dẫn No.4 làm từ nguyên liệu quý, lưu dữ liệu mật."], "3000148": ["Thạch Anh Mặt Trời", "l/it/icon_skillitem_01.webp", 3, "Dùng để nâng cấp các tank cao cấp - Rớt trong giải so tài - xếp hạng hoặc mua trong shop"], "3000053": ["Lục bảo", "l/it/icon_upitem_f_03.webp", 2, "Nguyên liệu cường hoá xe cấp 3"], "2000155": ["Quà Đăng Nhập 6 Ngày", "l/it/icon_skillitem_01.webp", 4, "Gói chào mừng dành cho người mới đăng nhập vào ngày thứ sáu. Mở nó để nhận được nhiều phần thưởng khác nhau."], "2700002": ["Thẻ Team Bạc", "l/it/gongxian02.webp", 3, "Sử dụng nhận 100 quỹ team và 100 cống hiến cá nhân."], "2000156": ["Quà Đăng Nhập 7 Ngày", "l/it/feiyicard.webp", 4, "Gói chào mừng dành cho người mới đăng nhập vào ngày thứ 7. Mở nó để nhận được nhiều phần thưởng khác nhau."], "2000003": ["Gundam", "l/it/feiyicard.webp", 4, "Dùng trong túi sẽ nhận tank \"Gundam\"."], "3000151": ["Phiếu đổi skin Tank", "l/it/meirongquan.webp", 2, "Dùng để đổi skin tank"], "3000004": ["Carbon", "l/it/icon_upitem_a_04.webp", 2, "Nguyên liệu lên cấp 3→4 và cường hoá xe cấp 4"], "2000157": ["Quà Đăng Nhập 14 Ngày", "l/it/wukongcard.webp", 4, "Gói chào mừng dành cho người mới đăng nhập ngày 14, bao gồm thẻ Ngộ Không cấp 4 dùng thử 3 ngày và nhiều phần thưởng khác nhau"], "2004596": ["Songoku（3 ngày）", "l/it/wukongcard.webp", 5, "Sử dụng nó trong gói để có thời gian dùng thử 3 ngày cho tank [Songoku cấp 4]."], "2900005": ["giờ hạnh phúc", "l/it/childrenDay.webp", 4, "Đạo cụ trang trí, đổi khung viền và nền.#ENTER#Trời xanh, đồng cỏ, cánh diều, bạn bè — thật là một thời tươi đẹp!"], "3000160": ["Pha lê mặt trời mọc (VN)", "l/it/riyaoshuijing.webp", 4, "Pha lê tụ năng lượng mặt trời — cần Búa nghiền để mở! Mở nhận Pha lê mặt trời và nguyên liệu riêng nâng cấp tank cấp 6 ngẫu nhiên."], "2000158": ["Quà Đăng Nhập 21 Ngày", "l/it/xuanwocard.webp", 4, "Gói quà chào mừng tân thủ đăng nhập ngày thứ 21, bên trong bao gồm thẻ dùng thử Cửu Vĩ Nhẫn Giả level 4 trong 3 ngày và nhiều phần thưởng khác."], "2004597": ["Naruto（3 ngày）", "l/it/xuanwocard.webp", 5, "Sử dụng nó trong gói để có thời gian dùng thử 3 ngày cho tank [Naruto cấp 4]."], "3000156": ["búa đập vỡ", "l/it/hammer_fensui.webp", 4, "Búa thần kỳ — đập vật gì cũng trả về dạng gốc."], "3000005": ["Alumin", "l/it/icon_upitem_a_05.webp", 3, "Nguyên liệu lên cấp 4→5 và cường hoá xe cấp 5"], "2000159": ["Quà Đăng Nhập 30 Ngày", "l/it/suijiegg.webp", 4, "Gói quà chào mừng dành cho người mới đăng nhập vào ngày thứ 30. Mở nó để nhận được nhiều phần thưởng khác nhau."], "2003042": ["Trứng tank ngẫu nhiên", "l/it/suijiegg.webp", 4, "Mở thẻ để ngẫu nhiên nhận được một trong các tank sau: Wing, Networm, Captain, Gourd, Peashooter, Dark Knight, Gấu Teddy, Hulk, Wukong, Evil Spirit, Steel Claw, Thor, Elf Prince, Songoku, Whirlpool và Soap Baby."], "3700008": ["Chip siêu dẫn No.8", "l/it/icon_zhushou_jingyan08.webp", 4, "Tăng 100000 exp trợ thủ — Chip siêu dẫn No.8 làm từ nguyên liệu quý, lưu dữ liệu mật."], "3800003": ["Siêu tinh thể cấp 3", "l/it/icon_zhushou_qianghua03.webp", 2, "Dùng cường hóa trợ thủ lần 21~30 — tinh thể luyện từ khoáng quý, cường độ năng lượng 3."], "3000054": ["Tử bảo", "l/it/icon_upitem_f_04.webp", 3, "Nguyên liệu cường hoá xe cấp 4"]}

const DAY_DESC = "Thưởng tích lũy login %d ngày"

const LOGIN = "Tích lũy login %d ngày"

const FX = [["nbl/rare_small", "NewbieLoginAwardBox.swfRare (ô nhỏ)", 24, [85, 85]], ["nbl/rare_big", "NewbieLoginAwardBox.swfRare (ô lớn)", 24, [120, 120]], ["nbl/get", "NewbieLoginFrame.swfGetAwardEffect", 17, [1, 1]]]

const FX_FPS = 24

const ACT = {"word": [-7, 31], "tip": [30, 0], "at": 198}
