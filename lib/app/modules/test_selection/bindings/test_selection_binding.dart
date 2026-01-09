import 'package:get/get.dart';
import '../controllers/test_selection_controller.dart';

class TestSelectionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TestSelectionController>(
      () => TestSelectionController(),
    );
  }
}