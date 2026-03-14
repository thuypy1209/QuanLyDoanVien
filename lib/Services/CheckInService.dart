import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils.dart';
import '../Repository/ApiResponse.dart';

class CheckInService {
  static final String baseUrl = '${Utils.baseUrl}/api/HoatDong';

  Future<ApiResponse<bool>> submitCheckIn(String qrContent) async {
    try {
      String? token = await Utils.getToken();
      int? hoatDongId;
      try {
        final Map<String, dynamic> data = jsonDecode(qrContent);
        if (data['type'] == 'CHECKIN_ACTIVITY') {
          hoatDongId = data['id'];
        } else {
          return ApiResponse.error("Mã QR này không dùng để điểm danh hoạt động!");
        }
      } catch (e) {
        hoatDongId = int.tryParse(qrContent);
      }
      if (hoatDongId == null) {
        return ApiResponse.error("Mã QR không hợp lệ!");
      }
      final url = Uri.parse('$baseUrl/checkin-by-activity/$hoatDongId');
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      final result = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return ApiResponse.success(true, message: result['message'] ?? "Điểm danh thành công!");
      } else {
        return ApiResponse.error(result['message'] ?? "Điểm danh thất bại!");
      }
    } catch (e) {
      return ApiResponse.error("Lỗi hệ thống: $e");
    }
  }
}