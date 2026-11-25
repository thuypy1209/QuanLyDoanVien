import 'package:flutter/material.dart';
import '../../Components/AppBarComponent.dart';
import '../../Components/ButtonComponent.dart';
import '../../Components/EmptyStateWidget.dart';
import '../../Models/XepLoaiModel.dart';
import '../../Services/PortalService.dart';

class XepLoaiScreen extends StatefulWidget {
  const XepLoaiScreen({Key? key}) : super(key: key);

  @override
  State<XepLoaiScreen> createState() => _XepLoaiScreenState();
}

class _XepLoaiScreenState extends State<XepLoaiScreen> {
  final PortalService _service = PortalService();
  bool _isLoading = true;
  String? _errorMessage;
  StudentXepLoaiResponse? _data;

  @override
  void initState() {
    super.initState();
    _fetchXepLoai();
  }

  Future<void> _fetchXepLoai() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await _service.getMyXepLoai();
    if (res.isSuccess && res.data != null) {
      setState(() {
        _data = res.data;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = res.message ?? 'Không thể tải thông tin xếp loại';
        _isLoading = false;
      });
    }
  }

  void _showSelfEvaluationModal() {
    final current = _data?.currentRating;
    String selectedNamHoc = current?.namHoc ?? '2025-2026';
    String selectedXepLoai = current?.xepLoai ?? 'XuatSac';
    final textController = TextEditingController(text: current?.tuDanhGia ?? '');
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tự Đánh Giá Rèn Luyện',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Năm học bình bầu:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        selectedNamHoc,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Mức tự xếp loại:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: selectedXepLoai,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'XuatSac', child: Text('Đoàn viên Xuất sắc')),
                        DropdownMenuItem(value: 'Kha', child: Text('Đoàn viên Khá')),
                        DropdownMenuItem(value: 'TrungBinh', child: Text('Đoàn viên Trung bình')),
                        DropdownMenuItem(value: 'Yeu', child: Text('Đoàn viên Yếu')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedXepLoai = val);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Nội dung tự nhận xét ưu khuyết điểm:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: textController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Nhập tóm tắt quá trình rèn luyện, đóng góp cho công tác Đoàn và phong trào thanh niên...',
                        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ButtonComponent(
                      text: 'Gửi bản tự đánh giá',
                      isLoading: isSubmitting,
                      color: const Color(0xFFD97706),
                      onPressed: () async {
                        final comment = textController.text.trim();
                        if (comment.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Vui lòng nhập nội dung tự nhận xét')),
                          );
                          return;
                        }

                        setModalState(() => isSubmitting = true);
                        final submitRes = await _service.submitTuDanhGia(
                          namHoc: selectedNamHoc,
                          xepLoai: selectedXepLoai,
                          tuDanhGia: comment,
                        );
                        setModalState(() => isSubmitting = false);

                        if (submitRes.isSuccess) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã gửi bản tự đánh giá thành công!'),
                              backgroundColor: Color(0xFF059669),
                            ),
                          );
                          _fetchXepLoai();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(submitRes.message ?? 'Không thể gửi đánh giá'),
                              backgroundColor: const Color(0xFFE11D48),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const AppBarComponent(
        title: 'Bình Bầu & Phân Loại',
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFD97706)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: EmptyStateWidget(
          message: 'Đã xảy ra lỗi',
          subMessage: _errorMessage!,
          actionText: 'Thử lại',
          onAction: _fetchXepLoai,
        ),
      );
    }

    final data = _data;
    if (data == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    final sv = data.sinhVien;
    final current = data.currentRating;
    final history = data.history;

    return RefreshIndicator(
      onRefresh: _fetchXepLoai,
      color: const Color(0xFFD97706),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Prestigious Gold/Amber Hero Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFD97706), // amber-600
                    Color(0xFFB45309), // amber-700
                    Color(0xFF78350F), // amber-900
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x35D97706),
                    blurRadius: 18,
                    offset: Offset(0, 8),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Năm học ${current?.namHoc ?? "2025-2026"}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      if (sv.laDoanVienUuTu)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE047),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.workspace_premium, size: 12, color: Color(0xFF78350F)),
                              SizedBox(width: 4),
                              Text(
                                'ĐOÀN VIÊN ƯU TÚ',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF78350F),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'KẾT QUẢ XẾP LOẠI ĐOÀN VIÊN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFFDE047),
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    current?.xepLoaiTitle ?? 'Chưa Xếp Loại',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Đoàn viên: ${sv.hoTen} • Điểm RL: ${sv.diemRenLuyenTichLuy} đ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Approval Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          current?.doanKhoaDuyet == true
                              ? Icons.verified_rounded
                              : Icons.schedule_rounded,
                          color: current?.doanKhoaDuyet == true
                              ? const Color(0xFFFDE047)
                              : Colors.white70,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          current?.doanKhoaDuyet == true
                              ? 'Đoàn Khoa đã phê duyệt'
                              : 'Đang chờ Đoàn Khoa phê duyệt',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Button
            ButtonComponent(
              text: current?.tuDanhGia != null
                  ? 'Chỉnh sửa tự nhận xét rèn luyện'
                  : 'Tự đánh giá năm học này',
              icon: Icons.edit_note_rounded,
              color: const Color(0xFFD97706),
              onPressed: _showSelfEvaluationModal,
            ),
            const SizedBox(height: 24),

            // History Section
            const Text(
              'Lịch Sử Phân Loại Qua Các Năm',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            if (history.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Center(
                  child: Text(
                    'Chưa có lịch sử các năm trước.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (ctx, i) {
                  final h = history[i];
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Năm học ${h.namHoc}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              h.xepLoaiTitle,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Đã lưu hồ sơ',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                            ),
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
