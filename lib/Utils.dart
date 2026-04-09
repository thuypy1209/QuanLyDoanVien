import 'dart:convert';
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
      String hoTen = _getValue(decoded, ['Name', 'unique_name', 'name', 'hoTen'], defaultValue: "Sinh viên");
      String email = _getValue(decoded, ['Email', 'email', 'emailaddress'], defaultValue: "Chưa cập nhật");
      String avatarUrl = _getValue(decoded, ['Avatar', 'avatar', 'avatarUrl'], defaultValue: "");

      await prefs.setString('mssv', mssv);
      await prefs.setString('name', hoTen);
      await prefs.setString('lop', lop);
      await prefs.setString('email', email);
      await prefs.setString('avatar', avatarUrl);

      userName = hoTen;
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

    String? userInfoStr = prefs.getString('user_info');
    String avatarUrl = "";


    if (userInfoStr != null) {
      try {
        Map<String, dynamic> userInfo = jsonDecode(userInfoStr);
        avatarUrl = userInfo['avatar'] ?? "";
      } catch (_) {}
    }

    return {
      'mssv': prefs.getString('mssv') ?? "...",
      'name': prefs.getString('name') ?? "...",
      'lop': prefs.getString('lop') ?? "...",
      'email': prefs.getString('email') ?? "...",
      'avatar': avatarUrl,
    };
  }

  static Future<void> updateAvatarUrl(String newUrl) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userInfoStr = prefs.getString('user_info');

    Map<String, dynamic> userInfo = {};
    if (userInfoStr != null) {
      try {
        userInfo = jsonDecode(userInfoStr);
      } catch (_) {}
    }

    userInfo['avatar'] = newUrl;
    await prefs.setString('user_info', jsonEncode(userInfo));
  }
  static Future<String> getName() async {
    final prefs = await SharedPreferences.getInstance();
    // Lấy tên đã lưu, nếu không có thì trả về "Sinh viên"
    return prefs.getString('name') ?? "Sinh viên";
  }
}