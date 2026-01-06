import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';
import 'package:shared_preferences/shared_preferences.dart';
class AuthRepository {
  // IP cho Android Emulator
  static const String baseUrl = 'http://10.0.2.2:5000/api/Auth';

  // 1. Xử lý Đăng ký
  Future<ApiResponse<bool>> register({
    required String mssv,
    required String password,
    required String confirmPassword,
    required String hoTen,
    required String email,
    required String lop,
    String khoa = "CNTT",
  }) async {
    final url = Uri.parse('$baseUrl/register');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "mssv": mssv,
          "password": password,
          "confirmPassword": confirmPassword,
          "hoTen": hoTen,
          "email": email,
          "lop": lop,
          "khoa": khoa
        }),
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(true, message: "Đăng ký thành công");
      } else {
        // Lấy lỗi từ server trả về
        return ApiResponse.error(response.body);
      }
    } catch (e) {
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }

  // 2. Xử lý Đăng nhập
  Future<ApiResponse<dynamic>> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        print("Server response: ${response.body}");
        final data = jsonDecode(response.body);
        final token = data['token'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', token);

        // Lưu các thông tin phụ để hiện ra màn hình chính
        // Dùng ?? "" để tránh lỗi nếu dữ liệu bị null
        await prefs.setString('mssv', data['mssv'] ?? "");
        await prefs.setString('hoten', data['hoTen'] ?? "Sinh viên");
        await prefs.setString('lop', data['lop'] ?? "");
        await prefs.setString('khoa', data['khoa'] ?? "");
        await prefs.setInt('diemRL', data['diemRL'] ?? 0);
        return ApiResponse.success(token, message: "Đăng nhập thành công");
      } else {
        return ApiResponse.error("Đăng nhập thất bại: ${response.body}");
      }
    } catch (e) {
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }
}