class AttendanceRequestModel {
  final String rollNumber;
  final int testId;
  final String attendanceStatus; // 'present' or 'absent'
  final String markedBy;
  final String deviceInfo;
  final String? notes;
  final LocationModel? location;
  final DateTime? offlineMarkedAt;
  final bool synced;

  AttendanceRequestModel({
    required this.rollNumber,
    required this.testId,
    required this.attendanceStatus,
    required this.markedBy,
    required this.deviceInfo,
    this.notes,
    this.location,
    this.offlineMarkedAt,
    this.synced = false,
  });

  factory AttendanceRequestModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRequestModel(
      rollNumber: json['roll_number'] ?? '',
      testId: json['test_id'] ?? 0,
      attendanceStatus: json['attendance_status'] ?? '',
      markedBy: json['marked_by'] ?? '',
      deviceInfo: json['device_info'] ?? '',
      notes: json['notes'],
      location: json['location'] != null 
          ? LocationModel.fromJson(json['location']) 
          : null,
      offlineMarkedAt: json['offline_marked_at'] != null 
          ? DateTime.parse(json['offline_marked_at']) 
          : null,
      synced: json['synced'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roll_number': rollNumber,
      'test_id': testId,
      'attendance_status': attendanceStatus,
      'marked_by': markedBy,
      'device_info': deviceInfo,
      'notes': notes,
      'location': location?.toJson(),
      'offline_marked_at': offlineMarkedAt?.toIso8601String(),
      'synced': synced,
    };
  }

  // Create a copy with updated fields
  AttendanceRequestModel copyWith({
    String? rollNumber,
    int? testId,
    String? attendanceStatus,
    String? markedBy,
    String? deviceInfo,
    String? notes,
    LocationModel? location,
    DateTime? offlineMarkedAt,
    bool? synced,
  }) {
    return AttendanceRequestModel(
      rollNumber: rollNumber ?? this.rollNumber,
      testId: testId ?? this.testId,
      attendanceStatus: attendanceStatus ?? this.attendanceStatus,
      markedBy: markedBy ?? this.markedBy,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      offlineMarkedAt: offlineMarkedAt ?? this.offlineMarkedAt,
      synced: synced ?? this.synced,
    );
  }
}

class LocationModel {
  final double latitude;
  final double longitude;

  LocationModel({
    required this.latitude,
    required this.longitude,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class BulkAttendanceResponseModel {
  final bool success;
  final String message;
  final BulkSummaryModel summary;
  final List<BulkResultModel> results;

  BulkAttendanceResponseModel({
    required this.success,
    required this.message,
    required this.summary,
    required this.results,
  });

  factory BulkAttendanceResponseModel.fromJson(Map<String, dynamic> json) {
    return BulkAttendanceResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      summary: BulkSummaryModel.fromJson(json['summary'] ?? {}),
      results: (json['results'] as List<dynamic>? ?? [])
          .map((item) => BulkResultModel.fromJson(item))
          .toList(),
    );
  }
}

class BulkSummaryModel {
  final int totalProcessed;
  final int successful;
  final int failed;

  BulkSummaryModel({
    required this.totalProcessed,
    required this.successful,
    required this.failed,
  });

  factory BulkSummaryModel.fromJson(Map<String, dynamic> json) {
    return BulkSummaryModel(
      totalProcessed: json['total_processed'] ?? 0,
      successful: json['successful'] ?? 0,
      failed: json['failed'] ?? 0,
    );
  }
}

class BulkResultModel {
  final String rollNumber;
  final bool success;
  final String message;
  final String status;

  BulkResultModel({
    required this.rollNumber,
    required this.success,
    required this.message,
    required this.status,
  });

  factory BulkResultModel.fromJson(Map<String, dynamic> json) {
    return BulkResultModel(
      rollNumber: json['roll_number'] ?? '',
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      status: json['status'] ?? '',
    );
  }
}