import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Utils.dart';
import '../Repository/ApiResponse.dart';
import '../Models/SoDoanModel.dart';
import '../Models/DoanPhiModel.dart';
import '../Models/XepLoaiModel.dart';
import '../Models/ChungNhanModel.dart';

class PortalService {
  Future<ApiResponse<StudentSoDoanResponse>> getMySoDoan() async {
    try {
      final token = await Utils.getToken();
      if (token == null) return ApiResponse.error('Chưa đăng nhập');

      final url = Uri.parse('${Utils.baseUrl}/api/SoDoan/me');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return ApiResponse.success(StudentSoDoanResponse.fromJson(data));
      } else {
        return ApiResponse.error('Lỗi ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  Future<ApiResponse<StudentDoanPhiResponse>> getMyDoanPhi() async {
    try {
      final token = await Utils.getToken();
      if (token == null) return ApiResponse.error('Chưa đăng nhập');

      final url = Uri.parse('${Utils.baseUrl}/api/DoanPhi/me');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return ApiResponse.success(StudentDoanPhiResponse.fromJson(data));
      } else {
        return ApiResponse.error('Lỗi ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  Future<ApiResponse<StudentXepLoaiResponse>> getMyXepLoai() async {
    try {
      final token = await Utils.getToken();
      if (token == null) return ApiResponse.error('Chưa đăng nhập');

      final url = Uri.parse('${Utils.baseUrl}/api/XepLoai/me');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return ApiResponse.success(StudentXepLoaiResponse.fromJson(data));
      } else {
        return ApiResponse.error('Lỗi ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  Future<ApiResponse<String>> submitTuDanhGia({
    required String namHoc,
    required String xepLoai,
    required String tuDanhGia,
  }) async {
    try {
      final token = await Utils.getToken();
      if (token == null) return ApiResponse.error('Chưa đăng nhập');

      final url = Uri.parse('${Utils.baseUrl}/api/XepLoai/tu-danh-gia');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'namHoc': namHoc,
          'xepLoai': xepLoai,
          'tuDanhGia': tuDanhGia,
        }),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return ApiResponse.success(data['message'] ?? 'Lưu bản tự đánh giá thành công');
      } else {
        return ApiResponse.error('Lỗi ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }

  Future<ApiResponse<StudentChungNhanResponse>> getMyChungNhan() async {
    try {
      final token = await Utils.getToken();
      if (token == null) return ApiResponse.error('Chưa đăng nhập');

      final url = Uri.parse('${Utils.baseUrl}/api/ChungNhan/me');
      final res = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return ApiResponse.success(StudentChungNhanResponse.fromJson(data));
      } else {
        return ApiResponse.error('Lỗi ${res.statusCode}: ${res.body}');
      }
    } catch (e) {
      return ApiResponse.error('Lỗi kết nối: $e');
    }
  }
}
