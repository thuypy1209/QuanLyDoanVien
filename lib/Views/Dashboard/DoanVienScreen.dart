import 'package:flutter/material.dart';
import '../../Services/StudentService.dart';
import '../../Models/StudentModel.dart';
import '../../Services/ActivityService.dart';
import '../../Models/ActivityModel.dart';
import '../../Utils.dart';

class DoanVienScreen extends StatefulWidget {
  const DoanVienScreen({super.key});

  @override
  State<DoanVienScreen> createState() => _DoanVienScreenState();
}

class _DoanVienScreenState extends State<DoanVienScreen> {
  StudentModel? _student;
  List<ActivityModel> _activities = [];
  bool _isLoading = true;
  final Color primaryColor = const Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // --- 1. CẬP NHẬT HÀM LẤY DỮ LIỆU (Có kiểm tra lịch sử) ---
  Future<void> _fetchData() async {
    final studentService = StudentService();
    final activityService = ActivityService();

    // A. LẤY THÔNG TIN TỪ BỘ NHỚ MÁY (Hiển thị ngay lập tức)
    // Dữ liệu này đã được lưu khi Đăng nhập thành công
    final localInfo = await Utils.getUserInfo();

    // Tạo một StudentModel tạm từ dữ liệu trong máy
    final localStudent = StudentModel(
      hoTen: localInfo['name'],
      mssv: localInfo['mssv'],
      lop: localInfo['lop'],
      diemRenLuyen: 0, // Tạm thời để 0, API sẽ cập nhật sau
    );

    // Cập nhật giao diện ngay để người dùng không thấy "---"
    if (mounted) {
      setState(() {
        _student = localStudent;
      });
    }

    try {
      // B. SAU ĐÓ GỌI API ĐỂ CẬP NHẬT MỚI NHẤT (Điểm rèn luyện, Hoạt động...)
      final results = await Future.wait([
        studentService.getStudentInfo(),
        activityService.getActivities(),
        activityService.getHistory()
      ]);

      if (mounted) {
        setState(() {
          // 1. Cập nhật lại Student nếu API trả về thành công (để lấy điểm rèn luyện mới nhất)
          final studentRes = results[0] as dynamic;
          if (studentRes.isSuccess && studentRes.data != null) {
            _student = studentRes.data;
          }

          // 2. Xử lý danh sách hoạt động
          final activityRes = results[1] as dynamic;
          final historyRes = results[2] as dynamic;

          if (activityRes.isSuccess) {
            List<ActivityModel> allActivities = activityRes.data ?? [];

            // So sánh lịch sử để đánh dấu "Đã đăng ký"
            if (historyRes.isSuccess && historyRes.data != null) {
              List<ActivityModel> historyList = historyRes.data!;
              // Lấy danh sách ID các hoạt động đã tham gia
              Set<int> registeredIds = historyList.map((e) => e.id ?? -1).toSet();

              for (var act in allActivities) {
                if (registeredIds.contains(act.id)) {
                  act.isRegistered = true;
                }
              }
            }
            _activities = allActivities;
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi fetch data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 2. HÀM XỬ LÝ KHI BẤM VÀO HOẠT ĐỘNG ---
  void _onActivityTap(ActivityModel activity) {
    if (activity.isRegistered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn đã đăng ký tham gia hoạt động này rồi!")),
      );
      return;
    }

    // Hiện hộp thoại xác nhận
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận đăng ký"),
        content: Text("Bạn có muốn đăng ký tham gia:\n'${activity.tenHoatDong}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // Đóng dialog
              _processRegistration(activity); // Gọi API
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text("Đăng ký ngay", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- 3. HÀM GỌI API ĐĂNG KÝ ---
  Future<void> _processRegistration(ActivityModel activity) async {
    // Hiện loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    final service = ActivityService();
    // Gọi Service đăng ký (ID không được null)
    final response = await service.registerActivity(activity.id!);

    // Tắt loading
    if (mounted) Navigator.of(context).pop();

    if (response.isSuccess) {
      // Cập nhật giao diện: Đổi trạng thái thành Đã ĐK ngay lập tức
      setState(() {
        activity.isRegistered = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Đăng ký thành công!"), backgroundColor: Colors.green),
      );
    } else {
      // Hiện lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ ${response.message}"), backgroundColor: Colors.red),
      );
    }
  }

  // Hàm xếp loại (Giữ nguyên)
  String getXepLoai(int diem) {
    if (diem >= 90) return "Xuất Sắc";
    if (diem >= 80) return "Tốt";
    if (diem >= 65) return "Khá";
    if (diem >= 50) return "Trung Bình";
    return "Yếu";
  }

  Color getMauXepLoai(int diem) {
    if (diem >= 80) return Colors.green;
    if (diem >= 65) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildQuickMenu(),
            const SizedBox(height: 20),
            _buildRecentActivities(),
          ],
        ),
      ),
    );
  }

  // ... (Hàm _buildHeader giữ nguyên) ...
  Widget _buildHeader() {
    String tenHienThi = _student?.hoTen ?? "Sinh viên";
    String mssvHienThi = _student?.mssv ?? "---";
    String lopHienThi = _student?.lop ?? "---";
    int diemHienThi = _student?.diemRenLuyen ?? 0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, const Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: primaryColor),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Xin chào,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    Text(
                      tenHienThi,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "$mssvHienThi | $lopHienThi",
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {},
              )
            ],
          ),
        ),

        // Khối điểm rèn luyện
        Positioned(
          bottom: -40,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Điểm rèn luyện", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(
                      "$diemHienThi",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                Container(height: 50, width: 1, color: Colors.grey[300]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Xếp loại", style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getMauXepLoai(diemHienThi).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        getXepLoai(diemHienThi),
                        style: TextStyle(
                          color: getMauXepLoai(diemHienThi),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ... (Hàm _buildQuickMenu giữ nguyên) ...
  Widget _buildQuickMenu() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tiện ích", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMenuItem(Icons.app_registration, "Đăng ký\nHoạt động", Colors.blue),
              _buildMenuItem(Icons.history, "Lịch sử\nTham gia", Colors.orange),
              _buildMenuItem(Icons.qr_code_scanner, "Quét mã\nĐiểm danh", Colors.purple),
              _buildMenuItem(Icons.school, "Kết quả\nHọc tập", Colors.green),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  // --- 4. SỬA DANH SÁCH ĐỂ BẮT SỰ KIỆN TAP ---
  Widget _buildRecentActivities() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Hoạt động sắp tới", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: const Text("Xem tất cả"))
            ],
          ),

          const SizedBox(height: 10),

          if (_activities.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Hiện chưa có hoạt động nào.", style: TextStyle(color: Colors.grey)),
              ),
            )
          else
          // Bọc item trong GestureDetector để bắt sự kiện Tap
            ..._activities.map((act) => GestureDetector(
              onTap: () => _onActivityTap(act), // Gọi hàm xử lý khi bấm
              child: _buildActivityItem(
                act.tenHoatDong ?? "Hoạt động không tên",
                act.thoiGianBatDau ?? "2025-01-01",
                act.diaDiem ?? "Chưa cập nhật",
                act.isRegistered,
              ),
            )).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ... (Hàm _buildActivityItem giữ nguyên logic UI) ...
  Widget _buildActivityItem(String title, String dateRaw, String location, bool isRegistered) {
    String day = "01";
    String month = "01";

    if (dateRaw.length >= 10) {
      day = dateRaw.substring(8, 10);
      month = dateRaw.substring(5, 7);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Column(
              children: [
                Text(day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text("Th$month", style: const TextStyle(fontSize: 12, color: Colors.blue)),
              ],
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          if (isRegistered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text("Đã ĐK", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}