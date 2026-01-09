import 'package:flutter/material.dart';

class TestModel {
  final int id;
  final String name;
  final String description;
  final String testDate;
  final String testTime;
  final String venue;
  final String status; // 'upcoming', 'active', 'completed'
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final String createdAt;
  final bool isActive;

  TestModel({
    required this.id,
    required this.name,
    required this.description,
    required this.testDate,
    required this.testTime,
    required this.venue,
    required this.status,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.createdAt,
    required this.isActive,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      testDate: json['test_date'] ?? '',
      testTime: json['test_time'] ?? '',
      venue: json['venue'] ?? '',
      status: json['status'] ?? 'upcoming',
      totalStudents: json['total_students'] ?? 0,
      presentCount: json['present_count'] ?? 0,
      absentCount: json['absent_count'] ?? 0,
      createdAt: json['created_at'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'test_date': testDate,
      'test_time': testTime,
      'venue': venue,
      'status': status,
      'total_students': totalStudents,
      'present_count': presentCount,
      'absent_count': absentCount,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }

  // Get status color
  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF10B981); // Green
      case 'upcoming':
        return const Color(0xFF3B82F6); // Blue
      case 'completed':
        return const Color(0xFF6B7280); // Gray
      default:
        return const Color(0xFF6B7280);
    }
  }

  // Get status icon
  IconData getStatusIcon() {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.play_circle_filled;
      case 'upcoming':
        return Icons.schedule;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help;
    }
  }

  // Get attendance percentage
  double get attendancePercentage {
    if (totalStudents == 0) return 0.0;
    return (presentCount / totalStudents) * 100;
  }

  // Check if test is selectable
  bool get canSelect {
    return status.toLowerCase() == 'active' || status.toLowerCase() == 'upcoming';
  }
}