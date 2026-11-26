import "dotenv/config";
import crypto from "crypto";
import fs from "fs";
import https from "https";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SERVER_DIR = path.resolve(__dirname, "..");
const SOURCE_DIR = path.join(SERVER_DIR, "public/godot");
const CHECKPOINT_PATH = path.join(SERVER_DIR, "data/.r2_uploaded.json");

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
  ".bin": "application/octet-stream",
  ".pck": "application/octet-stream",
};

const SHORT_CACHE_KEYS = new Set([
  "godot/a/index.json",
  "godot/a/i/index.json",
  "godot/a/l/index.json",
  "godot/a/s/index.json",
  "godot/a/e/index.json",
]);

function rfc3986Encode(str) {
  return encodeURIComponent(str).replace(/[!'()*]/g, (c) => `%${c.charCodeAt(0).toString(16).toUpperCase()}`);
}

function encodeS3Path(bucket, key) {
  const segs = key.split("/").map(rfc3986Encode).join("/");
  return `/${rfc3986Encode(bucket)}/${segs}`;
}

function sha256Hex(data) {
  return crypto.createHash("sha256").update(data).digest("hex");
}

function hmac(key, data) {
  return crypto.createHmac("sha256", key).update(data).digest();
}

export function signR2Request({
  method,
  host,
  canonicalUri,
  canonicalQuery = "",
  headers = {},
  payloadHash,
  accessKeyId,
  secretAccessKey,
  now = new Date(),
}) {
  const iso = now.toISOString().replace(/[:-]|\.\d{3}/g, "");
  const dateStamp = iso.slice(0, 8);
  const allHeaders = {
    host,
    "x-amz-content-sha256": payloadHash,
    "x-amz-date": iso,
  };
  for (const [k, v] of Object.entries(headers)) {
    allHeaders[k.toLowerCase()] = String(v).trim();
  }
  const sortedKeys = Object.keys(allHeaders).sort();
  const canonicalHeaders = sortedKeys.map((k) => `${k}:${allHeaders[k]}\n`).join("");
  const signedHeaders = sortedKeys.join(";");
  const canonicalRequest = [
    method,
    canonicalUri,
    canonicalQuery,
    canonicalHeaders,
    signedHeaders,
    payloadHash,
  ].join("\n");

  const scope = `${dateStamp}/auto/s3/aws4_request`;
  const stringToSign = ["AWS4-HMAC-SHA256", iso, scope, sha256Hex(canonicalRequest)].join("\n");

  const kDate = hmac(`AWS4${secretAccessKey}`, dateStamp);
  const kRegion = hmac(kDate, "auto");
  const kService = hmac(kRegion, "s3");
  const kSigning = hmac(kService, "aws4_request");
  const signature = crypto.createHmac("sha256", kSigning).update(stringToSign).digest("hex");

  return {
    ...allHeaders,
    authorization: `AWS4-HMAC-SHA256 Credential=${accessKeyId}/${scope}, SignedHeaders=${signedHeaders}, Signature=${signature}`,
  };
}

function cacheControlForKey(key) {
  if (key.startsWith("godot/av/")) return "public, max-age=31536000, immutable";
  if (SHORT_CACHE_KEYS.has(key)) return "public, max-age=300, stale-while-revalidate=600";
  return "public, max-age=86400, stale-while-revalidate=604800";
}

function contentTypeForFile(filePath) {
  const ext = path.extname(filePath).toLowerCase();
  return MIME[ext] || "application/octet-stream";
}

function walkFiles(dir, baseDir, out = []) {
  const entries = fs.readdirSync(dir, { withFileTypes: true });
  for (const e of entries) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) {
      walkFiles(full, baseDir, out);
    } else if (e.isFile()) {
      const stat = fs.statSync(full);
      const rel = path.relative(baseDir, full).split(path.sep).join("/");
      out.push({
        absPath: full,
        key: `godot/${rel}`,
        size: stat.size,
        mtimeMs: Math.floor(stat.mtimeMs),
      });
    }
  }
  return out;
}

function loadCheckpoint() {
  try {
    if (fs.existsSync(CHECKPOINT_PATH)) {
      return JSON.parse(fs.readFileSync(CHECKPOINT_PATH, "utf8"));
    }
  } catch {}
  return {};
}

function saveCheckpoint(map) {
  fs.mkdirSync(path.dirname(CHECKPOINT_PATH), { recursive: true });
  const tmp = `${CHECKPOINT_PATH}.tmp`;
  fs.writeFileSync(tmp, JSON.stringify(map), "utf8");
  fs.renameSync(tmp, CHECKPOINT_PATH);
}

function requestR2({ agent, method, host, canonicalUri, canonicalQuery = "", headers, body }) {
  return new Promise((resolve, reject) => {
    const fullPath = canonicalQuery ? `${canonicalUri}?${canonicalQuery}` : canonicalUri;
    const req = https.request(
      {
        agent,
        hostname: host,
        port: 443,
        method,
        path: fullPath,
        headers,
        timeout: 60000,
      },
      (res) => {
        const chunks = [];
        res.on("data", (c) => chunks.push(c));
        res.on("end", () => {
          resolve({ status: res.statusCode || 0, body: Buffer.concat(chunks).toString("utf8") });
        });
      }
    );
    req.on("timeout", () => {
      req.destroy(new Error("Request timeout"));
    });
    req.on("error", reject);
    if (body && body.length > 0) req.write(body);
    req.end();
  });
}

async function listRemoteObjects({ agent, host, bucket, accessKeyId, secretAccessKey }) {
  const remote = new Map();
  let token = "";
  const emptyHash = sha256Hex("");
  const canonicalUri = `/${rfc3986Encode(bucket)}`;

  while (true) {
    const params = [
      ["list-type", "2"],
      ["max-keys", "1000"],
      ["prefix", "godot/"],
    ];
    if (token) params.push(["continuation-token", token]);
    params.sort((a, b) => (a[0] < b[0] ? -1 : a[0] > b[0] ? 1 : 0));
    const canonicalQuery = params.map(([k, v]) => `${rfc3986Encode(k)}=${rfc3986Encode(v)}`).join("&");

    const signedHeaders = signR2Request({
      method: "GET",
      host,
      canonicalUri,
      canonicalQuery,
      payloadHash: emptyHash,
      accessKeyId,
      secretAccessKey,
    });
    const res = await requestR2({
      agent,
      method: "GET",
      host,
      canonicalUri,
      canonicalQuery,
      headers: signedHeaders,
    });
    if (res.status !== 200) {
      throw new Error(`ListObjectsV2 failed HTTP ${res.status}: ${res.body.slice(0, 300)}`);
    }

    const contentRe = /<Contents>([\s\S]*?)<\/Contents>/g;
    let m;
    while ((m = contentRe.exec(res.body)) !== null) {
      const block = m[1];
      const keyMatch = /<Key>([\s\S]*?)<\/Key>/.exec(block);
      const sizeMatch = /<Size>(\d+)<\/Size>/.exec(block);
      if (keyMatch && sizeMatch) {
        const key = keyMatch[1]
          .replace(/&amp;/g, "&")
          .replace(/&lt;/g, "<")
          .replace(/&gt;/g, ">")
          .replace(/&quot;/g, '"')
          .replace(/&apos;/g, "'");
        remote.set(key, Number(sizeMatch[1]));
      }
    }

    const truncMatch = /<IsTruncated>(true|false)<\/IsTruncated>/.exec(res.body);
    const nextMatch = /<NextContinuationToken>([\s\S]*?)<\/NextContinuationToken>/.exec(res.body);
    if (truncMatch?.[1] === "true" && nextMatch?.[1]) {
      token = nextMatch[1].replace(/&amp;/g, "&");
    } else {
      break;
    }
  }
  return remote;
}

async function uploadOneWithRetry({ agent, host, bucket, accessKeyId, secretAccessKey, item }) {
  const buf = fs.readFileSync(item.absPath);
  const payloadHash = sha256Hex(buf);
  const canonicalUri = encodeS3Path(bucket, item.key);
  const contentType = contentTypeForFile(item.absPath);
  const cacheControl = cacheControlForKey(item.key);

  let lastErr = null;
  for (let attempt = 1; attempt <= 5; attempt++) {
    try {
      const headers = signR2Request({
        method: "PUT",
        host,
        canonicalUri,
        headers: {
          "content-type": contentType,
          "cache-control": cacheControl,
        },
        payloadHash,
        accessKeyId,
        secretAccessKey,
      });
      headers["content-length"] = String(buf.length);

      const res = await requestR2({
        agent,
        method: "PUT",
        host,
        canonicalUri,
        headers,
        body: buf,
      });
      if (res.status >= 200 && res.status < 300) {
        return;
      }
      const errMsg = `HTTP ${res.status}: ${res.body.slice(0, 200)}`;
      if (res.status === 401 || res.status === 403 || res.status === 404) {
        throw new Error(`AUTH_OR_BUCKET_ERROR ${errMsg}`);
      }
      lastErr = new Error(errMsg);
    } catch (err) {
      if (String(err.message || "").startsWith("AUTH_OR_BUCKET_ERROR")) throw err;
      lastErr = err;
    }
    const backoff = Math.min(8000, 400 * 2 ** (attempt - 1));
    await new Promise((r) => setTimeout(r, backoff));
  }
  throw lastErr || new Error(`Failed uploading ${item.key}`);
}

function formatMB(bytes) {
  return (bytes / (1024 * 1024)).toFixed(1);
}

async function main() {
  const args = new Set(process.argv.slice(2));
  const dryRun = args.has("--dry-run");
  const forceAll = args.has("--force");
  const syncRemote = args.has("--sync-remote");

  if (!fs.existsSync(SOURCE_DIR)) {
    console.error(`[upload_r2] Source folder not found: ${SOURCE_DIR}`);
    process.exit(1);
  }

  const accountId = (process.env.R2_ACCOUNT_ID || "").trim();
  const bucket = (process.env.R2_BUCKET || "bb4399-assets").trim();
  const accessKeyId = (process.env.R2_ACCESS_KEY_ID || "").trim();
  const secretAccessKey = (process.env.R2_SECRET_ACCESS_KEY || "").trim();
  const concurrency = Math.max(1, Math.min(48, Number(process.env.R2_CONCURRENCY || 24)));

  console.log(`[upload_r2] Scanning ${SOURCE_DIR} ...`);
  const allFiles = walkFiles(SOURCE_DIR, SOURCE_DIR);
  const totalBytes = allFiles.reduce((s, f) => s + f.size, 0);
  console.log(`[upload_r2] Found ${allFiles.length.toLocaleString()} files (${formatMB(totalBytes)} MB).`);

  if (dryRun) {
    // Verify SigV4 signer + header assignment cleanly without network
    const sample = allFiles[0];
    const sig = signR2Request({
      method: "PUT",
      host: `${accountId || "example-account"}.r2.cloudflarestorage.com`,
      canonicalUri: encodeS3Path(bucket, sample.key),
      headers: {
        "content-type": contentTypeForFile(sample.absPath),
        "cache-control": cacheControlForKey(sample.key),
      },
      payloadHash: sha256Hex("test"),
      accessKeyId: "AKIAEXAMPLE",
      secretAccessKey: "SECRETEXAMPLE",
    });
    if (!sig.authorization.startsWith("AWS4-HMAC-SHA256 ")) {
      throw new Error("Invalid SigV4 output");
    }
    console.log(`[upload_r2] Dry-run OK! Sample key=${sample.key}, Content-Type=${contentTypeForFile(sample.absPath)}, Cache-Control=${cacheControlForKey(sample.key)}`);
    return;
  }

  if (!accountId || !accessKeyId || !secretAccessKey) {
    console.error(
      "[upload_r2] Thiếu thông tin R2 trong server/.env! Hãy điền đủ:\n" +
        "  R2_ACCOUNT_ID=...\n" +
        "  R2_BUCKET=bb4399-assets\n" +
        "  R2_ACCESS_KEY_ID=...\n" +
        "  R2_SECRET_ACCESS_KEY=..."
    );
    process.exit(1);
  }

  const host = `${accountId}.r2.cloudflarestorage.com`;
  const agent = new https.Agent({ keepAlive: true, maxSockets: concurrency + 8 });
  const checkpoint = forceAll ? {} : loadCheckpoint();

  if (syncRemote) {
    console.log(`[upload_r2] Syncing existing objects from R2 bucket "${bucket}"...`);
    const remote = await listRemoteObjects({ agent, host, bucket, accessKeyId, secretAccessKey });
    console.log(`[upload_r2] Found ${remote.size.toLocaleString()} objects already on R2.`);
    for (const f of allFiles) {
      if (remote.get(f.key) === f.size) {
        checkpoint[f.key] = { size: f.size, mtimeMs: f.mtimeMs };
      }
    }
    saveCheckpoint(checkpoint);
  }

  const queue = allFiles.filter((f) => {
    if (forceAll) return true;
    const prev = checkpoint[f.key];
    return !prev || prev.size !== f.size || prev.mtimeMs !== f.mtimeMs;
  });

  const skippedCount = allFiles.length - queue.length;
  const uploadBytesTotal = queue.reduce((s, f) => s + f.size, 0);
  console.log(
    `[upload_r2] Bucket: ${bucket} | Concurrency: ${concurrency} | Skipped: ${skippedCount.toLocaleString()} | To upload: ${queue.length.toLocaleString()} files (${formatMB(uploadBytesTotal)} MB)`
  );

  if (queue.length === 0) {
    console.log("[upload_r2] All files are already up to date on Cloudflare R2!");
    agent.destroy();
    return;
  }

  let cursor = 0;
  let doneCount = 0;
  let doneBytes = 0;
  let errCount = 0;
  let aborted = false;
  let fatalErr = null;
  const startedAt = Date.now();
  let lastPrintAt = 0;
  let sinceSave = 0;

  const flushCheckpoint = () => {
    try {
      saveCheckpoint(checkpoint);
      sinceSave = 0;
    } catch {}
  };

  process.on("SIGINT", () => {
    aborted = true;
    console.log("\n[upload_r2] Caught Ctrl+C — saving progress checkpoint so next run resumes cleanly...");
    flushCheckpoint();
  });

  const printProgress = (force = false) => {
    const now = Date.now();
    if (!force && now - lastPrintAt < 1000) return;
    lastPrintAt = now;
    const elapsedSec = Math.max(0.1, (now - startedAt) / 1000);
    const mbps = doneBytes / (1024 * 1024) / elapsedSec;
    const remBytes = Math.max(0, uploadBytesTotal - doneBytes);
    const etaSec = mbps > 0.01 ? Math.round(remBytes / (1024 * 1024) / mbps) : 0;
    const pct = ((doneCount / queue.length) * 100).toFixed(1);
    process.stdout.write(
      `\r[upload_r2] ${doneCount.toLocaleString()}/${queue.length.toLocaleString()} (${pct}%) | ${formatMB(doneBytes)}/${formatMB(uploadBytesTotal)} MB | ${mbps.toFixed(1)} MB/s | ETA ${etaSec}s | err: ${errCount}   `
    );
  };

  async function worker() {
    while (!aborted && !fatalErr) {
      const idx = cursor++;
      if (idx >= queue.length) break;
      const item = queue[idx];
      try {
        await uploadOneWithRetry({ agent, host, bucket, accessKeyId, secretAccessKey, item });
        checkpoint[item.key] = { size: item.size, mtimeMs: item.mtimeMs };
        doneCount++;
        doneBytes += item.size;
        sinceSave++;
        if (sinceSave >= 200) flushCheckpoint();
        printProgress();
      } catch (err) {
        if (String(err.message || "").startsWith("AUTH_OR_BUCKET_ERROR")) {
          fatalErr = err;
          aborted = true;
          break;
        }
        errCount++;
        console.error(`\n[upload_r2] Failed ${item.key}: ${err.message}`);
      }
    }
  }

  await Promise.all(Array.from({ length: concurrency }, () => worker()));
  flushCheckpoint();
  printProgress(true);
  console.log("");
  agent.destroy();

  if (fatalErr) {
    console.error(`[upload_r2] Stopped due to authentication/bucket error: ${fatalErr.message}`);
    process.exit(1);
  }
  if (aborted) {
    console.log("[upload_r2] Paused safely. Run `npm run upload:r2` again to resume where you left off.");
    process.exit(130);
  }
  if (errCount > 0) {
    console.warn(`[upload_r2] Finished with ${errCount} failed file(s). Run \`npm run upload:r2\` again to retry only the missing files.`);
    process.exit(1);
  }
  const sec = ((Date.now() - startedAt) / 1000).toFixed(1);
  console.log(`[upload_r2] DONE! Uploaded ${doneCount.toLocaleString()} files (${formatMB(doneBytes)} MB) to R2 bucket "${bucket}" in ${sec}s.`);
}

main().catch((err) => {
  console.error("[upload_r2] Fatal error:", err);
  process.exit(1);
});
