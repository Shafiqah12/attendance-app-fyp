import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../util/appRoutes.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

// ============ CLASS MODEL DEFINED HERE ============
class Class {
  final String id;
  final String courseName;
  final String startingDate;
  final String endingDate;

  const Class({
    required this.id,
    required this.courseName,
    required this.startingDate,
    required this.endingDate,
  });
}
// =================================================

class listCardClass extends StatelessWidget {
  final Map<String, dynamic> classes;

  const listCardClass({
    super.key,
    required this.classes,
  });

  Future<void> _deleteClass(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete "${classes['class_name'] ?? classes['courseName']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final success = await ApiService.deleteClass(classes['id'].toString());
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${classes['class_name'] ?? classes['courseName']} deleted successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final className = classes['class_name'] ?? classes['courseName'] ?? 'Unknown';
    final startDate = classes['starting_date'] ?? classes['startingDate'] ?? '';
    final endDate = classes['ending_date'] ?? classes['endingDate'] ?? '';
    final classId = classes['id'].toString();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(width: 2, color: theme.colorScheme.onSurface),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.onSurface.withOpacity(0.2),
            blurRadius: 5,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(className, style: theme.textTheme.titleLarge),
                    Text('Start: $startDate', style: theme.textTheme.bodySmall),
                    Text('End: $endDate', style: theme.textTheme.bodySmall),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      appRoutes.enrollStudentPage,
                      arguments: classId,
                    );
                  },
                  icon: Icon(Icons.school, color: theme.colorScheme.primary),
                  label: Text('Students', style: theme.textTheme.labelMedium),
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surface, elevation: 0),
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
                    appRoutes.attendancePage,
                    arguments: classId,
                  );
                },
                icon: Icon(Icons.check_box, color: theme.colorScheme.primary),
                label: Text('Attnd', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surface, elevation: 0),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    appRoutes.editClassPage,
                    arguments: classId,
                  );
                },
                icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                label: Text('Edit', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surface, elevation: 0),
              ),
              ElevatedButton.icon(
                onPressed: () => _deleteClass(context),
                icon: Icon(Icons.delete, color: theme.colorScheme.primary),
                label: Text('Del', style: theme.textTheme.bodyLarge?.copyWith(fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surface, elevation: 0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}