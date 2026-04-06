// Custom_listCardAttendance.dart
import 'package:attendify/util/appRoutes.dart';
import 'package:flutter/material.dart';

class Attendance {
  final String attendanceDate;
  final String presentStudents;

  const Attendance({
    required this.attendanceDate,
    required this.presentStudents,
  });
}

class listCardAttendance extends StatelessWidget {
  final Attendance attendance;
  final String classId;
  final VoidCallback onDelete;  // new callback

  const listCardAttendance({
    super.key,
    required this.attendance,
    required this.classId,
    required this.onDelete,    // accept it in constructor
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 2, color: colors.onSurface),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date : ${attendance.attendanceDate}',
                    style: textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
                  ),
                 
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      appRoutes.viewAttendanceViewPage,
                      arguments: {
                        "classId": classId,
                        "Date": attendance.attendanceDate,
                      },
                    );
                  },
                  icon: Icon(Icons.remove_red_eye, color: colors.primary),
                  label: Text('View', style: textTheme.labelLarge!.copyWith(color: colors.onSurface, fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: colors.surfaceContainerHighest, elevation: 0),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      appRoutes.editAttendanceViewPage,
                      arguments: {
                        "classId": classId,
                        "Date": attendance.attendanceDate,
                      },
                    );
                  },
                  icon: Icon(Icons.edit, color: colors.primary),
                  label: Text('Edit', style: textTheme.labelLarge!.copyWith(color: colors.onSurface, fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: colors.surfaceContainerHighest, elevation: 0),
                ),
                ElevatedButton.icon(
                  onPressed: onDelete,  
                  icon: Icon(Icons.delete, color: colors.primary),
                  label: Text('Del', style: textTheme.labelLarge!.copyWith(color: colors.onSurface, fontSize: 12)),
                  style: ElevatedButton.styleFrom(backgroundColor: colors.surfaceContainerHighest, elevation: 0),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
