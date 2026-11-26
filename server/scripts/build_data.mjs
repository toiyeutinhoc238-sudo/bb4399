import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SERVER_DIR = path.resolve(__dirname, "..");
const ROOT_DIR = path.resolve(SERVER_DIR, "..");
const GENERATED_DIR = path.join(SERVER_DIR, "src/generated");
const CLIENT_PROTO_DIR = path.join(ROOT_DIR, "client_godot/net/battle_protocol");
const ASSET_DIR = path.join(SERVER_DIR, "public/godot/a");

function parseGdDict(filePath, constName) {
  const txt = fs.readFileSync(filePath, "utf8");
  const idx = txt.indexOf(`const ${constName}:`);
  if (idx < 0) throw new Error(`Missing const ${constName} in ${filePath}`);
  const start = txt.indexOf("{", idx);
  let depth = 0;
  let end = start;
  let inStr = false;
  let esc = false;
  for (let i = start; i < txt.length; i++) {
    const ch = txt[i];
    if (esc) {
      esc = false;
      continue;
    }
    if (inStr) {
      if (ch === "\\") esc = true;
      else if (ch === '"') inStr = false;
      continue;
    }
    if (ch === '"') {
      inStr = true;
      continue;
    }
    if (ch === "{") depth++;
    else if (ch === "}") {
      depth--;
      if (depth === 0) {
        end = i + 1;
        break;
      }
    }
  }
  const raw = txt.slice(start, end).replace(/(\r?\n\s*)(\d+)\s*:/g, '$1"$2":');
  return JSON.parse(raw);
}

function readJsonSafe(filePath, fallback = null) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return fallback;
  }
}

function extractMapInfo(id, doc) {
  const width = Number(doc?.header?.mapWidth) || 1800;
  const height = Number(doc?.header?.mapHeight) || 1368;
  const duration = Number(doc?.header?.gameSecond) || 180;
  const killTarget = Number(doc?.header?.killNum) || 20;
  const spawns = { 1: [], 2: [] };
  if (Array.isArray(doc?.chunks)) {
    for (const chunk of doc.chunks) {
      if ((chunk.tag === 4 || chunk.tag === 3) && Array.isArray(chunk.data?.points)) {
        for (const pt of chunk.data.points) {
          const camp = Number(pt.iCamp);
          if ((camp === 1 || camp === 2) && Number.isFinite(pt.iCenterX) && Number.isFinite(pt.iCenterY)) {
            spawns[camp].push({ x: Math.round(pt.iCenterX), y: Math.round(pt.iCenterY) });
          }
        }
        if (spawns[1].length > 0 && spawns[2].length > 0) break;
      }
    }
  }
  if (spawns[1].length === 0) spawns[1].push({ x: 240, y: Math.round(height / 2) });
  if (spawns[2].length === 0) spawns[2].push({ x: Math.max(480, width - 240), y: Math.round(height / 2) });
  return { id: Number(id), width, height, duration, killTarget, spawns };
}

fs.mkdirSync(GENERATED_DIR, { recursive: true });

// 1. Build protocol_data.json
const schemaFile = path.join(CLIENT_PROTO_DIR, "protocol_schema.gd");
const idsFile = path.join(CLIENT_PROTO_DIR, "message_ids.gd");
if (fs.existsSync(schemaFile) && fs.existsSync(idsFile)) {
  const schema = parseGdDict(schemaFile, "CLASSES");
  const byId = parseGdDict(idsFile, "BY_ID");
  const protoOut = path.join(GENERATED_DIR, "protocol_data.json");
  fs.writeFileSync(protoOut, JSON.stringify({ schema, byId }), "utf8");
  const kb = (fs.statSync(protoOut).size / 1024).toFixed(1);
  console.log(`[build_data] Wrote protocol_data.json (${Object.keys(schema).length} classes, ${Object.keys(byId).length} IDs, ${kb} KB)`);
} else {
  console.warn("[build_data] Skipped protocol_data.json (client_godot protocol sources not found)");
}

// 2. Build catalog_data.json
const indexDoc = readJsonSafe(path.join(ASSET_DIR, "index.json"));
const garageDoc = readJsonSafe(path.join(ASSET_DIR, "l/garage.json"));
if (indexDoc) {
  const tanks = {};
  for (const [tid, ext] of Object.entries(indexDoc.tanks || {})) {
    const num = Number(ext);
    if (Number.isFinite(num) && num > 0) tanks[tid] = num;
  }

  const skills = {};
  for (const [tid, row] of Object.entries(garageDoc?.tanks || {})) {
    if (Array.isArray(row?.skills)) {
      const list = row.skills.map(Number).filter((n) => Number.isFinite(n) && n > 0);
      if (list.length > 0) skills[tid] = list;
    }
  }

  const maps = {};
  for (const [mid, folder] of Object.entries(indexDoc.maps || {})) {
    const mapPath = path.join(ASSET_DIR, String(folder), "map.json");
    const doc = readJsonSafe(mapPath);
    maps[mid] = extractMapInfo(mid, doc);
  }

  // Also grab CLIENT_BUILD from client_godot/ui/settings.gd
  let clientBuild = "G6b835";
  const settingsPath = path.join(ROOT_DIR, "client_godot/ui/settings.gd");
  if (fs.existsSync(settingsPath)) {
    const m = fs.readFileSync(settingsPath, "utf8").match(/const BUILD:\s*String\s*=\s*"([^"]+)"/);
    if (m) clientBuild = m[1];
  }

  const catalogOut = path.join(GENERATED_DIR, "catalog_data.json");
  fs.writeFileSync(catalogOut, JSON.stringify({ clientBuild, tanks, skills, maps }), "utf8");
  const kb = (fs.statSync(catalogOut).size / 1024).toFixed(1);
  console.log(
    `[build_data] Wrote catalog_data.json (build=${clientBuild}, ${Object.keys(tanks).length} tanks, ${Object.keys(skills).length} skillsets, ${Object.keys(maps).length} maps, ${kb} KB)`
  );
} else {
  console.warn("[build_data] Skipped catalog_data.json (server/public/godot/a/index.json not found)");
}
