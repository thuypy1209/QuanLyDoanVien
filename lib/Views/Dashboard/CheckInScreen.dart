import 'package:flutter/material.dart';

class CheckInScreen extends StatelessWidget {
  const CheckInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Điểm danh QR"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue[800]),
            const SizedBox(height: 20),
            const Text(
              "Quét mã QR để điểm danh",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Sau này sẽ gắn thư viện QR Code Scanner vào đây
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Chức năng đang phát triển")),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text("BẮT ĐẦU QUÉT"),
            ),
          ],
        ),
      ),
    );
  }
}