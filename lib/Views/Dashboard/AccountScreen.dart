import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:quanlidoanvien/Components/AppBarComponent.dart';
import '../../Utils.dart';

import '../Dashboard/CheckInScreen.dart';
import 'package:quanlidoanvien/Views/Screen/CheckInHistoryScreen.dart';
import 'package:quanlidoanvien/Views/Profile/StudentInfoScreen.dart';
import 'package:quanlidoanvien/Views/Portal/SoDoanScreen.dart';
import 'package:quanlidoanvien/Views/Portal/DoanPhiScreen.dart';
import 'package:quanlidoanvien/Views/Portal/XepLoaiScreen.dart';
import 'package:quanlidoanvien/Views/Portal/ChungNhanScreen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _hoTen = "Đang tải...";
  String _email = "Đang tải...";
  String _mssv = "";
  String _lop = "";

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
        _mssv = info['mssv'] ?? "";
        _lop = info['lop'] ?? "";
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đổi ảnh thành công!"), backgroundColor: Colors.green),
        );
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
      appBar: const AppBarComponent(
        title: "Cá nhân & Cổng Đoàn Viên",
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 16),

            // Nhóm 1: Hồ sơ & Sổ Đoàn
            _buildSectionTitle("HỒ SƠ & SỔ ĐOÀN"),
            _buildMenuGroup([
              _buildOptionItem(
                Icons.badge_outlined,
                "Thẻ & Thông tin Đoàn viên",
                const Color(0xFF0D47A1),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentInfoScreen())),
              ),
              _buildOptionItem(
                Icons.folder_shared_outlined,
                "Sổ Đoàn & Vị trí lưu trữ",
                const Color(0xFF7E22CE),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SoDoanScreen())),
              ),
            ]),

            const SizedBox(height: 16),

            // Nhóm 2: Tài chính & Thi đua
            _buildSectionTitle("NGHĨA VỤ & THI ĐUA"),
            _buildMenuGroup([
              _buildOptionItem(
                Icons.account_balance_wallet_outlined,
                "Đoàn phí của tôi",
                const Color(0xFF059669),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DoanPhiScreen())),
              ),
              _buildOptionItem(
                Icons.workspace_premium_outlined,
                "Bình bầu & Xếp loại thi đua",
                const Color(0xFFD97706),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const XepLoaiScreen())),
              ),
              _buildOptionItem(
                Icons.verified_outlined,
                "Giấy chứng nhận điện tử",
                const Color(0xFF0284C7),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChungNhanScreen())),
              ),
            ]),

            const SizedBox(height: 16),

            // Nhóm 3: Điểm danh & Check-in
            _buildSectionTitle("ĐIỂM DANH HOẠT ĐỘNG"),
            _buildMenuGroup([
              _buildOptionItem(
                Icons.qr_code_scanner,
                "Quét mã QR điểm danh",
                const Color(0xFF2563EB),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInScreen())),
              ),
              _buildOptionItem(
                Icons.history,
                "Lịch sử tham gia & Điểm danh",
                const Color(0xFF475569),
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInHistoryScreen())),
              ),
            ]),

            const SizedBox(height: 16),

            // Nhóm 4: Tài khoản
            _buildMenuGroup([
              _buildOptionItem(
                Icons.logout,
                "Đăng xuất",
                Colors.red,
                _handleLogout,
                isLogout: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF94A3B8),
          letterSpacing: 0.8,
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
        color: Color(0xFF0D47A1),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: Colors.blue[100],
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person, size: 40, color: Color(0xFF0D47A1))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _hoTen,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (_mssv.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "MSSV: $_mssv${_lop.isNotEmpty ? " • $_lop" : ""}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'monospace',
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildOptionItem(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap, {
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isLogout ? FontWeight.w700 : FontWeight.w600,
          color: isLogout ? Colors.red : const Color(0xFF1E293B),
        ),
      ),
      trailing: isLogout
          ? null
          : const Icon(Icons.chevron_right, size: 20, color: Color(0xFF94A3B8)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    );
  }
}
