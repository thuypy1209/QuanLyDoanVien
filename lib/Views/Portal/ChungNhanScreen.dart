import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../Components/AppBarComponent.dart';
import '../../Components/StatCard.dart';
import '../../Components/EmptyStateWidget.dart';
import '../../Components/CertificateDialog.dart';
import '../../Models/ChungNhanModel.dart';
import '../../Services/PortalService.dart';

class ChungNhanScreen extends StatefulWidget {
  const ChungNhanScreen({Key? key}) : super(key: key);

  @override
  State<ChungNhanScreen> createState() => _ChungNhanScreenState();
}

class _ChungNhanScreenState extends State<ChungNhanScreen> {
  final PortalService _service = PortalService();
  bool _isLoading = true;
  String? _errorMessage;
  StudentChungNhanResponse? _data;

  @override
  void initState() {
    super.initState();
    _fetchChungNhan();
  }

  Future<void> _fetchChungNhan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _service.getMyChungNhan();
    if (res.isSuccess && res.data != null) {
      setState(() {
        _data = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = res.message ?? 'Không thể tải thư viện chứng nhận';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppBarComponent(
        title: 'Chứng Nhận Điện Tử',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF0284C7)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: EmptyStateWidget(
          message: 'Đã xảy ra lỗi',
          subMessage: _errorMessage!,
          actionText: 'Thử lại',
          onAction: _fetchChungNhan,
        ),
      );
    }

    final data = _data;
    if (data == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    final sv = data.sinhVien;
    final items = data.items;
    final int tongDiem = items.fold(0, (sum, item) => sum + item.diemCong);

    return RefreshIndicator(
      onRefresh: _fetchChungNhan,
      color: const Color(0xFF0284C7),
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
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x300284C7),
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
                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Chứng Nhận Điện Tử',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Lưu trữ hồ sơ chứng nhận tham gia hoạt động và tra cứu mã xác thực QR',
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
                    title: 'Giấy chứng nhận',
                    value: '${data.tongChungNhan}',
                    subValue: 'Đã cấp chính thức',
                    icon: Icons.article_rounded,
                    iconColor: const Color(0xFF0284C7),
                    iconBgColor: const Color(0xFFE0F2FE),
                    badgeText: 'Chính thức',
                    badgeColor: const Color(0xFF0284C7),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Điểm tích lũy',
                    value: '+$tongDiem đ',
                    subValue: 'Từ các hoạt động',
                    icon: Icons.stars_rounded,
                    iconColor: const Color(0xFF059669),
                    iconBgColor: const Color(0xFFECFDF5),
                    badgeText: 'ĐRL',
                    badgeColor: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            StatCard(
              title: 'Giá trị pháp lý & Minh chứng',
              value: 'Xác thực mã QR toàn quốc',
              subValue: 'Dùng xét Danh hiệu Sinh viên 5 Tốt và Học bổng khuyến khích',
              icon: Icons.shield_rounded,
              iconColor: const Color(0xFF7C3AED),
              iconBgColor: const Color(0xFFF5F3FF),
              badgeText: 'Hợp lệ',
              badgeColor: const Color(0xFF7C3AED),
            ),
            const SizedBox(height: 20),

            // Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Danh Sách Chứng Nhận',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  '${items.length} chứng nhận',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (items.isEmpty)
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.workspace_premium_outlined, size: 48, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 12),
                      Text(
                        'Bạn chưa có Giấy chứng nhận nào',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hãy tham gia các phong trào tình nguyện, hội thảo và thực hiện Check-in QR để nhận chứng nhận.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (ctx, i) {
                  final cert = items[i];

                  String ngayCapStr = cert.ngayCap;
                  try {
                    final dt = DateTime.parse(cert.ngayCap);
                    ngayCapStr = DateFormat('dd/MM/yyyy').format(dt);
                  } catch (_) {}

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x060F172A),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cert.maChungNhan,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF1D4ED8),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: Text(
                                '+${cert.diemCong} Điểm RL',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          cert.tenHoatDong,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 4),
                            Text(
                              'Ngày cấp: $ngayCapStr',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                            if (cert.diaDiem != null && cert.diaDiem!.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  cert.diaDiem!,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                CertificateDialog.show(
                                  context,
                                  maChungNhan: cert.maChungNhan,
                                  hoTen: sv.hoTen,
                                  mssv: sv.mssv,
                                  lop: sv.lop ?? '---',
                                  tenHoatDong: cert.tenHoatDong,
                                  diaDiem: cert.diaDiem,
                                  ngayCap: ngayCapStr,
                                  diemCong: cert.diemCong,
                                );
                              },
                              icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                              label: const Text('Xem & Xác thực QR'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0284C7),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
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
