import crypto from "crypto";
import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { MongoClient } from "mongodb";
import { STARTER_TANKS, tankExternalId } from "./catalog.js";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const LOCAL_STORE_PATH = path.resolve(__dirname, "../data/local_store.json");

function hashPassword(password, saltHex = crypto.randomBytes(16).toString("hex")) {
  const hash = crypto.scryptSync(String(password), saltHex, 32).toString("hex");
  return { salt: saltHex, hash };
}

function verifyPassword(password, salt, expectedHash) {
  if (!salt || !expectedHash) return false;
  const actual = crypto.scryptSync(String(password), salt, 32);
  const expected = Buffer.from(expectedHash, "hex");
  return actual.length === expected.length && crypto.timingSafeEqual(actual, expected);
}

function makeStarterTanks(accountOid) {
  const nowSec = Math.floor(Date.now() / 1000);
  return STARTER_TANKS.map((tplId, idx) => ({
    m_tankUuid: `tank-${accountOid}-${tplId}`,
    m_tpltId: tplId,
    m_level: idx === 0 ? 5 : 3,
    m_nExp: 0,
    m_extFlag: 0,
    m_stthLevel: 0,
    m_externalId: tankExternalId(tplId),
    m_warCount: 0,
    m_weekWarCount: 0,
    m_contType: 0,
    m_cashHireCount: 0,
    m_coinHireCount: 0,
    m_existTime: 0,
    m_haloId: 0,
    m_skinFrameType: 0,
    m_ownTime: nowSec,
    m_stthCount: 0,
    m_comSkillId: 0,
    m_crystalSchemeId: 0,
    m_talPageUuid: "",
    m_proficiencyVal: 0,
    m_battleGains: 0,
  }));
}

function makeCharacterDoc({ accountId, name, sex }) {
  const nowSec = Math.floor(Date.now() / 1000);
  const accountOid = accountId;
  const charUuid = `char-${accountId}-${crypto.randomBytes(4).toString("hex")}`;
  const tanks = makeStarterTanks(accountOid);
  return {
    accountId,
    accountOid,
    charUuid,
    name,
    nameLower: name.toLowerCase(),
    sex: sex === 2 ? 2 : 1,
    level: 10,
    exp: 0,
    milLevel: 1,
    milExp: 0,
    avatarId: sex === 2 ? 2801002 : 2801001,
    decorateId: 0,
    sprayId: 0,
    thew: 200,
    thewBuy: 0,
    settingFlag: 0,
    gmLevel: 1,
    createTime: nowSec,
    onlineTime: 0,
    currency: {
      m_iCash: 5000,
      m_iGolden: 10000,
      m_iSilver: 50000,
      m_iHonor: 1000,
      m_icrystal: 1000,
      m_iPresentPoint: 0,
    },
    tanks,
    activeTankUuid: tanks[0].m_tankUuid,
    bags: { "2": [], "3": [], "7": [] },
    optionJson: JSON.stringify({ skillSlot: [1, 2, 3, 4, 10, 13], keyBoardSet: [] }),
    createdAt: new Date(),
    updatedAt: new Date(),
  };
}

export class Database {
  constructor() {
    this.mode = "local";
    this.client = null;
    this.db = null;
    this.local = {
      nextAccountId: 10001,
      accounts: [],
      characters: [],
      sessions: [],
      matches: [],
    };
  }

  async init({ uri, dbName = "bangbang", required = false } = {}) {
    const cleanUri = String(uri || "").trim();
    const isPlaceholder = !cleanUri || cleanUri.includes("<db_password>") || cleanUri.includes("<password>");
    if (!isPlaceholder) {
      try {
        this.client = new MongoClient(cleanUri, {
          serverSelectionTimeoutMS: 8000,
          connectTimeoutMS: 8000,
        });
        await this.client.connect();
        this.db = this.client.db(dbName);
        await this.db.command({ ping: 1 });
        await this._ensureIndexes();
        this.mode = "mongodb";
        console.log(`[db] Connected to MongoDB Atlas (database: ${dbName})`);
        return;
      } catch (err) {
        if (required) throw err;
        console.warn(`[db] MongoDB connection failed (${err.message}); falling back to local JSON store.`);
        try {
          await this.client?.close();
        } catch {}
        this.client = null;
        this.db = null;
      }
    } else if (required) {
      throw new Error("MONGODB_URI is not configured (still contains placeholder or empty).");
    } else {
      console.warn("[db] MONGODB_URI not configured yet (replace <db_password> in server/.env) -> using local JSON store.");
    }
    this._loadLocal();
    this.mode = "local";
  }

  async _ensureIndexes() {
    await this.db.collection("accounts").createIndex({ usernameLower: 1 }, { unique: true });
    await this.db.collection("accounts").createIndex({ accountId: 1 }, { unique: true });
    await this.db.collection("characters").createIndex({ accountId: 1 }, { unique: true });
    await this.db.collection("characters").createIndex({ nameLower: 1 }, { unique: true });
    await this.db.collection("characters").createIndex({ charUuid: 1 }, { unique: true });
    await this.db.collection("sessions").createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 });
    await this.db.collection("sessions").createIndex({ authToken: 1 });
    await this.db.collection("sessions").createIndex({ sessionKey: 1 });
    await this.db.collection("matches").createIndex({ endedAt: -1 });
  }

  _loadLocal() {
    try {
      if (fs.existsSync(LOCAL_STORE_PATH)) {
        const parsed = JSON.parse(fs.readFileSync(LOCAL_STORE_PATH, "utf8"));
        this.local = {
          nextAccountId: Number(parsed.nextAccountId) || 10001,
          accounts: Array.isArray(parsed.accounts) ? parsed.accounts : [],
          characters: Array.isArray(parsed.characters) ? parsed.characters : [],
          sessions: Array.isArray(parsed.sessions) ? parsed.sessions : [],
          matches: Array.isArray(parsed.matches) ? parsed.matches : [],
        };
      }
    } catch {
      // start fresh
    }
  }

  _saveLocal() {
    if (this.mode !== "local") return;
    fs.mkdirSync(path.dirname(LOCAL_STORE_PATH), { recursive: true });
    const tmp = `${LOCAL_STORE_PATH}.tmp`;
    fs.writeFileSync(tmp, JSON.stringify(this.local, null, 2), "utf8");
    fs.renameSync(tmp, LOCAL_STORE_PATH);
  }

  async _nextAccountId() {
    if (this.mode === "mongodb") {
      const res = await this.db.collection("counters").findOneAndUpdate(
        { _id: "accountId" },
        { $inc: { seq: 1 } },
        { upsert: true, returnDocument: "after" }
      );
      return 10000 + Number(res.seq || 1);
    }
    const id = this.local.nextAccountId++;
    this._saveLocal();
    return id;
  }

  async createAccount(username, password) {
    const clean = String(username || "").trim();
    const lower = clean.toLowerCase();
    if (!/^[A-Za-z0-9_.-]{3,32}$/.test(clean)) {
      return { ok: false, code: "INVALID_USERNAME", error: "Tài khoản 3-32 ký tự (chữ, số, _, ., -)." };
    }
    if (String(password || "").length < 4 || String(password || "").length > 128) {
      return { ok: false, code: "INVALID_PASSWORD", error: "Mật khẩu tối thiểu 4 ký tự." };
    }
    const existing = await this.findAccountByUsername(clean);
    if (existing) {
      return { ok: false, code: "EXISTS", error: "Tài khoản đã tồn tại." };
    }
    const accountId = await this._nextAccountId();
    const { salt, hash } = hashPassword(password);
    const doc = {
      accountId,
      username: clean,
      usernameLower: lower,
      passwordHash: hash,
      salt,
      createdAt: new Date(),
      lastLoginAt: new Date(),
    };
    if (this.mode === "mongodb") {
      try {
        await this.db.collection("accounts").insertOne(doc);
      } catch (err) {
        if (err?.code === 11000) {
          return { ok: false, code: "EXISTS", error: "Tài khoản đã tồn tại." };
        }
        throw err;
      }
    } else {
      this.local.accounts.push(doc);
      this._saveLocal();
    }
    return { ok: true, account: doc };
  }

  async findAccountByUsername(username) {
    const lower = String(username || "").trim().toLowerCase();
    if (!lower) return null;
    if (this.mode === "mongodb") {
      return await this.db.collection("accounts").findOne({ usernameLower: lower });
    }
    return this.local.accounts.find((a) => a.usernameLower === lower) || null;
  }

  async authenticate(username, password) {
    const acct = await this.findAccountByUsername(username);
    if (!acct) {
      return { ok: false, code: "INVALID_CREDENTIALS", error: "Sai tài khoản hoặc mật khẩu." };
    }
    if (!verifyPassword(password, acct.salt, acct.passwordHash)) {
      return { ok: false, code: "INVALID_CREDENTIALS", error: "Sai tài khoản hoặc mật khẩu." };
    }
    if (this.mode === "mongodb") {
      await this.db.collection("accounts").updateOne(
        { accountId: acct.accountId },
        { $set: { lastLoginAt: new Date() } }
      );
    } else {
      acct.lastLoginAt = new Date().toISOString();
      this._saveLocal();
    }
    return { ok: true, account: acct };
  }

  async createSession(acct) {
    const authToken = crypto.randomBytes(24).toString("hex");
    const resumeToken = crypto.randomBytes(32).toString("base64url").slice(0, 48);
    const sessionCookie = crypto.randomBytes(24).toString("hex");
    const sessionKey = (crypto.randomBytes(4).readUInt32LE(0) & 0x7fffffff) || 1;
    const expiresAt = new Date(Date.now() + 7 * 24 * 3600 * 1000);
    const doc = {
      accountId: acct.accountId,
      username: acct.username,
      authToken,
      resumeToken,
      sessionCookie,
      sessionKey,
      createdAt: new Date(),
      expiresAt,
    };
    if (this.mode === "mongodb") {
      await this.db.collection("sessions").insertOne(doc);
    } else {
      this.local.sessions = this.local.sessions.filter(
        (s) => new Date(s.expiresAt).getTime() > Date.now()
      );
      this.local.sessions.push(doc);
      this._saveLocal();
    }
    return doc;
  }

  async findSessionByResume(resumeToken) {
    if (!resumeToken) return null;
    const now = new Date();
    if (this.mode === "mongodb") {
      return await this.db.collection("sessions").findOne({
        resumeToken,
        expiresAt: { $gt: now },
      });
    }
    return (
      this.local.sessions.find(
        (s) => s.resumeToken === resumeToken && new Date(s.expiresAt) > now
      ) || null
    );
  }

  async findSessionByAuthToken(username, authToken) {
    if (!authToken) return null;
    const lower = String(username || "").trim().toLowerCase();
    const now = new Date();
    if (this.mode === "mongodb") {
      const s = await this.db.collection("sessions").findOne({
        authToken,
        expiresAt: { $gt: now },
      });
      if (s && s.username.toLowerCase() === lower) return s;
      return null;
    }
    return (
      this.local.sessions.find(
        (s) =>
          s.authToken === authToken &&
          s.username.toLowerCase() === lower &&
          new Date(s.expiresAt) > now
      ) || null
    );
  }

  async findSessionByKey(accountId, sessionKey) {
    const now = new Date();
    if (this.mode === "mongodb") {
      return await this.db.collection("sessions").findOne({
        accountId: Number(accountId),
        sessionKey: Number(sessionKey),
        expiresAt: { $gt: now },
      });
    }
    return (
      this.local.sessions.find(
        (s) =>
          Number(s.accountId) === Number(accountId) &&
          Number(s.sessionKey) === Number(sessionKey) &&
          new Date(s.expiresAt) > now
      ) || null
    );
  }

  async getCharacterByAccount(accountId) {
    if (this.mode === "mongodb") {
      return await this.db.collection("characters").findOne({ accountId: Number(accountId) });
    }
    return this.local.characters.find((c) => Number(c.accountId) === Number(accountId)) || null;
  }

  async createCharacter(accountId, name, sex) {
    const clean = String(name || "").trim();
    if (clean.length < 4) return { ok: false, reason: 9 };
    if (clean.length > 15) return { ok: false, reason: 4 };
    const existing = await this.getCharacterByAccount(accountId);
    if (existing) return { ok: true, character: existing };
    const lower = clean.toLowerCase();
    if (this.mode === "mongodb") {
      const taken = await this.db.collection("characters").findOne({ nameLower: lower });
      if (taken) return { ok: false, reason: 1 };
    } else if (this.local.characters.some((c) => c.nameLower === lower)) {
      return { ok: false, reason: 1 };
    }
    const doc = makeCharacterDoc({ accountId: Number(accountId), name: clean, sex });
    if (this.mode === "mongodb") {
      try {
        await this.db.collection("characters").insertOne(doc);
      } catch (err) {
        if (err?.code === 11000) return { ok: false, reason: 1 };
        throw err;
      }
    } else {
      this.local.characters.push(doc);
      this._saveLocal();
    }
    return { ok: true, character: doc };
  }

  async updateCharacter(accountId, patch) {
    const fields = { ...patch, updatedAt: new Date() };
    if (this.mode === "mongodb") {
      await this.db.collection("characters").updateOne(
        { accountId: Number(accountId) },
        { $set: fields }
      );
      return await this.getCharacterByAccount(accountId);
    }
    const ch = this.local.characters.find((c) => Number(c.accountId) === Number(accountId));
    if (ch) {
      Object.assign(ch, fields);
      this._saveLocal();
    }
    return ch || null;
  }

  async recordMatch(matchDoc) {
    const doc = { ...matchDoc, endedAt: new Date() };
    if (this.mode === "mongodb") {
      await this.db.collection("matches").insertOne(doc);
    } else {
      this.local.matches.unshift(doc);
      if (this.local.matches.length > 200) this.local.matches.length = 200;
      this._saveLocal();
    }
    return doc;
  }

  async listMatches(limit = 20) {
    if (this.mode === "mongodb") {
      return await this.db
        .collection("matches")
        .find({})
        .sort({ endedAt: -1 })
        .limit(limit)
        .toArray();
    }
    return this.local.matches.slice(0, limit);
  }

  async close() {
    if (this.client) await this.client.close();
  }
}
