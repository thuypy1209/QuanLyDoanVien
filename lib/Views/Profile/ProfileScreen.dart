import 'package:flutter/material.dart';
import '../../Utils.dart';
import '../Dashboard/CheckInScreen.dart';
import 'package:quanlidoanvien/Views/Screen/CheckInHistoryScreen.dart';
import 'package:quanlidoanvien/Views/Auth/LoginView.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Dữ liệu giả định (Sau này lấy từ Utils.getUserInfo())
  String _name = "Sinh viên";
  String _email = "sinhvien@hutech.edu.vn";

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() async {
    // Giả lập lấy thông tin từ bộ nhớ máy
    final info = await Utils.getUserInfo();
    setState(() {
      _name = info['name'] ?? "Nguyễn Văn A";
      _email = info['email'] ?? "sv@gmail.com";
    });
  }

  // Hàm Đăng xuất
  void _handleLogout() async {
    // Xóa token
    await Utils.saveToken("");
    // Quay về màn hình đăng nhập
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Màu nền xám nhạt
      body: Column(
        children: [
          // 1. PHẦN HEADER (Màu xanh + Avatar)
          _buildHeader(),

          const SizedBox(height: 20),

          // 2. PHẦN MENU CHỨC NĂNG
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  // Nhóm 1: Chức năng chính
                  _buildSectionContainer([
                    _buildMenuItem(
                        icon: Icons.info_outline,
                        text: "Thông tin Đoàn viên",
                        color: Colors.blue,
                        onTap: () {
                          // Điều hướng đến trang thông tin chi tiết (nếu có)
                        }
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                        icon: Icons.qr_code_scanner,
                        text: "Quét mã QR",
                        color: Colors.blue,
                        onTap: () {
                          // 👉 Chuyển sang màn hình Quét QR
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInScreen()));
                        }
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                        icon: Icons.history,
                        text: "Lịch sử check-in",
                        color: Colors.blue,
                        onTap: () {
                          // 👉 Chuyển sang màn hình Lịch sử
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInHistoryScreen()));
                        }
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // Nhóm 2: Cài đặt & Thông tin
                  _buildSectionContainer([
                    _buildMenuItem(icon: Icons.settings_outlined, text: "Cài đặt", color: Colors.grey, onTap: () {}),
                    _buildDivider(),
                    _buildMenuItem(icon: Icons.description_outlined, text: "Điều khoản sử dụng", color: Colors.blue, onTap: () {}),
                    _buildDivider(),
                    _buildMenuItem(icon: Icons.help_outline, text: "Thông tin ứng dụng", color: Colors.blue, onTap: () {}),
                  ]),

                  const SizedBox(height: 20),

                  // Nhóm 3: Đăng xuất
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: _buildMenuItem(
                        icon: Icons.logout,
                        text: "Đăng xuất",
                        color: Colors.red,
                        isArrowVisible: true,
                        onTap: _handleLogout
                    ),
                  ),

                  const SizedBox(height: 30),
                  const Text("Phiên bản ứng dụng 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget Header (Avatar + Tên)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF446AF3), // Màu xanh giống trong ảnh
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.white.withOpacity(0.3),
                child: const CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=12"), // Ảnh giả
                  // Hoặc dùng Icon nếu không có ảnh:
                  // child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, size: 14, color: Colors.blue),
                ),
              )
            ],
          ),
          const SizedBox(width: 15),
          // Tên và Email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  _email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Nút chỉnh sửa
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, color: Colors.white),
          )
        ],
      ),
    );
  }

  // Widget khung chứa các item
  Widget _buildSectionContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  // Widget dòng kẻ mờ
  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5, indent: 50, endIndent: 20, color: Colors.grey);
  }

  // Widget từng dòng Menu
  Widget _buildMenuItem({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
    bool isArrowVisible = true
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color), // Icon bên trái có màu
      title: Text(text, style: TextStyle(
          color: color == Colors.red ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w500
      )),
      trailing: isArrowVisible
          ? const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    );
  }
}