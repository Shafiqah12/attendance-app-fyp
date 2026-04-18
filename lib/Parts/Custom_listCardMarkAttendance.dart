import 'package:flutter/material.dart';
import 'package:attendify/services/api_service.dart';

class listCardMarkAttendence extends StatelessWidget {
  final EnrolledStudent student;
  final String status;
  final VoidCallback onToggle;

  const listCardMarkAttendence({
    super.key,
    required this.student,
    required this.status,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            // Status Circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: status == 'P' ? Colors.green : Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  status == 'P' ? 'P' : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.studentName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    student.studentRegistrationNumber,
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Toggle Buttons
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Present Button
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: status == 'P' ? Colors.green : Colors.grey.shade300,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'P',
                      style: TextStyle(
                        color: status == 'P' ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                // Absent Button
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: status == 'A' ? Colors.red : Colors.grey.shade300,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(8),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: status == 'A' ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}