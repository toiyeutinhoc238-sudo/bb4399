import fs from "fs";
import path from "path";
import zlib from "zlib";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const WEB_DIR = path.resolve(__dirname, "../web");
const TARGET_EXTS = new Set([".wasm", ".pck", ".js", ".json", ".svg", ".css"]);
const MIN_BYTES = 4096;

function walk(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, e.name);
    if (e.isDirectory()) walk(full, out);
    else if (e.isFile()) out.push(full);
  }
  return out;
}

const files = walk(WEB_DIR).filter((f) => TARGET_EXTS.has(path.extname(f).toLowerCase()));
if (files.length === 0) {
  console.log(`[compress_web] Chưa thấy file Godot Web nào trong ${WEB_DIR} (cần export index.html/index.wasm/index.pck vào server/web trước).`);
  process.exit(0);
}

let savedTotal = 0;
let rawTotal = 0;
let count = 0;

for (const file of files) {
  const raw = fs.readFileSync(file);
  if (raw.length < MIN_BYTES) continue;
  const br = zlib.brotliCompressSync(raw, {
    params: {
      [zlib.constants.BROTLI_PARAM_QUALITY]: 11,
      [zlib.constants.BROTLI_PARAM_SIZE_HINT]: raw.length,
    },
  });
  if (br.length < raw.length * 0.95) {
    fs.writeFileSync(`${file}.br`, br);
    rawTotal += raw.length;
    savedTotal += raw.length - br.length;
    count++;
    const pct = (((raw.length - br.length) / raw.length) * 100).toFixed(1);
    console.log(
      `[compress_web] ${path.relative(WEB_DIR, file)} -> .br (${(raw.length / 1024).toFixed(0)} KB -> ${(br.length / 1024).toFixed(0)} KB, -${pct}%)`
    );
  }
}

console.log(
  `[compress_web] Done! Created ${count} Brotli file(s), saved ${(savedTotal / (1024 * 1024)).toFixed(2)} MB out of ${(rawTotal / (1024 * 1024)).toFixed(2)} MB.`
);
