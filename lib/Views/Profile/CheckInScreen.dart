import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Đảm bảo đã thêm intl vào pubspec.yaml
import '../../Services/CheckInService.dart';
import '../../Models/CheckInHistoryModel.dart';

class CheckInHistoryScreen extends StatefulWidget {
  const CheckInHistoryScreen({super.key});

  @override
  State<CheckInHistoryScreen> createState() => _CheckInHistoryScreenState();
}

class _CheckInHistoryScreenState extends State<CheckInHistoryScreen> {
  // Biến hứng dữ liệu từ API
  late Future<List<CheckInHistoryModel>> _futureHistory;

  @override
  void initState() {
    super.initState();
    // GỌI API THẬT TẠI ĐÂY
    _futureHistory = CheckInService().getHistory();
  }

  // Hàm format ngày giờ
  String _formatDate(String? rawDate) {
    if (rawDate == null) return "---";
    try {
      return DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.parse(rawDate));
    } catch (_) { return rawDate; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lịch sử Check-in"),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<CheckInHistoryModel>>(
        future: _futureHistory, // Lắng nghe dữ liệu từ API
        builder: (context, snapshot) {
          // 1. Đang tải từ Server
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Có lỗi kết nối
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 50, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("Lỗi tải dữ liệu: ${snapshot.error}", textAlign: TextAlign.center),
                  TextButton(
                    onPressed: () => setState(() {
                      _futureHistory = CheckInService().getHistory();
                    }),
                    child: const Text("Thử lại"),
                  )
                ],
              ),
            );
          }

          // 3. Server trả về rỗng (Chưa check-in lần nào)
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Bạn chưa có lịch sử check-in nào trên Server.",
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
            );
          }

          // 4. CÓ DỮ LIỆU THẬT -> Hiển thị
          final history = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _futureHistory = CheckInService().getHistory();
              });
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: history.length,
              separatorBuilder: (ctx, index) => const Divider(),
              itemBuilder: (ctx, index) {
                final item = history[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: item.isSuccess ? Colors.green[50] : Colors.orange[50],
                    child: Icon(
                      item.isSuccess ? Icons.check_circle : Icons.hourglass_bottom,
                      color: item.isSuccess ? Colors.green : Colors.orange,
                    ),
                  ),
                  title: Text(
                    item.tenHoatDong ?? "Hoạt động không tên",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_formatDate(item.thoiGianCheckIn)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        item.isSuccess ? "Thành công" : "Chờ duyệt",
                        style: TextStyle(
                            color: item.isSuccess ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                        ),
                      ),
                      if(item.diemCong > 0)
                        Text("+${item.diemCong} điểm",
                            style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold)
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