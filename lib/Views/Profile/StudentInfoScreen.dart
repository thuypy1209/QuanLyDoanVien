import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Services/StudentService.dart'; // Import Service
import 'package:quanlidoanvien/Models/StudentModel.dart';
import 'package:quanlidoanvien/Utils.dart';
import '../../Services/UploadService.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class StudentInfoScreen extends StatefulWidget {
  const StudentInfoScreen({super.key});

  @override
  State<StudentInfoScreen> createState() => _StudentInfoScreenState();
}

class _StudentInfoScreenState extends State<StudentInfoScreen> {
  bool _isLoading = true;
  StudentModel? _student;
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchStudentData();
  }

  Future<void> _fetchStudentData() async {
    try {
      // 1. Lấy dữ liệu cơ bản từ Local (để hiện tên/mssv liền)
      final localData = await Utils.getUserInfo();

      // 2. Gọi API lấy thông tin chi tiết (Khoa, Điểm rèn luyện...)
      final service = StudentService();
      final response = await service.getStudentInfo();

      if (mounted) {
        setState(() {
          if (response.isSuccess && response.data != null) {
            _student = response.data;
          } else {
            // Fallback nếu API lỗi: Dùng dữ liệu local
            _student = StudentModel(
                hoTen: localData['name'],
                mssv: localData['mssv'],
                lop: localData['lop'],
                email: localData['email'],
                diemRenLuyen: 0,
                khoa: "---"
            );
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  // Hàm chọn ảnh từ thư viện
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Gọi API Upload ngay sau khi chọn ảnh
      _uploadAvatar();
    }
  }

  // Hàm upload ảnh lên Server
  Future<void> _uploadAvatar() async {
    if (_imageFile == null) return;

    setState(() => _isUploading = true);

    // Gọi UploadService. Nhớ chắc chắn Cổng Backend là 5000 hay cổng khác nha
    bool success = await UploadService.uploadImage("api/sinhvien/upload-avatar", _imageFile!);

    setState(() => _isUploading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật ảnh thành công!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
      }
      // Load lại data để lấy link ảnh mới từ DB (nếu cần thiết)
      // _fetchStudentData();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload thất bại! Vui lòng thử lại.", style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        title: const Text("Thông tin Đoàn viên", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF3D5AFE),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER (Avatar + Tên + MSSV) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                color: Color(0xFF3D5AFE),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                GestureDetector(
                onTap: _pickImage, // Bấm để chọn ảnh
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                      CircleAvatar(
                        radius: 52, // Viền trắng bên ngoài
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue[100],
                          // Load ảnh: Ưu tiên ảnh vừa chọn (FileImage), sau đó là ảnh từ Server (NetworkImage)
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (_student?.avatarUrl != null && _student!.avatarUrl!.isNotEmpty)
                              ? NetworkImage("${Utils.baseUrl}${_student!.avatarUrl}")
                              : null,
                          // Hiện icon nếu không có bất kỳ ảnh nào
                          child: (_imageFile == null && (_student?.avatarUrl == null || _student!.avatarUrl!.isEmpty))
                              ? const Icon(Icons.person, size: 60, color: Color(0xFF3D5AFE))
                              : null,
                        ),
                      ),
                      // Hiển thị vòng xoay đang tải khi upload
                      if (_isUploading)
                        const CircularProgressIndicator(color: Colors.white),

                      // Icon máy ảnh nhỏ ở góc báo hiệu có thể đổi ảnh
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                        ),
                      )
                    ],
                  ),
                ),
            const SizedBox(height: 10),
            Text(
              _student?.hoTen ?? "Sinh viên",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _student?.mssv ?? "---",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
            ],
          ),
        ),

            const SizedBox(height: 20),

            // --- CARD THÔNG TIN HỌC VẤN ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin học vấn",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const Divider(height: 25),

                  _buildInfoRow(Icons.school, "Khoa", _student?.khoa),
                  _buildInfoRow(Icons.class_, "Lớp", _student?.lop),

                  const Divider(height: 25),
                  const Text(
                    "Thông tin liên hệ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 15),
                  _buildInfoRow(Icons.email, "Email", _student?.email),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- CARD ĐIỂM RÈN LUYỆN (Nổi bật) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3D5AFE), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Điểm rèn luyện", style: TextStyle(color: Colors.white70, fontSize: 14)),
                      SizedBox(height: 5),
                      Text("Tổng tích lũy", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      "${_student?.diemRenLuyen ?? 0}",
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị dòng thông tin
  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF3D5AFE)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? "---",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}