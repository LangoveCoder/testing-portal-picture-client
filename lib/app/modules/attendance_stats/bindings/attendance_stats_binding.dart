import 'package:get/get.dart';
import '../controllers/attendance_stats_controller.dart';

class AttendanceStatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceStatsController>(
      () => AttendanceStatsController(),
    );
  }
}