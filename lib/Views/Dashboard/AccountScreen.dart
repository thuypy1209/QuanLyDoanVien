import 'package:flutter/material.dart';
import '../../Utils.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _hoTen = "Đang tải...";
  String _email = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() async {
    final info = await Utils.getUserInfo();
    if (mounted) {
      setState(() {
        _hoTen = info['name'] ?? "Sinh viên";
        _email = info['email'] ?? "Email";

      });
    }
  }

  void _handleLogout() async {
    await Utils.removeToken();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB), // Màu nền sáng của mẫu chuyên nghiệp
      appBar: AppBar(
        title: const Text("Cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PROFILE (Giống Ảnh 2) ---
            _buildProfileHeader(),

            const SizedBox(height: 20),

            // --- MENU TÙY CHỌN (Phân loại theo nhóm) ---
            _buildMenuGroup([
              _buildOptionItem(Icons.info_outline, "Thông tin Đoàn viên", Colors.blue, () {}),
              _buildOptionItem(Icons.qr_code_scanner, "Quét mã QR", Colors.blueAccent, () {}),
              _buildOptionItem(Icons.history, "Lịch sử check-in", Colors.blue, () {}),
            ]),

            const SizedBox(height: 15),

            _buildMenuGroup([
              _buildOptionItem(Icons.settings_outlined, "Cài đặt", Colors.grey, () {}),
              _buildOptionItem(Icons.description_outlined, "Điều khoản sử dụng", Colors.blue, () {}),
              _buildOptionItem(Icons.help_outline, "Thông tin ứng dụng", Colors.blue, () {}),
            ]),

            const SizedBox(height: 15),

            // --- NÚT ĐĂNG XUẤT ---
            _buildMenuGroup([
              _buildOptionItem(Icons.logout, "Đăng xuất", Colors.red, _handleLogout, isLogout: true),
            ]),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("Phiên bản ứng dụng 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget xây dựng Header giống Ảnh 2
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF3D5AFE),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  child: const Icon(Icons.person, size: 50, color: Colors.blue),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Color(0xFF3D5AFE), shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildStatusRow(Icons.account_circle_outlined, _hoTen, Colors.grey),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)))),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, Color color, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.blue),
      onTap: onTap,
    );
  }
}