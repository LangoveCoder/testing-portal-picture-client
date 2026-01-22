import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // ✅ All services (ApiProvider, SecureStorageService, AuthService)
    // are already initialized in main.dart - no need to create them here

    // Controller only
    Get.lazyPut<AuthController>(
      () => AuthController(),
    );
  }
}
