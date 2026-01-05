import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class Utils{
  static  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String userName = "";
  static int selectIndex = 0;
  static String baseUrl = 'http://10.0.2.2:5000';

  // 1. Lưu Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
    print("Đã lưu token vào bộ nhớ máy!");
  }

  // 2. Lấy Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken'); // Trả về null nếu chưa có
  }

  // 3. Xóa Token
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    print("Đã xóa token (Đăng xuất)!");
  }

}