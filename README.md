# Quản Lý Đoàn Viên (Union Management System)
-Dự án xây dựng ứng dụng di động hỗ trợ quản lý thông tin đoàn viên, theo dõi hoạt động phong trào và quản lý sổ đoàn điện tử. Được phát triển bằng Flutter nhằm mang lại trải nghiệm mượt mà trên cả Android.

## Tính năng chính
Quản lý hồ sơ: 

Điểm danh & Hoạt động: 


Tin tức & Thông báo: 


### Công nghệ sử dụng
Frontend: Flutter & Dart

Backend : ASP.NET Core

Database: SQL Server

Authentication: JWT (JSON Web Token) để xác thực người dùng

## Getting Started

I.Để chạy dự án này ở môi trường local, bạn cần thực hiện các bước sau:
1.Clone dự án:
    git clone https://github.com/thuypy1209/quanlidoanvien.git
    cd quanlidoanvien

2.Cài đặt các dependencies:
    flutter pub get

3.Chạy ứng dụng:
    flutter run

II.Add database local:
1.Clone database & API:
    git clone https://github.com/thuypy1209/DoanVienAPI.git
    cd DoanVienAPI

2.Khởi tạo Cơ sở dữ liệu
-Thực hiện xóa thủ công: Xóa toàn bộ thư mục có tên là Migrations
-Sau khi đã xóa cả Database và các file Migration cũ, chạy chuỗi lệnh sau
    dotnet ef migrations add InitialCreate

-Tạo bản thiết kế (Migration) đầu tiên chứa bảng HoatDong mới
    dotnet ef migrations add InitialCreate
    dotnet ef database update


A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
