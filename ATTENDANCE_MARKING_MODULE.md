# Attendance Marking Module

## Overview
The Attendance Marking module provides a complete UI for marking student attendance with photo capture. It integrates with the existing AttendanceService for API submission and offline queue management.

## Features
✅ Student information display with avatar
✅ Photo capture using camera or gallery
✅ Photo preview and retake functionality
✅ Attendance status selection (Present, Late, Absent)
✅ Photo validation for present status
✅ Confirmation dialog before submission
✅ Integration with AttendanceService for API/offline queue
✅ Modern, responsive UI with dark/light theme support

## Module Structure

```
lib/app/modules/mark_attendance/
├── bindings/
│   └── mark_attendance_binding.dart
├── controllers/
│   └── mark_attendance_controller.dart
└── views/
    └── mark_attendance_view.dart
```

## How to Navigate

Navigate to the attendance marking screen by passing a student object:

```dart
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

// From any controller or view
Get.toNamed(
  AppRoutes.MARK_ATTENDANCE,
  arguments: {
    'student': studentObject, // StudentModel instance
  },
);
```

## Usage Example

### From Student Search
```dart
// In student_search_controller.dart
void onStudentSelected(StudentModel student) {
  Get.toNamed(
    AppRoutes.MARK_ATTENDANCE,
    arguments: {'student': student},
  );
}
```

### From Students List
```dart
// In students_controller.dart
void markAttendance(StudentModel student) {
  Get.toNamed(
    AppRoutes.MARK_ATTENDANCE,
    arguments: {'student': student},
  );
}
```

## UI Components

### 1. Student Info Card
- Displays student avatar/photo
- Shows student name prominently
- Roll number badge
- Father name and college info

### 2. Photo Section
- **No Photo State**: Shows "CAPTURE PHOTO" button
- **Photo Captured State**: Shows preview with Retake/Remove options
- Photo source selection dialog (Camera/Gallery)

### 3. Status Selection
Three status options with visual feedback:
- **Present** (Green) - Requires photo, shows confirmation dialog
- **Late** (Orange) - Requires photo, shows confirmation dialog
- **Absent** (Red) - No photo required, immediately submits and returns to home

### 4. Submit Button
- Shows loading indicator during submission
- Confirmation dialog before marking
- Returns to previous screen on success

## Validation Rules

1. **Photo Required**: Photo is mandatory for "Present" and "Late" status
2. **Student Required**: Cannot submit without student data
3. **Status Required**: One status must be selected (default: Present)
4. **Absent Flow**: When "Absent" is selected, attendance is immediately marked and user returns to home page

## Controller Methods

### `capturePhoto()`
Opens camera to capture student photo using front camera with 85% quality.

### `pickFromGallery()`
Allows selecting photo from device gallery as fallback.

### `showPhotoSourceDialog()`
Shows dialog to choose between camera or gallery.

### `removePhoto()`
Removes the currently captured photo.

### `setStatus(String status)`
Changes attendance status ('present', 'late', or 'absent'). If 'absent' is selected, automatically submits and returns to home.

### `submitAttendanceDirectly()`
Submits attendance without confirmation dialog (used for absent status).

### `submitAttendance()`
Validates and submits attendance to AttendanceService.

### `confirmSubmit()`
Shows confirmation dialog before submission.

## Integration with AttendanceService

The module uses the existing `AttendanceService.markAttendance()` method:

```dart
final success = await attendanceService.markAttendance(
  studentId: student.id,
  rollNumber: student.rollNumber,
  status: selectedStatus.value,
  photoPath: capturedPhotoPath.value,
);
```

The AttendanceService handles:
- API submission to backend
- Offline queue management
- Photo upload
- Error handling

## Theming

The UI automatically adapts to light/dark theme using:
- `AppColors.getBackground(context)`
- `AppColors.getCardBackground(context)`
- `AppColors.getTextPrimary(context)`
- `AppColors.getShadow(context)`

## Dependencies

Required packages (already in pubspec.yaml):
- `image_picker` - For photo capture
- `get` - State management and navigation
- Custom services:
  - `AttendanceService` - Attendance submission
  - `CustomToast` - User feedback

## Testing

To test the module:

1. **Run the app** on Chrome or Android device
2. **Login** with valid credentials
3. **Search for a student** or select from list
4. **Navigate** to mark attendance
5. **Capture photo** using camera or gallery
6. **Select status** (Present/Late/Absent)
7. **Submit** and verify success message

## Error Handling

The module handles:
- Missing student data (shows error screen)
- Photo capture failure (toast message)
- Network errors (handled by AttendanceService)
- Validation errors (toast messages)

## Future Enhancements

Potential improvements:
- [ ] Bulk attendance marking
- [ ] Face recognition integration
- [ ] Attendance history for student
- [ ] Edit attendance after submission
- [ ] Attendance notes/remarks field
- [ ] Geolocation verification
- [ ] Time-based restrictions

## Route Configuration

The route is configured in `app_pages.dart`:

```dart
GetPage(
  name: AppRoutes.MARK_ATTENDANCE,
  page: () => const MarkAttendanceView(),
  binding: MarkAttendanceBinding(),
),
```

Route constant: `AppRoutes.MARK_ATTENDANCE = '/mark-attendance'`

## Summary

The Attendance Marking module is now fully integrated and ready to use. It provides a complete, modern UI for marking student attendance with all necessary validations and error handling.

**Status**: ✅ Complete and Production Ready

**Created**: January 21, 2026
