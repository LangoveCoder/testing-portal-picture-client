import 'package:get/get.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/student_search/bindings/student_search_binding.dart';
import '../modules/student_search/views/student_search_view.dart';
import '../modules/students/bindings/students_binding.dart';
import '../modules/students/views/students_view.dart';
import '../modules/camera/bindings/camera_binding.dart';
import '../modules/camera/views/camera_view.dart';
import '../modules/history/bindings/history_binding.dart';
import '../modules/history/views/history_view.dart';
import '../modules/qr_scanner/bindings/qr_scanner_binding.dart';
import '../modules/qr_scanner/views/qr_scanner_view.dart';
import '../modules/student_verification/bindings/student_verification_binding.dart';
import '../modules/student_verification/views/student_verification_view.dart';
import '../modules/attendance_stats/bindings/attendance_stats_binding.dart';
import '../modules/attendance_stats/views/attendance_stats_view.dart';
import '../modules/test_selection/bindings/test_selection_binding.dart';
import '../modules/test_selection/views/test_selection_view.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
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
      name: AppRoutes.STUDENTS,
      page: () => StudentsView(),
      binding: StudentsBinding(),
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
    GetPage(
      name: AppRoutes.QR_SCANNER,
      page: () => const QRScannerView(),
      binding: QRScannerBinding(),
    ),
    GetPage(
      name: AppRoutes.STUDENT_VERIFICATION,
      page: () => const StudentVerificationView(),
      binding: StudentVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.ATTENDANCE_STATS,
      page: () => const AttendanceStatsView(),
      binding: AttendanceStatsBinding(),
    ),
    GetPage(
      name: AppRoutes.TEST_SELECTION,
      page: () => const TestSelectionView(),
      binding: TestSelectionBinding(),
    ),
  ];
}

class AppRoutes {
  static const String SPLASH = '/splash';
  static const String AUTH = '/auth';
  static const String HOME = '/home';
  static const String STUDENT_SEARCH = '/student-search';
  static const String CAMERA = '/camera';
  static const String STUDENTS = '/students';
  static const String HISTORY = '/history';
  static const String QR_SCANNER = '/qr-scanner';
  static const String STUDENT_VERIFICATION = '/student-verification';
  static const String ATTENDANCE_STATS = '/attendance-stats';
  static const String TEST_SELECTION = '/test-selection';
}
