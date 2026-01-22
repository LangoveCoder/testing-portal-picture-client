import 'package:get/get.dart';
import '../controllers/mark_attendance_controller.dart';

class MarkAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MarkAttendanceController>(
      () => MarkAttendanceController(),
    );
  }
}
