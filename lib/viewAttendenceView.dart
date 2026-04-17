import 'package:flutter/material.dart';

class ViewAttendanceView extends StatelessWidget {
  final String classId;
  final String attendanceDate;
  
  const ViewAttendanceView({
    super.key,
    required this.classId,
    required this.attendanceDate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Attendance'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text('Class ID: $classId'),
            const SizedBox(height: 8),
            Text('Date: $attendanceDate'),
            const SizedBox(height: 16),
            const Text('Attendance details will be shown here'),
          ],
        ),
      ),
    );
  }
}