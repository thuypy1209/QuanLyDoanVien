import '../Repository/ApiResponse.dart';
import '../Repository/AuthRepository.dart';

class AuthService {
  late AuthRepository authRepository;

  AuthService() {
    this.authRepository = AuthRepository();
  }
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
  Future<ApiResponse<dynamic>> login(String username, String password) async {
    return await authRepository.login(username, password);
  }
}