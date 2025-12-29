import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/student_search/bindings/student_search_binding.dart';
import '../modules/student_search/views/student_search_view.dart';
import '../modules/camera/bindings/camera_binding.dart';
import '../modules/camera/views/camera_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';

class AppPages {
  static const INITIAL = AppRoutes.AUTH;

  static final routes = [
    GetPage(
      name: AppRoutes.AUTH,
      page: () => AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.STUDENT_SEARCH,
      page: () => StudentSearchView(),
      binding: StudentSearchBinding(),
    ),
    GetPage(
      name: AppRoutes.CAMERA,
      page: () => CameraView(),
      binding: CameraBinding(),
    ),
    GetPage(
      name: AppRoutes.HISTORY,
      page: () => HistoryView(),
      binding: HistoryBinding(),
    ),
  ];
}

class AppRoutes {
  static const String AUTH = '/auth';
  static const String HOME = '/home';
  static const String STUDENT_SEARCH = '/student-search';
  static const String CAMERA = '/camera';
  static const String HISTORY = '/history';
}
