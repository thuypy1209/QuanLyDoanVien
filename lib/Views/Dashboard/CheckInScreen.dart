import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

import '../../Services/CheckInService.dart';
import '../Screen/CheckInHistoryScreen.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final MobileScannerController _controller = MobileScannerController();

  // --- 1. XỬ LÝ QUYỀN VÀ MỞ CAMERA (Đã sửa để hứng kết quả) ---
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      if (mounted) {
        // 👉 SỬA: Dùng 'await' để đợi kết quả trả về từ màn hình quét
        final code = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScanView()),
        );

        // 👉 SỬA: Nếu có code trả về thì gọi API ngay
        if (code != null && code is String && mounted) {
          _handleScanResult(code);
        }
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) _showSettingsDialog();
    }
  }

  // --- 2. CHỌN ẢNH TỪ THƯ VIỆN (Đã sửa để gọi API) ---
  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? barcodes = await _controller.analyzeImage(image.path);

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        final String code = barcodes.barcodes.first.rawValue ?? "";

        // 👉 SỬA: Gọi hàm xử lý API thay vì hiện Dialog
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

  // --- 3. HÀM GỌI API CHECK-IN (Quan trọng nhất) ---
  void _handleScanResult(String code) async {
    // 1. Hiện Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Gọi Service
    final service = CheckInService();
    // Lưu ý: Code gửi lên Server sẽ là ID hoạt động (nếu bạn đã sửa Backend theo hướng dẫn trước)
    // Hoặc ID đăng ký (nếu dùng Backend cũ)
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
                // Nếu thành công -> Chuyển sang xem lịch sử luôn cho ngầu
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
      appBar: AppBar(
        title: const Text("Điểm danh QR"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
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

              _buildCustomButton(
                icon: Icons.camera_alt,
                label: "QUÉT CAMERA",
                color: const Color(0xFF0D47A1),
                isOutlined: false,
                onTap: _requestCameraPermission,
              ),

              const SizedBox(height: 15),

              _buildCustomButton(
                icon: Icons.image,
                label: "CHỌN TỪ THƯ VIỆN",
                color: Colors.orange[800]!,
                isOutlined: false,
                onTap: _scanFromGallery,
              ),

              const SizedBox(height: 15),

              _buildCustomButton(
                icon: Icons.history,
                label: "XEM LỊCH SỬ CHECK-IN",
                color: Colors.grey[700]!,
                isOutlined: true,
                onTap: _navigateToHistory,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isOutlined,
    required VoidCallback onTap,
  }) {
    final style = ElevatedButton.styleFrom(
      backgroundColor: isOutlined ? Colors.white : color,
      foregroundColor: isOutlined ? color : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      fixedSize: const Size(300, 55),
      side: isOutlined ? BorderSide(color: color) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );

    return ElevatedButton.icon(
      onPressed: onTap,
      style: style,
      icon: Icon(icon),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }
}

// --- MÀN HÌNH QUÉT CAMERA (Đã sửa logic trả về) ---
class QRScanView extends StatefulWidget {
  const QRScanView({super.key});

  @override
  State<QRScanView> createState() => _QRScanViewState();
}

class _QRScanViewState extends State<QRScanView> {
  bool isScanned = false; // Cờ để tránh quét liên tục nhiều lần

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Đang quét..."), backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: MobileScanner(
        onDetect: (capture) {
          // Chỉ xử lý nếu chưa quét lần nào
          if (!isScanned && capture.barcodes.isNotEmpty) {
            final String code = capture.barcodes.first.rawValue ?? "";

            if (code.isNotEmpty) {
              setState(() => isScanned = true); // Khóa lại ngay

              // 👉 SỬA: Đóng màn hình này và trả Code về màn hình trước
              Navigator.pop(context, code);
            }
          }
        },
      ),
    );
  }
}
