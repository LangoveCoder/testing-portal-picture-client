import 'package:get/get.dart';
import '../controllers/student_search_controller.dart';

class StudentSearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentSearchController>(() => StudentSearchController());
  }
}
