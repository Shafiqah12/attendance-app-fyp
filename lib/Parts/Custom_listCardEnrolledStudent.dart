import 'package:flutter/material.dart';
import 'package:attendify/services/api_service.dart';

class listCardEnrolledStudent extends StatelessWidget {
  final EnrolledStudent student;  // Use EnrolledStudent type
  final String classId;
  final VoidCallback onUnenroll;

  const listCardEnrolledStudent({
    super.key,
    required this.student,
    required this.classId,
    required this.onUnenroll,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Container(
      height: 110,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("Student_Images/Student.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.75,
              padding: const EdgeInsets.all(2),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          student.studentName,
                          style: textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Reg No: ${student.studentRegistrationNumber}',
                          style: textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: colors.primary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 70),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: onUnenroll,
                          icon: Icon(Icons.delete, color: colors.primary),
                          label: Text(
                            'Delete',
                            style: textTheme.labelLarge!.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.surfaceContainerHighest,
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}