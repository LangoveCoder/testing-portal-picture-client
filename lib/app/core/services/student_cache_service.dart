import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/student_model.dart';
import '../../data/providers/api_provider.dart';
import '../utils/custom_toast.dart';
import './auth_service.dart'; // ✅ ADD THIS IMPORT

class StudentCacheService extends GetxService {
  final GetStorage storage = GetStorage();
  late ApiProvider apiProvider;
  final Connectivity connectivity = Connectivity();

  static const String studentsKey = 'cached_students';
  static const String lastSyncKey = 'last_sync_time';

  var cachedStudents = <String, StudentModel>{}.obs; // Key = roll_number
  var lastSyncTime = Rxn<DateTime>();
  var isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();

    // Get the shared ApiProvider instance with auth token
    try {
      apiProvider = Get.find<ApiProvider>();
    } catch (e) {
      print('ApiProvider not found, creating new instance: $e');
      apiProvider = ApiProvider();
    }

    loadCache();
    autoSync();
  }

  // Load cached students from storage
  void loadCache() {
    try {
      final studentsData = storage.read(studentsKey);
      final lastSync = storage.read(lastSyncKey);

      if (studentsData != null) {
        final Map<String, dynamic> jsonMap = jsonDecode(studentsData);
        cachedStudents.value = jsonMap.map(
          (key, value) => MapEntry(key, StudentModel.fromJson(value)),
        );
        print('Loaded ${cachedStudents.length} students from cache');
      }

      if (lastSync != null) {
        lastSyncTime.value = DateTime.parse(lastSync);
        print('Last sync: ${lastSyncTime.value}');
      }
    } catch (e) {
      print('Error loading student cache: $e');
    }
  }

  // Save students to cache
  void saveCache() {
    try {
      final jsonMap = cachedStudents.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      storage.write(studentsKey, jsonEncode(jsonMap));
      storage.write(lastSyncKey, DateTime.now().toIso8601String());
      lastSyncTime.value = DateTime.now();
      print('Saved ${cachedStudents.length} students to cache');
    } catch (e) {
      print('Error saving student cache: $e');
    }
  }

  // Get student from cache
  StudentModel? getStudent(String rollNumber) {
    return cachedStudents[rollNumber];
  }

  // Add student to cache
  void addStudent(StudentModel student) {
    cachedStudents[student.rollNumber] = student;
    saveCache();
  }

  // Check if student exists in cache
  bool hasStudent(String rollNumber) {
    return cachedStudents.containsKey(rollNumber);
  }

  // Check if online
  Future<bool> isOnline() async {
    try {
      final result = await connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Sync students from server (download all students)
  Future<void> syncStudents() async {
    try {
      isSyncing.value = true;
      CustomToast.info('Syncing students...');

      print('=== SYNCING STUDENTS ===');

      // Get operator's assigned college ID (optional filter)
      AuthService? authService;
      try {
        authService = Get.find<AuthService>();
      } catch (e) {
        print('AuthService not found: $e');
      }

      final collegeId = authService?.currentOperator.value?.assignedCollegeId;
      print('College ID: $collegeId');

      final response = await apiProvider.bulkDownloadStudents(
        collegeId: collegeId,
      );

      print('✅ Response received');
      print('Success field: ${response.data['success']}');
      print('Count field: ${response.data['count']}');
      print('Response keys: ${response.data.keys}');
      print('Full response data: ${response.data}');

      final studentsField = response.data['students'] ?? response.data['data'];

      if (response.data['success'] == true && studentsField != null) {
        final List<dynamic> studentsList = studentsField as List<dynamic>;

        print('Processing ${studentsList.length} students...');

        cachedStudents.clear();

        int successCount = 0;
        int errorCount = 0;

        for (var studentData in studentsList) {
          try {
            final student = StudentModel.fromJson(studentData);
            cachedStudents[student.rollNumber] = student;
            successCount++;
          } catch (e) {
            print('❌ Error parsing student: $e');
            errorCount++;
          }
        }

        print('✅ Successfully cached $successCount students');
        if (errorCount > 0) {
          print('❌ Failed to parse $errorCount students');
        }

        storage.write(lastSyncKey, DateTime.now().toIso8601String());
        lastSyncTime.value = DateTime.now();
        saveCache();

        CustomToast.success('Synced $successCount students');
      } else {
        print('❌ Sync failed or students is null');
        CustomToast.error('Sync failed');
      }
    } catch (e, stackTrace) {
      print('❌ SYNC ERROR: $e');
      print('Stack trace: $stackTrace');
      CustomToast.error('Sync failed: $e');
    } finally {
      isSyncing.value = false;
    }
  }

  // Auto sync on app start if needed
  void autoSync() async {
    print('=== AUTO SYNC CHECK ===');
    print('Last sync time: ${lastSyncTime.value}');
    print('Cached students: ${cachedStudents.length}');

    // Wait for services to initialize
    await Future.delayed(Duration(seconds: 1));

    // ✅ Check if user is authenticated first
    AuthService? authService;
    try {
      authService = Get.find<AuthService>();
      if (!authService.isAuthenticated.value) {
        print('Skipping auto-sync - not authenticated');
        return;
      }
    } catch (e) {
      print('AuthService not found - skipping auto-sync: $e');
      return;
    }

    // Check if online
    final online = await isOnline();
    print('Is online: $online');

    if (!online) {
      print('Skipping auto-sync - offline');
      if (cachedStudents.isEmpty) {
        CustomToast.warning('Connect to internet to sync student data');
      }
      return;
    }

    // Sync if never synced before OR cache is empty
    if (lastSyncTime.value == null || cachedStudents.isEmpty) {
      print('First time or empty cache - syncing...');
      CustomToast.info('Downloading student data for offline use');
      await syncStudents();
      return;
    }

    final hoursSinceSync =
        DateTime.now().difference(lastSyncTime.value!).inHours;
    print('Hours since last sync: $hoursSinceSync');

    // Auto-sync if more than 24 hours
    if (hoursSinceSync > 24) {
      print('Last sync was $hoursSinceSync hours ago - syncing...');
      await syncStudents();
    } else {
      print('Cache is fresh - no sync needed');
    }
  }

  // Clear cache
  void clearCache() {
    cachedStudents.clear();
    storage.remove(studentsKey);
    storage.remove(lastSyncKey);
    lastSyncTime.value = null;
    print('Cache cleared');
  }

  // Get cache stats
  Map<String, dynamic> getCacheStats() {
    return {
      'total_students': cachedStudents.length,
      'last_sync': lastSyncTime.value?.toString() ?? 'Never',
      'hours_since_sync': lastSyncTime.value != null
          ? DateTime.now().difference(lastSyncTime.value!).inHours
          : null,
    };
  }
}
