import {
  FrameReader,
  SERVER_GREETING,
  VERSION_OK_FRAME,
  decodeFrame,
  defaultStruct,
  encodeFrame,
  encodeRawFrame,
  u64Words,
} from "./protocol.js";
import { tankExternalId, validMapId } from "./catalog.js";
import { BattleSession } from "./battle.js";

function parseCreateCharRaw(body) {
  if (!Buffer.isBuffer(body) || body.length < 6) return null;
  const sex = body.readInt32LE(0);
  const nameLen = body.readUInt16LE(4);
  if (6 + nameLen > body.length) return null;
  const name = body.subarray(6, 6 + nameLen).toString("utf8").trim();
  return { sex, name };
}

class ClientSession {
  constructor(ws, role, world) {
    this.ws = ws;
    this.role = role; // "login" | "gate" | "comm"
    this.world = world;
    this.reader = new FrameReader();
    this.accountId = 0;
    this.accountOid = 0;
    this.username = "";
    this.character = null;
    this.inWorld = false;
    this.roomId = 0;
    this.battle = null;
    this.hallType = 0;
  }

  send(buf) {
    if (this.ws.readyState === 1) {
      this.ws.send(buf, { binary: true });
    }
  }

  activeTank() {
    const ch = this.character;
    if (!ch || !Array.isArray(ch.tanks) || ch.tanks.length === 0) return null;
    return ch.tanks.find((t) => t.m_tankUuid === ch.activeTankUuid) || ch.tanks[0];
  }

  buildCharBasic() {
    const ch = this.character;
    return defaultStruct("BulkDataType.CHAR_BASIC", {
      account_oid: ch.accountOid,
      sexes: ch.sex,
      level: ch.level,
      exp: ch.exp,
      milLevel: ch.milLevel || 1,
      milExp: ch.milExp || 0,
      sprayId: ch.sprayId || 0,
      avatarId: ch.avatarId || 2801001,
      decorateId: ch.decorateId || 0,
      thew: ch.thew ?? 200,
      thew_buy: ch.thewBuy ?? 0,
      create_time: ch.createTime || Math.floor(Date.now() / 1000),
      online_time: ch.onlineTime || 0,
      setting_flag: ch.settingFlag || 0,
      gm_level: ch.gmLevel || 0,
      name: ch.name,
      charUuid: ch.charUuid,
    });
  }

  buildPlayerBrief() {
    const ch = this.character;
    return defaultStruct("BulkDataType.PLAYER_BRIEF", {
      nAcctId: ch.accountOid,
      szCharUuid: ch.charUuid,
      szName: ch.name,
      bLevel: ch.level,
      bSex: ch.sex,
      nAvatar: ch.avatarId || 2801001,
      nDecorateId: ch.decorateId || 0,
      iElo: 1000,
    });
  }

  buildOtherBrief() {
    const t = this.activeTank();
    const tankId = t?.m_tpltId || 10000001;
    return defaultStruct("BulkDataType.OTHER_BRIEF", {
      tankId,
      tankLevel: t?.m_level || 1,
      tankExternal: t?.m_externalId || tankExternalId(tankId),
      haloId: t?.m_haloId || 0,
      skinFrameType: t?.m_skinFrameType || 0,
      sprayId: this.character?.sprayId || 0,
    });
  }

  buildCharBrief(camp = 1) {
    return defaultStruct("BulkDataType.CHAR_BRIEF", {
      charData: this.buildPlayerBrief(),
      otherData: this.buildOtherBrief(),
      regionUid: 299001,
      nIp: 0,
      bCamp: camp,
      buffVec: [],
    });
  }

  sendWorldBootstrap() {
    const ch = this.character;
    this.inWorld = true;
    this.world.online.set(this.accountOid, this);

    this.send(
      encodeFrame("WorldMessage.WorldEnterConfirm", {
        m_account_oid: ch.accountOid,
        m_game_token: 1,
      })
    );
    this.send(
      encodeFrame("CharMessage.NotifyCharData", {
        m_charData: this.buildCharBasic(),
        m_currency: ch.currency,
        m_queryUrl: "",
        m_technoVec: [],
      })
    );
    this.send(
      encodeFrame("CharMessage.NotifyCharOption", {
        m_strOption: ch.optionJson || JSON.stringify({ skillSlot: [1, 2, 3, 4, 10, 13], keyBoardSet: [] }),
      })
    );
    this.send(
      encodeFrame("TankMessage.NotifyTankList", {
        m_tankVec: ch.tanks || [],
        m_notifyType: 1,
        m_contType: 0,
      })
    );
    this.sendBags(0);
  }

  sendBags(contType = 0) {
    const bags = this.character?.bags || {};
    const list = contType > 0 ? [contType] : [2, 3, 7];
    for (const c of list) {
      this.send(
        encodeFrame("ItemMessage.NotifyItemList", {
          m_contType: c,
          m_itemVec: bags[String(c)] || [],
          m_notifyType: 1,
        })
      );
    }
  }
}

export class GameWorld {
  constructor(db, config = {}) {
    this.db = db;
    this.gateHost = config.gateHost || "127.0.0.1";
    this.gatePort = config.gatePort || 8080;
    this.online = new Map(); // accountOid -> ClientSession
    this.rooms = new Map(); // roomId -> room
    this.nextRoomId = 1001;
    this.nextSceneId = 5001;
  }

  attachSocket(ws, role) {
    const session = new ClientSession(ws, role, this);
    ws.isAlive = true;
    ws.on("pong", () => {
      ws.isAlive = true;
    });
    // Required 2-byte server greeting before any protocol frames
    session.send(SERVER_GREETING);

    ws.on("message", (data) => {
      ws.isAlive = true;
      try {
        const frames = session.reader.feed(data);
        for (const frame of frames) {
          this._onFrame(session, frame).catch((err) => {
            console.error(`[ws:${role}] handler error:`, err);
          });
        }
      } catch (err) {
        console.error(`[ws:${role}] framing error:`, err.message);
        ws.close(1002);
      }
    });

    ws.on("close", () => {
      this._onDisconnect(session);
    });
  }

  _onDisconnect(session) {
    if (session.battle) {
      session.battle.handleExit(session, 1);
      session.battle = null;
    }
    if (session.roomId) {
      this._leaveRoom(session);
    }
    if (session.accountOid && this.online.get(session.accountOid) === session) {
      this.online.delete(session.accountOid);
    }
  }

  async _onFrame(session, frame) {
    const decoded = decodeFrame(frame);
    if (!decoded.ok) {
      console.warn(`[ws:${session.role}] decode failed type=${decoded.type}: ${decoded.error}`);
      return;
    }
    const { type, value, body } = decoded;

    // 52: RequestProtocolVersion (both login & gate)
    if (type === 52) {
      session.send(VERSION_OK_FRAME);
      return;
    }

    if (session.role === "login") {
      if (type === 51) {
        await this._handleAuthLogin(session, value);
      }
      return;
    }

    // ---- GATE / WORLD ----
    if (type === 54) {
      await this._handleServerLogin(session, value);
      return;
    }
    if (type === 64) {
      await this._handleCreateChar(session, body || frame.subarray(8));
      return;
    }
    if (type === 56) {
      await this._handleWorldEnter(session, value);
      return;
    }
    if (type === 61) {
      const now = Date.now();
      session.send(
        encodeFrame("SystemMessage.NotifyPingGateSvr", {
          m_recvTime: u64Words(now),
          m_time: Math.floor(now / 1000),
        })
      );
      return;
    }

    if (!session.inWorld || !session.character) return;

    switch (type) {
      case 165: // RequestContainerItemMessage
        session.sendBags(value.m_contType || 0);
        break;
      case 200: // ChangeBattleTank
        await this._handleChangeTank(session, value);
        break;
      case 79: // RequestChangeSetting
        session.character = await this.db.updateCharacter(session.accountId, {
          settingFlag: Number(value.m_setting) || 0,
        });
        break;
      case 88: // RequestSetCharOption
        session.character = await this.db.updateCharacter(session.accountId, {
          optionJson: String(value.m_strOption || ""),
        });
        break;
      case 450: // ChatMessage
        this._handleChat(session, value);
        break;
      case 607: // RequestInHall
        session.hallType = Number(value.m_bType) || 2;
        this._sendHallList(session, session.hallType, Number(value.m_iSite) || 0);
        break;
      case 608: // RequestOutHall
        session.hallType = 0;
        break;
      case 604: // RequestPlayerList
        this._sendPlayerList(session, Number(value.m_listType) || 0);
        break;
      case 600: // RequestCreateRoom
        this._handleCreateRoom(session, value);
        break;
      case 601: // RequestJoinRoom
        this._handleJoinRoom(session, value);
        break;
      case 602: // RequestRoomOp
        this._handleRoomOp(session, value);
        break;
      case 603: // RequestSetMap
        this._handleSetMap(session, value);
        break;
      case 304: // RequestSelectTutorMap (training map from lobby)
        this._startSoloMap(session, validMapId(value.m_nMapId));
        break;
      case 605: // SyncLoadAndDelay
        if (session.battle) {
          session.battle.handleLoadProgress(session, Number(value.m_nLoaded) || 0, Number(value.m_nDelay) || 0);
        }
        break;
      case 501: // RequestMoveForward
        if (session.battle) session.battle.handleMove(session, value);
        break;
      case 503: // RequestUseSkill
        if (session.battle) session.battle.handleUseSkill(session, value);
        break;
      case 613: // RequestExitBattleEnd
        if (session.battle) {
          const b = session.battle;
          session.battle = null;
          b.handleExit(session, Number(value.m_type) || 1);
        }
        break;
      default:
        break;
    }
  }

  async _handleAuthLogin(session, value) {
    const username = String(value.m_name || "").trim();
    const token = String(value.m_passwd || "");
    const sess = await this.db.findSessionByAuthToken(username, token);
    if (!sess) {
      session.send(
        encodeFrame("AuthMessage.LoginFail", {
          m_reason: 1,
          m_uOpenTime: 0,
          m_errMsg: "Phiên đăng nhập không hợp lệ hoặc đã hết hạn.",
        })
      );
      return;
    }
    const ch = await this.db.getCharacterByAccount(sess.accountId);
    session.send(
      encodeFrame("AuthMessage.LoginOk", {
        m_sessionkey: sess.sessionKey,
        m_expire_time: Math.floor(new Date(sess.expiresAt).getTime() / 1000),
        m_has_char: ch ? 1 : 0,
        m_nAcctId: sess.accountId,
      })
    );
    session.send(
      encodeFrame("AuthMessage.RegionServerList", {
        m_regions: [
          {
            region_id: 299001,
            region_name: "BangBang",
            gate_realm: this.gateHost,
            gate_port: this.gatePort,
            comm_realm: this.gateHost,
            comm_port: this.gatePort,
            cur_load: 1,
            is_pvp: 1,
            open_time: 0,
          },
        ],
      })
    );
  }

  async _handleServerLogin(session, value) {
    const sess = await this.db.findSessionByKey(value.m_nAcctId, value.m_session);
    if (!sess) {
      session.send(encodeRawFrame(908, Buffer.alloc(0)));
      return;
    }
    session.accountId = sess.accountId;
    session.accountOid = sess.accountId;
    session.username = sess.username;

    const ch = await this.db.getCharacterByAccount(sess.accountId);
    if (!ch) {
      session.send(encodeFrame("CharMessage.NotifyCreateNewChar", {}));
      return;
    }
    session.character = ch;
    session.send(
      encodeFrame("CharMessage.NotifyCharList", {
        m_list: [
          {
            m_basic: session.buildCharBasic(),
            m_charUuid: ch.charUuid,
          },
        ],
      })
    );
  }

  async _handleCreateChar(session, body) {
    if (!session.accountId) return;
    const parsed = parseCreateCharRaw(body);
    if (!parsed) {
      session.send(encodeFrame("CharMessage.CharCreateFail", { m_reason: 0 }));
      return;
    }
    const res = await this.db.createCharacter(session.accountId, parsed.name, parsed.sex);
    if (!res.ok) {
      session.send(encodeFrame("CharMessage.CharCreateFail", { m_reason: res.reason ?? 5 }));
      return;
    }
    session.character = res.character;
    // 1012: Character created OK (8-byte empty body frame)
    session.send(encodeRawFrame(1012, Buffer.alloc(0)));
    session.sendWorldBootstrap();
  }

  async _handleWorldEnter(session) {
    if (!session.accountId) return;
    const ch = session.character || (await this.db.getCharacterByAccount(session.accountId));
    if (!ch) {
      session.send(encodeFrame("WorldMessage.WorldEnterRejected", { m_reason: 1 }));
      return;
    }
    session.character = ch;
    session.sendWorldBootstrap();
  }

  async _handleChangeTank(session, value) {
    const uuid = String(value.m_tankUuid || "");
    const tank = (session.character.tanks || []).find((t) => t.m_tankUuid === uuid);
    if (!tank) return;
    session.character = await this.db.updateCharacter(session.accountId, {
      activeTankUuid: tank.m_tankUuid,
    });
    if (session.roomId && this.rooms.has(session.roomId)) {
      const room = this.rooms.get(session.roomId);
      const member = room.members.get(session.accountOid);
      const selFrame = encodeFrame("SceneMessage.NotifyTankSelected", {
        m_nCharOid: session.accountOid,
        m_nTankId: tank.m_tpltId,
        m_nTankCont: 0,
        m_nTankExt: tank.m_externalId || tankExternalId(tank.m_tpltId),
        m_nSkinFrameType: tank.m_skinFrameType || 0,
        m_nCommandSkill: 0,
      });
      const addFrame = encodeFrame("RoomMessage.NotifyRoomAdd", {
        m_charData: session.buildCharBrief(member?.camp || 1),
        isObserver: 0,
      });
      for (const m of room.members.values()) {
        m.session.send(selFrame);
        m.session.send(addFrame);
      }
    }
  }

  _handleChat(session, value) {
    const contents = {
      ...value.m_contents,
      senderOid: session.accountOid,
      senderUuid: session.character.charUuid,
      sender: session.character.name,
      senderGid: session.accountOid,
    };
    const frame = encodeFrame("ChatMessage.ChatMessage", {
      m_contents: contents,
      m_recvClientTime: value.m_recvClientTime || { lowpart: 0, hipart: 0 },
      m_recvChatTime: u64Words(Date.now()),
    });
    const ch = Number(contents.channel);
    if (ch === 32 || ch === 64) {
      if (session.battle) session.battle.broadcast(frame);
      return;
    }
    if ((ch === 8 || ch === 16) && session.roomId && this.rooms.has(session.roomId)) {
      const room = this.rooms.get(session.roomId);
      for (const m of room.members.values()) {
        if (ch === 8 || m.camp === room.members.get(session.accountOid)?.camp) {
          m.session.send(frame);
        }
      }
      return;
    }
    for (const peer of this.online.values()) {
      peer.send(frame);
    }
  }

  _sendHallList(session, type, site) {
    const roomList = [];
    for (const room of this.rooms.values()) {
      roomList.push({
        m_nRoomId: room.id,
        m_nNum: room.members.size,
        m_nMax: room.max,
        m_mapId: room.mapId,
        m_mode: room.mode,
        m_state: room.battle ? 3 : 1,
        m_isValidate: room.password ? 1 : 0,
        m_type: room.type,
        m_szName: room.name,
        m_nTeamId: 0,
      });
    }
    session.send(
      encodeFrame("RoomMessage.NotifyHallDisplayList", {
        m_roomList: roomList,
        m_sceneList: [],
        m_iSite: site,
        m_bType: type,
      })
    );
  }

  _sendPlayerList(session, listType) {
    const list = [];
    for (const peer of this.online.values()) {
      if (peer.character) list.push(peer.buildPlayerBrief());
    }
    session.send(
      encodeFrame("RoomMessage.NotifyPlayerList", {
        m_listType: listType,
        m_pageNumber: 0,
        m_playerList: list,
      })
    );
  }

  _roomEnterFrame(room) {
    const charVec = [];
    for (const m of room.members.values()) {
      charVec.push({
        bReady: m.ready ? 1 : 0,
        bBattle: room.battle ? 1 : 0,
        charBrief: m.session.buildCharBrief(m.camp),
      });
    }
    return encodeFrame("RoomMessage.EnterRoomOk", {
      m_nRoomId: room.id,
      m_nCreateId: room.hostOid,
      m_nMax: room.max,
      m_nMin: 1,
      m_nObNum: 0,
      m_nPassword: room.password,
      m_szName: room.name,
      m_state: room.battle ? 3 : 1,
      m_bType: room.type,
      m_mode: room.mode,
      roomConfig: {
        m_nMapId: room.mapId,
        m_bBanRobot: 0,
        m_nTankAvailableLevel: 0,
        m_iLadderScetionMin: 0,
        m_iLadderScetionMax: 0,
      },
      charVec,
      observerVec: [],
    });
  }

  _handleCreateRoom(session, value) {
    if (session.roomId) this._leaveRoom(session);
    const id = this.nextRoomId++;
    const mapId = validMapId(value.m_mapId || 4);
    const name = String(value.m_szName || "").trim() || `Phòng của ${session.character.name}`;
    const room = {
      id,
      hostOid: session.accountOid,
      name,
      type: Number(value.m_bType) || 2,
      mode: Number(value.m_bMode) || 0,
      mapId,
      password: Number(value.m_passWord) || 0,
      max: 10,
      members: new Map(),
      battle: null,
    };
    room.members.set(session.accountOid, { session, camp: 1, ready: true });
    this.rooms.set(id, room);
    session.roomId = id;
    session.send(this._roomEnterFrame(room));
  }

  _handleJoinRoom(session, value) {
    const room = this.rooms.get(Number(value.m_nRoomId));
    if (!room || room.members.size >= room.max) return;
    if (room.password && Number(value.m_nPassword) !== room.password) return;
    if (session.roomId) this._leaveRoom(session);

    let c1 = 0, c2 = 0;
    for (const m of room.members.values()) {
      if (m.camp === 1) c1++;
      else c2++;
    }
    const camp = c1 <= c2 ? 1 : 2;
    room.members.set(session.accountOid, { session, camp, ready: false });
    session.roomId = room.id;

    session.send(this._roomEnterFrame(room));
    const joinNote = encodeFrame("RoomMessage.NotifyRoomAdd", {
      m_charData: session.buildCharBrief(camp),
      isObserver: 0,
    });
    for (const [oid, m] of room.members) {
      if (oid !== session.accountOid) m.session.send(joinNote);
    }
  }

  _leaveRoom(session) {
    const room = this.rooms.get(session.roomId);
    session.roomId = 0;
    if (!room) return;
    const leaveFrame = encodeFrame("RoomMessage.NotifyRoomOp", {
      m_roomOp: 1,
      m_nStartOid: session.accountOid,
      m_nTarget: session.accountOid,
    });
    for (const m of room.members.values()) {
      m.session.send(leaveFrame);
    }
    room.members.delete(session.accountOid);
    if (room.members.size === 0) {
      if (room.battle) room.battle.stop();
      this.rooms.delete(room.id);
      return;
    }
    if (room.hostOid === session.accountOid) {
      const [nextHost] = room.members.keys();
      room.hostOid = nextHost;
      const hostFrame = encodeFrame("RoomMessage.NotifyRoomOp", {
        m_roomOp: 26,
        m_nStartOid: nextHost,
        m_nTarget: nextHost,
      });
      for (const m of room.members.values()) m.session.send(hostFrame);
    }
  }

  _handleSetMap(session, value) {
    const room = this.rooms.get(session.roomId);
    if (!room || room.hostOid !== session.accountOid) return;
    room.mapId = validMapId(value.m_nMapId);
    const frame = encodeFrame("RoomMessage.NotifyRoomMap", { m_nMapId: room.mapId });
    for (const m of room.members.values()) m.session.send(frame);
  }

  _handleRoomOp(session, value) {
    const room = this.rooms.get(session.roomId);
    if (!room) return;
    const op = Number(value.m_roomOp);
    const target = Number(value.m_nTarget) || 0;
    const member = room.members.get(session.accountOid);
    if (!member) return;

    if (op === 1) {
      this._leaveRoom(session);
      return;
    }
    if (op === 2 || op === 3) {
      member.ready = op === 2;
      const frame = encodeFrame("RoomMessage.NotifyRoomOp", {
        m_roomOp: op,
        m_nStartOid: session.accountOid,
        m_nTarget: session.accountOid,
      });
      for (const m of room.members.values()) m.session.send(frame);
      return;
    }
    if (op === 4) {
      member.camp = member.camp === 1 ? 2 : 1;
      const frame = encodeFrame("RoomMessage.NotifyRoomOp", {
        m_roomOp: 4,
        m_nStartOid: session.accountOid,
        m_nTarget: session.accountOid,
      });
      for (const m of room.members.values()) m.session.send(frame);
      return;
    }
    if (op === 20 && room.hostOid === session.accountOid && target !== session.accountOid && room.members.has(target)) {
      const kicked = room.members.get(target).session;
      const frame = encodeFrame("RoomMessage.NotifyRoomOp", {
        m_roomOp: 20,
        m_nStartOid: session.accountOid,
        m_nTarget: target,
      });
      for (const m of room.members.values()) m.session.send(frame);
      room.members.delete(target);
      kicked.roomId = 0;
      return;
    }
    if (op === 24 && room.hostOid === session.accountOid) {
      this._startRoomBattle(room);
    }
  }

  _startRoomBattle(room) {
    if (room.battle) return;
    const sceneId = this.nextSceneId++;
    const battle = new BattleSession({
      sceneId,
      room,
      db: this.db,
      onFinished: () => {
        if (room.battle === battle) room.battle = null;
      },
    });
    room.battle = battle;
    const list = [...room.members.values()];
    for (const m of list) m.session.battle = battle;
    battle.initParticipants(list);
  }

  _startSoloMap(session, mapId) {
    const fakeRoom = {
      id: 0,
      hostOid: session.accountOid,
      name: "Huấn luyện",
      type: 2,
      mode: 0,
      mapId,
      members: new Map([[session.accountOid, { session, camp: 1, ready: true }]]),
      battle: null,
    };
    const sceneId = this.nextSceneId++;
    const battle = new BattleSession({
      sceneId,
      room: fakeRoom,
      db: this.db,
    });
    session.battle = battle;
    battle.initParticipants([...fakeRoom.members.values()]);
  }
}
