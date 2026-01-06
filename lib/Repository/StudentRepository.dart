import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quanlidoanvien/Utils.dart'; // Đảm bảo import đúng Utils
import '../Models/StudentModel.dart';
import 'ApiResponse.dart';

class StudentRepository {
  // Không cần khai báo baseUrl riêng ở đây nếu đã dùng Utils.baseUrl

  Future<ApiResponse<StudentModel>> getStudentInfo() async {
    try {
      // 1. Lấy Token
      String? token = await Utils.getToken();
      if (token == null) {
        return ApiResponse.error("Chưa đăng nhập");
      }

      // 2. Tạo URL chuẩn (Dùng Utils.baseUrl để đồng bộ toàn app)
      final url = Uri.parse('${Utils.baseUrl}/api/SinhVien/me');

      // 3. Gọi API
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token", // Gửi Token xác thực
        },
      );

      // 4. Xử lý kết quả
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