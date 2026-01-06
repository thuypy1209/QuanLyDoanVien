import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quanlidoanvien/Utils.dart';
import '../Models/ActivityModel.dart';
import 'ApiResponse.dart';

class ActivityRepository {

  static const String baseUrl = 'http://10.0.2.2:5000/api/HoatDong';

  // Hàm lấy danh sách hoạt động
  Future<ApiResponse<List<ActivityModel>>> getActivities() async {
    try {

      String? token = await Utils.getToken();
      if (token == null) {
        return ApiResponse.error("Chưa đăng nhập hoặc phiên hết hạn.");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );


      if (response.statusCode == 200) {

        final List<dynamic> jsonData = jsonDecode(response.body);

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
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }
  Future<ApiResponse<bool>> registerActivity(int activityId) async {
    try {
      String? token = await Utils.getToken();

      final url = Uri.parse('$baseUrl/dangky/$activityId');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(true, message: "Đăng ký thành công!");
      } else {

        String msg = response.body;
        try {

          final errJson = jsonDecode(response.body);
          msg = errJson['message'] ?? response.body;
        } catch (_) {}

        return ApiResponse.error(msg);
      }
    } catch (e) {
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }

  Future<ApiResponse<List<ActivityModel>>> getHistory() async {
    try {
      String? token = await Utils.getToken();
      // Gọi API: GET api/HoatDong/lich-su
      final url = Uri.parse('$baseUrl/lich-su');

      final response = await http.get(
        url,
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        print("HISTORY JSON: ${response.body}");
        final List<dynamic> jsonData = jsonDecode(response.body);
        List<ActivityModel> activities = jsonData
            .map((item) => ActivityModel.fromJson(item))
            .toList();
        return ApiResponse.success(activities);
      } else {
        return ApiResponse.error("Lỗi tải lịch sử: ${response.statusCode}");
      }
    } catch (e) {
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }
}