extends RefCounted

const FILE: String = "res://assets/ui/hall/training.png"

const R: Dictionary = {
	"tr_base_off": [2, 530, 140, 40], 
	"tr_base_on": [144, 530, 140, 40], 
	"tr_btm": [392, 609, 388, 10], 
	"tr_build_pvp": [2, 348, 200, 180], 
	"tr_build_teach": [579, 2, 250, 200], 
	"tr_confirm": [2, 572, 120, 35], 
	"tr_flag_off": [286, 530, 140, 40], 
	"tr_flag_on": [428, 530, 140, 40], 
	"tr_happy_on": [570, 530, 140, 40], 
	"tr_head": [124, 572, 395, 34], 
	"tr_head_on": [521, 572, 395, 34], 
	"tr_hot_off": [712, 530, 140, 40], 
	"tr_hot_on": [854, 530, 140, 40], 
	"tr_mid": [2, 609, 388, 20], 
	"tr_outer": [2, 2, 575, 344], 
	"tr_roomtype_bk": [204, 348, 153, 53], 
	"tr_tab_pvp_off": [359, 348, 145, 41], 
	"tr_tab_pvp_on": [506, 348, 145, 41], 
	"tr_tab_teach_off": [653, 348, 145, 41], 
	"tr_tab_teach_on": [800, 348, 145, 41], 
	"tr_title": [918, 572, 79, 27], 
	"tr_top": [2, 631, 388, 10], 
}

const FRAME = [618, 500]

const AT = {"btnConfirm": [249, 447, 120, 35], "btnTutorial": [185, 49, 145, 41], "image9": [33, 102, 153, 53], "image7": [33, 152, 153, 53], "btnHot": [39, 108, 140, 40], "btnBase": [39, 158, 140, 40], "image8": [33, 202, 153, 53], "btnFlag": [39, 208, 140, 40], "btnPvp": [36, 49, 145, 41], "imgBuild": [50, 303, 200, 180], "btnHappy": [39, 108, 140, 40], "imgBuildTeach": [35, 299, 250, 200], "title": [269.5, 19, 79, 27], "outer": [21.5, 88, 575, 344], "acc": [188, 107, 395, 310]}

const HEADER = [34, 14, 32, "ffffff"]

const CONTENT = {"w": 388, "edge": 10, "desc": [12, 12, 364, 220, 16, "ffffff", 1, "l"]}

const MAPS = {"82": ["Luyện Vui Vẻ", "Đấu Vui Vẻ: phá chướng ngại, nhặt vp, thẻ điểm, tích lũy để phân hạng và nhận thưởng theo điểm", 8, 0], "101": ["Luyện Nhiệt Huyết", "TIPS: Tiêu diệt đối phương để giành điểm số và phần thắng!", 5, 3], "102": ["Luyện Căn Cứ", "TIPS: Phá huỷ căn cứ địch là thắng ngay. Hết giờ mà hai căn cứ chưa bị phá hết thì bên còn nhiều máu căn cứ hơn thắng; nếu cả hai căn cứ đều chưa mất máu thì cả hai bên đều thua.", 5, 1], "103": ["Luyện Cứ Điểm", "TIPS: Chiếm lĩnh và bảo vệ nhiều cứ điểm hơn, theo thời gian sẽ tăng thêm điểm, tích lũy đạt 1000 điểm sẽ thắng.", 5, 2], "150": ["Luyện Nhiệt Huyết [căn cứ diễn tập]", "Căn Cứ Diễn Tập: tránh đòn tấn công của địch, tìm cơ hội hạ Tank địch", 6, 3], "151": ["Luyện Nhiệt Huyết [Di Chỉ Khảo Cổ]", "Di Chỉ Khảo Cổ: dựa vào khối đá lớn giữa bản đồ để vòng đánh địch, phá rương cứu thương trước là lựa chọn không tồi", 6, 3], "152": ["Luyện Nhiệt Huyết [Băng Thiên Tuyết Địa]", "Băng Thiên Tuyết Địa: có ba đường trên, giữa, dưới; dồn quân tiêu diệt từng nhóm địch. Chú ý rương cứu thương trong căn cứ địch", 6, 3], "153": ["Luyện Nhiệt Huyết [Di ngôn Maya]", "Di Ngôn Maya: phá các viên gạch xếp thành chữ 2013 để tìm rương cứu thương, dựa vào nó cầm cự với địch", 6, 3], "166": ["Luyện Nhiệt Huyết [Tranh đoạt mỏ khoáng]", "Tranh Đoạt Mỏ Khoáng: phá hủy cứ địa địch, phá rương cứu thương và Tháp Pháo địch", 6, 1], "167": ["Luyện Nhiệt Huyết [Di Chỉ Maya]", "Di Chỉ Maya: Nắm bắt tháp pháo khu giữa để tạo ưu thế hạ địch", 6, 1], "168": ["Luyện Căn Cứ [DOTA Địa Cực]", "DOTA Địa Cực: phá tháp pháo tên lửa ở đường giữa sẽ có ưu thế lớn; đánh thẳng không được thì thử đánh lén từ đường biên", 6, 1], "175": ["Luyện Cứ Điểm[Di Chỉ Khảo Cổ]", "Rally: Thi đấu kịch liệt, chiếm lĩnh cứ điểm duy nhất và bảo vệ nó cho đến khi đạt 1000 điểm để giành chiến thắng!", 6, 2], "176": ["Bãi Thử Dùng Tank", "", 6, 0], "190": ["Luyện Phụ Bản", "Luyện PB: Các dũng sĩ, hãy cùng với Tank của mình đánh đuổi lũ tà ác.", 6, 0]}

const LISTS = {"3": [101, 150, 151, 152, 153], "1": [102, 166, 167, 168], "2": [103, 175]}
