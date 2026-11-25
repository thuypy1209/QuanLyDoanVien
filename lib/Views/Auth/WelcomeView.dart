import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Components/ButtonComponent.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // logo
              Container(
                height: 150,
                width: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Image.asset(
                  'assets/images/hutech.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                "Chào mừng bạn đến với",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 10),
              const Text(
                "CỔNG ĐOÀN VIÊN",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D47A1),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Hệ thống quản lý rèn luyện &\nHồ sơ sinh viên điện tử",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // Nut Dang nhap (Chinh)
              ButtonComponent(
                text: "Đăng nhập ngay",
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),

              const SizedBox(height: 15),

              // Nut Dang ky (Phu)
              ButtonComponent(
                text: "Đăng ký tài khoản mới",
                isOutlined: true,
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
              ),

              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}