import 'dart:io';
import 'package:http/http.dart' as http;
import '../Utils.dart';

class UploadService {

  // - endpoint: 'api/sinhvien/upload-avatar' HOẶC 'api/hoatdong/1/upload-image'
  static Future<bool> uploadImage(String endpoint, File imageFile) async {
    try {
      String? token = await Utils.getToken();
      var uri = Uri.parse("${Utils.baseUrl}/$endpoint");
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      var multipartFile = await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      );

      request.files.add(multipartFile);

      var response = await request.send();

      if (response.statusCode == 200) {
        print("Upload thành công!");
        return true;
      } else {
        // In ra lỗi để dễ bắt bệnh nếu xui bị tạch
        String responseBody = await response.stream.bytesToString();
        print("Lỗi upload: Mã ${response.statusCode} - $responseBody");
        return false;
      }
    } catch (e) {
      print("Exception khi upload: $e");
      return false;
    }
  }
}