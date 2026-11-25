class StudentDoanPhiResponse {
  final DoanPhiSinhVien sinhVien;
  final DoanPhiSummary summary;
  final List<DoanPhiRecord> records;

  StudentDoanPhiResponse({
    required this.sinhVien,
    required this.summary,
    required this.records,
  });

  factory StudentDoanPhiResponse.fromJson(Map<String, dynamic> json) {
    return StudentDoanPhiResponse(
      sinhVien: DoanPhiSinhVien.fromJson(json['sinhVien'] ?? {}),
      summary: DoanPhiSummary.fromJson(json['summary'] ?? {}),
      records: (json['records'] as List<dynamic>? ?? [])
          .map((item) => DoanPhiRecord.fromJson(item))
          .toList(),
    );
  }
}

class DoanPhiSinhVien {
  final String mssv;
  final String hoTen;
  final String? lop;
  final String? khoa;
  final String? chucVuDoan;
  final String? soDoanVien;

  DoanPhiSinhVien({
    required this.mssv,
    required this.hoTen,
    this.lop,
    this.khoa,
    this.chucVuDoan,
    this.soDoanVien,
  });

  factory DoanPhiSinhVien.fromJson(Map<String, dynamic> json) {
    return DoanPhiSinhVien(
      mssv: json['mssv'] ?? json['MSSV'] ?? '',
      hoTen: json['hoTen'] ?? json['HoTen'] ?? '',
      lop: json['lop'] ?? json['Lop'],
      khoa: json['khoa'] ?? json['Khoa'],
      chucVuDoan: json['chucVuDoan'] ?? json['ChucVuDoan'],
      soDoanVien: json['soDoanVien'] ?? json['SoDoanVien'],
    );
  }
}

class DoanPhiSummary {
  final int tongDaNop;
  final int tongChuaNop;
  final int soKyDaNop;
  final int soKyChuaNop;
  final bool daHoanTatTatCa;

  DoanPhiSummary({
    required this.tongDaNop,
    required this.tongChuaNop,
    required this.soKyDaNop,
    required this.soKyChuaNop,
    required this.daHoanTatTatCa,
  });

  factory DoanPhiSummary.fromJson(Map<String, dynamic> json) {
    return DoanPhiSummary(
      tongDaNop: json['tongDaNop'] ?? 0,
      tongChuaNop: json['tongChuaNop'] ?? 0,
      soKyDaNop: json['soKyDaNop'] ?? 0,
      soKyChuaNop: json['soKyChuaNop'] ?? 0,
      daHoanTatTatCa: json['daHoanTatTatCa'] ?? false,
    );
  }
}

class DoanPhiRecord {
  final int id;
  final String hocKy;
  final String namHoc;
  final int soTien;
  final String trangThai; // "DaNop" | "ChuaNop"
  final String? ngayNop;
  final String? nguoiThu;

  DoanPhiRecord({
    required this.id,
    required this.hocKy,
    required this.namHoc,
    required this.soTien,
    required this.trangThai,
    this.ngayNop,
    this.nguoiThu,
  });

  factory DoanPhiRecord.fromJson(Map<String, dynamic> json) {
    return DoanPhiRecord(
      id: json['id'] ?? json['Id'] ?? 0,
      hocKy: json['hocKy'] ?? json['HocKy'] ?? '',
      namHoc: json['namHoc'] ?? json['NamHoc'] ?? '',
      soTien: json['soTien'] ?? json['SoTien'] ?? 0,
      trangThai: json['trangThai'] ?? json['TrangThai'] ?? 'ChuaNop',
      ngayNop: json['ngayNop'] ?? json['NgayNop'],
      nguoiThu: json['nguoiThu'] ?? json['NguoiThu'],
    );
  }
}
