import "dotenv/config";
import http from "http";
import os from "os";
import path from "path";
import { pathToFileURL } from "url";
import { WebSocketServer } from "ws";
import { Database } from "./db.js";
import { createHttpHandler } from "./http_routes.js";
import { GameWorld } from "./game_ws.js";

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
  const db = new Database();
  await db.init({
    uri: options.mongoUri ?? process.env.MONGODB_URI ?? "",
    dbName: options.dbName ?? process.env.DB_NAME ?? "bangbang",
    required: options.mongoRequired ?? process.env.MONGODB_REQUIRED === "true",
  });

  const world = new GameWorld(db, { gateHost: "127.0.0.1", gatePort: port });
  const httpHandler = createHttpHandler(db, {
    onlineCount: () => world.online.size,
    roomCount: () => world.rooms.size,
  });

  const server = http.createServer(httpHandler);
  const wss = new WebSocketServer({ noServer: true, maxPayload: 512 * 1024 });

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

  await new Promise((resolve) => server.listen(port, host, resolve));
  const actualPort = server.address().port;
  world.gatePort = actualPort;

  if (!options.silent) {
    console.log(`\n=== BangBang / Tank Ghost Server ===`);
    console.log(`Storage : ${db.mode === "mongodb" ? "MongoDB Atlas" : "Local JSON fallback (update server/.env to enable MongoDB)"}`);
    console.log(`PC Local: http://127.0.0.1:${actualPort}`);
    for (const ip of lanAddresses()) {
      console.log(`LAN     : http://${ip}:${actualPort}`);
    }
    console.log(`Health  : http://127.0.0.1:${actualPort}/health`);
    console.log(`WS      : ws://127.0.0.1:${actualPort}/ws/login | /ws/gate | /ws/comm\n`);
  }

  return {
    server,
    wss,
    db,
    world,
    port: actualPort,
    async close() {
      for (const ws of wss.clients) ws.terminate();
      for (const room of world.rooms.values()) {
        if (room.battle) room.battle.stop();
      }
      await new Promise((resolve) => server.close(resolve));
      await db.close();
    },
  };
}

// Run directly when executed as main entry (handles Windows paths & spaces)
const isMain = process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href;
if (isMain) {
  startServer().catch((err) => {
    console.error("[server] Fatal startup error:", err);
    process.exit(1);
  });
}
