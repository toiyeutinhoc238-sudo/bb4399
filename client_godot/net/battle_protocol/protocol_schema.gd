

extends RefCounted

const CLASSES: Dictionary = {
	"sixcube.protocol.ActivityMessage.ActConvertInfo": {
		"compose": [
			"m_convertId", 
			"m_maxConvertCount", 
			"m_curConvertCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_convertId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_maxConvertCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_curConvertCount", 
				"type": "i32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.ActivityMessage.ActInfo": {
		"compose": [
			"m_nActId", 
			"m_nStartTime", 
			"m_nDurationTime", 
			"m_state"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStartTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDurationTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_state", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.ActivityMessage.ActivityEnterBoss": {
		"compose": [
			"m_iResetCD"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_iResetCD", 
				"type": "i32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ActivityMessage.ActivityNotifyBossData": {
		"compose": [
			"m_nActId", 
			"m_iBossHp", 
			"m_iBossMaxHp", 
			"m_iHarm", 
			"m_nRank", 
			"m_nEnterCD", 
			"m_rankVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActId", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iBossHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iBossMaxHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iHarm", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nEnterCD", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.ActivityMessage.HarmBossInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_rankVec"
			}
		], 
		"min_bytes": 26
	}, 
	"sixcube.protocol.ActivityMessage.ActivityNotifyStateChange": {
		"compose": [
			"m_activity", 
			"m_state", 
			"m_nParam"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_activity", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_state", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nParam", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.ActivityMessage.ActivitySyncBossData": {
		"compose": [
			"m_nActId", 
			"m_iBossHp", 
			"m_iBossMaxHp", 
			"m_rankVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActId", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iBossHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iBossMaxHp", 
				"type": "i32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.ActivityMessage.HarmBossInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_rankVec"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.ActivityMessage.CloseBossActUI": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.ActivityMessage.CloudPurchaseAwardInfo": {
		"compose": [
			"m_awardTime", 
			"m_awardName", 
			"m_buyCnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_awardTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_awardName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_buyCnt", 
				"type": "u32"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.ActivityMessage.HarmBossInfo": {
		"compose": [
			"m_charUuid", 
			"m_strName", 
			"m_iHarm"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iHarm", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.ActivityMessage.NotifyActInfo": {
		"compose": [
			"m_actInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.ActivityMessage.ActInfo", 
				"kind": "struct", 
				"name": "m_actInfo"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.ActivityMessage.NotifyActInfoList": {
		"compose": [
			"m_actList"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ActivityMessage.ActInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_actList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ActivityMessage.NotifyBonFireCompleteQuestInfoMessage": {
		"compose": [
			"m_questUseCnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_questUseCnt", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ActivityMessage.NotifyBonFireUseCountInfoMessage": {
		"compose": [
			"m_prevTotalUseCnt", 
			"m_curAddUseCnt", 
			"m_useParam"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_prevTotalUseCnt", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_curAddUseCnt", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_useParam", 
				"type": "i32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.ActivityMessage.NotifyCloudPurchaseAwardInfoMessage": {
		"compose": [
			"m_awardInfoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ActivityMessage.CloudPurchaseAwardInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_awardInfoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ActivityMessage.NotifyCloudPurchaseBuyInfoMessage": {
		"compose": [
			"m_notifyType", 
			"m_buyCnt", 
			"m_totalCnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_notifyType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_buyCnt", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_totalCnt", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.ActivityMessage.NotifyGlobalTimeAwardInfoMessage": {
		"compose": [
			"m_awardTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_awardTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ActivityMessage.NotifyItemCloudPurchaseTankInfoMessage": {
		"compose": [
			"m_awardTime", 
			"m_tankIdVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_awardTime", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_tankIdVec"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ActivityMessage.NotifyLuckConvertCountMessage": {
		"compose": [
			"m_actType", 
			"m_convertInfoVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_actType", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.ActivityMessage.ActConvertInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_convertInfoVec"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ActivityMessage.NotifyNextOnlinePeakActStartMessage": {
		"compose": [
			"m_onlinePeakPhase", 
			"m_isNextStart"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_onlinePeakPhase", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isNextStart", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.ActivityMessage.NotifyRandStepSupportInfoMessage": {
		"compose": [
			"m_supportUuidVec"
		], 
		"fields": [
			{
				"element": {
					"kind": "scalar", 
					"type": "utf8"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_supportUuidVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ActivityMessage.NotifyStopAct": {
		"compose": [
			"m_nActId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ActivityMessage.OpenBossActUI": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.ActivityMessage.RequestDrawOnlinePeakAwardMessage": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.AuthMessage.CloseSessionConfirm": {
		"compose": [
			"m_reason"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_reason", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.AuthMessage.LoginFail": {
		"compose": [
			"m_reason", 
			"m_uOpenTime", 
			"m_errMsg"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_reason", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_uOpenTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_errMsg", 
				"type": "utf8"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.AuthMessage.LoginOk": {
		"compose": [
			"m_sessionkey", 
			"m_expire_time", 
			"m_has_char", 
			"m_nAcctId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sessionkey", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_expire_time", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_has_char", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAcctId", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.AuthMessage.RegionServerList": {
		"compose": [
			"m_regions"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.LoginProtocol.REGION_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_regions"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.AuthMessage.RequestAuthLogin": {
		"compose": [
			"m_microclient", 
			"m_name", 
			"m_passwd", 
			"m_adult", 
			"m_time", 
			"m_platform", 
			"m_channel", 
			"m_token", 
			"m_passport", 
			"m_clientSid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_microclient", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_name", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_passwd", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_adult", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_time", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_platform", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_channel", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_token", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_passport", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_clientSid", 
				"type": "u32"
			}
		], 
		"min_bytes": 21
	}, 
	"sixcube.protocol.AuthMessage.RequestProtocolVersion": {
		"compose": [
			"m_auth_ver", 
			"m_gate_ver", 
			"m_mixAuth", 
			"m_client_ver"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_auth_ver", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_gate_ver", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mixAuth", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_client_ver", 
				"type": "utf8"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.AuthMessage.RequestServerLogin": {
		"compose": [
			"m_session", 
			"m_nAcctId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_session", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAcctId", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.AuthMessage.RequestSwitchLine": {
		"compose": [
			"m_sessionkey", 
			"m_bVipLevel", 
			"m_clientSid", 
			"m_wallowtime", 
			"m_isPwdCheck"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sessionkey", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bVipLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_clientSid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_wallowtime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isPwdCheck", 
				"type": "i32"
			}
		], 
		"min_bytes": 17
	}, 
	"sixcube.protocol.AuthMessage.SwitchLineResult": {
		"compose": [
			"m_bResult", 
			"m_regions"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bResult", 
				"type": "u8"
			}, 
			{
				"class": "sixcube.protocol.LoginProtocol.REGION_INFO", 
				"kind": "struct", 
				"name": "m_regions"
			}
		], 
		"min_bytes": 21
	}, 
	"sixcube.protocol.AuthMessage.VersionFail": {
		"compose": [
			"m_reason"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_reason", 
				"type": "i32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.AwardMessage.DrawAwardResult": {
		"compose": [
			"m_awardId", 
			"m_isOk", 
			"m_sysTip"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_awardId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isOk", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sysTip", 
				"type": "u32"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.AwardMessage.DrawGiftResult": {
		"compose": [
			"m_bGiftType", 
			"m_bRes", 
			"m_errMsg"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bGiftType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bRes", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_errMsg", 
				"type": "utf8"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.AwardMessage.NotifyRedPacketLog": {
		"compose": [
			"m_logList"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.AwardMessage.RedPktLog", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_logList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.AwardMessage.NotifyRobRedPacketSucc": {
		"compose": [
			"pktLog"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.AwardMessage.RedPktLog", 
				"kind": "struct", 
				"name": "pktLog"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.AwardMessage.NotifySendRedPacketSucc": {
		"compose": [
			"pktLog"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.AwardMessage.RedPktLog", 
				"kind": "struct", 
				"name": "pktLog"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.AwardMessage.RedPktLog": {
		"compose": [
			"strPacketUuid", 
			"opType", 
			"pktOwnerName", 
			"nMoneyType", 
			"nMoney"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "strPacketUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "opType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pktOwnerName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "nMoneyType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nMoney", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.AwardMessage.RequestDrawAward": {
		"compose": [
			"m_awardId", 
			"m_validate"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_awardId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_validate", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.AwardMessage.RequestDrawGift": {
		"compose": [
			"m_bGiftType", 
			"m_nLevel"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bGiftType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLevel", 
				"type": "u32"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.BattleQuestMessage.BattleQuestInfo": {
		"compose": [
			"nQusetId", 
			"nState", 
			"nCheckCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nQusetId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nState", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nCheckCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.BattleQuestMessage.NotifyBattleQuestBulletin": {
		"compose": [
			"nType", 
			"nQusetId", 
			"nCamp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nQusetId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nCamp", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.BattleQuestMessage.NotifyBattleQuestInfo": {
		"compose": [
			"questInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BattleQuestMessage.BattleQuestInfo", 
				"kind": "struct", 
				"name": "questInfo"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.BoosterCompeteMessage.BOOSTERCOMP_BRIEF": {
		"compose": [
			"m_nOid", 
			"m_szUuid", 
			"m_szName", 
			"m_nAvatar", 
			"m_nBtItemId", 
			"m_nBtLevel", 
			"m_nBtUpLevel", 
			"m_nBtRank", 
			"m_nBtUpCost", 
			"m_nBtRankCost", 
			"m_nTankLevel", 
			"m_nTankId", 
			"m_nTankExternal", 
			"m_nSequenceWin", 
			"m_nWin", 
			"m_nLose", 
			"m_nRank", 
			"m_nCharAtk"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAvatar", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBtItemId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBtLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBtUpLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBtRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBtUpCost", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBtRankCost", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankExternal", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSequenceWin", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nWin", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLose", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCharAtk", 
				"type": "u32"
			}
		], 
		"min_bytes": 68
	}, 
	"sixcube.protocol.BoosterCompeteMessage.BOOSTER_BATTLE_INFO": {
		"compose": [
			"m_strEnemy", 
			"m_nBattleResult", 
			"m_nRank", 
			"m_nBattleTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strEnemy", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBattleResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBattleTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.BoosterCompeteMessage.NotifyBoosterBattleResult": {
		"compose": [
			"m_bWin", 
			"m_nSilver", 
			"m_itemVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bWin", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSilver", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleItemInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_itemVec"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.BoosterCompeteMessage.NotifyBoosterCompInfo": {
		"compose": [
			"m_nChallengeCount", 
			"m_nBuyCount", 
			"m_nBuyLimit", 
			"m_nSequenceWin", 
			"m_nWin", 
			"m_nLose", 
			"m_nCoolTime", 
			"m_nRank", 
			"m_nTodaySeqWin", 
			"m_nCharAtk"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nChallengeCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBuyCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBuyLimit", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSequenceWin", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nWin", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLose", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCoolTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTodaySeqWin", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCharAtk", 
				"type": "u32"
			}
		], 
		"min_bytes": 40
	}, 
	"sixcube.protocol.BoosterCompeteMessage.NotifyBoosterEnemyList": {
		"compose": [
			"m_vecEnemy"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BoosterCompeteMessage.BOOSTERCOMP_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecEnemy"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.BoosterCompeteMessage.NotifyBstBattleHistory": {
		"compose": [
			"m_vecBattleInfo"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BoosterCompeteMessage.BOOSTER_BATTLE_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecBattleInfo"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.BoosterCompeteMessage.NotifyBstCompNowAwardInfo": {
		"compose": [
			"m_nGolden", 
			"m_nChipId", 
			"m_nChipCount", 
			"m_nItem1", 
			"m_nCount1", 
			"m_nItem2", 
			"m_nCount2"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGolden", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nChipId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nChipCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItem1", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount1", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItem2", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount2", 
				"type": "u32"
			}
		], 
		"min_bytes": 28
	}, 
	"sixcube.protocol.BoosterCompeteMessage.NotifyBstCompYesterdayAwardInfo": {
		"compose": [
			"m_bHasAward", 
			"m_nYesterdayRank", 
			"m_nGolden", 
			"m_nChipId", 
			"m_nChipCount", 
			"m_nItem1", 
			"m_nCount1", 
			"m_nItem2", 
			"m_nCount2"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bHasAward", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nYesterdayRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGolden", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nChipId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nChipCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItem1", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount1", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItem2", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount2", 
				"type": "u32"
			}
		], 
		"min_bytes": 33
	}, 
	"sixcube.protocol.BuffMessage.NotifyAddBuff": {
		"compose": [
			"m_nObjId", 
			"m_nBuffInfo", 
			"m_nExistTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nObjId", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.BuffInfo", 
				"kind": "struct", 
				"name": "m_nBuffInfo"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nExistTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 21
	}, 
	"sixcube.protocol.BuffMessage.NotifyRemoveBuff": {
		"compose": [
			"m_nObjId", 
			"m_nBuffInstId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nObjId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBuffInstId", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.BuffMessage.UpdateBuffTime": {
		"compose": [
			"m_nBuffInstId", 
			"m_nExistTime", 
			"m_nStackCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nBuffInstId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nExistTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStackCount", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.BulkDataType.BuffInfo": {
		"compose": [
			"m_nBuffTpltId", 
			"m_nBuffInstId", 
			"m_nStackCount", 
			"m_nCasterId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nBuffTpltId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBuffInstId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStackCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCasterId", 
				"type": "u32"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.BulkDataType.CHAPTER_SCENE": {
		"compose": [
			"m_nMapId", 
			"m_nPassDate", 
			"m_nPassTimes", 
			"m_nBeHarm", 
			"m_nDiedTimes", 
			"m_nScores", 
			"m_nStars", 
			"m_nStarsToday", 
			"m_nElapsed", 
			"m_nSettleFlag", 
			"m_nSettleDate", 
			"m_nResetTimes"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPassDate", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPassTimes", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBeHarm", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDiedTimes", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nScores", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStars", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStarsToday", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nElapsed", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSettleFlag", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSettleDate", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nResetTimes", 
				"type": "u16"
			}
		], 
		"min_bytes": 34
	}, 
	"sixcube.protocol.BulkDataType.CHAR_BASIC": {
		"compose": [
			"account_oid", 
			"sexes", 
			"level", 
			"vipTime", 
			"exp", 
			"tankExpDoubleTime", 
			"expDoubleTime", 
			"tokenDoubleTime", 
			"materialDoubleTime", 
			"tokenDoubleUse", 
			"materialDoubleUse", 
			"tankExpDoubleUse", 
			"milLevel", 
			"milExp", 
			"sprayId", 
			"vipPoints", 
			"vipPointsAddToday", 
			"avatarId", 
			"decorateId", 
			"iFizz", 
			"iWeekFizz", 
			"vipTankTryTime", 
			"superVipTime", 
			"actionFlag", 
			"thew", 
			"thew_buy", 
			"create_time", 
			"online_time", 
			"honor_id", 
			"goldenPool", 
			"rlteStageCount", 
			"setting_flag", 
			"cashback_times", 
			"cashback_picked", 
			"prentice_cashback", 
			"graduate_count", 
			"grocery_add", 
			"gm_level", 
			"hasTankSoulRankAward", 
			"nMilitaryStar", 
			"name", 
			"charUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "account_oid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "sexes", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "level", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "vipTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "exp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "tankExpDoubleTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "expDoubleTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "tokenDoubleTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "materialDoubleTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "tokenDoubleUse", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "materialDoubleUse", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "tankExpDoubleUse", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "milLevel", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "milExp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "sprayId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "vipPoints", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "vipPointsAddToday", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "avatarId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "decorateId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "iFizz", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "iWeekFizz", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "vipTankTryTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "superVipTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "actionFlag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "thew", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "thew_buy", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "create_time", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "online_time", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "honor_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "goldenPool", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "rlteStageCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "setting_flag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "cashback_times", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "cashback_picked", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "prentice_cashback", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "graduate_count", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "grocery_add", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "gm_level", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "hasTankSoulRankAward", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "nMilitaryStar", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "name", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "charUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 130
	}, 
	"sixcube.protocol.BulkDataType.CHAR_BRIEF": {
		"compose": [
			"charData", 
			"otherData", 
			"regionUid", 
			"nIp", 
			"bCamp", 
			"buffVec"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.PLAYER_BRIEF", 
				"kind": "struct", 
				"name": "charData"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.OTHER_BRIEF", 
				"kind": "struct", 
				"name": "otherData"
			}, 
			{
				"kind": "scalar", 
				"name": "regionUid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nIp", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "bCamp", 
				"type": "u8"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "buffVec"
			}
		], 
		"min_bytes": 104
	}, 
	"sixcube.protocol.BulkDataType.CHAR_CURRENCY": {
		"compose": [
			"m_iCash", 
			"m_iGolden", 
			"m_iSilver", 
			"m_iHonor", 
			"m_icrystal", 
			"m_iPresentPoint"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_iCash", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iGolden", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iSilver", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iHonor", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_icrystal", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iPresentPoint", 
				"type": "i32"
			}
		], 
		"min_bytes": 24
	}, 
	"sixcube.protocol.BulkDataType.CHAR_TALENT_PAGE": {
		"compose": [
			"charOid", 
			"talentTree"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "charOid", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.TALENT_GRID", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "talentTree"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.BulkDataType.CITY_INFO": {
		"compose": [
			"m_cityId", 
			"m_value", 
			"m_bEvalEasy", 
			"m_bEvalDiff", 
			"m_nDiffPass", 
			"m_nResetTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_cityId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_value", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bEvalEasy", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bEvalDiff", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDiffPass", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nResetTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 18
	}, 
	"sixcube.protocol.BulkDataType.CharCrystalSchemeInfo": {
		"compose": [
			"scheme_id", 
			"pos1_item_id", 
			"pos2_item_id", 
			"pos3_item_id", 
			"pos4_item_id", 
			"pos5_item_id", 
			"pos6_item_id", 
			"pos7_item_id", 
			"pos8_item_id", 
			"pos9_item_id", 
			"pos10_item_id", 
			"pos11_item_id", 
			"pos12_item_id", 
			"pos13_item_id", 
			"pos14_item_id", 
			"pos15_item_id", 
			"pos16_item_id", 
			"pos17_item_id", 
			"pos18_item_id", 
			"pos19_item_id", 
			"pos20_item_id", 
			"pos21_item_id", 
			"pos22_item_id", 
			"pos23_item_id", 
			"pos24_item_id", 
			"pos25_item_id", 
			"pos26_item_id", 
			"pos27_item_id", 
			"pos28_item_id", 
			"pos29_item_id", 
			"pos30_item_id"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "scheme_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos1_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos2_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos3_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos4_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos5_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos6_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos7_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos8_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos9_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos10_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos11_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos12_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos13_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos14_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos15_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos16_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos17_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos18_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos19_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos20_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos21_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos22_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos23_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos24_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos25_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos26_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos27_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos28_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos29_item_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "pos30_item_id", 
				"type": "u32"
			}
		], 
		"min_bytes": 124
	}, 
	"sixcube.protocol.BulkDataType.CharCrystalSchemeName": {
		"compose": [
			"scheme_id", 
			"scheme_name"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "scheme_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "scheme_name", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.BulkDataType.GiveItemStruct": {
		"compose": [
			"nTemplateId", 
			"iCount", 
			"bBind", 
			"iLifeTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nTemplateId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "iCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "bBind", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "iLifeTime", 
				"type": "i32"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.BulkDataType.HonorInfo": {
		"compose": [
			"nHonorId", 
			"nGainTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nHonorId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nGainTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.BulkDataType.ITEM_INSTANCE": {
		"compose": [
			"m_itemUuid", 
			"m_templateId", 
			"m_lifeTime", 
			"m_extFlag", 
			"m_count", 
			"m_level", 
			"m_upLevel", 
			"m_exp", 
			"m_rank", 
			"m_upCost", 
			"m_rankCost", 
			"m_createTime", 
			"m_slotNo"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_itemUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_templateId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_lifeTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_extFlag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_count", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_level", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_upLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_exp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_rank", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_upCost", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_rankCost", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_createTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_slotNo", 
				"type": "i16"
			}
		], 
		"min_bytes": 39
	}, 
	"sixcube.protocol.BulkDataType.InviteGiftPlayerInfo": {
		"compose": [
			"char_uuid", 
			"login_cnt", 
			"login_time", 
			"draw_time", 
			"draw_acc_cnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "char_uuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "login_cnt", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "login_time", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "draw_time", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "draw_acc_cnt", 
				"type": "u32"
			}
		], 
		"min_bytes": 18
	}, 
	"sixcube.protocol.BulkDataType.LimitInfo": {
		"compose": [
			"m_nLimitId", 
			"m_iCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nLimitId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iCount", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.BulkDataType.OTHER_BRIEF": {
		"compose": [
			"tankId", 
			"tankLevel", 
			"tryTank", 
			"btItemId", 
			"btRank", 
			"btLevel", 
			"btUpLevel", 
			"btUpCost", 
			"btRankCost", 
			"honorId", 
			"tankExternal", 
			"haloId", 
			"skinFrameType", 
			"btAtk", 
			"tankPartScore", 
			"commandSkill", 
			"sprayId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "tankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "tankLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "tryTank", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "btItemId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "btRank", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "btLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "btUpLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "btUpCost", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "btRankCost", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "honorId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "tankExternal", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "haloId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "skinFrameType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "btAtk", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "tankPartScore", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "commandSkill", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "sprayId", 
				"type": "u32"
			}
		], 
		"min_bytes": 50
	}, 
	"sixcube.protocol.BulkDataType.ObjInfo": {
		"compose": [
			"m_objId", 
			"m_tplId", 
			"m_x", 
			"m_y", 
			"m_hp", 
			"m_bCamp", 
			"m_maxHp", 
			"m_ownerId", 
			"m_shield", 
			"m_buffVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_tplId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_hp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bCamp", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_maxHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_ownerId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_shield", 
				"type": "i32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.BuffInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_buffVec"
			}
		], 
		"min_bytes": 31
	}, 
	"sixcube.protocol.BulkDataType.OneObjScore": {
		"compose": [
			"m_obj", 
			"m_value"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_obj", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_value", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.BulkDataType.OneSvrAward": {
		"compose": [
			"m_strName", 
			"m_rollId", 
			"m_iCount", 
			"m_nTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_rollId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.BulkDataType.PLAYER_BRIEF": {
		"compose": [
			"nAcctId", 
			"szCharUuid", 
			"szName", 
			"bLevel", 
			"bSex", 
			"nVipLevel", 
			"eloSectionId", 
			"preEloSectionId", 
			"nAvatar", 
			"nDecorateId", 
			"nGraduate", 
			"iElo", 
			"nHonorId", 
			"nBoosterAttack", 
			"nMilitaryStar", 
			"nTeamPlace", 
			"szTeamName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nAcctId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "szCharUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "szName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "bLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "bSex", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "nVipLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "eloSectionId", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "preEloSectionId", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "nAvatar", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nDecorateId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nGraduate", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "iElo", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "nHonorId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nBoosterAttack", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nMilitaryStar", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nTeamPlace", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "szTeamName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 43
	}, 
	"sixcube.protocol.BulkDataType.PVE_Evaluation_Result": {
		"compose": [
			"m_iTotalEval", 
			"m_iHarmEval", 
			"m_iDeadEval", 
			"m_iTimeEval", 
			"m_iBoosterEval"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_iTotalEval", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iHarmEval", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iDeadEval", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iTimeEval", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iBoosterEval", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.BulkDataType.PropsInfo": {
		"compose": [
			"nPropsId", 
			"bSlotno", 
			"iCount", 
			"nEndTime", 
			"nCountCoolTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nPropsId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "bSlotno", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "iCount", 
				"type": "i8"
			}, 
			{
				"kind": "scalar", 
				"name": "nEndTime", 
				"type": "u64_words"
			}, 
			{
				"kind": "scalar", 
				"name": "nCountCoolTime", 
				"type": "u64_words"
			}
		], 
		"min_bytes": 22
	}, 
	"sixcube.protocol.BulkDataType.PvpPairInfo": {
		"compose": [
			"m_type", 
			"m_nAvgTime", 
			"m_nCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAvgTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.BulkDataType.RECORD_BRIEF": {
		"compose": [
			"nActId", 
			"szCharUuid", 
			"szName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nActId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "szCharUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "szName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.BulkDataType.STORE_GOODS": {
		"compose": [
			"m_nGoodId", 
			"m_nItemId", 
			"m_nLeftCount", 
			"m_nPrice", 
			"m_nCoinType", 
			"m_nOriginPrice"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGoodId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItemId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLeftCount", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPrice", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCoinType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nOriginPrice", 
				"type": "u32"
			}
		], 
		"min_bytes": 19
	}, 
	"sixcube.protocol.BulkDataType.SettleAwardInfo": {
		"compose": [
			"m_cash", 
			"m_gift", 
			"m_golden", 
			"m_glory", 
			"m_settleItemVec", 
			"m_tankVec", 
			"m_exp", 
			"m_fizz"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_cash", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_gift", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_golden", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_glory", 
				"type": "i32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleItemVec", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_settleItemVec"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_tankVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_exp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_fizz", 
				"type": "u16"
			}
		], 
		"min_bytes": 26
	}, 
	"sixcube.protocol.BulkDataType.SettleGroup": {
		"compose": [
			"m_type", 
			"m_value"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_value", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.BulkDataType.SettleItemInfo": {
		"compose": [
			"m_itemId", 
			"m_count"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_itemId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_count", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.BulkDataType.SettleItemVec": {
		"compose": [
			"m_nType", 
			"m_itemVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleItemInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_itemVec"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.BulkDataType.TALENT_GRID": {
		"compose": [
			"nTalentId", 
			"nLevel"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nTalentId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nLevel", 
				"type": "u16"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.BulkDataType.TALENT_PAGE": {
		"compose": [
			"strUuid", 
			"strPageName", 
			"talentTree", 
			"nCreateTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "strUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "strPageName", 
				"type": "utf8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.TALENT_GRID", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "talentTree"
			}, 
			{
				"kind": "scalar", 
				"name": "nCreateTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.BulkDataType.TankInstance": {
		"compose": [
			"m_tankUuid", 
			"m_tpltId", 
			"m_level", 
			"m_nExp", 
			"m_extFlag", 
			"m_stthLevel", 
			"m_externalId", 
			"m_warCount", 
			"m_weekWarCount", 
			"m_contType", 
			"m_cashHireCount", 
			"m_coinHireCount", 
			"m_existTime", 
			"m_haloId", 
			"m_skinFrameType", 
			"m_ownTime", 
			"m_stthCount", 
			"m_comSkillId", 
			"m_crystalSchemeId", 
			"m_talPageUuid", 
			"m_proficiencyVal", 
			"m_battleGains"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_tankUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_tpltId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_level", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nExp", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_extFlag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_stthLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_externalId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_warCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_weekWarCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_cashHireCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_coinHireCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_existTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_haloId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_skinFrameType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_ownTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_stthCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_comSkillId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_crystalSchemeId", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_talPageUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_proficiencyVal", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleGains", 
				"type": "i32"
			}
		], 
		"min_bytes": 60
	}, 
	"sixcube.protocol.BulkDataType.TankPartInfo": {
		"compose": [
			"nPartId", 
			"nLv", 
			"nVal"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nPartId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nLv", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nVal", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.BulkDataType.TankSettleInfo": {
		"compose": [
			"m_charOid", 
			"m_tankTpltId", 
			"m_iStatData", 
			"m_iTeamMerit", 
			"m_iOldElo", 
			"m_iNewElo", 
			"m_iTankGains", 
			"m_iNewTankGains", 
			"m_bAward", 
			"m_isWin", 
			"m_iRobotType", 
			"m_eloSectionId", 
			"m_battleLevel", 
			"m_roomCount", 
			"m_camp", 
			"m_expVec", 
			"m_coinVec", 
			"m_tankExpVec", 
			"m_itemVec", 
			"m_evalPve"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_tankTpltId", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "i32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_iStatData"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iTeamMerit", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iOldElo", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iNewElo", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iTankGains", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iNewTankGains", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bAward", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isWin", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iRobotType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_eloSectionId", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_roomCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_camp", 
				"type": "u8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleGroup", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_expVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleGroup", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_coinVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleGroup", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_tankExpVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.GiveItemStruct", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_itemVec"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.PVE_Evaluation_Result", 
				"kind": "struct", 
				"name": "m_evalPve"
			}
		], 
		"min_bytes": 42
	}, 
	"sixcube.protocol.BulkDataType.TankStatInfo": {
		"compose": [
			"m_acctOid", 
			"m_iStatData", 
			"m_battlelevel"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_acctOid", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "i32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_iStatData"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battlelevel", 
				"type": "u8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.BulkDataType.YCARD_INFO": {
		"compose": [
			"nCardId", 
			"nCardLv"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nCardId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nCardLv", 
				"type": "u16"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ChapterMessage.NotifyChapterSceneScores": {
		"compose": [
			"m_scene", 
			"m_best", 
			"m_stat"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.CHAPTER_SCENE", 
				"kind": "struct", 
				"name": "m_scene"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.CHAPTER_SCENE", 
				"kind": "struct", 
				"name": "m_best"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "i32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_stat"
			}
		], 
		"min_bytes": 70
	}, 
	"sixcube.protocol.ChapterMessage.NotifyChapterScenes": {
		"compose": [
			"m_nChapterId", 
			"m_scenes"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nChapterId", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.CHAPTER_SCENE", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_scenes"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ChapterMessage.NotifyCityInfoInit": {
		"compose": [
			"m_infoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.CITY_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_infoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ChapterMessage.NotifySweepSoloAward": {
		"compose": [
			"m_awards"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleAwardInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_awards"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ChapterMessage.RejectSelectScene": {
		"compose": [
			"m_nReason", 
			"m_nInfo"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nReason", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nInfo", 
				"type": "u32"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.ChapterMessage.RequestSelectTankTrialMap": {
		"compose": [
			"m_nMapId", 
			"m_nTankId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.ChapterMessage.RequestSelectTutorMap": {
		"compose": [
			"m_nMapId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ChapterMessage.RequestSoloPveInfoMessage": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.ChapterMessage.RequestSweepSoloMap": {
		"compose": [
			"m_nCityId", 
			"m_nCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCityId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.ChapterMessage.UpdateCityInfo": {
		"compose": [
			"m_infoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.CITY_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_infoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.AcceptFacebookInvite": {
		"compose": [
			"m_strInviteId", 
			"m_strFbUid", 
			"m_strFbName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strInviteId", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strFbUid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strFbName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.CharMessage.CharCreateFail": {
		"compose": [
			"m_reason"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_reason", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.CharPickApprovedMessage": {
		"compose": [
			"m_charUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.CharPickInfo": {
		"compose": [
			"m_basic", 
			"m_charUuid"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.CHAR_BASIC", 
				"kind": "struct", 
				"name": "m_basic"
			}, 
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 132
	}, 
	"sixcube.protocol.CharMessage.ClientDataStat": {
		"compose": [
			"m_type", 
			"m_funcType", 
			"m_param1", 
			"m_param2"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_funcType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_param1", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_param2", 
				"type": "i32"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.CharMessage.ClientOpAct": {
		"compose": [
			"m_nId", 
			"m_nStartTime", 
			"m_nEndTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStartTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nEndTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.CharMessage.GiftInfo": {
		"compose": [
			"bType", 
			"nLevel", 
			"nAwardCount", 
			"nDrawCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "nLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nAwardCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nDrawCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.CharMessage.GuildSkillSlotInfo": {
		"compose": [
			"m_nSkillSlot", 
			"m_nSkillId", 
			"m_nSkillLevel"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSkillSlot", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkillId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkillLevel", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.CharMessage.ImpeachBadPlayer": {
		"compose": [
			"m_type", 
			"m_nActId", 
			"m_uuid", 
			"m_name"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nActId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_uuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_name", 
				"type": "utf8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.CharMessage.NotifyActionFlag": {
		"compose": [
			"m_nActionFlag"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActionFlag", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyAddLevel": {
		"compose": [
			"m_nChar", 
			"m_nLevel", 
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nChar", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.CharMessage.NotifyAdultVerifyResult": {
		"compose": [
			"m_nRet", 
			"m_bAdult"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRet", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bAdult", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.CharMessage.NotifyAfkStatus": {
		"compose": [
			"m_nState"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nState", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyBattleBooster": {
		"compose": [
			"m_boosterUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_boosterUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.NotifyBuddyBrief": {
		"compose": [
			"m_briefVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_briefVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.NotifyCashbackInfo": {
		"compose": [
			"m_cashback_times", 
			"m_cashback_picked"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_cashback_times", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_cashback_picked", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.CharMessage.NotifyChangeSpray": {
		"compose": [
			"m_sprayId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sprayId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyCharData": {
		"compose": [
			"m_charData", 
			"m_currency", 
			"m_queryUrl", 
			"m_technoVec"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.CHAR_BASIC", 
				"kind": "struct", 
				"name": "m_charData"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.CHAR_CURRENCY", 
				"kind": "struct", 
				"name": "m_currency"
			}, 
			{
				"kind": "scalar", 
				"name": "m_queryUrl", 
				"type": "utf8"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "i32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_technoVec"
			}
		], 
		"min_bytes": 158
	}, 
	"sixcube.protocol.CharMessage.NotifyCharExp": {
		"compose": [
			"m_nExp", 
			"m_iAddExp", 
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nExp", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iAddExp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.CharMessage.NotifyCharGift": {
		"compose": [
			"m_giftVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.CharMessage.GiftInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_giftVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.NotifyCharGuildSkillInfo": {
		"compose": [
			"m_skillList", 
			"m_nOpType"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.GuildSkillInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_skillList"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nOpType", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.CharMessage.NotifyCharList": {
		"compose": [
			"m_list"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.CharMessage.CharPickInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_list"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.NotifyCharOption": {
		"compose": [
			"m_strOption"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strOption", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.NotifyCharOptionTime": {
		"compose": [
			"m_nTime", 
			"m_nAddTime", 
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAddTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.CharMessage.NotifyCharProtectInfo": {
		"compose": [
			"m_bHasPwd", 
			"m_nDelPwdTicket"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bHasPwd", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDelPwdTicket", 
				"type": "u32"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.CharMessage.NotifyCharState": {
		"compose": [
			"m_szTargetUuid", 
			"m_nState", 
			"m_nRoomId", 
			"m_nRoomType", 
			"m_nSceneId", 
			"m_nGuildId", 
			"m_nGuildLevel", 
			"m_szGuildName", 
			"m_nTeamId", 
			"m_nTeamLevel", 
			"m_szTeamName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_szTargetUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nState", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRoomType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGuildId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGuildLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szGuildName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szTeamName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 26
	}, 
	"sixcube.protocol.CharMessage.NotifyCreateNewChar": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.CharMessage.NotifyDrawGoldenPoolResult": {
		"compose": [
			"m_nResult", 
			"m_nCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.CharMessage.NotifyDynamicConfig": {
		"compose": [
			"m_hideTankVec", 
			"m_escapeCoin", 
			"m_closedActVec", 
			"m_banActiveGuildSkillVec", 
			"m_banPassiveGuildSkillVec", 
			"m_closeOpAct", 
			"m_diffZoneTime", 
			"m_presentPointRate", 
			"m_cloneBanTankVec"
		], 
		"fields": [
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_hideTankVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_escapeCoin", 
				"type": "i32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_closedActVec"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_banActiveGuildSkillVec"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_banPassiveGuildSkillVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.CharMessage.ClientOpAct", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_closeOpAct"
			}, 
			{
				"kind": "scalar", 
				"name": "m_diffZoneTime", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_presentPointRate", 
				"type": "f32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_cloneBanTankVec"
			}
		], 
		"min_bytes": 24
	}, 
	"sixcube.protocol.CharMessage.NotifyFirstCharge": {
		"compose": [
			"m_nChargeCount", 
			"m_nRate", 
			"m_nMin", 
			"m_nMax"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nChargeCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRate", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMin", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMax", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.CharMessage.NotifyFizz": {
		"compose": [
			"m_iFizz", 
			"m_iWeekFizz"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_iFizz", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iWeekFizz", 
				"type": "i16"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyGuildGiftTime": {
		"compose": [
			"m_nTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyGuildSkillSlotInfo": {
		"compose": [
			"m_skillSlotList", 
			"m_nSlotFlag"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.CharMessage.GuildSkillSlotInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_skillSlotList"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSlotFlag", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.CharMessage.NotifyHeroEnterCount": {
		"compose": [
			"m_bFreeCount", 
			"m_bDayCount", 
			"m_bBuyCount", 
			"m_bDayBuyLimit"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bFreeCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bDayCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bBuyCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bDayBuyLimit", 
				"type": "u8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.CharMessage.NotifyHonor": {
		"compose": [
			"m_honorId", 
			"m_honorId2", 
			"m_honorId3", 
			"m_honorId4"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_honorId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_honorId2", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_honorId3", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_honorId4", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.CharMessage.NotifyHonorList": {
		"compose": [
			"m_honorList", 
			"m_nOpType"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.HonorInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_honorList"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nOpType", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.CharMessage.NotifyImpeachCheck": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.CharMessage.NotifyImpeachResult": {
		"compose": [
			"m_ret"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_ret", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyLimitInfo": {
		"compose": [
			"m_infos"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.LimitInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_infos"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.NotifyNeedCheckProtectPwd": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.CharMessage.NotifyNewSignIn": {
		"compose": [
			"m_nSignInFlag", 
			"m_nSignInCount", 
			"m_nSignInStage"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSignInFlag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSignInCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSignInStage", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.CharMessage.NotifyNotTyro": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.CharMessage.NotifyPrenticeCashbackInfo": {
		"compose": [
			"m_nPrenticeCashback"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nPrenticeCashback", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyProtectPwdOpResult": {
		"compose": [
			"m_nOpType", 
			"m_bResult"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nOpType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bResult", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.CharMessage.NotifyPvePass": {
		"compose": [
			"m_nMapId", 
			"m_nUseTime", 
			"m_nRecordTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nUseTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRecordTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.CharMessage.NotifyPveRecord": {
		"compose": [
			"m_record", 
			"m_nByte"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.CharMessage.OnePveRecord", 
				"kind": "struct", 
				"name": "m_record"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nByte", 
				"type": "u8"
			}
		], 
		"min_bytes": 15
	}, 
	"sixcube.protocol.CharMessage.NotifyRenameResult": {
		"compose": [
			"m_result", 
			"m_uuid", 
			"m_name", 
			"m_sexes"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_result", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_uuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_name", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sexes", 
				"type": "i32"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.CharMessage.NotifyRouletteCount": {
		"compose": [
			"m_nRlteType", 
			"m_nRlteCount", 
			"m_nRlteStageCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRlteType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRlteCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRlteStageCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.CharMessage.NotifyServerLoginConfigMessage": {
		"compose": [
			"m_stateUserCnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_stateUserCnt", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.NotifySetBattleMode": {
		"compose": [
			"m_nBattleMode"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nBattleMode", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyShowQQBlueVipRenew": {
		"compose": [
			"m_nBlueEndTime", 
			"m_nBlueYearEndTime", 
			"m_nSuperBlueEndTime", 
			"m_nExpandBlueEndTime", 
			"m_nSvrTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nBlueEndTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBlueYearEndTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSuperBlueEndTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nExpandBlueEndTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSvrTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 20
	}, 
	"sixcube.protocol.CharMessage.NotifySignIn": {
		"compose": [
			"m_nSignInFlag", 
			"m_nVipDoubleFlag", 
			"m_nYear", 
			"m_nMonth", 
			"m_nDay", 
			"m_nSignInCount", 
			"m_nSignInStage"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSignInFlag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nVipDoubleFlag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nYear", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMonth", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDay", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSignInCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSignInStage", 
				"type": "u32"
			}
		], 
		"min_bytes": 28
	}, 
	"sixcube.protocol.CharMessage.NotifySyncSetting": {
		"compose": [
			"m_setting"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_setting", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.NotifyThew": {
		"compose": [
			"m_thew", 
			"m_thewBuy", 
			"m_thewVip"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_thew", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_thewBuy", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_thewVip", 
				"type": "i32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.CharMessage.NotifyUpdateCharData": {
		"compose": [
			"m_bType", 
			"m_upUint", 
			"m_upStr"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_upUint", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_upStr", 
				"type": "utf8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.CharMessage.NotifyUseAvatar": {
		"compose": [
			"m_avatarId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_avatarId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.OnePveRecord": {
		"compose": [
			"m_mapId", 
			"m_nPassTime", 
			"m_nUseTime", 
			"m_charVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_mapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPassTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nUseTime", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.RECORD_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_charVec"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.CharMessage.RequestBuyThew": {
		"compose": [
			"m_coinVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TradeMessage.GoodsCoinVal", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_coinVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.RequestChangeHonor": {
		"compose": [
			"m_nHonorId", 
			"m_nHonorId2", 
			"m_nHonorId3", 
			"m_nHonorId4"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nHonorId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHonorId2", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHonorId3", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHonorId4", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.CharMessage.RequestChangeName": {
		"compose": [
			"m_newName", 
			"m_sexes"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_newName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sexes", 
				"type": "i32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.CharMessage.RequestChangeSetting": {
		"compose": [
			"m_setting"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_setting", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.RequestCharState": {
		"compose": [
			"m_targetUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_targetUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.RequestDrawGoldenPool": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.CharMessage.RequestFacebookInvite": {
		"compose": [
			"m_strInviteId", 
			"m_strReceiverVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strInviteId", 
				"type": "utf8"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "utf8"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_strReceiverVec"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.RequestGetVipDoubleAward": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.CharMessage.RequestLearnGuildSkill": {
		"compose": [
			"m_nGuildSkillId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGuildSkillId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.RequestProtectPwdOp": {
		"compose": [
			"m_nOpType", 
			"m_strPwd", 
			"m_strPwdChange"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nOpType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strPwd", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strPwdChange", 
				"type": "utf8"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.CharMessage.RequestPveRecord": {
		"compose": [
			"m_nMapId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.RequestRestMapEnterCount": {
		"compose": [
			"m_nMapId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.RequestSetBattleMode": {
		"compose": [
			"m_nBattleMode"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nBattleMode", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.RequestSetCharOption": {
		"compose": [
			"m_strOption"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strOption", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.CharMessage.RequestSetGuildSkill": {
		"compose": [
			"m_skillSlotInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.CharMessage.GuildSkillSlotInfo", 
				"kind": "struct", 
				"name": "m_skillSlotInfo"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.CharMessage.RequestSignIn": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.CharMessage.RequestSignInStageAward": {
		"compose": [
			"m_nStage"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nStage", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.RequestUnlockSkillSlot": {
		"compose": [
			"m_nSkillSlot"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSkillSlot", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.CharMessage.UpdateBattleTechno": {
		"compose": [
			"m_szUuid", 
			"m_technoVec", 
			"m_enemyElo", 
			"m_battleResult", 
			"m_eloUpType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_szUuid", 
				"type": "utf8"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "i32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_technoVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_enemyElo", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleResult", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_eloUpType", 
				"type": "i32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.CharMessage.UpdateBuddyBrief": {
		"compose": [
			"m_data"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
				"kind": "struct", 
				"name": "m_data"
			}
		], 
		"min_bytes": 44
	}, 
	"sixcube.protocol.CharMessage.UpdateGroceryAdd": {
		"compose": [
			"m_nAdd"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nAdd", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ChatMessage.ChatErrorInfo": {
		"compose": [
			"m_errNo", 
			"m_errDesc"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_errNo", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_errDesc", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ChatMessage.ChatMessage": {
		"compose": [
			"m_contents", 
			"m_recvClientTime", 
			"m_recvChatTime"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.ShareTypes.ChatContents", 
				"kind": "struct", 
				"name": "m_contents"
			}, 
			{
				"kind": "scalar", 
				"name": "m_recvClientTime", 
				"type": "i64_words"
			}, 
			{
				"kind": "scalar", 
				"name": "m_recvChatTime", 
				"type": "i64_words"
			}
		], 
		"min_bytes": 47
	}, 
	"sixcube.protocol.ChatMessage.NotifyHaveAnswer": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.ChatMessage.SystemBulletinNotify": {
		"compose": [
			"m_nPos", 
			"m_szColor", 
			"m_szContent", 
			"m_strPlatform", 
			"m_nPlayItemId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nPos", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szColor", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szContent", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strPlatform", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPlayItemId", 
				"type": "u32"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.ChatMessage.SystemTemplateBltNotify": {
		"compose": [
			"m_nBltId", 
			"m_argList", 
			"m_nPlayerItemId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nBltId", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "utf8"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_argList"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPlayerItemId", 
				"type": "u32"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.ClusterMessage.NotifyBackToMain": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.CurrencyMessage.CharCurrencyAction": {
		"compose": [
			"m_flow", 
			"m_reason", 
			"m_currency"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_flow", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_reason", 
				"type": "u16"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.CHAR_CURRENCY", 
				"kind": "struct", 
				"name": "m_currency"
			}
		], 
		"min_bytes": 28
	}, 
	"sixcube.protocol.CurrencyMessage.NotifyChargeDone": {
		"compose": [
			"m_rmbCount", 
			"m_cashCount", 
			"m_giftPack", 
			"m_giftCount", 
			"m_superVipBack", 
			"m_nItemId", 
			"m_nItemCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_rmbCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_cashCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_giftPack", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_giftCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_superVipBack", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItemId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItemCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 28
	}, 
	"sixcube.protocol.CurrencyMessage.RequestPaymentRmb": {
		"compose": [
			"m_orderId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_orderId", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.ApproveAllFriendApply": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.FriendMessage.ApproveFriendApply": {
		"compose": [
			"m_approveUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_approveUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.FriendApplyInfo": {
		"compose": [
			"m_charUuid", 
			"m_name", 
			"m_avatarId", 
			"m_level", 
			"m_vipLevel", 
			"m_sex", 
			"m_eloSectionId", 
			"m_applyOrigin"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_name", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_avatarId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_level", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_vipLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sex", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_eloSectionId", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_applyOrigin", 
				"type": "u8"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.FriendMessage.IgnoreAllFriendApply": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.FriendMessage.IgnoreFriendApply": {
		"compose": [
			"m_ignoreUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_ignoreUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.InviteGiftInviteInfo": {
		"compose": [
			"char_name", 
			"invite_time"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "char_name", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "invite_time", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.FriendMessage.NotifyAddFriend": {
		"compose": [
			"m_vecFriends"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecFriends"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.NotifyAddRelationInfo": {
		"compose": [
			"m_type", 
			"m_info"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}, 
			{
				"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
				"kind": "struct", 
				"name": "m_info"
			}
		], 
		"min_bytes": 48
	}, 
	"sixcube.protocol.FriendMessage.NotifyApplyFriendResult": {
		"compose": [
			"m_result"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_result", 
				"type": "u8"
			}
		], 
		"min_bytes": 1
	}, 
	"sixcube.protocol.FriendMessage.NotifyDeleteRelation": {
		"compose": [
			"m_charUuid", 
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.FriendMessage.NotifyFriendApplyCount": {
		"compose": [
			"m_applyCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_applyCount", 
				"type": "u8"
			}
		], 
		"min_bytes": 1
	}, 
	"sixcube.protocol.FriendMessage.NotifyFriendApplyList": {
		"compose": [
			"m_applyList"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.FriendMessage.FriendApplyInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_applyList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.NotifyInitFriendData": {
		"compose": [
			"m_vecFriend"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecFriend"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.NotifyInitQQFriendData": {
		"compose": [
			"m_vecFriend"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.FriendMessage.QQ_FRIEND_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecFriend"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.NotifyInviteGiftInviteInfoMessage": {
		"compose": [
			"m_infoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.FriendMessage.InviteGiftInviteInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_infoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.NotifyInviteGiftPlayerInfoMessage": {
		"compose": [
			"m_charInfoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.InviteGiftPlayerInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_charInfoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.NotifyInviteGiftPlayerInviteMessage": {
		"compose": [
			"m_strUuid", 
			"m_strName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.FriendMessage.NotifyInviteSpreadBindLevelInfoMessage": {
		"compose": [
			"m_level10Cnt", 
			"m_level15Cnt", 
			"m_level0Cnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_level10Cnt", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_level15Cnt", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_level0Cnt", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.FriendMessage.NotifyInviteSpreadPlayerInfoMessage": {
		"compose": [
			"m_bindAcctId", 
			"m_drawTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bindAcctId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_drawTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.FriendMessage.NotifyRefreshFriendData": {
		"compose": [
			"m_vecData"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecData"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.NotifyRelationInit": {
		"compose": [
			"m_attentionVec", 
			"m_blackVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.FriendMessage.RelationFriendInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_attentionVec"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "utf8"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_blackVec"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.FriendMessage.NotifyRemoveInviteGiftPlayerMessage": {
		"compose": [
			"m_strUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.QQ_FRIEND_BRIEF": {
		"compose": [
			"m_brief", 
			"m_userId"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
				"kind": "struct", 
				"name": "m_brief"
			}, 
			{
				"kind": "scalar", 
				"name": "m_userId", 
				"type": "utf8"
			}
		], 
		"min_bytes": 46
	}, 
	"sixcube.protocol.FriendMessage.RelationFriendInfo": {
		"compose": [
			"m_friendUuid", 
			"m_friendFlag"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_friendUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_friendFlag", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.FriendMessage.RequestAddFriend": {
		"compose": [
			"m_targetName", 
			"m_applyOrigin"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_targetName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_applyOrigin", 
				"type": "u8"
			}
		], 
		"min_bytes": 3
	}, 
	"sixcube.protocol.FriendMessage.RequestAddRelation": {
		"compose": [
			"m_strName", 
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.FriendMessage.RequestDeleteRelation": {
		"compose": [
			"m_charUuid", 
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.FriendMessage.RequestDrawInviteGiftAwardMessage": {
		"compose": [
			"m_strUuid", 
			"m_drawType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_drawType", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.FriendMessage.RequestFriendApplyList": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.FriendMessage.RequestInviteGiftPlayerInviteMessage": {
		"compose": [
			"m_strName", 
			"m_charOid", 
			"m_isCharOid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_charOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isCharOid", 
				"type": "u8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.FriendMessage.RequestRefreshFriendData": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.FriendMessage.RequestRemoveInviteGiftPlayerMessage": {
		"compose": [
			"m_strUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.FriendMessage.ResponseInviteGiftPlayerInviteMessage": {
		"compose": [
			"m_strUuid", 
			"m_responseType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_responseType", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.FundMessage.NotifyFundInfo": {
		"compose": [
			"nType", 
			"nStartTime", 
			"nBits"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nStartTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nBits", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.FundMessage.NotifyMCInfo": {
		"compose": [
			"iWeekCnt", 
			"iMonthCnt", 
			"iBothCnt", 
			"nWeekRemainCnt", 
			"nMonthRemainCnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "iWeekCnt", 
				"type": "i8"
			}, 
			{
				"kind": "scalar", 
				"name": "iMonthCnt", 
				"type": "i8"
			}, 
			{
				"kind": "scalar", 
				"name": "iBothCnt", 
				"type": "i8"
			}, 
			{
				"kind": "scalar", 
				"name": "nWeekRemainCnt", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "nMonthRemainCnt", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.GlobalMessage.NotifyPlayerGuildMatchSelectedTank": {
		"compose": [
			"m_vecSelTank"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.RoomMessage.SelTankCount", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecSelTank"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ItemMessage.ConvertInfo": {
		"compose": [
			"m_nConvertId", 
			"m_nConvertCnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nConvertId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nConvertCnt", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.ItemMessage.ItemSwapOk": {
		"compose": [
			"m_contType", 
			"m_itemA", 
			"m_slotA", 
			"m_itemB", 
			"m_slotB"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_itemA", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_slotA", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_itemB", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_slotB", 
				"type": "i16"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.ItemMessage.NotifyAddSpray": {
		"compose": [
			"m_sprayId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sprayId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.NotifyBonFireUseItemResultMessage": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.ItemMessage.NotifyBoosterResult": {
		"compose": [
			"m_type", 
			"m_isOk", 
			"m_errNo", 
			"m_uuid", 
			"m_oldParam", 
			"m_nowParam"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isOk", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_errNo", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_uuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_oldParam", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nowParam", 
				"type": "i32"
			}
		], 
		"min_bytes": 19
	}, 
	"sixcube.protocol.ItemMessage.NotifyChangeCrystalSchemeNameResultMessage": {
		"compose": [
			"m_result"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_result", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.NotifyClientUseItemFailedMessage": {
		"compose": [
			"m_contType", 
			"m_slotNo"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_slotNo", 
				"type": "i16"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ItemMessage.NotifyCrystalMakeFreeCoolTimeMessage": {
		"compose": [
			"nCoolEndTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nCoolEndTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.NotifyCrystalSchemeInfoMessage": {
		"compose": [
			"m_charSchemeInfoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.CharCrystalSchemeInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_charSchemeInfoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ItemMessage.NotifyCrystalSchemeNameMessage": {
		"compose": [
			"m_charSchemeNameVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.CharCrystalSchemeName", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_charSchemeNameVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ItemMessage.NotifyDeleteItem": {
		"compose": [
			"m_contType", 
			"m_slotVec", 
			"m_itemUuidVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "i16"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_slotVec"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "utf8"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_itemUuidVec"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.ItemMessage.NotifyItemList": {
		"compose": [
			"m_contType", 
			"m_itemVec", 
			"m_notifyType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.ITEM_INSTANCE", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_itemVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_notifyType", 
				"type": "u8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.ItemMessage.NotifyRandStepMessage": {
		"compose": [
			"m_notifyType", 
			"m_passStep"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_notifyType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_passStep", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.ItemMessage.NotifyRouletteAwardList": {
		"compose": [
			"m_nType", 
			"m_list"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.OneSvrAward", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_list"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ItemMessage.NotifySaveCrystalSchemeInfoResultMessage": {
		"compose": [
			"m_result"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_result", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.NotifySettleAward": {
		"compose": [
			"m_opType", 
			"m_info", 
			"m_isShow", 
			"m_nExtInfo"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_opType", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.SettleAwardInfo", 
				"kind": "struct", 
				"name": "m_info"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isShow", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nExtInfo", 
				"type": "u32"
			}
		], 
		"min_bytes": 35
	}, 
	"sixcube.protocol.ItemMessage.NotifySprayList": {
		"compose": [
			"m_sprayList"
		], 
		"fields": [
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_sprayList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.ItemMessage.NotifySvrAwardList": {
		"compose": [
			"m_nType", 
			"m_list"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.OneSvrAward", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_list"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ItemMessage.NotifyUpgradeCrystalResultMessage": {
		"compose": [
			"m_itemId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_itemId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.NotifyUseItem": {
		"compose": [
			"m_nCharUuid", 
			"m_targetUuid", 
			"m_targetName", 
			"m_nItemId", 
			"m_nCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCharUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_targetUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_targetName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItemId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.ItemMessage.RequestChangeCrystalSchemeNameMessage": {
		"compose": [
			"m_charSchemeName"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.CharCrystalSchemeName", 
				"kind": "struct", 
				"name": "m_charSchemeName"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ItemMessage.RequestCleanUpCont": {
		"compose": [
			"m_contType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.RequestContainerItemMessage": {
		"compose": [
			"m_contType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.RequestConvertItem": {
		"compose": [
			"m_convertVec", 
			"m_coinVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ItemMessage.ConvertInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_convertVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TradeMessage.GoodsCoinVal", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_coinVec"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.RequestCrystalMakeMessage": {
		"compose": [
			"nType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nType", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.RequestCrystalSchemeInfoMessage": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.ItemMessage.RequestExpandContainer": {
		"compose": [
			"m_nType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.ItemMessage.RequestReadItem": {
		"compose": [
			"m_contType", 
			"m_slot"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_slot", 
				"type": "i16"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ItemMessage.RequestSaveCrystalSchemeInfoMessage": {
		"compose": [
			"m_charSchemeInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.CharCrystalSchemeInfo", 
				"kind": "struct", 
				"name": "m_charSchemeInfo"
			}
		], 
		"min_bytes": 124
	}, 
	"sixcube.protocol.ItemMessage.RequestSetCurCrystalSchemeIdMessage": {
		"compose": [
			"m_schemeId", 
			"m_tankUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_schemeId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_tankUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.ItemMessage.RequestUseItem": {
		"compose": [
			"m_contType", 
			"m_iSlotNo", 
			"m_targetUuid", 
			"m_iCount", 
			"m_bAuto"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iSlotNo", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_targetUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bAuto", 
				"type": "u8"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.ItemMessage.UpdateItemInstance": {
		"compose": [
			"m_contType", 
			"m_item"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.ITEM_INSTANCE", 
				"kind": "struct", 
				"name": "m_item"
			}
		], 
		"min_bytes": 43
	}, 
	"sixcube.protocol.LeagueMessage.LeagueAwardResult": {
		"compose": [
			"m_result", 
			"m_awardId", 
			"m_belongs"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_result", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_awardId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_belongs", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.LeagueMessage.LeagueEnrollResult": {
		"compose": [
			"m_team_id", 
			"m_session", 
			"m_zone_id", 
			"m_result"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_team_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_session", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_zone_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_result", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.LeagueMessage.LeagueNotifyConfig": {
		"compose": [
			"m_websvc"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_websvc", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.LeagueMessage.LeagueRequestAward": {
		"compose": [
			"m_awardId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_awardId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.LeagueMessage.LeagueRequestEnroll": {
		"compose": [
			"m_team_id", 
			"m_session", 
			"m_zone_id"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_team_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_session", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_zone_id", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.LeagueMessage.LeagueStartPair": {
		"compose": [
			"m_nContest"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nContest", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.LoginProtocol.REGION_INFO": {
		"compose": [
			"region_id", 
			"region_name", 
			"gate_realm", 
			"gate_port", 
			"comm_realm", 
			"comm_port", 
			"cur_load", 
			"is_pvp", 
			"open_time"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "region_id", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "region_name", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "gate_realm", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "gate_port", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "comm_realm", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "comm_port", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "cur_load", 
				"type": "i8"
			}, 
			{
				"kind": "scalar", 
				"name": "is_pvp", 
				"type": "i8"
			}, 
			{
				"kind": "scalar", 
				"name": "open_time", 
				"type": "u32"
			}
		], 
		"min_bytes": 20
	}, 
	"sixcube.protocol.MailMessage.MAIL_BRIEF_INFO": {
		"compose": [
			"m_strUuid", 
			"m_strSendUuid", 
			"m_strSender", 
			"m_strTitle", 
			"m_nArriveTime", 
			"m_nMailType", 
			"m_nMailState", 
			"m_nSendMode", 
			"m_nAffixSign", 
			"m_nCreateTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strSendUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strSender", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strTitle", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nArriveTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMailType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMailState", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSendMode", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAffixSign", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCreateTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 32
	}, 
	"sixcube.protocol.MailMessage.MAIL_INSIDE_INFO": {
		"compose": [
			"m_strUuid", 
			"m_strText", 
			"m_cashNum", 
			"m_itemVec", 
			"m_tankInst"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strText", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_cashNum", 
				"type": "i32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.ITEM_INSTANCE", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_itemVec"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.TankInstance", 
				"kind": "struct", 
				"name": "m_tankInst"
			}
		], 
		"min_bytes": 70
	}, 
	"sixcube.protocol.MailMessage.NotifyMailInsideInfo": {
		"compose": [
			"m_info"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.MailMessage.MAIL_INSIDE_INFO", 
				"kind": "struct", 
				"name": "m_info"
			}
		], 
		"min_bytes": 70
	}, 
	"sixcube.protocol.MailMessage.NotifyMailList": {
		"compose": [
			"m_briefList"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.MailMessage.MAIL_BRIEF_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_briefList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.MailMessage.NotifyMailOperateResult": {
		"compose": [
			"m_result", 
			"m_opType", 
			"m_strMailUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_result", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_opType", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strMailUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.MailMessage.NotifyNoReadMailCount": {
		"compose": [
			"m_count"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_count", 
				"type": "i32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.MailMessage.RequestMailOperate": {
		"compose": [
			"m_strUuid", 
			"m_opType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_opType", 
				"type": "i32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.MailMessage.UpdateMailBriefInfo": {
		"compose": [
			"m_briefInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.MailMessage.MAIL_BRIEF_INFO", 
				"kind": "struct", 
				"name": "m_briefInfo"
			}
		], 
		"min_bytes": 32
	}, 
	"sixcube.protocol.MasterPrenticeMessage.MASTER_PRENTICE_BRIEF": {
		"compose": [
			"m_nIdentity", 
			"m_brief", 
			"m_nAmity", 
			"m_nCharge"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nIdentity", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
				"kind": "struct", 
				"name": "m_brief"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAmity", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCharge", 
				"type": "u32"
			}
		], 
		"min_bytes": 56
	}, 
	"sixcube.protocol.MasterPrenticeMessage.MASTER_PRENTICE_QUEST_INFO": {
		"compose": [
			"m_nQuestId", 
			"m_nState", 
			"m_nCheckCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nQuestId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nState", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCheckCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.MasterPrenticeMessage.NotifyMPApplyList": {
		"compose": [
			"m_applyList"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_applyList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.MasterPrenticeMessage.NotifyMPQuestInfo": {
		"compose": [
			"m_strUuid", 
			"m_nQuestInfo"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}, 
			{
				"class": "sixcube.protocol.MasterPrenticeMessage.MASTER_PRENTICE_QUEST_INFO", 
				"kind": "struct", 
				"name": "m_nQuestInfo"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.MasterPrenticeMessage.NotifyMPQuestList": {
		"compose": [
			"m_strUuid", 
			"m_vecQuest"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strUuid", 
				"type": "utf8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.MasterPrenticeMessage.MASTER_PRENTICE_QUEST_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecQuest"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.MasterPrenticeMessage.NotifyMPRelationCreated": {
		"compose": [
			"m_mpBrief"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.MasterPrenticeMessage.MASTER_PRENTICE_BRIEF", 
				"kind": "struct", 
				"name": "m_mpBrief"
			}
		], 
		"min_bytes": 56
	}, 
	"sixcube.protocol.MasterPrenticeMessage.NotifyMasterPrenticeInfo": {
		"compose": [
			"m_vecMPBrief"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.MasterPrenticeMessage.MASTER_PRENTICE_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecMPBrief"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.MasterPrenticeMessage.NotifyReceiveMPApply": {
		"compose": [
			"m_Buddy", 
			"m_nApplyType"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
				"kind": "struct", 
				"name": "m_Buddy"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nApplyType", 
				"type": "u32"
			}
		], 
		"min_bytes": 48
	}, 
	"sixcube.protocol.MasterPrenticeMessage.NotifyRemoveSocialRelation": {
		"compose": [
			"m_nType", 
			"m_tgtUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_tgtUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.MasterPrenticeMessage.NotifyUpdateMasterPrenticeInfo": {
		"compose": [
			"m_mpBrief"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.MasterPrenticeMessage.MASTER_PRENTICE_BRIEF", 
				"kind": "struct", 
				"name": "m_mpBrief"
			}
		], 
		"min_bytes": 56
	}, 
	"sixcube.protocol.MasterPrenticeMessage.RequestDeleteSocialRelation": {
		"compose": [
			"m_nType", 
			"m_tgtUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_tgtUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.MovementMessage.NotifyStopMove": {
		"compose": [
			"m_sceneId", 
			"m_oid", 
			"m_x", 
			"m_y"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_oid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.MovementMessage.NotifyTownPortal": {
		"compose": [
			"m_sceneId", 
			"m_oid", 
			"m_x", 
			"m_y"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_oid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.MovementMessage.RequestMoveForward": {
		"compose": [
			"m_start_x", 
			"m_start_y", 
			"m_direction", 
			"m_sceneId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_start_x", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_start_y", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_direction", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.NpcMessage.NotifyBarbetteTarget": {
		"compose": [
			"m_nBarbetteId", 
			"m_nTargetId", 
			"m_isSetTarget"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nBarbetteId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTargetId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isSetTarget", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.NpcMessage.NotifySceneTalk": {
		"compose": [
			"m_nSceneId", 
			"m_nTalkId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTalkId", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.NpcMessage.UpdateAINpcMaxHp": {
		"compose": [
			"m_nSceneId", 
			"m_nObjId", 
			"m_nMaxHp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nObjId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMaxHp", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.QuestMessage.AcemInfo": {
		"compose": [
			"m_nId", 
			"m_nOpenTime", 
			"m_nState", 
			"m_nCheckCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nOpenTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nState", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCheckCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.QuestMessage.NotifyAcemInfo": {
		"compose": [
			"m_acemInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.QuestMessage.AcemInfo", 
				"kind": "struct", 
				"name": "m_acemInfo"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.QuestMessage.NotifyAcemList": {
		"compose": [
			"m_acemVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.QuestMessage.AcemInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_acemVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.QuestMessage.NotifyCompleteQuest": {
		"compose": [
			"m_questId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_questId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.QuestMessage.NotifyCompleteQuestFail": {
		"compose": [
			"m_questId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_questId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.QuestMessage.NotifyDeleteQuest": {
		"compose": [
			"m_questIdVec"
		], 
		"fields": [
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_questIdVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.QuestMessage.NotifyQuestInfo": {
		"compose": [
			"m_questInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.QuestMessage.QuestInfo", 
				"kind": "struct", 
				"name": "m_questInfo"
			}
		], 
		"min_bytes": 28
	}, 
	"sixcube.protocol.QuestMessage.NotifyQuestList": {
		"compose": [
			"m_questVec", 
			"m_type"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.QuestMessage.QuestInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_questVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.QuestMessage.QuestInfo": {
		"compose": [
			"m_nId", 
			"m_nState", 
			"m_nCheckCount", 
			"m_nAcceptTime", 
			"m_nBeginTime", 
			"m_nEndTime", 
			"m_nChangeTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nState", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCheckCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAcceptTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBeginTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nEndTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nChangeTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 28
	}, 
	"sixcube.protocol.QuestMessage.RequestCompleteQuest": {
		"compose": [
			"m_nQuestId", 
			"m_nChoItemId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nQuestId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nChoItemId", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.QuestMessage.RequestGetItemQuest": {
		"compose": [
			"m_nItemId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nItemId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.QuestMessage.RequestLikeUs": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.QuestMessage.RequestOpenUI": {
		"compose": [
			"m_nUIType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nUIType", 
				"type": "u8"
			}
		], 
		"min_bytes": 1
	}, 
	"sixcube.protocol.QuestMessage.RequestSetDesktop": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.RoomMessage.AddPlayerList": {
		"compose": [
			"m_playerInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.PLAYER_BRIEF", 
				"kind": "struct", 
				"name": "m_playerInfo"
			}
		], 
		"min_bytes": 43
	}, 
	"sixcube.protocol.RoomMessage.ClearKickoutCountdown": {
		"compose": [
			"m_charId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.DelPlayerList": {
		"compose": [
			"m_acctId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_acctId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.EnterRoomOk": {
		"compose": [
			"m_nRoomId", 
			"m_nCreateId", 
			"m_nMax", 
			"m_nMin", 
			"m_nObNum", 
			"m_nPassword", 
			"m_szName", 
			"m_state", 
			"m_bType", 
			"m_mode", 
			"roomConfig", 
			"charVec", 
			"observerVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCreateId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMax", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMin", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nObNum", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPassword", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_state", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mode", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.RoomMessage.ROOM_CONFIG", 
				"kind": "struct", 
				"name": "roomConfig"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.RoomMessage.ROOM_CHAR_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "charVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.RoomMessage.ROOM_CHAR_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "observerVec"
			}
		], 
		"min_bytes": 35
	}, 
	"sixcube.protocol.RoomMessage.NotifyCharTankRank": {
		"compose": [
			"m_nOid", 
			"m_nRank"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.RoomMessage.NotifyEixtBatEndCount": {
		"compose": [
			"m_iCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_iCount", 
				"type": "i32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.NotifyHallDisplayList": {
		"compose": [
			"m_roomList", 
			"m_sceneList", 
			"m_iSite", 
			"m_bType"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.RoomMessage.RoomInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_roomList"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.RoomMessage.SceneInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_sceneList"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iSite", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.RoomMessage.NotifyKickoutCountdown": {
		"compose": [
			"m_charId", 
			"m_nCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.RoomMessage.NotifyLoadedRate": {
		"compose": [
			"m_nTankId", 
			"m_nDelay", 
			"m_nLoaded"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDelay", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLoaded", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.RoomMessage.NotifyMidwayJoin": {
		"compose": [
			"m_charBrief"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.CHAR_BRIEF", 
				"kind": "struct", 
				"name": "m_charBrief"
			}
		], 
		"min_bytes": 104
	}, 
	"sixcube.protocol.RoomMessage.NotifyNeedRoomPassword": {
		"compose": [
			"m_nRoomId", 
			"m_nRoomType", 
			"m_bMode"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRoomType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bMode", 
				"type": "u8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.RoomMessage.NotifyPairSceneStart": {
		"compose": [
			"m_nSceneId", 
			"m_nMapId", 
			"m_type", 
			"m_charData", 
			"m_lockCharIdVec", 
			"m_nTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.CHAR_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_charData"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_lockCharIdVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 17
	}, 
	"sixcube.protocol.RoomMessage.NotifyPlayerList": {
		"compose": [
			"m_listType", 
			"m_pageNumber", 
			"m_playerList"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_listType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_pageNumber", 
				"type": "u8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.PLAYER_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_playerList"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.NotifyRoomAdd": {
		"compose": [
			"m_charData", 
			"isObserver"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.CHAR_BRIEF", 
				"kind": "struct", 
				"name": "m_charData"
			}, 
			{
				"kind": "scalar", 
				"name": "isObserver", 
				"type": "u8"
			}
		], 
		"min_bytes": 105
	}, 
	"sixcube.protocol.RoomMessage.NotifyRoomBuff": {
		"compose": [
			"m_nCharId", 
			"m_nBuffVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCharId", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_nBuffVec"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.RoomMessage.NotifyRoomCharChange": {
		"compose": [
			"m_charData", 
			"m_otherData"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.PLAYER_BRIEF", 
				"kind": "struct", 
				"name": "m_charData"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.OTHER_BRIEF", 
				"kind": "struct", 
				"name": "m_otherData"
			}
		], 
		"min_bytes": 93
	}, 
	"sixcube.protocol.RoomMessage.NotifyRoomInvite": {
		"compose": [
			"m_start", 
			"m_nRoomId", 
			"m_bType", 
			"m_nPassword", 
			"m_nStartId", 
			"m_nMapId", 
			"m_nBattleMode"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_start", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPassword", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStartId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBattleMode", 
				"type": "u32"
			}
		], 
		"min_bytes": 23
	}, 
	"sixcube.protocol.RoomMessage.NotifyRoomMap": {
		"compose": [
			"m_nMapId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.NotifyRoomOp": {
		"compose": [
			"m_roomOp", 
			"m_nStartOid", 
			"m_nTarget"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_roomOp", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStartOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTarget", 
				"type": "u32"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.RoomMessage.NotifyRoomTankAvailableLevel": {
		"compose": [
			"m_nTankLevel"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankLevel", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.NotifySceneChangeCamp": {
		"compose": [
			"m_nSceneId", 
			"m_campId", 
			"m_nTime", 
			"m_iLockNum"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_campId", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iLockNum", 
				"type": "u32"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.RoomMessage.NotifySceneFreelyUseSameTank": {
		"compose": [
			"m_bUseSameTank"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bUseSameTank", 
				"type": "u8"
			}
		], 
		"min_bytes": 1
	}, 
	"sixcube.protocol.RoomMessage.NotifyStartGame": {
		"compose": [
			"m_nSceneId", 
			"m_nMapId", 
			"m_type", 
			"m_charData", 
			"m_backData", 
			"m_bEnterType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.CHAR_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_charData"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_backData"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bEnterType", 
				"type": "u8"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.RoomMessage.NotifyStartMatch": {
		"compose": [
			"m_nPairTime", 
			"m_pairInfo"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nPairTime", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.PvpPairInfo", 
				"kind": "struct", 
				"name": "m_pairInfo"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.RoomMessage.NotifyStopMatch": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.RoomMessage.NotifyTeamPveMapId": {
		"compose": [
			"nMapId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nMapId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.NotifyTeamRoomInOtherLine": {
		"compose": [
			"m_nClusterId", 
			"m_nRoomType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nClusterId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRoomType", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.RoomMessage.ROOM_CHAR_BRIEF": {
		"compose": [
			"bReady", 
			"bBattle", 
			"charBrief"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "bReady", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "bBattle", 
				"type": "u8"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.CHAR_BRIEF", 
				"kind": "struct", 
				"name": "charBrief"
			}
		], 
		"min_bytes": 106
	}, 
	"sixcube.protocol.RoomMessage.ROOM_CONFIG": {
		"compose": [
			"m_nMapId", 
			"m_bBanRobot", 
			"m_nTankAvailableLevel", 
			"m_iLadderScetionMin", 
			"m_iLadderScetionMax"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bBanRobot", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankAvailableLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iLadderScetionMin", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iLadderScetionMax", 
				"type": "u8"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.RoomMessage.RejectRoomInvite": {
		"compose": [
			"m_nStartId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nStartId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.RequestCreateRoom": {
		"compose": [
			"m_bType", 
			"m_bMode", 
			"m_mapId", 
			"m_passWord", 
			"m_szName", 
			"m_nItemId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bMode", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_passWord", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItemId", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.RoomMessage.RequestExitBattleEnd": {
		"compose": [
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}
		], 
		"min_bytes": 1
	}, 
	"sixcube.protocol.RoomMessage.RequestInHall": {
		"compose": [
			"m_bType", 
			"m_iSite"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iSite", 
				"type": "i32"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.RoomMessage.RequestJoinRoom": {
		"compose": [
			"m_nRoomId", 
			"m_bType", 
			"m_bMode", 
			"m_mapId", 
			"m_nPassword", 
			"m_nContestId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bMode", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPassword", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nContestId", 
				"type": "u32"
			}
		], 
		"min_bytes": 18
	}, 
	"sixcube.protocol.RoomMessage.RequestLookPlayer": {
		"compose": [
			"m_strTargetUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strTargetUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.RoomMessage.RequestLookRoom": {
		"compose": [
			"m_nRoomId", 
			"m_bType", 
			"m_nContestId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nContestId", 
				"type": "u32"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.RoomMessage.RequestLookScene": {
		"compose": [
			"m_nSceneId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.RequestOutHall": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.RoomMessage.RequestPlayerList": {
		"compose": [
			"m_listType", 
			"m_iSite"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_listType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iSite", 
				"type": "i32"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.RoomMessage.RequestRoomInvite": {
		"compose": [
			"m_target"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_target", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.RoomMessage.RequestRoomOp": {
		"compose": [
			"m_roomOp", 
			"m_nTarget"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_roomOp", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTarget", 
				"type": "u32"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.RoomMessage.RequestSetMap": {
		"compose": [
			"m_nMapId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.RoomMessage.RequestStartMatch": {
		"compose": [
			"m_bType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}
		], 
		"min_bytes": 1
	}, 
	"sixcube.protocol.RoomMessage.RequestStopMatch": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.RoomMessage.RoomInfo": {
		"compose": [
			"m_nRoomId", 
			"m_nNum", 
			"m_nMax", 
			"m_mapId", 
			"m_mode", 
			"m_state", 
			"m_isValidate", 
			"m_type", 
			"m_szName", 
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nNum", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMax", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mode", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_state", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isValidate", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 29
	}, 
	"sixcube.protocol.RoomMessage.SceneInfo": {
		"compose": [
			"m_nSceneId", 
			"m_nNum", 
			"m_nAllNum", 
			"m_mapId", 
			"m_inBattle", 
			"m_roomType", 
			"m_isLookerMax", 
			"m_startTime", 
			"m_szName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nNum", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAllNum", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_inBattle", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_roomType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isLookerMax", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_startTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 25
	}, 
	"sixcube.protocol.RoomMessage.SelTankCount": {
		"compose": [
			"m_nTankId", 
			"m_nCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.RoomMessage.SyncLoadAndDelay": {
		"compose": [
			"m_nSceneId", 
			"m_nTankId", 
			"m_nDelay", 
			"m_nLoaded"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDelay", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLoaded", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.RoomMessage.SyncPvpPairInfo": {
		"compose": [
			"m_infoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.PvpPairInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_infoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.RoomMessage.UpdatePlayerList": {
		"compose": [
			"m_acctId", 
			"m_elo", 
			"m_vipLevel"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_acctId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_elo", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_vipLevel", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.SceneMessage.AINpcDead": {
		"compose": [
			"m_AINpcId", 
			"m_x", 
			"m_y"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_AINpcId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.BattleTankProficiencyInfo": {
		"compose": [
			"m_charId", 
			"m_proficiencyVal"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_proficiencyVal", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.HpChangeInfo": {
		"compose": [
			"m_objId", 
			"m_objHp", 
			"m_nFury", 
			"m_casterId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_objHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nFury", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_casterId", 
				"type": "u32"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.SceneMessage.KillInfo": {
		"compose": [
			"m_killerObjId", 
			"m_deadObjId", 
			"m_skillId", 
			"m_dead_x", 
			"m_dead_y", 
			"m_contKillCount", 
			"m_killerKillCount", 
			"m_deadKillCount", 
			"m_isFirstBlood", 
			"m_assistTankId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_killerObjId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_deadObjId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_skillId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_dead_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_dead_y", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_contKillCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_killerKillCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_deadKillCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isFirstBlood", 
				"type": "u8"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_assistTankId"
			}
		], 
		"min_bytes": 22
	}, 
	"sixcube.protocol.SceneMessage.MoveInfo": {
		"compose": [
			"m_objId", 
			"m_x", 
			"m_y", 
			"m_speed", 
			"m_direction", 
			"m_moveType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_speed", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_direction", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_moveType", 
				"type": "u8"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.SceneMessage.NotifyAINpcWave": {
		"compose": [
			"m_iWave", 
			"m_iWaveMax"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_iWave", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iWaveMax", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.NotifyAddObject": {
		"compose": [
			"m_nSceneId", 
			"m_objVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.ObjInfo", 
				"kind": "struct", 
				"name": "m_objVec"
			}
		], 
		"min_bytes": 35
	}, 
	"sixcube.protocol.SceneMessage.NotifyAirDropProp": {
		"compose": [
			"m_nSceneId", 
			"m_propId", 
			"m_x", 
			"m_y", 
			"m_bCamp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_propId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bCamp", 
				"type": "u8"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.SceneMessage.NotifyBattleEnd": {
		"compose": [
			"m_nSceneId", 
			"m_nMapId", 
			"m_battleTime", 
			"m_roomType", 
			"m_winCamp", 
			"m_winType", 
			"m_rebLifeCount", 
			"m_buleLifeCount", 
			"m_tankVec", 
			"m_escapeVec", 
			"m_svrExpRate", 
			"m_tokengoldRate", 
			"m_bpvpActOpen", 
			"m_nItemDropRate", 
			"m_nKiller", 
			"m_nAssister", 
			"m_nKDA", 
			"m_nDestroyer", 
			"m_nVictoryMvp", 
			"m_nDefeatMvp", 
			"m_sceneUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_roomType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_winCamp", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_winType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_rebLifeCount", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_buleLifeCount", 
				"type": "i16"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.TankSettleInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_tankVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.TankSettleInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_escapeVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_svrExpRate", 
				"type": "f32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_tokengoldRate", 
				"type": "f32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bpvpActOpen", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nItemDropRate", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nKiller", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAssister", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nKDA", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDestroyer", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nVictoryMvp", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDefeatMvp", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sceneUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 62
	}, 
	"sixcube.protocol.SceneMessage.NotifyBattleEnter": {
		"compose": [
			"m_nStartTime", 
			"m_bOverTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nStartTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bOverTime", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.SceneMessage.NotifyBattleTankProficiencyValMessage": {
		"compose": [
			"infoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.BattleTankProficiencyInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "infoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.SceneMessage.NotifyCampAddWinRoundMessage": {
		"compose": [
			"m_winCamp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_winCamp", 
				"type": "i32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.SceneMessage.NotifyCampKillNum": {
		"compose": [
			"m_nRedKill", 
			"m_nBlueKill"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRedKill", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBlueKill", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.NotifyCampOccupyAddScore": {
		"compose": [
			"m_occupyIndex", 
			"m_occupyCamp", 
			"m_occupyScore"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_occupyIndex", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_occupyCamp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_occupyScore", 
				"type": "i32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.SceneMessage.NotifyCampOccupyScore": {
		"compose": [
			"m_nRedOccupyScore", 
			"m_nBlueOccupyScore"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRedOccupyScore", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBlueOccupyScore", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.NotifyCampWinRoundMessage": {
		"compose": [
			"m_nRedWinRound", 
			"m_nBlueWinRound"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRedWinRound", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBlueWinRound", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.NotifyCommandSkillSelected": {
		"compose": [
			"m_nCharOid", 
			"m_nCommandSkill"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCharOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCommandSkill", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.NotifyDeadModeAliveCntMessage": {
		"compose": [
			"m_nRedAliveCnt", 
			"m_nBlueAliveCnt"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRedAliveCnt", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBlueAliveCnt", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.NotifyEnterPairConfirmStateMessage": {
		"compose": [
			"m_stateTime", 
			"m_totalCount", 
			"m_confirmCount", 
			"m_robotCount", 
			"m_sceneId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_stateTime", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_totalCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_confirmCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_robotCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}
		], 
		"min_bytes": 20
	}, 
	"sixcube.protocol.SceneMessage.NotifyExitBattle": {
		"compose": [
			"m_nErrId", 
			"m_nSceneId", 
			"m_nCharId", 
			"m_exitType", 
			"m_isLook"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nErrId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCharId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_exitType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isLook", 
				"type": "u32"
			}
		], 
		"min_bytes": 20
	}, 
	"sixcube.protocol.SceneMessage.NotifyFire": {
		"compose": [
			"m_bullteId", 
			"m_objId", 
			"m_startX", 
			"m_startY", 
			"m_destX", 
			"m_destY", 
			"m_iSpeed", 
			"m_nTemplate"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bullteId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_startX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_startY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iSpeed", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTemplate", 
				"type": "u32"
			}
		], 
		"min_bytes": 22
	}, 
	"sixcube.protocol.SceneMessage.NotifyKillInfo": {
		"compose": [
			"m_killInfo"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.SceneMessage.KillInfo", 
				"kind": "struct", 
				"name": "m_killInfo"
			}
		], 
		"min_bytes": 22
	}, 
	"sixcube.protocol.SceneMessage.NotifyNewRoundStartMessage": {
		"compose": [
			"m_startTime", 
			"m_roundIndex", 
			"m_sceneId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_startTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_roundIndex", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.SceneMessage.NotifyObjThrow": {
		"compose": [
			"m_nObj", 
			"m_iStartX", 
			"m_iStartY", 
			"m_iDestX", 
			"m_iDestY", 
			"m_nTime", 
			"m_bType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nObj", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iStartX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iStartY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iDestX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iDestY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}
		], 
		"min_bytes": 17
	}, 
	"sixcube.protocol.SceneMessage.NotifyOverTimeStart": {
		"compose": [
			"m_overTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_overTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.SceneMessage.NotifyPairConfirmMessage": {
		"compose": [
			"m_confirmCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_confirmCount", 
				"type": "i32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.SceneMessage.NotifySceneObject": {
		"compose": [
			"m_objVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.ObjInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_objVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.SceneMessage.NotifySceneStat": {
		"compose": [
			"m_statVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.TankStatInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_statVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.SceneMessage.NotifySelfTankDetailAttr": {
		"compose": [
			"m_curHp", 
			"m_curMp", 
			"m_maxHp", 
			"m_maxMp", 
			"m_physicAtk", 
			"m_magicAtk", 
			"m_physicArmor", 
			"m_magicArmor", 
			"m_physicPenetration", 
			"m_magicPenetration", 
			"m_fireRate", 
			"m_fireRange", 
			"m_speed", 
			"m_commonCritRate", 
			"m_skillCdRate", 
			"m_hpRecover", 
			"m_mpRecover"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_curHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_curMp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_maxHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_maxMp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_physicAtk", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_magicAtk", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_physicArmor", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_magicArmor", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_physicPenetration", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_magicPenetration", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_fireRate", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_fireRange", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_speed", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_commonCritRate", 
				"type": "f32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_skillCdRate", 
				"type": "f32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_hpRecover", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mpRecover", 
				"type": "i32"
			}
		], 
		"min_bytes": 68
	}, 
	"sixcube.protocol.SceneMessage.NotifyShowSurrenderVotation": {
		"compose": [
			"m_validCount", 
			"m_nShowEndTime", 
			"m_nNextTime", 
			"m_nSponsor"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_validCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nShowEndTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nNextTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSponsor", 
				"type": "u32"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.SceneMessage.NotifySurrenderVotationCoolTime": {
		"compose": [
			"m_nTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.SceneMessage.NotifyTankLocked": {
		"compose": [
			"m_nCharOid", 
			"m_nTankId", 
			"m_nTankCont"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCharOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankCont", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.SceneMessage.NotifyTankSelected": {
		"compose": [
			"m_nCharOid", 
			"m_nTankId", 
			"m_nTankCont", 
			"m_nTankExt", 
			"m_nSkinFrameType", 
			"m_nCommandSkill"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCharOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankCont", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankExt", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkinFrameType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCommandSkill", 
				"type": "u32"
			}
		], 
		"min_bytes": 24
	}, 
	"sixcube.protocol.SceneMessage.ObjectHp": {
		"compose": [
			"m_objId", 
			"m_objHp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_objHp", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.ObjectMp": {
		"compose": [
			"m_objId", 
			"m_objMp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_objMp", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.ObjectShield": {
		"compose": [
			"m_objId", 
			"m_shield"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_shield", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.OccupyInfo": {
		"compose": [
			"iIndex", 
			"iCampId", 
			"iLock", 
			"iOccupy", 
			"scoreTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "iIndex", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "iCampId", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "iLock", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "iOccupy", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "scoreTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 20
	}, 
	"sixcube.protocol.SceneMessage.PortalInfo": {
		"compose": [
			"iIndex", 
			"iState"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "iIndex", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "iState", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SceneMessage.RequestBuyLife": {
		"compose": [
			"m_nSceneId", 
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.SceneMessage.RequestExitBattle": {
		"compose": [
			"m_nSceneId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.SceneMessage.RequestSceneStat": {
		"compose": [
			"m_nSceneId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.SceneMessage.SyncHpChange": {
		"compose": [
			"m_hpChgInfoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.HpChangeInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_hpChgInfoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.SceneMessage.SyncOccupyData": {
		"compose": [
			"m_occupyVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.OccupyInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_occupyVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.SceneMessage.SyncPortalData": {
		"compose": [
			"m_portalVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.PortalInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_portalVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.SceneMessage.SyncSceneData": {
		"compose": [
			"m_moveVec", 
			"m_fireVec", 
			"m_skillVec", 
			"m_hpVec", 
			"m_deadVec", 
			"m_mpVec", 
			"m_blowUpVec", 
			"m_delVec", 
			"m_overVec", 
			"m_shieldVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.MoveInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_moveVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.NotifyFire", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_fireVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TankMessage.NotifyUseSkill", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_skillVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.ObjectHp", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_hpVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.AINpcDead", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_deadVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.ObjectMp", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_mpVec"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_blowUpVec"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_delVec"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_overVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.SceneMessage.ObjectShield", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_shieldVec"
			}
		], 
		"min_bytes": 20
	}, 
	"sixcube.protocol.SceneMessage.UpdateObjScoreInfo": {
		"compose": [
			"m_reaon", 
			"m_values", 
			"m_target"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_reaon", 
				"type": "i32"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.OneObjScore", 
				"kind": "struct", 
				"name": "m_values"
			}, 
			{
				"kind": "scalar", 
				"name": "m_target", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.SceneMessage.UpdateSceneScoreInfo": {
		"compose": [
			"m_values"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.OneObjScore", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_values"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.SceneMessage.UpdateVotationInfo": {
		"compose": [
			"m_validCount", 
			"m_vecVoteInfo"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_validCount", 
				"type": "u8"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u8"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecVoteInfo"
			}
		], 
		"min_bytes": 3
	}, 
	"sixcube.protocol.ShareTypes.BUDDY_BRIEF": {
		"compose": [
			"m_accountId", 
			"m_charUuid", 
			"m_name", 
			"m_usedName", 
			"m_level", 
			"m_sex", 
			"m_online", 
			"m_state", 
			"m_roomType", 
			"m_vipLevel", 
			"m_gmLevel", 
			"m_eloSectionId", 
			"m_elo", 
			"m_nSessionTime", 
			"m_lastLoginTime", 
			"m_avatarId", 
			"m_decorateId", 
			"m_nHonorId", 
			"m_nBoosterAttack"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_accountId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_name", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_usedName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_level", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sex", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_online", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_state", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_roomType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_vipLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_gmLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_eloSectionId", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_elo", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSessionTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_lastLoginTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_avatarId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_decorateId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHonorId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBoosterAttack", 
				"type": "u32"
			}
		], 
		"min_bytes": 44
	}, 
	"sixcube.protocol.ShareTypes.ChatContents": {
		"compose": [
			"channel", 
			"senderVipLvl", 
			"senderGmLv", 
			"receiverVipLvl", 
			"senderOid", 
			"senderUuid", 
			"sender", 
			"senderGid", 
			"receiverOid", 
			"receiverUuid", 
			"receiver", 
			"content", 
			"paramVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "channel", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "senderVipLvl", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "senderGmLv", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "receiverVipLvl", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "senderOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "senderUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "sender", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "senderGid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "receiverOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "receiverUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "receiver", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "content", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "paramVec", 
				"type": "utf8"
			}
		], 
		"min_bytes": 31
	}, 
	"sixcube.protocol.SkillMessage.NotifySkillDestPos": {
		"compose": [
			"m_objId", 
			"m_destX", 
			"m_destY"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destY", 
				"type": "i16"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.SkillMessage.RequestAutoBullet": {
		"compose": [
			"m_sceneId", 
			"m_startX", 
			"m_startY", 
			"m_destX", 
			"m_destY"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_startX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_startY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destY", 
				"type": "i16"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.SkillMessage.RequestCacheSkillDestPos": {
		"compose": [
			"m_sceneId", 
			"m_destX", 
			"m_destY"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destY", 
				"type": "i16"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.StageMessage.NotifyStageCleared": {
		"compose": [
			"m_nStage", 
			"m_nCharLv"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nStage", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCharLv", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.StageMessage.NotifyStageProgress": {
		"compose": [
			"m_stage", 
			"m_now", 
			"m_max"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_stage", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_now"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_max"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.StageMessage.NotifyStageReapResult": {
		"compose": [
			"m_nResult", 
			"m_nStage"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStage", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.StageMessage.NotifyStageReward": {
		"compose": [
			"m_nStage", 
			"m_bReward", 
			"m_nReaped", 
			"m_nNextTime", 
			"m_nGetFlag", 
			"m_nStartLv", 
			"m_curStageVal"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nStage", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bReward", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nReaped", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nNextTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGetFlag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStartLv", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_curStageVal", 
				"type": "u32"
			}
		], 
		"min_bytes": 28
	}, 
	"sixcube.protocol.StageMessage.RequestReapStageReward": {
		"compose": [
			"m_nStage", 
			"m_isShow"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nStage", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isShow", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.StoreMessage.ConfirmStorePurchase": {
		"compose": [
			"m_storeType", 
			"m_itemPos", 
			"m_storeGood"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_storeType", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_itemPos", 
				"type": "u16"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.STORE_GOODS", 
				"kind": "struct", 
				"name": "m_storeGood"
			}
		], 
		"min_bytes": 23
	}, 
	"sixcube.protocol.StoreMessage.NotifyStoreBrief": {
		"compose": [
			"m_ntoreType", 
			"m_lastUpdate", 
			"m_refreshCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_ntoreType", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_lastUpdate", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_refreshCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.StoreMessage.NotifyStoreEnableSucceed": {
		"compose": [
			"m_ntoreType", 
			"m_lastUpdate", 
			"m_refreshCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_ntoreType", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_lastUpdate", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_refreshCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.StoreMessage.NotifyStoreMerchandise": {
		"compose": [
			"m_storeType", 
			"m_lastUpdate", 
			"m_refreshCount", 
			"m_storeGoods"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_storeType", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_lastUpdate", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_refreshCount", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.STORE_GOODS", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_storeGoods"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.SystemMessage.GmCommand": {
		"compose": [
			"m_command", 
			"m_gmName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_command", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_gmName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.SystemMessage.NotifyPingGateSvr": {
		"compose": [
			"m_recvTime", 
			"m_time"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_recvTime", 
				"type": "u64_words"
			}, 
			{
				"kind": "scalar", 
				"name": "m_time", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.SystemMessage.RequestPing": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.SystemMessage.SystemErrorMessage": {
		"compose": [
			"m_MsgID", 
			"m_ErrNo", 
			"m_errParamVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_MsgID", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_ErrNo", 
				"type": "i32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "utf8"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_errParamVec"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.SystemMessage.SystemHeartBeat": {
		"compose": [
			"m_time"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_time", 
				"type": "u64_words"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TalentMessage.NotifyOpTalentPage": {
		"compose": [
			"opType", 
			"strPageUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "opType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "strPageUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TalentMessage.NotifySceneCurTalentPage": {
		"compose": [
			"talentVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.CHAR_TALENT_PAGE", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "talentVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TalentMessage.NotifyTalentInfo": {
		"compose": [
			"talentPageVec", 
			"talTotalPoint", 
			"buyPageCount"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.TALENT_PAGE", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "talentPageVec"
			}, 
			{
				"kind": "scalar", 
				"name": "talTotalPoint", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "buyPageCount", 
				"type": "u8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.TalentMessage.NotifyTalentTotalPoint": {
		"compose": [
			"talTotalPoint"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "talTotalPoint", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TalentMessage.NotifyUpdateTalentPage": {
		"compose": [
			"opType", 
			"talentPage"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "opType", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.TALENT_PAGE", 
				"kind": "struct", 
				"name": "talentPage"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.TalentMessage.RequestAddTalentPage": {
		"compose": [
			"strPageName", 
			"nBuyType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "strPageName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "nBuyType", 
				"type": "u8"
			}
		], 
		"min_bytes": 3
	}, 
	"sixcube.protocol.TalentMessage.RequestOpTalentPage": {
		"compose": [
			"opType", 
			"strPageUuid", 
			"tankUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "opType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "strPageUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "tankUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TalentMessage.RequestSaveTalentPage": {
		"compose": [
			"talentPage"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.TALENT_PAGE", 
				"kind": "struct", 
				"name": "talentPage"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.TankMakeMessage.NotifyMakeTankInfo": {
		"compose": [
			"nLuckyVal"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nLuckyVal", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankMakeMessage.SyncTreasureTankMessage": {
		"compose": [
			"tankId", 
			"awardTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "tankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "awardTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.ChangeBattleTank": {
		"compose": [
			"m_tankUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_tankUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankMessage.NotifyAddTank": {
		"compose": [
			"m_selfData"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TankMessage.TankInfo", 
				"kind": "struct", 
				"name": "m_selfData"
			}
		], 
		"min_bytes": 46
	}, 
	"sixcube.protocol.TankMessage.NotifyBattleExp": {
		"compose": [
			"m_curExp", 
			"m_posX", 
			"m_posY", 
			"m_killHit"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_curExp", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_posX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_posY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_killHit", 
				"type": "u8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.TankMessage.NotifyChangeSlotSkill": {
		"compose": [
			"m_itemData"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.PropsInfo", 
				"kind": "struct", 
				"name": "m_itemData"
			}
		], 
		"min_bytes": 22
	}, 
	"sixcube.protocol.TankMessage.NotifyClientFreeWeekTank": {
		"compose": [
			"m_vecTankId", 
			"m_needNotify"
		], 
		"fields": [
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecTankId"
			}, 
			{
				"kind": "scalar", 
				"name": "m_needNotify", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TankMessage.NotifyDeleteTank": {
		"compose": [
			"m_tankUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_tankUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankMessage.NotifyExpeditionInfo": {
		"compose": [
			"m_nTime1", 
			"m_nTime2", 
			"m_nTime3", 
			"m_nTankId1", 
			"m_nTankId2", 
			"m_nTankId3", 
			"m_nTankId4", 
			"m_nTankId5", 
			"m_nTankId6", 
			"m_nTankId7", 
			"m_nTankId8", 
			"m_nTankId9"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTime1", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTime2", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTime3", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId1", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId2", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId3", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId4", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId5", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId6", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId7", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId8", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId9", 
				"type": "u32"
			}
		], 
		"min_bytes": 48
	}, 
	"sixcube.protocol.TankMessage.NotifyFireBallCanSelTankMessage": {
		"compose": [
			"m_vecTankId"
		], 
		"fields": [
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecTankId"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankMessage.NotifyGetResearchTankResult": {
		"compose": [
			"m_nResult", 
			"m_nTankId", 
			"m_nSchedule"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSchedule", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TankMessage.NotifyGetTankSkinResult": {
		"compose": [
			"m_nResult", 
			"m_nSkinId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkinId", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.NotifyOtherList": {
		"compose": [
			"m_otherList"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TankMessage.TankInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_otherList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankMessage.NotifyPresentHireTankOK": {
		"compose": [
			"m_nTankId", 
			"m_nTankLevel", 
			"m_nHireTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHireTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TankMessage.NotifyReceivePresentHireTank": {
		"compose": [
			"m_strPresentName", 
			"m_nTankId", 
			"m_nTankLevel", 
			"m_nHireTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strPresentName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHireTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.TankMessage.NotifyRecycleTankResearchResult": {
		"compose": [
			"m_nResult", 
			"m_nTankId", 
			"m_nExp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nExp", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TankMessage.NotifyRepeatGiveTank": {
		"compose": [
			"m_nTankId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankMessage.NotifyRepeatGiveTankSkin": {
		"compose": [
			"m_nItemId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nItemId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankMessage.NotifyResearchTankResult": {
		"compose": [
			"m_nTankId", 
			"m_nResult", 
			"m_nSchedule", 
			"m_nTodayCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSchedule", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTodayCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.TankMessage.NotifySelfData": {
		"compose": [
			"m_selfData", 
			"m_fireRate", 
			"m_speed", 
			"m_skillVec", 
			"m_itemVec", 
			"m_nKillCount", 
			"m_nDeadCount", 
			"m_nAssistCount"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TankMessage.TankInfo", 
				"kind": "struct", 
				"name": "m_selfData"
			}, 
			{
				"kind": "scalar", 
				"name": "m_fireRate", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_speed", 
				"type": "i16"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.PropsInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_skillVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.GiveItemStruct", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_itemVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nKillCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDeadCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAssistCount", 
				"type": "u8"
			}
		], 
		"min_bytes": 57
	}, 
	"sixcube.protocol.TankMessage.NotifySignalInfo": {
		"compose": [
			"m_objectId", 
			"m_iDestX", 
			"m_iDestY", 
			"m_iSignalType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objectId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iDestX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iDestY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iSignalType", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.TankMessage.NotifySkillStop": {
		"compose": [
			"m_nCasterId", 
			"m_nSkillId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCasterId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkillId", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.NotifySkinChipResult": {
		"compose": [
			"m_nResult", 
			"m_nSkinId", 
			"m_nSchedule"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkinId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSchedule", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TankMessage.NotifySpray": {
		"compose": [
			"m_sprayId", 
			"m_x", 
			"m_y"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sprayId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.NotifyTankBattleLevel": {
		"compose": [
			"m_objectId", 
			"m_Level"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objectId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_Level", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.TankMessage.NotifyTankBattleValMessage": {
		"compose": [
			"m_tankId", 
			"m_battleVal", 
			"m_valType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_tankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleVal", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_valType", 
				"type": "i32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TankMessage.NotifyTankHaloInfo": {
		"compose": [
			"m_nActType", 
			"m_nHaloId", 
			"m_vTankUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHaloId", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "utf8"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vTankUuid"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.TankMessage.NotifyTankList": {
		"compose": [
			"m_tankVec", 
			"m_notifyType", 
			"m_contType"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.TankInstance", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_tankVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_notifyType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u8"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankMessage.NotifyTankOpFail": {
		"compose": [
			"m_tankUuid", 
			"m_nType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_tankUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TankMessage.NotifyTankRelive": {
		"compose": [
			"m_acctOid", 
			"m_iReliveTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_acctOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iReliveTime", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.NotifyTankResearchInfo": {
		"compose": [
			"m_vecResearch"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TankMessage.TankResearchInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecResearch"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankMessage.NotifyTankSkinChipInfo": {
		"compose": [
			"m_vecChip"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TankMessage.TankSkinChipInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecChip"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankMessage.NotifyTeammateProp": {
		"compose": [
			"m_teamMateProp"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TankMessage.TeamProp", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_teamMateProp"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankMessage.NotifyUseSkill": {
		"compose": [
			"m_nCasterId", 
			"m_nTargetId", 
			"m_nSkillId", 
			"m_StartX", 
			"m_StartY", 
			"m_x", 
			"m_y", 
			"m_isReady", 
			"m_nCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCasterId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTargetId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkillId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_StartX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_StartY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isReady", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCount", 
				"type": "u8"
			}
		], 
		"min_bytes": 22
	}, 
	"sixcube.protocol.TankMessage.NotifyUseTankHaloResult": {
		"compose": [
			"m_bSuccess", 
			"m_sTankUUID", 
			"m_nHaloId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bSuccess", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_sTankUUID", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHaloId", 
				"type": "u32"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.TankMessage.RequestBuyTankSkinChip": {
		"compose": [
			"m_bBatch", 
			"m_nSkinId", 
			"m_nCoinType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bBatch", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkinId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCoinType", 
				"type": "u32"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.TankMessage.RequestChangeSkin": {
		"compose": [
			"m_tankUuid", 
			"m_skinUuid", 
			"m_contType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_tankUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_skinUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_contType", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.TankMessage.RequestGetRareTank": {
		"compose": [
			"m_nRareId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRareId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankMessage.RequestGetResearchTank": {
		"compose": [
			"m_nTankId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankMessage.RequestGetTankSkin": {
		"compose": [
			"m_nSkinId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSkinId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankMessage.RequestOpSpray": {
		"compose": [
			"m_sceneId", 
			"m_x", 
			"m_y"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.RequestRecycleTankResearch": {
		"compose": [
			"m_nTankId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankMessage.RequestResearchTank": {
		"compose": [
			"m_nTankId", 
			"m_nCoinType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCoinType", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.RequestSignalInfo": {
		"compose": [
			"m_nSceneId", 
			"m_iDestX", 
			"m_iDestY", 
			"m_iSignalType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iDestX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iDestY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iSignalType", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.TankMessage.RequestTankResearchInfo": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TankMessage.RequestUseFreeWeekTank": {
		"compose": [
			"m_nTankId", 
			"m_nTankCont"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankCont", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.RequestUseSkill": {
		"compose": [
			"m_sceneId", 
			"m_targetId", 
			"m_soltNo", 
			"m_destX", 
			"m_destY"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sceneId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_targetId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_soltNo", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destY", 
				"type": "i16"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.TankMessage.RequestUseTankHalo": {
		"compose": [
			"m_sTankUUID", 
			"m_nHaloId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_sTankUUID", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHaloId", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TankMessage.SceneShopBuyMessage": {
		"compose": [
			"m_nRoomId", 
			"m_nPropsId", 
			"m_nType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nPropsId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u8"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.TankMessage.SyncSkillCooltime": {
		"compose": [
			"m_nPropData", 
			"m_nOwnerId"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.PropsInfo", 
				"kind": "struct", 
				"name": "m_nPropData"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nOwnerId", 
				"type": "u32"
			}
		], 
		"min_bytes": 26
	}, 
	"sixcube.protocol.TankMessage.TankInfo": {
		"compose": [
			"m_objId", 
			"m_acctOid", 
			"m_x", 
			"m_y", 
			"m_hp", 
			"m_maxHp", 
			"m_iStar", 
			"m_iCamp", 
			"m_name", 
			"m_buffVec", 
			"m_lifeCount", 
			"m_curBattleExp", 
			"m_battleLevel", 
			"m_tankLevel", 
			"m_mp", 
			"m_maxMp", 
			"m_shield"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_objId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_acctOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_x", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_y", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_hp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_maxHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iStar", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iCamp", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_name", 
				"type": "utf8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.BuffInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_buffVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_lifeCount", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_curBattleExp", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_tankLevel", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_mp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_maxMp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_shield", 
				"type": "i32"
			}
		], 
		"min_bytes": 46
	}, 
	"sixcube.protocol.TankMessage.TankResearchInfo": {
		"compose": [
			"m_nTankId", 
			"m_nResearchCount", 
			"m_nSchedule"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nResearchCount", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSchedule", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TankMessage.TankSkinChipInfo": {
		"compose": [
			"m_nSkinId", 
			"m_nSchedule"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nSkinId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSchedule", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankMessage.TeamProp": {
		"compose": [
			"m_nPropData", 
			"m_nAcctOid"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.PropsInfo", 
				"kind": "struct", 
				"name": "m_nPropData"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAcctOid", 
				"type": "u32"
			}
		], 
		"min_bytes": 26
	}, 
	"sixcube.protocol.TankMessage.UpdateBulletOrbit": {
		"compose": [
			"m_bullteId", 
			"m_startX", 
			"m_startY", 
			"m_destX", 
			"m_destY"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bullteId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_startX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_startY", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destX", 
				"type": "i16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destY", 
				"type": "i16"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TankMessage.UpdateTankAttr": {
		"compose": [
			"m_acctOid", 
			"m_updateType", 
			"m_iUpdateVal"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_acctOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_updateType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iUpdateVal", 
				"type": "i32"
			}
		], 
		"min_bytes": 9
	}, 
	"sixcube.protocol.TankMessage.UpdateTankInstance": {
		"compose": [
			"m_tankInst", 
			"m_opType"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.BulkDataType.TankInstance", 
				"kind": "struct", 
				"name": "m_tankInst"
			}, 
			{
				"kind": "scalar", 
				"name": "m_opType", 
				"type": "u8"
			}
		], 
		"min_bytes": 61
	}, 
	"sixcube.protocol.TankPartMessage.NotifyTankPartInfo": {
		"compose": [
			"partInfo", 
			"bOpeType"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.TankPartInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "partInfo"
			}, 
			{
				"kind": "scalar", 
				"name": "bOpeType", 
				"type": "u8"
			}
		], 
		"min_bytes": 3
	}, 
	"sixcube.protocol.TankPartMessage.NotifyTankPartScore": {
		"compose": [
			"nScore"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nScore", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TankSoulMessage.CHAR_TANK_SOUL_COMP_BRIEF": {
		"compose": [
			"m_nOid", 
			"m_szUuid", 
			"m_szName", 
			"m_nAvatar", 
			"m_nRank", 
			"m_defendBrief"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nOid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAvatar", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_ARRAY", 
				"kind": "struct", 
				"name": "m_defendBrief"
			}
		], 
		"min_bytes": 86
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyAddTankSoul": {
		"compose": [
			"m_tankSoul"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TankSoulMessage.TankSoulInst", 
				"kind": "struct", 
				"name": "m_tankSoul"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyBuyTankSoulResult": {
		"compose": [
			"m_nTankSoulId", 
			"m_nRate"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRate", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.TankSoulMessage.NotifySetPveTankSoulOk": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulAddExpOk": {
		"compose": [
			"m_nTankSoulId", 
			"m_nLevel", 
			"m_nExp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLevel", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nExp", 
				"type": "u32"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulBattleHistory": {
		"compose": [
			"m_vecBattleInfo"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_HISTORY_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecBattleInfo"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulBattleProcess": {
		"compose": [
			"m_bType", 
			"m_nMapId", 
			"m_basicInfoA", 
			"m_basicInfoB", 
			"m_vecRound"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_BASIC_INFO", 
				"kind": "struct", 
				"name": "m_basicInfoA"
			}, 
			{
				"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_BASIC_INFO", 
				"kind": "struct", 
				"name": "m_basicInfoB"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_ROUND_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecRound"
			}
		], 
		"min_bytes": 39
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulBattleResult": {
		"compose": [
			"m_bWin", 
			"m_nSilver", 
			"m_itemVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bWin", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSilver", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleItemInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_itemVec"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulCompInfo": {
		"compose": [
			"m_bHasAward", 
			"m_nChallengeCount", 
			"m_nBuyCount", 
			"m_nBuyLimit", 
			"m_nSequenceWin", 
			"m_nCoolTime", 
			"m_nRank", 
			"m_nYesterdayRank", 
			"m_attackBrief", 
			"m_defendBrief"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bHasAward", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nChallengeCount", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBuyCount", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBuyLimit", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSequenceWin", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCoolTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nYesterdayRank", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_ARRAY", 
				"kind": "struct", 
				"name": "m_attackBrief"
			}, 
			{
				"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_ARRAY", 
				"kind": "struct", 
				"name": "m_defendBrief"
			}
		], 
		"min_bytes": 161
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulCompRankRecord": {
		"compose": [
			"m_nNewRank", 
			"m_nOldRank", 
			"m_item"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nNewRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nOldRank", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.BulkDataType.SettleItemInfo", 
				"kind": "struct", 
				"name": "m_item"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulEnemyList": {
		"compose": [
			"m_enemyList"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TankSoulMessage.CHAR_TANK_SOUL_COMP_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_enemyList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulList": {
		"compose": [
			"m_tankSoulList"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TankSoulMessage.TankSoulInst", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_tankSoulList"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulPveBattleResult": {
		"compose": [
			"m_nMapId", 
			"m_bWin", 
			"m_bFirstPass", 
			"m_vecItem"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bWin", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bFirstPass", 
				"type": "u8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleItemInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecItem"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulPveInitData": {
		"compose": [
			"m_nEasyMapId", 
			"m_nHardMapId", 
			"m_vecTankSoul"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nEasyMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nHardMapId", 
				"type": "u32"
			}, 
			{
				"element": {
					"kind": "scalar", 
					"type": "u32"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecTankSoul"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulPveMapData": {
		"compose": [
			"m_nMapId", 
			"m_nLeftCount", 
			"m_nBuyCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLeftCount", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBuyCount", 
				"type": "u16"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulPveSweepResult": {
		"compose": [
			"m_nMapId", 
			"m_vecAward"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nMapId", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TankSoulMessage.TankSoulPveSweepInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecAward"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TankSoulMessage.NotifyTankSoulUpgradeStarOk": {
		"compose": [
			"m_nTankSoulId", 
			"m_nStar"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStar", 
				"type": "u8"
			}
		], 
		"min_bytes": 5
	}, 
	"sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_ARRAY": {
		"compose": [
			"m_nTankSoulId1", 
			"m_nTankSoulStar1", 
			"m_nTankSoulLv1", 
			"m_nTankSoulId2", 
			"m_nTankSoulStar2", 
			"m_nTankSoulLv2", 
			"m_nTankSoulId3", 
			"m_nTankSoulStar3", 
			"m_nTankSoulLv3", 
			"m_nTankSoulId4", 
			"m_nTankSoulStar4", 
			"m_nTankSoulLv4", 
			"m_nTankSoulId5", 
			"m_nTankSoulStar5", 
			"m_nTankSoulLv5", 
			"m_nTankSoulId6", 
			"m_nTankSoulStar6", 
			"m_nTankSoulLv6", 
			"m_nTankSoulId7", 
			"m_nTankSoulStar7", 
			"m_nTankSoulLv7", 
			"m_nTankSoulId8", 
			"m_nTankSoulStar8", 
			"m_nTankSoulLv8", 
			"m_nTankSoulId9", 
			"m_nTankSoulStar9", 
			"m_nTankSoulLv9", 
			"m_nTankSoulId10", 
			"m_nTankSoulStar10", 
			"m_nTankSoulLv10"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId1", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar1", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv1", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId2", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar2", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv2", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId3", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar3", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv3", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId4", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar4", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv4", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId5", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar5", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv5", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId6", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar6", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv6", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId7", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar7", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv7", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId8", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar8", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv8", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId9", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar9", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv9", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId10", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulStar10", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTankSoulLv10", 
				"type": "u16"
			}
		], 
		"min_bytes": 70
	}, 
	"sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_BASIC_INFO": {
		"compose": [
			"m_nStrength", 
			"m_nAgility", 
			"m_nDefence", 
			"m_nMorale"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nStrength", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAgility", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDefence", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nMorale", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_HISTORY_INFO": {
		"compose": [
			"m_strEnemy", 
			"m_nBattleResult", 
			"m_nRank", 
			"m_nBattleTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strEnemy", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBattleResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBattleTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_ROUND_INFO": {
		"compose": [
			"m_bCamp", 
			"m_nCaster", 
			"m_nSkillId", 
			"m_basicA", 
			"m_basicB"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bCamp", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCaster", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkillId", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_BASIC_INFO", 
				"kind": "struct", 
				"name": "m_basicA"
			}, 
			{
				"class": "sixcube.protocol.TankSoulMessage.TANK_SOUL_BATTLE_BASIC_INFO", 
				"kind": "struct", 
				"name": "m_basicB"
			}
		], 
		"min_bytes": 41
	}, 
	"sixcube.protocol.TankSoulMessage.TankSoulInst": {
		"compose": [
			"m_nTankSoulId", 
			"m_nStar", 
			"m_nLv", 
			"m_nRate", 
			"m_nExp"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTankSoulId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStar", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nLv", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRate", 
				"type": "u16"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nExp", 
				"type": "u32"
			}
		], 
		"min_bytes": 13
	}, 
	"sixcube.protocol.TankSoulMessage.TankSoulPveSweepInfo": {
		"compose": [
			"m_vecItem"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.SettleItemInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecItem"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.AcceptChangeTeam": {
		"compose": [
			"m_nTeamId", 
			"m_charUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.ChallengeInfo": {
		"compose": [
			"m_teamBrief", 
			"m_nState", 
			"m_iCount", 
			"m_iPlace", 
			"m_nScores", 
			"m_nContest", 
			"m_nTurn", 
			"m_nStart", 
			"m_nCluster"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.TeamBrief", 
				"kind": "struct", 
				"name": "m_teamBrief"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nState", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iCount", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iPlace", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nScores", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nContest", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTurn", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStart", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nCluster", 
				"type": "u32"
			}
		], 
		"min_bytes": 48
	}, 
	"sixcube.protocol.TeamMessage.CharGuildWelfareDrawInfo": {
		"compose": [
			"nWelfareId", 
			"nGetTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nWelfareId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nGetTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TeamMessage.GuildBossAwardInfo": {
		"compose": [
			"m_bossId", 
			"m_awardBaseItem", 
			"m_awardRandItem", 
			"m_battleTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bossId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_awardBaseItem", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_awardRandItem", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.TeamMessage.GuildBossDamageInfo": {
		"compose": [
			"m_charUuid", 
			"m_charName", 
			"m_dmgHp", 
			"m_infoOverTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_charName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_dmgHp", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_infoOverTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TeamMessage.GuildBossInfo": {
		"compose": [
			"m_bossId", 
			"m_deadTime", 
			"m_battleTime", 
			"m_battleUuid", 
			"m_randAwardName", 
			"m_damInfoVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bossId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_deadTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_battleUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_randAwardName", 
				"type": "utf8"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.GuildBossDamageInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_damInfoVec"
			}
		], 
		"min_bytes": 18
	}, 
	"sixcube.protocol.TeamMessage.GuildInfo": {
		"compose": [
			"nGuildId", 
			"strName", 
			"nLevel", 
			"leaderUuid", 
			"viceLeaderUuid", 
			"strNotice", 
			"nActiveNum", 
			"iCoin", 
			"nCreateTime", 
			"iSettingBit", 
			"nLevelLimit", 
			"nLadderLimit", 
			"strRecruitNotice", 
			"weekLiveness", 
			"monthLiveness"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nGuildId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "strName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "nLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "leaderUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "viceLeaderUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "strNotice", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "nActiveNum", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "iCoin", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "nCreateTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "iSettingBit", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "nLevelLimit", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nLadderLimit", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "strRecruitNotice", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "weekLiveness", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "monthLiveness", 
				"type": "u32"
			}
		], 
		"min_bytes": 50
	}, 
	"sixcube.protocol.TeamMessage.GuildInviteInfo": {
		"compose": [
			"nAcctId", 
			"szInviteName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nAcctId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "szInviteName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.GuildMatchStartPair": {
		"compose": [
			"m_nGuildId", 
			"m_nTrackSvrId", 
			"m_nRoomId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGuildId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTrackSvrId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRoomId", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TeamMessage.GuildMatchTeamBrief": {
		"compose": [
			"m_strName", 
			"m_nAvatarId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_strName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAvatarId", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.GuildMatchTeamContest": {
		"compose": [
			"m_teamRed", 
			"m_teamBlue", 
			"m_nResult"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.GuildMatchTeamBrief", 
				"kind": "struct", 
				"name": "m_teamRed"
			}, 
			{
				"class": "sixcube.protocol.TeamMessage.GuildMatchTeamBrief", 
				"kind": "struct", 
				"name": "m_teamBlue"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.TeamMessage.GuildSkillInfo": {
		"compose": [
			"m_nGuildSkillId", 
			"m_nSkillLevel"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGuildSkillId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nSkillLevel", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TeamMessage.GuildWelfareInfo": {
		"compose": [
			"nWelfareId", 
			"strName", 
			"nGiftId", 
			"nCreateTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nWelfareId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "strName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "nGiftId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nCreateTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.TeamMessage.KillGuildBossInfo": {
		"compose": [
			"m_bossName", 
			"m_killName", 
			"m_deadTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_bossName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_killName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_deadTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TeamMessage.MemberInfo": {
		"compose": [
			"nTeamId", 
			"charUuid", 
			"nAcctId", 
			"nJoinTime", 
			"nTransTime", 
			"iMerit", 
			"iAllMerit", 
			"weekLiveness", 
			"monthLiveness"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "nAcctId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nJoinTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nTransTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "iMerit", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "iAllMerit", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "weekLiveness", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "monthLiveness", 
				"type": "u32"
			}
		], 
		"min_bytes": 34
	}, 
	"sixcube.protocol.TeamMessage.NotifyApplyList": {
		"compose": [
			"m_charVec", 
			"m_inviteVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_charVec"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.GuildInviteInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_inviteVec"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TeamMessage.NotifyBeChallenge": {
		"compose": [
			"m_nTeamId", 
			"m_teamBrief", 
			"m_nStartTime", 
			"m_nType"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"class": "sixcube.protocol.TeamMessage.TeamBrief", 
				"kind": "struct", 
				"name": "m_teamBrief"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStartTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}
		], 
		"min_bytes": 28
	}, 
	"sixcube.protocol.TeamMessage.NotifyChallengeFail": {
		"compose": [
			"m_nErr", 
			"m_nParam"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nErr", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nParam", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TeamMessage.NotifyChallengeList": {
		"compose": [
			"m_list"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.ChallengeInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_list"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.NotifyChallengeOk": {
		"compose": [
			"m_teamBrief", 
			"m_nStartTime", 
			"m_nRoomType"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.TeamBrief", 
				"kind": "struct", 
				"name": "m_teamBrief"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStartTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRoomType", 
				"type": "u32"
			}
		], 
		"min_bytes": 24
	}, 
	"sixcube.protocol.TeamMessage.NotifyChangePost": {
		"compose": [
			"m_targetUuid", 
			"m_iPost"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_targetUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iPost", 
				"type": "i32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.NotifyCharGuildWelfareInfo": {
		"compose": [
			"m_nCharDatas"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.CharGuildWelfareDrawInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_nCharDatas"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.NotifyConquerCastle": {
		"compose": [
			"m_nRank"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nRank", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TeamMessage.NotifyCreateTeam": {
		"compose": [
			"m_info"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.TeamInfo", 
				"kind": "struct", 
				"name": "m_info"
			}
		], 
		"min_bytes": 48
	}, 
	"sixcube.protocol.TeamMessage.NotifyDeleteTeam": {
		"compose": [
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildBossAwardMessage": {
		"compose": [
			"m_awardInfoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.GuildBossAwardInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_awardInfoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildBossInfoMessage": {
		"compose": [
			"m_bossInfoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.GuildBossInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_bossInfoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildBossKillInfoMessage": {
		"compose": [
			"m_infoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.KillGuildBossInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_infoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildInfo": {
		"compose": [
			"m_info", 
			"m_teamVec", 
			"m_selfTeamId"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.GuildInfo", 
				"kind": "struct", 
				"name": "m_info"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.TeamInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_teamVec"
			}, 
			{
				"kind": "scalar", 
				"name": "m_selfTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 56
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildInvite": {
		"compose": [
			"m_szStarter", 
			"m_nGuildId", 
			"m_nGuildName", 
			"m_nTeamId", 
			"m_nTeamName", 
			"m_isJoinGuild"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_szStarter", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGuildId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGuildName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isJoinGuild", 
				"type": "u8"
			}
		], 
		"min_bytes": 15
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildMatchPairGroup": {
		"compose": [
			"m_nScore", 
			"m_nGuildIdRed", 
			"m_strGuildNameRed", 
			"m_nGuildIdBlue", 
			"m_strGuildNameBlue", 
			"m_nResult", 
			"m_vecContest", 
			"m_nTurn"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nScore", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGuildIdRed", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strGuildNameRed", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGuildIdBlue", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strGuildNameBlue", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nResult", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.GuildMatchTeamContest", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_vecContest"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTurn", 
				"type": "u32"
			}
		], 
		"min_bytes": 26
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildSkillInfo": {
		"compose": [
			"m_skillList", 
			"m_nOpType"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.GuildSkillInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_skillList"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nOpType", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildWelfareDatas": {
		"compose": [
			"m_nGuildId", 
			"m_welfreDatas", 
			"m_isAdd"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGuildId", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.GuildWelfareInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_welfreDatas"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isAdd", 
				"type": "u8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.TeamMessage.NotifyGuildWelfareHint": {
		"compose": [
			"m_isCanDraw"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_isCanDraw", 
				"type": "u8"
			}
		], 
		"min_bytes": 1
	}, 
	"sixcube.protocol.TeamMessage.NotifyInviteMember": {
		"compose": [
			"m_szStarter", 
			"m_charUuid", 
			"m_nTeamId", 
			"m_nTeamName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_szStarter", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.TeamMessage.NotifyJoinApply": {
		"compose": [
			"m_data"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
				"kind": "struct", 
				"name": "m_data"
			}
		], 
		"min_bytes": 44
	}, 
	"sixcube.protocol.TeamMessage.NotifyJoinApplyLogin": {
		"compose": [
			"m_count"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_count", 
				"type": "i32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TeamMessage.NotifyJoinGuild": {
		"compose": [
			"m_newMember", 
			"m_info"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.ShareTypes.BUDDY_BRIEF", 
				"kind": "struct", 
				"name": "m_newMember"
			}, 
			{
				"class": "sixcube.protocol.TeamMessage.MemberInfo", 
				"kind": "struct", 
				"name": "m_info"
			}
		], 
		"min_bytes": 78
	}, 
	"sixcube.protocol.TeamMessage.NotifyLeaveGuild": {
		"compose": [
			"m_charUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.NotifyTeamKickout": {
		"compose": [
			"m_targetUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_targetUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.NotifyTeamMatchInfo": {
		"compose": [
			"m_cgTeamBrief", 
			"m_beCgTeamBrief", 
			"m_bCgStart", 
			"m_bBeCgStart", 
			"m_cgWin", 
			"m_beCgWin", 
			"m_nState", 
			"m_nStartTime", 
			"m_roomType", 
			"m_notifyType", 
			"m_isPariPolicy"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.TeamBrief", 
				"kind": "struct", 
				"name": "m_cgTeamBrief"
			}, 
			{
				"class": "sixcube.protocol.TeamMessage.TeamBrief", 
				"kind": "struct", 
				"name": "m_beCgTeamBrief"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bCgStart", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bBeCgStart", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_cgWin", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_beCgWin", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nState", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nStartTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_roomType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_notifyType", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isPariPolicy", 
				"type": "u8"
			}
		], 
		"min_bytes": 44
	}, 
	"sixcube.protocol.TeamMessage.NotifyTeamMatchResult": {
		"compose": [
			"m_cgTeamBrief", 
			"m_beCgTeamBrief", 
			"m_nWinTeamId", 
			"m_nRoomType"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.TeamBrief", 
				"kind": "struct", 
				"name": "m_cgTeamBrief"
			}, 
			{
				"class": "sixcube.protocol.TeamMessage.TeamBrief", 
				"kind": "struct", 
				"name": "m_beCgTeamBrief"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nWinTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nRoomType", 
				"type": "u32"
			}
		], 
		"min_bytes": 40
	}, 
	"sixcube.protocol.TeamMessage.NotifyTeamMember": {
		"compose": [
			"m_nContestId", 
			"m_nGuildId", 
			"m_nTeamId", 
			"m_memberVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nContestId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nGuildId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TeamMessage.MemberInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_memberVec"
			}
		], 
		"min_bytes": 14
	}, 
	"sixcube.protocol.TeamMessage.RequestApplyList": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TeamMessage.RequestApproveApply": {
		"compose": [
			"m_charUuid", 
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.RequestChallengeList": {
		"compose": [
			"m_nActivity", 
			"m_nContest"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActivity", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nContest", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TeamMessage.RequestChallengeTeam": {
		"compose": [
			"m_nActivity", 
			"m_nTeamId", 
			"m_nContest"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActivity", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nContest", 
				"type": "u32"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TeamMessage.RequestChangeGuildName": {
		"compose": [
			"m_newName"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_newName", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.RequestChangePost": {
		"compose": [
			"m_targetUuid", 
			"m_iPost", 
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_targetUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iPost", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 10
	}, 
	"sixcube.protocol.TeamMessage.RequestChangeTeamName": {
		"compose": [
			"m_newName", 
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_newName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.RequestChangeTeamPveFlag": {
		"compose": [
			"m_isOpen"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_isOpen", 
				"type": "u8"
			}
		], 
		"min_bytes": 1
	}, 
	"sixcube.protocol.TeamMessage.RequestDeleteTeam": {
		"compose": [
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TeamMessage.RequestGuildGift": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TeamMessage.RequestGuildInvite": {
		"compose": [
			"m_nTargeter", 
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTargeter", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.RequestGuildKickout": {
		"compose": [
			"m_targetUuid", 
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_targetUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.RequestGuildOp": {
		"compose": [
			"m_type", 
			"m_iparam"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iparam", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TeamMessage.RequestGuildUpgrade": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TeamMessage.RequestInGuildUI": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TeamMessage.RequestInviteMember": {
		"compose": [
			"m_nTeamId", 
			"m_charUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 6
	}, 
	"sixcube.protocol.TeamMessage.RequestJoinApply": {
		"compose": [
			"m_nGuildId", 
			"m_szInviteName", 
			"m_isFastJoin"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGuildId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szInviteName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_isFastJoin", 
				"type": "u8"
			}
		], 
		"min_bytes": 7
	}, 
	"sixcube.protocol.TeamMessage.RequestJoinGuild": {
		"compose": [
			"m_nGuildId", 
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGuildId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TeamMessage.RequestLeaveGuild": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TeamMessage.RequestMoveMember": {
		"compose": [
			"m_nOrigTeamId", 
			"m_origUuid", 
			"m_nDestTeamId", 
			"m_destUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nOrigTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_origUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDestTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_destUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.TeamMessage.RequestOutGuildUI": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TeamMessage.RequestRejectApply": {
		"compose": [
			"m_charUuid"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_charUuid", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.RequestResearchGuildSkill": {
		"compose": [
			"m_nGuildSkillId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nGuildSkillId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TeamMessage.RequestSetChannel": {
		"compose": [
			"m_szChannel"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_szChannel", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.RequestSetNotice": {
		"compose": [
			"m_szNotice"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_szNotice", 
				"type": "utf8"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.TeamMessage.RequestTeamMatchStart": {
		"compose": [
			"m_nActivity"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nActivity", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TeamMessage.RequestTeamMember": {
		"compose": [
			"m_nTeamId"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TeamMessage.RequestTransferTeamCoin": {
		"compose": [
			"m_nCoins", 
			"m_nDirection"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nCoins", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nDirection", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TeamMessage.TeamBrief": {
		"compose": [
			"m_nTeamId", 
			"m_szCluster", 
			"m_szName", 
			"m_iPlace", 
			"m_iGlory"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szCluster", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_szName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iPlace", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iGlory", 
				"type": "i32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.TeamMessage.TeamInfo": {
		"compose": [
			"nTeamId", 
			"nGuildId", 
			"strName", 
			"leaderUuid", 
			"nPlace", 
			"nHonorId", 
			"nCreateTime", 
			"nLevel", 
			"iCoin", 
			"iGlory", 
			"iMerit", 
			"nExtFlag", 
			"iOverdueCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "nTeamId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nGuildId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "strName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "leaderUuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "nPlace", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nHonorId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nCreateTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "nLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "iCoin", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "iGlory", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "iMerit", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "nExtFlag", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "iOverdueCount", 
				"type": "i32"
			}
		], 
		"min_bytes": 48
	}, 
	"sixcube.protocol.TeamMessage.TeamMatchStartPair": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.TeamMessage.UpdateGuildInfo": {
		"compose": [
			"m_info", 
			"m_nType"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.GuildInfo", 
				"kind": "struct", 
				"name": "m_info"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}
		], 
		"min_bytes": 54
	}, 
	"sixcube.protocol.TeamMessage.UpdateMemberInfo": {
		"compose": [
			"m_info"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.MemberInfo", 
				"kind": "struct", 
				"name": "m_info"
			}
		], 
		"min_bytes": 34
	}, 
	"sixcube.protocol.TeamMessage.UpdateTeamInfo": {
		"compose": [
			"m_info", 
			"m_nType"
		], 
		"fields": [
			{
				"class": "sixcube.protocol.TeamMessage.TeamInfo", 
				"kind": "struct", 
				"name": "m_info"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nType", 
				"type": "u32"
			}
		], 
		"min_bytes": 52
	}, 
	"sixcube.protocol.TradeMessage.BuyGoodsMessage": {
		"compose": [
			"m_type", 
			"m_info", 
			"m_coinVec"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}, 
			{
				"class": "sixcube.protocol.TradeMessage.GoodsBuyInfo", 
				"kind": "struct", 
				"name": "m_info"
			}, 
			{
				"element": {
					"class": "sixcube.protocol.TradeMessage.GoodsCoinVal", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_coinVec"
			}
		], 
		"min_bytes": 22
	}, 
	"sixcube.protocol.TradeMessage.GoodsBuyInfo": {
		"compose": [
			"m_goodsId", 
			"m_coinType", 
			"m_price", 
			"m_count"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_goodsId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_coinType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_price", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_count", 
				"type": "i32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.TradeMessage.GoodsCoinVal": {
		"compose": [
			"m_coinType", 
			"m_value"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_coinType", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_value", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TradeMessage.NotifyBuyGoodsOk": {
		"compose": [
			"m_type"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}
		], 
		"min_bytes": 4
	}, 
	"sixcube.protocol.TradeMessage.NotifyRecommendTankMessage": {
		"compose": [
			"m_tankId", 
			"m_recommendEndTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_tankId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_recommendEndTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.TradeMessage.PresentGoodsMessage": {
		"compose": [
			"m_goodsId", 
			"m_price", 
			"m_count", 
			"m_receiverName", 
			"m_text"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_goodsId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_price", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_count", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_receiverName", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_text", 
				"type": "utf8"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.TradeMessage.RejectGoodsBuy": {
		"compose": [
			"m_type", 
			"m_iCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_type", 
				"type": "i32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_iCount", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.VipMessage.ChargeBillsBakInfo": {
		"compose": [
			"m_drawTime", 
			"m_coinCount"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_drawTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_coinCount", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.VipMessage.NotifyDrawSuperVipChargeBackMessage": {
		"compose": [
			"m_drawResult", 
			"m_backCash"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_drawResult", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_backCash", 
				"type": "i32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.VipMessage.NotifyQQVip": {
		"compose": [
			"m_nYellowLevel", 
			"m_bIsYearYellow", 
			"m_bIsHighYellow", 
			"m_nBlueLevel", 
			"m_bIsYearBlue", 
			"m_bIsHighBlue", 
			"m_n3366Level"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nYellowLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bIsYearYellow", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bIsHighYellow", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nBlueLevel", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bIsYearBlue", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bIsHighBlue", 
				"type": "u8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_n3366Level", 
				"type": "u32"
			}
		], 
		"min_bytes": 16
	}, 
	"sixcube.protocol.VipMessage.NotifySuperVipChargeInfoMessage": {
		"compose": [
			"m_infoVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.VipMessage.ChargeBillsBakInfo", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "m_infoVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.VipMessage.NotifyVipChange": {
		"compose": [
			"m_nPoints", 
			"m_nEnded", 
			"m_nAddTime", 
			"m_nTodayAddPoints", 
			"m_superVipEndTime", 
			"m_superVipAddTime"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_nPoints", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nEnded", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nAddTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_nTodayAddPoints", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_superVipEndTime", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_superVipAddTime", 
				"type": "u32"
			}
		], 
		"min_bytes": 24
	}, 
	"sixcube.protocol.VipMessage.RequestSuperVipChargeInfoMessage": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.WorldMessage.WorldEnterConfirm": {
		"compose": [
			"m_account_oid", 
			"m_game_token"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_account_oid", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_game_token", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.WorldMessage.WorldEnterMessage": {
		"compose": [
			"m_char_uuid", 
			"m_loginId", 
			"m_accountId", 
			"m_strEnterKey", 
			"m_bIsFirstLogin"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_char_uuid", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_loginId", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_accountId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_strEnterKey", 
				"type": "utf8"
			}, 
			{
				"kind": "scalar", 
				"name": "m_bIsFirstLogin", 
				"type": "i16"
			}
		], 
		"min_bytes": 12
	}, 
	"sixcube.protocol.WorldMessage.WorldEnterRejected": {
		"compose": [
			"m_accountId", 
			"m_reason"
		], 
		"fields": [
			{
				"kind": "scalar", 
				"name": "m_accountId", 
				"type": "u32"
			}, 
			{
				"kind": "scalar", 
				"name": "m_reason", 
				"type": "u32"
			}
		], 
		"min_bytes": 8
	}, 
	"sixcube.protocol.WorldMessage.WorldEnterTrackConfirm": {
		"compose": [], 
		"fields": [], 
		"min_bytes": 0
	}, 
	"sixcube.protocol.YCardMessage.NotifyPlayYCardAnimation": {
		"compose": [
			"yCardVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.YCARD_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "yCardVec"
			}
		], 
		"min_bytes": 2
	}, 
	"sixcube.protocol.YCardMessage.NotifyYCardInfo": {
		"compose": [
			"yCardVec"
		], 
		"fields": [
			{
				"element": {
					"class": "sixcube.protocol.BulkDataType.YCARD_INFO", 
					"kind": "struct"
				}, 
				"kind": "array", 
				"length_type": "u16", 
				"name": "yCardVec"
			}
		], 
		"min_bytes": 2
	}
}
