class StudentModel {
  final int id;
  final String rollNumber;
  final String name;
  final String fatherName;
  final String cnic;
  final String gender;
  final String? picture;
  final String? testPhoto;
  final bool testPhotoCaptured;
  final String testName;
  final String testDate;
  final int? collegeId;  // ADD THIS
  final String? collegeName;  // ADD THIS
  final int? hallNumber;
  final int? zoneNumber;
  final int? rowNumber;
  final int? seatNumber;
  final String venue;

  StudentModel({
    required this.id,
    required this.rollNumber,
    required this.name,
    required this.fatherName,
    required this.cnic,
    required this.gender,
    this.picture,
    this.testPhoto,
    required this.testPhotoCaptured,
    required this.testName,
    required this.testDate,
    this.collegeId,  // ADD THIS
    this.collegeName,  // ADD THIS
    this.hallNumber,
    this.zoneNumber,
    this.rowNumber,
    this.seatNumber,
    required this.venue,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'],
      rollNumber: json['roll_number'],
      name: json['name'],
      fatherName: json['father_name'],
      cnic: json['cnic'],
      gender: json['gender'],
      picture: json['picture'],
      testPhoto: json['test_photo'],
      testPhotoCaptured: json['test_photo_captured'] ?? false,
      testName: json['test_name'] ?? 'N/A',
      testDate: json['test_date'] ?? '',
      collegeId: json['college_id'],  // ADD THIS
      collegeName: json['college_name'],  // ADD THIS
      hallNumber: json['hall_number'],
      zoneNumber: json['zone_number'],
      rowNumber: json['row_number'],
      seatNumber: json['seat_number'],
      venue: json['venue'] ?? 'N/A',
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
      'picture': picture,
      'test_photo': testPhoto,
      'test_photo_captured': testPhotoCaptured,
      'test_name': testName,
      'test_date': testDate,
      'college_id': collegeId,  // ADD THIS
      'college_name': collegeName,  // ADD THIS
      'hall_number': hallNumber,
      'zone_number': zoneNumber,
      'row_number': rowNumber,
      'seat_number': seatNumber,
      'venue': venue,
    };
  }

  // Helper getter for checking if photo exists
  bool get hasPhoto => testPhotoCaptured;

  // Helper getter for full seating info
  String get seatingInfo {
    if (hallNumber == null) return 'Not assigned';
    return 'H$hallNumber-Z$zoneNumber-R$rowNumber-S$seatNumber';
  }
}
