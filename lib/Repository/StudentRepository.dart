import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quanlidoanvien/Utils.dart';
import 'package:quanlidoanvien/Models/StudentModel.dart';
import 'ApiResponse.dart';

class StudentRepository {

  Future<ApiResponse<StudentModel>> getStudentInfo() async {
    try {
      String? token = await Utils.getToken();
      if (token == null) {
        return ApiResponse.error("Chưa đăng nhập");
      }

      final url = Uri.parse('${Utils.baseUrl}/api/SinhVien/me');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ApiResponse.success(StudentModel.fromJson(data));
      } else if (response.statusCode == 401) {
        return ApiResponse.error("Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.");
      } else {
        return ApiResponse.error("Lỗi: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }
}