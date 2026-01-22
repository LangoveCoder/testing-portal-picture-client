import 'package:get/get.dart';
import '../controllers/student_search_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/student_cache_service.dart';
import '../../../data/providers/api_provider.dart';

class StudentSearchBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure services are available
    Get.lazyPut<ApiProvider>(() => ApiProvider(), fenix: true);
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<StudentCacheService>(() => StudentCacheService(), fenix: true);

    // Controller
    Get.lazyPut<StudentSearchController>(
      () => StudentSearchController(),
    );
  }
}
