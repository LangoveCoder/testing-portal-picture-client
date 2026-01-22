class BiometricOperatorModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String status;
  final int? assignedCollegeId;
  final CollegeInfo? assignedCollege;
  final List<TestInfo> tests;
  final OperatorPermissions permissions;

  BiometricOperatorModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.status,
    this.assignedCollegeId,
    this.assignedCollege,
    required this.tests,
    required this.permissions,
  });

  factory BiometricOperatorModel.fromJson(Map<String, dynamic> json) {
    return BiometricOperatorModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      status: json['status'] ?? 'active',
      assignedCollegeId: json['assigned_college_id'],
      assignedCollege: json['assigned_college'] != null
          ? CollegeInfo.fromJson(json['assigned_college'])
          : null,
      tests: (json['accessible_tests'] as List<dynamic>?) // ✅ Changed from 'tests' to 'accessible_tests'
              ?.map((test) => TestInfo.fromJson(test))
              .toList() ??
          [],
      permissions: json['permissions'] != null
          ? OperatorPermissions.fromJson(json['permissions'])
          : OperatorPermissions.defaultPermissions(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      'assigned_college_id': assignedCollegeId,
      'assigned_college': assignedCollege?.toJson(),
      'tests': tests.map((test) => test.toJson()).toList(),
      'permissions': permissions.toJson(),
    };
  }
}

class CollegeInfo {
  final int id;
  final String name;
  final String district;
  final String province;

  CollegeInfo({
    required this.id,
    required this.name,
    required this.district,
    required this.province,
  });

  factory CollegeInfo.fromJson(Map<String, dynamic> json) {
    return CollegeInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      district: json['district'] ?? '',
      province: json['province'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'district': district,
      'province': province,
    };
  }
}

class TestInfo {
  final int id;
  final String testName;
  final String testDate;
  final String testTime;
  final int totalMarks;

  TestInfo({
    required this.id,
    required this.testName,
    required this.testDate,
    required this.testTime,
    required this.totalMarks,
  });

  factory TestInfo.fromJson(Map<String, dynamic> json) {
    return TestInfo(
      id: json['id'] ?? 0,
      testName: json['test_name'] ?? json['college_name'] ?? 'Test ${json['id']}', // ✅ Fallback to college_name or generic name
      testDate: json['test_date'] ?? '',
      testTime: json['test_time'] ?? '',
      totalMarks: json['total_marks'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_name': testName,
      'test_date': testDate,
      'test_time': testTime,
      'total_marks': totalMarks,
    };
  }
}

class OperatorPermissions {
  final bool canRegisterFingerprints;
  final bool canVerifyFingerprints;
  final bool canViewStudents;

  OperatorPermissions({
    required this.canRegisterFingerprints,
    required this.canVerifyFingerprints,
    required this.canViewStudents,
  });

  factory OperatorPermissions.fromJson(Map<String, dynamic> json) {
    return OperatorPermissions(
      canRegisterFingerprints: json['can_register_fingerprints'] ?? false,
      canVerifyFingerprints: json['can_verify_fingerprints'] ?? false,
      canViewStudents: json['can_view_students'] ?? false,
    );
  }

  factory OperatorPermissions.defaultPermissions() {
    return OperatorPermissions(
      canRegisterFingerprints: true,
      canVerifyFingerprints: true,
      canViewStudents: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'can_register_fingerprints': canRegisterFingerprints,
      'can_verify_fingerprints': canVerifyFingerprints,
      'can_view_students': canViewStudents,
    };
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final BiometricOperatorModel? operator;
  final String? token;
  final String? expiresAt;

  LoginResponse({
    required this.success,
    required this.message,
    this.operator,
    this.token,
    this.expiresAt,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      operator: json['data']?['operator'] != null
          ? BiometricOperatorModel.fromJson(json['data']['operator'])
          : null,
      token: json['data']?['token'],
      expiresAt: json['data']?['expires_at'],
    );
  }
}
