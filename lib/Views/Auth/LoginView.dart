import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Utils.dart'; // File Utils mới (có giải mã Token)
import '../../Components/TextFieldComponent.dart';
import '../../Services/AuthService.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;

  final Color primaryColor = const Color(0xFF0D47A1);

  // --- HÀM XỬ LÝ ĐĂNG NHẬP (ĐÃ SỬA) ---
  Future<void> _handleLogin() async {
    if (_userController.text.isEmpty || _passController.text.isEmpty) {
      _showDialog("Thông báo", "Vui lòng nhập đầy đủ tài khoản và mật khẩu");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      // Gọi Login
      final response = await authService.login(
          _userController.text,
          _passController.text
      );

      if (response.isSuccess) {
        // [QUAN TRỌNG] Server trả về JSON: { "Token": "ey...", "Message": "..." }
        // Chúng ta cần lấy đúng giá trị của key "Token"
        final data = response.data;
        String? token;

        if (data is Map<String, dynamic>) {
          token = data['Token']; // Lấy chuỗi Token trong JSON
        } else if (data is String) {
          token = data; // Dự phòng nếu server trả về chuỗi trần
        }

        if (token != null) {
          // Gửi Token cho Utils -> Utils sẽ tự Giải mã & Lưu MSSV, Tên, Lớp
          await Utils.saveToken(token);

          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        } else {
          _showDialog("Lỗi", "Không tìm thấy Token trong phản hồi từ Server");
        }
      } else {
        _showDialog("Đăng nhập thất bại", response.message ?? "Lỗi không xác định");
      }

    } catch (e) {
      _showDialog("Lỗi hệ thống", e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
            // Header
            Container(
              height: 320,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0D47A1), Color(0xFF42A5F5)],
                ),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(100)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.school, size: 80, color: Colors.white),
                  SizedBox(height: 15),
                  Text("Cổng Đoàn Viên", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 5),
                  Text("Đăng nhập hệ thống", style: TextStyle(color: Colors.white70, fontSize: 16))
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  TextFieldComponent(
                    controller: _userController,
                    hintText: "Tài khoản / MSSV",
                    icon: Icons.person_outline,
                  ),
                  TextFieldComponent(
                    controller: _passController,
                    hintText: "Mật khẩu",
                    icon: Icons.lock_outline,
                    isPassword: true,
                    obscureText: _isObscure,
                    onTogglePassword: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text("Quên mật khẩu?", style: TextStyle(color: primaryColor)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("ĐĂNG NHẬP", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản? "),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: Text("Đăng ký ngay", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
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