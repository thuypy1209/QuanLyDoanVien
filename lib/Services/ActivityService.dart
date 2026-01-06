import '../Models/ActivityModel.dart';
import '../Repository/ActivityRepository.dart';
import '../Repository/ApiResponse.dart';

class ActivityService {
  late ActivityRepository activityRepository;

  // Constructor: Khởi tạo Repository
  ActivityService() {
    this.activityRepository = ActivityRepository();
  }
  Future<ApiResponse<List<ActivityModel>>> getActivities() async {
    return await activityRepository.getActivities();
  }
  Future<ApiResponse<bool>> registerActivity(int activityId) async {
    return await activityRepository.registerActivity(activityId);
  }
  Future<ApiResponse<List<ActivityModel>>> getHistory() async {
    return await activityRepository.getHistory();
  }
}