import fs from "fs";
import path from "path";
import { PUBLIC_DIR } from "./catalog.js";
import { CaptchaStore } from "./captcha.js";

const MIME = {
  ".webp": "image/webp",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".json": "application/json; charset=utf-8",
  ".mp3": "audio/mpeg",
  ".ttf": "font/ttf",
  ".xml": "application/xml; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".wasm": "application/wasm",
  ".bin": "application/octet-stream",
  ".pck": "application/octet-stream",
};

function setCors(res, req) {
  const origin = req.headers.origin;
  if (origin) {
    res.setHeader("Access-Control-Allow-Origin", origin);
    res.setHeader("Access-Control-Allow-Credentials", "true");
  } else {
    res.setHeader("Access-Control-Allow-Origin", "*");
  }
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, X-Client-Instance, Cache-Control");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
}

function sendJson(res, status, obj, extraHeaders = {}) {
  const body = Buffer.from(JSON.stringify(obj), "utf8");
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": body.length,
    "Cache-Control": "no-store",
    ...extraHeaders,
  });
  res.end(body);
}

function sendText(res, status, contentType, text) {
  const body = Buffer.from(text, "utf8");
  res.writeHead(status, {
    "Content-Type": contentType,
    "Content-Length": body.length,
    "Cache-Control": "no-store",
  });
  res.end(body);
}

async function readJsonBody(req, limitBytes = 65536) {
  const chunks = [];
  let total = 0;
  for await (const chunk of req) {
    total += chunk.length;
    if (total > limitBytes) throw new Error("BODY_TOO_LARGE");
    chunks.push(chunk);
  }
  if (total === 0) return {};
  return JSON.parse(Buffer.concat(chunks, total).toString("utf8"));
}

function serveStatic(req, res, pathname) {
  let decoded;
  try {
    decoded = decodeURIComponent(pathname);
  } catch {
    return false;
  }
  const normalized = path.posix.normalize(decoded);
  if (normalized.includes("..")) return false;
  const target = path.join(PUBLIC_DIR, normalized);
  if (!target.startsWith(PUBLIC_DIR)) return false;
  if (!fs.existsSync(target)) return false;
  const stat = fs.statSync(target);
  if (!stat.isFile()) return false;
  const ext = path.extname(target).toLowerCase();
  const contentType = MIME[ext] || "application/octet-stream";
  const cacheHeader = normalized.startsWith("/godot/av/")
    ? "public, max-age=31536000, immutable"
    : "public, max-age=300";
  res.writeHead(200, {
    "Content-Type": contentType,
    "Content-Length": stat.size,
    "Cache-Control": cacheHeader,
  });
  if (req.method === "HEAD") {
    res.end();
    return true;
  }
  fs.createReadStream(target).pipe(res);
  return true;
}

export function createHttpHandler(db, stats = {}) {
  const captchas = new CaptchaStore();

  return async function handleHttp(req, res) {
    setCors(res, req);
    if (req.method === "OPTIONS") {
      res.writeHead(204);
      res.end();
      return;
    }

    const url = new URL(req.url || "/", `http://${req.headers.host || "localhost"}`);
    const pathname = url.pathname;

    try {
      if (pathname === "/health" && req.method === "GET") {
        return sendJson(res, 200, {
          ok: true,
          db: db.mode,
          uptimeSec: Math.floor(process.uptime()),
          online: typeof stats.onlineCount === "function" ? stats.onlineCount() : 0,
          rooms: typeof stats.roomCount === "function" ? stats.roomCount() : 0,
        });
      }

      // ---- AUTH ----
      if (pathname === "/api/auth" && req.method === "POST") {
        const body = await readJsonBody(req);
        let acct = null;
        if (typeof body.resume === "string" && body.resume.length >= 40) {
          const old = await db.findSessionByResume(body.resume);
          if (!old) {
            return sendJson(res, 401, {
              ok: false,
              code: "SESSION_EXPIRED",
              error: "Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.",
            });
          }
          acct = await db.findAccountByUsername(old.username);
        } else {
          const authRes = await db.authenticate(body.username, body.password);
          if (!authRes.ok) {
            return sendJson(res, 401, authRes);
          }
          acct = authRes.account;
        }
        if (!acct) {
          return sendJson(res, 401, { ok: false, code: "INVALID_CREDENTIALS", error: "Tài khoản không tồn tại." });
        }
        const session = await db.createSession(acct);
        const char = await db.getCharacterByAccount(acct.accountId);
        return sendJson(
          res,
          200,
          {
            ok: true,
            authToken: session.authToken,
            resumeToken: session.resumeToken,
            account: {
              username: acct.username,
              name: char?.name || acct.username,
            },
          },
          {
            "Set-Cookie": `bb_session=${session.sessionCookie}; HttpOnly; Path=/; SameSite=Lax`,
          }
        );
      }

      // ---- REGISTER ----
      if (pathname === "/api/register/status" && req.method === "GET") {
        return sendJson(res, 200, {
          ok: true,
          state: "open",
          quiz: false,
          regcode: false,
        });
      }

      if (pathname === "/api/register/captcha" && req.method === "GET") {
        const cap = captchas.issue();
        return sendJson(res, 200, {
          ok: true,
          id: cap.id,
          png: cap.pngBase64,
          email: false,
          quiz: false,
          regcode: false,
        });
      }

      if (pathname === "/api/register" && req.method === "POST") {
        const body = await readJsonBody(req);
        if (!captchas.verify(body.captchaId, body.captcha)) {
          return sendJson(res, 400, {
            ok: false,
            code: "CAPTCHA",
            error: "Mã xác nhận không đúng hoặc đã hết hạn.",
            renew: true,
          });
        }
        const created = await db.createAccount(body.username, body.password);
        if (!created.ok) {
          return sendJson(res, 400, { ...created, renew: true });
        }
        return sendJson(res, 200, {
          ok: true,
          username: created.account.username,
        });
      }

      // ---- AUXILIARY GAME HTTP ENDPOINTS ----
      if (pathname === "/hall-theme.xml") {
        return sendText(res, 200, "application/xml; charset=utf-8", '<hall theme="native"/>');
      }
      if (pathname === "/xml/ActivityTemplate_table.xml") {
        return sendText(res, 200, "application/xml; charset=utf-8", "<root/>");
      }
      if (pathname === "/getuseraward.php") {
        return sendText(res, 200, "text/plain; charset=utf-8", "0");
      }
      if (pathname === "/godot/pcdl.json") {
        return sendJson(res, 200, { v: 1, on: false, mirrors: [] });
      }
      if (pathname === "/api/client-error" && req.method === "POST") {
        const errDoc = await readJsonBody(req).catch(() => ({}));
        if (Array.isArray(errDoc.items) && errDoc.items.length > 0) {
          console.warn("[client-error]", errDoc.pf, errDoc.v, errDoc.items[0]?.m);
        }
        return sendJson(res, 200, { ok: true });
      }
      if (pathname === "/api/match-history" && req.method === "GET") {
        const rows = await db.listMatches(20);
        return sendJson(res, 200, { ok: true, items: rows, total: rows.length, page: 1 });
      }
      if (pathname === "/api/chat-faces") {
        return sendJson(res, 200, { ok: true, items: [] });
      }
      if (pathname === "/api/name-styles.xml") {
        return sendText(res, 200, "application/xml; charset=utf-8", "<styles/>");
      }
      if (pathname === "/api/couples.json") {
        return sendJson(res, 200, { ok: true, couples: [] });
      }

      // ---- STATIC ASSETS (/godot/a/*, /godot/av/*, /godot/lv/*, /godot/mu/*) ----
      if ((req.method === "GET" || req.method === "HEAD") && serveStatic(req, res, pathname)) {
        return;
      }

      sendJson(res, 404, { ok: false, error: "Not found" });
    } catch (err) {
      if (err.message === "BODY_TOO_LARGE") {
        return sendJson(res, 413, { ok: false, error: "Payload too large" });
      }
      console.error("[http] error on", pathname, err);
      sendJson(res, 500, { ok: false, error: "Internal server error" });
    }
  };
}
