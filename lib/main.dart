import 'package:quanlidoanvien/Utils.dart';

// Import HomeScreen
import 'package:quanlidoanvien/Views/Dashboard/HomeScreen.dart';

// --- IMPORT CÁC MÀN HÌNH ---
import 'package:quanlidoanvien/Views/Auth/LoginView.dart';
import 'package:quanlidoanvien/Views/Auth/WelcomeView.dart';
import 'package:quanlidoanvien/Views/Auth/RegisterView.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: Utils.navigatorKey,
      title: "My app",
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeView(),
        '/login': (context) => const LoginView(),
        '/register': (context) => const RegisterView(),
        '/home': (context) => const HomeScreen(),
      },
    ),
  );
}
