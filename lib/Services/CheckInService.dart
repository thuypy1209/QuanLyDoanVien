import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils.dart'; // File Utils chứa baseUrl và getToken
import '../Models/CheckInHistoryModel.dart'; // Model (Xem code bên dưới)

class CheckInService {
  // 1. GỬI MÃ QR ĐỂ ĐIỂM DANH
  Future<Map<String, dynamic>> submitCheckIn(String qrCode) async {
    try {
      final token = await Utils.getToken();
      final url = Uri.parse('${Utils.baseUrl}/api/CheckIn/submit');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"qrCode": qrCode}),
      );

      final data = jsonDecode(response.body);

      // Trả về kết quả kèm trạng thái success true/false
      if (response.statusCode == 200) {
        return {"success": true, "message": data['message'], "tenHoatDong": data['tenHoatDong']};
      } else {
        return {"success": false, "message": data['message'] ?? "Lỗi không xác định"};
      }
    } catch (e) {
      return {"success": false, "message": "Lỗi kết nối: $e"};
    }
  }

  // 2. LẤY LỊCH SỬ
  Future<List<CheckInHistoryModel>> getHistory() async {
    try {
      final token = await Utils.getToken();
      final url = Uri.parse('${Utils.baseUrl}/api/CheckIn/history');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> rawData = jsonDecode(response.body);
        return rawData.map((e) => CheckInHistoryModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("Error fetching history: $e");
      return [];
    }
  }
}