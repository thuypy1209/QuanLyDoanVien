import 'dart:io';
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
    final serverUrl = "${Utils.baseUrl}/chathub"; //
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    _hubConnection = HubConnectionBuilder()
        .withUrl(
      serverUrl,
      HttpConnectionOptions(
        accessTokenFactory: () async => token ?? "", //
        client: IOClient(httpClient),
        logging: (level, message) => print("SignalR: $message"),
      ),
    )
        .withAutomaticReconnect()
        .build();
    _hubConnection!.on("ReceiveMessage", (List<dynamic>? arguments) {
      if (arguments != null && arguments.isNotEmpty && onMessageReceived != null) {
        onMessageReceived!(arguments[0] as Map<String, dynamic>);
      }
    });

    _hubConnection!.onclose((error) => onConnectionChanged?.call(false));
    _hubConnection!.onreconnecting((error) => onConnectionChanged?.call(false));
    _hubConnection!.onreconnected((connectionId) => onConnectionChanged?.call(true));

    try {

      if (_hubConnection!.state == HubConnectionState.disconnected) {
        await _hubConnection!.start();
        onConnectionChanged?.call(true);
        print("Đã kết nối bằng signalr_core");
      }
    } catch (e) {
      onConnectionChanged?.call(false);
      print("Lỗi: $e");
    }
  }
  Future<void> sendMessage(String content) async {
    if (isConnected) {

      await _hubConnection!.invoke("SendMessage", args: [content]);
    }
  }
  void dispose() {
    _hubConnection?.stop();
  }
}