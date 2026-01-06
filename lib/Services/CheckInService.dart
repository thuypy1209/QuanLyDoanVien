import 'dart:convert'; // 👉 Quan trọng: Import thư viện để giải mã JSON
import 'package:http/http.dart' as http;
import '../Utils.dart';
import '../Repository/ApiResponse.dart'; // Đảm bảo đường dẫn import đúng với project của bạn

class CheckInService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/HoatDong';

  // 1. Gửi mã QR lên Server để điểm danh
  Future<ApiResponse<bool>> submitCheckIn(String qrContent) async {
    try {
      String? token = await Utils.getToken();

      int? hoatDongId;

      // 👉 BƯỚC 1: Xử lý thông tin từ mã QR
      try {
        // Trường hợp A: QR chứa chuỗi JSON (Code mới)
        // Ví dụ: {"id":4, "ten":"Mùa Hè Xanh", "time":"..."}
        final Map<String, dynamic> data = jsonDecode(qrContent);

        // Lấy ID hoạt động từ trong JSON
        hoatDongId = data['id'];

        print("🔍 Đã quét được JSON: $data"); // Log để kiểm tra

      } catch (e) {
        // Trường hợp B: QR chỉ chứa số (Code cũ hoặc nhập tay)
        // Nếu jsonDecode lỗi, ta thử ép kiểu trực tiếp sang số
        hoatDongId = int.tryParse(qrContent);
      }

      // Kiểm tra nếu không lấy được ID
      if (hoatDongId == null) {
        return ApiResponse.error("Mã QR không hợp lệ hoặc không chứa ID hoạt động!");
      }

      // 👉 BƯỚC 2: Gọi API Check-in
      // Lưu ý: Vì ID lấy từ QR bây giờ là "ID Hoạt động", nên ta gọi API check-in theo hoạt động
      // (Bạn cần đảm bảo Backend đã có API 'checkin-by-activity' như hướng dẫn trước)
      final url = Uri.parse('$baseUrl/checkin-by-activity/$hoatDongId');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // 👉 BƯỚC 3: Xử lý kết quả
      if (response.statusCode == 200) {
        return ApiResponse.success(true, message: "Điểm danh thành công!");
      } else {
        // Server trả về lỗi (ví dụ: "Chưa đăng ký", "Đã check-in rồi")
        // Nếu server trả về JSON lỗi dạng { "message": "..." } thì ta parse ra
        String errorMsg = response.body;
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson['message'] != null) {
            errorMsg = errorJson['message'];
          }
        } catch (_) {}

        return ApiResponse.error(errorMsg);
      }
    } catch (e) {
      return ApiResponse.error("Lỗi kết nối: $e");
    }
  }

// 2. Lấy lịch sử (Giữ nguyên hoặc dùng ActivityService)
}