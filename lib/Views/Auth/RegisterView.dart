import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Components/TextFieldComponent.dart';
import 'package:quanlidoanvien/Services/AuthService.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // 1. Khai báo Controller
  final TextEditingController _mssvController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _isLoading = false;

  // --- HÀM XỬ LÝ ĐĂNG KÝ (ĐÃ CẬP NHẬT) ---
  Future<void> _handleRegister() async {
    // 1. Validate Client (Giữ nguyên)
    if (_mssvController.text.isEmpty ||
        _nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _classController.text.isEmpty ||
        _passController.text.isEmpty ||
        _confirmPassController.text.isEmpty) {
      _showDialog("Thiếu thông tin", "Vui lòng điền đầy đủ tất cả các trường.");
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      _showDialog("Lỗi", "Mật khẩu nhập lại không khớp.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. GỌI SERVICE (Thay vì dùng http trực tiếp)
      final authService = AuthService();

      final response = await authService.register(
        mssv: _mssvController.text,
        password: _passController.text,
        confirmPassword: _confirmPassController.text,
        hoTen: _nameController.text,
        email: _emailController.text,
        lop: _classController.text,
        // khoa: "CNTT" (Đã mặc định trong Service/Repo nên không cần truyền nếu không đổi)
      );

      // 3. Xử lý kết quả dựa trên ApiResponse
      if (response.isSuccess) {
        // Thành công
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AlertDialog(
              title: const Text("Thành công"),
              content: const Text("Đăng ký tài khoản thành công! Vui lòng đăng nhập."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx); // Tắt dialog
                    Navigator.pop(context); // Quay về màn hình Login
                  },
                  child: const Text("Về trang Đăng nhập"),
                )
              ],
            ),
          );
        }
      } else {
        // Thất bại: Lấy thông báo lỗi từ Service trả về
        _showDialog("Đăng ký thất bại", response.message ?? "Lỗi không xác định");
      }

    } catch (e) {
      _showDialog("Lỗi hệ thống", e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Hàm hiện thông báo nhanh
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Đóng"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- GIAO DIỆN GIỮ NGUYÊN 100% ---
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 50, left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_add_alt_1, size: 60, color: Colors.white),
                        SizedBox(height: 10),
                        Text("Đăng Ký Tài Khoản", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextFieldComponent(
                    controller: _mssvController,
                    hintText: "Mã số sinh viên",
                    icon: Icons.card_membership,
                  ),

                  TextFieldComponent(
                    controller: _nameController,
                    hintText: "Họ và tên",
                    icon: Icons.person_outline,
                    capitalization: TextCapitalization.words,
                  ),

                  TextFieldComponent(
                    controller: _emailController,
                    hintText: "Email (Ví dụ: sv123@gmail.com)",
                    icon: Icons.email_outlined,
                    capitalization: TextCapitalization.none,
                  ),

                  TextFieldComponent(
                    controller: _classController,
                    hintText: "Lớp (Ví dụ: 21DTH01)",
                    icon: Icons.class_outlined,
                    capitalization: TextCapitalization.characters,
                  ),

                  TextFieldComponent(
                    controller: _passController,
                    hintText: "Mật khẩu",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _obscurePass,
                    onTogglePassword: () {
                      setState(() => _obscurePass = !_obscurePass);
                    },
                  ),

                  TextFieldComponent(
                    controller: _confirmPassController,
                    hintText: "Nhập lại mật khẩu",
                    icon: Icons.lock_reset,
                    isPassword: true,
                    obscureText: _obscureConfirmPass,
                    onTogglePassword: () {
                      setState(() => _obscureConfirmPass = !_obscureConfirmPass);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Nút đăng ký
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("HOÀN TẤT ĐĂNG KÝ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}