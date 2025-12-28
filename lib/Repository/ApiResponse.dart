class ApiResponse<T> {
  T? data;          // Dữ liệu trả về (VD: Token, User, List...)
  String? message;  // Thông báo lỗi hoặc thành công
  bool isSuccess;   // Trạng thái: true (thành công) / false (thất bại)

  ApiResponse({
    this.data,
    this.message,
    required this.isSuccess
  });

  // Hàm tạo nhanh lỗi
  factory ApiResponse.error(String msg) {
    return ApiResponse(isSuccess: false, message: msg);
  }

  // Hàm tạo nhanh thành công
  factory ApiResponse.success(T? data, {String? message}) {
    return ApiResponse(isSuccess: true, data: data, message: message);
  }
}