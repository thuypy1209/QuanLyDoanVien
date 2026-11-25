import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:http/io_client.dart';
import '../Utils.dart';

class ChatService {
  HubConnection? _hubConnection;
  Function(Map<String, dynamic> data)? onMessageReceived;
  Function(bool isConnected)? onConnectionChanged;
  bool get isConnected => _hubConnection?.state == HubConnectionState.connected;

  Future<void> initSignalR() async {
    final token = await Utils.getToken();
    final serverUrl = "${Utils.baseUrl}/chathub";

    print("SignalR: Bắt đầu khởi tạo kết nối tới: $serverUrl");

    if (token == null || token.trim().isEmpty) {
      print("SignalR CẢNH BÁO: Chưa tìm thấy accessToken (chưa đăng nhập). Vui lòng đăng nhập trước khi kết nối Chat.");
      onConnectionChanged?.call(false);
      return;
    }

    if (_hubConnection != null && _hubConnection!.state != HubConnectionState.disconnected) {
      print("SignalR: Kết nối đã tồn tại ở trạng thái ${_hubConnection!.state}");
      return;
    }

    try {
      HttpConnectionOptions options;
      if (kIsWeb) {
        options = HttpConnectionOptions(
          accessTokenFactory: () async => await Utils.getToken() ?? "",
          logging: (level, message) => print("SignalR [Web]: $message"),
        );
      } else {
        final httpClient = HttpClient()
          ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
        options = HttpConnectionOptions(
          client: IOClient(httpClient),
          accessTokenFactory: () async => await Utils.getToken() ?? "",
          logging: (level, message) => print("SignalR: $message"),
        );
      }

      _hubConnection = HubConnectionBuilder()
          .withUrl(serverUrl, options)
          .withAutomaticReconnect([0, 2000, 5000, 10000, 30000])
          .build();

      _hubConnection!.on("ReceiveMessage", (List<dynamic>? arguments) {
        if (arguments != null && arguments.isNotEmpty && onMessageReceived != null) {
          onMessageReceived!({
            "user": arguments[0].toString(),
            "message": arguments.length > 1 ? arguments[1].toString() : "",
            "time": DateTime.now().toString()
          });
        }
      });

      _hubConnection!.onclose((error) {
        print("SignalR: Kết nối đã đóng ($error)");
        onConnectionChanged?.call(false);
      });

      _hubConnection!.onreconnecting((error) {
        print("SignalR: Đang kết nối lại ($error)...");
        onConnectionChanged?.call(false);
      });

      _hubConnection!.onreconnected((connectionId) {
        print("SignalR: Đã kết nối lại thành công (connectionId: $connectionId)");
        onConnectionChanged?.call(true);
      });

      if (_hubConnection!.state == HubConnectionState.disconnected) {
        await _hubConnection!.start();
        onConnectionChanged?.call(true);
        print("SignalR: Đã kết nối thành công tới ChatHub!");
      }
    } catch (e) {
      onConnectionChanged?.call(false);
      print("SignalR Lỗi kết nối: $e");
    }
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    if (isConnected) {
      try {
        final String fullName = await Utils.getName();
        await _hubConnection!.invoke("SendMessage", args: [fullName, content]);
      } catch (e) {
        print("SignalR Lỗi gửi tin nhắn: $e");
      }
    } else {
      print("SignalR: Không thể gửi tin nhắn vì chưa kết nối.");
    }
  }

  void dispose() {
    try {
      _hubConnection?.stop();
    } catch (_) {}
  }
}
