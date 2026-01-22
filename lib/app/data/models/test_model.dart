class TestModel {
  final int id;
  final String name; // ✅ Changed from testName
  final String testDate;
  final String testTime;
  final int totalMarks;
  final String? collegeName; // ✅ Added

  TestModel({
    required this.id,
    required this.name,
    required this.testDate,
    required this.testTime,
    required this.totalMarks,
    this.collegeName,
  });

  // ✅ Getter for compatibility
  String get testName => name;

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] ?? 0,
      name: json['test_name'] ?? json['name'] ?? '',
      testDate: json['test_date'] ?? '',
      testTime: json['test_time'] ?? '',
      totalMarks: json['total_marks'] ?? 0,
      collegeName: json['college_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'test_name': name,
      'name': name,
      'test_date': testDate,
      'test_time': testTime,
      'total_marks': totalMarks,
      'college_name': collegeName,
    };
  }

  @override
  String toString() => 'TestModel(id: $id, name: $name, date: $testDate)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
