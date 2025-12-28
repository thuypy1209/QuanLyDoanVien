import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quanlidoanvien/Utils.dart'; // Import Utils để lấy Token
import '../Models/ActivityModel.dart';      // Import Model
import 'ApiResponse.dart';                  // Import Wrapper phản hồi

class ActivityRepository {
  // Đường dẫn API (Lưu ý: Android Emulator dùng 10.0.2.2)
  static const String baseUrl = 'http://10.0.2.2:5000/api/HoatDong';

  // Hàm lấy danh sách hoạt động
  Future<ApiResponse<List<ActivityModel>>> getActivities() async {
    try {
      // 1. Lấy Token từ Shared Preferences
      String? token = await Utils.getToken();

      if (token == null) {
        return ApiResponse.error("Chưa đăng nhập hoặc phiên hết hạn.");
      }

      // 2. Gọi API (Gửi kèm Token trong Header)
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // 3. Xử lý kết quả trả về
      if (response.statusCode == 200) {
        // API trả về một mảng JSON: [{}, {}, ...]
        final List<dynamic> jsonData = jsonDecode(response.body);

        // Chuyển đổi List<dynamic> thành List<ActivityModel>
        // Hàm map sẽ chạy vòng lặp qua từng phần tử và gọi ActivityModel.fromJson
        List<ActivityModel> activities = jsonData
            .map((jsonItem) => ActivityModel.fromJson(jsonItem))
            .toList();

        return ApiResponse.success(activities);

      } else if (response.statusCode == 401) {
        return ApiResponse.error("Phiên đăng nhập hết hạn (401).");
      } else {
        return ApiResponse.error("Lỗi Server: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      // Bắt lỗi mạng, lỗi parse JSON...
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }
}