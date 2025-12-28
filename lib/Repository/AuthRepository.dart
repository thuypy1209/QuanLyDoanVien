import 'dart:convert';
import 'package:http/http.dart' as http;
import 'ApiResponse.dart';

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

  // 2. Xử lý Đăng nhập (Trả về Token dạng String)
  Future<ApiResponse<String>> login(String username, String password) async {
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
        final data = jsonDecode(response.body);
        final token = data['token'];
        return ApiResponse.success(token, message: "Đăng nhập thành công");
      } else {
        return ApiResponse.error("Đăng nhập thất bại: ${response.body}");
      }
    } catch (e) {
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }
}