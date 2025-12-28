import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quanlidoanvien/Utils.dart';
import '../Models/StudentModel.dart';
import 'ApiResponse.dart';

class StudentRepository {
  // Đổi đường dẫn sang SinhVien
  static const String baseUrl = 'http://10.0.2.2:5000/api/SinhVien';

  Future<ApiResponse<StudentModel>> getStudentInfo() async {
    // Gọi vào endpoint "me" mà ta vừa tạo
    final url = Uri.parse('$baseUrl/me');

    String? token = await Utils.getToken();

    if (token == null) {
      return ApiResponse.error("Chưa đăng nhập");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Gửi Token đi
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(StudentModel.fromJson(data));
      } else {
        return ApiResponse.error("Lỗi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }
}