import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart'; // Import thư viện chọn ảnh

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  // Controller để phân tích ảnh tĩnh
  final MobileScannerController _controller = MobileScannerController();

  // --- 1. HÀM XỬ LÝ QUYỀN CAMERA (Giữ nguyên) ---
  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScanView()),
        );
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) _showSettingsDialog();
    }
  }

  // --- 2. HÀM CHỌN ẢNH TỪ THƯ VIỆN ---
  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    // Mở thư viện ảnh
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      // Phân tích mã QR trong ảnh
      final BarcodeCapture? barcodes = await _controller.analyzeImage(image.path);

      if (barcodes != null && barcodes.barcodes.isNotEmpty) {
        final String code = barcodes.barcodes.first.rawValue ?? "Không đọc được";
        if (mounted) {
          _showResultDialog(code);
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

  // --- 3. HÀM CHUYỂN ĐẾN LỊCH SỬ ---
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckInHistoryScreen()),
    );
  }

  // Hộp thoại kết quả chung
  void _showResultDialog(String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Quét thành công"),
        content: Text("Mã: $code"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          )
        ],
      ),
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
          // Nút tắt lịch sử trên AppBar cho tiện
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

              // --- NÚT 1: QUÉT CAMERA ---
              _buildCustomButton(
                icon: Icons.camera_alt,
                label: "QUÉT CAMERA",
                color: const Color(0xFF0D47A1),
                isOutlined: false,
                onTap: _requestCameraPermission,
              ),

              const SizedBox(height: 15),

              // --- NÚT 2: TỪ THƯ VIỆN ---
              _buildCustomButton(
                icon: Icons.image,
                label: "CHỌN TỪ THƯ VIỆN",
                color: Colors.orange[800]!,
                isOutlined: false,
                onTap: _scanFromGallery,
              ),

              const SizedBox(height: 15),

              // --- NÚT 3: LỊCH SỬ ---
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

  // Widget Button tùy chỉnh cho đẹp
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
      fixedSize: const Size(300, 55), // Cố định chiều rộng
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

// --- MÀN HÌNH QUÉT CAMERA (Giữ nguyên logic cũ) ---
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
            final String code = capture.barcodes.first.rawValue ?? "---";
            setState(() => isScanned = true);
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text("Thành công"),
                content: Text("Mã: $code"),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text("OK")
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

// --- MÀN HÌNH LỊCH SỬ CHECK-IN (Mới) ---
class CheckInHistoryScreen extends StatelessWidget {
  const CheckInHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả lập (Sau này thay bằng API)
    final List<Map<String, String>> history = [
      {"title": "Họp chi đoàn tháng 10", "time": "20/10/2025 08:30", "status": "Thành công"},
      {"title": "Lao động công ích", "time": "15/10/2025 07:00", "status": "Thành công"},
      {"title": "Hội thao sinh viên", "time": "10/10/2025 14:00", "status": "Thất bại"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử Check-in"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        itemCount: history.length,
        separatorBuilder: (ctx, index) => const Divider(),
        itemBuilder: (ctx, index) {
          final item = history[index];
          final isSuccess = item['status'] == "Thành công";

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isSuccess ? Colors.green[100] : Colors.red[100],
              child: Icon(
                isSuccess ? Icons.check : Icons.close,
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
            title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item['time']!),
            trailing: Text(
              item['status']!,
              style: TextStyle(
                  color: isSuccess ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold
              ),
            ),
          );
        },
      ),
    );
  }
}