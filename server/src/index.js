import "dotenv/config";
import http from "http";
import os from "os";
import path from "path";
import { pathToFileURL } from "url";
import { WebSocketServer } from "ws";
import { Database } from "./db.js";
import { createHttpHandler } from "./http_routes.js";
import { GameWorld } from "./game_ws.js";
import { CLIENT_BUILD, hasLocalAssets, hasWebClient } from "./catalog.js";

function lanAddresses() {
  const out = [];
  const nets = os.networkInterfaces();
  for (const entries of Object.values(nets)) {
    for (const info of entries || []) {
      if (info.family === "IPv4" && !info.internal) out.push(info.address);
    }
  }
  return out;
}

export async function startServer(options = {}) {
  const host = options.host ?? process.env.HOST ?? "0.0.0.0";
  const port = Number(options.port ?? process.env.PORT ?? 8080);
  const publicHost =
    options.publicHost ??
    process.env.PUBLIC_HOST ??
    process.env.RENDER_EXTERNAL_HOSTNAME ??
    "127.0.0.1";
  const publicPort = Number(
    options.publicPort ??
      process.env.PUBLIC_PORT ??
      (process.env.RENDER_EXTERNAL_HOSTNAME ? 443 : port)
  );
  const heartbeatMs = Number(options.wsHeartbeatMs ?? process.env.WS_HEARTBEAT_MS ?? 25000);

  const db = new Database();
  await db.init({
    uri: options.mongoUri ?? process.env.MONGODB_URI ?? "",
    dbName: options.dbName ?? process.env.DB_NAME ?? "bangbang",
    required: options.mongoRequired ?? process.env.MONGODB_REQUIRED === "true",
  });

  const world = new GameWorld(db, { gateHost: publicHost, gatePort: publicPort });
  const httpHandler = createHttpHandler(
    db,
    {
      onlineCount: () => world.online.size,
      roomCount: () => world.rooms.size,
    },
    {
      assetCdnUrl: options.assetCdnUrl,
      assetCdnStripGodot: options.assetCdnStripGodot,
      injectAssetCdn: options.injectAssetCdn,
      coopCoepMode: options.coopCoepMode,
      rateLimit: options.rateLimit,
      webDir: options.webDir,
      publicDir: options.publicDir,
    }
  );

  const server = http.createServer(httpHandler);
  // Render recommended timeouts to avoid 502 Bad Gateway with upstream load balancer
  server.keepAliveTimeout = 65000;
  server.headersTimeout = 66000;

  const wss = new WebSocketServer({
    noServer: true,
    maxPayload: 512 * 1024,
    perMessageDeflate: false, // tiny low-latency binary game frames
  });

  server.on("upgrade", (req, socket, head) => {
    const url = new URL(req.url || "/", `http://${req.headers.host || "localhost"}`);
    const match = /^\/ws\/(login|gate|comm)$/.exec(url.pathname);
    if (!match) {
      socket.write("HTTP/1.1 404 Not Found\r\n\r\n");
      socket.destroy();
      return;
    }
    const role = match[1];
    wss.handleUpgrade(req, socket, head, (ws) => {
      world.attachSocket(ws, role);
    });
  });

  // Periodic WebSocket ping/pong heartbeat (prevents Render proxy idle disconnects + clears dead sockets)
  let heartbeatTimer = null;
  if (heartbeatMs > 0) {
    heartbeatTimer = setInterval(() => {
      for (const ws of wss.clients) {
        if (ws.isAlive === false) {
          ws.terminate();
          continue;
        }
        ws.isAlive = false;
        try {
          ws.ping();
        } catch {
          ws.terminate();
        }
      }
    }, heartbeatMs);
    heartbeatTimer.unref?.();
  }

  await new Promise((resolve) => server.listen(port, host, resolve));
  const actualPort = server.address().port;
  if (!process.env.PUBLIC_PORT && !process.env.RENDER_EXTERNAL_HOSTNAME && !options.publicPort) {
    world.gatePort = actualPort;
  }

  if (!options.silent) {
    const cdnUrl = (options.assetCdnUrl ?? process.env.ASSET_CDN_URL ?? "").trim();
    const assetSummary = hasLocalAssets()
      ? "Local (server/public/godot)"
      : cdnUrl
        ? `External CDN (${cdnUrl})`
        : "Not configured (set ASSET_CDN_URL for Cloudflare R2)";
    console.log(`\n=== BangBang / Tank Ghost Server (build ${CLIENT_BUILD}) ===`);
    console.log(`Storage : ${db.mode === "mongodb" ? "MongoDB Atlas" : "Local JSON fallback"}`);
    console.log(`Assets  : ${assetSummary}`);
    console.log(`WebApp  : ${hasWebClient() ? "Godot Web HTML5 ready (/ & /godot/)" : "Status page (export Godot Web into server/web/)"}`);
    if (process.env.RENDER_EXTERNAL_URL) {
      console.log(`Public  : ${process.env.RENDER_EXTERNAL_URL}`);
    } else {
      console.log(`PC Local: http://127.0.0.1:${actualPort}`);
      for (const ip of lanAddresses()) {
        console.log(`LAN     : http://${ip}:${actualPort}`);
      }
    }
    console.log(`Health  : http://127.0.0.1:${actualPort}/health`);
    console.log(`WS      : ws://127.0.0.1:${actualPort}/ws/login | /ws/gate | /ws/comm\n`);
  }

  let closed = false;
  async function close() {
    if (closed) return;
    closed = true;
    if (heartbeatTimer) {
      clearInterval(heartbeatTimer);
      heartbeatTimer = null;
    }
    for (const room of world.rooms.values()) {
      if (room.battle) room.battle.stop();
    }
    for (const ws of wss.clients) {
      try {
        ws.close(1001, "Server shutting down");
      } catch {
        ws.terminate();
      }
    }
    await new Promise((resolve) => server.close(resolve));
    await db.close();
  }

  return {
    server,
    wss,
    db,
    world,
    port: actualPort,
    close,
  };
}

// Run directly when executed as main entry (handles Windows paths & spaces)
const isMain = process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href;
if (isMain) {
  startServer()
    .then((app) => {
      const shutdown = (signal) => {
        console.log(`\n[server] Received ${signal}, shutting down gracefully...`);
        const forceTimer = setTimeout(() => process.exit(1), 8000);
        forceTimer.unref?.();
        app.close().then(
          () => process.exit(0),
          () => process.exit(1)
        );
      };
      process.on("SIGTERM", () => shutdown("SIGTERM"));
      process.on("SIGINT", () => shutdown("SIGINT"));
    })
    .catch((err) => {
      console.error("[server] Fatal startup error:", err);
      process.exit(1);
    });
}
