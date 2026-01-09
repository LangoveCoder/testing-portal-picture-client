class AttendanceStatsModel {
  final int total;
  final int present;
  final int absent;
  final double presentPercentage;

  AttendanceStatsModel({
    required this.total,
    required this.present,
    required this.absent,
    required this.presentPercentage,
  });

  factory AttendanceStatsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatsModel(
      total: json['total'] ?? 0,
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      presentPercentage: (json['present_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'present': present,
      'absent': absent,
      'present_percentage': presentPercentage,
    };
  }
}