import 'dart:async';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  var progress = 0.0.obs;
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    _startProgressAnimation();
  }

  void _startProgressAnimation() {
    // Animate progress bar over 3 seconds with smoother increments
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (progress.value < 1.0) {
        progress.value += 0.01; // Increment by 1% every 30ms = 3 seconds total
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 200), () {
          navigateToAuth();
        });
      }
    });
  }

  void navigateToAuth() {
    _timer?.cancel();
    Get.offAllNamed(AppRoutes.AUTH);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}