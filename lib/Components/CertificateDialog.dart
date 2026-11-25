import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../Utils.dart';

class CertificateDialog extends StatelessWidget {
  final String maChungNhan;
  final String hoTen;
  final String mssv;
  final String lop;
  final String tenHoatDong;
  final String? diaDiem;
  final String ngayCap;
  final int diemCong;

  const CertificateDialog({
    Key? key,
    required this.maChungNhan,
    required this.hoTen,
    required this.mssv,
    required this.lop,
    required this.tenHoatDong,
    this.diaDiem,
    required this.ngayCap,
    required this.diemCong,
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String maChungNhan,
    required String hoTen,
    required String mssv,
    required String lop,
    required String tenHoatDong,
    String? diaDiem,
    required String ngayCap,
    required int diemCong,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CertificateDialog(
        maChungNhan: maChungNhan,
        hoTen: hoTen,
        mssv: mssv,
        lop: lop,
        tenHoatDong: tenHoatDong,
        diaDiem: diaDiem,
        ngayCap: ngayCap,
        diemCong: diemCong,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final verifyUrl = '${Utils.baseUrl}/verify/$maChungNhan';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with Emblem styling
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 24),
                  Column(
                    children: const [
                      Text(
                        'ĐOÀN TNCS HỒ CHÍ MINH',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0D47A1),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'ĐOÀN TRƯỜNG ĐẠI HỌC CÔNG NGHỆ TP.HCM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFE2E8F0)),

              // Certificate Title
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFEF3C7),
                ),
                child: const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFD97706),
                  size: 38,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'GIẤY CHỨNG NHẬN',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: 1.2,
                ),
              ),
              const Text(
                'ĐIỆN TỬ CHÍNH THỨC',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF059669),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // Student Recognition
              const Text(
                'Ban Chấp Hành Đoàn Trường Chứng Nhận Đoàn Viên:',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                hoTen.toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0D47A1),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'MSSV: $mssv  •  Chi đoàn: $lop',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 14),

              // Activity Detail Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Đã tích cực tham gia hoạt động phong trào:',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tenHoatDong,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (diaDiem != null && diaDiem!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            diaDiem!,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        '+$diemCong Điểm Rèn Luyện',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // QR Code Verification
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: QrImageView(
                  data: verifyUrl,
                  version: QrVersions.auto,
                  size: 110.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0D47A1),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Mã tra cứu: $maChungNhan',
                style: const TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2563EB),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ngày cấp: $ngayCap',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 16),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D47A1),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
