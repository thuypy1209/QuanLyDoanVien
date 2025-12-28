import '../Repository/ApiResponse.dart';
import '../Repository/StudentRepository.dart'; // Import Repo mới
import '../Models/StudentModel.dart';

class StudentService {
  late StudentRepository studentRepository;

  StudentService() {
    this.studentRepository = StudentRepository();
  }

  Future<ApiResponse<StudentModel>> getStudentInfo() async {
    return await studentRepository.getStudentInfo();
  }
}