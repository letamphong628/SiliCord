# Hồ Sơ Pháp Lý Clean-Room & Chống DMCA Takedown (Anti-DMCA & Trademark Compliance)

Dự án **SiliCord** được thiết kế và xây dựng theo tiêu chuẩn **Clean-Room Implementation (Phòng Sạch)** nhằm đảm bảo tính hợp pháp tuyệt đối, loại bỏ mọi căn cứ để đánh gậy bản quyền **DMCA (17 U.S.C. § 512)** hoặc khiếu nại nhãn hiệu thương mại.

---

## 1. Tại sao các dự án Discord Client khác bị đánh DMCA và SiliCord khắc phục thế nào?

| Nguyên nhân bị Discord đánh DMCA ở các dự án cũ | Giải pháp Kiến trúc Clean-Room của SiliCord |
| :--- | :--- |
| **1. Tải hoặc đóng gói lại (Re-distribute) bundle JS/CSS/HTML (`app.asar`) của Discord** | **SiliCord KHÔNG tải giao diện web của Discord.** Toàn bộ giao diện được viết mới 100% bằng mã máy Rust (`egui` / `eframe` GPU) từ con số 0. Không có bất kỳ dòng mã JavaScript, CSS hay file `.asar` nào của Discord. |
| **2. Nhúng font chữ độc quyền (`gg sans`, `Whitney`) hoặc logo `Clyde` có bản quyền** | **Zero Proprietary Assets:** SiliCord không chứa bất kỳ file ảnh `.png`, `.svg`, `.ico` hay font `.woff2`/`.ttf` nào thuộc sở hữu của Discord Inc. Mọi biểu tượng (`#`, Loa, Mic, Tai nghe, Bánh răng, Biểu tượng ứng dụng) đều được vẽ bằng thuật toán hình học vector trực tiếp trên GPU (`src/ui/theme.rs` & `src/tray/mod.rs`). |
| **3. Sao chép mã nguồn bị rò rỉ hoặc dịch ngược (Decompile) thư viện C++ (`discord_krisp.node`, `discord_game_sdk.dll`)** | **100% Original Rust Source Code:** Toàn bộ giao thức REST, WebSocket Gateway và IPC Named Pipe (`\\.\pipe\discord-ipc-0`) được cài đặt độc lập bằng Rust (`tokio`, `reqwest`, `tokio-tungstenite`) dựa trên đặc tả giao thức tương thích mở. |
| **4. Gây nhầm lẫn thương hiệu (Trademark Infringement)** | Tên dự án là **SiliCord**, sử dụng biểu tượng tinh thể Silicon lục giác tự vẽ và tuyên bố phi liên kết thương hiệu rõ ràng. |

---

## 2. Căn cứ Pháp lý Quốc tế & Hoa Kỳ

1. **Ngoại lệ Tương thích Ngược DMCA — 17 U.S.C. § 1201(f) (Reverse Engineering for Interoperability)**:
   - Luật Bản quyền Thiên niên kỷ Kỹ thuật số Hoa Kỳ (DMCA) tại mục **17 U.S.C. § 1201(f)** bảo vệ quyền của nhà phát triển phần mềm độc lập được tạo ra chương trình máy tính có khả năng **tương thích và trao đổi dữ liệu (Interoperability)** với các chương trình hoặc máy chủ khác.
2. **Án lệ Toà án Tối cao Hoa Kỳ — *Google LLC v. Oracle America, Inc.*, 593 U.S. ___ (2021) & *Sega v. Accolade*, 977 F.2d 1510 (9th Cir. 1992)**:
   - Cấu trúc gói tin JSON API/WebSocket và phương thức giao tiếp nhằm đạt khả năng tương thích hệ thống thuộc phạm vi *Fair Use* / không thuộc đối tượng độc quyền ngăn cấm khi mã nguồn thực thi được viết lại hoàn toàn độc lập (Clean-Room).
3. **Chỉ thị Phần mềm Liên minh Châu Âu — EU Directive 2009/24/EC (Article 6)**:
   - Bảo vệ tuyệt đối quyền xây dựng phần mềm tương thích giao thức mạng mà không cần sự cho phép của chủ sở hữu giao thức gốc, miễn là không sao chép mã nguồn bản quyền.

---

## 3. Tuyên bố Phi Liên Kết Thương Hiệu (Trademark Disclaimer)

> **SiliCord** là một dự án phần mềm mã nguồn sạch độc lập được viết bằng ngôn ngữ lập trình Rust.
> **SiliCord** KHÔNG liên kết, KHÔNG được tài trợ, KHÔNG được uỷ quyền và KHÔNG phải là sản phẩm chính thức của **Discord Inc.**
> Tên gọi "Discord" nếu được nhắc đến trong tài liệu kỹ thuật chỉ nhằm mục đích mô tả khả năng tương thích giao thức (*Nominative Fair Use*).
