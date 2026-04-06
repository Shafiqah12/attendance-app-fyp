import 'package:attendify/services/api_service.dart';
import 'package:flutter/material.dart';

class listCardStudent extends StatelessWidget {
  final Student student;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const listCardStudent({
    super.key,
    required this.student,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colors = theme.colorScheme;

    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(vertical: 6),
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
              width: MediaQuery.of(context).size.width * 0.25,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("Student_Images/Student.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: onEdit,
                        icon: Icon(Icons.edit, color: colors.primary),
                        label: Text('Edit', style: textTheme.labelLarge),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surfaceContainerHighest,
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: onDelete,
                        icon: Icon(Icons.delete, color: colors.primary),
                        label: Text('Delete', style: textTheme.labelLarge),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.surfaceContainerHighest,
                          elevation: 0,
                        ),
                      ),
                    ],
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