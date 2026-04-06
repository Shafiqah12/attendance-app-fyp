import 'package:attendify/services/api_service.dart';
import 'package:flutter/material.dart';

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
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    final imgPath = status == 'P'
        ? 'Attendence_Images/Present_Image.jpg'
        : 'Attendence_Images/Absent_Image.jpg';

    return Container(
      height: 90,
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
              margin: const EdgeInsets.only(right: 8),
              width: MediaQuery.of(context).size.width * 0.17,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('Student_Images/Student.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.studentName,
                    style: textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
                  ),
                  Text(
                    'Reg No: ${student.studentRegistrationNumber}',
                    style: textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.2,
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: onToggle,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(40, 40),
                    backgroundColor: colors.surfaceContainerHighest,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Image.asset(
                    imgPath,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}