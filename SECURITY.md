# 🛡 Chính Sách Bảo Mật & Báo Cáo Kiểm Toán An Ninh (Security Policy & Hardening)

Dự án **SiliCord** áp dụng nguyên tắc **"Phát hiện là Sửa ngay" (Zero-Tolerance & Immediate Remediation)** đối với mọi rủi ro bảo mật, rò rỉ dữ liệu hoặc lỗ hổng bộ nhớ không đáng có.

---

## 1. Các Rủi Ro Bảo Mật Không Đáng Có Đã Được Kiểm Toán & Khắc Phục Trực Tiếp

Trong quá trình rà soát mã nguồn, **5 rủi ro bảo mật phổ biến** thường gặp ở các ứng dụng Discord Desktop đã được phát hiện và **khắc phục triệt để ngay trong mã nguồn Rust của SiliCord**:

### 🔒 Khắc phục #1: Chống Quét Trộm Token bằng Regex trên Ổ cứng (`Machine-Bound Vault Sealing`)
- **Nguy cơ**: Các phần mềm độc hại (Token Stealers) thường quét các tệp cấu hình `.json` / `.ldb` trong `%APPDATA%` bằng biểu thức chính quy (Regex) để tìm chuỗi Token Discord dạng văn bản thuần (`plain-text`).
- **Biện pháp đã áp dụng ([`src/storage/mod.rs`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/storage/mod.rs#L65-L120))**:
  - Tuyệt đối không lưu Token dạng văn bản thuần xuống đĩa.
  - Hàm `seal_token_for_disk` tự động mã hoá/xáo trộn Token bằng khoá dẫn xuất gắn chặt với thiết bị cục bộ (`silicord_vault_v1:...`) trước khi ghi vào `%APPDATA%\SiliCord\config.json`.

### 🧹 Khắc phục #2: Xoá Sạch Mật Khẩu & Token Khỏi Bộ Nhớ RAM (`Volatile Memory Zeroization`)
- **Nguy cơ**: Sau khi người dùng nhập mật khẩu hoặc Token trên giao diện, chuỗi ký tự nhạy cảm nếu chỉ gọi `.clear()` thông thường thì dữ liệu gốc vẫn còn nằm lại trên vùng nhớ Heap cho đến khi được cấp phát đè, tạo rủi ro nếu máy bị đọc trộm tiến trình (Memory Dump).
- **Biện pháp đã áp dụng ([`SecurityHardening::zeroize_secret`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/compliance/mod.rs#L139-L150) & [`src/main.rs`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/main.rs#L168-L194))**:
  - Sử dụng lệnh ghi bộ nhớ không thể bị trình biên dịch tối ưu hoá bỏ qua (`std::ptr::write_volatile(byte, 0u8)`) kết hợp hàng rào bộ nhớ `std::sync::atomic::compiler_fence(Ordering::SeqCst)` để ghi đè toàn bộ mật khẩu, mã 2FA và Token bằng byte `0x00` ngay sau khi xác thực xong hoặc khi đăng xuất.

### 🌐 Khắc phục #3: Chặn Rò Rỉ Header `Authorization` Qua Chuyển Hướng HTTP (`Strict Host Pinning`)
- **Nguy cơ**: Nếu trình khách HTTP tự động đi theo các phản hồi chuyển hướng (`HTTP 301/302/307 Redirect`) tới một tên miền bên ngoài, header `Authorization` chứa Token của người dùng có thể bị lộ cho máy chủ thứ ba.
- **Biện pháp đã áp dụng ([`src/network/mod.rs`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/network/mod.rs#L86-L108) & [`SecurityHardening::is_trusted_discord_auth_url`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/compliance/mod.rs#L152-L168))**:
  - Khoá cứng `.redirect(reqwest::redirect::Policy::none())` và `.https_only(true)`.
  - Kiểm tra xác thực tên miền nghiêm ngặt trước mọi yêu cầu mạng: chỉ cho phép kết nối có chứa thông tin xác thực tới đúng tên miền chính thức `discord.com` và `gateway.discord.gg` qua TLS (`https://` / `wss://`).

### 🔌 Khắc phục #4: Chống Tấn Công Tràn Bộ Nhớ (OOM) & Lộ Dữ Liệu Qua Cổng IPC Rich Presence
- **Nguy cơ**: Cổng Named Pipe `\\.\pipe\discord-ipc-0` cho phép các trò chơi trên máy kết nối vào để hiển thị trạng thái Rich Presence. Nếu một ứng dụng cục bộ gửi header khai báo độ dài gói tin giả mạo (ví dụ `length = 1 GB`), ứng dụng sẽ bị tràn RAM; ngoài ra gói `READY` của IPC có thể làm lộ ID/Email thật.
- **Biện pháp đã áp dụng ([`src/rpc/mod.rs`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/rpc/mod.rs#L53-L95))**:
  - Kiểm tra giới hạn cứng `if length == 0 || length > 65_536 { break; }` (tối đa 64 KB mỗi khung IPC).
  - Trả về hồ sơ ẩn danh (`"id": "0"`, `"username": "silicord_user"`) cho tiến trình IPC cục bộ, tuyệt đối không tiết lộ Token hay Email tài khoản thật.

### 🛡 Khắc phục #5: Tường Lửa Chặn Telemetry & Bảo Vệ Quyền Riêng Tư Cấp Socket
- **Biện pháp đã áp dụng ([`TelemetryShield`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/compliance/mod.rs#L27-L68))**:
  - Chặn tự động 100% các đường dẫn thu thập dữ liệu hành vi và theo dõi thiết bị của Discord (`/science`, `/metrics`, `/track`, `sentry.io`, `datadoghq.com`, `/fingerprint-analytics`).

---

## 2. Quy Trình Báo Cáo & Cam Kết Sửa Lỗi Ngay Lập Tức

Nếu bạn phát hiện bất kỳ rủi ro bảo mật hoặc hành vi bất thường nào trong mã nguồn **SiliCord**:
1. **Không công khai dữ liệu nhạy cảm** (Token thật, mật khẩu thật) lên các kênh công cộng.
2. Kiểm tra trực tiếp trong các module bảo mật:
   - [`src/compliance/mod.rs`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/compliance/mod.rs) (Kiểm toán bảo mật, Zeroization, Host Pinning, Telemetry Firewall)
   - [`src/storage/mod.rs`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/storage/mod.rs) (Mã hoá/Niêm phong Token cục bộ)
   - [`src/network/mod.rs`](file:///c:/Users/PhongOfficial5/Desktop/SiliCord/src/network/mod.rs) (Chính sách HTTPS-Only & No-Redirect)
3. Mọi bản vá bảo mật luôn được ưu tiên xử lý và cập nhật **ngay lập tức** trước bất kỳ tính năng mới nào.
