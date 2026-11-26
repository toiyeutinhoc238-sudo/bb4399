import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const GENERATED_PROTO_PATH = path.resolve(__dirname, "./generated/protocol_data.json");
const CLIENT_PROTO_DIR = path.resolve(__dirname, "../../client_godot/net/battle_protocol");

const MAX_BODY_BYTES = 65527;
const SIZES = {
  u8: 1,
  i8: 1,
  u16: 2,
  i16: 2,
  u32: 4,
  i32: 4,
  f32: 4,
  utf8: 2,
  u64_words: 8,
  i64_words: 8,
};

const PADDED_C2S_TYPES = new Set([450, 501, 503, 600, 601, 602, 603, 604, 605, 607, 608, 613]);

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

function loadProtocolTables() {
  if (fs.existsSync(GENERATED_PROTO_PATH)) {
    const bundle = JSON.parse(fs.readFileSync(GENERATED_PROTO_PATH, "utf8"));
    if (bundle?.schema && bundle?.byId) {
      return { schema: bundle.schema, byId: bundle.byId };
    }
  }
  return {
    schema: parseGdDict(path.join(CLIENT_PROTO_DIR, "protocol_schema.gd"), "CLASSES"),
    byId: parseGdDict(path.join(CLIENT_PROTO_DIR, "message_ids.gd"), "BY_ID"),
  };
}

const loadedProto = loadProtocolTables();
export const SCHEMA = loadedProto.schema;
export const BY_ID = loadedProto.byId;
export const BY_CLASS = {};
for (const [idStr, cls] of Object.entries(BY_ID)) {
  BY_CLASS[cls] = Number(idStr);
}

export function u64Words(ms) {
  const big = BigInt(Math.max(0, Math.floor(Number(ms) || 0)));
  return {
    lowpart: Number(big & 0xffffffffn),
    hipart: Number((big >> 32n) & 0xffffffffn),
  };
}

export function i64Words(ms) {
  const big = BigInt(Math.floor(Number(ms) || 0));
  const low = Number(big & 0xffffffffn);
  const high = Number(BigInt.asIntN(32, big >> 32n));
  return { lowpart: low, hipart: high };
}

function defaultValueForField(field, depth = 0) {
  if (depth > 32) return null;
  if (field.kind === "array") return [];
  if (field.kind === "struct") return defaultStruct(field.class, {}, depth + 1);
  if (field.type === "utf8") return "";
  if (field.type === "u64_words" || field.type === "i64_words") return { lowpart: 0, hipart: 0 };
  return 0;
}

export function defaultStruct(protocolClass, overrides = {}, depth = 0) {
  const fullClass = protocolClass.startsWith("sixcube.protocol.")
    ? protocolClass
    : `sixcube.protocol.${protocolClass}`;
  const def = SCHEMA[fullClass];
  if (!def) throw new Error(`Unknown protocol class: ${fullClass}`);
  const out = {};
  for (const field of def.fields) {
    if (Object.prototype.hasOwnProperty.call(overrides, field.name) && overrides[field.name] !== undefined) {
      if (field.kind === "struct" && overrides[field.name] && typeof overrides[field.name] === "object") {
        out[field.name] = defaultStruct(field.class, overrides[field.name], depth + 1);
      } else {
        out[field.name] = overrides[field.name];
      }
    } else {
      out[field.name] = defaultValueForField(field, depth);
    }
  }
  return out;
}

class Writer {
  constructor() {
    this.chunks = [];
    this.size = 0;
  }
  push(buf) {
    if (this.size + buf.length > MAX_BODY_BYTES) {
      throw new Error("Body exceeds u16 frame budget");
    }
    this.chunks.push(buf);
    this.size += buf.length;
  }
  u8(v) {
    const b = Buffer.allocUnsafe(1);
    b.writeUInt8((Number(v) || 0) & 0xff, 0);
    this.push(b);
  }
  i8(v) {
    const b = Buffer.allocUnsafe(1);
    b.writeInt8(Math.max(-128, Math.min(127, Math.trunc(Number(v) || 0))), 0);
    this.push(b);
  }
  u16(v) {
    const b = Buffer.allocUnsafe(2);
    b.writeUInt16LE((Number(v) || 0) >>> 0 & 0xffff, 0);
    this.push(b);
  }
  i16(v) {
    const b = Buffer.allocUnsafe(2);
    b.writeInt16LE(Math.max(-32768, Math.min(32767, Math.trunc(Number(v) || 0))), 0);
    this.push(b);
  }
  u32(v) {
    const b = Buffer.allocUnsafe(4);
    b.writeUInt32LE((Number(v) || 0) >>> 0, 0);
    this.push(b);
  }
  i32(v) {
    const b = Buffer.allocUnsafe(4);
    b.writeInt32LE((Number(v) || 0) | 0, 0);
    this.push(b);
  }
  f32(v) {
    const b = Buffer.allocUnsafe(4);
    b.writeFloatLE(Number.isFinite(Number(v)) ? Number(v) : 0, 0);
    this.push(b);
  }
  utf8(v) {
    const raw = Buffer.isBuffer(v) ? v : Buffer.from(String(v ?? ""), "utf8");
    this.u16(raw.length);
    if (raw.length > 0) this.push(raw);
  }
  scalar(kind, val) {
    if (kind === "utf8") return this.utf8(val);
    if (kind === "u64_words") {
      const w = val && typeof val === "object" ? val : u64Words(val);
      this.u32(w.lowpart ?? 0);
      this.u32(w.hipart ?? 0);
      return;
    }
    if (kind === "i64_words") {
      const w = val && typeof val === "object" ? val : i64Words(val);
      this.u32(w.lowpart ?? 0);
      this.i32(w.hipart ?? 0);
      return;
    }
    this[kind](val);
  }
  writeValue(field, val, depth) {
    if (field.kind === "array") {
      const arr = Array.isArray(val) ? val : [];
      this.scalar(field.length_type, arr.length);
      for (const item of arr) {
        this.writeValue(field.element, item, depth);
      }
      return;
    }
    if (field.kind === "struct") {
      this.writeClass(field.class, val || {}, depth + 1);
      return;
    }
    this.scalar(field.type, val);
  }
  writeClass(cls, values, depth = 0) {
    if (depth > 64) throw new Error(`Excessive nesting: ${cls}`);
    const def = SCHEMA[cls];
    if (!def) throw new Error(`Unknown protocol class: ${cls}`);
    for (const field of def.fields) {
      const v = values && Object.prototype.hasOwnProperty.call(values, field.name)
        ? values[field.name]
        : defaultValueForField(field, depth);
      this.writeValue(field, v, depth);
    }
  }
  toBuffer() {
    return Buffer.concat(this.chunks, this.size);
  }
}

class Reader {
  constructor(buf) {
    this.buf = buf;
    this.pos = 0;
  }
  avail() {
    return this.buf.length - this.pos;
  }
  need(n) {
    if (n < 0 || this.avail() < n) {
      throw new Error(`Truncated body at byte ${this.pos} (need ${n}, have ${this.avail()})`);
    }
  }
  scalar(kind) {
    this.need(SIZES[kind]);
    if (kind === "utf8") {
      const len = this.buf.readUInt16LE(this.pos);
      this.pos += 2;
      this.need(len);
      const raw = this.buf.subarray(this.pos, this.pos + len);
      this.pos += len;
      const zero = raw.indexOf(0);
      return (zero >= 0 ? raw.subarray(0, zero) : raw).toString("utf8");
    }
    if (kind === "u64_words" || kind === "i64_words") {
      const lowpart = this.buf.readUInt32LE(this.pos);
      const hipart = kind === "i64_words"
        ? this.buf.readInt32LE(this.pos + 4)
        : this.buf.readUInt32LE(this.pos + 4);
      this.pos += 8;
      return { lowpart, hipart };
    }
    let out;
    switch (kind) {
      case "u8": out = this.buf.readUInt8(this.pos); break;
      case "i8": out = this.buf.readInt8(this.pos); break;
      case "u16": out = this.buf.readUInt16LE(this.pos); break;
      case "i16": out = this.buf.readInt16LE(this.pos); break;
      case "u32": out = this.buf.readUInt32LE(this.pos); break;
      case "i32": out = this.buf.readInt32LE(this.pos); break;
      case "f32": out = this.buf.readFloatLE(this.pos); break;
      default: throw new Error(`Unknown wire type: ${kind}`);
    }
    this.pos += SIZES[kind];
    return out;
  }
  readValue(field, depth) {
    if (field.kind === "array") {
      const count = this.scalar(field.length_type);
      if (count > 20000) throw new Error(`Oversize array: ${count}`);
      const arr = [];
      for (let i = 0; i < count; i++) {
        arr.push(this.readValue(field.element, depth));
      }
      return arr;
    }
    if (field.kind === "struct") {
      return this.readClass(field.class, depth + 1);
    }
    return this.scalar(field.type);
  }
  readClass(cls, depth = 0) {
    if (depth > 64) throw new Error(`Excessive nesting: ${cls}`);
    const def = SCHEMA[cls];
    if (!def) throw new Error(`Unknown protocol class: ${cls}`);
    const out = {};
    for (const field of def.fields) {
      out[field.name] = this.readValue(field, depth);
    }
    return out;
  }
}

export function encodeRawFrame(msgId, bodyBuf = Buffer.alloc(0), sequence = 0) {
  const total = bodyBuf.length + 8;
  const out = Buffer.allocUnsafe(total);
  out.writeUInt16LE(total, 0);
  out.writeInt16LE(msgId, 2);
  out.writeUInt32LE(sequence >>> 0, 4);
  if (bodyBuf.length > 0) bodyBuf.copy(out, 8);
  return out;
}

export function encodeFrame(protocolClass, values = {}, sequence = 0) {
  const fullClass = protocolClass.startsWith("sixcube.protocol.")
    ? protocolClass
    : `sixcube.protocol.${protocolClass}`;
  const msgId = BY_CLASS[fullClass];
  if (msgId === undefined) throw new Error(`No message ID for class: ${fullClass}`);
  const w = new Writer();
  w.writeClass(fullClass, values);
  return encodeRawFrame(msgId, w.toBuffer(), sequence);
}

function decodeBodyStrict(cls, bodyBuf) {
  const r = new Reader(bodyBuf);
  const value = r.readClass(cls);
  if (r.avail() !== 0) throw new Error(`Trailing body bytes: ${r.avail()}`);
  return value;
}

export function decodeFrame(frame) {
  if (!Buffer.isBuffer(frame) || frame.length < 8) {
    return { ok: false, error: "Invalid frame size" };
  }
  const length = frame.readUInt16LE(0);
  const type = frame.readInt16LE(2);
  const sequence = frame.readUInt32LE(4);
  if (length !== frame.length) {
    return { ok: false, type, error: `Length mismatch (${length} != ${frame.length})` };
  }
  const body = frame.subarray(8);
  const cls = BY_ID[String(type)];
  if (!cls) {
    return { ok: true, raw: true, type, sequence, body };
  }
  try {
    return { ok: true, type, class: cls, sequence, value: decodeBodyStrict(cls, body) };
  } catch (err) {
    // Strip Flash 8-byte zero padding used by client_godot on padded C2S frames
    if (PADDED_C2S_TYPES.has(type) && (frame.length - 2) % 8 === 0) {
      const maxPad = Math.min(7, body.length);
      for (let pad = 1; pad <= maxPad; pad++) {
        if (body[body.length - pad] !== 0) break;
        try {
          const val = decodeBodyStrict(cls, body.subarray(0, body.length - pad));
          return { ok: true, type, class: cls, sequence, value: val };
        } catch {
          // try stripping one more zero byte
        }
      }
    }
    return { ok: false, type, class: cls, error: err.message, body };
  }
}

export class FrameReader {
  constructor() {
    this.buf = Buffer.alloc(0);
  }
  feed(chunk) {
    const data = Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk);
    if (this.buf.length + data.length > 512 * 1024) {
      throw new Error("Frame buffer overflow");
    }
    this.buf = this.buf.length === 0 ? data : Buffer.concat([this.buf, data]);
    const frames = [];
    let cursor = 0;
    while (this.buf.length - cursor >= 2) {
      const len = this.buf.readUInt16LE(cursor);
      if (len < 8) throw new Error(`Invalid frame length: ${len}`);
      if (this.buf.length - cursor < len) break;
      frames.push(Buffer.from(this.buf.subarray(cursor, cursor + len)));
      cursor += len;
    }
    this.buf = cursor > 0 ? this.buf.subarray(cursor) : this.buf;
    return frames;
  }
}

export const SERVER_GREETING = Buffer.from([0x00, 0x00]);
export const VERSION_OK_FRAME = encodeRawFrame(903, Buffer.alloc(12)); // exact 20 bytes required by client
