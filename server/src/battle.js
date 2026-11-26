import crypto from "crypto";
import { encodeFrame, u64Words } from "./protocol.js";
import { loadMapInfo, tankExternalId, tankSkills } from "./catalog.js";

const STEPS = [
  [-24, -24], [0, -24], [24, -24], [24, 0],
  [24, 24], [0, 24], [-24, 24], [-24, 0], [0, 0],
];

const TICK_MS = 50;
const DEFAULT_SPEED = 180;
const DEFAULT_FIRE_RATE = 450;
const BULLET_SPEED = 620;
const HIT_RADIUS = 38;
const RESPAWN_MS = 3500;
const BOT_OID_BASE = 9000001;

export class BattleSession {
  constructor({ sceneId, room, db, onFinished }) {
    this.sceneId = sceneId;
    this.sceneUuid = `scene-${sceneId}-${crypto.randomBytes(4).toString("hex")}`;
    this.room = room;
    this.db = db;
    this.onFinished = onFinished;
    this.mapInfo = loadMapInfo(room.mapId || 4);
    this.mapId = this.mapInfo.id;
    this.roomType = room.type || 2;
    this.started = false;
    this.ended = false;
    this.startedAt = 0;
    this.nextBulletId = 1;
    this.tanks = new Map(); // objId -> tank runtime state
    this.bullets = new Map(); // bulletId -> bullet runtime state
    this.loaded = new Set(); // human accountOids loaded
    this.humanSessions = new Map(); // accountOid -> wsSession
    this.campKills = { 1: 0, 2: 0 };
    this.firstBloodDone = false;
    this.killTarget = Math.min(10, Math.max(3, this.mapInfo.killTarget || 10));
    this.timer = null;
    this.loadFallbackTimer = null;
    this.pendingMoves = [];
    this.pendingFires = [];
    this.pendingSkills = [];
    this.pendingHps = [];
    this.pendingBlowUps = [];
    this.pendingDels = [];
    this.pendingHpChanges = [];
  }

  _pickSpawn(camp, index) {
    const list = this.mapInfo.spawns[camp] || this.mapInfo.spawns[1];
    const pt = list[index % list.length];
    return { x: pt.x, y: pt.y };
  }

  initParticipants(members) {
    const briefs = [];
    let camp1Idx = 0;
    let camp2Idx = 0;
    const campsPresent = new Set();

    for (const m of members) {
      const camp = m.camp === 2 ? 2 : 1;
      campsPresent.add(camp);
      const spawn = this._pickSpawn(camp, camp === 1 ? camp1Idx++ : camp2Idx++);
      const oid = m.session.accountOid;
      const activeTank = m.session.activeTank();
      const tankTpl = activeTank?.m_tpltId || 10000001;
      const maxHp = 2200 + (activeTank?.m_level || 1) * 180;
      const skills = tankSkills(tankTpl);

      this.humanSessions.set(oid, m.session);
      this.tanks.set(oid, {
        objId: oid,
        acctOid: oid,
        isBot: false,
        name: m.session.character.name,
        camp,
        tankTpl,
        externalId: activeTank?.m_externalId || tankExternalId(tankTpl),
        tankLevel: activeTank?.m_level || 1,
        x: spawn.x,
        y: spawn.y,
        dir: camp === 1 ? 3 : 7,
        hp: maxHp,
        maxHp,
        mp: 1000,
        maxMp: 1000,
        shield: 0,
        speed: DEFAULT_SPEED,
        fireRate: DEFAULT_FIRE_RATE,
        skills,
        skillReadyAt: new Map(),
        dead: false,
        respawnAt: 0,
        kills: 0,
        deaths: 0,
        assists: 0,
        damage: 0,
        streak: 0,
      });
      briefs.push(m.session.buildCharBrief(camp));
    }

    // Solo play support: spawn an AI enemy tank if only 1 camp has humans
    if (campsPresent.size < 2) {
      const botCamp = campsPresent.has(1) ? 2 : 1;
      const botOid = BOT_OID_BASE + (this.sceneId % 1000);
      const botTpl = 10000003; // Panda bot
      const botExt = tankExternalId(botTpl);
      const spawn = this._pickSpawn(botCamp, 0);
      this.tanks.set(botOid, {
        objId: botOid,
        acctOid: botOid,
        isBot: true,
        name: "Bot Tập Bắn",
        camp: botCamp,
        tankTpl: botTpl,
        externalId: botExt,
        tankLevel: 3,
        x: spawn.x,
        y: spawn.y,
        dir: botCamp === 1 ? 3 : 7,
        hp: 1800,
        maxHp: 1800,
        mp: 1000,
        maxMp: 1000,
        shield: 0,
        speed: 130,
        fireRate: 1400,
        skills: tankSkills(botTpl),
        skillReadyAt: new Map(),
        dead: false,
        respawnAt: 0,
        kills: 0,
        deaths: 0,
        assists: 0,
        damage: 0,
        streak: 0,
        botMoveAt: 0,
        botFireAt: 0,
      });
      briefs.push({
        charData: {
          nAcctId: botOid,
          szCharUuid: `bot-${botOid}`,
          szName: "Bot Tập Bắn",
          bLevel: 5,
          bSex: 1,
          nVipLevel: 0,
          eloSectionId: 0,
          preEloSectionId: 0,
          nAvatar: 2801001,
          nDecorateId: 0,
          nGraduate: 0,
          iElo: 1000,
          nHonorId: 0,
          nBoosterAttack: 0,
          nMilitaryStar: 0,
          nTeamPlace: 0,
          szTeamName: "",
        },
        otherData: {
          tankId: botTpl,
          tankLevel: 3,
          tryTank: 0,
          btItemId: 0,
          btRank: 0,
          btLevel: 0,
          btUpLevel: 0,
          btUpCost: 0,
          btRankCost: 0,
          honorId: 0,
          tankExternal: botExt,
          haloId: 0,
          skinFrameType: 0,
          btAtk: 0,
          tankPartScore: 0,
          commandSkill: 0,
          sprayId: 0,
        },
        regionUid: 299001,
        nIp: 0,
        bCamp: botCamp,
        buffVec: [],
      });
    }

    const startPacket = encodeFrame("RoomMessage.NotifyStartGame", {
      m_nSceneId: this.sceneId,
      m_nMapId: this.mapId,
      m_type: this.roomType,
      m_charData: briefs,
      m_backData: [],
      m_bEnterType: 0,
    });
    this.broadcast(startPacket);

    // Fallback: start battle after 4 seconds even if a client is slow loading
    this.loadFallbackTimer = setTimeout(() => {
      if (!this.started && !this.ended) this._beginBattle();
    }, 4000);
  }

  _tankInfoStruct(t) {
    return {
      m_objId: t.objId,
      m_acctOid: t.acctOid,
      m_x: Math.round(t.x),
      m_y: Math.round(t.y),
      m_hp: t.hp,
      m_maxHp: t.maxHp,
      m_iStar: 1,
      m_iCamp: t.camp,
      m_name: t.name,
      m_buffVec: [],
      m_lifeCount: 0,
      m_curBattleExp: 0,
      m_battleLevel: 1,
      m_tankLevel: t.tankLevel,
      m_mp: t.mp,
      m_maxMp: t.maxMp,
      m_shield: t.shield,
    };
  }

  _propsStruct(skill, endMs = 0) {
    return {
      nPropsId: skill.id,
      bSlotno: skill.slot,
      iCount: 1,
      nEndTime: u64Words(endMs),
      nCountCoolTime: u64Words(skill.cdMs),
    };
  }

  handleLoadProgress(session, loaded, delay) {
    if (this.ended) return;
    const oid = session.accountOid;
    const note = encodeFrame("RoomMessage.NotifyLoadedRate", {
      m_nTankId: oid,
      m_nDelay: delay || 0,
      m_nLoaded: loaded || 0,
    });
    this.broadcast(note);
    if (loaded >= 100) {
      this.loaded.add(oid);
      if (!this.started && this.loaded.size >= this.humanSessions.size) {
        this._beginBattle();
      }
    }
  }

  _beginBattle() {
    if (this.started || this.ended) return;
    this.started = true;
    if (this.loadFallbackTimer) {
      clearTimeout(this.loadFallbackTimer);
      this.loadFallbackTimer = null;
    }
    this.startedAt = Date.now();
    const startSec = Math.floor(this.startedAt / 1000);

    for (const [oid, session] of this.humanSessions) {
      const me = this.tanks.get(oid);
      if (!me) continue;
      session.send(
        encodeFrame("TankMessage.NotifySelfData", {
          m_selfData: this._tankInfoStruct(me),
          m_fireRate: me.fireRate,
          m_speed: me.speed,
          m_skillVec: me.skills.map((s) => this._propsStruct(s, 0)),
          m_itemVec: [],
          m_nKillCount: me.kills,
          m_nDeadCount: me.deaths,
          m_nAssistCount: me.assists,
        })
      );
      const others = [];
      for (const [otherId, t] of this.tanks) {
        if (otherId !== oid) others.push(this._tankInfoStruct(t));
      }
      session.send(encodeFrame("TankMessage.NotifyOtherList", { m_otherList: others }));
      session.send(
        encodeFrame("SceneMessage.NotifyBattleEnter", {
          m_nStartTime: startSec,
          m_bOverTime: 0,
        })
      );
    }

    this.timer = setInterval(() => this._tick(), TICK_MS);
  }

  handleMove(session, msg) {
    if (!this.started || this.ended) return;
    const t = this.tanks.get(session.accountOid);
    if (!t || t.dead) return;
    const dir = Number(msg.m_direction);
    if (dir < 0 || dir > 7) return;
    const [dx, dy] = STEPS[dir];
    const startX = Number(msg.m_start_x);
    const startY = Number(msg.m_start_y);
    // Trust reasonable client grid steps clamped inside map bounds
    const baseX = Math.abs(startX - t.x) <= 96 ? startX : t.x;
    const baseY = Math.abs(startY - t.y) <= 96 ? startY : t.y;
    const nx = Math.max(24, Math.min(this.mapInfo.width - 24, baseX + dx));
    const ny = Math.max(24, Math.min(this.mapInfo.height - 24, baseY + dy));
    t.x = nx;
    t.y = ny;
    t.dir = dir;
    this.pendingMoves.push({
      m_objId: t.objId,
      m_x: Math.round(nx),
      m_y: Math.round(ny),
      m_speed: t.speed,
      m_direction: dir,
      m_moveType: 0,
    });
  }

  handleUseSkill(session, msg) {
    if (!this.started || this.ended) return;
    const t = this.tanks.get(session.accountOid);
    if (!t || t.dead) return;
    const slot = Number(msg.m_soltNo);
    const skill = t.skills.find((s) => s.slot === slot) || t.skills[0];
    if (!skill) return;
    const now = Date.now();
    const readyAt = t.skillReadyAt.get(slot) || 0;
    if (now < readyAt - 60) return;

    const endMs = now + skill.cdMs;
    t.skillReadyAt.set(slot, endMs);

    const destX = Math.max(0, Math.min(this.mapInfo.width, Number(msg.m_destX) || t.x + 200));
    const destY = Math.max(0, Math.min(this.mapInfo.height, Number(msg.m_destY) || t.y));
    const damage = slot === 0 ? 220 : slot === 2 ? 520 : 340;
    this._spawnBullet(t, skill.id, destX, destY, damage);

    if (slot !== 0) {
      this.pendingSkills.push({
        m_nCasterId: t.objId,
        m_nTargetId: Number(msg.m_targetId) || 0,
        m_nSkillId: skill.id,
        m_StartX: Math.round(t.x),
        m_StartY: Math.round(t.y),
        m_x: Math.round(destX),
        m_y: Math.round(destY),
        m_isReady: 0,
        m_nCount: 1,
      });
      this.broadcast(
        encodeFrame("TankMessage.SyncSkillCooltime", {
          m_nPropData: this._propsStruct(skill, endMs),
          m_nOwnerId: t.objId,
        })
      );
    }
  }

  _spawnBullet(shooter, templateId, destX, destY, damage) {
    const dx = destX - shooter.x;
    const dy = destY - shooter.y;
    const dist = Math.hypot(dx, dy);
    const maxRange = 640;
    let tx = destX;
    let ty = destY;
    if (dist < 1) {
      tx = shooter.x + 300;
      ty = shooter.y;
    } else if (dist > maxRange) {
      tx = shooter.x + (dx / dist) * maxRange;
      ty = shooter.y + (dy / dist) * maxRange;
    }
    const bulletId = this.nextBulletId++;
    const speed = BULLET_SPEED;
    this.bullets.set(bulletId, {
      id: bulletId,
      shooterId: shooter.objId,
      camp: shooter.camp,
      templateId,
      x: shooter.x,
      y: shooter.y,
      destX: tx,
      destY: ty,
      speed,
      damage,
    });
    this.pendingFires.push({
      m_bullteId: bulletId,
      m_objId: shooter.objId,
      m_startX: Math.round(shooter.x),
      m_startY: Math.round(shooter.y),
      m_destX: Math.round(tx),
      m_destY: Math.round(ty),
      m_iSpeed: speed,
      m_nTemplate: templateId,
    });
  }

  _tickBot(bot, now) {
    if (bot.dead) return;
    // Find nearest living enemy
    let target = null;
    let bestDist = Infinity;
    for (const other of this.tanks.values()) {
      if (other.dead || other.camp === bot.camp) continue;
      const d = Math.hypot(other.x - bot.x, other.y - bot.y);
      if (d < bestDist) {
        bestDist = d;
        target = other;
      }
    }
    if (!target) return;

    if (now >= (bot.botMoveAt || 0)) {
      bot.botMoveAt = now + 260;
      const angle = Math.atan2(target.y - bot.y, target.x - bot.x);
      let dir;
      if (bestDist > 260) {
        dir = ((Math.round(angle / (Math.PI / 4)) + 3) % 8 + 8) % 8;
      } else {
        dir = ((Math.round((angle + Math.PI / 2) / (Math.PI / 4)) + 3) % 8 + 8) % 8;
      }
      const [dx, dy] = STEPS[dir];
      const nx = Math.max(48, Math.min(this.mapInfo.width - 48, bot.x + dx));
      const ny = Math.max(48, Math.min(this.mapInfo.height - 48, bot.y + dy));
      bot.x = nx;
      bot.y = ny;
      bot.dir = dir;
      this.pendingMoves.push({
        m_objId: bot.objId,
        m_x: Math.round(nx),
        m_y: Math.round(ny),
        m_speed: bot.speed,
        m_direction: dir,
        m_moveType: 0,
      });
    }

    if (bestDist <= 540 && now >= (bot.botFireAt || 0)) {
      bot.botFireAt = now + bot.fireRate;
      this._spawnBullet(bot, 1, target.x, target.y, 120);
    }
  }

  _tick() {
    if (this.ended) return;
    const now = Date.now();
    const dt = TICK_MS / 1000;

    // 1. Respawns & Bots
    for (const t of this.tanks.values()) {
      if (t.dead && now >= t.respawnAt) {
        const spawn = this._pickSpawn(t.camp, Math.floor(Math.random() * 6));
        t.dead = false;
        t.hp = t.maxHp;
        t.mp = t.maxMp;
        t.x = spawn.x;
        t.y = spawn.y;
        this.broadcast(encodeFrame("TankMessage.NotifyAddTank", { m_selfData: this._tankInfoStruct(t) }));
      } else if (t.isBot) {
        this._tickBot(t, now);
      }
    }

    // 2. Bullets movement & collision
    for (const [id, b] of this.bullets) {
      const dx = b.destX - b.x;
      const dy = b.destY - b.y;
      const rem = Math.hypot(dx, dy);
      const step = b.speed * dt;
      if (rem <= step) {
        b.x = b.destX;
        b.y = b.destY;
      } else {
        b.x += (dx / rem) * step;
        b.y += (dy / rem) * step;
      }

      let hitTarget = null;
      for (const t of this.tanks.values()) {
        if (t.dead || t.camp === b.camp) continue;
        if (Math.hypot(t.x - b.x, t.y - b.y) <= HIT_RADIUS) {
          hitTarget = t;
          break;
        }
      }

      if (hitTarget) {
        this.bullets.delete(id);
        this.pendingBlowUps.push(id);
        this._applyDamage(b.shooterId, hitTarget, b.damage, b.templateId, now);
      } else if (rem <= step) {
        this.bullets.delete(id);
        this.pendingDels.push(id);
      }
    }

    // 3. Flush sync packet (1564) and HP delta popups (1605)
    if (this.pendingHpChanges.length > 0) {
      this.broadcast(encodeFrame("SceneMessage.SyncHpChange", { m_hpChgInfoVec: this.pendingHpChanges }));
      this.pendingHpChanges = [];
    }
    if (
      this.pendingMoves.length > 0 ||
      this.pendingFires.length > 0 ||
      this.pendingSkills.length > 0 ||
      this.pendingHps.length > 0 ||
      this.pendingBlowUps.length > 0 ||
      this.pendingDels.length > 0
    ) {
      this.broadcast(
        encodeFrame("SceneMessage.SyncSceneData", {
          m_moveVec: this.pendingMoves,
          m_fireVec: this.pendingFires,
          m_skillVec: this.pendingSkills,
          m_hpVec: this.pendingHps,
          m_deadVec: [],
          m_mpVec: [],
          m_blowUpVec: this.pendingBlowUps,
          m_delVec: this.pendingDels,
          m_overVec: [],
          m_shieldVec: [],
        })
      );
      this.pendingMoves = [];
      this.pendingFires = [];
      this.pendingSkills = [];
      this.pendingHps = [];
      this.pendingBlowUps = [];
      this.pendingDels = [];
    }

    // 4. Match end check (kill target or timer)
    const elapsedSec = (now - this.startedAt) / 1000;
    if (this.campKills[1] >= this.killTarget) {
      this.finish(1);
    } else if (this.campKills[2] >= this.killTarget) {
      this.finish(2);
    } else if (elapsedSec >= this.mapInfo.duration) {
      this.finish(this.campKills[1] >= this.campKills[2] ? 1 : 2);
    }
  }

  _applyDamage(shooterId, victim, amount, skillId, now) {
    const dmg = Math.max(1, Math.round(amount));
    victim.hp = Math.max(0, victim.hp - dmg);
    const shooter = this.tanks.get(shooterId);
    if (shooter) shooter.damage += dmg;
    this.pendingHps.push({ m_objId: victim.objId, m_objHp: victim.hp });
    this.pendingHpChanges.push({
      m_objId: victim.objId,
      m_objHp: -dmg,
      m_nFury: 0,
      m_casterId: shooterId,
    });

    if (victim.hp === 0 && !victim.dead) {
      victim.dead = true;
      victim.deaths += 1;
      victim.streak = 0;
      victim.respawnAt = now + RESPAWN_MS;
      const isFirstBlood = !this.firstBloodDone ? 1 : 0;
      this.firstBloodDone = true;
      if (shooter) {
        shooter.kills += 1;
        shooter.streak += 1;
        this.campKills[shooter.camp] = (this.campKills[shooter.camp] || 0) + 1;
      }
      this.broadcast(
        encodeFrame("SceneMessage.NotifyKillInfo", {
          m_killInfo: {
            m_killerObjId: shooterId,
            m_deadObjId: victim.objId,
            m_skillId: skillId,
            m_dead_x: Math.round(victim.x),
            m_dead_y: Math.round(victim.y),
            m_contKillCount: shooter?.streak || 1,
            m_killerKillCount: shooter?.kills || 1,
            m_deadKillCount: victim.deaths,
            m_isFirstBlood: isFirstBlood,
            m_assistTankId: [],
          },
        })
      );
      this.broadcast(
        encodeFrame("TankMessage.NotifyTankRelive", {
          m_acctOid: victim.objId,
          m_iReliveTime: RESPAWN_MS,
        })
      );
    }
  }

  async finish(winCamp) {
    if (this.ended) return;
    this.ended = true;
    this.stop();
    const battleTime = Math.max(1, Math.floor((Date.now() - (this.startedAt || Date.now())) / 1000));
    const tankVec = [];
    for (const t of this.tanks.values()) {
      const won = t.camp === winCamp ? 1 : 0;
      tankVec.push({
        m_charOid: t.acctOid,
        m_tankTpltId: t.tankTpl,
        m_iStatData: [t.deaths, t.kills, t.kills * 100 + Math.floor(t.damage / 50), t.assists, 0, 0, t.damage],
        m_iTeamMerit: won ? 20 : 10,
        m_iOldElo: 1000,
        m_iNewElo: won ? 1015 : 995,
        m_iTankGains: 0,
        m_iNewTankGains: 0,
        m_bAward: 1,
        m_isWin: won,
        m_iRobotType: t.isBot ? 1 : 0,
        m_eloSectionId: 1,
        m_battleLevel: 1,
        m_roomCount: this.tanks.size,
        m_camp: t.camp,
        m_expVec: [{ m_type: 1, m_value: won ? 200 : 100 }],
        m_coinVec: [{ m_type: 2, m_value: won ? 300 : 150 }],
        m_tankExpVec: [],
        m_itemVec: [],
        m_evalPve: { m_iTotalEval: 0, m_iHarmEval: 0, m_iDeadEval: 0, m_iTimeEval: 0, m_iBoosterEval: 0 },
      });
    }
    this.broadcast(
      encodeFrame("SceneMessage.NotifyBattleEnd", {
        m_nSceneId: this.sceneId,
        m_nMapId: this.mapId,
        m_battleTime: battleTime,
        m_roomType: this.roomType,
        m_winCamp: winCamp,
        m_winType: 1,
        m_rebLifeCount: 0,
        m_buleLifeCount: 0,
        m_tankVec: tankVec,
        m_escapeVec: [],
        m_svrExpRate: 1.0,
        m_tokengoldRate: 1.0,
        m_bpvpActOpen: 0,
        m_nItemDropRate: 100,
        m_nKiller: 0,
        m_nAssister: 0,
        m_nKDA: 0,
        m_nDestroyer: 0,
        m_nVictoryMvp: 0,
        m_nDefeatMvp: 0,
        m_sceneUuid: this.sceneUuid,
      })
    );

    try {
      await this.db.recordMatch({
        sceneUuid: this.sceneUuid,
        mapId: this.mapId,
        roomType: this.roomType,
        battleTime,
        winCamp,
        players: [...this.tanks.values()].map((t) => ({
          oid: t.acctOid,
          name: t.name,
          camp: t.camp,
          tankTpl: t.tankTpl,
          kills: t.kills,
          deaths: t.deaths,
          damage: t.damage,
          isBot: t.isBot,
        })),
      });
    } catch (err) {
      console.error("[battle] failed to record match:", err.message);
    }

    if (typeof this.onFinished === "function") this.onFinished(this);
  }

  handleExit(session, exitType = 1) {
    const oid = session.accountOid;
    session.send(
      encodeFrame("SceneMessage.NotifyExitBattle", {
        m_nErrId: 0,
        m_nSceneId: this.sceneId,
        m_nCharId: oid,
        m_exitType: exitType,
        m_isLook: 0,
      })
    );
    this.humanSessions.delete(oid);
    if (this.humanSessions.size === 0) {
      this.ended = true;
      this.stop();
      if (typeof this.onFinished === "function") this.onFinished(this);
    }
  }

  broadcast(buf) {
    for (const s of this.humanSessions.values()) {
      s.send(buf);
    }
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
    if (this.loadFallbackTimer) {
      clearTimeout(this.loadFallbackTimer);
      this.loadFallbackTimer = null;
    }
  }
}
