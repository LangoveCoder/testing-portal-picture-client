class UploadQueueModel {
  final String id;
  final String rollNumber;
  final String studentName;
  final String imagePath;
  final DateTime capturedAt;
  final bool isUploaded;
  final String? errorMessage;

  UploadQueueModel({
    required this.id,
    required this.rollNumber,
    required this.studentName,
    required this.imagePath,
    required this.capturedAt,
    this.isUploaded = false,
    this.errorMessage,
  });

  // To JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roll_number': rollNumber,
      'student_name': studentName,
      'image_path': imagePath,
      'captured_at': capturedAt.toIso8601String(),
      'is_uploaded': isUploaded,
      'error_message': errorMessage,
    };
  }

  // From JSON
  factory UploadQueueModel.fromJson(Map<String, dynamic> json) {
    return UploadQueueModel(
      id: json['id'],
      rollNumber: json['roll_number'],
      studentName: json['student_name'],
      imagePath: json['image_path'],
      capturedAt: DateTime.parse(json['captured_at']),
      isUploaded: json['is_uploaded'] ?? false,
      errorMessage: json['error_message'],
    );
  }

  // Copy with for updates
  UploadQueueModel copyWith({
    String? id,
    String? rollNumber,
    String? studentName,
    String? imagePath,
    DateTime? capturedAt,
    bool? isUploaded,
    String? errorMessage,
  }) {
    return UploadQueueModel(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      studentName: studentName ?? this.studentName,
      imagePath: imagePath ?? this.imagePath,
      capturedAt: capturedAt ?? this.capturedAt,
      isUploaded: isUploaded ?? this.isUploaded,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
