class StudentModel {
  String? mssv;
  String? hoTen;
  String? lop;
  String? khoa;
  String? email;
  int? diemRenLuyen;

  StudentModel({
    this.mssv,
    this.hoTen,
    this.lop,
    this.khoa,
    this.email,
    this.diemRenLuyen,
  });

  // Hàm chuyển từ JSON sang Object
  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      mssv: json['mssv'],
      hoTen: json['hoTen'],
      lop: json['lop'],
      khoa: json['khoa'],
      email: json['email'],
      diemRenLuyen: json['diemRenLuyenTichLuy'], // Chú ý tên trường phải khớp API trả về
    );
  }
}