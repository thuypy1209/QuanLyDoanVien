import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:signalr_netcore/signalr_netcore.dart';
import 'package:quanlidoanvien/Utils.dart';
import '../Repository/ApiResponse.dart';

// class ChatService {
//   late HubConnection _hubConnection;
//   Function(String user, String message)? onMessageReceived;
//   // 1. Kết nối SignalR (Giữ nguyên)
//   Future<void> connectSignalR() async {
//     final token = await Utils.getToken();
//     final serverUrl = "${Utils.baseUrl}/chathub"; // Lưu ý đường dẫn phải khớp Program.cs
//
//     _hubConnection = HubConnectionBuilder()
//         .withUrl(serverUrl, options: HttpConnectionOptions(
//       accessTokenFactory: () async => token ?? "",
//     ))
//         .build();
//
//     _hubConnection.on("ReceiveMessage", (arguments) {
//       if (arguments != null && arguments.length >= 2) {
//         final user = arguments[0].toString();
//         final message = arguments[1].toString();
//         if (onMessageReceived != null) {
//           onMessageReceived!(user, message);
//         }
//       }
//     });
//
//     try {
//       await _hubConnection.start();
//       print(" Đã kết nối SignalR");
//     } catch (e) {
//       print(" Lỗi kết nối SignalR: $e");
//     }
//   }

//   // 2. Gửi tin nhắn (Vẫn gọi API nhưng Server không lưu nữa)
//   Future<ApiResponse<bool>> sendMessage(String content) async {
//     try {
//       final token = await Utils.getToken();
//       final userInfo = await Utils.getUserInfo();
//
//       // Lấy tên người gửi từ bộ nhớ máy
//       final senderName = userInfo['name'] ?? "User";
//
//       final url = Uri.parse('${Utils.baseUrl}/api/Chat/send');
//
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode({
//           "SenderId": senderName, // Gửi tên người gửi để bên kia hiện
//           "Message": content
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         return ApiResponse.success(true);
//       } else {
//         return ApiResponse.error("Lỗi gửi tin");
//       }
//     } catch (e) {
//       return ApiResponse.error("Lỗi kết nối: $e");
//     }
//   }
//
//   // void disconnect() {
//   //   _hubConnection.stop();
//   // }
// }