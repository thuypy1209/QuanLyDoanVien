import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Models/ActivityModel.dart';
import 'package:quanlidoanvien/Services/ActivityService.dart';
import 'package:quanlidoanvien/Utils.dart';

class ActivityDetail extends StatefulWidget {
  final ActivityModel activity;
  const ActivityDetail({super.key, required this.activity});

  @override
  State<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  bool _isRegistering = false;
  late bool _isRegistered; // Dùng late cho chắc

  @override
  void initState() {
    super.initState();
    _isRegistered = widget.activity.isRegistered;
  }

  void _handleRegister() async {
    setState(() => _isRegistering = true);

    // Gọi Service (Trả về ApiResponse<bool>)
    final response = await ActivityService().registerActivity(widget.activity.id!);

    setState(() => _isRegistering = false);

    // Kiểm tra kết quả (Dựa vào ApiResponse)
    if (response.data == true) {
      // Nếu data trả về true => Thành công
      setState(() => _isRegistered = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Đăng ký thành công!"), backgroundColor: Colors.green),
        );
      }
    } else {
      // Nếu thất bại => Hiện message lỗi từ ApiResponse
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Đăng ký thất bại'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final act = widget.activity;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết hoạt động", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 👇 2. SỬA LẠI KHÚC LOAD ẢNH Ở ĐÂY NÈ
                  Image.network(
                    (act.imageUrl != null && act.imageUrl!.isNotEmpty)
                        ? "${Utils.baseUrl}${act.imageUrl}" // Nối baseUrl vào
                        : "https://via.placeholder.com/800x400?text=No+Image", // Link ảnh mặc định nếu DB không có
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    // Nếu lỗi (ví dụ sai cổng, tắt server) thì hiện cục xám
                    errorBuilder: (_, __, ___) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(act.tenHoatDong ?? "", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildInfoRow(Icons.calendar_today, "Thời gian: ${act.thoiGianBatDau ?? 'Chưa cập nhật'}"),
                        _buildInfoRow(Icons.location_on, "Địa điểm: ${act.diaDiem ?? 'Chưa cập nhật'}"),
                        _buildInfoRow(Icons.star, "Điểm cộng: ${act.diemCong ?? 0} điểm"),
                        const Divider(height: 30),
                        const Text("Mô tả chi tiết:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Text(
                          act.moTa ?? "Không có mô tả chi tiết.",
                          style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Nút Đăng ký giữ nguyên, viết rất chuẩn rồi
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: (_isRegistered || _isRegistering)
                    ? null
                    : () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Xác nhận", style: TextStyle(fontWeight: FontWeight.bold)),
                      content: const Text("Bạn có chắc chắn muốn đăng ký tham gia hoạt động này không?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleRegister(); // Gọi hàm xử lý
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                          child: const Text("Đăng ký", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRegistered ? Colors.green : const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isRegistering
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : Text(
                  _isRegistered ? "ĐÃ ĐĂNG KÝ" : "ĐĂNG KÝ THAM GIA",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[800], size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}