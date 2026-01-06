class CheckInHistoryModel {
  final int? id;
  final String? tenHoatDong;
  final String? thoiGianCheckIn;
  final bool isSuccess;
  final int diemCong; // Thêm trường này để hiển thị điểm cộng nếu cần

  CheckInHistoryModel({
    this.id,
    this.tenHoatDong,
    this.thoiGianCheckIn,
    this.isSuccess = false,
    this.diemCong = 0,
  });

  factory CheckInHistoryModel.fromJson(Map<String, dynamic> json) {
    return CheckInHistoryModel(
      id: json['id'],
      // Backend trả về 'tenHoatDong', nếu null thì hiện text mặc định
      tenHoatDong: json['tenHoatDong'] ?? "Hoạt động không tên",
      thoiGianCheckIn: json['thoiGianCheckIn'],
      // Backend trả về 'isSuccess' (true/false)
      isSuccess: json['isSuccess'] ?? false,
      diemCong: json['diemCong'] ?? 0,
    );
  }
}