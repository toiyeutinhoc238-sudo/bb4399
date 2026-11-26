extends RefCounted

const FILE: String = "res://assets/ui/hall/second_pwd.png"

const R: Dictionary = {
	"spw_cancel_clean": [726, 640, 96, 28], 
	"spw_cb": [54, 838, 22, 23], 
	"spw_cb_on": [78, 838, 22, 23], 
	"spw_change": [824, 640, 96, 28], 
	"spw_clean": [922, 640, 96, 28], 
	"spw_close": [2, 838, 24, 24], 
	"spw_frame_check": [2, 640, 356, 196], 
	"spw_frame_reset": [422, 2, 356, 276], 
	"spw_frame_set": [2, 362, 356, 276], 
	"spw_frame_unlock": [360, 362, 356, 276], 
	"spw_help_close": [28, 838, 24, 24], 
	"spw_help_frame": [2, 2, 418, 358], 
	"spw_help_ok": [360, 640, 120, 35], 
	"spw_ok": [482, 640, 120, 35], 
	"spw_unlock": [604, 640, 120, 35], 
}

const SIZE = {"set": [360, 280], "reset": [360, 280], "unlock": [360, 280], "check": [360, 200], "help": [422, 362]}

const FRAME_AT = {"set": [2, 2], "reset": [2, 2], "unlock": [2, 2], "check": [2, 2], "help": [2, 2]}

const NODES = {"set": {"txtInputPwd": [105.0, 80, 210, 35], "txtConfrimPwd": [105.0, 123, 210, 35], "btnClose": [321, 15, 24, 24], "btnConfirm": [120.0, 228, 120, 35], "imgHelp": [263, 52, 16, 16], "lblHelp": [280, 50, 0, 0], "canvas1": [168]}, "reset": {"txtOldPwd": [105.0, 76, 210, 35], "txtInputPwd": [105.0, 120, 210, 35], "txtConfrimPwd": [105.0, 163, 210, 35], "btnClose": [321, 15, 24, 24], "btnConfirm": [120.0, 228, 120, 35], "imgHelp": [263, 52, 16, 16], "lblHelp": [280, 50, 0, 0]}, "unlock": {"txtInputPwd": [105.0, 80, 210, 35], "btnClose": [321, 15, 24, 24], "btnConfirm": [120.0, 228, 120, 35], "btnChangPwd": [106, 122, 96, 28], "btnCleanPwd": [206, 122, 96, 28], "btnCancelClean": [206, 122, 96, 28], "imgHelp": [263, 52, 16, 16], "lblHelp": [280, 50, 0, 0], "canvas1": [154]}, "check": {"txtInputPwd": [105.0, 80, 210, 35], "btnClose": [321, 15, 24, 24], "btnConfirm": [120.0, 148, 120, 35], "imgHelp": [263, 52, 16, 16], "lblHelp": [280, 50, 0, 0]}}

const INPUT = {"px": 16, "pad": [15, 5], "max": 14}

const CHECK = {"box": [22, 23], "text_x": 25, "text_y": 4, "px": 13, "gutter": 2, "bit": 128, "chk_at": [0.0, 0]}

const HELP_LINK = {"color": "42ff5d", "px": 12}

const HELP = {"desc": [34, 66, 358, 232], "desc_px": 12, "title": [126.0, 20, 170], "title_px": 17, "glow": "737272", "close": [383, 15, 24, 24], "ok": [151.0, 310, 120, 35]}

const WORDS = {"DESZ": "T/g hồi sinh không cần mật mã cấp 2", "HELP": "Giải thích.", "HELP_TEXT": "Nếu bạn và người khác dùng chung nhân vật, hãy tạo mật mã cấp 2.\nSau khi tạo mật mã cấp 2, mỗi thao tác cần tiêu tốn tiền (Xu, Xu Khóa, Bạc) đề sẽ phải nhập mật mã cấp 2. \nSau khi tạo mật mã cấp 2 có thể sửa và xóa mật mã.\nNhấp sửa mật mã, nhập mật mã cũ và mới để sửa.\nNhấp xóa mật mã xong, chờ 3 ngày, mật mã sẽ tự bị xóa đi.\nXin chớ cho người khác biết mật mã của bạn.", "TIP_357": "Mật mã không khớp", "TIP_358": "Không để trống mật mã", "TIP_359": "Sau khi bắt đầu xóa mật mã sẽ bắt đầu đếm ngược, sau 3 ngày mật mã cấp 2 sẽ bị xóa", "TIP_360": "Mật mã cấp 2 : @time@ sau bị xóa, có xóa không", "TIP_361": "Mật mã không được trùng mật mã cũ", "TIP_364": "Mật mã phải trên 6 ký tự", "PWD_TIP1": "Lập mật mã cấp 2 thành công", "PWD_TIP2": "Thao tác thất bại", "PWD_TIP3": "Xác nhận mở bảo hộ mật mã cấp 2", "PWD_TIP6": "Xóa mật mã cấp 2 thành công", "PWD_TIP7": "Xóa mật mã cấp 2 thất bại", "PWD_TIP8": "Kiểm tra thành công", "PWD_TIP9": "Kiểm tra thất bại", "PWD_TIP10": "Hủy xóa thành công", "PWD_TIP11": "Hủy xóa thất bại", "PWD_TIP12": "Bắt đầu đếm ngược xóa mật mã", "PWD_TIP13": "Sửa thành công", "PWD_TIP14": "Sửa thất bại", "PWD_TIP15": "Mở bảo hộ mật mã cấp 2 thành công", "PWD_TIP16": "Mở khóa bảo hộ mật mã cấp 2", "PWD_TIP17": "Chuẩn bị xóa mật mã cấp 2 của bạn, còn @time@ nữa sẽ xóa."}

const TITLES = {"set": ["MẬT MÃ CẤP 2", 180.0, 18, 28], "reset": ["SỬA MẬT MÃ", 180.0, 18, 28], "unlock": ["MỞ KHÓA", 180.0, 18, 28], "check": ["MỞ KHÓA", 180.0, 18, 28]}

const LABELS = {"set": {"txtInputPwd": ["Mật mã", 100.0, 97.5], "txtConfrimPwd": ["Xác nhận", 100.0, 140.5]}, "reset": {"txtOldPwd": ["Mật mã cũ", 100.0, 93.5], "txtInputPwd": ["Mật mã mới", 100.0, 137.5], "txtConfrimPwd": ["Xác nhận", 100.0, 180.5]}, "unlock": {"txtInputPwd": ["Mật mã", 100.0, 97.5]}, "check": {"txtInputPwd": ["Mật mã", 100.0, 97.5]}}
