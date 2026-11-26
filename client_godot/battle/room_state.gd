extends RefCounted
var rooms: Dictionary = {}
var room: Dictionary = {}
var members: Dictionary = {}
var appearances: Dictionary = {}
var players: Array = []
var lists: Dictionary = {}
var self_id: int = 0
var page: int = 0

func clear() -> void :
	rooms.clear()
	room.clear()
	members.clear()
	appearances.clear()
	players.clear()
	lists.clear()
	self_id = 0
	page = 0

func brief(value: Dictionary) -> void :
	var id: int = int(value.charData.nAcctId)
	var old: Dictionary = members.get(id, {"ready": false, "battle": false})
	old["data"] = value
	members[id] = old
	appearances[id] = {"tank": int(value.otherData.tankId), "external": int(value.otherData.tankExternal), 
		"halo": int(value.otherData.get("haloId", 0)), "level": int(value.otherData.get("tankLevel", 0)), 
		"spray": int(value.otherData.get("sprayId", 0))}

func receive(type: int, value: Dictionary) -> void :
	match type:
		1724:
			page = int(value.m_iSite)
			if page <= 0:
				rooms.clear()
			for entry: Dictionary in value.m_roomList:
				rooms[int(entry.m_nRoomId)] = entry
			for entry: Dictionary in value.m_sceneList:


				rooms[int(entry.m_nSceneId)] = {"m_nRoomId": int(entry.m_nSceneId), 
					"m_nNum": int(entry.m_nNum), "m_nMax": int(entry.m_nAllNum), 
					"m_mapId": int(entry.m_mapId), "m_mode": 0, "m_type": int(entry.m_roomType), 
					"m_state": 3 if int(entry.m_inBattle) else 1, "m_szName": str(entry.m_szName), 
					"scene": true, "m_isLookerMax": int(entry.get("m_isLookerMax", 0)), "m_startTime": int(entry.get("m_startTime", 0))}
		1700:
			room = value.duplicate(true)
			members.clear()
			for entry: Dictionary in value.charVec:
				brief(entry.charBrief)
				var id: int = int(entry.charBrief.charData.nAcctId)
				members[id].ready = bool(entry.bReady)
				members[id].battle = bool(entry.bBattle)
		1702, 1706:
			brief(value.m_charData if type == 1702 else value.m_charBrief)
		1703:
			players = value.m_playerList
			lists[int(value.m_listType)] = value.m_playerList
		1704:
			if not room.is_empty():
				room.roomConfig.m_nMapId = value.m_nMapId
		1727:

			var before: Dictionary = appearances.get(int(value.m_nCharOid), {})
			var level: int = int(before.get("level", 0)) if int(before.get("tank", 0)) == int(value.m_nTankId) else 0
			appearances[int(value.m_nCharOid)] = {"tank": int(value.m_nTankId), "external": int(value.m_nTankExt), 
				"halo": int(before.get("halo", 0)), "level": level, "spray": int(before.get("spray", 0))}
		1728:
			var id: int = int(value.m_nCharOid)
			if appearances.has(id):
				if int(appearances[id].tank) != int(value.m_nTankId):
					appearances[id].level = 0
				appearances[id].tank = int(value.m_nTankId)
		1701:
			var id: int = int(value.m_nTarget) if int(value.m_nTarget) != 0 else int(value.m_nStartOid)
			match int(value.m_roomOp):
				1, 20:
					members.erase(id)
					if id == self_id:
						room.clear()
				2, 3:
					if members.has(id):
						members[id].ready = int(value.m_roomOp) == 2
				4:
					if members.has(id):

						var moved: Dictionary = members[id]
						moved.data.bCamp = 3 - int(moved.data.bCamp)
						members.erase(id)
						members[id] = moved
				26:
					if not room.is_empty():
						room.m_nCreateId = id
				21, 22:
					if not room.is_empty() and int(value.m_nTarget) >= 2:
						room.m_nMax = int(value.m_nTarget)
				101:
					if not room.is_empty():
						room.m_nPassword = int(value.m_nTarget)
				103:
					if members.has(id):
						members[id].battle = false
						members[id].ready = false

func is_host() -> bool:
	return not room.is_empty() and int(room.m_nCreateId) == self_id

func is_ready() -> bool:
	return bool(members.get(self_id, {}).get("ready", false))
