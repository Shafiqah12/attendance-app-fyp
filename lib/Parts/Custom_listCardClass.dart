import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../util/appRoutes.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

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

class listCardClass extends StatelessWidget {
  final Class classes;

  const listCardClass({
    super.key,
    required this.classes,
  });

  Future<void> _deleteClass(BuildContext context) async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Are you sure you want to delete "${classes.courseName}"?'),
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
      final authService = Provider.of<AuthService>(context, listen: false);
      final userId = authService.userId;
      
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await ApiService.deleteClass(classes.id);
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${classes.courseName} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate back or refresh the page
        Navigator.pop(context, true);
      } else if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete class'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          width: 2,
          color: theme.colorScheme.onSurface,
          style: BorderStyle.solid,
        ),
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
                    Text(classes.courseName, style: theme.textTheme.titleLarge),
                    Text('Start: ' + classes.startingDate, style: theme.textTheme.bodySmall),
                    Text('End: ' + classes.endingDate, style: theme.textTheme.bodySmall),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      appRoutes.enrollStudentPage,
                      arguments: classes.id,
                    );
                  },
                  icon: Icon(Icons.school, color: theme.colorScheme.primary),
                  label: Text('Students', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface)),
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
                    arguments: classes.id,
                  );
                },
                icon: Icon(Icons.check_box, color: theme.colorScheme.primary),
                label: Text('Attnd', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surface, elevation: 0),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    appRoutes.editClassPage,
                    arguments: classes.id,
                  );
                },
                icon: Icon(Icons.edit, color: theme.colorScheme.primary),
                label: Text('Edit', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surface, elevation: 0),
              ),
              ElevatedButton.icon(
                onPressed: () => _deleteClass(context),
                icon: Icon(Icons.delete, color: theme.colorScheme.primary),
                label: Text('Del', style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface, fontSize: 12)),
                style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.surface, elevation: 0),
              ),
            ],
          ),
        ],
      ),
    );
  }
}