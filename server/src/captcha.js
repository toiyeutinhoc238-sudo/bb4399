import crypto from "crypto";
import zlib from "zlib";

// 5x7 pixel font for digits 0-9
const DIGITS = {
  "0": ["01110", "10001", "10011", "10101", "11001", "10001", "01110"],
  "1": ["00100", "01100", "00100", "00100", "00100", "00100", "01110"],
  "2": ["01110", "10001", "00001", "00110", "01000", "10000", "11111"],
  "3": ["11110", "00001", "00001", "01110", "00001", "00001", "11110"],
  "4": ["00010", "00110", "01010", "10010", "11111", "00010", "00010"],
  "5": ["11111", "10000", "11110", "00001", "00001", "10001", "01110"],
  "6": ["01110", "10000", "11110", "10001", "10001", "10001", "01110"],
  "7": ["11111", "00001", "00010", "00100", "01000", "01000", "01000"],
  "8": ["01110", "10001", "10001", "01110", "10001", "10001", "01110"],
  "9": ["01110", "10001", "10001", "01111", "00001", "00001", "01110"],
};

const CRC_TABLE = new Uint32Array(256);
for (let n = 0; n < 256; n++) {
  let c = n;
  for (let k = 0; k < 8; k++) c = (c & 1) ? (0xedb88320 ^ (c >>> 1)) : (c >>> 1);
  CRC_TABLE[n] = c >>> 0;
}

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function pngChunk(type, data) {
  const head = Buffer.allocUnsafe(8);
  head.writeUInt32BE(data.length, 0);
  head.write(type, 4, 4, "ascii");
  const crcBuf = Buffer.allocUnsafe(4);
  crcBuf.writeUInt32BE(crc32(Buffer.concat([head.subarray(4), data])), 0);
  return Buffer.concat([head, data, crcBuf]);
}

function renderCaptchaPng(code) {
  const width = 140;
  const height = 48;
  const rgba = Buffer.alloc(width * height * 4);
  // Dark slate background
  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const i = (y * width + x) * 4;
      rgba[i] = 18;
      rgba[i + 1] = 24;
      rgba[i + 2] = 42;
      rgba[i + 3] = 255;
    }
  }
  const setPx = (x, y, r, g, b) => {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    const i = (y * width + x) * 4;
    rgba[i] = r;
    rgba[i + 1] = g;
    rgba[i + 2] = b;
    rgba[i + 3] = 255;
  };

  // Subtle noise lines
  for (let n = 0; n < 4; n++) {
    const y0 = 6 + crypto.randomInt(height - 12);
    const y1 = 6 + crypto.randomInt(height - 12);
    for (let x = 4; x < width - 4; x++) {
      const y = Math.round(y0 + ((y1 - y0) * x) / width);
      setPx(x, y, 56, 74, 112);
    }
  }

  // Draw 4 crisp digits scaled 4x
  const scale = 4;
  for (let idx = 0; idx < code.length; idx++) {
    const glyph = DIGITS[code[idx]] || DIGITS["0"];
    const ox = 16 + idx * 28 + crypto.randomInt(-2, 3);
    const oy = 10 + crypto.randomInt(-2, 3);
    for (let gy = 0; gy < glyph.length; gy++) {
      for (let gx = 0; gx < glyph[gy].length; gx++) {
        if (glyph[gy][gx] !== "1") continue;
        for (let dy = 0; dy < scale; dy++) {
          for (let dx = 0; dx < scale; dx++) {
            setPx(ox + gx * scale + dx, oy + gy * scale + dy, 90, 255, 168);
          }
        }
      }
    }
  }

  const rawRows = Buffer.alloc((width * 4 + 1) * height);
  for (let y = 0; y < height; y++) {
    const dst = y * (width * 4 + 1);
    rawRows[dst] = 0;
    rgba.copy(rawRows, dst + 1, y * width * 4, (y + 1) * width * 4);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8; // bit depth
  ihdr[9] = 6; // RGBA
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  return Buffer.concat([
    sig,
    pngChunk("IHDR", ihdr),
    pngChunk("IDAT", zlib.deflateSync(rawRows)),
    pngChunk("IEND", Buffer.alloc(0)),
  ]);
}

export class CaptchaStore {
  constructor() {
    this.items = new Map();
  }

  issue() {
    const now = Date.now();
    for (const [k, v] of this.items) {
      if (v.expiresAt <= now) this.items.delete(k);
    }
    const id = crypto.randomBytes(12).toString("hex");
    const code = String(crypto.randomInt(1000, 10000));
    this.items.set(id, { code, expiresAt: now + 5 * 60 * 1000 });
    return {
      id,
      code,
      pngBase64: renderCaptchaPng(code).toString("base64"),
    };
  }

  verify(id, answer) {
    const rec = this.items.get(String(id || ""));
    if (!rec) return false;
    this.items.delete(String(id));
    if (rec.expiresAt <= Date.now()) return false;
    return rec.code === String(answer || "").trim();
  }
}
