import fs from "fs";
import path from "path";
import zlib from "zlib";
import { CLIENT_BUILD, PUBLIC_DIR, WEB_DIR, hasLocalAssets, hasWebClient } from "./catalog.js";
import { CaptchaStore } from "./captcha.js";

const MIME = {
  ".webp": "image/webp",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".gif": "image/gif",
  ".svg": "image/svg+xml",
  ".ico": "image/x-icon",
  ".json": "application/json; charset=utf-8",
  ".mp3": "audio/mpeg",
  ".ogg": "audio/ogg",
  ".wav": "audio/wav",
  ".ttf": "font/ttf",
  ".woff2": "font/woff2",
  ".xml": "application/xml; charset=utf-8",
  ".txt": "text/plain; charset=utf-8",
  ".html": "text/html; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".js": "application/javascript; charset=utf-8",
  ".mjs": "application/javascript; charset=utf-8",
  ".wasm": "application/wasm",
  ".bin": "application/octet-stream",
  ".pck": "application/octet-stream",
};

const COMPRESSIBLE_EXT = new Set([
  ".json",
  ".xml",
  ".txt",
  ".html",
  ".css",
  ".js",
  ".mjs",
  ".svg",
  ".wasm",
]);

const MIRROR_HOST_RE =
  /^(https:\/\/[a-z0-9.-]+(?::[0-9]{1,5})?|http:\/\/(?:127\.0\.0\.1|localhost|10\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}|192\.168\.[0-9]{1,3}\.[0-9]{1,3}|172\.(?:1[6-9]|2[0-9]|3[0-1])\.[0-9]{1,3}\.[0-9]{1,3})(?::[0-9]{1,5})?)$/i;

const ASSET_SUBPATH_RE = /^\/(?:godot\/)?((?:a|av|lv|mu)\/.+)$/;

function parseCdnConfig(rawUrl, stripGodot = false) {
  const clean = String(rawUrl || "").trim().replace(/\/+$/, "");
  if (!clean || (!clean.startsWith("https://") && !clean.startsWith("http://"))) {
    return { enabled: false, origin: "", godotBase: "", mirrorOrigin: "" };
  }
  const hasGodotSuffix = clean.endsWith("/godot");
  const origin = hasGodotSuffix ? clean.slice(0, -6) : clean;
  const godotBase = stripGodot ? origin : hasGodotSuffix ? clean : `${clean}/godot`;
  const mirrorOrigin = !stripGodot && MIRROR_HOST_RE.test(origin) ? origin : "";
  return { enabled: true, origin, godotBase, mirrorOrigin };
}

function normalizeCoopCoep(mode) {
  const m = String(mode || "off").trim().toLowerCase();
  if (m === "credentialless" || m === "require-corp") return m;
  return "off";
}

function getClientIp(req) {
  const xff = req.headers["x-forwarded-for"];
  if (typeof xff === "string" && xff.length > 0) {
    return xff.split(",")[0].trim();
  }
  return req.socket?.remoteAddress || "unknown";
}

function isHttpsRequest(req) {
  const proto = String(req.headers["x-forwarded-proto"] || "").split(",")[0].trim().toLowerCase();
  return proto === "https" || Boolean(req.socket?.encrypted);
}

function pickEncoding(req) {
  const ae = String(req.headers["accept-encoding"] || "").toLowerCase();
  if (ae.includes("br")) return "br";
  if (ae.includes("gzip")) return "gzip";
  return "";
}

function compressBuffer(buf, encoding) {
  if (encoding === "br") {
    return zlib.brotliCompressSync(buf, {
      params: { [zlib.constants.BROTLI_PARAM_QUALITY]: 4 },
    });
  }
  if (encoding === "gzip") {
    return zlib.gzipSync(buf, { level: 6 });
  }
  return buf;
}

class RateLimiter {
  constructor() {
    this.buckets = new Map();
    this.lastSweep = Date.now();
  }
  allow(key, maxHits, windowMs) {
    const now = Date.now();
    if (now - this.lastSweep > 60000) {
      this.lastSweep = now;
      for (const [k, entry] of this.buckets) {
        if (entry.resetAt <= now) this.buckets.delete(k);
      }
    }
    let entry = this.buckets.get(key);
    if (!entry || entry.resetAt <= now) {
      entry = { count: 0, resetAt: now + windowMs };
      this.buckets.set(key, entry);
    }
    entry.count++;
    return entry.count <= maxHits;
  }
}

function setCors(res, req) {
  const origin = req.headers.origin;
  if (origin) {
    res.setHeader("Access-Control-Allow-Origin", origin);
    res.setHeader("Access-Control-Allow-Credentials", "true");
    res.setHeader("Vary", "Origin, Accept-Encoding");
  } else {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Vary", "Accept-Encoding");
  }
  res.setHeader("Access-Control-Allow-Headers", "Content-Type, X-Client-Instance, Cache-Control");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, HEAD, OPTIONS");
  res.setHeader("X-Content-Type-Options", "nosniff");
  res.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");
}

function sendBody(req, res, status, contentType, rawBody, extraHeaders = {}, compress = true) {
  const buf = Buffer.isBuffer(rawBody) ? rawBody : Buffer.from(String(rawBody), "utf8");
  const headers = {
    "Content-Type": contentType,
    "Cache-Control": "no-store",
    ...extraHeaders,
  };

  let payload = buf;
  if (compress && buf.length >= 1024) {
    const enc = pickEncoding(req);
    if (enc) {
      payload = compressBuffer(buf, enc);
      headers["Content-Encoding"] = enc;
    }
  }
  headers["Content-Length"] = payload.length;
  res.writeHead(status, headers);
  if (req.method === "HEAD") {
    res.end();
    return;
  }
  res.end(payload);
}

function sendJson(req, res, status, obj, extraHeaders = {}) {
  sendBody(req, res, status, "application/json; charset=utf-8", JSON.stringify(obj), extraHeaders, true);
}

function sendText(req, res, status, contentType, text, extraHeaders = {}) {
  sendBody(req, res, status, contentType, text, extraHeaders, true);
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

function escapeHtml(str) {
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;");
}

function renderStatusHtml({ req, dbMode, dbHealthy, online, rooms, uptimeSec, cdn, localAssets, webReady }) {
  const proto = isHttpsRequest(req) ? "https" : "http";
  const wsProto = proto === "https" ? "wss" : "ws";
  const host = req.headers.host || "localhost:8080";
  const origin = `${proto}://${host}`;
  const assetModeText = localAssets
    ? "Local (server/public/godot)"
    : cdn.enabled
      ? `Cloudflare R2 / CDN (${cdn.godotBase})`
      : "Chưa cấu hình ASSET_CDN_URL";

  return `<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1"/>
<title>BangBang / Tank Ghost Server</title>
<style>
  :root{color-scheme:dark;font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif}
  body{margin:0;min-height:100vh;background:#0b1020;color:#e5ecff;display:grid;place-items:center;padding:24px}
  .card{width:100%;max-width:720px;background:#121a30;border:1px solid #243257;border-radius:16px;padding:28px;box-shadow:0 20px 60px rgba(0,0,0,.45)}
  h1{margin:0 0 6px;font-size:24px;display:flex;align-items:center;gap:10px}
  .badge{font-size:12px;padding:3px 10px;border-radius:999px;background:#103a28;color:#4ade80;border:1px solid #1e6b48}
  .warn{background:#3a2810;color:#fbbf24;border-color:#784f18}
  p.sub{margin:0 0 20px;color:#93a4cc;font-size:14px}
  .grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(150px,1fr));gap:12px;margin-bottom:20px}
  .stat{background:#0d1426;border:1px solid #1e2a4a;border-radius:12px;padding:14px}
  .stat .k{font-size:12px;color:#8a9bc4;margin-bottom:4px}
  .stat .v{font-size:17px;font-weight:700;word-break:break-word}
  .box{background:#0d1426;border:1px solid #1e2a4a;border-radius:12px;padding:16px;margin-top:14px}
  .box h2{margin:0 0 10px;font-size:15px;color:#c7d6ff}
  code{background:#182442;padding:2px 6px;border-radius:6px;font-size:13px;color:#93c5fd}
  ol{margin:8px 0 0;padding-left:20px;color:#b8c7ea;font-size:14px;line-height:1.6}
  .links{margin-top:18px;display:flex;gap:10px;flex-wrap:wrap;font-size:13px}
  a{color:#60a5fa;text-decoration:none}
  a:hover{text-decoration:underline}
</style>
</head>
<body>
<main class="card">
  <h1>Tank Ghost / BangBang Server <span class="badge">${dbHealthy ? "ONLINE" : "DEGRADED"}</span></h1>
  <p class="sub">Game Server Node.js + WebSocket + MongoDB Atlas đang hoạt động (Build <code>${escapeHtml(CLIENT_BUILD)}</code>).</p>

  <section class="grid">
    <div class="stat"><div class="k">Database</div><div class="v">${escapeHtml(dbMode === "mongodb" ? "MongoDB Atlas" : "Local JSON")}</div></div>
    <div class="stat"><div class="k">Đang online</div><div class="v">${online} người / ${rooms} phòng</div></div>
    <div class="stat"><div class="k">Uptime</div><div class="v">${uptimeSec}s</div></div>
    <div class="stat"><div class="k">Web HTML5</div><div class="v">${webReady ? "Sẵn sàng" : "Chưa export"}</div></div>
  </section>

  <section class="box">
    <h2>Địa chỉ kết nối Client (PC / Android / iOS)</h2>
    <ol>
      <li>HTTP Origin: <code>${escapeHtml(origin)}</code></li>
      <li>WebSocket: <code>${escapeHtml(wsProto)}://${escapeHtml(host)}/ws/login</code></li>
      <li>Tài nguyên tĩnh: <code>${escapeHtml(assetModeText)}</code></li>
    </ol>
  </section>

  <section class="box">
    <h2>Cách bật chơi trực tiếp trên trình duyệt (Web HTML5)</h2>
    <ol>
      <li>Mở <code>client_godot/project.godot</code> bằng <strong>Godot 4.7.2</strong> và Export preset <strong>Web (HTML5)</strong> (khuyên tắt Thread Support để chạy mượt cả iOS Safari).</li>
      <li>Đặt toàn bộ file đã xuất (<code>index.html</code>, <code>index.js</code>, <code>index.wasm</code>, <code>index.pck</code>...) vào thư mục <code>server/web/</code> rồi push lên GitHub.</li>
      <li>Upload thư mục <code>server/public/godot/</code> lên <strong>Cloudflare R2</strong> và đặt biến môi trường <code>ASSET_CDN_URL</code> trên Render để tải hình/nhạc siêu tốc miễn phí băng thông.</li>
    </ol>
  </section>

  <div class="links">
    <a href="/health">/health</a>
    <a href="/godot/pcdl.json">/godot/pcdl.json</a>
    <a href="/api/register/status">/api/register/status</a>
    <a href="/api/match-history">/api/match-history</a>
  </div>
</main>
</body>
</html>`;
}

function serveFileWithCaching(req, res, absFilePath, { cacheControl, extraHeaders = {}, transformHtml = null }) {
  if (!fs.existsSync(absFilePath)) return false;
  const stat = fs.statSync(absFilePath);
  if (!stat.isFile()) return false;

  const ext = path.extname(absFilePath).toLowerCase();
  const contentType = MIME[ext] || "application/octet-stream";

  // HTML transform path (e.g., injecting window.__bbAssetRoot for zero-hop R2 loads)
  if (ext === ".html" && typeof transformHtml === "function") {
    const html = transformHtml(fs.readFileSync(absFilePath, "utf8"));
    sendBody(
      req,
      res,
      200,
      contentType,
      html,
      { "Cache-Control": cacheControl, ...extraHeaders },
      true
    );
    return true;
  }

  // Check precompressed .br / .gz sidecars first (e.g., index.wasm.br, index.pck.br)
  const ae = String(req.headers["accept-encoding"] || "").toLowerCase();
  let fileToServe = absFilePath;
  let fileStat = stat;
  let precompressedEnc = "";
  if (ae.includes("br") && fs.existsSync(`${absFilePath}.br`)) {
    const brStat = fs.statSync(`${absFilePath}.br`);
    if (brStat.isFile()) {
      fileToServe = `${absFilePath}.br`;
      fileStat = brStat;
      precompressedEnc = "br";
    }
  } else if (ae.includes("gzip") && fs.existsSync(`${absFilePath}.gz`)) {
    const gzStat = fs.statSync(`${absFilePath}.gz`);
    if (gzStat.isFile()) {
      fileToServe = `${absFilePath}.gz`;
      fileStat = gzStat;
      precompressedEnc = "gzip";
    }
  }

  const etag = `W/"${fileStat.size.toString(16)}-${Math.floor(fileStat.mtimeMs).toString(16)}${precompressedEnc ? `-${precompressedEnc}` : ""}"`;
  if (req.headers["if-none-match"] === etag) {
    res.writeHead(304, {
      ETag: etag,
      "Cache-Control": cacheControl,
      ...extraHeaders,
    });
    res.end();
    return true;
  }

  const headers = {
    "Content-Type": contentType,
    "Cache-Control": cacheControl,
    ETag: etag,
    ...extraHeaders,
  };

  if (precompressedEnc) {
    headers["Content-Encoding"] = precompressedEnc;
    headers["Content-Length"] = fileStat.size;
    res.writeHead(200, headers);
    if (req.method === "HEAD") {
      res.end();
      return true;
    }
    fs.createReadStream(fileToServe).pipe(res);
    return true;
  }

  // Dynamic streaming compression for compressible assets > 1 KB
  const dynEnc = COMPRESSIBLE_EXT.has(ext) && fileStat.size >= 1024 ? pickEncoding(req) : "";
  if (dynEnc) {
    headers["Content-Encoding"] = dynEnc;
    res.writeHead(200, headers);
    if (req.method === "HEAD") {
      res.end();
      return true;
    }
    const compressor =
      dynEnc === "br"
        ? zlib.createBrotliCompress({ params: { [zlib.constants.BROTLI_PARAM_QUALITY]: 4 } })
        : zlib.createGzip({ level: 6 });
    fs.createReadStream(fileToServe).pipe(compressor).pipe(res);
    return true;
  }

  headers["Content-Length"] = fileStat.size;
  res.writeHead(200, headers);
  if (req.method === "HEAD") {
    res.end();
    return true;
  }
  fs.createReadStream(fileToServe).pipe(res);
  return true;
}

function safeJoin(rootDir, relPosix) {
  let decoded;
  try {
    decoded = decodeURIComponent(relPosix);
  } catch {
    return null;
  }
  const normalized = path.posix.normalize(`/${decoded}`);
  if (normalized.includes("..")) return null;
  const resolved = path.resolve(rootDir, `.${normalized}`);
  const rootResolved = path.resolve(rootDir);
  if (resolved !== rootResolved && !resolved.startsWith(rootResolved + path.sep)) {
    return null;
  }
  return { resolved, normalized };
}

export function createHttpHandler(db, stats = {}, options = {}) {
  const captchas = new CaptchaStore();
  const limiter = new RateLimiter();
  const rateLimitEnabled = options.rateLimit !== false && process.env.DISABLE_RATE_LIMIT !== "true";
  const cdn = parseCdnConfig(
    options.assetCdnUrl ?? process.env.ASSET_CDN_URL ?? "",
    options.assetCdnStripGodot ?? process.env.ASSET_CDN_STRIP_GODOT === "true"
  );
  const injectAssetCdn =
    (options.injectAssetCdn ?? process.env.INJECT_ASSET_CDN !== "false") && cdn.enabled;
  const coopCoepMode = normalizeCoopCoep(options.coopCoepMode ?? process.env.COOP_COEP_MODE ?? "off");
  const webDir = options.webDir || WEB_DIR;
  const publicDir = options.publicDir || PUBLIC_DIR;

  function webExtraHeaders() {
    if (coopCoepMode === "credentialless") {
      return {
        "Cross-Origin-Opener-Policy": "same-origin",
        "Cross-Origin-Embedder-Policy": "credentialless",
      };
    }
    if (coopCoepMode === "require-corp") {
      return {
        "Cross-Origin-Opener-Policy": "same-origin",
        "Cross-Origin-Embedder-Policy": "require-corp",
      };
    }
    return {};
  }

  function injectCdnIntoHtml(html) {
    if (!injectAssetCdn) return html;
    const assetRoot = `${cdn.godotBase}/a/`;
    const snippet = `<script>window.__bbAssetRoot=${JSON.stringify(assetRoot)};</script>`;
    if (html.includes("</head>")) return html.replace("</head>", `${snippet}</head>`);
    return snippet + html;
  }

  function tryServeWebClient(req, res, pathname) {
    // Support serving Godot Web from both / and /godot/
    let rel = pathname;
    if (rel === "/godot") {
      res.writeHead(301, { Location: "/godot/" });
      res.end();
      return true;
    }
    if (rel.startsWith("/godot/")) {
      rel = rel.slice(6); // keep leading '/'
    }
    if (rel === "/") rel = "/index.html";

    const joined = safeJoin(webDir, rel);
    if (!joined) return false;
    const ext = path.extname(joined.resolved).toLowerCase();
    const isImmutable = ext === ".wasm" || ext === ".pck";
    const cacheControl =
      ext === ".html"
        ? "no-cache"
        : isImmutable
          ? "public, max-age=86400, stale-while-revalidate=604800"
          : "public, max-age=3600";

    return serveFileWithCaching(req, res, joined.resolved, {
      cacheControl,
      extraHeaders: webExtraHeaders(),
      transformHtml: ext === ".html" ? injectCdnIntoHtml : null,
    });
  }

  function tryServeGameAsset(req, res, pathname) {
    const match = ASSET_SUBPATH_RE.exec(pathname);
    if (!match) return false;

    const subPath = match[1]; // e.g., "a/index.json" or "av/1234/..."
    const isVersioned = subPath.startsWith("av/");
    const cacheControl = isVersioned
      ? "public, max-age=31536000, immutable"
      : "public, max-age=300, stale-while-revalidate=600";

    // 1. Try local server/public/godot/<subPath>
    const joined = safeJoin(publicDir, `/godot/${subPath}`);
    if (joined && fs.existsSync(joined.resolved)) {
      const ok = serveFileWithCaching(req, res, joined.resolved, {
        cacheControl,
        extraHeaders: { "Cross-Origin-Resource-Policy": "cross-origin" },
      });
      if (ok) return true;
    }

    // 2. Redirect to external CDN (Cloudflare R2) if configured
    if (cdn.enabled) {
      if (subPath.includes("..")) return false;
      const targetUrl = `${cdn.godotBase}/${subPath}`;
      res.writeHead(302, {
        Location: targetUrl,
        "Cache-Control": cacheControl,
      });
      res.end();
      return true;
    }

    return false;
  }

  return async function handleHttp(req, res) {
    setCors(res, req);
    if (req.method === "OPTIONS") {
      res.writeHead(204);
      res.end();
      return;
    }

    const url = new URL(req.url || "/", `http://${req.headers.host || "localhost"}`);
    const pathname = url.pathname;
    const isGetOrHead = req.method === "GET" || req.method === "HEAD";

    try {
      // ---- HEALTH ----
      if ((pathname === "/health" || pathname === "/healthz") && isGetOrHead) {
        const dbHealthy = await db.isHealthy();
        const localAssets = fs.existsSync(path.join(publicDir, "godot/a/index.json"));
        const webReady = fs.existsSync(path.join(webDir, "index.html"));
        return sendJson(req, res, dbHealthy ? 200 : 503, {
          ok: dbHealthy,
          db: db.mode,
          dbHealthy,
          build: CLIENT_BUILD,
          assetMode: localAssets ? "local" : cdn.enabled ? "cdn" : "none",
          assetCdn: cdn.enabled ? cdn.godotBase : "",
          webClient: webReady,
          coopCoep: coopCoepMode,
          uptimeSec: Math.floor(process.uptime()),
          online: typeof stats.onlineCount === "function" ? stats.onlineCount() : 0,
          rooms: typeof stats.roomCount === "function" ? stats.roomCount() : 0,
          memoryMb: Math.round(process.memoryUsage().rss / (1024 * 1024)),
        });
      }

      // ---- AUTH ----
      if (pathname === "/api/auth" && req.method === "POST") {
        if (rateLimitEnabled && !limiter.allow(`auth:${getClientIp(req)}`, 30, 60000)) {
          return sendJson(req, res, 429, {
            ok: false,
            code: "RATE_LIMIT",
            error: "Thử đăng nhập quá nhiều lần, vui lòng chờ 1 phút.",
          });
        }
        const body = await readJsonBody(req);
        let acct = null;
        if (typeof body.resume === "string" && body.resume.length >= 40) {
          const old = await db.findSessionByResume(body.resume);
          if (!old) {
            return sendJson(req, res, 401, {
              ok: false,
              code: "SESSION_EXPIRED",
              error: "Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.",
            });
          }
          acct = await db.findAccountByUsername(old.username);
        } else {
          const authRes = await db.authenticate(body.username, body.password);
          if (!authRes.ok) {
            return sendJson(req, res, 401, authRes);
          }
          acct = authRes.account;
        }
        if (!acct) {
          return sendJson(req, res, 401, {
            ok: false,
            code: "INVALID_CREDENTIALS",
            error: "Tài khoản không tồn tại.",
          });
        }
        const session = await db.createSession(acct);
        const char = await db.getCharacterByAccount(acct.accountId);
        const secureAttr = isHttpsRequest(req) ? "; Secure" : "";
        return sendJson(
          req,
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
            "Set-Cookie": `bb_session=${session.sessionCookie}; HttpOnly; Path=/; SameSite=Lax${secureAttr}`,
          }
        );
      }

      // ---- REGISTER ----
      if (pathname === "/api/register/status" && isGetOrHead) {
        return sendJson(req, res, 200, {
          ok: true,
          state: "open",
          quiz: false,
          regcode: false,
        });
      }

      if (pathname === "/api/register/captcha" && isGetOrHead) {
        if (rateLimitEnabled && !limiter.allow(`cap:${getClientIp(req)}`, 30, 60000)) {
          return sendJson(req, res, 429, { ok: false, error: "Quá nhiều yêu cầu captcha." });
        }
        const cap = captchas.issue();
        return sendJson(req, res, 200, {
          ok: true,
          id: cap.id,
          png: cap.pngBase64,
          email: false,
          quiz: false,
          regcode: false,
        });
      }

      if (pathname === "/api/register" && req.method === "POST") {
        if (rateLimitEnabled && !limiter.allow(`reg:${getClientIp(req)}`, 10, 60000)) {
          return sendJson(req, res, 429, {
            ok: false,
            code: "RATE_LIMIT",
            error: "Đăng ký quá nhanh, vui lòng thử lại sau 1 phút.",
          });
        }
        const body = await readJsonBody(req);
        if (!captchas.verify(body.captchaId, body.captcha)) {
          return sendJson(req, res, 400, {
            ok: false,
            code: "CAPTCHA",
            error: "Mã xác nhận không đúng hoặc đã hết hạn.",
            renew: true,
          });
        }
        const created = await db.createAccount(body.username, body.password);
        if (!created.ok) {
          return sendJson(req, res, 400, { ...created, renew: true });
        }
        return sendJson(req, res, 200, {
          ok: true,
          username: created.account.username,
        });
      }

      // ---- AUXILIARY GAME HTTP ENDPOINTS ----
      if (pathname === "/version.txt" || pathname === "/godot/version.txt") {
        return sendText(req, res, 200, "text/plain; charset=utf-8", CLIENT_BUILD);
      }
      if (pathname === "/hall-theme.xml") {
        return sendText(req, res, 200, "application/xml; charset=utf-8", '<hall theme="native"/>', {
          "Cache-Control": "public, max-age=300",
        });
      }
      if (pathname === "/xml/ActivityTemplate_table.xml") {
        return sendText(req, res, 200, "application/xml; charset=utf-8", "<root/>", {
          "Cache-Control": "public, max-age=300",
        });
      }
      if (pathname === "/getuseraward.php") {
        return sendText(req, res, 200, "text/plain; charset=utf-8", "0");
      }
      if (pathname === "/godot/pcdl.json" || pathname === "/pcdl.json") {
        const mirrors = cdn.mirrorOrigin ? [cdn.mirrorOrigin] : [];
        return sendJson(
          req,
          res,
          200,
          {
            v: 1,
            on: mirrors.length > 0,
            av: mirrors.length > 0,
            a: mirrors.length > 0,
            mirrors,
          },
          { "Cache-Control": "public, max-age=60" }
        );
      }
      if (pathname === "/api/client-error" && req.method === "POST") {
        const errDoc = await readJsonBody(req).catch(() => ({}));
        if (Array.isArray(errDoc.items) && errDoc.items.length > 0) {
          console.warn("[client-error]", errDoc.pf, errDoc.v, errDoc.items[0]?.m);
        }
        return sendJson(req, res, 200, { ok: true });
      }
      if (pathname === "/api/match-history" && isGetOrHead) {
        const rows = await db.listMatches(20);
        return sendJson(req, res, 200, { ok: true, items: rows, total: rows.length, page: 1 });
      }
      if (pathname === "/api/chat-faces") {
        return sendJson(req, res, 200, { ok: true, items: [] }, { "Cache-Control": "public, max-age=300" });
      }
      if (pathname === "/api/name-styles.xml") {
        return sendText(req, res, 200, "application/xml; charset=utf-8", "<styles/>", {
          "Cache-Control": "public, max-age=300",
        });
      }
      if (pathname === "/api/couples.json") {
        return sendJson(req, res, 200, { ok: true, couples: [] });
      }

      // ---- STATIC ASSETS (/godot/{a,av,lv,mu}/* and /{a,av,lv,mu}/*) ----
      if (isGetOrHead && tryServeGameAsset(req, res, pathname)) {
        return;
      }

      // ---- GODOT WEB HTML5 CLIENT (server/web/ -> / and /godot/) ----
      if (isGetOrHead && tryServeWebClient(req, res, pathname)) {
        return;
      }

      // ---- FALLBACK LANDING PAGE (when Godot Web export is not in server/web/ yet) ----
      if (isGetOrHead && (pathname === "/" || pathname === "/godot/")) {
        const dbHealthy = await db.isHealthy();
        const html = renderStatusHtml({
          req,
          dbMode: db.mode,
          dbHealthy,
          online: typeof stats.onlineCount === "function" ? stats.onlineCount() : 0,
          rooms: typeof stats.roomCount === "function" ? stats.roomCount() : 0,
          uptimeSec: Math.floor(process.uptime()),
          cdn,
          localAssets: fs.existsSync(path.join(publicDir, "godot/a/index.json")),
          webReady: fs.existsSync(path.join(webDir, "index.html")),
        });
        return sendText(req, res, 200, "text/html; charset=utf-8", html);
      }

      sendJson(req, res, 404, { ok: false, error: "Not found" });
    } catch (err) {
      if (err.message === "BODY_TOO_LARGE") {
        return sendJson(req, res, 413, { ok: false, error: "Payload too large" });
      }
      console.error("[http] error on", pathname, err);
      sendJson(req, res, 500, { ok: false, error: "Internal server error" });
    }
  };
}
