import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Components/AppBarComponent.dart';
import '../../Components/StatCard.dart';
import '../../Components/EmptyStateWidget.dart';
import '../../Models/SoDoanModel.dart';
import '../../Services/PortalService.dart';

class SoDoanScreen extends StatefulWidget {
  const SoDoanScreen({Key? key}) : super(key: key);

  @override
  State<SoDoanScreen> createState() => _SoDoanScreenState();
}

class _SoDoanScreenState extends State<SoDoanScreen> {
  final PortalService _service = PortalService();
  bool _isLoading = true;
  String? _errorMessage;
  StudentSoDoanResponse? _data;

  @override
  void initState() {
    super.initState();
    _fetchSoDoan();
  }

  Future<void> _fetchSoDoan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _service.getMySoDoan();
    if (res.isSuccess && res.data != null) {
      setState(() {
        _data = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = res.message ?? 'Không thể tải thông tin sổ đoàn';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppBarComponent(
        title: 'Sổ Đoàn & Hồ Sơ',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF9333EA)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: EmptyStateWidget(
          message: 'Đã xảy ra lỗi',
          subMessage: _errorMessage!,
          actionText: 'Thử lại',
          onAction: _fetchSoDoan,
        ),
      );
    }

    final data = _data;
    if (data == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    final sv = data.sinhVien;
    final sd = data.soDoan;
    final isDaNop = data.daNopSo;

    String ngayNopFormatted = 'Chưa ghi nhận';
    if (sd?.ngayNop != null) {
      try {
        final dt = DateTime.parse(sd!.ngayNop!);
        ngayNopFormatted = DateFormat('dd/MM/yyyy').format(dt);
      } catch (_) {}
    }

    return RefreshIndicator(
      onRefresh: _fetchSoDoan,
      color: const Color(0xFF9333EA),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7E22CE), Color(0xFF6B21A8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x307E22CE),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.folder_shared_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Hồ Sơ Sổ Đoàn Điện Tử',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tra cứu tình trạng tiếp nhận, ngăn lưu trữ và giấy sinh hoạt hè',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3 StatCards
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Trạng thái',
                    value: isDaNop
                        ? 'Đã nộp'
                        : (sd?.trangThaiSoDoan == 'DaRut' ? 'Đã rút' : 'Chưa nộp'),
                    subValue: isDaNop ? 'Lưu tại trường' : 'Cần bổ sung',
                    icon: isDaNop ? Icons.check_circle_rounded : Icons.pending_actions_rounded,
                    iconColor: isDaNop ? const Color(0xFF059669) : const Color(0xFFE11D48),
                    iconBgColor: isDaNop ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                    badgeText: isDaNop ? 'Hợp lệ' : 'Chưa nộp',
                    badgeColor: isDaNop ? const Color(0xFF059669) : const Color(0xFFE11D48),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Giấy hè',
                    value: (sd?.giayGioiThieuHe == true) ? 'Đã cấp' : 'Chưa cấp',
                    subValue: 'Sinh hoạt hè',
                    icon: Icons.wb_sunny_rounded,
                    iconColor: const Color(0xFFD97706),
                    iconBgColor: const Color(0xFFFEF3C7),
                    badgeText: (sd?.giayGioiThieuHe == true) ? 'Hoàn tất' : 'Chưa',
                    badgeColor: const Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Storage Location Card
            StatCard(
              title: 'Vị trí lưu trữ hồ sơ',
              value: sd?.viTriLuuTru ?? 'Chưa phân bổ ngăn tủ',
              subValue: 'Văn phòng Đoàn TNCS Hồ Chí Minh trường',
              icon: Icons.location_on_rounded,
              iconColor: const Color(0xFF7E22CE),
              iconBgColor: const Color(0xFFF3E8FF),
              badgeText: 'Kho lưu trữ',
              badgeColor: const Color(0xFF7E22CE),
            ),
            const SizedBox(height: 20),

            // Detailed Paper Record
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Thông tin hồ sơ bản giấy',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sv.soDoanVien ?? 'DV-${sv.mssv}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'monospace',
                            color: Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildDetailRow('Họ và tên:', sv.hoTen, isBold: true),
                  _buildDetailRow('Mã số sinh viên:', sv.mssv, isMono: true),
                  _buildDetailRow('Chi đoàn / Lớp:', sv.lop ?? '---'),
                  _buildDetailRow('Khoa / Viện:', sv.khoa ?? '---'),
                  _buildDetailRow('Chức vụ Đoàn:', sv.chucVuDoan ?? 'Đoàn viên'),
                  _buildDetailRow('Ngày tiếp nhận sổ:', ngayNopFormatted),
                  _buildDetailRow(
                    'Tình trạng sổ:',
                    isDaNop ? 'Đang lưu giữ tại Văn phòng Đoàn' : 'Chưa nộp sổ đoàn',
                    highlightColor: isDaNop ? const Color(0xFF059669) : const Color(0xFFE11D48),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Instructions Callout
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Lưu ý: Sinh viên cần nộp Sổ đoàn và Nghị quyết kết nạp bản gốc về Văn phòng Đoàn trường vào đầu khóa học. Khi chuyển trường hoặc tốt nghiệp, liên hệ Văn phòng Đoàn để thực hiện thủ tục rút sổ.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E40AF),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, bool isMono = false, Color? highlightColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                fontFamily: isMono ? 'monospace' : null,
                color: highlightColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
