import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/qr_scanner_controller.dart';
import '../../../core/values/app_colors.dart';
import '../../../core/services/attendance_service.dart';

class QRScannerView extends GetView<QRScannerController> {
  const QRScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attendanceService = Get.find<AttendanceService>();
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Student QR'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => IconButton(
            onPressed: controller.toggleFlash,
            icon: Icon(
              controller.isFlashOn.value ? Icons.flash_on : Icons.flash_off,
            ),
          )),
        ],
      ),
      body: Column(
        children: [
          // QR Scanner Area
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                // Mobile Scanner View
                MobileScanner(
                  controller: controller.scannerController,
                  onDetect: controller.onDetect,
                ),
                
                // Custom Scanning Overlay
                Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Center(
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.primary,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Corner decorations
                          Positioned(
                            top: -2,
                            left: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.primary, width: 8),
                                  left: BorderSide(color: AppColors.primary, width: 8),
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(color: AppColors.primary, width: 8),
                                  right: BorderSide(color: AppColors.primary, width: 8),
                                ),
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            left: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColors.primary, width: 8),
                                  left: BorderSide(color: AppColors.primary, width: 8),
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: AppColors.primary, width: 8),
                                  right: BorderSide(color: AppColors.primary, width: 8),
                                ),
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Processing Overlay
                Obx(() => controller.isProcessing.value
                    ? Container(
                        color: Colors.black54,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 16),
                              Text(
                                'Processing QR Code...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox()),
              ],
            ),
          ),
          
          // Bottom Controls
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Instructions
                  Text(
                    'Position the QR code within the frame',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Manual Entry Button
                      ElevatedButton.icon(
                        onPressed: controller.enterRollNumberManually,
                        icon: const Icon(Icons.keyboard),
                        label: const Text('Manual Entry'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      ),
                      
                      // Stats Button
                      Obx(() => ElevatedButton.icon(
                        onPressed: () => _showStatsDialog(context, attendanceService),
                        icon: Icon(
                          attendanceService.isOnline 
                              ? Icons.cloud_done 
                              : Icons.cloud_off,
                        ),
                        label: Text(
                          attendanceService.isOnline 
                              ? 'Online' 
                              : 'Offline (${attendanceService.pendingCount})',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: attendanceService.isOnline 
                              ? Colors.green 
                              : Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                        ),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context, AttendanceService attendanceService) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Icon(
              attendanceService.isOnline ? Icons.cloud_done : Icons.cloud_off,
              color: attendanceService.isOnline ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 8),
            Text(attendanceService.isOnline ? 'Online Status' : 'Offline Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow('Connection', attendanceService.isOnline ? 'Online' : 'Offline'),
            _buildStatusRow('Pending Records', '${attendanceService.pendingCount}'),
            _buildStatusRow('Syncing', attendanceService.isSyncing ? 'Yes' : 'No'),
            
            if (attendanceService.pendingCount > 0) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: attendanceService.isOnline 
                      ? () {
                          Get.back();
                          attendanceService.syncPendingRecords();
                        }
                      : null,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}