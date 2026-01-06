import 'dart:io';
import 'dart:convert'; // 👉 Cần để xử lý JSON phản hồi từ Server
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // 👉 Cần để gọi API Upload

import '../../Utils.dart';

// Import các màn hình chức năng
import '../Dashboard/CheckInScreen.dart';
import 'package:quanlidoanvien/Views/Screen/CheckInHistoryScreen.dart';
import 'package:quanlidoanvien/Views/Profile/StudentInfoScreen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _hoTen = "Đang tải...";
  String _email = "Đang tải...";

  // Biến quản lý ảnh
  File? _avatarFile;          // Ảnh vừa chọn từ thư viện (File Local)
  String? _serverAvatarUrl;   // Đường dẫn ảnh từ Server (URL Online)

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // 1. Tải thông tin User và Ảnh đại diện
  void _loadProfile() async {
    final info = await Utils.getUserInfo();
    if (mounted) {
      setState(() {
        _hoTen = info['name'] ?? "Sinh viên";
        _email = info['email'] ?? "Email";
        // Lấy avatar đã lưu trong Utils (nếu có)
        _serverAvatarUrl = info['avatar'];
      });
    }
  }

  // 2. Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800, // Nén ảnh lại cho nhẹ
        maxHeight: 800,
      );

      if (pickedFile != null) {
        // Hiển thị ngay lập tức để người dùng thấy mượt
        setState(() {
          _avatarFile = File(pickedFile.path);
        });

        // 👉 GỌI HÀM UPLOAD NGAY SAU KHI CHỌN
        await _uploadAvatarToServer(File(pickedFile.path));
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
    }
  }

  // 3. Hàm Upload ảnh lên Server (Backend ASP.NET)
  Future<void> _uploadAvatarToServer(File imageFile) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đang tải ảnh lên máy chủ...")),
      );

      String? token = await Utils.getToken();

      // ⚠️ LƯU Ý: Thay IP 10.0.2.2 bằng IP máy tính nếu chạy trên điện thoại thật
      var uri = Uri.parse('http://10.0.2.2:5000/api/SinhVien/upload-avatar');

      // Tạo request gửi file (Multipart)
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token'; // Đính kèm Token

      var pic = await http.MultipartFile.fromPath("file", imageFile.path);
      request.files.add(pic);

      // Gửi đi
      var response = await request.send();

      if (response.statusCode == 200) {
        // Đọc phản hồi từ server
        var responseString = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseString);

        // Server trả về: { "avatarUrl": "/uploads/avatars/..." }
        String newAvatarUrl = jsonResponse['avatarUrl'];

        print("✅ Upload thành công: $newAvatarUrl");

        // Lưu đường dẫn ảnh mới vào bộ nhớ máy (Utils)
        // (Bạn cần đảm bảo đã thêm hàm updateAvatarUrl vào file Utils.dart như hướng dẫn trước)
        await Utils.updateAvatarUrl(newAvatarUrl);

        // Cập nhật lại biến _serverAvatarUrl để lần sau mở app nó tự load
        setState(() {
          _serverAvatarUrl = newAvatarUrl;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật ảnh thành công!"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi server: ${response.statusCode}")),
        );
      }
    } catch (e) {
      print("Lỗi upload: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi kết nối Server")),
      );
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
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Cá nhân", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 20),

            _buildMenuGroup([
              _buildOptionItem(Icons.info_outline, "Thông tin Đoàn viên", Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentInfoScreen()));
              }),
              _buildOptionItem(Icons.qr_code_scanner, "Quét mã QR", Colors.blueAccent, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInScreen()));
              }),
              _buildOptionItem(Icons.history, "Lịch sử check-in", Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInHistoryScreen()));
              }),
            ]),

            const SizedBox(height: 15),

            _buildMenuGroup([
              _buildOptionItem(Icons.settings_outlined, "Cài đặt", Colors.grey, () {}),
              _buildOptionItem(Icons.description_outlined, "Điều khoản sử dụng", Colors.blue, () {}),
              _buildOptionItem(Icons.help_outline, "Thông tin ứng dụng", Colors.blue, () {}),
            ]),

            const SizedBox(height: 15),

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

  // --- WIDGET HEADER ĐÃ ĐƯỢC NÂNG CẤP ---
  Widget _buildProfileHeader() {
    // Logic xác định ảnh nào sẽ hiển thị
    ImageProvider? imageProvider;

    if (_avatarFile != null) {
      // 1. Ưu tiên: Ảnh vừa chọn từ thư viện
      imageProvider = FileImage(_avatarFile!);
    } else if (_serverAvatarUrl != null && _serverAvatarUrl!.isNotEmpty) {
      // 2. Tiếp theo: Ảnh từ Server (nếu có)
      // Ghép domain vào đường dẫn tương đối
      imageProvider = NetworkImage("http://10.0.2.2:5000$_serverAvatarUrl");
    }
    // 3. Nếu không có cả 2 -> imageProvider sẽ là null (hiện icon)

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF3D5AFE),
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
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
                  backgroundImage: imageProvider, // Hiển thị ảnh (nếu có)
                  child: imageProvider == null
                      ? const Icon(Icons.person, size: 50, color: Colors.blue)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage, // Bấm vào máy ảnh để chọn hình
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF3D5AFE),
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                      ),
                      child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                    ),
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

  // ... Các widget con khác giữ nguyên ...
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
        style: TextStyle(fontWeight: FontWeight.w500, color: isLogout ? Colors.red : Colors.black87),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.blue),
      onTap: onTap,
    );
  }
}