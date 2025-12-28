import 'package:flutter/material.dart';

class TextFieldComponent extends StatelessWidget {
  // Các tham số cần truyền vào
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;      // Có phải là ô mật khẩu không?
  final bool obscureText;     // Trạng thái ẩn/hiện (chỉ dùng nếu isPassword = true)
  final VoidCallback? onTogglePassword; // Hàm xử lý khi bấm nút mắt
  final TextCapitalization capitalization;

  // Màu chủ đạo (Xanh HUTECH)
  final Color primaryColor = const Color(0xFF0D47A1);

  const TextFieldComponent({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.obscureText = false,
    this.onTogglePassword,
    this.capitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // Tạo khoảng cách dưới mặc định
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscureText : false,
        textCapitalization: capitalization,
        decoration: InputDecoration(
          hintText: hintText,
          // Icon đầu dòng
          prefixIcon: Icon(icon, color: primaryColor),

          // Nút mắt ẩn/hiện (Chỉ hiện khi là ô mật khẩu)
          suffixIcon: isPassword
              ? IconButton(
            icon: Icon(
              obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onTogglePassword,
          )
              : null,

          // Trang trí viền bo tròn
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}