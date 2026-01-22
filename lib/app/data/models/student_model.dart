class StudentModel {
  final int id;
  final String rollNumber;
  final String name;
  final String fatherName;
  final String? cnic;
  final String gender;
  final int? collegeId;
  final String? collegeName;
  final String? picture;
  final String? testPhoto;
  final String? hallNumber;
  final String? seatNumber;
  final String? venue;
  final String? testName;
  final String? testDate;
  final BiometricStatus? biometricStatus;

  StudentModel({
    required this.id,
    required this.rollNumber,
    required this.name,
    required this.fatherName,
    this.cnic,
    required this.gender,
    this.collegeId,
    this.collegeName,
    this.picture,
    this.testPhoto,
    this.hallNumber,
    this.seatNumber,
    this.venue,
    this.testName,
    this.testDate,
    this.biometricStatus,
  });

  // ✅ HELPER: Check if student has photo captured
  bool get hasPhoto {
    if (testPhoto == null) return false;
    if (testPhoto!.isEmpty) return false;

    // Check if it's a valid URL or path
    return testPhoto!.contains('http') ||
        testPhoto!.contains('/') ||
        testPhoto!.isNotEmpty;
  }

  // ✅ HELPER: Check if student has fingerprint
  bool get hasFingerprint => biometricStatus?.hasFingerprint ?? false;

  // ✅ HELPER: Get fingerprint quality
  int? get fingerprintQuality => biometricStatus?.fingerprintQuality;

  // ✅ HELPER: Get fingerprint quality status
  String? get fingerprintQualityStatus => biometricStatus?.qualityStatus;

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      rollNumber: json['roll_number'] ?? '',
      name: json['name'] ?? '',
      fatherName: json['father_name'] ?? '',
      cnic: json['cnic'],
      gender: json['gender'] ?? 'Male',
      collegeId: json['college_id'],
      collegeName: json['college_name'],
      picture: json['picture'],
      testPhoto: json['test_photo'],
      hallNumber: json['hall_number']?.toString(),
      seatNumber: json['seat_number']?.toString(),
      venue: json['venue'],
      testName: json['test_name'],
      testDate: json['test_date'],
      biometricStatus: json['biometric_status'] != null
          ? BiometricStatus.fromJson(json['biometric_status'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roll_number': rollNumber,
      'name': name,
      'father_name': fatherName,
      'cnic': cnic,
      'gender': gender,
      'college_id': collegeId,
      'college_name': collegeName,
      'picture': picture,
      'test_photo': testPhoto,
      'hall_number': hallNumber,
      'seat_number': seatNumber,
      'venue': venue,
      'test_name': testName,
      'test_date': testDate,
      'biometric_status': biometricStatus?.toJson(),
    };
  }

  // ✅ HELPER: Create a copy with updated fields
  StudentModel copyWith({
    int? id,
    String? rollNumber,
    String? name,
    String? fatherName,
    String? cnic,
    String? gender,
    int? collegeId,
    String? collegeName,
    String? picture,
    String? testPhoto,
    String? hallNumber,
    String? seatNumber,
    String? venue,
    String? testName,
    String? testDate,
    BiometricStatus? biometricStatus,
  }) {
    return StudentModel(
      id: id ?? this.id,
      rollNumber: rollNumber ?? this.rollNumber,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      cnic: cnic ?? this.cnic,
      gender: gender ?? this.gender,
      collegeId: collegeId ?? this.collegeId,
      collegeName: collegeName ?? this.collegeName,
      picture: picture ?? this.picture,
      testPhoto: testPhoto ?? this.testPhoto,
      hallNumber: hallNumber ?? this.hallNumber,
      seatNumber: seatNumber ?? this.seatNumber,
      venue: venue ?? this.venue,
      testName: testName ?? this.testName,
      testDate: testDate ?? this.testDate,
      biometricStatus: biometricStatus ?? this.biometricStatus,
    );
  }

  @override
  String toString() {
    return 'StudentModel(id: $id, rollNumber: $rollNumber, name: $name, hasPhoto: $hasPhoto)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is StudentModel &&
        other.id == id &&
        other.rollNumber == rollNumber;
  }

  @override
  int get hashCode => id.hashCode ^ rollNumber.hashCode;
}

class BiometricStatus {
  final bool hasFingerprint;
  final int? fingerprintQuality;
  final String? registeredAt;
  final String? qualityStatus;

  BiometricStatus({
    required this.hasFingerprint,
    this.fingerprintQuality,
    this.registeredAt,
    this.qualityStatus,
  });

  factory BiometricStatus.fromJson(Map<String, dynamic> json) {
    return BiometricStatus(
      hasFingerprint: json['has_fingerprint'] ?? false,
      fingerprintQuality: json['fingerprint_quality'],
      registeredAt: json['registered_at'],
      qualityStatus: json['quality_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_fingerprint': hasFingerprint,
      'fingerprint_quality': fingerprintQuality,
      'registered_at': registeredAt,
      'quality_status': qualityStatus,
    };
  }

  BiometricStatus copyWith({
    bool? hasFingerprint,
    int? fingerprintQuality,
    String? registeredAt,
    String? qualityStatus,
  }) {
    return BiometricStatus(
      hasFingerprint: hasFingerprint ?? this.hasFingerprint,
      fingerprintQuality: fingerprintQuality ?? this.fingerprintQuality,
      registeredAt: registeredAt ?? this.registeredAt,
      qualityStatus: qualityStatus ?? this.qualityStatus,
    );
  }

  @override
  String toString() {
    return 'BiometricStatus(hasFingerprint: $hasFingerprint, quality: $fingerprintQuality, status: $qualityStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BiometricStatus &&
        other.hasFingerprint == hasFingerprint &&
        other.fingerprintQuality == fingerprintQuality &&
        other.registeredAt == registeredAt &&
        other.qualityStatus == qualityStatus;
  }

  @override
  int get hashCode {
    return hasFingerprint.hashCode ^
        fingerprintQuality.hashCode ^
        registeredAt.hashCode ^
        qualityStatus.hashCode;
  }
}
