import 'package:get/get.dart';
import '../controllers/qr_scanner_controller.dart';

class QRScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<QRScannerController>(
      () => QRScannerController(),
    );
  }
}