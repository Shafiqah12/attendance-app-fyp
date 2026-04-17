import 'package:flutter/material.dart';

class EditAttendanceView extends StatelessWidget {
  final String classId;
  final String attendanceDate;
  
  const EditAttendanceView({
    super.key,
    required this.classId,
    required this.attendanceDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_calendar, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Class ID: $classId'),
            const SizedBox(height: 8),
            Text('Date: $attendanceDate'),
            const SizedBox(height: 16),
            const Text('Edit attendance feature coming soon'),
          ],
        ),
      ),
    );
  }
}