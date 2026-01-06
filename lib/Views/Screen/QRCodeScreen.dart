import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Utils.dart';

class QRCodeScreen extends StatefulWidget {
  final int activityId;
  final String title;

  const QRCodeScreen({
    super.key,
    required this.activityId,
    required this.title,
  });

  @override
  State<QRCodeScreen> createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  void _loadToken() async {
    String? t = await Utils.getToken();
    setState(() {
      _token = t;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String qrUrl = 'http://10.0.2.2:5000/api/HoatDong/qr/${widget.activityId}';

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mã QR Điểm danh"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Quét mã để điểm danh",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            Text(
              widget.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D47A1),
              ),
            ),

            const SizedBox(height: 30),

            // Hiển thị khung chứa QR
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: _token == null
                  ? const CircularProgressIndicator() // Đợi lấy token
                  : Image.network(
                qrUrl,
                width: 280,
                height: 280,
                fit: BoxFit.cover,
                // 👉 QUAN TRỌNG: Gửi kèm Token nếu API yêu cầu
                headers: {
                  "Authorization": "Bearer $_token",
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    width: 280,
                    height: 280,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 280,
                    height: 280,
                    color: Colors.grey[200],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.broken_image, size: 50, color: Colors.red),
                        const SizedBox(height: 10),
                        Text("Lỗi tải QR: $error", textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
            const Text(
              "Vui lòng đưa mã này cho Sinh viên quét",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}