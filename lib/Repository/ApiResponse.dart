class ApiResponse<T> {
  T? data;
  String? message;
  bool isSuccess;

  ApiResponse({
    this.data,
    this.message,
    required this.isSuccess
  });


  factory ApiResponse.error(String msg) {
    return ApiResponse(isSuccess: false, message: msg);
  }

  factory ApiResponse.success(T? data, {String? message}) {
    return ApiResponse(isSuccess: true, data: data, message: message);
  }
}