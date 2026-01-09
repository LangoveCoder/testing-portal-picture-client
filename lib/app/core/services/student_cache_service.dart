import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/models/student_model.dart';
import '../../data/providers/api_provider.dart';
import '../utils/custom_toast.dart';

class StudentCacheService extends GetxService {
  final GetStorage storage = GetStorage();
  final ApiProvider apiProvider = ApiProvider();
  final Connectivity connectivity = Connectivity();

  static const String studentsKey = 'cached_students';
  static const String lastSyncKey = 'last_sync_time';

  var cachedStudents = <String, StudentModel>{}.obs; // Key = roll_number
  var lastSyncTime = Rxn<DateTime>();
  var isSyncing = false.obs;

  @override
  void onInit() {
    super.onInit();
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
  Future<bool> syncStudents({int? testId}) async {
    if (isSyncing.value) {
      print('Sync already in progress');
      return false;
    }

    if (!await isOnline()) {
      print('No internet connection for sync');
      CustomToast.warning('Cannot sync without internet connection');
      return false;
    }

    isSyncing.value = true;

    try {
      print('=== SYNCING STUDENTS ===');

      CustomToast.info('Downloading student data');

      // Download all students from API
      final response = await apiProvider.bulkDownloadStudents(testId: testId);

      if (response.data['success'] == true) {
        final List<dynamic> studentsData = response.data['data'];

        print('Downloaded ${studentsData.length} students');

        // Clear existing cache
        cachedStudents.clear();

        // Add all students to cache
        for (var studentJson in studentsData) {
          final student = StudentModel.fromJson(studentJson);
          cachedStudents[student.rollNumber] = student;
        }

        // Save to storage
        saveCache();

        print('Cached ${cachedStudents.length} students');

        CustomToast.success('Downloaded ${cachedStudents.length} students for offline use');

        return true;
      } else {
        CustomToast.error(response.data['message'] ?? 'Could not download students');
        return false;
      }
    } catch (e) {
      print('Sync error: $e');

      CustomToast.error('Could not sync student data: $e');

      return false;
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

    // Check if online
    final online = await isOnline();
    print('Is online: $online');

    if (!online) {
      print('Skipping auto-sync - offline');
      CustomToast.warning('Connect to internet to sync student data');
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
