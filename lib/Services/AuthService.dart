import '../Repository/ApiResponse.dart';
import '../Repository/AuthRepository.dart';

class AuthService {
  late AuthRepository authRepository;

  // Constructor khởi tạo Repository
  AuthService() {
    this.authRepository = AuthRepository();
  }

  // Hàm Đăng ký (Gọi từ Repository)
  Future<ApiResponse<bool>> register({
    required String mssv,
    required String password,
    required String confirmPassword,
    required String hoTen,
    required String email,
    required String lop,
  }) async {
    return await authRepository.register(
      mssv: mssv,
      password: password,
      confirmPassword: confirmPassword,
      hoTen: hoTen,
      email: email,
      lop: lop,
    );
  }

  // Hàm Đăng nhập (Gọi từ Repository)
  Future<ApiResponse<String>> login(String username, String password) async {
    return await authRepository.login(username, password);
  }
}