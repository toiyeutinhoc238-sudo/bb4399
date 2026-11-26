import assert from "assert/strict";
import fs from "fs";
import path from "path";
import WebSocket from "ws";
import { startServer } from "../src/index.js";
import { decodeFrame, encodeFrame, encodeRawFrame, FrameReader } from "../src/protocol.js";

function wsClient(url) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(url);
    const reader = new FrameReader();
    const queue = [];
    const waiters = [];
    let greeted = false;

    ws.on("message", (data) => {
      let buf = Buffer.isBuffer(data) ? data : Buffer.from(data);
      if (!greeted) {
        assert.equal(buf.readUInt16LE(0), 0, "Expected 00 00 greeting");
        greeted = true;
        buf = buf.subarray(2);
      }
      if (buf.length === 0) return;
      for (const frame of reader.feed(buf)) {
        const decoded = decodeFrame(frame);
        const item = { frame, decoded };
        if (waiters.length > 0) waiters.shift()(item);
        else queue.push(item);
      }
    });

    ws.on("open", () => {
      resolve({
        ws,
        send(buf) {
          ws.send(buf);
        },
        next(predicate, timeoutMs = 4000) {
          return new Promise((res, rej) => {
            const deadline = setTimeout(() => rej(new Error("Timed out waiting for packet")), timeoutMs);
            const check = (item) => {
              if (!predicate || predicate(item)) {
                clearTimeout(deadline);
                res(item);
              } else {
                waiters.push(check);
              }
            };
            while (queue.length > 0) {
              const item = queue.shift();
              if (!predicate || predicate(item)) {
                clearTimeout(deadline);
                res(item);
                return;
              }
            }
            waiters.push(check);
          });
        },
        close() {
          ws.close();
        },
      });
    });
    ws.on("error", reject);
  });
}

// Run test with isolated local mode (no Atlas creds needed in sandbox)
const testStore = path.resolve("data/local_store.json");
if (fs.existsSync(testStore)) fs.rmSync(testStore);

const app = await startServer({ port: 0, host: "127.0.0.1", mongoUri: "", silent: true });
const base = `http://127.0.0.1:${app.port}`;
const wsBase = `ws://127.0.0.1:${app.port}`;

try {
  // 1. Health & static assets
  const health = await (await fetch(`${base}/health`)).json();
  assert.equal(health.ok, true);
  const idxRes = await fetch(`${base}/godot/a/index.json`);
  assert.equal(idxRes.status, 200);
  const hallXml = await (await fetch(`${base}/hall-theme.xml`)).text();
  assert.ok(hallXml.includes('theme="native"'));

  // 2. Register status + captcha + account creation
  const st = await (await fetch(`${base}/api/register/status`)).json();
  assert.equal(st.state, "open");
  const cap = await (await fetch(`${base}/api/register/captcha`)).json();
  assert.equal(cap.ok, true);
  assert.ok(Buffer.from(cap.png, "base64").subarray(0, 4).equals(Buffer.from([137, 80, 78, 71])));

  // Direct account create via DB + auth over HTTP
  const acctRes = await app.db.createAccount("tester01", "pass1234");
  assert.equal(acctRes.ok, true);

  const authResp = await fetch(`${base}/api/auth`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ username: "tester01", password: "pass1234" }),
  });
  assert.equal(authResp.status, 200);
  assert.ok((authResp.headers.get("set-cookie") || "").includes("bb_session="));
  const auth = await authResp.json();
  assert.equal(auth.ok, true);
  assert.ok(auth.authToken && auth.resumeToken);

  // Resume auth works
  const resumeResp = await fetch(`${base}/api/auth`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ resume: auth.resumeToken }),
  });
  const resumed = await resumeResp.json();
  assert.equal(resumed.ok, true);

  // 3. /ws/login handshake
  const loginWs = await wsClient(`${wsBase}/ws/login`);
  loginWs.send(
    encodeFrame("AuthMessage.RequestProtocolVersion", {
      m_auth_ver: 3,
      m_gate_ver: 18,
      m_mixAuth: 0,
      m_client_ver: "curVersion",
    })
  );
  const verLogin = await loginWs.next((x) => x.frame.readInt16LE(2) === 903);
  assert.equal(verLogin.frame.length, 20, "Frame 903 must be exact 20 bytes");

  loginWs.send(
    encodeFrame("AuthMessage.RequestAuthLogin", {
      m_microclient: 0,
      m_name: "tester01",
      m_passwd: auth.authToken,
      m_adult: "1",
      m_time: "",
      m_platform: "",
      m_channel: "",
      m_token: "",
      m_passport: "",
      m_clientSid: 299001,
    })
  );
  const loginOk = await loginWs.next((x) => x.decoded.type === 901);
  const sessionKey = loginOk.decoded.value.m_sessionkey;
  const accountId = loginOk.decoded.value.m_nAcctId;
  const regionList = await loginWs.next((x) => x.decoded.type === 906);
  assert.equal(regionList.decoded.value.m_regions[0].region_id, 299001);
  loginWs.close();

  // 4. /ws/gate handshake + create character + enter lobby
  const gateWs = await wsClient(`${wsBase}/ws/gate`);
  gateWs.send(
    encodeFrame("AuthMessage.RequestProtocolVersion", {
      m_auth_ver: 3,
      m_gate_ver: 18,
      m_mixAuth: 0,
      m_client_ver: "1.0.1.8480",
    })
  );
  await gateWs.next((x) => x.frame.readInt16LE(2) === 903);

  gateWs.send(encodeFrame("AuthMessage.RequestServerLogin", { m_session: sessionKey, m_nAcctId: accountId }));
  await gateWs.next((x) => x.decoded.type === 1011); // NotifyCreateNewChar

  // Send raw frame 64 (create character)
  const nameBuf = Buffer.from("TankHero", "utf8");
  const c64 = Buffer.alloc(4 + 2 + nameBuf.length + 2 + 2);
  c64.writeInt32LE(1, 0);
  c64.writeUInt16LE(nameBuf.length, 4);
  nameBuf.copy(c64, 6);
  gateWs.send(encodeRawFrame(64, c64));

  await gateWs.next((x) => x.frame.readInt16LE(2) === 1012);
  const enterConfirm = await gateWs.next((x) => x.decoded.type === 1005);
  assert.equal(enterConfirm.decoded.value.m_account_oid, accountId);
  const charData = await gateWs.next((x) => x.decoded.type === 1016);
  assert.equal(charData.decoded.value.m_charData.name, "TankHero");
  const tankList = await gateWs.next((x) => x.decoded.type === 1150);
  assert.ok(tankList.decoded.value.m_tankVec.length >= 5);

  // 5. Ping -> Pong
  gateWs.send(encodeFrame("SystemMessage.RequestPing", {}));
  const pong = await gateWs.next((x) => x.decoded.type === 1003);
  assert.ok(pong.decoded.value.m_time > 0);

  // 6. Hall -> Create Room -> Start Battle (solo vs AI bot)
  gateWs.send(encodeFrame("RoomMessage.RequestInHall", { m_bType: 2, m_iSite: 0 }));
  await gateWs.next((x) => x.decoded.type === 1724);

  gateWs.send(
    encodeFrame("RoomMessage.RequestCreateRoom", {
      m_bType: 2,
      m_bMode: 0,
      m_mapId: 4,
      m_passWord: 0,
      m_szName: "Phong Test",
      m_nItemId: 0,
    })
  );
  const roomOk = await gateWs.next((x) => x.decoded.type === 1700);
  assert.equal(roomOk.decoded.value.roomConfig.m_nMapId, 4);

  // Start match (op 24)
  gateWs.send(encodeFrame("RoomMessage.RequestRoomOp", { m_roomOp: 24, m_nTarget: 0 }));
  const startGame = await gateWs.next((x) => x.decoded.type === 1705);
  const sceneId = startGame.decoded.value.m_nSceneId;
  assert.equal(startGame.decoded.value.m_charData.length, 2, "Should include player + AI bot");

  // Finish loading (100%)
  gateWs.send(
    encodeFrame("RoomMessage.SyncLoadAndDelay", {
      m_nSceneId: sceneId,
      m_nTankId: accountId,
      m_nDelay: 10,
      m_nLoaded: 100,
    })
  );
  const selfData = await gateWs.next((x) => x.decoded.type === 1550);
  const otherList = await gateWs.next((x) => x.decoded.type === 1551);
  await gateWs.next((x) => x.decoded.type === 1586);
  assert.equal(otherList.decoded.value.m_otherList.length, 1);

  // Move & Fire (with exact Flash 8-byte zero-padding used by client_godot)
  const padLikeGodot = (buf) => {
    const pad = (8 - ((buf.length - 2) % 8)) % 8;
    if (pad === 0) return buf;
    const out = Buffer.alloc(buf.length + pad);
    buf.copy(out, 0);
    out.writeUInt16LE(out.length, 0);
    return out;
  };
  const meX = selfData.decoded.value.m_selfData.m_x;
  const meY = selfData.decoded.value.m_selfData.m_y;
  gateWs.send(
    padLikeGodot(
      encodeFrame("MovementMessage.RequestMoveForward", {
        m_start_x: meX,
        m_start_y: meY,
        m_direction: 3,
        m_sceneId: sceneId,
      })
    )
  );
  gateWs.send(
    padLikeGodot(
      encodeFrame("TankMessage.RequestUseSkill", {
        m_sceneId: sceneId,
        m_targetId: 0,
        m_soltNo: 0,
        m_destX: meX + 200,
        m_destY: meY,
      })
    )
  );
  const sync = await gateWs.next((x) => x.decoded.type === 1564 && x.decoded.value.m_fireVec.length > 0);
  assert.ok(sync.decoded.value.m_fireVec.length >= 1);

  // Exit battle
  gateWs.send(encodeFrame("RoomMessage.RequestExitBattleEnd", { m_type: 1 }));
  const exitOk = await gateWs.next((x) => x.decoded.type === 1707);
  assert.equal(exitOk.decoded.value.m_nErrId, 0);

  gateWs.close();
  console.log("ALL SMOKE TESTS PASSED! (HTTP + Register/Auth + WS Login/Gate + Char Create + Room + Battle Move/Fire/Exit)");
} finally {
  await app.close();
  if (fs.existsSync(testStore)) fs.rmSync(testStore);
}
