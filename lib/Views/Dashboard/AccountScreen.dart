import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../Utils.dart';

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

  File? _avatarFile;
  String? _serverAvatarUrl;
  final ImagePicker _picker = ImagePicker();

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
        _serverAvatarUrl = info['avatar'];
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        setState(() {
          _avatarFile = File(pickedFile.path);
        });
        await _uploadAvatarToServer(File(pickedFile.path));
      }
    } catch (e) {
      print("Lỗi chọn ảnh: $e");
    }
  }

  Future<void> _uploadAvatarToServer(File imageFile) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đang tải ảnh...")));
      String? token = await Utils.getToken();

      var uri = Uri.parse('${Utils.baseUrl}/api/SinhVien/upload-avatar');

      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath("file", imageFile.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseString = await response.stream.bytesToString();
        var jsonResponse = jsonDecode(responseString);
        String newAvatarUrl = jsonResponse['avatarUrl'];

        await Utils.updateAvatarUrl(newAvatarUrl);

        setState(() {
          _serverAvatarUrl = newAvatarUrl;
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Đổi ảnh thành công!"), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${response.statusCode}")));
      }
    } catch (e) {
      print("Lỗi upload: $e");
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
              _buildOptionItem(Icons.logout, "Đăng xuất", Colors.red, _handleLogout, isLogout: true),
            ]),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    ImageProvider? imageProvider;
    if (_avatarFile != null) {
      imageProvider = FileImage(_avatarFile!);
    } else if (_serverAvatarUrl != null && _serverAvatarUrl!.isNotEmpty) {
      imageProvider = NetworkImage("${Utils.baseUrl}$_serverAvatarUrl");
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF3D5AFE),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue[100],
                  backgroundImage: imageProvider,
                  child: imageProvider == null ? const Icon(Icons.person, size: 50, color: Colors.blue) : null,
                ),
                Positioned(
                  bottom: 0, right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Color(0xFF3D5AFE), shape: BoxShape.circle),
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
                  const SizedBox(height: 4),
                  Text(_hoTen, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Column(children: children),
    );
  }

  Widget _buildOptionItem(IconData icon, String title, Color color, VoidCallback onTap, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: color, size: 24),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isLogout ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.blue),
      onTap: onTap,
    );
  }
}