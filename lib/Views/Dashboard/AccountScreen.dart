import 'package:flutter/material.dart';
import '../../Services/StudentService.dart';
import '../../Models/StudentModel.dart';
import '../../Utils.dart'; // Để dùng hàm xóa Token

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  StudentModel? _student;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() async {
    final service = StudentService();
    final response = await service.getStudentInfo();
    if (response.isSuccess && mounted) {
      setState(() {
        _student = response.data;
      });
    }
  }

  // Hàm Đăng xuất
  void _handleLogout() async {
    // 1. Xóa Token
    await Utils.saveToken("");

    // 2. Quay về màn hình Login
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Tài khoản"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar to
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, size: 60, color: Colors.white),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              _student?.hoTen ?? "Đang tải...",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              _student?.mssv ?? "",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            // Danh sách tùy chọn
            _buildOptionItem(Icons.person_outline, "Hồ sơ sinh viên", () {}),
            _buildOptionItem(Icons.lock_outline, "Đổi mật khẩu", () {}),
            _buildOptionItem(Icons.settings_outlined, "Cài đặt", () {}),

            const Divider(),

            // Nút Đăng xuất
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
              onTap: _handleLogout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}