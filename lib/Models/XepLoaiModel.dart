class StudentXepLoaiResponse {
  final XepLoaiSinhVien sinhVien;
  final XepLoaiRecord? currentRating;
  final List<XepLoaiRecord> history;

  StudentXepLoaiResponse({
    required this.sinhVien,
    this.currentRating,
    required this.history,
  });

  factory StudentXepLoaiResponse.fromJson(Map<String, dynamic> json) {
    return StudentXepLoaiResponse(
      sinhVien: XepLoaiSinhVien.fromJson(json['sinhVien'] ?? {}),
      currentRating: json['currentRating'] != null
          ? XepLoaiRecord.fromJson(json['currentRating'])
          : null,
      history: (json['history'] as List<dynamic>? ?? [])
          .map((item) => XepLoaiRecord.fromJson(item))
          .toList(),
    );
  }
}

class XepLoaiSinhVien {
  final String mssv;
  final String hoTen;
  final String? lop;
  final String? khoa;
  final String? chucVuDoan;
  final bool laDoanVienUuTu;
  final int diemRenLuyenTichLuy;

  XepLoaiSinhVien({
    required this.mssv,
    required this.hoTen,
    this.lop,
    this.khoa,
    this.chucVuDoan,
    required this.laDoanVienUuTu,
    required this.diemRenLuyenTichLuy,
  });

  factory XepLoaiSinhVien.fromJson(Map<String, dynamic> json) {
    return XepLoaiSinhVien(
      mssv: json['mssv'] ?? json['MSSV'] ?? '',
      hoTen: json['hoTen'] ?? json['HoTen'] ?? '',
      lop: json['lop'] ?? json['Lop'],
      khoa: json['khoa'] ?? json['Khoa'],
      chucVuDoan: json['chucVuDoan'] ?? json['ChucVuDoan'],
      laDoanVienUuTu: json['laDoanVienUuTu'] ?? json['LaDoanVienUuTu'] ?? false,
      diemRenLuyenTichLuy: json['diemRenLuyenTichLuy'] ?? json['DiemRenLuyenTichLuy'] ?? 0,
    );
  }
}

class XepLoaiRecord {
  final int id;
  final String namHoc;
  final String xepLoai; // "XuatSac" | "Kha" | "TrungBinh" | "Yeu"
  final String? tuDanhGia;
  final String? chiDoanDanhGia;
  final bool doanKhoaDuyet;

  XepLoaiRecord({
    required this.id,
    required this.namHoc,
    required this.xepLoai,
    this.tuDanhGia,
    this.chiDoanDanhGia,
    required this.doanKhoaDuyet,
  });

  factory XepLoaiRecord.fromJson(Map<String, dynamic> json) {
    return XepLoaiRecord(
      id: json['id'] ?? json['Id'] ?? 0,
      namHoc: json['namHoc'] ?? json['NamHoc'] ?? '',
      xepLoai: json['xepLoai'] ?? json['XepLoai'] ?? 'TrungBinh',
      tuDanhGia: json['tuDanhGia'] ?? json['TuDanhGia'],
      chiDoanDanhGia: json['chiDoanDanhGia'] ?? json['ChiDoanDanhGia'],
      doanKhoaDuyet: json['doanKhoaDuyet'] ?? json['DoanKhoaDuyet'] ?? false,
    );
  }

  String get xepLoaiTitle {
    switch (xepLoai) {
      case 'XuatSac':
        return 'Đoàn Viên Xuất Sắc';
      case 'Kha':
        return 'Đoàn Viên Khá';
      case 'TrungBinh':
        return 'Đoàn Viên Trung Bình';
      case 'Yeu':
        return 'Đoàn Viên Yếu';
      default:
        return 'Chưa Xếp Loại';
    }
  }
}
