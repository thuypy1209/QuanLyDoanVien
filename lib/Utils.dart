import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Utils {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static String baseUrl = 'http://10.0.2.2:5000';


  static int selectIndex = 0;
  static String userName = "";


  static String _getValue(Map<String, dynamic> json, List<String> keys, {String defaultValue = "..."}) {
    for (var key in keys) {
      if (json[key] != null) return json[key].toString();
    }
    return defaultValue;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);

    try {
      Map<String, dynamic> decoded = JwtDecoder.decode(token);

      String mssv = _getValue(decoded, ['MSSV', 'mssv', 'code']);
      String lop = _getValue(decoded, ['Lop', 'lop', 'classId']);

      String hoTen = _getValue(decoded, [
        'Name', 'unique_name', 'name', 'hoTen',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'
      ], defaultValue: "Sinh viên");

      String email = _getValue(decoded, [
        'Email', 'email', 'emailaddress',
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'
      ], defaultValue: "Chưa cập nhật");

      // Lưu vào máy
      await prefs.setString('mssv', mssv);
      await prefs.setString('name', hoTen);
      await prefs.setString('lop', lop);
      await prefs.setString('email', email);

      // Cập nhật biến tĩnh luôn để dùng ngay nếu cần
      userName = hoTen;

      print("Đã lưu: $hoTen ($email)");
    } catch (e) {
      print("Lỗi giải mã: $e");
    }
  }


  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    selectIndex = 0;
  }

  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'mssv': prefs.getString('mssv') ?? "...",
      'name': prefs.getString('name') ?? "...",
      'lop': prefs.getString('lop') ?? "...",
      'email': prefs.getString('email') ?? "...",
    };
  }
}