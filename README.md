# 📱 Quản Lý Đoàn Viên (Union Management System)

Giải pháp chuyển đổi số quản lý đoàn viên và hoạt động phong trào trên nền tảng di động.

## 📋 Giới thiệu dự án

Dự án được xây dựng nhằm hỗ trợ tổ chức Đoàn trong việc số hóa hồ sơ, quản lý sổ đoàn điện tử và theo dõi các hoạt động phong trào một cách minh bạch, hiệu quả.

Ứng dụng mang lại trải nghiệm mượt mà, đồng bộ dữ liệu thời gian thực giữa thiết bị di động và máy chủ.

### ✨ Tính năng chính

Nhóm tính năng, Chi tiết:

👤 Quản lý hồ sơ: Đăng ký/Đăng nhập, cập nhật thông tin cá nhân, quản lý sổ đoàn điện tử.

📅 Hoạt động: Xem danh sách hoạt động, đăng ký tham gia và thực hiện điểm danh.

📊 Thống kê: Theo dõi biểu đồ tham gia hoạt động trực quan bằng fl_chart.

🔔 Thông báo: Cập nhật tin tức phong trào và các thông báo mới nhất từ Đoàn cấp trên.

#### 🛠 Công nghệ sử dụng

Frontend (Mobile App)

- Framework: Flutter & Dart.

- State Management: Flutter BLoC.

- UI Libraries: curved_navigation_bar (Thanh điều hướng), fl_chart (Biểu đồ), cupertino_icons.

- Security: Lưu trữ JWT Token qua shared_preferences.

Backend (API)

- Framework: ASP.NET Core với kiến trúc RESTful API.

- Database: Microsoft SQL Server.

- Authentication: JWT (JSON Web Token).

- Real-time: SignalR hỗ trợ các tác vụ thời gian thực.

##### 🚀 Hướng dẫn cài đặt (Getting Started)

I. Cài đặt ứng dụng di động (Frontend)

Clone dự án:

```bash

git clone https://github.com/thuypy1209/quanlidoanvien.git
cd quanlidoanvien

```
2. Cài đặt thư viện:

```bash

flutter pub get
```
3. Cấu hình API:

Chỉnh sửa địa chỉ IP Server trong file lib/Services/AuthService.dart (hoặc các file Service tương ứng) để trỏ về máy local của bạn.

4. Chạy ứng dụng:

```bash

flutter run

```
II. Cài đặt hệ thống API & Database (Backend)

1. Clone dự án:

```bash

git clone https://github.com/thuypy1209/DoanVienAPI.git
cd DoanVienAPI

```
2. Cấu hình chuỗi kết nối:

Mở appsettings.json và cập nhật thông tin SQL Server tại mục DefaultConnection.

3. Khởi tạo Cơ sở dữ liệu:

```bash

Xóa thư mục Migrations cũ nếu có

dotnet ef migrations add InitialCreate

dotnet ef database update

```
4. Chạy API:

```bash

dotnet run --url "http://0.0.0.0:5000"

```
A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
