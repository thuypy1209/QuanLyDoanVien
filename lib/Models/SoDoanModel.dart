class StudentSoDoanResponse {
  final SoDoanSinhVien sinhVien;
  final SoDoanDetail? soDoan;
  final bool daNopSo;

  StudentSoDoanResponse({
    required this.sinhVien,
    this.soDoan,
    required this.daNopSo,
  });

  factory StudentSoDoanResponse.fromJson(Map<String, dynamic> json) {
    return StudentSoDoanResponse(
      sinhVien: SoDoanSinhVien.fromJson(json['sinhVien'] ?? {}),
      soDoan: json['soDoan'] != null ? SoDoanDetail.fromJson(json['soDoan']) : null,
      daNopSo: json['daNopSo'] ?? false,
    );
  }
}

class SoDoanSinhVien {
  final String mssv;
  final String hoTen;
  final String? lop;
  final String? khoa;
  final String? chucVuDoan;
  final String? soDoanVien;
  final String? ngayVaoDoan;
  final String? noiVaoDoan;

  SoDoanSinhVien({
    required this.mssv,
    required this.hoTen,
    this.lop,
    this.khoa,
    this.chucVuDoan,
    this.soDoanVien,
    this.ngayVaoDoan,
    this.noiVaoDoan,
  });

  factory SoDoanSinhVien.fromJson(Map<String, dynamic> json) {
    return SoDoanSinhVien(
      mssv: json['mssv'] ?? json['MSSV'] ?? '',
      hoTen: json['hoTen'] ?? json['HoTen'] ?? '',
      lop: json['lop'] ?? json['Lop'],
      khoa: json['khoa'] ?? json['Khoa'],
      chucVuDoan: json['chucVuDoan'] ?? json['ChucVuDoan'],
      soDoanVien: json['soDoanVien'] ?? json['SoDoanVien'],
      ngayVaoDoan: json['ngayVaoDoan'] ?? json['NgayVaoDoan'],
      noiVaoDoan: json['noiVaoDoan'] ?? json['NoiVaoDoan'],
    );
  }
}

class SoDoanDetail {
  final int id;
  final String trangThaiSoDoan;
  final String? ngayNop;
  final String? viTriLuuTru;
  final bool giayGioiThieuHe;

  SoDoanDetail({
    required this.id,
    required this.trangThaiSoDoan,
    this.ngayNop,
    this.viTriLuuTru,
    required this.giayGioiThieuHe,
  });

  factory SoDoanDetail.fromJson(Map<String, dynamic> json) {
    return SoDoanDetail(
      id: json['id'] ?? json['Id'] ?? 0,
      trangThaiSoDoan: json['trangThaiSoDoan'] ?? json['TrangThaiSoDoan'] ?? 'ChuaNop',
      ngayNop: json['ngayNop'] ?? json['NgayNop'],
      viTriLuuTru: json['viTriLuuTru'] ?? json['ViTriLuuTru'],
      giayGioiThieuHe: json['giayGioiThieuHe'] ?? json['GiayGioiThieuHe'] ?? false,
    );
  }
}
