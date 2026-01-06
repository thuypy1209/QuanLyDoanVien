import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Services/ActivityService.dart'; // 👉 Dùng Service này
import '../../Models/ActivityModel.dart';     // 👉 Dùng Model này
import 'package:quanlidoanvien/Repository/ApiResponse.dart';

class CheckInHistoryScreen extends StatefulWidget {
  const CheckInHistoryScreen({super.key});

  @override
  State<CheckInHistoryScreen> createState() => _CheckInHistoryScreenState();
}

class _CheckInHistoryScreenState extends State<CheckInHistoryScreen> {
  // Biến hứng dữ liệu từ API (Dùng ApiResponse để kiểm soát lỗi tốt hơn)
  late Future<ApiResponse<List<ActivityModel>>> _futureHistory;

  @override
  void initState() {
    super.initState();
    // 👉 GỌI API LỊCH SỬ ĐĂNG KÝ (Trả về cả Đã ĐK và Đã Tham Gia)
    _futureHistory = ActivityService().getHistory();
  }

  // Hàm format ngày giờ
  String _formatDate(String? rawDate) {
    if (rawDate == null) return "---";
    try {
      // API của bạn trả về: 2025-10-05T13:30:00
      return DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.parse(rawDate));
    } catch (_) { return rawDate; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hoạt động đã đăng ký"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<ApiResponse<List<ActivityModel>>>(
        future: _futureHistory,
        builder: (context, snapshot) {
          // 1. Đang tải
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Có lỗi kết nối
          if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          }

          final response = snapshot.data;

          // 3. API báo lỗi hoặc không thành công
          if (response == null || !response.isSuccess) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(response?.message ?? "Lỗi tải dữ liệu"),
                  TextButton(
                    onPressed: () => setState(() {
                      _futureHistory = ActivityService().getHistory();
                    }),
                    child: const Text("Thử lại"),
                  )
                ],
              ),
            );
          }

          // 4. Danh sách rỗng
          final history = response.data;
          if (history == null || history.isEmpty) {
            return const Center(
              child: Text("Bạn chưa đăng ký hoạt động nào.",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          // 5. CÓ DỮ LIỆU -> Hiển thị
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureHistory = ActivityService().getHistory();
              });
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (ctx, index) => const Divider(),
              itemBuilder: (ctx, index) {
                final item = history[index];

                // 👉 LOGIC KIỂM TRA TRẠNG THÁI TỪ API
                // Server trả về: "DaDangKy" hoặc "DaThamGia"
                bool isCheckedIn = item.trangThai == "DaThamGia";

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    // Nếu đã tham gia -> Màu xanh. Mới đăng ký -> Màu cam/xám
                    backgroundColor: isCheckedIn ? Colors.green[50] : Colors.blue[50],
                    child: Icon(
                      isCheckedIn ? Icons.check_circle : Icons.event_available,
                      color: isCheckedIn ? Colors.green : Colors.blue,
                    ),
                  ),
                  title: Text(
                    item.tenHoatDong ?? "Hoạt động không tên",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Thời gian: ${_formatDate(item.thoiGianBatDau)}"),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Hiển thị trạng thái chữ
                      Text(
                        isCheckedIn ? "Đã tham gia" : "Đã đăng ký",
                        style: TextStyle(
                            color: isCheckedIn ? Colors.green : Colors.blue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                        ),
                      ),
                      // Nếu đã tham gia thì hiện điểm cộng
                      if(isCheckedIn && (item.diemCong ?? 0) > 0)
                        Text("+${item.diemCong} điểm",
                            style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold)
                        ),
                      // Nếu chưa tham gia thì hiện nhắc nhở
                      if(!isCheckedIn)
                        const Text("Chưa check-in",
                            style: TextStyle(fontSize: 10, color: Colors.grey)
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}