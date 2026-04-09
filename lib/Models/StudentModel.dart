class StudentModel {
  String? mssv;
  String? hoTen;
  String? lop;
  String? khoa;
  String? email;
  int? diemRenLuyen;
  String? avatarUrl;

  StudentModel({
    this.mssv,
    this.hoTen,
    this.lop,
    this.khoa,
    this.email,
    this.diemRenLuyen,
    this.avatarUrl,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      mssv: json['mssv'] ?? json['MSSV'] ?? "",
      hoTen: json['hoTen'] ?? json['HoTen'] ?? "",
      lop: json['lop'] ?? json['Lop'] ?? "---",
      khoa: json['khoa'] ?? json['Khoa'] ?? "",
      email: json['email'] ?? json['Email'] ?? "",
      diemRenLuyen: json['diemRenLuyenTichLuy'] ?? 0,
      avatarUrl: json['avatarUrl'] ?? json['AvatarUrl'],
    );
  }
}