# Godot Web (HTML5) Build Directory

Đặt các tệp xuất từ **Godot 4.7.2 (Web / HTML5 preset)** vào thư mục này:

- `index.html`
- `index.js`
- `index.wasm` (có thể kèm bản nén sẵn `index.wasm.br` hoặc `index.wasm.gz` để tải nhanh hơn ~3x)
- `index.pck` (có thể kèm bản nén sẵn `index.pck.br` hoặc `index.pck.gz`)
- `index.png` / `index.icon.png` / `index.audio.worklet.js` (nếu có)

### Gợi ý Export tối ưu trong Godot 4.7.2
1. Mở `client_godot/project.godot` bằng **Godot 4.7.2**.
2. Chọn **Project → Export → Web**:
   - **Thread Support**: khuyên **tắt (Single-Threaded)** để chạy mượt trên cả **iOS Safari, Android và PC** mà không cần COEP chặt.
   - **Export Path**: trỏ thẳng tới `server/web/index.html`.
3. (Tùy chọn tối ưu tải siêu nhanh) Nén sẵn trước khi push:
   - Brotli: tạo `index.wasm.br` và `index.pck.br` cạnh bản gốc — server sẽ tự động phát bản `.br` khi trình duyệt hỗ trợ.
4. Commit & push `server/web/` lên GitHub — Render sẽ tự triển khai và mở trực tiếp game ở trang chủ `/` (và `/godot/`).
