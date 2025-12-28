import '../Models/ActivityModel.dart';
import '../Repository/ActivityRepository.dart';
import '../Repository/ApiResponse.dart';

class ActivityService {
  late ActivityRepository activityRepository;

  // Constructor: Khởi tạo Repository
  ActivityService() {
    this.activityRepository = ActivityRepository();
  }

  // Hàm lấy danh sách hoạt động
  Future<ApiResponse<List<ActivityModel>>> getActivities() async {
    return await activityRepository.getActivities();
  }
}