import assert from "assert/strict";
import fs from "fs";
import http from "http";
import os from "os";
import path from "path";
import zlib from "zlib";
import WebSocket from "ws";
import { startServer } from "../src/index.js";
import { CLIENT_BUILD, loadMapInfo, tankExternalId, tankSkills } from "../src/catalog.js";
import { decodeFrame, encodeFrame, encodeRawFrame, FrameReader } from "../src/protocol.js";

function rawHttpGet(url, headers = {}) {
  return new Promise((resolve, reject) => {
    const req = http.get(url, { headers }, (res) => {
      const chunks = [];
      res.on("data", (c) => chunks.push(c));
      res.on("end", () => {
        resolve({
          status: res.statusCode,
          headers: res.headers,
          body: Buffer.concat(chunks),
        });
      });
    });
    req.on("error", reject);
  });
}

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

// Verify bundled standalone catalog data
assert.equal(tankExternalId(10000001), 123);
assert.ok(tankSkills(10000001).length >= 4, "Starter tank should have real skills from catalog_data.json");
const map4 = loadMapInfo(4);
assert.equal(map4.id, 4);
assert.ok(map4.spawns[1].length >= 1 && map4.spawns[2].length >= 1, "Map 4 should have camp spawns");

// Run test with isolated local mode (no Atlas creds needed in sandbox)
const testStore = path.resolve("data/local_store.json");
if (fs.existsSync(testStore)) fs.rmSync(testStore);

const app = await startServer({ port: 0, host: "127.0.0.1", mongoUri: "", silent: true });
const base = `http://127.0.0.1:${app.port}`;
const wsBase = `ws://127.0.0.1:${app.port}`;

try {
  // 1. Health, status page, version.txt, compression & ETag 304
  const health = await (await fetch(`${base}/health`)).json();
  assert.equal(health.ok, true);
  assert.equal(health.dbHealthy, true);
  assert.equal(health.build, CLIENT_BUILD);

  const healthz = await fetch(`${base}/healthz`);
  assert.equal(healthz.status, 200);

  const verTxt = await (await fetch(`${base}/version.txt`)).text();
  assert.equal(verTxt, CLIENT_BUILD);
  const godotVerTxt = await (await fetch(`${base}/godot/version.txt`)).text();
  assert.equal(godotVerTxt, CLIENT_BUILD);

  // Fallback status dashboard at /
  const landing = await fetch(`${base}/`);
  assert.equal(landing.status, 200);
  assert.ok((landing.headers.get("content-type") || "").includes("text/html"));
  const landingHtml = await landing.text();
  assert.ok(landingHtml.includes("Tank Ghost / BangBang Server"));

  // Local static asset (gzip + ETag 304) when local server/public exists
  if (health.assetMode === "local") {
    const gzipResp = await rawHttpGet(`${base}/godot/a/index.json`, { "Accept-Encoding": "gzip" });
    assert.equal(gzipResp.status, 200);
    assert.equal(gzipResp.headers["content-encoding"], "gzip");
    assert.ok(gzipResp.headers.etag, "Static file should return ETag");
    const parsedIdx = JSON.parse(zlib.gunzipSync(gzipResp.body).toString("utf8"));
    assert.ok(parsedIdx.maps && parsedIdx.tanks);

    const notMod = await rawHttpGet(`${base}/godot/a/index.json`, {
      "If-None-Match": gzipResp.headers.etag,
    });
    assert.equal(notMod.status, 304);
  }

  const hallXml = await (await fetch(`${base}/hall-theme.xml`)).text();
  assert.ok(hallXml.includes('theme="native"'));

  // 2. Register status + captcha + account creation + HTTPS Secure cookie detection
  const st = await (await fetch(`${base}/api/register/status`)).json();
  assert.equal(st.state, "open");
  const cap = await (await fetch(`${base}/api/register/captcha`)).json();
  assert.equal(cap.ok, true);
  assert.ok(Buffer.from(cap.png, "base64").subarray(0, 4).equals(Buffer.from([137, 80, 78, 71])));

  const acctRes = await app.db.createAccount("tester01", "pass1234");
  assert.equal(acctRes.ok, true);

  const authResp = await fetch(`${base}/api/auth`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "X-Forwarded-Proto": "https",
    },
    body: JSON.stringify({ username: "tester01", password: "pass1234" }),
  });
  assert.equal(authResp.status, 200);
  const setCookie = authResp.headers.get("set-cookie") || "";
  assert.ok(setCookie.includes("bb_session="));
  assert.ok(setCookie.includes("Secure"), "Should mark cookie Secure behind HTTPS proxy");
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
} finally {
  await app.close();
}

// 7. Render + Cloudflare R2 CDN + Godot Web HTML5 + Precompressed Brotli + Rate Limit test
const tmpRoot = fs.mkdtempSync(path.join(os.tmpdir(), "bb4399-test-"));
const tmpPublic = path.join(tmpRoot, "empty_public");
const tmpWeb = path.join(tmpRoot, "web");
fs.mkdirSync(tmpPublic, { recursive: true });
fs.mkdirSync(tmpWeb, { recursive: true });
fs.writeFileSync(path.join(tmpWeb, "index.html"), "<!doctype html><html><head><title>BB</title></head><body>OK</body></html>");
const fakeWasm = Buffer.from([0x00, 0x61, 0x73, 0x6d, 0x01, 0x00, 0x00, 0x00]);
fs.writeFileSync(path.join(tmpWeb, "index.wasm"), fakeWasm);
fs.writeFileSync(path.join(tmpWeb, "index.wasm.br"), zlib.brotliCompressSync(fakeWasm));

const cdnApp = await startServer({
  port: 0,
  host: "127.0.0.1",
  mongoUri: "",
  silent: true,
  publicDir: tmpPublic,
  webDir: tmpWeb,
  assetCdnUrl: "https://pub-demo.r2.dev",
  coopCoepMode: "credentialless",
});
const cdnBase = `http://127.0.0.1:${cdnApp.port}`;

try {
  const h = await (await fetch(`${cdnBase}/health`)).json();
  assert.equal(h.assetMode, "cdn");
  assert.equal(h.assetCdn, "https://pub-demo.r2.dev/godot");
  assert.equal(h.webClient, true);
  assert.equal(h.coopCoep, "credentialless");

  // Godot Web index.html with injected window.__bbAssetRoot & COOP/COEP headers
  const webRoot = await fetch(`${cdnBase}/`);
  assert.equal(webRoot.status, 200);
  assert.equal(webRoot.headers.get("cross-origin-opener-policy"), "same-origin");
  assert.equal(webRoot.headers.get("cross-origin-embedder-policy"), "credentialless");
  const webHtml = await webRoot.text();
  assert.ok(webHtml.includes('window.__bbAssetRoot="https://pub-demo.r2.dev/godot/a/";'));

  // /godot -> 301 /godot/, /godot/ -> index.html
  const g301 = await fetch(`${cdnBase}/godot`, { redirect: "manual" });
  assert.equal(g301.status, 301);
  assert.equal(g301.headers.get("location"), "/godot/");
  const g200 = await fetch(`${cdnBase}/godot/`);
  assert.equal(g200.status, 200);

  // Precompressed .wasm.br serving
  const wasmResp = await rawHttpGet(`${cdnBase}/index.wasm`, { "Accept-Encoding": "br" });
  assert.equal(wasmResp.status, 200);
  assert.equal(wasmResp.headers["content-type"], "application/wasm");
  assert.equal(wasmResp.headers["content-encoding"], "br");
  assert.ok(zlib.brotliDecompressSync(wasmResp.body).equals(fakeWasm));

  // CDN 302 redirects for both /godot/a/*, /a/*, and /godot/av/* (immutable)
  const r1 = await fetch(`${cdnBase}/godot/a/index.json`, { redirect: "manual" });
  assert.equal(r1.status, 302);
  assert.equal(r1.headers.get("location"), "https://pub-demo.r2.dev/godot/a/index.json");

  const r2 = await fetch(`${cdnBase}/a/i/index.json`, { redirect: "manual" });
  assert.equal(r2.status, 302);
  assert.equal(r2.headers.get("location"), "https://pub-demo.r2.dev/godot/a/i/index.json");

  const r3 = await fetch(`${cdnBase}/godot/av/1234/tank.webp`, { redirect: "manual" });
  assert.equal(r3.status, 302);
  assert.equal(r3.headers.get("location"), "https://pub-demo.r2.dev/godot/av/1234/tank.webp");
  assert.ok((r3.headers.get("cache-control") || "").includes("immutable"));

  // /godot/pcdl.json auto-enables R2 mirror for native PC/Android/iOS clients
  const pcdl = await (await fetch(`${cdnBase}/godot/pcdl.json`)).json();
  assert.equal(pcdl.on, true);
  assert.equal(pcdl.av, true);
  assert.equal(pcdl.a, true);
  assert.deepEqual(pcdl.mirrors, ["https://pub-demo.r2.dev"]);

  // Rate limit check on /api/auth (31st request from same IP -> 429)
  let got429 = false;
  for (let i = 0; i < 32; i++) {
    const res = await fetch(`${cdnBase}/api/auth`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Forwarded-For": "203.0.113.9",
      },
      body: JSON.stringify({ username: "nobody", password: "wrong" }),
    });
    if (res.status === 429) {
      got429 = true;
      break;
    }
  }
  assert.equal(got429, true, "Rate limiter should trigger 429 after 30 auth attempts/min");

  console.log(
    "ALL SMOKE TESTS PASSED! (Standalone Catalog + HTTP/ETag/Gzip + Auth/Register + WS Login/Gate + Battle + Render R2 CDN + Godot Web HTML5 + Brotli + RateLimit)"
  );
} finally {
  await cdnApp.close();
  fs.rmSync(tmpRoot, { recursive: true, force: true });
  if (fs.existsSync(testStore)) fs.rmSync(testStore);
}
