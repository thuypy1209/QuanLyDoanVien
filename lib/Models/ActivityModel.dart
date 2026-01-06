class ActivityModel {
  int? id;
  String? tenHoatDong;
  String? moTa;
  String? thoiGianBatDau;
  String? thoiGianKetThuc;
  String? diaDiem;
  int? diemCong;
  String? trangThai;
  bool isRegistered;

  ActivityModel({
    this.id,
    this.tenHoatDong,
    this.moTa,
    this.thoiGianBatDau,
    this.thoiGianKetThuc,
    this.diaDiem,
    this.diemCong,
    this.trangThai,
    this.isRegistered = false
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      tenHoatDong: json['tenHoatDong'],
      moTa: json['moTa'],

      thoiGianBatDau: json['thoiGianBatDau'],
      thoiGianKetThuc: json['thoiGianKetThuc'],
      diaDiem: json['diaDiem'],
      diemCong: json['diemCong'],
      trangThai: json['trangThai'],
      isRegistered: false,
    );
  }
}