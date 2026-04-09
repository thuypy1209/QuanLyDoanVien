class ActivityModel {
  int? id;
  int? hoatDongId;
  String? tenHoatDong;
  String? moTa;
  String? thoiGianBatDau;
  String? thoiGianKetThuc;
  String? diaDiem;
  int? diemCong;
  String? trangThai;
  bool isRegistered;
  String? imageUrl;

  ActivityModel({
    this.id,
    this.hoatDongId,
    this.tenHoatDong,
    this.moTa,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.diaDiem,
    this.diemCong,
    this.trangThai,
    this.isRegistered = false,
    this.imageUrl,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      hoatDongId: json['hoatDongId'] ?? json['HoatDongId'] ?? (json['HoatDong'] != null ? json['HoatDong']['Id'] : null),
      tenHoatDong: json['tenHoatDong'],
      moTa: json['moTa'],

      thoiGianBatDau: json['thoiGianBatDau'],
      thoiGianKetThuc: json['thoiGianKetThuc'],
      diaDiem: json['diaDiem'],
      diemCong: json['diemCong'],
      trangThai: json['trangThai'],
      isRegistered: false,
      imageUrl: json['imageUrl']?? json['ImageUrl'],
    );
  }
}