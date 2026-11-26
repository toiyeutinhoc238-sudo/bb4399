# bb4399 (Tank Ghost / BangBang Client + Node.js Server)

Dự án gồm 2 phần đã được tối ưu sẵn để chạy **Local/LAN** lẫn triển khai online trên **Render + MongoDB Atlas + Cloudflare R2**:

- `client_godot/`: Client **Godot 4.7.2** (`GL Compatibility`) đã vá đa nền tảng (**PC, Android, iOS native và Web HTML5**):
  - Web HTML5 tự nhận `window.location.origin` (HTTP/HTTPS + WS/WSS) và hỗ trợ `window.__bbAssetRoot` tải asset thẳng từ Cloudflare R2 không qua server trung gian.
  - Native PC / Android / iOS hỗ trợ đổi server qua `ProjectSettings`, biến môi trường `BB_ORIGIN` hoặc `user://server.cfg`, và tự tận dụng gương tải `/godot/pcdl.json` từ R2.
- `server/`: Game Server **Node.js + WebSocket (`ws`) + MongoDB Atlas**, độc lập hoàn toàn (`rootDir: server`):
  - Tự chứa sẵn bộ dữ liệu gọn nhẹ `server/src/generated/` (~247 KB cho toàn bộ 604 struct giao thức, 96 xe tăng, 132 bản đồ) — **không cần** thư mục `server/public/` (~2 GB) hay `client_godot/` trên Render.
  - Tối ưu hiệu năng: `scrypt` bất đồng bộ (không block vòng lặp trận đấu 50ms), nén Brotli/Gzip + ETag 304, WebSocket `perMessageDeflate: false` + ping/pong giữ kết nối qua proxy, tắt mềm `SIGTERM`, rate limit chống spam đăng nhập/đăng ký.
  - Hỗ trợ host trực tiếp bản xuất Godot Web HTML5 trong `server/web/` (kèm hỗ trợ tệp nén sẵn `.br`/`.gz` và cấu hình `COOP_COEP_MODE`).

> Thư mục asset tĩnh `server/public/` (~2 GB) và tệp bí mật `server/.env` không đưa lên Git (xem `.gitignore`).

---

## 1. Triển khai lên Render (Khuyên dùng — 1 click với `render.yaml`)

1. **MongoDB Atlas → Network Access**:
   - Thêm IP `0.0.0.0/0` để máy chủ Render kết nối được vào cluster.
2. **Cloudflare R2 (host miễn phí ~2 GB asset hình ảnh / bản đồ / nhạc)**:
   - Tạo 1 Bucket trên Cloudflare R2, bật **Public Development URL** (hoặc custom domain) và thêm **CORS Policy** cho phép `GET`/`HEAD` từ `*`.
   - Tạo **R2 API Token** (`Object Read & Write`), điền `R2_ACCOUNT_ID`, `R2_BUCKET`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` vào `server/.env` rồi chạy 1 lệnh tự đẩy toàn bộ 23.113 file `server/public/godot/` lên `godot/` (đa luồng, có resume nếu rớt mạng):
     ```bash
     cd server
     npm run upload:r2
     ```
3. **Render Dashboard → New → Blueprint**:
   - Chọn repo `bb4399` — Render tự đọc `render.yaml` (khu vực **Singapore** cho ping thấp tại Việt Nam, `rootDir: server`, health check `/healthz`).
   - Điền 2 biến môi trường bí mật:
     - `MONGODB_URI`: chuỗi kết nối Atlas (`mongodb+srv://<user>:<pass>@<cluster>.mongodb.net/bangbang?retryWrites=true&w=majority`)
     - `ASSET_CDN_URL`: URL gốc của Cloudflare R2 (ví dụ `https://pub-xxxxxxxxxxxx.r2.dev`)
4. **Bật Web Game chơi trực tiếp trên trình duyệt (tùy chọn)**:
   - Mở `client_godot/project.godot` bằng **Godot 4.7.2** → Export **Web (HTML5)** (tắt Thread Support để chạy mượt cả iOS Safari) vào thư mục `server/web/`.
   - Chạy `npm run compress:web` trong `server/` để nén sẵn `.wasm`/`.pck`/`.js` sang `.br` (Brotli) giúp web tải nhanh gấp 3 lần, rồi push `server/web/` lên GitHub.
   - Khi chưa có bản export trong `server/web/`, mở link Render sẽ hiển thị trang trạng thái server + hướng dẫn kết nối nhanh.

---

## 2. Chạy Local / LAN trên máy tính

1. Tạo tệp `server/.env` từ `server/.env.example` và điền `MONGODB_URI` (hoặc để trống để chạy thử bằng file JSON cục bộ `server/data/local_store.json`).
2. Cài thư viện và chạy server:

```bash
cd server
npm install
npm start
```

3. Kiểm tra tự động toàn bộ HTTP/CDN/WebSocket/trận đấu:

```bash
cd server
npm test
```

4. Nếu cập nhật protocol hoặc thêm map/tank trong `server/public/`, tái tạo lại bộ dữ liệu gọn nhẹ bằng:

```bash
cd server
npm run build:data
```

---

## 3. Kết nối Client PC / Android / iOS

- **PC (localhost)**: mặc định đã trỏ `http://127.0.0.1:8080`.
- **Trỏ lên Render hoặc mạng LAN**: đặt `bangbang/android_origin` trong `client_godot/project.godot` (ví dụ `https://bb4399-server.onrender.com`), hoặc tạo `user://server.cfg`:

```ini
[bangbang]
origin="https://bb4399-server.onrender.com"
```
