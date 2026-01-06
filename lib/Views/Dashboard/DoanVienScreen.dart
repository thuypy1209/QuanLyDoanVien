import 'package:flutter/material.dart';
import 'package:quanlidoanvien/Services/StudentService.dart';
import 'package:quanlidoanvien/Models/StudentModel.dart';
import 'package:quanlidoanvien/Services/ActivityService.dart';
import 'package:quanlidoanvien/Models/ActivityModel.dart';
import 'package:quanlidoanvien/Utils.dart';
import 'CheckInScreen.dart';
import 'package:quanlidoanvien/Views/Screen/CheckInHistoryScreen.dart';
import 'package:quanlidoanvien/Views/Profile/ActivityDetail.dart';
import 'package:quanlidoanvien/Views/Screen/AllActivitiesScreen.dart';

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

  Widget _buildQuickMenu() {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Tiện ích", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            // 👇 SỬA Ở ĐÂY: Đổi từ spaceBetween thành spaceEvenly
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMenuItem(Icons.app_registration, "Đăng ký\nHoạt động", Colors.blue, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AllActivitiesScreen()));
              }),

              // Nếu dùng MainAxisAlignment.center thì bạn có thể thêm SizedBox(width: 20) ở đây để tạo khoảng cách

              _buildMenuItem(Icons.history, "Lịch sử\nTham gia", Colors.orange, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInHistoryScreen()));
              }),

              _buildMenuItem(Icons.qr_code_scanner, "Quét mã\nĐiểm danh", Colors.purple, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckInScreen()));
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
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15)
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
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
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text("Hiện chưa có hoạt động nào.", style: TextStyle(color: Colors.grey)),
              ),
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
              ),
            )).toList(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

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