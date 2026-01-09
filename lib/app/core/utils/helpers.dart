import 'custom_toast.dart';

class Helpers {
  // WhatsApp-style success message
  static void showSuccessToast(String message) {
    CustomToast.success(message);
  }

  // WhatsApp-style error message
  static void showErrorToast(String message) {
    CustomToast.error(message);
  }

  // WhatsApp-style info message
  static void showInfoToast(String message) {
    CustomToast.info(message);
  }

  // WhatsApp-style warning message
  static void showWarningToast(String message) {
    CustomToast.warning(message);
  }

  // Generic method (backward compatible)
  static void showToast(String message, {bool isError = false}) {
    if (isError) {
      showErrorToast(message);
    } else {
      showSuccessToast(message);
    }
  }
}
