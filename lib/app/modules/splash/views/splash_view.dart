import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../core/values/app_colors.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1A1A1A)
          : Colors.white,
      body: Column(
        children: [
          // Main content centered
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback if logo is not found
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              size: 80,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // App Name
                  Text(
                    'BACT Attendance Client',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    'Test Photo Capture Application',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white70
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Progress bar at the bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 50.0),
            child: Container(
              width: 150,
              height: 3,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.3)
                    : Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(1.5),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Obx(() => AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: 150 * controller.progress.value,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}