import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Utils.dart'; // Để lưu Token
import '../../Components/TextFieldComponent.dart'; // <--- Import Component
import '../../Services/AuthService.dart'; // <--- Import Service (Repository Pattern)

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // 1. Khai báo Controller
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Biến trạng thái
  bool _isObscure = true;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF0D47A1);

  // --- HÀM XỬ LÝ ĐĂNG NHẬP (ĐÃ CẬP NHẬT) ---
  Future<void> _handleLogin() async {
    // 1. Kiểm tra nhập liệu
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showDialog("Thông báo", "Vui lòng nhập đầy đủ tài khoản và mật khẩu");
      return;
    }

    setState(() {
      _isLoading = true; // Bắt đầu load
    });

    try {
      // 2. GỌI SERVICE
      final authService = AuthService();

      // Gọi hàm login và nhận về ApiResponse<String> (String ở đây là Token)
      final response = await authService.login(
          _userController.text,
          _passController.text
      );

      // 3. Xử lý kết quả
      if (response.isSuccess) {
        // Thành công: response.data chính là Token
        final token = response.data;

        if (token != null) {
          // Lưu Token vào máy
          await Utils.saveToken(token);

          // Chuyển trang (Xóa lịch sử để không back lại login được)
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                    (route) => false
            );
          }
        }
      } else {
        // Thất bại: Hiện lỗi từ Server (VD: Sai pass, tk không tồn tại...)
        _showDialog("Đăng nhập thất bại", response.message ?? "Lỗi không xác định");
      }

    } catch (e) {
      _showDialog("Lỗi hệ thống", e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false; // Tắt loading
        });
      }
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Đóng"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER (Giữ nguyên) ---
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF42A5F5),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(100),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.school, size: 80, color: Colors.white),
                  SizedBox(height: 15),
                  Text(
                    "Cổng Đoàn Viên",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Đăng nhập hệ thống",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  )
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- FORM ĐĂNG NHẬP (DÙNG COMPONENT MỚI) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // 1. Ô Tài khoản
                  TextFieldComponent(
                    controller: _userController,
                    hintText: "Tài khoản / MSSV",
                    icon: Icons.person_outline,
                  ),

                  // 2. Ô Mật khẩu
                  TextFieldComponent(
                    controller: _passController,
                    hintText: "Mật khẩu",
                    icon: Icons.lock_outline,
                    isPassword: true,          // Bật chế độ mật khẩu
                    obscureText: _isObscure,   // Trạng thái ẩn/hiện
                    onTogglePassword: () {     // Hàm đổi trạng thái
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),

                  // Quên mật khẩu
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Quên mật khẩu?", style: TextStyle(color: primaryColor)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- NÚT ĐĂNG NHẬP ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "ĐĂNG NHẬP",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Chuyển qua Đăng ký
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text(
                          "Đăng ký ngay",
                          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}