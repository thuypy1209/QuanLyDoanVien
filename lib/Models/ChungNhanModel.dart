class StudentChungNhanResponse {
  final ChungNhanSinhVien sinhVien;
  final int tongChungNhan;
  final List<ChungNhanItem> items;

  StudentChungNhanResponse({
    required this.sinhVien,
    required this.tongChungNhan,
    required this.items,
  });

  factory StudentChungNhanResponse.fromJson(Map<String, dynamic> json) {
    return StudentChungNhanResponse(
      sinhVien: ChungNhanSinhVien.fromJson(json['sinhVien'] ?? {}),
      tongChungNhan: json['tongChungNhan'] ?? 0,
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => ChungNhanItem.fromJson(item))
          .toList(),
    );
  }
}

class ChungNhanSinhVien {
  final String mssv;
  final String hoTen;
  final String? lop;
  final String? khoa;
  final String? chucVuDoan;
  final String? soDoanVien;

  ChungNhanSinhVien({
    required this.mssv,
    required this.hoTen,
    this.lop,
    this.khoa,
    this.chucVuDoan,
    this.soDoanVien,
  });

  factory ChungNhanSinhVien.fromJson(Map<String, dynamic> json) {
    return ChungNhanSinhVien(
      mssv: json['mssv'] ?? json['MSSV'] ?? '',
      hoTen: json['hoTen'] ?? json['HoTen'] ?? '',
      lop: json['lop'] ?? json['Lop'],
      khoa: json['khoa'] ?? json['Khoa'],
      chucVuDoan: json['chucVuDoan'] ?? json['ChucVuDoan'],
      soDoanVien: json['soDoanVien'] ?? json['SoDoanVien'],
    );
  }
}

class ChungNhanItem {
  final int id;
  final String maChungNhan;
  final String ngayCap;
  final int hoatDongId;
  final String tenHoatDong;
  final String? loaiHoatDong;
  final int diemCong;
  final String? thoiGianBatDau;
  final String? thoiGianKetThuc;
  final String? diaDiem;
  final String? moTa;

  ChungNhanItem({
    required this.id,
    required this.maChungNhan,
    required this.ngayCap,
    required this.hoatDongId,
    required this.tenHoatDong,
    this.loaiHoatDong,
    required this.diemCong,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.diaDiem,
    this.moTa,
  });

  factory ChungNhanItem.fromJson(Map<String, dynamic> json) {
    return ChungNhanItem(
      id: json['id'] ?? json['Id'] ?? 0,
      maChungNhan: json['maChungNhan'] ?? json['MaChungNhan'] ?? '',
      ngayCap: json['ngayCap'] ?? json['NgayCap'] ?? '',
      hoatDongId: json['hoatDongId'] ?? json['HoatDongId'] ?? 0,
      tenHoatDong: json['tenHoatDong'] ?? json['TenHoatDong'] ?? '',
      loaiHoatDong: json['loaiHoatDong'] ?? json['LoaiHoatDong'],
      diemCong: json['diemCong'] ?? json['DiemCong'] ?? 0,
      thoiGianBatDau: json['thoiGianBatDau'] ?? json['ThoiGianBatDau'],
      thoiGianKetThuc: json['thoiGianKetThuc'] ?? json['ThoiGianKetThuc'],
      diaDiem: json['diaDiem'] ?? json['DiaDiem'],
      moTa: json['moTa'] ?? json['MoTa'],
    );
  }
}
