class ActivityModel {
  int? id;
  String? tenHoatDong;
  String? moTa;           // Mới
  String? thoiGianBatDau; // Mới (Thay cho thoiGian cũ)
  String? thoiGianKetThuc;// Mới
  String? diaDiem;
  int? diemCong;          // Mới
  String? trangThai;      // Mới
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
      // JSON trả về DateTime dạng chuỗi ISO 8601
      thoiGianBatDau: json['thoiGianBatDau'],
      thoiGianKetThuc: json['thoiGianKetThuc'],
      diaDiem: json['diaDiem'],
      diemCong: json['diemCong'],
      trangThai: json['trangThai'],
      isRegistered: false,
    );
  }
}