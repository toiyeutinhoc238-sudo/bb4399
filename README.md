# bb4399 (Tank Ghost / BangBang Client + Node.js Server)

Dự án gồm 2 phần:
- `client_godot/`: Godot 4.7.2 client (`GL Compatibility`), đã vá hỗ trợ đa nền tảng (PC, Android, iOS native & Web HTML5) và đổi địa chỉ server local/LAN linh hoạt.
- `server/`: Backend Game Server dùng **Node.js + WebSocket (`ws`) + MongoDB Atlas**, phục vụ giao thức nhị phân `sixcube.protocol` (`/ws/login`, `/ws/gate`, `/ws/comm`), đăng ký/đăng nhập (`/api/auth`, `/api/register/*`), sảnh/phòng/chat và trận đấu thời gian thực.

> Lưu ý: Thư mục asset tĩnh `server/public/` (~2 GB) và tệp bí mật `server/.env` không được đưa lên Git (xem `.gitignore`).

## Chạy Server

1. Chuẩn bị thư mục tài nguyên tĩnh `server/public/godot/...` trên máy chủ (hoặc đặt `android_asset_root` tới CDN).
2. Tạo tệp `server/.env` từ `server/.env.example` và điền `MONGODB_URI` của bạn.
3. Cài thư viện và chạy:

```bash
cd server
npm install
npm start
```

Kiểm tra nhanh giao thức server:

```bash
cd server
npm test
```

## Chạy Client (`client_godot`)

- Mở `client_godot/project.godot` bằng **Godot 4.7.2**.
- **PC (localhost)**: mặc định đã trỏ `http://127.0.0.1:8080`.
- **Android / iOS (LAN / online)**: đổi `android_origin` trong `client_godot/project.godot` (hoặc tạo `user://server.cfg` mục `[bangbang]` với `origin="http://<IP_LAN>:8080"`).
