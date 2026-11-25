import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quanlidoanvien/Components/AppBarComponent.dart';
import 'package:quanlidoanvien/Components/ButtonComponent.dart';

import 'package:quanlidoanvien/Services/CheckInService.dart';
import 'package:quanlidoanvien/Views/Screen/CheckInHistoryScreen.dart';
import 'dart:convert';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final MobileScannerController _controller = MobileScannerController();
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      if (mounted) {
        final code = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScanView()),
        );
        if (code != null && code is String && mounted) {
          _handleScanResult(code);
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) _showSettingsDialog();
    }
  }
  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? barcodes = await _controller.analyzeImage(image.path);

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        final String code = barcodes.barcodes.first.rawValue ?? "";
        if (code.isNotEmpty && mounted) {
          _handleScanResult(code);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không tìm thấy mã QR trong ảnh này!")),
          );
        }
      }
    }
  }

  void _handleScanResult(String code) async {
    String activityId = "";

    try {
      // 1. Giải mã JSON từ chuỗi QR nhận được
      final Map<String, dynamic> data = jsonDecode(code);

      if (data['type'] == 'CHECKIN_ACTIVITY') {
        activityId = data['id'].toString(); // Lấy ID hoạt động
      } else {
        _showSimpleDialog("Lỗi", "Mã QR không hợp lệ cho hệ thống điểm danh.");
        return;
      }
    } catch (e) {
      activityId = code;
    }
    // 2. Hiện Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Gọi Service
    final service = CheckInService();
    final response = await service.submitCheckIn(code);

    // 3. Tắt Loading
    if (mounted) Navigator.pop(context);

    // 4. Hiện kết quả
    if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              Icon(
                response.isSuccess ? Icons.check_circle : Icons.error,
                color: response.isSuccess ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 10),
              Text(response.isSuccess ? "Thành công" : "Thất bại"),
            ],
          ),
          content: Text(
            response.message ?? "Có lỗi xảy ra",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);

                if (response.isSuccess) {
                  _navigateToHistory();
                }
              },
              child: const Text("Đóng"),
            )
          ],
        ),
      );
    }
  }
  void _showSimpleDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng"))],
      ),
    );
  }
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckInHistoryScreen()),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cần quyền Camera"),
        content: const Text("Vui lòng vào Cài đặt để cấp quyền."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text("Mở Cài đặt"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: "Điểm danh QR",
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
            tooltip: "Lịch sử",
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 100, color: Colors.blue[800]),
              const SizedBox(height: 30),
              const Text(
                "Chọn phương thức điểm danh",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),

              ButtonComponent(
                icon: Icons.camera_alt,
                text: "QUÉT CAMERA",
                color: const Color(0xFF0D47A1),
                width: 300,
                height: 55,
                onPressed: _requestCameraPermission,
              ),

              const SizedBox(height: 15),

              ButtonComponent(
                icon: Icons.image,
                text: "CHỌN TỪ THƯ VIỆN",
                color: Colors.orange[800]!,
                width: 300,
                height: 55,
                onPressed: _scanFromGallery,
              ),

              const SizedBox(height: 15),

              ButtonComponent(
                icon: Icons.history,
                text: "XEM LỊCH SỬ CHECK-IN",
                color: Colors.grey[700]!,
                width: 300,
                height: 55,
                isOutlined: true,
                onPressed: _navigateToHistory,
              ),

              const SizedBox(height: 35),

              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: const Color(0xFF0D47A1), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Hướng camera thẳng vào mã QR sự kiện và giữ khoảng cách 20-30cm để điểm danh tự động.",
                        style: TextStyle(fontSize: 12, color: Colors.blue[900], height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QRScanView extends StatefulWidget {
  const QRScanView({super.key});

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  bool isScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đang quét..."), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: MobileScanner(
        onDetect: (capture) {
          if (!isScanned && capture.barcodes.isNotEmpty) {
            final String code = capture.barcodes.first.rawValue ?? "";

            if (code.isNotEmpty) {
              setState(() => isScanned = true);
              Navigator.pop(context, code);
            }
          }
        },
      ),
    );
  }
}
