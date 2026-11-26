extends RefCounted

const FILE: String = "res://assets/ui/hall/challenge.png"

const R: Dictionary = {
	"kc_add": [300, 1048, 26, 26], 
	"kc_btn_bg": [872, 924, 106, 40], 
	"kc_btnbk": [116, 1048, 90, 28], 
	"kc_btnbk_ss": [208, 1048, 90, 28], 
	"kc_buy": [356, 1048, 25, 25], 
	"kc_card": [643, 542, 156, 316], 
	"kc_challenge": [642, 1006, 100, 33], 
	"kc_close": [383, 1048, 24, 24], 
	"kc_continue": [520, 1006, 120, 35], 
	"kc_dd_bg": [2, 924, 272, 80], 
	"kc_dd_pk": [662, 924, 50, 50], 
	"kc_dd_pk_t": [409, 1048, 64, 19], 
	"kc_dd_sign": [714, 924, 50, 50], 
	"kc_dd_sign_t": [475, 1048, 64, 19], 
	"kc_diamond": [766, 924, 50, 50], 
	"kc_frame": [2, 2, 859, 538], 
	"kc_get": [744, 1006, 100, 33], 
	"kc_gold": [818, 924, 52, 49], 
	"kc_got_bg": [2, 1006, 106, 40], 
	"kc_info": [328, 1048, 26, 26], 
	"kc_lose": [424, 924, 117, 67], 
	"kc_rank_1": [110, 1006, 80, 40], 
	"kc_rank_2": [192, 1006, 80, 40], 
	"kc_rank_3": [274, 1006, 80, 40], 
	"kc_rank_4": [356, 1006, 80, 40], 
	"kc_rank_5": [438, 1006, 80, 40], 
	"kc_result": [2, 542, 639, 380], 
	"kc_reward_box": [276, 924, 76, 76], 
	"kc_tile": [354, 924, 68, 68], 
	"kc_up_helper": [846, 1006, 100, 33], 
	"kc_watch": [2, 1048, 112, 31], 
	"kc_win": [543, 924, 117, 67], 
}

const FRAME = [880, 540]

const BODY = [19, 0]

const AT = {"btnClose": [842, 33, 24, 24], "btnBuyChallenge": [625, 408, 25, 25], "lblVipTip": [605, 440, 70, 0], "imgScoreHelp": [653, 464, 16, 16], "cvsReward": [672, 428, 165, 76], "imgReward": [682, 428, 76, 76], "imgGetReward": [704, 449, 106, 40], "btnGetReward": [707, 453, 100, 33], "frmReward": [529, 255, 200, 242], "btnWatchRank": [321, 388, 112, 31]}

const TEXTS = {"txtHistory": [39, 422, 400, 100, 12, "ffffff", 0, "l"], "lblRank": [671.5, 408, 169, 0, 14, "ffffff", 1, "c"], "lblChanllengeTime": [589, 412, 0, 0, 12, "ffffff", 1, "l"], "_ChallengeFrame_Label3": [563, 440, 0, 0, 13, "ffffff", 1, "r"], "lblCoolTime": [558, 440, 100, 0, 13, "ffffff", 1, "l"], "lblVipTip": [605, 440, 70, 0, 12, "fffc00", 1, "l"], "_ChallengeFrame_Label6": [563, 462, 0, 0, 13, "ffffff", 1, "r"], "lblGeneralScore": [558, 462, 100, 0, 13, "ffffff", 1, "l"], "_ChallengeFrame_Label8": [563, 482, 0, 0, 13, "ffffff", 1, "r"], "lblWinninStreak": [558, 482, 100, 0, 13, "ffffff", 1, "l"], "txtAwardTime": [760, 438, 77, 62, 12, "ffffff", 1, "c"]}

const CARDS = [[41, 67], [201, 67], [361, 67], [521, 67], [681, 67]]

const CARD = [158, 318]

const CARD_BODY = [1, 1]

const CARD_AT = {"imgNormalBg": [0, 0, 158, 318], "cvsBtn": [60, 10, 90, 28], "imgBg": [60, 10, 90, 28], "btnAddFriend": [92, 12, 26, 26], "btnPlayerInfo": [123, 12, 26, 26], "imgHead": [3, 7, 60, 60], "cvsTank": [37, 74, 136, 26], "imgTankLevel": [37, 74, 136, 26], "imgHelper": [29, 107, 100, 100], "avTank": [2, 62, 200, 200], "cvsChallengeBtn": [29, 267, 100, 40], "imgChallengeBtnBg": [26, 267, 106, 40], "btnChallenge": [29, 271, 100, 33], "rank": [79.0, 236.0, 0, 0]}

const CARD_TEXTS = {"lblPlayerName": [64, 47, 90, 0, 12, "ffffff", 1, "l"], "lblTankName": [36, 88, 0, 0, 12, "ffffff", 1, "c"], "lblGeneralScore": [0, 204, 158, 0, 14, "ffffff", 1, "c"], "lblRank": [0, 225, 158, 0, 14, "ffffff", 1, "c"], "lblJudge": [0, 246, 158, 0, 14, "ffffff", 1, "c"]}

const RESULT = [660, 400]

const RESULT_BODY = [19, 18]

const RESULT_AT = {"btnClose": [622, 33, 24, 24], "imgResult": [271.5, -12, 117, 67], "frmCardSelf": [40, 67, 158, 318], "frmCardEnemy": [462, 67, 158, 318], "btnUpHelper": [280, 293, 100, 33], "btnContinue": [270, 350, 120, 35], "cvsAwardItem": [230, 150, 200, 93], "frmReward0": [252, 175, 76, 68], "frmReward1": [332, 175, 76, 68], "frmReward2": [372, 175, 76, 68]}

const RESULT_TEXTS = {"lblNewRank": [200, 87, 260, 0, 20, "ffff00", 1, "c"], "_ChallengeRewardItemFrame_Text1": [330, 153, 0, 0, 12, "ffffff", 1, "c"]}

const TILE = {"tile": [4.0, 0, 68, 68], "item": [12, 10, 52, 49], "num": [-5, 63, 85, 0, 12, "ffffff", 1, "c"]}

const POPUP = {"wide": 200, "icon": [10, 8, 50, 50], "step": 58, "word": [68, 120]}

const DAILY = {"bg": [-112, 50], "first": [-102, 65], "step": 66, "word": [-7, 31], "tip": [30, 0], "num": [25, 2]}

const WORDS = {"rank_of": "Hạng: @num1@", "my_rank": "Hạng: @num1@", "buy_out": "Lượt khiêu chiến đã hết, bỏ ra @num1@xu khóa (hoặc xu) mua 1 lượt không?", "buy_left": "Lượt mua hôm nay: @num1@/@num2@", "buy_cost": "Lượt mua này tốn: @num1@ xu khóa (hoặc xu)", "buy_ask": "Có muốn dùng @num1@ xu (hoặc xu khóa) để mua 1 lượt khiêu chiến?", "rank_up": "Hạng tăng đến @num1@", "rank_same": "Hạng không đổi", "award_time": "T/g nhận", "judge_383": "[Không Thể Đánh Bại]", "judge_384": "[Cực Kỳ Gây Cấn]", "judge_385": "[Dám Thử Không]", "judge_386": "[Thực Lực Ngang Ngửa]", "judge_387": "[Vượt Trên Đối Thủ]", "judge_388": "[Nắm Chắc Phần Thắng]", "judge_389": "[Nghiền Nát Đối Thủ]", "buy_none": "Hết lượt mua hôm nay", "power_of": "C.Lực: @num1@", "vip_ask": "VIP khiêu chiến không bị CD, có lên VIP không?", "buy_limit": "Lượt mua đạt giới hạn", "you_hit": "@time@, bạn đã khiêu chiến @name@", "rank_rise": "Hạng tăng đến @num1@.", "rank_keep": "Hạng không đổi", "hit_you": "@time@, @name@ khiêu chiến bạn", "rank_fall": "Hạng giảm đến @num1@", "you_win": "Bạn thắng", "you_lose": "Bạn thua", "just_now": "Xong", "minutes": "@time@ phút trước", "hours": "@time@ giờ trước", "days": "@time@ ngày trước", "no_cash": "Xu không đủ, hãy nạp tiền", "cool": "CD:", "vip_free": "VIP không CD", "power": "Tổng Chiến Lực:", "streak": "Liên thắng:", "won_list": "Lượt này được phần thưởng sau", "score_help": "Tổng Chiến Lực chịu ảnh hưởng của chiến lực trợ thủ và cấp sao của Tank."}
