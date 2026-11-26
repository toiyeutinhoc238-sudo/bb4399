import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
export const PUBLIC_DIR = path.resolve(__dirname, "../public");
export const WEB_DIR = path.resolve(__dirname, "../web");
const ASSET_DIR = path.join(PUBLIC_DIR, "godot/a");
const GENERATED_CATALOG_PATH = path.resolve(__dirname, "./generated/catalog_data.json");

function readJsonSafe(filePath, fallback = null) {
  try {
    return JSON.parse(fs.readFileSync(filePath, "utf8"));
  } catch {
    return fallback;
  }
}

const generatedCatalog = readJsonSafe(GENERATED_CATALOG_PATH, null);
const liveIndexDoc = generatedCatalog ? null : readJsonSafe(path.join(ASSET_DIR, "index.json"), {});
const liveGarageDoc = generatedCatalog ? null : readJsonSafe(path.join(ASSET_DIR, "l/garage.json"), {});

const tankExtMap = generatedCatalog?.tanks || liveIndexDoc?.tanks || {};
const tankSkillMap = generatedCatalog?.skills || {};
const bundledMaps = generatedCatalog?.maps || {};
const mapCache = new Map();

export const CLIENT_BUILD = String(generatedCatalog?.clientBuild || "G6b835");

export function hasLocalAssets() {
  return fs.existsSync(path.join(ASSET_DIR, "index.json"));
}

export function hasWebClient() {
  return fs.existsSync(path.join(WEB_DIR, "index.html"));
}

export const STARTER_TANKS = [
  10000001, // Iron Man / Gang Thép
  10000002, // Groot
  10000003, // Panda / Po
  10000008, // Spider-Man
  10000019, // Gundam / Flying Wing
];

export function tankExternalId(tankId) {
  const ext = Number(tankExtMap[String(tankId)]);
  return Number.isFinite(ext) && ext > 0 ? ext : 123;
}

export function tankSkills(tankId) {
  let raw = tankSkillMap[String(tankId)];
  if (!Array.isArray(raw)) {
    const row = (liveGarageDoc?.tanks || {})[String(tankId)];
    raw = Array.isArray(row?.skills) ? row.skills.map(Number).filter((n) => n > 0) : [];
  }
  // Slot 0 = normal attack (1 = standard shot), Slots 1, 2, 3, 10 = skills
  const out = [{ slot: 0, id: 1, cdMs: 450 }];
  if (raw[0]) out.push({ slot: 1, id: raw[0], cdMs: 4000 });
  if (raw[1]) out.push({ slot: 2, id: raw[1], cdMs: 8000 });
  if (raw[3]) out.push({ slot: 3, id: raw[3], cdMs: 6000 });
  if (raw[2]) out.push({ slot: 10, id: raw[2], cdMs: 5000 });
  return out;
}

export function validMapId(mapId) {
  const key = String(mapId || 0);
  if (bundledMaps[key] || (liveIndexDoc?.maps && liveIndexDoc.maps[key])) {
    return Number(key);
  }
  return 4;
}

export function loadMapInfo(mapId) {
  const id = validMapId(mapId);
  if (mapCache.has(id)) return mapCache.get(id);

  const bundled = bundledMaps[String(id)];
  if (bundled) {
    mapCache.set(id, bundled);
    return bundled;
  }

  const doc = readJsonSafe(path.join(ASSET_DIR, `m/${id}/map.json`), null);
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
  const info = { id, width, height, duration, killTarget, spawns };
  mapCache.set(id, info);
  return info;
}
