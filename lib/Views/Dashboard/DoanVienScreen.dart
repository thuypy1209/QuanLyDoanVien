import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Components/StatusBadge.dart';
import 'package:quanlidoanvien/Components/EmptyStateWidget.dart';
import 'package:quanlidoanvien/Services/StudentService.dart';
import 'package:quanlidoanvien/Models/StudentModel.dart';
import 'package:quanlidoanvien/Services/ActivityService.dart';
import 'package:quanlidoanvien/Models/ActivityModel.dart';
import 'package:quanlidoanvien/Utils.dart';
import 'CheckInScreen.dart';
import 'package:quanlidoanvien/Views/Screen/CheckInHistoryScreen.dart';
import 'package:quanlidoanvien/Views/Profile/ActivityDetail.dart';
import 'package:quanlidoanvien/Views/Profile/StudentInfoScreen.dart';
import 'package:quanlidoanvien/Views/Screen/AllActivitiesScreen.dart';
import 'package:quanlidoanvien/Views/Portal/SoDoanScreen.dart';
import 'package:quanlidoanvien/Views/Portal/DoanPhiScreen.dart';
import 'package:quanlidoanvien/Views/Portal/XepLoaiScreen.dart';
import 'package:quanlidoanvien/Views/Portal/ChungNhanScreen.dart';

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

  Future<void> _fetchData() async {
    final studentService = StudentService();
    final activityService = ActivityService();


    final localInfo = await Utils.getUserInfo();

    final localStudent = StudentModel(
      hoTen: localInfo['name'],
      mssv: localInfo['mssv'],
      lop: localInfo['lop'],
      diemRenLuyen: 0,
    );

    if (mounted) {
      setState(() {
        _student = localStudent;
      });
    }

    try {
      final results = await Future.wait([
        studentService.getStudentInfo(),
        activityService.getActivities(),
        activityService.getHistory()
      ]);

      if (mounted) {
        setState(() {
          final studentRes = results[0] as dynamic;
          if (studentRes.isSuccess && studentRes.data != null) {
            _student = studentRes.data;
          }

          final activityRes = results[1] as dynamic;
          final historyRes = results[2] as dynamic;

          if (activityRes.isSuccess) {
            List<ActivityModel> allActivities = activityRes.data ?? [];


            if (historyRes.isSuccess && historyRes.data != null) {
              List<ActivityModel> historyList = historyRes.data!;


              Set<int> registeredIds = historyList.map((e) => e.hoatDongId ?? -1).toSet();

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

      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Hàm xếp loại
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
                backgroundImage: (_student?.avatarUrl != null && _student!.avatarUrl!.isNotEmpty)
                    ? NetworkImage("${Utils.baseUrl}${_student!.avatarUrl}")
                    : null,
                child: (_student?.avatarUrl == null || _student!.avatarUrl!.isEmpty)
                    ? Icon(Icons.person, size: 40, color: primaryColor)
                    : null,
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
                        color: Colors.white.withValues(alpha:0.2),
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
                  color: Colors.black.withValues(alpha:0.1),
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
                    StatusBadge.fromXepLoai(getXepLoai(diemHienThi)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickMenu() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tiện ích Cổng Đoàn Viên",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Hệ sinh thái Đoàn",
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Row 1
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMenuItem(Icons.event_available_rounded, "Đăng ký\nHoạt động", const Color(0xFF2563EB), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AllActivitiesScreen()));
              }),
              _buildMenuItem(Icons.folder_shared_rounded, "Sổ Đoàn\nĐiện tử", const Color(0xFF7E22CE), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SoDoanScreen()));
              }),
              _buildMenuItem(Icons.account_balance_wallet_rounded, "Nghĩa vụ\nĐoàn phí", const Color(0xFF059669), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DoanPhiScreen()));
              }),
              _buildMenuItem(Icons.workspace_premium_rounded, "Bình bầu\nXếp loại", const Color(0xFFD97706), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const XepLoaiScreen()));
              }),
            ],
          ),
          const SizedBox(height: 14),

          // Row 2
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMenuItem(Icons.verified_rounded, "Chứng nhận\nĐiện tử", const Color(0xFF0284C7), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChungNhanScreen()));
              }),
              _buildMenuItem(Icons.qr_code_scanner_rounded, "Quét mã\nĐiểm danh", const Color(0xFF4F46E5), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInScreen()));
              }),
              _buildMenuItem(Icons.history_rounded, "Lịch sử\nCheck-in", const Color(0xFFEA580C), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckInHistoryScreen()));
              }),
              _buildMenuItem(Icons.badge_rounded, "Hồ sơ\nĐoàn viên", const Color(0xFF0D47A1), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentInfoScreen()));
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
                height: 1.2,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // Danh sách hoạt động (Chuyển sang trang chi tiết khi bấm)
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
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AllActivitiesScreen()));
                  },
                  child: const Text("Xem tất cả")
              )
            ],
          ),

          const SizedBox(height: 10),

          if (_activities.isEmpty)
            EmptyStateWidget(
              message: "Chưa có hoạt động nào",
              subMessage: "Các hoạt động phong trào sắp tới sẽ hiển thị tại đây",
              icon: Icons.event_busy,
              actionText: "Làm mới",
              onAction: _fetchData,
            )
          else
            ..._activities.map((act) => GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityDetail(activity: act),
                  ),
                ).then((_) {
                  // Cập nhật lại dữ liệu khi quay về từ trang chi tiết
                  _fetchData();
                });
              },
              child: _buildActivityItem(
                act.tenHoatDong ?? "Hoạt động không tên",
                act.thoiGianBatDau ?? "--/--/----",
                act.diaDiem ?? "Chưa cập nhật",
                act.isRegistered,
                act.imageUrl,
              ),
            )).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
  Widget _buildFallbackDate(String day, String month) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha:0.1),
          borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
              day,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)
          ),
          Text(
              "Th$month",
              style: const TextStyle(fontSize: 12, color: Colors.blue)
          ),
        ],
      ),
    );
  }
  Widget _buildActivityItem(String title, String dateRaw, String location, bool isRegistered, String? imageUrl) {
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
        border: Border.all(color: Colors.grey.withValues(alpha:0.1)),
        boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha:0.05), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: (imageUrl != null && imageUrl.isNotEmpty)
                ? Image.network(
              "${Utils.baseUrl}$imageUrl",
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildFallbackDate(day, month), // Lỗi load ảnh thì hiện ngày
            )
                : _buildFallbackDate(day, month), // Không có ảnh thì hiện ngày
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          if (isRegistered)
            const StatusBadge(
              label: "Đã ĐK",
              color: Color(0xFF2E7D32),
              fontSize: 10,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            )
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );

  }
}