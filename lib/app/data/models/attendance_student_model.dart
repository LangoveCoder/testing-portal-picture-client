class AttendanceStudentModel {
  final int id;
  final String name;
  final String rollNumber;
  final String fatherName;
  final String cnic;
  final String gender;
  final String? picture;
  final String? testPhoto;
  final String hallNumber;
  final String seatNumber;
  final String collegeName;
  final String testDate;
  final BiometricStatusModel biometricStatus;
  final AttendanceRecordModel? attendance;
  final bool alreadyMarked;
  final bool canMarkAttendance;

  AttendanceStudentModel({
    required this.id,
    required this.name,
    required this.rollNumber,
    required this.fatherName,
    required this.cnic,
    required this.gender,
    this.picture,
    this.testPhoto,
    required this.hallNumber,
    required this.seatNumber,
    required this.collegeName,
    required this.testDate,
    required this.biometricStatus,
    this.attendance,
    required this.alreadyMarked,
    required this.canMarkAttendance,
  });

  factory AttendanceStudentModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStudentModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      rollNumber: json['roll_number'] ?? '',
      fatherName: json['father_name'] ?? '',
      cnic: json['cnic'] ?? '',
      gender: json['gender'] ?? '',
      picture: json['picture'],
      testPhoto: json['test_photo'],
      hallNumber: json['hall_number'] ?? '',
      seatNumber: json['seat_number'] ?? '',
      collegeName: json['college_name'] ?? '',
      testDate: json['test_date'] ?? '',
      biometricStatus: BiometricStatusModel.fromJson(json['biometric_status'] ?? {}),
      attendance: json['attendance'] != null 
          ? AttendanceRecordModel.fromJson(json['attendance']) 
          : null,
      alreadyMarked: json['already_marked'] ?? false,
      canMarkAttendance: json['can_mark_attendance'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'roll_number': rollNumber,
      'father_name': fatherName,
      'cnic': cnic,
      'gender': gender,
      'picture': picture,
      'test_photo': testPhoto,
      'hall_number': hallNumber,
      'seat_number': seatNumber,
      'college_name': collegeName,
      'test_date': testDate,
      'biometric_status': biometricStatus.toJson(),
      'attendance': attendance?.toJson(),
      'already_marked': alreadyMarked,
      'can_mark_attendance': canMarkAttendance,
    };
  }
}

class BiometricStatusModel {
  final bool hasFingerprint;
  final bool hasPhoto;
  final int fingerprintQuality;
  final String registeredAt;

  BiometricStatusModel({
    required this.hasFingerprint,
    required this.hasPhoto,
    required this.fingerprintQuality,
    required this.registeredAt,
  });

  factory BiometricStatusModel.fromJson(Map<String, dynamic> json) {
    return BiometricStatusModel(
      hasFingerprint: json['has_fingerprint'] ?? false,
      hasPhoto: json['has_photo'] ?? false,
      fingerprintQuality: json['fingerprint_quality'] ?? 0,
      registeredAt: json['registered_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_fingerprint': hasFingerprint,
      'has_photo': hasPhoto,
      'fingerprint_quality': fingerprintQuality,
      'registered_at': registeredAt,
    };
  }
}

class AttendanceRecordModel {
  final String rollNumber;
  final String studentName;
  final String fatherName;
  final String collegeName;
  final String attendanceStatus;
  final String markedAt;
  final String markedBy;
  final String? notes;
  final String? hallNumber;
  final String? seatNumber;
  final bool? hasPhoto;
  final bool? hasFingerprint;

  AttendanceRecordModel({
    required this.rollNumber,
    required this.studentName,
    required this.fatherName,
    required this.collegeName,
    required this.attendanceStatus,
    required this.markedAt,
    required this.markedBy,
    this.notes,
    this.hallNumber,
    this.seatNumber,
    this.hasPhoto,
    this.hasFingerprint,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      rollNumber: json['roll_number'] ?? '',
      studentName: json['student_name'] ?? '',
      fatherName: json['father_name'] ?? '',
      collegeName: json['college_name'] ?? '',
      attendanceStatus: json['attendance_status'] ?? '',
      markedAt: json['marked_at'] ?? '',
      markedBy: json['marked_by'] ?? '',
      notes: json['notes'],
      hallNumber: json['hall_number'],
      seatNumber: json['seat_number'],
      hasPhoto: json['has_photo'],
      hasFingerprint: json['has_fingerprint'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roll_number': rollNumber,
      'student_name': studentName,
      'father_name': fatherName,
      'college_name': collegeName,
      'attendance_status': attendanceStatus,
      'marked_at': markedAt,
      'marked_by': markedBy,
      'notes': notes,
      'hall_number': hallNumber,
      'seat_number': seatNumber,
      'has_photo': hasPhoto,
      'has_fingerprint': hasFingerprint,
    };
  }
}