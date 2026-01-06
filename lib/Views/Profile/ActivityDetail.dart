import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Models/ActivityModel.dart';
import 'package:quanlidoanvien/Services/ActivityService.dart';

class ActivityDetail extends StatefulWidget {
  final ActivityModel activity;
  const ActivityDetail({super.key, required this.activity});

  @override
  State<ActivityDetail> createState() => _ActivityDetailState();
}

class _ActivityDetailState extends State<ActivityDetail> {
  bool _isRegistering = false;
  bool _isRegistered = false;

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đăng ký thành công!"), backgroundColor: Colors.green),
      );
    } else {
      // Nếu thất bại => Hiện message lỗi từ ApiResponse
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${response.message ?? 'Đăng ký thất bại'}"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final act = widget.activity;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết hoạt động"),
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
                  Image.network(
                    act.imageUrl ?? "https://via.placeholder.com/800x400",
                    width: double.infinity,
                    height: 250,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(height: 250, color: Colors.grey[300]),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(act.tenHoatDong ?? "", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildInfoRow(Icons.calendar_today, "Thời gian: ${act.thoiGianBatDau}"),
                        _buildInfoRow(Icons.location_on, "Địa điểm: ${act.diaDiem}"),
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
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
                      title: const Text("Xác nhận"),
                      content: const Text("Bạn có chắc chắn muốn đăng ký?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _handleRegister(); // Gọi hàm xử lý
                          },
                          child: const Text("Đăng ký"),
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
                    ? const CircularProgressIndicator(color: Colors.white)
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
        children: [
          Icon(icon, color: Colors.blue[800], size: 22),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}