extends RefCounted

const FILE: String = "res://assets/ui/hall/ladder_rule.png"

const R: Dictionary = {
	"lu_link": [45, 2, 148, 44], 
	"lu_sb_bk": [2, 2, 20, 100], 
	"lu_sb_down": [195, 2, 19, 19], 
	"lu_sb_thumb": [24, 2, 19, 64], 
	"lu_sb_up": [216, 2, 19, 19], 
}

const LADDER = 3

const VIEW = [29, 70, 480, 380]

const DESC_W = 457

const GAP = 6

const LABEL_H = 26

const LINK = [349, 396, 148, 44]

const BAR = 19

const RULES = {"3": ["Quy tắc Đấu XH:", "Thời gian mở: #ENTER#9:00 - 22:00 hàng ngày#ENTER#1. Có 5 tank vĩnh viễn trở lên mới được tham gia Đấu Xếp Hạng, đồng đội không thể chọn trùng tank.#ENTER#2. Nhân vật ≥Lv15 mới được tham gia.", 3300602, 4], "4": ["Giới Thiệu: ", "[Chế độ Nhiệt Huyết]#ENTER#Điều kiện thắng: Đạt 25 lượt hạ gục, hoặc hết trận có số lượt hạ gục cao hơn đối phương.#ENTER#Giới thiệu: Bị hạ được hồi sinh, nhưng càng bị hạ nhiều thì thời gian hồi sinh càng dài.#ENTER#[Chế độ Tử Vong]#ENTER#Điều kiện thắng: Đấu 3 ván thắng 2.#ENTER#Giới thiệu: Mỗi ván chỉ có một mạng, hạ hết người chơi phe đối phương là thắng ván đó.#ENTER#[Chế độ Căn Cứ]#ENTER#Điều kiện thắng: Phá hủy căn cứ đối phương, hoặc hết trận máu căn cứ phe ta cao hơn đối phương.#ENTER#Giới thiệu: Nhặt đạo cụ kinh nghiệm, phá bệ pháo, công trình và hạ người chơi đối phương để nhận kinh nghiệm chiến trường: tăng cấp, giảm hồi Kỹ năng, tăng tấn công và sinh lực.#ENTER#[Chế độ Cứ Điểm]#ENTER#Điều kiện thắng: Phe ta đạt 1000 điểm trước, hoặc hết trận có điểm cao hơn đối phương.#ENTER#Giới thiệu: Chiếm cứ điểm để nhận điểm, chiếm càng nhiều cứ điểm thì nhận điểm càng nhanh.", 0, 0]}

const REWARD = "Xem thưởng:"
