class UploadQueueModel {
  final int id;
  final String rollNumber;
  final String studentName;
  final String imagePath;
  final DateTime capturedAt;
  final bool isUploaded;
  final String? errorMessage;
  final int retryCount;

  UploadQueueModel({
    required this.id,
    required this.rollNumber,
    required this.studentName,
    required this.imagePath,
    required this.capturedAt,
    this.isUploaded = false,
    this.errorMessage,
    this.retryCount = 0,
  });

  // To JSON for storage/database
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roll_number': rollNumber,
      'student_name': studentName,
      'image_path': imagePath,
      'captured_at': capturedAt.toIso8601String(),
      'is_uploaded': isUploaded ? 1 : 0,
      'error_message': errorMessage,
      'retry_count': retryCount,
    };
  }

  // From JSON/database
  factory UploadQueueModel.fromJson(Map<String, dynamic> json) {
    return UploadQueueModel(
      id: json['id'] is String ? int.parse(json['id']) : (json['id'] ?? 0),
      rollNumber: json['roll_number'] ?? '',
      studentName: json['student_name'] ?? '',
      imagePath: json['image_path'] ?? json['photo_path'] ?? '',
      capturedAt: json['captured_at'] != null
          ? DateTime.parse(json['captured_at'])
          : DateTime.now(),
      isUploaded: json['is_uploaded'] == 1 || json['is_uploaded'] == true,
      errorMessage: json['error_message'],
      retryCount: json['retry_count'] ?? 0,
    );
  }

  // Copy with for updates
  UploadQueueModel copyWith({
    int? id,
    String? rollNumber,
    String? studentName,
    String? imagePath,
    DateTime? capturedAt,
    bool? isUploaded,
    String? errorMessage,
    int? retryCount,
  }) {
    return UploadQueueModel(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      studentName: studentName ?? this.studentName,
      imagePath: imagePath ?? this.imagePath,
      capturedAt: capturedAt ?? this.capturedAt,
      isUploaded: isUploaded ?? this.isUploaded,
      errorMessage: errorMessage ?? this.errorMessage,
      retryCount: retryCount ?? this.retryCount,
    );
  }

  // Convert to CapturedStudent for History page
  CapturedStudent toCapturedStudent() {
    return CapturedStudent(
      id: id,
      rollNumber: rollNumber,
      studentName: studentName,
      photoPath: imagePath,
      capturedAt: capturedAt,
      isUploaded: isUploaded,
      retryCount: retryCount,
      errorMessage: errorMessage,
    );
  }

  // Create from CapturedStudent
  factory UploadQueueModel.fromCapturedStudent(CapturedStudent student) {
    return UploadQueueModel(
      id: student.id,
      rollNumber: student.rollNumber,
      studentName: student.studentName,
      imagePath: student.photoPath,
      capturedAt: student.capturedAt,
      isUploaded: student.isUploaded,
      retryCount: student.retryCount,
      errorMessage: student.errorMessage,
    );
  }
}

// CapturedStudent class for History page
class CapturedStudent {
  final int id;
  final String rollNumber;
  final String studentName;
  final String photoPath;
  final DateTime capturedAt;
  final bool isUploaded;
  final int retryCount;
  final String? errorMessage;

  CapturedStudent({
    required this.id,
    required this.rollNumber,
    required this.studentName,
    required this.photoPath,
    required this.capturedAt,
    this.isUploaded = false,
    this.retryCount = 0,
    this.errorMessage,
  });

  factory CapturedStudent.fromMap(Map<String, dynamic> map) {
    return CapturedStudent(
      id: map['id'] is String ? int.parse(map['id']) : (map['id'] ?? 0),
      rollNumber: map['roll_number'] ?? '',
      studentName: map['student_name'] ?? '',
      photoPath: map['image_path'] ?? map['photo_path'] ?? '',
      capturedAt: map['captured_at'] != null
          ? DateTime.parse(map['captured_at'])
          : DateTime.now(),
      isUploaded: map['is_uploaded'] == 1 || map['is_uploaded'] == true,
      retryCount: map['retry_count'] ?? 0,
      errorMessage: map['error_message'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roll_number': rollNumber,
      'student_name': studentName,
      'image_path': photoPath,
      'captured_at': capturedAt.toIso8601String(),
      'is_uploaded': isUploaded ? 1 : 0,
      'retry_count': retryCount,
      'error_message': errorMessage,
    };
  }

  // Convert to UploadQueueModel
  UploadQueueModel toUploadQueueModel() {
    return UploadQueueModel(
      id: id,
      rollNumber: rollNumber,
      studentName: studentName,
      imagePath: photoPath,
      capturedAt: capturedAt,
      isUploaded: isUploaded,
      retryCount: retryCount,
      errorMessage: errorMessage,
    );
  }
}
