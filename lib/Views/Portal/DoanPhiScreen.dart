import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Components/AppBarComponent.dart';
import '../../Components/StatCard.dart';
import '../../Components/EmptyStateWidget.dart';
import '../../Components/ButtonComponent.dart';
import '../../Models/DoanPhiModel.dart';
import '../../Services/PortalService.dart';

class DoanPhiScreen extends StatefulWidget {
  const DoanPhiScreen({Key? key}) : super(key: key);

  @override
  State<DoanPhiScreen> createState() => _DoanPhiScreenState();
}

class _DoanPhiScreenState extends State<DoanPhiScreen> {
  final PortalService _service = PortalService();
  bool _isLoading = true;
  String? _errorMessage;
  StudentDoanPhiResponse? _data;

  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _fetchDoanPhi();
  }

  Future<void> _fetchDoanPhi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _service.getMyDoanPhi();
    if (res.isSuccess && res.data != null) {
      setState(() {
        _data = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = res.message ?? 'Không thể tải thông tin đoàn phí';
        _isLoading = false;
      });
    }
  }

  void _showPaymentInstructions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Hướng Dẫn Nộp Đoàn Phí',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tài khoản Ban Chấp Hành Đoàn Trường',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoLine('Ngân hàng:', 'Vietcombank (VCB)'),
                    _buildInfoLine('Số tài khoản:', '0123 4567 8999', isMono: true),
                    _buildInfoLine('Chủ tài khoản:', 'DOAN TNCS HCM TRUONG DH HUTECH'),
                    _buildInfoLine('Mức thu quy định:', '25.000 đ / học kỳ'),
                    const SizedBox(height: 8),
                    const Divider(color: Color(0xFFA7F3D0)),
                    const SizedBox(height: 4),
                    const Text(
                      'Cú pháp chuyển khoản:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF065F46)),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        'DOANPHI_${_data?.sinhVien.mssv ?? "MSSV"}_HK2',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: Color(0xFF047857),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '• Đoàn viên cũng có thể nộp tiền mặt trực tiếp cho Bí thư Chi đoàn lớp để tổng hợp nộp về Đoàn Khoa.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              ButtonComponent(
                text: 'Đã hiểu',
                color: const Color(0xFF059669),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoLine(String label, String val, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
          Text(
            val,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              fontFamily: isMono ? 'monospace' : null,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppBarComponent(
        title: 'Đoàn Phí Của Tôi',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF059669)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: EmptyStateWidget(
          message: 'Đã xảy ra lỗi',
          subMessage: _errorMessage!,
          actionText: 'Thử lại',
          onAction: _fetchDoanPhi,
        ),
      );
    }

    final data = _data;
    if (data == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    final summary = data.summary;
    final records = data.records;

    return RefreshIndicator(
      onRefresh: _fetchDoanPhi,
      color: const Color(0xFF059669),
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
                  colors: [Color(0xFF059669), Color(0xFF0D9488)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x30059669),
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
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Nghĩa Vụ Đoàn Phí',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Theo dõi thu nộp đoàn phí định kỳ theo Điều lệ Đoàn TNCS Hồ Chí Minh',
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

            // Summary Stats
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Tình trạng',
                    value: summary.daHoanTatTatCa ? 'Hoàn tất' : 'Còn nợ',
                    subValue: summary.daHoanTatTatCa
                        ? 'Đã nộp đủ các kỳ'
                        : 'Còn ${summary.soKyChuaNop} kỳ chưa nộp',
                    icon: summary.daHoanTatTatCa
                        ? Icons.check_circle_rounded
                        : Icons.timelapse_rounded,
                    iconColor: summary.daHoanTatTatCa
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                    iconBgColor: summary.daHoanTatTatCa
                        ? const Color(0xFFECFDF5)
                        : const Color(0xFFFEF3C7),
                    badgeText: summary.daHoanTatTatCa ? 'Đạt' : 'Chưa',
                    badgeColor: summary.daHoanTatTatCa
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Đã đóng',
                    value: currencyFormat.format(summary.tongDaNop),
                    subValue: '${summary.soKyDaNop} học kỳ',
                    icon: Icons.paid_rounded,
                    iconColor: const Color(0xFF2563EB),
                    iconBgColor: const Color(0xFFEFF6FF),
                    badgeText: '${summary.soKyDaNop} kỳ',
                    badgeColor: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (summary.tongChuaNop > 0)
              StatCard(
                title: 'Số tiền còn nợ',
                value: currencyFormat.format(summary.tongChuaNop),
                subValue: 'Cần hoàn tất trước đợt xét bình bầu thi đua',
                icon: Icons.error_outline_rounded,
                iconColor: const Color(0xFFE11D48),
                iconBgColor: const Color(0xFFFFF1F2),
                badgeText: 'Cần nộp',
                badgeColor: const Color(0xFFE11D48),
                onTap: _showPaymentInstructions,
              ),

            const SizedBox(height: 20),

            // Button to show payment instructions
            ButtonComponent(
              text: 'Hướng dẫn & Cú pháp nộp đoàn phí',
              icon: Icons.qr_code_rounded,
              color: const Color(0xFF059669),
              onPressed: _showPaymentInstructions,
            ),
            const SizedBox(height: 20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lịch Sử Các Kỳ Thu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${records.length} đợt thu',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (records.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'Chưa có kỳ thu đoàn phí nào được tạo.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final r = records[i];
                  final isDaNop = r.trangThai == 'DaNop';

                  String ngayNopStr = '';
                  if (r.ngayNop != null) {
                    try {
                      final dt = DateTime.parse(r.ngayNop!);
                      ngayNopStr = DateFormat('dd/MM/yyyy').format(dt);
                    } catch (_) {}
                  }

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDaNop ? const Color(0xFFE2E8F0) : const Color(0xFFFECDD3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDaNop ? const Color(0xFFECFDF5) : const Color(0xFFFFF1F2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isDaNop ? Icons.check_circle_rounded : Icons.pending_rounded,
                            color: isDaNop ? const Color(0xFF059669) : const Color(0xFFE11D48),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.hocKy,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDaNop
                                          ? const Color(0xFFECFDF5)
                                          : const Color(0xFFFFF1F2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isDaNop
                                            ? const Color(0xFFA7F3D0)
                                            : const Color(0xFFFECDD3),
                                      ),
                                    ),
                                    child: Text(
                                      isDaNop ? 'Đã nộp' : 'Chưa nộp',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isDaNop
                                            ? const Color(0xFF059669)
                                            : const Color(0xFFE11D48),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Năm học ${r.namHoc}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    currencyFormat.format(r.soTien),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (isDaNop && ngayNopStr.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '• Nộp ngày: $ngayNopStr',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
